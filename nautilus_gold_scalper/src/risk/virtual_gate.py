from __future__ import annotations

from collections.abc import Sequence
from dataclasses import dataclass
from statistics import median


def _clamp01(value: float) -> float:
    if value <= 0.0:
        return 0.0
    if value >= 1.0:
        return 1.0
    return float(value)


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
    """Entry-only virtual gate (bar-only, deterministic, anti-lookahead).

    This gate is intentionally simple and timestamp-validated:
    - Consumes completed bars only.
    - Rejects any input bar with ts >= decision_ts_ns.
    - Detects single-bar range spikes and multi-bar turbulence clusters.

    Notes:
    - This is a *tradability* filter (microstructure/volatility health), not a directional signal.
    - All calculations are O(N) over lookback and avoid external state.
    """

    def __init__(
        self,
        *,
        lookback_bars: int = 20,
        range_spike_multiplier: float = 3.0,
        cluster_spike_multiplier: float = 2.5,
        cluster_max_fraction: float = 0.30,
        fail_open_on_insufficient_history: bool = False,
    ) -> None:
        if lookback_bars <= 1:
            raise ValueError("lookback_bars must be > 1")
        if range_spike_multiplier <= 1.0:
            raise ValueError("range_spike_multiplier must be > 1")
        if cluster_spike_multiplier <= 1.0:
            raise ValueError("cluster_spike_multiplier must be > 1")
        if not (0.0 <= float(cluster_max_fraction) <= 1.0):
            raise ValueError("cluster_max_fraction must be in [0, 1]")

        self._lookback_bars = int(lookback_bars)
        self._range_spike_multiplier = float(range_spike_multiplier)
        self._cluster_spike_multiplier = float(cluster_spike_multiplier)
        self._cluster_max_fraction = float(cluster_max_fraction)
        self._fail_open_on_insufficient_history = bool(fail_open_on_insufficient_history)

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
            if self._fail_open_on_insufficient_history:
                return VirtualGateResult(gate_ok=True)
            return VirtualGateResult(gate_ok=False, gate_reason="insufficient_history")

        end = len(bar_ts_ns)
        start = end - self._lookback_bars
        if start < 0:
            if self._fail_open_on_insufficient_history:
                return VirtualGateResult(gate_ok=True)
            return VirtualGateResult(gate_ok=False, gate_reason="insufficient_history")

        # Sanity: we must have at least 2 bars for pairwise checks.
        if (end - start) < 2:
            if self._fail_open_on_insufficient_history:
                return VirtualGateResult(gate_ok=True)
            return VirtualGateResult(gate_ok=False, gate_reason="insufficient_history")

        # Anti-lookahead: input bars must be completed before the decision timestamp.
        decision_ts_ns_i = int(decision_ts_ns)
        for i in range(start, end):
            if int(bar_ts_ns[i]) >= decision_ts_ns_i:
                return VirtualGateResult(gate_ok=False, gate_reason="temporal_violation")

        # Feed sanity: ensure strictly increasing timestamps.
        prev_ts_i = int(bar_ts_ns[start])
        for i in range(start + 1, end):
            ts_i = int(bar_ts_ns[i])
            if ts_i <= prev_ts_i:
                return VirtualGateResult(gate_ok=False, gate_reason="non_monotonic_ts")
            prev_ts_i = ts_i

        ranges: list[float] = []
        for i in range(start, end):
            h = float(bar_highs[i])
            l = float(bar_lows[i])
            if h < l:
                return VirtualGateResult(gate_ok=False, gate_reason="invalid_bar_range")
            ranges.append(h - l)

        median_range = float(median(ranges))
        if median_range <= 0.0:
            return VirtualGateResult(gate_ok=False, gate_reason="zero_median_range")

        last_range = float(ranges[-1])
        ratio = last_range / median_range

        # Primary block: single-bar volatility spike.
        if ratio > self._range_spike_multiplier:
            return VirtualGateResult(gate_ok=False, gate_reason="range_spike", gate_score=0.0)

        # Secondary block: multi-bar turbulence cluster.
        spike_count = 0
        for r in ranges:
            if (float(r) / median_range) > self._cluster_spike_multiplier:
                spike_count += 1
        spike_frac = spike_count / float(self._lookback_bars)
        if self._cluster_max_fraction <= 0.0:
            if spike_count > 0:
                return VirtualGateResult(
                    gate_ok=False, gate_reason="turbulence_cluster", gate_score=0.0
                )
            score_cluster = 1.0
        else:
            score_cluster = _clamp01(1.0 - (spike_frac / self._cluster_max_fraction))
            if spike_frac > self._cluster_max_fraction:
                return VirtualGateResult(
                    gate_ok=False, gate_reason="turbulence_cluster", gate_score=score_cluster
                )

        # Informational score (not used for sizing by default).
        if ratio <= 1.0:
            score_spike = 1.0
        else:
            score_spike = _clamp01(1.0 - ((ratio - 1.0) / (self._range_spike_multiplier - 1.0)))

        score = min(float(score_spike), float(score_cluster))
        return VirtualGateResult(gate_ok=True, gate_score=score)
