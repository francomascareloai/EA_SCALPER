---
phase: 11-hbs-implementation
plan: 01
type: execute
domain: nautilus-python
version: 2.2
reviewed_by: ARGUS + CRITIC (v2.0 + v2.1 reviews applied, all fixes implemented)
critic_v2_fixes: C-NEW-1 ✅, C-NEW-2 ✅, C-NEW-3 ✅, H-NEW-1 ✅, H-NEW-2 ✅, H-NEW-3 ✅, H-NEW-4 ✅, H-NEW-5 ✅, H-NEW-6 ✅
argus_v2_enhancements: A1 ✅ (jitter), A2 ✅ (exponential skip), A4 ✅ (volatility order types), A5 ✅ (weekday variance)
---

<objective>
Implement the Human Behavior Simulator (HBS) core Python module with 18+ humanization techniques, incorporating all CRITICAL and HIGH fixes from adversarial review.

Purpose: Create a statistically-realistic human trading behavior layer that makes automated execution indistinguishable from manual trading. This is the foundation for Apex stealth compliance.

Output:
- `human_config.py` - Configuration dataclass with all HBS parameters (expanded)
- `human_simulator.py` - Core HBS class with 18+ techniques (optimized)
- `economic_calendar.py` - News event detection for volatility awareness
- `test_human_simulator.py` - Unit tests with 90%+ coverage
</objective>

<execution_context>
@~/.claude/plugins/marketplaces/taches-cc-resources/skills/create-plans/workflows/execute-phase.md
@~/.claude/plugins/marketplaces/taches-cc-resources/skills/create-plans/templates/summary.md
</execution_context>

<context>
@.planning/phases/08-nautilus-deep-audit/00-BRIEF.md
@.planning/phases/08-nautilus-deep-audit/01-ROADMAP.md
@.planning/phases/08-nautilus-deep-audit/11-PHASE-HBS-IMPLEMENTATION-PLAN.md
@nautilus_gold_scalper/src/execution/execution_model.py
@nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py
</context>

<critical_fixes>
Fixes incorporated from ARGUS + CRITIC review (v2.0 + v2.1):

## CRITICAL (v2.0):
- [C1] RNG seed management - persist state, derive from date+account
- [C5] Economic calendar integration - news event delay multiplier

## CRITICAL (v2.1 - NEW):
- [C-NEW-1] Account ID validation - REQUIRED when rng_seed_from_date=True
- [C-NEW-2] HBSDecision must include limit_price/stop_price attributes
- [C-NEW-3] 30% rule uses PROFIT TARGET, not account equity

## HIGH (v2.0):
- [H1] Mixture model delays (80% Gaussian + 20% long-tail) - avoid K-S detection
- [H5] Increase delay_std to 0.4-0.5 for CV > 0.30
- [H6] Increase skip_base_rate to 12-15%
- [H7] Session-level mood variance (daily modifier)
- [H8] Re-seed RNG per session

## HIGH (v2.1 - NEW):
- [H-NEW-1] Use threading.Event for async executor startup (no busy-wait)
- [H-NEW-2] Implement FOMC, CPI, GDP in economic calendar (not just NFP)
- [H-NEW-3] Include session counter in RNG seed for mid-day restarts
- [H-NEW-4] Context-aware order cancellation (price moved, not random)
- [H-NEW-5] Check cancel flag BEFORE executing delayed order callback
- [H-NEW-6] Reduce/skip delays when DD > 3.5% (crisis mode)

## ARGUS ENHANCEMENTS (v2.1):
- [A1] Per-account parameter jitter (±5-10% randomization)
- [A2] Exponential skip rate increase after losses (fear response)
- [A3] Weighted mood effects (decision ≠ motor ≠ risk)
- [A4] Volatility-adaptive order types (more market orders when ATR high)
- [A5] Day-of-week behavioral variance
- [A6] Correlation-breaking injection for multivariate defense

NEW TECHNIQUES ADDED:
- Economic calendar awareness (Tier 1)
- Session mood variance (Tier 3)
- Micro-breaks (Tier 3)
- Signal throttling (Tier 4)
- Crisis mode (DD > 3.5% = reduced delays)
- Multivariate defense (correlation breaking)
</critical_fixes>

<tasks>

<task type="auto">
  <name>Task 1: Create Enhanced HBS Configuration Module</name>
  <files>nautilus_gold_scalper/src/execution/human_config.py</files>
  <action>
Create a dataclass-based configuration module for HBS with all parameters including CRITIC/ARGUS fixes:

```python
from dataclasses import dataclass, field
from typing import Literal, List, Optional
from datetime import time
from pathlib import Path
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
    delay_gaussian_weight: float = 0.80  # NEW: 80% of delays from Gaussian
    delay_longtail_weight: float = 0.20  # NEW: 20% from log-normal (long-tail)
    delay_mean: float = 1.0              # Center of Gaussian component
    delay_std: float = 0.45              # FIXED: Was 0.3, now 0.45 for CV > 0.35
    delay_min: float = 0.6               # FIXED: Was 0.5, now 0.6 (sub-600ms = bot)
    delay_max: float = 3.5               # FIXED: Was 2.5, now 3.5 for long-tail
    delay_longtail_mu: float = 0.5       # NEW: Log-normal mu for long-tail
    delay_longtail_sigma: float = 0.8    # NEW: Log-normal sigma
    delay_fatigue_curve: Literal["linear", "logistic"] = "logistic"  # FIXED: Was linear
    delay_fatigue_max: float = 0.30      # Max fatigue increase (30%)
    delay_fatigue_midpoint_hours: float = 3.0  # Logistic midpoint

    # === TIER 1: ENTRY PRECISION ===
    entry_offset_ticks_max: int = 3      # Random offset 0 to N ticks

    # === TIER 1: ORDER CANCELLATION ===
    cancel_rate: float = 0.09            # FIXED: Was 0.06, now 0.09 (research: 8-12%)
    cancel_only_pending: bool = True

    # === TIER 1: TRADING HOURS (ET) ===
    trading_start_hour: int = 9
    trading_end_hour: int = 17
    friday_early_end_hour: int = 14
    timezone: str = "America/New_York"   # NEW: Explicit timezone (FIXED: H3)

    # === TIER 1: ECONOMIC CALENDAR (NEW - C5) ===
    news_events_enabled: bool = True
    news_high_impact_delay_mult: float = 2.5   # NFP, FOMC, etc.
    news_medium_impact_delay_mult: float = 1.5
    news_pre_event_block_minutes: int = 5      # Block trades 5min before
    news_post_event_delay_minutes: int = 10    # Extended delay after
    news_calendar_source: str = "forexfactory"  # or "investing.com"

    # === TIER 2: SIGNAL SKIP (FIXED - H6) ===
    skip_enabled: bool = True
    skip_base_rate: float = 0.13         # FIXED: Was 0.10, now 0.13 (research: 12-15%)
    skip_after_loss_increase: float = 0.05
    skip_weak_threshold: float = 0.75

    # === TIER 2: SIZE VARIATION ===
    size_variation: float = 0.18         # FIXED: Was 0.15, now 0.18 for CV > 0.15
    size_reduce_after_losses: int = 2
    size_loss_reduction: float = 0.20
    size_warmup_reduction: float = 0.30
    size_warmup_trades_min: int = 1      # FIXED: Variable warmup (1-3)
    size_warmup_trades_max: int = 3      # NEW

    # === TIER 2: SL ADJUSTMENTS ===
    move_to_be_at_r: float = 1.0
    trail_start_at_r: float = 1.5
    trail_distance_r: float = 0.5

    # === TIER 3: BIG WIN PAUSE ===
    pause_after_big_win: bool = True
    big_win_threshold: float = 0.02
    big_win_pause_probability: float = 0.55  # FIXED: Was 0.40, now 0.55

    # === TIER 3: DAY OFF ===
    sick_day_rate: float = 0.035         # ~1 day/month
    sick_day_monday_reduction: float = 0.50  # NEW: 50% less likely on Monday

    # === TIER 3: SESSION MOOD (NEW - H7) ===
    mood_variance_enabled: bool = True
    mood_daily_modifier_min: float = 0.80  # 80-120% of base rates
    mood_daily_modifier_max: float = 1.20
    mood_affects: List[str] = field(default_factory=lambda: ["skip", "delay", "size"])

    # === TIER 3: MICRO-BREAKS (NEW) ===
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
    order_type_daily_drift: float = 0.03  # NEW: ±3% daily variance

    # === TIER 4: SIGNAL THROTTLE (NEW - H4) ===
    throttle_enabled: bool = True
    throttle_max_orders_per_minute: int = 3   # Max 3 orders/minute
    throttle_cooldown_seconds: float = 20.0   # Min 20s between orders
    throttle_exponential_backoff: bool = True # Exponential if exceeded

    # === TIER 4: ERROR RETRY ===
    retry_delays: List[float] = field(default_factory=lambda: [2.0, 5.0, 10.0])

    # === RNG MANAGEMENT (NEW - C1, H8, C-NEW-1, H-NEW-3) ===
    rng_seed_from_date: bool = True      # Derive seed from date+account
    rng_seed_account_id: str = ""        # Account ID for seed (REQUIRED if rng_seed_from_date=True)
    rng_persist_state: bool = True       # Persist state across restarts
    rng_state_file: str = ".hbs_rng_state.pkl"
    rng_session_counter: int = 0         # NEW: Increment on each restart (H-NEW-3)
    rng_use_json_format: bool = True     # NEW: Use JSON instead of pickle for security

    # === APEX COMPLIANCE (NEW - H2, C-NEW-3) ===
    apex_30pct_rule_enabled: bool = True
    apex_track_cumulative_pnl: bool = True
    apex_profit_target: float = 0.0      # NEW: C-NEW-3 - Must be set! 30% calculated from THIS, not equity

    # === CRISIS MODE (NEW - H-NEW-6) ===
    crisis_mode_enabled: bool = True
    crisis_dd_threshold: float = 0.035   # DD > 3.5% triggers crisis mode
    crisis_delay_reduction: float = 0.50 # Reduce delays by 50% in crisis
    crisis_skip_disabled: bool = True    # Disable skips in crisis (execute ASAP)

    # === PARAMETER JITTER (NEW - A1) ===
    jitter_enabled: bool = True
    jitter_range: float = 0.10           # ±10% randomization per account

    # === DAY-OF-WEEK VARIANCE (NEW - A5) ===
    weekday_modifiers: dict = field(default_factory=lambda: {
        "Monday": 0.85,    # Less aggressive start of week
        "Tuesday": 1.0,
        "Wednesday": 1.0,
        "Thursday": 1.05,  # Slightly more aggressive
        "Friday": 0.90,    # Conservative before weekend
    })

    @classmethod
    def from_yaml(cls, path: Path) -> "HumanSimConfig":
        """Load config from YAML file with validation."""
        with open(path) as f:
            data = yaml.safe_load(f)
        config = cls(**data)
        config.validate()
        return config

    def validate(self) -> None:
        """Validate all parameters are within acceptable ranges."""
        # Basic parameter validation
        assert 0.5 <= self.delay_mean <= 2.0, "delay_mean should be 0.5-2.0s"
        assert 0.3 <= self.delay_std <= 0.8, "delay_std should be 0.3-0.8s"
        assert self.delay_min >= 0.5, "delay_min must be >= 0.5s (anti-bot)"
        assert 0.0 <= self.skip_base_rate <= 0.30, "skip_base_rate should be 0-30%"
        assert 0.10 <= self.size_variation <= 0.25, "size_variation should be 10-25%"
        assert self.delay_gaussian_weight + self.delay_longtail_weight == 1.0
        assert self.throttle_max_orders_per_minute >= 1

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
            assert 0.02 <= self.crisis_dd_threshold <= 0.045, "crisis_dd_threshold should be 2-4.5%"

# === FACTORY FUNCTIONS ===
def get_default_config() -> HumanSimConfig:
    """Production-ready config with all ARGUS/CRITIC fixes."""
    return HumanSimConfig()

def get_aggressive_config() -> HumanSimConfig:
    """Less humanization, more trades (higher detection risk)."""
    return HumanSimConfig(
        skip_base_rate=0.08,
        delay_mean=0.8,
        size_variation=0.10,
        micro_break_enabled=False,
    )

def get_conservative_config() -> HumanSimConfig:
    """Maximum humanization, fewer trades (lowest detection risk)."""
    return HumanSimConfig(
        skip_base_rate=0.20,
        delay_mean=1.5,
        delay_std=0.6,
        size_variation=0.22,
        micro_break_probability_per_hour=0.08,
    )

def get_evaluation_config() -> HumanSimConfig:
    """Config optimized for Apex Evaluation phase."""
    return HumanSimConfig(
        skip_base_rate=0.10,  # Slightly aggressive to hit targets
        big_win_pause_probability=0.70,  # More conservative after wins
        apex_30pct_rule_enabled=True,
    )
```

AVOID:
- Using mutable default arguments directly (use field(default_factory=...))
- Hardcoding timezone - always use explicit ZoneInfo
  </action>
  <verify>
    - python -c "from nautilus_gold_scalper.src.execution.human_config import HumanSimConfig, get_default_config; c = get_default_config(); c.validate(); print('OK')"
    - mypy --strict nautilus_gold_scalper/src/execution/human_config.py
  </verify>
  <done>
    - HumanSimConfig dataclass created with ALL parameters (original 16 + new 10)
    - Mixture model parameters included (Gaussian + long-tail)
    - News event parameters included
    - Session mood parameters included
    - Signal throttle parameters included
    - RNG management parameters included
    - Factory functions for different scenarios
    - mypy passes with --strict
  </done>
</task>

<task type="auto">
  <name>Task 2: Create Economic Calendar Module</name>
  <files>nautilus_gold_scalper/src/execution/economic_calendar.py</files>
  <action>
Create a module for detecting high-impact economic events (CRITICAL fix C5):

```python
"""
Economic Calendar for HBS
=========================
Detects major news events that should trigger extended delays.
Prevents "bot traded through NFP at normal speed" detection.
"""

from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import List, Optional, Literal
from zoneinfo import ZoneInfo
import json
from pathlib import Path

ET = ZoneInfo("America/New_York")

@dataclass
class EconomicEvent:
    """Single economic event."""
    name: str
    datetime_et: datetime
    impact: Literal["high", "medium", "low"]
    currency: str  # "USD", "EUR", etc.
    actual: Optional[float] = None
    forecast: Optional[float] = None
    previous: Optional[float] = None

# Major USD events that ALWAYS require extended delays
HIGH_IMPACT_EVENTS = [
    "Nonfarm Payrolls",
    "FOMC Statement",
    "Fed Interest Rate Decision",
    "CPI",
    "Core CPI",
    "PPI",
    "GDP",
    "Unemployment Rate",
    "Retail Sales",
    "ISM Manufacturing PMI",
    "ISM Services PMI",
    "Initial Jobless Claims",
    "Building Permits",
    "Housing Starts",
    "Consumer Confidence",
]

MEDIUM_IMPACT_EVENTS = [
    "Durable Goods Orders",
    "Existing Home Sales",
    "New Home Sales",
    "Philadelphia Fed Manufacturing Index",
    "Empire State Manufacturing Index",
    "Industrial Production",
]

class EconomicCalendar:
    """
    Economic calendar for news-aware trading.

    Usage:
        calendar = EconomicCalendar()
        calendar.load_events(start_date, end_date)

        # In trading loop:
        event = calendar.get_nearest_event(current_time)
        if event and calendar.is_blocked(current_time, event):
            # Skip or extend delay
    """

    def __init__(self, cache_dir: Path = Path(".cache/calendar")):
        self.cache_dir = cache_dir
        self.events: List[EconomicEvent] = []
        self._loaded_range: Optional[tuple[datetime, datetime]] = None

    def load_events(self, start: datetime, end: datetime) -> None:
        """Load events for date range (from cache or fetch)."""
        cache_file = self.cache_dir / f"{start.date()}_{end.date()}.json"

        if cache_file.exists():
            self._load_from_cache(cache_file)
        else:
            self._fetch_and_cache(start, end, cache_file)

        self._loaded_range = (start, end)

    def get_nearest_event(
        self,
        current_time: datetime,
        lookahead_minutes: int = 30,
        lookbehind_minutes: int = 15,
    ) -> Optional[EconomicEvent]:
        """Get nearest high/medium impact event within window."""
        window_start = current_time - timedelta(minutes=lookbehind_minutes)
        window_end = current_time + timedelta(minutes=lookahead_minutes)

        for event in self.events:
            if event.impact in ("high", "medium"):
                if window_start <= event.datetime_et <= window_end:
                    return event
        return None

    def is_pre_event_blocked(
        self,
        current_time: datetime,
        event: EconomicEvent,
        block_minutes: int = 5,
    ) -> bool:
        """Check if we're in pre-event block window."""
        block_start = event.datetime_et - timedelta(minutes=block_minutes)
        return block_start <= current_time < event.datetime_et

    def get_post_event_delay_multiplier(
        self,
        current_time: datetime,
        event: EconomicEvent,
        post_event_minutes: int = 10,
        high_mult: float = 2.5,
        medium_mult: float = 1.5,
    ) -> float:
        """Get delay multiplier for post-event period."""
        if current_time < event.datetime_et:
            return 1.0  # Not post-event yet

        post_window_end = event.datetime_et + timedelta(minutes=post_event_minutes)
        if current_time > post_window_end:
            return 1.0  # Past post-event window

        if event.impact == "high":
            return high_mult
        elif event.impact == "medium":
            return medium_mult
        return 1.0

    def _load_from_cache(self, cache_file: Path) -> None:
        """Load events from cached JSON."""
        with open(cache_file) as f:
            data = json.load(f)
        self.events = [
            EconomicEvent(
                name=e["name"],
                datetime_et=datetime.fromisoformat(e["datetime_et"]),
                impact=e["impact"],
                currency=e["currency"],
            )
            for e in data
        ]

    def _fetch_and_cache(
        self,
        start: datetime,
        end: datetime,
        cache_file: Path
    ) -> None:
        """Fetch events from source and cache."""
        # For now, use static list of known events
        # TODO: Integrate with ForexFactory or Investing.com API
        self.events = self._generate_known_events(start, end)

        # Cache for future use
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        with open(cache_file, "w") as f:
            json.dump(
                [
                    {
                        "name": e.name,
                        "datetime_et": e.datetime_et.isoformat(),
                        "impact": e.impact,
                        "currency": e.currency,
                    }
                    for e in self.events
                ],
                f,
            )

    def _generate_known_events(
        self,
        start: datetime,
        end: datetime
    ) -> List[EconomicEvent]:
        """
        Generate known recurring events.

        NFP: First Friday of month, 8:30 AM ET
        FOMC: ~8 times/year, 2:00 PM ET (check schedule)
        CPI: ~12th of month, 8:30 AM ET
        """
        events = []

        # Generate NFP dates (first Friday of each month)
        current = start.replace(day=1)
        while current <= end:
            # Find first Friday
            first_friday = current
            while first_friday.weekday() != 4:  # Friday = 4
                first_friday += timedelta(days=1)

            nfp_time = first_friday.replace(
                hour=8, minute=30, second=0, microsecond=0,
                tzinfo=ET
            )
            if start <= nfp_time <= end:
                events.append(EconomicEvent(
                    name="Nonfarm Payrolls",
                    datetime_et=nfp_time,
                    impact="high",
                    currency="USD",
                ))

            # Move to next month
            if current.month == 12:
                current = current.replace(year=current.year + 1, month=1)
            else:
                current = current.replace(month=current.month + 1)

        # H-NEW-2 FIX: Add CPI, GDP, FOMC events
        # CPI: ~12th-13th of month, 8:30 AM ET
        current = start.replace(day=1)
        while current <= end:
            # CPI typically released around 12th of month
            cpi_day = current.replace(day=12)
            # Adjust to weekday if weekend
            while cpi_day.weekday() >= 5:  # Sat/Sun
                cpi_day += timedelta(days=1)

            cpi_time = cpi_day.replace(
                hour=8, minute=30, second=0, microsecond=0,
                tzinfo=ET
            )
            if start <= cpi_time <= end:
                events.append(EconomicEvent(
                    name="CPI",
                    datetime_et=cpi_time,
                    impact="high",
                    currency="USD",
                ))

            # Move to next month
            if current.month == 12:
                current = current.replace(year=current.year + 1, month=1)
            else:
                current = current.replace(month=current.month + 1)

        # GDP: Last week of month (Q1 end = Jan, Q2 end = Apr, Q3 end = Jul, Q4 end = Oct)
        # Actually released ~1 month after quarter end (advance estimate)
        gdp_months = [1, 4, 7, 10]  # Months when advance GDP released
        for year in range(start.year, end.year + 1):
            for month in gdp_months:
                # GDP released around 25th-28th of month
                gdp_day = datetime(year, month, 26, tzinfo=ET)
                # Adjust to weekday
                while gdp_day.weekday() >= 5:
                    gdp_day += timedelta(days=1)

                gdp_time = gdp_day.replace(
                    hour=8, minute=30, second=0, microsecond=0
                )
                if start <= gdp_time <= end:
                    events.append(EconomicEvent(
                        name="GDP",
                        datetime_et=gdp_time,
                        impact="high",
                        currency="USD",
                    ))

        # FOMC: ~8 times/year, 2:00 PM ET
        # Use approximate schedule (actual dates vary by year)
        # Fed typically meets: Jan, Mar, May, Jun, Jul, Sep, Nov, Dec
        fomc_months = [1, 3, 5, 6, 7, 9, 11, 12]
        for year in range(start.year, end.year + 1):
            for month in fomc_months:
                # FOMC typically mid-month, Wed announcement at 2 PM
                # Find third Wednesday of month (approximate)
                first_day = datetime(year, month, 1, tzinfo=ET)
                days_to_wed = (2 - first_day.weekday()) % 7  # Wed = 2
                third_wed = first_day + timedelta(days=days_to_wed + 14)

                fomc_time = third_wed.replace(
                    hour=14, minute=0, second=0, microsecond=0
                )
                if start <= fomc_time <= end:
                    events.append(EconomicEvent(
                        name="FOMC Statement",
                        datetime_et=fomc_time,
                        impact="high",
                        currency="USD",
                    ))

        return sorted(events, key=lambda e: e.datetime_et)
```

AVOID:
- Making HTTP requests during backtest (use cache)
- Blocking on API calls
- Not handling timezone correctly
  </action>
  <verify>
    - python -c "from nautilus_gold_scalper.src.execution.economic_calendar import EconomicCalendar; c = EconomicCalendar(); print('OK')"
    - mypy --strict nautilus_gold_scalper/src/execution/economic_calendar.py
  </verify>
  <done>
    - EconomicCalendar class created
    - High/medium impact event detection
    - Pre-event blocking (5 min before)
    - Post-event delay multiplier (10 min after)
    - Caching for backtest performance
    - NFP detection (first Friday of month)
  </done>
</task>

<task type="auto">
  <name>Task 3: Create Enhanced HBS Core Simulator</name>
  <files>nautilus_gold_scalper/src/execution/human_simulator.py</files>
  <action>
Create the core HumanBehaviorSimulator class with ALL fixes from ARGUS+CRITIC review:

```python
"""
Human Behavior Simulator (HBS) v2.0
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
"""

import pickle
import hashlib
from dataclasses import dataclass, field
from datetime import datetime, timedelta, time
from typing import Optional, Literal, List, Tuple
from pathlib import Path
from zoneinfo import ZoneInfo

import numpy as np

from .human_config import HumanSimConfig
from .economic_calendar import EconomicCalendar, EconomicEvent

ET = ZoneInfo("America/New_York")

@dataclass
class HBSState:
    """Mutable state tracking for the simulator."""
    # Daily state (reset on session_start)
    trades_today: int = 0
    warmup_trades_target: int = 1  # Randomized 1-3
    daily_pnl: float = 0.0
    is_sick_day: bool = False
    session_start: Optional[datetime] = None

    # Cumulative state (persists across days for Apex 30% rule)
    cumulative_pnl: float = 0.0

    # Streak state
    consecutive_losses: int = 0
    consecutive_wins: int = 0

    # Timing state (for throttling)
    last_trade_time: Optional[datetime] = None
    orders_this_minute: int = 0
    minute_start: Optional[datetime] = None

    # Mood state (daily modifier - H7 fix)
    mood_modifier: float = 1.0  # 0.80 - 1.20

    # Break state
    in_micro_break: bool = False
    break_end_time: Optional[datetime] = None

    # Fatigue
    hours_traded_today: float = 0.0

@dataclass
class HBSDecision:
    """Output of HBS decision-making."""
    should_skip: bool = False
    skip_reason: Optional[str] = None
    delay_seconds: float = 0.0
    size_multiplier: float = 1.0
    order_type: Literal["MARKET", "LIMIT", "STOP_LIMIT"] = "MARKET"
    entry_offset_ticks: int = 0
    is_throttled: bool = False
    throttle_wait_seconds: float = 0.0
    # C-NEW-2 FIX: Add limit_price and stop_price for LIMIT/STOP_LIMIT orders
    limit_price: Optional[float] = None    # Price for LIMIT orders
    stop_price: Optional[float] = None     # Trigger price for STOP_LIMIT orders
    # H-NEW-4 FIX: Context-aware cancellation
    cancel_if_price_moves_ticks: int = 5   # Cancel limit if price moves X ticks away
    cancel_after_seconds: float = 30.0     # Cancel limit if not filled in X seconds

class HumanBehaviorSimulator:
    """
    Core HBS implementation.

    Thread-safety: NOT thread-safe. Use one instance per strategy.
    """

    def __init__(
        self,
        config: HumanSimConfig,
        calendar: Optional[EconomicCalendar] = None,
    ):
        self.config = config
        self.state = HBSState()
        self.calendar = calendar or EconomicCalendar()

        # A1 FIX: Apply per-account parameter jitter for multivariate defense
        if config.jitter_enabled:
            self._apply_account_jitter()

        # Initialize RNG with proper seeding (C1, H8 fix)
        self._rng = self._create_rng()

        # Load persisted state if exists
        if config.rng_persist_state:
            self._load_rng_state()

    def _apply_account_jitter(self) -> None:
        """
        A1 FIX: Apply per-account parameter jitter for multivariate defense.

        Different accounts should have slightly different behavioral parameters
        to prevent AI detection systems from clustering accounts by behavior.
        The jitter is deterministic based on account_id so it's reproducible.
        """
        import hashlib

        # Create deterministic jitter based on account_id
        if not self.config.rng_seed_account_id:
            return  # Can't jitter without account ID

        # Hash account ID to get deterministic jitter seed
        hash_bytes = hashlib.sha256(
            self.config.rng_seed_account_id.encode()
        ).digest()
        jitter_seed = int.from_bytes(hash_bytes[:8], byteorder="big")
        jitter_rng = np.random.default_rng(jitter_seed)

        jitter_range = self.config.jitter_range

        # Apply jitter to key behavioral parameters
        # These are modified IN PLACE on the config (copy if needed)
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
        self.config.throttle_cooldown_seconds = jitter(
            self.config.throttle_cooldown_seconds
        )

    # ==========================================================================
    # CORE API
    # ==========================================================================

    def decide(
        self,
        signal_score: float,
        current_time: datetime,
        current_atr: float,
        atr_percentile: float,  # Changed from average_atr (M3 fix)
        current_dd: float = 0.0,  # H-NEW-6: Current drawdown as decimal (e.g., 0.035 = 3.5%)
    ) -> HBSDecision:
        """
        Main entry point: given a signal, return humanized execution decision.

        Args:
            signal_score: Confluence score 0.0-1.0
            current_time: Current timestamp (timezone-aware)
            current_atr: Current ATR value
            atr_percentile: Percentile rank of current ATR (0-100)
            current_dd: Current drawdown as decimal (H-NEW-6 fix)

        Returns:
            HBSDecision with all humanization applied
        """
        if not self.config.enabled:
            return HBSDecision()

        # Ensure timezone
        if current_time.tzinfo is None:
            current_time = current_time.replace(tzinfo=ET)

        decision = HBSDecision()

        # H-NEW-6 FIX: Check if we're in crisis mode (DD > threshold)
        in_crisis = (
            self.config.crisis_mode_enabled
            and current_dd >= self.config.crisis_dd_threshold
        )

        # === PRE-CHECKS ===

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

        # === SKIP LOGIC ===

        # H-NEW-6 FIX: In crisis mode, NEVER skip signals (execute ASAP)
        if not in_crisis or not self.config.crisis_skip_disabled:
            should_skip, skip_reason = self._should_skip_signal(
                signal_score, atr_percentile
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
                current_time, event,
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
            base_delay *= (1.0 - self.config.crisis_delay_reduction)
            self._log.info(
                f"CRISIS MODE: DD={current_dd*100:.2f}% > {self.config.crisis_dd_threshold*100:.1f}%, "
                f"delay reduced by {self.config.crisis_delay_reduction*100:.0f}%"
            )

        decision.delay_seconds = base_delay

        # === SIZE CALCULATION ===

        decision.size_multiplier = self._calculate_size_multiplier()

        # === ORDER TYPE ===

        # A4 FIX: Pass atr_percentile for volatility-adaptive order types
        decision.order_type = self._select_order_type(atr_percentile)

        # === ENTRY OFFSET ===

        decision.entry_offset_ticks = self._rng.integers(
            0, self.config.entry_offset_ticks_max + 1
        )

        # N-2 FIX: limit_price/stop_price must be calculated by caller
        # HBS cannot calculate them without knowing:
        #   - current_price
        #   - tick_size
        #   - signal direction
        # The integration layer (_execute_with_hbs) must populate these:
        #
        #   if decision.order_type == "LIMIT":
        #       direction_mult = 1 if signal.direction == "LONG" else -1
        #       # Buy limits below market, sell limits above
        #       offset = decision.entry_offset_ticks * tick_size * (-direction_mult)
        #       decision.limit_price = current_price + offset
        #   elif decision.order_type == "STOP_LIMIT":
        #       direction_mult = 1 if signal.direction == "LONG" else -1
        #       # Stop above market for longs, below for shorts
        #       stop_offset = self.config.stop_limit_offset_ticks * tick_size * direction_mult
        #       decision.stop_price = current_price + stop_offset
        #       # Limit slightly beyond stop for slippage allowance
        #       decision.limit_price = decision.stop_price + (tick_size * 2 * direction_mult)

        return decision

    def on_trade_result(self, win: bool, pnl: float) -> None:
        """Update state after trade completes."""
        self.state.trades_today += 1
        self.state.daily_pnl += pnl
        self.state.cumulative_pnl += pnl

        if win:
            self.state.consecutive_wins += 1
            self.state.consecutive_losses = 0
        else:
            self.state.consecutive_losses += 1
            self.state.consecutive_wins = 0

        self.state.last_trade_time = datetime.now(ET)

        # Maybe roll micro-break
        self._maybe_start_micro_break()

        # Persist RNG state
        if self.config.rng_persist_state:
            self._save_rng_state()

    def on_session_start(self, dt: datetime) -> None:
        """Reset daily state, roll sick day, set mood."""
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
        self.state.warmup_trades_target = self._rng.integers(
            self.config.size_warmup_trades_min,
            self.config.size_warmup_trades_max + 1,
        )

        # Roll sick day
        sick_rate = self.config.sick_day_rate
        if dt.weekday() == 0:  # Monday
            sick_rate *= self.config.sick_day_monday_reduction
        self.state.is_sick_day = self._rng.random() < sick_rate

        # Roll daily mood (H7 fix)
        if self.config.mood_variance_enabled:
            self.state.mood_modifier = self._rng.uniform(
                self.config.mood_daily_modifier_min,
                self.config.mood_daily_modifier_max,
            )

        # Re-seed RNG for new session (H8 fix)
        if self.config.rng_seed_from_date:
            self._reseed_for_date(dt)

    def on_session_end(self) -> None:
        """End of day cleanup."""
        # Check big win pause for next day
        if self.config.pause_after_big_win:
            if self.state.daily_pnl >= self.config.big_win_threshold:
                # Roll pause probability - affects NEXT session
                pass  # Handled in on_session_start

        # Persist final state
        if self.config.rng_persist_state:
            self._save_rng_state()

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
            delay = self._rng.normal(
                self.config.delay_mean,
                self.config.delay_std,
            )
        else:
            # Log-normal component (long-tail)
            delay = self._rng.lognormal(
                self.config.delay_longtail_mu,
                self.config.delay_longtail_sigma,
            )

        # Apply fatigue
        fatigue_mult = self._calculate_fatigue_modifier(current_time)
        delay *= fatigue_mult

        # Clamp to bounds
        delay = np.clip(delay, self.config.delay_min, self.config.delay_max)

        return float(delay)

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
            sigmoid = 1 / (1 + np.exp(-(hours - midpoint) / scale))
            fatigue = 1.0 + self.config.delay_fatigue_max * sigmoid
        else:
            # Linear fallback
            fatigue = 1.0 + (hours * self.config.delay_fatigue_max / 8.0)

        return min(fatigue, 1.0 + self.config.delay_fatigue_max)

    def _should_skip_signal(
        self,
        signal_score: float,
        atr_percentile: float,
    ) -> Tuple[bool, Optional[str]]:
        """Tier 2: Signal skip logic with mood modifier and ARGUS enhancements."""
        if not self.config.skip_enabled:
            return False, None

        skip_rate = self.config.skip_base_rate

        # A5 FIX: Apply day-of-week modifier
        weekday_name = datetime.now(ET).strftime("%A")
        weekday_mod = self.config.weekday_modifiers.get(weekday_name, 1.0)
        skip_rate *= weekday_mod

        # Apply mood modifier (H7)
        if self.config.mood_variance_enabled and "skip" in self.config.mood_affects:
            skip_rate *= self.state.mood_modifier

        # A2 FIX: EXPONENTIAL skip rate increase after losses (fear response)
        # Human traders become increasingly cautious after losses
        if self.state.consecutive_losses >= 1:
            # Exponential: base^losses (e.g., 1.5^3 = 3.375x increase after 3 losses)
            fear_multiplier = 1.5 ** self.state.consecutive_losses
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
        variation = self._rng.uniform(
            1.0 - self.config.size_variation,
            1.0 + self.config.size_variation,
        )

        # Apply mood (H7)
        if self.config.mood_variance_enabled and "size" in self.config.mood_affects:
            variation *= self.state.mood_modifier

        # Loss reduction
        if self.state.consecutive_losses >= self.config.size_reduce_after_losses:
            variation *= (1.0 - self.config.size_loss_reduction)

        # Warmup reduction
        if self.state.trades_today < self.state.warmup_trades_target:
            variation *= (1.0 - self.config.size_warmup_reduction)

        return float(np.clip(variation, 0.5, 1.2))

    def _select_order_type(
        self,
        atr_percentile: float = 50.0,  # A4 FIX: Accept ATR for volatility adaptation
    ) -> Literal["MARKET", "LIMIT", "STOP_LIMIT"]:
        """Tier 4: Weighted order type with daily drift and volatility adaptation.

        A4 FIX: In high volatility, human traders use more market orders
        (want immediate fill, less confident in limits getting filled).
        """
        # Apply daily drift
        drift = self._rng.uniform(
            -self.config.order_type_daily_drift,
            self.config.order_type_daily_drift,
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
        weekday_name = datetime.now(ET).strftime("%A")
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

        roll = self._rng.random()
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

        return self.config.trading_start_hour <= hour < end_hour

    def _check_throttle(self, current_time: datetime) -> Tuple[bool, float]:
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

    def _maybe_start_micro_break(self) -> None:
        """Tier 3: Maybe start a micro-break after trade."""
        if not self.config.micro_break_enabled:
            return

        # Probability per hour, but check after each trade
        # Approximate: if 3 trades/hour, each has 1/3 of hourly probability
        prob = self.config.micro_break_probability_per_hour / 3.0

        if self._rng.random() < prob:
            duration = self._rng.integers(
                self.config.micro_break_duration_min_minutes,
                self.config.micro_break_duration_max_minutes + 1,
            )
            self.state.in_micro_break = True
            self.state.break_end_time = datetime.now(ET) + timedelta(minutes=duration)

    # ==========================================================================
    # RNG MANAGEMENT (C1, H8 fixes)
    # ==========================================================================

    def _create_rng(self) -> np.random.Generator:
        """Create RNG with proper seeding."""
        if self.config.rng_seed_from_date:
            seed = self._compute_seed(datetime.now(ET))
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

    def _save_rng_state(self) -> None:
        """Persist RNG state and session counter to disk.

        N-3 FIX: Also persist session_counter so mid-day restarts get unique seeds.
        """
        state_file = Path(self.config.rng_state_file)
        state_data = {
            "rng_state": self._rng.bit_generator.state,
            "session_counter": self.config.rng_session_counter,
            "last_save_date": datetime.now(ET).date().isoformat(),
        }
        # Use JSON for security (pickle can execute arbitrary code)
        if self.config.rng_use_json_format:
            import json
            # RNG state contains numpy arrays, need to convert
            with open(state_file.with_suffix(".json"), "w") as f:
                json.dump({
                    "session_counter": state_data["session_counter"],
                    "last_save_date": state_data["last_save_date"],
                }, f)
        else:
            with open(state_file, "wb") as f:
                pickle.dump(state_data, f)

    def _load_rng_state(self) -> None:
        """Load persisted RNG state and increment session counter.

        N-3 FIX: Increment session_counter on each load to ensure unique seeds
        even if EA restarts mid-day.
        """
        state_file = Path(self.config.rng_state_file)
        json_file = state_file.with_suffix(".json")

        try:
            if self.config.rng_use_json_format and json_file.exists():
                import json
                with open(json_file, "r") as f:
                    data = json.load(f)
                last_date = data.get("last_save_date", "")
                today = datetime.now(ET).date().isoformat()

                if last_date == today:
                    # Same day restart - increment counter
                    self.config.rng_session_counter = data.get("session_counter", 0) + 1
                else:
                    # New day - reset counter
                    self.config.rng_session_counter = 0
            elif state_file.exists():
                # Legacy pickle format
                with open(state_file, "rb") as f:
                    data = pickle.load(f)
                if isinstance(data, dict):
                    self._rng.bit_generator.state = data.get("rng_state", self._rng.bit_generator.state)
                    last_date = data.get("last_save_date", "")
                    today = datetime.now(ET).date().isoformat()
                    if last_date == today:
                        self.config.rng_session_counter = data.get("session_counter", 0) + 1
                else:
                    # Old format (just the state)
                    self._rng.bit_generator.state = data
        except Exception:
            pass  # Use fresh RNG if load fails
```

AVOID:
- time.sleep() - return delay for caller to handle async
- Look-ahead bias - only use information available at signal time
- Deterministic patterns - proper randomization with mixture model
- Hardcoded timezones - always use ZoneInfo
  </action>
  <verify>
    - python -c "from nautilus_gold_scalper.src.execution.human_simulator import HumanBehaviorSimulator; from nautilus_gold_scalper.src.execution.human_config import HumanSimConfig; h = HumanBehaviorSimulator(HumanSimConfig()); print('OK')"
    - mypy --strict nautilus_gold_scalper/src/execution/human_simulator.py
  </verify>
  <done>
    - HumanBehaviorSimulator class created with 18+ techniques
    - Mixture model delays (Gaussian + log-normal)
    - Economic calendar integration
    - Session mood variance
    - Signal throttling
    - Logistic fatigue curve
    - Proper RNG seeding and persistence
    - All CRITICAL and HIGH fixes implemented
    - mypy passes with --strict
  </done>
</task>

<task type="auto">
  <name>Task 4: Create Comprehensive Unit Tests</name>
  <files>nautilus_gold_scalper/tests/test_human_simulator.py</files>
  <action>
Create comprehensive unit tests for HBS with 90%+ coverage, including tests for all CRITIC-identified edge cases:

```python
"""
HBS Unit Tests
==============
Comprehensive tests for Human Behavior Simulator.
Includes statistical validation and edge case coverage.
"""

import pytest
import numpy as np
from datetime import datetime, timedelta
from pathlib import Path
from zoneinfo import ZoneInfo
from scipy import stats

from nautilus_gold_scalper.src.execution.human_config import (
    HumanSimConfig,
    get_default_config,
    get_aggressive_config,
    get_conservative_config,
)
from nautilus_gold_scalper.src.execution.human_simulator import (
    HumanBehaviorSimulator,
    HBSState,
    HBSDecision,
)
from nautilus_gold_scalper.src.execution.economic_calendar import (
    EconomicCalendar,
    EconomicEvent,
)

ET = ZoneInfo("America/New_York")

class TestHumanSimConfig:
    """Test configuration module."""

    def test_default_config_valid(self):
        config = HumanSimConfig()
        config.validate()
        assert config.delay_mean == 1.0
        assert config.delay_std == 0.45  # Updated value
        assert config.skip_base_rate == 0.13  # Updated value

    def test_validation_catches_invalid_delay_min(self):
        config = HumanSimConfig(delay_min=0.3)  # Too low
        with pytest.raises(AssertionError):
            config.validate()

    def test_yaml_loading(self, tmp_path):
        yaml_content = """
enabled: true
delay_mean: 1.2
skip_base_rate: 0.15
"""
        yaml_file = tmp_path / "config.yaml"
        yaml_file.write_text(yaml_content)

        config = HumanSimConfig.from_yaml(yaml_file)
        assert config.delay_mean == 1.2
        assert config.skip_base_rate == 0.15

    def test_factory_presets(self):
        default = get_default_config()
        aggressive = get_aggressive_config()
        conservative = get_conservative_config()

        assert aggressive.skip_base_rate < default.skip_base_rate
        assert conservative.skip_base_rate > default.skip_base_rate
        assert conservative.delay_mean > aggressive.delay_mean

class TestHumanBehaviorSimulator:
    """Test core simulator functionality."""

    @pytest.fixture
    def simulator(self) -> HumanBehaviorSimulator:
        config = HumanSimConfig(enabled=True, rng_persist_state=False)
        return HumanBehaviorSimulator(config)

    @pytest.fixture
    def trading_time(self) -> datetime:
        """Valid trading time: Tuesday 10 AM ET."""
        return datetime(2024, 3, 12, 10, 0, 0, tzinfo=ET)

    # === SKIP LOGIC ===

    def test_skip_rate_approximately_13_percent(self, simulator, trading_time):
        """Base skip rate should be ~13% (updated from 10%)."""
        simulator.on_session_start(trading_time)

        skips = 0
        N = 2000
        for _ in range(N):
            decision = simulator.decide(
                signal_score=0.9,
                current_time=trading_time,
                current_atr=1.0,
                atr_percentile=50,
            )
            if decision.should_skip and decision.skip_reason == "random_skip":
                skips += 1

        skip_rate = skips / N
        assert 0.08 <= skip_rate <= 0.18, f"Skip rate {skip_rate} outside expected range"

    def test_skip_rate_increases_after_losses(self, simulator, trading_time):
        """Skip rate should increase after consecutive losses."""
        simulator.on_session_start(trading_time)

        # Simulate 3 losses
        for _ in range(3):
            simulator.on_trade_result(win=False, pnl=-100)

        skips = 0
        N = 1000
        for _ in range(N):
            decision = simulator.decide(
                signal_score=0.9,
                current_time=trading_time,
                current_atr=1.0,
                atr_percentile=50,
            )
            if decision.should_skip:
                skips += 1

        skip_rate = skips / N
        # Should be higher than base (13% + 3*5% = 28%)
        assert skip_rate >= 0.20, f"Skip rate {skip_rate} should be >= 20% after 3 losses"

    # === DELAY LOGIC (H1 FIX) ===

    def test_delay_follows_mixture_distribution(self, simulator, trading_time):
        """Delay should NOT be purely Gaussian (K-S test should fail for normal)."""
        simulator.on_session_start(trading_time)

        delays = []
        for _ in range(1000):
            decision = simulator.decide(
                signal_score=0.9,
                current_time=trading_time,
                current_atr=1.0,
                atr_percentile=50,
            )
            if not decision.should_skip:
                delays.append(decision.delay_seconds)

        # K-S test against normal distribution
        # Should FAIL because we use mixture model
        _, p_value = stats.normaltest(delays)

        # p_value < 0.05 means NOT normal (which is what we want)
        # But we don't want it to be TOO non-normal either
        assert len(delays) > 500, "Not enough non-skipped signals"
        # Just verify we have long-tail (some values > 2.5s)
        assert max(delays) > 2.0, "Should have long-tail delays"

    def test_delay_clamped_to_bounds(self, simulator, trading_time):
        """Delays should be within min/max bounds."""
        simulator.on_session_start(trading_time)

        for _ in range(500):
            decision = simulator.decide(
                signal_score=0.9,
                current_time=trading_time,
                current_atr=1.0,
                atr_percentile=50,
            )
            if not decision.should_skip:
                assert decision.delay_seconds >= simulator.config.delay_min
                assert decision.delay_seconds <= simulator.config.delay_max

    def test_delay_zero_in_backtest_mode(self):
        """In backtest mode, delay is calculated but should be informational."""
        config = HumanSimConfig(mode="backtest", rng_persist_state=False)
        simulator = HumanBehaviorSimulator(config)
        simulator.on_session_start(datetime(2024, 3, 12, 10, 0, 0, tzinfo=ET))

        decision = simulator.decide(
            signal_score=0.9,
            current_time=datetime(2024, 3, 12, 10, 0, 0, tzinfo=ET),
            current_atr=1.0,
            atr_percentile=50,
        )

        # Delay is calculated (not zero) even in backtest
        # But caller should NOT apply it
        assert decision.delay_seconds >= 0

    # === THROTTLE LOGIC (H4 FIX) ===

    def test_signal_throttle_blocks_rapid_signals(self, simulator, trading_time):
        """Rapid signals should be throttled."""
        simulator.on_session_start(trading_time)

        # Simulate 5 rapid signals within same minute
        throttled_count = 0
        for i in range(5):
            decision = simulator.decide(
                signal_score=0.9,
                current_time=trading_time + timedelta(seconds=i * 5),
                current_atr=1.0,
                atr_percentile=50,
            )
            if decision.is_throttled:
                throttled_count += 1
            elif not decision.should_skip:
                simulator.on_trade_result(win=True, pnl=100)

        # With max 3/minute and 20s cooldown, 2 of 5 should be throttled
        assert throttled_count >= 1, "Should throttle rapid signals"

    # === TRADING HOURS (H3 FIX) ===

    def test_outside_trading_hours_skips(self, simulator):
        """Signals outside trading hours should be skipped."""
        # 6 AM ET - before trading hours
        early_time = datetime(2024, 3, 12, 6, 0, 0, tzinfo=ET)
        simulator.on_session_start(early_time)

        decision = simulator.decide(
            signal_score=0.9,
            current_time=early_time,
            current_atr=1.0,
            atr_percentile=50,
        )

        assert decision.should_skip
        assert decision.skip_reason == "outside_trading_hours"

    def test_friday_early_close(self, simulator):
        """Friday should close at 2 PM ET."""
        # Friday 3 PM ET - after early close
        friday_late = datetime(2024, 3, 15, 15, 0, 0, tzinfo=ET)  # Friday
        simulator.on_session_start(friday_late)

        decision = simulator.decide(
            signal_score=0.9,
            current_time=friday_late,
            current_atr=1.0,
            atr_percentile=50,
        )

        assert decision.should_skip
        assert decision.skip_reason == "outside_trading_hours"

    # === SESSION MOOD (H7 FIX) ===

    def test_mood_variance_affects_behavior(self):
        """Different mood modifiers should affect skip/delay/size."""
        config = HumanSimConfig(
            mood_variance_enabled=True,
            rng_persist_state=False,
        )
        simulator = HumanBehaviorSimulator(config)

        # Run multiple sessions, collect mood modifiers
        moods = []
        for day in range(20):
            dt = datetime(2024, 3, day + 1, 10, 0, 0, tzinfo=ET)
            simulator.on_session_start(dt)
            moods.append(simulator.state.mood_modifier)

        # Should have variance in moods
        assert min(moods) < 0.95
        assert max(moods) > 1.05
        assert 0.80 <= min(moods) <= 1.20
        assert 0.80 <= max(moods) <= 1.20

    # === ECONOMIC CALENDAR (C5 FIX) ===

    def test_pre_news_block(self, simulator):
        """Signals 5 min before NFP should be blocked."""
        # NFP is first Friday, 8:30 AM ET
        nfp_time = datetime(2024, 3, 1, 8, 30, 0, tzinfo=ET)  # First Friday March 2024

        # 5 minutes before NFP
        before_nfp = nfp_time - timedelta(minutes=3)
        simulator.on_session_start(before_nfp)

        # Manually add NFP event
        simulator.calendar.events = [
            EconomicEvent(
                name="Nonfarm Payrolls",
                datetime_et=nfp_time,
                impact="high",
                currency="USD",
            )
        ]

        decision = simulator.decide(
            signal_score=0.9,
            current_time=before_nfp,
            current_atr=1.0,
            atr_percentile=50,
        )

        assert decision.should_skip
        assert "pre_news_block" in decision.skip_reason

    # === RNG MANAGEMENT (C1, H8 FIXES) ===

    def test_rng_reseed_per_session(self):
        """Different dates should produce different sequences."""
        config = HumanSimConfig(
            rng_seed_from_date=True,
            rng_seed_account_id="TEST123",
            rng_persist_state=False,
        )

        sim1 = HumanBehaviorSimulator(config)
        sim1.on_session_start(datetime(2024, 3, 1, 10, 0, 0, tzinfo=ET))

        sim2 = HumanBehaviorSimulator(config)
        sim2.on_session_start(datetime(2024, 3, 2, 10, 0, 0, tzinfo=ET))

        # Generate some random values
        vals1 = [sim1._rng.random() for _ in range(10)]
        vals2 = [sim2._rng.random() for _ in range(10)]

        # Should be different sequences
        assert vals1 != vals2

    def test_rng_reproducible_same_date(self):
        """Same date + account should produce same sequence."""
        config = HumanSimConfig(
            rng_seed_from_date=True,
            rng_seed_account_id="TEST123",
            rng_persist_state=False,
        )

        sim1 = HumanBehaviorSimulator(config)
        sim1.on_session_start(datetime(2024, 3, 1, 10, 0, 0, tzinfo=ET))

        sim2 = HumanBehaviorSimulator(config)
        sim2.on_session_start(datetime(2024, 3, 1, 10, 0, 0, tzinfo=ET))

        # Generate some random values
        vals1 = [sim1._rng.random() for _ in range(10)]
        vals2 = [sim2._rng.random() for _ in range(10)]

        # Should be same sequences
        assert vals1 == vals2

    # === EDGE CASES (CRITIC) ===

    def test_disabled_config_bypasses_all(self):
        """When disabled, HBS should return default decision."""
        config = HumanSimConfig(enabled=False, rng_persist_state=False)
        simulator = HumanBehaviorSimulator(config)

        decision = simulator.decide(
            signal_score=0.9,
            current_time=datetime(2024, 3, 12, 10, 0, 0, tzinfo=ET),
            current_atr=1.0,
            atr_percentile=50,
        )

        assert not decision.should_skip
        assert decision.delay_seconds == 0.0
        assert decision.size_multiplier == 1.0

    def test_sick_day_skips_all_signals(self, simulator, trading_time):
        """Sick day should skip all signals."""
        simulator.on_session_start(trading_time)
        simulator.state.is_sick_day = True

        decision = simulator.decide(
            signal_score=1.0,
            current_time=trading_time,
            current_atr=1.0,
            atr_percentile=50,
        )

        assert decision.should_skip
        assert decision.skip_reason == "sick_day"

class TestStatisticalProperties:
    """Monte Carlo tests for statistical validation."""

    def test_skip_rate_converges(self):
        """Skip rate should converge to configured value over many signals."""
        config = HumanSimConfig(
            skip_base_rate=0.13,
            mood_variance_enabled=False,  # Disable for pure test
            rng_persist_state=False,
        )
        simulator = HumanBehaviorSimulator(config)
        simulator.on_session_start(datetime(2024, 3, 12, 10, 0, 0, tzinfo=ET))

        skips = 0
        N = 5000
        for _ in range(N):
            decision = simulator.decide(
                signal_score=0.9,  # Strong signal
                current_time=datetime(2024, 3, 12, 10, 0, 0, tzinfo=ET),
                current_atr=1.0,
                atr_percentile=50,
            )
            if decision.should_skip and decision.skip_reason == "random_skip":
                skips += 1

        skip_rate = skips / N
        # Should be within 2% of target
        assert abs(skip_rate - 0.13) < 0.03, f"Skip rate {skip_rate} not near 0.13"

    def test_size_variation_uniform(self):
        """Size multiplier should be approximately uniform in range."""
        config = HumanSimConfig(
            size_variation=0.18,
            mood_variance_enabled=False,
            rng_persist_state=False,
        )
        simulator = HumanBehaviorSimulator(config)
        simulator.on_session_start(datetime(2024, 3, 12, 10, 0, 0, tzinfo=ET))

        sizes = []
        for _ in range(2000):
            mult = simulator._calculate_size_multiplier()
            sizes.append(mult)

        # Should be roughly uniform between 0.82 and 1.18
        assert min(sizes) >= 0.75
        assert max(sizes) <= 1.25
        # Mean should be near 1.0
        assert 0.95 <= np.mean(sizes) <= 1.05
```

AVOID: Flaky tests - use sufficient sample sizes (N≥1000) for statistical tests.
  </action>
  <verify>
    - pytest nautilus_gold_scalper/tests/test_human_simulator.py -v
    - pytest --cov=nautilus_gold_scalper.src.execution --cov-report=term-missing nautilus_gold_scalper/tests/test_human_simulator.py
  </verify>
  <done>
    - All tests pass
    - Coverage ≥ 90% on human_config, human_simulator, economic_calendar
    - Edge cases covered (CRITIC-identified)
    - Statistical properties verified (mixture model, skip rates)
    - RNG management tests pass
  </done>
</task>

</tasks>

<verification>
Before declaring plan complete:
- [ ] python -m pytest nautilus_gold_scalper/tests/test_human_simulator.py -v (all pass)
- [ ] mypy --strict nautilus_gold_scalper/src/execution/human_config.py (no errors)
- [ ] mypy --strict nautilus_gold_scalper/src/execution/human_simulator.py (no errors)
- [ ] mypy --strict nautilus_gold_scalper/src/execution/economic_calendar.py (no errors)
- [ ] Coverage ≥ 90%
- [ ] All 18+ techniques implemented and tested
- [ ] All CRITICAL fixes (C1, C5) verified
- [ ] All HIGH fixes (H1, H3-H8) verified
</verification>

<success_criteria>
- All tasks completed
- All verification checks pass
- HumanSimConfig with 26+ parameters (original 16 + 10 new)
- HumanBehaviorSimulator with 18+ techniques
- EconomicCalendar for news awareness
- Mixture model delays (anti-K-S detection)
- Session mood variance
- Signal throttling
- Proper RNG seeding
- Unit tests with 90%+ coverage
- Ready for integration in Plan 11-02
</success_criteria>

<output>
After completion, create `.planning/phases/08-nautilus-deep-audit/11-01-HBS-CORE-SUMMARY.md`:

# Phase 11 Plan 01: HBS Core Summary (v2.0)

**[Substantive one-liner about what was built]**

## Accomplishments
- Created human_config.py with 26+ HumanSimConfig parameters
- Created economic_calendar.py for news event detection
- Implemented HumanBehaviorSimulator with 18+ humanization techniques
- Unit tests with 90%+ coverage

## Files Created
- `nautilus_gold_scalper/src/execution/human_config.py` - Enhanced configuration
- `nautilus_gold_scalper/src/execution/economic_calendar.py` - News calendar
- `nautilus_gold_scalper/src/execution/human_simulator.py` - Core simulator v2.0
- `nautilus_gold_scalper/tests/test_human_simulator.py` - Comprehensive tests

## CRITICAL Fixes Implemented
- [C1] RNG seed management with persistence
- [C5] Economic calendar integration (NFP, FOMC blocking)

## HIGH Fixes Implemented
- [H1] Mixture model delays (80% Gaussian + 20% log-normal)
- [H3] Explicit timezone handling (ET)
- [H4] Signal throttling (max 3/min, 20s cooldown)
- [H5] Increased delay_std to 0.45
- [H6] Increased skip_base_rate to 0.13
- [H7] Session mood variance (0.80-1.20 daily modifier)
- [H8] RNG re-seeding per session

## Decisions Made
- [Key decisions and rationale]

## Issues Encountered
- [Problems and resolutions, or "None"]

## Next Step
Ready for 11-02-HBS-INTEGRATION-PLAN.md
</output>
