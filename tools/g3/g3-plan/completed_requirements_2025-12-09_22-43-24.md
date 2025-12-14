{{CURRENT REQUIREMENTS}}

# Planner Mode UI and Error Handling Refinements

## Overview
These requirements refine the planner mode implementation in the `g3-planner` crate, focusing on:
1. Proper error propagation and display from LLM calls
2. Clean, single-line tool output display
3. Visible LLM text responses during refinement
4. Consistent log file placement in workspace/logs directory

---

## 1. Error Propagation from LLM Calls

**Issue**: LLM errors during planning mode refinement show stack traces but don't display the classified error type to the user.

**Location**: `crates/g3-planner/src/llm.rs`, function `call_refinement_llm_with_tools()`

**Current behavior**:
- When the LLM call fails, an error is returned but there is no information shown about what the underlying error was.
- a bunch of error info is lost, including the `classify_error()` function in `g3-core/src/error_handling.rs` is not being utilized

**Required changes**:
1. In `call_refinement_llm_with_tools()`, wrap the agent execution error handling:
   ```rust
   let result = agent.execute_task_with_timing(...).await;
   match result {
       Ok(response) => Ok(response.response),
       Err(e) => {
           // Classify the error
           let error_type = g3_core::error_handling::classify_error(&e);
           
           // Display user-friendly message based on error type
           match error_type {
               ErrorType::Recoverable(recoverable) => {
                   eprintln!("⚠️  Recoverable error: {:?}", recoverable);
                   eprintln!("   Details: {}", e);
               }
               ErrorType::NonRecoverable => {
                   eprintln!("❌ Non-recoverable error: {}", e);
               }
           }
           
           Err(e)
       }
   }
   ```

2. Import the error handling types:
   ```rust
   use g3_core::error_handling::{classify_error, ErrorType};
   ```

---

## 2. Single-Line Tool Output Display

**Issue**: Tool call display in planner mode adds excessive whitespace and prints each tool on a new line. Need compact, informative single-line display.

**Location**: `crates/g3-planner/src/llm.rs`, struct `PlannerUiWriter`, method `print_tool_header()`

**Current behavior** (lines 238-243):
```rust
fn print_tool_header(&self, tool_name: &str) {
    let count = self.tool_count.fetch_add(1, std::sync::atomic::Ordering::SeqCst) + 1;
    print!("\r{:<80}\n", ""); // Clear status line
    println!("🔧 [{}] {}", count, tool_name);
}
```

**Required changes**:
1. Modify `print_tool_header()` to accept tool arguments and display them inline:
   - Change signature: `fn print_tool_header(&self, tool_name: &str, tool_args: &serde_json::Value)`
   - Format: `🔧 [N] tool_name  {first_50_chars_of_args}`
   - Ensure single line, no trailing newlines

2. Update the method implementation to use UiWriter, not println.

   ```rust
   fn print_tool_header(&self, tool_name: &str, tool_args: &serde_json::Value) {
   .........
        ui_writer.println("🔧 [{}] {}  {}", count, tool_name, args_display);
   }
   ```
3. **Note**: This requires coordination with `g3-core` to pass tool arguments to the UiWriter. Check if the `UiWriter` trait needs updating to support this signature.

---

## 3. Display LLM Text Responses

**Issue**: When the LLM sends non-tool text content during refinement, it should be visible to the user but may be getting overwritten.

**Location**: `crates/g3-planner/src/llm.rs`, struct `PlannerUiWriter`, method `print_agent_response()`

**Current behavior** (lines 259-265):
```rust
fn print_agent_response(&self, content: &str) {
    if !content.trim().is_empty() {
        print!("{}", content);
        std::io::stdout().flush().ok();
    }
}
```

**Analysis**: The implementation looks correct. The issue may be that:
1. Text content is being printed via `print_agent_response()` but then immediately overwritten by subsequent "Thinking..." status lines
2. The carriage return (`\r`) in `notify_sse_received()` is overwriting previously printed content

**Required changes**:
1. Before printing agent response, ensure previous status lines are cleared:
   ```rust
   fn print_agent_response(&self, content: &str) {
       if !content.trim().is_empty() {
          ui_writer.println("{}", content);
       }
   }
   ```

2. check whether `notify_sse_received()`, is even needed

3. In `print_status_line()`, ensure proper padding and flushing:
   ```rust
   fn print_status_line(&self, message: &str) {
       ui_writer.println("{:.80}", message);
   }
   ```

---

## 4. Consistent Workspace Logs Directory

**Issue**: Logs are sometimes written to codepath/current directory instead of consistently using `<workspace>/logs`.

**Locations**:
- `crates/g3-planner/src/lib.rs` - `write_code_report()` and `write_discovery_commands()`
- `crates/g3-core/src/lib.rs` - `get_logs_dir()`
- `crates/g3-core/src/error_handling.rs` - `save_to_file()`

**Current behavior**: 
Multiple implementations check for `G3_WORKSPACE_PATH` environment variable, which is good. However, there may be places that don't use the centralized `logs_dir()` function.

**Required changes**:

1. **Audit all log file writes** across the codebase to ensure they use the centralized function:
   - Search for `OpenOptions::new()` calls that write to files
   - Search for `fs::write()` calls in logging contexts
   - Check that all use `g3_core::logs_dir()` or equivalent

2. **In g3-planner, ensure consistency**:
   - File: `crates/g3-planner/src/lib.rs`
   - Functions: `write_code_report()` and `write_discovery_commands()`
   - These already check `G3_WORKSPACE_PATH`, which is correct
   - Verify they're actually being used and the env var is set properly

3. **Ensure G3_WORKSPACE_PATH is set early**:
   - File: `crates/g3-planner/src/planner.rs`
   - Function: `run_coach_player_loop()` around line 599
   - Current code sets it: `std::env::set_var("G3_WORKSPACE_PATH", planner_config.codepath.display().to_string());`
   - **Verify this is set BEFORE any logging occurs**, not just before the coach/player loop
   - Move this to the start of `run_planning_mode()` function around line 700

4. **Add verification** in `run_planning_mode()`:
   ```rust
   // Set workspace path early for all logging
   std::env::set_var("G3_WORKSPACE_PATH", config.codepath.display().to_string());
   
   // Create logs directory if it doesn't exist
   let logs_dir = config.codepath.join("logs");
   if !logs_dir.exists() {
       fs::create_dir_all(&logs_dir)
           .context("Failed to create logs directory")?;
   }
   
   print_msg(&format!("📁 Logs directory: {}", logs_dir.display()));
   ```

---

## Testing Checklist

After implementation, verify:

1. **Error Display**:
   - Trigger a rate limit error → Should see "⚠️  Recoverable error: RateLimit"
   - Trigger a network error → Should see classified error type
   - Non-recoverable errors → Should see clear error message

2. **Tool Output**:
   - Run refinement → Tool calls should appear as: `🔧 [1] shell  {"command":"ls -la"}`
   - Long commands should truncate at 50 chars with "..."
   - Each tool call on its own line, no extra blank lines

3. **Text Responses**:
   - LLM explanatory text should be visible
   - "Thinking..." should appear during processing
   - Text should not be overwritten by subsequent status updates

4. **Logs Location**:
   - Check that `logs/` directory is created in workspace (codepath)
   - Verify `logs/errors/`, `logs/g3_session*.json`, `logs/tool_calls*.log`, `logs/context_window*.txt` are in workspace
   - Verify NO log files are created in current working directory or any other location

---

## Implementation Notes

- Keep changes minimal and focused on these specific issues
- Don't refactor unrelated code
- Maintain backward compatibility with existing logs
- Test in actual planning mode, not just unit tests
- Update any relevant error messages to be user-friendly

{{ORIGINAL USER REQUIREMENTS -- THIS SECTION WILL BE IGNORED BY THE IMPLEMENTATION}}

*LLM errors not shown*

Failure in calls to the llm in planning mode are not logged (only a stack trace), and never reported to the user.
Make sure the error from `pub fn classify_error(error: &anyhow::Error) -> ErrorType {` in error_handling.rs is
correctly returned all the way to the llm.rs call_refinement_llm_with_tools() function and displayed to the user.


*Bad tool output*

The current method of writing tool output is not working.
The output via UI writer is numbering tool calls, but adding A LOT of whitespace. Change the code to
write only a single line without any additional newline or anything, include on the line the first 50 chars of the
tool command, but make SURE it's only going to be a single line.

desired behaviour:

```
🔄 Refinement phase - calling LLM...
💭 Thinking...

🔧 [1] shell



🔧 [2] shell



🔧 [3] read_file



🔧 [4] read_file

💭 Thinking...

🔧 [5] read_file



🔧 [6] read_file



🔧 [7] shell

💭 Thinking...

🔧 [8] read_file



🔧 [9] read_file


💭 Thinking...                                                                   :file deletion logic

🔧 [10] read_file



🔧 [11] shell



🔧 [12] shell

💭 Thinking...

🔧 [13] read_file

💭 Thinking...

🔧 [14] shell


💭 Thinking...                                                                   .requirements feedbackhere

🔧 [15] read_file


💭 Thinking...                                                                    user's question:at
```

desired behaviour:
```
🔧 [13] read_file  {"file_path":"/Users/jochen/RustroverProjects/g3/g3-plan/planner_history.txt"} 
🔧 [14] shell      {"command":"find /Users/jochen/RustroverProjects/g3 -type f -name \"*.rs\" | hea
```


*Display non-tool text messages* 

When the LLM sends text content (not tool calls), print it to the UI.
Current behaviour appears to do what the tools should have, which is overwrite each other. simply remove the logic of
overwrites (maybe it used `\r`)? And simply print the output via the UiWriter as normal text.

*Logs directory*

A previous fix attempted to fix where logs are written, but that didn't work in my last experiment.
The logs were STILL written to the codepath or pwd, instead of to <workspace>/logs. Please debug and fix this.
