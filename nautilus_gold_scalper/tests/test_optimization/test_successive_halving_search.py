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
    def objective_fidelity(params: dict[str, Any], start: str, end: str, windows: int) -> TrialResult:
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
            time_gate_violations=0,
            overnight_positions=0,
            apex_compliant=True,
            score=float(x),
        )

    searcher = SuccessiveHalvingSearch(cfg, objective_fn_with_fidelity=objective_fidelity)
    results = searcher.search(lambda p: objective_fidelity(p, "", "", 1))

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

    def objective_fidelity(params: dict[str, Any], start: str, end: str, windows: int) -> TrialResult:
        _ = (params, start, end, windows)
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
            time_gate_violations=0,
            overnight_positions=0,
            apex_compliant=True,
            score=0.0,
        )

    searcher = SuccessiveHalvingSearch(cfg, objective_fn_with_fidelity=objective_fidelity)
    with pytest.raises(ValueError, match="eta must be > 1"):
        searcher.search(lambda p: objective_fidelity(p, "", "", 1))
