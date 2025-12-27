"""
Configuration loader and validation for Apex Optimizer.

Loads YAML-based optimization specs with parameter ranges, constraints,
objective function settings, and validation configuration.
"""

from __future__ import annotations

import math
from collections.abc import Sequence
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Literal, cast

import yaml

SearchMode = Literal["grid", "random", "bayesian", "successive_halving"]

# Runtime validation constants for search modes.
# NOTE: "lhs" is accepted as a CLI-only alias and is normalized to "random" in _from_dict().
_VALID_SEARCH_MODES: frozenset[str] = frozenset(
    {"grid", "random", "bayesian", "successive_halving", "lhs"}
)
_REMOVED_SEARCH_MODES: dict[str, str] = {
    "wfo": "Removed: declared but never implemented",
    "coarse_fine": "Removed: declared but never implemented",
}
ParamType = Literal["float", "int", "categorical"]


@dataclass(frozen=True, slots=True)
class ParameterSpec:
    """Specification for a single parameter to optimize."""

    name: str  # dotpath, e.g., "confluence.min_threshold"
    param_type: ParamType
    range: tuple[float, float] | None = None  # For float/int
    step: float | None = None
    choices: list[Any] | None = None  # For categorical
    log_scale: bool = False
    description: str = ""

    def __post_init__(self) -> None:
        allowed_types: set[str] = {"float", "int", "categorical"}
        if self.param_type not in allowed_types:
            raise ValueError(f"Parameter {self.name}: invalid type {self.param_type!r}")

        if self.choices is not None and len(self.choices) == 0:
            raise ValueError(f"Parameter {self.name}: choices cannot be empty")

        # For int/float: require EITHER range OR choices (discrete set)
        if self.param_type in ("float", "int"):
            if self.range is None and self.choices is None:
                raise ValueError(
                    f"Parameter {self.name}: range or choices required for {self.param_type}"
                )

            if self.log_scale and self.param_type != "float":
                raise ValueError(
                    f"Parameter {self.name}: log_scale only supported for float, got {self.param_type}"
                )

            if self.range is not None:
                if len(self.range) != 2:
                    raise ValueError(
                        f"Parameter {self.name}: range must be a 2-tuple, got {self.range}"
                    )

                low, high = self.range
                if not (math.isfinite(low) and math.isfinite(high)):
                    raise ValueError(
                        f"Parameter {self.name}: range values must be finite, got ({low}, {high})"
                    )
                if high < low:
                    raise ValueError(f"Parameter {self.name}: invalid range ({low}, {high})")

                if self.log_scale and (low <= 0 or high <= 0):
                    raise ValueError(
                        f"Parameter {self.name}: log_scale requires positive range, got ({low}, {high})"
                    )

            if self.log_scale and self.range is None:
                raise ValueError(f"Parameter {self.name}: log_scale requires range")

            if self.step is not None:
                step = float(self.step)
                if not math.isfinite(step) or step <= 0:
                    raise ValueError(f"Parameter {self.name}: step must be > 0, got {self.step}")

        # Categorical: require choices
        if self.param_type == "categorical" and self.choices is None:
            raise ValueError(f"Parameter {self.name}: choices required for categorical")

        if self.param_type == "categorical" and self.log_scale:
            raise ValueError(f"Parameter {self.name}: log_scale not supported for categorical")


@dataclass(frozen=True, slots=True)
class EarlyStopConfig:
    """Early stopping configuration."""

    enabled: bool = True
    patience: int = 30  # Stop if no improvement in N trials
    min_delta: float = 0.01  # Minimum improvement threshold
    plateau_trials: int = 50  # Stop if top-10 unchanged


@dataclass(frozen=True, slots=True)
class SuccessiveHalvingConfig:
    """Successive Halving (multi-fidelity) configuration.

    Fidelity schedule is expressed as rolling windows ending at train_end.

    - window_days: list of rung window sizes in days.
        Use 0 to mean "full" (train_start..train_end).
    - wfa_windows: list of InlineWFA.windows per rung.
        Must match window_days length.
    - eta: reduction factor (keep top ceil(n/eta) each rung).
    """

    enabled: bool = True
    eta: int = 3
    window_days: Sequence[int] = (90, 365, 0)
    wfa_windows: Sequence[int] = (1, 3, 5)
    promotion_metric: str = "score"  # score | wfe | sqn

    def __post_init__(self) -> None:
        if self.eta < 1:
            raise ValueError(f"eta must be >= 1, got {self.eta}")
        if len(self.window_days) != len(self.wfa_windows):
            raise ValueError(
                f"window_days and wfa_windows must have same length: "
                f"{len(self.window_days)} != {len(self.wfa_windows)}"
            )
        if any(d < 0 for d in self.window_days):
            raise ValueError(f"window_days must be >= 0, got {list(self.window_days)}")
        if any(w < 1 for w in self.wfa_windows):
            raise ValueError(f"wfa_windows must be >= 1, got {list(self.wfa_windows)}")


@dataclass(frozen=True, slots=True)
class SearchConfig:
    """Search strategy configuration."""

    mode: SearchMode = "bayesian"
    trials: int = 200
    sampler: str = "tpe"  # tpe, cmaes, random
    max_grid_size: int = 1000
    n_samples: int = 200  # For random/latin hypercube
    seed: int = 42
    parallelism: int = 4
    timeout_per_trial: int = 300  # seconds
    early_stop: EarlyStopConfig = field(default_factory=EarlyStopConfig)
    successive_halving: SuccessiveHalvingConfig = field(default_factory=SuccessiveHalvingConfig)


@dataclass(frozen=True, slots=True)
class ApexConstraints:
    """Apex prop firm compliance constraints."""

    trailing_dd_max: float = 4.5  # Buffer before 5% Apex limit
    daily_dd_max: float = 3.0  # Buffer per CLAUDE.md hard blocks
    daily_profit_max: float = 29.0  # Buffer before 30% consistency rule
    overnight_positions: int = 0
    time_gate_violations: int = 0

    def __post_init__(self) -> None:
        trailing_dd_max = float(self.trailing_dd_max)
        if not (math.isfinite(trailing_dd_max) and 0 < trailing_dd_max <= 4.5):
            raise ValueError(
                f"trailing_dd_max must be in (0, 4.5] for Apex safety buffer, got {self.trailing_dd_max}"
            )

        daily_dd_max = float(self.daily_dd_max)
        if not (math.isfinite(daily_dd_max) and 0 < daily_dd_max <= 3.0):
            raise ValueError(
                f"daily_dd_max must be in (0, 3.0] per CLAUDE.md Apex DD hard blocks, got {self.daily_dd_max}"
            )

        daily_profit_max = float(self.daily_profit_max)
        if not (math.isfinite(daily_profit_max) and daily_profit_max > 0):
            raise ValueError(f"daily_profit_max must be > 0, got {self.daily_profit_max}")

        if self.overnight_positions < 0:
            raise ValueError(f"overnight_positions must be >= 0, got {self.overnight_positions}")
        if self.time_gate_violations < 0:
            raise ValueError(f"time_gate_violations must be >= 0, got {self.time_gate_violations}")


@dataclass(frozen=True, slots=True)
class ValidationConstraints:
    """Validation metric constraints."""

    wfe_min: float = 0.6
    sqn_min: float = 2.0
    psr_min: float = 0.85
    min_trades: int = 200
    min_years: int = 5


@dataclass(frozen=True, slots=True)
class AntiOverfitConstraints:
    """Anti-overfitting constraints."""

    pbo_max: float = 0.25
    mc95_dd_max: float = 4.0


@dataclass(frozen=True, slots=True)
class ConstraintsConfig:
    """All constraints configuration."""

    apex: ApexConstraints = field(default_factory=ApexConstraints)
    validation: ValidationConstraints = field(default_factory=ValidationConstraints)
    anti_overfit: AntiOverfitConstraints = field(default_factory=AntiOverfitConstraints)


@dataclass(frozen=True, slots=True)
class CompositeWeight:
    """Weight configuration for composite objective."""

    weight: float
    normalize: float = 1.0
    source: str | None = None  # For derived metrics like "positive_days_ratio"

    def __post_init__(self) -> None:
        if not math.isfinite(float(self.weight)):
            raise ValueError(f"weight must be finite, got {self.weight}")
        if not math.isfinite(float(self.normalize)) or float(self.normalize) <= 0:
            raise ValueError(f"normalize must be > 0, got {self.normalize}")


@dataclass(frozen=True, slots=True)
class PenaltyConfig:
    """Penalty configuration for objective function."""

    threshold: float = 0.0
    decay_rate: float = 0.0
    min_required: int = 0
    penalty_below: float = 1.0


@dataclass(frozen=True, slots=True)
class ObjectiveConfig:
    """Objective function configuration."""

    direction: str = "maximize"
    metric: str = "composite"  # sqn, sharpe, wfe, profit_factor, composite
    sqn_weight: CompositeWeight = field(
        default_factory=lambda: CompositeWeight(weight=0.4, normalize=5.0)
    )
    wfe_weight: CompositeWeight = field(
        default_factory=lambda: CompositeWeight(weight=0.35, normalize=1.0)
    )
    consistency_weight: CompositeWeight = field(
        default_factory=lambda: CompositeWeight(
            weight=0.25, normalize=1.0, source="positive_days_ratio"
        )
    )
    trailing_dd_penalty: PenaltyConfig = field(
        default_factory=lambda: PenaltyConfig(threshold=3.0, decay_rate=0.5)
    )
    trades_penalty: PenaltyConfig = field(
        default_factory=lambda: PenaltyConfig(min_required=200, penalty_below=0.5)
    )


@dataclass(frozen=True, slots=True)
class InlineWFAConfig:
    """Inline Walk-Forward Analysis configuration."""

    enabled: bool = True
    windows: int = 5
    is_ratio: float = 0.8  # In-sample ratio per window
    purge_days: int = 5
    embargo_days: int = 2
    early_prune_wfe: float = 0.5

    def __post_init__(self) -> None:
        if self.windows < 1:
            raise ValueError(f"windows must be >= 1, got {self.windows}")


@dataclass(frozen=True, slots=True)
class RegimeCheckConfig:
    """Regime coverage check configuration."""

    enabled: bool = False
    regimes: list[str] = field(default_factory=lambda: ["trend", "range", "volatile"])
    min_coverage: float = 0.7
    classifier: str = "volatility"


@dataclass(frozen=True, slots=True)
class ValidationConfig:
    """Validation layer configuration."""

    inline_wfa: InlineWFAConfig = field(default_factory=InlineWFAConfig)
    regime_check: RegimeCheckConfig = field(default_factory=RegimeCheckConfig)


@dataclass(frozen=True, slots=True)
class MonteCarloConfig:
    """Monte Carlo stress test configuration."""

    enabled: bool = True
    simulations: int = 5000
    block_bootstrap: bool = True
    block_size: str = "auto"  # "auto" = n^(1/3)
    confidence_levels: list[float] = field(default_factory=lambda: [0.95, 0.99])


@dataclass(frozen=True, slots=True)
class DegradationConfig:
    """Degradation stress test configuration."""

    enabled: bool = True
    rates: list[float] = field(default_factory=lambda: [0.10, 0.20, 0.30])
    must_survive: float = 0.20


@dataclass(frozen=True, slots=True)
class GhostTestConfig:
    """Ghost test configuration (signal vs baseline falsification).

    Fast disproof test: compare system metrics vs a null baseline generated from
    the same trade series.

    NOTE: This does not replace a true "random signal" backtest baseline, but it
    is a useful first gate to catch placebo edges cheaply.
    """

    enabled: bool = False
    sims: int = 200
    seed_offset: int = 0
    sharpe_delta_min: float = 0.5
    p_value_max: float = 0.05


@dataclass(frozen=True, slots=True)
class OverfittingDetectionConfig:
    """Overfitting detection configuration."""

    cliff_check: bool = True
    island_check: bool = True
    regime_bias_check: bool = True


@dataclass(frozen=True, slots=True)
class StressTestConfig:
    """Stress testing layer configuration."""

    enabled: bool = True
    top_n: int = 5
    monte_carlo: MonteCarloConfig = field(default_factory=MonteCarloConfig)
    degradation: DegradationConfig = field(default_factory=DegradationConfig)
    ghost_test: GhostTestConfig = field(default_factory=GhostTestConfig)
    overfitting_detection: OverfittingDetectionConfig = field(
        default_factory=OverfittingDetectionConfig
    )


@dataclass(frozen=True, slots=True)
class DataConfig:
    """Data configuration."""

    path: str = ""
    train_start: str = "2010-01-01"
    train_end: str = "2022-12-31"
    test_start: str = "2023-01-01"
    test_end: str = "2024-12-31"


@dataclass(frozen=True, slots=True)
class OutputConfig:
    """Output configuration."""

    dir: str = "logs/optimization"
    session_subfolder: bool = True
    reports: list[str] = field(default_factory=lambda: ["json", "csv"])
    checkpoint_enabled: bool = True
    checkpoint_interval: int = 10
    handoff_enabled: bool = True

    # Memory / persistence controls
    results_parquet: str | None = None
    results_flush_every: int = 50
    max_results_in_ram: int | None = 500


@dataclass(slots=True)
class OptimizationConfig:
    """Complete optimization configuration."""

    name: str = "Unnamed Optimization"
    version: str = "1.0"
    description: str = ""

    search: SearchConfig = field(default_factory=SearchConfig)
    parameters: list[ParameterSpec] = field(default_factory=list)
    fixed: dict[str, Any] = field(default_factory=dict)
    constraints: ConstraintsConfig = field(default_factory=ConstraintsConfig)
    objective: ObjectiveConfig = field(default_factory=ObjectiveConfig)
    validation: ValidationConfig = field(default_factory=ValidationConfig)
    stress_test: StressTestConfig = field(default_factory=StressTestConfig)
    data: DataConfig = field(default_factory=DataConfig)
    output: OutputConfig = field(default_factory=OutputConfig)

    @classmethod
    def from_yaml(cls, path: str | Path) -> OptimizationConfig:
        """Load configuration from YAML file."""
        path = Path(path)
        if not path.exists():
            raise FileNotFoundError(f"Config file not found: {path}")

        with open(path, encoding="utf-8") as f:
            raw = yaml.safe_load(f)

        return cls._from_dict(raw)

    @classmethod
    def _from_dict(cls, raw: Any) -> OptimizationConfig:
        """Parse raw YAML object into typed config."""
        if raw is None:
            raise ValueError("Optimization YAML is empty")
        if not isinstance(raw, dict):
            raise ValueError(f"Optimization YAML root must be a mapping, got {type(raw).__name__}")

        def _require_mapping(section_name: str) -> dict[str, Any]:
            v = raw.get(section_name)
            if v is None:
                return {}
            if not isinstance(v, dict):
                raise ValueError(
                    f"Optimization YAML section '{section_name}' must be a mapping, got {type(v).__name__}"
                )
            return cast(dict[str, Any], v)

        metadata = _require_mapping("metadata")
        search_raw = _require_mapping("search")
        params_raw = _require_mapping("parameters")
        fixed = _require_mapping("fixed")
        constraints_raw = _require_mapping("constraints")
        objective_raw = _require_mapping("objective")
        validation_raw = _require_mapping("validation")
        stress_raw = _require_mapping("stress_test")
        data_raw = _require_mapping("data")
        output_raw = _require_mapping("output")

        # Parse parameters
        parameters: list[ParameterSpec] = []
        for name, spec in params_raw.items():
            if not isinstance(spec, dict):
                continue

            param_type = spec.get("type", "float")
            range_val = spec.get("range")

            range_tuple: tuple[float, float] | None = None
            if range_val is not None:
                if not isinstance(range_val, Sequence) or len(range_val) != 2:
                    raise ValueError(f"Parameter {name}: range must be a 2-item sequence")
                range_tuple = (float(range_val[0]), float(range_val[1]))

            step_raw = spec.get("step")
            step_val: float | None = None
            if step_raw is not None:
                try:
                    step_val = float(step_raw)
                except Exception as exc:
                    raise ValueError(
                        f"Parameter {name}: step must be numeric (or null), got {step_raw!r}"
                    ) from exc

            parameters.append(
                ParameterSpec(
                    name=name,
                    param_type=param_type,
                    range=range_tuple,
                    step=step_val,
                    choices=spec.get("choices"),
                    log_scale=spec.get("log_scale", False),
                    description=spec.get("description", ""),
                )
            )

        # Parse early stop
        early_stop_raw = search_raw.get("early_stop", {})
        early_stop = EarlyStopConfig(
            enabled=early_stop_raw.get("enabled", True),
            patience=early_stop_raw.get("patience", 30),
            min_delta=early_stop_raw.get("min_delta", 0.01),
            plateau_trials=early_stop_raw.get("plateau_trials", 50),
        )

        # Parse successive halving
        sh_raw = search_raw.get("successive_halving", {})
        successive_halving = SuccessiveHalvingConfig(
            enabled=sh_raw.get("enabled", True),
            eta=sh_raw.get("eta", 3),
            window_days=tuple(sh_raw.get("window_days", (90, 365, 0))),
            wfa_windows=tuple(sh_raw.get("wfa_windows", (1, 3, 5))),
            promotion_metric=sh_raw.get("promotion_metric", "score"),
        )

        # Parse and validate search mode
        raw_mode = search_raw.get("mode", "bayesian")
        if raw_mode in _REMOVED_SEARCH_MODES:
            raise ValueError(
                f"search.mode='{raw_mode}' is not supported. "
                f"{_REMOVED_SEARCH_MODES[raw_mode]}. "
                f"Valid modes: {sorted(_VALID_SEARCH_MODES)}"
            )
        if raw_mode not in _VALID_SEARCH_MODES:
            raise ValueError(
                f"search.mode='{raw_mode}' is not valid. Valid modes: {sorted(_VALID_SEARCH_MODES)}"
            )
        # Treat 'lhs' as CLI-only alias for 'random' (both use LHS sampling).
        if raw_mode == "lhs":
            validated_mode: SearchMode = "random"
        else:
            validated_mode = cast(SearchMode, raw_mode)

        # Parse search config
        trials_raw = search_raw.get("trials", 200)
        n_samples_raw = search_raw.get("n_samples", 200)
        seed_raw = search_raw.get("seed", 42)
        parallelism_raw = search_raw.get("parallelism", 4)
        timeout_raw = search_raw.get("timeout_per_trial", 300)
        max_grid_size_raw = search_raw.get("max_grid_size", 1000)

        if seed_raw is None:
            raise ValueError("search.seed cannot be null")
        if isinstance(seed_raw, bool):
            raise ValueError(f"search.seed must be an int, got bool {seed_raw!r}")
        try:
            seed = int(seed_raw)
        except Exception as exc:
            raise ValueError(f"search.seed must be an int, got {seed_raw!r}") from exc

        try:
            trials = int(trials_raw)
        except Exception as exc:
            raise ValueError(f"search.trials must be an int, got {trials_raw!r}") from exc
        if trials < 1:
            raise ValueError(f"search.trials must be >= 1, got {trials}")

        try:
            n_samples = int(n_samples_raw)
        except Exception as exc:
            raise ValueError(f"search.n_samples must be an int, got {n_samples_raw!r}") from exc
        if n_samples < 1:
            raise ValueError(f"search.n_samples must be >= 1, got {n_samples}")

        try:
            parallelism = int(parallelism_raw)
        except Exception as exc:
            raise ValueError(f"search.parallelism must be an int, got {parallelism_raw!r}") from exc
        if parallelism < 1:
            raise ValueError(f"search.parallelism must be >= 1, got {parallelism}")

        try:
            timeout_per_trial = int(timeout_raw)
        except Exception as exc:
            raise ValueError(
                f"search.timeout_per_trial must be an int, got {timeout_raw!r}"
            ) from exc
        if timeout_per_trial < 1:
            raise ValueError(f"search.timeout_per_trial must be >= 1, got {timeout_per_trial}")

        try:
            max_grid_size = int(max_grid_size_raw)
        except Exception as exc:
            raise ValueError(
                f"search.max_grid_size must be an int, got {max_grid_size_raw!r}"
            ) from exc
        if max_grid_size < 1:
            raise ValueError(f"search.max_grid_size must be >= 1, got {max_grid_size}")

        search = SearchConfig(
            mode=validated_mode,
            trials=trials,
            sampler=search_raw.get("sampler", "tpe"),
            max_grid_size=max_grid_size,
            n_samples=n_samples,
            seed=seed,
            parallelism=parallelism,
            timeout_per_trial=timeout_per_trial,
            early_stop=early_stop,
            successive_halving=successive_halving,
        )

        # Parse constraints
        apex_raw = constraints_raw.get("apex", {})
        validation_constr_raw = constraints_raw.get("validation", {})
        anti_overfit_raw = constraints_raw.get("anti_overfit", {})

        constraints = ConstraintsConfig(
            apex=ApexConstraints(
                trailing_dd_max=apex_raw.get("trailing_dd_max", 4.5),
                daily_dd_max=apex_raw.get("daily_dd_max", 3.0),
                daily_profit_max=apex_raw.get("daily_profit_max", 29.0),
                overnight_positions=apex_raw.get("overnight_positions", 0),
                time_gate_violations=apex_raw.get("time_gate_violations", 0),
            ),
            validation=ValidationConstraints(
                wfe_min=validation_constr_raw.get("wfe_min", 0.6),
                sqn_min=validation_constr_raw.get("sqn_min", 2.0),
                psr_min=validation_constr_raw.get("psr_min", 0.85),
                min_trades=validation_constr_raw.get("min_trades", 200),
                min_years=validation_constr_raw.get("min_years", 5),
            ),
            anti_overfit=AntiOverfitConstraints(
                pbo_max=anti_overfit_raw.get("pbo_max", 0.25),
                mc95_dd_max=anti_overfit_raw.get("mc95_dd_max", 4.0),
            ),
        )

        # Parse objective
        composite_raw = objective_raw.get("composite", {})
        if composite_raw is None:
            composite_raw = {}
        if not isinstance(composite_raw, dict):
            raise ValueError(
                f"objective.composite must be a mapping, got {type(composite_raw).__name__}"
            )

        penalties_raw = objective_raw.get("penalties", {})
        if penalties_raw is None:
            penalties_raw = {}
        if not isinstance(penalties_raw, dict):
            raise ValueError(
                f"objective.penalties must be a mapping, got {type(penalties_raw).__name__}"
            )

        dd_penalty_raw = penalties_raw.get("trailing_dd", {})
        trades_penalty_raw = penalties_raw.get("trades", {})

        sqn_raw = composite_raw.get("sqn", {})
        wfe_raw = composite_raw.get("wfe", {})

        cons_raw: dict[str, Any]
        raw_consistency = composite_raw.get("consistency")
        # Backward-compatible aliases seen in existing grid configs.
        if raw_consistency is None:
            raw_consistency = composite_raw.get("positive_days")
        if raw_consistency is None:
            raw_consistency = composite_raw.get("win_rate")

        if raw_consistency is None:
            cons_raw = {}
        elif not isinstance(raw_consistency, dict):
            raise ValueError(
                f"objective.composite.consistency must be a mapping, got {type(raw_consistency).__name__}"
            )
        else:
            cons_raw = raw_consistency

        objective = ObjectiveConfig(
            direction=objective_raw.get("direction", "maximize"),
            metric=objective_raw.get("metric", "composite"),
            sqn_weight=CompositeWeight(
                weight=sqn_raw.get("weight", 0.4),
                normalize=sqn_raw.get("normalize", 5.0),
            ),
            wfe_weight=CompositeWeight(
                weight=wfe_raw.get("weight", 0.35),
                normalize=wfe_raw.get("normalize", 1.0),
            ),
            consistency_weight=CompositeWeight(
                weight=cons_raw.get("weight", 0.25),
                normalize=cons_raw.get("normalize", 1.0),
                source=cons_raw.get("source", "positive_days_ratio"),
            ),
            trailing_dd_penalty=PenaltyConfig(
                threshold=dd_penalty_raw.get("threshold", 3.0),
                decay_rate=dd_penalty_raw.get("decay_rate", 0.5),
            ),
            trades_penalty=PenaltyConfig(
                min_required=trades_penalty_raw.get("min_required", 200),
                penalty_below=trades_penalty_raw.get("penalty_below", 0.5),
            ),
        )

        # Parse inline WFA
        inline_wfa_raw = validation_raw.get("inline_wfa", {})
        if inline_wfa_raw is None:
            inline_wfa_raw = {}
        if not isinstance(inline_wfa_raw, dict):
            raise ValueError(
                f"validation.inline_wfa must be a mapping, got {type(inline_wfa_raw).__name__}"
            )

        regime_check_raw = validation_raw.get("regime_check", {})
        if regime_check_raw is None:
            regime_check_raw = {}
        if not isinstance(regime_check_raw, dict):
            raise ValueError(
                f"validation.regime_check must be a mapping, got {type(regime_check_raw).__name__}"
            )

        validation_config = ValidationConfig(
            inline_wfa=InlineWFAConfig(
                enabled=inline_wfa_raw.get("enabled", True),
                windows=inline_wfa_raw.get("windows", 5),
                is_ratio=inline_wfa_raw.get("is_ratio", 0.8),
                purge_days=inline_wfa_raw.get("purge_days", 5),
                embargo_days=inline_wfa_raw.get("embargo_days", 2),
                early_prune_wfe=inline_wfa_raw.get("early_prune_wfe", 0.5),
            ),
            regime_check=RegimeCheckConfig(
                enabled=regime_check_raw.get("enabled", False),
                regimes=regime_check_raw.get("regimes", ["trend", "range", "volatile"]),
                min_coverage=regime_check_raw.get("min_coverage", 0.7),
                classifier=regime_check_raw.get("classifier", "volatility"),
            ),
        )

        # Parse stress test
        mc_raw = stress_raw.get("monte_carlo", {})
        if mc_raw is None:
            mc_raw = {}
        if not isinstance(mc_raw, dict):
            raise ValueError(
                f"stress_test.monte_carlo must be a mapping, got {type(mc_raw).__name__}"
            )

        deg_raw = stress_raw.get("degradation", {})
        if deg_raw is None:
            deg_raw = {}
        if not isinstance(deg_raw, dict):
            raise ValueError(
                f"stress_test.degradation must be a mapping, got {type(deg_raw).__name__}"
            )

        ghost_raw = stress_raw.get("ghost_test", {})
        if ghost_raw is None:
            ghost_raw = {}
        if not isinstance(ghost_raw, dict):
            raise ValueError(
                f"stress_test.ghost_test must be a mapping, got {type(ghost_raw).__name__}"
            )

        overfit_raw = stress_raw.get("overfitting_detection", {})
        if overfit_raw is None:
            overfit_raw = {}
        if not isinstance(overfit_raw, dict):
            raise ValueError(
                f"stress_test.overfitting_detection must be a mapping, got {type(overfit_raw).__name__}"
            )

        stress_test = StressTestConfig(
            enabled=stress_raw.get("enabled", True),
            top_n=stress_raw.get("top_n", 5),
            monte_carlo=MonteCarloConfig(
                enabled=mc_raw.get("enabled", True),
                simulations=mc_raw.get("simulations", 5000),
                block_bootstrap=mc_raw.get("block_bootstrap", True),
                block_size=mc_raw.get("block_size", "auto"),
                confidence_levels=mc_raw.get("confidence_levels", [0.95, 0.99]),
            ),
            degradation=DegradationConfig(
                enabled=deg_raw.get("enabled", True),
                rates=deg_raw.get("rates", [0.10, 0.20, 0.30]),
                must_survive=deg_raw.get("must_survive", 0.20),
            ),
            ghost_test=GhostTestConfig(
                enabled=ghost_raw.get("enabled", False),
                sims=ghost_raw.get("sims", 200),
                seed_offset=ghost_raw.get("seed_offset", 0),
                sharpe_delta_min=ghost_raw.get("sharpe_delta_min", 0.5),
                p_value_max=ghost_raw.get("p_value_max", 0.05),
            ),
            overfitting_detection=OverfittingDetectionConfig(
                cliff_check=overfit_raw.get("cliff_check", True),
                island_check=overfit_raw.get("island_check", True),
                regime_bias_check=overfit_raw.get("regime_bias_check", True),
            ),
        )

        # Parse data config
        train_range = data_raw.get("train_range", {})
        if train_range is None:
            train_range = {}
        if not isinstance(train_range, dict):
            raise ValueError(
                f"data.train_range must be a mapping, got {type(train_range).__name__}"
            )

        test_range = data_raw.get("test_range", {})
        if test_range is None:
            test_range = {}
        if not isinstance(test_range, dict):
            raise ValueError(f"data.test_range must be a mapping, got {type(test_range).__name__}")

        data_config = DataConfig(
            path=data_raw.get("path", ""),
            train_start=train_range.get("start", "2010-01-01"),
            train_end=train_range.get("end", "2022-12-31"),
            test_start=test_range.get("start", "2023-01-01"),
            test_end=test_range.get("end", "2024-12-31"),
        )

        # Parse output config
        checkpoint_raw = output_raw.get("checkpointing", {})
        if checkpoint_raw is None:
            checkpoint_raw = {}
        if not isinstance(checkpoint_raw, dict):
            raise ValueError(
                f"output.checkpointing must be a mapping, got {type(checkpoint_raw).__name__}"
            )

        streaming_raw = output_raw.get("streaming", {})
        if streaming_raw is None:
            streaming_raw = {}
        if not isinstance(streaming_raw, dict):
            raise ValueError(
                f"output.streaming must be a mapping, got {type(streaming_raw).__name__}"
            )

        output_config = OutputConfig(
            dir=output_raw.get("dir", "logs/optimization"),
            session_subfolder=output_raw.get("session_subfolder", True),
            reports=output_raw.get("reports", ["json", "csv"]),
            checkpoint_enabled=checkpoint_raw.get("enabled", True),
            checkpoint_interval=checkpoint_raw.get("interval", 10),
            handoff_enabled=output_raw.get("handoff", {}).get("enabled", True),
            results_parquet=streaming_raw.get("results_parquet"),
            results_flush_every=streaming_raw.get("flush_every", 50),
            max_results_in_ram=streaming_raw.get("max_results_in_ram", 500),
        )

        return cls(
            name=metadata.get("name", "Unnamed Optimization"),
            version=metadata.get("version", "1.0"),
            description=metadata.get("description", ""),
            search=search,
            parameters=parameters,
            fixed=fixed,
            constraints=constraints,
            objective=objective,
            validation=validation_config,
            stress_test=stress_test,
            data=data_config,
            output=output_config,
        )

    def get_param_ranges(self) -> dict[str, tuple[float, float]]:
        """Get parameter name to range mapping for overfitting detection."""
        return {p.name: p.range for p in self.parameters if p.range is not None}
