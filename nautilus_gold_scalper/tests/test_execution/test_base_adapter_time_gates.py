from __future__ import annotations

from datetime import datetime, timezone
from zoneinfo import ZoneInfo

import pytest

from src.execution.base_adapter import BaseExecutionAdapter

ET = ZoneInfo("America/New_York")


def _dt_utc(year: int, month: int, day: int, hour: int, minute: int) -> datetime:
    dt_et = datetime(year, month, day, hour, minute, tzinfo=ET)
    return dt_et.astimezone(timezone.utc)


def test_send_order_blocks_new_entries_after_1630_et() -> None:
    a = BaseExecutionAdapter(name="TEST", symbol="XAUUSD")
    a.connect()

    ts_utc = _dt_utc(2025, 1, 15, 16, 31)
    with pytest.raises(RuntimeError, match="Apex time gate"):
        a.send_order("buy", 1.0, order_type="market", ts_utc=ts_utc)


def test_send_order_allows_reduce_only_after_1630_et() -> None:
    a = BaseExecutionAdapter(name="TEST", symbol="XAUUSD")
    a.connect()

    ts_utc = _dt_utc(2025, 1, 15, 16, 31)
    oid = a.send_order("sell", 1.0, order_type="close", ts_utc=ts_utc)
    assert oid >= 1


def test_get_time_gate_status_force_close_after_1655_et() -> None:
    a = BaseExecutionAdapter(name="TEST", symbol="XAUUSD")
    a.connect()

    ts_utc = _dt_utc(2025, 1, 15, 16, 56)
    new_allowed, force_close, reason = a.get_time_gate_status(ts_utc=ts_utc)

    assert new_allowed is False
    assert force_close is True
    assert reason == "apex_force_close_4:55PM"


def test_get_time_gate_status_cutoff_after_1659_et() -> None:
    a = BaseExecutionAdapter(name="TEST", symbol="XAUUSD")
    a.connect()

    ts_utc = _dt_utc(2025, 1, 15, 17, 0)
    new_allowed, force_close, reason = a.get_time_gate_status(ts_utc=ts_utc)

    assert new_allowed is False
    assert force_close is True
    assert reason == "apex_cutoff_4:59PM"


def test_enforce_time_gates_cancels_open_entry_orders_only() -> None:
    a = BaseExecutionAdapter(name="TEST", symbol="XAUUSD")
    a.connect()

    ts_open_utc = _dt_utc(2025, 1, 15, 16, 0)
    entry_oid = a.send_order("buy", 1.0, order_type="market", ts_utc=ts_open_utc)
    close_oid = a.send_order("sell", 1.0, order_type="close", ts_utc=ts_open_utc)

    ts_emergency_utc = _dt_utc(2025, 1, 15, 16, 56)
    new_allowed, force_close, reason = a.enforce_time_gates(ts_utc=ts_emergency_utc)

    assert new_allowed is False
    assert force_close is True
    assert reason == "apex_force_close_4:55PM"

    orders = {o["id"]: o for o in a.list_orders()}
    assert orders[entry_oid]["status"] == "CANCELLED"
    assert orders[close_oid]["status"] == "NEW"
