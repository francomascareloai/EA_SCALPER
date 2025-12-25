from __future__ import annotations

from dataclasses import dataclass


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

    This module is intentionally dependency-light: it only encodes precedence and
    sizing semantics. Concrete gates (ExposureCaps, NewsGuard, VolatilitySpacing,
    VirtualGate) will be integrated as inputs here in later plans.
    """

    def evaluate_entry(
        self,
        *,
        time_gate_ok: bool = True,
        blocked_today: bool = False,
        prop_firm_ok: bool = True,
        circuit_ok: bool = True,
        size_factor: float = 1.0,
        must_flatten: bool = False,
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

        can_open_new = not reasons and not must_flatten
        return RiskDecision(
            can_open_new=can_open_new,
            size_factor=size_factor,
            must_flatten=must_flatten,
            reasons=tuple(reasons),
        )
