"""
NautilusTrader Tick-Based Backtest for Gold Scalper.

Uses real XAUUSD tick data (25M+ records) with NautilusTrader native engine.
Ticks are fed as QuoteTicks and aggregated to M5 bars for strategy consumption.
"""
import json
import random
import sys
import time
from dataclasses import dataclass
from decimal import Decimal
from pathlib import Path
from typing import Literal, cast

import numpy as np
import pandas as pd
import yaml

sys.path.insert(0, str(Path(__file__).parent.parent))

from nautilus_trader.backtest.engine import BacktestEngine as NautilusEngine
from nautilus_trader.config import BacktestEngineConfig, LoggingConfig, RiskEngineConfig
from nautilus_trader.model.currencies import USD, XAU
from nautilus_trader.model.data import Bar, BarSpecification, BarType, QuoteTick
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
ReportsMode = Literal["none", "positions", "summary", "full"]
Product = Literal["xauusd", "mgc"]
Gateway = Literal["rithmic", "tradovate"]

_MISSING = object()

def _deep_update(dst: dict, src: dict) -> dict:
    """Recursively update nested dicts (in-place), returning dst."""
    for key, value in src.items():
        if isinstance(value, dict) and isinstance(dst.get(key), dict):
            _deep_update(cast(dict, dst[key]), value)
        else:
            dst[key] = value
    return dst


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
    """Return Apex all-in commission per side for a product + gateway.

    Sources (Apex Help Center, verified 2025-12-17):
    - Tradovate Commission & Instruments: MGC = $0.67 per side ($1.34 RT)
    - Rithmic Commissions & Instruments: MGC = $0.76 per side ($1.52 RT)

    Notes:
    - We model commission as "per side" (per fill). Round turn ~= 2x per-side.
    - Keep this function as the single source of truth for Apex commission assumptions.
    """
    if product != "mgc":
        raise ValueError(f"Unsupported Apex commission lookup for product={product!r}")
    if gateway == "rithmic":
        return 0.76
    if gateway == "tradovate":
        return 0.67
    raise ValueError(f"Unsupported gateway={gateway!r}")


def _quantize_to_tick(values: np.ndarray, tick: float, mode: Literal["nearest", "floor", "ceil"]) -> np.ndarray:
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
    """Load tick data from a single Parquet file with column pruning and optional time filtering."""
    print(f"Loading tick data from {filepath}...")

    # Use Arrow dataset scanning for filter pushdown when possible.
    # This is critical for performance with large Parquet files.
    try:
        import pyarrow.dataset as ds

        dataset = ds.dataset(filepath, format="parquet")
        expr = None

        if start_date:
            start_ts = pd.Timestamp(start_date, tz="UTC").to_datetime64()
            expr = (ds.field("datetime") >= np.datetime64(start_ts)) if expr is None else expr & (
                ds.field("datetime") >= np.datetime64(start_ts)
            )
        if end_date:
            end_ts = (pd.Timestamp(end_date, tz="UTC") + pd.Timedelta(days=1)).to_datetime64()
            expr = (ds.field("datetime") < np.datetime64(end_ts)) if expr is None else expr & (
                ds.field("datetime") < np.datetime64(end_ts)
            )

        table = dataset.to_table(columns=["datetime", "bid", "ask"], filter=expr)
        df = table.to_pandas()
    except Exception:
        # Fallback to pandas reader (slower, but keeps script resilient).
        df = pd.read_parquet(filepath, columns=["datetime", "bid", "ask"])

    if df['datetime'].dt.tz is None:
        df['datetime'] = pd.to_datetime(df['datetime'], utc=True)
    else:
        df['datetime'] = df['datetime'].dt.tz_convert('UTC')

    # Basic validation: no NaN, monotonic increasing timestamps
    if df['datetime'].isna().any():
        raise ValueError("Tick data contains NaN datetimes")
    if not df['datetime'].is_monotonic_increasing:
        df = df.sort_values('datetime')
        if not df['datetime'].is_monotonic_increasing:
            raise ValueError("Tick data timestamps are not monotonic even after sort")
    if df[['bid', 'ask']].isna().any().any():
        raise ValueError("Tick data contains NaN bid/ask values")

    step = sample_to_step(sample)
    if step > 1:
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


def build_ticks_with_wrangler(
    df: pd.DataFrame,
    instrument: Instrument,
    latency_ms: int,
    default_volume: float = 1.0,
) -> list[QuoteTick]:
    """Convert dataframe (datetime/bid/ask) to QuoteTicks using Cython wrangler.

    For performance, we avoid per-tick Python loops. Slippage/commission/latency
    are modeled in the execution layer via strategy config (not by mutating feed).
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

    ticks = wrangler.process(tick_df, default_volume=default_volume, ts_init_delta=int(max(0, latency_ms)) * 1_000_000)
    return cast(list[QuoteTick], ticks)


def load_m5_bars_csv(filepath: Path, start_date: str, end_date: str) -> pd.DataFrame:
    """Load M5 bars file (CSV or Parquet) into an OHLCV DataFrame indexed by UTC timestamp.

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
            raise ValueError("Bars file must contain `timestamp`/`datetime` or `Date`+`Time` columns")
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

    start_ts = pd.Timestamp(start_date, tz="UTC")
    end_ts = pd.Timestamp(end_date, tz="UTC") + pd.Timedelta(days=1)
    df = df[(df.index >= start_ts) & (df.index < end_ts)]
    if df.empty:
        raise ValueError(f"No bars in requested window: {start_date}..{end_date}")
    return df


def load_yaml_config(config_path: Path) -> dict:
    """Load YAML config if present, else return empty dict."""
    if not config_path.exists():
        return {}
    try:
        with open(config_path, encoding="utf-8") as f:
            return yaml.safe_load(f) or {}
    except Exception as exc:
        print(f"WARNING: Could not load config {config_path}: {exc}")
        return {}


def build_strategy_config(cfg: dict, bar_type: BarType, instrument_id):
    """Build GoldScalperConfig from YAML dict + defaults."""
    confluence_cfg = cfg.get("confluence", {}) if isinstance(cfg, dict) else {}
    risk_cfg = cfg.get("risk", {}) if isinstance(cfg, dict) else {}
    news_cfg = cfg.get("news", {}) if isinstance(cfg, dict) else {}
    spread_cfg = cfg.get("spread", {}) if isinstance(cfg, dict) else {}
    exec_cfg = cfg.get("execution", {}) if isinstance(cfg, dict) else {}
    session_cfg = cfg.get("session", {}) if isinstance(cfg, dict) else {}
    structure_cfg = cfg.get("structure", {}) if isinstance(cfg, dict) else {}
    ob_cfg = cfg.get("order_blocks", cfg.get("ob", {})) if isinstance(cfg, dict) else {}
    fvg_cfg = cfg.get("fvg", {}) if isinstance(cfg, dict) else {}
    sweeps_cfg = cfg.get("liquidity_sweeps", cfg.get("sweeps", {})) if isinstance(cfg, dict) else {}
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

    confluence_weights = confluence_cfg.get("weights", {}) if isinstance(confluence_cfg, dict) else {}

    execution_threshold = confluence_cfg.get("execution_threshold", confluence_cfg.get("min_score_to_trade", 70))

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
        try:
            return float(v)
        except Exception:
            return default

    # Derive time cutoffs with fallback to execution config
    cutoff_str = exec_cfg.get("flatten_time_et", time_cfg.get("cutoff_et", "16:59"))
    warning_str = time_cfg.get("warning_et", "16:00")
    urgent_str = time_cfg.get("urgent_et", "16:30")
    emergency_str = time_cfg.get("emergency_et", "16:55")

    max_spread_points = int(exec_cfg.get("max_spread_points", spread_cfg.get("max_spread_points", 80)))
    max_spread_pips = float(spreadmon_cfg.get("max_spread_pips", max_spread_points / 10.0))

    return GoldScalperConfig(
        strategy_id="GOLD-TICK-001",
        instrument_id=instrument_id,
        ltf_bar_type=bar_type,
        execution_threshold=int(execution_threshold),
        min_mtf_confluence=float(confluence_cfg.get("min_score_to_trade", 50)),
        min_rr_ratio=float(exec_cfg.get("min_rr_ratio", 1.5)),
        target_rr_ratio=float(exec_cfg.get("target_rr_ratio", 2.5)),
        use_session_filter=exec_cfg.get("use_session_filter", True),
        use_regime_filter=exec_cfg.get("use_regime_filter", True),
        require_htf_align=exec_cfg.get("require_htf_align", True),
        use_mtf=exec_cfg.get("use_mtf", True),
        use_footprint=exec_cfg.get("use_footprint", True),
        prop_firm_enabled=True,
        account_balance=exec_cfg.get("initial_balance", 100000.0),
        daily_loss_limit_pct=float(risk_cfg.get("dd_soft", 5.0)) * 100 if risk_cfg.get("dd_soft", 0) < 1 else float(risk_cfg.get("dd_soft", 5.0)),
        total_loss_limit_pct=float(risk_cfg.get("dd_hard", 10.0)) * 100 if risk_cfg.get("dd_hard", 0) < 1 else float(risk_cfg.get("dd_hard", 10.0)),
        risk_per_trade=Decimal(str(risk_cfg.get("max_risk_per_trade", 0.01))),
        max_spread_points=int(spread_cfg.get("max_spread_points", exec_cfg.get("max_spread_points", 80))),
        use_news_filter=news_cfg.get("enabled", True),
        news_score_penalty=int(news_cfg.get("score_penalty", -15)),
        news_size_multiplier=float(news_cfg.get("size_multiplier", 0.5)),
        flatten_time_et=cutoff_str,
        allow_overnight=exec_cfg.get("allow_overnight", time_cfg.get("allow_overnight", False)),
        slippage_ticks=int(exec_cfg.get("slippage_ticks", 2)),
        slippage_multiplier=float(exec_cfg.get("slippage_multiplier", 1.5)),
        commission_per_contract=float(exec_cfg.get("commission_per_contract", 2.5)),
        latency_ms=int(exec_cfg.get("latency_ms", 0)),
        partial_fill_prob=float(exec_cfg.get("partial_fill_prob", 0.0)),
        partial_fill_ratio=float(exec_cfg.get("partial_fill_ratio", 0.5)),
        fill_reject_base=float(exec_cfg.get("fill_reject_base", 0.0)),
        fill_reject_spread_factor=float(exec_cfg.get("fill_reject_spread_factor", 0.0)),
        fill_model=str(exec_cfg.get("fill_model", "realistic")),
        use_selector=exec_cfg.get("use_selector", True),
        max_spread_pips=max_spread_pips,
        spread_warning_ratio=float(spreadmon_cfg.get("warning_ratio", spread_cfg.get("warning_ratio", 2.0))),
        spread_block_ratio=float(spreadmon_cfg.get("block_ratio", spread_cfg.get("block_ratio", 5.0))),
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
        cb_cooldown_1=int(cb_cfg.get("cooldown_minutes", {}).get("level_1", 5)),
        cb_cooldown_2=int(cb_cfg.get("cooldown_minutes", {}).get("level_2", 15)),
        cb_cooldown_3=int(cb_cfg.get("cooldown_minutes", {}).get("level_3", 30)),
        cb_cooldown_4=int(cb_cfg.get("cooldown_minutes", {}).get("level_4", 1440)),
        cb_size_mult_2=float(cb_cfg.get("size_multipliers", {}).get("level_2", 0.75)),
        cb_size_mult_3=float(cb_cfg.get("size_multipliers", {}).get("level_3", 0.5)),
        cb_auto_recovery=bool(cb_cfg.get("auto_recovery", True)),
        consistency_cap_pct=float(consistency_cfg.get("daily_profit_cap_pct", 30.0)),
        telemetry_enabled=bool(telemetry_cfg.get("enabled", True)),
        telemetry_path=str(telemetry_cfg.get("path", "logs/telemetry.jsonl")),
        telemetry_capture_spread=bool(telemetry_capture.get("spread", True)),
        telemetry_capture_circuit=bool(telemetry_capture.get("circuit", True)),
        telemetry_capture_cutoff=bool(telemetry_capture.get("cutoff", True)),
        session_broker_gmt_offset=int(session_cfg.get("broker_gmt_offset", 0)),
        session_allow_asian=bool(session_cfg.get("allow_asian", False)),
        session_allow_late_ny=bool(session_cfg.get("allow_late_ny", False)),
        session_friday_close_hour=int(session_cfg.get("friday_close_hour", 14)),
        structure_swing_strength=int(structure_cfg.get("swing_strength", 3)),
        structure_equal_tolerance_pips=float(structure_cfg.get("equal_tolerance_pips", 5.0)),
        structure_break_buffer_pips=float(structure_cfg.get("break_buffer_pips", 2.0)),
        structure_lookback_bars=int(structure_cfg.get("lookback_bars", 100)),
        structure_min_swing_distance=int(structure_cfg.get("min_swing_distance", 5)),
        structure_point=float(structure_cfg.get("point", 0.0)),
        ob_displacement_threshold_pips=float(ob_cfg.get("displacement_threshold_pips", 20.0)),
        ob_volume_threshold=float(ob_cfg.get("volume_threshold", 1.5)),
        ob_require_structure_break=bool(ob_cfg.get("require_structure_break", True)),
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
        regime_multiscale_periods=tuple(int(x) for x in regime_cfg.get("multiscale_periods", [50, 100, 200])),
        selector_ftmo_safe_mode=bool(selector_cfg.get("ftmo_safe_mode", False)),
        selector_allow_news_trading=bool(selector_cfg.get("allow_news_trading", True)),
        selector_allow_asian_session=bool(selector_cfg.get("allow_asian_session", False)),
        selector_hurst_trend_threshold=float(selector_cfg.get("hurst_trend_threshold", 0.55)),
        selector_hurst_revert_threshold=float(selector_cfg.get("hurst_revert_threshold", 0.40)),
        selector_entropy_low_threshold=float(selector_cfg.get("entropy_low_threshold", 1.5)),
        selector_entropy_high_threshold=float(selector_cfg.get("entropy_high_threshold", 2.5)),
        hbs_enabled=bool(exec_cfg.get("hbs_enabled", True)),
        hbs_mode=str(exec_cfg.get("hbs_mode", "backtest")),
        hbs_account_id=str(exec_cfg.get("hbs_account_id", "")),
        hbs_profit_target=float(exec_cfg.get("hbs_profit_target", 3000.0)),
    )


def aggregate_tick_df_to_ohlcv(df: pd.DataFrame, interval_minutes: int) -> pd.DataFrame:
    """Aggregate (datetime,bid,ask) ticks into OHLCV bars using mid price."""
    if df.empty:
        return pd.DataFrame()

    ticks = df.copy()
    ticks["mid"] = (ticks["bid"] + ticks["ask"]) / 2.0
    ticks = ticks.set_index("datetime")

    ohlc = ticks["mid"].resample(f"{interval_minutes}min").ohlc()
    vol = ticks["mid"].resample(f"{interval_minutes}min").count()
    bars_df = ohlc.join(vol.rename("volume")).dropna()
    return bars_df


def build_bars_with_wrangler(bars_df: pd.DataFrame, bar_type: BarType, instrument: Instrument) -> list[Bar]:
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
        partial_fill_prob: float = 0.0,
        partial_fill_ratio: float = 0.5,
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
        self.seed = int(seed)
        self.metrics_jsonl: str | None = None

    def run(
        self,
        start_date: str = "2024-10-01",
        end_date: str = "2024-12-31",
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
        config_overrides: dict[str, object] | None = None,
        quiet: bool = False,
    ):
        """Run backtest with NautilusTrader.

        - `feed="ticks"`: loads QuoteTicks and aggregates bars internally (slow, most live-like).
        - `feed="bars"`: feeds external M5 bars (fast screening). Provide `bars_file` or `bars_override` for speed.
        """

        def _p(msg: str) -> None:
            if not quiet:
                print(msg)

        _p("=" * 60)
        _p("NAUTILUS TRADER TICK-BASED BACKTEST")
        _p("=" * 60)
        _p(f"Period: {start_date} to {end_date}")
        _p(f"Sample: {sample_rate} (float fraction or N-step)")
        _p(f"Feed: {feed} | Source: {data_source}")
        # Note: Filter settings loaded from strategy_config.yaml
        _p(f"Initial Balance: ${self.initial_balance:,.2f}")

        t0 = time.perf_counter()

        # Make runs deterministic by default (critical for comparing parameter sweeps).
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

        # Add venue
        engine.add_venue(
            venue=self.venue,
            oms_type=OmsType.NETTING,
            account_type=AccountType.MARGIN,
            base_currency=USD,
            starting_balances=[Money(self.initial_balance, USD)],
            default_leverage=Decimal("20"),
        )

        resolved_product: Product = product or self.product
        resolved_gateway: Gateway = gateway or self.gateway

        # Create instrument
        if resolved_product == "xauusd":
            instrument = create_xauusd_instrument(self.venue)
        elif resolved_product == "mgc":
            instrument = create_mgc_instrument(self.venue)
        else:  # pragma: no cover
            raise ValueError(f"Unsupported product={resolved_product!r}")
        self.instrument = instrument
        engine.add_instrument(instrument)

        _p(f"Instrument: {instrument.id} (product={resolved_product}, gateway={resolved_gateway})")

        # Load tick data from config.yaml (SINGLE SOURCE OF TRUTH)
        config_path = Path(__file__).parent.parent.parent / "data" / "config.yaml"
        if not config_path.exists():
            raise FileNotFoundError(f"Data config not found: {config_path}. Please create data/config.yaml first!")

        with open(config_path, encoding="utf-8") as f:
            data_config = yaml.safe_load(f) or {}
        project_root = Path(__file__).parent.parent.parent
        tick_path = project_root / data_config["active_dataset"]["path"]
        native_catalog_path = data_config["active_dataset"].get("native_catalog_path")
        # Resolve native catalog path relative to project root
        native_catalog = (project_root / native_catalog_path) if native_catalog_path else None

        _p(f"[CONFIG] Using dataset: {data_config['active_dataset']['name']}")
        _p(f"[CONFIG] Path: {tick_path}")
        if native_catalog and native_catalog.exists():
            _p(f"[CONFIG] Native catalog detected: {native_catalog}")

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
            raise ValueError("product=mgc is not compatible with source=catalog (dataset is XAUUSD spot)")
        if feed == "bars" and use_catalog and bars_override is None:
            raise ValueError("bars feed requires parquet source or explicit bars_override (catalog->bars not enabled here)")

        bars_df: pd.DataFrame | None = None
        if feed == "bars" and bars_override is None and bars_file:
            bars_path = Path(bars_file)
            if not bars_path.exists():
                raise FileNotFoundError(f"bars_file not found: {bars_path}")
            bars_df = load_m5_bars_csv(bars_path, start_date=start_date, end_date=end_date)
            if resolved_product == "mgc":
                tick = float(instrument.price_increment.as_double())
                bars_df = bars_df.copy()
                bars_df["open"] = _quantize_to_tick(bars_df["open"].astype(float).values, tick=tick, mode="nearest")
                bars_df["close"] = _quantize_to_tick(bars_df["close"].astype(float).values, tick=tick, mode="nearest")
                bars_df["high"] = _quantize_to_tick(bars_df["high"].astype(float).values, tick=tick, mode="ceil")
                bars_df["low"] = _quantize_to_tick(bars_df["low"].astype(float).values, tick=tick, mode="floor")

        quote_ticks: list[QuoteTick] = []
        df: pd.DataFrame | None = None
        if use_catalog and feed == "ticks":
            if not (native_catalog and native_catalog.exists()):
                raise FileNotFoundError("Catalog source requested but native catalog path not found in data/config.yaml")
            catalog = ParquetDataCatalog(str(native_catalog))
            quote_ticks = catalog.quote_ticks(
                instrument_ids=[self.instrument.id.value],
                start=start_date,
                end=end_date,
            )
            _p(f"[CATALOG] Loaded {len(quote_ticks):,} ticks from native catalog")
            if step > 1:
                quote_ticks = quote_ticks[::step]
        elif feed == "ticks" or (feed == "bars" and bars_override is None and bars_df is None):
            if not tick_path.exists():
                raise FileNotFoundError(f"Tick data not found at {tick_path}. Check data/config.yaml!")

            df = load_tick_data(str(tick_path), start_date, end_date, sample_rate)
            if feed == "ticks":
                quote_ticks = build_ticks_with_wrangler(df=df, instrument=self.instrument, latency_ms=self.latency_ms)

        # Create bar type for internal aggregation from ticks
        agg_source = AggregationSource.INTERNAL if feed == "ticks" else AggregationSource.EXTERNAL
        bar_type = BarType(
            instrument_id=instrument.id,
            bar_spec=BarSpecification(
                step=5,
                aggregation=BarAggregation.MINUTE,
                price_type=PriceType.MID,
            ),
            aggregation_source=agg_source,
        )
        _p(f"Bar type: {bar_type}")

        if feed == "ticks":
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
                bars_df2 = aggregate_tick_df_to_ohlcv(df, interval_minutes=5)
                if resolved_product == "mgc":
                    tick = float(instrument.price_increment.as_double())
                    bars_df2 = bars_df2.copy()
                    bars_df2["open"] = _quantize_to_tick(bars_df2["open"].astype(float).values, tick=tick, mode="nearest")
                    bars_df2["close"] = _quantize_to_tick(bars_df2["close"].astype(float).values, tick=tick, mode="nearest")
                    bars_df2["high"] = _quantize_to_tick(bars_df2["high"].astype(float).values, tick=tick, mode="ceil")
                    bars_df2["low"] = _quantize_to_tick(bars_df2["low"].astype(float).values, tick=tick, mode="floor")
                bars = build_bars_with_wrangler(bars_df2, bar_type=bar_type, instrument=instrument)
            engine.add_data(bars)
            _p(f"Added {len(bars):,} bars to engine (external bars feed)")

        # Configure strategy from YAML + overrides
        strategy_cfg_dict = load_yaml_config(Path(__file__).parent.parent.parent / "configs" / "strategy_config.yaml")
        strategy_cfg_dict.setdefault("confluence", {})
        strategy_cfg_dict.setdefault("execution", {})
        strategy_cfg_dict.setdefault("risk", {})
        strategy_cfg_dict.setdefault("news", {})
        strategy_cfg_dict.setdefault("footprint", {})
        strategy_cfg_dict.setdefault("regime", {})
        strategy_cfg_dict.setdefault("selector", {})

        # Apply runtime overrides so CLI/test args actually take effect.
        strategy_cfg_dict["confluence"]["execution_threshold"] = int(execution_threshold)
        strategy_cfg_dict["confluence"]["min_score_to_trade"] = int(execution_threshold)
        strategy_cfg_dict["execution"]["use_session_filter"] = bool(use_session_filter)
        strategy_cfg_dict["execution"]["use_regime_filter"] = bool(use_regime_filter)
        strategy_cfg_dict["execution"]["use_mtf"] = bool(use_mtf)
        strategy_cfg_dict["execution"]["use_footprint"] = bool(use_footprint)
        strategy_cfg_dict["execution"]["slippage_ticks"] = int(self.slippage_ticks)
        strategy_cfg_dict["execution"]["commission_per_contract"] = float(self.commission_per_contract)
        strategy_cfg_dict["execution"]["latency_ms"] = int(self.latency_ms)
        strategy_cfg_dict["execution"]["partial_fill_prob"] = float(self.partial_fill_prob)
        strategy_cfg_dict["execution"]["partial_fill_ratio"] = float(self.partial_fill_ratio)
        strategy_cfg_dict["execution"]["debug_mode"] = bool(debug_mode)
        strategy_cfg_dict["execution"]["prop_firm_enabled"] = bool(prop_firm_enabled)
        # Keep strategy-side risk state aligned with the backtest account.
        # (Used by PropFirm/DD trackers and as the initial equity baseline.)
        strategy_cfg_dict["execution"]["initial_balance"] = float(self.initial_balance)
        strategy_cfg_dict["news"]["enabled"] = bool(use_news_filter)
        if risk_per_trade is not None:
            strategy_cfg_dict["risk"]["max_risk_per_trade"] = float(risk_per_trade)

        if config_overrides:
            # Allow workflows (grid search) to sweep params without editing YAML.
            try:
                _deep_update(strategy_cfg_dict, cast(dict, config_overrides))
            except Exception as exc:
                _p(f"WARNING: could not apply config_overrides: {exc}")

        strategy_config = build_strategy_config(strategy_cfg_dict, bar_type, instrument.id)

        strategy = GoldScalperStrategy(config=strategy_config)
        engine.add_strategy(strategy)

        _p(f"Strategy: {strategy_config.strategy_id}")

        # Run
        if not quiet:
            print("\n" + "=" * 60)
            print("RUNNING TICK BACKTEST...")
            print("=" * 60 + "\n")

        terminated = False
        try:
            engine.run()
        except AccountTerminatedException as exc:
            # In prop-firm mode we terminate early on hard breaches; keep reporting stable.
            terminated = True
            _p(f"[TERMINATED] {exc}")

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
            _p(json.dumps({"event": "profile", "total_seconds": round(dt, 3)}))

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

        fills = None
        positions = None
        account = None

        if reports in ("summary", "full"):
            try:
                fills = engine.trader.generate_order_fills_report()
                print(f"\nOrder Fills: {len(fills)}")
                if reports == "full" and len(fills) > 0:
                    print(fills.to_string())
                elif reports == "summary" and len(fills) > 0:
                    print(fills.tail(10).to_string())
                if len(fills) > 0:
                    fills.to_csv(out_dir / "fills.csv", index=False)
            except Exception as e:
                print(f"Fills report error: {e}")

        if reports != "none":
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
                if len(positions) > 0:
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

        try:
            account = engine.trader.generate_account_report(self.venue)
            if len(account) > 0:
                account.to_csv(out_dir / "account.csv", index=False)

            # Calculate summary
            final_balance = float(account['total'].iloc[-1]) if len(account) > 0 else float(self.initial_balance)
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
                        filled_qty_sum = float(pd.to_numeric(positions[qty_col], errors="coerce").fillna(0).abs().sum())
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
            total_pnl = final_balance - float(self.initial_balance) - commission_est

            if reports in ("summary", "full"):
                print("\n" + "="*60)
                print("SUMMARY")
                print("="*60)
                print(f"Final Balance: ${final_balance:,.2f}")
                pct = (total_pnl / float(self.initial_balance) * 100.0) if self.initial_balance else 0.0
                print(f"Total PnL (net commissions): ${total_pnl:,.2f} ({pct:.2f}%)")
                if commission_est > 0:
                    print(f"Commission est.: ${commission_est:,.2f} ((sum(filled_qty)/lot_size) × {self.commission_per_contract})")

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
                            print(f"Wins / Losses:    {metrics_obj.num_wins:>12} / {metrics_obj.num_losses}")
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
                            dd_abs = (metrics_obj.max_drawdown_pct / 100.0) * float(self.initial_balance)
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
                        with open(out_dir / "metrics.json", "w", encoding="utf-8") as f:
                            json.dump(metrics, f, indent=2)
            except Exception:
                # Keep the summary output stable even if metrics fail.
                pass

            # Win rate from positions
            if positions is not None and len(positions) > 0 and "realized_pnl" in positions.columns:
                pnls = positions['realized_pnl'].apply(
                    lambda x: float(str(x).replace(' USD', '')) if pd.notna(x) else 0
                )
                wins = (pnls > 0).sum()
                losses = (pnls < 0).sum()
                total = wins + losses
                trades = int(total)
                if reports in ("summary", "full"):
                    print(f"Trades: {total} (W:{wins} L:{losses})")
                if total > 0:
                    if reports in ("summary", "full"):
                        print(f"Win Rate: {wins/total*100:.1f}%")
                        print(f"Avg PnL/trade: ${pnls.mean():.2f}")
            if reports == "full":
                print("\nAccount Report:")
                if account is not None:
                    print(account.to_string())
        except Exception as e:
            if reports in ("summary", "full"):
                print(f"Account report error: {e}")

        # Strategy stats
        try:
            for strategy in engine.trader.strategies():
                if hasattr(strategy, 'stats'):
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


def main():
    """Main entry point."""
    import argparse

    parser = argparse.ArgumentParser(description="Run Nautilus backtest (XAUUSD spot or MGC futures economics)")
    parser.add_argument('--start', default='2024-01-01', help='Start date')
    parser.add_argument('--end', default='2024-03-31', help='End date')
    parser.add_argument('--product', choices=['xauusd', 'mgc'], default='xauusd', help='Instrument product to simulate')
    parser.add_argument('--gateway', choices=['rithmic', 'tradovate'], default='tradovate', help='Apex gateway (commission schedule)')
    parser.add_argument('--threshold', type=int, default=None, help='Execution threshold (overrides config)')
    parser.add_argument('--sample', type=float, default=1.0, help='Sampling: float fraction (0-1) or N-step (>=1)')
    parser.add_argument('--feed', choices=['ticks', 'bars'], default='ticks', help='Data feed mode')
    parser.add_argument('--source', choices=['auto', 'parquet', 'catalog'], default='auto', help='Data source selection')
    parser.add_argument('--profile', action='store_true', help='Print coarse timing JSON')
    parser.add_argument('--reports', choices=['none', 'summary', 'full'], default='summary', help='Console reporting level')
    parser.add_argument('--bars-file', default=None, help='Optional M5 bars CSV file for fast screening (feed=bars)')
    parser.add_argument('--sweep', action='store_true', help='Run parameter sweep')
    parser.add_argument('--no-news', action='store_true', help='Disable news filter')
    parser.add_argument('--config', default='nautilus_gold_scalper/configs/strategy_config.yaml', help='Path to strategy YAML')
    parser.add_argument('--latency', type=int, default=None, help='Simulated latency in ms')
    parser.add_argument('--slippage', type=int, default=None, help='Slippage in ticks (overrides config)')
    parser.add_argument('--commission', type=float, default=None, help='Commission per contract (overrides config)')
    parser.add_argument('--partial-prob', type=float, default=None, help='Partial fill probability (0-1)')
    parser.add_argument('--partial-ratio', type=float, default=None, help='Partial fill ratio (0-1)')
    parser.add_argument('--metrics-jsonl', default=None, help='Optional path to write metrics JSONL')
    parser.add_argument('--out-dir', default=None, help='Optional output dir for reports (fills/positions/account)')
    parser.add_argument('--risk', type=float, default=None, help='Risk per trade (fraction, e.g. 0.005 = 0.5%)')
    args = parser.parse_args()

    config_path = Path(args.config)
    cfg = load_yaml_config(config_path)
    exec_cfg = cfg.get("execution", {}) if isinstance(cfg, dict) else {}
    threshold = args.threshold if args.threshold is not None else exec_cfg.get("execution_threshold", 70)
    slippage_ticks = args.slippage if args.slippage is not None else exec_cfg.get("slippage_ticks", 2)
    if args.commission is not None:
        commission = float(args.commission)
    elif args.product == "mgc":
        commission = apex_commission_per_side("mgc", cast(Gateway, args.gateway))
    else:
        commission = float(exec_cfg.get("commission_per_contract", 2.5))
    latency_ms = args.latency if args.latency is not None else exec_cfg.get("latency_ms", 0)
    partial_prob = args.partial_prob if args.partial_prob is not None else exec_cfg.get("partial_fill_prob", 0.0)
    partial_ratio = args.partial_ratio if args.partial_ratio is not None else exec_cfg.get("partial_fill_ratio", 0.5)
    metrics_jsonl = args.metrics_jsonl

    runner = BacktestRunner(
        initial_balance=exec_cfg.get("initial_balance", 100_000.0),
        log_level="INFO" if not args.sweep else "ERROR",  # INFO for single run, ERROR for sweeps
        slippage_ticks=slippage_ticks,
        commission_per_contract=commission,
        product=cast(Product, args.product),
        gateway=cast(Gateway, args.gateway),
        latency_ms=latency_ms,
        partial_fill_prob=partial_prob,
        partial_fill_ratio=partial_ratio,
    )
    runner.metrics_jsonl = metrics_jsonl

    if args.sweep:
        # Parameter sweep mode
        thresholds = [60, 70, 75, 80]
        results = []

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
                )
                runner.run(
                    start_date=args.start,
                    end_date=args.end,
                    sample_rate=args.sample,
                    use_session_filter=True,
                    use_regime_filter=True,
                    use_mtf=True,
                    use_footprint=True,
                    prop_firm_enabled=True,
                    use_news_filter=not args.no_news,
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
                )

                # Get results
                account = runner.engine.trader.generate_account_report(runner.venue)
                final = float(account['total'].iloc[-1]) if len(account) > 0 else 100000
                pnl = final - 100000

                fills = runner.engine.trader.generate_order_fills_report()
                trades = len(fills) // 2

                results.append({
                    'threshold': thresh,
                    'pnl': pnl,
                    'trades': trades,
                    'final_balance': final,
                })
                print(f"    PnL: ${pnl:,.2f}, Trades: {trades}")
                runner.engine.dispose()
            except Exception as e:
                print(f"    ERROR: {e}")
                results.append({'threshold': thresh, 'error': str(e)})

        print("\n" + "="*60)
        print("PARAMETER SWEEP RESULTS")
        print("="*60)
        for r in results:
            if 'error' not in r:
                print(f"Threshold {r['threshold']}: PnL=${r['pnl']:,.2f}, Trades={r['trades']}")
    else:
        # Single run mode
        runner.run(
            start_date=args.start,
            end_date=args.end,
            sample_rate=args.sample,
            use_session_filter=True,
            use_regime_filter=True,
            use_mtf=True,  # HTF/MTF derived from aggregated bars
            use_footprint=True,
            prop_firm_enabled=True,
            use_news_filter=not args.no_news,
            execution_threshold=threshold,
            debug_mode=True,
            feed=args.feed,
            data_source=args.source,
            profile=args.profile,
            reports=args.reports,
            bars_file=args.bars_file,
            output_dir=args.out_dir,
            risk_per_trade=args.risk,
            product=cast(Product, args.product),
            gateway=cast(Gateway, args.gateway),
        )


if __name__ == "__main__":
    main()
