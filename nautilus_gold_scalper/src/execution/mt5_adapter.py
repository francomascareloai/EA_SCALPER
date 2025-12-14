"""
MT5 adapter (offline-safe) for Nautilus execution pipeline.

Design goals:
- Default to simulator mode using tick files (CSV/Parquet).
- Provide the same API as BaseExecutionAdapter.
- Stub methods ready for real MT5 bridge (e.g., via MetaTrader Python gateway).
"""
from __future__ import annotations

from pathlib import Path
from typing import Optional

from .base_adapter import BaseExecutionAdapter


class MT5Adapter(BaseExecutionAdapter):
    """
    MetaTrader 5 adapter skeleton.

    To hook up to a real MT5 terminal:
    - Implement _mt5_connect() using MetaTrader5 package or a DLL bridge.
    - Override send_order/cancel_order to call MT5 trade calls.
    - Keep offline mode intact for deterministic backtests.
    """

    def __init__(
        self,
        symbol: str = "XAUUSD",
        data_path: Optional[Path] = None,
        mt5_login: Optional[int] = None,
        mt5_password: Optional[str] = None,
        mt5_server: Optional[str] = None,
    ):
        super().__init__(name="MT5", symbol=symbol, data_path=data_path)
        self._mt5_login = mt5_login
        self._mt5_password = mt5_password
        self._mt5_server = mt5_server

    def connect(self) -> None:
        # Offline-first: mark connected even without MT5 credentials
        # Real connection can be implemented later to avoid breaking flows.
        super().connect()

