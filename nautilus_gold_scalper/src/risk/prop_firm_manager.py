"""
Prop Firm Manager – compliance and risk throttling for prop accounts.

API aligns with tests in tests/test_risk/test_prop_firm_manager.py while
keeping lightweight hooks for runtime use in run_backtest.

AGENTS.md v3.7.0 Integration:
- Multi-tier DD protection (daily 1.5%→3.0%, total 3.0%→5.0%)
- Dynamic daily limit: MIN(3%, Remaining Buffer × 0.6)
- SENTINEL enforcement of both daily and total DD limits
"""
from __future__ import annotations

from dataclasses import dataclass
from enum import IntEnum
from typing import Optional, Tuple
from datetime import datetime, timezone
from decimal import Decimal

from .consistency_tracker import ConsistencyTracker
from .dd_protection import DDProtectionCalculator, DDProtectionState


class AccountTerminatedException(Exception):
    """Raised when Apex Trading limits are breached (DD > 5% or consistency rule violated)."""
    pass


class RiskLevel(IntEnum):
    NORMAL = 0
    ELEVATED = 1
    HIGH = 2
    CRITICAL = 3
    BREACHED = 4


@dataclass
class PropFirmLimits:
    account_size: float = 100_000.0
    daily_loss_limit: float = 3_000.0          # absolute $
    trailing_drawdown: float = 3_000.0         # absolute $
    buffer_pct: float = 0.1                    # 10% buffer for prudence
    max_contracts: int = 20


@dataclass
class PropFirmState:
    is_trading_allowed: bool
    is_hard_breached: bool
    risk_level: RiskLevel
    daily_loss_current: float
    trailing_dd_current: float
    consecutive_wins: int
    consecutive_losses: int
    # AGENTS.md v3.7.0 Multi-Tier DD fields
    dd_protection: Optional[DDProtectionState] = None


class PropFirmManager:
    """
    Simple prop-firm guardrails:
    - Daily loss limit with buffer
    - Trailing drawdown
    - Max contracts
    - Win/loss streak momentum factor
    """

    def __init__(self, limits: Optional[PropFirmLimits] = None):
        self.limits = limits or PropFirmLimits()
        self._initialized = False
        self._start_equity = self.limits.account_size
        self._equity = self.limits.account_size
        self._daily_start_equity = self.limits.account_size
        self._high_water = self.limits.account_size
        self._consecutive_wins = 0
        self._consecutive_losses = 0
        self._last_update = datetime.now(timezone.utc)
        self._strategy = None  # optional hook for stop/flatten on breach
        self._consistency = ConsistencyTracker(initial_balance=self.limits.account_size)

    # -------------------- lifecycle
    def initialize(self, starting_equity: float) -> None:
        self._start_equity = starting_equity
        self._equity = starting_equity
        self._daily_start_equity = starting_equity
        self._high_water = starting_equity
        self._consecutive_wins = 0
        self._consecutive_losses = 0
        self._initialized = True
        self._last_update = datetime.now(timezone.utc)

    def set_strategy(self, strategy) -> None:
        """Optional: attach strategy for hard stops/flatten on breach."""
        self._strategy = strategy

    # -------------------- updates
    def update_equity(self, equity: float) -> None:
        if not self._initialized:
            self.initialize(equity)
        self._equity = equity
        if equity > self._high_water:
            self._high_water = equity
        self._last_update = datetime.now(timezone.utc)

    def register_trade_close(self, contracts: float, profit: float) -> None:
        if profit > 0:
            self._consecutive_wins += 1
            self._consecutive_losses = 0
        elif profit < 0:
            self._consecutive_losses += 1
            self._consecutive_wins = 0
        self.update_equity(self._equity + profit)
        self._consistency.update_profit(profit, datetime.now(timezone.utc))

    def on_new_day(self, current_equity: Optional[float] = None) -> None:
        """
        Reset daily loss tracking at start of trading day.
        Args:
            current_equity: equity snapshot to set as new daily start (optional)
        """
        if current_equity is not None:
            self._equity = current_equity
        self._daily_start_equity = self._equity
        self._consecutive_wins = 0
        self._consecutive_losses = 0
        self._last_update = datetime.now(timezone.utc)
        self._consistency.reset_daily()

    # -------------------- checks
    def can_trade(self) -> bool:
        state = self.get_state()
        if not state.is_trading_allowed:
            self._hard_stop(state)
        if state.is_trading_allowed and not self._consistency.can_trade(datetime.now(timezone.utc)):
            return False
        return state.is_trading_allowed

    def validate_trade(self, risk_amount: float, contracts: float) -> Tuple[bool, str]:
        """
        Validate trade against prop firm limits.
        Includes AGENTS.md v3.7.0 multi-tier DD protection.
        
        Args:
            risk_amount: Risk in absolute dollars
            contracts: Number of contracts
            
        Returns:
            (allowed, reason)
        """
        if contracts > self.limits.max_contracts:
            return False, "Max contracts exceeded"

        # Legacy daily limit check (keep for backward compatibility)
        available = self.get_max_risk_available()
        if risk_amount > available:
            return False, "Daily limit would be exceeded"
        
        # AGENTS.md v3.7.0 Multi-Tier DD Protection
        dd_state = self.get_dd_protection_state()
        risk_pct = (risk_amount / self._equity) * 100 if self._equity > 0 else 0
        allowed, reason = DDProtectionCalculator.validate_trade(dd_state, risk_pct)
        
        if not allowed:
            return False, f"DD Protection: {reason}"
        
        return True, ""

    # -------------------- DD Protection Integration (AGENTS.md v3.7.0)
    def get_dd_protection_state(self) -> DDProtectionState:
        """
        Get current DD protection state with multi-tier limits.
        Implements AGENTS.md v3.7.0 specification.
        """
        return DDProtectionCalculator.calculate_state(
            hwm=self._high_water,
            day_start_balance=self._daily_start_equity,
            current_equity=self._equity
        )
    
    # -------------------- metrics
    def get_state(self) -> PropFirmState:
        daily_loss = max(0.0, self._daily_start_equity - self._equity)
        trailing_dd = max(0.0, self._high_water - self._equity)

        daily_limit = self.limits.daily_loss_limit
        # risk levels based on % of limit
        pct = (daily_loss / daily_limit) * 100 if daily_limit else 0
        risk_level = RiskLevel.NORMAL
        is_hard_breached = False

        if pct >= 95 or trailing_dd >= self.limits.trailing_drawdown:
            risk_level = RiskLevel.CRITICAL
            is_hard_breached = True
        elif pct >= 75:
            risk_level = RiskLevel.HIGH
        elif pct >= 55:
            risk_level = RiskLevel.ELEVATED
        else:
            risk_level = RiskLevel.NORMAL

        # if beyond limits, mark breached
        if daily_loss >= daily_limit or trailing_dd >= self.limits.trailing_drawdown:
            risk_level = RiskLevel.BREACHED
            is_hard_breached = True

        # Get DD protection state (AGENTS.md v3.7.0 multi-tier system)
        dd_protection = self.get_dd_protection_state()
        
        return PropFirmState(
            is_trading_allowed=not is_hard_breached and dd_protection.can_trade,
            is_hard_breached=is_hard_breached,
            risk_level=risk_level,
            daily_loss_current=daily_loss,
            trailing_dd_current=trailing_dd,
            consecutive_wins=self._consecutive_wins,
            consecutive_losses=self._consecutive_losses,
            dd_protection=dd_protection,
        )

    def get_max_risk_available(self) -> float:
        daily_loss = max(0.0, self._daily_start_equity - self._equity)
        effective_limit = self.limits.daily_loss_limit * (1 - self.limits.buffer_pct)
        return max(0.0, effective_limit - daily_loss)

    def get_momentum_adjustment_factor(self) -> float:
        if self._consecutive_wins >= 2:
            return 1.08
        if self._consecutive_losses >= 2:
            return 0.70
        return 1.0

    # -------------------- hard stop helpers
    def _hard_stop(self, state: PropFirmState) -> None:
        """
        Stop strategy and flatten positions when breach occurs.
        Raises AccountTerminatedException after cleanup.
        """
        if self._strategy is None:
            raise AccountTerminatedException(
                f"Apex Trading limits breached: Daily loss={state.daily_loss_current:.2f}, "
                f"Trailing DD={state.trailing_dd_current:.2f}"
            )
        
        try:
            self._strategy.log.critical(
                f"APEX DD BREACH - stopping strategy. Daily={state.daily_loss_current:.2f}, "
                f"Trailing={state.trailing_dd_current:.2f}"
            )
            self._strategy.close_all_positions(self._strategy.config.instrument_id)
            self._strategy.stop()
        except Exception as e:
            # last resort: mark trading not allowed
            self._strategy._is_trading_allowed = False
            raise AccountTerminatedException(
                f"Apex Trading limits breached and cleanup failed: {e}"
            ) from e
        
        # Raise exception to signal termination even if cleanup succeeded
        raise AccountTerminatedException(
            f"Apex Trading account terminated: Daily={state.daily_loss_current:.2f}, "
            f"Trailing DD={state.trailing_dd_current:.2f}"
        )

    # -------------------- compatibility for run_backtest
    def check_can_trade(self) -> bool:
        if not self.can_trade():
            raise Exception("Prop firm limits breached")
        return True

    def register_trade_result(self, profit: float) -> None:
        # profit passed as dollars
        self.register_trade_close(1, profit)

    def register_trade_executed(self) -> None:
        # placeholder for compatibility
        return None

    def update_current_balance(self, balance: float) -> None:
        self.update_equity(balance)
