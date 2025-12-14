#!/usr/bin/env python3
"""
Diagnose why strategy fails in certain periods
Compare market characteristics: Oct-Nov vs Dec 2024
"""
import sys
from pathlib import Path
import pandas as pd
import numpy as np
from datetime import datetime

PROJECT_ROOT = Path(__file__).parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

DATA_DIR = PROJECT_ROOT / "data" / "processed"


def analyze_period_characteristics(data_path: str, start_date: str, end_date: str):
    """Analyze market characteristics for a period"""
    print(f"\n{'='*60}")
    print(f"  Analyzing: {start_date} to {end_date}")
    print(f"{'='*60}")
    
    df = pd.read_parquet(data_path)
    
    # Filter to period
    df['datetime'] = pd.to_datetime(df['timestamp'])
    mask = (df['datetime'] >= start_date) & (df['datetime'] <= end_date)
    period_df = df[mask].copy()
    
    if len(period_df) == 0:
        print("  No data for this period")
        return None
    
    # Use existing mid_price column (spread is in points, convert to price)
    period_df['mid'] = period_df['mid_price']
    # spread column is already in the data (in points)
    
    # Resample to hourly for analysis
    period_df.set_index('datetime', inplace=True)
    hourly = period_df.resample('1h').agg({
        'mid': ['first', 'max', 'min', 'last', 'std'],
        'spread': 'mean'
    })
    hourly.columns = ['open', 'high', 'low', 'close', 'volatility', 'avg_spread']
    hourly = hourly.dropna()
    
    # Calculate metrics
    hourly['range'] = hourly['high'] - hourly['low']
    hourly['returns'] = hourly['close'].pct_change()
    hourly['direction'] = (hourly['close'] > hourly['open']).astype(int)
    
    # Daily aggregation
    daily = period_df.resample('1D').agg({
        'mid': ['first', 'max', 'min', 'last', 'std'],
        'spread': 'mean'
    })
    daily.columns = ['open', 'high', 'low', 'close', 'daily_vol', 'avg_spread']
    daily = daily.dropna()
    daily['range'] = daily['high'] - daily['low']
    daily['returns'] = daily['close'].pct_change()
    
    # Trend analysis
    price_start = hourly['close'].iloc[0]
    price_end = hourly['close'].iloc[-1]
    total_return = (price_end - price_start) / price_start
    
    # Volatility metrics
    avg_daily_range = daily['range'].mean()
    avg_hourly_vol = hourly['volatility'].mean()
    max_daily_range = daily['range'].max()
    
    # Trend consistency - count of up days vs down days
    daily['up'] = daily['close'] > daily['open']
    up_days = daily['up'].sum()
    down_days = len(daily) - up_days
    
    # Calculate rolling Hurst exponent approximation
    # Using simplified method - ratio of range to volatility
    daily['hurst_proxy'] = daily['range'] / (daily['daily_vol'] * 2.5)
    avg_hurst = daily['hurst_proxy'].mean()
    
    print(f"\n  PRICE METRICS:")
    print(f"    Start Price: ${price_start:.2f}")
    print(f"    End Price:   ${price_end:.2f}")
    print(f"    Total Return: {total_return*100:.2f}%")
    print(f"    Trend: {'UP' if total_return > 0 else 'DOWN'}")
    
    print(f"\n  VOLATILITY METRICS:")
    print(f"    Avg Daily Range: ${avg_daily_range:.2f}")
    print(f"    Max Daily Range: ${max_daily_range:.2f}")
    print(f"    Avg Hourly Vol:  ${avg_hourly_vol:.2f}")
    
    print(f"\n  TREND CONSISTENCY:")
    print(f"    Up Days:   {up_days} ({up_days/len(daily)*100:.1f}%)")
    print(f"    Down Days: {down_days} ({down_days/len(daily)*100:.1f}%)")
    print(f"    Hurst Proxy (avg): {avg_hurst:.2f}")
    print(f"      > 1.0 = trending, < 1.0 = mean-reverting")
    
    print(f"\n  SPREAD:")
    print(f"    Avg Spread: ${hourly['avg_spread'].mean():.3f}")
    
    return {
        'period': f"{start_date} to {end_date}",
        'total_return': total_return,
        'avg_daily_range': avg_daily_range,
        'max_daily_range': max_daily_range,
        'up_days': up_days,
        'down_days': down_days,
        'up_pct': up_days / len(daily),
        'hurst_proxy': avg_hurst,
    }


def main():
    print("="*70)
    print("  PERIOD FAILURE DIAGNOSIS")
    print("="*70)
    print("  Comparing market regimes between failing and profitable periods")
    
    data_2024 = str(DATA_DIR / "ticks_2024.parquet")
    
    # Period 1: October 2024 - LOSING PERIOD
    oct_stats = analyze_period_characteristics(
        data_2024, 
        "2024-10-01", 
        "2024-10-31"
    )
    
    # Period 2: November 2024 - TRANSITION
    nov_stats = analyze_period_characteristics(
        data_2024, 
        "2024-11-01", 
        "2024-11-30"
    )
    
    # Period 3: December 2024 - WINNING PERIOD
    dec_stats = analyze_period_characteristics(
        data_2024, 
        "2024-12-01", 
        "2024-12-31"
    )
    
    # Summary comparison
    print("\n" + "="*70)
    print("  SUMMARY COMPARISON")
    print("="*70)
    
    if all([oct_stats, nov_stats, dec_stats]):
        print(f"\n  | Metric          | Oct 2024    | Nov 2024    | Dec 2024    |")
        print(f"  |-----------------|-------------|-------------|-------------|")
        print(f"  | Total Return    | {oct_stats['total_return']*100:>9.2f}%  | {nov_stats['total_return']*100:>9.2f}%  | {dec_stats['total_return']*100:>9.2f}%  |")
        print(f"  | Avg Daily Range | ${oct_stats['avg_daily_range']:>9.2f}  | ${nov_stats['avg_daily_range']:>9.2f}  | ${dec_stats['avg_daily_range']:>9.2f}  |")
        print(f"  | Up Days %       | {oct_stats['up_pct']*100:>9.1f}%  | {nov_stats['up_pct']*100:>9.1f}%  | {dec_stats['up_pct']*100:>9.1f}%  |")
        print(f"  | Hurst Proxy     | {oct_stats['hurst_proxy']:>10.2f}  | {nov_stats['hurst_proxy']:>10.2f}  | {dec_stats['hurst_proxy']:>10.2f}  |")
    
    print("\n" + "="*70)
    print("  DIAGNOSIS")
    print("="*70)
    
    if dec_stats and oct_stats:
        if dec_stats['hurst_proxy'] > oct_stats['hurst_proxy']:
            print("\n  Dec has HIGHER Hurst proxy (more trending)")
            print("  -> Strategy works better in trending conditions")
        
        if dec_stats['up_pct'] > oct_stats['up_pct']:
            print("\n  Dec has MORE up days (bullish trend)")
            print("  -> Strategy may have bullish bias")
        
        if dec_stats['avg_daily_range'] != oct_stats['avg_daily_range']:
            print(f"\n  Dec daily range: ${dec_stats['avg_daily_range']:.2f}")
            print(f"  Oct daily range: ${oct_stats['avg_daily_range']:.2f}")
            if dec_stats['avg_daily_range'] > oct_stats['avg_daily_range']:
                print("  -> Higher volatility in Dec may favor SL/TP distances")
            else:
                print("  -> Lower volatility in Dec may reduce false stops")
    
    print("\n" + "="*70)
    print("  RECOMMENDATIONS")
    print("="*70)
    print("""
  1. ADD REGIME FILTER: Use Hurst exponent or similar to detect:
     - TRENDING regime (Hurst > 0.55): Enable trading
     - MEAN-REVERTING regime (Hurst < 0.45): Disable or reverse strategy
     
  2. ADD VOLATILITY FILTER: 
     - Track ATR or daily range
     - Adjust SL/TP dynamically based on volatility
     - Disable trading if volatility is abnormally high/low
     
  3. REDUCE POSITION SIZE in uncertain regimes:
     - Use Kelly fraction based on recent performance
     - Scale down when consecutive losses occur
     
  4. INVESTIGATE OCTOBER 2024:
     - Check for major news events (Fed, elections)
     - Check gold correlation with DXY during this period
""")


if __name__ == "__main__":
    main()
