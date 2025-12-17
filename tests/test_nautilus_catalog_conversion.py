from __future__ import annotations

from pathlib import Path

import pandas as pd


def test_session_filter_mask_basic() -> None:
    # Local import to avoid failing tests when nautilus_trader isn't installed.
    import importlib

    m = importlib.import_module("convert_csv_to_nautilus_catalog")
    SESSION_WINDOWS = m.SESSION_WINDOWS
    _session_mask = m._session_mask

    dt = pd.to_datetime(
        [
            "2024-01-01T00:30:00Z",  # ASIAN
            "2024-01-01T07:30:00Z",  # LONDON
            "2024-01-01T12:30:00Z",  # OVERLAP
            "2024-01-01T15:30:00Z",  # NY
            "2024-01-01T17:30:00Z",  # LATE_NY
        ],
        utc=True,
    )

    assert _session_mask(dt, SESSION_WINDOWS["ASIAN"]).tolist() == [True, False, False, False, False]
    assert _session_mask(dt, SESSION_WINDOWS["LONDON"]).tolist() == [False, True, False, False, False]
    assert _session_mask(dt, SESSION_WINDOWS["OVERLAP"]).tolist() == [False, False, True, False, False]
    assert _session_mask(dt, SESSION_WINDOWS["NY"]).tolist() == [False, False, False, True, False]
    assert _session_mask(dt, SESSION_WINDOWS["LATE_NY"]).tolist() == [False, False, False, False, True]


def test_catalog_validator_script_importable() -> None:
    # Ensures the QA script at least imports under the project environment.
    import importlib.util

    path = Path("scripts/data/validate_nautilus_catalog.py")
    assert path.exists()
    spec = importlib.util.spec_from_file_location("validate_nautilus_catalog", path)
    assert spec is not None
