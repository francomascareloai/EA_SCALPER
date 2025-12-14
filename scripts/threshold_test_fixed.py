#!/usr/bin/env python3
"""Test EA Logic with different confluence thresholds - FIXED CONFIG."""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

from scripts.backtest.tick_backtester import TickBacktester, BacktestConfig, ExecutionMode
from scripts.backtest.strategies.ea_logic_python import EAConfig, EALogic

def main():
    # Thresholds to test
    thresholds = [50, 55, 60, 65, 70]
    results_all = []
    
    for thresh in thresholds:
        print(f'\n{"="*70}')
        print(f'Testing threshold={thresh}')
        print("="*70)
        
        # IMPORTANT: Match ALL parameters from backtester's default config
        ea_config = EAConfig(
            risk_per_trade_pct=0.5,
            execution_threshold=float(thresh),
            confluence_min_score=float(thresh),
            min_rr=1.0,                     # KEY: Relaxed from 1.5
            max_spread_points=120.0,        # KEY: Relaxed from 80
            allow_asian=True,
            allow_late_ny=True,
            use_ml=False,
            use_fib_filter=False,           # KEY: Must be False
            ob_displacement_mult=1.5,       # KEY: Relaxed from 2.0
            fvg_min_gap=0.2,                # KEY: Relaxed from 0.3
            use_mtf=False
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
            atr_period=14,
            atr_sl_mult=2.0,
            atr_tp_mult=3.0,
            fp_score=50.0,
            debug=False
        )
        
        bt = TickBacktester(config)
        # Override EA with our custom config
        bt.ea = EALogic(ea_config, initial_balance=100_000.0)
        
        results = bt.run(
            tick_path='data/processed/ticks_2024.parquet',
            max_ticks=56_000_000
        )
        
        m = results.get('metrics', {})
        trades = m.get('total_trades', 0)
        pf = m.get('profit_factor', 0)
        wr = m.get('win_rate', 0)
        dd = m.get('max_drawdown', 0)
        ret = m.get('total_return', 0)
        
        results_all.append({
            'threshold': thresh,
            'trades': trades,
            'pf': pf,
            'win_rate': wr,
            'max_dd': dd,
            'return': ret
        })
    
    print('\n' + '='*80)
    print('THRESHOLD SENSITIVITY ANALYSIS - FIXED CONFIG')
    print('='*80)
    print(f"{'Threshold':<12} {'Trades':<10} {'PF':<10} {'Win Rate':<12} {'Max DD':<12} {'Return':<12}")
    print("-"*80)
    for r in results_all:
        wr_str = f"{r['win_rate']*100:.1f}%" if r['win_rate'] else "N/A"
        dd_str = f"{r['max_dd']*100:.2f}%" if r['max_dd'] else "N/A"
        ret_str = f"{r['return']*100:.2f}%" if r['return'] else "N/A"
        print(f"{r['threshold']:<12} {r['trades']:<10} {r['pf']:<10.2f} {wr_str:<12} {dd_str:<12} {ret_str:<12}")
    
    # Identify best config
    print('\n' + '='*80)
    print('RECOMMENDATION')
    print('='*80)
    
    profitable = [r for r in results_all if r['pf'] > 1.0 and r['trades'] >= 100]
    if profitable:
        # Best by PF with reasonable trade count
        best = max(profitable, key=lambda x: x['pf'] if x['trades'] >= 100 else 0)
        print(f"Best config: threshold={best['threshold']}")
        print(f"  Trades: {best['trades']}, PF: {best['pf']:.2f}, Return: {best['return']*100:.2f}%")
    else:
        print("No profitable configuration found with threshold >= 50")

if __name__ == "__main__":
    main()
