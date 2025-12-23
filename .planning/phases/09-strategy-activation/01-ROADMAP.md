# ROADMAP: Strategy Activation & Validation

## Changelog
- v1.1 (2025-12-23): Added detailed PLAN.md files for all 6 phases
- v1.0 (2025-12-23): Initial roadmap - 6 phases, multi-strategy activation

## Progress
- **Phases Completed:** 0/6
- **Current Phase:** Not started
- **Planning:** COMPLETE (all PLAN.md files created)

## Phase Overview

| Phase | Focus | Priority | Status | Plan File |
|-------|-------|----------|--------|-----------|
| 01 | Cleanup & Consolidation | P0 - BLOCKER | Not started | [02-PHASE-01-PLAN.md](02-PHASE-01-PLAN.md) |
| 02 | SMC_SCALPER Deep Audit | P0 - CRITICAL | Not started | [03-PHASE-02-PLAN.md](03-PHASE-02-PLAN.md) |
| 03 | TREND_FOLLOW Activation | P0 - CRITICAL | Not started | [04-PHASE-03-PLAN.md](04-PHASE-03-PLAN.md) |
| 04 | MEAN_REVERT Decision | P1 - HIGH | Not started | [05-PHASE-04-PLAN.md](05-PHASE-04-PLAN.md) |
| 05 | Framework Integration | P1 - HIGH | Not started | [06-PHASE-05-PLAN.md](06-PHASE-05-PLAN.md) |
| 06 | Multi-Strategy Backtest | P0 - CRITICAL | Not started | [07-PHASE-06-PLAN.md](07-PHASE-06-PLAN.md) |

---

## Phase 01: Cleanup & Consolidation (BLOCKER)

**Objective:** Limpar código morto e consolidar duplicações antes de auditar.

### Tasks

#### 01-01: Archive Dead Code
**Files to archive:**
- `scripts/backtest/strategies/ea_logic_full.py` → `_archive/`
- `scripts/backtest/strategies/ea_logic_python.py` → `_archive/`
- `scripts/backtest/strategies/ea_logic_compat.py` → `_archive/`
- `src/indicators/mtf_manager.py` → `_archive/` (signals/ version is active)
- `src/indicators/footprint_analyzer.py` → `_archive/` (no futures data)

**Verification:** No import errors after archiving

#### 01-02: Remove NEWS_TRADER from Flow
**Files to modify:**
- `strategy_selector.py`: Remove STRATEGY_NEWS_TRADER path or make it return STRATEGY_NONE
- `gold_scalper_strategy.py`: Remove any news trading logic

**Verification:** StrategySelector never returns NEWS_TRADER

#### 01-03: Consolidate MTF Manager
**Action:**
- Verify `signals/mtf_manager.py` is the canonical version
- Update any imports from `indicators/mtf_manager` to `signals/mtf_manager`
- Archive `indicators/mtf_manager.py`

**Verification:** All imports resolve correctly, tests pass

#### 01-04: Document Current Architecture
**Deliverable:** `ARCHITECTURE.md` showing:
- Strategy hierarchy (BaseGoldStrategy → GoldScalperStrategy)
- StrategySelector decision tree
- AdaptiveEVRouter arms
- Signal generation flow

**Agents:** 1 FORGE (opus)
**Blocking:** Must complete before Phase 02

---

## Phase 02: SMC_SCALPER Deep Audit (CRITICAL)

**Objective:** Validar profundamente se a estratégia SMC tem edge real.

### Tasks

#### 02-01: Indicator-by-Indicator Audit
**Files (~4,100 lines):**
- `order_block_detector.py` - OB detection logic
- `fvg_detector.py` - Fair Value Gap detection
- `liquidity_sweep.py` - Sweep detection
- `structure_analyzer.py` - HH/HL/LH/LL analysis
- `regime_detector.py` - Hurst/entropy regime

**CRUCIBLE Focus:**
- Cada indicador adiciona edge ou é ruído?
- Thresholds fazem sentido para XAUUSD?
- Combinação dos indicadores faz sentido?

#### 02-02: Confluence Scorer Audit
**File:** `confluence_scorer.py` (1,055 lines)

**CRUCIBLE Focus:**
- Pesos dos 9 fatores fazem sentido?
- Score threshold (65?) está calibrado?
- Scoring é robusto ou over-fitted?

#### 02-03: SMC Backtest Isolado
**Action:** Backtest com APENAS SMC_SCALPER

**Metrics Required:**
- WFE >= 0.6
- SQN >= 2.0
- PSR >= 0.85
- MC95DD < 4%
- Min 200 trades

**Deliverable:** `orchestration/SMC_BACKTEST_RESULTS.md`

#### 02-04: SMC GO/NO-GO Decision
**Gate:** Se métricas não atingidas, STOP e investigar root cause

**Agents:** 2 CRUCIBLE (opus) + 1 ORACLE (backtest)
**Checkpoint:** Human approval before Phase 03

---

## Phase 03: TREND_FOLLOW Activation (CRITICAL)

**Objective:** Ativar e validar estratégia Trend Follow (pullback + breakout).

### Tasks

#### 03-01: TrendFollow Code Audit
**File:** `signals/trend_follow.py` (196 lines)

**CRUCIBLE Focus:**
- Lógica de pullback (EMA bounce) está correta?
- Lógica de breakout (Donchian) está correta?
- Thresholds (ema_fast=20, ema_slow=50) fazem sentido?
- SL calculation é robusto?

#### 03-02: TrendFollow Integration Check
**Files:**
- `gold_scalper_strategy.py` lines 1499-1545 (router integration)
- `adaptive_router.py` (RouterArm definitions)

**Verify:**
- Candidates são gerados corretamente
- Router selection funciona
- Execution path completo

#### 03-03: TrendFollow Backtest Isolado
**Action:** Backtest com APENAS TREND_FOLLOW

**Variants to test:**
1. PULLBACK only
2. BREAKOUT only
3. Both combined

**Metrics Required:** Same as SMC

**Deliverable:** `orchestration/TRENDFOLLOW_BACKTEST_RESULTS.md`

#### 03-04: Enable TrendFollow by Default
**Files to modify:**
- `gold_scalper_strategy.py`: Set `enable_trend_follow=True` default

**Verification:** TrendFollow candidates appear in logs

**Agents:** 1 CRUCIBLE + 1 ORACLE
**Checkpoint:** Human approval before Phase 04

---

## Phase 04: MEAN_REVERT Decision (HIGH)

**Objective:** Decidir se implementamos Mean Revert ou removemos o enum.

### Tasks

#### 04-01: Mean Revert Research
**Questions:**
- Faz sentido para XAUUSD scalping?
- Quais indicadores usaríamos? (Bollinger? RSI? Regime-based?)
- StrategySelector já detecta regime "reverting" - como usar?

**Deliverable:** `orchestration/MEAN_REVERT_RESEARCH.md`

#### 04-02: Implementation Decision
**Options:**
1. **Implement:** Criar `mean_revert.py` similar a `trend_follow.py`
2. **Remove:** Deletar enum e path do StrategySelector
3. **Defer:** Manter enum mas retornar SMC_SCALPER quando selecionado

**Gate:** User decision required

#### 04-03: Execute Decision
**If Implement:**
- Create `signals/mean_revert.py`
- Add MeanRevertCandidate
- Integrate with Router
- Backtest

**If Remove:**
- Remove STRATEGY_MEAN_REVERT enum
- Update StrategySelector to not return it

**Agents:** 1 CRUCIBLE (research) + decision gate
**Checkpoint:** User chooses path

---

## Phase 05: Framework Integration (HIGH)

**Objective:** Integrar StrategySelector e AdaptiveEVRouter completamente.

### Tasks

#### 05-01: StrategySelector Validation
**File:** `strategy_selector.py` (550 lines)

**Verify:**
- All 6 gates work correctly
- Only valid StrategyTypes are returned
- Size multipliers are applied
- Score adjustments work

**Test:** Unit tests for each gate

#### 05-02: AdaptiveEVRouter Validation
**File:** `adaptive_router.py` (215 lines)

**Verify:**
- Thompson sampling works
- Context learning accumulates
- DD penalty applied correctly
- Bootstrap mode works

**Test:** Unit tests for selection logic

#### 05-03: Enable Router by Default
**Files to modify:**
- `gold_scalper_strategy.py`: Set `router_adaptive_ev=True` default

**Verification:** Router selection appears in logs

#### 05-04: Integration Test
**Action:** Run full integration test:
1. Selector chooses regime
2. Router chooses arm
3. Signal generated
4. Trade executed

**Deliverable:** `orchestration/INTEGRATION_TEST_RESULTS.md`

**Agents:** 1 FORGE + 1 SENTINEL
**Checkpoint:** Human verification

---

## Phase 06: Multi-Strategy Backtest (CRITICAL)

**Objective:** Validar o sistema completo com múltiplas estratégias.

### Tasks

#### 06-01: Individual Strategy Baselines
**Run separate backtests:**
1. SMC only (enable_trend_follow=False)
2. TrendFollow only (disable SMC in selector)
3. Mean Revert only (if implemented)

**Output:** Baseline metrics for each

#### 06-02: Combined Strategies - Selector Only
**Config:**
- use_selector=True
- router_adaptive_ev=False
- All strategies enabled

**Verify:** Selector switches between strategies correctly

#### 06-03: Combined Strategies - Router Active
**Config:**
- use_selector=True
- router_adaptive_ev=True
- All strategies enabled

**Verify:** Router learns and improves selection over time

#### 06-04: Comparison Analysis
**Compare:**
| Config | Trades | Win% | Profit | MaxDD | WFE | SQN |
|--------|--------|------|--------|-------|-----|-----|
| SMC only | | | | | | |
| TrendFollow only | | | | | | |
| Combined (Selector) | | | | | | |
| Combined (Router) | | | | | | |

**Deliverable:** `MULTI_STRATEGY_COMPARISON.md`

#### 06-05: Final GO/NO-GO
**Criteria:**
- Combined >= best individual (diversification benefit)
- All strategies contribute trades
- No single strategy dominates unfairly
- Drawdown reduced vs single strategy

**Agents:** 2 ORACLE + 1 DAEMON (synthesis)
**Final Gate:** User approval for production

---

## Execution Order

```
Phase 01 (Cleanup) ← BLOCKER
    ↓
Phase 02 (SMC Audit)
    ↓ checkpoint
Phase 03 (TrendFollow Activation)
    ↓ checkpoint
Phase 04 (Mean Revert Decision)
    ↓ user decision
Phase 05 (Framework Integration)
    ↓ checkpoint
Phase 06 (Multi-Strategy Backtest)
    ↓
FINAL GO/NO-GO
```

---

## Agent Allocation

| Phase | Agents | Model |
|-------|--------|-------|
| 01 | 1 FORGE | opus |
| 02 | 2 CRUCIBLE + 1 ORACLE | opus |
| 03 | 1 CRUCIBLE + 1 ORACLE | opus |
| 04 | 1 CRUCIBLE | opus |
| 05 | 1 FORGE + 1 SENTINEL | opus |
| 06 | 2 ORACLE + 1 DAEMON | opus |

**Total Agents:** ~10
**Max Parallel:** 2-3 per round

---

## Checkpoint Protocol

After each phase:
1. Write findings to `orchestration/PHASE_XX_FINDINGS.md`
2. Update this ROADMAP with status
3. Create brief summary for user
4. Wait for user approval before next phase

---

## Success Metrics

| Metric | Threshold | Required |
|--------|-----------|----------|
| WFE | >= 0.6 | Yes |
| SQN | >= 2.0 | Yes |
| PSR | >= 0.85 | Yes |
| MC95DD | < 4% | Yes |
| Min Trades | >= 200 | Yes |
| Multi-strategy benefit | >= 0% | Yes |
