from __future__ import annotations

import argparse
import json
from pathlib import Path

import polars as pl


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description=(
            "Build an ML dataset from strategy telemetry JSONL (ml_snapshot events).\n\n"
            "Input: telemetry.jsonl produced by TelemetrySink.\n"
            "Output: Parquet dataset with time-sorted rows and labels computed from future horizon (no leakage in features)."
        )
    )
    p.add_argument(
        "--telemetry",
        required=True,
        help="Path to telemetry.jsonl (e.g. nautilus_gold_scalper/scripts/logs/telemetry.jsonl).",
    )
    p.add_argument("--out", required=True, help="Output parquet path.")
    p.add_argument(
        "--instrument",
        default=None,
        help="Optional instrument_id filter (string match against ml_snapshot.instrument_id).",
    )
    p.add_argument(
        "--horizon-bars",
        type=int,
        default=12,
        help="Label horizon in bars (future look-ahead for y).",
    )
    p.add_argument(
        "--min-bars",
        type=int,
        default=200,
        help="Minimum rows required to write dataset.",
    )

    # Meta-label targets (direction-aware viability labels).
    # These are optional: if thresholds are not met, label is 0.
    p.add_argument(
        "--min-mfe",
        type=float,
        default=0.0025,
        help="Minimum favorable excursion (fraction) to consider a trade viable (e.g. 0.003 = +0.3%%).",
    )
    p.add_argument(
        "--max-mae",
        type=float,
        default=0.0015,
        help="Maximum adverse excursion (fraction) allowed for viability (e.g. 0.002 = 0.2%%).",
    )

    return p.parse_args()


def _read_jsonl(path: Path) -> pl.DataFrame:
    """Read a JSONL telemetry file into a DataFrame.

    Note: Telemetry files can contain heterogeneous event types. We want a stable
    schema where later-only keys (e.g. ml_snapshot fields) are retained.

    Polars `read_ndjson` infers schema from the first `infer_schema_length` rows,
    so we set it to `None` to scan the whole file for schema inference.
    """
    try:
        return pl.read_ndjson(path, infer_schema_length=None)
    except Exception:
        # Fallback: tolerant manual parser (kept for robustness with slightly invalid JSONL).
        rows: list[dict[str, object]] = []
        with path.open("r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    obj = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if not isinstance(obj, dict):
                    continue
                rows.append(obj)

        if not rows:
            return pl.DataFrame()

        # Let Polars reconcile schema across rows.
        return pl.from_dicts(rows, infer_schema_length=None)


def _coerce_numeric(df: pl.DataFrame) -> pl.DataFrame:
    # Be forgiving: telemetry may evolve; we coerce what we can.
    cols = df.columns

    def has(name: str) -> bool:
        return name in cols

    out = df
    if has("ts_event"):
        out = out.with_columns(pl.col("ts_event").cast(pl.Int64, strict=False))
    for c in ("open", "high", "low", "close", "atr", "atr_percentile", "spread_points", "selected_score", "execution_threshold"):
        if has(c):
            out = out.with_columns(pl.col(c).cast(pl.Float64, strict=False))
    for c in ("bar", "vol_bucket", "news_action", "news_minutes_to_event"):
        if has(c):
            out = out.with_columns(pl.col(c).cast(pl.Int64, strict=False))
    if has("news_in_window"):
        out = out.with_columns(pl.col("news_in_window").cast(pl.Boolean, strict=False))
    return out


def _build_dataset(
    df: pl.DataFrame,
    *,
    horizon_bars: int,
    min_mfe: float | None = None,
    max_mae: float | None = None,
) -> pl.DataFrame:
    if df.is_empty():
        return df

    if horizon_bars <= 0:
        raise ValueError("horizon_bars must be > 0")

    # Filter to ML snapshots only.
    df = df.filter(pl.col("event") == pl.lit("ml_snapshot"))

    # Keep only post_selection for now (single schema).
    if "stage" in df.columns:
        df = df.filter(pl.col("stage") == pl.lit("post_selection"))

    if df.is_empty():
        return df

    df = _coerce_numeric(df)

    required = ["ts_event", "close"]
    missing = [c for c in required if c not in df.columns]
    if missing:
        raise ValueError(f"Missing required columns in telemetry: {missing}")

    # Sort by event timestamp (nanoseconds). This is critical for correct label alignment.
    df = df.sort("ts_event")

    # Guard against invalid prices. (Labels are ratios; close must be positive.)
    df = df.filter(pl.col("close") > pl.lit(0.0))

    # Labels (future): next_h_close, forward return, and direction.
    # Formula: ret_fwd = future_close / close - 1
    df = df.with_columns(
        pl.col("close").shift(-horizon_bars).alias("future_close"),
    )
    df = df.with_columns(
        ((pl.col("future_close") / pl.col("close")) - pl.lit(1.0)).alias("ret_fwd"),
        (pl.col("future_close") > pl.col("close")).cast(pl.Int8).alias("y_up"),
    )

    # Robust excursion labels for swing/scalp (needs OHLC in snapshots).
    # We compute forward-looking extremes over the next `horizon_bars` bars, excluding the current bar.
    # For row t:
    # - future_max_high = max(high[t+1 .. t+h])
    # - future_min_low  = min(low[t+1 .. t+h])
    # Then:
    # - mfe_up   = (future_max_high - close[t]) / close[t]
    # - mfe_down = (close[t] - future_min_low) / close[t]
    cols = set(df.columns)
    if "high" in cols and "low" in cols:
        # Reverse-series trick to get forward-looking rolling windows.
        # In reversed order, the "next" bars become "previous" bars.
        rev_high = pl.col("high").reverse().shift(1)
        rev_low = pl.col("low").reverse().shift(1)

        future_max_high = (
            rev_high.rolling_max(window_size=horizon_bars).reverse().alias("future_max_high")
        )
        future_min_low = (
            rev_low.rolling_min(window_size=horizon_bars).reverse().alias("future_min_low")
        )

        df = df.with_columns(future_max_high, future_min_low)

        df = df.with_columns(
            ((pl.col("future_max_high") - pl.col("close")) / pl.col("close")).alias("mfe_up"),
            ((pl.col("close") - pl.col("future_min_low")) / pl.col("close")).alias("mfe_down"),
        )

        # Enforce non-negativity (numerical robustness).
        df = df.with_columns(
            pl.col("mfe_up").clip(lower_bound=0.0).alias("mfe_up"),
            pl.col("mfe_down").clip(lower_bound=0.0).alias("mfe_down"),
        )

        # Convenience labels for long/short adverse magnitudes (always >= 0 when non-null).
        df = df.with_columns(
            ((pl.col("close") - pl.col("future_min_low")) / pl.col("close")).alias("mae_long_abs"),
            ((pl.col("future_max_high") - pl.col("close")) / pl.col("close")).alias("mae_short_abs"),
            ((pl.col("future_max_high") - pl.col("future_min_low")) / pl.col("close")).alias("range_fwd"),
        )
        df = df.with_columns(
            pl.col("mae_long_abs").clip(lower_bound=0.0).alias("mae_long_abs"),
            pl.col("mae_short_abs").clip(lower_bound=0.0).alias("mae_short_abs"),
            pl.col("range_fwd").clip(lower_bound=0.0).alias("range_fwd"),
        )

        # Direction-aware viability labels (meta-label targets).
        # y_good_long  = 1 if within next horizon we reach at least `min_mfe` upside and do not draw down more than `max_mae`.
        # y_good_short = 1 if within next horizon we reach at least `min_mfe` downside and do not draw down more than `max_mae`.
        if (min_mfe is not None) and (max_mae is not None):
            if min_mfe < 0.0 or max_mae < 0.0:
                raise ValueError("min_mfe and max_mae must be >= 0")
            df = df.with_columns(
                ((pl.col("mfe_up") >= pl.lit(float(min_mfe))) & (pl.col("mae_long_abs") <= pl.lit(float(max_mae))))
                .cast(pl.Int8)
                .alias("y_good_long"),
                ((pl.col("mfe_down") >= pl.lit(float(min_mfe))) & (pl.col("mae_short_abs") <= pl.lit(float(max_mae))))
                .cast(pl.Int8)
                .alias("y_good_short"),
            )

    # Drop rows without labels (tail horizon).
    df = df.filter(pl.col("future_close").is_not_null())

    # Sanity: direction label in {0,1}
    df = df.with_columns(pl.col("y_up").cast(pl.Int8))

    return df


def main() -> int:
    args = parse_args()
    telemetry_path = Path(args.telemetry)
    out_path = Path(args.out)

    if not telemetry_path.exists():
        raise FileNotFoundError(f"Telemetry file not found: {telemetry_path}")

    df = _read_jsonl(telemetry_path)
    if df.is_empty():
        raise ValueError(f"No JSON objects found in: {telemetry_path}")

    if args.instrument:
        if "instrument_id" not in df.columns:
            raise ValueError("--instrument provided but telemetry has no instrument_id field")
        df = df.filter(pl.col("instrument_id") == pl.lit(str(args.instrument)))

    dataset = _build_dataset(
        df,
        horizon_bars=int(args.horizon_bars),
        min_mfe=float(args.min_mfe),
        max_mae=float(args.max_mae),
    )
    if dataset.is_empty() or dataset.height < int(args.min_bars):
        raise ValueError(f"Dataset too small: {dataset.height} rows (min {args.min_bars})")

    out_path.parent.mkdir(parents=True, exist_ok=True)
    dataset.write_parquet(out_path)

    print(f"Wrote dataset: rows={dataset.height:,} cols={len(dataset.columns)} -> {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
