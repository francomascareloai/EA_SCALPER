#!/usr/bin/env python3
"""
SMC/ICT Components for Python Backtesting
==========================================
Port of the MQL5 EA logic to Python for accurate backtesting.

Components:
1. Structure Analyzer - HH/HL/LH/LL, BOS, CHoCH
2. Order Block Detector - Institutional OBs
3. FVG Detector - Fair Value Gaps
4. Liquidity Sweep Detector - BSL/SSL pools

Author: FORGE
Date: 2025-12-01
"""

import numpy as np
import pandas as pd
from dataclasses import dataclass, field
from typing import List, Optional, Tuple
from enum import Enum
from datetime import datetime


# =============================================================================
# ENUMERATIONS
# =============================================================================

class MarketBias(Enum):
    BULLISH = 0
    BEARISH = 1
    RANGING = 2
    TRANSITION = 3


class StructureBreak(Enum):
    NONE = 0
    BOS = 1      # Break of Structure (continuation)
    CHOCH = 2    # Change of Character (reversal)
    SWEEP = 3    # Liquidity sweep (fake break)


class OBType(Enum):
    BULLISH = 0
    BEARISH = 1


class FVGType(Enum):
    BULLISH = 0
    BEARISH = 1


class LiquidityType(Enum):
    NONE = 0
    BSL = 1  # Buy-Side Liquidity (above highs)
    SSL = 2  # Sell-Side Liquidity (below lows)


# =============================================================================
# DATA STRUCTURES
# =============================================================================

@dataclass
class SwingPoint:
    time: datetime
    price: float
    bar_index: int
    is_high: bool
    is_broken: bool = False
    break_time: Optional[datetime] = None


@dataclass
class OrderBlock:
    time: datetime
    ob_type: OBType
    top: float
    bottom: float
    entry_price: float  # Optimal entry (usually 50% of OB)
    strength: float     # 0-100
    is_valid: bool = True
    is_mitigated: bool = False
    mitigation_time: Optional[datetime] = None


@dataclass
class FairValueGap:
    time: datetime
    fvg_type: FVGType
    top: float
    bottom: float
    entry_price: float  # 50% fill level
    strength: float     # 0-100
    is_filled: bool = False
    fill_percentage: float = 0.0


@dataclass
class LiquidityPool:
    level: float
    pool_type: LiquidityType
    touch_count: int
    first_touch: datetime
    last_touch: datetime
    strength: float
    is_equal_level: bool
    is_swept: bool = False
    sweep_time: Optional[datetime] = None


@dataclass
class SweepEvent:
    pool: LiquidityPool
    sweep_price: float
    sweep_depth: float
    sweep_time: datetime
    has_rejection: bool
    rejection_size: float


# =============================================================================
# STRUCTURE ANALYZER
# =============================================================================

class StructureAnalyzer:
    """
    Market Structure Analysis - HH/HL/LH/LL, BOS, CHoCH
    Identifies market bias and structure breaks.
    """
    
    def __init__(self, swing_strength: int = 3, equal_tolerance: float = 0.5):
        self.swing_strength = swing_strength  # Bars on each side for swing
        self.equal_tolerance = equal_tolerance  # Points for equal levels
        self.swing_highs: List[SwingPoint] = []
        self.swing_lows: List[SwingPoint] = []
        self.current_bias = MarketBias.RANGING
        self.last_break = StructureBreak.NONE
        
    def analyze(self, df: pd.DataFrame) -> pd.DataFrame:
        """Add structure analysis to dataframe"""
        df = df.copy()
        
        # Find swing points
        df['swing_high'] = self._find_swing_highs(df)
        df['swing_low'] = self._find_swing_lows(df)
        
        # Determine structure (HH/HL or LH/LL)
        df['structure'] = self._classify_structure(df)
        
        # Detect BOS and CHoCH
        df['bos'] = False
        df['choch'] = False
        df['bias'] = MarketBias.RANGING.value
        
        last_swing_high = None
        last_swing_low = None
        prev_swing_high = None
        prev_swing_low = None
        current_bias = MarketBias.RANGING
        
        for i in range(len(df)):
            # Update swing points
            if df['swing_high'].iloc[i]:
                prev_swing_high = last_swing_high
                last_swing_high = df['high'].iloc[i]
                
            if df['swing_low'].iloc[i]:
                prev_swing_low = last_swing_low
                last_swing_low = df['low'].iloc[i]
            
            # Check for structure breaks
            if last_swing_high is not None and last_swing_low is not None:
                close = df['close'].iloc[i]
                
                # BOS - Break of Structure (continuation)
                if current_bias == MarketBias.BULLISH:
                    if close > last_swing_high:  # Break above swing high
                        df.loc[df.index[i], 'bos'] = True
                elif current_bias == MarketBias.BEARISH:
                    if close < last_swing_low:  # Break below swing low
                        df.loc[df.index[i], 'bos'] = True
                
                # CHoCH - Change of Character (reversal)
                if current_bias == MarketBias.BULLISH:
                    if close < last_swing_low:  # Break below in uptrend
                        df.loc[df.index[i], 'choch'] = True
                        current_bias = MarketBias.BEARISH
                elif current_bias == MarketBias.BEARISH:
                    if close > last_swing_high:  # Break above in downtrend
                        df.loc[df.index[i], 'choch'] = True
                        current_bias = MarketBias.BULLISH
                
                # Determine bias from structure
                if prev_swing_high is not None and prev_swing_low is not None:
                    if last_swing_high > prev_swing_high and last_swing_low > prev_swing_low:
                        current_bias = MarketBias.BULLISH
                    elif last_swing_high < prev_swing_high and last_swing_low < prev_swing_low:
                        current_bias = MarketBias.BEARISH
            
            df.loc[df.index[i], 'bias'] = current_bias.value
        
        return df
    
    def _find_swing_highs(self, df: pd.DataFrame) -> pd.Series:
        """Find swing highs (local maxima)"""
        n = self.swing_strength
        highs = df['high'].values
        swing_highs = pd.Series(False, index=df.index)
        
        for i in range(n, len(highs) - n):
            is_swing = True
            for j in range(1, n + 1):
                if highs[i] <= highs[i - j] or highs[i] <= highs[i + j]:
                    is_swing = False
                    break
            swing_highs.iloc[i] = is_swing
        
        return swing_highs
    
    def _find_swing_lows(self, df: pd.DataFrame) -> pd.Series:
        """Find swing lows (local minima)"""
        n = self.swing_strength
        lows = df['low'].values
        swing_lows = pd.Series(False, index=df.index)
        
        for i in range(n, len(lows) - n):
            is_swing = True
            for j in range(1, n + 1):
                if lows[i] >= lows[i - j] or lows[i] >= lows[i + j]:
                    is_swing = False
                    break
            swing_lows.iloc[i] = is_swing
        
        return swing_lows
    
    def _classify_structure(self, df: pd.DataFrame) -> pd.Series:
        """Classify each bar's structure context"""
        # Simplified - just track if we're making HH/HL or LH/LL
        return pd.Series('NEUTRAL', index=df.index)


# =============================================================================
# ORDER BLOCK DETECTOR
# =============================================================================

class OrderBlockDetector:
    """
    Order Block Detection - Institutional supply/demand zones.
    
    Bullish OB: Last bearish candle before strong bullish move
    Bearish OB: Last bullish candle before strong bearish move
    """
    
    def __init__(self, displacement_mult: float = 2.0, min_body_ratio: float = 0.5):
        self.displacement_mult = displacement_mult  # ATR multiplier for displacement
        self.min_body_ratio = min_body_ratio  # Min body/range ratio
        self.order_blocks: List[OrderBlock] = []
        
    def detect(self, df: pd.DataFrame) -> pd.DataFrame:
        """Detect order blocks and add to dataframe"""
        df = df.copy()
        df['ob_bullish'] = False
        df['ob_bearish'] = False
        df['ob_bullish_zone_top'] = np.nan
        df['ob_bullish_zone_bottom'] = np.nan
        df['ob_bearish_zone_top'] = np.nan
        df['ob_bearish_zone_bottom'] = np.nan
        
        atr = df['atr'].values if 'atr' in df.columns else self._calculate_atr(df)
        
        for i in range(5, len(df) - 1):
            # Check for bullish OB
            # Pattern: Bearish candle followed by strong bullish displacement
            if self._is_bearish_candle(df, i) and self._has_bullish_displacement(df, i, atr[i]):
                df.loc[df.index[i], 'ob_bullish'] = True
                df.loc[df.index[i], 'ob_bullish_zone_top'] = df['open'].iloc[i]
                df.loc[df.index[i], 'ob_bullish_zone_bottom'] = df['low'].iloc[i]
            
            # Check for bearish OB
            # Pattern: Bullish candle followed by strong bearish displacement
            if self._is_bullish_candle(df, i) and self._has_bearish_displacement(df, i, atr[i]):
                df.loc[df.index[i], 'ob_bearish'] = True
                df.loc[df.index[i], 'ob_bearish_zone_top'] = df['high'].iloc[i]
                df.loc[df.index[i], 'ob_bearish_zone_bottom'] = df['open'].iloc[i]
        
        # Forward fill OB zones for proximity checking
        df['ob_bullish_zone_top'] = df['ob_bullish_zone_top'].ffill()
        df['ob_bullish_zone_bottom'] = df['ob_bullish_zone_bottom'].ffill()
        df['ob_bearish_zone_top'] = df['ob_bearish_zone_top'].ffill()
        df['ob_bearish_zone_bottom'] = df['ob_bearish_zone_bottom'].ffill()
        
        # Check if price is in OB zone
        df['in_bullish_ob'] = (df['low'] <= df['ob_bullish_zone_top']) & (df['high'] >= df['ob_bullish_zone_bottom'])
        df['in_bearish_ob'] = (df['high'] >= df['ob_bearish_zone_bottom']) & (df['low'] <= df['ob_bearish_zone_top'])
        
        return df
    
    def _is_bearish_candle(self, df: pd.DataFrame, i: int) -> bool:
        """Check if candle is bearish with sufficient body"""
        open_p = df['open'].iloc[i]
        close = df['close'].iloc[i]
        high = df['high'].iloc[i]
        low = df['low'].iloc[i]
        
        if close >= open_p:
            return False
        
        body = open_p - close
        range_ = high - low
        return body / range_ >= self.min_body_ratio if range_ > 0 else False
    
    def _is_bullish_candle(self, df: pd.DataFrame, i: int) -> bool:
        """Check if candle is bullish with sufficient body"""
        open_p = df['open'].iloc[i]
        close = df['close'].iloc[i]
        high = df['high'].iloc[i]
        low = df['low'].iloc[i]
        
        if close <= open_p:
            return False
        
        body = close - open_p
        range_ = high - low
        return body / range_ >= self.min_body_ratio if range_ > 0 else False
    
    def _has_bullish_displacement(self, df: pd.DataFrame, i: int, atr: float) -> bool:
        """Check for strong bullish move after index"""
        if i + 3 >= len(df):
            return False
        
        # Look at next 3 candles for displacement
        high_after = df['high'].iloc[i+1:i+4].max()
        close_at = df['close'].iloc[i]
        
        displacement = high_after - close_at
        return displacement >= atr * self.displacement_mult
    
    def _has_bearish_displacement(self, df: pd.DataFrame, i: int, atr: float) -> bool:
        """Check for strong bearish move after index"""
        if i + 3 >= len(df):
            return False
        
        low_after = df['low'].iloc[i+1:i+4].min()
        close_at = df['close'].iloc[i]
        
        displacement = close_at - low_after
        return displacement >= atr * self.displacement_mult
    
    def _calculate_atr(self, df: pd.DataFrame, period: int = 14) -> np.ndarray:
        """Calculate ATR if not present"""
        tr = np.maximum(
            df['high'] - df['low'],
            np.maximum(
                abs(df['high'] - df['close'].shift(1)),
                abs(df['low'] - df['close'].shift(1))
            )
        )
        return tr.rolling(period).mean().fillna(tr).values


# =============================================================================
# FVG DETECTOR
# =============================================================================

class FVGDetector:
    """
    Fair Value Gap Detection - Price imbalances.
    
    Bullish FVG: Gap between candle 1 high and candle 3 low (in uptrend)
    Bearish FVG: Gap between candle 1 low and candle 3 high (in downtrend)
    """
    
    def __init__(self, min_gap_points: float = 0.5, max_gap_points: float = 10.0):
        self.min_gap_points = min_gap_points
        self.max_gap_points = max_gap_points
        
    def detect(self, df: pd.DataFrame) -> pd.DataFrame:
        """Detect FVGs and add to dataframe"""
        df = df.copy()
        df['fvg_bullish'] = False
        df['fvg_bearish'] = False
        df['fvg_bullish_top'] = np.nan
        df['fvg_bullish_bottom'] = np.nan
        df['fvg_bearish_top'] = np.nan
        df['fvg_bearish_bottom'] = np.nan
        
        for i in range(2, len(df)):
            # Bullish FVG: Gap up
            # Candle 1 high < Candle 3 low (gap between them)
            c1_high = df['high'].iloc[i-2]
            c3_low = df['low'].iloc[i]
            
            if c3_low > c1_high:
                gap = c3_low - c1_high
                if self.min_gap_points <= gap <= self.max_gap_points:
                    df.loc[df.index[i-1], 'fvg_bullish'] = True
                    df.loc[df.index[i-1], 'fvg_bullish_top'] = c3_low
                    df.loc[df.index[i-1], 'fvg_bullish_bottom'] = c1_high
            
            # Bearish FVG: Gap down
            # Candle 1 low > Candle 3 high (gap between them)
            c1_low = df['low'].iloc[i-2]
            c3_high = df['high'].iloc[i]
            
            if c1_low > c3_high:
                gap = c1_low - c3_high
                if self.min_gap_points <= gap <= self.max_gap_points:
                    df.loc[df.index[i-1], 'fvg_bearish'] = True
                    df.loc[df.index[i-1], 'fvg_bearish_top'] = c1_low
                    df.loc[df.index[i-1], 'fvg_bearish_bottom'] = c3_high
        
        # Forward fill FVG zones
        df['fvg_bullish_top'] = df['fvg_bullish_top'].ffill()
        df['fvg_bullish_bottom'] = df['fvg_bullish_bottom'].ffill()
        df['fvg_bearish_top'] = df['fvg_bearish_top'].ffill()
        df['fvg_bearish_bottom'] = df['fvg_bearish_bottom'].ffill()
        
        # Check if price is in FVG zone
        df['in_bullish_fvg'] = (df['low'] <= df['fvg_bullish_top']) & (df['high'] >= df['fvg_bullish_bottom'])
        df['in_bearish_fvg'] = (df['high'] >= df['fvg_bearish_bottom']) & (df['low'] <= df['fvg_bearish_top'])
        
        return df


# =============================================================================
# LIQUIDITY SWEEP DETECTOR
# =============================================================================

class LiquiditySweepDetector:
    """
    Liquidity Sweep Detection - BSL/SSL pools.
    
    BSL: Buy-side liquidity (stop losses above highs)
    SSL: Sell-side liquidity (stop losses below lows)
    """
    
    def __init__(self, equal_tolerance: float = 0.3, min_touches: int = 2,
                 lookback: int = 50, sweep_threshold: float = 0.5):
        self.equal_tolerance = equal_tolerance
        self.min_touches = min_touches
        self.lookback = lookback
        self.sweep_threshold = sweep_threshold
        
    def detect(self, df: pd.DataFrame) -> pd.DataFrame:
        """Detect liquidity pools and sweeps"""
        df = df.copy()
        df['bsl_level'] = np.nan
        df['ssl_level'] = np.nan
        df['bsl_sweep'] = False
        df['ssl_sweep'] = False
        df['sweep_rejection'] = False
        
        # Find equal highs (BSL)
        df['equal_high'] = self._find_equal_levels(df, 'high')
        
        # Find equal lows (SSL)
        df['equal_low'] = self._find_equal_levels(df, 'low')
        
        # Track liquidity pools and detect sweeps
        bsl_pools = []
        ssl_pools = []
        
        for i in range(self.lookback, len(df)):
            # Update BSL pools
            if df['equal_high'].iloc[i]:
                bsl_pools.append({
                    'level': df['high'].iloc[i],
                    'time': df.index[i],
                    'swept': False
                })
            
            # Update SSL pools  
            if df['equal_low'].iloc[i]:
                ssl_pools.append({
                    'level': df['low'].iloc[i],
                    'time': df.index[i],
                    'swept': False
                })
            
            # Check for BSL sweep (price goes above, then rejects)
            for pool in bsl_pools:
                if not pool['swept'] and df['high'].iloc[i] > pool['level'] + self.sweep_threshold:
                    # Check for rejection (close below the level)
                    if df['close'].iloc[i] < pool['level']:
                        df.loc[df.index[i], 'bsl_sweep'] = True
                        df.loc[df.index[i], 'sweep_rejection'] = True
                        pool['swept'] = True
            
            # Check for SSL sweep (price goes below, then rejects)
            for pool in ssl_pools:
                if not pool['swept'] and df['low'].iloc[i] < pool['level'] - self.sweep_threshold:
                    # Check for rejection (close above the level)
                    if df['close'].iloc[i] > pool['level']:
                        df.loc[df.index[i], 'ssl_sweep'] = True
                        df.loc[df.index[i], 'sweep_rejection'] = True
                        pool['swept'] = True
            
            # Clean old pools
            bsl_pools = [p for p in bsl_pools if (df.index[i] - p['time']).days < 5]
            ssl_pools = [p for p in ssl_pools if (df.index[i] - p['time']).days < 5]
        
        return df
    
    def _find_equal_levels(self, df: pd.DataFrame, col: str) -> pd.Series:
        """Find equal highs or lows"""
        result = pd.Series(False, index=df.index)
        values = df[col].values
        
        for i in range(1, len(values) - 1):
            # Look back for equal levels
            for j in range(max(0, i - self.lookback), i):
                if abs(values[i] - values[j]) <= self.equal_tolerance:
                    result.iloc[i] = True
                    break
        
        return result


# =============================================================================
# PREMIUM/DISCOUNT ZONES
# =============================================================================

class PremiumDiscountAnalyzer:
    """
    Premium/Discount Zone Analysis.
    
    Premium zone: Upper 50% of range (good to sell)
    Discount zone: Lower 50% of range (good to buy)
    """
    
    def __init__(self, lookback: int = 50):
        self.lookback = lookback
        
    def analyze(self, df: pd.DataFrame) -> pd.DataFrame:
        """Add premium/discount analysis to dataframe"""
        df = df.copy()
        
        # Calculate range high/low over lookback
        df['range_high'] = df['high'].rolling(self.lookback).max()
        df['range_low'] = df['low'].rolling(self.lookback).min()
        df['equilibrium'] = (df['range_high'] + df['range_low']) / 2
        
        # Determine zone
        df['in_premium'] = df['close'] > df['equilibrium']
        df['in_discount'] = df['close'] < df['equilibrium']
        
        # Calculate position in range (0-1)
        df['range_position'] = (df['close'] - df['range_low']) / (df['range_high'] - df['range_low'])
        df['range_position'] = df['range_position'].clip(0, 1)
        
        return df


# =============================================================================
# CONFLUENCE CALCULATOR
# =============================================================================

class ConfluenceCalculator:
    """
    Calculate confluence score combining all SMC components.
    Mirrors the CConfluenceScorer from the MQL5 EA.
    """
    
    # Weights (sum to 100)
    WEIGHTS = {
        'structure': 20,     # Market structure alignment
        'order_block': 18,   # Price at/near OB
        'fvg': 15,           # Price at/near FVG
        'liquidity': 15,     # Liquidity sweep
        'premium_discount': 12,  # Premium/Discount zone
        'bias': 10,          # Overall bias alignment
        'bos_choch': 10,     # Recent BOS/CHoCH
    }
    
    def calculate(self, row: pd.Series, direction: str) -> float:
        """
        Calculate confluence score for a potential trade.
        
        Args:
            row: DataFrame row with all SMC indicators
            direction: 'BUY' or 'SELL'
            
        Returns:
            Score 0-100
        """
        score = 0.0
        
        if direction == 'BUY':
            # Structure: Bullish bias
            if row.get('bias', 2) == MarketBias.BULLISH.value:
                score += self.WEIGHTS['structure']
            elif row.get('bias', 2) == MarketBias.RANGING.value:
                score += self.WEIGHTS['structure'] * 0.5
            
            # Order Block: Price in bullish OB
            if row.get('in_bullish_ob', False):
                score += self.WEIGHTS['order_block']
            
            # FVG: Price in bullish FVG
            if row.get('in_bullish_fvg', False):
                score += self.WEIGHTS['fvg']
            
            # Liquidity: SSL sweep (good for buy)
            if row.get('ssl_sweep', False):
                score += self.WEIGHTS['liquidity']
            
            # Premium/Discount: In discount zone (good for buy)
            if row.get('in_discount', False):
                score += self.WEIGHTS['premium_discount']
            elif row.get('range_position', 0.5) < 0.4:
                score += self.WEIGHTS['premium_discount'] * 0.7
            
            # BOS/CHoCH: Recent bullish CHoCH
            if row.get('choch', False) and row.get('bias', 2) == MarketBias.BULLISH.value:
                score += self.WEIGHTS['bos_choch']
            elif row.get('bos', False) and row.get('bias', 2) == MarketBias.BULLISH.value:
                score += self.WEIGHTS['bos_choch'] * 0.7
        
        else:  # SELL
            # Structure: Bearish bias
            if row.get('bias', 2) == MarketBias.BEARISH.value:
                score += self.WEIGHTS['structure']
            elif row.get('bias', 2) == MarketBias.RANGING.value:
                score += self.WEIGHTS['structure'] * 0.5
            
            # Order Block: Price in bearish OB
            if row.get('in_bearish_ob', False):
                score += self.WEIGHTS['order_block']
            
            # FVG: Price in bearish FVG
            if row.get('in_bearish_fvg', False):
                score += self.WEIGHTS['fvg']
            
            # Liquidity: BSL sweep (good for sell)
            if row.get('bsl_sweep', False):
                score += self.WEIGHTS['liquidity']
            
            # Premium/Discount: In premium zone (good for sell)
            if row.get('in_premium', False):
                score += self.WEIGHTS['premium_discount']
            elif row.get('range_position', 0.5) > 0.6:
                score += self.WEIGHTS['premium_discount'] * 0.7
            
            # BOS/CHoCH: Recent bearish CHoCH
            if row.get('choch', False) and row.get('bias', 2) == MarketBias.BEARISH.value:
                score += self.WEIGHTS['bos_choch']
            elif row.get('bos', False) and row.get('bias', 2) == MarketBias.BEARISH.value:
                score += self.WEIGHTS['bos_choch'] * 0.7
        
        return min(100, score)


# =============================================================================
# COMBINED SMC ANALYZER
# =============================================================================

class SMCAnalyzer:
    """
    Combined SMC/ICT Analysis.
    Runs all components and adds results to dataframe.
    """
    
    def __init__(self):
        self.structure = StructureAnalyzer(swing_strength=3)
        self.order_blocks = OrderBlockDetector(displacement_mult=2.0)
        self.fvg = FVGDetector(min_gap_points=0.3, max_gap_points=15.0)
        self.liquidity = LiquiditySweepDetector(equal_tolerance=0.5)
        self.premium_discount = PremiumDiscountAnalyzer(lookback=50)
        self.confluence = ConfluenceCalculator()
    
    def analyze(self, df: pd.DataFrame) -> pd.DataFrame:
        """Run all SMC analysis on dataframe"""
        # Calculate ATR first (needed by other components)
        df['tr'] = np.maximum(
            df['high'] - df['low'],
            np.maximum(
                abs(df['high'] - df['close'].shift(1)),
                abs(df['low'] - df['close'].shift(1))
            )
        )
        df['atr'] = df['tr'].rolling(14).mean()
        
        # Run all analyzers
        df = self.structure.analyze(df)
        df = self.order_blocks.detect(df)
        df = self.fvg.detect(df)
        df = self.liquidity.detect(df)
        df = self.premium_discount.analyze(df)
        
        # Calculate confluence scores
        df['score_buy'] = df.apply(lambda row: self.confluence.calculate(row, 'BUY'), axis=1)
        df['score_sell'] = df.apply(lambda row: self.confluence.calculate(row, 'SELL'), axis=1)
        
        return df.dropna()


if __name__ == "__main__":
    # Quick test
    print("SMC Components loaded successfully")
    print(f"Available: StructureAnalyzer, OrderBlockDetector, FVGDetector, LiquiditySweepDetector")
