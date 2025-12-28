# Nautilus Gold Scalper – Operational Docs Index

This folder is the canonical home for **operational documentation** (how to run/configure/backtest/optimize/operate the Nautilus scalper).

## Index

- Configuration
  - `configuration/CONFIGURATION_GUIDE.md` (includes `risk_engine.*` keys: submit/modify rate + max notional)

- Reference
  - `reference/SCRIPTS.md` (includes **Readiness gate**: 1-command pytest+mypy+smoke-matrix; includes sizing A/B via `--sizing-engine`)
  - `reference/BARS_GENERATION.md`
  - `reference/NEWS_CALENDAR.md`
  - `reference/NEWS_CALENDAR_IMPLEMENTATION.md`
  - `reference/NEWS_TRADER_NOTES.md`
  - `reference/DATASETS.md` (native catalogs: stride 1/5/10/20, 2020+)

- Performance
  - `reference/SCRIPTS.md` (profiling: `--profile`, determinism via `trade_signature_v2.json`)
  - `reference/DATASETS.md` (stride choice and speed/fidelity trade-off)

- ML
  - `ml/ML_PIPELINE.md`
  - `ml/ONNX_MIGRATION_SUMMARY.md`

- Modules
  - `modules/indicators/FOOTPRINT_ANALYZER_STATUS.md`

## Rules (to prevent docs drift)

- New operational docs MUST be added under `nautilus_gold_scalper/docs/`.
- `nautilus_gold_scalper/INDEX.md` stays minimal and links here.
- Avoid putting operational docs under `src/**` or `scripts/**`; if needed, keep only a short pointer stub that links into `docs/`.
