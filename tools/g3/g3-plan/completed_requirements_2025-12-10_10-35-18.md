{{CURRENT REQUIREMENTS}}

# Planner Mode UI Output Fixes

## Overview
These requirements address persistent issues with planner mode UI output that have not been fully resolved in previous attempts. The implementation must **test by actually running the app** to verify the fixes work correctly.

---

## 1. Tool Call Display: Single Line Output

**Problem**: Tool calls in planner mode are adding excessive whitespace and multiple newlines despite previous fix attempts.

**Root Cause Analysis**:
- `PlannerUiWriter::print_tool_header()` in `crates/g3-planner/src/llm.rs` (lines ~260-283) currently uses `println!()` 
- The method signature matches the UiWriter trait which provides `tool_args: Option<&serde_json::Value>`
- Previous attempts may have failed due to:
  1. Using `println!()` instead of proper formatting
  2. Not handling string truncation at character boundaries correctly
  3. Not accounting for terminal width limitations

**Required Changes**:

### Location: `crates/g3-planner/src/llm.rs`, `PlannerUiWriter::print_tool_header()`

```rust
fn print_tool_header(&self, tool_name: &str, tool_args: Option<&serde_json::Value>) {
    let count = self.tool_count.fetch_add(1, std::sync::atomic::Ordering::SeqCst) + 1;
    
    // Format args for display (first 50 chars, must be safe char boundary)
    let args_display = if let Some(args) = tool_args {
        let args_str = serde_json::to_string(args).unwrap_or_else(|_| "{}".to_string());
        if args_str.len() > 50 {
            // Use char_indices to safely truncate at char boundary
            let truncate_idx = args_str.char_indices()
                .nth(50)
                .map(|(idx, _)| idx)
                .unwrap_or(args_str.len());
            args_str[..truncate_idx].to_string()
        } else {
            args_str
        }
    } else {
        "{}".to_string()
    };
    
    // Print on EXACTLY one line, no trailing newline, use print! with explicit \n at end
    use std::io::Write;
    println!("🔧 [{}] {}  {}", count, tool_name, args_display);
    std::io::stdout().flush().ok();
}
```

**Expected Output**:
```
🔧 [13] read_file  {"file_path":"/Users/jochen/RustroverProjects/g3/g3-plan/planner_history.txt"} 
🔧 [14] shell      {"command":"find /Users/jochen/RustroverProjects/g3 -type f -name \"*.rs\" | hea
```

**Testing**: Run `g3 --planning --codepath ~/RustroverProjects/g3` and verify tool output has NO extra blank lines.

---

## 2. LLM Text Response Display

**Problem**: When the LLM sends non-tool text content during refinement, it appears mangled or gets overwritten by status lines.

**Root Cause Analysis**:
- `PlannerUiWriter::print_agent_response()` in `crates/g3-planner/src/llm.rs` (lines ~288-293) uses `println!()` which is correct
- However, `notify_sse_received()` is a no-op, which is correct (we don't want "Thinking..." to overwrite text)
- The issue may be in how agent text chunks are accumulated or how the Agent in g3-core calls this method

**Required Changes**:

### Location: `crates/g3-planner/src/llm.rs`, `PlannerUiWriter::print_agent_response()`

```rust
fn print_agent_response(&self, content: &str) {
    // Display non-tool text messages from LLM
    if !content.trim().is_empty() {
        // Ensure we're on a fresh line, print content as-is, no buffering
        print!("{}", content);
        std::io::stdout().flush().ok();
    }
}
```

**Reasoning**: 
- Use `print!()` not `println!()` to avoid adding extra newlines if content already has them
- Flush immediately to ensure text appears in real-time
- Do NOT use carriage returns or status line clearing

**Testing**: Run planning mode and verify LLM explanatory text appears as readable, contiguous text without being overwritten.

---

## 3. Logs Directory Location

**Problem**: Despite setting `G3_WORKSPACE_PATH` early in `run_planning_mode()`, logs are still written to the codepath or current directory instead of `<workspace>/logs`.

**Root Cause Analysis**:
- `run_planning_mode()` in `crates/g3-planner/src/planner.rs` sets `G3_WORKSPACE_PATH` at line ~752
- However, provider initialization happens BEFORE this at line ~735 (`llm::create_planner_provider()`)
- Provider initialization may trigger logging that happens BEFORE the environment variable is set
- Additionally, there may be other code paths that write logs before the variable is set

**Required Changes**:

### Location: `crates/g3-planner/src/planner.rs`, `run_planning_mode()` function

**Move the G3_WORKSPACE_PATH setup to the VERY START** of `run_planning_mode()`, immediately after determining codepath:

```rust
pub async fn run_planning_mode(
    codepath: Option<String>,
    no_git: bool,
    config_path: Option<&str>,
) -> anyhow::Result<()> {
    print_msg("\n🎯 G3 Planning Mode");
    print_msg("==================\n");
    
    // Get codepath first (needed for setting workspace path early)
    let codepath = match codepath {
        Some(path) => {
            let expanded = expand_codepath(&path)?;
            print_msg(&format!("📁 Codepath: {}", expanded.display()));
            expanded
        }
        None => {
            let path = prompt_for_codepath()?;
            print_msg(&format!("📁 Codepath: {}", path.display()));
            path
        }
    };
    
    // Verify codepath exists
    if !codepath.exists() {
        anyhow::bail!("Codepath does not exist: {}", codepath.display());
    }
    
    // >>> THIS ALREADY EXISTS IN THE CODE AT THE RIGHT PLACE (line ~752) <<<
    // Set workspace path EARLY for all logging (before provider initialization)
    std::env::set_var("G3_WORKSPACE_PATH", codepath.display().to_string());
    
    // Create logs directory and verify it exists
    let logs_dir = codepath.join("logs");
    if !logs_dir.exists() {
        fs::create_dir_all(&logs_dir)
            .context("Failed to create logs directory")?;
    }
    print_msg(&format!("📁 Logs directory: {}", logs_dir.display()));
    // >>> END OF EXISTING CODE <<<
    
    // NOW initialize the provider (after workspace is set)
    print_msg("🔧 Initializing planner provider...");
    let provider = match llm::create_planner_provider(config_path).await {
        // ... rest of function
```

**Note**: Looking at the actual code, lines 752-763 already do this correctly. The problem might be elsewhere.

### Additional Investigation Required:

1. **Check if the environment variable persists across async boundaries**: The planner provider is created in an async function. Verify the env var is still set when Agent::new() is called in `llm::call_refinement_llm_with_tools()`.

2. **Check g3-core logging initialization**: Look for any logging that happens during `g3_config::Config::load()` or provider creation that might not respect `G3_WORKSPACE_PATH`.

3. **Verify all log writes use `g3_core::logs_dir()`**: 
   - Search for `OpenOptions::new()` calls
   - Search for `fs::write()` in logging contexts
   - Ensure all use the centralized `get_logs_dir()` function

### Location: `crates/g3-core/src/lib.rs`, `get_logs_dir()` function

Verify this function is correctly checking the environment variable (it appears to be correct):

```rust
fn get_logs_dir() -> std::path::PathBuf {
    if let Ok(workspace_path) = std::env::var("G3_WORKSPACE_PATH") {
        std::path::PathBuf::from(workspace_path).join("logs")
    } else {
        std::env::current_dir().unwrap_or_default().join("logs")
    }
}
```

**Debugging Steps for Implementation**:
1. Add debug print immediately after setting `G3_WORKSPACE_PATH` to confirm it's set
2. Add debug print in `get_logs_dir()` to show what path is being returned
3. Run the app and grep for where logs are actually being written
4. If logs still go to wrong place, add tracing to find which code path is writing them

**Testing**: 
1. Delete any log files in the current directory and in `/Users/jochen/RustroverProjects/g3/logs/`
2. Run `cd /tmp && g3 --planning --codepath ~/RustroverProjects/g3`
3. Verify ALL logs are written to `~/RustroverProjects/g3/logs/` and NONE to `/tmp/logs/` or `/tmp/`

---

## Implementation Notes

**CRITICAL**: This is the third attempt to fix these issues. The implementer MUST:

1. **Actually run the application** in planning mode to verify each fix
2. **Use real test cases** - not just unit tests
3. **Check the actual output** in the terminal and verify log file locations on disk
4. **Take screenshots or copy actual terminal output** to verify fixes
5. **Do not assume the fix works** without visual verification

**Success Criteria**:
- Tool calls display on single lines with no extra whitespace (verified by running app)
- LLM text responses display as readable, contiguous text (verified by running app)
- ALL logs are written to `<workspace>/logs/` directory (verified by ls after running app)
- NO logs appear in current directory or any other location

---

{{ORIGINAL USER REQUIREMENTS -- THIS SECTION WILL BE IGNORED BY THE IMPLEMENTATION}}

*Bad tool output*

The current method of writing tool output is not working.
The output via UI writer is numbering tool calls, but adding A LOT of whitespace. Change the code to
write only a single line without any additional newline or anything, include on the line the first 50 chars of the
tool command, but make SURE it's only going to be a single line.

Despite repeated attempts to fix it, this is still not working.

Please RUN THE ACTUAL APP in planning mode and observe how many empty lines are written to the display during
tool calls. TRY AS MANY solutions, including adding new functions to UiWriter to make sure only a single line
is written to the output.

desired behaviour:
```
🔧 [13] read_file  {"file_path":"/Users/jochen/RustroverProjects/g3/g3-plan/planner_history.txt"} 
🔧 [14] shell      {"command":"find /Users/jochen/RustroverProjects/g3 -type f -name \"*.rs\" | hea
```


*Display non-tool text messages*

When the LLM sends text content (not tool calls), print it to the UI. It's currently mangled. RUN THE ACTUAL APP
and make SURE it appears as contiguous text in a coherent manner.

*Logs directory*

A previous fix attempted to fix where logs are written, but that didn't work in my last experiment.
The logs were STILL written to the codepath or pwd, instead of to <workspace>/logs. Please debug and fix this
THIS IS CRITICAL. DO NOT APPROVE A SOLUTION WHERE RUNNING THE APP PRODUCES LOG FILES IN THE WRONG PLACE.
