from __future__ import annotations

from typing import Any

from nautilus_trader.core.data import Data
from nautilus_trader.model import InstrumentId
from nautilus_trader.serialization.base import register_serializable_type

# Optional at runtime; keep typed as Any to avoid mypy issues when NautilusTrader
# modules are treated as Any (ignore_missing_imports).
try:
    import pyarrow as pa
except Exception:  # pragma: no cover
    pa = None

try:
    from nautilus_trader.serialization.arrow.serializer import register_arrow
except Exception:  # pragma: no cover
    register_arrow = None


class StrategyEventData(Data):  # type: ignore[misc]
    instrument_id: InstrumentId
    name: str
    payload_json: str

    def __init__(
        self,
        *,
        instrument_id: InstrumentId,
        name: str,
        payload_json: str,
        ts_event: int = 0,
        ts_init: int = 0,
    ) -> None:
        self.instrument_id = instrument_id
        self.name = str(name)
        self.payload_json = str(payload_json)
        self._ts_event = int(ts_event)
        self._ts_init = int(ts_init)

    @property
    def ts_event(self) -> int:
        return self._ts_event

    @property
    def ts_init(self) -> int:
        return self._ts_init

    def to_dict(self) -> dict[str, Any]:
        return {
            "instrument_id": self.instrument_id.value,
            "name": str(self.name),
            "payload_json": str(self.payload_json),
            "type": self.__class__.__name__,
            "ts_event": int(self._ts_event),
            "ts_init": int(self._ts_init),
        }

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> StrategyEventData:
        data.pop("type", None)
        if "instrument_id" in data:
            data["instrument_id"] = InstrumentId.from_str(data["instrument_id"])
        return cls(**data)


def _register_strategy_event_data_serialization() -> None:
    try:
        register_serializable_type(
            StrategyEventData,
            StrategyEventData.to_dict,
            StrategyEventData.from_dict,
        )
    except KeyError:
        pass

    if pa is None or register_arrow is None:
        return

    schema = pa.schema(
        {
            "instrument_id": pa.string(),
            "name": pa.string(),
            "payload_json": pa.string(),
            "type": pa.string(),
            "ts_event": pa.int64(),
            "ts_init": pa.int64(),
        },
    )

    def encode(obj: StrategyEventData) -> pa.RecordBatch:
        return pa.RecordBatch.from_pylist([obj.to_dict()], schema=schema)

    def decode(table: pa.Table) -> list[StrategyEventData]:
        return [StrategyEventData.from_dict(d) for d in table.to_pylist()]

    try:
        register_arrow(
            data_cls=StrategyEventData,
            schema=schema,
            encoder=encode,
            decoder=decode,
        )
    except (KeyError, ValueError):
        pass


_register_strategy_event_data_serialization()
