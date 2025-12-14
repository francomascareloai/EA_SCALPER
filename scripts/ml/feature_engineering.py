#!/usr/bin/env python3
"""
feature_engineering.py - Generate features for ONNX direction prediction model.

BATCH 3: Creates the 15 features required by the EA's ONNX model.

Features (matching EA's COnnxBrain expectations):
    Group 1: Price Action (5)
    1. returns - (close - prev_close) / prev_close
    2. log_returns - log(close / prev_close)
    3. range_pct - (high - low) / close
    4. body_pct - abs(close - open) / (high - low)
    5. upper_shadow_pct - (high - max(open, close)) / (high - low)

    Group 2: MTF RSI (3)
    6. rsi_m5 - RSI(14) on M5 / 100
    7. rsi_m15 - RSI(14) on M15 / 100
    8. rsi_h1 - RSI(14) on H1 / 100

    Group 3: Regime (3)
    9. hurst - Hurst exponent (0-1)
    10. entropy - Shannon entropy normalized
    11. regime_code - 0=REVERTING, 0.5=RANDOM, 1=TRENDING

    Group 4: Session/Time (2)
    12. session_code - 0=ASIA, 0.25=LONDON, 0.5=OVERLAP, 0.75=NY, 1=CLOSE
    13. hour_sin - sin(2*pi*hour/24)

    Group 5: Volatility (2)
    14. atr_norm - ATR(14) / close
    15. vol_ratio - current_vol / avg_vol(20)

Usage:
    python scripts/ml/feature_engineering.py \
        --bars-m5 data/bars_m5.csv \
        --bars-m15 data/bars_m15.csv \
        --bars-h1 data/bars_h1.csv \
        --output data/features/features.parquet
"""

import argparse
import sys
from pathlib import Path
from typing import Optional, Tuple

import numpy as np
import pandas as pd
from tqdm import tqdm


# Regime thresholds
HURST_TRENDING = 0.55
HURST_REVERTING = 0.45

# Session definitions (UTC)
SESSIONS = {
    'ASIA': (0, 7),
    'LONDON': (7, 12),
    'OVERLAP': (12, 16),
    'NY': (16, 21),
    'CLOSE': (21, 24),
}

SESSION_CODES = {
    'ASIA': 0.0,
    'LONDON': 0.25,
    'OVERLAP': 0.5,
    'NY': 0.75,
    'CLOSE': 1.0,
}


def calculate_rsi(prices: pd.Series, period: int = 14) -> pd.Series:
    """Calculate RSI indicator."""
    delta = prices.diff()
    gain = delta.where(delta > 0, 0.0)
    loss = -delta.where(delta < 0, 0.0)
    
    avg_gain = gain.rolling(window=period, min_periods=1).mean()
    avg_loss = loss.rolling(window=period, min_periods=1).mean()
    
    rs = avg_gain / (avg_loss + 1e-10)
    rsi = 100 - (100 / (1 + rs))
    
    return rsi / 100  # Normalize to 0-1


def calculate_atr(high: pd.Series, low: pd.Series, close: pd.Series, 
                  period: int = 14) -> pd.Series:
    """Calculate ATR indicator."""
    prev_close = close.shift(1)
    
    tr1 = high - low
    tr2 = abs(high - prev_close)
    tr3 = abs(low - prev_close)
    
    tr = pd.concat([tr1, tr2, tr3], axis=1).max(axis=1)
    atr = tr.rolling(window=period, min_periods=1).mean()
    
    return atr


def calculate_hurst_rolling(prices: pd.Series, window: int = 100) -> pd.Series:
    """Calculate rolling Hurst exponent."""
    hurst = pd.Series(index=prices.index, dtype=float)
    hurst[:] = 0.5  # Default
    
    prices_arr = prices.values
    
    for i in range(window, len(prices_arr)):
        window_prices = prices_arr[i-window:i]
        returns = np.diff(np.log(window_prices + 1e-10))
        
        if len(returns) < 2:
            continue
        
        mean_ret = np.mean(returns)
        deviations = returns - mean_ret
        cum_dev = np.cumsum(deviations)
        
        R = np.max(cum_dev) - np.min(cum_dev)
        S = np.std(returns, ddof=1)
        
        if S > 1e-10 and R > 1e-10:
            RS = R / S
            n = len(returns)
            H = np.log(RS) / np.log(n)
            H = np.clip(H, 0, 1)
            hurst.iloc[i] = H
    
    return hurst


def calculate_shannon_entropy(returns: pd.Series, window: int = 50, 
                              bins: int = 10) -> pd.Series:
    """Calculate rolling Shannon entropy of returns."""
    entropy = pd.Series(index=returns.index, dtype=float)
    entropy[:] = 0.5  # Default (normalized)
    
    max_entropy = np.log(bins)  # Maximum possible entropy
    
    returns_arr = returns.values
    
    for i in range(window, len(returns_arr)):
        window_ret = returns_arr[i-window:i]
        
        # Remove NaN
        window_ret = window_ret[~np.isnan(window_ret)]
        if len(window_ret) < 10:
            continue
        
        # Histogram
        hist, _ = np.histogram(window_ret, bins=bins, density=True)
        hist = hist + 1e-10  # Avoid log(0)
        hist = hist / hist.sum()  # Normalize
        
        # Shannon entropy
        H = -np.sum(hist * np.log(hist))
        entropy.iloc[i] = H / max_entropy  # Normalize to 0-1
    
    return entropy


def get_session_code(hour: int) -> float:
    """Get session code from hour."""
    for session, (start, end) in SESSIONS.items():
        if session == 'CLOSE':
            if hour >= start:
                return SESSION_CODES[session]
        elif start <= hour < end:
            return SESSION_CODES[session]
    return 0.5  # Default


def generate_features(
    bars_m5: pd.DataFrame,
    bars_m15: Optional[pd.DataFrame] = None,
    bars_h1: Optional[pd.DataFrame] = None,
    hurst_window: int = 100,
    verbose: bool = True
) -> pd.DataFrame:
    """
    Generate all 15 features for the ONNX model.
    
    Args:
        bars_m5: M5 bar data with OHLCV columns
        bars_m15: Optional M15 bar data
        bars_h1: Optional H1 bar data
        hurst_window: Window for Hurst calculation
        verbose: Print progress
    
    Returns:
        DataFrame with 15 feature columns + datetime + target
    """
    if verbose:
        print("Generating features...")
    
    df = bars_m5.copy()
    
    # Ensure datetime column
    if 'datetime' not in df.columns:
        if 'Date' in df.columns and 'Time' in df.columns:
            df['datetime'] = pd.to_datetime(df['Date'].astype(str) + ' ' + df['Time'].astype(str))
        elif 'time' in df.columns:
            df['datetime'] = pd.to_datetime(df['time'])
    
    df = df.sort_values('datetime').reset_index(drop=True)
    
    # Standardize column names
    col_map = {'Open': 'open', 'High': 'high', 'Low': 'low', 'Close': 'close', 'Volume': 'volume'}
    df = df.rename(columns={k: v for k, v in col_map.items() if k in df.columns})
    
    # =========================================================================
    # GROUP 1: PRICE ACTION (5 features)
    # =========================================================================
    if verbose:
        print("  [1/5] Price action features...")
    
    # 1. Returns
    df['returns'] = df['close'].pct_change()
    
    # 2. Log returns
    df['log_returns'] = np.log(df['close'] / df['close'].shift(1))
    
    # 3. Range percentage
    df['range_pct'] = (df['high'] - df['low']) / (df['close'] + 1e-10)
    
    # 4. Body percentage
    body = abs(df['close'] - df['open'])
    bar_range = df['high'] - df['low']
    df['body_pct'] = body / (bar_range + 1e-10)
    
    # 5. Upper shadow percentage
    upper_shadow = df['high'] - df[['open', 'close']].max(axis=1)
    df['upper_shadow_pct'] = upper_shadow / (bar_range + 1e-10)
    
    # =========================================================================
    # GROUP 2: MTF RSI (3 features)
    # =========================================================================
    if verbose:
        print("  [2/5] MTF RSI features...")
    
    # 6. RSI M5
    df['rsi_m5'] = calculate_rsi(df['close'], period=14)
    
    # 7. RSI M15 (resample or use provided)
    if bars_m15 is not None and len(bars_m15) > 0:
        m15 = bars_m15.copy()
        if 'datetime' not in m15.columns:
            if 'Date' in m15.columns and 'Time' in m15.columns:
                m15['datetime'] = pd.to_datetime(m15['Date'].astype(str) + ' ' + m15['Time'].astype(str))
        m15 = m15.rename(columns={'Close': 'close'})
        m15['rsi_m15'] = calculate_rsi(m15['close'], period=14)
        m15 = m15[['datetime', 'rsi_m15']]
        m15['datetime'] = pd.to_datetime(m15['datetime'])
        df['datetime'] = pd.to_datetime(df['datetime'])
        df = pd.merge_asof(df.sort_values('datetime'), m15.sort_values('datetime'),
                          on='datetime', direction='backward')
    else:
        # Approximate from M5
        df['rsi_m15'] = calculate_rsi(df['close'].rolling(3).mean(), period=14)
    
    # 8. RSI H1
    if bars_h1 is not None and len(bars_h1) > 0:
        h1 = bars_h1.copy()
        if 'datetime' not in h1.columns:
            if 'Date' in h1.columns and 'Time' in h1.columns:
                h1['datetime'] = pd.to_datetime(h1['Date'].astype(str) + ' ' + h1['Time'].astype(str))
        h1 = h1.rename(columns={'Close': 'close'})
        h1['rsi_h1'] = calculate_rsi(h1['close'], period=14)
        h1 = h1[['datetime', 'rsi_h1']]
        h1['datetime'] = pd.to_datetime(h1['datetime'])
        df = pd.merge_asof(df.sort_values('datetime'), h1.sort_values('datetime'),
                          on='datetime', direction='backward')
    else:
        # Approximate from M5
        df['rsi_h1'] = calculate_rsi(df['close'].rolling(12).mean(), period=14)
    
    # =========================================================================
    # GROUP 3: REGIME (3 features)
    # =========================================================================
    if verbose:
        print("  [3/5] Regime features...")
    
    # 9. Hurst exponent
    df['hurst'] = calculate_hurst_rolling(df['close'], window=hurst_window)
    
    # 10. Shannon entropy
    df['entropy'] = calculate_shannon_entropy(df['returns'], window=50)
    
    # 11. Regime code
    def regime_code(h):
        if h > HURST_TRENDING:
            return 1.0  # TRENDING
        elif h < HURST_REVERTING:
            return 0.0  # REVERTING
        else:
            return 0.5  # RANDOM
    
    df['regime_code'] = df['hurst'].apply(regime_code)
    
    # =========================================================================
    # GROUP 4: SESSION/TIME (2 features)
    # =========================================================================
    if verbose:
        print("  [4/5] Session features...")
    
    # 12. Session code
    df['hour'] = df['datetime'].dt.hour
    df['session_code'] = df['hour'].apply(get_session_code)
    
    # 13. Hour sin (cyclical encoding)
    df['hour_sin'] = np.sin(2 * np.pi * df['hour'] / 24)
    
    # =========================================================================
    # GROUP 5: VOLATILITY (2 features)
    # =========================================================================
    if verbose:
        print("  [5/5] Volatility features...")
    
    # 14. ATR normalized
    atr = calculate_atr(df['high'], df['low'], df['close'], period=14)
    df['atr_norm'] = atr / (df['close'] + 1e-10)
    
    # 15. Volume ratio
    if 'volume' in df.columns and df['volume'].sum() > 0:
        avg_vol = df['volume'].rolling(window=20, min_periods=1).mean()
        df['vol_ratio'] = df['volume'] / (avg_vol + 1e-10)
    else:
        # Use range as proxy
        avg_range = bar_range.rolling(window=20, min_periods=1).mean()
        df['vol_ratio'] = bar_range / (avg_range + 1e-10)
    
    # =========================================================================
    # TARGET: Direction (for training)
    # =========================================================================
    if verbose:
        print("  Adding target...")
    
    # Target: 1 if next bar closes higher, 0 otherwise
    df['target'] = (df['close'].shift(-1) > df['close']).astype(float)
    
    # =========================================================================
    # SELECT FINAL FEATURES
    # =========================================================================
    feature_cols = [
        'datetime',
        # Group 1: Price Action
        'returns', 'log_returns', 'range_pct', 'body_pct', 'upper_shadow_pct',
        # Group 2: MTF RSI
        'rsi_m5', 'rsi_m15', 'rsi_h1',
        # Group 3: Regime
        'hurst', 'entropy', 'regime_code',
        # Group 4: Session
        'session_code', 'hour_sin',
        # Group 5: Volatility
        'atr_norm', 'vol_ratio',
        # Target
        'target'
    ]
    
    # Keep only feature columns that exist
    feature_cols = [c for c in feature_cols if c in df.columns]
    result = df[feature_cols].copy()
    
    # Drop rows with NaN in features
    result = result.dropna()
    
    if verbose:
        print(f"\nGenerated {len(result):,} samples with {len(feature_cols)-2} features")
    
    return result


def main():
    parser = argparse.ArgumentParser(
        description='Generate features for ONNX direction prediction model'
    )
    parser.add_argument(
        '--bars-m5', '-m5',
        required=True,
        help='Path to M5 bar data (CSV)'
    )
    parser.add_argument(
        '--bars-m15', '-m15',
        help='Path to M15 bar data (CSV)'
    )
    parser.add_argument(
        '--bars-h1', '-h1',
        help='Path to H1 bar data (CSV)'
    )
    parser.add_argument(
        '--output', '-o',
        default='data/features/features.parquet',
        help='Output path for features'
    )
    parser.add_argument(
        '--hurst-window', '-w',
        type=int,
        default=100,
        help='Window for Hurst calculation (default: 100)'
    )
    
    args = parser.parse_args()
    
    # Load bar data
    print(f"\nLoading M5 bars from: {args.bars_m5}")
    bars_m5 = pd.read_csv(args.bars_m5)
    print(f"  Loaded {len(bars_m5):,} M5 bars")
    
    bars_m15 = None
    if args.bars_m15:
        print(f"Loading M15 bars from: {args.bars_m15}")
        bars_m15 = pd.read_csv(args.bars_m15)
        print(f"  Loaded {len(bars_m15):,} M15 bars")
    
    bars_h1 = None
    if args.bars_h1:
        print(f"Loading H1 bars from: {args.bars_h1}")
        bars_h1 = pd.read_csv(args.bars_h1)
        print(f"  Loaded {len(bars_h1):,} H1 bars")
    
    # Generate features
    features = generate_features(
        bars_m5=bars_m5,
        bars_m15=bars_m15,
        bars_h1=bars_h1,
        hurst_window=args.hurst_window
    )
    
    # Save
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    features.to_parquet(output_path, compression='snappy', index=False)
    print(f"\nFeatures saved to: {output_path}")
    
    return 0


if __name__ == '__main__':
    sys.exit(main())
