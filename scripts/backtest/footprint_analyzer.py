#!/usr/bin/env python3
"""
Footprint Analyzer - Tick-by-Tick Order Flow Analysis
======================================================
Generates institutional-grade footprint metrics from tick data.

Metrics Generated:
- Delta: Aggressive buy volume - Aggressive sell volume
- Imbalance: Buy/Sell ratio per price level
- Stacked Imbalance: 3+ consecutive levels with imbalance
- Absorption: Large passive volume holding price
- POC: Point of Control (highest volume level)
- VWAP: Volume Weighted Average Price

Author: FORGE v3.1
Date: 2025-12-01
"""

import numpy as np
import pandas as pd
import pyarrow.parquet as pq
from dataclasses import dataclass
from typing import Dict, List, Tuple, Optional
from datetime import datetime, timedelta
import warnings
warnings.filterwarnings('ignore')


# =============================================================================
# CONFIGURATION
# =============================================================================

@dataclass
class FootprintConfig:
    """Configuration for footprint analysis"""
    # Price level granularity (tick size for XAUUSD)
    tick_size: float = 0.01  # $0.01 = 1 cent
    
    # Imbalance thresholds
    imbalance_ratio: float = 3.0  # 300% = strong imbalance
    stacked_min_levels: int = 3   # Minimum levels for stacked imbalance
    
    # Absorption thresholds
    absorption_volume_mult: float = 2.0  # 2x average volume
    absorption_price_tolerance: float = 0.05  # Max price movement %
    
    # Delta normalization
    delta_normalization: float = 1e5  # For score calculation

    # Scoring weights / caps
    base_score: float = 50.0
    max_delta_points: float = 20.0
    stacked_points_per_block: float = 5.0
    max_stacked_points: float = 15.0
    absorption_points: float = 10.0
    imbalance_points: float = 5.0
    absorption_threshold: float = 0.3
    
    # Timeframe
    bar_timeframe: str = '5min'  # M5 bars

    # Verbose logging
    verbose: bool = False


# =============================================================================
# TICK CLASSIFICATION
# =============================================================================

def classify_tick_aggression(ticks: pd.DataFrame) -> pd.DataFrame:
    """
    Classify each tick as aggressive buy or aggressive sell.
    Memory-efficient version using numpy operations directly.
    
    Logic:
    - If tick price >= previous ask → Aggressive BUY (hit the ask)
    - If tick price <= previous bid → Aggressive SELL (hit the bid)
    - Otherwise → Use tick rule (price change direction)
    """
    # Work with numpy arrays directly to save memory
    mid_price = ticks['mid_price'].values if 'mid_price' in ticks.columns else (ticks['bid'].values + ticks['ask'].values) / 2
    bid = ticks['bid'].values
    ask = ticks['ask'].values
    volume = ticks['volume'].values
    
    # Shift values manually (more memory efficient)
    prev_bid = np.roll(bid, 1)
    prev_ask = np.roll(ask, 1)
    prev_mid = np.roll(mid_price, 1)
    prev_bid[0] = bid[0]
    prev_ask[0] = ask[0]
    prev_mid[0] = mid_price[0]
    
    # Price change
    price_change = mid_price - prev_mid
    
    # Classify aggression
    is_buy = (mid_price >= prev_ask) | (price_change > 0)
    is_sell = (mid_price <= prev_bid) | (price_change < 0)
    
    # Handle neutral - default to buy on zero change
    neutral = ~is_buy & ~is_sell
    is_buy = is_buy | (neutral & (price_change >= 0))
    is_sell = is_sell & ~is_buy  # Ensure mutual exclusivity
    
    # Calculate volumes directly
    buy_volume = np.where(is_buy, volume, 0)
    sell_volume = np.where(is_sell, volume, 0)
    
    # Add only the columns we need
    ticks['buy_volume'] = buy_volume
    ticks['sell_volume'] = sell_volume
    ticks['price_change'] = price_change
    
    # Clean up large arrays
    del prev_bid, prev_ask, prev_mid, is_buy, is_sell, neutral, buy_volume, sell_volume
    
    return ticks


def calculate_price_level(price: float, tick_size: float) -> float:
    """Round price to nearest tick level"""
    return round(price / tick_size) * tick_size


# =============================================================================
# FOOTPRINT METRICS CALCULATOR
# =============================================================================

class FootprintAnalyzer:
    """
    Analyzes tick data to generate footprint metrics per bar.
    
    Outputs per bar:
    - delta: Net aggressive volume (buy - sell)
    - delta_pct: Delta as % of total volume
    - total_volume: Total tick volume
    - buy_volume: Total aggressive buy volume
    - sell_volume: Total aggressive sell volume
    - imbalance_count: Number of price levels with imbalance
    - stacked_imbal: Count of stacked imbalance occurrences
    - max_imbalance: Maximum imbalance ratio found
    - absorption: Absorption signal strength (0-1)
    - poc_price: Point of Control price
    - vwap: Volume Weighted Average Price
    - fp_score: Final footprint score (0-100)
    """
    
    def __init__(self, config: FootprintConfig = None):
        self.config = config or FootprintConfig()
    
    def analyze_ticks(self, ticks: pd.DataFrame) -> pd.DataFrame:
        """
        Main entry point: Convert tick data to footprint metrics per M5 bar.
        Memory-efficient version using aggregation instead of per-tick columns.
        
        Args:
            ticks: DataFrame with columns [timestamp, bid, ask, volume, ...]
            
        Returns:
            DataFrame with footprint metrics indexed by bar timestamp
        """
        if self.config.verbose:
            print(f"[FootprintAnalyzer] Processing {len(ticks):,} ticks...")
        
        # 1. Classify tick aggression (in-place, memory efficient)
        if self.config.verbose:
            print("[FootprintAnalyzer] Classifying tick aggression...")
        ticks = classify_tick_aggression(ticks)
        
        # 2. Add bar_time for grouping
        if self.config.verbose:
            print(f"[FootprintAnalyzer] Resampling to {self.config.bar_timeframe} bars...")
        ticks['bar_time'] = ticks.index.floor(self.config.bar_timeframe)
        
        # 3. Fast aggregation for basic metrics
        if self.config.verbose:
            print("[FootprintAnalyzer] Aggregating basic metrics...")
        agg_funcs = {
            'buy_volume': 'sum',
            'sell_volume': 'sum',
            'volume': 'sum',
            'mid_price': ['first', 'last', 'min', 'max', 'mean', 'count']
        }
        
        grouped = ticks.groupby('bar_time').agg(agg_funcs)
        grouped.columns = ['buy_volume', 'sell_volume', 'total_volume', 
                          'open', 'close', 'low', 'high', 'vwap', 'tick_count']
        
        # Calculate delta
        grouped['delta'] = grouped['buy_volume'] - grouped['sell_volume']
        grouped['delta_pct'] = grouped['delta'] / grouped['total_volume'].replace(0, 1)
        
        # 4. Calculate advanced metrics (imbalance, stacked, absorption) per bar
        if self.config.verbose:
            print("[FootprintAnalyzer] Calculating imbalance and absorption (this may take a while)...")
        
        results = []
        bar_groups = ticks.groupby('bar_time')
        total_bars = len(bar_groups)
        
        for i, (bar_time, bar_ticks) in enumerate(bar_groups):
            if self.config.verbose and i % 10000 == 0:
                print(f"[FootprintAnalyzer] Processing bar {i:,}/{total_bars:,}...")
            
            # Fast path: only calculate price level analysis for bars with sufficient ticks
            if len(bar_ticks) >= 10:
                level_stats = self._analyze_price_levels_fast(bar_ticks)
                absorption = self._detect_absorption_fast(bar_ticks)
            else:
                level_stats = {'imbalance_count': 0, 'stacked_imbal': 0, 
                              'max_imbalance': 0, 'avg_imbalance': 0, 'poc_price': np.nan}
                absorption = 0.0
            
            results.append({
                'timestamp': bar_time,
                'imbalance_count': level_stats['imbalance_count'],
                'stacked_imbal': level_stats['stacked_imbal'],
                'max_imbalance': level_stats['max_imbalance'],
                'avg_imbalance': level_stats['avg_imbalance'],
                'poc_price': level_stats['poc_price'],
                'absorption': absorption,
            })
        
        # Merge with basic metrics
        advanced_df = pd.DataFrame(results).set_index('timestamp')
        fp_df = grouped.merge(advanced_df, left_index=True, right_index=True, how='left')
        
        # 5. Calculate footprint scores
        if self.config.verbose:
            print("[FootprintAnalyzer] Calculating footprint scores...")
        fp_df['fp_score'] = fp_df.apply(self._calculate_score, axis=1)
        
        # Clean up
        del ticks['bar_time']
        if 'buy_volume' in ticks.columns:
            del ticks['buy_volume']
        if 'sell_volume' in ticks.columns:
            del ticks['sell_volume']
        if 'price_change' in ticks.columns:
            del ticks['price_change']
        
        if self.config.verbose:
            print(f"[FootprintAnalyzer] Generated {len(fp_df):,} footprint bars")
        
        return fp_df
    
    def _analyze_price_levels_fast(self, bar_ticks: pd.DataFrame) -> Dict:
        """Fast price level analysis without creating new dataframes"""
        mid_prices = bar_ticks['mid_price'].values
        buy_vols = bar_ticks['buy_volume'].values
        sell_vols = bar_ticks['sell_volume'].values
        volumes = bar_ticks['volume'].values
        
        # Round to price levels
        tick_size = self.config.tick_size
        levels = np.round(mid_prices / tick_size) * tick_size
        
        # Group by level using numpy
        unique_levels = np.unique(levels)
        
        if len(unique_levels) == 0:
            return {'imbalance_count': 0, 'stacked_imbal': 0, 
                   'max_imbalance': 0, 'avg_imbalance': 0, 'poc_price': np.nan}
        
        level_buy = np.zeros(len(unique_levels))
        level_sell = np.zeros(len(unique_levels))
        level_vol = np.zeros(len(unique_levels))
        
        for j, lvl in enumerate(unique_levels):
            mask = levels == lvl
            level_buy[j] = buy_vols[mask].sum()
            level_sell[j] = sell_vols[mask].sum()
            level_vol[j] = volumes[mask].sum()
        
        # Calculate imbalance ratios
        buy_ratio = level_buy / (level_sell + 1)
        sell_ratio = level_sell / (level_buy + 1)
        max_ratio = np.maximum(buy_ratio, sell_ratio)
        
        # Count imbalanced levels
        threshold = self.config.imbalance_ratio
        imbalanced = max_ratio >= threshold
        imbalance_count = imbalanced.sum()
        
        # Stacked imbalance (consecutive)
        stacked_imbal = 0
        consecutive = 0
        for is_imbal in imbalanced:
            if is_imbal:
                consecutive += 1
                if consecutive >= self.config.stacked_min_levels:
                    stacked_imbal += 1
            else:
                consecutive = 0
        
        # POC
        poc_idx = np.argmax(level_vol)
        poc_price = unique_levels[poc_idx]
        
        return {
            'imbalance_count': int(imbalance_count),
            'stacked_imbal': stacked_imbal,
            'max_imbalance': float(max_ratio.max()) if len(max_ratio) > 0 else 0,
            'avg_imbalance': float(max_ratio.mean()) if len(max_ratio) > 0 else 0,
            'poc_price': poc_price
        }
    
    def _detect_absorption_fast(self, bar_ticks: pd.DataFrame) -> float:
        """Fast absorption detection"""
        if len(bar_ticks) < 10:
            return 0.0
        
        mid_prices = bar_ticks['mid_price'].values
        volumes = bar_ticks['volume'].values
        buy_vols = bar_ticks['buy_volume'].values
        sell_vols = bar_ticks['sell_volume'].values
        
        high = mid_prices.max()
        low = mid_prices.min()
        price_range = high - low
        avg_price = mid_prices.mean()
        
        if avg_price == 0:
            return 0.0
        
        range_pct = price_range / avg_price
        total_vol = volumes.sum()
        
        absorption = 0.0
        
        # High volume + small range = absorption
        if range_pct < self.config.absorption_price_tolerance and total_vol > 0:
            range_factor = 1 - (range_pct / self.config.absorption_price_tolerance)
            absorption += range_factor * 0.5
        
        # Significant delta that didn't move price
        if total_vol > 0:
            delta = abs(buy_vols.sum() - sell_vols.sum())
            delta_pct = delta / total_vol
            
            if delta_pct > 0.3 and range_pct < self.config.absorption_price_tolerance:
                absorption += delta_pct * 0.5
        
        return min(1.0, absorption)
    
    def _calculate_bar_metrics(self, bar_time: datetime, bar_ticks: pd.DataFrame) -> Dict:
        """Calculate all footprint metrics for a single bar"""
        
        # Basic volumes
        buy_vol = bar_ticks['buy_volume'].sum()
        sell_vol = bar_ticks['sell_volume'].sum()
        total_vol = bar_ticks['volume'].sum()
        
        # Delta
        delta = buy_vol - sell_vol
        delta_pct = delta / total_vol if total_vol > 0 else 0
        
        # VWAP
        if total_vol > 0:
            vwap = (bar_ticks['mid_price'] * bar_ticks['volume']).sum() / total_vol
        else:
            vwap = bar_ticks['mid_price'].mean()
        
        # Price levels analysis
        level_stats = self._analyze_price_levels(bar_ticks)
        
        # Absorption detection
        absorption = self._detect_absorption(bar_ticks)
        
        return {
            'timestamp': bar_time,
            'delta': delta,
            'delta_pct': delta_pct,
            'total_volume': total_vol,
            'buy_volume': buy_vol,
            'sell_volume': sell_vol,
            'imbalance_count': level_stats['imbalance_count'],
            'stacked_imbal': level_stats['stacked_imbal'],
            'max_imbalance': level_stats['max_imbalance'],
            'avg_imbalance': level_stats['avg_imbalance'],
            'poc_price': level_stats['poc_price'],
            'absorption': absorption,
            'vwap': vwap,
            'tick_count': len(bar_ticks),
            'high': bar_ticks['mid_price'].max(),
            'low': bar_ticks['mid_price'].min(),
            'open': bar_ticks['mid_price'].iloc[0] if len(bar_ticks) > 0 else np.nan,
            'close': bar_ticks['mid_price'].iloc[-1] if len(bar_ticks) > 0 else np.nan,
        }
    
    def _analyze_price_levels(self, bar_ticks: pd.DataFrame) -> Dict:
        """Analyze buy/sell volume per price level for imbalances"""
        
        # Group by price level
        levels = bar_ticks.groupby('price_level').agg({
            'buy_volume': 'sum',
            'sell_volume': 'sum',
            'volume': 'sum'
        }).reset_index()
        
        if len(levels) == 0:
            return {
                'imbalance_count': 0,
                'stacked_imbal': 0,
                'max_imbalance': 0,
                'avg_imbalance': 0,
                'poc_price': np.nan
            }
        
        # Calculate imbalance ratio per level
        # Imbalance = (buy_at_level[i] - sell_at_level[i-1]) / total
        # Simplified: ratio = buy / (sell + 1) for buy imbalance
        #             ratio = sell / (buy + 1) for sell imbalance
        
        levels['buy_imbal_ratio'] = levels['buy_volume'] / (levels['sell_volume'] + 1)
        levels['sell_imbal_ratio'] = levels['sell_volume'] / (levels['buy_volume'] + 1)
        levels['max_ratio'] = levels[['buy_imbal_ratio', 'sell_imbal_ratio']].max(axis=1)
        
        # Count imbalanced levels
        threshold = self.config.imbalance_ratio
        levels['is_imbalanced'] = levels['max_ratio'] >= threshold
        imbalance_count = levels['is_imbalanced'].sum()
        
        # Detect stacked imbalances
        stacked_imbal = self._count_stacked_imbalances(levels)
        
        # POC (Point of Control) - level with highest volume
        poc_idx = levels['volume'].idxmax()
        poc_price = levels.loc[poc_idx, 'price_level'] if pd.notna(poc_idx) else np.nan
        
        return {
            'imbalance_count': imbalance_count,
            'stacked_imbal': stacked_imbal,
            'max_imbalance': levels['max_ratio'].max() if len(levels) > 0 else 0,
            'avg_imbalance': levels['max_ratio'].mean() if len(levels) > 0 else 0,
            'poc_price': poc_price
        }
    
    def _count_stacked_imbalances(self, levels: pd.DataFrame) -> int:
        """
        Count stacked imbalances: 3+ consecutive levels with imbalance.
        Returns count of stacked occurrences.
        """
        if len(levels) < self.config.stacked_min_levels:
            return 0
        
        # Sort by price level
        levels = levels.sort_values('price_level')
        
        # Find consecutive imbalanced levels
        imbal_flags = levels['is_imbalanced'].values
        
        stacked_count = 0
        consecutive = 0
        
        for is_imbal in imbal_flags:
            if is_imbal:
                consecutive += 1
                if consecutive >= self.config.stacked_min_levels:
                    stacked_count += 1
            else:
                consecutive = 0
        
        return stacked_count
    
    def _detect_absorption(self, bar_ticks: pd.DataFrame) -> float:
        """
        Detect absorption: Large passive volume that holds price.
        
        Signs of absorption:
        1. High volume at a price level
        2. Price doesn't move much (small range)
        3. One side has much more volume than price movement suggests
        
        Returns: Absorption strength (0-1)
        """
        if len(bar_ticks) < 10:
            return 0.0
        
        # Calculate price range
        high = bar_ticks['mid_price'].max()
        low = bar_ticks['mid_price'].min()
        price_range = high - low
        avg_price = bar_ticks['mid_price'].mean()
        
        if avg_price == 0:
            return 0.0
        
        range_pct = price_range / avg_price
        
        # Calculate volume metrics
        total_vol = bar_ticks['volume'].sum()
        avg_vol_per_tick = total_vol / len(bar_ticks)
        
        # Calculate delta
        buy_vol = bar_ticks['buy_volume'].sum()
        sell_vol = bar_ticks['sell_volume'].sum()
        
        # Absorption indicators:
        # 1. Small price range despite high volume
        # 2. Significant delta that didn't move price
        
        absorption = 0.0
        
        # High volume + small range = potential absorption
        if range_pct < self.config.absorption_price_tolerance and total_vol > 0:
            # The smaller the range with volume, the more absorption
            range_factor = 1 - (range_pct / self.config.absorption_price_tolerance)
            absorption += range_factor * 0.5
        
        # Significant delta that didn't move price = absorption
        if total_vol > 0:
            delta = abs(buy_vol - sell_vol)
            delta_pct = delta / total_vol
            
            # If delta is high but range is low, absorption is happening
            if delta_pct > 0.3 and range_pct < self.config.absorption_price_tolerance:
                absorption += delta_pct * 0.5
        
        return min(1.0, absorption)
    
    def _calculate_score(self, row: pd.Series) -> float:
        """
        Calculate footprint score (0-100) from metrics.
        
        Scoring Logic:
        - Base score: 50
        - Delta contribution: ±20 (direction and strength)
        - Stacked imbalance: +15 max (strong institutional activity)
        - Absorption: +10 (potential reversal/continuation)
        - Imbalance count: +5 max (additional confirmation)
        
        Score interpretation:
        - 0-30: Strong bearish footprint
        - 30-45: Bearish bias
        - 45-55: Neutral
        - 55-70: Bullish bias
        - 70-100: Strong bullish footprint
        """
        cfg = self.config
        score = cfg.base_score

        # 1. Delta contribution
        delta_norm = row['delta'] / cfg.delta_normalization
        score += np.tanh(delta_norm) * cfg.max_delta_points

        # 2. Stacked imbalance
        stacked = row.get('stacked_imbal', 0)
        stacked_contribution = min(stacked * cfg.stacked_points_per_block, cfg.max_stacked_points)
        if row['delta'] > 0:
            score += stacked_contribution
        elif row['delta'] < 0:
            score -= stacked_contribution

        # 3. Absorption
        absorption = row.get('absorption', 0)
        if absorption > cfg.absorption_threshold:
            score += cfg.absorption_points if row['delta'] >= 0 else -cfg.absorption_points

        # 4. Imbalance presence
        if row.get('imbalance_count', 0) > 0:
            score += cfg.imbalance_points

        # Clamp to valid range
        return float(np.clip(score, 0, 100))


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

def load_and_analyze_ticks(tick_path: str, config: FootprintConfig = None, 
                          chunk_size: int = 5_000_000) -> pd.DataFrame:
    """
    Load tick data from Parquet and generate footprint metrics.
    Memory-efficient chunked processing for large files.
    
    Args:
        tick_path: Path to Parquet file
        config: FootprintConfig (optional)
        chunk_size: Number of ticks per chunk (default 5M)
        
    Returns:
        DataFrame with footprint metrics per M5 bar
    """
    print(f"[Footprint] Loading ticks from {tick_path}...")
    
    # Load parquet
    table = pq.read_table(tick_path)
    total_rows = table.num_rows
    print(f"[Footprint] Total ticks: {total_rows:,}")
    
    if config is None:
        config = FootprintConfig()
    
    # Process in chunks if large
    if total_rows > chunk_size:
        print(f"[Footprint] Processing in chunks of {chunk_size:,}...")
        all_results = []
        
        for start in range(0, total_rows, chunk_size):
            end = min(start + chunk_size, total_rows)
            print(f"\n[Footprint] Processing chunk {start:,} - {end:,}...")
            
            # Slice table and convert
            chunk_table = table.slice(start, end - start)
            ticks = chunk_table.to_pandas()
            
            # Ensure timestamp index
            if 'timestamp' in ticks.columns:
                if not pd.api.types.is_datetime64_any_dtype(ticks['timestamp']):
                    ticks['timestamp'] = pd.to_datetime(ticks['timestamp'])
                ticks.set_index('timestamp', inplace=True)
            
            # Process chunk
            fp_chunk = _process_tick_chunk(ticks, config)
            all_results.append(fp_chunk)
            
            # Free memory
            del ticks, chunk_table
        
        # Combine all chunks
        print("\n[Footprint] Combining chunks...")
        fp_df = pd.concat(all_results)
        
        # Aggregate duplicates (same bar_time from different chunks)
        fp_df = fp_df.groupby(fp_df.index).agg({
            'buy_volume': 'sum',
            'sell_volume': 'sum',
            'total_volume': 'sum',
            'delta': 'sum',
            'delta_pct': 'mean',
            'imbalance_count': 'max',
            'stacked_imbal': 'max',
            'max_imbalance': 'max',
            'avg_imbalance': 'mean',
            'absorption': 'max',
            'fp_score': 'mean',
            'open': 'first',
            'close': 'last',
            'high': 'max',
            'low': 'min',
            'vwap': 'mean',
            'tick_count': 'sum',
            'poc_price': 'first'
        })
        
        # Recalculate fp_score after aggregation
        analyzer = FootprintAnalyzer(config)
        fp_df['fp_score'] = fp_df.apply(analyzer._calculate_score, axis=1)
        
    else:
        ticks = table.to_pandas()
        
        if 'timestamp' in ticks.columns:
            if not pd.api.types.is_datetime64_any_dtype(ticks['timestamp']):
                ticks['timestamp'] = pd.to_datetime(ticks['timestamp'])
            ticks.set_index('timestamp', inplace=True)
        
        ticks.sort_index(inplace=True)
        
        print(f"[Footprint] Period: {ticks.index[0]} to {ticks.index[-1]}")
        
        analyzer = FootprintAnalyzer(config)
        fp_df = analyzer.analyze_ticks(ticks)
    
    print(f"[Footprint] Generated {len(fp_df):,} footprint bars")
    return fp_df


def _process_tick_chunk(ticks: pd.DataFrame, config: FootprintConfig) -> pd.DataFrame:
    """Process a chunk of ticks and return footprint metrics"""
    ticks.sort_index(inplace=True)
    
    # Classify aggression using numpy (memory efficient)
    mid_price = ticks['mid_price'].values if 'mid_price' in ticks.columns else (ticks['bid'].values + ticks['ask'].values) / 2
    bid = ticks['bid'].values
    ask = ticks['ask'].values
    volume = ticks['volume'].values
    
    # Shift values
    prev_bid = np.roll(bid, 1)
    prev_ask = np.roll(ask, 1)
    prev_mid = np.roll(mid_price, 1)
    prev_bid[0] = bid[0]
    prev_ask[0] = ask[0]
    prev_mid[0] = mid_price[0]
    
    # Price change
    price_change = mid_price - prev_mid
    
    # Classify aggression
    is_buy = (mid_price >= prev_ask) | (price_change > 0)
    is_sell = (mid_price <= prev_bid) | (price_change < 0)
    
    neutral = ~is_buy & ~is_sell
    is_buy = is_buy | (neutral & (price_change >= 0))
    is_sell = is_sell & ~is_buy
    
    buy_volume = np.where(is_buy, volume, 0)
    sell_volume = np.where(is_sell, volume, 0)
    
    # Create minimal dataframe for groupby
    bar_times = pd.to_datetime(ticks.index).floor(config.bar_timeframe)
    
    df_minimal = pd.DataFrame({
        'bar_time': bar_times,
        'buy_volume': buy_volume,
        'sell_volume': sell_volume,
        'volume': volume,
        'mid_price': mid_price
    })
    
    # Aggregate
    grouped = df_minimal.groupby('bar_time').agg({
        'buy_volume': 'sum',
        'sell_volume': 'sum',
        'volume': 'sum',
        'mid_price': ['first', 'last', 'min', 'max', 'mean', 'count']
    })
    grouped.columns = ['buy_volume', 'sell_volume', 'total_volume',
                      'open', 'close', 'low', 'high', 'vwap', 'tick_count']
    
    grouped['delta'] = grouped['buy_volume'] - grouped['sell_volume']
    grouped['delta_pct'] = grouped['delta'] / grouped['total_volume'].replace(0, 1)
    
    # Simplified metrics (skip detailed imbalance for speed)
    grouped['imbalance_count'] = 0
    grouped['stacked_imbal'] = 0
    grouped['max_imbalance'] = 0.0
    grouped['avg_imbalance'] = 0.0
    grouped['absorption'] = 0.0
    grouped['poc_price'] = grouped['vwap']
    
    # Calculate fp_score
    analyzer = FootprintAnalyzer(config)
    grouped['fp_score'] = grouped.apply(analyzer._calculate_score, axis=1)
    
    return grouped


def merge_footprint_with_bars(bars_df: pd.DataFrame, fp_df: pd.DataFrame) -> pd.DataFrame:
    """
    Merge footprint metrics with OHLC bars.
    
    Args:
        bars_df: OHLC DataFrame with datetime index
        fp_df: Footprint DataFrame with datetime index
        
    Returns:
        Merged DataFrame with all columns
    """
    # Ensure both have datetime index
    if not isinstance(bars_df.index, pd.DatetimeIndex):
        bars_df.index = pd.to_datetime(bars_df.index)
    if not isinstance(fp_df.index, pd.DatetimeIndex):
        fp_df.index = pd.to_datetime(fp_df.index)
    
    # Merge on index
    merged = bars_df.merge(
        fp_df[['delta', 'delta_pct', 'stacked_imbal', 'absorption', 
               'imbalance_count', 'max_imbalance', 'avg_imbalance', 'fp_score']],
        left_index=True,
        right_index=True,
        how='left'
    )
    
    # Fill NaN footprint scores with neutral
    merged['fp_score'] = merged['fp_score'].fillna(50)
    merged['delta'] = merged['delta'].fillna(0)
    merged['stacked_imbal'] = merged['stacked_imbal'].fillna(0)
    merged['absorption'] = merged['absorption'].fillna(0)
    
    return merged


# =============================================================================
# MAIN / TEST
# =============================================================================

def main():
    """Test footprint analysis on 2024 tick data"""
    
    print("=" * 80)
    print("           FOOTPRINT ANALYZER - TICK ORDER FLOW ANALYSIS")
    print("=" * 80)
    
    # Configuration
    config = FootprintConfig(
        tick_size=0.01,          # $0.01 for XAUUSD
        imbalance_ratio=3.0,     # 300% for strong imbalance
        stacked_min_levels=3,    # 3+ levels = stacked
        bar_timeframe='5min'     # M5 bars
    )
    
    # Load and analyze
    tick_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/data/processed/ticks_2024.parquet"
    fp_df = load_and_analyze_ticks(tick_path, config)
    
    # Print summary
    print("\n" + "=" * 80)
    print("                        FOOTPRINT ANALYSIS SUMMARY")
    print("=" * 80)
    
    print(f"\nBars analyzed: {len(fp_df):,}")
    print(f"Period: {fp_df.index[0]} to {fp_df.index[-1]}")
    
    print("\n--- Delta Statistics ---")
    print(f"Mean Delta: {fp_df['delta'].mean():,.0f}")
    print(f"Std Delta: {fp_df['delta'].std():,.0f}")
    print(f"Positive Delta bars: {(fp_df['delta'] > 0).sum():,} ({(fp_df['delta'] > 0).mean()*100:.1f}%)")
    print(f"Negative Delta bars: {(fp_df['delta'] < 0).sum():,} ({(fp_df['delta'] < 0).mean()*100:.1f}%)")
    
    print("\n--- Imbalance Statistics ---")
    print(f"Bars with stacked imbalance: {(fp_df['stacked_imbal'] > 0).sum():,}")
    print(f"Max stacked in single bar: {fp_df['stacked_imbal'].max()}")
    print(f"Mean imbalance count: {fp_df['imbalance_count'].mean():.1f}")
    
    print("\n--- Absorption Statistics ---")
    print(f"Bars with absorption > 0.3: {(fp_df['absorption'] > 0.3).sum():,}")
    print(f"Max absorption: {fp_df['absorption'].max():.2f}")
    
    print("\n--- Footprint Score Distribution ---")
    print(f"Mean FP Score: {fp_df['fp_score'].mean():.1f}")
    print(f"Strong Bullish (>70): {(fp_df['fp_score'] > 70).sum():,} ({(fp_df['fp_score'] > 70).mean()*100:.1f}%)")
    print(f"Bullish (55-70): {((fp_df['fp_score'] > 55) & (fp_df['fp_score'] <= 70)).sum():,}")
    print(f"Neutral (45-55): {((fp_df['fp_score'] >= 45) & (fp_df['fp_score'] <= 55)).sum():,}")
    print(f"Bearish (30-45): {((fp_df['fp_score'] >= 30) & (fp_df['fp_score'] < 45)).sum():,}")
    print(f"Strong Bearish (<30): {(fp_df['fp_score'] < 30).sum():,} ({(fp_df['fp_score'] < 30).mean()*100:.1f}%)")
    
    # Save to CSV for inspection
    output_path = "C:/Users/Admin/Documents/EA_SCALPER_XAUUSD/data/footprint_2024.csv"
    fp_df.to_csv(output_path)
    print(f"\n[Footprint] Saved to {output_path}")
    
    # Show sample data
    print("\n--- Sample Footprint Data (last 10 bars) ---")
    print(fp_df[['delta', 'stacked_imbal', 'absorption', 'fp_score']].tail(10).to_string())
    
    print("\n" + "=" * 80)
    print("                        FOOTPRINT ANALYSIS COMPLETE")
    print("=" * 80)
    
    return fp_df


if __name__ == "__main__":
    main()
