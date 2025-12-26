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
from datetime import datetime, timezone
from enum import IntEnum
from typing import Any

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
    # H4 FIX: Legacy dollar-based limits DEPRECATED.
    # These are kept for backward compatibility but should NOT be used.
    # Use DDProtectionCalculator (percentage-based) instead.
    # The percentage system (4% halt, 5% Apex limit) is authoritative.
    daily_loss_limit: float = 3_000.0  # DEPRECATED: use DDProtectionCalculator
    trailing_drawdown: float = 3_000.0  # DEPRECATED: use DDProtectionCalculator
    buffer_pct: float = 0.1  # 10% buffer for prudence
    max_contracts: int = (
        1000  # Raised for XAUUSD CFD (no real contract limit); override for MGC futures
    )

    def __post_init__(self) -> None:
        """R10-FIX: Validate account_size to prevent div/0 in DD calculations."""
        if self.account_size <= 0:
            raise ValueError(f"account_size must be positive, got {self.account_size}")


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
    dd_protection: DDProtectionState | None = None


class PropFirmManager:
    """
    Simple prop-firm guardrails:
    - Daily loss limit with buffer
    - Trailing drawdown
    - Max contracts
    - Win/loss streak momentum factor
    """

    def __init__(self, limits: PropFirmLimits | None = None, *, raise_on_breach: bool = True):
        self.limits = limits or PropFirmLimits()
        self._raise_on_breach = bool(raise_on_breach)
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
        self._terminated = False

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

    def set_strategy(self, strategy: Any) -> None:
        """Optional: attach strategy for hard stops/flatten on breach."""
        self._strategy = strategy

    # -------------------- updates
    @staticmethod
    def _resolve_now(now: datetime | None) -> datetime:
        return now if now is not None else datetime.now(timezone.utc)

    def update_equity(self, equity: float, now: datetime | None = None) -> None:
        """Update current equity and high-water mark.

        H3 FIX: IMPORTANT - Conservative Price Requirement for Apex Compliance.

        Per CLAUDE.md hwm_trap_warning and price_basis rules:
        - LONG positions: caller MUST compute unrealized P/L using BID price
        - SHORT positions: caller MUST compute unrealized P/L using ASK price
        - NEVER use MID price - it artificially inflates unrealized profit

        The equity parameter should reflect:
            equity = account_balance + sum(unrealized_pnl_at_conservative_prices)

        Where unrealized_pnl_at_conservative_prices uses:
            LONG: (bid_price - entry_price) * position_size
            SHORT: (entry_price - ask_price) * position_size

        This ensures HWM is not artificially inflated by optimistic mid-price valuations.

        Args:
            equity: Current account equity INCLUDING unrealized P/L computed with
                    conservative (BID for longs, ASK for shorts) prices.
            now: Optional timestamp for the update.
        """
        if not self._initialized:
            self.initialize(equity)
        self._equity = equity
        if equity > self._high_water:
            self._high_water = equity
        self._last_update = self._resolve_now(now)

    def register_trade_close(
        self,
        contracts: float,
        profit: float,
        now: datetime | None = None,
        *,
        equity: float | None = None,
    ) -> None:
        """Register a realized trade result.

        IMPORTANT: Do NOT add `profit` on top of `self._equity`.

        `update_equity()` is called intrabar with mark-to-market equity
        (balance + unrealized PnL). When the position closes, that unrealized PnL
        becomes realized PnL, but the account equity should remain the same.

        If callers have an explicit post-close equity snapshot (e.g., realized
        balance after fees/slippage), pass it via `equity=`.
        """
        _ = contracts  # kept for compatibility / future sizing hooks
        now_dt = self._resolve_now(now)
        now_et = now_dt.astimezone(self._consistency.et_tz)

        if profit > 0:
            self._consecutive_wins += 1
            self._consecutive_losses = 0
        elif profit < 0:
            self._consecutive_losses += 1
            self._consecutive_wins = 0

        if equity is not None:
            self.update_equity(equity, now=now_dt)
        else:
            # Equity already includes unrealized PnL from MTM updates.
            # Avoid double-counting profit on close.
            self._last_update = now_dt

        self._consistency.update_profit(profit, now_et)

    def on_new_day(self, current_equity: float | None = None, now: datetime | None = None) -> None:
        """
        Reset daily loss tracking at start of trading day.
        Args:
            current_equity: equity snapshot to set as new daily start (optional)
        """
        now_dt = self._resolve_now(now)
        if current_equity is not None:
            self._equity = current_equity
        self._daily_start_equity = self._equity
        self._consecutive_wins = 0
        self._consecutive_losses = 0
        self._last_update = now_dt
        self._consistency.reset_daily()

    # -------------------- checks
    def can_trade(self, now: datetime | None = None) -> bool:
        now_dt = self._resolve_now(now)
        now_et = now_dt.astimezone(self._consistency.et_tz)
        state = self.get_state()
        if not state.is_trading_allowed:
            if self._terminated:
                return False
            self._terminated = True
            if self._raise_on_breach:
                self._hard_stop(state)
            return False
        if state.is_trading_allowed and not self._consistency.can_trade(now_et):
            return False
        return state.is_trading_allowed

    def ensure_compliance(self, now: datetime | None = None) -> PropFirmState:
        """Enforce hard stop when already in breach.

        This is intended for intrabar checks while positions are open.
        """
        now_dt = self._resolve_now(now)
        state = self.get_state()
        if (
            state.is_hard_breached
            or (state.dd_protection is not None and not state.dd_protection.can_trade)
        ) and not self._terminated:
            self._terminated = True
            if self._raise_on_breach:
                self._hard_stop(state)
        return state

    def validate_trade(self, risk_amount: float, contracts: float) -> tuple[bool, str]:
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

        # CRUCIBLE FIX: Single trade loss cap (flash crash protection)
        # Formula: potential_loss_pct = risk_amount / equity * 100
        # Example: risk=1500, equity=100000 -> 1500/100000*100 = 1.5%
        SINGLE_TRADE_LOSS_CAP = 0.015  # 1.5% max per trade
        if self._equity > 0:
            potential_loss_pct = risk_amount / self._equity
            # R10-FIX: Replace assert with explicit validation.
            # Assert is disabled with python -O, bypassing this safety check.
            if not (0 <= potential_loss_pct <= 1):
                raise ValueError(f"Invalid loss pct: {potential_loss_pct}")
            if potential_loss_pct > SINGLE_TRADE_LOSS_CAP:
                return (
                    False,
                    f"Single trade loss {potential_loss_pct * 100:.2f}% exceeds {SINGLE_TRADE_LOSS_CAP * 100}% cap",
                )

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
            current_equity=self._equity,
        )

    # -------------------- metrics
    def get_state(self) -> PropFirmState:
        daily_loss = max(0.0, self._daily_start_equity - self._equity)
        trailing_dd = max(0.0, self._high_water - self._equity)

        # H4 FIX: Use DDProtectionCalculator (percentage-based) as authoritative source.
        # Legacy dollar-based checks are DEPRECATED and kept only for backward compatibility.
        # The dd_protection state determines risk level and trading permission.
        dd_protection = self.get_dd_protection_state()

        # Map DDProtectionState to RiskLevel for backward compatibility
        # Per CLAUDE.md dd_limits:
        # Trailing: WARN 3.0%, CAUTION 3.5%, CRITICAL 4.0%, HALT 4.5%, TERMINATED 5.0%
        # Daily: WARN 1.5%, CAUTION 2.0%, REDUCE 2.5%, HALT 3.0%
        risk_level = RiskLevel.NORMAL
        is_hard_breached = False

        if not dd_protection.can_trade:
            # DDProtectionCalculator halted trading (trailing >= 4% or daily >= 3%)
            risk_level = RiskLevel.BREACHED
            is_hard_breached = True
        elif dd_protection.total_dd_pct >= 4.0 or dd_protection.daily_dd_pct >= 3.0:
            # CRITICAL zone: at halt thresholds (4.0% trailing, 3.0% daily)
            risk_level = RiskLevel.CRITICAL
        elif dd_protection.total_dd_pct >= 3.5 or dd_protection.daily_dd_pct >= 2.5:
            # HIGH risk zone (CAUTION trailing, REDUCE daily)
            risk_level = RiskLevel.HIGH
        elif dd_protection.total_dd_pct >= 3.0 or dd_protection.daily_dd_pct >= 2.0:
            # ELEVATED risk zone (WARN trailing, CAUTION daily)
            risk_level = RiskLevel.ELEVATED
        else:
            risk_level = RiskLevel.NORMAL

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
            logger = getattr(self._strategy, "log", None)
            log_fn = (
                getattr(logger, "critical", None)
                or getattr(logger, "error", None)
                or getattr(logger, "warning", None)
            )
            if callable(log_fn):
                log_fn(
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
