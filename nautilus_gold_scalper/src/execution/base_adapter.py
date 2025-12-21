"""
Lightweight execution adapter interfaces for offline-friendly connectivity.

These classes are intentionally conservative: they default to an offline
simulation mode (file-backed tick stream) and maintain an in-memory order
ledger. This keeps backtests and dry-runs deterministic while allowing
runtime replacement with real connectors (MT5/NinjaTrader) when credentials
and transports are available.
"""
from __future__ import annotations

import itertools
from collections.abc import Generator
from dataclasses import dataclass
from datetime import datetime, time, timezone
from pathlib import Path

import pandas as pd

try:
    from zoneinfo import ZoneInfo

    _ET_TZ: ZoneInfo | None = ZoneInfo("America/New_York")
except Exception:  # pragma: no cover
    _ET_TZ = None


@dataclass
class TickEvent:
    """Minimal tick representation."""
    symbol: str
    timestamp: pd.Timestamp
    bid: float
    ask: float
    last: float
    volume: float


class BaseExecutionAdapter:
    """
    Base adapter with safe defaults.

    - Offline-first: if no connection params are provided, works in simulator mode.
    - Deterministic: order ids are incremental and stored in-memory.
    - Tick source: CSV/Parquet with bid/ask/last/volume columns.

    WP1/WP4 safety: enforces Apex time gates at the adapter layer as a last line of
    defense (strategy-level checks are not sufficient under stalls/miswiring).
    """

    def __init__(self, name: str, symbol: str, data_path: Path | None = None):
        self.name = name
        self.symbol = symbol
        self.data_path = data_path
        self._connected = False
        self._order_counter = itertools.count(1)
        self._orders: dict[int, dict[str, object]] = {}

    # --- Connectivity -----------------------------------------------------
    def connect(self) -> None:
        """Mark adapter as connected (or perform real connection in subclasses)."""
        self._connected = True

    def disconnect(self) -> None:
        self._connected = False

    def is_connected(self) -> bool:
        return self._connected

    # --- Market data ------------------------------------------------------
    def stream_ticks(self) -> Generator[TickEvent, None, None]:
        """
        Yield ticks from file (CSV/Parquet) for deterministic replay.
        Expected columns: time, bid, ask, last, volume (flexible names handled).
        """
        if self.data_path is None:
            raise RuntimeError("data_path not provided for tick streaming.")
        path = Path(self.data_path)
        if not path.exists():
            raise FileNotFoundError(path)

        if path.suffix.lower() in {".parquet", ".pq"}:
            df = pd.read_parquet(path)
        else:
            df = pd.read_csv(path)

        # Normalize column names
        cols = {c.lower(): c for c in df.columns}
        ts_col = cols.get("time") or cols.get("timestamp") or cols.get("datetime")
        bid_col = cols.get("bid") or cols.get("bidprice") or cols.get("bid_price")
        ask_col = cols.get("ask") or cols.get("askprice") or cols.get("ask_price")
        last_col = cols.get("last") or cols.get("lastprice") or cols.get("price") or ask_col
        vol_col = cols.get("volume") or cols.get("vol")

        for _, row in df.iterrows():
            yield TickEvent(
                symbol=self.symbol,
                timestamp=pd.to_datetime(row[ts_col]),
                bid=float(row[bid_col]),
                ask=float(row[ask_col]),
                last=float(row[last_col]),
                volume=float(row[vol_col]) if vol_col else 0.0,
            )

    # --- Orders -----------------------------------------------------------
    def send_order(
        self,
        side: str,
        qty: float,
        order_type: str = "market",
        price: float | None = None,
        time_in_force: str = "GTC",
        *,
        ts_utc: datetime | None = None,
    ) -> int:
        """Store order locally and return order id.

        Safety: Enforces Apex time gates in ET at the adapter boundary.
        - After 16:30 ET: blocks *new entries*.
        - Reduce-only / flatten orders are allowed at any time.

        If ET conversion is unavailable, fail-closed for new entries.

        Subclasses can override to route to real venues.
        """
        if not self._connected:
            raise RuntimeError("Adapter not connected")

        now_utc = ts_utc or datetime.now(timezone.utc)
        if now_utc.tzinfo is None:
            now_utc = now_utc.replace(tzinfo=timezone.utc)

        if not self._is_order_allowed(now_utc=now_utc, order_type=order_type):
            raise RuntimeError("Order blocked by Apex time gate")

        oid = next(self._order_counter)
        self._orders[oid] = {
            "side": side,
            "qty": qty,
            "type": order_type,
            "price": price,
            "tif": time_in_force,
            "status": "NEW",
            "ts_utc": now_utc,
        }
        return oid

    def _is_order_allowed(self, *, now_utc: datetime, order_type: str) -> bool:
        if _ET_TZ is None:
            return False

        dt_et = now_utc.astimezone(_ET_TZ)
        now_time = dt_et.time()

        urgent = time(16, 30)
        emergency = time(16, 55)
        cutoff = time(16, 59)

        order_type_norm = order_type.lower().strip()
        is_reduce_only = order_type_norm in {"close", "flatten", "reduce", "reduce_only"}

        # Reduce-only / flatten orders are allowed at any time.
        if is_reduce_only:
            return True

        # Never allow new entries after urgent.
        if now_time >= urgent:
            return False

        # Block any new orders after emergency/cutoff (defense in depth).
        if now_time >= emergency or now_time >= cutoff:
            return False

        return True

    def cancel_order(self, order_id: int) -> bool:
        if order_id in self._orders:
            self._orders[order_id]["status"] = "CANCELLED"
            return True
        return False

    def list_orders(self) -> list[dict[str, object]]:
        return [{**{"id": oid}, **info} for oid, info in self._orders.items()]

