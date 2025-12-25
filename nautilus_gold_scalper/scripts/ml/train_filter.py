from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path

import joblib
import numpy as np
import polars as pl
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import brier_score_loss, roc_auc_score
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler


@dataclass(frozen=True, slots=True)
class TrainResult:
    model_path: Path
    features_path: Path
    metrics_path: Path


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Train ML entry filter (meta-label) from Parquet dataset.")
    p.add_argument("--dataset", required=True, help="Input dataset parquet (from build_dataset_from_telemetry.py).")
    p.add_argument("--out-dir", required=True, help="Output directory (will contain model + metadata).")

    p.add_argument(
        "--target",
        default="y_good_long",
        choices=["y_good_long", "y_good_short"],
        help="Target column to train (direction-specific).",
    )

    p.add_argument(
        "--test-size",
        type=float,
        default=0.2,
        help="Holdout fraction for quick sanity metrics (not time-series safe).",
    )
    p.add_argument(
        "--random-state",
        type=int,
        default=42,
        help="Random seed (only affects the quick holdout split).",
    )

    p.add_argument(
        "--min-rows",
        type=int,
        default=5_000,
        help="Minimum dataset rows required to train.",
    )

    return p.parse_args()


def _select_feature_columns(df: pl.DataFrame, *, target: str) -> list[str]:
    # Exclude telemetry meta + labels.
    exclude_prefixes = (
        "future_",
        "ret_",
        "mfe_",
        "mae_",
        "range_",
    )
    exclude = {
        "event",
        "stage",
        "target",
        "ts_event",
        "instrument_id",
        "bar",
        "session",
        "regime",
        "arm",
        "y_up",
        "y_good_long",
        "y_good_short",
        target,
    }

    cols: list[str] = []
    for c in df.columns:
        if c in exclude:
            continue
        if any(c.startswith(pfx) for pfx in exclude_prefixes):
            continue
        # Keep numeric only.
        if df.schema[c] in (pl.Int8, pl.Int16, pl.Int32, pl.Int64, pl.UInt8, pl.UInt16, pl.UInt32, pl.UInt64, pl.Float32, pl.Float64):
            cols.append(c)

    # Stable order.
    cols.sort()
    return cols


def _to_numpy(df: pl.DataFrame, cols: list[str]) -> np.ndarray:
    if not cols:
        raise ValueError("No feature columns selected")
    mat = df.select(cols).to_numpy()
    # Ensure float for sklearn.
    return mat.astype(np.float64, copy=False)


def train_filter_model(dataset_path: Path, *, out_dir: Path, target: str, test_size: float, random_state: int, min_rows: int) -> TrainResult:
    df = pl.read_parquet(dataset_path)
    if df.height < min_rows:
        raise ValueError(f"Dataset too small: {df.height} rows (min {min_rows})")

    if target not in df.columns:
        raise ValueError(f"Target not found: {target}")

    # Basic cleaning.
    df = df.filter(pl.col(target).is_not_null())

    # Ensure binary int labels.
    y = df.select(pl.col(target).cast(pl.Int8, strict=False)).to_numpy().reshape(-1)
    if y.size == 0:
        raise ValueError("No labels available after filtering")

    unique = set(int(v) for v in np.unique(y))
    if not unique.issubset({0, 1}):
        raise ValueError(f"Target must be binary 0/1, got: {sorted(unique)}")

    feature_cols = _select_feature_columns(df, target=target)
    X = _to_numpy(df, feature_cols)

    if not (0.0 < test_size < 0.9):
        raise ValueError("test_size must be in (0, 0.9)")

    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=float(test_size),
        random_state=int(random_state),
        stratify=y,
    )

    # Deterministic, fast baseline: logistic regression (probabilities are already calibrated enough
    # for a first cut; we can add calibration later once we validate the ONNX export path).
    # NOTE: This is not time-series safe evaluation; it is a smoke check only.
    model = Pipeline(
        steps=[
            ("imputer", SimpleImputer(strategy="median")),
            ("scaler", StandardScaler()),
            ("clf", LogisticRegression(max_iter=200, solver="lbfgs")),
        ]
    )

    model.fit(X_train, y_train)

    proba = model.predict_proba(X_test)[:, 1]

    metrics: dict[str, float] = {}
    try:
        metrics["roc_auc"] = float(roc_auc_score(y_test, proba))
    except ValueError:
        metrics["roc_auc"] = float("nan")
    metrics["brier"] = float(brier_score_loss(y_test, proba))
    metrics["pos_rate"] = float(np.mean(y))
    metrics["n_rows"] = float(df.height)
    metrics["n_features"] = float(len(feature_cols))

    out_dir.mkdir(parents=True, exist_ok=True)
    model_path = out_dir / f"filter_{target}.joblib"
    features_path = out_dir / f"filter_{target}_features.txt"
    metrics_path = out_dir / f"filter_{target}_metrics.json"

    joblib.dump(model, model_path)
    features_path.write_text("\n".join(feature_cols) + "\n", encoding="utf-8")
    metrics_path.write_text(
        "{\n" + ",\n".join([f'  "{k}": {v}' for k, v in metrics.items()]) + "\n}\n",
        encoding="utf-8",
    )

    return TrainResult(model_path=model_path, features_path=features_path, metrics_path=metrics_path)


def main() -> int:
    args = parse_args()
    res = train_filter_model(
        Path(args.dataset),
        out_dir=Path(args.out_dir),
        target=str(args.target),
        test_size=float(args.test_size),
        random_state=int(args.random_state),
        min_rows=int(args.min_rows),
    )

    print(f"Wrote model: {res.model_path}")
    print(f"Wrote features: {res.features_path}")
    print(f"Wrote metrics: {res.metrics_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
