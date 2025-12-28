"""Tests for anti-overfitting detection.

Plan 10-05: Test cliff, island, and regime-bias detectors.
"""

from __future__ import annotations

from src.optimization.config import ParameterSpec
from src.optimization.constraints.anti_overfit import (
    OverfitSeverity,
    OverfitWarning,
    OverfitWarningType,
    detect_cliff,
    detect_island,
    detect_regime_bias,
    run_all_detectors,
    summarize_warnings,
)
from src.optimization.search.base import TrialResult


def _make_result(
    trial_id: int = 1,
    params: dict | None = None,
    score: float = 1.0,
    regime_scores: dict[str, float] | None = None,
) -> TrialResult:
    """Helper to create TrialResult with defaults."""
    return TrialResult(
        trial_id=trial_id,
        params=params or {},
        sqn=2.0,
        sharpe=1.5,
        sortino=1.8,
        profit_factor=1.5,
        total_pnl=1000.0,
        trades=250,
        win_rate=0.55,
        max_drawdown_pct=3.0,
        wfe=0.7,
        wfe_std=0.1,
        positive_days_ratio=0.6,
        regime_scores=regime_scores or {},
        trailing_dd=3.0,
        daily_profit_max=15.0,
        daily_dd=1.5,
        time_gate_violations=0,
        overnight_positions=0,
        apex_compliant=True,
        score=score,
    )


def _make_param_specs() -> list[ParameterSpec]:
    """Create test parameter specs."""
    return [
        ParameterSpec(
            name="threshold",
            param_type="float",
            range=(0.1, 1.0),
            step=0.1,
        ),
        ParameterSpec(
            name="lookback",
            param_type="int",
            range=(10, 100),
            step=10,
        ),
        ParameterSpec(
            name="multiplier",
            param_type="float",
            range=(0.5, 2.0),
            step=0.1,
        ),
    ]


class TestDetectCliff:
    """Test cliff detection at parameter boundaries."""

    def test_cliff_low_detected(self) -> None:
        """Param at 2% of range should trigger CLIFF_LOW."""
        specs = _make_param_specs()
        # threshold range is [0.1, 1.0], so 0.12 is at 2.2% of range
        params = {"threshold": 0.12, "lookback": 50, "multiplier": 1.0}

        warnings = detect_cliff(params, specs, tolerance=0.05)

        assert len(warnings) == 1
        assert warnings[0].warning_type == OverfitWarningType.CLIFF_LOW
        assert warnings[0].parameter == "threshold"
        assert warnings[0].severity == OverfitSeverity.WARN

    def test_cliff_high_detected(self) -> None:
        """Param at 98% of range should trigger CLIFF_HIGH."""
        specs = _make_param_specs()
        # threshold range is [0.1, 1.0], so 0.98 is at 97.8% of range
        params = {"threshold": 0.98, "lookback": 50, "multiplier": 1.0}

        warnings = detect_cliff(params, specs, tolerance=0.05)

        assert len(warnings) == 1
        assert warnings[0].warning_type == OverfitWarningType.CLIFF_HIGH
        assert warnings[0].parameter == "threshold"

    def test_no_cliff_in_middle(self) -> None:
        """Param at 50% should NOT trigger cliff warning."""
        specs = _make_param_specs()
        # All params in middle of range
        params = {"threshold": 0.55, "lookback": 50, "multiplier": 1.25}

        warnings = detect_cliff(params, specs, tolerance=0.05)

        assert len(warnings) == 0

    def test_multiple_cliffs_detected(self) -> None:
        """Multiple params at edges should trigger multiple warnings."""
        specs = _make_param_specs()
        # threshold at low edge, multiplier at high edge
        params = {"threshold": 0.12, "lookback": 50, "multiplier": 1.98}

        warnings = detect_cliff(params, specs, tolerance=0.05)

        assert len(warnings) == 2
        types = {w.warning_type for w in warnings}
        assert OverfitWarningType.CLIFF_LOW in types
        assert OverfitWarningType.CLIFF_HIGH in types

    def test_empty_params(self) -> None:
        """Empty params should return no warnings."""
        specs = _make_param_specs()
        params: dict[str, float] = {}

        warnings = detect_cliff(params, specs)

        assert len(warnings) == 0

    def test_tolerance_boundary(self) -> None:
        """Param just outside tolerance boundary should NOT trigger."""
        specs = _make_param_specs()
        # threshold range [0.1, 1.0], range_size = 0.9
        # 5% of range = 0.045, so min + 0.045 = 0.145
        # Use 0.15 which is at 5.5% to be clearly outside tolerance
        params = {"threshold": 0.15}

        warnings = detect_cliff(params, specs, tolerance=0.05)

        # At 5.5%, should not trigger (> tolerance)
        assert len(warnings) == 0


class TestDetectIsland:
    """Test island detection for isolated optima."""

    def test_island_detected_when_isolated(self) -> None:
        """Best result with very different params should trigger ISLAND."""
        # Best has very different params from the rest
        results = [
            _make_result(1, {"a": 0.5, "b": 2.0}, score=100),
            _make_result(2, {"a": 0.1, "b": 0.5}, score=90),
            _make_result(3, {"a": 0.15, "b": 0.6}, score=85),
            _make_result(4, {"a": 0.12, "b": 0.55}, score=80),
            _make_result(5, {"a": 0.11, "b": 0.52}, score=75),
            _make_result(6, {"a": 0.13, "b": 0.58}, score=70),
        ]

        warnings = detect_island(results, top_k=5, neighbor_threshold=0.10)

        assert len(warnings) == 1
        assert warnings[0].warning_type == OverfitWarningType.ISLAND
        assert warnings[0].severity == OverfitSeverity.CRITICAL

    def test_no_island_with_neighbors(self) -> None:
        """Best result with similar neighbors should NOT trigger."""
        # Best has similar params to #2
        results = [
            _make_result(1, {"a": 0.50, "b": 2.0}, score=100),
            _make_result(2, {"a": 0.52, "b": 2.1}, score=90),  # Within 10%
            _make_result(3, {"a": 0.1, "b": 0.5}, score=85),
            _make_result(4, {"a": 0.12, "b": 0.55}, score=80),
            _make_result(5, {"a": 0.11, "b": 0.52}, score=75),
            _make_result(6, {"a": 0.13, "b": 0.58}, score=70),
        ]

        warnings = detect_island(results, top_k=5, neighbor_threshold=0.10)

        assert len(warnings) == 0

    def test_insufficient_results(self) -> None:
        """Not enough results should return no warning."""
        results = [
            _make_result(1, {"a": 0.5}),
            _make_result(2, {"a": 0.1}),
        ]

        warnings = detect_island(results, top_k=5)

        assert len(warnings) == 0

    def test_empty_results(self) -> None:
        """Empty results should return no warnings."""
        warnings = detect_island([], top_k=5)
        assert len(warnings) == 0

    def test_categorical_only_triggers_island(self) -> None:
        """When all params are categorical, island should be detected.

        Regression test: _params_are_close must return False when no numeric
        comparison happened (fail-closed), so categorical-only params trigger
        ISLAND warning since no neighbor proximity can be established.
        """
        # All params are strings (categorical) - no numeric comparison possible
        results = [
            _make_result(1, {"mode": "aggressive", "style": "fast"}, score=100),
            _make_result(2, {"mode": "conservative", "style": "slow"}, score=90),
            _make_result(3, {"mode": "moderate", "style": "medium"}, score=85),
            _make_result(4, {"mode": "cautious", "style": "steady"}, score=80),
            _make_result(5, {"mode": "balanced", "style": "normal"}, score=75),
            _make_result(6, {"mode": "defensive", "style": "careful"}, score=70),
        ]

        warnings = detect_island(results, top_k=5, neighbor_threshold=0.10)

        # With no numeric params, _params_are_close returns False → island detected
        assert len(warnings) == 1
        assert warnings[0].warning_type == OverfitWarningType.ISLAND


class TestDetectRegimeBias:
    """Test regime bias detection."""

    def test_regime_bias_detected(self) -> None:
        """Regime with <20% of best performance should trigger warning."""
        result = _make_result(
            regime_scores={
                "trend": 1.5,
                "range": 0.2,  # 13.3% of best
                "volatile": 0.8,
            }
        )

        warnings = detect_regime_bias(result, min_coverage=0.20)

        assert len(warnings) == 1
        assert warnings[0].warning_type == OverfitWarningType.REGIME_BIAS
        assert "range" in warnings[0].message

    def test_multiple_regime_bias(self) -> None:
        """Multiple underperforming regimes should trigger multiple warnings."""
        result = _make_result(
            regime_scores={
                "trend": 1.5,
                "range": 0.1,  # 6.7% of best
                "volatile": 0.2,  # 13.3% of best
            }
        )

        warnings = detect_regime_bias(result, min_coverage=0.20)

        assert len(warnings) == 2

    def test_no_regime_bias(self) -> None:
        """All regimes >20% of best should NOT trigger."""
        result = _make_result(
            regime_scores={
                "trend": 1.5,
                "range": 0.5,  # 33% of best
                "volatile": 0.8,  # 53% of best
            }
        )

        warnings = detect_regime_bias(result, min_coverage=0.20)

        assert len(warnings) == 0

    def test_graceful_degradation_no_regime_scores(self) -> None:
        """Missing regime_scores should return empty list, not error."""
        result = _make_result(regime_scores={})

        warnings = detect_regime_bias(result)

        assert len(warnings) == 0

    def test_all_negative_regimes(self) -> None:
        """All negative regime scores should return no warnings."""
        result = _make_result(
            regime_scores={
                "trend": -0.5,
                "range": -0.8,
            }
        )

        warnings = detect_regime_bias(result)

        assert len(warnings) == 0


class TestRunAllDetectors:
    """Test combined detector runner."""

    def test_runs_all_detectors(self) -> None:
        """Should run cliff, island, and regime bias detectors."""
        specs = _make_param_specs()
        results = [
            _make_result(
                1,
                {"threshold": 0.12, "lookback": 50, "multiplier": 1.0},
                score=100,
                regime_scores={"trend": 1.5, "range": 0.1},
            ),
            _make_result(2, {"threshold": 0.1, "lookback": 10, "multiplier": 0.5}, score=50),
            _make_result(3, {"threshold": 0.2, "lookback": 20, "multiplier": 0.6}, score=40),
            _make_result(4, {"threshold": 0.15, "lookback": 15, "multiplier": 0.55}, score=35),
            _make_result(5, {"threshold": 0.18, "lookback": 18, "multiplier": 0.58}, score=30),
            _make_result(6, {"threshold": 0.17, "lookback": 17, "multiplier": 0.57}, score=25),
        ]

        warnings = run_all_detectors(results, specs)

        # Should have cliff (threshold at low edge) + island + regime bias
        types = {w.warning_type for w in warnings}
        assert OverfitWarningType.CLIFF_LOW in types
        assert OverfitWarningType.REGIME_BIAS in types

    def test_empty_results(self) -> None:
        """Empty results should return empty list."""
        specs = _make_param_specs()
        warnings = run_all_detectors([], specs)
        assert warnings == []


class TestSummarizeWarnings:
    """Test warning summarization."""

    def test_summarize_multiple_types(self) -> None:
        """Should count warnings by type."""
        warnings = [
            OverfitWarning(OverfitWarningType.CLIFF_LOW, "a", OverfitSeverity.WARN, "msg"),
            OverfitWarning(OverfitWarningType.CLIFF_HIGH, "b", OverfitSeverity.WARN, "msg"),
            OverfitWarning(OverfitWarningType.CLIFF_LOW, "c", OverfitSeverity.WARN, "msg"),
            OverfitWarning(OverfitWarningType.ISLAND, None, OverfitSeverity.CRITICAL, "msg"),
        ]

        summary = summarize_warnings(warnings)

        assert summary == {
            "CLIFF_LOW": 2,
            "CLIFF_HIGH": 1,
            "ISLAND": 1,
        }

    def test_summarize_empty(self) -> None:
        """Empty warnings should return empty dict."""
        summary = summarize_warnings([])
        assert summary == {}


class TestOverfitWarning:
    """Test OverfitWarning dataclass."""

    def test_to_dict(self) -> None:
        """Should serialize to dict correctly."""
        warning = OverfitWarning(
            warning_type=OverfitWarningType.CLIFF_LOW,
            parameter="threshold",
            severity=OverfitSeverity.WARN,
            message="threshold=0.12 is near min",
        )

        d = warning.to_dict()

        assert d == {
            "type": "CLIFF_LOW",
            "parameter": "threshold",
            "severity": "WARN",
            "message": "threshold=0.12 is near min",
        }

    def test_to_dict_no_parameter(self) -> None:
        """Should handle None parameter."""
        warning = OverfitWarning(
            warning_type=OverfitWarningType.ISLAND,
            parameter=None,
            severity=OverfitSeverity.CRITICAL,
            message="Isolated optimum",
        )

        d = warning.to_dict()

        assert d["parameter"] is None
