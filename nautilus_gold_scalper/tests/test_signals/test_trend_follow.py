import os
import sys

import numpy as np

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..")))

from nautilus_gold_scalper.src.signals.trend_follow import (
    TrendDirection,
    TrendFollowVariant,
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

