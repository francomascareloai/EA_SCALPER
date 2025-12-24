"""Grid search strategy for Apex Optimizer.

Generates the Cartesian product of all parameter values.

Key requirements (Phase 10-02):
- Deterministic iteration order (reproducible).
- Fail-fast if estimated grid size exceeds `max_grid_size`.
- Avoid materializing the full grid in memory.
"""

from __future__ import annotations

from collections.abc import Iterator
from typing import Any

from nautilus_gold_scalper.src.optimization.config import OptimizationConfig, ParameterSpec
from nautilus_gold_scalper.src.optimization.search.base import (
    ConstraintFn,
    ObjectiveFn,
    SearchStrategy,
    TrialResult,
)


class GridSearch(SearchStrategy):
    """Deterministic grid search over ParameterSpec ranges/choices."""

    def __init__(self, config: OptimizationConfig) -> None:
        super().__init__(config)
        self._results: list[TrialResult] = []

    def search(
        self,
        objective_fn: ObjectiveFn,
        constraint_fn: ConstraintFn | None = None,
    ) -> list[TrialResult]:
        self._results = []

        grid_size = estimate_grid_size(self.config.parameters)
        if grid_size > self.config.search.max_grid_size:
            raise ValueError(
                f"Grid size {grid_size:,} exceeds max_grid_size={self.config.search.max_grid_size:,}. "
                "Reduce parameter space or increase max_grid_size."
            )

        for trial_id, params in enumerate(iter_grid_params(self.config.parameters)):
            result = objective_fn(params)

            # Attach trial id (objective returns TrialResult with trial_id=0)
            result.trial_id = trial_id

            if constraint_fn is not None:
                constraints = constraint_fn(result)
                if any(c > 0 for c in constraints):
                    # Match BayesianSearch behavior: hard reject
                    result.apex_compliant = False
                    result.score = -999.0

            self._results.append(result)

        self._results.sort(key=lambda r: r.score, reverse=True)
        return self._results

    def get_best_params(self) -> dict[str, Any]:
        if not self._results:
            return {}
        return self._results[0].params

    def get_study_summary(self) -> dict[str, Any]:
        return {
            "n_trials": len(self._results),
            "n_complete": len([r for r in self._results if not r.pruned]),
            "n_pruned": len([r for r in self._results if r.pruned]),
            "n_failed": 0,
            "best_value": self._results[0].score if self._results else None,
            "best_params": self.get_best_params(),
            "mode": "grid",
            "grid_size": len(self._results),
        }


def estimate_grid_size(parameters: list[ParameterSpec]) -> int:
    size = 1
    for spec in parameters:
        size *= estimate_param_cardinality(spec)
    return size


def estimate_param_cardinality(spec: ParameterSpec) -> int:
    if spec.param_type in ("float", "int"):
        assert spec.range is not None
        if spec.step is None or spec.step <= 0:
            raise ValueError(f"Parameter {spec.name}: step must be set for grid search")

        low, high = spec.range
        if high < low:
            raise ValueError(f"Parameter {spec.name}: invalid range ({low}, {high})")

        # inclusive endpoints, with step
        n = int((high - low) / spec.step) + 1
        if n <= 0:
            raise ValueError(f"Parameter {spec.name}: empty grid (check range/step)")
        return n

    if spec.param_type == "categorical":
        assert spec.choices is not None
        if len(spec.choices) == 0:
            raise ValueError(f"Parameter {spec.name}: choices cannot be empty")
        return len(spec.choices)

    raise ValueError(f"Unsupported param_type: {spec.param_type}")


def iter_grid_values(spec: ParameterSpec) -> Iterator[Any]:
    if spec.param_type == "float":
        assert spec.range is not None
        assert spec.step is not None
        low, high = spec.range
        n = estimate_param_cardinality(spec)
        for i in range(n):
            yield low + i * spec.step
        return

    if spec.param_type == "int":
        assert spec.range is not None
        assert spec.step is not None
        low, high = spec.range
        step_int = int(spec.step)
        low_int, high_int = int(low), int(high)
        for v in range(low_int, high_int + 1, step_int):
            yield v
        return

    if spec.param_type == "categorical":
        assert spec.choices is not None
        for v in spec.choices:
            yield v
        return

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
