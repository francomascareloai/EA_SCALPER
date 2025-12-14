#!/usr/bin/env python3
"""Test EA WITH substitution to debug why it fails."""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

from scripts.backtest.tick_backtester import TickBacktester, BacktestConfig, ExecutionMode
from scripts.backtest.strategies.ea_logic_python import EAConfig, EALogic

def main():
    config = BacktestConfig(
        use_ea_logic=True,
        eval_window_bars=500,
        execution_mode=ExecutionMode.PESSIMISTIC,
        initial_balance=100_000.0,
        risk_per_trade=0.005,
        max_daily_dd=0.05,
        max_total_dd=0.10,
        bar_timeframe='15min',
        exec_timeframe='15min',
        debug=True,
        debug_interval=5000
    )

    bt = TickBacktester(config)
    
    # Print BEFORE substitution
    print("BEFORE substitution:")
    print(f'  EA execution_threshold: {bt.ea.cfg.execution_threshold}')
    print(f'  EA use_fib_filter: {bt.ea.cfg.use_fib_filter}')
    print(f'  EA id: {id(bt.ea)}')
    
    # Create replacement EA with SAME config as backtester creates
    ea_config = EAConfig(
        risk_per_trade_pct=0.5,
        execution_threshold=50.0,
        confluence_min_score=50.0,
        min_rr=1.5,
        max_spread_points=80.0,
        allow_asian=True,
        allow_late_ny=True,
        use_ml=False,
        use_fib_filter=False,
        ob_displacement_mult=1.5,
        fvg_min_gap=0.2,
        use_mtf=False
    )
    
    # Substitute
    bt.ea = EALogic(ea_config, initial_balance=100_000.0)
    
    # Print AFTER substitution
    print("\nAFTER substitution:")
    print(f'  EA execution_threshold: {bt.ea.cfg.execution_threshold}')
    print(f'  EA use_fib_filter: {bt.ea.cfg.use_fib_filter}')
    print(f'  EA id: {id(bt.ea)}')
    
    results = bt.run(
        tick_path='data/processed/ticks_2024.parquet',
        max_ticks=10_000_000
    )
    
    # Print AFTER run
    print("\nAFTER run:")
    print(f'  EA id: {id(bt.ea)}')
    
    m = results.get('metrics', {})
    print(f'\nTrades: {m.get("total_trades", 0)}')
    print(f'PF: {m.get("profit_factor", 0):.2f}')

if __name__ == "__main__":
    main()
