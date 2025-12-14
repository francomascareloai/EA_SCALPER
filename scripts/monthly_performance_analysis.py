#!/usr/bin/env python3
"""
Monthly Performance Analysis
Run backtest on each month independently to see true performance variation
"""
import sys
from pathlib import Path
import pandas as pd
from datetime import datetime

PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from scripts.backtest.tick_backtester import (
    TickBacktester, BacktestConfig, ExecutionMode
)

DATA_DIR = PROJECT_ROOT / "data" / "processed"


def test_month(year: int, month: int, config: BacktestConfig) -> dict:
    """Test strategy for a specific month"""
    
    # Load full year data
    data_path = DATA_DIR / f"ticks_{year}.parquet"
    if not data_path.exists():
        return None
    
    df = pd.read_parquet(data_path)
    df['datetime'] = pd.to_datetime(df['timestamp'])
    
    # Filter to specific month
    start_date = f"{year}-{month:02d}-01"
    if month == 12:
        end_date = f"{year}-{month:02d}-31"
    else:
        end_date = f"{year}-{month+1:02d}-01"
    
    mask = (df['datetime'] >= start_date) & (df['datetime'] < end_date)
    month_df = df[mask].copy()
    
    if len(month_df) < 100000:  # Need enough data
        return {'month': f"{year}-{month:02d}", 'trades': 0, 'error': 'Insufficient data'}
    
    # Save temp file for backtest
    temp_path = DATA_DIR / f"temp_month_{year}_{month:02d}.parquet"
    month_df.to_parquet(temp_path)
    
    try:
        # Run backtest with NO account blow (use large initial balance)
        config.initial_balance = 1_000_000  # $1M to avoid DD limit
        
        bt = TickBacktester(config)
        raw_results = bt.run(str(temp_path), max_ticks=50_000_000)
        metrics = raw_results.get('metrics', raw_results)
        
        n_trades = len(bt.trades) if bt.trades else 0
        
        # Calculate directional breakdown
        longs = 0
        long_wins = 0
        shorts = 0
        short_wins = 0
        
        if bt.trades:
            for t in bt.trades:
                direction = t.direction.value if hasattr(t.direction, 'value') else str(t.direction)
                if direction in ['BUY', 'LONG']:
                    longs += 1
                    if t.pnl > 0:
                        long_wins += 1
                else:
                    shorts += 1
                    if t.pnl > 0:
                        short_wins += 1
        
        result = {
            'month': f"{year}-{month:02d}",
            'trades': n_trades,
            'pf': metrics.get('profit_factor', 0),
            'wr': metrics.get('win_rate', 0),
            'return': metrics.get('total_return', 0),
            'dd': metrics.get('max_drawdown', 0),
            'longs': longs,
            'long_wr': long_wins / longs if longs > 0 else 0,
            'shorts': shorts,
            'short_wr': short_wins / shorts if shorts > 0 else 0,
        }
        
        # Cleanup
        temp_path.unlink()
        
        return result
        
    except Exception as e:
        if temp_path.exists():
            temp_path.unlink()
        return {'month': f"{year}-{month:02d}", 'trades': 0, 'error': str(e)}


def main():
    print("="*80)
    print("  MONTHLY PERFORMANCE ANALYSIS - SESSION_FILTER")
    print("="*80)
    
    config = BacktestConfig(
        execution_mode=ExecutionMode.PESSIMISTIC,
        initial_balance=1_000_000,  # High to avoid DD limit
        risk_per_trade=0.005,
        use_regime_filter=False,
        use_session_filter=True,
        session_start_hour=7,
        session_end_hour=21,
        use_ea_logic=False,
        bar_timeframe='5min',
        debug=False
    )
    
    # Test 2024 months
    print("\n  Testing each month of 2024...\n")
    
    results = []
    for month in range(1, 13):
        print(f"  Processing 2024-{month:02d}...", end=" ", flush=True)
        result = test_month(2024, month, config)
        if result:
            if 'error' in result:
                print(f"ERROR: {result['error']}")
            else:
                print(f"{result['trades']} trades, PF={result['pf']:.2f}, Return={result['return']*100:.1f}%")
            results.append(result)
    
    # Summary table
    print("\n" + "="*80)
    print("  MONTHLY RESULTS SUMMARY")
    print("="*80)
    
    print(f"\n  | Month    | Trades | PF   | WR    | Return | DD    | Long WR | Short WR |")
    print(f"  |----------|--------|------|-------|--------|-------|---------|----------|")
    
    total_trades = 0
    total_return = 0
    profitable_months = 0
    
    for r in results:
        if 'error' not in r:
            total_trades += r['trades']
            total_return += r['return']
            if r['return'] > 0:
                profitable_months += 1
            
            print(f"  | {r['month']}  | {r['trades']:>6} | {r['pf']:>4.2f} | {r['wr']*100:>4.1f}% | "
                  f"{r['return']*100:>5.1f}% | {r['dd']*100:>4.1f}% | {r['long_wr']*100:>6.1f}% | {r['short_wr']*100:>7.1f}% |")
        else:
            print(f"  | {r['month']}  | ERROR: {r.get('error', 'Unknown')[:40]} |")
    
    print(f"\n  SUMMARY:")
    print(f"    Total Trades: {total_trades}")
    print(f"    Total Return: {total_return*100:.1f}%")
    print(f"    Profitable Months: {profitable_months}/{len([r for r in results if 'error' not in r])}")
    
    # Identify patterns
    print("\n" + "="*80)
    print("  PATTERN ANALYSIS")
    print("="*80)
    
    valid_results = [r for r in results if 'error' not in r and r['trades'] > 0]
    
    if valid_results:
        # Best/worst months
        best = max(valid_results, key=lambda x: x['return'])
        worst = min(valid_results, key=lambda x: x['return'])
        
        print(f"\n  Best Month:  {best['month']} (Return: {best['return']*100:.1f}%, PF: {best['pf']:.2f})")
        print(f"  Worst Month: {worst['month']} (Return: {worst['return']*100:.1f}%, PF: {worst['pf']:.2f})")
        
        # Directional bias
        avg_long_wr = sum(r['long_wr'] for r in valid_results) / len(valid_results)
        avg_short_wr = sum(r['short_wr'] for r in valid_results) / len(valid_results)
        
        print(f"\n  Avg Long Win Rate:  {avg_long_wr*100:.1f}%")
        print(f"  Avg Short Win Rate: {avg_short_wr*100:.1f}%")
        
        if avg_long_wr > avg_short_wr + 0.1:
            print("  -> BULLISH BIAS detected in strategy")
        elif avg_short_wr > avg_long_wr + 0.1:
            print("  -> BEARISH BIAS detected in strategy")
        else:
            print("  -> No significant directional bias")


if __name__ == "__main__":
    main()
