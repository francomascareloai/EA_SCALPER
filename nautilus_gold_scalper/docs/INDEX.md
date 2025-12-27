# Nautilus Gold Scalper – Operational Docs Index

This folder is the canonical home for **operational documentation** (how to run/configure/backtest/optimize/operate the Nautilus scalper).

## Index

- Configuration
  - `configuration/CONFIGURATION_GUIDE.md`

- Reference
  - `reference/SCRIPTS.md` (includes **Readiness gate**: 1-command pytest+mypy+smoke-matrix)
  - `reference/BARS_GENERATION.md`
  - `reference/NEWS_CALENDAR.md`
  - `reference/NEWS_CALENDAR_IMPLEMENTATION.md`
  - `reference/NEWS_TRADER_NOTES.md`

- ML
  - `ml/ML_PIPELINE.md`
  - `ml/ONNX_MIGRATION_SUMMARY.md`

- Modules
  - `modules/indicators/FOOTPRINT_ANALYZER_STATUS.md`

## Rules (to prevent docs drift)

- New operational docs MUST be added under `nautilus_gold_scalper/docs/`.
- `nautilus_gold_scalper/INDEX.md` stays minimal and links here.
- Avoid putting operational docs under `src/**` or `scripts/**`; if needed, keep only a short pointer stub that links into `docs/`.
