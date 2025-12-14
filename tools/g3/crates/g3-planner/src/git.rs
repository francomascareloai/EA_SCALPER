//! Git operations for planning mode
//!
//! This module provides git functionality for the planner:
//! - Repository detection
//! - Branch information
//! - Dirty file detection
//! - Staging and committing

use anyhow::{Context, Result};
use std::path::Path;
use std::process::Command;

/// Files and directories to exclude from staging
const EXCLUDE_PATTERNS: &[&str] = &[
    "target/",
    "node_modules/",
    "__pycache__/",
    ".venv/",
    "*.log",
    "*.tmp",
    "*.bak",
    ".DS_Store",
    "Thumbs.db",
    "*.pyc",
    "tmp/",
    "temp/",
    ".pytest_cache/",
    ".mypy_cache/",
    ".ruff_cache/",
    "*.swp",
    "*.swo",
    "*~",
];

/// Check if the given path is within a git repository
pub fn check_git_repo(codepath: &Path) -> Result<bool> {
    let output = Command::new("git")
        .args(["rev-parse", "--git-dir"])
        .current_dir(codepath)
        .output()
        .context("Failed to execute git command")?;

    Ok(output.status.success())
}

/// Get the root directory of the git repository
pub fn get_repo_root(codepath: &Path) -> Result<String> {
    let output = Command::new("git")
        .args(["rev-parse", "--show-toplevel"])
        .current_dir(codepath)
        .output()
        .context("Failed to get git repo root")?;

    if !output.status.success() {
        anyhow::bail!("Not in a git repository");
    }

    let root = String::from_utf8(output.stdout)
        .context("Invalid UTF-8 in git output")?
        .trim()
        .to_string();

    Ok(root)
}

/// Get the current git branch name
pub fn get_current_branch(codepath: &Path) -> Result<String> {
    let output = Command::new("git")
        .args(["branch", "--show-current"])
        .current_dir(codepath)
        .output()
        .context("Failed to get current git branch")?;

    if !output.status.success() {
        // Might be in detached HEAD state
        let stderr = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("Failed to get branch name: {}", stderr);
    }

    let branch = String::from_utf8(output.stdout)
        .context("Invalid UTF-8 in git output")?
        .trim()
        .to_string();

    if branch.is_empty() {
        // Detached HEAD state - get short SHA instead
        let sha_output = Command::new("git")
            .args(["rev-parse", "--short", "HEAD"])
            .current_dir(codepath)
            .output()
            .context("Failed to get HEAD SHA")?;

        let sha = String::from_utf8(sha_output.stdout)
            .context("Invalid UTF-8 in git output")?
            .trim()
            .to_string();

        Ok(format!("(detached HEAD at {})", sha))
    } else {
        Ok(branch)
    }
}

/// Get the current HEAD SHA
pub fn get_head_sha(codepath: &Path) -> Result<String> {
    let output = Command::new("git")
        .args(["rev-parse", "HEAD"])
        .current_dir(codepath)
        .output()
        .context("Failed to get HEAD SHA")?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("Failed to get HEAD SHA: {}", stderr);
    }

    let sha = String::from_utf8(output.stdout)
        .context("Invalid UTF-8 in git output")?
        .trim()
        .to_string();

    Ok(sha)
}

/// Information about dirty/untracked files
#[derive(Debug, Default)]
pub struct DirtyFiles {
    pub modified: Vec<String>,
    pub untracked: Vec<String>,
    pub staged: Vec<String>,
}

impl DirtyFiles {
    pub fn is_empty(&self) -> bool {
        self.modified.is_empty() && self.untracked.is_empty() && self.staged.is_empty()
    }

    pub fn to_display_string(&self) -> String {
        let mut lines = Vec::new();

        if !self.staged.is_empty() {
            lines.push("Staged:".to_string());
            for f in &self.staged {
                lines.push(format!("  {}", f));
            }
        }

        if !self.modified.is_empty() {
            lines.push("Modified:".to_string());
            for f in &self.modified {
                lines.push(format!("  {}", f));
            }
        }

        if !self.untracked.is_empty() {
            lines.push("Untracked:".to_string());
            for f in &self.untracked {
                lines.push(format!("  {}", f));
            }
        }

        lines.join("\n")
    }
}

/// Check for untracked, uncommitted, or dirty files
/// Optionally ignores files matching a given path pattern
pub fn check_dirty_files(codepath: &Path, ignore_pattern: Option<&str>) -> Result<DirtyFiles> {
    let output = Command::new("git")
        .args(["status", "--porcelain"])
        .current_dir(codepath)
        .output()
        .context("Failed to check git status")?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("Failed to check git status: {}", stderr);
    }

    let status_output = String::from_utf8(output.stdout)
        .context("Invalid UTF-8 in git output")?;

    let mut result = DirtyFiles::default();

    for line in status_output.lines() {
        if line.len() < 3 {
            continue;
        }

        let status = &line[0..2];
        let file = line[3..].trim();

        // Check if this file should be ignored
        if let Some(pattern) = ignore_pattern {
            if file.contains(pattern) {
                continue;
            }
        }

        match status {
            "??" => result.untracked.push(file.to_string()),
            " M" | "MM" | "AM" => result.modified.push(file.to_string()),
            "M " | "A " | "D " | "R " => result.staged.push(file.to_string()),
            _ => {
                // Other statuses (deleted, renamed, etc.)
                if status.starts_with(' ') {
                    result.modified.push(file.to_string());
                } else {
                    result.staged.push(file.to_string());
                }
            }
        }
    }

    Ok(result)
}

/// Check if a file should be excluded from staging based on patterns
fn should_exclude(path: &str) -> bool {
    for pattern in EXCLUDE_PATTERNS {
        if pattern.ends_with('/') {
            // Directory pattern
            let dir_name = pattern.trim_end_matches('/');
            if path.contains(&format!("/{}/", dir_name)) || path.starts_with(&format!("{}/", dir_name)) {
                return true;
            }
        } else if pattern.starts_with('*') {
            // Wildcard pattern
            let suffix = pattern.trim_start_matches('*');
            if path.ends_with(suffix) {
                return true;
            }
        } else {
            // Exact match
            if path == *pattern || path.ends_with(&format!("/{}", pattern)) {
                return true;
            }
        }
    }
    false
}

/// Stage files for commit, excluding temporary/artifact files
/// Stages all files in the specified directory plus any modified/new code files
pub fn stage_files(codepath: &Path, plan_dir: &Path) -> Result<StagingResult> {
    let mut result = StagingResult::default();

    // First, stage all files in the g3-plan directory
    let plan_dir_str = plan_dir.to_string_lossy();
    let add_plan_output = Command::new("git")
        .args(["add", &plan_dir_str])
        .current_dir(codepath)
        .output()
        .context("Failed to stage g3-plan directory")?;

    if !add_plan_output.status.success() {
        let stderr = String::from_utf8_lossy(&add_plan_output.stderr);
        // Don't fail if directory doesn't exist yet
        if !stderr.contains("did not match any files") {
            anyhow::bail!("Failed to stage g3-plan directory: {}", stderr);
        }
    }

    // Get list of all changed files
    let status_output = Command::new("git")
        .args(["status", "--porcelain"])
        .current_dir(codepath)
        .output()
        .context("Failed to get git status")?;

    let status_str = String::from_utf8(status_output.stdout)
        .context("Invalid UTF-8 in git output")?;

    // Stage files that aren't excluded
    for line in status_str.lines() {
        if line.len() < 3 {
            continue;
        }

        let status = &line[0..2];
        let file = line[3..].trim();

        // Skip already staged files
        if !status.starts_with(' ') && status != "??" {
            continue;
        }

        // Check if this file should be excluded
        if should_exclude(file) {
            result.excluded.push(file.to_string());
            continue;
        }

        // Stage the file
        let add_output = Command::new("git")
            .args(["add", file])
            .current_dir(codepath)
            .output()
            .context(format!("Failed to stage file: {}", file))?;

        if add_output.status.success() {
            result.staged.push(file.to_string());
        } else {
            result.failed.push(file.to_string());
        }
    }

    Ok(result)
}

/// Re-stage the g3-plan directory to capture any changes made after initial staging.
///
/// This is specifically needed because `planner_history.txt` is modified AFTER the initial
/// `stage_files()` call (to write the GIT COMMIT entry) but BEFORE `git commit`.
/// Without this re-staging, the GIT COMMIT entry would not be included in the commit.
pub fn stage_plan_dir(codepath: &Path, plan_dir: &Path) -> Result<()> {
    let plan_dir_str = plan_dir.to_string_lossy();
    let add_output = Command::new("git")
        .args(["add", &plan_dir_str])
        .current_dir(codepath)
        .output()
        .context("Failed to re-stage g3-plan directory")?;

    if !add_output.status.success() {
        let stderr = String::from_utf8_lossy(&add_output.stderr);
        anyhow::bail!("Failed to re-stage g3-plan directory: {}", stderr);
    }

    Ok(())
}

/// Result of staging operation
#[derive(Debug, Default)]
pub struct StagingResult {
    pub staged: Vec<String>,
    pub excluded: Vec<String>,
    pub failed: Vec<String>,
}

/// Make a git commit with the given summary and description
pub fn commit(codepath: &Path, summary: &str, description: &str) -> Result<String> {
    // Combine summary and description into full commit message
    let full_message = if description.is_empty() {
        summary.to_string()
    } else {
        format!("{}\n\n{}", summary, description)
    };

    let output = Command::new("git")
        .args(["commit", "-m", &full_message])
        .current_dir(codepath)
        .output()
        .context("Failed to make git commit")?;

    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        anyhow::bail!("Git commit failed: {}", stderr);
    }

    // Get the commit SHA
    get_head_sha(codepath)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_should_exclude_target() {
        assert!(should_exclude("target/debug/something"));
        assert!(should_exclude("some/path/target/release/bin"));
    }

    #[test]
    fn test_should_exclude_node_modules() {
        assert!(should_exclude("node_modules/package/index.js"));
        assert!(should_exclude("frontend/node_modules/react/index.js"));
    }

    #[test]
    fn test_should_exclude_log_files() {
        assert!(should_exclude("app.log"));
        assert!(should_exclude("logs/debug.log"));
    }

    #[test]
    fn test_should_exclude_temp_files() {
        assert!(should_exclude("file.tmp"));
        assert!(should_exclude("file.bak"));
        assert!(should_exclude("file.swp"));
    }

    #[test]
    fn test_should_not_exclude_normal_files() {
        assert!(!should_exclude("src/main.rs"));
        assert!(!should_exclude("Cargo.toml"));
        assert!(!should_exclude("README.md"));
        assert!(!should_exclude("package.json"));
    }

    #[test]
    fn test_dirty_files_display() {
        let dirty = DirtyFiles {
            modified: vec!["src/main.rs".to_string()],
            untracked: vec!["new_file.txt".to_string()],
            staged: vec!["Cargo.toml".to_string()],
        };

        let display = dirty.to_display_string();
        assert!(display.contains("Modified:"));
        assert!(display.contains("src/main.rs"));
        assert!(display.contains("Untracked:"));
        assert!(display.contains("new_file.txt"));
        assert!(display.contains("Staged:"));
        assert!(display.contains("Cargo.toml"));
    }
}
