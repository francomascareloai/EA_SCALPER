#!/usr/bin/env python3
"""
DETAILED HURST THRESHOLD STUDY
==============================
Tests Hurst thresholds in small increments to find optimal value.
"""

import sys
from pathlib import Path
from datetime import datetime
import pandas as pd
import numpy as np

PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from scripts.backtest.tick_backtester import (
    TickBacktester, BacktestConfig, ExecutionMode
)

DATA_DIR = PROJECT_ROOT / "data" / "processed"
OUTPUT_DIR = PROJECT_ROOT / "DOCS" / "04_REPORTS" / "BACKTESTS"


def test_hurst_threshold(data_path: str, hurst: float) -> dict:
    """Test a specific Hurst threshold"""
    try:
        config = BacktestConfig(
            execution_mode=ExecutionMode.PESSIMISTIC,
            initial_balance=1_000_000,
            risk_per_trade=0.005,
            use_regime_filter=True,
            hurst_threshold=hurst,
            use_session_filter=False,
            use_ea_logic=False,
            bar_timeframe='5min',
            debug=False
        )
        
        bt = TickBacktester(config)
        raw_results = bt.run(data_path, max_ticks=50_000_000)
        metrics = raw_results.get('metrics', raw_results)
        
        return {
            'hurst': hurst,
            'trades': metrics.get('total_trades', 0),
            'win_rate': metrics.get('win_rate', 0),
            'pf': metrics.get('profit_factor', 0),
            'return': metrics.get('total_return', 0),
            'dd': metrics.get('max_drawdown', 0),
            'sqn': metrics.get('sqn', 0),
            'success': True
        }
    except Exception as e:
        return {
            'hurst': hurst,
            'error': str(e),
            'success': False
        }


def main():
    print("="*70)
    print("  DETAILED HURST THRESHOLD STUDY")
    print("="*70)
    
    data_2024 = str(DATA_DIR / "ticks_2024.parquet")
    
    # Test Hurst from 0.48 to 0.65 in 0.01 increments
    hurst_values = [round(x * 0.01, 2) for x in range(48, 66)]
    
    results = []
    
    print(f"\n  Testing {len(hurst_values)} Hurst thresholds...\n")
    print(f"  {'Hurst':<8} {'Trades':<8} {'WR':<8} {'PF':<8} {'Return':<10} {'DD':<8} {'SQN':<8}")
    print(f"  {'-'*8} {'-'*8} {'-'*8} {'-'*8} {'-'*10} {'-'*8} {'-'*8}")
    
    for hurst in hurst_values:
        result = test_hurst_threshold(data_2024, hurst)
        results.append(result)
        
        if result['success']:
            print(f"  {hurst:<8.2f} {result['trades']:<8} {result['win_rate']*100:<7.1f}% "
                  f"{result['pf']:<8.2f} {result['return']*100:<9.1f}% "
                  f"{result['dd']*100:<7.1f}% {result['sqn']:<8.2f}")
    
    # Find optimal
    valid = [r for r in results if r.get('success') and r.get('trades', 0) > 30]
    
    if valid:
        # Best by PF
        best_pf = max(valid, key=lambda x: x.get('pf', 0))
        
        # Best by PF with acceptable trades (>100)
        high_trades = [r for r in valid if r.get('trades', 0) > 100]
        best_pf_ht = max(high_trades, key=lambda x: x.get('pf', 0)) if high_trades else None
        
        # Best by return with DD < 5%
        low_dd = [r for r in valid if r.get('dd', 1) < 0.05]
        best_ret_low_dd = max(low_dd, key=lambda x: x.get('return', -999)) if low_dd else None
        
        print("\n" + "="*70)
        print("  OPTIMAL HURST THRESHOLDS")
        print("="*70)
        
        print(f"\n  Best by PF (any trades):")
        print(f"    Hurst: {best_pf['hurst']:.2f} -> PF={best_pf['pf']:.2f}, Return={best_pf['return']*100:.1f}%, Trades={best_pf['trades']}")
        
        if best_pf_ht:
            print(f"\n  Best by PF (>100 trades):")
            print(f"    Hurst: {best_pf_ht['hurst']:.2f} -> PF={best_pf_ht['pf']:.2f}, Return={best_pf_ht['return']*100:.1f}%, Trades={best_pf_ht['trades']}")
        
        if best_ret_low_dd:
            print(f"\n  Best by Return (DD<5%):")
            print(f"    Hurst: {best_ret_low_dd['hurst']:.2f} -> Return={best_ret_low_dd['return']*100:.1f}%, PF={best_ret_low_dd['pf']:.2f}, DD={best_ret_low_dd['dd']*100:.1f}%")
    
    # Also test with session filter combination
    print("\n" + "="*70)
    print("  HURST + SESSION FILTER COMBINATIONS")
    print("="*70)
    
    top_hurst = [0.51, 0.52, 0.53, 0.54, 0.55]
    sessions = [
        ("NO_SESSION", False, 0, 24),
        ("ACTIVE_7_21", True, 7, 21),
        ("LONDON_7_16", True, 7, 16),
    ]
    
    combo_results = []
    
    print(f"\n  {'Combo':<35} {'Trades':<8} {'WR':<8} {'PF':<8} {'Return':<10} {'DD':<8}")
    print(f"  {'-'*35} {'-'*8} {'-'*8} {'-'*8} {'-'*10} {'-'*8}")
    
    for hurst in top_hurst:
        for sess_name, sess_enabled, sess_start, sess_end in sessions:
            try:
                config = BacktestConfig(
                    execution_mode=ExecutionMode.PESSIMISTIC,
                    initial_balance=1_000_000,
                    risk_per_trade=0.005,
                    use_regime_filter=True,
                    hurst_threshold=hurst,
                    use_session_filter=sess_enabled,
                    session_start_hour=sess_start,
                    session_end_hour=sess_end,
                    use_ea_logic=False,
                    bar_timeframe='5min',
                    debug=False
                )
                
                bt = TickBacktester(config)
                raw_results = bt.run(data_2024, max_ticks=50_000_000)
                metrics = raw_results.get('metrics', raw_results)
                
                combo_name = f"HURST_{hurst}+{sess_name}"
                r = {
                    'combo': combo_name,
                    'hurst': hurst,
                    'session': sess_name,
                    'trades': metrics.get('total_trades', 0),
                    'win_rate': metrics.get('win_rate', 0),
                    'pf': metrics.get('profit_factor', 0),
                    'return': metrics.get('total_return', 0),
                    'dd': metrics.get('max_drawdown', 0),
                }
                combo_results.append(r)
                
                print(f"  {combo_name:<35} {r['trades']:<8} {r['win_rate']*100:<7.1f}% "
                      f"{r['pf']:<8.2f} {r['return']*100:<9.1f}% {r['dd']*100:<7.1f}%")
                
            except Exception as e:
                print(f"  {combo_name:<35} ERROR: {str(e)[:30]}")
    
    # Find best combo
    valid_combos = [r for r in combo_results if r.get('trades', 0) > 30]
    if valid_combos:
        best_combo = max(valid_combos, key=lambda x: x.get('pf', 0))
        print(f"\n  BEST COMBO: {best_combo['combo']}")
        print(f"    PF={best_combo['pf']:.2f}, Return={best_combo['return']*100:.1f}%, DD={best_combo['dd']*100:.1f}%, Trades={best_combo['trades']}")
    
    print("\n" + "="*70)


if __name__ == "__main__":
    main()
