"""
Integration tests for ConsistencyTracker with 25% limit.
Validates P1 critical item: Apex consistency rule blocks trades at 25% (5% margin).
"""
from datetime import datetime, timedelta
from zoneinfo import ZoneInfo

import pytest

from src.risk.consistency_tracker import ConsistencyTracker


class TestConsistencyIntegration:
    """Integration tests for 25% consistency rule."""

    def test_consistency_25_percent_limit(self):
        """Test that 25% daily profit blocks further trades."""
        tracker = ConsistencyTracker(initial_balance=100000.0)
        et_tz = ZoneInfo("America/New_York")
        now = datetime(2024, 11, 1, 10, 0, 0, tzinfo=et_tz)

        # Day 1: Make $10,000 total profit (build history)
        tracker.update_profit(trade_pnl=10000.0, now=now)

        # Total profit = $10,000, Daily profit = $10,000
        # First day = 100% daily consistency (blocks immediately)
        assert not tracker.can_trade(now=now), \
            "First day with profit blocks (100% > 25% limit)"

        # Day 2: Make $2,000 profit (18% of total - should be ALLOWED)
        now_day2 = now + timedelta(days=1)
        tracker.update_profit(trade_pnl=2000.0, now=now_day2)

        # Total profit = $12,000, Daily profit = $2,000
        # Daily % = 2000 / 12000 = 16.7% < 25% limit → ALLOWED
        assert tracker.can_trade(now=now_day2), \
            "Should allow trades when daily profit 16.7% < 25% limit"

        # Day 3: Make $4,000 profit (28.6% of total - should be BLOCKED)
        now_day3 = now_day2 + timedelta(days=1)
        tracker.update_profit(trade_pnl=4000.0, now=now_day3)

        # Total profit = $16,000, Daily profit = $4,000
        # Daily % = 4000 / 16000 = 25% → BLOCKED (exactly at limit)
        assert not tracker.can_trade(now=now_day3), \
            "Should block trades when daily profit ≥25% of total profit"

        daily_pct = tracker.get_daily_profit_pct()
        print(f"[OK] 25% limit enforced: daily_profit=${tracker.daily_profit:.2f}, "
              f"total_profit=${tracker.total_profit:.2f}, "
              f"daily_pct={daily_pct:.1f}% (BLOCKED because ≥{25}%)")

    def test_consistency_below_25_percent_allows(self):
        """Test that <25% daily profit allows trading."""
        tracker = ConsistencyTracker(initial_balance=100000.0)
        et_tz = ZoneInfo("America/New_York")
        now = datetime(2024, 11, 1, 10, 0, 0, tzinfo=et_tz)

        # Day 1: Make $10,000 profit
        tracker.update_profit(trade_pnl=10000.0, now=now)

        # Day 2: Make $2,000 profit
        now_day2 = now + timedelta(days=1)
        tracker.update_profit(trade_pnl=2000.0, now=now_day2)

        # Total = $12,000, Daily = $2,000
        # Daily % = 2000 / 12000 = 16.7% < 25% limit
        # Should ALLOW trading
        assert tracker.can_trade(now=now_day2), \
            "Should allow trades when daily profit <25% of total profit"

        daily_pct = tracker.get_daily_profit_pct()
        print(f"[OK] Below 25% allowed: daily_profit=${tracker.daily_profit:.2f}, "
              f"total_profit=${tracker.total_profit:.2f}, "
              f"daily_pct={daily_pct:.1f}% (ALLOWED because <{25}%)")

    def test_consistency_exactly_25_percent_blocks(self):
        """Test that exactly 25% blocks (boundary condition)."""
        tracker = ConsistencyTracker(initial_balance=100000.0)
        et_tz = ZoneInfo("America/New_York")
        now = datetime(2024, 11, 1, 10, 0, 0, tzinfo=et_tz)

        # Day 1: Make $10,000 profit
        tracker.update_profit(trade_pnl=10000.0, now=now)

        # Day 2: Make exactly 25% of total
        # To get exactly 25%: daily / total = 0.25
        # If we add $10,000 to $30,000: T = $40,000, D = $10,000
        # 10000 / 40000 = 25% (no floating point issues)
        tracker.update_profit(trade_pnl=20000.0, now=now)  # Total now $30,000

        now_day2 = now + timedelta(days=1)
        tracker.update_profit(trade_pnl=10000.0, now=now_day2)

        # Should block at exactly 25%
        can_trade = tracker.can_trade(now=now_day2)
        daily_pct = tracker.get_daily_profit_pct()

        # Should be blocked (>= 25%)
        assert not can_trade, \
            f"Should block at exactly 25%, got daily_pct={daily_pct:.1f}%"

        print(f"[OK] 25% boundary: daily_profit=${tracker.daily_profit:.2f}, "
              f"total_profit=${tracker.total_profit:.2f}, "
              f"daily_pct={daily_pct:.1f}% (BLOCKED at boundary)")

    def test_consistency_daily_reset(self):
        """Test that daily reset allows trading again next day."""
        tracker = ConsistencyTracker(initial_balance=100000.0)
        et_tz = ZoneInfo("America/New_York")
        now = datetime(2024, 11, 1, 10, 0, 0, tzinfo=et_tz)

        # Day 1: Hit 25% limit
        tracker.update_profit(trade_pnl=30000.0, now=now)  # Total $30k
        now_same_day = now + timedelta(hours=2)
        tracker.update_profit(trade_pnl=10000.0, now=now_same_day)  # Daily $40k = 25%

        # Should be blocked
        assert not tracker.can_trade(now=now_same_day), \
            "Should be blocked after hitting 25%"

        # Day 2: Auto-reset on new day
        now_next_day = now + timedelta(days=1)

        # Just checking can_trade should trigger reset
        can_trade_next_day = tracker.can_trade(now=now_next_day)

        # Should be allowed again (daily profit reset to 0)
        assert can_trade_next_day, \
            "Should allow trading after daily reset"

        assert tracker.daily_profit == 0.0, \
            "Daily profit should reset to 0 on new day"

        assert float(tracker.total_profit) == 40000.0, \
            "Total profit should persist across days"

        print(f"[OK] Daily reset: day 2 can_trade={can_trade_next_day}, "
              f"daily_profit=${tracker.daily_profit:.2f}, "
              f"total_profit=${tracker.total_profit:.2f}")

    def test_consistency_apex_safety_margin(self):
        """Test that 25% limit provides 5% safety margin below Apex 30%."""
        # Apex rule: Daily profit > 30% of total → account termination
        # Our rule: Daily profit > 25% of total → block trades
        # Safety margin: 30% - 25% = 5%

        tracker = ConsistencyTracker(initial_balance=100000.0)
        et_tz = ZoneInfo("America/New_York")
        now = datetime(2024, 11, 1, 10, 0, 0, tzinfo=et_tz)

        # Day 1: $30,000 profit
        tracker.update_profit(trade_pnl=30000.0, now=now)

        # Day 2: $10,000 profit (25% of total)
        now_day2 = now + timedelta(days=1)
        tracker.update_profit(trade_pnl=10000.0, now=now_day2)

        daily_pct = tracker.get_daily_profit_pct()

        # Should be blocked at 25%
        assert not tracker.can_trade(now=now_day2), \
            "Should block at 25%"

        # Calculate margin to Apex 30% limit
        margin_to_apex = 30.0 - daily_pct

        assert margin_to_apex >= 4.0, \
            f"Should have at least 4% margin to Apex 30%, got {margin_to_apex:.1f}%"

        # If we made $2,000 more ($12,000 total daily):
        # 12000 / 42000 = 28.57% (still below Apex 30%)
        # This validates the 5% buffer works

        print(f"[OK] Safety margin: our_limit=25%, apex_limit=30%, "
              f"current={daily_pct:.1f}%, "
              f"margin_to_apex={margin_to_apex:.1f}% "
              f"(PROTECTED with 5% buffer)")


if __name__ == "__main__":
    pytest.main([__file__, "-v", "-s"])
