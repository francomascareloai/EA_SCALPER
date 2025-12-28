#!/usr/bin/env python3
"""Test interactive Deep Research with clarification handling.

This demonstrates the flow where:
1. Initial query → ChatGPT Deep Research
2. GPT asks clarifying question → NEEDS_CLARIFICATION status
3. We (or Claude subagent) respond → continue_conversation()
4. Repeat until COMPLETED
"""

import logging
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))

from deep_reasoning_mcp.backends.undetected_chatgpt import (
    ChatGPTUndetectedBackend,
    ChatGPTUndetectedConfig,
    is_clarification_question,
)
from deep_reasoning_mcp.models import ReasoningModel, TaskStatus

logging.basicConfig(level=logging.INFO, format="%(levelname)s:%(name)s:%(message)s")


def test_clarification_detection():
    """Test the clarification detection heuristics."""
    print("=" * 60)
    print("Testing clarification detection heuristics (weighted scoring)")
    print("=" * 60)

    test_cases = [
        # Should be detected as clarification
        (
            "Could you please clarify which aspects of quantum computing you're most interested in?",
            True,
        ),
        (
            "What specifically would you like me to focus on?",
            True,
        ),
        (
            "Before I begin my research, I'd like to know: are you interested in hardware or software developments?",
            True,
        ),
        (
            "Which areas are most relevant to your needs?",
            True,
        ),
        # Hybrid - starts helpful but ends with question
        (
            "I can help with that! However, could you first tell me what level of detail you need?",
            True,
        ),
        # Multi-lingual
        (
            "Poderia esclarecer qual aspecto você gostaria que eu focasse?",
            True,
        ),
        # Should NOT be detected as clarification (actual answers)
        (
            "Here is a comprehensive overview of quantum computing developments in 2024...",
            False,
        ),
        (
            "## Latest Quantum Computing Developments\n\n1. IBM achieved 1000+ qubits...",
            False,
        ),
        (
            "Based on my research, here are the key developments: " + "x" * 2000,
            False,
        ),
        # Answer with data
        (
            "The quantum computing market grew 67% in 2024. Key metrics: 23 companies launched products.",
            False,
        ),
    ]

    passed = 0
    for text, expected in test_cases:
        result, confidence = is_clarification_question(text)
        status = "✓" if result == expected else "✗"
        print(
            f"{status} Expected {expected}, got {result} (conf: {confidence:.2f}): {text[:50]}..."
        )
        if result == expected:
            passed += 1

    print(f"\nPassed: {passed}/{len(test_cases)}")
    return passed == len(test_cases)


def generate_clarification_response(
    original_question: str,
    clarification_question: str,
    context: str = "",
) -> str:
    """
    Generate a response to GPT's clarification question.

    In production, this would be done by a Claude subagent with full context.
    For testing, we use a simple rule-based approach.
    """
    # This is a placeholder - in production, Claude subagent would handle this
    # with full context from the original request

    print("\n" + "=" * 60)
    print("GPT asked for clarification:")
    print("-" * 60)
    print(clarification_question)
    print("-" * 60)

    # For testing, provide a comprehensive response
    response = f"""Based on my research needs, please focus on:

1. **Technical breakthroughs**: Any new quantum computing achievements in terms of qubit count, error correction, or coherence times.

2. **Commercial developments**: Companies that have launched quantum computing services or achieved significant funding.

3. **Practical applications**: Real-world use cases where quantum computing is being applied successfully.

4. **Timeline**: Recent developments from the past 12 months (2024).

The original question context was: {original_question}

Please provide a comprehensive research report covering these areas."""

    return response


def main():
    # First test the heuristics
    print()
    if not test_clarification_detection():
        print("\nWarning: Some heuristics failed, but continuing with main test...")
    print()

    print("=" * 60)
    print("Testing Interactive Deep Research")
    print("=" * 60)
    print()
    print("This test will:")
    print("1. Start a Deep Research query")
    print("2. If GPT asks for clarification, automatically respond")
    print("3. Continue until final answer is received")
    print()

    config = ChatGPTUndetectedConfig(
        headless=False,
        user_data_dir=Path.home() / ".deep-reasoning" / "chrome-profile-linux",
        profile_directory="Default",  # Avoid profile picker
        timeout_seconds=1800,  # 30 min for Deep Research
    )

    backend = ChatGPTUndetectedBackend(config)
    max_clarifications = 3  # Prevent infinite loops

    try:
        print("Initializing browser...")
        backend.initialize()
        print("Browser started!")
        print()

        # Initial query - intentionally vague to trigger clarification
        question = "What are the latest developments in quantum computing?"

        print(f"Sending initial query: {question}")
        print("This may trigger a clarification question from GPT...")
        print()

        result = backend.query(
            model=ReasoningModel.GPT_5_PRO,
            question=question,
            system_hints=["research"],  # Enable Deep Research
        )

        clarification_count = 0

        while result.status == TaskStatus.NEEDS_CLARIFICATION:
            clarification_count += 1

            if clarification_count > max_clarifications:
                print(f"Too many clarifications ({clarification_count}), stopping")
                break

            print(f"\n[Clarification {clarification_count}/{max_clarifications}]")

            # Generate response to clarification
            response = generate_clarification_response(
                original_question=question,
                clarification_question=result.clarification_question,
            )

            print("\nSending clarification response...")
            print("-" * 40)
            print(response[:500] + "..." if len(response) > 500 else response)
            print("-" * 40)

            # Continue the conversation
            result = backend.continue_conversation(
                conversation_id=result.conversation_id,
                response=response,
            )

        # Final result
        print("\n" + "=" * 60)
        print(f"Final Status: {result.status}")
        print(f"Total Duration: {result.duration_seconds:.1f}s")
        print(f"Clarifications handled: {clarification_count}")
        print("=" * 60)

        if result.response:
            print(f"\nResponse length: {len(result.response)} chars")
            print("\nFirst 3000 chars:")
            print("-" * 40)
            print(result.response[:3000])
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
