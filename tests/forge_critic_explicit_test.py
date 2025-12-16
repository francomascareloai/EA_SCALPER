"""
TradeValidator - Apex Compliance Validator

This module provides trade validation based on Apex trading rules:
- Time gates (block after 4:30 PM ET, force close 4:55 PM ET)
- Daily and Total DD limits
- Trailing DD from HWM
- 30% daily profit consistency limit

Created by: FORGE-NAUTILUS
Version: 2.0 (Post-CRITIC review - fixed CRITICAL issues)

CRITIC Review History:
- v1.0: BLOCKED - Missing 30% profit limit, no timezone enforcement
- v2.0: Fixed all CRITICAL and HIGH issues
"""

from dataclasses import dataclass
from datetime import datetime, time, timezone
from enum import Enum
from typing import Tuple
from zoneinfo import ZoneInfo


# Eastern Time timezone
ET_TIMEZONE = ZoneInfo("America/New_York")


class ValidationStatus(Enum):
    """Status returned by validation checks."""
    ALLOWED = "allowed"
    WARN = "warn"
    CAUTION = "caution"
    REDUCE = "reduce"
    HALT = "halt"
    TERMINATED = "terminated"


@dataclass
class ValidationResult:
    """Result of a validation check."""
    allowed: bool
    status: ValidationStatus
    message: str


class TradeValidator:
    """
    Validates trades against Apex compliance rules.

    Time Gates (ET timezone):
        - Block new trades after 4:30 PM ET
        - Emergency force-close from 4:55 PM ET
        - Close ALL by 4:59 PM ET

    DD Limits (Daily):
        - 1.5% warn, 2.0% caution, 2.5% reduce, 3.0% HALT

    DD Limits (Total):
        - 3.0% warn, 3.5% caution, 4.0% caution, 4.5% HALT, 5.0% TERMINATED

    Hard Blocks:
        - Trailing DD >= 4.0% OR Total DD >= 4.5% -> HALT

    Consistency Rule:
        - Max 30% profit per day

    Input Format:
        - DD values are percentages (e.g., 1.5 means 1.5%, not 0.015)
        - Equity values are in account currency
        - Times can be any timezone (will be converted to ET)
    """

    # Time gate thresholds (ET)
    BLOCK_NEW_TRADES = time(16, 30)  # 4:30 PM
    FORCE_CLOSE_START = time(16, 55)  # 4:55 PM
    MARKET_CLOSE = time(16, 59)  # 4:59 PM

    # Daily DD thresholds (percentages)
    DAILY_WARN = 1.5
    DAILY_CAUTION = 2.0
    DAILY_REDUCE = 2.5
    DAILY_HALT = 3.0

    # Total DD thresholds (percentages)
    TOTAL_WARN = 3.0
    TOTAL_CAUTION = 3.5
    TOTAL_CAUTION_2 = 4.0
    TOTAL_HALT = 4.5
    TOTAL_TERMINATED = 5.0

    # Hard block thresholds
    TRAILING_DD_HALT = 4.0

    # Consistency rule: max daily profit
    MAX_DAILY_PROFIT_PCT = 30.0

    def __init__(self) -> None:
        """Initialize the validator."""
        pass

    def _convert_to_et(self, dt: datetime) -> datetime:
        """
        Convert datetime to Eastern Time.

        Args:
            dt: Datetime (can be naive or timezone-aware)

        Returns:
            Datetime in Eastern Time

        Note:
            If naive datetime is passed, it is assumed to already be ET.
        """
        if dt.tzinfo is None:
            # Naive datetime - assume it's already ET
            return dt.replace(tzinfo=ET_TIMEZONE)
        else:
            # Timezone-aware - convert to ET
            return dt.astimezone(ET_TIMEZONE)

    def _is_weekend(self, dt: datetime) -> bool:
        """
        Check if the given datetime is a weekend.

        Args:
            dt: Datetime to check

        Returns:
            True if Saturday (5) or Sunday (6)
        """
        return dt.weekday() >= 5

    def validate_time_gate(self, current_time: datetime) -> ValidationResult:
        """
        Validate if trading is allowed based on time gates.

        Args:
            current_time: Current datetime (any timezone - will be converted to ET)

        Returns:
            ValidationResult with allowed status and message
        """
        # Convert to ET
        et_time = self._convert_to_et(current_time)
        time_only = et_time.time()

        # Check weekend first
        if self._is_weekend(et_time):
            return ValidationResult(
                allowed=False,
                status=ValidationStatus.HALT,
                message="Weekend - market closed"
            )

        if time_only >= self.MARKET_CLOSE:
            return ValidationResult(
                allowed=False,
                status=ValidationStatus.HALT,
                message="Market closed - all positions must be closed"
            )

        if time_only >= self.FORCE_CLOSE_START:
            return ValidationResult(
                allowed=False,
                status=ValidationStatus.HALT,
                message="Emergency force-close period - close all positions"
            )

        if time_only >= self.BLOCK_NEW_TRADES:
            return ValidationResult(
                allowed=False,
                status=ValidationStatus.HALT,
                message="New trades blocked after 4:30 PM ET"
            )

        return ValidationResult(
            allowed=True,
            status=ValidationStatus.ALLOWED,
            message="Trading allowed"
        )

    def validate_daily_dd(self, daily_dd: float) -> ValidationResult:
        """
        Validate daily drawdown against limits.

        Args:
            daily_dd: Current daily drawdown as percentage (e.g., 1.5 for 1.5%)
                      Must be >= 0 (negative values indicate profit, not DD)

        Returns:
            ValidationResult with status based on DD level

        Raises:
            ValueError: If daily_dd is negative
        """
        if daily_dd < 0:
            raise ValueError(
                f"Daily DD must be >= 0 (got {daily_dd}). "
                "Use validate_daily_profit() for profit checks."
            )

        if daily_dd >= self.DAILY_HALT:
            return ValidationResult(
                allowed=False,
                status=ValidationStatus.HALT,
                message=f"Daily DD {daily_dd:.2f}% >= {self.DAILY_HALT}% - HALT"
            )

        if daily_dd >= self.DAILY_REDUCE:
            return ValidationResult(
                allowed=True,
                status=ValidationStatus.REDUCE,
                message=f"Daily DD {daily_dd:.2f}% >= {self.DAILY_REDUCE}% - REDUCE size"
            )

        if daily_dd >= self.DAILY_CAUTION:
            return ValidationResult(
                allowed=True,
                status=ValidationStatus.CAUTION,
                message=f"Daily DD {daily_dd:.2f}% >= {self.DAILY_CAUTION}% - CAUTION"
            )

        if daily_dd >= self.DAILY_WARN:
            return ValidationResult(
                allowed=True,
                status=ValidationStatus.WARN,
                message=f"Daily DD {daily_dd:.2f}% >= {self.DAILY_WARN}% - WARNING"
            )

        return ValidationResult(
            allowed=True,
            status=ValidationStatus.ALLOWED,
            message=f"Daily DD {daily_dd:.2f}% - OK"
        )

    def validate_total_dd(self, total_dd: float) -> ValidationResult:
        """
        Validate total drawdown against limits.

        Args:
            total_dd: Current total drawdown as percentage
                      Must be >= 0

        Returns:
            ValidationResult with status based on DD level

        Raises:
            ValueError: If total_dd is negative
        """
        if total_dd < 0:
            raise ValueError(
                f"Total DD must be >= 0 (got {total_dd}). "
                "Negative values indicate profit, not drawdown."
            )

        if total_dd >= self.TOTAL_TERMINATED:
            return ValidationResult(
                allowed=False,
                status=ValidationStatus.TERMINATED,
                message=f"Total DD {total_dd:.2f}% >= {self.TOTAL_TERMINATED}% - TERMINATED"
            )

        if total_dd >= self.TOTAL_HALT:
            return ValidationResult(
                allowed=False,
                status=ValidationStatus.HALT,
                message=f"Total DD {total_dd:.2f}% >= {self.TOTAL_HALT}% - HALT"
            )

        if total_dd >= self.TOTAL_CAUTION_2:
            return ValidationResult(
                allowed=True,
                status=ValidationStatus.CAUTION,
                message=f"Total DD {total_dd:.2f}% >= {self.TOTAL_CAUTION_2}% - CAUTION"
            )

        if total_dd >= self.TOTAL_CAUTION:
            return ValidationResult(
                allowed=True,
                status=ValidationStatus.CAUTION,
                message=f"Total DD {total_dd:.2f}% >= {self.TOTAL_CAUTION}% - CAUTION"
            )

        if total_dd >= self.TOTAL_WARN:
            return ValidationResult(
                allowed=True,
                status=ValidationStatus.WARN,
                message=f"Total DD {total_dd:.2f}% >= {self.TOTAL_WARN}% - WARNING"
            )

        return ValidationResult(
            allowed=True,
            status=ValidationStatus.ALLOWED,
            message=f"Total DD {total_dd:.2f}% - OK"
        )

    def validate_trailing_dd(self, current_equity: float, hwm: float) -> ValidationResult:
        """
        Validate trailing drawdown from high-water mark.

        Args:
            current_equity: Current equity including unrealized P&L
            hwm: High-water mark (maximum equity reached)

        Returns:
            ValidationResult with status based on trailing DD

        Note:
            If current_equity > hwm, this indicates the HWM should be updated
            by the caller. This method returns ALLOWED with 0% drawdown.
        """
        if hwm <= 0:
            return ValidationResult(
                allowed=False,
                status=ValidationStatus.HALT,
                message="Invalid HWM - must be positive"
            )

        if current_equity <= 0:
            return ValidationResult(
                allowed=False,
                status=ValidationStatus.HALT,
                message="Invalid equity - must be positive"
            )

        # If equity exceeds HWM, no drawdown (HWM should be updated by caller)
        if current_equity >= hwm:
            return ValidationResult(
                allowed=True,
                status=ValidationStatus.ALLOWED,
                message="At or above HWM - no trailing drawdown"
            )

        trailing_dd = ((hwm - current_equity) / hwm) * 100

        if trailing_dd >= self.TRAILING_DD_HALT:
            return ValidationResult(
                allowed=False,
                status=ValidationStatus.HALT,
                message=f"Trailing DD {trailing_dd:.2f}% >= {self.TRAILING_DD_HALT}% - HALT"
            )

        return ValidationResult(
            allowed=True,
            status=ValidationStatus.ALLOWED,
            message=f"Trailing DD {trailing_dd:.2f}% - OK"
        )

    def validate_daily_profit(self, daily_profit_pct: float) -> ValidationResult:
        """
        Validate daily profit against consistency rule (max 30%).

        Args:
            daily_profit_pct: Current daily profit as percentage (e.g., 25.0 for 25%)

        Returns:
            ValidationResult - HALT if profit exceeds 30% limit

        Note:
            This enforces the Apex consistency rule to prevent over-trading.
        """
        if daily_profit_pct >= self.MAX_DAILY_PROFIT_PCT:
            return ValidationResult(
                allowed=False,
                status=ValidationStatus.HALT,
                message=f"Daily profit {daily_profit_pct:.2f}% >= {self.MAX_DAILY_PROFIT_PCT}% - "
                        "HALT (consistency rule)"
            )

        if daily_profit_pct >= self.MAX_DAILY_PROFIT_PCT * 0.8:  # 24% warning
            return ValidationResult(
                allowed=True,
                status=ValidationStatus.WARN,
                message=f"Daily profit {daily_profit_pct:.2f}% approaching limit - WARNING"
            )

        return ValidationResult(
            allowed=True,
            status=ValidationStatus.ALLOWED,
            message=f"Daily profit {daily_profit_pct:.2f}% - OK"
        )

    def can_trade(
        self,
        current_time: datetime,
        daily_dd: float,
        total_dd: float,
        current_equity: float,
        hwm: float,
        daily_profit_pct: float = 0.0
    ) -> ValidationResult:
        """
        Combined validation - checks all rules.

        Args:
            current_time: Current datetime (any timezone - will be converted to ET)
            daily_dd: Daily drawdown percentage (must be >= 0)
            total_dd: Total drawdown percentage (must be >= 0)
            current_equity: Current equity including unrealized P&L
            hwm: High-water mark
            daily_profit_pct: Current daily profit percentage (default 0.0)

        Returns:
            ValidationResult - allowed only if ALL checks pass

        Raises:
            ValueError: If DD values are negative
        """
        # Check time gate first
        time_result = self.validate_time_gate(current_time)
        if not time_result.allowed:
            return time_result

        # Check daily DD
        daily_result = self.validate_daily_dd(daily_dd)
        if not daily_result.allowed:
            return daily_result

        # Check total DD
        total_result = self.validate_total_dd(total_dd)
        if not total_result.allowed:
            return total_result

        # Check trailing DD
        trailing_result = self.validate_trailing_dd(current_equity, hwm)
        if not trailing_result.allowed:
            return trailing_result

        # Check daily profit (consistency rule)
        profit_result = self.validate_daily_profit(daily_profit_pct)
        if not profit_result.allowed:
            return profit_result

        # All passed - return most restrictive status
        statuses = [
            daily_result.status,
            total_result.status,
            trailing_result.status,
            profit_result.status
        ]
        if ValidationStatus.REDUCE in statuses:
            return ValidationResult(
                allowed=True,
                status=ValidationStatus.REDUCE,
                message="Trading allowed with REDUCED size"
            )
        if ValidationStatus.CAUTION in statuses:
            return ValidationResult(
                allowed=True,
                status=ValidationStatus.CAUTION,
                message="Trading allowed with CAUTION"
            )
        if ValidationStatus.WARN in statuses:
            return ValidationResult(
                allowed=True,
                status=ValidationStatus.WARN,
                message="Trading allowed with WARNING"
            )

        return ValidationResult(
            allowed=True,
            status=ValidationStatus.ALLOWED,
            message="All validations passed - trading allowed"
        )


# =============================================================================
# TESTS
# =============================================================================
import pytest


class TestTradeValidator:
    """Tests for TradeValidator class."""

    @pytest.fixture
    def validator(self) -> TradeValidator:
        """Create a validator instance."""
        return TradeValidator()

    # Time Gate Tests
    def test_time_gate_trading_allowed(self, validator: TradeValidator) -> None:
        """Test that trading is allowed during regular hours."""
        # 10:00 AM ET
        dt = datetime(2024, 1, 15, 10, 0, 0)
        result = validator.validate_time_gate(dt)
        assert result.allowed is True
        assert result.status == ValidationStatus.ALLOWED

    def test_time_gate_blocked_after_430(self, validator: TradeValidator) -> None:
        """Test that new trades are blocked after 4:30 PM ET."""
        # 4:31 PM ET
        dt = datetime(2024, 1, 15, 16, 31, 0)
        result = validator.validate_time_gate(dt)
        assert result.allowed is False
        assert result.status == ValidationStatus.HALT

    def test_time_gate_exactly_430(self, validator: TradeValidator) -> None:
        """Test behavior at exactly 4:30 PM ET (boundary)."""
        # Exactly 4:30:00 PM ET
        dt = datetime(2024, 1, 15, 16, 30, 0)
        result = validator.validate_time_gate(dt)
        assert result.allowed is False
        assert result.status == ValidationStatus.HALT

    def test_time_gate_force_close(self, validator: TradeValidator) -> None:
        """Test force close period detection."""
        # 4:56 PM ET
        dt = datetime(2024, 1, 15, 16, 56, 0)
        result = validator.validate_time_gate(dt)
        assert result.allowed is False
        assert "force-close" in result.message.lower()

    def test_time_gate_weekend_saturday(self, validator: TradeValidator) -> None:
        """Test that trading is blocked on Saturday."""
        # Saturday
        dt = datetime(2024, 1, 13, 10, 0, 0)  # Jan 13, 2024 is Saturday
        result = validator.validate_time_gate(dt)
        assert result.allowed is False
        assert "weekend" in result.message.lower()

    def test_time_gate_weekend_sunday(self, validator: TradeValidator) -> None:
        """Test that trading is blocked on Sunday."""
        # Sunday
        dt = datetime(2024, 1, 14, 10, 0, 0)  # Jan 14, 2024 is Sunday
        result = validator.validate_time_gate(dt)
        assert result.allowed is False
        assert "weekend" in result.message.lower()

    def test_time_gate_utc_conversion(self, validator: TradeValidator) -> None:
        """Test that UTC times are correctly converted to ET."""
        # 3:00 PM ET = 8:00 PM UTC (during EST, not DST)
        # This should be ALLOWED (before 4:30 PM ET)
        utc_time = datetime(2024, 1, 15, 20, 0, 0, tzinfo=timezone.utc)
        result = validator.validate_time_gate(utc_time)
        assert result.allowed is True

    def test_time_gate_utc_blocked(self, validator: TradeValidator) -> None:
        """Test that UTC times after 4:30 PM ET are blocked."""
        # 4:45 PM ET = 9:45 PM UTC (during EST)
        utc_time = datetime(2024, 1, 15, 21, 45, 0, tzinfo=timezone.utc)
        result = validator.validate_time_gate(utc_time)
        assert result.allowed is False

    # Daily DD Tests
    def test_daily_dd_allowed(self, validator: TradeValidator) -> None:
        """Test that low daily DD is allowed."""
        result = validator.validate_daily_dd(0.5)
        assert result.allowed is True
        assert result.status == ValidationStatus.ALLOWED

    def test_daily_dd_warn(self, validator: TradeValidator) -> None:
        """Test daily DD warning threshold."""
        result = validator.validate_daily_dd(1.6)
        assert result.allowed is True
        assert result.status == ValidationStatus.WARN

    def test_daily_dd_exactly_warn(self, validator: TradeValidator) -> None:
        """Test daily DD at exactly warning threshold."""
        result = validator.validate_daily_dd(1.5)
        assert result.allowed is True
        assert result.status == ValidationStatus.WARN

    def test_daily_dd_halt(self, validator: TradeValidator) -> None:
        """Test daily DD halt threshold."""
        result = validator.validate_daily_dd(3.1)
        assert result.allowed is False
        assert result.status == ValidationStatus.HALT

    def test_daily_dd_negative_raises(self, validator: TradeValidator) -> None:
        """Test that negative DD raises ValueError."""
        with pytest.raises(ValueError, match="must be >= 0"):
            validator.validate_daily_dd(-1.0)

    # Total DD Tests
    def test_total_dd_allowed(self, validator: TradeValidator) -> None:
        """Test that low total DD is allowed."""
        result = validator.validate_total_dd(1.0)
        assert result.allowed is True
        assert result.status == ValidationStatus.ALLOWED

    def test_total_dd_terminated(self, validator: TradeValidator) -> None:
        """Test total DD termination threshold."""
        result = validator.validate_total_dd(5.1)
        assert result.allowed is False
        assert result.status == ValidationStatus.TERMINATED

    def test_total_dd_negative_raises(self, validator: TradeValidator) -> None:
        """Test that negative total DD raises ValueError."""
        with pytest.raises(ValueError, match="must be >= 0"):
            validator.validate_total_dd(-0.5)

    # Trailing DD Tests
    def test_trailing_dd_allowed(self, validator: TradeValidator) -> None:
        """Test trailing DD within limits."""
        result = validator.validate_trailing_dd(98000, 100000)
        assert result.allowed is True
        assert result.status == ValidationStatus.ALLOWED

    def test_trailing_dd_halt(self, validator: TradeValidator) -> None:
        """Test trailing DD halt threshold."""
        # 5% drawdown from HWM
        result = validator.validate_trailing_dd(95000, 100000)
        assert result.allowed is False
        assert result.status == ValidationStatus.HALT

    def test_trailing_dd_exactly_4_percent(self, validator: TradeValidator) -> None:
        """Test trailing DD at exactly 4% threshold."""
        result = validator.validate_trailing_dd(96000, 100000)
        assert result.allowed is False
        assert result.status == ValidationStatus.HALT

    def test_trailing_dd_invalid_hwm(self, validator: TradeValidator) -> None:
        """Test handling of invalid HWM."""
        result = validator.validate_trailing_dd(100000, 0)
        assert result.allowed is False

    def test_trailing_dd_invalid_equity(self, validator: TradeValidator) -> None:
        """Test handling of invalid equity (zero or negative)."""
        result = validator.validate_trailing_dd(0, 100000)
        assert result.allowed is False
        assert "Invalid equity" in result.message

    def test_trailing_dd_equity_above_hwm(self, validator: TradeValidator) -> None:
        """Test when equity exceeds HWM (new HWM should be set by caller)."""
        result = validator.validate_trailing_dd(105000, 100000)
        assert result.allowed is True
        assert "no trailing drawdown" in result.message.lower()

    # Daily Profit Tests (Consistency Rule)
    def test_daily_profit_allowed(self, validator: TradeValidator) -> None:
        """Test that normal daily profit is allowed."""
        result = validator.validate_daily_profit(10.0)
        assert result.allowed is True
        assert result.status == ValidationStatus.ALLOWED

    def test_daily_profit_warning(self, validator: TradeValidator) -> None:
        """Test that approaching 30% triggers warning."""
        result = validator.validate_daily_profit(25.0)
        assert result.allowed is True
        assert result.status == ValidationStatus.WARN

    def test_daily_profit_halt(self, validator: TradeValidator) -> None:
        """Test that 30%+ profit halts trading (consistency rule)."""
        result = validator.validate_daily_profit(30.0)
        assert result.allowed is False
        assert result.status == ValidationStatus.HALT
        assert "consistency" in result.message.lower()

    def test_daily_profit_over_limit(self, validator: TradeValidator) -> None:
        """Test that profit well over 30% is blocked."""
        result = validator.validate_daily_profit(45.0)
        assert result.allowed is False
        assert result.status == ValidationStatus.HALT

    # Combined Tests
    def test_can_trade_all_pass(self, validator: TradeValidator) -> None:
        """Test that trading is allowed when all checks pass."""
        dt = datetime(2024, 1, 15, 10, 0, 0)  # Monday 10 AM
        result = validator.can_trade(
            current_time=dt,
            daily_dd=0.5,
            total_dd=1.0,
            current_equity=99000,
            hwm=100000,
            daily_profit_pct=5.0
        )
        assert result.allowed is True

    def test_can_trade_time_blocked(self, validator: TradeValidator) -> None:
        """Test that trading is blocked by time gate."""
        dt = datetime(2024, 1, 15, 16, 45, 0)
        result = validator.can_trade(
            current_time=dt,
            daily_dd=0.5,
            total_dd=1.0,
            current_equity=99000,
            hwm=100000
        )
        assert result.allowed is False

    def test_can_trade_profit_blocked(self, validator: TradeValidator) -> None:
        """Test that trading is blocked by profit consistency rule."""
        dt = datetime(2024, 1, 15, 10, 0, 0)
        result = validator.can_trade(
            current_time=dt,
            daily_dd=0.5,
            total_dd=1.0,
            current_equity=99000,
            hwm=100000,
            daily_profit_pct=35.0
        )
        assert result.allowed is False
        assert result.status == ValidationStatus.HALT

    def test_can_trade_with_warning(self, validator: TradeValidator) -> None:
        """Test combined validation with warning status."""
        dt = datetime(2024, 1, 15, 10, 0, 0)
        result = validator.can_trade(
            current_time=dt,
            daily_dd=1.6,  # Triggers warning
            total_dd=1.0,
            current_equity=99000,
            hwm=100000
        )
        assert result.allowed is True
        assert result.status == ValidationStatus.WARN


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
