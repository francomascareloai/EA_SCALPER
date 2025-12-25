import os
import sys

import numpy as np

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..")))

from nautilus_gold_scalper.src.signals.trend_follow import (
    TrendDirection,
    TrendFollowVariant,
    compute_psar_series,
    generate_trend_follow_candidates,
)


def test_trend_follow_breakout_long_candidate_generated() -> None:
    n = 200
    base = np.linspace(2000.0, 2020.0, n, dtype=np.float64)
    closes = base.copy()
    highs = closes + 0.2
    lows = closes - 0.2

    # Force a clear breakout on the last bar (above previous highs).
    highs[-1] = float(np.max(highs[:-1]) + 2.0)
    closes[-1] = highs[-1] - 0.1

    cands = generate_trend_follow_candidates(
        closes=closes,
        highs=highs,
        lows=lows,
        tick_size=0.1,
        atr=1.0,
        atr_percentile=80.0,
        min_score=60.0,
    )
    assert any(c.variant == TrendFollowVariant.BREAKOUT and c.direction == TrendDirection.LONG for c in cands)


def test_trend_follow_er_gate_blocks_candidates_when_low() -> None:
    n = 200
    # Choppy-ish series: alternating up/down to keep ER low.
    closes = 2000.0 + np.where(np.arange(n) % 2 == 0, 0.5, -0.5).astype(np.float64)
    highs = closes + 0.2
    lows = closes - 0.2

    # Even with high ATR percentile, ER gate should block.
    cands = generate_trend_follow_candidates(
        closes=closes,
        highs=highs,
        lows=lows,
        tick_size=0.1,
        atr=2.0,
        atr_percentile=90.0,
        breakout_lookback=20,
        er_enabled=True,
        er_period=48,
        er_smoothing=3,
        er_min=0.60,
        min_score=60.0,
    )
    assert cands == []


def test_trend_follow_pullback_long_candidate_generated() -> None:
    n = 240
    closes = np.linspace(2500.0, 2550.0, n, dtype=np.float64)
    highs = closes + 0.2
    lows = closes - 0.2

    # Create a pullback wick-touch on the prev bar, then a bounce close on the last bar.
    closes[-2] = closes[-3] - 2.0
    highs[-2] = closes[-2] + 0.2
    lows[-2] = closes[-2] - 4.0  # wick deep enough to touch EMA_fast area

    closes[-1] = closes[-3] + 0.5
    highs[-1] = closes[-1] + 0.2
    lows[-1] = closes[-1] - 0.2

    cands = generate_trend_follow_candidates(
        closes=closes,
        highs=highs,
        lows=lows,
        tick_size=0.1,
        atr=2.0,
        atr_percentile=70.0,
        min_score=60.0,
    )
    assert any(c.variant == TrendFollowVariant.PULLBACK and c.direction == TrendDirection.LONG for c in cands)

    cands_sma = generate_trend_follow_candidates(
        closes=closes,
        highs=highs,
        lows=lows,
        tick_size=0.1,
        atr=2.0,
        atr_percentile=70.0,
        ma_type="SMA",
        min_score=60.0,
    )
    assert any(c.variant == TrendFollowVariant.PULLBACK and c.direction == TrendDirection.LONG for c in cands_sma)


def test_trend_follow_pullback_recross_strict_blocks_when_no_recross() -> None:
    n = 200
    closes = np.linspace(2500.0, 2520.0, n, dtype=np.float64)
    highs = closes + 0.2
    lows = closes - 0.2

    # Wick touches near EMA_fast, but closes stay above EMA (no recross in recent bars).
    lows[-2] = closes[-2] - 5.0
    closes[-1] = closes[-2] + 0.5

    cands = generate_trend_follow_candidates(
        closes=closes,
        highs=highs,
        lows=lows,
        tick_size=0.1,
        atr=2.0,
        atr_percentile=70.0,
        ema_fast=10,
        ema_slow=20,
        pullback_require_recross=True,
        pullback_recross_lookback=5,
        min_score=60.0,
    )
    assert not any(c.variant == TrendFollowVariant.PULLBACK for c in cands)


def test_trend_follow_swing_breakout_long_candidate_generated() -> None:
    n = 120
    base = np.linspace(2000.0, 2020.0, n, dtype=np.float64)
    closes = base.copy()
    highs = closes + 0.2
    lows = closes - 0.2

    # Create a confirmed swing high, then break above it on the last bar.
    # Using swing_strength=3, a swing at index 80 is confirmed once we have bars through 83.
    swing_idx = 80
    highs[swing_idx] = float(np.max(highs) + 5.0)
    closes[swing_idx] = highs[swing_idx] - 0.1
    for j in range(1, 4):
        highs[swing_idx + j] = closes[swing_idx + j] + 0.2
        closes[swing_idx + j] = closes[swing_idx] - 3.0
        lows[swing_idx + j] = closes[swing_idx + j] - 0.2

    # Now break above the swing high at the end.
    highs[-1] = float(highs[swing_idx] + 2.0)
    closes[-1] = highs[-1] - 0.1

    cands = generate_trend_follow_candidates(
        closes=closes,
        highs=highs,
        lows=lows,
        tick_size=0.1,
        atr=2.0,
        atr_percentile=80.0,
        ema_fast=10,
        ema_slow=20,
        sep_ticks_min=1.0,
        donchian_breakout_enabled=False,
        swing_breakout_enabled=True,
        swing_strength=3,
        swing_lookback_bars=120,
        min_score=60.0,
    )
    assert any(c.variant == TrendFollowVariant.SWING_BREAKOUT and c.direction == TrendDirection.LONG for c in cands)


def test_psar_series_basic_shape() -> None:
    n = 50
    closes = np.linspace(100.0, 150.0, n, dtype=np.float64)
    highs = closes + 1.0
    lows = closes - 1.0

    sar = compute_psar_series(highs=highs, lows=lows, closes=closes, af_step=0.02, af_max=0.2)

    assert sar.shape == (n,)
    assert np.isfinite(sar).all()

