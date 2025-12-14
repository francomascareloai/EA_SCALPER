"""
Convert yearly XAUUSD stride20 CSVs to Parquet (zstd), with validation.

Input:
    data/ticks/by_year/xauusd_YYYY_stride20.csv
        columns (no header): datetime, bid, ask
        datetime format: %Y%m%d %H:%M:%S.%f (UTC implicit)

Outputs:
    data/ticks/parquet/xauusd_YYYY_stride20.parquet
    data/ticks/parquet/xauusd_2021_2024_stride20.parquet (combined, if >1 file)

Validation steps per file:
    - parse datetime to UTC
    - drop rows with parse errors or NaN bid/ask
    - sort by datetime; ensure monotonic
    - print count, min/max datetime
"""
from __future__ import annotations

import sys
from pathlib import Path
from typing import List

import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq


DATA_DIR = Path("data/ticks")
CSV_DIR = DATA_DIR / "by_year"
PARQUET_DIR = DATA_DIR / "parquet"
PARQUET_DIR.mkdir(parents=True, exist_ok=True)


def read_csv_clean(path: Path) -> pd.DataFrame:
    """Load CSV (no header), parse datetime UTC, drop bad rows, sort."""
    df = pd.read_csv(
        path,
        names=["datetime", "bid", "ask"],
        header=None,
        dtype={"bid": float, "ask": float},
    )

    df["datetime"] = pd.to_datetime(
        df["datetime"],
        format="%Y%m%d %H:%M:%S.%f",
        errors="coerce",
        utc=True,
    )

    before = len(df)
    df = df.dropna(subset=["datetime", "bid", "ask"])
    if len(df) != before:
        print(f"[WARN] {path.name}: dropped {before - len(df)} bad rows")

    df = df.sort_values("datetime")

    if df["datetime"].is_monotonic_increasing is False:
        df = df.sort_values("datetime")
        if df["datetime"].is_monotonic_increasing is False:
            raise ValueError(f"{path.name}: datetime not monotonic after sort")

    return df.reset_index(drop=True)


def to_parquet(df: pd.DataFrame, out_path: Path) -> None:
    table = pa.Table.from_pandas(df, preserve_index=False)
    pq.write_table(table, out_path, compression="zstd")


def summarize(df: pd.DataFrame, name: str) -> None:
    print(
        f"[OK] {name}: rows={len(df):,} "
        f"min={df['datetime'].min()} max={df['datetime'].max()} "
        f"bid[{df['bid'].min():.2f},{df['bid'].max():.2f}] "
        f"ask[{df['ask'].min():.2f},{df['ask'].max():.2f}]"
    )


def main() -> None:
    csv_files: List[Path] = sorted(CSV_DIR.glob("xauusd_*_stride20.csv"))
    if not csv_files:
        print(f"No CSV files found in {CSV_DIR}")
        sys.exit(1)

    parquet_paths = []

    for csv in csv_files:
        df = read_csv_clean(csv)
        out = PARQUET_DIR / f"{csv.stem}.parquet"
        to_parquet(df, out)
        summarize(df, csv.name)
        parquet_paths.append(out)

    if len(parquet_paths) > 1:
        print("\n[INFO] Building combined parquet...")
        frames = [pd.read_parquet(p) for p in parquet_paths]
        combo = pd.concat(frames, ignore_index=True).sort_values("datetime")
        out_combo = PARQUET_DIR / "xauusd_2021_2024_stride20.parquet"
        to_parquet(combo, out_combo)
        summarize(combo, out_combo.name)


if __name__ == "__main__":
    main()
