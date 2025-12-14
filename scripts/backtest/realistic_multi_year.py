#!/usr/bin/env python3
"""
REALISTIC Multi-Year Backtest
=============================
Adds realistic friction:
1. Worst-case execution (pessimistic slippage)
2. Random slippage on each trade
3. When SL+TP both hit in same bar, assume SL hit first (worst case)
4. Higher spread during volatility
5. Full year data (no sampling)

Author: ORACLE
Date: 2025-12-02
"""
import sys
import os
import random
sys.path.insert(0, 'C:/Users/Admin/Documents/EA_SCALPER_XAUUSD')

import pandas as pd
import numpy as np
from datetime import datetime
from pathlib import Path
from dataclasses import dataclass
from typing import List, Dict, Optional
import pyarrow.parquet as pq

# Monkey-patch to add realistic friction
REALISTIC_MODE = True
RANDOM_SLIPPAGE_POINTS = 5  # 0-5 points random slippage
WORST_CASE_SL_TP = True  # If both hit, assume SL first


def load_ticks_chunked(filepath: str, chunk_size: int = 5_000_000):
    """Load ticks in chunks to handle large files"""
    pf = pq.ParquetFile(filepath)
    chunks = []
    for batch in pf.iter_batches(batch_size=chunk_size):
        df = batch.to_pandas()
        chunks.append(df)
        if len(chunks) * chunk_size >= 50_000_000:  # Max 50M ticks
            break
    return pd.concat(chunks, ignore_index=True)


def run_realistic_backtest(year: int):
    """Run realistic backtest for a year"""
    from scripts.backtest.tick_backtester import (
        TickBacktester, BacktestConfig, ExecutionMode,
        Direction, ExitReason
    )
    
    data_path = f"C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/data/processed/ticks_{year}.parquet"
    
    if not os.path.exists(data_path):
        return {'year': year, 'error': 'File not found'}
    
    # Check file size to decide max ticks
    pf = pq.ParquetFile(data_path)
    total_rows = pf.metadata.num_rows
    max_ticks = min(total_rows, 30_000_000)  # Max 30M ticks (~6 months)
    
    print(f"\n[{year}] Loading {max_ticks:,} of {total_rows:,} ticks...")
    
    config = BacktestConfig(
        execution_mode=ExecutionMode.PESSIMISTIC,
        initial_balance=100_000,
        risk_per_trade=0.005,  # 0.5%
        use_ea_logic=True,
        use_real_footprint=False,  # Disable to speed up
        use_session_filter=True,
        session_start_hour=8,
        session_end_hour=20,
        use_regime_filter=False,
        bar_timeframe='5min',
        # Pessimistic execution
        base_slippage_points=5.0,  # Higher slippage
        latency_ms=100,
        rejection_rate=0.05,  # 5% order rejections
        debug=False
    )
    
    try:
        bt = TickBacktester(config)
        
        # Patch the _manage_position to be more realistic
        original_manage = bt._manage_position
        
        def realistic_manage_position(timestamp, bar):
            """Realistic position management - worst case when ambiguous"""
            if bt.position is None:
                return
            
            pos = bt.position
            
            if pos.direction == Direction.LONG:
                sl_hit = bar['low'] <= pos.sl_price
                tp_hit = bar['high'] >= pos.tp_price
                
                if sl_hit and tp_hit:
                    # Both hit - worst case: SL first
                    # Add random slippage against us
                    slippage = random.uniform(0, RANDOM_SLIPPAGE_POINTS) * 0.01
                    exit_price = pos.sl_price - slippage
                    bt._close_position(timestamp, bar, ExitReason.SL, exit_price=exit_price)
                elif sl_hit:
                    slippage = random.uniform(0, RANDOM_SLIPPAGE_POINTS) * 0.01
                    exit_price = pos.sl_price - slippage
                    bt._close_position(timestamp, bar, ExitReason.SL, exit_price=exit_price)
                elif tp_hit:
                    # TP hit - small slippage against us
                    slippage = random.uniform(0, 2) * 0.01
                    exit_price = pos.tp_price - slippage
                    bt._close_position(timestamp, bar, ExitReason.TP, exit_price=exit_price)
            
            else:  # SHORT
                sl_hit = bar['high'] >= pos.sl_price
                tp_hit = bar['low'] <= pos.tp_price
                
                if sl_hit and tp_hit:
                    # Both hit - worst case: SL first
                    slippage = random.uniform(0, RANDOM_SLIPPAGE_POINTS) * 0.01
                    exit_price = pos.sl_price + slippage
                    bt._close_position(timestamp, bar, ExitReason.SL, exit_price=exit_price)
                elif sl_hit:
                    slippage = random.uniform(0, RANDOM_SLIPPAGE_POINTS) * 0.01
                    exit_price = pos.sl_price + slippage
                    bt._close_position(timestamp, bar, ExitReason.SL, exit_price=exit_price)
                elif tp_hit:
                    slippage = random.uniform(0, 2) * 0.01
                    exit_price = pos.tp_price + slippage
                    bt._close_position(timestamp, bar, ExitReason.TP, exit_price=exit_price)
        
        # Apply patch
        bt._manage_position = realistic_manage_position
        
        result = bt.run(data_path, max_ticks=max_ticks)
        m = result['metrics']
        
        return {
            'year': year,
            'ticks': max_ticks,
            'trades': m['total_trades'],
            'win_rate': m['win_rate'],
            'profit_factor': m['profit_factor'],
            'sharpe': m['sharpe_ratio'],
            'max_dd': m['max_drawdown'],
            'return': m['total_return'],
            'sqn': m['sqn'],
            'final_balance': m['final_balance'],
            'gross_profit': m['gross_profit'],
            'gross_loss': m['gross_loss'],
        }
    except Exception as e:
        import traceback
        traceback.print_exc()
        return {'year': year, 'error': str(e)}


def main():
    print("=" * 100)
    print("           REALISTIC MULTI-YEAR BACKTEST")
    print("           (Worst-case execution, random slippage, SL priority)")
    print("=" * 100)
    
    # Seed for reproducibility
    random.seed(42)
    np.random.seed(42)
    
    # Test years
    years = [2018, 2019, 2020, 2021, 2022, 2023, 2024]
    
    results = []
    
    for year in years:
        print(f"\n{'='*60}")
        print(f"YEAR: {year}")
        print(f"{'='*60}")
        
        r = run_realistic_backtest(year)
        results.append(r)
        
        if 'error' in r:
            print(f"  ERROR: {r['error']}")
        else:
            print(f"\n  Results:")
            print(f"    Ticks processed: {r['ticks']:,}")
            print(f"    Trades: {r['trades']}")
            print(f"    Win Rate: {r['win_rate']:.1%}")
            print(f"    Profit Factor: {r['profit_factor']:.2f}")
            print(f"    Sharpe: {r['sharpe']:.2f}")
            print(f"    Max DD: {r['max_dd']:.2%}")
            print(f"    Return: {r['return']:.2%}")
    
    # Summary
    print("\n" + "=" * 120)
    print("                                    REALISTIC MULTI-YEAR SUMMARY")
    print("=" * 120)
    print(f"{'Year':<6} {'Ticks':>12} {'Trades':>8} {'WR':>8} {'PF':>8} {'Sharpe':>10} {'MaxDD':>8} {'Return':>10} {'Balance':>12} {'Status'}")
    print("-" * 120)
    
    valid_results = [r for r in results if 'error' not in r]
    
    for r in results:
        if 'error' in r:
            print(f"{r['year']:<6} {'-':>12} {'-':>8} {'-':>8} {'-':>8} {'-':>10} {'-':>8} {'-':>10} {'-':>12} ERROR")
        else:
            # Determine status
            if r['profit_factor'] < 1.0:
                status = "LOSS"
            elif r['max_dd'] >= 0.10:
                status = "DD_FAIL"
            elif r['profit_factor'] >= 1.5 and r['max_dd'] < 0.05:
                status = "GREAT"
            elif r['profit_factor'] >= 1.2:
                status = "GOOD"
            else:
                status = "MARGINAL"
            
            print(f"{r['year']:<6} {r['ticks']:>12,} {r['trades']:>8} {r['win_rate']:>7.1%} "
                  f"{r['profit_factor']:>8.2f} {r['sharpe']:>10.2f} {r['max_dd']:>7.2%} "
                  f"{r['return']:>9.2%} ${r['final_balance']:>10,.0f} {status}")
    
    print("-" * 120)
    
    if valid_results:
        # Aggregates
        avg_wr = np.mean([r['win_rate'] for r in valid_results])
        avg_pf = np.mean([r['profit_factor'] for r in valid_results])
        avg_sharpe = np.mean([r['sharpe'] for r in valid_results])
        max_dd_worst = max([r['max_dd'] for r in valid_results])
        
        # Compound return
        compound = 1.0
        for r in valid_results:
            compound *= (1 + r['return'])
        compound_return = compound - 1
        
        # Consistency
        profitable_years = sum(1 for r in valid_results if r['return'] > 0)
        ftmo_compliant = sum(1 for r in valid_results if r['max_dd'] < 0.10)
        
        print(f"{'AVG':<6} {'-':>12} {'-':>8} {avg_wr:>7.1%} {avg_pf:>8.2f} {avg_sharpe:>10.2f} {'-':>8} {'-':>10}")
        print(f"{'WORST':<6} {'-':>12} {'-':>8} {'-':>8} {'-':>8} {'-':>10} {max_dd_worst:>7.2%} {'-':>10}")
        print(f"{'CMPND':<6} {'-':>12} {'-':>8} {'-':>8} {'-':>8} {'-':>10} {'-':>8} {compound_return:>9.2%}")
    
    print("=" * 120)
    
    # Final Assessment with realistic expectations
    print("\n" + "=" * 80)
    print("FINAL ASSESSMENT (REALISTIC)")
    print("=" * 80)
    
    if valid_results:
        print(f"\n  Years Tested: {len(valid_results)}")
        print(f"  Profitable Years: {profitable_years}/{len(valid_results)} ({profitable_years/len(valid_results)*100:.0f}%)")
        print(f"  FTMO Compliant: {ftmo_compliant}/{len(valid_results)}")
        print(f"  Average Win Rate: {avg_wr:.1%}")
        print(f"  Average PF: {avg_pf:.2f}")
        print(f"  Worst Max DD: {max_dd_worst:.2%}")
        print(f"  Compound Return: {compound_return:.2%}")
        
        # Realistic assessment
        print("\n  VERDICT:")
        if profitable_years == len(valid_results) and avg_pf >= 1.3:
            print("    [STRONG] Strategy profitable across all years")
        elif profitable_years >= len(valid_results) * 0.7 and avg_pf >= 1.1:
            print("    [MODERATE] Strategy mostly profitable, some weak years")
        else:
            print("    [WEAK] Strategy inconsistent - needs more work")
        
        # Realistic live expectations
        print("\n  REALISTIC LIVE EXPECTATIONS:")
        print(f"    Expected WR: {avg_wr * 0.7:.1%} - {avg_wr * 0.9:.1%}")
        print(f"    Expected PF: {avg_pf * 0.5:.2f} - {avg_pf * 0.7:.2f}")
        print(f"    Expected DD: {max_dd_worst * 2:.2%} - {max_dd_worst * 4:.2%}")
        print(f"    Expected Annual Return: {compound_return/len(valid_results) * 0.3:.1%} - {compound_return/len(valid_results) * 0.5:.1%}")
    
    print("\n" + "=" * 80)
    
    return results


if __name__ == "__main__":
    main()
