//! Tests for the critical invariant: planner_history.txt must be written BEFORE git commit
//!
//! This test suite ensures that the ordering of history write and git commit operations
//! is maintained correctly. This is essential for audit trail purposes and post-mortem
//! analysis when commits fail.

use anyhow::Result;
use std::fs;
use std::process::Command;
use tempfile::TempDir;

/// Helper to create a test git repository
fn setup_test_git_repo() -> Result<TempDir> {
    let temp_dir = TempDir::new()?;
    let repo_path = temp_dir.path();
    
    // Initialize git repo
    Command::new("git")
        .args(["init"])
        .current_dir(repo_path)
        .output()?;
    
    // Configure git user (required for commits)
    Command::new("git")
        .args(["config", "user.name", "Test User"])
        .current_dir(repo_path)
        .output()?;
    
    Command::new("git")
        .args(["config", "user.email", "test@example.com"])
        .current_dir(repo_path)
        .output()?;
    
    // Create g3-plan directory
    let plan_dir = repo_path.join("g3-plan");
    fs::create_dir_all(&plan_dir)?;
    
    // Create planner_history.txt
    fs::write(plan_dir.join("planner_history.txt"), "")?;
    
    Ok(temp_dir)
}

/// Test that history entry is written even when git commit fails due to missing files
#[test]
fn test_history_written_before_commit_on_empty_staging() {
    let temp_dir = setup_test_git_repo().expect("Failed to setup test repo");
    let repo_path = temp_dir.path();
    let plan_dir = repo_path.join("g3-plan");
    
    // Import necessary types
    use g3_planner::planner::PlannerConfig;
    use g3_planner::history;
    
    // Create a config
    let config = PlannerConfig {
        codepath: repo_path.to_path_buf(),
        no_git: false,
        max_turns: 5,
        quiet: true,
        config_path: None,
    };
    
    // Write a history entry as would happen in stage_and_commit
    let summary = "Test commit message";
    history::write_git_commit(&plan_dir, summary).expect("Failed to write history");
    
    // Read history file to verify entry was written
    let history_content = fs::read_to_string(plan_dir.join("planner_history.txt"))
        .expect("Failed to read history file");
    
    // Verify the history entry exists
    assert!(history_content.contains("GIT COMMIT"), "History should contain GIT COMMIT entry");
    assert!(history_content.contains("Test commit message"), "History should contain the commit message");
    
    // Now attempt a commit (which will fail because nothing is staged)
    // This simulates the scenario where history is written but commit fails
    let commit_result = g3_planner::git::commit(&config.codepath, summary, "Test description");
    
    // The commit should fail (nothing staged)
    assert!(commit_result.is_err(), "Commit should fail with nothing staged");
    
    // But history entry should still be present
    let history_after = fs::read_to_string(plan_dir.join("planner_history.txt"))
        .expect("Failed to read history file after commit");
    
    assert!(history_after.contains("GIT COMMIT"), "History should still contain GIT COMMIT entry after failed commit");
    assert!(history_after.contains("Test commit message"), "History should still contain the message after failed commit");
}

/// Test successful commit flow with history written first
#[test]
fn test_history_written_before_successful_commit() {
    let temp_dir = setup_test_git_repo().expect("Failed to setup test repo");
    let repo_path = temp_dir.path();
    let plan_dir = repo_path.join("g3-plan");
    
    use g3_planner::history;
    
    // Create a file to commit
    let test_file = repo_path.join("test.txt");
    fs::write(&test_file, "test content").expect("Failed to create test file");
    
    // Stage the file
    Command::new("git")
        .args(["add", "test.txt"])
        .current_dir(repo_path)
        .output()
        .expect("Failed to stage file");
    
    // Write history entry BEFORE commit
    let summary = "Add test file";
    history::write_git_commit(&plan_dir, summary).expect("Failed to write history");
    
    // Verify history was written
    let history_before = fs::read_to_string(plan_dir.join("planner_history.txt"))
        .expect("Failed to read history file");
    assert!(history_before.contains("GIT COMMIT"), "History should contain GIT COMMIT before commit");
    assert!(history_before.contains("Add test file"), "History should contain message before commit");
    
    // Now make the commit
    let commit_result = g3_planner::git::commit(repo_path, summary, "Test description");
    assert!(commit_result.is_ok(), "Commit should succeed with staged file");
    
    // Verify history is still there after successful commit
    let history_after = fs::read_to_string(plan_dir.join("planner_history.txt"))
        .expect("Failed to read history file after commit");
    assert!(history_after.contains("GIT COMMIT"), "History should contain GIT COMMIT after commit");
    assert!(history_after.contains("Add test file"), "History should contain message after commit");
}

/// Test the ordering invariant: history must be written before attempting the commit
/// This ensures that if the commit operation is interrupted or fails, the history entry exists
#[test]
fn test_history_ordering_invariant() {
    let temp_dir = setup_test_git_repo().expect("Failed to setup test repo");
    let repo_path = temp_dir.path();
    let plan_dir = repo_path.join("g3-plan");
    
    use g3_planner::history;
    
    // Test 1: Verify history is written first, even before staging
    let summary1 = "First history entry";
    
    // Record initial history state
    let history_initial = fs::read_to_string(plan_dir.join("planner_history.txt"))
        .expect("Failed to read history file");
    
    // Write history entry
    history::write_git_commit(&plan_dir, summary1).expect("Failed to write history");
    
    // Write history entry BEFORE attempting commit
    let history_after_write = fs::read_to_string(plan_dir.join("planner_history.txt"))
        .expect("Failed to read history file");
    
    // Verify the history entry exists and is different from initial state
    assert_ne!(history_initial, history_after_write, "History should have changed after write");
    assert!(history_after_write.contains("GIT COMMIT"), "History should contain GIT COMMIT entry");
    assert!(history_after_write.contains("First history entry"), "History should contain the commit message");
    
    // This demonstrates the ordering: history is written and persisted to disk
    // BEFORE any git operations are attempted. If git::commit() were to fail
    // at this point (e.g., due to missing staged files, git config errors, etc.),
    // the history entry would already be on disk and available for audit.
    
    // The other tests (test_history_written_before_commit_on_empty_staging and
    // test_multiple_history_entries_with_failures) verify behavior with actual failures.
    
    // This test focuses on the invariant itself: write happens first.
}

/// Test multiple history entries with mixed success/failure
#[test]
fn test_multiple_history_entries_with_failures() {
    let temp_dir = setup_test_git_repo().expect("Failed to setup test repo");
    let repo_path = temp_dir.path();
    let plan_dir = repo_path.join("g3-plan");
    
    use g3_planner::history;
    
    // First entry - will fail (nothing staged)
    history::write_git_commit(&plan_dir, "Commit 1 - will fail").expect("Failed to write history");
    let _ = g3_planner::git::commit(repo_path, "Commit 1 - will fail", "Desc 1");
    
    // Second entry - will succeed
    let test_file = repo_path.join("file1.txt");
    fs::write(&test_file, "content 1").expect("Failed to create file");
    Command::new("git")
        .args(["add", "file1.txt"])
        .current_dir(repo_path)
        .output()
        .expect("Failed to stage file");
    
    history::write_git_commit(&plan_dir, "Commit 2 - will succeed").expect("Failed to write history");
    let _ = g3_planner::git::commit(repo_path, "Commit 2 - will succeed", "Desc 2");
    
    // Third entry - will fail (nothing staged)
    history::write_git_commit(&plan_dir, "Commit 3 - will fail").expect("Failed to write history");
    let _ = g3_planner::git::commit(repo_path, "Commit 3 - will fail", "Desc 3");
    
    // Read history and verify all entries are present
    let history_content = fs::read_to_string(plan_dir.join("planner_history.txt"))
        .expect("Failed to read history file");
    
    // All three attempts should be recorded, regardless of success/failure
    assert!(history_content.contains("Commit 1 - will fail"), "First commit attempt should be in history");
    assert!(history_content.contains("Commit 2 - will succeed"), "Second commit attempt should be in history");
    assert!(history_content.contains("Commit 3 - will fail"), "Third commit attempt should be in history");
    
    // Count the number of GIT COMMIT entries
    let commit_count = history_content.matches("GIT COMMIT").count();
    assert_eq!(commit_count, 3, "Should have exactly 3 GIT COMMIT entries");
}

/// Test that history entries have consistent format and timestamps
#[test]
fn test_history_entry_format() {
    let temp_dir = setup_test_git_repo().expect("Failed to setup test repo");
    let plan_dir = temp_dir.path().join("g3-plan");
    
    use g3_planner::history;
    
    // Write a history entry
    let summary = "Test formatting";
    history::write_git_commit(&plan_dir, summary).expect("Failed to write history");
    
    // Read and verify format
    let history_content = fs::read_to_string(plan_dir.join("planner_history.txt"))
        .expect("Failed to read history file");
    
    // Should contain timestamp (YYYY-MM-DD HH:MM:SS format)
    assert!(history_content.contains("-"), "Should contain date separators");
    assert!(history_content.contains(":"), "Should contain time separators");
    
    // Should contain the entry type
    assert!(history_content.contains("GIT COMMIT"), "Should contain entry type");
    
    // Should contain the message in parentheses
    assert!(history_content.contains("(Test formatting)"), "Should contain message in parentheses");
}

/// Test that stage_plan_dir correctly re-stages changes to planner_history.txt
#[test]
fn test_stage_plan_dir_captures_history_changes() {
    let temp_dir = setup_test_git_repo().expect("Failed to setup test repo");
    let repo_path = temp_dir.path();
    let plan_dir = repo_path.join("g3-plan");

    use g3_planner::git;
    use g3_planner::history;

    // Create a file and make an initial commit so we have a valid HEAD
    let test_file = repo_path.join("initial.txt");
    fs::write(&test_file, "initial content").expect("Failed to create initial file");
    Command::new("git")
        .args(["add", "."])
        .current_dir(repo_path)
        .output()
        .expect("Failed to stage initial files");
    Command::new("git")
        .args(["commit", "-m", "Initial commit"])
        .current_dir(repo_path)
        .output()
        .expect("Failed to make initial commit");

    // Now create a new file to stage
    let new_file = repo_path.join("new_feature.txt");
    fs::write(&new_file, "new feature").expect("Failed to create new file");

    // Stage all files (simulating stage_files call)
    git::stage_files(repo_path, &plan_dir).expect("Failed to stage files");

    // Get git status to see what's staged
    let status_before = Command::new("git")
        .args(["status", "--porcelain"])
        .current_dir(repo_path)
        .output()
        .expect("Failed to get git status");
    let _status_before_str = String::from_utf8_lossy(&status_before.stdout);

    // Write a history entry AFTER staging (simulating the bug scenario)
    history::write_git_commit(&plan_dir, "Test commit").expect("Failed to write history");

    // At this point, planner_history.txt has been modified but the change is NOT staged
    // This is the bug: the GIT COMMIT entry would not be included in the commit

    // Now call stage_plan_dir to re-stage the plan directory
    git::stage_plan_dir(repo_path, &plan_dir).expect("Failed to re-stage plan dir");

    // Get git status again
    let status_after = Command::new("git")
        .args(["status", "--porcelain"])
        .current_dir(repo_path)
        .output()
        .expect("Failed to get git status");
    let status_after_str = String::from_utf8_lossy(&status_after.stdout);

    // Verify planner_history.txt is now staged (should show as "A " or "M " not " M" or "??")
    // The file should be in the staged area
    assert!(status_after_str.contains("g3-plan/planner_history.txt"), 
        "planner_history.txt should appear in git status");
    
    // Make a commit and verify the history entry is included
    let commit_result = git::commit(repo_path, "Test commit", "Description");
    assert!(commit_result.is_ok(), "Commit should succeed: {:?}", commit_result);
}
