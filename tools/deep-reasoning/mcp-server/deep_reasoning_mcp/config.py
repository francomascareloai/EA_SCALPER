"""Configuration for Deep Reasoning MCP."""

import os
from pathlib import Path

from pydantic import BaseModel, Field


class Chat2ApiConfig(BaseModel):
    """Configuration for chat2api backend."""

    base_url: str = Field(default="http://localhost:5005")
    api_prefix: str = Field(default="deep-reasoning")
    authorization_key: str = Field(default="deep-reasoning-key")
    timeout_seconds: int = Field(
        default=1200, description="20 minutes for deep reasoning"
    )

    @property
    def endpoint(self) -> str:
        """Full chat completions endpoint."""
        return f"{self.base_url}/{self.api_prefix}/v1/chat/completions"


class GeminiPlaywrightConfig(BaseModel):
    """Configuration for Gemini Playwright backend."""

    headless: bool = Field(default=True, description="Run browser in headless mode")
    session_dir: Path = Field(
        default_factory=lambda: Path.home() / ".deep-reasoning" / "gemini-session"
    )
    timeout_seconds: int = Field(
        default=1200, description="20 minutes for deep reasoning"
    )
    gemini_url: str = Field(default="https://gemini.google.com/app")


class StorageConfig(BaseModel):
    """Configuration for task storage."""

    base_dir: Path = Field(default_factory=lambda: Path.home() / ".deep-reasoning")
    db_name: str = Field(default="tasks.db")
    responses_dir: str = Field(default="responses")

    @property
    def db_path(self) -> Path:
        """Path to SQLite database."""
        return self.base_dir / self.db_name

    @property
    def responses_path(self) -> Path:
        """Path to responses directory."""
        return self.base_dir / self.responses_dir


class Config(BaseModel):
    """Main configuration."""

    chat2api: Chat2ApiConfig = Field(default_factory=Chat2ApiConfig)
    gemini: GeminiPlaywrightConfig = Field(default_factory=GeminiPlaywrightConfig)
    storage: StorageConfig = Field(default_factory=StorageConfig)

    # Worker settings
    max_concurrent_tasks: int = Field(
        default=4, description="Max parallel model queries"
    )
    poll_interval_seconds: float = Field(
        default=5.0, description="Task status poll interval"
    )


def load_config() -> Config:
    """Load configuration from environment and defaults."""
    config = Config()

    # Override from environment if set
    if chat2api_url := os.getenv("CHAT2API_URL"):
        config.chat2api.base_url = chat2api_url

    if chat2api_prefix := os.getenv("CHAT2API_PREFIX"):
        config.chat2api.api_prefix = chat2api_prefix

    if chat2api_key := os.getenv("CHAT2API_KEY"):
        config.chat2api.authorization_key = chat2api_key

    if storage_dir := os.getenv("DEEP_REASONING_DIR"):
        config.storage.base_dir = Path(storage_dir)

    # Ensure directories exist
    config.storage.base_dir.mkdir(parents=True, exist_ok=True)
    config.storage.responses_path.mkdir(parents=True, exist_ok=True)
    config.gemini.session_dir.mkdir(parents=True, exist_ok=True)

    return config
