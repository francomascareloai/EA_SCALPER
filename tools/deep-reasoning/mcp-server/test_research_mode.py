#!/usr/bin/env python3
"""Test ChatGPT Playwright backend with Search/Research mode."""

import asyncio
import logging
import sys
from pathlib import Path

# Add to path
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
        headless=False,  # Non-headless required due to Cloudflare
        timeout_seconds=600,  # 10 min for research
    )

    backend = ChatGPTPlaywrightBackend(config)
    await backend.initialize()

    try:
        print("Testing with Search/Research mode enabled...")
        result = await backend.query(
            model=ReasoningModel.GPT_5_PRO,
            question="What are the latest developments in quantum computing in December 2025?",
            system_hints=["research"],  # This triggers research mode
        )

        print(f"\nStatus: {result.status}")
        print(f"Duration: {result.duration_seconds:.1f}s")

        if result.response:
            print(f"Response length: {len(result.response)} chars")
            print(f"Response preview: {result.response[:500]}...")
        else:
            print(f"Error: {result.error}")

    finally:
        await backend.close()


if __name__ == "__main__":
    asyncio.run(main())
