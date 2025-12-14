#!/usr/bin/env python3
"""
WFA Filter Study - Walk-Forward Analysis for All Filter Combinations
=====================================================================
Tests each filter combination with proper Walk-Forward validation.

This is the GOLD STANDARD test for detecting overfitting.

Configurations tested (32 combinations):
- All 2^5 combinations of: REGIME, SESSION, MTF, CONFLUENCE, FOOTPRINT

Output:
- WFE (Walk-Forward Efficiency) for each combination
- Ranking by WFE (higher = less overfitting)
- GO/NO-GO recommendation

Author: ORACLE + FORGE
Date: 2025-12-02
"""

import numpy as np
import pandas as pd
from dataclasses import dataclass, field
from typing import List, Dict, Optional, Tuple
from datetime import datetime
from itertools import product
import warnings
import sys
import pathlib

warnings.filterwarnings('ignore')

ROOT = pathlib.Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

# Import from ablation study
from scripts.backtest.ablation_study import (
    AblationConfig, SMCAblationBacktester, 
    resample_to_ohlc, add_indicators,
    HAVE_FOOTPRINT, load_parquet_ticks
)

if HAVE_FOOTPRINT:
    from scripts.backtest.footprint_analyzer import FootprintConfig, load_and_analyze_ticks


@dataclass
class WFAWindowResult:
    """Result for a single WFA window"""
    window_id: int
    is_start: str
    is_end: str
    oos_start: str
    oos_end: str
    is_sharpe: float
    oos_sharpe: float
    is_return: float
    oos_return: float
    is_trades: int
    oos_trades: int
    efficiency: float


@dataclass
class FilterWFAResult:
    """WFA result for a filter configuration"""
    config_name: str
    filters: Dict[str, bool]
    wfe: float
    mean_is_sharpe: float
    mean_oos_sharpe: float
    oos_positive_pct: float
    total_trades: int
    windows: List[WFAWindowResult]
    status: str  # APPROVED, MARGINAL, REJECTED


def run_backtest_on_window(
    ltf_bars: pd.DataFrame,
    htf_bars: pd.DataFrame,
    fp_df: Optional[pd.DataFrame],
    config: AblationConfig,
    start_idx: int,
    end_idx: int
) -> Dict:
    """Run backtest on a specific window of data"""
    
    # Slice data to window
    window_ltf = ltf_bars.iloc[start_idx:end_idx].copy()
    window_htf = htf_bars[htf_bars.index <= window_ltf.index[-1]].copy()
    
    if len(window_ltf) < 50:
        return {'error': 'Insufficient data', 'trades': 0}
    
    # Slice footprint if available
    window_fp = None
    if fp_df is not None and config.use_footprint_filter:
        window_fp = fp_df[fp_df.index.isin(window_ltf.index)].copy()
    
    # Run backtest
    bt = SMCAblationBacktester(config)
    result = bt.run(window_ltf, window_htf, window_fp)
    
    return result


def run_wfa_for_config(
    ltf_bars: pd.DataFrame,
    htf_bars: pd.DataFrame,
    fp_df: Optional[pd.DataFrame],
    config_dict: Dict,
    n_windows: int = 5,
    is_ratio: float = 0.7
) -> FilterWFAResult:
    """
    Run Walk-Forward Analysis for a single filter configuration.
    
    Args:
        ltf_bars: M5 OHLCV data with indicators
        htf_bars: H1 OHLCV data with indicators
        fp_df: Footprint data (optional)
        config_dict: Filter configuration
        n_windows: Number of WFA windows
        is_ratio: In-sample ratio (0.7 = 70% train, 30% test)
    
    Returns:
        FilterWFAResult with WFE and window details
    """
    
    n = len(ltf_bars)
    
    # Calculate window sizes
    # Rolling WFA: windows slide by OOS size
    total_oos = int(n * (1 - is_ratio))
    oos_size = total_oos // n_windows
    is_size = int(oos_size * is_ratio / (1 - is_ratio))
    
    # Minimum sizes
    min_window = 100
    if oos_size < min_window:
        oos_size = min_window
        is_size = int(oos_size * is_ratio / (1 - is_ratio))
    
    # Build config
    config = AblationConfig(
        use_regime_filter=config_dict.get('use_regime_filter', False),
        use_session_filter=config_dict.get('use_session_filter', False),
        use_mtf_filter=config_dict.get('use_mtf_filter', False),
        use_confluence_filter=config_dict.get('use_confluence_filter', False),
        use_footprint_filter=config_dict.get('use_footprint_filter', False),
    )
    
    windows = []
    
    for i in range(n_windows):
        # Rolling window positions
        window_start = i * oos_size
        is_start = window_start
        is_end = is_start + is_size
        oos_start = is_end
        oos_end = oos_start + oos_size
        
        if oos_end > n:
            break
        
        # Run IS backtest
        is_result = run_backtest_on_window(
            ltf_bars, htf_bars, fp_df, config, is_start, is_end
        )
        
        # Run OOS backtest
        oos_result = run_backtest_on_window(
            ltf_bars, htf_bars, fp_df, config, oos_start, oos_end
        )
        
        if 'error' in is_result or 'error' in oos_result:
            continue
        
        is_sharpe = is_result.get('sharpe_ratio', 0)
        oos_sharpe = oos_result.get('sharpe_ratio', 0)
        is_return = is_result.get('total_return', 0)
        oos_return = oos_result.get('total_return', 0)
        
        # Efficiency: how much IS performance retained OOS
        if is_return != 0:
            efficiency = oos_return / is_return
        else:
            efficiency = 0 if oos_return == 0 else 1
        
        window = WFAWindowResult(
            window_id=i + 1,
            is_start=str(ltf_bars.index[is_start]),
            is_end=str(ltf_bars.index[is_end-1]),
            oos_start=str(ltf_bars.index[oos_start]),
            oos_end=str(ltf_bars.index[min(oos_end-1, n-1)]),
            is_sharpe=is_sharpe,
            oos_sharpe=oos_sharpe,
            is_return=is_return,
            oos_return=oos_return,
            is_trades=is_result.get('total_trades', 0),
            oos_trades=oos_result.get('total_trades', 0),
            efficiency=efficiency
        )
        windows.append(window)
    
    if not windows:
        return FilterWFAResult(
            config_name=config_dict['name'],
            filters={k: v for k, v in config_dict.items() if k.startswith('use_')},
            wfe=0,
            mean_is_sharpe=0,
            mean_oos_sharpe=0,
            oos_positive_pct=0,
            total_trades=0,
            windows=[],
            status='NO_DATA'
        )
    
    # Calculate aggregate WFE
    is_returns = [w.is_return for w in windows]
    oos_returns = [w.oos_return for w in windows]
    
    mean_is = np.mean(is_returns) if is_returns else 0
    mean_oos = np.mean(oos_returns) if oos_returns else 0
    
    # WFE = Mean OOS / Mean IS (capped at reasonable range)
    if mean_is != 0:
        wfe = mean_oos / mean_is
        wfe = np.clip(wfe, -2, 2)  # Cap extreme values
    else:
        wfe = 0 if mean_oos == 0 else 1
    
    # Sharpe averages
    is_sharpes = [w.is_sharpe for w in windows]
    oos_sharpes = [w.oos_sharpe for w in windows]
    mean_is_sharpe = np.mean(is_sharpes)
    mean_oos_sharpe = np.mean(oos_sharpes)
    
    # Consistency
    oos_positive = sum(1 for r in oos_returns if r > 0)
    oos_positive_pct = oos_positive / len(windows) * 100 if windows else 0
    
    total_trades = sum(w.is_trades + w.oos_trades for w in windows)
    
    # Status determination
    if wfe >= 0.6:
        status = 'APPROVED'
    elif wfe >= 0.4:
        status = 'MARGINAL'
    elif wfe >= 0.2:
        status = 'SUSPECT'
    else:
        status = 'REJECTED'
    
    return FilterWFAResult(
        config_name=config_dict['name'],
        filters={k: v for k, v in config_dict.items() if k.startswith('use_')},
        wfe=wfe,
        mean_is_sharpe=mean_is_sharpe,
        mean_oos_sharpe=mean_oos_sharpe,
        oos_positive_pct=oos_positive_pct,
        total_trades=total_trades,
        windows=windows,
        status=status
    )


def generate_all_filter_combinations() -> List[Dict]:
    """Generate all 32 combinations of 5 filters"""
    
    filter_names = ['regime', 'session', 'mtf', 'confluence', 'footprint']
    combinations = []
    
    for bits in product([False, True], repeat=5):
        config = {
            'use_regime_filter': bits[0],
            'use_session_filter': bits[1],
            'use_mtf_filter': bits[2],
            'use_confluence_filter': bits[3],
            'use_footprint_filter': bits[4],
        }
        
        # Generate name
        active = [f.upper()[:3] for f, b in zip(filter_names, bits) if b]
        if not active:
            name = 'BASELINE'
        else:
            name = '+'.join(active)
        
        config['name'] = name
        combinations.append(config)
    
    return combinations


def generate_key_combinations() -> List[Dict]:
    """Generate key filter combinations (reduced set for faster testing)"""
    
    return [
        {'name': 'BASELINE', 'use_regime_filter': False, 'use_session_filter': False, 
         'use_mtf_filter': False, 'use_confluence_filter': False, 'use_footprint_filter': False},
        
        {'name': '+REGIME', 'use_regime_filter': True, 'use_session_filter': False,
         'use_mtf_filter': False, 'use_confluence_filter': False, 'use_footprint_filter': False},
        
        {'name': '+SESSION', 'use_regime_filter': False, 'use_session_filter': True,
         'use_mtf_filter': False, 'use_confluence_filter': False, 'use_footprint_filter': False},
        
        {'name': '+MTF', 'use_regime_filter': False, 'use_session_filter': False,
         'use_mtf_filter': True, 'use_confluence_filter': False, 'use_footprint_filter': False},
        
        {'name': '+CONFLUENCE', 'use_regime_filter': False, 'use_session_filter': False,
         'use_mtf_filter': False, 'use_confluence_filter': True, 'use_footprint_filter': False},
        
        {'name': '+FOOTPRINT', 'use_regime_filter': False, 'use_session_filter': False,
         'use_mtf_filter': False, 'use_confluence_filter': False, 'use_footprint_filter': True},
        
        {'name': 'REG+MTF', 'use_regime_filter': True, 'use_session_filter': False,
         'use_mtf_filter': True, 'use_confluence_filter': False, 'use_footprint_filter': False},
        
        {'name': 'REG+MTF+CONF', 'use_regime_filter': True, 'use_session_filter': False,
         'use_mtf_filter': True, 'use_confluence_filter': True, 'use_footprint_filter': False},
        
        {'name': 'REG+MTF+FP', 'use_regime_filter': True, 'use_session_filter': False,
         'use_mtf_filter': True, 'use_confluence_filter': False, 'use_footprint_filter': True},
        
        {'name': 'ALL_NO_FP', 'use_regime_filter': True, 'use_session_filter': True,
         'use_mtf_filter': True, 'use_confluence_filter': True, 'use_footprint_filter': False},
        
        {'name': 'ALL_FILTERS', 'use_regime_filter': True, 'use_session_filter': True,
         'use_mtf_filter': True, 'use_confluence_filter': True, 'use_footprint_filter': True},
    ]


def run_wfa_study(
    data_path: str,
    output_path: str,
    n_windows: int = 5,
    max_ticks: Optional[int] = None,
    full_combinations: bool = False
):
    """
    Run complete WFA study across filter combinations.
    """
    
    print("=" * 80)
    print("           WFA FILTER STUDY - WALK-FORWARD VALIDATION")
    print("=" * 80)
    
    # Load data
    print(f"\n[1/5] Loading tick data from {data_path}...")
    ticks = load_parquet_ticks(data_path, max_rows=max_ticks)
    
    print(f"  Loaded {len(ticks):,} ticks")
    print(f"  Period: {ticks.index[0]} to {ticks.index[-1]}")
    
    # Resample
    print("\n[2/5] Resampling to M5 and H1 bars...")
    ltf_bars = resample_to_ohlc(ticks, '5min')
    htf_bars = resample_to_ohlc(ticks, '1h')
    print(f"  M5 bars: {len(ltf_bars):,}")
    print(f"  H1 bars: {len(htf_bars):,}")
    
    # Add indicators
    print("\n[3/5] Calculating indicators...")
    ltf_bars = add_indicators(ltf_bars, AblationConfig())
    htf_bars = add_indicators(htf_bars, AblationConfig())
    
    # Generate footprint
    fp_df = None
    if HAVE_FOOTPRINT:
        print("\n[3.5/5] Generating footprint metrics...")
        try:
            fp_config = FootprintConfig(tick_size=0.01, bar_period='5min')
            _, fp_df = load_and_analyze_ticks(data_path, fp_config, max_ticks=max_ticks)
            print(f"  Footprint bars: {len(fp_df):,}")
        except Exception as e:
            print(f"  [Warning] Footprint failed: {e}")
    
    # Get filter combinations
    if full_combinations:
        configs = generate_all_filter_combinations()
        print(f"\n[4/5] Running WFA for ALL {len(configs)} filter combinations...")
    else:
        configs = generate_key_combinations()
        print(f"\n[4/5] Running WFA for {len(configs)} key filter combinations...")
    
    print(f"  Windows: {n_windows} | IS Ratio: 70% | OOS Ratio: 30%")
    
    results = []
    
    for i, config_dict in enumerate(configs):
        print(f"\n  [{i+1}/{len(configs)}] Testing {config_dict['name']}...")
        
        result = run_wfa_for_config(
            ltf_bars, htf_bars, fp_df, config_dict,
            n_windows=n_windows
        )
        
        results.append(result)
        
        print(f"      WFE: {result.wfe:.2f} | Status: {result.status} | "
              f"OOS+: {result.oos_positive_pct:.0f}% | Trades: {result.total_trades}")
    
    # Sort by WFE
    results.sort(key=lambda x: x.wfe, reverse=True)
    
    # Print summary
    print("\n" + "=" * 100)
    print("                              WFA FILTER STUDY RESULTS")
    print("=" * 100)
    print(f"{'Config':<20} {'WFE':>8} {'Status':<10} {'IS Sharpe':>10} {'OOS Sharpe':>10} {'OOS+%':>8} {'Trades':>8}")
    print("-" * 100)
    
    for r in results:
        print(f"{r.config_name:<20} {r.wfe:>8.2f} {r.status:<10} "
              f"{r.mean_is_sharpe:>10.2f} {r.mean_oos_sharpe:>10.2f} "
              f"{r.oos_positive_pct:>7.0f}% {r.total_trades:>8}")
    
    print("=" * 100)
    
    # Analysis
    print("\n[5/5] ANALYSIS & RECOMMENDATIONS:")
    
    approved = [r for r in results if r.status == 'APPROVED']
    marginal = [r for r in results if r.status == 'MARGINAL']
    rejected = [r for r in results if r.status in ('SUSPECT', 'REJECTED')]
    
    print(f"\n  APPROVED (WFE >= 0.6):  {len(approved)} configs")
    for r in approved[:5]:
        print(f"    - {r.config_name}: WFE={r.wfe:.2f}")
    
    print(f"\n  MARGINAL (0.4 <= WFE < 0.6): {len(marginal)} configs")
    for r in marginal[:3]:
        print(f"    - {r.config_name}: WFE={r.wfe:.2f}")
    
    print(f"\n  REJECTED (WFE < 0.4): {len(rejected)} configs")
    for r in rejected[:3]:
        print(f"    - {r.config_name}: WFE={r.wfe:.2f}")
    
    # Footprint analysis
    fp_results = [r for r in results if r.filters.get('use_footprint_filter', False)]
    no_fp_results = [r for r in results if not r.filters.get('use_footprint_filter', False)]
    
    if fp_results and no_fp_results:
        avg_wfe_with_fp = np.mean([r.wfe for r in fp_results])
        avg_wfe_no_fp = np.mean([r.wfe for r in no_fp_results])
        
        print(f"\n  FOOTPRINT IMPACT:")
        print(f"    Avg WFE WITH footprint:    {avg_wfe_with_fp:.2f}")
        print(f"    Avg WFE WITHOUT footprint: {avg_wfe_no_fp:.2f}")
        
        if avg_wfe_with_fp > avg_wfe_no_fp:
            print(f"    [OK] Footprint IMPROVES WFE by {(avg_wfe_with_fp/avg_wfe_no_fp - 1)*100:.1f}%")
        else:
            print(f"    [WARN] Footprint DEGRADES WFE by {(1 - avg_wfe_with_fp/avg_wfe_no_fp)*100:.1f}%")
    
    # Best config
    if results:
        best = results[0]
        print(f"\n  BEST CONFIGURATION: {best.config_name}")
        print(f"    WFE: {best.wfe:.2f}")
        print(f"    OOS Positive: {best.oos_positive_pct:.0f}%")
        print(f"    Status: {best.status}")
    
    # Generate report
    report = generate_wfa_report(results, n_windows)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(report)
    
    print(f"\n  Report saved to: {output_path}")
    print("\n" + "=" * 80)
    print("                    WFA FILTER STUDY COMPLETE")
    print("=" * 80)
    
    return results


def generate_wfa_report(results: List[FilterWFAResult], n_windows: int) -> str:
    """Generate markdown report"""
    
    now = datetime.now().strftime("%Y-%m-%d %H:%M")
    
    report = f"""# WFA Filter Study - Walk-Forward Validation

**Generated:** {now}  
**Windows:** {n_windows} | **IS Ratio:** 70% | **OOS Ratio:** 30%

---

## Executive Summary

Walk-Forward Analysis (WFA) tests if strategy performance generalizes to unseen data.
**WFE >= 0.6** means strategy retains 60%+ of in-sample performance out-of-sample.

## Results Table

| Rank | Config | WFE | Status | IS Sharpe | OOS Sharpe | OOS+% | Trades |
|------|--------|-----|--------|-----------|------------|-------|--------|
"""
    
    for i, r in enumerate(results, 1):
        status_icon = "✓" if r.status == 'APPROVED' else "⚠" if r.status == 'MARGINAL' else "✗"
        report += f"| {i} | {r.config_name} | {r.wfe:.2f} | {status_icon} {r.status} | "
        report += f"{r.mean_is_sharpe:.2f} | {r.mean_oos_sharpe:.2f} | {r.oos_positive_pct:.0f}% | {r.total_trades} |\n"
    
    # Footprint analysis
    fp_results = [r for r in results if r.filters.get('use_footprint_filter', False)]
    no_fp_results = [r for r in results if not r.filters.get('use_footprint_filter', False)]
    
    if fp_results and no_fp_results:
        avg_wfe_with_fp = np.mean([r.wfe for r in fp_results])
        avg_wfe_no_fp = np.mean([r.wfe for r in no_fp_results])
        
        report += f"""
## Footprint Impact Analysis

| Metric | WITH Footprint | WITHOUT Footprint | Delta |
|--------|----------------|-------------------|-------|
| Avg WFE | {avg_wfe_with_fp:.2f} | {avg_wfe_no_fp:.2f} | {avg_wfe_with_fp - avg_wfe_no_fp:+.2f} |

"""
        if avg_wfe_with_fp > avg_wfe_no_fp:
            report += f"**Verdict:** Footprint IMPROVES generalization by {(avg_wfe_with_fp/avg_wfe_no_fp - 1)*100:.1f}%\n"
        else:
            report += f"**Verdict:** Footprint DEGRADES generalization by {(1 - avg_wfe_with_fp/avg_wfe_no_fp)*100:.1f}%\n"
    
    # Recommendations
    approved = [r for r in results if r.status == 'APPROVED']
    
    report += """
## Recommendations

"""
    
    if approved:
        report += f"### Approved Configurations ({len(approved)})\n\n"
        for r in approved[:5]:
            active = [k.replace('use_', '').replace('_filter', '').upper() 
                     for k, v in r.filters.items() if v]
            filters_str = ', '.join(active) if active else 'None (baseline)'
            report += f"- **{r.config_name}** (WFE={r.wfe:.2f}): Filters: {filters_str}\n"
    else:
        report += "**WARNING:** No configurations achieved WFE >= 0.6. Strategy may be overfitted.\n"
    
    if results:
        best = results[0]
        report += f"""
### Best Configuration

**{best.config_name}** with WFE = {best.wfe:.2f}

This configuration shows the best generalization from in-sample to out-of-sample data.
"""
    
    report += """
---

## Methodology

- **Walk-Forward Analysis (WFA)**: Rolling windows with 70% train / 30% test
- **WFE Calculation**: Mean OOS Return / Mean IS Return
- **Status Thresholds**:
  - APPROVED: WFE >= 0.6 (retains 60%+ performance)
  - MARGINAL: 0.4 <= WFE < 0.6
  - SUSPECT: 0.2 <= WFE < 0.4
  - REJECTED: WFE < 0.2 (severe overfitting)

---
*Generated by ORACLE v2.2 - Walk-Forward Validation*
"""
    
    return report


def main():
    data_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/data/processed/ticks_2024.parquet"
    output_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/DOCS/04_REPORTS/VALIDATION/WFA_FILTER_STUDY.md"
    n_windows = 5
    max_ticks = None
    full = False
    
    args = sys.argv[1:]
    for i, a in enumerate(args):
        if a == '--full':
            full = True
        elif a == '--windows' and i + 1 < len(args):
            n_windows = int(args[i + 1])
        elif a == '--max' and i + 1 < len(args):
            max_ticks = int(args[i + 1])
        elif not a.startswith('--') and i == 0:
            data_path = a
    
    run_wfa_study(data_path, output_path, n_windows, max_ticks, full)


if __name__ == "__main__":
    main()
