//! Retry infrastructure for agent task execution
//!
//! This module provides reusable retry logic for executing agent tasks,
//! including error classification, exponential backoff, and configurable retry strategies.
//!
//! Used by both autonomous mode (g3-cli) and planning mode (g3-planner).

use crate::error_handling::{calculate_retry_delay, classify_error, ErrorType, RecoverableError};
use crate::ui_writer::UiWriter;
use crate::{Agent, DiscoveryOptions, TaskResult};
use anyhow::Result;
use std::time::Instant;
use tracing::{info, warn};

/// Configuration for retry behavior
#[derive(Debug, Clone)]
pub struct RetryConfig {
    /// Maximum number of retry attempts
    pub max_retries: u32,
    /// Whether this is autonomous mode (affects backoff timing)
    pub is_autonomous: bool,
    /// Role name for logging (e.g., "player", "coach")
    pub role_name: String,
}

impl Default for RetryConfig {
    fn default() -> Self {
        Self {
            max_retries: 3,
            is_autonomous: false,
            role_name: "agent".to_string(),
        }
    }
}

impl RetryConfig {
    /// Create a retry config for player agent
    pub fn player() -> Self {
        Self {
            max_retries: 3,
            is_autonomous: true,
            role_name: "player".to_string(),
        }
    }

    /// Create a retry config for coach agent
    pub fn coach() -> Self {
        Self {
            max_retries: 3,
            is_autonomous: true,
            role_name: "coach".to_string(),
        }
    }

    /// Create a retry config for planning mode
    pub fn planning(role: &str) -> Self {
        Self {
            max_retries: 3,
            is_autonomous: true,
            role_name: role.to_string(),
        }
    }

    /// Set custom max retries
    pub fn with_max_retries(mut self, max_retries: u32) -> Self {
        self.max_retries = max_retries;
        self
    }
}

/// Result of a retry operation
#[derive(Debug)]
pub enum RetryResult {
    /// Task succeeded with result
    Success(TaskResult),
    /// Task failed after max retries (contains last error message)
    MaxRetriesReached(String),
    /// Context length exceeded - should end current turn
    ContextLengthExceeded(String),
    /// Panic detected - should terminate
    Panic(anyhow::Error),
}

impl RetryResult {
    /// Check if the result is a success
    pub fn is_success(&self) -> bool {
        matches!(self, RetryResult::Success(_))
    }

    /// Get the task result if successful
    pub fn into_result(self) -> Option<TaskResult> {
        match self {
            RetryResult::Success(result) => Some(result),
            _ => None,
        }
    }
}

/// Callback for handling context length exceeded errors
pub type ContextExceededCallback<W> = Box<dyn FnOnce(&Agent<W>, &anyhow::Error, u32) + Send>;

/// Execute an agent task with retry logic
///
/// This function handles:
/// - Error classification (timeout, rate limit, server error, etc.)
/// - Exponential backoff between retries
/// - Context length exceeded errors (ends turn gracefully)
/// - Panic detection (terminates execution)
///
/// # Arguments
/// * `agent` - The agent to execute the task
/// * `prompt` - The task prompt
/// * `config` - Retry configuration
/// * `show_prompt` - Whether to show the prompt
/// * `show_code` - Whether to show code in output
/// * `discovery` - Optional discovery options
/// * `print_fn` - Function to print status messages
///
/// # Returns
/// A `RetryResult` indicating success, failure, or special conditions
pub async fn execute_with_retry<W, F>(
    agent: &mut Agent<W>,
    prompt: &str,
    config: &RetryConfig,
    show_prompt: bool,
    show_code: bool,
    discovery: Option<DiscoveryOptions<'_>>,
    mut print_fn: F,
) -> RetryResult
where
    W: UiWriter + Clone + Send + Sync + 'static,
    F: FnMut(&str),
{
    let mut retry_count = 0;
    let start_time = Instant::now();

    loop {
        let result = agent
            .execute_task_with_timing(prompt, None, false, show_prompt, show_code, true, discovery.clone())
            .await;

        match result {
            Ok(task_result) => {
                if retry_count > 0 {
                    info!(
                        "{} task succeeded after {} retries (elapsed: {:?})",
                        config.role_name,
                        retry_count,
                        start_time.elapsed()
                    );
                }
                return RetryResult::Success(task_result);
            }
            Err(e) => {
                let error_type = classify_error(&e);

                // Check for context length exceeded
                if matches!(
                    error_type,
                    ErrorType::Recoverable(RecoverableError::ContextLengthExceeded)
                ) {
                    let msg = format!(
                        "⚠️ Context length exceeded in {} turn: {}",
                        config.role_name, e
                    );
                    print_fn(&msg);
                    print_fn("📝 Logging error to session and ending current turn...");

                    // Log to session with forensic context
                    let forensic_context = format!(
                        "Role: {}\nContext tokens: {}\nTotal available: {}\nPercentage used: {:.1}%\nPrompt length: {} chars\nError occurred at: {}",
                        config.role_name,
                        agent.get_context_window().used_tokens,
                        agent.get_context_window().total_tokens,
                        agent.get_context_window().percentage_used(),
                        prompt.len(),
                        chrono::Utc::now().to_rfc3339()
                    );
                    agent.log_error_to_session(&e, "assistant", Some(forensic_context));

                    return RetryResult::ContextLengthExceeded(e.to_string());
                }

                // Check for panic
                if e.to_string().contains("panic") {
                    print_fn(&format!("💥 {} panic detected: {}", config.role_name, e));
                    return RetryResult::Panic(e);
                }

                // Check if error is recoverable
                match error_type {
                    ErrorType::Recoverable(ref recoverable_type) => {
                        retry_count += 1;

                        if retry_count >= config.max_retries {
                            let msg = format!(
                                "🔄 Max retries ({}) reached for {}",
                                config.max_retries, config.role_name
                            );
                            print_fn(&msg);
                            return RetryResult::MaxRetriesReached(e.to_string());
                        }

                        // Calculate backoff delay
                        let delay = calculate_retry_delay(retry_count, config.is_autonomous);

                        let msg = format!(
                            "⚠️ {} error (attempt {}/{}): {:?} - {}",
                            config.role_name, retry_count, config.max_retries, recoverable_type, e
                        );
                        print_fn(&msg);

                        let retry_msg = format!(
                            "🔄 Retrying {} in {:?}...",
                            config.role_name, delay
                        );
                        print_fn(&retry_msg);

                        warn!(
                            "Recoverable error ({:?}) in {} (attempt {}/{}). Retrying in {:?}...",
                            recoverable_type, config.role_name, retry_count, config.max_retries, delay
                        );

                        tokio::time::sleep(delay).await;
                    }
                    ErrorType::NonRecoverable => {
                        let msg = format!(
                            "❌ Non-recoverable error in {}: {}",
                            config.role_name, e
                        );
                        print_fn(&msg);
                        return RetryResult::MaxRetriesReached(e.to_string());
                    }
                }
            }
        }
    }
}

/// Execute a simple async operation with retry (for non-agent tasks)
///
/// This is a simpler retry wrapper for operations like LLM API calls
/// that don't involve the full agent machinery.
pub async fn retry_operation<F, Fut, T, P>(
    operation_name: &str,
    mut operation: F,
    max_retries: u32,
    is_autonomous: bool,
    mut print_fn: P,
) -> Result<T>
where
    F: FnMut() -> Fut,
    Fut: std::future::Future<Output = Result<T>>,
    P: FnMut(&str),
{
    let mut retry_count = 0;

    loop {
        match operation().await {
            Ok(result) => {
                if retry_count > 0 {
                    info!(
                        "Operation '{}' succeeded after {} retries",
                        operation_name, retry_count
                    );
                }
                return Ok(result);
            }
            Err(e) => {
                let error_type = classify_error(&e);

                match error_type {
                    ErrorType::Recoverable(ref recoverable_type) => {
                        retry_count += 1;

                        if retry_count >= max_retries {
                            let msg = format!(
                                "❌ Operation '{}' failed after {} retries: {}",
                                operation_name, retry_count, e
                            );
                            print_fn(&msg);
                            return Err(e);
                        }

                        let delay = calculate_retry_delay(retry_count, is_autonomous);
                        let msg = format!(
                            "⚠️ {} error in '{}' (attempt {}/{}), retrying in {:?}...",
                            format!("{:?}", recoverable_type),
                            operation_name,
                            retry_count,
                            max_retries,
                            delay
                        );
                        print_fn(&msg);

                        tokio::time::sleep(delay).await;
                    }
                    ErrorType::NonRecoverable => {
                        let msg = format!(
                            "❌ Non-recoverable error in '{}': {}",
                            operation_name, e
                        );
                        print_fn(&msg);
                        return Err(e);
                    }
                }
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_retry_config_defaults() {
        let config = RetryConfig::default();
        assert_eq!(config.max_retries, 3);
        assert!(!config.is_autonomous);
        assert_eq!(config.role_name, "agent");
    }

    #[test]
    fn test_retry_config_player() {
        let config = RetryConfig::player();
        assert_eq!(config.max_retries, 3);
        assert!(config.is_autonomous);
        assert_eq!(config.role_name, "player");
    }

    #[test]
    fn test_retry_config_coach() {
        let config = RetryConfig::coach();
        assert_eq!(config.max_retries, 3);
        assert!(config.is_autonomous);
        assert_eq!(config.role_name, "coach");
    }

    #[test]
    fn test_retry_config_with_max_retries() {
        let config = RetryConfig::player().with_max_retries(5);
        assert_eq!(config.max_retries, 5);
    }

    #[test]
    fn test_retry_result_is_success() {
        use crate::ContextWindow;
        let ctx = ContextWindow::new(1000);
        let result = RetryResult::Success(TaskResult::new("test".to_string(), ctx));
        assert!(result.is_success());

        let failed = RetryResult::MaxRetriesReached("error".to_string());
        assert!(!failed.is_success());
    }
}
