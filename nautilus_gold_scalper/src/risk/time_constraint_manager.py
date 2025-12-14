"""
TimeConstraintManager
Enforces Apex daily cutoff (4:59 PM ET) with staged warnings.
"""
from __future__ import annotations

from datetime import datetime, time
from typing import Set

try:
    from zoneinfo import ZoneInfo
    ET_TZ = ZoneInfo("America/New_York")
except Exception:  # pragma: no cover
    from datetime import timezone
    ET_TZ = timezone.utc


class TimeConstraintManager:
    """Enforces Apex 4:59 PM ET cutoff with warnings and forced flatten."""

    def __init__(
        self,
        strategy,
        cutoff: time = time(16, 59),
        warning: time = time(16, 0),
        urgent: time = time(16, 30),
        emergency: time = time(16, 55),
        allow_overnight: bool = False,
        telemetry=None,
    ) -> None:
        self.strategy = strategy
        self.cutoff = cutoff
        self.warnings = {
            "warning": warning,
            "urgent": urgent,
            "emergency": emergency,
        }
        self.allow_overnight = allow_overnight
        self._issued: Set[str] = set()
        self.telemetry = telemetry

    def check(self, ts_ns: int) -> bool:
        """
        Check time constraints for a given timestamp in nanoseconds.
        Returns True if trading is allowed, False if trading must stop.
        """
        if self.allow_overnight:
            return True

        dt_et = datetime.fromtimestamp(ts_ns / 1e9, tz=ET_TZ)
        now_time = dt_et.time()

        # Warnings
        for level, when in self.warnings.items():
            if now_time >= when and level not in self._issued:
                self._log_warning(level, dt_et)
                self._issued.add(level)

        # Hard cutoff: force close + block
        if now_time >= self.cutoff:
            self._force_close_all(dt_et)
            return False

        return True

    def reset_daily(self) -> None:
        """Reset warning flags for a new trading day."""
        self._issued.clear()

    # -------- internal helpers --------
    def _force_close_all(self, dt_et: datetime) -> None:
        """Flatten all positions and stop further trading."""
        try:
            self.strategy.close_all_positions(self.strategy.config.instrument_id)
        except Exception:
            # Fail-safe: try generic cache walk
            for pos in self.strategy.cache.positions_open():
                try:
                    self.strategy.close_position(pos)
                except Exception:
                    pass

        self.strategy._is_trading_allowed = False  # internal guard
        setattr(self.strategy, "_trading_blocked_today", True)
        cutoff_str = self.cutoff.strftime("%H:%M")
        self.strategy.log.error(
            f'{{"event":"apex_cutoff","ts":"{dt_et.isoformat()}","action":"flatten","reason":"{cutoff_str} cutoff"}}'
        )
        if self.telemetry:
            self.telemetry.emit(
                "apex_cutoff",
                {"ts": dt_et.isoformat(), "action": "flatten", "reason": "cutoff_reached", "cutoff": cutoff_str},
            )

    def _log_warning(self, level: str, dt_et: datetime) -> None:
        cutoff_str = self.cutoff.strftime("%H:%M")
        payload = f'{{"event":"apex_cutoff_warning","level":"{level}","ts":"{dt_et.isoformat()}","cutoff":"{cutoff_str} ET"}}'
        if level == "emergency":
            self.strategy.log.error(payload)
        elif level == "urgent":
            self.strategy.log.error(payload)
        else:
            self.strategy.log.warning(payload)
        if self.telemetry:
            self.telemetry.emit(
                "apex_cutoff_warning",
                {"level": level, "ts": dt_et.isoformat(), "cutoff": cutoff_str},
            )
