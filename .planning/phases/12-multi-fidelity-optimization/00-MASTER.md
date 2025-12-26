# Phase 12: Multi-Fidelity Optimization Infrastructure — Master Plan

**Date:** 2025-12-25
**Version:** 1.0
**Status:** PARTIALLY IMPLEMENTED (anti-overfit gates integrated)
**Philosophy:** RANKING PRESERVATION > VALUE CORRECTION | FALSIFICATION-FIRST

---

## Executive Summary

Phase 12 originally scoped a **multi-fidelity (multi-stride) tournament** to make 1000+ config searches feasible.

Current reality in the repo:
- The multi-fidelity tournament module (`nautilus_gold_scalper/src/optimization/fidelity/`) is **not implemented yet**.
- The optimizer pipeline has already gained the key *risk/overfit safety layer* pieces that Phase 12 depended on:
  - **Daily DD hard limit** enforcement via `constraints.apex.daily_dd_max`
  - **Layer3 stress metrics** (trade-based MC drawdown percentiles + degradation)
  - **Candidate-set PBO (CSCV-like proxy)** integrated into the optimization run and exported in reports

This master plan is now the authoritative **design doc for the deferred multi-fidelity tournament**, while the **current execution path** is: run the existing optimizer with the new anti-overfit constraints and Layer3 stress.

**Original (deferred) architecture target:**
```
Multi-Fidelity Tournament Pipeline:
  Stage 0: Stride 20 → sanity check
  Stage 1: Stride 10 → filter by ranking
  Stage 2: Stride 5  → refine by robust metrics
  Stage 3: Stride 1  → validate finalists
```

---

## Research Foundation (From Genius Council)

### ARGUS Findings
- No universal "PnL scaling formula" exists - bias is path-dependent
- Multi-fidelity calibration is industry standard (quant firms)
- Rank correlation (Spearman) is the key validation metric
- Stride 5 showed +7% error in P1 - best proxy candidate

### DAEMON Strategic Verdict
- **REJECT** correction factor approach - fundamentally wrong abstraction
- **APPROVE** multi-fidelity tournament + ranking preservation
- "A scalar correction factor is the wrong abstraction for a path-dependent error"
- Focus on decision-correctness, not value-correction

### CRITIC Adversarial Analysis
- Stride 2-4 overestimate due to aliasing/phase-locking (deletes "damage ticks")
- Non-monotone error (stride 2 > stride 5) kills linear correction models
- Must validate rank correlation before trusting any stride for filtering
- Add "Stride Sensitivity Score" to detect artifact-exploiting configs

### CRUCIBLE Trading Perspective
- Lower resolution deletes "damage ticks" that kill breakouts in live
- Breakout detection is threshold-crossing (highly resolution-sensitive)
- Ranking metrics: prioritize DD, trade count, PF over Sharpe/WR
- Session-aware validation (P2=good, P3=bad showed regime matters more)

---

## Evidence Base (From Empirical Testing)

### Stride Comparison Results (2025-12-25)

| Period | Stride 1 (ref) | Stride 2 | Stride 3 | Stride 4 | Stride 5 |
|--------|----------------|----------|----------|----------|----------|
| P1 (Jun 03-10) | +$225.64 | +$610.48 (+170%) | +$1,188.32 (+426%) | +$286.41 (+27%) | +$241.43 (+7%) |
| P2 (Jul 01-08) | +$116.15 | +$924.96 (+696%) | +$698.04 (+501%) | +$623.85 (+437%) | — |
| P3 (Aug 01-08) | -$1,290.97 | -$1,551.61 (+20%) | -$894.83 (-31%) | -$2,204.41 (+71%) | -$1,810.55 (+40%) |

**Key Insight:** Stride 5 had only +7% error in P1 - the most accurate proxy.

**Report Location:** `DOCS/04_REPORTS/VALIDATION/STRIDE_COMPARISON_REPORT_20251225.md`

---

## Plan Breakdown (Atomic Plans)

Each plan has 2-3 tasks maximum for quality preservation.

NOTE (2025-12-26): Plans 12-01..12-06 describe the *deferred* multi-fidelity tournament. The current codebase does not yet contain `nautilus_gold_scalper/src/optimization/fidelity/`.
The production path today is the existing optimizer + anti-overfit gates (PBO + MC95DD + daily_dd_max).

### 12-01: Rank Correlation Validation (DISPROOF TEST)
**Goal:** Prove that ranking is preserved between strides before building anything
**Tasks:**
1. Sample 30-50 random configs from parameter space
2. Run stride 1, 5, 10 on 2-3 periods
3. Calculate Spearman rank correlation
**Gate:** If corr < 0.6 → STOP (stride filtering is invalid)

### 12-02: Stride Sensitivity Score Implementation
**Goal:** Detect configs that exploit stride artifacts
**Tasks:**
1. Define sensitivity metric: ΔPnL% + ΔTrades% + ΔStopOuts%
2. Implement `StrideSensitivityScorer` class
3. Add sensitivity gate to optimizer (high sensitivity = disqualified)

### 12-03: Multi-Fidelity Pipeline Architecture
**Goal:** Build the tournament pipeline skeleton
**Tasks:**
1. Create `MultiFidelityOptimizer` with stage definitions
2. Implement promotion logic (top K → next stage)
3. Add persistence for cross-stage metrics

### 12-04: Pessimistic Execution Model
**Goal:** Make coarse sims conservative (lower bound, not corrected optimistic)
**Tasks:**
1. Implement pessimistic fill model (SL assumed hit, TP assumed missed)
2. Add spread buffer enforcement (reject if SL < 3x spread)
3. Integrate with VirtualGate for consistent conservatism

### 12-05: Grid Optimizer Integration
**Goal:** Wire multi-fidelity into existing optimizer
**Tasks:**
1. (DEFERRED) Add tournament-specific CLI flags (`--multi-fidelity`, `--mf-stages`, `--mf-resume`)
2. (DEFERRED) Implement tournament stride switching per stage

NOTE: The current CLI already supports a multi-fidelity-like mode via `--mode successive_halving` (early pruning).
3. Add stage progression logging

### 12-06: Production Grid Workflow
**Goal:** Create end-to-end production workflow
**Tasks:**
1. Create config template for multi-fidelity optimization
2. Document workflow with examples
3. Add validation checklist for production runs

---

## Dependencies

### Required Before Starting
- [x] Phase 10 (Apex Optimizer) basics complete
- [x] `run_backtest.py` working with `--sample` parameter
- [x] VirtualGate implementation complete (Phase 11)

### Files to Modify
| File | Change |
|------|--------|
| `nautilus_gold_scalper/src/optimization/optimizer.py` | (DEFERRED) add tournament multi-fidelity mode |
| `nautilus_gold_scalper/src/optimization/config.py` | (DEFERRED) add fidelity stage config |
| `nautilus_gold_scalper/scripts/optimize.py` | Add multi-fidelity CLI |
| NEW: `nautilus_gold_scalper/src/optimization/fidelity/` | Multi-fidelity module |

---

## GO/NO-GO Gates

### 12-01 Gate (CRITICAL - Must pass before proceeding)
```
Spearman rank correlation stride5 vs stride1 >= 0.7
Spearman rank correlation stride10 vs stride1 >= 0.5
```
If fails: Multi-fidelity approach is invalid. Return to stride 1 only.

### Phase 12 Final Gate
- [ ] All plans completed
- [ ] Rank correlation validated (>= 0.7 for stride 5)
- [ ] Sensitivity scoring working
- [ ] Multi-fidelity pipeline runs end-to-end
- [ ] At least one full grid search completed successfully
- [ ] `pytest -q` passes
- [ ] `mypy --strict` passes on new code

---

## MANDATORY EXECUTION PROTOCOL

**ESTE PROTOCOLO DEVE SER SEGUIDO EM TODAS AS ACOES:**

### 1. Autonomous Loop (CRITIC ate GO)
```
Executar task → CRITIC review (opus) → GO?
                      ↓ NO
                Fix automatico → CRITIC review → loop (max 3x)
                      ↓ ainda NO-GO apos 3x
                Perguntar usuario
```

### 2. Quick Test/Backtest Apos Cada Fix
```bash
# OBRIGATORIO apos qualquer mudanca de codigo
.venv/bin/pytest -q nautilus_gold_scalper/tests/

# Para validar rank correlation:
.venv/bin/python -m nautilus_gold_scalper.scripts.backtest.run_backtest \
  --source catalog \
  --catalog-path data/catalog_native/xauusd_2003_2025_stride1_COMPLETE \
  --sample 5 \
  --start 2024-06-03 --end 2024-06-10 \
  --enable-trend-follow

# Verificar:
# - Testes passam
# - Sem erros no log
# - Metricas nao pioraram significativamente
```

### 3. Parallel Agents (sem limite)
- Pode spawnar multiplos agents em paralelo para fixes
- Usar agents especializados simultaneamente se necessario
- Nao economizar - usar quantos precisar para velocidade

### 4. Anti-Hallucination
- SEMPRE mostrar output dos comandos executados
- NUNCA dizer "deve funcionar" sem testar de verdade
- NUNCA inventar metricas - usar output real dos testes
- NUNCA inventar APIs - verificar documentacao primeiro

### 5. Consultar Documentacao
```bash
# ANTES de escrever codigo com bibliotecas externas:
rg -n "metodo_ou_classe" external/nautilus_trader/ docs/
# Se nao encontrar: usar context7 MCP para docs atualizados
```

### 6. Verificacao Obrigatoria
```bash
# Antes de qualquer GO:
.venv/bin/mypy --strict nautilus_gold_scalper/src/optimization/
.venv/bin/pytest -q nautilus_gold_scalper/tests/
```

---

## Risk Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Rank correlation < 0.6 | MEDIUM | CRITICAL | Stop immediately, return to stride 1 only |
| Stride 5 diverges in new periods | MEDIUM | HIGH | Validate on 5+ periods before trusting |
| Sensitivity score too aggressive | LOW | MEDIUM | Tune thresholds empirically |
| Pipeline complexity → bugs | MEDIUM | MEDIUM | Extensive testing, atomic plans |

---

## Timeline (No estimates, just order)

```
12-01: Rank Correlation → MUST PASS FIRST (blocker for rest)
         ↓
12-02: Sensitivity Score → In parallel with 12-03
12-03: Pipeline Architecture → Core implementation
         ↓
12-04: Pessimistic Execution → Refinement
12-05: Optimizer Integration → Wiring
         ↓
12-06: Production Workflow → Documentation + validation
```

---

## Agent Responsibilities

| Plan | Lead Agent | Support Agents |
|------|------------|----------------|
| 12-01 | ORACLE | CRITIC |
| 12-02 | FORGE | CRUCIBLE |
| 12-03 | FORGE | NAUTILUS |
| 12-04 | SENTINEL | FORGE |
| 12-05 | FORGE | ORACLE |
| 12-06 | DOCS | ORACLE, SENTINEL |

---

## References

- `DOCS/04_REPORTS/VALIDATION/STRIDE_COMPARISON_REPORT_20251225.md`
- `.planning/phases/10-apex-optimizer/00-MASTER.md`
- `nautilus_gold_scalper/src/optimization/` (existing optimizer)
- `nautilus_gold_scalper/scripts/backtest/run_backtest.py` (backtest runner)

---

**AGENT:** ORCHESTRATOR
**VERSION:** 1.0
**CLAUDE_MD_VERSION:** 3.10.23
**STATUS:** NEEDS UPDATE (tournament module deferred; anti-overfit gates landed)

---

*"Don't build a system that needs reality removed to look good."* — DAEMON

*End of Master Plan*
