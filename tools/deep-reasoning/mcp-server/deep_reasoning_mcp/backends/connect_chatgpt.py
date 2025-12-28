"""Connect to user's existing Chrome browser for ChatGPT automation.

This approach uses the user's real Chrome session (already logged in)
instead of creating a new browser instance that triggers bot detection.

Usage:
1. Close all Chrome windows
2. Run: start_chrome_debug.bat (Windows) or start_chrome_debug.sh (Linux)
3. Log into ChatGPT manually in that Chrome window
4. Run your automation - it will connect to that Chrome instance
"""

import asyncio
import logging
import random
import re
from datetime import datetime
from pathlib import Path
from typing import Optional

from playwright.async_api import async_playwright, Browser, Page

from ..models import (
    ModelResult,
    ModelProvider,
    MODEL_PROVIDERS,
    ReasoningModel,
    TaskStatus,
)
from . import BaseBackend

logger = logging.getLogger(__name__)


# =============================================================================
# HUMAN-LIKE BEHAVIOR UTILITIES
# =============================================================================


async def human_delay(min_ms: int = 100, max_ms: int = 300) -> None:
    """Random delay to simulate human reaction time."""
    delay = random.uniform(min_ms / 1000, max_ms / 1000)
    await asyncio.sleep(delay)


async def human_thinking_pause() -> None:
    """Longer pause to simulate human thinking (0.5-2s)."""
    await asyncio.sleep(random.uniform(0.5, 2.0))


async def human_move_and_click(page: Page, element) -> None:
    """Move mouse naturally to element, then click with human timing."""
    box = await element.bounding_box()
    if not box:
        await element.click()
        return

    x = box["x"] + box["width"] * random.uniform(0.3, 0.7)
    y = box["y"] + box["height"] * random.uniform(0.3, 0.7)

    # Move in steps
    steps = random.randint(3, 6)
    for step in range(1, steps + 1):
        progress = step / steps
        noise_x = random.uniform(-5, 5)
        noise_y = random.uniform(-5, 5)
        await page.mouse.move(x * progress + noise_x, y * progress + noise_y)
        await asyncio.sleep(random.uniform(0.01, 0.03))

    await human_delay(50, 150)
    await page.mouse.click(x + random.uniform(-2, 2), y + random.uniform(-2, 2))
    await human_delay(100, 250)


# =============================================================================
# SCRIPTS TO START CHROME WITH DEBUG PORT
# =============================================================================

WINDOWS_START_SCRIPT = """@echo off
REM Start Chrome with remote debugging enabled
REM Close ALL Chrome windows first!

echo Starting Chrome with debug port 9222...
echo Make sure to close ALL other Chrome windows first!
echo.

start "" "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe" --remote-debugging-port=9222 --user-data-dir="%USERPROFILE%\\AppData\\Local\\Google\\Chrome\\User Data"

echo Chrome started. You can now:
echo 1. Log into ChatGPT in this Chrome window
echo 2. Run your automation script
pause
"""

LINUX_START_SCRIPT = """#!/bin/bash
# Start Chrome with remote debugging enabled
# Close ALL Chrome windows first!

echo "Starting Chrome with debug port 9222..."
echo "Make sure to close ALL other Chrome windows first!"
echo

google-chrome --remote-debugging-port=9222 &

echo "Chrome started. You can now:"
echo "1. Log into ChatGPT in this Chrome window"
echo "2. Run your automation script"
"""


def create_start_scripts(output_dir: Path) -> None:
    """Create helper scripts to start Chrome with debug port."""
    output_dir.mkdir(parents=True, exist_ok=True)

    # Windows script
    win_script = output_dir / "start_chrome_debug.bat"
    win_script.write_text(WINDOWS_START_SCRIPT)

    # Linux script
    linux_script = output_dir / "start_chrome_debug.sh"
    linux_script.write_text(LINUX_START_SCRIPT)
    linux_script.chmod(0o755)

    logger.info(f"Created start scripts in {output_dir}")


# =============================================================================
# MAIN BACKEND
# =============================================================================


class ChatGPTConnectConfig:
    """Configuration for connecting to existing Chrome."""

    def __init__(
        self,
        cdp_url: str = "http://localhost:9222",
        timeout_seconds: int = 1800,
        chatgpt_url: str = "https://chatgpt.com",
    ):
        self.cdp_url = cdp_url
        self.timeout_seconds = timeout_seconds
        self.chatgpt_url = chatgpt_url


class ChatGPTConnectBackend(BaseBackend):
    """
    Backend that connects to user's existing Chrome browser.

    This uses the user's real session (already logged in) instead of
    creating a new browser instance that triggers bot detection.

    Setup:
    1. Close all Chrome windows
    2. Start Chrome with: chrome --remote-debugging-port=9222
    3. Log into ChatGPT in that window
    4. Run your automation
    """

    def __init__(self, config: Optional[ChatGPTConnectConfig] = None):
        self.config = config or ChatGPTConnectConfig()
        self._playwright = None
        self._browser: Optional[Browser] = None
        self._initialized = False

    async def initialize(self) -> None:
        """Connect to existing Chrome via CDP."""
        self._playwright = await async_playwright().start()

        try:
            # Connect to existing Chrome
            self._browser = await self._playwright.chromium.connect_over_cdp(
                self.config.cdp_url
            )
            self._initialized = True
            logger.info(f"Connected to Chrome at {self.config.cdp_url}")

        except Exception as e:
            error_msg = str(e)
            if "connect" in error_msg.lower():
                raise RuntimeError(
                    f"Could not connect to Chrome at {self.config.cdp_url}. "
                    "Make sure Chrome is running with --remote-debugging-port=9222\n"
                    "Run: start_chrome_debug.bat (Windows) or start_chrome_debug.sh (Linux)"
                )
            raise

    async def close(self) -> None:
        """Disconnect (does not close Chrome)."""
        if self._browser:
            await self._browser.close()
        if self._playwright:
            await self._playwright.stop()
        self._initialized = False

    def supports_model(self, model: ReasoningModel) -> bool:
        """This backend supports ChatGPT models."""
        return MODEL_PROVIDERS.get(model) == ModelProvider.CHATGPT

    async def query(
        self,
        model: ReasoningModel,
        question: str,
        context: Optional[str] = None,
        system_hints: Optional[list[str]] = None,
    ) -> ModelResult:
        """Query ChatGPT using the connected Chrome session."""
        if not self._initialized or not self._browser:
            return ModelResult(
                model=model,
                status=TaskStatus.FAILED,
                error="Backend not initialized. Call initialize() first.",
            )

        started_at = datetime.now()
        page = None

        try:
            # Get existing context or create new page
            contexts = self._browser.contexts
            if contexts:
                ctx = contexts[0]
                pages = ctx.pages
                # Find ChatGPT page or create new
                for p in pages:
                    if "chatgpt" in p.url.lower():
                        page = p
                        break
                if not page:
                    page = await ctx.new_page()
            else:
                ctx = await self._browser.new_context()
                page = await ctx.new_page()

            # Navigate to ChatGPT if not already there
            if "chatgpt" not in page.url.lower():
                logger.info("Navigating to ChatGPT...")
                await page.goto(self.config.chatgpt_url, wait_until="domcontentloaded")
                await human_thinking_pause()
                await human_delay(1000, 2000)

            # Wait for composer
            composer = await self._wait_for_composer(page)
            if not composer:
                raise RuntimeError("Could not find composer - are you logged in?")

            logger.info("Chat interface ready")
            await human_delay(500, 1000)

            # Enable Deep Research if requested
            if system_hints and "research" in system_hints:
                await self._select_pro_model(page)
                await human_thinking_pause()
                await self._enable_deep_research(page)

            # Send message
            full_prompt = f"{context}\n\n{question}" if context else question
            await self._send_message(page, full_prompt)

            # Wait for response
            logger.info("Waiting for response...")
            response_text = await self._wait_for_response(
                page, timeout=self.config.timeout_seconds
            )

            completed_at = datetime.now()
            duration = (completed_at - started_at).total_seconds()

            logger.info(f"Got response in {duration:.1f}s ({len(response_text)} chars)")

            return ModelResult(
                model=model,
                status=TaskStatus.COMPLETED,
                response=response_text,
                started_at=started_at,
                completed_at=completed_at,
                duration_seconds=duration,
            )

        except Exception as e:
            logger.error(f"Error: {e}")
            completed_at = datetime.now()
            return ModelResult(
                model=model,
                status=TaskStatus.FAILED,
                started_at=started_at,
                completed_at=completed_at,
                duration_seconds=(completed_at - started_at).total_seconds(),
                error=str(e),
            )

    async def _wait_for_composer(self, page: Page):
        """Wait for composer element."""
        selectors = [
            "#prompt-textarea",
            '[contenteditable="true"]',
            'textarea[data-testid="composer-input"]',
        ]
        for selector in selectors:
            try:
                await page.wait_for_selector(selector, timeout=10000)
                return page.locator(selector).first
            except Exception:
                continue
        return None

    async def _select_pro_model(self, page: Page) -> None:
        """Select Pro model."""
        try:
            model_btn = page.locator('[data-testid="model-switcher-dropdown-button"]')
            if await model_btn.is_visible(timeout=3000):
                await human_thinking_pause()
                await human_move_and_click(page, model_btn)
                logger.info("Opened model selector")
                await human_delay(500, 1000)

                # Find Pro option
                options = page.locator('[role="menuitemradio"]')
                count = await options.count()
                for i in range(count):
                    opt = options.nth(i)
                    text = await opt.inner_text()
                    if "pro" in text.lower():
                        await human_delay(300, 600)
                        await human_move_and_click(page, opt)
                        logger.info("Selected Pro model")
                        await human_delay(500, 1000)
                        return

                await page.keyboard.press("Escape")
        except Exception as e:
            logger.debug(f"Error selecting Pro model: {e}")

    async def _enable_deep_research(self, page: Page) -> None:
        """Enable Deep Research mode."""
        try:
            # Focus composer
            composer = page.locator("#prompt-textarea")
            if await composer.is_visible(timeout=2000):
                await human_move_and_click(page, composer)
                await human_delay(400, 800)

            # Click + button
            plus_btn = page.locator('[data-testid="composer-plus-btn"]')
            if await plus_btn.is_visible(timeout=2000):
                await human_delay(200, 500)
                await human_move_and_click(page, plus_btn)
                logger.info("Opened options menu")
                await human_delay(600, 1000)

                # Find Deep Research
                items = page.locator('[role="menuitemradio"]')
                count = await items.count()
                for i in range(count):
                    item = items.nth(i)
                    text = await item.inner_text()
                    if "deep research" in text.lower() or "investigar" in text.lower():
                        await human_delay(300, 600)
                        await human_move_and_click(page, item)
                        logger.info("Deep Research enabled")
                        await human_thinking_pause()
                        return

        except Exception as e:
            logger.warning(f"Error enabling Deep Research: {e}")

    async def _send_message(self, page: Page, message: str) -> None:
        """Send a message."""
        composer = page.locator("#prompt-textarea").first
        await human_move_and_click(page, composer)
        await human_thinking_pause()

        # Type message
        await composer.fill(message)
        await human_delay(500, 1000)
        await human_thinking_pause()

        # Click send
        send_btn = page.locator('[data-testid="send-button"]').first
        if await send_btn.is_visible(timeout=2000) and await send_btn.is_enabled():
            await human_delay(200, 400)
            await human_move_and_click(page, send_btn)
        else:
            await composer.press("Control+Enter")

        logger.info("Message sent")

    async def _wait_for_response(self, page: Page, timeout: int = 1800) -> str:
        """Wait for response to complete."""
        start_time = asyncio.get_event_loop().time()
        last_content = ""
        stable_count = 0

        while True:
            elapsed = asyncio.get_event_loop().time() - start_time
            if elapsed > timeout:
                raise TimeoutError(f"Response timeout after {timeout}s")

            # Check if generating
            is_generating = False
            try:
                stop_btn = page.locator('[data-testid="stop-button"]')
                is_generating = await stop_btn.is_visible(timeout=1000)
            except Exception:
                pass

            # Extract response
            try:
                messages = page.locator('[data-message-author-role="assistant"]')
                count = await messages.count()
                if count > 0:
                    last_msg = messages.nth(count - 1)
                    current = await last_msg.inner_text()

                    if current == last_content:
                        stable_count += 1
                    else:
                        stable_count = 0
                        last_content = current

                    if not is_generating and stable_count >= 5:
                        return self._clean_response(current)
            except Exception as e:
                logger.debug(f"Error extracting: {e}")

            if int(elapsed) % 30 == 0 and int(elapsed) > 0:
                logger.info(f"Waiting... {int(elapsed)}s, {len(last_content)} chars")

            await asyncio.sleep(1)

    def _clean_response(self, text: str) -> str:
        """Clean response text."""
        text = re.sub(r"\d+\s*/\s*\d+$", "", text)
        text = re.sub(r"Copy code", "", text)
        return text.strip()
