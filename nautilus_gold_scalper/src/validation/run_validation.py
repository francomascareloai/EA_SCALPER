#!/usr/bin/env python3
"""
Data Validation Pipeline Runner.

Execute the full DuckDB/Polars-based validation pipeline on XAUUSD catalog data.

Usage:
    python -m src.validation.run_validation

    # Or with custom catalog path:
    python -m src.validation.run_validation --catalog /path/to/catalog

The pipeline validates:
    - Phase 1-A: Deep data validation (CSV → Parquet quality)
    - Phase 2: Main catalog validation (schema, temporal, price, gaps, regime)
    - Phase 3: Session catalog validation (6 sessions, DST handling)
    - Phase 4: Integrity & cleanup (cross-catalog consistency)
    - Phase 5: Advanced validation (GJR-GARCH, stylized facts, look-ahead)

Uses DuckDB for 10-50x faster Parquet queries compared to NautilusTrader.
Memory-safe for 12GB systems (6GB for validation, 6GB for OS).
"""

from __future__ import annotations

import argparse
import logging
import sys
from datetime import datetime
from pathlib import Path

from src.validation.core.config import (
    MemoryConfig,
    ValidationConfig,
)
from src.validation.core.engine import DuckDBConnection
from src.validation.core.results import PipelineResult, ValidationStatus
from src.validation.phases import (
    Phase1AValidator,
    Phase2Validator,
    Phase3Validator,
    Phase4Validator,
    Phase5Validator,
)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger(__name__)


def run_validation_pipeline(
    catalog_path: str,
    phases: list[int] | None = None,
    memory_limit_gb: float = 6.0,
) -> PipelineResult:
    """Execute the validation pipeline.

    Args:
        catalog_path: Path to NautilusTrader catalog directory.
        phases: List of phase numbers to run (1-5). If None, run all.
        memory_limit_gb: DuckDB memory limit in GB.

    Returns:
        PipelineResult with all phase results and GO/NO-GO decision.
    """
    logger.info("=" * 60)
    logger.info("XAUUSD Data Validation Pipeline")
    logger.info("=" * 60)
    logger.info(f"Catalog: {catalog_path}")
    logger.info(f"Memory limit: {memory_limit_gb}GB")
    logger.info("")

    # Create configuration with memory settings
    memory_config = MemoryConfig(max_memory_gb=memory_limit_gb)
    config = ValidationConfig(catalog_path=catalog_path, memory=memory_config)

    # Create DuckDB connection
    db = DuckDBConnection(memory_limit_gb=memory_limit_gb)

    # Create pipeline result
    pipeline = PipelineResult()
    pipeline.pipeline_start = datetime.now()

    # Define all validators
    all_validators = {
        1: ("Phase 1-A: Deep Data Validation", Phase1AValidator),
        2: ("Phase 2: Main Catalog Validation", Phase2Validator),
        3: ("Phase 3: Session Catalog Validation", Phase3Validator),
        4: ("Phase 4: Integrity & Cleanup", Phase4Validator),
        5: ("Phase 5: Advanced Validation", Phase5Validator),
    }

    # Filter phases if specified
    if phases is None:
        phases = [1, 2, 3, 4, 5]

    # Run each phase
    for phase_num in phases:
        if phase_num not in all_validators:
            logger.warning(f"Unknown phase number: {phase_num}")
            continue

        phase_name, validator_class = all_validators[phase_num]
        logger.info("-" * 50)
        logger.info(f"Running {phase_name}...")
        logger.info("-" * 50)

        try:
            validator = validator_class(config, db)
            result = validator.validate()
            pipeline.add_phase(result)

            # Log phase summary
            status_emoji = {
                ValidationStatus.PASS: "✅",
                ValidationStatus.WARNING: "⚠️",
                ValidationStatus.FAIL: "❌",
                ValidationStatus.CRITICAL: "🚨",
                ValidationStatus.SKIPPED: "⏭️",
            }
            emoji = status_emoji.get(result.status, "❓")
            logger.info(f"{emoji} {phase_name}: {result.status.name}")
            logger.info(f"   Checks: {result.passed_checks} passed, {result.failed_checks} failed")
            if result.duration_seconds:
                logger.info(f"   Duration: {result.duration_seconds:.2f}s")

            # Print individual check results
            for check in result.checks:
                check_emoji = status_emoji.get(check.status, "❓")
                logger.info(f"     {check_emoji} {check.name}: {check.message}")

        except Exception as e:
            logger.exception(f"Phase {phase_num} failed with error")
            logger.error(f"Error: {e}")

    pipeline.pipeline_end = datetime.now()

    # Final summary
    logger.info("=" * 60)
    logger.info("VALIDATION SUMMARY")
    logger.info("=" * 60)
    logger.info(f"Total Phases: {len(pipeline.phases)}")
    logger.info(f"Total Checks: {pipeline.total_checks}")
    logger.info(f"Passed: {pipeline.total_passed}")
    logger.info(f"Failed: {pipeline.total_failed}")
    logger.info(f"Warnings: {pipeline.total_warnings}")
    logger.info(f"Duration: {pipeline.total_duration_seconds:.2f}s")
    logger.info("")

    # GO/NO-GO Decision
    decision = pipeline.go_nogo_decision
    decision_emoji = {
        "GO": "✅",
        "GO-CONDITIONAL": "⚠️",
        "NO-GO": "❌",
        "INCOMPLETE": "⏭️",
    }
    emoji = decision_emoji.get(decision, "❓")
    logger.info(f"{emoji} DECISION: {decision}")
    logger.info("=" * 60)

    return pipeline


def main() -> int:
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Run XAUUSD data validation pipeline",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "--catalog",
        type=str,
        default="data/catalog_native/xauusd_2003_2025_stride1_COMPLETE",
        help="Path to NautilusTrader catalog directory",
    )
    parser.add_argument(
        "--phases",
        type=str,
        default=None,
        help="Comma-separated list of phases to run (e.g., '1,2,5'). Default: all",
    )
    parser.add_argument(
        "--memory",
        type=float,
        default=6.0,
        help="DuckDB memory limit in GB (default: 6.0)",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Enable verbose output",
    )

    args = parser.parse_args()

    if args.verbose:
        logging.getLogger().setLevel(logging.DEBUG)

    # Parse phases
    phases = None
    if args.phases:
        phases = [int(p.strip()) for p in args.phases.split(",")]

    # Check catalog exists
    catalog_path = Path(args.catalog)
    if not catalog_path.exists():
        logger.error(f"Catalog path does not exist: {catalog_path}")
        return 1

    # Run pipeline
    result = run_validation_pipeline(
        catalog_path=str(catalog_path),
        phases=phases,
        memory_limit_gb=args.memory,
    )

    # Return code based on decision
    if result.go_nogo_decision == "GO":
        return 0
    elif result.go_nogo_decision == "GO-CONDITIONAL":
        return 0  # Warnings are acceptable
    else:
        return 1  # NO-GO or INCOMPLETE


if __name__ == "__main__":
    sys.exit(main())
