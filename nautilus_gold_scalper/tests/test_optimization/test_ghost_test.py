from __future__ import annotations

import pandas as pd

from src.optimization.stress.ghost_test import run_ghost_test


def test_ghost_test_runs_and_returns_fields() -> None:
    trades_df = pd.DataFrame({"timestamp": pd.date_range("2024-01-01", periods=50, freq="D"), "pnl": [1.0] * 25 + [-0.5] * 25})

    res = run_ghost_test(trades_df, sims=50, seed=123, block_size=5)

    assert res.sims == 50
    assert isinstance(res.sharpe_full, float)
    assert isinstance(res.sharpe_baseline_mean, float)
    assert isinstance(res.sharpe_delta, float)
    assert 0.0 <= res.p_value <= 1.0


def test_ghost_test_requires_pnl_column() -> None:
    trades_df = pd.DataFrame({"timestamp": pd.date_range("2024-01-01", periods=5, freq="D"), "x": [1, 2, 3, 4, 5]})

    try:
        run_ghost_test(trades_df, sims=10, seed=1)
    except ValueError as e:
        assert "missing required column" in str(e)
    else:
        raise AssertionError("Expected ValueError")
