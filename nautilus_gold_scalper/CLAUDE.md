# Claude Code Instructions (Nautilus Gold Scalper)

These instructions apply to work under `nautilus_gold_scalper/`.

## Canonical operational docs

- Operational documentation lives in: `nautilus_gold_scalper/docs/`
- Start here: `nautilus_gold_scalper/docs/INDEX.md`

## Rules (prevent lost/scattered docs)

- If you need to create or update *operational* docs (how to run/configure/backtest/optimize/operate):
  - Put the doc under `nautilus_gold_scalper/docs/`.
  - Add/link it from `nautilus_gold_scalper/docs/INDEX.md`.
  - Add a short link from `nautilus_gold_scalper/INDEX.md` if it’s a top-tier entrypoint.

- Avoid adding long operational docs under `nautilus_gold_scalper/src/**` or `nautilus_gold_scalper/scripts/**`.
  - If a doc needs to exist next to code for discoverability, keep it as a short pointer stub linking to the canonical doc under `docs/`.

## Single source of truth (configs)

- Strategy knobs: `nautilus_gold_scalper/configs/strategy_config.yaml`
- Data source paths: `nautilus_gold_scalper/data/config.yaml`

## Validation gate

- Before reporting “done”, run:
  - `.venv/bin/python -m pytest -q`
  - `.venv/bin/mypy --strict nautilus_gold_scalper/src nautilus_gold_scalper/scripts/optimize.py nautilus_gold_scalper/scripts/run_backtest.py nautilus_gold_scalper/scripts/backtest/run_backtest.py`
