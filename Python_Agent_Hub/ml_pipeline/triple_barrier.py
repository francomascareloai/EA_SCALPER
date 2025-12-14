"""
Triple Barrier Labeling Implementation
Based on: López de Prado - Advances in Financial Machine Learning

This module implements the Triple Barrier method for generating trading labels
that better reflect real trading conditions with stop-losses and take-profits.
"""

import numpy as np
import pandas as pd
from typing import Tuple, Optional, Union
from dataclasses import dataclass


@dataclass
class BarrierConfig:
    """Configuration for Triple Barrier method."""
    pt_multiplier: float = 2.0    # Take profit = pt_multiplier * volatility
    sl_multiplier: float = 1.0    # Stop loss = sl_multiplier * volatility
    max_holding_period: int = 20  # Maximum bars to hold position
    min_return_threshold: float = 0.0001  # Minimum return for non-zero label


def get_volatility(prices: pd.Series, method: str = 'atr', window: int = 14,
                   high: Optional[pd.Series] = None, low: Optional[pd.Series] = None) -> pd.Series:
    """
    Calculate volatility measure for barrier sizing.
    
    Args:
        prices: Close prices
        method: 'atr' (Average True Range) or 'std' (Standard Deviation)
        window: Lookback period
        high: High prices (required for ATR)
        low: Low prices (required for ATR)
    
    Returns:
        Volatility series
    """
    if method == 'atr':
        if high is None or low is None:
            raise ValueError("ATR requires high and low prices")
        
        tr1 = high - low
        tr2 = abs(high - prices.shift(1))
        tr3 = abs(low - prices.shift(1))
        tr = pd.concat([tr1, tr2, tr3], axis=1).max(axis=1)
        return tr.rolling(window=window).mean()
    
    elif method == 'std':
        returns = prices.pct_change()
        return returns.rolling(window=window).std() * prices
    
    else:
        raise ValueError(f"Unknown method: {method}")


def get_barriers(entry_price: float, volatility: float, 
                 config: BarrierConfig) -> Tuple[float, float]:
    """
    Calculate upper and lower barriers.
    
    Args:
        entry_price: Entry price
        volatility: Current volatility measure (ATR or std)
        config: Barrier configuration
    
    Returns:
        Tuple of (upper_barrier, lower_barrier)
    """
    upper = entry_price + config.pt_multiplier * volatility
    lower = entry_price - config.sl_multiplier * volatility
    return upper, lower


def get_first_touch(prices: pd.Series, upper: float, lower: float,
                    max_bars: int) -> Tuple[int, str]:
    """
    Find which barrier is touched first.
    
    Args:
        prices: Future prices starting from entry
        upper: Upper barrier price
        lower: Lower barrier price
        max_bars: Maximum holding period
    
    Returns:
        Tuple of (bar_index, barrier_type)
        barrier_type: 'upper', 'lower', or 'vertical'
    """
    for i, price in enumerate(prices.iloc[:max_bars]):
        if price >= upper:
            return i, 'upper'
        if price <= lower:
            return i, 'lower'
    
    return max_bars - 1, 'vertical'


def triple_barrier_labels(
    prices: pd.Series,
    volatility: pd.Series,
    config: Optional[BarrierConfig] = None,
    side: Optional[pd.Series] = None
) -> pd.DataFrame:
    """
    Generate Triple Barrier labels for the entire series.
    
    Args:
        prices: Close prices
        volatility: Volatility measure (ATR recommended)
        config: Barrier configuration (default: BarrierConfig())
        side: Optional series with +1 (long) or -1 (short) signals
              If provided, barriers are adjusted for direction
    
    Returns:
        DataFrame with columns:
        - 'label': +1 (profit), -1 (loss), 0 (timeout)
        - 'return': Return at exit
        - 'holding_period': Bars held
        - 'exit_type': 'upper', 'lower', or 'vertical'
    """
    if config is None:
        config = BarrierConfig()
    
    n = len(prices)
    results = {
        'label': np.full(n, np.nan),
        'return': np.full(n, np.nan),
        'holding_period': np.full(n, np.nan),
        'exit_type': [None] * n
    }
    
    # Process each entry point
    for i in range(n - config.max_holding_period):
        entry_price = prices.iloc[i]
        entry_vol = volatility.iloc[i]
        
        # Skip if no volatility data
        if pd.isna(entry_vol) or entry_vol <= 0:
            continue
        
        # Get barriers
        upper, lower = get_barriers(entry_price, entry_vol, config)
        
        # Adjust for side if provided
        if side is not None and not pd.isna(side.iloc[i]):
            if side.iloc[i] < 0:  # Short position
                upper, lower = lower, upper  # Swap barriers
        
        # Find first touch
        future_prices = prices.iloc[i+1:i+1+config.max_holding_period]
        touch_idx, touch_type = get_first_touch(
            future_prices, upper, lower, config.max_holding_period
        )
        
        # Calculate return
        exit_price = future_prices.iloc[touch_idx] if len(future_prices) > touch_idx else prices.iloc[i+config.max_holding_period]
        ret = (exit_price - entry_price) / entry_price
        
        # Adjust for side
        if side is not None and not pd.isna(side.iloc[i]) and side.iloc[i] < 0:
            ret = -ret
        
        # Assign label
        if touch_type == 'upper':
            label = 1
        elif touch_type == 'lower':
            label = -1
        else:  # vertical
            if abs(ret) < config.min_return_threshold:
                label = 0
            else:
                label = 1 if ret > 0 else -1
        
        results['label'][i] = label
        results['return'][i] = ret
        results['holding_period'][i] = touch_idx + 1
        results['exit_type'][i] = touch_type
    
    return pd.DataFrame(results, index=prices.index)


def meta_labeling(primary_signal: pd.Series, 
                  triple_barrier_label: pd.Series) -> pd.Series:
    """
    Generate meta-labels for bet sizing.
    
    The meta-label answers: "Should I trade this signal?"
    - 1: Primary signal was correct
    - 0: Primary signal was wrong
    
    Args:
        primary_signal: Series with +1 (buy) or -1 (sell) signals
        triple_barrier_label: Triple barrier labels (+1, -1, 0)
    
    Returns:
        Meta-labels (1 = correct, 0 = incorrect)
    """
    # Signal correct if same sign as triple barrier label
    # OR if triple barrier is 0 (neutral outcome)
    correct = (primary_signal * triple_barrier_label) > 0
    neutral = triple_barrier_label == 0
    
    meta_label = (correct | neutral).astype(int)
    
    # Where primary signal is 0 or NaN, meta-label is NaN
    meta_label[primary_signal == 0] = np.nan
    meta_label[pd.isna(primary_signal)] = np.nan
    
    return meta_label


def get_label_stats(labels: pd.DataFrame) -> dict:
    """
    Calculate statistics for triple barrier labels.
    
    Args:
        labels: DataFrame from triple_barrier_labels()
    
    Returns:
        Dictionary with label statistics
    """
    valid = labels['label'].dropna()
    
    return {
        'total_samples': len(valid),
        'positive_count': (valid == 1).sum(),
        'negative_count': (valid == -1).sum(),
        'neutral_count': (valid == 0).sum(),
        'positive_ratio': (valid == 1).mean(),
        'negative_ratio': (valid == -1).mean(),
        'neutral_ratio': (valid == 0).mean(),
        'avg_return': labels['return'].mean(),
        'avg_holding_period': labels['holding_period'].mean(),
        'exit_types': labels['exit_type'].value_counts().to_dict()
    }


# Example usage
if __name__ == "__main__":
    # Create sample data
    np.random.seed(42)
    n = 1000
    
    # Simulate price series with trend
    returns = np.random.normal(0.0001, 0.001, n)
    prices = pd.Series(100 * np.cumprod(1 + returns))
    prices.index = pd.date_range('2024-01-01', periods=n, freq='5min')
    
    # Calculate volatility (using std as proxy for ATR)
    volatility = prices.pct_change().rolling(14).std() * prices
    
    # Generate labels
    config = BarrierConfig(
        pt_multiplier=2.0,
        sl_multiplier=1.0,
        max_holding_period=20
    )
    
    labels = triple_barrier_labels(prices, volatility, config)
    stats = get_label_stats(labels)
    
    print("=== Triple Barrier Label Statistics ===")
    print(f"Total samples: {stats['total_samples']}")
    print(f"Positive (+1): {stats['positive_ratio']:.2%}")
    print(f"Negative (-1): {stats['negative_ratio']:.2%}")
    print(f"Neutral (0): {stats['neutral_ratio']:.2%}")
    print(f"Avg return: {stats['avg_return']:.4%}")
    print(f"Avg holding period: {stats['avg_holding_period']:.1f} bars")
    print(f"Exit types: {stats['exit_types']}")
