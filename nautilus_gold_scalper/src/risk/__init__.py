"""
Risk Management Module for Nautilus Gold Scalper.

Comprehensive risk management system for prop firm compliance:
- PropFirmManager: Daily/total drawdown limits
- PositionSizer: Kelly, ATR, adaptive position sizing
- DrawdownTracker: Real-time DD monitoring with alerts
- VaRCalculator: Value at Risk and CVaR calculations
- CircuitBreaker: Multi-level trading protection (6 levels)

Example:
    from src.risk import PropFirmManager, PositionSizer, DrawdownTracker, CircuitBreaker
    
    # Initialize risk manager
    prop_manager = PropFirmManager(account_balance=100_000)
    
    # Initialize position sizer
    sizer = PositionSizer(method=LotSizeMethod.KELLY)
    
    # Initialize drawdown tracker
    dd_tracker = DrawdownTracker(initial_equity=100_000)
    
    # Initialize circuit breaker
    circuit_breaker = CircuitBreaker(daily_loss_limit=0.05, total_loss_limit=0.10)
    
    # Before trade
    if prop_manager.check_can_trade() and circuit_breaker.can_trade():
        risk_amount = prop_manager.calculate_risk_amount()
        lot = sizer.calculate_lot(
            balance=100_000,
            stop_loss_pips=50,
            pip_value=10.0
        )
        # Apply circuit breaker size reduction
        lot *= circuit_breaker.get_size_multiplier()
        # Execute trade...
    
    # After trade
    prop_manager.register_trade_result(profit=250)
    sizer.register_trade_result(profit=250)
    dd_tracker.update(current_equity=100_250)
    circuit_breaker.register_trade_result(pnl=250, is_win=True)
    circuit_breaker.update_equity(current_equity=100_250)
"""

from .prop_firm_manager import PropFirmManager, PropFirmLimits, PropFirmState, RiskLevel, AccountTerminatedException
from .position_sizer import PositionSizer, LotSizeMethod
from .drawdown_tracker import DrawdownTracker, DrawdownSnapshot
from .var_calculator import VaRCalculator
from .circuit_breaker import CircuitBreaker, CircuitBreakerLevel, CircuitBreakerState
from .spread_monitor import SpreadMonitor, SpreadState, SpreadSnapshot as SpreadSnapshot_
from .time_constraint_manager import TimeConstraintManager
from .consistency_tracker import ConsistencyTracker

__all__ = [
    "PropFirmManager",
    "PropFirmLimits",
    "PropFirmState",
    "RiskLevel",
    "AccountTerminatedException",
    "PositionSizer",
    "LotSizeMethod",
    "DrawdownTracker",
    "DrawdownSnapshot",
    "VaRCalculator",
    "CircuitBreaker",
    "CircuitBreakerLevel",
    "CircuitBreakerState",
    "SpreadMonitor",
    "SpreadState",
    "SpreadSnapshot_",
    "TimeConstraintManager",
    "ConsistencyTracker",
]

__version__ = "1.1.0"
