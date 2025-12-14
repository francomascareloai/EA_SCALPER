#!/usr/bin/env python3
"""
segment_data.py - Segment data by regime and session for targeted backtesting.

BATCH 2: This script segments processed tick/bar data into regime×session combinations
for more granular backtesting and Kelly table generation.

Features:
- Regime detection using Hurst R/S (same logic as CRegimeDetector.mqh)
- Session classification (ASIA/LONDON/OVERLAP/NY/CLOSE)
- Output segmented parquet files
- Statistics per segment

Usage:
    python scripts/backtest/segment_data.py \
        --input data/processed/ticks_2020.parquet \
        --output data/segments/ \
        --bars-m5 Python_Agent_Hub/ml_pipeline/data/Bars_2020-2025XAUUSD_ftmo-M5-No Session.csv

Output:
    data/segments/
    ├── regime_trending.parquet
    ├── regime_reverting.parquet
    ├── regime_random.parquet
    ├── session_asia.parquet
    ├── session_london.parquet
    ├── session_overlap.parquet
    ├── session_ny.parquet
    ├── session_close.parquet
    ├── trending_overlap.parquet  (best segment)
    └── SEGMENT_STATS.json
"""

import argparse
import json
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import numpy as np
import pandas as pd
from tqdm import tqdm


# Regime thresholds (matching CRegimeDetector.mqh)
HURST_TRENDING_THRESHOLD = 0.55
HURST_REVERTING_THRESHOLD = 0.45

# Session definitions (UTC)
SESSIONS = {
    'ASIA': (0, 7),      # 00:00-07:00
    'LONDON': (7, 12),   # 07:00-12:00
    'OVERLAP': (12, 16), # 12:00-16:00
    'NY': (16, 21),      # 16:00-21:00
    'CLOSE': (21, 24),   # 21:00-00:00
}


def calculate_hurst_rs(prices: np.ndarray, window: int = 100) -> float:
    """
    Calculate Hurst exponent using R/S method.
    
    Same algorithm as CRegimeDetector::CalculateHurstRS() in MQL5.
    
    Returns:
        H > 0.55: Trending
        0.45 < H < 0.55: Random walk
        H < 0.45: Mean reverting
    """
    if len(prices) < window:
        return 0.5
    
    returns = np.diff(np.log(prices + 1e-10))
    
    if len(returns) < 2:
        return 0.5
    
    mean_return = np.mean(returns)
    deviations = returns - mean_return
    cumulative_deviations = np.cumsum(deviations)
    
    R = np.max(cumulative_deviations) - np.min(cumulative_deviations)
    S = np.std(returns, ddof=1)
    
    if S > 1e-10 and R > 1e-10:
        RS = R / S
        n = len(returns)
        H = np.log(RS) / np.log(n)
        H = np.clip(H, 0, 1)
    else:
        H = 0.5
    
    return float(H)


def classify_regime(hurst: float) -> str:
    """Classify regime based on Hurst exponent."""
    if hurst > HURST_TRENDING_THRESHOLD:
        return 'TRENDING'
    elif hurst < HURST_REVERTING_THRESHOLD:
        return 'REVERTING'
    else:
        return 'RANDOM'


def get_session(hour: int) -> str:
    """Get session name from hour (UTC)."""
    for session, (start, end) in SESSIONS.items():
        if session == 'CLOSE':
            if hour >= start or hour < 0:
                return session
        elif start <= hour < end:
            return session
    return 'UNKNOWN'


def add_regime_labels(df: pd.DataFrame, window: int = 100, 
                      price_col: str = 'mid_price') -> pd.DataFrame:
    """
    Add regime labels to dataframe using rolling Hurst calculation.
    
    Args:
        df: DataFrame with price data
        window: Rolling window size for Hurst calculation
        price_col: Column name for price data
    
    Returns:
        DataFrame with 'hurst' and 'regime' columns added
    """
    print(f"Calculating rolling Hurst (window={window})...")
    
    # Get prices
    if price_col in df.columns:
        prices = df[price_col].values
    elif 'Close' in df.columns:
        prices = df['Close'].values
    elif 'bid' in df.columns and 'ask' in df.columns:
        prices = ((df['bid'] + df['ask']) / 2).values
    else:
        raise ValueError("No price column found")
    
    # Calculate rolling Hurst
    hurst_values = np.full(len(df), 0.5)
    
    # For efficiency, calculate every N rows and forward-fill
    step = max(1, window // 10)
    
    for i in tqdm(range(window, len(prices), step), desc="Hurst calculation"):
        window_prices = prices[max(0, i-window):i]
        h = calculate_hurst_rs(window_prices, window)
        # Apply to next 'step' rows
        end_idx = min(i + step, len(prices))
        hurst_values[i:end_idx] = h
    
    df = df.copy()
    df['hurst'] = hurst_values
    df['regime'] = df['hurst'].apply(classify_regime)
    
    return df


def add_session_labels(df: pd.DataFrame, datetime_col: str = 'timestamp') -> pd.DataFrame:
    """
    Add session labels to dataframe.
    
    Args:
        df: DataFrame with datetime column
        datetime_col: Column name for datetime
    
    Returns:
        DataFrame with 'session' column added
    """
    print("Adding session labels...")
    
    df = df.copy()
    
    # Find datetime column
    if datetime_col not in df.columns:
        if 'datetime' in df.columns:
            datetime_col = 'datetime'
        else:
            raise ValueError("No datetime column found")
    
    # Ensure datetime type
    if not pd.api.types.is_datetime64_any_dtype(df[datetime_col]):
        df[datetime_col] = pd.to_datetime(df[datetime_col])
    
    # Extract hour and classify session
    df['hour'] = df[datetime_col].dt.hour
    df['session'] = df['hour'].apply(get_session)
    
    return df


def segment_data(
    input_path: str,
    output_dir: str,
    bars_m5_path: Optional[str] = None,
    hurst_window: int = 100
) -> Dict:
    """
    Main segmentation function.
    
    Args:
        input_path: Path to input parquet/CSV file
        output_dir: Directory for output segments
        bars_m5_path: Optional path to M5 bar data for Hurst calculation
        hurst_window: Window size for Hurst calculation
    
    Returns:
        Dictionary with segmentation statistics
    """
    input_path = Path(input_path)
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print(f"\nInput: {input_path}")
    print(f"Output: {output_dir}")
    
    # Load data
    print("\nLoading data...")
    if input_path.suffix == '.parquet':
        df = pd.read_parquet(input_path)
    else:
        df = pd.read_csv(input_path)
    
    print(f"Loaded {len(df):,} records")
    
    # Detect datetime column or create from Date+Time
    datetime_col = None
    for col in ['timestamp', 'datetime', 'time']:
        if col in df.columns:
            datetime_col = col
            break
    
    # If no datetime found, try to create from Date + Time columns
    if datetime_col is None:
        if 'Date' in df.columns and 'Time' in df.columns:
            df['datetime'] = pd.to_datetime(df['Date'].astype(str) + ' ' + df['Time'].astype(str))
            datetime_col = 'datetime'
        elif 'Date' in df.columns:
            df['datetime'] = pd.to_datetime(df['Date'].astype(str))
            datetime_col = 'datetime'
        else:
            raise ValueError("No datetime column found")
    
    # Ensure datetime type
    if not pd.api.types.is_datetime64_any_dtype(df[datetime_col]):
        df[datetime_col] = pd.to_datetime(df[datetime_col])
    
    # Add regime labels
    df = add_regime_labels(df, window=hurst_window)
    
    # Add session labels
    df = add_session_labels(df, datetime_col=datetime_col)
    
    # Calculate statistics
    stats = {
        'input_file': str(input_path),
        'output_dir': str(output_dir),
        'total_records': len(df),
        'hurst_window': hurst_window,
        'timestamp': datetime.now().isoformat(),
        'regimes': {},
        'sessions': {},
        'cross_segments': {}
    }
    
    # Save regime segments
    print("\nSaving regime segments...")
    for regime in ['TRENDING', 'REVERTING', 'RANDOM']:
        regime_df = df[df['regime'] == regime]
        count = len(regime_df)
        pct = count / len(df) * 100
        
        stats['regimes'][regime] = {
            'count': count,
            'pct': round(pct, 2)
        }
        
        if count > 0:
            output_file = output_dir / f'regime_{regime.lower()}.parquet'
            regime_df.to_parquet(output_file, compression='snappy', index=False)
            stats['regimes'][regime]['file'] = str(output_file)
            print(f"  {regime}: {count:,} records ({pct:.1f}%)")
    
    # Save session segments
    print("\nSaving session segments...")
    for session in SESSIONS.keys():
        session_df = df[df['session'] == session]
        count = len(session_df)
        pct = count / len(df) * 100
        
        stats['sessions'][session] = {
            'count': count,
            'pct': round(pct, 2)
        }
        
        if count > 0:
            output_file = output_dir / f'session_{session.lower()}.parquet'
            session_df.to_parquet(output_file, compression='snappy', index=False)
            stats['sessions'][session]['file'] = str(output_file)
            print(f"  {session}: {count:,} records ({pct:.1f}%)")
    
    # Save cross-segments (regime × session)
    print("\nSaving cross-segments (regime × session)...")
    key_combinations = [
        ('TRENDING', 'OVERLAP'),   # Best expected
        ('TRENDING', 'LONDON'),
        ('TRENDING', 'NY'),
        ('REVERTING', 'OVERLAP'),
        ('REVERTING', 'LONDON'),
    ]
    
    for regime, session in key_combinations:
        cross_df = df[(df['regime'] == regime) & (df['session'] == session)]
        count = len(cross_df)
        pct = count / len(df) * 100
        
        key = f"{regime}_{session}"
        stats['cross_segments'][key] = {
            'count': count,
            'pct': round(pct, 2)
        }
        
        if count > 0:
            output_file = output_dir / f'{regime.lower()}_{session.lower()}.parquet'
            cross_df.to_parquet(output_file, compression='snappy', index=False)
            stats['cross_segments'][key]['file'] = str(output_file)
            print(f"  {key}: {count:,} records ({pct:.1f}%)")
    
    # Save statistics
    stats_file = output_dir / 'SEGMENT_STATS.json'
    with open(stats_file, 'w') as f:
        json.dump(stats, f, indent=2)
    
    print(f"\n{'='*60}")
    print("SEGMENTATION COMPLETE")
    print(f"{'='*60}")
    print(f"Total records: {stats['total_records']:,}")
    print(f"\nRegime distribution:")
    for regime, data in stats['regimes'].items():
        print(f"  {regime}: {data['pct']:.1f}%")
    print(f"\nSession distribution:")
    for session, data in stats['sessions'].items():
        print(f"  {session}: {data['pct']:.1f}%")
    print(f"\nStatistics saved to: {stats_file}")
    
    return stats


def main():
    parser = argparse.ArgumentParser(
        description='Segment data by regime and session for targeted backtesting'
    )
    parser.add_argument(
        '--input', '-i',
        required=True,
        help='Path to input parquet or CSV file'
    )
    parser.add_argument(
        '--output', '-o',
        default='data/segments/',
        help='Output directory for segments'
    )
    parser.add_argument(
        '--bars-m5',
        help='Optional: Path to M5 bar data'
    )
    parser.add_argument(
        '--hurst-window', '-w',
        type=int,
        default=100,
        help='Window size for Hurst calculation (default: 100)'
    )
    
    args = parser.parse_args()
    
    stats = segment_data(
        input_path=args.input,
        output_dir=args.output,
        bars_m5_path=args.bars_m5,
        hurst_window=args.hurst_window
    )
    
    return 0


if __name__ == '__main__':
    sys.exit(main())
