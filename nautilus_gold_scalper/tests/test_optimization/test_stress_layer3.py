from __future__ import annotations

import pandas as pd

from src.optimization.stress.degradation import compute_degradation_survived
from src.optimization.stress.monte_carlo_dd import compute_mc_drawdown_percentiles_from_trades


def test_compute_mc_drawdown_percentiles_from_trades_basic_bounds() -> None:
    trades_df = pd.DataFrame(
        {
            "timestamp": pd.date_range("2024-01-01", periods=8, freq="D"),
            "pnl": [10.0, -5.0, 8.0, -4.0, 12.0, -6.0, 7.0, -3.0],
        }
    )

    res = compute_mc_drawdown_percentiles_from_trades(
        trades_df,
        start_equity=100.0,
        simulations=200,
        seed=123,
        block_bootstrap=True,
        block_size="auto",
    )

    assert 0.0 <= res.mc_95_dd <= 100.0
    assert 0.0 <= res.mc_99_dd <= 100.0
    assert res.mc_99_dd >= res.mc_95_dd


def test_compute_degradation_survived_returns_rates() -> None:
    trades_df = pd.DataFrame(
        {
            "timestamp": pd.date_range("2024-01-01", periods=6, freq="D"),
            "pnl": [10.0, -5.0, 10.0, -5.0, 10.0, -5.0],
        }
    )

    survived = compute_degradation_survived(
        trades_df,
        start_equity=100.0,
        rates=[0.0, 0.2, 0.5],
        dd_limit_pct=50.0,
    )

    assert 0.0 in survived
    assert all(0.0 <= r < 1.0 for r in survived)
