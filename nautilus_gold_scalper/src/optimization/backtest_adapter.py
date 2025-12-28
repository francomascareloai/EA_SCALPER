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

import argparse
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
Sample: TypeAlias = int | float
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
    sample_rate: Sample = 1
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


def create_backtest_fn_from_cli(
    args: argparse.Namespace,
    config: object,
) -> BacktestFn:
    """Create a backtest function from optimize.py CLI/config objects.

    This keeps `scripts/optimize.py` lightweight by delegating the adapter logic
    to this module, while preserving the script's CLI-driven defaults.

    Notes:
    - `config` is treated as opaque; we only optionally read `config.search.seed`.
    - The returned callable is compatible with ApexOptimizer.
    """

    # Resolve feed mode (default from CLI unless overridden per rung)
    default_feed_raw = getattr(args, "feed", None)
    quick = bool(getattr(args, "quick", False))
    if default_feed_raw is None:
        default_feed: FeedMode = "bars" if quick else "ticks"
    else:
        # Fail-closed to supported modes only.
        default_feed = "bars" if str(default_feed_raw) == "bars" else "ticks"

    default_bars_file = getattr(args, "bars_file", None)
    default_bars_file_str = str(default_bars_file) if default_bars_file else None

    config_seed = getattr(getattr(config, "search", None), "seed", None)
    seed = int(getattr(args, "seed", config_seed if config_seed is not None else 42))

    adapter_cfg = BacktestAdapterConfig(
        initial_balance=float(getattr(args, "initial_balance", 50000.0)),
        ltf_minutes=int(getattr(args, "ltf_minutes", 1)),
        sample_rate=getattr(args, "sample_rate", getattr(args, "sample", 1)),
        seed=seed,
        feed_mode=default_feed,
        bars_file=default_bars_file_str,
    )

    return create_backtest_fn(adapter_cfg)


def create_backtest_fn(
    config: BacktestAdapterConfig | None = None,
    *,
    initial_balance: float = 50000.0,
    ltf_minutes: int = 1,
    sample_rate: Sample = 1,
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

        # NOTE: `params` may be either:
        # - nested dicts (ApexOptimizer expanded dotpaths), OR
        # - flat dotpath keys (e.g., {"execution.use_mtf": true}).
        #
        # Contract: We must NOT override YAML `fixed` values merged into params by ApexOptimizer.
        # execution_threshold
        # - Prefer explicit runtime override (execution.* / run.*),
        # - otherwise fall back to confluence thresholds.
        execution_threshold = _get_param_int_alias(
            params,
            (
                "execution.execution_threshold",
                "run.execution_threshold",
                "confluence.execution_threshold",
                "confluence.min_score_to_trade",
            ),
            cfg.execution_threshold,
        )

        use_session_filter = _get_param_bool_alias(
            params,
            (
                "execution.use_session_filter",
                "run.use_session_filter",
            ),
            cfg.use_session_filter,
        )

        use_regime_filter = _get_param_bool_alias(
            params,
            (
                "execution.use_regime_filter",
                "run.use_regime_filter",
            ),
            cfg.use_regime_filter,
        )

        use_mtf = _get_param_bool_alias(
            params,
            (
                "execution.use_mtf",
                "run.use_mtf",
            ),
            cfg.use_mtf,
        )

        use_footprint = _get_param_bool_alias(
            params,
            (
                "execution.use_footprint",
                "run.use_footprint",
            ),
            cfg.use_footprint,
        )

        # use_news_filter
        # Prefer explicit runtime override (execution.* / run.*), otherwise use YAML `news.enabled`.
        use_news_filter = _get_param_bool_alias(
            params,
            (
                "execution.use_news_filter",
                "run.use_news_filter",
                "news.enabled",
                "use_news_filter",
            ),
            cfg.use_news_filter,
        )

        # CRITICAL: Force-disable prop_firm for bars-only runs (not valid for Apex compliance)
        prop_firm_enabled = cfg.prop_firm_enabled
        if resolved_feed != "ticks":
            prop_firm_enabled = False

        # risk_per_trade (YAML uses `risk.max_risk_per_trade`)
        risk_per_trade = _get_param_float_alias(
            params,
            (
                "risk.max_risk_per_trade",
                "run.risk_per_trade",
            ),
            None,
        )

        # Default ltf_minutes from adapter config, allow YAML override.
        ltf_minutes = _get_param_int_alias(
            params,
            (
                "execution.ltf_bar_minutes",
                "run.ltf_bar_minutes",
            ),
            int(cfg.ltf_minutes),
        )
        if ltf_minutes <= 0:
            ltf_minutes = int(cfg.ltf_minutes)

        # Run the backtest
        _summary = runner.run(
            start_date=start_date,
            end_date=end_date,
            ltf_minutes=int(ltf_minutes),
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

    NOTE: Returns `_MISSING` when key is absent OR value is explicitly None.
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


def _get_from_section(section: object, key: str) -> object:
    if isinstance(section, dict) and key in section:
        v = section[key]
        return v if v is not None else _MISSING
    return _MISSING


def _get_param_int_alias(
    params: dict[str, Any],
    aliases: tuple[str, ...],
    default: int,
) -> int:
    for key in aliases:
        v = _get_value(params, key)
        if v is _MISSING:
            continue
        return _get_param_int({key: v}, key, default)
    return default


def _get_param_bool_alias(
    params: dict[str, Any],
    aliases: tuple[str, ...],
    default: bool,
) -> bool:
    for key in aliases:
        v = _get_value(params, key)
        if v is _MISSING:
            continue
        return _get_param_bool({key: v}, key, default)
    return default


def _get_param_float_alias(
    params: dict[str, Any],
    aliases: tuple[str, ...],
    default: float | None,
) -> float | None:
    for key in aliases:
        v = _get_value(params, key)
        if v is _MISSING:
            continue
        return _get_param_float({key: v}, key, default)
    return default


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
        return pd.Series(dtype=float, name="equity")

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
                        "failing closed (DD=100%%). invalid_ts=%d finite_equity=%s total=%d",
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
                    return equity_series

        # For Apex trailing DD validation we MUST use MTM equity.
        # Balance-only series (account report) or reconstructed equity-from-returns can materially
        # understate trailing DD and let unsafe candidates pass.
        logger.error(
            "CRITICAL: Cannot extract MTM equity curve from strategy DrawdownTracker. "
            "Returning empty series to fail closed (DD=100%%)."
        )
        return pd.Series(dtype=float, name="equity")

    except Exception as e:
        logger.error(f"Failed to extract equity: {type(e).__name__}: {e}")
        return pd.Series(dtype=float, name="equity")
