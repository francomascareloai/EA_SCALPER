from __future__ import annotations

import datetime
from dataclasses import dataclass
from typing import Any

from nautilus_gold_scalper.src.risk.time_constraint_manager import TimeConstraintManager
from nautilus_trader.model.enums import OrderStatus


@dataclass
class _Order:
    client_order_id: object
    status: object | None = None


class DummyCache:
    def __init__(self) -> None:
        self._orders: list[object] = []
        self._positions: list[object] = []

    def positions_open(self) -> list[object]:
        return list(self._positions)

    def orders(self, _instrument_id: object) -> list[object]:
        return list(self._orders)

    def order(self, order_id: object) -> object | None:
        for order in self._orders:
            if getattr(order, "client_order_id", None) == order_id:
                return order
        return None


class DummyStrategy:
    def __init__(self) -> None:
        self.closed = False
        self.canceled = False
        self.log = self
        self._is_trading_allowed = True
        self.config = type("Cfg", (), {"instrument_id": None})
        self._trading_blocked_today = False
        self._forcing_flatten = False
        self._close_calls = 0
        self._cache = DummyCache()

    def close_position(self, *_args: object, **_kwargs: object) -> None:  # pragma: no cover
        return None

    # Logging proxies
    def critical(self, _msg: str) -> None:  # pragma: no cover
        return None

    def error(self, _msg: str) -> None:  # pragma: no cover
        return None

    def warning(self, _msg: str) -> None:  # pragma: no cover
        return None

    # Position management stubs
    def cancel_all_orders(self, *_args: object, **_kwargs: object) -> None:
        self.canceled = True

    def close_all_positions(self, *_args: object, **_kwargs: object) -> None:
        from nautilus_trader.model.identifiers import ClientOrderId

        self.closed = True
        self._close_calls += 1
        self._cache._orders.append(
            _Order(
                client_order_id=ClientOrderId(f"CLOSE-{self._close_calls}"),
                status=OrderStatus.SUBMITTED,
            )
        )

    @property
    def cache(self) -> DummyCache:
        return self._cache


def ts_at(hour: int, minute: int) -> int:
    """Create timestamp in ET timezone (not UTC)."""
    try:
        from zoneinfo import ZoneInfo

        et_tz: datetime.tzinfo = ZoneInfo("America/New_York")
    except Exception:
        # Fallback for testing: use UTC offset approximation
        et_tz = datetime.timezone(datetime.timedelta(hours=-5))

    dt = datetime.datetime(2025, 1, 1, hour, minute, tzinfo=et_tz)
    return int(dt.timestamp() * 1e9)


def test_time_manager_allows_before_urgent_block() -> None:
    s = DummyStrategy()
    mgr = TimeConstraintManager(strategy=s, allow_overnight=False)
    assert mgr.check(ts_at(15, 0)) is True
    assert s._is_trading_allowed is True
    assert s._trading_blocked_today is False


def test_time_manager_blocks_new_trades_after_urgent() -> None:
    s = DummyStrategy()
    mgr = TimeConstraintManager(strategy=s, allow_overnight=False)
    assert mgr.can_open_new(ts_at(16, 30)) is False
    assert s.closed is False
    assert s._is_trading_allowed is True
    assert s._trading_blocked_today is False


def test_time_manager_flattens_in_emergency_window() -> None:
    s = DummyStrategy()
    # Simulate an open position so the manager submits close orders.
    s.cache._positions = [object()]
    mgr = TimeConstraintManager(strategy=s, allow_overnight=False)
    assert mgr.check(ts_at(16, 55)) is False
    assert s.canceled is True
    assert s.closed is True
    assert s._is_trading_allowed is False
    assert s._trading_blocked_today is True
    assert mgr._close_order_ids


def test_time_manager_retries_when_close_orders_rejected(monkeypatch: Any) -> None:
    s = DummyStrategy()
    s.cache._positions = [object()]
    mgr = TimeConstraintManager(strategy=s, allow_overnight=False)

    # First call submits close orders and records their IDs.
    assert mgr.check(ts_at(16, 55)) is False
    assert mgr._close_order_ids
    assert s.closed is True

    # Mark the submitted close order(s) as REJECTED so the manager retries.
    for order in s.cache._orders:
        oid = getattr(order, "client_order_id", None)
        if oid is not None and oid in mgr._close_order_ids:
            order.status = OrderStatus.REJECTED

    # Force the internal rejection check to observe those statuses.
    assert mgr.check(ts_at(16, 55)) is False

    assert mgr._close_retry_count == 1
    # Retry path resets tracking and triggers IOC escalation (individual close).
    assert s._forcing_flatten is True


def test_time_manager_escalates_to_individual_close_on_retry(monkeypatch: Any) -> None:
    class TrackingStrategy(DummyStrategy):
        def __init__(self) -> None:
            super().__init__()
            self.close_position_calls = 0

        def close_position(self, *_args: object, **_kwargs: object) -> None:
            self.close_position_calls += 1

    s = TrackingStrategy()
    s.cache._positions = [object(), object()]
    mgr = TimeConstraintManager(strategy=s, allow_overnight=False)

    # First call submits close orders (batch).
    assert mgr.check(ts_at(16, 55)) is False

    # Mark prior close orders as rejected.
    for order in s.cache._orders:
        oid = getattr(order, "client_order_id", None)
        if oid is not None and oid in mgr._close_order_ids:
            order.status = OrderStatus.REJECTED

    # Second call triggers retry and should attempt individual close.
    assert mgr.check(ts_at(16, 55)) is False
    assert mgr._close_retry_count == 1
    assert s.close_position_calls == 2


def test_time_manager_cutoff_clamps_emergency_gate() -> None:
    s = DummyStrategy()
    mgr = TimeConstraintManager(
        strategy=s,
        allow_overnight=False,
        cutoff=datetime.time(16, 59),
        emergency=datetime.time(17, 5),
    )
    assert mgr.warnings["emergency"] == datetime.time(16, 59)


def test_time_manager_blocks_and_flattens_at_cutoff() -> None:
    s = DummyStrategy()
    mgr = TimeConstraintManager(strategy=s, allow_overnight=False)
    assert mgr.check(ts_at(16, 59)) is False
    assert "cutoff" in mgr._issued
    assert s.canceled is True
    assert s.closed is True
    assert s._is_trading_allowed is False
    assert s._trading_blocked_today is True


def test_time_manager_resets_daily() -> None:
    s = DummyStrategy()
    mgr = TimeConstraintManager(strategy=s, allow_overnight=False)
    mgr._issued.update({"warning", "urgent", "emergency"})
    mgr.reset_daily()
    assert mgr._issued == set()


def test_time_manager_wall_clock_check_uses_clock_timestamp() -> None:
    s = DummyStrategy()

    class DummyClock:
        def timestamp_ns(self) -> int:
            return ts_at(16, 55)

        @property
        def timer_names(self) -> list[str]:
            return []

        def cancel_timer(self, _name: str) -> None:
            return None

        def set_timer_ns(self, *args: object, **kwargs: object) -> None:
            return None

    clk = DummyClock()
    mgr = TimeConstraintManager(strategy=s, allow_overnight=False, clock=clk, use_clock_timer=True)

    assert mgr.check_wall_clock() is False
    assert s.canceled is True
    assert s.closed is True
    assert s._is_trading_allowed is False
    assert s._trading_blocked_today is True


def test_time_manager_clock_timer_triggers_enforcement_path() -> None:
    s = DummyStrategy()

    class DummyClock:
        def __init__(self) -> None:
            self.set_timer_calls: list[dict[str, object]] = []

        def timestamp_ns(self) -> int:
            return ts_at(16, 55)

        @property
        def timer_names(self) -> list[str]:
            return []

        def cancel_timer(self, _name: str) -> None:
            return None

        def set_timer_ns(self, **kwargs: object) -> None:
            self.set_timer_calls.append(dict(kwargs))

    clk = DummyClock()
    mgr = TimeConstraintManager(
        strategy=s,
        allow_overnight=False,
        clock=clk,
        use_clock_timer=True,
        timer_interval_ns=123,
    )

    assert len(clk.set_timer_calls) == 1
    call = clk.set_timer_calls[0]
    assert call["name"] == "apex_time_gates"
    assert call["interval_ns"] == 123
    assert call["fire_immediately"] is True
    assert call["allow_past"] is True
    assert isinstance(call["start_time_ns"], int)
    assert isinstance(call["stop_time_ns"], int)

    callback = call["callback"]
    assert callable(callback)

    callback(type("Evt", (), {"name": "not_apex_time_gates"})())
    assert s.canceled is False
    assert s.closed is False

    callback(type("Evt", (), {"name": "apex_time_gates"})())

    assert s.canceled is True
    assert s.closed is True
    assert s._is_trading_allowed is False
    assert s._trading_blocked_today is True


def test_time_manager_fail_safe_when_et_unavailable(monkeypatch: Any) -> None:
    s = DummyStrategy()
    mgr = TimeConstraintManager(strategy=s, allow_overnight=False)

    import nautilus_gold_scalper.src.risk.time_constraint_manager as tcm

    monkeypatch.setattr(tcm, "ET_TZ", None)
    assert mgr.can_open_new(ts_at(10, 0)) is False
    assert mgr.check(ts_at(10, 0)) is False
    assert s.canceled is True
    assert s.closed is True
    assert s._is_trading_allowed is False
    assert s._trading_blocked_today is True
