//! Regression test for cache_control serialization bug
//!
//! This test verifies that cache_control is NOT serialized in the wrong format.
//! The bug was that it serialized as:
//!   - `system.0.cache_control.ephemeral.ttl` (WRONG)
//!
//! It should serialize as:
//!   - `"cache_control": {"type": "ephemeral"}` for ephemeral
//!   - `"cache_control": {"type": "ephemeral", "ttl": "5m"}` for 5minute
//!   - `"cache_control": {"type": "ephemeral", "ttl": "1h"}` for 1hour

use g3_providers::{CacheControl, Message, MessageRole};

#[test]
fn test_no_wrong_serialization_format() {
    // Test ephemeral
    let msg = Message::with_cache_control(
        MessageRole::System,
        "Test".to_string(),
        CacheControl::ephemeral(),
    );
    let json = serde_json::to_string(&msg).unwrap();

    println!("Ephemeral message JSON: {}", json);

    // Should NOT contain the wrong format
    assert!(
        !json.contains("system.0.cache_control"),
        "JSON should not contain 'system.0.cache_control' path"
    );
    assert!(
        !json.contains("cache_control.ephemeral"),
        "JSON should not contain 'cache_control.ephemeral' path"
    );

    // Should contain the correct format
    assert!(
        json.contains(r#""cache_control":{"type":"ephemeral"}"#),
        "JSON should contain correct cache_control format"
    );
}

#[test]
fn test_five_minute_no_wrong_format() {
    let msg = Message::with_cache_control(
        MessageRole::System,
        "Test".to_string(),
        CacheControl::five_minute(),
    );
    let json = serde_json::to_string(&msg).unwrap();

    println!("5-minute message JSON: {}", json);

    // Should NOT contain the wrong format
    assert!(
        !json.contains("system.0.cache_control"),
        "JSON should not contain 'system.0.cache_control' path"
    );
    assert!(
        !json.contains("cache_control.ephemeral.ttl"),
        "JSON should not contain 'cache_control.ephemeral.ttl' path"
    );

    // Should contain the correct format with ttl as a direct field
    assert!(
        json.contains(r#""type":"ephemeral""#),
        "JSON should contain type field"
    );
    assert!(
        json.contains(r#""ttl":"5m""#),
        "JSON should contain ttl field with value 5m"
    );
}

#[test]
fn test_one_hour_no_wrong_format() {
    let msg = Message::with_cache_control(
        MessageRole::System,
        "Test".to_string(),
        CacheControl::one_hour(),
    );
    let json = serde_json::to_string(&msg).unwrap();

    println!("1-hour message JSON: {}", json);

    // Should NOT contain the wrong format
    assert!(
        !json.contains("system.0.cache_control"),
        "JSON should not contain 'system.0.cache_control' path"
    );
    assert!(
        !json.contains("cache_control.ephemeral.ttl"),
        "JSON should not contain 'cache_control.ephemeral.ttl' path"
    );

    // Should contain the correct format with ttl as a direct field
    assert!(
        json.contains(r#""type":"ephemeral""#),
        "JSON should contain type field"
    );
    assert!(
        json.contains(r#""ttl":"1h""#),
        "JSON should contain ttl field with value 1h"
    );
}

#[test]
fn test_cache_control_structure_is_flat() {
    // Verify that the cache_control object has a flat structure
    // with 'type' and optional 'ttl' at the same level

    let cache_control = CacheControl::five_minute();
    let json_value = serde_json::to_value(&cache_control).unwrap();

    println!(
        "Cache control as JSON value: {}",
        serde_json::to_string_pretty(&json_value).unwrap()
    );

    let obj = json_value.as_object().expect("Should be an object");

    // Should have exactly 2 keys at the top level
    assert_eq!(
        obj.len(),
        2,
        "Cache control should have exactly 2 top-level fields"
    );

    // Both 'type' and 'ttl' should be at the same level
    assert!(obj.contains_key("type"), "Should have 'type' field");
    assert!(obj.contains_key("ttl"), "Should have 'ttl' field");

    // 'type' should be a string, not an object
    assert!(obj["type"].is_string(), "'type' should be a string value");

    // 'ttl' should be a string, not nested
    assert!(obj["ttl"].is_string(), "'ttl' should be a string value");
}

#[test]
fn test_ephemeral_cache_control_structure() {
    let cache_control = CacheControl::ephemeral();
    let json_value = serde_json::to_value(&cache_control).unwrap();

    println!(
        "Ephemeral cache control as JSON value: {}",
        serde_json::to_string_pretty(&json_value).unwrap()
    );

    let obj = json_value.as_object().expect("Should be an object");

    // Should have exactly 1 key (only 'type', no 'ttl')
    assert_eq!(
        obj.len(),
        1,
        "Ephemeral cache control should have exactly 1 top-level field"
    );

    // Should have 'type' field
    assert!(obj.contains_key("type"), "Should have 'type' field");

    // Should NOT have 'ttl' field
    assert!(
        !obj.contains_key("ttl"),
        "Ephemeral should not have 'ttl' field"
    );

    // 'type' should be a string with value "ephemeral"
    assert_eq!(obj["type"].as_str().unwrap(), "ephemeral");
}
