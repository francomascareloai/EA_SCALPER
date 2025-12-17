"""
TimeConstraintManager
Enforces Apex daily cutoff (4:59 PM ET) with staged warnings.
"""
from __future__ import annotations

from datetime import datetime, time
from typing import Protocol
from zoneinfo import ZoneInfo

try:
    ET_TZ: ZoneInfo | None = ZoneInfo("America/New_York")
except Exception:  # pragma: no cover
    ET_TZ = None


class TimeConstraintManager:
    """Enforces Apex 4:59 PM ET cutoff with warnings and forced flatten."""

    def __init__(
        self,
        strategy: TimeManagedStrategy,
        cutoff: time = time(16, 59),
        warning: time = time(16, 0),
        urgent: time = time(16, 30),
        emergency: time = time(16, 55),
        allow_overnight: bool = False,
        telemetry: TimeManagedStrategy.Telemetry | None = None,
    ) -> None:
        self.strategy = strategy
        self.cutoff = cutoff
        self.warnings = {
            "warning": warning,
            "urgent": urgent,
            "emergency": emergency,
        }
        self.allow_overnight = allow_overnight
        self._issued: set[str] = set()
        self.telemetry = telemetry

    def check(self, ts_ns: int) -> bool:
        """
        Check time constraints for a given timestamp in nanoseconds.
        Returns True if trading is allowed, False if trading must stop.
        """
        if self.allow_overnight:
            return True

        dt_et = (
            datetime.fromtimestamp(ts_ns / 1e9, tz=ET_TZ)
            if ET_TZ is not None
            else datetime.fromtimestamp(ts_ns / 1e9)
        )
        now_time = dt_et.time()

        for level, when in self.warnings.items():
            if now_time >= when and level not in self._issued:
                self._log_warning(level, dt_et)
                self._issued.add(level)

        if now_time >= self.cutoff:
            # Only emit/log the cutoff once per day to avoid log spam on every bar/tick.
            # The strategy remains blocked until the daily reset, so repeated calls add no value.
            if "cutoff" not in self._issued:
                self._force_close_all(dt_et)
                self._issued.add("cutoff")
            return False

        return True

    def reset_daily(self) -> None:
        """Reset warning flags for a new trading day."""
        self._issued.clear()

    def _force_close_all(self, dt_et: datetime) -> None:
        """Flatten all positions and stop further trading."""
        try:
            self.strategy.close_all_positions(getattr(self.strategy.config, "instrument_id", None))
        except Exception:
            for pos in self.strategy.cache.positions_open():
                try:
                    self.strategy.close_position(pos)
                except Exception:
                    pass

        self.strategy._is_trading_allowed = False
        self.strategy._trading_blocked_today = True
        cutoff_str = self.cutoff.strftime("%H:%M")
        # This is a safety/compliance event, not a runtime error; keep at WARNING to avoid log spam in sweeps.
        self.strategy.log.warning(
            f'{{"event":"apex_cutoff","ts":"{dt_et.isoformat()}","action":"flatten","reason":"{cutoff_str} cutoff"}}'
        )
        if self.telemetry:
            self.telemetry.emit(
                "apex_cutoff",
                {"ts": dt_et.isoformat(), "action": "flatten", "reason": "cutoff_reached", "cutoff": cutoff_str},
            )

    def _log_warning(self, level: str, dt_et: datetime) -> None:
        cutoff_str = self.cutoff.strftime("%H:%M")
        payload = (
            f'{{"event":"apex_cutoff_warning","level":"{level}","ts":"{dt_et.isoformat()}","cutoff":"{cutoff_str} ET"}}'
        )
        self.strategy.log.warning(payload)
        if self.telemetry:
            self.telemetry.emit(
                "apex_cutoff_warning",
                {"level": level, "ts": dt_et.isoformat(), "cutoff": cutoff_str},
            )


class TimeManagedStrategy(Protocol):
    class _Config(Protocol):
        instrument_id: object

    class _Cache(Protocol):
        def positions_open(self) -> list[object]: ...

    class Telemetry(Protocol):
        def emit(self, event: str, payload: object) -> None: ...

    class _Log(Protocol):
        def error(self, msg: str) -> None: ...
        def warning(self, msg: str) -> None: ...

    config: _Config
    cache: _Cache
    log: _Log
    _is_trading_allowed: bool
    _trading_blocked_today: bool

    def close_all_positions(self, instrument_id: object) -> None: ...
    def close_position(self, position_id: object) -> None: ...
