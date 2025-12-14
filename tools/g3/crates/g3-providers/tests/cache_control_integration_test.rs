//! Integration tests for cache_control feature
//!
//! These tests verify that cache_control is correctly serialized in messages
//! for both Anthropic and Databricks providers.

use g3_providers::{CacheControl, Message, MessageRole};
use serde_json::json;

#[test]
fn test_ephemeral_cache_control_serialization() {
    let cache_control = CacheControl::ephemeral();
    let json = serde_json::to_value(&cache_control).unwrap();

    println!(
        "Ephemeral cache_control JSON: {}",
        serde_json::to_string(&json).unwrap()
    );

    assert_eq!(
        json,
        json!({
            "type": "ephemeral"
        })
    );

    // Verify no ttl field is present
    assert!(!json.as_object().unwrap().contains_key("ttl"));
}

#[test]
fn test_five_minute_cache_control_serialization() {
    let cache_control = CacheControl::five_minute();
    let json = serde_json::to_value(&cache_control).unwrap();

    println!(
        "5-minute cache_control JSON: {}",
        serde_json::to_string(&json).unwrap()
    );

    assert_eq!(
        json,
        json!({
            "type": "ephemeral",
            "ttl": "5m"
        })
    );
}

#[test]
fn test_one_hour_cache_control_serialization() {
    let cache_control = CacheControl::one_hour();
    let json = serde_json::to_value(&cache_control).unwrap();

    println!(
        "1-hour cache_control JSON: {}",
        serde_json::to_string(&json).unwrap()
    );

    assert_eq!(
        json,
        json!({
            "type": "ephemeral",
            "ttl": "1h"
        })
    );
}

#[test]
fn test_message_with_ephemeral_cache_control() {
    let msg = Message::with_cache_control(
        MessageRole::System,
        "System prompt".to_string(),
        CacheControl::ephemeral(),
    );

    let json = serde_json::to_value(&msg).unwrap();
    println!(
        "Message with ephemeral cache_control: {}",
        serde_json::to_string(&json).unwrap()
    );

    let cache_control = json
        .get("cache_control")
        .expect("cache_control field should exist");
    assert_eq!(cache_control.get("type").unwrap(), "ephemeral");
    assert!(!cache_control.as_object().unwrap().contains_key("ttl"));
}

#[test]
fn test_message_with_five_minute_cache_control() {
    let msg = Message::with_cache_control(
        MessageRole::System,
        "System prompt".to_string(),
        CacheControl::five_minute(),
    );

    let json = serde_json::to_value(&msg).unwrap();
    println!(
        "Message with 5-minute cache_control: {}",
        serde_json::to_string(&json).unwrap()
    );

    let cache_control = json
        .get("cache_control")
        .expect("cache_control field should exist");
    assert_eq!(cache_control.get("type").unwrap(), "ephemeral");
    assert_eq!(cache_control.get("ttl").unwrap(), "5m");
}

#[test]
fn test_message_with_one_hour_cache_control() {
    let msg = Message::with_cache_control(
        MessageRole::System,
        "System prompt".to_string(),
        CacheControl::one_hour(),
    );

    let json = serde_json::to_value(&msg).unwrap();
    println!(
        "Message with 1-hour cache_control: {}",
        serde_json::to_string(&json).unwrap()
    );

    let cache_control = json
        .get("cache_control")
        .expect("cache_control field should exist");
    assert_eq!(cache_control.get("type").unwrap(), "ephemeral");
    assert_eq!(cache_control.get("ttl").unwrap(), "1h");
}

#[test]
fn test_message_without_cache_control() {
    let msg = Message::new(MessageRole::User, "Hello".to_string());

    let json = serde_json::to_value(&msg).unwrap();
    println!(
        "Message without cache_control: {}",
        serde_json::to_string(&json).unwrap()
    );

    // cache_control field should not be present when not set
    assert!(!json.as_object().unwrap().contains_key("cache_control"));
}

#[test]
fn test_cache_control_json_format_ephemeral() {
    let cache_control = CacheControl::ephemeral();
    let json_str = serde_json::to_string(&cache_control).unwrap();

    println!("Ephemeral JSON string: {}", json_str);

    // Verify exact JSON format
    assert_eq!(json_str, r#"{"type":"ephemeral"}"#);
}

#[test]
fn test_cache_control_json_format_five_minute() {
    let cache_control = CacheControl::five_minute();
    let json_str = serde_json::to_string(&cache_control).unwrap();

    println!("5-minute JSON string: {}", json_str);

    // Verify exact JSON format
    assert_eq!(json_str, r#"{"type":"ephemeral","ttl":"5m"}"#);
}

#[test]
fn test_cache_control_json_format_one_hour() {
    let cache_control = CacheControl::one_hour();
    let json_str = serde_json::to_string(&cache_control).unwrap();

    println!("1-hour JSON string: {}", json_str);

    // Verify exact JSON format
    assert_eq!(json_str, r#"{"type":"ephemeral","ttl":"1h"}"#);
}

#[test]
fn test_deserialization_ephemeral() {
    let json_str = r#"{"type":"ephemeral"}"#;
    let cache_control: CacheControl = serde_json::from_str(json_str).unwrap();

    assert_eq!(cache_control.ttl, None);
}

#[test]
fn test_deserialization_five_minute() {
    let json_str = r#"{"type":"ephemeral","ttl":"5m"}"#;
    let cache_control: CacheControl = serde_json::from_str(json_str).unwrap();

    assert_eq!(cache_control.ttl, Some("5m".to_string()));
}

#[test]
fn test_deserialization_one_hour() {
    let json_str = r#"{"type":"ephemeral","ttl":"1h"}"#;
    let cache_control: CacheControl = serde_json::from_str(json_str).unwrap();

    assert_eq!(cache_control.ttl, Some("1h".to_string()));
}
