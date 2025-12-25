from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime

from ..signals.news_calendar import NewsWindow
from .exposure_caps import ExposureCaps
from .news_guard import NewsGuard
from .volatility_spacing import VolatilitySpacing
from .virtual_gate import VirtualGate, VirtualGateInput

def _clamp01(value: float) -> float:
    if value <= 0.0:
        return 0.0
    if value >= 1.0:
        return 1.0
    return float(value)


@dataclass(frozen=True)
class RiskDecision:
    """Immutable, strategy-consumable risk decision.

    Semantics:
    - `must_flatten` wins globally (if True, `can_open_new` must be False).
    - `can_open_new` applies only to *new entries*.
    - `size_factor` applies only to *new entry sizing* (clamped to [0, 1]).
    """

    can_open_new: bool = True
    size_factor: float = 1.0
    must_flatten: bool = False
    reasons: tuple[str, ...] = ()

    def __post_init__(self) -> None:
        object.__setattr__(self, "size_factor", _clamp01(float(self.size_factor)))
        if self.must_flatten and self.can_open_new:
            object.__setattr__(self, "can_open_new", False)


class UnifiedRiskPolicy:
    """Single policy surface consumed by strategies (entry-only gates).

    Semantics:
    - `must_flatten` wins globally (but this policy does not execute flattening).
    - Entry-only gates compose with “most restrictive wins”.
    - `size_factor` is an entry sizing multiplier in [0, 1].
    """

    def __init__(
        self,
        *,
        exposure_caps: ExposureCaps | None = None,
        news_guard: NewsGuard | None = None,
        volatility_spacing: VolatilitySpacing | None = None,
        virtual_gate: VirtualGate | None = None,
    ) -> None:
        self._exposure_caps = exposure_caps
        self._news_guard = news_guard
        self._volatility_spacing = volatility_spacing
        self._virtual_gate = virtual_gate

    def evaluate_entry(
        self,
        *,
        time_gate_ok: bool = True,
        blocked_today: bool = False,
        prop_firm_ok: bool = True,
        circuit_ok: bool = True,
        must_flatten: bool = False,
        # Gate inputs (optional, deterministic)
        open_positions_count: int | None = None,
        open_instruments_count: int | None = None,
        news_window: NewsWindow | None = None,
        now_utc: datetime | None = None,
        last_entry_ts_ns: int | None = None,
        now_ts_ns: int | None = None,
        volatility: float | None = None,
        virtual_gate_input: VirtualGateInput | None = None,
        base_size_factor: float = 1.0,
    ) -> RiskDecision:
        reasons: list[str] = []

        if must_flatten:
            reasons.append("must_flatten")

        if blocked_today:
            reasons.append("blocked_today")

        if not time_gate_ok:
            reasons.append("time_gate_entry")

        if not prop_firm_ok:
            reasons.append("prop_firm")

        if not circuit_ok:
            reasons.append("circuit_breaker")

        # Exposure caps (entry-only)
        if self._exposure_caps is not None and open_positions_count is not None and open_instruments_count is not None:
            cap = self._exposure_caps.evaluate(
                open_positions_count=int(open_positions_count),
                open_instruments_count=int(open_instruments_count),
            )
            if not cap.allow_entry and cap.reason:
                reasons.append(cap.reason)

        # News guard (entry-only)
        if self._news_guard is not None and news_window is not None:
            ng = self._news_guard.evaluate_from_window(news_window)
            if not ng.allow_entry:
                reasons.append(ng.reason or "news_blackout")

        # Volatility spacing (entry-only)
        if (
            self._volatility_spacing is not None
            and last_entry_ts_ns is not None
            and now_ts_ns is not None
            and volatility is not None
            and last_entry_ts_ns > 0
        ):
            sp = self._volatility_spacing.evaluate(
                now_ts_ns=int(now_ts_ns),
                last_entry_ts_ns=int(last_entry_ts_ns),
                volatility=float(volatility),
            )
            if not sp.allow_entry:
                reasons.append(sp.reason or "volatility_spacing")

        # Virtual gate (entry-only)
        if self._virtual_gate is not None:
            if virtual_gate_input is None:
                reasons.append("virtual_gate_missing_input")
            else:
                vg = self._virtual_gate.evaluate(
                    decision_ts_ns=int(virtual_gate_input.decision_ts_ns),
                    bar_ts_ns=virtual_gate_input.bar_ts_ns,
                    bar_highs=virtual_gate_input.bar_highs,
                    bar_lows=virtual_gate_input.bar_lows,
                )
                if not vg.gate_ok:
                    reasons.append(vg.gate_reason or "virtual_gate")

        _ = now_utc

        # If entry is blocked, size_factor is irrelevant but keep it deterministic.
        can_open_new = not reasons and not must_flatten
        size_factor = base_size_factor

        if news_window is not None:
            # Preserve existing NewsCalendar sizing semantics.
            size_factor *= float(getattr(news_window, "size_multiplier", 1.0))

        return RiskDecision(
            can_open_new=can_open_new,
            size_factor=size_factor,
            must_flatten=must_flatten,
            reasons=tuple(reasons),
        )
