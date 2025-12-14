//! Tests for verifying system message loading with README content
//!
//! This test verifies that when a README is present, the system message
//! is correctly loaded and structured in the context window.

use g3_core::ContextWindow;
use g3_providers::{Message, MessageRole};

/// Test that system prompt is always the first message
#[test]
fn test_system_prompt_is_first_message() {
    let mut context = ContextWindow::new(10000);

    // Simulate agent initialization: system prompt first
    let system_prompt = "You are G3, an AI programming agent of the same skill level...";
    context.add_message(Message::new(MessageRole::System, system_prompt.to_string()));

    // Verify the first message is the system prompt
    assert!(!context.conversation_history.is_empty());
    let first_message = &context.conversation_history[0];
    assert!(
        matches!(first_message.role, MessageRole::System),
        "First message should be a System message"
    );
    assert!(
        first_message.content.contains("You are G3"),
        "First message should contain the system prompt"
    );
}

/// Test that README is added as the second system message after the system prompt
#[test]
fn test_readme_is_second_message_after_system_prompt() {
    let mut context = ContextWindow::new(10000);

    // Simulate agent initialization: system prompt first
    let system_prompt = "You are G3, an AI programming agent of the same skill level...";
    context.add_message(Message::new(MessageRole::System, system_prompt.to_string()));

    // Add README as second system message (simulating what Agent::new_with_readme does)
    let readme_content = "📚 Project README (from README.md):\n\n# My Project\n\nThis is a test project.";
    context.add_message(Message::new(MessageRole::System, readme_content.to_string()));

    // Verify we have 2 messages
    assert_eq!(context.conversation_history.len(), 2);

    // Verify the first message is the system prompt
    let first_message = &context.conversation_history[0];
    assert!(
        matches!(first_message.role, MessageRole::System),
        "First message should be a System message"
    );
    assert!(
        first_message.content.contains("You are G3"),
        "First message should contain the system prompt"
    );

    // Verify the second message is the README
    let second_message = &context.conversation_history[1];
    assert!(
        matches!(second_message.role, MessageRole::System),
        "Second message should be a System message"
    );
    assert!(
        second_message.content.contains("Project README"),
        "Second message should contain the README content"
    );
    assert!(
        second_message.content.contains("My Project"),
        "Second message should contain the actual README content"
    );
}

/// Test that system prompt and README are separate messages (not combined)
#[test]
fn test_system_prompt_and_readme_are_separate() {
    let mut context = ContextWindow::new(10000);

    // Simulate agent initialization
    let system_prompt = "You are G3, an AI programming agent...";
    context.add_message(Message::new(MessageRole::System, system_prompt.to_string()));

    let readme_content = "📚 Project README (from README.md):\n\n# Test Project";
    context.add_message(Message::new(MessageRole::System, readme_content.to_string()));

    // Verify they are separate messages
    assert_eq!(context.conversation_history.len(), 2);

    // First message should NOT contain README
    let first_message = &context.conversation_history[0];
    assert!(
        !first_message.content.contains("Project README"),
        "System prompt should not contain README content"
    );

    // Second message should NOT contain system prompt
    let second_message = &context.conversation_history[1];
    assert!(
        !second_message.content.contains("You are G3"),
        "README message should not contain system prompt"
    );
}

/// Test that TODO is added as third message after system prompt and README
#[test]
fn test_todo_is_third_message_after_readme() {
    let mut context = ContextWindow::new(10000);

    // Simulate agent initialization order:
    // 1. System prompt
    let system_prompt = "You are G3, an AI programming agent...";
    context.add_message(Message::new(MessageRole::System, system_prompt.to_string()));

    // 2. README
    let readme_content = "📚 Project README (from README.md):\n\n# Test Project";
    context.add_message(Message::new(MessageRole::System, readme_content.to_string()));

    // 3. TODO (if present)
    let todo_content = "📋 Existing TODO list (from todo.g3.md):\n\n- [ ] Task 1\n- [x] Task 2";
    context.add_message(Message::new(MessageRole::System, todo_content.to_string()));

    // Verify we have 3 messages
    assert_eq!(context.conversation_history.len(), 3);

    // Verify order
    assert!(
        context.conversation_history[0].content.contains("You are G3"),
        "First message should be system prompt"
    );
    assert!(
        context.conversation_history[1].content.contains("Project README"),
        "Second message should be README"
    );
    assert!(
        context.conversation_history[2].content.contains("TODO list"),
        "Third message should be TODO"
    );
}

/// Test that AGENTS.md content is combined with README in the same message
#[test]
fn test_agents_and_readme_combined() {
    let mut context = ContextWindow::new(10000);

    // Simulate agent initialization
    let system_prompt = "You are G3, an AI programming agent...";
    context.add_message(Message::new(MessageRole::System, system_prompt.to_string()));

    // Combined AGENTS.md and README.md content (as done in g3-cli)
    let combined_content = "# Agent Configuration\n\nSpecial instructions.\n\n# Project README\n\nProject description.";
    context.add_message(Message::new(MessageRole::System, combined_content.to_string()));

    // Verify we have 2 messages
    assert_eq!(context.conversation_history.len(), 2);

    // Verify the second message contains both AGENTS and README
    let second_message = &context.conversation_history[1];
    assert!(
        second_message.content.contains("Agent Configuration"),
        "Combined message should contain AGENTS.md content"
    );
    assert!(
        second_message.content.contains("Project README"),
        "Combined message should contain README content"
    );
}

/// Test that user messages come after system messages
#[test]
fn test_user_messages_after_system_messages() {
    let mut context = ContextWindow::new(10000);

    // Simulate agent initialization
    let system_prompt = "You are G3, an AI programming agent...";
    context.add_message(Message::new(MessageRole::System, system_prompt.to_string()));

    let readme_content = "📚 Project README (from README.md):\n\n# Test Project";
    context.add_message(Message::new(MessageRole::System, readme_content.to_string()));

    // Add user message
    let user_message = "Please help me with this task.";
    context.add_message(Message::new(MessageRole::User, user_message.to_string()));

    // Verify order
    assert_eq!(context.conversation_history.len(), 3);
    assert!(matches!(context.conversation_history[0].role, MessageRole::System));
    assert!(matches!(context.conversation_history[1].role, MessageRole::System));
    assert!(matches!(context.conversation_history[2].role, MessageRole::User));
}

/// Test that empty README content is not added
#[test]
fn test_empty_readme_not_added() {
    let mut context = ContextWindow::new(10000);

    // Simulate agent initialization
    let system_prompt = "You are G3, an AI programming agent...";
    context.add_message(Message::new(MessageRole::System, system_prompt.to_string()));

    // Try to add empty README (should be skipped due to empty content check)
    let empty_readme = "   "; // whitespace only
    context.add_message(Message::new(MessageRole::System, empty_readme.to_string()));

    // Verify only system prompt was added (empty message should be skipped)
    assert_eq!(
        context.conversation_history.len(),
        1,
        "Empty README should not be added to conversation history"
    );
}

/// Test the reload_readme detection logic
#[test]
fn test_readme_detection_for_reload() {
    let mut context = ContextWindow::new(10000);

    // Simulate agent initialization
    let system_prompt = "You are G3, an AI programming agent...";
    context.add_message(Message::new(MessageRole::System, system_prompt.to_string()));

    // Add README with expected markers
    let readme_content = "# Project README\n\nThis is the project description.";
    context.add_message(Message::new(MessageRole::System, readme_content.to_string()));

    // Check if the second message (index 1) is a README
    let has_readme = context
        .conversation_history
        .get(1)
        .map(|m| {
            matches!(m.role, MessageRole::System)
                && (m.content.contains("Project README")
                    || m.content.contains("Agent Configuration"))
        })
        .unwrap_or(false);

    assert!(has_readme, "Should detect README at index 1");
}

/// Test that README detection fails when no README is present
#[test]
fn test_readme_detection_without_readme() {
    let mut context = ContextWindow::new(10000);

    // Simulate agent initialization without README
    let system_prompt = "You are G3, an AI programming agent...";
    context.add_message(Message::new(MessageRole::System, system_prompt.to_string()));

    // Add a user message directly (no README)
    context.add_message(Message::new(MessageRole::User, "Hello".to_string()));

    // Check if the second message (index 1) is a README
    let has_readme = context
        .conversation_history
        .get(1)
        .map(|m| {
            matches!(m.role, MessageRole::System)
                && (m.content.contains("Project README")
                    || m.content.contains("Agent Configuration"))
        })
        .unwrap_or(false);

    assert!(!has_readme, "Should not detect README when none exists");
}
