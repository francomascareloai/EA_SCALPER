# Guia de Execução: Data Validation & Backtest Pipeline

**Data**: 2025-12-16
**Status**: Pronto para execução
**Planos**: 100% otimizados com ARGUS improvements

---

## ⚡ ARGUS Research Improvements (Onde Encontrar)

Cada arquivo de fase agora tem um **sumário das melhorias no TOPO** (logo após o título).
Para detalhes completos com código, veja a seção `## ARGUS Research Improvements` no **final** de cada arquivo.

| Fase | Principais Melhorias |
|------|---------------------|
| 1-A | DuckDB 1.0+, Polars streaming, pandas_market_calendars |
| 2 | DuckDB queries, zoneinfo (DST), HMM regime detection |
| 3 | zoneinfo (DST), per-session statistics |
| 4 | Cross-catalog hash, metadata audit |
| 5 | GJR-GARCH, Stylized Facts Battery, Lee-Mykland jumps |
| 6 | Block bootstrap, CPCV setup, DSR/PSR metrics |
| 7 | Monte Carlo block bootstrap, CPCV, per-regime validation |
| 8 | PSR≥0.85, Min 200 trades, SQN<5.0, CPCV≥0.6 |

**Report consolidado**: `DOCS/03_RESEARCH/FINDINGS/IMPROVEMENT_REPORT.md`

---

## Pré-Requisitos (Execute UMA VEZ antes de começar)

```bash
# 1. Ativar ambiente virtual
source .venv/bin/activate

# 2. Instalar dependências novas
pip install duckdb>=1.0.0 polars>=0.20.0 pandas-market-calendars>=4.0
pip install mlfinlab>=2.0.0 hmmlearn>=0.3.0 arch>=6.0.0 timeseriescv>=0.2.0
pip install pandera>=0.18.0

# 3. Verificar instalação
python -c "import duckdb, polars, arch; print('OK')"
```

---

## Ordem de Execução das Fases

| # | Fase | Comando Claude Code | Bloqueante |
|---|------|---------------------|------------|
| 1 | Phase 1-A | `/run-plan .planning/phases/08-data-validation-backtest/01-A-PHASE-PLAN.md` | SIM |
| 2 | Phase 2 | `/run-plan .planning/phases/08-data-validation-backtest/02-PHASE-PLAN.md` | SIM |
| 3 | Phase 3 | `/run-plan .planning/phases/08-data-validation-backtest/03-PHASE-PLAN.md` | SIM |
| 4 | Phase 4 | `/run-plan .planning/phases/08-data-validation-backtest/04-PHASE-PLAN.md` | SIM |
| 5 | Phase 5 | `/run-plan .planning/phases/08-data-validation-backtest/05-PHASE-PLAN.md` | SIM |
| 6 | Phase 6 | `/run-plan .planning/phases/08-data-validation-backtest/06-PHASE-PLAN.md` | SIM |
| 7 | Phase 7 | `/run-plan .planning/phases/08-data-validation-backtest/07-PHASE-PLAN.md` | SIM |
| 8 | Phase 8 | `/run-plan .planning/phases/08-data-validation-backtest/08-PHASE-PLAN.md` | FINAL |

---

## Comandos Passo a Passo

### FASE 1-A: Deep Data Validation (CSV → Parquet)

```
/run-plan .planning/phases/08-data-validation-backtest/01-A-PHASE-PLAN.md
```

**O que faz**: Valida conversão CSV→Parquet, conta ticks, verifica integridade
**Duração estimada**: 15-30 min
**Saídas**: `DOCS/03_RESEARCH/FINDINGS/PHASE1A_*.json`

**Se FALHAR**: Pare e investigue. Não continue para Phase 2.

---

### FASE 2: Main Catalog Validation

```
/run-plan .planning/phases/08-data-validation-backtest/02-PHASE-PLAN.md
```

**O que faz**: Health check, schema, temporal, price, gaps, regime, sessions, quality score
**Duração estimada**: 20-40 min
**Saídas**: `DOCS/03_RESEARCH/FINDINGS/PHASE2_*.json`

**Se FALHAR**: Pare e investigue. Não continue para Phase 3.

---

### FASE 3: Session Catalog Validation

```
/run-plan .planning/phases/08-data-validation-backtest/03-PHASE-PLAN.md
```

**O que faz**: Valida 6 sessões (ASIAN, LONDON, OVERLAP, NY, LATE_NY, EVENING)
**Duração estimada**: 15-25 min
**Saídas**: `DOCS/03_RESEARCH/FINDINGS/PHASE3_SESSION_*.json`

**Se FALHAR**: Pare e investigue. Não continue para Phase 4.

---

### FASE 4: Integrity & Cleanup

```
/run-plan .planning/phases/08-data-validation-backtest/04-PHASE-PLAN.md
```

**O que faz**: Cross-catalog consistency, metadata audit, cleanup
**Duração estimada**: 10-20 min
**Saídas**: `DOCS/03_RESEARCH/FINDINGS/PHASE4_*.json`

**Se FALHAR**: Pare e investigue. Não continue para Phase 5.

---

### FASE 5: Advanced Validation

```
/run-plan .planning/phases/08-data-validation-backtest/05-PHASE-PLAN.md
```

**O que faz**: GJR-GARCH, look-ahead audit, stylized facts, lineage, performance
**Duração estimada**: 20-40 min
**Saídas**: `DOCS/03_RESEARCH/FINDINGS/PHASE5_*.json`

**Se FALHAR**: Pare e investigue. Não continue para Phase 6.

---

### FASE 6: Backtest Framework Setup

```
/run-plan .planning/phases/08-data-validation-backtest/06-PHASE-PLAN.md
```

**O que faz**: Configura backtester, WFA, Monte Carlo com block bootstrap
**Duração estimada**: 15-30 min
**Saídas**: `DOCS/03_RESEARCH/FINDINGS/PHASE6_*.json`

**Se FALHAR**: Pare e investigue. Não continue para Phase 7.

---

### FASE 7: Backtest Execution

```
/run-plan .planning/phases/08-data-validation-backtest/07-PHASE-PLAN.md
```

**O que faz**: Baseline backtest, WFA (16 windows), Monte Carlo (5000 sims), CPCV
**Duração estimada**: 30-60 min (mais longo)
**Saídas**: `DOCS/03_RESEARCH/FINDINGS/PHASE7_*.json`

**Se FALHAR**: Pare e investigue. Não continue para Phase 8.

---

### FASE 8: GO/NO-GO Decision

```
/run-plan .planning/phases/08-data-validation-backtest/08-PHASE-PLAN.md
```

**O que faz**: Consolida resultados, aplica thresholds, decisão final
**Duração estimada**: 10-20 min
**Saídas**: `DOCS/03_RESEARCH/FINDINGS/PHASE8_GONOGO_DECISION.json`

**Resultado**: GO, GO-CONDITIONAL, ou NO-GO

---

## Thresholds GO/NO-GO (Referência Rápida)

| Métrica | Threshold | Peso |
|---------|-----------|------|
| WFE | >= 0.60 | CRITICAL |
| SQN | >= 2.0 AND < 5.0 | CRITICAL |
| MC DD 95% | < 4% | CRITICAL |
| Min Trades | >= 200 | CRITICAL |
| CPCV Score | >= 0.6 | CRITICAL |
| PSR | >= 0.85 | HIGH |
| DSR | > 0 | HIGH |

---

## Comandos Úteis Durante Execução

```bash
# Ver status dos arquivos gerados
ls -la DOCS/03_RESEARCH/FINDINGS/

# Ver último resultado
cat DOCS/03_RESEARCH/FINDINGS/PHASE*_*.json | jq .status

# Verificar memória (deve estar < 8GB)
free -h

# Se travar, verificar processos Python
ps aux | grep python
```

---

## Se Algo Der Errado

1. **Erro de memória**: Reinicie e tente novamente (DuckDB tem spill-to-disk)
2. **Fase falhou**: Leia o JSON de saída para entender o motivo
3. **Dados corrompidos**: Volte para os CSVs originais e reconverta
4. **Dúvida**: Pergunte no Claude Code antes de continuar

---

## Checklist Final

- [ ] Dependências instaladas
- [ ] Phase 1-A: PASS
- [ ] Phase 2: PASS
- [ ] Phase 3: PASS
- [ ] Phase 4: PASS
- [ ] Phase 5: PASS
- [ ] Phase 6: PASS
- [ ] Phase 7: PASS
- [ ] Phase 8: GO/GO-CONDITIONAL

---

*Documento gerado em 2025-12-16. Planos otimizados com ARGUS research.*
