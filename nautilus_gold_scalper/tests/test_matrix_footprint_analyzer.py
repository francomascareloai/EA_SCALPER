"""Matrix tests for FootprintAnalyzer.

These tests complement the existing footprint unit tests by running deterministic
multi-bar sequences to validate:
- timezone contract
- cumulative delta behavior
- no-crash on estimated/tick modes
"""

from __future__ import annotations

from datetime import datetime, timezone

import pytest

from src.indicators.footprint_analyzer import FootprintAnalyzer, FootprintSimulator


def test_matrix_footprint_requires_tz_aware_timestamp() -> None:
    fp = FootprintAnalyzer()

    with pytest.raises(ValueError):
        fp.analyze_bar(
            high=2001.0,
            low=1999.0,
            open_price=2000.0,
            close=2000.5,
            volume=100,
            tick_data=None,
            timestamp=datetime(2025, 1, 1, 12, 0, 0),
        )


def test_matrix_footprint_sequence_estimated_mode_monotonic_timestamp() -> None:
    fp = FootprintAnalyzer(lookback_bars=5)

    # Run several bars to populate history and cumulative delta.
    for i in range(8):
        ts = datetime(2025, 1, 1, 12, 0, i, tzinfo=timezone.utc)
        state = fp.analyze_bar(
            high=2001.0 + i * 0.1,
            low=1999.0 + i * 0.1,
            open_price=2000.0 + i * 0.1,
            close=2000.5 + i * 0.1,
            volume=100 + i,
            tick_data=None,
            timestamp=ts,
        )

        assert state.bar_timestamp == ts
        assert fp.get_cumulative_delta() == state.cumulative_delta


def test_matrix_footprint_sequence_tick_mode_deterministic_simulator() -> None:
    fp = FootprintAnalyzer(cluster_size=0.50, lookback_bars=5)

    ts = datetime(2025, 1, 1, 12, 0, 0, tzinfo=timezone.utc)
    ticks = FootprintSimulator.simulate_tick_data(
        high=2002.0,
        low=1999.0,
        open_price=2000.0,
        close=2001.5,
        volume=500,
        cluster_size=0.50,
        seed=0,
    )

    state = fp.analyze_bar(
        high=2002.0,
        low=1999.0,
        open_price=2000.0,
        close=2001.5,
        volume=500,
        tick_data=ticks,
        timestamp=ts,
    )

    assert state.total_volume > 0
    assert -100.0 <= float(state.delta_percent) <= 100.0
    assert 0.0 <= float(state.score) <= 100.0

    # is_bullish/is_bearish must be callable.
    assert isinstance(fp.is_bullish(), bool)
    assert isinstance(fp.is_bearish(), bool)
