#!/usr/bin/env python3
"""Open ChatGPT in browser for 2 minutes, then save session."""

import asyncio
import sys
from pathlib import Path

from playwright.async_api import async_playwright


async def main():
    wait_seconds = int(sys.argv[1]) if len(sys.argv) > 1 else 120

    session_dir = Path.home() / ".deep-reasoning" / "chatgpt-session"
    session_dir.mkdir(parents=True, exist_ok=True)

    print(f"Session will be saved to: {session_dir}", flush=True)
    print("Opening browser...", flush=True)

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

    print("Navigating to ChatGPT...", flush=True)
    await page.goto("https://chatgpt.com", wait_until="domcontentloaded", timeout=60000)

    print(f"Browser will stay open for {wait_seconds} seconds.", flush=True)
    print(
        "Log in to ChatGPT if needed. Session saves automatically when browser closes.",
        flush=True,
    )

    # Wait specified time
    await asyncio.sleep(wait_seconds)

    # Check cookies before closing
    cookies = await context.cookies()
    has_session = any(
        c.get("name", "").startswith("__Secure")
        or "session" in c.get("name", "").lower()
        for c in cookies
    )

    if has_session:
        print("✓ Session cookies detected!", flush=True)
    else:
        print("⚠ No session cookies found - you may not be logged in", flush=True)

    print("Saving session...", flush=True)
    await context.close()
    await pw.stop()
    print(f"✓ Session saved to: {session_dir}", flush=True)


if __name__ == "__main__":
    asyncio.run(main())
