from __future__ import annotations

from typing import Any

from nautilus_gold_scalper.src.strategies.base_strategy import BaseGoldStrategy, BaseStrategyConfig
from nautilus_trader.model.enums import PositionSide
from nautilus_trader.model.events import OrderAccepted, OrderCanceled, OrderRejected
from nautilus_trader.model.identifiers import InstrumentId
from nautilus_trader.model.objects import Price, Quantity


class DummyConfig(BaseStrategyConfig):
    # Only what BaseGoldStrategy requires at init-time
    instrument_id = InstrumentId.from_str("XAUUSD.SIM")
    seed = 42


class DummyStrategy(BaseGoldStrategy):
    def __init__(self) -> None:
        super().__init__(config=DummyConfig(instrument_id=InstrumentId.from_str("XAUUSD.SIM")))
        self.closed = False
        self.canceled = False

        self.instrument = None

    def _on_strategy_start(self) -> None:
        return None

    def _on_strategy_stop(self) -> None:
        return None

    def _on_htf_bar(self, _bar: Any) -> None:
        return None

    def _on_mtf_bar(self, _bar: Any) -> None:
        return None

    def _on_ltf_bar(self, _bar: Any) -> None:
        return None

    def _check_for_signal(self, _bar: Any) -> None:
        return None

    # Strategy hooks used by fail-safe
    def cancel_all_orders(self, *_args: Any, **_kwargs: Any) -> None:
        self.canceled = True

    def close_all_positions(self, *_args: Any, **_kwargs: Any) -> None:
        self.closed = True


def _event(cls: type[Any], **overrides: Any) -> Any:
    """Construct a minimal Nautilus event using from_dict().

    NOTE: Nautilus identifier types are strict (many require a '-' and event_id must be UUID).
    """
    import uuid

    base: dict[str, Any] = {
        "event_id": str(uuid.uuid4()),
        "account_id": "ACC-1",
        "client_order_id": "CID",
        "instrument_id": "XAUUSD.SIM",
        "venue_order_id": "VID",
        "strategy_id": "STRAT-1",
        "trader_id": "TRADER-1",
        "ts_event": 1,
        "ts_init": 1,
    }
    base.update(overrides)
    return cls.from_dict(base)


def test_ioc_reject_defers_pending_clear_until_grace_expires() -> None:
    s = DummyStrategy()

    s._entry_client_order_id = "ENTRY"
    s._pending_sl = object()  # type: ignore[assignment]
    s._pending_tp = object()  # type: ignore[assignment]

    evt = _event(OrderRejected, client_order_id="ENTRY", reason="rejected", ts_event=1)
    s.on_order_rejected(evt)

    assert s._entry_client_order_id is None
    assert s._pending_sl is not None
    assert s._pending_tp is not None

    s._finalize_entry_terminal_if_safe(6_000_000_001)
    assert s._pending_sl is None
    assert s._pending_tp is None


def test_ioc_cancel_defers_pending_clear_until_grace_expires() -> None:
    s = DummyStrategy()

    s._entry_client_order_id = "ENTRY"
    s._pending_sl = object()  # type: ignore[assignment]
    s._pending_tp = object()  # type: ignore[assignment]

    evt = _event(OrderCanceled, client_order_id="ENTRY", ts_event=1)
    s.on_order_canceled(evt)

    assert s._entry_client_order_id is None
    assert s._pending_sl is not None
    assert s._pending_tp is not None

    s._finalize_entry_terminal_if_safe(6_000_000_001)
    assert s._pending_sl is None
    assert s._pending_tp is None


def test_bracket_sl_reject_triggers_emergency_close_and_halt() -> None:
    s = DummyStrategy()

    # Simulate position is open
    s._position = object()  # type: ignore[assignment]

    s._bracket_sl_client_order_id = "SL"
    evt = _event(OrderRejected, client_order_id="SL", reason="reject")
    s.on_order_rejected(evt)

    assert s.closed is True
    assert s.canceled is True
    assert s._is_trading_allowed is False
    assert s._trading_blocked_today is True


def test_bracket_tp_reject_triggers_failsafe_when_tp_expected() -> None:
    s = DummyStrategy()

    s._position = object()  # type: ignore[assignment]
    s._bracket_sl_client_order_id = "SL"
    s._bracket_sl_confirmed = True
    s._bracket_tp_client_order_id = "TP"
    s._bracket_tp_expected = True

    evt = _event(OrderRejected, client_order_id="TP", reason="reject")
    s.on_order_rejected(evt)

    assert s.closed is True
    assert s.canceled is True
    assert s._is_trading_allowed is False
    assert s._trading_blocked_today is True


def test_bracket_tp_reject_does_not_trigger_failsafe_when_tp_not_expected() -> None:
    s = DummyStrategy()

    s._position = object()  # type: ignore[assignment]
    s._bracket_sl_client_order_id = "SL"
    s._bracket_sl_confirmed = True
    s._bracket_tp_client_order_id = "TP"
    s._bracket_tp_expected = False

    evt = _event(OrderRejected, client_order_id="TP", reason="reject")
    s.on_order_rejected(evt)

    assert s.closed is False
    assert s.canceled is False
    assert s._is_trading_allowed is True
    assert s._trading_blocked_today is False
    assert s._bracket_tp_client_order_id is None
    assert s._bracket_tp_confirmed is False


def test_bracket_accept_tp_first_does_not_failsafe() -> None:
    s = DummyStrategy()

    # Simulate position is open with brackets submitted
    s._position = object()  # type: ignore[assignment]
    s._bracket_sl_client_order_id = "SL"
    s._bracket_tp_client_order_id = "TP"

    evt = _event(OrderAccepted, client_order_id="TP")
    s.on_order_accepted(evt)

    assert s._execution_failsafe_triggered is False
    assert s._is_trading_allowed is True
    assert s._trading_blocked_today is False


def test_failsafe_latch_survives_position_opened() -> None:
    s = DummyStrategy()
    s._trigger_execution_failsafe(reason="test")

    class DummyPositionOpened:
        def __init__(self) -> None:
            self.position_id = "POS-1"
            self.ts_event = 123

    s.on_position_opened(DummyPositionOpened())  # type: ignore[arg-type]

    assert s._execution_failsafe_triggered is True
    assert s._is_trading_allowed is False
    assert s._trading_blocked_today is True


def test_drawdown_breach_in_position_triggers_failsafe() -> None:
    s = DummyStrategy()

    class DummyDrawdownTracker:
        def get_daily_drawdown_pct(self) -> float:
            return 3.0

        def get_total_drawdown_pct(self) -> float:
            return 0.0

    s._drawdown_tracker = DummyDrawdownTracker()  # type: ignore[assignment]
    s._position = object()  # type: ignore[assignment]

    s._apply_drawdown_limits(analysis=object())

    assert s.closed is True
    assert s.canceled is True
    assert s._is_trading_allowed is False
    assert s._trading_blocked_today is True


def test_drawdown_breach_flat_only_blocks_trading() -> None:
    s = DummyStrategy()

    class DummyDrawdownTracker:
        def get_daily_drawdown_pct(self) -> float:
            return 0.0

        def get_total_drawdown_pct(self) -> float:
            return 4.0

    s._drawdown_tracker = DummyDrawdownTracker()  # type: ignore[assignment]
    s._position = None

    s._apply_drawdown_limits(analysis=object())

    assert s.closed is False
    # DD breach while flat: block new trades, but do not force a fail-safe close.
    # TradingState may still cancel pending orders depending on RiskEngine.
    assert s._is_trading_allowed is False
    assert s._trading_blocked_today is True


def test_bar_driven_sl_timeout_triggers_failsafe() -> None:
    s = DummyStrategy()

    s._position = object()  # type: ignore[assignment]
    s._bracket_sl_client_order_id = "SL"
    s._bracket_sl_confirmed = False
    s._bracket_submitted_ts_ns = 0
    s._bracket_confirm_timeout_ns = 5

    class DummyBar:
        def __init__(self) -> None:
            self.ts_event = 10
            self.bar_type = None

    # No quote ticks; watchdog should trigger on any bar event.
    s.on_bar(DummyBar())  # type: ignore[arg-type]

    assert s.closed is True
    assert s.canceled is True
    assert s._is_trading_allowed is False
    assert s._trading_blocked_today is True


def test_bracket_sl_confirm_timeout_triggers_failsafe() -> None:
    s = DummyStrategy()

    # Simulate position is open with brackets submitted but SL not confirmed
    # Provide the minimal fields needed by _compute_equity_from_tick.
    s._position = type(
        "Pos",
        (),
        {
            "avg_px_open": type("Px", (), {"as_double": lambda _self: 1.0})(),
            "quantity": type("Qty", (), {"as_double": lambda _self: 1.0})(),
            "side": PositionSide.LONG,
        },
    )()  # type: ignore[assignment]
    s._bracket_sl_client_order_id = "SL"
    s._bracket_submitted_ts_ns = 0
    s._bracket_confirm_timeout_ns = 5
    s._position_opened_ts_ns = 0

    class _Px:
        def __init__(self, v: float) -> None:
            self._v = v

        def as_double(self) -> float:
            return self._v

        def __sub__(self, other: _Px) -> float:
            return self._v - other._v

    class DummyTick:
        def __init__(self) -> None:
            self.ts_event = 10
            self.ask_price = _Px(2.0)
            self.bid_price = _Px(1.0)

    s.instrument = type("Inst", (), {"price_increment": 0.01})()

    s.on_quote_tick(DummyTick())

    assert s.closed is True
    assert s.canceled is True
    assert s._is_trading_allowed is False
    assert s._trading_blocked_today is True


def _set_min_position(s: DummyStrategy, pos_id: str = "POS-1") -> None:
    s._position = type(
        "Pos",
        (),
        {
            "side": PositionSide.LONG,
            "avg_px_open": type("Px", (), {"as_double": lambda _self: 1.0})(),
            "quantity": type("Qty", (), {"as_double": lambda _self: 1.0})(),
            "id": pos_id,
            "realized_pnl": 0.0,
        },
    )()  # type: ignore[assignment]


def test_entry_cancel_before_position_open_does_not_reuse_stale_pending_on_next_entry() -> None:
    s = DummyStrategy()

    # Previous attempt staged SL/TP, then entry got canceled (terminal state) but we are still within grace.
    s._entry_client_order_id = "ENTRY"
    s._pending_sl = Price.from_str("1.0")
    s._pending_tp = Price.from_str("2.0")

    evt = _event(OrderCanceled, client_order_id="ENTRY", ts_event=1)
    s.on_order_canceled(evt)

    assert s._pending_sl is not None
    assert s._pending_tp is not None

    # Next entry attempt must overwrite staged protection (must not inherit stale values).
    # We simulate an entry by directly setting pending SL/TP as the entry code would do.
    s._pending_sl = None
    s._pending_tp = None

    # Grace cleanup should be a no-op once pending has been overwritten.
    s._finalize_entry_terminal_if_safe(6_000_000_001)
    assert s._pending_sl is None
    assert s._pending_tp is None


def test_position_opened_without_protective_orders_triggers_failsafe() -> None:
    s = DummyStrategy()
    _set_min_position(s)

    # No pending SL/TP.
    s._pending_sl = None
    s._pending_tp = None

    class DummyPositionOpened:
        def __init__(self) -> None:
            self.position_id = "POS-1"
            self.ts_event = 123

    s.on_position_opened(DummyPositionOpened())  # type: ignore[arg-type]

    assert s.closed is True
    assert s.canceled is True
    assert s._is_trading_allowed is False
    assert s._trading_blocked_today is True


def test_entry_stages_protection_before_submit_order() -> None:
    """Regression: IOC market order can fill synchronously in backtests.

    Ensure `_pending_sl/_pending_tp` are staged *before* `submit_order()`.
    """

    class _Order:
        def __init__(self, client_order_id: str) -> None:
            self.client_order_id = client_order_id

    class _StubOrderFactory:
        def market(self, **_kwargs: Any) -> _Order:
            return _Order("ENTRY")

    class ImmediateFillStrategy(DummyStrategy):
        def __init__(self) -> None:
            super().__init__()
            self._saw_submit = False

        @property
        def order_factory(self) -> Any:  # pragma: no cover
            return _StubOrderFactory()

        def submit_order(self, _order: Any) -> None:  # type: ignore[override]
            # This is the critical assertion: protection must already be staged.
            assert self._pending_sl is not None
            self._saw_submit = True

    s = ImmediateFillStrategy()

    s._enter_long(
        quantity=Quantity.from_int(1),
        sl_price=Price.from_str("1.0"),
        tp_price=Price.from_str("2.0"),
    )

    assert s._saw_submit is True
    assert s._execution_failsafe_triggered is False
    assert s._is_trading_allowed is True
    assert s._trading_blocked_today is False


def test_sl_reject_during_forced_flatten_does_not_trigger_failsafe() -> None:
    s = DummyStrategy()
    _set_min_position(s)

    # Forced flatten can cause SL/TP to be rejected/canceled by the engine/venue. This should
    # not recursively trigger FAILSAFE again.
    s._forcing_flatten = True  # type: ignore[attr-defined]
    s._bracket_sl_client_order_id = "SL"

    evt = _event(OrderRejected, client_order_id="SL", reason="reject")
    s.on_order_rejected(evt)

    assert s._execution_failsafe_triggered is False
    assert s.closed is False
    assert s.canceled is False
    assert s._is_trading_allowed is True
    assert s._trading_blocked_today is False


def test_sl_cancel_during_forced_flatten_does_not_trigger_failsafe() -> None:
    s = DummyStrategy()
    _set_min_position(s)

    s._forcing_flatten = True  # type: ignore[attr-defined]
    s._bracket_sl_client_order_id = "SL"

    evt = _event(OrderCanceled, client_order_id="SL", ts_event=1)
    s.on_order_canceled(evt)

    assert s._execution_failsafe_triggered is False
    assert s.closed is False
    assert s.canceled is False
    assert s._is_trading_allowed is True
    assert s._trading_blocked_today is False


def test_failsafe_flatten_retry_is_throttled_by_interval() -> None:
    class CaptureCloseStrategy(DummyStrategy):
        def __init__(self) -> None:
            super().__init__()
            self.close_kwargs: list[dict[str, Any]] = []

        def close_all_positions(self, *_args: Any, **kwargs: Any) -> None:  # type: ignore[override]
            self.close_kwargs.append(dict(kwargs))
            super().close_all_positions(*_args, **kwargs)

    s = CaptureCloseStrategy()
    _set_min_position(s)

    s._failsafe_close_retry_interval_ns = 10
    s._failsafe_close_max_attempts = 10
    s._failsafe_close_retry_count = 0
    s._failsafe_close_last_attempt_ts_ns = None

    s._attempt_failsafe_flatten(now_ts_ns=100)
    assert len(s.close_kwargs) == 1

    # Within retry interval -> no new attempt
    s._attempt_failsafe_flatten(now_ts_ns=105)
    assert len(s.close_kwargs) == 1

    # After retry interval -> next attempt
    s._attempt_failsafe_flatten(now_ts_ns=110)
    assert len(s.close_kwargs) == 2

    assert s.close_kwargs[0].get("reduce_only") is True


def test_failsafe_flatten_stops_after_max_attempts() -> None:
    class CaptureCloseStrategy(DummyStrategy):
        def __init__(self) -> None:
            super().__init__()
            self.close_calls = 0

        def close_all_positions(self, *_args: Any, **_kwargs: Any) -> None:  # type: ignore[override]
            self.close_calls += 1
            super().close_all_positions(*_args, **_kwargs)

    s = CaptureCloseStrategy()
    _set_min_position(s)

    s._failsafe_close_retry_interval_ns = 0
    s._failsafe_close_max_attempts = 2
    s._failsafe_close_retry_count = 0
    s._failsafe_close_last_attempt_ts_ns = None

    s._attempt_failsafe_flatten(now_ts_ns=100)
    s._attempt_failsafe_flatten(now_ts_ns=101)
    s._attempt_failsafe_flatten(now_ts_ns=102)

    assert s.close_calls == 2


def test_failsafe_does_not_crash_if_close_all_positions_throws() -> None:
    class CloseRaisesStrategy(DummyStrategy):
        def close_all_positions(self, *_args: Any, **_kwargs: Any) -> None:  # type: ignore[override]
            raise RuntimeError("boom")

    s = CloseRaisesStrategy()
    _set_min_position(s)

    s._trigger_execution_failsafe(reason="test")

    assert s._execution_failsafe_triggered is True
    assert s._is_trading_allowed is False
    assert s._trading_blocked_today is True


def test_on_bar_attempts_flatten_when_failsafe_triggered() -> None:
    class CaptureCloseStrategy(DummyStrategy):
        def __init__(self) -> None:
            super().__init__()
            self.close_calls = 0

        def close_all_positions(self, *_args: Any, **_kwargs: Any) -> None:  # type: ignore[override]
            self.close_calls += 1
            super().close_all_positions(*_args, **_kwargs)

    s = CaptureCloseStrategy()
    _set_min_position(s)
    s._execution_failsafe_triggered = True

    class DummyBar:
        def __init__(self) -> None:
            self.ts_event = 123
            self.bar_type = None
            self.is_revision = False

    s.on_bar(DummyBar())  # type: ignore[arg-type]
    assert s.close_calls == 1
