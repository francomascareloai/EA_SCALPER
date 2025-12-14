"""
Volume Delta Calculator - Order Flow Analysis
EA_SCALPER_XAUUSD - Order Flow Module

Implements Tick Rule (Lee & Ready 1991) for delta calculation.
Provides both real tick-based and OHLCV approximation methods.
"""
import pandas as pd
import numpy as np
from dataclasses import dataclass
from typing import Dict, Optional, Tuple, List


@dataclass
class DeltaResult:
    """Result of delta calculation."""
    delta: float          # Buy Volume - Sell Volume
    buy_volume: float     # Estimated buy volume
    sell_volume: float    # Estimated sell volume
    delta_pct: float      # Delta as percentage of total
    
    @property
    def total_volume(self) -> float:
        return self.buy_volume + self.sell_volume
    
    @property
    def buy_ratio(self) -> float:
        return self.buy_volume / self.total_volume if self.total_volume > 0 else 0.5
    
    @property
    def imbalance(self) -> str:
        if self.delta_pct > 0.3:
            return 'strong_buying'
        elif self.delta_pct > 0.1:
            return 'buying'
        elif self.delta_pct < -0.3:
            return 'strong_selling'
        elif self.delta_pct < -0.1:
            return 'selling'
        return 'balanced'


class VolumeDeltaCalculator:
    """
    Calculates Volume Delta using Tick Rule.
    
    The Tick Rule (Lee & Ready 1991):
    - If price upticks → classify as buyer-initiated
    - If price downticks → classify as seller-initiated
    - If unchanged → use previous classification
    
    This is an approximation but academically validated for most applications.
    
    Trading Applications:
    - Delta aligned with price = trend confirmation
    - Delta divergence = potential reversal
    - High delta on breakout = genuine breakout
    """
    
    def __init__(self):
        self.last_direction = 0  # 1 = buy, -1 = sell
    
    def calculate_from_ticks(self, ticks_df: pd.DataFrame) -> DeltaResult:
        """
        Calculate delta from actual tick data.
        
        Args:
            ticks_df: DataFrame with 'price' and optionally 'volume'
                     (from MT5's CopyTicks)
        
        Returns:
            DeltaResult with buy/sell breakdown
        """
        if len(ticks_df) < 2:
            return DeltaResult(0, 0, 0, 0)
        
        prices = ticks_df['price'].values
        volumes = ticks_df['volume'].values if 'volume' in ticks_df.columns else np.ones(len(ticks_df))
        
        buy_vol = 0.0
        sell_vol = 0.0
        last_direction = 0
        
        for i in range(1, len(prices)):
            price_change = prices[i] - prices[i-1]
            vol = volumes[i]
            
            if price_change > 0:
                buy_vol += vol
                last_direction = 1
            elif price_change < 0:
                sell_vol += vol
                last_direction = -1
            else:
                # Same price - use last direction
                if last_direction == 1:
                    buy_vol += vol
                elif last_direction == -1:
                    sell_vol += vol
                else:
                    # No direction yet - split 50/50
                    buy_vol += vol / 2
                    sell_vol += vol / 2
        
        total = buy_vol + sell_vol
        delta = buy_vol - sell_vol
        delta_pct = delta / total if total > 0 else 0
        
        return DeltaResult(
            delta=delta,
            buy_volume=buy_vol,
            sell_volume=sell_vol,
            delta_pct=delta_pct
        )
    
    def calculate_from_ohlcv(self, df: pd.DataFrame) -> pd.DataFrame:
        """
        Approximate delta using OHLCV data (for backtesting).
        
        Logic:
        - Bullish candle (close > open): more volume is buy-side
        - Bearish candle (close < open): more volume is sell-side
        - Proportion based on close position within the range
        
        This is less accurate than tick-based but enables backtesting.
        
        Args:
            df: DataFrame with OHLCV data
        
        Returns:
            DataFrame with delta columns added
        """
        result = df.copy()
        
        # Calculate close position in range (0 = low, 1 = high)
        range_size = result['high'] - result['low']
        
        # Handle zero range (doji)
        close_position = np.where(
            range_size > 0,
            (result['close'] - result['low']) / range_size,
            0.5  # Doji = 50/50
        )
        
        # Get volume column
        vol_col = 'volume' if 'volume' in result.columns else 'tick_volume'
        volume = result[vol_col] if vol_col in result.columns else pd.Series(1, index=result.index)
        
        # Estimate buy/sell volume
        result['buy_volume_est'] = volume * close_position
        result['sell_volume_est'] = volume * (1 - close_position)
        result['delta_est'] = result['buy_volume_est'] - result['sell_volume_est']
        result['delta_pct'] = result['delta_est'] / volume
        result['delta_pct'] = result['delta_pct'].fillna(0)
        
        # Cumulative delta (CVD - Cumulative Volume Delta)
        result['cumulative_delta'] = result['delta_est'].cumsum()
        
        # Delta momentum (rate of change)
        result['delta_roc'] = result['cumulative_delta'].diff(5)
        
        # Delta moving average
        result['delta_ma'] = result['delta_pct'].rolling(20).mean()
        
        return result
    
    def calculate_bar_delta(
        self, 
        open_price: float, 
        high: float, 
        low: float, 
        close: float, 
        volume: float
    ) -> DeltaResult:
        """
        Calculate delta for a single bar (real-time use).
        
        Args:
            open_price, high, low, close, volume: Bar data
        
        Returns:
            DeltaResult for this bar
        """
        bar_range = high - low
        
        if bar_range == 0:
            return DeltaResult(0, volume / 2, volume / 2, 0)
        
        close_position = (close - low) / bar_range
        buy_vol = volume * close_position
        sell_vol = volume * (1 - close_position)
        delta = buy_vol - sell_vol
        
        return DeltaResult(
            delta=delta,
            buy_volume=buy_vol,
            sell_volume=sell_vol,
            delta_pct=delta / volume if volume > 0 else 0
        )
    
    def detect_divergence(
        self, 
        df: pd.DataFrame, 
        lookback: int = 20
    ) -> Dict[str, any]:
        """
        Detect divergence between price and cumulative delta.
        
        Divergences often precede reversals:
        - Bullish divergence: price making lows, delta making highs
        - Bearish divergence: price making highs, delta making lows
        """
        df_delta = self.calculate_from_ohlcv(df)
        recent = df_delta.tail(lookback)
        
        if len(recent) < lookback:
            return {'divergence': 'none', 'strength': 0}
        
        # Price trend
        price_start = recent['close'].iloc[0]
        price_end = recent['close'].iloc[-1]
        price_change_pct = (price_end - price_start) / price_start
        
        # Delta trend
        delta_start = recent['cumulative_delta'].iloc[0]
        delta_end = recent['cumulative_delta'].iloc[-1]
        delta_change = delta_end - delta_start
        
        # Normalize delta change
        avg_vol = recent['volume'].mean() if 'volume' in recent.columns else 1
        delta_change_norm = delta_change / (avg_vol * lookback)
        
        divergence = 'none'
        strength = 0
        
        # Bearish divergence: price up, delta down
        if price_change_pct > 0.01 and delta_change_norm < -0.1:
            divergence = 'bearish'
            strength = min(1.0, abs(price_change_pct) + abs(delta_change_norm))
        
        # Bullish divergence: price down, delta up
        elif price_change_pct < -0.01 and delta_change_norm > 0.1:
            divergence = 'bullish'
            strength = min(1.0, abs(price_change_pct) + abs(delta_change_norm))
        
        return {
            'divergence': divergence,
            'strength': strength,
            'price_change': price_change_pct,
            'delta_change': delta_change_norm
        }
    
    def get_features(self, df: pd.DataFrame) -> Dict[str, float]:
        """
        Get ML features based on Volume Delta.
        
        Returns:
            Dict with normalized features for ML model
        """
        df_delta = self.calculate_from_ohlcv(df)
        
        # Current values
        current_delta_pct = df_delta['delta_pct'].iloc[-1]
        delta_ma = df_delta['delta_ma'].iloc[-1]
        
        # Cumulative delta normalized
        cum_delta = df_delta['cumulative_delta'].iloc[-1]
        cum_delta_norm = cum_delta / df_delta['cumulative_delta'].abs().max() if cum_delta != 0 else 0
        
        # Delta ROC normalized
        delta_roc = df_delta['delta_roc'].iloc[-1]
        vol_mean = df['volume'].mean() if 'volume' in df.columns else 1
        delta_roc_norm = delta_roc / (vol_mean * 5) if vol_mean > 0 else 0
        
        # Divergence
        div = self.detect_divergence(df)
        divergence_value = 0
        if div['divergence'] == 'bullish':
            divergence_value = div['strength']
        elif div['divergence'] == 'bearish':
            divergence_value = -div['strength']
        
        # Delta trend (is delta increasing or decreasing?)
        delta_trend = (df_delta['cumulative_delta'].iloc[-1] - df_delta['cumulative_delta'].iloc[-10]) / abs(df_delta['cumulative_delta'].iloc[-10] + 1)
        
        return {
            'delta_current': np.clip(current_delta_pct, -1, 1),
            'delta_ma20': np.clip(delta_ma, -1, 1) if not pd.isna(delta_ma) else 0,
            'delta_cumulative_norm': np.clip(cum_delta_norm, -1, 1),
            'delta_roc_norm': np.clip(delta_roc_norm, -2, 2),
            'delta_divergence': np.clip(divergence_value, -1, 1),
            'delta_trend': np.clip(delta_trend, -2, 2) if not pd.isna(delta_trend) else 0,
        }
    
    def get_trading_signal(self, df: pd.DataFrame) -> Dict[str, any]:
        """
        Get trading signal based on Volume Delta analysis.
        """
        df_delta = self.calculate_from_ohlcv(df)
        div = self.detect_divergence(df)
        
        current_delta = df_delta['delta_pct'].iloc[-1]
        delta_ma = df_delta['delta_ma'].iloc[-1]
        
        signal = {
            'type': 'neutral',
            'confidence': 0.0,
            'delta_current': current_delta,
            'delta_ma': delta_ma,
            'divergence': div
        }
        
        # Strong buying pressure
        if current_delta > 0.3 and delta_ma > 0.1:
            signal['type'] = 'strong_buying'
            signal['confidence'] = min(1.0, current_delta)
            signal['bias'] = 'bullish'
        
        # Strong selling pressure
        elif current_delta < -0.3 and delta_ma < -0.1:
            signal['type'] = 'strong_selling'
            signal['confidence'] = min(1.0, abs(current_delta))
            signal['bias'] = 'bearish'
        
        # Divergence signals (higher priority)
        if div['divergence'] != 'none' and div['strength'] > 0.5:
            signal['type'] = f"{div['divergence']}_divergence"
            signal['confidence'] = div['strength']
            signal['bias'] = 'bullish' if div['divergence'] == 'bullish' else 'bearish'
        
        return signal


if __name__ == '__main__':
    # Test with sample data
    np.random.seed(42)
    
    # Generate sample OHLCV data with trend
    dates = pd.date_range('2024-01-01', periods=500, freq='15min')
    base_price = 2000
    
    prices = [base_price]
    trend = 0.1  # Slight uptrend
    for _ in range(499):
        change = np.random.randn() * 2 + trend
        prices.append(prices[-1] + change)
    
    df = pd.DataFrame({
        'open': prices,
        'high': [p + abs(np.random.randn() * 2) for p in prices],
        'low': [p - abs(np.random.randn() * 2) for p in prices],
        'close': [p + np.random.randn() * 0.5 for p in prices],
        'volume': [np.random.randint(100, 1000) for _ in prices]
    }, index=dates)
    
    # Calculate delta
    calc = VolumeDeltaCalculator()
    df_with_delta = calc.calculate_from_ohlcv(df)
    
    print("Volume Delta Analysis")
    print("=" * 40)
    print(f"Current Delta %:     {df_with_delta['delta_pct'].iloc[-1]:.3f}")
    print(f"Delta MA(20):        {df_with_delta['delta_ma'].iloc[-1]:.3f}")
    print(f"Cumulative Delta:    {df_with_delta['cumulative_delta'].iloc[-1]:,.0f}")
    print(f"Delta ROC(5):        {df_with_delta['delta_roc'].iloc[-1]:,.0f}")
    
    # Detect divergence
    div = calc.detect_divergence(df)
    print(f"\nDivergence Analysis:")
    print(f"  Type:     {div['divergence']}")
    print(f"  Strength: {div['strength']:.2f}")
    
    # Get features
    features = calc.get_features(df)
    print(f"\nML Features:")
    for k, v in features.items():
        print(f"  {k}: {v:.4f}")
    
    # Get signal
    signal = calc.get_trading_signal(df)
    print(f"\nTrading Signal:")
    print(f"  Type: {signal['type']}")
    print(f"  Confidence: {signal['confidence']:.2f}")
    if 'bias' in signal:
        print(f"  Bias: {signal['bias']}")
