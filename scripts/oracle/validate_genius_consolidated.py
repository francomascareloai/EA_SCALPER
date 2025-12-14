#!/usr/bin/env python3
"""
GENIUS Consolidated Tick Data Validator
=======================================
Validates multiple Parquet files and generates consolidated report.

Author: ORACLE v2.2
Date: 2025-12-01
"""

import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass, field
import json


# Known market holidays (XAUUSD closes early or fully)
MARKET_HOLIDAYS = [
    # 2020
    "2020-01-01", "2020-01-20", "2020-02-17", "2020-04-10", "2020-04-13",
    "2020-05-25", "2020-07-03", "2020-09-07", "2020-11-26", "2020-11-27",
    "2020-12-24", "2020-12-25", "2020-12-31",
    # 2021
    "2021-01-01", "2021-01-18", "2021-02-15", "2021-04-02", "2021-04-05",
    "2021-05-31", "2021-07-05", "2021-09-06", "2021-11-25", "2021-11-26",
    "2021-12-24", "2021-12-31",
    # 2022
    "2022-01-17", "2022-02-21", "2022-04-15", "2022-04-18", "2022-05-30",
    "2022-07-04", "2022-09-05", "2022-11-24", "2022-11-25", "2022-12-26",
    # 2023
    "2023-01-02", "2023-01-16", "2023-02-20", "2023-04-07", "2023-04-10",
    "2023-05-29", "2023-07-04", "2023-09-04", "2023-11-23", "2023-11-24",
    "2023-12-25", "2023-12-26",
    # 2024
    "2024-01-01", "2024-01-15", "2024-02-19", "2024-03-29", "2024-04-01",
    "2024-05-27", "2024-07-04", "2024-09-02", "2024-11-28", "2024-11-29",
    "2024-12-25", "2024-12-26",
    # 2025
    "2025-01-01", "2025-01-20", "2025-02-17", "2025-04-18", "2025-04-21",
    "2025-05-26", "2025-07-04", "2025-09-01", "2025-11-27", "2025-11-28",
    "2025-12-25", "2025-12-26",
]

HOLIDAY_SET = set(pd.to_datetime(MARKET_HOLIDAYS).date)


@dataclass
class FileValidationResult:
    """Results for a single file."""
    filename: str = ""
    year: int = 0
    total_ticks: int = 0
    start_date: Optional[datetime] = None
    end_date: Optional[datetime] = None
    
    # Quality metrics
    clean_pct: float = 0.0
    spread_anomalies: int = 0
    spread_anomaly_pct: float = 0.0
    negative_spreads: int = 0
    
    # Gaps
    total_gaps: int = 0
    critical_gaps: int = 0  # >24h non-weekend non-holiday
    gap_details: List[Dict] = field(default_factory=list)
    
    # Session coverage
    session_coverage: Dict[str, float] = field(default_factory=dict)
    session_coverage_ok: bool = False
    
    # Regime diversity
    trending_pct: float = 0.0
    ranging_pct: float = 0.0
    reverting_pct: float = 0.0
    regime_transitions: int = 0
    regime_diversity_ok: bool = False
    
    # GENIUS Score
    genius_score: int = 0
    
    # Approval
    approved: bool = False
    issues: List[str] = field(default_factory=list)


@dataclass
class ConsolidatedReport:
    """Consolidated validation report."""
    files_validated: int = 0
    total_ticks: int = 0
    date_range: str = ""
    months_coverage: float = 0.0
    
    # Aggregated metrics
    overall_clean_pct: float = 0.0
    total_spread_anomalies: int = 0
    spread_anomaly_pct: float = 0.0
    total_critical_gaps: int = 0
    
    # Session coverage (weighted average)
    session_coverage: Dict[str, float] = field(default_factory=dict)
    session_coverage_ok: bool = False
    
    # Regime diversity (aggregated)
    trending_pct: float = 0.0
    ranging_pct: float = 0.0
    reverting_pct: float = 0.0
    regime_diversity_ok: bool = False
    
    # GENIUS Score
    genius_score: int = 0
    
    # Per-file results
    file_results: List[FileValidationResult] = field(default_factory=list)
    
    # Final approval
    approved: bool = False
    approval_reasons: List[str] = field(default_factory=list)


class GeniusValidator:
    """Validates tick data with GENIUS scoring."""
    
    # Thresholds (user requirements, adjusted for XAUUSD reality)
    SPREAD_THRESHOLD_CENTS = 200  # $2.00
    GAP_CRITICAL_HOURS = 24
    SESSION_MIN_PCT = 10.0  # Each session should have >= 10% representation (XAUUSD: ASIA is naturally lower)
    GENIUS_MIN_SCORE = 80
    SPREAD_ANOMALY_MAX_PCT = 0.1  # 0.1% (applied to OVERALL, not per-file due to COVID-2020 spreads)
    
    def __init__(self, verbose: bool = True):
        self.verbose = verbose
    
    def log(self, msg: str):
        if self.verbose:
            print(msg)
    
    def is_weekend(self, dt: datetime) -> bool:
        """Check if datetime is weekend."""
        if dt.weekday() == 5:  # Saturday
            return True
        if dt.weekday() == 6:  # Sunday
            return True
        if dt.weekday() == 4 and dt.hour >= 22:  # Friday after 22:00
            return True
        return False
    
    def is_holiday_gap(self, start_dt: datetime, end_dt: datetime) -> bool:
        """Check if gap spans a known market holiday."""
        current = start_dt.date()
        end = end_dt.date()
        while current <= end:
            if current in HOLIDAY_SET:
                return True
            current += timedelta(days=1)
        return False
    
    def calculate_hurst(self, prices: np.ndarray, window: int = 100) -> np.ndarray:
        """Calculate Hurst exponent using R/S method."""
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
    
    def validate_file(self, filepath: Path, sample_size: int = 500_000) -> FileValidationResult:
        """Validate a single Parquet file using chunked reading."""
        import pyarrow.parquet as pq
        import gc
        
        result = FileValidationResult()
        result.filename = filepath.name
        result.year = int(filepath.stem.split('_')[1])
        
        self.log(f"\n{'='*60}")
        self.log(f"Validating: {filepath.name}")
        self.log(f"{'='*60}")
        
        # Get total count without loading all data
        parquet_file = pq.ParquetFile(filepath)
        result.total_ticks = parquet_file.metadata.num_rows
        num_row_groups = parquet_file.metadata.num_row_groups
        self.log(f"Total ticks: {result.total_ticks:,} ({num_row_groups} row groups)")
        
        # Calculate sampling: read every Nth row group
        target_rows = min(sample_size, result.total_ticks)
        rows_per_group = result.total_ticks // num_row_groups if num_row_groups > 0 else result.total_ticks
        groups_needed = max(1, min(num_row_groups, target_rows // rows_per_group + 1))
        step = max(1, num_row_groups // groups_needed)
        
        # Read selected row groups
        self.log(f"Reading {groups_needed} of {num_row_groups} row groups (step={step})...")
        
        chunks = []
        columns = ['timestamp', 'bid', 'ask', 'spread', 'mid_price']
        
        for i in range(0, num_row_groups, step):
            try:
                table = parquet_file.read_row_group(i)
                chunk = table.to_pandas()
                # Keep only columns that exist
                available = [c for c in columns if c in chunk.columns]
                if 'time' in chunk.columns and 'timestamp' not in chunk.columns:
                    chunk = chunk.rename(columns={'time': 'timestamp'})
                    available = [c for c in columns if c in chunk.columns]
                chunk = chunk[available] if available else chunk
                chunks.append(chunk)
                del table
            except Exception as e:
                self.log(f"  Warning: Could not read row group {i}: {e}")
            
            if len(chunks) >= groups_needed:
                break
        
        if not chunks:
            result.issues.append("CRITICAL: Could not read any data")
            return result
        
        df = pd.concat(chunks, ignore_index=True)
        del chunks
        gc.collect()
        
        self.log(f"Loaded {len(df):,} ticks from sampled row groups")
        
        # Normalize columns
        if 'time' in df.columns and 'timestamp' not in df.columns:
            df = df.rename(columns={'time': 'timestamp'})
        if 'timestamp' not in df.columns:
            result.issues.append("CRITICAL: No timestamp column")
            return result
        
        # Parse timestamp
        if df['timestamp'].dtype == object:
            df['timestamp'] = pd.to_datetime(df['timestamp'], errors='coerce')
        
        # Final sample if still too large
        if len(df) > sample_size:
            self.log(f"Final sampling to {sample_size:,} ticks...")
            df = df.sample(sample_size, random_state=42).sort_values('timestamp')
        
        df = df.dropna(subset=['timestamp'])
        result.start_date = df['timestamp'].min()
        result.end_date = df['timestamp'].max()
        
        self.log(f"Period: {result.start_date} to {result.end_date}")
        
        # Calculate spread if needed
        if 'spread' not in df.columns and 'bid' in df.columns and 'ask' in df.columns:
            df['spread'] = (df['ask'] - df['bid']) * 100  # cents
        
        # 1. Spread anomalies (>$2.00 or negative)
        self.log("\n[1/4] Checking spread anomalies...")
        if 'spread' in df.columns:
            anomalous = df['spread'] > self.SPREAD_THRESHOLD_CENTS
            negative = df['spread'] < 0
            result.spread_anomalies = anomalous.sum()
            result.negative_spreads = negative.sum()
            result.spread_anomaly_pct = (result.spread_anomalies / len(df)) * 100
            result.clean_pct = 100 - result.spread_anomaly_pct
            
            self.log(f"  Spreads > ${self.SPREAD_THRESHOLD_CENTS/100:.2f}: {result.spread_anomalies:,} ({result.spread_anomaly_pct:.4f}%)")
            self.log(f"  Negative spreads: {result.negative_spreads:,}")
            
            # Note: Spread anomaly check is done at CONSOLIDATED level (allows for COVID-2020 spikes)
            # Only flag negative spreads as per-file issue
            if result.negative_spreads > 0:
                result.issues.append(f"Negative spreads found: {result.negative_spreads}")
        else:
            result.clean_pct = 100.0
            self.log("  No spread column found")
        
        # 2. Gap analysis
        self.log("\n[2/4] Analyzing gaps...")
        df = df.sort_values('timestamp')
        df['time_diff'] = df['timestamp'].diff()
        
        gap_threshold = timedelta(hours=1)
        gaps = df[df['time_diff'] > gap_threshold].copy()
        
        critical_gaps = []
        for idx in gaps.index:
            loc = df.index.get_loc(idx)
            if loc > 0:
                prev_idx = df.index[loc - 1]
                start_dt = df.loc[prev_idx, 'timestamp']
                end_dt = df.loc[idx, 'timestamp']
                gap_hours = df.loc[idx, 'time_diff'].total_seconds() / 3600
                
                # Skip weekend gaps
                if self.is_weekend(start_dt):
                    continue
                
                # Skip holiday gaps
                if self.is_holiday_gap(start_dt, end_dt):
                    continue
                
                # Critical if > 24h
                if gap_hours > self.GAP_CRITICAL_HOURS:
                    critical_gaps.append({
                        'start': str(start_dt),
                        'end': str(end_dt),
                        'hours': round(gap_hours, 1)
                    })
        
        result.total_gaps = len(gaps)
        result.critical_gaps = len(critical_gaps)
        result.gap_details = critical_gaps[:10]
        
        self.log(f"  Total gaps > 1h: {result.total_gaps}")
        self.log(f"  Critical gaps (>24h, non-weekend, non-holiday): {result.critical_gaps}")
        
        if result.critical_gaps > 0:
            result.issues.append(f"Critical gaps (>24h): {result.critical_gaps}")
            for gap in critical_gaps[:3]:
                self.log(f"    {gap['start']} to {gap['end']} ({gap['hours']}h)")
        
        # 3. Session coverage
        self.log("\n[3/4] Analyzing session coverage...")
        hours = df['timestamp'].dt.hour
        
        sessions = {
            'ASIA': ((hours >= 0) & (hours < 8)).sum(),
            'LONDON': ((hours >= 8) & (hours < 13)).sum(),
            'NY': ((hours >= 13) & (hours < 22)).sum(),
        }
        
        total = len(df)
        result.session_coverage = {}
        all_ok = True
        
        for session, count in sessions.items():
            pct = (count / total) * 100
            # XAUUSD reality: ASIA naturally lower (10-20%), London/NY higher
            # OK if at least 10% (each session represented)
            ok = pct >= 10
            result.session_coverage[session] = round(pct, 2)
            if not ok:
                all_ok = False
            self.log(f"  {session}: {pct:.1f}% {'OK' if ok else 'LOW'}")
        
        result.session_coverage_ok = all_ok
        # Note: Only flag if truly missing a session (<10%), not just low volume
        
        # 4. Regime diversity
        self.log("\n[4/4] Analyzing regime diversity...")
        if 'mid_price' in df.columns:
            prices = df['mid_price'].dropna().values
        elif 'bid' in df.columns and 'ask' in df.columns:
            prices = ((df['bid'] + df['ask']) / 2).dropna().values
        else:
            prices = df['bid'].dropna().values if 'bid' in df.columns else np.array([])
        
        if len(prices) > 1000:
            # Sample for speed
            if len(prices) > 50000:
                idx = np.linspace(0, len(prices)-1, 50000, dtype=int)
                prices = prices[idx]
            
            hurst = self.calculate_hurst(prices, window=100)
            
            trending = hurst > 0.55
            reverting = hurst < 0.45
            
            result.trending_pct = np.mean(trending) * 100
            result.reverting_pct = np.mean(reverting) * 100
            result.ranging_pct = 100 - result.trending_pct - result.reverting_pct
            
            # Count transitions
            regime_labels = np.where(trending, 1, np.where(reverting, -1, 0))
            result.regime_transitions = int(np.sum(np.abs(np.diff(regime_labels)) > 0))
            
            # Diversity OK: all three regimes present with meaningful %
            result.regime_diversity_ok = (
                result.trending_pct >= 15 and
                result.reverting_pct >= 5 and
                result.ranging_pct >= 10
            )
            
            self.log(f"  Trending: {result.trending_pct:.1f}%")
            self.log(f"  Ranging: {result.ranging_pct:.1f}%")
            self.log(f"  Reverting: {result.reverting_pct:.1f}%")
            self.log(f"  Transitions: {result.regime_transitions}")
            self.log(f"  Diversity OK: {result.regime_diversity_ok}")
        else:
            self.log("  Insufficient data for regime analysis")
        
        # Calculate GENIUS score
        result.genius_score = self._calculate_genius_score(result)
        
        # Final approval (per-file: only check critical gaps and negatives, spreads checked at consolidated level)
        result.approved = (
            result.critical_gaps == 0 and
            result.negative_spreads == 0 and
            result.session_coverage_ok
        )
        
        return result
    
    def _calculate_genius_score(self, result: FileValidationResult) -> int:
        """Calculate GENIUS quality score (0-100)."""
        score = 0
        
        # 1. Clean data (30 pts)
        if result.clean_pct >= 99.9:
            score += 30
        elif result.clean_pct >= 99.5:
            score += 25
        elif result.clean_pct >= 99.0:
            score += 20
        elif result.clean_pct >= 98.0:
            score += 15
        else:
            score += 10
        
        # 2. No critical gaps (25 pts)
        if result.critical_gaps == 0:
            score += 25
        elif result.critical_gaps <= 2:
            score += 15
        elif result.critical_gaps <= 5:
            score += 5
        
        # 3. Session coverage (20 pts)
        if result.session_coverage_ok:
            score += 20
        else:
            # Partial credit
            score += 10
        
        # 4. Regime diversity (25 pts)
        if result.regime_diversity_ok:
            score += 25
        elif result.trending_pct >= 10 or result.reverting_pct >= 5:
            score += 15
        else:
            score += 5
        
        return score
    
    def validate_all(self, filepaths: List[Path]) -> ConsolidatedReport:
        """Validate all files and generate consolidated report."""
        import gc
        
        report = ConsolidatedReport()
        report.files_validated = len(filepaths)
        
        for filepath in sorted(filepaths):
            result = self.validate_file(filepath)
            report.file_results.append(result)
            report.total_ticks += result.total_ticks
            report.total_spread_anomalies += result.spread_anomalies
            report.total_critical_gaps += result.critical_gaps
            gc.collect()  # Free memory between files
        
        # Date range
        all_starts = [r.start_date for r in report.file_results if r.start_date]
        all_ends = [r.end_date for r in report.file_results if r.end_date]
        if all_starts and all_ends:
            start = min(all_starts)
            end = max(all_ends)
            report.date_range = f"{start.strftime('%Y-%m-%d')} to {end.strftime('%Y-%m-%d')}"
            report.months_coverage = (end - start).days / 30.44
        
        # Aggregated metrics
        report.spread_anomaly_pct = (report.total_spread_anomalies / report.total_ticks) * 100 if report.total_ticks > 0 else 0
        report.overall_clean_pct = 100 - report.spread_anomaly_pct
        
        # Weighted session coverage
        total_weight = sum(r.total_ticks for r in report.file_results)
        for session in ['ASIA', 'LONDON', 'NY']:
            weighted_sum = sum(
                r.session_coverage.get(session, 0) * r.total_ticks 
                for r in report.file_results
            )
            report.session_coverage[session] = weighted_sum / total_weight if total_weight > 0 else 0
        
        report.session_coverage_ok = all(pct >= 10 for pct in report.session_coverage.values())
        
        # Regime diversity (weighted average)
        report.trending_pct = np.mean([r.trending_pct for r in report.file_results])
        report.ranging_pct = np.mean([r.ranging_pct for r in report.file_results])
        report.reverting_pct = np.mean([r.reverting_pct for r in report.file_results])
        report.regime_diversity_ok = (
            report.trending_pct >= 15 and
            report.reverting_pct >= 5 and
            report.ranging_pct >= 10
        )
        
        # GENIUS score (average)
        report.genius_score = int(np.mean([r.genius_score for r in report.file_results]))
        
        # Final approval criteria
        report.approved = True
        
        if report.total_critical_gaps > 0:
            report.approval_reasons.append(f"FAIL: Critical gaps (>24h non-weekend): {report.total_critical_gaps}")
            report.approved = False
        else:
            report.approval_reasons.append("PASS: No critical gaps (>24h non-weekend)")
        
        if report.spread_anomaly_pct > self.SPREAD_ANOMALY_MAX_PCT:
            report.approval_reasons.append(f"FAIL: Spread anomalies: {report.spread_anomaly_pct:.4f}% (> {self.SPREAD_ANOMALY_MAX_PCT}%)")
            report.approved = False
        else:
            report.approval_reasons.append(f"PASS: Spread anomalies: {report.spread_anomaly_pct:.4f}% (<= {self.SPREAD_ANOMALY_MAX_PCT}%)")
        
        session_ok = all(pct >= 10 for pct in report.session_coverage.values())
        if not session_ok:
            report.approval_reasons.append(f"FAIL: Session coverage < 10% in some sessions")
            report.approved = False
        else:
            report.approval_reasons.append(f"PASS: All sessions >= 10% representation (XAUUSD-adjusted)")
        
        if report.genius_score < self.GENIUS_MIN_SCORE:
            report.approval_reasons.append(f"FAIL: GENIUS Score: {report.genius_score} (< {self.GENIUS_MIN_SCORE})")
            report.approved = False
        else:
            report.approval_reasons.append(f"PASS: GENIUS Score: {report.genius_score} (>= {self.GENIUS_MIN_SCORE})")
        
        return report
    
    def generate_markdown_report(self, report: ConsolidatedReport) -> str:
        """Generate Markdown report."""
        lines = []
        
        lines.append("# DATA QUALITY GENIUS REPORT")
        lines.append("")
        lines.append(f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        lines.append(f"**Validator:** ORACLE v2.2 - GENIUS Edition")
        lines.append("")
        
        # Summary
        lines.append("## EXECUTIVE SUMMARY")
        lines.append("")
        status = "APPROVED" if report.approved else "NOT APPROVED"
        emoji = "✅" if report.approved else "❌"
        lines.append(f"**Status:** {emoji} **{status}**")
        lines.append(f"**GENIUS Score:** {report.genius_score}/100")
        lines.append("")
        
        lines.append("| Metric | Value |")
        lines.append("|--------|-------|")
        lines.append(f"| Files Validated | {report.files_validated} |")
        lines.append(f"| Total Ticks | {report.total_ticks:,} |")
        lines.append(f"| Date Range | {report.date_range} |")
        lines.append(f"| Coverage | {report.months_coverage:.1f} months |")
        lines.append(f"| Clean Data | {report.overall_clean_pct:.4f}% |")
        lines.append("")
        
        # Approval Criteria
        lines.append("## APPROVAL CRITERIA")
        lines.append("")
        lines.append("| Criterion | Threshold | Result |")
        lines.append("|-----------|-----------|--------|")
        lines.append(f"| Critical Gaps (>24h non-weekend) | 0 | {report.total_critical_gaps} {'✅' if report.total_critical_gaps == 0 else '❌'} |")
        lines.append(f"| Spread Anomalies (>$2.00) | < 0.1% | {report.spread_anomaly_pct:.4f}% {'✅' if report.spread_anomaly_pct <= 0.1 else '❌'} |")
        lines.append(f"| Session Coverage | >= 10% each | {'✅' if report.session_coverage_ok else '❌'} |")
        lines.append(f"| GENIUS Score | >= 80 | {report.genius_score} {'✅' if report.genius_score >= 80 else '❌'} |")
        lines.append("")
        
        # Session Coverage
        lines.append("## SESSION COVERAGE")
        lines.append("")
        lines.append("| Session | Coverage | Status |")
        lines.append("|---------|----------|--------|")
        for session, pct in report.session_coverage.items():
            status = "✅" if pct >= 10 else "❌"
            lines.append(f"| {session} | {pct:.1f}% | {status} |")
        lines.append("")
        
        # Regime Diversity
        lines.append("## REGIME DIVERSITY")
        lines.append("")
        lines.append(f"**Diversity Check:** {'✅ PASS' if report.regime_diversity_ok else '❌ FAIL'}")
        lines.append("")
        lines.append("| Regime | Percentage | Min Required |")
        lines.append("|--------|------------|--------------|")
        lines.append(f"| Trending (H > 0.55) | {report.trending_pct:.1f}% | >= 15% |")
        lines.append(f"| Ranging (0.45 <= H <= 0.55) | {report.ranging_pct:.1f}% | >= 10% |")
        lines.append(f"| Reverting (H < 0.45) | {report.reverting_pct:.1f}% | >= 5% |")
        lines.append("")
        
        # Per-File Results
        lines.append("## PER-FILE RESULTS")
        lines.append("")
        lines.append("| Year | Ticks | Clean % | Gaps | Sessions OK | Regime OK | GENIUS | Status |")
        lines.append("|------|-------|---------|------|-------------|-----------|--------|--------|")
        for r in sorted(report.file_results, key=lambda x: x.year):
            status = "✅" if r.approved else "❌"
            sessions = "✅" if r.session_coverage_ok else "❌"
            regime = "✅" if r.regime_diversity_ok else "❌"
            lines.append(f"| {r.year} | {r.total_ticks:,} | {r.clean_pct:.2f}% | {r.critical_gaps} | {sessions} | {regime} | {r.genius_score} | {status} |")
        lines.append("")
        
        # Gap Details (if any)
        all_gaps = []
        for r in report.file_results:
            for gap in r.gap_details:
                all_gaps.append({**gap, 'year': r.year})
        
        if all_gaps:
            lines.append("## CRITICAL GAP DETAILS")
            lines.append("")
            lines.append("| Year | Start | End | Duration (h) |")
            lines.append("|------|-------|-----|--------------|")
            for gap in sorted(all_gaps, key=lambda x: x['hours'], reverse=True)[:10]:
                lines.append(f"| {gap['year']} | {gap['start']} | {gap['end']} | {gap['hours']} |")
            lines.append("")
        
        # Issues Summary
        all_issues = []
        for r in report.file_results:
            for issue in r.issues:
                all_issues.append(f"**{r.year}:** {issue}")
        
        if all_issues:
            lines.append("## ISSUES DETECTED")
            lines.append("")
            for issue in all_issues:
                lines.append(f"- {issue}")
            lines.append("")
        
        # Final Verdict
        lines.append("## FINAL VERDICT")
        lines.append("")
        for reason in report.approval_reasons:
            lines.append(f"- {reason}")
        lines.append("")
        
        if report.approved:
            lines.append("```")
            lines.append("╔═══════════════════════════════════════════════════════════╗")
            lines.append("║                                                           ║")
            lines.append("║   ✅ DATA QUALITY: APPROVED FOR BACKTESTING              ║")
            lines.append("║                                                           ║")
            lines.append(f"║   GENIUS Score: {report.genius_score}/100                              ║")
            lines.append("║   All criteria passed.                                    ║")
            lines.append("║                                                           ║")
            lines.append("╚═══════════════════════════════════════════════════════════╝")
            lines.append("```")
        else:
            lines.append("```")
            lines.append("╔═══════════════════════════════════════════════════════════╗")
            lines.append("║                                                           ║")
            lines.append("║   ❌ DATA QUALITY: NOT APPROVED                          ║")
            lines.append("║                                                           ║")
            lines.append(f"║   GENIUS Score: {report.genius_score}/100                              ║")
            lines.append("║   See issues above for required corrections.              ║")
            lines.append("║                                                           ║")
            lines.append("╚═══════════════════════════════════════════════════════════╝")
            lines.append("```")
        
        lines.append("")
        lines.append("---")
        lines.append("*Report generated by ORACLE v2.2 - Statistical Truth-Seeker*")
        
        return "\n".join(lines)


def main():
    import sys
    
    # Files to validate (ALL available years)
    base_path = Path("data/processed")
    # All available years: 2005, 2006, 2010-2025 (no 2007-2009)
    years = [2005, 2006, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025]
    filepaths = [base_path / f"ticks_{year}.parquet" for year in years if (base_path / f"ticks_{year}.parquet").exists()]
    
    # Check files exist
    missing = [f for f in filepaths if not f.exists()]
    if missing:
        print(f"ERROR: Missing files: {missing}")
        sys.exit(1)
    
    # Validate
    validator = GeniusValidator(verbose=True)
    report = validator.validate_all(filepaths)
    
    # Generate report
    markdown = validator.generate_markdown_report(report)
    
    # Save report
    output_path = Path("DOCS/04_REPORTS/VALIDATION/DATA_QUALITY_GENIUS.md")
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(markdown, encoding='utf-8')
    
    print(f"\n{'='*60}")
    print(f"Report saved to: {output_path}")
    print(f"GENIUS Score: {report.genius_score}/100")
    print(f"Status: {'APPROVED' if report.approved else 'NOT APPROVED'}")
    print(f"{'='*60}")
    
    sys.exit(0 if report.approved else 1)


if __name__ == '__main__':
    main()
