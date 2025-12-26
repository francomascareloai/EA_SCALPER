"""Tests for Grid Search strategy."""

from typing import Any

import pytest

from src.optimization.config import OptimizationConfig, ParameterSpec, SearchConfig
from src.optimization.search.base import TrialResult
from src.optimization.search.grid import GridSearch, estimate_grid_size


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
            daily_dd=1.0,
            time_gate_violations=0,
            overnight_positions=0,
            apex_compliant=True,
            score=0.8,
        )

    return _objective


def test_grid_size_estimation():
    # Setup parameters
    params = [
        ParameterSpec(name="p1", param_type="int", range=(1, 3), step=1),  # 3 values: 1, 2, 3
        ParameterSpec(
            name="p2", param_type="float", range=(0.0, 1.0), step=0.5
        ),  # 3 values: 0.0, 0.5, 1.0
        ParameterSpec(name="p3", param_type="categorical", choices=["a", "b"]),  # 2 values
    ]

    # Grid size = 3 * 3 * 2 = 18
    assert estimate_grid_size(params) == 18


def test_grid_search_execution(mock_objective_fn):
    # Config with small grid
    config = OptimizationConfig(
        search=SearchConfig(mode="grid", max_grid_size=100),
        parameters=[
            ParameterSpec(name="x", param_type="int", range=(1, 2), step=1),  # 2
            ParameterSpec(name="y", param_type="categorical", choices=["A", "B"]),  # 2
        ],
    )

    searcher = GridSearch(config)
    results = searcher.search(mock_objective_fn)

    # Should have 4 trials (2 * 2)
    assert len(results) == 4

    # Check if we covered all combinations
    combinations = set()
    for r in results:
        combinations.add((r.params["x"], r.params["y"]))

    expected = {(1, "A"), (1, "B"), (2, "A"), (2, "B")}
    assert combinations == expected


def test_max_grid_size_limit(mock_objective_fn):
    # Config that exceeds limit
    config = OptimizationConfig(
        search=SearchConfig(mode="grid", max_grid_size=5),
        parameters=[
            ParameterSpec(name="x", param_type="int", range=(1, 10), step=1),  # 10 values
        ],
    )

    searcher = GridSearch(config)

    with pytest.raises(ValueError, match="exceeds max_grid_size"):
        searcher.search(mock_objective_fn)
