from __future__ import annotations

import argparse
import os
import re
import shutil
from dataclasses import dataclass
from pathlib import Path

import numpy as np
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
import yaml
from nautilus_trader.model.data import QuoteTick
from nautilus_trader.persistence.catalog import ParquetDataCatalog

_WINDOWS_DRIVE_RX = re.compile(r"^(?P<drive>[A-Za-z]):[\\/](?P<rest>.*)$")


def _normalize_cli_path(value: str) -> Path:
    """Normalize CLI paths across WSL + Windows.

    Supports both:
    - WSL style: /mnt/d/...
    - Windows style: D:\\... or D:/...
    """

    s = str(value).strip().strip('"').strip("'")
    m = _WINDOWS_DRIVE_RX.match(s)
    if m:
        drive = m.group("drive").lower()
        rest = m.group("rest").replace("\\", "/")
        return Path("/mnt") / drive / rest
    return Path(s)


def _format_bytes(n: int) -> str:
    # Simple, stable formatting (avoid locale issues)
    units = ["B", "KB", "MB", "GB", "TB"]
    size = float(n)
    for u in units:
        if size < 1024.0:
            return f"{size:.1f}{u}"
        size /= 1024.0
    return f"{size:.1f}PB"


def _estimate_tree_size_bytes(root: Path) -> int:
    total = 0
    for dirpath, _dirnames, filenames in os.walk(root):
        dp = Path(dirpath)
        for name in filenames:
            try:
                total += (dp / name).stat().st_size
            except FileNotFoundError:
                # File might disappear mid-walk; treat as 0.
                pass
    return total


def _nearest_existing_parent(path: Path) -> Path:
    p = path
    while not p.exists():
        parent = p.parent
        if parent == p:
            return p
        p = parent
    return p


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[3]


def _load_default_catalog_path() -> Path:
    repo_root = _repo_root()
    project_root = repo_root / "nautilus_gold_scalper"

    cfg_path = project_root / "data" / "config.yaml"
    cfg = yaml.safe_load(cfg_path.read_text(encoding="utf-8"))
    if not isinstance(cfg, dict):
        raise ValueError(f"Invalid YAML config (expected mapping): {cfg_path}")

    active = cfg.get("active_dataset", {})
    if not isinstance(active, dict):
        raise ValueError(f"Invalid YAML config (active_dataset not mapping): {cfg_path}")

    candidates: list[Path] = []

    cat = active.get("native_catalog_path")
    if cat:
        # Matches `run_backtest.py` path resolution semantics.
        candidates.append((project_root / str(cat)).expanduser())

    datasets = cfg.get("datasets", {})
    if isinstance(datasets, dict):
        stride1 = datasets.get("stride1_catalog", {})
        if isinstance(stride1, dict):
            p = stride1.get("path")
            if p:
                candidates.append((repo_root / str(p)).expanduser())

    for cand in candidates:
        resolved = cand.resolve()
        if resolved.exists():
            return resolved

    if candidates:
        raise FileNotFoundError(
            "Default native catalog path not found. Tried: "
            + ", ".join(str(p.resolve()) for p in candidates)
        )

    raise ValueError(f"No catalog path candidates found in {cfg_path}")


def _parse_date_utc(date_str: str) -> pd.Timestamp:
    s = str(date_str)
    if s.endswith("Z"):
        s = s[:-1] + "+00:00"
    ts = pd.Timestamp(s)
    if ts.tzinfo is None:
        ts = ts.tz_localize("UTC")
    else:
        ts = ts.tz_convert("UTC")
    return ts


def _count_parquet_files(catalog_dir: Path) -> int:
    data_dir = catalog_dir / "data"
    if not data_dir.exists():
        return 0
    return sum(1 for _ in data_dir.rglob("*.parquet"))


_FILENAME_RX = re.compile(
    r"^(?P<s_date>\d{4}-\d{2}-\d{2})T(?P<s_h>\d{2})-(?P<s_m>\d{2})-(?P<s_s>\d{2})-(?P<s_ns>\d{9})Z_"
    r"(?P<e_date>\d{4}-\d{2}-\d{2})T(?P<e_h>\d{2})-(?P<e_m>\d{2})-(?P<e_s>\d{2})-(?P<e_ns>\d{9})Z\.parquet$"
)


def _parse_filename_range(name: str) -> tuple[pd.Timestamp, pd.Timestamp] | None:
    m = _FILENAME_RX.match(name)
    if not m:
        return None

    def _to_iso(prefix: str) -> str:
        date = m.group(f"{prefix}_date")
        hh = m.group(f"{prefix}_h")
        mm = m.group(f"{prefix}_m")
        ss = m.group(f"{prefix}_s")
        ns = m.group(f"{prefix}_ns")
        return f"{date}T{hh}:{mm}:{ss}.{ns}Z"

    start = _parse_date_utc(_to_iso("s"))
    end = _parse_date_utc(_to_iso("e"))
    if end < start:
        return None

    return start, end


def _count_filtered_quote_tick_files(
    *,
    src_catalog: Path,
    start: pd.Timestamp | None,
    end: pd.Timestamp | None,
) -> tuple[int, int]:
    src_qt = src_catalog / "data" / "quote_tick"
    if not src_qt.exists():
        raise FileNotFoundError(f"Missing quote_tick directory: {src_qt}")

    total = 0
    keep = 0

    for inst_dir in src_qt.iterdir():
        if not inst_dir.is_dir():
            continue
        for f in inst_dir.glob("*.parquet"):
            total += 1
            ok = True
            if start is not None or end is not None:
                iv = _parse_filename_range(f.name)
                if iv is None:
                    ok = False
                else:
                    a, b = iv
                    if start is not None and b < start:
                        ok = False
                    if end is not None and a > end:
                        ok = False
            if ok:
                keep += 1

    return total, keep


def _sample_arrow_table_stride(table: pa.Table, *, stride: int) -> pa.Table:
    if stride <= 1:
        return table
    n = table.num_rows
    if n == 0:
        return table
    idx = np.arange(0, n, stride, dtype=np.int64)
    return table.take(pa.array(idx))


def _copy_filtered_quote_ticks(
    *,
    src_catalog: Path,
    out_catalog: Path,
    start: pd.Timestamp | None,
    end: pd.Timestamp | None,
    stride: int,
) -> None:
    """Copy only the parts of the catalog needed for QuoteTick backtests.

    This is intentionally conservative and only copies:
    - data/quote_tick/** (filtered by filename timestamp overlap if start/end provided)
    - data/currency_pair/** (small instrument metadata)
    - root checkpoint json if present

    If `stride` > 1, downsample ticks while copying by taking every Nth row within each file.
    Output remains a Nautilus-native ParquetDataCatalog layout.
    """

    if out_catalog.exists():
        raise FileExistsError(f"Output directory already exists: {out_catalog}")

    out_catalog.mkdir(parents=True)
    (out_catalog / "data").mkdir(parents=True, exist_ok=True)

    # Copy checkpoint metadata if present
    for meta in (".checkpoint.json",):
        src_meta = src_catalog / meta
        if src_meta.exists():
            shutil.copy2(src_meta, out_catalog / meta)

    # Copy currency_pair metadata (tiny)
    src_cp = src_catalog / "data" / "currency_pair"
    if src_cp.exists():
        dst_cp = out_catalog / "data" / "currency_pair"
        shutil.copytree(src_cp, dst_cp)

    # Copy filtered quote ticks
    src_qt = src_catalog / "data" / "quote_tick"
    if not src_qt.exists():
        raise FileNotFoundError(f"Missing quote_tick directory: {src_qt}")

    for inst_dir in src_qt.iterdir():
        if not inst_dir.is_dir():
            continue
        dst_inst = out_catalog / "data" / "quote_tick" / inst_dir.name
        dst_inst.mkdir(parents=True, exist_ok=True)

        for f in inst_dir.glob("*.parquet"):
            keep = True
            if start is not None or end is not None:
                iv = _parse_filename_range(f.name)
                if iv is None:
                    keep = False
                else:
                    a, b = iv
                    if start is not None and b < start:
                        keep = False
                    if end is not None and a > end:
                        keep = False
            if not keep:
                continue

            if stride <= 1:
                shutil.copy2(f, dst_inst / f.name)
                continue

            table = pq.read_table(f)
            table = _sample_arrow_table_stride(table, stride=stride)
            if table.num_rows == 0:
                continue
            pq.write_table(
                table,
                where=str(dst_inst / f.name),
                row_group_size=5000,
            )


@dataclass(frozen=True, slots=True)
class Plan:
    source_catalog: Path
    output_catalog: Path
    period: pd.Timedelta
    start: pd.Timestamp | None
    end: pd.Timestamp | None
    ensure_contiguous_files: bool
    filtered_copy: bool
    stride: int


def _build_plan(args: argparse.Namespace) -> Plan:
    src = (
        _normalize_cli_path(args.catalog_dir).expanduser()
        if args.catalog_dir
        else _load_default_catalog_path()
    )
    src = src.resolve()

    start = _parse_date_utc(args.start) if args.start else None
    end = _parse_date_utc(args.end) if args.end else None

    stride = max(1, int(args.stride))

    if args.output_dir:
        out = _normalize_cli_path(args.output_dir).expanduser().resolve()
    else:
        base = src.name
        if stride > 1:
            base = f"{base}_stride{stride}"

        if args.filtered_copy and (start is not None or end is not None):
            if start is not None and end is not None:
                suffix = f"filtered_{start.strftime('%Y%m%d')}_{end.strftime('%Y%m%d')}"
            elif start is not None:
                suffix = f"filtered_from_{start.strftime('%Y%m%d')}"
            else:
                end_ts = end
                assert end_ts is not None
                suffix = f"filtered_until_{end_ts.strftime('%Y%m%d')}"
            out = src.with_name(f"{base}_{suffix}_consolidated_{args.period_days}d")
        else:
            out = src.with_name(f"{base}_consolidated_{args.period_days}d")

    return Plan(
        source_catalog=src,
        output_catalog=out,
        period=pd.Timedelta(days=int(args.period_days)),
        start=start,
        end=end,
        ensure_contiguous_files=bool(args.ensure_contiguous_files),
        filtered_copy=bool(args.filtered_copy),
        stride=stride,
    )


def _parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description=(
            "Consolidate a Nautilus ParquetDataCatalog for faster queries (reduces file fragmentation). "
            "SAFETY: never modifies the source catalog; always copies to an output directory."
        )
    )
    p.add_argument(
        "--catalog-dir",
        default=None,
        help=(
            "Source catalog directory. Defaults to `nautilus_gold_scalper/data/config.yaml` "
            "(native catalog path with fallback)."
        ),
    )
    p.add_argument(
        "--output-dir",
        default=None,
        help=(
            "Output directory for consolidated catalog copy. Default: <catalog-dir>_consolidated_<period>d."
        ),
    )
    p.add_argument(
        "--period-days",
        type=int,
        default=7,
        help="Consolidation period size in days (recommended: 7 or 30 for stride1).",
    )
    p.add_argument(
        "--stride",
        type=int,
        default=1,
        help=(
            "Optional downsampling stride applied during filtered copy (take every Nth tick within each file). "
            "Use 1 for full fidelity."
        ),
    )
    p.add_argument(
        "--start", default=None, help="Optional start (YYYY-MM-DD or ISO datetime, UTC)."
    )
    p.add_argument("--end", default=None, help="Optional end (YYYY-MM-DD or ISO datetime, UTC).")
    p.add_argument(
        "--ensure-contiguous-files",
        action="store_true",
        help=(
            "Use period boundary naming for output files (recommended). "
            "If not set, Nautilus uses actual data timestamps for file naming."
        ),
    )
    p.add_argument(
        "--filtered-copy",
        action="store_true",
        help=(
            "Copy only QuoteTick + minimal metadata, filtering by filename timestamp overlap with --start/--end. "
            "Useful to create a smaller 2020+ working catalog before consolidation."
        ),
    )
    p.add_argument(
        "--no-copy",
        action="store_true",
        help=(
            "DANGEROUS: operate directly on --catalog-dir (destructive). "
            "Requires --i-understand-this-deletes-files."
        ),
    )
    p.add_argument(
        "--i-understand-this-deletes-files",
        action="store_true",
        help="Required when using --no-copy.",
    )
    p.add_argument(
        "--dry-run",
        action="store_true",
        help="Print what would be done (including file counts) and exit.",
    )
    return p.parse_args()


def main() -> int:
    args = _parse_args()
    plan = _build_plan(args)

    if args.no_copy and not args.i_understand_this_deletes_files:
        raise ValueError("--no-copy requires --i-understand-this-deletes-files")

    src = plan.source_catalog
    out = plan.output_catalog if not args.no_copy else plan.source_catalog

    if not src.exists():
        raise FileNotFoundError(f"Catalog not found: {src}")

    src_files = _count_parquet_files(src)

    print("=" * 60)
    print("NAUTILUS CATALOG CONSOLIDATION")
    print("=" * 60)
    print(f"Source: {src}")
    print(f"Output: {out}")
    print(f"Period: {plan.period}")
    print(f"Range:  {plan.start} -> {plan.end}")
    print(f"Filtered copy: {plan.filtered_copy}")
    print(f"Source parquet files: {src_files}")

    if plan.filtered_copy and (plan.start is not None or plan.end is not None):
        total, keep = _count_filtered_quote_tick_files(
            src_catalog=src, start=plan.start, end=plan.end
        )
        print(f"QuoteTick parquet files: {total}")
        print(f"QuoteTick files kept:   {keep}")

        # Show size estimate early to help choose output disk.
        # Note: this is an overestimate if consolidation merges files.
        src_qt = src / "data" / "quote_tick"
        est_bytes = 0
        for inst_dir in src_qt.iterdir():
            if not inst_dir.is_dir():
                continue
            for f in inst_dir.glob("*.parquet"):
                iv = _parse_filename_range(f.name)
                if iv is None:
                    continue
                a, b = iv
                if plan.start is not None and b < plan.start:
                    continue
                if plan.end is not None and a > plan.end:
                    continue
                try:
                    est_bytes += f.stat().st_size
                except FileNotFoundError:
                    pass
        stride_note = f" (stride={plan.stride})" if plan.stride > 1 else ""
        est_scaled = int(est_bytes / float(plan.stride)) if plan.stride > 1 else est_bytes
        print(f"Estimated QuoteTick bytes to copy{stride_note}: {_format_bytes(est_scaled)}")

    if args.dry_run:
        return 0

    if not args.no_copy:
        if out.exists():
            raise FileExistsError(f"Output directory already exists: {out}")
        if plan.filtered_copy:
            print("Copying catalog (filtered safe mode)...")
            _copy_filtered_quote_ticks(
                src_catalog=src,
                out_catalog=out,
                start=plan.start,
                end=plan.end,
                stride=plan.stride,
            )
        else:
            print("Copying catalog (safe mode)...")
            shutil.copytree(src, out)

    out_files_before = _count_parquet_files(out)

    catalog = ParquetDataCatalog(str(out))

    # For stride1 catalogs, period-based consolidation avoids creating huge single files.
    catalog.consolidate_data_by_period(
        data_cls=QuoteTick,
        identifier=None,
        period=plan.period,
        start=plan.start,
        end=plan.end,
        ensure_contiguous_files=plan.ensure_contiguous_files,
    )

    out_files_after = _count_parquet_files(out)

    print("=" * 60)
    print("DONE")
    print("=" * 60)
    print(f"Output parquet files before: {out_files_before}")
    print(f"Output parquet files after:  {out_files_after}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
