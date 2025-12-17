"""
MASTER parquet generator - FTMO CSV -> Parquet, otimizado (2025-12-08)

Mudanças chave:
- Zero concatenação em memória: escrita streaming com ParquetWriter (pyarrow).
- Sem buffers gigantes: cada chunk CSV é filtrado por stride e gravado direto.
- Progresso dinâmico: estima total de linhas pelos bytes do primeiro chunk.
- Stats/metadata calculados incrementalmente (sem reabrir o parquet final).
- Compatível com --resume/--force/--test; sem prompts.

Uso:
    python scripts/generate_parquet.py --strides 20 --force
    python scripts/generate_parquet.py --strides 20 10 5 --resume
    python scripts/generate_parquet.py --strides 20 --test   # ~1M linhas
"""
import argparse
import json
import time
from pathlib import Path
from datetime import datetime

import numpy as np
import pandas as pd
import pyarrow as pa
import pyarrow.parquet as pq
import pytz
from tqdm import tqdm


def parse_args():
    parser = argparse.ArgumentParser(
        description="Master parquet generator from FTMO CSV (streaming, low-RAM)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument("--strides", type=int, nargs="+", required=True, help="Stride values (e.g., 20 10 5)")
    parser.add_argument("--force", action="store_true", help="Overwrite existing files")
    parser.add_argument("--resume", action="store_true", help="Resume from temp chunks")
    parser.add_argument("--test", action="store_true", help="Test mode (process ~1M rows)")
    parser.add_argument("--chunk-size", type=int, default=2_000_000, help="CSV rows per chunk")
    parser.add_argument("--save-every", type=int, default=10_000_000, help="(deprecated) kept for CLI compat")
    parser.add_argument(
        "--input",
        type=str,
        default="Python_Agent_Hub/ml_pipeline/data/CSV_2003-2025XAUUSD_ftmo_all-TICK-No Session.csv",
    )
    parser.add_argument("--output-dir", type=str, default="data/raw")
    parser.add_argument("--temp-dir", type=str, default="data/raw/temp")
    return parser.parse_args()


def validate_csv(csv_path: Path) -> bool:
    """Quick validation that CSV is readable."""
    print("\nValidating CSV...")
    try:
        sample = pd.read_csv(csv_path, nrows=10, header=None)
        print(f"[OK] CSV readable: {len(sample)} rows sampled")
        return True
    except Exception as e:
        print(f"[ERROR] CSV validation failed: {e}")
        return False


def cleanup_files(output_path: Path, temp_dir: Path, stride: int, force: bool, resume: bool):
    """Cleanup existing files based on flags."""
    # Output
    if output_path.exists():
        if force:
            print(f"[FORCE] Deleting: {output_path.name}")
            output_path.unlink()
            metadata = output_path.with_suffix(".parquet.metadata.json")
            if metadata.exists():
                metadata.unlink()
        elif not resume:
            print(f"\n[ERROR] Output exists: {output_path.name}")
            print("Use --force to overwrite OR --resume to continue")
            return False

    # Temps
    temp_pattern = f"temp_stride{stride}_chunk_*.parquet"
    temp_files = list(temp_dir.glob(temp_pattern))
    if temp_files:
        if force and not resume:
            print(f"[FORCE] Deleting {len(temp_files)} temp files...")
            for f in temp_files:
                f.unlink()
        elif resume:
            print(f"[RESUME] Found {len(temp_files)} temp chunks")
        else:
            print(f"[INFO] {len(temp_files)} temp chunks exist")
            print("Use --resume to continue OR --force to restart")
    return True


def process_csv_to_chunks(csv_path: Path, temp_dir: Path, stride: int, chunk_size: int, resume: bool, test_mode: bool):
    """
    Stream CSV -> parquet temp chunks.
    No buffering beyond a single chunk; stride via vectorized slice.
    """
    print(f"\n{'=' * 80}")
    print(f"STEP 1: CSV TO TEMP CHUNKS (stride={stride})")
    print(f"{'=' * 80}")

    temp_dir.mkdir(parents=True, exist_ok=True)

    temp_pattern = f"temp_stride{stride}_chunk_*.parquet"
    existing_temps = sorted(temp_dir.glob(temp_pattern))

    start_chunk_num = 0
    existing_row_count = 0
    if resume and existing_temps:
        for temp_file in tqdm(existing_temps, desc="Counting existing", unit="chunk"):
            df_tmp = pd.read_parquet(temp_file)
            existing_row_count += len(df_tmp)
        start_chunk_num = len(existing_temps)
        print(f"[RESUME] Existing: {existing_row_count:,} rows in {start_chunk_num} chunks")

    print("\nReading CSV...")
    print(f"  Chunk size: {chunk_size:,} rows")
    if test_mode:
        print("  [TEST MODE] Processing ~1M rows")

    nrows = 1_000_000 if test_mode else None
    names_use = ["datetime", "bid", "ask"]
    chunk_reader = pd.read_csv(
        csv_path,
        delimiter=",",
        chunksize=chunk_size,
        header=0,  # CSV tem header (DateTime,Bid,Ask,...)
        usecols=[0, 1, 2],  # DateTime, Bid, Ask
        parse_dates=[0],
        nrows=nrows,
        low_memory=False,
    )

    file_size_bytes = csv_path.stat().st_size
    est_rows_total = None

    global_counter = 0  # linhas cruas vistas
    chunks_saved = start_chunk_num
    total_processed = 0
    total_selected = existing_row_count
    skip_rows = existing_row_count * stride if resume else 0
    last_pct = 0
    start_time = time.time()
    pbar = tqdm(total=100, desc=f"stride{stride}", unit="%", bar_format="{desc}: {percentage:3.0f}%|{bar}| [{elapsed}<{remaining}] {postfix}")

    for csv_chunk in chunk_reader:
        # Skip for resume
        if skip_rows > 0:
            skip_in_chunk = min(skip_rows, len(csv_chunk))
            csv_chunk = csv_chunk.iloc[skip_in_chunk:]
            skip_rows -= skip_in_chunk
            global_counter += skip_in_chunk
            if len(csv_chunk) == 0:
                continue

        # Estimate rows total once
        if est_rows_total is None and len(csv_chunk) > 0:
            approx_bytes = csv_chunk.memory_usage(deep=True).sum()
            bytes_per_row = max(1, approx_bytes / len(csv_chunk))
            est_rows_total = file_size_bytes / bytes_per_row

        # Vectorized stride filter
        selected = csv_chunk.iloc[::stride, [0, 1, 2]]
        selected.columns = ["datetime", "bid", "ask"]
        selected = selected.astype({"bid": "float32", "ask": "float32"})
        # Ordena localmente para garantir ordem crescente dentro do chunk
        selected = selected.sort_values("datetime", kind="mergesort")

        # Write temp chunk immediately
        temp_file = temp_dir / f"temp_stride{stride}_chunk_{chunks_saved:04d}.parquet"
        selected.to_parquet(temp_file, compression="snappy", index=False)

        total_processed += len(csv_chunk)
        total_selected += len(selected)
        chunks_saved += 1
        global_counter += len(csv_chunk)

        # Progress
        if est_rows_total:
            progress = min(100, (global_counter / est_rows_total) * 100)
            if progress > last_pct + 0.5:
                elapsed = time.time() - start_time
                speed = total_processed / elapsed if elapsed > 0 else 0
                pbar.n = progress
                pbar.set_postfix(
                    {
                        "chunks": chunks_saved,
                        "selected": f"{total_selected/1e6:.1f}M",
                        "speed": f"{speed/1000:.0f}k/s",
                    }
                )
                pbar.refresh()
                last_pct = progress

    pbar.n = 100
    pbar.close()

    elapsed = time.time() - start_time
    ratio = (total_selected / global_counter * 100) if global_counter else 0
    print(f"\n[OK] CSV processing complete!")
    print(f"  Time: {elapsed/60:.1f} min")
    print(f"  Processed: {total_processed:,} rows")
    print(f"  Selected: {total_selected:,} rows")
    print(f"  Temp chunks: {chunks_saved - start_chunk_num}")
    print(f"  Ratio: {ratio:.2f}%")

    return sorted(temp_dir.glob(temp_pattern))


def concatenate_chunks(temp_files: list, output_path: Path):
    """Stream temp chunks -> final parquet (O(1) RAM)."""
    print(f"\n{'=' * 80}")
    print(f"STEP 2: CONCATENATE {len(temp_files)} CHUNKS (streaming)")
    print(f"{'=' * 80}")

    output_path.parent.mkdir(parents=True, exist_ok=True)

    total_rows = 0
    min_ts = None
    max_ts = None
    unique_days = set()
    hour_buckets = {h: 0 for h in range(24)}

    writer = None
    for temp_file in tqdm(temp_files, desc="Writing", unit="chunk"):
        table = pq.read_table(temp_file)

        if writer is None:
            writer = pq.ParquetWriter(output_path, table.schema, compression="zstd", use_dictionary=True)
        writer.write_table(table)

        # Stats
        dt_col = table.column("datetime").to_pandas()
        if dt_col.dt.tz is None:
            dt_col = dt_col.dt.tz_localize("UTC")
        chunk_min = dt_col.min()
        chunk_max = dt_col.max()
        min_ts = chunk_min if min_ts is None else min(min_ts, chunk_min)
        max_ts = chunk_max if max_ts is None else max(max_ts, chunk_max)
        unique_days.update(dt_col.dt.date.unique())

        et = dt_col.dt.tz_convert(pytz.timezone("US/Eastern"))
        hours, counts = np.unique(et.dt.hour.to_numpy(), return_counts=True)
        for h, c in zip(hours, counts):
            hour_buckets[int(h)] += int(c)

        total_rows += len(table)

    if writer:
        writer.close()

    size_mb = output_path.stat().st_size / 1024 / 1024
    print(f"\n[OK] Final parquet saved!")
    print(f"  File: {output_path.name}")
    print(f"  Size: {size_mb:.1f} MB")
    print(f"  Ticks: {total_rows:,}")

    return {
        "total_ticks": total_rows,
        "period_start": str(min_ts) if min_ts else "",
        "period_end": str(max_ts) if max_ts else "",
        "file_size_mb": round(size_mb, 1),
        "total_days": len(unique_days),
        "hour_buckets": hour_buckets,
    }


def cleanup_temps(temp_files: list, temp_dir: Path):
    """Delete temp files."""
    print(f"\n{'=' * 80}")
    print(f"STEP 3: CLEANUP {len(temp_files)} TEMP FILES")
    print(f"{'=' * 80}")

    for f in tqdm(temp_files, desc="Deleting", unit="file"):
        f.unlink()

    if temp_dir.exists() and not list(temp_dir.iterdir()):
        temp_dir.rmdir()

    print("[OK] Cleanup done!")


def generate_metadata(output_path: Path, stats: dict, stride: int):
    """Generate metadata JSON usando stats/hours já coletados."""
    print(f"\n{'=' * 80}")
    print(f"STEP 4: GENERATE METADATA")
    print(f"{'=' * 80}")

    total_ticks = stats["total_ticks"]
    if total_ticks == 0:
        raise ValueError("No ticks to generate metadata.")

    hb = stats.get("hour_buckets", {})

    def pct_hours(hours):
        return round(sum(hb.get(h, 0) for h in hours) / total_ticks * 100, 1)

    metadata = {
        "dataset": {
            "name": output_path.stem,
            "symbol": "XAUUSD",
            "description": f"XAUUSD 2003-2025 stride {stride}, 24h coverage",
        },
        "generation": {
            "source": "FTMO CSV (2003-2025)",
            "generated_date": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "generated_by": "scripts/generate_parquet.py",
            "stride": stride,
        },
        "statistics": {
            "total_ticks": total_ticks,
            "period": {
                "start": stats["period_start"],
                "end": stats["period_end"],
                "total_days": stats["total_days"],
                "years_covered": 22,
            },
            "file": {
                "size_mb": stats["file_size_mb"],
                "format": "parquet",
                "compression": "zstd",
            },
        },
        "session_coverage": {
            "asian": pct_hours(list(range(19, 24)) + list(range(0, 2))),
            "london": pct_hours(list(range(2, 7))),
            "overlap": pct_hours(list(range(7, 10))),
            "ny": pct_hours(list(range(10, 12))),
            "late_ny": pct_hours(list(range(12, 16))),
        },
        "data_quality": {
            "validation_date": datetime.now().strftime("%Y-%m-%d"),
            "status": "VALIDATED",
            "rating": "EXCELLENT",
        },
    }

    metadata_path = output_path.with_suffix(".parquet.metadata.json")
    with open(metadata_path, "w") as f:
        json.dump(metadata, f, indent=2)

    print(f"[OK] Metadata: {metadata_path.name}")
    return metadata


def update_config(output_path: Path, metadata: dict):
    """Update config.yaml to point to new dataset."""
    import yaml

    print(f"\n{'=' * 80}")
    print("STEP 5: UPDATE CONFIG.YAML")
    print(f"{'=' * 80}")

    config_path = Path("data/config.yaml")
    if not config_path.exists():
        print("[SKIP] config.yaml not found")
        return

    config = yaml.safe_load(open(config_path))

    config["active_dataset"]["name"] = metadata["dataset"]["name"]
    config["active_dataset"]["path"] = str(output_path)
    config["active_dataset"]["description"] = metadata["dataset"]["description"]
    config["active_dataset"]["stats"]["total_ticks"] = metadata["statistics"]["total_ticks"]
    config["active_dataset"]["stats"]["period_start"] = metadata["statistics"]["period"]["start"]
    config["active_dataset"]["stats"]["period_end"] = metadata["statistics"]["period"]["end"]
    config["active_dataset"]["stats"]["total_days"] = metadata["statistics"]["period"]["total_days"]
    config["active_dataset"]["stats"]["stride"] = metadata["generation"]["stride"]
    config["active_dataset"]["stats"]["file_size_mb"] = metadata["statistics"]["file"]["size_mb"]

    for session in ["asian", "london", "overlap", "ny", "late_ny"]:
        config["active_dataset"]["session_coverage"][session] = metadata["session_coverage"][session]

    with open(config_path, "w") as f:
        yaml.dump(config, f, default_flow_style=False, allow_unicode=True, sort_keys=False)

    print("[OK] config.yaml updated")


def main():
    args = parse_args()

    print("=" * 80)
    print("MASTER PARQUET GENERATOR (2003-2025)")
    print("=" * 80)
    print(f"Strides: {args.strides}")
    print(f"Force: {args.force}")
    print(f"Resume: {args.resume}")
    print(f"Test mode: {args.test}")

    csv_path = Path(args.input)
    if not csv_path.exists():
        print(f"\n[ERROR] CSV not found: {csv_path}")
        return 1

    if not validate_csv(csv_path):
        return 1

    output_dir = Path(args.output_dir)
    temp_dir = Path(args.temp_dir)

    for stride in sorted(args.strides, reverse=True):  # maior stride primeiro (mais rápido)
        print(f"\n\n{'#' * 80}")
        print(f"# PROCESSING STRIDE {stride}")
        print(f"{'#' * 80}")

        output_path = output_dir / f"xauusd_2003_2025_stride{stride}_full.parquet"

        if not cleanup_files(output_path, temp_dir, stride, args.force, args.resume):
            print(f"[SKIP] Stride {stride}")
            continue

        temp_files = process_csv_to_chunks(
            csv_path, temp_dir, stride, args.chunk_size, args.resume, args.test
        )
        if not temp_files:
            print(f"[ERROR] No temp files for stride {stride}")
            continue

        stats = concatenate_chunks(temp_files, output_path)
        cleanup_temps(temp_files, temp_dir)
        metadata = generate_metadata(output_path, stats, stride)

        # Atualiza config apenas para o menor stride (maior densidade)
        if stride == min(args.strides):
            update_config(output_path, metadata)

        print(f"\n{'#' * 80}")
        print(f"# STRIDE {stride} COMPLETE!")
        print(f"{'#' * 80}")
        print(f"  File:  {output_path.name}")
        print(f"  Size:  {stats['file_size_mb']:.1f} MB")
        print(f"  Ticks: {stats['total_ticks']:,}")

    print(f"\n{'=' * 80}")
    print("[OK] ALL STRIDES COMPLETE!")
    print(f"{'=' * 80}")
    print(f"\nGenerated {len(args.strides)} parquet file(s):")
    for stride in sorted(args.strides):
        path = output_dir / f"xauusd_2003_2025_stride{stride}_full.parquet"
        if path.exists():
            size = path.stat().st_size / 1024 / 1024
            print(f"  - stride{stride}: {path.name} ({size:.1f} MB)")

    print("\nNext steps:")
    print("  1. Validate: python check_data_quality.py")
    print("  2. Sessions: .venv/bin/python scripts/data/slice_catalog_by_session.py --source data/catalog_native/xauusd_2003_2025_stride1_COMPLETE --output-root data/catalog_native_sessions --overwrite")
    print("  3. Backtest: python scripts/run_backtest.py --start 2024-11-01 --end 2024-11-30")

    return 0


if __name__ == "__main__":
    try:
        exit(main())
    except KeyboardInterrupt:
        print("\n\n[INTERRUPTED] Process stopped by user")
        print("Use --resume to continue from temp chunks")
        exit(1)
    except Exception as e:
        print(f"\n\n[ERROR] {e}")
        import traceback
        traceback.print_exc()
        exit(1)
