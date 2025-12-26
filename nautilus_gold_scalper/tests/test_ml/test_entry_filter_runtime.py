from __future__ import annotations

import json
from pathlib import Path

import numpy as np


def _train_and_export(tmp_path: Path) -> Path:
    import polars as pl
    from nautilus_gold_scalper.scripts.ml.export_onnx import export_filter_onnx
    from nautilus_gold_scalper.scripts.ml.train_filter import train_filter_model

    # Minimal dataset compatible with train_filter_model
    n_rows = 6000
    rng = np.random.default_rng(1)
    x0 = rng.normal(size=n_rows)
    x1 = rng.normal(size=n_rows)
    y = (x0 + 0.3 * x1 + rng.normal(scale=0.5, size=n_rows) > 0).astype(int)

    rows: list[dict[str, object]] = []
    for i in range(n_rows):
        rows.append(
            {
                "event": "ml_snapshot",
                "stage": "post_selection",
                "ts_event": i + 1,
                "close": float(100 + i),
                "y_good_long": int(y[i]),
                "open": float(100 + i),
                "high": float(101 + i),
                "low": float(99 + i),
                "atr": float(abs(x0[i])),
                "atr_percentile": float(abs(x1[i]) * 10.0),
                "spread_points": 1.0,
                "selected_score": 70.0,
                "execution_threshold": 60.0,
                "f0": float(x0[i]),
                "f1": float(x1[i]),
            }
        )

    df = pl.DataFrame(rows)
    dataset_path = tmp_path / "dataset.parquet"
    df.write_parquet(dataset_path)

    out_dir = tmp_path / "out"
    train_res = train_filter_model(
        dataset_path,
        out_dir=out_dir,
        target="y_good_long",
        test_size=0.2,
        random_state=42,
        min_rows=5000,
    )

    onnx_out = out_dir / "filter_y_good_long.onnx"
    export_filter_onnx(
        train_res.model_path,
        features_path=train_res.features_path,
        out_path=onnx_out,
        opset=12,
        verify=True,
        allow_unsafe_pickle=True,
    )

    return out_dir


def test_entry_filter_fail_open_missing_model(tmp_path: Path) -> None:
    from nautilus_gold_scalper.src.ml.entry_filter import OnnxEntryFilter

    f = OnnxEntryFilter(tmp_path / "does-not-exist.onnx")
    f.initialize()

    d = f.predict({"close": 100.0}, direction="long", min_p_edge=0.99, mode="gate")
    assert d.should_trade is True
    assert d.p_edge is None


def test_entry_filter_predict_and_gate(tmp_path: Path) -> None:
    from nautilus_gold_scalper.src.ml.entry_filter import OnnxEntryFilter

    model_dir = _train_and_export(tmp_path)

    meta_path = model_dir / "filter_y_good_long_metadata.json"
    meta = json.loads(meta_path.read_text(encoding="utf-8"))
    cols = meta["feature_cols"]

    f = OnnxEntryFilter(model_dir)
    f.initialize()

    features = dict.fromkeys(cols, 0.0)

    d_log = f.predict(features, direction="long", min_p_edge=0.99, mode="log_only")
    assert d_log.should_trade is True
    assert d_log.p_edge is not None

    d_gate = f.predict(features, direction="long", min_p_edge=0.9999, mode="gate")
    # With very high threshold it should usually block, but never crash.
    assert d_gate.p_edge is not None
    assert d_gate.reason in ("blocked_below_threshold", "ok")


def test_entry_filter_gate_fail_open_on_missing_features(tmp_path: Path) -> None:
    from nautilus_gold_scalper.src.ml.entry_filter import OnnxEntryFilter

    model_dir = _train_and_export(tmp_path)

    f = OnnxEntryFilter(model_dir)
    f.initialize()

    d = f.predict({}, direction="long", min_p_edge=0.0, mode="gate")
    assert d.should_trade is True
    assert d.p_edge is None
    assert d.reason == "missing_features"
