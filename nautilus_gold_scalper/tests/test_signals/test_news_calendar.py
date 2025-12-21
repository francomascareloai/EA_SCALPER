import os
import sys
from datetime import datetime, timezone
from pathlib import Path

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", "..")))

from nautilus_gold_scalper.src.signals.news_calendar import NewsCalendar, NewsImpact


def test_news_calendar_allows_historical_window_from_csv(tmp_path: Path) -> None:
    # Create a minimal NewsCalendar CSV with a single HIGH impact event.
    csv_path = tmp_path / "news.csv"
    csv_path.write_text(
        "time_utc,event_name,currency,impact,buffer_before_min,buffer_after_min\n"
        "2024-01-05T13:30:00Z,Nonfarm Payrolls,USD,3,30,30\n",
        encoding="utf-8",
    )

    cal = NewsCalendar(events_path=csv_path)

    # 10 minutes BEFORE event => in window
    now_before = datetime(2024, 1, 5, 13, 20, tzinfo=timezone.utc)
    w1 = cal.check_news_window(now=now_before)
    assert w1.in_window
    assert w1.event is not None

    # 10 minutes AFTER event => in window
    now_after = datetime(2024, 1, 5, 13, 40, tzinfo=timezone.utc)
    w2 = cal.check_news_window(now=now_after)
    assert w2.in_window
    assert w2.event is not None


def test_news_calendar_returns_normal_outside_window(tmp_path: Path) -> None:
    csv_path = tmp_path / "news.csv"
    csv_path.write_text(
        "time_utc,event_name,currency,impact,buffer_before_min,buffer_after_min\n"
        "2024-01-05T13:30:00Z,Nonfarm Payrolls,USD,3,30,30\n",
        encoding="utf-8",
    )

    cal = NewsCalendar(events_path=csv_path)

    # Far away => no window
    now_far = datetime(2024, 1, 5, 10, 0, tzinfo=timezone.utc)
    w = cal.check_news_window(now=now_far)
    assert not w.in_window
    assert w.event is None


def test_news_calendar_parses_epoch_and_string_impact_with_comments(tmp_path: Path) -> None:
    csv_path = tmp_path / "hub_style.csv"

    event_time = datetime(2020, 1, 3, 13, 30, tzinfo=timezone.utc)
    epoch_utc = int(event_time.timestamp())

    csv_path.write_text(
        "timestamp_utc,event,currency,impact,forecast,previous,actual,status\n"
        "# comment line should be ignored\n"
        "\n"
        f"{epoch_utc},Non-Farm Payrolls,USD,HIGH,160,266,225,confirmed\n",
        encoding="utf-8",
    )

    cal = NewsCalendar(events_path=csv_path)

    now_before = datetime(2020, 1, 3, 13, 20, tzinfo=timezone.utc)
    w = cal.check_news_window(now=now_before)
    assert w.in_window
    assert w.event is not None
    assert w.event.event_name == "Non-Farm Payrolls"
    assert w.event.impact == NewsImpact.HIGH
