"""
Base search strategy interface.
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import Any, Callable

from nautilus_gold_scalper.src.optimization.config import OptimizationConfig


@dataclass
class TrialResult:
    """Result from a single optimization trial."""

    trial_id: int
    params: dict[str, Any]

    # Performance metrics
    sqn: float
    sharpe: float
    sortino: float
    profit_factor: float
    total_pnl: float
    trades: int
    win_rate: float
    max_drawdown_pct: float

    # Validation metrics
    wfe: float
    wfe_std: float
    positive_days_ratio: float
    regime_scores: dict[str, float]

    # Apex compliance
    trailing_dd: float
    daily_profit_max: float
    time_gate_violations: int
    overnight_positions: int
    apex_compliant: bool

    # Composite score
    score: float

    # Stress test results (populated in Layer 3)
    mc_95_dd: float | None = None
    mc_99_dd: float | None = None
    degradation_survived: list[float] | None = None
    pbo: float | None = None

    # Metadata
    duration_seconds: float = 0.0
    output_dir: str = ""
    pruned: bool = False


ObjectiveFn = Callable[[dict[str, Any]], TrialResult]
ConstraintFn = Callable[[TrialResult], list[float]]


class SearchStrategy(ABC):
    """Abstract base class for search strategies."""

    def __init__(self, config: OptimizationConfig) -> None:
        self.config = config

    @abstractmethod
    def search(
        self,
        objective_fn: ObjectiveFn,
        constraint_fn: ConstraintFn | None = None,
    ) -> list[TrialResult]:
        """
        Execute search and return list of trial results.

        Args:
            objective_fn: Function that takes params dict and returns TrialResult
            constraint_fn: Optional function that returns constraint violations

        Returns:
            List of TrialResult sorted by score (best first)
        """
        ...

    @abstractmethod
    def get_best_params(self) -> dict[str, Any]:
        """Get best parameters found during search."""
        ...

    @abstractmethod
    def get_study_summary(self) -> dict[str, Any]:
        """Get summary statistics from the search."""
        ...
