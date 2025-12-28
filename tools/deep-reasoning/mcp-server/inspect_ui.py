#!/usr/bin/env python3
"""Inspect ChatGPT UI buttons to find Deep Research option."""

import asyncio
import logging
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from playwright.async_api import async_playwright

logging.basicConfig(level=logging.INFO, format="%(levelname)s:%(name)s:%(message)s")


async def main():
    session_dir = Path.home() / ".deep-reasoning" / "chatgpt-session"

    print("Opening ChatGPT to inspect UI...")

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
    await asyncio.sleep(3)

    print("\n=== INSPECTING UI BUTTONS ===\n")

    # Find all buttons
    buttons = page.locator("button")
    count = await buttons.count()
    print(f"Found {count} buttons total\n")

    # Log interesting buttons
    for i in range(min(count, 30)):  # First 30 buttons
        try:
            button = buttons.nth(i)
            if await button.is_visible(timeout=500):
                text = await button.inner_text()
                aria_label = await button.get_attribute("aria-label")
                data_testid = await button.get_attribute("data-testid")

                if text or aria_label or data_testid:
                    print(
                        f"Button {i}: text='{text[:50] if text else ''}' aria='{aria_label}' testid='{data_testid}'"
                    )
        except:
            continue

    # Look for specific research-related elements
    print("\n=== SEARCHING FOR RESEARCH-RELATED ELEMENTS ===\n")

    research_patterns = [
        "Deep research",
        "deep-research",
        "Research",
        "Investigate",
        "Investigar",
        "Pesquisar",
        "Study",
        "Estudar",
        "Search",
    ]

    for pattern in research_patterns:
        try:
            elements = page.locator(f"text='{pattern}'")
            count = await elements.count()
            if count > 0:
                print(f"Found '{pattern}': {count} elements")
                for i in range(min(count, 3)):
                    el = elements.nth(i)
                    tag = await el.evaluate("el => el.tagName")
                    text = await el.inner_text()
                    print(f"  - {tag}: '{text[:50]}'")
        except:
            pass

    print("\n=== KEEPING BROWSER OPEN FOR 30 SECONDS ===")
    print("Observe the interface manually...")
    await asyncio.sleep(30)

    await context.close()
    await pw.stop()
    print("Done")


if __name__ == "__main__":
    asyncio.run(main())
