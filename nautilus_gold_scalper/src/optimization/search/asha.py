"""ASHA (Asynchronous Successive Halving Algorithm) search strategy.

Provides asynchronous multi-fidelity optimization that doesn't require
synchronization barriers, enabling better parallelism.

Key benefits over synchronous Successive Halving:
- No waiting for slowest trial in each rung
- Better GPU/CPU utilization
- Earlier termination of poor configurations

Reference: Li et al. 2020 "A System for Massively Parallel Hyperparameter Tuning"
"""

from __future__ import annotations

import logging
import threading
import time
from collections.abc import Callable, Iterator
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from typing import Any

from src.optimization.config import OptimizationConfig
from src.optimization.search.base import (
    ConstraintFn,
    ObjectiveFn,
    SearchStrategy,
    TrialResult,
)

logger = logging.getLogger(__name__)


@dataclass
class ASHARung:
    """Represents a rung in ASHA."""

    level: int  # Rung index (0 = cheapest)
    wfa_windows: int  # WFA windows for this rung
    window_days: int  # Training window days (0 = full)
    feed_mode: str  # 'ticks' or 'bars'
    bars_file: str | None


class ASHASearch(SearchStrategy):
    """Asynchronous Successive Halving Algorithm (ASHA).

    Unlike synchronous Successive Halving, ASHA promotes configurations
    as soon as they complete, without waiting for all configurations
    in a rung to finish. This enables better parallelism.

    Key differences from SuccessiveHalvingSearch:
    - No synchronization barriers between rungs
    - Configurations are promoted immediately when they qualify
    - Uses a promotion rule based on relative ranking
    """

    def __init__(
        self,
        config: OptimizationConfig,
        *,
        on_result: Callable[[TrialResult], None] | None = None,
        max_results_in_ram: int | None = None,
        objective_fn_with_fidelity: (
            Callable[[dict[str, Any], str, str, int, str, str | None], TrialResult] | None
        ) = None,
        n_workers: int = 4,
        grace_period: int = 1,
        reduction_factor: int = 4,
    ) -> None:
        """Initialize ASHA search.

        Args:
            config: Optimization configuration
            on_result: Optional callback for each result
            max_results_in_ram: Cap on results kept in memory
            objective_fn_with_fidelity: Fidelity-aware objective function
            n_workers: Number of parallel workers
            grace_period: Minimum evaluations before pruning
            reduction_factor: Reduction factor between rungs (eta)
        """
        super().__init__(config, on_result=on_result, max_results_in_ram=max_results_in_ram)
        self._objective_fidelity = objective_fn_with_fidelity
        self._n_workers = n_workers
        self._grace_period = grace_period
        self._reduction_factor = reduction_factor

        # Concurrency control
        self._lock = threading.Lock()
        self._trial_counter = 0
        self._start_time: float = 0.0
        self._asha_results: list[TrialResult] = []  # Separate list for ASHA

        # Rung tracking: rung_level -> list of (score, trial_id, params, result)
        self._rung_results: dict[int, list[tuple[float, int, dict[str, Any], TrialResult]]] = {}

    def search(
        self,
        objective_fn: ObjectiveFn,
        constraint_fn: ConstraintFn | None = None,
    ) -> list[TrialResult]:
        """Execute ASHA search with asynchronous parallel evaluation."""
        _ = objective_fn  # Use fidelity-aware version instead

        if self._objective_fidelity is None:
            raise ValueError("objective_fn_with_fidelity must be provided for ASHA")

        self._start_time = time.time()
        self._asha_results = []
        self._trial_counter = 0

        sh = self.config.search.successive_halving
        if not sh.enabled:
            raise ValueError("successive_halving.enabled is false")

        # Build rung schedule
        rungs = self._build_rungs()
        if not rungs:
            raise ValueError("No rungs defined for ASHA")

        # Initialize rung result tracking
        for rung in rungs:
            self._rung_results[rung.level] = []

        # Generate initial candidates
        n_initial = self.config.search.trials
        candidates = list(self._generate_candidates(n_initial))

        # Create work queue: (rung_level, params)
        work_queue: list[tuple[int, dict[str, Any]]] = [(0, c) for c in candidates]

        # Process work items in parallel
        with ThreadPoolExecutor(max_workers=self._n_workers) as executor:
            futures: dict[Any, tuple[int, dict[str, Any]]] = {}
            completed = 0
            max_trials = n_initial * len(rungs)  # Upper bound

            while work_queue or futures:
                # Submit work up to worker limit
                while work_queue and len(futures) < self._n_workers:
                    rung_level, params = work_queue.pop(0)
                    rung = rungs[rung_level]
                    future = executor.submit(
                        self._evaluate_config,
                        params,
                        rung,
                        constraint_fn,
                    )
                    futures[future] = (rung_level, params)

                if not futures:
                    break

                # Wait for at least one completion
                done = []
                for future in as_completed(futures, timeout=300):
                    done.append(future)
                    break  # Process one at a time for proper promotion logic

                for future in done:
                    rung_level, params = futures.pop(future)

                    try:
                        result = future.result()
                        completed += 1

                        # Record result
                        with self._lock:
                            self._rung_results[rung_level].append(
                                (result.score, result.trial_id, params, result)
                            )

                        # Check if should promote to next rung
                        if rung_level < len(rungs) - 1:
                            if self._should_promote(rung_level, result.score):
                                work_queue.append((rung_level + 1, params))

                    except Exception:
                        logger.exception("ASHA evaluation failed")
                        completed += 1

                # Early stop if we've done enough
                if completed >= max_trials:
                    break

        # Sort results: prioritize highest rung, then by score
        max_rung = len(rungs) - 1
        self._asha_results.sort(
            key=lambda r: (
                r.apex_compliant,
                self._get_result_rung(r.trial_id) == max_rung,
                r.score,
            ),
            reverse=True,
        )

        return self._asha_results

    def _build_rungs(self) -> list[ASHARung]:
        """Build rung schedule from config."""
        sh = self.config.search.successive_halving
        rungs = []

        for i, (days, wfa, feed, bars) in enumerate(
            zip(sh.window_days, sh.wfa_windows, sh.feed_modes, sh.bars_files)
        ):
            rungs.append(
                ASHARung(
                    level=i,
                    wfa_windows=int(wfa),
                    window_days=int(days),
                    feed_mode=str(feed),
                    bars_file=bars,
                )
            )

        return rungs

    def _generate_candidates(self, n: int) -> Iterator[dict[str, Any]]:
        """Generate initial candidate configurations."""
        sampler = self.config.search.successive_halving.sampler

        if sampler == "sobol":
            from src.optimization.streaming.generator import StreamingSobolGenerator

            gen = StreamingSobolGenerator(
                self.config.parameters,
                seed=self.config.search.seed,
                n_samples=n,
            )
            yield from gen

        elif sampler == "levy":
            # Reuse Lévy generation from successive halving
            from src.optimization.search.successive_halving import SuccessiveHalvingSearch

            sh = SuccessiveHalvingSearch(
                self.config,
                objective_fn_with_fidelity=self._objective_fidelity,
            )
            yield from sh._iter_levy_candidates(n)

        else:
            # Default: LHS
            from src.optimization.streaming.generator import StreamingLHSGenerator

            lhs_gen = StreamingLHSGenerator(
                self.config.parameters,
                seed=self.config.search.seed,
                n_samples=n,
                batch_size=128,
            )
            yield from lhs_gen

    def _evaluate_config(
        self,
        params: dict[str, Any],
        rung: ASHARung,
        constraint_fn: ConstraintFn | None,
    ) -> TrialResult:
        """Evaluate a configuration at a given rung."""
        with self._lock:
            trial_id = self._trial_counter
            self._trial_counter += 1

        start_time = time.time()

        # Resolve date range for this rung
        start_date, end_date = self._resolve_rung_dates(rung.window_days)

        # Evaluate
        if self._objective_fidelity is None:
            raise RuntimeError("objective_fidelity not set")

        result = self._objective_fidelity(
            params,
            start_date,
            end_date,
            rung.wfa_windows,
            rung.feed_mode,
            rung.bars_file,
        )
        result.trial_id = trial_id
        result.duration_seconds = time.time() - start_time

        # Apply constraints:
        # - Full Apex constraints require tick-level bid/ask for conservative HWM marking
        # - BUT: time gates (4:30 PM block, overnight) CAN be checked even in bars mode
        # - See 12-11-OPTIMIZATION-ROADMAP.md TIER 1.1: "Don't promote configs that would die in ticks"
        if constraint_fn is not None:
            if rung.feed_mode == "ticks":
                # Full constraint checking for tick-based runs
                constraints = constraint_fn(result)
                if any(c > 0 for c in constraints):
                    result.apex_compliant = False
                    result.score = -999.0
            else:
                # Bars mode: check time-gate and overnight violations (timestamps available)
                has_time_violations = (
                    result.time_gate_violations > 0 or result.overnight_positions > 0
                )
                if has_time_violations:
                    result.apex_compliant = False
                    result.score = max(-500.0, result.score * 0.1)  # Heavy penalty

        # Record result
        self._record_result(result)
        with self._lock:
            self._asha_results.append(result)

        return result

    def _resolve_rung_dates(self, window_days: int) -> tuple[str, str]:
        """Resolve start/end dates for a rung."""
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

    def _should_promote(self, rung_level: int, score: float) -> bool:
        """Decide if a configuration should be promoted to the next rung.

        ASHA promotes a configuration if it's in the top 1/eta fraction
        of all configurations evaluated at this rung so far.
        """
        with self._lock:
            rung_results = self._rung_results.get(rung_level, [])

            if len(rung_results) < self._grace_period:
                # Not enough data to make promotion decision
                # In ASHA, we can still promote early configs
                return True

            # Sort by score (descending)
            scores = sorted([r[0] for r in rung_results], reverse=True)

            # Find rank of this score
            rank = 1
            for s in scores:
                if score >= s:
                    break
                rank += 1

            # Promote if in top 1/eta fraction
            promotion_threshold = max(1, len(scores) // self._reduction_factor)
            return rank <= promotion_threshold

    def _get_result_rung(self, trial_id: int) -> int:
        """Get the maximum rung level a trial reached."""
        max_rung = 0
        with self._lock:
            for rung_level, results in self._rung_results.items():
                for _, tid, _, _ in results:
                    if tid == trial_id:
                        max_rung = max(max_rung, rung_level)
        return max_rung

    def get_best_params(self) -> dict[str, Any]:
        """Get best parameters found during search."""
        if not self._results:
            return {}
        return dict(self._results[0].params)

    def get_study_summary(self) -> dict[str, Any]:
        """Get summary statistics from the search."""
        rung_counts = {
            f"rung_{level}_count": len(results) for level, results in self._rung_results.items()
        }

        return {
            "n_trials": self._trial_counter,
            "n_complete": len(self._results),
            "n_pruned": 0,  # ASHA doesn't explicitly prune
            "n_failed": 0,
            "best_value": self._results[0].score if self._results else None,
            "best_params": self.get_best_params(),
            "duration_seconds": time.time() - self._start_time,
            "mode": "asha",
            "n_workers": self._n_workers,
            "reduction_factor": self._reduction_factor,
            **rung_counts,
        }
