"""
Market Structure Analyzer (SMC-style).
Migrated from: MQL5/Include/EA_SCALPER/Analysis/CStructureAnalyzer.mqh

Detects:
- Swing Points (HH, HL, LH, LL, EQH, EQL) - Higher/Lower Highs and Lows
- Structure Breaks (BOS = continuation, CHoCH = reversal)
- Market Bias (Bullish, Bearish, Ranging, Transition)
- Premium/Discount zones relative to structure equilibrium

Key Methods:
- analyze(): Main analysis entry point
- get_market_bias(): Returns current market bias (BULLISH/BEARISH/RANGING/TRANSITION)
- has_recent_bos(): Check for Break of Structure (trend continuation)
- has_recent_choch(): Check for Change of Character (trend reversal)

// ✓ FORGE v4.0: 7/7 checks
"""

from dataclasses import dataclass
from datetime import datetime, timezone
from enum import IntEnum
from typing import Any

import numpy as np

from ..core.definitions import SignalType
from ..core.exceptions import InsufficientDataError


class StructurePointType(IntEnum):
    """Swing point type."""

    HH = 0  # Higher High
    HL = 1  # Higher Low
    LH = 2  # Lower High
    LL = 3  # Lower Low
    EQH = 4  # Equal High
    EQL = 5  # Equal Low


class MarketBias(IntEnum):
    """Market bias based on structure."""

    BULLISH = 0  # HH + HL sequence
    BEARISH = 1  # LH + LL sequence
    RANGING = 2  # No clear direction
    TRANSITION = 3  # Changing direction


class BreakType(IntEnum):
    """Structure break type."""

    NONE = 0
    BOS = 1  # Break of Structure (continuation)
    CHOCH = 2  # Change of Character (reversal)
    SWEEP = 3  # Liquidity sweep (fake break)


@dataclass
class SwingPoint:
    """Detected swing point."""

    timestamp: datetime | None = None
    price: float = 0.0
    bar_index: int = 0
    is_high: bool = True
    point_type: StructurePointType = StructurePointType.HH
    is_broken: bool = False
    break_time: datetime | None = None
    strength: float = 0.0
    is_valid: bool = True


@dataclass
class StructureBreak:
    """Structure break event."""

    timestamp: datetime | None = None
    break_price: float = 0.0
    swing_price: float = 0.0
    break_type: BreakType = BreakType.NONE
    new_bias: MarketBias = MarketBias.RANGING
    displacement: float = 0.0
    has_retest: bool = False
    retest_price: float = 0.0
    strength: int = 0  # 0-100
    is_valid: bool = False


@dataclass
class FibonacciLevels:
    """Key Fibonacci levels derived from the most recent swing leg."""

    swing_high: float = 0.0
    swing_low: float = 0.0
    golden_low: float = 0.0
    golden_high: float = 0.0
    ext_1272: float = 0.0
    ext_1618: float = 0.0
    ext_200: float = 0.0
    direction: SignalType = SignalType.SIGNAL_NONE
    in_golden_pocket: bool = False


@dataclass
class StructureState:
    """Complete market structure state."""

    bias: MarketBias = MarketBias.RANGING
    htf_bias: MarketBias = MarketBias.RANGING

    # Last swing points
    last_high: SwingPoint | None = None
    last_low: SwingPoint | None = None
    prev_high: SwingPoint | None = None
    prev_low: SwingPoint | None = None

    # Structure breaks
    last_break: StructureBreak | None = None
    bos_count: int = 0
    choch_count: int = 0

    # Premium/Discount
    equilibrium: float = 0.0
    range_high: float = 0.0
    range_low: float = 0.0
    in_premium: bool = False
    in_discount: bool = False

    # Quality metrics
    structure_quality: float = 0.0  # 0-100
    trend_strength: float = 0.0  # 0-100

    # Score for confluence
    score: float = 0.0
    direction: SignalType = SignalType.SIGNAL_NONE

    # Fibonacci confluence
    fibonacci: FibonacciLevels | None = None


class StructureAnalyzer:
    """
    SMC Market Structure Analyzer.

    Detects:
    - Swing highs/lows with classification (HH, HL, LH, LL)
    - Break of Structure (BOS) - trend continuation
    - Change of Character (CHoCH) - trend reversal
    - Premium/Discount zones
    """

    def __init__(
        self,
        swing_strength: int = 3,
        equal_tolerance_pips: float = 5.0,
        break_buffer_pips: float = 2.0,
        lookback_bars: int = 100,
        min_swing_distance: int = 5,
        point: float = 0.01,
    ):
        """
        Args:
            swing_strength: Bars on each side to confirm swing
            equal_tolerance_pips: Tolerance for equal H/L (in pips)
            break_buffer_pips: Buffer for valid break (in pips)
            lookback_bars: Bars to analyze
            min_swing_distance: Min bars between swings
        """
        # R11-FIX: Validate point > 0 to prevent division by zero
        if point <= 0:
            raise ValueError(f"point must be positive, got {point}")
        self.swing_strength = swing_strength
        # `point` is the minimum price increment for the instrument (XAUUSD=0.01, MGC=0.1).
        # The `*_pips` arguments are interpreted in "points" of size `point`.
        self.equal_tolerance = float(equal_tolerance_pips) * float(point)
        self.break_buffer = float(break_buffer_pips) * float(point)
        self.lookback_bars = lookback_bars
        self.min_swing_distance = min_swing_distance

        # Internal state
        self._swing_highs: list[SwingPoint] = []
        self._swing_lows: list[SwingPoint] = []
        self._breaks: list[StructureBreak] = []
        self._state = StructureState()
        self._point = float(point)

    def reset(self) -> None:
        self._swing_highs = []
        self._swing_lows = []
        self._breaks = []
        self._state = StructureState()

    def analyze(
        self,
        highs: np.ndarray[Any, Any],
        lows: np.ndarray[Any, Any],
        closes: np.ndarray[Any, Any],
        timestamps: np.ndarray[Any, Any] | None = None,
        current_price: float | None = None,
    ) -> StructureState:
        """
        Analyze market structure.

        Args:
            highs: Array of high prices
            lows: Array of low prices
            closes: Array of close prices
            timestamps: Array of timestamps (optional)
            current_price: Current price (defaults to last close)

        Returns:
            StructureState with complete analysis
        """
        n = len(closes)
        if n < self.lookback_bars // 2:
            raise InsufficientDataError(f"Need at least {self.lookback_bars // 2} bars")

        if timestamps is None:
            raise ValueError(
                "StructureAnalyzer.analyze requires timestamps for deterministic time semantics"
            )

        # Enforce contract: timestamps must be datetime64 for correct UTC conversion.
        timestamps_arr = np.asarray(timestamps)
        if not np.issubdtype(timestamps_arr.dtype, np.datetime64):
            raise TypeError(
                "StructureAnalyzer.analyze expects timestamps as np.datetime64 array (not ints/bar-index)"
            )

        # Fail fast on NaT to avoid silent state degradation in downstream consumers.
        if np.isnat(timestamps_arr).any():
            raise ValueError("StructureAnalyzer.analyze timestamps contains NaT")

        if current_price is None:
            current_price = float(closes[-1])

        # Narrow type for strict typing
        current_price = float(current_price)

        # Reset state
        self._swing_highs = []
        self._swing_lows = []
        self._breaks = []
        self._state = StructureState()

        # Detect swing points
        self._detect_swing_points(highs, lows, closes, timestamps)

        # Classify swing points
        self._classify_swing_points()

        # Determine initial bias
        self._state.bias = self._determine_bias()

        # Detect structure breaks
        self._detect_breaks(highs, lows, closes, timestamps, current_price)

        # Re-evaluate bias after breaks
        self._state.bias = self._determine_bias()

        # Calculate premium/discount
        self._calculate_premium_discount(current_price)

        # Fibonacci confluence
        self._calculate_fibonacci_levels(current_price)

        # Quality metrics
        self._state.structure_quality = self._calculate_structure_quality()
        self._state.trend_strength = self._calculate_trend_strength()

        # Calculate score for confluence
        self._calculate_structure_score(current_price)

        return self._state

    def _detect_swing_points(
        self,
        highs: np.ndarray[Any, Any],
        lows: np.ndarray[Any, Any],
        closes: np.ndarray[Any, Any],
        timestamps: np.ndarray[Any, Any],
    ) -> None:
        """Detect swing highs and lows."""
        n = len(highs)
        strength = self.swing_strength

        # Causal swing detection with delayed confirmation.
        # A swing at candidate index `cand` is only confirmed once `strength` bars have elapsed.
        # We evaluate `cand = i - strength` using the symmetric window [cand-strength, cand+strength]
        # which is fully known at time `i`.
        if n < (strength * 2 + 1):
            return

        for i in range(strength * 2, n):
            cand = i - strength
            if cand - strength < 0 or cand + strength >= n:
                continue

            # Check swing high
            is_swing_high = True
            for j in range(1, strength + 1):
                if highs[cand] <= highs[cand - j] or highs[cand] <= highs[cand + j]:
                    is_swing_high = False
                    break

            if is_swing_high:
                # Enforce minimum distance between swings to reduce noise.
                # If a new swing occurs too close to the previous one, keep the more extreme level.
                if (
                    self._swing_highs
                    and (cand - self._swing_highs[-1].bar_index) < self.min_swing_distance
                ):
                    if float(highs[cand]) > self._swing_highs[-1].price:
                        self._swing_highs[-1] = SwingPoint(
                            timestamp=datetime.fromtimestamp(
                                timestamps[cand].astype("datetime64[ns]").astype(int) / 1e9,
                                tz=timezone.utc,
                            ),
                            price=float(highs[cand]),
                            bar_index=cand,
                            is_high=True,
                            point_type=StructurePointType.HH,  # Will be reclassified
                            is_valid=True,
                        )
                else:
                    self._swing_highs.append(
                        SwingPoint(
                            timestamp=datetime.fromtimestamp(
                                timestamps[cand].astype("datetime64[ns]").astype(int) / 1e9,
                                tz=timezone.utc,
                            ),
                            price=float(highs[cand]),
                            bar_index=cand,
                            is_high=True,
                            point_type=StructurePointType.HH,  # Will be reclassified
                            is_valid=True,
                        )
                    )

            # Check swing low
            is_swing_low = True
            for j in range(1, strength + 1):
                if lows[cand] >= lows[cand - j] or lows[cand] >= lows[cand + j]:
                    is_swing_low = False
                    break

            if is_swing_low:
                # Enforce minimum distance between swings to reduce noise.
                # If a new swing occurs too close to the previous one, keep the more extreme level.
                if (
                    self._swing_lows
                    and (cand - self._swing_lows[-1].bar_index) < self.min_swing_distance
                ):
                    # For lows, more extreme = lower price
                    if float(lows[cand]) < self._swing_lows[-1].price:
                        self._swing_lows[-1] = SwingPoint(
                            timestamp=datetime.fromtimestamp(
                                timestamps[cand].astype("datetime64[ns]").astype(int) / 1e9,
                                tz=timezone.utc,
                            ),
                            price=float(lows[cand]),
                            bar_index=cand,
                            is_high=False,
                            point_type=StructurePointType.LL,  # Will be reclassified
                            is_valid=True,
                        )
                else:
                    self._swing_lows.append(
                        SwingPoint(
                            timestamp=datetime.fromtimestamp(
                                timestamps[cand].astype("datetime64[ns]").astype(int) / 1e9,
                                tz=timezone.utc,
                            ),
                            price=float(lows[cand]),
                            bar_index=cand,
                            is_high=False,
                            point_type=StructurePointType.LL,  # Will be reclassified
                            is_valid=True,
                        )
                    )

        # Store last swings in state
        if len(self._swing_highs) >= 2:
            self._state.last_high = self._swing_highs[-1]
            self._state.prev_high = self._swing_highs[-2]
        elif len(self._swing_highs) == 1:
            self._state.last_high = self._swing_highs[0]

        if len(self._swing_lows) >= 2:
            self._state.last_low = self._swing_lows[-1]
            self._state.prev_low = self._swing_lows[-2]
        elif len(self._swing_lows) == 1:
            self._state.last_low = self._swing_lows[0]

    def _classify_swing_points(self) -> None:
        """Classify swing points as HH/HL/LH/LL."""
        # Classify highs
        for i in range(1, len(self._swing_highs)):
            curr = self._swing_highs[i]
            prev = self._swing_highs[i - 1]
            diff = curr.price - prev.price

            if abs(diff) <= self.equal_tolerance:
                curr.point_type = StructurePointType.EQH
            elif diff > 0:
                curr.point_type = StructurePointType.HH
            else:
                curr.point_type = StructurePointType.LH

        # Classify lows
        for i in range(1, len(self._swing_lows)):
            curr = self._swing_lows[i]
            prev = self._swing_lows[i - 1]
            diff = curr.price - prev.price

            if abs(diff) <= self.equal_tolerance:
                curr.point_type = StructurePointType.EQL
            elif diff > 0:
                curr.point_type = StructurePointType.HL
            else:
                curr.point_type = StructurePointType.LL

    def _determine_bias(self) -> MarketBias:
        """Determine bias based on swing point sequence."""
        if len(self._swing_highs) < 2 or len(self._swing_lows) < 2:
            return MarketBias.RANGING

        last_high = self._swing_highs[-1]
        last_low = self._swing_lows[-1]

        # Bullish: HH + HL
        # NOTE: treat EQL/EQH as ambiguous for bias; fail closed to RANGING.
        if last_high.point_type == StructurePointType.HH:
            if last_low.point_type == StructurePointType.HL:
                return MarketBias.BULLISH

        # Bearish: LH + LL
        if last_high.point_type == StructurePointType.LH:
            if last_low.point_type == StructurePointType.LL:
                return MarketBias.BEARISH

        # SMC-6: Resolve EQH/EQL ambiguity (range -> fail closed)
        # If the last high is EQH, bias is ambiguous without additional context.
        if last_high.point_type == StructurePointType.EQH:
            return MarketBias.RANGING

        # Check for transition (mixed signals)
        if (
            last_high.point_type == StructurePointType.LH
            and last_low.point_type == StructurePointType.HL
        ):
            return MarketBias.TRANSITION
        if (
            last_high.point_type == StructurePointType.HH
            and last_low.point_type == StructurePointType.LL
        ):
            return MarketBias.TRANSITION

        return MarketBias.RANGING

    def _detect_breaks(
        self,
        highs: np.ndarray[Any, Any],
        lows: np.ndarray[Any, Any],
        closes: np.ndarray[Any, Any],
        timestamps: np.ndarray[Any, Any],
        current_price: float,
    ) -> None:
        """Detect BOS and CHoCH.

        FIX: Process only ONE break per update - the NEAREST level.
        This prevents chronology collapse when multiple levels break at once.
        """
        atr_estimate: float | None = None
        if len(highs) >= 14:
            atr_estimate = float(np.mean(highs[-14:] - lows[-14:]))

        # FIX: Detect at most ONE break per update.
        # If price is beyond multiple levels at once, record the nearest level only.
        break_recorded = False

        # Check breaks of swing lows (bearish break)
        # Sort by price DESCENDING so we check the HIGHEST swing low first (nearest to break)
        sorted_swing_lows = sorted(
            [s for s in self._swing_lows if not s.is_broken and s.is_valid],
            key=lambda s: s.price,
            reverse=True,
        )
        for swing in sorted_swing_lows:
            if current_price < swing.price - self.break_buffer:
                # Validate with close
                if closes[-1] < swing.price:
                    displacement = swing.price - current_price
                    if atr_estimate and displacement < max(self.break_buffer, atr_estimate * 0.5):
                        continue

                    swing.is_broken = True

                    # Determine if BOS or CHoCH
                    if self._state.bias == MarketBias.BEARISH:
                        break_type = BreakType.BOS
                        self._state.bos_count += 1
                    else:
                        break_type = BreakType.CHOCH
                        self._state.choch_count += 1

                    self._state.last_break = StructureBreak(
                        break_price=current_price,
                        swing_price=swing.price,
                        break_type=break_type,
                        new_bias=MarketBias.BEARISH,
                        displacement=displacement,
                        strength=min(100, int(displacement / self._point / 10)),
                        is_valid=True,
                    )
                    break_recorded = True
                    break

        if break_recorded:
            return

        # Check breaks of swing highs (bullish break)
        # Sort by price ASCENDING so we check the LOWEST swing high first (nearest to break)
        sorted_swing_highs = sorted(
            [s for s in self._swing_highs if not s.is_broken and s.is_valid],
            key=lambda s: s.price,
        )
        for swing in sorted_swing_highs:
            if current_price > swing.price + self.break_buffer:
                # Validate with close
                if closes[-1] > swing.price:
                    displacement = current_price - swing.price
                    if atr_estimate and displacement < max(self.break_buffer, atr_estimate * 0.5):
                        continue

                    swing.is_broken = True

                    if self._state.bias == MarketBias.BULLISH:
                        break_type = BreakType.BOS
                        self._state.bos_count += 1
                    else:
                        break_type = BreakType.CHOCH
                        self._state.choch_count += 1

                    self._state.last_break = StructureBreak(
                        break_price=current_price,
                        swing_price=swing.price,
                        break_type=break_type,
                        new_bias=MarketBias.BULLISH,
                        displacement=displacement,
                        strength=min(100, int(displacement / self._point / 10)),
                        is_valid=True,
                    )
                    break

    def _calculate_premium_discount(self, current_price: float) -> None:
        """Calculate premium/discount zones."""
        if not self._state.last_high or not self._state.last_low:
            return

        range_high = self._state.last_high.price
        range_low = self._state.last_low.price

        self._state.range_high = range_high
        self._state.range_low = range_low
        self._state.equilibrium = (range_high + range_low) / 2
        self._state.in_premium = current_price > self._state.equilibrium
        self._state.in_discount = current_price < self._state.equilibrium

    def _calculate_fibonacci_levels(self, current_price: float) -> None:
        """
        Compute Fibonacci golden pocket and extensions for the latest swing leg.

        - Golden pocket: 65%–61.8% retracement of the active swing
        - Extensions: 127.2%, 161.8%, 200% of the swing range
        """
        if not self._state.last_high or not self._state.last_low:
            return

        swing_high = self._state.last_high.price
        swing_low = self._state.last_low.price
        if swing_high <= 0 or swing_low <= 0 or swing_high == swing_low:
            return

        fib = FibonacciLevels(swing_high=swing_high, swing_low=swing_low)
        swing_range = abs(swing_high - swing_low)

        # Determine direction from current bias
        if self._state.bias == MarketBias.BULLISH:
            fib.direction = SignalType.SIGNAL_BUY
            fib.golden_high = swing_high - swing_range * 0.618
            fib.golden_low = swing_high - swing_range * 0.650
            fib.ext_1272 = swing_high + swing_range * 0.272
            fib.ext_1618 = swing_high + swing_range * 0.618
            fib.ext_200 = swing_high + swing_range * 1.0
            fib.in_golden_pocket = fib.golden_low <= current_price <= fib.golden_high
        elif self._state.bias == MarketBias.BEARISH:
            fib.direction = SignalType.SIGNAL_SELL
            fib.golden_low = swing_low + swing_range * 0.618
            fib.golden_high = swing_low + swing_range * 0.650
            fib.ext_1272 = swing_low - swing_range * 0.272
            fib.ext_1618 = swing_low - swing_range * 0.618
            fib.ext_200 = swing_low - swing_range * 1.0
            fib.in_golden_pocket = fib.golden_low <= current_price <= fib.golden_high
        else:
            # Only compute when we have a directional bias
            return

        self._state.fibonacci = fib

    def _calculate_structure_quality(self) -> float:
        """Calculate structure quality score (0-100)."""
        score = 50.0

        # More swings = better structure
        if len(self._swing_highs) >= 3 and len(self._swing_lows) >= 3:
            score += 15
        elif len(self._swing_highs) >= 2 and len(self._swing_lows) >= 2:
            score += 10

        # Clear bias = higher quality
        if self._state.bias in [MarketBias.BULLISH, MarketBias.BEARISH]:
            score += 20
        elif self._state.bias == MarketBias.TRANSITION:
            score -= 10

        # Recent BOS = structure confirmed
        if self._state.bos_count >= 2:
            score += 15
        elif self._state.bos_count >= 1:
            score += 10

        # CHoCH reduces quality
        score -= self._state.choch_count * 5

        return max(0, min(100, score))

    def _calculate_trend_strength(self) -> float:
        """Calculate trend strength (0-100)."""
        if self._state.bias in [MarketBias.RANGING, MarketBias.TRANSITION]:
            return 0.0

        strength = 30.0

        # Consecutive BOS increases strength
        strength += self._state.bos_count * 15

        # Higher quality = stronger trend
        strength += self._state.structure_quality * 0.3

        # Premium/discount alignment
        if self._state.bias == MarketBias.BULLISH and self._state.in_discount:
            strength += 10
        elif self._state.bias == MarketBias.BEARISH and self._state.in_premium:
            strength += 10

        return min(100, strength)

    def _calculate_structure_score(self, current_price: float) -> None:
        """Calculate structure score for confluence."""
        score = 0.0
        direction = SignalType.SIGNAL_NONE

        # Score based on bias
        if self._state.bias == MarketBias.BULLISH:
            direction = SignalType.SIGNAL_BUY
            score += 40
            if self._state.in_discount:
                score += 20  # Buy in discount is better
        elif self._state.bias == MarketBias.BEARISH:
            direction = SignalType.SIGNAL_SELL
            score += 40
            if self._state.in_premium:
                score += 20  # Sell in premium is better

        # Bonus for recent BOS
        if self._state.last_break and self._state.last_break.break_type == BreakType.BOS:
            score += 15

        # Bonus for CHoCH (reversal)
        if self._state.last_break and self._state.last_break.break_type == BreakType.CHOCH:
            score += 25

        # Fibonacci golden pocket bonus
        if self._state.fibonacci and self._state.fibonacci.in_golden_pocket:
            score += 15

        # Adjust by trend strength
        score *= 0.5 + self._state.trend_strength / 200

        self._state.score = min(100, score)
        self._state.direction = direction

    def get_signal_direction(self) -> SignalType:
        """Return signal direction based on structure."""
        return self._state.direction

    def get_structure_score(self) -> float:
        """Return structure score (0-100)."""
        return self._state.score

    def get_bias(self) -> MarketBias:
        """Return current market bias."""
        return self._state.bias

    def get_market_bias(self) -> MarketBias:
        """
        Return current market bias.

        Alias for get_bias() for compatibility with MQL5 naming convention.

        Returns:
            MarketBias: BULLISH, BEARISH, RANGING, or TRANSITION
        """
        return self._state.bias

    def is_bullish(self) -> bool:
        """Check if structure is bullish."""
        return self._state.bias == MarketBias.BULLISH

    def is_bearish(self) -> bool:
        """Check if structure is bearish."""
        return self._state.bias == MarketBias.BEARISH

    def has_recent_bos(self) -> bool:
        """Check if there's a recent BOS."""
        return (
            self._state.last_break is not None
            and self._state.last_break.break_type == BreakType.BOS
            and self._state.last_break.is_valid
        )

    def has_recent_choch(self) -> bool:
        """Check if there's a recent CHoCH."""
        return (
            self._state.last_break is not None
            and self._state.last_break.break_type == BreakType.CHOCH
            and self._state.last_break.is_valid
        )

    def get_last_state(self) -> StructureState:
        """Return the last analyzed structure state."""
        return self._state

    def get_last_swing_low(self) -> float:
        """Get price of last swing low."""
        return self._state.last_low.price if self._state.last_low else 0.0

    def get_last_swing_high(self) -> float:
        """Get price of last swing high."""
        return self._state.last_high.price if self._state.last_high else 0.0
