//! Planner history management
//!
//! This module manages the planner_history.txt file which serves as:
//! - An audit log of planning steps
//! - A comprehensive reference of historic requirements and implementations
//! - A file that requires merging/resolution if updated on separate git branches

use anyhow::{Context, Result};
use chrono::Local;
use std::fs::{self, OpenOptions};
use std::io::Write;
use std::path::Path;

/// Format a timestamp for planner_history.txt entries
/// Format: YYYY-MM-DD HH:MM:SS (ISO 8601 for readability)
pub fn format_timestamp() -> String {
    Local::now().format("%Y-%m-%d %H:%M:%S").to_string()
}

/// Format a timestamp for filenames
/// Format: YYYY-MM-DD_HH-MM-SS (filesystem-safe)
pub fn format_timestamp_for_filename() -> String {
    Local::now().format("%Y-%m-%d_%H-%M-%S").to_string()
}

/// Ensure the planner_history.txt file exists, creating it if necessary
pub fn ensure_history_file(plan_dir: &Path) -> Result<()> {
    let history_path = plan_dir.join("planner_history.txt");
    
    if !history_path.exists() {
        fs::write(&history_path, "")
            .context("Failed to create planner_history.txt")?;
    }
    
    Ok(())
}

/// Append an entry to planner_history.txt.
///
/// This function opens the file in append mode, writes a single line, and explicitly flushes
/// the buffer to ensure the write is durable before returning. While dropping the file handle
/// would normally trigger a flush, we make it explicit here for clarity and to eliminate any
/// possibility of buffering issues.
///
/// NOTE: The observed "GIT COMMIT not written before commit" bug is NOT caused by I/O buffering
/// in this function. It's caused by incorrect call ordering where `git::commit()` is invoked
/// before `history::write_git_commit()`. This function correctly writes to disk when called.
fn append_entry(plan_dir: &Path, entry: &str) -> Result<()> {
    let history_path = plan_dir.join("planner_history.txt");
    
    let mut file = OpenOptions::new()
        .create(true)
        .append(true)
        .open(&history_path)
        .context("Failed to open planner_history.txt for appending")?;
    
    writeln!(file, "{}", entry)
        .context("Failed to write to planner_history.txt")?;
    
    // Explicit flush to ensure data is written to disk before returning
    file.flush()
        .context("Failed to flush planner_history.txt")?;
    
    Ok(())
}

/// Write a "REFINING REQUIREMENTS" entry
pub fn write_refining_requirements(plan_dir: &Path) -> Result<()> {
    let timestamp = format_timestamp();
    let entry = "{timestamp} - REFINING REQUIREMENTS (new_requirements.md)"
        .replace("{timestamp}", &timestamp);
    append_entry(plan_dir, &entry)
}

/// Write a "GIT HEAD" entry with the current SHA
pub fn write_git_head(plan_dir: &Path, sha: &str) -> Result<()> {
    let timestamp = format_timestamp();
    let entry = "{timestamp} - GIT HEAD ({sha})"
        .replace("{timestamp}", &timestamp)
        .replace("{sha}", sha);
    append_entry(plan_dir, &entry)
}

/// Write a "START IMPLEMENTING" entry with a summary block
pub fn write_start_implementing(plan_dir: &Path, summary: &str) -> Result<()> {
    let timestamp = format_timestamp();
    let entry = "{timestamp} - START IMPLEMENTING (current_requirements.md)"
        .replace("{timestamp}", &timestamp);
    
    // Format the summary with proper indentation
    let indented_summary = summary
        .lines()
        .map(|line| format!("  {}", line))
        .collect::<Vec<_>>()
        .join("\n");
    
    let summary_block = "<<\n{summary}\n>>"
        .replace("{summary}", &indented_summary);
    
    append_entry(plan_dir, &entry)?;
    append_entry(plan_dir, &summary_block)?;
    
    Ok(())
}

/// Write an "ATTEMPTING RECOVERY" entry
pub fn write_attempting_recovery(plan_dir: &Path) -> Result<()> {
    let timestamp = format_timestamp();
    let entry = "{timestamp}   ATTEMPTING RECOVERY"
        .replace("{timestamp}", &timestamp);
    append_entry(plan_dir, &entry)
}

/// Write a "USER SKIPPED RECOVERY" entry
pub fn write_skipped_recovery(plan_dir: &Path) -> Result<()> {
    let timestamp = format_timestamp();
    let entry = "{timestamp}  USER SKIPPED RECOVERY"
        .replace("{timestamp}", &timestamp);
    append_entry(plan_dir, &entry)
}

/// Write a "COMPLETED REQUIREMENTS" entry
pub fn write_completed_requirements(
    plan_dir: &Path,
    requirements_file: &str,
    todo_file: &str,
) -> Result<()> {
    let timestamp = format_timestamp();
    let entry = "{timestamp} - COMPLETED REQUIREMENTS ({requirements_file},  {todo_file})"
        .replace("{timestamp}", &timestamp)
        .replace("{requirements_file}", requirements_file)
        .replace("{todo_file}", todo_file);
    append_entry(plan_dir, &entry)
}

/// Write a "GIT COMMIT" entry
pub fn write_git_commit(plan_dir: &Path, message: &str) -> Result<()> {
    let timestamp = format_timestamp();
    // Truncate message if too long for a single line
    let truncated_message = if message.len() > 72 {
        format!("{}...", &message[..69])
    } else {
        message.to_string()
    };
    let entry = "{timestamp} - GIT COMMIT ({message})"
        .replace("{timestamp}", &timestamp)
        .replace("{message}", &truncated_message);
    append_entry(plan_dir, &entry)
}

/// Generate the completed requirements filename
pub fn completed_requirements_filename() -> String {
    format!("completed_requirements_{}.md", format_timestamp_for_filename())
}

/// Generate the completed todo filename
pub fn completed_todo_filename() -> String {
    format!("completed_todo_{}.md", format_timestamp_for_filename())
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    #[test]
    fn test_format_timestamp() {
        let ts = format_timestamp();
        // Should be in format YYYY-MM-DD HH:MM:SS
        assert_eq!(ts.len(), 19);
        assert_eq!(&ts[4..5], "-");
        assert_eq!(&ts[7..8], "-");
        assert_eq!(&ts[10..11], " ");
        assert_eq!(&ts[13..14], ":");
        assert_eq!(&ts[16..17], ":");
    }

    #[test]
    fn test_format_timestamp_for_filename() {
        let ts = format_timestamp_for_filename();
        // Should be in format YYYY-MM-DD_HH-MM-SS
        assert_eq!(ts.len(), 19);
        assert_eq!(&ts[4..5], "-");
        assert_eq!(&ts[7..8], "-");
        assert_eq!(&ts[10..11], "_");
        assert_eq!(&ts[13..14], "-");
        assert_eq!(&ts[16..17], "-");
        // Should not contain colons (filesystem-safe)
        assert!(!ts.contains(':'));
    }

    #[test]
    fn test_ensure_history_file() {
        let temp_dir = TempDir::new().unwrap();
        let plan_dir = temp_dir.path();
        
        let history_path = plan_dir.join("planner_history.txt");
        assert!(!history_path.exists());
        
        ensure_history_file(plan_dir).unwrap();
        
        assert!(history_path.exists());
    }

    #[test]
    fn test_write_entries() {
        let temp_dir = TempDir::new().unwrap();
        let plan_dir = temp_dir.path();
        
        ensure_history_file(plan_dir).unwrap();
        
        write_refining_requirements(plan_dir).unwrap();
        write_git_head(plan_dir, "abc123def456").unwrap();
        write_start_implementing(plan_dir, "Test summary line 1\nTest summary line 2").unwrap();
        write_attempting_recovery(plan_dir).unwrap();
        write_completed_requirements(plan_dir, "completed_requirements_2025-01-01_12-00-00.md", "completed_todo_2025-01-01_12-00-00.md").unwrap();
        write_git_commit(plan_dir, "Add feature X").unwrap();
        
        let history_path = plan_dir.join("planner_history.txt");
        let content = fs::read_to_string(history_path).unwrap();
        
        assert!(content.contains("REFINING REQUIREMENTS"));
        assert!(content.contains("GIT HEAD (abc123def456)"));
        assert!(content.contains("START IMPLEMENTING"));
        assert!(content.contains("Test summary line 1"));
        assert!(content.contains("ATTEMPTING RECOVERY"));
        assert!(content.contains("COMPLETED REQUIREMENTS"));
        assert!(content.contains("GIT COMMIT"));
    }

    #[test]
    fn test_completed_filenames() {
        let req_file = completed_requirements_filename();
        let todo_file = completed_todo_filename();
        
        assert!(req_file.starts_with("completed_requirements_"));
        assert!(req_file.ends_with(".md"));
        assert!(todo_file.starts_with("completed_todo_"));
        assert!(todo_file.ends_with(".md"));
        
        // Should not contain colons
        assert!(!req_file.contains(':'));
        assert!(!todo_file.contains(':'));
    }
}
