"""
src.execution package - Trade execution and order management.

Note: apex_adapter.py archived to _archive/ (will use NinjaTrader instead)
"""

from .trade_manager import TradeManager, TradeInfo
from .base_adapter import BaseExecutionAdapter, TickEvent
from .mt5_adapter import MT5Adapter
from .ninjatrader_adapter import NinjaTraderAdapter

__all__ = [
    'TradeManager',
    'TradeInfo',
    'BaseExecutionAdapter',
    'TickEvent',
    'MT5Adapter',
    'NinjaTraderAdapter',
]
