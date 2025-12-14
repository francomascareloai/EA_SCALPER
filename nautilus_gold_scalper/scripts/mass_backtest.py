"""
Mass Backtesting with Parameter Optimization.
Runs multiple backtests with different parameter combinations.
"""
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from typing import Dict, List, Any, Optional
from pathlib import Path
from dataclasses import dataclass, replace
from itertools import product
import json
from concurrent.futures import ProcessPoolExecutor, as_completed
import multiprocessing as mp

from nautilus_trader.backtest.engine import BacktestEngine, BacktestEngineConfig
from nautilus_trader.model import Bar, BarType, BarSpecification
from nautilus_trader.model.enums import AggregationSource, BarAggregation, PriceType
from nautilus_trader.model.identifiers import InstrumentId, TraderId, Venue
from nautilus_trader.model.objects import Price, Quantity
from nautilus_trader.config import LoggingConfig
from nautilus_trader.test_kit.providers import TestInstrumentProvider

from src.strategies.gold_scalper_strategy import GoldScalperStrategy, GoldScalperConfig
# Central config loader (YAML single source); fallback for direct script runs
try:  # pragma: no cover
    from scripts.run_backtest import load_yaml_config, build_strategy_config
except Exception:  # pragma: no cover
    from run_backtest import load_yaml_config, build_strategy_config  # type: ignore


@dataclass
class BacktestResult:
    """Result of a single backtest run."""
    params: Dict[str, Any]
    total_trades: int
    win_rate: float
    profit_factor: float
    total_pnl: float
    max_drawdown: float
    sharpe_ratio: float
    avg_trade_pnl: float
    start_date: str
    end_date: str
    duration_days: int
    error: Optional[str] = None


def create_instrument():
    """Create XAUUSD instrument."""
    from nautilus_trader.model.currencies import USD
    from nautilus_trader.model.enums import AssetClass
    from nautilus_trader.model.identifiers import Symbol
    from nautilus_trader.model.instruments import CurrencyPair
    
    return CurrencyPair(
        instrument_id=InstrumentId(Symbol("XAU/USD"), Venue("SIM")),
        raw_symbol=Symbol("XAUUSD"),
        base_currency=USD,  # XAU treated as USD for simplicity
        quote_currency=USD,
        price_precision=2,
        size_precision=2,
        price_increment=Price.from_str("0.01"),
        size_increment=Quantity.from_str("0.01"),
        lot_size=Quantity.from_str("1"),
        max_quantity=Quantity.from_str("1000"),
        min_quantity=Quantity.from_str("0.01"),
        max_price=Price.from_str("10000.00"),
        min_price=Price.from_str("100.00"),
        margin_init=0,
        margin_maint=0,
        maker_fee=0,
        taker_fee=0,
        ts_event=0,
        ts_init=0,
    )


def load_and_aggregate_bars(
    parquet_path: str,
    start_date: str,
    end_date: str,
    sample_rate: int = 5,
) -> pd.DataFrame:
    """Load tick data and aggregate to M5 bars."""
    df = pd.read_parquet(parquet_path)
    
    # Filter by date
    df['datetime'] = pd.to_datetime(df['datetime'])
    mask = (df['datetime'] >= start_date) & (df['datetime'] <= end_date)
    df = df[mask]
    
    if len(df) == 0:
        return pd.DataFrame()
    
    # Sample ticks
    df = df.iloc[::sample_rate].copy()
    
    # Calculate mid price
    df['mid'] = (df['bid'] + df['ask']) / 2
    df.set_index('datetime', inplace=True)
    
    # Aggregate to M5 bars
    bars = df['mid'].resample('5min').ohlc()
    bars['volume'] = df['mid'].resample('5min').count()
    bars.columns = ['open', 'high', 'low', 'close', 'volume']
    bars = bars.dropna()
    
    return bars


def run_single_backtest(
    params: Dict[str, Any],
    bars_df: pd.DataFrame,
    instrument,
    bar_type: BarType,
) -> BacktestResult:
    """Run a single backtest with given parameters."""
    try:
        # Create engine
        engine = BacktestEngine(
            config=BacktestEngineConfig(
                trader_id=TraderId("MASS-001"),
                logging=LoggingConfig(log_level="ERROR"),  # Quiet logging
            )
        )
        
        # Add venue and instrument
        engine.add_venue(
            venue=Venue("SIM"),
            oms_type="NETTING",
            account_type="MARGIN",
            base_currency="USD",
            starting_balances=["100000 USD"],
        )
        engine.add_instrument(instrument)
        
        # Convert bars to NautilusTrader format
        bars = []
        for idx, row in bars_df.iterrows():
            ts = int(pd.Timestamp(idx).timestamp() * 1e9)
            bar = Bar(
                bar_type=bar_type,
                open=Price.from_str(f"{row['open']:.2f}"),
                high=Price.from_str(f"{row['high']:.2f}"),
                low=Price.from_str(f"{row['low']:.2f}"),
                close=Price.from_str(f"{row['close']:.2f}"),
                volume=Quantity.from_str(f"{row['volume']:.2f}"),
                ts_event=ts,
                ts_init=ts,
            )
            bars.append(bar)
        
        engine.add_data(bars)
        
        # Strategy config from central YAML, then override sweep params
        cfg_path = Path(__file__).parent.parent / "configs" / "strategy_config.yaml"
        cfg_dict = load_yaml_config(cfg_path)
        base_cfg = build_strategy_config(cfg_dict, bar_type=bar_type, instrument_id=instrument.id)
        config = replace(
            base_cfg,
            execution_threshold=params.get("execution_threshold", base_cfg.execution_threshold),
            min_mtf_confluence=params.get("min_mtf_confluence", base_cfg.min_mtf_confluence),
            require_htf_align=params.get("require_htf_align", base_cfg.require_htf_align),
            aggressive_mode=params.get("aggressive_mode", base_cfg.aggressive_mode),
            use_footprint_boost=params.get("use_footprint_boost", base_cfg.use_footprint_boost),
            use_session_filter=params.get("use_session_filter", base_cfg.use_session_filter),
            use_regime_filter=params.get("use_regime_filter", base_cfg.use_regime_filter),
            use_footprint=params.get("use_footprint", base_cfg.use_footprint),
            debug_mode=False,
        )
        
        strategy = GoldScalperStrategy(config=config)
        engine.add_strategy(strategy)
        
        # Run backtest
        engine.run()
        
        # Extract results
        fills = engine.trader.generate_order_fills_report()
        positions = engine.trader.generate_positions_report()
        account = engine.trader.generate_account_report()
        
        # Calculate metrics
        total_trades = len(fills) // 2 if len(fills) > 0 else 0  # Entry + Exit = 1 trade
        
        if total_trades == 0:
            return BacktestResult(
                params=params,
                total_trades=0,
                win_rate=0.0,
                profit_factor=0.0,
                total_pnl=0.0,
                max_drawdown=0.0,
                sharpe_ratio=0.0,
                avg_trade_pnl=0.0,
                start_date=str(bars_df.index.min()),
                end_date=str(bars_df.index.max()),
                duration_days=(bars_df.index.max() - bars_df.index.min()).days,
            )
        
        # Get PnL from account
        final_balance = float(account['total'].iloc[-1])
        initial_balance = 100000.0
        total_pnl = final_balance - initial_balance
        
        # Estimate win rate from positions
        if len(positions) > 0 and 'realized_pnl' in positions.columns:
            pnls = positions['realized_pnl'].apply(lambda x: float(str(x).replace(' USD', '')) if pd.notna(x) else 0)
            wins = (pnls > 0).sum()
            losses = (pnls < 0).sum()
            win_rate = wins / (wins + losses) * 100 if (wins + losses) > 0 else 0
            
            # Profit factor
            gross_profit = pnls[pnls > 0].sum()
            gross_loss = abs(pnls[pnls < 0].sum())
            profit_factor = gross_profit / gross_loss if gross_loss > 0 else float('inf')
            
            avg_trade_pnl = pnls.mean()
        else:
            win_rate = 0.0
            profit_factor = 0.0
            avg_trade_pnl = 0.0
        
        engine.dispose()
        
        return BacktestResult(
            params=params,
            total_trades=total_trades,
            win_rate=win_rate,
            profit_factor=profit_factor,
            total_pnl=total_pnl,
            max_drawdown=0.0,  # TODO: Calculate properly
            sharpe_ratio=0.0,  # TODO: Calculate properly
            avg_trade_pnl=avg_trade_pnl,
            start_date=str(bars_df.index.min()),
            end_date=str(bars_df.index.max()),
            duration_days=(bars_df.index.max() - bars_df.index.min()).days,
        )
        
    except Exception as e:
        return BacktestResult(
            params=params,
            total_trades=0,
            win_rate=0.0,
            profit_factor=0.0,
            total_pnl=0.0,
            max_drawdown=0.0,
            sharpe_ratio=0.0,
            avg_trade_pnl=0.0,
            start_date="",
            end_date="",
            duration_days=0,
            error=str(e),
        )


def generate_parameter_grid() -> List[Dict[str, Any]]:
    """Generate parameter combinations for testing."""
    param_ranges = {
        'execution_threshold': [60, 70, 75, 80],
        'min_mtf_confluence': [30.0, 40.0, 50.0, 60.0],
        'require_htf_align': [True, False],
        'aggressive_mode': [False, True],
        'use_session_filter': [False],  # Start simple
        'use_regime_filter': [False],
        'use_footprint': [False],
    }
    
    # Generate all combinations
    keys = list(param_ranges.keys())
    values = list(param_ranges.values())
    
    combinations = []
    for combo in product(*values):
        params = dict(zip(keys, combo))
        combinations.append(params)
    
    return combinations


def run_mass_backtest(
    parquet_path: str,
    start_date: str = "2024-01-01",
    end_date: str = "2024-06-30",
    sample_rate: int = 10,
    max_workers: int = 4,
    max_combinations: int = 100,
):
    """Run mass backtesting with multiple parameter combinations."""
    print("=" * 60)
    print("MASS BACKTESTING ENGINE")
    print("=" * 60)
    
    # Load data once
    print(f"\nLoading data from {start_date} to {end_date}...")
    bars_df = load_and_aggregate_bars(parquet_path, start_date, end_date, sample_rate)
    
    if len(bars_df) == 0:
        print("ERROR: No data loaded!")
        return
    
    print(f"Loaded {len(bars_df):,} M5 bars")
    print(f"Period: {bars_df.index.min()} to {bars_df.index.max()}")
    
    # Create instrument and bar type
    instrument = create_instrument()
    bar_type = BarType(
        instrument_id=instrument.id,
        bar_spec=BarSpecification(5, BarAggregation.MINUTE, PriceType.MID),
        aggregation_source=AggregationSource.EXTERNAL,
    )
    
    # Generate parameter combinations
    all_params = generate_parameter_grid()
    params_to_test = all_params[:max_combinations]
    
    print(f"\nTesting {len(params_to_test)} parameter combinations...")
    print(f"Total possible: {len(all_params)}")
    
    results: List[BacktestResult] = []
    
    # Run backtests sequentially (multiprocessing has issues with NautilusTrader)
    for i, params in enumerate(params_to_test):
        print(f"\rRunning backtest {i+1}/{len(params_to_test)}...", end="", flush=True)
        result = run_single_backtest(params, bars_df, instrument, bar_type)
        results.append(result)
    
    print("\n")
    
    # Analyze results
    print("=" * 60)
    print("RESULTS SUMMARY")
    print("=" * 60)
    
    # Filter successful runs
    successful = [r for r in results if r.error is None]
    failed = [r for r in results if r.error is not None]
    
    print(f"\nTotal runs: {len(results)}")
    print(f"Successful: {len(successful)}")
    print(f"Failed: {len(failed)}")
    
    if failed:
        print(f"\nFirst error: {failed[0].error}")
    
    # Filter runs with trades
    with_trades = [r for r in successful if r.total_trades > 0]
    print(f"Runs with trades: {len(with_trades)}")
    
    if not with_trades:
        print("\nNo parameter combination generated trades!")
        print("Possible issues:")
        print("- Threshold too high")
        print("- Data period too short")
        print("- Strategy filters too strict")
        return results
    
    # Sort by PnL
    sorted_results = sorted(with_trades, key=lambda x: x.total_pnl, reverse=True)
    
    print("\n" + "=" * 60)
    print("TOP 10 PARAMETER COMBINATIONS")
    print("=" * 60)
    
    for i, r in enumerate(sorted_results[:10]):
        print(f"\n#{i+1}:")
        print(f"  PnL: ${r.total_pnl:,.2f}")
        print(f"  Trades: {r.total_trades}")
        print(f"  Win Rate: {r.win_rate:.1f}%")
        print(f"  Profit Factor: {r.profit_factor:.2f}")
        print(f"  Params: threshold={r.params['execution_threshold']}, "
              f"htf_align={r.params['require_htf_align']}, "
              f"aggressive={r.params['aggressive_mode']}")
    
    # Statistics
    print("\n" + "=" * 60)
    print("STATISTICS")
    print("=" * 60)
    
    pnls = [r.total_pnl for r in with_trades]
    trades = [r.total_trades for r in with_trades]
    
    print(f"\nPnL Statistics:")
    print(f"  Mean: ${np.mean(pnls):,.2f}")
    print(f"  Median: ${np.median(pnls):,.2f}")
    print(f"  Std Dev: ${np.std(pnls):,.2f}")
    print(f"  Min: ${min(pnls):,.2f}")
    print(f"  Max: ${max(pnls):,.2f}")
    
    print(f"\nTrade Statistics:")
    print(f"  Mean trades: {np.mean(trades):.1f}")
    print(f"  Max trades: {max(trades)}")
    print(f"  Min trades: {min(trades)}")
    
    # Profitable runs
    profitable = [r for r in with_trades if r.total_pnl > 0]
    print(f"\nProfitable combinations: {len(profitable)}/{len(with_trades)} "
          f"({len(profitable)/len(with_trades)*100:.1f}%)")
    
    # Save results
    output_file = f"mass_backtest_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    output_path = os.path.join(os.path.dirname(__file__), output_file)
    
    results_data = [
        {
            'params': r.params,
            'total_trades': r.total_trades,
            'win_rate': r.win_rate,
            'profit_factor': r.profit_factor,
            'total_pnl': r.total_pnl,
            'avg_trade_pnl': r.avg_trade_pnl,
            'start_date': r.start_date,
            'end_date': r.end_date,
            'duration_days': r.duration_days,
            'error': r.error,
        }
        for r in results
    ]
    
    with open(output_path, 'w') as f:
        json.dump(results_data, f, indent=2)
    
    print(f"\nResults saved to: {output_path}")
    
    return results


if __name__ == "__main__":
    TICK_DATA_PATH = r"C:\Users\Admin\Documents\EA_SCALPER_XAUUSD\data\ticks\xauusd_2020_2024_stride20.parquet"
    
    results = run_mass_backtest(
        parquet_path=TICK_DATA_PATH,
        start_date="2024-01-01",
        end_date="2024-06-30",
        sample_rate=10,  # Sample every 10th tick for speed
        max_combinations=56,  # 7 thresholds * 4 mtf * 2 htf = 56 combos
    )
