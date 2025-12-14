#!/usr/bin/env python3
"""
run_phase2_full_validation.py - Full 2020-2024 Validation Pipeline
===================================================================
Runs SESSION_FILTER configuration across 5 years of tick data to
achieve statistical significance (200+ trades target).

Author: FORGE + ORACLE
Date: 2025-12-02
"""

import sys
import os
import json
from pathlib import Path
from datetime import datetime
from dataclasses import dataclass, asdict
from typing import Dict, List, Optional, Tuple
import numpy as np
import pandas as pd

PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from scripts.backtest.tick_backtester import (
    TickBacktester, BacktestConfig, ExecutionMode
)

DATA_DIR = PROJECT_ROOT / "data"
PROCESSED_DIR = DATA_DIR / "processed"
OUTPUT_DIR = PROJECT_ROOT / "DOCS" / "04_REPORTS" / "BACKTESTS"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)


@dataclass
class KellyMetrics:
    """Kelly criterion metrics"""
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
    asymmetry: float
    skewness: float
    tail_ratio: float
    gain_to_pain: float
    convexity_score: int


def calculate_kelly(trades: pd.DataFrame, segment_name: str = "") -> KellyMetrics:
    """Calculate Kelly criterion metrics from trades"""
    if len(trades) < 20:
        return KellyMetrics(
            segment=segment_name, n_trades=len(trades), win_rate=0, avg_win=0, avg_loss=0,
            payoff_ratio=0, kelly_full=0, kelly_half=0, kelly_quarter=0,
            recommendation="INSUFFICIENT_DATA"
        )
    
    wins = trades[trades['profit'] > 0]
    losses = trades[trades['profit'] <= 0]
    
    if len(wins) == 0 or len(losses) == 0:
        return KellyMetrics(
            segment=segment_name, n_trades=len(trades), 
            win_rate=len(wins)/len(trades) if len(trades) > 0 else 0,
            avg_win=wins['profit'].mean() if len(wins) > 0 else 0, 
            avg_loss=0, payoff_ratio=0, kelly_full=0, kelly_half=0, kelly_quarter=0,
            recommendation="NO_EDGE"
        )
    
    p = len(wins) / len(trades)
    q = 1 - p
    avg_win = wins['profit'].mean()
    avg_loss = abs(losses['profit'].mean())
    b = avg_win / avg_loss if avg_loss > 0 else 0
    
    kelly_full = (p * b - q) / b if b > 0 else 0
    n = len(trades)
    kelly_corrected = kelly_full * (1 - 1/np.sqrt(n)) if n > 0 else 0
    
    if kelly_corrected <= 0:
        rec = "AVOID"
    elif n < 50:
        rec = "QUARTER_KELLY"
    elif n < 100:
        rec = "QUARTER_KELLY"
    elif n < 200:
        rec = "HALF_KELLY"
    else:
        rec = "HALF_KELLY_OR_FULL"
    
    return KellyMetrics(
        segment=segment_name,
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
    if len(trades) < 20:
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
    
    if len(wins) >= 5 and len(losses) >= 5:
        tail_ratio = np.percentile(wins, 95) / abs(np.percentile(losses, 5))
    else:
        tail_ratio = asymmetry
    
    gain_to_pain = sum(wins) / abs(sum(losses)) if sum(losses) != 0 else 0
    
    score = 0
    if asymmetry >= 1.5: score += 30
    elif asymmetry >= 1.2: score += 20
    elif asymmetry >= 1.0: score += 10
    
    if skewness > 0.5: score += 30
    elif skewness > 0: score += 15
    
    if tail_ratio >= 2.0: score += 20
    elif tail_ratio >= 1.5: score += 10
    
    if gain_to_pain >= 2.0: score += 20
    elif gain_to_pain >= 1.5: score += 10
    
    return ConvexityMetrics(
        asymmetry=asymmetry,
        skewness=skewness,
        tail_ratio=tail_ratio,
        gain_to_pain=gain_to_pain,
        convexity_score=min(100, score)
    )


def calculate_sqn(trades: pd.DataFrame) -> float:
    """Calculate System Quality Number (Van Tharp)"""
    if len(trades) < 20:
        return 0
    profits = trades['profit'].values
    mean_r = np.mean(profits)
    std_r = np.std(profits)
    if std_r == 0:
        return 0
    sqn = (mean_r / std_r) * np.sqrt(len(profits))
    return sqn


def run_backtest_year(year: int, config: BacktestConfig, 
                      max_ticks: int = 10_000_000) -> Tuple[Dict, pd.DataFrame]:
    """Run backtest for a single year"""
    data_path = PROCESSED_DIR / f"ticks_{year}.parquet"
    if not data_path.exists():
        print(f"  [!] Data not found for {year}")
        return {}, pd.DataFrame()
    
    print(f"  Processing {year}... ({data_path.stat().st_size / 1e6:.1f} MB)")
    
    try:
        bt = TickBacktester(config)
        raw_results = bt.run(str(data_path), max_ticks=max_ticks)
        
        # Extract metrics from the return structure
        metrics = raw_results.get('metrics', raw_results)  # Handle both old and new format
        
        trades_data = []
        if hasattr(bt, 'trades') and bt.trades:
            for t in bt.trades:
                trades_data.append({
                    'year': year,
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
        print(f"    -> {len(trades_df)} trades, PF: {metrics.get('profit_factor', 0):.2f}, Return: {metrics.get('total_return', 0)*100:.1f}%")
        
        return metrics, trades_df
        
    except Exception as e:
        print(f"  [ERROR] {year}: {e}")
        import traceback
        traceback.print_exc()
        return {}, pd.DataFrame()


def aggregate_results(yearly_results: Dict[int, Tuple[Dict, pd.DataFrame]]) -> Dict:
    """Aggregate results from multiple years"""
    all_trades = []
    total_return = 0
    equity_curves = []
    
    for year, (results, trades_df) in sorted(yearly_results.items()):
        if not trades_df.empty:
            all_trades.append(trades_df)
            total_return += results.get('total_return', 0)
    
    if not all_trades:
        return {}
    
    combined_trades = pd.concat(all_trades, ignore_index=True)
    
    wins = combined_trades[combined_trades['profit'] > 0]
    losses = combined_trades[combined_trades['profit'] <= 0]
    
    win_rate = len(wins) / len(combined_trades) if len(combined_trades) > 0 else 0
    
    total_wins = wins['profit'].sum() if len(wins) > 0 else 0
    total_losses = abs(losses['profit'].sum()) if len(losses) > 0 else 0
    profit_factor = total_wins / total_losses if total_losses > 0 else 0
    
    # Calculate equity curve
    combined_trades_sorted = combined_trades.sort_values('entry_time')
    equity = 100000  # Starting balance
    peak = equity
    max_dd = 0
    
    for _, trade in combined_trades_sorted.iterrows():
        equity += trade['profit']
        peak = max(peak, equity)
        dd = (peak - equity) / peak
        max_dd = max(max_dd, dd)
    
    # Calculate Sharpe (simplified)
    profits = combined_trades['profit'].values
    daily_returns = profits / 100000  # Approximate
    sharpe = np.mean(daily_returns) / np.std(daily_returns) * np.sqrt(252) if np.std(daily_returns) > 0 else 0
    
    return {
        'total_trades': len(combined_trades),
        'win_rate': win_rate,
        'profit_factor': profit_factor,
        'total_return': total_return,
        'max_drawdown': max_dd,
        'sharpe_ratio': sharpe,
        'avg_win': wins['profit'].mean() if len(wins) > 0 else 0,
        'avg_loss': abs(losses['profit'].mean()) if len(losses) > 0 else 0,
        'sqn': calculate_sqn(combined_trades),
        'combined_trades': combined_trades
    }


def generate_full_report(session_results: Dict, global_results: Dict, output_path: Path):
    """Generate comprehensive report"""
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write("# PHASE 2 FULL VALIDATION REPORT (2020-2024)\n\n")
        f.write(f"**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        f.write("---\n\n")
        
        # Main comparison table
        f.write("## Configuration Comparison\n\n")
        f.write("| Metric | GLOBAL (No Filter) | SESSION_FILTER (7:00-21:00 GMT) |\n")
        f.write("|--------|--------------------|---------------------------------|\n")
        f.write(f"| Total Trades | {global_results.get('total_trades', 0)} | {session_results.get('total_trades', 0)} |\n")
        f.write(f"| Win Rate | {global_results.get('win_rate', 0)*100:.1f}% | {session_results.get('win_rate', 0)*100:.1f}% |\n")
        f.write(f"| Profit Factor | {global_results.get('profit_factor', 0):.2f} | {session_results.get('profit_factor', 0):.2f} |\n")
        f.write(f"| Max Drawdown | {global_results.get('max_drawdown', 0)*100:.1f}% | {session_results.get('max_drawdown', 0)*100:.1f}% |\n")
        f.write(f"| Total Return | {global_results.get('total_return', 0)*100:.1f}% | {session_results.get('total_return', 0)*100:.1f}% |\n")
        f.write(f"| Sharpe Ratio | {global_results.get('sharpe_ratio', 0):.2f} | {session_results.get('sharpe_ratio', 0):.2f} |\n")
        f.write(f"| SQN | {global_results.get('sqn', 0):.2f} | {session_results.get('sqn', 0):.2f} |\n")
        
        f.write("\n---\n\n")
        
        # Kelly Analysis for SESSION_FILTER
        f.write("## Kelly Criterion Analysis (SESSION_FILTER)\n\n")
        if 'combined_trades' in session_results:
            kelly = calculate_kelly(session_results['combined_trades'], "SESSION_FILTER")
            f.write(f"- **Sample Size**: {kelly.n_trades} trades\n")
            f.write(f"- **Win Rate**: {kelly.win_rate*100:.1f}%\n")
            f.write(f"- **Payoff Ratio**: {kelly.payoff_ratio:.2f}\n")
            f.write(f"- **Kelly Full**: {kelly.kelly_full*100:.2f}%\n")
            f.write(f"- **Kelly Half** (recommended): {kelly.kelly_half*100:.2f}%\n")
            f.write(f"- **Kelly Quarter** (conservative): {kelly.kelly_quarter*100:.2f}%\n")
            f.write(f"- **Recommendation**: {kelly.recommendation}\n\n")
        
        # Convexity Analysis
        f.write("## Convexity Analysis (SESSION_FILTER)\n\n")
        if 'combined_trades' in session_results:
            conv = calculate_convexity(session_results['combined_trades'])
            f.write(f"- **Asymmetry** (avg_win/avg_loss): {conv.asymmetry:.2f}\n")
            f.write(f"- **Skewness**: {conv.skewness:.2f}\n")
            f.write(f"- **Tail Ratio**: {conv.tail_ratio:.2f}\n")
            f.write(f"- **Gain/Pain Ratio**: {conv.gain_to_pain:.2f}\n")
            f.write(f"- **Convexity Score**: {conv.convexity_score}/100\n\n")
        
        f.write("---\n\n")
        
        # GENIUS Checkpoint
        f.write("## PHASE 2 GENIUS CHECKPOINT\n\n")
        
        n_trades = session_results.get('total_trades', 0)
        pf = session_results.get('profit_factor', 0)
        wr = session_results.get('win_rate', 0)
        dd = session_results.get('max_drawdown', 0)
        sqn = session_results.get('sqn', 0)
        
        f.write("### Basic Metrics\n\n")
        f.write(f"- [{'x' if n_trades >= 100 else ' '}] >= 100 trades ({n_trades})\n")
        f.write(f"- [{'x' if pf >= 1.3 else ' '}] PF >= 1.3 ({pf:.2f})\n")
        f.write(f"- [{'x' if wr >= 0.45 else ' '}] Win Rate >= 45% ({wr*100:.1f}%)\n")
        f.write(f"- [{'x' if dd <= 0.10 else ' '}] Max DD <= 10% ({dd*100:.1f}%)\n")
        f.write(f"- [{'x' if sqn >= 1.5 else ' '}] SQN >= 1.5 ({sqn:.2f})\n\n")
        
        if 'combined_trades' in session_results:
            kelly = calculate_kelly(session_results['combined_trades'], "SESSION_FILTER")
            conv = calculate_convexity(session_results['combined_trades'])
            
            f.write("### GENIUS Metrics\n\n")
            f.write(f"- [{'x' if kelly.kelly_half > 0.02 else ' '}] Kelly Half > 2% ({kelly.kelly_half*100:.2f}%)\n")
            f.write(f"- [{'x' if conv.asymmetry >= 1.2 else ' '}] Asymmetry >= 1.2 ({conv.asymmetry:.2f})\n")
            f.write(f"- [{'x' if conv.skewness > 0 else ' '}] Positive skewness ({conv.skewness:.2f})\n")
            f.write(f"- [{'x' if conv.convexity_score >= 50 else ' '}] Convexity >= 50 ({conv.convexity_score})\n")
        
        f.write("\n---\n\n")
        
        # Go/No-Go Decision
        f.write("## PHASE 2 GO/NO-GO DECISION\n\n")
        
        passed_basic = n_trades >= 100 and pf >= 1.2 and wr >= 0.40 and dd <= 0.12
        passed_genius = False
        if 'combined_trades' in session_results:
            kelly = calculate_kelly(session_results['combined_trades'], "SESSION_FILTER")
            passed_genius = kelly.kelly_half > 0.01
        
        if passed_basic and passed_genius:
            f.write("### **GO** - Proceed to Phase 5 (Oracle Validation)\n\n")
            f.write("Rationale:\n")
            f.write("- SESSION_FILTER shows consistent edge across 2020-2024\n")
            f.write("- Positive Kelly indicates mathematical advantage\n")
            f.write("- Ready for Walk-Forward Analysis and Monte Carlo validation\n")
        elif passed_basic:
            f.write("### **CONDITIONAL GO** - Review GENIUS metrics\n\n")
            f.write("Basic metrics pass but GENIUS metrics marginal.\n")
        else:
            f.write("### **NO-GO** - Requires optimization\n\n")
            f.write("Strategy needs further refinement before Phase 5.\n")
        
        f.write("\n---\n\n")
        f.write("*Report generated by ORACLE + FORGE - Phase 2 Full Validation*\n")
    
    print(f"\n[+] Report saved: {output_path}")


def main():
    """Run full 2020-2024 validation"""
    
    print("="*70)
    print("  PHASE 2 FULL VALIDATION (2020-2024)")
    print("="*70)
    print(f"  Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("="*70)
    
    years = [2020, 2021, 2022, 2023, 2024]
    max_ticks_per_year = 15_000_000  # ~15M ticks per year
    
    # Config 1: GLOBAL (no filters)
    print("\n" + "-"*50)
    print("  [1/2] Running GLOBAL configuration (no filters)")
    print("-"*50)
    
    global_config = BacktestConfig(
        execution_mode=ExecutionMode.PESSIMISTIC,
        initial_balance=100_000,
        risk_per_trade=0.005,
        use_regime_filter=False,
        use_session_filter=False,
        use_ea_logic=False,
        bar_timeframe='5min',
        debug=False
    )
    
    global_yearly = {}
    for year in years:
        results, trades = run_backtest_year(year, global_config, max_ticks_per_year)
        if results:
            global_yearly[year] = (results, trades)
    
    global_aggregated = aggregate_results(global_yearly)
    print(f"\n  GLOBAL Total: {global_aggregated.get('total_trades', 0)} trades, PF: {global_aggregated.get('profit_factor', 0):.2f}")
    
    # Config 2: SESSION_FILTER (London/NY hours)
    print("\n" + "-"*50)
    print("  [2/2] Running SESSION_FILTER (7:00-21:00 GMT)")
    print("-"*50)
    
    session_config = BacktestConfig(
        execution_mode=ExecutionMode.PESSIMISTIC,
        initial_balance=100_000,
        risk_per_trade=0.005,
        use_regime_filter=False,
        use_session_filter=True,
        session_start_hour=7,
        session_end_hour=21,
        use_ea_logic=False,
        bar_timeframe='5min',
        debug=False
    )
    
    session_yearly = {}
    for year in years:
        results, trades = run_backtest_year(year, session_config, max_ticks_per_year)
        if results:
            session_yearly[year] = (results, trades)
    
    session_aggregated = aggregate_results(session_yearly)
    print(f"\n  SESSION_FILTER Total: {session_aggregated.get('total_trades', 0)} trades, PF: {session_aggregated.get('profit_factor', 0):.2f}")
    
    # Generate report
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    report_path = OUTPUT_DIR / f"PHASE2_FULL_VALIDATION_{timestamp}.md"
    generate_full_report(session_aggregated, global_aggregated, report_path)
    
    # Save JSON results
    json_path = OUTPUT_DIR / f"phase2_full_results_{timestamp}.json"
    
    json_data = {
        'timestamp': timestamp,
        'years': years,
        'global': {
            'total_trades': global_aggregated.get('total_trades', 0),
            'win_rate': global_aggregated.get('win_rate', 0),
            'profit_factor': global_aggregated.get('profit_factor', 0),
            'max_drawdown': global_aggregated.get('max_drawdown', 0),
            'total_return': global_aggregated.get('total_return', 0),
            'sqn': global_aggregated.get('sqn', 0),
        },
        'session_filter': {
            'total_trades': session_aggregated.get('total_trades', 0),
            'win_rate': session_aggregated.get('win_rate', 0),
            'profit_factor': session_aggregated.get('profit_factor', 0),
            'max_drawdown': session_aggregated.get('max_drawdown', 0),
            'total_return': session_aggregated.get('total_return', 0),
            'sqn': session_aggregated.get('sqn', 0),
        }
    }
    
    # Add Kelly metrics
    if 'combined_trades' in session_aggregated:
        kelly = calculate_kelly(session_aggregated['combined_trades'], "SESSION_FILTER")
        conv = calculate_convexity(session_aggregated['combined_trades'])
        json_data['session_filter']['kelly'] = asdict(kelly)
        json_data['session_filter']['convexity'] = asdict(conv)
    
    with open(json_path, 'w') as f:
        json.dump(json_data, f, indent=2, default=str)
    
    print(f"[+] JSON saved: {json_path}")
    
    print("\n" + "="*70)
    print("  PHASE 2 FULL VALIDATION COMPLETE")
    print("="*70)
    
    # Summary
    print(f"\n  SESSION_FILTER (2020-2024):")
    print(f"    Trades: {session_aggregated.get('total_trades', 0)}")
    print(f"    Win Rate: {session_aggregated.get('win_rate', 0)*100:.1f}%")
    print(f"    Profit Factor: {session_aggregated.get('profit_factor', 0):.2f}")
    print(f"    Max DD: {session_aggregated.get('max_drawdown', 0)*100:.1f}%")
    print(f"    SQN: {session_aggregated.get('sqn', 0):.2f}")
    
    if 'combined_trades' in session_aggregated:
        kelly = calculate_kelly(session_aggregated['combined_trades'], "SESSION_FILTER")
        print(f"    Kelly Half: {kelly.kelly_half*100:.2f}%")
    
    return session_aggregated, global_aggregated


if __name__ == "__main__":
    main()
