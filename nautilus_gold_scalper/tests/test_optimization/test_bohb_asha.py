"""Tests for BOHB and ASHA search strategies."""

from __future__ import annotations

from typing import Any

import pytest

from src.optimization.config import (
    DataConfig,
    OptimizationConfig,
    ParameterSpec,
    SearchConfig,
    SuccessiveHalvingConfig,
)
from src.optimization.search.base import TrialResult


def _make_trial_result(
    trial_id: int,
    params: dict[str, Any],
    score: float,
) -> TrialResult:
    """Create a minimal TrialResult for testing."""
    return TrialResult(
        trial_id=trial_id,
        params=params,
        sqn=score,
        sharpe=0.0,
        sortino=0.0,
        profit_factor=0.0,
        total_pnl=0.0,
        trades=10,
        win_rate=0.5,
        max_drawdown_pct=1.0,
        wfe=score,
        wfe_std=0.0,
        positive_days_ratio=0.5,
        regime_scores={},
        trailing_dd=1.0,
        daily_profit_max=10.0,
        daily_dd=1.0,
        time_gate_violations=0,
        overnight_positions=0,
        apex_compliant=True,
        score=score,
    )


def _make_config(*, trials: int, eta: int, mode: str = "successive_halving") -> OptimizationConfig:
    """Create test optimization config."""
    cfg = OptimizationConfig()
    cfg.search = SearchConfig(
        mode=mode,
        trials=trials,
        seed=42,
        parallelism=2,
        successive_halving=SuccessiveHalvingConfig(
            enabled=True,
            eta=eta,
            window_days=(30, 0),
            wfa_windows=(1, 3),
            promotion_metric="score",
            sampler="sobol",
            mutate_between_rungs=False,
            mutate_prob=0.75,
        ),
    )
    cfg.parameters = [
        ParameterSpec(name="x", param_type="float", range=(0.0, 10.0), step=0.5),
        ParameterSpec(name="y", param_type="int", range=(1, 5), step=1),
    ]
    cfg.data = DataConfig(train_start="2020-01-01", train_end="2020-12-31")
    return cfg


class TestBOHBSearch:
    """Tests for BOHBSearch."""

    def test_bohb_instantiation(self) -> None:
        """Test that BOHBSearch can be instantiated."""
        from src.optimization.search.bohb import BOHBSearch

        cfg = _make_config(trials=10, eta=3)

        def dummy_objective_fidelity(
            params: dict[str, Any],
            start: str,
            end: str,
            windows: int,
            feed: str,
            bars_file: str | None,
        ) -> TrialResult:
            return _make_trial_result(0, params, float(params["x"]))

        searcher = BOHBSearch(
            cfg,
            objective_fn_with_fidelity=dummy_objective_fidelity,
            min_resource=1,
            max_resource=3,
            reduction_factor=3,
        )

        assert searcher is not None
        assert searcher._min_resource == 1
        assert searcher._max_resource == 3
        assert searcher._reduction_factor == 3

    def test_bohb_get_study_summary_empty(self) -> None:
        """Test study summary when no search has been run."""
        from src.optimization.search.bohb import BOHBSearch

        cfg = _make_config(trials=10, eta=3)
        searcher = BOHBSearch(cfg)

        summary = searcher.get_study_summary()
        assert summary == {}

    def test_bohb_get_best_params_empty(self) -> None:
        """Test best params when no search has been run."""
        from src.optimization.search.bohb import BOHBSearch

        cfg = _make_config(trials=10, eta=3)
        searcher = BOHBSearch(cfg)

        params = searcher.get_best_params()
        assert params == {}


class TestASHASearch:
    """Tests for ASHASearch."""

    def test_asha_instantiation(self) -> None:
        """Test that ASHASearch can be instantiated."""
        from src.optimization.search.asha import ASHASearch

        cfg = _make_config(trials=10, eta=3)

        def dummy_objective_fidelity(
            params: dict[str, Any],
            start: str,
            end: str,
            windows: int,
            feed: str,
            bars_file: str | None,
        ) -> TrialResult:
            return _make_trial_result(0, params, float(params["x"]))

        searcher = ASHASearch(
            cfg,
            objective_fn_with_fidelity=dummy_objective_fidelity,
            n_workers=2,
            reduction_factor=4,
        )

        assert searcher is not None
        assert searcher._n_workers == 2
        assert searcher._reduction_factor == 4

    def test_asha_requires_fidelity_objective(self) -> None:
        """Test that ASHA requires fidelity-aware objective."""
        from src.optimization.search.asha import ASHASearch

        cfg = _make_config(trials=10, eta=3)
        searcher = ASHASearch(cfg)

        with pytest.raises(ValueError, match="objective_fn_with_fidelity must be provided"):
            searcher.search(lambda p: _make_trial_result(0, p, 0.0))

    def test_asha_get_study_summary(self) -> None:
        """Test ASHA study summary structure."""
        from src.optimization.search.asha import ASHASearch

        cfg = _make_config(trials=10, eta=3)
        searcher = ASHASearch(cfg)

        summary = searcher.get_study_summary()
        assert "n_trials" in summary
        assert "mode" in summary
        assert summary["mode"] == "asha"

    def test_asha_build_rungs(self) -> None:
        """Test that ASHA builds rungs correctly from config."""
        from src.optimization.search.asha import ASHASearch

        cfg = _make_config(trials=10, eta=3)
        searcher = ASHASearch(cfg)

        rungs = searcher._build_rungs()
        assert len(rungs) == 2
        assert rungs[0].level == 0
        assert rungs[0].wfa_windows == 1
        assert rungs[1].level == 1
        assert rungs[1].wfa_windows == 3


class TestWarmStartProvider:
    """Tests for WarmStartProvider."""

    def test_warmstart_instantiation(self) -> None:
        """Test WarmStartProvider can be instantiated."""
        from src.optimization.warmstart import WarmStartConfig, WarmStartProvider

        cfg = _make_config(trials=10, eta=3)
        warm_cfg = WarmStartConfig(
            checkpoint_paths=[],
            parquet_paths=[],
            min_score=0.0,
            apex_only=False,
            top_k=10,
        )

        provider = WarmStartProvider(cfg, warm_cfg)
        assert provider is not None

    def test_warmstart_hash_deterministic(self) -> None:
        """Test that param hashing is deterministic."""
        from src.optimization.warmstart import _hash_params

        params1 = {"x": 1.0, "y": 2, "z": "abc"}
        params2 = {"z": "abc", "x": 1.0, "y": 2}  # Same but different order

        hash1 = _hash_params(params1)
        hash2 = _hash_params(params2)

        assert hash1 == hash2

    def test_warmstart_is_evaluated(self) -> None:
        """Test is_evaluated check."""
        from src.optimization.warmstart import WarmStartConfig, WarmStartProvider, _hash_params

        cfg = _make_config(trials=10, eta=3)
        warm_cfg = WarmStartConfig(
            checkpoint_paths=[],
            parquet_paths=[],
        )

        provider = WarmStartProvider(cfg, warm_cfg)

        # Add a seen hash
        params = {"x": 1.0, "y": 2}
        provider._seen_hashes.add(_hash_params(params))

        assert provider.is_evaluated(params)
        assert not provider.is_evaluated({"x": 2.0, "y": 3})


class TestAdaptiveFidelitySelector:
    """Tests for AdaptiveFidelitySelector."""

    def test_adaptive_fidelity_instantiation(self) -> None:
        """Test AdaptiveFidelitySelector can be instantiated."""
        from src.optimization.adaptive_fidelity import AdaptiveFidelitySelector

        cfg = _make_config(trials=10, eta=3)
        selector = AdaptiveFidelitySelector(cfg)

        assert selector is not None
        assert selector._current_level == 0

    def test_adaptive_fidelity_select_initial(self) -> None:
        """Test initial fidelity selection uses lowest level."""
        from src.optimization.adaptive_fidelity import AdaptiveFidelitySelector

        cfg = _make_config(trials=10, eta=3)
        selector = AdaptiveFidelitySelector(cfg)

        level = selector.select_fidelity({"x": 1.0, "y": 2})

        assert level.level == 0

    def test_adaptive_fidelity_record_result(self) -> None:
        """Test recording results updates statistics."""
        from src.optimization.adaptive_fidelity import AdaptiveFidelitySelector

        cfg = _make_config(trials=10, eta=3)
        selector = AdaptiveFidelitySelector(cfg)

        level = selector.select_fidelity({"x": 1.0, "y": 2})
        result = _make_trial_result(0, {"x": 1.0, "y": 2}, 0.75)

        selector.record_result(level, result)

        assert selector._level_stats[0].n_evals == 1
        assert selector._level_stats[0].max_score == 0.75

    def test_adaptive_fidelity_summary(self) -> None:
        """Test fidelity summary structure."""
        from src.optimization.adaptive_fidelity import AdaptiveFidelitySelector

        cfg = _make_config(trials=10, eta=3)
        selector = AdaptiveFidelitySelector(cfg)

        summary = selector.get_fidelity_summary()

        assert "total_evals" in summary
        assert "current_level" in summary
        assert "levels" in summary
