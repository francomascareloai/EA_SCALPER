"""
Forex Factory Calendar Scraper
==============================
Scrapes economic calendar from Forex Factory (FREE alternative to Finnhub).

Design Decisions:
1. Respect rate limits (1 request/second)
2. Cache results locally to avoid repeated scraping
3. Parse HTML with BeautifulSoup
4. Convert all times to UTC
5. Filter for USD events only (affects gold)

Usage:
    scraper = ForexFactoryScraper()
    events = scraper.get_week_events()
    events = scraper.get_month_events(year=2025, month=1)
"""

import os
import re
import json
import time
import logging
from datetime import datetime, timezone, timedelta
from typing import List, Optional, Dict
from pathlib import Path
import requests
from bs4 import BeautifulSoup

logger = logging.getLogger(__name__)


class ForexFactoryEvent:
    """Represents an economic event from Forex Factory."""
    
    def __init__(self):
        self.timestamp_utc: int = 0
        self.event: str = ""
        self.currency: str = ""
        self.impact: str = "LOW"
        self.forecast: Optional[float] = None
        self.previous: Optional[float] = None
        self.actual: Optional[float] = None
        self.status: str = "tentative"
    
    def to_dict(self) -> dict:
        return {
            'timestamp_utc': self.timestamp_utc,
            'event': self.event,
            'currency': self.currency,
            'impact': self.impact,
            'forecast': self.forecast,
            'previous': self.previous,
            'actual': self.actual,
            'status': self.status
        }
    
    def to_csv_row(self) -> str:
        return f"{self.timestamp_utc},{self.event},{self.currency},{self.impact},{self.forecast or ''},{self.previous or ''},{self.actual or ''},{self.status}"


class ForexFactoryScraper:
    """
    Scraper for Forex Factory economic calendar.
    
    Forex Factory URL format:
    - Week view: https://www.forexfactory.com/calendar?week=jan5.2025
    - Month view: https://www.forexfactory.com/calendar?month=jan.2025
    """
    
    BASE_URL = "https://www.forexfactory.com/calendar"
    
    # User agent to avoid blocking
    HEADERS = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Connection': 'keep-alive',
    }
    
    # Impact level mapping from CSS classes
    IMPACT_MAP = {
        'high': 'HIGH',
        'medium': 'MEDIUM',
        'low': 'LOW',
        'holiday': 'LOW',
        'red': 'HIGH',      # Red folder icon
        'orange': 'MEDIUM', # Orange folder icon
        'yellow': 'LOW',    # Yellow folder icon
    }
    
    # Month name to number
    MONTH_MAP = {
        'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
        'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12
    }
    
    def __init__(self, cache_dir: str = None):
        self.session = requests.Session()
        self.session.headers.update(self.HEADERS)
        self.last_request_time = 0
        self.min_request_interval = 1.0  # 1 second between requests
        
        # Cache directory
        if cache_dir:
            self.cache_dir = Path(cache_dir)
        else:
            self.cache_dir = Path(__file__).parent.parent / "data" / "ff_cache"
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        
        logger.info("ForexFactoryScraper initialized")
    
    def _rate_limit(self):
        """Ensure we don't exceed rate limits."""
        elapsed = time.time() - self.last_request_time
        if elapsed < self.min_request_interval:
            time.sleep(self.min_request_interval - elapsed)
        self.last_request_time = time.time()
    
    def _get_cached(self, cache_key: str) -> Optional[List[dict]]:
        """Get cached data if fresh (< 1 hour old)."""
        cache_file = self.cache_dir / f"{cache_key}.json"
        
        if not cache_file.exists():
            return None
        
        # Check age
        age = time.time() - cache_file.stat().st_mtime
        if age > 3600:  # 1 hour cache
            return None
        
        try:
            with open(cache_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            logger.warning(f"Cache read error: {e}")
            return None
    
    def _set_cache(self, cache_key: str, data: List[dict]):
        """Save data to cache."""
        cache_file = self.cache_dir / f"{cache_key}.json"
        try:
            with open(cache_file, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2)
        except Exception as e:
            logger.warning(f"Cache write error: {e}")
    
    def _fetch_page(self, url: str) -> Optional[str]:
        """Fetch a page with rate limiting."""
        self._rate_limit()
        
        try:
            response = self.session.get(url, timeout=30)
            
            if response.status_code == 200:
                return response.text
            else:
                logger.error(f"HTTP {response.status_code} for {url}")
                return None
                
        except requests.exceptions.RequestException as e:
            logger.error(f"Request failed: {e}")
            return None
    
    def _parse_time(self, time_str: str, date_context: datetime) -> Optional[datetime]:
        """
        Parse time string from Forex Factory.
        
        Formats:
        - "8:30am" -> 08:30
        - "All Day" -> 00:00
        - "Tentative" -> 12:00 (assume midday)
        """
        if not time_str or time_str.lower() in ['all day', 'tentative', '']:
            return date_context.replace(hour=12, minute=0, second=0, microsecond=0)
        
        try:
            # Clean up time string
            time_str = time_str.strip().lower()
            
            # Parse "8:30am" or "2:00pm" format
            match = re.match(r'(\d{1,2}):?(\d{2})?\s*(am|pm)?', time_str)
            if match:
                hour = int(match.group(1))
                minute = int(match.group(2)) if match.group(2) else 0
                ampm = match.group(3)
                
                if ampm == 'pm' and hour != 12:
                    hour += 12
                elif ampm == 'am' and hour == 12:
                    hour = 0
                
                # Forex Factory shows Eastern Time (ET)
                et_time = date_context.replace(hour=hour, minute=minute, second=0, microsecond=0)
                
                # Convert ET to UTC (+5 hours, or +4 during DST)
                # Simplified: assume +5 (EST)
                utc_time = et_time + timedelta(hours=5)
                
                return utc_time
        except Exception as e:
            logger.warning(f"Failed to parse time '{time_str}': {e}")
        
        return date_context.replace(hour=12, minute=0, second=0, microsecond=0)
    
    def _parse_number(self, value_str: str) -> Optional[float]:
        """Parse numeric value with K, M, B, % suffixes."""
        if not value_str or value_str.strip() == '':
            return None
        
        try:
            value_str = value_str.strip()
            
            # Remove common suffixes
            multiplier = 1.0
            if value_str.endswith('K'):
                multiplier = 1.0  # Keep as thousands
                value_str = value_str[:-1]
            elif value_str.endswith('M'):
                multiplier = 1000.0
                value_str = value_str[:-1]
            elif value_str.endswith('B'):
                multiplier = 1000000.0
                value_str = value_str[:-1]
            elif value_str.endswith('%'):
                value_str = value_str[:-1]
            
            # Handle negative
            negative = False
            if value_str.startswith('-'):
                negative = True
                value_str = value_str[1:]
            
            # Parse number
            value = float(value_str.replace(',', ''))
            value *= multiplier
            if negative:
                value = -value
            
            return value
            
        except (ValueError, TypeError):
            return None
    
    def _parse_impact(self, impact_element) -> str:
        """Parse impact level from HTML element."""
        if not impact_element:
            return "LOW"
        
        # Check class names
        classes = impact_element.get('class', [])
        if isinstance(classes, str):
            classes = classes.split()
        
        for cls in classes:
            cls_lower = cls.lower()
            for key, value in self.IMPACT_MAP.items():
                if key in cls_lower:
                    return value
        
        # Check title/alt attributes
        title = impact_element.get('title', '').lower()
        if 'high' in title:
            return 'HIGH'
        elif 'medium' in title:
            return 'MEDIUM'
        
        return "LOW"
    
    def _parse_calendar_page(self, html: str) -> List[ForexFactoryEvent]:
        """Parse a Forex Factory calendar page."""
        events = []
        
        try:
            soup = BeautifulSoup(html, 'html.parser')
            
            # Find calendar table
            calendar_table = soup.find('table', class_='calendar__table')
            if not calendar_table:
                logger.warning("Calendar table not found")
                return events
            
            # Track current date context
            current_date = None
            
            # Find all rows
            rows = calendar_table.find_all('tr', class_='calendar__row')
            
            for row in rows:
                try:
                    # Check for date row
                    date_cell = row.find('td', class_='calendar__date')
                    if date_cell:
                        date_span = date_cell.find('span')
                        if date_span:
                            date_text = date_span.get_text(strip=True)
                            # Parse date like "Mon Jan 6"
                            try:
                                # Add year
                                year = datetime.now().year
                                parsed = datetime.strptime(f"{date_text} {year}", "%a %b %d %Y")
                                current_date = parsed.replace(tzinfo=timezone.utc)
                            except ValueError:
                                pass
                    
                    if not current_date:
                        continue
                    
                    # Get currency
                    currency_cell = row.find('td', class_='calendar__currency')
                    if not currency_cell:
                        continue
                    
                    currency = currency_cell.get_text(strip=True).upper()
                    
                    # Only USD events (affect gold)
                    if currency != 'USD':
                        continue
                    
                    # Get event name
                    event_cell = row.find('td', class_='calendar__event')
                    if not event_cell:
                        continue
                    
                    event_name = event_cell.get_text(strip=True)
                    if not event_name:
                        continue
                    
                    # Get time
                    time_cell = row.find('td', class_='calendar__time')
                    time_str = time_cell.get_text(strip=True) if time_cell else ""
                    
                    event_time = self._parse_time(time_str, current_date)
                    if not event_time:
                        continue
                    
                    # Get impact
                    impact_cell = row.find('td', class_='calendar__impact')
                    impact_span = impact_cell.find('span') if impact_cell else None
                    impact = self._parse_impact(impact_span)
                    
                    # Get forecast/previous/actual
                    forecast_cell = row.find('td', class_='calendar__forecast')
                    previous_cell = row.find('td', class_='calendar__previous')
                    actual_cell = row.find('td', class_='calendar__actual')
                    
                    forecast = self._parse_number(forecast_cell.get_text(strip=True)) if forecast_cell else None
                    previous = self._parse_number(previous_cell.get_text(strip=True)) if previous_cell else None
                    actual = self._parse_number(actual_cell.get_text(strip=True)) if actual_cell else None
                    
                    # Create event
                    event = ForexFactoryEvent()
                    event.timestamp_utc = int(event_time.timestamp())
                    event.event = event_name
                    event.currency = currency
                    event.impact = impact
                    event.forecast = forecast
                    event.previous = previous
                    event.actual = actual
                    event.status = "confirmed" if actual is not None else "tentative"
                    
                    events.append(event)
                    
                except Exception as e:
                    logger.warning(f"Error parsing row: {e}")
                    continue
            
        except Exception as e:
            logger.error(f"Error parsing calendar page: {e}")
        
        return events
    
    def get_week_events(self, year: int = None, month: int = None, day: int = None) -> List[ForexFactoryEvent]:
        """
        Get events for a specific week.
        
        URL format: calendar?week=jan5.2025
        """
        if year is None:
            now = datetime.now()
            year = now.year
            month = now.month
            day = now.day
        
        # Format: jan5.2025
        month_name = list(self.MONTH_MAP.keys())[month - 1]
        week_param = f"{month_name}{day}.{year}"
        
        cache_key = f"week_{week_param}"
        
        # Check cache
        cached = self._get_cached(cache_key)
        if cached:
            logger.info(f"Using cached data for {week_param}")
            return [self._dict_to_event(d) for d in cached]
        
        # Fetch page
        url = f"{self.BASE_URL}?week={week_param}"
        html = self._fetch_page(url)
        
        if not html:
            return []
        
        events = self._parse_calendar_page(html)
        
        # Cache results
        self._set_cache(cache_key, [e.to_dict() for e in events])
        
        logger.info(f"Scraped {len(events)} USD events for week of {week_param}")
        return events
    
    def get_month_events(self, year: int = None, month: int = None) -> List[ForexFactoryEvent]:
        """
        Get events for a specific month.
        
        URL format: calendar?month=jan.2025
        """
        if year is None or month is None:
            now = datetime.now()
            year = year or now.year
            month = month or now.month
        
        # Format: jan.2025
        month_name = list(self.MONTH_MAP.keys())[month - 1]
        month_param = f"{month_name}.{year}"
        
        cache_key = f"month_{month_param}"
        
        # Check cache
        cached = self._get_cached(cache_key)
        if cached:
            logger.info(f"Using cached data for {month_param}")
            return [self._dict_to_event(d) for d in cached]
        
        # Fetch page
        url = f"{self.BASE_URL}?month={month_param}"
        html = self._fetch_page(url)
        
        if not html:
            return []
        
        events = self._parse_calendar_page(html)
        
        # Cache results
        self._set_cache(cache_key, [e.to_dict() for e in events])
        
        logger.info(f"Scraped {len(events)} USD events for {month_param}")
        return events
    
    def get_upcoming_events(self, days: int = 7) -> List[ForexFactoryEvent]:
        """Get events for the next N days."""
        # Get this week and next week
        events = []
        
        now = datetime.now()
        events.extend(self.get_week_events(now.year, now.month, now.day))
        
        # Get next week if needed
        next_week = now + timedelta(days=7)
        events.extend(self.get_week_events(next_week.year, next_week.month, next_week.day))
        
        # Filter by date range
        now_ts = int(now.timestamp())
        end_ts = int((now + timedelta(days=days)).timestamp())
        
        events = [e for e in events if now_ts <= e.timestamp_utc <= end_ts]
        
        # Remove duplicates and sort
        seen = set()
        unique_events = []
        for e in events:
            key = (e.timestamp_utc, e.event)
            if key not in seen:
                seen.add(key)
                unique_events.append(e)
        
        unique_events.sort(key=lambda x: x.timestamp_utc)
        
        return unique_events
    
    def _dict_to_event(self, d: dict) -> ForexFactoryEvent:
        """Convert dict to ForexFactoryEvent."""
        event = ForexFactoryEvent()
        event.timestamp_utc = d.get('timestamp_utc', 0)
        event.event = d.get('event', '')
        event.currency = d.get('currency', 'USD')
        event.impact = d.get('impact', 'LOW')
        event.forecast = d.get('forecast')
        event.previous = d.get('previous')
        event.actual = d.get('actual')
        event.status = d.get('status', 'tentative')
        return event
    
    def export_to_csv(self, events: List[ForexFactoryEvent], filepath: str):
        """Export events to CSV file."""
        header = "timestamp_utc,event,currency,impact,forecast,previous,actual,status"
        lines = [header]
        
        for event in events:
            lines.append(event.to_csv_row())
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write('\n'.join(lines))
        
        logger.info(f"Exported {len(events)} events to {filepath}")


# Singleton instance
_scraper: Optional[ForexFactoryScraper] = None

def get_forex_factory_scraper() -> ForexFactoryScraper:
    """Get or create scraper singleton."""
    global _scraper
    if _scraper is None:
        _scraper = ForexFactoryScraper()
    return _scraper
