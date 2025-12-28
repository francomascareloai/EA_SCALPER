"""Anti-overfitting detection for optimization results.

Implements cliff, island, and regime-bias detectors per Plan 10-05.
These detect common overfitting patterns in optimized parameter sets.
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from src.optimization.config import ParameterSpec
    from src.optimization.search.base import TrialResult


class OverfitWarningType(str, Enum):
    """Types of overfitting warnings."""

    CLIFF_LOW = "CLIFF_LOW"
    CLIFF_HIGH = "CLIFF_HIGH"
    ISLAND = "ISLAND"
    REGIME_BIAS = "REGIME_BIAS"


class OverfitSeverity(str, Enum):
    """Severity levels for overfitting warnings."""

    WARN = "WARN"
    CRITICAL = "CRITICAL"


@dataclass(frozen=True, slots=True)
class OverfitWarning:
    """Warning about potential overfitting.

    Attributes:
        warning_type: Type of overfitting detected.
        parameter: Parameter name (for cliff warnings) or None.
        severity: WARN or CRITICAL.
        message: Human-readable description.
    """

    warning_type: OverfitWarningType
    parameter: str | None
    severity: OverfitSeverity
    message: str

    def to_dict(self) -> dict[str, str | None]:
        """Convert to dictionary for serialization."""
        return {
            "type": self.warning_type.value,
            "parameter": self.parameter,
            "severity": self.severity.value,
            "message": self.message,
        }


def detect_cliff(
    best_params: dict[str, float],
    param_specs: list[ParameterSpec],
    tolerance: float = 0.05,
) -> list[OverfitWarning]:
    """Detect if best params are at edge of parameter range.

    Parameters at the edge of their range suggest the optimum might be
    outside the search space, or the parameter is hitting a constraint.

    Args:
        best_params: The optimized parameters (name -> value).
        param_specs: Parameter specifications with min/max ranges.
        tolerance: How close to edge is "cliff" (default 5% of range).

    Returns:
        List of CLIFF_LOW or CLIFF_HIGH warnings for parameters at edges.

    Example:
        If param "threshold" has range [0.1, 1.0] and optimized to 0.12,
        that's within 5% of the low edge, triggering CLIFF_LOW.
    """
    warnings: list[OverfitWarning] = []

    for spec in param_specs:
        # Skip categorical or params without range
        if spec.range is None:
            continue

        param_name = spec.name
        if param_name not in best_params:
            continue

        value = best_params[param_name]
        low, high = spec.range
        range_size = high - low

        # Avoid division by zero for degenerate ranges
        if range_size <= 0:
            continue

        # Check low edge
        # Formula: (value - low) / range_size < tolerance
        # Example: low=0.1, high=1.0, value=0.12, range=0.9
        #          (0.12 - 0.1) / 0.9 = 0.022 < 0.05 → CLIFF_LOW
        distance_from_low = (value - low) / range_size
        if distance_from_low < tolerance:
            warnings.append(
                OverfitWarning(
                    warning_type=OverfitWarningType.CLIFF_LOW,
                    parameter=param_name,
                    severity=OverfitSeverity.WARN,
                    message=(
                        f"{param_name}={value:.4f} is within {tolerance * 100:.0f}% "
                        f"of min={low:.4f} (range [{low:.4f}, {high:.4f}])"
                    ),
                )
            )

        # Check high edge
        # Formula: (high - value) / range_size < tolerance
        distance_from_high = (high - value) / range_size
        if distance_from_high < tolerance:
            warnings.append(
                OverfitWarning(
                    warning_type=OverfitWarningType.CLIFF_HIGH,
                    parameter=param_name,
                    severity=OverfitSeverity.WARN,
                    message=(
                        f"{param_name}={value:.4f} is within {tolerance * 100:.0f}% "
                        f"of max={high:.4f} (range [{low:.4f}, {high:.4f}])"
                    ),
                )
            )

    return warnings


def detect_island(
    results: list[TrialResult],
    top_k: int = 5,
    neighbor_threshold: float = 0.10,
) -> list[OverfitWarning]:
    """Detect if best result is isolated (no good neighbors).

    An "island" is when the best parameter set has no similar configurations
    among the other top performers. This suggests the optimum might be a
    noise artifact rather than a robust solution.

    Args:
        results: All trial results, assumed sorted by score descending.
        top_k: How many top results to check for neighbors (default 5).
        neighbor_threshold: Parameter distance threshold (default 10%).
            Two configs are "neighbors" if ALL params are within this
            relative distance.

    Returns:
        List containing ISLAND warning if best is isolated, else empty.

    Example:
        If best has params {a: 0.5, b: 2.0} but none of the next 5 best
        have params within 10% of those values, it's an island.
    """
    warnings: list[OverfitWarning] = []

    # Need at least best + top_k others to check
    if len(results) < top_k + 1:
        return warnings

    best = results[0]
    top_results = results[1 : top_k + 1]

    # Check if any top result is "close" to best
    has_neighbor = False
    for result in top_results:
        if _params_are_close(best.params, result.params, neighbor_threshold):
            has_neighbor = True
            break

    if not has_neighbor:
        warnings.append(
            OverfitWarning(
                warning_type=OverfitWarningType.ISLAND,
                parameter=None,
                severity=OverfitSeverity.CRITICAL,
                message=(
                    f"Best result (trial {best.trial_id}) has no neighbors "
                    f"in top {top_k + 1} within {neighbor_threshold * 100:.0f}% "
                    f"param distance. May be noise artifact."
                ),
            )
        )

    return warnings


def detect_regime_bias(
    result: TrialResult,
    min_coverage: float = 0.20,
) -> list[OverfitWarning]:
    """Detect if result performs well only in specific regime.

    A strategy that only works in one market regime (e.g., trending) but
    fails in others (ranging, volatile) is likely overfit to that regime.

    Args:
        result: Trial result with regime_scores dict.
        min_coverage: Minimum performance ratio vs best regime (default 20%).
            Regimes below this threshold trigger warnings.

    Returns:
        List of REGIME_BIAS warnings for underperforming regimes.

    Note:
        Degrades gracefully if regime_scores unavailable (returns empty list).
    """
    warnings: list[OverfitWarning] = []

    # Check if regime_scores available
    if not hasattr(result, "regime_scores"):
        return warnings  # Degrade gracefully

    regime_scores = result.regime_scores
    if not regime_scores:
        return warnings

    # Find best performing regime
    max_score = max(regime_scores.values())
    if max_score <= 0:
        return warnings  # All regimes negative, different issue

    # Check each regime against the best
    for regime, score in regime_scores.items():
        # Formula: ratio = score / max_score
        # Example: max=1.5, score=0.2 → ratio=0.133 < 0.20 → REGIME_BIAS
        ratio = score / max_score if max_score > 0 else 0.0

        if ratio < min_coverage:
            warnings.append(
                OverfitWarning(
                    warning_type=OverfitWarningType.REGIME_BIAS,
                    parameter=None,
                    severity=OverfitSeverity.WARN,
                    message=(
                        f"Regime '{regime}' has {ratio * 100:.1f}% of best regime "
                        f"performance (score={score:.3f} vs max={max_score:.3f}). "
                        f"Strategy may be overfit to specific market conditions."
                    ),
                )
            )

    return warnings


def _params_are_close(
    params1: dict[str, object],
    params2: dict[str, object],
    threshold: float,
) -> bool:
    """Check if two param sets are within threshold relative distance.

    Two parameter sets are considered "close" if ALL common numeric
    parameters are within the threshold relative distance.

    Args:
        params1: First parameter set.
        params2: Second parameter set.
        threshold: Maximum relative distance (e.g., 0.10 = 10%).

    Returns:
        True if all params are within threshold, False otherwise.
    """
    common_keys = set(params1.keys()) & set(params2.keys())
    if not common_keys:
        return False

    # Track if any numeric comparison actually happened
    numeric_compared = False

    for key in common_keys:
        v1 = params1[key]
        v2 = params2[key]

        # Skip non-numeric params (categorical)
        if not isinstance(v1, (int, float)) or not isinstance(v2, (int, float)):
            continue

        numeric_compared = True

        # Both zero is exact match
        if v1 == 0 and v2 == 0:
            continue

        # Calculate relative distance
        # Formula: |v1 - v2| / max(|v1|, |v2|)
        max_val = max(abs(v1), abs(v2))
        if max_val == 0:
            continue

        relative_distance = abs(v1 - v2) / max_val
        if relative_distance > threshold:
            return False

    # If no numeric params were compared, params are NOT considered close
    # (fail-closed: can't claim proximity without evidence)
    return numeric_compared


def run_all_detectors(
    results: list[TrialResult],
    param_specs: list[ParameterSpec],
    *,
    cliff_tolerance: float = 0.05,
    island_top_k: int = 5,
    island_neighbor_threshold: float = 0.10,
    regime_min_coverage: float = 0.20,
) -> list[OverfitWarning]:
    """Run all overfitting detectors on the top result.

    Convenience function that runs all detectors with configurable params.

    Args:
        results: Trial results sorted by score descending.
        param_specs: Parameter specifications.
        cliff_tolerance: Cliff detection tolerance (default 5%).
        island_top_k: Number of top results to check for neighbors.
        island_neighbor_threshold: Neighbor distance threshold.
        regime_min_coverage: Minimum regime coverage ratio.

    Returns:
        Combined list of all warnings from all detectors.
    """
    if not results:
        return []

    best = results[0]
    all_warnings: list[OverfitWarning] = []

    # Run cliff detection on best params
    all_warnings.extend(
        detect_cliff(
            best_params=best.params,
            param_specs=param_specs,
            tolerance=cliff_tolerance,
        )
    )

    # Run island detection
    all_warnings.extend(
        detect_island(
            results=results,
            top_k=island_top_k,
            neighbor_threshold=island_neighbor_threshold,
        )
    )

    # Run regime bias detection
    all_warnings.extend(
        detect_regime_bias(
            result=best,
            min_coverage=regime_min_coverage,
        )
    )

    return all_warnings


def summarize_warnings(warnings: list[OverfitWarning]) -> dict[str, int]:
    """Summarize warnings by type for reporting.

    Args:
        warnings: List of overfitting warnings.

    Returns:
        Dict mapping warning type to count.
    """
    summary: dict[str, int] = {}
    for w in warnings:
        key = w.warning_type.value
        summary[key] = summary.get(key, 0) + 1
    return summary
