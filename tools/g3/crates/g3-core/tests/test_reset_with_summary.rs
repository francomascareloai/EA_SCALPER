//! Tests for reset_with_summary to ensure system prompt is preserved after compaction

use g3_core::ContextWindow;
use g3_providers::{Message, MessageRole};

/// Test that reset_with_summary preserves the original system prompt
#[test]
fn test_reset_with_summary_preserves_system_prompt() {
    let mut context = ContextWindow::new(10000);

    // Add the system prompt as the first message (simulating agent initialization)
    let system_prompt = "You are G3, an AI programming agent...";
    context.add_message(Message::new(MessageRole::System, system_prompt.to_string()));

    // Add some conversation history
    context.add_message(Message::new(MessageRole::User, "Task: Write a function".to_string()));
    context.add_message(Message::new(MessageRole::Assistant, "I'll help you write that function.".to_string()));
    context.add_message(Message::new(MessageRole::User, "Thanks, now add tests".to_string()));
    context.add_message(Message::new(MessageRole::Assistant, "Here are the tests.".to_string()));

    // Verify we have 5 messages before reset
    assert_eq!(context.conversation_history.len(), 5);

    // Reset with summary
    let summary = "We discussed writing a function and adding tests.".to_string();
    let latest_user_msg = Some("Continue with the implementation".to_string());
    context.reset_with_summary(summary, latest_user_msg);

    // Verify the first message is still the system prompt
    assert!(!context.conversation_history.is_empty(), "Conversation history should not be empty");
    
    let first_message = &context.conversation_history[0];
    assert!(
        matches!(first_message.role, MessageRole::System),
        "First message should be a System message, got {:?}",
        first_message.role
    );
    assert!(
        first_message.content.contains("You are G3"),
        "First message should contain the system prompt 'You are G3', got: {}",
        &first_message.content[..first_message.content.len().min(100)]
    );

    // Verify the summary was added as a separate system message
    let has_summary = context.conversation_history.iter().any(|m| {
        matches!(m.role, MessageRole::System) && m.content.contains("Previous conversation summary")
    });
    assert!(has_summary, "Should have a summary message");

    // Verify the latest user message was added
    let has_user_msg = context.conversation_history.iter().any(|m| {
        matches!(m.role, MessageRole::User) && m.content.contains("Continue with the implementation")
    });
    assert!(has_user_msg, "Should have the latest user message");
}

/// Test that reset_with_summary preserves README message if present
#[test]
fn test_reset_with_summary_preserves_readme() {
    let mut context = ContextWindow::new(10000);

    // Add the system prompt as the first message
    let system_prompt = "You are G3, an AI programming agent...";
    context.add_message(Message::new(MessageRole::System, system_prompt.to_string()));

    // Add README as second system message
    let readme_content = "# Project README\n\nThis is a test project.";
    context.add_message(Message::new(MessageRole::System, readme_content.to_string()));

    // Add some conversation history
    context.add_message(Message::new(MessageRole::User, "Task: Write a function".to_string()));
    context.add_message(Message::new(MessageRole::Assistant, "Done.".to_string()));

    // Verify we have 4 messages before reset
    assert_eq!(context.conversation_history.len(), 4);

    // Reset with summary
    let summary = "We wrote a function.".to_string();
    context.reset_with_summary(summary, None);

    // Verify the first message is still the system prompt
    let first_message = &context.conversation_history[0];
    assert!(
        first_message.content.contains("You are G3"),
        "First message should be the system prompt"
    );

    // Verify the README was preserved as the second message
    let second_message = &context.conversation_history[1];
    assert!(
        matches!(second_message.role, MessageRole::System),
        "Second message should be a System message"
    );
    assert!(
        second_message.content.contains("Project README"),
        "Second message should be the README"
    );
}

/// Test that reset_with_summary works when there's no README
#[test]
fn test_reset_with_summary_without_readme() {
    let mut context = ContextWindow::new(10000);

    // Add only the system prompt (no README)
    let system_prompt = "You are G3, an AI programming agent...";
    context.add_message(Message::new(MessageRole::System, system_prompt.to_string()));

    // Add conversation without README
    context.add_message(Message::new(MessageRole::User, "Hello".to_string()));
    context.add_message(Message::new(MessageRole::Assistant, "Hi there!".to_string()));

    // Reset with summary
    let summary = "Greeted the user.".to_string();
    context.reset_with_summary(summary, None);

    // Verify the first message is still the system prompt
    let first_message = &context.conversation_history[0];
    assert!(
        first_message.content.contains("You are G3"),
        "First message should be the system prompt"
    );

    // Verify we have system prompt + summary (no README)
    // The second message should be the summary, not a README
    let second_message = &context.conversation_history[1];
    assert!(
        second_message.content.contains("Previous conversation summary"),
        "Second message should be the summary when no README exists"
    );
}

/// Test that reset_with_summary handles Agent Configuration in addition to README
#[test]
fn test_reset_with_summary_preserves_agent_configuration() {
    let mut context = ContextWindow::new(10000);

    // Add the system prompt as the first message
    let system_prompt = "You are G3, an AI programming agent...";
    context.add_message(Message::new(MessageRole::System, system_prompt.to_string()));

    // Add Agent Configuration as second system message
    let agents_content = "# Agent Configuration\n\nSpecial instructions for this project.";
    context.add_message(Message::new(MessageRole::System, agents_content.to_string()));

    // Add some conversation history
    context.add_message(Message::new(MessageRole::User, "Task: Do something".to_string()));

    // Reset with summary
    let summary = "Did something.".to_string();
    context.reset_with_summary(summary, None);

    // Verify the Agent Configuration was preserved
    let second_message = &context.conversation_history[1];
    assert!(
        second_message.content.contains("Agent Configuration"),
        "Second message should be the Agent Configuration"
    );
}
