//! Main planning mode orchestration
//!
//! This module contains the main logic for running planning mode,
//! including the state machine transitions and user interactions.

use anyhow::{Context, Result};
use std::fs;
use std::io::{self, Write};
use std::path::{Path, PathBuf};

use crate::git;
use crate::history;
use crate::llm;
use crate::state::{
    ApprovalChoice, BranchConfirmChoice, CompletionChoice, DirtyFilesChoice,
    PlannerState, RecoveryChoice, RecoveryInfo,
};

/// Configuration for planning mode
#[derive(Debug, Clone)]
pub struct PlannerConfig {
    /// The codepath to work in
    pub codepath: PathBuf,
    /// Whether git operations are disabled
    pub no_git: bool,
    /// Maximum turns for coach/player loop
    pub max_turns: usize,
    /// Whether to run in quiet mode
    pub quiet: bool,
    /// Path to config file
    pub config_path: Option<String>,
}

impl PlannerConfig {
    /// Get the g3-plan directory path
    pub fn plan_dir(&self) -> PathBuf {
        self.codepath.join("g3-plan")
    }

    /// Get the path to new_requirements.md
    pub fn new_requirements_path(&self) -> PathBuf {
        self.plan_dir().join("new_requirements.md")
    }

    /// Get the path to current_requirements.md
    pub fn current_requirements_path(&self) -> PathBuf {
        self.plan_dir().join("current_requirements.md")
    }

    /// Get the path to todo.g3.md
    pub fn todo_path(&self) -> PathBuf {
        self.plan_dir().join("todo.g3.md")
    }

    /// Get the path to planner_history.txt
    pub fn history_path(&self) -> PathBuf {
        self.plan_dir().join("planner_history.txt")
    }
}

/// Result of running planning mode
#[derive(Debug)]
pub enum PlannerResult {
    /// User quit normally
    Quit,
    /// Completed a planning cycle
    Completed,
    /// Error occurred
    Error(String),
}

/// Expand tilde in path to home directory
pub fn expand_codepath(path: &str) -> Result<PathBuf> {
    let expanded = shellexpand::tilde(path);
    let path = PathBuf::from(expanded.as_ref());
    
    // Resolve to absolute path
    let resolved = if path.is_absolute() {
        path
    } else {
        std::env::current_dir()?.join(path)
    };
    
    // Canonicalize if path exists, otherwise just return resolved
    if resolved.exists() {
        Ok(resolved.canonicalize()?)
    } else {
        Ok(resolved)
    }
}

/// Prompt user for codepath if not provided
pub fn prompt_for_codepath() -> Result<PathBuf> {
    print!("Enter codepath (path to your project): ");
    io::stdout().flush()?;
    
    let mut input = String::new();
    io::stdin().read_line(&mut input)?;
    let input = input.trim();
    
    if input.is_empty() || input == "quit" || input == "q" {
        anyhow::bail!("User quit during codepath prompt");
    }
    
    expand_codepath(input)
}

/// Read a line of user input
fn read_line() -> Result<String> {
    let mut input = String::new();
    io::stdin().read_line(&mut input)?;
    Ok(input.trim().to_string())
}

/// Print a message to stdout
fn print_msg(msg: &str) {
    println!("{}", msg);
}

/// Print a message and flush stdout (for prompts)
fn print_prompt(msg: &str) {
    print!("{}", msg);
    io::stdout().flush().ok();
}

/// Initialize the planning directory structure
pub fn initialize_plan_dir(config: &PlannerConfig) -> Result<()> {
    let plan_dir = config.plan_dir();
    
    // Create plan directory if it doesn't exist
    if !plan_dir.exists() {
        fs::create_dir_all(&plan_dir)
            .context("Failed to create g3-plan directory")?;
        print_msg(&format!("📁 Created {}", plan_dir.display()));
    }
    
    // Ensure history file exists
    history::ensure_history_file(&plan_dir)?;
    
    Ok(())
}

/// Check git repository status (if git is enabled)
pub fn check_git_status(config: &PlannerConfig) -> Result<()> {
    if config.no_git {
        print_msg("⚠️  Git operations disabled (--no-git flag)");
        return Ok(());
    }
    
    // Check if we're in a git repo
    if !git::check_git_repo(&config.codepath)? {
        print_msg("No git repository found for the codepath. Please initialize a git repo and try again.");
        anyhow::bail!("No git repository found");
    }
    
    // Get and display current branch
    let branch = git::get_current_branch(&config.codepath)?;
    let prompt = "Current git branch: {branch}\nIs this the correct branch to work on? [Y/n]".replace("{branch}", &branch);
    print_prompt(&format!("{} ", prompt));
    
    let input = read_line()?;
    match BranchConfirmChoice::from_input(&input) {
        Some(BranchConfirmChoice::Confirm) => {},
        Some(BranchConfirmChoice::Quit) | None => {
            print_msg("Exiting - please switch to the correct branch and restart.");
            anyhow::bail!("User declined branch confirmation");
        }
    }
    
    // Check for dirty/untracked files (ignore new_requirements.md)
    let ignore_pattern = "g3-plan/new_requirements.md";
    let dirty_files = git::check_dirty_files(&config.codepath, Some(ignore_pattern))?;
    
    if !dirty_files.is_empty() {
        let warning = r#"Warning: There are uncommitted changes in the git repository:
        {files}
        
        This may be expected if resuming from a previous session.
        Do you want to proceed anyway? [Y/n]"#
            .replace("{files}", &dirty_files.to_display_string());
        print_msg(&warning);
        print_prompt("[Y/n] ");
        
        let input = read_line()?;
        match DirtyFilesChoice::from_input(&input) {
            Some(DirtyFilesChoice::Proceed) => {},
            Some(DirtyFilesChoice::Quit) | None => {
                print_msg("Exiting - please commit or stash your changes and restart.");
                anyhow::bail!("User declined to proceed with dirty files");
            }
        }
    }
    
    Ok(())
}

/// Check startup state and determine if recovery is needed
pub fn check_startup_state(config: &PlannerConfig) -> PlannerState {
    let plan_dir = config.plan_dir();
    
    // Check for recovery situation
    if let Some(recovery_info) = RecoveryInfo::detect(&plan_dir) {
        return PlannerState::Recovery(recovery_info);
    }
    
    PlannerState::PromptForRequirements
}

/// Handle recovery situation
pub fn handle_recovery(config: &PlannerConfig, info: &RecoveryInfo) -> Result<PlannerState> {
    // Build the recovery prompt
    let datetime = info.requirements_modified.as_deref().unwrap_or("unknown time");
    let todo_info = if let Some(ref contents) = info.todo_contents {
        "- todo.g3.md contents:\n{contents}".replace("{contents}", contents)
    } else {
        String::new()
    };
    
    let prompt = r#"The last run didn't complete successfully. Found:
    - current_requirements.md from {datetime}
    {todo_info}
    
    Would you like to resume the previous implementation?
    [Y] Yes - Attempt to resume
    [N] No - Mark as complete and proceed to review new_requirements.md
    [Q] Quit - Exit and investigate manually"#
        .replace("{datetime}", datetime)
        .replace("{todo_info}", &todo_info);
    
    print_msg(&prompt);
    print_prompt("Choice: ");
    
    loop {
        let input = read_line()?;
        match RecoveryChoice::from_input(&input) {
            Some(RecoveryChoice::Resume) => {
                // Log recovery attempt
                history::write_attempting_recovery(&config.plan_dir())?;
                return Ok(PlannerState::ImplementRequirements);
            }
            Some(RecoveryChoice::MarkComplete) => {
                // Log skipped recovery
                history::write_skipped_recovery(&config.plan_dir())?;
                return Ok(PlannerState::ImplementationComplete);
            }
            Some(RecoveryChoice::Quit) => {
                return Ok(PlannerState::Quit);
            }
            None => {
                print_prompt("Invalid choice. Please enter Y, N, or Q: ");
            }
        }
    }
}

/// Prompt for new requirements
pub fn prompt_for_new_requirements(config: &PlannerConfig) -> Result<PlannerState> {
    // Delete existing todo file since we're starting fresh
    let todo_path = config.todo_path();
    if todo_path.exists() {
        fs::remove_file(&todo_path)
            .context("Failed to delete old todo.g3.md")?;
    }
    
    // Display prompt
    let prompt = r#"I will help you refine the current requirements of your project.
    Please write or edit your requirements in `{codepath}/g3-plan/new_requirements.md`.
    Hit enter for me to start a review of that file."#
        .replace("{codepath}", &config.codepath.display().to_string());
    print_msg(&prompt);
    print_prompt("Press Enter when ready: ");
    
    let input = read_line()?;
    if input.to_lowercase() == "quit" || input.to_lowercase() == "q" {
        return Ok(PlannerState::Quit);
    }
    
    // Check if new_requirements.md exists
    let new_req_path = config.new_requirements_path();
    if !new_req_path.exists() {
        let error_msg = "File not found: {path}/g3-plan/new_requirements.md"
            .replace("{path}", &config.codepath.display().to_string());
        print_msg(&format!("❌ {}", error_msg));
        print_msg("Please create the file and try again.");
        return Ok(PlannerState::PromptForRequirements);
    }
    
    // Ensure the file has the ORIGINAL_REQUIREMENTS tag
    ensure_original_requirements_tag(&new_req_path)?;
    
    // Log that we're refining requirements
    history::write_refining_requirements(&config.plan_dir())?;
    
    Ok(PlannerState::RefineRequirements)
}

/// Ensure the new_requirements.md file has the ORIGINAL_REQUIREMENTS tag
fn ensure_original_requirements_tag(path: &Path) -> Result<()> {
    let content = fs::read_to_string(path)
        .context("Failed to read new_requirements.md")?;
    
    // Check if either tag is already present
    if content.contains("{{ORIGINAL USER REQUIREMENTS -- THIS SECTION WILL BE IGNORED BY THE IMPLEMENTATION}}") 
        || content.contains("{{CURRENT REQUIREMENTS}}") {
        return Ok(());
    }
    
    // Prepend the ORIGINAL_REQUIREMENTS tag
    let new_content = format!("{}\n\n{}", "{{ORIGINAL USER REQUIREMENTS -- THIS SECTION WILL BE IGNORED BY THE IMPLEMENTATION}}", content);
    fs::write(path, new_content)
        .context("Failed to update new_requirements.md with ORIGINAL_REQUIREMENTS tag")?;
    
    Ok(())
}

/// Check if requirements have CURRENT REQUIREMENTS tag after LLM refinement
pub fn check_current_requirements_tag(config: &PlannerConfig) -> Result<bool> {
    let new_req_path = config.new_requirements_path();
    let content = fs::read_to_string(&new_req_path)
        .context("Failed to read new_requirements.md")?;
    
    Ok(content.contains("{{CURRENT REQUIREMENTS}}"))
}

/// Prompt user to approve refined requirements
pub fn prompt_for_approval(config: &PlannerConfig) -> Result<ApprovalChoice> {
    let prompt = r#"The LLM has updated `{codepath}/g3-plan/new_requirements.md`.
    Please review the file. If it's acceptable, type 'yes' to proceed with implementation.
    Type 'no' to continue refining, or 'quit' to exit."#
        .replace("{codepath}", &config.codepath.display().to_string());
    print_msg(&prompt);
    print_prompt("Choice: ");
    
    loop {
        let input = read_line()?;
        match ApprovalChoice::from_input(&input) {
            Some(choice) => return Ok(choice),
            None => {
                print_prompt("Invalid choice. Please enter 'yes', 'no', or 'quit': ");
            }
        }
    }
}

/// Move new_requirements.md to current_requirements.md
pub fn promote_requirements(config: &PlannerConfig) -> Result<()> {
    let new_req_path = config.new_requirements_path();
    let current_req_path = config.current_requirements_path();
    
    fs::rename(&new_req_path, &current_req_path)
        .context("Failed to rename new_requirements.md to current_requirements.md")?;
    
    print_msg(&format!(
        "📄 Renamed new_requirements.md to current_requirements.md"
    ));
    
    Ok(())
}

/// Read current requirements content
pub fn read_current_requirements(config: &PlannerConfig) -> Result<String> {
    let path = config.current_requirements_path();
    fs::read_to_string(&path)
        .context("Failed to read current_requirements.md")
}

/// Read todo file content
pub fn read_todo(config: &PlannerConfig) -> Result<Option<String>> {
    let path = config.todo_path();
    if path.exists() {
        Ok(Some(fs::read_to_string(&path)
            .context("Failed to read todo.g3.md")?))
    } else {
        Ok(None)
    }
}

/// Check if all todos are complete
pub fn check_todos_complete(todo_contents: &str) -> bool {
    // Check if there are any incomplete items (- [ ])
    !todo_contents.contains("- [ ]")
}

/// Prompt user to confirm implementation completion
pub fn prompt_for_completion(config: &PlannerConfig) -> Result<CompletionChoice> {
    let todo_contents = read_todo(config)?.unwrap_or_else(|| "(no todo file)".to_string());
    
    let prompt = r#"The coach/player loop has completed.
    
    Todo file contents:
    {todo_contents}
    
    Do you consider the todos and requirements completed? [Y/n]
    If not, we'll return to the coach/player loop."#
        .replace("{todo_contents}", &todo_contents);
    print_msg(&prompt);
    print_prompt("Choice: ");
    
    loop {
        let input = read_line()?;
        match CompletionChoice::from_input(&input) {
            Some(choice) => return Ok(choice),
            None => {
                print_prompt("Invalid choice. Please enter Y, N, or Q: ");
            }
        }
    }
}

/// Complete the implementation - rename files and prepare for commit
pub fn complete_implementation(config: &PlannerConfig) -> Result<(String, String)> {
    let plan_dir = config.plan_dir();
    
    // Generate timestamped filenames
    let req_filename = history::completed_requirements_filename();
    let todo_filename = history::completed_todo_filename();
    
    // Rename current_requirements.md
    let current_req = config.current_requirements_path();
    let completed_req = plan_dir.join(&req_filename);
    if current_req.exists() {
        fs::rename(&current_req, &completed_req)
            .context("Failed to rename current_requirements.md")?;
        print_msg(&format!("📄 Renamed to {}", req_filename));
    }
    
    // Rename todo.g3.md
    let todo_path = config.todo_path();
    let completed_todo = plan_dir.join(&todo_filename);
    if todo_path.exists() {
        fs::rename(&todo_path, &completed_todo)
            .context("Failed to rename todo.g3.md")?;
        print_msg(&format!("📄 Renamed to {}", todo_filename));
    }
    
    // Log completion
    history::write_completed_requirements(&plan_dir, &req_filename, &todo_filename)?;
    
    Ok((req_filename, todo_filename))
}

/// Stage files and make git commit
pub fn stage_and_commit(
    config: &PlannerConfig,
    summary: &str,
    description: &str,
) -> Result<()> {
    if config.no_git {
        print_msg("⚠️  Skipping git commit (--no-git flag)");
        return Ok(());
    }
    
    // Stage files
    print_msg("📦 Staging files...");
    let staging_result = git::stage_files(&config.codepath, &config.plan_dir())?;
    
    if !staging_result.staged.is_empty() {
        print_msg(&format!("  Staged {} files", staging_result.staged.len()));
    }
    if !staging_result.excluded.is_empty() {
        print_msg(&format!("  Excluded {} files (temporary/artifacts)", staging_result.excluded.len()));
    }
    
    // Show pre-commit message
    let pre_commit = r#"Ready to make a git commit with the following message:
    
    Summary: {summary}
    
    Description:
    {description}
    
    Please review the currently staged files (use `git status` in another terminal).
    Press Enter to continue with the commit, or type 'quit' to exit without committing."#
        .replace("{summary}", summary)
        .replace("{description}", description);
    print_msg(&pre_commit);
    
    let input = read_line()?;
    if input.to_lowercase() == "quit" || input.to_lowercase() == "q" {
        print_msg("Skipping commit. Files remain staged.");
        return Ok(());
    }
    
    // If you're modifying this function, ENSURE that:
    // - history::write_git_commit() is called BEFORE git::commit()
    // - No conditional logic can skip the history write if the commit proceeds
    // - Tests in commit_history_ordering_test.rs continue to pass
    history::write_git_commit(&config.plan_dir(), summary)?;
    
    // Re-stage g3-plan directory to include the GIT COMMIT entry we just wrote
    // This ensures planner_history.txt changes are included in the commit
    git::stage_plan_dir(&config.codepath, &config.plan_dir())?;
    
    // Make commit
    print_msg("📝 Making git commit...");
    let _commit_sha = git::commit(&config.codepath, summary, description)?;
    print_msg("✅ Commit successful");
    
    Ok(())
}

/// Parse commit message from LLM response
pub fn parse_commit_message(response: &str) -> (String, String) {
    let mut summary = String::new();
    let mut description = String::new();
    
    if let Some(summary_start) = response.find("{{COMMIT_SUMMARY}}") {
        let after_tag = &response[summary_start + "{{COMMIT_SUMMARY}}".len()..];
        if let Some(end) = after_tag.find("{{COMMIT_DESCRIPTION}}") {
            summary = after_tag[..end].trim().to_string();
        } else {
            summary = after_tag.lines().next().unwrap_or("").trim().to_string();
        }
    }
    
    if let Some(desc_start) = response.find("{{COMMIT_DESCRIPTION}}") {
        let after_tag = &response[desc_start + "{{COMMIT_DESCRIPTION}}".len()..];
        description = after_tag.trim().to_string();
    }
    
    // Ensure summary is max 72 chars
    if summary.len() > 72 {
        summary = format!("{}...", &summary[..69]);
    }
    
    // Ensure description lines are max 72 chars
    let wrapped_desc: Vec<String> = description
        .lines()
        .take(10) // Max 10 lines
        .map(|line| {
            if line.len() > 72 {
                format!("{}...", &line[..69])
            } else {
                line.to_string()
            }
        })
        .collect();
    description = wrapped_desc.join("\n");
    
    // Fallback if parsing failed
    if summary.is_empty() {
        summary = "Implement requirements".to_string();
    }
    
    (summary, description)
}

/// Tools available to the planner agent
pub fn get_planner_tools() -> Vec<&'static str> {
    vec![
        "read_file",
        "write_file", 
        "shell",
        "code_search",
        "str_replace",
        "final_output",
    ]
}

/// Tools NOT available to the planner agent
pub fn get_excluded_planner_tools() -> Vec<&'static str> {
    vec![
        "todo_write", // Planner should not write todos during refinement
    ]
}

/// Run the coach/player implementation loop
/// 
/// This function runs the actual implementation phase using g3-core's Agent
/// in a coach/player feedback loop similar to autonomous mode.
pub async fn run_coach_player_loop(
    planner_config: &PlannerConfig,
    g3_config: &g3_config::Config,
    requirements_content: &str,
) -> Result<()> {
    use g3_core::project::Project;
    use g3_core::retry::{execute_with_retry, RetryConfig, RetryResult};
    use g3_core::feedback_extraction::{extract_coach_feedback, FeedbackExtractionConfig};
    use g3_core::Agent;
    
    let max_turns = planner_config.max_turns;
    
    // Create project with custom requirements path
    let project = Project::new_autonomous_with_requirements(
        planner_config.codepath.clone(),
        requirements_content.to_string(),
    )?;
    
    // Enter the workspace
    project.ensure_workspace_exists()?;
    project.enter_workspace()?;
    
    print_msg(&format!("📁 Working in: {}", planner_config.codepath.display()));
    print_msg(&format!("🔄 Max turns: {}", max_turns));
    
    // Set environment variable for custom todo path
    std::env::set_var("G3_TODO_PATH", planner_config.todo_path().display().to_string());
    
    let mut turn = 1;
    let mut coach_feedback = String::new();
    
    while turn <= max_turns {
        print_msg(&format!("\n=== Turn {}/{} ===", turn, max_turns));
        
        // Player phase - implement requirements
        print_msg("🎯 Player: Implementing requirements...");
        
        let player_config = g3_config.for_player()?;
        let ui_writer = llm::PlannerUiWriter::new();
        let mut player_agent = Agent::new_autonomous_with_readme_and_quiet(
            player_config,
            ui_writer,
            None,
            planner_config.quiet,
        ).await?;
        
        let player_prompt = if coach_feedback.is_empty() || turn == 1 {
            format!(
                "You are G3 in implementation mode. Read and implement the following requirements:\n\n{}\n\nImplement this step by step. Write the todo list to: {}\n\nCreate all necessary files and code.",
                requirements_content,
                planner_config.todo_path().display()
            )
        } else {
            format!(
                "You are G3 in implementation mode. Address the following coach feedback:\n\n{}\n\nOriginal requirements:\n{}\n\nFix the issues mentioned above.",
                coach_feedback,
                requirements_content
            )
        };
        
        // Execute player task with retry logic
        let player_retry_config = RetryConfig::planning("player");
        let player_result = execute_with_retry(
            &mut player_agent,
            &player_prompt,
            &player_retry_config,
            false, // show_prompt
            false, // show_code
            None,  // discovery
            |msg| print_msg(msg),
        ).await;
        
        match player_result {
            RetryResult::Success(result) => {
                print_msg(&format!("✅ Player completed: {} chars response", result.response.len()));
            }
            RetryResult::MaxRetriesReached(err) => {
                print_msg(&format!("⚠️  Player failed after max retries: {}", err));
                // Continue to coach phase anyway to get feedback
            }
            RetryResult::ContextLengthExceeded(err) => {
                print_msg(&format!("⚠️  Player context length exceeded: {}", err));
                // Continue to next turn
                turn += 1;
                continue;
            }
            RetryResult::Panic(e) => {
                print_msg(&format!("💥 Player panic: {}", e));
                return Err(e);
            }
        }
        
        // Coach phase - review implementation
        print_msg("🎓 Coach: Reviewing implementation...");
        
        let coach_config = g3_config.for_coach()?;
        let coach_ui_writer = llm::PlannerUiWriter::new();
        let mut coach_agent = Agent::new_autonomous_with_readme_and_quiet(
            coach_config,
            coach_ui_writer,
            None,
            planner_config.quiet,
        ).await?;
        
        let coach_prompt = format!(
            "You are G3 in coach mode. Review the implementation against these requirements:\n\n{}\n\nCheck:\n1. Are requirements implemented correctly?\n2. Does the code compile?\n3. What's missing?\n\nUse the final_output tool to provide your feedback.\nIf implementation is COMPLETE, include 'IMPLEMENTATION_APPROVED' in your feedback.\nOtherwise, provide specific feedback for the player to fix.",
            requirements_content
        );
        
        // Execute coach task with retry logic
        let coach_retry_config = RetryConfig::planning("coach");
        let coach_result = execute_with_retry(
            &mut coach_agent,
            &coach_prompt,
            &coach_retry_config,
            false, // show_prompt
            false, // show_code
            None,  // discovery
            |msg| print_msg(msg),
        ).await;
        
        match coach_result {
            RetryResult::Success(result) => {
                // Extract feedback using the robust extraction module
                let feedback_config = FeedbackExtractionConfig::default();
                let extracted = extract_coach_feedback(&result, &coach_agent, &feedback_config);
                
                print_msg(&format!("📝 Coach feedback extracted from {:?}: {} chars", 
                    extracted.source, extracted.content.len()));
                
                // Check for approval
                if extracted.is_approved() || result.response.contains("IMPLEMENTATION_APPROVED") {
                    print_msg("✅ Coach approved implementation!");
                    return Ok(());
                }
                
                coach_feedback = extracted.content;
                
                // Display first 25 lines of coach feedback
                let lines: Vec<&str> = coach_feedback.lines().collect();
                for line in lines.iter().take(25) {
                    print_msg(&format!("  {}", line));
                }
                if lines.len() > 25 {
                    print_msg("  ...");
                }
            }
            RetryResult::MaxRetriesReached(err) => {
                print_msg(&format!("⚠️  Coach failed after max retries: {}", err));
                coach_feedback = "Please review and fix any issues.".to_string();
            }
            RetryResult::ContextLengthExceeded(err) => {
                print_msg(&format!("⚠️  Coach context length exceeded: {}", err));
                coach_feedback = "Context window full. Please continue with current progress.".to_string();
            }
            RetryResult::Panic(e) => {
                print_msg(&format!("💥 Coach panic: {}", e));
                return Err(e);
            }
        }
        
        turn += 1;
    }
    
    print_msg(&format!("⏰ Reached max turns ({})", max_turns));
    Ok(())
}

/// Main entry point for planning mode
/// 
/// This function orchestrates the entire planning workflow:
/// 1. Initialize the planning directory
/// 2. Check git status (if enabled)
/// 3. Detect and handle recovery situations
/// 4. Run the refinement and implementation loop
pub async fn run_planning_mode(
    codepath: Option<String>,
    workspace: Option<std::path::PathBuf>,
    no_git: bool,
    config_path: Option<&str>,
) -> anyhow::Result<()> {
    print_msg("\n🎯 G3 Planning Mode");
    print_msg("==================\n");
    
    // Get codepath first (needed for setting workspace path early)
    let codepath = match codepath {
        Some(path) => {
            let expanded = expand_codepath(&path)?;
            print_msg(&format!("📁 Codepath: {}", expanded.display()));
            expanded
        }
        None => {
            let path = prompt_for_codepath()?;
            print_msg(&format!("📁 Codepath: {}", path.display()));
            path
        }
    };
    
    // Verify codepath exists
    if !codepath.exists() {
        anyhow::bail!("Codepath does not exist: {}", codepath.display());
    }
    
    // Determine workspace directory (use workspace arg if provided, else use codepath)
    let workspace_dir = workspace.unwrap_or_else(|| codepath.clone());
    print_msg(&format!("📁 Workspace: {}", workspace_dir.display()));
    
    // Set G3_WORKSPACE_PATH environment variable EARLY for all logging
    std::env::set_var("G3_WORKSPACE_PATH", workspace_dir.display().to_string());
    
    // Create logs directory and verify it exists
    let logs_dir = workspace_dir.join("logs");
    if !logs_dir.exists() {
        fs::create_dir_all(&logs_dir)
            .context("Failed to create logs directory")?;
    }
    print_msg(&format!("📁 Logs directory: {}", logs_dir.display()));
    
    // Create the LLM provider for planning
    print_msg("🔧 Initializing planner provider...");
    let provider = match llm::create_planner_provider(config_path).await {
        Ok(p) => p,
        Err(e) => {
            print_msg(&format!("❌ Failed to initialize provider: {}", e));
            print_msg("Please check your configuration file.");
            anyhow::bail!("Provider initialization failed: {}", e);
        }
    };
    print_msg(&format!("✅ Provider initialized: {}", provider.name()));
    
    
    // Create configuration
    let config = PlannerConfig {
        codepath: codepath.clone(),
        no_git,
        max_turns: 5, // Default, could be made configurable
        quiet: false,
        config_path: config_path.map(|s| s.to_string()),
    };
    
    // Initialize plan directory
    initialize_plan_dir(&config)?;
    
    // Check git status
    check_git_status(&config)?;
    
    // Main planning loop
    let mut state = check_startup_state(&config);
    
    loop {
        state = match state {
            PlannerState::Startup => {
                // Startup state transitions to checking for recovery
                check_startup_state(&config)
            }
            PlannerState::Recovery(info) => {
                handle_recovery(&config, &info)?
            }
            PlannerState::PromptForRequirements => {
                prompt_for_new_requirements(&config)?
            }
            PlannerState::RefineRequirements => {
                // Call LLM for refinement with full tool execution
                print_msg("\n🔄 Refinement phase - calling LLM...");
                
                let codepath_str = config.codepath.display().to_string();
                let workspace_str = workspace_dir.display().to_string();
                
                // Load config and call LLM with full tool execution capability
                let g3_config = g3_config::Config::load(config.config_path.as_deref())?;
                let response = llm::call_refinement_llm_with_tools(
                    &g3_config,
                    &codepath_str,
                    &workspace_str,
                ).await;
                
                match response {
                    Ok(_) => print_msg("✅ LLM refinement complete."),
                    Err(e) => print_msg(&format!("⚠️  LLM refinement error: {}", e)),
                }
                
                if check_current_requirements_tag(&config)? {
                    match prompt_for_approval(&config)? {
                        ApprovalChoice::Approve => PlannerState::ImplementRequirements,
                        ApprovalChoice::Refine => PlannerState::PromptForRequirements,
                        ApprovalChoice::Quit => PlannerState::Quit,
                    }
                } else {
                    print_msg(&format!("❌ {}", "The LLM didn't update the requirements file with {{CURRENT REQUIREMENTS}}. Please restart the app."));
                    PlannerState::Quit
                }
            }
            PlannerState::ImplementRequirements => {
                // Promote requirements and run coach/player
                if config.new_requirements_path().exists() {
                    promote_requirements(&config)?;
                }
                
                // Write git HEAD to history before implementation
                if !config.no_git {
                    let head_sha = git::get_head_sha(&config.codepath)?;
                    history::write_git_head(&config.plan_dir(), &head_sha)?;
                    print_msg(&format!("📝 Recorded git HEAD: {}", &head_sha[..12.min(head_sha.len())]));
                }
                
                // Read requirements and generate summary
                let requirements_content = read_current_requirements(&config)?;
                
                print_msg("📝 Generating requirements summary...");
                let summary = match llm::generate_requirements_summary(
                    provider.as_ref(),
                    &requirements_content,
                ).await {
                    Ok(s) => s,
                    Err(e) => {
                        print_msg(&format!("⚠️  Summary generation failed: {}", e));
                        "Requirements implementation in progress".to_string()
                    }
                };
                
                // Write start implementing entry with summary
                history::write_start_implementing(&config.plan_dir(), &summary)?;
                print_msg("📝 Recorded implementation start in history");
                
                // Run the actual coach/player loop
                print_msg("\n🚀 Starting coach/player implementation loop...");
                
                let g3_config = g3_config::Config::load(config.config_path.as_deref())?;
                let implementation_result = run_coach_player_loop(
                    &config,
                    &g3_config,
                    &requirements_content,
                ).await;
                
                match implementation_result {
                    Ok(_) => print_msg("✅ Coach/player loop completed"),
                    Err(e) => {
                        print_msg(&format!("⚠️  Implementation error: {}", e));
                        print_msg("You can try to resume or mark as complete.");
                    }
                }
                
                PlannerState::ImplementationComplete
            }
            PlannerState::ImplementationComplete => {
                // Check completion and commit
                match prompt_for_completion(&config)? {
                    CompletionChoice::Complete => {
                        let (req_file, todo_file) = complete_implementation(&config)?;

                        // Read requirements for LLM context
                        let requirements_content = if config.plan_dir().join(&req_file).exists() {
                            std::fs::read_to_string(config.plan_dir().join(&req_file))
                                .unwrap_or_else(|_| "Requirements unavailable".to_string())
                        } else {
                            "Requirements unavailable".to_string()
                        };

                        // Generate commit message using LLM
                        print_msg("📝 Generating commit message...");
                        let (summary, description) = match llm::generate_commit_message(
                            provider.as_ref(),
                            &requirements_content,
                            &req_file,
                            &todo_file,
                        ).await {
                            Ok((s, d)) => (s, d),
                            Err(e) => {
                                print_msg(&format!("⚠️  Commit message generation failed: {}", e));
                                ("Implement planning requirements".to_string(),
                                 format!("Requirements: {}\nTodo: {}", req_file, todo_file))
                            }
                        };

                        stage_and_commit(&config, &summary, &description)?;
                        PlannerState::PromptForRequirements
                    }
                    CompletionChoice::Continue => PlannerState::ImplementRequirements,
                    CompletionChoice::Quit => PlannerState::Quit,
                }
            }
            PlannerState::Quit => {
                print_msg("\n👋 Exiting planning mode.");
                break;
            }
        };
    }
    
    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    #[test]
    fn test_expand_codepath_tilde() {
        let result = expand_codepath("~/test/path").unwrap();
        assert!(result.to_string_lossy().contains("test/path"));
        assert!(!result.to_string_lossy().contains('~'));
    }

    #[test]
    fn test_planner_config_paths() {
        let config = PlannerConfig {
            codepath: PathBuf::from("/test/project"),
            no_git: false,
            max_turns: 5,
            quiet: false,
            config_path: None,
        };

        assert_eq!(config.plan_dir(), PathBuf::from("/test/project/g3-plan"));
        assert_eq!(config.new_requirements_path(), PathBuf::from("/test/project/g3-plan/new_requirements.md"));
        assert_eq!(config.current_requirements_path(), PathBuf::from("/test/project/g3-plan/current_requirements.md"));
        assert_eq!(config.todo_path(), PathBuf::from("/test/project/g3-plan/todo.g3.md"));
    }

    #[test]
    fn test_check_todos_complete() {
        assert!(check_todos_complete("- [x] Task 1\n- [x] Task 2"));
        assert!(!check_todos_complete("- [x] Task 1\n- [ ] Task 2"));
        assert!(!check_todos_complete("- [ ] Task 1"));
        assert!(check_todos_complete("No tasks here"));
    }

    #[test]
    fn test_parse_commit_message() {
        let response = r#"Some preamble
{{COMMIT_SUMMARY}}
Add planning mode with state machine
{{COMMIT_DESCRIPTION}}
Implements the planning workflow including:
- Requirements refinement
- Git integration
- History tracking"#;

        let (summary, desc) = parse_commit_message(response);
        assert_eq!(summary, "Add planning mode with state machine");
        assert!(desc.contains("Implements the planning workflow"));
        assert!(desc.contains("Requirements refinement"));
    }

    #[test]
    fn test_parse_commit_message_truncation() {
        let long_summary = "A".repeat(100);
        let response = format!("{{{{COMMIT_SUMMARY}}}}\n{}\n{{{{COMMIT_DESCRIPTION}}}}\nDesc", long_summary);
        
        let (summary, _) = parse_commit_message(&response);
        assert!(summary.len() <= 72);
        assert!(summary.ends_with("..."));
    }

    #[test]
    fn test_ensure_original_requirements_tag() {
        let temp_dir = TempDir::new().unwrap();
        let path = temp_dir.path().join("new_requirements.md");
        
        // Write content without tag
        fs::write(&path, "Some requirements").unwrap();
        
        ensure_original_requirements_tag(&path).unwrap();
        
        let content = fs::read_to_string(&path).unwrap();
        assert!(content.contains("{{ORIGINAL USER REQUIREMENTS -- THIS SECTION WILL BE IGNORED BY THE IMPLEMENTATION}}"));
        assert!(content.contains("Some requirements"));
    }

    #[test]
    fn test_ensure_original_requirements_tag_already_present() {
        let temp_dir = TempDir::new().unwrap();
        let path = temp_dir.path().join("new_requirements.md");
        
        // Write content with tag already
        let content_with_tag = format!("{}\n\nSome requirements", "{{ORIGINAL USER REQUIREMENTS -- THIS SECTION WILL BE IGNORED BY THE IMPLEMENTATION}}");
        fs::write(&path, &content_with_tag).unwrap();
        
        ensure_original_requirements_tag(&path).unwrap();
        
        let content = fs::read_to_string(&path).unwrap();
        // Should not duplicate the tag
        assert_eq!(content.matches("{{ORIGINAL USER REQUIREMENTS -- THIS SECTION WILL BE IGNORED BY THE IMPLEMENTATION}}").count(), 1);
    }

    #[test]
    fn test_initialize_plan_dir() {
        let temp_dir = TempDir::new().unwrap();
        let config = PlannerConfig {
            codepath: temp_dir.path().to_path_buf(),
            no_git: true,
            max_turns: 5,
            quiet: false,
            config_path: None,
        };

        initialize_plan_dir(&config).unwrap();

        assert!(config.plan_dir().exists());
        assert!(config.history_path().exists());
    }
}
