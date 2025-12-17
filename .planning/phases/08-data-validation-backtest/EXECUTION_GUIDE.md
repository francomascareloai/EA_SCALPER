# Guia de Execução: Data Validation & Backtest Pipeline

**Data**: 2025-12-17
**Status**: Pronto para execução
**Planos**: 100% otimizados com ARGUS improvements (XML format)
**Protocol 0**: Delegação Obrigatória ATIVO

---

## ⚠️ LEMBRETE CRÍTICO: Protocol 0 - Delegação Obrigatória

> **O orquestrador NÃO PODE ler arquivos de dados ou resultados diretamente.**
>
> Cada plano (01-A até 08) inclui o Protocol 0. Os sub-agents devem:
> 1. LER os dados e executar os scripts
> 2. ESCREVER análise completa em: `outputs/PHASEXX_*.json`
> 3. RETORNAR apenas resumo (max 300 palavras) para o chat

### Sessão de Orquestração

**Criar pasta de sessão ANTES de cada fase**:
```bash
mkdir -p .planning/phases/08-data-validation-backtest/orchestration/
```

Cada sub-agent deve salvar output completo em arquivo antes de retornar resumo.

---

## Estrutura de Pastas

```
.planning/phases/08-data-validation-backtest/
├── 00-BRIEF.md           # Overview do projeto
├── 00-ROADMAP.md         # Roadmap geral
├── 01-A-PLAN.xml.md      # Phase 1-A (Deep Data Validation)
├── 02-PLAN.xml.md        # Phase 2 (Main Catalog Validation)
├── 03-PLAN.xml.md        # Phase 3 (Session Validation)
├── 04-PLAN.xml.md        # Phase 4 (Integrity & Cleanup)
├── 05-PLAN.xml.md        # Phase 5 (Advanced Validation)
├── 06-PLAN.xml.md        # Phase 6 (Backtest Framework)
├── 07-PLAN.xml.md        # Phase 7 (Backtest Execution)
├── 08-PLAN.xml.md        # Phase 8 (GO/NO-GO Decision)
├── outputs/              # ← TODOS os resultados JSON
└── orchestration/        # Orchestration session outputs
```

**Regra de engenharia (anti-bagunça):**
- `.planning/**` é **somente** para planos, logs e outputs.
- Scripts executáveis devem viver em `scripts/` (repo) ou `nautilus_gold_scalper/scripts/` (robô).

---

## ⚡ ARGUS Research Improvements

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

---

## Pré-Requisitos (Execute UMA VEZ antes de começar)

```bash
# 1. Ativar ambiente virtual
source .venv/bin/activate

# 2. Instalar dependências novas
pip install duckdb>=1.0.0 polars>=0.20.0 pandas-market-calendars>=4.0
pip install hmmlearn>=0.3.0 arch>=6.0.0 pandera>=0.18.0

# 3. Verificar instalação
python -c "import duckdb, polars, arch; print('OK')"
```

---

## Ordem de Execução das Fases

| # | Fase | Comando | Bloqueante |
|---|------|---------|------------|
| 1 | Phase 1-A | `/run-plan .planning/phases/08-data-validation-backtest/01-A-PLAN.xml.md` | SIM |
| 2 | Phase 2 | `/run-plan .planning/phases/08-data-validation-backtest/02-PLAN.xml.md` | SIM |
| 3 | Phase 3 | `/run-plan .planning/phases/08-data-validation-backtest/03-PLAN.xml.md` | SIM |
| 4 | Phase 4 | `/run-plan .planning/phases/08-data-validation-backtest/04-PLAN.xml.md` | SIM |
| 5 | Phase 5 | `/run-plan .planning/phases/08-data-validation-backtest/05-PLAN.xml.md` | SIM |
| 6 | Phase 6 | `/run-plan .planning/phases/08-data-validation-backtest/06-PLAN.xml.md` | SIM |
| 7 | Phase 7 | `/run-plan .planning/phases/08-data-validation-backtest/07-PLAN.xml.md` | SIM |
| 8 | Phase 8 | `/run-plan .planning/phases/08-data-validation-backtest/08-PLAN.xml.md` | FINAL |

---

## Comandos Passo a Passo

### FASE 1-A: Deep Data Validation (CSV → Parquet)

```
/run-plan .planning/phases/08-data-validation-backtest/01-A-PLAN.xml.md
```

**O que faz**: Valida conversão CSV→Parquet, conta ticks, verifica integridade
**Duração estimada**: 15-30 min
**Saídas**: `outputs/PHASE1A_*.json`

**Se FALHAR**: Pare e investigue. Não continue para Phase 2.

---

### FASE 2: Main Catalog Validation

```
/run-plan .planning/phases/08-data-validation-backtest/02-PLAN.xml.md
```

**O que faz**: Health check, schema, temporal, price, gaps, regime, sessions, quality score
**Duração estimada**: 20-40 min
**Saídas**: `outputs/PHASE2_*.json`

**Se FALHAR**: Pare e investigue. Não continue para Phase 3.

---

### FASE 3: Session Catalog Validation

```
/run-plan .planning/phases/08-data-validation-backtest/03-PLAN.xml.md
```

**O que faz**: Valida 6 sessões (ASIAN, LONDON, OVERLAP, NY, LATE_NY, EVENING)
**Duração estimada**: 15-25 min
**Saídas**: `outputs/PHASE3_SESSION_*.json`

**Se FALHAR**: Pare e investigue. Não continue para Phase 4.

---

### FASE 4: Integrity & Cleanup

```
/run-plan .planning/phases/08-data-validation-backtest/04-PLAN.xml.md
```

**O que faz**: Cross-catalog consistency, metadata audit, cleanup
**Duração estimada**: 10-20 min
**Saídas**: `outputs/PHASE4_*.json`

**Se FALHAR**: Pare e investigue. Não continue para Phase 5.

---

### FASE 5: Advanced Validation

```
/run-plan .planning/phases/08-data-validation-backtest/05-PLAN.xml.md
```

**O que faz**: GJR-GARCH, look-ahead audit, stylized facts, lineage, performance
**Duração estimada**: 20-40 min
**Saídas**: `outputs/PHASE5_*.json`

**Se FALHAR**: Pare e investigue. Não continue para Phase 6.

---

### FASE 6: Backtest Framework Setup

```
/run-plan .planning/phases/08-data-validation-backtest/06-PLAN.xml.md
```

**O que faz**: Configura backtester, WFA, Monte Carlo com block bootstrap
**Duração estimada**: 15-30 min
**Saídas**: `outputs/PHASE6_*.json`

**Se FALHAR**: Pare e investigue. Não continue para Phase 7.

---

### FASE 7: Backtest Execution

```
/run-plan .planning/phases/08-data-validation-backtest/07-PLAN.xml.md
```

**O que faz**: Baseline backtest, WFA (16 windows), Monte Carlo (5000 sims), CPCV
**Duração estimada**: 30-60 min (mais longo)
**Saídas**: `outputs/PHASE7_*.json`

**Se FALHAR**: Pare e investigue. Não continue para Phase 8.

---

### FASE 8: GO/NO-GO Decision

```
/run-plan .planning/phases/08-data-validation-backtest/08-PLAN.xml.md
```

**O que faz**: Consolida resultados, aplica thresholds, decisão final
**Duração estimada**: 10-20 min
**Saídas**: `outputs/PHASE8_DECISION_SUMMARY.json`

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
ls -la .planning/phases/08-data-validation-backtest/outputs/

# Ver último resultado
cat .planning/phases/08-data-validation-backtest/outputs/PHASE*_*.json | jq .status

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

*Documento atualizado em 2025-12-17. Planos em formato XML com Protocol 0 enforced.*
