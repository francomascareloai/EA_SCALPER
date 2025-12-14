//! Planner state machine
//!
//! This module defines the state machine for the planning mode:
//!
//! ```text
//!          +------------- RECOVERY (Resume) ---------------------+
//!          |                                                     |
//!          |  +---------- RECOVERY (Mark Complete) ----+         |
//!          |  |                                        |         |
//!          ^  ^                                        v         v
//! STARTUP -> PROMPT FOR NEW REQUIREMENTS -> REFINE REQUIREMENTS -> IMPLEMENT REQUIREMENTS -> IMPLEMENTATION COMPLETE +
//! ^                                                                                                         v
//! |                                                                                                         |
//! +---------------------------------------------------------------------------------------------------------+
//! ```

use std::path::Path;
use chrono::{DateTime, Local};

/// The state of the planning mode
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum PlannerState {
    /// Initial startup state
    Startup,
    /// Recovery needed - found incomplete previous run
    Recovery(RecoveryInfo),
    /// Prompting user for new requirements
    PromptForRequirements,
    /// Refining requirements with LLM
    RefineRequirements,
    /// Implementing requirements (coach/player loop)
    ImplementRequirements,
    /// Implementation completed successfully
    ImplementationComplete,
    /// User quit the application
    Quit,
}

/// Information about a recovery situation
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct RecoveryInfo {
    /// Whether current_requirements.md exists
    pub has_current_requirements: bool,
    /// Timestamp of current_requirements.md if it exists
    pub requirements_modified: Option<String>,
    /// Whether todo.g3.md exists
    pub has_todo: bool,
    /// Contents of todo.g3.md if it exists
    pub todo_contents: Option<String>,
}

impl RecoveryInfo {
    /// Create recovery info by checking file existence
    pub fn detect(plan_dir: &Path) -> Option<Self> {
        let current_req_path = plan_dir.join("current_requirements.md");
        let todo_path = plan_dir.join("todo.g3.md");

        let has_current_requirements = current_req_path.exists();
        let has_todo = todo_path.exists();

        // If neither file exists, no recovery needed
        if !has_current_requirements && !has_todo {
            return None;
        }

        let requirements_modified = if has_current_requirements {
            get_file_modified_time(&current_req_path)
        } else {
            None
        };

        let todo_contents = if has_todo {
            std::fs::read_to_string(&todo_path).ok()
        } else {
            None
        };

        Some(RecoveryInfo {
            has_current_requirements,
            requirements_modified,
            has_todo,
            todo_contents,
        })
    }
}

/// Get the modified time of a file as a formatted string
fn get_file_modified_time(path: &Path) -> Option<String> {
    let metadata = std::fs::metadata(path).ok()?;
    let modified = metadata.modified().ok()?;
    let datetime: DateTime<Local> = modified.into();
    Some(datetime.format("%Y-%m-%d %H:%M:%S").to_string())
}

/// User's choice when presented with recovery options
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RecoveryChoice {
    /// Resume the previous implementation
    Resume,
    /// Mark as complete and proceed to new requirements
    MarkComplete,
    /// Quit and investigate manually
    Quit,
}

impl RecoveryChoice {
    /// Parse user input into a recovery choice
    pub fn from_input(input: &str) -> Option<Self> {
        let input = input.trim().to_lowercase();
        match input.as_str() {
            "y" | "yes" => Some(RecoveryChoice::Resume),
            "n" | "no" => Some(RecoveryChoice::MarkComplete),
            "q" | "quit" => Some(RecoveryChoice::Quit),
            _ => None,
        }
    }
}

/// User's choice when asked to approve requirements
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ApprovalChoice {
    /// Approve and proceed to implementation
    Approve,
    /// Continue refining
    Refine,
    /// Quit the application
    Quit,
}

impl ApprovalChoice {
    /// Parse user input into an approval choice
    pub fn from_input(input: &str) -> Option<Self> {
        let input = input.trim().to_lowercase();
        match input.as_str() {
            "y" | "yes" => Some(ApprovalChoice::Approve),
            "n" | "no" => Some(ApprovalChoice::Refine),
            "q" | "quit" => Some(ApprovalChoice::Quit),
            _ => None,
        }
    }
}

/// User's choice when asked if implementation is complete
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CompletionChoice {
    /// Yes, implementation is complete
    Complete,
    /// No, continue with coach/player loop
    Continue,
    /// Quit the application
    Quit,
}

impl CompletionChoice {
    /// Parse user input into a completion choice
    pub fn from_input(input: &str) -> Option<Self> {
        let input = input.trim().to_lowercase();
        match input.as_str() {
            "y" | "yes" | "" => Some(CompletionChoice::Complete),
            "n" | "no" => Some(CompletionChoice::Continue),
            "q" | "quit" => Some(CompletionChoice::Quit),
            _ => None,
        }
    }
}

/// User's choice when asked to confirm git branch
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum BranchConfirmChoice {
    /// Yes, correct branch
    Confirm,
    /// No, wrong branch - quit
    Quit,
}

impl BranchConfirmChoice {
    /// Parse user input into a branch confirmation choice
    pub fn from_input(input: &str) -> Option<Self> {
        let input = input.trim().to_lowercase();
        match input.as_str() {
            "y" | "yes" | "" => Some(BranchConfirmChoice::Confirm),
            "n" | "no" | "q" | "quit" => Some(BranchConfirmChoice::Quit),
            _ => None,
        }
    }
}

/// User's choice when warned about dirty files
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum DirtyFilesChoice {
    /// Proceed anyway
    Proceed,
    /// Quit and handle manually
    Quit,
}

impl DirtyFilesChoice {
    /// Parse user input into a dirty files choice
    pub fn from_input(input: &str) -> Option<Self> {
        let input = input.trim().to_lowercase();
        match input.as_str() {
            "y" | "yes" | "" => Some(DirtyFilesChoice::Proceed),
            "n" | "no" | "q" | "quit" => Some(DirtyFilesChoice::Quit),
            _ => None,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::TempDir;

    #[test]
    fn test_recovery_info_no_files() {
        let temp_dir = TempDir::new().unwrap();
        let result = RecoveryInfo::detect(temp_dir.path());
        assert!(result.is_none());
    }

    #[test]
    fn test_recovery_info_with_current_requirements() {
        let temp_dir = TempDir::new().unwrap();
        let req_path = temp_dir.path().join("current_requirements.md");
        std::fs::write(&req_path, "test requirements").unwrap();

        let result = RecoveryInfo::detect(temp_dir.path());
        assert!(result.is_some());
        let info = result.unwrap();
        assert!(info.has_current_requirements);
        assert!(info.requirements_modified.is_some());
        assert!(!info.has_todo);
        assert!(info.todo_contents.is_none());
    }

    #[test]
    fn test_recovery_info_with_todo() {
        let temp_dir = TempDir::new().unwrap();
        let todo_path = temp_dir.path().join("todo.g3.md");
        std::fs::write(&todo_path, "- [ ] Test task").unwrap();

        let result = RecoveryInfo::detect(temp_dir.path());
        assert!(result.is_some());
        let info = result.unwrap();
        assert!(!info.has_current_requirements);
        assert!(info.has_todo);
        assert_eq!(info.todo_contents, Some("- [ ] Test task".to_string()));
    }

    #[test]
    fn test_recovery_choice_parsing() {
        assert_eq!(RecoveryChoice::from_input("y"), Some(RecoveryChoice::Resume));
        assert_eq!(RecoveryChoice::from_input("YES"), Some(RecoveryChoice::Resume));
        assert_eq!(RecoveryChoice::from_input("n"), Some(RecoveryChoice::MarkComplete));
        assert_eq!(RecoveryChoice::from_input("No"), Some(RecoveryChoice::MarkComplete));
        assert_eq!(RecoveryChoice::from_input("q"), Some(RecoveryChoice::Quit));
        assert_eq!(RecoveryChoice::from_input("quit"), Some(RecoveryChoice::Quit));
        assert_eq!(RecoveryChoice::from_input("invalid"), None);
    }

    #[test]
    fn test_approval_choice_parsing() {
        assert_eq!(ApprovalChoice::from_input("yes"), Some(ApprovalChoice::Approve));
        assert_eq!(ApprovalChoice::from_input("no"), Some(ApprovalChoice::Refine));
        assert_eq!(ApprovalChoice::from_input("quit"), Some(ApprovalChoice::Quit));
    }

    #[test]
    fn test_completion_choice_parsing() {
        assert_eq!(CompletionChoice::from_input("y"), Some(CompletionChoice::Complete));
        assert_eq!(CompletionChoice::from_input(""), Some(CompletionChoice::Complete)); // Default
        assert_eq!(CompletionChoice::from_input("n"), Some(CompletionChoice::Continue));
        assert_eq!(CompletionChoice::from_input("quit"), Some(CompletionChoice::Quit));
    }

    #[test]
    fn test_branch_confirm_parsing() {
        assert_eq!(BranchConfirmChoice::from_input("y"), Some(BranchConfirmChoice::Confirm));
        assert_eq!(BranchConfirmChoice::from_input(""), Some(BranchConfirmChoice::Confirm)); // Default
        assert_eq!(BranchConfirmChoice::from_input("n"), Some(BranchConfirmChoice::Quit));
    }

    #[test]
    fn test_dirty_files_choice_parsing() {
        assert_eq!(DirtyFilesChoice::from_input("y"), Some(DirtyFilesChoice::Proceed));
        assert_eq!(DirtyFilesChoice::from_input(""), Some(DirtyFilesChoice::Proceed)); // Default
        assert_eq!(DirtyFilesChoice::from_input("n"), Some(DirtyFilesChoice::Quit));
    }
}
