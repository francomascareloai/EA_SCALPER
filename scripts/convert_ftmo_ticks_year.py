"""
Convert a single year from the mega CSV:
  Python_Agent_Hub/ml_pipeline/data/CSV_2003-2025XAUUSD_ftmo_all-TICK-No Session.csv

Columns (no header):
  datetime, bid, ask, spread, volume
  datetime format: %Y%m%d %H:%M:%S.%f (UTC)

Usage:
  python scripts/convert_ftmo_ticks_year.py --year 2024

Outputs:
  data/ticks/parquet_ftmo_build/xauusd_ftmo_{YEAR}_ticks.parquet (zstd)

Behavior:
  - Reads in chunks (1,000,000 rows)
  - Keeps only rows matching --year
  - Stops as soon as datetime crosses into > year (fast exit)
  - Writes incrementally to a ParquetWriter
  - Prints summary (rows, min/max datetime)
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import Optional

import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq


SOURCE = Path("Python_Agent_Hub/ml_pipeline/data/CSV_2003-2025XAUUSD_ftmo_all-TICK-No Session.csv")
OUT_DIR = Path("data/ticks/parquet_ftmo_build")
CHUNK_SIZE = 1_000_000


def parse_args() -> argparse.Namespace:
    ap = argparse.ArgumentParser()
    ap.add_argument("--year", type=int, required=True, help="Target year to extract (e.g., 2024)")
    return ap.parse_args()


def process_year(target_year: int) -> None:
    if not SOURCE.exists():
        print(f"Source not found: {SOURCE}")
        sys.exit(1)

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out_path = OUT_DIR / f"xauusd_ftmo_{target_year}_ticks.parquet"

    schema = pa.schema(
        [
            ("datetime", pa.timestamp("ns", tz="UTC")),
            ("bid", pa.float64()),
            ("ask", pa.float64()),
            ("spread", pa.float64()),
            ("volume", pa.float64()),
        ]
    )

    writer: Optional[pq.ParquetWriter] = None
    total_rows = 0
    min_dt = None
    max_dt = None

    try:
        for chunk in pd.read_csv(
            SOURCE,
            names=["datetime", "bid", "ask", "spread", "volume"],
            header=None,
            dtype={"bid": float, "ask": float, "spread": float, "volume": float},
            chunksize=CHUNK_SIZE,
        ):
            # Parse datetime
            chunk["datetime"] = pd.to_datetime(
                chunk["datetime"],
                format="%Y%m%d %H:%M:%S.%f",
                errors="coerce",
                utc=True,
            )
            chunk = chunk.dropna(subset=["datetime", "bid", "ask"])

            # Filter target year
            year_series = chunk["datetime"].dt.year
            mask_year = year_series == target_year
            mask_future = year_series > target_year

            # If nothing from target year and we've passed it, break early
            if mask_future.any() and not mask_year.any():
                break

            sub = chunk[mask_year]
            if sub.empty:
                continue

            if writer is None:
                writer = pq.ParquetWriter(out_path, schema=schema, compression="zstd")

            table = pa.Table.from_pandas(sub, preserve_index=False, schema=schema)
            writer.write_table(table)

            total_rows += len(sub)
            mn = sub["datetime"].min()
            mx = sub["datetime"].max()
            min_dt = mn if min_dt is None else min(min_dt, mn)
            max_dt = mx if max_dt is None else max(max_dt, mx)

            if mask_future.any():
                # We have reached the next year; stop
                break
    finally:
        if writer:
            writer.close()

    if total_rows == 0:
        print(f"[WARN] Year {target_year}: no rows found. Output not created.")
        if out_path.exists():
            out_path.unlink()
    else:
        print(
            f"[OK] Year {target_year}: rows={total_rows:,} "
            f"min={min_dt} max={max_dt} -> {out_path}"
        )


def main() -> None:
    args = parse_args()
    process_year(args.year)


if __name__ == "__main__":
    main()
