from __future__ import annotations

import argparse
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any

import polars as pl
import yaml


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[3]


def _parse_date_utc(date_str: str, *, end_inclusive: bool) -> datetime:
    """Parse a date/datetime string into a tz-aware UTC datetime.

    Accepts either:
    - YYYY-MM-DD (treated as UTC midnight)
    - Full ISO datetime, optionally with an explicit offset

    NOTE: If tz-aware input is provided, preserve the actual instant in time by
    converting to UTC (do NOT overwrite tzinfo via replace()).
    """

    s = str(date_str)
    if s.endswith("Z"):
        s = s[:-1] + "+00:00"

    d = datetime.fromisoformat(s)
    if d.tzinfo is None:
        d = d.replace(tzinfo=timezone.utc)
    else:
        d = d.astimezone(timezone.utc)

    if end_inclusive:
        return d + timedelta(days=1)
    return d


def _load_default_ticks_path() -> Path:
    root = _repo_root()
    cfg_path = root / "data" / "config.yaml"
    cfg: Any = yaml.safe_load(cfg_path.read_text(encoding="utf-8"))
    if not isinstance(cfg, dict):
        raise ValueError(f"Invalid YAML config (expected mapping): {cfg_path}")

    active = cfg.get("active_dataset", {})
    if not isinstance(active, dict):
        raise ValueError(f"Invalid YAML config (active_dataset not mapping): {cfg_path}")

    path = active.get("path")
    if not path:
        raise ValueError(f"`active_dataset.path` not found in {cfg_path}")

    return (root / str(path)).resolve()


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Build M5 bars (OHLCV) from tick parquet using Polars.")
    p.add_argument("--start", required=True, help="Start date (YYYY-MM-DD or ISO datetime, UTC).")
    p.add_argument(
        "--end",
        required=True,
        help="End date (YYYY-MM-DD or ISO datetime). Date-only is inclusive full day; datetime is inclusive instant.",
    )
    p.add_argument(
        "--ticks-parquet",
        default=None,
        help="Input tick parquet. Defaults to `data/config.yaml:active_dataset.path`.",
    )
    p.add_argument(
        "--out",
        default=None,
        help="Output parquet path (default: data/derived/xauusd_m5_<start>_<end>.parquet).",
    )
    return p.parse_args()


def main() -> int:
    args = parse_args()
    root = _repo_root()

    ticks_path = Path(args.ticks_parquet) if args.ticks_parquet else _load_default_ticks_path()
    if not ticks_path.exists():
        raise FileNotFoundError(f"Tick parquet not found: {ticks_path}")

    start_dt = _parse_date_utc(str(args.start), end_inclusive=False)
    end_dt = _parse_date_utc(str(args.end), end_inclusive=False)
    end_is_date_only = len(str(args.end)) == 10

    out_path = (
        Path(args.out)
        if args.out
        else root / "data" / "derived" / f"xauusd_m5_{args.start}_{args.end}.parquet"
    )
    out_path.parent.mkdir(parents=True, exist_ok=True)

    # Treat input ticks as UTC (our dataset timestamps are UTC, but may be tz-naive in Parquet).
    lf = pl.scan_parquet(str(ticks_path)).select(["datetime", "bid", "ask"])
    lf = lf.with_columns(
        pl.col("datetime")
        .cast(pl.Datetime(time_unit="ns", time_zone="UTC"), strict=False)
        .alias("datetime"),
    )
    if end_is_date_only:
        end_dt_exclusive = end_dt + timedelta(days=1)
        end_filter = pl.col("datetime") < pl.lit(end_dt_exclusive)
    else:
        end_filter = pl.col("datetime") <= pl.lit(end_dt)

    lf = lf.filter((pl.col("datetime") >= pl.lit(start_dt)) & end_filter)
    lf = lf.with_columns(((pl.col("bid") + pl.col("ask")) / 2.0).alias("mid")).sort("datetime")

    # Keep timestamps at bar start (label="left"). Downstream loaders (e.g. `load_m5_bars_csv`) shift
    # to bar close to avoid look-ahead when consuming OHLC.
    bars = (
        lf.group_by_dynamic(index_column="datetime", every="5m", closed="left", label="left")
        .agg(
            pl.col("mid").first().alias("open"),
            pl.col("mid").max().alias("high"),
            pl.col("mid").min().alias("low"),
            pl.col("mid").last().alias("close"),
            pl.len().alias("volume"),
        )
        .rename({"datetime": "timestamp"})
    )

    try:
        df = bars.collect(engine="streaming")
    except TypeError:  # pragma: no cover
        df = bars.collect()

    if df.is_empty():
        raise ValueError(f"No bars produced for {args.start}..{args.end} from {ticks_path}")

    df.write_parquet(out_path)
    print(f"Wrote {len(df):,} bars -> {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
