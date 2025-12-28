#!/usr/bin/env python3
"""Debug Deep Research flow step by step."""

import asyncio
import logging
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from playwright.async_api import async_playwright

logging.basicConfig(level=logging.INFO, format="%(levelname)s:%(name)s:%(message)s")


async def main():
    session_dir = Path.home() / ".deep-reasoning" / "chatgpt-session"

    print("Opening ChatGPT...")

    pw = await async_playwright().start()

    context = await pw.chromium.launch_persistent_context(
        user_data_dir=str(session_dir),
        headless=False,
        viewport={"width": 1280, "height": 900},
        args=[
            "--disable-blink-features=AutomationControlled",
            "--no-sandbox",
        ],
    )

    page = await context.new_page()
    await page.goto("https://chatgpt.com", wait_until="domcontentloaded", timeout=60000)
    await asyncio.sleep(5)

    print("\n=== STEP 1: Clicking composer ===\n")
    composer = page.locator("#prompt-textarea")
    await composer.click()
    await asyncio.sleep(1)

    print("\n=== STEP 2: Clicking + button ===\n")
    plus_btn = page.locator('[data-testid="composer-plus-btn"]')
    await plus_btn.click()
    await asyncio.sleep(1)

    print("\n=== STEP 3: Clicking Deep Research ===\n")
    deep_research = page.locator(
        '[role="menuitemradio"]:has-text("Deep research")'
    ).first
    if not await deep_research.is_visible(timeout=2000):
        # Try Portuguese
        deep_research = page.locator(
            '[role="menuitemradio"]:has-text("Investigar")'
        ).first

    await deep_research.click()
    print("Clicked Deep Research")

    # Wait and observe
    await asyncio.sleep(2)

    print("\n=== STEP 4: Looking for Research badge ===\n")
    # Look for the badge that appears when Deep Research is enabled
    badge_selectors = [
        '[aria-label*="Research"]',
        '[aria-label*="Investigar"]',
        'button:has-text("Research")',
        'button:has-text("Investigar")',
    ]

    for selector in badge_selectors:
        try:
            elem = page.locator(selector).first
            if await elem.is_visible(timeout=1000):
                text = await elem.inner_text()
                aria = await elem.get_attribute("aria-label")
                print(f"  Found badge: text='{text}' aria='{aria}'")
        except Exception:
            continue

    print("\n=== STEP 5: Looking for any confirmation UI ===\n")
    # Check if there's a confirmation dialog or additional UI
    all_buttons = page.locator("button")
    count = await all_buttons.count()
    print(f"Total buttons: {count}")

    for i in range(count):
        try:
            btn = all_buttons.nth(i)
            if await btn.is_visible(timeout=100):
                text = await btn.inner_text()
                aria = await btn.get_attribute("aria-label")
                testid = await btn.get_attribute("data-testid")
                if text or aria:
                    print(
                        f"  Button {i}: text='{text[:50] if text else ''}' aria='{aria}' testid='{testid}'"
                    )
        except:
            continue

    print("\n=== STEP 6: Typing a complex question ===\n")

    # Click composer again to focus
    await composer.click()
    await asyncio.sleep(0.5)

    # Type a complex question that should trigger clarifying questions
    question = """I need comprehensive research on the latest advances in quantum computing for financial applications in 2025.
    Specifically looking at:
    1. Which banks/hedge funds are deploying quantum systems
    2. What specific algorithms are being used for portfolio optimization
    3. Any regulatory frameworks being developed
    Please provide sources and citations."""

    await composer.fill(question)
    await asyncio.sleep(1)

    print("Question typed")

    print("\n=== STEP 7: Before clicking send - checking UI state ===\n")

    # Check for any pending confirmations or special states
    dialogs = page.locator('[role="dialog"]')
    dialog_count = await dialogs.count()
    print(f"Open dialogs: {dialog_count}")

    # Check composer state
    composer_text = await composer.inner_text()
    print(f"Composer content length: {len(composer_text)}")

    # Look for send button
    send_btn = page.locator('[data-testid="send-button"]').first
    if await send_btn.is_visible(timeout=1000):
        enabled = await send_btn.is_enabled()
        print(f"Send button visible: True, enabled: {enabled}")

    print("\n=== STEP 8: Sending message ===\n")

    # Send the message
    await send_btn.click()
    print("Message sent")

    print("\n=== STEP 9: Observing response (30 seconds) ===\n")

    # Watch for the response and any clarifying questions
    for i in range(30):
        await asyncio.sleep(1)

        # Check for assistant messages
        messages = page.locator('[data-message-author-role="assistant"]')
        count = await messages.count()

        if count > 0:
            last_msg = messages.nth(count - 1)
            text = await last_msg.inner_text()
            print(
                f"  [{i + 1}s] Assistant message ({len(text)} chars): {text[:200]}..."
            )

            # Check if it's asking clarifying questions
            if any(
                phrase in text.lower()
                for phrase in [
                    "clarify",
                    "esclarecer",
                    "could you",
                    "can you",
                    "would you like",
                    "gostaria",
                ]
            ):
                print("\n  *** CLARIFYING QUESTION DETECTED! ***\n")

        # Check for any special Deep Research UI
        research_ui = page.locator('[class*="research"], [class*="deep"]')
        research_count = await research_ui.count()
        if research_count > 0:
            print(f"  Research UI elements: {research_count}")

    print("\n=== KEEPING BROWSER OPEN FOR 60 SECONDS ===")
    print("Observe the behavior manually...\n")
    await asyncio.sleep(60)

    await context.close()
    await pw.stop()
    print("Done")


if __name__ == "__main__":
    asyncio.run(main())
