# Nautilus Gold Scalper - Scripts (Fonte Única)

Esta pasta contém os **scripts oficiais** para rodar o robô (NautilusTrader) de forma organizada.

## Backtest (oficial)

- CLI principal (tick ou bars):
  - `python -m nautilus_gold_scalper.scripts.run_backtest --start 2024-11-01 --end 2024-11-07`
  - Defaults atuais: `--product mgc` e `--gateway tradovate`.
  - Dica performance: use `--feed bars` para iteração rápida; use `--feed ticks` para simulação mais detalhada.
  - Stride (aproximação): use `--sample N` (ex.: `--sample 20` ≈ pegar 1 a cada 20 ticks). Para produção/validação final, prefira `data/config.yaml` com dataset stride20 ou `--source catalog` para stride1 completo.
  - Para screening rápido com barras M5 prontas: `--bars-file Python_Agent_Hub/ml_pipeline/data/Bars_2020-2025XAUUSD_ftmo-M5-No Session.csv`

## Compatibilidade

Alguns imports antigos em testes/planos usam `scripts.*` (package local). Para evitar quebrar, existem wrappers em:
- `nautilus_gold_scalper/scripts/run_backtest.py`

## Regra de organização

- **NÃO** criar scripts executáveis em `.planning/**/scripts/`.
- Coloque scripts do robô aqui (`nautilus_gold_scalper/scripts/`).
- Scripts genéricos de dados/ORACLE permanecem em `scripts/data/` e `scripts/oracle/`.

## Workflows (screening/otimização)

### Readiness gate (1 comando)

- Rodar gates de prontidão (pytest + mypy --strict + backtest smoke matrix stride20):
  - `python -m nautilus_gold_scalper.scripts.workflows.validate_ready --start 2024-01-01 --end 2024-02-01`

- Rodar também validação lenta do catálogo stride1 (DuckDB phases 2-4):
  - `python -m nautilus_gold_scalper.scripts.workflows.validate_ready --with-data-validation`


- Otimização unificada (grid/random/bayesian/successive_halving):
  - `python nautilus_gold_scalper/scripts/optimize.py --config nautilus_gold_scalper/configs/grids/smc_optimization_fast.yaml --dry-run`
  - `python nautilus_gold_scalper/scripts/optimize.py --config nautilus_gold_scalper/configs/grids/smc_optimization_fast.yaml --mode successive_halving --trials 64`

- Grid search rápido focado em meta +$3000 / 20 dias (conta 50k) (LEGACY, mantido por compatibilidade):
  - `python -m nautilus_gold_scalper.scripts.workflows.grid_search_eval20d --start 2020-01-01 --end 2020-06-30`
  - Métricas “radar-safe”: `--max-daily-share 0.30 --min-positive-days-ratio 0.60 --min-operated-days 5`

### Preparar barras M5 (1x)

Para o grid search ficar realmente rápido, gere um arquivo de barras M5 (Parquet) uma vez:
- `python -m nautilus_gold_scalper.scripts.data.build_m5_bars --start 2020-01-01 --end 2025-12-31 --out data/derived/xauusd_m5_2020_2025.parquet`
