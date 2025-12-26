"""Tests for Random Search strategy."""

from typing import Any

import pytest

from src.optimization.config import OptimizationConfig, ParameterSpec, SearchConfig
from src.optimization.search.base import TrialResult
from src.optimization.search.random import RandomSearch


@pytest.fixture
def mock_objective_fn():
    def _objective(params: dict[str, Any]) -> TrialResult:
        return TrialResult(
            trial_id=0,
            params=params,
            sqn=2.0,
            sharpe=1.5,
            sortino=2.0,
            profit_factor=1.5,
            total_pnl=1000.0,
            trades=100,
            win_rate=0.6,
            max_drawdown_pct=2.0,
            wfe=0.8,
            wfe_std=0.1,
            positive_days_ratio=0.6,
            regime_scores={},
            trailing_dd=1.0,
            daily_profit_max=10.0,
            time_gate_violations=0,
            overnight_positions=0,
            apex_compliant=True,
            score=0.8,
        )

    return _objective


def test_random_search_samples_count(mock_objective_fn):
    n_samples = 20
    config = OptimizationConfig(
        search=SearchConfig(mode="random", n_samples=n_samples, seed=42),
        parameters=[
            ParameterSpec(name="x", param_type="float", range=(0.0, 1.0)),
        ],
    )

    searcher = RandomSearch(config)
    results = searcher.search(mock_objective_fn)

    assert len(results) == n_samples
    assert results[0].trial_id == 0
    assert results[-1].trial_id == n_samples - 1


def test_stratified_sampling_property(mock_objective_fn):
    # Test if samples are stratified (LHS property)
    # We sample 10 points in [0, 10]. In LHS, we expect roughly one point per unit interval.
    # Since we add shuffle and random uniform, it's not perfect grid, but better than pure random.

    n_samples = 10
    config = OptimizationConfig(
        search=SearchConfig(mode="random", n_samples=n_samples, seed=42),
        parameters=[
            ParameterSpec(name="x", param_type="float", range=(0.0, 10.0)),
        ],
    )

    searcher = RandomSearch(config)
    results = searcher.search(mock_objective_fn)

    values = sorted([r.params["x"] for r in results])

    # Check bounds
    assert min(values) >= 0.0
    assert max(values) <= 10.0

    # Check spread: simplistic check, std dev of differences should be low for perfectly stratified
    # but here we just ensure uniqueness and range coverage
    assert len(set(values)) == n_samples  # all unique (highly likely for floats)


def test_random_search_reproducibility():
    config = OptimizationConfig(
        search=SearchConfig(mode="random", n_samples=10, seed=42),
        parameters=[
            ParameterSpec(name="x", param_type="float", range=(0.0, 1.0)),
            ParameterSpec(name="cat", param_type="categorical", choices=["A", "B", "C"]),
        ],
    )

    params1 = list(RandomSearch(config).iter_params())[:10]
    params2 = list(RandomSearch(config).iter_params())[:10]

    assert params1 == params2


def test_categorical_balancing(mock_objective_fn):
    # 3 choices, 30 samples -> expect exactly 10 of each
    config = OptimizationConfig(
        search=SearchConfig(mode="random", n_samples=30, seed=42),
        parameters=[
            ParameterSpec(name="cat", param_type="categorical", choices=["A", "B", "C"]),
        ],
    )

    searcher = RandomSearch(config)
    results = searcher.search(mock_objective_fn)

    counts = {"A": 0, "B": 0, "C": 0}
    for r in results:
        counts[r.params["cat"]] += 1

    assert counts["A"] == 10
    assert counts["B"] == 10
    assert counts["C"] == 10
