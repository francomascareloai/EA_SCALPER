"""
Fibonacci Analyzer - EA_SCALPER_XAUUSD P1 Enhancement
======================================================
Golden Pocket detection, Extensions for TPs, Cluster analysis.

Based on ARGUS Research (2025-12-01):
- SSRN Paper (Shanaev & Gibson 2022): 38.2%, 50%, 61.8% statistically significant
- Golden Pocket (50%-61.8%) is institutional accumulation zone
- Extensions 127.2%, 161.8% are standard TP levels

Author: FORGE v3.1
Date: 2025-12-01
"""

import numpy as np
from dataclasses import dataclass, field
from typing import List, Tuple, Optional, Dict
from enum import IntEnum


class FibLevel(IntEnum):
    """Fibonacci levels with statistical significance."""
    L236 = 236   # 23.6% - AVOID (reduces predictive power per SSRN)
    L382 = 382   # 38.2% - USE (shallow pullback)
    L500 = 500   # 50.0% - USE (psychological)
    L618 = 618   # 61.8% - USE (golden ratio)
    L650 = 650   # 65.0% - USE (golden pocket upper)
    L705 = 705   # 70.5% - USE (optimal entry)
    L786 = 786   # 78.6% - CAUTION (deep retracement)
    
    # Extensions
    E1272 = 1272  # 127.2% - TP1
    E1618 = 1618  # 161.8% - TP2 (golden extension)
    E2000 = 2000  # 200.0% - TP3


@dataclass
class FibonacciLevels:
    """Calculated Fibonacci levels from swing."""
    swing_high: float = 0.0
    swing_low: float = 0.0
    is_bullish: bool = True  # True if retracement from swing low to high
    
    # Retracement levels (for entries)
    level_236: float = 0.0
    level_382: float = 0.0
    level_500: float = 0.0
    level_618: float = 0.0
    level_650: float = 0.0
    level_705: float = 0.0
    level_786: float = 0.0
    
    # Extension levels (for TPs)
    ext_1272: float = 0.0
    ext_1618: float = 0.0
    ext_2000: float = 0.0
    
    # Golden Pocket zone
    golden_pocket_low: float = 0.0
    golden_pocket_high: float = 0.0
    
    is_valid: bool = False


@dataclass
class FibCluster:
    """Fibonacci cluster (multiple fibs converging)."""
    price_level: float = 0.0
    fib_count: int = 0           # How many fibs converge here
    levels_converging: List[float] = field(default_factory=list)
    strength: int = 0            # 1-5 based on count
    tolerance: float = 0.0       # Points tolerance used


@dataclass 
class FibAnalysisResult:
    """Complete Fibonacci analysis result."""
    # Current price position
    in_golden_pocket: bool = False
    near_fib_level: bool = False
    nearest_fib_level: float = 0.0
    nearest_fib_name: str = ""
    distance_to_nearest: float = 0.0
    distance_in_atr: float = 0.0
    
    # Scores
    fib_score: float = 50.0       # 0-100 score for confluence
    golden_pocket_score: float = 0.0
    
    # Extensions for TPs
    tp1_fib: float = 0.0         # 127.2%
    tp2_fib: float = 0.0         # 161.8%
    tp3_fib: float = 0.0         # 200.0%
    
    # Clusters
    clusters: List[FibCluster] = field(default_factory=list)
    near_cluster: bool = False
    
    # Raw levels
    levels: FibonacciLevels = field(default_factory=FibonacciLevels)
    
    is_valid: bool = False


class FibonacciAnalyzer:
    """
    Complete Fibonacci analysis for XAUUSD trading.
    
    Features:
    - Golden Pocket detection (50%-61.8%/65%)
    - Extension levels for TPs (127.2%, 161.8%, 200%)
    - Cluster detection (multiple swings converging)
    - Score calculation for confluence
    """
    
    # Valid levels (per SSRN research)
    VALID_LEVELS = [0.382, 0.500, 0.618, 0.705]
    
    # Levels to AVOID (reduce predictive power)
    AVOID_LEVELS = [0.236, 0.764, 0.786]
    
    def __init__(self, 
                 swing_lookback: int = 5,
                 cluster_tolerance: float = 20.0,
                 golden_pocket_lower: float = 0.50,
                 golden_pocket_upper: float = 0.65):
        """
        Initialize Fibonacci Analyzer.
        
        Args:
            swing_lookback: Bars to check for swing high/low
            cluster_tolerance: Points tolerance for cluster detection
            golden_pocket_lower: Lower bound of golden pocket (default 50%)
            golden_pocket_upper: Upper bound of golden pocket (default 65%)
        """
        self.swing_lookback = swing_lookback
        self.cluster_tolerance = cluster_tolerance
        self.golden_pocket_lower = golden_pocket_lower
        self.golden_pocket_upper = golden_pocket_upper
    
    def find_swing_high(self, highs: np.ndarray, lookback: int = None) -> Tuple[int, float]:
        """Find most recent swing high."""
        if lookback is None:
            lookback = self.swing_lookback
        
        if len(highs) < lookback * 2 + 1:
            return -1, 0.0
        
        for i in range(lookback, len(highs) - lookback):
            is_swing = True
            for j in range(1, lookback + 1):
                if highs[i] <= highs[i - j] or highs[i] <= highs[i + j]:
                    is_swing = False
                    break
            if is_swing:
                return i, float(highs[i])
        
        # Fallback: highest point in last N bars
        idx = np.argmax(highs[-50:]) if len(highs) >= 50 else np.argmax(highs)
        return len(highs) - 50 + idx if len(highs) >= 50 else idx, float(highs[idx])
    
    def find_swing_low(self, lows: np.ndarray, lookback: int = None) -> Tuple[int, float]:
        """Find most recent swing low."""
        if lookback is None:
            lookback = self.swing_lookback
        
        if len(lows) < lookback * 2 + 1:
            return -1, 0.0
        
        for i in range(lookback, len(lows) - lookback):
            is_swing = True
            for j in range(1, lookback + 1):
                if lows[i] >= lows[i - j] or lows[i] >= lows[i + j]:
                    is_swing = False
                    break
            if is_swing:
                return i, float(lows[i])
        
        # Fallback: lowest point in last N bars
        idx = np.argmin(lows[-50:]) if len(lows) >= 50 else np.argmin(lows)
        return len(lows) - 50 + idx if len(lows) >= 50 else idx, float(lows[idx])
    
    def calculate_levels(self, swing_high: float, swing_low: float, 
                         is_bullish: bool = True) -> FibonacciLevels:
        """
        Calculate all Fibonacci levels from swing.
        
        Args:
            swing_high: Swing high price
            swing_low: Swing low price
            is_bullish: True for bullish setup (price retracing down)
        """
        levels = FibonacciLevels()
        levels.swing_high = swing_high
        levels.swing_low = swing_low
        levels.is_bullish = is_bullish
        
        range_size = swing_high - swing_low
        if range_size <= 0:
            return levels
        
        if is_bullish:
            # Bullish: price came up, now retracing down
            # Fib levels are BELOW swing high
            levels.level_236 = swing_high - range_size * 0.236
            levels.level_382 = swing_high - range_size * 0.382
            levels.level_500 = swing_high - range_size * 0.500
            levels.level_618 = swing_high - range_size * 0.618
            levels.level_650 = swing_high - range_size * 0.650
            levels.level_705 = swing_high - range_size * 0.705
            levels.level_786 = swing_high - range_size * 0.786
            
            # Extensions ABOVE swing high
            levels.ext_1272 = swing_high + range_size * 0.272
            levels.ext_1618 = swing_high + range_size * 0.618
            levels.ext_2000 = swing_high + range_size * 1.000
            
            # Golden pocket (between 50% and 65%)
            levels.golden_pocket_high = levels.level_500
            levels.golden_pocket_low = levels.level_650
        else:
            # Bearish: price came down, now retracing up
            # Fib levels are ABOVE swing low
            levels.level_236 = swing_low + range_size * 0.236
            levels.level_382 = swing_low + range_size * 0.382
            levels.level_500 = swing_low + range_size * 0.500
            levels.level_618 = swing_low + range_size * 0.618
            levels.level_650 = swing_low + range_size * 0.650
            levels.level_705 = swing_low + range_size * 0.705
            levels.level_786 = swing_low + range_size * 0.786
            
            # Extensions BELOW swing low
            levels.ext_1272 = swing_low - range_size * 0.272
            levels.ext_1618 = swing_low - range_size * 0.618
            levels.ext_2000 = swing_low - range_size * 1.000
            
            # Golden pocket (between 50% and 65%)
            levels.golden_pocket_low = levels.level_500
            levels.golden_pocket_high = levels.level_650
        
        levels.is_valid = True
        return levels
    
    def is_in_golden_pocket(self, price: float, levels: FibonacciLevels) -> bool:
        """Check if price is in golden pocket zone."""
        if not levels.is_valid:
            return False
        
        low = min(levels.golden_pocket_low, levels.golden_pocket_high)
        high = max(levels.golden_pocket_low, levels.golden_pocket_high)
        
        return low <= price <= high
    
    def get_nearest_fib_level(self, price: float, levels: FibonacciLevels, 
                               atr: float) -> Tuple[float, str, float]:
        """
        Get nearest Fibonacci level.
        
        Returns:
            (level_price, level_name, distance_in_atr)
        """
        if not levels.is_valid:
            return 0.0, "", float('inf')
        
        fib_levels = [
            (levels.level_382, "38.2%"),
            (levels.level_500, "50.0%"),
            (levels.level_618, "61.8%"),
            (levels.level_705, "70.5%"),
        ]
        
        nearest = None
        min_dist = float('inf')
        
        for level_price, level_name in fib_levels:
            dist = abs(price - level_price)
            if dist < min_dist:
                min_dist = dist
                nearest = (level_price, level_name)
        
        if nearest is None:
            return 0.0, "", float('inf')
        
        dist_in_atr = min_dist / atr if atr > 0 else float('inf')
        return nearest[0], nearest[1], dist_in_atr
    
    def find_clusters(self, highs: np.ndarray, lows: np.ndarray, 
                      num_swings: int = 3) -> List[FibCluster]:
        """
        Find Fibonacci clusters (multiple fibs converging).
        
        Multiple swing pairs generating Fib at same price = high probability zone.
        """
        clusters = []
        all_fib_levels = []
        
        # Find multiple swings
        swings = []
        for i in range(num_swings):
            start_idx = i * 20
            end_idx = min(start_idx + 50, len(highs))
            
            if end_idx - start_idx < 20:
                continue
            
            segment_highs = highs[start_idx:end_idx]
            segment_lows = lows[start_idx:end_idx]
            
            sh_idx, sh_val = self.find_swing_high(segment_highs)
            sl_idx, sl_val = self.find_swing_low(segment_lows)
            
            if sh_val > 0 and sl_val > 0 and sh_val > sl_val:
                swings.append((sh_val, sl_val))
        
        # Calculate fib levels for each swing pair
        for sh, sl in swings:
            levels = self.calculate_levels(sh, sl, is_bullish=True)
            if levels.is_valid:
                all_fib_levels.extend([
                    levels.level_382,
                    levels.level_500,
                    levels.level_618,
                    levels.level_705,
                ])
        
        if len(all_fib_levels) < 2:
            return clusters
        
        # Group nearby levels
        all_fib_levels.sort()
        used = set()
        
        for i, level in enumerate(all_fib_levels):
            if i in used:
                continue
            
            cluster_levels = [level]
            used.add(i)
            
            for j in range(i + 1, len(all_fib_levels)):
                if j in used:
                    continue
                if abs(all_fib_levels[j] - level) <= self.cluster_tolerance:
                    cluster_levels.append(all_fib_levels[j])
                    used.add(j)
            
            if len(cluster_levels) >= 2:
                cluster = FibCluster()
                cluster.price_level = np.mean(cluster_levels)
                cluster.fib_count = len(cluster_levels)
                cluster.levels_converging = cluster_levels
                cluster.strength = min(5, len(cluster_levels))
                cluster.tolerance = self.cluster_tolerance
                clusters.append(cluster)
        
        return clusters
    
    def calculate_fib_score(self, price: float, levels: FibonacciLevels, 
                            atr: float, clusters: List[FibCluster] = None) -> float:
        """
        Calculate Fibonacci score for confluence (0-100).
        
        Scoring:
        - In Golden Pocket: +40
        - Near valid Fib level (< 0.5 ATR): +30
        - Near Fib level (< 1 ATR): +20
        - Near cluster: +20
        - OB/FVG overlap bonus: handled externally
        """
        if not levels.is_valid:
            return 40.0  # Neutral
        
        score = 40.0
        
        # Golden Pocket bonus (biggest factor)
        if self.is_in_golden_pocket(price, levels):
            score += 40.0
        
        # Proximity to valid Fib level
        _, _, dist_atr = self.get_nearest_fib_level(price, levels, atr)
        
        if dist_atr <= 0.25:
            score += 30.0
        elif dist_atr <= 0.5:
            score += 20.0
        elif dist_atr <= 1.0:
            score += 10.0
        
        # Cluster bonus
        if clusters:
            for cluster in clusters:
                if abs(price - cluster.price_level) <= self.cluster_tolerance:
                    score += 10.0 * cluster.strength
                    break
        
        return min(100.0, max(0.0, score))
    
    def analyze(self, highs: np.ndarray, lows: np.ndarray, 
                current_price: float, atr: float,
                is_bullish_bias: bool = True) -> FibAnalysisResult:
        """
        Complete Fibonacci analysis.
        
        Args:
            highs: Price highs array
            lows: Price lows array
            current_price: Current price
            atr: Current ATR
            is_bullish_bias: True for looking for long entries
        """
        result = FibAnalysisResult()
        
        if len(highs) < 20 or len(lows) < 20 or atr <= 0:
            return result
        
        # Find swing points
        _, swing_high = self.find_swing_high(highs)
        _, swing_low = self.find_swing_low(lows)
        
        if swing_high <= swing_low or swing_high == 0 or swing_low == 0:
            return result
        
        # Calculate Fibonacci levels
        levels = self.calculate_levels(swing_high, swing_low, is_bullish_bias)
        result.levels = levels
        
        if not levels.is_valid:
            return result
        
        # Golden Pocket check
        result.in_golden_pocket = self.is_in_golden_pocket(current_price, levels)
        if result.in_golden_pocket:
            result.golden_pocket_score = 40.0
        
        # Nearest Fib level
        nearest_price, nearest_name, dist_atr = self.get_nearest_fib_level(
            current_price, levels, atr
        )
        result.nearest_fib_level = nearest_price
        result.nearest_fib_name = nearest_name
        result.distance_in_atr = dist_atr
        result.distance_to_nearest = abs(current_price - nearest_price)
        result.near_fib_level = dist_atr <= 1.0
        
        # Find clusters
        result.clusters = self.find_clusters(highs, lows, num_swings=3)
        for cluster in result.clusters:
            if abs(current_price - cluster.price_level) <= self.cluster_tolerance:
                result.near_cluster = True
                break
        
        # Calculate score
        result.fib_score = self.calculate_fib_score(
            current_price, levels, atr, result.clusters
        )
        
        # Extension targets
        result.tp1_fib = levels.ext_1272
        result.tp2_fib = levels.ext_1618
        result.tp3_fib = levels.ext_2000
        
        result.is_valid = True
        return result
    
    def get_fib_targets(self, entry_price: float, stop_loss: float,
                        is_long: bool, levels: FibonacciLevels = None) -> Dict[str, float]:
        """
        Calculate Fibonacci-based take profit targets.
        
        Can use either:
        1. Extension levels from swing (if levels provided)
        2. Risk-based extensions (127.2%, 161.8%, 200% of risk)
        """
        risk = abs(entry_price - stop_loss)
        
        targets = {}
        
        if levels and levels.is_valid:
            # Use swing-based extensions
            targets['tp1_ext'] = levels.ext_1272
            targets['tp2_ext'] = levels.ext_1618
            targets['tp3_ext'] = levels.ext_2000
        
        # Risk-based extensions (always calculate)
        if is_long:
            targets['tp1_risk'] = entry_price + risk * 1.272
            targets['tp2_risk'] = entry_price + risk * 1.618
            targets['tp3_risk'] = entry_price + risk * 2.0
        else:
            targets['tp1_risk'] = entry_price - risk * 1.272
            targets['tp2_risk'] = entry_price - risk * 1.618
            targets['tp3_risk'] = entry_price - risk * 2.0
        
        return targets


# Convenience function
def create_fibonacci_analyzer(**kwargs) -> FibonacciAnalyzer:
    """Factory function to create FibonacciAnalyzer."""
    return FibonacciAnalyzer(**kwargs)


if __name__ == "__main__":
    # Test
    print("Fibonacci Analyzer Test")
    print("=" * 50)
    
    np.random.seed(42)
    
    # Simulate price data
    n = 100
    base = 2000.0
    highs = base + np.random.randn(n).cumsum() * 2 + np.arange(n) * 0.1
    lows = highs - np.random.rand(n) * 5 - 2
    
    analyzer = FibonacciAnalyzer()
    
    current_price = highs[-1] - 10
    atr = 5.0
    
    result = analyzer.analyze(highs, lows, current_price, atr, is_bullish_bias=True)
    
    print(f"Current Price: {current_price:.2f}")
    print(f"ATR: {atr:.2f}")
    print(f"\nFibonacci Analysis:")
    print(f"  Valid: {result.is_valid}")
    print(f"  Score: {result.fib_score:.1f}")
    print(f"  In Golden Pocket: {result.in_golden_pocket}")
    print(f"  Nearest Fib: {result.nearest_fib_name} @ {result.nearest_fib_level:.2f}")
    print(f"  Distance (ATR): {result.distance_in_atr:.2f}")
    print(f"\nExtension Targets:")
    print(f"  TP1 (127.2%): {result.tp1_fib:.2f}")
    print(f"  TP2 (161.8%): {result.tp2_fib:.2f}")
    print(f"  TP3 (200.0%): {result.tp3_fib:.2f}")
    
    if result.clusters:
        print(f"\nClusters Found: {len(result.clusters)}")
        for i, c in enumerate(result.clusters):
            print(f"  [{i+1}] Level: {c.price_level:.2f}, Strength: {c.strength}")
