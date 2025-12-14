"""Build Nautilus native ParquetDataCatalogs from the master FTMO tick CSV.

This script is the single entrypoint for data materialization:
- Full catalog (optionally stride)
- Per-session catalogs (ASIAN/LONDON/OVERLAP/NY/LATE_NY)

It uses `scripts/convert_csv_to_nautilus_catalog.py` for the actual conversion logic.
"""

from __future__ import annotations

import argparse
import subprocess
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build Nautilus native catalogs (full + sessions)")
    parser.add_argument(
        "--input",
        type=Path,
        default=Path("Python_Agent_Hub/ml_pipeline/data/CSV_2003-2025XAUUSD_ftmo_all-TICK-No Session.csv"),
    )
    parser.add_argument(
        "--out-root",
        type=Path,
        default=Path("data/catalog_native"),
        help="Root folder where catalogs will be created",
    )
    parser.add_argument("--stride", type=int, default=20)
    parser.add_argument("--chunk-size", type=int, default=2_000_000)
    parser.add_argument("--start-date", type=str, default=None)
    parser.add_argument("--end-date", type=str, default=None)
    parser.add_argument("--venue", type=str, default="SIM")
    parser.add_argument("--sessions", action="store_true", help="Also build session catalogs")
    parser.add_argument("--fail-on-disjoint", action="store_true")
    return parser.parse_args()


def run(cmd: list[str]) -> None:
    print("\n$ " + " ".join(cmd))
    subprocess.run(cmd, check=True)


def main() -> None:
    args = parse_args()
    converter = Path("scripts/convert_csv_to_nautilus_catalog.py")

    base_name = f"xauusd_2003_2025_stride{args.stride}_full"
    out_full = args.out_root / base_name

    base_cmd = [
        str(Path(".venv/bin/python")),
        str(converter),
        "--input",
        str(args.input),
        "--chunk-size",
        str(args.chunk_size),
        "--stride",
        str(args.stride),
        "--venue",
        args.venue,
    ]
    if args.start_date:
        base_cmd += ["--start-date", args.start_date]
    if args.end_date:
        base_cmd += ["--end-date", args.end_date]
    if args.fail_on_disjoint:
        base_cmd += ["--fail-on-disjoint"]

    run(base_cmd + ["--output", str(out_full)])

    if args.sessions:
        for session in ["ASIAN", "LONDON", "OVERLAP", "NY", "LATE_NY"]:
            out_session = args.out_root / f"{base_name}__{session}"
            run(base_cmd + ["--output", str(out_session), "--session", session])


if __name__ == "__main__":
    main()
