import os
import sys

import numpy as np

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..")))

from nautilus_gold_scalper.src.signals.mean_revert import generate_mean_revert_candidates
from nautilus_gold_scalper.src.signals.trend_follow import TrendDirection


def test_mean_revert_long_candidate_generated() -> None:
    # Mostly flat series -> low std -> BB tight, then sharp dip -> below lower band.
    n = 120
    closes = np.full(n, 2000.0, dtype=np.float64)
    highs = closes + 0.2
    lows = closes - 0.2

    # Create a sequence of losses to push RSI low.
    for i in range(n - 20, n - 1):
        closes[i] = closes[i - 1] - 1.0
        highs[i] = closes[i] + 0.2
        lows[i] = closes[i] - 0.2

    # Last bar overshoots lower band.
    closes[-1] = closes[-2] - 15.0
    highs[-1] = closes[-1] + 0.2
    lows[-1] = closes[-1] - 0.2

    cands = generate_mean_revert_candidates(
        closes=closes,
        highs=highs,
        lows=lows,
        tick_size=0.1,
        atr=5.0,
        atr_percentile=40.0,
        bb_period=20,
        bb_k=2.0,
        rsi_period=14,
        rsi_oversold=35.0,
        rsi_overbought=65.0,
        max_atr_percentile=80.0,
        min_score=60.0,
    )

    assert any(c.direction == TrendDirection.LONG for c in cands)


def test_mean_revert_short_candidate_generated() -> None:
    # Mostly flat series -> low std -> BB tight, then sharp spike -> above upper band.
    n = 120
    closes = np.full(n, 2100.0, dtype=np.float64)
    highs = closes + 0.2
    lows = closes - 0.2

    # Create a sequence of gains to push RSI high.
    for i in range(n - 20, n - 1):
        closes[i] = closes[i - 1] + 1.0
        highs[i] = closes[i] + 0.2
        lows[i] = closes[i] - 0.2

    closes[-1] = closes[-2] + 15.0
    highs[-1] = closes[-1] + 0.2
    lows[-1] = closes[-1] - 0.2

    cands = generate_mean_revert_candidates(
        closes=closes,
        highs=highs,
        lows=lows,
        tick_size=0.1,
        atr=5.0,
        atr_percentile=35.0,
        bb_period=20,
        bb_k=2.0,
        rsi_period=14,
        rsi_oversold=35.0,
        rsi_overbought=65.0,
        max_atr_percentile=80.0,
        min_score=60.0,
    )

    assert any(c.direction == TrendDirection.SHORT for c in cands)


def test_mean_revert_insufficient_history_returns_empty() -> None:
    closes = np.array([2000.0] * 10, dtype=np.float64)
    highs = closes + 0.1
    lows = closes - 0.1

    cands = generate_mean_revert_candidates(
        closes=closes,
        highs=highs,
        lows=lows,
        tick_size=0.1,
        atr=1.0,
        atr_percentile=30.0,
        bb_period=20,
        rsi_period=14,
    )

    assert cands == []
