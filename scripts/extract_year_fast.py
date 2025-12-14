"""
Fast year extractor using binary search on a large, sorted tick CSV.

Assumes:
  - File sorted ascending by datetime string starting YYYY...
  - Lines like: YYYYMMDD hh:mm:ss.xxx,bid,ask[,spread][,volume]
  - No header (if header exists, it will be skipped).

Strategy:
  - Binary-search file offsets to find first line with year >= target.
  - Stream forward writing lines that start with target year.
  - Stop when year > target or EOF.

Usage:
  python scripts/extract_year_fast.py --year 2024 \
    --source Python_Agent_Hub/ml_pipeline/data/CSV-2020-2025XAUUSD_ftmo-TICK-No Session.csv \
    --out data/ticks/tmp/xauusd_2024_raw.csv
"""
from __future__ import annotations

import argparse
from pathlib import Path
import sys


def parse_args() -> argparse.Namespace:
    ap = argparse.ArgumentParser()
    ap.add_argument("--year", type=int, required=True)
    ap.add_argument("--source", type=Path, required=True)
    ap.add_argument("--out", type=Path, required=True)
    ap.add_argument("--header", action="store_true", help="Skip first line if header present")
    return ap.parse_args()


def read_line_at(f, offset: int) -> str:
    f.seek(offset)
    f.readline()  # drop partial line
    return f.readline()


def get_year(line: str) -> int:
    try:
        return int(line[:4])
    except Exception:
        return -1


def find_first_offset_for_year(f, size: int, target_year: int) -> int:
    lo, hi = 0, size
    found = size
    while lo < hi:
        mid = (lo + hi) // 2
        line = read_line_at(f, mid)
        if not line:
            hi = mid
            continue
        y = get_year(line)
        if y < target_year and y != -1:
            lo = mid + 1
        else:
            found = mid
            hi = mid
    return found


def main() -> None:
    args = parse_args()
    target = args.year

    if not args.source.exists():
        print(f"Source not found: {args.source}")
        sys.exit(1)

    args.out.parent.mkdir(parents=True, exist_ok=True)

    size = args.source.stat().st_size
    with args.source.open("r", encoding="utf-8") as fin:
        # Optionally skip header
        if args.header:
            header = fin.readline()

        start_off = find_first_offset_for_year(fin, size, target)
        fin.seek(start_off)
        # align to full line
        fin.readline()

        written = 0
        with args.out.open("w", encoding="utf-8") as fout:
            for line in fin:
                y = get_year(line)
                if y < target:
                    continue
                if y > target:
                    break
                fout.write(line)
                written += 1

        print(f"[OK] Year {target}: wrote {written:,} lines to {args.out}")


if __name__ == "__main__":
    main()
