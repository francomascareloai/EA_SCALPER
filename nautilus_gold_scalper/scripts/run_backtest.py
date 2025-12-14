"""
NautilusTrader Tick-Based Backtest for Gold Scalper.

Uses real XAUUSD tick data (25M+ records) with NautilusTrader native engine.
Ticks are fed as QuoteTicks and aggregated to M5 bars for strategy consumption.
"""
import sys
from decimal import Decimal
from pathlib import Path
from datetime import datetime

import pandas as pd
import numpy as np
import yaml
import math
import json
from typing import Optional, TextIO

sys.path.insert(0, str(Path(__file__).parent.parent))

from nautilus_trader.backtest.engine import BacktestEngine as NautilusEngine
from nautilus_trader.config import BacktestEngineConfig, LoggingConfig, RiskEngineConfig
from nautilus_trader.model.identifiers import TraderId, Venue, InstrumentId, Symbol
from nautilus_trader.model.currencies import USD, XAU
from nautilus_trader.model.enums import AccountType, OmsType
from nautilus_trader.model.objects import Money, Price, Quantity
from nautilus_trader.model.data import QuoteTick, Bar, BarType, BarSpecification
from nautilus_trader.model.enums import BarAggregation, PriceType, AggregationSource
from nautilus_trader.model.instruments import CurrencyPair
from nautilus_trader.persistence.catalog import ParquetDataCatalog
from nautilus_trader.persistence.wranglers import QuoteTickDataWrangler

from src.strategies.gold_scalper_strategy import GoldScalperStrategy, GoldScalperConfig
from src.utils.metrics import MetricsCalculator


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
        size_increment=Quantity.from_str("0.01"),
        lot_size=Quantity.from_str("1"),
        max_quantity=Quantity.from_str("100"),
        min_quantity=Quantity.from_str("0.01"),
        max_price=Price.from_str("10000.00"),
        min_price=Price.from_str("100.00"),
        margin_init=Decimal("0.05"),
        margin_maint=Decimal("0.03"),
        maker_fee=Decimal("0.0001"),
        taker_fee=Decimal("0.0002"),
        ts_event=0,
        ts_init=0,
    )


def load_tick_data(
    filepath: str,
    start_date: str = None,
    end_date: str = None,
    sample_rate: int = 1,
) -> pd.DataFrame:
    """Load tick data from parquet file."""
    print(f"Loading tick data from {filepath}...")
    df = pd.read_parquet(filepath)
    
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
    
    if start_date:
        start_ts = pd.Timestamp(start_date, tz='UTC')
        df = df[df['datetime'] >= start_ts]
    if end_date:
        # Add 1 day to include the entire end date
        end_ts = pd.Timestamp(end_date, tz='UTC') + pd.Timedelta(days=1)
        df = df[df['datetime'] < end_ts]
    
    if sample_rate > 1:
        df = df.iloc[::sample_rate]
    
    if len(df) == 0:
        raise ValueError(f"No data found for date range: {start_date} to {end_date}")
    
    print(f"Loaded {len(df):,} ticks from {df['datetime'].iloc[0]} to {df['datetime'].iloc[-1]}")
    return df


def build_ticks_with_wrangler(
    df: pd.DataFrame,
    instrument: CurrencyPair,
    slippage_ticks: int,
    latency_ms: int,
    default_volume: float = 1.0,
) -> list[QuoteTick]:
    """Convert dataframe (datetime/bid/ask) to QuoteTicks using Cython wrangler, applying slippage/latency."""
    if df.empty:
        return []

    wrangler = QuoteTickDataWrangler(instrument)

    # Apply slippage at the price level before constructing ticks
    slip_value = float(instrument.price_increment) * max(0, slippage_ticks)
    if slip_value:
        df = df.copy()
        df["bid"] = df["bid"] - slip_value
        df["ask"] = df["ask"] + slip_value

    tick_df = pd.DataFrame(
        {
            "bid_price": df["bid"].astype(float),
            "ask_price": df["ask"].astype(float),
            "bid_size": default_volume,
            "ask_size": default_volume,
        },
        index=pd.DatetimeIndex(df["datetime"], name="timestamp"),
    )

    ticks = wrangler.process(tick_df, default_volume=default_volume, ts_init_delta=int(max(0, latency_ms)) * 1_000_000)
    return ticks


def adjust_ticks_from_catalog(
    ticks: list[QuoteTick],
    instrument: CurrencyPair,
    slippage_ticks: int,
    latency_ms: int,
) -> list[QuoteTick]:
    """Apply slippage/latency to QuoteTicks loaded from catalog using raw-array fast path."""
    if (slippage_ticks <= 0) and (latency_ms <= 0):
        return ticks

    slip_raw = int(round(float(instrument.price_increment) * max(0, slippage_ticks) * 1_000_000_000))
    latency_ns = int(max(0, latency_ms) * 1_000_000)

    bid_raw = np.fromiter((t.bid_price.raw for t in ticks), dtype=np.int64)
    ask_raw = np.fromiter((t.ask_price.raw for t in ticks), dtype=np.int64)
    size_raw = np.fromiter((t.bid_size.raw for t in ticks), dtype=np.int64)
    ts_event = np.fromiter((t.ts_event for t in ticks), dtype=np.int64)
    ts_init = np.fromiter((t.ts_init for t in ticks), dtype=np.int64)

    if slip_raw:
        bid_raw = bid_raw - slip_raw
        ask_raw = ask_raw + slip_raw
    if latency_ns:
        ts_event = ts_event + latency_ns
        ts_init = ts_init + latency_ns

    return QuoteTick.from_raw_arrays_to_list(
        instrument.id,
        instrument.price_precision,
        instrument.size_precision,
        bid_raw,
        ask_raw,
        size_raw,
        size_raw,
        ts_event,
        ts_init,
    )


def load_yaml_config(config_path: Path) -> dict:
    """Load YAML config if present, else return empty dict."""
    if not config_path.exists():
        return {}
    try:
        with open(config_path, "r", encoding="utf-8") as f:
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
    spreadmon_cfg = cfg.get("spread_monitor", {}) if isinstance(cfg, dict) else {}
    time_cfg = cfg.get("time", {}) if isinstance(cfg, dict) else {}
    cb_cfg = cfg.get("circuit_breaker", {}) if isinstance(cfg, dict) else {}
    consistency_cfg = cfg.get("consistency", {}) if isinstance(cfg, dict) else {}
    telemetry_cfg = cfg.get("telemetry", {}) if isinstance(cfg, dict) else {}
    telemetry_capture = telemetry_cfg.get("capture", {}) if isinstance(telemetry_cfg, dict) else {}

    execution_threshold = confluence_cfg.get("execution_threshold", confluence_cfg.get("min_score_to_trade", 70))

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
        use_session_filter=exec_cfg.get("use_session_filter", True),
        use_regime_filter=exec_cfg.get("use_regime_filter", True),
        require_htf_align=exec_cfg.get("require_htf_align", True),
        use_mtf=exec_cfg.get("use_mtf", True),
        use_footprint=exec_cfg.get("use_footprint", True),
        prop_firm_enabled=True,
        account_balance=exec_cfg.get("initial_balance", 100000.0),
        daily_loss_limit_pct=float(risk_cfg.get("dd_soft", 5.0)) * 100 if risk_cfg.get("dd_soft", 0) < 1 else float(risk_cfg.get("dd_soft", 5.0)),
        total_loss_limit_pct=float(risk_cfg.get("dd_hard", 10.0)) * 100 if risk_cfg.get("dd_hard", 0) < 1 else float(risk_cfg.get("dd_hard", 10.0)),
        risk_per_trade=Decimal(str(risk_cfg.get("max_risk_per_trade", 0.5))),
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
    )


def create_quote_ticks(df: pd.DataFrame, instrument: CurrencyPair, slippage_ticks: int = 0, latency_ms: int = 0) -> list:
    """Convert DataFrame to QuoteTick objects."""
    print("Converting to QuoteTick objects...")
    
    slip_value = float(instrument.price_increment) * max(0, slippage_ticks)
    ticks = []
    for idx, row in df.iterrows():
        ts_ns = int(row['datetime'].timestamp() * 1e9)
        if latency_ms > 0:
            ts_ns += int(latency_ms * 1e6)
        # Slip proportional to spread (if available) and random small jitter
        base_bid = row['bid']
        base_ask = row['ask']
        spread = max(0.0, base_ask - base_bid)
        vol_factor = np.clip(spread / instrument.price_increment, 0, 5)
        slip_adj = slip_value + (spread * 0.25) + (vol_factor * float(instrument.price_increment) * 0.1)
        bid_px = base_bid - slip_adj
        ask_px = base_ask + slip_adj
        
        tick = QuoteTick(
            instrument_id=instrument.id,
            bid_price=Price.from_str(f"{bid_px:.2f}"),
            ask_price=Price.from_str(f"{ask_px:.2f}"),
            bid_size=Quantity.from_str("1.00"),
            ask_size=Quantity.from_str("1.00"),
            ts_event=ts_ns,
            ts_init=ts_ns,
        )
        ticks.append(tick)
        
        if len(ticks) % 500000 == 0:
            print(f"  Processed {len(ticks):,} ticks...")
    
    print(f"Created {len(ticks):,} QuoteTick objects")
    return ticks


def aggregate_ticks_to_bars(df: pd.DataFrame, bar_type: BarType, interval_minutes: int = 5) -> list:
    """Pre-aggregate ticks into M5 bars."""
    print(f"Aggregating ticks into {interval_minutes}-minute bars...")
    
    # Calculate mid price
    df = df.copy()
    df['mid'] = (df['bid'] + df['ask']) / 2
    
    # Resample to bars
    df.set_index('datetime', inplace=True)
    ohlcv = df['mid'].resample(f'{interval_minutes}min').ohlc()
    ohlcv['volume'] = df['mid'].resample(f'{interval_minutes}min').count()
    
    # Drop NaN rows
    ohlcv = ohlcv.dropna()
    
    print(f"Created {len(ohlcv):,} bars")
    
    bars = []
    for timestamp, row in ohlcv.iterrows():
        ts_ns = int(timestamp.timestamp() * 1e9)
        
        bar = Bar(
            bar_type=bar_type,
            open=Price.from_str(f"{row['open']:.2f}"),
            high=Price.from_str(f"{row['high']:.2f}"),
            low=Price.from_str(f"{row['low']:.2f}"),
            close=Price.from_str(f"{row['close']:.2f}"),
            volume=Quantity.from_str(f"{row['volume']:.2f}"),  # Match instrument precision
            ts_event=ts_ns,
            ts_init=ts_ns,
        )
        bars.append(bar)
    
    print(f"Created {len(bars):,} Bar objects")
    return bars


class BacktestRunner:
    """NautilusTrader-based tick backtest runner."""
    
    def __init__(
        self,
        initial_balance: float = 100_000.0,
        log_level: str = "WARNING",
        slippage_ticks: int = 2,
        commission_per_contract: float = 2.5,
        latency_ms: int = 0,
        partial_fill_prob: float = 0.0,
        partial_fill_ratio: float = 0.5,
    ):
        self.initial_balance = initial_balance
        self.log_level = log_level
        self.engine = None
        self.venue = Venue("SIM")
        self.instrument = None
        self.slippage_ticks = slippage_ticks
        self.commission_per_contract = commission_per_contract
        self.latency_ms = latency_ms
        self.partial_fill_prob = partial_fill_prob
        self.partial_fill_ratio = partial_fill_ratio
    
    def run(
        self,
        start_date: str = "2024-10-01",
        end_date: str = "2024-12-31",
        sample_rate: int = 1,
        use_session_filter: bool = True,
        use_regime_filter: bool = True,
        use_mtf: bool = False,
        use_footprint: bool = True,
        prop_firm_enabled: bool = True,
        use_news_filter: bool = True,
        execution_threshold: int = 70,
        debug_mode: bool = False,
    ):
        """Run tick-based backtest with NautilusTrader."""
        
        print("=" * 60)
        print("NAUTILUS TRADER TICK-BASED BACKTEST")
        print("=" * 60)
        print(f"Period: {start_date} to {end_date}")
        print(f"Sample Rate: 1/{sample_rate} ticks")
        print(f"Filters: session={use_session_filter}, regime={use_regime_filter}, footprint={use_footprint}")
        print(f"Initial Balance: ${self.initial_balance:,.2f}")
        
        # Configure engine
        engine_config = BacktestEngineConfig(
            trader_id=TraderId("GOLD-TICK-001"),
            logging=LoggingConfig(log_level=self.log_level),
            risk_engine=RiskEngineConfig(bypass=False),
        )
        
        self.engine = NautilusEngine(config=engine_config)
        
        # Add venue
        self.engine.add_venue(
            venue=self.venue,
            oms_type=OmsType.NETTING,
            account_type=AccountType.MARGIN,
            base_currency=USD,
            starting_balances=[Money(self.initial_balance, USD)],
            default_leverage=Decimal("20"),
        )
        
        # Create instrument
        self.instrument = create_xauusd_instrument(self.venue)
        self.engine.add_instrument(self.instrument)
        
        print(f"Instrument: {self.instrument.id}")
        
        # Load tick data from config.yaml (SINGLE SOURCE OF TRUTH)
        config_path = Path(__file__).parent.parent.parent / "data" / "config.yaml"
        if not config_path.exists():
            raise FileNotFoundError(f"Data config not found: {config_path}. Please create data/config.yaml first!")
        
        data_config = yaml.safe_load(open(config_path))
        tick_path = Path(__file__).parent.parent.parent / data_config["active_dataset"]["path"]
        native_catalog_path = data_config["active_dataset"].get("native_catalog_path")
        native_catalog = Path(native_catalog_path) if native_catalog_path else None

        print(f"[CONFIG] Using dataset: {data_config['active_dataset']['name']}")
        print(f"[CONFIG] Path: {tick_path}")
        if native_catalog and native_catalog.exists():
            print(f"[CONFIG] Native catalog detected: {native_catalog}")
        
        start_ns = pd.Timestamp(start_date, tz="UTC").value if start_date else None
        end_ns = (pd.Timestamp(end_date, tz="UTC") + pd.Timedelta(days=1)).value if end_date else None

        if native_catalog and native_catalog.exists():
            catalog = ParquetDataCatalog(str(native_catalog))
            quote_ticks = catalog.query(
                data_cls=QuoteTick,
                identifiers=[self.instrument.id.value],
                start=start_ns,
                end=end_ns,
            )
            quote_ticks = adjust_ticks_from_catalog(quote_ticks, self.instrument, self.slippage_ticks, self.latency_ms)
        else:
            if not tick_path.exists():
                raise FileNotFoundError(f"Tick data not found at {tick_path}. Check data/config.yaml!")
            df = load_tick_data(str(tick_path), start_date, end_date, sample_rate)
            quote_ticks = build_ticks_with_wrangler(
                df=df,
                instrument=self.instrument,
                slippage_ticks=self.slippage_ticks,
                latency_ms=self.latency_ms,
            )
        
        # Create bar type for internal aggregation from ticks
        bar_type = BarType(
            instrument_id=self.instrument.id,
            bar_spec=BarSpecification(
                step=5,
                aggregation=BarAggregation.MINUTE,
                price_type=PriceType.MID,
            ),
            aggregation_source=AggregationSource.INTERNAL,
        )
        print(f"Bar type: {bar_type}")

        # Add data to engine (bars aggregated internally)
        self.engine.add_data(quote_ticks)
        print(f"Added {len(quote_ticks):,} ticks to engine (bars aggregated internally)")
        
        # Configure strategy from YAML + overrides
        strategy_cfg_dict = load_yaml_config(Path(__file__).parent.parent / "configs" / "strategy_config.yaml")
        strategy_config = build_strategy_config(strategy_cfg_dict, bar_type, self.instrument.id)
        
        strategy = GoldScalperStrategy(config=strategy_config)
        self.engine.add_strategy(strategy)
        
        print(f"Strategy: {strategy_config.strategy_id}")
        
        # Run
        print("\n" + "=" * 60)
        print("RUNNING TICK BACKTEST...")
        print("=" * 60 + "\n")
        
        self.engine.run()
        
        # Print results
        self._print_results()
        
        self.engine.dispose()
        
        print("\n" + "=" * 60)
        print("TICK BACKTEST COMPLETE")
        print("=" * 60)
    
    def _print_results(self):
        """Print backtest results."""
        print("\n" + "=" * 60)
        print("BACKTEST RESULTS")
        print("=" * 60)

        output_dir = Path("logs") / "backtest_latest"
        output_dir.mkdir(parents=True, exist_ok=True)

        metrics_out: Optional[TextIO] = None
        if getattr(self, "metrics_jsonl", None):
            try:
                metrics_out = open(self.metrics_jsonl, "a", encoding="utf-8")
            except Exception:
                metrics_out = None

        fills = None
        positions = None
        account = None

        try:
            fills = self.engine.trader.generate_order_fills_report()
            print(f"\nOrder Fills: {len(fills)}")
            if len(fills) > 0:
                print(fills.to_string())
                fills.to_csv(output_dir / "fills.csv", index=False)
        except Exception as e:
            print(f"Fills report error: {e}")
        
        try:
            positions = self.engine.trader.generate_positions_report()
            print(f"\nPositions Report:")
            if len(positions) > 0:
                print(positions.to_string())
                positions.to_csv(output_dir / "positions.csv", index=False)
            else:
                print("  No positions")
        except Exception as e:
            print(f"Positions report error: {e}")
        
        try:
            account = self.engine.trader.generate_account_report(self.venue)
            if len(account) > 0:
                account.to_csv(output_dir / "account.csv", index=False)
            
            # Calculate summary
            final_balance = float(account['total'].iloc[-1]) if len(account) > 0 else 100000
            fills_count = len(fills) if 'fills' in locals() and fills is not None else 0
            total_commissions = fills_count * self.commission_per_contract
            total_pnl = final_balance - 100000 - total_commissions
            
            print(f"\n" + "="*60)
            print("SUMMARY")
            print("="*60)
            print(f"Final Balance: ${final_balance:,.2f}")
            print(f"Total PnL (net commissions): ${total_pnl:,.2f} ({total_pnl/1000:.2f}%)")
            if total_commissions > 0:
                print(f"Commissions: ${total_commissions:,.2f} ({fills_count} fills @ {self.commission_per_contract} each)")
            # Calculate performance metrics using MetricsCalculator
            if len(account) > 1 and fills is not None and len(fills) > 0:
                # Extract PnL series from account equity changes
                equity_series = account['total'].values
                pnl_series = []
                
                # Calculate per-trade PnL from equity changes
                # Approximate trade PnLs from equity curve changes
                for i in range(1, len(equity_series)):
                    trade_pnl = equity_series[i] - equity_series[i-1]
                    if abs(trade_pnl) > 0.01:  # Filter out noise
                        pnl_series.append(trade_pnl)
                
                if len(pnl_series) > 0:
                    # Use MetricsCalculator for accurate metrics
                    calculator = MetricsCalculator(risk_free_rate=0.02)
                    metrics_obj = calculator.calculate(
                        pnl_series=pnl_series,
                        initial_balance=100000.0
                    )
                    
                    # Print formatted metrics
                    print(f"\n" + "="*60)
                    print("PERFORMANCE METRICS")
                    print("="*60)
                    print(f"Total PnL:        ${metrics_obj.total_pnl:>12,.2f}")
                    print(f"Num Trades:       {metrics_obj.num_trades:>12}")
                    print(f"Wins / Losses:    {metrics_obj.num_wins:>12} / {metrics_obj.num_losses}")
                    print(f"Win Rate:         {metrics_obj.win_rate:>12.1f}%")
                    print(f"Profit Factor:    {metrics_obj.profit_factor:>12.2f}")
                    print(f"Avg Win:          ${metrics_obj.avg_win:>12,.2f}")
                    print(f"Avg Loss:         ${metrics_obj.avg_loss:>12,.2f}")
                    print(f"-"*60)
                    print(f"Sharpe Ratio:     {metrics_obj.sharpe_ratio:>12.3f}")
                    print(f"Sortino Ratio:    {metrics_obj.sortino_ratio:>12.3f}")
                    print(f"Calmar Ratio:     {metrics_obj.calmar_ratio:>12.3f}")
                    print(f"SQN:              {metrics_obj.sqn:>12.3f}")
                    print(f"-"*60)
                    print(f"Max Drawdown:     {metrics_obj.max_drawdown_pct:>12.2f}%")
                    print(f"Std Dev:          ${metrics_obj.std_dev:>12,.2f}")
                    print(f"Recovery Factor:  {metrics_obj.recovery_factor:>12.2f}")
                    print("="*60)
                    
                    # Also log as JSON for programmatic parsing
                    log_line = {
                        "event": "metrics",
                        "sharpe": round(metrics_obj.sharpe_ratio, 3),
                        "sortino": round(metrics_obj.sortino_ratio, 3),
                        "calmar": round(metrics_obj.calmar_ratio, 3),
                        "sqn": round(metrics_obj.sqn, 3),
                        "max_drawdown_pct": round(metrics_obj.max_drawdown_pct, 3),
                        "win_rate": round(metrics_obj.win_rate, 1),
                        "profit_factor": round(metrics_obj.profit_factor, 2),
                    }
                    print(json.dumps(log_line))
                    
                    metrics = {
                        "final_balance": final_balance,
                        "total_pnl": total_pnl,
                        "fills": fills_count,
                        "commissions": total_commissions,
                        "sharpe": metrics_obj.sharpe_ratio,
                        "sortino": metrics_obj.sortino_ratio,
                        "max_drawdown_pct": metrics_obj.max_drawdown_pct,
                        "calmar": metrics_obj.calmar_ratio,
                        "sqn": metrics_obj.sqn,
                        "win_rate": metrics_obj.win_rate,
                        "profit_factor": metrics_obj.profit_factor,
                    }
                    with open(output_dir / "metrics.json", "w", encoding="utf-8") as f:
                        json.dump(metrics, f, indent=2)
            
            # Win rate from positions
            if 'positions' in dir() and len(positions) > 0 and 'realized_pnl' in positions.columns:
                pnls = positions['realized_pnl'].apply(
                    lambda x: float(str(x).replace(' USD', '')) if pd.notna(x) else 0
                )
                wins = (pnls > 0).sum()
                losses = (pnls < 0).sum()
                total = wins + losses
                print(f"Trades: {total} (W:{wins} L:{losses})")
                if total > 0:
                    print(f"Win Rate: {wins/total*100:.1f}%")
                    print(f"Avg PnL/trade: ${pnls.mean():.2f}")
            
            print(f"\nAccount Report:")
            print(account.to_string())
        except Exception as e:
            print(f"Account report error: {e}")
        
        # Strategy stats
        try:
            for strategy in self.engine.trader.strategies():
                if hasattr(strategy, 'stats'):
                    print(f"\nStrategy Stats ({strategy.id}):")
                    for k, v in strategy.stats.items():
                        print(f"  {k}: {v}")
        except Exception:
            pass


def main():
    """Main entry point."""
    import argparse
    
    parser = argparse.ArgumentParser(description='Run XAUUSD backtest')
    parser.add_argument('--start', default='2024-01-01', help='Start date')
    parser.add_argument('--end', default='2024-03-31', help='End date')
    parser.add_argument('--threshold', type=int, default=None, help='Execution threshold (overrides config)')
    parser.add_argument('--sample', type=int, default=1, help='Tick sample rate (1 = all ticks)')
    parser.add_argument('--sweep', action='store_true', help='Run parameter sweep')
    parser.add_argument('--no-news', action='store_true', help='Disable news filter')
    parser.add_argument('--config', default='nautilus_gold_scalper/configs/strategy_config.yaml', help='Path to strategy YAML')
    parser.add_argument('--latency', type=int, default=None, help='Simulated latency in ms')
    parser.add_argument('--slippage', type=int, default=None, help='Slippage in ticks (overrides config)')
    parser.add_argument('--commission', type=float, default=None, help='Commission per contract (overrides config)')
    parser.add_argument('--partial-prob', type=float, default=None, help='Partial fill probability (0-1)')
    parser.add_argument('--partial-ratio', type=float, default=None, help='Partial fill ratio (0-1)')
    parser.add_argument('--metrics-jsonl', default=None, help='Optional path to write metrics JSONL')
    args = parser.parse_args()
    
    config_path = Path(args.config)
    cfg = load_yaml_config(config_path)
    exec_cfg = cfg.get("execution", {}) if isinstance(cfg, dict) else {}
    threshold = args.threshold if args.threshold is not None else exec_cfg.get("execution_threshold", 70)
    slippage_ticks = args.slippage if args.slippage is not None else exec_cfg.get("slippage_ticks", 2)
    commission = args.commission if args.commission is not None else exec_cfg.get("commission_per_contract", 2.5)
    latency_ms = args.latency if args.latency is not None else exec_cfg.get("latency_ms", 0)
    partial_prob = args.partial_prob if args.partial_prob is not None else exec_cfg.get("partial_fill_prob", 0.0)
    partial_ratio = args.partial_ratio if args.partial_ratio is not None else exec_cfg.get("partial_fill_ratio", 0.5)
    metrics_jsonl = args.metrics_jsonl

    runner = BacktestRunner(
        initial_balance=exec_cfg.get("initial_balance", 100_000.0),
        log_level="DEBUG" if not args.sweep else "ERROR",  # FORÇA DEBUG para single run
        slippage_ticks=slippage_ticks,
        commission_per_contract=commission,
        latency_ms=latency_ms,
        partial_fill_prob=partial_prob,
        partial_fill_ratio=partial_ratio,
    )
    
    if args.sweep:
        # Parameter sweep mode
        import json
        from datetime import datetime
        
        thresholds = [60, 70, 75, 80]
        results = []
        
        for thresh in thresholds:
            print(f"\n>>> Testing threshold={thresh}...")
            try:
                runner = BacktestRunner(initial_balance=100_000.0, log_level="ERROR")
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
        )


if __name__ == "__main__":
    main()
