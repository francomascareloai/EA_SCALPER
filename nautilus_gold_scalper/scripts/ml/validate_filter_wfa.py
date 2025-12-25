from __future__ import annotations

import argparse
import json
from dataclasses import dataclass
from pathlib import Path

import numpy as np
import polars as pl


@dataclass(frozen=True, slots=True)
class FoldMetrics:
    fold: int
    train_rows: int
    test_rows: int
    pos_rate_train: float
    pos_rate_test: float
    baseline_rate_test: float
    kept_rate_test: float
    uplift_pos_rate: float


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Walk-forward sanity validation for entry filter gating.")
    p.add_argument("--dataset", required=True, help="Parquet dataset from build_dataset_from_telemetry.py")
    p.add_argument("--target", default="y_good_long", choices=["y_good_long", "y_good_short"], help="Target column")
    p.add_argument("--min-rows", type=int, default=5000, help="Minimum rows required")
    p.add_argument("--train", type=int, default=5000, help="Train window size")
    p.add_argument("--test", type=int, default=1000, help="Test window size")
    p.add_argument("--step", type=int, default=1000, help="Step size between folds")
    p.add_argument("--p-edge", type=float, default=0.65, help="Gating threshold")
    p.add_argument("--ghost", action="store_true", help="Ghost test: use constant p_edge=0.5")
    p.add_argument("--out", default=None, help="Optional output JSON path")
    return p.parse_args()


def _select_feature_columns(df: pl.DataFrame, *, target: str) -> list[str]:
    exclude_prefixes = ("future_", "ret_", "mfe_", "mae_", "range_")
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
        if df.schema[c] in (
            pl.Int8,
            pl.Int16,
            pl.Int32,
            pl.Int64,
            pl.UInt8,
            pl.UInt16,
            pl.UInt32,
            pl.UInt64,
            pl.Float32,
            pl.Float64,
        ):
            cols.append(c)
    cols.sort()
    return cols


def _to_numpy(df: pl.DataFrame, cols: list[str]) -> np.ndarray:
    return df.select(cols).to_numpy().astype(np.float64, copy=False)


def walk_forward_validate(
    dataset_path: Path,
    *,
    target: str,
    min_rows: int,
    train_size: int,
    test_size: int,
    step: int,
    p_edge: float,
    ghost: bool,
) -> dict[str, object]:
    from sklearn.impute import SimpleImputer
    from sklearn.linear_model import LogisticRegression
    from sklearn.pipeline import Pipeline
    from sklearn.preprocessing import StandardScaler

    df = pl.read_parquet(dataset_path)
    if df.height < min_rows:
        raise ValueError(f"Dataset too small: {df.height} rows (min {min_rows})")

    if "ts_event" in df.columns:
        df = df.sort("ts_event")

    df = df.filter(pl.col(target).is_not_null())
    y = df.select(pl.col(target).cast(pl.Int8, strict=False)).to_numpy().reshape(-1)

    feature_cols = _select_feature_columns(df, target=target)
    X = _to_numpy(df, feature_cols)

    n = int(len(y))
    if n < train_size + test_size:
        raise ValueError("Not enough rows for one fold")

    fold_metrics: list[FoldMetrics] = []

    fold = 0
    start = 0
    while start + train_size + test_size <= n:
        fold += 1
        tr_slice = slice(start, start + train_size)
        te_slice = slice(start + train_size, start + train_size + test_size)

        X_tr, y_tr = X[tr_slice], y[tr_slice]
        X_te, y_te = X[te_slice], y[te_slice]

        model = Pipeline(
            steps=[
                ("imputer", SimpleImputer(strategy="median")),
                ("scaler", StandardScaler()),
                ("clf", LogisticRegression(max_iter=200, solver="lbfgs")),
            ]
        )
        model.fit(X_tr, y_tr)

        if ghost:
            p = np.full((len(y_te),), 0.5, dtype=np.float64)
        else:
            p = model.predict_proba(X_te)[:, 1]

        keep = p >= float(p_edge)

        base_rate = float(np.mean(y_te))
        kept_rate = float(np.mean(y_te[keep])) if bool(np.any(keep)) else float("nan")

        fold_metrics.append(
            FoldMetrics(
                fold=fold,
                train_rows=int(len(y_tr)),
                test_rows=int(len(y_te)),
                pos_rate_train=float(np.mean(y_tr)),
                pos_rate_test=base_rate,
                baseline_rate_test=base_rate,
                kept_rate_test=kept_rate,
                uplift_pos_rate=float(kept_rate - base_rate) if np.isfinite(kept_rate) else float("nan"),
            )
        )

        start += int(step)

    def _json_float(x: float) -> float | None:
        # JSON spec doesn't support NaN/Inf; keep output parseable by strict readers.
        if not np.isfinite(x):
            return None
        return float(x)

    out: dict[str, object] = {
        "dataset": str(dataset_path),
        "target": target,
        "n_rows": int(n),
        "n_features": int(len(feature_cols)),
        "p_edge": float(p_edge),
        "ghost": bool(ghost),
        "folds": [
            {
                "fold": fm.fold,
                "train_rows": fm.train_rows,
                "test_rows": fm.test_rows,
                "pos_rate_train": _json_float(fm.pos_rate_train),
                "pos_rate_test": _json_float(fm.pos_rate_test),
                "baseline_rate_test": _json_float(fm.baseline_rate_test),
                "kept_rate_test": _json_float(fm.kept_rate_test),
                "uplift_pos_rate": _json_float(fm.uplift_pos_rate),
            }
            for fm in fold_metrics
        ],
    }
    return out


def main() -> int:
    args = parse_args()
    res = walk_forward_validate(
        Path(args.dataset),
        target=str(args.target),
        min_rows=int(args.min_rows),
        train_size=int(args.train),
        test_size=int(args.test),
        step=int(args.step),
        p_edge=float(args.p_edge),
        ghost=bool(args.ghost),
    )

    if args.out:
        out_path = Path(args.out)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(json.dumps(res, indent=2, sort_keys=True) + "\n", encoding="utf-8")
        print(f"Wrote: {out_path}")
    else:
        print(json.dumps(res, indent=2, sort_keys=True))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
