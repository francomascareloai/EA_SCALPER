from __future__ import annotations

from typing import Any

from nautilus_gold_scalper.src.strategies.base_strategy import BaseGoldStrategy, BaseStrategyConfig
from nautilus_trader.model.identifiers import InstrumentId


class DummyConfig(BaseStrategyConfig):
    instrument_id = InstrumentId.from_str("XAUUSD.SIM")
    seed = 42


class InvalidTwapConfig(BaseStrategyConfig):
    instrument_id = InstrumentId.from_str("XAUUSD.SIM")
    seed = 42
    twap_enabled = True
    twap_horizon_secs = 10.0
    twap_interval_secs = 20.0


class DummyStrategy(BaseGoldStrategy):
    def __init__(self, *, config: BaseStrategyConfig) -> None:
        super().__init__(config=config)
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


def test_twap_invalid_params_fail_closed() -> None:
    s = DummyStrategy(config=InvalidTwapConfig(instrument_id=InstrumentId.from_str("XAUUSD.SIM")))

    s._is_trading_allowed = True
    s._execution_failsafe_triggered = False

    twap = s._twap_exec_for_entry()
    assert twap is None

    assert s._execution_failsafe_triggered is True
    assert s._is_trading_allowed is False
