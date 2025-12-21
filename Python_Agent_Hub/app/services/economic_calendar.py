"""
Economic Calendar Service
=========================
Fetches economic events from Finnhub API with caching and fallback.

Design Decisions (from pre-implementation analysis):
1. All timestamps in UTC (Unix epoch)
2. Retry with exponential backoff (3x: 1s, 2s, 4s)
3. Cache in memory + JSON file backup
4. Pydantic validation for all data
5. Fallback to local CSV if API fails

Events tracked for Gold:
- Fed Interest Rate Decision (CRITICAL)
- Non-Farm Payrolls (HIGH)
- CPI (HIGH)
- PPI (MEDIUM)
- GDP (MEDIUM)
- Jobless Claims (MEDIUM)
"""

import argparse
import csv
import os
import json
import time
import logging
from datetime import datetime, timezone, timedelta
from typing import Optional, List, Dict, Any
from enum import Enum
from pathlib import Path
import requests

from pydantic import BaseModel, Field, validator

logger = logging.getLogger(__name__)


class NewsImpact(str, Enum):
    """Impact level of economic event."""
    HIGH = "HIGH"
    MEDIUM = "MEDIUM"
    LOW = "LOW"


class EconomicEvent(BaseModel):
    """Economic event data model with validation."""
    timestamp_utc: int = Field(..., description="Unix timestamp in UTC")
    event: str = Field(..., min_length=1, max_length=200)
    country: str = Field(default="US", max_length=10)
    currency: str = Field(default="USD", max_length=10)
    impact: NewsImpact = Field(default=NewsImpact.MEDIUM)
    forecast: Optional[float] = None
    previous: Optional[float] = None
    actual: Optional[float] = None
    unit: str = Field(default="", max_length=20)
    
    @validator('timestamp_utc')
    def validate_timestamp(cls, v):
        if v < 946684800:  # Before year 2000
            raise ValueError("Timestamp too old")
        if v > 2524608000:  # After year 2050
            raise ValueError("Timestamp too far in future")
        return v
    
    @property
    def datetime_utc(self) -> datetime:
        """Convert timestamp to datetime."""
        return datetime.fromtimestamp(self.timestamp_utc, tz=timezone.utc)
    
    @property
    def surprise(self) -> Optional[float]:
        """Calculate surprise (actual - forecast)."""
        if self.actual is not None and self.forecast is not None:
            return self.actual - self.forecast
        return None
    
    @property
    def surprise_direction(self) -> str:
        """Direction of surprise: BETTER, WORSE, INLINE."""
        surprise = self.surprise
        if surprise is None:
            return "UNKNOWN"
        if abs(surprise) < 0.01:
            return "INLINE"
        return "BETTER" if surprise > 0 else "WORSE"
    
    def to_csv_row(self) -> str:
        """Convert to CSV row."""
        return f"{self.timestamp_utc},{self.event},{self.currency},{self.impact.value},{self.forecast or ''},{self.previous or ''},{self.actual or ''}"


class EconomicCalendarCache:
    """In-memory cache with file backup."""
    
    def __init__(self, cache_file: str = None):
        self.events: List[EconomicEvent] = []
        self.last_update: Optional[datetime] = None
        self.cache_ttl_seconds: int = 3600  # 1 hour
        
        if cache_file:
            self.cache_file = Path(cache_file)
        else:
            self.cache_file = Path(__file__).parent.parent / "data" / "calendar_cache.json"
        
        self._load_from_file()
    
    def _load_from_file(self):
        """Load cache from JSON file."""
        try:
            if self.cache_file.exists():
                with open(self.cache_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    self.events = [EconomicEvent(**e) for e in data.get('events', [])]
                    if data.get('last_update'):
                        self.last_update = datetime.fromisoformat(data['last_update'])
                    logger.info(f"Loaded {len(self.events)} events from cache file")
        except Exception as e:
            logger.warning(f"Failed to load cache file: {e}")
            self.events = []
    
    def _save_to_file(self):
        """Save cache to JSON file."""
        try:
            self.cache_file.parent.mkdir(parents=True, exist_ok=True)
            data = {
                'events': [e.dict() for e in self.events],
                'last_update': self.last_update.isoformat() if self.last_update else None
            }
            with open(self.cache_file, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2)
            logger.info(f"Saved {len(self.events)} events to cache file")
        except Exception as e:
            logger.error(f"Failed to save cache file: {e}")
    
    def is_valid(self) -> bool:
        """Check if cache is still valid."""
        if not self.last_update:
            return False
        age = (datetime.now(timezone.utc) - self.last_update).total_seconds()
        return age < self.cache_ttl_seconds
    
    def update(self, events: List[EconomicEvent]):
        """Update cache with new events."""
        self.events = events
        self.last_update = datetime.now(timezone.utc)
        self._save_to_file()
    
    def get_events(self, start_ts: int = None, end_ts: int = None) -> List[EconomicEvent]:
        """Get events within time range."""
        result = self.events
        if start_ts:
            result = [e for e in result if e.timestamp_utc >= start_ts]
        if end_ts:
            result = [e for e in result if e.timestamp_utc <= end_ts]
        return sorted(result, key=lambda e: e.timestamp_utc)


class FinnhubClient:
    """Finnhub API client with retry logic."""
    
    BASE_URL = "https://finnhub.io/api/v1"
    
    # Events that affect Gold (USD-related)
    GOLD_EVENTS = [
        "interest rate decision",
        "non-farm payrolls",
        "nonfarm payrolls",
        "unemployment rate",
        "cpi",
        "consumer price index",
        "ppi",
        "producer price index",
        "gdp",
        "gross domestic product",
        "jobless claims",
        "initial claims",
        "retail sales",
        "ism manufacturing",
        "ism services",
        "fomc",
        "fed chair",
        "powell",
        "durable goods",
        "trade balance",
        "treasury",
    ]
    
    def __init__(self, api_key: str = None):
        self.api_key = api_key or os.getenv('FINNHUB_KEY')
        if not self.api_key:
            logger.warning("FINNHUB_KEY not configured - calendar service will use fallback")
        
        self.session = requests.Session()
        self.session.headers.update({'X-Finnhub-Token': self.api_key or ''})
    
    def _request_with_retry(self, endpoint: str, params: dict = None, max_retries: int = 3) -> Optional[dict]:
        """Make request with exponential backoff retry."""
        if not self.api_key:
            return None
        
        url = f"{self.BASE_URL}/{endpoint}"
        delays = [1, 2, 4]  # Exponential backoff
        
        for attempt in range(max_retries):
            try:
                response = self.session.get(url, params=params, timeout=10)
                
                if response.status_code == 200:
                    return response.json()
                elif response.status_code == 429:  # Rate limit
                    logger.warning(f"Rate limited, waiting {delays[attempt]}s...")
                    time.sleep(delays[attempt])
                    continue
                elif response.status_code == 401:
                    logger.error("Invalid Finnhub API key")
                    return None
                else:
                    logger.error(f"Finnhub API error: {response.status_code} - {response.text}")
                    
            except requests.exceptions.Timeout:
                logger.warning(f"Timeout on attempt {attempt + 1}")
                if attempt < max_retries - 1:
                    time.sleep(delays[attempt])
            except requests.exceptions.RequestException as e:
                logger.error(f"Request failed: {e}")
                if attempt < max_retries - 1:
                    time.sleep(delays[attempt])
        
        return None
    
    def _is_gold_relevant(self, event_name: str) -> bool:
        """Check if event is relevant for Gold trading."""
        event_lower = event_name.lower()
        return any(keyword in event_lower for keyword in self.GOLD_EVENTS)
    
    def _parse_impact(self, impact_value: int) -> NewsImpact:
        """Convert Finnhub impact (1-3) to our enum."""
        if impact_value >= 3:
            return NewsImpact.HIGH
        elif impact_value >= 2:
            return NewsImpact.MEDIUM
        return NewsImpact.LOW
    
    def get_calendar(self, from_date: str, to_date: str) -> List[EconomicEvent]:
        """
        Fetch economic calendar from Finnhub.
        
        Args:
            from_date: Start date (YYYY-MM-DD)
            to_date: End date (YYYY-MM-DD)
        
        Returns:
            List of EconomicEvent objects
        """
        data = self._request_with_retry(
            "calendar/economic",
            params={'from': from_date, 'to': to_date}
        )
        
        if not data or 'economicCalendar' not in data:
            logger.warning("No calendar data received from Finnhub")
            return []
        
        events = []
        for item in data['economicCalendar']:
            try:
                # Filter for US events that affect Gold
                country = item.get('country', '')
                event_name = item.get('event', '')
                
                if country != 'US':
                    continue
                
                if not self._is_gold_relevant(event_name):
                    continue
                
                # Parse timestamp
                event_time = item.get('time', '')
                if not event_time:
                    continue
                
                # Finnhub returns ISO format: "2024-01-05 13:30:00"
                dt = datetime.strptime(event_time, "%Y-%m-%d %H:%M:%S")
                dt = dt.replace(tzinfo=timezone.utc)
                timestamp = int(dt.timestamp())
                
                # Parse numeric values
                def parse_number(val):
                    if val is None or val == '':
                        return None
                    try:
                        # Remove % and K/M/B suffixes
                        s = str(val).replace('%', '').replace('K', '').replace('M', '').replace('B', '').strip()
                        return float(s) if s else None
                    except (ValueError, TypeError):
                        return None
                
                event = EconomicEvent(
                    timestamp_utc=timestamp,
                    event=event_name,
                    country=country,
                    currency="USD",
                    impact=self._parse_impact(item.get('impact', 1)),
                    forecast=parse_number(item.get('estimate')),
                    previous=parse_number(item.get('prev')),
                    actual=parse_number(item.get('actual')),
                    unit=item.get('unit', '')
                )
                events.append(event)
                
            except Exception as e:
                logger.warning(f"Failed to parse event: {e}")
                continue
        
        logger.info(f"Fetched {len(events)} Gold-relevant events from Finnhub")
        return events
    
    def health_check(self) -> bool:
        """Check if Finnhub API is accessible."""
        if not self.api_key:
            return False
        
        try:
            response = self.session.get(
                f"{self.BASE_URL}/quote",
                params={'symbol': 'AAPL'},
                timeout=5
            )
            return response.status_code == 200
        except Exception:
            return False


class EconomicCalendarService:
    """
    Main service for economic calendar data.
    
    Usage:
        service = EconomicCalendarService()
        events = service.get_upcoming_events(hours=24)
        next_high = service.get_next_high_impact_event()
    """
    
    def __init__(self):
        self.client = FinnhubClient()
        self.cache = EconomicCalendarCache()
        self._initialized = False
        logger.info("EconomicCalendarService initialized")
    
    def _ensure_data(self):
        """Ensure we have calendar data."""
        if self.cache.is_valid():
            return
        
        # Fetch next 7 days
        today = datetime.now(timezone.utc).date()
        from_date = today.strftime("%Y-%m-%d")
        to_date = (today + timedelta(days=7)).strftime("%Y-%m-%d")
        
        events = self.client.get_calendar(from_date, to_date)
        
        if events:
            self.cache.update(events)
        else:
            logger.warning("Using cached data (may be stale)")
    
    def get_upcoming_events(self, hours: int = 24) -> List[EconomicEvent]:
        """Get events in the next N hours."""
        self._ensure_data()
        
        now = datetime.now(timezone.utc)
        start_ts = int(now.timestamp())
        end_ts = int((now + timedelta(hours=hours)).timestamp())
        
        return self.cache.get_events(start_ts, end_ts)
    
    def get_next_high_impact_event(self) -> Optional[EconomicEvent]:
        """Get the next HIGH impact event."""
        self._ensure_data()
        
        now_ts = int(datetime.now(timezone.utc).timestamp())
        
        for event in self.cache.get_events(start_ts=now_ts):
            if event.impact == NewsImpact.HIGH:
                return event
        
        return None
    
    def is_in_news_window(self, minutes_before: int = 30, minutes_after: int = 15) -> dict:
        """
        Check if we're currently in a news window.
        
        Returns dict with:
        - in_window: bool
        - event: EconomicEvent or None
        - minutes_to_event: int or None (negative = event passed)
        """
        self._ensure_data()
        
        now = datetime.now(timezone.utc)
        now_ts = int(now.timestamp())
        
        # Check events in the relevant time range
        window_start = int((now - timedelta(minutes=minutes_after)).timestamp())
        window_end = int((now + timedelta(minutes=minutes_before)).timestamp())
        
        events = self.cache.get_events(window_start, window_end)
        
        # Find the closest HIGH impact event
        for event in events:
            if event.impact == NewsImpact.HIGH:
                event_time = event.datetime_utc
                diff = event_time - now
                minutes_to_event = int(diff.total_seconds() / 60)
                
                # Check if within window
                if -minutes_after <= minutes_to_event <= minutes_before:
                    return {
                        'in_window': True,
                        'event': event,
                        'minutes_to_event': minutes_to_event,
                        'is_before_event': minutes_to_event > 0
                    }
        
        # Check MEDIUM impact too
        for event in events:
            if event.impact == NewsImpact.MEDIUM:
                event_time = event.datetime_utc
                diff = event_time - now
                minutes_to_event = int(diff.total_seconds() / 60)
                
                # Tighter window for medium impact
                med_before = minutes_before // 2
                med_after = minutes_after // 2
                
                if -med_after <= minutes_to_event <= med_before:
                    return {
                        'in_window': True,
                        'event': event,
                        'minutes_to_event': minutes_to_event,
                        'is_before_event': minutes_to_event > 0
                    }
        
        return {
            'in_window': False,
            'event': None,
            'minutes_to_event': None,
            'is_before_event': None
        }
    
    def get_events_for_date(self, date: datetime) -> List[EconomicEvent]:
        """Get all events for a specific date."""
        self._ensure_data()
        
        start_of_day = datetime(date.year, date.month, date.day, tzinfo=timezone.utc)
        end_of_day = start_of_day + timedelta(days=1)
        
        return self.cache.get_events(
            int(start_of_day.timestamp()),
            int(end_of_day.timestamp())
        )
    
    def export_to_csv(self, filepath: str):
        """Export events to CSV for MQL5 consumption."""
        self._ensure_data()

        header = "timestamp_utc,event,currency,impact,forecast,previous,actual"
        lines = [header]

        for event in self.cache.events:
            lines.append(event.to_csv_row())

        with open(filepath, 'w', encoding='utf-8') as f:
            f.write('\n'.join(lines))

        logger.info(f"Exported {len(self.cache.events)} events to {filepath}")

    def export_to_news_calendar_csv(
        self,
        filepath: str,
        *,
        buffer_before_min: int = 30,
        buffer_after_min: int = 30,
    ) -> None:
        """Export events to `nautilus_gold_scalper` NewsCalendar CSV schema.

        Output columns:
          time_utc,event_name,currency,impact,buffer_before_min,buffer_after_min,forecast,previous,actual,is_valid

        Notes:
        - `time_utc` is ISO8601 with `Z` suffix.
        - `impact` is mapped to NewsCalendar ints: LOW=1, MEDIUM=2, HIGH=3.
        """
        self._ensure_data()

        header = [
            "time_utc",
            "event_name",
            "currency",
            "impact",
            "buffer_before_min",
            "buffer_after_min",
            "forecast",
            "previous",
            "actual",
            "is_valid",
        ]

        with open(filepath, 'w', encoding='utf-8', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=header)
            writer.writeheader()

            for event in self.cache.events:
                # Map string impact to NewsCalendar int impact
                if event.impact == NewsImpact.HIGH:
                    impact_int = 3
                elif event.impact == NewsImpact.MEDIUM:
                    impact_int = 2
                elif event.impact == NewsImpact.LOW:
                    impact_int = 1
                else:
                    impact_int = 0

                dt = event.datetime_utc
                time_utc = dt.replace(microsecond=0).isoformat().replace('+00:00', 'Z')

                writer.writerow({
                    "time_utc": time_utc,
                    "event_name": event.event,
                    "currency": event.currency,
                    "impact": impact_int,
                    "buffer_before_min": buffer_before_min,
                    "buffer_after_min": buffer_after_min,
                    "forecast": event.forecast if event.forecast is not None else "",
                    "previous": event.previous if event.previous is not None else "",
                    "actual": event.actual if event.actual is not None else "",
                    "is_valid": "true",
                })

        logger.info(f"Exported {len(self.cache.events)} events to NewsCalendar CSV {filepath}")
    
    def health_check(self) -> dict:
        """Check service health."""
        finnhub_ok = self.client.health_check()
        cache_valid = self.cache.is_valid()
        cache_count = len(self.cache.events)
        
        return {
            'status': 'healthy' if (finnhub_ok or cache_valid) else 'degraded',
            'finnhub_api': 'ok' if finnhub_ok else 'unavailable',
            'cache_valid': cache_valid,
            'cached_events': cache_count,
            'last_update': self.cache.last_update.isoformat() if self.cache.last_update else None
        }


# Global service instance
_calendar_service: Optional[EconomicCalendarService] = None

def get_calendar_service() -> EconomicCalendarService:
    """Get or create the calendar service singleton."""
    global _calendar_service
    if _calendar_service is None:
        _calendar_service = EconomicCalendarService()
    return _calendar_service
