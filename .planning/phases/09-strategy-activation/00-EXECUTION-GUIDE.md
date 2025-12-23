# EXECUTION GUIDE: Phase 09 - Strategy Activation

**Document:** 00-EXECUTION-GUIDE.md
**Version:** 2.0 (with CRITIC gates and verification)
**Created:** 2025-12-23
**Master Plan:** 01-ROADMAP-FINAL.md (v2.0 ARGUS-Integrated)

---

## Quick Reference

```
OUTPUT FOLDER: .planning/phases/09-strategy-activation/orchestration/
```

---

## Anti-Hallucination Protocol

**CRITICAL: Verificacoes obrigatorias em cada fase**

| Verificacao | Comando | Quando |
|-------------|---------|--------|
| Tests passam | `mypy --strict && pytest -q` | Antes de qualquer GO |
| Arquivo existe | `ls -la <arquivo>` | Apos agent dizer que criou |
| Codigo compila | `python -c "import <modulo>"` | Apos mudanca de codigo |
| Metricas reais | Ver output do backtest | Nunca confiar em "metricas estimadas" |
| Git diff | `git diff --stat` | Verificar o que realmente mudou |

**Se agent disser algo sem mostrar output do comando: DESCONFIE.**

---

## Execution Flow (with CRITIC gates)

```
Phase 00-A → CRITIC review (sonnet) → GO/NO-GO
      ↓
Phase 00-B → CRITIC review (sonnet) → GO/NO-GO
      ↓
Phase 01 → CRITIC review (sonnet) → GO/NO-GO
      ↓
Phase 02 → CRITIC review (opus) → GO/NO-GO (CRITICAL - look-ahead)
      ↓
Phase 03 → CRITIC review (sonnet) → GO/NO-GO
      ↓
Phase 04 → User decision
      ↓
Phase 05 → CRITIC review (sonnet) → GO/NO-GO
      ↓
Phase 06 → CRITIC review (opus) → GO/NO-GO (CRITICAL - metrics)
      ↓
Phase 07 → CRITIC review (sonnet) → GO/NO-GO
      ↓
Phase 08 → CRITIC + SENTINEL (opus) → FINAL APPROVAL
```

**Model Policy:**
- **Sonnet**: Phases 00-A, 00-B, 01, 03, 05, 07 (standard review)
- **Opus**: Phases 02, 06, 08 (CRITICAL - money/risk/look-ahead)

---

## Execution Prompts

### Phase 00-A: BASELINE VALIDATION

**Executar:**
```
/run-plan .planning/phases/09-strategy-activation/09-PHASE-00A-PLAN.md
```

**Verificar antes de GO:**
- [ ] Backtest SMC rodou (ver logs)
- [ ] Backtest EMA rodou (ver logs)
- [ ] Metricas sao do OUTPUT real (nao inventadas)
- [ ] Arquivo `PHASE_00A_BASELINE_RESULTS.md` criado

**CRITIC review (sonnet):**
```
Spawn CRITIC (sonnet) to review PHASE_00A_BASELINE_RESULTS.md
Check: metrics match actual backtest output? comparison fair? conclusion justified?
Verify: CRITIC Phase 00-A output file exists before proceeding.
```

---

### Phase 00-B: CRITICAL BUG FIXES

**Executar:**
```
/run-plan .planning/phases/09-strategy-activation/10-PHASE-00B-PLAN.md
```

**Verificar antes de GO:**
- [ ] `git diff` mostra mudancas nos arquivos corretos
- [ ] `mypy --strict nautilus_gold_scalper/` passa
- [ ] `pytest -q` passa
- [ ] Backtest com diagnostic logging mostra 9 fatores > 0
- [ ] Arquivo `PHASE_00B_BUGFIX_REPORT.md` criado

**CRITIC review (sonnet):**
```
Spawn CRITIC (sonnet) to review:
1. Git diff - changes make sense?
2. Semantic collision actually fixed?
3. No new bugs introduced?
4. Tests actually ran (show pytest output)?
5. Verify PHASE_00A_CRITIC_REVIEW.md exists (previous phase reviewed).
```

---

### Phase 01: DIAGNOSTIC & BASELINE

**Executar:**
```
/run-plan .planning/phases/09-strategy-activation/02-PHASE-01-PLAN.md
```

**Verificar antes de GO:**
- [ ] Factor activation report com numeros reais
- [ ] Trade count > 50 (ou Plan B triggered)
- [ ] Arquivo `PHASE_01_DIAGNOSTIC_RESULTS.md` criado

**CRITIC review (sonnet):**
```
Spawn CRITIC (sonnet) to review:
1. Are diagnostic numbers from real backtest or estimated?
2. Verify PHASE_00B_CRITIC_REVIEW.md exists (previous phase reviewed).
```

---

### Phase 02: SMC DEEP AUDIT

**Executar:**
```
/run-plan .planning/phases/09-strategy-activation/03-PHASE-02-PLAN.md
```

**Verificar antes de GO (CRITICAL - look-ahead bias):**
- [ ] 17 look-ahead patterns checked with grep (show output)
- [ ] NautilusTrader config verified (show config)
- [ ] WFE >= 0.6 (show calculation)
- [ ] Arquivos criados:
  - `LOOKAHEAD_CHECKLIST.md`
  - `NAUTILUS_CONFIG_AUDIT.md`
  - `HWM_PROTECTION_DESIGN.md`
  - `PHASE_02_SMC_AUDIT.md`

**CRITIC review (MANDATORY - opus):**
```
Spawn CRITIC (opus) to review:
1. Each of 17 look-ahead patterns - grep output shown?
2. Any pattern FAILED? What was the fix?
3. WFE calculation correct?
4. No shortcuts taken?
```

---

### Phase 03: TREND_FOLLOW ACTIVATION

**Executar:**
```
/run-plan .planning/phases/09-strategy-activation/04-PHASE-03-PLAN.md
```

**Verificar antes de GO:**
- [ ] TREND_FOLLOW strategy backtest ran
- [ ] Metricas reais do output
- [ ] Arquivo `PHASE_03_TREND_FOLLOW.md` criado

**CRITIC review (sonnet):**
```
Spawn CRITIC (sonnet) to review:
1. Strategy makes sense? Metrics from real backtest?
2. Verify PHASE_02_CRITIC_REVIEW.md exists (previous phase reviewed).
```

---

### Phase 04: MEAN_REVERT DECISION

**Executar:**
```
/run-plan .planning/phases/09-strategy-activation/05-PHASE-04-PLAN.md
```

**Verificar:**
- [ ] Research feito com sources citados
- [ ] Decisao documentada com rationale
- [ ] Arquivos criados:
  - `MEAN_REVERT_RESEARCH.md`
  - `PHASE_04_DECISION.md`

**User decision required - nao e automatico.**

---

### Phase 05: FRAMEWORK INTEGRATION

**Executar:**
```
/run-plan .planning/phases/09-strategy-activation/06-PHASE-05-PLAN.md
```

**Verificar antes de GO:**
- [ ] 30% per-trade limit code exists (show code)
- [ ] 5:1 R:R enforcement code exists (show code)
- [ ] Execution modes (AUTO/SIGNAL_ONLY) work
- [ ] `mypy --strict` passa
- [ ] `pytest -q` passa
- [ ] Arquivo `PHASE_05_INTEGRATION.md` criado

**CRITIC review (sonnet):**
```
Spawn CRITIC (sonnet) to review:
1. Risk code correct? Edge cases handled? Tests exist?
2. Verify PHASE_04_DECISION.md exists (user decision documented).
```

---

### Phase 06: MULTI-STRATEGY BACKTEST

**Executar:**
```
/run-plan .planning/phases/09-strategy-activation/07-PHASE-06-PLAN.md
```

**Verificar antes de GO (CRITICAL - metrics):**
- [ ] WFE >= 0.6 (show backtest output)
- [ ] SQN >= 2.0 (show calculation)
- [ ] PSR >= 0.85 (show calculation)
- [ ] DSR > 0 (show calculation)
- [ ] PBO < 25% (show calculation)
- [ ] MC95DD < 4% (show Monte Carlo output)
- [ ] Trades >= 200
- [ ] Arquivos criados:
  - `FAILURE_MODE_MATRIX.md`
  - `PHASE_06_MULTI_STRATEGY.md`

**CRITIC review (MANDATORY - opus):**
```
Spawn CRITIC (opus) to review:
1. All metrics from REAL backtest output?
2. Calculations correct?
3. WFE formula applied correctly?
4. Monte Carlo actually ran 1000+ iterations?
5. No data snooping?
```

---

### Phase 07: PAPER TRADING

**Executar:**
```
/run-plan .planning/phases/09-strategy-activation/11-PHASE-07-PLAN.md
```

**Verificar antes de GO:**
- [ ] 2 weeks of logs exist
- [ ] Time gates verified (4:30 PM block, 4:55 PM close)
- [ ] HWM tracking correct (show examples)
- [ ] Both execution modes tested
- [ ] Arquivos criados:
  - `EXECUTION_MODE_TEST.md`
  - `PHASE_07_PAPER_TRADING.md`

**CRITIC review (sonnet):**
```
Spawn CRITIC (sonnet) to review:
1. Paper trading actually happened? Logs real? Issues found?
2. Verify PHASE_06_CRITIC_REVIEW.md exists (previous phase reviewed).
```

---

### Phase 08: PRODUCTION READINESS

**Executar:**
```
/run-plan .planning/phases/09-strategy-activation/12-PHASE-08-PLAN.md
```

**Verificar (FINAL GATE):**
- [ ] CRITIC review completed
- [ ] SENTINEL approval obtained
- [ ] All previous phases have CRITIC reviews
- [ ] Arquivos criados:
  - `PHASE_08_CRITIC_REVIEW.md`
  - `PHASE_08_SENTINEL_APPROVAL.md`

**CRITIC + SENTINEL review (MANDATORY - opus):**
```
Spawn CRITIC (opus): Full adversarial review
Spawn SENTINEL (opus): Apex compliance sign-off
Both must APPROVE for GO.
```

---

## Verification Commands Cheatsheet

```bash
# Tests passam?
mypy --strict nautilus_gold_scalper/ && pytest -q

# O que mudou?
git diff --stat
git diff <arquivo>

# Arquivo existe?
ls -la .planning/phases/09-strategy-activation/orchestration/

# Codigo importa?
python -c "from nautilus_gold_scalper.src.strategies.gold_scalper_strategy import GoldScalperStrategy"

# Config NautilusTrader?
rg -n "bars_timestamp_on_close|ts_init_delta|bar_execution" nautilus_gold_scalper/

# Look-ahead check rapido?
rg -n "close\[-1\]|iloc\[-1\]|\[i\+1\]" nautilus_gold_scalper/src/
```

---

## Red Flags (PARE se ver isso)

| Red Flag | O que significa |
|----------|-----------------|
| "Metricas estimadas" | Agent nao rodou backtest |
| "Deve funcionar" | Agent nao testou |
| "Arquivo criado" sem `ls` | Pode nao existir |
| Numeros redondos demais | Provavelmente inventados |
| "Tests passam" sem output | Pode nao ter rodado |
| Skip de CRITIC review | Risco de bug escondido |

---

## Output Files (Updated)

### Orchestration Folder

```
.planning/phases/09-strategy-activation/orchestration/
├── PHASE_00A_BASELINE_RESULTS.md
├── PHASE_00A_CRITIC_REVIEW.md        ← NEW
├── PHASE_00B_BUGFIX_REPORT.md
├── PHASE_00B_CRITIC_REVIEW.md        ← NEW
├── PHASE_01_DIAGNOSTIC_RESULTS.md
├── PHASE_01_CRITIC_REVIEW.md         ← NEW
├── LOOKAHEAD_CHECKLIST.md
├── NAUTILUS_CONFIG_AUDIT.md
├── HWM_PROTECTION_DESIGN.md
├── PHASE_02_SMC_AUDIT.md
├── PHASE_02_CRITIC_REVIEW.md         ← NEW (CRITICAL)
├── PHASE_03_TREND_FOLLOW.md
├── PHASE_03_CRITIC_REVIEW.md         ← NEW
├── MEAN_REVERT_RESEARCH.md
├── PHASE_04_DECISION.md
├── PHASE_05_INTEGRATION.md
├── PHASE_05_CRITIC_REVIEW.md         ← NEW
├── FAILURE_MODE_MATRIX.md
├── PHASE_06_MULTI_STRATEGY.md
├── PHASE_06_CRITIC_REVIEW.md         ← NEW (CRITICAL)
├── EXECUTION_MODE_TEST.md
├── PHASE_07_PAPER_TRADING.md
├── PHASE_07_CRITIC_REVIEW.md         ← NEW
├── PHASE_08_CRITIC_REVIEW.md
└── PHASE_08_SENTINEL_APPROVAL.md
```

---

## Hard Exit Criteria

| Gate | Condition | Action |
|------|-----------|--------|
| Phase 00-A | EMA > SMC | STOP or PIVOT |
| Phase 00-B | Bugs not fixed after 2 weeks | STOP or PIVOT |
| Phase 01 | < 50 trades after fix | Trigger Plan B |
| Phase 02 | WFE < 0.3 on dev set | STOP |
| Phase 02 | CRITIC finds look-ahead bias | STOP and FIX |
| Phase 06 | CRITIC finds metric errors | STOP and FIX |
| Holdout | Negative return 2021-2025 | STOP |
| Any | Engineering hours > 400 | HARD PAUSE |
| Any | CRITIC NO-GO without resolution | STOP |

---

## CRITIC Review Template

Cada CRITIC review deve responder:

```markdown
## CRITIC Review: Phase XX

### 1. Verification
- [ ] Output files exist
- [ ] Tests ran (show output)
- [ ] Metrics from real data (not estimated)

### 2. Adversarial Analysis
- What could be wrong?
- What was NOT tested?
- What assumptions were made?

### 3. Look-Ahead Check (if code changed)
- [ ] No future data access
- [ ] Indicators shifted correctly
- [ ] Bar timestamps correct

### 4. Verdict
[ ] GO - All checks pass
[ ] CONDITIONAL - Issues found but fixable
[ ] NO-GO - Critical issues, must fix before proceeding

### 5. Issues Found
1. ...
2. ...

### 6. Required Actions (if CONDITIONAL/NO-GO)
1. ...
2. ...
```

---

*End of Execution Guide v2.0*
