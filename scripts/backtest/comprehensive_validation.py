#!/usr/bin/env python3
"""
Comprehensive Validation Suite
==============================
Complete validation pipeline for EA_SCALPER_XAUUSD:
1. Backtest with specified filter config
2. Monte Carlo simulation (5000 runs)
3. Cross-year validation (train 2023, test 2024)
4. Final GO/NO-GO recommendation

Author: ORACLE + FORGE
Date: 2025-12-02
"""

import numpy as np
import pandas as pd
from dataclasses import dataclass
from typing import Dict, List, Optional, Tuple
from datetime import datetime
import sys
import pathlib
import warnings
import tempfile
import os

warnings.filterwarnings('ignore')

ROOT = pathlib.Path(__file__).resolve().parents[2]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from scripts.backtest.ablation_study import (
    AblationConfig, SMCAblationBacktester,
    resample_to_ohlc, add_indicators, load_parquet_ticks
)
from scripts.oracle.monte_carlo import BlockBootstrapMC


@dataclass
class ValidationResult:
    """Complete validation result"""
    config_name: str
    
    # Backtest metrics
    total_trades: int
    win_rate: float
    profit_factor: float
    sharpe_ratio: float
    max_drawdown: float
    total_return: float
    
    # Monte Carlo metrics
    mc_dd_95th: float
    mc_prob_profit: float
    mc_ftmo_violation_prob: float
    mc_confidence_score: int
    
    # Cross-year metrics (if available)
    cross_year_wfe: Optional[float]
    train_sharpe: Optional[float]
    test_sharpe: Optional[float]
    
    # Final verdict
    verdict: str
    recommendation: str


def run_backtest_config(
    ticks: pd.DataFrame,
    config_name: str,
    use_regime: bool = False,
    use_session: bool = False,
    use_mtf: bool = False,
    use_confluence: bool = False,
    use_footprint: bool = False
) -> Tuple[Dict, pd.DataFrame]:
    """Run backtest with specific config, return metrics and trades DataFrame"""
    
    # Resample to bars
    ltf_bars = resample_to_ohlc(ticks, '5min')
    htf_bars = resample_to_ohlc(ticks, '1h')
    
    # Add indicators
    config = AblationConfig(
        use_regime_filter=use_regime,
        use_session_filter=use_session,
        use_mtf_filter=use_mtf,
        use_confluence_filter=use_confluence,
        use_footprint_filter=use_footprint,
    )
    
    ltf_bars = add_indicators(ltf_bars, config)
    htf_bars = add_indicators(htf_bars, config)
    
    # Run backtest
    bt = SMCAblationBacktester(config)
    result = bt.run(ltf_bars, htf_bars, None)
    
    # Extract trades as DataFrame
    trades_data = []
    if hasattr(bt, 'trades') and bt.trades:
        for t in bt.trades:
            trades_data.append({
                'entry_time': t.get('entry_time', ''),
                'exit_time': t.get('exit_time', ''),
                'direction': t.get('direction', ''),
                'profit': t.get('pnl', 0),
                'entry_price': t.get('entry_price', 0),
                'exit_price': t.get('exit_price', 0),
            })
    
    trades_df = pd.DataFrame(trades_data) if trades_data else pd.DataFrame({'profit': []})
    
    return result, trades_df


def run_monte_carlo(trades_df: pd.DataFrame, n_simulations: int = 5000) -> Dict:
    """Run Monte Carlo simulation on trades"""
    
    if len(trades_df) < 20:
        return {
            'dd_95th': 0,
            'prob_profit': 0,
            'ftmo_violation_prob': 100,
            'confidence_score': 0,
            'error': 'Insufficient trades for Monte Carlo'
        }
    
    mc = BlockBootstrapMC(n_simulations=n_simulations)
    result = mc.run(trades_df, use_block=True)
    
    return {
        'dd_95th': result.dd_95th,
        'prob_profit': result.prob_profit,
        'ftmo_violation_prob': result.ftmo_total_violation_prob,
        'confidence_score': result.confidence_score,
        'var_95': result.var_95,
        'cvar_95': result.cvar_95,
        'verdict': result.ftmo_verdict
    }


def run_cross_year_validation(
    train_path: str,
    test_path: str,
    config_name: str,
    use_regime: bool,
    use_session: bool,
    use_mtf: bool,
    use_confluence: bool,
    use_footprint: bool,
    max_ticks: int = 10000000
) -> Dict:
    """Run cross-year validation: train on one year, test on another"""
    
    print(f"\n  Loading train data: {train_path}")
    try:
        train_ticks = load_parquet_ticks(train_path, max_rows=max_ticks)
    except Exception as e:
        return {'error': f'Failed to load train data: {e}'}
    
    print(f"  Loading test data: {test_path}")
    try:
        test_ticks = load_parquet_ticks(test_path, max_rows=max_ticks)
    except Exception as e:
        return {'error': f'Failed to load test data: {e}'}
    
    # Run backtest on train
    print(f"  Running backtest on train data...")
    train_result, _ = run_backtest_config(
        train_ticks, f"{config_name}_train",
        use_regime, use_session, use_mtf, use_confluence, use_footprint
    )
    
    # Run backtest on test
    print(f"  Running backtest on test data...")
    test_result, _ = run_backtest_config(
        test_ticks, f"{config_name}_test",
        use_regime, use_session, use_mtf, use_confluence, use_footprint
    )
    
    train_return = train_result.get('total_return', 0)
    test_return = test_result.get('total_return', 0)
    
    # Calculate WFE
    if train_return != 0:
        wfe = test_return / train_return
        wfe = np.clip(wfe, -2, 2)
    else:
        wfe = 0 if test_return == 0 else 1
    
    return {
        'train_trades': train_result.get('total_trades', 0),
        'test_trades': test_result.get('total_trades', 0),
        'train_sharpe': train_result.get('sharpe_ratio', 0),
        'test_sharpe': test_result.get('sharpe_ratio', 0),
        'train_return': train_return,
        'test_return': test_return,
        'wfe': wfe,
        'train_period': f"{train_ticks.index[0]} to {train_ticks.index[-1]}",
        'test_period': f"{test_ticks.index[0]} to {test_ticks.index[-1]}"
    }


def run_comprehensive_validation(
    data_path: str,
    output_path: str,
    config_name: str = "REG+MTF",
    use_regime: bool = True,
    use_session: bool = False,
    use_mtf: bool = True,
    use_confluence: bool = False,
    use_footprint: bool = False,
    max_ticks: int = 15000000,
    run_cross_year: bool = True
):
    """Run complete validation suite"""
    
    print("=" * 80)
    print("        COMPREHENSIVE VALIDATION SUITE")
    print("=" * 80)
    print(f"\nConfiguration: {config_name}")
    print(f"  REGIME: {use_regime}")
    print(f"  SESSION: {use_session}")
    print(f"  MTF: {use_mtf}")
    print(f"  CONFLUENCE: {use_confluence}")
    print(f"  FOOTPRINT: {use_footprint}")
    
    # Phase 1: Main Backtest
    print("\n" + "=" * 40)
    print("[PHASE 1] BACKTEST")
    print("=" * 40)
    
    print(f"\nLoading data from {data_path}...")
    ticks = load_parquet_ticks(data_path, max_rows=max_ticks)
    print(f"  Loaded {len(ticks):,} ticks")
    print(f"  Period: {ticks.index[0]} to {ticks.index[-1]}")
    
    print("\nRunning backtest...")
    bt_result, trades_df = run_backtest_config(
        ticks, config_name,
        use_regime, use_session, use_mtf, use_confluence, use_footprint
    )
    
    print(f"\n  Trades: {bt_result.get('total_trades', 0)}")
    print(f"  Win Rate: {bt_result.get('win_rate', 0)*100:.1f}%")
    print(f"  Profit Factor: {bt_result.get('profit_factor', 0):.2f}")
    print(f"  Sharpe: {bt_result.get('sharpe_ratio', 0):.2f}")
    # FIX BUG #1: Use max_drawdown_pct (percentage 0-1), not max_drawdown (absolute $)
    print(f"  Max DD: {bt_result.get('max_drawdown_pct', bt_result.get('max_drawdown', 0))*100:.2f}%")
    print(f"  Return: {bt_result.get('total_return', 0)*100:.2f}%")
    
    # Phase 2: Monte Carlo
    print("\n" + "=" * 40)
    print("[PHASE 2] MONTE CARLO (5000 simulations)")
    print("=" * 40)
    
    if len(trades_df) >= 20:
        mc_result = run_monte_carlo(trades_df, n_simulations=5000)
        
        print(f"\n  DD 95th percentile: {mc_result.get('dd_95th', 0):.1f}%")
        print(f"  P(Profit > 0): {mc_result.get('prob_profit', 0):.1f}%")
        print(f"  P(FTMO violation): {mc_result.get('ftmo_violation_prob', 0):.1f}%")
        print(f"  Confidence Score: {mc_result.get('confidence_score', 0)}/100")
        print(f"  FTMO Verdict: {mc_result.get('verdict', 'N/A')}")
    else:
        mc_result = {'error': 'Insufficient trades', 'dd_95th': 0, 'prob_profit': 0, 
                     'ftmo_violation_prob': 100, 'confidence_score': 0}
        print(f"\n  [SKIP] Not enough trades ({len(trades_df)}) for Monte Carlo")
    
    # Phase 3: Cross-Year Validation
    cross_year_result = None
    if run_cross_year:
        print("\n" + "=" * 40)
        print("[PHASE 3] CROSS-YEAR VALIDATION")
        print("=" * 40)
        
        # Determine paths
        base_dir = pathlib.Path(data_path).parent
        train_path = base_dir / "ticks_2023.parquet"
        test_path = base_dir / "ticks_2024.parquet"
        
        if train_path.exists() and test_path.exists():
            cross_year_result = run_cross_year_validation(
                str(train_path), str(test_path), config_name,
                use_regime, use_session, use_mtf, use_confluence, use_footprint,
                max_ticks=10000000
            )
            
            if 'error' not in cross_year_result:
                print(f"\n  Train Period: {cross_year_result['train_period']}")
                print(f"  Test Period: {cross_year_result['test_period']}")
                print(f"  Train Trades: {cross_year_result['train_trades']}")
                print(f"  Test Trades: {cross_year_result['test_trades']}")
                print(f"  Train Sharpe: {cross_year_result['train_sharpe']:.2f}")
                print(f"  Test Sharpe: {cross_year_result['test_sharpe']:.2f}")
                print(f"  WFE: {cross_year_result['wfe']:.2f}")
                
                if cross_year_result['wfe'] >= 0.6:
                    print(f"  Status: APPROVED (WFE >= 0.6)")
                elif cross_year_result['wfe'] >= 0.4:
                    print(f"  Status: MARGINAL")
                else:
                    print(f"  Status: REJECTED (WFE < 0.4)")
            else:
                print(f"\n  [ERROR] {cross_year_result['error']}")
        else:
            print(f"\n  [SKIP] Cross-year data not available")
            print(f"    Train: {train_path} exists={train_path.exists()}")
            print(f"    Test: {test_path} exists={test_path.exists()}")
    
    # Final Verdict
    print("\n" + "=" * 80)
    print("                    FINAL VERDICT")
    print("=" * 80)
    
    # Scoring
    score = 0
    max_score = 100
    breakdown = {}
    
    # Backtest score (40 points)
    bt_score = 0
    if bt_result.get('total_trades', 0) >= 50:
        bt_score += 10
    if bt_result.get('profit_factor', 0) >= 1.5:
        bt_score += 10
    if bt_result.get('sharpe_ratio', 0) > 0:
        bt_score += 10
    # FIX BUG #1: Use max_drawdown_pct (percentage 0-1), not max_drawdown (absolute $)
    max_dd_pct = bt_result.get('max_drawdown_pct', bt_result.get('max_drawdown', 1))
    if max_dd_pct < 0.10:
        bt_score += 10
    breakdown['backtest'] = bt_score
    score += bt_score
    
    # Monte Carlo score (30 points)
    mc_score = 0
    if 'error' not in mc_result:
        if mc_result.get('dd_95th', 100) < 15:
            mc_score += 10
        if mc_result.get('prob_profit', 0) > 60:
            mc_score += 10
        if mc_result.get('ftmo_violation_prob', 100) < 20:
            mc_score += 10
    breakdown['monte_carlo'] = mc_score
    score += mc_score
    
    # Cross-year score (30 points)
    cy_score = 0
    if cross_year_result and 'error' not in cross_year_result:
        wfe = cross_year_result.get('wfe', 0)
        if wfe >= 0.6:
            cy_score = 30
        elif wfe >= 0.4:
            cy_score = 20
        elif wfe >= 0.2:
            cy_score = 10
    breakdown['cross_year'] = cy_score
    score += cy_score
    
    print(f"\nConfiguration: {config_name}")
    print(f"\nScore Breakdown:")
    print(f"  Backtest:    {breakdown['backtest']}/40")
    print(f"  Monte Carlo: {breakdown['monte_carlo']}/30")
    print(f"  Cross-Year:  {breakdown['cross_year']}/30")
    print(f"  TOTAL:       {score}/100")
    
    # Verdict
    if score >= 80:
        verdict = "GO - Ready for live trading"
        emoji = "[OK]"
    elif score >= 60:
        verdict = "CONDITIONAL GO - Monitor closely"
        emoji = "[WARN]"
    elif score >= 40:
        verdict = "NO-GO - Needs optimization"
        emoji = "[FAIL]"
    else:
        verdict = "REJECT - Strategy not viable"
        emoji = "[FAIL]"
    
    print(f"\n{emoji} VERDICT: {verdict}")
    
    # Generate report
    report = generate_validation_report(
        config_name, bt_result, mc_result, cross_year_result, score, breakdown, verdict
    )
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(report)
    
    print(f"\nReport saved to: {output_path}")
    print("\n" + "=" * 80)
    
    return {
        'config': config_name,
        'score': score,
        'verdict': verdict,
        'backtest': bt_result,
        'monte_carlo': mc_result,
        'cross_year': cross_year_result
    }


def generate_validation_report(
    config_name: str,
    bt_result: Dict,
    mc_result: Dict,
    cross_year_result: Optional[Dict],
    score: int,
    breakdown: Dict,
    verdict: str
) -> str:
    """Generate markdown validation report"""
    
    now = datetime.now().strftime("%Y-%m-%d %H:%M")
    
    report = f"""# Comprehensive Validation Report

**Configuration:** {config_name}  
**Generated:** {now}  
**Total Score:** {score}/100  
**Verdict:** {verdict}

---

## Score Breakdown

| Component | Score | Max | Status |
|-----------|-------|-----|--------|
| Backtest | {breakdown['backtest']} | 40 | {"PASS" if breakdown['backtest'] >= 30 else "FAIL"} |
| Monte Carlo | {breakdown['monte_carlo']} | 30 | {"PASS" if breakdown['monte_carlo'] >= 20 else "FAIL"} |
| Cross-Year | {breakdown['cross_year']} | 30 | {"PASS" if breakdown['cross_year'] >= 20 else "FAIL"} |
| **TOTAL** | **{score}** | **100** | **{verdict.split(' - ')[0]}** |

---

## Phase 1: Backtest Results

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Trades | {bt_result.get('total_trades', 0)} | >= 50 | {"PASS" if bt_result.get('total_trades', 0) >= 50 else "FAIL"} |
| Win Rate | {bt_result.get('win_rate', 0)*100:.1f}% | >= 40% | {"PASS" if bt_result.get('win_rate', 0) >= 0.4 else "FAIL"} |
| Profit Factor | {bt_result.get('profit_factor', 0):.2f} | >= 1.5 | {"PASS" if bt_result.get('profit_factor', 0) >= 1.5 else "FAIL"} |
| Sharpe Ratio | {bt_result.get('sharpe_ratio', 0):.2f} | > 0 | {"PASS" if bt_result.get('sharpe_ratio', 0) > 0 else "FAIL"} |
| Max Drawdown | {bt_result.get('max_drawdown_pct', bt_result.get('max_drawdown', 0))*100:.2f}% | < 10% | {"PASS" if bt_result.get('max_drawdown_pct', bt_result.get('max_drawdown', 1)) < 0.10 else "FAIL"} |
| Total Return | {bt_result.get('total_return', 0)*100:.2f}% | > 0% | {"PASS" if bt_result.get('total_return', 0) > 0 else "FAIL"} |

---

## Phase 2: Monte Carlo Results (5000 simulations)

"""
    
    if 'error' not in mc_result:
        report += f"""| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| DD 95th Percentile | {mc_result.get('dd_95th', 0):.1f}% | < 15% | {"PASS" if mc_result.get('dd_95th', 100) < 15 else "FAIL"} |
| P(Profit > 0) | {mc_result.get('prob_profit', 0):.1f}% | > 60% | {"PASS" if mc_result.get('prob_profit', 0) > 60 else "FAIL"} |
| P(FTMO Violation) | {mc_result.get('ftmo_violation_prob', 0):.1f}% | < 20% | {"PASS" if mc_result.get('ftmo_violation_prob', 100) < 20 else "FAIL"} |
| Confidence Score | {mc_result.get('confidence_score', 0)}/100 | >= 60 | {"PASS" if mc_result.get('confidence_score', 0) >= 60 else "FAIL"} |
| VaR 95% | {mc_result.get('var_95', 0):.1f}% | < 10% | {"PASS" if mc_result.get('var_95', 100) < 10 else "FAIL"} |
| CVaR 95% | {mc_result.get('cvar_95', 0):.1f}% | < 12% | {"PASS" if mc_result.get('cvar_95', 100) < 12 else "FAIL"} |

"""
    else:
        report += f"**Error:** {mc_result.get('error', 'Unknown')}\n\n"
    
    report += "---\n\n## Phase 3: Cross-Year Validation\n\n"
    
    if cross_year_result and 'error' not in cross_year_result:
        wfe = cross_year_result.get('wfe', 0)
        wfe_status = "APPROVED" if wfe >= 0.6 else "MARGINAL" if wfe >= 0.4 else "REJECTED"
        
        report += f"""| Metric | Train (2023) | Test (2024) | WFE |
|--------|--------------|-------------|-----|
| Trades | {cross_year_result.get('train_trades', 0)} | {cross_year_result.get('test_trades', 0)} | - |
| Sharpe | {cross_year_result.get('train_sharpe', 0):.2f} | {cross_year_result.get('test_sharpe', 0):.2f} | - |
| Return | {cross_year_result.get('train_return', 0)*100:.2f}% | {cross_year_result.get('test_return', 0)*100:.2f}% | **{wfe:.2f}** |

**WFE Status:** {wfe_status} (threshold: >= 0.6 for approval)

"""
    else:
        error = cross_year_result.get('error', 'Data not available') if cross_year_result else 'Not run'
        report += f"**Status:** {error}\n\n"
    
    report += f"""---

## Final Recommendation

**Verdict:** {verdict}

"""
    
    if score >= 80:
        report += """The strategy passes all validation phases and is ready for live trading.

**Next Steps:**
1. Deploy to demo account for 2-4 weeks
2. Monitor FTMO compliance metrics daily
3. Proceed to challenge when demo confirms results
"""
    elif score >= 60:
        report += """The strategy shows promise but needs monitoring.

**Next Steps:**
1. Extended demo testing (4-8 weeks)
2. Fine-tune filter parameters
3. Re-run validation after adjustments
"""
    else:
        report += """The strategy does not meet validation criteria.

**Next Steps:**
1. Review filter logic
2. Consider different configuration
3. Collect more data for analysis
"""
    
    report += """
---
*Generated by ORACLE v2.2 - Comprehensive Validation Suite*
"""
    
    return report


def main():
    data_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/data/processed/ticks_2024.parquet"
    output_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/DOCS/04_REPORTS/VALIDATION/COMPREHENSIVE_VALIDATION.md"
    
    # Default: REG+MTF (best WFA config)
    config = {
        'name': 'REG+MTF',
        'regime': True,
        'session': False,
        'mtf': True,
        'confluence': False,
        'footprint': False
    }
    
    max_ticks = 15000000
    run_cy = True
    
    # Parse args
    args = sys.argv[1:]
    for i, a in enumerate(args):
        if a == '--config' and i + 1 < len(args):
            cfg_name = args[i + 1].upper()
            if cfg_name == 'BASELINE':
                config = {'name': 'BASELINE', 'regime': False, 'session': False, 
                         'mtf': False, 'confluence': False, 'footprint': False}
            elif cfg_name == 'REG+MTF':
                config = {'name': 'REG+MTF', 'regime': True, 'session': False,
                         'mtf': True, 'confluence': False, 'footprint': False}
            elif cfg_name == 'ALL_NO_FP':
                config = {'name': 'ALL_NO_FP', 'regime': True, 'session': True,
                         'mtf': True, 'confluence': True, 'footprint': False}
            elif cfg_name == 'ALL_FILTERS':
                config = {'name': 'ALL_FILTERS', 'regime': True, 'session': True,
                         'mtf': True, 'confluence': True, 'footprint': True}
        elif a == '--max' and i + 1 < len(args):
            max_ticks = int(args[i + 1])
        elif a == '--no-cross-year':
            run_cy = False
        elif not a.startswith('--') and i == 0:
            data_path = a
    
    run_comprehensive_validation(
        data_path, output_path,
        config_name=config['name'],
        use_regime=config['regime'],
        use_session=config['session'],
        use_mtf=config['mtf'],
        use_confluence=config['confluence'],
        use_footprint=config['footprint'],
        max_ticks=max_ticks,
        run_cross_year=run_cy
    )


if __name__ == "__main__":
    main()
