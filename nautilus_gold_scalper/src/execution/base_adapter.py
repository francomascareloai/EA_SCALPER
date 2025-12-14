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
from dataclasses import dataclass
from pathlib import Path
from typing import Generator, Optional, List, Dict

import pandas as pd


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
    """

    def __init__(self, name: str, symbol: str, data_path: Optional[Path] = None):
        self.name = name
        self.symbol = symbol
        self.data_path = data_path
        self._connected = False
        self._order_counter = itertools.count(1)
        self._orders: Dict[int, Dict] = {}

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
        price: Optional[float] = None,
        time_in_force: str = "GTC",
    ) -> int:
        """
        Store order locally and return order id.
        Subclasses can override to route to real venues.
        """
        if not self._connected:
            raise RuntimeError("Adapter not connected")
        oid = next(self._order_counter)
        self._orders[oid] = {
            "side": side,
            "qty": qty,
            "type": order_type,
            "price": price,
            "tif": time_in_force,
            "status": "NEW",
        }
        return oid

    def cancel_order(self, order_id: int) -> bool:
        if order_id in self._orders:
            self._orders[order_id]["status"] = "CANCELLED"
            return True
        return False

    def list_orders(self) -> List[Dict]:
        return [{**{"id": oid}, **info} for oid, info in self._orders.items()]

