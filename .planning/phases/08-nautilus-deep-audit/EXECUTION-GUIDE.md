# Nautilus Deep Audit - Guia de Execução

**Versão:** 1.1
**Data:** 2025-12-17
**Status:** TODOS OS PLANOS APROVADOS (12/12)

---

## ⚠️ LEMBRETE CRÍTICO: Protocol 0 - Delegação Obrigatória

**ANTES de executar qualquer fase, lembre-se:**

O orquestrador **NÃO DEVE** ler arquivos de código diretamente. Cada plano de fase já inclui prompts de delegação que instruem o sub-agente a:
1. **LER** os arquivos de código (o orquestrador NÃO leu)
2. **ANALISAR** seguindo o plano
3. **ESCREVER** findings completos em arquivo
4. **RETORNAR** apenas resumo de 300 palavras

**Se você vir o orquestrador lendo arquivos `src/` diretamente → PARE e use a delegação.**

---

## Resumo

Este guia contém todos os comandos que você precisa executar no Claude Code para completar o Deep Audit do Nautilus Trader. Cada fase foi revisada pelo CRITIC e aprovada.

**Escopo Total:** ~40,588 linhas de código
**Fases:** 11 (00-09, incluindo 04.5)
**Tempo Estimado:** 4-8 horas (dependendo da complexidade dos findings)

---

## Pré-Requisitos

Antes de começar, certifique-se de:

1. Estar no diretório correto: `/home/franco/projetos/EA_SCALPER_XAUUSD`
2. Ter o ambiente Python ativado: `source .venv/bin/activate`
3. Ter tempo disponível para monitorar (cada fase pode levar 15-60 minutos)

---

## Comandos por Fase

### Phase 00: Foundation Verification (JÁ EXECUTADO)

**Status:** COMPLETE - Baseline verificado em 2025-12-16

O baseline foi criado:
- Git tag: `audit-baseline-20251216`
- Pytest: ALL PASSING
- Thresholds: MATCH CLAUDE.md

**Você pode pular para Phase 01.**

---

### Phase 01: Core Strategy Audit

**Foco:** Estratégia principal (gold_scalper_strategy.py, base_strategy.py, strategy_selector.py)

```
Execute Phase 01 of the Nautilus Deep Audit. Follow the plan in .planning/phases/08-nautilus-deep-audit/02-PHASE-01-PLAN.md exactly. Write findings to orchestration/PHASE_01_FINDINGS.md
```

**Tempo estimado:** 45-60 minutos
**Após conclusão:** Verifique `orchestration/PHASE_01_FINDINGS.md`

---

### Phase 02: SMC Indicators Audit

**Foco:** Indicadores Smart Money Concepts (8 arquivos, ~4,100 linhas)

**Round 0 (MTF Manager - BLOCKING):**
```
Execute Phase 02 Round 0 of the Nautilus Deep Audit. Review mtf_manager.py FIRST as specified in .planning/phases/08-nautilus-deep-audit/03-PHASE-02-PLAN.md. This is blocking for Round 1.
```

**Round 1 (3 agents parallel):**
```
Execute Phase 02 Round 1 of the Nautilus Deep Audit with 3 parallel agents as specified in the plan. Follow .planning/phases/08-nautilus-deep-audit/03-PHASE-02-PLAN.md
```

**Round 2 (2 agents parallel):**
```
Execute Phase 02 Round 2 of the Nautilus Deep Audit with 2 parallel agents as specified in the plan.
```

**Tempo estimado:** 60-90 minutos (total)
**Após conclusão:** Verifique `orchestration/PHASE_02_*.md`

---

### Phase 03: Risk Modules Audit

**Foco:** Módulos de risco (drawdown, circuit breaker, position sizing, etc.)

**Round 1 (2 agents parallel):**
```
Execute Phase 03 Round 1 of the Nautilus Deep Audit. Focus on DD Stack and Apex Rules Stack as specified in .planning/phases/08-nautilus-deep-audit/04-PHASE-03-PLAN.md
```

**Round 2 (1 agent):**
```
Execute Phase 03 Round 2 of the Nautilus Deep Audit. Focus on Sizing Stack.
```

**Tempo estimado:** 45-60 minutos
**Após conclusão:** Verifique `orchestration/PHASE_03_FINDINGS.md`

---

### Phase 04: Signal Generators Audit

**Foco:** Geradores de sinal (confluence_scorer, entry_optimizer, news modules)

```
Execute Phase 04 of the Nautilus Deep Audit with 2 parallel REVIEWER agents as specified in .planning/phases/08-nautilus-deep-audit/05-PHASE-04-PLAN.md
```

**Tempo estimado:** 30-45 minutos
**Após conclusão:** Verifique `orchestration/PHASE_04_FINDINGS.md`

---

### Phase 04.5: ML Pipeline Audit (CRITICAL)

**Foco:** Pipeline de ML - look-ahead bias é o maior risco aqui

```
Execute Phase 04.5 of the Nautilus Deep Audit. This is the ML Pipeline audit - HIGHEST RISK for look-ahead bias. Follow .planning/phases/08-nautilus-deep-audit/05.5-PHASE-04.5-PLAN.md with exhaustive temporal tracing.
```

**Tempo estimado:** 45-60 minutos
**Após conclusão:** Verifique `orchestration/PHASE_04.5_FINDINGS.md`

**IMPORTANTE:** Se encontrar look-ahead bias, isso é BLOCKING para go-live.

---

### Phase 05: Execution Layer Audit

**Foco:** Camada de execução (trade_manager, adapters, holiday handling)

```
Execute Phase 05 of the Nautilus Deep Audit with 2 parallel agents as specified in .planning/phases/08-nautilus-deep-audit/06-PHASE-05-PLAN.md
```

**Tempo estimado:** 30-45 minutos
**Após conclusão:** Verifique `orchestration/PHASE_05_FINDINGS.md`

---

### Phase 06: Backtest Scripts Audit

**Foco:** Scripts de backtest (ea_logic_full, monte_carlo, walk-forward, etc.)

**Round 1 (3 REVIEWER agents):**
```
Execute Phase 06 Round 1 of the Nautilus Deep Audit with 3 REVIEWER agents. Focus on core strategies as specified in .planning/phases/08-nautilus-deep-audit/07-PHASE-06-PLAN.md
```

**Round 2 (2 REVIEWER agents):**
```
Execute Phase 06 Round 2 of the Nautilus Deep Audit with 2 REVIEWER agents. Focus on validation scripts.
```

**Tempo estimado:** 60-90 minutos (total)
**Após conclusão:** Verifique `orchestration/PHASE_06_FINDINGS.md`

---

### Phase 07: Test Coverage Analysis

**Foco:** Análise de cobertura de testes

```
Execute Phase 07 of the Nautilus Deep Audit. Analyze test coverage as specified in .planning/phases/08-nautilus-deep-audit/08-PHASE-07-PLAN.md. Run pytest --cov for baseline.
```

**Tempo estimado:** 30-45 minutos
**Após conclusão:** Verifique `orchestration/PHASE_07_FINDINGS.md`

---

### Phase 08: Integration Points Audit

**Foco:** Pontos de integração entre módulos

```
Execute Phase 08 of the Nautilus Deep Audit with 4 parallel NAUTILUS agents. Focus on all 4 integration areas as specified in .planning/phases/08-nautilus-deep-audit/09-PHASE-08-PLAN.md
```

**Tempo estimado:** 45-60 minutos
**Após conclusão:** Verifique `orchestration/PHASE_08_FINDINGS.md`

---

### Phase 09: Final Synthesis (GO/NO-GO)

**Foco:** Síntese final de todos os findings + decisão GO/NO-GO

```
Execute Phase 09 of the Nautilus Deep Audit. Synthesize all findings from Phases 00-08 into final AUDIT_REPORT.md, ISSUES_TRACKER.md, and RECOMMENDATIONS.md. Make GO/NO-GO decision. Follow .planning/phases/08-nautilus-deep-audit/10-PHASE-09-PLAN.md
```

**Tempo estimado:** 60-90 minutos
**Após conclusão:** Verifique:
- `orchestration/AUDIT_REPORT.md`
- `orchestration/ISSUES_TRACKER.md`
- `orchestration/RECOMMENDATIONS.md`

---

## Checkpoints Recomendados

Após cada fase, você pode verificar o progresso:

```
Mostrar status atual do audit. Leia orchestration/MANIFEST.md e resuma o progresso.
```

---

## Se Algo Der Errado

### Context Overflow
Se o Claude ficar sem contexto:
```
Continuar o Nautilus Deep Audit. Ler orchestration/MANIFEST.md para entender o estado atual e continuar de onde parou.
```

### Fase Incompleta
Se uma fase não completar:
```
Retomar Phase [XX] do Nautilus Deep Audit. O status anterior está em orchestration/PHASE_[XX]_FINDINGS.md
```

### CRITICAL Issue Encontrado
Se encontrar um issue CRITICAL:
```
Parar o audit. Foi encontrado um issue CRITICAL em Phase [XX]. Analisar o impacto e decidir se devemos corrigir antes de continuar.
```

---

## Ordem de Execução Resumida

```
1. Phase 01 (Core Strategy)
2. Phase 02 R0 → R1 → R2 (Indicators)
3. Phase 03 R1 → R2 (Risk)
4. Phase 04 (Signals) ← pode rodar em paralelo com 04.5
5. Phase 04.5 (ML) ← CRITICAL
6. Phase 05 (Execution)
7. Phase 06 R1 → R2 (Backtest)
8. Phase 07 (Tests)
9. Phase 08 (Integration)
10. Phase 09 (Synthesis + GO/NO-GO)
```

---

## Arquivos de Referência

| Arquivo | Propósito |
|---------|-----------|
| `MASTER-PLAN.md` | Visão geral do audit (v2.1 com Protocol 0) |
| `01-ROADMAP.md` | Progresso e fases |
| `PROTOCOLS.md` | **Protocol 0 (delegação obrigatória)** + todos os protocolos |
| `EXECUTION-TEMPLATE.md` | Templates para sub-agents |
| `orchestration/MANIFEST.md` | Índice de outputs |

---

## Após Completar o Audit

1. Ler `AUDIT_REPORT.md` para o resumo executivo
2. Verificar `ISSUES_TRACKER.md` para lista de bugs/issues
3. Seguir `RECOMMENDATIONS.md` para próximos passos
4. Se GO: Preparar para go-live
5. Se NO-GO: Corrigir issues CRITICAL/HIGH primeiro

---

**Boa sorte com o audit!**
