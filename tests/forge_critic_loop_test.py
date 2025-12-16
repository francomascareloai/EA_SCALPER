"""
PositionSizer Component - Apex-Compliant Position Sizing for XAUUSD

This module implements a position sizer that:
1. Calculates lot size based on risk percentage and stop loss
2. Respects Apex DD limits (trailing 5% from HWM, daily limits)
3. Has time gate awareness (4:30 PM / 4:55 PM ET)
4. Includes proper error handling

Created by FORGE-NAUTILUS subagent with CRITIC loop validation.
"""

from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, time
from decimal import Decimal, ROUND_DOWN
from enum import Enum, auto
from typing import Optional
from zoneinfo import ZoneInfo


class TradingStatus(Enum):
    """Status codes for position sizing decisions."""
    ALLOWED = auto()          # Normal trading allowed
    WARN = auto()             # Warning level DD
    CAUTION = auto()          # Caution level DD
    REDUCE = auto()           # Reduced position size due to DD
    HALTED = auto()           # Trading halted due to DD limits
    BLOCKED_TIME_GATE = auto()  # Blocked: after 4:30 PM ET
    EMERGENCY_CLOSE = auto()    # Emergency close mode: 4:55-4:59 PM ET


@dataclass(frozen=True)
class SizingResult:
    """Result of position sizing calculation."""
    lot_size: Decimal
    status: TradingStatus
    message: str
    risk_adjustment: Decimal  # Multiplier applied (1.0 = full, 0.5 = half, 0 = halted)

    def is_tradeable(self) -> bool:
        """Returns True if trading is allowed."""
        return self.status in (TradingStatus.ALLOWED, TradingStatus.WARN,
                               TradingStatus.CAUTION, TradingStatus.REDUCE)


class PositionSizer:
    """
    Apex-compliant position sizer for XAUUSD.

    Calculates lot size based on risk percentage while respecting:
    - Apex DD limits (daily and total/trailing)
    - Time gates (4:30 PM, 4:55 PM, 4:59 PM ET)
    - Min/max lot constraints

    Apex DD Limits:
    - Daily: 1.5% warn, 2.0% caution, 2.5% reduce, 3.0% HALT
    - Total: 3.0% warn, 3.5% caution, 4.0% caution, 4.5% HALT
    - Hard blocks: trailing_dd >= 4.0% OR total_dd >= 4.5% -> HALT
    """

    # Time gate constants (ET)
    BLOCK_NEW_TRADES = time(16, 30)  # 4:30 PM ET
    EMERGENCY_CLOSE = time(16, 55)   # 4:55 PM ET
    MARKET_CLOSE = time(16, 59)      # 4:59 PM ET

    # DD thresholds
    DAILY_DD_WARN = Decimal("1.5")
    DAILY_DD_CAUTION = Decimal("2.0")
    DAILY_DD_REDUCE = Decimal("2.5")
    DAILY_DD_HALT = Decimal("3.0")

    TOTAL_DD_WARN = Decimal("3.0")
    TOTAL_DD_CAUTION_1 = Decimal("3.5")
    TOTAL_DD_CAUTION_2 = Decimal("4.0")
    TOTAL_DD_HALT = Decimal("4.5")
    TOTAL_DD_TERMINATED = Decimal("5.0")

    # Hard block thresholds (safety buffer)
    TRAILING_DD_HARD_BLOCK = Decimal("4.0")
    TOTAL_DD_HARD_BLOCK = Decimal("4.5")

    # Risk adjustment multipliers
    RISK_MULT_FULL = Decimal("1.0")
    RISK_MULT_REDUCED = Decimal("0.75")
    RISK_MULT_HALF = Decimal("0.5")
    RISK_MULT_HALTED = Decimal("0.0")

    def __init__(
        self,
        account_balance: Decimal,
        risk_per_trade_pct: Decimal = Decimal("1.0"),
        tick_value: Decimal = Decimal("10.0"),  # XAUUSD: $10 per pip per lot
        min_lot: Decimal = Decimal("0.01"),
        max_lot: Decimal = Decimal("100.0"),
        timezone: str = "America/New_York"
    ) -> None:
        """
        Initialize the position sizer.

        Args:
            account_balance: Current account balance
            risk_per_trade_pct: Risk per trade as percentage (e.g., 1.0 for 1%)
            tick_value: Value per pip per lot (XAUUSD ~$10)
            min_lot: Minimum lot size
            max_lot: Maximum lot size
            timezone: Timezone for time gate checks

        Raises:
            ValueError: If any parameter is invalid
        """
        if account_balance <= Decimal("0"):
            raise ValueError("account_balance must be positive")
        if risk_per_trade_pct <= Decimal("0"):
            raise ValueError("risk_per_trade_pct must be positive")
        if tick_value <= Decimal("0"):
            raise ValueError("tick_value must be positive")
        if min_lot <= Decimal("0"):
            raise ValueError("min_lot must be positive")
        if max_lot <= min_lot:
            raise ValueError("max_lot must be greater than min_lot")

        self._account_balance = account_balance
        self._risk_per_trade_pct = risk_per_trade_pct
        self._tick_value = tick_value
        self._min_lot = min_lot
        self._max_lot = max_lot
        self._tz = ZoneInfo(timezone)

    def calculate_lot_size(
        self,
        stop_loss_pips: Decimal,
        daily_dd_pct: Decimal,
        total_dd_pct: Decimal,
        current_time: datetime
    ) -> SizingResult:
        """
        Calculate position size respecting all Apex constraints.

        Args:
            stop_loss_pips: Stop loss distance in pips
            daily_dd_pct: Current daily drawdown percentage (e.g., 1.5 for 1.5%)
            total_dd_pct: Current total/trailing drawdown percentage (e.g., 3.0 for 3.0%)
            current_time: Current datetime for time gate checks (MUST be timezone-aware)

        Returns:
            SizingResult with lot_size, status, message, and risk_adjustment

        Raises:
            ValueError: If current_time is timezone-naive
        """
        # Validate timezone-aware datetime (CRITICAL: prevents crash in time gate check)
        if current_time.tzinfo is None:
            raise ValueError(
                "current_time must be timezone-aware. "
                "Use datetime.now(timezone.utc) or datetime.now(ZoneInfo('America/New_York'))"
            )

        # Validate stop loss
        if stop_loss_pips <= Decimal("0"):
            return SizingResult(
                lot_size=Decimal("0"),
                status=TradingStatus.HALTED,
                message="Invalid stop loss: must be positive",
                risk_adjustment=self.RISK_MULT_HALTED
            )

        # Validate DD percentages (warn on unusual values)
        if daily_dd_pct < Decimal("0") or total_dd_pct < Decimal("0"):
            return SizingResult(
                lot_size=Decimal("0"),
                status=TradingStatus.HALTED,
                message="Invalid DD: drawdown cannot be negative",
                risk_adjustment=self.RISK_MULT_HALTED
            )

        # Check time gates first
        time_result = self._check_time_gate(current_time)
        if time_result is not None:
            return time_result

        # Check DD limits
        dd_result = self._check_dd_limits(daily_dd_pct, total_dd_pct)

        # If halted, return immediately
        if dd_result.status == TradingStatus.HALTED:
            return SizingResult(
                lot_size=Decimal("0"),
                status=TradingStatus.HALTED,
                message=dd_result.message,
                risk_adjustment=self.RISK_MULT_HALTED
            )

        # Calculate base lot size
        risk_amount = self._account_balance * (self._risk_per_trade_pct / Decimal("100"))
        base_lot_size = risk_amount / (stop_loss_pips * self._tick_value)

        # Apply risk adjustment
        adjusted_lot_size = base_lot_size * dd_result.risk_adjustment

        # Clamp to min/max
        final_lot_size = self._clamp_lot_size(adjusted_lot_size)

        # Quantize to 2 decimal places
        final_lot_size = final_lot_size.quantize(Decimal("0.01"), rounding=ROUND_DOWN)

        return SizingResult(
            lot_size=final_lot_size,
            status=dd_result.status,
            message=dd_result.message,
            risk_adjustment=dd_result.risk_adjustment
        )

    def _check_time_gate(self, current_time: datetime) -> Optional[SizingResult]:
        """
        Check if trading is blocked due to time gates.

        Returns:
            SizingResult if blocked, None if trading allowed
        """
        # Convert to ET
        et_time = current_time.astimezone(self._tz).time()

        if et_time >= self.MARKET_CLOSE:
            return SizingResult(
                lot_size=Decimal("0"),
                status=TradingStatus.HALTED,
                message=f"Market closed: after {self.MARKET_CLOSE}",
                risk_adjustment=self.RISK_MULT_HALTED
            )

        if et_time >= self.EMERGENCY_CLOSE:
            return SizingResult(
                lot_size=Decimal("0"),
                status=TradingStatus.EMERGENCY_CLOSE,
                message=f"Emergency close mode: {self.EMERGENCY_CLOSE} - {self.MARKET_CLOSE}",
                risk_adjustment=self.RISK_MULT_HALTED
            )

        if et_time >= self.BLOCK_NEW_TRADES:
            return SizingResult(
                lot_size=Decimal("0"),
                status=TradingStatus.BLOCKED_TIME_GATE,
                message=f"New trades blocked after {self.BLOCK_NEW_TRADES}",
                risk_adjustment=self.RISK_MULT_HALTED
            )

        return None

    def _check_dd_limits(
        self,
        daily_dd_pct: Decimal,
        total_dd_pct: Decimal
    ) -> SizingResult:
        """
        Check DD limits and determine risk adjustment.

        Returns:
            SizingResult with appropriate status and risk adjustment

        Note:
            Hard block at 4.0% trailing DD. This is more conservative than the
            Apex 5% limit, providing a 1% safety buffer.
        """
        # Hard block check (safety buffer - 4.0% is more conservative than Apex 5%)
        # This catches total_dd_pct >= 4.0%, halting before hitting the 5% Apex limit
        if total_dd_pct >= self.TRAILING_DD_HARD_BLOCK:
            return SizingResult(
                lot_size=Decimal("0"),
                status=TradingStatus.HALTED,
                message=f"HALTED: Trailing DD {total_dd_pct:.2f}% >= {self.TRAILING_DD_HARD_BLOCK}% hard block",
                risk_adjustment=self.RISK_MULT_HALTED
            )

        # Check daily DD limits
        if daily_dd_pct >= self.DAILY_DD_HALT:
            return SizingResult(
                lot_size=Decimal("0"),
                status=TradingStatus.HALTED,
                message=f"HALTED: Daily DD {daily_dd_pct}% >= {self.DAILY_DD_HALT}%",
                risk_adjustment=self.RISK_MULT_HALTED
            )

        # Determine risk adjustment based on DD levels
        risk_mult = self.RISK_MULT_FULL
        status = TradingStatus.ALLOWED
        message = "Trading allowed at full risk"

        # Check for REDUCE level
        if daily_dd_pct >= self.DAILY_DD_REDUCE or total_dd_pct >= self.TOTAL_DD_CAUTION_2:
            risk_mult = self.RISK_MULT_HALF
            status = TradingStatus.REDUCE
            message = f"REDUCE: DD at {max(daily_dd_pct, total_dd_pct)}%, risk reduced to 50%"

        # Check for CAUTION level
        elif daily_dd_pct >= self.DAILY_DD_CAUTION or total_dd_pct >= self.TOTAL_DD_CAUTION_1:
            risk_mult = self.RISK_MULT_REDUCED
            status = TradingStatus.CAUTION
            message = f"CAUTION: DD at {max(daily_dd_pct, total_dd_pct)}%, risk reduced to 75%"

        # Check for WARN level
        elif daily_dd_pct >= self.DAILY_DD_WARN or total_dd_pct >= self.TOTAL_DD_WARN:
            status = TradingStatus.WARN
            message = f"WARNING: DD at {max(daily_dd_pct, total_dd_pct)}%"

        return SizingResult(
            lot_size=Decimal("0"),  # Will be calculated later
            status=status,
            message=message,
            risk_adjustment=risk_mult
        )

    def _clamp_lot_size(self, lot_size: Decimal) -> Decimal:
        """Clamp lot size to min/max bounds."""
        if lot_size < self._min_lot:
            return self._min_lot
        if lot_size > self._max_lot:
            return self._max_lot
        return lot_size


# =============================================================================
# TESTS
# =============================================================================

import pytest
from datetime import timezone as dt_timezone
from typing import Generator


class TestPositionSizer:
    """Tests for PositionSizer class."""

    @pytest.fixture  # type: ignore[untyped-decorator]
    def sizer(self) -> Generator[PositionSizer, None, None]:
        """Create a standard position sizer for testing."""
        yield PositionSizer(
            account_balance=Decimal("100000"),  # $100k
            risk_per_trade_pct=Decimal("1.0"),   # 1%
            tick_value=Decimal("10.0"),          # $10/pip
            min_lot=Decimal("0.01"),
            max_lot=Decimal("100.0")
        )

    @pytest.fixture  # type: ignore[untyped-decorator]
    def normal_time(self) -> Generator[datetime, None, None]:
        """Return a normal trading time (10 AM ET)."""
        yield datetime(2024, 1, 15, 10, 0, 0, tzinfo=ZoneInfo("America/New_York"))

    # --- Basic Calculation Tests ---

    def test_basic_lot_calculation(self, sizer: PositionSizer, normal_time: datetime) -> None:
        """Test basic lot size calculation."""
        # 1% of $100k = $1000 risk
        # $1000 / (50 pips * $10) = 2.0 lots
        result = sizer.calculate_lot_size(
            stop_loss_pips=Decimal("50"),
            daily_dd_pct=Decimal("0"),
            total_dd_pct=Decimal("0"),
            current_time=normal_time
        )

        assert result.lot_size == Decimal("2.00")
        assert result.status == TradingStatus.ALLOWED
        assert result.risk_adjustment == Decimal("1.0")

    def test_small_stop_loss_capped(self, sizer: PositionSizer, normal_time: datetime) -> None:
        """Test that very small SL doesn't exceed max lot."""
        # Very small SL would result in huge lot size
        result = sizer.calculate_lot_size(
            stop_loss_pips=Decimal("1"),  # Very tight SL
            daily_dd_pct=Decimal("0"),
            total_dd_pct=Decimal("0"),
            current_time=normal_time
        )

        # Should be capped at max_lot
        assert result.lot_size == Decimal("100.00")

    def test_large_stop_loss_min_lot(self, sizer: PositionSizer, normal_time: datetime) -> None:
        """Test that very large SL results in min lot."""
        # Very large SL = tiny lot size
        result = sizer.calculate_lot_size(
            stop_loss_pips=Decimal("10000"),  # Huge SL
            daily_dd_pct=Decimal("0"),
            total_dd_pct=Decimal("0"),
            current_time=normal_time
        )

        assert result.lot_size == Decimal("0.01")

    def test_zero_stop_loss_rejected(self, sizer: PositionSizer, normal_time: datetime) -> None:
        """Test that zero stop loss is rejected."""
        result = sizer.calculate_lot_size(
            stop_loss_pips=Decimal("0"),
            daily_dd_pct=Decimal("0"),
            total_dd_pct=Decimal("0"),
            current_time=normal_time
        )

        assert result.lot_size == Decimal("0")
        assert result.status == TradingStatus.HALTED
        assert "Invalid stop loss" in result.message

    def test_negative_stop_loss_rejected(self, sizer: PositionSizer, normal_time: datetime) -> None:
        """Test that negative stop loss is rejected."""
        result = sizer.calculate_lot_size(
            stop_loss_pips=Decimal("-10"),
            daily_dd_pct=Decimal("0"),
            total_dd_pct=Decimal("0"),
            current_time=normal_time
        )

        assert result.lot_size == Decimal("0")
        assert result.status == TradingStatus.HALTED

    # --- DD Limit Tests ---

    def test_daily_dd_warn(self, sizer: PositionSizer, normal_time: datetime) -> None:
        """Test warning at 1.5% daily DD."""
        result = sizer.calculate_lot_size(
            stop_loss_pips=Decimal("50"),
            daily_dd_pct=Decimal("1.5"),
            total_dd_pct=Decimal("0"),
            current_time=normal_time
        )

        assert result.status == TradingStatus.WARN
        assert result.risk_adjustment == Decimal("1.0")
        assert result.lot_size == Decimal("2.00")

    def test_daily_dd_caution(self, sizer: PositionSizer, normal_time: datetime) -> None:
        """Test caution at 2.0% daily DD - reduced to 75%."""
        result = sizer.calculate_lot_size(
            stop_loss_pips=Decimal("50"),
            daily_dd_pct=Decimal("2.0"),
            total_dd_pct=Decimal("0"),
            current_time=normal_time
        )

        assert result.status == TradingStatus.CAUTION
        assert result.risk_adjustment == Decimal("0.75")
        # 2.0 lots * 0.75 = 1.5 lots
        assert result.lot_size == Decimal("1.50")

    def test_daily_dd_reduce(self, sizer: PositionSizer, normal_time: datetime) -> None:
        """Test reduce at 2.5% daily DD - reduced to 50%."""
        result = sizer.calculate_lot_size(
            stop_loss_pips=Decimal("50"),
            daily_dd_pct=Decimal("2.5"),
            total_dd_pct=Decimal("0"),
            current_time=normal_time
        )

        assert result.status == TradingStatus.REDUCE
        assert result.risk_adjustment == Decimal("0.5")
        # 2.0 lots * 0.5 = 1.0 lots
        assert result.lot_size == Decimal("1.00")

    def test_daily_dd_halt(self, sizer: PositionSizer, normal_time: datetime) -> None:
        """Test halt at 3.0% daily DD."""
        result = sizer.calculate_lot_size(
            stop_loss_pips=Decimal("50"),
            daily_dd_pct=Decimal("3.0"),
            total_dd_pct=Decimal("0"),
            current_time=normal_time
        )

        assert result.status == TradingStatus.HALTED
        assert result.lot_size == Decimal("0")

    def test_total_dd_hard_block(self, sizer: PositionSizer, normal_time: datetime) -> None:
        """Test hard block at 4.0% trailing DD."""
        result = sizer.calculate_lot_size(
            stop_loss_pips=Decimal("50"),
            daily_dd_pct=Decimal("0"),
            total_dd_pct=Decimal("4.0"),
            current_time=normal_time
        )

        assert result.status == TradingStatus.HALTED
        assert result.lot_size == Decimal("0")
        assert "hard block" in result.message.lower()

    # --- Time Gate Tests ---

    def test_blocked_after_430pm(self, sizer: PositionSizer) -> None:
        """Test trades blocked after 4:30 PM ET."""
        blocked_time = datetime(2024, 1, 15, 16, 35, 0, tzinfo=ZoneInfo("America/New_York"))

        result = sizer.calculate_lot_size(
            stop_loss_pips=Decimal("50"),
            daily_dd_pct=Decimal("0"),
            total_dd_pct=Decimal("0"),
            current_time=blocked_time
        )

        assert result.status == TradingStatus.BLOCKED_TIME_GATE
        assert result.lot_size == Decimal("0")

    def test_emergency_close_after_455pm(self, sizer: PositionSizer) -> None:
        """Test emergency close mode after 4:55 PM ET."""
        emergency_time = datetime(2024, 1, 15, 16, 56, 0, tzinfo=ZoneInfo("America/New_York"))

        result = sizer.calculate_lot_size(
            stop_loss_pips=Decimal("50"),
            daily_dd_pct=Decimal("0"),
            total_dd_pct=Decimal("0"),
            current_time=emergency_time
        )

        assert result.status == TradingStatus.EMERGENCY_CLOSE
        assert result.lot_size == Decimal("0")

    def test_halted_after_459pm(self, sizer: PositionSizer) -> None:
        """Test halted after 4:59 PM ET."""
        closed_time = datetime(2024, 1, 15, 17, 0, 0, tzinfo=ZoneInfo("America/New_York"))

        result = sizer.calculate_lot_size(
            stop_loss_pips=Decimal("50"),
            daily_dd_pct=Decimal("0"),
            total_dd_pct=Decimal("0"),
            current_time=closed_time
        )

        assert result.status == TradingStatus.HALTED
        assert result.lot_size == Decimal("0")

    def test_allowed_before_430pm(self, sizer: PositionSizer) -> None:
        """Test trades allowed before 4:30 PM ET."""
        allowed_time = datetime(2024, 1, 15, 16, 29, 0, tzinfo=ZoneInfo("America/New_York"))

        result = sizer.calculate_lot_size(
            stop_loss_pips=Decimal("50"),
            daily_dd_pct=Decimal("0"),
            total_dd_pct=Decimal("0"),
            current_time=allowed_time
        )

        assert result.is_tradeable()

    # --- Constructor Validation Tests ---

    def test_invalid_account_balance(self) -> None:
        """Test that zero/negative balance raises ValueError."""
        with pytest.raises(ValueError, match="account_balance must be positive"):
            PositionSizer(account_balance=Decimal("0"))

    def test_invalid_risk_pct(self) -> None:
        """Test that zero/negative risk raises ValueError."""
        with pytest.raises(ValueError, match="risk_per_trade_pct must be positive"):
            PositionSizer(
                account_balance=Decimal("100000"),
                risk_per_trade_pct=Decimal("0")
            )

    def test_invalid_min_max_lot(self) -> None:
        """Test that max_lot <= min_lot raises ValueError."""
        with pytest.raises(ValueError, match="max_lot must be greater than min_lot"):
            PositionSizer(
                account_balance=Decimal("100000"),
                min_lot=Decimal("1.0"),
                max_lot=Decimal("0.5")
            )

    # --- Edge Cases ---

    def test_is_tradeable_helper(self, sizer: PositionSizer, normal_time: datetime) -> None:
        """Test the is_tradeable helper method."""
        # Allowed status
        result = sizer.calculate_lot_size(
            stop_loss_pips=Decimal("50"),
            daily_dd_pct=Decimal("0"),
            total_dd_pct=Decimal("0"),
            current_time=normal_time
        )
        assert result.is_tradeable() is True

        # Halted status
        result_halted = sizer.calculate_lot_size(
            stop_loss_pips=Decimal("50"),
            daily_dd_pct=Decimal("5.0"),
            total_dd_pct=Decimal("0"),
            current_time=normal_time
        )
        assert result_halted.is_tradeable() is False

    def test_timezone_conversion(self, sizer: PositionSizer) -> None:
        """Test that UTC times are correctly converted to ET."""
        # 9 PM UTC = 4 PM ET (during EST, no DST)
        # This should be before 4:30 PM ET - allowed
        utc_time = datetime(2024, 1, 15, 21, 0, 0, tzinfo=dt_timezone.utc)

        result = sizer.calculate_lot_size(
            stop_loss_pips=Decimal("50"),
            daily_dd_pct=Decimal("0"),
            total_dd_pct=Decimal("0"),
            current_time=utc_time
        )

        # 9 PM UTC = 4 PM ET in winter (EST = UTC-5)
        assert result.is_tradeable()

    def test_worst_dd_used(self, sizer: PositionSizer, normal_time: datetime) -> None:
        """Test that the worst DD (daily vs total) determines the action."""
        # Daily at 1.0% (OK), Total at 3.5% (CAUTION)
        result = sizer.calculate_lot_size(
            stop_loss_pips=Decimal("50"),
            daily_dd_pct=Decimal("1.0"),
            total_dd_pct=Decimal("3.5"),
            current_time=normal_time
        )

        # Should use the worse one (total at 3.5% = CAUTION)
        assert result.status == TradingStatus.CAUTION
        assert result.risk_adjustment == Decimal("0.75")

    # --- CRITIC-identified tests (Iteration 1 fixes) ---

    def test_naive_datetime_raises_error(self, sizer: PositionSizer) -> None:
        """Test that naive datetime raises ValueError with helpful message."""
        naive_time = datetime(2024, 1, 15, 10, 0, 0)  # No tzinfo

        with pytest.raises(ValueError, match="current_time must be timezone-aware"):
            sizer.calculate_lot_size(
                stop_loss_pips=Decimal("50"),
                daily_dd_pct=Decimal("0"),
                total_dd_pct=Decimal("0"),
                current_time=naive_time
            )

    def test_negative_dd_rejected(self, sizer: PositionSizer, normal_time: datetime) -> None:
        """Test that negative DD values are rejected."""
        # Negative daily DD
        result = sizer.calculate_lot_size(
            stop_loss_pips=Decimal("50"),
            daily_dd_pct=Decimal("-1.0"),
            total_dd_pct=Decimal("0"),
            current_time=normal_time
        )
        assert result.status == TradingStatus.HALTED
        assert "negative" in result.message.lower()

        # Negative total DD
        result2 = sizer.calculate_lot_size(
            stop_loss_pips=Decimal("50"),
            daily_dd_pct=Decimal("0"),
            total_dd_pct=Decimal("-2.5"),
            current_time=normal_time
        )
        assert result2.status == TradingStatus.HALTED

    def test_dst_spring_forward(self, sizer: PositionSizer) -> None:
        """Test time gate during DST spring forward (March 2024)."""
        # March 10, 2024 at 2 AM, clocks spring forward to 3 AM
        # Test 4:25 PM ET on March 11 (after DST change)
        dst_time = datetime(2024, 3, 11, 16, 25, 0, tzinfo=ZoneInfo("America/New_York"))

        result = sizer.calculate_lot_size(
            stop_loss_pips=Decimal("50"),
            daily_dd_pct=Decimal("0"),
            total_dd_pct=Decimal("0"),
            current_time=dst_time
        )

        # 4:25 PM is before 4:30 PM gate
        assert result.is_tradeable()

        # Test 4:35 PM ET (should be blocked)
        blocked_dst = datetime(2024, 3, 11, 16, 35, 0, tzinfo=ZoneInfo("America/New_York"))
        result2 = sizer.calculate_lot_size(
            stop_loss_pips=Decimal("50"),
            daily_dd_pct=Decimal("0"),
            total_dd_pct=Decimal("0"),
            current_time=blocked_dst
        )
        assert result2.status == TradingStatus.BLOCKED_TIME_GATE


if __name__ == "__main__":
    pytest.main([__file__, "-v"])
