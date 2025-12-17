from __future__ import annotations

"""
Slice a Nautilus ParquetDataCatalog into per-session catalogs (UTC/GMT).

This is the single canonical entrypoint for session splitting in this repo.

Sessions (UTC/GMT, half-open [start,end)):
- ASIAN:   00:00–07:00
- LONDON:  07:00–12:00
- OVERLAP: 12:00–15:00
- NY:      15:00–17:00
- LATE_NY: 17:00–21:00
- EVENING: 21:00–24:00

Example:
    .venv/bin/python scripts/data/slice_catalog_by_session.py \
      --source data/catalog_native/xauusd_2003_2025_stride1_COMPLETE \
      --output-root data/catalog_native_sessions \
      --overwrite
"""

import argparse
import json
import os
import shutil
import tempfile
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Iterable, Optional, TypeAlias, cast

import numpy as np
from numpy.typing import NDArray
import pyarrow as pa
import pyarrow.compute as pc
import pyarrow.parquet as pq


@dataclass(frozen=True)
class SessionWindow:
    name: str
    start_hour_gmt: int
    end_hour_gmt: int


# Session windows are UTC/GMT hours derived from `ts_event` (nanoseconds).
# Half-open intervals: [start, end), with EVENING treated as [21, 24).
SESSION_WINDOWS: dict[str, SessionWindow] = {
    "ASIAN": SessionWindow("ASIAN", 0, 7),
    "LONDON": SessionWindow("LONDON", 7, 12),
    "OVERLAP": SessionWindow("OVERLAP", 12, 15),
    "NY": SessionWindow("NY", 15, 17),
    "LATE_NY": SessionWindow("LATE_NY", 17, 21),
    "EVENING": SessionWindow("EVENING", 21, 24),
}


@dataclass
class _SessionWriteState:
    session: str
    out_dir: Path
    ticks_written: int = 0
    last_source_file: str | None = None


def _parse_utc_date_to_ns(date_str: str) -> int:
    # Accept YYYY-MM-DD or full ISO timestamps; treat naive as UTC.
    dt = datetime.fromisoformat(date_str.replace("Z", "+00:00"))
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return int(dt.astimezone(timezone.utc).timestamp() * 1_000_000_000)


def _format_ts_event_ns(ts_ns: int) -> str:
    secs = ts_ns // 1_000_000_000
    nanos = ts_ns % 1_000_000_000
    dt = datetime.fromtimestamp(secs, tz=timezone.utc)
    return dt.strftime("%Y-%m-%dT%H-%M-%S") + f"-{nanos:09d}Z"


def _ensure_empty_or_backup(path: Path, overwrite: bool) -> None:
    if not path.exists():
        return
    if not overwrite:
        raise FileExistsError(f"Output already exists: {path} (use --overwrite)")

    suffix = "_OLD"
    backup = Path(f"{path}{suffix}")
    idx = 2
    while backup.exists():
        backup = Path(f"{path}{suffix}_{idx}")
        idx += 1
    path.rename(backup)


def _detect_single_child_dir(parent: Path) -> Path:
    children = [p for p in parent.iterdir() if p.is_dir()]
    if len(children) != 1:
        raise ValueError(f"Expected exactly 1 directory in {parent}, found {len(children)}")
    return children[0]


def _iter_quote_tick_files(source_catalog: Path, instrument_dir_name: str) -> list[Path]:
    base = source_catalog / "data" / "quote_tick" / instrument_dir_name
    if not base.exists():
        raise FileNotFoundError(f"quote_tick folder not found: {base}")
    files = sorted(base.glob("*.parquet"))
    if not files:
        raise FileNotFoundError(f"No parquet files found under: {base}")
    return files


def _copy_currency_pair(source_catalog: Path, out_catalog: Path, instrument_dir_name: str) -> None:
    src_dir = source_catalog / "data" / "currency_pair" / instrument_dir_name
    if not src_dir.exists():
        raise FileNotFoundError(f"currency_pair folder not found: {src_dir}")
    dst_dir = out_catalog / "data" / "currency_pair" / instrument_dir_name
    dst_dir.mkdir(parents=True, exist_ok=True)

    for src_file in src_dir.glob("*.parquet"):
        shutil.copy2(src_file, dst_dir / src_file.name)


def _session_mask_from_hours(hours: pa.Array, session: SessionWindow) -> pa.Array:
    if session.start_hour_gmt < session.end_hour_gmt:
        return pc.and_(pc.greater_equal(hours, session.start_hour_gmt), pc.less(hours, session.end_hour_gmt))
    return pc.or_(pc.greater_equal(hours, session.start_hour_gmt), pc.less(hours, session.end_hour_gmt))


_HOUR_NS = np.uint64(3_600_000_000_000)

TsEventNsArray: TypeAlias = NDArray[np.uint64]
HoursUtcArray: TypeAlias = NDArray[np.uint8]
BoolMaskArray: TypeAlias = NDArray[np.bool_]
IndexArray: TypeAlias = NDArray[np.int64]


def _hour_utc_from_ts_event_ns(ts_event_ns: TsEventNsArray) -> HoursUtcArray:
    # ts_event is nanoseconds since epoch (UTC). Hour-of-day in [0, 23].
    return ((ts_event_ns // _HOUR_NS) % np.uint64(24)).astype(np.uint8, copy=False)


def _indices_for_session(
    *,
    hours_utc: HoursUtcArray,
    session: SessionWindow,
    base_mask: BoolMaskArray,
) -> IndexArray:
    if session.start_hour_gmt < session.end_hour_gmt:
        mask = base_mask & (hours_utc >= session.start_hour_gmt) & (hours_utc < session.end_hour_gmt)
    else:
        mask = base_mask & ((hours_utc >= session.start_hour_gmt) | (hours_utc < session.end_hour_gmt))
    idx = np.flatnonzero(mask).astype(np.int64, copy=False)
    return cast(IndexArray, idx)


def _load_checkpoint(path: Path) -> dict[str, object] | None:
    if not path.exists():
        return None
    loaded = json.loads(path.read_text(encoding="utf-8"))
    if isinstance(loaded, dict):
        return cast(dict[str, object], loaded)
    return None


def _write_checkpoint(path: Path, payload: dict[str, object]) -> None:
    path.write_text(json.dumps(payload, indent=2, sort_keys=True), encoding="utf-8")


def _default_output_prefix(source_catalog: Path) -> str:
    name = source_catalog.name
    for suffix in ("_COMPLETE", "_full", "_INCOMPLETE"):
        if name.endswith(suffix):
            return name[: -len(suffix)]
    return name


def slice_catalog_by_session(
    *,
    source_catalog: Path,
    output_root: Path,
    sessions: Iterable[str],
    instrument_dir_name: str | None,
    overwrite: bool,
    resume: bool,
    batch_size: int,
    start_ns: int | None,
    end_ns: int | None,
    limit_files: int | None,
) -> None:
    if instrument_dir_name is None:
        instrument_dir_name = _detect_single_child_dir(source_catalog / "data" / "quote_tick").name

    quote_files = _iter_quote_tick_files(source_catalog, instrument_dir_name)
    if limit_files is not None:
        quote_files = quote_files[:limit_files]

    output_prefix = _default_output_prefix(source_catalog)

    states: dict[str, _SessionWriteState] = {}
    for session in sessions:
        if session not in SESSION_WINDOWS:
            raise ValueError(f"Unknown session: {session}")
        out_catalog = output_root / f"{output_prefix}_{session}"
        if out_catalog.exists():
            if overwrite:
                _ensure_empty_or_backup(out_catalog, overwrite=True)
            elif not resume:
                raise FileExistsError(f"Output already exists: {out_catalog} (use --resume or --overwrite)")
        (out_catalog / "data" / "quote_tick" / instrument_dir_name).mkdir(parents=True, exist_ok=True)
        # Copy instrument definition once (idempotent).
        dst_cp_dir = out_catalog / "data" / "currency_pair" / instrument_dir_name
        if not dst_cp_dir.exists() or not list(dst_cp_dir.glob("*.parquet")):
            _copy_currency_pair(source_catalog, out_catalog, instrument_dir_name)
        states[session] = _SessionWriteState(session=session, out_dir=out_catalog)

    # Resume: skip already processed input files by comparing against checkpoint (per session).
    if resume:
        for state in states.values():
            ckpt = _load_checkpoint(state.out_dir / ".checkpoint.json")
            if ckpt and ckpt.get("source_catalog") == str(source_catalog.resolve()):
                ticks_written = ckpt.get("ticks_written", 0)
                if isinstance(ticks_written, int):
                    state.ticks_written = ticks_written
                elif isinstance(ticks_written, float):
                    state.ticks_written = int(ticks_written)
                elif isinstance(ticks_written, str) and ticks_written.isdigit():
                    state.ticks_written = int(ticks_written)
                last_file = ckpt.get("last_source_file")
                if isinstance(last_file, str) and last_file:
                    state.last_source_file = last_file

    # Use the maximum last processed file across sessions to keep progress aligned.
    last_done: str | None = None
    if resume:
        candidates = [s.last_source_file for s in states.values() if s.last_source_file]
        if candidates:
            last_done = max(candidates)

    files_to_process = quote_files
    if last_done is not None:
        files_to_process = [p for p in quote_files if p.name > last_done]

    print(f"[slice] source={source_catalog}")
    print(f"[slice] instrument_dir={instrument_dir_name}")
    print(f"[slice] output_root={output_root} prefix={output_prefix}")
    print(f"[slice] sessions={','.join(states.keys())}")
    print(f"[slice] input_files_total={len(quote_files)} to_process={len(files_to_process)} batch_size={batch_size}")
    if start_ns is not None or end_ns is not None:
        print(f"[slice] ts_event_range_ns=[{start_ns},{end_ns})")

    for src_path in files_to_process:
        pf = pq.ParquetFile(src_path)

        # For each session, write one parquet per input parquet (if non-empty).
        per_session_writer: dict[str, pq.ParquetWriter] = {}
        per_session_tmp: dict[str, Path] = {}
        per_session_min: dict[str, int] = {}
        per_session_max: dict[str, int] = {}
        per_session_rows: dict[str, int] = {}

        try:
            session_names = list(states.keys())
            session_windows = [SESSION_WINDOWS[s] for s in session_names]

            for batch in pf.iter_batches(batch_size=batch_size):
                ts_event_idx = batch.schema.get_field_index("ts_event")
                ts_event_arr = batch.column(ts_event_idx)
                ts_event_ns = cast(TsEventNsArray, ts_event_arr.to_numpy(zero_copy_only=False).astype(np.uint64, copy=False))
                hours_utc = _hour_utc_from_ts_event_ns(ts_event_ns)

                base_mask = cast(BoolMaskArray, np.ones(ts_event_ns.shape[0], dtype=np.bool_))
                if start_ns is not None:
                    base_mask &= ts_event_ns >= np.uint64(start_ns)
                if end_ns is not None:
                    base_mask &= ts_event_ns < np.uint64(end_ns)

                for session_name, session_window in zip(session_names, session_windows, strict=True):
                    idx = _indices_for_session(
                        hours_utc=hours_utc,
                        session=session_window,
                        base_mask=base_mask,
                    )
                    if idx.size == 0:
                        continue

                    # Min/max ts_event for naming.
                    ts_sel = ts_event_ns[idx]
                    min_ts = int(ts_sel.min())
                    max_ts = int(ts_sel.max())

                    per_session_min[session_name] = min(min_ts, per_session_min.get(session_name, min_ts))
                    per_session_max[session_name] = max(max_ts, per_session_max.get(session_name, max_ts))
                    per_session_rows[session_name] = per_session_rows.get(session_name, 0) + int(idx.size)

                    indices = pa.array(idx, type=pa.int64())
                    filtered_rb = pc.take(batch, indices)
                    filtered_table = pa.Table.from_batches([cast(pa.RecordBatch, filtered_rb)])

                    if session_name not in per_session_writer:
                        tmp_dir = states[session_name].out_dir / "data" / "quote_tick" / instrument_dir_name
                        tmp_dir.mkdir(parents=True, exist_ok=True)
                        fd, tmp_name = tempfile.mkstemp(prefix=".tmp_", suffix=".parquet", dir=str(tmp_dir))
                        os.close(fd)
                        tmp_path = Path(tmp_name)
                        per_session_tmp[session_name] = tmp_path
                        per_session_writer[session_name] = pq.ParquetWriter(
                            str(tmp_path),
                            filtered_table.schema,
                            compression="snappy",
                        )

                    per_session_writer[session_name].write_table(filtered_table)
        finally:
            for writer in per_session_writer.values():
                writer.close()

        # Finalize per-session files (rename tmp -> final).
        for session_name in states.keys():
            # Always advance checkpoint so `--resume` won't reprocess no-op files.
            states[session_name].last_source_file = src_path.name

            if session_name in per_session_tmp:
                tmp_path = per_session_tmp[session_name]
                out_dir = states[session_name].out_dir / "data" / "quote_tick" / instrument_dir_name
                start_s = _format_ts_event_ns(per_session_min[session_name])
                end_s = _format_ts_event_ns(per_session_max[session_name])
                final_path = out_dir / f"{start_s}_{end_s}.parquet"
                if final_path.exists():
                    # Idempotency on resume: if the final file is already there, drop temp and do not recount.
                    tmp_path.unlink(missing_ok=True)
                else:
                    tmp_path.rename(final_path)
                    states[session_name].ticks_written += int(per_session_rows.get(session_name, 0))

            _write_checkpoint(
                states[session_name].out_dir / ".checkpoint.json",
                {
                    "version": 4,
                    "instrument_dir": instrument_dir_name,
                    "session": session_name,
                    "ticks_written": states[session_name].ticks_written,
                    "source_catalog": str(source_catalog.resolve()),
                    "last_source_file": states[session_name].last_source_file,
                    "updated_utc": datetime.now(tz=timezone.utc).isoformat(),
                    "ts_event_start_ns": start_ns,
                    "ts_event_end_ns": end_ns,
                },
            )

        print(
            f"[ok] source_file={src_path.name} "
            + " ".join(
                f"{s}={per_session_rows.get(s, 0):,}"
                for s in states.keys()
                if per_session_rows.get(s, 0)
            )
        )

    print("[done] session slicing complete")
    for s, st in states.items():
        print(f"  {s}: ticks_written={st.ticks_written:,} out={st.out_dir}")


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Slice a Nautilus ParquetDataCatalog into per-session catalogs (UTC/GMT).")
    p.add_argument("--source", type=Path, required=True, help="Source ParquetDataCatalog directory")
    p.add_argument(
        "--output-root",
        type=Path,
        default=Path("data/catalog_native_sessions"),
        help="Destination root where session catalogs will be created",
    )
    p.add_argument(
        "--sessions",
        type=str,
        default=",".join(SESSION_WINDOWS.keys()),
        help="Comma-separated sessions (ASIAN,LONDON,OVERLAP,NY,LATE_NY,EVENING)",
    )
    p.add_argument(
        "--instrument-dir",
        type=str,
        default=None,
        help="Instrument folder name under data/quote_tick (e.g. XAUUSD.SIM). Auto-detected if omitted.",
    )
    p.add_argument("--overwrite", action="store_true", help="Move existing outputs aside to *_OLD")
    p.add_argument("--resume", action="store_true", help="Resume based on .checkpoint.json (skips processed source files)")
    p.add_argument("--batch-size", type=int, default=500_000, help="Rows per batch when scanning parquet")
    p.add_argument("--start", type=str, default=None, help="UTC start (YYYY-MM-DD or ISO). Inclusive.")
    p.add_argument("--end", type=str, default=None, help="UTC end (YYYY-MM-DD or ISO). Exclusive.")
    p.add_argument("--limit-files", type=int, default=None, help="Process only first N source parquet files (debug)")
    return p.parse_args()


def main() -> None:
    args = parse_args()
    if not args.source.exists():
        raise FileNotFoundError(str(args.source))
    sessions = [s.strip() for s in args.sessions.split(",") if s.strip()]
    start_ns = _parse_utc_date_to_ns(args.start) if args.start else None
    end_ns = _parse_utc_date_to_ns(args.end) if args.end else None

    slice_catalog_by_session(
        source_catalog=args.source,
        output_root=args.output_root,
        sessions=sessions,
        instrument_dir_name=args.instrument_dir,
        overwrite=args.overwrite,
        resume=args.resume,
        batch_size=args.batch_size,
        start_ns=start_ns,
        end_ns=end_ns,
        limit_files=args.limit_files,
    )


if __name__ == "__main__":
    main()
