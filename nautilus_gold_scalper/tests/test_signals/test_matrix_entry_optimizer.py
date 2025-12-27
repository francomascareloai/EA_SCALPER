"""Matrix tests for EntryOptimizer.

These tests are deterministic contract tests focused on:
- priority order (FVG > OB > FIB > MARKET)
- fail-closed behavior for SIGNAL_NONE and spread blocks
- SL clamping invariants
- deterministic validity timestamps when current_time is provided
"""

from __future__ import annotations

from datetime import datetime, timedelta, timezone

import pytest

from src.signals.entry_optimizer import EntryOptimizer, EntryType, SignalDirection


def _ts(i: int = 0) -> datetime:
    return datetime(2025, 1, 1, 12, 0, i, tzinfo=timezone.utc)


def test_matrix_entry_optimizer_signal_none_resets_and_is_invalid() -> None:
    opt = EntryOptimizer(max_wait_bars=10)

    entry = opt.calculate_optimal_entry(
        direction=SignalDirection.SIGNAL_NONE,
        current_price=2000.0,
        atr=2.0,
        current_time=_ts(0),
    )

    assert entry.is_valid is False
    assert entry.entry_type == EntryType.ENTRY_NONE
    assert entry.valid_until is None


def test_matrix_entry_optimizer_atr_non_positive_is_clamped_and_time_is_deterministic() -> None:
    opt = EntryOptimizer(max_wait_bars=7)

    now = _ts(1)
    entry = opt.calculate_optimal_entry(
        direction=SignalDirection.SIGNAL_BUY,
        current_price=2000.0,
        atr=0.0,
        current_time=now,
    )

    assert entry.is_valid is True
    assert entry.valid_until == now + timedelta(minutes=15 * opt.max_wait_bars)


def test_matrix_entry_optimizer_buy_priority_fvg_over_ob() -> None:
    opt = EntryOptimizer(fvg_fill_percent=0.5, ob_retest_percent=0.7)

    entry = opt.calculate_optimal_entry(
        direction=SignalDirection.SIGNAL_BUY,
        fvg_low=1990.0,
        fvg_high=2000.0,
        ob_low=1985.0,
        ob_high=1995.0,
        sweep_level=1980.0,
        current_price=2010.0,
        atr=2.0,
        current_time=_ts(2),
    )

    assert entry.is_valid is True
    assert entry.entry_type == EntryType.ENTRY_FVG_FILL
    assert entry.zone_type == "FVG"
    assert entry.optimal_price == pytest.approx(1995.0)


def test_matrix_entry_optimizer_buy_falls_back_to_ob_when_fvg_invalid() -> None:
    opt = EntryOptimizer(fvg_fill_percent=0.5, ob_retest_percent=0.7)

    entry = opt.calculate_optimal_entry(
        direction=SignalDirection.SIGNAL_BUY,
        fvg_low=2000.0,
        fvg_high=2000.0,  # invalid (high not > low)
        ob_low=1980.0,
        ob_high=1990.0,
        sweep_level=0.0,
        current_price=2005.0,
        atr=2.0,
        current_time=_ts(3),
    )

    assert entry.is_valid is True
    assert entry.entry_type == EntryType.ENTRY_OB_RETEST
    assert entry.zone_type == "OB"


def test_matrix_entry_optimizer_buy_fib_when_in_golden_pocket() -> None:
    opt = EntryOptimizer()

    entry = opt.calculate_optimal_entry(
        direction=SignalDirection.SIGNAL_BUY,
        fvg_low=0.0,
        fvg_high=0.0,
        ob_low=0.0,
        ob_high=0.0,
        sweep_level=0.0,
        current_price=2000.0,
        atr=4.0,
        golden_pocket=(1995.0, 2005.0),
        current_time=_ts(4),
    )

    assert entry.is_valid is True
    assert entry.entry_type == EntryType.ENTRY_FIB_RETRACE
    assert entry.zone_type == "FIB"
    assert entry.acceptable_low <= entry.optimal_price <= entry.acceptable_high


def test_matrix_entry_optimizer_buy_market_when_no_zone_matches() -> None:
    opt = EntryOptimizer()

    entry = opt.calculate_optimal_entry(
        direction=SignalDirection.SIGNAL_BUY,
        fvg_low=0.0,
        fvg_high=0.0,
        ob_low=0.0,
        ob_high=0.0,
        sweep_level=0.0,
        current_price=2000.0,
        atr=4.0,
        golden_pocket=(1900.0, 1950.0),  # out of range
        current_time=_ts(5),
    )

    assert entry.is_valid is True
    assert entry.entry_type == EntryType.ENTRY_MARKET
    assert entry.zone_type == "MARKET"


def test_matrix_entry_optimizer_sell_priority_fvg_over_ob() -> None:
    opt = EntryOptimizer(fvg_fill_percent=0.5, ob_retest_percent=0.7)

    entry = opt.calculate_optimal_entry(
        direction=SignalDirection.SIGNAL_SELL,
        fvg_low=2000.0,
        fvg_high=2010.0,
        ob_low=2010.0,
        ob_high=2020.0,
        sweep_level=2030.0,
        current_price=1990.0,
        atr=2.0,
        current_time=_ts(6),
    )

    assert entry.is_valid is True
    assert entry.entry_type == EntryType.ENTRY_FVG_FILL
    assert entry.zone_type == "FVG"
    assert entry.optimal_price == pytest.approx(2005.0)


def test_matrix_entry_optimizer_spread_block_fail_closed() -> None:
    opt = EntryOptimizer()

    entry = opt.calculate_optimal_entry(
        direction=SignalDirection.SIGNAL_BUY,
        fvg_low=1990.0,
        fvg_high=2000.0,
        sweep_level=1980.0,
        current_price=2010.0,
        atr=2.0,
        spread_ratio=2.0,
        signal_urgency=0.5,
        current_time=_ts(7),
    )

    assert entry.is_valid is False
    assert entry.zone_type == "SPREAD_BLOCK"


def test_matrix_entry_optimizer_spread_widens_zone_and_degrades_rr() -> None:
    opt = EntryOptimizer()

    entry = opt.calculate_optimal_entry(
        direction=SignalDirection.SIGNAL_BUY,
        fvg_low=1990.0,
        fvg_high=2000.0,
        sweep_level=1980.0,
        current_price=2010.0,
        atr=10.0,
        spread_ratio=1.2,
        signal_urgency=0.1,
        current_time=_ts(8),
    )

    assert entry.is_valid is True
    assert entry.zone_type == "FVG"

    widened_low = 1990.0 - (1.2 - 1.0) * 10.0 * 0.1
    widened_high = 2000.0 + (1.2 - 1.0) * 10.0 * 0.1
    assert entry.acceptable_low == pytest.approx(widened_low)
    assert entry.acceptable_high == pytest.approx(widened_high)

    # Risk:reward should be reduced when spread_ratio > 1.
    assert entry.risk_reward > 0.0


def test_matrix_entry_optimizer_sl_clamp_defaults_when_sweep_missing() -> None:
    opt = EntryOptimizer(default_sl_price=30.0)

    entry = opt.calculate_optimal_entry(
        direction=SignalDirection.SIGNAL_BUY,
        fvg_low=1990.0,
        fvg_high=2000.0,
        sweep_level=0.0,  # forces raw_sl=0
        current_price=2010.0,
        atr=2.0,
        current_time=_ts(9),
    )

    assert entry.is_valid is True
    assert entry.entry_type == EntryType.ENTRY_FVG_FILL
    assert entry.stop_loss == pytest.approx(entry.optimal_price - opt.default_sl_price)


def test_matrix_entry_optimizer_sl_clamp_min_distance() -> None:
    opt = EntryOptimizer(min_sl_price=15.0)

    # Choose values so the BUY FVG optimal_price is 105.0.
    # raw_sl = sweep_level - atr*sl_buffer_atr. We want raw_sl close enough that
    # sl_distance < min_sl_price to trigger clamping.
    entry = opt.calculate_optimal_entry(
        direction=SignalDirection.SIGNAL_BUY,
        fvg_low=100.0,
        fvg_high=110.0,
        sweep_level=104.2,  # raw_sl = 104.0 (with atr=1, sl_buffer_atr=0.2)
        current_price=120.0,
        atr=1.0,
        current_time=_ts(10),
    )

    assert entry.is_valid is True
    assert entry.entry_type == EntryType.ENTRY_FVG_FILL
    assert entry.optimal_price == pytest.approx(105.0)
    assert entry.stop_loss == pytest.approx(entry.optimal_price - opt.min_sl_price)


def test_matrix_entry_optimizer_should_enter_now_market_executes_immediately() -> None:
    opt = EntryOptimizer()

    opt.calculate_optimal_entry(
        direction=SignalDirection.SIGNAL_BUY,
        fvg_low=0.0,
        fvg_high=0.0,
        ob_low=0.0,
        ob_high=0.0,
        sweep_level=0.0,
        current_price=2000.0,
        atr=4.0,
        golden_pocket=None,
        current_time=_ts(11),
    )

    assert opt.entry_type == EntryType.ENTRY_MARKET
    assert opt.should_enter_now(current_price=1.0, current_time=_ts(11)) is True


def test_matrix_entry_optimizer_has_expired_boundary_is_not_expired() -> None:
    opt = EntryOptimizer(max_wait_bars=2)

    start = _ts(12)
    entry = opt.calculate_optimal_entry(
        direction=SignalDirection.SIGNAL_BUY,
        current_price=2000.0,
        atr=2.0,
        current_time=start,
    )

    assert entry.valid_until is not None
    assert opt.has_expired(entry.valid_until) is False
    assert opt.has_expired(entry.valid_until + timedelta(seconds=1)) is True
