#!/usr/bin/env python3
"""
Unified Optimization Script - Apex Optimizer with BacktestRunner integration.

This script consolidates all optimization workflows (grid, random, bayesian, successive_halving)
into a single robust entry point with full CLI configuration.

Usage:
    # Run from repo root
    python nautilus_gold_scalper/scripts/optimize.py --config nautilus_gold_scalper/configs/grids/smc_optimization_fast.yaml

    # Or run from inside nautilus_gold_scalper/
    python scripts/optimize.py --config configs/grids/smc_optimization_fast.yaml

    # Override mode and trials
    python nautilus_gold_scalper/scripts/optimize.py --config nautilus_gold_scalper/configs/grids/smc_optimization_fast.yaml --mode random --trials 50

    # Dry run to preview configuration
    python nautilus_gold_scalper/scripts/optimize.py --config nautilus_gold_scalper/configs/grids/smc_optimization_fast.yaml --dry-run

Version: 1.0.0
Author: Franco (Nautilus Gold Scalper project)
"""

from __future__ import annotations

import argparse
import json
import logging
import math
import os
import random
import shutil
import signal
import sys
import tempfile
import time
from collections.abc import Callable, Generator
from contextlib import contextmanager
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from functools import lru_cache
from pathlib import Path
from typing import TYPE_CHECKING, Any, TypeAlias

import numpy as np
import pandas as pd
import yaml

# Add project root to path
PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from src.optimization.config import OptimizationConfig, ParameterSpec
from src.optimization.optimizer import ApexOptimizer
from src.optimization.search.base import TrialResult


def _normalize_jsonable(v: Any) -> Any:
    """Convert common non-JSON types (numpy scalars) into JSON-friendly values."""
    if isinstance(v, (np.integer,)):
        return int(v)
    if isinstance(v, (np.floating,)):
        return float(v)
    return v


def _sanitize_for_json(obj: Any) -> Any:
    """Recursively sanitize values so JSON is strict-safe.

    Replaces NaN/Inf/-Inf with None so downstream strict JSON parsers don't fail.
    """
    if isinstance(obj, dict):
        return {k: _sanitize_for_json(v) for k, v in obj.items()}

    if isinstance(obj, list):
        return [_sanitize_for_json(v) for v in obj]

    # Normalize numpy floating to builtin float before isfinite.
    if isinstance(obj, (float, np.floating)):
        v = float(obj)
        return v if math.isfinite(v) else None

    return obj


# Type checking imports for lazy-loaded modules
if TYPE_CHECKING:
    from scripts.backtest.run_backtest import BacktestRunner as BacktestRunnerType

BacktestRunnerT: TypeAlias = type["BacktestRunnerType"]


# =============================================================================
# CONSTANTS
# =============================================================================
DEFAULT_INITIAL_BALANCE: float = 100_000.0
DEFAULT_LTF_MINUTES: int = 15
DEFAULT_SEED: int = 42
DEFAULT_SAMPLE_RATE: float = 1.0
LOG_FORMAT: str = "%(asctime)s [%(levelname)s] %(name)s: %(message)s"
DATE_FORMAT: str = "%Y-%m-%d %H:%M:%S"


def _resolve_seed(
    cli_seed: int | None, config_seed: int | None, *, default: int = DEFAULT_SEED
) -> int:
    """Resolve a deterministic RNG seed.

    IMPORTANT: do NOT use `a or b` here because `0` is a valid seed.

    Args:
        cli_seed: Seed passed via CLI (may be None)
        config_seed: Seed from config (may be None)
        default: Fallback seed when both are None

    Returns:
        An `int` seed (0 is preserved).
    """
    seed_val: int | None
    if cli_seed is not None:
        seed_val = cli_seed
    elif config_seed is not None:
        seed_val = config_seed
    else:
        seed_val = default

    # Ensure we always propagate a builtin int (yaml/np can sneak in other numerics).
    return int(seed_val)


# Atomic write constants
ATOMIC_WRITE_SUFFIX: str = ".tmp"


# =============================================================================
# ATOMIC FILE OPERATIONS
# =============================================================================
def _atomic_write(path: Path, content: str) -> None:
    """Write file atomically using temp file + rename pattern.

    This prevents file corruption from crashes mid-write:
    1. Write to temp file in same directory (same filesystem for atomic rename)
    2. Flush and sync to disk
    3. Atomic rename to final path

    Args:
        path: Final destination path
        content: String content to write
    """
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp_path = tempfile.mkstemp(dir=path.parent, suffix=ATOMIC_WRITE_SUFFIX)
    try:
        try:
            f = os.fdopen(fd, "w", encoding="utf-8")
        except Exception:
            # If fdopen fails, we must close the raw fd to avoid a leak.
            os.close(fd)
            raise

        with f:
            f.write(content)
            f.flush()
            os.fsync(f.fileno())

        shutil.move(tmp_path, path)
    except Exception:
        # Clean up temp file on failure
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)
        raise


def _atomic_write_csv(path: Path, df: pd.DataFrame) -> None:
    """Write DataFrame to CSV atomically.

    Args:
        path: Final destination path
        df: DataFrame to write
    """
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp_path = tempfile.mkstemp(dir=path.parent, suffix=ATOMIC_WRITE_SUFFIX)
    try:
        try:
            # Close the fd since to_csv opens its own handle
            os.close(fd)
        except Exception:
            # If close fails, abort before writing so we don't leak fds across loops.
            if os.path.exists(tmp_path):
                os.unlink(tmp_path)
            raise

        df.to_csv(tmp_path, index=False)
        shutil.move(tmp_path, path)
    except Exception:
        if os.path.exists(tmp_path):
            os.unlink(tmp_path)
        raise


# =============================================================================
# GRACEFUL SHUTDOWN HANDLERS
# =============================================================================
_shutdown_requested: bool = False


def _signal_handler(signum: int, frame: Any) -> None:
    """Handle SIGTERM/SIGINT for graceful shutdown."""
    global _shutdown_requested
    _shutdown_requested = True
    sig_name = signal.Signals(signum).name
    logging.getLogger(__name__).warning(
        f"Received {sig_name}, initiating graceful shutdown... "
        "(current trial will complete, then save results)"
    )


@contextmanager
def graceful_shutdown() -> Generator[None, None, None]:
    """Context manager for graceful signal handling.

    Installs SIGTERM and SIGINT handlers that set a shutdown flag
    instead of immediately terminating. Restores original handlers on exit.

    Usage:
        with graceful_shutdown():
            for trial in trials:
                if is_shutdown_requested():
                    break
                run_trial(...)
    """
    global _shutdown_requested
    _shutdown_requested = False

    original_sigterm = signal.signal(signal.SIGTERM, _signal_handler)
    original_sigint = signal.signal(signal.SIGINT, _signal_handler)
    try:
        yield
    finally:
        signal.signal(signal.SIGTERM, original_sigterm)
        signal.signal(signal.SIGINT, original_sigint)


def is_shutdown_requested() -> bool:
    """Check if graceful shutdown has been requested."""
    return _shutdown_requested


# =============================================================================
# LAZY IMPORTS (Thread-safe via lru_cache)
# =============================================================================
@lru_cache(maxsize=1)
def get_backtest_runner() -> Any:
    """Thread-safe lazy import of BacktestRunner.

    Uses lru_cache to ensure single import even in multi-threaded context.
    """
    from scripts.backtest.run_backtest import BacktestRunner

    return BacktestRunner


logger = logging.getLogger(__name__)


@dataclass
class OptimizationResult:
    """Summary of optimization run."""

    config_path: str
    mode: str
    total_trials: int
    completed_trials: int
    best_score: float
    best_params: dict[str, Any]
    best_sqn: float
    best_wfe: float
    best_sharpe: float
    duration_seconds: float
    output_dir: str
    apex_compliant_count: int


def setup_logging(level: str = "INFO", log_file: Path | None = None) -> None:
    """Configure logging for optimization runs."""
    handlers: list[logging.Handler] = [logging.StreamHandler(sys.stdout)]
    if log_file:
        handlers.append(logging.FileHandler(log_file))

    logging.basicConfig(
        level=getattr(logging, level.upper()),
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
        handlers=handlers,
        force=True,
    )


def parse_args() -> argparse.Namespace:
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Apex Optimizer - Unified parameter optimization for Apex-compliant strategies",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Run successive halving optimization (default fast config)
  python scripts/optimize.py --config configs/grids/smc_optimization_fast.yaml

  # Run Bayesian optimization with 100 trials
  python scripts/optimize.py --config configs/grids/smc_optimization_fast.yaml --mode bayesian --trials 100

  # Dry run to preview configuration
  python scripts/optimize.py --config configs/grids/smc_optimization_fast.yaml --dry-run

  # Full parallelism for grid search
  python scripts/optimize.py --config configs/grids/smc_optimization_fast.yaml --mode grid --parallelism 8

  # Quick test with random sampling
  python scripts/optimize.py --config configs/grids/smc_optimization_fast.yaml --mode random --trials 20 --quick

Modes:
  grid              - Exhaustive grid search (all combinations)
  random            - Latin hypercube sampling (stratified random)
  lhs               - Alias for random (explicit LHS naming)
  bayesian          - Bayesian optimization with Gaussian processes
  successive_halving - Multi-fidelity with early pruning (recommended)
""",
    )

    # Required
    parser.add_argument(
        "--config",
        type=str,
        required=True,
        help="Path to YAML optimization config file",
    )

    # Search configuration overrides
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
        "--seed",
        type=int,
        default=None,
        help="Random seed for reproducibility (overrides config)",
    )

    # Output configuration
    parser.add_argument(
        "--output",
        type=str,
        default=None,
        help="Output directory (overrides config)",
    )

    parser.add_argument(
        "--log-level",
        type=str,
        choices=["DEBUG", "INFO", "WARNING", "ERROR"],
        default="INFO",
        help="Logging level",
    )

    # Execution modes
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show configuration without running optimization",
    )

    parser.add_argument(
        "--quick",
        action="store_true",
        help="Quick mode: use bars feed instead of ticks for faster execution",
    )

    parser.add_argument(
        "--quiet",
        action="store_true",
        help="Suppress per-trial output (less verbose)",
    )

    # Data configuration
    # NOTE: BacktestRunner reads the dataset path from `nautilus_gold_scalper/data/config.yaml`
    # (single source of truth). We intentionally do NOT support `--data-path` here to avoid
    # mismatches between what the optimizer prints and what the runner actually uses.

    parser.add_argument(
        "--start-date",
        type=str,
        default=None,
        help="Training start date YYYY-MM-DD (overrides config)",
    )

    parser.add_argument(
        "--end-date",
        type=str,
        default=None,
        help="Training end date YYYY-MM-DD (overrides config)",
    )

    parser.add_argument(
        "--sample-rate",
        type=float,
        default=1.0,
        help="Tick sampling rate (1.0 = all ticks, 0.1 = 10%%, 10 = every 10th tick)",
    )

    # Backtest configuration
    parser.add_argument(
        "--initial-balance",
        type=float,
        default=100_000.0,
        help="Initial account balance",
    )

    parser.add_argument(
        "--ltf-minutes",
        type=int,
        default=15,
        help="Low timeframe bar period in minutes",
    )

    parser.add_argument(
        "--feed",
        type=str,
        choices=["ticks", "bars"],
        default=None,
        help="Data feed mode: ticks (accurate) or bars (fast)",
    )

    parser.add_argument(
        "--bars-file",
        type=str,
        default=None,
        help="Path to M5 bars file (CSV/Parquet). Requires feed=bars (or --quick).",
    )

    parser.add_argument(
        "--resume",
        type=str,
        default=None,
        help=(
            "Path to optimizer checkpoint.json to resume from. "
            "Supported for modes: grid, random, successive_halving. "
            "Not supported for bayesian."
        ),
    )

    return parser.parse_args()


def estimate_grid_size(parameters: list[ParameterSpec]) -> int:
    """Estimate total grid size from parameters.

    Uses round() instead of int() to match real grid search cardinality
    (avoids float precision off-by-one errors).
    """
    size = 1
    for p in parameters:
        if p.range and p.step:
            # Use round() to match grid.py implementation (endpoint-correct)
            n = round((p.range[1] - p.range[0]) / p.step) + 1
            size *= n
        elif p.choices:
            size *= len(p.choices)
    return size


def create_backtest_fn(
    args: argparse.Namespace,
    config: OptimizationConfig,
) -> Callable[[dict[str, Any], str, str], tuple[pd.DataFrame, pd.Series]]:
    """Create a backtest function that wraps BacktestRunner.

    Returns:
        Callable that takes (params, start_date, end_date) and returns
        (trades_df, equity_series) for WFA/validation.
    """
    BR = get_backtest_runner()

    # Resolve feed mode
    feed = args.feed
    if feed is None:
        feed = "bars" if args.quick else "ticks"

    bars_file = str(args.bars_file) if args.bars_file else None

    def backtest_fn(
        params: dict[str, Any],
        start_date: str,
        end_date: str,
    ) -> tuple[pd.DataFrame, pd.Series]:
        """Run a single backtest trial with given parameters.

        Args:
            params: Strategy parameter overrides
            start_date: Training period start (YYYY-MM-DD)
            end_date: Training period end (YYYY-MM-DD)

        Returns:
            trades_df: DataFrame with columns [entry_time, exit_time, pnl, ...]
            equity_series: Series indexed by time with cumulative equity
        """
        seed = _resolve_seed(args.seed, getattr(config.search, "seed", None), default=DEFAULT_SEED)
        runner = BR(
            initial_balance=args.initial_balance,
            log_level="ERROR",  # Quiet logging during optimization
            seed=seed,
        )

        # NOTE: `params` may be either:
        # - nested dicts (ApexOptimizer expanded dotpaths), OR
        # - flat dotpath keys (e.g., {"execution.use_mtf": true}).
        # We must NOT override YAML `fixed` values with hardcoded defaults.
        _missing = object()

        def _get_value(mapping: dict[str, Any], dotted_key: str) -> object:
            """Get a config value from either nested dicts or dotpath keys.

            Precedence:
            1) Exact key match in mapping (supports flat dotpaths)
            2) Nested lookup by splitting on '.'
            """
            if dotted_key in mapping:
                v = mapping[dotted_key]
                return v if v is not None else _missing

            cur: object = mapping
            for part in dotted_key.split("."):
                if not isinstance(cur, dict) or part not in cur:
                    return _missing
                cur = cur[part]
            return cur if cur is not None else _missing

        def _get_from_section(section: object, key: str) -> object:
            if isinstance(section, dict) and key in section:
                v = section[key]
                return v if v is not None else _missing
            return _missing

        def _as_bool(v: object, default: bool) -> bool:
            if isinstance(v, (bool, np.bool_)):
                return bool(v)
            if isinstance(v, (int, np.integer)):
                return bool(int(v))
            if isinstance(v, str):
                s = v.strip().lower()
                if s in ("true", "1", "yes", "y", "on"):
                    return True
                if s in ("false", "0", "no", "n", "off"):
                    return False
            return default

        def _as_int(v: object, default: int) -> int:
            if isinstance(v, (int, np.integer)):
                return int(v)
            if isinstance(v, float):
                if v.is_integer():
                    return int(v)
                return default
            if isinstance(v, str):
                try:
                    return int(v)
                except ValueError:
                    return default
            # Strict typing: avoid calling int(...) on unknown objects.
            return default

        def _as_float(v: object) -> float | None:
            if isinstance(v, (int, float, np.integer, np.floating)):
                return float(v)
            if isinstance(v, str):
                try:
                    return float(v)
                except ValueError:
                    return None
            # Strict typing: avoid calling float(...) on unknown objects.
            return None

        # Hardcoded fallbacks (used ONLY when value is absent from params)
        execution_threshold_default = 70
        use_session_filter_default = True
        use_regime_filter_default = True
        use_mtf_default = False
        use_footprint_default = True
        prop_firm_enabled_default = True
        use_news_filter_default = True

        exec_over = params.get("execution") if isinstance(params, dict) else None
        confluence_over = params.get("confluence") if isinstance(params, dict) else None
        news_over = params.get("news") if isinstance(params, dict) else None
        risk_over = params.get("risk") if isinstance(params, dict) else None
        run_over = params.get("run") if isinstance(params, dict) else None

        # execution_threshold
        # - Prefer explicit runtime override (execution.* / run.*)
        # - Otherwise, fall back to confluence thresholds
        thresh_raw = _get_from_section(exec_over, "execution_threshold")
        if thresh_raw is _missing:
            thresh_raw = _get_from_section(run_over, "execution_threshold")
        if thresh_raw is _missing:
            thresh_raw = _get_value(params, "run.execution_threshold")
        if thresh_raw is _missing:
            thresh_raw = _get_from_section(confluence_over, "execution_threshold")
        if thresh_raw is _missing:
            thresh_raw = _get_from_section(confluence_over, "min_score_to_trade")
        if thresh_raw is _missing:
            thresh_raw = _get_value(params, "execution.execution_threshold")
        if thresh_raw is _missing:
            thresh_raw = _get_value(params, "confluence.execution_threshold")
        if thresh_raw is _missing:
            thresh_raw = _get_value(params, "confluence.min_score_to_trade")
        execution_threshold = _as_int(thresh_raw, execution_threshold_default)

        # Execution booleans
        use_session_raw = _get_from_section(exec_over, "use_session_filter")
        if use_session_raw is _missing:
            use_session_raw = _get_from_section(run_over, "use_session_filter")
        if use_session_raw is _missing:
            use_session_raw = _get_value(params, "run.use_session_filter")
        if use_session_raw is _missing:
            use_session_raw = _get_value(params, "execution.use_session_filter")
        use_session_filter = _as_bool(use_session_raw, use_session_filter_default)

        use_regime_raw = _get_from_section(exec_over, "use_regime_filter")
        if use_regime_raw is _missing:
            use_regime_raw = _get_from_section(run_over, "use_regime_filter")
        if use_regime_raw is _missing:
            use_regime_raw = _get_value(params, "run.use_regime_filter")
        if use_regime_raw is _missing:
            use_regime_raw = _get_value(params, "execution.use_regime_filter")
        use_regime_filter = _as_bool(use_regime_raw, use_regime_filter_default)

        use_mtf_raw = _get_from_section(exec_over, "use_mtf")
        if use_mtf_raw is _missing:
            use_mtf_raw = _get_from_section(run_over, "use_mtf")
        if use_mtf_raw is _missing:
            use_mtf_raw = _get_value(params, "run.use_mtf")
        if use_mtf_raw is _missing:
            use_mtf_raw = _get_value(params, "execution.use_mtf")
        use_mtf = _as_bool(use_mtf_raw, use_mtf_default)

        use_footprint_raw = _get_from_section(exec_over, "use_footprint")
        if use_footprint_raw is _missing:
            use_footprint_raw = _get_from_section(run_over, "use_footprint")
        if use_footprint_raw is _missing:
            use_footprint_raw = _get_value(params, "run.use_footprint")
        if use_footprint_raw is _missing:
            use_footprint_raw = _get_value(params, "execution.use_footprint")
        use_footprint = _as_bool(use_footprint_raw, use_footprint_default)

        prop_firm_raw = _get_from_section(exec_over, "prop_firm_enabled")
        if prop_firm_raw is _missing:
            prop_firm_raw = _get_from_section(run_over, "prop_firm_enabled")
        if prop_firm_raw is _missing:
            prop_firm_raw = _get_value(params, "run.prop_firm_enabled")
        if prop_firm_raw is _missing:
            prop_firm_raw = _get_value(params, "execution.prop_firm_enabled")
        prop_firm_enabled = _as_bool(prop_firm_raw, prop_firm_enabled_default)

        # use_news_filter
        # Prefer explicit runtime override (execution.* / run.*), otherwise use YAML `news.enabled`.
        news_enabled_raw = _get_from_section(exec_over, "use_news_filter")
        if news_enabled_raw is _missing:
            news_enabled_raw = _get_from_section(run_over, "use_news_filter")
        if news_enabled_raw is _missing:
            news_enabled_raw = _get_value(params, "run.use_news_filter")
        if news_enabled_raw is _missing:
            news_enabled_raw = _get_from_section(news_over, "enabled")
        if news_enabled_raw is _missing:
            news_enabled_raw = _get_value(params, "news.enabled")
        if news_enabled_raw is _missing:
            news_enabled_raw = _get_value(params, "use_news_filter")
        use_news_filter = _as_bool(news_enabled_raw, use_news_filter_default)

        # Default ltf_minutes from CLI args, allow YAML override.
        ltf_minutes = args.ltf_minutes
        ltf_bar_raw = _get_from_section(exec_over, "ltf_bar_minutes")
        if ltf_bar_raw is _missing:
            ltf_bar_raw = _get_value(params, "execution.ltf_bar_minutes")
        if ltf_bar_raw is not _missing:
            ltf_minutes_candidate = _as_int(ltf_bar_raw, ltf_minutes)
            if ltf_minutes_candidate > 0:
                ltf_minutes = ltf_minutes_candidate

        # risk_per_trade (YAML uses `risk.max_risk_per_trade`)
        risk_per_trade: float | None = None
        risk_val = _get_from_section(risk_over, "max_risk_per_trade")
        if risk_val is _missing:
            risk_val = _get_value(params, "risk.max_risk_per_trade")
        if risk_val is not _missing:
            risk_per_trade = _as_float(risk_val)

        # CRITICAL: When prop_firm_enabled is True, Apex trailing DD / HWM semantics
        # require QuoteTicks (bid/ask) to compute mark-to-market equity intrabar.
        # Bar-only mode is a fast screener but is NOT valid for Apex compliance.
        if prop_firm_enabled and feed != "ticks":
            logger.error(
                "CRITICAL: prop_firm_enabled=True requires feed=ticks for MTM equity/HWM enforcement. "
                "Refusing to run optimization trial in feed=%s.",
                feed,
            )
            return pd.DataFrame(), pd.Series(dtype=float, name="equity")

        summary = runner.run(
            start_date=start_date,
            end_date=end_date,
            ltf_minutes=ltf_minutes,
            sample_rate=args.sample_rate,
            use_session_filter=use_session_filter,
            use_regime_filter=use_regime_filter,
            use_mtf=use_mtf,
            use_footprint=use_footprint,
            prop_firm_enabled=prop_firm_enabled,
            use_news_filter=use_news_filter,
            execution_threshold=execution_threshold,
            risk_per_trade=risk_per_trade,
            feed=feed,
            bars_file=bars_file,
            reports="none",
            return_summary=True,
            quiet=True,
            config_overrides=params,
        )

        # Extract trades and equity from the run
        # The BacktestRunner stores results internally
        trades_df = _extract_trades_df(runner)

        # Ensure we can extract MTM equity: BacktestRunner always stores the last
        # strategy instance as `runner.strategy`.
        equity_series = _extract_equity_series(runner, args.initial_balance)

        return trades_df, equity_series

    return backtest_fn


def _extract_trades_df(runner: Any) -> pd.DataFrame:
    """Extract trades DataFrame from BacktestRunner.

    We intentionally avoid using `engine.cache.*` internals because the public Cache API
    does not expose `fills()` in the installed NautilusTrader build.

    Source of truth for realized trades is `engine.trader.generate_positions_report()`,
    which already contains realized PnL and open/close timestamps.

    Returns a DataFrame which MUST include:
    - `entry_time` (UTC datetime-like): used for WFA window assignment (decision time)
    - `exit_time` (UTC datetime-like): used for overnight checks and realized timing
    - `timestamp` (UTC datetime-like): legacy field (may be derived from exit_time)
    - `pnl` (float): used for SQN/Sharpe and daily PnL aggregation
    """
    if runner.engine is None:
        return pd.DataFrame()

    try:
        positions = runner.engine.trader.generate_positions_report()
        if positions is None or len(positions) == 0:
            return pd.DataFrame()

        df = positions.copy()

        # Timestamps: prefer explicit opened/closed datetime columns.
        # (Some reports may also contain ns integer columns like ts_init.)
        entry_time = None
        exit_time = None
        if "ts_opened" in df.columns:
            entry_time = pd.to_datetime(df["ts_opened"], utc=True, errors="coerce")
        elif "ts_init" in df.columns:
            entry_time = pd.to_datetime(df["ts_init"], utc=True, errors="coerce", unit="ns")

        if "ts_closed" in df.columns:
            exit_time = pd.to_datetime(df["ts_closed"], utc=True, errors="coerce")
        elif "ts_last" in df.columns:
            exit_time = pd.to_datetime(df["ts_last"], utc=True, errors="coerce")

        # Realized PnL is recorded as strings like "339.57 USD".
        # Keep it net-of-fees as reported by the engine.
        if "realized_pnl" in df.columns:
            pnl = df["realized_pnl"].astype(str).str.replace("USD", "", regex=False).str.strip()
            pnl = pd.to_numeric(pnl, errors="coerce")
        else:
            pnl = pd.Series([np.nan] * len(df), dtype=float)

        instrument_id = df["instrument_id"].astype(str) if "instrument_id" in df.columns else None

        # CRITICAL: Use entry_time for timestamp, NOT exit_time.
        # Using exit_time causes look-ahead bias in WFA: trades opened in
        # in-sample but closed in out-of-sample would be incorrectly attributed
        # to OOS, inflating WFE metrics.
        # Formula: timestamp = entry_time (decision time, not realization time)
        trades = pd.DataFrame(
            {
                "instrument_id": instrument_id if instrument_id is not None else "",
                "entry_time": entry_time,
                "exit_time": exit_time,
                "timestamp": entry_time,  # Always use entry_time (no look-ahead)
                "pnl": pnl.astype(float),
            }
        )

        # Drop rows where required fields are missing.
        # Keep legacy `timestamp` requirement for backwards compatibility, but ensure
        # WFA can still use `entry_time` when present.
        trades = trades.dropna(subset=["timestamp", "pnl"]).reset_index(drop=True)
        return trades

    except Exception as e:
        logger.warning(f"Failed to extract trades: {e}")
        return pd.DataFrame()


def _extract_equity_series(runner: Any, initial_balance: float) -> pd.Series:
    """Extract equity curve from BacktestRunner.

    CRITICAL: `engine.trader.generate_account_report()['total']` is *balance*, not
    mark-to-market equity. It does not reliably include unrealized PnL and can
    severely underestimate Apex trailing DD.

    Primary source for Apex trailing DD must be mark-to-market equity using
    conservative pricing (LONG uses BID, SHORT uses ASK). The strategy already
    enforces this in `BaseStrategy.on_quote_tick()` by updating `DrawdownTracker`
    with equity computed from tick prices.

    Extraction:
    1) Strategy DrawdownTracker equity curve (MTM, conservative)

    If MTM equity cannot be extracted, this function returns an empty series so
    the optimization validation can fail closed (DD=100% → apex_compliant=False).

    Formula for trailing DD at any point t:
        HWM(t) = max(equity[0:t])
        trailing_dd_pct(t) = (HWM(t) - equity(t)) / HWM(t) * 100

    Example:
        equity = [100000, 102000, 101000, 103000, 99000]
        HWM    = [100000, 102000, 102000, 103000, 103000]
        DD%    = [0.0, 0.0, 0.98, 0.0, 3.88]
    """
    if runner.engine is None:
        logger.warning("No engine available for equity extraction")
        return pd.Series(dtype=float)

    try:
        # Preferred: extract mark-to-market equity from strategy DrawdownTracker history.
        strategy = getattr(runner, "strategy", None)
        drawdown_tracker = getattr(strategy, "_drawdown_tracker", None) if strategy else None
        if drawdown_tracker is not None and hasattr(drawdown_tracker, "get_history"):
            history = drawdown_tracker.get_history()
            if history:
                # History items are DrawdownSnapshot dataclasses.
                # Use `timestamp` as index and `equity` as value.
                times = [getattr(h, "timestamp", None) for h in history]
                equities = [float(getattr(h, "equity", float("nan"))) for h in history]
                dt_index = pd.to_datetime(times, utc=True, errors="coerce")

                # Fail closed on any timestamp/equity corruption: dropping bad rows can
                # understate DD by cherry-picking a subset of the curve.
                invalid_ts = int(pd.isna(dt_index).sum())
                finite_equity = bool(np.isfinite(np.asarray(equities, dtype=float)).all())
                if invalid_ts > 0 or not finite_equity:
                    logger.error(
                        "CRITICAL: MTM equity history contains invalid timestamps or non-finite equity; "
                        "failing closed (DD=100%). invalid_ts=%d finite_equity=%s total=%d",
                        invalid_ts,
                        str(finite_equity),
                        int(len(equities)),
                    )
                    return pd.Series(dtype=float, name="equity")

                equity_series = pd.Series(equities, index=dt_index, name="equity")

                # Keep duplicate timestamps: dropping duplicates can understate drawdown by
                # removing peaks/troughs. Use a stable sort to preserve original ordering
                # for equal timestamps.
                equity_series = (
                    equity_series.replace([np.inf, -np.inf], np.nan)
                    .dropna()
                    .sort_index(kind="mergesort")
                )

                if len(equity_series) >= 2:
                    logger.info(
                        f"EQUITY_SOURCE=drawdown_tracker points={len(equity_series)} "
                        f"range=[{equity_series.min():.2f},{equity_series.max():.2f}]"
                    )
                    return equity_series

        # For Apex trailing DD validation we MUST use MTM equity.
        # Balance-only series (account report) or reconstructed equity-from-returns can materially
        # understate trailing DD and let unsafe candidates pass.
        logger.error(
            "CRITICAL: Cannot extract MTM equity curve from strategy DrawdownTracker. "
            "Returning empty series to fail closed (DD=100%)."
        )
        return pd.Series(dtype=float, name="equity")

    except Exception as e:
        logger.error(f"Failed to extract equity: {type(e).__name__}: {e}")
        return pd.Series(dtype=float, name="equity")


def print_dry_run(args: argparse.Namespace, config: OptimizationConfig) -> None:
    """Print configuration for dry run."""
    print("\n" + "=" * 70)
    print("APEX OPTIMIZER - DRY RUN")
    print("=" * 70)

    print(f"\nConfiguration: {args.config}")
    print(f"Name: {config.name}")
    print(f"Version: {config.version}")

    # Search configuration
    mode = args.mode if args.mode is not None else config.search.mode
    trials = args.trials if args.trials is not None else config.search.trials
    parallelism = args.parallelism if args.parallelism is not None else config.search.parallelism
    seed = _resolve_seed(args.seed, getattr(config.search, "seed", None), default=DEFAULT_SEED)

    print(f"\n{'─' * 40}")
    print("SEARCH CONFIGURATION")
    print(f"{'─' * 40}")
    print(f"  Mode:        {mode}")
    print(f"  Trials:      {trials}")
    print(f"  Parallelism: {parallelism}")
    print(f"  Seed:        {seed}")

    if mode == "successive_halving":
        sh = config.search.successive_halving
        print("\n  Successive Halving:")
        print(f"    eta:          {sh.eta}")
        print(f"    window_days:  {list(sh.window_days)}")
        print(f"    wfa_windows:  {list(sh.wfa_windows)}")
        print(f"    metric:       {sh.promotion_metric}")

    # Parameters
    print(f"\n{'─' * 40}")
    print(f"PARAMETERS ({len(config.parameters)} total)")
    print(f"{'─' * 40}")
    for p in config.parameters:
        if p.range:
            n_values = int((p.range[1] - p.range[0]) / (p.step or 1)) + 1
            print(f"  {p.name}:")
            print(f"    range: [{p.range[0]}, {p.range[1]}], step={p.step} ({n_values} values)")
        elif p.choices:
            print(f"  {p.name}:")
            print(f"    choices: {p.choices} ({len(p.choices)} values)")

    # Grid size estimate
    grid_size = estimate_grid_size(config.parameters)
    print(f"\n  Total grid combinations: {grid_size:,}")

    if mode == "grid" and grid_size > config.search.max_grid_size:
        print(f"  ⚠️  WARNING: Exceeds max_grid_size={config.search.max_grid_size}")
    elif mode == "successive_halving":
        sh = config.search.successive_halving
        n_rungs = len(sh.window_days)
        total_evals = trials
        for i in range(1, n_rungs):
            total_evals += trials // (sh.eta**i)
        print(
            f"  Successive halving: {trials} trials × {n_rungs} rungs ≈ {total_evals} evaluations"
        )

    # Constraints
    print(f"\n{'─' * 40}")
    print("APEX CONSTRAINTS")
    print(f"{'─' * 40}")
    print(f"  Trailing DD max:    {config.constraints.apex.trailing_dd_max}%")
    print(f"  Daily profit max:   {config.constraints.apex.daily_profit_max}%")
    print(f"  Overnight positions: {config.constraints.apex.overnight_positions}")
    print(f"  Time gate violations: {config.constraints.apex.time_gate_violations}")

    print(f"\n{'─' * 40}")
    print("VALIDATION GATES")
    print(f"{'─' * 40}")
    print(f"  WFE min:      {config.constraints.validation.wfe_min}")
    print(f"  SQN min:      {config.constraints.validation.sqn_min}")
    print(f"  PSR min:      {config.constraints.validation.psr_min}")
    print(f"  Min trades:   {config.constraints.validation.min_trades}")
    print(f"  Min years:    {config.constraints.validation.min_years}")

    # Data
    print(f"\n{'─' * 40}")
    print("DATA")
    print(f"{'─' * 40}")
    print("  Dataset source: nautilus_gold_scalper/data/config.yaml")
    print(f"  Train range: {config.data.train_start} to {config.data.train_end}")
    print(f"  Test range:  {config.data.test_start} to {config.data.test_end}")
    print(f"  Sample rate: {args.sample_rate}")
    print(f"  Feed mode:   {args.feed or ('bars' if args.quick else 'ticks')}")

    # Output
    print(f"\n{'─' * 40}")
    print("OUTPUT")
    print(f"{'─' * 40}")
    output_dir = args.output or config.output.dir
    print(f"  Directory:   {output_dir}")
    print(f"  Reports:     {', '.join(config.output.reports)}")
    print(f"  Checkpoints: {config.output.checkpoint_enabled}")

    print("\n" + "=" * 70)
    print("Dry run complete. Remove --dry-run to execute optimization.")
    print("=" * 70 + "\n")


def apply_cli_overrides(config: OptimizationConfig, args: argparse.Namespace) -> OptimizationConfig:
    """Apply CLI argument overrides to config.

    Since OptimizationConfig uses frozen dataclasses, we need to recreate
    with modified values using dataclasses.replace().

    CRITICAL: Use explicit `is not None` checks, NOT falsy `or` pattern.
    Reason: `0 or default` returns `default` in Python, ignoring valid 0 values.
    Example: `--seed 0` would be ignored with `args.seed or config.search.seed`.
    """
    from dataclasses import replace as dc_replace

    # Helper to apply override only if explicitly provided (not None)
    def _override(cli_val: Any, default: Any) -> Any:
        return cli_val if cli_val is not None else default

    # Build modified search config using replace
    new_search = dc_replace(
        config.search,
        mode=("random" if args.mode == "lhs" else _override(args.mode, config.search.mode)),
        trials=_override(args.trials, config.search.trials),
        n_samples=_override(args.trials, config.search.n_samples),
        parallelism=_override(args.parallelism, config.search.parallelism),
        seed=_override(args.seed, config.search.seed),
    )

    # Build modified data config (flat fields)
    new_data = dc_replace(
        config.data,
        path=config.data.path,
        train_start=_override(args.start_date, config.data.train_start),
        train_end=_override(args.end_date, config.data.train_end),
    )

    # Build modified output config (flat fields)
    new_output = dc_replace(
        config.output,
        dir=_override(args.output, config.output.dir),
    )

    # Create new config with overrides
    return OptimizationConfig(
        name=config.name,
        version=config.version,
        description=config.description,
        search=new_search,
        parameters=config.parameters,
        fixed=config.fixed,
        constraints=config.constraints,
        objective=config.objective,
        validation=config.validation,
        stress_test=config.stress_test,
        data=new_data,
        output=new_output,
    )


def run_optimization(args: argparse.Namespace) -> int:
    """Run the optimization pipeline."""
    import math

    config_path = Path(args.config)
    if not config_path.exists():
        logger.error(f"Config file not found: {config_path}")
        return 1

    # Validate CLI numeric args for NaN/Inf/negative early (fail fast)
    # These values can propagate and cause silent misbehavior in backtests.
    numeric_validations = [
        ("initial_balance", args.initial_balance, 1000.0, None),  # min, max (None=no max)
        ("sample_rate", args.sample_rate, 0.01, 1.0) if args.sample_rate is not None else None,
        ("trials", args.trials, 1, None) if args.trials is not None else None,
        ("parallelism", args.parallelism, 1, None) if args.parallelism is not None else None,
    ]
    for check in numeric_validations:
        if check is None:
            continue
        name, val, min_val, max_val = check
        if not math.isfinite(val):
            logger.error(f"CLI arg --{name.replace('_', '-')} must be finite, got {val}")
            return 1
        if val < min_val:
            logger.error(f"CLI arg --{name.replace('_', '-')} must be >= {min_val}, got {val}")
            return 1
        if max_val is not None and val > max_val:
            logger.error(f"CLI arg --{name.replace('_', '-')} must be <= {max_val}, got {val}")
            return 1

    # Load config
    try:
        config = OptimizationConfig.from_yaml(config_path)
    except Exception as e:
        logger.error(f"Failed to load config: {e}")
        return 1

    # Apply CLI overrides
    config = apply_cli_overrides(config, args)

    # Validate bars_file mode early (fail fast)
    if args.bars_file:
        resolved_feed = args.feed or ("bars" if args.quick else "ticks")
        if resolved_feed != "bars":
            logger.error(
                "--bars-file requires feed=bars (or --quick). Current feed=%s", resolved_feed
            )
            return 1
        if not Path(str(args.bars_file)).exists():
            logger.error("--bars-file not found: %s", args.bars_file)
            return 1

    # Create output directory
    output_dir = Path(config.output.dir)
    if config.output.session_subfolder:
        session_id = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
        output_dir = output_dir / session_id
    output_dir.mkdir(parents=True, exist_ok=True)

    # Setup logging with file output
    log_file = output_dir / "optimization.log"
    setup_logging(args.log_level, log_file)

    print("\n" + "=" * 70)
    print("APEX OPTIMIZER - STARTING OPTIMIZATION")
    print("=" * 70)
    print(f"\nConfiguration: {config_path}")
    print(f"Mode: {config.search.mode}")
    print(f"Trials: {config.search.trials}")
    print(f"Output: {output_dir}")
    print("=" * 70 + "\n")

    # Set random seeds for reproducibility
    seed = _resolve_seed(args.seed, getattr(config.search, "seed", None), default=DEFAULT_SEED)
    random.seed(seed)
    np.random.seed(seed)

    # Create backtest function
    logger.info("Creating backtest function...")
    backtest_fn = create_backtest_fn(args, config)

    # Create optimizer
    logger.info("Initializing ApexOptimizer...")
    optimizer = ApexOptimizer(config, backtest_fn=backtest_fn)

    # Save config snapshot atomically
    config_snapshot = output_dir / "config_snapshot.yaml"
    config_data = {
        "name": config.name,
        "mode": config.search.mode,
        "trials": config.search.trials,
        "parallelism": config.search.parallelism,
        "seed": seed,
        "parameters": [p.name for p in config.parameters],
        "data": {
            "dataset_source": "nautilus_gold_scalper/data/config.yaml",
        },
        "cli_args": {
            "quick": args.quick,
            "sample_rate": args.sample_rate,
            "feed": args.feed,
            "bars_file": args.bars_file,
            "initial_balance": args.initial_balance,
        },
    }
    _atomic_write(config_snapshot, yaml.safe_dump(config_data, default_flow_style=False))

    # Run optimization with graceful shutdown handling
    t0 = time.perf_counter()
    interrupted = False
    try:
        with graceful_shutdown():
            results = optimizer.run(resume_from=args.resume)
    except KeyboardInterrupt:
        # This catches any interrupt not handled by the context manager
        logger.warning("Optimization interrupted by user")
        results = optimizer.get_results()  # Use public accessor
        interrupted = True
    except Exception as e:
        logger.error(f"Optimization failed: {e}")
        import traceback

        traceback.print_exc()
        return 1

    if is_shutdown_requested():
        logger.info("Graceful shutdown completed - saving partial results")
        results = optimizer.get_results()
        interrupted = True

    duration = time.perf_counter() - t0

    # Process results
    if not results:
        logger.warning("No results from optimization")
        return 1

    # Sort by score - BUT preserve SH ordering for successive_halving mode.
    # Successive halving returns results sorted by (last_rung_first, score),
    # ensuring top result is from final rung (highest fidelity).
    # Re-sorting purely by score would defeat multi-fidelity selection.
    if config.search.mode == "successive_halving":
        # Preserve optimizer ordering: last-rung results already at top
        sorted_results = results
    else:
        sorted_results = sorted(results, key=lambda r: r.score, reverse=True)
    best = sorted_results[0]

    # Count Apex compliant
    apex_compliant = sum(1 for r in results if r.apex_compliant)

    # Create summary
    summary = OptimizationResult(
        config_path=str(config_path),
        mode=config.search.mode,
        total_trials=config.search.trials,
        completed_trials=len(results),
        best_score=best.score,
        best_params=best.params,
        best_sqn=best.sqn,
        best_wfe=best.wfe,
        best_sharpe=best.sharpe,
        duration_seconds=duration,
        output_dir=str(output_dir),
        apex_compliant_count=apex_compliant,
    )

    # Save results
    _save_results(output_dir, sorted_results, summary)

    # Print summary
    print("\n" + "=" * 70)
    print("OPTIMIZATION COMPLETE")
    print("=" * 70)
    print(f"\nCompleted: {len(results)}/{config.search.trials} trials")
    print(f"Duration: {duration:.1f}s ({duration / 60:.1f} min)")
    print(f"Apex compliant: {apex_compliant}/{len(results)}")
    print("\nBest trial:")
    print(f"  Score:  {best.score:.4f}")
    print(f"  SQN:    {best.sqn:.2f}")
    print(f"  WFE:    {best.wfe:.2%}")
    print(f"  Sharpe: {best.sharpe:.2f}")
    print(f"  Trades: {best.trades}")
    print("\nBest parameters:")
    for k, v in best.params.items():
        print(f"  {k}: {v}")
    print(f"\nResults saved to: {output_dir}")
    print("=" * 70 + "\n")

    return 0


def _save_results(
    output_dir: Path,
    results: list[TrialResult],
    summary: OptimizationResult,
) -> None:
    """Save optimization results to files atomically.

    Uses temp file + rename pattern to prevent corruption from crashes mid-write.
    Files are written in order of importance: summary first, then full results.
    """
    # Build results data once
    results_data = []
    for r in results:
        results_data.append(
            {
                "trial_id": int(r.trial_id),
                "params": {k: _normalize_jsonable(v) for k, v in dict(r.params).items()},
                "score": float(r.score),
                "sqn": float(r.sqn),
                "sharpe": float(r.sharpe),
                "sortino": float(r.sortino),
                "wfe": float(r.wfe),
                "trades": int(r.trades),
                "win_rate": float(r.win_rate),
                "max_drawdown_pct": float(r.max_drawdown_pct),
                "trailing_dd": float(r.trailing_dd),
                "apex_compliant": bool(r.apex_compliant),
                "total_pnl": float(r.total_pnl),
            }
        )

    # Sanitize for strict JSON compliance: replace NaN/Inf/-Inf with None.
    summary_jsonable = _sanitize_for_json(asdict(summary))
    results_jsonable = _sanitize_for_json(results_data)

    # Save summary JSON (most critical - save first)
    summary_path = output_dir / "summary.json"
    _atomic_write(summary_path, json.dumps(summary_jsonable, indent=2, default=str))

    # Save all results as JSON
    # NOTE: results_data can contain numpy scalars (np.int64/np.float64) depending on upstream.
    # Use `default=str` to guarantee serialization without crashing after long runs.
    results_path = output_dir / "all_results.json"
    _atomic_write(results_path, json.dumps(results_jsonable, indent=2, default=str))

    # Save as CSV for easy analysis
    csv_path = output_dir / "results.csv"
    df = pd.DataFrame(results_data)
    _atomic_write_csv(csv_path, df)

    # Save top 10
    top_path = output_dir / "top10.json"
    _atomic_write(top_path, json.dumps(results_jsonable[:10], indent=2, default=str))

    logger.info(f"Saved results atomically to {output_dir}")


def main() -> int:
    """Main entry point."""
    args = parse_args()

    if args.dry_run:
        # Dry run mode - just show config
        config_path = Path(args.config)
        if not config_path.exists():
            print(f"Error: Config file not found: {config_path}")
            return 1

        try:
            config = OptimizationConfig.from_yaml(config_path)
            print_dry_run(args, config)
            return 0
        except Exception as e:
            print(f"Error loading config: {e}")
            return 1

    # Full optimization run
    setup_logging(args.log_level)
    return run_optimization(args)


if __name__ == "__main__":
    sys.exit(main())
