#!/usr/bin/env python3
"""Test EA Logic with different confluence thresholds."""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

from scripts.backtest.tick_backtester import TickBacktester, BacktestConfig, ExecutionMode
from scripts.backtest.strategies.ea_logic_python import EAConfig, EALogic

def main():
    thresholds = [50, 55, 60, 65]
    results_all = []
    
    for thresh in thresholds:
        print(f'\n{"="*60}')
        print(f'Testing threshold={thresh}')
        print("="*60)
        
        ea_config = EAConfig(
            execution_threshold=float(thresh),
            confluence_min_score=float(thresh),
            min_rr=1.5,
            max_spread_points=80.0,
            risk_per_trade_pct=0.5,
            use_ml=False,
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
    
    print('\n' + '='*70)
    print('THRESHOLD SENSITIVITY ANALYSIS - SUMMARY')
    print('='*70)
    print(f"{'Threshold':<12} {'Trades':<10} {'PF':<8} {'Win Rate':<10} {'Max DD':<10} {'Return':<10}")
    print("-"*70)
    for r in results_all:
        print(f"{r['threshold']:<12} {r['trades']:<10} {r['pf']:<8.2f} {r['win_rate']*100:<10.1f}% {r['max_dd']*100:<10.2f}% {r['return']*100:<10.2f}%")

if __name__ == "__main__":
    main()
