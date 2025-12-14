use g3_config::Config;
use g3_core::ui_writer::UiWriter;
use g3_core::{Agent, ToolCall};
use serial_test::serial;
use std::sync::{Arc, Mutex};
use tempfile::TempDir;

// Mock UI Writer for testing
#[derive(Clone)]
struct MockUiWriter {
    output: Arc<Mutex<Vec<String>>>,
    prompt_responses: Arc<Mutex<Vec<bool>>>,
    choice_responses: Arc<Mutex<Vec<usize>>>,
}

impl MockUiWriter {
    fn new() -> Self {
        Self {
            output: Arc::new(Mutex::new(Vec::new())),
            prompt_responses: Arc::new(Mutex::new(Vec::new())),
            choice_responses: Arc::new(Mutex::new(Vec::new())),
        }
    }

    fn set_prompt_response(&self, response: bool) {
        self.prompt_responses.lock().unwrap().push(response);
    }

    fn set_choice_response(&self, response: usize) {
        self.choice_responses.lock().unwrap().push(response);
    }

    fn get_output(&self) -> Vec<String> {
        self.output.lock().unwrap().clone()
    }
}

impl UiWriter for MockUiWriter {
    fn print(&self, message: &str) {
        self.output.lock().unwrap().push(message.to_string());
    }
    fn println(&self, message: &str) {
        self.output.lock().unwrap().push(message.to_string());
    }
    fn print_inline(&self, message: &str) {
        self.output.lock().unwrap().push(message.to_string());
    }
    fn print_system_prompt(&self, _prompt: &str) {}
    fn print_context_status(&self, message: &str) {
        self.output
            .lock()
            .unwrap()
            .push(format!("STATUS: {}", message));
    }
    fn print_context_thinning(&self, _message: &str) {}
    fn print_tool_header(&self, _tool_name: &str, _tool_args: Option<&serde_json::Value>) {}
    fn print_tool_arg(&self, _key: &str, _value: &str) {}
    fn print_tool_output_header(&self) {}
    fn update_tool_output_line(&self, _line: &str) {}
    fn print_tool_output_line(&self, _line: &str) {}
    fn print_tool_output_summary(&self, _hidden_count: usize) {}
    fn print_tool_timing(&self, _duration_str: &str) {}
    fn print_agent_prompt(&self) {}
    fn print_agent_response(&self, _content: &str) {}
    fn notify_sse_received(&self) {}
    fn flush(&self) {}
    fn wants_full_output(&self) -> bool {
        false
    }
    fn prompt_user_yes_no(&self, message: &str) -> bool {
        self.output
            .lock()
            .unwrap()
            .push(format!("PROMPT: {}", message));
        self.prompt_responses.lock().unwrap().pop().unwrap_or(true)
    }
    fn prompt_user_choice(&self, message: &str, options: &[&str]) -> usize {
        self.output
            .lock()
            .unwrap()
            .push(format!("CHOICE: {} Options: {:?}", message, options));
        self.choice_responses.lock().unwrap().pop().unwrap_or(0)
    }
    fn print_final_output(&self, summary: &str) {
        self.output.lock().unwrap().push(format!("FINAL: {}", summary));
    }
}

#[tokio::test]
#[serial]
async fn test_todo_staleness_check_matching_sha() {
    let temp_dir = TempDir::new().unwrap();
    let todo_path = temp_dir.path().join("todo.g3.md");
    std::env::set_current_dir(&temp_dir).unwrap();

    let sha = "abc123hash";
    let content = format!(
        "{{{{Based on the requirements file with SHA256: {}}}}}\n- [ ] Task 1",
        sha
    );
    std::fs::write(&todo_path, content).unwrap();

    let mut config = Config::default();
    config.agent.check_todo_staleness = true;

    let ui_writer = MockUiWriter::new();
    let mut agent = Agent::new_autonomous(config, ui_writer).await.unwrap();
    agent.set_requirements_sha(sha.to_string());

    let tool_call = ToolCall {
        tool: "todo_read".to_string(),
        args: serde_json::json!({}),
    };
    let result = agent.execute_tool(&tool_call).await.unwrap();

    assert!(result.contains("📝 TODO list:"));
    assert!(!result.contains("⚠️ TODO list is stale"));
}

#[tokio::test]
#[serial]
async fn test_todo_staleness_check_mismatch_sha_ignore() {
    let temp_dir = TempDir::new().unwrap();
    let todo_path = temp_dir.path().join("todo.g3.md");
    std::env::set_current_dir(&temp_dir).unwrap();

    let sha_file = "old_sha";
    let sha_req = "new_sha";
    let content = format!(
        "{{{{Based on the requirements file with SHA256: {}}}}}\n- [ ] Task 1",
        sha_file
    );
    std::fs::write(&todo_path, content).unwrap();

    let mut config = Config::default();
    config.agent.check_todo_staleness = true;

    let ui_writer = MockUiWriter::new();
    ui_writer.set_choice_response(0); // Ignore

    let mut agent = Agent::new_autonomous(config, ui_writer).await.unwrap();
    agent.set_requirements_sha(sha_req.to_string());

    let tool_call = ToolCall {
        tool: "todo_read".to_string(),
        args: serde_json::json!({}),
    };
    let result = agent.execute_tool(&tool_call).await.unwrap();

    assert!(result.contains("📝 TODO list:"));
}

#[tokio::test]
#[serial]
async fn test_todo_staleness_check_mismatch_sha_mark_stale() {
    let temp_dir = TempDir::new().unwrap();
    let todo_path = temp_dir.path().join("todo.g3.md");
    std::env::set_current_dir(&temp_dir).unwrap();

    let sha_file = "old_sha";
    let sha_req = "new_sha";
    let content = format!(
        "{{{{Based on the requirements file with SHA256: {}}}}}\n- [ ] Task 1",
        sha_file
    );
    std::fs::write(&todo_path, content).unwrap();

    let mut config = Config::default();
    config.agent.check_todo_staleness = true;

    let ui_writer = MockUiWriter::new();
    ui_writer.set_choice_response(1); // Mark as Stale

    let mut agent = Agent::new_autonomous(config, ui_writer).await.unwrap();
    agent.set_requirements_sha(sha_req.to_string());

    let tool_call = ToolCall {
        tool: "todo_read".to_string(),
        args: serde_json::json!({}),
    };
    let result = agent.execute_tool(&tool_call).await.unwrap();

    assert!(result.contains("⚠️ TODO list is stale"));
    assert!(result.contains("Please regenerate"));
}

// Note: We cannot easily test "Quit" (index 2) because it calls std::process::exit(0)
// which would kill the test runner. We skip that test case here.

#[tokio::test]
#[serial]
async fn test_todo_staleness_check_disabled() {
    let temp_dir = TempDir::new().unwrap();
    let todo_path = temp_dir.path().join("todo.g3.md");
    std::env::set_current_dir(&temp_dir).unwrap();

    let sha_file = "old_sha";
    let sha_req = "new_sha";
    let content = format!(
        "{{{{Based on the requirements file with SHA256: {}}}}}\n- [ ] Task 1",
        sha_file
    );
    std::fs::write(&todo_path, content).unwrap();

    let mut config = Config::default();
    config.agent.check_todo_staleness = false;

    let ui_writer = MockUiWriter::new();
    let mut agent = Agent::new_autonomous(config, ui_writer).await.unwrap();
    agent.set_requirements_sha(sha_req.to_string());

    let tool_call = ToolCall {
        tool: "todo_read".to_string(),
        args: serde_json::json!({}),
    };
    let result = agent.execute_tool(&tool_call).await.unwrap();

    assert!(result.contains("📝 TODO list:"));
}
