from __future__ import annotations

import numpy as np

from oracle.validate_session_catalogs import _parse_file_ts_event_ns, _utc_hours_from_ts_event_ns


def test_parse_file_ts_event_ns_roundtrip_example() -> None:
    # 2003-05-05 03:01:03.421Z
    ns = _parse_file_ts_event_ns("2003-05-05T03-01-03-421000000Z")
    assert isinstance(ns, int)
    # Hour should be 3 UTC.
    arr = np.array([ns], dtype=np.uint64)
    h = int(_utc_hours_from_ts_event_ns(arr)[0])
    assert h == 3

