"""Playwright-based ChatGPT backend for real Deep Research."""

import asyncio
import logging
import random
import re
import uuid
from datetime import datetime
from pathlib import Path
from typing import Optional

from playwright.async_api import async_playwright, Browser, BrowserContext, Page

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


async def human_type(page: Page, element, text: str) -> None:
    """Type text character by character with human-like timing.

    - Variable speed per character (50-150ms)
    - Occasional longer pauses (thinking)
    - Small chance of typo + correction (disabled for now - too slow)
    """
    await element.click()
    await human_delay(200, 400)

    for i, char in enumerate(text):
        # Type the character
        await page.keyboard.type(char, delay=random.randint(30, 80))

        # Occasional micro-pause (every 5-15 chars, simulating reading/thinking)
        if random.random() < 0.05:
            await human_delay(200, 500)

        # Longer pause after punctuation (like a human would pause)
        if char in ".!?\n":
            await human_delay(100, 300)


async def human_move_and_click(page: Page, element) -> None:
    """Move mouse naturally to element, then click with human timing."""
    # Get element bounding box
    box = await element.bounding_box()
    if not box:
        # Fallback to simple click
        await element.click()
        return

    # Calculate a random point within the element (not always center)
    x = box["x"] + box["width"] * random.uniform(0.3, 0.7)
    y = box["y"] + box["height"] * random.uniform(0.3, 0.7)

    # Move mouse with slight curve (Playwright doesn't support bezier, so we do steps)
    current_pos = await page.evaluate("() => ({x: 0, y: 0})")  # Approximate
    steps = random.randint(3, 6)

    for step in range(1, steps + 1):
        # Add slight randomness to path
        progress = step / steps
        noise_x = random.uniform(-5, 5)
        noise_y = random.uniform(-5, 5)
        intermediate_x = (
            current_pos.get("x", 0) + (x - current_pos.get("x", 0)) * progress + noise_x
        )
        intermediate_y = (
            current_pos.get("y", 0) + (y - current_pos.get("y", 0)) * progress + noise_y
        )

        await page.mouse.move(intermediate_x, intermediate_y)
        await asyncio.sleep(random.uniform(0.01, 0.03))

    # Small pause before clicking (human hesitation)
    await human_delay(50, 150)

    # Click with slight position variation
    await page.mouse.click(x + random.uniform(-2, 2), y + random.uniform(-2, 2))

    # Post-click pause
    await human_delay(100, 250)


async def human_scroll(page: Page, direction: str = "down", amount: int = 300) -> None:
    """Scroll with human-like behavior (variable speed, not instant)."""
    scroll_amount = amount * (1 if direction == "down" else -1)

    # Scroll in chunks with variable timing
    chunks = random.randint(3, 6)
    chunk_size = scroll_amount / chunks

    for _ in range(chunks):
        await page.mouse.wheel(0, chunk_size)
        await asyncio.sleep(random.uniform(0.05, 0.15))


# =============================================================================
# MAIN BACKEND
# =============================================================================


class ChatGPTPlaywrightConfig:
    """Configuration for ChatGPT Playwright backend."""

    def __init__(
        self,
        headless: bool = False,  # False to see browser during dev
        session_dir: Optional[Path] = None,
        timeout_seconds: int = 1800,  # 30 minutes for Deep Research
        chatgpt_url: str = "https://chatgpt.com",
        humanize: bool = True,  # Enable human-like behavior
        max_concurrent_pages: int = 3,
        max_concurrent_bootstrap_pages: int = 1,
        goto_timeout_ms: int = 120_000,
        max_query_retries: int = 1,
    ):
        self.headless = headless
        self.session_dir = (
            session_dir or Path.home() / ".deep-reasoning" / "chatgpt-session"
        )
        self.timeout_seconds = timeout_seconds
        self.chatgpt_url = chatgpt_url
        self.humanize = humanize
        self.max_concurrent_pages = max_concurrent_pages
        self.max_concurrent_bootstrap_pages = max_concurrent_bootstrap_pages
        self.goto_timeout_ms = goto_timeout_ms
        self.max_query_retries = max_query_retries


class ChatGPTPlaywrightBackend(BaseBackend):
    """Backend using Playwright for ChatGPT Deep Research."""

    def __init__(self, config: Optional[ChatGPTPlaywrightConfig] = None):
        self.config = config or ChatGPTPlaywrightConfig()
        self._playwright = None
        self._browser: Optional[Browser] = None
        self._context: Optional[BrowserContext] = None
        self._initialized = False
        # Overall concurrency (pages open simultaneously)
        self._page_semaphore = asyncio.Semaphore(self.config.max_concurrent_pages)
        # Bootstrap concurrency (navigate/login/UI setup). Keep this low to reduce flakiness.
        self._bootstrap_semaphore = asyncio.Semaphore(
            self.config.max_concurrent_bootstrap_pages
        )

    async def initialize(self) -> None:
        """Initialize Playwright browser with saved session."""
        self.config.session_dir.mkdir(parents=True, exist_ok=True)

        self._playwright = await async_playwright().start()

        # Use persistent context to maintain login
        # Add more realistic browser fingerprint
        self._context = await self._playwright.chromium.launch_persistent_context(
            user_data_dir=str(self.config.session_dir),
            headless=self.config.headless,
            viewport={"width": 1280, "height": 900},
            args=[
                "--disable-blink-features=AutomationControlled",
                "--no-sandbox",
                "--disable-dev-shm-usage",
                "--disable-accelerated-2d-canvas",
                "--no-first-run",
                "--no-zygote",
            ],
            # More realistic user agent
            user_agent=(
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/120.0.0.0 Safari/537.36"
            ),
            # Locale and timezone
            locale="en-US",
            timezone_id="America/New_York",
        )

        # Remove webdriver property that reveals automation
        for page in self._context.pages:
            await self._hide_automation(page)

        self._initialized = True
        logger.info(
            f"ChatGPT Playwright backend initialized (session: {self.config.session_dir})"
        )

    async def _hide_automation(self, page: Page) -> None:
        """Hide automation indicators from the page."""
        await page.add_init_script("""
            // Remove webdriver property
            Object.defineProperty(navigator, 'webdriver', {
                get: () => undefined
            });

            // Mock plugins
            Object.defineProperty(navigator, 'plugins', {
                get: () => [1, 2, 3, 4, 5]
            });

            // Mock languages
            Object.defineProperty(navigator, 'languages', {
                get: () => ['en-US', 'en']
            });

            // Remove automation-related properties
            window.chrome = { runtime: {} };
        """)

    async def close(self) -> None:
        """Close browser."""
        if self._context:
            await self._context.close()
        if self._playwright:
            await self._playwright.stop()
        self._initialized = False

    def supports_model(self, model: ReasoningModel) -> bool:
        """This backend supports ChatGPT models for Deep Research."""
        return MODEL_PROVIDERS.get(model) == ModelProvider.CHATGPT

    async def query(
        self,
        model: ReasoningModel,
        question: str,
        context: Optional[str] = None,
        system_hints: Optional[list[str]] = None,
    ) -> ModelResult:
        """
        Query ChatGPT via Playwright with real Deep Research.

        This navigates to ChatGPT, enables Deep Research mode,
        submits the prompt, and waits for the full response.
        """
        if not self._initialized or not self._context:
            return ModelResult(
                model=model,
                status=TaskStatus.FAILED,
                error="Backend not initialized. Call initialize() first.",
            )

        started_at = datetime.now()
        page = None

        async with self._page_semaphore:
            try:
                page = await self._context.new_page()
                await self._hide_automation(page)

                # Bootstrap phase: navigate/login/UI setup. Serialize to reduce flakiness.
                async with self._bootstrap_semaphore:
                    # Navigate to ChatGPT (retry on transient timeouts)
                    logger.info("Navigating to ChatGPT...")
                    await self._goto_chatgpt(page)

                    # Human-like wait for page to load (look around)
                    await human_thinking_pause()
                    await human_delay(1000, 2000)

                    # Close any modals that might appear (rate limit, welcome, etc.)
                    await self._close_modals(page)

                    # Check if logged in by looking for the prompt textarea
                    # Use multiple selectors as ChatGPT UI changes frequently
                    composer_selectors = [
                        "#prompt-textarea",  # Current (Dec 2025)
                        '[id="prompt-textarea"]',
                        'div[contenteditable="true"]',
                        'textarea[data-testid="composer-input"]',  # Old selector
                    ]

                    composer_found = False
                    for selector in composer_selectors:
                        try:
                            await page.wait_for_selector(selector, timeout=5000)
                            logger.info(
                                f"Chat interface loaded, composer found: {selector}"
                            )
                            composer_found = True
                            break
                        except Exception:
                            continue

                    if not composer_found:
                        logger.warning(
                            "Composer not found. Waiting longer for login..."
                        )
                        try:
                            await page.wait_for_selector(
                                ", ".join(composer_selectors[:3]),
                                timeout=120000,
                            )
                        except Exception as e:
                            await self._save_debug_screenshot(
                                page, prefix="pw_wait_composer"
                            )
                            raise e

                    # If we still can't see a composer, capture a screenshot for debugging
                    try:
                        composer_visible = await page.locator(
                            "#prompt-textarea"
                        ).is_visible(timeout=1000)
                        if not composer_visible:
                            await self._save_debug_screenshot(
                                page, prefix="pw_no_composer"
                            )
                            logger.warning(
                                f"Composer still not visible. url={page.url}"
                            )
                    except Exception:
                        pass

                    # Human pause after page loads
                    await human_delay(500, 1000)

                    # Close modals again (they may appear after page settles)
                    await self._close_modals(page)

                    # Select the Pro model first (required for Deep Research)
                    deep_research_enabled = bool(
                        system_hints and "research" in system_hints
                    )
                    if deep_research_enabled:
                        await self._select_pro_model(page)
                        await human_thinking_pause()
                        await self._enable_deep_research(page)

                    # Compose and send the prompt
                    full_prompt = f"{context}\n\n{question}" if context else question
                    await self._send_message(page, full_prompt)

                logger.info(
                    "Waiting for response (this may take 10-20 minutes for Deep Research)..."
                )
                response_text = await self._wait_for_response(
                    page,
                    timeout=self.config.timeout_seconds,
                    deep_research_enabled=deep_research_enabled,
                )

                # If ChatGPT returns a transient error, retry once on the same page.
                if self._is_transient_chatgpt_error(response_text):
                    logger.warning(
                        "ChatGPT returned transient error response; retrying once..."
                    )
                    await self._save_debug_screenshot(page, prefix="pw_transient_error")
                    await human_delay(500, 1200)
                    await self._click_retry_if_present(page)
                    response_text = await self._wait_for_response(
                        page,
                        timeout=self.config.timeout_seconds,
                        deep_research_enabled=deep_research_enabled,
                    )

                    if self._is_transient_chatgpt_error(response_text):
                        await self._save_debug_screenshot(
                            page, prefix="pw_transient_error_after_retry"
                        )
                        return ModelResult(
                            model=model,
                            status=TaskStatus.FAILED,
                            started_at=started_at,
                            completed_at=datetime.now(),
                            duration_seconds=(
                                datetime.now() - started_at
                            ).total_seconds(),
                            error="ChatGPT returned transient error twice (Retry did not recover)",
                        )

                completed_at = datetime.now()
                duration = (completed_at - started_at).total_seconds()

                logger.info(
                    f"Got response in {duration:.1f}s ({len(response_text)} chars)"
                )

                return ModelResult(
                    model=model,
                    status=TaskStatus.COMPLETED,
                    response=response_text,
                    started_at=started_at,
                    completed_at=completed_at,
                    duration_seconds=duration,
                )

            except Exception as e:
                logger.error(f"Error in ChatGPT Playwright: {e}")
                completed_at = datetime.now()
                return ModelResult(
                    model=model,
                    status=TaskStatus.FAILED,
                    started_at=started_at,
                    completed_at=completed_at,
                    duration_seconds=(completed_at - started_at).total_seconds(),
                    error=str(e),
                )
            finally:
                if page:
                    await page.close()

    def _is_transient_chatgpt_error(self, text: str) -> bool:
        """Detect transient ChatGPT UI errors that should be retried."""
        t = (text or "").strip().lower()
        if not t:
            return False
        # Common error strings observed in UI
        needles = [
            "something went wrong while generating the response",
            "retry",
        ]
        if all(n in t for n in needles):
            return True
        return False

    async def _save_debug_screenshot(self, page: Page, prefix: str) -> Optional[Path]:
        """Save a debug screenshot to ~/.deep-reasoning/errors."""
        try:
            screenshot_path = (
                Path.home()
                / ".deep-reasoning"
                / "errors"
                / f"{prefix}_{uuid.uuid4().hex[:8]}.png"
            )
            screenshot_path.parent.mkdir(parents=True, exist_ok=True)
            await page.screenshot(path=str(screenshot_path), full_page=True)
            logger.warning(f"Saved debug screenshot: {screenshot_path}")
            return screenshot_path
        except Exception as e:
            # Use WARNING (not debug) so failures are visible in normal runs
            logger.warning(f"Failed to save debug screenshot ({prefix}): {e}")
            return None

    async def _click_retry_if_present(self, page: Page) -> None:
        """Click a visible 'Retry' UI control if present; else send 'Retry'."""
        try:
            retry_selectors = [
                'button:has-text("Retry")',
                'button:has-text("Tentar novamente")',
                'button:has-text("Try again")',
                '[data-testid*="retry"]',
            ]
            for selector in retry_selectors:
                try:
                    btn = page.locator(selector).first
                    if await btn.is_visible(timeout=1000):
                        await human_move_and_click(page, btn)
                        await human_delay(300, 600)
                        return
                except Exception:
                    continue
        except Exception:
            pass

        # Fallback: send the text "Retry" in the chat
        try:
            await self._send_message(page, "Retry")
        except Exception:
            pass

    async def _goto_chatgpt(self, page: Page) -> None:
        """Navigate to ChatGPT with retries.

        Rationale:
        - When opening multiple pages concurrently, transient timeouts can occur.
        - Retrying once with a longer timeout is usually sufficient.
        """
        last_err: Optional[Exception] = None
        for attempt in range(self.config.max_query_retries + 1):
            try:
                await page.goto(
                    self.config.chatgpt_url,
                    wait_until="domcontentloaded",
                    timeout=self.config.goto_timeout_ms,
                )
                return
            except Exception as e:
                last_err = e
                # Small backoff before retry
                await asyncio.sleep(1 + attempt)

        raise RuntimeError(f"Failed to load ChatGPT after retries: {last_err}")

    async def _close_modals(self, page: Page) -> None:
        """Close any modals that might block interaction."""
        try:
            # Check if the rate limit / no-auth modal is present
            rate_limit_modal = page.locator('[data-testid="modal-no-auth-rate-limit"]')
            if await rate_limit_modal.is_visible(timeout=2000):
                logger.warning(
                    "Rate limit modal detected - user may not be logged in. "
                    "Attempting to dismiss..."
                )
                # Try clicking outside the modal to dismiss it
                # The modal has an absolute overlay, so we need to click the backdrop
                try:
                    # Look for a close X button
                    close_btns = [
                        '[data-testid="modal-no-auth-rate-limit"] button[aria-label="Close"]',
                        '[data-testid="modal-no-auth-rate-limit"] button[aria-label="Fechar"]',
                        'button[aria-label="Close"]',
                    ]
                    for selector in close_btns:
                        try:
                            btn = page.locator(selector).first
                            if await btn.is_visible(timeout=500):
                                await human_move_and_click(page, btn)
                                logger.info(f"Closed rate limit modal via: {selector}")
                                await human_delay(300, 600)
                                return
                        except Exception:
                            continue
                except Exception:
                    pass

                # If no close button, try pressing Escape
                await human_delay(200, 400)
                await page.keyboard.press("Escape")
                await human_delay(300, 600)

                # If modal still visible, this is a hard block - user not logged in
                if await rate_limit_modal.is_visible(timeout=500):
                    raise RuntimeError(
                        "Not logged in - rate limit modal cannot be dismissed. "
                        "Please run: python login_chatgpt_timed.py 120"
                    )

            # Try pressing Escape to close any other modals
            await human_delay(100, 200)
            await page.keyboard.press("Escape")
            await human_delay(200, 400)

        except RuntimeError:
            raise
        except Exception as e:
            logger.debug(f"Error closing modals: {e}")

    async def _select_pro_model(self, page: Page) -> None:
        """Select the Pro model from the model selector dropdown.

        This is required before enabling Deep Research.
        """
        try:
            # Find and click the model selector
            model_selector = page.locator(
                '[data-testid="model-switcher-dropdown-button"]'
            )
            if await model_selector.is_visible(timeout=3000):
                await human_thinking_pause()
                await human_move_and_click(page, model_selector)
                logger.info("Opened model selector dropdown")
                await human_delay(500, 1000)

                # Look for Pro option in the dropdown
                pro_selectors = [
                    '[role="menuitemradio"]:has-text("Pro")',
                    '[role="menuitem"]:has-text("Pro")',
                    'button:has-text("5.2 Pro")',
                    'button:has-text("GPT-5")',
                ]

                for selector in pro_selectors:
                    try:
                        option = page.locator(selector).first
                        if await option.is_visible(timeout=2000):
                            await human_delay(300, 600)
                            await human_move_and_click(page, option)
                            logger.info(f"Selected Pro model via: {selector}")
                            await human_delay(500, 1000)
                            return
                    except Exception:
                        continue

                # Close dropdown if Pro not found (might already be selected)
                await page.keyboard.press("Escape")
                await human_delay(200, 400)
                logger.debug("Pro model may already be selected")

        except Exception as e:
            logger.debug(f"Error selecting Pro model: {e}")

    async def _enable_deep_research(self, page: Page) -> None:
        """Enable Deep Research mode.

        ChatGPT's UI (Dec 2025) workflow:
        1. Click the composer to focus it (reveals + button)
        2. Click the "+" button (data-testid=composer-plus-btn) to open menu
        3. Click "Deep research" menu item (role=menuitemradio)

        Note: This is different from:
        - "Web search": Quick web search
        - "Extended Thinking": Separate feature, cannot combine with Deep Research
        - "Agent mode": Agentic task execution
        """
        try:
            # Step 1: Focus composer to reveal + button
            composer = page.locator("#prompt-textarea")
            if await composer.is_visible(timeout=2000):
                await human_move_and_click(page, composer)
                await human_delay(400, 800)
                logger.debug("Composer focused")

            # Step 2: Click the "+" button to open the options menu
            plus_btn = page.locator('[data-testid="composer-plus-btn"]')
            if await plus_btn.is_visible(timeout=2000):
                await human_delay(200, 500)
                await human_move_and_click(page, plus_btn)
                logger.info("Opened options menu via composer-plus-btn")
                await human_delay(600, 1000)
            else:
                # Fallback selectors
                fallback_selectors = [
                    'button[aria-label="Add files and more"]',
                    'button[aria-label="Adicionar arquivos e mais"]',  # Portuguese
                ]
                clicked = False
                for selector in fallback_selectors:
                    try:
                        btn = page.locator(selector).first
                        if await btn.is_visible(timeout=1000):
                            await human_move_and_click(page, btn)
                            logger.info(f"Opened options menu via: {selector}")
                            clicked = True
                            await human_delay(600, 1000)
                            break
                    except Exception:
                        continue
                if not clicked:
                    logger.warning("Could not find '+' button")
                    return

            # Step 3: Click "Deep research" menu item
            deep_research_selectors = [
                '[role="menuitemradio"]:has-text("Deep research")',
                '[role="menuitemradio"]:has-text("Investigar")',  # Portuguese
                '[role="menuitem"]:has-text("Deep research")',
                '[role="menuitem"]:has-text("Investigar")',
            ]

            for selector in deep_research_selectors:
                try:
                    option = page.locator(selector).first
                    if await option.is_visible(timeout=2000):
                        await human_delay(300, 600)
                        await human_move_and_click(page, option)
                        logger.info(f"Deep Research mode enabled via: {selector}")
                        await human_thinking_pause()
                        return
                except Exception:
                    continue

            logger.warning(
                "Could not find Deep Research option - proceeding without it"
            )

        except Exception as e:
            logger.warning(f"Error enabling Deep Research mode: {e}")

    async def _send_message(self, page: Page, message: str) -> None:
        """Type and send a message with human-like behavior."""
        # Find the composer element (contenteditable div or textarea)
        # Priority order: current UI first
        composer_selectors = [
            "#prompt-textarea",  # Current (Dec 2025) - contenteditable div
            'div[contenteditable="true"]',
            'textarea[data-testid="composer-input"]',  # Old selector
        ]

        composer = None
        for selector in composer_selectors:
            try:
                elem = page.locator(selector).first
                if await elem.is_visible(timeout=1000):
                    composer = elem
                    break
            except Exception:
                continue

        if not composer:
            raise RuntimeError("Could not find composer element")

        # Human-like: move to composer, pause, then start typing
        await human_move_and_click(page, composer)
        await human_thinking_pause()

        # For long messages, use fill (faster but still looks natural with pause after)
        # For short messages, type character by character
        if len(message) > 200:
            # Use fill for long messages but add human pauses around it
            await composer.fill(message)
            await human_delay(500, 1000)
        else:
            # Type short messages naturally
            await human_type(page, composer, message)

        # Pause like a human would before sending (reviewing the message)
        await human_thinking_pause()

        # Find and click send button, or press Ctrl+Enter
        try:
            send_button = page.locator(
                '[data-testid="send-button"], button[aria-label*="Send"], button[aria-label*="Enviar"]'
            ).first
            if (
                await send_button.is_visible(timeout=2000)
                and await send_button.is_enabled()
            ):
                await human_delay(200, 400)
                await human_move_and_click(page, send_button)
            else:
                # Use Ctrl+Enter to send (works better in ChatGPT)
                await human_delay(100, 300)
                await composer.press("Control+Enter")
        except Exception:
            await human_delay(100, 300)
            await composer.press("Control+Enter")

        logger.info("Message sent")

    async def _wait_for_response(
        self,
        page: Page,
        timeout: int = 1800,
        deep_research_enabled: bool = False,
    ) -> str:
        """Wait for the response to complete and extract text.

        Notes:
        - For Deep Research, the assistant may first reply with a short "I'll start" message
          while continuing to research. In that case we keep waiting for a longer, stable answer.
        """
        start_time = asyncio.get_event_loop().time()
        last_content = ""
        stable_count = 0
        last_log_bucket = -1

        def _looks_like_placeholder(text: str) -> bool:
            t = (text or "").strip().lower()
            if len(t) < 250:
                for needle in [
                    "i'll begin",
                    "i’ll begin",
                    "i'll start",
                    "i’ll start",
                    "i'll compile",
                    "i’ll compile",
                    "i'll prepare",
                    "i’ll prepare",
                    "let you know when it's ready",
                    "let you know when it’s ready",
                    "feel free to keep chatting",
                    "i’ll let you know as soon as it’s ready",
                ]:
                    if needle in t:
                        return True
            return False

        while True:
            elapsed = asyncio.get_event_loop().time() - start_time
            if elapsed > timeout:
                raise TimeoutError(f"Response timeout after {timeout}s")

            # Check if still generating
            is_generating = False
            try:
                stop_button = page.locator(
                    '[data-testid="stop-button"], button[aria-label*="Stop"]'
                )
                is_generating = await stop_button.is_visible(timeout=1000)
            except Exception:
                pass

            # Also check for thinking/researching indicators
            try:
                thinking = page.locator(
                    '[data-testid="thinking-indicator"], .thinking, .researching'
                )
                if await thinking.is_visible(timeout=500):
                    is_generating = True
            except Exception:
                pass

            # Extract last assistant message
            try:
                messages = page.locator('[data-message-author-role="assistant"]')
                count = await messages.count()
                if count > 0:
                    last_message = messages.nth(count - 1)
                    current_content = await last_message.inner_text()

                    if current_content == last_content:
                        stable_count += 1
                    else:
                        stable_count = 0
                        last_content = current_content

                    stable_enough = stable_count >= 5
                    if stable_enough and not is_generating:
                        # If Deep Research is enabled, ignore early placeholder replies
                        if deep_research_enabled and _looks_like_placeholder(
                            current_content
                        ):
                            stable_count = 0
                        else:
                            return self._clean_response(current_content)
            except Exception as e:
                logger.debug(f"Error extracting response: {e}")

            # Log progress every ~30 seconds without spamming
            bucket = int(elapsed) // 30
            if bucket != last_log_bucket and bucket > 0:
                logger.info(
                    f"Still waiting... {int(elapsed)}s elapsed, {len(last_content)} chars so far"
                )
                last_log_bucket = bucket

            await asyncio.sleep(1)

    def _clean_response(self, text: str) -> str:
        """Clean up the response text."""
        # Remove common UI artifacts
        text = re.sub(r"\d+\s*/\s*\d+$", "", text)  # Remove pagination like "1 / 3"
        text = re.sub(r"Copy code", "", text)
        text = text.strip()
        return text
