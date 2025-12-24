"""
Trend-follow signal generator (lightweight, backtest-safe).

Produces deterministic TrendFollow candidates:
- Pullback: dip/touch into EMA_fast within trend, then bounce in trend direction.
- Breakout: close breaks prior N-bar high/low (Donchian-style), gated by volatility.

Design goals:
- No look-ahead: only uses current closed bar (last element) + prior bars.
- Minimal dependencies: numpy only.
- Output score is 0..100 to compare with confluence scores and execution thresholds.
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Any

import numpy as np
from numpy.typing import NDArray


class TrendFollowVariant(str, Enum):
    PULLBACK = "trend_pullback"
    BREAKOUT = "trend_breakout"


class TrendDirection(str, Enum):
    LONG = "long"
    SHORT = "short"


@dataclass(frozen=True, slots=True)
class TrendFollowCandidate:
    variant: TrendFollowVariant
    direction: TrendDirection
    score: float  # 0..100
    sl_distance: float  # price units
    reason: str
    meta: dict[str, Any]


def _ema(values: NDArray[np.floating[Any]], period: int) -> NDArray[np.floating[Any]]:
    if period <= 1 or values.size == 0:
        return values
    alpha = 2.0 / (period + 1.0)
    out = np.empty_like(values, dtype=np.float64)
    out[0] = float(values[0])
    for i in range(1, values.size):
        out[i] = alpha * float(values[i]) + (1.0 - alpha) * float(out[i - 1])
    return out


def generate_trend_follow_candidates(
    *,
    closes: NDArray[np.floating[Any]],
    highs: NDArray[np.floating[Any]],
    lows: NDArray[np.floating[Any]],
    tick_size: float,
    atr: float,
    atr_percentile: float,
    # thresholds
    ema_fast: int = 20,
    ema_slow: int = 50,
    pullback_lookback: int = 10,
    breakout_lookback: int = 20,
    min_atr_percentile_breakout: float = 65.0,
    min_score: float = 60.0,
) -> list[TrendFollowCandidate]:
    """
    Produce zero or more TrendFollow candidates for the latest closed bar.

    Inputs must include the current closed bar as the last element.
    """
    if closes.size < max(ema_slow + 2, breakout_lookback + 2, pullback_lookback + 2):
        return []
    if tick_size <= 0:
        tick_size = 0.01

    c = closes.astype(np.float64, copy=False)
    h = highs.astype(np.float64, copy=False)
    l = lows.astype(np.float64, copy=False)

    ema_f = _ema(c, ema_fast)
    ema_s = _ema(c, ema_slow)

    # Trend direction from EMA separation (simple, robust).
    sep = float(abs(ema_f[-1] - ema_s[-1]))
    sep_ticks = sep / tick_size
    is_up = ema_f[-1] > ema_s[-1]
    is_down = ema_f[-1] < ema_s[-1]

    # Normalize ATR percentile
    atr_p = float(max(0.0, min(100.0, atr_percentile)))

    candidates: list[TrendFollowCandidate] = []

    # --- Pullback variant
    # In an uptrend: wick touches/near EMA_fast then closes back above (bounce).
    pb_lb = int(max(3, pullback_lookback))
    recent_low = float(np.min(l[-pb_lb:]))
    recent_high = float(np.max(h[-pb_lb:]))
    last_close = float(c[-1])
    prev_close = float(c[-2])
    prev_ema_f = float(ema_f[-2])
    last_ema_f = float(ema_f[-1])
    prev_low = float(l[-2])
    last_low = float(l[-1])
    prev_high_bar = float(h[-2])
    last_high_bar = float(h[-1])

    touch_dist = float(max(tick_size, min(float(max(0.0, atr)) * 0.35, float(max(0.0, atr)) or tick_size)))

    if is_up and sep_ticks >= 4.0:
        ema_ref = float(min(prev_ema_f, last_ema_f))
        touched = min(prev_low, last_low) <= ema_ref + touch_dist
        bounced = last_close > last_ema_f and (prev_close <= prev_ema_f or prev_low <= prev_ema_f)
        if touched and bounced:
            sl = max(0.0, last_close - (recent_low - tick_size))
            score = 60.0 + min(25.0, sep_ticks * 1.5) + min(10.0, (atr_p - 40.0) * 0.2)
            score = float(min(99.0, score))
            if score >= float(min_score) and sl > tick_size:
                candidates.append(
                    TrendFollowCandidate(
                        variant=TrendFollowVariant.PULLBACK,
                        direction=TrendDirection.LONG,
                        score=score,
                        sl_distance=sl,
                        reason="pullback_bounce_ema",
                        meta={"sep_ticks": sep_ticks, "atr_percentile": atr_p},
                    )
                )
    elif is_down and sep_ticks >= 4.0:
        ema_ref = float(max(prev_ema_f, last_ema_f))
        touched = max(prev_high_bar, last_high_bar) >= ema_ref - touch_dist
        bounced = last_close < last_ema_f and (prev_close >= prev_ema_f or prev_high_bar >= prev_ema_f)
        if touched and bounced:
            sl = max(0.0, (recent_high + tick_size) - last_close)
            score = 60.0 + min(25.0, sep_ticks * 1.5) + min(10.0, (atr_p - 40.0) * 0.2)
            score = float(min(99.0, score))
            if score >= float(min_score) and sl > tick_size:
                candidates.append(
                    TrendFollowCandidate(
                        variant=TrendFollowVariant.PULLBACK,
                        direction=TrendDirection.SHORT,
                        score=score,
                        sl_distance=sl,
                        reason="pullback_reject_ema",
                        meta={"sep_ticks": sep_ticks, "atr_percentile": atr_p},
                    )
                )

    # --- Breakout variant
    # Close breaks above/below previous N-bar high/low, with volatility not too low.
    bo_lb = int(max(5, breakout_lookback))
    prev_high = float(np.max(h[-(bo_lb + 1) : -1]))
    prev_low = float(np.min(l[-(bo_lb + 1) : -1]))

    if atr_p >= float(min_atr_percentile_breakout):
        if is_up and last_close > prev_high + tick_size:
            sl_level = prev_high - max(tick_size, float(max(0.0, atr)) * 0.25)
            sl = max(0.0, last_close - sl_level)
            score = 62.0 + min(20.0, sep_ticks * 1.2) + min(12.0, (atr_p - 50.0) * 0.25)
            score = float(min(99.0, score))
            if score >= float(min_score) and sl > tick_size:
                candidates.append(
                    TrendFollowCandidate(
                        variant=TrendFollowVariant.BREAKOUT,
                        direction=TrendDirection.LONG,
                        score=score,
                        sl_distance=sl,
                        reason="breakout_n_high",
                        meta={"prev_high": prev_high, "sep_ticks": sep_ticks, "atr_percentile": atr_p},
                    )
                )
        elif is_down and last_close < prev_low - tick_size:
            sl_level = prev_low + max(tick_size, float(max(0.0, atr)) * 0.25)
            sl = max(0.0, sl_level - last_close)
            score = 62.0 + min(20.0, sep_ticks * 1.2) + min(12.0, (atr_p - 50.0) * 0.25)
            score = float(min(99.0, score))
            if score >= float(min_score) and sl > tick_size:
                candidates.append(
                    TrendFollowCandidate(
                        variant=TrendFollowVariant.BREAKOUT,
                        direction=TrendDirection.SHORT,
                        score=score,
                        sl_distance=sl,
                        reason="breakout_n_low",
                        meta={"prev_low": prev_low, "sep_ticks": sep_ticks, "atr_percentile": atr_p},
                    )
                )

    return candidates

