"""
Tests for SpreadMonitor.

Test coverage:
- Initialization and validation
- Spread tracking and statistics
- State transitions (NORMAL → ELEVATED → HIGH → EXTREME → BLOCKED)
- Size multiplier calculations
- Z-score detection
- Spread cost analysis
- Edge cases (zero spread, invalid inputs, insufficient data)
"""

from datetime import datetime

import pytest

from src.risk.spread_monitor import SpreadMonitor, SpreadState


class TestSpreadMonitorInit:
    """Test SpreadMonitor initialization."""

    def test_init_defaults(self):
        """Test initialization with default parameters."""
        monitor = SpreadMonitor(warmup_block_trading=False)

        assert monitor._symbol == "XAUUSD"
        assert monitor._history_size == 100
        assert monitor._warning_ratio == 2.0
        assert monitor._block_ratio == 5.0
        assert monitor._max_spread_pips == 50.0
        assert monitor._pip_factor == 10.0

    def test_init_custom(self):
        """Test initialization with custom parameters."""
        monitor = SpreadMonitor(
            symbol="EURUSD",
            history_size=50,
            warning_ratio=1.5,
            block_ratio=3.0,
            max_spread_pips=30.0,
            pip_factor=1.0,
        )

        assert monitor._symbol == "EURUSD"
        assert monitor._history_size == 50
        assert monitor._warning_ratio == 1.5
        assert monitor._block_ratio == 3.0
        assert monitor._max_spread_pips == 30.0
        assert monitor._pip_factor == 1.0

    def test_init_invalid_history_size(self):
        """Test initialization with invalid history size."""
        with pytest.raises(ValueError, match="Invalid history_size"):
            SpreadMonitor(history_size=0)

        with pytest.raises(ValueError, match="Invalid history_size"):
            SpreadMonitor(history_size=-10)

    def test_init_invalid_ratios(self):
        """Test initialization with invalid ratios."""
        with pytest.raises(ValueError, match="Invalid warning_ratio"):
            SpreadMonitor(warning_ratio=0)

        with pytest.raises(ValueError, match="block_ratio must be > warning_ratio"):
            SpreadMonitor(warning_ratio=5.0, block_ratio=3.0)

    def test_init_invalid_max_spread(self):
        """Test initialization with invalid max spread."""
        with pytest.raises(ValueError, match="Invalid max_spread_pips"):
            SpreadMonitor(max_spread_pips=0)

        with pytest.raises(ValueError, match="Invalid max_spread_pips"):
            SpreadMonitor(max_spread_pips=-10)


class TestSpreadMonitorUpdate:
    """Test spread updates and tracking."""

    def test_update_valid(self):
        """Test update with valid bid/ask."""
        monitor = SpreadMonitor(history_size=20, pip_factor=10.0, warmup_block_trading=False)

        # Update with spread of 3 points (0.3 pips)
        snapshot = monitor.update(bid=2650.00, ask=2650.03, now=datetime(2025, 1, 1))

        assert snapshot is not None
        assert snapshot.current_spread_points == 0.3
        assert snapshot.current_spread_pips == pytest.approx(0.03, rel=1e-4)

    def test_update_invalid_bid_ask(self):
        """Test update with invalid bid/ask."""
        monitor = SpreadMonitor(warmup_block_trading=False)

        # Zero bid
        with pytest.raises(ValueError, match="Invalid bid/ask"):
            monitor.update(bid=0, ask=2650.00, now=datetime(2025, 1, 1))

        # Negative bid
        with pytest.raises(ValueError, match="Invalid bid/ask"):
            monitor.update(bid=-100, ask=2650.00, now=datetime(2025, 1, 1))

        # Ask < bid
        with pytest.raises(ValueError, match="Ask .* < bid"):
            monitor.update(bid=2650.00, ask=2649.00, now=datetime(2025, 1, 1))

    def test_update_rate_limiting(self):
        """Test rate limiting of updates."""
        monitor = SpreadMonitor(update_interval=5, warmup_block_trading=False)  # 5 seconds

        # First update
        t0 = datetime(2025, 1, 1)
        snapshot1 = monitor.update(bid=2650.00, ask=2650.05, now=t0)

        # Second update immediately (should return cached)
        snapshot2 = monitor.update(bid=2650.00, ask=2650.10, now=t0)

        # Should be same object (cached)
        assert snapshot1 is snapshot2

    def test_update_builds_history(self):
        """Test that updates build spread history."""
        monitor = SpreadMonitor(history_size=10, update_interval=0, warmup_block_trading=False)

        # Add 10 spreads
        base = datetime(2025, 1, 1)
        for i in range(10):
            monitor.update(
                bid=2650.00,
                ask=2650.00 + (i + 1) * 0.01,
                now=base.replace(second=i),
            )

        assert len(monitor._spread_history) == 10

    def test_update_circular_buffer(self):
        """Test that history uses circular buffer."""
        monitor = SpreadMonitor(history_size=5, update_interval=0, warmup_block_trading=False)

        # Add 10 spreads (should keep last 5)
        base = datetime(2025, 1, 1)
        for i in range(10):
            monitor.update(
                bid=2650.00,
                ask=2650.00 + (i + 1) * 0.01,
                now=base.replace(second=i),
            )

        assert len(monitor._spread_history) == 5


class TestSpreadStates:
    """Test spread state transitions."""

    def test_state_collecting_data(self):
        """Test NORMAL state during data collection."""
        monitor = SpreadMonitor(history_size=20, update_interval=0, warmup_block_trading=False)

        # Add only 5 samples (need 10+)
        t = datetime(2025, 1, 1)
        for i in range(5):
            snapshot = monitor.update(bid=2650.00, ask=2650.03, now=t.replace(second=i))

        assert snapshot.status == SpreadState.NORMAL
        assert snapshot.can_trade is True
        assert snapshot.size_multiplier == 1.0
        assert "Collecting data" in snapshot.reason

    def test_state_normal(self):
        """Test NORMAL state with stable spread."""
        monitor = SpreadMonitor(
            history_size=20,
            update_interval=0,
            warning_ratio=2.0,
        )

        # Add 15 samples with consistent spread (3 points)
        t = datetime(2025, 1, 1)
        for i in range(15):
            snapshot = monitor.update(bid=2650.00, ask=2650.03, now=t.replace(second=i))

        assert snapshot.status == SpreadState.NORMAL
        assert snapshot.can_trade is True
        assert snapshot.size_multiplier == 1.0
        assert snapshot.score_adjustment == 0
        assert snapshot.reason == "Normal"

    def test_state_elevated(self):
        """Test ELEVATED state with 2x spread."""
        monitor = SpreadMonitor(
            history_size=20,
            update_interval=0,
            warning_ratio=2.0,
            block_ratio=5.0,
        )

        # Add baseline: 3 points average
        t = datetime(2025, 1, 1)
        for i in range(15):
            monitor.update(bid=2650.00, ask=2650.03, now=t.replace(second=i))

        # Add spike: 6 points (2x average)
        snapshot = monitor.update(bid=2650.00, ask=2650.06, now=t.replace(second=59))

        assert snapshot.status == SpreadState.ELEVATED
        assert snapshot.can_trade is True
        assert snapshot.size_multiplier == 0.5
        assert snapshot.score_adjustment == -15
        assert "Elevated" in snapshot.reason

    def test_state_high(self):
        """Test HIGH state with 3x spread."""
        monitor = SpreadMonitor(
            history_size=20,
            update_interval=0,
            warning_ratio=2.0,
            block_ratio=5.0,
        )

        # Add baseline: 3 points average
        t = datetime(2025, 1, 1)
        for i in range(15):
            monitor.update(bid=2650.00, ask=2650.03, now=t.replace(second=i))

        # Add spike: 9 points (3x average = 1.5 * warning_ratio)
        snapshot = monitor.update(bid=2650.00, ask=2650.09, now=t.replace(second=59))

        assert snapshot.status == SpreadState.HIGH
        assert snapshot.can_trade is True
        assert snapshot.size_multiplier == 0.25
        assert snapshot.score_adjustment == -30
        assert "High spread" in snapshot.reason

    def test_state_extreme(self):
        """Test EXTREME state with 5x+ spread."""
        monitor = SpreadMonitor(
            history_size=20,
            update_interval=0,
            warning_ratio=2.0,
            block_ratio=5.0,
        )

        # Add baseline: 3 points average
        t = datetime(2025, 1, 1)
        for i in range(15):
            monitor.update(bid=2650.00, ask=2650.03, now=t.replace(second=i))

        # Add spike: 15 points (5x average)
        snapshot = monitor.update(bid=2650.00, ask=2650.15, now=t.replace(second=59))

        assert snapshot.status == SpreadState.EXTREME
        assert snapshot.can_trade is False
        assert snapshot.size_multiplier == 0.0
        assert snapshot.score_adjustment == -50

    def test_state_blocked_absolute(self):
        """Test BLOCKED state from absolute max."""
        monitor = SpreadMonitor(
            history_size=20,
            update_interval=0,
            max_spread_pips=5.0,
            pip_factor=10.0,
        )

        # Add baseline: 3 points average
        t = datetime(2025, 1, 1)
        for i in range(15):
            monitor.update(bid=2650.00, ask=2650.03, now=t.replace(second=i))

        # Add spike: 50 points = 5 pips (at max)
        snapshot = monitor.update(bid=2650.00, ask=2650.50, now=t.replace(second=59))

        assert snapshot.status == SpreadState.BLOCKED
        assert snapshot.can_trade is False
        assert snapshot.size_multiplier == 0.0
        assert snapshot.score_adjustment == -100
        assert "exceeds max" in snapshot.reason


class TestSpreadStatistics:
    """Test spread statistics calculations."""

    def test_average_calculation(self):
        """Test average spread calculation."""
        monitor = SpreadMonitor(history_size=10, update_interval=0, pip_factor=10.0)

        # Add spreads: 1, 2, 3, ..., 10 points
        t = datetime(2025, 1, 1)
        for i in range(1, 11):
            snapshot = monitor.update(
                bid=2650.00,
                ask=2650.00 + i * 0.01,
                now=t.replace(second=i),
            )

        # Average should be 5.5 points
        assert snapshot.average_spread == pytest.approx(5.5, rel=1e-2)

    def test_std_dev_calculation(self):
        """Test standard deviation calculation."""
        monitor = SpreadMonitor(history_size=10, update_interval=0, warmup_block_trading=False)

        # Add uniform spread
        t = datetime(2025, 1, 1)
        for i in range(15):
            snapshot = monitor.update(bid=2650.00, ask=2650.03, now=t.replace(second=i))

        # Std dev should be near zero for uniform spread
        assert snapshot.std_dev < 0.1

    def test_z_score_detection(self):
        """Test Z-score anomaly detection."""
        monitor = SpreadMonitor(history_size=20, update_interval=0, warmup_block_trading=False)

        # Add baseline: 3 points average, low variance
        t = datetime(2025, 1, 1)
        for i in range(15):
            monitor.update(bid=2650.00, ask=2650.03, now=t.replace(second=i))

        # Add large spike
        snapshot = monitor.update(bid=2650.00, ask=2650.15, now=t.replace(second=59))

        # Should detect high Z-score
        assert snapshot.z_score > 3.0
        assert snapshot.status in [SpreadState.HIGH, SpreadState.ELEVATED]

    def test_min_max_tracking(self):
        """Test min/max spread tracking."""
        monitor = SpreadMonitor(history_size=20, update_interval=0, warmup_block_trading=False)

        # Add varying spreads: 1, 5, 3, 8, 2 points
        t = datetime(2025, 1, 1)
        spreads = [0.01, 0.05, 0.03, 0.08, 0.02]
        for i, spread in enumerate(spreads):
            snapshot = monitor.update(
                bid=2650.00,
                ask=2650.00 + spread,
                now=t.replace(second=i),
            )

        assert snapshot.min_spread == pytest.approx(1.0, rel=1e-2)
        assert snapshot.max_spread == pytest.approx(8.0, rel=1e-2)


class TestSpreadMethods:
    """Test SpreadMonitor methods."""

    def test_can_trade(self):
        """Test can_trade method."""
        monitor = SpreadMonitor(update_interval=0, warmup_block_trading=False)

        # No data yet - should allow
        assert monitor.can_trade() is True

        # Normal spread
        t = datetime(2025, 1, 1)
        for i in range(15):
            monitor.update(bid=2650.00, ask=2650.03, now=t.replace(second=i))
        assert monitor.can_trade() is True

        # Extreme spread (blocked)
        monitor = SpreadMonitor(update_interval=0, block_ratio=2.0, warmup_block_trading=False)
        t = datetime(2025, 1, 1)
        for i in range(15):
            monitor.update(bid=2650.00, ask=2650.03, now=t.replace(second=i))
        monitor.update(bid=2650.00, ask=2650.10, now=t.replace(second=59))  # 3.3x
        assert monitor.can_trade() is False

    def test_get_size_multiplier(self):
        """Test get_size_multiplier method."""
        monitor = SpreadMonitor(
            history_size=20, update_interval=0, warning_ratio=2.0, warmup_block_trading=False
        )

        # Normal: 1.0
        t = datetime(2025, 1, 1)
        for i in range(15):
            monitor.update(bid=2650.00, ask=2650.03, now=t.replace(second=i))
        assert monitor.get_size_multiplier() == 1.0

        # Elevated: 0.5
        monitor.update(bid=2650.00, ask=2650.06, now=t.replace(second=59))
        assert monitor.get_size_multiplier() == 0.5

    def test_get_score_adjustment(self):
        """Test get_score_adjustment method."""
        monitor = SpreadMonitor(history_size=20, update_interval=0, warmup_block_trading=False)

        # Normal: 0
        t = datetime(2025, 1, 1)
        for i in range(15):
            monitor.update(bid=2650.00, ask=2650.03, now=t.replace(second=i))
        assert monitor.get_score_adjustment() == 0

        # Elevated: negative
        monitor = SpreadMonitor(
            history_size=20, update_interval=0, warning_ratio=2.0, warmup_block_trading=False
        )
        t = datetime(2025, 1, 1)
        for i in range(15):
            monitor.update(bid=2650.00, ask=2650.03, now=t.replace(second=i))
        monitor.update(bid=2650.00, ask=2650.06, now=t.replace(second=59))
        assert monitor.get_score_adjustment() < 0

    def test_get_spread_cost_percent(self):
        """Test spread cost as % of SL."""
        monitor = SpreadMonitor(update_interval=0, pip_factor=10.0, warmup_block_trading=False)

        # Spread: 3 points = 0.3 pips
        t = datetime(2025, 1, 1)
        for i in range(15):
            monitor.update(bid=2650.00, ask=2650.03, now=t.replace(second=i))

        # SL: 50 pips
        cost_pct = monitor.get_spread_cost_percent(sl_distance=50.0)

        # 0.3 / 50 * 100 = 0.6%
        assert cost_pct == pytest.approx(0.6, rel=1e-2)

    def test_get_spread_cost_percent_invalid(self):
        """Test spread cost with invalid SL."""
        monitor = SpreadMonitor(warmup_block_trading=False)

        with pytest.raises(ValueError, match="Invalid sl_distance"):
            monitor.get_spread_cost_percent(sl_distance=0)

        with pytest.raises(ValueError, match="Invalid sl_distance"):
            monitor.get_spread_cost_percent(sl_distance=-10)

    def test_get_snapshot(self):
        """Test get_snapshot method."""
        monitor = SpreadMonitor(update_interval=0, warmup_block_trading=False)

        # No data yet
        assert monitor.get_snapshot() is None

        # After update
        snapshot = monitor.update(bid=2650.00, ask=2650.03, now=datetime(2025, 1, 1))
        assert monitor.get_snapshot() is snapshot

    def test_reset(self):
        """Test reset method."""
        monitor = SpreadMonitor(history_size=10, update_interval=0, warmup_block_trading=False)

        # Add data
        t = datetime(2025, 1, 1)
        for i in range(10):
            monitor.update(bid=2650.00, ask=2650.03, now=t.replace(second=i))

        assert len(monitor._spread_history) == 10
        assert monitor._snapshot is not None

        # Reset
        monitor.reset()

        assert len(monitor._spread_history) == 0
        assert monitor._snapshot is None
        assert monitor._sum == 0.0
        assert monitor._sum_sq == 0.0


class TestSpreadEdgeCases:
    """Test edge cases and corner scenarios."""

    def test_zero_spread(self):
        """Test with zero spread (bid == ask)."""
        monitor = SpreadMonitor(update_interval=0, warmup_block_trading=False)

        # Update with zero spread
        snapshot = monitor.update(bid=2650.00, ask=2650.00, now=datetime(2025, 1, 1))

        assert snapshot.current_spread_points == 0.0
        assert snapshot.current_spread_pips == 0.0
        assert snapshot.status == SpreadState.NORMAL

    def test_very_small_spread(self):
        """Test with very small spread."""
        monitor = SpreadMonitor(update_interval=0, pip_factor=10.0, warmup_block_trading=False)

        # 0.1 point = 0.01 pip
        snapshot = monitor.update(bid=2650.000, ask=2650.001, now=datetime(2025, 1, 1))

        assert snapshot.current_spread_pips == pytest.approx(0.001, rel=1e-4)
        assert snapshot.status == SpreadState.NORMAL

    def test_large_spread_spike(self):
        """Test handling of sudden large spread spike."""
        monitor = SpreadMonitor(
            history_size=20,
            update_interval=0,
            max_spread_pips=100.0,
            pip_factor=10.0,
        )

        # Normal spreads
        t = datetime(2025, 1, 1)
        for i in range(15):
            monitor.update(bid=2650.00, ask=2650.03, now=t.replace(second=i))

        # Huge spike: 200 points = 20 pips
        snapshot = monitor.update(bid=2650.00, ask=2652.00, now=t.replace(second=59))

        # Should be EXTREME or BLOCKED
        assert snapshot.status in [SpreadState.EXTREME, SpreadState.BLOCKED]
        assert snapshot.can_trade is False

    def test_pip_factor_conversion(self):
        """Test pip factor conversion for different instruments."""
        t = datetime(2025, 1, 1)

        # XAUUSD: 10 points = 1 pip
        monitor_xau = SpreadMonitor(pip_factor=10.0, update_interval=0, warmup_block_trading=False)
        snapshot_xau = monitor_xau.update(bid=2650.00, ask=2650.30, now=t)
        assert snapshot_xau.current_spread_pips == pytest.approx(3.0, rel=1e-2)

        # EURUSD: 1 point = 1 pip (5-digit broker)
        monitor_eur = SpreadMonitor(pip_factor=1.0, update_interval=0, warmup_block_trading=False)
        snapshot_eur = monitor_eur.update(bid=1.10000, ask=1.10030, now=t.replace(second=1))
        assert snapshot_eur.current_spread_pips == pytest.approx(0.3, rel=1e-2)


class TestSpreadRepr:
    """Test string representation."""

    def test_repr_no_data(self):
        """Test repr with no data."""
        monitor = SpreadMonitor(warmup_block_trading=False)

        repr_str = repr(monitor)
        assert "XAUUSD" in repr_str
        assert "no data" in repr_str

    def test_repr_with_data(self):
        """Test repr with data."""
        monitor = SpreadMonitor(update_interval=0, warmup_block_trading=False)

        t = datetime(2025, 1, 1)
        for i in range(15):
            monitor.update(bid=2650.00, ask=2650.03, now=t.replace(second=i))

        repr_str = repr(monitor)
        assert "XAUUSD" in repr_str
        assert "status=" in repr_str
        assert "spread=" in repr_str
        assert "can_trade=" in repr_str


# ✓ FORGE v4.0: Test scaffold complete
# - Test_Initialize: Parameter validation
# - Test_EdgeCases: Zero spread, invalid inputs, large spikes
# - Test_HappyPath: Normal spread tracking and state transitions
# - Test_ErrorConditions: Invalid bid/ask, division by zero handled
