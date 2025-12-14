"""
Fast extractor: splits a mega tick CSV by year (string prefix filter).

Assumes lines start with YYYYMMDD (as in FTMO CSVs).
Columns are untouched; no datetime parsing (fast).

Usage:
  python scripts/extract_year_csv.py --year 2024 \
     --source Python_Agent_Hub/ml_pipeline/data/CSV_2003-2025XAUUSD_ftmo_all-TICK-No Session.csv \
     --out data/ticks/tmp/xauusd_2024_raw.csv
"""
from __future__ import annotations

import argparse
from pathlib import Path
import sys


def parse_args() -> argparse.Namespace:
    ap = argparse.ArgumentParser()
    ap.add_argument("--year", type=int, required=True, help="Target year, e.g. 2024")
    ap.add_argument("--source", type=Path, required=True, help="Path to mega CSV")
    ap.add_argument("--out", type=Path, required=True, help="Output CSV path")
    return ap.parse_args()


def main() -> None:
    args = parse_args()
    year_str = str(args.year)

    if not args.source.exists():
        print(f"Source not found: {args.source}")
        sys.exit(1)

    args.out.parent.mkdir(parents=True, exist_ok=True)

    kept = 0
    stopped = False

    with args.source.open("r", encoding="utf-8") as fin, args.out.open("w", encoding="utf-8") as fout:
        for line in fin:
            if line.startswith(year_str):
                fout.write(line)
                kept += 1
            elif kept > 0:
                # we already passed target year and reached next year prefix
                stopped = True
                break

    print(f"[OK] Year {args.year}: wrote {kept:,} lines to {args.out}")
    if not stopped:
        print("[INFO] Reached EOF without next-year prefix; file may end in target year.")


if __name__ == "__main__":
    main()
