#!/usr/bin/env python3
"""
FASE 2.1: EA Logic Backtest
============================
Run backtest using EA_SCALPER_XAUUSD Python parity layer.

This is NOT the MA crossover baseline - this uses the FULL EA logic:
- CRegimeDetector
- CSessionFilter
- CMTFManager
- CLiquiditySweepDetector
- CFootprintAnalyzer (simplified)
- CConfluenceScorer

Author: ORACLE
Date: 2025-12-02
"""

import os
import sys
from pathlib import Path
from datetime import datetime

# Add project root to path
project_root = Path(__file__).parent.parent.parent
sys.path.insert(0, str(project_root))

import numpy as np
import pandas as pd
import pyarrow.parquet as pq

# Import backtester with EA logic support
from scripts.backtest.tick_backtester import (
    TickBacktester,
    BacktestConfig,
    ExecutionMode
)


def load_processed_data(year: int = 2024, max_rows: int = 5_000_000) -> str:
    """Get path to processed parquet file."""
    data_dir = project_root / "data" / "processed"
    parquet_path = data_dir / f"ticks_{year}.parquet"
    
    if not parquet_path.exists():
        print(f"[ERROR] Parquet file not found: {parquet_path}")
        print(f"Available files: {list(data_dir.glob('*.parquet'))}")
        sys.exit(1)
    
    return str(parquet_path)


def run_ea_logic_backtest(
    years: list = [2024],
    execution_mode: ExecutionMode = ExecutionMode.PESSIMISTIC,
    max_ticks: int = 5_000_000,
    risk_per_trade: float = 0.005,  # 0.5%
    use_footprint: bool = False,  # Disable for initial speed test
    bar_timeframe: str = '5min'
) -> dict:
    """
    Run backtest using EA logic (not MA crossover).
    
    Args:
        years: List of years to backtest
        execution_mode: OPTIMISTIC, NORMAL, PESSIMISTIC, STRESS
        max_ticks: Max ticks per year
        risk_per_trade: Risk per trade (0.005 = 0.5%)
        use_footprint: Enable footprint analysis (slower)
        bar_timeframe: Indicator timeframe
    
    Returns:
        Dict with aggregated results
    """
    print("\n" + "="*70)
    print("       FASE 2.1: EA LOGIC BACKTEST")
    print("       Using Python Parity of EA_SCALPER_XAUUSD v3.30")
    print("="*70)
    
    all_results = []
    
    for year in years:
        print(f"\n[Year {year}] Loading data...")
        
        # Get data path
        data_path = load_processed_data(year, max_ticks)
        
        # Configure backtest
        # NOTE: EA execution_threshold is in EAConfig, not BacktestConfig
        # We need to modify ea_logic_python default or pass via a custom config
        config = BacktestConfig(
            # EA Logic mode - THIS IS THE KEY DIFFERENCE
            use_ea_logic=True,
            eval_window_bars=500,  # Bars window for EA evaluation (increased for regime)
            
            # Execution settings
            execution_mode=execution_mode,
            
            # Capital and risk
            initial_balance=100_000.0,
            risk_per_trade=risk_per_trade,
            max_daily_dd=0.05,  # 5% FTMO
            max_total_dd=0.10,  # 10% FTMO
            
            # Timeframe
            bar_timeframe=bar_timeframe,
            exec_timeframe=bar_timeframe,
            
            # Strategy params (used by EA logic internally)
            atr_period=14,
            atr_sl_mult=2.0,
            atr_tp_mult=3.0,
            
            # Filters handled by EA logic, disable baseline filters
            use_regime_filter=False,  # EA has its own regime detection
            use_session_filter=False,  # EA has its own session filter
            
            # Footprint (optional, slower)
            fp_score=50.0,  # Default if not computed
            
            # Debug
            debug=True,
            debug_interval=1000
        )
        
        # Run backtest
        bt = TickBacktester(config)
        results = bt.run(
            tick_path=data_path,
            max_ticks=max_ticks
        )
        
        results['year'] = year
        all_results.append(results)
        
        # Export trades
        output_dir = project_root / "data" / "trades_ea_logic"
        output_dir.mkdir(exist_ok=True)
        export_path = output_dir / f"trades_ea_logic_{year}.csv"
        bt.export_trades(str(export_path))
        
        # Print gate blocks if available (from EA logic)
        if bt.ea is not None and hasattr(bt.ea, 'gate_blocks'):
            print(f"\n[Year {year}] EA Gate Blocks:")
            for gate, count in sorted(bt.ea.gate_blocks.items()):
                print(f"  {gate}: {count:,}")
    
    # Aggregate results
    return aggregate_results(all_results)


def aggregate_results(results_list: list) -> dict:
    """Aggregate results from multiple years."""
    
    if not results_list:
        return {'error': 'No results to aggregate'}
    
    # Combine all trades
    all_trades = []
    for r in results_list:
        all_trades.extend(r.get('trades', []))
    
    if not all_trades:
        return {'error': 'No trades generated across all years'}
    
    # Recalculate metrics
    pnls = [t.pnl for t in all_trades]
    wins = [p for p in pnls if p > 0]
    losses = [p for p in pnls if p < 0]
    
    total_trades = len(all_trades)
    win_rate = len(wins) / total_trades if total_trades > 0 else 0
    
    gross_profit = sum(wins) if wins else 0
    gross_loss = abs(sum(losses)) if losses else 0
    profit_factor = gross_profit / gross_loss if gross_loss > 0 else float('inf')
    
    # Max DD across all periods
    max_dd = max(r['metrics'].get('max_drawdown', 0) for r in results_list)
    
    # Total return
    final_balance = results_list[-1]['metrics'].get('final_balance', 100000)
    total_return = (final_balance - 100000) / 100000
    
    # Sharpe approximation
    if len(pnls) > 1:
        returns = np.array(pnls) / 100000
        sharpe = np.mean(returns) / np.std(returns) * np.sqrt(252 * 288) if np.std(returns) > 0 else 0
    else:
        sharpe = 0
    
    # SQN
    sqn = np.sqrt(total_trades) * np.mean(pnls) / np.std(pnls) if np.std(pnls) > 0 else 0
    
    agg = {
        'total_trades': total_trades,
        'win_rate': win_rate,
        'profit_factor': profit_factor,
        'max_drawdown': max_dd,
        'total_return': total_return,
        'sharpe_ratio': sharpe,
        'sqn': sqn,
        'gross_profit': gross_profit,
        'gross_loss': gross_loss,
        'avg_win': np.mean(wins) if wins else 0,
        'avg_loss': np.mean(losses) if losses else 0,
        'final_balance': final_balance,
        'net_profit': final_balance - 100000,
        'years_tested': len(results_list),
        'all_trades': all_trades,
        'per_year_results': results_list
    }
    
    print_aggregated_report(agg)
    return agg


def print_aggregated_report(agg: dict):
    """Print aggregated backtest report."""
    
    print("\n" + "="*70)
    print("           AGGREGATED EA LOGIC BACKTEST REPORT")
    print("="*70)
    
    if 'error' in agg:
        print(f"\n[ERROR] {agg['error']}")
        return
    
    print(f"\nYears Tested:     {agg['years_tested']}")
    print(f"Total Trades:     {agg['total_trades']}")
    print(f"Win Rate:         {agg['win_rate']:.1%}")
    print(f"Profit Factor:    {agg['profit_factor']:.2f}")
    print(f"Sharpe Ratio:     {agg['sharpe_ratio']:.2f}")
    print(f"SQN:              {agg['sqn']:.2f}")
    
    print(f"\nMax Drawdown:     {agg['max_drawdown']:.2%}")
    print(f"Total Return:     {agg['total_return']:.2%}")
    print(f"Net Profit:       ${agg['net_profit']:,.2f}")
    print(f"Final Balance:    ${agg['final_balance']:,.2f}")
    
    print(f"\nGross Profit:     ${agg['gross_profit']:,.2f}")
    print(f"Gross Loss:       ${agg['gross_loss']:,.2f}")
    print(f"Avg Win:          ${agg['avg_win']:,.2f}")
    print(f"Avg Loss:         ${agg['avg_loss']:,.2f}")
    
    # GENIUS Scoring
    print("\n" + "-"*50)
    print("GENIUS SCORING (GO/NO-GO):")
    
    score = 0
    max_score = 100
    
    # PF scoring (0-20)
    if agg['profit_factor'] >= 1.5:
        score += 20
        print(f"  [20/20] PF >= 1.5 ({agg['profit_factor']:.2f})")
    elif agg['profit_factor'] >= 1.3:
        score += 15
        print(f"  [15/20] PF >= 1.3 ({agg['profit_factor']:.2f})")
    elif agg['profit_factor'] >= 1.0:
        score += 10
        print(f"  [10/20] PF >= 1.0 ({agg['profit_factor']:.2f})")
    else:
        print(f"  [ 0/20] PF < 1.0 ({agg['profit_factor']:.2f})")
    
    # Win rate scoring (0-15)
    if agg['win_rate'] >= 0.55:
        score += 15
        print(f"  [15/15] WR >= 55% ({agg['win_rate']:.1%})")
    elif agg['win_rate'] >= 0.50:
        score += 10
        print(f"  [10/15] WR >= 50% ({agg['win_rate']:.1%})")
    elif agg['win_rate'] >= 0.45:
        score += 5
        print(f"  [ 5/15] WR >= 45% ({agg['win_rate']:.1%})")
    else:
        print(f"  [ 0/15] WR < 45% ({agg['win_rate']:.1%})")
    
    # Max DD scoring (0-20)
    if agg['max_drawdown'] < 0.05:
        score += 20
        print(f"  [20/20] Max DD < 5% ({agg['max_drawdown']:.1%})")
    elif agg['max_drawdown'] < 0.08:
        score += 15
        print(f"  [15/20] Max DD < 8% ({agg['max_drawdown']:.1%})")
    elif agg['max_drawdown'] < 0.10:
        score += 10
        print(f"  [10/20] Max DD < 10% ({agg['max_drawdown']:.1%})")
    else:
        print(f"  [ 0/20] Max DD >= 10% ({agg['max_drawdown']:.1%})")
    
    # Sharpe scoring (0-20)
    if agg['sharpe_ratio'] >= 2.0:
        score += 20
        print(f"  [20/20] Sharpe >= 2.0 ({agg['sharpe_ratio']:.2f})")
    elif agg['sharpe_ratio'] >= 1.5:
        score += 15
        print(f"  [15/20] Sharpe >= 1.5 ({agg['sharpe_ratio']:.2f})")
    elif agg['sharpe_ratio'] >= 1.0:
        score += 10
        print(f"  [10/20] Sharpe >= 1.0 ({agg['sharpe_ratio']:.2f})")
    else:
        print(f"  [ 0/20] Sharpe < 1.0 ({agg['sharpe_ratio']:.2f})")
    
    # SQN scoring (0-15)
    if agg['sqn'] >= 2.0:
        score += 15
        print(f"  [15/15] SQN >= 2.0 ({agg['sqn']:.2f})")
    elif agg['sqn'] >= 1.5:
        score += 10
        print(f"  [10/15] SQN >= 1.5 ({agg['sqn']:.2f})")
    elif agg['sqn'] >= 1.0:
        score += 5
        print(f"  [ 5/15] SQN >= 1.0 ({agg['sqn']:.2f})")
    else:
        print(f"  [ 0/15] SQN < 1.0 ({agg['sqn']:.2f})")
    
    # Trade count scoring (0-10)
    if agg['total_trades'] >= 200:
        score += 10
        print(f"  [10/10] Trades >= 200 ({agg['total_trades']})")
    elif agg['total_trades'] >= 100:
        score += 7
        print(f"  [ 7/10] Trades >= 100 ({agg['total_trades']})")
    elif agg['total_trades'] >= 50:
        score += 5
        print(f"  [ 5/10] Trades >= 50 ({agg['total_trades']})")
    else:
        print(f"  [ 0/10] Trades < 50 ({agg['total_trades']}) - LOW SIGNIFICANCE")
    
    print("-"*50)
    print(f"GENIUS SCORE: {score}/{max_score}")
    
    if score >= 80:
        print("VERDICT: [GO] - Ready for WFA and Monte Carlo")
    elif score >= 60:
        print("VERDICT: [CONDITIONAL GO] - Proceed with caution")
    else:
        print("VERDICT: [NO-GO] - Needs optimization")
    
    print("="*70)


def main():
    """Run FASE 2.1 EA Logic backtest."""
    
    # Run on 2024 data with MORE ticks and M15 timeframe for more signals
    results = run_ea_logic_backtest(
        years=[2024],  # Start with 1 year
        execution_mode=ExecutionMode.PESSIMISTIC,
        max_ticks=10_000_000,  # ~10M ticks for better H1 coverage
        risk_per_trade=0.005,  # 0.5% risk per trade
        bar_timeframe='15min'  # M15 for EA compatibility
    )
    
    # Save results
    output_path = project_root / "DOCS" / "04_REPORTS" / "BACKTESTS" / "FASE2_1_EA_LOGIC_RESULTS.json"
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    import json
    
    # Create serializable version
    results_json = {
        'total_trades': results.get('total_trades', 0),
        'win_rate': results.get('win_rate', 0),
        'profit_factor': results.get('profit_factor', 0),
        'max_drawdown': results.get('max_drawdown', 0),
        'total_return': results.get('total_return', 0),
        'sharpe_ratio': results.get('sharpe_ratio', 0),
        'sqn': results.get('sqn', 0),
        'gross_profit': results.get('gross_profit', 0),
        'gross_loss': results.get('gross_loss', 0),
        'avg_win': results.get('avg_win', 0),
        'avg_loss': results.get('avg_loss', 0),
        'final_balance': results.get('final_balance', 100000),
        'net_profit': results.get('net_profit', 0),
        'timestamp': datetime.now().isoformat(),
        'config': {
            'execution_mode': 'PESSIMISTIC',
            'years': [2024],
            'use_ea_logic': True
        }
    }
    
    with open(output_path, 'w') as f:
        json.dump(results_json, f, indent=2)
    
    print(f"\n[Results saved to: {output_path}]")
    
    return results


if __name__ == "__main__":
    main()
