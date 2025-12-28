#!/usr/bin/env python3
"""Test ChatGPT Playwright backend with 3 concurrent pages.

This validates the low-RAM multi-page approach:
- One persistent browser context (single session/login)
- Up to 3 concurrent queries (each uses its own page)

NOTE: Deep Research can take 10-20 minutes and may first emit a short
placeholder reply ("I'll prepare...") before producing the full report.
"""

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
logger = logging.getLogger(__name__)


async def main():
    config = ChatGPTPlaywrightConfig(
        headless=False,
        timeout_seconds=1800,
        max_concurrent_pages=3,
    )

    backend = ChatGPTPlaywrightBackend(config)
    await backend.initialize()

    try:
        queries = [
            (
                "q1",
                "What are the most important breakthroughs in quantum computing in 2024? Provide sources and key metrics.",
            ),
            (
                "q2",
                "Summarize the latest developments in EU MiCA regulation in 2024 and practical compliance implications for a crypto trading firm.",
            ),
            (
                "q3",
                "Compare market microstructure and liquidity patterns across Binance, Coinbase, and Kraken in 2024. Focus on order book depth, spread dynamics, and maker/taker behavior.",
            ),
        ]

        async def run_one(job_id: str, question: str):
            logger.info(f"[{job_id}] submitting")
            result = await backend.query(
                model=ReasoningModel.GPT_5_PRO,
                question=question,
                system_hints=["research"],
            )
            logger.info(
                f"[{job_id}] done status={result.status} chars={len(result.response or '')} err={result.error}"
            )
            return job_id, result

        results = await asyncio.gather(*[run_one(jid, q) for (jid, q) in queries])

        out_dir = Path.home() / ".deep-reasoning" / "responses" / "parallel_3"
        out_dir.mkdir(parents=True, exist_ok=True)

        print("\n" + "=" * 70)
        print("RESULTS")
        print("=" * 70)

        for job_id, res in results:
            print(
                f"\n[{job_id}] status={res.status} duration={res.duration_seconds:.1f}s"
            )
            if res.response:
                print(f"  response_len={len(res.response)}")
                print(f"  preview={res.response[:300].replace('\n', ' ')}...")
                (out_dir / f"{job_id}.md").write_text(res.response)
            else:
                print(f"  error={res.error}")

        print(f"\nSaved outputs to: {out_dir}")

    finally:
        await backend.close()


if __name__ == "__main__":
    asyncio.run(main())
