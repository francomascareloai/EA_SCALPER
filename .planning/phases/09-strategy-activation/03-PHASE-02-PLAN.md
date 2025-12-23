# PLAN: Phase 02 - SMC_SCALPER Deep Audit

## Metadata
- **Phase:** 02
- **Priority:** P0 - CRITICAL
- **Status:** Not Started
- **Agents:** 2 CRUCIBLE (opus) + 1 ORACLE (backtest)
- **Depends On:** Phase 01 Complete
- **Checkpoint:** Human approval before Phase 03

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

Validar profundamente se a estratégia SMC (Smart Money Concept) tem edge real. Esta é a estratégia principal do robô - deve ser rigorosamente auditada antes de ativar outras.

---

## Files Under Audit

| File | Lines | Purpose |
|------|-------|---------|
| `order_block_detector.py` | ~600 | OB detection logic |
| `fvg_detector.py` | ~400 | Fair Value Gap detection |
| `liquidity_sweep.py` | ~350 | Sweep detection |
| `structure_analyzer.py` | ~500 | HH/HL/LH/LL analysis |
| `regime_detector.py` | ~450 | Hurst/entropy regime |
| `confluence_scorer.py` | ~1,055 | 9-factor scoring |
| **Total** | **~3,355** | |

---

## Tasks

### Task 02-01: Order Block Detector Audit

**Status:** Not Started

**File:** `src/indicators/order_block_detector.py`

**CRUCIBLE Questions:**
1. O que define um Order Block válido? A implementação está correta?
2. Os thresholds (volume, price range) fazem sentido para XAUUSD?
3. O lookback period é adequado para scalping?
4. Há look-ahead bias na detecção?
5. OB detection adiciona edge ou é ruído?

**Validation Tests:**
```python
# Test 1: OB detection on known historical patterns
# Test 2: False positive rate analysis
# Test 3: Temporal correctness (no look-ahead)
```

**Acceptance Criteria:**
- [ ] Logic is correct per SMC theory
- [ ] Thresholds calibrated for XAUUSD
- [ ] No look-ahead bias
- [ ] Edge contribution verified

---

### Task 02-02: FVG Detector Audit

**Status:** Not Started

**File:** `src/indicators/fvg_detector.py`

**CRUCIBLE Questions:**
1. FVG detection segue a definição correta (3-candle gap)?
2. Minimum gap size faz sentido para XAUUSD spread?
3. FVG fill logic está implementada?
4. Como FVGs expiram? Time-based ou price-based?

**Validation Tests:**
```python
# Test 1: FVG detection accuracy
# Test 2: Fill detection accuracy
# Test 3: Edge contribution (trades at FVG vs random)
```

**Acceptance Criteria:**
- [ ] FVG definition correct
- [ ] Gap size calibrated for XAUUSD
- [ ] Fill logic works
- [ ] Edge verified

---

### Task 02-03: Liquidity Sweep Audit

**Status:** Not Started

**File:** `src/indicators/liquidity_sweep.py`

**CRUCIBLE Questions:**
1. O que define um sweep válido?
2. High/Low identification é robusto?
3. False sweep detection (price returns vs breaks)?
4. Timing: sweep acontece antes ou depois do trade?

**Validation Tests:**
```python
# Test 1: Sweep detection on known sweeps
# Test 2: False positive rate
# Test 3: Trade timing relative to sweep
```

**Acceptance Criteria:**
- [ ] Sweep definition correct
- [ ] High/Low identification robust
- [ ] Timing logic correct
- [ ] Edge verified

---

### Task 02-04: Structure Analyzer Audit

**Status:** Not Started

**File:** `src/indicators/structure_analyzer.py`

**CRUCIBLE Questions:**
1. HH/HL/LH/LL detection usa swing points corretos?
2. Swing point lookback é adequado?
3. Break of Structure (BOS) detection funciona?
4. Change of Character (CHoCH) detection funciona?

**Validation Tests:**
```python
# Test 1: Structure detection on trending market
# Test 2: Structure detection on ranging market
# Test 3: BOS/CHoCH accuracy
```

**Acceptance Criteria:**
- [ ] Swing point detection correct
- [ ] BOS logic correct
- [ ] CHoCH logic correct
- [ ] Edge verified

---

### Task 02-05: Regime Detector Audit

**Status:** Not Started

**File:** `src/indicators/regime_detector.py`

**CRUCIBLE Questions:**
1. Hurst exponent calculation está correto?
2. Shannon entropy calculation está correto?
3. Thresholds (0.55 trend, 0.45 revert) são válidos?
4. Regime changes são detectados com latência aceitável?

**Validation Tests:**
```python
# Test 1: Hurst on known trending data (should be > 0.5)
# Test 2: Hurst on known ranging data (should be < 0.5)
# Test 3: Regime change detection latency
```

**Acceptance Criteria:**
- [ ] Hurst calculation verified
- [ ] Entropy calculation verified
- [ ] Thresholds calibrated
- [ ] Latency acceptable

---

### Task 02-06: Confluence Scorer Audit

**Status:** Not Started

**File:** `src/signals/confluence_scorer.py` (~1,055 lines)

**CRUCIBLE Questions:**
1. Quais são os 9 fatores e seus pesos?
2. Os pesos fazem sentido? (Quais são mais importantes?)
3. Score threshold (65?) está calibrado?
4. Scoring é robusto ou over-fitted?
5. Há correlação excessiva entre fatores?

**9 Factors to Analyze:**
```
Factor              | Weight | Question
--------------------|--------|-------------------
Order Block         | ?      | Edge contribution?
FVG                 | ?      | Edge contribution?
Liquidity Sweep     | ?      | Edge contribution?
Structure           | ?      | Edge contribution?
Regime              | ?      | Edge contribution?
Volume              | ?      | Edge contribution?
Momentum            | ?      | Edge contribution?
Trend Alignment     | ?      | Edge contribution?
Session             | ?      | Edge contribution?
```

**Validation Tests:**
```python
# Test 1: Score distribution analysis
# Test 2: Win rate by score bucket (50-60, 60-70, 70-80, 80+)
# Test 3: Factor correlation matrix
# Test 4: Individual factor edge analysis
```

**Acceptance Criteria:**
- [ ] All 9 factors documented
- [ ] Weights make sense
- [ ] Score threshold calibrated
- [ ] No over-fitting detected
- [ ] Edge verified for combined score

---

### Task 02-07: SMC Backtest Isolado

**Status:** Not Started

**Action:** Run backtest with ONLY SMC_SCALPER strategy enabled.

**Configuration:**
```python
config = {
    "strategy_type": "SMC_SCALPER",
    "enable_trend_follow": False,
    "use_selector": False,  # Force SMC only
    "router_adaptive_ev": False,
}
```

**Dataset:** `data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet`

**Required Metrics:**
| Metric | Threshold | Required |
|--------|-----------|----------|
| WFE | >= 0.6 | Yes |
| SQN | >= 2.0 | Yes |
| PSR | >= 0.85 | Yes |
| MC95DD | < 4% | Yes |
| Min Trades | >= 200 | Yes |
| Profit Factor | > 1.3 | Yes |

**Walk-Forward Analysis:**
- Training: 70%, Test: 30%
- Minimum 3 folds
- WFE consistency across folds

**Deliverable:** `orchestration/SMC_BACKTEST_RESULTS.md`

**Acceptance Criteria:**
- [ ] All metrics meet thresholds
- [ ] WFE consistent across folds
- [ ] No over-fitting detected
- [ ] Equity curve reasonable

---

### Task 02-08: SMC GO/NO-GO Decision

**Status:** Not Started

**Decision Gate:**

```
IF all metrics pass AND no critical issues found:
    → GO: Proceed to Phase 03

ELSE:
    → NO-GO: STOP and investigate root cause
    → Document issues in ISSUES.md
    → May require strategy redesign
```

**GO Criteria:**
- [ ] All indicator audits passed
- [ ] Confluence scorer validated
- [ ] Backtest metrics met
- [ ] No critical issues

**NO-GO Actions:**
1. Document all issues found
2. Prioritize fixes
3. Re-run backtest after fixes
4. Re-evaluate GO/NO-GO

---

## Execution Order

```
02-01 (OB)      ─┐
02-02 (FVG)     ─┼─→ [CRUCIBLE 1]
02-03 (Sweep)   ─┘

02-04 (Structure) ─┐
02-05 (Regime)    ─┼─→ [CRUCIBLE 2]
02-06 (Scorer)    ─┘

02-07 (Backtest) ─────→ [ORACLE]

02-08 (GO/NO-GO) ─────→ [Human Decision]
```

**Parallelization:** CRUCIBLE 1 and CRUCIBLE 2 can run in parallel.

---

## Phase Completion Checklist

- [ ] All 6 indicator files audited
- [ ] Confluence scorer audited
- [ ] SMC backtest completed
- [ ] Metrics documented
- [ ] GO/NO-GO decision made
- [ ] Human approval obtained

---

## Deliverables

1. `orchestration/SMC_INDICATOR_AUDIT.md` - Indicator-by-indicator findings
2. `orchestration/SMC_SCORER_AUDIT.md` - Confluence scorer analysis
3. `orchestration/SMC_BACKTEST_RESULTS.md` - Backtest metrics and equity curve
4. `orchestration/PHASE_02_FINDINGS.md` - Summary and GO/NO-GO recommendation

---

## Exit Criteria

Phase 02 is COMPLETE when:
1. All SMC indicators validated or issues documented
2. Confluence scorer validated or issues documented
3. Backtest metrics meet thresholds OR root causes identified
4. Human approves GO/NO-GO decision

**Next Phase:** Phase 03 - TREND_FOLLOW Activation
