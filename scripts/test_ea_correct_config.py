#!/usr/bin/env python3
"""Test EA with CORRECT relaxed config matching backtester internal."""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

from scripts.backtest.tick_backtester import TickBacktester, BacktestConfig, ExecutionMode
from scripts.backtest.strategies.ea_logic_python import EAConfig, EALogic

def main():
    print('Testing with CORRECT relaxed config (min_rr=1.0)...')
    
    # CORRECT config matching backtester internal
    ea_config = EAConfig(
        execution_threshold=50.0,
        confluence_min_score=50.0,
        min_rr=1.0,                # KEY: Relaxed from 1.5
        max_spread_points=120.0,   # KEY: Relaxed from 80
        use_ml=False,
        use_fib_filter=False,
        ob_displacement_mult=1.5,
        fvg_min_gap=0.2,
    )
    
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
    bt.ea = EALogic(ea_config, initial_balance=100_000.0)
    
    results = bt.run(
        tick_path='data/processed/ticks_2024.parquet',
        max_ticks=10_000_000
    )
    
    m = results.get('metrics', {})
    print(f'\nTrades: {m.get("total_trades", 0)}')
    print(f'PF: {m.get("profit_factor", 0):.2f}')
    print(f'Return: {m.get("total_return", 0)*100:.2f}%')

if __name__ == "__main__":
    main()
