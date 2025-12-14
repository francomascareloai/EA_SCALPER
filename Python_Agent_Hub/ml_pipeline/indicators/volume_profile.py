"""
Volume Profile Calculator - POC, VAH, VAL
EA_SCALPER_XAUUSD - Order Flow Module

100% backtestable - uses only OHLCV data.
Based on Market Profile / Auction Market Theory (Dalton).
"""
import pandas as pd
import numpy as np
from dataclasses import dataclass
from typing import Dict, Optional, Tuple


@dataclass
class VolumeProfileResult:
    """Result of Volume Profile calculation."""
    poc: float                    # Point of Control (highest volume price)
    vah: float                    # Value Area High
    val: float                    # Value Area Low
    profile: Dict[float, float]   # Price -> Volume mapping
    value_area_pct: float         # Value area percentage (default 70%)
    total_volume: float           # Total volume in profile
    poc_volume: float             # Volume at POC
    
    @property
    def value_area_range(self) -> float:
        return self.vah - self.val
    
    def price_position(self, price: float) -> str:
        """Get position of price relative to Value Area."""
        if price > self.vah:
            return 'above_va'
        elif price < self.val:
            return 'below_va'
        elif price > self.poc:
            return 'upper_va'
        else:
            return 'lower_va'


class VolumeProfileCalculator:
    """
    Calculates Volume Profile with POC, VAH, VAL.
    
    Key Concepts:
    - POC (Point of Control): Price with highest traded volume
    - VAH (Value Area High): Upper bound of 70% volume zone
    - VAL (Value Area Low): Lower bound of 70% volume zone
    - Value Area: 70% of volume is transacted within this range
    
    Trading Applications:
    - POC acts as strong support/resistance
    - Price below VAL = oversold (potential buy)
    - Price above VAH = overbought (potential sell)
    - Confluence with SMC zones (OB/FVG) increases probability
    """
    
    def __init__(self, price_bins: int = 50, value_area_pct: float = 0.70):
        """
        Initialize calculator.
        
        Args:
            price_bins: Number of price bins for distribution
            value_area_pct: Percentage of volume for Value Area (default 70%)
        """
        self.price_bins = price_bins
        self.value_area_pct = value_area_pct
    
    def calculate(
        self, 
        df: pd.DataFrame, 
        lookback: int = 200,
        session: Optional[str] = None
    ) -> VolumeProfileResult:
        """
        Calculate Volume Profile for the last N bars.
        
        Args:
            df: DataFrame with 'high', 'low', 'close', 'volume'
            lookback: Number of bars for analysis
            session: Optional session filter ('asian', 'london', 'ny')
        
        Returns:
            VolumeProfileResult with POC, VAH, VAL
        """
        data = df.tail(lookback).copy()
        
        # Optional session filter
        if session and 'hour' in data.columns:
            data = self._filter_session(data, session)
        
        if len(data) < 10:
            return self._empty_result(df['close'].iloc[-1])
        
        # Determine price range
        price_min = data['low'].min()
        price_max = data['high'].max()
        price_range = price_max - price_min
        
        if price_range == 0:
            return self._empty_result(data['close'].iloc[-1])
        
        bin_size = price_range / self.price_bins
        
        # Distribute volume by price using TPO method
        volume_at_price = self._distribute_volume(data, price_min, bin_size)
        
        if not volume_at_price:
            return self._empty_result(data['close'].iloc[-1])
        
        # Calculate POC
        poc_bin = max(volume_at_price, key=volume_at_price.get)
        poc = price_min + (poc_bin + 0.5) * bin_size
        poc_volume = volume_at_price[poc_bin]
        
        # Calculate Value Area (70% of volume)
        total_volume = sum(volume_at_price.values())
        vah, val = self._calculate_value_area(
            volume_at_price, poc_bin, total_volume, price_min, bin_size
        )
        
        # Create profile dict with actual prices
        profile = {
            price_min + (k + 0.5) * bin_size: v 
            for k, v in volume_at_price.items()
        }
        
        return VolumeProfileResult(
            poc=poc,
            vah=vah,
            val=val,
            profile=profile,
            value_area_pct=self.value_area_pct,
            total_volume=total_volume,
            poc_volume=poc_volume
        )
    
    def _distribute_volume(
        self, 
        data: pd.DataFrame, 
        price_min: float, 
        bin_size: float
    ) -> Dict[int, float]:
        """Distribute volume across price bins."""
        volume_at_price = {}
        
        for idx in range(len(data)):
            row = data.iloc[idx]
            bar_high = row['high']
            bar_low = row['low']
            bar_vol = row['volume'] if 'volume' in row else row.get('tick_volume', 1)
            bar_range = bar_high - bar_low
            
            if bar_range == 0 or bar_vol == 0:
                # Doji - all volume at close
                bin_key = int((row['close'] - price_min) / bin_size)
                bin_key = max(0, min(bin_key, self.price_bins - 1))
                volume_at_price[bin_key] = volume_at_price.get(bin_key, 0) + bar_vol
                continue
            
            # Distribute volume across touched bins
            bins_touched = set()
            price = bar_low
            while price <= bar_high:
                bin_key = int((price - price_min) / bin_size)
                bin_key = max(0, min(bin_key, self.price_bins - 1))
                bins_touched.add(bin_key)
                price += bin_size
            
            if bins_touched:
                vol_per_bin = bar_vol / len(bins_touched)
                for bin_key in bins_touched:
                    volume_at_price[bin_key] = volume_at_price.get(bin_key, 0) + vol_per_bin
        
        return volume_at_price
    
    def _calculate_value_area(
        self,
        volume_at_price: Dict[int, float],
        poc_bin: int,
        total_volume: float,
        price_min: float,
        bin_size: float
    ) -> Tuple[float, float]:
        """Calculate Value Area by expanding from POC."""
        target_volume = total_volume * self.value_area_pct
        
        va_bins = {poc_bin}
        current_volume = volume_at_price.get(poc_bin, 0)
        
        bins_sorted = sorted(volume_at_price.keys())
        if poc_bin not in bins_sorted:
            return price_min + self.price_bins * bin_size, price_min
        
        poc_idx = bins_sorted.index(poc_bin)
        up_idx = poc_idx + 1
        down_idx = poc_idx - 1
        
        # Expand from POC, taking higher volume side first
        while current_volume < target_volume:
            up_vol = 0
            down_vol = 0
            
            if up_idx < len(bins_sorted):
                up_vol = volume_at_price.get(bins_sorted[up_idx], 0)
            if down_idx >= 0:
                down_vol = volume_at_price.get(bins_sorted[down_idx], 0)
            
            if up_vol == 0 and down_vol == 0:
                break
            
            if up_vol >= down_vol and up_idx < len(bins_sorted):
                va_bins.add(bins_sorted[up_idx])
                current_volume += up_vol
                up_idx += 1
            elif down_idx >= 0:
                va_bins.add(bins_sorted[down_idx])
                current_volume += down_vol
                down_idx -= 1
            else:
                break
        
        # Calculate VAH and VAL
        vah_bin = max(va_bins)
        val_bin = min(va_bins)
        vah = price_min + (vah_bin + 1) * bin_size
        val = price_min + val_bin * bin_size
        
        return vah, val
    
    def _filter_session(self, data: pd.DataFrame, session: str) -> pd.DataFrame:
        """Filter data by trading session."""
        if session == 'asian':
            return data[(data.index.hour >= 0) & (data.index.hour < 8)]
        elif session == 'london':
            return data[(data.index.hour >= 8) & (data.index.hour < 16)]
        elif session == 'ny':
            return data[(data.index.hour >= 13) & (data.index.hour < 22)]
        return data
    
    def _empty_result(self, price: float) -> VolumeProfileResult:
        """Return empty result when calculation fails."""
        return VolumeProfileResult(
            poc=price,
            vah=price,
            val=price,
            profile={},
            value_area_pct=self.value_area_pct,
            total_volume=0,
            poc_volume=0
        )
    
    def get_features(
        self, 
        df: pd.DataFrame, 
        current_price: Optional[float] = None,
        lookback: int = 200
    ) -> Dict[str, float]:
        """
        Get ML features based on Volume Profile.
        
        Returns:
            Dict with normalized features for ML model
        """
        if current_price is None:
            current_price = df['close'].iloc[-1]
        
        result = self.calculate(df, lookback)
        atr = self._calculate_atr(df)
        
        if atr == 0:
            atr = 1  # Avoid division by zero
        
        return {
            'vp_poc_distance': (current_price - result.poc) / atr,
            'vp_vah_distance': (current_price - result.vah) / atr,
            'vp_val_distance': (current_price - result.val) / atr,
            'vp_in_value_area': 1.0 if result.val <= current_price <= result.vah else 0.0,
            'vp_above_poc': 1.0 if current_price > result.poc else 0.0,
            'vp_va_width': result.value_area_range / atr,
            'vp_poc_strength': result.poc_volume / result.total_volume if result.total_volume > 0 else 0,
        }
    
    def _calculate_atr(self, df: pd.DataFrame, period: int = 14) -> float:
        """Calculate ATR for normalization."""
        high = df['high']
        low = df['low']
        close = df['close'].shift(1)
        
        tr = pd.concat([
            high - low,
            (high - close).abs(),
            (low - close).abs()
        ], axis=1).max(axis=1)
        
        atr = tr.rolling(period).mean().iloc[-1]
        return atr if not pd.isna(atr) else (high - low).mean()
    
    def get_trading_signal(
        self, 
        df: pd.DataFrame,
        current_price: Optional[float] = None
    ) -> Dict[str, any]:
        """
        Get trading signal based on Volume Profile.
        
        Returns:
            Dict with signal type and confidence
        """
        if current_price is None:
            current_price = df['close'].iloc[-1]
        
        result = self.calculate(df)
        
        signal = {
            'type': 'neutral',
            'confidence': 0.0,
            'poc': result.poc,
            'vah': result.vah,
            'val': result.val,
            'position': result.price_position(current_price)
        }
        
        # Price at/near POC - strong level
        atr = self._calculate_atr(df)
        poc_distance = abs(current_price - result.poc)
        
        if poc_distance < atr * 0.5:
            signal['type'] = 'poc_test'
            signal['confidence'] = 1 - (poc_distance / (atr * 0.5))
        
        # Price below VAL - potential long
        elif current_price < result.val:
            distance_below = result.val - current_price
            signal['type'] = 'below_value_area'
            signal['confidence'] = min(1.0, distance_below / atr)
            signal['bias'] = 'bullish'  # Mean reversion expected
        
        # Price above VAH - potential short
        elif current_price > result.vah:
            distance_above = current_price - result.vah
            signal['type'] = 'above_value_area'
            signal['confidence'] = min(1.0, distance_above / atr)
            signal['bias'] = 'bearish'  # Mean reversion expected
        
        return signal


if __name__ == '__main__':
    # Test with sample data
    np.random.seed(42)
    
    # Generate sample OHLCV data
    dates = pd.date_range('2024-01-01', periods=500, freq='15min')
    base_price = 2000
    
    prices = [base_price]
    for _ in range(499):
        change = np.random.randn() * 2
        prices.append(prices[-1] + change)
    
    df = pd.DataFrame({
        'open': prices,
        'high': [p + abs(np.random.randn()) for p in prices],
        'low': [p - abs(np.random.randn()) for p in prices],
        'close': [p + np.random.randn() * 0.5 for p in prices],
        'volume': [np.random.randint(100, 1000) for _ in prices]
    }, index=dates)
    
    # Calculate Volume Profile
    calc = VolumeProfileCalculator(price_bins=50)
    result = calc.calculate(df, lookback=200)
    
    print("Volume Profile Analysis")
    print("=" * 40)
    print(f"POC:             ${result.poc:.2f}")
    print(f"VAH:             ${result.vah:.2f}")
    print(f"VAL:             ${result.val:.2f}")
    print(f"Value Area:      ${result.value_area_range:.2f}")
    print(f"Total Volume:    {result.total_volume:,.0f}")
    print(f"POC Volume:      {result.poc_volume:,.0f} ({result.poc_volume/result.total_volume*100:.1f}%)")
    
    # Get features
    current_price = df['close'].iloc[-1]
    features = calc.get_features(df, current_price)
    
    print(f"\nML Features (price ${current_price:.2f}):")
    for k, v in features.items():
        print(f"  {k}: {v:.4f}")
    
    # Get signal
    signal = calc.get_trading_signal(df)
    print(f"\nTrading Signal:")
    print(f"  Type: {signal['type']}")
    print(f"  Position: {signal['position']}")
    print(f"  Confidence: {signal['confidence']:.2f}")
