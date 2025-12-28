"""Lévy-Enhanced Search Strategy with Gradient Memory and Bad Region Skip.

SPIKE: Testing AION-inspired techniques against our LHS baseline.

Techniques from AION optimizer:
1. Lévy Flight mutations (heavy-tailed steps for escaping local optima)
2. Gradient Memory (remember which directions improved score)
3. Bad Region Skip (avoid parameter regions with historically bad ROI)

Usage:
    from src.optimization.search.levy_enhanced import LevyEnhancedSearch
    search = LevyEnhancedSearch(config)
    results = search.search(objective_fn)
"""

from __future__ import annotations

import math
from collections import defaultdict
from collections.abc import Callable, Iterator
from dataclasses import dataclass, field
from typing import Any

import numpy as np

from src.optimization.config import OptimizationConfig, ParameterSpec
from src.optimization.search.base import (
    ConstraintFn,
    ObjectiveFn,
    SearchStrategy,
    TrialResult,
)


@dataclass
class GradientMemory:
    """Track which parameter directions led to improvements."""

    # param_name -> list of (direction: +1/-1, magnitude, success_count)
    directions: dict[str, list[tuple[int, float, int]]] = field(
        default_factory=lambda: defaultdict(list)
    )
    # param_name -> cumulative success direction (+1 = increase better, -1 = decrease better)
    cumulative: dict[str, float] = field(default_factory=lambda: defaultdict(float))

    def record(self, param_name: str, direction: int, magnitude: float, improved: bool) -> None:
        """Record a mutation outcome."""
        if improved:
            self.cumulative[param_name] += direction * magnitude
            self.directions[param_name].append((direction, magnitude, 1))
            # Keep only last 20 successful directions
            if len(self.directions[param_name]) > 20:
                self.directions[param_name] = self.directions[param_name][-20:]

    def get_bias(self, param_name: str) -> float:
        """Get directional bias for a parameter (-1 to +1)."""
        if param_name not in self.cumulative:
            return 0.0
        total = self.cumulative[param_name]
        # Normalize to -1..+1 range with soft saturation
        return math.tanh(total / 5.0)


@dataclass
class BadRegionTracker:
    """Track parameter regions that consistently produce bad results.

    Divides each parameter's range into bins and tracks average score per bin.
    """

    n_bins: int = 4
    min_samples_per_bin: int = 3
    bad_threshold_ratio: float = 0.3  # Bin is "bad" if avg < 30% of best
    max_samples_per_bin: int = 100  # Memory cap per bin

    # param_name -> bin_index -> list of scores
    bin_scores: dict[str, dict[int, list[float]]] = field(
        default_factory=lambda: defaultdict(lambda: defaultdict(list))
    )
    best_score: float = float("-inf")

    def record(
        self, params: dict[str, Any], score: float, param_specs: dict[str, ParameterSpec]
    ) -> None:
        """Record a trial result."""
        self.best_score = max(self.best_score, score)

        for name, value in params.items():
            if name not in param_specs:
                continue
            spec = param_specs[name]
            if spec.param_type == "categorical":
                continue  # Skip categorical for now

            # Calculate bin index
            if spec.range is None:
                continue
            low, high = spec.range
            if high == low:
                continue
            normalized = (value - low) / (high - low)
            bin_idx = min(int(normalized * self.n_bins), self.n_bins - 1)
            bin_list = self.bin_scores[name][bin_idx]
            bin_list.append(score)
            # Memory cap: keep only last N samples per bin
            if len(bin_list) > self.max_samples_per_bin:
                self.bin_scores[name][bin_idx] = bin_list[-self.max_samples_per_bin :]

    def is_bad_region(self, param_name: str, value: float, spec: ParameterSpec) -> bool:
        """Check if a parameter value falls in a historically bad region."""
        if spec.param_type == "categorical":
            return False

        if spec.range is None:
            return False
        low, high = spec.range
        if high == low:
            return False

        normalized = (value - low) / (high - low)
        bin_idx = min(int(normalized * self.n_bins), self.n_bins - 1)

        scores = self.bin_scores.get(param_name, {}).get(bin_idx, [])
        if len(scores) < self.min_samples_per_bin:
            return False  # Not enough data

        avg_score = sum(scores) / len(scores)
        threshold = self.best_score * self.bad_threshold_ratio

        return avg_score < threshold

    def should_skip(self, params: dict[str, Any], param_specs: dict[str, ParameterSpec]) -> bool:
        """Check if we should skip this parameter combination."""
        if self.best_score == float("-inf"):
            return False  # No data yet

        bad_count = 0
        total_numeric = 0

        for name, value in params.items():
            if name not in param_specs:
                continue
            spec = param_specs[name]
            if spec.param_type == "categorical":
                continue

            total_numeric += 1
            if self.is_bad_region(name, value, spec):
                bad_count += 1

        if total_numeric == 0:
            return False

        # Skip if >70% of parameters are in bad regions
        return (bad_count / total_numeric) > 0.7


class LevyEnhancedSearch(SearchStrategy):
    """Search strategy using Lévy flights, gradient memory, and bad region skip.

    This is a SPIKE to compare against LHS baseline.
    """

    # Lévy flight parameters
    LEVY_ALPHA: float = 1.5  # Lévy exponent (1.5 = good balance exploration/exploitation)
    SIGMA_LEVY: float = 0.6  # Scale for Lévy steps

    # Probability controls
    GRADIENT_MEMORY_PROB: float = 0.7  # Prob of using gradient memory when available
    QUANTUM_TUNNEL_PROB: float = 0.05  # Prob of 5x step (escape local optima)
    ELITE_CROSSOVER_PROB: float = 0.1  # Prob of crossover with elite

    # Temperature adaptation
    TEMP_MIN: float = 0.05
    TEMP_MAX: float = 2.0
    TEMP_DECAY: float = 0.95
    TEMP_GROWTH: float = 1.05

    def __init__(
        self,
        config: OptimizationConfig,
        *,
        on_result: Callable[[TrialResult], None] | None = None,
        max_results_in_ram: int | None = None,
        n_elite: int = 5,
        warmup_samples: int = 20,
    ) -> None:
        super().__init__(config, on_result=on_result, max_results_in_ram=max_results_in_ram)

        self._n_elite = n_elite
        self._warmup_samples = warmup_samples
        self._temperature = 1.0
        self._stagnation = 0
        self._improvements = 0

        # State trackers
        self._gradient_memory = GradientMemory()
        self._bad_regions = BadRegionTracker()
        self._elite: list[TrialResult] = []
        self._param_specs = {p.name: p for p in config.parameters}

        # Metrics for comparison
        self._total_evaluations = 0
        self._skipped_bad_region = 0
        self._used_gradient_memory = 0
        self._used_quantum_tunnel = 0
        self._used_elite_crossover = 0

        # RNG
        self._rng = np.random.default_rng(config.search.seed or 42)

    def search(
        self,
        objective_fn: ObjectiveFn,
        constraint_fn: ConstraintFn | None = None,
    ) -> list[TrialResult]:
        self._results: list[TrialResult] = []
        n_samples = self.config.search.n_samples

        # Phase 1: Warmup with random samples (like LHS)
        warmup_params = list(self._generate_warmup_samples(self._warmup_samples))
        for trial_id, params in enumerate(warmup_params):
            result = self._evaluate(trial_id, params, objective_fn, constraint_fn)
            self._update_state(params, result, improved=True)  # All warmup are "improvements"

        # Phase 2: Lévy-enhanced exploration
        current_best = self._get_best_params()
        for trial_id in range(self._warmup_samples, n_samples):
            # Generate candidate via Lévy mutation
            candidate = self._generate_candidate(current_best)

            # Bad region skip
            if self._should_skip(candidate):
                self._skipped_bad_region += 1
                continue

            # Evaluate
            result = self._evaluate(trial_id, candidate, objective_fn, constraint_fn)

            # Check improvement
            improved = result.score > (self._elite[0].score if self._elite else float("-inf"))
            self._update_state(candidate, result, improved)

            # Update current best for next iteration
            if improved:
                current_best = candidate
                self._improvements += 1
                self._stagnation = 0
            else:
                self._stagnation += 1

            # Temperature adaptation
            self._adapt_temperature(improved)

        self._results.sort(key=lambda r: r.score, reverse=True)
        return self._results

    def _generate_warmup_samples(self, n: int) -> Iterator[dict[str, Any]]:
        """Generate initial random samples using stratified sampling."""
        for _ in range(n):
            params: dict[str, Any] = {}
            for spec in self.config.parameters:
                if spec.param_type == "categorical":
                    params[spec.name] = self._rng.choice(spec.choices)
                else:
                    if spec.range is None:
                        raise ValueError(
                            f"Parameter {spec.name}: range required for {spec.param_type}"
                        )
                    low, high = spec.range
                    if spec.param_type == "int":
                        params[spec.name] = int(self._rng.integers(int(low), int(high) + 1))
                    else:
                        params[spec.name] = float(self._rng.uniform(low, high))
            yield params

    def _generate_candidate(self, base: dict[str, Any]) -> dict[str, Any]:
        """Generate candidate using Lévy flight + gradient memory."""
        candidate: dict[str, Any] = {}

        def _reflect_to_bounds(value: float, low: float, high: float) -> float:
            width = high - low
            if width <= 0:
                return low
            x = (value - low) % (2.0 * width)
            if x > width:
                x = 2.0 * width - x
            return low + x

        def _stochastic_round(value: float) -> int:
            lo = math.floor(value)
            hi = lo + 1
            p_hi = value - float(lo)
            return int(hi if self._rng.random() < p_hi else lo)

        # Elite crossover check
        use_crossover = self._rng.random() < self.ELITE_CROSSOVER_PROB and len(self._elite) >= 2
        if use_crossover:
            self._used_elite_crossover += 1
            donor = self._rng.choice(self._elite[1:])  # Pick non-best elite
            crossover_mask = self._rng.random(len(self.config.parameters)) < 0.5
        else:
            donor = None
            crossover_mask = None

        for i, spec in enumerate(self.config.parameters):
            if spec.param_type == "categorical":
                # For categorical, just use base or random
                if use_crossover and crossover_mask is not None and crossover_mask[i]:
                    candidate[spec.name] = donor.params[spec.name] if donor else base.get(spec.name)
                else:
                    candidate[spec.name] = base.get(spec.name, self._rng.choice(spec.choices))
                continue

            if spec.range is None:
                raise ValueError(f"Parameter {spec.name}: range required for {spec.param_type}")
            low, high = spec.range
            base_value = base.get(spec.name, (low + high) / 2)
            param_range = high - low

            # Apply step
            if spec.log_scale:
                if low <= 0 or high <= 0:
                    raise ValueError(
                        f"Parameter {spec.name}: log_scale requires positive range, got ({low}, {high})"
                    )
                base_log = math.log10(max(float(base_value), 1e-12))
                low_log = math.log10(low)
                high_log = math.log10(high)
                log_range = high_log - low_log
                new_log = base_log + self._levy_step() * self._temperature * log_range * 0.1
                if self._rng.random() < self.QUANTUM_TUNNEL_PROB:
                    new_log += self._levy_step() * self._temperature * log_range * 0.4
                    self._used_quantum_tunnel += 1
                gradient_bias = self._gradient_memory.get_bias(spec.name)
                if abs(gradient_bias) > 0.1 and self._rng.random() < self.GRADIENT_MEMORY_PROB:
                    new_log *= 1 + gradient_bias
                    self._used_gradient_memory += 1
                new_value = float(10 ** _reflect_to_bounds(new_log, low_log, high_log))
            else:
                # Raw-space Lévy step + reflection.
                step = self._levy_step() * self._temperature * param_range * 0.1
                if self._rng.random() < self.QUANTUM_TUNNEL_PROB:
                    step *= 5.0
                    self._used_quantum_tunnel += 1
                gradient_bias = self._gradient_memory.get_bias(spec.name)
                if abs(gradient_bias) > 0.1 and self._rng.random() < self.GRADIENT_MEMORY_PROB:
                    step *= 1 + gradient_bias
                    self._used_gradient_memory += 1
                new_value = _reflect_to_bounds(float(base_value) + step, low, high)

            # Quantize if integer
            if spec.param_type == "int":
                new_value = _stochastic_round(float(new_value))
                new_value = int(max(int(low), min(int(high), new_value)))
            elif spec.step:
                # Snap to step grid
                step_size = float(spec.step)
                if step_size > 0:
                    new_value = low + round((float(new_value) - low) / step_size) * step_size
                    new_value = _reflect_to_bounds(float(new_value), low, high)

            # Elite crossover
            if use_crossover and crossover_mask is not None and crossover_mask[i] and donor:
                new_value = donor.params.get(spec.name, new_value)

            candidate[spec.name] = new_value

        return candidate

    def _levy_step(self) -> float:
        """Generate a Lévy flight step.

        Uses Mantegna's algorithm for generating Lévy-stable random numbers.
        """
        # Mantegna's algorithm
        # sigma_u = (gamma(1+alpha) * sin(pi*alpha/2) / (gamma((1+alpha)/2) * alpha * 2^((alpha-1)/2)))^(1/alpha)
        # Simplified for alpha=1.5:
        sigma_u = self.SIGMA_LEVY

        u = self._rng.normal(0, sigma_u)
        v = self._rng.normal(0, 1)

        # Lévy step with epsilon guard to prevent division by zero
        v_safe = max(abs(v), 1e-10)
        step = u / (v_safe ** (1 / self.LEVY_ALPHA))

        return float(step)

    def _should_skip(self, params: dict[str, Any]) -> bool:
        """Decide whether to skip this candidate."""
        # Don't skip during warmup
        if self._total_evaluations < self._warmup_samples:
            return False

        # Don't skip if skip rate is too high (>60%)
        if self._total_evaluations > 0:
            skip_rate = self._skipped_bad_region / self._total_evaluations
            if skip_rate > 0.6:
                return False

        # Random pass-through (20% always evaluate)
        if self._rng.random() < 0.2:
            return False

        return self._bad_regions.should_skip(params, self._param_specs)

    def _evaluate(
        self,
        trial_id: int,
        params: dict[str, Any],
        objective_fn: ObjectiveFn,
        constraint_fn: ConstraintFn | None,
    ) -> TrialResult:
        """Evaluate a parameter configuration."""
        self._total_evaluations += 1

        result = objective_fn(params)
        result.trial_id = trial_id

        if constraint_fn is not None:
            constraints = constraint_fn(result)
            if any(c > 0 for c in constraints):
                result.apex_compliant = False
                result.score = -999.0

        self._record_result(result)
        return result

    def _update_state(self, params: dict[str, Any], result: TrialResult, improved: bool) -> None:
        """Update internal state after evaluation."""
        # Update bad region tracker
        self._bad_regions.record(params, result.score, self._param_specs)

        # Update gradient memory
        if len(self._results) >= 2 and improved:
            prev_best = self._elite[0] if self._elite else self._results[-2]
            for name, value in params.items():
                if name not in self._param_specs:
                    continue
                spec = self._param_specs[name]
                if spec.param_type == "categorical":
                    continue

                prev_value = prev_best.params.get(name, value)
                if prev_value != value:
                    direction = 1 if value > prev_value else -1
                    if spec.range is None:
                        continue
                    low, high = spec.range
                    width = high - low
                    if width <= 0:
                        continue
                    magnitude = abs(value - prev_value) / width
                    self._gradient_memory.record(name, direction, magnitude, improved)

        # Update elite pool
        if result.score > float("-inf"):
            self._elite.append(result)
            self._elite.sort(key=lambda r: r.score, reverse=True)
            self._elite = self._elite[: self._n_elite]

    def _adapt_temperature(self, improved: bool) -> None:
        """Adapt temperature based on search progress."""
        if improved:
            # Exploitation: decrease temperature
            self._temperature *= self.TEMP_DECAY
        else:
            # Exploration: increase temperature if stagnating
            if self._stagnation > 10:
                self._temperature *= self.TEMP_GROWTH

        # Clamp temperature
        self._temperature = max(self.TEMP_MIN, min(self.TEMP_MAX, self._temperature))

    def _get_best_params(self) -> dict[str, Any]:
        """Get current best parameters."""
        if self._elite:
            return dict(self._elite[0].params)
        if self._results:
            return dict(self._results[0].params)
        # Random start
        return next(self._generate_warmup_samples(1))

    def get_best_params(self) -> dict[str, Any]:
        return dict(self._get_best_params())

    def get_study_summary(self) -> dict[str, Any]:
        return {
            "n_trials": self._total_evaluations,
            "n_complete": len([r for r in self._results if not r.pruned]),
            "n_pruned": len([r for r in self._results if r.pruned]),
            "n_failed": 0,
            "best_value": self._results[0].score if self._results else None,
            "best_params": self.get_best_params(),
            "mode": "levy_enhanced",
            "samples": int(self.config.search.n_samples),
            "results_retained_in_ram": len(self._results),
            # Spike-specific metrics
            "levy_metrics": {
                "skipped_bad_region": self._skipped_bad_region,
                "used_gradient_memory": self._used_gradient_memory,
                "used_quantum_tunnel": self._used_quantum_tunnel,
                "used_elite_crossover": self._used_elite_crossover,
                "final_temperature": self._temperature,
                "improvements": self._improvements,
                "stagnation": self._stagnation,
            },
        }
