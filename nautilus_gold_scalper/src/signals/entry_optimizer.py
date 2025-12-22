"""
Entry Optimizer - Optimal entry point calculation for maximum R:R.

Port of CEntryOptimizer.mqh from MQL5.

THE PROBLEM:
- Most traders enter at MARKET price
- This leaves money on the table
- Poor entry = worse R:R = lower profitability

THE SOLUTION:
- Wait for price to retrace to OPTIMAL entry zone
- Use FVG 50% fill for precision entries
- Use OB refinement (70% of zone) for better price

ENTRY PRIORITY:
1. FVG 50% fill - Most precise, best R:R
2. OB 70% retest - Good precision, structural
3. Market entry - Only if signal is very strong

THE MATH:
Market entry: 1.5:1 R:R × 55% = 0.275R expectancy
OB retest:    2.5:1 R:R × 55% = 0.625R expectancy
FVG fill:     3.0:1 R:R × 55% = 0.85R  expectancy

5-10 pips better entry = 2-3x better expectancy!
"""
import logging
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from enum import IntEnum

logger = logging.getLogger(__name__)


class EntryType(IntEnum):
    """Type of entry execution."""
    ENTRY_NONE = 0
    ENTRY_MARKET = 1           # Immediate market entry
    ENTRY_FVG_FILL = 2         # Wait for FVG fill
    ENTRY_OB_RETEST = 3        # Wait for OB retest
    ENTRY_LIMIT_ORDER = 4      # Place limit order at optimal level
    ENTRY_FIB_RETRACE = 5      # Golden pocket retrace entry


class EntryQuality(IntEnum):
    """Quality tier of the entry."""
    ENTRY_QUALITY_POOR = 0
    ENTRY_QUALITY_ACCEPTABLE = 1
    ENTRY_QUALITY_GOOD = 2
    ENTRY_QUALITY_OPTIMAL = 3


class SignalDirection(IntEnum):
    """Signal direction for entry."""
    SIGNAL_NONE = 0
    SIGNAL_BUY = 1
    SIGNAL_SELL = -1


@dataclass
class OptimalEntry:
    """Structure containing optimal entry parameters."""
    entry_type: EntryType = EntryType.ENTRY_NONE
    quality: EntryQuality = EntryQuality.ENTRY_QUALITY_POOR
    direction: SignalDirection = SignalDirection.SIGNAL_NONE

    # Price levels
    optimal_price: float = 0.0
    acceptable_high: float = 0.0
    acceptable_low: float = 0.0
    stop_loss: float = 0.0
    take_profit_1: float = 0.0  # 1.5R
    take_profit_2: float = 0.0  # 2.5R
    take_profit_3: float = 0.0  # 4R

    # Risk metrics
    risk_reward: float = 0.0

    # Zone info
    zone_source_high: float = 0.0
    zone_source_low: float = 0.0
    zone_type: str = ""

    # Validity
    max_wait_bars: int = 0
    valid_until: datetime | None = None
    is_valid: bool = False

    def reset(self) -> None:
        """Reset all fields to default values."""
        self.entry_type = EntryType.ENTRY_NONE
        self.quality = EntryQuality.ENTRY_QUALITY_POOR
        self.direction = SignalDirection.SIGNAL_NONE
        self.optimal_price = 0.0
        self.acceptable_high = 0.0
        self.acceptable_low = 0.0
        self.stop_loss = 0.0
        self.take_profit_1 = 0.0
        self.take_profit_2 = 0.0
        self.take_profit_3 = 0.0
        self.risk_reward = 0.0
        self.zone_source_high = 0.0
        self.zone_source_low = 0.0
        self.zone_type = ""
        self.max_wait_bars = 0
        self.valid_until = None
        self.is_valid = False


class EntryOptimizer:
    """
    Entry optimization for maximum R:R in XAUUSD scalping.

    Prioritizes entries in order:
    1. FVG 50% fill (best R:R ~3.0)
    2. OB 70% retest (good R:R ~2.5)
    3. Market entry (acceptable R:R ~1.5)
    """

    # XAUUSD Scalping SL Limits (in price units, not points)
    # For XAUUSD: 1 point = $0.01, so 5000 points = $50
    DEFAULT_MAX_SL_PRICE = 50.0      # Max ~$50 SL
    DEFAULT_MIN_SL_PRICE = 15.0      # Min ~$15 SL
    DEFAULT_SL_PRICE = 30.0          # Default ~$30 SL

    def __init__(
        self,
        min_rr_ratio: float = 1.5,
        target_rr_ratio: float = 2.5,
        fvg_fill_percent: float = 0.5,
        ob_retest_percent: float = 0.7,
        max_wait_bars: int = 10,
        sl_buffer_atr: float = 0.2,
        max_sl_price: float | None = None,
        min_sl_price: float | None = None,
        default_sl_price: float | None = None,
    ):
        """
        Initialize the entry optimizer.

        Args:
            min_rr_ratio: Minimum acceptable R:R ratio
            target_rr_ratio: Target R:R ratio for optimal entries
            fvg_fill_percent: FVG fill target (0.5 = 50%)
            ob_retest_percent: OB retest target (0.7 = 70%)
            max_wait_bars: Maximum bars to wait for optimal entry
            sl_buffer_atr: Stop loss buffer in ATR units
            max_sl_price: Maximum SL distance in price
            min_sl_price: Minimum SL distance in price
            default_sl_price: Default SL distance in price
        """
        self.min_rr_ratio = min_rr_ratio
        self.target_rr_ratio = target_rr_ratio
        self.fvg_fill_percent = fvg_fill_percent
        self.ob_retest_percent = ob_retest_percent
        self.max_wait_bars = max_wait_bars
        self.sl_buffer_atr = sl_buffer_atr

        # SL limits
        self.max_sl_price = max_sl_price or self.DEFAULT_MAX_SL_PRICE
        self.min_sl_price = min_sl_price or self.DEFAULT_MIN_SL_PRICE
        self.default_sl_price = default_sl_price or self.DEFAULT_SL_PRICE

        # Current entry state
        self._current_entry = OptimalEntry()

        logger.info(f"EntryOptimizer initialized: target_rr={target_rr_ratio}, "
                   f"fvg_fill={fvg_fill_percent}, ob_retest={ob_retest_percent}")

    def _calculate_risk_reward(self, entry: float, sl: float, tp: float) -> float:
        """Calculate R:R ratio."""
        risk = abs(entry - sl)
        reward = abs(tp - entry)

        if risk <= 0:
            return 0.0
        return reward / risk

    def _clamp_sl_distance(self, optimal_price: float, raw_sl: float, is_buy: bool) -> float:
        """
        Clamp SL distance between min and max limits.

        Args:
            optimal_price: Entry price
            raw_sl: Raw calculated SL
            is_buy: True for buy, False for sell

        Returns:
            Clamped SL price
        """
        if is_buy:
            sl_distance = optimal_price - raw_sl
            if raw_sl <= 0 or sl_distance > self.max_sl_price:
                return optimal_price - self.default_sl_price
            elif sl_distance < self.min_sl_price:
                return optimal_price - self.min_sl_price
            return raw_sl
        else:
            sl_distance = raw_sl - optimal_price
            if raw_sl <= 0 or sl_distance > self.max_sl_price:
                return optimal_price + self.default_sl_price
            elif sl_distance < self.min_sl_price:
                return optimal_price + self.min_sl_price
            return raw_sl

    def _apply_fib_targets(
        self,
        entry: OptimalEntry,
        fib_targets: tuple[float, float, float] | None,
        is_buy: bool
    ) -> None:
        """Override default TP ladder with Fibonacci extensions when provided."""
        if not fib_targets:
            return

        tp1, tp2, tp3 = fib_targets

        def _choose(candidate: float, fallback: float, prefer_higher: bool) -> float:
            if candidate and candidate > 0:
                if prefer_higher:
                    return max(candidate, fallback)
                return min(candidate, fallback)
            return fallback

        if is_buy:
            entry.take_profit_1 = _choose(tp1, entry.take_profit_1, True)
            entry.take_profit_2 = _choose(tp2, entry.take_profit_2, True)
            entry.take_profit_3 = _choose(tp3, entry.take_profit_3, True)
        else:
            entry.take_profit_1 = _choose(tp1, entry.take_profit_1, False)
            entry.take_profit_2 = _choose(tp2, entry.take_profit_2, False)
            entry.take_profit_3 = _choose(tp3, entry.take_profit_3, False)

    def _apply_spread_penalty(
        self,
        spread_ratio: float,
        signal_urgency: float,
        atr: float,
    ) -> None:
        """Adjust or block entries when spread is elevated."""
        if not self._current_entry.is_valid:
            return

        if spread_ratio <= 1.0:
            return

        # Block low-urgency signals in extreme spread
        if spread_ratio > 1.5 and signal_urgency < 0.8:
            self._current_entry.is_valid = False
            self._current_entry.quality = EntryQuality.ENTRY_QUALITY_POOR
            self._current_entry.zone_type = "SPREAD_BLOCK"
            return

        # Widen acceptable zone slightly to account for spread slippage
        buffer = max(0.0, (spread_ratio - 1.0) * atr * 0.1)
        self._current_entry.acceptable_low -= buffer
        self._current_entry.acceptable_high += buffer

        # Risk:reward degrades with spread
        if self._current_entry.risk_reward > 0:
            self._current_entry.risk_reward = self._current_entry.risk_reward / spread_ratio

    def _optimize_for_buy(
        self,
        fvg_low: float,
        fvg_high: float,
        ob_low: float,
        ob_high: float,
        sweep_low: float,
        current_price: float,
        atr: float,
        golden_pocket: tuple[float, float] | None = None,
        fib_targets: tuple[float, float, float] | None = None,
        current_time: datetime | None = None,
    ) -> OptimalEntry:
        """Optimize entry for BUY signal."""
        entry = OptimalEntry()
        entry.direction = SignalDirection.SIGNAL_BUY

        has_fvg = fvg_low > 0 and fvg_high > 0 and fvg_high > fvg_low
        has_ob = ob_low > 0 and ob_high > 0 and ob_high > ob_low

        # PRIORITY 1: FVG 50% fill (best entry)
        if has_fvg and fvg_low < current_price:
            fvg_mid = fvg_low + (fvg_high - fvg_low) * self.fvg_fill_percent

            entry.entry_type = EntryType.ENTRY_FVG_FILL
            entry.optimal_price = fvg_mid
            entry.acceptable_low = fvg_low
            entry.acceptable_high = fvg_high
            entry.zone_type = "FVG"
            entry.zone_source_low = fvg_low
            entry.zone_source_high = fvg_high

            # Calculate SL
            raw_sl = sweep_low - (atr * self.sl_buffer_atr) if sweep_low > 0 else 0
            entry.stop_loss = self._clamp_sl_distance(entry.optimal_price, raw_sl, True)

            # Calculate TPs
            risk = entry.optimal_price - entry.stop_loss
            entry.take_profit_1 = entry.optimal_price + risk * 1.5
            entry.take_profit_2 = entry.optimal_price + risk * 2.5
            entry.take_profit_3 = entry.optimal_price + risk * 4.0
            self._apply_fib_targets(entry, fib_targets, True)

            entry.risk_reward = self._calculate_risk_reward(
                entry.optimal_price, entry.stop_loss, entry.take_profit_2
            )
            entry.quality = EntryQuality.ENTRY_QUALITY_OPTIMAL
            entry.is_valid = True

        # PRIORITY 2: OB 70% retest (good entry)
        elif has_ob and ob_low < current_price:
            ob_entry = ob_low + (ob_high - ob_low) * self.ob_retest_percent

            entry.entry_type = EntryType.ENTRY_OB_RETEST
            entry.optimal_price = ob_entry
            entry.acceptable_low = ob_low
            entry.acceptable_high = ob_high
            entry.zone_type = "OB"
            entry.zone_source_low = ob_low
            entry.zone_source_high = ob_high

            # Calculate SL
            raw_sl = ob_low - (atr * self.sl_buffer_atr)
            if sweep_low > 0 and sweep_low < raw_sl:
                raw_sl = sweep_low - (atr * self.sl_buffer_atr)
            entry.stop_loss = self._clamp_sl_distance(entry.optimal_price, raw_sl, True)

            # Calculate TPs
            risk = entry.optimal_price - entry.stop_loss
            entry.take_profit_1 = entry.optimal_price + risk * 1.5
            entry.take_profit_2 = entry.optimal_price + risk * 2.5
            entry.take_profit_3 = entry.optimal_price + risk * 4.0
            self._apply_fib_targets(entry, fib_targets, True)

            entry.risk_reward = self._calculate_risk_reward(
                entry.optimal_price, entry.stop_loss, entry.take_profit_2
            )
            entry.quality = EntryQuality.ENTRY_QUALITY_GOOD
            entry.is_valid = True

        # PRIORITY 3: Market entry (acceptable)
        elif golden_pocket and golden_pocket[0] <= current_price <= golden_pocket[1]:
            gp_low, gp_high = golden_pocket
            gp_mid = gp_low + (gp_high - gp_low) * 0.5

            entry.entry_type = EntryType.ENTRY_FIB_RETRACE
            entry.optimal_price = gp_mid
            entry.acceptable_low = gp_low
            entry.acceptable_high = gp_high
            entry.zone_type = "FIB"
            entry.zone_source_low = gp_low
            entry.zone_source_high = gp_high

            raw_sl = gp_low - (atr * self.sl_buffer_atr)
            entry.stop_loss = self._clamp_sl_distance(entry.optimal_price, raw_sl, True)

            risk = entry.optimal_price - entry.stop_loss
            entry.take_profit_1 = entry.optimal_price + risk * 1.5
            entry.take_profit_2 = entry.optimal_price + risk * 2.5
            entry.take_profit_3 = entry.optimal_price + risk * 4.0
            self._apply_fib_targets(entry, fib_targets, True)

            entry.risk_reward = self._calculate_risk_reward(
                entry.optimal_price, entry.stop_loss, entry.take_profit_2
            )
            entry.quality = EntryQuality.ENTRY_QUALITY_GOOD
            entry.is_valid = True

        else:
            entry.entry_type = EntryType.ENTRY_MARKET
            entry.optimal_price = current_price
            entry.acceptable_low = current_price - atr * 0.2
            entry.acceptable_high = current_price + atr * 0.2
            entry.zone_type = "MARKET"

            # Use default SL
            entry.stop_loss = current_price - self.default_sl_price

            # Calculate TPs
            risk = current_price - entry.stop_loss
            entry.take_profit_1 = current_price + risk * 1.5
            entry.take_profit_2 = current_price + risk * 2.5
            entry.take_profit_3 = current_price + risk * 4.0
            self._apply_fib_targets(entry, fib_targets, True)

            entry.risk_reward = self._calculate_risk_reward(
                current_price, entry.stop_loss, entry.take_profit_2
            )
            entry.quality = EntryQuality.ENTRY_QUALITY_ACCEPTABLE
            entry.is_valid = True

        # Set validity window (15 min bars * max_wait_bars)
        # Use provided current_time for backtest determinism, fallback to wall-clock for live
        base_time = current_time if current_time is not None else datetime.now(timezone.utc)
        entry.max_wait_bars = self.max_wait_bars
        entry.valid_until = base_time + timedelta(minutes=15 * self.max_wait_bars)

        return entry

    def _optimize_for_sell(
        self,
        fvg_low: float,
        fvg_high: float,
        ob_low: float,
        ob_high: float,
        sweep_high: float,
        current_price: float,
        atr: float,
        golden_pocket: tuple[float, float] | None = None,
        fib_targets: tuple[float, float, float] | None = None,
        current_time: datetime | None = None,
    ) -> OptimalEntry:
        """Optimize entry for SELL signal."""
        entry = OptimalEntry()
        entry.direction = SignalDirection.SIGNAL_SELL

        has_fvg = fvg_low > 0 and fvg_high > 0 and fvg_high > fvg_low
        has_ob = ob_low > 0 and ob_high > 0 and ob_high > ob_low

        # PRIORITY 1: FVG 50% fill
        if has_fvg and fvg_high > current_price:
            fvg_mid = fvg_high - (fvg_high - fvg_low) * self.fvg_fill_percent

            entry.entry_type = EntryType.ENTRY_FVG_FILL
            entry.optimal_price = fvg_mid
            entry.acceptable_low = fvg_low
            entry.acceptable_high = fvg_high
            entry.zone_type = "FVG"
            entry.zone_source_low = fvg_low
            entry.zone_source_high = fvg_high

            # Calculate SL
            raw_sl = sweep_high + (atr * self.sl_buffer_atr) if sweep_high > 0 else 0
            entry.stop_loss = self._clamp_sl_distance(entry.optimal_price, raw_sl, False)

            # Calculate TPs
            risk = entry.stop_loss - entry.optimal_price
            entry.take_profit_1 = entry.optimal_price - risk * 1.5
            entry.take_profit_2 = entry.optimal_price - risk * 2.5
            entry.take_profit_3 = entry.optimal_price - risk * 4.0
            self._apply_fib_targets(entry, fib_targets, False)

            entry.risk_reward = self._calculate_risk_reward(
                entry.optimal_price, entry.stop_loss, entry.take_profit_2
            )
            entry.quality = EntryQuality.ENTRY_QUALITY_OPTIMAL
            entry.is_valid = True

        # PRIORITY 2: OB 70% retest
        elif has_ob and ob_high > current_price:
            ob_entry = ob_high - (ob_high - ob_low) * self.ob_retest_percent

            entry.entry_type = EntryType.ENTRY_OB_RETEST
            entry.optimal_price = ob_entry
            entry.acceptable_low = ob_low
            entry.acceptable_high = ob_high
            entry.zone_type = "OB"
            entry.zone_source_low = ob_low
            entry.zone_source_high = ob_high

            # Calculate SL
            raw_sl = ob_high + (atr * self.sl_buffer_atr)
            if sweep_high > 0 and sweep_high > raw_sl:
                raw_sl = sweep_high + (atr * self.sl_buffer_atr)
            entry.stop_loss = self._clamp_sl_distance(entry.optimal_price, raw_sl, False)

            # Calculate TPs
            risk = entry.stop_loss - entry.optimal_price
            entry.take_profit_1 = entry.optimal_price - risk * 1.5
            entry.take_profit_2 = entry.optimal_price - risk * 2.5
            entry.take_profit_3 = entry.optimal_price - risk * 4.0
            self._apply_fib_targets(entry, fib_targets, False)

            entry.risk_reward = self._calculate_risk_reward(
                entry.optimal_price, entry.stop_loss, entry.take_profit_2
            )
            entry.quality = EntryQuality.ENTRY_QUALITY_GOOD
            entry.is_valid = True

        # PRIORITY 3: Market entry
        elif golden_pocket and golden_pocket[0] <= current_price <= golden_pocket[1]:
            gp_low, gp_high = golden_pocket
            gp_mid = gp_low + (gp_high - gp_low) * 0.5

            entry.entry_type = EntryType.ENTRY_FIB_RETRACE
            entry.optimal_price = gp_mid
            entry.acceptable_low = gp_low
            entry.acceptable_high = gp_high
            entry.zone_type = "FIB"
            entry.zone_source_low = gp_low
            entry.zone_source_high = gp_high

            raw_sl = gp_high + (atr * self.sl_buffer_atr)
            entry.stop_loss = self._clamp_sl_distance(entry.optimal_price, raw_sl, False)

            risk = entry.stop_loss - entry.optimal_price
            entry.take_profit_1 = entry.optimal_price - risk * 1.5
            entry.take_profit_2 = entry.optimal_price - risk * 2.5
            entry.take_profit_3 = entry.optimal_price - risk * 4.0
            self._apply_fib_targets(entry, fib_targets, False)

            entry.risk_reward = self._calculate_risk_reward(
                entry.optimal_price, entry.stop_loss, entry.take_profit_2
            )
            entry.quality = EntryQuality.ENTRY_QUALITY_GOOD
            entry.is_valid = True

        else:
            entry.entry_type = EntryType.ENTRY_MARKET
            entry.optimal_price = current_price
            entry.acceptable_low = current_price - atr * 0.2
            entry.acceptable_high = current_price + atr * 0.2
            entry.zone_type = "MARKET"

            entry.stop_loss = current_price + self.default_sl_price

            risk = entry.stop_loss - current_price
            entry.take_profit_1 = current_price - risk * 1.5
            entry.take_profit_2 = current_price - risk * 2.5
            entry.take_profit_3 = current_price - risk * 4.0
            self._apply_fib_targets(entry, fib_targets, False)

            entry.risk_reward = self._calculate_risk_reward(
                current_price, entry.stop_loss, entry.take_profit_2
            )
            entry.quality = EntryQuality.ENTRY_QUALITY_ACCEPTABLE
            entry.is_valid = True

        entry.max_wait_bars = self.max_wait_bars
        # Use provided current_time for backtest determinism, fallback to wall-clock for live
        base_time = current_time if current_time is not None else datetime.now(timezone.utc)
        entry.valid_until = base_time + timedelta(minutes=15 * self.max_wait_bars)

        return entry

    def calculate_optimal_entry(
        self,
        direction: SignalDirection,
        fvg_low: float = 0.0,
        fvg_high: float = 0.0,
        ob_low: float = 0.0,
        ob_high: float = 0.0,
        sweep_level: float = 0.0,
        current_price: float = 0.0,
        atr: float = 1.0,
        golden_pocket: tuple[float, float] | None = None,
        fib_targets: tuple[float, float, float] | None = None,
        spread_ratio: float = 1.0,
        signal_urgency: float = 1.0,
        current_time: datetime | None = None,
    ) -> OptimalEntry:
        """
        Calculate optimal entry parameters.

        Args:
            direction: Signal direction (BUY/SELL)
            fvg_low: FVG zone low (0 if none)
            fvg_high: FVG zone high (0 if none)
            ob_low: Order Block zone low (0 if none)
            ob_high: Order Block zone high (0 if none)
            sweep_level: Level that was swept (for SL placement)
            current_price: Current market price
            atr: ATR value for buffer calculations
            golden_pocket: Tuple(low, high) for Fib golden pocket zone
            fib_targets: Tuple(tp1, tp2, tp3) using Fib extensions
            spread_ratio: Current spread / average spread ratio
            signal_urgency: 0-1 urgency score; low urgency blocks in high spread
            current_time: Event/bar timestamp for backtest determinism.
                          If None, falls back to datetime.now(timezone.utc) for live trading.

        Returns:
            OptimalEntry with calculated levels
        """
        self._current_entry.reset()

        if direction == SignalDirection.SIGNAL_NONE:
            return self._current_entry

        if atr <= 0:
            logger.warning("Invalid ATR value, using default")
            atr = 1.0

        if direction == SignalDirection.SIGNAL_BUY:
            self._current_entry = self._optimize_for_buy(
                fvg_low, fvg_high, ob_low, ob_high, sweep_level, current_price, atr,
                golden_pocket, fib_targets, current_time
            )
        else:
            self._current_entry = self._optimize_for_sell(
                fvg_low, fvg_high, ob_low, ob_high, sweep_level, current_price, atr,
                golden_pocket, fib_targets, current_time
            )

        # Apply spread awareness: block or adjust if spread is elevated
        self._apply_spread_penalty(
            spread_ratio=spread_ratio,
            signal_urgency=signal_urgency,
            atr=atr,
        )

        logger.debug(f"Optimal entry calculated: {self.get_entry_info()}")
        return self._current_entry

    def should_enter_now(
        self,
        current_price: float,
        current_time: datetime | None = None,
    ) -> bool:
        """
        Check if should enter at current price.

        Args:
            current_price: Current market price to evaluate.
            current_time: Event/bar timestamp for backtest determinism.
                          If None, falls back to datetime.now(timezone.utc) for live trading.

        Returns:
            True if entry conditions are met and setup is not expired.
        """
        if not self._current_entry.is_valid:
            return False
        if self.has_expired(current_time):
            return False

        # Market entries execute immediately
        if self._current_entry.entry_type == EntryType.ENTRY_MARKET:
            return True

        # FVG/OB entries wait for price to reach zone
        return self.is_in_acceptable_zone(current_price)

    def is_in_optimal_zone(self, current_price: float) -> bool:
        """Check if price is in optimal entry zone."""
        if not self._current_entry.is_valid:
            return False

        tolerance = abs(self._current_entry.acceptable_high -
                       self._current_entry.acceptable_low) * 0.1

        return abs(current_price - self._current_entry.optimal_price) <= tolerance

    def is_in_acceptable_zone(self, current_price: float) -> bool:
        """Check if price is in acceptable entry zone."""
        if not self._current_entry.is_valid:
            return False

        return (self._current_entry.acceptable_low <= current_price <=
                self._current_entry.acceptable_high)

    def has_expired(self, current_time: datetime | None = None) -> bool:
        """
        Check if entry setup has expired.

        Args:
            current_time: Event/bar timestamp for backtest determinism.
                          If None, falls back to datetime.now(timezone.utc) for live trading.

        Returns:
            True if the entry setup has expired.
        """
        if self._current_entry.valid_until is None:
            return True
        check_time = current_time if current_time is not None else datetime.now(timezone.utc)
        return check_time > self._current_entry.valid_until

    @property
    def current_entry(self) -> OptimalEntry:
        """Get current entry setup."""
        return self._current_entry

    @property
    def entry_type(self) -> EntryType:
        """Get current entry type."""
        return self._current_entry.entry_type

    @property
    def optimal_price(self) -> float:
        """Get optimal entry price."""
        return self._current_entry.optimal_price

    @property
    def stop_loss(self) -> float:
        """Get stop loss level."""
        return self._current_entry.stop_loss

    @property
    def tp1(self) -> float:
        """Get TP1 level."""
        return self._current_entry.take_profit_1

    @property
    def tp2(self) -> float:
        """Get TP2 level."""
        return self._current_entry.take_profit_2

    @property
    def tp3(self) -> float:
        """Get TP3 level."""
        return self._current_entry.take_profit_3

    @property
    def risk_reward(self) -> float:
        """Get R:R ratio."""
        return self._current_entry.risk_reward

    def reset(self) -> None:
        """Reset current entry."""
        self._current_entry.reset()

    def get_entry_info(self) -> str:
        """Get human-readable entry info."""
        if not self._current_entry.is_valid:
            return "No valid entry"

        direction = "BUY" if self._current_entry.direction == SignalDirection.SIGNAL_BUY else "SELL"
        quality_names = {
            EntryQuality.ENTRY_QUALITY_OPTIMAL: "OPTIMAL",
            EntryQuality.ENTRY_QUALITY_GOOD: "GOOD",
            EntryQuality.ENTRY_QUALITY_ACCEPTABLE: "ACCEPTABLE",
            EntryQuality.ENTRY_QUALITY_POOR: "POOR"
        }

        return (f"Entry: {self._current_entry.zone_type} | "
                f"Dir: {direction} | "
                f"Optimal: {self._current_entry.optimal_price:.2f} | "
                f"SL: {self._current_entry.stop_loss:.2f} | "
                f"R:R: {self._current_entry.risk_reward:.2f} | "
                f"Quality: {quality_names.get(self._current_entry.quality, 'UNKNOWN')}")
