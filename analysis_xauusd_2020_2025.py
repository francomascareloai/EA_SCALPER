#!/usr/bin/env python3
"""
XAUUSD Financial Analysis 2020-2025
Agent 1: Financial Analyst
"""

import pandas as pd
import numpy as np
from pathlib import Path
from datetime import datetime

def analyze_xauusd_dataset():
    """Comprehensive analysis of XAUUSD dataset 2020-2025"""

    # Load the dataset
    data_path = Path('/home/franco/projetos/EA_SCALPER_XAUUSD/data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet')

    if not data_path.exists():
        print(f"ERROR: Dataset not found at {data_path}")
        return

    print("Loading dataset...")
    df = pd.read_parquet(data_path)

    # Filter for 2020-2025 period
    df['datetime'] = pd.to_datetime(df['datetime'])
    df_2020_2025 = df[(df['datetime'] >= '2020-01-01') & (df['datetime'] < '2026-01-01')].copy()

    print("\n" + "="*80)
    print("XAUUSD DATASET STATISTICS (2020-2025)")
    print("="*80)
    print(f"Total ticks: {len(df_2020_2025):,}")
    print(f"Date range: {df_2020_2025['datetime'].min()} to {df_2020_2025['datetime'].max()}")
    print(f"Price range: ${df_2020_2025['bid'].min():.2f} - ${df_2020_2025['bid'].max():.2f}")

    print("\n" + "-"*80)
    print("PRICE STATISTICS (Bid)")
    print("-"*80)
    print(df_2020_2025['bid'].describe())

    # Calculate annual statistics
    print("\n" + "="*80)
    print("ANNUAL VOLATILITY AND PRICE ANALYSIS")
    print("="*80)

    df_2020_2025['year'] = df_2020_2025['datetime'].dt.year

    annual_stats = []
    for year in sorted(df_2020_2025['year'].unique()):
        year_data = df_2020_2025[df_2020_2025['year'] == year].copy()

        # Calculate returns and volatility
        year_data_sorted = year_data.sort_values('datetime')
        returns = year_data_sorted['bid'].pct_change().dropna()

        # Annualized volatility (assuming continuous trading, adjusted for stride)
        volatility_annual = returns.std() * np.sqrt(252 * 24 * 60 / 20)  # Adjusted for stride 20

        # Price range
        price_min = year_data['bid'].min()
        price_max = year_data['bid'].max()
        price_range = price_max - price_min

        # Year-over-year return
        if len(year_data_sorted) > 0:
            year_start_price = year_data_sorted.iloc[0]['bid']
            year_end_price = year_data_sorted.iloc[-1]['bid']
            yoy_return = ((year_end_price - year_start_price) / year_start_price) * 100
        else:
            yoy_return = 0

        annual_stats.append({
            'Year': year,
            'Volatility_pct': volatility_annual * 100,
            'Min_Price': price_min,
            'Max_Price': price_max,
            'Range': price_range,
            'YoY_Return_pct': yoy_return,
            'Num_Ticks': len(year_data)
        })

        print(f"{year}: Vol={volatility_annual*100:6.2f}%, "
              f"Min=${price_min:8.2f}, Max=${price_max:8.2f}, "
              f"Range=${price_range:7.2f}, YoY={yoy_return:+6.2f}%, "
              f"Ticks={len(year_data):,}")

    # Volatility regime analysis
    print("\n" + "="*80)
    print("VOLATILITY REGIME ANALYSIS")
    print("="*80)

    df_sorted = df_2020_2025.sort_values('datetime').copy()
    df_sorted['returns'] = df_sorted['bid'].pct_change()

    # Rolling 20-day volatility (adjusted for stride)
    window_size = 20 * 24 * 60 // 20  # 20 days worth of ticks with stride 20
    df_sorted['volatility_rolling'] = df_sorted['returns'].rolling(window=window_size).std()

    vol_stats = df_sorted['volatility_rolling'].describe()
    print("\nRolling Volatility Statistics:")
    print(vol_stats)

    # Define regimes
    high_vol_threshold = df_sorted['volatility_rolling'].quantile(0.75)
    low_vol_threshold = df_sorted['volatility_rolling'].quantile(0.25)

    print(f"\nVolatility Regime Thresholds:")
    print(f"  High volatility (>75th percentile): {high_vol_threshold:.6f}")
    print(f"  Medium volatility (25th-75th percentile): {low_vol_threshold:.6f} - {high_vol_threshold:.6f}")
    print(f"  Low volatility (<25th percentile): {low_vol_threshold:.6f}")

    # Count regime periods
    df_sorted['regime'] = pd.cut(df_sorted['volatility_rolling'],
                                  bins=[0, low_vol_threshold, high_vol_threshold, float('inf')],
                                  labels=['Low', 'Medium', 'High'])

    regime_counts = df_sorted['regime'].value_counts()
    print(f"\nRegime Distribution:")
    for regime in ['Low', 'Medium', 'High']:
        if regime in regime_counts:
            count = regime_counts[regime]
            pct = (count / len(df_sorted[df_sorted['regime'].notna()])) * 100
            print(f"  {regime} volatility: {count:,} ticks ({pct:.1f}%)")

    # Key support and resistance levels (statistical)
    print("\n" + "="*80)
    print("STATISTICAL SUPPORT & RESISTANCE LEVELS")
    print("="*80)

    # Use price distribution to identify key levels
    price_levels = np.percentile(df_2020_2025['bid'], [5, 10, 25, 50, 75, 90, 95])
    print(f"5th percentile (strong support):    ${price_levels[0]:.2f}")
    print(f"10th percentile (support):           ${price_levels[1]:.2f}")
    print(f"25th percentile (minor support):     ${price_levels[2]:.2f}")
    print(f"50th percentile (median):            ${price_levels[3]:.2f}")
    print(f"75th percentile (minor resistance):  ${price_levels[4]:.2f}")
    print(f"90th percentile (resistance):        ${price_levels[5]:.2f}")
    print(f"95th percentile (strong resistance): ${price_levels[6]:.2f}")

    # Recent price levels (2025)
    df_2025 = df_2020_2025[df_2020_2025['year'] == 2025]
    if len(df_2025) > 0:
        print(f"\n2025 Current Levels:")
        print(f"  Latest price: ${df_2025['bid'].iloc[-1]:.2f}")
        print(f"  2025 High:    ${df_2025['bid'].max():.2f}")
        print(f"  2025 Low:     ${df_2025['bid'].min():.2f}")

    # Correlation proxy analysis (intra-market)
    print("\n" + "="*80)
    print("INTRA-MARKET CORRELATION ANALYSIS")
    print("="*80)

    # Calculate correlation between different time periods (regime persistence)
    df_sorted['hour'] = df_sorted['datetime'].dt.hour
    df_sorted['day_of_week'] = df_sorted['datetime'].dt.dayofweek

    # Hourly volatility patterns
    hourly_vol = df_sorted.groupby('hour')['returns'].std()
    print("\nHourly Volatility Patterns (Top 5 hours):")
    top_hours = hourly_vol.nlargest(5)
    for hour, vol in top_hours.items():
        print(f"  Hour {hour:02d}:00: {vol:.6f}")

    print("\nAnalysis complete!")
    print("="*80)

if __name__ == "__main__":
    analyze_xauusd_dataset()
