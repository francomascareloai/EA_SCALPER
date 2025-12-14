"""
Purged K-Fold Cross-Validation for Time Series
Based on: López de Prado - Advances in Financial Machine Learning

This module implements cross-validation methods that prevent information leakage
in time series data by purging overlapping samples and adding embargo periods.
"""

import numpy as np
import pandas as pd
from typing import Generator, Tuple, Optional, List
from sklearn.model_selection import BaseCrossValidator
from dataclasses import dataclass


@dataclass
class CVConfig:
    """Configuration for cross-validation."""
    n_splits: int = 5
    purge_gap: int = 10    # Bars to purge after test end
    embargo_pct: float = 0.01  # Percentage of test size as embargo


class PurgedKFold(BaseCrossValidator):
    """
    Purged K-Fold cross-validation for time series.
    
    Key features:
    - Test set always comes AFTER training set (no look-ahead)
    - Purge gap between train and test to prevent leakage
    - Optional embargo after test set
    
    Args:
        n_splits: Number of folds
        purge_gap: Number of samples to purge between train and test
    """
    
    def __init__(self, n_splits: int = 5, purge_gap: int = 10):
        self.n_splits = n_splits
        self.purge_gap = purge_gap
    
    def split(self, X: np.ndarray, y: Optional[np.ndarray] = None, 
              groups: Optional[np.ndarray] = None) -> Generator[Tuple[np.ndarray, np.ndarray], None, None]:
        """
        Generate train/test indices.
        
        Args:
            X: Features array
            y: Labels (unused, for compatibility)
            groups: Groups (unused)
        
        Yields:
            Tuple of (train_indices, test_indices)
        """
        n_samples = len(X)
        fold_size = n_samples // (self.n_splits + 1)  # +1 because we need space for test
        
        for i in range(self.n_splits):
            # Test set position (progressively later in the series)
            test_start = (i + 1) * fold_size
            test_end = test_start + fold_size
            
            # Train set: everything before test, minus purge gap
            train_end = max(0, test_start - self.purge_gap)
            train_indices = np.arange(0, train_end)
            
            # Test set
            test_indices = np.arange(test_start, min(test_end, n_samples))
            
            if len(train_indices) > 0 and len(test_indices) > 0:
                yield train_indices, test_indices
    
    def get_n_splits(self, X: Optional[np.ndarray] = None, 
                     y: Optional[np.ndarray] = None, 
                     groups: Optional[np.ndarray] = None) -> int:
        return self.n_splits


class WalkForwardCV(BaseCrossValidator):
    """
    Walk-Forward cross-validation (expanding window).
    
    Each fold:
    - Train on all data up to a point
    - Test on the next period
    - Window expands over time
    
    Args:
        n_splits: Number of test periods
        train_min_samples: Minimum training samples required
        test_size: Size of each test period
        purge_gap: Gap between train and test
    """
    
    def __init__(self, n_splits: int = 5, train_min_samples: int = 100,
                 test_size: int = 50, purge_gap: int = 10):
        self.n_splits = n_splits
        self.train_min_samples = train_min_samples
        self.test_size = test_size
        self.purge_gap = purge_gap
    
    def split(self, X: np.ndarray, y: Optional[np.ndarray] = None,
              groups: Optional[np.ndarray] = None) -> Generator[Tuple[np.ndarray, np.ndarray], None, None]:
        """Generate walk-forward splits."""
        n_samples = len(X)
        
        # Calculate spacing for test periods
        total_test_space = self.n_splits * self.test_size
        available_space = n_samples - self.train_min_samples - self.purge_gap
        
        if available_space < total_test_space:
            # Adjust test size to fit
            actual_test_size = available_space // self.n_splits
        else:
            actual_test_size = self.test_size
        
        for i in range(self.n_splits):
            # Test period
            test_start = self.train_min_samples + self.purge_gap + (i * actual_test_size)
            test_end = test_start + actual_test_size
            
            if test_end > n_samples:
                break
            
            # Train period (everything before, minus purge)
            train_end = test_start - self.purge_gap
            train_indices = np.arange(0, train_end)
            test_indices = np.arange(test_start, test_end)
            
            if len(train_indices) >= self.train_min_samples:
                yield train_indices, test_indices
    
    def get_n_splits(self, X: Optional[np.ndarray] = None,
                     y: Optional[np.ndarray] = None,
                     groups: Optional[np.ndarray] = None) -> int:
        return self.n_splits


class CombinatorialPurgedCV(BaseCrossValidator):
    """
    Combinatorial Purged Cross-Validation.
    
    Generates all possible train/test combinations where:
    - Test groups are non-overlapping
    - Train groups are purged around test groups
    - Preserves temporal order within groups
    
    Args:
        n_groups: Number of groups to divide data into
        n_test_groups: Number of groups to use as test in each split
        purge_gap: Gap around test groups
    """
    
    def __init__(self, n_groups: int = 6, n_test_groups: int = 2, purge_gap: int = 10):
        self.n_groups = n_groups
        self.n_test_groups = n_test_groups
        self.purge_gap = purge_gap
        self._n_splits = None
    
    def split(self, X: np.ndarray, y: Optional[np.ndarray] = None,
              groups: Optional[np.ndarray] = None) -> Generator[Tuple[np.ndarray, np.ndarray], None, None]:
        """Generate combinatorial splits."""
        from itertools import combinations
        
        n_samples = len(X)
        group_size = n_samples // self.n_groups
        
        # Create group boundaries
        group_bounds = [(i * group_size, (i + 1) * group_size) for i in range(self.n_groups)]
        group_bounds[-1] = (group_bounds[-1][0], n_samples)  # Last group gets remainder
        
        # Generate all combinations of test groups
        for test_group_indices in combinations(range(self.n_groups), self.n_test_groups):
            # Test indices
            test_indices = []
            for gi in test_group_indices:
                start, end = group_bounds[gi]
                test_indices.extend(range(start, end))
            test_indices = np.array(sorted(test_indices))
            
            # Train indices (all groups not in test, with purging)
            train_indices = []
            for gi in range(self.n_groups):
                if gi in test_group_indices:
                    continue
                
                start, end = group_bounds[gi]
                
                # Check if adjacent to any test group
                for tgi in test_group_indices:
                    t_start, t_end = group_bounds[tgi]
                    
                    # Purge if adjacent
                    if gi == tgi - 1:  # Train group is before test
                        end = max(start, end - self.purge_gap)
                    elif gi == tgi + 1:  # Train group is after test
                        start = min(end, start + self.purge_gap)
                
                if start < end:
                    train_indices.extend(range(start, end))
            
            train_indices = np.array(sorted(train_indices))
            
            if len(train_indices) > 0 and len(test_indices) > 0:
                yield train_indices, test_indices
    
    def get_n_splits(self, X: Optional[np.ndarray] = None,
                     y: Optional[np.ndarray] = None,
                     groups: Optional[np.ndarray] = None) -> int:
        from math import comb
        return comb(self.n_groups, self.n_test_groups)


def calculate_wfe(train_scores: List[float], test_scores: List[float]) -> float:
    """
    Calculate Walk-Forward Efficiency (WFE).
    
    WFE measures how well in-sample performance translates to out-of-sample.
    WFE = mean(test_scores) / mean(train_scores)
    
    Target: WFE > 0.6 indicates robust model
    
    Args:
        train_scores: List of training scores per fold
        test_scores: List of test scores per fold
    
    Returns:
        WFE ratio (0 to 1+)
    """
    mean_train = np.mean(train_scores)
    mean_test = np.mean(test_scores)
    
    if mean_train == 0:
        return 0.0
    
    return mean_test / mean_train


def plot_cv_splits(cv: BaseCrossValidator, X: np.ndarray, 
                   figsize: Tuple[int, int] = (12, 6)) -> None:
    """
    Visualize cross-validation splits.
    
    Args:
        cv: Cross-validator instance
        X: Data array
        figsize: Figure size
    """
    try:
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available for plotting")
        return
    
    fig, ax = plt.subplots(figsize=figsize)
    
    n_samples = len(X)
    n_splits = cv.get_n_splits(X)
    
    for i, (train, test) in enumerate(cv.split(X)):
        # Create masks
        train_mask = np.zeros(n_samples)
        test_mask = np.zeros(n_samples)
        train_mask[train] = 1
        test_mask[test] = 2
        
        indices = np.arange(n_samples)
        
        ax.scatter(indices[train], [i] * len(train), c='blue', marker='|', s=100, label='Train' if i == 0 else '')
        ax.scatter(indices[test], [i] * len(test), c='red', marker='|', s=100, label='Test' if i == 0 else '')
    
    ax.set_xlabel('Sample Index')
    ax.set_ylabel('CV Fold')
    ax.set_title(f'{cv.__class__.__name__} Splits')
    ax.legend()
    plt.tight_layout()
    plt.show()


class TimeSeriesCV:
    """
    High-level interface for time series cross-validation.
    
    Provides easy access to different CV strategies with sensible defaults.
    """
    
    @staticmethod
    def get_purged_kfold(n_splits: int = 5, purge_gap: int = 10) -> PurgedKFold:
        """Get Purged K-Fold cross-validator."""
        return PurgedKFold(n_splits=n_splits, purge_gap=purge_gap)
    
    @staticmethod
    def get_walk_forward(n_splits: int = 5, train_min: int = 100,
                         test_size: int = 50, purge_gap: int = 10) -> WalkForwardCV:
        """Get Walk-Forward cross-validator."""
        return WalkForwardCV(
            n_splits=n_splits,
            train_min_samples=train_min,
            test_size=test_size,
            purge_gap=purge_gap
        )
    
    @staticmethod
    def get_combinatorial(n_groups: int = 6, n_test_groups: int = 2,
                          purge_gap: int = 10) -> CombinatorialPurgedCV:
        """Get Combinatorial Purged cross-validator."""
        return CombinatorialPurgedCV(
            n_groups=n_groups,
            n_test_groups=n_test_groups,
            purge_gap=purge_gap
        )


# Example usage
if __name__ == "__main__":
    np.random.seed(42)
    
    # Create sample data
    n_samples = 1000
    X = np.random.randn(n_samples, 15)
    y = np.random.randint(0, 2, n_samples)
    
    print("=== Purged K-Fold ===")
    cv1 = PurgedKFold(n_splits=5, purge_gap=10)
    for i, (train, test) in enumerate(cv1.split(X)):
        print(f"Fold {i+1}: Train {len(train)} samples [{train[0]}-{train[-1]}], "
              f"Test {len(test)} samples [{test[0]}-{test[-1]}]")
    
    print("\n=== Walk-Forward CV ===")
    cv2 = WalkForwardCV(n_splits=5, train_min_samples=200, test_size=100, purge_gap=20)
    for i, (train, test) in enumerate(cv2.split(X)):
        print(f"Fold {i+1}: Train {len(train)} samples [{train[0]}-{train[-1]}], "
              f"Test {len(test)} samples [{test[0]}-{test[-1]}]")
    
    print("\n=== Combinatorial Purged CV ===")
    cv3 = CombinatorialPurgedCV(n_groups=4, n_test_groups=1, purge_gap=10)
    print(f"Number of splits: {cv3.get_n_splits()}")
    for i, (train, test) in enumerate(cv3.split(X)):
        print(f"Split {i+1}: Train {len(train)} samples, Test {len(test)} samples")
    
    # Calculate WFE example
    print("\n=== Walk-Forward Efficiency ===")
    train_scores = [0.85, 0.87, 0.84, 0.86, 0.88]
    test_scores = [0.72, 0.69, 0.71, 0.70, 0.73]
    wfe = calculate_wfe(train_scores, test_scores)
    print(f"WFE = {wfe:.3f} (target > 0.6)")
    
    if wfe >= 0.6:
        print("✓ Model appears robust")
    else:
        print("✗ Model may be overfitting")
