from __future__ import annotations

import argparse
import json
import random
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Iterable, TypeAlias, cast

import numpy as np
from numpy.typing import NDArray
import pyarrow.parquet as pq


SESSION_HOURS_UTC: dict[str, set[int]] = {
    "ASIAN": set(range(0, 7)),
    "LONDON": set(range(7, 12)),
    "OVERLAP": set(range(12, 15)),
    "NY": set(range(15, 17)),
    "LATE_NY": set(range(17, 21)),
    "EVENING": set(range(21, 24)),
}

_HOUR_NS = np.uint64(3_600_000_000_000)
_SCALE_1E16 = 1e16  # Nautilus Price raw scale inferred from stored bytes.


TsNs: TypeAlias = NDArray[np.uint64]


@dataclass(frozen=True)
class SessionSampleStats:
    session: str
    sample_ticks: int
    crossed_quotes: int
    crossed_rate: float
    spread_mean: float
    spread_p50: float
    spread_p90: float
    spread_p99: float
    spread_max: float
    intertick_ms_p50: float
    intertick_ms_p99: float
    gap_gt_1s: int
    gap_gt_10s: int
    gap_max_s: float
    hours_observed: list[int]


def _parse_file_ts_event_ns(part: str) -> int:
    # Format: YYYY-MM-DDTHH-MM-SS-nnnnnnnnnZ (created from ts_event ns).
    if not part.endswith("Z"):
        raise ValueError(f"Expected 'Z' suffix: {part}")
    body = part[:-1]
    date_s, time_s = body.split("T", 1)
    hh_s, mm_s, ss_s, ns_s = time_s.split("-", 3)
    dt = datetime.fromisoformat(f"{date_s}T{hh_s}:{mm_s}:{ss_s}").replace(tzinfo=timezone.utc)
    return int(dt.timestamp() * 1_000_000_000) + int(ns_s)


def _range_from_filename(parquet_path: Path) -> tuple[int, int]:
    stem = parquet_path.stem
    a, b = stem.split("_", 1)
    return _parse_file_ts_event_ns(a), _parse_file_ts_event_ns(b)


def _decode_price_raw_i64(b: bytes) -> int:
    # Nautilus stores Price as fixed_size_binary[16]. For our values it fits in int64
    # and the high 8 bytes are sign-extension (all 0x00 for positive).
    lo = int.from_bytes(b[:8], byteorder="little", signed=True)
    hi = b[8:]
    sign = 0xFF if lo < 0 else 0x00
    if any(x != sign for x in hi):
        return int.from_bytes(b, byteorder="little", signed=True)
    return lo


def _utc_hours_from_ts_event_ns(ts_ns: TsNs) -> NDArray[np.uint8]:
    return ((ts_ns // _HOUR_NS) % np.uint64(24)).astype(np.uint8, copy=False)


def _pick_sample_files(files: list[Path], k: int, seed: int) -> list[Path]:
    if not files:
        return []
    if len(files) <= k:
        return files

    rng = random.Random(seed)
    picks: list[Path] = [files[0], files[len(files) // 2], files[-1]]
    remaining = [f for f in files if f not in picks]
    extra = rng.sample(remaining, k=max(0, k - len(picks)))
    picks.extend(extra)
    # de-dupe preserving order
    out: list[Path] = []
    seen: set[Path] = set()
    for p in picks:
        if p not in seen:
            out.append(p)
            seen.add(p)
    return out


def _iter_session_parquets(session_catalog: Path, instrument_dir: str) -> list[Path]:
    base = session_catalog / "data" / "quote_tick" / instrument_dir
    files = sorted(base.glob("*.parquet"))
    if not files:
        raise FileNotFoundError(f"No quote_tick parquet files found under: {base}")
    return files


def _infer_instrument_dir(session_catalog: Path) -> str:
    base = session_catalog / "data" / "quote_tick"
    children = [p for p in base.iterdir() if p.is_dir()]
    if len(children) != 1:
        raise ValueError(f"Expected exactly 1 instrument folder under {base}, found {len(children)}")
    return children[0].name


def sample_stats_for_session(
    *,
    session: str,
    session_catalog: Path,
    sample_files: int,
    sample_ticks_max: int,
    batch_size: int,
    seed: int,
) -> SessionSampleStats:
    instrument_dir = _infer_instrument_dir(session_catalog)
    files = _iter_session_parquets(session_catalog, instrument_dir)
    chosen = _pick_sample_files(files, k=sample_files, seed=seed)

    allowed_hours = SESSION_HOURS_UTC[session]
    hours_seen: set[int] = set()

    spreads: list[float] = []
    crossed = 0
    ts_all: list[np.uint64] = []

    remaining = sample_ticks_max
    for f in chosen:
        pf = pq.ParquetFile(f)
        for batch in pf.iter_batches(batch_size=batch_size, columns=["ts_event", "bid_price", "ask_price"]):
            n = batch.num_rows
            take_n = min(n, remaining)
            if take_n <= 0:
                break

            ts_ns = batch.column(0).to_numpy(zero_copy_only=False).astype(np.uint64, copy=False)[:take_n]
            bid_b = batch.column(1).to_numpy(zero_copy_only=False)[:take_n]
            ask_b = batch.column(2).to_numpy(zero_copy_only=False)[:take_n]

            hours = _utc_hours_from_ts_event_ns(ts_ns)
            hours_seen.update(int(x) for x in np.unique(hours).tolist())
            extra = set(int(x) for x in np.unique(hours).tolist()) - allowed_hours
            if extra:
                raise ValueError(f"Session {session}: found hours outside allowed: {sorted(extra)} in file={f.name}")

            # Decode prices (sample-only, ok to be Python-loop).
            for bb, ab in zip(bid_b, ask_b, strict=True):
                bid_raw = _decode_price_raw_i64(bb)
                ask_raw = _decode_price_raw_i64(ab)
                if bid_raw > ask_raw:
                    crossed += 1
                spreads.append((ask_raw - bid_raw) / _SCALE_1E16)

            ts_all.append(ts_ns)
            remaining -= take_n
            if remaining <= 0:
                break
        if remaining <= 0:
            break

    if not spreads or not ts_all:
        raise ValueError(f"No sample ticks collected for session={session} at {session_catalog}")

    ts_concat = np.concatenate(ts_all).astype(np.uint64, copy=False)
    ts_concat.sort()
    diffs_ns = np.diff(ts_concat.astype(np.int64, copy=False))
    diffs_ms = (diffs_ns / 1_000_000.0) if diffs_ns.size else np.array([], dtype=np.float64)

    gap_gt_1s = int(np.sum(diffs_ns > 1_000_000_000)) if diffs_ns.size else 0
    gap_gt_10s = int(np.sum(diffs_ns > 10_000_000_000)) if diffs_ns.size else 0
    gap_max_s = float(diffs_ns.max() / 1_000_000_000.0) if diffs_ns.size else 0.0

    spread_arr = np.asarray(spreads, dtype=np.float64)
    q = cast(NDArray[np.float64], np.quantile(spread_arr, np.array([0.5, 0.9, 0.99], dtype=np.float64)))
    p50 = float(q[0])
    p90 = float(q[1])
    p99 = float(q[2])
    it_p50 = float(np.quantile(diffs_ms, 0.5)) if diffs_ms.size else 0.0
    it_p99 = float(np.quantile(diffs_ms, 0.99)) if diffs_ms.size else 0.0

    return SessionSampleStats(
        session=session,
        sample_ticks=int(spread_arr.size),
        crossed_quotes=crossed,
        crossed_rate=(crossed / float(spread_arr.size)) if spread_arr.size else 0.0,
        spread_mean=float(spread_arr.mean()),
        spread_p50=float(p50),
        spread_p90=float(p90),
        spread_p99=float(p99),
        spread_max=float(spread_arr.max()),
        intertick_ms_p50=it_p50,
        intertick_ms_p99=it_p99,
        gap_gt_1s=gap_gt_1s,
        gap_gt_10s=gap_gt_10s,
        gap_max_s=gap_max_s,
        hours_observed=sorted(hours_seen),
    )


def _total_rows_from_metadata(files: Iterable[Path]) -> int:
    total = 0
    for f in files:
        pf = pq.ParquetFile(f)
        total += int(pf.metadata.num_rows)
    return total


def validate_sessions(
    *,
    sessions_root: Path,
    sample_files: int,
    sample_ticks: int,
    batch_size: int,
    seed: int,
    output_json: Path,
) -> dict[str, Any]:
    results: dict[str, Any] = {
        "timestamp_utc": datetime.now(tz=timezone.utc).isoformat(),
        "sessions_root": str(sessions_root.resolve()),
        "sample_files_per_session": sample_files,
        "sample_ticks_per_session": sample_ticks,
        "batch_size": batch_size,
        "seed": seed,
        "sessions": {},
    }

    for session in SESSION_HOURS_UTC.keys():
        catalog = sessions_root / f"xauusd_2003_2025_stride1_{session}"
        if not catalog.exists():
            raise FileNotFoundError(f"Missing session catalog: {catalog}")

        instrument_dir = _infer_instrument_dir(catalog)
        files = _iter_session_parquets(catalog, instrument_dir)
        total_rows = _total_rows_from_metadata(files)
        start_ns, end_ns = _range_from_filename(files[0])[0], _range_from_filename(files[-1])[1]

        stats = sample_stats_for_session(
            session=session,
            session_catalog=catalog,
            sample_files=sample_files,
            sample_ticks_max=sample_ticks,
            batch_size=batch_size,
            seed=seed,
        )

        results["sessions"][session] = {
            "catalog": str(catalog),
            "instrument_dir": instrument_dir,
            "files": len(files),
            "total_ticks": total_rows,
            "range": {"start_ns": start_ns, "end_ns": end_ns},
            "sample": stats.__dict__,
        }

    output_json.parent.mkdir(parents=True, exist_ok=True)
    output_json.write_text(json.dumps(results, indent=2, sort_keys=True), encoding="utf-8")
    return results


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Statistical validation for per-session Nautilus catalogs (stride=1).")
    p.add_argument("--sessions-root", type=Path, default=Path("data/catalog_native_sessions"))
    p.add_argument("--sample-files", type=int, default=8, help="Parquet files sampled per session")
    p.add_argument("--sample-ticks", type=int, default=200_000, help="Max ticks sampled per session")
    p.add_argument("--batch-size", type=int, default=500_000)
    p.add_argument("--seed", type=int, default=1337)
    p.add_argument("--output", type=Path, default=Path("logs/session_catalogs_stats.json"))
    return p.parse_args()


def main() -> None:
    args = parse_args()
    validate_sessions(
        sessions_root=args.sessions_root,
        sample_files=args.sample_files,
        sample_ticks=args.sample_ticks,
        batch_size=args.batch_size,
        seed=args.seed,
        output_json=args.output,
    )
    print("[OK] Session catalogs statistical validation complete")
    print(f"  output={args.output}")


if __name__ == "__main__":
    main()
