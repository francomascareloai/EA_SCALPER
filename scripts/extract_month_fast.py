"""
Fast month extractor from a large, sorted tick CSV (YYYYMM prefix).

Assumes:
  - Lines start with YYYYMMDD ...
  - File sorted ascending by datetime
  - No header (use --header if first line is header)

Usage:
  python scripts/extract_month_fast.py --year 2024 --month 1 \
    --source data/ticks/tmp/xauusd_2024_raw.csv \
    --out data/ticks/tmp/xauusd_202401_raw.csv
"""
from __future__ import annotations

import argparse
from pathlib import Path
import sys


def parse_args() -> argparse.Namespace:
    ap = argparse.ArgumentParser()
    ap.add_argument("--year", type=int, required=True)
    ap.add_argument("--month", type=int, required=True)
    ap.add_argument("--source", type=Path, required=True)
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--header", action="store_true")
    return ap.parse_args()


def get_prefix(year: int, month: int) -> str:
    return f"{year:04d}{month:02d}"


def get_yearmonth(line: str) -> str:
    return line[:6]


def main() -> None:
    args = parse_args()
    prefix = get_prefix(args.year, args.month)

    if not args.source.exists():
        print(f"Source not found: {args.source}")
        sys.exit(1)

    args.out.parent.mkdir(parents=True, exist_ok=True)

    written = 0
    stopped = False

    with args.source.open("r", encoding="utf-8") as fin, args.out.open("w", encoding="utf-8") as fout:
        if args.header:
            fin.readline()

        for line in fin:
            ym = get_yearmonth(line)
            if ym < prefix:
                continue
            if ym > prefix:
                stopped = True
                break
            fout.write(line)
            written += 1

    print(f"[OK] {prefix}: wrote {written:,} lines to {args.out}")
    if not stopped:
        print("[INFO] Reached EOF without next month prefix; file may end here.")


if __name__ == "__main__":
    main()
