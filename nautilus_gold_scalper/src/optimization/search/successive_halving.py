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

import numpy as np
import pandas as pd

from src.optimization.config import OptimizationConfig
from src.optimization.search.base import (
    ConstraintFn,
    ObjectiveFn,
    SearchStrategy,
    TrialResult,
)
from src.optimization.streaming.generator import (
    StreamingLHSGenerator,
)


class SuccessiveHalvingSearch(SearchStrategy):
    """Successive halving with date-range and WFA-window fidelity."""

    def __init__(
        self,
        config: OptimizationConfig,
        *,
        on_result: Callable[[TrialResult], None] | None = None,
        max_results_in_ram: int | None = None,
        objective_fn_with_fidelity: (
            Callable[[dict[str, Any], str, str, int, str, str | None], TrialResult] | None
        ) = None,
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
        feed_modes = list(sh.feed_modes)
        bars_files = list(sh.bars_files)

        if len(window_days) == 0:
            raise ValueError("successive_halving.window_days must be non-empty")
        if len(window_days) != len(wfa_windows):
            raise ValueError("successive_halving.window_days and wfa_windows must have same length")
        if len(window_days) != len(feed_modes):
            raise ValueError("successive_halving.window_days and feed_modes must have same length")
        if len(window_days) != len(bars_files):
            raise ValueError("successive_halving.window_days and bars_files must have same length")

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

        for rung_idx, (days, wfa_n, feed_mode, bars_file) in enumerate(
            zip(window_days, wfa_windows, feed_modes, bars_files)
        ):
            start_date, end_date = self._resolve_rung_dates(days)

            rung_results: list[TrialResult] = []
            for params in candidates:
                if trial_id < self._start_trial_id:
                    trial_id += 1
                    continue

                result = self._objective_fidelity(
                    params,
                    start_date,
                    end_date,
                    int(wfa_n),
                    str(feed_mode),
                    bars_file,
                )
                result.trial_id = trial_id

                if rung_idx == len(window_days) - 1:
                    last_rung_trial_ids.add(trial_id)

                trial_id += 1

                # Constraints checking:
                # - Full Apex constraints (including HWM/DD) require tick-level bid/ask for conservative marking
                # - BUT: time gates (4:30 PM block, overnight) CAN be checked even in bars mode
                # - See 12-11-OPTIMIZATION-ROADMAP.md TIER 1.1: "Don't promote configs that would die in ticks"
                if constraint_fn is not None:
                    if str(feed_mode) == "ticks":
                        # Full constraint checking for tick-based runs
                        constraints = constraint_fn(result)
                        if any(c > 0 for c in constraints):
                            result.apex_compliant = False
                            result.score = -999.0
                    else:
                        # Bars mode: check time-gate and overnight violations (timestamps available)
                        # These are HARD constraints that don't require tick-level HWM precision
                        has_time_violations = (
                            result.time_gate_violations > 0 or result.overnight_positions > 0
                        )
                        if has_time_violations:
                            # Penalize heavily but don't fully eliminate
                            # (allows ranking while flagging as non-compliant)
                            result.apex_compliant = False
                            result.score = max(-500.0, result.score * 0.1)  # Heavy penalty

                # Record all rung evaluations (streaming + RAM cap).
                self._record_result(result)
                rung_results.append(result)

            # Promote top fraction to next rung.
            rung_results.sort(key=self._metric_key(sh.promotion_metric), reverse=True)
            if rung_idx < len(window_days) - 1:
                k = max(1, int(math.ceil(len(rung_results) / sh.eta)))
                promoted = rung_results[:k]
                candidates = [r.params for r in promoted]

                # Optional evolutionary refinement: mutate survivors before next rung.
                # This keeps SH as the outer loop (resource allocation) while using Lévy
                # steps to explore neighborhoods of promising configs.
                if sh.mutate_between_rungs and sh.sampler == "levy":
                    mut_rng = np.random.default_rng(self.config.search.seed + rung_idx + 1)
                    candidates = [
                        self._mutate_params_levy(
                            c,
                            rng=mut_rng,
                            mutate_prob=float(sh.mutate_prob),
                        )
                        for c in candidates
                    ]

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
        sampler = self.config.search.successive_halving.sampler
        if sampler == "levy":
            # Lévy-flight sampling (non-adaptive) for heavy-tailed exploration.
            yield from self._iter_levy_candidates(n)
        elif sampler == "sobol":
            # Sobol quasi-random sequences: ~3.5x better convergence than LHS.
            from src.optimization.streaming.generator import StreamingSobolGenerator

            sobol_gen = StreamingSobolGenerator(
                self.config.parameters,
                seed=self.config.search.seed,
                n_samples=n,
            )
            yield from sobol_gen
        else:
            # Default: use LHS (Latin Hypercube Sampling)
            lhs_gen = StreamingLHSGenerator(
                self.config.parameters,
                seed=self.config.search.seed,
                n_samples=n,
                batch_size=self._batch_size,
            )
            yield from lhs_gen

    def _iter_levy_candidates(self, n: int) -> Iterator[dict[str, Any]]:
        """Generate candidates using Lévy-flight mutations (non-adaptive).

        Successive halving generates candidates up-front, so this sampler is
        intentionally *static* (no gradient memory / bad-region feedback loop).

        Key safeguards (Argus):
        - Reflection boundary handling (avoid boundary-mass collapse from clipping)
        - Log-space sampling when `spec.log_scale` is set
        - Stochastic rounding for integers
        """

        rng = np.random.default_rng(self.config.search.seed)

        # Lévy step parameters: kept consistent with LevyEnhancedSearch.
        levy_alpha = 1.5
        sigma_levy = 0.6
        step_scale = 0.20  # fraction of range width applied to Lévy step

        def levy_step() -> float:
            # Mantegna's algorithm (with epsilon guard).
            u = float(rng.normal(0.0, sigma_levy))
            v = float(rng.normal(0.0, 1.0))
            v_safe = max(abs(v), 1e-10)
            return float(u / (v_safe ** (1.0 / levy_alpha)))

        def reflect_to_bounds(value: float, low: float, high: float) -> float:
            width = high - low
            if width <= 0:
                return low
            x = (value - low) % (2.0 * width)
            if x > width:
                x = 2.0 * width - x
            return low + x

        def stochastic_round(value: float) -> int:
            lo = math.floor(value)
            hi = lo + 1
            p_hi = value - float(lo)
            return int(hi if rng.random() < p_hi else lo)

        def random_params() -> dict[str, Any]:
            params: dict[str, Any] = {}
            for spec in self.config.parameters:
                if spec.param_type == "categorical":
                    if spec.choices is None or len(spec.choices) == 0:
                        raise ValueError(f"Parameter {spec.name}: choices required")
                    params[spec.name] = rng.choice(spec.choices)
                elif spec.param_type == "int":
                    if spec.range is None:
                        if spec.choices is None or len(spec.choices) == 0:
                            raise ValueError(f"Parameter {spec.name}: range or choices required")
                        params[spec.name] = int(rng.choice(spec.choices))
                    else:
                        low_f, high_f = spec.range
                        low_i, high_i = int(low_f), int(high_f)
                        params[spec.name] = int(rng.integers(low_i, high_i + 1))
                else:
                    # float
                    if spec.range is None:
                        if spec.choices is None or len(spec.choices) == 0:
                            raise ValueError(f"Parameter {spec.name}: range or choices required")
                        params[spec.name] = float(rng.choice(spec.choices))
                    else:
                        low_f, high_f = spec.range
                        if spec.log_scale:
                            if low_f <= 0 or high_f <= 0:
                                raise ValueError(
                                    f"Parameter {spec.name}: log_scale requires positive range, got ({low_f}, {high_f})"
                                )
                            log_low = math.log10(low_f)
                            log_high = math.log10(high_f)
                            u01 = float(rng.uniform(0.0, 1.0))
                            params[spec.name] = float(10 ** (log_low + (log_high - log_low) * u01))
                        else:
                            params[spec.name] = float(rng.uniform(low_f, high_f))
            return params

        def mutate_from_anchor(anchor: dict[str, Any]) -> dict[str, Any]:
            params: dict[str, Any] = {}
            for spec in self.config.parameters:
                if spec.param_type == "categorical":
                    # Keep categorical stable most of the time; occasionally resample.
                    if rng.random() < 0.10:
                        if spec.choices is None or len(spec.choices) == 0:
                            raise ValueError(f"Parameter {spec.name}: choices required")
                        params[spec.name] = rng.choice(spec.choices)
                    else:
                        params[spec.name] = anchor[spec.name]
                    continue

                if spec.range is None:
                    # Discrete domain via choices.
                    if spec.choices is None or len(spec.choices) == 0:
                        raise ValueError(f"Parameter {spec.name}: range or choices required")
                    params[spec.name] = anchor.get(spec.name, spec.choices[0])
                    continue

                low_f, high_f = spec.range
                width = high_f - low_f
                if width <= 0:
                    params[spec.name] = anchor.get(spec.name, low_f)
                    continue

                base = float(anchor.get(spec.name, (low_f + high_f) / 2.0))

                if spec.log_scale:
                    if low_f <= 0 or high_f <= 0:
                        raise ValueError(
                            f"Parameter {spec.name}: log_scale requires positive range, got ({low_f}, {high_f})"
                        )
                    base_log = math.log10(max(base, 1e-12))
                    low_log = math.log10(low_f)
                    high_log = math.log10(high_f)
                    new_log = base_log + levy_step() * (high_log - low_log) * step_scale
                    new_log = reflect_to_bounds(new_log, low_log, high_log)
                    new_value_f = float(10**new_log)
                else:
                    new_value_f = base + levy_step() * width * step_scale
                    new_value_f = reflect_to_bounds(new_value_f, low_f, high_f)

                if spec.step is not None and spec.param_type == "float":
                    step = float(spec.step)
                    if step > 0:
                        new_value_f = low_f + round((new_value_f - low_f) / step) * step
                        new_value_f = reflect_to_bounds(new_value_f, low_f, high_f)

                if spec.param_type == "int":
                    new_int = stochastic_round(new_value_f)
                    new_int = int(max(int(low_f), min(int(high_f), new_int)))
                    params[spec.name] = new_int
                else:
                    params[spec.name] = float(new_value_f)

            return params

        # Use a small number of anchors, then Lévy-mutate around them.
        n_anchors = max(1, min(5, int(math.sqrt(max(1, n)))))
        anchors = [random_params() for _ in range(n_anchors)]

        for i in range(n):
            if i < n_anchors:
                yield anchors[i]
            else:
                anchor = anchors[int(rng.integers(0, n_anchors))]
                yield mutate_from_anchor(anchor)

    def _mutate_params_levy(
        self,
        params: dict[str, Any],
        *,
        rng: np.random.Generator,
        mutate_prob: float,
    ) -> dict[str, Any]:
        """Apply Lévy-flight mutation to a params dict (for between-rung refinement)."""

        def reflect_to_bounds(value: float, low: float, high: float) -> float:
            width = high - low
            if width <= 0:
                return low
            x = (value - low) % (2.0 * width)
            if x > width:
                x = 2.0 * width - x
            return low + x

        def stochastic_round(value: float) -> int:
            lo = math.floor(value)
            hi = lo + 1
            p_hi = value - float(lo)
            return int(hi if rng.random() < p_hi else lo)

        levy_alpha = 1.5
        sigma_levy = 0.6
        step_scale = 0.10

        def levy_step() -> float:
            u = float(rng.normal(0.0, sigma_levy))
            v = float(rng.normal(0.0, 1.0))
            v_safe = max(abs(v), 1e-10)
            return float(u / (v_safe ** (1.0 / levy_alpha)))

        out: dict[str, Any] = dict(params)
        for spec in self.config.parameters:
            if rng.random() >= mutate_prob:
                continue

            name = spec.name
            if spec.param_type == "categorical":
                if spec.choices is None or len(spec.choices) == 0:
                    continue
                # mutate categorical with small chance
                if rng.random() < 0.10:
                    out[name] = rng.choice(spec.choices)
                continue

            if spec.range is None:
                continue

            low_f, high_f = spec.range
            width = high_f - low_f
            if width <= 0:
                continue

            base = float(out.get(name, (low_f + high_f) / 2.0))
            if spec.log_scale:
                if low_f <= 0 or high_f <= 0:
                    continue
                base_log = math.log10(max(base, 1e-12))
                low_log = math.log10(low_f)
                high_log = math.log10(high_f)
                new_log = base_log + levy_step() * (high_log - low_log) * step_scale
                new_log = reflect_to_bounds(new_log, low_log, high_log)
                new_value = float(10**new_log)
            else:
                new_value = reflect_to_bounds(
                    base + levy_step() * width * step_scale, low_f, high_f
                )

            if spec.param_type == "int":
                new_int = stochastic_round(new_value)
                out[name] = int(max(int(low_f), min(int(high_f), new_int)))
            else:
                if spec.step is not None:
                    step = float(spec.step)
                    if step > 0:
                        new_value = low_f + round((new_value - low_f) / step) * step
                        new_value = reflect_to_bounds(new_value, low_f, high_f)
                out[name] = float(new_value)

        return out

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
