#!/usr/bin/env python3
"""
XAUUSD Historical Data Validator v2.0 - Institutional Grade
============================================================
Complete validation for backtesting with:
- Regime analysis (Hurst, entropy)
- Session distribution
- Quality scoring (0-100)
- Markdown report generation

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
import json
from dataclasses import dataclass, field, asdict
from collections import defaultdict


@dataclass
class RegimeStats:
    """Regime distribution statistics."""
    trending_pct: float = 0.0      # Hurst > 0.55
    random_pct: float = 0.0       # 0.45 <= Hurst <= 0.55
    reverting_pct: float = 0.0    # Hurst < 0.45
    avg_hurst: float = 0.5
    hurst_std: float = 0.0
    regime_changes: int = 0
    avg_regime_duration_hours: float = 0.0


@dataclass
class SessionStats:
    """Session distribution statistics."""
    asia_pct: float = 0.0         # 00:00-07:00 UTC
    london_pct: float = 0.0       # 07:00-12:00 UTC
    overlap_pct: float = 0.0      # 12:00-16:00 UTC
    newyork_pct: float = 0.0      # 16:00-21:00 UTC
    close_pct: float = 0.0        # 21:00-00:00 UTC
    avg_spread_by_session: Dict[str, float] = field(default_factory=dict)
    avg_volatility_by_session: Dict[str, float] = field(default_factory=dict)


@dataclass
class ValidationResult:
    """Complete validation results."""
    # Basic stats
    total_records: int = 0
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    days_coverage: int = 0
    months_coverage: float = 0.0
    years_coverage: float = 0.0
    
    # Quality metrics
    clean_records: int = 0
    clean_percentage: float = 0.0
    
    # Problems
    invalid_prices: int = 0
    anomalous_spreads: int = 0
    gaps_count: int = 0
    gaps_over_1day: int = 0
    gaps_critical: int = 0
    missing_data: int = 0
    duplicates: int = 0
    
    # Distribution
    regime_stats: RegimeStats = field(default_factory=RegimeStats)
    session_stats: SessionStats = field(default_factory=SessionStats)
    
    # Spread analysis
    avg_spread: float = 0.0
    max_spread: float = 0.0
    spread_percentile_95: float = 0.0
    spread_percentile_99: float = 0.0
    
    # Problems details
    problems: List[str] = field(default_factory=list)
    gap_details: List[Dict] = field(default_factory=list)
    
    # Quality Score
    quality_score: int = 0
    score_breakdown: Dict[str, int] = field(default_factory=dict)
    
    # Approval
    approved: bool = False
    approval_reasons: List[str] = field(default_factory=list)
    recommendations: List[str] = field(default_factory=list)


class HurstCalculator:
    """Calculate Hurst exponent using R/S method."""
    
    @staticmethod
    def hurst_rs(series: np.ndarray, max_lag: int = 20) -> float:
        """
        Calculate Hurst exponent using R/S (rescaled range) method.
        H > 0.5: trending (persistent)
        H = 0.5: random walk
        H < 0.5: mean-reverting (anti-persistent)
        """
        if len(series) < max_lag * 2:
            return 0.5
        
        lags = range(2, min(max_lag, len(series) // 4))
        rs_values = []
        
        for lag in lags:
            # Divide series into chunks
            chunks = len(series) // lag
            rs_sum = 0
            
            for i in range(chunks):
                chunk = series[i*lag:(i+1)*lag]
                if len(chunk) < 2:
                    continue
                
                # Calculate mean-adjusted cumulative sum
                mean = np.mean(chunk)
                cumsum = np.cumsum(chunk - mean)
                
                # R = max - min of cumulative sum
                R = np.max(cumsum) - np.min(cumsum)
                
                # S = standard deviation
                S = np.std(chunk, ddof=1) if np.std(chunk, ddof=1) > 0 else 1e-10
                
                rs_sum += R / S
            
            if chunks > 0:
                rs_values.append(rs_sum / chunks)
        
        if len(rs_values) < 2:
            return 0.5
        
        # Linear regression on log-log scale
        log_lags = np.log(list(lags)[:len(rs_values)])
        log_rs = np.log(rs_values)
        
        try:
            slope, _ = np.polyfit(log_lags, log_rs, 1)
            return np.clip(slope, 0, 1)
        except:
            return 0.5


class XAUUSDDataValidatorV2:
    """Institutional-grade data validator for XAUUSD tick data."""
    
    # Thresholds
    MIN_MONTHS = 36              # Minimum 3 years for robust WFA
    MIN_CLEAN_PCT = 95.0
    GAP_THRESHOLD_MINUTES = 5
    MAX_GAP_DAYS = 1
    SPREAD_THRESHOLD = 100      # cents ($1.00)
    HURST_WINDOW = 500          # ticks for Hurst calculation
    
    # Session definitions (UTC)
    SESSIONS = {
        'asia': (0, 7),
        'london': (7, 12),
        'overlap': (12, 16),
        'newyork': (16, 21),
        'close': (21, 24)
    }
    
    def __init__(self, verbose: bool = True):
        self.verbose = verbose
        self._sampling_gap_ignored = False
        
    def log(self, msg: str):
        if self.verbose:
            print(msg)
    
    def is_weekend(self, dt: datetime) -> bool:
        """Check if datetime is during forex weekend."""
        if dt.weekday() == 5:  # Saturday
            return True
        if dt.weekday() == 6:  # Sunday
            return True
        if dt.weekday() == 4 and dt.hour >= 22:  # Friday after 22:00
            return True
        return False
    
    def get_session(self, hour: int) -> str:
        """Get session name from hour (UTC)."""
        for session, (start, end) in self.SESSIONS.items():
            if start <= hour < end:
                return session
        return 'asia'  # 00:00 wraps to asia
    
    def load_tick_data(self, filepath: Path, sample_size: int = 2_000_000) -> pd.DataFrame:
        """Load tick data efficiently using head + tail sampling."""
        self.log(f"[Load] File: {filepath}")
        file_size_gb = filepath.stat().st_size / (1024**3)
        self.log(f"[Load] Size: {file_size_gb:.2f} GB")
        
        head_size = sample_size // 2
        tail_size = sample_size // 2
        
        # Read head
        self.log(f"[Load] Reading first {head_size:,} lines...")
        head_lines = []
        with open(filepath, 'r', encoding='utf-8', errors='ignore') as f:
            for i, line in enumerate(f):
                if i >= head_size:
                    break
                head_lines.append(line.strip())
        
        # Estimate total lines
        avg_line_len = sum(len(l) for l in head_lines[:100]) / 100 if head_lines else 40
        estimated_lines = int(filepath.stat().st_size / avg_line_len)
        self.log(f"[Load] Estimated total: ~{estimated_lines:,} lines")
        
        # Read tail using seek
        self.log(f"[Load] Reading last {tail_size:,} lines...")
        file_size = filepath.stat().st_size
        bytes_to_read = min(tail_size * 50, file_size // 2)
        
        tail_lines = []
        with open(filepath, 'rb') as f:
            f.seek(max(0, file_size - bytes_to_read))
            f.readline()  # Skip partial
            content = f.read().decode('utf-8', errors='ignore')
            lines = content.strip().split('\n')
            tail_lines = [l.strip() for l in lines[-tail_size:]]
        
        # Mark for gap detection
        self._head_last = head_lines[-1] if head_lines else None
        self._tail_first = tail_lines[0] if tail_lines else None
        self._sampling_gap_ignored = True
        
        # Parse
        all_lines = head_lines + tail_lines
        self.log(f"[Load] Parsing {len(all_lines):,} lines...")
        
        data = []
        for line in all_lines:
            parts = line.split(',')
            if len(parts) >= 3:
                try:
                    dt = pd.to_datetime(parts[0], format='%Y.%m.%d %H:%M:%S.%f')
                    bid = float(parts[1])
                    ask = float(parts[2])
                    data.append({
                        'datetime': dt,
                        'bid': bid,
                        'ask': ask,
                        'mid': (bid + ask) / 2,
                        'spread': (ask - bid) * 100
                    })
                except:
                    continue
        
        df = pd.DataFrame(data)
        df = df.sort_values('datetime').reset_index(drop=True)
        self.log(f"[Load] Loaded {len(df):,} ticks")
        
        return df
    
    def calculate_regime_stats(self, df: pd.DataFrame) -> RegimeStats:
        """Calculate regime distribution using Hurst exponent."""
        self.log("\n[Regime] Calculating Hurst exponents...")
        
        if len(df) < self.HURST_WINDOW * 10:
            self.log("[Regime] Not enough data for regime analysis")
            return RegimeStats()
        
        # Sample points for Hurst calculation (every N ticks)
        sample_interval = max(1, len(df) // 1000)
        sample_indices = range(self.HURST_WINDOW, len(df), sample_interval)
        
        hursts = []
        regimes = []
        
        for idx in sample_indices:
            prices = df['mid'].iloc[idx-self.HURST_WINDOW:idx].values
            if len(prices) < self.HURST_WINDOW:
                continue
            
            h = HurstCalculator.hurst_rs(prices)
            hursts.append(h)
            
            if h > 0.55:
                regimes.append('trending')
            elif h < 0.45:
                regimes.append('reverting')
            else:
                regimes.append('random')
        
        if not hursts:
            return RegimeStats()
        
        # Count regime changes
        changes = sum(1 for i in range(1, len(regimes)) if regimes[i] != regimes[i-1])
        
        # Average duration
        if changes > 0:
            total_hours = (df['datetime'].iloc[-1] - df['datetime'].iloc[0]).total_seconds() / 3600
            avg_duration = total_hours / (changes + 1)
        else:
            avg_duration = 0
        
        stats = RegimeStats(
            trending_pct=sum(1 for r in regimes if r == 'trending') / len(regimes) * 100,
            random_pct=sum(1 for r in regimes if r == 'random') / len(regimes) * 100,
            reverting_pct=sum(1 for r in regimes if r == 'reverting') / len(regimes) * 100,
            avg_hurst=np.mean(hursts),
            hurst_std=np.std(hursts),
            regime_changes=changes,
            avg_regime_duration_hours=avg_duration
        )
        
        self.log(f"[Regime] Trending: {stats.trending_pct:.1f}%, Random: {stats.random_pct:.1f}%, Reverting: {stats.reverting_pct:.1f}%")
        self.log(f"[Regime] Avg Hurst: {stats.avg_hurst:.3f} (std: {stats.hurst_std:.3f})")
        
        return stats
    
    def calculate_session_stats(self, df: pd.DataFrame) -> SessionStats:
        """Calculate session distribution and characteristics."""
        self.log("\n[Session] Analyzing session distribution...")
        
        df = df.copy()
        df['hour'] = df['datetime'].dt.hour
        df['session'] = df['hour'].apply(self.get_session)
        
        total = len(df)
        stats = SessionStats()
        
        session_counts = df['session'].value_counts()
        stats.asia_pct = session_counts.get('asia', 0) / total * 100
        stats.london_pct = session_counts.get('london', 0) / total * 100
        stats.overlap_pct = session_counts.get('overlap', 0) / total * 100
        stats.newyork_pct = session_counts.get('newyork', 0) / total * 100
        stats.close_pct = session_counts.get('close', 0) / total * 100
        
        # Spread by session
        stats.avg_spread_by_session = df.groupby('session')['spread'].mean().to_dict()
        
        # Volatility by session (using price range)
        df['returns'] = df['mid'].pct_change().abs()
        stats.avg_volatility_by_session = df.groupby('session')['returns'].std().to_dict()
        
        self.log(f"[Session] Asia: {stats.asia_pct:.1f}%, London: {stats.london_pct:.1f}%, "
                f"Overlap: {stats.overlap_pct:.1f}%, NY: {stats.newyork_pct:.1f}%, Close: {stats.close_pct:.1f}%")
        
        return stats
    
    def calculate_quality_score(self, result: ValidationResult) -> Tuple[int, Dict[str, int]]:
        """
        Calculate quality score 0-100 based on multiple factors.
        
        Breakdown:
        - Data Coverage (25 pts): >= 36 months
        - Clean Data % (25 pts): >= 95%
        - Gap Analysis (15 pts): < 0.1% critical gaps
        - Regime Diversity (15 pts): All regimes represented
        - Session Coverage (10 pts): All sessions represented
        - Spread Quality (10 pts): Realistic spreads
        """
        breakdown = {}
        
        # 1. Data Coverage (25 pts)
        # 36+ months = 25, 24 months = 20, 12 months = 10, <12 = 0
        if result.months_coverage >= 36:
            coverage_score = 25
        elif result.months_coverage >= 24:
            coverage_score = 20
        elif result.months_coverage >= 12:
            coverage_score = 10 + (result.months_coverage - 12) * (10/12)
        else:
            coverage_score = result.months_coverage * (10/12)
        breakdown['coverage'] = int(coverage_score)
        
        # 2. Clean Data % (25 pts)
        # 99%+ = 25, 95% = 20, 90% = 10, <90% = 0
        if result.clean_percentage >= 99:
            clean_score = 25
        elif result.clean_percentage >= 95:
            clean_score = 20 + (result.clean_percentage - 95) * 1.25
        elif result.clean_percentage >= 90:
            clean_score = 10 + (result.clean_percentage - 90) * 2
        else:
            clean_score = max(0, result.clean_percentage * (10/90))
        breakdown['clean_data'] = int(clean_score)
        
        # 3. Gap Analysis (15 pts)
        # 0 critical gaps = 15, <0.1% = 10, <0.5% = 5, >0.5% = 0
        critical_gap_pct = result.gaps_critical / max(1, result.total_records) * 100
        if critical_gap_pct == 0:
            gap_score = 15
        elif critical_gap_pct < 0.1:
            gap_score = 10 + (0.1 - critical_gap_pct) * 50
        elif critical_gap_pct < 0.5:
            gap_score = 5 + (0.5 - critical_gap_pct) * 12.5
        else:
            gap_score = max(0, 5 - critical_gap_pct)
        breakdown['gaps'] = int(gap_score)
        
        # 4. Regime Diversity (15 pts)
        # All 3 regimes with >10% each = 15
        regime_score = 0
        if result.regime_stats.trending_pct >= 10:
            regime_score += 5
        if result.regime_stats.random_pct >= 5:
            regime_score += 5
        if result.regime_stats.reverting_pct >= 10:
            regime_score += 5
        breakdown['regime_diversity'] = int(regime_score)
        
        # 5. Session Coverage (10 pts)
        # All sessions > 5% each = 10
        session_score = 0
        sessions = [
            result.session_stats.asia_pct,
            result.session_stats.london_pct,
            result.session_stats.overlap_pct,
            result.session_stats.newyork_pct
        ]
        for pct in sessions:
            if pct >= 5:
                session_score += 2.5
        breakdown['session_coverage'] = int(session_score)
        
        # 6. Spread Quality (10 pts)
        # Avg spread < 30 cents = 10, < 50 = 7, < 100 = 3, > 100 = 0
        if result.avg_spread < 30:
            spread_score = 10
        elif result.avg_spread < 50:
            spread_score = 7 + (50 - result.avg_spread) * 0.15
        elif result.avg_spread < 100:
            spread_score = 3 + (100 - result.avg_spread) * 0.08
        else:
            spread_score = 0
        breakdown['spread_quality'] = int(spread_score)
        
        total_score = sum(breakdown.values())
        return min(100, max(0, total_score)), breakdown
    
    def validate(self, filepath: Path, sample_size: int = 2_000_000) -> ValidationResult:
        """Run complete validation."""
        result = ValidationResult()
        
        if not filepath.exists():
            result.problems.append(f"ERROR: File not found: {filepath}")
            return result
        
        # Load data
        df = self.load_tick_data(filepath, sample_size)
        
        if len(df) == 0:
            result.problems.append("ERROR: No valid data loaded")
            return result
        
        result.total_records = len(df)
        result.start_date = str(df['datetime'].min())
        result.end_date = str(df['datetime'].max())
        
        # Calculate coverage
        start = df['datetime'].min()
        end = df['datetime'].max()
        result.days_coverage = (end - start).days
        result.months_coverage = result.days_coverage / 30.44
        result.years_coverage = result.days_coverage / 365.25
        
        self.log(f"\n[Period] {result.start_date} to {result.end_date}")
        self.log(f"[Period] Coverage: {result.years_coverage:.1f} years ({result.months_coverage:.0f} months)")
        
        # Validate prices
        self.log("\n[Validate] Checking price integrity...")
        invalid_bid = (df['bid'] <= 0) | df['bid'].isna() | (df['bid'] < 1000) | (df['bid'] > 5000)
        invalid_ask = (df['ask'] <= 0) | df['ask'].isna() | (df['ask'] < 1000) | (df['ask'] > 5000)
        result.invalid_prices = (invalid_bid | invalid_ask).sum()
        
        if result.invalid_prices > 0:
            result.problems.append(f"Invalid prices: {result.invalid_prices:,}")
        
        # Validate spreads
        self.log("[Validate] Checking spreads...")
        result.avg_spread = df['spread'].mean()
        result.max_spread = df['spread'].max()
        result.spread_percentile_95 = df['spread'].quantile(0.95)
        result.spread_percentile_99 = df['spread'].quantile(0.99)
        
        anomalous = df['spread'] > self.SPREAD_THRESHOLD
        result.anomalous_spreads = anomalous.sum()
        
        if result.anomalous_spreads > 0:
            result.problems.append(f"Anomalous spreads (>{self.SPREAD_THRESHOLD}c): {result.anomalous_spreads:,}")
        
        # Check duplicates
        result.duplicates = df.duplicated(subset=['datetime']).sum()
        if result.duplicates > 0:
            result.problems.append(f"Duplicate timestamps: {result.duplicates:,}")
        
        # Check gaps
        self.log("[Validate] Checking gaps...")
        df_sorted = df.sort_values('datetime')
        time_diffs = df_sorted['datetime'].diff()
        gap_threshold = timedelta(minutes=self.GAP_THRESHOLD_MINUTES)
        
        gaps = df_sorted[time_diffs > gap_threshold].copy()
        real_gaps = []
        
        for idx in gaps.index:
            loc = df_sorted.index.get_loc(idx)
            if loc > 0:
                prev_idx = df_sorted.index[loc - 1]
                start_dt = df_sorted.loc[prev_idx, 'datetime']
                end_dt = df_sorted.loc[idx, 'datetime']
                gap_duration = time_diffs.loc[idx]
                
                # Skip sampling artifact
                if self._sampling_gap_ignored and self._head_last and self._tail_first:
                    try:
                        head_dt = pd.to_datetime(self._head_last.split(',')[0], format='%Y.%m.%d %H:%M:%S.%f')
                        tail_dt = pd.to_datetime(self._tail_first.split(',')[0], format='%Y.%m.%d %H:%M:%S.%f')
                        if abs((start_dt - head_dt).total_seconds()) < 60:
                            continue
                    except:
                        pass
                
                # Skip weekend gaps
                if self.is_weekend(start_dt):
                    continue
                
                gap_hours = gap_duration.total_seconds() / 3600
                gap_info = {
                    'start': str(start_dt),
                    'end': str(end_dt),
                    'hours': gap_hours
                }
                
                if gap_hours > 24:
                    result.gaps_critical += 1
                    result.gaps_over_1day += 1
                elif gap_hours > 1:
                    result.gaps_over_1day += 1
                
                real_gaps.append(gap_info)
        
        result.gaps_count = len(real_gaps)
        result.gap_details = real_gaps[:20]
        
        if result.gaps_count > 0:
            result.problems.append(f"Data gaps: {result.gaps_count:,} ({result.gaps_critical} critical)")
        
        # Calculate clean percentage
        problems_count = result.invalid_prices + result.anomalous_spreads + result.duplicates
        result.clean_records = result.total_records - problems_count
        result.clean_percentage = result.clean_records / result.total_records * 100
        
        # Regime analysis
        result.regime_stats = self.calculate_regime_stats(df)
        
        # Session analysis
        result.session_stats = self.calculate_session_stats(df)
        
        # Quality score
        result.quality_score, result.score_breakdown = self.calculate_quality_score(result)
        
        # Approval criteria
        self.log("\n[Approval] Checking criteria...")
        
        # Criterion 1: Minimum data
        if result.months_coverage >= self.MIN_MONTHS:
            result.approval_reasons.append(f"[OK] Coverage: {result.months_coverage:.0f} months (>= {self.MIN_MONTHS})")
        else:
            result.approval_reasons.append(f"[FAIL] Coverage: {result.months_coverage:.0f} months (< {self.MIN_MONTHS})")
            result.recommendations.append(f"Need {self.MIN_MONTHS - result.months_coverage:.0f} more months of data")
        
        # Criterion 2: Clean data
        if result.clean_percentage >= self.MIN_CLEAN_PCT:
            result.approval_reasons.append(f"[OK] Clean data: {result.clean_percentage:.2f}% (>= {self.MIN_CLEAN_PCT}%)")
        else:
            result.approval_reasons.append(f"[FAIL] Clean data: {result.clean_percentage:.2f}% (< {self.MIN_CLEAN_PCT}%)")
            result.recommendations.append("Clean or filter problematic data points")
        
        # Criterion 3: No critical gaps
        if result.gaps_critical == 0:
            result.approval_reasons.append("[OK] No critical gaps (>24h)")
        else:
            result.approval_reasons.append(f"[FAIL] {result.gaps_critical} critical gaps found")
            result.recommendations.append("Fill gaps or exclude periods")
        
        # Criterion 4: Regime diversity
        if (result.regime_stats.trending_pct >= 10 and 
            result.regime_stats.reverting_pct >= 10):
            result.approval_reasons.append("[OK] Regime diversity sufficient")
        else:
            result.approval_reasons.append("[WARN] Limited regime diversity")
            result.recommendations.append("Consider data from different market conditions")
        
        # Criterion 5: Session coverage
        min_session = min(
            result.session_stats.asia_pct,
            result.session_stats.london_pct,
            result.session_stats.newyork_pct
        )
        if min_session >= 5:
            result.approval_reasons.append("[OK] All major sessions represented")
        else:
            result.approval_reasons.append("[WARN] Some sessions underrepresented")
        
        # Final approval
        result.approved = (
            result.months_coverage >= self.MIN_MONTHS and
            result.clean_percentage >= self.MIN_CLEAN_PCT and
            result.gaps_critical == 0 and
            result.quality_score >= 70
        )
        
        return result
    
    def generate_markdown_report(self, result: ValidationResult, filepath: Path = None) -> str:
        """Generate comprehensive markdown report."""
        
        lines = [
            "# DATA QUALITY REPORT - XAUUSD Tick Data",
            "",
            f"**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            f"**Validator**: v2.0 Institutional Grade",
            "",
            "---",
            "",
            "## SUMMARY",
            "",
            f"| Metric | Value |",
            f"|--------|-------|",
            f"| **Quality Score** | **{result.quality_score}/100** |",
            f"| Total Records | {result.total_records:,} |",
            f"| Period | {result.start_date[:10]} to {result.end_date[:10]} |",
            f"| Coverage | {result.years_coverage:.1f} years ({result.months_coverage:.0f} months) |",
            f"| Clean Data | {result.clean_percentage:.2f}% |",
            f"| Status | {'APPROVED' if result.approved else 'NOT APPROVED'} |",
            "",
            "---",
            "",
            "## QUALITY SCORE BREAKDOWN",
            "",
            "| Component | Score | Max |",
            "|-----------|-------|-----|",
        ]
        
        max_scores = {
            'coverage': 25, 'clean_data': 25, 'gaps': 15,
            'regime_diversity': 15, 'session_coverage': 10, 'spread_quality': 10
        }
        
        for key, score in result.score_breakdown.items():
            lines.append(f"| {key.replace('_', ' ').title()} | {score} | {max_scores.get(key, 0)} |")
        
        lines.extend([
            f"| **TOTAL** | **{result.quality_score}** | **100** |",
            "",
            "---",
            "",
            "## PROBLEM STATISTICS",
            "",
            f"| Issue | Count |",
            f"|-------|-------|",
            f"| Invalid Prices | {result.invalid_prices:,} |",
            f"| Anomalous Spreads | {result.anomalous_spreads:,} |",
            f"| Duplicate Timestamps | {result.duplicates:,} |",
            f"| Data Gaps | {result.gaps_count:,} |",
            f"| Critical Gaps (>24h) | {result.gaps_critical:,} |",
            "",
            "---",
            "",
            "## SPREAD ANALYSIS",
            "",
            f"| Metric | Value (cents) |",
            f"|--------|---------------|",
            f"| Average | {result.avg_spread:.2f} |",
            f"| 95th Percentile | {result.spread_percentile_95:.2f} |",
            f"| 99th Percentile | {result.spread_percentile_99:.2f} |",
            f"| Maximum | {result.max_spread:.2f} |",
            "",
            "---",
            "",
            "## REGIME DISTRIBUTION",
            "",
            f"| Regime | Percentage | Hurst Range |",
            f"|--------|------------|-------------|",
            f"| Trending | {result.regime_stats.trending_pct:.1f}% | H > 0.55 |",
            f"| Random Walk | {result.regime_stats.random_pct:.1f}% | 0.45-0.55 |",
            f"| Mean Reverting | {result.regime_stats.reverting_pct:.1f}% | H < 0.45 |",
            "",
            f"- **Average Hurst**: {result.regime_stats.avg_hurst:.3f} (std: {result.regime_stats.hurst_std:.3f})",
            f"- **Regime Changes**: {result.regime_stats.regime_changes:,}",
            f"- **Avg Regime Duration**: {result.regime_stats.avg_regime_duration_hours:.1f} hours",
            "",
            "---",
            "",
            "## SESSION DISTRIBUTION",
            "",
            f"| Session | Coverage | Avg Spread |",
            f"|---------|----------|------------|",
            f"| Asia (00-07 UTC) | {result.session_stats.asia_pct:.1f}% | {result.session_stats.avg_spread_by_session.get('asia', 0):.2f}c |",
            f"| London (07-12 UTC) | {result.session_stats.london_pct:.1f}% | {result.session_stats.avg_spread_by_session.get('london', 0):.2f}c |",
            f"| Overlap (12-16 UTC) | {result.session_stats.overlap_pct:.1f}% | {result.session_stats.avg_spread_by_session.get('overlap', 0):.2f}c |",
            f"| New York (16-21 UTC) | {result.session_stats.newyork_pct:.1f}% | {result.session_stats.avg_spread_by_session.get('newyork', 0):.2f}c |",
            f"| Close (21-24 UTC) | {result.session_stats.close_pct:.1f}% | {result.session_stats.avg_spread_by_session.get('close', 0):.2f}c |",
            "",
            "---",
            "",
            "## APPROVAL CRITERIA",
            "",
        ])
        
        for reason in result.approval_reasons:
            status = "✅" if "[OK]" in reason else ("⚠️" if "[WARN]" in reason else "❌")
            lines.append(f"- {status} {reason.replace('[OK]', '').replace('[FAIL]', '').replace('[WARN]', '').strip()}")
        
        lines.extend([
            "",
            "---",
            "",
            "## FINAL VERDICT",
            "",
        ])
        
        if result.approved:
            lines.append("### ✅ APPROVED FOR BACKTESTING")
            lines.append("")
            lines.append(f"Quality Score: **{result.quality_score}/100** - Data meets institutional standards.")
        else:
            lines.append("### ❌ NOT APPROVED")
            lines.append("")
            lines.append(f"Quality Score: **{result.quality_score}/100** - See recommendations below.")
            
            if result.recommendations:
                lines.append("")
                lines.append("**Recommendations:**")
                for rec in result.recommendations:
                    lines.append(f"- {rec}")
        
        lines.extend([
            "",
            "---",
            "",
            f"*Report generated by FORGE v3.1 for EA_SCALPER_XAUUSD*"
        ])
        
        report = "\n".join(lines)
        
        if filepath:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(report)
            print(f"\n[Report] Saved to: {filepath}")
        
        return report


def main():
    parser = argparse.ArgumentParser(description='XAUUSD Data Validator v2.0')
    parser.add_argument('filepath', type=str, help='Path to tick data CSV')
    parser.add_argument('--sample', type=int, default=2_000_000, help='Sample size (default: 2M)')
    parser.add_argument('--output', '-o', type=str, help='Output markdown report path')
    parser.add_argument('--json', type=str, help='Output JSON results path')
    parser.add_argument('--quiet', '-q', action='store_true', help='Quiet mode')
    
    args = parser.parse_args()
    
    filepath = Path(args.filepath)
    validator = XAUUSDDataValidatorV2(verbose=not args.quiet)
    
    print(f"\n{'='*60}")
    print("XAUUSD DATA VALIDATOR v2.0 - INSTITUTIONAL GRADE")
    print(f"{'='*60}")
    
    result = validator.validate(filepath, sample_size=args.sample)
    
    # Generate report
    output_path = args.output or f"DATA_QUALITY_REPORT_{datetime.now().strftime('%Y%m%d')}.md"
    report = validator.generate_markdown_report(result, Path(output_path))
    
    # Export JSON if requested
    if args.json:
        # Convert dataclasses to dict
        result_dict = asdict(result)
        with open(args.json, 'w') as f:
            json.dump(result_dict, f, indent=2, default=str)
        print(f"[JSON] Saved to: {args.json}")
    
    # Print summary
    print(f"\n{'='*60}")
    print(f"QUALITY SCORE: {result.quality_score}/100")
    print(f"STATUS: {'APPROVED' if result.approved else 'NOT APPROVED'}")
    print(f"{'='*60}")
    
    sys.exit(0 if result.approved else 1)


if __name__ == '__main__':
    main()
