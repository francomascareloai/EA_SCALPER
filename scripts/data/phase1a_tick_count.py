#!/usr/bin/env python3
"""
Phase 1-A.1: Tick count validation (CSV sessions vs Parquet catalogs).

This script exists to keep `.planning/**` free of executable scripts while still
supporting Phase 1-A outputs in `.planning/phases/08-data-validation-backtest/outputs/`.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import tracemalloc
from pathlib import Path
from typing import Any

import duckdb


DEFAULT_SESSIONS: tuple[str, ...] = ("ASIAN", "EVENING", "LATE_NY", "LONDON", "NY", "OVERLAP")


def count_csv_ticks_by_session(csv_dir: Path) -> dict[str, int]:
    csv_counts: dict[str, int] = {}
    csv_files = sorted(csv_dir.glob("xauusd_*.csv"))

    print(f"Counting ticks from {len(csv_files)} CSV session files...")

    for csv_file in csv_files:
        session = csv_file.stem.replace("xauusd_", "")
        result = subprocess.run(["wc", "-l", str(csv_file)], capture_output=True, text=True, check=True)
        csv_counts[session] = int(result.stdout.split()[0])
        print(f"  {session}: {csv_counts[session]:,} lines")

    return csv_counts


def count_parquet_ticks(db: duckdb.DuckDBPyConnection, parquet_glob: str, name: str) -> int:
    print(f"Counting: {name}")
    print(f"  Pattern: {parquet_glob}")
    (count,) = db.execute(f"SELECT COUNT(*) FROM read_parquet('{parquet_glob}')").fetchone()
    count = int(count)
    print(f"  Count: {count:,}")
    return count


def count_session_parquets(
    db: duckdb.DuckDBPyConnection,
    base_dir: Path,
    sessions: tuple[str, ...],
) -> dict[str, int]:
    session_counts: dict[str, int] = {}
    print("\nCounting Session Parquet Catalogs:")

    for session in sessions:
        catalog_dir = base_dir / f"xauusd_2003_2025_stride1_{session}"
        if not catalog_dir.exists():
            print(f"  WARNING: {session} catalog not found at {catalog_dir}")
            session_counts[session] = 0
            continue

        pattern = str(catalog_dir / "data/quote_tick/**/*.parquet")
        session_counts[session] = count_parquet_ticks(db, pattern, f"Session: {session}")

    return session_counts


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Phase 1-A.1 tick count validation (CSV vs Parquet).")
    p.add_argument("--csv-dir", type=Path, default=Path("data/session_csvs"))
    p.add_argument(
        "--main-catalog",
        type=Path,
        default=Path("data/catalog_native/xauusd_2003_2025_stride1_COMPLETE"),
        help="Main Parquet catalog (Nautilus ParquetDataCatalog layout).",
    )
    p.add_argument(
        "--sessions-catalog-base",
        type=Path,
        default=Path("data/catalog_native_sessions"),
        help="Base dir containing per-session catalogs.",
    )
    p.add_argument(
        "--sessions",
        type=str,
        default=",".join(DEFAULT_SESSIONS),
        help="Comma-separated session names.",
    )
    p.add_argument(
        "--output",
        type=Path,
        default=Path(".planning/phases/08-data-validation-backtest/outputs/PHASE1A_CSV_PARQUET_COUNT.json"),
    )
    p.add_argument("--duckdb-memory", type=str, default="6GB")
    p.add_argument("--duckdb-temp", type=Path, default=Path("/tmp/duckdb_swap"))
    return p.parse_args()


def main() -> int:
    args = parse_args()
    sessions = tuple(s.strip() for s in args.sessions.split(",") if s.strip())

    tracemalloc.start()

    args.duckdb_temp.mkdir(parents=True, exist_ok=True)
    db = duckdb.connect(":memory:")
    db.execute(f"SET memory_limit='{args.duckdb_memory}';")
    db.execute(f"SET temp_directory='{args.duckdb_temp}';")

    print("=" * 80)
    print("PHASE 1-A.1: Comprehensive Tick Count Validation")
    print("=" * 80)

    if not args.main_catalog.exists():
        raise FileNotFoundError(f"Main catalog not found: {args.main_catalog}")
    if not args.csv_dir.exists():
        raise FileNotFoundError(f"CSV directory not found: {args.csv_dir}")

    print("\n--- MAIN PARQUET CATALOG ---")
    main_pattern = str(args.main_catalog / "data/quote_tick/**/*.parquet")
    main_parquet_count = count_parquet_ticks(db, main_pattern, "Main Catalog")

    print("\n--- SESSION PARQUET CATALOGS ---")
    session_parquet_counts = count_session_parquets(db, args.sessions_catalog_base, sessions)
    session_parquet_sum = sum(session_parquet_counts.values())
    print(f"\nSession Parquet SUM: {session_parquet_sum:,}")

    print("\n--- SESSION CSV FILES ---")
    csv_counts = count_csv_ticks_by_session(args.csv_dir)
    csv_sum = sum(csv_counts.values())
    print(f"\nCSV SUM: {csv_sum:,}")

    print("\n" + "=" * 80)
    print("VALIDATION RESULTS")
    print("=" * 80)

    diff_session_main = session_parquet_sum - main_parquet_count
    diff_session_main_pct = abs(diff_session_main) / main_parquet_count * 100 if main_parquet_count > 0 else 0.0

    print("\n1. Session Parquets vs Main Parquet:")
    print(f"   Main Parquet:     {main_parquet_count:,}")
    print(f"   Session Sum:      {session_parquet_sum:,}")
    print(f"   Difference:       {diff_session_main:,} ({diff_session_main_pct:.4f}%)")
    print(f"   Status: {'PASS ✓' if diff_session_main_pct <= 0.1 else 'FAIL ✗'}")

    print("\n2. CSV vs Session Parquet (by session):")
    csv_parquet_matches: dict[str, bool] = {}
    for session, csv_count in csv_counts.items():
        pq_count = session_parquet_counts.get(session, 0)
        diff = csv_count - pq_count
        diff_pct = abs(diff) / pq_count * 100 if pq_count > 0 else 0.0
        match = diff_pct <= 0.1
        csv_parquet_matches[session] = match
        print(
            f"   {session:12s}: CSV={csv_count:,} PQ={pq_count:,} diff={diff:,} "
            f"({diff_pct:.4f}%) {'✓' if match else '✗'}"
        )

    session_partition_ok = diff_session_main_pct <= 0.1
    csv_match_ok = all(csv_parquet_matches.values()) if csv_parquet_matches else False
    overall_status = "PASS" if (session_partition_ok and csv_match_ok) else "FAIL"

    current, peak = tracemalloc.get_traced_memory()
    memory_peak_mb = peak / 1024 / 1024
    tracemalloc.stop()

    print(f"\nMemory peak: {memory_peak_mb:.2f} MB")
    print(f"\nOVERALL STATUS: {overall_status}")

    result: dict[str, Any] = {
        "main_parquet_count": main_parquet_count,
        "session_parquet_sum": session_parquet_sum,
        "session_parquet_counts": session_parquet_counts,
        "csv_sum": csv_sum,
        "csv_counts": csv_counts,
        "session_main_difference": diff_session_main,
        "session_main_difference_pct": diff_session_main_pct,
        "csv_parquet_matches": csv_parquet_matches,
        "status": overall_status,
        "memory_peak_mb": int(memory_peak_mb),
    }

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2), encoding="utf-8")
    print(f"\nResults written to: {args.output}")

    db.close()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

