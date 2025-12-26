from __future__ import annotations

import argparse
import re
from datetime import datetime, timedelta, timezone
from pathlib import Path

import polars as pl
import yaml


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[3]


def _load_default_instrument() -> str:
    cfg_path = _repo_root() / "data" / "config.yaml"
    cfg = yaml.safe_load(cfg_path.read_text(encoding="utf-8"))
    active = cfg.get("active_dataset", {}) if isinstance(cfg, dict) else {}
    inst = active.get("instrument")
    if not inst:
        raise ValueError(f"`active_dataset.instrument` not found in {cfg_path}")
    return str(inst)


def _instrument_folder_name(instrument: str) -> str:
    # Catalog folder names omit "/" from instrument IDs (e.g. "XAU/USD.SIM" -> "XAUUSD.SIM").
    return str(instrument).replace("/", "")


def _parse_date_utc(date_str: str, *, end_inclusive: bool) -> datetime:
    """Parse a date/datetime string into a tz-aware UTC datetime.

    Accepts either:
    - YYYY-MM-DD (treated as UTC midnight)
    - Full ISO datetime, optionally with an explicit offset (including a trailing 'Z')

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

    return d + (timedelta(days=1) if end_inclusive else timedelta(0))


def _split_csv(value: str | None) -> list[str]:
    if not value:
        return []
    return [p.strip() for p in value.split(",") if p.strip()]


def _timeframes(value: str | None) -> list[str]:
    if not value:
        return ["M5"]
    out: list[str] = []
    for part in value.split(","):
        p = part.strip().upper()
        if p:
            out.append(p)
    return out or ["M5"]


def _tf_to_every(tf: str) -> str:
    tf_u = tf.upper().strip()
    if tf_u.startswith("M"):
        return f"{int(tf_u[1:])}m"
    if tf_u.startswith("H"):
        return f"{int(tf_u[1:])}h"
    raise ValueError(f"Unsupported timeframe: {tf!r} (use M5/M15/M30/H1/H4...)")


def _decode_price_raw_u64_expr(col: str) -> pl.Expr:
    # Nautilus quote_tick parquet stores Price/Quantity as binary blobs.
    # For these catalogs, the first 8 bytes are the fixed-point raw value (UInt64, little-endian),
    # padded to 16 bytes. Raw is scaled by 1e16 (FIXED_PRECISION).
    arr = pl.col(col).bin.reinterpret(dtype=pl.Array(pl.UInt64, 2), endianness="little")
    return arr.arr.get(0)


def _scan_catalog_ticks(*, catalog_dir: Path, instrument: str) -> pl.LazyFrame:
    inst_dir = _instrument_folder_name(instrument)
    ticks_glob = catalog_dir / "data" / "quote_tick" / inst_dir / "*.parquet"
    if not ticks_glob.parent.exists():
        raise FileNotFoundError(f"Catalog instrument path not found: {ticks_glob.parent}")

    # Fail fast on empty directories to avoid a confusing late failure inside Polars.
    if not any(ticks_glob.parent.glob("*.parquet")):
        raise FileNotFoundError(f"No parquet files found under: {ticks_glob.parent}")

    try:
        return pl.scan_parquet(str(ticks_glob)).select(["ts_event", "bid_price", "ask_price"])
    except Exception as exc:
        # Surface a clearer error for corrupted/parsing failures.
        raise RuntimeError(f"Failed to scan parquet ticks at: {ticks_glob}") from exc


def _build_bars(
    *,
    lf_ticks: pl.LazyFrame,
    start_dt: datetime,
    end_dt_exclusive: datetime,
    every: str,
) -> pl.LazyFrame:
    lf = lf_ticks.with_columns(
        pl.col("ts_event")
        .cast(pl.Datetime(time_unit="ns", time_zone="UTC"), strict=False)
        .alias("timestamp"),
        (_decode_price_raw_u64_expr("bid_price").cast(pl.Float64) / 1e16).alias("bid"),
        (_decode_price_raw_u64_expr("ask_price").cast(pl.Float64) / 1e16).alias("ask"),
    )
    lf = lf.filter(
        (pl.col("timestamp") >= pl.lit(start_dt)) & (pl.col("timestamp") < pl.lit(end_dt_exclusive))
    )
    lf = lf.with_columns(((pl.col("bid") + pl.col("ask")) / 2.0).alias("mid")).select(
        ["timestamp", "mid"]
    )
    lf = lf.sort("timestamp")
    # IMPORTANT (temporal correctness): label bars at the RIGHT edge of the interval.
    # If we label on the left edge, a bar timestamp (t0) would summarize data from (t0..t1),
    # which can create look-ahead when consuming bars by timestamp.
    return (
        lf.group_by_dynamic(index_column="timestamp", every=every, closed="left", label="right")
        .agg(
            pl.col("mid").first().alias("open"),
            pl.col("mid").max().alias("high"),
            pl.col("mid").min().alias("low"),
            pl.col("mid").last().alias("close"),
            pl.len().alias("volume"),
        )
        .with_columns(pl.col("timestamp").cast(pl.Datetime(time_unit="ns", time_zone="UTC")))
    )


def _resolve_sessions(
    *,
    sessions_root: Path,
    sessions: list[str] | None,
    all_sessions: bool,
) -> list[Path]:
    root = sessions_root
    if not root.exists():
        raise FileNotFoundError(f"sessions_root not found: {root}")
    if not root.is_dir():
        raise NotADirectoryError(f"sessions_root is not a directory: {root}")

    all_dirs = [p for p in root.iterdir() if p.is_dir() and not p.name.endswith("_OLD")]
    if all_sessions:
        return sorted(all_dirs, key=lambda p: p.name.lower())

    wanted = [s.strip().upper() for s in (sessions or []) if s.strip()]
    if not wanted:
        raise ValueError("Provide --sessions or --all-sessions")

    selected: list[Path] = []
    for sess in wanted:
        matches = [p for p in all_dirs if p.name.upper().endswith(f"_{sess}")]
        if not matches:
            raise FileNotFoundError(f"No session catalog found for {sess!r} under {root}")
        stride1 = [p for p in matches if "stride1" in p.name.lower()]
        chosen = sorted(stride1 or matches, key=lambda p: p.name.lower())[0]
        selected.append(chosen)
    return selected


def _extract_session_name(catalog_dir_name: str) -> str:
    m = re.search(r"_stride\d+_(?P<session>.+)$", str(catalog_dir_name))
    if m:
        return str(m.group("session")).upper()
    return str(catalog_dir_name).split("_")[-1].upper()


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description="Build OHLCV bars from Nautilus native session catalogs (quote_tick parquet)."
    )
    p.add_argument("--start", required=True, help="Start date (YYYY-MM-DD, UTC).")
    p.add_argument("--end", required=True, help="End date (YYYY-MM-DD, UTC, inclusive).")
    p.add_argument(
        "--instrument",
        default=None,
        help="Instrument folder name inside catalog (default: from data/config.yaml).",
    )
    p.add_argument(
        "--sessions-root",
        default="data/catalog_native_sessions",
        help="Root folder containing session-sliced catalogs (repo-relative by default).",
    )
    p.add_argument(
        "--sessions", default=None, help="Comma-separated session names (e.g. EVENING,LATE_NY)."
    )
    p.add_argument(
        "--all-sessions",
        action="store_true",
        help="Build bars for all sessions under sessions-root.",
    )
    p.add_argument(
        "--timeframes",
        default="M5",
        help="Comma-separated timeframes (e.g. M5,M15,M30,H1,H4). Default M5.",
    )
    p.add_argument(
        "--out-dir",
        default="data/derived/bars_sessions",
        help="Output base dir (repo-relative by default).",
    )
    p.add_argument("--overwrite", action="store_true", help="Overwrite existing output files.")
    return p.parse_args()


def main() -> int:
    args = parse_args()
    repo_root = _repo_root()

    sessions_root = Path(args.sessions_root)
    sessions_root = (
        sessions_root.resolve()
        if sessions_root.is_absolute()
        else (repo_root / sessions_root).resolve()
    )

    out_dir = Path(args.out_dir)
    out_dir = out_dir.resolve() if out_dir.is_absolute() else (repo_root / out_dir).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)

    instrument = str(args.instrument) if args.instrument else _load_default_instrument()

    start_dt = _parse_date_utc(str(args.start), end_inclusive=False)
    end_dt_excl = _parse_date_utc(str(args.end), end_inclusive=True)

    sessions = [s.upper() for s in _split_csv(args.sessions)]
    tf_list = _timeframes(str(args.timeframes))

    catalogs = _resolve_sessions(
        sessions_root=sessions_root, sessions=sessions, all_sessions=bool(args.all_sessions)
    )

    for catalog_dir in catalogs:
        session_name = _extract_session_name(catalog_dir.name)
        lf_ticks = _scan_catalog_ticks(catalog_dir=catalog_dir, instrument=instrument)
        for tf in tf_list:
            every = _tf_to_every(tf)
            bars_lf = _build_bars(
                lf_ticks=lf_ticks, start_dt=start_dt, end_dt_exclusive=end_dt_excl, every=every
            )
            try:
                bars = bars_lf.collect(engine="streaming")
            except TypeError:  # pragma: no cover
                bars = bars_lf.collect()
            if bars.is_empty():
                raise ValueError(
                    f"No bars produced for session={session_name} tf={tf} in {args.start}..{args.end}"
                )

            safe_inst = _instrument_folder_name(instrument).replace(".", "_")
            out_path = (
                out_dir / session_name / tf / f"{safe_inst}_{tf}_{args.start}_{args.end}.parquet"
            )
            out_path.parent.mkdir(parents=True, exist_ok=True)
            if out_path.exists() and not args.overwrite:
                print(f"Skip (exists): {out_path}")
                continue
            bars.write_parquet(out_path)
            print(f"[{session_name}] {tf}: wrote {bars.height:,} bars -> {out_path}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
