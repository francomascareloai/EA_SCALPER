"""
NautilusTrader Native Backtest for Gold Scalper Strategy.

This uses NautilusTrader's BacktestEngine for proper event-driven backtesting.
All modules are fully integrated with Nautilus architecture.
"""
import sys
from decimal import Decimal
from pathlib import Path
from datetime import datetime

import pandas as pd
import yaml

# Add src to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from nautilus_trader.backtest.engine import BacktestEngine
from nautilus_trader.config import (
    BacktestEngineConfig,
    LoggingConfig,
    RiskEngineConfig,
)
from nautilus_trader.model.identifiers import TraderId, Venue, InstrumentId, Symbol
from nautilus_trader.model.currencies import USD, XAU
from nautilus_trader.model.enums import AccountType, OmsType, PriceType, BarAggregation, AggregationSource
from nautilus_trader.model.data import BarSpecification
from nautilus_trader.model.objects import Money, Price, Quantity
from nautilus_trader.model.data import BarType, Bar
from nautilus_trader.model.instruments import CurrencyPair
from nautilus_trader.persistence.wranglers import BarDataWrangler

from src.strategies.gold_scalper_strategy import GoldScalperStrategy, GoldScalperConfig

# Reuse central config builder; fallback if not importable as package
try:  # pragma: no cover
    from scripts.run_backtest import load_yaml_config, build_strategy_config
except Exception:  # pragma: no cover
    from run_backtest import load_yaml_config, build_strategy_config  # type: ignore


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


def load_bar_data(filepath: str, start_date: str = None, end_date: str = None) -> pd.DataFrame:
    """Load and prepare OHLCV data for NautilusTrader."""
    print(f"Loading data from {filepath}...")
    df = pd.read_csv(filepath)
    
    # Parse datetime and set timezone
    df['timestamp'] = pd.to_datetime(
        df['Date'].astype(str) + ' ' + df['Time'], 
        format='%Y%m%d %H:%M:%S',
        utc=True
    )
    df = df.set_index('timestamp')
    
    # Rename columns to match NautilusTrader expectations
    df = df.rename(columns={
        'Open': 'open',
        'High': 'high',
        'Low': 'low',
        'Close': 'close',
        'Volume': 'volume'
    })
    df = df[['open', 'high', 'low', 'close', 'volume']]

    if df.isna().any().any():
        raise ValueError("Bar data contains NaN values")
    if not df.index.is_monotonic_increasing:
        df = df.sort_index()
        if not df.index.is_monotonic_increasing:
            raise ValueError("Bar data timestamps not monotonic even after sort")
    
    # Filter by date
    if start_date:
        df = df[df.index >= start_date]
    if end_date:
        df = df[df.index <= end_date]
    
    print(f"Loaded {len(df)} bars from {df.index[0]} to {df.index[-1]}")
    return df


def run_nautilus_backtest(
    start_date: str = "2024-10-01",
    end_date: str = "2024-12-31",
    initial_balance: float = 100_000.0,
    log_level: str = "INFO",
    config_path: str = "nautilus_gold_scalper/configs/strategy_config.yaml",
):
    """Run backtest using NautilusTrader's native engine."""
    
    print("=" * 60)
    print("NAUTILUS TRADER NATIVE BACKTEST")
    print("=" * 60)
    
    # Configure backtest engine
    engine_config = BacktestEngineConfig(
        trader_id=TraderId("GOLD-SCALPER-001"),
        logging=LoggingConfig(
            log_level=log_level,
            log_level_file="DEBUG",
        ),
        risk_engine=RiskEngineConfig(
            bypass=False,  # Enforce risk for realism
        ),
    )
    
    engine = BacktestEngine(config=engine_config)
    
    # Add venue
    SIM = Venue("SIM")
    engine.add_venue(
        venue=SIM,
        oms_type=OmsType.NETTING,
        account_type=AccountType.MARGIN,
        base_currency=USD,
        starting_balances=[Money(initial_balance, USD)],
        default_leverage=Decimal("20"),
    )
    
    # Create and add instrument
    xauusd = create_xauusd_instrument(SIM)
    engine.add_instrument(xauusd)
    
    print(f"Instrument: {xauusd.id}")
    print(f"Venue: {SIM}")
    print(f"Starting Balance: ${initial_balance:,.2f}")
    
    # Load historical data
    data_path = Path(__file__).parent.parent.parent / "Python_Agent_Hub/ml_pipeline/data/Bars_2020-2025XAUUSD_ftmo-M5-No Session.csv"
    df = load_bar_data(str(data_path), start_date, end_date)
    
    # Create bar type for M5 timeframe
    bar_type = BarType(
        instrument_id=xauusd.id,
        bar_spec=BarSpecification(
            step=5,
            aggregation=BarAggregation.MINUTE,
            price_type=PriceType.LAST,
        ),
        aggregation_source=AggregationSource.EXTERNAL,
    )
    
    # Wrangle data to Bar objects
    wrangler = BarDataWrangler(bar_type, xauusd)
    bars = wrangler.process(df)
    engine.add_data(bars)
    
    print(f"Added {len(bars)} M5 bars to engine")
    
    # Configure strategy via YAML (single source of truth)
    cfg = load_yaml_config(Path(config_path))
    strategy_config = build_strategy_config(cfg, bar_type=bar_type, instrument_id=xauusd.id)
    
    strategy = GoldScalperStrategy(config=strategy_config)
    engine.add_strategy(strategy)
    
    print(f"Strategy: {strategy_config.strategy_id}")
    print(f"Execution Threshold: {strategy_config.execution_threshold}")
    print(f"Risk per Trade: {strategy_config.risk_per_trade}%")
    
    # Run backtest
    print("\n" + "=" * 60)
    print("RUNNING BACKTEST...")
    print("=" * 60 + "\n")
    
    engine.run()
    
    # Print results
    print("\n" + "=" * 60)
    print("BACKTEST RESULTS")
    print("=" * 60)
    
    # Get reports
    try:
        fills_report = engine.trader.generate_order_fills_report()
        print(f"\nOrder Fills: {len(fills_report)}")
        if len(fills_report) > 0:
            print(fills_report.tail(10))
    except Exception as e:
        print(f"Fills report error: {e}")
    
    try:
        positions_report = engine.trader.generate_positions_report()
        print(f"\nPositions Report:")
        print(positions_report)
    except Exception as e:
        print(f"Positions report error: {e}")
    
    try:
        account_report = engine.trader.generate_account_report(SIM)
        print(f"\nAccount Report:")
        print(account_report)
    except Exception as e:
        print(f"Account report error: {e}")
    
    # Clean up
    engine.dispose()
    
    print("\n" + "=" * 60)
    print("BACKTEST COMPLETE")
    print("=" * 60)


if __name__ == "__main__":
    run_nautilus_backtest(
        start_date="2024-10-01",
        end_date="2024-12-31",
        initial_balance=100_000.0,
        log_level="INFO",
    )
