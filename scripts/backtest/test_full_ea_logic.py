#!/usr/bin/env python3
"""
TEST: Full EA Logic Parity
==========================
Tests using ea_logic_full.py (COMPLETE port of MQL5 EA)
NOT the simplified ea_logic_python.py with relaxed thresholds.

This test uses realistic_backtester.py which properly implements:
- Real CRegimeDetector (Multi-scale Hurst, Variance Ratio)
- Real CConfluenceScorer (9 factors, Bayesian scoring)
- Real CSessionFilter (Session/Day quality)
- Real MTF alignment (H1, M15, M5)
- Real footprint analysis
- min_confluence = 65 (not relaxed 50)
- min_rr = 1.5 (not relaxed 1.0)

Author: ORACLE
Date: 2025-12-02
"""
import sys
sys.path.insert(0, 'C:/Users/Admin/Documents/EA_SCALPER_XAUUSD')
sys.path.insert(0, 'C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/scripts/backtest')

import os
import numpy as np
import random

# Check which logic is available
print("=" * 80)
print("CHECKING EA LOGIC AVAILABILITY")
print("=" * 80)

try:
    from scripts.backtest.strategies.ea_logic_full import (
        EALogicFull, create_ea_logic, SignalType, MarketRegime
    )
    print("[OK] ea_logic_full.py loaded (COMPLETE MQL5 PORT)")
    HAVE_FULL = True
except ImportError as e:
    print(f"[FAIL] ea_logic_full.py: {e}")
    HAVE_FULL = False

try:
    from scripts.backtest.strategies.ea_logic_python import EALogic, EAConfig
    print("[OK] ea_logic_python.py loaded (SIMPLIFIED)")
except ImportError as e:
    print(f"[FAIL] ea_logic_python.py: {e}")

print("=" * 80)

if not HAVE_FULL:
    print("\n[ERROR] ea_logic_full.py not available!")
    print("Cannot run FULL EA parity test.")
    sys.exit(1)


def test_with_realistic_backtester():
    """Test using realistic_backtester.py with FULL EA logic"""
    from scripts.backtest.realistic_backtester import (
        RealisticBacktester, RealisticBacktestConfig, ExecutionMode, USE_FULL_LOGIC
    )
    
    print("\n" + "=" * 80)
    print("TEST 1: REALISTIC BACKTESTER (FULL EA LOGIC)")
    print("=" * 80)
    
    print(f"\n[Config] USE_FULL_LOGIC = {USE_FULL_LOGIC}")
    
    if not USE_FULL_LOGIC:
        print("[WARNING] realistic_backtester is NOT using full EA logic!")
        print("         Results may not match real EA behavior.")
    
    data_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/data/processed/ticks_2024.parquet"
    
    if not os.path.exists(data_path):
        print(f"[ERROR] Data file not found: {data_path}")
        return None
    
    # Create config with REAL EA thresholds
    config = RealisticBacktestConfig(
        initial_balance=100_000,
        execution_mode=ExecutionMode.PESSIMISTIC,
        min_confluence=65.0,   # REAL threshold (not relaxed 50)
        min_rr=1.5,            # REAL RR (not relaxed 1.0)
        enable_footprint=True,
        enable_latency_sim=True,
        base_slippage_points=5.0,
        rejection_rate=0.05,
        debug=False
    )
    
    print(f"\n[Config] min_confluence = {config.min_confluence}")
    print(f"[Config] min_rr = {config.min_rr}")
    print(f"[Config] enable_footprint = {config.enable_footprint}")
    print(f"[Config] execution_mode = {config.execution_mode.value}")
    
    random.seed(42)
    np.random.seed(42)
    
    print("\n[Running backtest with FULL EA logic...]")
    
    try:
        bt = RealisticBacktester(config)
        result = bt.run(data_path, max_ticks=3_000_000)
        
        if result is None:
            print("[ERROR] Backtest returned None")
            return None
        
        m = result.get('metrics', {})
        
        print("\n" + "=" * 80)
        print("RESULTS (FULL EA LOGIC)")
        print("=" * 80)
        print(f"  Total Trades:    {m.get('total_trades', 0)}")
        print(f"  Win Rate:        {m.get('win_rate', 0):.1%}")
        print(f"  Profit Factor:   {m.get('profit_factor', 0):.2f}")
        print(f"  Sharpe Ratio:    {m.get('sharpe_ratio', 0):.2f}")
        print(f"  Max Drawdown:    {m.get('max_drawdown', 0):.2%}")
        print(f"  Total Return:    {m.get('total_return', 0):.2%}")
        print(f"  Net Profit:      ${m.get('net_profit', 0):,.2f}")
        
        # Gate statistics (if available)
        if hasattr(bt, 'ea_logic_full') and bt.ea_logic_full is not None:
            gates = bt.ea_logic_full.get_gate_stats()
            print("\n  Gate Blocks:")
            for gate, count in sorted(gates.items()):
                if count > 0:
                    print(f"    {gate}: {count}")
        
        return result
    except Exception as e:
        import traceback
        print(f"\n[ERROR] {e}")
        traceback.print_exc()
        return None


def compare_simplified_vs_full():
    """Compare simplified ea_logic_python vs full ea_logic_full"""
    from scripts.backtest.tick_backtester import (
        TickBacktester, BacktestConfig, ExecutionMode
    )
    
    print("\n" + "=" * 80)
    print("TEST 2: COMPARISON - SIMPLIFIED vs FULL")
    print("=" * 80)
    
    data_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/data/processed/ticks_2024.parquet"
    
    # Test 1: SIMPLIFIED (current tick_backtester with relaxed thresholds)
    print("\n[A] SIMPLIFIED (ea_logic_python, relaxed thresholds)...")
    config_simple = BacktestConfig(
        execution_mode=ExecutionMode.PESSIMISTIC,
        initial_balance=100_000,
        use_ea_logic=True,  # Uses ea_logic_python (simplified)
        use_session_filter=True,
        session_start_hour=8,
        session_end_hour=20,
        bar_timeframe='5min',
        base_slippage_points=5.0,
        rejection_rate=0.05,
    )
    
    random.seed(42)
    np.random.seed(42)
    
    bt_simple = TickBacktester(config_simple)
    result_simple = bt_simple.run(data_path, max_ticks=3_000_000)
    m_simple = result_simple['metrics']
    
    print(f"    Trades: {m_simple['total_trades']}, WR: {m_simple['win_rate']:.1%}, PF: {m_simple['profit_factor']:.2f}")
    
    # Test 2: FULL (realistic_backtester with real thresholds)
    print("\n[B] FULL (ea_logic_full, real thresholds)...")
    result_full = test_with_realistic_backtester()
    
    if result_full:
        m_full = result_full.get('metrics', {})
        
        # Comparison
        print("\n" + "=" * 80)
        print("COMPARISON: SIMPLIFIED vs FULL EA LOGIC")
        print("=" * 80)
        print(f"{'Metric':<20} {'Simplified':>15} {'Full':>15} {'Diff':>15}")
        print("-" * 65)
        print(f"{'Trades':<20} {m_simple['total_trades']:>15} {m_full.get('total_trades', 0):>15} "
              f"{m_full.get('total_trades', 0) - m_simple['total_trades']:>+15}")
        print(f"{'Win Rate':<20} {m_simple['win_rate']:>14.1%} {m_full.get('win_rate', 0):>14.1%}")
        print(f"{'Profit Factor':<20} {m_simple['profit_factor']:>15.2f} {m_full.get('profit_factor', 0):>15.2f}")
        print(f"{'Max DD':<20} {m_simple['max_drawdown']:>14.2%} {m_full.get('max_drawdown', 0):>14.2%}")
        print(f"{'Return':<20} {m_simple['total_return']:>14.2%} {m_full.get('total_return', 0):>14.2%}")
        print("=" * 80)
        
        # Warning if big difference
        trade_diff = abs(m_full.get('total_trades', 0) - m_simple['total_trades'])
        if trade_diff > m_simple['total_trades'] * 0.5:
            print("\n[!] WARNING: Significant difference in trade count!")
            print("    SIMPLIFIED logic is generating MORE trades than FULL EA logic.")
            print("    Previous backtest results may be OVERLY OPTIMISTIC.")
    
    return result_simple, result_full


if __name__ == "__main__":
    print("\n" + "=" * 80)
    print("EA LOGIC PARITY TEST")
    print("Testing with FULL EA logic (ea_logic_full.py)")
    print("NOT the simplified version (ea_logic_python.py)")
    print("=" * 80)
    
    # Run comparison
    compare_simplified_vs_full()
