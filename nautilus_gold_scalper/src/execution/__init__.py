"""
src.execution package - Trade execution and order management.

Note: apex_adapter.py archived to _archive/ (will use NinjaTrader instead)

HBS (Human Behavior Simulator) v2.2:
- human_config.py - Configuration dataclass with all HBS parameters
- human_simulator.py - Core HBS class with 18+ techniques
- economic_calendar.py - News event detection for volatility awareness
"""

from .base_adapter import BaseExecutionAdapter, TickEvent
from .delayed_executor import (
    DelayedExecutor,
    PendingExecution,
)
from .economic_calendar import (
    HIGH_IMPACT_EVENTS,
    MEDIUM_IMPACT_EVENTS,
    EconomicCalendar,
    EconomicEvent,
)

# HBS modules
from .human_config import (
    HumanSimConfig,
    get_aggressive_config,
    get_backtest_config,
    get_conservative_config,
    get_default_config,
    get_evaluation_config,
)
from .human_simulator import (
    HBSDecision,
    HBSState,
    HumanBehaviorSimulator,
)
from .mt5_adapter import MT5Adapter
from .ninjatrader_adapter import NinjaTraderAdapter
from .order_lifecycle import (
    OrderLifecycleManager,
    OrderState,
    OrderType,
    TrackedOrder,
)
from .trade_manager import TradeInfo, TradeManager

__all__ = [
    # Existing
    'TradeManager',
    'TradeInfo',
    'BaseExecutionAdapter',
    'TickEvent',
    'MT5Adapter',
    'NinjaTraderAdapter',
    # HBS Config
    'HumanSimConfig',
    'get_default_config',
    'get_aggressive_config',
    'get_conservative_config',
    'get_evaluation_config',
    'get_backtest_config',
    # HBS Core
    'HumanBehaviorSimulator',
    'HBSState',
    'HBSDecision',
    # Economic Calendar
    'EconomicCalendar',
    'EconomicEvent',
    'HIGH_IMPACT_EVENTS',
    'MEDIUM_IMPACT_EVENTS',
]
