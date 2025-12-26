"""
Multi-Tier DD Protection System - AGENTS.md v3.7.0
===================================================
Implements comprehensive daily and total DD limits with dynamic adjustments.

Daily DD Limits (from day start balance):
- 1.5% WARNING → Log alert, continue cautiously
- 2.0% CAUTION → Proceed carefully (no size cut)
- 2.5% REDUCE → Cut position sizes to 50%
- 3.0% EMERGENCY_HALT → Force close all, end day

Total DD Limits (from high-water mark):
- 3.0% WARNING → Review strategy, reduce daily limit to 2.5%
- 3.5% CONSERVATIVE → Daily limit 2.0%, A+ setups only
- 4.0% CRITICAL → Daily limit 1.0%, perfect setups only
- 4.5% HALT_ALL → Halt trading, plan recovery
- 5.0% TERMINATED → Account terminated by Apex

Dynamic Daily Limit: MIN(3%, Remaining Buffer × 0.6)
"""

import math
from dataclasses import dataclass
from enum import Enum
from typing import NamedTuple


class DDAction(Enum):
    """DD Protection Actions"""

    NONE = "Continue Normal"
    WARNING = "Log Alert"
    REDUCE = "Cut Sizes 50%"
    STOP_NEW = "No New Trades"
    EMERGENCY_HALT = "Force Close All"
    HALT_ALL = "Halt Trading"
    TERMINATED = "Account Terminated"


@dataclass
class DDTier:
    """DD Threshold Tier"""

    threshold_pct: float
    action: DDAction
    severity: str
    response: str
    rationale: str


# Daily DD Tiers (from day start balance)
# Per CLAUDE.md dd_limits: WARN 1.5%, CAUTION 2.0%, REDUCE 2.5%, HALT 3.0%
DAILY_DD_TIERS = [
    DDTier(
        1.5,
        DDAction.WARNING,
        "[!]",
        "Log alert, continue trading cautelosamente",
        "Primeiro sinal (WARN) - revisar estratégia intraday",
    ),
    DDTier(
        2.0,
        DDAction.WARNING,
        "[!]",
        "CAUTION: Proceed carefully, apenas setups A/B rating",
        "CAUTION level - vigilância aumentada, sem corte de tamanho ainda",
    ),
    DDTier(
        2.5,
        DDAction.REDUCE,
        "[!!]",
        "REDUCE: Cortar position sizes para 50%",
        "REDUCE level - reduzir exposição imediatamente",
    ),
    DDTier(
        3.0,
        DDAction.EMERGENCY_HALT,
        "[!!!]",
        "HALT: FORCE CLOSE ALL positions, END trading for day, LOG incident",
        "HALT level - limite máximo diário atingido",
    ),
]

# Total DD Tiers (from high-water mark)
# Per CLAUDE.md dd_limits: WARN 3.0%, CAUTION 3.5%, CRITICAL 4.0%, HALT 4.5%, TERMINATED 5.0%
# NOTE: Project non-negotiable: hard block at trailing DD >= 4.0% (safety buffer before Apex 5%).
TOTAL_DD_TIERS = [
    DDTier(
        3.0,
        DDAction.WARNING,
        "[!]",
        "WARN: Revisar estratégia geral, reduzir daily DD limit para 2.5%",
        "WARN level (40% buffer consumed) - ajustar conservadorismo",
    ),
    DDTier(
        3.5,
        DDAction.WARNING,
        "[!]",
        "CAUTION: Daily DD limit reduzido para 2.0%, apenas A+ setups",
        "CAUTION level (30% buffer remaining) - trading altamente seletivo",
    ),
    DDTier(
        4.0,
        DDAction.HALT_ALL,
        "[!!]",
        "CRITICAL: HALT all trading immediately (safety buffer before Apex limit)",
        "CRITICAL level - Hard-block at 4.0% to avoid Apex termination risk",
    ),
    DDTier(
        4.5,
        DDAction.HALT_ALL,
        "[!!!]",
        "HALT: Trading suspended - extremely close to Apex 5% limit",
        "HALT level - apenas 0.5% de buffer restante, emergency mode",
    ),
    DDTier(
        5.0,
        DDAction.TERMINATED,
        "[X]",
        "TERMINATED: ACCOUNT TERMINATED by Apex Trading - sem apelação",
        "TERMINATED level - Limite Apex atingido, falha total de risk management",
    ),
]


class DDProtectionState(NamedTuple):
    """Complete DD protection state"""

    # DD measurements
    daily_dd_pct: float
    total_dd_pct: float
    remaining_buffer_pct: float
    max_daily_dd_pct: float

    # Actions triggered
    daily_action: DDAction
    total_action: DDAction

    # Tier information
    daily_tier: str
    total_tier: str

    # Trading permissions
    can_trade: bool
    can_open_new: bool
    position_size_factor: float  # 0.5 = 50% reduction, 1.0 = normal

    # Dollar amounts (for compatibility)
    daily_dd_usd: float
    total_dd_usd: float


class DDProtectionCalculator:
    """
    Calculates DD protection state based on account metrics.
    Stateless - purely functional calculations.
    """

    APEX_LIMIT_PCT = 5.0  # Apex total DD limit
    MAX_DAILY_DD_PCT = 3.0  # Maximum daily DD (fresh account)
    DYNAMIC_FACTOR = 0.6  # Factor for dynamic daily limit formula

    @staticmethod
    def calculate_daily_dd_pct(day_start_balance: float, current_equity: float) -> float:
        """Daily DD% = (Day Start - Current) / Day Start × 100"""
        if not (
            isinstance(day_start_balance, (int, float)) and isinstance(current_equity, (int, float))
        ):
            raise TypeError(
                f"DD inputs must be numeric, got day_start_balance={type(day_start_balance).__name__}, current_equity={type(current_equity).__name__}"
            )
        if not (math.isfinite(day_start_balance) and math.isfinite(current_equity)):
            # Fail closed: treat invalid inputs as blown.
            return 100.0
        # Formula: daily_dd_pct = max(0, (day_start_balance - current_equity) / day_start_balance * 100)
        # Example: day_start_balance=50000, current_equity=49250
        #          daily_dd_pct = (50000-49250)/50000*100 = 1.5
        if day_start_balance <= 0:
            return 0.0

        daily_dd_pct = ((day_start_balance - current_equity) / day_start_balance) * 100.0
        daily_dd_pct = min(100.0, max(0.0, daily_dd_pct))
        if not (0.0 <= daily_dd_pct <= 100.0):
            raise ValueError(f"Invalid daily_dd_pct: {daily_dd_pct}")
        return daily_dd_pct

    @staticmethod
    def calculate_total_dd_pct(hwm: float, current_equity: float) -> float:
        """Total DD% = (HWM - Current) / HWM × 100"""
        if not (isinstance(hwm, (int, float)) and isinstance(current_equity, (int, float))):
            raise TypeError(
                f"DD inputs must be numeric, got hwm={type(hwm).__name__}, current_equity={type(current_equity).__name__}"
            )
        if not (math.isfinite(hwm) and math.isfinite(current_equity)):
            # Fail closed: treat invalid inputs as blown.
            return 100.0
        # Formula: total_dd_pct = max(0, (hwm - current_equity) / hwm * 100)
        # Example: hwm=52000, current_equity=50000
        #          total_dd_pct = (52000-50000)/52000*100 = 3.846...
        if hwm <= 0:
            return 0.0

        total_dd_pct = ((hwm - current_equity) / hwm) * 100.0
        total_dd_pct = min(100.0, max(0.0, total_dd_pct))
        if not (0.0 <= total_dd_pct <= 100.0):
            raise ValueError(f"Invalid total_dd_pct: {total_dd_pct}")
        return total_dd_pct

    @staticmethod
    def calculate_remaining_buffer_pct(total_dd_pct: float) -> float:
        """Remaining Buffer% = Apex Limit (5%) - Total DD%"""
        # Remaining buffer can become negative after breach; keep bounded at 0 for downstream sizing.
        buffer_pct = DDProtectionCalculator.APEX_LIMIT_PCT - float(total_dd_pct)
        return max(0.0, buffer_pct)

    @staticmethod
    def calculate_max_daily_dd_pct(remaining_buffer_pct: float) -> float:
        """
        Dynamic Max Daily DD% = MIN(3%, Remaining Buffer% × 0.6)

        Factor 0.6 ensures buffer not consumed in one day, allowing multi-day recovery.

        Examples:
        - Fresh account (5% buffer) → MIN(3%, 3%) = 3.0%
        - Warning (1.5% buffer)     → MIN(3%, 0.9%) = 0.9%
        - Critical (0.5% buffer)    → MIN(3%, 0.3%) = 0.3%
        """
        # Formula: max_daily_dd_pct = min(MAX_DAILY_DD_PCT, remaining_buffer_pct * DYNAMIC_FACTOR)
        # Example: remaining_buffer_pct=1.5 -> 1.5*0.6=0.9 -> min(3.0, 0.9) = 0.9
        rb = max(0.0, float(remaining_buffer_pct))
        dynamic_limit = rb * DDProtectionCalculator.DYNAMIC_FACTOR
        max_daily = min(DDProtectionCalculator.MAX_DAILY_DD_PCT, dynamic_limit)
        # Bounds: this is a percentage in [0, MAX_DAILY_DD_PCT]
        if not (0.0 <= max_daily <= DDProtectionCalculator.MAX_DAILY_DD_PCT):
            raise ValueError(f"Invalid max_daily_dd_pct: {max_daily}")
        return max_daily

    @staticmethod
    def get_daily_dd_tier(daily_dd_pct: float) -> tuple[DDTier, int]:
        """
        Get daily DD tier based on percentage.
        Returns (DDTier, tier_index) where tier_index is 0-based.
        """
        for i, tier in enumerate(DAILY_DD_TIERS):
            if daily_dd_pct >= tier.threshold_pct:
                continue
            # Found tier we're below
            if i > 0:
                return DAILY_DD_TIERS[i - 1], i - 1
            else:
                # Below first tier = no action
                return DDTier(0.0, DDAction.NONE, "", "", ""), -1

        # At or above highest tier
        return DAILY_DD_TIERS[-1], len(DAILY_DD_TIERS) - 1

    @staticmethod
    def get_total_dd_tier(total_dd_pct: float) -> tuple[DDTier, int]:
        """
        Get total DD tier based on percentage.
        Returns (DDTier, tier_index) where tier_index is 0-based.
        """
        for i, tier in enumerate(TOTAL_DD_TIERS):
            if total_dd_pct >= tier.threshold_pct:
                continue
            # Found tier we're below
            if i > 0:
                return TOTAL_DD_TIERS[i - 1], i - 1
            else:
                # Below first tier = no action
                return DDTier(0.0, DDAction.NONE, "", "", ""), -1

        # At or above highest tier
        return TOTAL_DD_TIERS[-1], len(TOTAL_DD_TIERS) - 1

    @classmethod
    def calculate_state(
        cls, hwm: float, day_start_balance: float, current_equity: float
    ) -> DDProtectionState:
        """
        Calculate complete DD protection state.

        Args:
            hwm: High-water mark (peak equity including unrealized P&L)
            day_start_balance: Equity at start of current trading day
            current_equity: Current equity (includes unrealized P&L)

        Returns:
            DDProtectionState with all DD metrics and actions
        """
        # Calculate DD percentages
        daily_dd_pct = cls.calculate_daily_dd_pct(day_start_balance, current_equity)
        total_dd_pct = cls.calculate_total_dd_pct(hwm, current_equity)
        remaining_buffer_pct = cls.calculate_remaining_buffer_pct(total_dd_pct)
        max_daily_dd_pct = cls.calculate_max_daily_dd_pct(remaining_buffer_pct)

        # Get tier actions
        daily_tier_obj, daily_tier_idx = cls.get_daily_dd_tier(daily_dd_pct)
        total_tier_obj, total_tier_idx = cls.get_total_dd_tier(total_dd_pct)

        daily_action = daily_tier_obj.action if daily_tier_idx >= 0 else DDAction.NONE
        total_action = total_tier_obj.action if total_tier_idx >= 0 else DDAction.NONE

        # Determine trading permissions (fail-safe)
        can_trade = daily_action not in (
            DDAction.EMERGENCY_HALT,
            DDAction.HALT_ALL,
            DDAction.TERMINATED,
        ) and total_action not in (
            DDAction.HALT_ALL,
            DDAction.TERMINATED,
        )
        can_open_new = daily_action not in (
            DDAction.STOP_NEW,
            DDAction.EMERGENCY_HALT,
            DDAction.HALT_ALL,
            DDAction.TERMINATED,
        ) and total_action not in (DDAction.STOP_NEW, DDAction.HALT_ALL, DDAction.TERMINATED)

        # Position size factor
        if daily_action == DDAction.REDUCE or total_action == DDAction.REDUCE:
            position_size_factor = 0.5  # Cut to 50%
        elif daily_action in (DDAction.STOP_NEW, DDAction.EMERGENCY_HALT, DDAction.HALT_ALL):
            position_size_factor = 0.0  # No new positions
        elif total_action in (DDAction.STOP_NEW, DDAction.HALT_ALL):
            position_size_factor = 0.0  # No new positions
        else:
            position_size_factor = 1.0  # Normal sizing

        # Dollar amounts (for compatibility)
        daily_dd_usd = day_start_balance * (daily_dd_pct / 100)
        total_dd_usd = hwm * (total_dd_pct / 100)

        # Tier descriptions
        daily_tier_desc = (
            f"Tier {daily_tier_idx + 1}: {daily_dd_pct:.2f}% {daily_action.value}"
            if daily_tier_idx >= 0
            else "Below 1.5%"
        )
        total_tier_desc = (
            f"Tier {total_tier_idx + 1}: {total_dd_pct:.2f}% {total_action.value}"
            if total_tier_idx >= 0
            else "Below 3.0%"
        )

        return DDProtectionState(
            daily_dd_pct=daily_dd_pct,
            total_dd_pct=total_dd_pct,
            remaining_buffer_pct=remaining_buffer_pct,
            max_daily_dd_pct=max_daily_dd_pct,
            daily_action=daily_action,
            total_action=total_action,
            daily_tier=daily_tier_desc,
            total_tier=total_tier_desc,
            can_trade=can_trade,
            can_open_new=can_open_new,
            position_size_factor=position_size_factor,
            daily_dd_usd=daily_dd_usd,
            total_dd_usd=total_dd_usd,
        )

    @classmethod
    def validate_trade(
        cls,
        dd_state: DDProtectionState,
        proposed_risk_pct: float,
        *,
        proposed_risk_pct_day_start: float | None = None,
        proposed_risk_pct_hwm: float | None = None,
    ) -> tuple[bool, str]:
        """Validate if a trade is allowed based on DD state and proposed risk.

        Args:
            dd_state: Current DD protection state
            proposed_risk_pct: Risk amount as % of current equity
            proposed_risk_pct_day_start: Optional risk as % of day-start equity (daily DD denom)
            proposed_risk_pct_hwm: Optional risk as % of HWM (trailing DD denom)

        Returns:
            (allowed: bool, reason: str)
        """
        # Check if trading is completely halted
        if not dd_state.can_trade:
            return (
                False,
                f"Trading halted: {dd_state.daily_action.value} OR {dd_state.total_action.value}",
            )

        # Check if new positions allowed
        if not dd_state.can_open_new:
            return (
                False,
                f"New positions blocked: Daily DD {dd_state.daily_dd_pct:.2f}%, Total DD {dd_state.total_dd_pct:.2f}%",
            )

        risk_pct_day_start = (
            float(proposed_risk_pct)
            if proposed_risk_pct_day_start is None
            else float(proposed_risk_pct_day_start)
        )
        risk_pct_hwm = (
            float(proposed_risk_pct)
            if proposed_risk_pct_hwm is None
            else float(proposed_risk_pct_hwm)
        )

        # PRIORITY 1: Hard-block before Apex trailing DD limit (project buffer at 4.0%).
        # Formula: potential_total_dd_pct = total_dd_pct + (risk_amount / HWM) * 100
        potential_total_dd = dd_state.total_dd_pct + risk_pct_hwm
        if potential_total_dd >= 4.0:
            return False, (
                f"Trade would breach trailing DD safety buffer: "
                f"Current {dd_state.total_dd_pct:.2f}% + Risk {risk_pct_hwm:.2f}% = {potential_total_dd:.2f}% "
                f">= 4.0%"
            )

        # PRIORITY 2: Check if proposed risk would exceed dynamic daily limit
        # NOTE: Dynamic limit can be lower than current daily DD%. In that case, trading should already
        # be effectively blocked for new risk (even a tiny trade).
        # Daily DD is measured vs day-start equity; use matching denominator.
        potential_daily_dd = dd_state.daily_dd_pct + risk_pct_day_start
        if potential_daily_dd >= dd_state.max_daily_dd_pct:
            return False, (
                f"Trade would exceed dynamic daily limit: "
                f"Current {dd_state.daily_dd_pct:.2f}% + Risk {risk_pct_day_start:.2f}% = {potential_daily_dd:.2f}% "
                f">= Limit {dd_state.max_daily_dd_pct:.2f}%"
            )

        # Trade allowed
        return True, "Trade approved"
