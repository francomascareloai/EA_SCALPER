# PLAN: Phase 00-B - Critical Bug Fixes

## Metadata
- **Phase:** 00-B
- **Priority:** P0 - CRITICAL
- **Status:** Not Started
- **Agents:** 1 FORGE (opus)
- **Depends On:** Phase 00-A (PROCEED verdict)
- **Duration:** 1 week

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

Corrigir todos os bugs conhecidos que impedem o sistema de 9 fatores de funcionar corretamente.

---

## Tasks

### Task 00B-01: Semantic Collision Fix

**Status:** Not Started
**Priority:** P0

**Problem:** Variable `_mtf_order_blocks` is overwritten by LTF detection. Confluence scorer receives M5 data thinking it is M15 structural zones.

**User Decision:** Use M15 for OB/FVG (Option A)

**Fix:**
```python
# BEFORE (ambiguous - gets overwritten)
self._mtf_order_blocks: list[OrderBlock] = []
self._mtf_fvgs: list[FairValueGap] = []

# AFTER (explicit by timeframe)
self._htf_order_blocks: list[OrderBlock] = []   # H1 - direction
self._mtf_order_blocks: list[OrderBlock] = []   # M15 - structure
self._ltf_order_blocks: list[OrderBlock] = []   # M5 - entry

self._htf_fvgs: list[FairValueGap] = []
self._mtf_fvgs: list[FairValueGap] = []
self._ltf_fvgs: list[FairValueGap] = []
```

**Files to Modify:**
| File | Change |
|------|--------|
| `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py` | Rename variables, fix detection logic |
| `nautilus_gold_scalper/src/signals/mtf_manager.py` | Populate correct lists by timeframe |
| `nautilus_gold_scalper/src/signals/confluence_scorer.py` | Receive M15 data for OB/FVG scoring |

**Validation:**
1. Run 1-week backtest with diagnostic logging
2. Verify OB and FVG factors score > 0
3. Compare before/after trade count

**Acceptance Criteria:**
- [ ] Variables renamed to explicit _htf/_mtf/_ltf
- [ ] MTF manager populates correct lists
- [ ] Confluence scorer receives correct timeframe data
- [ ] OB and FVG factors score > 0 in test

---

### Task 00B-02: File Path Fixes

**Status:** Not Started

**Corrected Paths:**
| Planned Path | Actual Path | Action |
|--------------|-------------|--------|
| `src/indicators/mtf_manager.py` | `nautilus_gold_scalper/src/indicators/mtf_manager.py` | Add deprecation warning |
| `src/signals/mtf_manager.py` | `nautilus_gold_scalper/src/signals/mtf_manager.py` | Production version |
| `tests/test_signals/test_mtf_manager.py` | Does not exist | CREATE |

**Actions:**
1. Add deprecation warning to legacy `indicators/mtf_manager.py`
2. Create tests for production `signals/mtf_manager.py`
3. Handle footprint test dependencies

**Acceptance Criteria:**
- [ ] Deprecation warning added to legacy file
- [ ] Tests created for production file
- [ ] All tests pass

---

### Task 00B-03: Trade Clustering Investigation

**Status:** Not Started

**Problem:** All 7 trades occurred Jan 2-10, 2024. ZERO trades after Jan 10.

**Investigation Steps:**
1. Add logging for factor scores at week boundaries
2. Compare factor activations: week 1 vs week 10 vs week 20
3. Check for state variables that grow unbounded
4. Verify MTF bar buffers don't overflow

**Possible Causes:**
- State reset issue after first trades
- Memory leak causing degradation
- MTF bar accumulation overflow
- Time-dependent bug in indicators

**Acceptance Criteria:**
- [ ] Root cause identified
- [ ] Fix implemented (if found)
- [ ] Verified trades distribute across time period

---

### Task 00B-04: bracket_sl_canceled Investigation

**Status:** Not Started

**Problem:** Failsafe triggers repeatedly with bracket_sl_canceled.

**Investigation:**
1. Check bracket order rejection cause
2. Verify SL/TP order submission
3. Check order lifecycle handling

**Acceptance Criteria:**
- [ ] Root cause identified
- [ ] Fix implemented

---

### Task 00B-05: Diagnostic Logging

**Status:** Not Started

**Implementation:**
```python
# In confluence_scorer.py, add verbose logging
logger.info(f"Factor breakdown:")
logger.info(f"  structure={structure_score:.2f}")
logger.info(f"  regime={regime_score:.2f}")
logger.info(f"  ob={ob_score:.2f} (count={len(order_blocks)})")
logger.info(f"  fvg={fvg_score:.2f} (count={len(fvgs)})")
logger.info(f"  sweep={sweep_score:.2f}")
logger.info(f"  amd={amd_score:.2f}")
logger.info(f"  fib={fib_score:.2f}")
logger.info(f"  mtf={mtf_score:.2f}")
logger.info(f"  footprint={footprint_score:.2f}")
logger.info(f"  TOTAL={total_score:.2f} (threshold={threshold})")
```

**Acceptance Criteria:**
- [ ] Diagnostic logging added
- [ ] Can see all 9 factor scores in logs
- [ ] Logging level configurable

---

## Validation

**Final Checks:**
```bash
# Run tests
mypy --strict nautilus_gold_scalper/
pytest -q

# Run short backtest with diagnostics
python -m nautilus_gold_scalper.run_backtest --period 1w --verbose
```

---

## Deliverables

1. `orchestration/PHASE_00B_BUGFIX_REPORT.md` - All fixes documented

---

## Output Format

```markdown
# Phase 00-B: Bug Fix Report

## Summary
[1-2 paragraphs with what was fixed]

## Fixes Applied

### 1. Semantic Collision
- Files modified: [list]
- Changes: [description]
- Before/After: [comparison]

### 2. File Paths
- Actions taken: [list]

### 3. Trade Clustering
- Root cause: [finding]
- Fix: [description]

### 4. bracket_sl_canceled
- Root cause: [finding]
- Fix: [description]

### 5. Diagnostic Logging
- Added to: [files]
- Sample output: [example]

## Validation Results
- mypy: PASS/FAIL
- pytest: PASS/FAIL (X tests)
- All 9 factors score > 0: YES/NO

## Next Steps
[What to do next]
```

---

## GO/NO-GO Gate

**Criteria:**
- [ ] All 9 factors can score > 0 (verify with diagnostic logs)
- [ ] No division by zero or null handling errors
- [ ] Test suite passes (`mypy --strict`, `pytest -q`)
- [ ] File paths corrected and documented

**Decision:**
| Outcome | Action |
|---------|--------|
| All criteria pass | Proceed to Phase 01 |
| 5+ factors fire | Proceed with caution |
| < 5 factors fire | Investigate further |

---

## Exit Criteria

Phase 00-B is COMPLETE when:
1. Semantic collision fixed
2. File paths corrected
3. Trade clustering investigated
4. Diagnostic logging added
5. All tests pass

**Next Phase:** Phase 01 - Diagnostic & Baseline
