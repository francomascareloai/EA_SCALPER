# ROADMAP: Strategy Activation & Validation

## Changelog
- v1.3 (2025-12-23): Added Empirical Observations from backtest debugging (Score=0.0 fix, component analysis)
- v1.2 (2025-12-23): Added Phase 00 (Pre-Activation Sprint) - 34 CRITICAL blockers discovered
- v1.1 (2025-12-23): Added detailed PLAN.md files for all 6 phases
- v1.0 (2025-12-23): Initial roadmap - 6 phases, multi-strategy activation

## Progress
- **Phases Completed:** 0/7
- **Current Phase:** Phase 00 (Pre-Activation Sprint)
- **Status:** NO-GO - 34 CRITICAL blockers must be fixed before Phase 02
- **Latest Backtest (2025-12-23):** 7 trades in 6 months, +$319 PnL, Score=0.0 bug FIXED

---

## Empirical Observations (2025-12-23 Backtest Debugging Session)

### Key Finding: Only 1 of 9 Confluence Factors Fires

During extensive backtest debugging, we discovered that most signals only activate the **structure** component:

```
structure=15.0, regime=0.0, ob=0.0, fvg=0.0, sweep=0.0, amd=0.0, fib=0.0, mtf=0.0, footprint=0.0
```

**Impact on Roadmap:**
- **Category 2 (Semantic Collision)** confirmed as likely root cause - OB/FVG may be receiving wrong data
- **Category 7 (Ablation Study)** is now CRITICAL - need to understand why 8/9 factors score=0

### Score=0.0 Bug (FIXED in commit 58b84178)

Session adjustment was killing scores:
- `session_filter.py:154-161`: Upgrade quality when session explicitly allowed
- `confluence_scorer.py:642-646`: Don't apply -5 adjustment when trading allowed

### Trade Frequency Issue

| Period | Trades | Expected | Gap |
|--------|--------|----------|-----|
| 6 months | 7 | ~30-40 | 4-5x fewer |

**Root Cause Hypothesis:** Semantic collision + high threshold (35) + broken OB/FVG detection

### Score Ranges by Session

| Session | Score Range | Trades |
|---------|-------------|--------|
| Asian | 16-22 | None (correct) |
| London | 30-40 | Few |
| Overlap | 44-52 | Most |
| NY | 35-48 | Some |

### Recommendations for Phase 00

1. **Priority 1:** Fix Category 2 (Semantic Collision) - likely explains OB/FVG score=0
2. **Priority 2:** Run ablation study after fix to see which factors now contribute
3. **Priority 3:** Consider lowering threshold to 25-30 after fixes

---

**Original Plan:** Start Phase 02 (SMC Deep Audit) immediately after Phase 01 cleanup.

**Reality Check:** Deep analysis revealed **34 CRITICAL blockers** that make Phase 02 unreliable:
- **MTF Duplication**: Tests validate `indicators/mtf_manager.py` (legacy EMA-based), production uses `signals/mtf_manager.py` (SMC-based) → Tests don't validate production code!
- **Semantic Collision**: Variable `_mtf_order_blocks` overwritten by LTF detection, scorer receives M5 data thinking it's M15 structural zones → Wrong data = wrong signals!
- **Test Coverage**: 52.68% line / 28.66% branch (below 70%/50% minimums) → Hidden bugs
- **Edge Hypothesis Unproven**: 9 confluence factors but no ablation study → May be overfitted!

**Conclusion:** Must execute **2-week Pre-Activation Sprint (Phase 00)** before Phase 02, or audit will be based on unreliable code.

## Planning Documents Map

| Document | Purpose | Status |
|----------|---------|--------|
| **00-BRIEF.md** | High-level objective & scope | ✅ Complete |
| **01-ROADMAP.md** | THIS FILE - 7-phase execution plan | 🔄 Updated |
| **02-CRITICAL_ISSUES_AUDIT.md** | Technical reference - 34 issues detailed | ✅ Complete |
| **03-PRE_ACTIVATION_CHECKLIST.md** | Executable tasks for Phase 00 | ✅ Complete |
| **04-EXECUTIVE_SUMMARY.md** | Decision document for Franco | ✅ Complete |

## Phase Overview

| Phase | Focus | Priority | Status | Tasks | Details |
|-------|-------|----------|--------|-------|---------|
| **00** | **Pre-Activation Sprint** | **P0 - BLOCKER** | ⬜ Not started | 46 tasks | [03-PRE_ACTIVATION_CHECKLIST.md](03-PRE_ACTIVATION_CHECKLIST.md) |
| 01 | Cleanup & Consolidation | P0 - BLOCKER | ⚠️ Blocked by 00 | See below | Integrated below |
| 02 | SMC_SCALPER Deep Audit | P0 - CRITICAL | ⚠️ Blocked by 00 | See below | Integrated below |
| 03 | TREND_FOLLOW Activation | P0 - CRITICAL | ⚠️ Blocked by 02 | See below | Integrated below |
| 04 | MEAN_REVERT Decision | P1 - HIGH | ⚠️ Blocked by 03 | See below | Integrated below |
| 05 | Framework Integration | P1 - HIGH | ⚠️ Blocked by 04 | See below | Integrated below |
| 06 | Multi-Strategy Backtest | P0 - CRITICAL | ⚠️ Blocked by 05 | See below | Integrated below |

**Total Timeline:** Phase 00 (2 weeks) + Phases 01-06 (4-6 weeks) = **6-8 weeks to production**

---

## 🚨 USER DECISION REQUIRED (Blocks Phase 00 Start)

### Decision 1: Semantic Collision - OB/FVG Timeframe (MANDATORY)
**Question:** Which timeframe should confluence scorer use for Order Blocks?

- [ ] **Option A (RECOMMENDED)**: MTF (M15) - SMC structural zones
  - Aligns with SMC philosophy (M15 = structure)
  - More reliable, less noise
  - **Why recommended:** Structural zones from higher timeframe provide stronger confluence

- [ ] **Option B**: LTF (M5) - Precise entry timing
  - More granular entries
  - More noise, less reliable signals

- [ ] **Option C**: Both (combined list)
  - Maximum information
  - More complex, risk of conflicting signals

**Impact:** Blocks SEM-001 task (Day 1-2 of Phase 00). Must decide before starting.

### Decision 2-4: Optional (Can Defer to Phase 04)
- **Decision 2:** MT5/Ninja adapters (YES fix / NO archive) - Not blocking
- **Decision 3:** TradeManager integration (YES integrate / NO archive) - Not blocking
- **Decision 4:** STRATEGY_MEAN_REVERT (Implement / Remove / Defer) - Phase 04 decision

---

## Phase 00: Pre-Activation Sprint (2 weeks, 46 tasks)

**Objective:** Fix critical blockers discovered during deep analysis BEFORE starting Phase 02 SMC audit.

**Why This Phase Exists:**
Original plan assumed code was "ready" for audit. Reality: 34 CRITICAL issues that would make audit unreliable. This sprint fixes foundations so Phase 02+ can proceed confidently.

### Week 1: Critical Blockers (5 days, ~29 hours)

#### Day 1-2: MTF & Semantic Collision (13 hours)

**MTF Manager Duplication (6 hours)**
- ⬜ MTF-001: Add deprecation warning to `src/indicators/mtf_manager.py` (30 min)
- ⬜ MTF-002: Create `tests/test_signals/test_mtf_manager.py` with comprehensive tests (3 hours)
  - Test bullish/bearish/ranging alignment
  - Test premium/discount zones
  - Test BOS/CHoCH integration
  - Test regime blocking
- ⬜ MTF-003: Validate strategy still works (quick backtest) (1 hour)
- ⬜ MTF-004: Verify coverage increased (≥70% for mtf_manager) (30 min)
- ⬜ MTF-005: Archive legacy `src/indicators/mtf_manager.py` (1 hour)

**Semantic Collision Fix (7 hours)** ⚠️ REQUIRES DECISION 1
- ⬜ SEM-001: Rename variables (1 hour)
  - `_mtf_order_blocks` → `_htf_order_blocks`, `_mtf_order_blocks`, `_ltf_order_blocks`
  - `_mtf_fvgs` → `_htf_fvgs`, `_mtf_fvgs`, `_ltf_fvgs`
- ⬜ SEM-002: Fix OB/FVG detection logic (separate HTF/MTF/LTF) (2 hours)
- ⬜ SEM-003: Update confluence scorer call (30 min)
- ⬜ SEM-004: Run baseline backtest BEFORE fix (1 hour)
- ⬜ SEM-005: Run validation backtest AFTER fix (1 hour)
- ⬜ SEM-006: Document changes (BUGFIX_LOG + CHANGELOG) (30 min)

**Checkpoint 1:** Coverage increased, semantic collision fixed, strategy works

#### Day 3-4: Test Coverage (12-18 hours)

- ⬜ COV-001: Time Gates Tests (2 hours)
  - 4:30 PM block, 4:55 PM emergency, 4:59 PM flatten
  - Timezone ET vs UTC, DST transitions
- ⬜ COV-002: DD Breach Flatten Tests (2 hours)
  - Trailing DD 4.5% triggers, Daily DD 3.0% halt
  - HWM tracking with unrealized, failsafe latch
- ⬜ COV-003: Execution Failsafe Tests (2 hours)
  - Bracket rejection, watchdog flatten, order lifecycle
- ⬜ COV-004: Confluence Scoring Tests (3 hours)
  - All 9 factors contribute
  - ICT sequence validation (regression for at_poi fix)
  - Session-specific weights, phase multipliers
- ⬜ COV-005: MTF Integration Tests (3 hours)
  - HTF/MTF/LTF bar subscriptions
  - Alignment detection, regime blocking
  - Premium/discount logic

**Checkpoint 2:** Coverage ≥70% line / 50% branch

#### Day 5: Apex & Temporal (4 hours)

**Apex Compliance (3 hours)**
- ⬜ APEX-001: Timezone standardization audit (1 hour)
  - Grep all `utcnow()`, `timezone.utc`, `GMT` references
- ⬜ APEX-002: Implement standardization (1.5 hours)
  - All daily boundaries → `America/New_York`
  - Add degraded mode (4:20 PM block, 4:45 PM close)
- ⬜ APEX-003: Add DST edge case tests (30 min)

**Temporal Integrity (1 hour)**
- ⬜ TEMP-001: Deprecate EA parity scripts (30 min)
  - `ea_logic_full.py`, `ea_logic_python.py`, `ea_logic_compat.py`
- ⬜ TEMP-002: Document validation approach (30 min)
  - "Don't use MC/WFA until refactored, use ORACLE instead"

**Checkpoint 3:** Foundations solid, ready for ablation

### Week 2: Edge Discovery & Validation (5 days, ~20 hours)

#### Day 6-8: Ablation Study (14 hours)

**Design Phase (2 hours)**
- ⬜ ABL-001: Create 10 ablation config variants (1 hour)
  - Baseline + 9 configs (each disables one factor)
- ⬜ ABL-002: Design statistical analysis (1 hour)
  - Metrics: WFE, SQN, PF, trade_count, max_DD
  - Significance: p < 0.05

**Execution Phase (8 hours)**
- ⬜ ABL-003: Run baseline backtest (all 9 factors) (1 hour)
- ⬜ ABL-004: Run 9 ablation variants (6 hours)
  - Config 1: Disable Structure
  - Config 2: Disable Regime
  - Config 3: Disable OB
  - Config 4: Disable FVG
  - Config 5: Disable Sweep
  - Config 6: Disable AMD
  - Config 7: Disable Fib
  - Config 8: Disable MTF
  - Config 9: Disable Footprint
- ⬜ ABL-005: Collect & compare results (1 hour)

**Analysis Phase (3 hours)**
- ⬜ ABL-006: Identify non-contributing factors (1 hour)
- ⬜ ABL-007: Create simplification proposal (1 hour)
  - Target: 3-5 factors (down from 9)
- ⬜ ABL-008: Document findings (ABLATION_RESULTS.md) (1 hour)

**Checkpoint 4:** Evidence-based factor list

#### Simplification Phase (6 hours) ⚠️ Requires approval on factors to remove

- ⬜ SIMP-001: Remove non-contributing factors (2 hours)
- ⬜ SIMP-002: Update tests for simplified scorer (1 hour)
- ⬜ SIMP-003: Run validation backtest (1 hour)
- ⬜ SIMP-004: Document simplification (1 hour)
- ⬜ SIMP-005: Update Phase 02 plan based on findings (1 hour)

**Checkpoint 5:** Simplified scorer validated

#### Day 9-10: Documentation & Prep (6 hours)

**Architecture Documentation (4 hours)**
- ⬜ DOC-001: Create ARCHITECTURE.md (3 hours)
  - Strategy hierarchy diagram
  - StrategySelector decision tree
  - AdaptiveEVRouter arms
  - Signal generation flow
  - Risk management layers
- ⬜ DOC-002: Auto-generate class hierarchy (1 hour)

**Final Prep (2 hours)**
- ⬜ DOC-003: Update this ROADMAP with findings (30 min)
- ⬜ DOC-004: Create Phase 02 handoff document (1.5 hours)
  - Week 1-2 accomplishments
  - Updated blocker count (target: ≤10 CRITICAL)
  - Ablation executive summary
  - GO/NO-GO recommendation

**Checkpoint 6:** Ready for Phase 02

### Phase 00 GO/NO-GO Criteria

| Criterion | Current | Target | Required |
|-----------|---------|--------|----------|
| MTF duplication resolved | ❌ 2 implementations | ✅ 1 canonical | YES |
| Semantic collision fixed | ❌ LTF overwrites MTF | ✅ Separate by TF | YES |
| Test coverage (line) | 52.68% | ≥70% | YES |
| Test coverage (branch) | 28.66% | ≥50% | YES |
| Apex compliance verified | ⚠️ Partial | ✅ Complete | YES |
| Ablation study complete | ❌ Not started | ✅ Done + simplified | YES |
| CRITICAL issues | 34 open | ≤10 open | YES |
| Documentation | ⚠️ Incomplete | ✅ ARCHITECTURE.md | YES |

**Verdict:** ❌ NO-GO until all criteria ✅

### Agent Allocation (Phase 00)

| Agent Type | Model | Count | Tasks |
|------------|-------|-------|-------|
| **FORGE** | opus | 3 | MTF fix, Semantic fix, Coverage tests, Timezone, Simplification |
| **ORACLE** | opus | 1 | Ablation backtests (10 variants) |
| **CRUCIBLE** | opus | 1 | Ablation design & analysis |
| **SENTINEL** | opus | 1 | Apex compliance verification |
| **DOCUMENTER** | opus | 1 | ARCHITECTURE.md creation |

**Total:** ~8 agent invocations (some parallel)
**Max Parallel:** 2-3 per round (per CORE orchestration rules)

**Reference:** See [03-PRE_ACTIVATION_CHECKLIST.md](03-PRE_ACTIVATION_CHECKLIST.md) for full task details.

**Phase 00 Completion:** All tasks ✅ → Proceed to Phase 01

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
🚨 USER DECISION 1 (Semantic Collision) ← MANDATORY BEFORE START
    ↓
Phase 00 (Pre-Activation Sprint - 2 weeks)
    Week 1: MTF fix, Semantic fix, Coverage, Apex, Temporal
    Week 2: Ablation study, Simplification, Documentation
    ↓ checkpoint (ALL Phase 00 GO/NO-GO criteria must be ✅)
Phase 01 (Cleanup & Consolidation)
    Archive dead code, remove NEWS_TRADER, document architecture
    ↓
Phase 02 (SMC Audit)
    Indicator-by-indicator audit, confluence scorer analysis
    ↓ checkpoint (SMC GO/NO-GO)
Phase 03 (TrendFollow Activation)
    Code audit, integration check, isolated backtest
    ↓ checkpoint
Phase 04 (Mean Revert Decision)
    Research → user decision → execute
    ↓ user decision
Phase 05 (Framework Integration)
    StrategySelector validation, AdaptiveEVRouter validation
    ↓ checkpoint
Phase 06 (Multi-Strategy Backtest)
    Individual baselines, combined selector, combined router
    ↓
FINAL GO/NO-GO (Production Readiness)
```

**Critical Path:** Phase 00 BLOCKS everything else. Must complete all 8 GO/NO-GO criteria before Phase 02.

---

## Agent Allocation

| Phase | Agents | Model | Notes |
|-------|--------|-------|-------|
| **00** | **8 total** | **opus** | FORGE(×3), ORACLE(×1), CRUCIBLE(×1), SENTINEL(×1), DOCUMENTER(×1) |
| 01 | 1 FORGE | opus | Architecture doc |
| 02 | 2 CRUCIBLE + 1 ORACLE | opus | Deep strategy audit |
| 03 | 1 CRUCIBLE + 1 ORACLE | opus | TrendFollow validation |
| 04 | 1 CRUCIBLE | opus | Research only |
| 05 | 1 FORGE + 1 SENTINEL | opus | Integration tests |
| 06 | 2 ORACLE + 1 DAEMON | opus | Multi-strategy comparison |

**Total Agents:** ~18 (Phase 00 + Phases 01-06)
**Max Parallel:** 2-3 per round (default, unless plan specifies otherwise)

---

## Checkpoint Protocol

After each phase:
1. Write findings to `orchestration/PHASE_XX_FINDINGS.md`
2. Update this ROADMAP with status
3. Create brief summary for user
4. Wait for user approval before next phase

---

## Success Metrics

| Metric | Threshold | Required | Phase Validated |
|--------|-----------|----------|-----------------|
| **Phase 00 Completion** | All 8 GO/NO-GO criteria ✅ | **YES** | Phase 00 |
| Test Coverage (line) | >= 70% | YES | Phase 00 |
| Test Coverage (branch) | >= 50% | YES | Phase 00 |
| WFE | >= 0.6 | YES | Phase 02, 03, 06 |
| SQN | >= 2.0 | YES | Phase 02, 03, 06 |
| PSR | >= 0.85 | YES | Phase 02, 03, 06 |
| MC95DD | < 4% | YES | Phase 02, 03, 06 |
| Min Trades | >= 200 | YES | Phase 02, 03, 06 |
| Multi-strategy benefit | >= 0% | YES | Phase 06 |

**Gate Rule:** Phase 00 is MANDATORY gate. If Phase 00 NO-GO → entire roadmap blocked.

---

## Summary: What Changed

**Before:** 6 phases, start with Phase 01 cleanup then Phase 02 SMC audit

**After (Integrated Plan):**
1. **Phase 00 added** (2-week Pre-Activation Sprint) - BLOCKS everything
   - 34 CRITICAL issues discovered during deep analysis
   - 46 executable tasks across MTF fix, Semantic collision, Coverage, Ablation, Docs
   - 8 mandatory GO/NO-GO criteria must pass before Phase 02

2. **Supporting Documents:**
   - 02-CRITICAL_ISSUES_AUDIT.md = Technical reference (34 issues detailed)
   - 03-PRE_ACTIVATION_CHECKLIST.md = Task-by-task execution guide
   - 04-EXECUTIVE_SUMMARY.md = Decision document for Franco

3. **Decision Required:** Option A/B/C for Semantic Collision (blocks Day 1 start)

4. **Timeline Impact:** 2 weeks added upfront, but prevents wasted effort on unreliable code

**Bottom Line:** All findings now integrated into ONE cohesive roadmap. Phase 00 ensures solid foundations before expensive audit work.
