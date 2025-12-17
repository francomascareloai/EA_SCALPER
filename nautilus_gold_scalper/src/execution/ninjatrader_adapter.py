"""
NinjaTrader adapter (offline-safe) for Nautilus execution pipeline.

Design goals identical to MT5Adapter:
- Works in pure offline/simulator mode by default.
- Clear extension points for a real NT8 bridge (DLL/REST/WS).
"""
from __future__ import annotations

from pathlib import Path

from .base_adapter import BaseExecutionAdapter


class NinjaTraderAdapter(BaseExecutionAdapter):
    """
    NinjaTrader 8 adapter skeleton.

    Real connectivity options (to be implemented when credentials/transport are available):
    - DLL bridge via NinjaScript add-on exposing sockets.
    - REST/WebSocket ATI bridge.
    - IB -> NT passthrough.
    """

    def __init__(
        self,
        symbol: str = "XAUUSD",
        data_path: Path | None = None,
        host: str | None = None,
        port: int | None = None,
        api_key: str | None = None,
    ):
        super().__init__(name="NINJATRADER", symbol=symbol, data_path=data_path)
        self._host = host
        self._port = port
        self._api_key = api_key

    def connect(self) -> None:
        # Offline-first; real socket/REST handshake can be added later.
        super().connect()

