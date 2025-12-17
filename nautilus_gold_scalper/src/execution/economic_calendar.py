"""
Economic Calendar for HBS v2.2
==============================
Detects major news events that should trigger extended delays.
Prevents "bot traded through NFP at normal speed" detection.

H-NEW-2 FIX: Implements FOMC, CPI, GDP events (not just NFP).
"""

import json
import logging
from dataclasses import dataclass
from datetime import datetime, timedelta
from pathlib import Path
from typing import Literal
from zoneinfo import ZoneInfo

ET = ZoneInfo("America/New_York")

logger = logging.getLogger(__name__)


@dataclass
class EconomicEvent:
    """Single economic event."""
    name: str
    datetime_et: datetime
    impact: Literal["high", "medium", "low"]
    currency: str  # "USD", "EUR", etc.
    actual: float | None = None
    forecast: float | None = None
    previous: float | None = None


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
        if event and calendar.is_pre_event_blocked(current_time, event):
            # Skip or extend delay
    """

    def __init__(self, cache_dir: Path = Path(".cache/calendar")):
        self.cache_dir = cache_dir
        self.events: list[EconomicEvent] = []
        self._loaded_range: tuple[datetime, datetime] | None = None

    def load_events(self, start: datetime, end: datetime) -> None:
        """Load events for date range (from cache or generate)."""
        # Ensure timezone
        if start.tzinfo is None:
            start = start.replace(tzinfo=ET)
        if end.tzinfo is None:
            end = end.replace(tzinfo=ET)

        cache_file = self.cache_dir / f"{start.date()}_{end.date()}.json"

        if cache_file.exists():
            self._load_from_cache(cache_file)
        else:
            self._fetch_and_cache(start, end, cache_file)

        self._loaded_range = (start, end)
        logger.info(f"Loaded {len(self.events)} economic events for {start.date()} to {end.date()}")

    def get_nearest_event(
        self,
        current_time: datetime,
        lookahead_minutes: int = 30,
        lookbehind_minutes: int = 15,
    ) -> EconomicEvent | None:
        """Get nearest high/medium impact event within window."""
        # Ensure timezone
        if current_time.tzinfo is None:
            current_time = current_time.replace(tzinfo=ET)

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
        # Ensure timezone
        if current_time.tzinfo is None:
            current_time = current_time.replace(tzinfo=ET)

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
        # Ensure timezone
        if current_time.tzinfo is None:
            current_time = current_time.replace(tzinfo=ET)

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
        """Load events from cached JSON.

        R3-M-5 FIX: Handle corrupted cache files gracefully.
        """
        try:
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
        except (json.JSONDecodeError, KeyError, ValueError, TypeError) as e:
            logger.warning(f"Corrupted cache file {cache_file}: {e}. Regenerating events.")
            self.events = []  # Fall back to empty, caller will regenerate

    def _fetch_and_cache(
        self,
        start: datetime,
        end: datetime,
        cache_file: Path
    ) -> None:
        """Generate events and cache for future use."""
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
                indent=2,
            )

    def _generate_known_events(
        self,
        start: datetime,
        end: datetime
    ) -> list[EconomicEvent]:
        """
        Generate known recurring events.

        NFP: First Friday of month, 8:30 AM ET
        FOMC: ~8 times/year, 2:00 PM ET (check schedule)
        CPI: ~12th of month, 8:30 AM ET
        GDP: Quarterly, ~25th-28th of month

        CRITICAL-5 WARNING: These are APPROXIMATIONS. Real event dates vary.
        For production, consider loading from a curated JSON file or external API.
        """
        # CRITICAL-5 FIX: Log warning about approximations
        logger.warning(
            "EconomicCalendar using APPROXIMATE event dates. "
            "NFP/FOMC/CPI/GDP dates are estimated and may not match actual release dates. "
            "For production, load from a verified calendar source."
        )

        events: list[EconomicEvent] = []

        # Generate NFP dates (first Friday of each month)
        current = start.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
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
        current = start.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        while current <= end:
            # CPI typically released around 12th of month
            try:
                cpi_day = current.replace(day=12)
            except ValueError:
                # Handle short months
                cpi_day = current.replace(day=10)

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
                try:
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
                except ValueError:
                    continue  # Skip invalid dates

        # FOMC: ~8 times/year, 2:00 PM ET
        # Use approximate schedule (actual dates vary by year)
        # Fed typically meets: Jan, Mar, May, Jun, Jul, Sep, Nov, Dec
        fomc_months = [1, 3, 5, 6, 7, 9, 11, 12]
        for year in range(start.year, end.year + 1):
            for month in fomc_months:
                try:
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
                except ValueError:
                    continue  # Skip invalid dates

        # Sort by datetime
        return sorted(events, key=lambda e: e.datetime_et)

    def get_events_for_date(self, dt: datetime) -> list[EconomicEvent]:
        """Get all events for a specific date."""
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=ET)

        target_date = dt.date()
        return [
            e for e in self.events
            if e.datetime_et.date() == target_date
        ]

    def has_high_impact_today(self, dt: datetime) -> bool:
        """Check if there are any high-impact events today."""
        events_today = self.get_events_for_date(dt)
        return any(e.impact == "high" for e in events_today)
