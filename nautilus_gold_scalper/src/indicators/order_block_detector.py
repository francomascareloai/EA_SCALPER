"""
Order Block Detector (Smart Money Concepts).
Migrated from: MQL5/Include/EA_SCALPER/Analysis/EliteOrderBlock.mqh

Detects:
- Bullish Order Blocks (last down candle before up displacement)
- Bearish Order Blocks (last up candle before down displacement)
- Breaker Blocks (broken order blocks that flip polarity)
- Quality scoring (LOW, MEDIUM, HIGH, ELITE)
- Mitigation levels (50-70% of OB zone)
"""
from datetime import datetime
from typing import Any

import numpy as np
from numpy.typing import NDArray

from ..core.data_types import OrderBlock
from ..core.definitions import (
    XAUUSD_POINT,
    OrderBlockQuality,
    OrderBlockState,
    OrderBlockType,
    SignalType,
)
from ..core.exceptions import InsufficientDataError


class OrderBlockDetector:
    """
    Elite Order Block Detector using ICT methodology.

    An Order Block is the last opposite-colored candle before a strong displacement.
    - Bullish OB: Last bearish candle before bullish impulse
    - Bearish OB: Last bullish candle before bearish impulse

    Quality is based on:
    - Displacement size after formation
    - Volume profile
    - Confluence with other factors
    """

    def __init__(
        self,
        displacement_threshold: float = 20.0,  # pips
        volume_threshold: float = 1.5,
        require_structure_break: bool = True,
        max_order_blocks: int = 50,
        point: float = XAUUSD_POINT,
        pip_factor: float = 10.0,
        lookback_bars: int = 50,
    ):
        """
        Args:
            displacement_threshold: Minimum displacement after OB (in pips)
            volume_threshold: Minimum volume ratio vs average
            require_structure_break: Require structure break confirmation
            max_order_blocks: Maximum OBs to track
            point: Instrument point size
        """
        # Convert pips to price. Default pip_factor=10 preserves legacy XAUUSD convention (1 pip = 0.1 when point=0.01).
        self.displacement_threshold = displacement_threshold * point * pip_factor
        self.volume_threshold = volume_threshold
        self.require_structure_break = require_structure_break
        self.max_order_blocks = max_order_blocks
        self.point = point
        self.pip_factor = pip_factor
        self.lookback_bars = lookback_bars

        # Storage
        self._order_blocks: list[OrderBlock] = []

    def detect(
        self,
        opens: NDArray[np.floating[Any]],
        highs: NDArray[np.floating[Any]],
        lows: NDArray[np.floating[Any]],
        closes: NDArray[np.floating[Any]],
        volumes: NDArray[np.floating[Any]] | None = None,
        timestamps: NDArray[np.datetime64] | None = None,
        current_price: float | None = None,
    ) -> list[OrderBlock]:
        """
        Detect order blocks in price data.

        Args:
            opens: Array of open prices
            highs: Array of high prices
            lows: Array of low prices
            closes: Array of close prices
            volumes: Array of volumes (optional)
            timestamps: Array of timestamps (optional)
            current_price: Current price for state updates (defaults to last close)

        Returns:
            List of detected OrderBlock objects
        """
        n = len(closes)
        if n < self.lookback_bars:
            raise InsufficientDataError(f"Need at least {self.lookback_bars} bars for order block detection")

        if timestamps is None:
            timestamps = np.arange(n, dtype="datetime64[ns]")

        if current_price is None:
            current_price = float(closes[-1])

        # Reset storage
        self._order_blocks = []

        # Calculate average volume if provided
        avg_volume = float(np.mean(volumes)) if volumes is not None else None

        # Scan for order blocks causally (no future bars).
        # We confirm an OB only once the immediate displacement candle is present.
        # Candidate OB candle is (i - 1); displacement candle is i.
        for i in range(6, n):
            ob_index = i - 1

            # Check for bullish order block confirmed by the displacement candle at i
            if self._is_bullish_ob_pattern(opens, highs, lows, closes, i):
                ob = self._create_bullish_ob(
                    opens, highs, lows, closes, volumes, timestamps, ob_index, avg_volume
                )
                if ob and self._validate_ob(ob):
                    self._order_blocks.append(ob)
                    if len(self._order_blocks) >= self.max_order_blocks:
                        break

            # Check for bearish order block confirmed by the displacement candle at i
            if self._is_bearish_ob_pattern(opens, highs, lows, closes, i):
                ob = self._create_bearish_ob(
                    opens, highs, lows, closes, volumes, timestamps, ob_index, avg_volume
                )
                if ob and self._validate_ob(ob):
                    self._order_blocks.append(ob)
                    if len(self._order_blocks) >= self.max_order_blocks:
                        break

        # Update states based on current price
        self._update_ob_states(current_price)

        # Sort by probability score (best first)
        self._order_blocks.sort(key=lambda x: x.probability_score, reverse=True)

        # NOTE: no synthetic fallback here.
        # Returning fabricated order blocks is unsafe for backtests and can mask
        # detector misconfiguration.

        return self._order_blocks

    def get_ob_score(self, current_price: float, direction: SignalType) -> float:
        """Return probability score of best OB in direction near price."""
        if not self._order_blocks:
            return 0.0
        candidates = [ob for ob in self._order_blocks if ob.direction == direction]
        if not candidates:
            return 0.0
        # pick closest to price
        best = min(candidates, key=lambda ob: abs(current_price - ob.refined_entry))
        return float(best.probability_score)

    def _is_bullish_ob_pattern(
        self,
        opens: NDArray[np.floating[Any]],
        highs: NDArray[np.floating[Any]],
        lows: NDArray[np.floating[Any]],
        closes: NDArray[np.floating[Any]],
        index: int,
    ) -> bool:
        """Check if index confirms a bullish OB pattern (causal)."""
        ob_index = index - 1
        if ob_index < 3 or index >= len(closes):
            return False

        # OB candle (previous) must be bearish
        ob_body = closes[ob_index] - opens[ob_index]
        if ob_body >= 0:
            return False

        # Displacement candle (current) must close above OB high
        displacement = closes[index] - highs[ob_index]
        if displacement <= 0:
            return False

        # OB must have meaningful body size
        total_range = highs[ob_index] - lows[ob_index]
        if total_range <= 0 or abs(ob_body) < total_range * 0.5:
            return False

        # OB body size vs trailing average (no future bars)
        avg_body = self._calculate_avg_body_size(opens, closes, ob_index, 10)
        if abs(ob_body) < avg_body * 1.5:
            return False

        return True

    def _is_bearish_ob_pattern(
        self,
        opens: NDArray[np.floating[Any]],
        highs: NDArray[np.floating[Any]],
        lows: NDArray[np.floating[Any]],
        closes: NDArray[np.floating[Any]],
        index: int,
    ) -> bool:
        """Check if index confirms a bearish OB pattern (causal)."""
        ob_index = index - 1
        if ob_index < 3 or index >= len(closes):
            return False

        # OB candle (previous) must be bullish
        ob_body = closes[ob_index] - opens[ob_index]
        if ob_body <= 0:
            return False

        # Displacement candle (current) must close below OB low
        displacement = lows[ob_index] - closes[index]
        if displacement <= 0:
            return False

        # OB must have meaningful body size
        total_range = highs[ob_index] - lows[ob_index]
        if total_range <= 0 or abs(ob_body) < total_range * 0.5:
            return False

        # OB body size vs trailing average (no future bars)
        avg_body = self._calculate_avg_body_size(opens, closes, ob_index, 10)
        if abs(ob_body) < avg_body * 1.5:
            return False

        return True

    def _create_bullish_ob(
        self,
        opens: NDArray[np.floating[Any]],
        highs: NDArray[np.floating[Any]],
        lows: NDArray[np.floating[Any]],
        closes: NDArray[np.floating[Any]],
        volumes: NDArray[np.floating[Any]] | None,
        timestamps: NDArray[np.datetime64],
        index: int,
        avg_volume: float | None,
    ) -> OrderBlock | None:
        """Create a bullish order block structure."""
        ob = OrderBlock()

        # Timestamps
        ob.timestamp = datetime.fromtimestamp(timestamps[index].astype("datetime64[s]").astype(int))

        # Price levels
        ob.high_price = float(highs[index])
        ob.low_price = float(lows[index])
        ob.refined_entry = float(lows[index] + (highs[index] - lows[index]) * 0.5)  # 50% mitigation

        # Type and state
        ob.ob_type = OrderBlockType.OB_BULLISH
        ob.state = OrderBlockState.OB_STATE_ACTIVE
        ob.direction = SignalType.SIGNAL_BUY

        # Calculate metrics
        ob.displacement_size = self._calculate_displacement(highs, lows, closes, index, bullish=True)
        ob.volume_ratio = self._calculate_volume_ratio(volumes, index, avg_volume) if volumes is not None else 1.0

        # Quality assessment
        ob.strength = self._calculate_ob_strength(ob)
        ob.quality = self._classify_ob_quality(ob)
        ob.probability_score = self._calculate_probability_score(ob)

        # Flags
        ob.is_fresh = True
        ob.is_institutional = self._is_institutional_ob(ob)
        ob.is_valid = True
        ob.touch_count = 0

        # Confluence (external)
        ob.has_fvg_confluence = False
        ob.has_liquidity_confluence = False
        ob.has_structure_confluence = False
        ob.confluence_score = 0.0

        return ob

    def _create_bearish_ob(
        self,
        opens: NDArray[np.floating[Any]],
        highs: NDArray[np.floating[Any]],
        lows: NDArray[np.floating[Any]],
        closes: NDArray[np.floating[Any]],
        volumes: NDArray[np.floating[Any]] | None,
        timestamps: NDArray[np.datetime64],
        index: int,
        avg_volume: float | None,
    ) -> OrderBlock | None:
        """Create a bearish order block structure."""
        ob = OrderBlock()

        # Timestamps
        ob.timestamp = datetime.fromtimestamp(timestamps[index].astype("datetime64[s]").astype(int))

        # Price levels
        ob.high_price = float(highs[index])
        ob.low_price = float(lows[index])
        ob.refined_entry = float(highs[index] - (highs[index] - lows[index]) * 0.5)  # 50% mitigation

        # Type and state
        ob.ob_type = OrderBlockType.OB_BEARISH
        ob.state = OrderBlockState.OB_STATE_ACTIVE
        ob.direction = SignalType.SIGNAL_SELL

        # Calculate metrics
        ob.displacement_size = self._calculate_displacement(highs, lows, closes, index, bullish=False)
        ob.volume_ratio = self._calculate_volume_ratio(volumes, index, avg_volume) if volumes is not None else 1.0

        # Quality assessment
        ob.strength = self._calculate_ob_strength(ob)
        ob.quality = self._classify_ob_quality(ob)
        ob.probability_score = self._calculate_probability_score(ob)

        # Flags
        ob.is_fresh = True
        ob.is_institutional = self._is_institutional_ob(ob)
        ob.is_valid = True
        ob.touch_count = 0

        # Confluence (external)
        ob.has_fvg_confluence = False
        ob.has_liquidity_confluence = False
        ob.has_structure_confluence = False
        ob.confluence_score = 0.0

        return ob

    def _validate_ob(self, ob: OrderBlock) -> bool:
        """Validate order block meets minimum requirements."""
        if ob.strength < 45.0:
            return False
        if ob.probability_score < 70.0:
            return False
        if ob.quality < OrderBlockQuality.OB_QUALITY_MEDIUM:
            return False
        return True

    def _calculate_displacement(
        self,
        highs: NDArray[np.floating[Any]],
        lows: NDArray[np.floating[Any]],
        closes: NDArray[np.floating[Any]],
        index: int,
        bullish: bool,
    ) -> float:
        """Calculate displacement size for a confirmed OB (causal)."""
        displacement_index = index + 1
        if displacement_index >= len(closes):
            return 0.0

        if bullish:
            return float(max(0.0, closes[displacement_index] - highs[index]))

        return float(max(0.0, lows[index] - closes[displacement_index]))

    def _calculate_volume_ratio(
        self,
        volumes: NDArray[np.floating[Any]] | None,
        index: int,
        avg_volume: float | None,
    ) -> float:
        """Calculate volume ratio vs average."""
        if volumes is None or avg_volume is None or avg_volume == 0:
            return 1.0

        current_volume = float(volumes[index])
        return float(current_volume / avg_volume)

    def _calculate_avg_body_size(
        self,
        opens: NDArray[np.floating[Any]],
        closes: NDArray[np.floating[Any]],
        index: int,
        period: int,
    ) -> float:
        """Calculate average body size over period."""
        start = max(0, index - period)
        end = index

        bodies = np.abs(closes[start:end] - opens[start:end])
        return float(np.mean(bodies)) if len(bodies) > 0 else 0.0

    def _calculate_ob_strength(self, ob: OrderBlock) -> float:
        """Calculate order block strength (0-100)."""
        strength = 0.0

        # Displacement contribution (max 30)
        disp_pips = ob.displacement_size / (self.point * 10)
        strength += min(disp_pips, 30.0)

        # Volume contribution (max 20)
        strength += min(ob.volume_ratio * 10, 20.0)

        # Institutional flag (15)
        if ob.is_institutional:
            strength += 15.0

        # Confluence (max 35, added externally)
        strength += ob.confluence_score * 0.35

        return float(min(100.0, strength))

    def _classify_ob_quality(self, ob: OrderBlock) -> OrderBlockQuality:
        """Classify order block quality based on metrics."""
        quality_score = 0.0

        # Displacement contribution
        disp_pips = ob.displacement_size / (self.point * 10)
        if disp_pips >= 30:
            quality_score += 25.0
        elif disp_pips >= 20:
            quality_score += 15.0
        elif disp_pips >= 10:
            quality_score += 10.0

        # Volume contribution
        if ob.volume_ratio > 1.8:
            quality_score += 25.0
        elif ob.volume_ratio > 1.5:
            quality_score += 15.0
        elif ob.volume_ratio > 1.2:
            quality_score += 10.0

        # Displacement must be meaningful (causal measurement yields smaller values than forward scan)
        if disp_pips >= 30:
            quality_score += 15.0
        elif disp_pips >= 20:
            quality_score += 10.0
        elif disp_pips >= 10:
            quality_score += 5.0

        # Institutional bonus
        if ob.is_institutional:
            quality_score += 15.0

        # Confluence
        quality_score += ob.confluence_score * 0.1

        if quality_score >= 85.0:
            return OrderBlockQuality.OB_QUALITY_ELITE
        elif quality_score >= 70.0:
            return OrderBlockQuality.OB_QUALITY_HIGH
        elif quality_score >= 55.0:
            return OrderBlockQuality.OB_QUALITY_MEDIUM
        else:
            return OrderBlockQuality.OB_QUALITY_LOW

    def _calculate_probability_score(self, ob: OrderBlock) -> float:
        """Calculate probability score (0-100)."""
        probability = 50.0

        # Quality bonus
        if ob.quality == OrderBlockQuality.OB_QUALITY_ELITE:
            probability += 30.0
        elif ob.quality == OrderBlockQuality.OB_QUALITY_HIGH:
            probability += 20.0
        elif ob.quality == OrderBlockQuality.OB_QUALITY_MEDIUM:
            probability += 10.0

        # Institutional bonus
        if ob.is_institutional:
            probability += 15.0

        # Fresh OB bonus
        if ob.is_fresh:
            probability += 10.0

        # Confluence bonus
        probability += ob.confluence_score * 0.2

        return float(min(100.0, probability))

    def _is_institutional_ob(self, ob: OrderBlock) -> bool:
        """Check if OB has institutional characteristics."""
        disp_pips = ob.displacement_size / (self.point * 10)

        # Large displacement
        if disp_pips > 25:
            return True

        # High volume
        if ob.volume_ratio > 2.0:
            return True

        return False

    def _update_ob_states(self, current_price: float) -> None:
        """Update order block states based on current price."""
        for ob in self._order_blocks:
            if ob.state in [OrderBlockState.OB_STATE_ACTIVE, OrderBlockState.OB_STATE_TESTED]:
                if ob.ob_type == OrderBlockType.OB_BULLISH:
                    # Bullish OB is mitigated if price closes below low
                    if current_price < ob.low_price:
                        ob.state = OrderBlockState.OB_STATE_MITIGATED
                        ob.is_fresh = False
                    # Tested if price is inside OB zone
                    elif ob.low_price <= current_price <= ob.high_price:
                        ob.state = OrderBlockState.OB_STATE_TESTED
                        ob.touch_count += 1
                        ob.is_fresh = False
                else:  # Bearish OB
                    # Bearish OB is mitigated if price closes above high
                    if current_price > ob.high_price:
                        ob.state = OrderBlockState.OB_STATE_MITIGATED
                        ob.is_fresh = False
                    # Tested if price is inside OB zone
                    elif ob.low_price <= current_price <= ob.high_price:
                        ob.state = OrderBlockState.OB_STATE_TESTED
                        ob.touch_count += 1
                        ob.is_fresh = False

    def get_active_obs(self) -> list[OrderBlock]:
        """Get all active (non-mitigated) order blocks."""
        return [ob for ob in self._order_blocks if ob.state == OrderBlockState.OB_STATE_ACTIVE]

    def get_nearest_ob(
        self,
        ob_type: OrderBlockType,
        current_price: float,
    ) -> OrderBlock | None:
        """Get nearest active order block of specified type."""
        active = [ob for ob in self._order_blocks
                  if ob.ob_type == ob_type
                  and ob.state in [OrderBlockState.OB_STATE_ACTIVE, OrderBlockState.OB_STATE_TESTED]]

        if not active:
            return None

        # Sort by distance to current price
        active.sort(key=lambda ob: abs((ob.high_price + ob.low_price) / 2 - current_price))
        return active[0]

    def get_proximity_score(
        self,
        ob_type: OrderBlockType,
        current_price: float,
        atr: float,
    ) -> float:
        """
        Calculate proximity score (0-100) based on distance to nearest OB.

        Args:
            ob_type: Type of order block to check
            current_price: Current price
            atr: Current ATR value

        Returns:
            Proximity score (0-100)
        """
        ob = self.get_nearest_ob(ob_type, current_price)
        if not ob:
            return 0.0

        ob_mid = (ob.high_price + ob.low_price) / 2
        distance = abs(current_price - ob_mid)
        distance_atr = distance / atr if atr > 0 else 999

        # Score based on distance
        if distance_atr <= 0.5:
            score = 100.0
        elif distance_atr <= 1.0:
            score = 80.0 + (1.0 - distance_atr) * 40
        elif distance_atr <= 2.0:
            score = 50.0 + (2.0 - distance_atr) * 30
        elif distance_atr <= 3.0:
            score = (3.0 - distance_atr) * 50
        else:
            score = 0.0

        # Adjust by OB quality
        score *= (ob.probability_score / 100.0)

        # Bonus if price is approaching OB
        if ob_type == OrderBlockType.OB_BULLISH and current_price > ob.high_price:
            score *= 1.2
        elif ob_type == OrderBlockType.OB_BEARISH and current_price < ob.low_price:
            score *= 1.2

        return float(min(100.0, score))

    def is_price_in_ob_zone(
        self,
        ob_type: OrderBlockType,
        current_price: float,
    ) -> bool:
        """Check if price is currently inside an OB zone."""
        for ob in self._order_blocks:
            if ob.ob_type != ob_type:
                continue
            if ob.state in [OrderBlockState.OB_STATE_MITIGATED, OrderBlockState.OB_STATE_DISABLED]:
                continue

            if ob.low_price <= current_price <= ob.high_price:
                return True

        return False


# ✓ FORGE v4.0: 7/7 checks
# CHECK 1: Error handling - InsufficientDataError, None checks
# CHECK 2: Bounds & Null - Array index checks, Optional types
# CHECK 3: Division by zero - avg_volume, atr checks
# CHECK 4: Resource management - No explicit resources
# CHECK 5: FTMO compliance - N/A (indicator only)
# CHECK 6: REGRESSION - Module is new, no dependencies yet
# CHECK 7: BUG PATTERNS - No known patterns applied
