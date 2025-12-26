"""
Tests for DrawdownTracker.
"""

from datetime import datetime, timezone

import pytest

from src.risk.drawdown_tracker import (
    DrawdownSeverity,
    DrawdownTracker,
)


class TestDrawdownTracker:
    """Test suite for DrawdownTracker."""

    def test_initial_state(self):
        """Initial state should show no drawdown."""
        dt = DrawdownTracker(initial_equity=100_000)

        analysis = dt.get_analysis()

        assert analysis.current_drawdown_abs == 0
        assert analysis.current_drawdown_pct == 0
        assert analysis.is_in_drawdown is False
        assert analysis.severity == DrawdownSeverity.NONE

    def test_drawdown_detection(self):
        """Should detect when entering drawdown."""
        dt = DrawdownTracker(initial_equity=100_000)

        # Simulate profit then loss
        dt.update(105_000)  # Peak
        analysis = dt.update(102_000)  # Drawdown

        assert analysis.is_in_drawdown is True
        assert analysis.current_drawdown_abs == 3_000
        assert analysis.current_drawdown_pct == pytest.approx(2.857, rel=0.01)
        assert analysis.peak_equity == 105_000

    def test_drawdown_recovery(self):
        """Should detect recovery from drawdown."""
        dt = DrawdownTracker(initial_equity=100_000)

        dt.update(105_000)  # Peak
        dt.update(102_000)  # Drawdown
        analysis = dt.update(106_000)  # Recovery + new high

        assert analysis.is_in_drawdown is False
        assert analysis.peak_equity == 106_000
        assert analysis.drawdown_events_count == 1

    def test_max_drawdown_tracking(self):
        """Should track maximum drawdown."""
        dt = DrawdownTracker(initial_equity=100_000)

        dt.update(110_000)  # Peak 1
        dt.update(105_000)  # DD 1: ~4.5%
        dt.update(112_000)  # Peak 2
        dt.update(100_000)  # DD 2: ~10.7%
        analysis = dt.update(115_000)  # Recovery

        # Max DD should be the 10.7% one
        assert analysis.max_drawdown_pct >= 10

    def test_losing_streak_tracking(self):
        """Should track losing streaks."""
        dt = DrawdownTracker(initial_equity=100_000)

        # Simulate 4 losses
        dt.update(99_000, pnl=-1000)
        dt.update(98_000, pnl=-1000)
        dt.update(97_000, pnl=-1000)
        analysis = dt.update(96_000, pnl=-1000)

        assert analysis.current_losing_streak == 4
        assert analysis.max_losing_streak == 4

    def test_winning_streak_tracking(self):
        """Should track winning streaks."""
        dt = DrawdownTracker(initial_equity=100_000)

        # Simulate 3 wins
        dt.update(101_000, pnl=1000)
        dt.update(102_000, pnl=1000)
        analysis = dt.update(103_000, pnl=1000)

        assert analysis.current_winning_streak == 3
        assert analysis.max_winning_streak == 3

    def test_streak_reset_on_opposite(self):
        """Streaks should reset when opposite outcome occurs."""
        dt = DrawdownTracker(initial_equity=100_000)

        # Build winning streak
        dt.update(101_000, pnl=1000)
        dt.update(102_000, pnl=1000)

        # One loss resets
        analysis = dt.update(101_500, pnl=-500)

        assert analysis.current_winning_streak == 0
        assert analysis.current_losing_streak == 1
        assert analysis.max_winning_streak == 2

    def test_severity_levels(self):
        """Should correctly classify severity."""
        dt = DrawdownTracker(initial_equity=100_000)

        # Minor < 2%
        dt.update(100_000)
        analysis = dt.update(99_000)  # 1%
        assert analysis.severity == DrawdownSeverity.MINOR

        # Moderate 2-5%
        dt.update(100_000)
        analysis = dt.update(97_000)  # 3%
        assert analysis.severity == DrawdownSeverity.MODERATE

        # Significant 5-8%
        dt.update(100_000)
        analysis = dt.update(93_500)  # 6.5%
        assert analysis.severity == DrawdownSeverity.SIGNIFICANT

        # Severe 8-10%
        dt.update(100_000)
        analysis = dt.update(91_000)  # 9%
        assert analysis.severity == DrawdownSeverity.SEVERE

        # Critical > 10%
        dt.update(100_000)
        analysis = dt.update(88_000)  # 12%
        assert analysis.severity == DrawdownSeverity.CRITICAL

    def test_should_reduce_size(self):
        """Should recommend size reduction during losing streak."""
        dt = DrawdownTracker(initial_equity=100_000)

        # 2 losses - not yet
        dt.update(99_000, pnl=-1000)
        dt.update(98_000, pnl=-1000)
        assert dt.should_reduce_size(threshold_streak=3) is False

        # 3 losses - yes
        dt.update(97_000, pnl=-1000)
        assert dt.should_reduce_size(threshold_streak=3) is True

    def test_size_reduction_factor(self):
        """Should calculate correct reduction factor."""
        dt = DrawdownTracker(initial_equity=100_000)

        # No streak/DD = 1.0
        assert dt.get_size_reduction_factor() == 1.0

        # After 2 losses
        dt.update(99_000, pnl=-1000)
        dt.update(98_000, pnl=-1000)
        assert dt.get_size_reduction_factor() == 0.85  # -15%

        # After 4 losses
        dt.update(97_000, pnl=-1000)
        dt.update(96_000, pnl=-1000)
        assert dt.get_size_reduction_factor() == 0.40  # -60%

    def test_recovery_factor(self):
        """Should calculate recovery factor correctly."""
        dt = DrawdownTracker(initial_equity=100_000)

        # Profit of $10,000 with max DD of $5,000
        dt.update(110_000)  # Peak
        dt.update(105_000)  # DD = $5,000
        analysis = dt.update(115_000)  # Profit = $15,000

        # Recovery factor = profit / max_dd = 15,000 / 5,000 = 3.0
        assert analysis.recovery_factor >= 2.0

    def test_underwater_stats(self):
        """Should track underwater statistics."""
        dt = DrawdownTracker(initial_equity=100_000)

        # Create a drawdown period
        dt.update(105_000)  # Peak
        dt.update(102_000)  # DD start
        dt.update(101_000)
        dt.update(100_500)
        dt.update(106_000)  # Recovery

        stats = dt.get_underwater_stats()

        assert stats["total_events"] >= 1
        assert stats["avg_duration_bars"] > 0

    def test_equity_curve(self):
        """Should return equity history."""
        dt = DrawdownTracker(initial_equity=100_000)

        dt.update(101_000)
        dt.update(102_000)
        dt.update(101_500)

        curve = dt.get_equity_curve()

        assert len(curve) == 3
        assert curve == [101_000, 102_000, 101_500]

    def test_daily_reset_uses_day_boundary_tz(self):
        dt = DrawdownTracker(initial_equity=100_000, day_boundary_tz="America/New_York")

        # 2025-01-01 00:30 UTC is still 2024-12-31 in ET.
        dt.update(99_000, now=datetime(2025, 1, 1, 0, 30, tzinfo=timezone.utc))
        before = dt.get_daily_drawdown_pct()
        assert before > 0

        # 2025-01-01 04:59 UTC is still 2024-12-31 in ET (23:59 ET).
        dt.update(98_000, now=datetime(2025, 1, 1, 4, 59, tzinfo=timezone.utc))
        assert dt.get_daily_drawdown_pct() > 0

        # 2025-01-01 05:01 UTC is 00:01 ET -> new ET day, daily DD should reset.
        dt.update(98_000, now=datetime(2025, 1, 1, 5, 1, tzinfo=timezone.utc))
        assert dt.get_daily_drawdown_pct() == 0.0
