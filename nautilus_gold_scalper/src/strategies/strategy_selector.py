"""
Strategy Selector - Dynamic strategy selection based on market context.

Port of CStrategySelector.mqh from MQL5.

Decision Hierarchy (6 Gates):
1. SAFETY FIRST - Circuit breaker, spread, FTMO
2. FTMO SAFE MODE - If near DD limit, reduce exposure
3. NEWS CHECK - Apply penalties/blocks (no dedicated news strategy)
4. SESSION CHECK - London/NY best, avoid Asia
5. HOLIDAY CHECK - Reduced liquidity days
6. REGIME SELECTION - Trend/Revert/Random based on Hurst/Entropy
"""

import logging
from dataclasses import dataclass
from datetime import datetime, timezone
from enum import IntEnum

logger = logging.getLogger(__name__)


class StrategyType(IntEnum):
    """Available trading strategies."""

    STRATEGY_NONE = 0  # No trading
    STRATEGY_NEWS_TRADER = 1  # News event trading
    STRATEGY_TREND_FOLLOW = 2  # Trending market (Hurst > 0.55)
    STRATEGY_MEAN_REVERT = 3  # Mean-reverting (Hurst < 0.45)
    STRATEGY_SMC_SCALPER = 4  # Default SMC scalping
    STRATEGY_SAFE_MODE = 5  # Reduced risk mode


class NewsImpact(IntEnum):
    """News event impact level."""

    IMPACT_LOW = 0
    IMPACT_MEDIUM = 1
    IMPACT_HIGH = 2


@dataclass
class MarketContext:
    """
    Complete market context for strategy selection.
    Aggregates all environmental factors.
    """

    # Regime
    hurst: float = 0.5
    entropy: float = 2.0
    is_trending: bool = False
    is_reverting: bool = False
    is_random: bool = True

    # News
    in_news_window: bool = False
    news_imminent: bool = False  # < 5 min
    minutes_to_news: int = 999
    news_impact: NewsImpact = NewsImpact.IMPACT_LOW

    # Session
    is_london: bool = False
    is_newyork: bool = False
    is_overlap: bool = False  # Best time
    is_asian: bool = False
    is_weekend: bool = False

    # Holiday
    is_holiday: bool = False
    reduced_liquidity: bool = False

    # Safety
    circuit_ok: bool = True
    spread_ok: bool = True
    spread_ratio: float = 1.0

    # FTMO/Prop Firm
    daily_dd_percent: float = 0.0
    total_dd_percent: float = 0.0
    near_dd_limit: bool = False  # > 3%

    # Technical
    atr: float = 0.0
    volatility_percentile: float = 50.0
    high_volatility: bool = False

    def reset(self) -> None:
        """Reset all fields to defaults."""
        self.hurst = 0.5
        self.entropy = 2.0
        self.is_trending = False
        self.is_reverting = False
        self.is_random = True

        self.in_news_window = False
        self.news_imminent = False
        self.minutes_to_news = 999
        self.news_impact = NewsImpact.IMPACT_LOW

        self.is_london = False
        self.is_newyork = False
        self.is_overlap = False
        self.is_asian = False
        self.is_weekend = False

        self.is_holiday = False
        self.reduced_liquidity = False

        self.circuit_ok = True
        self.spread_ok = True
        self.spread_ratio = 1.0

        self.daily_dd_percent = 0.0
        self.total_dd_percent = 0.0
        self.near_dd_limit = False

        self.atr = 0.0
        self.volatility_percentile = 50.0
        self.high_volatility = False


@dataclass
class StrategySelection:
    """Result of strategy selection."""

    strategy: StrategyType = StrategyType.STRATEGY_NONE
    size_multiplier: float = 0.0  # 0.0 - 1.0
    score_adjustment: int = 0  # Bonus/penalty for confluence
    reason: str = "Not analyzed"
    can_trade: bool = False

    # Confidence levels
    regime_confidence: float = 0.0
    timing_confidence: float = 0.0
    overall_confidence: float = 0.0

    def reset(self) -> None:
        """Reset to defaults."""
        self.strategy = StrategyType.STRATEGY_NONE
        self.size_multiplier = 0.0
        self.score_adjustment = 0
        self.reason = "Not analyzed"
        self.can_trade = False
        self.regime_confidence = 0.0
        self.timing_confidence = 0.0
        self.overall_confidence = 0.0


class StrategySelector:
    """
    Dynamic strategy selector based on market context.

    Uses 6-gate decision hierarchy to select optimal strategy:
    1. Safety blocks (circuit breaker, spread, weekend)
    2. FTMO safe mode (near DD limits)
    3. News events (apply penalties/blocks; no dedicated news strategy)
    4. Session (Asian blocked by default)
    5. Holiday (reduced position size)
    6. Regime (trending/reverting/random)
    """

    # Hurst thresholds
    DEFAULT_HURST_TREND = 0.55
    DEFAULT_HURST_REVERT = 0.40  # Changed from 0.45 - tighter filter for prime reverting

    # Entropy thresholds
    DEFAULT_ENTROPY_LOW = 1.5
    DEFAULT_ENTROPY_HIGH = 2.5

    def __init__(
        self,
        ftmo_safe_mode: bool = False,
        allow_news_trading: bool = True,
        allow_asian_session: bool = False,
        hurst_trend_threshold: float = DEFAULT_HURST_TREND,
        hurst_revert_threshold: float = DEFAULT_HURST_REVERT,
        entropy_low_threshold: float = DEFAULT_ENTROPY_LOW,
        entropy_high_threshold: float = DEFAULT_ENTROPY_HIGH,
        holiday_detector: object | None = None,
    ):
        """
        Initialize the strategy selector.

        Args:
            ftmo_safe_mode: Enable extra conservative mode
            allow_news_trading: Allow news trading strategy
            allow_asian_session: Allow trading in Asian session
            hurst_trend_threshold: Hurst above this = trending
            hurst_revert_threshold: Hurst below this = reverting
            entropy_low_threshold: Entropy below this = low noise
            entropy_high_threshold: Entropy above this = high noise
            holiday_detector: Optional HolidayDetector for automatic holiday detection
        """
        self.ftmo_safe_mode = ftmo_safe_mode
        self.allow_news_trading = allow_news_trading
        self.allow_asian_session = allow_asian_session

        self.hurst_trend = hurst_trend_threshold
        self.hurst_revert = hurst_revert_threshold
        self.entropy_low = entropy_low_threshold
        self.entropy_high = entropy_high_threshold

        self._context = MarketContext()
        self._selection = StrategySelection()
        self._last_update: datetime | None = None

        # External regime (from Python hub or local calc)
        self._current_hurst = 0.5
        self._current_entropy = 2.0

        # Holiday detection (optional)
        self._holiday_detector = holiday_detector

        logger.info(
            f"StrategySelector initialized: ftmo_safe={ftmo_safe_mode}, "
            f"news={allow_news_trading}, asian={allow_asian_session}, "
            f"holiday_detector={'wired' if holiday_detector else 'none'}"
        )

    def set_regime(self, hurst: float, entropy: float) -> None:
        """Update regime from external source."""
        self._current_hurst = hurst
        self._current_entropy = entropy

    def update_context(
        self,
        # Safety
        circuit_ok: bool = True,
        spread_ok: bool = True,
        spread_ratio: float = 1.0,
        # FTMO
        daily_dd_percent: float = 0.0,
        total_dd_percent: float = 0.0,
        # News
        in_news_window: bool = False,
        minutes_to_news: int = 999,
        news_impact: NewsImpact = NewsImpact.IMPACT_LOW,
        # Technical
        atr: float = 0.0,
        # Time (for backtest correctness)
        bar_time: datetime | None = None,
    ) -> None:
        """
        Update market context from external sources.

        Args:
            circuit_ok: Circuit breaker status
            spread_ok: Spread monitor status
            spread_ratio: Current spread vs average
            daily_dd_percent: Daily drawdown %
            total_dd_percent: Total drawdown %
            in_news_window: Whether in news blackout
            minutes_to_news: Minutes to next news event
            news_impact: Impact level of upcoming news
            atr: Current ATR value
            bar_time: Bar timestamp for backtest correctness (uses system time if None)
        """
        self._context.circuit_ok = circuit_ok
        self._context.spread_ok = spread_ok
        self._context.spread_ratio = spread_ratio

        self._context.daily_dd_percent = daily_dd_percent
        self._context.total_dd_percent = total_dd_percent
        self._context.near_dd_limit = daily_dd_percent >= 3.0

        self._context.in_news_window = in_news_window
        self._context.minutes_to_news = minutes_to_news
        self._context.news_imminent = 0 < minutes_to_news <= 5
        self._context.news_impact = news_impact

        self._context.atr = atr

        # Update session info (use bar_time for backtest correctness)
        self._update_session_info(bar_time)

        # Update regime info
        self._update_regime_info()

        self._last_update = bar_time if bar_time else datetime.now(timezone.utc)

    def _update_session_info(self, bar_time: datetime | None = None) -> None:
        """Update session detection based on bar time (or system time as fallback)."""
        # BUG FIX: Use bar_time for backtest correctness, not system time
        now = bar_time if bar_time else datetime.now(timezone.utc)
        hour = now.hour
        day = now.weekday()  # 0=Monday, 6=Sunday

        # Weekend check
        self._context.is_weekend = day >= 5  # Saturday or Sunday

        # Session detection (UTC)
        self._context.is_asian = 0 <= hour < 7
        self._context.is_london = 7 <= hour < 16
        self._context.is_newyork = 13 <= hour < 22
        self._context.is_overlap = 13 <= hour < 16  # Best hours

        # Holiday detection (if HolidayDetector is wired)
        if self._holiday_detector is not None:
            try:
                # HolidayDetector.is_holiday(check_time) -> bool
                is_holiday_method = getattr(self._holiday_detector, "is_holiday", None)
                if is_holiday_method is not None:
                    self._context.is_holiday = is_holiday_method(now)
                    # Also check for reduced liquidity (day before/after major holidays)
                    reduced_liq_method = getattr(
                        self._holiday_detector, "is_reduced_liquidity", None
                    )
                    if reduced_liq_method is not None:
                        self._context.reduced_liquidity = reduced_liq_method(now)
            except Exception:
                # Fail-safe: if HolidayDetector fails, assume no holiday
                self._context.is_holiday = False
                self._context.reduced_liquidity = False

    def _update_regime_info(self) -> None:
        """Update regime classification."""
        self._context.hurst = self._current_hurst
        self._context.entropy = self._current_entropy

        # Classify regime
        self._context.is_trending = self._context.hurst > self.hurst_trend
        self._context.is_reverting = self._context.hurst < self.hurst_revert
        self._context.is_random = not self._context.is_trending and not self._context.is_reverting

        # High entropy = high noise
        self._context.high_volatility = self._context.entropy > self.entropy_high

    def select_strategy(self, context: MarketContext | None = None) -> StrategySelection:
        """
        Select optimal strategy based on market context.

        Args:
            context: Optional external context (uses internal if None)

        Returns:
            StrategySelection with recommended strategy
        """
        if context is not None:
            self._context = context

        self._selection = self._evaluate_strategies()
        return self._selection

    def _evaluate_strategies(self) -> StrategySelection:
        """Evaluate all strategies and select best."""
        result = StrategySelection()
        result.reset()

        # ================================================================
        # GATE 1: ABSOLUTE BLOCKS
        # ================================================================

        # Circuit breaker
        if not self._context.circuit_ok:
            result.strategy = StrategyType.STRATEGY_NONE
            result.can_trade = False
            result.reason = "Circuit breaker active"
            return result

        # Spread too high
        if not self._context.spread_ok:
            result.strategy = StrategyType.STRATEGY_NONE
            result.can_trade = False
            result.reason = "Spread too high"
            return result

        # Weekend
        if self._context.is_weekend:
            result.strategy = StrategyType.STRATEGY_NONE
            result.can_trade = False
            result.reason = "Weekend - market closed"
            return result

        # ================================================================
        # GATE 2: FTMO SAFE MODE
        # ================================================================

        if self.ftmo_safe_mode or self._context.near_dd_limit:
            # Near DD limit - ultra conservative
            if self._context.daily_dd_percent >= 3.5:
                result.strategy = StrategyType.STRATEGY_NONE
                result.can_trade = False
                result.reason = "FTMO Safe: DD too high (>3.5%)"
                return result

            # Safe mode active
            result.strategy = StrategyType.STRATEGY_SAFE_MODE
            result.size_multiplier = 0.25
            result.score_adjustment = -20
            result.can_trade = True
            result.reason = "FTMO Safe Mode active"

            # Block news trading in safe mode
            if self._context.in_news_window:
                result.strategy = StrategyType.STRATEGY_NONE
                result.can_trade = False
                result.reason = "FTMO Safe: No news trading"
                return result

            return result

        # ================================================================
        # GATE 3: NEWS CHECK
        # ================================================================

        # No dedicated "news trader" strategy.
        # If enabled, we allow trading during news windows with reduced size / confluence penalty.
        if self._context.in_news_window:
            if not self.allow_news_trading:
                result.strategy = StrategyType.STRATEGY_NONE
                result.can_trade = False
                result.reason = "News window - trading disabled"
                return result

            # High impact news window - reduce size (but still route by regime)
            if self._context.news_impact == NewsImpact.IMPACT_HIGH:
                result.size_multiplier = 0.5
                result.score_adjustment = -20
                # Continue to regime selection

            # Medium impact - reduce normal trading
            if self._context.news_impact == NewsImpact.IMPACT_MEDIUM:
                result.size_multiplier = 0.5
                result.score_adjustment = -15
                # Continue to regime selection

        # News imminent - block all trading
        if self._context.news_imminent and self._context.news_impact == NewsImpact.IMPACT_HIGH:
            result.strategy = StrategyType.STRATEGY_NONE
            result.can_trade = False
            result.reason = "High impact news in < 5 min"
            return result

        # ================================================================
        # GATE 4: SESSION CHECK
        # ================================================================

        # Asian session - check if mean-reverting regime (allow Asian for ranging)
        if self._context.is_asian and not self.allow_asian_session:
            # Exception: Allow Asian for MEAN_REVERT if prime reverting
            if self._context.is_reverting and self._context.hurst < 0.40:
                # Asian + reverting = allow with reduced size
                result.size_multiplier = 0.5
                result.score_adjustment -= 5
                # Continue to regime selection
            else:
                result.strategy = StrategyType.STRATEGY_NONE
                result.can_trade = False
                result.reason = "Asian session blocked (not reverting)"
                return result

        # Best time: London/NY overlap
        if self._context.is_overlap:
            result.timing_confidence = 1.0
            result.score_adjustment += 10
        elif self._context.is_london or self._context.is_newyork:
            result.timing_confidence = 0.8
        else:
            result.timing_confidence = 0.5
            result.size_multiplier = (
                min(result.size_multiplier + 0.5, 0.5) if result.size_multiplier > 0 else 0.5
            )

        # ================================================================
        # GATE 5: HOLIDAY CHECK
        # ================================================================

        if self._context.is_holiday or self._context.reduced_liquidity:
            result.size_multiplier = (
                min(result.size_multiplier + 0.5, 0.5) if result.size_multiplier > 0 else 0.5
            )
            result.score_adjustment -= 10
            result.reason = (
                "Holiday - reduced liquidity" if self._context.is_holiday else "Reduced liquidity"
            )

        # ================================================================
        # GATE 6: REGIME SELECTION
        # ================================================================

        # Random walk - no trade
        if self._context.is_random:
            result.strategy = StrategyType.STRATEGY_NONE
            result.can_trade = False
            result.reason = f"Random walk regime (Hurst ~{self._context.hurst:.2f})"
            return result

        # High noise - reduce confidence
        if self._context.high_volatility:
            result.size_multiplier = (
                min(result.size_multiplier + 0.5, 0.5) if result.size_multiplier > 0 else 0.5
            )
            result.score_adjustment -= 15

        # Trending market
        if self._context.is_trending:
            result.strategy = StrategyType.STRATEGY_TREND_FOLLOW
            result.regime_confidence = (self._context.hurst - 0.5) / 0.5  # Normalize

            if self._context.entropy < self.entropy_low:
                # Prime trending: high Hurst, low entropy
                result.size_multiplier = 1.0
                result.score_adjustment += 15
                result.reason = "Prime trending regime"
            else:
                # Noisy trending
                result.size_multiplier = 0.5
                result.reason = "Noisy trending regime"

        # Mean reverting market
        elif self._context.is_reverting:
            result.strategy = StrategyType.STRATEGY_MEAN_REVERT
            result.regime_confidence = (0.5 - self._context.hurst) / 0.5  # Normalize

            if self._context.entropy < self.entropy_low:
                # Prime reverting
                result.size_multiplier = 1.0
                result.score_adjustment += 10
                result.reason = "Prime reverting regime"
            else:
                # Noisy reverting
                result.size_multiplier = 0.5
                result.reason = "Noisy reverting regime"

        # Default: SMC Scalper
        else:
            result.strategy = StrategyType.STRATEGY_SMC_SCALPER
            result.size_multiplier = 0.75
            result.reason = "Default SMC scalping"

        result.can_trade = True
        result.overall_confidence = self._calculate_confidence(result)

        return result

    def _calculate_confidence(self, result: StrategySelection) -> float:
        """Calculate overall confidence score."""
        regime_weight = 0.5
        timing_weight = 0.3
        safety_weight = 0.2

        regime_score = result.regime_confidence
        timing_score = result.timing_confidence
        safety_score = 1.0 if (self._context.circuit_ok and self._context.spread_ok) else 0.0

        return (
            regime_score * regime_weight
            + timing_score * timing_weight
            + safety_score * safety_weight
        )

    @property
    def context(self) -> MarketContext:
        """Get current market context."""
        return self._context

    @property
    def current_strategy(self) -> StrategyType:
        """Get currently selected strategy."""
        return self._selection.strategy

    @property
    def can_trade(self) -> bool:
        """Check if trading is allowed."""
        return self._selection.can_trade

    @property
    def size_multiplier(self) -> float:
        """Get position size multiplier."""
        return self._selection.size_multiplier

    def get_strategy_name(self, strategy: StrategyType) -> str:
        """Get human-readable strategy name."""
        names = {
            StrategyType.STRATEGY_NONE: "NONE",
            StrategyType.STRATEGY_NEWS_TRADER: "NEWS_TRADER",  # Deprecated: no longer selected by StrategySelector
            StrategyType.STRATEGY_TREND_FOLLOW: "TREND_FOLLOW",
            StrategyType.STRATEGY_MEAN_REVERT: "MEAN_REVERT",
            StrategyType.STRATEGY_SMC_SCALPER: "SMC_SCALPER",
            StrategyType.STRATEGY_SAFE_MODE: "SAFE_MODE",
        }
        return names.get(strategy, "UNKNOWN")

    def print_selection(self) -> None:
        """Print selection details to log."""
        logger.info("=== Strategy Selection ===")
        logger.info(f"Strategy: {self.get_strategy_name(self._selection.strategy)}")
        logger.info(f"Can Trade: {self._selection.can_trade}")
        logger.info(f"Size Mult: {self._selection.size_multiplier:.2f}")
        logger.info(f"Score Adj: {self._selection.score_adjustment}")
        logger.info(f"Reason: {self._selection.reason}")
        logger.info("--- Context ---")
        logger.info(f"Hurst: {self._context.hurst:.3f} Entropy: {self._context.entropy:.3f}")
        logger.info(
            f"Trending: {self._context.is_trending} Reverting: {self._context.is_reverting}"
        )
        logger.info(f"Session: London={self._context.is_london} NY={self._context.is_newyork}")
        logger.info(f"News Window: {self._context.in_news_window}")
        logger.info(
            f"DD: Daily={self._context.daily_dd_percent:.2f}% Total={self._context.total_dd_percent:.2f}%"
        )
        logger.info("==========================")
