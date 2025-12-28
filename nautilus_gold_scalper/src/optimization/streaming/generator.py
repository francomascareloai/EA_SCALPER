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
                if spec.range is not None:
                    low, high = spec.range
                    strata = np.linspace(0.0, 1.0, n + 1)
                    u = self._rng.uniform(strata[:-1], strata[1:])

                    if spec.log_scale:
                        if low <= 0 or high <= 0:
                            raise ValueError(
                                f"Parameter {spec.name}: log_scale requires positive range, got ({low}, {high})"
                            )
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
                else:
                    # Discrete float domain (choices) - balance within batch.
                    if spec.choices is None:
                        raise ValueError(
                            f"spec.range or spec.choices is required for {spec.param_type} parameter '{spec.name}'"
                        )
                    if len(spec.choices) == 0:
                        raise ValueError(f"Parameter {spec.name}: empty float choices")

                    n_choices = len(spec.choices)
                    base = n // n_choices
                    rem = n % n_choices
                    idx = np.repeat(np.arange(n_choices), base)
                    if rem:
                        extra = self._rng.choice(np.arange(n_choices), size=rem, replace=False)
                        idx = np.concatenate([idx, extra])
                    self._rng.shuffle(idx)

                    values = np.array([float(spec.choices[i]) for i in idx], dtype=float)
                    param_values[spec.name] = values

            elif spec.param_type == "int":
                if spec.range is not None:
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
                else:
                    # Discrete int domain (choices) - balance within batch.
                    if spec.choices is None:
                        raise ValueError(
                            f"spec.range or spec.choices is required for {spec.param_type} parameter '{spec.name}'"
                        )
                    if len(spec.choices) == 0:
                        raise ValueError(f"Parameter {spec.name}: empty int choices")

                    try:
                        int_choices = [int(v) for v in spec.choices]
                    except Exception as exc:
                        raise ValueError(
                            f"Parameter {spec.name}: invalid int choices {spec.choices!r}"
                        ) from exc

                    n_choices = len(int_choices)
                    base = n // n_choices
                    rem = n % n_choices
                    idx = np.repeat(np.arange(n_choices), base)
                    if rem:
                        extra = self._rng.choice(np.arange(n_choices), size=rem, replace=False)
                        idx = np.concatenate([idx, extra])
                    self._rng.shuffle(idx)

                    values = np.array([int_choices[i] for i in idx], dtype=int)
                    param_values[spec.name] = values

            elif spec.param_type == "categorical":
                # R13-FIX: Replace assert with explicit validation
                if spec.choices is None:
                    raise ValueError(
                        f"spec.choices is required for {spec.param_type} parameter '{spec.name}'"
                    )
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


class StreamingSobolGenerator:
    """Streaming Sobol sequence generator for quasi-random sampling.

    Sobol sequences provide better space-filling than LHS with:
    - Lower discrepancy (more uniform coverage)
    - ~3.5x faster convergence than LHS for numerical integration
    - Deterministic and reproducible

    Uses scipy.stats.qmc.Sobol under the hood.

    Reference: scipy.stats.qmc.Sobol documentation
    """

    def __init__(
        self,
        parameters: list[ParameterSpec],
        *,
        seed: int,
        n_samples: int,
    ) -> None:
        if n_samples < 0:
            raise ValueError("n_samples must be >= 0")

        self._parameters = parameters
        self._seed = seed
        self._n_samples = n_samples
        self._rng = np.random.RandomState(seed)

        # Filter parameters that need Sobol sampling (continuous with range)
        self._sobol_params: list[ParameterSpec] = []
        self._discrete_params: list[ParameterSpec] = []

        for spec in parameters:
            if spec.param_type == "float" and spec.range is not None:
                self._sobol_params.append(spec)
            elif spec.param_type == "int" and spec.range is not None:
                self._sobol_params.append(spec)
            else:
                # Categorical or discrete choices: handle separately
                self._discrete_params.append(spec)

    def __iter__(self) -> Iterator[dict[str, Any]]:
        if self._n_samples == 0:
            return

        # Import here to avoid issues if scipy.stats.qmc not available
        from scipy.stats.qmc import Sobol

        n_sobol_dims = len(self._sobol_params)

        # Generate Sobol samples for continuous dimensions
        if n_sobol_dims > 0:
            sampler = Sobol(d=n_sobol_dims, scramble=True, seed=self._seed)
            # Generate samples in [0, 1]^d
            sobol_raw = sampler.random(self._n_samples)
        else:
            sobol_raw = np.empty((self._n_samples, 0))

        # Pre-generate discrete/categorical values for all samples
        discrete_values: dict[str, npt.NDArray[Any]] = {}
        for spec in self._discrete_params:
            discrete_values[spec.name] = self._generate_discrete_column(spec, self._n_samples)

        # Yield samples one by one
        for i in range(self._n_samples):
            sample: dict[str, Any] = {}

            # Map Sobol [0,1] values to parameter ranges
            for j, spec in enumerate(self._sobol_params):
                u = sobol_raw[i, j]
                sample[spec.name] = self._map_unit_to_param(u, spec)

            # Add discrete/categorical values
            for spec in self._discrete_params:
                sample[spec.name] = discrete_values[spec.name][i]

            yield sample

    def _map_unit_to_param(self, u: float, spec: ParameterSpec) -> Any:
        """Map a [0, 1] value to parameter domain."""
        if spec.range is None:
            raise ValueError(f"Parameter {spec.name} has no range")

        low, high = spec.range

        if spec.param_type == "float":
            if spec.log_scale:
                if low <= 0 or high <= 0:
                    raise ValueError(f"Parameter {spec.name}: log_scale requires positive range")
                log_low = np.log10(low)
                log_high = np.log10(high)
                value = float(np.power(10, log_low + (log_high - log_low) * u))
            else:
                value = float(low + (high - low) * u)

            if spec.step:
                steps = round((value - low) / spec.step)
                value = low + steps * spec.step
                value = max(low, min(high, value))

            return value

        elif spec.param_type == "int":
            low_i, high_i = int(low), int(high)
            step = int(spec.step) if spec.step else 1
            n_choices = (high_i - low_i) // step + 1
            idx = int(u * n_choices)
            idx = min(idx, n_choices - 1)  # Clamp to valid range
            return low_i + idx * step

        else:
            raise ValueError(f"Unsupported param_type for Sobol: {spec.param_type}")

    def _generate_discrete_column(self, spec: ParameterSpec, n: int) -> npt.NDArray[Any]:
        """Generate n values for a discrete/categorical parameter."""
        if spec.param_type == "categorical":
            if spec.choices is None:
                raise ValueError(f"Parameter {spec.name}: choices required")
            n_choices = len(spec.choices)
            if n_choices == 0:
                raise ValueError(f"Parameter {spec.name}: empty choices")

            # Balanced sampling with shuffle
            base = n // n_choices
            rem = n % n_choices
            idx = np.repeat(np.arange(n_choices), base)
            if rem:
                extra = self._rng.choice(np.arange(n_choices), size=rem, replace=False)
                idx = np.concatenate([idx, extra])
            self._rng.shuffle(idx)
            return np.array([spec.choices[i] for i in idx], dtype=object)

        elif spec.param_type in ("int", "float") and spec.choices is not None:
            # Discrete int/float with explicit choices
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

            if spec.param_type == "int":
                return np.array([int(spec.choices[i]) for i in idx], dtype=int)
            else:
                return np.array([float(spec.choices[i]) for i in idx], dtype=float)

        else:
            raise ValueError(f"Cannot generate discrete column for {spec.name}")


def streaming_sobol_samples(
    parameters: list[ParameterSpec],
    *,
    seed: int,
    n_samples: int,
) -> Iterator[dict[str, Any]]:
    """Convenience function for streaming Sobol samples."""
    return iter(
        StreamingSobolGenerator(
            parameters,
            seed=seed,
            n_samples=n_samples,
        )
    )
