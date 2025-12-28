# Nautilus Gold Scalper - Scripts (Fonte Única)

Esta pasta contém os **scripts oficiais** para rodar o robô (NautilusTrader) de forma organizada.

## Backtest (oficial)

- CLI principal (tick ou bars):
  - `python -m nautilus_gold_scalper.scripts.run_backtest --start 2024-11-01 --end 2024-11-07`
  - Defaults atuais: `--product mgc` e `--gateway tradovate`.
  - Dica performance: use `--feed bars` para iteração rápida; use `--feed ticks` para simulação mais detalhada.
  - Ticks (recomendado): use catálogos nativos 2020+ via `--catalog-stride {1,5,10,20}`.
    - Para screening rápido: `--catalog-stride 20` (default do `--source auto` para XAUUSD 2020+).
    - Para validação final (máxima fidelidade): `--catalog-stride 1`.
  - Stride (aproximação, legacy): use `--sample N` (ex.: `--sample 20` ≈ pegar 1 a cada 20 ticks).
  - Para screening rápido com barras prontas: `--bars-file ...` (suporta M5/M15; `--feed bars`).

### Comparar engines de position sizing (A/B)

O runner suporta trocar o engine de sizing sem editar YAML:

- `--sizing-engine custom` (default): usa `nautilus_gold_scalper.src.risk.position_sizer.PositionSizer`
- `--sizing-engine nautilus_fixed`: usa `nautilus_trader.risk.sizing.FixedRiskSizer`

Exemplo (mesmo window, gera artifacts com hashes determinísticos em `trade_signature_v2.json`):
- `python -m nautilus_gold_scalper.scripts.run_backtest --product xauusd --gateway rithmic --feed ticks --source auto --start 2024-01-02 --end 2024-01-05 --ltf-minutes 15 --reports full --out-dir nautilus_gold_scalper/_artifacts/backtests/sizing_compare/custom_20240102_20240105 --no-require-telemetry --risk 0.01 --sizing-engine custom --quiet`
- `python -m nautilus_gold_scalper.scripts.run_backtest --product xauusd --gateway rithmic --feed ticks --source auto --start 2024-01-02 --end 2024-01-05 --ltf-minutes 15 --reports full --out-dir nautilus_gold_scalper/_artifacts/backtests/sizing_compare/nautilus_fixed_20240102_20240105 --no-require-telemetry --risk 0.01 --sizing-engine nautilus_fixed --quiet`

Notas:
- Para XAUUSD, `--gateway` precisa ser `rithmic` ou `tradovate` (o runner usa esse enum mesmo em simulação).
- `--ltf-minutes` deve bater com `execution.ltf_bar_minutes` do YAML (default é 15).

## Compatibilidade

Alguns imports antigos em testes/planos usam `scripts.*` (package local). Para evitar quebrar, existem wrappers em:
- `nautilus_gold_scalper/scripts/run_backtest.py`

## Regra de organização

- **NÃO** criar scripts executáveis em `.planning/**/scripts/`.
- Coloque scripts do robô aqui (`nautilus_gold_scalper/scripts/`).
- Scripts genéricos de dados/ORACLE permanecem em `scripts/data/` e `scripts/oracle/`.

## Workflows (screening/otimização)

### Readiness gate (1 comando)

- Rodar gates de prontidão (pytest + mypy --strict + backtest smoke matrix ticks, source=auto):
  - `python -m nautilus_gold_scalper.scripts.workflows.validate_ready --start 2024-01-01 --end 2024-02-01`

**Nota (telemetria / Apex compliance):**
- O backtest runner tem um **hard-gate** de telemetria por padrão (`--require-telemetry`).
- Se você não passar `--telemetry-path` nem `--out-dir`, o runner falha com erro pedindo um destino.
- Para `--smoke-matrix`, o runner auto-cria `--out-dir` e grava `telemetry.jsonl` dentro dele.
- Para desabilitar o gate (não recomendado para validação Apex), use `--no-require-telemetry`.

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

## Apex Optimizer (Phase 10)

**Módulo completo de otimização com validação Apex e detecção de overfitting.**

### CLI (src/optimization/__main__.py)

```bash
# Dry run (mostra configuração sem executar)
python -m nautilus_gold_scalper.src.optimization --config configs/grids/smc_optimization_fast.yaml --dry-run

# Rodar otimização com modo específico
python -m nautilus_gold_scalper.src.optimization --config configs/grids/smc_optimization_fast.yaml \
  --mode random --trials 50 --parallelism 4

# Com feed de barras para iteração rápida
python -m nautilus_gold_scalper.src.optimization --config configs/grids/smc_optimization_fast.yaml \
  --feed bars --bars-file data/derived/xauusd_m5_2020_2025.parquet
```

### Modos de busca disponíveis

| Mode | Descrição | Uso recomendado |
|------|-----------|-----------------|
| `grid` | Busca exaustiva em grade | Espaço pequeno (<100 combinações) |
| `random` | Amostragem aleatória | Exploração inicial, espaço grande |
| `lhs` | Latin Hypercube Sampling | Cobertura uniforme do espaço |
| `bayesian` | Otimização bayesiana (Optuna) | Convergência eficiente |
| `successive_halving` | ASHA/HyperBand | Budget limitado, muitos trials |

### Layers de validação

1. **Layer 1**: Backtest básico (Sharpe, SQN, WFE, trades, Apex compliance)
2. **Layer 2**: Walk-Forward Analysis (train/test splits, WFE std)
3. **Layer 3a**: Monte Carlo Drawdown (block bootstrap, MC95DD < 4%)
4. **Layer 3b**: Ghost Test (baseline falsification, p < 0.05)
5. **Layer 3c**: Overfit Detection (cliff, island, regime bias warnings)

### Flags CLI importantes

| Flag | Descrição |
|------|-----------|
| `--dry-run` | Preview config sem executar |
| `--mode {grid,random,lhs,bayesian,successive_halving}` | Algoritmo de busca |
| `--trials N` | Número de trials (para random/bayesian) |
| `--parallelism N` | Workers paralelos |
| `--seed N` | Seed para reprodutibilidade |
| `--feed {ticks,bars}` | Fonte de dados |
| `--bars-file PATH` | Arquivo de barras (obrigatório se --feed bars) |
| `--train-start/--train-end` | Override de período de treino |

### Arquivo de configuração (YAML)

```yaml
# configs/grids/smc_optimization_fast.yaml
parameters:
  - name: threshold
    min: 0.1
    max: 1.0
    type: float
  - name: lookback
    min: 10
    max: 100
    type: int

search:
  mode: random
  trials: 100
  parallelism: 4
  seed: 42

wfa:
  n_splits: 5
  train_ratio: 0.7

stress:
  mc_simulations: 1000
  ghost_simulations: 500

overfitting:
  cliff_check: true
  island_check: true
  regime_bias_check: true
```

### Output

O optimizer gera um handoff JSON com:
- `best_params`: Parâmetros otimizados
- `metrics`: Sharpe, SQN, WFE, MC95DD, etc.
- `apex_compliant`: true/false
- `overfit_warnings`: Lista de alertas (cliff, island, regime bias)
- `recommendation`: GO / CONDITIONAL_GO / NO_GO

