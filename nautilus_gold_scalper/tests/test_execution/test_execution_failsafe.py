from __future__ import annotations

from typing import Any

import pytest
from nautilus_trader.model.events import OrderAccepted, OrderCanceled, OrderRejected, PositionOpened
from nautilus_trader.model.enums import PositionSide

from nautilus_gold_scalper.src.strategies.base_strategy import BaseGoldStrategy, BaseStrategyConfig


from nautilus_trader.model.identifiers import InstrumentId


class DummyConfig(BaseStrategyConfig):
    # Only what BaseGoldStrategy requires at init-time
    instrument_id = InstrumentId.from_str("XAUUSD.SIM")


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


def test_ioc_reject_clears_pending() -> None:
    s = DummyStrategy()

    s._entry_client_order_id = "ENTRY"
    s._pending_sl = object()  # type: ignore[assignment]
    s._pending_tp = object()  # type: ignore[assignment]

    evt = _event(OrderRejected, client_order_id="ENTRY", reason="rejected")
    s.on_order_rejected(evt)

    assert s._pending_sl is None
    assert s._pending_tp is None
    assert s._entry_client_order_id is None


def test_ioc_cancel_clears_pending() -> None:
    s = DummyStrategy()

    s._entry_client_order_id = "ENTRY"
    s._pending_sl = object()  # type: ignore[assignment]
    s._pending_tp = object()  # type: ignore[assignment]

    evt = _event(OrderCanceled, client_order_id="ENTRY")
    s.on_order_canceled(evt)

    assert s._pending_sl is None
    assert s._pending_tp is None
    assert s._entry_client_order_id is None


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


def test_bracket_tp_reject_does_not_trigger_failsafe() -> None:
    s = DummyStrategy()

    s._position = object()  # type: ignore[assignment]
    s._bracket_sl_client_order_id = "SL"
    s._bracket_sl_confirmed = True
    s._bracket_tp_client_order_id = "TP"

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

        def __sub__(self, other: "_Px") -> float:
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


def test_position_opened_without_protective_orders_triggers_failsafe() -> None:
    s = DummyStrategy()

    # Provide a minimal Position-like object directly (avoid patching Nautilus Actor cache).
    s._position = type(
        "Pos",
        (),
        {
            "side": PositionSide.LONG,
            "avg_px_open": type("Px", (), {"as_double": lambda _self: 1.0})(),
            "quantity": type("Qty", (), {"as_double": lambda _self: 1.0})(),
            "id": "POS-1",
            "realized_pnl": 0.0,
        },
    )()  # type: ignore[assignment]

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
