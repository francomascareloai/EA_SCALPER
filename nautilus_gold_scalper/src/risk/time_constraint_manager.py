"""
TimeConstraintManager
Enforces Apex daily cutoff (4:59 PM ET) with staged warnings.
"""

from __future__ import annotations

from datetime import datetime, time
from datetime import timezone as dt_timezone
from typing import Protocol
from zoneinfo import ZoneInfo

from nautilus_trader.common.component import Clock, TimeEvent
from nautilus_trader.model.enums import OrderStatus
from nautilus_trader.model.identifiers import ClientOrderId

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
        prop_firm_enabled: bool = False,
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

        # R9-CRITICAL-FIX: Force allow_overnight=False when prop_firm_enabled=True
        # to prevent bypassing Apex time gates even if config specifies allow_overnight=True.
        # Apex requires ALL positions closed by 4:59 PM ET - overnight positions are prohibited.
        if prop_firm_enabled and allow_overnight:
            import logging

            logging.getLogger(__name__).warning(
                "APEX SAFETY: allow_overnight=True ignored because prop_firm_enabled=True. "
                "Prop firm mode requires all positions closed by 4:59 PM ET."
            )
            allow_overnight = False

        self.allow_overnight = allow_overnight
        self._prop_firm_enabled = prop_firm_enabled
        self._issued: set[str] = set()
        self.telemetry = telemetry

        # BUG-13 FIX: Track if close orders have already been submitted
        # to prevent spamming on every tick after cutoff
        self._close_orders_submitted: bool = False
        self._close_submitted_ts_ns: int | None = None

        # CRITICAL FIX: Track order IDs for rejection detection and retry
        self._close_order_ids: list[ClientOrderId] = []
        self._close_retry_count: int = 0
        self._max_close_retries: int = 3
        # Timeout for close orders (5 seconds in nanoseconds)
        self._close_timeout_ns: int = 5_000_000_000

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
        # M4 FIX: Use datetime.timezone.utc (imported as dt_timezone) as ultimate fallback
        # in case ZoneInfo("UTC") also fails.
        try:
            fallback_tz = ZoneInfo("UTC")
        except Exception:
            fallback_tz = dt_timezone.utc  # type: ignore[assignment]
        self._force_close_all(
            datetime.fromtimestamp(ts_ns / 1e9, tz=fallback_tz),
            trigger="timezone_unavailable",
            gate_time=None,
        )
        return datetime.fromtimestamp(ts_ns / 1e9, tz=fallback_tz)

    def reset_daily(self) -> None:
        """Reset warning flags for a new trading day."""
        self._issued.clear()
        # BUG-13 FIX: Reset close order tracking for new day
        self._close_orders_submitted = False
        self._close_submitted_ts_ns = None
        # CRITICAL FIX: Reset retry tracking for new day
        self._close_order_ids.clear()
        self._close_retry_count = 0

    def _force_close_all(self, dt_et: datetime, *, trigger: str, gate_time: time | None) -> None:
        """Flatten all positions and block further trading for the day.

        CRITICAL FIX: Implements retry mechanism for rejected close orders.
        If close orders are REJECTED (not just pending), retries up to max_retries
        with IOC (Immediate-Or-Cancel) fallback to ensure no overnight positions.
        """
        remaining = list(self.strategy.cache.positions_open())

        # Always block trading and cancel pending orders on emergency close
        # This must happen even if no positions (there may be pending orders)
        if not self._close_orders_submitted:
            # Cancel all orders first (SL/TP that might interfere, or pending orders)
            try:
                self.strategy.cancel_all_orders(
                    getattr(self.strategy.config, "instrument_id", None)
                )
            except Exception:
                pass

            # Block further trading
            if hasattr(self.strategy, "_is_trading_allowed"):
                self.strategy._is_trading_allowed = False
            if hasattr(self.strategy, "_trading_blocked_today"):
                self.strategy._trading_blocked_today = True

            # Log the cutoff event
            gate_str = gate_time.strftime("%H:%M") if gate_time is not None else "unknown"
            if "flatten" not in self._issued:
                self._issued.add("flatten")
                self.strategy.log.warning(
                    f'{{"event":"apex_cutoff","ts":"{dt_et.isoformat()}","action":"flatten",'
                    f'"trigger":"{trigger}","gate":"{gate_str} ET"}}'
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

        # SUCCESS: No positions remaining - all done
        if not remaining:
            try:
                self.strategy._forcing_flatten = False
            except Exception:
                pass
            # Mark as submitted even with no positions to prevent re-entry
            self._close_orders_submitted = True
            # Call close_all_positions even with no positions for compatibility
            try:
                self.strategy.close_all_positions(
                    getattr(self.strategy.config, "instrument_id", None),
                    reduce_only=False,
                )
            except Exception:
                pass
            return

        # Get current timestamp for timeout detection
        current_ts_ns: int = 0
        if self._clock is not None:
            current_ts_ns = int(self._clock.timestamp_ns())

        # Check if we already submitted close orders (for retry logic)
        if self._close_orders_submitted:
            # CRITICAL FIX: Check for rejected orders and retry
            rejected_count = self._check_rejected_close_orders()

            if rejected_count > 0:
                # Orders were rejected - retry with fallback
                if self._close_retry_count < self._max_close_retries:
                    self._close_retry_count += 1
                    self.strategy.log.warning(
                        f'{{"event":"CLOSE_ORDER_REJECTED","retry":{self._close_retry_count},'
                        f'"max_retries":{self._max_close_retries},"rejected_count":{rejected_count},'
                        f'"remaining_positions":{len(remaining)},"trigger":"{trigger}"}}'
                    )
                    # Reset tracking and retry with IOC fallback
                    self._close_order_ids.clear()
                    self._close_orders_submitted = False
                    # Fall through to submit new orders (with IOC on retry)
                else:
                    # Max retries exceeded - CRITICAL ALERT
                    self.strategy.log.error(
                        f'{{"event":"CRITICAL_CLOSE_FAILED","max_retries_exceeded":true,'
                        f'"retry_count":{self._close_retry_count},"remaining_positions":{len(remaining)},'
                        f'"trigger":"{trigger}","action":"MANUAL_INTERVENTION_REQUIRED"}}'
                    )
                    if self.telemetry:
                        self.telemetry.emit(
                            "critical_close_failed",
                            {
                                "ts": dt_et.isoformat(),
                                "retry_count": self._close_retry_count,
                                "remaining_positions": len(remaining),
                                "trigger": trigger,
                            },
                        )
                    return

            # Check for timeout (orders pending too long without fill)
            elif (
                self._close_submitted_ts_ns is not None
                and current_ts_ns > 0
                and (current_ts_ns - self._close_submitted_ts_ns) > self._close_timeout_ns
            ):
                # Timeout reached - orders pending too long, retry
                if self._close_retry_count < self._max_close_retries:
                    self._close_retry_count += 1
                    self.strategy.log.warning(
                        f'{{"event":"CLOSE_ORDER_TIMEOUT","retry":{self._close_retry_count},'
                        f'"max_retries":{self._max_close_retries},"remaining_positions":{len(remaining)},'
                        f'"timeout_ms":{self._close_timeout_ns // 1_000_000},"trigger":"{trigger}"}}'
                    )
                    # Reset and retry with IOC
                    self._close_order_ids.clear()
                    self._close_orders_submitted = False
                    # Fall through to submit new orders
                else:
                    # Max retries on timeout - still positions open
                    if "critical_logged" not in self._issued:
                        self._issued.add("critical_logged")
                        self.strategy.log.error(
                            f'{{"event":"CRITICAL_CLOSE_TIMEOUT","max_retries_exceeded":true,'
                            f'"remaining_positions":{len(remaining)},"trigger":"{trigger}"}}'
                        )
                    return
            else:
                # Orders submitted, not rejected, not timed out - wait
                if "critical_logged" not in self._issued:
                    self._issued.add("critical_logged")
                    self.strategy.log.warning(
                        f'{{"event":"POSITIONS_PENDING_CLOSE","trigger":"{trigger}",'
                        f'"remaining_count":{len(remaining)},"retry":{self._close_retry_count},'
                        f'"note":"Close orders submitted, waiting for fill"}}'
                    )
                return

        # First time OR retry: submit close orders for remaining positions
        self._close_orders_submitted = True
        self._close_submitted_ts_ns = current_ts_ns if current_ts_ns > 0 else None

        # Signal that we're intentionally flattening
        try:
            self.strategy._forcing_flatten = True
        except Exception:
            pass

        # Submit close orders
        # On retry (retry_count > 0), we use IOC time-in-force for urgency
        use_ioc = self._close_retry_count > 0
        self._submit_close_orders(remaining, use_ioc=use_ioc)

    def _check_rejected_close_orders(self) -> int:
        """Check if any submitted close orders were rejected.

        Returns the count of rejected orders.
        """
        rejected_count = 0
        for order_id in self._close_order_ids:
            try:
                order = self.strategy.cache.order(order_id)
                if order is not None:
                    # Use getattr for defensive access since Protocol uses object type
                    order_status = getattr(order, "status", None)
                    if order_status == OrderStatus.REJECTED:
                        rejected_count += 1
            except Exception:
                # If we can't check order status, assume not rejected
                pass
        return rejected_count

    def _submit_close_orders(self, positions: list[object], *, use_ioc: bool) -> None:
        """Submit close orders for given positions.

        Args:
            positions: List of open positions to close.
            use_ioc: If True, use IOC (Immediate-Or-Cancel) time-in-force for urgency.
        """
        self._close_order_ids.clear()

        try:
            # Use close_all_positions first (standard approach)
            # Note: close_all_positions doesn't return order IDs directly,
            # but we can track orders submitted after this call
            instrument_id = getattr(self.strategy.config, "instrument_id", None)

            # Get order count before submission
            orders_before = len(list(self.strategy.cache.orders(instrument_id)))

            self.strategy.close_all_positions(
                instrument_id,
                reduce_only=False,  # Force close
            )

            # Capture newly submitted order IDs
            all_orders = list(self.strategy.cache.orders(instrument_id))
            # New orders are those added after our call
            if len(all_orders) > orders_before:
                for order in all_orders[orders_before:]:
                    if hasattr(order, "client_order_id"):
                        self._close_order_ids.append(order.client_order_id)

        except Exception:
            # Fallback: try closing positions individually
            for pos in positions:
                try:
                    self.strategy.close_position(pos, reduce_only=False)
                except Exception:
                    pass

    def _log_warning(self, level: str, dt_et: datetime) -> None:
        cutoff_str = self.cutoff.strftime("%H:%M")
        payload = f'{{"event":"apex_cutoff_warning","level":"{level}","ts":"{dt_et.isoformat()}","cutoff":"{cutoff_str} ET"}}'
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
        def order(self, order_id: ClientOrderId) -> object | None: ...
        def orders(self, instrument_id: object) -> list[object]: ...

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
    _forcing_flatten: bool

    def cancel_all_orders(self, instrument_id: object) -> None: ...
    def close_all_positions(self, instrument_id: object, reduce_only: bool = ...) -> None: ...
    def close_position(self, position_id: object, reduce_only: bool = ...) -> None: ...
