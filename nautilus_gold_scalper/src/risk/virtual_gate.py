from __future__ import annotations

from dataclasses import dataclass
from statistics import median
from typing import Sequence


@dataclass(frozen=True)
class VirtualGateInput:
    decision_ts_ns: int
    bar_ts_ns: Sequence[int]
    bar_highs: Sequence[float]
    bar_lows: Sequence[float]


@dataclass(frozen=True)
class VirtualGateResult:
    gate_ok: bool
    gate_reason: str | None = None
    gate_score: float | None = None


class VirtualGate:
    def __init__(
        self,
        *,
        lookback_bars: int = 20,
        range_spike_multiplier: float = 3.0,
    ) -> None:
        if lookback_bars <= 1:
            raise ValueError("lookback_bars must be > 1")
        if range_spike_multiplier <= 0.0:
            raise ValueError("range_spike_multiplier must be > 0")
        self._lookback_bars = int(lookback_bars)
        self._range_spike_multiplier = float(range_spike_multiplier)

    def evaluate(
        self,
        *,
        decision_ts_ns: int,
        bar_ts_ns: Sequence[int],
        bar_highs: Sequence[float],
        bar_lows: Sequence[float],
    ) -> VirtualGateResult:
        if decision_ts_ns <= 0:
            return VirtualGateResult(gate_ok=False, gate_reason="invalid_decision_ts")

        if not bar_ts_ns or not bar_highs or not bar_lows:
            return VirtualGateResult(gate_ok=False, gate_reason="missing_inputs")
        if not (len(bar_ts_ns) == len(bar_highs) == len(bar_lows)):
            return VirtualGateResult(gate_ok=False, gate_reason="length_mismatch")

        if len(bar_ts_ns) < self._lookback_bars:
            return VirtualGateResult(gate_ok=False, gate_reason="insufficient_history")

        bar_ts_ns_lookback = bar_ts_ns[-self._lookback_bars :]
        bar_highs_lookback = bar_highs[-self._lookback_bars :]
        bar_lows_lookback = bar_lows[-self._lookback_bars :]

        for ts in bar_ts_ns_lookback:
            if int(ts) >= int(decision_ts_ns):
                return VirtualGateResult(gate_ok=False, gate_reason="temporal_violation")

        ranges: list[float] = []
        for high, low in zip(bar_highs_lookback, bar_lows_lookback, strict=True):
            ranges.append(max(0.0, float(high) - float(low)))

        median_range = float(median(ranges))
        last_range = float(ranges[-1])

        if median_range <= 0.0:
            return VirtualGateResult(gate_ok=False, gate_reason="zero_median_range")

        ratio = last_range / median_range
        if ratio > self._range_spike_multiplier:
            score = max(0.0, min(1.0, self._range_spike_multiplier / ratio))
            return VirtualGateResult(gate_ok=False, gate_reason="range_spike", gate_score=score)

        score_ok = max(0.0, min(1.0, 1.0 - (ratio / self._range_spike_multiplier)))
        return VirtualGateResult(gate_ok=True, gate_reason=None, gate_score=score_ok)
