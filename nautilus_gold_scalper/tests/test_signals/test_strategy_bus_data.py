from __future__ import annotations

from nautilus_gold_scalper.src.signals.strategy_bus_data import StrategyEventData
from nautilus_trader.model.identifiers import InstrumentId


def test_strategy_event_data_round_trip() -> None:
    obj = StrategyEventData(
        instrument_id=InstrumentId.from_str("XAUUSD.SIM"),
        name="unit_test",
        payload_json="{}",
        ts_event=123,
        ts_init=456,
    )
    d = obj.to_dict()
    obj2 = StrategyEventData.from_dict(d)

    assert obj2.instrument_id == obj.instrument_id
    assert obj2.name == obj.name
    assert obj2.payload_json == obj.payload_json
    assert obj2.ts_event == obj.ts_event
    assert obj2.ts_init == obj.ts_init
