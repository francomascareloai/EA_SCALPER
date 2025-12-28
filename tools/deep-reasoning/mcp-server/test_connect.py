#!/usr/bin/env python3
"""Test connecting to existing Chrome for ChatGPT automation."""

import asyncio
import logging
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from deep_reasoning_mcp.backends.connect_chatgpt import (
    ChatGPTConnectBackend,
    ChatGPTConnectConfig,
    create_start_scripts,
)
from deep_reasoning_mcp.models import ReasoningModel

logging.basicConfig(level=logging.INFO, format="%(levelname)s:%(name)s:%(message)s")


async def main():
    # Create helper scripts
    script_dir = Path(__file__).parent
    create_start_scripts(script_dir)
    print(f"Created start_chrome_debug.bat in {script_dir}")
    print()

    print("=" * 50)
    print("SETUP INSTRUCTIONS:")
    print("=" * 50)
    print("1. Close ALL Chrome windows")
    print("2. Run: start_chrome_debug.bat (in Windows)")
    print("3. Log into ChatGPT in that Chrome window")
    print("4. Press Enter here to continue...")
    print("=" * 50)
    input()

    print("Connecting to Chrome...")

    config = ChatGPTConnectConfig(
        cdp_url="http://localhost:9222",
        timeout_seconds=120,
    )

    backend = ChatGPTConnectBackend(config)

    try:
        await backend.initialize()
        print("Connected!")

        print("\nTesting simple query...")
        result = await backend.query(
            model=ReasoningModel.GPT_5_PRO,
            question="What is 2+2?",
        )

        print(f"\nStatus: {result.status}")
        print(f"Duration: {result.duration_seconds:.1f}s")

        if result.response:
            print(f"Response: {result.response[:500]}")
        else:
            print(f"Error: {result.error}")

    except Exception as e:
        print(f"Error: {e}")
        print("\nMake sure Chrome is running with --remote-debugging-port=9222")

    finally:
        await backend.close()


if __name__ == "__main__":
    asyncio.run(main())
