//! g3-planner: Planning mode and fast-discovery planner for G3 AI coding agent
//!
//! This crate provides:
//! - Planning mode state machine and orchestration
//! - Requirements refinement workflow
//! - Git integration for planning commits
//! - Planner history management
//! - Fast-discovery functionality for codebase exploration

mod code_explore;
pub mod git;
pub mod history;
pub mod llm;
pub mod planner;
pub mod prompts;
pub mod state;

pub use code_explore::explore_codebase;
pub use planner::{expand_codepath, PlannerConfig, PlannerResult};
pub use state::{PlannerState, RecoveryInfo};
pub use planner::run_planning_mode;

use anyhow::Result;
use chrono::Local;
use g3_providers::{CompletionRequest, LLMProvider, Message, MessageRole};
use prompts::{DISCOVERY_REQUIREMENTS_PROMPT, DISCOVERY_SYSTEM_PROMPT};
use std::fs::{self, OpenOptions};
use std::io::Write;

/// Type alias for a status callback function
pub type StatusCallback = Box<dyn Fn(&str) + Send + Sync>;

/// Generates initial discovery messages for fast codebase exploration.
///
/// This function:
/// 1. Runs explore_codebase to get a codebase report
/// 2. Sends the report to the LLM with DISCOVERY_SYSTEM_PROMPT
/// 3. Extracts shell commands from the LLM response
/// 4. Returns Assistant messages with tool calls for each command
///
/// # Arguments
///
/// * `codebase_path` - The path to the codebase to explore
/// * `provider` - An LLM provider to query for exploration commands
/// * `requirements_text` - Optional requirements text to include in the discovery prompt
/// * `status_callback` - Optional callback for status updates
///
/// # Returns
///
/// A `Result<Vec<Message>>` containing Assistant messages with JSON tool call strings.
pub async fn get_initial_discovery_messages(
    codebase_path: &str,
    requirements_text: Option<&str>,
    provider: &dyn LLMProvider,
    status_callback: Option<&StatusCallback>,
) -> Result<Vec<Message>> {
    // Helper to call status callback if provided
    let status = |msg: &str| {
        if let Some(cb) = status_callback {
            cb(msg);
        }
    };

    status("🔍 Starting code discovery...");

    // Step 1: Run explore_codebase to get the codebase report
    let codebase_report = explore_codebase(codebase_path);

    // Write the codebase report to logs directory
    write_code_report(&codebase_report)?;

    // Step 2: Build the prompt with the codebase report appended
    let user_prompt = if let Some(requirements) = requirements_text {
        format!(
            "{}\n\n
            === REQUIREMENTS ===\n\n{}\n\n
            === CODEBASE REPORT ===\n\n{}",
            DISCOVERY_REQUIREMENTS_PROMPT, requirements, codebase_report
        )
    } else {
        format!(
            "{}\n\n=== CODEBASE REPORT ===\n\n{}",
            DISCOVERY_REQUIREMENTS_PROMPT, codebase_report
        )
    };

    // Step 3: Create messages for the LLM
    let messages = vec![
        Message::new(MessageRole::System, DISCOVERY_SYSTEM_PROMPT.to_string()),
        Message::new(MessageRole::User, user_prompt),
    ];

    // Step 4: Send to LLM
    let request = CompletionRequest {
        messages,
        max_tokens: Some(provider.max_tokens()),
        temperature: Some(provider.temperature()),
        stream: false,
        tools: None,
        disable_thinking: false,
    };

    status("🤖 Calling LLM for discovery commands...");

    let response = provider.complete(request).await?;

    // Step 5: Extract shell commands from the response
    let shell_commands = extract_shell_commands(&response.content);

    status(&format!(
        "📋 Extracted {} discovery commands",
        shell_commands.len()
    ));

    // Write the discovery commands to logs directory
    write_discovery_commands(&shell_commands)?;

    // Step 6: Format as tool messages
    let tool_messages = shell_commands
        .into_iter()
        .map(|cmd| create_tool_message("shell", &cmd))
        .collect();

    Ok(tool_messages)
}

/// Creates an Assistant message with a tool call in g3's JSON format.
pub fn create_tool_message(tool: &str, command: &str) -> Message {
    let tool_call = serde_json::json!({
        "tool": tool,
        "args": {
            "command": command
        }
    });

    Message::new(MessageRole::Assistant, tool_call.to_string())
}

/// Extract shell commands from the LLM response.
/// Looks for {{CODE EXPLORATION COMMANDS}} section and extracts commands from code blocks.
pub fn extract_shell_commands(response: &str) -> Vec<String> {
    let mut commands = Vec::new();

    let section_marker = "{{CODE EXPLORATION COMMANDS}}";
    let section_start = match response.find(section_marker) {
        Some(pos) => pos + section_marker.len(),
        None => return commands,
    };

    let section_content = &response[section_start..];
    let mut in_code_block = false;
    let mut current_block = String::new();

    for line in section_content.lines() {
        let trimmed = line.trim();

        if trimmed.starts_with("```") {
            if in_code_block {
                // End of code block - extract commands
                for cmd_line in current_block.lines() {
                    let cmd = cmd_line.trim();
                    if !cmd.is_empty() && !cmd.starts_with('#') {
                        commands.push(cmd.to_string());
                    }
                }
                current_block.clear();
            }
            in_code_block = !in_code_block;
        } else if in_code_block {
            current_block.push_str(line);
            current_block.push('\n');
        }
    }

    commands
}

/// Extract the summary section from the LLM response
pub fn extract_summary(response: &str) -> Option<String> {
    let section_marker = "{{SUMMARY BASED ON INITIAL INFO}}";
    let section_start = match response.find(section_marker) {
        Some(pos) => pos + section_marker.len(),
        None => return None,
    };

    let section_content = &response[section_start..];
    let section_end = section_content.find("{{").unwrap_or(section_content.len());

    let summary = section_content[..section_end].trim().to_string();
    if summary.is_empty() {
        None
    } else {
        Some(summary)
    }
}

/// Write the codebase report to logs directory
fn write_code_report(report: &str) -> Result<()> {
    // Get logs directory from workspace path or current dir
    let logs_dir = if let Ok(workspace_path) = std::env::var("G3_WORKSPACE_PATH") {
        std::path::PathBuf::from(workspace_path).join("logs")
    } else {
        std::env::current_dir().unwrap_or_default().join("logs")
    };
    
    // Ensure logs directory exists  
    fs::create_dir_all(&logs_dir)?;

    // Generate timestamp in same format as tool_calls log
    let timestamp = Local::now().format("%Y%m%d_%H%M%S").to_string();
    let filename = logs_dir.join(format!("code_report_{}.log", timestamp));

    // Write the report to file
    let mut file = OpenOptions::new()
        .create(true)
        .write(true)
        .truncate(true)
        .open(&filename)?;

    file.write_all(report.as_bytes())?;
    file.flush()?;

    Ok(())
}

/// Write the discovery commands to logs directory
fn write_discovery_commands(commands: &[String]) -> Result<()> {
    // Get logs directory from workspace path or current dir
    let logs_dir = if let Ok(workspace_path) = std::env::var("G3_WORKSPACE_PATH") {
        std::path::PathBuf::from(workspace_path).join("logs")
    } else {
        std::env::current_dir().unwrap_or_default().join("logs")
    };
    
    // Ensure logs directory exists
    fs::create_dir_all(&logs_dir)?;

    // Generate timestamp in same format as tool_calls log
    let timestamp = Local::now().format("%Y%m%d_%H%M%S").to_string();
    let filename = logs_dir.join(format!("discovery_commands_{}.log", timestamp));

    // Write the commands to file
    let mut file = OpenOptions::new()
        .create(true)
        .write(true)
        .truncate(true)
        .open(&filename)?;

    // Write header
    file.write_all(b"# Discovery Commands\n")?;
    file.write_all(b"# Generated by g3-planner\n\n")?;

    // Write each command on a separate line
    for cmd in commands {
        file.write_all(cmd.as_bytes())?;
        file.write_all(b"\n")?;
    }
    file.flush()?;

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_create_tool_message_format() {
        let msg = create_tool_message("shell", "ls -la");

        assert!(matches!(msg.role, MessageRole::Assistant));

        let parsed: serde_json::Value = serde_json::from_str(&msg.content).unwrap();
        assert_eq!(parsed["tool"], "shell");
        assert_eq!(parsed["args"]["command"], "ls -la");
    }

    #[test]
    fn test_extract_shell_commands_basic() {
        let response = r#"
Some text here.

{{CODE EXPLORATION COMMANDS}}

```bash
ls -la
cat README.md
rg --files -g '*.rs'
```

More text.
"#;

        let commands = extract_shell_commands(response);
        assert_eq!(commands.len(), 3);
        assert_eq!(commands[0], "ls -la");
        assert_eq!(commands[1], "cat README.md");
        assert_eq!(commands[2], "rg --files -g '*.rs'");
    }

    #[test]
    fn test_extract_shell_commands_with_comments() {
        let response = r#"
{{CODE EXPLORATION COMMANDS}}

```
# This is a comment
ls -la
# Another comment
cat file.txt
```
"#;

        let commands = extract_shell_commands(response);
        assert_eq!(commands.len(), 2);
        assert_eq!(commands[0], "ls -la");
        assert_eq!(commands[1], "cat file.txt");
    }

    #[test]
    fn test_extract_shell_commands_no_section() {
        let response = "Some response without the expected section.";
        let commands = extract_shell_commands(response);
        assert!(commands.is_empty());
    }

    #[test]
    fn test_extract_summary() {
        let response = r#"
{{SUMMARY BASED ON INITIAL INFO}}

This is a summary of the codebase.
It has multiple lines.

{{CODE EXPLORATION COMMANDS}}

```
ls -la
```
"#;

        let summary = extract_summary(response);
        assert!(summary.is_some());
        let summary_text = summary.unwrap();
        assert!(summary_text.contains("This is a summary"));
        assert!(summary_text.contains("multiple lines"));
    }

    #[test]
    fn test_extract_summary_no_section() {
        let response = "Response without summary section.";
        let summary = extract_summary(response);
        assert!(summary.is_none());
    }
}
