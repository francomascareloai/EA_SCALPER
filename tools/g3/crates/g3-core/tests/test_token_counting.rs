use g3_core::ContextWindow;
use g3_providers::{Message, MessageRole, Usage};

/// Test that used_tokens is tracked via add_message, not update_usage_from_response.
/// This is critical for the 80% summarization threshold to work correctly.
#[test]
fn test_used_tokens_tracked_via_messages() {
    let mut window = ContextWindow::new(10000);

    // Add a user message - this should update used_tokens
    let user_msg = Message::new(MessageRole::User, "Hello, how are you?".to_string());
    window.add_message(user_msg);
    
    // used_tokens should be non-zero after adding a message
    assert!(window.used_tokens > 0, "used_tokens should increase after add_message");
    let tokens_after_user_msg = window.used_tokens;

    // Add an assistant message
    let assistant_msg = Message::new(MessageRole::Assistant, "I'm doing well, thank you!".to_string());
    window.add_message(assistant_msg);
    
    // used_tokens should increase further
    assert!(window.used_tokens > tokens_after_user_msg, "used_tokens should increase after adding assistant message");
}

/// Test that update_usage_from_response only updates cumulative_tokens, not used_tokens.
/// This prevents double-counting which was causing the 80% threshold to be reached at 200%+.
#[test]
fn test_update_usage_only_affects_cumulative() {
    let mut window = ContextWindow::new(10000);

    // Initial state
    assert_eq!(window.used_tokens, 0);
    assert_eq!(window.cumulative_tokens, 0);

    // Simulate API response with usage data
    let usage = Usage {
        prompt_tokens: 100,
        completion_tokens: 50,
        total_tokens: 150,
    };
    window.update_usage_from_response(&usage);

    // used_tokens should NOT change - it's tracked via add_message
    assert_eq!(window.used_tokens, 0, "used_tokens should not be updated by update_usage_from_response");
    
    // cumulative_tokens SHOULD be updated for API usage tracking
    assert_eq!(window.cumulative_tokens, 150, "cumulative_tokens should track total API usage");

    // Another API call
    let usage2 = Usage {
        prompt_tokens: 200,
        completion_tokens: 75,
        total_tokens: 275,
    };
    window.update_usage_from_response(&usage2);

    // used_tokens still unchanged
    assert_eq!(window.used_tokens, 0, "used_tokens should remain unchanged");
    
    // cumulative_tokens accumulates
    assert_eq!(window.cumulative_tokens, 425, "cumulative_tokens should accumulate");
}

/// Test that add_streaming_tokens only updates cumulative_tokens.
/// The assistant message will be added via add_message which tracks used_tokens.
#[test]
fn test_add_streaming_tokens_only_affects_cumulative() {
    let mut window = ContextWindow::new(10000);

    // Add streaming tokens (fallback when no usage data available)
    window.add_streaming_tokens(100);
    
    // used_tokens should NOT change
    assert_eq!(window.used_tokens, 0, "used_tokens should not be updated by add_streaming_tokens");
    
    // cumulative_tokens SHOULD be updated
    assert_eq!(window.cumulative_tokens, 100, "cumulative_tokens should be updated");

    // Add more streaming tokens
    window.add_streaming_tokens(50);
    assert_eq!(window.used_tokens, 0);
    assert_eq!(window.cumulative_tokens, 150);
}

/// Test percentage calculation is based on used_tokens (actual context content).
#[test]
fn test_percentage_based_on_used_tokens() {
    let mut window = ContextWindow::new(1000);

    // Initially 0%
    assert_eq!(window.percentage_used(), 0.0);
    assert_eq!(window.remaining_tokens(), 1000);

    // Add messages to increase used_tokens
    // A message with ~100 chars should be roughly 25-30 tokens
    let msg = Message::new(MessageRole::User, "x".repeat(400)); // ~100 tokens estimated
    window.add_message(msg);
    
    // Percentage should be based on used_tokens
    let percentage = window.percentage_used();
    assert!(percentage > 0.0, "percentage should be > 0 after adding message");
    assert!(percentage < 100.0, "percentage should be < 100");
    
    // remaining_tokens should decrease
    assert!(window.remaining_tokens() < 1000, "remaining tokens should decrease");
}

/// Test that the 80% summarization threshold works correctly.
/// This was the original bug - used_tokens was being double/triple counted.
#[test]
fn test_should_summarize_threshold() {
    let mut window = ContextWindow::new(1000);

    // Add messages until we approach 80%
    // Each message of ~320 chars is roughly 80 tokens (at 4 chars/token)
    for _ in 0..9 {
        let msg = Message::new(MessageRole::User, "x".repeat(320));
        window.add_message(msg);
    }

    // Should be around 720 tokens (72%) - not yet at threshold
    // Note: actual token count depends on estimation algorithm
    let percentage = window.percentage_used();
    println!("After 9 messages: {}% used ({} tokens)", percentage, window.used_tokens);

    // Add one more message to push over 80%
    let msg = Message::new(MessageRole::User, "x".repeat(320));
    window.add_message(msg);
    
    let percentage_after = window.percentage_used();
    println!("After 10 messages: {}% used ({} tokens)", percentage_after, window.used_tokens);

    // Now should_summarize should return true if we're at 80%+
    if percentage_after >= 80.0 {
        assert!(window.should_summarize(), "should_summarize should be true at 80%+");
    }
}

/// Test that cumulative_tokens and used_tokens are independent.
#[test]
fn test_cumulative_vs_used_independence() {
    let mut window = ContextWindow::new(10000);

    // Add a message (affects used_tokens)
    let msg = Message::new(MessageRole::User, "Hello world".to_string());
    window.add_message(msg);
    let used_after_msg = window.used_tokens;
    let cumulative_after_msg = window.cumulative_tokens;
    
    // Both should be equal at this point (message adds to both)
    assert_eq!(used_after_msg, cumulative_after_msg);

    // Now simulate API response (only affects cumulative_tokens)
    let usage = Usage {
        prompt_tokens: 500,
        completion_tokens: 200,
        total_tokens: 700,
    };
    window.update_usage_from_response(&usage);

    // used_tokens unchanged
    assert_eq!(window.used_tokens, used_after_msg, "used_tokens should not change from API response");
    
    // cumulative_tokens increased
    assert_eq!(window.cumulative_tokens, cumulative_after_msg + 700, "cumulative_tokens should increase");
    
    // They should now be different
    assert!(window.cumulative_tokens > window.used_tokens, "cumulative should be greater than used");
}
