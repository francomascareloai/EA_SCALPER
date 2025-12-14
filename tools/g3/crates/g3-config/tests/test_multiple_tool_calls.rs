#[cfg(test)]
mod test_multiple_tool_calls {
    use g3_config::{AgentConfig, Config};

    #[test]
    fn test_config_has_multiple_tool_calls_field() {
        let config = Config::default();

        // Test that the field exists and defaults to false
        assert_eq!(config.agent.allow_multiple_tool_calls, false);

        // Test that we can create a config with the field set to true
        let mut custom_config = Config::default();
        custom_config.agent.allow_multiple_tool_calls = true;
        assert_eq!(custom_config.agent.allow_multiple_tool_calls, true);
    }

    #[test]
    fn test_agent_config_serialization() {
        let agent_config = AgentConfig {
            max_context_length: Some(100000),
            fallback_default_max_tokens: 8192,
            enable_streaming: true,
            allow_multiple_tool_calls: true,
            timeout_seconds: 60,
            auto_compact: true,
            max_retry_attempts: 3,
            autonomous_max_retry_attempts: 6,
            check_todo_staleness: true,
        };

        // Test serialization
        let json = serde_json::to_string(&agent_config).unwrap();
        assert!(json.contains("\"allow_multiple_tool_calls\":true"));

        // Test deserialization
        let deserialized: AgentConfig = serde_json::from_str(&json).unwrap();
        assert_eq!(deserialized.allow_multiple_tool_calls, true);
    }
}
