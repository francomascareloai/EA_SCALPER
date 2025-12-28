"""Base backend interface."""

from abc import ABC, abstractmethod
from typing import Optional

from ..models import ModelResult, ReasoningModel


class BaseBackend(ABC):
    """Abstract base class for model backends."""

    @abstractmethod
    async def initialize(self) -> None:
        """Initialize the backend."""
        pass

    @abstractmethod
    async def close(self) -> None:
        """Cleanup backend resources."""
        pass

    @abstractmethod
    async def query(
        self,
        model: ReasoningModel,
        question: str,
        context: Optional[str] = None,
        system_hints: Optional[list[str]] = None,
    ) -> ModelResult:
        """
        Query a model with a question.

        Args:
            model: The model to query
            question: The question/prompt
            context: Optional additional context
            system_hints: Optional hints for special modes:
                - ["research"] for Deep Research mode
                - ["reason"] for extended thinking/reasoning mode

        Returns:
            ModelResult with response or error
        """
        pass

    @abstractmethod
    def supports_model(self, model: ReasoningModel) -> bool:
        """Check if this backend supports the given model."""
        pass
