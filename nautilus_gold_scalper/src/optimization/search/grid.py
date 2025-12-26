"""Grid search strategy for Apex Optimizer.

Generates the Cartesian product of all parameter values.

Key requirements (Phase 10-02):
- Deterministic iteration order (reproducible).
- Fail-fast if estimated grid size exceeds `max_grid_size`.
- Avoid materializing the full grid in memory.

Supports optional on-disk streaming and bounded in-RAM retention via SearchStrategy.
"""

from __future__ import annotations

from collections.abc import Callable, Iterator
from typing import Any

from src.optimization.config import OptimizationConfig, ParameterSpec
from src.optimization.search.base import (
    ConstraintFn,
    ObjectiveFn,
    SearchStrategy,
    TrialResult,
)


class GridSearch(SearchStrategy):
    """Deterministic grid search over ParameterSpec ranges/choices."""

    def __init__(
        self,
        config: OptimizationConfig,
        *,
        on_result: Callable[[TrialResult], None] | None = None,
        max_results_in_ram: int | None = None,
        start_trial_id: int = 0,
        seed_results: list[TrialResult] | None = None,
    ) -> None:
        super().__init__(config, on_result=on_result, max_results_in_ram=max_results_in_ram)
        if start_trial_id < 0:
            raise ValueError("start_trial_id must be >= 0")
        self._start_trial_id = start_trial_id
        if seed_results:
            # Seed previously completed results so callers can reconstruct full history.
            self._results = list(seed_results)

        # `start_trial_id` represents already-completed trials (even if results are capped).
        self._evaluated_total = int(self._start_trial_id)

    def search(
        self,
        objective_fn: ObjectiveFn,
        constraint_fn: ConstraintFn | None = None,
    ) -> list[TrialResult]:
        # Preserve any seeded results (resume). If none, start empty.
        if self._start_trial_id == 0:
            self._results = []

        grid_size = estimate_grid_size(self.config.parameters)
        if grid_size > self.config.search.max_grid_size:
            raise ValueError(
                f"Grid size {grid_size:,} exceeds max_grid_size={self.config.search.max_grid_size:,}. "
                "Reduce parameter space or increase max_grid_size."
            )

        for trial_id, params in enumerate(iter_grid_params(self.config.parameters)):
            if trial_id < self._start_trial_id:
                continue

            result = objective_fn(params)
            result.trial_id = trial_id

            if constraint_fn is not None:
                constraints = constraint_fn(result)
                if any(c > 0 for c in constraints):
                    result.apex_compliant = False
                    result.score = -999.0

            self._record_result(result)

        self._results.sort(key=lambda r: r.score, reverse=True)
        return self._results

    def get_best_params(self) -> dict[str, Any]:
        if not self._results:
            return {}
        return self._results[0].params

    def get_study_summary(self) -> dict[str, Any]:
        return {
            "n_trials": int(self._evaluated_total),
            "n_complete": len([r for r in self._results if not r.pruned]),
            "n_pruned": len([r for r in self._results if r.pruned]),
            "n_failed": 0,
            "best_value": self._results[0].score if self._results else None,
            "best_params": self.get_best_params(),
            "mode": "grid",
            "grid_size": estimate_grid_size(self.config.parameters),
            "results_retained_in_ram": len(self._results),
        }


def estimate_grid_size(parameters: list[ParameterSpec]) -> int:
    size = 1
    for spec in parameters:
        size *= estimate_param_cardinality(spec)
    return size


def estimate_param_cardinality(spec: ParameterSpec) -> int:
    # If choices is specified, use it directly (works for any type)
    if spec.choices is not None:
        if len(spec.choices) == 0:
            raise ValueError(f"Parameter {spec.name}: choices cannot be empty")
        return len(spec.choices)

    if spec.param_type in ("float", "int"):
        # R13-FIX: Replace assert with explicit validation
        if spec.range is None:
            raise ValueError(
                f"spec.range is required for {spec.param_type} parameter '{spec.name}'"
            )
        if spec.step is None or spec.step <= 0:
            raise ValueError(f"Parameter {spec.name}: step must be set for grid search")

        low, high = spec.range
        if high < low:
            raise ValueError(f"Parameter {spec.name}: invalid range ({low}, {high})")

        # CRITICAL: Use round() to avoid float precision issues.
        # Problem: int((0.3 - 0.0) / 0.1) = int(2.999...) = 2, but should be 3.
        # Solution: round to nearest integer, which handles small float errors.
        # Formula: n = round((high - low) / step) + 1
        # Example: (0.3 - 0.0) / 0.1 = 2.999... → round → 3 → n = 4 ✓
        step = float(spec.step)
        n = int(round((high - low) / step)) + 1
        if n <= 0:
            raise ValueError(f"Parameter {spec.name}: empty grid (check range/step)")
        return n

    if spec.param_type == "categorical":
        # Already handled above if choices is not None
        raise ValueError(f"Parameter {spec.name}: choices required for categorical")

    raise ValueError(f"Unsupported param_type: {spec.param_type}")


def iter_grid_values(spec: ParameterSpec) -> Iterator[Any]:
    # If choices is specified, use it directly (works for any type: int, float, categorical)
    if spec.choices is not None:
        for v in spec.choices:
            yield v
        return

    # Range-based iteration for float/int
    if spec.param_type == "float":
        # R13-FIX: Replace assert with explicit validation
        if spec.range is None:
            raise ValueError(
                f"spec.range is required for {spec.param_type} parameter '{spec.name}'"
            )
        if spec.step is None:
            raise ValueError(f"spec.step is required for {spec.param_type} parameter '{spec.name}'")
        low, high = spec.range
        n = estimate_param_cardinality(spec)
        # CRITICAL: Float precision fix
        # Formula: value = round(low + i * step, 10) clamped to [low, high]
        # Example: low=0.001, step=0.001, high=0.01, n=10
        #   i=9 → raw = 0.001 + 9*0.001 = 0.01 → round → 0.01 → clamp → 0.01 ✓
        # Without this fix, accumulated error can produce 0.010000000000000002
        for i in range(n):
            raw_val = low + i * spec.step
            # Round to 10 decimals to eliminate floating-point accumulation error
            rounded_val = round(raw_val, 10)
            # Clamp to range to ensure last value doesn't exceed high
            clamped_val = max(low, min(high, rounded_val))
            yield clamped_val
        return

    if spec.param_type == "int":
        # R13-FIX: Replace assert with explicit validation
        if spec.range is None:
            raise ValueError(
                f"spec.range is required for {spec.param_type} parameter '{spec.name}'"
            )
        if spec.step is None:
            raise ValueError(f"spec.step is required for {spec.param_type} parameter '{spec.name}'")
        low, high = spec.range
        step_int = int(spec.step)
        low_int, high_int = int(low), int(high)
        for v in range(low_int, high_int + 1, step_int):
            yield v
        return

    if spec.param_type == "categorical":
        # Already handled above if choices is not None
        raise ValueError(f"Parameter {spec.name}: choices required for categorical")

    raise ValueError(f"Unsupported param_type: {spec.param_type}")


def iter_grid_params(parameters: list[ParameterSpec]) -> Iterator[dict[str, Any]]:
    """Yield param dicts in deterministic order without materializing the grid."""

    def rec(idx: int, acc: dict[str, Any]) -> Iterator[dict[str, Any]]:
        if idx >= len(parameters):
            yield dict(acc)
            return

        spec = parameters[idx]
        for value in iter_grid_values(spec):
            acc[spec.name] = value
            yield from rec(idx + 1, acc)

    return rec(0, {})
