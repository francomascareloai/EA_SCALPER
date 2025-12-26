"""Successive Halving (multi-fidelity) search strategy.

Implements a simple Successive Halving loop using a streaming LHS-like
candidate generator.

Fidelity is approximated by:
- shorter train window (rolling window ending at train_end)
- fewer InlineWFA windows

This keeps RAM bounded and prunes poor configs early.
"""

from __future__ import annotations

import math
from collections.abc import Callable, Iterator
from datetime import timedelta
from typing import Any

import pandas as pd

from src.optimization.config import OptimizationConfig
from src.optimization.search.base import (
    ConstraintFn,
    ObjectiveFn,
    SearchStrategy,
    TrialResult,
)
from src.optimization.streaming.generator import StreamingLHSGenerator


class SuccessiveHalvingSearch(SearchStrategy):
    """Successive halving with date-range and WFA-window fidelity."""

    def __init__(
        self,
        config: OptimizationConfig,
        *,
        on_result: Callable[[TrialResult], None] | None = None,
        max_results_in_ram: int | None = None,
        objective_fn_with_fidelity: Callable[[dict[str, Any], str, str, int], TrialResult]
        | None = None,
        start_trial_id: int = 0,
        seed_results: list[TrialResult] | None = None,
        batch_size: int = 128,
    ) -> None:
        super().__init__(config, on_result=on_result, max_results_in_ram=max_results_in_ram)
        if start_trial_id < 0:
            raise ValueError("start_trial_id must be >= 0")
        self._start_trial_id = int(start_trial_id)
        if seed_results:
            self._results = list(seed_results)

        # `start_trial_id` represents already-completed evaluations across rungs.
        self._evaluated_total = int(self._start_trial_id)

        self._batch_size = batch_size
        self._objective_fidelity = objective_fn_with_fidelity

    def search(
        self,
        objective_fn: ObjectiveFn,
        constraint_fn: ConstraintFn | None = None,
    ) -> list[TrialResult]:
        # The public interface passes objective_fn(params). For successive halving we
        # require a fidelity-aware wrapper provided by ApexOptimizer.
        _ = objective_fn
        if self._objective_fidelity is None:
            raise ValueError("objective_fn_with_fidelity must be provided")

        # Preserve any seeded results (resume). If none, start empty.
        if self._start_trial_id == 0:
            self._results = []

        sh = self.config.search.successive_halving
        if not sh.enabled:
            raise ValueError("successive_halving.enabled is false")

        if sh.eta <= 1:
            raise ValueError("successive_halving.eta must be > 1")

        window_days = list(sh.window_days)
        wfa_windows = list(sh.wfa_windows)
        if len(window_days) == 0:
            raise ValueError("successive_halving.window_days must be non-empty")
        if len(window_days) != len(wfa_windows):
            raise ValueError("successive_halving.window_days and wfa_windows must have same length")

        # Candidate pool size: reuse trials for this mode.
        n0 = int(self.config.search.trials)
        if n0 <= 0:
            return []

        # Generate initial candidates (params only), stream results per rung.
        # NOTE: This intentionally materializes the candidate list. Keep n0 modest.
        candidates = list(self._iter_candidates(n0))

        trial_id = 0
        last_rung_trial_ids: set[int] = set()

        # If resuming, we skip evaluations until trial_id reaches start_trial_id.
        # This works because candidate generation + rung iteration are deterministic
        # given (seed, trials, successive_halving config).

        for rung_idx, (days, wfa_n) in enumerate(zip(window_days, wfa_windows)):
            start_date, end_date = self._resolve_rung_dates(days)

            rung_results: list[TrialResult] = []
            for params in candidates:
                if trial_id < self._start_trial_id:
                    trial_id += 1
                    continue

                result = self._objective_fidelity(params, start_date, end_date, int(wfa_n))
                result.trial_id = trial_id

                if rung_idx == len(window_days) - 1:
                    last_rung_trial_ids.add(trial_id)

                trial_id += 1

                if constraint_fn is not None:
                    constraints = constraint_fn(result)
                    if any(c > 0 for c in constraints):
                        result.apex_compliant = False
                        result.score = -999.0

                # Record all rung evaluations (streaming + RAM cap).
                self._record_result(result)
                rung_results.append(result)

            # Promote top fraction to next rung.
            rung_results.sort(key=self._metric_key(sh.promotion_metric), reverse=True)
            if rung_idx < len(window_days) - 1:
                k = max(1, int(math.ceil(len(rung_results) / sh.eta)))
                promoted = rung_results[:k]
                candidates = [r.params for r in promoted]

        # Ensure best params come from the last rung AND are Apex-compliant.
        # CRITICAL: apex_compliant must be part of sort key to prevent returning
        # a non-compliant config as "best" (would terminate live account).
        # Sort priority: (1) apex_compliant, (2) last_rung, (3) score
        self._results.sort(
            key=lambda r: (
                r.apex_compliant,  # Compliant first
                r.trial_id in last_rung_trial_ids,  # Last rung second
                r.score,  # Highest score third
            ),
            reverse=True,
        )
        return self._results

    def _iter_candidates(self, n: int) -> Iterator[dict[str, Any]]:
        generator = StreamingLHSGenerator(
            self.config.parameters,
            seed=self.config.search.seed,
            n_samples=n,
            batch_size=self._batch_size,
        )
        yield from generator

    def _resolve_rung_dates(self, window_days: int) -> tuple[str, str]:
        # Rung window ends at train_end (inclusive).
        end = pd.Timestamp(self.config.data.train_end)
        full_start = pd.Timestamp(self.config.data.train_start)

        if window_days <= 0:
            start = full_start
        else:
            # Example: end=2020-12-31, window_days=30 => start=2020-12-01
            start = end - timedelta(days=int(window_days) - 1)
            if start < full_start:
                start = full_start

        # Ensure string format matches existing code expectations.
        return start.strftime("%Y-%m-%d"), end.strftime("%Y-%m-%d")

    def _metric_key(self, metric: str) -> Callable[[TrialResult], float]:
        metric_l = metric.lower()
        if metric_l == "wfe":
            return lambda r: r.wfe
        if metric_l == "sqn":
            return lambda r: r.sqn
        return lambda r: r.score

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
            "mode": "successive_halving",
            "rungs": len(self.config.search.successive_halving.window_days),
            "results_retained_in_ram": len(self._results),
        }
