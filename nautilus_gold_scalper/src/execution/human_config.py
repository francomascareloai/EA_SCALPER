"""
Human Behavior Simulator Configuration v2.2
============================================
Configuration dataclass for HBS with all 26 parameters validated against
industry research on human trading patterns.

Incorporates all CRITIC/ARGUS fixes:
- C-NEW-1: Account ID validation for RNG seeding
- C-NEW-3: Profit target validation for 30% rule
- H-NEW-3: Session counter for mid-day restart differentiation
- A1: Parameter jitter for multivariate AI defense
- A5: Day-of-week behavioral variance
"""

from dataclasses import dataclass, field
from pathlib import Path
from typing import Literal
from zoneinfo import ZoneInfo

import yaml

ET = ZoneInfo("America/New_York")


@dataclass
class HumanSimConfig:
    """
    Configuration for Human Behavior Simulator.

    All parameters validated against industry research on human trading patterns.
    See: ARGUS Research Report for parameter justifications.
    """

    # === MODE ===
    mode: Literal["backtest", "live", "paper"] = "backtest"
    enabled: bool = True

    # === TIER 1: LATENCY (FIXED - H1, H5) ===
    # Mixture model: 80% Gaussian + 20% long-tail for anti-detection
    delay_gaussian_weight: float = 0.80  # 80% of delays from Gaussian
    delay_longtail_weight: float = 0.20  # 20% from log-normal (long-tail)
    delay_mean: float = 1.0  # Center of Gaussian component
    delay_std: float = 0.45  # FIXED: Was 0.3, now 0.45 for CV > 0.35
    delay_min: float = 0.6  # FIXED: Was 0.5, now 0.6 (sub-600ms = bot)
    delay_max: float = 3.5  # FIXED: Was 2.5, now 3.5 for long-tail
    delay_longtail_mu: float = 0.5  # Log-normal mu for long-tail
    delay_longtail_sigma: float = 0.8  # Log-normal sigma
    delay_fatigue_curve: Literal["linear", "logistic"] = "logistic"  # FIXED: Was linear
    delay_fatigue_max: float = 0.30  # Max fatigue increase (30%)
    delay_fatigue_midpoint_hours: float = 3.0  # Logistic midpoint

    # === TIER 1: ENTRY PRECISION ===
    entry_offset_ticks_max: int = 3  # Random offset 0 to N ticks
    stop_limit_offset_ticks: int = 5  # Ticks above/below market for STOP_LIMIT

    # === TIER 1: ORDER CANCELLATION ===
    cancel_rate: float = 0.09  # FIXED: Was 0.06, now 0.09 (research: 8-12%)
    cancel_only_pending: bool = True

    # === TIER 1: TRADING HOURS (ET) ===
    trading_start_hour: int = 9
    trading_end_hour: int = 17
    friday_early_end_hour: int = 14
    timezone: str = "America/New_York"  # Explicit timezone (FIXED: H3)

    # === TIER 1: APEX TIME GATES (HIGH-5/HIGH-8) ===
    # These are NON-NEGOTIABLE Apex Trader requirements
    apex_new_trade_block_hour: int = 16  # 4:00 PM ET - block new trades
    apex_new_trade_block_minute: int = 30  # 4:30 PM ET (16:30)
    apex_force_close_hour: int = 16  # 4:00 PM ET
    apex_force_close_minute: int = 55  # 4:55 PM ET - emergency close all
    apex_session_end_hour: int = 17  # 5:00 PM ET - absolute deadline

    # === TIER 1: ECONOMIC CALENDAR (C5) ===
    news_events_enabled: bool = True
    news_high_impact_delay_mult: float = 2.5  # NFP, FOMC, etc.
    news_medium_impact_delay_mult: float = 1.5
    news_pre_event_block_minutes: int = 5  # Block trades 5min before
    news_post_event_delay_minutes: int = 10  # Extended delay after
    news_calendar_source: str = "forexfactory"  # or "investing.com"

    # === TIER 2: SIGNAL SKIP (FIXED - H6) ===
    skip_enabled: bool = True
    skip_base_rate: float = 0.13  # FIXED: Was 0.10, now 0.13 (research: 12-15%)
    skip_after_loss_increase: float = 0.05
    skip_weak_threshold: float = 0.75

    # === TIER 2: SIZE VARIATION ===
    size_variation: float = 0.18  # FIXED: Was 0.15, now 0.18 for CV > 0.15
    size_reduce_after_losses: int = 2
    size_loss_reduction: float = 0.20
    size_warmup_reduction: float = 0.30
    size_warmup_trades_min: int = 1  # FIXED: Variable warmup (1-3)
    size_warmup_trades_max: int = 3

    # === TIER 2: SL ADJUSTMENTS ===
    move_to_be_at_r: float = 1.0
    trail_start_at_r: float = 1.5
    trail_distance_r: float = 0.5

    # === TIER 3: BIG WIN PAUSE ===
    pause_after_big_win: bool = True
    big_win_threshold: float = 0.02
    big_win_pause_probability: float = 0.55  # FIXED: Was 0.40, now 0.55

    # === TIER 3: DAY OFF ===
    sick_day_rate: float = 0.035  # ~1 day/month
    sick_day_monday_reduction: float = 0.50  # 50% less likely on Monday

    # === TIER 3: SESSION MOOD (H7) ===
    mood_variance_enabled: bool = True
    mood_daily_modifier_min: float = 0.80  # 80-120% of base rates
    mood_daily_modifier_max: float = 1.20
    mood_affects: list[str] = field(default_factory=lambda: ["skip", "delay", "size"])

    # === TIER 3: MICRO-BREAKS ===
    micro_break_enabled: bool = True
    micro_break_probability_per_hour: float = 0.05  # 5% per hour
    micro_break_duration_min_minutes: int = 5
    micro_break_duration_max_minutes: int = 15

    # === TIER 4: VOLATILITY ===
    high_volatility_atr_percentile: int = 90  # FIXED: Was ratio, now percentile
    high_volatility_delay_multiple: float = 2.0
    high_volatility_skip_increase: float = 0.15

    # === TIER 4: ORDER TYPE MIX ===
    order_type_market_pct: float = 0.70
    order_type_limit_pct: float = 0.25
    order_type_stop_limit_pct: float = 0.05
    order_type_daily_drift: float = 0.03  # ±3% daily variance

    # === TIER 4: SIGNAL THROTTLE (H4) ===
    throttle_enabled: bool = True
    throttle_max_orders_per_minute: int = 3  # Max 3 orders/minute
    throttle_cooldown_seconds: float = 20.0  # Min 20s between orders
    throttle_exponential_backoff: bool = True  # Exponential if exceeded

    # === TIER 4: ERROR RETRY ===
    retry_delays: list[float] = field(default_factory=lambda: [2.0, 5.0, 10.0])

    # === RNG MANAGEMENT (C1, H8, C-NEW-1, H-NEW-3) ===
    rng_seed_from_date: bool = True  # Derive seed from date+account
    rng_seed_account_id: str = ""  # Account ID for seed (REQUIRED if rng_seed_from_date=True)
    rng_persist_state: bool = True  # Persist state across restarts
    rng_state_file: str = ".hbs_rng_state.json"
    rng_session_counter: int = 0  # Increment on each restart (H-NEW-3)
    rng_use_json_format: bool = True  # Use JSON instead of pickle for security

    # === APEX COMPLIANCE (H2, C-NEW-3) ===
    apex_30pct_rule_enabled: bool = True
    apex_track_cumulative_pnl: bool = True
    apex_profit_target: float = 0.0  # C-NEW-3: Must be set! 30% calculated from THIS, not equity

    # === CRISIS MODE (H-NEW-6) ===
    crisis_mode_enabled: bool = True
    crisis_dd_threshold: float = 0.035  # DD > 3.5% triggers crisis mode
    crisis_delay_reduction: float = 0.50  # Reduce delays by 50% in crisis
    crisis_skip_disabled: bool = True  # Disable skips in crisis (execute ASAP)

    # === PARAMETER JITTER (A1) ===
    jitter_enabled: bool = True
    jitter_range: float = 0.10  # ±10% randomization per account

    # === DAY-OF-WEEK VARIANCE (A5) ===
    weekday_modifiers: dict[str, float] = field(
        default_factory=lambda: {
            "Monday": 0.85,  # Less aggressive start of week
            "Tuesday": 1.0,
            "Wednesday": 1.0,
            "Thursday": 1.05,  # Slightly more aggressive
            "Friday": 0.90,  # Conservative before weekend
        }
    )

    @classmethod
    def from_yaml(cls, path: Path) -> "HumanSimConfig":
        """Load config from YAML file with validation."""
        with open(path, encoding="utf-8") as f:
            data = yaml.safe_load(f)
        if not isinstance(data, dict):
            raise ValueError(
                f"HumanSimConfig YAML root must be a mapping, got {type(data).__name__}"
            )
        config = cls(**data)
        config.validate()
        return config

    def validate(self) -> None:
        """Validate all parameters are within acceptable ranges."""
        # R12-FIX: Replace assert with explicit validation (assert disabled with -O).
        # Basic parameter validation
        if not (0.5 <= self.delay_mean <= 2.0):
            raise ValueError(f"delay_mean should be 0.5-2.0s, got {self.delay_mean}")
        if not (0.3 <= self.delay_std <= 0.8):
            raise ValueError(f"delay_std should be 0.3-0.8s, got {self.delay_std}")
        if self.delay_min < 0.5:
            raise ValueError(f"delay_min must be >= 0.5s (anti-bot), got {self.delay_min}")
        if not (0.0 <= self.skip_base_rate <= 0.30):
            raise ValueError(f"skip_base_rate should be 0-30%, got {self.skip_base_rate}")
        if not (0.10 <= self.size_variation <= 0.25):
            raise ValueError(f"size_variation should be 10-25%, got {self.size_variation}")
        if abs(self.delay_gaussian_weight + self.delay_longtail_weight - 1.0) >= 0.01:
            raise ValueError(
                f"delay weights must sum to 1.0, got gaussian={self.delay_gaussian_weight} + "
                f"longtail={self.delay_longtail_weight} = "
                f"{self.delay_gaussian_weight + self.delay_longtail_weight}"
            )
        if self.throttle_max_orders_per_minute < 1:
            raise ValueError(
                f"throttle_max_orders_per_minute must be >= 1, got {self.throttle_max_orders_per_minute}"
            )

        # C-NEW-1: Account ID REQUIRED when using date-based seeding
        if self.rng_seed_from_date and not self.rng_seed_account_id:
            raise ValueError(
                "rng_seed_account_id is REQUIRED when rng_seed_from_date=True. "
                "Without it, all accounts produce identical RNG sequences!"
            )

        # C-NEW-3: Profit target REQUIRED for 30% rule
        if self.apex_30pct_rule_enabled and self.apex_profit_target <= 0:
            raise ValueError(
                "apex_profit_target must be set when apex_30pct_rule_enabled=True. "
                "30% rule is calculated from PROFIT TARGET, not account equity! "
                "Example: For $50k account with 8% target, set apex_profit_target=4000.0"
            )

        # Crisis mode validation
        if self.crisis_mode_enabled:
            # R12-FIX: Replace assert with explicit validation (assert disabled with -O).
            if not (0.02 <= self.crisis_dd_threshold <= 0.045):
                raise ValueError(
                    f"crisis_dd_threshold should be 2-4.5%, got {self.crisis_dd_threshold}"
                )


# === FACTORY FUNCTIONS ===
def get_default_config(account_id: str, profit_target: float) -> HumanSimConfig:
    """Production-ready config with all ARGUS/CRITIC fixes.

    Args:
        account_id: Unique identifier for the trading account (required for RNG)
        profit_target: Account profit target in dollars (required for 30% rule)
    """
    return HumanSimConfig(
        rng_seed_account_id=account_id,
        apex_profit_target=profit_target,
    )


def get_aggressive_config(account_id: str, profit_target: float) -> HumanSimConfig:
    """Less humanization, more trades (higher detection risk)."""
    return HumanSimConfig(
        rng_seed_account_id=account_id,
        apex_profit_target=profit_target,
        skip_base_rate=0.08,
        delay_mean=0.8,
        size_variation=0.10,
        micro_break_enabled=False,
    )


def get_conservative_config(account_id: str, profit_target: float) -> HumanSimConfig:
    """Maximum humanization, fewer trades (lowest detection risk)."""
    return HumanSimConfig(
        rng_seed_account_id=account_id,
        apex_profit_target=profit_target,
        skip_base_rate=0.20,
        delay_mean=1.5,
        delay_std=0.6,
        size_variation=0.22,
        micro_break_probability_per_hour=0.08,
    )


def get_evaluation_config(account_id: str, profit_target: float) -> HumanSimConfig:
    """Config optimized for Apex Evaluation phase."""
    return HumanSimConfig(
        rng_seed_account_id=account_id,
        apex_profit_target=profit_target,
        skip_base_rate=0.10,  # Slightly aggressive to hit targets
        big_win_pause_probability=0.70,  # More conservative after wins
        apex_30pct_rule_enabled=True,
    )


def get_backtest_config() -> HumanSimConfig:
    """Config for backtesting - relaxed validation for testing purposes."""
    return HumanSimConfig(
        enabled=False,  # DISABLE HBS for backtesting - allows pure strategy evaluation
        rng_seed_from_date=False,  # Use random seed for backtests
        rng_seed_account_id="backtest",
        apex_30pct_rule_enabled=False,  # Don't need profit target for backtests
        apex_profit_target=0.0,
        mode="backtest",
    )
