# PLAN: Phase 05 - Framework Integration

## Metadata
- **Phase:** 05
- **Priority:** P1 - HIGH
- **Status:** Not Started
- **Agents:** 1 FORGE (opus) + 1 SENTINEL (opus)
- **Depends On:** Phase 04 Complete
- **Checkpoint:** Human verification

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

Integrar completamente o StrategySelector e o AdaptiveEVRouter. Ambos os frameworks estão implementados mas não estão 100% ativos ou validados. Esta fase garante que funcionam corretamente juntos.

---

## Files Under Audit

| File | Lines | Purpose |
|------|-------|---------|
| `strategy_selector.py` | ~550 | 6-gate selection |
| `adaptive_router.py` | ~215 | Thompson sampling |
| `gold_scalper_strategy.py` | ~100 lines relevant | Integration |
| **Total Focus** | **~865** | |

---

## Tasks

### Task 05-01: StrategySelector Validation

**Status:** Not Started

**File:** `src/strategies/strategy_selector.py` (~550 lines)

**Verify 6 Gates:**

| Gate | Purpose | Validation |
|------|---------|------------|
| 1. Safety | Block trading if unsafe | Test with DD scenarios |
| 2. FTMO | Adjust size for compliance | Test size multipliers |
| 3. News | Block during news (now NONE) | Test returns NONE |
| 4. Session | Filter by trading session | Test with different times |
| 5. Holiday | Block on holidays | Test with holiday dates |
| 6. Regime | Select strategy by regime | Test with different Hurst values |

**Unit Tests to Create:**
```python
def test_gate_1_safety_blocks_on_high_dd():
    """Gate 1 returns STRATEGY_NONE when DD > threshold."""
    pass

def test_gate_2_ftmo_applies_size_multiplier():
    """Gate 2 adjusts position size for FTMO compliance."""
    pass

def test_gate_3_news_returns_none():
    """Gate 3 returns STRATEGY_NONE during news (not NEWS_TRADER)."""
    pass

def test_gate_4_session_filters_correctly():
    """Gate 4 allows/blocks based on session time."""
    pass

def test_gate_5_holiday_blocks_on_holidays():
    """Gate 5 returns STRATEGY_NONE on holidays."""
    pass

def test_gate_6_regime_selects_correct_strategy():
    """Gate 6 selects TREND_FOLLOW/MEAN_REVERT/SMC based on Hurst."""
    pass

def test_selector_only_returns_valid_strategies():
    """Selector never returns NEWS_TRADER or invalid types."""
    pass

def test_size_multipliers_applied_correctly():
    """Size multipliers are calculated and applied."""
    pass

def test_score_adjustments_work():
    """Score adjustments modify signal confidence."""
    pass
```

**Acceptance Criteria:**
- [ ] All 6 gates work correctly
- [ ] Only valid StrategyTypes returned
- [ ] Size multipliers applied
- [ ] Score adjustments work
- [ ] All unit tests pass

---

### Task 05-02: AdaptiveEVRouter Validation

**Status:** Not Started

**File:** `src/strategies/adaptive_router.py` (~215 lines)

**Verify Components:**

| Component | Purpose | Validation |
|-----------|---------|------------|
| Thompson Sampling | Probabilistic arm selection | Test distribution |
| Context Learning | Learn from outcomes | Test update mechanism |
| DD Penalty | Reduce risk during DD | Test penalty application |
| Bootstrap Mode | Initial exploration | Test first N trades |

**Unit Tests to Create:**
```python
def test_thompson_sampling_selects_arms():
    """Thompson sampling produces valid arm selections."""
    pass

def test_context_learning_accumulates():
    """Router learns from trade outcomes."""
    pass

def test_dd_penalty_reduces_risk():
    """High DD reduces expected value of risky arms."""
    pass

def test_bootstrap_mode_explores():
    """First N trades explore all arms equally."""
    pass

def test_arm_selection_respects_probabilities():
    """Arms with higher EV selected more often."""
    pass

def test_router_handles_all_arm_types():
    """Router can select SMC, TREND_PULLBACK, TREND_BREAKOUT."""
    pass
```

**Acceptance Criteria:**
- [ ] Thompson sampling works
- [ ] Context learning accumulates
- [ ] DD penalty applied correctly
- [ ] Bootstrap mode works
- [ ] All unit tests pass

---

### Task 05-03: Enable Router by Default

**Status:** Not Started

**Prerequisite:** Tasks 05-01 and 05-02 pass.

**Files to Modify:**

1. **`gold_scalper_strategy.py`:**
```python
# Change:
router_adaptive_ev: bool = False
# To:
router_adaptive_ev: bool = True
```

**Verification:**
```bash
# Run strategy and check logs for router activity
python -m nautilus_gold_scalper.run_backtest --verbose

# Grep for router selection
rg "RouterArm|Thompson|select_arm" logs/latest.log
```

**Acceptance Criteria:**
- [ ] `router_adaptive_ev=True` is default
- [ ] Router selection appears in logs
- [ ] No errors on activation
- [ ] Tests pass

---

### Task 05-04: Integration Test

**Status:** Not Started

**Action:** Run full integration test of the complete flow.

**Test Scenario:**
```
1. Tick received
2. StrategySelector.select() → returns StrategyType
3. Based on type:
   - SMC_SCALPER → SMC indicators → ConfluenceScorer → Candidates
   - TREND_FOLLOW → TrendFollowGenerator → Candidates
4. AdaptiveEVRouter.select_arm() → best candidate
5. Signal generated with appropriate size
6. Order submitted
7. Trade outcome → Router learns
```

**Integration Test Code:**
```python
def test_full_integration_flow():
    """Test complete flow from tick to trade to learning."""

    # Setup
    strategy = GoldScalperStrategy(config)

    # Simulate trending regime
    mock_data = create_trending_data()
    strategy.on_data(mock_data)

    # Verify:
    # 1. Selector chose TREND_FOLLOW or SMC_SCALPER
    # 2. Candidates were generated
    # 3. Router selected an arm
    # 4. Order was submitted (or not, based on score)

    # Simulate trade outcome
    mock_fill = create_mock_fill(profit=100)
    strategy.on_order_filled(mock_fill)

    # Verify router learned from outcome
    assert strategy.router.arm_stats[selected_arm].wins > 0
```

**Test Cases:**
```python
# Test 1: Trending market → TREND_FOLLOW selected
# Test 2: Ranging market → SMC_SCALPER selected
# Test 3: High DD → SAFE_MODE or reduced size
# Test 4: News time → STRATEGY_NONE
# Test 5: Router learns from winning trade
# Test 6: Router learns from losing trade
# Test 7: DD penalty affects selection
```

**Deliverable:** `orchestration/INTEGRATION_TEST_RESULTS.md`

**Acceptance Criteria:**
- [ ] All integration tests pass
- [ ] Flow works end-to-end
- [ ] Router learning verified
- [ ] No unexpected behavior

---

### Task 05-05: SENTINEL Apex Compliance Check

**Status:** Not Started

**SENTINEL Review:**

1. **DD Tracking:**
   - Are both trailing and daily DD tracked correctly?
   - Does high DD trigger SAFE_MODE or halt?
   - Is HWM updated correctly?

2. **Time Gates:**
   - Does Selector respect 4:30 PM ET block?
   - Is emergency close at 4:55 PM ET working?

3. **Position Sizing:**
   - Are size multipliers Apex-compliant?
   - Is max position size enforced?

4. **Strategy Selection:**
   - Does SAFE_MODE reduce risk appropriately?
   - Are all strategies Apex-compliant?

**Acceptance Criteria:**
- [ ] SENTINEL approves Apex compliance
- [ ] No compliance gaps identified
- [ ] All safety mechanisms verified

---

## Execution Order

```
05-01 (Selector) ─────→ [FORGE]
        ↓
05-02 (Router) ───────→ [FORGE]
        ↓
05-03 (Enable) ───────→ [FORGE]
        ↓
05-04 (Integration) ──→ [FORGE]
        ↓
05-05 (Apex Check) ───→ [SENTINEL]
        ↓
Human Verification
```

---

## Phase Completion Checklist

- [ ] StrategySelector validated with unit tests
- [ ] AdaptiveEVRouter validated with unit tests
- [ ] Router enabled by default
- [ ] Integration tests pass
- [ ] SENTINEL approves Apex compliance
- [ ] Human verification complete

---

## Deliverables

1. `tests/test_strategy_selector.py` - Unit tests for Selector
2. `tests/test_adaptive_router.py` - Unit tests for Router
3. `tests/test_integration.py` - Integration tests
4. `orchestration/INTEGRATION_TEST_RESULTS.md` - Test results
5. `orchestration/PHASE_05_FINDINGS.md` - Summary

---

## Exit Criteria

Phase 05 is COMPLETE when:
1. Selector and Router individually validated
2. Integration flow works end-to-end
3. SENTINEL approves Apex compliance
4. Both frameworks enabled by default

**Next Phase:** Phase 06 - Multi-Strategy Backtest
