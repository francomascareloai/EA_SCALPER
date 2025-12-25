from __future__ import annotations

from pathlib import Path

import numpy as np
import polars as pl

from nautilus_gold_scalper.scripts.ml.train_filter import train_filter_model


def _make_tiny_dataset(n_rows: int, n_features: int, *, seed: int = 7) -> pl.DataFrame:
    rng = np.random.default_rng(seed)

    # Create a stable, learnable label with some noise.
    x0 = rng.normal(size=n_rows)
    x1 = rng.normal(size=n_rows)
    y = (x0 + 0.3 * x1 + rng.normal(scale=0.5, size=n_rows) > 0).astype(int)

    rows: list[dict[str, object]] = []
    for i in range(n_rows):
        row: dict[str, object] = {
            "event": "ml_snapshot",
            "stage": "post_selection",
            "ts_event": i + 1,
            "close": float(100 + i),
            "y_good_long": int(y[i]),
        }
        for j in range(n_features):
            row[f"f{j}"] = float(x0[i] if j == 0 else (x1[i] if j == 1 else rng.normal()))
        rows.append(row)

    return pl.DataFrame(rows)


def test_train_export_onnx_infer(tmp_path: Path) -> None:
    df = _make_tiny_dataset(n_rows=6000, n_features=6)
    dataset_path = tmp_path / "dataset.parquet"
    df.write_parquet(dataset_path)

    out_dir = tmp_path / "out"
    res = train_filter_model(
        dataset_path,
        out_dir=out_dir,
        target="y_good_long",
        test_size=0.2,
        random_state=42,
        min_rows=5000,
    )

    assert res.model_path.exists()
    assert res.features_path.exists()
    assert res.metrics_path.exists()

    # ONNX export (and parity check) should succeed.
    from nautilus_gold_scalper.scripts.ml.export_onnx import export_filter_onnx

    onnx_res = export_filter_onnx(
        res.model_path,
        features_path=res.features_path,
        out_path=out_dir / "filter_y_good_long.onnx",
        opset=12,
        verify=True,
    )

    assert onnx_res.onnx_path.exists()
    assert onnx_res.metadata_path.exists()
