"""
Mean-reversion signal generator (lightweight, backtest-safe).

Produces deterministic MeanRevert candidates using:
- Bollinger Bands (SMA +/- k*STD)
- RSI (Wilder smoothing)

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

from .trend_follow import TrendDirection, _ema, _kaufman_efficiency_ratio_series


class MeanRevertVariant(str, Enum):
    BB_RSI = "bb_rsi"


@dataclass(frozen=True, slots=True)
class MeanRevertCandidate:
    variant: MeanRevertVariant
    direction: TrendDirection
    score: float  # 0..100
    sl_distance: float  # price units
    reason: str
    meta: dict[str, Any]


def _sma(values: NDArray[np.floating[Any]], period: int) -> float:
    if period <= 0 or values.size < period:
        return float("nan")
    return float(np.mean(values[-period:]))


def _std(values: NDArray[np.floating[Any]], period: int) -> float:
    if period <= 1 or values.size < period:
        return float("nan")
    # population std (ddof=0) for determinism
    return float(np.std(values[-period:], ddof=0))


def _rsi_wilder(values: NDArray[np.floating[Any]], period: int) -> float:
    """Return RSI for the last element using Wilder's smoothing."""
    if period <= 1 or values.size < period + 1:
        return float("nan")

    diffs = np.diff(values.astype(np.float64, copy=False))
    gains = np.where(diffs > 0.0, diffs, 0.0)
    losses = np.where(diffs < 0.0, -diffs, 0.0)

    # Seed with simple average over first `period` diffs.
    avg_gain = float(np.mean(gains[:period]))
    avg_loss = float(np.mean(losses[:period]))

    # Wilder smoothing across remaining diffs.
    for i in range(period, gains.size):
        avg_gain = (avg_gain * (period - 1) + float(gains[i])) / float(period)
        avg_loss = (avg_loss * (period - 1) + float(losses[i])) / float(period)

    if avg_loss <= 0.0:
        return 100.0
    rs = avg_gain / avg_loss
    rsi = 100.0 - (100.0 / (1.0 + rs))
    return float(max(0.0, min(100.0, rsi)))


def generate_mean_revert_candidates(
    *,
    closes: NDArray[np.floating[Any]],
    highs: NDArray[np.floating[Any]],
    lows: NDArray[np.floating[Any]],
    tick_size: float,
    atr: float,
    atr_percentile: float,
    # thresholds
    bb_period: int = 20,
    bb_k: float = 2.0,
    rsi_period: int = 14,
    rsi_oversold: float = 30.0,
    rsi_overbought: float = 70.0,
    bb_touch_atr_frac: float = 0.15,
    max_atr_percentile: float = 70.0,
    # Optional ER (Kaufman efficiency ratio) regime gate.
    er_enabled: bool = False,
    er_period: int = 48,
    er_smoothing: int = 3,
    er_max: float = 0.30,
    min_score: float = 60.0,
) -> list[MeanRevertCandidate]:
    """Produce zero or more MeanRevert candidates for the latest closed bar."""

    min_bars = max(int(bb_period) + 2, int(rsi_period) + 2, 50)
    if bool(er_enabled):
        min_bars = max(min_bars, int(max(2, er_period)) + int(max(0, er_smoothing)) + 2)

    if closes.size < min_bars:
        return []

    if tick_size <= 0:
        tick_size = 0.01

    c = closes.astype(np.float64, copy=False)
    h = highs.astype(np.float64, copy=False)
    l = lows.astype(np.float64, copy=False)

    last_close = float(c[-1])
    last_high = float(h[-1])
    last_low = float(l[-1])

    # Optional ER gate: MR should avoid directional regimes.
    # If enabled and ER > er_max: do not generate candidates.
    er: float | None = None
    if bool(er_enabled):
        er_p = int(max(2, er_period))
        er_series = _kaufman_efficiency_ratio_series(c, er_p)
        if int(er_smoothing) > 1:
            er_series = _ema(er_series, int(er_smoothing))
        er = float(er_series[-1])
        if float(er) > float(er_max):
            return []

    mid = _sma(c, int(bb_period))
    sd = _std(c, int(bb_period))
    if not np.isfinite(mid) or not np.isfinite(sd):
        return []

    k = float(max(0.1, bb_k))
    upper = mid + k * sd
    lower = mid - k * sd

    rsi = _rsi_wilder(c, int(rsi_period))
    if not np.isfinite(rsi):
        return []

    atr_p = float(max(0.0, min(100.0, atr_percentile)))

    # Touch distance: allow slight overshoot beyond band, scaled by ATR.
    atr_val = float(max(0.0, atr))
    touch_dist = max(tick_size, atr_val * float(max(0.0, bb_touch_atr_frac)))

    candidates: list[MeanRevertCandidate] = []

    # Long: oversold + price near/below lower band.
    if (atr_p <= float(max_atr_percentile)) and (rsi <= float(rsi_oversold)):
        if last_low <= lower + touch_dist:
            # SL: below recent local low and below lower band.
            recent_low = float(np.min(l[-20:]))
            sl_level = min(recent_low, lower) - tick_size
            sl = max(0.0, last_close - sl_level)

            rsi_strength = (float(rsi_oversold) - float(rsi)) / max(1.0, float(rsi_oversold))
            band_excess = (lower - last_close) / max(tick_size, sd)
            score = 60.0 + min(20.0, max(0.0, band_excess) * 6.0) + min(15.0, max(0.0, rsi_strength) * 30.0)
            score -= min(10.0, max(0.0, atr_p - 40.0) * 0.25)
            score = float(max(0.0, min(99.0, score)))

            if score >= float(min_score) and sl > tick_size:
                candidates.append(
                    MeanRevertCandidate(
                        variant=MeanRevertVariant.BB_RSI,
                        direction=TrendDirection.LONG,
                        score=score,
                        sl_distance=sl,
                        reason="bb_lower_rsi_oversold",
                        meta={
                            "bb_mid": mid,
                            "bb_upper": upper,
                            "bb_lower": lower,
                            "rsi": rsi,
                            "atr_percentile": atr_p,
                            "er": er,
                        },
                    )
                )

    # Short: overbought + price near/above upper band.
    if (atr_p <= float(max_atr_percentile)) and (rsi >= float(rsi_overbought)):
        if last_high >= upper - touch_dist:
            recent_high = float(np.max(h[-20:]))
            sl_level = max(recent_high, upper) + tick_size
            sl = max(0.0, sl_level - last_close)

            rsi_strength = (float(rsi) - float(rsi_overbought)) / max(1.0, (100.0 - float(rsi_overbought)))
            band_excess = (last_close - upper) / max(tick_size, sd)
            score = 60.0 + min(20.0, max(0.0, band_excess) * 6.0) + min(15.0, max(0.0, rsi_strength) * 30.0)
            score -= min(10.0, max(0.0, atr_p - 40.0) * 0.25)
            score = float(max(0.0, min(99.0, score)))

            if score >= float(min_score) and sl > tick_size:
                candidates.append(
                    MeanRevertCandidate(
                        variant=MeanRevertVariant.BB_RSI,
                        direction=TrendDirection.SHORT,
                        score=score,
                        sl_distance=sl,
                        reason="bb_upper_rsi_overbought",
                        meta={
                            "bb_mid": mid,
                            "bb_upper": upper,
                            "bb_lower": lower,
                            "rsi": rsi,
                            "atr_percentile": atr_p,
                            "er": er,
                        },
                    )
                )

    return candidates
