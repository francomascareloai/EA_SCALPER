from __future__ import annotations

import polars as pl

from nautilus_gold_scalper.scripts.ml.build_dataset_from_telemetry import _build_dataset


def test_build_dataset_adds_y_good_long_short_with_ohlc() -> None:
    # Two post_selection rows + one tail row (dropped). We craft OHLC so excursions are clear.
    # Sorted closes: [100, 100, 100]
    # Next bar high=103, low=99 => mfe_up=0.03, mae_long_abs=0.01
    df = pl.DataFrame(
        [
            {
                "event": "ml_snapshot",
                "stage": "post_selection",
                "ts_event": 10,
                "open": 100.0,
                "high": 100.0,
                "low": 100.0,
                "close": 100.0,
            },
            {
                "event": "ml_snapshot",
                "stage": "post_selection",
                "ts_event": 20,
                "open": 100.0,
                "high": 103.0,
                "low": 99.0,
                "close": 100.0,
            },
            {
                "event": "ml_snapshot",
                "stage": "post_selection",
                "ts_event": 30,
                "open": 100.0,
                "high": 100.0,
                "low": 100.0,
                "close": 100.0,
            },
        ]
    )

    out = _build_dataset(df, horizon_bars=1, min_mfe=0.02, max_mae=0.015)
    assert out.height == 2
    assert "y_good_long" in out.columns
    assert "y_good_short" in out.columns

    # For ts=10 row, next bar has enough upside and MAE within max_mae => y_good_long=1.
    assert out["y_good_long"].to_list()[0] == 1

    # For a short, mfe_down = (close - future_min_low)/close = (100-99)/100 = 0.01 < 0.02 => y_good_short=0.
    assert out["y_good_short"].to_list()[0] == 0
