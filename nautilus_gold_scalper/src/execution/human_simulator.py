"""
Human Behavior Simulator (HBS) v2.2
===================================
Implements 18+ humanization techniques to make automated trading
statistically indistinguishable from manual trading.

Key improvements over v1.0:
- Mixture model delays (Gaussian + log-normal long-tail)
- Economic calendar awareness
- Session mood variance
- Signal throttling
- Logistic fatigue curve
- Proper RNG seeding and persistence
- Crisis mode for DD > 3.5%
- Per-account parameter jitter (A1)
- Day-of-week variance (A5)
- Exponential fear response after losses (A2)

All CRITIC/ARGUS fixes incorporated:
- C-NEW-1, C-NEW-2, C-NEW-3
- H-NEW-1 through H-NEW-6
- A1, A2, A4, A5 enhancements
"""

import hashlib
import json
import logging
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any, Literal
from zoneinfo import ZoneInfo

import numpy as np

from .economic_calendar import EconomicCalendar
from .human_config import HumanSimConfig

ET = ZoneInfo("America/New_York")


def _localize_et_strict(dt: datetime) -> datetime:
    """Attach ET tzinfo to naive datetimes, handling DST correctly.

    This emulates `pytz.timezone(...).localize(dt, is_dst=None)` strictness:
    - Raises ValueError for ambiguous (fall-back) local times.
    - Raises ValueError for nonexistent (spring-forward) local times.
    - Returns an ET-aware datetime when unambiguous.

    Note on `zoneinfo`:
        For many unambiguous local times, `fold=0` and `fold=1` may produce the
        same UTC offset, so a naive "round-trip" check alone cannot distinguish
        ambiguity. We must also consider offset differences.
    """
    if dt.tzinfo is not None:
        return dt.astimezone(ET)

    # Evaluate both folds.
    dt_fold0 = dt.replace(tzinfo=ET, fold=0)
    dt_fold1 = dt.replace(tzinfo=ET, fold=1)

    # Detect ambiguity via offset difference.
    off0 = dt_fold0.utcoffset()
    off1 = dt_fold1.utcoffset()
    if off0 is not None and off1 is not None and off0 != off1:
        raise ValueError(f"Ambiguous local time in ET: {dt!r}")

    # Detect nonexistent local times via strict round-trip.
    rt0 = dt_fold0.astimezone(timezone.utc).astimezone(ET).replace(tzinfo=None)
    rt1 = dt_fold1.astimezone(timezone.utc).astimezone(ET).replace(tzinfo=None)

    ok0 = rt0 == dt
    ok1 = rt1 == dt

    if not ok0 and not ok1:
        raise ValueError(f"Nonexistent local time in ET: {dt!r}")

    # Unambiguous local time: choose fold=0 by convention.
    return dt_fold0


logger = logging.getLogger(__name__)


@dataclass
class HBSState:
    """Mutable state tracking for the simulator."""

    # Daily state (reset on session_start)
    trades_today: int = 0
    warmup_trades_target: int = 1  # Randomized 1-3
    daily_pnl: float = 0.0
    is_sick_day: bool = False
    session_start: datetime | None = None

    # Cumulative state (persists across days for Apex 30% rule)
    cumulative_pnl: float = 0.0

    # Streak state
    consecutive_losses: int = 0
    consecutive_wins: int = 0

    # Timing state (for throttling)
    last_trade_time: datetime | None = None
    orders_this_minute: int = 0
    minute_start: datetime | None = None

    # Mood state (daily modifier - H7 fix)
    mood_modifier: float = 1.0  # 0.80 - 1.20

    # Break state
    in_micro_break: bool = False
    break_end_time: datetime | None = None

    # Fatigue
    hours_traded_today: float = 0.0

    # CRITICAL-3 FIX: Big win pause state
    big_win_pause_until: datetime | None = None


@dataclass
class HBSDecision:
    """Output of HBS decision-making."""

    should_skip: bool = False
    skip_reason: str | None = None
    delay_seconds: float = 0.0
    size_multiplier: float = 1.0
    order_type: Literal["MARKET", "LIMIT", "STOP_LIMIT"] = "MARKET"
    entry_offset_ticks: int = 0
    is_throttled: bool = False
    throttle_wait_seconds: float = 0.0
    # C-NEW-2 FIX: Add limit_price and stop_price for LIMIT/STOP_LIMIT orders
    limit_price: float | None = None  # Price for LIMIT orders
    stop_price: float | None = None  # Trigger price for STOP_LIMIT orders
    # H-NEW-4 FIX: Context-aware cancellation
    cancel_if_price_moves_ticks: int = 5  # Cancel limit if price moves X ticks away
    cancel_after_seconds: float = 30.0  # Cancel limit if not filled in X seconds


class HumanBehaviorSimulator:
    """
    Core HBS implementation with 18+ humanization techniques.

    Thread-safety: NOT thread-safe. Use one instance per strategy.

    Usage:
        config = HumanSimConfig(
            rng_seed_account_id="account123",
            apex_profit_target=4000.0,  # For $50k account with 8% target
        )
        hbs = HumanBehaviorSimulator(config)

        # At session start:
        hbs.on_session_start(datetime.now(ET))

        # For each signal:
        decision = hbs.decide(
            signal_score=0.85,
            current_time=datetime.now(ET),
            current_atr=1.5,
            atr_percentile=75.0,
            current_dd=0.02,
        )

        if not decision.should_skip:
            await asyncio.sleep(decision.delay_seconds)
            # Execute with decision.size_multiplier, decision.order_type, etc.

        # After trade result:
        hbs.on_trade_result(win=True, pnl=150.0)

        # At session end:
        hbs.on_session_end()
    """

    def __init__(
        self,
        config: HumanSimConfig,
        calendar: EconomicCalendar | None = None,
    ):
        self.config = config
        self.state = HBSState()
        self.calendar = calendar or EconomicCalendar()

        # A1 FIX: Apply per-account parameter jitter for multivariate defense
        if config.jitter_enabled and config.rng_seed_account_id:
            self._apply_account_jitter()

        # Initialize RNG with proper seeding (C1, H8 fix)
        self._rng = self._create_rng()

        # Load persisted state if exists
        if config.rng_persist_state:
            self._load_rng_state()

        logger.info(
            f"HBS initialized: mode={config.mode}, "
            f"account={config.rng_seed_account_id[:8]}..., "
            f"jitter={'ON' if config.jitter_enabled else 'OFF'}"
        )

    def _apply_account_jitter(self) -> None:
        """
        A1 FIX: Apply per-account parameter jitter for multivariate defense.

        Different accounts should have slightly different behavioral parameters
        to prevent AI detection systems from clustering accounts by behavior.
        The jitter is deterministic based on account_id so it's reproducible.
        """
        # Create deterministic jitter based on account_id
        if not self.config.rng_seed_account_id:
            return  # Can't jitter without account ID

        # Hash account ID to get deterministic jitter seed
        hash_bytes = hashlib.sha256(self.config.rng_seed_account_id.encode()).digest()
        jitter_seed = int.from_bytes(hash_bytes[:8], byteorder="big")
        jitter_rng = np.random.default_rng(jitter_seed)

        jitter_range = self.config.jitter_range

        # Apply jitter to key behavioral parameters
        def jitter(value: float) -> float:
            mult = jitter_rng.uniform(1.0 - jitter_range, 1.0 + jitter_range)
            return value * mult

        # Jitter delay parameters
        self.config.delay_mean = jitter(self.config.delay_mean)
        self.config.delay_std = jitter(self.config.delay_std)

        # Jitter skip rate
        self.config.skip_base_rate = jitter(self.config.skip_base_rate)

        # Jitter size variation
        self.config.size_variation = jitter(self.config.size_variation)

        # Jitter throttle cooldown
        self.config.throttle_cooldown_seconds = jitter(self.config.throttle_cooldown_seconds)

        logger.debug(
            f"Applied account jitter (±{jitter_range * 100:.0f}%): "
            f"delay_mean={self.config.delay_mean:.3f}, "
            f"skip_rate={self.config.skip_base_rate:.3f}"
        )

    # ==========================================================================
    # CORE API
    # ==========================================================================

    def decide(
        self,
        signal_score: float,
        current_time: datetime,
        current_atr: float,
        atr_percentile: float,
        current_dd: float = 0.0,
    ) -> HBSDecision:
        """
        Main entry point: given a signal, return humanized execution decision.

        Args:
            signal_score: Confluence score 0.0-1.0
            current_time: Current timestamp (timezone-aware)
            current_atr: Current ATR value
            atr_percentile: Percentile rank of current ATR (0-100)
            current_dd: Current TRAILING drawdown from HIGH-WATER MARK as decimal.
                        Example: 0.035 = 3.5% trailing DD.
                        CRITICAL: Must be trailing DD for Apex compliance (H-NEW-6),
                        NOT daily DD or total DD from starting equity.

        Returns:
            HBSDecision with all humanization applied
        """
        if not self.config.enabled:
            return HBSDecision()

        # Ensure timezone
        if current_time.tzinfo is None:
            current_time = _localize_et_strict(current_time)  # R13-FIX

        decision = HBSDecision()

        # H-NEW-6 FIX: Check if we're in crisis mode (DD > threshold)
        in_crisis = (
            self.config.crisis_mode_enabled and current_dd >= self.config.crisis_dd_threshold
        )

        # === PRE-CHECKS ===

        # CRITICAL-3 FIX: Big win pause - check if still in pause period
        if self.state.big_win_pause_until is not None:
            if current_time < self.state.big_win_pause_until:
                decision.should_skip = True
                decision.skip_reason = "big_win_pause"
                return decision
            else:
                # Pause expired, clear it
                self.state.big_win_pause_until = None

        # Sick day?
        if self.state.is_sick_day:
            decision.should_skip = True
            decision.skip_reason = "sick_day"
            return decision

        # Micro-break?
        if self._in_micro_break(current_time):
            decision.should_skip = True
            decision.skip_reason = "micro_break"
            return decision

        # HIGH-5 FIX: Apex time gate - block new trades after 4:30 PM ET
        if self.is_new_trade_blocked(current_time):
            decision.should_skip = True
            decision.skip_reason = "apex_time_gate_4:30PM"
            logger.warning(
                f"New trades blocked: time={current_time.astimezone(ET).strftime('%H:%M')} ET "
                f">= 16:30 (Apex time gate)"
            )
            return decision

        # Trading hours?
        if not self._is_trading_hours(current_time):
            decision.should_skip = True
            decision.skip_reason = "outside_trading_hours"
            return decision

        # Economic event block?
        event = self.calendar.get_nearest_event(current_time)
        if event and self.calendar.is_pre_event_blocked(
            current_time, event, self.config.news_pre_event_block_minutes
        ):
            decision.should_skip = True
            decision.skip_reason = f"pre_news_block:{event.name}"
            return decision

        # Signal throttle check (H4 fix)
        throttle_result = self._check_throttle(current_time)
        if throttle_result[0]:
            decision.is_throttled = True
            decision.throttle_wait_seconds = throttle_result[1]
            decision.should_skip = True
            decision.skip_reason = "throttled"
            return decision

        # CRITICAL-4 FIX: Apex 30% rule enforcement
        # Prevent daily profit from exceeding 30% of profit target (consistency rule)
        if self.is_30pct_rule_hit():
            decision.should_skip = True
            decision.skip_reason = "apex_30pct_rule"
            logger.warning(
                f"30% rule hit: daily_pnl={self.state.daily_pnl:.2f} >= "
                f"max={self.get_max_daily_pnl_allowed():.2f}"
            )
            return decision

        # === SKIP LOGIC ===

        # H-NEW-6 FIX: In crisis mode, NEVER skip signals (execute ASAP)
        if not in_crisis or not self.config.crisis_skip_disabled:
            should_skip, skip_reason = self._should_skip_signal(
                signal_score, atr_percentile, current_time
            )
            if should_skip:
                decision.should_skip = True
                decision.skip_reason = skip_reason
                return decision

        # === DELAY CALCULATION ===

        base_delay = self._calculate_delay_mixture(current_time)

        # Apply volatility modifier
        if atr_percentile >= self.config.high_volatility_atr_percentile:
            base_delay *= self.config.high_volatility_delay_multiple

        # Apply news event modifier (C5 fix)
        if event:
            news_mult = self.calendar.get_post_event_delay_multiplier(
                current_time,
                event,
                self.config.news_post_event_delay_minutes,
                self.config.news_high_impact_delay_mult,
                self.config.news_medium_impact_delay_mult,
            )
            base_delay *= news_mult

        # Apply mood modifier (H7 fix)
        if self.config.mood_variance_enabled and "delay" in self.config.mood_affects:
            base_delay *= self.state.mood_modifier

        # H-NEW-6 FIX: In crisis mode, reduce delays to execute faster
        if in_crisis:
            base_delay *= 1.0 - self.config.crisis_delay_reduction
            logger.warning(
                f"CRISIS MODE: DD={current_dd * 100:.2f}% > "
                f"{self.config.crisis_dd_threshold * 100:.1f}%, "
                f"delay reduced by {self.config.crisis_delay_reduction * 100:.0f}%"
            )

        decision.delay_seconds = base_delay

        # === SIZE CALCULATION ===

        decision.size_multiplier = self._calculate_size_multiplier()

        # === ORDER TYPE ===

        # A4 FIX: Pass atr_percentile for volatility-adaptive order types
        # CRITICAL-1 FIX: Pass current_time for backtest-correct weekday calculation
        decision.order_type = self._select_order_type(atr_percentile, current_time)

        # === ENTRY OFFSET ===

        decision.entry_offset_ticks = int(
            self._rng.integers(0, self.config.entry_offset_ticks_max + 1)
        )

        # CRITICAL-6 FIX: Document and validate limit price requirement
        # For LIMIT/STOP_LIMIT orders, caller MUST calculate limit_price and stop_price
        # using current_price, tick_size, and direction.
        # See calculate_limit_prices() helper method below.
        if decision.order_type in ("LIMIT", "STOP_LIMIT"):
            logger.debug(
                f"Order type {decision.order_type} selected. "
                f"Caller must set limit_price/stop_price using calculate_limit_prices()."
            )

        return decision

    def calculate_limit_prices(
        self,
        direction: Literal["BUY", "SELL"],
        current_price: float,
        tick_size: float,
        offset_ticks: int = 0,
    ) -> tuple[float | None, float | None]:
        """
        CRITICAL-6 FIX: Helper to calculate limit/stop prices for LIMIT/STOP_LIMIT orders.

        Args:
            direction: "BUY" or "SELL"
            current_price: Current market price
            tick_size: Instrument tick size (e.g., 0.01 for XAUUSD)
            offset_ticks: Number of ticks to offset from current price (from HBSDecision)

        Returns:
            Tuple of (limit_price, stop_price) where:
            - For LIMIT orders: limit_price is set, stop_price is None
            - For STOP_LIMIT orders: both are set (stop triggers entry)

        Usage:
            decision = hbs.decide(...)
            if decision.order_type in ("LIMIT", "STOP_LIMIT"):
                limit_price, stop_price = hbs.calculate_limit_prices(
                    direction="BUY",
                    current_price=current_price,
                    tick_size=0.01,
                    offset_ticks=decision.entry_offset_ticks,
                )
                decision.limit_price = limit_price
                decision.stop_price = stop_price
        """
        offset = offset_ticks * tick_size

        if direction == "BUY":
            # Buy limit = below market (want better price)
            limit_price = current_price - offset
            # Buy stop = above market (triggers if price rises)
            stop_price = current_price + offset
        else:  # SELL
            # Sell limit = above market (want better price)
            limit_price = current_price + offset
            # Sell stop = below market (triggers if price falls)
            stop_price = current_price - offset

        return limit_price, stop_price

    def on_trade_result(
        self,
        win: bool,
        pnl: float,
        current_time: datetime | None = None,
    ) -> None:
        """Update state after trade completes.

        Args:
            win: Whether the trade was a winner
            pnl: Profit/loss amount
            current_time: Current timestamp (REQUIRED for backtest mode).
                          If None in live mode, uses datetime.now(ET).

        Raises:
            ValueError: If current_time is None in backtest mode (R3-M-1 FIX)
        """
        # R3-M-1 FIX: Enforce current_time in backtest mode
        if current_time is None:
            if self.config.mode == "backtest":
                raise ValueError(
                    "current_time is REQUIRED in backtest mode to ensure temporal correctness"
                )
            current_time = datetime.now(ET)
        elif current_time.tzinfo is None:
            current_time = _localize_et_strict(current_time)  # R13-FIX

        self.state.trades_today += 1
        self.state.daily_pnl += pnl
        self.state.cumulative_pnl += pnl

        if win:
            self.state.consecutive_wins += 1
            self.state.consecutive_losses = 0

            # CRITICAL-3 FIX: Big win pause - humans celebrate/relax after large wins
            if self.config.pause_after_big_win and pnl > 0:
                # Check if this is a "big win" (>2% of daily P&L or absolute threshold)
                pnl_pct = pnl / max(self.config.apex_profit_target, 1.0)
                if pnl_pct >= self.config.big_win_threshold:
                    # Roll probability of pause
                    if self._rng.random() < self.config.big_win_pause_probability:
                        # Pause for 5-15 minutes (human celebration/relaxation)
                        pause_minutes = float(self._rng.uniform(5, 15))
                        # HIGH-2 FIX: Use current_time instead of datetime.now()
                        self.state.big_win_pause_until = current_time + timedelta(
                            minutes=pause_minutes
                        )
                        logger.info(
                            f"Big win pause triggered: pnl={pnl:.2f} ({pnl_pct * 100:.1f}%), "
                            f"pausing for {pause_minutes:.1f} minutes"
                        )
        else:
            self.state.consecutive_losses += 1
            self.state.consecutive_wins = 0

        # HIGH-1 FIX: Use current_time instead of datetime.now()
        self.state.last_trade_time = current_time

        # Maybe roll micro-break
        self._maybe_start_micro_break(current_time)

        # Persist RNG state
        if self.config.rng_persist_state:
            self._save_rng_state()

        logger.debug(
            f"Trade result: win={win}, pnl={pnl:.2f}, "
            f"daily_pnl={self.state.daily_pnl:.2f}, "
            f"streak={'W' if win else 'L'}{max(self.state.consecutive_wins, self.state.consecutive_losses)}"
        )

    def on_session_start(self, dt: datetime) -> None:
        """Reset daily state, roll sick day, set mood."""
        # Ensure timezone
        if dt.tzinfo is None:
            dt = _localize_et_strict(dt)  # R13-FIX

        # Reset daily state
        self.state.trades_today = 0
        self.state.daily_pnl = 0.0
        self.state.hours_traded_today = 0.0
        self.state.session_start = dt
        self.state.orders_this_minute = 0
        self.state.minute_start = None
        self.state.in_micro_break = False
        self.state.break_end_time = None

        # Randomize warmup trades (1-3)
        self.state.warmup_trades_target = int(
            self._rng.integers(
                self.config.size_warmup_trades_min,
                self.config.size_warmup_trades_max + 1,
            )
        )

        # Roll sick day
        sick_rate = self.config.sick_day_rate
        if dt.weekday() == 0:  # Monday
            sick_rate *= self.config.sick_day_monday_reduction
        self.state.is_sick_day = bool(self._rng.random() < sick_rate)

        # Roll daily mood (H7 fix)
        if self.config.mood_variance_enabled:
            self.state.mood_modifier = float(
                self._rng.uniform(
                    self.config.mood_daily_modifier_min,
                    self.config.mood_daily_modifier_max,
                )
            )

        # Re-seed RNG for new session (H8 fix)
        if self.config.rng_seed_from_date:
            self._reseed_for_date(dt)

        # Load economic calendar for this date range
        self.calendar.load_events(
            dt,
            dt + timedelta(days=1),
        )

        logger.info(
            f"Session started: {dt.date()}, "
            f"sick_day={self.state.is_sick_day}, "
            f"mood={self.state.mood_modifier:.2f}, "
            f"warmup_trades={self.state.warmup_trades_target}"
        )

    def on_session_end(self) -> None:
        """End of day cleanup."""
        # Persist final state
        if self.config.rng_persist_state:
            self._save_rng_state()

        logger.info(
            f"Session ended: trades={self.state.trades_today}, daily_pnl={self.state.daily_pnl:.2f}"
        )

    # ==========================================================================
    # TECHNIQUE IMPLEMENTATIONS
    # ==========================================================================

    def _calculate_delay_mixture(self, current_time: datetime) -> float:
        """
        Tier 1: Mixture model delay (H1 fix).
        80% Gaussian + 20% log-normal for anti-detection.
        """
        # Choose component
        if self._rng.random() < self.config.delay_gaussian_weight:
            # Gaussian component
            delay = float(
                self._rng.normal(
                    self.config.delay_mean,
                    self.config.delay_std,
                )
            )
        else:
            # Log-normal component (long-tail)
            delay = float(
                self._rng.lognormal(
                    self.config.delay_longtail_mu,
                    self.config.delay_longtail_sigma,
                )
            )

        # Apply fatigue
        fatigue_mult = self._calculate_fatigue_modifier(current_time)
        delay *= fatigue_mult

        # Clamp to bounds
        delay = float(np.clip(delay, self.config.delay_min, self.config.delay_max))

        return delay

    def _calculate_fatigue_modifier(self, current_time: datetime) -> float:
        """
        Fatigue using logistic curve (M2 fix).
        Increases faster early, plateaus later.
        """
        if self.state.session_start is None:
            return 1.0

        hours = (current_time - self.state.session_start).total_seconds() / 3600
        self.state.hours_traded_today = hours

        if self.config.delay_fatigue_curve == "logistic":
            # Logistic: 1 + max * sigmoid((hours - midpoint) / scale)
            midpoint = self.config.delay_fatigue_midpoint_hours
            scale = 1.0  # How sharp the transition is
            sigmoid = float(1 / (1 + np.exp(-(hours - midpoint) / scale)))
            fatigue = float(1.0 + self.config.delay_fatigue_max * sigmoid)
        else:
            # Linear fallback
            fatigue = 1.0 + (hours * self.config.delay_fatigue_max / 8.0)

        return float(min(fatigue, 1.0 + self.config.delay_fatigue_max))

    def _should_skip_signal(
        self,
        signal_score: float,
        atr_percentile: float,
        current_time: datetime,
    ) -> tuple[bool, str | None]:
        """Tier 2: Signal skip logic with mood modifier and ARGUS enhancements."""
        if not self.config.skip_enabled:
            return False, None

        skip_rate = self.config.skip_base_rate

        # A5 FIX: Apply day-of-week modifier
        # CRITICAL-1 FIX: Use current_time instead of datetime.now() for backtest correctness
        dt_et = current_time.astimezone(ET)
        weekday_name = dt_et.strftime("%A")
        weekday_mod = self.config.weekday_modifiers.get(weekday_name, 1.0)
        skip_rate *= weekday_mod

        # Apply mood modifier (H7)
        if self.config.mood_variance_enabled and "skip" in self.config.mood_affects:
            skip_rate *= self.state.mood_modifier

        # A2 FIX: EXPONENTIAL skip rate increase after losses (fear response)
        # Human traders become increasingly cautious after losses
        if self.state.consecutive_losses >= 1:
            # Exponential: base^losses (e.g., 1.5^3 = 3.375x increase after 3 losses)
            fear_multiplier = 1.5**self.state.consecutive_losses
            # Cap at 5x to prevent excessive skipping
            fear_multiplier = min(fear_multiplier, 5.0)
            skip_rate *= fear_multiplier

        # Weak signal increase
        if signal_score < self.config.skip_weak_threshold:
            skip_rate += 0.10

        # High volatility increase
        if atr_percentile >= self.config.high_volatility_atr_percentile:
            skip_rate += self.config.high_volatility_skip_increase

        # Cap skip rate at reasonable max (don't skip >80% of signals)
        skip_rate = min(skip_rate, 0.80)

        # Roll
        if self._rng.random() < skip_rate:
            reason = "random_skip"
            if self.state.consecutive_losses >= 2:
                reason = "post_loss_skip"
            elif signal_score < self.config.skip_weak_threshold:
                reason = "weak_signal_skip"
            elif atr_percentile >= self.config.high_volatility_atr_percentile:
                reason = "volatility_skip"
            return True, reason

        return False, None

    def _calculate_size_multiplier(self) -> float:
        """Tier 2: Size variation with loss/warmup modifiers and mood."""
        # Base variation
        variation = float(
            self._rng.uniform(
                1.0 - self.config.size_variation,
                1.0 + self.config.size_variation,
            )
        )

        # Apply mood (H7)
        if self.config.mood_variance_enabled and "size" in self.config.mood_affects:
            variation *= self.state.mood_modifier

        # Loss reduction
        if self.state.consecutive_losses >= self.config.size_reduce_after_losses:
            variation *= 1.0 - self.config.size_loss_reduction

        # Warmup reduction
        if self.state.trades_today < self.state.warmup_trades_target:
            variation *= 1.0 - self.config.size_warmup_reduction

        return float(np.clip(variation, 0.5, 1.2))

    def _select_order_type(
        self,
        atr_percentile: float,
        current_time: datetime,
    ) -> Literal["MARKET", "LIMIT", "STOP_LIMIT"]:
        """Tier 4: Weighted order type with daily drift and volatility adaptation.

        A4 FIX: In high volatility, human traders use more market orders
        (want immediate fill, less confident in limits getting filled).
        """
        # Apply daily drift
        drift = float(
            self._rng.uniform(
                -self.config.order_type_daily_drift,
                self.config.order_type_daily_drift,
            )
        )

        market_pct = self.config.order_type_market_pct + drift
        limit_pct = self.config.order_type_limit_pct

        # A4 FIX: Volatility adaptation
        # High volatility = more market orders (human response to fast markets)
        if atr_percentile >= self.config.high_volatility_atr_percentile:
            # Shift 20% from limits to market orders in high vol
            volatility_shift = 0.20
            market_pct += volatility_shift
            limit_pct = max(0.10, limit_pct - volatility_shift)

        # A5 FIX: Day-of-week variance (Friday = more conservative = more market orders)
        # CRITICAL-1 FIX: Use current_time instead of datetime.now() for backtest correctness
        dt_et = current_time.astimezone(ET)
        weekday_name = dt_et.strftime("%A")
        if weekday_name == "Friday":
            # Friday close approaching = prefer immediate fills
            market_pct += 0.10
            limit_pct = max(0.10, limit_pct - 0.10)

        # Normalize to ensure probabilities sum to ~1.0
        total_pct = market_pct + limit_pct
        if total_pct > 0.95:
            # Leave some room for STOP_LIMIT
            market_pct = market_pct * 0.90 / total_pct
            limit_pct = limit_pct * 0.90 / total_pct

        roll = float(self._rng.random())
        if roll < market_pct:
            return "MARKET"
        elif roll < market_pct + limit_pct:
            return "LIMIT"
        else:
            return "STOP_LIMIT"

    def _is_trading_hours(self, dt: datetime) -> bool:
        """Tier 1: Check trading hours with proper timezone."""
        # Convert to ET
        dt_et = dt.astimezone(ET)

        hour = dt_et.hour
        weekday = dt_et.weekday()

        # Weekend
        if weekday >= 5:
            return False

        # Friday early close
        end_hour = self.config.trading_end_hour
        if weekday == 4:  # Friday
            end_hour = self.config.friday_early_end_hour

        return bool(self.config.trading_start_hour <= hour < end_hour)

    def _check_throttle(self, current_time: datetime) -> tuple[bool, float]:
        """Tier 4: Signal throttling (H4 fix)."""
        if not self.config.throttle_enabled:
            return False, 0.0

        # Check cooldown
        if self.state.last_trade_time:
            elapsed = (current_time - self.state.last_trade_time).total_seconds()
            if elapsed < self.config.throttle_cooldown_seconds:
                wait = self.config.throttle_cooldown_seconds - elapsed
                return True, wait

        # Check orders per minute
        if self.state.minute_start:
            if (current_time - self.state.minute_start).total_seconds() < 60:
                if self.state.orders_this_minute >= self.config.throttle_max_orders_per_minute:
                    wait = 60 - (current_time - self.state.minute_start).total_seconds()
                    return True, wait
            else:
                # New minute
                self.state.minute_start = current_time
                self.state.orders_this_minute = 0
        else:
            self.state.minute_start = current_time
            self.state.orders_this_minute = 0

        # Increment counter
        self.state.orders_this_minute += 1

        return False, 0.0

    def _in_micro_break(self, current_time: datetime) -> bool:
        """Tier 3: Check if in micro-break."""
        if not self.state.in_micro_break:
            return False

        if self.state.break_end_time and current_time >= self.state.break_end_time:
            self.state.in_micro_break = False
            self.state.break_end_time = None
            return False

        return True

    def _maybe_start_micro_break(self, current_time: datetime) -> None:
        """Tier 3: Maybe start a micro-break after trade.

        Args:
            current_time: Current timestamp for temporal correctness (HIGH-3 FIX).
        """
        if not self.config.micro_break_enabled:
            return

        # Probability per hour, but check after each trade
        # Approximate: if 3 trades/hour, each has 1/3 of hourly probability
        prob = self.config.micro_break_probability_per_hour / 3.0

        if self._rng.random() < prob:
            duration = int(
                self._rng.integers(
                    self.config.micro_break_duration_min_minutes,
                    self.config.micro_break_duration_max_minutes + 1,
                )
            )
            self.state.in_micro_break = True
            # HIGH-3 FIX: Use current_time instead of datetime.now()
            self.state.break_end_time = current_time + timedelta(minutes=duration)
            logger.info(f"Starting micro-break for {duration} minutes")

    # ==========================================================================
    # RNG MANAGEMENT (C1, H8 fixes)
    # ==========================================================================

    def _create_rng(self, initial_time: datetime | None = None) -> np.random.Generator:
        """Create RNG with proper seeding.

        R2-C-1 FIX: Accept initial_time parameter to avoid datetime.now() temporal violation.
        In backtest mode, this should be the simulated start time, not wall clock.

        Args:
            initial_time: The timestamp to use for seeding. If None and rng_seed_from_date
                         is True, uses a fixed epoch date for reproducibility.
        """
        if self.config.rng_seed_from_date:
            if initial_time is not None:
                seed = self._compute_seed(initial_time)
            else:
                # R2-C-1 FIX: Use fixed epoch date instead of datetime.now()
                # This ensures reproducible behavior when initial_time not provided
                # Live mode will call on_session_start() which reseeds properly
                epoch_date = datetime(2020, 1, 1, tzinfo=ET)
                seed = self._compute_seed(epoch_date)
        else:
            seed = None
        return np.random.default_rng(seed)

    def _compute_seed(self, dt: datetime) -> int:
        """Compute deterministic seed from date + account + session counter.

        H-NEW-3 FIX: Include session counter to prevent identical sequences
        if EA restarts mid-day. Each restart increments the counter.
        """
        # Include session counter to differentiate mid-day restarts
        seed_str = (
            f"{dt.date().isoformat()}_"
            f"{self.config.rng_seed_account_id}_"
            f"{self.config.rng_session_counter}"
        )
        hash_bytes = hashlib.sha256(seed_str.encode()).digest()
        return int.from_bytes(hash_bytes[:8], byteorder="big")

    def _reseed_for_date(self, dt: datetime) -> None:
        """Re-seed RNG for new session (H8 fix)."""
        seed = self._compute_seed(dt)
        self._rng = np.random.default_rng(seed)

    def _save_rng_state(self, current_time: datetime | None = None) -> None:
        """Persist RNG state and session counter to disk.

        N-3 FIX: Also persist session_counter so mid-day restarts get unique seeds.
        R2-C-2 FIX: Accept current_time parameter to avoid datetime.now() temporal violation.

        Args:
            current_time: The current timestamp (for backtest correctness).
                         If None, uses datetime.now(ET) (only safe in live mode).
        """
        if current_time is None:
            current_time = datetime.now(ET)
        elif current_time.tzinfo is None:
            current_time = _localize_et_strict(current_time)  # R13-FIX

        state_file = Path(self.config.rng_state_file)
        json_file = (
            state_file if state_file.suffix.lower() == ".json" else state_file.with_suffix(".json")
        )

        state_data: dict[str, Any] = {
            "rng_state": self._rng.bit_generator.state,
            "session_counter": int(self.config.rng_session_counter),
            "last_save_date": current_time.date().isoformat(),
        }

        try:
            if not self.config.rng_use_json_format:
                logger.warning(
                    "rng_use_json_format=False is ignored; pickle persistence is disabled (RCE risk)."
                )

            json_file.parent.mkdir(parents=True, exist_ok=True)

            if json_file.exists() and json_file.is_symlink():
                logger.warning("Refusing to write RNG state to symlink: %s", json_file)
                return

            with open(json_file, "w", encoding="utf-8") as f:
                try:
                    json.dump(state_data, f, ensure_ascii=True, sort_keys=True)
                except TypeError:
                    # Safety fallback: if the RNG state is not JSON serializable in some
                    # environments, persist at least the session counter.
                    json.dump(
                        {
                            "session_counter": state_data["session_counter"],
                            "last_save_date": state_data["last_save_date"],
                        },
                        f,
                        ensure_ascii=True,
                        sort_keys=True,
                    )
                f.write("\n")
        except Exception:
            logger.warning("Failed to save RNG state", exc_info=True)

    def _load_rng_state(self, current_time: datetime | None = None) -> None:
        """Load persisted RNG state and increment session counter.

        N-3 FIX: Increment session_counter on each load to ensure unique seeds
        even if EA restarts mid-day.
        R2-C-2 FIX: Accept current_time parameter to avoid datetime.now() temporal violation.

        Args:
            current_time: The current timestamp (for backtest correctness).
                         If None, uses datetime.now(ET) (only safe in live mode).
        """
        if current_time is None:
            current_time = datetime.now(ET)
        elif current_time.tzinfo is None:
            current_time = _localize_et_strict(current_time)  # R13-FIX

        today = current_time.date().isoformat()

        state_file = Path(self.config.rng_state_file)
        json_file = (
            state_file if state_file.suffix.lower() == ".json" else state_file.with_suffix(".json")
        )

        try:
            if not self.config.rng_use_json_format and (json_file.exists() or state_file.exists()):
                logger.warning(
                    "rng_use_json_format=False is ignored; pickle loading is disabled (RCE risk)."
                )

            if json_file.exists() and json_file.is_symlink():
                logger.warning("Refusing to read RNG state from symlink: %s", json_file)
                return

            if json_file.exists():
                with open(json_file, encoding="utf-8") as f:
                    data = json.load(f)

                if not isinstance(data, dict):
                    return

                # Restore RNG state if present.
                rng_state = data.get("rng_state")
                if isinstance(rng_state, dict):
                    self._rng.bit_generator.state = rng_state

                last_date = str(data.get("last_save_date", ""))

                raw_counter = data.get("session_counter", 0)
                counter = int(raw_counter) if isinstance(raw_counter, (int, str)) else 0

                if last_date == today:
                    # Same day restart - increment counter
                    self.config.rng_session_counter = counter + 1
                    logger.info(
                        f"Same-day restart detected, incrementing session_counter to "
                        f"{self.config.rng_session_counter}"
                    )
                else:
                    # New day - reset counter
                    self.config.rng_session_counter = 0
            elif state_file.exists():
                logger.warning(
                    "Ignoring legacy pickle RNG state file (RCE risk): %s",
                    state_file,
                )
        except Exception:
            logger.warning("Failed to load RNG state", exc_info=True)
            # Use fresh RNG if load fails

    # ==========================================================================
    # UTILITY METHODS
    # ==========================================================================

    def get_max_daily_pnl_allowed(self) -> float:
        """Get the maximum daily P&L allowed under 30% rule.

        C-NEW-3 FIX: Uses profit_target, NOT account equity.
        """
        if not self.config.apex_30pct_rule_enabled:
            return float("inf")
        return float(self.config.apex_profit_target) * 0.30

    def is_30pct_rule_hit(self) -> bool:
        """Check if daily P&L has hit 30% of profit target."""
        if not self.config.apex_30pct_rule_enabled:
            return False
        return self.state.daily_pnl >= self.get_max_daily_pnl_allowed()

    # ==========================================================================
    # HIGH-5/HIGH-8 FIX: APEX TIME GATES
    # ==========================================================================

    def is_new_trade_blocked(self, current_time: datetime) -> bool:
        """
        HIGH-5 FIX: Check if new trades are blocked (after 4:30 PM ET).

        Apex requires no new positions after 4:30 PM ET to ensure
        orderly close before 5:00 PM ET session end.
        """
        dt_et = current_time.astimezone(ET)
        block_time = dt_et.replace(
            hour=self.config.apex_new_trade_block_hour,
            minute=self.config.apex_new_trade_block_minute,
            second=0,
            microsecond=0,
        )
        return dt_et >= block_time

    def is_force_close_time(self, current_time: datetime) -> bool:
        """
        HIGH-8 FIX: Check if we're in force-close window (after 4:55 PM ET).

        At 4:55 PM ET, all positions MUST be closed immediately to avoid
        Apex overnight position violation (5:00 PM ET deadline).
        """
        dt_et = current_time.astimezone(ET)
        force_close_time = dt_et.replace(
            hour=self.config.apex_force_close_hour,
            minute=self.config.apex_force_close_minute,
            second=0,
            microsecond=0,
        )
        return dt_et >= force_close_time

    def get_time_gate_status(
        self,
        current_time: datetime,
    ) -> tuple[bool, bool, str | None]:
        """
        Get comprehensive time gate status for Apex compliance.

        Returns:
            Tuple of:
            - new_trades_allowed: Whether new trades can be opened
            - force_close_required: Whether all positions must close NOW
            - reason: Explanation string if blocked/forced
        """
        if self.is_force_close_time(current_time):
            return False, True, "apex_force_close_4:55PM"

        if self.is_new_trade_blocked(current_time):
            return False, False, "apex_new_trade_block_4:30PM"

        return True, False, None

    def get_state_summary(self) -> dict[str, int | float | bool]:
        """Get a summary of current HBS state for logging."""
        return {
            "trades_today": self.state.trades_today,
            "daily_pnl": self.state.daily_pnl,
            "cumulative_pnl": self.state.cumulative_pnl,
            "consecutive_losses": self.state.consecutive_losses,
            "consecutive_wins": self.state.consecutive_wins,
            "mood_modifier": self.state.mood_modifier,
            "is_sick_day": self.state.is_sick_day,
            "in_micro_break": self.state.in_micro_break,
            "session_counter": self.config.rng_session_counter,
        }

    # ==========================================================================
    # CRITICAL-2 FIX: ORDER CANCELLATION
    # ==========================================================================

    def should_cancel_pending_order(
        self,
        order_id: str,
        order_type: str,
        is_filled: bool,
        seconds_pending: float = 0.0,
        price_moved_ticks: int = 0,
    ) -> tuple[bool, str | None]:
        """
        CRITICAL-2 FIX: Determine if a pending order should be cancelled.

        Human traders don't always let limit orders fill - they cancel ~9% of the time.
        This method implements probabilistic cancellation for human-like behavior.

        Args:
            order_id: Unique order identifier (for logging)
            order_type: "LIMIT", "STOP_LIMIT", or "MARKET"
            is_filled: Whether the order has already filled
            seconds_pending: How long the order has been pending
            price_moved_ticks: How many ticks price has moved since order was placed

        Returns:
            Tuple of (should_cancel, reason) where reason is:
            - "random_cancel": Probabilistic cancellation (cancel_rate)
            - "price_moved": Price moved too far away
            - "timeout": Order pending too long
            - None if should not cancel
        """
        # Only cancel pending (unfilled) orders
        if is_filled:
            return False, None

        # Only cancel limit-type orders if configured
        if self.config.cancel_only_pending and order_type == "MARKET":
            return False, None

        # Check price movement cancellation (deterministic)
        if price_moved_ticks >= 5:  # Default from HBSDecision
            logger.debug(
                f"Order {order_id}: price moved {price_moved_ticks} ticks, recommending cancel"
            )
            return True, "price_moved"

        # Check timeout cancellation (deterministic)
        if seconds_pending >= 30.0:  # Default from HBSDecision
            logger.debug(
                f"Order {order_id}: pending {seconds_pending:.1f}s > 30s, recommending cancel"
            )
            return True, "timeout"

        # Roll probabilistic cancellation based on cancel_rate
        # This simulates human indecision / changing their mind
        if self._rng.random() < self.config.cancel_rate:
            logger.debug(f"Order {order_id}: random cancel rolled (rate={self.config.cancel_rate})")
            return True, "random_cancel"

        return False, None
