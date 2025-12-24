"""Random search strategy with Latin Hypercube Sampling (LHS).

Implements stratified sampling to ensure better coverage of the parameter space
than pure random sampling, while maintaining reproducibility via seed.

Key requirements (Phase 10-02):
- LHS / Stratified sampling behavior.
- Reproducibility (seed).
- No heavy dependencies (pure numpy/random).

This implementation uses a batch-streaming LHS-like generator to keep RAM bounded.
"""

from __future__ import annotations

import random
from collections.abc import Iterator
from typing import Any, Callable

import numpy as np

from src.optimization.config import OptimizationConfig
from src.optimization.search.base import (
    ConstraintFn,
    ObjectiveFn,
    SearchStrategy,
    TrialResult,
)
from src.optimization.streaming.generator import StreamingLHSGenerator


class RandomSearch(SearchStrategy):
    """Random search with stratified sampling (LHS-like)."""

    def __init__(
        self,
        config: OptimizationConfig,
        *,
        on_result: Callable[[TrialResult], None] | None = None,
        max_results_in_ram: int | None = None,
        batch_size: int = 128,
    ) -> None:
        super().__init__(config, on_result=on_result, max_results_in_ram=max_results_in_ram)
        self._rng = np.random.RandomState(config.search.seed)
        self._batch_size = batch_size
        random.seed(config.search.seed)

    def search(
        self,
        objective_fn: ObjectiveFn,
        constraint_fn: ConstraintFn | None = None,
    ) -> list[TrialResult]:
        self._results = []
        n_samples = self.config.search.n_samples

        for trial_id, params in enumerate(self._iter_samples(n_samples)):
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

    def _iter_samples(self, n_samples: int) -> Iterator[dict[str, Any]]:
        generator = StreamingLHSGenerator(
            self.config.parameters,
            seed=self.config.search.seed,
            n_samples=n_samples,
            batch_size=self._batch_size,
        )
        yield from generator

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
            "mode": "random",
            "samples": len(self._results),
        }
