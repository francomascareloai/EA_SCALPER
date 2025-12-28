#!/usr/bin/env python3
"""Parallel Deep Research with multiple Chrome profiles.

Architecture for running N simultaneous Deep Research queries.

Each research session uses a separate Chrome profile to avoid conflicts.
"""

import asyncio
import logging
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

from deep_reasoning_mcp.backends.undetected_chatgpt import (
    ChatGPTUndetectedBackend,
    ChatGPTUndetectedConfig,
)
from deep_reasoning_mcp.models import ModelResult, ReasoningModel, TaskStatus

logging.basicConfig(level=logging.INFO, format="%(levelname)s:%(name)s:%(message)s")
logger = logging.getLogger(__name__)


@dataclass
class ResearchJob:
    """A research job to execute."""

    job_id: str
    query: str
    profile_name: str
    system_hints: Optional[list[str]] = None


class ParallelResearchManager:
    """
    Manages parallel Deep Research sessions using multiple Chrome profiles.

    Each profile maintains its own ChatGPT session, allowing true parallelism.

    Usage:
        manager = ParallelResearchManager(max_workers=3)
        await manager.initialize_profiles()

        results = await manager.run_parallel([
            ResearchJob("job1", "Query 1...", "profile-1"),
            ResearchJob("job2", "Query 2...", "profile-2"),
            ResearchJob("job3", "Query 3...", "profile-3"),
        ])
    """

    def __init__(
        self,
        max_workers: int = 3,
        base_profile_dir: Optional[Path] = None,
        headless: bool = False,
        timeout_seconds: int = 1800,
    ):
        self.max_workers = max_workers
        self.base_profile_dir = (
            base_profile_dir or Path.home() / ".deep-reasoning" / "profiles"
        )
        self.headless = headless
        self.timeout_seconds = timeout_seconds
        self._executor = ThreadPoolExecutor(max_workers=max_workers)
        self._backends: dict[str, ChatGPTUndetectedBackend] = {}

    def _get_profile_path(self, profile_name: str) -> Path:
        """Get the path for a named profile."""
        return self.base_profile_dir / profile_name

    def _create_backend(self, profile_name: str) -> ChatGPTUndetectedBackend:
        """Create a backend for a specific profile."""
        profile_path = self._get_profile_path(profile_name)
        config = ChatGPTUndetectedConfig(
            headless=self.headless,
            user_data_dir=profile_path,
            profile_directory="Default",
            timeout_seconds=self.timeout_seconds,
        )
        return ChatGPTUndetectedBackend(config)

    def initialize_profiles(self, profile_names: list[str]) -> None:
        """Initialize Chrome profiles for parallel use.

        IMPORTANT: You need to log into ChatGPT manually for each profile
        the first time. Run this with headless=False to do the initial login.
        """
        for name in profile_names:
            if name not in self._backends:
                logger.info(f"Initializing profile: {name}")
                backend = self._create_backend(name)
                backend.initialize()
                self._backends[name] = backend
                logger.info(f"Profile {name} ready")

    def _execute_job(self, job: ResearchJob) -> ModelResult:
        """Execute a single research job (runs in thread)."""
        logger.info(f"[{job.job_id}] Starting research on profile {job.profile_name}")

        backend = self._backends.get(job.profile_name)
        if not backend:
            return ModelResult(
                model=ReasoningModel.GPT_5_PRO,
                status=TaskStatus.FAILED,
                error=f"Profile {job.profile_name} not initialized",
            )

        try:
            result = backend.query(
                model=ReasoningModel.GPT_5_PRO,
                question=job.query,
                system_hints=job.system_hints,
            )

            # Handle clarifications automatically (basic response)
            clarification_count = 0
            while (
                result.status == TaskStatus.NEEDS_CLARIFICATION
                and clarification_count < 3
            ):
                clarification_count += 1
                logger.info(
                    f"[{job.job_id}] Handling clarification {clarification_count}"
                )

                response = """Please proceed with a comprehensive analysis covering:
1. All relevant technical aspects
2. Quantitative data and metrics
3. Practical examples and case studies
4. Recent developments (2024)

Provide structured output with clear sections."""

                result = backend.continue_conversation(
                    conversation_id=result.conversation_id,
                    response=response,
                )

            logger.info(f"[{job.job_id}] Completed with status: {result.status}")
            return result

        except Exception as e:
            logger.error(f"[{job.job_id}] Error: {e}")
            return ModelResult(
                model=ReasoningModel.GPT_5_PRO,
                status=TaskStatus.FAILED,
                error=str(e),
            )

    async def run_parallel(self, jobs: list[ResearchJob]) -> dict[str, ModelResult]:
        """Run multiple research jobs in parallel.

        Each job runs on its designated profile. Jobs with the same profile
        will be queued sequentially on that profile.
        """
        # Group jobs by profile
        profile_jobs: dict[str, list[ResearchJob]] = {}
        for job in jobs:
            if job.profile_name not in profile_jobs:
                profile_jobs[job.profile_name] = []
            profile_jobs[job.profile_name].append(job)

        # Execute jobs - parallel across profiles, sequential within each profile
        results: dict[str, ModelResult] = {}
        loop = asyncio.get_event_loop()

        async def run_profile_jobs(profile: str, profile_job_list: list[ResearchJob]):
            for job in profile_job_list:
                result = await loop.run_in_executor(
                    self._executor,
                    self._execute_job,
                    job,
                )
                results[job.job_id] = result

        # Run all profiles in parallel
        await asyncio.gather(
            *[
                run_profile_jobs(profile, jobs_list)
                for profile, jobs_list in profile_jobs.items()
            ]
        )

        return results

    def close_all(self) -> None:
        """Close all backends."""
        for name, backend in self._backends.items():
            try:
                backend.close()
                logger.info(f"Closed profile: {name}")
            except Exception as e:
                logger.warning(f"Error closing {name}: {e}")
        self._backends.clear()
        self._executor.shutdown(wait=True)


async def demo_parallel_research():
    """Demo: Run 3 research queries in parallel."""
    print("=" * 70)
    print("Parallel Deep Research Demo")
    print("=" * 70)
    print()
    print("This will run 3 research queries simultaneously using 3 Chrome profiles.")
    print()
    print("IMPORTANT: Each profile needs to be logged into ChatGPT first!")
    print("Run this script with headless=False to do initial login.")
    print()

    manager = ParallelResearchManager(
        max_workers=3,
        headless=False,  # Set to True after initial login
        timeout_seconds=1800,
    )

    # Define profiles
    profiles = ["research-1", "research-2", "research-3"]

    try:
        # Initialize profiles
        print("Initializing profiles (this opens 3 Chrome windows)...")
        manager.initialize_profiles(profiles)
        print("All profiles ready!")
        print()

        # Wait for user to log in if needed
        input("Press Enter after logging into ChatGPT in all windows...")

        # Define research jobs
        jobs = [
            ResearchJob(
                job_id="quantum",
                query="What are the latest breakthroughs in quantum computing in 2024?",
                profile_name="research-1",
                system_hints=["research"],
            ),
            ResearchJob(
                job_id="ai",
                query="How has AI safety research evolved in 2024? What are the key concerns?",
                profile_name="research-2",
                system_hints=["research"],
            ),
            ResearchJob(
                job_id="crypto",
                query="Analyze the state of cryptocurrency regulation globally in 2024.",
                profile_name="research-3",
                system_hints=["research"],
            ),
        ]

        print(f"Starting {len(jobs)} parallel research jobs...")
        print()

        # Run in parallel
        results = await manager.run_parallel(jobs)

        # Print results
        print("\n" + "=" * 70)
        print("RESULTS")
        print("=" * 70)

        for job_id, result in results.items():
            print(f"\n[{job_id}]")
            print(f"  Status: {result.status}")
            print(
                f"  Duration: {result.duration_seconds:.1f}s"
                if result.duration_seconds
                else ""
            )
            if result.response:
                print(f"  Response: {len(result.response)} chars")
                print(f"  Preview: {result.response[:200]}...")
            elif result.error:
                print(f"  Error: {result.error}")

    finally:
        print("\nClosing all browsers...")
        manager.close_all()


if __name__ == "__main__":
    asyncio.run(demo_parallel_research())
