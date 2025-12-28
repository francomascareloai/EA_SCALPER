#!/usr/bin/env python3
"""Debug ChatGPT interface to find correct selectors."""

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
    await asyncio.sleep(5)  # Give more time for full load

    print("\n=== LOOKING FOR TEXTAREAS ===\n")

    textareas = page.locator("textarea")
    count = await textareas.count()
    print(f"Found {count} textareas")

    for i in range(count):
        try:
            ta = textareas.nth(i)
            if await ta.is_visible(timeout=500):
                data_testid = await ta.get_attribute("data-testid")
                id_attr = await ta.get_attribute("id")
                placeholder = await ta.get_attribute("placeholder")
                print(
                    f"  Textarea {i}: id='{id_attr}' testid='{data_testid}' placeholder='{placeholder}'"
                )
        except:
            continue

    print("\n=== LOOKING FOR INPUT ELEMENTS ===\n")

    inputs = page.locator("input, [contenteditable='true']")
    count = await inputs.count()
    print(f"Found {count} inputs/contenteditable")

    for i in range(min(count, 10)):
        try:
            inp = inputs.nth(i)
            if await inp.is_visible(timeout=500):
                tag = await inp.evaluate("el => el.tagName")
                data_testid = await inp.get_attribute("data-testid")
                id_attr = await inp.get_attribute("id")
                print(f"  {tag} {i}: id='{id_attr}' testid='{data_testid}'")
        except:
            continue

    print("\n=== CHECKING LOGIN STATUS ===\n")

    # Look for login button
    login_btn = page.locator('[data-testid="login-button"]')
    has_login = await login_btn.count() > 0
    print(f"Login button exists: {has_login}")

    # Look for profile button (indicates logged in)
    profile_btn = page.locator('[data-testid="profile-button"]')
    has_profile = await profile_btn.count() > 0
    print(f"Profile button exists: {has_profile}")

    # Look for send button (indicates chat interface)
    send_btn = page.locator('[data-testid="send-button"]')
    has_send = await send_btn.count() > 0
    print(f"Send button exists: {has_send}")

    # Look for composer
    composer = page.locator('[data-testid*="composer"]')
    composer_count = await composer.count()
    print(f"Composer elements: {composer_count}")

    for i in range(min(composer_count, 5)):
        try:
            c = composer.nth(i)
            testid = await c.get_attribute("data-testid")
            print(f"  - {testid}")
        except:
            pass

    print("\n=== KEEPING BROWSER OPEN FOR 20 SECONDS ===")
    await asyncio.sleep(20)

    await context.close()
    await pw.stop()
    print("Done")


if __name__ == "__main__":
    asyncio.run(main())
