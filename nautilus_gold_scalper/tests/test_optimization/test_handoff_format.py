"""Tests for handoff format generation in SummaryReporter."""

from __future__ import annotations

import tempfile

from src.optimization.config import OptimizationConfig
from src.optimization.reporting.summary import SummaryReporter
from src.optimization.search.base import TrialResult


def _make_trial_result(
    trial_id: int,
    score: float,
    apex_compliant: bool = True,
    overfit_warnings: list[dict[str, str | None]] | None = None,
) -> TrialResult:
    """Create a minimal TrialResult for testing."""
    return TrialResult(
        trial_id=trial_id,
        params={"param1": 0.5, "param2": 100},
        sqn=2.5,
        sharpe=1.8,
        sortino=2.1,
        profit_factor=1.9,
        total_pnl=5000.0,
        trades=250,
        win_rate=0.55,
        max_drawdown_pct=3.5,
        wfe=0.72,
        wfe_std=0.05,
        positive_days_ratio=0.65,
        regime_scores={"trend": 0.8, "range": 0.6, "volatile": 0.7},
        trailing_dd=2.5,
        daily_profit_max=15.0,
        daily_dd=1.0,
        time_gate_violations=0,
        overnight_positions=0,
        apex_compliant=apex_compliant,
        score=score,
        mc_95_dd=3.2,
        mc_99_dd=4.1,
        degradation_survived=[0.1, 0.2],
        pbo=0.18,
        overfit_warnings=overfit_warnings,
        duration_seconds=120.0,
        output_dir="/tmp/test",
        pruned=False,
    )


def _make_config() -> OptimizationConfig:
    """Create a minimal OptimizationConfig for testing."""
    return OptimizationConfig(
        name="Test Optimization",
        version="1.0",
    )


class TestHandoffFormatGeneration:
    """Tests for generate_handoff() method."""

    def test_handoff_generates_oracle_file(self) -> None:
        """Handoff generates HANDOFF_ORACLE.md file."""
        with tempfile.TemporaryDirectory() as tmpdir:
            config = _make_config()
            reporter = SummaryReporter(tmpdir, config)
            results = [_make_trial_result(i, 0.8 - i * 0.1) for i in range(5)]

            path = reporter.generate_handoff(results, target="ORACLE")

            assert path.exists()
            assert path.name == "HANDOFF_ORACLE.md"

    def test_handoff_generates_sentinel_file(self) -> None:
        """Handoff generates HANDOFF_SENTINEL.md file."""
        with tempfile.TemporaryDirectory() as tmpdir:
            config = _make_config()
            reporter = SummaryReporter(tmpdir, config)
            results = [_make_trial_result(i, 0.8 - i * 0.1) for i in range(5)]

            path = reporter.generate_handoff(results, target="SENTINEL")

            assert path.exists()
            assert path.name == "HANDOFF_SENTINEL.md"

    def test_handoff_contains_required_sections(self) -> None:
        """Handoff contains all required sections from PRD."""
        with tempfile.TemporaryDirectory() as tmpdir:
            config = _make_config()
            reporter = SummaryReporter(tmpdir, config)
            results = [_make_trial_result(i, 0.8 - i * 0.1) for i in range(5)]

            path = reporter.generate_handoff(results, target="ORACLE")
            content = path.read_text()

            # Check required sections
            assert "### Run Metadata" in content
            assert "### Search Space Summary" in content
            assert "### Top" in content and "Candidates" in content
            assert "### Apex Rejection Summary" in content
            assert "### Apex Compliance Limits" in content
            assert "### Recommendations for ORACLE" in content
            assert "### Files Generated" in content
            assert "### Next Agent Should" in content

    def test_handoff_contains_apex_limits(self) -> None:
        """Handoff explicitly shows Apex limits with buffers."""
        with tempfile.TemporaryDirectory() as tmpdir:
            config = _make_config()
            reporter = SummaryReporter(tmpdir, config)
            results = [_make_trial_result(0, 0.8)]

            path = reporter.generate_handoff(results, target="ORACLE")
            content = path.read_text()

            # Check Apex limits are present
            assert "Trailing DD Max:" in content
            assert "Daily DD Max:" in content
            assert "Daily Profit Max:" in content
            assert "Overnight Positions:" in content
            assert "Time Gate Violations:" in content
            # Check buffer explanations
            assert "Apex limit: 5%" in content

    def test_handoff_includes_ghost_test_when_provided(self) -> None:
        """Handoff includes Ghost Test section when ghost_summary is provided."""
        with tempfile.TemporaryDirectory() as tmpdir:
            config = _make_config()
            reporter = SummaryReporter(tmpdir, config)
            results = [_make_trial_result(0, 0.8)]
            ghost_summary = {
                "sharpe_full": 1.5,
                "sharpe_baseline_mean": 0.8,
                "sharpe_baseline_std": 0.3,
                "sharpe_delta": 0.7,
                "p_value": 0.02,
                "sims": 200,
            }

            path = reporter.generate_handoff(results, target="ORACLE", ghost_summary=ghost_summary)
            content = path.read_text()

            assert "### Ghost Test (Signal vs Baseline)" in content
            assert "Sharpe(full):" in content
            assert "ΔSharpe(full-baseline):" in content
            assert "p-value(one-sided):" in content
            assert "verdict:" in content

    def test_handoff_includes_stratification_when_provided(self) -> None:
        """Handoff includes Stratification Summary when provided."""
        with tempfile.TemporaryDirectory() as tmpdir:
            config = _make_config()
            reporter = SummaryReporter(tmpdir, config)
            results = [_make_trial_result(0, 0.8)]
            strat_summary = {
                "by_session": {"london": {"trades": 100, "pnl": 2000}},
                "by_regime": {"trend": {"sharpe": 1.5}},
            }

            path = reporter.generate_handoff(
                results, target="ORACLE", stratification_summary=strat_summary
            )
            content = path.read_text()

            assert "### Stratification Summary" in content
            assert "by_session" in content
            assert "london" in content

    def test_handoff_includes_overfit_analysis_default_clear(self) -> None:
        """Handoff shows CLEAR status when no overfit_warnings."""
        with tempfile.TemporaryDirectory() as tmpdir:
            config = _make_config()
            reporter = SummaryReporter(tmpdir, config)
            results = [_make_trial_result(0, 0.8, overfit_warnings=None)]

            path = reporter.generate_handoff(results, target="ORACLE")
            content = path.read_text()

            assert "### Overfitting Analysis" in content
            assert "Cliff Detection" in content
            assert "Island Detection" in content
            assert "Regime Bias" in content
            assert "CLEAR" in content

    def test_handoff_shows_overfit_warnings_when_present(self) -> None:
        """Handoff shows warnings when overfit_warnings are present."""
        with tempfile.TemporaryDirectory() as tmpdir:
            config = _make_config()
            reporter = SummaryReporter(tmpdir, config)

            warnings = [
                {"type": "CLIFF_LOW", "message": "param1=0.15 near min=0.15"},
                {"type": "REGIME_BIAS", "message": "range score=0.4 below coverage"},
            ]
            results = [_make_trial_result(0, 0.8, overfit_warnings=warnings)]

            path = reporter.generate_handoff(results, target="ORACLE")
            content = path.read_text()

            assert "### Overfitting Analysis" in content
            # Should show cliff warning
            assert "Cliff Detection" in content
            # Should show regime warning
            assert "Regime Bias" in content

    def test_handoff_with_explicit_overfit_analysis(self) -> None:
        """Handoff uses explicit overfit_analysis when provided."""
        with tempfile.TemporaryDirectory() as tmpdir:
            config = _make_config()
            reporter = SummaryReporter(tmpdir, config)
            results = [_make_trial_result(0, 0.8)]

            overfit = {
                "cliff": ["CLIFF_HIGH: param1=0.40 near max=0.40"],
                "island": [],
                "regime_bias": ["range score too low"],
            }

            path = reporter.generate_handoff(results, target="ORACLE", overfit_analysis=overfit)
            content = path.read_text()

            assert "Cliff Detection" in content
            assert "WARNING" in content
            assert "CLIFF_HIGH" in content
            assert "range score too low" in content

    def test_handoff_limits_warnings_to_three_per_category(self) -> None:
        """Handoff limits warning display to 3 per category to keep compact."""
        with tempfile.TemporaryDirectory() as tmpdir:
            config = _make_config()
            reporter = SummaryReporter(tmpdir, config)
            results = [_make_trial_result(0, 0.8)]

            overfit = {
                "cliff": [f"warning {i}" for i in range(10)],
                "island": [],
                "regime_bias": [],
            }

            path = reporter.generate_handoff(results, target="ORACLE", overfit_analysis=overfit)
            content = path.read_text()

            # Should only show 3 warnings
            assert content.count("warning") <= 3


class TestHandoffWithEmptyResults:
    """Tests for edge cases with empty or minimal results."""

    def test_handoff_with_empty_results(self) -> None:
        """Handoff handles empty results gracefully."""
        with tempfile.TemporaryDirectory() as tmpdir:
            config = _make_config()
            reporter = SummaryReporter(tmpdir, config)

            path = reporter.generate_handoff([], target="ORACLE")
            content = path.read_text()

            assert "HANDOFF: APEX_OPTIMIZER" in content
            assert "Top 0 Candidates" in content

    def test_handoff_with_single_result(self) -> None:
        """Handoff handles single result correctly."""
        with tempfile.TemporaryDirectory() as tmpdir:
            config = _make_config()
            reporter = SummaryReporter(tmpdir, config)
            results = [_make_trial_result(0, 0.8)]

            path = reporter.generate_handoff(results, target="ORACLE")
            content = path.read_text()

            assert "Top 1 Candidates" in content


class TestHandoffStudyStats:
    """Tests for study_stats integration."""

    def test_handoff_shows_study_stats(self) -> None:
        """Handoff shows study statistics when provided."""
        with tempfile.TemporaryDirectory() as tmpdir:
            config = _make_config()
            reporter = SummaryReporter(tmpdir, config)
            results = [_make_trial_result(0, 0.8)]
            stats = {"n_complete": 100, "n_pruned": 20, "duration_seconds": 3600}

            path = reporter.generate_handoff(results, target="ORACLE", study_stats=stats)
            content = path.read_text()

            assert "100 completed" in content
            assert "20 pruned" in content
            assert "3600.0s" in content
