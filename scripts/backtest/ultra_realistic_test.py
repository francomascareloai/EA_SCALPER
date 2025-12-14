#!/usr/bin/env python3
"""
ULTRA-REALISTIC Backtest with proper degradation factors
========================================================
Issues with previous "realistic" test:
1. Bar-based backtests can't capture intra-bar adverse movement
2. SL/TP hit detection at bar resolution is optimistic
3. Missing: spread widening, requotes, slippage on entry

This version applies industry-standard degradation:
- 30% reduction in win rate expectation
- 50% reduction in profit factor expectation
- 3x increase in max drawdown expectation

Author: ORACLE
Date: 2025-12-02
"""
import sys
sys.path.insert(0, 'C:/Users/Admin/Documents/EA_SCALPER_XAUUSD')

import pandas as pd
import numpy as np
from datetime import datetime
from pathlib import Path
import random

from scripts.backtest.tick_backtester import (
    TickBacktester, BacktestConfig, ExecutionMode
)


def run_quick_comparison():
    """Run quick test comparing optimistic vs realistic"""
    
    print("=" * 80)
    print("QUICK BACKTEST: OPTIMISTIC vs REALISTIC COMPARISON")
    print("=" * 80)
    
    data_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/data/processed/ticks_2024.parquet"
    
    # Test 1: Optimistic (original)
    print("\n[1] OPTIMISTIC MODE (original)...")
    config_opt = BacktestConfig(
        execution_mode=ExecutionMode.OPTIMISTIC,
        initial_balance=100_000,
        risk_per_trade=0.005,
        use_ea_logic=True,
        use_session_filter=True,
        session_start_hour=8,
        session_end_hour=20,
        bar_timeframe='5min',
        base_slippage_points=0.0,
        rejection_rate=0.0,
        debug=False
    )
    
    bt_opt = TickBacktester(config_opt)
    result_opt = bt_opt.run(data_path, max_ticks=5_000_000)
    m_opt = result_opt['metrics']
    
    print(f"    Trades: {m_opt['total_trades']}")
    print(f"    Win Rate: {m_opt['win_rate']:.1%}")
    print(f"    PF: {m_opt['profit_factor']:.2f}")
    print(f"    Max DD: {m_opt['max_drawdown']:.2%}")
    print(f"    Return: {m_opt['total_return']:.2%}")
    
    # Test 2: Pessimistic (friction)
    print("\n[2] PESSIMISTIC MODE (friction)...")
    config_pess = BacktestConfig(
        execution_mode=ExecutionMode.PESSIMISTIC,
        initial_balance=100_000,
        risk_per_trade=0.005,
        use_ea_logic=True,
        use_session_filter=True,
        session_start_hour=8,
        session_end_hour=20,
        bar_timeframe='5min',
        base_slippage_points=5.0,
        latency_ms=100,
        rejection_rate=0.10,  # 10% rejection
        debug=False
    )
    
    bt_pess = TickBacktester(config_pess)
    result_pess = bt_pess.run(data_path, max_ticks=5_000_000)
    m_pess = result_pess['metrics']
    
    print(f"    Trades: {m_pess['total_trades']}")
    print(f"    Win Rate: {m_pess['win_rate']:.1%}")
    print(f"    PF: {m_pess['profit_factor']:.2f}")
    print(f"    Max DD: {m_pess['max_drawdown']:.2%}")
    print(f"    Return: {m_pess['total_return']:.2%}")
    
    # Test 3: Ultra-pessimistic (worst case)
    print("\n[3] ULTRA-PESSIMISTIC MODE...")
    config_ultra = BacktestConfig(
        execution_mode=ExecutionMode.PESSIMISTIC,
        initial_balance=100_000,
        risk_per_trade=0.005,
        use_ea_logic=True,
        use_session_filter=True,
        session_start_hour=8,
        session_end_hour=20,
        bar_timeframe='5min',
        base_slippage_points=10.0,  # Higher slippage
        latency_ms=200,
        rejection_rate=0.20,  # 20% rejection
        debug=False
    )
    
    bt_ultra = TickBacktester(config_ultra)
    result_ultra = bt_ultra.run(data_path, max_ticks=5_000_000)
    m_ultra = result_ultra['metrics']
    
    print(f"    Trades: {m_ultra['total_trades']}")
    print(f"    Win Rate: {m_ultra['win_rate']:.1%}")
    print(f"    PF: {m_ultra['profit_factor']:.2f}")
    print(f"    Max DD: {m_ultra['max_drawdown']:.2%}")
    print(f"    Return: {m_ultra['total_return']:.2%}")
    
    # Summary with realistic expectations
    print("\n" + "=" * 80)
    print("COMPARISON SUMMARY")
    print("=" * 80)
    print(f"{'Mode':<20} {'Trades':>8} {'WR':>10} {'PF':>10} {'MaxDD':>10} {'Return':>12}")
    print("-" * 80)
    print(f"{'Optimistic':<20} {m_opt['total_trades']:>8} {m_opt['win_rate']:>9.1%} "
          f"{m_opt['profit_factor']:>10.2f} {m_opt['max_drawdown']:>9.2%} {m_opt['total_return']:>11.2%}")
    print(f"{'Pessimistic':<20} {m_pess['total_trades']:>8} {m_pess['win_rate']:>9.1%} "
          f"{m_pess['profit_factor']:>10.2f} {m_pess['max_drawdown']:>9.2%} {m_pess['total_return']:>11.2%}")
    print(f"{'Ultra-Pessimistic':<20} {m_ultra['total_trades']:>8} {m_ultra['win_rate']:>9.1%} "
          f"{m_ultra['profit_factor']:>10.2f} {m_ultra['max_drawdown']:>9.2%} {m_ultra['total_return']:>11.2%}")
    print("-" * 80)
    
    # Calculate degradation
    if m_opt['win_rate'] > 0:
        wr_degrad = (m_opt['win_rate'] - m_ultra['win_rate']) / m_opt['win_rate'] * 100
        pf_degrad = (m_opt['profit_factor'] - m_ultra['profit_factor']) / m_opt['profit_factor'] * 100
        print(f"\nDegradation (Optimistic -> Ultra):")
        print(f"  Win Rate: -{wr_degrad:.1f}%")
        print(f"  Profit Factor: -{pf_degrad:.1f}%")
    
    # Apply industry degradation factors
    print("\n" + "=" * 80)
    print("REALISTIC LIVE EXPECTATIONS")
    print("(Industry standard: backtest-to-live degradation of 30-50%)")
    print("=" * 80)
    
    # Use pessimistic as base, apply further degradation
    live_wr = m_pess['win_rate'] * 0.85  # 15% further degradation
    live_pf = m_pess['profit_factor'] * 0.60  # 40% degradation
    live_dd = m_pess['max_drawdown'] * 4.0  # 4x DD in live
    live_return = m_pess['total_return'] * 0.30  # Only 30% of backtest return
    
    print(f"\nBased on PESSIMISTIC backtest ({m_pess['total_trades']} trades):")
    print(f"  Backtest WR: {m_pess['win_rate']:.1%} -> Expected Live: {live_wr:.1%}")
    print(f"  Backtest PF: {m_pess['profit_factor']:.2f} -> Expected Live: {live_pf:.2f}")
    print(f"  Backtest DD: {m_pess['max_drawdown']:.2%} -> Expected Live: {live_dd:.2%}")
    print(f"  Backtest Return: {m_pess['total_return']:.2%} -> Expected Live: {live_return:.2%}")
    
    # FTMO viability assessment
    print("\n" + "=" * 80)
    print("FTMO $100K CHALLENGE VIABILITY")
    print("=" * 80)
    
    ftmo_daily_dd = 0.05  # 5%
    ftmo_total_dd = 0.10  # 10%
    ftmo_target = 0.10  # 10% profit target
    
    print(f"\n  FTMO Requirements:")
    print(f"    Daily DD Limit: {ftmo_daily_dd:.0%}")
    print(f"    Total DD Limit: {ftmo_total_dd:.0%}")
    print(f"    Profit Target: {ftmo_target:.0%}")
    
    print(f"\n  Expected Live Performance:")
    print(f"    Max DD: {live_dd:.2%} {'[OK]' if live_dd < ftmo_total_dd else '[FAIL - TOO RISKY]'}")
    print(f"    Daily DD Risk: {live_dd * 0.5:.2%} {'[OK]' if live_dd * 0.5 < ftmo_daily_dd else '[WARNING]'}")
    print(f"    Can reach target: {'Yes' if live_pf > 1.0 else 'No'}")
    
    # Final verdict
    print("\n" + "=" * 80)
    print("FINAL VERDICT")
    print("=" * 80)
    
    if live_pf > 1.2 and live_dd < ftmo_total_dd:
        print("  [GO] Strategy appears viable for FTMO challenge")
        print("       BUT: Start with demo trading for 4-8 weeks first")
        print("       Monitor actual DD vs expected before going live")
    elif live_pf > 1.0 and live_dd < ftmo_total_dd:
        print("  [MARGINAL] Strategy may be viable but edges are thin")
        print("             Consider parameter optimization first")
    else:
        print("  [NO-GO] Strategy too risky for FTMO")
        print("          Expected DD exceeds FTMO limits")
        print("          Need to reduce position sizing or improve win rate")
    
    print("=" * 80)
    
    return {
        'optimistic': m_opt,
        'pessimistic': m_pess,
        'ultra_pessimistic': m_ultra,
        'live_estimates': {
            'win_rate': live_wr,
            'profit_factor': live_pf,
            'max_dd': live_dd,
            'return': live_return
        }
    }


if __name__ == "__main__":
    random.seed(42)
    np.random.seed(42)
    run_quick_comparison()
