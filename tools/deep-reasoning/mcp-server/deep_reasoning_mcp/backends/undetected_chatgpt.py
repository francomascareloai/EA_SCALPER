"""Undetected Chrome backend for ChatGPT Deep Research.

This uses undetected-chromedriver which patches Chrome to avoid bot detection.
Much more robust than Playwright for sites with anti-bot measures.

Supports interactive conversations where GPT may ask clarifying questions.

Version: 2.0 - Robustness improvements based on adversarial review
"""

import logging
import random
import re
import shutil
import time
import uuid
from datetime import datetime
from pathlib import Path
from threading import Lock
from typing import Optional

import undetected_chromedriver as uc
from selenium.common.exceptions import (
    NoSuchElementException,
    StaleElementReferenceException,
    TimeoutException,
    WebDriverException,
)
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

from ..models import (
    MODEL_PROVIDERS,
    ModelProvider,
    ModelResult,
    ReasoningModel,
    TaskStatus,
)
from . import BaseBackend

logger = logging.getLogger(__name__)


# =============================================================================
# CONSTANTS
# =============================================================================

# Thresholds for clarification detection
MIN_TEXT_LENGTH = 20
MAX_SHORT_RESPONSE = 800  # Raised from 500
MAX_MEDIUM_RESPONSE = 2500
CLARIFICATION_SCORE_THRESHOLD = 3

# Stability constants for response detection
STABLE_SECONDS = 5
POLL_INTERVAL_SECONDS = 1

# Conversation limits
MAX_CLARIFICATIONS_PER_CONVERSATION = 5
CONVERSATION_TTL_SECONDS = 7200  # 2 hours


# =============================================================================
# CLARIFICATION DETECTION - WEIGHTED SCORING SYSTEM
# =============================================================================

# Compile patterns once at module level for performance
CLARIFICATION_PATTERNS = [
    # English - Direct requests
    re.compile(r"could you (please )?(clarify|specify|elaborate|explain|tell me more)"),
    re.compile(r"can you (provide|give|share) more (details|information|context)"),
    re.compile(r"please (let me know|specify|clarify|tell me)"),
    re.compile(r"i('d| would) (like|need) to (know|understand)"),
    # English - Question words
    re.compile(r"what (specifically|exactly|particular|type of|kind of|sort of)"),
    re.compile(r"which (aspects?|areas?|topics?|parts?|one|option)"),
    re.compile(r"how (detailed?|comprehensive|deep|much|many)"),
    re.compile(r"who is (this for|the audience|the target)"),
    # English - Conditional/Preparatory
    re.compile(
        r"to (better|properly|accurately|effectively) (help|assist|answer|research)"
    ),
    re.compile(r"before i (begin|start|proceed|research|dive in)"),
    re.compile(r"in order to (provide|give|research)"),
    re.compile(r"just to (clarify|confirm|make sure|verify)"),
    # English - Preferences/Choices
    re.compile(r"are you (interested|looking) (in|for)"),
    re.compile(r"do you want me to (focus|concentrate|cover|include)"),
    re.compile(r"would you (prefer|like) (me to|that i)"),
    re.compile(r"should i (focus|cover|include|prioritize)"),
    # English - Scope/Requirements
    re.compile(r"what level of detail"),
    re.compile(r"how recent should"),
    re.compile(r"what time ?(period|frame|range)"),
    re.compile(r"are you comparing"),
    # English - Direct need statements
    re.compile(r"i need (to know|more information|clarification)"),
    re.compile(r"it would help( me)? to (know|understand)"),
    re.compile(
        r"(further|additional) (specification|clarification|information) is (needed|required)"
    ),
    # Portuguese patterns
    re.compile(r"poderia (esclarecer|especificar|detalhar|explicar)"),
    re.compile(r"pode (me dar|fornecer|compartilhar) mais (detalhes|informações)"),
    re.compile(r"qual (aspecto|área|tópico|tipo)"),
    re.compile(r"você (quer|gostaria|prefere) que eu"),
    re.compile(r"antes de (começar|iniciar|prosseguir)"),
    re.compile(r"para (melhor|poder) (ajudar|responder|pesquisar)"),
    re.compile(r"preciso (saber|entender|de mais)"),
    # Spanish patterns
    re.compile(r"podr[ií]as? (aclarar|especificar|explicar)"),
    re.compile(r"qu[ée] (aspecto|[áa]rea|tipo)"),
    re.compile(r"prefieres? que (me enfoque|cubra|investigue)"),
    # French patterns
    re.compile(r"pourriez[- ]vous (pr[ée]ciser|expliquer|clarifier)"),
    re.compile(r"quel(le)?s? (aspect|domaine|type)"),
    re.compile(r"avant de (commencer|proc[ée]der)"),
]

# Patterns that indicate a final/complete answer
ANSWER_PATTERNS = [
    # Document structure
    re.compile(r"^(here|aqui|voici)\b", re.IGNORECASE),
    re.compile(r"^##+ ", re.MULTILINE),
    re.compile(r"^\d+\.\s", re.MULTILINE),
    re.compile(r"^\*\s", re.MULTILINE),
    # Conclusions
    re.compile(r"\b(in summary|in conclusion|to summarize|overall)\b"),
    re.compile(r"\b(em resumo|em conclus[ãa]o|no geral)\b"),
    # Answers/Results
    re.compile(r"(the answer is|a resposta [ée])"),
    re.compile(r"(the results? (show|indicate)|os resultados (mostram|indicam))"),
    re.compile(r"(key findings?|principais descobertas)"),
    re.compile(r"(based on my research|com base na minha pesquisa)"),
    re.compile(r"(after (extensive )?research|ap[óo]s (extensa )?pesquisa)"),
    # Definitive language
    re.compile(r"(there are \d+|existem \d+)"),
    re.compile(r"\b(main points?|key takeaways?|pontos principais)\b"),
    re.compile(r"\b(according to|sources indicate|studies show)\b"),
    # Data/Evidence markers
    re.compile(r"\d+%|\d+\.\d+%"),  # Percentages
    re.compile(r"^\s*\|.*\|.*\|", re.MULTILINE),  # Markdown tables
    re.compile(r"\[\d+\]"),  # Citation markers
]


def is_clarification_question(text: str) -> tuple[bool, float]:
    """Detect if response is asking for clarification vs giving answer.

    Uses weighted scoring approach for robustness.

    Returns:
        tuple: (is_clarification, confidence_score 0-1)
    """
    if not text or len(text) < MIN_TEXT_LENGTH:
        return False, 0.0

    text_lower = text.lower()
    text_clean = text.strip()
    length = len(text)

    # === SIGNALS (each adds/subtracts points) ===
    score = 0

    # 1. Pattern matches (strongest signal)
    clarification_matches = sum(
        1 for p in CLARIFICATION_PATTERNS if p.search(text_lower)
    )
    answer_matches = sum(1 for p in ANSWER_PATTERNS if p.search(text_lower))

    score += clarification_matches * 3  # Each match = +3
    score -= answer_matches * 4  # Each match = -4 (answers weighted higher)

    # 2. Question marks (position matters)
    question_marks = text.count("?")

    # Check last sentence specifically (strongest signal for questions)
    lines = [l.strip() for l in text_clean.split("\n") if l.strip()]
    if lines:
        last_line = lines[-1]
        if len(last_line) > 10 and last_line.endswith("?"):
            score += 5  # Strong signal if last sentence is question

    # Multiple questions throughout
    if question_marks >= 2:
        score += 2
    elif question_marks == 1:
        score += 1

    # 3. Length-based adjustments
    if length < 400:
        # Short responses: patterns + "?" are strong signals
        score += 2
    elif length > MAX_MEDIUM_RESPONSE:
        # Very long responses: likely answers even with questions
        score -= 5
    # Medium range (400-2500): rely on patterns

    # 4. Structure indicators (strong answer signals)
    if re.search(r"^##+ ", text_clean, re.MULTILINE):
        score -= 3  # Headers = structured answer

    numbered_lines = len(re.findall(r"^\d+\.\s", text_clean, re.MULTILINE))
    if numbered_lines >= 3:
        score -= 3  # Long numbered list = answer

    # 5. Data/citation indicators
    if re.search(r"\d+%|\[\d+\]|according to|sources?:|reference:", text_lower):
        score -= 2  # Research data = answer

    # === DECISION ===
    is_clarification = score >= CLARIFICATION_SCORE_THRESHOLD

    # Normalize confidence to 0-1 range
    confidence = min(abs(score) / 15.0, 1.0)

    return is_clarification, confidence


# =============================================================================
# HUMAN-LIKE BEHAVIOR UTILITIES
# =============================================================================


def human_delay(min_sec: float = 0.1, max_sec: float = 0.3) -> None:
    """Random delay to simulate human reaction time using Gaussian distribution."""
    # Gaussian is more human-like than uniform
    mean = (min_sec + max_sec) / 2
    std = (max_sec - min_sec) / 4
    delay = max(min_sec, min(max_sec, random.gauss(mean, std)))
    time.sleep(delay)


def human_thinking_pause() -> None:
    """Longer pause to simulate human thinking (0.5-2s)."""
    time.sleep(random.gauss(1.0, 0.3))


def human_type(element, text: str, fast: bool = True) -> None:
    """Type text character by character with human-like timing.

    Args:
        element: The input element
        text: Text to type
        fast: If True, use faster typing speed (default for automation)
    """
    element.click()
    human_delay(0.1, 0.2)

    for char in text:
        element.send_keys(char)
        # Fast mode: ~100 chars/sec, Normal: ~20 chars/sec
        if fast:
            time.sleep(max(0.005, random.gauss(0.01, 0.003)))
        else:
            time.sleep(max(0.02, random.gauss(0.05, 0.02)))

        # Occasional micro-pause (reduced frequency in fast mode)
        pause_chance = 0.01 if fast else 0.05
        if random.random() < pause_chance:
            human_delay(0.05, 0.15)

        # Pause after punctuation (shorter in fast mode)
        if char in ".!?\n":
            if fast:
                human_delay(0.02, 0.05)
            else:
                human_delay(0.1, 0.3)


def smooth_scroll_to_element(driver, element) -> None:
    """Scroll smoothly to an element."""
    driver.execute_script(
        "arguments[0].scrollIntoView({behavior: 'smooth', block: 'center'});", element
    )
    human_delay(0.3, 0.6)


# =============================================================================
# MAIN BACKEND
# =============================================================================


def find_chrome_binary() -> str:
    """Find Chrome binary, handling WSL environment."""
    # Check for Linux Chrome first
    for binary in ["google-chrome", "chromium-browser", "chromium", "chrome"]:
        path = shutil.which(binary)
        if path:
            return path

    # Check for Windows Chrome via WSL
    windows_paths = [
        "/mnt/c/Program Files/Google/Chrome/Application/chrome.exe",
        "/mnt/c/Program Files (x86)/Google/Chrome/Application/chrome.exe",
    ]
    for path in windows_paths:
        if Path(path).exists():
            return path

    return ""  # Let undetected-chromedriver find it


class ChatGPTUndetectedConfig:
    """Configuration for ChatGPT Undetected Chrome backend."""

    def __init__(
        self,
        headless: bool = False,
        user_data_dir: Optional[Path] = None,
        profile_directory: str = "Default",
        timeout_seconds: int = 1800,  # 30 minutes for Deep Research
        chatgpt_url: str = "https://chatgpt.com",
        chrome_binary: Optional[str] = None,
        max_clarifications: int = MAX_CLARIFICATIONS_PER_CONVERSATION,
        save_screenshots_on_error: bool = True,
        screenshot_dir: Optional[Path] = None,
    ):
        self.headless = headless
        self.user_data_dir = (
            user_data_dir or Path.home() / ".deep-reasoning" / "chrome-profile"
        )
        self.profile_directory = profile_directory
        self.timeout_seconds = timeout_seconds
        self.chatgpt_url = chatgpt_url
        self.chrome_binary = chrome_binary or find_chrome_binary()
        self.max_clarifications = max_clarifications
        self.save_screenshots_on_error = save_screenshots_on_error
        self.screenshot_dir = (
            screenshot_dir or Path.home() / ".deep-reasoning" / "errors"
        )


class ChatGPTUndetectedBackend(BaseBackend):
    """
    Backend using undetected-chromedriver for ChatGPT Deep Research.

    This uses a patched Chrome that bypasses bot detection.
    Much more robust than Playwright for anti-bot protected sites.

    Features:
    - Undetected Chrome driver (bypasses Cloudflare, etc.)
    - Persistent profile (maintains login)
    - Human-like behavior (random delays, natural typing)
    - Interactive conversations (handles clarification questions)
    - Robust error handling and recovery
    - Screenshot capture on errors
    """

    def __init__(self, config: Optional[ChatGPTUndetectedConfig] = None):
        self.config = config or ChatGPTUndetectedConfig()
        self._driver: Optional[uc.Chrome] = None
        self._initialized = False
        # Thread-safe conversation storage
        self._conversations_lock = Lock()
        self._active_conversations: dict[str, dict] = {}

    def initialize(self) -> None:
        """Initialize undetected Chrome with saved profile."""
        self.config.user_data_dir.mkdir(parents=True, exist_ok=True)
        self.config.screenshot_dir.mkdir(parents=True, exist_ok=True)

        options = uc.ChromeOptions()

        # Set Chrome binary if specified
        if self.config.chrome_binary:
            options.binary_location = self.config.chrome_binary
            logger.info(f"Using Chrome binary: {self.config.chrome_binary}")

        # Use persistent profile
        user_data_dir = str(self.config.user_data_dir)

        options.add_argument(f"--user-data-dir={user_data_dir}")

        # Specify profile directory to avoid profile picker
        if self.config.profile_directory:
            options.add_argument(f"--profile-directory={self.config.profile_directory}")
            logger.info(f"Using Chrome profile: {self.config.profile_directory}")

        # Window size
        options.add_argument("--window-size=1280,900")

        # Anti-detection flags
        options.add_argument("--disable-blink-features=AutomationControlled")
        options.add_argument("--no-sandbox")
        options.add_argument("--disable-dev-shm-usage")

        if self.config.headless:
            options.add_argument("--headless=new")

        # Create driver
        self._driver = uc.Chrome(
            options=options,
            use_subprocess=True,
        )

        # Disable implicit waits to avoid conflicts with explicit waits
        self._driver.implicitly_wait(0)

        # Verify driver is working
        try:
            self._driver.get("about:blank")
        except Exception as e:
            raise RuntimeError(f"Chrome driver failed health check: {e}")

        self._initialized = True
        logger.info(
            f"ChatGPT Undetected backend initialized (profile: {user_data_dir}/{self.config.profile_directory})"
        )

    def _ensure_driver_alive(self) -> bool:
        """Check if driver is still alive, reinitialize if needed."""
        if not self._driver:
            return False

        try:
            # Quick health check
            _ = self._driver.title
            return True
        except (WebDriverException, Exception) as e:
            logger.warning(f"Driver appears dead ({e}), attempting recovery...")
            try:
                self.close()
                self.initialize()
                return self._initialized
            except Exception as reinit_error:
                logger.error(f"Failed to reinitialize driver: {reinit_error}")
                return False

    def _save_screenshot(self, name: str) -> Optional[Path]:
        """Save a screenshot for debugging."""
        if not self.config.save_screenshots_on_error or not self._driver:
            return None

        try:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            screenshot_path = self.config.screenshot_dir / f"{name}_{timestamp}.png"
            self._driver.save_screenshot(str(screenshot_path))
            logger.info(f"Screenshot saved: {screenshot_path}")
            return screenshot_path
        except Exception as e:
            logger.warning(f"Failed to save screenshot: {e}")
            return None

    def _cleanup_conversation(self, conversation_id: str) -> None:
        """Safely remove a conversation from active conversations."""
        with self._conversations_lock:
            self._active_conversations.pop(conversation_id, None)

    def _cleanup_stale_conversations(self) -> None:
        """Remove conversations older than TTL."""
        now = datetime.now()
        with self._conversations_lock:
            to_remove = []
            for conv_id, conv in self._active_conversations.items():
                started_at = conv.get("started_at")
                if started_at:
                    age = (now - started_at).total_seconds()
                    if age > CONVERSATION_TTL_SECONDS:
                        to_remove.append(conv_id)

            for conv_id in to_remove:
                logger.warning(f"Cleaning up stale conversation {conv_id}")
                del self._active_conversations[conv_id]

    def close(self) -> None:
        """Close browser."""
        if self._driver:
            try:
                self._driver.quit()
            except Exception as e:
                logger.warning(f"Error closing driver: {e}")
        self._initialized = False
        with self._conversations_lock:
            self._active_conversations.clear()

    def supports_model(self, model: ReasoningModel) -> bool:
        """This backend supports ChatGPT models for Deep Research."""
        return MODEL_PROVIDERS.get(model) == ModelProvider.CHATGPT

    def query(
        self,
        model: ReasoningModel,
        question: str,
        context: Optional[str] = None,
        system_hints: Optional[list[str]] = None,
    ) -> ModelResult:
        """
        Query ChatGPT via Undetected Chrome with real Deep Research.

        Returns:
            ModelResult with status=COMPLETED if done,
            or status=NEEDS_CLARIFICATION if GPT asked a follow-up question.
            Use continue_conversation() to respond.
        """
        if not self._initialized or not self._driver:
            return ModelResult(
                model=model,
                status=TaskStatus.FAILED,
                error="Backend not initialized. Call initialize() first.",
            )

        # Health check before starting
        if not self._ensure_driver_alive():
            return ModelResult(
                model=model,
                status=TaskStatus.FAILED,
                error="Chrome driver is not responsive.",
            )

        # Cleanup stale conversations periodically
        self._cleanup_stale_conversations()

        started_at = datetime.now()
        conversation_id = str(uuid.uuid4())[:8]

        try:
            driver = self._driver

            # Navigate to ChatGPT
            logger.info("Navigating to ChatGPT...")
            driver.get(self.config.chatgpt_url)

            # Human-like wait for page to load
            human_thinking_pause()
            human_delay(1.0, 2.0)

            # Wait for composer to appear
            wait = WebDriverWait(driver, 60)
            composer = self._wait_for_composer(wait)

            if not composer:
                self._save_screenshot(f"no_composer_{conversation_id}")
                # Check if login is needed
                if self._is_login_page(driver):
                    raise RuntimeError(
                        "Session expired - login required. Please log into ChatGPT in the browser."
                    )
                raise RuntimeError("Could not find composer - page may have changed")

            logger.info("Chat interface loaded")
            human_delay(0.5, 1.0)

            # Select Pro model and enable Deep Research if requested
            if system_hints and "research" in system_hints:
                self._select_pro_model(driver, wait)
                human_thinking_pause()
                self._enable_deep_research(driver, wait)

            # Compose and send the prompt
            full_prompt = f"{context}\n\n{question}" if context else question
            self._send_message(driver, wait, full_prompt)

            # Store conversation state for potential continuation
            with self._conversations_lock:
                self._active_conversations[conversation_id] = {
                    "model": model,
                    "original_question": question,
                    "context": context,
                    "system_hints": system_hints,
                    "messages": [{"role": "user", "content": full_prompt}],
                    "started_at": started_at,
                    "clarification_count": 0,
                }

            # Wait for response
            logger.info(
                "Waiting for response (this may take 10-20 minutes for Deep Research)..."
            )
            response_text = self._wait_for_response(driver, self.config.timeout_seconds)

            completed_at = datetime.now()
            duration = (completed_at - started_at).total_seconds()

            # Check if this is a clarification question
            is_clarification, confidence = is_clarification_question(response_text)

            if is_clarification:
                logger.info(
                    f"GPT asked for clarification (confidence: {confidence:.2f})"
                )
                with self._conversations_lock:
                    if conversation_id in self._active_conversations:
                        self._active_conversations[conversation_id]["messages"].append(
                            {"role": "assistant", "content": response_text}
                        )
                        self._active_conversations[conversation_id][
                            "clarification_count"
                        ] = 1

                return ModelResult(
                    model=model,
                    status=TaskStatus.NEEDS_CLARIFICATION,
                    clarification_question=response_text,
                    conversation_id=conversation_id,
                    started_at=started_at,
                    completed_at=completed_at,
                    duration_seconds=duration,
                )

            # Complete response
            logger.info(f"Got response in {duration:.1f}s ({len(response_text)} chars)")

            # Conversation complete, remove from active
            self._cleanup_conversation(conversation_id)

            return ModelResult(
                model=model,
                status=TaskStatus.COMPLETED,
                response=response_text,
                conversation_id=conversation_id,
                started_at=started_at,
                completed_at=completed_at,
                duration_seconds=duration,
            )

        except Exception as e:
            logger.error(f"Error in ChatGPT Undetected: {e}")
            self._save_screenshot(f"error_{conversation_id}")
            # CRITICAL: Clean up on failure
            self._cleanup_conversation(conversation_id)
            completed_at = datetime.now()
            return ModelResult(
                model=model,
                status=TaskStatus.FAILED,
                started_at=started_at,
                completed_at=completed_at,
                duration_seconds=(completed_at - started_at).total_seconds(),
                error=str(e),
            )

    def continue_conversation(
        self,
        conversation_id: str,
        response: str,
    ) -> ModelResult:
        """
        Continue a conversation by responding to a clarification question.

        Args:
            conversation_id: ID from the previous ModelResult
            response: Your response to GPT's question

        Returns:
            ModelResult - may be COMPLETED or NEEDS_CLARIFICATION again
        """
        with self._conversations_lock:
            if conversation_id not in self._active_conversations:
                return ModelResult(
                    model=ReasoningModel.GPT_5_PRO,
                    status=TaskStatus.FAILED,
                    error=f"Conversation {conversation_id} not found or expired",
                )
            conv = self._active_conversations[conversation_id].copy()

        model = conv["model"]
        clarification_count = conv.get("clarification_count", 0)

        # Check clarification limit
        if clarification_count >= self.config.max_clarifications:
            self._cleanup_conversation(conversation_id)
            return ModelResult(
                model=model,
                status=TaskStatus.FAILED,
                error=f"Max clarifications ({self.config.max_clarifications}) exceeded",
            )

        # Health check
        if not self._ensure_driver_alive():
            self._cleanup_conversation(conversation_id)
            return ModelResult(
                model=model,
                status=TaskStatus.FAILED,
                error="Chrome driver is not responsive.",
            )

        driver = self._driver
        wait = WebDriverWait(driver, 60)

        try:
            # Send the response
            logger.info(
                f"Continuing conversation {conversation_id} (clarification {clarification_count + 1})"
            )
            self._send_message(driver, wait, response)

            with self._conversations_lock:
                if conversation_id in self._active_conversations:
                    self._active_conversations[conversation_id]["messages"].append(
                        {"role": "user", "content": response}
                    )

            # Wait for next response
            response_text = self._wait_for_response(driver, self.config.timeout_seconds)

            completed_at = datetime.now()
            duration = (completed_at - conv["started_at"]).total_seconds()

            # Check if still asking for clarification
            is_clarification, confidence = is_clarification_question(response_text)

            if is_clarification:
                logger.info(
                    f"GPT asked for more clarification (confidence: {confidence:.2f})"
                )
                with self._conversations_lock:
                    if conversation_id in self._active_conversations:
                        self._active_conversations[conversation_id]["messages"].append(
                            {"role": "assistant", "content": response_text}
                        )
                        self._active_conversations[conversation_id][
                            "clarification_count"
                        ] = clarification_count + 1

                return ModelResult(
                    model=model,
                    status=TaskStatus.NEEDS_CLARIFICATION,
                    clarification_question=response_text,
                    conversation_id=conversation_id,
                    started_at=conv["started_at"],
                    completed_at=completed_at,
                    duration_seconds=duration,
                )

            # Got final response
            with self._conversations_lock:
                if conversation_id in self._active_conversations:
                    self._active_conversations[conversation_id]["messages"].append(
                        {"role": "assistant", "content": response_text}
                    )

            logger.info(f"Conversation {conversation_id} completed in {duration:.1f}s")

            # Clean up
            self._cleanup_conversation(conversation_id)

            return ModelResult(
                model=model,
                status=TaskStatus.COMPLETED,
                response=response_text,
                conversation_id=conversation_id,
                started_at=conv["started_at"],
                completed_at=completed_at,
                duration_seconds=duration,
            )

        except Exception as e:
            logger.error(f"Error continuing conversation: {e}")
            self._save_screenshot(f"continue_error_{conversation_id}")
            self._cleanup_conversation(conversation_id)
            return ModelResult(
                model=model,
                status=TaskStatus.FAILED,
                error=str(e),
            )

    def get_conversation_history(self, conversation_id: str) -> list[dict]:
        """Get the message history for a conversation."""
        with self._conversations_lock:
            if conversation_id in self._active_conversations:
                return (
                    self._active_conversations[conversation_id]
                    .get("messages", [])
                    .copy()
                )
        return []

    def _is_login_page(self, driver) -> bool:
        """Check if we're on a login page."""
        try:
            # Look for login indicators
            login_selectors = [
                'button:contains("Log in")',
                'button:contains("Sign up")',
                '[data-testid="login-button"]',
                'a[href*="auth"]',
            ]
            for selector in login_selectors:
                try:
                    elements = driver.find_elements(By.CSS_SELECTOR, selector)
                    if elements:
                        return True
                except Exception:
                    pass

            # Check URL
            if "auth" in driver.current_url or "login" in driver.current_url:
                return True

            return False
        except Exception:
            return False

    def _wait_for_composer(self, wait: WebDriverWait):
        """Wait for the composer element to appear."""
        selectors = [
            (By.ID, "prompt-textarea"),
            (By.CSS_SELECTOR, '[contenteditable="true"]'),
            (By.CSS_SELECTOR, 'textarea[data-testid="composer-input"]'),
        ]

        for by, selector in selectors:
            try:
                elem = wait.until(EC.presence_of_element_located((by, selector)))
                return elem
            except TimeoutException:
                continue

        return None

    def _select_pro_model(self, driver, wait: WebDriverWait) -> None:
        """Select the Pro model from dropdown."""
        try:
            # Find model selector
            model_btn = driver.find_element(
                By.CSS_SELECTOR, '[data-testid="model-switcher-dropdown-button"]'
            )
            if model_btn:
                human_thinking_pause()
                smooth_scroll_to_element(driver, model_btn)
                human_delay(0.2, 0.4)
                model_btn.click()
                logger.info("Opened model selector")
                human_delay(0.5, 1.0)

                # Look for Pro option
                options = driver.find_elements(
                    By.CSS_SELECTOR, '[role="menuitemradio"]'
                )
                option = None  # Initialize to avoid UnboundLocalError

                for opt in options:
                    if "Pro" in opt.text:
                        option = opt
                        break

                if option:
                    human_delay(0.3, 0.6)
                    option.click()
                    logger.info("Selected Pro model")
                    human_delay(0.5, 1.0)
                else:
                    # Close dropdown if Pro not found
                    driver.find_element(By.TAG_NAME, "body").send_keys(Keys.ESCAPE)
                    human_delay(0.2, 0.4)
                    logger.debug("Pro model may already be selected")

        except NoSuchElementException:
            logger.debug("Model selector not found")
        except Exception as e:
            logger.warning(f"Error selecting Pro model: {e}")

    def _enable_deep_research(self, driver, wait: WebDriverWait) -> None:
        """Enable Deep Research mode."""
        try:
            # Step 1: Focus composer
            composer = driver.find_element(By.ID, "prompt-textarea")
            smooth_scroll_to_element(driver, composer)
            human_delay(0.2, 0.4)
            composer.click()
            human_delay(0.4, 0.8)
            logger.debug("Composer focused")

            # Step 2: Click the "+" button
            plus_selectors = [
                '[data-testid="composer-plus-btn"]',
                'button[aria-label="Add files and more"]',
                'button[aria-label="Adicionar arquivos e mais"]',
            ]

            plus_btn = None
            for selector in plus_selectors:
                try:
                    plus_btn = driver.find_element(By.CSS_SELECTOR, selector)
                    if plus_btn.is_displayed():
                        break
                except NoSuchElementException:
                    continue

            if plus_btn:
                human_delay(0.2, 0.5)
                plus_btn.click()
                logger.info("Opened options menu")
                human_delay(0.6, 1.0)
            else:
                logger.warning("Could not find '+' button")
                return

            # Step 3: Click "Deep research" menu item
            menu_items = driver.find_elements(By.CSS_SELECTOR, '[role="menuitemradio"]')
            for item in menu_items:
                text = item.text.lower()
                if "deep research" in text or "investigar" in text:
                    human_delay(0.3, 0.6)
                    item.click()
                    logger.info("Deep Research mode enabled")
                    human_thinking_pause()
                    return

            logger.warning("Could not find Deep Research option")

        except NoSuchElementException as e:
            logger.warning(f"Element not found enabling Deep Research: {e}")
        except Exception as e:
            logger.warning(f"Error enabling Deep Research: {e}")

    def _send_message(self, driver, wait: WebDriverWait, message: str) -> None:
        """Type and send a message."""
        # Find composer
        try:
            composer = driver.find_element(By.ID, "prompt-textarea")
        except NoSuchElementException:
            raise RuntimeError("Composer not found - page may have changed")

        smooth_scroll_to_element(driver, composer)
        human_delay(0.2, 0.4)
        composer.click()
        human_thinking_pause()

        # Type message (use JS for messages > 50 chars, char-by-char for short)
        if len(message) > 50:
            # Use JavaScript to set value directly (faster for long text)
            driver.execute_script(
                "arguments[0].innerText = arguments[1];", composer, message
            )
            # Trigger multiple events for compatibility
            driver.execute_script(
                """
                const elem = arguments[0];
                ['input', 'change', 'keyup'].forEach(event =>
                    elem.dispatchEvent(new Event(event, {bubbles: true}))
                );
            """,
                composer,
            )
            human_delay(0.5, 1.0)

            # Verify text was inserted
            actual_text = composer.get_attribute("innerText") or ""
            if len(actual_text.strip()) < len(message) * 0.9:  # Allow 10% variance
                logger.warning(
                    "JS text insertion may have failed, falling back to typing"
                )
                composer.clear()
                human_type(composer, message[:500])  # Type at least the first part
        else:
            human_type(composer, message)

        # Review pause
        human_thinking_pause()

        # Find and click send button
        send_selectors = [
            '[data-testid="send-button"]',
            'button[aria-label*="Send"]',
            'button[aria-label*="Enviar"]',
        ]

        for selector in send_selectors:
            try:
                send_btn = driver.find_element(By.CSS_SELECTOR, selector)
                if send_btn.is_displayed() and send_btn.is_enabled():
                    human_delay(0.2, 0.4)
                    send_btn.click()
                    logger.info("Message sent")
                    return
            except NoSuchElementException:
                continue

        # Fallback: Ctrl+Enter
        composer.send_keys(Keys.CONTROL + Keys.RETURN)
        logger.info("Message sent via Ctrl+Enter")

    def _wait_for_response(self, driver, timeout: int = 1800) -> str:
        """Wait for the response to complete and extract text."""
        start_time = time.time()
        last_content = ""
        last_change_time = time.time()
        last_log_interval = 0
        last_health_check = time.time()

        while True:
            elapsed = time.time() - start_time

            if elapsed > timeout:
                # Try to extract partial response before timeout
                logger.warning(f"Timeout after {timeout}s, extracting partial response")
                if last_content:
                    return self._clean_response(last_content)
                raise TimeoutError(f"Response timeout after {timeout}s with no content")

            # Periodic health check (every 60s)
            if time.time() - last_health_check > 60:
                if not self._ensure_driver_alive():
                    raise RuntimeError("Chrome driver died during response wait")
                last_health_check = time.time()

            # Wrap ALL DOM operations in stale element handling
            try:
                # Check if still generating
                is_generating = False
                try:
                    stop_btn = driver.find_element(
                        By.CSS_SELECTOR,
                        '[data-testid="stop-button"], button[aria-label*="Stop"]',
                    )
                    is_generating = stop_btn.is_displayed()
                except NoSuchElementException:
                    pass

                # Check for thinking/researching indicators
                try:
                    thinking = driver.find_element(
                        By.CSS_SELECTOR,
                        '[data-testid="thinking-indicator"], [class*="thinking"], [class*="researching"]',
                    )
                    if thinking.is_displayed():
                        is_generating = True
                except NoSuchElementException:
                    pass

                # Extract response text
                messages = driver.find_elements(
                    By.CSS_SELECTOR, '[data-message-author-role="assistant"]'
                )
                if messages:
                    last_message = messages[-1]
                    current_content = last_message.text

                    if current_content != last_content:
                        last_change_time = time.time()
                        last_content = current_content

                    # If stable for STABLE_SECONDS and not generating, done
                    stable_duration = time.time() - last_change_time
                    if not is_generating and stable_duration >= STABLE_SECONDS:
                        return self._clean_response(current_content)

            except StaleElementReferenceException:
                # Element went stale (DOM changed), retry on next iteration
                logger.debug("Stale element, retrying...")
                time.sleep(POLL_INTERVAL_SECONDS)
                continue
            except Exception as e:
                logger.warning(f"Error extracting response: {e}")

            # Log progress every 30 seconds (avoid duplicate logs)
            current_interval = int(elapsed) // 30
            if current_interval > last_log_interval:
                logger.info(
                    f"Still waiting... {int(elapsed)}s elapsed, {len(last_content)} chars so far"
                )
                last_log_interval = current_interval

            time.sleep(POLL_INTERVAL_SECONDS)

    def _clean_response(self, text: str) -> str:
        """Clean up the response text."""
        # Remove pagination indicators at end only
        text = re.sub(r"\d+\s*/\s*\d+$", "", text)
        # Remove "Copy code" from code block headers (not body)
        text = re.sub(r"^Copy code\s*$", "", text, flags=re.MULTILINE)
        return text.strip()


# Convenience function for quick testing
def test_undetected_backend():
    """Quick test of the undetected backend."""
    config = ChatGPTUndetectedConfig(headless=False, timeout_seconds=120)
    backend = ChatGPTUndetectedBackend(config)

    try:
        backend.initialize()
        result = backend.query(
            model=ReasoningModel.GPT_5_PRO,
            question="What is 2+2?",
        )
        print(f"Status: {result.status}")
        print(f"Duration: {result.duration_seconds:.1f}s")
        if result.response:
            print(f"Response: {result.response[:200]}")
        else:
            print(f"Error: {result.error}")
    finally:
        backend.close()


if __name__ == "__main__":
    test_undetected_backend()
