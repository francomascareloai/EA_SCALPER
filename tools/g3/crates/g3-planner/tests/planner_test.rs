//! Integration tests for g3-planner

use g3_planner::{create_tool_message, explore_codebase, extract_shell_commands};
use g3_providers::MessageRole;

#[test]
fn test_create_tool_message_format() {
    let msg = create_tool_message("shell", "ls -la");

    assert!(matches!(msg.role, MessageRole::Assistant));

    let parsed: serde_json::Value = serde_json::from_str(&msg.content).unwrap();
    assert_eq!(parsed["tool"], "shell");
    assert_eq!(parsed["args"]["command"], "ls -la");
}

#[test]
fn test_explore_codebase_returns_report() {
    // Test with current directory (should find Rust files in g3 project)
    let report = explore_codebase(".");

    // Should return a non-empty report
    assert!(!report.is_empty(), "Report should not be empty");

    // Should contain the codebase analysis header
    assert!(
        report.contains("CODEBASE ANALYSIS") || report.contains("No recognized"),
        "Report should have analysis header or indicate no languages found"
    );
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
fn test_extract_shell_commands_multiple_code_blocks() {
    let response = r#"
{{CODE EXPLORATION COMMANDS}}

```bash
ls -la
```

Some explanation text.

```
cat README.md
head -50 src/main.rs
```
"#;

    let commands = extract_shell_commands(response);
    assert_eq!(commands.len(), 3);
    assert_eq!(commands[0], "ls -la");
    assert_eq!(commands[1], "cat README.md");
    assert_eq!(commands[2], "head -50 src/main.rs");
}
