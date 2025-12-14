//! Flock mode implementation - parallel multi-agent development

use anyhow::{Context, Result};
use chrono::Utc;
use g3_config::Config;
use std::path::{Path, PathBuf};
use std::process::Stdio;
use tokio::io::{AsyncBufReadExt, BufReader};
use tokio::process::Command;
use tracing::{debug, error, info, warn};
use uuid::Uuid;

use crate::status::{FlockStatus, SegmentState, SegmentStatus};

/// Configuration for flock mode
#[derive(Debug, Clone)]
pub struct FlockConfig {
    /// Project directory (must be a git repo with flock-requirements.md)
    pub project_dir: PathBuf,

    /// Flock workspace directory where segments will be created
    pub flock_workspace: PathBuf,

    /// Number of segments to partition work into
    pub num_segments: usize,

    /// Maximum turns per segment (for autonomous mode)
    pub max_turns: usize,

    /// G3 configuration to use for agents
    pub g3_config: Config,

    /// Path to g3 binary (defaults to current executable)
    pub g3_binary: Option<PathBuf>,
}

impl FlockConfig {
    /// Create a new flock configuration
    pub fn new(
        project_dir: PathBuf,
        flock_workspace: PathBuf,
        num_segments: usize,
    ) -> Result<Self> {
        // Validate project directory
        if !project_dir.exists() {
            anyhow::bail!(
                "Project directory does not exist: {}",
                project_dir.display()
            );
        }

        // Check if it's a git repo
        if !project_dir.join(".git").exists() {
            anyhow::bail!(
                "Project directory must be a git repository: {}",
                project_dir.display()
            );
        }

        // Check for flock-requirements.md
        let requirements_path = project_dir.join("flock-requirements.md");
        if !requirements_path.exists() {
            anyhow::bail!(
                "Project directory must contain flock-requirements.md: {}",
                project_dir.display()
            );
        }

        // Load default config
        let g3_config = Config::load(None).or_else(|_| {
            // If no config file exists, return an error with helpful message
            anyhow::bail!("No G3 configuration found. Please create a .g3.toml file.")
        })?;

        Ok(Self {
            project_dir,
            flock_workspace,
            num_segments,
            max_turns: 5, // Default
            g3_config,
            g3_binary: None,
        })
    }

    /// Create a new flock configuration with a specified config path
    pub fn new_with_config(
        project_dir: PathBuf,
        flock_workspace: PathBuf,
        num_segments: usize,
        config_path: Option<&str>,
    ) -> Result<Self> {
        // Validate project directory
        if !project_dir.exists() {
            anyhow::bail!(
                "Project directory does not exist: {}",
                project_dir.display()
            );
        }

        // Check if it's a git repo
        if !project_dir.join(".git").exists() {
            anyhow::bail!(
                "Project directory must be a git repository: {}",
                project_dir.display()
            );
        }

        // Check for flock-requirements.md
        let requirements_path = project_dir.join("flock-requirements.md");
        if !requirements_path.exists() {
            anyhow::bail!(
                "Project directory must contain flock-requirements.md: {}",
                project_dir.display()
            );
        }

        // Load config from specified path
        let g3_config = Config::load(config_path)?;

        Ok(Self {
            project_dir,
            flock_workspace,
            num_segments,
            max_turns: 5, // Default
            g3_config,
            g3_binary: None,
        })
    }

    /// Set maximum turns per segment
    pub fn with_max_turns(mut self, max_turns: usize) -> Self {
        self.max_turns = max_turns;
        self
    }

    /// Set custom g3 binary path
    pub fn with_g3_binary(mut self, binary: PathBuf) -> Self {
        self.g3_binary = Some(binary);
        self
    }

    /// Set custom g3 config
    pub fn with_config(mut self, config: Config) -> Self {
        self.g3_config = config;
        self
    }
}

/// Flock mode orchestrator
pub struct FlockMode {
    config: FlockConfig,
    status: FlockStatus,
    session_id: String,
}

impl FlockMode {
    /// Create a new flock mode instance
    pub fn new(config: FlockConfig) -> Result<Self> {
        let session_id = Uuid::new_v4().to_string();

        let status = FlockStatus::new(
            session_id.clone(),
            config.project_dir.clone(),
            config.flock_workspace.clone(),
            config.num_segments,
        );

        Ok(Self {
            config,
            status,
            session_id,
        })
    }

    /// Run flock mode
    pub async fn run(&mut self) -> Result<()> {
        info!(
            "Starting flock mode with {} segments",
            self.config.num_segments
        );

        // Step 1: Partition requirements
        println!(
            "\n🧠 Step 1: Partitioning requirements into {} segments...",
            self.config.num_segments
        );
        let partitions = self.partition_requirements().await?;

        // Step 2: Create segment workspaces
        println!("\n📁 Step 2: Creating segment workspaces...");
        self.create_segment_workspaces(&partitions).await?;

        // Step 3: Run segments in parallel
        println!(
            "\n🚀 Step 3: Running {} segments in parallel...",
            self.config.num_segments
        );
        self.run_segments_parallel().await?;

        // Step 4: Generate final report
        println!("\n📊 Step 4: Generating final report...");
        self.status.completed_at = Some(Utc::now());
        self.save_status()?;

        let report = self.status.generate_report();
        println!("{}", report);

        Ok(())
    }

    /// Partition requirements using an AI agent
    async fn partition_requirements(&mut self) -> Result<Vec<String>> {
        let requirements_path = self.config.project_dir.join("flock-requirements.md");
        let requirements_content = std::fs::read_to_string(&requirements_path)
            .context("Failed to read flock-requirements.md")?;

        // Create a temporary workspace for the partitioning agent
        let partition_workspace = self.config.flock_workspace.join("_partition");
        std::fs::create_dir_all(&partition_workspace)?;

        // Create the partitioning prompt
        let partition_prompt = format!(
            "You are a software architect tasked with partitioning project requirements into {} logical, \
            largely non-overlapping modules that can grow into separate architectural components \
            (e.g., crates, services, or packages).\n\n\
            REQUIREMENTS:\n{}\n\n\
            INSTRUCTIONS:\n\
            1. Analyze the requirements carefully\n\
            2. Identify {} distinct architectural modules that:\n\
               - Have minimal overlap and dependencies\n\
               - Can be developed largely independently\n\
               - Represent logical architectural boundaries\n\
               - Could eventually become separate crates or services\n\
            3. For each module, provide:\n\
               - A clear module name\n\
               - The specific requirements that belong to this module\n\
               - Any dependencies on other modules\n\n\
            4. Return your final partitioning exactly once, prefixed by the marker '{{PARTITION JSON}}' followed by a fenced code block that starts with \"```json\" and ends with \"```\". Place only the JSON array inside the fence.\n\
            5. Use the final_output tool to provide your partitioning as a JSON array of objects, where each object has:\n\
               - \"module_name\": string\n\
               - \"requirements\": string (the requirements text for this module)\n\
               - \"dependencies\": array of strings (names of other modules this depends on)\n\n\
            Example format:\n\
            {{{{PARTITION JSON}}}}\n\
            ```json\n\
            [\n\
              {{\n\
                \"module_name\": \"core-engine\",\n\
                \"requirements\": \"Implement the core processing engine...\",\n\
                \"dependencies\": []\n\
              }},\n\
              {{\n\
                \"module_name\": \"api-server\",\n\
                \"requirements\": \"Create REST API endpoints...\",\n\
                \"dependencies\": [\"core-engine\"]\n\
              }}\n\
            ]\n\
            ```\n\n\
            Be thoughtful and strategic in your partitioning. The goal is to enable parallel development.",
            self.config.num_segments,
            requirements_content,
            self.config.num_segments
        );

        // Get g3 binary path
        let g3_binary = self.get_g3_binary()?;

        // Run g3 in single-shot mode to partition requirements
        println!("   Analyzing requirements and creating partitions...");
        let output = Command::new(&g3_binary)
            .arg("--workspace")
            .arg(&partition_workspace)
            .arg("--quiet") // Disable logging for partitioning agent
            .arg(&partition_prompt)
            .output()
            .await
            .context("Failed to run g3 for partitioning")?;

        if !output.status.success() {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!("Partitioning agent failed: {}", stderr);
        }

        let stdout = String::from_utf8_lossy(&output.stdout);
        debug!("Partitioning agent output: {}", stdout);

        // Extract JSON from the output
        let partitions_json = Self::extract_json_from_output(&stdout)
            .context("Failed to extract partition JSON from agent output")?;

        // Parse the partitions
        let partitions: Vec<serde_json::Value> =
            serde_json::from_str(&partitions_json).context("Failed to parse partition JSON")?;

        if partitions.len() != self.config.num_segments {
            warn!(
                "Expected {} partitions but got {}. Adjusting...",
                self.config.num_segments,
                partitions.len()
            );
        }

        // Extract requirements text from each partition
        let mut partition_texts = Vec::new();
        for (i, partition) in partitions.iter().enumerate() {
            let default_name = format!("module-{}", i + 1);
            let module_name = partition["module_name"].as_str().unwrap_or(&default_name);
            let requirements = partition["requirements"]
                .as_str()
                .context("Missing requirements field in partition")?;
            let dependencies = partition["dependencies"]
                .as_array()
                .map(|arr| {
                    arr.iter()
                        .filter_map(|v| v.as_str())
                        .collect::<Vec<_>>()
                        .join(", ")
                })
                .unwrap_or_default();

            let partition_text = format!(
                "# Module: {}\n\n## Dependencies\n{}\n\n## Requirements\n\n{}",
                module_name,
                if dependencies.is_empty() {
                    "None".to_string()
                } else {
                    dependencies
                },
                requirements
            );

            partition_texts.push(partition_text);
            println!("   ✓ Created partition {}: {}", i + 1, module_name);
        }

        Ok(partition_texts)
    }

    /// Extract JSON from agent output (looks for JSON array in output)
    fn extract_json_from_output(output: &str) -> Result<String> {
        // Try to find all occurrences of partition markers and extract valid JSON
        const MARKERS: &[&str] = &["{{PARTITION JSON}}", "{PARTITION JSON}"];

        let mut candidates = Vec::new();

        // Find all marker occurrences
        for &marker in MARKERS {
            let mut search_start = 0;
            while let Some(marker_index) = output[search_start..].find(marker) {
                let absolute_index = search_start + marker_index;
                let after_marker = &output[absolute_index + marker.len()..];

                // Try to find a code fence after this marker
                if let Some(fence_start) = after_marker.find("```") {
                    let after_fence = &after_marker[fence_start + 3..];

                    // Skip optional "json" language identifier
                    let content_start = after_fence
                        .strip_prefix("json")
                        .unwrap_or(after_fence)
                        .trim_start_matches(|c: char| c.is_whitespace());

                    // Find closing fence
                    if let Some(fence_end) = content_start.find("```") {
                        let json_candidate = content_start[..fence_end].trim();
                        candidates.push(json_candidate.to_string());
                    }
                }

                // Move search position forward
                search_start = absolute_index + marker.len();
            }
        }

        if candidates.is_empty() {
            anyhow::bail!(
                "Could not find any partition JSON markers with code fences in agent output"
            );
        }

        // Try to parse each candidate and return the first valid JSON
        let mut last_error = None;
        for (i, candidate) in candidates.iter().enumerate() {
            match serde_json::from_str::<serde_json::Value>(candidate) {
                Ok(_) => {
                    debug!(
                        "Successfully parsed JSON from candidate {} of {}",
                        i + 1,
                        candidates.len()
                    );
                    return Ok(candidate.clone());
                }
                Err(e) => {
                    debug!(
                        "Failed to parse candidate {} of {}: {}",
                        i + 1,
                        candidates.len(),
                        e
                    );
                    last_error = Some(e);
                }
            }
        }

        // If we get here, none of the candidates were valid JSON
        if let Some(err) = last_error {
            anyhow::bail!(
                "Found {} JSON candidate(s) but none were valid JSON. Last error: {}",
                candidates.len(),
                err
            );
        }

        anyhow::bail!("No valid JSON found in output")
    }

    /// Create segment workspaces by copying project directory
    async fn create_segment_workspaces(&mut self, partitions: &[String]) -> Result<()> {
        // Ensure flock workspace exists
        std::fs::create_dir_all(&self.config.flock_workspace)?;

        for (i, partition) in partitions.iter().enumerate() {
            let segment_id = i + 1;
            let segment_dir = self
                .config
                .flock_workspace
                .join(format!("segment-{}", segment_id));

            println!("   Creating segment {} workspace...", segment_id);

            // Copy project directory to segment directory
            self.copy_git_repo(&self.config.project_dir, &segment_dir)
                .await
                .context(format!("Failed to copy project to segment {}", segment_id))?;

            // Write segment-requirements.md
            let requirements_path = segment_dir.join("segment-requirements.md");
            std::fs::write(&requirements_path, partition).context(format!(
                "Failed to write requirements for segment {}",
                segment_id
            ))?;

            println!(
                "   ✓ Segment {} workspace ready at {}",
                segment_id,
                segment_dir.display()
            );
        }

        Ok(())
    }

    /// Copy a git repository to a new location
    async fn copy_git_repo(&self, source: &Path, dest: &Path) -> Result<()> {
        // Use git clone for efficient copying
        let output = Command::new("git")
            .arg("clone")
            .arg(source)
            .arg(dest)
            .output()
            .await
            .context("Failed to run git clone")?;

        if !output.status.success() {
            let stderr = String::from_utf8_lossy(&output.stderr);
            anyhow::bail!("Git clone failed: {}", stderr);
        }

        Ok(())
    }

    /// Run all segments in parallel
    async fn run_segments_parallel(&mut self) -> Result<()> {
        let mut handles = Vec::new();

        for segment_id in 1..=self.config.num_segments {
            let segment_dir = self
                .config
                .flock_workspace
                .join(format!("segment-{}", segment_id));
            let max_turns = self.config.max_turns;
            let g3_binary = self.get_g3_binary()?;
            let status_file = self.get_status_file_path();
            let session_id = self.session_id.clone();

            // Initialize segment status
            let segment_status = SegmentStatus {
                segment_id,
                workspace: segment_dir.clone(),
                state: SegmentState::Running,
                started_at: Utc::now(),
                completed_at: None,
                tokens_used: 0,
                tool_calls: 0,
                errors: 0,
                current_turn: 0,
                max_turns,
                last_message: Some("Starting...".to_string()),
                error_message: None,
            };

            self.status.update_segment(segment_id, segment_status);
            self.save_status()?;

            // Spawn a task for this segment
            let handle = tokio::spawn(async move {
                run_segment(
                    segment_id,
                    segment_dir,
                    max_turns,
                    g3_binary,
                    status_file,
                    session_id,
                )
                .await
            });

            handles.push((segment_id, handle));
        }

        // Wait for all segments to complete
        for (segment_id, handle) in handles {
            match handle.await {
                Ok(Ok(final_status)) => {
                    println!("\n✅ Segment {} completed", segment_id);
                    self.status.update_segment(segment_id, final_status);
                    self.save_status()?;
                }
                Ok(Err(e)) => {
                    error!("Segment {} failed: {}", segment_id, e);
                    let mut segment_status = self
                        .status
                        .segments
                        .get(&segment_id)
                        .cloned()
                        .unwrap_or_else(|| SegmentStatus {
                            segment_id,
                            workspace: self
                                .config
                                .flock_workspace
                                .join(format!("segment-{}", segment_id)),
                            state: SegmentState::Failed,
                            started_at: Utc::now(),
                            completed_at: Some(Utc::now()),
                            tokens_used: 0,
                            tool_calls: 0,
                            errors: 1,
                            current_turn: 0,
                            max_turns: self.config.max_turns,
                            last_message: None,
                            error_message: Some(e.to_string()),
                        });
                    segment_status.state = SegmentState::Failed;
                    segment_status.completed_at = Some(Utc::now());
                    segment_status.error_message = Some(e.to_string());
                    segment_status.errors += 1;
                    self.status.update_segment(segment_id, segment_status);
                    self.save_status()?;
                }
                Err(e) => {
                    error!("Segment {} task panicked: {}", segment_id, e);
                    let mut segment_status = self
                        .status
                        .segments
                        .get(&segment_id)
                        .cloned()
                        .unwrap_or_else(|| SegmentStatus {
                            segment_id,
                            workspace: self
                                .config
                                .flock_workspace
                                .join(format!("segment-{}", segment_id)),
                            state: SegmentState::Failed,
                            started_at: Utc::now(),
                            completed_at: Some(Utc::now()),
                            tokens_used: 0,
                            tool_calls: 0,
                            errors: 1,
                            current_turn: 0,
                            max_turns: self.config.max_turns,
                            last_message: None,
                            error_message: Some(format!("Task panicked: {}", e)),
                        });
                    segment_status.state = SegmentState::Failed;
                    segment_status.completed_at = Some(Utc::now());
                    segment_status.error_message = Some(format!("Task panicked: {}", e));
                    segment_status.errors += 1;
                    self.status.update_segment(segment_id, segment_status);
                    self.save_status()?;
                }
            }
        }

        Ok(())
    }

    /// Get the g3 binary path
    fn get_g3_binary(&self) -> Result<PathBuf> {
        if let Some(ref binary) = self.config.g3_binary {
            Ok(binary.clone())
        } else {
            // Use current executable
            std::env::current_exe().context("Failed to get current executable path")
        }
    }

    /// Get the status file path
    fn get_status_file_path(&self) -> PathBuf {
        self.config.flock_workspace.join("flock-status.json")
    }

    /// Save current status to file
    fn save_status(&self) -> Result<()> {
        let status_file = self.get_status_file_path();
        self.status.save_to_file(&status_file)
    }
}

/// Run a single segment worker
async fn run_segment(
    segment_id: usize,
    segment_dir: PathBuf,
    max_turns: usize,
    g3_binary: PathBuf,
    status_file: PathBuf,
    session_id: String,
) -> Result<SegmentStatus> {
    info!(
        "Starting segment {} in {}",
        segment_id,
        segment_dir.display()
    );

    let mut segment_status = SegmentStatus {
        segment_id,
        workspace: segment_dir.clone(),
        state: SegmentState::Running,
        started_at: Utc::now(),
        completed_at: None,
        tokens_used: 0,
        tool_calls: 0,
        errors: 0,
        current_turn: 0,
        max_turns,
        last_message: Some("Starting autonomous mode...".to_string()),
        error_message: None,
    };

    // Run g3 in autonomous mode with segment-requirements.md
    let mut child = Command::new(&g3_binary)
        .arg("--workspace")
        .arg(&segment_dir)
        .arg("--autonomous")
        .arg("--max-turns")
        .arg(max_turns.to_string())
        .arg("--requirements")
        .arg(std::fs::read_to_string(
            segment_dir.join("segment-requirements.md"),
        )?)
        .arg("--quiet") // Disable session logging for workers
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .context("Failed to spawn g3 process")?;

    // Stream output and update status
    let stdout = child.stdout.take().context("Failed to get stdout")?;
    let stderr = child.stderr.take().context("Failed to get stderr")?;

    let stdout_reader = BufReader::new(stdout);
    let stderr_reader = BufReader::new(stderr);

    let mut stdout_lines = stdout_reader.lines();
    let mut stderr_lines = stderr_reader.lines();

    // Read output and update status
    loop {
        tokio::select! {
            line = stdout_lines.next_line() => {
                match line {
                    Ok(Some(line)) => {
                        println!("[Segment {}] {}", segment_id, line);

                        // Parse output for status updates
                        if line.contains("TURN") {
                            // Extract turn number if possible
                            if let Some(turn_str) = line.split("TURN").nth(1) {
                                if let Ok(turn) = turn_str.trim().split('/').next().unwrap_or("0").parse::<usize>() {
                                    segment_status.current_turn = turn;
                                }
                            }
                        }

                        segment_status.last_message = Some(line);
                        update_status_file(&status_file, &session_id, segment_status.clone())?;
                    }
                    Ok(None) => break,
                    Err(e) => {
                        error!("Error reading stdout for segment {}: {}", segment_id, e);
                        break;
                    }
                }
            }
            line = stderr_lines.next_line() => {
                match line {
                    Ok(Some(line)) => {
                        eprintln!("[Segment {} ERROR] {}", segment_id, line);
                        segment_status.errors += 1;
                        update_status_file(&status_file, &session_id, segment_status.clone())?;
                    }
                    Ok(None) => break,
                    Err(e) => {
                        error!("Error reading stderr for segment {}: {}", segment_id, e);
                        break;
                    }
                }
            }
        }
    }

    // Wait for process to complete
    let status = child
        .wait()
        .await
        .context("Failed to wait for g3 process")?;

    segment_status.completed_at = Some(Utc::now());

    if status.success() {
        segment_status.state = SegmentState::Completed;
        segment_status.last_message = Some("Completed successfully".to_string());
    } else {
        segment_status.state = SegmentState::Failed;
        segment_status.error_message = Some(format!("Process exited with status: {}", status));
        segment_status.errors += 1;
    }

    // Try to extract metrics from session log if available
    let log_dir = segment_dir.join("logs");
    if log_dir.exists() {
        if let Ok(entries) = std::fs::read_dir(&log_dir) {
            for entry in entries.flatten() {
                let path = entry.path();
                if path.extension().and_then(|s| s.to_str()) == Some("json") {
                    if let Ok(log_content) = std::fs::read_to_string(&path) {
                        if let Ok(log_json) =
                            serde_json::from_str::<serde_json::Value>(&log_content)
                        {
                            // Extract token usage
                            if let Some(context) = log_json.get("context_window") {
                                if let Some(cumulative) = context.get("cumulative_tokens") {
                                    if let Some(tokens) = cumulative.as_u64() {
                                        segment_status.tokens_used = tokens;
                                    }
                                }
                            }

                            // Count tool calls from conversation history
                            if let Some(context) = log_json.get("context_window") {
                                if let Some(history) = context.get("conversation_history") {
                                    if let Some(messages) = history.as_array() {
                                        let tool_call_count = messages
                                            .iter()
                                            .filter(|msg| {
                                                msg.get("role").and_then(|r| r.as_str())
                                                    == Some("tool")
                                            })
                                            .count();
                                        segment_status.tool_calls = tool_call_count as u64;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    update_status_file(&status_file, &session_id, segment_status.clone())?;

    Ok(segment_status)
}

/// Update the status file with new segment status
fn update_status_file(
    status_file: &PathBuf,
    session_id: &str,
    segment_status: SegmentStatus,
) -> Result<()> {
    // Load existing status or create new one
    let mut flock_status = if status_file.exists() {
        FlockStatus::load_from_file(status_file)?
    } else {
        // This shouldn't happen, but handle it gracefully
        FlockStatus::new(session_id.to_string(), PathBuf::new(), PathBuf::new(), 0)
    };

    flock_status.update_segment(segment_status.segment_id, segment_status);
    flock_status.save_to_file(status_file)?;

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::FlockMode;

    #[test]
    fn extract_json_from_output_handles_partition_marker_and_fences() {
        const NOISY_PREFIX: &str = concat!(
            "\u{001b}[2m\n",
            "\u{001b}[1A\u{001b}[2K│ \u{001b}[2m# Requirements Partitioning into 2 Architectural Modules\u{001b}[0m\n",
            "\u{001b}[1A\u{001b}[2K│ \u{001b}[2m\u{001b}[0m\n",
            "\u{001b}[1A\u{001b}[2K│ \u{001b}[2m## Analysis\u{001b}[0m\n",
            "\u{001b}[1A\u{001b}[2K│ \u{001b}[2m\u{001b}[0m\n",
            "\u{001b}[1A\u{001b}[2K│ \u{001b}[2m```json\u{001b}[0m\n",
            "\u{001b}[1A\u{001b}[2K│ \u{001b}[2m[\u{001b}[0m\n",
            "\u{001b}[1A\u{001b}[2K│ \u{001b}[2m  {\u{001b}[0m\n",
            "\u{001b}[1A\u{001b}[2K│ \u{001b}[2m  }\u{001b}[0m\n",
            "\u{001b}[1A\u{001b}[2K│ \u{001b}[2m]\u{001b}[0m\n",
            "\u{001b}[1A\u{001b}[2K│ \u{001b}[2m```\u{001b}[0m\n",
            "\n",
            "# Requirements Partitioning into 2 Architectural Modules\n",
            "\n",
            "## Analysis\n",
            "\n",
            "The requirements have been partitioned into two logical, largely non-overlapping modules based on architectural concerns:\n",
            "\n",
            "1. **Message Protocol Module** - Handles message identity, formatting, and LLM communication\n",
            "2. **Observability Module** - Handles logging, summarization, and monitoring of message history\n",
            "\n",
            "## Module Partitioning\n",
            "\n"
        );

        let expected_json = r#"[
  {
    "module_name": "message-protocol",
    "requirements": "For all messages sent in the message history, unique ID that is not longer than six characters they need to be alphanumeric and can be case sensitive. Double check the message format specification for Open AI message formats. Write tests to make sure the LLM works, so make sure it's an integration test.",
    "dependencies": []
  },
  {
    "module_name": "observability",
    "requirements": "Add functionality that will summarise the entire message history every time it is sent to LLM. Put it in the logs directory the same as the workspace logs for message history. Call it \"context_window_<suffix>\" where the suffix is the same name as will be used for logging the message history, for example \"g3_session_you_are_g3_in_coach_f79be2a46ac40c35.json\". Look at the code that generates that file name in G3 and use the same code. This file name changes every time and new agent is created, so follow the same pattern with the context window summary. Whenever the file name changes, update a symlink called \"current_context_window\" to that new file. Every time the message history is sent to the LLM, rewrite the entire file. Each message should only take up one line. The format is: date&time, estimated number of tokens of the entire message (use the token estimator code in G3, write it in a compact way for example 1K, 2M, 100b, 200K, colour code it graded from bright green to dark red where 200b is bright green and 50K is dark red), message ID, role (e.g. \"user\", \"assistant\"), the first hundred characters of \"content\".",
    "dependencies": ["message-protocol"]
  }
]"#;

        let mut output = String::from(NOISY_PREFIX);
        output.push_str("{{PARTITION JSON}}\n```json\n");
        output.push_str(expected_json);
        output.push_str("```");

        let extracted = FlockMode::extract_json_from_output(&output)
            .expect("should extract JSON between markers");

        assert_eq!(extracted, expected_json);
    }

    #[test]
    fn extract_json_from_output_handles_multiple_markers_and_invalid_json() {
        // This is the actual output from the LLM that was failing
        let output = r#"[2m[0m
[1A[2K│ [2m# Requirements Partitioning into 2 Architectural Modules[0m
[1A[2K│ [2m[0m
[1A[2K│ [2m## Analysis[0m
[1A[2K│ [2m[0m
[1A[2K│ [2mThe requirements have been partitioned into two logical, largely non-overlapping modules based on architectural concerns:[0m
[1A[2K│ [2m[0m
[1A[2K│ [2m1. **Message Protocol Module** - Handles message identity, formatting, and LLM communication[0m
[1A[2K│ [2m2. **Observability Module** - Handles logging, summarization, and monitoring of message history[0m
[1A[2K│ [2m[0m
[1A[2K│ [2m## Module Partitioning[0m
[1A[2K│ [2m[0m{PARTITION JSON}
[1A[2K│ [2m```json[0m
[1A[2K│ [2m[[0m
[1A[2K│ [2m  {[0m
[1A[2K│ [2m    "module_name": "message-protocol",[0m
[1A[2K│ [2m    "requirements": "For all messages sent in the message history, unique ID that is not longer than six characters they need to be alphanumeric and can be case sensitive. Double check the message format specification for Open AI message formats. Write tests to make sure the LLM works, so make sure it's an integration test.",[0m
[1A[2K│ [2m    "dependencies": [][0m
[1A[2K│ [2m  },[0m
[1A[2K│ [2m  {[0m
[1A[2K│ [2m    "module_name": "observability",[0m
[1A[2K│ [2m    "requirements": "Add functionality that will summarise the entire message history every time it is sent to LLM. Put it in the logs directory the same as the workspace logs for message history. Call it \"context_window_<suffix>\" where the suffix is the same name as will be used for logging the message history, for example \"g3_session_you_are_g3_in_coach_f79be2a46ac40c35.json\". Look at the code that generates that file name in G3 and use the same code. This file name changes every time and new agent is created, so follow the same pattern with the context window summary. Whenever the file name changes, update a symlink called \"current_context_window\" to that new file. Every time the message history is sent to the LLM, rewrite the entire file. Each message should only take up one line. The format is: date&time, estimated number of tokens of the entire message (use the token estimator code in G3, write it in a compact way for example 1K, 2M, 100b, 200K, colour code it graded from bright green to dark red where 200b is bright green and 50K is dark red), message ID, role (e.g. \"user\", \"assistant\"), the first hundred characters of \"content\".",[0m
[1A[2K│ [2m    "dependencies": ["message-protocol"][0m
[1A[2K│ [2m  }[0m
[1A[2K│ [2m][0m
[1A[2K│ [2m```[0m
[1A[2K│ [2m[0m
[1A[2K│ [2m## Rationale[0m
[1A[2K│ [2m[0m
[1A[2K│ [2m### Module 1: message-protocol[0m
[1A[2K│ [2m**Purpose**: Core messaging infrastructure and LLM communication layer[0m
[1A[2K│ [2m[0m
[1A[2K│ [2m**Responsibilities**:[0m
[1A[2K│ [2m- Generate unique 6-character alphanumeric message IDs[0m
[1A[2K│ [2m- Ensure OpenAI message format compliance[0m
[1A[2K│ [2m- Handle LLM request/response cycles[0m
[1A[2K│ [2m- Integration testing of LLM functionality[0m
[1A[2K│ [2m[0m
[1A[2K│ [2m**Why it's independent**: This module defines the fundamental message structure and communication protocol. It can be developed and tested independently as a core library.[0m
[1A[2K│ [2m[0m
[1A[2K│ [2m**Future evolution**: Could become a separate crate (e.g., `g3-message-protocol`) or even a standalone service if message routing becomes complex.[0m
[1A[2K│ [2m[0m
[1A[2K│ [2m### Module 2: observability[0m
[1A[2K│ [2m**Purpose**: Monitoring, logging, and visualization of system activity[0m
[1A[2K│ [2m[0m
[1A[2K│ [2m**Responsibilities**:[0m
[1A[2K│ [2m- Summarize message history on each LLM interaction[0m
[1A[2K│ [2m- Generate context window summary files with specific naming conventions[0m
[1A[2K│ [2m- Manage symlinks to current summary files[0m
[1A[2K│ [2m- Format one-line summaries with timestamps, token counts, message IDs, roles, and content previews[0m
[1A[2K│ [2m- Color-code token estimates for visual monitoring[0m
[1A[2K│ [2m- Integrate with existing G3 logging infrastructure[0m
[1A[2K│ [2m[0m
[1A[2K│ [2m**Why it depends on message-protocol**: Needs access to message IDs, message content, and token estimation utilities. However, the core messaging system doesn't need to know about observability.[0m
[1A[2K│ [2m[0m
[1A[2K│ [2m**Future evolution**: Could become a separate crate (e.g., `g3-observability`) or monitoring service that subscribes to message events.[0m
[1A[2K│ [2m[0m
[1A[2K│ [2m## Benefits of This Partitioning[0m
[1A[2K│ [2m[0m
[1A[2K│ [2m1. **Separation of Concerns**: Core messaging logic is isolated from monitoring/logging concerns[0m
[1A[2K│ [2m2. **Parallel Development**: Teams can work independently on message protocol vs. observability features[0m
[1A[2K│ [2m3. **Testability**: Each module can be tested in isolation[0m
[1A[2K│ [2m4. **Maintainability**: Changes to logging/monitoring don't affect core message handling[0m
[1A[2K│ [2m5. **Scalability**: Observability could be extracted to a separate service for distributed systems[0m
[1A[2K│ [2m6. **Dependency Direction**: Clean one-way dependency (observability → message-protocol) prevents circular dependencies[0m



# Requirements Partitioning into 2 Architectural Modules

## Analysis

The requirements have been partitioned into two logical, largely non-overlapping modules based on architectural concerns:

1. **Message Protocol Module** - Handles message identity, formatting, and LLM communication
2. **Observability Module** - Handles logging, summarization, and monitoring of message history

## Module Partitioning

{{PARTITION JSON}}
```json
[
  {
    "module_name": "message-protocol",
    "requirements": "For all messages sent in the message history, unique ID that is not longer than six characters they need to be alphanumeric and can be case sensitive. Double check the message format specification for Open AI message formats. Write tests to make sure the LLM works, so make sure it's an integration test.",
    "dependencies": []
  },
  {
    "module_name": "observability",
    "requirements": "Add functionality that will summarise the entire message history every time it is sent to LLM. Put it in the logs directory the same as the workspace logs for message history. Call it \"context_window_<suffix>\" where the suffix is the same name as will be used for logging the message history, for example \"g3_session_you_are_g3_in_coach_f79be2a46ac40c35.json\". Look at the code that generates that file name in G3 and use the same code. This file name changes every time and new agent is created, so follow the same pattern with the context window summary. Whenever the file name changes, update a symlink called \"current_context_window\" to that new file. Every time the message history is sent to the LLM, rewrite the entire file. Each message should only take up one line. The format is: date&time, estimated number of tokens of the entire message (use the token estimator code in G3, write it in a compact way for example 1K, 2M, 100b, 200K, colour code it graded from bright green to dark red where 200b is bright green and 50K is dark red), message ID, role (e.g. \"user\", \"assistant\"), the first hundred characters of \"content\".",
    "dependencies": ["message-protocol"]
  }
]
```

## Rationale

### Module 1: message-protocol
**Purpose**: Core messaging infrastructure and LLM communication layer

**Responsibilities**:
- Generate unique 6-character alphanumeric message IDs
- Ensure OpenAI message format compliance
- Handle LLM request/response cycles
- Integration testing of LLM functionality

**Why it's independent**: This module defines the fundamental message structure and communication protocol. It can be developed and tested independently as a core library.

**Future evolution**: Could become a separate crate (e.g., `g3-message-protocol`) or even a standalone service if message routing becomes complex.

### Module 2: observability
**Purpose**: Monitoring, logging, and visualization of system activity

**Responsibilities**:
- Summarize message history on each LLM interaction
- Generate context window summary files with specific naming conventions
- Manage symlinks to current summary files
- Format one-line summaries with timestamps, token counts, message IDs, roles, and content previews
- Color-code token estimates for visual monitoring
- Integrate with existing G3 logging infrastructure

**Why it depends on message-protocol**: Needs access to message IDs, message content, and token estimation utilities. However, the core messaging system doesn't need to know about observability.

**Future evolution**: Could become a separate crate (e.g., `g3-observability`) or monitoring service that subscribes to message events.

## Benefits of This Partitioning

1. **Separation of Concerns**: Core messaging logic is isolated from monitoring/logging concerns
2. **Parallel Development**: Teams can work independently on message protocol vs. observability features
3. **Testability**: Each module can be tested in isolation
4. **Maintainability**: Changes to logging/monitoring don't affect core message handling
5. **Scalability**: Observability could be extracted to a separate service for distributed systems
6. **Dependency Direction**: Clean one-way dependency (observability → message-protocol) prevents circular dependencies"#;

        let extracted = FlockMode::extract_json_from_output(output)
            .expect("should extract valid JSON from output with multiple markers");

        // Should be able to parse as JSON
        let parsed: serde_json::Value =
            serde_json::from_str(&extracted).expect("extracted content should be valid JSON");

        // Verify it's an array with 2 elements
        assert!(parsed.is_array());
        let arr = parsed.as_array().unwrap();
        assert_eq!(arr.len(), 2);

        // Verify the structure
        assert_eq!(arr[0]["module_name"], "message-protocol");
        assert_eq!(arr[1]["module_name"], "observability");
    }
}
