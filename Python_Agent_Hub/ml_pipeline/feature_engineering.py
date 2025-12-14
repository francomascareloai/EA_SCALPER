"""
Feature Engineering Pipeline for Direction Model
EA_SCALPER_XAUUSD - Singularity Edition

Generates 15+ features for LSTM training with multi-timeframe support.
"""

import pandas as pd
import numpy as np
from pathlib import Path
from typing import Optional, Tuple
import warnings
warnings.filterwarnings('ignore')

DATA_DIR = Path(__file__).parent / "data"


def calculate_rsi(prices: pd.Series, period: int = 14) -> pd.Series:
    """Calculate RSI indicator."""
    delta = prices.diff()
    gain = (delta.where(delta > 0, 0)).rolling(window=period).mean()
    loss = (-delta.where(delta < 0, 0)).rolling(window=period).mean()
    rs = gain / loss
    return 100 - (100 / (1 + rs))


def calculate_atr(high: pd.Series, low: pd.Series, close: pd.Series, period: int = 14) -> pd.Series:
    """Calculate Average True Range."""
    tr1 = high - low
    tr2 = abs(high - close.shift())
    tr3 = abs(low - close.shift())
    tr = pd.concat([tr1, tr2, tr3], axis=1).max(axis=1)
    return tr.rolling(window=period).mean()


def calculate_bollinger_position(close: pd.Series, period: int = 20, std: int = 2) -> pd.Series:
    """Calculate position within Bollinger Bands (-1 to 1)."""
    ma = close.rolling(window=period).mean()
    std_dev = close.rolling(window=period).std()
    upper = ma + (std_dev * std)
    lower = ma - (std_dev * std)
    return (close - ma) / (upper - lower)


def calculate_hurst(prices: pd.Series, window: int = 100) -> pd.Series:
    """Calculate rolling Hurst exponent using R/S analysis."""
    def hurst_rs(ts):
        if len(ts) < 20:
            return 0.5
        try:
            ts = np.array(ts)
            returns = np.diff(np.log(ts))
            if len(returns) < 10:
                return 0.5
            
            max_k = min(len(returns) // 2, 50)
            min_k = 10
            
            if max_k <= min_k:
                return 0.5
            
            rs_list = []
            n_list = []
            
            for n in range(min_k, max_k + 1):
                subseries_count = len(returns) // n
                if subseries_count < 1:
                    continue
                    
                rs_sub = []
                for i in range(subseries_count):
                    sub = returns[i * n:(i + 1) * n]
                    mean_sub = np.mean(sub)
                    cumdev = np.cumsum(sub - mean_sub)
                    R = np.max(cumdev) - np.min(cumdev)
                    S = np.std(sub, ddof=1)
                    if S > 0:
                        rs_sub.append(R / S)
                
                if rs_sub:
                    rs_list.append(np.mean(rs_sub))
                    n_list.append(n)
            
            if len(rs_list) < 3:
                return 0.5
            
            log_n = np.log(n_list)
            log_rs = np.log(rs_list)
            H = np.polyfit(log_n, log_rs, 1)[0]
            return np.clip(H, 0, 1)
        except:
            return 0.5
    
    return prices.rolling(window=window).apply(hurst_rs, raw=False)


def calculate_entropy(returns: pd.Series, window: int = 100, bins: int = 10) -> pd.Series:
    """Calculate rolling Shannon entropy of returns."""
    def entropy(x):
        if len(x) < 10:
            return 2.0
        try:
            hist, _ = np.histogram(x, bins=bins, density=True)
            hist = hist[hist > 0]
            if len(hist) == 0:
                return 2.0
            return -np.sum(hist * np.log2(hist + 1e-10))
        except:
            return 2.0
    
    return returns.rolling(window=window).apply(entropy, raw=False)


def get_session(hour: int) -> int:
    """Get trading session: 0=Asia, 1=London, 2=NY."""
    if hour < 7:
        return 0  # Asia
    elif hour < 15:
        return 1  # London
    else:
        return 2  # NY


def create_features(df: pd.DataFrame, timeframe: str = "M15") -> pd.DataFrame:
    """
    Create all 15 features for the Direction Model.
    
    Features:
    1. returns - Simple returns
    2. log_returns - Log returns
    3. range_pct - Bar range as % of close
    4. rsi - RSI(14)
    5. atr_norm - ATR normalized by close
    6. ma_dist - Distance from MA(20) as %
    7. bb_pos - Position in Bollinger Bands
    8. hurst - Hurst exponent (regime)
    9. entropy - Shannon entropy (noise)
    10. session - Trading session (0,1,2)
    11. hour_sin - Hour cyclical (sin)
    12. hour_cos - Hour cyclical (cos)
    13. spread_norm - Spread normalized
    14. tick_intensity - Tick count normalized
    15. volatility_regime - ATR z-score
    """
    print(f"Creating features for {timeframe}...")
    
    f = pd.DataFrame(index=df.index)
    
    # 1-2. Returns
    f['returns'] = df['close'].pct_change()
    f['log_returns'] = np.log(df['close'] / df['close'].shift(1))
    
    # 3. Range
    f['range_pct'] = (df['high'] - df['low']) / df['close']
    
    # 4. RSI
    f['rsi'] = calculate_rsi(df['close'], 14) / 100  # Normalize to 0-1
    
    # 5. ATR Normalized
    atr = calculate_atr(df['high'], df['low'], df['close'], 14)
    f['atr_norm'] = atr / df['close']
    
    # 6. MA Distance
    ma20 = df['close'].rolling(20).mean()
    f['ma_dist'] = (df['close'] - ma20) / ma20
    
    # 7. Bollinger Position
    f['bb_pos'] = calculate_bollinger_position(df['close'], 20, 2)
    
    # 8. Hurst Exponent (computationally expensive)
    print("  Calculating Hurst exponent (this takes a while)...")
    f['hurst'] = calculate_hurst(df['close'], 100)
    
    # 9. Entropy
    print("  Calculating Entropy...")
    f['entropy'] = calculate_entropy(f['returns'].fillna(0), 100, 10) / 4  # Normalize
    
    # 10-12. Temporal features
    f['session'] = df.index.hour.map(get_session)
    f['hour_sin'] = np.sin(2 * np.pi * df.index.hour / 24)
    f['hour_cos'] = np.cos(2 * np.pi * df.index.hour / 24)
    
    # 13-14. Microstructure (from tick data)
    if 'spread_mean' in df.columns:
        f['spread_norm'] = df['spread_mean'] / df['close'] * 1000  # Normalize
    else:
        f['spread_norm'] = 0.0
    
    if 'tick_count' in df.columns:
        f['tick_intensity'] = df['tick_count'] / df['tick_count'].rolling(100).mean()
    else:
        f['tick_intensity'] = 1.0
    
    # 15. Volatility Regime
    atr_mean = atr.rolling(100).mean()
    atr_std = atr.rolling(100).std()
    f['volatility_regime'] = (atr - atr_mean) / (atr_std + 1e-10)
    
    # Add prefix for multi-timeframe
    f.columns = [f"{timeframe}_{col}" for col in f.columns]
    
    return f


def create_target(df: pd.DataFrame, horizon: int = 5, threshold: float = 0.001) -> pd.Series:
    """
    Create target variable: direction in next N bars.
    
    Returns:
        0 = Bearish (price down > threshold)
        1 = Bullish (price up > threshold)
        2 = Neutral (change < threshold) - optional, can be filtered
    """
    future_return = df['close'].shift(-horizon) / df['close'] - 1
    
    target = pd.Series(index=df.index, dtype=int)
    target[future_return > threshold] = 1   # Bullish
    target[future_return < -threshold] = 0  # Bearish
    target[(future_return >= -threshold) & (future_return <= threshold)] = 2  # Neutral
    
    return target


def load_and_prepare_data(
    timeframes: list = ["M5", "M15", "H1"],
    target_tf: str = "M15",
    horizon: int = 5
) -> Tuple[pd.DataFrame, pd.Series]:
    """
    Load data from multiple timeframes and create feature matrix.
    
    Args:
        timeframes: List of timeframes to load
        target_tf: Timeframe to use for target calculation
        horizon: Number of bars ahead for target
    
    Returns:
        X: Feature DataFrame
        y: Target Series
    """
    print("="*60)
    print("FEATURE ENGINEERING PIPELINE")
    print("="*60)
    
    all_features = []
    target_df = None
    
    for tf in timeframes:
        filepath = DATA_DIR / f"XAUUSD_{tf}_2020-2025.csv"
        
        if not filepath.exists():
            print(f"Warning: {filepath} not found, skipping {tf}")
            continue
        
        print(f"\nLoading {tf}...")
        df = pd.read_csv(filepath, parse_dates=['datetime'], index_col='datetime')
        
        # Remove empty bars
        df = df[df['volume'] > 0]
        print(f"  Loaded {len(df):,} bars")
        
        # Create features
        features = create_features(df, tf)
        all_features.append(features)
        
        # Store target timeframe data
        if tf == target_tf:
            target_df = df.copy()
    
    # Merge all features on datetime
    print("\nMerging features...")
    X = all_features[0]
    for feat_df in all_features[1:]:
        X = X.join(feat_df, how='outer')
    
    # Forward fill for multi-timeframe alignment
    X = X.ffill()
    
    # Create target
    print("Creating target variable...")
    y = create_target(target_df, horizon=horizon)
    
    # Align X and y
    common_idx = X.index.intersection(y.index)
    X = X.loc[common_idx]
    y = y.loc[common_idx]
    
    # Drop NaN rows
    valid_mask = ~(X.isna().any(axis=1) | y.isna())
    X = X[valid_mask]
    y = y[valid_mask]
    
    print(f"\nFinal dataset:")
    print(f"  Features: {X.shape[1]}")
    print(f"  Samples: {len(X):,}")
    print(f"  Target distribution:")
    print(f"    Bearish (0): {(y == 0).sum():,} ({100*(y == 0).mean():.1f}%)")
    print(f"    Bullish (1): {(y == 1).sum():,} ({100*(y == 1).mean():.1f}%)")
    print(f"    Neutral (2): {(y == 2).sum():,} ({100*(y == 2).mean():.1f}%)")
    
    return X, y


def save_dataset(X: pd.DataFrame, y: pd.Series, name: str = "training_dataset"):
    """Save processed dataset."""
    output_path = DATA_DIR / f"{name}.parquet"
    
    dataset = X.copy()
    dataset['target'] = y
    dataset.to_parquet(output_path)
    
    print(f"\nDataset saved to {output_path}")
    print(f"Size: {output_path.stat().st_size / (1024**2):.1f} MB")
    
    return output_path


if __name__ == "__main__":
    # Create features using M15 as base with M5 and H1 for context
    X, y = load_and_prepare_data(
        timeframes=["M15", "H1"],  # Start with M15 + H1 (M5 is very large)
        target_tf="M15",
        horizon=5  # Predict 5 bars ahead (~1.25 hours)
    )
    
    # Save for training
    save_dataset(X, y, "XAUUSD_ML_dataset_M15_H1")
    
    print("\n" + "="*60)
    print("FEATURE ENGINEERING COMPLETE!")
    print("="*60)
    print("\nFeatures created:")
    for col in X.columns:
        print(f"  - {col}")
