from datetime import datetime
from decimal import Decimal
from zoneinfo import ZoneInfo

from nautilus_gold_scalper.src.risk.consistency_tracker import ConsistencyTracker


def test_consistency_blocks_above_30_percent():
    tracker = ConsistencyTracker(initial_balance=Decimal("100000"))
    now = datetime(2025, 1, 1, 12, 0, tzinfo=ZoneInfo("America/New_York"))

    # total profit 100, daily profit 100 -> 100% (way over 25% limit)
    tracker.update_profit(Decimal("100"), now)
    assert tracker.can_trade(now) is False
    # Verify daily profit is 100% of total (100/100)
    assert tracker.daily_profit == tracker.total_profit


def test_consistency_allows_under_30_percent():
    tracker = ConsistencyTracker(initial_balance=Decimal("100000"))
    now = datetime(2025, 1, 1, 12, 0, tzinfo=ZoneInfo("America/New_York"))

    # Need total > daily to keep percentage under 25%
    tracker.update_profit(Decimal("100"), now)  # total=100, daily=100 -> 100%

    # Simulate previous day's profit by adjusting total_profit manually
    # This is a test workaround - in real system, daily resets handle this
    tracker.reset_daily()  # Reset daily to 0
    tracker.total_profit = Decimal("100")  # Keep total from "yesterday"
    tracker.update_profit(Decimal("20"), now)  # daily=20, total=120 -> 16.7%
    assert tracker.can_trade(now) is True


def test_consistency_reset_daily():
    tracker = ConsistencyTracker(initial_balance=Decimal("100000"))
    now = datetime(2025, 1, 1, 12, 0, tzinfo=ZoneInfo("America/New_York"))

    tracker.update_profit(Decimal("100"), now)
    tracker.reset_daily()
    assert tracker.daily_profit == Decimal("0")
    assert tracker.can_trade(now) is True
