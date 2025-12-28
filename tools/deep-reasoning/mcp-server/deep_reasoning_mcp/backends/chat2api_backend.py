"""Chat2API backend for ChatGPT models with token rotation."""

import logging
from datetime import datetime
from typing import Optional

import httpx

from ..config import Chat2ApiConfig
from ..models import (
    ModelResult,
    ModelProvider,
    MODEL_PROVIDERS,
    ReasoningModel,
    TaskStatus,
)
from ..token_manager import TokenManager, get_token_manager
from . import BaseBackend

logger = logging.getLogger(__name__)


# Model name mapping for chat2api
CHATGPT_MODEL_NAMES: dict[ReasoningModel, str] = {
    ReasoningModel.GPT_5_PRO: "gpt-5",
    ReasoningModel.GPT_5_2_PRO: "gpt-5",  # Maps to same endpoint, latest version
    ReasoningModel.O1_PRO: "o1-pro",
    ReasoningModel.O1: "o1",
    ReasoningModel.O1_MINI: "o1-mini",
    ReasoningModel.O3: "o3",
    ReasoningModel.O3_MINI: "o3-mini",
    ReasoningModel.O3_MINI_HIGH: "o3-mini-high",
    ReasoningModel.GPT_4O: "gpt-4o",
}


class Chat2ApiBackend(BaseBackend):
    """Backend using chat2api for ChatGPT models with Codex token rotation."""

    def __init__(
        self,
        config: Chat2ApiConfig,
        token_manager: Optional[TokenManager] = None,
        access_token: Optional[str] = None,
    ):
        """
        Initialize Chat2API backend.

        Args:
            config: Chat2API configuration
            token_manager: TokenManager for Codex account rotation (recommended)
            access_token: Static fallback token (optional, uses TokenManager if None)
        """
        self.config = config
        self.token_manager = token_manager
        self.static_token = access_token
        self._client: Optional[httpx.AsyncClient] = None

    async def initialize(self) -> None:
        """Initialize HTTP client and token manager."""
        self._client = httpx.AsyncClient(
            timeout=httpx.Timeout(self.config.timeout_seconds),
        )

        # Use global token manager if not provided
        if self.token_manager is None and self.static_token is None:
            self.token_manager = get_token_manager()

        if self.token_manager:
            stats = self.token_manager.get_stats()
            logger.info(
                f"Chat2API backend initialized with {stats['available']}/{stats['total']} "
                f"Codex accounts available"
            )
        else:
            logger.info("Chat2API backend initialized with static token")

    async def close(self) -> None:
        """Close HTTP client."""
        if self._client:
            await self._client.aclose()
            self._client = None

    def supports_model(self, model: ReasoningModel) -> bool:
        """Check if model is a ChatGPT model."""
        return MODEL_PROVIDERS.get(model) == ModelProvider.CHATGPT

    def _get_token(self) -> Optional[str]:
        """Get next available token."""
        if self.token_manager:
            return self.token_manager.get_next_token()
        return self.static_token

    async def query(
        self,
        model: ReasoningModel,
        question: str,
        context: Optional[str] = None,
        system_hints: Optional[list[str]] = None,
    ) -> ModelResult:
        """Query ChatGPT via chat2api with automatic token rotation.

        Args:
            model: The reasoning model to use
            question: The question/prompt
            context: Optional system context
            system_hints: Optional hints for special modes:
                - ["research"] for Deep Research mode
                - ["reason"] for extended thinking/reasoning mode
        """
        if not self._client:
            raise RuntimeError("Backend not initialized")

        if not self.supports_model(model):
            return ModelResult(
                model=model,
                status=TaskStatus.FAILED,
                error=f"Model {model} not supported by Chat2API backend",
            )

        # Get token (with rotation if using TokenManager)
        auth_token = self._get_token()
        if not auth_token:
            return ModelResult(
                model=model,
                status=TaskStatus.FAILED,
                error="No available Codex tokens. All accounts expired or in cooldown.",
            )

        started_at = datetime.now()
        model_name = CHATGPT_MODEL_NAMES.get(model, model.value)

        # Build messages
        messages = []
        if context:
            messages.append({"role": "system", "content": context})
        messages.append({"role": "user", "content": question})

        # Build request payload
        request_payload = {
            "model": model_name,
            "messages": messages,
            "stream": False,
        }

        # Add system_hints for Deep Research / extended thinking
        if system_hints:
            request_payload["system_hints"] = system_hints
            logger.info(f"Using system_hints: {system_hints}")

        max_retries = 3 if self.token_manager else 1

        for attempt in range(max_retries):
            try:
                logger.info(
                    f"Querying {model_name} via chat2api (attempt {attempt + 1}/{max_retries})..."
                )

                response = await self._client.post(
                    self.config.endpoint,
                    headers={
                        "Content-Type": "application/json",
                        "Authorization": f"Bearer {auth_token}",
                    },
                    json=request_payload,
                )

                # Handle rate limiting
                if response.status_code == 429:
                    if self.token_manager:
                        retry_after = int(response.headers.get("Retry-After", "60"))
                        self.token_manager.mark_rate_limited(auth_token, retry_after)
                        # Get next token and retry
                        auth_token = self._get_token()
                        if auth_token:
                            continue
                    # No more tokens or static token - fail
                    raise httpx.HTTPStatusError(
                        "Rate limited",
                        request=response.request,
                        response=response,
                    )

                # Handle auth errors
                if response.status_code in (401, 403):
                    if self.token_manager:
                        self.token_manager.mark_error(auth_token)
                        auth_token = self._get_token()
                        if auth_token:
                            continue
                    raise httpx.HTTPStatusError(
                        "Auth failed",
                        request=response.request,
                        response=response,
                    )

                response.raise_for_status()
                data = response.json()

                completed_at = datetime.now()
                duration = (completed_at - started_at).total_seconds()

                # Extract response
                content = data["choices"][0]["message"]["content"]

                # Extract reasoning/thinking if present (O1/O3 models)
                thinking = None
                if "reasoning_content" in data["choices"][0]["message"]:
                    thinking = data["choices"][0]["message"]["reasoning_content"]

                # Token usage
                tokens = None
                if "usage" in data:
                    tokens = data["usage"].get("total_tokens")

                logger.info(f"Got response from {model_name} in {duration:.1f}s")

                return ModelResult(
                    model=model,
                    status=TaskStatus.COMPLETED,
                    response=content,
                    thinking_process=thinking,
                    started_at=started_at,
                    completed_at=completed_at,
                    duration_seconds=duration,
                    tokens_used=tokens,
                )

            except httpx.HTTPStatusError as e:
                logger.error(f"HTTP error from chat2api: {e.response.status_code}")
                if attempt < max_retries - 1 and self.token_manager:
                    self.token_manager.mark_error(auth_token)
                    auth_token = self._get_token()
                    if auth_token:
                        continue
                return ModelResult(
                    model=model,
                    status=TaskStatus.FAILED,
                    started_at=started_at,
                    completed_at=datetime.now(),
                    error=f"HTTP {e.response.status_code}: {e.response.text[:500]}",
                )

            except Exception as e:
                logger.error(f"Error querying chat2api: {e}")
                return ModelResult(
                    model=model,
                    status=TaskStatus.FAILED,
                    started_at=started_at,
                    completed_at=datetime.now(),
                    error=str(e),
                )

        # Should not reach here
        return ModelResult(
            model=model,
            status=TaskStatus.FAILED,
            started_at=started_at,
            completed_at=datetime.now(),
            error="Max retries exceeded",
        )
