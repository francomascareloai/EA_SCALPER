from __future__ import annotations

from collections.abc import Iterator
from typing import Any

import numpy as np
import numpy.typing as npt

from src.optimization.config import ParameterSpec


class StreamingLHSGenerator:
    """Batch-streaming LHS-like generator.

    True Latin Hypercube requires global coordination across all N samples.
    This generator provides a practical compromise:
    - Generate stratified samples in batches (each batch has LHS-like properties)
    - Yield samples one-by-one
    - Bounded memory: O(batch_size * n_params)

    Reproducible given the same seed and batch_size.
    """

    def __init__(
        self,
        parameters: list[ParameterSpec],
        *,
        seed: int,
        n_samples: int,
        batch_size: int = 128,
    ) -> None:
        if batch_size <= 0:
            raise ValueError("batch_size must be > 0")
        if n_samples < 0:
            raise ValueError("n_samples must be >= 0")

        self._parameters = parameters
        self._rng = np.random.RandomState(seed)
        self._remaining = n_samples
        self._batch_size = batch_size

    def __iter__(self) -> Iterator[dict[str, Any]]:
        while self._remaining > 0:
            current_batch = min(self._batch_size, self._remaining)
            yield from self._generate_batch(current_batch)
            self._remaining -= current_batch

    def _generate_batch(self, n: int) -> Iterator[dict[str, Any]]:
        param_values: dict[str, npt.NDArray[Any]] = {}

        for spec in self._parameters:
            if spec.param_type == "float":
                assert spec.range is not None
                low, high = spec.range
                strata = np.linspace(0.0, 1.0, n + 1)
                u = self._rng.uniform(strata[:-1], strata[1:])

                if spec.log_scale:
                    log_low = np.log10(low)
                    log_high = np.log10(high)
                    values = np.power(10, log_low + (log_high - log_low) * u)
                else:
                    values = low + (high - low) * u

                if spec.step:
                    steps = np.round((values - low) / spec.step)
                    values = low + steps * spec.step
                    values = np.clip(values, low, high)

                self._rng.shuffle(values)
                param_values[spec.name] = values

            elif spec.param_type == "int":
                assert spec.range is not None
                low_f, high_f = spec.range
                low, high = int(low_f), int(high_f)
                step = int(spec.step) if spec.step else 1

                choices = np.arange(low, high + 1, step)
                if len(choices) == 0:
                    raise ValueError(f"Parameter {spec.name}: empty int domain")

                replace = len(choices) < n
                values = self._rng.choice(choices, size=n, replace=replace)
                self._rng.shuffle(values)
                param_values[spec.name] = values.astype(int)

            elif spec.param_type == "categorical":
                assert spec.choices is not None
                n_choices = len(spec.choices)
                if n_choices == 0:
                    raise ValueError(f"Parameter {spec.name}: empty choices")

                base = n // n_choices
                rem = n % n_choices
                idx = np.repeat(np.arange(n_choices), base)
                if rem:
                    extra = self._rng.choice(np.arange(n_choices), size=rem, replace=False)
                    idx = np.concatenate([idx, extra])
                self._rng.shuffle(idx)
                values = np.array([spec.choices[i] for i in idx], dtype=object)
                param_values[spec.name] = values

            else:
                raise ValueError(f"Unsupported param_type: {spec.param_type}")

        for i in range(n):
            yield {name: vals[i] for name, vals in param_values.items()}


def streaming_lhs_samples(
    parameters: list[ParameterSpec],
    *,
    seed: int,
    n_samples: int,
    batch_size: int = 128,
) -> Iterator[dict[str, Any]]:
    return iter(
        StreamingLHSGenerator(
            parameters,
            seed=seed,
            n_samples=n_samples,
            batch_size=batch_size,
        )
    )
