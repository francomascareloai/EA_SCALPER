#!/usr/bin/env python3
"""Interactive script to log in to Google/Gemini and save session.

Run this script from a terminal with display access:
    python login_gemini.py

A browser window will open. Log in to Google manually.
Once logged in and you see the Gemini interface, press Enter in the terminal.
The session will be saved for future automated use.
"""

import asyncio
import sys
from pathlib import Path

# Add parent to path for imports
sys.path.insert(0, str(Path(__file__).parent))

from playwright.async_api import async_playwright


async def main():
    session_dir = Path.home() / ".deep-reasoning" / "gemini-session"
    session_dir.mkdir(parents=True, exist_ok=True)

    print(f"Session will be saved to: {session_dir}")
    print("Opening browser...")
    print("")

    pw = await async_playwright().start()

    # Launch browser in non-headless mode
    context = await pw.chromium.launch_persistent_context(
        user_data_dir=str(session_dir),
        headless=False,  # Show browser window
        viewport={"width": 1280, "height": 900},
        args=[
            "--disable-blink-features=AutomationControlled",
            "--no-sandbox",
        ],
    )

    page = await context.new_page()

    print("Navigating to Gemini...")
    await page.goto(
        "https://gemini.google.com", wait_until="domcontentloaded", timeout=60000
    )

    print("")
    print("=" * 60)
    print("INSTRUCTIONS:")
    print("1. Log in to Google in the browser window")
    print("2. Wait until you see the Gemini chat interface")
    print("3. CLOSE THE BROWSER WINDOW to save the session")
    print("=" * 60)
    print("")
    print("Waiting for you to close the browser...")

    # Wait for page/context to close (user closes browser)
    try:
        await page.wait_for_event("close", timeout=600000)  # 10 min timeout
    except Exception:
        pass  # Page closed or timeout

    # Verify login worked by checking if session cookies exist
    cookies = await context.cookies()
    has_session = any(
        "SID" in c.get("name", "") or "SSID" in c.get("name", "") for c in cookies
    )

    if has_session:
        print("✓ Login successful! Google session cookies detected.")
    else:
        print("⚠ Warning: Session cookies not found. Login may not have worked.")

    print("Saving session...")
    await page.close()
    await context.close()
    await pw.stop()

    print("")
    print(f"✓ Session saved to: {session_dir}")
    print("You can now use the Playwright backend with Gemini models")


if __name__ == "__main__":
    asyncio.run(main())
