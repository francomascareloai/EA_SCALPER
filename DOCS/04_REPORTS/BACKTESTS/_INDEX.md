# BACKTESTS INDEX - EA_SCALPER_XAUUSD

**Scope**: Organizar tudo de backtest/validação e listar próximos passos (ORACLE).

---

## 1) Onde estão os artefatos
- `DOCS/04_REPORTS/BACKTESTS/BASELINE_METRICS.md` — MA baseline (perde, PF<1).
- `DOCS/04_REPORTS/BACKTESTS/ABLATION_STUDY.md` — SMC ablation (filters isolados).
- `DOCS/04_REPORTS/BACKTESTS/EXHAUSTIVE_FILTER_STUDY_20251202_030018.md` — grid de filtros; melhor PF~1.05, retorno ~0.
- `DOCS/04_REPORTS/BACKTESTS/PHASE2_VALIDATION_*.md` — falhou (faltou closed_trades / bid-ask).
- `DOCS/04_REPORTS/BACKTESTS/FASE2_1_EA_LOGIC_RESULTS.json` — métricas irreais (bug em P&L/lots).
- Scripts mapeados em `scripts/backtest/README.md` (core = `realistic_backtester.py`, runners, legados).
- Scripts principais:
  - `scripts/backtest/realistic_backtester.py` — event-driven v2.0 (FTMO DD, latency, onnx mock).
  - `scripts/backtest/run_backtest.py`, `tick_backtester.py`, `backtest_strategy.py` — versões antigas.
  - `Python_Agent_Hub/ml_pipeline/backtesting/*.py` — utilitários (vectorbt, etc).
- Referências gerais: `DOCS/04_REPORTS/VALIDATION/BACKTEST_MASTER_PLAN.md`.

---

## 2) Estado atual (diagnóstico rápido)
- Dados: falta parquet/csv consistente com `bid,ask` (ou `mid_price` + `spread`) para XAUUSD recente.
- Backtester: pipeline Phase2 quebrou por:
  - `TickBacktester` sem atributo `closed_trades`.
  - Parquet sem `bid/ask`.
- Métricas infladas em `FASE2_1_EA_LOGIC_RESULTS.json` sugerem cálculo de P&L ou lot errado.
- Há lógica duplicada (full vs compat); `ea_logic_full.py` não foi carregado nos logs.

---

## 3) Plano de ação (TODO executivo)
**Dados**
- [ ] Consolidar tick data XAUUSD 2022–2024 em parquet com colunas: `timestamp,bid,ask` (ou `mid_price,spread`).
- [ ] Salvar em `data/ticks/xauusd_2022_2024.parquet` (ou path único) e documentar.

**Backtester**
- [ ] Garantir que `realistic_backtester.py` rode end-to-end com esse parquet (usar modo PESSIMISTIC).
- [ ] Corrigir cálculo de P&L/lotes no compat path (evitar PF irreais).
- [ ] Exportar `trades.csv` Oracle-compatible (entry/exit, pnl, lots, confluence).
- [ ] Adicionar atributo/coleção `closed_trades` ou adaptar scripts Phase2 para usar `trades`.
- [ ] Verificar carregamento do `ea_logic_full.py`; se ausente, documentar e travar em compat.

**Test matrix (FTMO-like)**
- V0: EA atual (sem Confluence v2 / ATR SLTP).
- V1: V0 + Confluence v2 + SL/TP ATR+regime (quando implementado).
- V2: V1 + Risk Engine FTMO (daily/total DD + circuit breaker).
- Para cada versão:
  - [ ] Run 5M ticks (sanity).
  - [ ] Run 50M ticks (ano cheio OOS 2024 ou 2025 YTD).
  - [ ] Export trades, equity.
  - [ ] Monte Carlo (5k bootstrap) → DD p95 < 15%.
  - [ ] FTMO breaches: P(Daily DD ≥5%) < 5%; P(Total DD ≥10%) < 2%.

**Oracle pipeline**
- [ ] Integrar com `scripts.oracle` (WFA, MC, PSR, prop_firm_validator).
- [ ] Gerar relatório final GO/NO-GO em `DOCS/04_REPORTS/VALIDATION/GO_NOGO_REPORT.md`.

---

## 4) Comandos sugeridos (quando dados estiverem prontos)
```
# Backtest realista
python scripts/backtest/realistic_backtester.py ^
  --ticks data/ticks/xauusd_2022_2024.parquet ^
  --mode pessimistic ^
  --min-confluence 65 ^
  --max-ticks 5000000

# Monte Carlo e GO/NO-GO (exemplo)
python -m scripts.oracle.monte_carlo --input data/trades.csv --sims 5000 --block
python -m scripts.oracle.prop_firm_validator --input data/trades.csv --firm ftmo
python -m scripts.oracle.go_nogo_validator --input data/trades.csv --output DOCS/04_REPORTS/VALIDATION/GO_NOGO_REPORT.md
```

---

## 5) Prioridade imediata (hoje)
1) Padronizar dataset de ticks com bid/ask.  
2) Rodar `realistic_backtester.py` em PESSIMISTIC e exportar `trades.csv`.  
3) Corrigir P&L/lotes se métricas ficarem irreais; reexecutar.  
4) Rodar Monte Carlo + prop firm validator; registrar em `DOCS/04_REPORTS/BACKTESTS/` (novo relatório).  
5) Atualizar este índice com resultados e links dos novos reports.

---

## 6) Responsáveis
- ORACLE: backtests, WFA, MC, relatórios.
- FORGE: fixes de código (backtester/EA), alinhamento de lógica.
- ARGUS: pesquisa de benchmarks (já consolidado em FUTURE_IMPROVEMENTS).

---

*Mantenha este índice atualizado a cada rodada de testes.*
