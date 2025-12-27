"""
NautilusTrader Tick-Based Backtest for Gold Scalper.

Uses real XAUUSD tick data (25M+ records) with NautilusTrader native engine.
Ticks are fed as QuoteTicks and aggregated to LTF bars for strategy consumption.
"""

import copy
import json
import logging
import os
import random
import subprocess
import sys
import time
from collections.abc import Generator, Iterator
from dataclasses import dataclass
from datetime import datetime, timezone
from decimal import Decimal
from heapq import heappop, heappush
from pathlib import Path
from typing import Any, Literal, cast

import numpy as np
import pandas as pd
import yaml
from numpy.typing import NDArray

# Ensure imports work regardless of current working directory.
# - `src.*` lives under `nautilus_gold_scalper/src` (needs project root on sys.path)
# - `nautilus_gold_scalper.*` is imported as a namespace package (needs repo root on sys.path)
_project_root = Path(__file__).resolve().parent.parent.parent
_repo_root = _project_root.parent
sys.path.insert(0, str(_repo_root))
sys.path.insert(0, str(_project_root))

from nautilus_trader.backtest.engine import BacktestEngine as NautilusEngine
from nautilus_trader.backtest.models import (
    LatencyModel,
    OneTickSlippageFillModel,
    PerContractFeeModel,
    ThreeTierFillModel,
    TwoTierFillModel,
)
from nautilus_trader.config import BacktestEngineConfig, LoggingConfig, RiskEngineConfig
from nautilus_trader.model.currencies import USD, XAU
from nautilus_trader.model.data import Bar, BarSpecification, BarType, QuoteTick, capsule_to_list
from nautilus_trader.model.enums import (
    AccountType,
    AggregationSource,
    AssetClass,
    BarAggregation,
    OmsType,
    PriceType,
)
from nautilus_trader.model.identifiers import InstrumentId, Symbol, TraderId, Venue
from nautilus_trader.model.instruments import CurrencyPair, FuturesContract, Instrument
from nautilus_trader.model.objects import Money, Price, Quantity
from nautilus_trader.persistence.catalog import ParquetDataCatalog
from nautilus_trader.persistence.wranglers import BarDataWrangler, QuoteTickDataWrangler

from src.core.definitions import (
    WEIGHT_AMD_CYCLE,
    WEIGHT_FIB,
    WEIGHT_FOOTPRINT,
    WEIGHT_FVG,
    WEIGHT_LIQUIDITY_SWEEP,
    WEIGHT_MTF,
    WEIGHT_ORDER_BLOCK,
    WEIGHT_REGIME,
    WEIGHT_STRUCTURE,
)
from src.risk.prop_firm_manager import AccountTerminatedException
from src.strategies.gold_scalper_strategy import GoldScalperConfig, GoldScalperStrategy
from src.utils.metrics import MetricsCalculator

Sample = int | float
FeedMode = Literal["ticks", "bars"]
DataSource = Literal["auto", "parquet", "catalog"]


class TickSourceMismatchError(RuntimeError):
    """Raised when attempting to run a stride=1 fidelity comparison on a non-equivalent tick source."""


ReportsMode = Literal["none", "positions", "summary", "full"]
Product = Literal["xauusd", "mgc"]
Gateway = Literal["rithmic", "tradovate"]
BarsTimestampBasis = Literal["open", "close"]

_MISSING = object()

# Nautilus disallows MINUTE bars with step=60; use HOUR(1) instead.
# For MINUTE aggregation, supported steps are divisors of 60 (excluding 60 itself).
_MINUTE_BAR_STEPS: tuple[int, ...] = (1, 2, 3, 4, 5, 6, 10, 12, 15, 20, 30)

# Base latency models minimum network RTT (production always has non-zero RTT).
_DEFAULT_BASE_LATENCY_MS: int = 10


# ---------------------------------------------------------------------------
# Certification mode helpers (--certify)
# ---------------------------------------------------------------------------


class CertifyPreflightError(RuntimeError):
    """Raised when --certify preflight validation fails."""


def resolve_certify_output_dir(
    product: str,
    start: str,
    end: str,
    *,
    base_logs_dir: Path | None = None,
) -> Path:
    """
    Generate a unique output directory for certification artifacts.

    Format: logs/certify_<YYYYMMDD_HHMMSS>_<product>_<start>_<end>/

    Args:
        product: Product identifier (xauusd, mgc).
        start: Start date string (YYYY-MM-DD).
        end: End date string (YYYY-MM-DD).
        base_logs_dir: Base logs directory. Defaults to project logs/.

    Returns:
        Path to the unique output directory (created).
    """
    if base_logs_dir is None:
        base_logs_dir = Path(__file__).resolve().parent.parent.parent / "logs"

    timestamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
    # Sanitize date strings (remove any non-alphanumeric chars except dash)
    start_safe = "".join(c for c in start if c.isalnum() or c == "-")
    end_safe = "".join(c for c in end if c.isalnum() or c == "-")
    product_safe = "".join(c for c in product if c.isalnum())

    dir_name = f"certify_{timestamp}_{product_safe}_{start_safe}_{end_safe}"
    out_dir = base_logs_dir / dir_name
    out_dir.mkdir(parents=True, exist_ok=True)
    return out_dir


def certify_preflight_checks(
    *,
    feed: str,
    no_prop: bool,
) -> None:
    """
    Validate preflight conditions for --certify mode.

    Raises:
        CertifyPreflightError: If any preflight check fails.
    """
    # 1. Feed must be ticks (bar-only mode is not valid for prop-firm compliance)
    if feed != "ticks":
        raise CertifyPreflightError(
            f"--certify requires --feed=ticks (got {feed!r}). "
            "Bar-only mode is not valid for Apex prop-firm MTM equity/HWM enforcement."
        )

    # 2. Cannot disable prop-firm rules in certification mode
    if no_prop:
        raise CertifyPreflightError(
            "--certify is incompatible with --no-prop. "
            "Certification requires prop-firm rules enabled for compliance validation."
        )


def _get_git_head() -> str | None:
    """Best-effort retrieval of current git HEAD commit hash."""
    try:
        result = subprocess.run(
            ["git", "rev-parse", "HEAD"],
            capture_output=True,
            text=True,
            timeout=5,
            check=False,
        )
        if result.returncode == 0:
            stdout: str = result.stdout
            return stdout.strip()[:12]  # Short hash
    except (OSError, subprocess.TimeoutExpired):
        pass
    return None


def _bar_spec_from_minutes(*, minutes: int) -> BarSpecification:
    minutes_int = int(minutes)
    if minutes_int <= 0:
        raise ValueError(f"Invalid timeframe minutes={minutes!r} (must be > 0)")

    if minutes_int % 60 == 0:
        hours = minutes_int // 60
        if hours <= 0:
            raise ValueError(f"Invalid timeframe minutes={minutes!r} (hours must be > 0)")
        return BarSpecification(
            step=hours, aggregation=BarAggregation.HOUR, price_type=PriceType.MID
        )

    if minutes_int not in _MINUTE_BAR_STEPS:
        raise ValueError(
            f"Invalid timeframe minutes={minutes_int}: supported minute steps are divisors of 60 "
            "(1,2,3,4,5,6,10,12,15,20,30) or any multiple of 60 (hour bars)."
        )

    return BarSpecification(
        step=minutes_int, aggregation=BarAggregation.MINUTE, price_type=PriceType.MID
    )


def _bar_type_from_minutes(
    *, instrument_id: InstrumentId, minutes: int, aggregation_source: AggregationSource
) -> BarType:
    return BarType(
        instrument_id=instrument_id,
        bar_spec=_bar_spec_from_minutes(minutes=minutes),
        aggregation_source=aggregation_source,
    )


def _deep_update(dst: dict[str, Any], src: dict[str, Any]) -> dict[str, Any]:
    """Recursively update nested dicts (in-place), returning dst."""
    for key, value in src.items():
        if isinstance(value, dict) and isinstance(dst.get(key), dict):
            _deep_update(cast(dict[str, Any], dst[key]), cast(dict[str, Any], value))
        else:
            dst[key] = value
    return dst


def _parse_bool(value: Any, default: bool) -> bool:
    """Parse a boolean value from YAML config, handling string "true"/"false".

    CRITICAL: bool("false") == True in Python!
    This helper correctly handles string representations from YAML configs.

    Args:
        value: The value from config (could be bool, str, int, or None).
        default: Default value if value is None.

    Returns:
        Parsed boolean value.
    """
    if value is None:
        return default
    if isinstance(value, bool):
        return value
    if isinstance(value, str):
        lower = value.lower().strip()
        if lower in ("true", "1", "yes", "on"):
            return True
        if lower in ("false", "0", "no", "off"):
            return False
        # Invalid string - use default
        return default
    if isinstance(value, int):
        return bool(value)
    return default


def _parse_bars_timestamp_basis(value: Any, *, field: str) -> BarsTimestampBasis:
    """Parse bars timestamp basis.

    Supported:
    - "open": timestamps represent bar start (requires +bar_duration shift to close).
    - "close": timestamps already represent bar close (no shift).

    Fail-closed: invalid values raise ValueError.
    """
    if isinstance(value, str):
        s = value.strip().lower()
        if s in ("open", "close"):
            return cast(BarsTimestampBasis, s)
    raise ValueError(f"{field} must be one of: 'open', 'close' (got {value!r})")


def _bars_timestamp_basis_from_execution_cfg(exec_cfg: dict[str, Any]) -> BarsTimestampBasis:
    raw = exec_cfg.get("bars_timestamp_basis")
    if raw is None:
        # Default preserves historical behavior: assume bar-open timestamps and shift to close.
        return "open"
    return _parse_bars_timestamp_basis(raw, field="execution.bars_timestamp_basis")


@dataclass(frozen=True, slots=True)
class BacktestSummary:
    start_date: str
    end_date: str
    feed: FeedMode
    source: DataSource
    sample: float
    initial_balance: float
    final_balance: float
    total_pnl: float
    fills: int
    trades: int
    terminated: bool
    max_drawdown_pct: float | None
    sharpe: float | None
    sqn: float | None


def find_tick_file() -> Path:
    """Locate a tick file under Python_Agent_Hub/ml_pipeline/data."""
    root = Path(__file__).parent.parent.parent / "Python_Agent_Hub" / "ml_pipeline" / "data"
    candidates = list(root.glob("**/*tick*.parquet")) + list(root.glob("**/*ticks*.parquet"))
    if not candidates:
        candidates = list(root.glob("**/*tick*.csv")) + list(root.glob("**/*ticks*.csv"))
    if not candidates:
        raise FileNotFoundError(f"Nenhum arquivo de ticks encontrado em {root}")
    # choose the largest (most complete)
    return max(candidates, key=lambda p: p.stat().st_size)


def create_xauusd_instrument(venue: Venue) -> CurrencyPair:
    """Create XAUUSD instrument for backtesting."""
    return CurrencyPair(
        instrument_id=InstrumentId(Symbol("XAU/USD"), venue),
        raw_symbol=Symbol("XAUUSD"),
        base_currency=XAU,
        quote_currency=USD,
        price_precision=2,
        size_precision=2,
        price_increment=Price.from_str("0.01"),
        # Quantity is in XAU (oz). Standard lot is 100 oz; micro-lot 0.01 = 1 oz.
        # Keep precision aligned with Nautilus correctness checks (size_precision == size_increment.precision).
        size_increment=Quantity.from_str("0.01"),
        lot_size=Quantity.from_str("100.00"),
        max_quantity=Quantity.from_str("10000.00"),
        min_quantity=Quantity.from_str("1.00"),
        max_price=Price.from_str("10000.00"),
        min_price=Price.from_str("100.00"),
        margin_init=Decimal("0.05"),
        margin_maint=Decimal("0.03"),
        # For prop-style backtests we model commissions explicitly via our ExecutionModel
        # (commission_per_contract per lot). Percentage maker/taker fees would double-charge.
        maker_fee=Decimal("0.0"),
        taker_fee=Decimal("0.0"),
        ts_event=0,
        ts_init=0,
    )


def create_mgc_instrument(venue: Venue) -> FuturesContract:
    """Create CME E-micro Gold (MGC) futures contract instrument for backtesting.

    Note: Our dataset is spot XAUUSD. When using `product="mgc"` we approximate MGC
    economics (tick size + multiplier + commissions) on top of spot-derived prices.
    """
    # MGC contract: 10 troy ounces, quoted in USD per oz.
    # Tick size: 0.10 => tick value: $1.00 per contract (0.10 * 10).
    # Set expiration far in the future so the SimulatedExchange doesn't reject orders
    # as "expired" when backtesting historical spot-derived prices (e.g., 2020+).
    far_future_ns = 4_102_444_800_000_000_000  # 2100-01-01T00:00:00Z in ns
    return FuturesContract(
        instrument_id=InstrumentId(Symbol("MGC"), venue),
        raw_symbol=Symbol("MGC"),
        asset_class=AssetClass.COMMODITY,
        currency=USD,
        price_precision=1,
        price_increment=Price.from_str("0.1"),
        multiplier=Quantity.from_str("10"),
        lot_size=Quantity.from_str("1"),
        underlying="Gold",
        activation_ns=0,
        expiration_ns=far_future_ns,
        ts_event=0,
        ts_init=0,
        # For prop-style backtests we model commissions explicitly via our ExecutionModel.
        maker_fee=Decimal("0.0"),
        taker_fee=Decimal("0.0"),
        exchange="XCME",
    )


def apex_commission_per_side(product: Product, gateway: Gateway) -> float:
    """Backward-compatible wrapper.

    Prefer `nautilus_gold_scalper.src.execution.commission_schedule` for new code.
    """
    from nautilus_gold_scalper.src.execution.commission_schedule import commission_per_side_usd

    return float(commission_per_side_usd(profile="apex", product=product, gateway=gateway))


def _quantize_to_tick(
    values: NDArray[np.float64], tick: float, mode: Literal["nearest", "floor", "ceil"]
) -> NDArray[np.float64]:
    if tick <= 0:
        return values
    scaled = values / tick
    if mode == "nearest":
        q = np.rint(scaled)
    elif mode == "floor":
        q = np.floor(scaled + 1e-9)
    elif mode == "ceil":
        q = np.ceil(scaled - 1e-9)
    else:  # pragma: no cover
        raise ValueError(f"Unknown quantize mode: {mode}")
    return q * tick


def load_tick_data(
    filepath: str,
    start_date: str | None = None,
    end_date: str | None = None,
    sample: Sample = 1,
) -> pd.DataFrame:
    """Load tick data from a single Parquet file with column pruning and optional time filtering.

    Note:
        When `sample` implies uniform down-sampling (step > 1), we drop ticks deterministically
        (take every Nth row). This can miss price spikes and underestimate volatility, so treat
        results as *screening only* and prefer the stride20 dataset or a lower sample rate for
        final validation.
    """
    print(f"Loading tick data from {filepath}...")

    # Use Arrow dataset scanning for filter pushdown when possible.
    # This is critical for performance with large Parquet files.
    try:
        import pyarrow.dataset as ds

        dataset = ds.dataset(filepath, format="parquet")
        expr = None

        if start_date:
            start_ts = pd.Timestamp(start_date, tz="UTC").to_datetime64()
            expr = (
                (ds.field("datetime") >= np.datetime64(start_ts))
                if expr is None
                else expr & (ds.field("datetime") >= np.datetime64(start_ts))
            )
        if end_date:
            end_ts = (pd.Timestamp(end_date, tz="UTC") + pd.Timedelta(days=1)).to_datetime64()
            expr = (
                (ds.field("datetime") < np.datetime64(end_ts))
                if expr is None
                else expr & (ds.field("datetime") < np.datetime64(end_ts))
            )

        table = dataset.to_table(columns=["datetime", "bid", "ask"], filter=expr)
        df = table.to_pandas()
    except Exception:
        # Fallback to pandas reader (slower, but keeps script resilient).
        df = pd.read_parquet(filepath, columns=["datetime", "bid", "ask"])

    if df["datetime"].dt.tz is None:
        df["datetime"] = pd.to_datetime(df["datetime"], utc=True)
    else:
        df["datetime"] = df["datetime"].dt.tz_convert("UTC")

    # Basic validation: no NaN, monotonic increasing timestamps
    if df["datetime"].isna().any():
        raise ValueError("Tick data contains NaN datetimes")
    if not df["datetime"].is_monotonic_increasing:
        df = df.sort_values("datetime")
        if not df["datetime"].is_monotonic_increasing:
            raise ValueError("Tick data timestamps are not monotonic even after sort")

    # EDGE-4: De-duplicate duplicate timestamps after sort
    # Duplicates can appear in some data sources and can break downstream "one tick per ts" assumptions.
    # Keep the first occurrence to preserve causality.
    if df["datetime"].duplicated().any():
        n_before = len(df)
        df = df[~df["datetime"].duplicated(keep="first")].copy()
        n_removed = n_before - len(df)
        if n_removed > 0:
            print(f"[WARN] Removed {n_removed:,} duplicate-timestamp ticks")

    if df[["bid", "ask"]].isna().any().any():
        raise ValueError("Tick data contains NaN bid/ask values")

    # Spread sanity: bid must be < ask (no crossed markets)
    # Filter out invalid ticks instead of failing (small number is acceptable)
    invalid_spread = df["bid"] >= df["ask"]
    n_invalid = invalid_spread.sum()
    if n_invalid > 0:
        pct_invalid = n_invalid / len(df) * 100
        if pct_invalid > 0.1:  # More than 0.1% invalid = data quality issue
            raise ValueError(
                f"Data quality issue: {n_invalid:,} ticks ({pct_invalid:.3f}%) have bid >= ask"
            )
        print(f"[WARN] Filtered {n_invalid:,} ticks with invalid spread (bid >= ask)")
        df = df[~invalid_spread].copy()

    # Price range sanity for XAUUSD (gold typically $200-$5000/oz historically)
    # Filter out outliers instead of failing (small number is acceptable)
    MIN_PRICE, MAX_PRICE = 200.0, 10000.0
    out_of_range = (df["bid"] < MIN_PRICE) | (df["ask"] > MAX_PRICE)
    n_bad = out_of_range.sum()
    if n_bad > 0:
        pct_bad = n_bad / len(df) * 100
        if pct_bad > 0.1:  # More than 0.1% = data quality issue
            sample_bad = df[out_of_range].head(3)[["datetime", "bid", "ask"]].to_string()
            raise ValueError(
                f"Data quality issue: {n_bad:,} ticks ({pct_bad:.3f}%) out of price range\n{sample_bad}"
            )
        print(f"[WARN] Filtered {n_bad:,} ticks with price out of range ({MIN_PRICE}-{MAX_PRICE})")
        df = df[~out_of_range].copy()

    step = sample_to_step(sample)
    if step > 1:
        import warnings

        warnings.warn(
            f"Uniform tick sampling (step={step}) may miss price spikes and underestimate volatility. "
            "Consider using stride20 dataset or lower sample rate for final validation.",
            UserWarning,
            stacklevel=2,
        )
        df = df.iloc[::step].copy()

    if len(df) == 0:
        raise ValueError(f"No data found for date range: {start_date} to {end_date}")

    print(f"Loaded {len(df):,} ticks from {df['datetime'].iloc[0]} to {df['datetime'].iloc[-1]}")
    return df


def sample_to_step(sample: Sample) -> int:
    """Normalize sampling input to a 'take every Nth' step.

    - `sample` as int >= 1: take every Nth tick.
    - `sample` as float 0 < x <= 1: approximate fraction (e.g. 0.1 ~= every 10th tick).
    """
    if isinstance(sample, bool):  # pragma: no cover
        raise ValueError("sample must be int or float, not bool")
    sample_f = float(sample)
    if sample_f <= 0:
        raise ValueError("sample must be > 0")
    if sample_f < 1:
        return max(1, int(round(1.0 / sample_f)))
    return max(1, int(round(sample_f)))


def _build_fill_model(fill_model: str | None, *, seed: int) -> object | None:
    """Construct a Nautilus fill model with deterministic seeding.

    NOTE: Nautilus FillModels seed Python's global RNG in __init__.
    Passing `random_seed` is mandatory to avoid OS-entropy seeding which breaks determinism.
    """
    resolved = str(fill_model or "").strip().lower()
    if resolved in ("", "none", "off"):
        return None
    if resolved in ("one_tick", "one-tick", "1tick", "1_tick"):
        return cast(object, OneTickSlippageFillModel(random_seed=int(seed)))
    if resolved in ("two_tier", "two-tier", "2tier", "2_tier"):
        return cast(object, TwoTierFillModel(random_seed=int(seed)))
    if resolved in ("three_tier", "three-tier", "3tier", "3_tier", "realistic"):
        return cast(object, ThreeTierFillModel(random_seed=int(seed)))
    raise ValueError(f"Unsupported fill_model={resolved!r}")


def _merge_sorted_quote_ticks(ticks_lists: list[list[QuoteTick]]) -> list[QuoteTick]:
    """K-way merge QuoteTicks lists by ts_event (nanoseconds).

    Assumes each list is already sorted by QuoteTick.ts_event.
    """
    if not ticks_lists:
        return []

    total = sum(len(lst) for lst in ticks_lists)
    if total == 0:
        return []

    heap: list[tuple[int, int, int, QuoteTick]] = []
    for list_index, ticks in enumerate(ticks_lists):
        if not ticks:
            continue
        qt0 = ticks[0]
        heappush(heap, (int(qt0.ts_event), list_index, 0, qt0))

    merged: list[QuoteTick] = []
    append = merged.append
    while heap:
        _, list_index, tick_index, tick = heappop(heap)
        append(tick)
        next_index = tick_index + 1
        ticks = ticks_lists[list_index]
        if next_index < len(ticks):
            nxt = ticks[next_index]
            heappush(heap, (int(nxt.ts_event), list_index, next_index, nxt))

    return merged


def build_ticks_with_wrangler(
    df: pd.DataFrame,
    instrument: Instrument,
    latency_ms: int,
    default_volume: float = 1.0,
    *,
    spread_multiplier: float = 1.0,
) -> list[QuoteTick]:
    """Convert dataframe (datetime/bid/ask) to QuoteTicks using Cython wrangler.

    For performance, we avoid per-tick Python loops.

    Notes:
    - Spread can be stressed via `spread_multiplier`, which scales the (ask-bid) spread
      while preserving the mid price. This is used for hostile execution smoke tests.
    - Slippage/commission/latency are modeled in the execution layer via strategy config
      (not by mutating feed).
    """
    if df.empty:
        return []

    wrangler = QuoteTickDataWrangler(instrument)

    # Reset index to avoid index alignment issues when constructing new DataFrame
    df_reset = df.reset_index(drop=True)
    # If instrument tick size is coarser than our dataset (e.g., MGC tick 0.10),
    # quantize bid/ask to valid increments. Use floor for bid, ceil for ask to
    # preserve a non-negative spread.
    try:
        tick = float(instrument.price_increment.as_double())
    except Exception:
        tick = 0.0
    bid = df_reset["bid"].astype(float).values
    ask = df_reset["ask"].astype(float).values
    if tick > 0:
        bid = _quantize_to_tick(bid, tick=tick, mode="floor")
        ask = _quantize_to_tick(ask, tick=tick, mode="ceil")
    tick_df = pd.DataFrame(
        {
            "bid_price": bid,
            "ask_price": ask,
            "bid_size": default_volume,
            "ask_size": default_volume,
        },
        index=pd.DatetimeIndex(df_reset["datetime"].values, name="timestamp"),
    )

    ticks = wrangler.process(
        tick_df, default_volume=default_volume, ts_init_delta=int(max(0, latency_ms)) * 1_000_000
    )
    return cast(list[QuoteTick], ticks)


def load_bars_csv(
    filepath: Path,
    start_date: str,
    end_date: str,
    *,
    ltf_minutes: int,
    timestamp_basis: BarsTimestampBasis,
) -> pd.DataFrame:
    """Load bars file (CSV or Parquet) into an OHLCV DataFrame indexed by UTC timestamp.

    Temporal correctness:
    - If the input timestamp represents bar *start* ("open"), shift the index forward by the
      bar duration so downstream logic treats OHLC as known only at bar close.
    - If the input timestamp represents bar *close* ("close"), DO NOT shift.

    Supported inputs:
    - FTMO-style CSV with `Date` (YYYYMMDD) + `Time` (HH:MM:SS) and `Open/High/Low/Close[/Volume]`
    - CSV/Parquet with a `timestamp` or `datetime` column plus `open/high/low/close[/volume]`
    """
    if filepath.suffix.lower() in {".parquet", ".pq"}:
        df = pd.read_parquet(filepath)
    else:
        df = pd.read_csv(filepath)

    ts_col = None
    if "timestamp" in df.columns:
        ts_col = "timestamp"
    elif "datetime" in df.columns:
        ts_col = "datetime"

    if ts_col is not None:
        ts = pd.to_datetime(df[ts_col], utc=True, errors="coerce")
        df = df.assign(timestamp=ts).dropna(subset=["timestamp"]).set_index("timestamp")
    else:
        if "Date" not in df.columns or "Time" not in df.columns:
            raise ValueError(
                "Bars file must contain `timestamp`/`datetime` or `Date`+`Time` columns"
            )
        ts = pd.to_datetime(
            df["Date"].astype(str) + " " + df["Time"].astype(str),
            format="%Y%m%d %H:%M:%S",
            utc=True,
            errors="coerce",
        )
        df = df.assign(timestamp=ts).dropna(subset=["timestamp"]).set_index("timestamp")

    rename_map = {
        "Open": "open",
        "High": "high",
        "Low": "low",
        "Close": "close",
        "Volume": "volume",
        "OPEN": "open",
        "HIGH": "high",
        "LOW": "low",
        "CLOSE": "close",
        "VOLUME": "volume",
    }
    df = df.rename(columns=rename_map)
    for col in ("open", "high", "low", "close"):
        if col not in df.columns:
            raise ValueError(f"Bars file missing column: {col}")
    if "volume" not in df.columns:
        df["volume"] = 0
    df = df[["open", "high", "low", "close", "volume"]]

    if df.isna().any().any():
        raise ValueError("Bar data contains NaN values")
    if not df.index.is_monotonic_increasing:
        df = df.sort_index()
        if not df.index.is_monotonic_increasing:
            raise ValueError("Bar data timestamps not monotonic even after sort")

    if ltf_minutes <= 0:
        raise ValueError(f"ltf_minutes must be positive, got {ltf_minutes}")

    if timestamp_basis == "open":
        # Assume bars are timestamped by bar *start* and shift to bar close to
        # avoid look-ahead when consuming OHLC in the strategy.
        df.index = pd.to_datetime(df.index, utc=True) + pd.Timedelta(minutes=int(ltf_minutes))
    elif timestamp_basis == "close":
        # Bars already labeled at bar close; do not shift.
        df.index = pd.to_datetime(df.index, utc=True)
    else:  # pragma: no cover
        raise ValueError(f"Invalid timestamp_basis={timestamp_basis!r}")

    # Sanity check: for contiguous intraday data, the most common step should match the bar duration.
    # (Allow gaps for weekends/holidays by only checking short deltas.)
    if len(df.index) >= 3:
        deltas = df.index.to_series().diff().dropna()
        expected = pd.Timedelta(minutes=int(ltf_minutes))
        short = deltas[deltas <= expected * 2]
        if not short.empty:
            most_common = short.value_counts().index[0]
            if most_common != expected:
                raise ValueError(
                    f"Bars timestamps step mismatch: expected {expected}, most_common={most_common}. "
                    f"timestamp_basis={timestamp_basis!r} may be wrong for this file."
                )

    start_ts = pd.Timestamp(start_date, tz="UTC")
    end_ts = pd.Timestamp(end_date, tz="UTC") + pd.Timedelta(days=1)
    df = df[(df.index >= start_ts) & (df.index < end_ts)]
    if df.empty:
        raise ValueError(f"No bars in requested window: {start_date}..{end_date}")
    return df


def load_yaml_config(config_path: Path) -> dict[str, Any]:
    """Load YAML config if present, else return empty dict."""
    if not config_path.exists():
        return {}
    try:
        with open(config_path, encoding="utf-8") as f:
            data = yaml.safe_load(f)
        if data is None:
            return {}
        if not isinstance(data, dict):
            raise ValueError(f"YAML root must be a mapping, got {type(data).__name__}")
        return data
    except Exception as exc:
        print(f"WARNING: Could not load config {config_path}: {exc}")
        return {}


def build_strategy_config(
    cfg: dict[str, Any],
    bar_type: BarType,
    instrument_id: InstrumentId,
    *,
    ltf_minutes: int,
) -> GoldScalperConfig:
    """Build GoldScalperConfig from YAML dict + defaults."""

    def _infer_slippage_in_fills(execution_cfg: dict[str, Any]) -> bool:
        # If the runner is configured to use an engine FillModel, then fill prices already
        # include slippage (and strategy-side slippage cash adjustment must be disabled).
        v = execution_cfg.get("fill_model", "")
        s = str(v).strip().lower()
        return s not in ("", "none", "off")

    def _infer_fees_in_account(execution_cfg: dict[str, Any]) -> bool:
        # If the runner will attach an engine FeeModel, then the account equity already
        # reflects commissions (and strategy-side commission cash adjustment must be disabled).
        commission = execution_cfg.get("commission_per_contract", 0.0)
        try:
            return float(commission) != 0.0
        except Exception:
            return False

    confluence_cfg = cfg.get("confluence", {}) if isinstance(cfg, dict) else {}
    risk_cfg = cfg.get("risk", {}) if isinstance(cfg, dict) else {}
    news_cfg = cfg.get("news", {}) if isinstance(cfg, dict) else {}
    spread_cfg = cfg.get("spread", {}) if isinstance(cfg, dict) else {}
    exec_cfg = cfg.get("execution", {}) if isinstance(cfg, dict) else {}
    session_cfg = cfg.get("session", {}) if isinstance(cfg, dict) else {}
    structure_cfg = cfg.get("structure", {}) if isinstance(cfg, dict) else {}
    ob_cfg_raw = cfg.get("order_blocks", cfg.get("ob", {})) if isinstance(cfg, dict) else {}
    fvg_cfg_raw = cfg.get("fvg", {}) if isinstance(cfg, dict) else {}
    sweeps_cfg_raw = (
        cfg.get("liquidity_sweeps", cfg.get("sweeps", {})) if isinstance(cfg, dict) else {}
    )

    ob_cfg = ob_cfg_raw if isinstance(ob_cfg_raw, dict) else {}
    fvg_cfg = fvg_cfg_raw if isinstance(fvg_cfg_raw, dict) else {}
    sweeps_cfg = sweeps_cfg_raw if isinstance(sweeps_cfg_raw, dict) else {}
    amd_cfg = cfg.get("amd", {}) if isinstance(cfg, dict) else {}
    mtf_cfg = cfg.get("mtf", {}) if isinstance(cfg, dict) else {}
    footprint_cfg = cfg.get("footprint", {}) if isinstance(cfg, dict) else {}
    regime_cfg = cfg.get("regime", {}) if isinstance(cfg, dict) else {}
    selector_cfg = cfg.get("selector", {}) if isinstance(cfg, dict) else {}
    spreadmon_cfg = cfg.get("spread_monitor", {}) if isinstance(cfg, dict) else {}
    time_cfg = cfg.get("time", {}) if isinstance(cfg, dict) else {}
    cb_cfg = cfg.get("circuit_breaker", {}) if isinstance(cfg, dict) else {}
    consistency_cfg = cfg.get("consistency", {}) if isinstance(cfg, dict) else {}
    telemetry_cfg = cfg.get("telemetry", {}) if isinstance(cfg, dict) else {}
    telemetry_capture = telemetry_cfg.get("capture", {}) if isinstance(telemetry_cfg, dict) else {}
    ml_cfg = cfg.get("ml", {}) if isinstance(cfg, dict) else {}

    confluence_weights = (
        confluence_cfg.get("weights", {}) if isinstance(confluence_cfg, dict) else {}
    )

    execution_threshold = confluence_cfg.get(
        "execution_threshold", confluence_cfg.get("min_score_to_trade", 70)
    )

    weight_defaults: dict[str, float] = {
        "confluence_weight_structure": float(WEIGHT_STRUCTURE),
        "confluence_weight_regime": float(WEIGHT_REGIME),
        "confluence_weight_order_block": float(WEIGHT_ORDER_BLOCK),
        "confluence_weight_fvg": float(WEIGHT_FVG),
        "confluence_weight_liquidity_sweep": float(WEIGHT_LIQUIDITY_SWEEP),
        "confluence_weight_amd_cycle": float(WEIGHT_AMD_CYCLE),
        "confluence_weight_fib": float(WEIGHT_FIB),
        "confluence_weight_mtf": float(WEIGHT_MTF),
        "confluence_weight_footprint": float(WEIGHT_FOOTPRINT),
    }

    def _first_present(mapping: object, keys: tuple[str, ...]) -> object:
        if not isinstance(mapping, dict):
            return _MISSING
        for k in keys:
            if k in mapping:
                v = mapping[k]
                if v is not None:
                    return v
        return _MISSING

    def _weight(
        *,
        field_name: str,
        weights_keys: tuple[str, ...],
        legacy_keys: tuple[str, ...],
    ) -> float:
        """Resolve confluence weight, preserving explicit 0 values."""
        default = float(weight_defaults.get(field_name, 0.0))
        v = _first_present(confluence_weights, weights_keys)
        if v is _MISSING:
            v = _first_present(confluence_cfg, legacy_keys)
        if v is _MISSING:
            return default
        if isinstance(v, (int, float)):
            return float(v)
        if isinstance(v, str):
            try:
                return float(v)
            except Exception:
                return default
        return default

    # Derive time cutoffs with fallback to execution config
    cutoff_str = exec_cfg.get("flatten_time_et", time_cfg.get("cutoff_et", "16:59"))
    warning_str = time_cfg.get("warning_et", "16:00")
    urgent_str = time_cfg.get("urgent_et", "16:30")
    emergency_str = time_cfg.get("emergency_et", "16:55")

    max_spread_points = int(
        exec_cfg.get("max_spread_points", spread_cfg.get("max_spread_points", 80))
    )
    max_spread_pips = float(spreadmon_cfg.get("max_spread_pips", max_spread_points / 10.0))

    # Derive multi-timeframe bar types from the primary LTF bar type.
    # Without these, BaseGoldStrategy.on_bar() will never route MTF/HTF bars, leaving
    # the MTF-driven OB/FVG inputs empty.
    use_mtf = _parse_bool(exec_cfg.get("use_mtf"), default=True)
    require_htf_align = _parse_bool(exec_cfg.get("require_htf_align"), default=True)
    agg_source = bar_type.aggregation_source

    # Keep timeframes consistent across LTF experiments.
    # Default hierarchy: LTF < MTF < HTF.
    # We intentionally restrict timeframes to the `MTFManager.Timeframe` enum set.
    # This keeps runner inference consistent with strategy + prevents bar-type collisions.
    ltf_minutes_int = max(1, int(ltf_minutes))

    SUPPORTED_TIMEFRAME_MINUTES = (1, 5, 15, 30, 60, 240, 1440)

    def _next_supported_minutes(*, gt_minutes: int) -> int:
        for candidate in SUPPORTED_TIMEFRAME_MINUTES:
            if candidate > gt_minutes:
                return candidate
        raise ValueError(
            f"No supported timeframe minutes greater than {gt_minutes}. "
            f"Supported: {SUPPORTED_TIMEFRAME_MINUTES}"
        )

    if ltf_minutes_int not in SUPPORTED_TIMEFRAME_MINUTES:
        raise ValueError(
            f"Unsupported LTF minutes: {ltf_minutes_int}. Supported: {SUPPORTED_TIMEFRAME_MINUTES}"
        )

    need_htf_data = bool(use_mtf) or bool(require_htf_align)

    # Resolve MTF minutes.
    mtf_minutes = _next_supported_minutes(gt_minutes=ltf_minutes_int)
    if use_mtf and exec_cfg.get("mtf_bar_minutes") is not None:
        mtf_candidate = int(exec_cfg.get("mtf_bar_minutes"))
        if mtf_candidate <= ltf_minutes_int:
            raise ValueError(
                f"execution.mtf_bar_minutes must be > LTF ({ltf_minutes_int}), got {mtf_candidate}"
            )
        if mtf_candidate not in SUPPORTED_TIMEFRAME_MINUTES:
            raise ValueError(
                f"Unsupported execution.mtf_bar_minutes: {mtf_candidate}. "
                f"Supported: {SUPPORTED_TIMEFRAME_MINUTES}"
            )
        _bar_spec_from_minutes(minutes=mtf_candidate)
        mtf_minutes = mtf_candidate

    # Resolve HTF minutes.
    # Default: pick the next supported bucket strictly greater than max(LTF,MTF).
    htf_minutes = _next_supported_minutes(gt_minutes=max(ltf_minutes_int, mtf_minutes))
    if need_htf_data and exec_cfg.get("htf_bar_minutes") is not None:
        htf_candidate = int(exec_cfg.get("htf_bar_minutes"))
        if htf_candidate <= max(ltf_minutes_int, mtf_minutes):
            raise ValueError(
                f"execution.htf_bar_minutes must be > max(LTF,MTF) ({max(ltf_minutes_int, mtf_minutes)}), got {htf_candidate}"
            )
        if htf_candidate not in SUPPORTED_TIMEFRAME_MINUTES:
            raise ValueError(
                f"Unsupported execution.htf_bar_minutes: {htf_candidate}. "
                f"Supported: {SUPPORTED_TIMEFRAME_MINUTES}"
            )
        _bar_spec_from_minutes(minutes=htf_candidate)
        htf_minutes = htf_candidate

    # Safety: prevent bar-type collisions (BaseStrategy routes HTF before MTF).
    if need_htf_data and htf_minutes <= mtf_minutes:
        raise ValueError(
            f"Invalid timeframe hierarchy: ltf={ltf_minutes_int}, mtf={mtf_minutes}, htf={htf_minutes} "
            "(must satisfy ltf < mtf < htf)"
        )

    management_bar_minutes = int(exec_cfg.get("management_bar_minutes", 60) or 0)

    ltf_bar_minutes = int(exec_cfg.get("ltf_bar_minutes", ltf_minutes_int) or ltf_minutes_int)
    if ltf_bar_minutes != ltf_minutes_int:
        # ltf_minutes is controlled by the runner (engine bar aggregation). YAML must not diverge.
        raise ValueError(
            f"execution.ltf_bar_minutes ({ltf_bar_minutes}) must match runner ltf_minutes ({ltf_minutes_int}). "
            "Use --ltf-minutes or optimize execution.ltf_bar_minutes to drive LTF."
        )
    if management_bar_minutes < 0:
        raise ValueError(
            f"execution.management_bar_minutes must be >= 0, got {management_bar_minutes}"
        )

    mtf_bar_type = (
        _bar_type_from_minutes(
            instrument_id=instrument_id,
            minutes=mtf_minutes,
            aggregation_source=agg_source,
        )
        if use_mtf
        else None
    )
    htf_bar_type = (
        _bar_type_from_minutes(
            instrument_id=instrument_id,
            minutes=htf_minutes,
            aggregation_source=agg_source,
        )
        if need_htf_data
        else None
    )

    return GoldScalperConfig(
        strategy_id="GOLD-TICK-001",
        seed=int(exec_cfg.get("seed", 42)),
        instrument_id=instrument_id,
        htf_bar_type=htf_bar_type,
        mtf_bar_type=mtf_bar_type,
        ltf_bar_type=bar_type,
        ltf_bar_minutes=ltf_minutes_int,
        mtf_bar_minutes=int(mtf_minutes),
        htf_bar_minutes=int(htf_minutes),
        management_bar_minutes=int(management_bar_minutes),
        execution_threshold=int(execution_threshold),
        slippage_in_fills=_infer_slippage_in_fills(exec_cfg),
        fees_in_account=_infer_fees_in_account(exec_cfg),
        min_mtf_confluence=float(confluence_cfg.get("min_score_to_trade", 50)),
        min_rr_ratio=float(exec_cfg.get("min_rr_ratio", 1.5)),
        target_rr_ratio=float(exec_cfg.get("target_rr_ratio", 2.5)),
        trend_target_rr_ratio=float(exec_cfg.get("trend_target_rr_ratio", 0.0)),
        mean_revert_target_rr_ratio=float(exec_cfg.get("mean_revert_target_rr_ratio", 0.0)),
        trade_partial_tp_r=float(exec_cfg.get("trade_partial_tp_r", 1.0)),
        trade_partial_tp_percent=float(exec_cfg.get("trade_partial_tp_percent", 0.5)),
        trade_trailing_start_r=float(exec_cfg.get("trade_trailing_start_r", 1.0)),
        use_session_filter=exec_cfg.get("use_session_filter", True),
        use_regime_filter=exec_cfg.get("use_regime_filter", True),
        require_htf_align=require_htf_align,
        require_mtf_zone=_parse_bool(exec_cfg.get("require_mtf_zone"), default=False),
        require_ltf_confirm=_parse_bool(exec_cfg.get("require_ltf_confirm"), default=False),
        use_mtf=use_mtf,
        aggressive_mode=_parse_bool(exec_cfg.get("aggressive_mode"), default=False),
        use_footprint=exec_cfg.get("use_footprint", True),
        use_footprint_boost=_parse_bool(exec_cfg.get("use_footprint_boost"), default=True),
        use_bandit_context=_parse_bool(exec_cfg.get("use_bandit_context"), default=False),
        prop_firm_enabled=_parse_bool(exec_cfg.get("prop_firm_enabled"), default=True),
        account_balance=exec_cfg.get("initial_balance", 100000.0),
        # DD limits: config uses fractions (0.03 = 3%), but GoldScalperConfig expects percent-points (3.0)
        # Safe conversion: if value < 1, treat as fraction and multiply by 100
        daily_loss_limit_pct=float(risk_cfg.get("dd_soft", 0.03)) * 100.0
        if float(risk_cfg.get("dd_soft", 0.03)) < 1.0
        else float(risk_cfg.get("dd_soft", 3.0)),
        total_loss_limit_pct=float(risk_cfg.get("dd_hard", 0.05)) * 100.0
        if float(risk_cfg.get("dd_hard", 0.05)) < 1.0
        else float(risk_cfg.get("dd_hard", 5.0)),
        risk_per_trade=Decimal(str(risk_cfg.get("max_risk_per_trade", 0.01))),
        max_spread_points=int(
            spread_cfg.get("max_spread_points", exec_cfg.get("max_spread_points", 80))
        ),
        use_news_filter=news_cfg.get("enabled", True),
        news_score_penalty=int(news_cfg.get("score_penalty", -15)),
        news_size_multiplier=float(news_cfg.get("size_multiplier", 0.5)),
        news_events_path=(
            str(news_cfg.get("events_path")) if news_cfg.get("events_path") else None
        ),
        flatten_time_et=cutoff_str,
        allow_overnight=_parse_bool(
            exec_cfg.get("allow_overnight", time_cfg.get("allow_overnight")),
            default=False,  # APEX: default False - no overnight positions
        ),
        slippage_ticks=int(exec_cfg.get("slippage_ticks", 2)),
        slippage_multiplier=float(exec_cfg.get("slippage_multiplier", 1.5)),
        atr_multiplier=float(exec_cfg.get("atr_multiplier", 1.5)),
        commission_source=str(exec_cfg.get("commission_source", "manual")),
        commission_profile=str(exec_cfg.get("commission_profile", "apex")),
        commission_gateway=str(exec_cfg.get("commission_gateway", "tradovate")),
        commission_per_contract=float(exec_cfg.get("commission_per_contract", 2.5)),
        latency_ms=int(exec_cfg.get("latency_ms", 0)),
        partial_fill_prob=float(exec_cfg.get("partial_fill_prob", 0.0)),
        partial_fill_ratio=float(exec_cfg.get("partial_fill_ratio", 0.5)),
        fill_reject_base=float(exec_cfg.get("fill_reject_base", 0.0)),
        fill_reject_spread_factor=float(exec_cfg.get("fill_reject_spread_factor", 0.0)),
        fill_model=str(exec_cfg.get("fill_model", "realistic")),
        use_selector=exec_cfg.get("use_selector", True),
        enable_smc=_parse_bool(exec_cfg.get("enable_smc"), default=True),
        enable_trend_follow=_parse_bool(exec_cfg.get("enable_trend_follow"), default=False),
        trend_follow_mode=str(exec_cfg.get("trend_follow_mode", "BOTH")),
        enable_trend_pullback=_parse_bool(exec_cfg.get("enable_trend_pullback"), default=True),
        enable_trend_breakout=_parse_bool(exec_cfg.get("enable_trend_breakout"), default=True),
        # TrendFollow moving average type
        trend_ma_type=str(exec_cfg.get("trend_ma_type", "EMA")),
        # TrendFollow core MA periods
        trend_ema_fast=int(exec_cfg.get("trend_ema_fast", 20)),
        trend_ema_slow=int(exec_cfg.get("trend_ema_slow", 50)),
        trend_pullback_lookback=int(exec_cfg.get("trend_pullback_lookback", 10)),
        # TrendFollow breakout variants
        trend_enable_donchian_breakout=_parse_bool(
            exec_cfg.get("trend_enable_donchian_breakout"), default=True
        ),
        trend_enable_swing_breakout=_parse_bool(
            exec_cfg.get("trend_enable_swing_breakout"), default=False
        ),
        trend_swing_strength=int(exec_cfg.get("trend_swing_strength", 3)),
        trend_swing_lookback_bars=int(exec_cfg.get("trend_swing_lookback_bars", 120)),
        # Breakout buffers
        trend_breakout_entry_buffer_atr_mult=float(
            exec_cfg.get("trend_breakout_entry_buffer_atr_mult", 0.0)
        ),
        trend_breakout_sl_buffer_atr_mult=float(
            exec_cfg.get("trend_breakout_sl_buffer_atr_mult", 0.25)
        ),
        # Pullback strictness
        trend_pullback_require_recross=_parse_bool(
            exec_cfg.get("trend_pullback_require_recross"), default=False
        ),
        trend_pullback_recross_lookback=int(exec_cfg.get("trend_pullback_recross_lookback", 1)),
        # Breakout gates
        trend_breakout_lookback=int(exec_cfg.get("trend_breakout_lookback", 30)),
        trend_min_atr_percentile_breakout=float(
            exec_cfg.get("trend_min_atr_percentile_breakout", 65.0)
        ),
        trend_er_enabled=_parse_bool(exec_cfg.get("trend_er_enabled"), default=False),
        trend_er_period=int(exec_cfg.get("trend_er_period", 48)),
        trend_er_smoothing=int(exec_cfg.get("trend_er_smoothing", 3)),
        trend_er_min=float(exec_cfg.get("trend_er_min", 0.30)),
        trend_sep_ticks_min=float(exec_cfg.get("trend_sep_ticks_min", 4.0)),
        trend_touch_dist_mult=float(exec_cfg.get("trend_touch_dist_mult", 0.35)),
        trend_min_score=float(exec_cfg.get("trend_min_score", 60.0)),
        # Parabolic SAR (alignment filter)
        psar_enabled=_parse_bool(exec_cfg.get("psar_enabled"), default=False),
        psar_step=float(exec_cfg.get("psar_step", 0.02)),
        psar_max=float(exec_cfg.get("psar_max", 0.20)),
        psar_use_prev_bar=_parse_bool(exec_cfg.get("psar_use_prev_bar"), default=True),
        psar_trend_use_prev_bar=(
            _parse_bool(exec_cfg["psar_trend_use_prev_bar"], default=True)
            if "psar_trend_use_prev_bar" in exec_cfg
            and exec_cfg["psar_trend_use_prev_bar"] is not None
            else None
        ),
        psar_smc_use_prev_bar=(
            _parse_bool(exec_cfg["psar_smc_use_prev_bar"], default=True)
            if "psar_smc_use_prev_bar" in exec_cfg and exec_cfg["psar_smc_use_prev_bar"] is not None
            else None
        ),
        psar_apply_to_trend=_parse_bool(exec_cfg.get("psar_apply_to_trend"), default=False),
        psar_apply_to_smc=_parse_bool(exec_cfg.get("psar_apply_to_smc"), default=False),
        trend_direction_mode=str(exec_cfg.get("trend_direction_mode", "NORMAL")),
        ghost_mode=_parse_bool(exec_cfg.get("ghost_mode"), default=False),
        ghost_seed=int(exec_cfg.get("ghost_seed", 1337)),
        enable_mean_revert=_parse_bool(exec_cfg.get("enable_mean_revert"), default=False),
        mean_revert_bb_period=int(exec_cfg.get("mean_revert_bb_period", 20)),
        mean_revert_bb_k=float(exec_cfg.get("mean_revert_bb_k", 2.0)),
        mean_revert_rsi_period=int(exec_cfg.get("mean_revert_rsi_period", 14)),
        mean_revert_rsi_oversold=float(exec_cfg.get("mean_revert_rsi_oversold", 30.0)),
        mean_revert_rsi_overbought=float(exec_cfg.get("mean_revert_rsi_overbought", 70.0)),
        mean_revert_max_atr_percentile=float(exec_cfg.get("mean_revert_max_atr_percentile", 70.0)),
        mean_revert_er_enabled=_parse_bool(exec_cfg.get("mean_revert_er_enabled"), default=False),
        mean_revert_er_period=int(exec_cfg.get("mean_revert_er_period", 48)),
        mean_revert_er_smoothing=int(exec_cfg.get("mean_revert_er_smoothing", 3)),
        mean_revert_er_max=float(exec_cfg.get("mean_revert_er_max", 0.30)),
        force_mean_revert=_parse_bool(exec_cfg.get("force_mean_revert"), default=False),
        regime_stability_min_bars=int(exec_cfg.get("regime_stability_min_bars", 0)),
        regime_stability_max_transition_prob=float(
            exec_cfg.get("regime_stability_max_transition_prob", 1.0)
        ),
        router_adaptive_ev=_parse_bool(exec_cfg.get("router_adaptive_ev"), default=True),
        router_min_trades_to_trust=int(exec_cfg.get("router_min_trades_to_trust", 30)),
        router_score_weight=float(exec_cfg.get("router_score_weight", 0.10)),
        router_dd_penalty_total=float(exec_cfg.get("router_dd_penalty_total", 0.20)),
        router_dd_penalty_daily=float(exec_cfg.get("router_dd_penalty_daily", 0.10)),
        # Phase 11 safety layer (entry-only)
        max_concurrent_positions=int(exec_cfg.get("max_concurrent_positions", 1)),
        max_concurrent_instruments=int(exec_cfg.get("max_concurrent_instruments", 1)),
        vol_spacing_min_seconds=float(exec_cfg.get("vol_spacing_min_seconds", 0.0)),
        vol_spacing_max_seconds=float(exec_cfg.get("vol_spacing_max_seconds", 300.0)),
        vol_spacing_reference_atr=float(exec_cfg.get("vol_spacing_reference_atr", 1.0)),
        virtual_gate_enabled=_parse_bool(exec_cfg.get("virtual_gate_enabled"), default=True),
        virtual_gate_lookback_bars=int(exec_cfg.get("virtual_gate_lookback_bars", 20)),
        virtual_gate_range_spike_multiplier=float(
            exec_cfg.get("virtual_gate_range_spike_multiplier", 3.0)
        ),
        virtual_gate_cluster_spike_multiplier=float(
            exec_cfg.get("virtual_gate_cluster_spike_multiplier", 2.5)
        ),
        virtual_gate_cluster_max_fraction=float(
            exec_cfg.get("virtual_gate_cluster_max_fraction", 0.30)
        ),
        virtual_gate_fail_open_on_insufficient_history=_parse_bool(
            exec_cfg.get("virtual_gate_fail_open_on_insufficient_history"), default=True
        ),
        max_spread_pips=max_spread_pips,
        spread_warning_ratio=float(
            spreadmon_cfg.get("warning_ratio", spread_cfg.get("warning_ratio", 2.0))
        ),
        spread_block_ratio=float(
            spreadmon_cfg.get("block_ratio", spread_cfg.get("block_ratio", 5.0))
        ),
        spread_history_size=int(spreadmon_cfg.get("history_size", 200)),
        spread_update_interval=int(spreadmon_cfg.get("update_interval", 1)),
        spread_pip_factor=float(spreadmon_cfg.get("pip_factor", 10.0)),
        time_warning_et=warning_str,
        time_urgent_et=urgent_str,
        time_emergency_et=emergency_str,
        cb_level_1_losses=int(cb_cfg.get("level_1_losses", 3)),
        cb_level_2_losses=int(cb_cfg.get("level_2_losses", 5)),
        cb_level_3_dd=float(cb_cfg.get("level_3_dd", 3.0)),
        cb_level_4_dd=float(cb_cfg.get("level_4_dd", 4.0)),
        cb_level_5_dd=float(cb_cfg.get("level_5_dd", 4.5)),
        cb_cooldown_1=int((cb_cfg.get("cooldown_minutes") or {}).get("level_1", 5)),
        cb_cooldown_2=int((cb_cfg.get("cooldown_minutes") or {}).get("level_2", 15)),
        cb_cooldown_3=int((cb_cfg.get("cooldown_minutes") or {}).get("level_3", 30)),
        cb_cooldown_4=int((cb_cfg.get("cooldown_minutes") or {}).get("level_4", 1440)),
        cb_size_mult_2=float((cb_cfg.get("size_multipliers") or {}).get("level_2", 0.75)),
        cb_size_mult_3=float((cb_cfg.get("size_multipliers") or {}).get("level_3", 0.5)),
        cb_auto_recovery=_parse_bool(cb_cfg.get("auto_recovery"), default=True),
        consistency_cap_pct=float(consistency_cfg.get("daily_profit_cap_pct", 30.0)),
        telemetry_enabled=_parse_bool(telemetry_cfg.get("enabled"), default=True),
        telemetry_path=str(telemetry_cfg.get("path", "logs/telemetry.jsonl")),
        telemetry_capture_spread=_parse_bool(telemetry_capture.get("spread"), default=True),
        telemetry_capture_circuit=_parse_bool(telemetry_capture.get("circuit"), default=True),
        telemetry_capture_cutoff=_parse_bool(telemetry_capture.get("cutoff"), default=True),
        ml_filter_enabled=_parse_bool(
            ml_cfg.get("filter_enabled") if isinstance(ml_cfg, dict) else None,
            default=False,
        ),
        ml_filter_mode=str(ml_cfg.get("filter_mode", "log_only"))
        if isinstance(ml_cfg, dict)
        else "log_only",
        ml_filter_min_p_edge=float(ml_cfg.get("filter_min_p_edge", 0.55))
        if isinstance(ml_cfg, dict)
        else 0.55,
        ml_filter_model_path=(
            ml_cfg.get("filter_model_path") if isinstance(ml_cfg, dict) else None
        ),
        ml_capture_enabled=_parse_bool(
            ml_cfg.get("capture_enabled") if isinstance(ml_cfg, dict) else None,
            default=False,
        ),
        session_broker_gmt_offset=int(session_cfg.get("broker_gmt_offset", 0)),
        session_allow_asian=_parse_bool(session_cfg.get("allow_asian"), default=False),
        session_allow_late_ny=_parse_bool(session_cfg.get("allow_late_ny"), default=False),
        session_friday_close_hour=int(session_cfg.get("friday_close_hour", 14)),
        structure_swing_strength=int(structure_cfg.get("swing_strength", 3)),
        structure_equal_tolerance_pips=float(structure_cfg.get("equal_tolerance_pips", 5.0)),
        structure_break_buffer_pips=float(structure_cfg.get("break_buffer_pips", 2.0)),
        structure_lookback_bars=int(structure_cfg.get("lookback_bars", 100)),
        structure_min_swing_distance=int(structure_cfg.get("min_swing_distance", 5)),
        structure_point=float(structure_cfg.get("point", 0.0)),
        ob_displacement_threshold_pips=float(ob_cfg.get("displacement_threshold_pips", 20.0)),
        ob_volume_threshold=float(ob_cfg.get("volume_threshold", 1.5)),
        ob_require_structure_break=_parse_bool(ob_cfg.get("require_structure_break"), default=True),
        ob_max_order_blocks=int(ob_cfg.get("max_order_blocks", 50)),
        ob_lookback_bars=int(ob_cfg.get("lookback_bars", 50)),
        ob_point=float(ob_cfg.get("point", 0.0)),
        ob_pip_factor=float(ob_cfg.get("pip_factor", 10.0)),
        fvg_min_gap_pips=float(fvg_cfg.get("min_gap_pips", 1.0)),
        fvg_max_gap_pips=float(fvg_cfg.get("max_gap_pips", 40.0)),
        fvg_min_displacement_pips=float(fvg_cfg.get("min_displacement_pips", 15.0)),
        fvg_volume_threshold=float(fvg_cfg.get("volume_threshold", 1.5)),
        fvg_max_fvgs=int(fvg_cfg.get("max_fvgs", 50)),
        fvg_expiry_hours=int(fvg_cfg.get("expiry_hours", 24)),
        fvg_point=float(fvg_cfg.get("point", 0.0)),
        fvg_pip_factor=float(fvg_cfg.get("pip_factor", 10.0)),
        sweep_equal_tolerance_pips=float(sweeps_cfg.get("equal_tolerance_pips", 3.0)),
        sweep_min_touches=int(sweeps_cfg.get("min_touches", 2)),
        sweep_min_sweep_depth_pips=float(sweeps_cfg.get("min_sweep_depth_pips", 5.0)),
        sweep_max_bars_beyond=int(sweeps_cfg.get("max_bars_beyond", 3)),
        sweep_lookback_bars=int(sweeps_cfg.get("lookback_bars", 20)),
        sweep_swing_strength=int(sweeps_cfg.get("swing_strength", 3)),
        sweep_point=float(sweeps_cfg.get("point", 0.0)),
        sweep_pip_factor=float(sweeps_cfg.get("pip_factor", 10.0)),
        amd_min_accumulation_bars=int(amd_cfg.get("min_accumulation_bars", 15)),
        amd_max_accumulation_bars=int(amd_cfg.get("max_accumulation_bars", 80)),
        amd_range_atr_max=float(amd_cfg.get("range_atr_max", 1.5)),
        amd_min_sweep_depth_pips=float(amd_cfg.get("min_sweep_depth_pips", 5.0)),
        amd_min_displacement_atr=float(amd_cfg.get("min_displacement_atr", 1.5)),
        amd_equal_tolerance_pips=float(amd_cfg.get("equal_tolerance_pips", 3.0)),
        amd_point=float(amd_cfg.get("point", 0.0)),
        amd_pip_factor=float(amd_cfg.get("pip_factor", 10.0)),
        mtf_htf_swing_strength=int(mtf_cfg.get("htf_swing_strength", 5)),
        mtf_mtf_swing_strength=int(mtf_cfg.get("mtf_swing_strength", 3)),
        mtf_ltf_swing_strength=int(mtf_cfg.get("ltf_swing_strength", 2)),
        mtf_htf_lookback_bars=int(mtf_cfg.get("htf_lookback_bars", 100)),
        mtf_mtf_lookback_bars=int(mtf_cfg.get("mtf_lookback_bars", 100)),
        mtf_ltf_lookback_bars=int(mtf_cfg.get("ltf_lookback_bars", 50)),
        mtf_structure_point=float(mtf_cfg.get("structure_point", 0.0)),
        confluence_weight_structure=_weight(
            field_name="confluence_weight_structure",
            weights_keys=("structure",),
            legacy_keys=("structure_weight", "structure"),
        ),
        confluence_weight_regime=_weight(
            field_name="confluence_weight_regime",
            weights_keys=("regime",),
            legacy_keys=("regime_weight", "regime"),
        ),
        confluence_weight_order_block=_weight(
            field_name="confluence_weight_order_block",
            weights_keys=("order_block", "ob"),
            legacy_keys=("order_block_weight", "ob_weight"),
        ),
        confluence_weight_fvg=_weight(
            field_name="confluence_weight_fvg",
            weights_keys=("fvg",),
            legacy_keys=("fvg_weight",),
        ),
        confluence_weight_liquidity_sweep=_weight(
            field_name="confluence_weight_liquidity_sweep",
            weights_keys=("liquidity_sweep", "sweep"),
            legacy_keys=("liquidity_sweep_weight", "sweep_weight"),
        ),
        confluence_weight_amd_cycle=_weight(
            field_name="confluence_weight_amd_cycle",
            weights_keys=("amd_cycle", "amd"),
            legacy_keys=("amd_cycle_weight", "amd_weight"),
        ),
        confluence_weight_fib=_weight(
            field_name="confluence_weight_fib",
            weights_keys=("fib",),
            legacy_keys=("fib_weight",),
        ),
        confluence_weight_mtf=_weight(
            field_name="confluence_weight_mtf",
            weights_keys=("mtf",),
            legacy_keys=("mtf_weight",),
        ),
        confluence_weight_footprint=_weight(
            field_name="confluence_weight_footprint",
            weights_keys=("footprint",),
            legacy_keys=("footprint_weight",),
        ),
        footprint_cluster_size=float(footprint_cfg.get("cluster_size", 0.50)),
        footprint_imbalance_ratio=float(footprint_cfg.get("imbalance_ratio", 3.0)),
        footprint_stacked_min=int(footprint_cfg.get("stacked_min", 3)),
        footprint_absorption_threshold=float(footprint_cfg.get("absorption_threshold", 15.0)),
        footprint_volume_multiplier=float(footprint_cfg.get("volume_multiplier", 2.0)),
        footprint_lookback_bars=int(footprint_cfg.get("lookback_bars", 20)),
        footprint_stack_decay_30m=float(footprint_cfg.get("stack_decay_30m", 0.75)),
        footprint_stack_decay_60m=float(footprint_cfg.get("stack_decay_60m", 0.50)),
        footprint_score_floor=float(footprint_cfg.get("score_floor", 40.0)),
        footprint_score_cap=float(footprint_cfg.get("score_cap", 95.0)),
        regime_hurst_period=int(regime_cfg.get("hurst_period", 100)),
        regime_entropy_period=int(regime_cfg.get("entropy_period", 50)),
        regime_vr_period=int(regime_cfg.get("vr_period", 20)),
        regime_kalman_q=float(regime_cfg.get("kalman_q", 0.01)),
        regime_kalman_r=float(regime_cfg.get("kalman_r", 0.1)),
        regime_multiscale_periods=tuple(
            int(x) for x in regime_cfg.get("multiscale_periods", [50, 100, 200])
        ),
        selector_ftmo_safe_mode=_parse_bool(selector_cfg.get("ftmo_safe_mode"), default=False),
        selector_allow_news_trading=_parse_bool(
            selector_cfg.get("allow_news_trading"), default=True
        ),
        selector_allow_asian_session=_parse_bool(
            selector_cfg.get("allow_asian_session"), default=False
        ),
        selector_hurst_trend_threshold=float(selector_cfg.get("hurst_trend_threshold", 0.55)),
        selector_hurst_revert_threshold=float(selector_cfg.get("hurst_revert_threshold", 0.40)),
        selector_entropy_low_threshold=float(selector_cfg.get("entropy_low_threshold", 1.5)),
        selector_entropy_high_threshold=float(selector_cfg.get("entropy_high_threshold", 2.5)),
        hbs_enabled=_parse_bool(exec_cfg.get("hbs_enabled"), default=True),
        hbs_mode=str(exec_cfg.get("hbs_mode", "backtest")),
        hbs_account_id=str(exec_cfg.get("hbs_account_id", "")),
        hbs_profit_target=float(exec_cfg.get("hbs_profit_target", 3000.0)),
    )


def aggregate_tick_df_to_ohlcv(df: pd.DataFrame, interval_minutes: int) -> pd.DataFrame:
    """Aggregate (datetime,bid,ask) ticks into OHLCV bars using mid price.

    Temporal correctness:
    - Use left-closed bins (include bar start, exclude bar end).
    - Label bars by *bar close* timestamp (right label) so consumers don't treat
      full OHLC as known at bar start.
    """
    if df.empty:
        return pd.DataFrame()

    ticks = df.copy()
    ticks["mid"] = (ticks["bid"] + ticks["ask"]) / 2.0
    ticks = ticks.set_index("datetime")

    rs = ticks["mid"].resample(f"{interval_minutes}min", closed="left", label="right")
    ohlc = rs.ohlc()
    vol = rs.count()
    bars_df = ohlc.join(vol.rename("volume")).dropna()
    return bars_df


def build_bars_with_wrangler(
    bars_df: pd.DataFrame, bar_type: BarType, instrument: Instrument
) -> list[Bar]:
    """Convert OHLCV dataframe to Nautilus `Bar` objects via Cython wrangler."""
    if bars_df.empty:
        return []
    wrangler = BarDataWrangler(bar_type, instrument)
    return cast(list[Bar], wrangler.process(bars_df))


class BacktestRunner:
    """NautilusTrader-based tick backtest runner."""

    def __init__(
        self,
        initial_balance: float = 100_000.0,
        log_level: str = "WARNING",
        slippage_ticks: int = 2,
        commission_per_contract: float = 2.5,
        product: Product = "xauusd",
        gateway: Gateway = "tradovate",
        latency_ms: int = 0,
        partial_fill_prob: float = 0.0,  # NOTE: Not wired to engine fill model (placeholder)
        partial_fill_ratio: float = 0.5,  # NOTE: Not wired to engine fill model (placeholder)
        fill_model: str = "realistic",
        seed: int = 42,
    ):
        self.initial_balance = initial_balance
        self.log_level = log_level
        self.engine: NautilusEngine | None = None
        self.venue = Venue("SIM")
        self.instrument: Instrument | None = None
        self.slippage_ticks = slippage_ticks
        self.commission_per_contract = commission_per_contract
        self.product: Product = product
        self.gateway: Gateway = gateway
        self.latency_ms = latency_ms
        self.partial_fill_prob = partial_fill_prob
        self.partial_fill_ratio = partial_fill_ratio
        self.fill_model = str(fill_model)
        self.seed = int(seed)
        self.metrics_jsonl: str | None = None
        # Keep a reference to the strategy instance used in the last run.
        # This allows downstream tools (optimizer) to extract mark-to-market equity
        # from the strategy's DrawdownTracker history.
        self.strategy: Any | None = None

    def run(
        self,
        start_date: str = "2024-10-01",
        end_date: str = "2024-12-31",
        ltf_minutes: int = 15,
        sample_rate: Sample = 1,
        use_session_filter: bool = True,
        use_regime_filter: bool = True,
        use_mtf: bool = False,
        use_footprint: bool = True,
        prop_firm_enabled: bool = True,
        use_news_filter: bool = True,
        execution_threshold: int = 70,
        debug_mode: bool = False,
        feed: FeedMode = "ticks",
        data_source: DataSource = "auto",
        profile: bool = False,
        reports: ReportsMode = "summary",
        bars_file: str | None = None,
        bars_override: list[Bar] | None = None,
        return_summary: bool = False,
        output_dir: str | None = None,
        risk_per_trade: float | None = None,
        product: Product | None = None,
        gateway: Gateway | None = None,
        config_overrides: dict[str, Any] | None = None,
        quiet: bool = False,
        catalog_path: str | None = None,
        catalog_paths: list[str] | None = None,
        strategy_config_path: Path | None = None,
    ) -> BacktestSummary | None:
        """Run backtest with NautilusTrader.

        - `feed="ticks"`: loads QuoteTicks and aggregates bars internally (slow, most live-like).
        - `feed="bars"`: feeds external M5 bars (fast screening). Provide `bars_file` or `bars_override` for speed.
        """

        def _p(msg: str) -> None:
            if not quiet:
                print(msg)

        # Grid runs can generate enormous log volume (and slow down the engine).
        # When `quiet=True`, temporarily disable Python logging across the process.
        prev_disable = logging.root.manager.disable
        if quiet:
            logging.disable(logging.CRITICAL)

        _p("=" * 60)
        _p("NAUTILUS TRADER TICK-BASED BACKTEST")
        _p("=" * 60)
        _p(f"Period: {start_date} to {end_date}")
        _p(f"Sample: {sample_rate} (float fraction or N-step)")
        _p(f"Feed: {feed} | Source: {data_source}")
        _p(f"LTF minutes: {ltf_minutes}")

        # CRITICAL: Apex trailing DD / HWM semantics require QuoteTicks (bid/ask) for
        # mark-to-market equity updates. Bar-only mode is a fast screener but is NOT
        # valid for prop-firm compliance decisions.
        if prop_firm_enabled and feed != "ticks":
            raise ValueError(
                "prop_firm_enabled=True requires feed='ticks' for MTM equity/HWM enforcement. "
                "Use feed='ticks' or disable prop-firm rules via --no-prop / prop_firm_enabled=False."
            )
        # Note: Filters/defaults are loaded from the selected strategy YAML.
        _p(f"Initial Balance: ${self.initial_balance:,.2f}")

        t0 = time.perf_counter()

        # Make runs deterministic by default (critical for comparing parameter sweeps).
        # Also avoid hash-randomization affecting any set/dict ordering in configs.
        os.environ.setdefault("PYTHONHASHSEED", str(self.seed))
        random.seed(self.seed)
        np.random.seed(self.seed)

        # Configure engine
        engine_config = BacktestEngineConfig(
            trader_id=TraderId("GOLD-TICK-001"),
            logging=LoggingConfig(log_level=self.log_level),
            risk_engine=RiskEngineConfig(bypass=False),
        )

        engine = NautilusEngine(config=engine_config)
        self.engine = engine

        resolved_product: Product = product or self.product
        resolved_gateway: Gateway = gateway or self.gateway

        # Create instrument early (needed for lot_size conversion in engine fee model)
        if resolved_product == "xauusd":
            instrument = create_xauusd_instrument(self.venue)
        elif resolved_product == "mgc":
            instrument = create_mgc_instrument(self.venue)
        else:  # pragma: no cover
            raise ValueError(f"Unsupported product={resolved_product!r}")
        self.instrument = instrument

        # Load strategy YAML config early so engine models (fills/fees/latency) match the strategy config.
        default_cfg_path = Path(__file__).parent.parent.parent / "configs" / "strategy_config.yaml"
        cfg_path = strategy_config_path if strategy_config_path is not None else default_cfg_path
        strategy_cfg_dict = load_yaml_config(cfg_path)
        strategy_cfg_dict.setdefault("confluence", {})
        strategy_cfg_dict.setdefault("execution", {})
        strategy_cfg_dict.setdefault("risk", {})
        strategy_cfg_dict.setdefault("news", {})
        strategy_cfg_dict.setdefault("footprint", {})
        strategy_cfg_dict.setdefault("regime", {})
        strategy_cfg_dict.setdefault("selector", {})

        confluence_cfg = (
            strategy_cfg_dict["confluence"]
            if isinstance(strategy_cfg_dict["confluence"], dict)
            else {}
        )
        exec_cfg = (
            strategy_cfg_dict["execution"]
            if isinstance(strategy_cfg_dict["execution"], dict)
            else {}
        )
        risk_cfg = strategy_cfg_dict["risk"] if isinstance(strategy_cfg_dict["risk"], dict) else {}
        news_cfg = strategy_cfg_dict["news"] if isinstance(strategy_cfg_dict["news"], dict) else {}

        if config_overrides:
            # Allow workflows (grid search) to sweep params without editing YAML.
            try:
                _deep_update(strategy_cfg_dict, config_overrides)
            except Exception as exc:
                _p(f"WARNING: could not apply config_overrides: {exc}")

        # Refresh views after _deep_update
        confluence_cfg = (
            strategy_cfg_dict["confluence"]
            if isinstance(strategy_cfg_dict["confluence"], dict)
            else {}
        )
        exec_cfg = (
            strategy_cfg_dict["execution"]
            if isinstance(strategy_cfg_dict["execution"], dict)
            else {}
        )
        risk_cfg = strategy_cfg_dict["risk"] if isinstance(strategy_cfg_dict["risk"], dict) else {}
        news_cfg = strategy_cfg_dict["news"] if isinstance(strategy_cfg_dict["news"], dict) else {}

        # Apply runtime overrides so CLI/test args actually take effect.
        confluence_cfg["execution_threshold"] = int(execution_threshold)
        confluence_cfg["min_score_to_trade"] = int(execution_threshold)
        exec_cfg["use_session_filter"] = bool(use_session_filter)
        exec_cfg["use_regime_filter"] = bool(use_regime_filter)
        exec_cfg["use_mtf"] = bool(use_mtf)
        exec_cfg["use_footprint"] = bool(use_footprint)
        exec_cfg["slippage_ticks"] = int(self.slippage_ticks)
        exec_cfg["latency_ms"] = int(self.latency_ms)
        exec_cfg["partial_fill_prob"] = float(self.partial_fill_prob)
        exec_cfg["partial_fill_ratio"] = float(self.partial_fill_ratio)
        exec_cfg["fill_model"] = str(self.fill_model)
        exec_cfg["seed"] = int(self.seed)
        exec_cfg["debug_mode"] = bool(debug_mode)
        exec_cfg["prop_firm_enabled"] = bool(prop_firm_enabled)
        # Keep strategy-side risk state aligned with the backtest account.
        exec_cfg["initial_balance"] = float(self.initial_balance)
        news_cfg["enabled"] = bool(use_news_filter)
        if risk_per_trade is not None:
            risk_cfg["max_risk_per_trade"] = float(risk_per_trade)

        # Commission schedule knobs must reflect the run-time gateway/product.
        exec_cfg.setdefault("commission_source", "manual")
        exec_cfg.setdefault("commission_profile", "apex")
        exec_cfg["commission_gateway"] = str(resolved_gateway)

        commission_source = str(exec_cfg.get("commission_source", "manual")).strip().lower()
        commission_profile = str(exec_cfg.get("commission_profile", "apex")).strip().lower()
        if commission_source == "schedule":
            from nautilus_gold_scalper.src.execution.commission_schedule import (
                commission_per_side_usd,
            )

            resolved_commission_per_contract = float(
                commission_per_side_usd(
                    profile=cast(Any, commission_profile),
                    product=cast(Any, resolved_product),
                    gateway=cast(Any, resolved_gateway),
                )
            )
        else:
            resolved_commission_per_contract = float(self.commission_per_contract)

        self.commission_per_contract = float(resolved_commission_per_contract)
        strategy_cfg_dict["execution"]["commission_per_contract"] = float(
            resolved_commission_per_contract
        )

        fill_model: object | None = None
        fee_model: object | None = None
        latency_model: object | None = None

        # Fill slippage model (engine-level): defines fill prices.
        # NOTE: TwoTier/ThreeTier are depth simulators and can create >1 tick average slippage for large orders.
        fill_model = _build_fill_model(self.fill_model, seed=int(self.seed))

        # Fee model (engine-level): defines account commissions.
        # Interpretation: `commission_per_contract` is per side for ONE lot.
        # Nautilus `PerContractFeeModel` charges per filled Quantity unit, so we convert
        # USD/lot -> USD/unit using the instrument lot size.
        fee_model = None
        if (
            resolved_commission_per_contract is not None
            and float(resolved_commission_per_contract) != 0.0
        ):
            lot_size_units = float(instrument.lot_size.as_double())
            commission_per_unit = float(resolved_commission_per_contract) / max(
                1e-9, lot_size_units
            )
            fee_model = PerContractFeeModel(Money(Decimal(str(commission_per_unit)), USD))

        # Latency model (engine-level): adds delays to order messages.
        resolved_latency_ms = int(self.latency_ms)
        if resolved_latency_ms > 0:
            latency_model = LatencyModel(
                base_latency_nanos=0,
                insert_latency_nanos=resolved_latency_ms * 1_000_000,
                update_latency_nanos=resolved_latency_ms * 1_000_000,
                cancel_latency_nanos=resolved_latency_ms * 1_000_000,
            )

        # Add venue
        engine.add_venue(
            venue=self.venue,
            oms_type=OmsType.NETTING,
            account_type=AccountType.MARGIN,
            base_currency=USD,
            starting_balances=[Money(self.initial_balance, USD)],
            default_leverage=Decimal("20"),
            fill_model=fill_model,
            fee_model=fee_model,
            latency_model=latency_model,
        )

        engine.add_instrument(instrument)

        _p(f"Instrument: {instrument.id} (product={resolved_product}, gateway={resolved_gateway})")

        # Load tick data from config.yaml (SINGLE SOURCE OF TRUTH)
        config_path = Path(__file__).parent.parent.parent / "data" / "config.yaml"
        if not config_path.exists():
            raise FileNotFoundError(
                f"Data config not found: {config_path}. Please create data/config.yaml first!"
            )

        with open(config_path, encoding="utf-8") as f:
            data_config = yaml.safe_load(f) or {}

        # Validate required config structure
        if "active_dataset" not in data_config:
            raise ValueError("data/config.yaml must contain 'active_dataset' section")
        if "path" not in data_config["active_dataset"]:
            raise ValueError("data/config.yaml active_dataset must contain 'path'")

        project_root = Path(__file__).parent.parent.parent
        repo_root = project_root.parent
        tick_path = (project_root / data_config["active_dataset"]["path"]).resolve()
        tick_path_str = str(tick_path)
        native_catalog_path = data_config["active_dataset"].get("native_catalog_path")
        # Resolve native catalog path(s). Overrides are resolved relative to repo root, while the
        # default config path is resolved relative to nautilus_gold_scalper/ (project_root).
        native_catalogs: list[Path] | None = None
        if catalog_paths:
            native_catalogs = []
            for p in catalog_paths:
                pp = Path(p)
                native_catalogs.append(
                    pp.resolve() if pp.is_absolute() else (repo_root / pp).resolve()
                )
        elif catalog_path:
            pp = Path(catalog_path)
            native_catalogs = [pp.resolve() if pp.is_absolute() else (repo_root / pp).resolve()]
        elif native_catalog_path:
            native_catalogs = [(project_root / native_catalog_path).resolve()]

        _p(f"[CONFIG] Using dataset: {data_config['active_dataset']['name']}")
        _p(f"[CONFIG] Path: {tick_path_str}")
        if native_catalogs:
            existing_paths = [p for p in native_catalogs if p.exists()]
            if existing_paths:
                if len(existing_paths) == 1:
                    _p(f"[CONFIG] Native catalog detected: {existing_paths[0]}")
                else:
                    _p(f"[CONFIG] Native catalogs detected: {len(existing_paths)}")
                    for cat_path in existing_paths:
                        _p(f"  - {cat_path}")

        step = sample_to_step(sample_rate)

        use_catalog = False
        if data_source == "catalog":
            use_catalog = True
        elif data_source == "parquet":
            use_catalog = False
        else:
            # auto: prefer the configured Parquet file unless explicitly selecting catalog
            use_catalog = False

        if resolved_product == "mgc" and use_catalog:
            raise ValueError(
                "product=mgc is not compatible with source=catalog (dataset is XAUUSD spot)"
            )
        if feed == "bars" and use_catalog and bars_override is None:
            raise ValueError(
                "bars feed requires parquet source or explicit bars_override (catalog->bars not enabled here)"
            )

        ltf_minutes_int = max(1, int(ltf_minutes))

        bars_df: pd.DataFrame | None = None
        if feed == "bars" and bars_override is None and bars_file:
            if ltf_minutes_int != 5:
                raise ValueError(
                    "bars_file input currently supports only M5 bars; use feed=ticks for ltf-minutes != 5"
                )
            bars_path = Path(bars_file)
            if not bars_path.exists():
                raise FileNotFoundError(f"bars_file not found: {bars_path}")

            bars_timestamp_basis = _bars_timestamp_basis_from_execution_cfg(exec_cfg)

            bars_df = load_bars_csv(
                bars_path,
                start_date=start_date,
                end_date=end_date,
                ltf_minutes=ltf_minutes_int,
                timestamp_basis=bars_timestamp_basis,
            )
            if resolved_product == "mgc":
                tick = float(instrument.price_increment.as_double())
                bars_df = bars_df.copy()
                bars_df["open"] = _quantize_to_tick(
                    bars_df["open"].astype(float).values, tick=tick, mode="nearest"
                )
                bars_df["close"] = _quantize_to_tick(
                    bars_df["close"].astype(float).values, tick=tick, mode="nearest"
                )
                bars_df["high"] = _quantize_to_tick(
                    bars_df["high"].astype(float).values, tick=tick, mode="ceil"
                )
                bars_df["low"] = _quantize_to_tick(
                    bars_df["low"].astype(float).values, tick=tick, mode="floor"
                )

        quote_ticks: list[QuoteTick] = []
        df: pd.DataFrame | None = None
        if use_catalog and feed == "ticks":
            if not native_catalogs:
                raise FileNotFoundError(
                    "Catalog source requested but native catalog path not configured"
                )
            missing = [p for p in native_catalogs if not p.exists()]
            if missing:
                raise FileNotFoundError(f"Catalog path(s) not found: {missing}")
            catalogs = [ParquetDataCatalog(str(p)) for p in native_catalogs]

            # ParquetDataCatalog.quote_ticks expects nanosecond timestamps (int), not date strings.
            # When we pass strings, it returns an empty result (silent failure) and the backtest crashes later.
            start_ts = pd.Timestamp(start_date, tz="UTC")
            end_ts = pd.Timestamp(end_date, tz="UTC")
            # If the user passed a date-only string, include the full day (end is exclusive).
            if len(end_date) <= 10:
                end_ts = end_ts + pd.Timedelta(days=1)
            start_ns = int(start_ts.value)
            end_ns = int(end_ts.value)

            # Streaming ingestion path (memory-safe for stride1): use the Rust backend session
            # and yield QuoteTick chunks to NautilusEngine via add_data_iterator.
            # NOTE: ParquetDataCatalog.quote_ticks materializes full lists and will OOM on stride1.
            if step != 1:
                raise ValueError(
                    "source=catalog currently requires sample_rate=1 when streaming (sampling before materialization is not supported)"
                )

            def _iter_catalog_quote_tick_chunks(
                catalog: ParquetDataCatalog,
            ) -> Iterator[list[QuoteTick]]:
                session = catalog.backend_session(
                    data_cls=QuoteTick,
                    identifiers=[instrument.id.value],
                    start=start_ns,
                    end=end_ns,
                )
                result = session.to_query_result()
                for capsule in result:
                    chunk = capsule_to_list(capsule)
                    if chunk:
                        yield cast(list[QuoteTick], chunk)

            if len(catalogs) == 1:
                engine.add_data_iterator(
                    "backtest_data",
                    cast(
                        Generator[list[Any], None, None],
                        _iter_catalog_quote_tick_chunks(catalogs[0]),
                    ),
                )
            else:
                # Multiple catalogs: merge chunk heads by first ts_init.
                def _merge_catalogs_in_ts_order(
                    catalogs_in: list[ParquetDataCatalog],
                ) -> Iterator[list[QuoteTick]]:
                    iters = [_iter_catalog_quote_tick_chunks(c) for c in catalogs_in]
                    heads: list[list[QuoteTick] | None] = []
                    for it in iters:
                        try:
                            heads.append(next(it))
                        except StopIteration:
                            heads.append(None)

                    while True:
                        best_i: int | None = None
                        best_ts: int | None = None
                        for i, head in enumerate(heads):
                            if not head:
                                continue
                            ts0 = int(head[0].ts_init)
                            if best_ts is None or ts0 < best_ts:
                                best_ts = ts0
                                best_i = i

                        if best_i is None:
                            return

                        out = heads[best_i]
                        assert out is not None
                        yield out

                        try:
                            heads[best_i] = next(iters[best_i])
                        except StopIteration:
                            heads[best_i] = None

                engine.add_data_iterator(
                    "backtest_data",
                    cast(Generator[list[Any], None, None], _merge_catalogs_in_ts_order(catalogs)),
                )

            quote_ticks = []  # streaming mode; do not materialize
            _p(f"[CATALOG] Streaming quote ticks from native catalog(s): {len(catalogs)}")
        elif feed == "ticks" or (feed == "bars" and bars_override is None and bars_df is None):
            if not tick_path.exists():
                raise FileNotFoundError(
                    f"Tick data not found at {tick_path}. Check data/config.yaml!"
                )

            df = load_tick_data(str(tick_path), start_date, end_date, sample_rate)
            if feed == "ticks":
                quote_ticks = build_ticks_with_wrangler(
                    df=df, instrument=self.instrument, latency_ms=self.latency_ms
                )

        # Create bar type for internal aggregation from ticks
        agg_source = AggregationSource.INTERNAL if feed == "ticks" else AggregationSource.EXTERNAL
        bar_type = _bar_type_from_minutes(
            instrument_id=instrument.id,
            minutes=ltf_minutes_int,
            aggregation_source=agg_source,
        )
        _p(f"Bar type: {bar_type}")

        if feed == "ticks":
            if use_catalog:
                # Data is fed via add_data_iterator in streaming mode.
                _p("Added ticks via catalog iterator (streaming)")
            else:
                if not quote_ticks:
                    raise ValueError(
                        f"No tick data found for period {start_date} to {end_date}. Check date range and data source."
                    )
                engine.add_data(quote_ticks)
                _p(f"Added {len(quote_ticks):,} ticks to engine (bars aggregated internally)")
        else:
            if bars_override is not None:
                bars = bars_override
            elif bars_df is not None:
                bars = build_bars_with_wrangler(bars_df, bar_type=bar_type, instrument=instrument)
            else:
                # resample ticks into bars (slower than bars_file, still faster than full tick engine)
                assert df is not None
                assert not use_catalog
                bars_df2 = aggregate_tick_df_to_ohlcv(df, interval_minutes=ltf_minutes_int)
                if resolved_product == "mgc":
                    tick = float(instrument.price_increment.as_double())
                    bars_df2 = bars_df2.copy()
                    bars_df2["open"] = _quantize_to_tick(
                        bars_df2["open"].astype(float).values, tick=tick, mode="nearest"
                    )
                    bars_df2["close"] = _quantize_to_tick(
                        bars_df2["close"].astype(float).values, tick=tick, mode="nearest"
                    )
                    bars_df2["high"] = _quantize_to_tick(
                        bars_df2["high"].astype(float).values, tick=tick, mode="ceil"
                    )
                    bars_df2["low"] = _quantize_to_tick(
                        bars_df2["low"].astype(float).values, tick=tick, mode="floor"
                    )
                bars = build_bars_with_wrangler(bars_df2, bar_type=bar_type, instrument=instrument)
            engine.add_data(bars)
            _p(f"Added {len(bars):,} bars to engine (external bars feed)")

        # Configure strategy from YAML + overrides (built earlier so engine + strategy share the same economics)
        strategy_config = build_strategy_config(
            strategy_cfg_dict, bar_type, instrument.id, ltf_minutes=ltf_minutes_int
        )

        strategy = GoldScalperStrategy(config=strategy_config)
        engine.add_strategy(strategy)
        self.strategy = strategy

        _p(f"Strategy: {strategy_config.strategy_id}")

        # Run
        if not quiet:
            print("\n" + "=" * 60)
            print("RUNNING TICK BACKTEST...")
            print("=" * 60 + "\n")

        terminated = False
        use_streaming = use_catalog and feed == "ticks"
        try:
            engine.run(streaming=use_streaming)
        except AccountTerminatedException as exc:
            # In prop-firm mode we terminate early on hard breaches; keep reporting stable.
            terminated = True
            _p(f"[TERMINATED] {exc}")
        finally:
            # If we ran in streaming mode, explicitly end the engine before dispose().
            # Nautilus does not call end() when streaming=True.
            if use_streaming:
                try:
                    engine.end()
                except Exception:
                    pass
            if quiet:
                logging.disable(prev_disable)

        summary = self._print_results(
            reports=reports,
            start_date=start_date,
            end_date=end_date,
            feed=feed,
            source=data_source,
            sample=float(sample_rate),
            output_dir=Path(output_dir) if output_dir else None,
            terminated=terminated,
        )

        if profile:
            dt = time.perf_counter() - t0
            payload = {"event": "profile", "total_seconds": round(dt, 3)}
            if output_dir:
                try:
                    profile_path = Path(output_dir) / "profile.json"
                    profile_path.write_text(json.dumps(payload) + "\n", encoding="utf-8")
                except Exception:
                    pass
            _p(json.dumps(payload))

        engine.dispose()

        if not quiet:
            print("\n" + "=" * 60)
            print("TICK BACKTEST COMPLETE")
            print("=" * 60)
        if return_summary:
            return summary
        return None

    def _print_results(
        self,
        reports: ReportsMode,
        start_date: str,
        end_date: str,
        feed: FeedMode,
        source: DataSource,
        sample: float,
        output_dir: Path | None,
        terminated: bool,
    ) -> BacktestSummary:
        """Print backtest results and write CSV outputs."""
        engine = self.engine
        instrument = self.instrument
        assert engine is not None

        if reports in ("summary", "full"):
            print("\n" + "=" * 60)
            print("BACKTEST RESULTS")
            print("=" * 60)

        out_dir = output_dir or (Path("logs") / "backtest_latest")
        out_dir.mkdir(parents=True, exist_ok=True)

        fills: Any | None = None
        positions: Any | None = None
        account: Any | None = None

        try:
            fills = engine.trader.generate_order_fills_report()
            if reports in ("summary", "full"):
                print(f"\nOrder Fills: {len(fills)}")
                if reports == "full" and len(fills) > 0:
                    print(fills.to_string())
                elif reports == "summary" and len(fills) > 0:
                    print(fills.tail(10).to_string())
            if fills is not None and len(fills) > 0:
                fills.to_csv(out_dir / "fills.csv", index=False)
        except Exception as e:
            if reports in ("summary", "full"):
                print(f"Fills report error: {e}")

        try:
            positions = engine.trader.generate_positions_report()
            if reports in ("summary", "full"):
                print("\nPositions Report:")
                if reports == "full" and len(positions) > 0:
                    print(positions.to_string())
                elif reports == "summary" and len(positions) > 0:
                    print(positions.tail(10).to_string())
                elif len(positions) == 0:
                    print("  No positions")
            if positions is not None and len(positions) > 0:
                positions.to_csv(out_dir / "positions.csv", index=False)
        except Exception as e:
            if reports in ("summary", "full"):
                print(f"Positions report error: {e}")

        final_balance = float(self.initial_balance)
        total_pnl = 0.0
        fills_count = 0
        trades = 0
        sharpe: float | None = None
        sqn: float | None = None
        max_dd_pct: float | None = None
        commission_est = 0.0
        metrics_payload: dict[str, Any] | None = None

        try:
            account = engine.trader.generate_account_report(self.venue)
            if len(account) > 0:
                account.to_csv(out_dir / "account.csv", index=False)

            # Calculate summary
            final_balance = (
                float(account["total"].iloc[-1])
                if len(account) > 0
                else float(self.initial_balance)
            )
            fills_count = int(len(fills)) if fills is not None else 0
            # Estimate commission using configured per-lot cost (matches ExecutionModel.commission_per_lot).
            # Prefer filled quantity sum; fallback to positions peak_qty when fills report is disabled.
            filled_qty_sum = 0.0
            if fills is not None and len(fills) > 0 and "filled_qty" in fills.columns:
                try:
                    filled_qty_sum = float(fills["filled_qty"].astype(float).sum())
                except Exception:
                    filled_qty_sum = 0.0
            elif positions is not None and len(positions) > 0:
                qty_col = None
                for c in ("peak_qty", "filled_qty", "quantity"):
                    if c in positions.columns:
                        qty_col = c
                        break
                if qty_col is not None:
                    try:
                        filled_qty_sum = float(
                            pd.to_numeric(positions[qty_col], errors="coerce").fillna(0).abs().sum()
                        )
                        # positions are per completed trade; estimate both sides (entry+exit).
                        filled_qty_sum *= 2.0
                    except Exception:
                        filled_qty_sum = 0.0
            lot_size = 100.0
            if instrument is not None:
                try:
                    lot_size = float(instrument.lot_size.as_double())
                except Exception:
                    lot_size = 100.0
            filled_lots_sum = (float(filled_qty_sum) / lot_size) if lot_size > 0 else 0.0
            commission_est = float(filled_lots_sum) * float(self.commission_per_contract)
            total_pnl = final_balance - float(self.initial_balance)

            if reports in ("summary", "full"):
                print("\n" + "=" * 60)
                print("SUMMARY")
                print("=" * 60)
                print(f"Final Balance: ${final_balance:,.2f}")
                pct = (
                    (total_pnl / float(self.initial_balance) * 100.0)
                    if self.initial_balance
                    else 0.0
                )
                print(f"Total PnL: ${total_pnl:,.2f} ({pct:.2f}%)")
                if commission_est > 0:
                    print(
                        f"Commission est.: ${commission_est:,.2f} ((sum(filled_qty)/lot_size) × {self.commission_per_contract})"
                    )

            # Calculate performance metrics using MetricsCalculator (best-effort; must not break summary/trades).
            try:
                if len(account) > 1:
                    equity_series = account["total"].values
                    pnl_series: list[float] = []
                    for i in range(1, len(equity_series)):
                        trade_pnl = float(equity_series[i] - equity_series[i - 1])
                        if abs(trade_pnl) > 0.01:
                            pnl_series.append(trade_pnl)

                    if pnl_series:
                        calculator = MetricsCalculator(risk_free_rate=0.02)
                        metrics_obj = calculator.calculate(
                            pnl_series=pnl_series,
                            initial_balance=float(self.initial_balance),
                        )

                        sharpe = float(metrics_obj.sharpe_ratio)
                        sqn = float(metrics_obj.sqn)
                        max_dd_pct = float(metrics_obj.max_drawdown_pct)

                        if reports in ("summary", "full"):
                            print("\n" + "=" * 60)
                            print("PERFORMANCE METRICS")
                            print("=" * 60)
                            print(f"Total PnL:        ${metrics_obj.total_pnl:>12,.2f}")
                            print(f"Num Trades:       {metrics_obj.num_trades:>12}")
                            print(
                                f"Wins / Losses:    {metrics_obj.num_wins:>12} / {metrics_obj.num_losses}"
                            )
                            print(f"Win Rate:         {metrics_obj.win_rate:>12.1f}%")
                            print(f"Profit Factor:    {metrics_obj.profit_factor:>12.2f}")
                            print(f"Avg Win:          ${metrics_obj.avg_win:>12,.2f}")
                            print(f"Avg Loss:         ${metrics_obj.avg_loss:>12,.2f}")
                            print("-" * 60)
                            print(f"Sharpe Ratio:     {metrics_obj.sharpe_ratio:>12.3f}")
                            print(f"Sortino Ratio:    {metrics_obj.sortino_ratio:>12.3f}")
                            print(f"Calmar Ratio:     {metrics_obj.calmar_ratio:>12.3f}")
                            print(f"SQN:              {metrics_obj.sqn:>12.3f}")
                            print("-" * 60)
                            print(f"Max Drawdown:     {metrics_obj.max_drawdown_pct:>12.2f}%")
                            print(f"Std Dev:          ${metrics_obj.std_dev:>12,.2f}")
                            dd_abs = (metrics_obj.max_drawdown_pct / 100.0) * float(
                                self.initial_balance
                            )
                            recovery = (metrics_obj.total_pnl / dd_abs) if dd_abs > 0 else 0.0
                            print(f"Recovery Factor:  {recovery:>12.2f}")
                            print("=" * 60)

                        metrics = {
                            "final_balance": final_balance,
                            "total_pnl": total_pnl,
                            "fills": fills_count,
                            "commission_est": commission_est,
                            "sharpe": metrics_obj.sharpe_ratio,
                            "sortino": metrics_obj.sortino_ratio,
                            "max_drawdown_pct": metrics_obj.max_drawdown_pct,
                            "calmar": metrics_obj.calmar_ratio,
                            "sqn": metrics_obj.sqn,
                            "win_rate": metrics_obj.win_rate,
                            "profit_factor": metrics_obj.profit_factor,
                        }
                        metrics_payload = metrics
                        with open(out_dir / "metrics.json", "w", encoding="utf-8") as f:
                            json.dump(metrics, f, indent=2, default=str)
            except Exception:
                # Keep the summary output stable even if metrics fail.
                pass

            # Win rate from positions
            if positions is not None and len(positions) > 0 and "realized_pnl" in positions.columns:
                pnls = positions["realized_pnl"].apply(
                    lambda x: float(str(x).replace(" USD", "")) if pd.notna(x) else 0
                )
                wins = (pnls > 0).sum()
                losses = (pnls < 0).sum()
                total = wins + losses
                trades = int(total)
                if reports in ("summary", "full"):
                    print(f"Trades: {total} (W:{wins} L:{losses})")
                if total > 0:
                    if reports in ("summary", "full"):
                        print(f"Win Rate: {wins / total * 100:.1f}%")
                        print(f"Avg PnL/trade: ${pnls.mean():.2f}")
            if reports == "full":
                print("\nAccount Report:")
                if account is not None:
                    print(account.to_string())
        except Exception as e:
            if reports in ("summary", "full"):
                print(f"Account report error: {e}")

        if self.metrics_jsonl:
            payload = metrics_payload or {
                "final_balance": float(final_balance),
                "total_pnl": float(total_pnl),
                "fills": int(fills_count),
                "commission_est": float(commission_est),
                "sharpe": sharpe,
                "sqn": sqn,
                "max_drawdown_pct": max_dd_pct,
            }
            record = {
                "ts_utc": datetime.now(timezone.utc).isoformat(),
                "start_date": start_date,
                "end_date": end_date,
                "feed": feed,
                "source": source,
                "sample": float(sample),
                "initial_balance": float(self.initial_balance),
                "terminated": bool(terminated),
                "metrics": payload,
            }
            out_path = Path(self.metrics_jsonl)
            out_path.parent.mkdir(parents=True, exist_ok=True)
            with open(out_path, "a", encoding="utf-8") as f:
                f.write(json.dumps(record, default=str) + "\n")

        # Strategy stats
        try:
            for strategy in engine.trader.strategies():
                if hasattr(strategy, "stats"):
                    if reports in ("summary", "full"):
                        print(f"\nStrategy Stats ({strategy.id}):")
                        for k, v in strategy.stats.items():
                            print(f"  {k}: {v}")
        except Exception:
            pass
        return BacktestSummary(
            start_date=start_date,
            end_date=end_date,
            feed=feed,
            source=source,
            sample=sample,
            initial_balance=float(self.initial_balance),
            final_balance=float(final_balance),
            total_pnl=float(total_pnl),
            fills=int(fills_count),
            trades=int(trades),
            terminated=bool(terminated),
            max_drawdown_pct=max_dd_pct,
            sharpe=sharpe,
            sqn=sqn,
        )


def _split_csv(value: str | None) -> list[str]:
    if not value:
        return []
    return [p.strip() for p in value.split(",") if p.strip()]


def _pick_best_catalog(matches: list[Path]) -> Path:
    """Prefer stride1 when multiple catalogs match a session name."""
    if len(matches) == 1:
        return matches[0]
    stride1 = [p for p in matches if "stride1" in p.name.lower()]
    if stride1:
        return sorted(stride1, key=lambda p: p.name.lower())[0]
    return sorted(matches, key=lambda p: p.name.lower())[0]


def _resolve_session_catalogs(
    *,
    repo_root: Path,
    sessions_root: str,
    product: Product,
    sessions: list[str] | None,
    all_sessions: bool,
) -> list[str]:
    root = Path(sessions_root)
    root_path = root.resolve() if root.is_absolute() else (repo_root / root).resolve()
    if not root_path.exists():
        raise FileNotFoundError(f"sessions_root not found: {root_path}")
    if not root_path.is_dir():
        raise NotADirectoryError(f"sessions_root is not a directory: {root_path}")

    all_dirs = [p for p in root_path.iterdir() if p.is_dir() and not p.name.endswith("_OLD")]
    prod_key = product.lower()
    all_dirs = [p for p in all_dirs if prod_key in p.name.lower()]

    if all_sessions:
        selected = sorted(all_dirs, key=lambda p: p.name.lower())
        return [str(p) for p in selected]

    wanted = [s.strip().upper() for s in (sessions or []) if s.strip()]
    if not wanted:
        return []

    selected_paths: list[str] = []
    for sess in wanted:
        matches = [p for p in all_dirs if p.name.upper().endswith(f"_{sess}")]
        if not matches:
            raise FileNotFoundError(f"No catalog found for session={sess!r} under {root_path}")
        chosen = _pick_best_catalog(matches)
        selected_paths.append(str(chosen))
    return selected_paths


def main() -> None:
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(
        description="Run Nautilus backtest (XAUUSD spot or MGC futures economics)"
    )
    parser.add_argument("--start", default="2024-01-01", help="Start date")
    parser.add_argument("--end", default="2024-03-31", help="End date")
    parser.add_argument(
        "--product",
        choices=["xauusd", "mgc"],
        default="mgc",
        help="Instrument product to simulate",
    )
    parser.add_argument(
        "--gateway",
        choices=["rithmic", "tradovate"],
        default="tradovate",
        help="Apex gateway (commission schedule)",
    )
    parser.add_argument(
        "--threshold", type=int, default=None, help="Execution threshold (overrides config)"
    )
    parser.add_argument(
        "--sample", type=float, default=1.0, help="Sampling: float fraction (0-1) or N-step (>=1)"
    )
    parser.add_argument(
        "--ltf-minutes", type=int, default=15, help="LTF bar interval in minutes (default: 15)"
    )
    parser.add_argument("--feed", choices=["ticks", "bars"], default="ticks", help="Data feed mode")
    parser.add_argument(
        "--source",
        choices=["auto", "parquet", "catalog"],
        default="auto",
        help="Data source selection",
    )
    parser.add_argument("--profile", action="store_true", help="Print coarse timing JSON")
    parser.add_argument(
        "--reports",
        choices=["none", "summary", "full"],
        default="summary",
        help="Console reporting level",
    )
    parser.add_argument(
        "--bars-file",
        default=None,
        help=(
            "Optional M5 bars CSV file for fast screening (feed=bars). "
            "Use --bars-timestamp-basis to specify whether timestamps are bar-open or bar-close."
        ),
    )
    parser.add_argument(
        "--bars-timestamp-basis",
        choices=["open", "close"],
        default=None,
        help=(
            "Bars timestamp basis for --bars-file: 'open' (bar start, shift +duration) or 'close' "
            "(already bar close, no shift). Default preserves current behavior: 'open'."
        ),
    )
    parser.add_argument("--sweep", action="store_true", help="Run parameter sweep")
    parser.add_argument(
        "--smoke-matrix",
        action="store_true",
        help=(
            "Run a fast stride20 smoke matrix (short window) to validate feature flags wiring. "
            "Uses parquet stride20, feed=ticks, and prints a compact pass/fail table."
        ),
    )
    parser.add_argument("--no-news", action="store_true", help="Disable news filter")
    parser.add_argument(
        "--news-events-path",
        default=None,
        help="Optional local NewsCalendar CSV/JSON path (overrides YAML news.events_path)",
    )
    parser.add_argument(
        "--no-session-filter",
        action="store_true",
        help="Disable session filter (useful for session-sliced catalogs)",
    )
    parser.add_argument("--no-regime-filter", action="store_true", help="Disable regime filter")
    parser.add_argument("--no-mtf", action="store_true", help="Disable MTF manager")
    parser.add_argument(
        "--no-virtual-gate",
        action="store_true",
        help="Disable VirtualGate (Phase 11 Safety Layer)",
    )
    parser.add_argument(
        "--no-vol-spacing",
        action="store_true",
        help="Disable volatility spacing (Phase 11 Safety Layer)",
    )
    parser.add_argument(
        "--no-exposure-caps",
        action="store_true",
        help="Disable exposure caps (Phase 11 Safety Layer)",
    )
    parser.add_argument(
        "--disable-smc",
        action="store_true",
        help="Disable SMC path (overrides YAML execution.enable_smc)",
    )
    parser.add_argument(
        "--enable-trend-follow",
        action="store_true",
        help="Enable TrendFollow path (overrides YAML execution.enable_trend_follow)",
    )
    parser.add_argument(
        "--trend-follow-mode",
        choices=["PULLBACK_ONLY", "BREAKOUT_ONLY", "BOTH"],
        default=None,
        help="Override YAML execution.trend_follow_mode (only if TrendFollow enabled)",
    )
    parser.add_argument(
        "--enable-mean-revert",
        action="store_true",
        help="Enable MeanRevert path (overrides YAML execution.enable_mean_revert; forces use_selector=true)",
    )
    parser.add_argument(
        "--mr-only",
        action="store_true",
        help="Trade only MeanRevert (disables SMC + TrendFollow; forces use_selector=true)",
    )
    parser.add_argument(
        "--no-footprint", action="store_true", help="Disable footprint/orderflow component"
    )
    parser.add_argument(
        "--no-prop", action="store_true", help="Disable prop-firm rules (for diagnostics only)"
    )
    parser.add_argument(
        "--certify",
        action="store_true",
        help=(
            "Institutional-grade certification mode: forces ticks feed, telemetry, "
            "prop-firm rules, and runs Apex compliance validator post-backtest. "
            "Auto-creates output directory under logs/certify_<timestamp>/. "
            "Exits non-zero if compliance validation fails."
        ),
    )
    # Default config path relative to script location (works from any CWD)
    _default_config = str(Path(__file__).parent.parent.parent / "configs" / "strategy_config.yaml")
    parser.add_argument("--config", default=_default_config, help="Path to strategy YAML")
    parser.add_argument("--latency", type=int, default=None, help="Simulated latency in ms")
    parser.add_argument(
        "--slippage", type=int, default=None, help="Slippage in ticks (overrides config)"
    )
    parser.add_argument(
        "--commission", type=float, default=None, help="Commission per contract (overrides config)"
    )
    parser.add_argument(
        "--partial-prob", type=float, default=None, help="Partial fill probability (0-1)"
    )
    parser.add_argument(
        "--partial-ratio", type=float, default=None, help="Partial fill ratio (0-1)"
    )
    parser.add_argument(
        "--metrics-jsonl", default=None, help="Optional path to write metrics JSONL"
    )
    parser.add_argument(
        "--out-dir", default=None, help="Optional output dir for reports (fills/positions/account)"
    )
    parser.add_argument(
        "--quiet",
        action="store_true",
        help="Suppress console + logging noise (recommended for sweeps)",
    )
    parser.add_argument(
        "--telemetry-path", default=None, help="Override YAML telemetry.path (JSONL)"
    )
    parser.add_argument(
        "--require-telemetry",
        action=argparse.BooleanOptionalAction,
        default=True,
        help="Require telemetry artifacts for Apex compliance (default: True). "
        "Use --no-require-telemetry to disable this gate.",
    )
    parser.add_argument(
        "--ml-capture",
        action="store_true",
        help="Enable ML snapshot capture to telemetry (ml_snapshot events)",
    )
    parser.add_argument(
        "--catalog-path",
        default=None,
        help="Override native catalog dir (relative to repo root), e.g. data/catalog_native_sessions/... (source=catalog)",
    )
    parser.add_argument(
        "--catalog-paths",
        default=None,
        help="Comma-separated catalog dirs (absolute or repo-relative). Overrides --catalog-path.",
    )
    parser.add_argument(
        "--fidelity-stride1",
        action="store_true",
        help=(
            "Run a stride20 vs stride1 fidelity check on the SAME time window. "
            "Requires tick feed; runs parquet stride20 and catalog stride1, then compares key metrics."
        ),
    )
    parser.add_argument(
        "--sessions-root",
        default="data/catalog_native_sessions",
        help="Root folder for session-sliced catalogs (repo-relative by default).",
    )
    parser.add_argument(
        "--sessions",
        default=None,
        help="Comma-separated session names to include (e.g. EVENING,LATE_NY).",
    )
    parser.add_argument(
        "--all-sessions",
        action="store_true",
        help="Include all session catalogs under --sessions-root (product-filtered).",
    )
    parser.add_argument(
        "--risk",
        type=float,
        default=None,
        help="Risk per trade (fraction, e.g. 0.005 = 0.5 percent)",
    )
    parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        help="Enable detailed score debugging (logs every confluence calculation)",
    )
    parser.add_argument(
        "--isolate",
        default=None,
        choices=[
            "structure",
            "regime",
            "session",
            "ob",
            "fvg",
            "sweep",
            "amd",
            "fib",
            "mtf",
            "footprint",
        ],
        help="Isolate a single indicator for testing (sets only that weight to 100, others to 0)",
    )
    # TrendFollow parameter overrides for sensitivity sweeps (Oracle/CRITIC recommendations)
    parser.add_argument(
        "--trend-sep-ticks",
        type=float,
        default=None,
        help="EMA separation threshold in ticks (default: 4.0)",
    )
    parser.add_argument(
        "--trend-touch-dist-mult",
        type=float,
        default=None,
        help="Touch distance as ATR multiplier (default: 0.35)",
    )
    parser.add_argument(
        "--trend-min-score",
        type=float,
        default=None,
        help="Minimum signal score threshold (default: 60.0)",
    )
    parser.add_argument(
        "--trend-ma-type",
        choices=["EMA", "SMA", "WMA", "HMA"],
        default=None,
        help="Moving average type for TrendFollow (default: EMA)",
    )
    parser.add_argument(
        "--trend-ema-fast",
        type=int,
        default=None,
        help="Fast MA period for TrendFollow (default: 20)",
    )
    parser.add_argument(
        "--trend-ema-slow",
        type=int,
        default=None,
        help="Slow MA period for TrendFollow (default: 50)",
    )
    parser.add_argument(
        "--trend-pullback-require-recross",
        action="store_true",
        default=None,
        help="Require EMA recross for pullback entries",
    )
    parser.add_argument(
        "--trend-pullback-recross-lookback",
        type=int,
        default=None,
        help="Recross lookback bars (default: 3)",
    )
    parser.add_argument(
        "--trend-er-enabled",
        action="store_true",
        default=None,
        help="Enable Kaufman Efficiency Ratio gate for breakouts",
    )
    parser.add_argument(
        "--trend-er-min",
        type=float,
        default=None,
        help="Minimum ER to allow breakout candidates (default: 0.40)",
    )
    parser.add_argument(
        "--ghost-mode",
        action="store_true",
        help="Ghost Test: randomize signal directions to test filter edge",
    )
    parser.add_argument(
        "--ghost-seed",
        type=int,
        default=None,
        help="Ghost Test seed for deterministic runs (default: 1337)",
    )
    parser.add_argument(
        "--trend-direction-mode",
        choices=["NORMAL", "INVERT"],
        default=None,
        help="TrendFollow direction ablation (NORMAL or INVERT).",
    )
    parser.add_argument(
        "--psar-enabled",
        action="store_true",
        help="Enable Parabolic SAR (PSAR) alignment filter (overrides YAML).",
    )
    parser.add_argument(
        "--psar-use-prev-bar",
        choices=["trend", "smc", "both", "none"],
        default=None,
        help='PSAR index selection: use t-1 for trend/smc/both, or use last bar with "none".',
    )
    args = parser.parse_args()

    # ---------------------------------------------------------------------------
    # Certification mode preflight and setup (--certify)
    # ---------------------------------------------------------------------------
    certify_mode: bool = getattr(args, "certify", False)
    certify_out_dir: Path | None = None

    if certify_mode:
        # Preflight checks: fail fast before any heavy work
        try:
            certify_preflight_checks(feed=args.feed, no_prop=args.no_prop)
        except CertifyPreflightError as e:
            sys.exit(f"CERTIFY PREFLIGHT FAILED: {e}")

        # Auto-create output directory if not provided
        if args.out_dir:
            certify_out_dir = Path(args.out_dir)
            certify_out_dir.mkdir(parents=True, exist_ok=True)
        else:
            certify_out_dir = resolve_certify_output_dir(
                product=args.product, start=args.start, end=args.end
            )
            # Override args.out_dir so downstream logic uses it
            args.out_dir = str(certify_out_dir)

        # Force telemetry enabled with path inside out-dir
        if args.telemetry_path is None:
            args.telemetry_path = str(certify_out_dir / "telemetry.jsonl")

        # Force require_telemetry=True for certification
        args.require_telemetry = True

        print(f"[CERTIFY] Output directory: {certify_out_dir}")
        print(f"[CERTIFY] Telemetry path: {args.telemetry_path}")

    config_path = Path(args.config)
    cfg = load_yaml_config(config_path)
    exec_cfg = cfg.get("execution", {}) if isinstance(cfg, dict) else {}

    config_overrides: dict[str, object] | None = None

    # Bars timestamp basis override: CLI wins over YAML; conflicts fail closed.
    if args.bars_timestamp_basis is not None:
        cli_basis = _parse_bars_timestamp_basis(
            args.bars_timestamp_basis, field="--bars-timestamp-basis"
        )
        yaml_basis: BarsTimestampBasis | None = None
        if isinstance(exec_cfg, dict) and exec_cfg.get("bars_timestamp_basis") is not None:
            yaml_basis = _parse_bars_timestamp_basis(
                exec_cfg.get("bars_timestamp_basis"), field="execution.bars_timestamp_basis"
            )
        if yaml_basis is not None and yaml_basis != cli_basis:
            raise ValueError(
                "Conflicting bars timestamp basis: "
                f"CLI --bars-timestamp-basis={cli_basis!r} vs YAML execution.bars_timestamp_basis={yaml_basis!r}"
            )
        config_overrides = config_overrides or {}
        config_overrides.setdefault("execution", {})
        exec_over = config_overrides.get("execution")
        if isinstance(exec_over, dict):
            exec_over["bars_timestamp_basis"] = cli_basis

    if args.news_events_path:
        config_overrides = config_overrides or {}
        config_overrides.setdefault("news", {})
        news_over = config_overrides.get("news")
        if isinstance(news_over, dict):
            news_over["events_path"] = args.news_events_path

    # Telemetry hard-gate for Apex compliance (default: require telemetry artifacts)
    # This ensures backtest runs intended for Apex compliance always produce telemetry.
    require_telemetry: bool = getattr(args, "require_telemetry", True)
    effective_telemetry_path: str | None = args.telemetry_path

    if require_telemetry:
        # Must have telemetry path - fail closed if missing
        if effective_telemetry_path is None:
            if args.out_dir:
                effective_telemetry_path = str(Path(args.out_dir) / "telemetry.jsonl")
            else:
                sys.exit(
                    "ERROR: Telemetry required for Apex compliance. "
                    "Pass --telemetry-path <path> or --out-dir <dir> (auto-creates telemetry.jsonl). "
                    "Use --no-require-telemetry to disable this gate."
                )
    else:
        # Not required, but auto-set for reproducibility if reports enabled and out_dir provided
        if effective_telemetry_path is None and args.reports != "none" and args.out_dir:
            effective_telemetry_path = str(Path(args.out_dir) / "telemetry.jsonl")

    # Apply telemetry overrides if we have a path
    if effective_telemetry_path:
        config_overrides = config_overrides or {}
        config_overrides.setdefault("telemetry", {})
        tel_over = config_overrides.get("telemetry")
        if isinstance(tel_over, dict):
            tel_over["path"] = effective_telemetry_path
            if require_telemetry:
                tel_over["enabled"] = True

    if args.ml_capture:
        config_overrides = config_overrides or {}
        config_overrides.setdefault("ml", {})
        ml_over = config_overrides.get("ml")
        if isinstance(ml_over, dict):
            ml_over["capture_enabled"] = True

    # Safety Layer overrides (avoid editing YAML for quick experiments)
    if args.no_virtual_gate or args.no_vol_spacing or args.no_exposure_caps:
        config_overrides = config_overrides or {}
        config_overrides.setdefault("execution", {})
        exec_over = config_overrides.get("execution")
        if isinstance(exec_over, dict):
            if args.no_virtual_gate:
                exec_over["virtual_gate_enabled"] = False
            if args.no_vol_spacing:
                exec_over["vol_spacing_max_seconds"] = 0.0
            if args.no_exposure_caps:
                exec_over["max_concurrent_positions"] = 99
                exec_over["max_concurrent_instruments"] = 99

    # TrendFollow/SMC overrides (avoid editing YAML for quick experiments)
    if args.disable_smc or args.enable_trend_follow or (args.trend_follow_mode is not None):
        config_overrides = config_overrides or {}
        config_overrides.setdefault("execution", {})
        exec_over = config_overrides.get("execution")
        if isinstance(exec_over, dict):
            if args.disable_smc:
                exec_over["enable_smc"] = False
            if args.enable_trend_follow:
                exec_over["enable_trend_follow"] = True
            if args.trend_follow_mode is not None:
                exec_over["trend_follow_mode"] = str(args.trend_follow_mode)

    # MeanRevert overrides
    if args.enable_mean_revert or args.mr_only:
        config_overrides = config_overrides or {}
        config_overrides.setdefault("execution", {})
        exec_over = config_overrides.get("execution")
        if isinstance(exec_over, dict):
            exec_over["enable_mean_revert"] = True
            exec_over["use_selector"] = True
            if args.mr_only:
                exec_over["enable_smc"] = False
                exec_over["enable_trend_follow"] = False

    # TrendFollow parameter overrides (sensitivity sweeps per Oracle/CRITIC)
    _tf_param_override = (
        getattr(args, "trend_sep_ticks", None) is not None
        or getattr(args, "trend_touch_dist_mult", None) is not None
        or getattr(args, "trend_min_score", None) is not None
        or getattr(args, "trend_ma_type", None) is not None
        or getattr(args, "trend_ema_fast", None) is not None
        or getattr(args, "trend_ema_slow", None) is not None
        or getattr(args, "trend_pullback_require_recross", None) is not None
        or getattr(args, "trend_pullback_recross_lookback", None) is not None
        or getattr(args, "trend_er_enabled", None) is not None
        or getattr(args, "trend_er_min", None) is not None
        or getattr(args, "ghost_mode", False)
        or getattr(args, "ghost_seed", None) is not None
    )
    if _tf_param_override:
        config_overrides = config_overrides or {}
        config_overrides.setdefault("execution", {})
        exec_over = config_overrides.get("execution")
        if isinstance(exec_over, dict):
            if getattr(args, "trend_sep_ticks", None) is not None:
                exec_over["trend_sep_ticks_min"] = float(args.trend_sep_ticks)
            if getattr(args, "trend_touch_dist_mult", None) is not None:
                exec_over["trend_touch_dist_mult"] = float(args.trend_touch_dist_mult)
            if getattr(args, "trend_min_score", None) is not None:
                exec_over["trend_min_score"] = float(args.trend_min_score)
            if getattr(args, "trend_ma_type", None) is not None:
                exec_over["trend_ma_type"] = str(args.trend_ma_type)
            if getattr(args, "trend_ema_fast", None) is not None:
                exec_over["trend_ema_fast"] = int(args.trend_ema_fast)
            if getattr(args, "trend_ema_slow", None) is not None:
                exec_over["trend_ema_slow"] = int(args.trend_ema_slow)
            if getattr(args, "trend_pullback_require_recross", None) is not None:
                exec_over["trend_pullback_require_recross"] = bool(
                    args.trend_pullback_require_recross
                )
            if getattr(args, "trend_pullback_recross_lookback", None) is not None:
                exec_over["trend_pullback_recross_lookback"] = int(
                    args.trend_pullback_recross_lookback
                )
            if getattr(args, "trend_er_enabled", None) is not None:
                exec_over["trend_er_enabled"] = bool(args.trend_er_enabled)
            if getattr(args, "trend_er_min", None) is not None:
                exec_over["trend_er_min"] = float(args.trend_er_min)
            if getattr(args, "trend_direction_mode", None) is not None:
                exec_over["trend_direction_mode"] = str(args.trend_direction_mode)
            if getattr(args, "ghost_mode", False):
                exec_over["ghost_mode"] = True
            if getattr(args, "ghost_seed", None) is not None:
                exec_over["ghost_seed"] = int(args.ghost_seed)
            if getattr(args, "psar_enabled", False):
                exec_over["psar_enabled"] = True
            if getattr(args, "psar_use_prev_bar", None) is not None:
                sel = str(args.psar_use_prev_bar).strip().lower()
                if sel == "none":
                    exec_over["psar_trend_use_prev_bar"] = False
                    exec_over["psar_smc_use_prev_bar"] = False
                elif sel == "trend":
                    exec_over["psar_trend_use_prev_bar"] = True
                elif sel == "smc":
                    exec_over["psar_smc_use_prev_bar"] = True
                elif sel == "both":
                    exec_over["psar_trend_use_prev_bar"] = True
                    exec_over["psar_smc_use_prev_bar"] = True

    # --isolate: override confluence weights to test single indicator
    if args.isolate:
        indicator_map = {
            "structure": "structure",
            "regime": "regime",
            "session": None,  # session is scored separately
            "ob": "order_block",
            "fvg": "fvg",
            "sweep": "liquidity_sweep",
            "amd": "amd_cycle",
            "fib": "fib",
            "mtf": "mtf",
            "footprint": "footprint",
        }
        # Zero out all weights, then set isolated one to 100
        isolated_weights = {k: 0 for k in indicator_map.values() if k}
        yaml_key = indicator_map.get(args.isolate)
        if yaml_key:
            isolated_weights[yaml_key] = 100
        config_overrides = config_overrides or {}
        config_overrides["confluence"] = config_overrides.get("confluence", {})
        if isinstance(config_overrides["confluence"], dict):
            config_overrides["confluence"]["weights"] = isolated_weights
        print(f"[ISOLATE] Testing only '{args.isolate}' indicator (weight=100, others=0)")

    threshold = (
        args.threshold if args.threshold is not None else exec_cfg.get("execution_threshold", 70)
    )
    slippage_ticks = (
        args.slippage if args.slippage is not None else exec_cfg.get("slippage_ticks", 2)
    )
    if args.commission is not None:
        commission = float(args.commission)
    else:
        commission_source = str(exec_cfg.get("commission_source", "manual")).strip().lower()
        commission_profile = str(exec_cfg.get("commission_profile", "apex")).strip().lower()
        commission_gateway = str(exec_cfg.get("commission_gateway", args.gateway)).strip().lower()

        if commission_source == "schedule":
            from nautilus_gold_scalper.src.execution.commission_schedule import (
                commission_per_side_usd,
            )

            commission = float(
                commission_per_side_usd(
                    profile=cast(Any, commission_profile),
                    product=cast(Any, cast(Product, args.product)),
                    gateway=cast(Any, cast(Gateway, commission_gateway)),
                )
            )
        elif args.product == "mgc":
            # Backward-compat for older configs/tests.
            commission = apex_commission_per_side("mgc", cast(Gateway, args.gateway))
        else:
            commission = float(exec_cfg.get("commission_per_contract", 2.5))
    latency_ms = args.latency if args.latency is not None else (exec_cfg.get("latency_ms") or 0)
    partial_prob = (
        args.partial_prob
        if args.partial_prob is not None
        else (exec_cfg.get("partial_fill_prob") or 0.0)
    )
    partial_ratio = (
        args.partial_ratio
        if args.partial_ratio is not None
        else (exec_cfg.get("partial_fill_ratio") or 0.5)
    )
    metrics_jsonl = args.metrics_jsonl

    # BUG-2 FIX: Resolve session/regime filter settings from config when CLI flags not explicitly set.
    # Previously, --no-session-filter (action='store_true') always defaulted to False when not passed,
    # which was then inverted to use_session_filter=True, ignoring the config file setting.
    # Formula: if CLI flag explicitly set (True), force disable; else use config value.
    # Example: config has use_session_filter=false, no CLI flag -> should be False (was True before fix)
    resolved_use_session_filter = (
        False if args.no_session_filter else exec_cfg.get("use_session_filter", True)
    )
    resolved_use_regime_filter = (
        False if args.no_regime_filter else exec_cfg.get("use_regime_filter", True)
    )
    resolved_use_mtf = False if args.no_mtf else exec_cfg.get("use_mtf", True)
    resolved_use_footprint = False if args.no_footprint else exec_cfg.get("use_footprint", True)
    resolved_prop_firm_enabled = False if args.no_prop else exec_cfg.get("prop_firm_enabled", True)
    resolved_use_news_filter = False if args.no_news else exec_cfg.get("use_news_filter", True)

    runner_log_level = "ERROR" if args.quiet else ("ERROR" if args.sweep else "INFO")
    runner = BacktestRunner(
        initial_balance=exec_cfg.get("initial_balance", 100_000.0),
        log_level=runner_log_level,
        slippage_ticks=slippage_ticks,
        commission_per_contract=commission,
        product=cast(Product, args.product),
        gateway=cast(Gateway, args.gateway),
        latency_ms=latency_ms,
        partial_fill_prob=partial_prob,
        partial_fill_ratio=partial_ratio,
        fill_model=str(exec_cfg.get("fill_model", "realistic")),
        seed=int(exec_cfg.get("seed", 42)),
    )
    runner.metrics_jsonl = metrics_jsonl

    project_root = Path(__file__).parent.parent.parent
    repo_root = project_root.parent

    catalog_paths: list[str] | None = None
    explicit_catalog_paths = _split_csv(args.catalog_paths)
    if explicit_catalog_paths:
        catalog_paths = explicit_catalog_paths
    elif args.all_sessions or args.sessions:
        sessions = _split_csv(args.sessions)
        resolved = _resolve_session_catalogs(
            repo_root=repo_root,
            sessions_root=str(args.sessions_root),
            product=cast(Product, args.product),
            sessions=sessions,
            all_sessions=bool(args.all_sessions),
        )
        catalog_paths = resolved if resolved else None

    if args.smoke_matrix:
        # Fast validation harness: run a short, deterministic matrix of feature toggles
        # using the default parquet stride20 dataset.
        import datetime as _dt

        start_dt = _dt.date.fromisoformat(str(args.start))
        end_dt = _dt.date.fromisoformat(str(args.end))
        max_days = 5
        if (end_dt - start_dt).days + 1 > max_days:
            end_dt = start_dt + _dt.timedelta(days=max_days - 1)

        smoke_start = start_dt.isoformat()
        smoke_end = end_dt.isoformat()

        # Base overrides from CLI (e.g., telemetry path, news file) are respected.
        base_overrides = copy.deepcopy(config_overrides) if config_overrides is not None else None

        def _case_overrides(extra: dict[str, Any] | None) -> dict[str, Any] | None:
            if base_overrides is None and not extra:
                return None
            merged: dict[str, Any] = (
                copy.deepcopy(base_overrides) if base_overrides is not None else {}
            )
            if extra:
                _deep_update(merged, extra)
            return merged

        cases: list[tuple[str, dict[str, Any] | None, dict[str, Any]]] = [
            (
                "baseline",
                None,
                {
                    "use_session_filter": resolved_use_session_filter,
                    "use_regime_filter": resolved_use_regime_filter,
                    "use_mtf": resolved_use_mtf,
                    "use_footprint": resolved_use_footprint,
                    "prop_firm_enabled": resolved_prop_firm_enabled,
                    "use_news_filter": resolved_use_news_filter,
                },
            ),
            (
                "baseline_repeat",
                None,
                {
                    "use_session_filter": resolved_use_session_filter,
                    "use_regime_filter": resolved_use_regime_filter,
                    "use_mtf": resolved_use_mtf,
                    "use_footprint": resolved_use_footprint,
                    "prop_firm_enabled": resolved_prop_firm_enabled,
                    "use_news_filter": resolved_use_news_filter,
                },
            ),
            (
                "no_news",
                None,
                {
                    "use_session_filter": resolved_use_session_filter,
                    "use_regime_filter": resolved_use_regime_filter,
                    "use_mtf": resolved_use_mtf,
                    "use_footprint": resolved_use_footprint,
                    "prop_firm_enabled": resolved_prop_firm_enabled,
                    "use_news_filter": False,
                },
            ),
            (
                "no_session_filter",
                None,
                {
                    "use_session_filter": False,
                    "use_regime_filter": resolved_use_regime_filter,
                    "use_mtf": resolved_use_mtf,
                    "use_footprint": resolved_use_footprint,
                    "prop_firm_enabled": resolved_prop_firm_enabled,
                    "use_news_filter": resolved_use_news_filter,
                },
            ),
            (
                "no_regime_filter",
                None,
                {
                    "use_session_filter": resolved_use_session_filter,
                    "use_regime_filter": False,
                    "use_mtf": resolved_use_mtf,
                    "use_footprint": resolved_use_footprint,
                    "prop_firm_enabled": resolved_prop_firm_enabled,
                    "use_news_filter": resolved_use_news_filter,
                },
            ),
            (
                "no_mtf",
                None,
                {
                    "use_session_filter": resolved_use_session_filter,
                    "use_regime_filter": resolved_use_regime_filter,
                    "use_mtf": False,
                    "use_footprint": resolved_use_footprint,
                    "prop_firm_enabled": resolved_prop_firm_enabled,
                    "use_news_filter": resolved_use_news_filter,
                },
            ),
            (
                "no_virtual_gate",
                {"execution": {"virtual_gate_enabled": False}},
                {
                    "use_session_filter": resolved_use_session_filter,
                    "use_regime_filter": resolved_use_regime_filter,
                    "use_mtf": resolved_use_mtf,
                    "use_footprint": resolved_use_footprint,
                    "prop_firm_enabled": resolved_prop_firm_enabled,
                    "use_news_filter": resolved_use_news_filter,
                },
            ),
            (
                "no_vol_spacing",
                {"execution": {"vol_spacing_max_seconds": 0.0}},
                {
                    "use_session_filter": resolved_use_session_filter,
                    "use_regime_filter": resolved_use_regime_filter,
                    "use_mtf": resolved_use_mtf,
                    "use_footprint": resolved_use_footprint,
                    "prop_firm_enabled": resolved_prop_firm_enabled,
                    "use_news_filter": resolved_use_news_filter,
                },
            ),
            (
                "no_exposure_caps",
                {"execution": {"max_concurrent_positions": 99, "max_concurrent_instruments": 99}},
                {
                    "use_session_filter": resolved_use_session_filter,
                    "use_regime_filter": resolved_use_regime_filter,
                    "use_mtf": resolved_use_mtf,
                    "use_footprint": resolved_use_footprint,
                    "prop_firm_enabled": resolved_prop_firm_enabled,
                    "use_news_filter": resolved_use_news_filter,
                },
            ),
            (
                "mr_only",
                {
                    "execution": {
                        "enable_mean_revert": True,
                        "use_selector": True,
                        "enable_smc": False,
                        "enable_trend_follow": False,
                    }
                },
                {
                    "use_session_filter": resolved_use_session_filter,
                    "use_regime_filter": resolved_use_regime_filter,
                    "use_mtf": resolved_use_mtf,
                    "use_footprint": resolved_use_footprint,
                    "prop_firm_enabled": resolved_prop_firm_enabled,
                    "use_news_filter": resolved_use_news_filter,
                },
            ),
        ]

        print("\n" + "=" * 60)
        print("SMOKE MATRIX (stride20 parquet)")
        print("=" * 60)
        print(f"Window: {smoke_start} to {smoke_end} (clamped to <= {max_days} days)")
        print("Mode: feed=ticks, source=parquet")
        print("\nCASE\tOK\tTRADES\tFILLS\tPNL\tTERMINATED")

        baseline_signature: tuple[int, int, float, bool] | None = None

        for name, extra_overrides, params in cases:
            try:
                runner_case = BacktestRunner(
                    initial_balance=exec_cfg.get("initial_balance", 100_000.0),
                    log_level="ERROR",
                    slippage_ticks=int(slippage_ticks),
                    commission_per_contract=float(commission),
                    product=cast(Product, args.product),
                    gateway=cast(Gateway, args.gateway),
                    latency_ms=int(latency_ms),
                    partial_fill_prob=float(partial_prob),
                    partial_fill_ratio=float(partial_ratio),
                    fill_model=str(exec_cfg.get("fill_model", "realistic")),
                )
                summary = runner_case.run(
                    start_date=smoke_start,
                    end_date=smoke_end,
                    ltf_minutes=int(args.ltf_minutes),
                    sample_rate=float(args.sample),
                    use_session_filter=bool(params["use_session_filter"]),
                    use_regime_filter=bool(params["use_regime_filter"]),
                    use_mtf=bool(params["use_mtf"]),
                    use_footprint=bool(params["use_footprint"]),
                    prop_firm_enabled=bool(params["prop_firm_enabled"]),
                    use_news_filter=bool(params["use_news_filter"]),
                    execution_threshold=int(threshold),
                    debug_mode=False,
                    feed="ticks",
                    data_source="parquet",
                    profile=False,
                    reports="none",
                    bars_file=None,
                    output_dir=None,
                    risk_per_trade=args.risk,
                    product=cast(Product, args.product),
                    gateway=cast(Gateway, args.gateway),
                    quiet=True,
                    catalog_path=None,
                    catalog_paths=None,
                    strategy_config_path=config_path,
                    config_overrides=_case_overrides(extra_overrides),
                    return_summary=True,
                )

                if summary is None:
                    raise RuntimeError("BacktestRunner returned no summary")

                sig = (
                    int(summary.trades),
                    int(summary.fills),
                    float(summary.total_pnl),
                    bool(summary.terminated),
                )
                if name == "baseline":
                    baseline_signature = sig
                if (
                    name == "baseline_repeat"
                    and baseline_signature is not None
                    and sig != baseline_signature
                ):
                    raise RuntimeError(
                        f"Non-deterministic baseline: expected {baseline_signature}, got {sig}"
                    )

                print(
                    f"{name}\tOK\t{summary.trades}\t{summary.fills}\t{summary.total_pnl:.2f}\t{int(summary.terminated)}"
                )
            except Exception as exc:
                print(f"{name}\tFAIL\t0\t0\t0.00\t0\t# {type(exc).__name__}: {exc}")

        return

    if args.fidelity_stride1:
        if args.feed != "ticks":
            raise ValueError("--fidelity-stride1 requires --feed=ticks")

        if cast(Product, args.product) != "xauusd":
            raise TickSourceMismatchError(
                "--fidelity-stride1 is only supported for product=xauusd (spot). "
                "MGC uses a different data source and cannot be compared tick-for-tick."
            )

        # Keep this run deterministic and comparable: force same strategy config + same window,
        # but different tick sources.
        base_kwargs = dict(
            start_date=args.start,
            end_date=args.end,
            ltf_minutes=int(args.ltf_minutes),
            sample_rate=1.0,
            use_session_filter=resolved_use_session_filter,
            use_regime_filter=resolved_use_regime_filter,
            use_mtf=resolved_use_mtf,
            use_footprint=resolved_use_footprint,
            prop_firm_enabled=resolved_prop_firm_enabled,
            use_news_filter=resolved_use_news_filter,
            execution_threshold=int(threshold),
            debug_mode=False,
            feed="ticks",
            profile=bool(args.profile),
            reports="none",
            bars_file=None,
            output_dir=None,
            risk_per_trade=args.risk,
            product=cast(Product, args.product),
            gateway=cast(Gateway, args.gateway),
            quiet=True,
            strategy_config_path=config_path,
            config_overrides=config_overrides,
            return_summary=True,
        )

        runner_stride20 = BacktestRunner(
            initial_balance=exec_cfg.get("initial_balance", 100_000.0),
            log_level="ERROR",
            slippage_ticks=int(slippage_ticks),
            commission_per_contract=float(commission),
            product=cast(Product, args.product),
            gateway=cast(Gateway, args.gateway),
            latency_ms=int(latency_ms),
            partial_fill_prob=float(partial_prob),
            partial_fill_ratio=float(partial_ratio),
            fill_model=str(exec_cfg.get("fill_model", "realistic")),
            seed=int(exec_cfg.get("seed", 42)),
        )

        runner_stride1 = BacktestRunner(
            initial_balance=exec_cfg.get("initial_balance", 100_000.0),
            log_level="ERROR",
            slippage_ticks=int(slippage_ticks),
            commission_per_contract=float(commission),
            product=cast(Product, args.product),
            gateway=cast(Gateway, args.gateway),
            latency_ms=int(latency_ms),
            partial_fill_prob=float(partial_prob),
            partial_fill_ratio=float(partial_ratio),
            fill_model=str(exec_cfg.get("fill_model", "realistic")),
            seed=int(exec_cfg.get("seed", 42)),
        )

        summary_stride20 = runner_stride20.run(
            **base_kwargs,
            data_source="parquet",
            catalog_path=None,
            catalog_paths=None,
        )
        summary_stride1 = runner_stride1.run(
            **base_kwargs,
            data_source="catalog",
            catalog_path=args.catalog_path,
            catalog_paths=catalog_paths,
        )

        if summary_stride20 is None or summary_stride1 is None:
            raise RuntimeError("Fidelity run returned no summary")

        print("\n" + "=" * 60)
        print("FIDELITY CHECK: stride20(parquet) vs stride1(catalog)")
        print("=" * 60)
        print(f"Window: {args.start} -> {args.end}")
        print("Metric\tstride20\tstride1\tΔ")

        def _row(name: str, a: float, b: float) -> None:
            delta = b - a
            print(f"{name}\t{a}\t{b}\t{delta}")

        _row("trades", float(summary_stride20.trades), float(summary_stride1.trades))
        _row("fills", float(summary_stride20.fills), float(summary_stride1.fills))
        _row("pnl", float(summary_stride20.total_pnl), float(summary_stride1.total_pnl))
        _row(
            "terminated",
            float(int(summary_stride20.terminated)),
            float(int(summary_stride1.terminated)),
        )

        # Determinism guard: stride1 must be stable on repeat.
        summary_stride1_repeat = runner_stride1.run(
            **base_kwargs,
            data_source="catalog",
            catalog_path=args.catalog_path,
            catalog_paths=catalog_paths,
        )
        if summary_stride1_repeat is None:
            raise RuntimeError("Fidelity repeat returned no summary")

        sig1 = (
            int(summary_stride1.trades),
            int(summary_stride1.fills),
            float(summary_stride1.total_pnl),
            bool(summary_stride1.terminated),
        )
        sig1b = (
            int(summary_stride1_repeat.trades),
            int(summary_stride1_repeat.fills),
            float(summary_stride1_repeat.total_pnl),
            bool(summary_stride1_repeat.terminated),
        )
        if sig1 != sig1b:
            raise RuntimeError(f"Non-deterministic stride1: expected {sig1}, got {sig1b}")

        return

    if args.sweep:
        # Parameter sweep mode
        thresholds = [60, 70, 75, 80]
        results: list[dict[str, float]] = []

        for thresh in thresholds:
            print(f"\n>>> Testing threshold={thresh}...")
            try:
                runner = BacktestRunner(
                    initial_balance=exec_cfg.get("initial_balance", 100_000.0),
                    log_level="ERROR",
                    slippage_ticks=slippage_ticks,
                    commission_per_contract=commission,
                    product=cast(Product, args.product),
                    gateway=cast(Gateway, args.gateway),
                    latency_ms=latency_ms,
                    partial_fill_prob=partial_prob,
                    partial_fill_ratio=partial_ratio,
                    fill_model=str(exec_cfg.get("fill_model", "realistic")),
                )
                summary = runner.run(
                    start_date=args.start,
                    end_date=args.end,
                    ltf_minutes=int(args.ltf_minutes),
                    sample_rate=args.sample,
                    use_session_filter=resolved_use_session_filter,  # BUG-2 FIX
                    use_regime_filter=resolved_use_regime_filter,  # BUG-2 FIX
                    use_mtf=resolved_use_mtf,  # BUG-2 FIX
                    use_footprint=resolved_use_footprint,  # BUG-2 FIX
                    prop_firm_enabled=resolved_prop_firm_enabled,  # BUG-2 FIX
                    use_news_filter=resolved_use_news_filter,  # BUG-2 FIX
                    execution_threshold=thresh,
                    debug_mode=False,
                    feed=args.feed,
                    data_source=args.source,
                    profile=args.profile,
                    reports=args.reports,
                    bars_file=args.bars_file,
                    output_dir=args.out_dir,
                    risk_per_trade=args.risk,
                    product=cast(Product, args.product),
                    gateway=cast(Gateway, args.gateway),
                    quiet=bool(args.quiet),
                    catalog_path=args.catalog_path,
                    catalog_paths=catalog_paths,
                    strategy_config_path=config_path,
                    config_overrides=config_overrides,
                    return_summary=True,
                )

                # Get results from summary (engine is disposed after run())
                if summary is not None:
                    pnl = summary.total_pnl
                    trades = summary.trades
                    final = summary.final_balance
                else:
                    pnl = 0.0
                    trades = 0
                    final = runner.initial_balance

                results.append(
                    {
                        "threshold": int(thresh),
                        "pnl": float(pnl),
                        "trades": int(trades),
                        "final_balance": float(final),
                    }
                )
                print(f"    PnL: ${pnl:,.2f}, Trades: {trades}")
            except Exception as e:
                print(f"    ERROR: {e}")
                results.append(
                    {"threshold": float(thresh), "pnl": 0.0, "trades": 0.0, "final_balance": 0.0}
                )

        print("\n" + "=" * 60)
        print("PARAMETER SWEEP RESULTS")
        print("=" * 60)
        for r in results:
            if "error" not in r:
                print(f"Threshold {r['threshold']}: PnL=${r['pnl']:,.2f}, Trades={r['trades']}")
    else:
        # Single run mode
        verbose_mode = bool(args.verbose)
        if verbose_mode:
            print(
                "[VERBOSE] Detailed score logging enabled - will show every confluence calculation"
            )

        # IMPORTANT: In bars-feed mode, Nautilus may only iterate on incoming bars (no wall-clock
        # ticks). The strategy's Apex TimeConstraintManager uses a Clock timer by default which can
        # create excessive timer churn when there are long periods without market events.
        # For ablation/backtest screening on bars, disable clock timers unless explicitly overridden.
        if args.feed == "bars":
            config_overrides = config_overrides or {}
            config_overrides.setdefault("execution", {})
            exec_over = config_overrides.get("execution")
            if isinstance(exec_over, dict):
                exec_over.setdefault("time_gate_use_clock_timer", False)

        # In certification mode, we need the summary for validation
        summary = runner.run(
            start_date=args.start,
            end_date=args.end,
            ltf_minutes=int(args.ltf_minutes),
            sample_rate=args.sample,
            use_session_filter=resolved_use_session_filter,  # BUG-2 FIX
            use_regime_filter=resolved_use_regime_filter,  # BUG-2 FIX
            use_mtf=resolved_use_mtf,  # HTF/MTF derived from aggregated bars  # BUG-2 FIX
            use_footprint=resolved_use_footprint,  # BUG-2 FIX
            prop_firm_enabled=resolved_prop_firm_enabled,  # BUG-2 FIX
            use_news_filter=resolved_use_news_filter,  # BUG-2 FIX
            execution_threshold=threshold,
            debug_mode=verbose_mode,
            feed=args.feed,
            data_source=args.source,
            profile=args.profile,
            reports=args.reports,
            bars_file=args.bars_file,
            output_dir=args.out_dir,
            risk_per_trade=args.risk,
            product=cast(Product, args.product),
            gateway=cast(Gateway, args.gateway),
            quiet=bool(args.quiet),
            catalog_path=args.catalog_path,
            catalog_paths=catalog_paths,
            strategy_config_path=config_path,
            config_overrides=config_overrides,
            return_summary=certify_mode,  # Force return_summary in certification mode
        )

        # ---------------------------------------------------------------------------
        # Certification mode: run Apex compliance validator and write certification.json
        # ---------------------------------------------------------------------------
        if certify_mode and certify_out_dir is not None:
            from nautilus_gold_scalper.scripts.validate_apex_compliance import (
                validate_compliance_from_paths,
            )

            print("\n[CERTIFY] Running Apex compliance validation...")

            fills_path = certify_out_dir / "fills.csv"
            positions_path = certify_out_dir / "positions.csv"
            telemetry_path = Path(args.telemetry_path) if args.telemetry_path else None
            apex_cert_path = certify_out_dir / "apex_compliance_cert.json"

            # Validate required artifacts exist
            if not fills_path.exists():
                sys.exit(
                    f"CERTIFY FAILED: fills.csv not found at {fills_path}. "
                    "Ensure backtest produced fill reports (--reports=full or default)."
                )

            # Run validator in-process
            validator_summary = validate_compliance_from_paths(
                trades_path=fills_path,
                positions_path=positions_path if positions_path.exists() else None,
                telemetry_path=telemetry_path,
                account_size=float(runner.initial_balance),
                dd_limit=0.05,
                daily_dd_limit=0.03,
                consistency_limit=0.30,
                cutoff="16:59",
                require_telemetry=True,
                output_path=apex_cert_path,
            )

            # Build certification.json
            certification_data: dict[str, object] = {
                "timestamp_utc": datetime.now(timezone.utc).isoformat(),
                "git_head": _get_git_head(),
                "run_args": {
                    "start": args.start,
                    "end": args.end,
                    "product": args.product,
                    "gateway": args.gateway,
                    "feed": args.feed,
                    "ltf_minutes": int(args.ltf_minutes),
                    "config": str(config_path),
                    "initial_balance": float(runner.initial_balance),
                },
                "artifact_paths": {
                    "fills": str(fills_path),
                    "positions": str(positions_path) if positions_path.exists() else None,
                    "telemetry": str(telemetry_path) if telemetry_path else None,
                    "apex_compliance_cert": str(apex_cert_path),
                },
                "backtest_summary": {
                    "trades": summary.trades if summary else None,
                    "fills": summary.fills if summary else None,
                    "total_pnl": summary.total_pnl if summary else None,
                    "final_balance": summary.final_balance if summary else None,
                    "terminated": summary.terminated if summary else None,
                    "max_drawdown_pct": summary.max_drawdown_pct if summary else None,
                    "sharpe": summary.sharpe if summary else None,
                    "sqn": summary.sqn if summary else None,
                },
                "validator_summary": validator_summary,
                "passed": bool(validator_summary.get("passed", False)),
            }

            cert_path = certify_out_dir / "certification.json"
            with open(cert_path, "w", encoding="utf-8") as f:
                json.dump(certification_data, f, indent=2)

            print(f"[CERTIFY] Certification written to: {cert_path}")

            # Check pass/fail
            if certification_data["passed"]:
                print("[CERTIFY] PASSED - Apex compliance validated")
            else:
                violations = validator_summary.get("violations", [])
                print("[CERTIFY] FAILED - Apex compliance violations detected:")
                for v in violations:
                    print(f"  - {v}")
                sys.exit(1)


if __name__ == "__main__":
    main()
