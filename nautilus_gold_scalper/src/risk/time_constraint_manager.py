"""
TimeConstraintManager
Enforces Apex daily cutoff (4:59 PM ET) with staged warnings.
"""
from __future__ import annotations

from datetime import datetime, time
from typing import Protocol
from zoneinfo import ZoneInfo

from nautilus_trader.common.component import Clock, TimeEvent

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
        *,
        clock: Clock | None = None,
        use_clock_timer: bool = False,
        timer_interval_ns: int = 10_000_000_000,
    ) -> None:
        self.strategy = strategy
        self.cutoff = cutoff
        if emergency > cutoff:
            emergency = cutoff

        self.warnings = {
            "warning": warning,
            "urgent": urgent,
            "emergency": emergency,
        }
        self.allow_overnight = allow_overnight
        self._issued: set[str] = set()
        self.telemetry = telemetry

        self._clock = clock
        self._use_clock_timer = use_clock_timer
        self._timer_interval_ns = int(timer_interval_ns)
        self._timer_name = "apex_time_gates"

        if self._use_clock_timer and self._clock is not None:
            self._ensure_timer_started()

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

    def check_wall_clock(self) -> bool:
        """Safety enforcement when feed stalls (live mode).

        Uses the strategy clock timestamp to enforce emergency close even if no
        market events are arriving.
        """
        if self._clock is None:
            return True
        return self.check(int(self._clock.timestamp_ns()))

    def on_timer(self, event: TimeEvent) -> None:
        if getattr(event, "name", "") != self._timer_name:
            return
        self.check_wall_clock()

    def _ensure_timer_started(self) -> None:
        if self._clock is None:
            return
        # Safe to call multiple times; cancel if already exists.
        # timer_names is a property (list), not a method
        if self._timer_name in self._clock.timer_names:
            try:
                self._clock.cancel_timer(self._timer_name)
            except Exception:
                pass

        now_ns = int(self._clock.timestamp_ns())
        start_ns = now_ns
        stop_ns = now_ns + int(24 * 60 * 60 * 1_000_000_000)

        self._clock.set_timer_ns(
            name=self._timer_name,
            interval_ns=int(self._timer_interval_ns),
            start_time_ns=int(start_ns),
            stop_time_ns=int(stop_ns),
            callback=self.on_timer,
            allow_past=True,
            fire_immediately=True,
        )

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

        # Cutoff window: force-close on every call until flat.
        if now_time >= self.cutoff:
            self._force_close_all(dt_et, trigger="cutoff", gate_time=self.cutoff)
            self._issued.add("cutoff")
            return False

        # Emergency window: force-close on every call until flat.
        if now_time >= self.warnings["emergency"]:
            self._force_close_all(dt_et, trigger="emergency", gate_time=self.warnings["emergency"])
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
        self._force_close_all(
            datetime.fromtimestamp(ts_ns / 1e9, tz=ZoneInfo("UTC")),
            trigger="timezone_unavailable",
            gate_time=None,
        )
        return datetime.fromtimestamp(ts_ns / 1e9, tz=ZoneInfo("UTC"))

    def reset_daily(self) -> None:
        """Reset warning flags for a new trading day."""
        self._issued.clear()

    def _force_close_all(self, dt_et: datetime, *, trigger: str, gate_time: time | None) -> None:
        """Flatten all positions and block further trading for the day."""
        try:
            self.strategy.cancel_all_orders(getattr(self.strategy.config, "instrument_id", None))
        except Exception:
            pass

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

        gate_str = gate_time.strftime("%H:%M") if gate_time is not None else "unknown"
        if "flatten" not in self._issued:
            self._issued.add("flatten")
            self.strategy.log.warning(
                f'{{"event":"apex_cutoff","ts":"{dt_et.isoformat()}","action":"flatten","trigger":"{trigger}","gate":"{gate_str} ET"}}'
            )
            if self.telemetry:
                self.telemetry.emit(
                    "apex_cutoff",
                    {
                        "ts": dt_et.isoformat(),
                        "action": "flatten",
                        "trigger": trigger,
                        "gate": gate_str,
                        "reason": f"{trigger}_reached",
                    },
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

    def cancel_all_orders(self, instrument_id: object) -> None: ...
    def close_all_positions(self, instrument_id: object) -> None: ...
    def close_position(self, position_id: object) -> None: ...
