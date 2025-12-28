"""Playwright-based Gemini backend for DeepThink."""

import asyncio
import logging
import re
from datetime import datetime
from typing import Optional

from playwright.async_api import async_playwright, BrowserContext, Page

from ..config import GeminiPlaywrightConfig
from ..models import (
    ModelResult,
    ModelProvider,
    MODEL_PROVIDERS,
    ReasoningModel,
    TaskStatus,
)
from . import BaseBackend

logger = logging.getLogger(__name__)


class GeminiPlaywrightBackend(BaseBackend):
    """
    Backend using Playwright for Gemini DeepThink.

    Opens a browser, uses saved session, and submits queries
    to Gemini with DeepThink mode enabled.
    """

    def __init__(self, config: GeminiPlaywrightConfig):
        self.config = config
        self._playwright = None
        self._context: Optional[BrowserContext] = None
        self._initialized = False

    async def initialize(self) -> None:
        """Initialize Playwright browser with saved session."""
        self.config.session_dir.mkdir(parents=True, exist_ok=True)

        self._playwright = await async_playwright().start()

        # Use persistent context to maintain Google login
        self._context = await self._playwright.chromium.launch_persistent_context(
            user_data_dir=str(self.config.session_dir),
            headless=self.config.headless,
            viewport={"width": 1280, "height": 900},
            args=[
                "--disable-blink-features=AutomationControlled",
                "--no-sandbox",
            ],
        )

        self._initialized = True
        logger.info(
            f"Gemini Playwright backend initialized (session: {self.config.session_dir})"
        )

    async def close(self) -> None:
        """Close browser."""
        if self._context:
            await self._context.close()
        if self._playwright:
            await self._playwright.stop()
        self._initialized = False

    def supports_model(self, model: ReasoningModel) -> bool:
        """Check if model is a Gemini model."""
        return MODEL_PROVIDERS.get(model) == ModelProvider.GEMINI

    async def query(
        self,
        model: ReasoningModel,
        question: str,
        context: Optional[str] = None,
        system_hints: Optional[list[str]] = None,
    ) -> ModelResult:
        """
        Query Gemini via Playwright with DeepThink mode.
        """
        if not self._initialized or not self._context:
            return ModelResult(
                model=model,
                status=TaskStatus.FAILED,
                error="Backend not initialized. Call initialize() first.",
            )

        if not self.supports_model(model):
            return ModelResult(
                model=model,
                status=TaskStatus.FAILED,
                error=f"Model {model} not supported by Gemini backend",
            )

        started_at = datetime.now()
        page = None

        try:
            page = await self._context.new_page()

            # Navigate to Gemini
            logger.info("Navigating to Gemini...")
            await page.goto(
                self.config.gemini_url, wait_until="networkidle", timeout=60000
            )
            await asyncio.sleep(2)

            # Check if logged in
            try:
                # Look for the chat input area
                await page.wait_for_selector(
                    'div[contenteditable="true"], textarea[aria-label*="prompt"], .ql-editor',
                    timeout=10000,
                )
                logger.info("Gemini interface loaded, user is logged in")
            except Exception:
                logger.warning("Not logged in. Please log in to Google manually...")
                await page.wait_for_selector(
                    'div[contenteditable="true"], textarea[aria-label*="prompt"], .ql-editor',
                    timeout=120000,
                )

            # Enable DeepThink mode if using deepthink model
            if model == ReasoningModel.GEMINI_DEEPTHINK:
                await self._enable_deepthink(page)

            # Compose and send the prompt
            full_prompt = f"{context}\n\n{question}" if context else question
            await self._send_message(page, full_prompt)

            # Wait for response (DeepThink can take 5-15 minutes)
            logger.info(
                "Waiting for Gemini response (this may take 5-15 minutes for DeepThink)..."
            )
            response_text, thinking_text = await self._wait_for_response(
                page, timeout=self.config.timeout_seconds
            )

            completed_at = datetime.now()
            duration = (completed_at - started_at).total_seconds()

            logger.info(f"Got response in {duration:.1f}s ({len(response_text)} chars)")

            return ModelResult(
                model=model,
                status=TaskStatus.COMPLETED,
                response=response_text,
                thinking_process=thinking_text,
                started_at=started_at,
                completed_at=completed_at,
                duration_seconds=duration,
            )

        except Exception as e:
            logger.error(f"Error in Gemini Playwright: {e}")
            return ModelResult(
                model=model,
                status=TaskStatus.FAILED,
                started_at=started_at,
                completed_at=datetime.now(),
                error=str(e),
            )
        finally:
            if page:
                await page.close()

    async def _enable_deepthink(self, page: Page) -> None:
        """Enable DeepThink mode."""
        try:
            # Look for DeepThink toggle or button
            deepthink_selectors = [
                'button:has-text("Deep Think")',
                'button:has-text("Think")',
                '[data-testid="deepthink-toggle"]',
                'button[aria-label*="Think"]',
                # Gemini's thinking mode toggle
                ".think-toggle",
                'button:has-text("Thinking")',
            ]

            for selector in deepthink_selectors:
                try:
                    button = page.locator(selector).first
                    if await button.is_visible(timeout=2000):
                        await button.click()
                        logger.info("DeepThink mode enabled")
                        await asyncio.sleep(1)
                        return
                except Exception:
                    continue

            logger.warning(
                "Could not find DeepThink button - proceeding with default mode"
            )

        except Exception as e:
            logger.warning(f"Error enabling DeepThink: {e}")

    async def _send_message(self, page: Page, message: str) -> None:
        """Type and send a message to Gemini."""
        # Find the input area (Gemini uses contenteditable div)
        input_selectors = [
            'div[contenteditable="true"]',
            'textarea[aria-label*="prompt"]',
            ".ql-editor",
            '[data-testid="text-input"]',
        ]

        input_element = None
        for selector in input_selectors:
            try:
                element = page.locator(selector).first
                if await element.is_visible(timeout=2000):
                    input_element = element
                    break
            except Exception:
                continue

        if not input_element:
            raise Exception("Could not find Gemini input field")

        # Clear and type the message
        await input_element.click()
        await input_element.fill(message)
        await asyncio.sleep(0.5)

        # Find and click send button
        send_selectors = [
            'button[aria-label*="Send"]',
            'button[aria-label*="Submit"]',
            '[data-testid="send-button"]',
            "button.send-button",
        ]

        for selector in send_selectors:
            try:
                button = page.locator(selector).first
                if await button.is_visible(timeout=2000) and await button.is_enabled():
                    await button.click()
                    logger.info("Message sent to Gemini")
                    return
            except Exception:
                continue

        # Fallback: try pressing Enter
        await input_element.press("Enter")
        logger.info("Message sent via Enter key")

    async def _wait_for_response(
        self, page: Page, timeout: int = 1200
    ) -> tuple[str, Optional[str]]:
        """Wait for Gemini response and extract text + thinking."""
        start_time = asyncio.get_event_loop().time()
        last_content = ""
        stable_count = 0

        while True:
            elapsed = asyncio.get_event_loop().time() - start_time
            if elapsed > timeout:
                raise TimeoutError(f"Response timeout after {timeout}s")

            # Check if still generating
            is_generating = False
            try:
                # Look for loading/generating indicators
                loading_selectors = [
                    ".loading-indicator",
                    '[data-testid="loading"]',
                    'button[aria-label*="Stop"]',
                    ".generating",
                ]
                for selector in loading_selectors:
                    try:
                        if await page.locator(selector).first.is_visible(timeout=500):
                            is_generating = True
                            break
                    except Exception:
                        pass
            except Exception:
                pass

            # Extract current response
            try:
                # Get the last model response
                response_selectors = [
                    ".model-response",
                    '[data-testid="model-response"]',
                    ".response-container",
                    ".markdown-content",
                ]

                current_content = ""
                for selector in response_selectors:
                    try:
                        elements = page.locator(selector)
                        count = await elements.count()
                        if count > 0:
                            last_element = elements.nth(count - 1)
                            current_content = await last_element.inner_text()
                            break
                    except Exception:
                        continue

                if current_content:
                    if current_content == last_content:
                        stable_count += 1
                    else:
                        stable_count = 0
                        last_content = current_content

                    # If content is stable for 5 seconds and not generating, we're done
                    if not is_generating and stable_count >= 5:
                        # Try to extract thinking process
                        thinking = await self._extract_thinking(page)
                        return self._clean_response(current_content), thinking

            except Exception as e:
                logger.debug(f"Error extracting response: {e}")

            # Log progress every 30 seconds
            if int(elapsed) % 30 == 0 and int(elapsed) > 0:
                logger.info(
                    f"Still waiting... {int(elapsed)}s elapsed, {len(last_content)} chars so far"
                )

            await asyncio.sleep(1)

    async def _extract_thinking(self, page: Page) -> Optional[str]:
        """Try to extract the thinking/reasoning process if visible."""
        try:
            thinking_selectors = [
                ".thinking-steps",
                '[data-testid="thinking-process"]',
                ".reasoning-chain",
                ".thought-process",
            ]

            for selector in thinking_selectors:
                try:
                    element = page.locator(selector).first
                    if await element.is_visible(timeout=1000):
                        return await element.inner_text()
                except Exception:
                    continue

        except Exception:
            pass

        return None

    def _clean_response(self, text: str) -> str:
        """Clean up the response text."""
        text = re.sub(r"\d+\s*/\s*\d+$", "", text)
        text = re.sub(r"Copy code", "", text)
        text = text.strip()
        return text
