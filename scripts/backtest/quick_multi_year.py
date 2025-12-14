#!/usr/bin/env python3
"""
Quick Multi-Year Test (Optimized for speed)
============================================
Tests strategy across multiple years with realistic friction.
Uses smaller sample (3M ticks per year) for faster execution.

Author: ORACLE
Date: 2025-12-02
"""
import sys
sys.path.insert(0, 'C:/Users/Admin/Documents/EA_SCALPER_XAUUSD')

import os
import pandas as pd
import numpy as np
import random
from datetime import datetime

from scripts.backtest.tick_backtester import (
    TickBacktester, BacktestConfig, ExecutionMode
)


def run_quick_multi_year():
    """Run quick multi-year validation"""
    
    print("=" * 100)
    print("QUICK MULTI-YEAR BACKTEST (Realistic Friction)")
    print("=" * 100)
    
    years = [2021, 2022, 2023, 2024]
    results = []
    
    for year in years:
        data_path = f"C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/data/processed/ticks_{year}.parquet"
        
        if not os.path.exists(data_path):
            print(f"\n[{year}] Data not found - skipping")
            results.append({'year': year, 'error': 'File not found'})
            continue
        
        print(f"\n[{year}] Running backtest...")
        
        config = BacktestConfig(
            execution_mode=ExecutionMode.PESSIMISTIC,
            initial_balance=100_000,
            risk_per_trade=0.005,
            use_ea_logic=True,
            use_session_filter=True,
            session_start_hour=8,
            session_end_hour=20,
            bar_timeframe='5min',
            base_slippage_points=10.0,  # Realistic slippage
            rejection_rate=0.05,
            debug=False
        )
        
        random.seed(42)
        np.random.seed(42)
        
        try:
            bt = TickBacktester(config)
            result = bt.run(data_path, max_ticks=3_000_000)  # Smaller sample for speed
            m = result['metrics']
            
            results.append({
                'year': year,
                'trades': m['total_trades'],
                'win_rate': m['win_rate'],
                'pf': m['profit_factor'],
                'sharpe': m['sharpe_ratio'],
                'max_dd': m['max_drawdown'],
                'return': m['total_return'],
                'net_profit': m['net_profit']
            })
            
            status = "OK" if m['profit_factor'] >= 1.0 else "LOSS"
            print(f"    Trades: {m['total_trades']}, WR: {m['win_rate']:.1%}, "
                  f"PF: {m['profit_factor']:.2f}, DD: {m['max_drawdown']:.2%} [{status}]")
        except Exception as e:
            print(f"    ERROR: {e}")
            results.append({'year': year, 'error': str(e)})
    
    # Summary
    print("\n" + "=" * 100)
    print("MULTI-YEAR SUMMARY")
    print("=" * 100)
    print(f"{'Year':>6} {'Trades':>8} {'WR':>8} {'PF':>8} {'Sharpe':>10} {'MaxDD':>10} {'Return':>10} {'Net Profit':>12} {'Status'}")
    print("-" * 100)
    
    valid_results = [r for r in results if 'error' not in r]
    
    for r in results:
        if 'error' in r:
            print(f"{r['year']:>6} {'ERROR':>8}")
        else:
            status = "OK" if r['pf'] >= 1.0 else "LOSS"
            print(f"{r['year']:>6} {r['trades']:>8} {r['win_rate']:>7.1%} {r['pf']:>8.2f} "
                  f"{r['sharpe']:>10.1f} {r['max_dd']:>9.2%} {r['return']:>9.2%} ${r['net_profit']:>10,.0f} {status}")
    
    if valid_results:
        # Aggregates
        avg_wr = np.mean([r['win_rate'] for r in valid_results])
        avg_pf = np.mean([r['pf'] for r in valid_results])
        avg_sharpe = np.mean([r['sharpe'] for r in valid_results])
        worst_dd = max([r['max_dd'] for r in valid_results])
        
        print("-" * 100)
        print(f"{'AVG':>6} {'-':>8} {avg_wr:>7.1%} {avg_pf:>8.2f} {avg_sharpe:>10.1f}")
        print(f"{'WORST':>6} {'-':>8} {'-':>8} {'-':>8} {'-':>10} {worst_dd:>9.2%}")
        
        # Compound return
        compound = 1.0
        for r in valid_results:
            compound *= (1 + r['return'])
        print(f"{'CMPND':>6} {'-':>8} {'-':>8} {'-':>8} {'-':>10} {'-':>10} {(compound-1):>9.2%}")
        
        # Consistency
        profitable_years = sum(1 for r in valid_results if r['pf'] >= 1.0)
        strong_years = sum(1 for r in valid_results if r['pf'] >= 1.5)
        
        print("\n" + "=" * 100)
        print("CONSISTENCY ANALYSIS")
        print("=" * 100)
        print(f"  Years tested: {len(valid_results)}")
        print(f"  Profitable years: {profitable_years}/{len(valid_results)} ({profitable_years/len(valid_results)*100:.0f}%)")
        print(f"  Strong years (PF>1.5): {strong_years}/{len(valid_results)}")
        print(f"  Average Win Rate: {avg_wr:.1%}")
        print(f"  Average PF: {avg_pf:.2f}")
        print(f"  Worst Max DD: {worst_dd:.2%}")
        
        # FINAL VERDICT
        print("\n" + "=" * 100)
        print("FINAL VERDICT")
        print("=" * 100)
        
        if profitable_years == len(valid_results) and avg_pf >= 2.0:
            verdict = "STRONG GO"
            msg = "Strategy consistently profitable across all years with strong metrics"
        elif profitable_years == len(valid_results) and avg_pf >= 1.3:
            verdict = "GO"
            msg = "Strategy profitable in all tested years"
        elif profitable_years >= len(valid_results) * 0.75:
            verdict = "MARGINAL GO"
            msg = "Strategy mostly profitable, some weak years"
        else:
            verdict = "NO-GO"
            msg = "Strategy inconsistent or unprofitable"
        
        print(f"  [{verdict}] {msg}")
        
        # Live expectations
        print("\n  Expected Live Performance (with 30% degradation):")
        print(f"    Win Rate: {avg_wr:.1%} -> {avg_wr * 0.7:.1%}")
        print(f"    Profit Factor: {avg_pf:.2f} -> {avg_pf * 0.5:.2f}")
        print(f"    Max DD: {worst_dd:.2%} -> {worst_dd * 4:.2%}")
    
    print("=" * 100)
    
    return results


if __name__ == "__main__":
    run_quick_multi_year()
