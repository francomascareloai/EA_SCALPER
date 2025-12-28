"""Adaptive fidelity selection for multi-fidelity optimization.

Dynamically selects the optimal fidelity level for each configuration,
balancing evaluation cost vs information gain.

Key concepts:
- Low-fidelity: Faster but noisier estimates (fewer WFA windows, shorter periods)
- High-fidelity: Slower but more accurate estimates (full data, full WFA)
- Adaptive selection: Use low-fidelity to screen, high-fidelity to confirm

Inspired by FastBO and FABOLAS approaches from AutoML research.

IMPORTANT (12-11-OPTIMIZATION-ROADMAP TIER 1.3):
- rank_correlation MUST be measured, not assumed
- Use validate_fidelity_correlation() before trusting multi-fidelity
- If correlation < 0.3, low-fidelity is INVALID for pruning
"""

from __future__ import annotations

import logging
from collections.abc import Callable
from dataclasses import dataclass
from typing import Any

import numpy as np

from src.optimization.config import OptimizationConfig
from src.optimization.search.base import TrialResult

logger = logging.getLogger(__name__)


@dataclass
class FidelityLevel:
    """Represents a fidelity level for evaluation."""

    level: int
    name: str
    window_days: int  # 0 = full range
    wfa_windows: int
    feed_mode: str  # 'ticks' or 'bars'
    bars_file: str | None = None

    # Cost model (relative to lowest fidelity)
    relative_cost: float = 1.0

    # Quality model (correlation with true performance)
    rank_correlation: float = 1.0


@dataclass
class AdaptiveFidelityConfig:
    """Configuration for adaptive fidelity selection."""

    # Fidelity levels (ordered by cost, ascending)
    fidelity_levels: list[FidelityLevel]

    # When to upgrade fidelity
    upgrade_threshold: float = 0.7  # Score quantile to upgrade
    min_samples_for_upgrade: int = 10  # Need this many samples to estimate quantile

    # Cost-quality tradeoff
    cost_weight: float = 0.3  # Higher = prefer cheaper evaluations
    quality_weight: float = 0.7  # Higher = prefer accurate evaluations

    # Exploration parameters
    initial_fidelity: int = 0  # Start at lowest fidelity
    max_low_fidelity_evals: int = 100  # Max evals before forcing upgrade


class AdaptiveFidelitySelector:
    """Selects optimal fidelity level for each configuration.

    Uses a bandit-like approach to balance exploration (trying different
    fidelities) with exploitation (using the best-performing fidelity).
    """

    def __init__(
        self,
        config: OptimizationConfig,
        adaptive_config: AdaptiveFidelityConfig | None = None,
    ) -> None:
        """Initialize adaptive fidelity selector.

        Args:
            config: Optimization configuration
            adaptive_config: Adaptive fidelity configuration
        """
        self.config = config

        # Build default fidelity levels from successive halving config if not provided
        if adaptive_config is None:
            adaptive_config = self._build_default_config()

        self.adaptive_config = adaptive_config

        # Tracking state
        self._level_stats: dict[int, _LevelStats] = {}
        for level in adaptive_config.fidelity_levels:
            self._level_stats[level.level] = _LevelStats()

        self._current_level: int = adaptive_config.initial_fidelity
        self._total_evals: int = 0

    def _build_default_config(self) -> AdaptiveFidelityConfig:
        """Build default config from successive halving settings.

        WARNING (12-11-OPTIMIZATION-ROADMAP TIER 1.3):
        The rank_correlation values here are ASSUMED, not measured.
        Use validate_fidelity_correlation() to measure actual correlation
        before trusting multi-fidelity promotion decisions.
        """
        sh = self.config.search.successive_halving
        levels = []

        # Log warning about assumed correlation values
        logger.warning(
            "AdaptiveFidelity: rank_correlation values are ASSUMED (0.5-1.0), not measured. "
            "Run validate_fidelity_correlation() to verify multi-fidelity is valid. "
            "See 12-11-OPTIMIZATION-ROADMAP.md TIER 1.3."
        )

        for i, (days, wfa, feed, bars) in enumerate(
            zip(sh.window_days, sh.wfa_windows, sh.feed_modes, sh.bars_files)
        ):
            # Estimate relative cost based on window size and WFA windows
            base_cost = 1.0
            if days > 0:
                # Shorter windows are cheaper
                base_cost = days / 365.0
            cost_multiplier = wfa / max(sh.wfa_windows)

            # ASSUMED correlation - increases linearly with fidelity level
            # This is a heuristic; actual correlation should be measured with
            # validate_fidelity_correlation() for critical optimization runs
            assumed_correlation = 0.5 + 0.5 * (i / max(1, len(sh.window_days) - 1))

            levels.append(
                FidelityLevel(
                    level=i,
                    name=f"rung_{i}",
                    window_days=int(days),
                    wfa_windows=int(wfa),
                    feed_mode=str(feed),
                    bars_file=bars,
                    relative_cost=base_cost * cost_multiplier,
                    rank_correlation=assumed_correlation,
                )
            )

        return AdaptiveFidelityConfig(fidelity_levels=levels)

    def select_fidelity(
        self,
        params: dict[str, Any],
        *,
        predicted_score: float | None = None,
    ) -> FidelityLevel:
        """Select the optimal fidelity level for a configuration.

        Args:
            params: Configuration parameters
            predicted_score: Optional predicted score from surrogate model

        Returns:
            Selected fidelity level
        """
        levels = self.adaptive_config.fidelity_levels

        if not levels:
            raise ValueError("No fidelity levels configured")

        # Initial phase: use lowest fidelity
        if self._total_evals < self.adaptive_config.min_samples_for_upgrade:
            return levels[self._current_level]

        # Check if we should upgrade based on observed performance
        should_upgrade = self._should_upgrade_fidelity(predicted_score)

        if should_upgrade and self._current_level < len(levels) - 1:
            self._current_level += 1
            logger.info(f"Upgrading to fidelity level {self._current_level}")

        # Force upgrade if too many low-fidelity evals
        low_fidelity_evals = self._level_stats[0].n_evals
        if low_fidelity_evals >= self.adaptive_config.max_low_fidelity_evals:
            if self._current_level < len(levels) - 1:
                self._current_level = min(self._current_level + 1, len(levels) - 1)

        return levels[self._current_level]

    def _should_upgrade_fidelity(self, predicted_score: float | None) -> bool:
        """Determine if we should upgrade to higher fidelity.

        Upgrade when we have high-scoring configurations that would
        benefit from more accurate evaluation.
        """
        if predicted_score is None:
            # No prediction available - use statistical approach
            current_stats = self._level_stats.get(self._current_level)
            if current_stats is None or current_stats.n_evals < 5:
                return False

            # Upgrade if we've found some promising configs
            return current_stats.max_score > current_stats.mean_score + current_stats.std_score

        # Have prediction - upgrade if it's in top quantile
        current_stats = self._level_stats.get(self._current_level)
        if current_stats is None or current_stats.n_evals < 5:
            return predicted_score > 0.5

        threshold = current_stats.quantile(self.adaptive_config.upgrade_threshold)
        return predicted_score >= threshold

    def record_result(
        self,
        level: FidelityLevel,
        result: TrialResult,
    ) -> None:
        """Record the result of an evaluation.

        Args:
            level: Fidelity level used
            result: Evaluation result
        """
        stats = self._level_stats.get(level.level)
        if stats is not None:
            stats.add_score(result.score)

        self._total_evals += 1

    def get_fidelity_summary(self) -> dict[str, Any]:
        """Get summary of fidelity usage."""
        levels_summary: dict[str, dict[str, Any]] = {}

        for level in self.adaptive_config.fidelity_levels:
            stats = self._level_stats.get(level.level)
            if stats is not None:
                levels_summary[level.name] = {
                    "n_evals": stats.n_evals,
                    "mean_score": stats.mean_score,
                    "max_score": stats.max_score,
                    "relative_cost": level.relative_cost,
                }

        summary: dict[str, Any] = {
            "total_evals": self._total_evals,
            "current_level": self._current_level,
            "levels": levels_summary,
        }

        return summary

    def compute_expected_cost(self) -> float:
        """Compute expected total cost based on current fidelity usage."""
        total_cost = 0.0

        for level in self.adaptive_config.fidelity_levels:
            stats = self._level_stats.get(level.level)
            if stats is not None:
                total_cost += stats.n_evals * level.relative_cost

        return total_cost


class _LevelStats:
    """Track statistics for a fidelity level."""

    def __init__(self) -> None:
        self.n_evals: int = 0
        self.scores: list[float] = []

    def add_score(self, score: float) -> None:
        self.n_evals += 1
        self.scores.append(score)

    @property
    def mean_score(self) -> float:
        if not self.scores:
            return 0.0
        return float(np.mean(self.scores))

    @property
    def std_score(self) -> float:
        if len(self.scores) < 2:
            return 0.0
        return float(np.std(self.scores))

    @property
    def max_score(self) -> float:
        if not self.scores:
            return 0.0
        return float(np.max(self.scores))

    def quantile(self, q: float) -> float:
        if not self.scores:
            return 0.0
        return float(np.quantile(self.scores, q))


class AdaptiveFidelitySearch:
    """Wrapper that adds adaptive fidelity to any search strategy.

    This is a decorator/wrapper pattern that can be applied to existing
    search strategies to make them fidelity-aware.
    """

    def __init__(
        self,
        config: OptimizationConfig,
        objective_fn_with_fidelity: Callable[
            [dict[str, Any], str, str, int, str, str | None], TrialResult
        ],
        adaptive_config: AdaptiveFidelityConfig | None = None,
    ) -> None:
        """Initialize adaptive fidelity search wrapper.

        Args:
            config: Optimization configuration
            objective_fn_with_fidelity: Fidelity-aware objective function
            adaptive_config: Optional adaptive configuration
        """
        self.config = config
        self._objective_fidelity = objective_fn_with_fidelity
        self._selector = AdaptiveFidelitySelector(config, adaptive_config)

    def evaluate_with_adaptive_fidelity(
        self,
        params: dict[str, Any],
        *,
        predicted_score: float | None = None,
    ) -> TrialResult:
        """Evaluate a configuration with adaptively selected fidelity.

        Args:
            params: Configuration parameters
            predicted_score: Optional predicted score from surrogate

        Returns:
            Evaluation result
        """
        # Select fidelity level
        level = self._selector.select_fidelity(params, predicted_score=predicted_score)

        # Resolve date range
        start_date, end_date = self._resolve_dates(level.window_days)

        # Evaluate
        result = self._objective_fidelity(
            params,
            start_date,
            end_date,
            level.wfa_windows,
            level.feed_mode,
            level.bars_file,
        )

        # Record result
        self._selector.record_result(level, result)

        return result

    def _resolve_dates(self, window_days: int) -> tuple[str, str]:
        """Resolve date range for evaluation."""
        from datetime import timedelta

        import pandas as pd

        end = pd.Timestamp(self.config.data.train_end)
        full_start = pd.Timestamp(self.config.data.train_start)

        if window_days <= 0:
            start = full_start
        else:
            start = end - timedelta(days=int(window_days) - 1)
            if start < full_start:
                start = full_start

        return start.strftime("%Y-%m-%d"), end.strftime("%Y-%m-%d")

    def get_summary(self) -> dict[str, Any]:
        """Get summary of adaptive fidelity usage."""
        return self._selector.get_fidelity_summary()


# =============================================================================
# FIDELITY CORRELATION VALIDATION (12-11-OPTIMIZATION-ROADMAP TIER 1.3)
# =============================================================================


@dataclass
class FidelityCorrelationResult:
    """Result of fidelity correlation validation."""

    spearman_correlation: float
    p_value: float
    n_samples: int
    is_valid: bool  # True if correlation >= min_threshold
    top_5_overlap: int  # How many of low-fidelity top-5 appear in high-fidelity top-5
    message: str


def validate_fidelity_correlation(
    configs: list[dict[str, Any]],
    objective_fn_low: Callable[[dict[str, Any]], TrialResult],
    objective_fn_high: Callable[[dict[str, Any]], TrialResult],
    n_sample: int = 50,
    min_correlation: float = 0.3,
    seed: int = 42,
) -> FidelityCorrelationResult:
    """Validate that low-fidelity ranks correlate with high-fidelity ranks.

    This is a MANDATORY check before trusting multi-fidelity optimization.
    See 12-11-OPTIMIZATION-ROADMAP.md TIER 1.3.

    Args:
        configs: List of parameter configurations to test
        objective_fn_low: Low-fidelity objective function
        objective_fn_high: High-fidelity objective function
        n_sample: Number of configs to sample (default 50)
        min_correlation: Minimum Spearman correlation to consider valid (default 0.3)
        seed: Random seed for sampling

    Returns:
        FidelityCorrelationResult with validation status

    Example:
        >>> result = validate_fidelity_correlation(
        ...     configs=candidate_configs,
        ...     objective_fn_low=lambda c: run_rung0(c),
        ...     objective_fn_high=lambda c: run_rungN(c),
        ... )
        >>> if not result.is_valid:
        ...     logger.critical(f"Multi-fidelity INVALID: correlation={result.spearman_correlation:.2f}")
        ...     # Fall back to single-fidelity or fail-closed
    """
    # Import scipy here to avoid import error if not installed
    from scipy.stats import spearmanr

    rng = np.random.default_rng(seed)

    # Sample configs
    sample_size = min(n_sample, len(configs))
    if sample_size < 10:
        return FidelityCorrelationResult(
            spearman_correlation=0.0,
            p_value=1.0,
            n_samples=sample_size,
            is_valid=False,
            top_5_overlap=0,
            message=f"Insufficient configs for validation: {sample_size} < 10 required",
        )

    sample_indices = rng.choice(len(configs), size=sample_size, replace=False)
    sample_configs = [configs[i] for i in sample_indices]

    # Evaluate at both fidelity levels
    scores_low: list[float] = []
    scores_high: list[float] = []

    for cfg in sample_configs:
        try:
            result_low = objective_fn_low(cfg)
            result_high = objective_fn_high(cfg)
            scores_low.append(result_low.score)
            scores_high.append(result_high.score)
        except Exception as e:
            logger.warning(f"Fidelity validation: config evaluation failed: {e}")
            # Skip failed configs
            continue

    if len(scores_low) < 10:
        return FidelityCorrelationResult(
            spearman_correlation=0.0,
            p_value=1.0,
            n_samples=len(scores_low),
            is_valid=False,
            top_5_overlap=0,
            message=f"Too many evaluation failures: only {len(scores_low)} succeeded",
        )

    # Compute Spearman rank correlation
    correlation, p_value = spearmanr(scores_low, scores_high)

    # Handle NaN correlation (can happen with constant scores)
    if np.isnan(correlation):
        correlation = 0.0
        p_value = 1.0

    # Check top-5 overlap
    low_ranks = np.argsort(scores_low)[::-1][:5]  # Top 5 by low-fidelity
    high_ranks = np.argsort(scores_high)[::-1][:5]  # Top 5 by high-fidelity
    overlap = len(set(low_ranks) & set(high_ranks))

    # Determine validity
    is_valid = correlation >= min_correlation

    if not is_valid:
        message = (
            f"LOW fidelity correlation: {correlation:.2f} (p={p_value:.4f}) - "
            f"multi-fidelity INVALID for pruning (threshold={min_correlation})"
        )
        logger.critical(message)
    else:
        message = (
            f"Fidelity correlation: {correlation:.2f} (p={p_value:.4f}) - "
            f"multi-fidelity valid (top-5 overlap: {overlap}/5)"
        )
        logger.info(message)

    return FidelityCorrelationResult(
        spearman_correlation=float(correlation),
        p_value=float(p_value),
        n_samples=len(scores_low),
        is_valid=is_valid,
        top_5_overlap=overlap,
        message=message,
    )
