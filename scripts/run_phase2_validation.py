#!/usr/bin/env python3
"""
run_phase2_validation.py - Execute Phase 2 validation pipeline
===============================================================
Runs tick backtester with EA logic across multiple segments and
collects GENIUS metrics (Kelly, Convexity, WFE).

Author: FORGE + ORACLE
Date: 2025-12-02
"""

import sys
import os
import json
from pathlib import Path
from datetime import datetime
from dataclasses import dataclass, asdict
from typing import Dict, List, Optional
import numpy as np
import pandas as pd

# Add project root to path
PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from scripts.backtest.tick_backtester import (
    TickBacktester, BacktestConfig, ExecutionMode
)

# Paths
DATA_DIR = PROJECT_ROOT / "data"
PROCESSED_DIR = DATA_DIR / "processed"
SEGMENTS_DIR = DATA_DIR / "segments"
OUTPUT_DIR = PROJECT_ROOT / "DOCS" / "04_REPORTS" / "BACKTESTS"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


@dataclass
class KellyMetrics:
    """Kelly criterion metrics for a segment"""
    segment: str
    n_trades: int
    win_rate: float
    avg_win: float
    avg_loss: float
    payoff_ratio: float
    kelly_full: float
    kelly_half: float
    kelly_quarter: float
    recommendation: str


@dataclass
class ConvexityMetrics:
    """Convexity metrics for P&L distribution"""
    asymmetry: float  # avg_win / avg_loss
    skewness: float
    tail_ratio: float  # 95th win / 5th loss
    gain_to_pain: float
    convexity_score: int  # 0-100


def calculate_kelly(trades: pd.DataFrame) -> KellyMetrics:
    """Calculate Kelly criterion metrics from trades"""
    if len(trades) < 30:
        return KellyMetrics(
            segment="", n_trades=len(trades), win_rate=0, avg_win=0, avg_loss=0,
            payoff_ratio=0, kelly_full=0, kelly_half=0, kelly_quarter=0,
            recommendation="INSUFFICIENT_DATA"
        )
    
    wins = trades[trades['profit'] > 0]
    losses = trades[trades['profit'] <= 0]
    
    if len(wins) == 0 or len(losses) == 0:
        return KellyMetrics(
            segment="", n_trades=len(trades), win_rate=len(wins)/len(trades) if len(trades) > 0 else 0,
            avg_win=0, avg_loss=0, payoff_ratio=0, kelly_full=0, kelly_half=0, kelly_quarter=0,
            recommendation="NO_EDGE"
        )
    
    p = len(wins) / len(trades)
    q = 1 - p
    avg_win = wins['profit'].mean()
    avg_loss = abs(losses['profit'].mean())
    b = avg_win / avg_loss if avg_loss > 0 else 0
    
    # Kelly calculation
    kelly_full = (p * b - q) / b if b > 0 else 0
    
    # Conservative corrections
    n = len(trades)
    kelly_corrected = kelly_full * (1 - 1/np.sqrt(n)) if n > 0 else 0
    
    # Recommendations
    if kelly_corrected <= 0:
        rec = "AVOID"
    elif n < 50:
        rec = "QUARTER_KELLY"
    elif n < 100:
        rec = "QUARTER_KELLY"
    elif n < 300:
        rec = "HALF_KELLY"
    else:
        rec = "HALF_KELLY"
    
    return KellyMetrics(
        segment="",
        n_trades=len(trades),
        win_rate=p,
        avg_win=avg_win,
        avg_loss=avg_loss,
        payoff_ratio=b,
        kelly_full=kelly_full,
        kelly_half=max(0, kelly_corrected / 2),
        kelly_quarter=max(0, kelly_corrected / 4),
        recommendation=rec
    )


def calculate_convexity(trades: pd.DataFrame) -> ConvexityMetrics:
    """Calculate convexity metrics from trades"""
    if len(trades) < 30:
        return ConvexityMetrics(
            asymmetry=0, skewness=0, tail_ratio=0, gain_to_pain=0, convexity_score=0
        )
    
    profits = trades['profit'].values
    wins = profits[profits > 0]
    losses = profits[profits < 0]
    
    if len(wins) == 0 or len(losses) == 0:
        return ConvexityMetrics(
            asymmetry=0, skewness=0, tail_ratio=0, gain_to_pain=0, convexity_score=0
        )
    
    from scipy import stats
    
    asymmetry = np.mean(wins) / abs(np.mean(losses)) if np.mean(losses) != 0 else 0
    skewness = stats.skew(profits)
    
    # Tail ratio: 95th percentile win vs 5th percentile loss
    if len(wins) >= 5 and len(losses) >= 5:
        tail_ratio = np.percentile(wins, 95) / abs(np.percentile(losses, 5))
    else:
        tail_ratio = asymmetry
    
    gain_to_pain = sum(wins) / abs(sum(losses)) if sum(losses) != 0 else 0
    
    # Convexity score (0-100)
    score = 0
    if asymmetry >= 1.5:
        score += 30
    elif asymmetry >= 1.2:
        score += 20
    elif asymmetry >= 1.0:
        score += 10
    
    if skewness > 0.5:
        score += 30
    elif skewness > 0:
        score += 15
    
    if tail_ratio >= 2.0:
        score += 20
    elif tail_ratio >= 1.5:
        score += 10
    
    if gain_to_pain >= 2.0:
        score += 20
    elif gain_to_pain >= 1.5:
        score += 10
    
    return ConvexityMetrics(
        asymmetry=asymmetry,
        skewness=skewness,
        tail_ratio=tail_ratio,
        gain_to_pain=gain_to_pain,
        convexity_score=min(100, score)
    )


def run_backtest_segment(segment_name: str, data_path: Path, config: BacktestConfig,
                         max_ticks: int = 2_000_000) -> Dict:
    """Run backtest on a specific segment"""
    print(f"\n{'='*60}")
    print(f"  Running backtest: {segment_name}")
    print(f"{'='*60}")
    
    try:
        bt = TickBacktester(config)
        results = bt.run(str(data_path), max_ticks=max_ticks)
        
        # Get trades (attribute is 'trades', not 'closed_trades')
        if hasattr(bt, 'trades') and bt.trades:
            trades_data = []
            for t in bt.trades:
                trades_data.append({
                    'entry_time': t.entry_time,
                    'exit_time': t.exit_time,
                    'direction': t.direction.value if hasattr(t.direction, 'value') else str(t.direction),
                    'entry_price': t.entry_price,
                    'exit_price': t.exit_price,
                    'profit': t.pnl,
                    'sl': t.sl,
                    'tp': t.tp,
                })
            trades_df = pd.DataFrame(trades_data)
        else:
            trades_df = pd.DataFrame()
        
        # Calculate GENIUS metrics
        kelly = calculate_kelly(trades_df) if len(trades_df) > 0 else None
        if kelly:
            kelly.segment = segment_name
        
        convexity = calculate_convexity(trades_df) if len(trades_df) > 0 else None
        
        return {
            'segment': segment_name,
            'data_path': str(data_path),
            'results': results,
            'trades': trades_df,
            'kelly': asdict(kelly) if kelly else None,
            'convexity': asdict(convexity) if convexity else None,
            'success': True
        }
    except Exception as e:
        print(f"  ERROR: {e}")
        import traceback
        traceback.print_exc()
        return {
            'segment': segment_name,
            'data_path': str(data_path),
            'error': str(e),
            'success': False
        }


def generate_report(results: List[Dict], output_path: Path):
    """Generate markdown report with all results"""
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write("# PHASE 2 VALIDATION REPORT - GENIUS METRICS\n\n")
        f.write(f"**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        f.write("---\n\n")
        
        # Summary table
        f.write("## Summary\n\n")
        f.write("| Segment | Trades | Win Rate | PF | Max DD | Return | Kelly | Convexity |\n")
        f.write("|---------|--------|----------|----|---------| ------|-------|----------|\n")
        
        for r in results:
            if not r['success']:
                f.write(f"| {r['segment']} | ERROR | - | - | - | - | - | - |\n")
                continue
            
            m = r['results']
            kelly_str = f"{r['kelly']['kelly_half']*100:.2f}%" if r['kelly'] else "-"
            conv_str = f"{r['convexity']['convexity_score']}" if r['convexity'] else "-"
            
            f.write(f"| {r['segment']} | {m.get('total_trades', 0)} | "
                   f"{m.get('win_rate', 0)*100:.1f}% | {m.get('profit_factor', 0):.2f} | "
                   f"{m.get('max_drawdown', 0)*100:.1f}% | {m.get('total_return', 0)*100:.1f}% | "
                   f"{kelly_str} | {conv_str} |\n")
        
        f.write("\n---\n\n")
        
        # Kelly Table
        f.write("## Kelly Table by Segment\n\n")
        f.write("| Segment | N | Win Rate | Payoff | Kelly Full | Kelly Half | Recommendation |\n")
        f.write("|---------|---|----------|--------|------------|------------|----------------|\n")
        
        for r in results:
            if not r['success'] or not r['kelly']:
                continue
            k = r['kelly']
            f.write(f"| {k['segment']} | {k['n_trades']} | {k['win_rate']*100:.1f}% | "
                   f"{k['payoff_ratio']:.2f} | {k['kelly_full']*100:.2f}% | "
                   f"{k['kelly_half']*100:.2f}% | {k['recommendation']} |\n")
        
        f.write("\n---\n\n")
        
        # Convexity Analysis
        f.write("## Convexity Analysis\n\n")
        f.write("| Segment | Asymmetry | Skewness | Tail Ratio | Gain/Pain | Score |\n")
        f.write("|---------|-----------|----------|------------|-----------|-------|\n")
        
        for r in results:
            if not r['success'] or not r['convexity']:
                continue
            c = r['convexity']
            f.write(f"| {r['segment']} | {c['asymmetry']:.2f} | {c['skewness']:.2f} | "
                   f"{c['tail_ratio']:.2f} | {c['gain_to_pain']:.2f} | {c['convexity_score']} |\n")
        
        f.write("\n---\n\n")
        
        # Detailed results per segment
        f.write("## Detailed Results\n\n")
        for r in results:
            f.write(f"### {r['segment']}\n\n")
            if not r['success']:
                f.write(f"**ERROR**: {r.get('error', 'Unknown')}\n\n")
                continue
            
            m = r['results']
            f.write(f"- **Trades**: {m.get('total_trades', 0)}\n")
            f.write(f"- **Win Rate**: {m.get('win_rate', 0)*100:.1f}%\n")
            f.write(f"- **Profit Factor**: {m.get('profit_factor', 0):.2f}\n")
            f.write(f"- **Max Drawdown**: {m.get('max_drawdown', 0)*100:.2f}%\n")
            f.write(f"- **Total Return**: {m.get('total_return', 0)*100:.2f}%\n")
            f.write(f"- **Sharpe Ratio**: {m.get('sharpe_ratio', 0):.2f}\n")
            f.write("\n")
        
        # Checkpoint
        f.write("## PHASE 2 CHECKPOINT\n\n")
        
        # Find best segment
        valid_results = [r for r in results if r['success'] and r['results'].get('profit_factor', 0) > 0]
        
        if valid_results:
            best = max(valid_results, key=lambda x: x['results'].get('profit_factor', 0))
            f.write(f"**Best Segment**: {best['segment']} (PF: {best['results'].get('profit_factor', 0):.2f})\n\n")
            
            # Checklist
            global_result = next((r for r in results if r['segment'] == 'GLOBAL'), None)
            
            checks = []
            if global_result and global_result['success']:
                gm = global_result['results']
                checks.append(f"- [{'x' if gm.get('profit_factor', 0) >= 1.3 else ' '}] PF Global >= 1.3 ({gm.get('profit_factor', 0):.2f})")
                checks.append(f"- [{'x' if gm.get('win_rate', 0) >= 0.45 else ' '}] Win Rate >= 45% ({gm.get('win_rate', 0)*100:.1f}%)")
                checks.append(f"- [{'x' if gm.get('max_drawdown', 0) <= 0.15 else ' '}] Max DD <= 15% ({gm.get('max_drawdown', 0)*100:.1f}%)")
                checks.append(f"- [{'x' if gm.get('total_trades', 0) >= 100 else ' '}] >= 100 trades ({gm.get('total_trades', 0)})")
            
            f.write("### Basic Metrics\n\n")
            f.write("\n".join(checks) + "\n\n")
            
            # GENIUS checks
            f.write("### GENIUS Metrics\n\n")
            if global_result and global_result['kelly']:
                k = global_result['kelly']
                f.write(f"- [{'x' if k['kelly_half'] > 0 else ' '}] Kelly positive ({k['kelly_half']*100:.2f}%)\n")
            if global_result and global_result['convexity']:
                c = global_result['convexity']
                f.write(f"- [{'x' if c['asymmetry'] >= 1.5 else ' '}] Asymmetry >= 1.5 ({c['asymmetry']:.2f})\n")
                f.write(f"- [{'x' if c['skewness'] > 0 else ' '}] Positive skewness ({c['skewness']:.2f})\n")
                f.write(f"- [{'x' if c['convexity_score'] >= 60 else ' '}] Convexity score >= 60 ({c['convexity_score']})\n")
        
        f.write("\n---\n\n")
        f.write("*Report generated by ORACLE + FORGE*\n")
    
    print(f"\nReport saved to: {output_path}")


def main():
    """Run Phase 2 validation pipeline"""
    
    print("="*70)
    print("  PHASE 2 VALIDATION PIPELINE - GENIUS METRICS")
    print("="*70)
    print(f"  Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("="*70)
    
    # Base config
    base_config = BacktestConfig(
        execution_mode=ExecutionMode.PESSIMISTIC,
        initial_balance=100_000,
        risk_per_trade=0.005,
        use_regime_filter=True,
        hurst_threshold=0.55,
        use_session_filter=True,
        session_start_hour=7,
        session_end_hour=21,
        use_ea_logic=False,  # Start with simple strategy
        bar_timeframe='5min',
        debug=False
    )
    
    results = []
    
    # Test 1: Global (2024 data - recent)
    data_path = PROCESSED_DIR / "ticks_2024.parquet"
    if data_path.exists():
        base_config.use_regime_filter = False
        base_config.use_session_filter = False
        r = run_backtest_segment("GLOBAL", data_path, base_config, max_ticks=3_000_000)
        results.append(r)
    
    # Test 2: With Regime Filter
    if data_path.exists():
        base_config.use_regime_filter = True
        base_config.use_session_filter = False
        r = run_backtest_segment("REGIME_FILTER", data_path, base_config, max_ticks=3_000_000)
        results.append(r)
    
    # Test 3: With Session Filter
    if data_path.exists():
        base_config.use_regime_filter = False
        base_config.use_session_filter = True
        r = run_backtest_segment("SESSION_FILTER", data_path, base_config, max_ticks=3_000_000)
        results.append(r)
    
    # Test 4: Both Filters
    if data_path.exists():
        base_config.use_regime_filter = True
        base_config.use_session_filter = True
        r = run_backtest_segment("REGIME+SESSION", data_path, base_config, max_ticks=3_000_000)
        results.append(r)
    
    # Test 5: Trending segment only
    trending_path = SEGMENTS_DIR / "regime_trending.parquet"
    if trending_path.exists():
        base_config.use_regime_filter = False  # Already filtered
        base_config.use_session_filter = True
        r = run_backtest_segment("TRENDING", trending_path, base_config, max_ticks=2_000_000)
        results.append(r)
    
    # Test 6: Trending + Overlap (best segment)
    best_path = SEGMENTS_DIR / "trending_overlap.parquet"
    if best_path.exists():
        base_config.use_regime_filter = False
        base_config.use_session_filter = False
        r = run_backtest_segment("TRENDING_OVERLAP", best_path, base_config, max_ticks=1_000_000)
        results.append(r)
    
    # Generate report
    report_path = OUTPUT_DIR / f"PHASE2_VALIDATION_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md"
    generate_report(results, report_path)
    
    # Save raw results
    results_json = OUTPUT_DIR / f"phase2_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    
    # Prepare JSON-serializable results
    json_results = []
    for r in results:
        jr = {
            'segment': r['segment'],
            'success': r['success']
        }
        if r['success']:
            jr['results'] = r['results']
            jr['kelly'] = r['kelly']
            jr['convexity'] = r['convexity']
            jr['n_trades'] = len(r['trades']) if isinstance(r.get('trades'), pd.DataFrame) else 0
        else:
            jr['error'] = r.get('error', 'Unknown')
        json_results.append(jr)
    
    with open(results_json, 'w') as f:
        json.dump(json_results, f, indent=2, default=str)
    
    print(f"\nResults saved to: {results_json}")
    
    print("\n" + "="*70)
    print("  PHASE 2 VALIDATION COMPLETE")
    print("="*70)
    
    return results


if __name__ == "__main__":
    main()
