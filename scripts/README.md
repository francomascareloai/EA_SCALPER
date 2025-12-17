#
# Scripts (Fonte Única) - EA_SCALPER_XAUUSD
#
# Objetivo: evitar duplicação / bagunça de scripts gerados por fases do `.planning/`.
# Regra: scripts executáveis NÃO devem ficar em `.planning/**/scripts/`.
#

## Onde colocar o quê

- **Robô Nautilus (principal):** `nautilus_gold_scalper/scripts/`
- **Dados / conversões / catálogos:** `scripts/data/`
- **ORACLE (validações, MC/WFA/PSR/DSR/PBO):** `scripts/oracle/`
- **`.planning/`**: apenas documentação, templates e outputs (NUNCA scripts executáveis)

## Backtest (rápido → fiel)

- Screening rápido (M5 bars):
  - `python -m nautilus_gold_scalper.scripts.workflows.grid_search_eval20d --start 2020-01-01 --end 2020-06-30`
- Validação fiel (ticks) dos candidatos:
  - `python -m nautilus_gold_scalper.scripts.run_backtest --feed ticks --start 2020-01-01 --end 2020-06-30 --reports summary`

## Registry

- Scripts canônicos do `.planning` devem apontar para:
  - `.planning/phases/08-data-validation-backtest/SCRIPT_REGISTRY.md`

## Session slicing (catálogo Nautilus → por sessão)

- Script canônico: `scripts/data/slice_catalog_by_session.py`
- Exemplo (recriar sessões a partir do catálogo COMPLETE):
  - `.venv/bin/python scripts/data/slice_catalog_by_session.py --source data/catalog_native/xauusd_2003_2025_stride1_COMPLETE --output-root data/catalog_native_sessions --overwrite`
