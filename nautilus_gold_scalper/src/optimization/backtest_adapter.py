"""
Backtest adapter for ApexOptimizer integration.

This module provides a reusable factory that produces `backtest_fn` callables
compatible with `ApexOptimizer`. The adapter wraps `BacktestRunner` and handles:
- Parameter dotpath expansion to nested dicts
- Trades DataFrame extraction (with required columns: timestamp, pnl, entry_time, exit_time)
- Mark-to-market equity series extraction (conservative pricing for Apex DD)

Usage:
    from src.optimization.backtest_adapter import create_backtest_fn

    backtest_fn = create_backtest_fn(
        initial_balance=50000.0,
        ltf_minutes=1,
        sample_rate=1,
    )

    trades_df, equity_series = backtest_fn(
        params={"execution.execution_threshold": 70},
        start_date="2020-01-01",
        end_date="2020-12-31",
    )
"""

from __future__ import annotations

import logging
import sys
from collections.abc import Callable
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path
from typing import TYPE_CHECKING, Any, Literal, TypeAlias

import numpy as np
import pandas as pd

# Ensure imports work regardless of current working directory.
_project_root = Path(__file__).resolve().parent.parent.parent
_repo_root = _project_root.parent
if str(_repo_root) not in sys.path:
    sys.path.insert(0, str(_repo_root))
if str(_project_root) not in sys.path:
    sys.path.insert(0, str(_project_root))

logger = logging.getLogger(__name__)

# Type alias for the backtest function signature expected by ApexOptimizer
FeedMode: TypeAlias = Literal["ticks", "bars"]
BacktestFn: TypeAlias = Callable[..., tuple[pd.DataFrame, pd.Series]]


if TYPE_CHECKING:
    pass


# Sentinel object for missing values (distinguishes None from absent)
_MISSING: object = object()


@lru_cache(maxsize=1)
def _get_backtest_runner() -> Any:
    """Thread-safe lazy import of BacktestRunner.

    Uses lru_cache to ensure single import even in multi-threaded context.
    Returns Any to avoid strict typing issues with dynamic imports.
    """
    from scripts.backtest.run_backtest import BacktestRunner

    return BacktestRunner


@dataclass(frozen=True)
class BacktestAdapterConfig:
    """Configuration for the backtest adapter.

    Attributes:
        initial_balance: Starting account balance in USD.
        ltf_minutes: Low timeframe bar aggregation period in minutes.
        sample_rate: Tick sample rate (1 = every tick, 10 = every 10th tick).
        seed: Random seed for reproducibility.
        feed_mode: Default feed mode ("ticks" for full fidelity, "bars" for fast prescreen).
        bars_file: Optional path to prebuilt bars file (for bars feed mode).
        use_session_filter: Enable session time filter.
        use_regime_filter: Enable regime detection filter.
        use_mtf: Enable multi-timeframe analysis.
        use_footprint: Enable footprint analysis.
        prop_firm_enabled: Enable Apex prop firm rules (DD/HWM enforcement).
        use_news_filter: Enable news event filter.
    """

    initial_balance: float = 50000.0
    ltf_minutes: int = 1
    sample_rate: int = 1
    seed: int = 42
    feed_mode: FeedMode = "ticks"
    bars_file: str | None = None
    use_session_filter: bool = True
    use_regime_filter: bool = True
    use_mtf: bool = False
    use_footprint: bool = True
    prop_firm_enabled: bool = True
    use_news_filter: bool = True
    # Default execution threshold (can be overridden by params)
    execution_threshold: int = 70


def create_backtest_fn(
    config: BacktestAdapterConfig | None = None,
    *,
    initial_balance: float = 50000.0,
    ltf_minutes: int = 1,
    sample_rate: int = 1,
    seed: int = 42,
    feed_mode: FeedMode = "ticks",
    bars_file: str | None = None,
) -> BacktestFn:
    """Create a backtest function compatible with ApexOptimizer.

    This factory returns a callable that:
    - Takes (params, start_date, end_date, feed_mode?, bars_file?) -> (trades_df, equity_series)
    - Handles dotpath expansion for nested parameter dicts
    - Extracts trades with required columns (timestamp, pnl, entry_time, exit_time)
    - Extracts mark-to-market equity series for Apex DD calculation

    Args:
        config: Full adapter configuration (takes precedence if provided).
        initial_balance: Starting account balance in USD.
        ltf_minutes: Low timeframe bar aggregation period.
        sample_rate: Tick sample rate.
        seed: Random seed for reproducibility.
        feed_mode: Default feed mode.
        bars_file: Optional path to prebuilt bars file.

    Returns:
        Callable compatible with ApexOptimizer.set_backtest_fn().

    Example:
        backtest_fn = create_backtest_fn(initial_balance=100000.0)
        optimizer = ApexOptimizer.from_yaml("config.yaml")
        optimizer.set_backtest_fn(backtest_fn)
        results = optimizer.run()
    """
    if config is not None:
        cfg = config
    else:
        cfg = BacktestAdapterConfig(
            initial_balance=initial_balance,
            ltf_minutes=ltf_minutes,
            sample_rate=sample_rate,
            seed=seed,
            feed_mode=feed_mode,
            bars_file=bars_file,
        )

    BR = _get_backtest_runner()

    def backtest_fn(
        params: dict[str, Any],
        start_date: str,
        end_date: str,
        *,
        feed_mode: str | None = None,
        bars_file: str | None = None,
    ) -> tuple[pd.DataFrame, pd.Series]:
        """Run a single backtest trial with given parameters.

        Args:
            params: Strategy parameter overrides (may be nested dicts or flat dotpaths).
            start_date: Training period start (YYYY-MM-DD).
            end_date: Training period end (YYYY-MM-DD).
            feed_mode: Override feed mode for this run.
            bars_file: Override bars file for this run.

        Returns:
            trades_df: DataFrame with columns [timestamp, pnl, entry_time, exit_time, ...].
            equity_series: Series indexed by time with cumulative MTM equity.
        """
        resolved_feed = str(feed_mode or cfg.feed_mode)
        resolved_bars_file = bars_file if bars_file is not None else cfg.bars_file

        runner = BR(
            initial_balance=cfg.initial_balance,
            log_level="ERROR",  # Quiet logging during optimization
            seed=cfg.seed,
        )

        # Extract execution parameters from params dict
        execution_threshold = _get_param_int(
            params, "execution.execution_threshold", cfg.execution_threshold
        )
        use_session_filter = _get_param_bool(
            params, "execution.use_session_filter", cfg.use_session_filter
        )
        use_regime_filter = _get_param_bool(
            params, "execution.use_regime_filter", cfg.use_regime_filter
        )
        use_mtf = _get_param_bool(params, "execution.use_mtf", cfg.use_mtf)
        use_footprint = _get_param_bool(params, "execution.use_footprint", cfg.use_footprint)
        use_news_filter = _get_param_bool(params, "news.enabled", cfg.use_news_filter)

        # CRITICAL: Force-disable prop_firm for bars-only runs (not valid for Apex compliance)
        prop_firm_enabled = cfg.prop_firm_enabled
        if resolved_feed != "ticks":
            prop_firm_enabled = False

        # Extract risk parameter if present
        risk_per_trade = _get_param_float(params, "risk.max_risk_per_trade", None)

        # Run the backtest
        _summary = runner.run(
            start_date=start_date,
            end_date=end_date,
            ltf_minutes=cfg.ltf_minutes,
            sample_rate=cfg.sample_rate,
            use_session_filter=use_session_filter,
            use_regime_filter=use_regime_filter,
            use_mtf=use_mtf,
            use_footprint=use_footprint,
            prop_firm_enabled=prop_firm_enabled,
            use_news_filter=use_news_filter,
            execution_threshold=execution_threshold,
            risk_per_trade=risk_per_trade,
            feed=resolved_feed,
            bars_file=resolved_bars_file,
            reports="none",
            return_summary=True,
            quiet=True,
            config_overrides=params,
        )

        # Extract trades and equity
        trades_df = _extract_trades_df(runner)
        equity_series = _extract_equity_series(runner, cfg.initial_balance)

        return trades_df, equity_series

    return backtest_fn


def _get_value(mapping: dict[str, Any], dotted_key: str) -> object:
    """Get a config value from either nested dicts or dotpath keys.

    Precedence:
    1) Exact key match in mapping (supports flat dotpaths)
    2) Nested lookup by splitting on '.'
    """
    if dotted_key in mapping:
        v = mapping[dotted_key]
        return v if v is not None else _MISSING

    cur: object = mapping
    for part in dotted_key.split("."):
        if not isinstance(cur, dict) or part not in cur:
            return _MISSING
        cur = cur[part]
    return cur if cur is not None else _MISSING


def _get_param_int(params: dict[str, Any], key: str, default: int) -> int:
    """Extract integer parameter with dotpath support."""
    val = _get_value(params, key)
    if val is _MISSING:
        return default
    if isinstance(val, (int, np.integer)):
        return int(val)
    if isinstance(val, float) and float(val).is_integer():
        return int(val)
    if isinstance(val, str):
        try:
            return int(val)
        except ValueError:
            return default
    return default


def _get_param_bool(params: dict[str, Any], key: str, default: bool) -> bool:
    """Extract boolean parameter with dotpath support."""
    val = _get_value(params, key)
    if val is _MISSING:
        return default
    if isinstance(val, (bool, np.bool_)):
        return bool(val)
    if isinstance(val, (int, np.integer)):
        return bool(int(val))
    if isinstance(val, str):
        s = val.strip().lower()
        if s in ("true", "1", "yes", "y", "on"):
            return True
        if s in ("false", "0", "no", "n", "off"):
            return False
    return default


def _get_param_float(params: dict[str, Any], key: str, default: float | None) -> float | None:
    """Extract float parameter with dotpath support."""
    val = _get_value(params, key)
    if val is _MISSING:
        return default
    if isinstance(val, (int, float, np.integer, np.floating)):
        return float(val)
    if isinstance(val, str):
        try:
            return float(val)
        except ValueError:
            return default
    return default


def _extract_trades_df(runner: Any) -> pd.DataFrame:
    """Extract trades DataFrame from BacktestRunner.

    Returns a DataFrame which MUST include:
    - `entry_time` (UTC datetime-like): used for WFA window assignment (decision time)
    - `exit_time` (UTC datetime-like): used for overnight checks and realized timing
    - `timestamp` (UTC datetime-like): legacy field (derived from entry_time)
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
        if "realized_pnl" in df.columns:
            pnl = df["realized_pnl"].astype(str).str.replace("USD", "", regex=False).str.strip()
            pnl = pd.to_numeric(pnl, errors="coerce")
        else:
            pnl = pd.Series([np.nan] * len(df), dtype=float)

        instrument_id = df["instrument_id"].astype(str) if "instrument_id" in df.columns else None

        # CRITICAL: Use entry_time for timestamp, NOT exit_time.
        # Using exit_time causes look-ahead bias in WFA.
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
        trades = trades.dropna(subset=["timestamp", "pnl"]).reset_index(drop=True)
        return trades

    except Exception as e:
        logger.warning(f"Failed to extract trades: {e}")
        return pd.DataFrame()


def _extract_equity_series(runner: Any, initial_balance: float) -> pd.Series:
    """Extract mark-to-market equity curve from BacktestRunner.

    CRITICAL: Uses DrawdownTracker history which has conservative MTM pricing
    (LONG uses BID, SHORT uses ASK) for accurate Apex trailing DD calculation.

    If MTM equity cannot be extracted, returns an empty series so validation
    can fail closed (DD=100% -> apex_compliant=False).
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
                timestamps = [h.timestamp for h in history]
                equities = [h.equity for h in history]
                series = pd.Series(equities, index=pd.DatetimeIndex(timestamps, tz="UTC"))
                return series

        # Fallback: compute equity from cumulative PnL + initial balance
        trades_df = _extract_trades_df(runner)
        if not trades_df.empty and "timestamp" in trades_df.columns and "pnl" in trades_df.columns:
            sorted_trades = trades_df.sort_values("timestamp")
            cumulative_pnl = sorted_trades["pnl"].cumsum()
            equity = initial_balance + cumulative_pnl
            series = pd.Series(
                equity.values,
                index=pd.DatetimeIndex(sorted_trades["timestamp"].values, tz="UTC"),
            )
            return series

        # Last resort: empty series (will fail closed)
        logger.warning("Could not extract MTM equity; returning empty series")
        return pd.Series(dtype=float)

    except Exception as e:
        logger.warning(f"Failed to extract equity: {e}")
        return pd.Series(dtype=float)
