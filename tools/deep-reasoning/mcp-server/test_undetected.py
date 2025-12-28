#!/usr/bin/env python3
"""Test the undetected Chrome backend."""

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
    print("Initializing undetected Chrome backend...")

    config = ChatGPTUndetectedConfig(
        headless=False,
        timeout_seconds=120,
    )

    backend = ChatGPTUndetectedBackend(config)
    backend.initialize()

    try:
        print("Testing simple query...")
        result = backend.query(
            model=ReasoningModel.GPT_5_PRO,
            question="What is 2+2?",
        )

        print(f"\nStatus: {result.status}")
        print(f"Duration: {result.duration_seconds:.1f}s")

        if result.response:
            print(f"Response: {result.response[:200]}")
        else:
            print(f"Error: {result.error}")

    finally:
        backend.close()


if __name__ == "__main__":
    main()
