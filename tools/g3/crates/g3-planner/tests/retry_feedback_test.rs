//! Integration tests for retry logic and feedback extraction in planning mode
//!
//! These tests verify that the retry infrastructure and coach feedback extraction
//! work correctly together, without requiring actual API calls.

use g3_core::feedback_extraction::{ExtractedFeedback, FeedbackExtractionConfig, FeedbackSource};
use g3_core::retry::RetryConfig;

#[test]
fn test_retry_config_for_planning_player() {
    let config = RetryConfig::planning("player");
    assert_eq!(config.max_retries, 3);
    assert!(config.is_autonomous);
    assert_eq!(config.role_name, "player");
}

#[test]
fn test_retry_config_for_planning_coach() {
    let config = RetryConfig::planning("coach");
    assert_eq!(config.max_retries, 3);
    assert!(config.is_autonomous);
    assert_eq!(config.role_name, "coach");
}

#[test]
fn test_retry_config_with_custom_max_retries() {
    let config = RetryConfig::planning("player").with_max_retries(6);
    assert_eq!(config.max_retries, 6);
    assert!(config.is_autonomous);
    assert_eq!(config.role_name, "player");
}

#[test]
fn test_retry_config_default() {
    let config = RetryConfig::default();
    assert_eq!(config.max_retries, 3);
    assert!(!config.is_autonomous);
    assert_eq!(config.role_name, "agent");
}

#[test]
fn test_retry_config_player_preset() {
    let config = RetryConfig::player();
    assert_eq!(config.max_retries, 3);
    assert!(config.is_autonomous);
    assert_eq!(config.role_name, "player");
}

#[test]
fn test_retry_config_coach_preset() {
    let config = RetryConfig::coach();
    assert_eq!(config.max_retries, 3);
    assert!(config.is_autonomous);
    assert_eq!(config.role_name, "coach");
}

#[test]
fn test_extracted_feedback_approval_detection() {
    let approved = ExtractedFeedback::new(
        "Great work! IMPLEMENTATION_APPROVED".to_string(),
        FeedbackSource::NativeToolCall,
    );
    assert!(approved.is_approved());
    assert!(!approved.is_fallback());

    let not_approved = ExtractedFeedback::new(
        "Please fix the issues".to_string(),
        FeedbackSource::NativeToolCall,
    );
    assert!(!not_approved.is_approved());
    assert!(!not_approved.is_fallback());

    let fallback = ExtractedFeedback::new(
        "Default feedback".to_string(),
        FeedbackSource::DefaultFallback,
    );
    assert!(!fallback.is_approved());
    assert!(fallback.is_fallback());
}

#[test]
fn test_feedback_extraction_config_default() {
    let config = FeedbackExtractionConfig::default();
    assert!(!config.verbose);
    assert!(config.logs_dir.is_none());
    assert!(config.default_feedback.contains("review"));
}

#[test]
fn test_feedback_extraction_config_custom() {
    let config = FeedbackExtractionConfig {
        verbose: true,
        logs_dir: Some(std::path::PathBuf::from("/tmp/test_logs")),
        default_feedback: "Custom fallback message for testing".to_string(),
    };
    assert!(config.verbose);
    assert_eq!(
        config.logs_dir,
        Some(std::path::PathBuf::from("/tmp/test_logs"))
    );
    assert!(config.default_feedback.contains("Custom fallback"));
}

#[test]
fn test_feedback_source_variants() {
    // Verify all feedback sources are distinguishable
    let sources = vec![
        FeedbackSource::SessionLog,
        FeedbackSource::NativeToolCall,
        FeedbackSource::ConversationHistory,
        FeedbackSource::TaskResultResponse,
        FeedbackSource::DefaultFallback,
    ];

    for (i, source1) in sources.iter().enumerate() {
        for (j, source2) in sources.iter().enumerate() {
            if i == j {
                assert_eq!(source1, source2);
            } else {
                assert_ne!(source1, source2);
            }
        }
    }
}

#[test]
fn test_retry_configs_for_planning_mode_are_autonomous() {
    // Both player and coach should be marked as autonomous for planning mode
    let player = RetryConfig::planning("player");
    let coach = RetryConfig::planning("coach");

    assert!(
        player.is_autonomous,
        "Player should be autonomous in planning mode"
    );
    assert!(
        coach.is_autonomous,
        "Coach should be autonomous in planning mode"
    );
}

#[test]
fn test_extracted_feedback_new() {
    let feedback = ExtractedFeedback::new(
        "Test content".to_string(),
        FeedbackSource::SessionLog,
    );
    assert_eq!(feedback.content, "Test content");
    assert_eq!(feedback.source, FeedbackSource::SessionLog);
}

#[test]
fn test_extracted_feedback_approval_variations() {
    // Test various approval message formats
    let cases = vec![
        ("IMPLEMENTATION_APPROVED", true),
        ("IMPLEMENTATION_APPROVED - great work!", true),
        ("All done. IMPLEMENTATION_APPROVED", true),
        ("implementation_approved", false), // Case sensitive
        ("APPROVED", false),                // Must be exact phrase
        ("Please fix these issues", false),
        ("", false),
    ];

    for (content, expected_approved) in cases {
        let feedback = ExtractedFeedback::new(content.to_string(), FeedbackSource::SessionLog);
        assert_eq!(
            feedback.is_approved(),
            expected_approved,
            "Failed for content: '{}'",
            content
        );
    }
}

#[test]
fn test_feedback_source_fallback_detection() {
    // Only DefaultFallback should be detected as fallback
    let sources_and_expected = vec![
        (FeedbackSource::SessionLog, false),
        (FeedbackSource::NativeToolCall, false),
        (FeedbackSource::ConversationHistory, false),
        (FeedbackSource::TaskResultResponse, false),
        (FeedbackSource::DefaultFallback, true),
    ];

    for (source, expected_is_fallback) in sources_and_expected {
        let feedback = ExtractedFeedback::new("Test".to_string(), source.clone());
        assert_eq!(
            feedback.is_fallback(),
            expected_is_fallback,
            "Failed for source: {:?}",
            source
        );
    }
}

#[test]
fn test_retry_config_chaining() {
    // Test that with_max_retries can be chained
    let config = RetryConfig::planning("player")
        .with_max_retries(10)
        .with_max_retries(5);
    
    assert_eq!(config.max_retries, 5);
    assert!(config.is_autonomous);
    assert_eq!(config.role_name, "player");
}
