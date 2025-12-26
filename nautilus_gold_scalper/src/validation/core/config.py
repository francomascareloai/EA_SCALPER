"""
Validation Configuration Module.

Provides dataclass-based configuration for the validation pipeline with:
- Memory constraints (12GB RAM system, 6GB for validation)
- Data quality thresholds
- Price validation ranges
- Backtest thresholds (from CLAUDE.md and ARGUS research)
- Apex compliance limits
- Session definitions

All thresholds are derived from:
- Apex Trader Funding rules (5% trailing DD, 30% consistency, time gates)
- ARGUS research on statistical validation (SQN, PSR, PBO, Monte Carlo)
- CLAUDE.md approval gate specifications
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import yaml


@dataclass(frozen=True, slots=True)
class MemoryConfig:
    """
    Memory management configuration.

    Designed for 12GB RAM systems, leaving 6GB for OS and other processes.
    Enables spill-to-disk for large datasets via DuckDB.

    Attributes:
        max_memory_gb: Maximum memory for validation pipeline (default: 6.0GB).
        chunk_size_ticks: Number of ticks per processing chunk (default: 5M).
        enable_spill_to_disk: Enable DuckDB disk spilling for large queries.
    """

    max_memory_gb: float = 6.0
    chunk_size_ticks: int = 5_000_000
    enable_spill_to_disk: bool = True

    def __post_init__(self) -> None:
        """Validate memory configuration."""
        if self.max_memory_gb <= 0:
            raise ValueError(f"max_memory_gb must be positive, got {self.max_memory_gb}")
        if self.max_memory_gb > 12.0:
            raise ValueError(f"max_memory_gb exceeds system limit (12GB), got {self.max_memory_gb}")
        if self.chunk_size_ticks <= 0:
            raise ValueError(f"chunk_size_ticks must be positive, got {self.chunk_size_ticks}")


@dataclass(frozen=True, slots=True)
class DataQualityConfig:
    """
    Data quality threshold configuration.

    Thresholds for validating data completeness and quality.

    Attributes:
        min_coverage_months: Minimum months of data required (36 = 3 years).
        min_clean_data_pct: Minimum percentage of clean data (99.0%).
        max_critical_gaps: Maximum allowed critical gaps (0 for strict).
        min_quality_score: Minimum overall quality score (0-100 scale).
    """

    min_coverage_months: int = 36
    min_clean_data_pct: float = 99.0
    max_critical_gaps: int = 0
    min_quality_score: float = 70.0

    def __post_init__(self) -> None:
        """Validate data quality thresholds."""
        if not 1 <= self.min_coverage_months <= 360:
            raise ValueError(f"min_coverage_months must be 1-360, got {self.min_coverage_months}")
        if not 0.0 <= self.min_clean_data_pct <= 100.0:
            raise ValueError(f"min_clean_data_pct must be 0-100, got {self.min_clean_data_pct}")
        if self.max_critical_gaps < 0:
            raise ValueError(
                f"max_critical_gaps must be non-negative, got {self.max_critical_gaps}"
            )
        if not 0.0 <= self.min_quality_score <= 100.0:
            raise ValueError(f"min_quality_score must be 0-100, got {self.min_quality_score}")


@dataclass(frozen=True, slots=True)
class PriceValidationConfig:
    """
    Price validation thresholds for XAUUSD.

    Historical gold price ranges from ~$300 (2003) to ~$3500 (2025 projections).
    Spread limits based on normal market conditions.

    Attributes:
        price_range_min: Minimum valid gold price (2003 levels).
        price_range_max: Maximum valid gold price (2025 projected peak).
        max_spread_cents: Maximum single-tick spread in cents (extreme condition).
        max_avg_spread_cents: Maximum average spread in cents (normal condition).
    """

    price_range_min: float = 300.0
    price_range_max: float = 3500.0
    max_spread_cents: float = 100.0
    max_avg_spread_cents: float = 30.0

    def __post_init__(self) -> None:
        """Validate price thresholds."""
        if self.price_range_min <= 0:
            raise ValueError(f"price_range_min must be positive, got {self.price_range_min}")
        if self.price_range_max <= self.price_range_min:
            raise ValueError(
                f"price_range_max ({self.price_range_max}) must exceed "
                f"price_range_min ({self.price_range_min})"
            )
        if self.max_spread_cents <= 0:
            raise ValueError(f"max_spread_cents must be positive, got {self.max_spread_cents}")
        if self.max_avg_spread_cents <= 0:
            raise ValueError(
                f"max_avg_spread_cents must be positive, got {self.max_avg_spread_cents}"
            )


@dataclass(frozen=True, slots=True)
class BacktestThresholdConfig:
    """
    Backtest validation thresholds from ARGUS research.

    Conservative thresholds ensuring statistical robustness:
    - WFE >= 0.60: Walk-forward efficiency (out-of-sample vs in-sample)
    - SQN >= 2.0: System Quality Number (expectancy/std)
    - SQN <= 5.0: Upper bound (too good may indicate overfitting)
    - PSR >= 0.85: Probabilistic Sharpe Ratio (fat-tail adjusted)
    - DSR > 0: Deflated Sharpe Ratio (multiple testing penalty)
    - PBO < 0.25: Probability of Backtest Overfitting
    - MC 95th DD < 4%: Monte Carlo drawdown at 95th percentile

    Attributes:
        min_wfe: Minimum walk-forward efficiency ratio.
        min_sqn: Minimum System Quality Number.
        max_sqn: Maximum SQN (suspicion flag for overfitting).
        min_psr: Minimum Probabilistic Sharpe Ratio.
        max_pbo: Maximum Probability of Backtest Overfitting.
        max_mc_dd_95: Maximum Monte Carlo 95th percentile drawdown.
        min_trades: Minimum trade count for statistical significance.
        min_dsr: Minimum Deflated Sharpe Ratio (must be positive).
    """

    min_wfe: float = 0.60
    min_sqn: float = 2.0
    max_sqn: float = 5.0
    min_psr: float = 0.85
    max_pbo: float = 0.25
    max_mc_dd_95: float = 0.04
    min_trades: int = 200
    min_dsr: float = 0.0

    def __post_init__(self) -> None:
        """Validate backtest thresholds."""
        if not 0.0 <= self.min_wfe <= 1.0:
            raise ValueError(f"min_wfe must be 0-1, got {self.min_wfe}")
        if self.min_sqn <= 0:
            raise ValueError(f"min_sqn must be positive, got {self.min_sqn}")
        if self.max_sqn <= self.min_sqn:
            raise ValueError(f"max_sqn ({self.max_sqn}) must exceed min_sqn ({self.min_sqn})")
        if not 0.0 <= self.min_psr <= 1.0:
            raise ValueError(f"min_psr must be 0-1, got {self.min_psr}")
        if not 0.0 <= self.max_pbo <= 1.0:
            raise ValueError(f"max_pbo must be 0-1, got {self.max_pbo}")
        if not 0.0 < self.max_mc_dd_95 < 1.0:
            raise ValueError(f"max_mc_dd_95 must be 0-1 (exclusive), got {self.max_mc_dd_95}")
        if self.min_trades < 30:
            raise ValueError(
                f"min_trades must be at least 30 for significance, got {self.min_trades}"
            )


@dataclass(frozen=True, slots=True)
class ApexConfig:
    """
    Apex Trader Funding compliance thresholds.

    Critical limits with safety buffers:
    - Trailing DD: 4% buffer (Apex limit: 5%)
    - Total DD: 4.5% buffer (Apex limit: 5%)
    - Daily profit: 30% max (consistency rule)

    Time gates (all in ET):
    - 16:30: Block new trades
    - 16:55: Force close warning
    - 16:59: Emergency close deadline

    Attributes:
        max_trailing_dd: Maximum trailing drawdown from HWM (includes unrealized).
        max_total_dd: Maximum total drawdown limit.
        max_daily_profit: Maximum daily profit percentage (consistency rule).
        trade_block_hour_et: Hour (ET) to block new trades.
        trade_block_minute_et: Minute (ET) to block new trades.
        force_close_hour_et: Hour (ET) for force close.
        force_close_minute_et: Minute (ET) for force close.
        deadline_hour_et: Final deadline hour (ET).
        deadline_minute_et: Final deadline minute (ET).
    """

    max_trailing_dd: float = 0.04
    max_total_dd: float = 0.045
    max_daily_profit: float = 0.30
    trade_block_hour_et: int = 16
    trade_block_minute_et: int = 30
    force_close_hour_et: int = 16
    force_close_minute_et: int = 55
    deadline_hour_et: int = 16
    deadline_minute_et: int = 59

    def __post_init__(self) -> None:
        """Validate Apex thresholds."""
        if not 0.0 < self.max_trailing_dd <= 0.05:
            raise ValueError(
                f"max_trailing_dd must be 0-5% (Apex limit), got {self.max_trailing_dd}"
            )
        if not 0.0 < self.max_total_dd <= 0.05:
            raise ValueError(f"max_total_dd must be 0-5% (Apex limit), got {self.max_total_dd}")
        if not 0.0 < self.max_daily_profit <= 1.0:
            raise ValueError(f"max_daily_profit must be 0-100%, got {self.max_daily_profit}")
        if not 0 <= self.trade_block_hour_et <= 23:
            raise ValueError(f"trade_block_hour_et must be 0-23, got {self.trade_block_hour_et}")
        if not 0 <= self.trade_block_minute_et <= 59:
            raise ValueError(
                f"trade_block_minute_et must be 0-59, got {self.trade_block_minute_et}"
            )


@dataclass(frozen=True, slots=True)
class SessionConfig:
    """
    Trading session window configuration.

    Sessions define analysis windows with UTC hour ranges.
    Default sessions cover major gold trading periods:
    - Sydney: 21:00-06:00 UTC
    - Tokyo: 00:00-09:00 UTC
    - London: 08:00-17:00 UTC
    - New York: 13:00-22:00 UTC
    - London-NY Overlap: 13:00-17:00 UTC (highest liquidity)
    - Asian: 00:00-08:00 UTC

    Attributes:
        sessions: Mapping of session name to (start_hour, end_hour) UTC.
    """

    sessions: dict[str, tuple[int, int]] = field(
        default_factory=lambda: {
            "sydney": (21, 6),
            "tokyo": (0, 9),
            "london": (8, 17),
            "new_york": (13, 22),
            "london_ny_overlap": (13, 17),
            "asian": (0, 8),
        }
    )

    def __post_init__(self) -> None:
        """Validate session definitions."""
        for name, (start, end) in self.sessions.items():
            if not 0 <= start <= 23:
                raise ValueError(f"Session '{name}' start hour must be 0-23, got {start}")
            if not 0 <= end <= 23:
                raise ValueError(f"Session '{name}' end hour must be 0-23, got {end}")

    def is_in_session(self, session_name: str, hour_utc: int) -> bool:
        """
        Check if a UTC hour falls within a named session.

        Handles sessions that cross midnight (e.g., Sydney 21:00-06:00).

        Args:
            session_name: Name of the session to check.
            hour_utc: Hour in UTC (0-23).

        Returns:
            True if the hour is within the session, False otherwise.

        Raises:
            KeyError: If session_name is not defined.
        """
        if session_name not in self.sessions:
            raise KeyError(f"Unknown session: {session_name}")

        start, end = self.sessions[session_name]

        if start <= end:
            # Normal session (e.g., London 08:00-17:00)
            return start <= hour_utc < end
        else:
            # Session crosses midnight (e.g., Sydney 21:00-06:00)
            return hour_utc >= start or hour_utc < end


@dataclass(slots=True)
class ValidationConfig:
    """
    Master validation configuration.

    Aggregates all sub-configurations for the validation pipeline.
    Supports loading from YAML files and provides sensible defaults.

    Attributes:
        catalog_path: Path to the data catalog (Parquet file or directory).
        memory: Memory management configuration.
        data_quality: Data quality thresholds.
        price: Price validation thresholds.
        backtest: Backtest statistical thresholds.
        apex: Apex compliance thresholds.
        sessions: Trading session definitions.
    """

    catalog_path: str
    memory: MemoryConfig = field(default_factory=MemoryConfig)
    data_quality: DataQualityConfig = field(default_factory=DataQualityConfig)
    price: PriceValidationConfig = field(default_factory=PriceValidationConfig)
    backtest: BacktestThresholdConfig = field(default_factory=BacktestThresholdConfig)
    apex: ApexConfig = field(default_factory=ApexConfig)
    sessions: SessionConfig = field(default_factory=SessionConfig)

    def __post_init__(self) -> None:
        """Validate the catalog path."""
        if not self.catalog_path:
            raise ValueError("catalog_path cannot be empty")

    @classmethod
    def default(cls, catalog_path: str) -> ValidationConfig:
        """
        Create a ValidationConfig with all default values.

        Args:
            catalog_path: Path to the data catalog.

        Returns:
            ValidationConfig with default thresholds.

        Example:
            config = ValidationConfig.default("/path/to/catalog")
        """
        return cls(catalog_path=catalog_path)

    @classmethod
    def from_yaml(cls, path: str | Path) -> ValidationConfig:
        """
        Load ValidationConfig from a YAML file.

        YAML structure expected:
        ```yaml
        catalog_path: /path/to/catalog
        memory:
          max_memory_gb: 6.0
          chunk_size_ticks: 5000000
          enable_spill_to_disk: true
        data_quality:
          min_coverage_months: 36
          ...
        price:
          price_range_min: 300.0
          ...
        backtest:
          min_wfe: 0.60
          ...
        apex:
          max_trailing_dd: 0.04
          ...
        sessions:
          sessions:
            london: [8, 17]
            new_york: [13, 22]
        ```

        Args:
            path: Path to the YAML configuration file.

        Returns:
            ValidationConfig loaded from the file.

        Raises:
            FileNotFoundError: If the file does not exist.
            ValueError: If the YAML structure is invalid.
            yaml.YAMLError: If the YAML cannot be parsed.
        """
        path = Path(path)
        if not path.exists():
            raise FileNotFoundError(f"Configuration file not found: {path}")

        with open(path, encoding="utf-8") as f:
            data: dict[str, Any] = yaml.safe_load(f)

        if not isinstance(data, dict):
            raise ValueError(f"YAML root must be a mapping, got {type(data).__name__}")

        catalog_path = data.get("catalog_path")
        if not catalog_path:
            raise ValueError("YAML must contain 'catalog_path' key")

        # Parse sub-configurations
        memory_data = data.get("memory", {})
        data_quality_data = data.get("data_quality", {})
        price_data = data.get("price", {})
        backtest_data = data.get("backtest", {})
        apex_data = data.get("apex", {})
        sessions_data = data.get("sessions", {})

        # Handle sessions specially due to tuple conversion
        sessions_dict: dict[str, tuple[int, int]] | None = None
        if sessions_data and "sessions" in sessions_data:
            raw_sessions = sessions_data["sessions"]
            if not isinstance(raw_sessions, dict):
                raise ValueError(
                    f"sessions.sessions must be a mapping of name -> [start,end], got {type(raw_sessions).__name__}"
                )
            sessions_dict = {}
            for name, hours in raw_sessions.items():
                if not isinstance(hours, (list, tuple)) or len(hours) != 2:
                    raise ValueError(
                        f"sessions.sessions.{name} must be a 2-item sequence [start,end], got {hours!r}"
                    )
                sessions_dict[str(name)] = (int(hours[0]), int(hours[1]))

        return cls(
            catalog_path=str(catalog_path),
            memory=MemoryConfig(**memory_data) if memory_data else MemoryConfig(),
            data_quality=(
                DataQualityConfig(**data_quality_data) if data_quality_data else DataQualityConfig()
            ),
            price=(PriceValidationConfig(**price_data) if price_data else PriceValidationConfig()),
            backtest=(
                BacktestThresholdConfig(**backtest_data)
                if backtest_data
                else BacktestThresholdConfig()
            ),
            apex=ApexConfig(**apex_data) if apex_data else ApexConfig(),
            sessions=(SessionConfig(sessions=sessions_dict) if sessions_dict else SessionConfig()),
        )

    def to_yaml(self, path: str | Path) -> None:
        """
        Save ValidationConfig to a YAML file.

        Args:
            path: Path to save the YAML configuration.
        """
        path = Path(path)
        path.parent.mkdir(parents=True, exist_ok=True)

        # Convert sessions tuples to lists for YAML
        sessions_for_yaml = {name: list(hours) for name, hours in self.sessions.sessions.items()}

        data = {
            "catalog_path": self.catalog_path,
            "memory": {
                "max_memory_gb": self.memory.max_memory_gb,
                "chunk_size_ticks": self.memory.chunk_size_ticks,
                "enable_spill_to_disk": self.memory.enable_spill_to_disk,
            },
            "data_quality": {
                "min_coverage_months": self.data_quality.min_coverage_months,
                "min_clean_data_pct": self.data_quality.min_clean_data_pct,
                "max_critical_gaps": self.data_quality.max_critical_gaps,
                "min_quality_score": self.data_quality.min_quality_score,
            },
            "price": {
                "price_range_min": self.price.price_range_min,
                "price_range_max": self.price.price_range_max,
                "max_spread_cents": self.price.max_spread_cents,
                "max_avg_spread_cents": self.price.max_avg_spread_cents,
            },
            "backtest": {
                "min_wfe": self.backtest.min_wfe,
                "min_sqn": self.backtest.min_sqn,
                "max_sqn": self.backtest.max_sqn,
                "min_psr": self.backtest.min_psr,
                "max_pbo": self.backtest.max_pbo,
                "max_mc_dd_95": self.backtest.max_mc_dd_95,
                "min_trades": self.backtest.min_trades,
                "min_dsr": self.backtest.min_dsr,
            },
            "apex": {
                "max_trailing_dd": self.apex.max_trailing_dd,
                "max_total_dd": self.apex.max_total_dd,
                "max_daily_profit": self.apex.max_daily_profit,
                "trade_block_hour_et": self.apex.trade_block_hour_et,
                "trade_block_minute_et": self.apex.trade_block_minute_et,
                "force_close_hour_et": self.apex.force_close_hour_et,
                "force_close_minute_et": self.apex.force_close_minute_et,
                "deadline_hour_et": self.apex.deadline_hour_et,
                "deadline_minute_et": self.apex.deadline_minute_et,
            },
            "sessions": {"sessions": sessions_for_yaml},
        }

        with open(path, "w", encoding="utf-8") as f:
            yaml.safe_dump(data, f, default_flow_style=False, sort_keys=False)

    def validate_catalog_exists(self) -> bool:
        """
        Check if the catalog path exists.

        Returns:
            True if the path exists, False otherwise.
        """
        return Path(self.catalog_path).exists()

    def get_duckdb_memory_limit(self) -> str:
        """
        Get DuckDB-compatible memory limit string.

        Returns:
            Memory limit formatted for DuckDB (e.g., "6GB").
        """
        return f"{int(self.memory.max_memory_gb)}GB"
