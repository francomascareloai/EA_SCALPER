from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class VolatilitySpacingResult:
    allow_entry: bool
    required_cooldown_seconds: float
    reason: str | None = None


class VolatilitySpacing:
    """Entry-only spacing gate which scales monotonically with volatility.

    This is a time-based cooldown gate, NOT price-level scheduling.
    """

    def __init__(
        self,
        *,
        min_cooldown_seconds: float = 0.0,
        max_cooldown_seconds: float = 300.0,
        reference_volatility: float = 1.0,
    ) -> None:
        self.min_cooldown_seconds = float(min_cooldown_seconds)
        self.max_cooldown_seconds = float(max_cooldown_seconds)
        self.reference_volatility = float(reference_volatility) if reference_volatility > 0 else 1.0

    def required_cooldown_seconds(self, *, volatility: float) -> float:
        v = float(volatility)
        if v <= 0.0:
            base = self.min_cooldown_seconds
        else:
            ratio = v / self.reference_volatility
            ratio = max(0.0, ratio)
            base = self.min_cooldown_seconds + (self.max_cooldown_seconds - self.min_cooldown_seconds) * min(1.0, ratio)

        return float(max(self.min_cooldown_seconds, min(self.max_cooldown_seconds, base)))

    def evaluate(
        self,
        *,
        now_ts_ns: int,
        last_entry_ts_ns: int | None,
        volatility: float,
    ) -> VolatilitySpacingResult:
        required = self.required_cooldown_seconds(volatility=volatility)
        if last_entry_ts_ns is None:
            return VolatilitySpacingResult(True, required, None)

        elapsed = max(0.0, (int(now_ts_ns) - int(last_entry_ts_ns)) / 1e9)
        if elapsed < required:
            return VolatilitySpacingResult(False, required, "volatility_spacing")

        return VolatilitySpacingResult(True, required, None)
