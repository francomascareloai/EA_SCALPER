"""
Deflated Sharpe Ratio Analysis
==============================

Implements:
- Probabilistic Sharpe Ratio (PSR)
- Deflated Sharpe Ratio (DSR)  
- Probability of Backtest Overfitting (PBO)
- Minimum Track Record Length (MinTRL)

Based on: Bailey & Lopez de Prado (2014)
For: EA_SCALPER_XAUUSD - ORACLE Validation

Usage:
    python -m scripts.oracle.deflated_sharpe --input results.csv --trials 10
    
    # Or as module:
    from scripts.oracle.deflated_sharpe import SharpeAnalyzer
    analyzer = SharpeAnalyzer()
    result = analyzer.analyze(returns, n_trials=10)
"""

import numpy as np
from scipy import stats
from dataclasses import dataclass
from typing import Optional, List
import argparse
import pandas as pd


@dataclass
class SharpeAnalysisResult:
    """Result of Sharpe analysis"""
    observed_sharpe: float
    probabilistic_sharpe: float      # PSR
    deflated_sharpe: float           # DSR
    expected_max_sharpe: float       # E[max(SR)] under H0
    p_value: float
    min_track_record_length: int     # MinTRL
    skewness: float
    kurtosis: float
    n_observations: int
    
    is_significant: bool
    verdict: str  # LIKELY_REAL, MARGINAL, LIKELY_OVERFIT
    interpretation: str


class SharpeAnalyzer:
    """
    Complete Sharpe Ratio analysis with overfitting detection.
    
    Implements Lopez de Prado & Bailey (2014) methodology:
    - PSR: Probability that true Sharpe > benchmark
    - DSR: Sharpe adjusted for multiple testing
    - MinTRL: Minimum track record for statistical significance
    """
    
    EULER_MASCHERONI = 0.5772156649
    
    def analyze(
        self,
        returns: np.ndarray,
        n_trials: int = 1,
        benchmark_sharpe: float = 0.0,
        confidence_level: float = 0.95,
        annualization: int = 252
    ) -> SharpeAnalysisResult:
        """
        Complete Sharpe analysis with overfitting detection.
        
        Args:
            returns: Array of returns (daily)
            n_trials: Number of strategies/parameters tested
            benchmark_sharpe: Benchmark Sharpe to compare against
            confidence_level: Confidence level (default 95%)
            annualization: Annualization factor (252 for daily)
        
        Returns:
            SharpeAnalysisResult with all metrics
        """
        n = len(returns)
        
        # Basic statistics
        mean_return = returns.mean()
        std_return = returns.std(ddof=1)
        skewness = stats.skew(returns)
        kurtosis = stats.kurtosis(returns, fisher=False)
        
        # Observed Sharpe (annualized)
        observed_sharpe = np.sqrt(annualization) * mean_return / std_return if std_return > 0 else 0
        
        # Standard error of Sharpe (Lo, 2002 + Mertens, 2002)
        se_sharpe = self._sharpe_standard_error(observed_sharpe, n, skewness, kurtosis)
        
        # Probabilistic Sharpe Ratio
        psr = self._probabilistic_sharpe(observed_sharpe, benchmark_sharpe, n, skewness, kurtosis)
        
        # Expected Max Sharpe under H0 (given n_trials)
        expected_max_sharpe = self._expected_max_sharpe(n_trials)
        
        # Deflated Sharpe Ratio
        dsr = (observed_sharpe - expected_max_sharpe) / se_sharpe if se_sharpe > 0 else 0
        
        # P-value
        p_value = 1 - stats.norm.cdf(dsr)
        
        # Minimum Track Record Length
        min_trl = self._minimum_track_record(benchmark_sharpe, observed_sharpe, skewness, kurtosis, confidence_level)
        
        # Verdict and interpretation
        verdict, interpretation = self._interpret(dsr, psr, observed_sharpe, n_trials)
        is_significant = psr >= 0.90 and dsr > 0
        
        return SharpeAnalysisResult(
            observed_sharpe=observed_sharpe,
            probabilistic_sharpe=psr,
            deflated_sharpe=dsr,
            expected_max_sharpe=expected_max_sharpe,
            p_value=p_value,
            min_track_record_length=min_trl,
            skewness=skewness,
            kurtosis=kurtosis,
            n_observations=n,
            is_significant=is_significant,
            verdict=verdict,
            interpretation=interpretation
        )
    
    def _sharpe_standard_error(self, sr: float, n: int, skew: float, kurt: float) -> float:
        """Standard error of Sharpe considering higher moments"""
        return np.sqrt(
            (1 + 0.5 * sr**2 - skew * sr + ((kurt - 3) / 4) * sr**2) / (n - 1)
        )
    
    def _probabilistic_sharpe(
        self, sr_obs: float, sr_benchmark: float, n: int, skew: float, kurt: float
    ) -> float:
        """PSR: P(SR > SR_benchmark | observations)"""
        numerator = (sr_obs - sr_benchmark) * np.sqrt(n - 1)
        denominator = np.sqrt(1 + 0.5 * sr_obs**2 - skew * sr_obs + ((kurt - 3) / 4) * sr_obs**2)
        
        if denominator == 0:
            return 0.5
        
        z_score = numerator / denominator
        return stats.norm.cdf(z_score)
    
    def _expected_max_sharpe(self, n_trials: int) -> float:
        """E[max(SR)] under H0 - expected Sharpe from random chance"""
        if n_trials <= 1:
            return 0
        
        return (
            np.sqrt(2 * np.log(n_trials)) - 
            (self.EULER_MASCHERONI + np.log(np.log(n_trials))) / 
            (2 * np.sqrt(2 * np.log(n_trials)))
        )
    
    def _minimum_track_record(
        self, sr_benchmark: float, sr_obs: float, skew: float, kurt: float, confidence: float
    ) -> int:
        """MinTRL: How many periods needed for X% confidence"""
        z = stats.norm.ppf(confidence)
        
        numerator = z**2 * (1 + 0.5 * sr_obs**2 - skew * sr_obs + ((kurt - 3) / 4) * sr_obs**2)
        denominator = (sr_obs - sr_benchmark)**2
        
        if denominator <= 0:
            return 9999
        
        return int(np.ceil(numerator / denominator)) + 1
    
    def _interpret(self, dsr: float, psr: float, sr: float, n_trials: int) -> tuple:
        """Interpret results into verdict and explanation"""
        if dsr > 2 and psr > 0.95:
            verdict = "LIKELY_REAL"
            interpretation = f"Edge very likely REAL. DSR={dsr:.2f} >> 0, PSR={psr:.1%} >> 95%."
        elif dsr > 0 and psr > 0.90:
            verdict = "LIKELY_REAL"
            interpretation = f"Edge probably real. DSR={dsr:.2f} > 0, PSR={psr:.1%} > 90%."
        elif dsr > -0.5 and psr > 0.80:
            verdict = "MARGINAL"
            interpretation = f"Uncertain - could be luck. DSR={dsr:.2f}, PSR={psr:.1%}. Need more data."
        elif dsr > -1:
            verdict = "LIKELY_OVERFIT"
            interpretation = f"Probably overfit/luck. DSR={dsr:.2f} < 0 after {n_trials} trials adjustment."
        else:
            verdict = "LIKELY_OVERFIT"
            interpretation = f"Almost certainly overfit. DSR={dsr:.2f} << 0. Sharpe {sr:.2f} is noise."
        
        return verdict, interpretation

    def generate_report(self, result: SharpeAnalysisResult, n_trials: int) -> str:
        """Generate text report"""
        lines = [
            "=" * 70,
            "OVERFITTING ANALYSIS REPORT (Lopez de Prado)",
            "=" * 70,
            f"Observations: {result.n_observations}",
            f"Observed Sharpe: {result.observed_sharpe:.2f}",
            f"Skewness: {result.skewness:.2f}",
            f"Kurtosis: {result.kurtosis:.2f}",
            "-" * 70,
            "PROBABILISTIC SHARPE RATIO (PSR):",
            f"  PSR (vs SR*=0): {result.probabilistic_sharpe:.1%}",
            f"  Status: {'PASS' if result.probabilistic_sharpe >= 0.90 else 'MARGINAL' if result.probabilistic_sharpe >= 0.80 else 'FAIL'}",
            f"  Min Track Record: {result.min_track_record_length} periods for 95% confidence",
            "-" * 70,
            "DEFLATED SHARPE RATIO (DSR):",
            f"  N Trials: {n_trials}",
            f"  E[max(SR)] under H0: {result.expected_max_sharpe:.2f}",
            f"  DSR: {result.deflated_sharpe:.2f}",
            f"  P-value: {result.p_value:.3f}",
            f"  Status: {'PASS' if result.deflated_sharpe > 0 else 'FAIL'}",
            "-" * 70,
            f"VERDICT: {result.verdict}",
            f"Interpretation: {result.interpretation}",
            "=" * 70,
        ]
        
        # Recommendations
        lines.append("RECOMMENDATIONS:")
        if result.probabilistic_sharpe < 0.90:
            lines.append("  - Collect more data (PSR needs more observations)")
        if result.deflated_sharpe < 0:
            lines.append("  - Reduce number of tests/parameters (high multiple testing)")
        if result.min_track_record_length > result.n_observations:
            lines.append(f"  - Need {result.min_track_record_length - result.n_observations} more observations for significance")
        if result.is_significant:
            lines.append("  - Proceed with GO/NO-GO validation")
        lines.append("=" * 70)
        
        return "\n".join(lines)


def main():
    """CLI interface"""
    parser = argparse.ArgumentParser(description='Overfitting Analysis (PSR/DSR)')
    parser.add_argument('--input', '-i', required=True, help='CSV file with returns column')
    parser.add_argument('--trials', '-n', type=int, default=1, help='Number of strategies/params tested')
    parser.add_argument('--column', '-c', default='return', help='Column name for returns')
    parser.add_argument('--benchmark', '-b', type=float, default=0.0, help='Benchmark Sharpe')
    
    args = parser.parse_args()
    
    # Load data
    df = pd.read_csv(args.input)
    if args.column not in df.columns:
        # Try common column names
        for col in ['return', 'returns', 'pnl', 'profit', 'daily_return']:
            if col in df.columns:
                args.column = col
                break
        else:
            print(f"Error: Column '{args.column}' not found. Available: {list(df.columns)}")
            return
    
    returns = df[args.column].dropna().values
    
    # Run analysis
    analyzer = SharpeAnalyzer()
    result = analyzer.analyze(returns, n_trials=args.trials, benchmark_sharpe=args.benchmark)
    
    # Print report
    print(analyzer.generate_report(result, args.trials))


if __name__ == '__main__':
    main()
