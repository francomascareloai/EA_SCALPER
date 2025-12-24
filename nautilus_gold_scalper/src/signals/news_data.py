from __future__ import annotations

from typing import Any

from nautilus_trader.core.data import Data
from nautilus_trader.model import InstrumentId
from nautilus_trader.serialization.base import register_serializable_type

# These are optional at runtime; keep them typed as Any to avoid mypy issues when
# NautilusTrader modules are treated as Any (ignore_missing_imports).
try:
    import pyarrow as pa
except Exception:  # pragma: no cover
    pa = None

try:
    from nautilus_trader.serialization.arrow.serializer import register_arrow
except Exception:  # pragma: no cover
    register_arrow = None


class NewsWindowData(Data):  # type: ignore[misc]
    instrument_id: InstrumentId
    in_window: bool
    action: int
    minutes_to_event: int
    is_before_event: bool
    score_adjustment: int
    size_multiplier: float
    event_name: str
    currency: str
    impact: int
    reason: str

    def __init__(
        self,
        *,
        instrument_id: InstrumentId,
        in_window: bool,
        action: int,
        minutes_to_event: int,
        is_before_event: bool,
        score_adjustment: int,
        size_multiplier: float,
        event_name: str,
        currency: str,
        impact: int,
        reason: str,
        ts_event: int = 0,
        ts_init: int = 0,
    ) -> None:
        self.instrument_id = instrument_id
        self.in_window = in_window
        self.action = action
        self.minutes_to_event = minutes_to_event
        self.is_before_event = is_before_event
        self.score_adjustment = score_adjustment
        self.size_multiplier = size_multiplier
        self.event_name = event_name
        self.currency = currency
        self.impact = impact
        self.reason = reason
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
            "in_window": bool(self.in_window),
            "action": int(self.action),
            "minutes_to_event": int(self.minutes_to_event),
            "is_before_event": bool(self.is_before_event),
            "score_adjustment": int(self.score_adjustment),
            "size_multiplier": float(self.size_multiplier),
            "event_name": str(self.event_name),
            "currency": str(self.currency),
            "impact": int(self.impact),
            "reason": str(self.reason),
            "type": self.__class__.__name__,
            "ts_event": int(self._ts_event),
            "ts_init": int(self._ts_init),
        }

    @classmethod
    def from_dict(cls, data: dict[str, Any]) -> NewsWindowData:
        data.pop("type", None)
        if "instrument_id" in data:
            data["instrument_id"] = InstrumentId.from_str(data["instrument_id"])
        return cls(**data)


def _register_news_window_data_serialization() -> None:
    try:
        register_serializable_type(NewsWindowData, NewsWindowData.to_dict, NewsWindowData.from_dict)
    except KeyError:
        pass

    if pa is None or register_arrow is None:
        return

    schema = pa.schema(
        {
            "instrument_id": pa.string(),
            "in_window": pa.bool_(),
            "action": pa.int64(),
            "minutes_to_event": pa.int64(),
            "is_before_event": pa.bool_(),
            "score_adjustment": pa.int64(),
            "size_multiplier": pa.float64(),
            "event_name": pa.string(),
            "currency": pa.string(),
            "impact": pa.int64(),
            "reason": pa.string(),
            "type": pa.string(),
            "ts_event": pa.int64(),
            "ts_init": pa.int64(),
        },
    )

    def encode(obj: NewsWindowData) -> pa.RecordBatch:
        return pa.RecordBatch.from_pylist([obj.to_dict()], schema=schema)

    def decode(table: pa.Table) -> list[NewsWindowData]:
        return [NewsWindowData.from_dict(d) for d in table.to_pylist()]

    try:
        register_arrow(
            data_cls=NewsWindowData,
            schema=schema,
            encoder=encode,
            decoder=decode,
        )
    except (KeyError, ValueError):
        pass


_register_news_window_data_serialization()
