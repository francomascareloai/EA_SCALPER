# Script Registry - Use These, Don't Create New

**REGRA ABSOLUTA:** Os planos DEVEM usar estes scripts existentes. NÃO criar novos.

---

## Data Validation Scripts

| Task | Script Existente | Comando |
|------|------------------|---------|
| Validate catalog | `scripts/data/validate_nautilus_catalog.py` | `python -m scripts.data.validate_nautilus_catalog --catalog PATH` |
| Validate data quality | `scripts/oracle/validate_data_v2.py` | `python -m scripts.oracle.validate_data_v2 --input FILE` |
| Validate data structure | `scripts/validate_data_structure.py` | `python scripts/validate_data_structure.py` |
| Phase 1-A.1 tick counts | `scripts/data/phase1a_tick_count.py` | `python -m scripts.data.phase1a_tick_count` |
| Phase 1-A gap detection | `scripts/data/phase1a_gap_detection.py` | `python -m scripts.data.phase1a_gap_detection` |

---

## Backtest Scripts

| Task | Script Existente | Comando |
|------|------------------|---------|
| Run backtest (CLI oficial) | `nautilus_gold_scalper/scripts/run_backtest.py` | `python -m nautilus_gold_scalper.scripts.run_backtest --start DATE --end DATE` |
| Tick feed (detalhado) | `nautilus_gold_scalper/scripts/run_backtest.py` | `python -m nautilus_gold_scalper.scripts.run_backtest --feed ticks --start DATE --end DATE` |
| Bars feed (rápido) | `nautilus_gold_scalper/scripts/run_backtest.py` | `python -m nautilus_gold_scalper.scripts.run_backtest --feed bars --start DATE --end DATE` |

---

## ORACLE Validation Suite

| Task | Script Existente | Comando |
|------|------------------|---------|
| **Full GO/NO-GO** | `scripts/oracle/go_nogo_validator.py` | `python -m scripts.oracle.go_nogo_validator --input trades.csv --n-trials 100` |
| Walk-Forward Analysis | `scripts/oracle/walk_forward.py` | `python -m scripts.oracle.walk_forward --input trades.csv --mode rolling --windows 16` |
| Monte Carlo | `scripts/oracle/monte_carlo.py` | `python -m scripts.oracle.monte_carlo --input trades.csv --simulations 5000 --block` |
| PSR/DSR | `scripts/oracle/deflated_sharpe.py` | `python -m scripts.oracle.deflated_sharpe --input returns.csv` |
| Prop Firm | `scripts/oracle/prop_firm_validator.py` | `python -m scripts.oracle.prop_firm_validator --input trades.csv --firm apex` |
| Apex Compliance | `nautilus_gold_scalper/scripts/validate_apex_compliance.py` | `python -m nautilus_gold_scalper.scripts.validate_apex_compliance --trades FILE` |
| Execution Sim | `scripts/oracle/execution_simulator.py` | `python -m scripts.oracle.execution_simulator --input trades.csv --mode pessimistic` |
| Metrics | `scripts/oracle/metrics.py` | Import: `from scripts.oracle.metrics import calculate_all_metrics` |
| Confidence | `scripts/oracle/confidence.py` | Import: `from scripts.oracle.confidence import calculate_confidence_score` |

---

## Data Conversion

| Task | Script Existente | Comando |
|------|------------------|---------|
| CSV → Nautilus | `scripts/data/convert_csv_to_nautilus_catalog.py` | CLI |
| Parquet → Nautilus | `scripts/data/convert_parquet_to_nautilus_native.py` | CLI |
| Ticks → M5 Bars (Parquet, screening rápido) | `nautilus_gold_scalper/scripts/data/build_m5_bars.py` | `python -m nautilus_gold_scalper.scripts.data.build_m5_bars --start 2020-01-01 --end 2025-12-31 --out data/derived/xauusd_m5_2020_2025.parquet` |

---

## Workflow Completo (Exemplo)

```bash
# 1. Validate data
python -m scripts.oracle.validate_data_v2 --input data/catalog_native/xauusd_2003_2025_stride1_COMPLETE/

# 2. Run backtest
python -m nautilus_gold_scalper.scripts.nautilus_backtest

# 3. Full ORACLE validation (WFA + MC + PSR + DSR + Apex)
python -m scripts.oracle.go_nogo_validator --input logs/backtest_latest/fills.csv --n-trials 100 --capital 100000

# 4. Apex compliance check
python -m nautilus_gold_scalper.scripts.validate_apex_compliance --trades logs/backtest_latest/fills.csv --account-size 100000
```

---

## Anti-Duplication Rules

1. **ANTES de criar qualquer script:** Verificar este registry
2. **Se funcionalidade existe:** USAR o script existente
3. **Se precisa adaptar:** Copiar e modificar (com referência ao original)
4. **Se realmente não existe:** Criar em `scripts/` ou `nautilus_gold_scalper/scripts/` (nunca em `.planning/`)
5. **Novos scripts DEVEM:** Passar por CRITIC review antes de usar

---

*Última atualização: 2025-12-16*
