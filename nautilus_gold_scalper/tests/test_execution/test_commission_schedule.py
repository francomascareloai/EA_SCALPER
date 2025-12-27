from __future__ import annotations

import logging

import pytest
from nautilus_gold_scalper.src.execution.commission_schedule import commission_per_side_usd


def test_apex_xauusd_falls_back_to_zero_commission(caplog: pytest.LogCaptureFixture) -> None:
    caplog.set_level(logging.WARNING)

    value = commission_per_side_usd(profile="apex", product="xauusd", gateway="tradovate")
    assert value == 0.0

    # Ensure we log a warning so the fallback is visible in backtest runs.
    assert any(
        "Fallback: Apex commission requested for product='xauusd'" in record.message
        for record in caplog.records
    )


def test_apex_mgc_commission_is_nonzero() -> None:
    value = commission_per_side_usd(profile="apex", product="mgc", gateway="tradovate")
    assert value > 0.0


def test_ftmo_schedule_is_intentionally_undefined() -> None:
    with pytest.raises(NotImplementedError):
        commission_per_side_usd(profile="ftmo", product="xauusd", gateway="tradovate")
