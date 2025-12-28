from __future__ import annotations

from typing import Any

from nautilus_gold_scalper.src.strategies.base_strategy import BaseGoldStrategy, BaseStrategyConfig
from nautilus_trader.model.identifiers import InstrumentId


class DummyConfig(BaseStrategyConfig):
    instrument_id = InstrumentId.from_str("XAUUSD.SIM")
    seed = 42


class DummyStrategy(BaseGoldStrategy):
    def __init__(self) -> None:
        super().__init__(config=DummyConfig(instrument_id=InstrumentId.from_str("XAUUSD.SIM")))
        self.instrument = None

        # Mimic GoldScalperStrategy where time manager exists as a private attribute.
        class _TM:
            def __init__(self) -> None:
                self._issued: set[str] = set()
                self._close_orders_submitted = False
                self._close_submitted_ts_ns: int | None = None
                self._flatten_complete = False
                self._close_retry_count = 0
                self._close_order_ids: list[Any] = []

            def check(self, _ts_ns: int) -> bool:
                return False

            def reset_daily(self) -> None:
                self._issued.clear()

        self._time_manager = _TM()

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


def test_on_save_contract_returns_bytes_dict() -> None:
    s = DummyStrategy()
    state = s.on_save()
    assert isinstance(state, dict)
    assert all(isinstance(k, str) for k in state.keys())
    assert all(isinstance(v, (bytes, bytearray)) for v in state.values())


def test_round_trip_preserves_fail_closed_latches() -> None:
    s1 = DummyStrategy()
    s1._trading_blocked_today = True
    s1._execution_failsafe_triggered = True
    s1._is_trading_allowed = False
    s1._last_market_ts_ns = 1

    blob = s1.on_save()

    s2 = DummyStrategy()
    s2.on_load(blob)

    assert s2._trading_blocked_today is True
    assert s2._execution_failsafe_triggered is True
    assert s2._is_trading_allowed is False


def test_corrupted_state_fails_closed() -> None:
    s = DummyStrategy()
    s._is_trading_allowed = True

    s.on_load({"base": b"not-json"})

    assert s._execution_failsafe_triggered is True
    assert s._is_trading_allowed is False
