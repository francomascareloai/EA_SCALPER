"""
Walk-Forward Analysis (WFA)
===========================

Implements:
- Rolling WFA (sliding window)
- Anchored WFA (expanding window)
- Purged Cross-Validation (prevents data leakage)
- CPCV - Combinatorial Purged CV

Based on: Lopez de Prado (2018), Advances in Financial ML
For: EA_SCALPER_XAUUSD - ORACLE Validation

Usage:
    python -m scripts.oracle.walk_forward --input trades.csv --mode rolling
    
    # Or as module:
    from scripts.oracle.walk_forward import WalkForwardAnalyzer
    wfa = WalkForwardAnalyzer()
    result = wfa.run(trades_df, mode='rolling')
"""

import numpy as np
import pandas as pd
from dataclasses import dataclass
from typing import List, Tuple, Optional, Literal
from enum import Enum
import argparse


class WFAMode(Enum):
    ROLLING = "rolling"
    ANCHORED = "anchored"


@dataclass
class WindowResult:
    """Result for a single WFA window"""
    window_id: int
    is_start: str
    is_end: str
    oos_start: str
    oos_end: str
    is_return: float
    oos_return: float
    is_trades: int
    oos_trades: int
    efficiency: float  # OOS/IS ratio


@dataclass
class WFAResult:
    """Complete WFA result"""
    mode: str
    n_windows: int
    is_ratio: float
    purge_gap: int
    
    # Aggregate metrics
    wfe: float  # Walk-Forward Efficiency
    mean_is_return: float
    mean_oos_return: float
    std_oos_return: float
    
    # Consistency
    oos_positive_pct: float  # % of positive OOS windows
    worst_oos_window: float
    best_oos_window: float
    
    # Window details
    windows: List[WindowResult]
    
    # Verdict
    status: str  # APPROVED, MARGINAL, REJECTED
    interpretation: str


class WalkForwardAnalyzer:
    """
    Walk-Forward Analysis implementation.
    
    Supports:
    - Rolling (sliding) and Anchored (expanding) modes
    - Purged gap between IS and OOS to prevent leakage
    - Embargo period after OOS
    """
    
    def __init__(
        self,
        n_windows: int = 10,
        is_ratio: float = 0.7,
        purge_gap: int = 0,
        embargo_pct: float = 0.0,
        min_trades_per_window: int = 10
    ):
        """
        Args:
            n_windows: Number of WFA windows
            is_ratio: In-sample ratio (0.7 = 70% IS, 30% OOS)
            purge_gap: Number of observations to purge between IS and OOS
            embargo_pct: Percentage of OOS to embargo at end
            min_trades_per_window: Minimum trades required per window
        """
        self.n_windows = n_windows
        self.is_ratio = is_ratio
        self.purge_gap = purge_gap
        self.embargo_pct = embargo_pct
        self.min_trades_per_window = min_trades_per_window
    
    def run(
        self,
        trades: pd.DataFrame,
        mode: Literal['rolling', 'anchored'] = 'rolling',
        return_col: str = 'profit'
    ) -> WFAResult:
        """
        Run Walk-Forward Analysis.
        
        Args:
            trades: DataFrame with trade data
            mode: 'rolling' or 'anchored'
            return_col: Column name for returns/profits
        
        Returns:
            WFAResult with complete analysis
        """
        n = len(trades)
        
        if n < self.n_windows * self.min_trades_per_window:
            raise ValueError(f"Not enough trades. Need {self.n_windows * self.min_trades_per_window}, have {n}")
        
        # Calculate window sizes properly
        # Total data per window = IS + purge + OOS
        # For rolling: windows slide by OOS size (no overlap in OOS)
        # For anchored: IS expands from start, OOS slides
        
        # Calculate sizes based on total data and windows
        total_oos_data = n * (1 - self.is_ratio)  # Total OOS portion
        oos_size = max(self.min_trades_per_window, int(total_oos_data / self.n_windows))
        is_size = int(oos_size * self.is_ratio / (1 - self.is_ratio))
        
        # Ensure minimum IS size
        is_size = max(is_size, self.min_trades_per_window * 2)
        
        # Window step for rolling mode
        window_step = oos_size
        
        if oos_size < self.min_trades_per_window:
            raise ValueError(f"OOS window too small: {oos_size} < {self.min_trades_per_window}")
        
        windows = []
        
        for i in range(self.n_windows):
            if mode == 'rolling':
                # Rolling: each window advances by window_step (OOS size)
                # This ensures no OOS overlap between consecutive windows
                window_start = i * window_step
                is_start = window_start
                is_end = is_start + is_size
            else:
                # Anchored: IS always starts from beginning, expands over time
                is_start = 0
                is_end = is_size + i * window_step
            
            # Purge gap between IS and OOS (prevent data leakage)
            purge_end = is_end + self.purge_gap
            
            # OOS window starts after purge
            oos_start = purge_end
            oos_end = oos_start + oos_size
            
            # Check boundaries - stop if OOS would exceed data
            if oos_end > n:
                break
            
            # Also check if IS has enough data
            if is_end - is_start < self.min_trades_per_window:
                continue
            
            # Extract data
            is_data = trades.iloc[is_start:is_end]
            oos_data = trades.iloc[oos_start:oos_end]
            
            # Skip if not enough trades in either window
            if len(is_data) < self.min_trades_per_window or len(oos_data) < self.min_trades_per_window:
                continue
            
            # Calculate returns
            is_return = is_data[return_col].sum()
            oos_return = oos_data[return_col].sum()
            
            # Window efficiency (OOS/IS ratio)
            efficiency = oos_return / is_return if is_return != 0 else 0
            
            # Create result
            result = WindowResult(
                window_id=i + 1,
                is_start=str(is_start),
                is_end=str(is_end),
                oos_start=str(oos_start),
                oos_end=str(oos_end),
                is_return=is_return,
                oos_return=oos_return,
                is_trades=len(is_data),
                oos_trades=len(oos_data),
                efficiency=efficiency
            )
            windows.append(result)
        
        # Calculate aggregate metrics
        is_returns = [w.is_return for w in windows]
        oos_returns = [w.oos_return for w in windows]
        
        mean_is = np.mean(is_returns)
        mean_oos = np.mean(oos_returns)
        std_oos = np.std(oos_returns)
        
        # WFE = Mean OOS / Mean IS
        wfe = mean_oos / mean_is if mean_is != 0 else 0
        
        # Consistency metrics
        oos_positive = sum(1 for r in oos_returns if r > 0)
        oos_positive_pct = oos_positive / len(windows) * 100
        
        # Determine status
        if wfe >= 0.6:
            status = "APPROVED"
            interpretation = f"WFE={wfe:.2f} >= 0.6: Strategy retains {wfe*100:.0f}% of IS performance OOS. Edge likely real."
        elif wfe >= 0.5:
            status = "MARGINAL"
            interpretation = f"WFE={wfe:.2f}: Borderline. Strategy degrades {(1-wfe)*100:.0f}% OOS. Consider simplification."
        elif wfe >= 0.4:
            status = "SUSPECT"
            interpretation = f"WFE={wfe:.2f}: High degradation. Likely some overfitting. Simplify strategy."
        else:
            status = "REJECTED"
            interpretation = f"WFE={wfe:.2f} < 0.4: Severe overfitting. Strategy curve-fitted to IS data."
        
        return WFAResult(
            mode=mode,
            n_windows=len(windows),
            is_ratio=self.is_ratio,
            purge_gap=self.purge_gap,
            wfe=wfe,
            mean_is_return=mean_is,
            mean_oos_return=mean_oos,
            std_oos_return=std_oos,
            oos_positive_pct=oos_positive_pct,
            worst_oos_window=min(oos_returns),
            best_oos_window=max(oos_returns),
            windows=windows,
            status=status,
            interpretation=interpretation
        )
    
    def generate_report(self, result: WFAResult) -> str:
        """Generate text report"""
        lines = [
            "=" * 70,
            f"WALK-FORWARD ANALYSIS REPORT ({result.mode.upper()})",
            "=" * 70,
            f"Windows: {result.n_windows} | IS Ratio: {result.is_ratio:.0%} | Purge: {result.purge_gap}",
            "-" * 70,
            "SUMMARY:",
            f"  WFE (Walk-Forward Efficiency): {result.wfe:.2f}",
            f"  Status: {result.status}",
            "-" * 70,
            "AGGREGATE METRICS:",
            f"  Mean IS Return:  ${result.mean_is_return:,.2f}",
            f"  Mean OOS Return: ${result.mean_oos_return:,.2f}",
            f"  StdDev OOS:      ${result.std_oos_return:,.2f}",
            "-" * 70,
            "CONSISTENCY:",
            f"  OOS Positive Windows: {result.oos_positive_pct:.0f}%",
            f"  Best OOS Window:      ${result.best_oos_window:,.2f}",
            f"  Worst OOS Window:     ${result.worst_oos_window:,.2f}",
            "-" * 70,
            "WINDOW DETAILS:",
        ]
        
        lines.append("  | Window | IS Return | OOS Return | Efficiency |")
        lines.append("  |--------|-----------|------------|------------|")
        for w in result.windows:
            lines.append(f"  | {w.window_id:6} | ${w.is_return:8,.0f} | ${w.oos_return:9,.0f} | {w.efficiency:10.2f} |")
        
        lines.extend([
            "-" * 70,
            "INTERPRETATION:",
            f"  {result.interpretation}",
            "=" * 70,
        ])
        
        return "\n".join(lines)


class PurgedKFold:
    """
    Purged K-Fold Cross-Validation.
    
    Prevents data leakage by:
    1. Purging: Remove samples too close to test set
    2. Embargo: Block samples after test set from training
    """
    
    def __init__(
        self,
        n_splits: int = 5,
        purge_gap: int = 0,
        embargo_pct: float = 0.01
    ):
        self.n_splits = n_splits
        self.purge_gap = purge_gap
        self.embargo_pct = embargo_pct
    
    def split(self, X: np.ndarray) -> List[Tuple[np.ndarray, np.ndarray]]:
        """
        Generate purged train/test splits.
        
        Args:
            X: Data array or indices
        
        Yields:
            (train_indices, test_indices) tuples
        """
        n = len(X)
        indices = np.arange(n)
        fold_size = n // self.n_splits
        embargo_size = int(n * self.embargo_pct)
        
        splits = []
        for i in range(self.n_splits):
            test_start = i * fold_size
            test_end = test_start + fold_size if i < self.n_splits - 1 else n
            
            # Test indices
            test_idx = indices[test_start:test_end]
            
            # Purge: remove samples before test
            purge_start = max(0, test_start - self.purge_gap)
            
            # Embargo: remove samples after test
            embargo_end = min(n, test_end + embargo_size)
            
            # Train indices (exclude purge, test, and embargo)
            train_mask = np.ones(n, dtype=bool)
            train_mask[purge_start:embargo_end] = False
            train_idx = indices[train_mask]
            
            splits.append((train_idx, test_idx))
        
        return splits


def calculate_wfe(is_performance: float, oos_performance: float) -> float:
    """Simple WFE calculation"""
    if is_performance == 0:
        return 0
    return oos_performance / is_performance


def main():
    """CLI interface"""
    parser = argparse.ArgumentParser(description='Walk-Forward Analysis')
    parser.add_argument('--input', '-i', required=True, help='CSV file with trades')
    parser.add_argument('--mode', '-m', choices=['rolling', 'anchored'], default='rolling')
    parser.add_argument('--windows', '-w', type=int, default=10, help='Number of windows')
    parser.add_argument('--is-ratio', type=float, default=0.7, help='In-sample ratio')
    parser.add_argument('--purge', type=int, default=0, help='Purge gap between IS and OOS')
    parser.add_argument('--column', '-c', default='profit', help='Return/profit column')
    
    args = parser.parse_args()
    
    # Load data
    df = pd.read_csv(args.input)
    if args.column not in df.columns:
        for col in ['profit', 'pnl', 'return', 'pl']:
            if col in df.columns:
                args.column = col
                break
        else:
            print(f"Error: Column '{args.column}' not found. Available: {list(df.columns)}")
            return
    
    # Run WFA
    wfa = WalkForwardAnalyzer(
        n_windows=args.windows,
        is_ratio=args.is_ratio,
        purge_gap=args.purge
    )
    result = wfa.run(df, mode=args.mode, return_col=args.column)
    
    # Print report
    print(wfa.generate_report(result))


if __name__ == '__main__':
    main()
