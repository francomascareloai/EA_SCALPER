#!/usr/bin/env python3
"""
Phase 1-A: Gap detection for quote ticks (DuckDB, spill-to-disk).

Moves the former `.planning/**/scripts/gap_detection_v2.py` into a proper,
central location under `scripts/data/`.
"""

from __future__ import annotations

import argparse
import json
import os
import traceback
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path

import duckdb


@dataclass(frozen=True, slots=True)
class Gap:
    start_ts: int
    end_ts: int
    gap_hours: float


def weekday_name(dt: datetime) -> str:
    return ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][dt.weekday()]


def is_weekend_gap(start_dt: datetime, end_dt: datetime, gap_hours: float) -> bool:
    start_weekday = start_dt.weekday()  # 0=Mon, 4=Fri, 6=Sun
    end_weekday = end_dt.weekday()
    is_friday_close = (start_weekday == 4 and start_dt.hour >= 18)
    is_sunday_open = (end_weekday == 6 and end_dt.hour >= 18) or (end_weekday == 0 and end_dt.hour <= 6)
    return is_friday_close and is_sunday_open and (40 < gap_hours < 60)


def is_extended_weekend_gap(start_dt: datetime, end_dt: datetime, gap_hours: float) -> bool:
    is_thursday_close = (start_dt.weekday() == 3 and start_dt.hour >= 18)
    is_monday_open = (end_dt.weekday() == 0 and end_dt.hour <= 6)
    return is_thursday_close and is_monday_open and (65 < gap_hours < 80)


def is_us_holiday_early_close_gap(start_dt: datetime, end_dt: datetime, gap_hours: float) -> bool:
    if not (4 <= gap_hours <= 10):
        return False
    is_early_close = 18 <= start_dt.hour <= 22
    is_next_day_open = 0 <= end_dt.hour <= 6
    if not (is_early_close and is_next_day_open):
        return False

    month, day = start_dt.month, start_dt.day
    if month == 7 and day in (3, 4):
        return True
    if month == 12 and day in (24, 25, 31):
        return True
    if month == 1 and day == 1:
        return True

    if month in (1, 2) and 14 <= day <= 21:
        return True
    if month == 5 and 25 <= day <= 31:
        return True
    if month == 9 and 1 <= day <= 7:
        return True
    if month == 11 and 22 <= day <= 28:
        return True

    return False


def is_normal_session_gap(start_dt: datetime, end_dt: datetime, gap_hours: float) -> bool:
    if not (1 <= gap_hours <= 4):
        return False
    if start_dt.weekday() >= 5 or end_dt.weekday() >= 5:
        return False
    return True


def classify_gap(start_ts: int, end_ts: int, gap_hours: float) -> str:
    start_dt = datetime.fromtimestamp(start_ts / 1e9, tz=timezone.utc)
    end_dt = datetime.fromtimestamp(end_ts / 1e9, tz=timezone.utc)

    if is_weekend_gap(start_dt, end_dt, gap_hours):
        return "weekend"
    if is_extended_weekend_gap(start_dt, end_dt, gap_hours):
        return "extended_weekend"
    if is_us_holiday_early_close_gap(start_dt, end_dt, gap_hours):
        return "holiday_early_close"
    if is_normal_session_gap(start_dt, end_dt, gap_hours):
        return "session_transition"
    return "unexpected"


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Phase 1-A gap detection (DuckDB) for XAUUSD quote ticks.")
    p.add_argument(
        "--data-glob",
        type=str,
        default="data/catalog_native/xauusd_2003_2025_stride1_COMPLETE/data/quote_tick/XAUUSD.SIM/*.parquet",
        help="Parquet glob for quote_tick files.",
    )
    p.add_argument(
        "--output",
        type=Path,
        default=Path(".planning/phases/08-data-validation-backtest/outputs/PHASE1A_GAP_DETECTION.json"),
    )
    p.add_argument("--duckdb-memory", type=str, default="6GB")
    p.add_argument("--duckdb-temp", type=Path, default=Path("/tmp/duckdb_swap"))
    p.add_argument("--min-gap-seconds", type=int, default=3600)
    p.add_argument("--max-unexpected", type=int, default=50)
    return p.parse_args()


def main() -> int:
    args = parse_args()
    args.duckdb_temp.mkdir(parents=True, exist_ok=True)
    os.makedirs(args.duckdb_temp, exist_ok=True)

    db = duckdb.connect(":memory:")
    db.execute(f"SET memory_limit='{args.duckdb_memory}';")
    db.execute(f"SET temp_directory='{args.duckdb_temp}';")

    print("=" * 60)
    print("PHASE 1-A: Gap Detection (DuckDB)")
    print("=" * 60)
    print(f"Data glob: {args.data_glob}")
    print(f"Temp directory: {args.duckdb_temp}")

    try:
        (total_ticks,) = db.execute(f"SELECT COUNT(*) FROM read_parquet('{args.data_glob}')").fetchone()
        total_ticks = int(total_ticks)

        (min_ts, max_ts) = db.execute(
            f"SELECT MIN(ts_event) as min_ts, MAX(ts_event) as max_ts FROM read_parquet('{args.data_glob}')"
        ).fetchone()

        min_dt = datetime.fromtimestamp(min_ts / 1e9, tz=timezone.utc)
        max_dt = datetime.fromtimestamp(max_ts / 1e9, tz=timezone.utc)

        print(f"Total ticks: {total_ticks:,}")
        print(f"Date range: {min_dt.isoformat()} -> {max_dt.isoformat()}")
        print("\nFinding gaps (this may take a while)...")

        gaps_query = f"""
            WITH ticks AS (
                SELECT
                    ts_event,
                    LAG(ts_event) OVER (ORDER BY ts_event) as prev_ts
                FROM read_parquet('{args.data_glob}')
            )
            SELECT
                prev_ts,
                ts_event,
                (ts_event - prev_ts) / 1e9 / 3600.0 as gap_hours
            FROM ticks
            WHERE prev_ts IS NOT NULL
              AND (ts_event - prev_ts) / 1e9 > {int(args.min_gap_seconds)}
            ORDER BY gap_hours DESC
        """

        rows = db.execute(gaps_query).fetchall()
        gaps = [Gap(int(prev_ts), int(curr_ts), float(gap_hours)) for prev_ts, curr_ts, gap_hours in rows]
        print(f"Found {len(gaps)} gaps > {args.min_gap_seconds}s")

        buckets: dict[str, list[dict[str, object]]] = {
            "weekend": [],
            "extended_weekend": [],
            "holiday_early_close": [],
            "session_transition": [],
            "unexpected": [],
        }

        for g in gaps:
            start_dt = datetime.fromtimestamp(g.start_ts / 1e9, tz=timezone.utc)
            end_dt = datetime.fromtimestamp(g.end_ts / 1e9, tz=timezone.utc)
            gap_type = classify_gap(g.start_ts, g.end_ts, g.gap_hours)

            buckets[gap_type].append(
                {
                    "start": start_dt.isoformat().replace("+00:00", "Z"),
                    "end": end_dt.isoformat().replace("+00:00", "Z"),
                    "start_weekday": weekday_name(start_dt),
                    "end_weekday": weekday_name(end_dt),
                    "gap_hours": round(g.gap_hours, 2),
                }
            )

        unexpected = buckets["unexpected"]
        max_unexpected_gap_minutes = max((x["gap_hours"] for x in unexpected), default=0.0) * 60

        unexpected_count = len(unexpected)
        status = "PASS" if unexpected_count == 0 else ("WARN" if unexpected_count <= 5 else "FAIL")

        import resource

        memory_peak_mb = int(resource.getrusage(resource.RUSAGE_SELF).ru_maxrss // 1024)

        result = {
            "analysis_timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
            "version": "2.0",
            "data_source": args.data_glob,
            "date_range": {
                "start": min_dt.isoformat().replace("+00:00", "Z"),
                "end": max_dt.isoformat().replace("+00:00", "Z"),
            },
            "total_ticks": total_ticks,
            "total_gaps_found": len(gaps),
            "gap_classification": {k: len(v) for k, v in buckets.items()},
            "unexpected_gaps": unexpected[: int(args.max_unexpected)],
            "unexpected_gap_count": unexpected_count,
            "max_unexpected_gap_minutes": round(max_unexpected_gap_minutes, 2),
            "status": status,
            "memory_peak_mb": memory_peak_mb,
            "notes": [],
        }

        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(result, indent=2), encoding="utf-8")
        print(f"\nResults written to: {args.output}")
        db.close()
        return 0

    except Exception:
        traceback.print_exc()
        db.close()
        return 1


if __name__ == "__main__":
    raise SystemExit(main())

