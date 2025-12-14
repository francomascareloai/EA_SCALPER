#!/usr/bin/env python3
"""Test EA without substitution to verify baseline works."""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

from scripts.backtest.tick_backtester import TickBacktester, BacktestConfig, ExecutionMode

def main():
    # Test WITHOUT substituting EA - let backtester create it
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
    # DO NOT substitute EA - use default
    
    print(f'EA created: {bt.ea is not None}')
    print(f'EA execution_threshold: {bt.ea.cfg.execution_threshold}')
    print(f'EA confluence_min_score: {bt.ea.cfg.confluence_min_score}')
    print(f'EA use_fib_filter: {bt.ea.cfg.use_fib_filter}')
    print(f'EA ob_displacement_mult: {bt.ea.cfg.ob_displacement_mult}')
    print(f'EA fvg_min_gap: {bt.ea.cfg.fvg_min_gap}')
    
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
