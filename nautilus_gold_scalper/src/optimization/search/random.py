"""Random search strategy with Latin Hypercube Sampling (LHS).

Implements stratified sampling to ensure better coverage of the parameter space
than pure random sampling, while maintaining reproducibility via seed.

Key requirements (Phase 10-02):
- LHS / Stratified sampling behavior.
- Reproducibility (seed).
- No heavy dependencies (pure numpy/random).
"""

from __future__ import annotations

import random
from typing import Any

import numpy as np
import numpy.typing as npt

from nautilus_gold_scalper.src.optimization.config import OptimizationConfig, ParameterSpec
from nautilus_gold_scalper.src.optimization.search.base import (
    ConstraintFn,
    ObjectiveFn,
    SearchStrategy,
    TrialResult,
)


class RandomSearch(SearchStrategy):
    """Random search with stratified sampling (LHS-like)."""

    def __init__(self, config: OptimizationConfig) -> None:
        super().__init__(config)
        self._results: list[TrialResult] = []
        self._rng = np.random.RandomState(config.search.seed)
        # Python's random is used for some operations, seed it too
        random.seed(config.search.seed)

    def search(
        self,
        objective_fn: ObjectiveFn,
        constraint_fn: ConstraintFn | None = None,
    ) -> list[TrialResult]:
        self._results = []
        n_samples = self.config.search.n_samples

        # Generate stratified samples for all parameters upfront
        # This ensures we cover the space evenly (LHS property)
        samples = self._generate_lhs_samples(n_samples)

        for trial_id, params in enumerate(samples):
            result = objective_fn(params)
            result.trial_id = trial_id

            if constraint_fn is not None:
                constraints = constraint_fn(result)
                if any(c > 0 for c in constraints):
                    result.apex_compliant = False
                    result.score = -999.0

            self._results.append(result)

        self._results.sort(key=lambda r: r.score, reverse=True)
        return self._results

    def _generate_lhs_samples(self, n_samples: int) -> list[dict[str, Any]]:
        """Generate N stratified samples."""
        # Dictionary to hold lists of values for each param
        param_values: dict[str, npt.NDArray[Any]] = {}

        for spec in self.config.parameters:
            if spec.param_type == "float":
                assert spec.range is not None
                low, high = spec.range

                if spec.log_scale:
                    # Log-uniform stratification
                    log_low, log_high = np.log10(low), np.log10(high)
                    strata = np.linspace(log_low, log_high, n_samples + 1)
                    # Sample uniformly within each stratum
                    uniforms = self._rng.uniform(strata[:-1], strata[1:])
                    values = np.power(10, uniforms)

                    # Round if step provided
                    if spec.step:
                        # Round to nearest step
                        steps = np.round((values - low) / spec.step)
                        values = low + steps * spec.step
                        # Clamp to range
                        values = np.clip(values, low, high)

                else:
                    # Uniform stratification
                    strata = np.linspace(low, high, n_samples + 1)
                    values = self._rng.uniform(strata[:-1], strata[1:])

                    if spec.step:
                        steps = np.round((values - low) / spec.step)
                        values = low + steps * spec.step
                        values = np.clip(values, low, high)

                # Shuffle the values for this parameter independently
                self._rng.shuffle(values)
                param_values[spec.name] = values

            elif spec.param_type == "int":
                assert spec.range is not None
                low, high = int(spec.range[0]), int(spec.range[1])
                step = int(spec.step) if spec.step else 1

                # For ints, we can't always guarantee N unique stratified samples
                # if the range is small. We sample with replacement if range < n_samples.
                domain_size = (high - low) // step + 1

                if domain_size >= n_samples:
                    # Stratified
                    # Divide domain into n_samples buckets (roughly)
                    # This is tricky for discrete, so we simplify:
                    # Just sample N uniform floats and discretize
                    strata = np.linspace(low, high + 0.99, n_samples + 1)
                    raw_values = self._rng.uniform(strata[:-1], strata[1:])
                    # Map to nearest valid step
                    steps = np.floor((raw_values - low) / step)
                    values = low + steps * step
                    values = np.clip(values, low, high).astype(int)
                else:
                    # Domain too small for LHS, just random sample with replacement
                    # but try to be as uniform as possible
                    choices = np.arange(low, high + 1, step)
                    values = self._rng.choice(choices, size=n_samples, replace=True)

                self._rng.shuffle(values)
                param_values[spec.name] = values

            elif spec.param_type == "categorical":
                assert spec.choices is not None
                # For categorical, we try to balance classes
                n_choices = len(spec.choices)
                base_count = n_samples // n_choices
                remainder = n_samples % n_choices

                # Create balanced list
                choice_indices = np.repeat(np.arange(n_choices), base_count)
                if remainder > 0:
                    extra = self._rng.choice(np.arange(n_choices), size=remainder, replace=False)
                    choice_indices = np.concatenate([choice_indices, extra])

                self._rng.shuffle(choice_indices)
                values = np.array([spec.choices[i] for i in choice_indices], dtype=object)
                param_values[spec.name] = values

        # Construct list of dicts
        samples = []
        for i in range(n_samples):
            params = {name: vals[i] for name, vals in param_values.items()}
            samples.append(params)

        return samples

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
