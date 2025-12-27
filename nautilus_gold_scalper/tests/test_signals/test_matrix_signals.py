"""Matrix tests for signal modules.

These tests are contract/sanity checks over deterministic synthetic data.
They aim to catch import errors and basic invariant violations when we refactor.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any

import numpy as np
import pytest
from numpy.typing import NDArray

from src.signals.mean_revert import generate_mean_revert_candidates
from src.signals.trend_follow import compute_psar_series, generate_trend_follow_candidates


@dataclass(frozen=True)
class SignalCase:
    name: str
    n: int


def _make_prices(
    n: int,
    *,
    slope: float = 0.0,
    shock_at: int | None = None,
    shock_size: float = 0.0,
    seed: int = 2027,
) -> tuple[NDArray[np.floating[Any]], NDArray[np.floating[Any]], NDArray[np.floating[Any]]]:
    rng = np.random.default_rng(seed)
    base = 1900.0
    closes = base + np.cumsum(rng.normal(0.0, 0.5, n) + float(slope))

    if shock_at is not None and 0 <= int(shock_at) < n:
        closes[int(shock_at)] += float(shock_size)

    highs = closes + rng.uniform(0.2, 1.2, n)
    lows = closes - rng.uniform(0.2, 1.2, n)
    return highs.astype(float), lows.astype(float), closes.astype(float)


SIGNAL_CASES: list[SignalCase] = [
    SignalCase(name="small", n=60),
    SignalCase(name="medium", n=250),
]


@pytest.mark.parametrize("case", SIGNAL_CASES, ids=lambda c: c.name)  # type: ignore[untyped-decorator]
def test_matrix_trend_follow_psar_series(case: SignalCase) -> None:
    highs, lows, closes = _make_prices(case.n)

    psar = compute_psar_series(
        highs=highs,
        lows=lows,
        closes=closes,
    )

    assert psar is not None
    assert len(psar) == len(closes)
    assert np.all(np.isfinite(psar))


@pytest.mark.parametrize("case", SIGNAL_CASES, ids=lambda c: c.name)  # type: ignore[untyped-decorator]
def test_matrix_generate_trend_follow_candidates_contract(case: SignalCase) -> None:
    highs, lows, closes = _make_prices(max(case.n, 80))

    candidates = generate_trend_follow_candidates(
        closes=closes,
        highs=highs,
        lows=lows,
        tick_size=0.01,
        atr=2.0,
        atr_percentile=70.0,
        ma_type="EMA",
        ema_fast=10,
        ema_slow=30,
        pullback_lookback=10,
        breakout_lookback=20,
        min_score=0.0,
        donchian_breakout_enabled=True,
        swing_breakout_enabled=True,
    )

    assert isinstance(candidates, list)
    for c in candidates:
        assert 0.0 <= float(c.score) <= 100.0
        assert float(c.sl_distance) >= 0.0
        assert c.reason


def test_matrix_generate_trend_follow_candidates_forced_breakout() -> None:
    # Intentionally create a strong uptrend so at least one candidate is likely.
    highs, lows, closes = _make_prices(260, slope=0.25, seed=9001)

    candidates = generate_trend_follow_candidates(
        closes=closes,
        highs=highs,
        lows=lows,
        tick_size=0.01,
        atr=3.0,
        atr_percentile=95.0,
        ma_type="EMA",
        ema_fast=10,
        ema_slow=30,
        pullback_lookback=10,
        breakout_lookback=20,
        min_score=0.0,
        donchian_breakout_enabled=True,
        swing_breakout_enabled=False,
        sep_ticks_min=1.0,
    )

    assert isinstance(candidates, list)
    assert candidates, "Expected at least one trend-follow candidate in forced trend series"


def test_matrix_generate_trend_follow_candidates_er_gate_blocks() -> None:
    # Strongly directional series tends to produce high ER; when ER gate is strict, it should block.
    highs, lows, closes = _make_prices(260, slope=0.30, seed=9002)

    candidates = generate_trend_follow_candidates(
        closes=closes,
        highs=highs,
        lows=lows,
        tick_size=0.01,
        atr=3.0,
        atr_percentile=95.0,
        ma_type="EMA",
        ema_fast=10,
        ema_slow=30,
        pullback_lookback=10,
        breakout_lookback=20,
        min_score=0.0,
        donchian_breakout_enabled=True,
        swing_breakout_enabled=False,
        er_enabled=True,
        er_period=48,
        er_smoothing=3,
        er_min=0.999,  # unrealistically strict, should always block
    )

    assert candidates == []


def test_matrix_generate_trend_follow_candidates_invalid_ma_type_raises() -> None:
    highs, lows, closes = _make_prices(260, slope=0.10, seed=9003)

    with pytest.raises(ValueError):
        generate_trend_follow_candidates(
            closes=closes,
            highs=highs,
            lows=lows,
            tick_size=0.01,
            atr=2.0,
            atr_percentile=70.0,
            ma_type="NOPE",
        )


def test_matrix_mean_revert_contract_and_er_gate() -> None:
    # Build mostly-flat series, then force a sharp dip to create a likely LONG MR signal.
    n = 260
    highs, lows, closes = _make_prices(n, slope=0.0, seed=9101)

    # Force a dip on the last bar to help BB+RSI trigger.
    closes[-1] = float(closes[-2] - 15.0)
    highs[-1] = float(closes[-1] + 0.2)
    lows[-1] = float(closes[-1] - 0.2)

    cands = generate_mean_revert_candidates(
        closes=closes,
        highs=highs,
        lows=lows,
        tick_size=0.1,
        atr=5.0,
        atr_percentile=35.0,
        bb_period=20,
        rsi_period=14,
        rsi_oversold=40.0,
        max_atr_percentile=80.0,
        min_score=0.0,
    )

    assert isinstance(cands, list)
    for c in cands:
        assert 0.0 <= float(c.score) <= 100.0
        assert float(c.sl_distance) >= 0.0
        assert c.reason

    # If ER gate is unrealistically strict, it must block.
    blocked = generate_mean_revert_candidates(
        closes=closes,
        highs=highs,
        lows=lows,
        tick_size=0.1,
        atr=5.0,
        atr_percentile=35.0,
        bb_period=20,
        rsi_period=14,
        rsi_oversold=40.0,
        max_atr_percentile=80.0,
        er_enabled=True,
        er_period=48,
        er_smoothing=3,
        er_max=0.0,
        min_score=0.0,
    )

    assert blocked == []
