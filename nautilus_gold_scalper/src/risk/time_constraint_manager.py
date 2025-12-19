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
    """Enforces Apex time gates (ET) for prop-firm compliance."""

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

    def can_open_new(self, ts_ns: int) -> bool:
        """Return True if opening *new* positions is allowed at `ts_ns` (ET)."""
        if self.allow_overnight:
            return True

        if ET_TZ is None:
            return False

        dt_et = self._to_et(ts_ns)
        now_time = dt_et.time()

        # Block new trades after the urgent (4:30 PM ET) gate.
        if now_time >= self.warnings["urgent"]:
            return False

        return True

    def check(self, ts_ns: int) -> bool:
        """Return True if trading may continue at `ts_ns` (ET).

        This method is used for safety enforcement (flatten + halt) near close.
        It does NOT block at the 4:30 PM entry gate; use `can_open_new` for that.
        """
        if self.allow_overnight:
            return True

        dt_et = self._to_et(ts_ns)
        if ET_TZ is None:
            return False
        now_time = dt_et.time()

        for level, when in self.warnings.items():
            if now_time >= when and level not in self._issued:
                self._log_warning(level, dt_et)
                self._issued.add(level)

        # Emergency window: force-close on every call until flat.
        if now_time >= self.warnings["emergency"]:
            self._force_close_all(dt_et)
            return False

        # Cutoff window: flatten once and block trading for the rest of the day.
        if now_time >= self.cutoff:
            if "cutoff" not in self._issued:
                self._force_close_all(dt_et)
                self._issued.add("cutoff")
            return False

        return True

    def _to_et(self, ts_ns: int) -> datetime:
        """Convert event timestamp (ns) to America/New_York.

        Fail-safe: if timezone info is unavailable, assume worst-case and return a
        timestamp in UTC but shifted to be conservative for close compliance.
        """
        if ET_TZ is not None:
            return datetime.fromtimestamp(ts_ns / 1e9, tz=ET_TZ)

        # Degraded mode: without reliable ET conversion, fail-safe.
        # If we can't compute ET reliably, assume we're in the danger window and block.
        self._force_close_all(datetime.fromtimestamp(ts_ns / 1e9, tz=ZoneInfo("UTC")))
        return datetime.fromtimestamp(ts_ns / 1e9, tz=ZoneInfo("UTC"))

    def reset_daily(self) -> None:
        """Reset warning flags for a new trading day."""
        self._issued.clear()

    def _force_close_all(self, dt_et: datetime) -> None:
        """Flatten all positions and block further trading for the day."""
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
        if "flatten" not in self._issued:
            self._issued.add("flatten")
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
