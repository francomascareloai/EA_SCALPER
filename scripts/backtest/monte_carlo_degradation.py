#!/usr/bin/env python3
"""
Monte Carlo Degradation Test
============================
Simulates real-world degradation by randomly converting some winners to losers.

This tests the strategy's robustness against:
1. False signals that look good but fail
2. Bad fills / timing within bars
3. Unexpected market behavior
4. Model overfitting

Tests degradation from 0% to 50% of winners converted to losers.

Author: ORACLE
Date: 2025-12-02
"""
import sys
sys.path.insert(0, 'C:/Users/Admin/Documents/EA_SCALPER_XAUUSD')

import pandas as pd
import numpy as np
import random
from typing import List, Dict


def degrade_trades(trades: List[Dict], degradation_rate: float, seed: int = 42) -> Dict:
    """
    Apply degradation by converting some winners to losers.
    
    Args:
        trades: List of trade dicts with 'pnl' key
        degradation_rate: 0.0 to 1.0 - fraction of winners to convert
        seed: Random seed for reproducibility
        
    Returns:
        Dict with degraded metrics
    """
    random.seed(seed)
    np.random.seed(seed)
    
    degraded_trades = []
    winners_converted = 0
    
    for trade in trades:
        new_trade = trade.copy()
        
        # If winner, potentially convert to loser
        if trade['pnl'] > 0 and random.random() < degradation_rate:
            # Convert to loss - assume SL hit instead of TP
            # Calculate what the loss would have been
            # Approximate: loss = -win * (SL_dist / TP_dist) if we had RR info
            # For simplicity, assume 1.5 RR, so loss = -win / 1.5
            new_trade['pnl'] = -abs(trade['pnl']) / 1.5
            new_trade['exit_reason'] = 'SL'  # Was TP, now SL
            winners_converted += 1
        
        degraded_trades.append(new_trade)
    
    # Calculate metrics
    total_trades = len(degraded_trades)
    winners = [t for t in degraded_trades if t['pnl'] > 0]
    losers = [t for t in degraded_trades if t['pnl'] <= 0]
    
    gross_profit = sum(t['pnl'] for t in winners)
    gross_loss = abs(sum(t['pnl'] for t in losers))
    net_profit = gross_profit - gross_loss
    
    win_rate = len(winners) / total_trades if total_trades > 0 else 0
    profit_factor = gross_profit / gross_loss if gross_loss > 0 else float('inf')
    
    # Simple drawdown calculation
    cumsum = np.cumsum([t['pnl'] for t in degraded_trades])
    running_max = np.maximum.accumulate(cumsum)
    drawdown = (running_max - cumsum) / (100_000 + running_max)  # Assume 100k starting
    max_dd = drawdown.max()
    
    return {
        'total_trades': total_trades,
        'winners': len(winners),
        'losers': len(losers),
        'win_rate': win_rate,
        'gross_profit': gross_profit,
        'gross_loss': gross_loss,
        'net_profit': net_profit,
        'profit_factor': profit_factor,
        'max_dd': max_dd,
        'winners_converted': winners_converted
    }


def run_monte_carlo_degradation():
    """Run Monte Carlo degradation sweep"""
    
    print("=" * 100)
    print("MONTE CARLO DEGRADATION TEST")
    print("Simulating real-world degradation by converting winners to losers")
    print("=" * 100)
    
    # First run a backtest to get trades
    from scripts.backtest.tick_backtester import (
        TickBacktester, BacktestConfig, ExecutionMode
    )
    
    data_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/data/processed/ticks_2024.parquet"
    
    print("\n[1] Running baseline backtest...")
    
    config = BacktestConfig(
        execution_mode=ExecutionMode.PESSIMISTIC,
        initial_balance=100_000,
        risk_per_trade=0.005,
        use_ea_logic=True,
        use_session_filter=True,
        session_start_hour=8,
        session_end_hour=20,
        bar_timeframe='5min',
        base_slippage_points=5.0,
        rejection_rate=0.02,
        debug=False
    )
    
    random.seed(42)
    np.random.seed(42)
    
    bt = TickBacktester(config)
    result = bt.run(data_path, max_ticks=5_000_000)
    
    # Convert trades to dicts
    trades = [
        {
            'pnl': t.pnl,
            'exit_reason': t.exit_reason,
            'lots': t.lots,
        }
        for t in bt.trades
    ]
    
    baseline_metrics = result['metrics']
    print(f"    Baseline: {baseline_metrics['total_trades']} trades, "
          f"{baseline_metrics['win_rate']:.1%} WR, "
          f"PF {baseline_metrics['profit_factor']:.2f}")
    
    # Test different degradation levels
    print("\n[2] Testing degradation levels...")
    
    degradation_levels = [0.0, 0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.35, 0.40, 0.50]
    results = []
    
    for degrad in degradation_levels:
        metrics = degrade_trades(trades, degrad)
        results.append({
            'degradation': degrad,
            **metrics
        })
        
        status = "PROFIT" if metrics['profit_factor'] >= 1.2 else ("MARGINAL" if metrics['profit_factor'] >= 1.0 else "LOSS")
        print(f"    {degrad*100:>5.0f}% degradation: WR {metrics['win_rate']:.1%}, "
              f"PF {metrics['profit_factor']:.2f}, Net ${metrics['net_profit']:,.0f} [{status}]")
    
    # Summary table
    print("\n" + "=" * 110)
    print("MONTE CARLO DEGRADATION RESULTS")
    print("=" * 110)
    print(f"{'Degrad%':>8} {'Trades':>8} {'Winners':>8} {'WR':>8} {'PF':>8} {'Net Profit':>12} {'MaxDD':>8} {'Converted':>10} {'Status'}")
    print("-" * 110)
    
    for r in results:
        status = "PROFIT" if r['profit_factor'] >= 1.2 else ("MARGINAL" if r['profit_factor'] >= 1.0 else "LOSS")
        print(f"{r['degradation']*100:>7.0f}% {r['total_trades']:>8} {r['winners']:>8} "
              f"{r['win_rate']:>7.1%} {r['profit_factor']:>8.2f} ${r['net_profit']:>10,.0f} "
              f"{r['max_dd']:>7.2%} {r['winners_converted']:>10} {status}")
    
    # Find breaking points
    print("\n" + "=" * 110)
    print("BREAKING POINT ANALYSIS")
    print("=" * 110)
    
    marginal_point = None
    loss_point = None
    
    for r in results:
        if r['profit_factor'] < 1.2 and marginal_point is None:
            marginal_point = r['degradation']
        if r['profit_factor'] < 1.0 and loss_point is None:
            loss_point = r['degradation']
    
    if marginal_point:
        print(f"  Strategy becomes MARGINAL at {marginal_point*100:.0f}% degradation")
        print(f"    (i.e., {marginal_point*100:.0f}% of winning signals turn out to be losers)")
    else:
        print(f"  Strategy stays PROFITABLE even at 50% degradation!")
    
    if loss_point:
        print(f"  Strategy becomes LOSS-MAKING at {loss_point*100:.0f}% degradation")
    else:
        print(f"  Strategy never becomes loss-making in tested range!")
    
    # Interpretation
    print("\n" + "=" * 110)
    print("REAL-WORLD INTERPRETATION")
    print("=" * 110)
    print("""
    Degradation represents "false signals" - trades that look good in backtesting
    but fail in live trading due to:
    - Entry timing (price moved before order filled)
    - Spread widening during signal generation
    - Market microstructure effects
    - Overfitting to historical patterns
    
    Industry benchmarks:
    - Well-designed strategies: 10-20% degradation expected
    - Average strategies: 20-30% degradation expected
    - Overfitted strategies: 40%+ degradation (often complete failure)
    """)
    
    # Find the expected live performance
    expected_degrad = 0.20  # Industry standard 20% degradation
    expected_metrics = degrade_trades(trades, expected_degrad)
    
    print(f"\n  EXPECTED LIVE PERFORMANCE (assuming 20% degradation):")
    print(f"    Win Rate: {baseline_metrics['win_rate']:.1%} -> {expected_metrics['win_rate']:.1%}")
    print(f"    Profit Factor: {baseline_metrics['profit_factor']:.2f} -> {expected_metrics['profit_factor']:.2f}")
    print(f"    Net Profit: ${baseline_metrics['net_profit']:,.0f} -> ${expected_metrics['net_profit']:,.0f}")
    print(f"    Max DD: {baseline_metrics['max_drawdown']:.2%} -> {expected_metrics['max_dd']:.2%}")
    
    # Final verdict
    print("\n" + "=" * 110)
    print("FINAL VERDICT")
    print("=" * 110)
    
    if expected_metrics['profit_factor'] >= 1.5:
        print("  [STRONG GO] Strategy maintains good profitability even with realistic degradation")
        print("              Recommended for live testing after demo period")
    elif expected_metrics['profit_factor'] >= 1.2:
        print("  [GO] Strategy remains profitable with expected degradation")
        print("       Proceed to demo testing with caution")
    elif expected_metrics['profit_factor'] >= 1.0:
        print("  [MARGINAL] Strategy barely profitable with expected degradation")
        print("             Consider improving signal quality before live trading")
    else:
        print("  [NO-GO] Strategy not viable with realistic degradation")
        print("          Need significant improvements before live testing")
    
    print("=" * 110)
    
    return results


if __name__ == "__main__":
    run_monte_carlo_degradation()
