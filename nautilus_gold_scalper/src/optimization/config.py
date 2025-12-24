"""
Configuration loader and validation for Apex Optimizer.

Loads YAML-based optimization specs with parameter ranges, constraints,
objective function settings, and validation configuration.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Literal

import yaml


SearchMode = Literal["grid", "random", "bayesian", "wfo", "coarse_fine"]
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
        if self.param_type in ("float", "int") and self.range is None:
            raise ValueError(f"Parameter {self.name}: range required for {self.param_type}")
        if self.param_type == "categorical" and not self.choices:
            raise ValueError(f"Parameter {self.name}: choices required for categorical")


@dataclass(frozen=True, slots=True)
class EarlyStopConfig:
    """Early stopping configuration."""

    enabled: bool = True
    patience: int = 30  # Stop if no improvement in N trials
    min_delta: float = 0.01  # Minimum improvement threshold
    plateau_trials: int = 50  # Stop if top-10 unchanged


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


@dataclass(frozen=True, slots=True)
class ApexConstraints:
    """Apex prop firm compliance constraints."""

    trailing_dd_max: float = 4.5  # Buffer before 5% limit
    daily_profit_max: float = 29.0  # Buffer before 30% consistency rule
    overnight_positions: int = 0
    time_gate_violations: int = 0


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
    overfitting_detection: OverfittingDetectionConfig = field(
        default_factory=OverfittingDetectionConfig
    )


@dataclass(frozen=True, slots=True)
class DataConfig:
    """Data configuration."""

    path: str = "data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet"
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
    def from_yaml(cls, path: str | Path) -> "OptimizationConfig":
        """Load configuration from YAML file."""
        path = Path(path)
        if not path.exists():
            raise FileNotFoundError(f"Config file not found: {path}")

        with open(path, encoding="utf-8") as f:
            raw = yaml.safe_load(f) or {}

        return cls._from_dict(raw)

    @classmethod
    def _from_dict(cls, raw: dict[str, Any]) -> "OptimizationConfig":
        """Parse raw dict into typed config."""
        metadata = raw.get("metadata", {})
        search_raw = raw.get("search", {})
        params_raw = raw.get("parameters", {})
        fixed = raw.get("fixed", {})
        constraints_raw = raw.get("constraints", {})
        objective_raw = raw.get("objective", {})
        validation_raw = raw.get("validation", {})
        stress_raw = raw.get("stress_test", {})
        data_raw = raw.get("data", {})
        output_raw = raw.get("output", {})

        # Parse parameters
        parameters: list[ParameterSpec] = []
        for name, spec in params_raw.items():
            if not isinstance(spec, dict):
                continue
            param_type = spec.get("type", "float")
            range_val = spec.get("range")
            parameters.append(
                ParameterSpec(
                    name=name,
                    param_type=param_type,
                    range=tuple(range_val) if range_val else None,
                    step=spec.get("step"),
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

        # Parse search config
        search = SearchConfig(
            mode=search_raw.get("mode", "bayesian"),
            trials=search_raw.get("trials", 200),
            sampler=search_raw.get("sampler", "tpe"),
            max_grid_size=search_raw.get("max_grid_size", 1000),
            n_samples=search_raw.get("n_samples", 200),
            seed=search_raw.get("seed", 42),
            parallelism=search_raw.get("parallelism", 4),
            timeout_per_trial=search_raw.get("timeout_per_trial", 300),
            early_stop=early_stop,
        )

        # Parse constraints
        apex_raw = constraints_raw.get("apex", {})
        validation_constr_raw = constraints_raw.get("validation", {})
        anti_overfit_raw = constraints_raw.get("anti_overfit", {})

        constraints = ConstraintsConfig(
            apex=ApexConstraints(
                trailing_dd_max=apex_raw.get("trailing_dd_max", 4.5),
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
        penalties_raw = objective_raw.get("penalties", {})
        dd_penalty_raw = penalties_raw.get("trailing_dd", {})
        trades_penalty_raw = penalties_raw.get("trades", {})

        sqn_raw = composite_raw.get("sqn", {})
        wfe_raw = composite_raw.get("wfe", {})
        cons_raw = composite_raw.get("consistency", {})

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
        regime_check_raw = validation_raw.get("regime_check", {})

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
        deg_raw = stress_raw.get("degradation", {})
        overfit_raw = stress_raw.get("overfitting_detection", {})

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
            overfitting_detection=OverfittingDetectionConfig(
                cliff_check=overfit_raw.get("cliff_check", True),
                island_check=overfit_raw.get("island_check", True),
                regime_bias_check=overfit_raw.get("regime_bias_check", True),
            ),
        )

        # Parse data config
        train_range = data_raw.get("train_range", {})
        test_range = data_raw.get("test_range", {})

        data_config = DataConfig(
            path=data_raw.get("path", "data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet"),
            train_start=train_range.get("start", "2010-01-01"),
            train_end=train_range.get("end", "2022-12-31"),
            test_start=test_range.get("start", "2023-01-01"),
            test_end=test_range.get("end", "2024-12-31"),
        )

        # Parse output config
        checkpoint_raw = output_raw.get("checkpointing", {})

        output_config = OutputConfig(
            dir=output_raw.get("dir", "logs/optimization"),
            session_subfolder=output_raw.get("session_subfolder", True),
            reports=output_raw.get("reports", ["json", "csv"]),
            checkpoint_enabled=checkpoint_raw.get("enabled", True),
            checkpoint_interval=checkpoint_raw.get("interval", 10),
            handoff_enabled=output_raw.get("handoff", {}).get("enabled", True),
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
        return {
            p.name: p.range
            for p in self.parameters
            if p.range is not None
        }
