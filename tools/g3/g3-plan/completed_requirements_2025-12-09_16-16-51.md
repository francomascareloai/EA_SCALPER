{{CURRENT REQUIREMENTS}}

These requirements refine the planner mode implementation in `g3-planner` crate.

## 1. Display Coach Feedback Content (Not Just Length)

**Location**: `crates/g3-planner/src/planner.rs`, `run_coach_player_loop()` function around line 610

**Current behavior**:
```rust
coach_feedback = result.response;
print_msg(&format!("📝 Coach feedback: {} chars", coach_feedback.len()));
```

**Required change**:
- Display the first 25 lines of coach feedback content (not just the character count)
- Truncate with "..." indicator if feedback exceeds 25 lines
- Keep showing the char count as secondary info

**Example output**:
```
📝 Coach feedback (1234 chars):
  The implementation looks good but needs:
  1. Error handling for edge cases
  2. Unit tests for the new function
  ...
```

## 2. TODO File Location and Preservation in Planning Mode

**Issue**: The TODO file must be:
1. Ensure Written to `<codepath>/g3-plan/todo.g3.md` during implementation (this appears to work via `G3_TODO_PATH` env var)
2. If anything in the system prompt or elsewhere instructs deletion, do NOT delete when in planner mode, since it needs to be renamed to `completed_todo_<timestamp>.md`

**Current behavior to verify**:
- `G3_TODO_PATH` is set in `run_coach_player_loop()` at line ~596
- The `todo_read` and `todo_write` tools in g3-core should respect this env var

**Required changes**:
- In `prompt_for_new_requirements()` function (around line 255), the code deletes `todo.g3.md` when starting fresh refinement. This is correct behavior.
- Verify that during the coach/player loop, the TODO file is NOT deleted by the final_output tool or any cleanup logic
- If there is cleanup logic or other code other than the rename in at completion in planning, add a mechanism to prevent TODO deletion in planner mode (e.g., check for `G3_TODO_PATH` env var or add a planner mode flag)

**Files to check**:
- `crates/g3-core/src/lib.rs` - `todo_write` tool implementation, ensure it respects `G3_TODO_PATH`
- Check if `final_output` tool deletes the TODO file

## 3. Write GIT COMMIT Entry BEFORE Actual Commit

**Location**: `crates/g3-planner/src/planner.rs`, `stage_and_commit()` function around line 568

**Current behavior**:
```rust
// Make commit
print_msg("📝 Making git commit...");
let _commit_sha = git::commit(&config.codepath, summary, description)?;
print_msg("✅ Commit successful");

// Log commit to history (AFTER commit - wrong order)
history::write_git_commit(&config.plan_dir(), summary)?;
```

**Required change**:
After getting user go-ahead to commit, then do:
```rust
// Log commit to history BEFORE making the commit
history::write_git_commit(&config.plan_dir(), summary)?;

// Make commit
print_msg("📝 Making git commit...");
let _commit_sha = git::commit(&config.codepath, summary, description)?;
print_msg("✅ Commit successful");
```

**Rationale**: If the commit fails, the history will still record the attempt. This provides better audit trail and allows recovery.

## 4. Single-Line UI Updates During LLM Processing

**Location**: `crates/g3-planner/src/llm.rs`, `PlannerUiWriter` implementation

**Current behavior**:
- `print_tool_header` prints each tool on a new line
- Agent text responses are not displayed during refinement

**Required changes**:

a) **Single-line status updates**: Instead of printing a new line for each tool call, use carriage return (`\r`) to update a single status line:
   - Show "Thinking..." while waiting
   - Show context window size (if available)
   - Show tool count: "Executing tool 3..."
   - Use `print!("\r{:<80}", status_line)` pattern to overwrite previous line

b) **Display non-tool text messages**: When the LLM sends text content (not tool calls), print it to the UI:
   - Implement `print_agent_response(&self, content: &str)` to actually print content
   - This allows the planner to communicate its reasoning to the user


## 5. Write Logs to Workspace Path (Not Relative)

Logs are written to the current/or codepath directory. Instead write them to the workspace path.
This applies to logs such as conversation history, tools calls, context window, errors etc...
*ALL logs throughout the g3 codebase* should be exclusively written to <workspace>/logs.

{{ORIGINAL USER REQUIREMENTS -- THIS SECTION WILL BE IGNORED BY THE IMPLEMENTATION}}

1.

In planner.rs Show coach feedback: up to 25 lines

coach_feedback = result.response;
print_msg(&format!("📝 Coach feedback: {} chars", coach_feedback.len()));

2.

I can't find where the TODO file is written during implementation in planning mode. Please check that it's written to the g3-plan directory.
It looks like there are explicit instructions to delete the TODO file when complete, potentially in player mode. DO NOT ALLOW it to be deleted when in planner mode since we want to copy it for history.

3.
Make sure to write the "GIT COMMIT (<message>)"  to the planner_history.txt file *immediately before* doing the actual commit (not after, like the current implementation  does).

4. In planner mode, do not write a new line in UI writer for each tool call. Instead keep a single line that says "thinking...." While the llm is working.  Keep each update on a single line (use backspace or something to erase the last update?) and show the context window size and that we're waiting for the llm to finish tool calls. HOWEVER, DO PRINT to the UI all non-tool comments (text messages) that the llm sends (that's currently not happening).

5. Logs are written to the <codepath> directory. Instead write them to the workspace path.

