"""Base search strategy interface."""

from __future__ import annotations

from abc import ABC, abstractmethod
from collections.abc import Callable
from dataclasses import dataclass
from typing import Any

from src.optimization.config import OptimizationConfig


@dataclass(slots=True)
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
    daily_dd: float
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

    # Overfitting warnings (populated in Layer 3)
    overfit_warnings: list[dict[str, str | None]] | None = None

    # Metadata
    duration_seconds: float = 0.0
    output_dir: str = ""
    pruned: bool = False


ObjectiveFn = Callable[[dict[str, Any]], TrialResult]
ConstraintFn = Callable[[TrialResult], list[float]]
OnResultFn = Callable[[TrialResult], None]


class SearchStrategy(ABC):
    """Abstract base class for search strategies."""

    def __init__(
        self,
        config: OptimizationConfig,
        *,
        on_result: OnResultFn | None = None,
        max_results_in_ram: int | None = None,
    ) -> None:
        self.config = config
        self._on_result = on_result
        self._max_results_in_ram = max_results_in_ram
        self._results: list[TrialResult] = []
        self._evaluated_total: int = 0

    def _record_result(self, result: TrialResult) -> None:
        if self._on_result is not None:
            self._on_result(result)

        self._evaluated_total += 1

        self._results.append(result)

        if self._max_results_in_ram is not None and len(self._results) > self._max_results_in_ram:
            # Keep only top-N by score to cap RAM.
            self._results.sort(key=lambda r: r.score, reverse=True)
            del self._results[self._max_results_in_ram :]

    @abstractmethod
    def search(
        self,
        objective_fn: ObjectiveFn,
        constraint_fn: ConstraintFn | None = None,
    ) -> list[TrialResult]:
        """Execute search and return list of trial results."""

    @abstractmethod
    def get_best_params(self) -> dict[str, Any]:
        """Get best parameters found during search."""

    @abstractmethod
    def get_study_summary(self) -> dict[str, Any]:
        """Get summary statistics from the search."""
