{{CURRENT REQUIREMENTS}}

These requirements specify verification tasks for the planning mode's retry logic and coach
response parsing, along with documentation of where configuration is located.

## 1. Document Retry Configuration Location

**Goal**: Clarify where retry settings are configured for planning mode.

**Findings to document**:
1. Retry configuration is in the `.g3.toml` config file (or `config.example.toml` as template)
   under the `[agent]` section:
   ```toml
   [agent]
   max_retry_attempts = 3              # Default mode retries
   autonomous_max_retry_attempts = 6   # Used by planning/autonomous mode
   ```

2. The retry infrastructure is implemented in `crates/g3-core/src/retry.rs`:
   - `RetryConfig` struct defines retry behavior per role
   - `RetryConfig::planning("player")` and `RetryConfig::planning("coach")` create presets
   - Default max retries is 3 (hardcoded in `RetryConfig::planning()`)

3. **Note**: Currently `RetryConfig::planning()` uses a hardcoded `max_retries: 3` rather than
   reading from the config file's `autonomous_max_retry_attempts`. This may be intentional or
   a gap to address.

**Required action**:

- add examples to config.example.toml for the coach and player retry configs.

## 2. Verify Retry Loop Functionality

**Goal**: Confirm that connection retry loops in planning mode work correctly for recoverable
errors.

**Verification approach**:
1. The retry logic is implemented in `g3_core::retry::execute_with_retry()` and is already
   used by both player and coach phases in `run_coach_player_loop()` (planner.rs lines 633-640
   and 682-689).

2. Error classification happens in `g3_core::error_handling::classify_error()` which identifies:
   - `RecoverableError::RateLimit` (429 errors)
   - `RecoverableError::NetworkError` (connection failures)
   - `RecoverableError::ServerError` (5xx errors)
   - `RecoverableError::Timeout` (request timeouts)
   - `RecoverableError::ModelBusy` (capacity issues)

3. **Manual verification steps** (for a human tester):
   - Run planning mode with a temporarily invalid API endpoint to trigger network errors
   - Observe retry messages: `"⚠️ player error (attempt X/3): NetworkError - ..."`
   - Observe backoff: `"🔄 Retrying player in Xs..."`
   - After max retries, observe: `"🔄 Max retries (3) reached for player"`

4. **Existing test coverage**:
   - `g3-core/src/retry.rs` has unit tests for `RetryConfig` construction
   - `g3-core/src/error_handling.rs` has tests for `classify_error()` and delay calculations

**Required action**:
- No code changes needed if retry loops are already functioning.
- If issues are found during manual verification, document specific failure scenarios.

## 3. Verify Coach Response Parsing

**Goal**: Confirm that coach feedback extraction works correctly in planning mode.

**Current implementation**:
1. Coach feedback extraction uses `g3_core::feedback_extraction::extract_coach_feedback()`
   (called at planner.rs ~line 695).

2. The extraction tries multiple sources in order:
   - `FeedbackSource::SessionLog` - from session log JSON file
   - `FeedbackSource::NativeToolCall` - from native tool call JSON in response
   - `FeedbackSource::ConversationHistory` - from conversation history
   - `FeedbackSource::TaskResultResponse` - from TaskResult parsing
   - `FeedbackSource::DefaultFallback` - default message

3. Planning mode displays the extraction source:
   ```
   📝 Coach feedback extracted from SessionLog: 1234 chars
   ```

**Verification approach**:
1. **Manual verification steps**:
   - Run a planning mode session through at least one coach/player cycle
   - Observe the feedback extraction message and confirm it shows a valid source
     (preferably `SessionLog` or `NativeToolCall`, not `DefaultFallback`)
   - Verify the first 25 lines of feedback are displayed correctly
   - Confirm `IMPLEMENTATION_APPROVED` detection works when coach approves

2. **Existing test coverage**:
   - `g3-core/src/feedback_extraction.rs` has comprehensive unit tests:
     - `test_extract_balanced_json_*` - JSON parsing
     - `test_try_extract_json_tool_call` - tool call extraction
     - `test_is_final_output_tool_call_*` - detecting final_output calls
     - `test_extracted_feedback_is_approved` - approval detection

**Required action**:
- No code changes needed if parsing is working correctly.
- If `DefaultFallback` is observed frequently during manual testing, investigate why
  earlier extraction methods are failing and document findings.

## 4. Optional: Add Integration Test for Retry + Feedback Flow

**Goal**: Create a lightweight integration test that verifies the retry and feedback
extraction machinery works together.

**Scope**: Only implement if time permits and manual verification reveals issues.

**Approach**:
1. Create a test in `crates/g3-planner/tests/` that:
   - Mocks an LLM provider that returns a `final_output` tool call
   - Verifies `extract_coach_feedback()` successfully extracts the feedback
   - Optionally simulates a recoverable error to test retry logic

2. This test should NOT require actual API calls or network access.
