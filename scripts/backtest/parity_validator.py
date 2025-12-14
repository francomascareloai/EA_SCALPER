"""
Parity Validator: MQL5 vs Python Signal Comparison
===================================================
Validates that Python port produces same signals as MQL5 EA.

Usage:
    python parity_validator.py --mql5-file path/to/mql5_signals.csv --data-file path/to/m15_data.csv
    python parity_validator.py --generate-reference  # Use Python to generate reference

Author: Franco / Singularity Trading
Version: 1.0
"""

import argparse
import sys
from pathlib import Path
from dataclasses import dataclass, field
from typing import Optional, List, Dict, Tuple
from datetime import datetime
import pandas as pd
import numpy as np

# Add project root to path
project_root = Path(__file__).parent.parent.parent
sys.path.insert(0, str(project_root))

from scripts.backtest.strategies.ea_logic_full import (
    RegimeDetector, MarketRegime, RegimeAnalysis,
    SessionFilter, TradingSession, SessionQuality,
    ConfluenceScorer, ConfluenceResult, SignalType,
    MTFManager, LiquiditySweepDetector
)


@dataclass
class ParityResult:
    """Result of comparing a single bar."""
    timestamp: datetime
    bar_index: int
    
    # MQL5 values
    mql5_regime: str = ""
    mql5_hurst: float = 0.0
    mql5_entropy: float = 0.0
    mql5_vr: float = 0.0
    mql5_confidence: float = 0.0
    mql5_size_mult: float = 0.0
    mql5_score_adj: int = 0
    
    # Python values
    py_regime: str = ""
    py_hurst: float = 0.0
    py_entropy: float = 0.0
    py_vr: float = 0.0
    py_confidence: float = 0.0
    py_size_mult: float = 0.0
    py_score_adj: int = 0
    
    # Deltas
    hurst_delta: float = 0.0
    entropy_delta: float = 0.0
    vr_delta: float = 0.0
    confidence_delta: float = 0.0
    
    # Match flags
    regime_match: bool = False
    hurst_match: bool = False  # Within tolerance
    entropy_match: bool = False
    vr_match: bool = False
    
    def __post_init__(self):
        self.hurst_delta = abs(self.mql5_hurst - self.py_hurst)
        self.entropy_delta = abs(self.mql5_entropy - self.py_entropy)
        self.vr_delta = abs(self.mql5_vr - self.py_vr)
        self.confidence_delta = abs(self.mql5_confidence - self.py_confidence)


@dataclass
class ParityReport:
    """Summary of parity validation."""
    total_bars: int = 0
    
    # Match counts
    regime_matches: int = 0
    hurst_matches: int = 0
    entropy_matches: int = 0
    vr_matches: int = 0
    
    # Match percentages
    regime_parity: float = 0.0
    hurst_parity: float = 0.0
    entropy_parity: float = 0.0
    vr_parity: float = 0.0
    
    # Delta stats
    hurst_mean_delta: float = 0.0
    hurst_max_delta: float = 0.0
    entropy_mean_delta: float = 0.0
    entropy_max_delta: float = 0.0
    vr_mean_delta: float = 0.0
    vr_max_delta: float = 0.0
    
    # Divergence details
    divergences: List[ParityResult] = field(default_factory=list)
    
    def calculate(self, results: List[ParityResult], 
                  hurst_tol: float = 0.03, 
                  entropy_tol: float = 0.1, 
                  vr_tol: float = 0.05):
        """Calculate summary statistics."""
        self.total_bars = len(results)
        if self.total_bars == 0:
            return
        
        hurst_deltas = []
        entropy_deltas = []
        vr_deltas = []
        
        for r in results:
            # Check matches
            r.regime_match = r.mql5_regime == r.py_regime
            r.hurst_match = r.hurst_delta <= hurst_tol
            r.entropy_match = r.entropy_delta <= entropy_tol
            r.vr_match = r.vr_delta <= vr_tol
            
            if r.regime_match:
                self.regime_matches += 1
            if r.hurst_match:
                self.hurst_matches += 1
            if r.entropy_match:
                self.entropy_matches += 1
            if r.vr_match:
                self.vr_matches += 1
            
            hurst_deltas.append(r.hurst_delta)
            entropy_deltas.append(r.entropy_delta)
            vr_deltas.append(r.vr_delta)
            
            # Track divergences
            if not r.regime_match:
                self.divergences.append(r)
        
        # Percentages
        self.regime_parity = self.regime_matches / self.total_bars * 100
        self.hurst_parity = self.hurst_matches / self.total_bars * 100
        self.entropy_parity = self.entropy_matches / self.total_bars * 100
        self.vr_parity = self.vr_matches / self.total_bars * 100
        
        # Delta stats
        self.hurst_mean_delta = np.mean(hurst_deltas)
        self.hurst_max_delta = np.max(hurst_deltas)
        self.entropy_mean_delta = np.mean(entropy_deltas)
        self.entropy_max_delta = np.max(entropy_deltas)
        self.vr_mean_delta = np.mean(vr_deltas)
        self.vr_max_delta = np.max(vr_deltas)


class ParityValidator:
    """Validates parity between MQL5 and Python implementations."""
    
    # Tolerances
    HURST_TOLERANCE = 0.03      # Hurst can differ by up to 0.03
    ENTROPY_TOLERANCE = 0.15    # Entropy can differ by up to 0.15
    VR_TOLERANCE = 0.08         # VR can differ by up to 0.08
    CONFIDENCE_TOLERANCE = 5.0  # Confidence can differ by 5 points
    
    def __init__(self):
        self.regime_detector = RegimeDetector()
        self.session_filter = SessionFilter(gmt_offset=0)
        self.mtf_manager = MTFManager(gmt_offset=0)
        self.sweep_detector = LiquiditySweepDetector()
        self.confluence_scorer = ConfluenceScorer()
        
        self.results: List[ParityResult] = []
        self.report = ParityReport()
    
    def load_mql5_signals(self, filepath: Path) -> pd.DataFrame:
        """Load MQL5 exported signals from CSV."""
        if not filepath.exists():
            raise FileNotFoundError(f"MQL5 signals file not found: {filepath}")
        
        df = pd.read_csv(filepath)
        df['timestamp'] = pd.to_datetime(df['timestamp'])
        return df
    
    def load_price_data(self, filepath: Path) -> pd.DataFrame:
        """Load M15 price data for Python analysis."""
        if not filepath.exists():
            raise FileNotFoundError(f"Price data file not found: {filepath}")
        
        df = pd.read_csv(filepath)
        
        # Handle different column formats
        if 'time' in df.columns:
            df['time'] = pd.to_datetime(df['time'])
        elif 'Date' in df.columns and 'Time' in df.columns:
            # Format: Date=YYYYMMDD, Time=HH:MM:SS
            df['time'] = pd.to_datetime(
                df['Date'].astype(str) + ' ' + df['Time'].astype(str),
                format='%Y%m%d %H:%M:%S'
            )
        elif 'datetime' in df.columns:
            df['time'] = pd.to_datetime(df['datetime'])
        else:
            raise ValueError(f"Could not identify time column in {filepath}")
        
        # Ensure we have close column
        if 'Close' in df.columns and 'close' not in df.columns:
            df['close'] = df['Close']
        
        df = df.sort_values('time').reset_index(drop=True)
        return df
    
    def run_python_analysis(self, prices: np.ndarray, idx: int = 0) -> RegimeAnalysis:
        """Run Python regime analysis on price data."""
        return self.regime_detector.analyze_regime(prices)
    
    def compare_bar(self, 
                    timestamp: datetime,
                    bar_idx: int,
                    mql5_row: pd.Series,
                    py_analysis: RegimeAnalysis) -> ParityResult:
        """Compare MQL5 and Python results for a single bar."""
        result = ParityResult(
            timestamp=timestamp,
            bar_index=bar_idx,
            
            # MQL5 values
            mql5_regime=mql5_row['regime'],
            mql5_hurst=float(mql5_row['hurst_exponent']),
            mql5_entropy=float(mql5_row['shannon_entropy']),
            mql5_vr=float(mql5_row['variance_ratio']),
            mql5_confidence=float(mql5_row['confidence']),
            mql5_size_mult=float(mql5_row['size_mult']),
            mql5_score_adj=int(mql5_row['score_adj']),
            
            # Python values
            py_regime=py_analysis.regime.name,
            py_hurst=py_analysis.hurst_exponent,
            py_entropy=py_analysis.shannon_entropy,
            py_vr=py_analysis.variance_ratio,
            py_confidence=py_analysis.confidence,
            py_size_mult=py_analysis.size_multiplier,
            py_score_adj=py_analysis.score_adjustment,
        )
        
        return result
    
    def validate(self, 
                 mql5_signals: pd.DataFrame, 
                 price_data: pd.DataFrame) -> ParityReport:
        """Run full parity validation."""
        print(f"Validating {len(mql5_signals)} bars...")
        
        self.results = []
        
        # Create timestamp index for price data
        price_data['time'] = pd.to_datetime(price_data['time'])
        
        for idx, mql5_row in mql5_signals.iterrows():
            timestamp = mql5_row['timestamp']
            
            # Find corresponding price data (need historical bars)
            mask = price_data['time'] <= timestamp
            historical_prices = price_data[mask]['close'].values
            
            if len(historical_prices) < 250:
                continue  # Not enough data
            
            # Run Python analysis
            py_analysis = self.run_python_analysis(historical_prices)
            
            if not py_analysis.is_valid:
                continue
            
            # Compare
            result = self.compare_bar(timestamp, idx, mql5_row, py_analysis)
            self.results.append(result)
            
            if len(self.results) % 100 == 0:
                print(f"  Processed {len(self.results)} bars...")
        
        # Calculate report
        self.report = ParityReport()
        self.report.calculate(
            self.results,
            hurst_tol=self.HURST_TOLERANCE,
            entropy_tol=self.ENTROPY_TOLERANCE,
            vr_tol=self.VR_TOLERANCE
        )
        
        return self.report
    
    def validate_python_only(self, price_data: pd.DataFrame, 
                             start_date: str, end_date: str) -> pd.DataFrame:
        """
        Run Python analysis and export results (for comparison with MQL5 later).
        This is useful when MQL5 export isn't available yet.
        """
        print(f"Running Python-only analysis from {start_date} to {end_date}...")
        
        price_data['time'] = pd.to_datetime(price_data['time'])
        
        # Pre-extract all closes as numpy array for efficiency
        all_closes = price_data['close'].values.astype(np.float64)
        all_times = price_data['time'].values
        
        # Find index range for analysis period
        start_idx = np.searchsorted(all_times, np.datetime64(start_date))
        end_idx = np.searchsorted(all_times, np.datetime64(end_date), side='right')
        
        print(f"Analysis range: bar {start_idx} to {end_idx} ({end_idx - start_idx} bars)")
        
        results = []
        min_history = 250  # Need at least 250 bars of history
        
        for idx in range(max(start_idx, min_history), min(end_idx, len(all_closes))):
            timestamp = pd.Timestamp(all_times[idx])
            
            # Get historical prices (use numpy slicing, much faster)
            historical_prices = all_closes[:idx+1]
            
            if len(historical_prices) < min_history:
                continue
            
            # Run analysis
            analysis = self.run_python_analysis(historical_prices)
            
            if not analysis.is_valid:
                continue
            
            results.append({
                'timestamp': timestamp,
                'bar_index': idx,
                'close': historical_prices[-1],
                'hurst_short': analysis.hurst_short,
                'hurst_medium': analysis.hurst_medium,
                'hurst_long': analysis.hurst_long,
                'hurst_exponent': analysis.hurst_exponent,
                'shannon_entropy': analysis.shannon_entropy,
                'variance_ratio': analysis.variance_ratio,
                'multiscale_agreement': analysis.multiscale_agreement,
                'transition_prob': analysis.transition_probability,
                'regime_velocity': analysis.regime_velocity,
                'bars_in_regime': analysis.bars_in_regime,
                'regime': analysis.regime.name,
                'confidence': analysis.confidence,
                'size_mult': analysis.size_multiplier,
                'score_adj': analysis.score_adjustment,
                'is_valid': analysis.is_valid,
            })
            
            if len(results) % 100 == 0:
                print(f"  Analyzed {len(results)} bars...")
        
        return pd.DataFrame(results)
    
    def print_report(self):
        """Print human-readable parity report."""
        r = self.report
        
        print("\n" + "=" * 60)
        print("        PARITY VALIDATION REPORT")
        print("=" * 60)
        
        print(f"\nTotal Bars Analyzed: {r.total_bars}")
        
        print("\n--- PARITY SCORES ---")
        print(f"  Regime Match:    {r.regime_parity:6.2f}% ({r.regime_matches}/{r.total_bars})")
        print(f"  Hurst Match:     {r.hurst_parity:6.2f}% ({r.hurst_matches}/{r.total_bars}) [tol: {self.HURST_TOLERANCE}]")
        print(f"  Entropy Match:   {r.entropy_parity:6.2f}% ({r.entropy_matches}/{r.total_bars}) [tol: {self.ENTROPY_TOLERANCE}]")
        print(f"  VR Match:        {r.vr_parity:6.2f}% ({r.vr_matches}/{r.total_bars}) [tol: {self.VR_TOLERANCE}]")
        
        print("\n--- DELTA STATISTICS ---")
        print(f"  Hurst:   mean={r.hurst_mean_delta:.4f}, max={r.hurst_max_delta:.4f}")
        print(f"  Entropy: mean={r.entropy_mean_delta:.4f}, max={r.entropy_max_delta:.4f}")
        print(f"  VR:      mean={r.vr_mean_delta:.4f}, max={r.vr_max_delta:.4f}")
        
        # Overall parity assessment
        overall_parity = (r.regime_parity + r.hurst_parity + r.entropy_parity + r.vr_parity) / 4
        
        print("\n--- OVERALL ASSESSMENT ---")
        print(f"  Combined Parity: {overall_parity:.2f}%")
        
        if overall_parity >= 95:
            print("  Status: EXCELLENT - Python port is highly accurate")
        elif overall_parity >= 90:
            print("  Status: GOOD - Minor discrepancies, acceptable")
        elif overall_parity >= 80:
            print("  Status: FAIR - Some divergences, review needed")
        else:
            print("  Status: POOR - Significant divergences, fixes required")
        
        # Top divergences
        if r.divergences:
            print(f"\n--- TOP {min(10, len(r.divergences))} REGIME DIVERGENCES ---")
            for i, d in enumerate(r.divergences[:10]):
                print(f"  {d.timestamp}: MQL5={d.mql5_regime} vs PY={d.py_regime}")
                print(f"    Hurst: {d.mql5_hurst:.4f} vs {d.py_hurst:.4f} (delta={d.hurst_delta:.4f})")
        
        print("\n" + "=" * 60)
    
    def export_results(self, filepath: Path):
        """Export detailed results to CSV."""
        rows = []
        for r in self.results:
            rows.append({
                'timestamp': r.timestamp,
                'bar_index': r.bar_index,
                'mql5_regime': r.mql5_regime,
                'py_regime': r.py_regime,
                'regime_match': r.regime_match,
                'mql5_hurst': r.mql5_hurst,
                'py_hurst': r.py_hurst,
                'hurst_delta': r.hurst_delta,
                'hurst_match': r.hurst_match,
                'mql5_entropy': r.mql5_entropy,
                'py_entropy': r.py_entropy,
                'entropy_delta': r.entropy_delta,
                'entropy_match': r.entropy_match,
                'mql5_vr': r.mql5_vr,
                'py_vr': r.py_vr,
                'vr_delta': r.vr_delta,
                'vr_match': r.vr_match,
                'mql5_confidence': r.mql5_confidence,
                'py_confidence': r.py_confidence,
                'confidence_delta': r.confidence_delta,
            })
        
        df = pd.DataFrame(rows)
        df.to_csv(filepath, index=False)
        print(f"Results exported to: {filepath}")


def find_data_file(data_dir: Path) -> Optional[Path]:
    """Find M15 data file in data directory."""
    # Check multiple potential locations
    potential_paths = [
        data_dir / "bars-2020-2025XAUUSD_ftmo-M15-No Session.csv",
        data_dir.parent / "Python_Agent_Hub" / "ml_pipeline" / "data" / "bars-2020-2025XAUUSD_ftmo-M15-No Session.csv",
    ]
    
    for path in potential_paths:
        if path.exists():
            return path
    
    # Fallback: search by pattern
    patterns = [
        "*M15*.csv",
        "XAUUSD_M15*.csv",
        "*.csv"
    ]
    
    for pattern in patterns:
        matches = list(data_dir.glob(pattern))
        if matches:
            return matches[0]
    
    return None


def main():
    parser = argparse.ArgumentParser(description='Parity Validator: MQL5 vs Python')
    parser.add_argument('--mql5-file', type=str, help='Path to MQL5 exported signals CSV')
    parser.add_argument('--data-file', type=str, help='Path to M15 price data CSV')
    parser.add_argument('--generate-reference', action='store_true',
                        help='Generate Python reference signals (for later MQL5 comparison)')
    parser.add_argument('--start-date', type=str, default='2025-11-10',
                        help='Start date (YYYY-MM-DD)')
    parser.add_argument('--end-date', type=str, default='2025-11-28',
                        help='End date (YYYY-MM-DD)')
    parser.add_argument('--output', type=str, default='parity_results.csv',
                        help='Output file for results')
    
    args = parser.parse_args()
    
    validator = ParityValidator()
    
    # Default paths
    project_root = Path(__file__).parent.parent.parent
    data_dir = project_root / "data"
    
    if args.generate_reference:
        # Python-only mode: generate reference signals
        print("=== Python Reference Generation Mode ===")
        
        # Find data file
        data_path = Path(args.data_file) if args.data_file else find_data_file(data_dir)
        if not data_path or not data_path.exists():
            print(f"ERROR: Could not find price data file")
            print(f"  Searched in: {data_dir}")
            print(f"  Please provide --data-file argument")
            return 1
        
        print(f"Loading price data from: {data_path}")
        price_data = validator.load_price_data(data_path)
        print(f"Loaded {len(price_data)} bars")
        
        # Run analysis
        results_df = validator.validate_python_only(
            price_data, 
            args.start_date, 
            args.end_date
        )
        
        # Export
        output_path = Path(args.output)
        results_df.to_csv(output_path, index=False)
        print(f"\nPython reference signals exported to: {output_path}")
        print(f"Total signals: {len(results_df)}")
        
        # Print summary
        regime_counts = results_df['regime'].value_counts()
        print("\nRegime Distribution:")
        for regime, count in regime_counts.items():
            pct = count / len(results_df) * 100
            print(f"  {regime}: {count} ({pct:.1f}%)")
        
        return 0
    
    # Full validation mode: compare MQL5 vs Python
    print("=== Full Parity Validation Mode ===")
    
    if not args.mql5_file:
        print("ERROR: --mql5-file is required for validation")
        print("  First run MQL5 ParityExporter script to generate signals")
        print("  Or use --generate-reference to create Python reference only")
        return 1
    
    # Load MQL5 signals
    mql5_path = Path(args.mql5_file)
    print(f"Loading MQL5 signals from: {mql5_path}")
    mql5_signals = validator.load_mql5_signals(mql5_path)
    print(f"Loaded {len(mql5_signals)} MQL5 signals")
    
    # Load price data
    data_path = Path(args.data_file) if args.data_file else find_data_file(data_dir)
    if not data_path or not data_path.exists():
        print(f"ERROR: Could not find price data file")
        return 1
    
    print(f"Loading price data from: {data_path}")
    price_data = validator.load_price_data(data_path)
    print(f"Loaded {len(price_data)} bars")
    
    # Run validation
    report = validator.validate(mql5_signals, price_data)
    
    # Print report
    validator.print_report()
    
    # Export detailed results
    output_path = Path(args.output)
    validator.export_results(output_path)
    
    # Return exit code based on parity
    overall = (report.regime_parity + report.hurst_parity + 
               report.entropy_parity + report.vr_parity) / 4
    
    return 0 if overall >= 90 else 1


if __name__ == "__main__":
    sys.exit(main())
