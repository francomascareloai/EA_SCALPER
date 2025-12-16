"""
Validation Core Module.

Provides:
- ValidationConfig: Configuration dataclass with thresholds and settings
- Sub-configuration classes for memory, data quality, price, backtest, apex, sessions
- ValidationStatus: Enum for check outcomes
- CheckResult, PhaseResult, PipelineResult: Result dataclasses
- ValidationEngine: Main orchestrator with DuckDB + Polars
- DuckDBConnection: Managed database connection with memory limits
- PhaseValidator: Abstract base class for validation phases
"""

from nautilus_gold_scalper.src.validation.core.config import (
    ApexConfig,
    BacktestThresholdConfig,
    DataQualityConfig,
    MemoryConfig,
    PriceValidationConfig,
    SessionConfig,
    ValidationConfig,
)
from nautilus_gold_scalper.src.validation.core.engine import (
    CatalogStats,
    DuckDBConnection,
    PhaseValidator,
    ValidationEngine,
)
from nautilus_gold_scalper.src.validation.core.results import (
    CheckResult,
    PhaseResult,
    PipelineResult,
    ValidationResult,
    ValidationStatus,
    load_pipeline_result,
)

__all__ = [
    # Config
    "ApexConfig",
    "BacktestThresholdConfig",
    "DataQualityConfig",
    "MemoryConfig",
    "PriceValidationConfig",
    "SessionConfig",
    "ValidationConfig",
    # Engine
    "CatalogStats",
    "DuckDBConnection",
    "PhaseValidator",
    "ValidationEngine",
    # Results
    "CheckResult",
    "PhaseResult",
    "PipelineResult",
    "ValidationResult",
    "ValidationStatus",
    "load_pipeline_result",
]
