"""Data models for Deep Reasoning MCP."""

from datetime import datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, Field


class TaskStatus(str, Enum):
    """Status of a reasoning task."""

    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"
    NEEDS_CLARIFICATION = "needs_clarification"  # GPT asked a follow-up question


class ModelProvider(str, Enum):
    """Available model providers."""

    CHATGPT = "chatgpt"  # via chat2api
    GEMINI = "gemini"  # via playwright


class ReasoningModel(str, Enum):
    """Available reasoning models."""

    # ChatGPT models (via chat2api)
    GPT_5_PRO = "gpt-5-pro"
    GPT_5_2_PRO = "gpt-5.2-pro"  # Latest GPT-5.2 PRO
    O1_PRO = "o1-pro"
    O1 = "o1"  # O1 full model
    O1_MINI = "o1-mini"
    O3 = "o3"  # O3 full model
    O3_MINI = "o3-mini"
    O3_MINI_HIGH = "o3-mini-high"
    GPT_4O = "gpt-4o"

    # Gemini models (via playwright)
    GEMINI_DEEPTHINK = "gemini-deepthink"
    GEMINI_2_5_PRO = "gemini-2.5-pro"


# Model to provider mapping
MODEL_PROVIDERS: dict[ReasoningModel, ModelProvider] = {
    ReasoningModel.GPT_5_PRO: ModelProvider.CHATGPT,
    ReasoningModel.GPT_5_2_PRO: ModelProvider.CHATGPT,
    ReasoningModel.O1_PRO: ModelProvider.CHATGPT,
    ReasoningModel.O1: ModelProvider.CHATGPT,
    ReasoningModel.O1_MINI: ModelProvider.CHATGPT,
    ReasoningModel.O3: ModelProvider.CHATGPT,
    ReasoningModel.O3_MINI: ModelProvider.CHATGPT,
    ReasoningModel.O3_MINI_HIGH: ModelProvider.CHATGPT,
    ReasoningModel.GPT_4O: ModelProvider.CHATGPT,
    ReasoningModel.GEMINI_DEEPTHINK: ModelProvider.GEMINI,
    ReasoningModel.GEMINI_2_5_PRO: ModelProvider.GEMINI,
}


class ReasoningTask(BaseModel):
    """A reasoning task submitted to the system."""

    task_id: str = Field(description="Unique task identifier")
    question: str = Field(description="The question/prompt to reason about")
    models: list[ReasoningModel] = Field(description="Models to query")
    status: TaskStatus = Field(default=TaskStatus.PENDING)
    created_at: datetime = Field(default_factory=datetime.now)
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    priority: int = Field(default=0, ge=0, le=10, description="0=normal, 10=urgent")

    # Results per model
    results: dict[str, "ModelResult"] = Field(default_factory=dict)

    # Metadata
    context: Optional[str] = Field(default=None, description="Additional context")
    save_path: Optional[str] = Field(
        default=None, description="Path to saved response file"
    )

    # Deep Research / Extended mode options
    system_hints: Optional[list[str]] = Field(
        default=None,
        description="System hints for special modes: 'research' for Deep Research, 'reason' for extended thinking",
    )
    deep_research: bool = Field(
        default=False,
        description="Enable Deep Research mode (sets system_hint='research')",
    )
    use_playwright: bool = Field(
        default=False,
        description="Use Playwright browser automation for real Deep Research (slower but authentic)",
    )


class ModelResult(BaseModel):
    """Result from a single model."""

    model: ReasoningModel
    status: TaskStatus = Field(default=TaskStatus.PENDING)
    response: Optional[str] = None
    thinking_process: Optional[str] = Field(
        default=None, description="Reasoning steps if available"
    )
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    duration_seconds: Optional[float] = None
    error: Optional[str] = None
    tokens_used: Optional[int] = None

    # For interactive conversations
    clarification_question: Optional[str] = Field(
        default=None,
        description="Question from GPT if status=NEEDS_CLARIFICATION",
    )
    conversation_id: Optional[str] = Field(
        default=None,
        description="ID to continue the conversation",
    )


class TaskSummary(BaseModel):
    """Summary of a task for listing."""

    task_id: str
    question_preview: str = Field(description="First 100 chars of question")
    models: list[str]
    status: TaskStatus
    created_at: datetime
    completed_count: int = Field(description="How many models completed")
    total_count: int = Field(description="Total models requested")
