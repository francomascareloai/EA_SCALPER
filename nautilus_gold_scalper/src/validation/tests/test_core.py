"""Tests for validation core components."""

from __future__ import annotations

from datetime import datetime

import pytest
from nautilus_gold_scalper.src.validation.core.config import (
    DataQualityConfig,
    MemoryConfig,
    PriceValidationConfig,
    ValidationConfig,
)
from nautilus_gold_scalper.src.validation.core.engine import (
    DuckDBConnection,
)
from nautilus_gold_scalper.src.validation.core.results import (
    CheckResult,
    PhaseResult,
    PipelineResult,
    ValidationStatus,
)


class TestValidationConfig:
    """Tests for ValidationConfig dataclass."""

    def test_default_config(self) -> None:
        """Test creating config with defaults."""
        config = ValidationConfig(
            catalog_path="/data/test_catalog",
        )

        assert config.catalog_path == "/data/test_catalog"
        assert config.memory.max_memory_gb == 6.0
        assert config.memory.chunk_size_ticks == 5_000_000

    def test_memory_config_defaults(self) -> None:
        """Test MemoryConfig defaults match CLAUDE.md constraints."""
        memory = MemoryConfig()

        # 12GB system, 6GB for validation per CLAUDE.md
        assert memory.max_memory_gb == 6.0
        assert memory.chunk_size_ticks == 5_000_000  # 5M ticks
        assert memory.enable_spill_to_disk is True

    def test_data_quality_thresholds(self) -> None:
        """Test DataQualityConfig has correct thresholds."""
        quality = DataQualityConfig()

        assert quality.min_coverage_months == 36  # 3 years
        assert quality.min_clean_data_pct == 99.0  # 99%
        assert quality.max_critical_gaps == 0  # No critical gaps allowed
        assert quality.min_quality_score == 70.0

    def test_price_validation_ranges(self) -> None:
        """Test PriceValidationConfig for XAUUSD ranges."""
        prices = PriceValidationConfig()

        # XAUUSD historical range
        assert prices.price_range_min == 300.0  # Gold low ~2003
        assert prices.price_range_max == 3500.0  # Future proof
        assert prices.max_spread_cents == 100.0


class TestValidationStatus:
    """Tests for ValidationStatus enum."""

    def test_status_ordering(self) -> None:
        """Test status severity ordering using comparison."""
        # CRITICAL > FAIL > WARNING > SKIPPED > PASS
        assert ValidationStatus.PASS < ValidationStatus.SKIPPED
        assert ValidationStatus.SKIPPED < ValidationStatus.WARNING
        assert ValidationStatus.WARNING < ValidationStatus.FAIL
        assert ValidationStatus.FAIL < ValidationStatus.CRITICAL


class TestCheckResult:
    """Tests for CheckResult dataclass."""

    def test_create_passing_check(self) -> None:
        """Test creating a passing check result."""
        check = CheckResult(
            name="Test Check",
            status=ValidationStatus.PASS,
            message="All good",
            value=0.5,
            threshold=1.0,
        )

        assert check.name == "Test Check"
        assert check.status == ValidationStatus.PASS
        assert check.passed is True
        assert check.failed is False

    def test_create_failing_check(self) -> None:
        """Test creating a failing check result."""
        check = CheckResult(
            name="Gap Analysis",
            status=ValidationStatus.FAIL,
            message="Found 100 gaps",
            value=100,
            threshold=50,
            details={"gaps": [{"start": 1, "end": 2}]},
        )

        assert check.status == ValidationStatus.FAIL
        assert check.passed is False
        assert check.failed is True
        assert check.details is not None
        assert "gaps" in check.details

    def test_check_to_dict(self) -> None:
        """Test CheckResult serialization."""
        check = CheckResult(
            name="Test",
            status=ValidationStatus.PASS,
            message="OK",
            value=42,
        )

        d = check.to_dict()
        assert d["name"] == "Test"
        assert d["status"] == "PASS"
        assert d["value"] == 42


class TestPhaseResult:
    """Tests for PhaseResult dataclass."""

    def test_phase_result_computation(self) -> None:
        """Test PhaseResult status computation from checks."""
        result = PhaseResult(
            phase_id="phase_1",
            phase_name="Test Phase",
            status=ValidationStatus.PASS,
        )
        result.start_time = datetime.now()

        # Add passing check
        result.add_check(CheckResult(
            name="Check 1",
            status=ValidationStatus.PASS,
            message="OK",
        ))

        # Add warning check
        result.add_check(CheckResult(
            name="Check 2",
            status=ValidationStatus.WARNING,
            message="Minor issue",
        ))

        # Compute should be WARNING (worst status)
        assert result.compute_status() == ValidationStatus.WARNING

    def test_phase_result_critical_overrides(self) -> None:
        """Test that CRITICAL status overrides all."""
        result = PhaseResult(
            phase_id="phase_2",
            phase_name="Critical Test",
            status=ValidationStatus.PASS,
        )
        result.start_time = datetime.now()

        result.add_check(CheckResult(
            name="Good Check",
            status=ValidationStatus.PASS,
            message="OK",
        ))

        result.add_check(CheckResult(
            name="Critical Check",
            status=ValidationStatus.CRITICAL,
            message="Data corrupted",
        ))

        assert result.compute_status() == ValidationStatus.CRITICAL


class TestDuckDBConnection:
    """Tests for DuckDB connection wrapper."""

    def test_connection_creation(self) -> None:
        """Test creating an in-memory DuckDB connection."""
        db = DuckDBConnection(memory_limit_gb=2.0)

        # Basic query should work
        result = db.query("SELECT 1 as test").fetchone()
        assert result is not None
        assert result[0] == 1

    def test_polars_query(self) -> None:
        """Test query returning Polars DataFrame."""
        db = DuckDBConnection()

        df = db.query_df("SELECT 1 as a, 2 as b UNION ALL SELECT 3, 4")

        assert len(df) == 2
        assert "a" in df.columns
        assert "b" in df.columns

    def test_context_manager(self) -> None:
        """Test DuckDB connection as context manager."""
        with DuckDBConnection() as db:
            result = db.query("SELECT 42").fetchone()
            assert result is not None
            assert result[0] == 42


class TestPipelineResult:
    """Tests for PipelineResult (full validation run)."""

    def test_go_nogo_decision_go(self) -> None:
        """Test GO decision when all phases pass."""
        pipeline = PipelineResult(pipeline_start=datetime.now())

        # Add passing phase
        phase = PhaseResult(
            phase_id="phase_1",
            phase_name="Phase 1",
            status=ValidationStatus.PASS,
        )
        phase.start_time = datetime.now()
        phase.end_time = datetime.now()
        pipeline.add_phase(phase)

        assert pipeline.go_nogo_decision == "GO"

    def test_go_nogo_decision_nogo(self) -> None:
        """Test NO-GO decision when a phase fails."""
        pipeline = PipelineResult(pipeline_start=datetime.now())

        # Add failing phase
        phase = PhaseResult(
            phase_id="phase_1",
            phase_name="Phase 1",
            status=ValidationStatus.FAIL,
        )
        phase.start_time = datetime.now()
        phase.end_time = datetime.now()
        pipeline.add_phase(phase)

        assert pipeline.go_nogo_decision == "NO-GO"

    def test_go_nogo_decision_conditional(self) -> None:
        """Test GO-CONDITIONAL when there are warnings."""
        pipeline = PipelineResult(pipeline_start=datetime.now())

        # Add phase with warnings
        phase = PhaseResult(
            phase_id="phase_1",
            phase_name="Phase 1",
            status=ValidationStatus.WARNING,
        )
        phase.start_time = datetime.now()
        phase.end_time = datetime.now()
        pipeline.add_phase(phase)

        assert pipeline.go_nogo_decision == "GO-CONDITIONAL"


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
