#!/usr/bin/env python3
"""Test undetected-chromedriver with Deep Research mode."""

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
    print("=" * 60)
    print("Testing Deep Research with undetected-chromedriver")
    print("=" * 60)
    print()

    config = ChatGPTUndetectedConfig(
        headless=False,
        user_data_dir=Path.home() / ".deep-reasoning" / "chrome-profile-linux",
        profile_directory="Default",  # Avoid profile picker
        timeout_seconds=1800,  # 30 min for Deep Research
    )

    backend = ChatGPTUndetectedBackend(config)

    try:
        print("Initializing browser...")
        backend.initialize()
        print("Browser started!")
        print()

        # Test with Deep Research enabled
        print("Testing with Deep Research mode...")
        print("This will take 10-20 minutes for full research.")
        print()

        result = backend.query(
            model=ReasoningModel.GPT_5_PRO,
            question="What are the latest developments in quantum computing in 2024? Provide a brief summary.",
            system_hints=["research"],  # This triggers Deep Research mode
        )

        print(f"\nStatus: {result.status}")
        print(f"Duration: {result.duration_seconds:.1f}s")

        if result.response:
            print(f"\nResponse length: {len(result.response)} chars")
            print("\nFirst 2000 chars:")
            print("-" * 40)
            print(result.response[:2000])
            print("-" * 40)
        else:
            print(f"Error: {result.error}")

    except Exception as e:
        print(f"Error: {e}")
        import traceback

        traceback.print_exc()

    finally:
        print("\nKeeping browser open for 30 seconds for inspection...")
        import time

        time.sleep(30)
        backend.close()


if __name__ == "__main__":
    main()
