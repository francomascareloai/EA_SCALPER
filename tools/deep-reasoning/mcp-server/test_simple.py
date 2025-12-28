#!/usr/bin/env python3
"""Simple test - send message without research mode."""

import asyncio
import logging
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from deep_reasoning_mcp.backends.playwright_chatgpt import (
    ChatGPTPlaywrightBackend,
    ChatGPTPlaywrightConfig,
)
from deep_reasoning_mcp.models import ReasoningModel

logging.basicConfig(level=logging.INFO, format="%(levelname)s:%(name)s:%(message)s")


async def main():
    print("Initializing backend...")

    config = ChatGPTPlaywrightConfig(
        headless=False,
        timeout_seconds=120,
    )

    backend = ChatGPTPlaywrightBackend(config)
    await backend.initialize()

    try:
        print("Testing simple query WITHOUT research mode...")
        result = await backend.query(
            model=ReasoningModel.GPT_5_PRO,
            question="What is 2+2?",
            # NO hints = no research mode
        )

        print(f"\nStatus: {result.status}")
        print(f"Duration: {result.duration_seconds:.1f}s")

        if result.response:
            print(f"Response: {result.response[:200]}")
        else:
            print(f"Error: {result.error}")

    finally:
        await backend.close()


if __name__ == "__main__":
    asyncio.run(main())
