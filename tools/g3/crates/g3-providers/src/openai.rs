use anyhow::Result;
use async_trait::async_trait;
use bytes::Bytes;
use futures_util::stream::StreamExt;
use reqwest::Client;
use reqwest::header::CONTENT_TYPE;
use serde::Deserialize;
use serde_json::json;
use tokio::sync::mpsc;
use tokio_stream::wrappers::ReceiverStream;
use tracing::{debug, error};

use crate::{
    CompletionChunk, CompletionRequest, CompletionResponse, CompletionStream, LLMProvider, Message,
    MessageRole, Tool, ToolCall, Usage,
};

#[derive(Debug, Default)]
struct SseParseOutcome {
    usage: Option<Usage>,
    tool_calls: Option<Vec<ToolCall>>,
    saw_any_sse_data: bool,
    saw_content_delta: bool,
    saw_tool_delta: bool,
    saw_done: bool,
    buffered_tail: String,
}

#[derive(Clone)]
pub struct OpenAIProvider {
    client: Client,
    api_key: String,
    model: String,
    base_url: String,
    max_tokens: Option<u32>,
    _temperature: Option<f32>,
    name: String,
}

impl OpenAIProvider {
    pub fn new(
        api_key: String,
        model: Option<String>,
        base_url: Option<String>,
        max_tokens: Option<u32>,
        temperature: Option<f32>,
    ) -> Result<Self> {
        Self::new_with_name(
            "openai".to_string(),
            api_key,
            model,
            base_url,
            max_tokens,
            temperature,
        )
    }

    pub fn new_with_name(
        name: String,
        api_key: String,
        model: Option<String>,
        base_url: Option<String>,
        max_tokens: Option<u32>,
        temperature: Option<f32>,
    ) -> Result<Self> {
        Ok(Self {
            client: Client::new(),
            api_key,
            model: model.unwrap_or_else(|| "gpt-4o".to_string()),
            base_url: base_url.unwrap_or_else(|| "https://api.openai.com/v1".to_string()),
            max_tokens,
            _temperature: temperature,
            name,
        })
    }

    fn create_request_body(
        &self,
        messages: &[Message],
        tools: Option<&[Tool]>,
        stream: bool,
        max_tokens: Option<u32>,
        _temperature: Option<f32>,
    ) -> serde_json::Value {
        let mut body = json!({
            "model": self.model,
            "messages": convert_messages(messages),
            "stream": stream,
        });

        if let Some(max_tokens) = max_tokens.or(self.max_tokens) {
            body["max_completion_tokens"] = json!(max_tokens);
        }

        // OpenAI calls with temp setting seem to fail, so don't send one.
        // if let Some(temperature) = temperature.or(self.temperature) {
        //     body["temperature"] = json!(temperature);
        // }

        if let Some(tools) = tools {
            if !tools.is_empty() {
                body["tools"] = json!(convert_tools(tools));
            }
        }

        if stream {
            body["stream_options"] = json!({
                "include_usage": true,
            });
        }

        body
    }

    async fn parse_sse_stream(
        &self,
        mut stream: impl futures_util::Stream<Item = reqwest::Result<Bytes>> + Unpin,
        tx: &mpsc::Sender<Result<CompletionChunk>>,
    ) -> SseParseOutcome {
        let mut buffer = String::new();
        let mut accumulated_usage: Option<Usage> = None;
        let mut current_tool_calls: Vec<OpenAIStreamingToolCall> = Vec::new();
        let mut saw_any_sse_data = false;
        let mut saw_content_delta = false;
        let mut saw_tool_delta = false;
        let mut saw_done = false;

        while let Some(chunk_result) = stream.next().await {
            match chunk_result {
                Ok(chunk) => {
                    let chunk_str = match std::str::from_utf8(&chunk) {
                        Ok(s) => s,
                        Err(e) => {
                            error!("Failed to parse chunk as UTF-8: {}", e);
                            continue;
                        }
                    };

                    buffer.push_str(chunk_str);

                    // Process complete lines
                    while let Some(line_end) = buffer.find('\n') {
                        let line = buffer[..line_end].trim().to_string();
                        buffer.drain(..line_end + 1);

                        if line.is_empty() {
                            continue;
                        }

                        // Parse Server-Sent Events format (some proxies omit the space after `data:`)
                        if let Some(data) = line.strip_prefix("data:") {
                            saw_any_sse_data = true;
                            let data = data.trim();
                            if data.is_empty() {
                                continue;
                            }

                            if data == "[DONE]" {
                                debug!("Received stream completion marker");
                                saw_done = true;
                                break;
                            }

                            // Parse the JSON data
                            match serde_json::from_str::<OpenAIStreamChunk>(data) {
                                Ok(chunk_data) => {
                                    // Handle content (some proxies stream "thinking" in `reasoning_content`)
                                    for choice in &chunk_data.choices {
                                        if let Some(content) = &choice.delta.content {
                                            if !content.is_empty() {
                                                saw_content_delta = true;

                                                let chunk = CompletionChunk {
                                                    content: content.clone(),
                                                    finished: false,
                                                    tool_calls: None,
                                                    usage: None,
                                                };
                                                if tx.send(Ok(chunk)).await.is_err() {
                                                    debug!("Receiver dropped, stopping stream");
                                                    return SseParseOutcome::default();
                                                }
                                            }
                                        }

                                        if let Some(reasoning) = &choice.delta.reasoning_content {
                                            if !reasoning.is_empty() {
                                                saw_content_delta = true;

                                                let chunk = CompletionChunk {
                                                    content: reasoning.clone(),
                                                    finished: false,
                                                    tool_calls: None,
                                                    usage: None,
                                                };
                                                if tx.send(Ok(chunk)).await.is_err() {
                                                    debug!("Receiver dropped, stopping stream");
                                                    return SseParseOutcome::default();
                                                }
                                            }
                                        }

                                        // Handle tool calls
                                        if let Some(delta_tool_calls) = &choice.delta.tool_calls {
                                            if !delta_tool_calls.is_empty() {
                                                saw_tool_delta = true;
                                            }
                                            for delta_tool_call in delta_tool_calls {
                                                if let Some(index) = delta_tool_call.index {
                                                    // Ensure we have enough tool calls in our vector
                                                    while current_tool_calls.len() <= index {
                                                        current_tool_calls.push(
                                                            OpenAIStreamingToolCall::default(),
                                                        );
                                                    }

                                                    let tool_call = &mut current_tool_calls[index];

                                                    if let Some(id) = &delta_tool_call.id {
                                                        tool_call.id = Some(id.clone());
                                                    }

                                                    if let Some(function) =
                                                        &delta_tool_call.function
                                                    {
                                                        if let Some(name) = &function.name {
                                                            tool_call.name = Some(name.clone());
                                                        }
                                                        if let Some(arguments) = &function.arguments
                                                        {
                                                            tool_call.arguments.push_str(arguments);
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // Handle usage
                                    if let Some(usage) = chunk_data.usage {
                                        accumulated_usage = Some(Usage {
                                            prompt_tokens: usage.prompt_tokens,
                                            completion_tokens: usage.completion_tokens,
                                            total_tokens: usage.total_tokens,
                                        });
                                    }
                                }
                                Err(e) => {
                                    debug!("Failed to parse stream chunk: {} - Data: {}", e, data);
                                }
                            }
                        }
                    }

                    if saw_done {
                        break;
                    }
                }
                Err(e) => {
                    error!("Stream error: {}", e);
                    let _ = tx
                        .send(Err(anyhow::anyhow!("Stream error: {}", e)))
                        .await;
                    return SseParseOutcome::default();
                }
            }
        }

        let tool_calls = if current_tool_calls.is_empty() {
            None
        } else {
            Some(
                current_tool_calls
                    .iter()
                    .filter_map(|tc| tc.to_tool_call())
                    .collect(),
            )
        };

        SseParseOutcome {
            usage: accumulated_usage,
            tool_calls,
            saw_any_sse_data,
            saw_content_delta,
            saw_tool_delta,
            saw_done,
            buffered_tail: buffer,
        }
    }
}

#[async_trait]
impl LLMProvider for OpenAIProvider {
    async fn complete(&self, request: CompletionRequest) -> Result<CompletionResponse> {
        debug!(
            "Processing OpenAI completion request with {} messages",
            request.messages.len()
        );

        let body = self.create_request_body(
            &request.messages,
            request.tools.as_deref(),
            false,
            request.max_tokens,
            request.temperature,
        );

        debug!("Sending request to OpenAI API: model={}", self.model);

        let response = self
            .client
            .post(format!("{}/chat/completions", self.base_url))
            .header("Authorization", format!("Bearer {}", self.api_key))
            .json(&body)
            .send()
            .await?;

        let status = response.status();
        if !status.is_success() {
            let error_text = response
                .text()
                .await
                .unwrap_or_else(|_| "Unknown error".to_string());
            return Err(anyhow::anyhow!(
                "OpenAI API error {}: {}",
                status,
                error_text
            ));
        }

        let openai_response: OpenAIResponse = response.json().await?;

        let content = openai_response
            .choices
            .first()
            .and_then(|choice| choice.message.content.clone())
            .unwrap_or_default();

        let usage = Usage {
            prompt_tokens: openai_response.usage.prompt_tokens,
            completion_tokens: openai_response.usage.completion_tokens,
            total_tokens: openai_response.usage.total_tokens,
        };

        debug!(
            "OpenAI completion successful: {} tokens generated",
            usage.completion_tokens
        );

        Ok(CompletionResponse {
            content,
            usage,
            model: self.model.clone(),
        })
    }

    async fn stream(&self, request: CompletionRequest) -> Result<CompletionStream> {
        debug!(
            "Processing OpenAI streaming request with {} messages",
            request.messages.len()
        );

        let body_stream = self.create_request_body(
            &request.messages,
            request.tools.as_deref(),
            true,
            request.max_tokens,
            request.temperature,
        );

        let body_non_stream = self.create_request_body(
            &request.messages,
            request.tools.as_deref(),
            false,
            request.max_tokens,
            request.temperature,
        );

        debug!(
            "Sending streaming request to OpenAI API: model={}",
            self.model
        );

        let response = self
            .client
            .post(format!("{}/chat/completions", self.base_url))
            .header("Authorization", format!("Bearer {}", self.api_key))
            .json(&body_stream)
            .send()
            .await?;

        let status = response.status();
        if !status.is_success() {
            let error_text = response
                .text()
                .await
                .unwrap_or_else(|_| "Unknown error".to_string());
            return Err(anyhow::anyhow!(
                "OpenAI API error {}: {}",
                status,
                error_text
            ));
        }

        let (tx, rx) = mpsc::channel(100);

        // If the server didn't return SSE, fall back to parsing a single JSON response and emit it
        // as a synthetic stream. This commonly happens behind "OpenAI-compatible" proxies.
        let provider = self.clone();
        let content_type = response
            .headers()
            .get(CONTENT_TYPE)
            .and_then(|v| v.to_str().ok())
            .unwrap_or("");

        if !content_type.contains("text/event-stream") {
            tokio::spawn(async move { emit_non_stream_response(response, &tx).await });

            return Ok(ReceiverStream::new(rx));
        }

        let stream = response.bytes_stream();

        // Spawn task to process the stream
        tokio::spawn(async move {
            let outcome = provider.parse_sse_stream(stream, &tx).await;

            // Some proxies return a "valid" SSE stream that immediately finishes (often only `[DONE]`)
            // without any content/tool deltas. In that case, transparently retry non-streaming.
            let saw_semantic_output = outcome.saw_content_delta || outcome.tool_calls.is_some();
            if outcome.saw_any_sse_data && outcome.saw_done && !saw_semantic_output {
                debug!("SSE stream finished without any content/tool output; retrying as non-stream");
                match provider
                    .client
                    .post(format!("{}/chat/completions", provider.base_url))
                    .header("Authorization", format!("Bearer {}", provider.api_key))
                    .json(&body_non_stream)
                    .send()
                    .await
                {
                    Ok(resp) => {
                        emit_non_stream_response(resp, &tx).await;
                    }
                    Err(e) => {
                        let _ = tx
                            .send(Err(anyhow::anyhow!(
                                "Empty SSE stream and non-stream retry failed: {}",
                                e
                            )))
                            .await;
                    }
                }
                return;
            }

            // Fallback: some proxies ignore stream=true but still set text/event-stream;
            // if we never saw any SSE data lines but have buffered JSON, try to parse it.
            let buffered = outcome.buffered_tail.trim();
            if !outcome.saw_any_sse_data && !buffered.is_empty() && !saw_semantic_output {
                if let Ok(resp) = serde_json::from_str::<OpenAIResponse>(buffered) {
                    let (content, tool_calls) = extract_non_stream_content_and_tools(&resp);
                    let usage = Usage {
                        prompt_tokens: resp.usage.prompt_tokens,
                        completion_tokens: resp.usage.completion_tokens,
                        total_tokens: resp.usage.total_tokens,
                    };

                    if !content.is_empty() {
                        let _ = tx
                            .send(Ok(CompletionChunk {
                                content,
                                finished: false,
                                tool_calls: None,
                                usage: None,
                            }))
                            .await;
                    }

                    let _ = tx
                        .send(Ok(CompletionChunk {
                            content: String::new(),
                            finished: true,
                            tool_calls,
                            usage: Some(usage),
                        }))
                        .await;
                    return;
                }
            }

            // Normal finish: emit final marker with tool calls/usage.
            let final_chunk = CompletionChunk {
                content: String::new(),
                finished: true,
                tool_calls: outcome.tool_calls,
                usage: outcome.usage.clone(),
            };
            let _ = tx.send(Ok(final_chunk)).await;

            if let Some(usage) = outcome.usage {
                debug!(
                    "Stream completed with usage - prompt: {}, completion: {}, total: {}",
                    usage.prompt_tokens, usage.completion_tokens, usage.total_tokens
                );
            }
        });

        Ok(ReceiverStream::new(rx))
    }

    fn name(&self) -> &str {
        &self.name
    }

    fn model(&self) -> &str {
        &self.model
    }

    fn has_native_tool_calling(&self) -> bool {
        // OpenAI models support native tool calling
        true
    }

    fn max_tokens(&self) -> u32 {
        self.max_tokens.unwrap_or(16000)
    }

    fn temperature(&self) -> f32 {
        self._temperature.unwrap_or(0.1)
    }
}

fn convert_messages(messages: &[Message]) -> Vec<serde_json::Value> {
    messages
        .iter()
        .map(|msg| {
            json!({
                "role": match msg.role {
                    MessageRole::System => "system",
                    MessageRole::User => "user",
                    MessageRole::Assistant => "assistant",
                },
                "content": msg.content,
            })
        })
        .collect()
}

fn convert_tools(tools: &[Tool]) -> Vec<serde_json::Value> {
    tools
        .iter()
        .map(|tool| {
            json!({
                "type": "function",
                "function": {
                    "name": tool.name,
                    "description": tool.description,
                    "parameters": tool.input_schema,
                }
            })
        })
        .collect()
}

async fn emit_non_stream_response(
    response: reqwest::Response,
    tx: &mpsc::Sender<Result<CompletionChunk>>,
) {
    let status = response.status();
    if !status.is_success() {
        let error_text = response
            .text()
            .await
            .unwrap_or_else(|_| "Unknown error".to_string());
        let _ = tx
            .send(Err(anyhow::anyhow!(
                "OpenAI API error {}: {}",
                status,
                error_text
            )))
            .await;
        return;
    }

    match response.text().await {
        Ok(text) => match serde_json::from_str::<OpenAIResponse>(&text) {
            Ok(resp) => {
                let (content, tool_calls) = extract_non_stream_content_and_tools(&resp);
                let usage = Usage {
                    prompt_tokens: resp.usage.prompt_tokens,
                    completion_tokens: resp.usage.completion_tokens,
                    total_tokens: resp.usage.total_tokens,
                };

                if !content.is_empty() {
                    let _ = tx
                        .send(Ok(CompletionChunk {
                            content,
                            finished: false,
                            tool_calls: None,
                            usage: None,
                        }))
                        .await;
                }

                let _ = tx
                    .send(Ok(CompletionChunk {
                        content: String::new(),
                        finished: true,
                        tool_calls,
                        usage: Some(usage),
                    }))
                    .await;
            }
            Err(e) => {
                let _ = tx
                    .send(Err(anyhow::anyhow!(
                        "Non-streaming response failed to parse: {}",
                        e
                    )))
                    .await;
            }
        },
        Err(e) => {
            let _ = tx
                .send(Err(anyhow::anyhow!(
                    "Failed to read non-streaming response body: {}",
                    e
                )))
                .await;
        }
    }
}

fn extract_non_stream_content_and_tools(
    resp: &OpenAIResponse,
) -> (String, Option<Vec<ToolCall>>) {
    let choice = match resp.choices.first() {
        Some(c) => c,
        None => return (String::new(), None),
    };

    let content = choice.message.content.clone().unwrap_or_default();

    let tool_calls = match &choice.message.tool_calls {
        Some(calls) if !calls.is_empty() => {
            let converted: Vec<ToolCall> = calls
                .iter()
                .filter_map(|tc| {
                    let args =
                        serde_json::from_str(&tc.function.arguments).unwrap_or(serde_json::Value::Null);
                    Some(ToolCall {
                        id: tc.id.clone(),
                        tool: tc.function.name.clone(),
                        args,
                    })
                })
                .collect();
            if converted.is_empty() {
                None
            } else {
                Some(converted)
            }
        }
        _ => None,
    };

    (content, tool_calls)
}

#[cfg(test)]
mod streaming_tests {
    use super::OpenAIProvider;
    use crate::CompletionChunk;
    use bytes::Bytes;
    use futures_util::stream;
    use tokio::sync::mpsc;

    fn sse_line(json: &str) -> Bytes {
        Bytes::from(format!("data: {}\n\n", json))
    }

    #[tokio::test]
    async fn does_not_duplicate_content_on_done() {
        let provider = OpenAIProvider::new_with_name(
            "openai.test".to_string(),
            "sk-test".to_string(),
            Some("gpt-4o".to_string()),
            Some("http://example.invalid/v1".to_string()),
            Some(128),
            None,
        )
        .unwrap();

        let chunk_1 = r#"{"choices":[{"delta":{"content":"Oi"}}]}"#;
        let chunk_2 = r#"{"choices":[{"delta":{"content":"!"}}]}"#;
        let done = Bytes::from("data: [DONE]\n\n");

        let input = stream::iter(vec![Ok(sse_line(chunk_1)), Ok(sse_line(chunk_2)), Ok(done)]);

        let (tx, mut rx) = mpsc::channel::<anyhow::Result<CompletionChunk>>(16);
        let outcome = provider.parse_sse_stream(input, &tx).await;

        let final_chunk = CompletionChunk {
            content: String::new(),
            finished: true,
            tool_calls: outcome.tool_calls,
            usage: outcome.usage,
        };
        let _ = tx.send(Ok(final_chunk)).await;

        let mut seen = Vec::new();
        while let Some(item) = rx.recv().await {
            let chunk = item.unwrap();
            seen.push((chunk.content, chunk.finished));
            if chunk.finished {
                break;
            }
        }

        // We should see the two deltas, then a finished marker with empty content.
        assert_eq!(
            seen,
            vec![
                ("Oi".to_string(), false),
                ("!".to_string(), false),
                (String::new(), true)
            ]
        );
    }

    #[tokio::test]
    async fn supports_reasoning_content_streaming() {
        let provider = OpenAIProvider::new_with_name(
            "openai.test".to_string(),
            "sk-test".to_string(),
            Some("gpt-4o".to_string()),
            Some("http://example.invalid/v1".to_string()),
            Some(128),
            None,
        )
        .unwrap();

        let chunk_1 = r#"{"choices":[{"delta":{"reasoning_content":"think"}}]}"#;
        let chunk_2 = r#"{"choices":[{"delta":{"reasoning_content":"ing"}}]}"#;
        let done = Bytes::from("data: [DONE]\n\n");

        let input = stream::iter(vec![Ok(sse_line(chunk_1)), Ok(sse_line(chunk_2)), Ok(done)]);

        let (tx, mut rx) = mpsc::channel::<anyhow::Result<CompletionChunk>>(16);
        let outcome = provider.parse_sse_stream(input, &tx).await;

        let final_chunk = CompletionChunk {
            content: String::new(),
            finished: true,
            tool_calls: outcome.tool_calls,
            usage: outcome.usage,
        };
        let _ = tx.send(Ok(final_chunk)).await;

        let mut out = String::new();
        while let Some(item) = rx.recv().await {
            let chunk = item.unwrap();
            out.push_str(&chunk.content);
            if chunk.finished {
                break;
            }
        }

        assert!(out.contains("thinking"));
    }
}

// OpenAI API response structures
#[derive(Debug, Deserialize)]
struct OpenAIResponse {
    choices: Vec<OpenAIChoice>,
    usage: OpenAIUsage,
}

#[derive(Debug, Deserialize)]
struct OpenAIChoice {
    message: OpenAIMessage,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct OpenAIMessage {
    content: Option<String>,
    #[serde(default)]
    tool_calls: Option<Vec<OpenAIToolCall>>,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct OpenAIToolCall {
    id: String,
    function: OpenAIFunction,
}

#[allow(dead_code)]
#[derive(Debug, Deserialize)]
struct OpenAIFunction {
    name: String,
    arguments: String,
}

// Streaming tool call accumulator
#[derive(Debug, Default)]
struct OpenAIStreamingToolCall {
    id: Option<String>,
    name: Option<String>,
    arguments: String,
}

impl OpenAIStreamingToolCall {
    fn to_tool_call(&self) -> Option<ToolCall> {
        let id = self.id.as_ref()?;
        let name = self.name.as_ref()?;

        let args = serde_json::from_str(&self.arguments).unwrap_or(serde_json::Value::Null);

        Some(ToolCall {
            id: id.clone(),
            tool: name.clone(),
            args,
        })
    }
}

#[derive(Debug, Deserialize)]
struct OpenAIUsage {
    prompt_tokens: u32,
    completion_tokens: u32,
    total_tokens: u32,
}

// Streaming response structures
#[derive(Debug, Deserialize)]
struct OpenAIStreamChunk {
    choices: Vec<OpenAIStreamChoice>,
    usage: Option<OpenAIUsage>,
}

#[derive(Debug, Deserialize)]
struct OpenAIStreamChoice {
    delta: OpenAIDelta,
}

#[derive(Debug, Deserialize)]
struct OpenAIDelta {
    content: Option<String>,
    #[serde(default)]
    reasoning_content: Option<String>,
    #[serde(default)]
    tool_calls: Option<Vec<OpenAIDeltaToolCall>>,
}

#[derive(Debug, Deserialize)]
struct OpenAIDeltaToolCall {
    index: Option<usize>,
    id: Option<String>,
    function: Option<OpenAIDeltaFunction>,
}

#[derive(Debug, Deserialize)]
struct OpenAIDeltaFunction {
    name: Option<String>,
    arguments: Option<String>,
}
