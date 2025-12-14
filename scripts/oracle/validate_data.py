#!/usr/bin/env python3
"""
XAUUSD Historical Data Validator v1.0
=====================================
Validates tick and bar data for backtesting quality.

Supports:
- Tick data (CSV): datetime,bid,ask
- Bar data (CSV): Date,Time,Open,High,Low,Close,Volume
- MT5 direct connection (optional)

Author: FORGE v3.1
Date: 2025-12-01
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from pathlib import Path
from typing import Optional, Dict, List, Tuple
import argparse
import sys
from dataclasses import dataclass, field


@dataclass
class ValidationResult:
    """Holds validation results."""
    total_records: int = 0
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    months_coverage: float = 0.0
    clean_records: int = 0
    clean_percentage: float = 0.0
    
    # Problem counts
    gaps_count: int = 0
    gaps_over_1day: int = 0
    missing_data: int = 0
    anomalous_spreads: int = 0
    invalid_prices: int = 0
    zero_volume_periods: int = 0
    
    # Problem details
    problems: List[str] = field(default_factory=list)
    gap_details: List[Dict] = field(default_factory=list)
    
    # GENIUS Features (v2.0)
    # Regime Analysis (Principle #3)
    regime_transitions: int = 0
    trending_pct: float = 0.0
    ranging_pct: float = 0.0
    reverting_pct: float = 0.0
    avg_transition_duration: float = 0.0
    regime_diversity_ok: bool = False
    
    # MTF Consistency (Principle #4)
    mtf_consistency_score: float = 0.0
    mtf_checked: bool = False
    
    # Volatility Clustering
    volatility_autocorr: float = 0.0
    volatility_clustering_ok: bool = False
    
    # Session Coverage
    session_coverage: Dict = field(default_factory=dict)
    session_coverage_ok: bool = False
    
    # GENIUS Quality Score (0-100)
    quality_score_genius: int = 0
    
    # Approval
    approved: bool = False
    approval_reasons: List[str] = field(default_factory=list)


class XAUUSDDataValidator:
    """Validates XAUUSD historical data for backtesting."""
    
    # Validation thresholds
    GAP_THRESHOLD_MINUTES = 5  # Gap threshold for tick data
    GAP_THRESHOLD_BARS = 2    # Gap threshold for bar data (2 bars = 10min for M5)
    MAX_GAP_DAYS = 1          # Max allowed gap (except weekends)
    SPREAD_THRESHOLD = 100    # Max spread in cents ($1.00)
    MIN_MONTHS = 12           # Minimum months of data required
    MIN_CLEAN_PCT = 95.0      # Minimum clean data percentage
    ZERO_VOLUME_THRESHOLD = 10  # Consecutive zero volume bars
    
    def __init__(self, verbose: bool = True):
        self.verbose = verbose
        self._head_last_line = None  # For detecting artificial gaps in head+tail sampling
        self._tail_first_line = None
        
    def log(self, msg: str):
        """Print if verbose mode."""
        if self.verbose:
            print(msg)
    
    def is_weekend(self, dt: datetime) -> bool:
        """Check if datetime is during weekend (Friday 22:00 UTC to Sunday 22:00 UTC)."""
        # Friday = 4, Saturday = 5, Sunday = 6
        if dt.weekday() == 5:  # Saturday
            return True
        if dt.weekday() == 6:  # Sunday
            return True
        if dt.weekday() == 4 and dt.hour >= 22:  # Friday after 22:00
            return True
        return False
    
    def is_gap_during_weekend(self, start_dt: datetime, end_dt: datetime) -> bool:
        """Check if a gap spans only weekend hours."""
        # If gap starts on Friday evening and ends Sunday evening/Monday morning
        if start_dt.weekday() == 4 and start_dt.hour >= 21:
            if end_dt.weekday() in [6, 0]:  # Sunday or Monday
                return True
        return False
    
    def detect_data_type(self, filepath: Path) -> str:
        """Auto-detect if file is tick or bar data."""
        # Parquet files are treated as ticks by default
        if filepath.suffix.lower() in ('.parquet', '.pq'):
            return 'ticks'

        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            first_line = f.readline().strip()
            second_line = f.readline().strip()
        
        # Check if first line is header
        if 'Date' in first_line and 'Open' in first_line:
            return 'bars'
        
        # Check tick format: datetime,bid,ask
        parts = first_line.split(',')
        if len(parts) == 3:
            try:
                # Try parsing as tick data
                float(parts[1])
                float(parts[2])
                return 'ticks'
            except ValueError:
                pass
        
        return 'unknown'
    
    def load_tick_data(self, filepath: Path, sample_size: Optional[int] = None) -> pd.DataFrame:
        """Load tick data from CSV - optimized for huge files."""
        self.log(f"Loading tick data from: {filepath}")
        
        file_size_gb = filepath.stat().st_size / (1024**3)
        
        # For very large files (>1GB), use streaming approach
        if file_size_gb > 1 and sample_size:
            self.log(f"Large file detected ({file_size_gb:.2f} GB). Using streaming sample...")
            return self._load_tick_data_streaming(filepath, sample_size)
        elif sample_size:
            self.log(f"Loading with random sampling ({sample_size:,} records)...")
            return self._load_tick_data_sampled(filepath, sample_size)
        else:
            self.log("Loading full file in chunks...")
            return self._load_tick_data_full(filepath)

    def load_parquet_ticks(self, filepath: Path, sample_size: Optional[int] = None) -> pd.DataFrame:
        """Load tick data from Parquet (already columnar, no sampling needed)."""
        self.log(f"Loading parquet ticks from: {filepath}")
        df = pd.read_parquet(filepath)
        # Normalize column names
        rename = {}
        if 'time' in df.columns and 'timestamp' not in df.columns:
            rename['time'] = 'timestamp'
        if 'mid' in df.columns and 'mid_price' not in df.columns:
            rename['mid'] = 'mid_price'
        df = df.rename(columns=rename)
        # Parse timestamp if still string
        if df['timestamp'].dtype == object:
            df['timestamp'] = pd.to_datetime(df['timestamp'], errors='coerce')
        # Ensure datetime alias used by downstream checks
        if 'datetime' not in df.columns:
            df['datetime'] = df['timestamp']
        # Derive spread if missing
        if 'spread' not in df.columns and {'bid', 'ask'}.issubset(df.columns):
            df['spread'] = (df['ask'] - df['bid']) * 100  # convert to cents
        if sample_size and len(df) > sample_size:
            df = df.sample(sample_size, random_state=42).sort_values('timestamp')
        return df
    
    def _load_tick_data_streaming(self, filepath: Path, sample_size: int) -> pd.DataFrame:
        """Stream through file and collect samples - HEAD + TAIL only (fast)."""
        from collections import deque
        
        # For huge files: only use HEAD + TAIL (no random seek = fast)
        head_size = sample_size // 2
        tail_size = sample_size // 2
        
        self.log(f"  Reading first {head_size:,} lines...")
        head_lines = []
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            for i, line in enumerate(f):
                if i >= head_size:
                    break
                head_lines.append(line.strip())
        
        # Estimate total lines
        avg_line_len = sum(len(l) for l in head_lines[:100]) / 100
        estimated_lines = int(filepath.stat().st_size / avg_line_len)
        self.log(f"  Estimated total lines: ~{estimated_lines:,}")
        
        self.log(f"  Reading last {tail_size:,} lines (using seek)...")
        # Use file seek to jump to end - much faster than reading entire file
        tail_lines = []
        file_size = filepath.stat().st_size
        # Estimate bytes to read (average line ~37 bytes for tick data)
        bytes_to_read = min(tail_size * 50, file_size // 2)  # 50 bytes per line estimate
        
        with open(filepath, 'rb') as f:
            # Seek to near end
            f.seek(max(0, file_size - bytes_to_read))
            f.readline()  # Skip partial line
            content = f.read().decode('utf-8', errors='ignore')
            lines = content.strip().split('\n')
            tail_lines = [l.strip() for l in lines[-tail_size:]]
        
        self.log(f"  Got {len(tail_lines):,} tail lines")
        
        # Combine head + tail only
        all_lines = head_lines + tail_lines
        self.log(f"  Total sampled: {len(all_lines):,} lines (head + tail)")
        
        # Mark boundary datetimes for gap detection (to ignore head-tail junction)
        # We'll skip gaps where start_dt < head_last AND end_dt > tail_first
        self._head_last_line = head_lines[-1] if head_lines else None
        self._tail_first_line = tail_lines[0] if tail_lines else None
        
        # Parse to DataFrame
        data = []
        for line in all_lines:
            parts = line.split(',')
            if len(parts) >= 3:
                data.append(parts[:3])
        
        df = pd.DataFrame(data, columns=['datetime', 'bid', 'ask'])
        df['datetime'] = pd.to_datetime(df['datetime'], format='%Y.%m.%d %H:%M:%S.%f', errors='coerce')
        df['bid'] = pd.to_numeric(df['bid'], errors='coerce')
        df['ask'] = pd.to_numeric(df['ask'], errors='coerce')
        df['spread'] = (df['ask'] - df['bid']) * 100
        
        # Sort by datetime
        df = df.sort_values('datetime').reset_index(drop=True)
        
        self.log(f"  Loaded {len(df):,} ticks")
        return df
    
    def _load_tick_data_sampled(self, filepath: Path, sample_size: int) -> pd.DataFrame:
        """Load sampled tick data using skiprows."""
        # Estimate line count
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            first_lines = [f.readline() for _ in range(100)]
        avg_line_len = sum(len(l) for l in first_lines) / len(first_lines)
        estimated_lines = int(filepath.stat().st_size / avg_line_len)
        
        skip_ratio = max(1, estimated_lines // sample_size)
        self.log(f"  Skip ratio: 1/{skip_ratio}")
        
        df = pd.read_csv(
            filepath,
            names=['datetime', 'bid', 'ask'],
            skiprows=lambda i: i % skip_ratio != 0,
            encoding='utf-8',
            on_bad_lines='skip'
        )
        
        df['datetime'] = pd.to_datetime(df['datetime'], format='%Y.%m.%d %H:%M:%S.%f', errors='coerce')
        df['bid'] = pd.to_numeric(df['bid'], errors='coerce')
        df['ask'] = pd.to_numeric(df['ask'], errors='coerce')
        df['spread'] = (df['ask'] - df['bid']) * 100
        
        self.log(f"  Loaded {len(df):,} ticks")
        return df
    
    def _load_tick_data_full(self, filepath: Path) -> pd.DataFrame:
        """Load full tick data in chunks."""
        chunks = []
        chunk_size = 5_000_000
        
        for i, chunk in enumerate(pd.read_csv(
            filepath,
            names=['datetime', 'bid', 'ask'],
            chunksize=chunk_size,
            encoding='utf-8',
            on_bad_lines='skip'
        )):
            self.log(f"  Processing chunk {i+1} ({len(chunk):,} rows)...")
            chunk['datetime'] = pd.to_datetime(chunk['datetime'], format='%Y.%m.%d %H:%M:%S.%f', errors='coerce')
            chunk['bid'] = pd.to_numeric(chunk['bid'], errors='coerce')
            chunk['ask'] = pd.to_numeric(chunk['ask'], errors='coerce')
            chunk['spread'] = (chunk['ask'] - chunk['bid']) * 100
            chunks.append(chunk)
        
        df = pd.concat(chunks, ignore_index=True)
        self.log(f"  Loaded {len(df):,} ticks")
        return df
    
    def load_bar_data(self, filepath: Path) -> pd.DataFrame:
        """Load bar data from CSV."""
        self.log(f"Loading bar data from: {filepath}")
        
        df = pd.read_csv(filepath, encoding='utf-8')
        
        # Combine Date and Time columns
        if 'Date' in df.columns and 'Time' in df.columns:
            df['datetime'] = pd.to_datetime(
                df['Date'].astype(str) + ' ' + df['Time'].astype(str),
                format='%Y%m%d %H:%M:%S'
            )
        elif 'datetime' in df.columns:
            df['datetime'] = pd.to_datetime(df['datetime'])
        
        # Calculate spread from OHLC if available
        if 'High' in df.columns and 'Low' in df.columns:
            df['spread'] = (df['High'] - df['Low']) * 100  # Approximation
        
        self.log(f"Loaded {len(df):,} bars")
        return df
    
    def validate_tick_data(self, df: pd.DataFrame, result: ValidationResult) -> ValidationResult:
        """Validate tick data quality."""
        self.log("\n" + "="*60)
        self.log("VALIDATING TICK DATA")
        self.log("="*60)
        
        # Basic stats
        result.total_records = len(df)
        valid_datetime = df['datetime'].notna()
        df_valid = df[valid_datetime].copy()
        
        if len(df_valid) == 0:
            result.problems.append("CRITICAL: No valid datetime records found")
            return result
        
        df_valid = df_valid.sort_values('datetime')
        result.start_date = df_valid['datetime'].min()
        result.end_date = df_valid['datetime'].max()
        
        # Calculate coverage in months
        if result.start_date and result.end_date:
            days = (result.end_date - result.start_date).days
            result.months_coverage = days / 30.44
        
        self.log(f"\nPeriod: {result.start_date} to {result.end_date}")
        self.log(f"Coverage: {result.months_coverage:.1f} months ({days:,} days)")
        
        problems_mask = pd.Series(False, index=df_valid.index)
        
        # 1. Check for invalid prices (negative or zero)
        self.log("\n[1/5] Checking for invalid prices...")
        invalid_bid = (df_valid['bid'] <= 0) | df_valid['bid'].isna()
        invalid_ask = (df_valid['ask'] <= 0) | df_valid['ask'].isna()
        invalid_prices = invalid_bid | invalid_ask
        result.invalid_prices = invalid_prices.sum()
        problems_mask |= invalid_prices
        
        if result.invalid_prices > 0:
            result.problems.append(f"Invalid prices (<=0 or NaN): {result.invalid_prices:,}")
            # Show examples
            examples = df_valid[invalid_prices].head(3)
            for _, row in examples.iterrows():
                result.problems.append(f"  - {row['datetime']}: bid={row['bid']}, ask={row['ask']}")
        
        # 2. Check for anomalous spreads
        self.log("[2/5] Checking for anomalous spreads (>{} cents)...".format(self.SPREAD_THRESHOLD))
        anomalous = df_valid['spread'] > self.SPREAD_THRESHOLD
        result.anomalous_spreads = anomalous.sum()
        problems_mask |= anomalous
        
        if result.anomalous_spreads > 0:
            result.problems.append(f"Anomalous spreads (>{self.SPREAD_THRESHOLD} cents): {result.anomalous_spreads:,}")
            # Show worst examples
            worst = df_valid[anomalous].nlargest(3, 'spread')
            for _, row in worst.iterrows():
                result.problems.append(f"  - {row['datetime']}: spread={row['spread']:.0f} cents (bid={row['bid']:.2f}, ask={row['ask']:.2f})")
        
        # 3. Check for gaps
        self.log("[3/5] Checking for gaps (>{} minutes)...".format(self.GAP_THRESHOLD_MINUTES))
        df_valid['time_diff'] = df_valid['datetime'].diff()
        gap_threshold = timedelta(minutes=self.GAP_THRESHOLD_MINUTES)
        
        gaps = df_valid[df_valid['time_diff'] > gap_threshold].copy()
        
        # Filter out weekend gaps and head-tail boundary (artificial gap from sampling)
        real_gaps = []
        weekend_gaps = 0
        sampling_gaps = 0
        
        for idx in gaps.index:
            loc = df_valid.index.get_loc(idx)
            if loc > 0:
                prev_idx = df_valid.index[loc - 1]
                start_dt = df_valid.loc[prev_idx, 'datetime']
                end_dt = df_valid.loc[idx, 'datetime']
                gap_duration = df_valid.loc[idx, 'time_diff']
                
                # Skip artificial gap at head-tail boundary (from sampling strategy)
                # If gap spans from head sample to tail sample, it's artificial
                if self._head_last_line and self._tail_first_line:
                    try:
                        head_last_dt = pd.to_datetime(self._head_last_line.split(',')[0], format='%Y.%m.%d %H:%M:%S.%f')
                        tail_first_dt = pd.to_datetime(self._tail_first_line.split(',')[0], format='%Y.%m.%d %H:%M:%S.%f')
                        # If this gap is near the head-tail boundary (within 1 second), skip it
                        if abs((start_dt - head_last_dt).total_seconds()) < 1 or abs((end_dt - tail_first_dt).total_seconds()) < 1:
                            sampling_gaps += 1
                            continue
                    except:
                        pass
                
                if self.is_gap_during_weekend(start_dt, end_dt):
                    weekend_gaps += 1
                else:
                    gap_days = gap_duration.total_seconds() / 86400
                    real_gaps.append({
                        'start': start_dt,
                        'end': end_dt,
                        'duration': gap_duration,
                        'days': gap_days
                    })
                    
                    if gap_days > self.MAX_GAP_DAYS:
                        result.gaps_over_1day += 1
        
        result.gaps_count = len(real_gaps)
        result.gap_details = real_gaps[:20]  # Keep first 20 for report
        
        if result.gaps_count > 0 or sampling_gaps > 0:
            result.problems.append(f"Gaps >{self.GAP_THRESHOLD_MINUTES}min (non-weekend): {result.gaps_count:,}")
            result.problems.append(f"  Weekend gaps (expected): {weekend_gaps:,}")
            if sampling_gaps > 0:
                result.problems.append(f"  Sampling boundary gaps (ignored): {sampling_gaps:,}")
            
            # Show worst gaps
            sorted_gaps = sorted(real_gaps, key=lambda x: x['duration'], reverse=True)[:5]
            for gap in sorted_gaps:
                result.problems.append(f"  - {gap['start']} to {gap['end']} ({gap['duration']})")
        
        # 4. Check for missing/NaN data
        self.log("[4/5] Checking for missing data...")
        result.missing_data = df['datetime'].isna().sum() + df['bid'].isna().sum() + df['ask'].isna().sum()
        
        if result.missing_data > 0:
            result.problems.append(f"Missing/NaN values: {result.missing_data:,}")
        
        # 5. Calculate clean percentage
        self.log("[5/5] Calculating clean data percentage...")
        result.clean_records = len(df_valid) - problems_mask.sum()
        result.clean_percentage = (result.clean_records / len(df_valid)) * 100 if len(df_valid) > 0 else 0
        
        return result
    
    def validate_bar_data(self, df: pd.DataFrame, result: ValidationResult, timeframe_minutes: int = 5) -> ValidationResult:
        """Validate bar data quality."""
        self.log("\n" + "="*60)
        self.log("VALIDATING BAR DATA")
        self.log("="*60)
        
        # Basic stats
        result.total_records = len(df)
        valid_datetime = df['datetime'].notna()
        df_valid = df[valid_datetime].copy()
        
        if len(df_valid) == 0:
            result.problems.append("CRITICAL: No valid datetime records found")
            return result
        
        df_valid = df_valid.sort_values('datetime')
        result.start_date = df_valid['datetime'].min()
        result.end_date = df_valid['datetime'].max()
        
        if result.start_date and result.end_date:
            days = (result.end_date - result.start_date).days
            result.months_coverage = days / 30.44
        
        self.log(f"\nPeriod: {result.start_date} to {result.end_date}")
        self.log(f"Coverage: {result.months_coverage:.1f} months")
        
        problems_mask = pd.Series(False, index=df_valid.index)
        
        # 1. Check for invalid prices
        self.log("\n[1/6] Checking for invalid prices...")
        price_cols = ['Open', 'High', 'Low', 'Close']
        invalid_prices = pd.Series(False, index=df_valid.index)
        
        for col in price_cols:
            if col in df_valid.columns:
                invalid_prices |= (df_valid[col] <= 0) | df_valid[col].isna()
        
        result.invalid_prices = invalid_prices.sum()
        problems_mask |= invalid_prices
        
        if result.invalid_prices > 0:
            result.problems.append(f"Invalid prices (<=0 or NaN): {result.invalid_prices:,}")
        
        # 2. Check OHLC consistency
        self.log("[2/6] Checking OHLC consistency...")
        if all(col in df_valid.columns for col in price_cols):
            ohlc_invalid = (
                (df_valid['High'] < df_valid['Low']) |
                (df_valid['High'] < df_valid['Open']) |
                (df_valid['High'] < df_valid['Close']) |
                (df_valid['Low'] > df_valid['Open']) |
                (df_valid['Low'] > df_valid['Close'])
            )
            ohlc_errors = ohlc_invalid.sum()
            problems_mask |= ohlc_invalid
            
            if ohlc_errors > 0:
                result.problems.append(f"OHLC consistency errors: {ohlc_errors:,}")
        
        # 3. Check for gaps
        self.log("[3/6] Checking for gaps...")
        df_valid['time_diff'] = df_valid['datetime'].diff()
        expected_gap = timedelta(minutes=timeframe_minutes)
        gap_threshold = expected_gap * self.GAP_THRESHOLD_BARS
        
        gaps = df_valid[df_valid['time_diff'] > gap_threshold].copy()
        
        real_gaps = []
        for idx in gaps.index:
            loc = df_valid.index.get_loc(idx)
            if loc > 0:
                prev_idx = df_valid.index[loc - 1]
                start_dt = df_valid.loc[prev_idx, 'datetime']
                end_dt = df_valid.loc[idx, 'datetime']
                gap_duration = df_valid.loc[idx, 'time_diff']
                
                if not self.is_gap_during_weekend(start_dt, end_dt):
                    gap_days = gap_duration.total_seconds() / 86400
                    real_gaps.append({
                        'start': start_dt,
                        'end': end_dt,
                        'duration': gap_duration,
                        'days': gap_days
                    })
                    if gap_days > self.MAX_GAP_DAYS:
                        result.gaps_over_1day += 1
        
        result.gaps_count = len(real_gaps)
        result.gap_details = real_gaps[:20]
        
        if result.gaps_count > 0:
            result.problems.append(f"Gaps (non-weekend): {result.gaps_count:,}")
        
        # 4. Check for zero volume
        self.log("[4/6] Checking for zero volume periods...")
        if 'Volume' in df_valid.columns:
            zero_vol = df_valid['Volume'] == 0
            
            # Find consecutive zero volume periods
            zero_runs = []
            run_length = 0
            run_start = None
            
            for idx, is_zero in zero_vol.items():
                if is_zero:
                    if run_length == 0:
                        run_start = idx
                    run_length += 1
                else:
                    if run_length >= self.ZERO_VOLUME_THRESHOLD:
                        zero_runs.append((run_start, run_length))
                    run_length = 0
            
            result.zero_volume_periods = len(zero_runs)
            
            if result.zero_volume_periods > 0:
                result.problems.append(f"Zero volume periods (>={self.ZERO_VOLUME_THRESHOLD} consecutive): {result.zero_volume_periods:,}")
        
        # 5. Check for anomalous spreads (using High-Low range)
        self.log("[5/6] Checking for anomalous bar ranges...")
        if 'High' in df_valid.columns and 'Low' in df_valid.columns:
            bar_range = (df_valid['High'] - df_valid['Low']) * 100  # in cents
            anomalous = bar_range > self.SPREAD_THRESHOLD * 10  # 10x normal spread for bar range
            result.anomalous_spreads = anomalous.sum()
            problems_mask |= anomalous
            
            if result.anomalous_spreads > 0:
                result.problems.append(f"Anomalous bar ranges: {result.anomalous_spreads:,}")
        
        # 6. Calculate clean percentage
        self.log("[6/6] Calculating clean data percentage...")
        result.clean_records = len(df_valid) - problems_mask.sum()
        result.clean_percentage = (result.clean_records / len(df_valid)) * 100 if len(df_valid) > 0 else 0
        
        return result
    
    # =========================================================================
    # GENIUS VALIDATION METHODS (v2.0)
    # =========================================================================
    
    def calculate_hurst_rs(self, prices: np.ndarray, window: int = 100) -> np.ndarray:
        """
        Calculate Hurst exponent using R/S method (rolling).
        
        Returns array of Hurst values for each valid window.
        H > 0.55: Trending
        0.45 < H < 0.55: Random walk
        H < 0.45: Mean reverting
        """
        if len(prices) < window:
            return np.array([0.5])
        
        hurst_values = []
        
        for i in range(window, len(prices)):
            window_prices = prices[i-window:i]
            returns = np.diff(np.log(window_prices + 1e-10))
            
            if len(returns) < 2:
                hurst_values.append(0.5)
                continue
            
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
            
            hurst_values.append(H)
        
        return np.array(hurst_values)
    
    def analyze_regimes(self, df: pd.DataFrame, result: ValidationResult) -> ValidationResult:
        """
        Analyze regime transitions (GENIUS Principle #3).
        
        Uses Hurst exponent to classify regimes:
        - TRENDING: H > 0.55
        - RANDOM: 0.45 <= H <= 0.55
        - REVERTING: H < 0.45
        """
        self.log("\n[GENIUS] Analyzing regime transitions...")
        
        # Get price series
        if 'mid_price' in df.columns:
            prices = df['mid_price'].dropna().values
        elif 'Close' in df.columns:
            prices = df['Close'].dropna().values
        elif 'bid' in df.columns and 'ask' in df.columns:
            prices = ((df['bid'] + df['ask']) / 2).dropna().values
        else:
            self.log("  WARNING: No price column found for regime analysis")
            return result
        
        if len(prices) < 200:
            self.log("  WARNING: Insufficient data for regime analysis (<200 points)")
            return result
        
        # Sample if too large
        if len(prices) > 100000:
            sample_idx = np.linspace(0, len(prices)-1, 100000, dtype=int)
            prices = prices[sample_idx]
        
        # Calculate Hurst
        hurst = self.calculate_hurst_rs(prices, window=100)
        
        # Classify regimes
        trending = hurst > 0.55
        reverting = hurst < 0.45
        random_walk = ~trending & ~reverting
        
        result.trending_pct = np.sum(trending) / len(hurst) * 100
        result.reverting_pct = np.sum(reverting) / len(hurst) * 100
        result.ranging_pct = np.sum(random_walk) / len(hurst) * 100
        
        # Count transitions
        regime_labels = np.where(trending, 1, np.where(reverting, -1, 0))
        transitions = np.sum(np.abs(np.diff(regime_labels)) > 0)
        result.regime_transitions = int(transitions)
        
        # Average transition duration (in bars)
        if transitions > 0:
            result.avg_transition_duration = len(hurst) / (transitions + 1)
        
        # Check diversity: trending >= 20%, reverting >= 10%, random >= 5%
        result.regime_diversity_ok = (
            result.trending_pct >= 20 and
            result.reverting_pct >= 10 and
            result.ranging_pct >= 5
        )
        
        self.log(f"  Trending: {result.trending_pct:.1f}%")
        self.log(f"  Reverting: {result.reverting_pct:.1f}%")
        self.log(f"  Random: {result.ranging_pct:.1f}%")
        self.log(f"  Transitions: {result.regime_transitions}")
        self.log(f"  Diversity OK: {result.regime_diversity_ok}")
        
        return result
    
    def analyze_volatility_clustering(self, df: pd.DataFrame, result: ValidationResult) -> ValidationResult:
        """
        Analyze volatility clustering (GARCH-like behavior).
        
        Real markets show autocorrelation in |returns| (volatility clusters).
        Synthetic data typically doesn't.
        """
        self.log("\n[GENIUS] Analyzing volatility clustering...")
        
        # Get returns
        if 'mid_price' in df.columns:
            prices = df['mid_price'].dropna()
        elif 'Close' in df.columns:
            prices = df['Close'].dropna()
        elif 'bid' in df.columns:
            prices = df['bid'].dropna()
        else:
            return result
        
        if len(prices) < 1000:
            self.log("  WARNING: Insufficient data for volatility analysis")
            return result
        
        # Sample if needed
        if len(prices) > 100000:
            prices = prices.iloc[::len(prices)//100000]
        
        returns = prices.pct_change().dropna()
        abs_returns = np.abs(returns)
        
        # Calculate autocorrelation at lag 1
        if len(abs_returns) > 10:
            autocorr = np.corrcoef(abs_returns[:-1], abs_returns[1:])[0, 1]
            result.volatility_autocorr = float(autocorr) if not np.isnan(autocorr) else 0.0
        
        # Real markets typically show autocorr > 0.1
        result.volatility_clustering_ok = result.volatility_autocorr > 0.1
        
        self.log(f"  Volatility Autocorr(1): {result.volatility_autocorr:.4f}")
        self.log(f"  Clustering OK (>0.1): {result.volatility_clustering_ok}")
        
        return result
    
    def analyze_session_coverage(self, df: pd.DataFrame, result: ValidationResult) -> ValidationResult:
        """
        Analyze trading session coverage.
        
        Sessions (UTC):
        - ASIA:    00:00-07:00
        - LONDON:  07:00-12:00
        - OVERLAP: 12:00-16:00
        - NY:      16:00-21:00
        - CLOSE:   21:00-00:00
        """
        self.log("\n[GENIUS] Analyzing session coverage...")
        
        # Get datetime column
        if 'datetime' in df.columns:
            dt_col = 'datetime'
        elif 'timestamp' in df.columns:
            dt_col = 'timestamp'
        else:
            self.log("  WARNING: No datetime column found")
            return result
        
        df_valid = df[df[dt_col].notna()].copy()
        if len(df_valid) == 0:
            return result
        
        hours = df_valid[dt_col].dt.hour
        
        # Define sessions
        sessions = {
            'ASIA': (hours >= 0) & (hours < 7),
            'LONDON': (hours >= 7) & (hours < 12),
            'OVERLAP': (hours >= 12) & (hours < 16),
            'NY': (hours >= 16) & (hours < 21),
            'CLOSE': (hours >= 21) | (hours < 0)
        }
        
        session_targets = {
            'ASIA': 5.0,
            'LONDON': 5.0,
            'OVERLAP': 5.0,
            'NY': 5.0,
            'CLOSE': 5.0
        }
        
        total = len(df_valid)
        result.session_coverage = {}
        all_ok = True
        
        for session, mask in sessions.items():
            pct = mask.sum() / total * 100
            target = session_targets[session]
            ok = pct >= target
            result.session_coverage[session] = {
                'pct': round(pct, 2),
                'target': target,
                'ok': ok
            }
            if not ok:
                all_ok = False
            self.log(f"  {session}: {pct:.2f}% (target >={target}%) {'OK' if ok else 'LOW'}")
        
        result.session_coverage_ok = all_ok
        
        return result
    
    def validate_mtf_consistency(self, m5_path: str = None, m15_path: str = None, 
                                  h1_path: str = None, result: ValidationResult = None) -> ValidationResult:
        """
        Validate MTF data consistency (GENIUS Principle #4).
        
        Checks:
        - H1.high == max(M5.high) for each hour
        - H1.low == min(M5.low) for each hour
        """
        if result is None:
            result = ValidationResult()
        
        if not m5_path or not h1_path:
            self.log("\n[GENIUS] MTF Consistency: Skipped (paths not provided)")
            return result
        
        self.log("\n[GENIUS] Validating MTF consistency...")
        
        try:
            m5_df = pd.read_csv(m5_path)
            h1_df = pd.read_csv(h1_path)
            
            # Parse datetime
            for df in [m5_df, h1_df]:
                if 'Date' in df.columns and 'Time' in df.columns:
                    df['datetime'] = pd.to_datetime(df['Date'] + ' ' + df['Time'])
                elif 'time' in df.columns:
                    df['datetime'] = pd.to_datetime(df['time'])
            
            # Group M5 by hour
            m5_df['hour'] = m5_df['datetime'].dt.floor('H')
            m5_grouped = m5_df.groupby('hour').agg({
                'High': 'max',
                'Low': 'min'
            }).reset_index()
            
            # Merge with H1
            h1_df['hour'] = h1_df['datetime'].dt.floor('H')
            merged = m5_grouped.merge(h1_df[['hour', 'High', 'Low']], on='hour', suffixes=('_m5', '_h1'))
            
            if len(merged) == 0:
                self.log("  WARNING: No matching hours found between M5 and H1")
                return result
            
            # Check consistency (with small tolerance for floating point)
            tolerance = 0.01
            high_match = np.abs(merged['High_m5'] - merged['High_h1']) < tolerance
            low_match = np.abs(merged['Low_m5'] - merged['Low_h1']) < tolerance
            
            consistent = high_match & low_match
            result.mtf_consistency_score = consistent.sum() / len(consistent) * 100
            result.mtf_checked = True
            
            self.log(f"  MTF Consistency: {result.mtf_consistency_score:.2f}%")
            
        except Exception as e:
            self.log(f"  ERROR during MTF validation: {e}")
        
        return result
    
    def calculate_quality_score_genius(self, result: ValidationResult) -> ValidationResult:
        """
        Calculate GENIUS Quality Score (0-100).
        
        Scoring:
        - Data Coverage (25 pts)
        - Clean Data % (25 pts)
        - Gap Analysis (15 pts)
        - Regime Diversity (15 pts)
        - Session Coverage (10 pts)
        - Spread Quality (10 pts)
        """
        self.log("\n[GENIUS] Calculating Quality Score...")
        
        score = 0
        breakdown = []
        
        # 1. Data Coverage (25 pts)
        months = result.months_coverage
        if months >= 60:
            pts = 25
        elif months >= 36:
            pts = 20
        elif months >= 24:
            pts = 15
        elif months >= 12:
            pts = 10
        else:
            pts = 5
        score += pts
        breakdown.append(f"  Coverage ({months:.0f} months): +{pts} pts")
        
        # 2. Clean Data % (25 pts)
        clean = result.clean_percentage
        if clean >= 99:
            pts = 25
        elif clean >= 97:
            pts = 20
        elif clean >= 95:
            pts = 15
        elif clean >= 90:
            pts = 10
        else:
            pts = 5
        score += pts
        breakdown.append(f"  Clean Data ({clean:.1f}%): +{pts} pts")
        
        # 3. Gap Analysis (15 pts)
        critical_gaps = result.gaps_over_1day
        if critical_gaps == 0:
            pts = 15
        elif critical_gaps <= 2:
            pts = 10
        elif critical_gaps <= 5:
            pts = 5
        else:
            pts = 0
        score += pts
        breakdown.append(f"  Gaps ({critical_gaps} critical): +{pts} pts")
        
        # 4. Regime Diversity (15 pts)
        if result.regime_diversity_ok and result.regime_transitions >= 50:
            pts = 15
        elif result.regime_diversity_ok:
            pts = 10
        elif result.trending_pct >= 15 or result.reverting_pct >= 5:
            pts = 5
        else:
            pts = 0
        score += pts
        breakdown.append(f"  Regime Diversity: +{pts} pts")
        
        # 5. Session Coverage (10 pts)
        if result.session_coverage_ok:
            pts = 10
        elif len([s for s in result.session_coverage.values() if s.get('ok', False)]) >= 3:
            pts = 5
        else:
            pts = 0
        score += pts
        breakdown.append(f"  Session Coverage: +{pts} pts")
        
        # 6. Volatility Clustering / Data Authenticity (10 pts)
        if result.volatility_clustering_ok:
            pts = 10
        elif result.volatility_autocorr > 0.05:
            pts = 5
        else:
            pts = 0
        score += pts
        breakdown.append(f"  Vol Clustering (autocorr={result.volatility_autocorr:.3f}): +{pts} pts")
        
        result.quality_score_genius = score
        
        for line in breakdown:
            self.log(line)
        self.log(f"  TOTAL GENIUS SCORE: {score}/100")
        
        return result
    
    def run_genius_validation(self, df: pd.DataFrame, result: ValidationResult,
                              m5_path: str = None, h1_path: str = None) -> ValidationResult:
        """Run all GENIUS validations."""
        self.log("\n" + "="*60)
        self.log("GENIUS VALIDATION (v2.0)")
        self.log("="*60)
        
        result = self.analyze_regimes(df, result)
        result = self.analyze_volatility_clustering(df, result)
        result = self.analyze_session_coverage(df, result)
        
        if m5_path and h1_path:
            result = self.validate_mtf_consistency(m5_path, h1_path, result=result)
        
        result = self.calculate_quality_score_genius(result)
        
        return result
    
    def check_approval_criteria(self, result: ValidationResult) -> ValidationResult:
        """Check if data meets approval criteria."""
        self.log("\n" + "="*60)
        self.log("CHECKING APPROVAL CRITERIA")
        self.log("="*60)
        
        approved = True
        
        # Criterion 1: Minimum 12 months of data
        if result.months_coverage >= self.MIN_MONTHS:
            result.approval_reasons.append(f"✅ Coverage: {result.months_coverage:.1f} months (>= {self.MIN_MONTHS})")
        else:
            result.approval_reasons.append(f"❌ Coverage: {result.months_coverage:.1f} months (< {self.MIN_MONTHS} required)")
            approved = False
        
        # Criterion 2: >= 95% clean data
        if result.clean_percentage >= self.MIN_CLEAN_PCT:
            result.approval_reasons.append(f"✅ Clean data: {result.clean_percentage:.2f}% (>= {self.MIN_CLEAN_PCT}%)")
        else:
            result.approval_reasons.append(f"❌ Clean data: {result.clean_percentage:.2f}% (< {self.MIN_CLEAN_PCT}% required)")
            approved = False
        
        # Criterion 3: No gaps > 1 day (except weekends)
        if result.gaps_over_1day == 0:
            result.approval_reasons.append(f"✅ No gaps > 1 day (except weekends)")
        else:
            result.approval_reasons.append(f"❌ Found {result.gaps_over_1day} gaps > 1 day (excluding weekends)")
            approved = False
        
        # GENIUS Criteria (v2.0)
        # Criterion 4: GENIUS Quality Score >= 90
        if result.quality_score_genius >= 90:
            result.approval_reasons.append(f"✅ GENIUS Score: {result.quality_score_genius}/100 (>= 90)")
        elif result.quality_score_genius >= 75:
            result.approval_reasons.append(f"⚠️ GENIUS Score: {result.quality_score_genius}/100 (75-89, acceptable)")
        else:
            result.approval_reasons.append(f"❌ GENIUS Score: {result.quality_score_genius}/100 (< 75)")
            approved = False
        
        # Criterion 5: Regime transitions >= 50
        if result.regime_transitions >= 50:
            result.approval_reasons.append(f"✅ Regime transitions: {result.regime_transitions} (>= 50)")
        elif result.regime_transitions >= 30:
            result.approval_reasons.append(f"⚠️ Regime transitions: {result.regime_transitions} (30-49)")
        else:
            result.approval_reasons.append(f"❌ Regime transitions: {result.regime_transitions} (< 30)")
        
        # Criterion 6: Volatility clustering (real data check)
        if result.volatility_clustering_ok:
            result.approval_reasons.append(f"✅ Volatility clustering OK (autocorr={result.volatility_autocorr:.3f})")
        else:
            result.approval_reasons.append(f"⚠️ Volatility clustering weak (autocorr={result.volatility_autocorr:.3f})")
        
        result.approved = approved
        return result
    
    def generate_report(self, result: ValidationResult, output_path: Optional[Path] = None) -> str:
        """Generate validation report."""
        
        lines = []
        lines.append("=" * 70)
        lines.append("XAUUSD DATA VALIDATION REPORT")
        lines.append("=" * 70)
        lines.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        lines.append("")
        
        # Summary
        lines.append("-" * 70)
        lines.append("SUMMARY")
        lines.append("-" * 70)
        lines.append(f"Total Records:     {result.total_records:,}")
        lines.append(f"Period Start:      {result.start_date}")
        lines.append(f"Period End:        {result.end_date}")
        lines.append(f"Coverage:          {result.months_coverage:.1f} months")
        lines.append(f"Clean Records:     {result.clean_records:,}")
        lines.append(f"Clean Percentage:  {result.clean_percentage:.2f}%")
        lines.append("")
        
        # Problem Statistics
        lines.append("-" * 70)
        lines.append("PROBLEM STATISTICS")
        lines.append("-" * 70)
        lines.append(f"Invalid Prices:    {result.invalid_prices:,}")
        lines.append(f"Anomalous Spreads: {result.anomalous_spreads:,}")
        lines.append(f"Data Gaps:         {result.gaps_count:,}")
        lines.append(f"Gaps > 1 Day:      {result.gaps_over_1day:,}")
        lines.append(f"Missing Data:      {result.missing_data:,}")
        lines.append(f"Zero Vol Periods:  {result.zero_volume_periods:,}")
        lines.append("")
        
        # Problem Details
        if result.problems:
            lines.append("-" * 70)
            lines.append("PROBLEM DETAILS")
            lines.append("-" * 70)
            for problem in result.problems:
                lines.append(problem)
            lines.append("")
        
        # Approval Criteria
        lines.append("-" * 70)
        lines.append("APPROVAL CRITERIA")
        lines.append("-" * 70)
        for reason in result.approval_reasons:
            lines.append(reason)
        lines.append("")
        
        # Final Verdict
        lines.append("=" * 70)
        if result.approved:
            lines.append("RESULT: ✅ APPROVED FOR BACKTESTING")
        else:
            lines.append("RESULT: ❌ NOT APPROVED - See issues above")
        lines.append("=" * 70)
        
        report = "\n".join(lines)
        
        # Save to file if path provided
        if output_path:
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(report)
            self.log(f"\nReport saved to: {output_path}")
        
        return report
    
    def validate_file(self, filepath: Path, sample_size: Optional[int] = None, 
                      timeframe_minutes: int = 5, 
                      m5_path: str = None, h1_path: str = None,
                      run_genius: bool = True) -> ValidationResult:
        """
        Main validation entry point.
        
        Args:
            filepath: Path to data file
            sample_size: Sample size for large files
            timeframe_minutes: Timeframe for bar data
            m5_path: Optional M5 bar data path for MTF validation
            h1_path: Optional H1 bar data path for MTF validation
            run_genius: Whether to run GENIUS validation (default: True)
        """
        
        result = ValidationResult()
        
        if not filepath.exists():
            result.problems.append(f"ERROR: File not found: {filepath}")
            return result
        
        # Detect data type
        data_type = self.detect_data_type(filepath)
        self.log(f"Detected data type: {data_type}")
        
        if data_type == 'ticks':
            if filepath.suffix.lower() in ('.parquet', '.pq'):
                df = self.load_parquet_ticks(filepath, sample_size)
            else:
                df = self.load_tick_data(filepath, sample_size)
            result = self.validate_tick_data(df, result)
        elif data_type == 'bars':
            df = self.load_bar_data(filepath)
            result = self.validate_bar_data(df, result, timeframe_minutes)
        else:
            result.problems.append(f"ERROR: Unknown data format")
            return result
        
        # Run GENIUS validation (v2.0)
        if run_genius and len(df) > 0:
            result = self.run_genius_validation(df, result, m5_path, h1_path)
        
        # Check approval criteria
        result = self.check_approval_criteria(result)
        
        return result


def main():
    parser = argparse.ArgumentParser(
        description='XAUUSD Historical Data Validator v2.0 (GENIUS Edition)',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Validate tick data (full)
  python validate_data.py path/to/ticks.csv
  
  # Validate with sampling (faster for large files)
  python validate_data.py path/to/ticks.csv --sample 1000000
  
  # Validate M5 bar data
  python validate_data.py path/to/bars.csv --timeframe 5
  
  # Validate with MTF consistency check
  python validate_data.py path/to/ticks.csv --m5 path/to/m5.csv --h1 path/to/h1.csv
  
  # Save report to file
  python validate_data.py path/to/data.csv --output report.txt
  
  # Skip GENIUS validation (faster, basic only)
  python validate_data.py path/to/data.csv --no-genius
        """
    )
    
    parser.add_argument('filepath', type=str, help='Path to CSV data file')
    parser.add_argument('--sample', type=int, default=None, 
                        help='Sample size for large files (default: load all)')
    parser.add_argument('--timeframe', type=int, default=5,
                        help='Timeframe in minutes for bar data (default: 5)')
    parser.add_argument('--output', '-o', type=str, default=None,
                        help='Output path for report (default: print to console)')
    parser.add_argument('--quiet', '-q', action='store_true',
                        help='Suppress progress messages')
    parser.add_argument('--m5', type=str, default=None,
                        help='Path to M5 bar data for MTF validation')
    parser.add_argument('--h1', type=str, default=None,
                        help='Path to H1 bar data for MTF validation')
    parser.add_argument('--no-genius', action='store_true',
                        help='Skip GENIUS validation (faster, basic only)')
    
    args = parser.parse_args()
    
    filepath = Path(args.filepath)
    output_path = Path(args.output) if args.output else None
    
    validator = XAUUSDDataValidator(verbose=not args.quiet)
    
    print(f"\nValidating: {filepath}")
    print(f"File size: {filepath.stat().st_size / (1024**3):.2f} GB")
    if not args.no_genius:
        print("GENIUS validation: ENABLED")
    
    result = validator.validate_file(
        filepath,
        sample_size=args.sample,
        timeframe_minutes=args.timeframe,
        m5_path=args.m5,
        h1_path=args.h1,
        run_genius=not args.no_genius
    )
    
    report = validator.generate_report(result, output_path)
    
    # Print with safe encoding for Windows console
    try:
        print("\n" + report)
    except UnicodeEncodeError:
        # Fallback: replace unicode chars with ASCII equivalents
        safe_report = report.replace('✅', '[OK]').replace('❌', '[FAIL]').replace('⚠️', '[WARN]')
        print("\n" + safe_report)
    
    # Exit code: 0 if approved, 1 if not
    sys.exit(0 if result.approved else 1)


if __name__ == '__main__':
    main()
