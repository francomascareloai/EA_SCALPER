"""
CLI entry point for Apex Optimizer.

Usage:
    python -m src.optimization --config configs/grids/smc_optimization.yaml
    python -m src.optimization --config configs/grids/smc_optimization.yaml --trials 50 --dry-run
"""

from __future__ import annotations

import argparse
import logging
import sys
from pathlib import Path

# Add project root to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent.parent.parent))

from src.optimization.config import OptimizationConfig


def setup_logging(level: str = "INFO") -> None:
    """Configure logging for optimization runs."""
    logging.basicConfig(
        level=getattr(logging, level.upper()),
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )


def parse_args() -> argparse.Namespace:
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Apex Optimizer - Parameter optimization for Apex-compliant trading strategies",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Run Bayesian optimization with 100 trials
  python -m src.optimization --config configs/grids/smc.yaml --trials 100

  # Dry run to see grid size
  python -m src.optimization --config configs/grids/smc.yaml --dry-run

  # Run with custom output directory
  python -m src.optimization --config configs/grids/smc.yaml --output logs/my_run
""",
    )

    parser.add_argument(
        "--config",
        type=str,
        required=True,
        help="Path to YAML optimization config file",
    )

    parser.add_argument(
        "--mode",
        type=str,
        choices=["grid", "random", "lhs", "bayesian", "successive_halving"],
        default=None,
        help="Search mode (overrides config)",
    )

    parser.add_argument(
        "--trials",
        type=int,
        default=None,
        help="Number of trials (overrides config)",
    )

    parser.add_argument(
        "--parallelism",
        type=int,
        default=None,
        help="Number of parallel workers (overrides config)",
    )

    parser.add_argument(
        "--output",
        type=str,
        default=None,
        help="Output directory (overrides config)",
    )

    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show configuration without running optimization",
    )

    parser.add_argument(
        "--log-level",
        type=str,
        choices=["DEBUG", "INFO", "WARNING", "ERROR"],
        default="INFO",
        help="Logging level",
    )

    parser.add_argument(
        "--seed",
        type=int,
        default=None,
        help="Random seed for reproducibility",
    )

    return parser.parse_args()


def main() -> int:
    """Main entry point."""
    args = parse_args()
    setup_logging(args.log_level)

    logger = logging.getLogger(__name__)

    # Load config
    config_path = Path(args.config)
    if not config_path.exists():
        logger.error(f"Config file not found: {config_path}")
        return 1

    try:
        config = OptimizationConfig.from_yaml(config_path)
    except Exception:
        logger.error("Failed to load config", exc_info=True)
        return 1

    # Apply CLI overrides
    # Note: Since config is frozen dataclass, we need to create new instances
    # For MVP, we'll just log the overrides and note they would be applied

    if args.dry_run:
        print("\n" + "=" * 60)
        print("APEX OPTIMIZER - DRY RUN")
        print("=" * 60)
        print(f"\nConfiguration: {config_path}")
        print(f"Name: {config.name}")
        print(f"Version: {config.version}")
        print("\nSearch:")
        mode = args.mode if args.mode is not None else config.search.mode
        print(f"  Mode: {mode}")
        if mode == "successive_halving":
            sh = config.search.successive_halving
            print(
                f"  SuccessiveHalving: eta={sh.eta} window_days={list(sh.window_days)} wfa_windows={list(sh.wfa_windows)}"
            )
        trials = args.trials if args.trials is not None else config.search.trials
        parallelism = (
            args.parallelism if args.parallelism is not None else config.search.parallelism
        )
        print(f"  Trials: {trials}")
        print(f"  Parallelism: {parallelism}")
        seed_val = args.seed if args.seed is not None else config.search.seed
        seed = 42 if seed_val is None else int(seed_val)
        print(f"  Seed: {seed}")
        print(f"\nParameters ({len(config.parameters)}):")
        for p in config.parameters:
            if p.range:
                print(f"  {p.name}: [{p.range[0]}, {p.range[1]}] step={p.step}")
            else:
                print(f"  {p.name}: {p.choices}")

        # Estimate grid size
        if mode == "grid":
            size = 1
            for p in config.parameters:
                if p.range and p.step:
                    n = int((p.range[1] - p.range[0]) / p.step) + 1
                    size *= n
                elif p.choices:
                    size *= len(p.choices)
            print(f"\nEstimated grid size: {size:,}")
            if size > config.search.max_grid_size:
                print(f"WARNING: Exceeds max_grid_size={config.search.max_grid_size}")

        print("\nConstraints:")
        print(f"  Apex trailing DD max: {config.constraints.apex.trailing_dd_max}%")
        print(f"  Apex daily profit max: {config.constraints.apex.daily_profit_max}%")
        print(f"  WFE min: {config.constraints.validation.wfe_min}")
        print(f"  SQN min: {config.constraints.validation.sqn_min}")
        print(f"  Min trades: {config.constraints.validation.min_trades}")

        print("\nOutput:")
        print(f"  Directory: {args.output or config.output.dir}")
        print(f"  Reports: {', '.join(config.output.reports)}")

        print("\n" + "=" * 60)
        print("Dry run complete. Remove --dry-run to execute optimization.")
        print("=" * 60 + "\n")
        return 0

    # Create optimizer
    logger.info("Initializing ApexOptimizer...")

    # NOTE: This CLI is intentionally "dry-run" oriented for now.
    # Running the full optimization requires integrating a backtest function.
    print("\n" + "=" * 60)
    print("APEX OPTIMIZER")
    print("=" * 60)
    print(f"\nConfiguration: {config_path}")
    print(f"Name: {config.name}")
    print(f"Mode: {config.search.mode}")
    print(f"Trials: {config.search.trials}")
    print()
    print("NOTE: To run optimization, integrate with BacktestRunner:")
    print()
    print("  from src.optimization import ApexOptimizer")
    print("  from nautilus_gold_scalper.scripts.backtest.run_backtest import BacktestRunner")
    print()
    print("  def backtest_fn(params, start, end):")
    print("      runner = BacktestRunner(...)")
    print("      result = runner.run(config_overrides=params, ...)")
    print("      return trades_df, equity_series")
    print()
    print("  optimizer = ApexOptimizer.from_yaml('config.yaml')")
    print("  optimizer.set_backtest_fn(backtest_fn)")
    print("  results = optimizer.run()")
    print()
    print("=" * 60 + "\n")

    return 0


if __name__ == "__main__":
    sys.exit(main())
