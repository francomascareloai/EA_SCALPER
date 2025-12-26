# Bars Generation (Precompute)

This repo supports **fast screening** by precomputing OHLCV bars into `data/derived/` (not tracked by git).

## Full-market bars (from tick parquet)

Build bars from the tick parquet configured in `data/config.yaml` (`active_dataset.path`).

Example (2020-01-01 → 2025-11-28):

```bash
./.venv/bin/python -m nautilus_gold_scalper.scripts.data.build_m5_bars \
  --start 2020-01-01 \
  --end 2025-11-28 \
  --timeframes M5,M15,M30,H1,H4
```

Outputs (one file per TF):
- `data/derived/bars_full/M5/xauusd_M5_2020-01-01_2025-11-28.parquet`
- `data/derived/bars_full/M15/xauusd_M15_2020-01-01_2025-11-28.parquet`
- `data/derived/bars_full/M30/xauusd_M30_2020-01-01_2025-11-28.parquet`
- `data/derived/bars_full/H1/xauusd_H1_2020-01-01_2025-11-28.parquet`
- `data/derived/bars_full/H4/xauusd_H4_2020-01-01_2025-11-28.parquet`

## Session-sliced bars (from Nautilus native session catalogs)

Build bars from `data/catalog_native_sessions/*` (already session-sliced catalogs).

Example (all sessions, 2020-01-01 → 2025-11-28):

```bash
./.venv/bin/python -m nautilus_gold_scalper.scripts.data.build_bars_from_catalog \
  --start 2020-01-01 \
  --end 2025-11-28 \
  --sessions-root data/catalog_native_sessions \
  --all-sessions \
  --timeframes M5,M15,M30,H1,H4 \
  --out-dir data/derived/bars_sessions \
  --overwrite
```

Outputs:
- `data/derived/bars_sessions/<SESSION>/<TF>/XAUUSD_SIM_<TF>_2020-01-01_2025-11-28.parquet`

Example sessions: `ASIAN`, `LONDON`, `NY`, `OVERLAP`, `EVENING`, `LATE_NY`.

