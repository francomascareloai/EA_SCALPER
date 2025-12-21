"""Economic calendar backfill/export.

Purpose
-------
Backfill Finnhub economic calendar data over a historical range and export it
in deterministic, machine-readable formats for:
- Analysis / ML (timestamp_utc based)
- `nautilus_gold_scalper` NewsCalendar (ISO8601 time_utc based)

Security
--------
- Requires `FINNHUB_KEY` via environment variable or `--api-key`.
- Never hardcode or print API keys.

Look-ahead warning
------------------
Fields like `actual` are only known after the release. If you use `actual`
(or any post-release fields) as features before the event time, you will
introduce look-ahead bias.

Usage example
-------------
python3 -m app.services.economic_calendar_backfill \
  --start 2020-01-01 --end 2025-12-20 \
  --out-json app/data/calendar_cache.json \
  --out-raw-csv app/data/economic_calendar_2020_today.csv \
  --out-news-csv ../../nautilus_gold_scalper/data/raw/news_events_2020_today.csv
"""

from __future__ import annotations

import argparse
import json
import sys
import time
import os
from dataclasses import dataclass
from datetime import date, datetime, timedelta, timezone
from pathlib import Path
from typing import Any, Iterable, List, Optional, Sequence

import requests


class NewsImpact(str):
    HIGH = "HIGH"
    MEDIUM = "MEDIUM"
    LOW = "LOW"


@dataclass(frozen=True)
class EconomicEvent:
    timestamp_utc: int
    event: str
    country: str
    currency: str
    impact: NewsImpact
    forecast: Optional[float]
    previous: Optional[float]
    actual: Optional[float]
    unit: str


class FinnhubClient:
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

    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or os.getenv('FINNHUB_KEY')
        self.session = requests.Session()
        if self.api_key:
            self.session.headers.update({'X-Finnhub-Token': self.api_key})

    def _request_with_retry(self, endpoint: str, params: dict[str, str], max_retries: int = 3) -> Optional[dict[str, Any]]:
        if not self.api_key:
            return None

        url = f"{self.BASE_URL}/{endpoint}"
        delays = [1, 2, 4]
        for attempt in range(max_retries):
            try:
                resp = self.session.get(url, params=params, timeout=15)
                if resp.status_code == 200:
                    return resp.json()
                if resp.status_code == 429 and attempt < len(delays):
                    time.sleep(delays[attempt])
                    continue
                return None
            except requests.RequestException:
                if attempt < len(delays):
                    time.sleep(delays[attempt])
        return None

    @staticmethod
    def _is_gold_relevant(event_name: str) -> bool:
        event_lower = event_name.lower()
        return any(k in event_lower for k in FinnhubClient.GOLD_EVENTS)

    @staticmethod
    def _parse_impact(impact_value: int) -> NewsImpact:
        if impact_value >= 3:
            return NewsImpact.HIGH
        if impact_value >= 2:
            return NewsImpact.MEDIUM
        return NewsImpact.LOW

    @staticmethod
    def _parse_number(val: Any) -> Optional[float]:
        if val is None or val == '':
            return None
        try:
            s = str(val).replace('%', '').replace('K', '').replace('M', '').replace('B', '').strip()
            return float(s) if s else None
        except (ValueError, TypeError):
            return None

    def get_calendar(self, from_date: str, to_date: str) -> list[EconomicEvent]:
        data = self._request_with_retry(
            "calendar/economic",
            params={'from': from_date, 'to': to_date},
        )

        if not data or 'economicCalendar' not in data:
            return []

        events: list[EconomicEvent] = []
        for item in data.get('economicCalendar', []):
            try:
                country = str(item.get('country', '') or '')
                event_name = str(item.get('event', '') or '')
                if country != 'US':
                    continue
                if not self._is_gold_relevant(event_name):
                    continue

                event_time = item.get('time', '')
                if not event_time:
                    continue

                dt = datetime.strptime(str(event_time), "%Y-%m-%d %H:%M:%S").replace(tzinfo=timezone.utc)
                ts = int(dt.timestamp())

                events.append(EconomicEvent(
                    timestamp_utc=ts,
                    event=event_name,
                    country=country,
                    currency="USD",
                    impact=self._parse_impact(int(item.get('impact', 1) or 1)),
                    forecast=self._parse_number(item.get('estimate')),
                    previous=self._parse_number(item.get('prev')),
                    actual=self._parse_number(item.get('actual')),
                    unit=str(item.get('unit', '') or ''),
                ))
            except Exception:
                continue

        return events


@dataclass(frozen=True)
class BackfillStats:
    requested_chunks: int
    fetched_events: int
    unique_events: int
    empty_chunks: int


def _parse_yyyy_mm_dd(value: str) -> date:
    return datetime.strptime(value.strip(), "%Y-%m-%d").date()


def _daterange_chunks(start: date, end: date, chunk_days: int) -> Iterable[tuple[date, date]]:
    if chunk_days <= 0:
        raise ValueError("chunk_days must be > 0")

    cur = start
    while cur <= end:
        chunk_end = min(end, cur + timedelta(days=chunk_days - 1))
        yield cur, chunk_end
        cur = chunk_end + timedelta(days=1)


def _dedupe_sort(events: Sequence[EconomicEvent]) -> List[EconomicEvent]:
    # Finnhub can return duplicates across adjacent windows.
    # Stable key: (timestamp, event, currency)
    seen: set[tuple[int, str, str]] = set()
    out: list[EconomicEvent] = []
    for ev in events:
        key = (ev.timestamp_utc, ev.event, ev.currency)
        if key in seen:
            continue
        seen.add(key)
        out.append(ev)

    out.sort(key=lambda e: e.timestamp_utc)
    return out


def _as_cache_json(events: Sequence[EconomicEvent]) -> dict:
    return {
        'events': [
            {
                'timestamp_utc': e.timestamp_utc,
                'event': e.event,
                'country': e.country,
                'currency': e.currency,
                'impact': str(e.impact),
                'forecast': e.forecast,
                'previous': e.previous,
                'actual': e.actual,
                'unit': e.unit,
            }
            for e in events
        ],
        'last_update': datetime.now(timezone.utc).isoformat(),
        'source': 'finnhub',
    }


def _impact_to_newscalendar_int(impact: NewsImpact) -> int:
    if impact == NewsImpact.HIGH:
        return 3
    if impact == NewsImpact.MEDIUM:
        return 2
    if impact == NewsImpact.LOW:
        return 1
    return 0


def _dt_to_time_utc_z(ts_utc: int) -> str:
    dt = datetime.fromtimestamp(ts_utc, tz=timezone.utc)
    return dt.replace(microsecond=0).isoformat().replace('+00:00', 'Z')


def export_news_calendar_csv(
    events: Sequence[EconomicEvent],
    out_path: Path,
    *,
    buffer_before_min: int,
    buffer_after_min: int,
) -> None:
    import csv

    out_path.parent.mkdir(parents=True, exist_ok=True)

    fieldnames = [
        'time_utc',
        'event_name',
        'currency',
        'impact',
        'buffer_before_min',
        'buffer_after_min',
        'forecast',
        'previous',
        'actual',
        'is_valid',
    ]

    with out_path.open('w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for e in events:
            writer.writerow({
                'time_utc': _dt_to_time_utc_z(e.timestamp_utc),
                'event_name': e.event,
                'currency': e.currency,
                'impact': _impact_to_newscalendar_int(e.impact),
                'buffer_before_min': buffer_before_min,
                'buffer_after_min': buffer_after_min,
                'forecast': e.forecast if e.forecast is not None else '',
                'previous': e.previous if e.previous is not None else '',
                'actual': e.actual if e.actual is not None else '',
                'is_valid': 'true',
            })


def export_raw_csv(events: Sequence[EconomicEvent], out_path: Path) -> None:
    import csv

    out_path.parent.mkdir(parents=True, exist_ok=True)

    fieldnames = [
        'timestamp_utc',
        'event',
        'country',
        'currency',
        'impact',
        'forecast',
        'previous',
        'actual',
        'unit',
    ]

    with out_path.open('w', encoding='utf-8', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for e in events:
            writer.writerow({
                'timestamp_utc': e.timestamp_utc,
                'event': e.event,
                'country': e.country,
                'currency': e.currency,
                'impact': e.impact.value,
                'forecast': e.forecast if e.forecast is not None else '',
                'previous': e.previous if e.previous is not None else '',
                'actual': e.actual if e.actual is not None else '',
                'unit': e.unit,
            })


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description='Backfill Finnhub economic calendar and export files')
    parser.add_argument('--start', required=True, help='Start date YYYY-MM-DD')
    parser.add_argument('--end', required=True, help='End date YYYY-MM-DD (inclusive)')
    parser.add_argument('--chunk-days', type=int, default=7, help='Days per API request window')
    parser.add_argument('--sleep-seconds', type=float, default=0.0, help='Sleep between chunks (rate-limit friendly)')
    parser.add_argument('--api-key', default=None, help='Finnhub API key (prefer FINNHUB_KEY env var)')

    parser.add_argument('--out-json', default=None, help='Write cache JSON (EconomicCalendarCache schema)')
    parser.add_argument('--out-raw-csv', default=None, help='Write raw CSV for analysis/ML')
    parser.add_argument('--out-news-csv', default=None, help='Write NewsCalendar-compatible CSV')
    parser.add_argument('--buffer-before-min', type=int, default=30)
    parser.add_argument('--buffer-after-min', type=int, default=30)

    args = parser.parse_args(list(argv) if argv is not None else None)

    start = _parse_yyyy_mm_dd(args.start)
    end = _parse_yyyy_mm_dd(args.end)
    if end < start:
        raise ValueError('end must be >= start')

    client = FinnhubClient(api_key=args.api_key)

    all_events: list[EconomicEvent] = []
    requested_chunks = 0
    empty_chunks = 0

    for chunk_start, chunk_end in _daterange_chunks(start, end, args.chunk_days):
        requested_chunks += 1
        from_date = chunk_start.strftime('%Y-%m-%d')
        to_date = chunk_end.strftime('%Y-%m-%d')

        events = client.get_calendar(from_date, to_date)
        if not events:
            empty_chunks += 1
        all_events.extend(events)

        if args.sleep_seconds and args.sleep_seconds > 0:
            time.sleep(args.sleep_seconds)

    unique = _dedupe_sort(all_events)

    stats = BackfillStats(
        requested_chunks=requested_chunks,
        fetched_events=len(all_events),
        unique_events=len(unique),
        empty_chunks=empty_chunks,
    )

    # Write outputs
    if args.out_json:
        out = Path(args.out_json)
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(json.dumps(_as_cache_json(unique), indent=2), encoding='utf-8')

    if args.out_raw_csv:
        export_raw_csv(unique, Path(args.out_raw_csv))

    if args.out_news_csv:
        export_news_calendar_csv(
            unique,
            Path(args.out_news_csv),
            buffer_before_min=args.buffer_before_min,
            buffer_after_min=args.buffer_after_min,
        )

    # Print compact summary
    sys.stdout.write(
        f"chunks={stats.requested_chunks} empty_chunks={stats.empty_chunks} "
        f"fetched={stats.fetched_events} unique={stats.unique_events}\n"
    )

    if stats.unique_events == 0:
        sys.stdout.write(
            "WARNING: no events returned. Possible causes: FINNHUB_KEY missing/invalid, "
            "plan does not allow historical access, or filters are too strict (US + GOLD_EVENTS).\n"
        )

    return 0


if __name__ == '__main__':
    raise SystemExit(main())
