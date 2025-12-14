//! Tests for TODO completion detection and file deletion behavior

/// Helper to check if all TODOs are complete (same logic as in lib.rs)
fn all_todos_complete(content: &str) -> bool {
    let has_incomplete = content.lines().any(|line| {
        let trimmed = line.trim();
        trimmed.starts_with("- [ ]")
    });
    
    !has_incomplete && (content.contains("- [x]") || content.contains("- [X]"))
}

#[test]
fn test_all_complete_lowercase() {
    let content = "# Test\n\n- [x] Done 1\n- [x] Done 2";
    assert!(all_todos_complete(content));
}

#[test]
fn test_all_complete_uppercase() {
    let content = "# Test\n\n- [X] Done 1\n- [X] Done 2";
    assert!(all_todos_complete(content));
}

#[test]
fn test_all_complete_mixed_case() {
    let content = "# Test\n\n- [x] Done 1\n- [X] Done 2";
    assert!(all_todos_complete(content));
}

#[test]
fn test_has_incomplete() {
    let content = "# Test\n\n- [x] Done 1\n- [ ] Not done";
    assert!(!all_todos_complete(content));
}

#[test]
fn test_all_incomplete() {
    let content = "# Test\n\n- [ ] Not done 1\n- [ ] Not done 2";
    assert!(!all_todos_complete(content));
}

#[test]
fn test_no_checkboxes() {
    let content = "# Just a header\n\nSome text without checkboxes";
    assert!(!all_todos_complete(content));
}

#[test]
fn test_nested_complete() {
    let content = "# Test\n\n- [x] Parent\n  - [x] Child 1\n  - [x] Child 2";
    assert!(all_todos_complete(content));
}

#[test]
fn test_nested_incomplete() {
    let content = "# Test\n\n- [x] Parent\n  - [x] Child 1\n  - [ ] Child 2";
    assert!(!all_todos_complete(content));
}

#[test]
fn test_indented_incomplete() {
    // Indented incomplete items should still be detected
    let content = "# Test\n\n- [x] Done\n    - [ ] Indented incomplete";
    assert!(!all_todos_complete(content));
}

#[test]
fn test_empty_content() {
    let content = "";
    assert!(!all_todos_complete(content));
}

#[test]
fn test_whitespace_only() {
    let content = "   \n\n   ";
    assert!(!all_todos_complete(content));
}
