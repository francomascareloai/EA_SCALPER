"""
Swings Wrapper for SMC Integration.

Wraps NautilusTrader's native Swings indicator with SMC-specific helpers
for structure detection (BOS/CHoCH).

The native Swings indicator provides:
- direction: 1 = uptrend, -1 = downtrend
- changed: True if direction just changed (potential BOS/CHoCH)
- high_price / low_price: Current swing levels
- since_high / since_low: Bars since last swing
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Any

try:
    from nautilus_trader.indicators import Swings
except ImportError:
    Swings = None

if TYPE_CHECKING:
    from nautilus_trader.model import Bar


class SwingsWrapper:
    """Wrapper for Nautilus Swings indicator with SMC integration.

    Provides a clean interface for detecting swing highs/lows and
    potential structure breaks (BOS/CHoCH).

    Parameters
    ----------
    period : int
        The rolling window period for swing detection (default: 5).
        Smaller values = more sensitive, larger = smoother.
    """

    def __init__(self, period: int = 5):
        """Initialize SwingsWrapper.

        Args:
            period: Rolling window period for swing detection.
        """
        self._period = period
        self._swings: Any = None
        self._last_swing_high: float | None = None
        self._last_swing_low: float | None = None
        self._initialized = False

        if Swings is not None:
            self._swings = Swings(period=period)
        else:
            # Fallback: manual tracking without native indicator
            self._manual_highs: list[float] = []
            self._manual_lows: list[float] = []

    def update(self, bar: Bar) -> None:
        """Update with new bar data.

        Args:
            bar: The bar to process.
        """
        if self._swings is not None:
            self._swings.handle_bar(bar)

            if self._swings.initialized:
                self._initialized = True
                # Cache swing levels
                hp = self._swings.high_price
                lp = self._swings.low_price
                self._last_swing_high = float(hp) if hp is not None else None
                self._last_swing_low = float(lp) if lp is not None else None
        else:
            # Manual fallback: simple high/low tracking
            high = float(bar.high)
            low = float(bar.low)
            self._manual_highs.append(high)
            self._manual_lows.append(low)

            # Keep only last `period` values
            if len(self._manual_highs) > self._period:
                self._manual_highs.pop(0)
                self._manual_lows.pop(0)

            if len(self._manual_highs) >= self._period:
                self._initialized = True
                self._last_swing_high = max(self._manual_highs)
                self._last_swing_low = min(self._manual_lows)

    @property
    def initialized(self) -> bool:
        """Check if indicator has enough data."""
        return self._initialized

    @property
    def direction(self) -> int:
        """Get current trend direction.

        Returns:
            1 = uptrend (higher highs/lows)
            -1 = downtrend (lower highs/lows)
            0 = neutral/uninitialized
        """
        if self._swings is not None and self._swings.initialized:
            return int(self._swings.direction)
        return 0

    @property
    def direction_changed(self) -> bool:
        """Check if direction just changed.

        This indicates a potential BOS (Break of Structure) or
        CHoCH (Change of Character) event.

        Returns:
            True if direction changed on this bar.
        """
        if self._swings is not None and self._swings.initialized:
            return bool(self._swings.changed)
        return False

    @property
    def last_swing_high(self) -> float | None:
        """Get the last swing high price."""
        return self._last_swing_high

    @property
    def last_swing_low(self) -> float | None:
        """Get the last swing low price."""
        return self._last_swing_low

    @property
    def bars_since_high(self) -> int:
        """Get bars since last swing high."""
        if self._swings is not None and self._swings.initialized:
            return int(self._swings.since_high)
        return 0

    @property
    def bars_since_low(self) -> int:
        """Get bars since last swing low."""
        if self._swings is not None and self._swings.initialized:
            return int(self._swings.since_low)
        return 0

    @property
    def period(self) -> int:
        """Get the period used for swing detection."""
        return self._period

    def is_bullish_bos(self, current_price: float) -> bool:
        """Check for bullish Break of Structure.

        A bullish BOS occurs when price breaks above the last swing high
        in an uptrend (direction == 1).

        Args:
            current_price: Current market price (typically bar close).

        Returns:
            True if bullish BOS detected.
        """
        if not self._initialized or self._last_swing_high is None:
            return False

        return self.direction == 1 and current_price > self._last_swing_high

    def is_bearish_bos(self, current_price: float) -> bool:
        """Check for bearish Break of Structure.

        A bearish BOS occurs when price breaks below the last swing low
        in a downtrend (direction == -1).

        Args:
            current_price: Current market price (typically bar close).

        Returns:
            True if bearish BOS detected.
        """
        if not self._initialized or self._last_swing_low is None:
            return False

        return self.direction == -1 and current_price < self._last_swing_low

    def is_bullish_choch(self, current_price: float) -> bool:
        """Check for bullish Change of Character.

        A bullish CHoCH occurs when price breaks above the last swing high
        while previously in a downtrend (potential reversal).

        Args:
            current_price: Current market price.

        Returns:
            True if bullish CHoCH detected.
        """
        if not self._initialized or self._last_swing_high is None:
            return False

        # Direction changed from -1 to 1 AND price confirms the break
        return self.direction_changed and self.direction == 1

    def is_bearish_choch(self, current_price: float) -> bool:
        """Check for bearish Change of Character.

        A bearish CHoCH occurs when price breaks below the last swing low
        while previously in an uptrend (potential reversal).

        Args:
            current_price: Current market price.

        Returns:
            True if bearish CHoCH detected.
        """
        if not self._initialized or self._last_swing_low is None:
            return False

        # Direction changed from 1 to -1 AND price confirms the break
        return self.direction_changed and self.direction == -1

    def reset(self) -> None:
        """Reset the indicator state."""
        if self._swings is not None:
            self._swings.reset()
        self._last_swing_high = None
        self._last_swing_low = None
        self._initialized = False
        if hasattr(self, "_manual_highs"):
            self._manual_highs.clear()
            self._manual_lows.clear()
