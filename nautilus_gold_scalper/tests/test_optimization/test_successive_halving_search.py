"""Tests for Successive Halving search strategy."""

from __future__ import annotations

from collections import Counter
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
from src.optimization.search.successive_halving import SuccessiveHalvingSearch


def _make_config(*, trials: int, eta: int) -> OptimizationConfig:
    cfg = OptimizationConfig()
    cfg.search = SearchConfig(
        mode="successive_halving",
        trials=trials,
        seed=42,
        successive_halving=SuccessiveHalvingConfig(
            enabled=True,
            eta=eta,
            window_days=(30, 0),
            wfa_windows=(1, 3),
            promotion_metric="score",
            sampler="lhs",
            mutate_between_rungs=False,
            mutate_prob=0.75,
        ),
    )
    cfg.parameters = [
        ParameterSpec(name="x", param_type="int", range=(0, 8), step=1),
    ]
    cfg.data = DataConfig(train_start="2020-01-01", train_end="2020-12-31")
    return cfg


def test_successive_halving_promotes_top_fraction() -> None:
    cfg = _make_config(trials=9, eta=3)

    seen: list[tuple[str, str, int]] = []

    # Fidelity-aware objective: score is just x (bigger is better).
    def objective_fidelity(
        params: dict[str, Any], start: str, end: str, windows: int, feed: str, bars_file: str | None
    ) -> TrialResult:
        _ = (feed, bars_file)
        seen.append((start, end, windows))
        x = int(params["x"])
        return TrialResult(
            trial_id=0,
            params=dict(params),
            sqn=0.0,
            sharpe=0.0,
            sortino=0.0,
            profit_factor=0.0,
            total_pnl=0.0,
            trades=1,
            win_rate=0.0,
            max_drawdown_pct=0.0,
            wfe=0.0,
            wfe_std=0.0,
            positive_days_ratio=0.0,
            regime_scores={},
            trailing_dd=0.0,
            daily_profit_max=0.0,
            daily_dd=0.0,
            time_gate_violations=0,
            overnight_positions=0,
            apex_compliant=True,
            score=float(x),
        )

    searcher = SuccessiveHalvingSearch(cfg, objective_fn_with_fidelity=objective_fidelity)
    results = searcher.search(lambda p: objective_fidelity(p, "", "", 1, "ticks", None))

    # With trials=9 and eta=3:
    # rung0 evaluates 9, promotes ceil(9/3)=3
    # rung1 evaluates 3
    assert len(results) == 12

    # Promoted configs should be evaluated twice (once per rung).
    xs = [int(r.params["x"]) for r in results]
    counts = Counter(xs)
    assert counts[8] == 2
    assert counts[7] == 2
    assert counts[6] == 2

    # Rung 0 uses the rolling window ending at train_end.
    # NOTE: 2020 is a leap year, so 30 days inclusive ending 2020-12-31 starts at 2020-12-02.
    assert ("2020-12-02", "2020-12-31", 1) in seen
    # Rung 1 uses full train window.
    assert ("2020-01-01", "2020-12-31", 3) in seen


def test_invalid_eta_rejected() -> None:
    cfg = _make_config(trials=10, eta=1)

    def objective_fidelity(
        params: dict[str, Any], start: str, end: str, windows: int, feed: str, bars_file: str | None
    ) -> TrialResult:
        _ = (params, start, end, windows, feed, bars_file)
        return TrialResult(
            trial_id=0,
            params={},
            sqn=0.0,
            sharpe=0.0,
            sortino=0.0,
            profit_factor=0.0,
            total_pnl=0.0,
            trades=0,
            win_rate=0.0,
            max_drawdown_pct=0.0,
            wfe=0.0,
            wfe_std=0.0,
            positive_days_ratio=0.0,
            regime_scores={},
            trailing_dd=0.0,
            daily_profit_max=0.0,
            daily_dd=0.0,
            time_gate_violations=0,
            overnight_positions=0,
            apex_compliant=True,
            score=0.0,
        )

    searcher = SuccessiveHalvingSearch(cfg, objective_fn_with_fidelity=objective_fidelity)
    with pytest.raises(ValueError, match="eta must be > 1"):
        searcher.search(lambda p: objective_fidelity(p, "", "", 1))


def _make_config_with_sampler(*, trials: int, eta: int, sampler: str) -> OptimizationConfig:
    """Create config with specified sampler."""
    cfg = OptimizationConfig()
    cfg.search = SearchConfig(
        mode="successive_halving",
        trials=trials,
        seed=42,
        successive_halving=SuccessiveHalvingConfig(
            enabled=True,
            eta=eta,
            window_days=(30, 0),
            wfa_windows=(1, 3),
            promotion_metric="score",
            sampler=sampler,
            mutate_between_rungs=False,
            mutate_prob=0.75,
        ),
    )
    cfg.parameters = [
        ParameterSpec(name="x", param_type="float", range=(0.0, 10.0), step=0.5),
        ParameterSpec(name="y", param_type="int", range=(1, 5), step=1),
        ParameterSpec(name="cat", param_type="categorical", choices=["a", "b"]),
    ]
    cfg.data = DataConfig(train_start="2020-01-01", train_end="2020-12-31")
    return cfg


def test_sobol_sampler_generates_valid_candidates() -> None:
    """Test that Sobol sampler generates valid parameter samples."""
    cfg = _make_config_with_sampler(trials=16, eta=4, sampler="sobol")

    seen_params: list[dict[str, Any]] = []

    def objective_fidelity(
        params: dict[str, Any], start: str, end: str, windows: int, feed: str, bars_file: str | None
    ) -> TrialResult:
        _ = (start, end, windows, feed, bars_file)
        seen_params.append(dict(params))
        return TrialResult(
            trial_id=0,
            params=dict(params),
            sqn=0.0,
            sharpe=0.0,
            sortino=0.0,
            profit_factor=0.0,
            total_pnl=0.0,
            trades=1,
            win_rate=0.0,
            max_drawdown_pct=0.0,
            wfe=0.0,
            wfe_std=0.0,
            positive_days_ratio=0.0,
            regime_scores={},
            trailing_dd=0.0,
            daily_profit_max=0.0,
            daily_dd=0.0,
            time_gate_violations=0,
            overnight_positions=0,
            apex_compliant=True,
            score=float(params["x"]) + float(params["y"]),
        )

    searcher = SuccessiveHalvingSearch(cfg, objective_fn_with_fidelity=objective_fidelity)
    results = searcher.search(lambda p: objective_fidelity(p, "", "", 1, "ticks", None))

    # With trials=16 and eta=4:
    # rung0 evaluates 16, promotes ceil(16/4)=4
    # rung1 evaluates 4
    assert len(results) == 20

    # All params should be within valid ranges
    for params in seen_params:
        assert 0.0 <= params["x"] <= 10.0
        assert params["x"] % 0.5 == 0.0 or abs(params["x"] % 0.5) < 0.01
        assert 1 <= params["y"] <= 5
        assert params["cat"] in ("a", "b")


def test_sobol_sampler_deterministic() -> None:
    """Test that Sobol sampler is deterministic with same seed."""
    cfg = _make_config_with_sampler(trials=8, eta=2, sampler="sobol")

    runs: list[list[dict[str, Any]]] = []

    for _ in range(2):
        seen: list[dict[str, Any]] = []

        def objective_fidelity(
            params: dict[str, Any],
            start: str,
            end: str,
            windows: int,
            feed: str,
            bars_file: str | None,
        ) -> TrialResult:
            _ = (start, end, windows, feed, bars_file)
            seen.append(dict(params))
            return TrialResult(
                trial_id=0,
                params=dict(params),
                sqn=0.0,
                sharpe=0.0,
                sortino=0.0,
                profit_factor=0.0,
                total_pnl=0.0,
                trades=1,
                win_rate=0.0,
                max_drawdown_pct=0.0,
                wfe=0.0,
                wfe_std=0.0,
                positive_days_ratio=0.0,
                regime_scores={},
                trailing_dd=0.0,
                daily_profit_max=0.0,
                daily_dd=0.0,
                time_gate_violations=0,
                overnight_positions=0,
                apex_compliant=True,
                score=float(params["x"]),
            )

        searcher = SuccessiveHalvingSearch(cfg, objective_fn_with_fidelity=objective_fidelity)
        searcher.search(lambda p: objective_fidelity(p, "", "", 1, "ticks", None))
        runs.append(seen)

    # First 8 params from each run should be identical (rung 0)
    for i in range(8):
        assert runs[0][i]["x"] == runs[1][i]["x"]
        assert runs[0][i]["y"] == runs[1][i]["y"]
        assert runs[0][i]["cat"] == runs[1][i]["cat"]
