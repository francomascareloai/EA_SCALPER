#!/usr/bin/env python3
"""
Multi-Year Backtest - Comprehensive Validation
===============================================
Tests EA logic across multiple years to validate robustness.

Author: ORACLE
Date: 2025-12-02
"""
import sys
import os
sys.path.insert(0, 'C:/Users/Admin/Documents/EA_SCALPER_XAUUSD')

import pandas as pd
import numpy as np
from datetime import datetime
from pathlib import Path

from scripts.backtest.tick_backtester import TickBacktester, BacktestConfig, ExecutionMode

def run_year_backtest(year: int, max_ticks: int = 10_000_000) -> dict:
    """Run backtest for a specific year"""
    data_path = f"C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/data/processed/ticks_{year}.parquet"
    
    if not os.path.exists(data_path):
        return {'year': year, 'error': 'File not found'}
    
    config = BacktestConfig(
        execution_mode=ExecutionMode.PESSIMISTIC,
        initial_balance=100_000,
        risk_per_trade=0.005,
        use_ea_logic=True,
        use_real_footprint=True,
        use_session_filter=True,
        session_start_hour=8,
        session_end_hour=20,
        bar_timeframe='5min',
        debug=False
    )
    
    try:
        bt = TickBacktester(config)
        result = bt.run(data_path, max_ticks=max_ticks)
        m = result['metrics']
        
        return {
            'year': year,
            'trades': m['total_trades'],
            'win_rate': m['win_rate'],
            'profit_factor': m['profit_factor'],
            'sharpe': m['sharpe_ratio'],
            'max_dd': m['max_drawdown'],
            'return': m['total_return'],
            'sqn': m['sqn'],
            'final_balance': m['final_balance'],
        }
    except Exception as e:
        return {'year': year, 'error': str(e)}


def main():
    print("=" * 100)
    print("                    MULTI-YEAR BACKTEST - EA PARITY VALIDATION")
    print("=" * 100)
    
    # Years to test
    years = [2020, 2021, 2022, 2023, 2024]
    max_ticks = 15_000_000  # ~3 months per year
    
    results = []
    
    for year in years:
        print(f"\n{'='*50}")
        print(f"TESTING YEAR: {year}")
        print(f"{'='*50}")
        
        r = run_year_backtest(year, max_ticks)
        results.append(r)
        
        if 'error' in r:
            print(f"  ERROR: {r['error']}")
        else:
            print(f"  Trades: {r['trades']}")
            print(f"  Win Rate: {r['win_rate']:.1%}")
            print(f"  Profit Factor: {r['profit_factor']:.2f}")
            print(f"  Sharpe: {r['sharpe']:.2f}")
            print(f"  Max DD: {r['max_dd']:.2%}")
            print(f"  Return: {r['return']:.2%}")
    
    # Summary
    print("\n" + "=" * 100)
    print("                              MULTI-YEAR SUMMARY")
    print("=" * 100)
    print(f"{'Year':<8} {'Trades':>8} {'WR':>8} {'PF':>8} {'Sharpe':>10} {'MaxDD':>8} {'Return':>10} {'Status'}")
    print("-" * 100)
    
    valid_results = [r for r in results if 'error' not in r]
    
    for r in results:
        if 'error' in r:
            print(f"{r['year']:<8} {'ERROR':>8} {'-':>8} {'-':>8} {'-':>10} {'-':>8} {'-':>10} {r['error'][:30]}")
        else:
            status = "PASS" if r['profit_factor'] >= 1.0 and r['max_dd'] < 0.10 else "FAIL"
            if r['profit_factor'] >= 1.5 and r['max_dd'] < 0.05:
                status = "GREAT"
            print(f"{r['year']:<8} {r['trades']:>8} {r['win_rate']:>7.1%} {r['profit_factor']:>8.2f} "
                  f"{r['sharpe']:>10.2f} {r['max_dd']:>7.2%} {r['return']:>9.2%} {status}")
    
    print("-" * 100)
    
    if valid_results:
        avg_wr = np.mean([r['win_rate'] for r in valid_results])
        avg_pf = np.mean([r['profit_factor'] for r in valid_results])
        avg_sharpe = np.mean([r['sharpe'] for r in valid_results])
        avg_dd = np.mean([r['max_dd'] for r in valid_results])
        total_return = np.prod([1 + r['return'] for r in valid_results]) - 1
        
        print(f"{'AVG':<8} {'-':>8} {avg_wr:>7.1%} {avg_pf:>8.2f} {avg_sharpe:>10.2f} {avg_dd:>7.2%} {'-':>10}")
        print(f"{'COMPOUND':<8} {'-':>8} {'-':>8} {'-':>8} {'-':>10} {'-':>8} {total_return:>9.2%}")
    
    print("=" * 100)
    
    # Final Assessment
    print("\nFINAL ASSESSMENT:")
    
    profitable_years = sum(1 for r in valid_results if r['profit_factor'] >= 1.0)
    ftmo_compliant = sum(1 for r in valid_results if r['max_dd'] < 0.10)
    
    print(f"  Profitable Years: {profitable_years}/{len(valid_results)}")
    print(f"  FTMO Compliant: {ftmo_compliant}/{len(valid_results)}")
    
    if profitable_years == len(valid_results) and ftmo_compliant == len(valid_results):
        print("\n  [OK] STRATEGY VALIDATED - Profitable across all tested years")
    elif profitable_years >= len(valid_results) * 0.8:
        print("\n  [WARN] STRATEGY MARGINAL - Some years underperform")
    else:
        print("\n  [FAIL] STRATEGY FAILS - Not consistently profitable")
    
    return results


if __name__ == "__main__":
    main()
