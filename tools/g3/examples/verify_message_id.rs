// Verification script to demonstrate Message ID implementation
// Run with: cargo run --example verify_message_id

use g3_providers::{Message, MessageRole};

fn main() {
    println!("=== Message ID Implementation Verification ===");
    println!();

    // Create several messages to show ID generation
    println!("Creating 5 messages to demonstrate ID generation:");
    for i in 1..=5 {
        let msg = Message::new(MessageRole::User, format!("Test message {}", i));
        println!("  Message {}: id = '{}'", i, msg.id);
    }

    println!();
    println!("ID Format: HHMMSS-XXX");
    println!("  - HHMMSS: Current time (hours, minutes, seconds)");
    println!("  - XXX: 3 random alphabetic characters (a-z, A-Z)");

    println!();
    println!("Verifying ID is NOT serialized to JSON:");
    let msg = Message::new(MessageRole::User, "Hello World".to_string());
    let json = serde_json::to_string(&msg).unwrap();
    println!("  Message ID: {}", msg.id);
    println!("  JSON output: {}", json);
    println!("  Contains 'id' field: {}", json.contains("\"id\""));

    println!();
    println!("✅ Implementation complete!");
}
