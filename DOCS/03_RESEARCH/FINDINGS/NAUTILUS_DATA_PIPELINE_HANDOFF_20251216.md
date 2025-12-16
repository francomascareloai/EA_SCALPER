# Nautilus Data Pipeline Handoff (XAUUSD) — 2025-12-16

## Goal

Build reliable, crash-safe datasets for XAUUSD research/backtesting:

- Convert a huge FTMO tick CSV into a NautilusTrader-native `ParquetDataCatalog` ("FULL catalog") with safe resume.
- Produce per-session Nautilus catalogs (ASIAN/LONDON/OVERLAP/NY/LATE_NY/EVENING) from the FULL catalog for session-specific backtests.
- Operate safely under WSL2 RAM constraints (avoid OOM) using windowed slicing, conservative chunking, checkpoints, and overwrite/backups.

This document is a handoff summary for another agent to continue.

## Environment

- OS: WSL2 (Linux 6.6.x, 14GB RAM typical reported)
- Python: 3.12
- Repo root: `/home/franco/projetos/EA_SCALPER_XAUUSD`

## Datasets

### FULL Nautilus catalog

Primary artifact is a Nautilus `ParquetDataCatalog` containing `QuoteTick` data.

- Instrument id used throughout: `XAU/USD.SIM`
- FULL catalog directory patterns used:
  - `data/catalog_native/xauusd_2003_2025_stride1_full` (stride=1)
  - `data/catalog_native/xauusd_2003_2025_stride20_full` (downsampled, stride=20)

Notes:
- Parquet file ranges can span multiple days/months; this is normal because they follow chunk flush/write boundaries, not calendar partitions.

### Session catalogs

Session catalogs are also Nautilus `ParquetDataCatalog`s derived from the FULL catalog.

Expected output root:
- `data/catalog_native_sessions/`

Expected per-session outputs:
- `data/catalog_native_sessions/xauusd_2003_2025_stride1_ASIAN`
- `data/catalog_native_sessions/xauusd_2003_2025_stride1_LONDON`
- `data/catalog_native_sessions/xauusd_2003_2025_stride1_OVERLAP`
- `data/catalog_native_sessions/xauusd_2003_2025_stride1_NY`
- `data/catalog_native_sessions/xauusd_2003_2025_stride1_LATE_NY`
- `data/catalog_native_sessions/xauusd_2003_2025_stride1_EVENING`

Staging pattern:
- Writes go to `*_INCOMPLETE` first, then atomically renamed to the final directory.

## Session definition

Session windows are UTC/GMT hours derived from `ts_event` nanoseconds:

- ASIAN: 00:00–07:00
- LONDON: 07:00–12:00
- OVERLAP: 12:00–15:00
- NY: 15:00–17:00
- LATE_NY: 17:00–21:00
- EVENING: 21:00–00:00 (wrap)

Implemented in:
- `scripts/slice_catalog_by_session.py`

## Key scripts (current state)

### 1) CSV → Nautilus FULL catalog

File:
- `scripts/convert_csv_to_nautilus_catalog.py`

Capabilities:
- `--resume` crash-safe via checkpoint (slower)
- `--resume-fast` crash-safe via checkpoint including `byte_offset` (fast + deterministic)
- `--migrate-checkpoint-to-fast` to upgrade an existing checkpoint to include `byte_offset`
- Optional filtering:
  - `--start-date` / `--end-date`
  - `--session` (GMT window filter)
- Quality gates:
  - `--max-invalid-row-rate`
  - `--max-crossed-quote-rate`
  - `--fail-on-disjoint`

Important safety fence:
- Refuses `--resume-fast` if checkpoint `byte_offset==0` and output catalog is non-empty (prevents duplication).

### 2) FULL catalog → session catalogs (low-memory)

File:
- `scripts/slice_catalog_by_session.py`

Design:
- Reads `QuoteTick` from FULL `ParquetDataCatalog`.
- Writes directly to session catalog (no pandas), buffering only `--chunk-ticks` ticks per flush.
- Optional windowing (`--start/--end`) to keep working set small under WSL.
- Checkpoint per session in staging directory (refuses resume if window/source mismatch).
- `--overwrite` moves existing final output aside using `_OLD`, `_OLD_2`, ...

### 3) Orchestrate all sessions + windows sequentially

File:
- `scripts/run_session_slicing_full.py`

Purpose:
- Runs `slice_catalog_by_session.py` as subprocess.
- Sequential execution (one session at a time, one window at a time) to minimize RAM.
- Default windows (coarse):
  - 2003→2009
  - 2009→2014
  - 2014→2019
  - 2019→2025-12-01
- Default chunking tuned for low RAM:
  - `--chunk-ticks` default currently set conservatively (often run with 10k–20k)
  - `--checkpoint-every-ticks` commonly 20k–50k

Logging:
- Typical run uses `nohup ... > logs/session_slicing.log 2>&1 &`

## Operating procedures

### A) Build session catalogs from existing FULL catalog (recommended)

Conservative mode (min RAM):

```bash
nohup .venv/bin/python scripts/run_session_slicing_full.py \
  --source data/catalog_native/xauusd_2003_2025_stride1_full \
  --output-root data/catalog_native_sessions \
  --resume --overwrite \
  --chunk-ticks 10000 \
  --checkpoint-every-ticks 20000 \
  > logs/session_slicing.log 2>&1 &
```

Monitor:

```bash
tail -f logs/session_slicing.log
```

Notes:
- Expect temporary `rate=0/s` at the start of each window (catalog scan / iterator warm-up).
- Final lines per window/session: `[OK] session=... complete -> ... ticks_written=...`.

### B) If memory appears "stuck" at ~95%

On Linux/WSL, high RAM usage can be filesystem cache. Check `available`, not `used`:

```bash
free -h
cat /proc/meminfo | rg -n "^(MemTotal|MemFree|MemAvailable|Cached|AnonPages|SwapTotal|SwapFree)"
```

If `MemAvailable` is low and swap is rising, find the process:

```bash
ps aux --sort=-%mem | head -n 20
```

Kill runaway job if needed:

```bash
kill <pid>
```

The slicing pipeline is resume-safe; killing is recoverable.

## Validation / QA notes

Quality checks used previously:
- Windowed validations using `scripts/data/validate_nautilus_catalog.py` across multiple years.
- Additional invariants:
  - Monotonic timestamps
  - Crossed quotes (bid>ask) rate
  - Spread sanity

Key caveat:
- Ensure you query with instrument id `XAU/USD.SIM`.

## Known pitfalls

1) Running multi-session slicing concurrently can blow RAM.
   - Prefer sequential: one session at a time.

2) `--resume-fast` requires `byte_offset`.
   - If you have an old checkpoint without it, run `--migrate-checkpoint-to-fast`.

3) WSL "RAM 95%" can be cache, not leak.
   - Verify using `MemAvailable`.

4) Old staging dirs may exist.
   - Pipeline uses `_INCOMPLETE` and can overwrite with backups if `--overwrite`.

## What to do next (for the next agent)

1) Confirm which FULL catalog is canonical for research (likely stride=1 if disk allows).
2) Run the session slicing orchestration end-to-end with conservative chunking.
3) Run a small validation window on each session catalog before large backtests.
4) (Optional) If file counts become huge, consider a later compaction pass (rewrite Parquet) — not required for correctness.
