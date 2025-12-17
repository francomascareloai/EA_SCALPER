from __future__ import annotations

from datetime import datetime, timezone

import pyarrow as pa
import pyarrow.compute as pc

from data.slice_catalog_by_session import (
    SESSION_WINDOWS,
    _format_ts_event_ns,
    _session_mask_from_hours,
)


def _ts_ns_for_hour(hour: int) -> int:
    dt = datetime(2024, 1, 2, hour, 0, 0, tzinfo=timezone.utc)
    return int(dt.timestamp() * 1_000_000_000)


def test_format_ts_event_ns_has_nanos_and_z() -> None:
    ts = _ts_ns_for_hour(15) + 123_456_789
    s = _format_ts_event_ns(ts)
    assert s.endswith("Z")
    assert "T15-00-00-" in s
    assert s.split("-")[-1] == "123456789Z"


def test_session_masks_partition_hours() -> None:
    # One sample tick for each UTC hour.
    ts_events = pa.array([_ts_ns_for_hour(h) for h in range(24)], type=pa.uint64())

    covered = pa.array([False] * 24)
    for session in SESSION_WINDOWS.values():
        ts = pc.cast(pc.cast(ts_events, pa.int64()), pa.timestamp("ns"))
        hours = pc.hour(ts)
        mask = _session_mask_from_hours(hours, session)
        # Ensure the mask selects at least one hour.
        assert pc.sum(pc.cast(mask, pa.int64())).as_py() > 0
        covered = pc.or_(covered, mask)  # type: ignore[assignment]

    # All hours must be covered by the 6 sessions.
    assert pc.all(covered).as_py() is True


def test_session_boundaries() -> None:
    ts_events = pa.array(
        [
            _ts_ns_for_hour(6),  # ASIAN last hour
            _ts_ns_for_hour(7),  # LONDON start
            _ts_ns_for_hour(11),  # LONDON last hour
            _ts_ns_for_hour(12),  # OVERLAP start
            _ts_ns_for_hour(14),  # OVERLAP last hour
            _ts_ns_for_hour(15),  # NY start
            _ts_ns_for_hour(16),  # NY last hour
            _ts_ns_for_hour(17),  # LATE_NY start
            _ts_ns_for_hour(20),  # LATE_NY last hour
            _ts_ns_for_hour(21),  # EVENING start
            _ts_ns_for_hour(23),  # EVENING last hour
        ],
        type=pa.uint64(),
    )

    def sel(session_name: str) -> list[bool]:
        ts = pc.cast(pc.cast(ts_events, pa.int64()), pa.timestamp("ns"))
        hours = pc.hour(ts)
        mask = _session_mask_from_hours(hours, SESSION_WINDOWS[session_name])
        return list(mask.to_pylist())

    assert sel("ASIAN")[0] is True
    assert sel("LONDON")[1] is True
    assert sel("LONDON")[2] is True
    assert sel("OVERLAP")[3] is True
    assert sel("OVERLAP")[4] is True
    assert sel("NY")[5] is True
    assert sel("NY")[6] is True
    assert sel("LATE_NY")[7] is True
    assert sel("LATE_NY")[8] is True
    assert sel("EVENING")[9] is True
    assert sel("EVENING")[10] is True
