"""
Trend-follow signal generator (lightweight, backtest-safe).

Produces deterministic TrendFollow candidates:
- Pullback: dip/touch into EMA_fast within trend, then bounce in trend direction.
- Breakout: close breaks prior N-bar high/low (Donchian-style), gated by volatility.
- Swing breakout (optional): close breaks last confirmed swing high/low, gated by volatility.

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
    SWING_BREAKOUT = "trend_swing_breakout"


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


def _sma(values: NDArray[np.floating[Any]], period: int) -> NDArray[np.floating[Any]]:
    if period <= 1 or values.size == 0:
        return values

    n = int(values.size)
    p = int(period)
    v = values.astype(np.float64, copy=False)

    out = np.empty(n, dtype=np.float64)
    csum = np.cumsum(v, dtype=np.float64)
    for i in range(n):
        start = i - p + 1
        if start <= 0:
            total = float(csum[i])
            denom = float(i + 1)
        else:
            total = float(csum[i] - csum[start - 1])
            denom = float(p)
        out[i] = total / max(1.0, denom)
    return out


def _wma(values: NDArray[np.floating[Any]], period: int) -> NDArray[np.floating[Any]]:
    if period <= 1 or values.size == 0:
        return values

    n = int(values.size)
    p = int(period)
    v = values.astype(np.float64, copy=False)

    out = np.empty(n, dtype=np.float64)

    # Warm-up with growing window (1..p-1)
    for i in range(min(n, p - 1)):
        w = i + 1
        denom = float(w * (w + 1) / 2)
        num = 0.0
        for j in range(w):
            num += float(j + 1) * float(v[i - w + 1 + j])
        out[i] = num / max(1.0, denom)

    if n < p:
        return out

    # First full window (size p)
    denom_full = float(p * (p + 1) / 2)
    wsum = 0.0
    ssum = 0.0
    for j in range(p):
        x = float(v[j])
        ssum += x
        wsum += float(j + 1) * x
    out[p - 1] = wsum / max(1.0, denom_full)

    # Rolling update (O(n))
    for i in range(p, n):
        x_new = float(v[i])
        wsum = wsum - ssum + float(p) * x_new
        ssum = ssum - float(v[i - p]) + x_new
        out[i] = wsum / max(1.0, denom_full)

    return out


def _hma(values: NDArray[np.floating[Any]], period: int) -> NDArray[np.floating[Any]]:
    if period <= 1 or values.size == 0:
        return values

    p = int(period)
    half = max(1, p // 2)
    sqrt_p = max(1, int(np.sqrt(float(p))))

    v = values.astype(np.float64, copy=False)
    w_full = _wma(v, p)
    w_half = _wma(v, half)

    diff = 2.0 * w_half - w_full
    return _wma(diff, sqrt_p)


def compute_psar_series(
    *,
    highs: NDArray[np.floating[Any]],
    lows: NDArray[np.floating[Any]],
    closes: NDArray[np.floating[Any]] | None = None,
    af_step: float = 0.02,
    af_max: float = 0.20,
) -> NDArray[np.floating[Any]]:
    """Compute Parabolic SAR (Wilder) series on closed bars.

    Implementation notes:
    - Pure numpy, single-pass (O(n)).
    - Uses only historical highs/lows at each index (no look-ahead).
    - Returns a SAR value for each bar index.

    This is intended for *filtering* decisions using t-1 values in strategy logic.
    """
    h = highs.astype(np.float64, copy=False)
    l = lows.astype(np.float64, copy=False)
    n = int(h.size)
    out = np.zeros(n, dtype=np.float64)
    if n == 0:
        return out

    step = float(max(0.0, af_step))
    max_af = float(max(step, af_max))

    if closes is not None and int(closes.size) >= 2:
        c = closes.astype(np.float64, copy=False)
        is_long = bool(c[1] >= c[0])
    elif n >= 2:
        is_long = bool((h[1] + l[1]) >= (h[0] + l[0]))
    else:
        is_long = True

    af = step
    if is_long:
        ep = float(h[0])
        out[0] = float(l[0])
    else:
        ep = float(l[0])
        out[0] = float(h[0])

    for i in range(1, n):
        prev_sar = float(out[i - 1])
        sar = prev_sar + af * (ep - prev_sar)

        if is_long:
            # SAR cannot be above the prior lows.
            if i >= 2:
                sar = float(min(sar, float(l[i - 1]), float(l[i - 2])))
            else:
                sar = float(min(sar, float(l[i - 1])))

            # Reversal
            if float(l[i]) < sar:
                is_long = False
                sar = float(ep)
                ep = float(l[i])
                af = step
            else:
                # Update EP/AF
                if float(h[i]) > ep:
                    ep = float(h[i])
                    af = float(min(max_af, af + step))

        else:
            # SAR cannot be below the prior highs.
            if i >= 2:
                sar = float(max(sar, float(h[i - 1]), float(h[i - 2])))
            else:
                sar = float(max(sar, float(h[i - 1])))

            # Reversal
            if float(h[i]) > sar:
                is_long = True
                sar = float(ep)
                ep = float(h[i])
                af = step
            else:
                # Update EP/AF
                if float(l[i]) < ep:
                    ep = float(l[i])
                    af = float(min(max_af, af + step))

        out[i] = float(sar)

    return out


def _kaufman_efficiency_ratio_series(
    closes: NDArray[np.floating[Any]],
    period: int,
) -> NDArray[np.floating[Any]]:
    """Compute Kaufman Efficiency Ratio (ER) series.

    ER[t] = |price[t] - price[t-N]| / sum_{i=t-N+1..t} |price[i] - price[i-1]|

    The first `period` values are 0.0.
    ER is clipped to [0, 1].
    """
    n = int(period)
    c = closes.astype(np.float64, copy=False)
    out = np.zeros_like(c, dtype=np.float64)

    if n <= 1 or c.size < n + 1:
        return out

    absdiff = np.abs(np.diff(c))
    csum = np.concatenate([np.zeros(1, dtype=np.float64), np.cumsum(absdiff)])

    # For each index i in [n .. len(c)-1]:
    # change = |c[i] - c[i-n]|
    # volatility = sum(absdiff[i-n : i])
    change = np.abs(c[n:] - c[:-n])
    volatility = csum[n:] - csum[:-n]

    mask = volatility > 0.0
    er_vals = np.zeros_like(volatility, dtype=np.float64)
    er_vals[mask] = change[mask] / volatility[mask]
    er_vals = np.clip(er_vals, 0.0, 1.0)

    out[n:] = er_vals
    return out


def _find_last_confirmed_swings(
    *,
    highs: NDArray[np.floating[Any]],
    lows: NDArray[np.floating[Any]],
    strength: int,
    lookback_bars: int,
) -> tuple[tuple[int, float] | None, tuple[int, float] | None]:
    """Return (last_swing_high, last_swing_low) confirmed before the current bar.

    This uses delayed (causal) confirmation:
    - A swing at index `cand` is only confirmed once `strength` bars have elapsed.
    - At the current bar index `last`, we can confirm swings up to `last - strength`.

    Returns:
      - last_swing_high: (index, price) or None
      - last_swing_low: (index, price) or None
    """
    s = int(max(1, strength))
    n = int(highs.size)
    if n < (s * 2 + 1):
        return None, None

    last = n - 1
    last_confirmable = last - s
    if last_confirmable < s:
        return None, None

    lb = int(max(s * 2 + 1, lookback_bars))
    min_cand = max(s, last_confirmable - lb)

    last_high: tuple[int, float] | None = None
    last_low: tuple[int, float] | None = None

    # Mirror StructureAnalyzer's causal swing detection (with delayed confirmation).
    for i in range(s * 2, last + 1):
        cand = i - s
        if cand < min_cand:
            continue
        if cand > last_confirmable:
            break

        # Swing high
        is_swing_high = True
        for j in range(1, s + 1):
            if float(highs[cand]) <= float(highs[cand - j]) or float(highs[cand]) <= float(
                highs[cand + j]
            ):
                is_swing_high = False
                break
        if is_swing_high:
            last_high = (int(cand), float(highs[cand]))

        # Swing low
        is_swing_low = True
        for j in range(1, s + 1):
            if float(lows[cand]) >= float(lows[cand - j]) or float(lows[cand]) >= float(
                lows[cand + j]
            ):
                is_swing_low = False
                break
        if is_swing_low:
            last_low = (int(cand), float(lows[cand]))

    return last_high, last_low


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
    ma_type: str = "EMA",
    pullback_lookback: int = 10,
    breakout_lookback: int = 20,
    min_atr_percentile_breakout: float = 65.0,
    # Pullback strictness
    pullback_require_recross: bool = False,
    pullback_recross_lookback: int = 1,
    # Breakout tuning
    breakout_entry_buffer_atr_mult: float = 0.0,
    breakout_sl_buffer_atr_mult: float = 0.25,
    donchian_breakout_enabled: bool = True,
    swing_breakout_enabled: bool = False,
    swing_strength: int = 3,
    swing_lookback_bars: int = 120,
    # Optional ER (Kaufman efficiency ratio) regime gate.
    er_enabled: bool = False,
    er_period: int = 48,
    er_smoothing: int = 3,
    er_min: float = 0.30,
    min_score: float = 60.0,
    # CLI-sweepable params (Oracle/CRITIC sensitivity sweep)
    sep_ticks_min: float = 4.0,
    touch_dist_mult: float = 0.35,
) -> list[TrendFollowCandidate]:
    """
    Produce zero or more TrendFollow candidates for the latest closed bar.

    Inputs must include the current closed bar as the last element.
    """
    min_bars = max(ema_slow + 2, breakout_lookback + 2, pullback_lookback + 2)
    if bool(er_enabled):
        min_bars = max(min_bars, int(max(2, er_period)) + int(max(0, er_smoothing)) + 2)

    if closes.size < min_bars:
        return []
    if tick_size <= 0:
        tick_size = 0.01

    c = closes.astype(np.float64, copy=False)
    h = highs.astype(np.float64, copy=False)
    l = lows.astype(np.float64, copy=False)

    ma = str(ma_type or "EMA").strip().upper()
    if ma == "EMA":
        ema_f = _ema(c, ema_fast)
        ema_s = _ema(c, ema_slow)
    elif ma == "SMA":
        ema_f = _sma(c, ema_fast)
        ema_s = _sma(c, ema_slow)
    elif ma == "WMA":
        ema_f = _wma(c, ema_fast)
        ema_s = _wma(c, ema_slow)
    elif ma == "HMA":
        ema_f = _hma(c, ema_fast)
        ema_s = _hma(c, ema_slow)
    else:
        raise ValueError(f"Unknown ma_type={ma_type!r}. Expected one of: EMA, SMA, WMA, HMA")

    # Optional ER regime gate (Kaufman efficiency ratio).
    er: float | None = None
    if bool(er_enabled):
        er_p = int(max(2, er_period))
        er_series = _kaufman_efficiency_ratio_series(c, er_p)
        if int(er_smoothing) > 1:
            er_series = _ema(er_series, int(er_smoothing))
        er = float(er_series[-1])

    # Trend direction from EMA separation (simple, robust).
    sep = float(abs(ema_f[-1] - ema_s[-1]))
    sep_ticks = sep / tick_size
    is_up = ema_f[-1] > ema_s[-1]
    is_down = ema_f[-1] < ema_s[-1]

    # Normalize ATR percentile
    atr_p = float(max(0.0, min(100.0, atr_percentile)))

    # Optional ER gate.
    # If enabled and ER < er_min: do not generate candidates.
    if er is not None and float(er) < float(er_min):
        return []

    last_atr = float(max(0.0, atr))
    entry_buffer = float(max(tick_size, last_atr * float(max(0.0, breakout_entry_buffer_atr_mult))))
    sl_buffer = float(max(tick_size, last_atr * float(max(0.0, breakout_sl_buffer_atr_mult))))

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

    touch_dist = float(
        max(tick_size, min(last_atr * float(touch_dist_mult), last_atr or tick_size))
    )

    pb_recross_lb = int(max(1, pullback_recross_lookback))

    if is_up and sep_ticks >= float(sep_ticks_min):
        ema_ref = float(min(prev_ema_f, last_ema_f))
        touched = min(prev_low, last_low) <= ema_ref + touch_dist

        if bool(pullback_require_recross):
            recrossed = False
            for k in range(1, pb_recross_lb + 1):
                idx = -(k + 1)
                if float(c[idx]) <= float(ema_f[idx]):
                    recrossed = True
                    break
            bounced = last_close > last_ema_f and recrossed
        else:
            bounced = last_close > last_ema_f and (
                prev_close <= prev_ema_f or prev_low <= prev_ema_f
            )

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
                        meta={
                            "sep_ticks": sep_ticks,
                            "atr_percentile": atr_p,
                            "er": er,
                            "pullback_require_recross": bool(pullback_require_recross),
                            "pullback_recross_lookback": pb_recross_lb,
                        },
                    )
                )
    elif is_down and sep_ticks >= float(sep_ticks_min):
        ema_ref = float(max(prev_ema_f, last_ema_f))
        touched = max(prev_high_bar, last_high_bar) >= ema_ref - touch_dist

        if bool(pullback_require_recross):
            recrossed = False
            for k in range(1, pb_recross_lb + 1):
                idx = -(k + 1)
                if float(c[idx]) >= float(ema_f[idx]):
                    recrossed = True
                    break
            bounced = last_close < last_ema_f and recrossed
        else:
            bounced = last_close < last_ema_f and (
                prev_close >= prev_ema_f or prev_high_bar >= prev_ema_f
            )

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
                        meta={
                            "sep_ticks": sep_ticks,
                            "atr_percentile": atr_p,
                            "er": er,
                            "pullback_require_recross": bool(pullback_require_recross),
                            "pullback_recross_lookback": pb_recross_lb,
                        },
                    )
                )

    # --- Donchian breakout variant
    # Close breaks above/below previous N-bar high/low, with volatility not too low.
    if bool(donchian_breakout_enabled):
        bo_lb = int(max(5, breakout_lookback))
        prev_high = float(np.max(h[-(bo_lb + 1) : -1]))
        prev_low = float(np.min(l[-(bo_lb + 1) : -1]))

        if atr_p >= float(min_atr_percentile_breakout):
            if is_up and last_close > prev_high + entry_buffer:
                sl_level = prev_high - sl_buffer
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
                            meta={
                                "prev_high": prev_high,
                                "sep_ticks": sep_ticks,
                                "atr_percentile": atr_p,
                                "er": er,
                                "breakout_entry_buffer": entry_buffer,
                                "breakout_sl_buffer": sl_buffer,
                            },
                        )
                    )
            elif is_down and last_close < prev_low - entry_buffer:
                sl_level = prev_low + sl_buffer
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
                            meta={
                                "prev_low": prev_low,
                                "sep_ticks": sep_ticks,
                                "atr_percentile": atr_p,
                                "er": er,
                                "breakout_entry_buffer": entry_buffer,
                                "breakout_sl_buffer": sl_buffer,
                            },
                        )
                    )

    # --- Swing breakout variant (optional)
    if bool(swing_breakout_enabled) and atr_p >= float(min_atr_percentile_breakout):
        last_swing_high, last_swing_low = _find_last_confirmed_swings(
            highs=h,
            lows=l,
            strength=int(max(1, swing_strength)),
            lookback_bars=int(max(2, swing_lookback_bars)),
        )

        if last_swing_high is not None:
            swing_idx, swing_high = last_swing_high
            if is_up and last_close > float(swing_high) + entry_buffer:
                sl_level = float(swing_high) - sl_buffer
                sl = max(0.0, last_close - sl_level)
                score = 62.0 + min(20.0, sep_ticks * 1.2) + min(12.0, (atr_p - 50.0) * 0.25)
                score = float(min(99.0, score))
                if score >= float(min_score) and sl > tick_size:
                    candidates.append(
                        TrendFollowCandidate(
                            variant=TrendFollowVariant.SWING_BREAKOUT,
                            direction=TrendDirection.LONG,
                            score=score,
                            sl_distance=sl,
                            reason="swing_breakout_high",
                            meta={
                                "swing_high": float(swing_high),
                                "swing_high_idx": int(swing_idx),
                                "sep_ticks": sep_ticks,
                                "atr_percentile": atr_p,
                                "er": er,
                                "breakout_entry_buffer": entry_buffer,
                                "breakout_sl_buffer": sl_buffer,
                                "swing_strength": int(max(1, swing_strength)),
                            },
                        )
                    )

        if last_swing_low is not None:
            swing_idx, swing_low = last_swing_low
            if is_down and last_close < float(swing_low) - entry_buffer:
                sl_level = float(swing_low) + sl_buffer
                sl = max(0.0, sl_level - last_close)
                score = 62.0 + min(20.0, sep_ticks * 1.2) + min(12.0, (atr_p - 50.0) * 0.25)
                score = float(min(99.0, score))
                if score >= float(min_score) and sl > tick_size:
                    candidates.append(
                        TrendFollowCandidate(
                            variant=TrendFollowVariant.SWING_BREAKOUT,
                            direction=TrendDirection.SHORT,
                            score=score,
                            sl_distance=sl,
                            reason="swing_breakout_low",
                            meta={
                                "swing_low": float(swing_low),
                                "swing_low_idx": int(swing_idx),
                                "sep_ticks": sep_ticks,
                                "atr_percentile": atr_p,
                                "er": er,
                                "breakout_entry_buffer": entry_buffer,
                                "breakout_sl_buffer": sl_buffer,
                                "swing_strength": int(max(1, swing_strength)),
                            },
                        )
                    )

    return candidates
