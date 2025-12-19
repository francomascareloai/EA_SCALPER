# Nautilus Deep Audit - Guia de Execução

**Versão:** 1.2
**Data:** 2025-12-19
**Status:** PLANOS APROVADOS ✅ | EXECUÇÃO EM ANDAMENTO

---

## ⚠️ LEMBRETE CRÍTICO: Protocol 0 - Delegação Obrigatória

**ANTES de executar qualquer fase, lembre-se:**

O orquestrador **NÃO DEVE** ler arquivos de código diretamente. Cada plano de fase já inclui prompts de delegação que instruem o sub-agente a:
1. **LER** os arquivos de código (o orquestrador NÃO leu)
2. **ANALISAR** seguindo o plano
3. **ESCREVER** findings completos em arquivo
4. **RETORNAR** apenas resumo (curto, objetivo)

**Se você vir o orquestrador lendo arquivos `src/` diretamente → PARE e use a delegação.**

---

## Como acompanhar o estado (fonte da verdade)

1. **Status atual:** `orchestration/MANIFEST.md`
2. **Outputs de cada fase:** `orchestration/PHASE_*.md`
3. **Se travar / perder contexto:** peça para ler `orchestration/MANIFEST.md` e continuar do “Next Step”.

---

## Estado atual (já executado)

Estas fases já foram executadas e têm findings no `orchestration/`:
- Phase 00: COMPLETE (`orchestration/PHASE_00_FINDINGS.md`)
- Phase 01: COMPLETE (historicamente BLOCKED, depois remediado) (`orchestration/PHASE_01_FINDINGS.md` + `orchestration/PHASE_01_CRITIC_REVIEW.md`)
- Phase 02 R0: COMPLETE (`orchestration/PHASE_02_R0_MTF_FINDINGS.md`)
- Phase 02 R1: COMPLETE (REMEDIATED) (`orchestration/PHASE_02_R1_[A/B/C]_FINDINGS.md`)
- Phase 03: COMPLETE (REMEDIATED) (`orchestration/PHASE_03_*_FINDINGS.md` + `orchestration/PHASE_03_INTEGRATION_FINDINGS.md`)

**Você deve começar pelo próximo item “READY” no MANIFEST.**

---

## Pré-Requisitos (para qualquer sessão)

1. Estar no diretório correto: `/home/franco/projetos/EA_SCALPER_XAUUSD`
2. Ambiente Python ativado (se for rodar testes/coverage): `source .venv/bin/activate`
3. **Paralelismo recomendado:** 2 agentes por sessão (máximo 3). Evite 4+ em paralelo.

---

## Ordem recomendada (atualizada)

1) **Phase 02 R2** (fechar pendências de indicadores + contratos de integração)
2) **Phase 04.5 (ML)** (crítica: maior risco de look-ahead)
3) **Phase 04 (Signals)**
4) **Phase 05 (Execution)**
5) **Phase 06 R1 → R2 (Backtests)**
6) **Phase 07 (Coverage/Test realism)**
7) **Phase 08 (Integration)** (dividir em 2 sessões)
8) **Phase 09 (Synthesis + GO/NO-GO)**

---

## Prompts prontos (copiar/colar em várias sessões)

> **Regra de ouro:** cada sessão deve terminar atualizando `orchestration/MANIFEST.md` com status + outputs gerados.

### Sessão 01 — Phase 02 R2 (Targeted Follow-up)

```
Execute Phase 02 R2 of the Nautilus Deep Audit.

Context:
- Phase 02 R0 (MTF) and Phase 02 R1 (Indicators) have findings already in .planning/phases/08-nautilus-deep-audit/orchestration/.
- Phase 02 R2 is a targeted follow-up round to close open Phase 02 issues and validate integration contracts.

DELEGATION PROTOCOL (MANDATORY):
1. YOU read the necessary source files and the Phase 02 findings - orchestrator has NOT read them
2. Start by reading:
   - .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_02_R0_MTF_FINDINGS.md
   - .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_02_R1_A_FINDINGS.md
   - .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_02_R1_B_FINDINGS.md
   - .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_02_R1_C_FINDINGS.md
3. Then verify the remaining open items are either:
   - fixed in code, OR
   - explicitly deferred with rationale and owner phase, OR
   - need a remediation task (create a concrete fix plan)
4. Write COMPLETE R2 output to:
   - .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_02_R2_FOLLOWUP_FINDINGS.md
5. Update:
   - .planning/phases/08-nautilus-deep-audit/orchestration/MANIFEST.md (set Phase 02 R2 status)
6. Return ONLY a short summary with:
   - what was verified
   - what remains open
   - whether Phase 02 can be considered DONE

Plan references:
- .planning/phases/08-nautilus-deep-audit/03-PHASE-02-PLAN.md
- .planning/phases/08-nautilus-deep-audit/01-ROADMAP.md
```

### Sessão 02 — Phase 04.5 (ML Pipeline Audit) (CRITICAL)

```
Execute Phase 04.5 (ML Pipeline Audit) of the Nautilus Deep Audit.

DELEGATION PROTOCOL (MANDATORY):
1. YOU read the source files - orchestrator has NOT read them
2. First: run ML file discovery (search for ML-related code)
3. Expected files:
   - nautilus_gold_scalper/src/ml/feature_engineering.py
   - nautilus_gold_scalper/src/ml/ensemble_predictor.py
   - nautilus_gold_scalper/src/ml/model_trainer.py
4. If expected files not found: search entire codebase for ML code, document what exists, adapt analysis.
5. Focus: look-ahead bias, leakage, temporal split correctness, train/inference parity.
6. Write COMPLETE analysis to:
   - .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_04.5_ML_FINDINGS.md
7. Update:
   - .planning/phases/08-nautilus-deep-audit/orchestration/MANIFEST.md
8. Return ONLY a short summary with PASS/FAIL verdict (look-ahead) and issue counts.

Plan file: .planning/phases/08-nautilus-deep-audit/05.5-PHASE-04.5-PLAN.md
```

### Sessão 03 — Phase 04 (Signal Generators) (2 agentes)

**Prompt (Agent A):**
```
Execute Phase 04 Agent A (Scoring/Entry Chain) of the Nautilus Deep Audit.

DELEGATION PROTOCOL (MANDATORY):
1. YOU read the source files - orchestrator has NOT read them
2. Files to analyze:
   - nautilus_gold_scalper/src/signals/confluence_scorer.py
   - nautilus_gold_scalper/src/signals/entry_optimizer.py
   - nautilus_gold_scalper/src/signals/mtf_manager.py
3. Focus: thresholds, MTF alignment, scoring correctness, look-ahead traps.
4. Write COMPLETE analysis to:
   - .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_04_A_SCORING_FINDINGS.md
5. Return ONLY a short summary with issue counts.

Plan file: .planning/phases/08-nautilus-deep-audit/05-PHASE-04-PLAN.md
```

**Prompt (Agent B):**
```
Execute Phase 04 Agent B (News Modules) of the Nautilus Deep Audit.

DELEGATION PROTOCOL (MANDATORY):
1. YOU read the source files - orchestrator has NOT read them
2. Files to analyze:
   - nautilus_gold_scalper/src/signals/news_calendar.py
   - nautilus_gold_scalper/src/signals/news_trader.py
3. Focus: news timing, blackout windows, timezone correctness, look-ahead in event/results handling.
4. Write COMPLETE analysis to:
   - .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_04_B_NEWS_FINDINGS.md
5. Return ONLY a short summary with issue counts.

Plan file: .planning/phases/08-nautilus-deep-audit/05-PHASE-04-PLAN.md
```

**Prompt (Consolidação):**
```
Consolidate Phase 04 outputs.

1. Read:
   - .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_04_A_SCORING_FINDINGS.md
   - .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_04_B_NEWS_FINDINGS.md
2. Create:
   - .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_04_FINDINGS.md
3. Update:
   - .planning/phases/08-nautilus-deep-audit/orchestration/MANIFEST.md
4. Return a short summary with issue counts and blockers.
```

### Sessão 04 — Phase 05 (Execution Layer) (2 agentes)

**Prompt (Agent A):**
```
Execute Phase 05 Agent A (Trade Manager) of the Nautilus Deep Audit.

DELEGATION PROTOCOL (MANDATORY):
1. YOU read the source file - orchestrator has NOT read it
2. File to analyze:
   - nautilus_gold_scalper/src/execution/trade_manager.py
3. Focus: lifecycle, SL/TP attachment, rejection handling, emergency close path, state machine completeness.
4. Write COMPLETE analysis to:
   - .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_05_A_TRADEMGR_FINDINGS.md
5. Return ONLY short summary with issue counts.

Plan file: .planning/phases/08-nautilus-deep-audit/06-PHASE-05-PLAN.md
```

**Prompt (Agent B):**
```
Execute Phase 05 Agent B (Execution Model + Adapters) of the Nautilus Deep Audit.

DELEGATION PROTOCOL (MANDATORY):
1. YOU read the source files - orchestrator has NOT read them
2. Files to analyze:
   - nautilus_gold_scalper/src/execution/execution_model.py
   - nautilus_gold_scalper/src/execution/base_adapter.py
   - nautilus_gold_scalper/src/execution/mt5_adapter.py
   - nautilus_gold_scalper/src/execution/ninjatrader_adapter.py
3. Focus: execution realism (latency/slippage), integration contract, failure modes.
4. Write COMPLETE analysis to:
   - .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_05_B_ADAPTERS_FINDINGS.md
5. Return ONLY short summary with issue counts.

Plan file: .planning/phases/08-nautilus-deep-audit/06-PHASE-05-PLAN.md
```

**Prompt (Consolidação):**
```
Consolidate Phase 05 outputs.

1. Read:
   - .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_05_A_TRADEMGR_FINDINGS.md
   - .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_05_B_ADAPTERS_FINDINGS.md
2. Create:
   - .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_05_FINDINGS.md
3. Update:
   - .planning/phases/08-nautilus-deep-audit/orchestration/MANIFEST.md
4. Return a short summary with issue counts and blockers.
```

### Sessão 05 — Phase 06 R1 (Backtest Scripts) (3 agentes máx.)

```
Execute Phase 06 Round 1 of the Nautilus Deep Audit as specified in .planning/phases/08-nautilus-deep-audit/07-PHASE-06-PLAN.md.

Run with up to 3 parallel REVIEWER agents (A/B/C) exactly as the plan defines.
Each agent must write its findings output to the file paths defined in the plan.
After all complete, consolidate and update orchestration/MANIFEST.md.
```

### Sessão 06 — Phase 06 R2 (Validation Scripts) (2 agentes)

```
Execute Phase 06 Round 2 of the Nautilus Deep Audit as specified in .planning/phases/08-nautilus-deep-audit/07-PHASE-06-PLAN.md.

Run with 2 parallel REVIEWER agents (D/E) exactly as the plan defines.
Each agent must write its findings output to the file paths defined in the plan.
After all complete, consolidate and update orchestration/MANIFEST.md.
```

### Sessão 07 — Phase 07 (Test Coverage Analysis)

```
Execute Phase 07 (Test Coverage Analysis) of the Nautilus Deep Audit.

DELEGATION PROTOCOL (MANDATORY):
1. YOU run pytest --cov and read test files - orchestrator has NOT
2. Run baseline:
   pytest --cov=nautilus_gold_scalper --cov-report=term-missing tests/
3. Analyze coverage gaps + mock realism + temporal correctness.
4. Write COMPLETE analysis to:
   - .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_07_COVERAGE_FINDINGS.md
5. Update:
   - .planning/phases/08-nautilus-deep-audit/orchestration/MANIFEST.md
6. Return ONLY short summary with coverage metrics and top gaps.

Plan file: .planning/phases/08-nautilus-deep-audit/08-PHASE-07-PLAN.md
```

### Sessão 08 — Phase 08 (Integration) — Parte A (2 agentes)

**Agent A (Strategy↔Risk) + Agent B (Indicator↔Strategy):**
```
Execute Phase 08 (Integration Points Audit) Part A of the Nautilus Deep Audit.

Run 2 parallel NAUTILUS agents:
- Agent A: Strategy ↔ Risk Integration
- Agent B: Indicator ↔ Strategy Integration

Each agent must follow the delegation protocol and write outputs to:
- .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_08_A_STRATEGYRISK_FINDINGS.md
- .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_08_B_INDICATORSTRAT_FINDINGS.md

Plan file: .planning/phases/08-nautilus-deep-audit/09-PHASE-08-PLAN.md
```

### Sessão 09 — Phase 08 (Integration) — Parte B (2 agentes)

**Agent C (Signal↔Execution) + Agent D (Time Sync):**
```
Execute Phase 08 (Integration Points Audit) Part B of the Nautilus Deep Audit.

Run 2 parallel NAUTILUS agents:
- Agent C: Signal ↔ Execution Integration
- Agent D: Time Synchronization

Each agent must follow the delegation protocol and write outputs to:
- .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_08_C_SIGNALEXEC_FINDINGS.md
- .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_08_D_TIMESYNC_FINDINGS.md

After both parts A and B are done, consolidate into:
- .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_08_FINDINGS.md
Then update:
- .planning/phases/08-nautilus-deep-audit/orchestration/MANIFEST.md

Plan file: .planning/phases/08-nautilus-deep-audit/09-PHASE-08-PLAN.md
```

### Sessão 10 — Phase 09 (Final Synthesis + GO/NO-GO)

```
Execute Phase 09 (Final Synthesis) of the Nautilus Deep Audit.

DELEGATION PROTOCOL (MANDATORY):
1. YOU read all findings files from .planning/phases/08-nautilus-deep-audit/orchestration/
2. Synthesize and write:
   - AUDIT_REPORT.md
   - ISSUES_TRACKER.md
   - RECOMMENDATIONS.md
   all inside .planning/phases/08-nautilus-deep-audit/orchestration/
3. Update:
   - .planning/phases/08-nautilus-deep-audit/orchestration/MANIFEST.md
4. Return ONLY short summary with GO/NO-GO and top blockers.

Plan file: .planning/phases/08-nautilus-deep-audit/10-PHASE-09-PLAN.md
```

---

## Prompt de “status/retomada” (use em qualquer sessão)

```
Mostrar status atual do audit.

1. Leia .planning/phases/08-nautilus-deep-audit/orchestration/MANIFEST.md
2. Resuma o progresso: fases completas, fase atual, blockers, próximos passos.
3. Continue exatamente do próximo item READY.
```
