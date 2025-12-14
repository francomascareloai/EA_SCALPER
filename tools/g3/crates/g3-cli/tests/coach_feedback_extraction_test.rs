use serde_json::json;
use std::fs;
use tempfile::TempDir;

#[test]
fn test_extract_coach_feedback_with_timing_message() {
    // Create a temporary directory for logs
    let temp_dir = TempDir::new().unwrap();
    let logs_dir = temp_dir.path().join("logs");
    fs::create_dir(&logs_dir).unwrap();

    // Create a mock session log with the problematic conversation history
    // where timing message appears after the tool result
    let session_id = "test_session_123";
    let log_file_path = logs_dir.join(format!("g3_session_{}.json", session_id));

    let log_content = json!({
        "session_id": session_id,
        "context_window": {
            "conversation_history": [
                {
                    "role": "assistant",
                    "content": "{\"tool\": \"final_output\", \"args\": {\"summary\":\"IMPLEMENTATION_APPROVED\"}}"
                },
                {
                    "role": "user",
                    "content": "Tool result: IMPLEMENTATION_APPROVED"
                },
                {
                    "role": "assistant",
                    "content": "🕝 27.7s | 💭 7.5s"
                }
            ]
        }
    });

    fs::write(&log_file_path, serde_json::to_string_pretty(&log_content).unwrap()).unwrap();

    // Now test the extraction logic
    let log_content_str = fs::read_to_string(&log_file_path).unwrap();
    let log_json: serde_json::Value = serde_json::from_str(&log_content_str).unwrap();

    if let Some(context_window) = log_json.get("context_window") {
        if let Some(conversation_history) = context_window.get("conversation_history") {
            if let Some(messages) = conversation_history.as_array() {
                // This is the key logic we're testing - find the last USER message with "Tool result:"
                let last_tool_result = messages.iter().rev().find(|msg| {
                    if let Some(role) = msg.get("role") {
                        if let Some(role_str) = role.as_str() {
                            if role_str == "User" || role_str == "user" {
                                if let Some(content) = msg.get("content") {
                                    if let Some(content_str) = content.as_str() {
                                        return content_str.starts_with("Tool result:");
                                    }
                                }
                            }
                        }
                    }
                    false
                });

                // Verify we found the correct message
                assert!(last_tool_result.is_some(), "Should find the tool result message");

                if let Some(last_message) = last_tool_result {
                    if let Some(content) = last_message.get("content") {
                        if let Some(content_str) = content.as_str() {
                            let feedback = if content_str.starts_with("Tool result: ") {
                                content_str.strip_prefix("Tool result: ").unwrap_or(content_str)
                            } else {
                                content_str
                            };

                            // Verify we extracted the correct feedback
                            assert_eq!(feedback, "IMPLEMENTATION_APPROVED", "Should extract the actual feedback, not timing");
                            
                            // Verify the feedback is NOT the timing message
                            assert!(!feedback.contains("🕝"), "Feedback should not be the timing message");
                            
                            println!("✅ Successfully extracted coach feedback: {}", feedback);
                            return;
                        }
                    }
                }
            }
        }
    }

    panic!("Failed to extract coach feedback");
}

#[test]
fn test_extract_only_final_output_tool_results() {
    // Test that we only extract tool results from final_output, not from other tools
    let temp_dir = TempDir::new().unwrap();
    let logs_dir = temp_dir.path().join("logs");
    fs::create_dir(&logs_dir).unwrap();

    let session_id = "test_session_final_output_only";
    let log_file_path = logs_dir.join(format!("g3_session_{}.json", session_id));

    let log_content = json!({
        "session_id": session_id,
        "context_window": {
            "conversation_history": [
                {
                    "role": "assistant",
                    "content": "{\"tool\": \"shell\", \"args\": {\"command\":\"ls\"}}"
                },
                {
                    "role": "user",
                    "content": "Tool result: file1.txt\nfile2.txt"
                },
                {
                    "role": "assistant",
                    "content": "{\"tool\": \"read_file\", \"args\": {\"file_path\":\"test.txt\"}}"
                },
                {
                    "role": "user",
                    "content": "Tool result: This is test content"
                },
                {
                    "role": "assistant",
                    "content": "{\"tool\": \"final_output\", \"args\": {\"summary\":\"APPROVED_RESULT\"}}"
                },
                {
                    "role": "user",
                    "content": "Tool result: APPROVED_RESULT"
                },
                {
                    "role": "assistant",
                    "content": "🕝 20.5s | 💭 5.2s"
                }
            ]
        }
    });

    fs::write(&log_file_path, serde_json::to_string_pretty(&log_content).unwrap()).unwrap();

    // Test the new extraction logic that verifies the tool is final_output
    let log_content_str = fs::read_to_string(&log_file_path).unwrap();
    let log_json: serde_json::Value = serde_json::from_str(&log_content_str).unwrap();

    if let Some(context_window) = log_json.get("context_window") {
        if let Some(conversation_history) = context_window.get("conversation_history") {
            if let Some(messages) = conversation_history.as_array() {
                // Go backwards through messages to find final_output tool result
                for i in (0..messages.len()).rev() {
                    let msg = &messages[i];
                    
                    if let Some(role) = msg.get("role") {
                        if let Some(role_str) = role.as_str() {
                            if role_str == "User" || role_str == "user" {
                                if let Some(content) = msg.get("content") {
                                    if let Some(content_str) = content.as_str() {
                                        if content_str.starts_with("Tool result:") {
                                            // Check if preceding message was final_output
                                            if i > 0 {
                                                let prev_msg = &messages[i - 1];
                                                if let Some(prev_content) = prev_msg.get("content") {
                                                    if let Some(prev_content_str) = prev_content.as_str() {
                                                        if prev_content_str.contains("\"tool\": \"final_output\"") {
                                                            let feedback = content_str.strip_prefix("Tool result: ").unwrap_or(content_str);
                                                            assert_eq!(feedback, "APPROVED_RESULT", "Should extract only final_output result");
                                                            println!("✅ Correctly extracted only final_output tool result: {}", feedback);
                                                            return;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    panic!("Failed to extract final_output tool result");
}

#[test]
fn test_extract_coach_feedback_without_timing_message() {
    // Create a temporary directory for logs
    let temp_dir = TempDir::new().unwrap();
    let logs_dir = temp_dir.path().join("logs");
    fs::create_dir(&logs_dir).unwrap();

    // Test the case where there's no timing message (backward compatibility)
    let session_id = "test_session_456";
    let log_file_path = logs_dir.join(format!("g3_session_{}.json", session_id));

    let log_content = json!({
        "session_id": session_id,
        "context_window": {
            "conversation_history": [
                {
                    "role": "assistant",
                    "content": "{\"tool\": \"final_output\", \"args\": {\"summary\":\"TEST_FEEDBACK\"}}"
                },
                {
                    "role": "user",
                    "content": "Tool result: TEST_FEEDBACK"
                }
            ]
        }
    });

    fs::write(&log_file_path, serde_json::to_string_pretty(&log_content).unwrap()).unwrap();

    // Test extraction
    let log_content_str = fs::read_to_string(&log_file_path).unwrap();
    let log_json: serde_json::Value = serde_json::from_str(&log_content_str).unwrap();

    if let Some(context_window) = log_json.get("context_window") {
        if let Some(conversation_history) = context_window.get("conversation_history") {
            if let Some(messages) = conversation_history.as_array() {
                let last_tool_result = messages.iter().rev().find(|msg| {
                    if let Some(role) = msg.get("role") {
                        if let Some(role_str) = role.as_str() {
                            if role_str == "User" || role_str == "user" {
                                if let Some(content) = msg.get("content") {
                                    if let Some(content_str) = content.as_str() {
                                        return content_str.starts_with("Tool result:");
                                    }
                                }
                            }
                        }
                    }
                    false
                });

                assert!(last_tool_result.is_some());

                if let Some(last_message) = last_tool_result {
                    if let Some(content) = last_message.get("content") {
                        if let Some(content_str) = content.as_str() {
                            let feedback = content_str.strip_prefix("Tool result: ").unwrap_or(content_str);
                            assert_eq!(feedback, "TEST_FEEDBACK");
                            println!("✅ Successfully extracted coach feedback without timing: {}", feedback);
                            return;
                        }
                    }
                }
            }
        }
    }

    panic!("Failed to extract coach feedback");
}

#[test]
fn test_extract_coach_feedback_with_multiple_tool_results() {
    // Test that we get the LAST tool result when there are multiple
    let temp_dir = TempDir::new().unwrap();
    let logs_dir = temp_dir.path().join("logs");
    fs::create_dir(&logs_dir).unwrap();

    let session_id = "test_session_789";
    let log_file_path = logs_dir.join(format!("g3_session_{}.json", session_id));

    let log_content = json!({
        "session_id": session_id,
        "context_window": {
            "conversation_history": [
                {
                    "role": "assistant",
                    "content": "{\"tool\": \"shell\", \"args\": {\"command\":\"ls\"}}"
                },
                {
                    "role": "user",
                    "content": "Tool result: file1.txt\nfile2.txt"
                },
                {
                    "role": "assistant",
                    "content": "{\"tool\": \"final_output\", \"args\": {\"summary\":\"FINAL_RESULT\"}}"
                },
                {
                    "role": "user",
                    "content": "Tool result: FINAL_RESULT"
                },
                {
                    "role": "assistant",
                    "content": "🕝 15.2s | 💭 3.1s"
                }
            ]
        }
    });

    fs::write(&log_file_path, serde_json::to_string_pretty(&log_content).unwrap()).unwrap();

    // Test extraction
    let log_content_str = fs::read_to_string(&log_file_path).unwrap();
    let log_json: serde_json::Value = serde_json::from_str(&log_content_str).unwrap();

    if let Some(context_window) = log_json.get("context_window") {
        if let Some(conversation_history) = context_window.get("conversation_history") {
            if let Some(messages) = conversation_history.as_array() {
                let last_tool_result = messages.iter().rev().find(|msg| {
                    if let Some(role) = msg.get("role") {
                        if let Some(role_str) = role.as_str() {
                            if role_str == "User" || role_str == "user" {
                                if let Some(content) = msg.get("content") {
                                    if let Some(content_str) = content.as_str() {
                                        return content_str.starts_with("Tool result:");
                                    }
                                }
                            }
                        }
                    }
                    false
                });

                assert!(last_tool_result.is_some());

                if let Some(last_message) = last_tool_result {
                    if let Some(content) = last_message.get("content") {
                        if let Some(content_str) = content.as_str() {
                            let feedback = content_str.strip_prefix("Tool result: ").unwrap_or(content_str);
                            // Should get the LAST tool result (final_output), not the first one (shell)
                            assert_eq!(feedback, "FINAL_RESULT", "Should extract the last tool result");
                            assert!(!feedback.contains("file1.txt"), "Should not extract earlier tool results");
                            println!("✅ Successfully extracted last tool result: {}", feedback);
                            return;
                        }
                    }
                }
            }
        }
    }

    panic!("Failed to extract coach feedback");
}
