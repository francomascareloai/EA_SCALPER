#!/usr/bin/env python3
"""Test Deep Research with complex multi-faceted query.

This tests a more realistic research scenario with detailed requirements.
"""

import logging
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from deep_reasoning_mcp.backends.undetected_chatgpt import (
    ChatGPTUndetectedBackend,
    ChatGPTUndetectedConfig,
)
from deep_reasoning_mcp.models import ReasoningModel, TaskStatus

logging.basicConfig(level=logging.INFO, format="%(levelname)s:%(name)s:%(message)s")


def generate_clarification_response(
    clarification_question: str, original_context: str
) -> str:
    """Generate detailed response to GPT's clarification question.

    In production, this would be handled by a Claude subagent with full context.
    """
    # Analyze what GPT is asking for
    q_lower = clarification_question.lower()

    response_parts = [
        "Based on my research requirements, here are the specific details:\n"
    ]

    # Detect what aspects GPT is asking about and respond accordingly
    if "time" in q_lower or "period" in q_lower or "recent" in q_lower:
        response_parts.append(
            "**Time Period:** Focus on developments from 2024 (last 12 months).\n"
        )

    if "company" in q_lower or "companies" in q_lower or "which" in q_lower:
        response_parts.append(
            "**Companies of Interest:** Major players (IBM, Google, Microsoft, IonQ, Rigetti) and notable startups.\n"
        )

    if "technical" in q_lower or "hardware" in q_lower or "software" in q_lower:
        response_parts.append(
            "**Technical Focus:** Both hardware (qubit count, error correction, coherence) and software (algorithms, quantum advantage demonstrations).\n"
        )

    if "application" in q_lower or "use case" in q_lower or "practical" in q_lower:
        response_parts.append(
            "**Applications:** Real-world deployments in finance, drug discovery, optimization, cryptography.\n"
        )

    if "region" in q_lower or "country" in q_lower or "geographic" in q_lower:
        response_parts.append(
            "**Geographic Scope:** Global, with emphasis on US, EU, and China initiatives.\n"
        )

    # Always add comprehensive scope
    response_parts.append("""
**Research Depth:** Comprehensive report with:
1. Executive summary (key takeaways)
2. Technical breakthroughs with metrics
3. Commercial landscape and funding
4. Real-world applications and case studies
5. Future outlook and challenges

**Output Format:** Structured markdown with headers, bullet points, and data tables where relevant.

Please provide a thorough analysis covering these aspects.""")

    return "\n".join(response_parts)


def main():
    print("=" * 70)
    print("Testing Deep Research with Complex Query")
    print("=" * 70)
    print()

    # Complex, multi-faceted research query
    complex_query = """Analyze the current state of algorithmic trading in cryptocurrency markets:

1. **Market Microstructure**: How do order book dynamics and liquidity patterns differ across major exchanges (Binance, Coinbase, Kraken)?

2. **Strategy Performance**: Which algorithmic trading strategies have shown robust performance in 2024 despite increased volatility? Include statistical evidence.

3. **Regulatory Impact**: How have recent regulations (MiCA in EU, SEC actions in US) affected algorithmic trading operations?

4. **Technology Stack**: What are the most effective technology choices for low-latency crypto trading systems?

5. **Risk Management**: Best practices for managing tail risk and black swan events in 24/7 crypto markets.

Provide quantitative data, specific examples, and actionable insights for a professional trading firm."""

    print(f"Query length: {len(complex_query)} chars")
    print()
    print("Query preview:")
    print("-" * 40)
    print(complex_query[:500] + "...")
    print("-" * 40)
    print()

    config = ChatGPTUndetectedConfig(
        headless=False,
        user_data_dir=Path.home() / ".deep-reasoning" / "chrome-profile-linux",
        profile_directory="Default",
        timeout_seconds=1800,  # 30 min for Deep Research
        max_clarifications=3,
    )

    backend = ChatGPTUndetectedBackend(config)
    max_clarifications = 3

    try:
        print("Initializing browser...")
        backend.initialize()
        print("Browser started!")
        print()

        print("Sending complex research query with Deep Research mode...")
        print()

        result = backend.query(
            model=ReasoningModel.GPT_5_PRO,
            question=complex_query,
            system_hints=["research"],  # Enable Deep Research
        )

        clarification_count = 0

        while result.status == TaskStatus.NEEDS_CLARIFICATION:
            clarification_count += 1

            if clarification_count > max_clarifications:
                print(f"\nMax clarifications reached ({max_clarifications}), stopping")
                break

            print(f"\n{'=' * 60}")
            print(f"[Clarification {clarification_count}/{max_clarifications}]")
            print(f"{'=' * 60}")
            print("\nGPT asks:")
            print("-" * 40)
            print(result.clarification_question)
            print("-" * 40)

            # Generate contextual response
            response = generate_clarification_response(
                result.clarification_question,
                complex_query,
            )

            print("\nOur response:")
            print("-" * 40)
            print(response[:600] + "..." if len(response) > 600 else response)
            print("-" * 40)

            # Continue conversation
            result = backend.continue_conversation(
                conversation_id=result.conversation_id,
                response=response,
            )

        # Final results
        print("\n" + "=" * 70)
        print("FINAL RESULTS")
        print("=" * 70)
        print(f"Status: {result.status}")
        print(f"Total Duration: {result.duration_seconds:.1f}s")
        print(f"Clarifications handled: {clarification_count}")
        print()

        if result.response:
            print(f"Response length: {len(result.response)} chars")
            print()
            print("First 5000 chars of response:")
            print("-" * 40)
            print(result.response[:5000])
            if len(result.response) > 5000:
                print(f"\n... [{len(result.response) - 5000} more chars]")
            print("-" * 40)

            # Save full response
            output_file = (
                Path.home()
                / ".deep-reasoning"
                / "responses"
                / "complex_research_output.md"
            )
            output_file.parent.mkdir(parents=True, exist_ok=True)
            output_file.write_text(result.response)
            print(f"\nFull response saved to: {output_file}")
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
