# PLAN: Phase 03 - TREND_FOLLOW Activation

## Metadata
- **Phase:** 03
- **Priority:** P0 - CRITICAL
- **Status:** Not Started
- **Agents:** 1 CRUCIBLE (opus) + 1 ORACLE (backtest)
- **Depends On:** Phase 02 Complete (SMC GO)
- **Checkpoint:** Human approval before Phase 04

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

### 2. Quick Backtest Apos Cada Fix
```bash
# OBRIGATORIO apos qualquer mudanca de codigo
python -m nautilus_gold_scalper.run_backtest --start 2024-01-01 --end 2024-01-07

# Verificar:
# - Trades > 0 (senao algo quebrou)
# - Sem erros no log
# - Trade count nao caiu 50%+
```

### 3. Parallel Agents (sem limite)
- Pode spawnar multiplos agents em paralelo para fixes
- FORGE + ORACLE + SENTINEL simultaneo se necessario
- Nao economizar - usar quantos precisar

### 4. Anti-Hallucination
- SEMPRE mostrar output dos comandos
- NUNCA dizer "deve funcionar" sem testar
- NUNCA inventar metricas - usar output real

### 5. Verificacao Obrigatoria
```bash
# Antes de qualquer GO:
mypy --strict nautilus_gold_scalper/
pytest -q
# Quick backtest (1 semana)
```

---

## Objective

Ativar e validar a estratégia Trend Follow (pullback + breakout). Esta estratégia já está implementada mas desabilitada (`enable_trend_follow=False`). Precisamos validar o edge e ativá-la.

---

## Files Under Audit

| File | Lines | Purpose |
|------|-------|---------|
| `signals/trend_follow.py` | ~196 | Pullback + Breakout logic |
| `gold_scalper_strategy.py` | ~100 lines relevant | Router integration |
| `adaptive_router.py` | ~50 lines relevant | Arm definitions |
| **Total Focus** | **~350** | |

---

## Tasks

### Task 03-01: TrendFollow Code Audit

**Status:** Not Started

**File:** `src/signals/trend_follow.py` (~196 lines)

**CRUCIBLE Questions:**

**Pullback Logic:**
1. EMA fast (20) e slow (50) fazem sentido para XAUUSD scalping?
2. Pullback detection: price touches EMA and bounces?
3. Entry trigger: o que confirma o bounce?
4. Stop loss calculation é robusto?

**Breakout Logic:**
1. Donchian channel period faz sentido?
2. Breakout confirmation: volume? momentum?
3. False breakout filtering existe?
4. Entry timing: on break or after retest?

**General:**
1. TrendFollowCandidate score (0-100) como é calculado?
2. Há look-ahead bias?
3. Performance: cabe no budget de 50ms?

**Code Review Checklist:**
```python
# Verify these are implemented correctly:
- [ ] EMA calculation (no look-ahead)
- [ ] Pullback detection logic
- [ ] Breakout detection logic
- [ ] Score calculation
- [ ] SL/TP calculation
- [ ] Candidate generation
```

**Acceptance Criteria:**
- [ ] Pullback logic correct per technical analysis theory
- [ ] Breakout logic correct
- [ ] Thresholds make sense for XAUUSD
- [ ] No look-ahead bias
- [ ] Performance acceptable

---

### Task 03-02: TrendFollow Integration Check

**Status:** Not Started

**Files:**
- `gold_scalper_strategy.py` (lines ~1499-1545)
- `adaptive_router.py` (RouterArm definitions)

**Verify:**

1. **Candidate Generation:**
```python
# In gold_scalper_strategy.py:
# - TrendFollowGenerator is instantiated
# - generate_candidates() is called
# - Candidates are passed to router
```

2. **Router Integration:**
```python
# RouterArm enum includes:
# - TREND_PULLBACK
# - TREND_BREAKOUT
# Router can select these arms
```

3. **Execution Path:**
```
on_data()
    → StrategySelector.select() returns TREND_FOLLOW
    → TrendFollowGenerator.generate_candidates()
    → AdaptiveEVRouter.select_arm()
    → Execute selected candidate
```

**Test Cases:**
```python
# Test 1: Force TREND_FOLLOW regime, verify candidates generated
# Test 2: Verify router can select TREND_PULLBACK arm
# Test 3: Verify router can select TREND_BREAKOUT arm
# Test 4: End-to-end: regime → candidate → execution
```

**Acceptance Criteria:**
- [ ] Candidates generated correctly
- [ ] Router selection works
- [ ] Execution path complete
- [ ] No dead code paths

---

### Task 03-03: TrendFollow Backtest Isolado

**Status:** Not Started

**Action:** Run backtest with ONLY TREND_FOLLOW strategy.

**Test Variants:**

**Variant 1: PULLBACK Only**
```python
config = {
    "strategy_type": "TREND_FOLLOW",
    "trend_follow_mode": "PULLBACK_ONLY",
    "enable_smc": False,
}
```

**Variant 2: BREAKOUT Only**
```python
config = {
    "strategy_type": "TREND_FOLLOW",
    "trend_follow_mode": "BREAKOUT_ONLY",
    "enable_smc": False,
}
```

**Variant 3: Both Combined**
```python
config = {
    "strategy_type": "TREND_FOLLOW",
    "trend_follow_mode": "BOTH",
    "enable_smc": False,
}
```

**Dataset:** `data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet`

**Required Metrics (per variant):**
| Metric | Threshold | Required |
|--------|-----------|----------|
| WFE | >= 0.6 | Yes |
| SQN | >= 2.0 | Yes |
| PSR | >= 0.85 | Yes |
| MC95DD | < 4% | Yes |
| Min Trades | >= 200 | Yes |

**Comparison Analysis:**
| Variant | Trades | Win% | Profit | MaxDD | WFE | SQN |
|---------|--------|------|--------|-------|-----|-----|
| Pullback | | | | | | |
| Breakout | | | | | | |
| Combined | | | | | | |

**Deliverable:** `orchestration/TRENDFOLLOW_BACKTEST_RESULTS.md`

**Acceptance Criteria:**
- [ ] At least one variant meets thresholds
- [ ] Best variant identified
- [ ] WFE consistent across folds

---

### Task 03-04: Enable TrendFollow by Default

**Status:** Not Started

**Prerequisite:** Task 03-03 shows acceptable metrics.

**Files to Modify:**

1. **`gold_scalper_strategy.py`:**
```python
# Change:
enable_trend_follow: bool = False
# To:
enable_trend_follow: bool = True
```

2. **Configuration validation:**
```python
# Ensure TrendFollowGenerator is always instantiated
# Ensure candidates are always evaluated
```

**Verification:**
```bash
# Run strategy and check logs
python -m nautilus_gold_scalper.run_backtest --verbose

# Grep for TrendFollow activity
rg "TrendFollow" logs/latest.log
rg "TREND_PULLBACK|TREND_BREAKOUT" logs/latest.log
```

**Acceptance Criteria:**
- [ ] `enable_trend_follow=True` is default
- [ ] TrendFollow candidates appear in logs
- [ ] No errors on activation
- [ ] Tests pass

---

### Task 03-05: TrendFollow GO/NO-GO Decision

**Status:** Not Started

**Decision Gate:**

```
IF backtest metrics pass AND code audit passed:
    → GO: Enable TrendFollow, proceed to Phase 04

ELSE IF only one variant works:
    → PARTIAL GO: Enable only that variant

ELSE:
    → NO-GO: Keep disabled, investigate issues
```

**GO Criteria:**
- [ ] Code audit passed
- [ ] At least one variant meets metrics
- [ ] Integration verified
- [ ] Enabled by default

---

## Execution Order

```
03-01 (Code Audit) ─────→ [CRUCIBLE]
        ↓
03-02 (Integration) ─────→ [CRUCIBLE]
        ↓
03-03 (Backtest) ─────────→ [ORACLE]
        ↓
03-04 (Enable) ───────────→ [FORGE]
        ↓
03-05 (GO/NO-GO) ─────────→ [Human Decision]
```

---

## Phase Completion Checklist

- [ ] TrendFollow code audited
- [ ] Integration verified
- [ ] Backtest completed (3 variants)
- [ ] Best variant identified
- [ ] Enabled by default (if GO)
- [ ] Human approval obtained

---

## Deliverables

1. `orchestration/TRENDFOLLOW_CODE_AUDIT.md` - Code review findings
2. `orchestration/TRENDFOLLOW_BACKTEST_RESULTS.md` - Backtest metrics
3. `orchestration/PHASE_03_FINDINGS.md` - Summary and GO/NO-GO

---

## Exit Criteria

Phase 03 is COMPLETE when:
1. TrendFollow code validated
2. Backtest shows acceptable edge
3. Strategy enabled by default (if GO)
4. Human approves decision

**Next Phase:** Phase 04 - MEAN_REVERT Decision
