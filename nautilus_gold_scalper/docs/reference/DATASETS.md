# Datasets (Nautilus Gold Scalper)

This document describes the canonical tick datasets used by the Nautilus Gold Scalper backtest runner.

## 1) Generic Parquet ticks (legacy)

- File (workspace path): `data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet`
- Storage: this file is a **symlink** to the external drive copy at:
  - `/mnt/d/EA_SCALPER_XAUUSD/data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet`

Notes:
- This is **not** a Nautilus native catalog layout.
- Use only for quick iteration or compatibility.

## 2) Nautilus native catalogs (recommended)

All of these are Nautilus `ParquetDataCatalog` layouts.

### 2020+ working set (consolidated 7d)

- Stride 1 (baseline, highest fidelity)
  - `data/catalog_native/xauusd_2003_2025_stride1_COMPLETE_filtered_from_20200101_consolidated_7d`

- Stride 5 (native)
  - `data/catalog_native/xauusd_2003_2025_stride5_filtered_from_20200101_consolidated_7d`

- Stride 10 (native)
  - `data/catalog_native/xauusd_2003_2025_stride10_filtered_from_20200101_consolidated_7d`

- Stride 20 (native)
  - `data/catalog_native/xauusd_2003_2025_stride20_filtered_from_20200101_consolidated_7d`

## Runner integration

Use the backtest runner catalog selection flag (see `nautilus_gold_scalper/scripts/backtest/run_backtest.py`) to pick `1|5|10|20` for native catalogs.
