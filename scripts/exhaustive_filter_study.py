#!/usr/bin/env python3
"""
EXHAUSTIVE FILTER ABLATION STUDY
================================
Tests ALL combinations of filters to find optimal configuration.

Filters to test:
1. Session Hours (start/end)
2. Regime Filter (Hurst threshold)
3. Bar Timeframe
4. Risk per Trade
5. Execution Mode

Author: FORGE + ORACLE
Date: 2025-12-02
"""

import sys
import os
import json
import itertools
from pathlib import Path
from datetime import datetime
from dataclasses import dataclass, asdict
from typing import Dict, List, Tuple, Optional
import pandas as pd
import numpy as np
from concurrent.futures import ProcessPoolExecutor, as_completed
import warnings
warnings.filterwarnings('ignore')

PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from scripts.backtest.tick_backtester import (
    TickBacktester, BacktestConfig, ExecutionMode
)

DATA_DIR = PROJECT_ROOT / "data" / "processed"
OUTPUT_DIR = PROJECT_ROOT / "DOCS" / "04_REPORTS" / "BACKTESTS"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


# ============================================================================
# FILTER CONFIGURATIONS TO TEST
# ============================================================================

# Session Filter Configurations
SESSION_CONFIGS = [
    {"name": "NO_FILTER", "enabled": False, "start": 0, "end": 24},
    {"name": "LONDON_ONLY", "enabled": True, "start": 7, "end": 16},
    {"name": "NY_ONLY", "enabled": True, "start": 13, "end": 22},
    {"name": "LONDON_NY_OVERLAP", "enabled": True, "start": 13, "end": 17},
    {"name": "ACTIVE_HOURS", "enabled": True, "start": 7, "end": 21},
    {"name": "EXTENDED_ACTIVE", "enabled": True, "start": 6, "end": 22},
    {"name": "MORNING_LONDON", "enabled": True, "start": 7, "end": 12},
    {"name": "AFTERNOON_NY", "enabled": True, "start": 14, "end": 20},
    {"name": "ASIA_EXCLUDED", "enabled": True, "start": 5, "end": 23},
]

# Regime Filter Configurations  
REGIME_CONFIGS = [
    {"name": "NO_REGIME", "enabled": False, "hurst": 0.50},
    {"name": "HURST_0.50", "enabled": True, "hurst": 0.50},
    {"name": "HURST_0.52", "enabled": True, "hurst": 0.52},
    {"name": "HURST_0.55", "enabled": True, "hurst": 0.55},
    {"name": "HURST_0.58", "enabled": True, "hurst": 0.58},
    {"name": "HURST_0.60", "enabled": True, "hurst": 0.60},
]

# Timeframe Configurations
TIMEFRAME_CONFIGS = [
    "1min",
    "5min",
    "15min",
    "30min",
]

# Risk Per Trade
RISK_CONFIGS = [
    0.003,  # 0.3%
    0.005,  # 0.5%
    0.007,  # 0.7%
    0.010,  # 1.0%
]


def run_single_test(config_dict: dict, data_path: str, test_name: str) -> dict:
    """Run a single backtest configuration"""
    try:
        config = BacktestConfig(
            execution_mode=ExecutionMode.PESSIMISTIC,
            initial_balance=1_000_000,  # Large balance to avoid DD limit
            risk_per_trade=config_dict['risk'],
            use_regime_filter=config_dict['regime_enabled'],
            hurst_threshold=config_dict['hurst'],
            use_session_filter=config_dict['session_enabled'],
            session_start_hour=config_dict['session_start'],
            session_end_hour=config_dict['session_end'],
            use_ea_logic=False,
            bar_timeframe=config_dict['timeframe'],
            debug=False
        )
        
        bt = TickBacktester(config)
        raw_results = bt.run(data_path, max_ticks=50_000_000)
        metrics = raw_results.get('metrics', raw_results)
        
        return {
            'test_name': test_name,
            'config': config_dict,
            'trades': metrics.get('total_trades', 0),
            'win_rate': metrics.get('win_rate', 0),
            'pf': metrics.get('profit_factor', 0),
            'return': metrics.get('total_return', 0),
            'dd': metrics.get('max_drawdown', 0),
            'sharpe': metrics.get('sharpe_ratio', 0),
            'sqn': metrics.get('sqn', 0),
            'success': True
        }
    except Exception as e:
        return {
            'test_name': test_name,
            'config': config_dict,
            'error': str(e),
            'success': False
        }


def run_session_filter_study(data_path: str) -> List[dict]:
    """Test all session filter configurations"""
    print("\n" + "="*70)
    print("  STUDY 1: SESSION FILTER ABLATION")
    print("="*70)
    
    results = []
    
    for session in SESSION_CONFIGS:
        config_dict = {
            'session_enabled': session['enabled'],
            'session_start': session['start'],
            'session_end': session['end'],
            'regime_enabled': False,
            'hurst': 0.50,
            'timeframe': '5min',
            'risk': 0.005
        }
        
        test_name = f"SESSION_{session['name']}"
        print(f"  Testing: {test_name}...", end=" ", flush=True)
        
        result = run_single_test(config_dict, data_path, test_name)
        results.append(result)
        
        if result['success']:
            print(f"{result['trades']} trades, PF={result['pf']:.2f}, Return={result['return']*100:.1f}%")
        else:
            print(f"ERROR: {result.get('error', 'Unknown')[:50]}")
    
    return results


def run_regime_filter_study(data_path: str) -> List[dict]:
    """Test all regime filter configurations"""
    print("\n" + "="*70)
    print("  STUDY 2: REGIME FILTER ABLATION")
    print("="*70)
    
    results = []
    
    for regime in REGIME_CONFIGS:
        config_dict = {
            'session_enabled': False,
            'session_start': 0,
            'session_end': 24,
            'regime_enabled': regime['enabled'],
            'hurst': regime['hurst'],
            'timeframe': '5min',
            'risk': 0.005
        }
        
        test_name = f"REGIME_{regime['name']}"
        print(f"  Testing: {test_name}...", end=" ", flush=True)
        
        result = run_single_test(config_dict, data_path, test_name)
        results.append(result)
        
        if result['success']:
            print(f"{result['trades']} trades, PF={result['pf']:.2f}, Return={result['return']*100:.1f}%")
        else:
            print(f"ERROR: {result.get('error', 'Unknown')[:50]}")
    
    return results


def run_timeframe_study(data_path: str) -> List[dict]:
    """Test all timeframe configurations"""
    print("\n" + "="*70)
    print("  STUDY 3: TIMEFRAME ABLATION")
    print("="*70)
    
    results = []
    
    for tf in TIMEFRAME_CONFIGS:
        config_dict = {
            'session_enabled': False,
            'session_start': 0,
            'session_end': 24,
            'regime_enabled': False,
            'hurst': 0.50,
            'timeframe': tf,
            'risk': 0.005
        }
        
        test_name = f"TIMEFRAME_{tf}"
        print(f"  Testing: {test_name}...", end=" ", flush=True)
        
        result = run_single_test(config_dict, data_path, test_name)
        results.append(result)
        
        if result['success']:
            print(f"{result['trades']} trades, PF={result['pf']:.2f}, Return={result['return']*100:.1f}%")
        else:
            print(f"ERROR: {result.get('error', 'Unknown')[:50]}")
    
    return results


def run_risk_study(data_path: str) -> List[dict]:
    """Test all risk configurations"""
    print("\n" + "="*70)
    print("  STUDY 4: RISK PER TRADE ABLATION")
    print("="*70)
    
    results = []
    
    for risk in RISK_CONFIGS:
        config_dict = {
            'session_enabled': False,
            'session_start': 0,
            'session_end': 24,
            'regime_enabled': False,
            'hurst': 0.50,
            'timeframe': '5min',
            'risk': risk
        }
        
        test_name = f"RISK_{risk*100:.1f}pct"
        print(f"  Testing: {test_name}...", end=" ", flush=True)
        
        result = run_single_test(config_dict, data_path, test_name)
        results.append(result)
        
        if result['success']:
            print(f"{result['trades']} trades, PF={result['pf']:.2f}, Return={result['return']*100:.1f}%")
        else:
            print(f"ERROR: {result.get('error', 'Unknown')[:50]}")
    
    return results


def run_combined_study(data_path: str, top_session: dict, top_regime: dict) -> List[dict]:
    """Test combinations of best filters"""
    print("\n" + "="*70)
    print("  STUDY 5: COMBINED FILTER STUDY")
    print("="*70)
    
    results = []
    
    # Test: Best Session + Each Regime
    for regime in REGIME_CONFIGS:
        config_dict = {
            'session_enabled': top_session['enabled'],
            'session_start': top_session['start'],
            'session_end': top_session['end'],
            'regime_enabled': regime['enabled'],
            'hurst': regime['hurst'],
            'timeframe': '5min',
            'risk': 0.005
        }
        
        test_name = f"COMBINED_{top_session['name']}+{regime['name']}"
        print(f"  Testing: {test_name}...", end=" ", flush=True)
        
        result = run_single_test(config_dict, data_path, test_name)
        results.append(result)
        
        if result['success']:
            print(f"{result['trades']} trades, PF={result['pf']:.2f}, Return={result['return']*100:.1f}%")
        else:
            print(f"ERROR: {result.get('error', 'Unknown')[:50]}")
    
    return results


def run_full_grid_search(data_path: str) -> List[dict]:
    """Full grid search of all combinations (expensive!)"""
    print("\n" + "="*70)
    print("  STUDY 6: FULL GRID SEARCH (Session x Regime x Timeframe)")
    print("="*70)
    
    # Reduced set for performance
    sessions_reduced = [
        {"name": "NO_FILTER", "enabled": False, "start": 0, "end": 24},
        {"name": "LONDON_NY_OVERLAP", "enabled": True, "start": 13, "end": 17},
        {"name": "ACTIVE_HOURS", "enabled": True, "start": 7, "end": 21},
    ]
    
    regimes_reduced = [
        {"name": "NO_REGIME", "enabled": False, "hurst": 0.50},
        {"name": "HURST_0.55", "enabled": True, "hurst": 0.55},
        {"name": "HURST_0.60", "enabled": True, "hurst": 0.60},
    ]
    
    timeframes_reduced = ["5min", "15min"]
    
    results = []
    total = len(sessions_reduced) * len(regimes_reduced) * len(timeframes_reduced)
    count = 0
    
    for session in sessions_reduced:
        for regime in regimes_reduced:
            for tf in timeframes_reduced:
                count += 1
                config_dict = {
                    'session_enabled': session['enabled'],
                    'session_start': session['start'],
                    'session_end': session['end'],
                    'regime_enabled': regime['enabled'],
                    'hurst': regime['hurst'],
                    'timeframe': tf,
                    'risk': 0.005
                }
                
                test_name = f"GRID_{session['name']}_{regime['name']}_{tf}"
                print(f"  [{count}/{total}] {test_name}...", end=" ", flush=True)
                
                result = run_single_test(config_dict, data_path, test_name)
                results.append(result)
                
                if result['success']:
                    print(f"PF={result['pf']:.2f}, Return={result['return']*100:.1f}%")
                else:
                    print(f"ERROR")
    
    return results


def generate_report(all_results: dict, output_path: Path):
    """Generate comprehensive report"""
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write("# EXHAUSTIVE FILTER ABLATION STUDY\n\n")
        f.write(f"**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        f.write("---\n\n")
        
        # Summary of best configurations
        f.write("## BEST CONFIGURATIONS SUMMARY\n\n")
        
        for study_name, results in all_results.items():
            valid = [r for r in results if r.get('success', False) and r.get('trades', 0) > 20]
            if not valid:
                continue
            
            # Sort by PF
            by_pf = sorted(valid, key=lambda x: x.get('pf', 0), reverse=True)
            best = by_pf[0] if by_pf else None
            
            if best:
                f.write(f"### {study_name}\n\n")
                f.write(f"**Best**: {best['test_name']}\n")
                f.write(f"- PF: {best['pf']:.2f}\n")
                f.write(f"- Return: {best['return']*100:.1f}%\n")
                f.write(f"- Trades: {best['trades']}\n")
                f.write(f"- Win Rate: {best['win_rate']*100:.1f}%\n")
                f.write(f"- Max DD: {best['dd']*100:.1f}%\n")
                f.write(f"- SQN: {best['sqn']:.2f}\n\n")
        
        f.write("---\n\n")
        
        # Detailed tables for each study
        for study_name, results in all_results.items():
            valid = [r for r in results if r.get('success', False)]
            if not valid:
                continue
            
            f.write(f"## {study_name}\n\n")
            f.write("| Configuration | Trades | WR | PF | Return | DD | SQN |\n")
            f.write("|--------------|--------|----|----|--------|----|----- |\n")
            
            # Sort by PF descending
            sorted_results = sorted(valid, key=lambda x: x.get('pf', 0), reverse=True)
            
            for r in sorted_results:
                f.write(f"| {r['test_name']} | {r['trades']} | "
                       f"{r['win_rate']*100:.1f}% | {r['pf']:.2f} | "
                       f"{r['return']*100:.1f}% | {r['dd']*100:.1f}% | "
                       f"{r['sqn']:.2f} |\n")
            
            f.write("\n")
        
        # Final recommendations
        f.write("---\n\n")
        f.write("## FINAL RECOMMENDATIONS\n\n")
        
        # Find overall best
        all_valid = []
        for results in all_results.values():
            all_valid.extend([r for r in results if r.get('success', False) and r.get('trades', 0) > 30])
        
        if all_valid:
            # Top 5 by PF
            top_by_pf = sorted(all_valid, key=lambda x: x.get('pf', 0), reverse=True)[:5]
            
            f.write("### Top 5 by Profit Factor\n\n")
            for i, r in enumerate(top_by_pf, 1):
                f.write(f"{i}. **{r['test_name']}**: PF={r['pf']:.2f}, Return={r['return']*100:.1f}%, DD={r['dd']*100:.1f}%\n")
            
            f.write("\n")
            
            # Top 5 by Return with DD < 5%
            low_dd = [r for r in all_valid if r.get('dd', 1) < 0.05]
            if low_dd:
                top_by_return = sorted(low_dd, key=lambda x: x.get('return', 0), reverse=True)[:5]
                
                f.write("### Top 5 by Return (DD < 5%)\n\n")
                for i, r in enumerate(top_by_return, 1):
                    f.write(f"{i}. **{r['test_name']}**: Return={r['return']*100:.1f}%, PF={r['pf']:.2f}, DD={r['dd']*100:.1f}%\n")
            
            f.write("\n")
            
            # Top 5 by SQN
            top_by_sqn = sorted(all_valid, key=lambda x: x.get('sqn', -999), reverse=True)[:5]
            
            f.write("### Top 5 by SQN\n\n")
            for i, r in enumerate(top_by_sqn, 1):
                f.write(f"{i}. **{r['test_name']}**: SQN={r['sqn']:.2f}, PF={r['pf']:.2f}, Return={r['return']*100:.1f}%\n")
        
        f.write("\n---\n\n")
        f.write("*Report generated by ORACLE + FORGE - Exhaustive Filter Study*\n")
    
    print(f"\n[+] Report saved: {output_path}")


def main():
    print("="*70)
    print("  EXHAUSTIVE FILTER ABLATION STUDY")
    print("="*70)
    print(f"  Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("="*70)
    
    # Use 2024 data for testing
    data_2024 = str(DATA_DIR / "ticks_2024.parquet")
    
    all_results = {}
    
    # Study 1: Session Filters
    all_results['SESSION_FILTERS'] = run_session_filter_study(data_2024)
    
    # Study 2: Regime Filters
    all_results['REGIME_FILTERS'] = run_regime_filter_study(data_2024)
    
    # Study 3: Timeframes
    all_results['TIMEFRAMES'] = run_timeframe_study(data_2024)
    
    # Study 4: Risk Per Trade
    all_results['RISK_LEVELS'] = run_risk_study(data_2024)
    
    # Find best session and regime for combined study
    session_results = [r for r in all_results['SESSION_FILTERS'] if r.get('success')]
    regime_results = [r for r in all_results['REGIME_FILTERS'] if r.get('success')]
    
    best_session = max(session_results, key=lambda x: x.get('pf', 0)) if session_results else None
    best_regime = max(regime_results, key=lambda x: x.get('pf', 0)) if regime_results else None
    
    # Study 5: Combined Filters
    if best_session:
        top_session_config = next(
            (s for s in SESSION_CONFIGS if s['name'] in best_session['test_name']),
            SESSION_CONFIGS[0]
        )
        top_regime_config = next(
            (r for r in REGIME_CONFIGS if r['name'] in best_regime['test_name']),
            REGIME_CONFIGS[0]
        ) if best_regime else REGIME_CONFIGS[0]
        
        all_results['COMBINED'] = run_combined_study(data_2024, top_session_config, top_regime_config)
    
    # Study 6: Grid Search
    all_results['GRID_SEARCH'] = run_full_grid_search(data_2024)
    
    # Generate report
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    report_path = OUTPUT_DIR / f"EXHAUSTIVE_FILTER_STUDY_{timestamp}.md"
    generate_report(all_results, report_path)
    
    # Save raw results
    json_path = OUTPUT_DIR / f"filter_study_results_{timestamp}.json"
    with open(json_path, 'w') as f:
        json.dump(all_results, f, indent=2, default=str)
    print(f"[+] JSON saved: {json_path}")
    
    # Print summary
    print("\n" + "="*70)
    print("  STUDY COMPLETE - TOP RESULTS")
    print("="*70)
    
    all_valid = []
    for results in all_results.values():
        all_valid.extend([r for r in results if r.get('success', False) and r.get('trades', 0) > 30])
    
    if all_valid:
        top5 = sorted(all_valid, key=lambda x: x.get('pf', 0), reverse=True)[:5]
        
        print("\n  TOP 5 CONFIGURATIONS BY PROFIT FACTOR:\n")
        print(f"  {'Rank':<5} {'Configuration':<45} {'PF':>6} {'Return':>8} {'DD':>6} {'Trades':>7}")
        print(f"  {'-'*5} {'-'*45} {'-'*6} {'-'*8} {'-'*6} {'-'*7}")
        
        for i, r in enumerate(top5, 1):
            print(f"  {i:<5} {r['test_name']:<45} {r['pf']:>6.2f} {r['return']*100:>7.1f}% {r['dd']*100:>5.1f}% {r['trades']:>7}")
    
    print("\n" + "="*70)
    

if __name__ == "__main__":
    main()
