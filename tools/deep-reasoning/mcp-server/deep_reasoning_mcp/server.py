"""Deep Reasoning MCP Server."""

import asyncio
import logging
import os
import uuid
from datetime import datetime
from typing import Any, Optional

from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import TextContent, Tool

from .backends.chat2api_backend import Chat2ApiBackend
from .backends.gemini_backend import GeminiPlaywrightBackend
from .backends.playwright_chatgpt import (
    ChatGPTPlaywrightBackend,
    ChatGPTPlaywrightConfig,
)
from .config import load_config
from .models import (
    MODEL_PROVIDERS,
    ModelProvider,
    ModelResult,
    ReasoningModel,
    ReasoningTask,
    TaskStatus,
)
from .storage import TaskStorage

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Global state
_storage: Optional[TaskStorage] = None
_chat2api_backend: Optional[Chat2ApiBackend] = None
_chatgpt_playwright_backend: Optional[ChatGPTPlaywrightBackend] = None
_gemini_backend: Optional[GeminiPlaywrightBackend] = None
_background_tasks: dict[str, asyncio.Task] = {}


async def initialize_backends() -> None:
    """Initialize all backends and storage."""
    global _storage, _chat2api_backend, _chatgpt_playwright_backend, _gemini_backend

    config = load_config()

    # Initialize storage
    _storage = TaskStorage(config.storage)
    await _storage.initialize()
    logger.info("Storage initialized")

    # Initialize Chat2API backend (fast API mode)
    access_token = os.getenv("CHATGPT_ACCESS_TOKEN")
    _chat2api_backend = Chat2ApiBackend(config.chat2api, access_token=access_token)
    await _chat2api_backend.initialize()

    # Initialize Playwright backends only if USE_PLAYWRIGHT is set
    if os.getenv("USE_PLAYWRIGHT", "").lower() in ("1", "true", "yes"):
        # ChatGPT Playwright for real Deep Research
        chatgpt_config = ChatGPTPlaywrightConfig(
            headless=os.getenv("PLAYWRIGHT_HEADLESS", "").lower()
            in ("1", "true", "yes"),
        )
        _chatgpt_playwright_backend = ChatGPTPlaywrightBackend(chatgpt_config)
        await _chatgpt_playwright_backend.initialize()

        # Gemini Playwright for DeepThink
        _gemini_backend = GeminiPlaywrightBackend(config.gemini)
        await _gemini_backend.initialize()
    else:
        logger.info("Playwright backends disabled (set USE_PLAYWRIGHT=1 to enable)")


async def cleanup_backends() -> None:
    """Cleanup all backends."""
    global _storage, _chat2api_backend, _chatgpt_playwright_backend, _gemini_backend

    if _chat2api_backend:
        await _chat2api_backend.close()
    if _chatgpt_playwright_backend:
        await _chatgpt_playwright_backend.close()
    if _gemini_backend:
        await _gemini_backend.close()
    if _storage:
        await _storage.close()


def get_backend_for_model(model: ReasoningModel, use_playwright: bool = False):
    """Get the appropriate backend for a model."""
    provider = MODEL_PROVIDERS.get(model)
    if provider == ModelProvider.CHATGPT:
        if use_playwright and _chatgpt_playwright_backend:
            return _chatgpt_playwright_backend
        return _chat2api_backend
    elif provider == ModelProvider.GEMINI:
        return _gemini_backend
    return None


async def execute_task(task: ReasoningTask) -> None:
    """Execute a reasoning task by querying all specified models."""
    if not _storage:
        raise RuntimeError("Storage not initialized")

    task.status = TaskStatus.RUNNING
    task.started_at = datetime.now()
    await _storage.save_task(task)

    # Prepare system_hints
    system_hints = task.system_hints
    if task.deep_research and not system_hints:
        system_hints = ["research"]

    # Determine if we should use Playwright (for real browser-based Deep Research)
    use_playwright = task.use_playwright

    # Query each model
    for model in task.models:
        backend = get_backend_for_model(model, use_playwright=use_playwright)
        if not backend:
            task.results[model.value] = ModelResult(
                model=model,
                status=TaskStatus.FAILED,
                error=f"No backend for model {model}",
            )
            continue

        logger.info(
            f"Task {task.task_id}: Querying {model.value} (playwright={use_playwright})..."
        )

        result = await backend.query(model, task.question, task.context, system_hints)
        task.results[model.value] = result

        # Save response to file if successful
        if result.status == TaskStatus.COMPLETED and result.response:
            filepath = await _storage.save_response_file(
                task.task_id,
                model,
                result.response,
                result.thinking_process,
            )
            logger.info(f"Saved response to {filepath}")

        # Update task in storage
        await _storage.save_task(task)

    # Mark task complete
    task.status = TaskStatus.COMPLETED
    task.completed_at = datetime.now()
    await _storage.save_task(task)

    logger.info(f"Task {task.task_id} completed")


# Create MCP server
server = Server("deep-reasoning")


@server.list_tools()
async def list_tools() -> list[Tool]:
    """List available tools."""
    return [
        Tool(
            name="ask_deep",
            description="""Submit a complex question to deep reasoning models.

This sends your question to powerful reasoning models (GPT-5.2 Pro, O1-Pro, O3, Gemini DeepThink)
and returns a task_id. These models can take 5-20 minutes to respond.

Use get_task_status to check progress and get results.

Available models:
- gpt-5.2-pro: GPT-5.2 Pro (latest, recommended)
- gpt-5-pro: GPT-5 Pro (ChatGPT)
- o1-pro: O1 Pro reasoning model
- o1: O1 full model
- o1-mini: O1 Mini
- o3: O3 full model
- o3-mini: O3 Mini
- o3-mini-high: O3 Mini High
- gpt-4o: GPT-4o
- gemini-deepthink: Gemini DeepThink (not yet implemented)
- gemini-2.5-pro: Gemini 2.5 Pro (not yet implemented)

Special modes:
- deep_research: Enable Deep Research mode for comprehensive investigation
- system_hints: Pass custom hints like ["research"] or ["reason"]""",
            inputSchema={
                "type": "object",
                "properties": {
                    "question": {
                        "type": "string",
                        "description": "The complex question or prompt to reason about",
                    },
                    "models": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "List of models to query. Default: ['gpt-5.2-pro']",
                        "default": ["gpt-5.2-pro"],
                    },
                    "context": {
                        "type": "string",
                        "description": "Optional additional context or system prompt",
                    },
                    "priority": {
                        "type": "integer",
                        "description": "Priority 0-10 (10=urgent). Default: 0",
                        "default": 0,
                    },
                    "wait": {
                        "type": "boolean",
                        "description": "If true, wait for completion. If false, return task_id immediately. Default: false",
                        "default": False,
                    },
                    "deep_research": {
                        "type": "boolean",
                        "description": "Enable Deep Research mode for comprehensive multi-source investigation. Default: false",
                        "default": False,
                    },
                    "system_hints": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "Custom system hints: ['research'] for Deep Research, ['reason'] for extended thinking",
                    },
                    "use_playwright": {
                        "type": "boolean",
                        "description": "Use Playwright browser automation for REAL Deep Research (takes 10-20 min). Requires USE_PLAYWRIGHT=1 env var. Default: false",
                        "default": False,
                    },
                },
                "required": ["question"],
            },
        ),
        Tool(
            name="get_task_status",
            description="Get the status and results of a reasoning task.",
            inputSchema={
                "type": "object",
                "properties": {
                    "task_id": {
                        "type": "string",
                        "description": "The task ID returned by ask_deep",
                    },
                },
                "required": ["task_id"],
            },
        ),
        Tool(
            name="list_tasks",
            description="List all reasoning tasks with their status.",
            inputSchema={
                "type": "object",
                "properties": {
                    "status": {
                        "type": "string",
                        "enum": ["pending", "running", "completed", "failed"],
                        "description": "Filter by status (optional)",
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Max number of tasks to return. Default: 20",
                        "default": 20,
                    },
                },
            },
        ),
        Tool(
            name="cancel_task",
            description="Cancel a pending or running task.",
            inputSchema={
                "type": "object",
                "properties": {
                    "task_id": {
                        "type": "string",
                        "description": "The task ID to cancel",
                    },
                },
                "required": ["task_id"],
            },
        ),
        Tool(
            name="available_models",
            description="List all available reasoning models and their status.",
            inputSchema={"type": "object", "properties": {}},
        ),
    ]


@server.call_tool()
async def call_tool(name: str, arguments: dict[str, Any]) -> list[TextContent]:
    """Handle tool calls."""
    if not _storage:
        await initialize_backends()

    if name == "ask_deep":
        return await handle_ask_deep(arguments)
    elif name == "get_task_status":
        return await handle_get_task_status(arguments)
    elif name == "list_tasks":
        return await handle_list_tasks(arguments)
    elif name == "cancel_task":
        return await handle_cancel_task(arguments)
    elif name == "available_models":
        return await handle_available_models()
    else:
        return [TextContent(type="text", text=f"Unknown tool: {name}")]


async def handle_ask_deep(args: dict[str, Any]) -> list[TextContent]:
    """Handle ask_deep tool call."""
    if not _storage:
        return [TextContent(type="text", text="Error: Storage not initialized")]

    question = args["question"]
    model_names = args.get("models", ["gpt-5.2-pro"])
    context = args.get("context")
    priority = args.get("priority", 0)
    wait = args.get("wait", False)
    deep_research = args.get("deep_research", False)
    system_hints = args.get("system_hints")
    use_playwright = args.get("use_playwright", False)

    # Parse models
    models = []
    for name in model_names:
        try:
            models.append(ReasoningModel(name))
        except ValueError:
            return [
                TextContent(
                    type="text",
                    text=f"Error: Unknown model '{name}'. Use available_models to see valid options.",
                )
            ]

    # Create task with Deep Research options
    task_id = str(uuid.uuid4())[:8]
    task = ReasoningTask(
        task_id=task_id,
        question=question,
        models=models,
        context=context,
        priority=priority,
        deep_research=deep_research,
        system_hints=system_hints,
        use_playwright=use_playwright,
    )

    await _storage.save_task(task)

    # Build mode description
    mode_desc = ""
    if use_playwright:
        mode_desc = "\n**Mode:** Playwright Deep Research (REAL browser, 10-20 min)"
    elif deep_research:
        mode_desc = "\n**Mode:** Deep Research (API mode, faster)"
    elif system_hints:
        mode_desc = f"\n**System Hints:** {system_hints}"

    logger.info(
        f"Created task {task_id} for models: {[m.value for m in models]} (deep_research={deep_research}, playwright={use_playwright})"
    )

    if wait:
        # Execute synchronously
        await execute_task(task)
        return await handle_get_task_status({"task_id": task_id})
    else:
        # Execute in background
        bg_task = asyncio.create_task(execute_task(task))
        _background_tasks[task_id] = bg_task

        return [
            TextContent(
                type="text",
                text=f"""Task submitted successfully!

**Task ID:** {task_id}
**Models:** {", ".join(m.value for m in models)}
**Status:** pending{mode_desc}

The models will process your question in the background. This may take 5-20 minutes.
{"Deep Research mode is enabled - this may take longer for comprehensive results." if deep_research else ""}
Use `get_task_status` with task_id="{task_id}" to check progress and get results.

Responses will be saved to: ~/.deep-reasoning/responses/{task_id}/""",
            )
        ]


async def handle_get_task_status(args: dict[str, Any]) -> list[TextContent]:
    """Handle get_task_status tool call."""
    if not _storage:
        return [TextContent(type="text", text="Error: Storage not initialized")]

    task_id = args["task_id"]
    task = await _storage.get_task(task_id)

    if not task:
        return [TextContent(type="text", text=f"Error: Task '{task_id}' not found")]

    # Build status report
    lines = [
        f"# Task {task.task_id}",
        f"**Status:** {task.status.value}",
        f"**Created:** {task.created_at.isoformat()}",
        "",
        f"**Question:** {task.question[:200]}{'...' if len(task.question) > 200 else ''}",
        "",
        "## Model Results",
        "",
    ]

    for model in task.models:
        result = task.results.get(model.value)
        if result:
            lines.append(f"### {model.value}")
            lines.append(f"- Status: {result.status.value}")
            if result.duration_seconds:
                lines.append(f"- Duration: {result.duration_seconds:.1f}s")
            if result.error:
                lines.append(f"- Error: {result.error}")
            if result.response:
                preview = result.response[:500]
                if len(result.response) > 500:
                    preview += f"\n\n... ({len(result.response)} chars total)"
                lines.append(f"- Response preview:\n```\n{preview}\n```")
            lines.append("")
        else:
            lines.append(f"### {model.value}")
            lines.append("- Status: waiting")
            lines.append("")

    if task.save_path:
        lines.append(f"**Full responses saved to:** {task.save_path}")

    return [TextContent(type="text", text="\n".join(lines))]


async def handle_list_tasks(args: dict[str, Any]) -> list[TextContent]:
    """Handle list_tasks tool call."""
    if not _storage:
        return [TextContent(type="text", text="Error: Storage not initialized")]

    status_filter = None
    if status_str := args.get("status"):
        status_filter = TaskStatus(status_str)

    limit = args.get("limit", 20)

    summaries = await _storage.list_tasks(status_filter, limit)

    if not summaries:
        return [TextContent(type="text", text="No tasks found.")]

    lines = ["# Reasoning Tasks", ""]
    for s in summaries:
        lines.append(
            f"- **{s.task_id}** [{s.status.value}] "
            f"({s.completed_count}/{s.total_count} models) - "
            f"{s.question_preview[:50]}..."
        )

    return [TextContent(type="text", text="\n".join(lines))]


async def handle_cancel_task(args: dict[str, Any]) -> list[TextContent]:
    """Handle cancel_task tool call."""
    if not _storage:
        return [TextContent(type="text", text="Error: Storage not initialized")]

    task_id = args["task_id"]

    # Cancel background task if running
    if bg_task := _background_tasks.get(task_id):
        bg_task.cancel()
        del _background_tasks[task_id]

    task = await _storage.get_task(task_id)
    if task:
        task.status = TaskStatus.CANCELLED
        await _storage.save_task(task)
        return [TextContent(type="text", text=f"Task {task_id} cancelled.")]

    return [TextContent(type="text", text=f"Task {task_id} not found.")]


async def handle_available_models() -> list[TextContent]:
    """Handle available_models tool call."""
    lines = [
        "# Available Deep Reasoning Models",
        "",
        "## ChatGPT Models (via chat2api)",
        "| Model | Description | Status |",
        "|-------|-------------|--------|",
        "| gpt-5.2-pro | GPT-5.2 Pro (latest) | Ready ✓ |",
        "| gpt-5-pro | GPT-5 Pro | Ready ✓ |",
        "| o1-pro | O1 Pro reasoning | Ready (Pro account required) |",
        "| o1 | O1 full model | Ready ✓ |",
        "| o1-mini | O1 Mini | Ready ✓ |",
        "| o3 | O3 full model | Ready ✓ |",
        "| o3-mini | O3 Mini | Ready ✓ |",
        "| o3-mini-high | O3 Mini High | Ready ✓ |",
        "| gpt-4o | GPT-4o | Ready ✓ |",
        "",
        "## Gemini Models (via Playwright)",
        "| Model | Description | Status |",
        "|-------|-------------|--------|",
        "| gemini-deepthink | Gemini DeepThink | Not Yet Implemented |",
        "| gemini-2.5-pro | Gemini 2.5 Pro | Not Yet Implemented |",
        "",
        "## Special Modes",
        "",
        "### Deep Research",
        "Enable comprehensive multi-source investigation:",
        "```",
        "ask_deep(question='...', deep_research=true)",
        "```",
        "",
        "### Extended Thinking/Reasoning",
        "Enable extended thinking mode:",
        "```",
        "ask_deep(question='...', system_hints=['reason'])",
        "```",
        "",
        "## Setup",
        "",
        "Uses Codex tokens from ~/.cli-proxy-api/codex-*.json (auto-rotation).",
        "Or set CHATGPT_ACCESS_TOKEN env var for manual token.",
    ]

    return [TextContent(type="text", text="\n".join(lines))]


async def run_server() -> None:
    """Run the MCP server."""
    await initialize_backends()

    try:
        async with stdio_server() as (read_stream, write_stream):
            await server.run(
                read_stream, write_stream, server.create_initialization_options()
            )
    finally:
        await cleanup_backends()


def main() -> None:
    """Entry point."""
    asyncio.run(run_server())


if __name__ == "__main__":
    main()
