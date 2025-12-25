from __future__ import annotations

import json
from pathlib import Path

import polars as pl

from nautilus_gold_scalper.scripts.ml.build_dataset_from_telemetry import _build_dataset, _read_jsonl


def _write_jsonl(path: Path, rows: list[dict[str, object]]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as f:
        for r in rows:
            f.write(json.dumps(r) + "\n")


def test_read_jsonl_roundtrip(tmp_path: Path) -> None:
    p = tmp_path / "telemetry.jsonl"
    rows: list[dict[str, object]] = [
        {"event": "ml_snapshot", "ts_event": 1, "close": 10.0, "stage": "post_selection"},
        {"event": "other", "ts": "2025-01-01T00:00:00Z"},
    ]
    _write_jsonl(p, rows)

    df = _read_jsonl(p)
    assert df.height == 2
    assert "event" in df.columns


def test_build_dataset_labels_and_sorting() -> None:
    # Intentionally unsorted ts_event; builder must sort before shifting.
    # Include OHLC to enable MAE/MFE labels.
    df = pl.DataFrame(
        [
            {
                "event": "ml_snapshot",
                "stage": "post_selection",
                "ts_event": 30,
                "open": 103.0,
                "high": 104.0,
                "low": 102.0,
                "close": 103.0,
            },
            {
                "event": "ml_snapshot",
                "stage": "post_selection",
                "ts_event": 10,
                "open": 100.0,
                "high": 101.0,
                "low": 99.0,
                "close": 100.0,
            },
            {
                "event": "ml_snapshot",
                "stage": "post_selection",
                "ts_event": 20,
                "open": 101.0,
                "high": 103.0,
                "low": 100.0,
                "close": 101.0,
            },
        ]
    )

    out = _build_dataset(df, horizon_bars=1, min_mfe=0.02, max_mae=0.01)
    assert out.height == 2  # last row dropped due to missing label

    ts = out["ts_event"].to_list()
    assert ts == sorted(ts)

    # After sorting by ts_event: closes are [100, 101, 103]
    # horizon=1 => future_close [101, 103]
    assert out["future_close"].to_list() == [101.0, 103.0]
    assert out["y_up"].to_list() == [1, 1]

    # Forward excursions (next 1 bar):
    # For close=100 (ts=10), next bar (ts=20) has high=103, low=100:
    # mfe_up = (103-100)/100 = 0.03
    # mae_long_abs = (100-100)/100 = 0.0
    assert abs(float(out["mfe_up"].to_list()[0]) - 0.03) < 1e-12
    assert out["mae_long_abs"].to_list()[0] == 0.0


def test_build_dataset_filters_stage() -> None:
    df = pl.DataFrame(
        [
            {"event": "ml_snapshot", "stage": "pre", "ts_event": 1, "close": 1.0},
            {"event": "ml_snapshot", "stage": "post_selection", "ts_event": 2, "close": 2.0},
            {"event": "ml_snapshot", "stage": "post_selection", "ts_event": 3, "close": 3.0},
        ]
    )
    out = _build_dataset(df, horizon_bars=1, min_mfe=0.02, max_mae=0.01)
    assert out.height == 1  # only post_selection rows, minus tail
    assert "y_good_long" not in out.columns  # requires OHLC excursion labels
    assert "y_good_short" not in out.columns


def test_build_dataset_requires_columns() -> None:
    df = pl.DataFrame([{"event": "ml_snapshot", "stage": "post_selection", "ts_event": 1}])
    try:
        _build_dataset(df, horizon_bars=1, min_mfe=0.02, max_mae=0.01)
        assert False, "expected ValueError"
    except ValueError as e:
        assert "Missing required columns" in str(e)
