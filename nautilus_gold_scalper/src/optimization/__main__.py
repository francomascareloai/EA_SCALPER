"""
CLI entry point for Apex Optimizer.

Usage:
    python -m src.optimization --config configs/grids/smc_optimization.yaml
    python -m src.optimization --config configs/grids/smc_optimization.yaml --trials 50 --dry-run
    python -m src.optimization --config configs/grids/smc_optimization.yaml --train-start 2020-01-01 --train-end 2020-06-30
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
================================================================================
                           APEX OPTIMIZER - HAPPY PATH
================================================================================

1. VALIDATE CONFIG (dry-run):
   python -m src.optimization --config configs/grids/smc.yaml --dry-run

2. RUN OPTIMIZATION:
   # Bayesian search (recommended for exploration):
   python -m src.optimization --config configs/grids/smc.yaml --mode bayesian --trials 100

   # Quick smoke test (narrow date range):
   python -m src.optimization --config configs/grids/smc.yaml --train-start 2020-01-01 --train-end 2020-06-30 --trials 20

   # Grid search (small parameter space only):
   python -m src.optimization --config configs/grids/smc.yaml --mode grid

   # Successive Halving (multi-fidelity, recommended for large searches):
   python -m src.optimization --config configs/grids/smc.yaml --mode successive_halving --trials 200

3. OUTPUTS (in logs/optimization/<session>/):
   - summary.json        Full results with all metrics
   - summary.csv         Tabular summary for analysis
   - top_candidates.json Top N candidates with params
   - HANDOFF_ORACLE.md   Structured handoff for ORACLE agent
   - HANDOFF_SENTINEL.md Structured handoff for SENTINEL agent

4. NEXT STEPS:
   - Review HANDOFF_ORACLE.md for validation recommendations
   - Run ORACLE/SENTINEL validation on top candidates
   - Generate final GO/NO-GO recommendation

================================================================================
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

    # Training date range overrides (for smoke tests without editing YAML)
    parser.add_argument(
        "--train-start",
        type=str,
        default=None,
        help="Training period start date (YYYY-MM-DD), overrides config",
    )

    parser.add_argument(
        "--train-end",
        type=str,
        default=None,
        help="Training period end date (YYYY-MM-DD), overrides config",
    )

    # Backtest adapter configuration
    parser.add_argument(
        "--initial-balance",
        type=float,
        default=50000.0,
        help="Initial account balance in USD (default: 50000)",
    )

    parser.add_argument(
        "--feed",
        type=str,
        choices=["ticks", "bars"],
        default="ticks",
        help="Feed mode: 'ticks' for full fidelity, 'bars' for fast prescreen (default: ticks)",
    )

    parser.add_argument(
        "--ltf-minutes",
        type=int,
        default=1,
        help="Low timeframe bar aggregation period in minutes (default: 1)",
    )

    parser.add_argument(
        "--sample-rate",
        type=int,
        default=1,
        help="Tick sample rate (1 = every tick, 10 = every 10th) (default: 1)",
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

    # Apply CLI overrides to config
    # Note: OptimizationConfig is frozen, so we need to use dataclasses.replace
    from dataclasses import replace

    if args.mode is not None:
        config = replace(config, search=replace(config.search, mode=args.mode))
    if args.trials is not None:
        config = replace(config, search=replace(config.search, trials=args.trials))
    if args.seed is not None:
        config = replace(config, search=replace(config.search, seed=args.seed))
    if args.output is not None:
        config = replace(config, output=replace(config.output, dir=args.output))
    if args.train_start is not None:
        config = replace(config, data=replace(config.data, train_start=args.train_start))
    if args.train_end is not None:
        config = replace(config, data=replace(config.data, train_end=args.train_end))

    if args.dry_run:
        print("\n" + "=" * 60)
        print("APEX OPTIMIZER - DRY RUN")
        print("=" * 60)
        print(f"\nConfiguration: {config_path}")
        print(f"Name: {config.name}")
        print(f"Version: {config.version}")
        print("\nSearch:")
        mode = config.search.mode
        print(f"  Mode: {mode}")
        if mode == "successive_halving":
            sh = config.search.successive_halving
            print(
                f"  SuccessiveHalving: eta={sh.eta} window_days={list(sh.window_days)} wfa_windows={list(sh.wfa_windows)}"
            )
        print(f"  Trials: {config.search.trials}")
        print(f"  Parallelism: {config.search.parallelism}")
        print(f"  Seed: {config.search.seed or 42}")
        print("\nData:")
        print(f"  Train start: {config.data.train_start}")
        print(f"  Train end: {config.data.train_end}")
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
        print(f"  Directory: {config.output.dir}")
        print(f"  Reports: {', '.join(config.output.reports)}")

        print("\nBacktest adapter:")
        print(f"  Initial balance: ${args.initial_balance:,.0f}")
        print(f"  Feed mode: {args.feed}")
        print(f"  LTF minutes: {args.ltf_minutes}")
        print(f"  Sample rate: {args.sample_rate}")

        print("\n" + "=" * 60)
        print("Dry run complete. Remove --dry-run to execute optimization.")
        print("=" * 60 + "\n")
        return 0

    # Run optimization
    logger.info("Initializing ApexOptimizer...")

    from src.optimization.backtest_adapter import BacktestAdapterConfig, create_backtest_fn
    from src.optimization.optimizer import ApexOptimizer

    # Create backtest function using adapter
    adapter_config = BacktestAdapterConfig(
        initial_balance=args.initial_balance,
        ltf_minutes=args.ltf_minutes,
        sample_rate=args.sample_rate,
        seed=config.search.seed or 42,
        feed_mode=args.feed,
    )
    backtest_fn = create_backtest_fn(adapter_config)

    # Create and run optimizer
    optimizer = ApexOptimizer(config, backtest_fn=backtest_fn)

    print("\n" + "=" * 60)
    print("APEX OPTIMIZER")
    print("=" * 60)
    print(f"\nConfiguration: {config_path}")
    print(f"Name: {config.name}")
    print(f"Mode: {config.search.mode}")
    print(f"Trials: {config.search.trials}")
    print(f"Training: {config.data.train_start} -> {config.data.train_end}")
    print(f"Feed: {args.feed}")
    print()

    try:
        results = optimizer.run()
    except Exception:
        logger.error("Optimization failed", exc_info=True)
        return 1

    print("\n" + "=" * 60)
    print("OPTIMIZATION COMPLETE")
    print("=" * 60)
    print(f"\nTotal trials: {len(results)}")
    apex_compliant = sum(1 for r in results if r.apex_compliant)
    print(f"Apex compliant: {apex_compliant}")

    if results:
        best = results[0]
        print("\nBest result:")
        print(f"  Score: {best.score:.4f}")
        print(f"  SQN: {best.sqn:.2f}")
        print(f"  WFE: {best.wfe:.2f}")
        print(f"  Trades: {best.trades}")
        print(f"  Win rate: {best.win_rate:.1%}")
        print(f"  Max DD: {best.max_drawdown_pct:.2f}%")
        print(f"  Apex compliant: {best.apex_compliant}")
        print("\n  Best params:")
        for k, v in best.params.items():
            print(f"    {k}: {v}")

    output_dir = optimizer.get_output_dir()
    if output_dir:
        print(f"\nOutput: {output_dir}")

    print("=" * 60 + "\n")

    return 0


if __name__ == "__main__":
    sys.exit(main())
