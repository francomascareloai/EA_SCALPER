#!/usr/bin/env python3
"""Test undetected-chromedriver with Linux Chrome for ChatGPT."""

import logging
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from deep_reasoning_mcp.backends.undetected_chatgpt import (
    ChatGPTUndetectedBackend,
    ChatGPTUndetectedConfig,
)
from deep_reasoning_mcp.models import ReasoningModel

logging.basicConfig(level=logging.INFO, format="%(levelname)s:%(name)s:%(message)s")


def main():
    print("=" * 50)
    print("Testing undetected-chromedriver with Linux Chrome")
    print("=" * 50)
    print()
    print("This will open a Chrome window.")
    print("You may need to log into ChatGPT manually the first time.")
    print()

    # Use Linux Chrome (default) with persistent profile
    config = ChatGPTUndetectedConfig(
        headless=False,  # Show browser for debugging
        user_data_dir=Path.home() / ".deep-reasoning" / "chrome-profile-linux",
        profile_directory="Default",  # Avoid profile picker
        timeout_seconds=120,
    )

    backend = ChatGPTUndetectedBackend(config)

    try:
        print("Initializing browser...")
        backend.initialize()
        print("Browser started!")
        print()

        print("Testing simple query (without Deep Research)...")
        result = backend.query(
            model=ReasoningModel.GPT_5_PRO,
            question="What is 2+2? Answer briefly.",
        )

        print(f"\nStatus: {result.status}")
        print(f"Duration: {result.duration_seconds:.1f}s")

        if result.response:
            print(f"Response: {result.response[:500]}")
        else:
            print(f"Error: {result.error}")

    except Exception as e:
        print(f"Error: {e}")
        import traceback

        traceback.print_exc()

    finally:
        print("\nKeeping browser open for 10 seconds for inspection...")
        import time

        time.sleep(10)
        backend.close()


if __name__ == "__main__":
    main()
