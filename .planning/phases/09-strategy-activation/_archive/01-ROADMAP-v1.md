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

---

## ORACLE Critical Review (Validation Perspective)

**Reviewed:** 2025-12-23
**Agent:** ORACLE v3.3
**CLAUDE_MD_VERSION:** 3.10.21
**STATUS:** COMPLETE

### Backtest Methodology Assessment

**CRITICAL GAPS IDENTIFIED:**

1. **Walk-Forward Analysis Design - INSUFFICIENT**
   - Plan specifies "70% IS, 30% OOS, minimum 3 folds"
   - For 22 years of data, this is woefully inadequate
   - ORACLE standard: 12 rolling windows minimum
   - 3 folds = each OOS window is ~2.4 years (too coarse to detect regime failures)
   - **FIX REQUIRED:** Expand to 12 rolling windows (IS: 2 years, OOS: 6 months, purge gap: max trade duration)

2. **Monte Carlo Specification - MISSING**
   - Plan mentions MC95DD < 4% threshold (correct for Apex)
   - BUT NO specification of:
     - Number of runs (ORACLE requires 5000)
     - Block bootstrap vs simple shuffle (must preserve autocorrelation)
     - Confidence intervals
   - **FIX REQUIRED:** Add MC methodology: 5000 runs, block bootstrap with block size = average trade duration

3. **Holdout Period - NOT RESERVED**
   - Ablation study runs on full 2003-2025 dataset
   - Then validation runs on SAME dataset
   - This is IN-SAMPLE selection + IN-SAMPLE validation = guaranteed overfitting
   - **FIX REQUIRED:** Reserve 2020-2025 as TRUE holdout. Run ablation on 2003-2019 only. Final validation ONLY on holdout.

### Statistical Rigor

**BLOCKING GAPS:**

| Missing Element | ORACLE Requirement | Plan Status | Severity |
|-----------------|-------------------|-------------|----------|
| DSR (Deflated Sharpe) | DSR > 0 mandatory | NOT MENTIONED | BLOCKER |
| PBO (Prob. Backtest Overfitting) | PBO < 25% | NOT MENTIONED | BLOCKER |
| Purged CV | Gap between train/test | NOT MENTIONED | BLOCKER |
| Multiple Testing Correction | Bonferroni or similar | NOT MENTIONED | BLOCKER |

**The ablation study tests 10 configurations + 3 TrendFollow variants + 5 combined configs = ~18 tests on same dataset.**

Without multiple testing correction, family-wise error rate at p=0.05: 1-(0.95)^18 = **60% chance of false positive**.

**SAMPLE SIZE CRISIS:**
- Empirical observation: 7 trades in 6 months
- ORACLE minimum: 200 trades
- **ANY statistical conclusions from 7 trades are INVALID**
- Cannot calculate meaningful WFE, SQN, PSR with n=7

### Metric Threshold Analysis

| Metric | Plan Threshold | ORACLE Assessment | Recommendation |
|--------|---------------|-------------------|----------------|
| WFE | >= 0.6 | Potentially too low for XAUUSD | >= 0.7 for high confidence |
| SQN | >= 2.0 | Acceptable minimum | Target 2.5-3.0 |
| PSR | >= 0.85 | Reasonable but incomplete | Must pair with DSR |
| MC95DD | < 4% | Correct for Apex | Approve |
| Profit Factor | > 1.3 | TOO LOW | >= 1.5 for XAUUSD spreads |
| Min Trades | >= 200 | Correct | CURRENTLY: 7 (BLOCKED) |

**WARNING:** PSR alone does NOT account for selection bias. The plan tests multiple strategies/configurations. Without DSR, PSR is misleading.

### Overfitting Protection

**CURRENT PROTECTION: INADEQUATE**

1. **No holdout period** - All validation uses same data as development
2. **Ablation on full dataset** - Factor selection biased toward in-sample performance
3. **No parameter count audit** - 9 factors with unknown sub-parameters (likely 50+ total)
4. **No PBO calculation** - Cannot quantify overfitting probability

**POSITIVE:** Ablation study is the right concept. Reducing 9 factors to 3-5 will reduce overfitting. BUT methodology must be fixed.

### Dataset Concerns

1. **Stride 20 discards 95% of ticks**
   - May hide tick-level patterns SMC relies on
   - Liquidity sweeps are tick-level events
   - Order block detection accuracy may be compromised

2. **22-year span crosses multiple regimes**
   - Pre-crisis (2003-2007), Crisis (2008-2011), Consolidation (2012-2019), COVID/Inflation (2020-2025)
   - Strategy that "works" in all regimes is likely: genuinely robust OR overfitted to patterns that repeat
   - The 7-trade issue suggests overly conservative filtering

3. **No GATE 0 data quality validation**
   - No explicit null checks, timestamp monotonicity, price range validation
   - ORACLE protocol requires GATE 0 before any statistical tests

### Missing Validation Steps

| Step | ORACLE Requirement | Plan Status | Priority |
|------|-------------------|-------------|----------|
| DSR Calculation | Every GO/NO-GO decision | MISSING | P0 |
| PBO Threshold | PBO < 25% | MISSING | P0 |
| Holdout Reserve | 20-25% most recent data | MISSING | P0 |
| 12-Window WFA | Rolling, purged | Only 3 folds | P0 |
| MC 5000 Runs | Block bootstrap | Unspecified | P0 |
| Paper Trading Gate | Before GO decision | After GO (wrong!) | P0 |
| Regime-Stratified WFA | Per-regime validation | MISSING | P1 |
| Transaction Cost Sensitivity | Vary spread/slippage | MISSING | P1 |
| Consistency Rule (30% single day) | Apex compliance | MISSING | P1 |
| Confidence Intervals | On all metrics | MISSING | P2 |
| GATE 0 Data Quality | Before any tests | MISSING | P2 |

### Recommendations

**BLOCKING ISSUES (Must fix before proceeding):**

1. **Add DSR calculation** to Phase 02, 03, and 06 GO/NO-GO criteria
   - DSR > 0 is MANDATORY per ORACLE protocol
   - Use Bailey-Lopez de Prado formula
   - Correct for total number of trials (N_trials)

2. **Reserve 2020-2025 as TRUE holdout**
   - Run ablation study on 2003-2019 ONLY
   - Final validation on 2020-2025 (NEVER optimize on this data)
   - This prevents selection bias contaminating results

3. **Specify Monte Carlo methodology**
   - Minimum 5000 simulation runs
   - Block bootstrap (block size = average trade duration in bars)
   - Report: MC95DD, MC5DD (tail risk), P(profitable year)

4. **Add PBO (Probability of Backtest Overfitting)**
   - Use CSCV (Combinatorially Symmetric Cross-Validation)
   - Required: PBO < 25%
   - Target: PBO < 15%

5. **Fix trade frequency BEFORE validation**
   - Current: 7 trades in 6 months (INVALID)
   - Required: 200+ trades for statistical significance
   - Semantic collision fix may improve this, but VERIFY

6. **Move paper trading BEFORE final GO decision**
   - Current plan: Paper trading is post-GO action
   - CLAUDE.md requirement: 2 weeks paper trading BEFORE go-live approval
   - This is a sequencing error

**MAJOR GAPS (Should fix):**

7. **Expand WFA to 12 rolling windows**
   - IS: 2 years, OOS: 6 months
   - Include purge gap (max trade duration)
   - Report WFE per window (not just aggregate)

8. **Add regime-stratified validation**
   - Verify edge in: trending, ranging, high-vol, low-vol regimes separately
   - A strategy might pass overall but fail in specific regimes

9. **Add transaction cost sensitivity**
   - Test at 30, 50, 100 pip spread assumptions
   - XAUUSD spread varies significantly by session

10. **Add consistency rule validation (GATE 6)**
    - Verify no single day > 30% of total profit
    - Required for Apex evaluation accounts

### ORACLE Verdict

- [ ] APPROVED - Validation plan sound
- [x] CONDITIONAL - Needs additions listed above
- [ ] BLOCKED - Major gaps

**Current Status: CONDITIONAL APPROVAL**

The plan has correct STRUCTURE but incorrect METHODOLOGY in several critical areas. The 6 blocking issues MUST be addressed before any GO/NO-GO decision can be considered valid.

**Blocking Issues Summary:**
1. No DSR calculation (cannot approve without multiple testing correction)
2. No holdout period (ablation on full dataset = data leakage)
3. MC methodology unspecified (need 5000 runs, block bootstrap)
4. PBO threshold missing (need PBO < 25%)
5. 7 trades is statistically invalid (need 200+)
6. Paper trading sequenced AFTER go-live (must be BEFORE)

**Until these are fixed, ORACLE cannot issue GO for any strategy.**

---

*ORACLE v3.3 - "The past only matters if it predicts the future."*

---

## FORGE Critical Review (Implementation Perspective)

**Reviewed:** 2025-12-23
**Agent:** FORGE-NAUTILUS v1.1
**CLAUDE_MD_VERSION:** 3.10.21
**STATUS:** COMPLETE

### Feasibility Assessment

The planning is **comprehensive but contains critical path issues** that must be fixed before execution:

**CRITICAL PATH ERRORS:**

1. **All File Paths Are Incorrect**
   - Plans reference: `src/indicators/mtf_manager.py`
   - Actual location: `nautilus_gold_scalper/src/indicators/mtf_manager.py`
   - Every file path in the planning documents is missing the `nautilus_gold_scalper/` prefix
   - **Impact:** Commands will fail, grep/read operations will miss targets

2. **Footprint Analyzer Has Test Dependencies**
   - Plan says archive `src/indicators/footprint_analyzer.py`
   - Reality: 3 test files exist for it (`test_footprint_analyzer.py`, `test_footprint_analyzer_signal.py`, `test_footprint_configurable.py`)
   - Archiving source without handling tests = immediate test failures

3. **_archive/ Directory Does Not Exist**
   - Plan references `_archive/legacy/` as destination
   - Directory must be created first - not mentioned in any task

4. **Test File Imports Legacy MTF Manager**
   - `test_indicators/test_mtf_manager.py` imports from `src.indicators.mtf_manager` (line 10)
   - This tests the LEGACY EMA-based implementation, NOT the production SMC-based one
   - Confirms the duplication issue but plan underestimates fixing complexity

### Dependencies Verification

**FILE PATHS VERIFIED (corrected):**

| Planned Path | Actual Path | Exists |
|--------------|-------------|--------|
| `src/indicators/mtf_manager.py` | `nautilus_gold_scalper/src/indicators/mtf_manager.py` | YES (671 lines) |
| `src/signals/mtf_manager.py` | `nautilus_gold_scalper/src/signals/mtf_manager.py` | YES (416 lines) |
| `src/strategies/gold_scalper_strategy.py` | `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py` | YES (2652 lines) |
| `src/signals/confluence_scorer.py` | `nautilus_gold_scalper/src/signals/confluence_scorer.py` | YES (1055 lines) |
| `scripts/.../ea_logic_full.py` | `scripts/backtest/strategies/ea_logic_full.py` | YES |
| `src/indicators/footprint_analyzer.py` | `nautilus_gold_scalper/src/indicators/footprint_analyzer.py` | YES |
| `tests/test_signals/test_mtf_manager.py` | Does not exist | MISSING |

**CONFIGURATION INCONSISTENCIES:**
- `configs/strategy_config_apex_mgc.yaml` line 89: `enable_trend_follow: true`
- `gold_scalper_strategy.py` line 114: `enable_trend_follow: bool = False`
- Same issue for `router_adaptive_ev`: yaml=true, code default=false
- **Plan does not address which is authoritative**

### Missing Implementation Tasks

1. **Pre-Ablation Validation Step**
   - After semantic collision fix, must verify backtest produces sufficient trades (>50) before proceeding to ablation
   - Current observation: 7 trades in 6 months is statistically meaningless

2. **Rollback Checkpoints**
   - Major surgery on 2652-line gold_scalper_strategy.py
   - No git branching strategy documented
   - Recommend: Create branch per major change, checkpoint commits

3. **YAML/Code Configuration Reconciliation**
   - Task to decide which config source is authoritative
   - Task to sync yaml and code defaults

4. **Test Directory Setup for signals/mtf_manager**
   - `tests/test_signals/` directory has no `test_mtf_manager.py`
   - Creating new test file may need `__init__.py` updates

5. **Bracket SL Canceled Investigation**
   - Observed in backtest: FAILSAFE triggers on `bracket_sl_canceled`
   - Root cause not diagnosed
   - If SL brackets consistently fail, all trades abort

6. **Duplicate Task Resolution**
   - Phase 00 MTF-005: "Archive legacy mtf_manager.py"
   - Phase 01 Task 01-03: "Archive indicators/mtf_manager.py"
   - Same task in two phases - which executes?

### Implementation Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Semantic collision fix breaks backtest entirely | HIGH | Run quick validation (1 month) after each change |
| Ablation study produces inconclusive results (insufficient trades) | HIGH | Define minimum trade count threshold (n>50) as gate |
| gold_scalper_strategy.py is 2652-line monolith | MEDIUM | Consider refactoring to smaller modules in Phase 01 |
| Parallel CRUCIBLE agents produce conflicting recommendations | MEDIUM | Add reconciliation step before merging findings |
| Time gates tested only in unit tests, not realistic conditions | MEDIUM | Add DST transition integration test |
| NEWS_TRADER still actively returned by selector (line 375) | LOW | Confirm removal approach (return NONE vs delete enum) |

### Time Estimate Reality Check

| Phase | Planned | Realistic | Notes |
|-------|---------|-----------|-------|
| Day 1-2 (MTF + Semantic) | 13 hours | 18-20 hours | Semantic collision on 2652-line file needs more buffer |
| Day 3-4 (Coverage) | 12-18 hours | 16-22 hours | Going from 52% to 70% is substantial |
| Day 5 (Apex + Temporal) | 4 hours | 4-5 hours | Realistic |
| Day 6-8 (Ablation) | 14 hours | 18-22 hours | 10 full backtests on 32.7M ticks take time |
| Day 9-10 (Documentation) | 6 hours | 6-8 hours | Realistic |
| **Phase 00 Total** | **49 hours (2 weeks)** | **62-77 hours (3 weeks)** | **Add 50% buffer** |
| Phases 01-06 | 4-6 weeks | 6-8 weeks | Dependent on Phase 00 findings |
| **Total to Production** | 6-8 weeks | 9-11 weeks | Conservative estimate |

### Recommendations

1. **[BLOCKING] Fix all file paths** - Add `nautilus_gold_scalper/` prefix to every path in planning docs
2. **[BLOCKING] Add mkdir task** - Create `_archive/legacy/` before any archiving
3. **[BLOCKING] Handle footprint test dependencies** - Archive tests or add deprecation handling
4. **[HIGH] Add pre-ablation validation gate** - "Trades > 50 in 3-month test" before proceeding
5. **[HIGH] Add rollback strategy** - Branch per phase, checkpoint commits after each major change
6. **[HIGH] Reconcile yaml/code configs** - Decide authoritative source, add sync task
7. **[HIGH] Remove duplicate tasks** - Keep MTF archiving in Phase 00 ONLY
8. **[MEDIUM] Add bracket_sl_canceled investigation** - Root cause blocks all trading
9. **[MEDIUM] Increase time estimates by 50%** - Current estimates are optimistic
10. **[MEDIUM] Add Phase 02 contingency** - Define path if SMC fails GO/NO-GO but TrendFollow passes
11. **[LOW] Move ARCHITECTURE.md to DOCS/** - Align with CLAUDE.md output_destinations
12. **[LOW] Fix document numbering** - 02-CRITICAL_ISSUES vs 02-PHASE-01-PLAN is confusing

### FORGE Verdict

- [ ] APPROVED - Ready for execution
- [X] **CONDITIONAL** - Needs minor-to-moderate fixes before execution
- [ ] BLOCKED - Major issues must be resolved

**Blocking Issues (4):**
1. File paths incorrect throughout all planning documents
2. _archive/ directory must be created
3. Footprint analyzer test dependencies not handled
4. Duplicate tasks between Phase 00 and Phase 01

**High Priority Fixes (4):**
1. Pre-ablation trade count validation gate
2. Git branching/rollback strategy
3. YAML/code configuration reconciliation
4. bracket_sl_canceled root cause investigation

**Timeline Adjustment Required:**
- Phase 00: 3 weeks (not 2)
- Total: 9-11 weeks (not 6-8)

---

*FORGE-NAUTILUS v1.1 | Review Complete*

---

## SENTINEL Critical Review (Risk & Apex Compliance)

**Reviewed:** 2025-12-23
**Agent:** SENTINEL v3.2
**CLAUDE_MD_VERSION:** 3.10.21

### Apex Compliance Gaps

**CRITICAL GAPS:**

1. **No Paper Trading Phase Before Production**
   - CLAUDE.md `production_workflow` mandates "Phase 2: Paper Trading - Minimum 2 weeks with live data feed"
   - Phase 09 goes directly from Phase 06 backtest to "production"
   - Post-Phase 06 mentions "Plan paper trading phase" but this is AFTER the GO/NO-GO decision
   - **This violates CLAUDE.md mandate and is a BLOCKING issue**

2. **Missing Broker-Side SL Verification**
   - CLAUDE.md `Broker-Side Safety Requirement` states: "ALL live trades MUST have broker-side (server-side) stop-loss as backup"
   - Phase 09 has ZERO mention of broker-side SL verification
   - Client-side stops can fail (disconnect, crash, latency) - broker SL is last line of defense
   - **This is MANDATORY per SENTINEL spec and is a BLOCKING issue**

3. **HWM Calculation Correctness Not Verified**
   - CLAUDE.md `hwm_trap_warning.price_basis` mandates:
     - LONG positions: use BID price for unrealized exit value
     - SHORT positions: use ASK price for unrealized exit value
     - NEVER use MID price (artificially inflates unrealized profit)
   - COV-002 mentions `test_hwm_trap_scenario()` but details are sparse
   - No explicit test for BID/ASK vs MID price usage
   - **HWM miscalculation = account blown before system reacts**

4. **Circuit Breaker Levels Not Tested**
   - SENTINEL defines 5 circuit breaker levels with graduated response:
     - Level 0 (NORMAL): <3% DD, 100% size
     - Level 1 (WARNING): 3-3.5% DD, 100% size, A+B only, close by 4:30 PM
     - Level 2 (CAUTION): 3.5-4% DD, 50% size, A only, close by 4:00 PM
     - Level 3 (SOFT STOP): 4-4.5% DD, 0% size, no new trades
     - Level 4 (EMERGENCY): >=4.5% DD, close all immediately
   - Phase 09 tests binary (trade/halt) but NOT graduated response
   - Time override (< 1h to close escalates one level) not tested

**MODERATE GAPS:**

5. **Emergency Close Protocol Untested**
   - CLAUDE.md defines detailed Emergency Close Protocol with retry logic:
     - Primary close at 4:55 PM
     - Retry 1-3 at 5-second intervals
     - Escalation to human at 4:55:20 PM if all retries fail
     - Broker-side backstop requirement
   - Phase 09 mentions 4:55 PM emergency close but not retry/escalation logic

6. **HALT Protocol Not Explicit**
   - When DD >= 4.5%, recovery via trading is "LOGICALLY IMPOSSIBLE"
   - Required actions: immediate close, halt trading, alert human, wait for reset
   - Phase 09 doesn't explicitly test this terminal state

7. **Clock Drift Handling Incomplete**
   - CLAUDE.md `timekeeping_contract` requires:
     - NTP sync validation at startup
     - Warning at >1s drift, degraded mode at >5s drift
     - Degraded mode times: 4:20 PM block, 4:45 PM close
   - APEX-002 mentions timezone but not clock drift validation

8. **Position Sizing Multipliers Not Fully Tested**
   - DD multipliers: 1.0/0.85/0.50/0.0 by DD level
   - Time multipliers: 1.0/0.85/0.70/0.50/0.0 by time to close
   - Regime multiplier: 0.0 for RANDOM_WALK (NO TRADE)
   - Phase 05 mentions size multipliers but not graduated enforcement

### DD Tracking Analysis

**Current State:**
- COV-002 plans tests for DD breach - tests are "to create" not existing
- Trailing DD thresholds (3.0%, 3.5%, 4.0%, 4.5%, 5.0%) mentioned but graduated response not tested
- Daily DD thresholds (1.5%, 2.0%, 2.5%, 3.0%) not explicitly tested with specific actions

**Missing Tests:**
1. HWM includes unrealized PnL from ALL open positions (not just newest)
2. HWM uses conservative prices (BID/ASK not MID)
3. HWM never decreases intraday (monotonic increase)
4. HWM resets to realized equity at EOD
5. Daily DD calculated from session start equity
6. Aggregate position DD calculation (if multiple positions open)

**CRITICAL CONCERN:**
Empirical observations show "FAILSAFE" triggers repeatedly with "bracket_sl_canceled" but "DAILY_RESET cleared failsafe latch". Is this intentional? If FAILSAFE can be auto-cleared, it's not a true safety mechanism.

### Time Gate Verification

**Covered (COV-001):**
- 4:30 PM block new trades
- 4:55 PM emergency close
- 4:59 PM hard flatten
- DST transitions (APEX-003)

**NOT Covered:**
- Degraded mode times (4:20 PM block, 4:45 PM close when time source uncertain)
- Clock drift detection and validation
- What happens when emergency close FAILS (retry logic, escalation)
- Broker-side "end of day flatten" as backstop

### Position Sizing Safeguards

**Current Plan:**
- Phase 05 Task 05-01 verifies size multipliers in StrategySelector
- Phase 05 Task 05-02 verifies DD penalty in Router

**Missing:**
1. DD-based position reduction (50% at DD 3.5-4%, 0% at DD >=4%)
2. Time-based position reduction (0% at <30 min to close)
3. Regime-based sizing (RANDOM_WALK = 0 = NO TRADE)
4. Maximum aggregate position limit across all strategies
5. What prevents simultaneous signals from over-allocating?

### Missing Risk Controls

1. **Broker-Side SL as Backup** - Not mentioned anywhere in Phase 09
2. **Multi-Position Aggregation Limit** - What if SMC + TREND_FOLLOW both signal?
3. **Recovery Protocol Verification** - RECOVERY/RETURN/NORMAL phases after DD > 3.5%
4. **Human Escalation Protocol** - Triggers at DD >= 4.0%, DD >= 4.5%, emergency close failure
5. **Network Resilience Testing** - Graceful degradation on disconnect
6. **Data Staleness Detection** - What if MTF data goes stale?
7. **Config Tamper Protection** - Prevent disabling DD protection at runtime

### Failure Mode Analysis

**Failure modes NOT addressed in Phase 09:**

| Scenario | Risk | Current Coverage |
|----------|------|------------------|
| Network disconnect at 4:58 PM | Overnight position = violation | NONE |
| Broker rejects close order | Position stays open | NONE |
| Clock drift > 5 seconds | Time gates fire late | NONE |
| HWM calculated with MID price | False safety, real blow | NONE |
| Simultaneous SMC + TF signals | Over-allocation | NONE |
| Partial fill with wrong SL qty | Under-protected position | NONE |
| bracket_sl always fails | All trades naked | Mentioned but not root-caused |
| MTF data staleness | Wrong confluence signals | NONE |

### Recommendations

**BLOCKING (must fix before any GO decision):**

1. **ADD Phase 6.5: Paper Trading Phase**
   - Minimum 2 weeks with live data feed
   - Real-time HWM and DD tracking
   - Verify time gates fire correctly in live conditions
   - This is MANDATED by CLAUDE.md production_workflow

2. **ADD Broker-Side SL Verification to Phase 00**
   - Confirm broker accepts SL at order level
   - Test client-side failure doesn't leave naked position
   - Document broker-side backstop procedures

3. **EXPAND COV-002 with HWM Calculation Correctness Tests**
   - Test BID price for LONG unrealized PnL
   - Test ASK price for SHORT unrealized PnL
   - Test MID price is NEVER used
   - Test HWM monotonic increase intraday
   - Test HWM EOD reset

4. **ADD Circuit Breaker Level Tests to Phase 00**
   - Test all 5 levels (0-4) with specific DD thresholds
   - Test size reduction at each level
   - Test forced close-by times at each level
   - Test time override (< 1h escalates one level)

**HIGH PRIORITY (fix before production):**

5. **ADD Emergency Close Protocol Tests**
   - Test retry logic at 4:55 PM
   - Test escalation after failed retries
   - Test human alert mechanism
   - Test behavior when all methods fail

6. **ADD Position Sizing Multiplier Tests**
   - DD multipliers: 1.0/0.85/0.50/0.0
   - Time multipliers: 1.0/0.85/0.70/0.50/0.0
   - Regime multipliers (especially RANDOM_WALK = 0.0)

7. **ADD Clock Drift Validation to Phase 00**
   - NTP sync check at startup
   - Degraded mode activation at >5s drift
   - Test degraded mode times (4:20 PM / 4:45 PM)

8. **ADD HALT Protocol Tests**
   - DD >= 4.5% triggers immediate HALT
   - No trades after HALT (not just reduced)
   - Human alert triggered
   - Trading resumes only after explicit reset (not automatic)

9. **ADD Multi-Position Aggregation Tests to Phase 05**
   - Maximum aggregate position limit
   - Aggregate DD calculation
   - Simultaneous signal handling

10. **ADD Recovery Protocol Tests to Phase 00**
    - RECOVERY phase behavior (25% size, A+ only)
    - RETURN phase behavior (50% size, A/B)
    - Phase transition rules
    - Loss in RECOVERY halts for day

11. **CLARIFY Phase 06 GO/NO-GO Criteria**
    - Current criteria are backtest-only (WFE, SQN, PSR, MC95DD)
    - Add Apex compliance criteria:
      - Time gates verified in real-time (paper trading)
      - HWM calculation verified with correct prices
      - Circuit breakers tested at each level
      - SENTINEL formal sign-off obtained

12. **ADD Failure Mode Testing Phase**
    - Network disconnect scenarios
    - Broker rejection scenarios
    - Clock drift scenarios
    - Data staleness scenarios

### SENTINEL Verdict

- [ ] APPROVED - Apex compliant
- [ ] CONDITIONAL - Minor gaps
- [x] BLOCKED - Critical risk gaps

**Blocking Issues:**

1. **No paper trading phase** - Violates CLAUDE.md production_workflow mandate
2. **No broker-side SL verification** - Violates SENTINEL MANDATORY requirement
3. **HWM calculation correctness unverified** - Potential for account blow before system reacts
4. **Circuit breaker graduated response untested** - Binary halt vs graduated protection

**Assessment:**

Phase 09 is well-structured for STRATEGY VALIDATION (backtest performance, code quality) but INSUFFICIENT for PRODUCTION READINESS (operational safety, failure modes). The plan addresses "does the strategy have edge?" but not "what happens when things fail in live trading?"

Before Phase 06 GO/NO-GO can be considered for production:
1. All 4 blocking issues must be resolved
2. Paper trading phase must complete successfully
3. SENTINEL must re-review and issue formal approval

**Recommended Action:**

1. Proceed with Phase 00-06 as planned for strategy validation
2. ADD explicit Phase 6.5 (Paper Trading) and Phase 6.75 (Failure Mode Testing)
3. Rename Phase 06 GO/NO-GO from "production" to "paper trading readiness"
4. Add Phase 07 for final production GO/NO-GO with SENTINEL sign-off

---

*"Trailing DD does not forgive. The clock does not wait. Broker-side SL is the last line of defense."*

**SENTINEL v3.2 - Apex Trading Guardian**

---

## CRUCIBLE Critical Review (Strategy Perspective)

**Reviewed:** 2025-12-23
**Agent:** CRUCIBLE v4.2
**CLAUDE_MD_VERSION:** 3.10.21
**STATUS:** COMPLETE

### Multi-Strategy Philosophy

**Assessment: PREMATURE**

The plan proposes activating 3 strategies (SMC_SCALPER, TREND_FOLLOW, MEAN_REVERT) when the PRIMARY strategy is demonstrably broken:

| Evidence | Implication |
|----------|-------------|
| 7 trades in 6 months | Strategy is over-filtered or broken |
| Only 1 of 9 factors fires | 8 factors contribute NOTHING |
| +$319 on 7 trades | Statistically meaningless (need 200+) |
| 8/9 factors = 0 score | Not a "confluence system" - single factor detector |

**Concern:** Adding more strategies (TrendFollow, MeanRevert) on top of a broken foundation is backwards engineering. The approach should be:
1. Get ONE strategy to produce 200+ trades with validated edge
2. THEN consider diversification with additional strategies

**Recommendation:** Validate TREND_FOLLOW first (simpler, ~200 lines vs ~4,000 for SMC). If TrendFollow produces edge, question whether SMC complexity is justified AT ALL.

---

### SMC Confluence Analysis

**Assessment: FUNDAMENTALLY FLAWED**

The 9-factor confluence system is marketed as sophisticated SMC, but empirical evidence shows:

| Factor | Weight | Observed Score | Status |
|--------|--------|----------------|--------|
| Structure (BOS/CHoCH) | 15pts | 15.0 | ONLY ONE FIRING |
| Regime (Hurst/Entropy) | 10pts | 0.0 | Dead |
| Order Blocks | 15pts | 0.0 | Dead (semantic collision?) |
| FVG | 10pts | 0.0 | Dead (semantic collision?) |
| Liquidity Sweep | 10pts | 0.0 | Dead |
| AMD Cycle | 10pts | 0.0 | Dead |
| Fibonacci | 5pts | 0.0 | Dead |
| MTF Alignment | 15pts | 0.0 | Dead |
| Footprint | 10pts | 0.0 | Dead (no futures data!) |

**Reality Check:** This is NOT a 9-factor system. It is a single-factor structure detector with 8 dead weights adding complexity without value.

**Critical Question NOT Asked:** Do SMC concepts (OB, FVG, sweeps) even apply to XAUUSD M5 scalping?
- SMC was developed by ICT for forex DAILY charts
- Order blocks represent institutional accumulation over hours/days
- On M5, you see HFT and retail flow, NOT "smart money footprints"
- The 8 dead factors may not be bugs - the patterns may not EXIST at this resolution

**Recommendation:** Before fixing "bugs", validate that SMC concepts are applicable to M5 XAUUSD. Run academic literature search on SMC efficacy at sub-hourly timeframes.

---

### Ablation Study Critique

**Assessment: DESIGN FLAWED**

The proposed ablation study has multiple critical issues:

**FLAW 1: Wrong Order of Operations**
- Plan runs ablation DURING Phase 00 (Day 6-8)
- But semantic collision isn't fixed until Day 1-2
- IF semantic collision fix makes OB/FVG fire, ablation results change completely
- **Fix:** Run ablation AFTER semantic fix + diagnostic logging confirms factors fire

**FLAW 2: Insufficient Statistical Power**
- Baseline: ~7 trades in 6 months
- Each ablation config needs 200+ trades for WFE validity
- With ~7 trades per config, t-tests are meaningless
- **Fix:** Run ablation on full 2003-2025 dataset, require 200+ trades minimum

**FLAW 3: No Control Group**
- What if ALL 9 factors are useless?
- Need "random signal + same risk management" baseline
- This isolates edge from signal vs edge from risk management
- **Fix:** Add random entry baseline to ablation configs

**FLAW 4: Wrong Metric Focus**
- Plan focuses on WFE/SQN differences
- Should also track: factor activation rate, signal frequency, false positive rate
- Need to understand WHY factors don't fire
- **Fix:** Add diagnostic logging before ablation

**Corrected Ablation Protocol:**
1. Fix semantic collision (Day 1-2) - already in plan
2. Add diagnostic logging: log every factor's raw score per bar (NEW)
3. Run 1-month diagnostic backtest, analyze factor activation rates (NEW)
4. Only ablate factors that FIRE (don't ablate dead code)
5. Add random entry baseline config (NEW)
6. Require 200+ trades per config for validity

---

### Edge Hypothesis Concerns

**Assessment: NO VALID EVIDENCE OF EDGE**

Current claim: "Positive PnL (+$319) suggests SOME edge exists"

**Statistical Reality:**
- 7 trades is FAR below minimum sample (200)
- With 3 wins / 4 losses, confidence interval is enormous
- +$319 on ~$50k account = 0.6% return in 6 months
- A coin flip with 2:1 RR would produce similar results

**The Dangerous Assumption:**
The entire plan assumes there IS an edge to validate. But with 7 trades, we have:
- No WFE (can't compute on 7 trades)
- No statistical significance
- No regime coverage (all trades clustered in early Jan)
- No OOS validation

**What We Actually Know:**
1. Structure detection works (fires consistently)
2. 8 other factors don't fire (broken or non-existent patterns)
3. Session filtering works (Asian blocked, Overlap allowed)
4. Risk management works (no account blow-up)

**Recommendation:** Do NOT claim edge until we have:
- 200+ trades across multiple market conditions
- WFE >= 0.6 on rolling 1-year windows
- Monte Carlo 95th percentile DD < 4%

---

### Complexity vs Robustness

**Assessment: SEVERELY OVER-ENGINEERED**

| Metric | Current State | Concern |
|--------|---------------|---------|
| Total Code | ~15,000 lines | For 7 trades/6mo? |
| SMC Indicators | ~4,100 lines | 8 of 9 don't work |
| Confluence Scorer | 1,055 lines | Scores mostly 0 |
| StrategySelector | 550 lines | 6 gates for 1 strategy |
| AdaptiveEVRouter | 215 lines | Thompson sampling for what? |
| MTF Manager (2x!) | 1,089 lines | Duplicated, one unused |

**The 15,000-Line System Produces:** 7 trades in 6 months.

**A Simple Alternative:**
- EMA 20/50 crossover + session filter + Apex risk management
- Approximately 200 lines of code
- Would produce 100+ trades in 6 months
- Easy to validate, easy to debug, easy to trust

**Over-Engineering Indicators:**
1. Thompson sampling router for a system with ~1 trade/month
2. 9-factor confluence when only 1 factor fires
3. Hurst exponent regime detection (computationally expensive) returning 0
4. Multi-timeframe alignment not contributing to score

**Recommendation:** Apply Occam's Razor aggressively:
1. Remove/archive all factors that don't fire
2. Simplify to structure + session filter + risk management
3. Validate this simple version FIRST
4. Add complexity ONLY when simple version proves insufficient

---

### Missing Strategic Questions

Questions the plan should ask but doesn't:

**1. Fundamental Validity of SMC on M5**
- Do Order Blocks exist on M5 XAUUSD tick data?
- Is there academic evidence SMC works below H1?
- What timeframe did ICT develop SMC for?

**2. Simple Baseline Comparison**
- What would EMA crossover produce on same data?
- What would random entry + same risk management produce?
- Is SMC complexity justified by outperformance?

**3. Trade Frequency vs Quality Trade-off**
- Is 35 threshold too high or are detectors broken?
- What threshold produces 200+ trades/year?
- Is low frequency intentional or symptomatic of bugs?

**4. Data Relevance**
- Is 2003-2008 XAUUSD relevant to current market?
- Market structure changed dramatically (ETFs, retail access, HFT)
- Should we weight recent data more heavily?

**5. Regime Detection Validity**
- Is Hurst exponent valid on M5 data?
- Computational cost vs benefit?
- Does it predict XAUUSD regime changes?

**6. Exit Strategy**
- If after all fixes, SMC still underperforms simple strategies?
- At what point do we abandon SMC approach?
- What's the sunk cost threshold?

---

### Recommendations

**Priority CRITICAL:**

1. **ADD: Simple Baseline Test (BEFORE Phase 00)**
   - Run EMA 20/50 crossover + session filter + Apex risk management
   - Same data, same timeframe, same capital
   - This is the BAR that SMC must clear to justify its complexity
   - If simple produces similar results, SMC is wasted effort

2. **REORDER Phase 00:**
   - Day 1-2: Fix semantic collision (as planned)
   - Day 3: Run DIAGNOSTIC backtest (log every factor score per bar)
   - Day 4: Analyze factor activation rates (how often does each fire?)
   - Day 5-6: Fix factors that SHOULD fire but don't
   - Day 7-8: Ablation ONLY on factors that fire
   - Day 9-10: Documentation + simple baseline comparison

3. **ADD: Decision Gate After Phase 00 Ablation**
   - IF ablation shows structure alone provides 90%+ of edge:
     - SIMPLIFY to structure + session + risk only
     - Archive 8 unused factors
   - IF all factors combined < simple baseline:
     - STOP SMC development
     - Focus on TrendFollow only

**Priority HIGH:**

4. **SWAP Phase 02 and Phase 03:**
   - Run TrendFollow BEFORE SMC deep audit
   - TrendFollow is simpler, more likely to work
   - If TrendFollow produces edge, question if SMC is needed

5. **DEFER Phase 04 (MeanRevert) Indefinitely:**
   - Gold trends - mean reversion is statistically wrong approach
   - No academic evidence gold mean-reverts at M5
   - Remove from roadmap until proven otherwise

6. **SIMPLIFY Phase 06:**
   - Don't force multi-strategy if only one works
   - Single proven strategy > multiple unproven strategies
   - Router complexity not justified until multiple strategies prove edge

**Priority MEDIUM:**

7. **ADD: Literature Review Task**
   - Search for academic papers on SMC efficacy
   - Focus on: gold, sub-hourly timeframes, retail data
   - If no evidence SMC works on gold M5, reconsider entire approach

8. **ADD: Data Recency Analysis**
   - Compare 2003-2012 results vs 2013-2025 results
   - If old data drives performance, edge may be gone
   - Modern market structure may invalidate historical patterns

---

### CRUCIBLE Verdict

- [ ] APPROVED - Strategy sound
- [X] CONDITIONAL - Needs refinement
- [ ] BLOCKED - Fundamental issues

**Rationale:** The plan correctly identifies symptoms (semantic collision, broken factors, low trades) but does not question the underlying disease (SMC on M5 XAUUSD). Before investing 6-8 weeks:

1. Prove SMC outperforms simple baseline
2. Fix diagnostic order (semantic collision -> logging -> ablation)
3. Add statistical validity requirements (200+ trades)
4. Create exit criteria if SMC approach fails

**Blocking Issues:**

| Issue | Severity | Resolution Required |
|-------|----------|---------------------|
| No simple baseline comparison | CRITICAL | Add Phase -1 or modify Phase 00 |
| Ablation before diagnostic logging | HIGH | Reorder Phase 00 tasks |
| 7 trades claimed as "edge evidence" | HIGH | Require 200+ trades for claims |
| No exit criteria if SMC fails | MEDIUM | Define abandonment threshold |

**Conditional Approval:**
Plan may proceed IF the following are added:
1. Simple baseline test before Phase 00
2. Diagnostic logging before ablation
3. Decision gate after ablation with clear "abandon SMC" criteria
4. Minimum 200 trades requirement for any GO/NO-GO decision

Without these additions, CRUCIBLE recommends **HALT** until strategy approach is validated.

---

*"A 9-factor confluence system where 8 factors score zero is not sophisticated - it's broken. Fix the foundation before adding floors."*

**CRUCIBLE v4.2 - The Backtest Quality Guardian**

---

## ARGUS Research: Multi-Strategy Systems

**Researched:** 2025-12-23
**Agent:** ARGUS v2.4
**CLAUDE_MD_VERSION:** 3.10.21
**STATUS:** COMPLETE

### Executive Summary

**VERDICT: Current multi-strategy architecture (StrategySelector + AdaptiveEVRouter with Thompson sampling) is STATISTICALLY INVALID for the observed trade frequency of 7 trades in 6 months.**

The research confirms and strengthens CRUCIBLE's critique with academic evidence. Thompson sampling requires logarithmic sample sizes to converge - with ~7 trades, the algorithm is permanently in cold-start mode and cannot have learned anything useful. The minimum sample size for any reliable strategy evaluation is 200-300 trades.

---

### Multi-Strategy Diversification

**Evidence Summary:**

Multi-strategy diversification works when:
1. Strategies are **uncorrelated** (correlation coefficient R^2 is low)
2. Sufficient trade volume exists to **measure** correlation
3. Each individual strategy has proven edge independently

Key finding: "Profits add, drawdowns do not" - when one strategy experiences drawdown, another may be reaching new equity highs, reducing overall volatility. [1]

Research on multi-manager implementations shows:
- Reduced realized portfolio risk metrics (maximum drawdown)
- Reduced dispersion in terminal wealth levels
- Diminishing returns after first few additional strategies [1][2]

**Applicability to EA_SCALPER_XAUUSD:**

| Requirement | Current State | Gap |
|-------------|---------------|-----|
| Uncorrelated strategies | SMC_SCALPER + TREND_FOLLOW + MEAN_REVERT | CANNOT MEASURE with 7 trades |
| Sufficient trade volume | 7 trades / 6 months | Need 200+ per strategy |
| Proven individual edge | Only SMC_SCALPER partially tested | 0/3 strategies validated |

**CONCLUSION:** Multi-strategy diversification is NOT applicable until each individual strategy produces 200+ trades with validated edge.

---

### Strategy Selection Algorithms

**Thompson Sampling vs Alternatives:**

| Algorithm | Selection Rule | Strengths | Weaknesses |
|-----------|---------------|-----------|------------|
| **Thompson Sampling** | Sample from posterior, pick max expected reward | Adaptive via Bayes updates; 93% better than random in simulations; optimal for Bernoulli bandits | Requires substantial samples to converge |
| **UCB** | Optimistic mean + confidence bound | Theoretical regret bounds; handles non-stationary rewards | Over-explores suboptimal arms |
| **Epsilon-Greedy** | Greedy (1-epsilon) or random (epsilon) | Easy to implement; low computation | Poor exploration; slower convergence |

**Convergence Requirements:**

Thompson sampling convergence requires sample size scaling logarithmically with time horizon: O(sum_i(ln(T) / Delta_i)) pulls per suboptimal arm. [3][4]

**Cold Start Problem:** In early stages with few or zero samples, all MAB algorithms face high initial uncertainty. Thompson sampling handles this well through posterior sampling, BUT still requires substantial data to learn. [4]

**PAC bounds:** O(K * ln(K/delta) / epsilon^2) total pulls needed for epsilon-optimal arm with probability 1-delta. [5]

**Applicability to EA_SCALPER_XAUUSD:**

| Metric | Requirement | Current State | Assessment |
|--------|-------------|---------------|------------|
| Sample size for convergence | O(ln(T)) minimum | 7 total trades | PERMANENTLY IN COLD-START |
| Pulls per arm for PAC bounds | ~50-100 minimum | ~2-3 trades per strategy | STATISTICALLY MEANINGLESS |
| Reward signal | Stable, identifiable | Insufficient observations | CANNOT LEARN |

**CONCLUSION:** Thompson sampling is an excellent algorithm, but it is COMPLETELY INAPPROPRIATE for our trade frequency. With ~1 trade/month, it would take DECADES for the bandit to converge. **REMOVE AdaptiveEVRouter until trade frequency increases 10x.**

---

### Regime Detection Methods

**Hurst Exponent for Gold/Commodities:**

Evidence supports Hurst exponent as effective for regime detection in gold and commodities:
- Classifies price series as: persistent (H > 0.5, trend), anti-persistent (H <= 0.5, mean reversion), random (H ~ 0.5)
- Rolling windows of 8-16 weeks (commodities) or 100-150 days (gold/equities) work best
- Anti-persistent regimes (H <= 0.45) signal higher mean reversion probability (58-60% within 1 week) [6]

**Hurst vs HMM:**

| Method | Advantages | Disadvantages |
|--------|------------|---------------|
| **Hurst Exponent** | Simple, real-time rolling computation, no state assumptions, long-memory detection | Point estimate, may miss regime transitions |
| **HMM** | Models hidden states explicitly, captures dynamic transitions | More parameters, overfitting risk, computational cost |

Research shows Hurst is simpler and sufficient for most applications. HMM may outperform for multi-state complexity but requires more data. [6]

**Applicability to EA_SCALPER_XAUUSD:**

Current implementation uses Hurst exponent (correct choice), but:
- Regime factor scores 0.0 in backtest observations
- CANNOT VALIDATE regime detection with 7 trades
- Need trades distributed across trending/ranging/volatile periods

**CONCLUSION:** Hurst exponent is appropriate for regime detection in gold. However, the current implementation appears broken (scores 0.0). Fix first, then validate with 200+ trades across multiple regimes.

---

### Institutional Portfolio Construction

**How Hedge Funds Combine Strategies:**

1. **Dynamic Capital Allocation:** Shift capital to strategies with superior risk-return profiles using Sharpe ratio, VaR, alpha/beta tracking [7]

2. **Orthogonality/Low-Correlation Blending:** Strategies selected for minimal overlap. Aggregating orthogonal substrategies boosts composite Sharpe even if individual Sharpes are modest [8]

3. **Multi-Manager (Pod) Structure:** Decentralized specialist teams handle sizing/timing; central oversight for allocation/rebalancing [7]

4. **Systematic Multi-Strategy:** Integrated platform with unified research; models trading costs, liquidity, signal orthogonality ex ante [8]

**Key Requirements:**

| Element | Institutional Standard | EA_SCALPER_XAUUSD State |
|---------|----------------------|-------------------------|
| Track record per strategy | 100+ trades minimum | 7 trades total |
| Correlation measurement | Empirical R^2 matrix | IMPOSSIBLE to compute |
| Risk budgeting | VaR/CVaR per strategy | Insufficient data |
| Performance attribution | Factor analysis | Single factor fires |

**CONCLUSION:** Institutional approaches require SUBSTANTIAL track records to implement. Our current 7 trades is approximately 1/20th of the minimum needed even for initial evaluation.

---

### Complexity vs Performance Tradeoff

**Evidence Strongly Favors Simplicity:**

Key findings from research on trading system complexity:

1. **Overfitting is the central mechanism** why complexity fails. Systems with many parameters become tailored to historical conditions rather than generalizable patterns [9]

2. **Stable parameters** that perform consistently across a range of values are preferred over single best-performing combinations [9]

3. **Systems with fewer trades are MORE vulnerable** to overfitting - each additional rule requires substantially more data for reliable optimization [9]

4. **Case study (Harry):** Trader optimized with 360,000 parameter combinations, achieved excellent backtest results, but system failed in real-time because it was backward-looking [9]

**Best Practices:**
- One-parameter-at-a-time optimization (not brute-force)
- Walk-forward testing across multiple periods
- Monte Carlo optimization with different subsets [9]

**The Complexity Trap:**

| Metric | Current SMC System | Simple Alternative (EMA crossover) |
|--------|-------------------|-----------------------------------|
| Lines of code | ~15,000 | ~200 |
| Factors/Parameters | 9 factors (8 dead) | 2-3 parameters |
| Trades in 6 months | 7 | Expected 100+ |
| Validation difficulty | HIGH (need 2000+ trades) | LOW (need 200 trades) |

**CONCLUSION:** Strong evidence that simpler systems outperform complex ones. The current 9-factor system (where 8 factors score 0) is the WORST of both worlds: complexity overhead without complexity benefit. **SIMPLIFY AGGRESSIVELY.**

---

### Adaptive/ML Systems for Strategy Selection

**Evidence Summary:**

ML for strategy selection CAN work but comes with caveats:

**Positive Evidence:**
- Random Forest and SGD excel in Bitcoin trading (highest Sharpe, PNL) [10]
- SVM on moving average changes: 90.31% accuracy, 29.57% annualized returns [10]
- XGBoost performs well on longer horizons [10]

**Negative Evidence:**
- High overfitting risks, parameter sensitivity
- Modest risk-adjusted outperformance in many studies
- Conflicting results across asset classes
- ARIMA vs Prophet inconsistent in crypto [10]

**Minimum Data Requirements:**
- 1,000+ samples for basic ML training
- Rolling windows for temporal validation
- Feature engineering and regularization required

**Applicability to EA_SCALPER_XAUUSD:**

| Requirement | Current State | Assessment |
|-------------|---------------|------------|
| Training samples | 7 trades | 0.7% of minimum |
| Validation samples | 0 | IMPOSSIBLE |
| Feature diversity | 8 factors score 0 | NO SIGNAL VARIETY |

**CONCLUSION:** ML for strategy selection is a BAD IDEA at current trade frequency. The system would be "learning" from noise. **DEFER any ML/adaptive approach until trade frequency reaches 1000+ per year.**

---

### Sample Size Crisis

**Minimum Trades for Reliable Evaluation:**

| Purpose | Minimum Trades | EA_SCALPER_XAUUSD | Gap |
|---------|---------------|-------------------|-----|
| Basic evaluation | 200-300 | 7 | 28-42x fewer |
| Statistical significance | 1,000+ | 7 | 143x fewer |
| MAB convergence | O(ln(T)) per arm | ~2 per arm | CANNOT CONVERGE |
| Walk-forward validation | 50+ per window | 7 total | Cannot do 1 window |
| Monte Carlo confidence | 100+ per bootstrap | 7 total | INVALID |

**Critical Insight:** The project name is "EA_SCALPER" - scalping implies HIGH frequency (many trades per day). The observed 7 trades in 6 months is NOT scalping. This is LOW-FREQUENCY swing trading at best, or a BROKEN SYSTEM at worst.

**Expected Scalping Volume:**
- Typical gold scalping: 5-20 trades per day during active sessions
- London-NY overlap: 4+ hours of tradeable conditions daily
- Expected 6-month volume: 500-2000+ trades

**CONCLUSION:** The 7-trade observation suggests either:
1. Strategy gates are TOO RESTRICTIVE (threshold 35 too high)
2. 8 dead factors are preventing valid signals
3. The system is fundamentally broken

---

### Key Recommendations for Our Plan

Based on triangulated evidence (academic + code + empirical), ARGUS recommends:

**BLOCKING (Must Address):**

1. **REMOVE AdaptiveEVRouter (Thompson Sampling)**
   - Rationale: Cannot converge with current trade frequency
   - Action: Archive, replace with static allocation or simple heuristics
   - Recovery: Re-enable when trade frequency exceeds 200/year per strategy

2. **SIMPLIFY to Single Strategy First**
   - Rationale: Multi-strategy requires validated individual edges
   - Action: Focus on getting ONE strategy (SMC or TrendFollow) to 200+ trades
   - Only after one works, consider adding second strategy

3. **FIX Trade Frequency Crisis**
   - Current: ~14 trades/year
   - Minimum: 200 trades/year for basic validation
   - Required action: Lower threshold (35->25?) OR fix dead factors

**HIGH PRIORITY:**

4. **Preserve Hurst Regime Detection (but fix it)**
   - Evidence supports Hurst for gold regime detection
   - Currently scoring 0 - investigate root cause
   - Use for FILTERING (trade/no-trade) not SWITCHING strategies

5. **Add Simple Baseline Comparison**
   - Test EMA crossover + session filter + same risk management
   - This is the BAR that any complex system must clear
   - If simple baseline wins, abandon SMC complexity

6. **Apply Occam's Razor to Confluence Scoring**
   - Remove all factors that score 0 permanently
   - Target: 2-3 factors maximum
   - Fewer parameters = less overfitting = more robust

**MEDIUM PRIORITY:**

7. **Defer Mean Revert Strategy**
   - Gold trends, not mean-reverts at M5
   - No academic evidence for gold mean reversion scalping
   - Archive until proven otherwise

8. **Remove StrategySelector 6-Gate Architecture**
   - Over-engineered for current single-strategy reality
   - Replace with simple regime filter + session gate
   - Reintroduce complexity only when multiple strategies proven

---

### Architectural Decision Matrix

Based on research, here is the recommended approach by trade frequency:

| Trade Frequency | Architecture | Regime Detection | Strategy Selection |
|-----------------|--------------|------------------|-------------------|
| < 50/year (CURRENT) | Single strategy | None (insufficient data) | None (single option) |
| 50-200/year | Single strategy | Simple Hurst filter | None |
| 200-500/year | 2 strategies | Hurst + session | Static allocation (50/50) |
| 500-1000/year | 2-3 strategies | Hurst validated | Simple heuristic switching |
| 1000+/year | Multi-strategy | Full regime detection | Consider Thompson sampling |

**CURRENT STATE: < 50/year**
**RECOMMENDED ARCHITECTURE: Single strategy with session filter only**

---

### ARGUS Verdict

**Confidence Level: HIGH**

Evidence triangulation:
- Academic (5+ peer-reviewed sources on MAB, complexity, diversification)
- Practitioner (hedge fund approaches, trading system optimization)
- Empirical (observed 7 trades, 8 dead factors)

**Verdict: Current architecture is STATISTICALLY INVALID for observed trade frequency.**

The StrategySelector (6 gates) + AdaptiveEVRouter (Thompson sampling) structure would be appropriate for a system producing 1000+ trades/year. For 7 trades in 6 months, this is:
- ~100x over-engineered
- Thompson sampling in permanent cold-start
- Multi-strategy diversification impossible to measure

**Handoff Recommendation:**

| Next Agent | Action |
|------------|--------|
| FORGE | Archive AdaptiveEVRouter, simplify StrategySelector to regime filter |
| CRUCIBLE | Redesign for single-strategy simplicity |
| ORACLE | Rerun backtest with lower threshold (25) to achieve 200+ trades |
| SENTINEL | Validate simplified risk controls still meet Apex requirements |

---

### Sources

1. KJ Trading Systems - Algorithmic Trading Diversification: https://kjtradingsystems.com/algorithmic-trading-diversiifcation.html
2. Think New Found - Is Multi-Manager Diversification Worth It?: https://blog.thinknewfound.com/2019/01/is-multi-manager-diversification-worth-it/
3. Stanford - Tutorial on Thompson Sampling: https://web.stanford.edu/~bvr/pubs/TS_Tutorial.pdf
4. Oxford Statistics - Advanced Financial Learning Lecture 15: https://www.stats.ox.ac.uk/~rebeschi/teaching/AFoL/22/material/lecture15.pdf
5. JMLR - PAC Bounds for Multi-Armed Bandits: https://www.jmlr.org/papers/volume5/mannor04b/mannor04b.pdf
6. PMC - Hurst Exponent Regime Detection: https://pmc.ncbi.nlm.nih.gov/articles/PMC10137866/
7. Daloopa - Multi-Strategy Hedge Funds Overview: https://daloopa.com/blog/analyst-best-practices/multi-strategy-hedge-funds-an-overview
8. Acadian Asset Management - Systematic Multi-Strategy Hedge Fund: https://www.acadian-asset.com/-/media/files/thematic-research-paper-pdfs/acadian---the-systematic-multi-strategy-hedge-fund----a-better-alternative.pdf
9. Enlightened Stock Trading - Trading System Optimization: https://enlightenedstocktrading.com/trading-system-optimization/
10. arXiv - Machine Learning for Trading Strategy Selection: https://arxiv.org/html/2407.18334v1
11. IJCAI - Thompson Sampling for Portfolio Blending: https://www.ijcai.org/Proceedings/16/Papers/283.pdf
12. InstaForex - Low Frequency Trading: https://www.instaforex.com/knowledge_base/354-low-frequency-trading
13. DailyForex - Gold Scalping Strategy: https://www.dailyforex.com/forex-articles/gold-scalping-strategy/216881

---

*ARGUS v2.4 - "Evidence-based decisions or no decisions at all."*

---

## ARGUS Research: SMC & Gold Trading Strategies

**Researched:** 2025-12-23
**Agent:** ARGUS v2.4
**CLAUDE_MD_VERSION:** 3.10.21
**STATUS:** COMPLETE

### Executive Summary

**VERDICT: Our 9-factor SMC approach is OVER-ENGINEERED and likely OVERFITTED.**

The research triangulates evidence from academic papers, prop firm strategies, and trading research to validate that:
1. 9 confluence factors is 2-4x more than recommended
2. SMC on M5 CAN work but requires proper HTF confirmation
3. Gold MOMENTUM strategies significantly outperform mean reversion
4. Successful prop firm traders use 2-3 simple indicators
5. Our current approach violates multiple best practices

---

### SMC on M5 Timeframe

**Finding: SMC CAN work on M5 but REQUIRES multi-timeframe confirmation from H1/M15.**

| Trading Style | Structure Timeframe | Entry Timeframe | Key Characteristics |
|---------------|---------------------|-----------------|---------------------|
| Scalping | H1 or M15 | M5 to M1 | High-frequency trades in kill zones; tight stops |
| Day Trading | H4 or H1 | M15 to M5 | 2-5 trades/day; 10-15 pip stops |
| Swing Trading | Daily or H4 | H1 to M15 | Multi-day holds; larger targets |

**Critical Insights:**
- M5 entries work when aligned with HTF liquidity sweeps or FVGs
- Trading M5 in isolation risks false signals from noise
- Optimal sessions: London-NY overlap (7:30-10:00 AM ET) for volatility
- 5-minute order blocks are "well-respected" and reduce over-refinement risks

**Our Gap:** The strategy has MTF alignment code but it scores 0.0 - the semantic collision prevents HTF confirmation from working.

**Sources:** [1] ACY Market News, [2] ePlanetBrokers SMC Training, [3] TradingStrategyGuides

---

### Gold-Specific Best Practices

**Finding: MOMENTUM/TREND-FOLLOWING significantly outperforms mean reversion for XAUUSD.**

**Academic Evidence (arxiv.org/abs/2511.08571 - "Forecast-to-Fill"):**
- Strategy: Simple trend + momentum signals on gold futures
- Result: **Sharpe ratio 2.88**, annualized return ~43% (2015-2025 OOS)
- Approach: Volatility-targeted, friction-aware positions

**Comparative Study (bcpublication.org):**
| Strategy | Gold Performance | Notes |
|----------|------------------|-------|
| Momentum | **BETTER** | Higher profits with volatile assets |
| Mean Reversion | POOR | Almost negative strategy returns |

**Reason:** Gold exhibits positive time series momentum. Mean reversion strategies fail because gold trends rather than reverting.

**Best Performing Gold Strategies (per research):**
1. **London Breakout**: Enter on Asian session range breakout at London open (07:00-09:00 UTC)
2. **4H Trend Continuation**: EMA 50/200 on 4H, pullback entries to 50 EMA or Fib levels
3. **Session-Based Scalping**: NY session focus, 5-15 pips per trade, 8-12% monthly

**Our Gap:** No clear momentum component. Our SMC approach is detection-heavy but lacks clear trend confirmation.

**Sources:** [14] arxiv.org/abs/2511.08571, [15] SSRN 2652637, [16] bcpublication.org/BM/article/3890

---

### Optimal Confluence Factor Count

**Finding: 2-4 independent factors is the sweet spot. 5+ leads to analysis paralysis and overfitting.**

| Confluence Count | Win Rate (approx) | Risks |
|------------------|-------------------|-------|
| 1-2 | ~40% | Lower confirmation |
| **3-4** | **~70%** | **Sweet spot - balanced** |
| 5+ | ~90% (theoretical) | Analysis paralysis, overfitting, rare setups |

**Academic/Practitioner Consensus:**
- Multiple indicators often **correlate**, leading to redundant signals
- Simple strategies (1-2 indicators) **outperform complex ones in backtests** due to lower overfitting
- Over-reliance on 5+ factors dilutes focus and increases false positives

**Critical Warning:**
> "A 2014 study revealed that **44% of published trading strategies failed to replicate their results on new data.**"

**Our Problem:**
- We have 9 factors (2-4x recommended maximum)
- Only 1 factor fires (structure) - the others add complexity without value
- This is NOT a confluence system - it's a single-factor detector with 8 dead weights

**Recommendation:** Reduce to 3-4 INDEPENDENT factors:
1. Structure (BOS/CHoCH) - KEEP (working)
2. Order Blocks - KEEP (fix semantic collision)
3. Fair Value Gap - KEEP (fix semantic collision)
4. Session Filter - KEEP (working)
5. Regime Filter - ADD (volatility-based)

**Archive:** MTF alignment (redundant with session), AMD, Fib, Footprint (no data), Sweep (low activation)

**Sources:** [17] ColibritTrader, [18] LiteFinance, [19] TimothySykes

---

### Simple vs Complex Performance

**Finding: Evidence is nuanced but SIMPLE is generally MORE ROBUST.**

**Arguments FOR Simplicity:**
- Simple strategies are more robust, easier to implement
- Less prone to overfitting (curve-fitting historical data)
- Align with Occam's Razor principle
- "Less is more" enables complementary strategies

**Arguments FOR Complexity:**
- Complex strategies can yield higher Sharpe ratios
- Lower market correlation for diversification
- True alpha beyond basic beta

**Critical Evidence:**
> "AQR Capital Management documented a moving average strategy with **Sharpe ratio of 1.2 during backtesting that dropped to -0.2** when applied to new data."

This demonstrates the overfitting risk with complex strategies.

**Validation Gold Standard: Walk-Forward Optimization**
- Optimize on rolling in-sample window
- Test on following out-of-sample segment
- Repeat across all available data
- Smooth profit curve = reliable; spikes = unstable

**Our Status:**
- 15,000+ lines of code for 7 trades in 6 months
- Massive complexity with no validated edge
- A simple EMA crossover + session filter would likely produce 100+ trades

**Sources:** [20] QuantifiedStrategies, [21] QuantStart, [22] SCIRP

---

### Order Flow vs Price Action for Gold

**Finding: No definitive winner. Best approach is COMBINING both methods.**

| Approach | Pros | Cons |
|----------|------|------|
| Order Flow | Early signal identification, precision tracking | Requires advanced tools, skilled interpretation |
| Price Action | Works with any chart, widely understood | Lagging, subjective interpretation |
| **Combined** | Confirmation strength, reduced false signals | More complexity |

**Gold-Specific Context:**
- Order flow works well in futures markets due to centralized order books
- Gold CFD data may not provide true order flow visibility
- Our footprint analyzer scores 0.0 because we don't have futures data

**Recommendation:** Focus on price action (structure, OB, FVG) for our CFD-based approach. Order flow is a nice-to-have if we move to futures.

**Sources:** [23] Bookmap, [24] Optimusfutures

---

### Institutional Gold Trading

**Finding: Institutions use SIMPLE, SESSION-SPECIFIC strategies with strict risk management.**

**How Prop Firms Trade Gold (FTMO Case Studies):**

| Trader | Strategy | Results | Key Elements |
|--------|----------|---------|--------------|
| Choon Chiat | Scalping | $30K+ profit, very high win rate | 30M top-down, 5M entries, BB + RSI, NY session |
| Swing Specialist | Swing Trading | +$30,007 (+15%), 61% win rate | XAUUSD longs only, trailing SL on higher lows |
| Multi-TF | Trend Following | Passed 200K challenge | Daily/4H for liquidity, 15M for entries, 4:1-5:1 R:R |

**Common Patterns Among Successful Traders:**
1. **Specialization**: Focus on XAUUSD exclusively
2. **Multi-timeframe**: HTF for bias, LTF for entry
3. **Simple indicators**: EMA + RSI or Bollinger Bands (2-3 max)
4. **Session-specific**: NY session for volatility
5. **Strict risk management**: Trailing stops, fixed pip targets
6. **High R:R ratios**: 2:1 minimum, often 4:1 or 5:1

**FVG + EMA Strategy (FTMO Recommended):**
- 20/50 period EMAs for trend direction
- Enter on FVG pullbacks during trend
- Target 2:1 R:R minimum

**Our Gap:**
- Too many indicators (9 vs 2-3)
- No clear R:R targeting
- Not session-optimized (we filter but don't optimize FOR sessions)

**Sources:** [25] FTMO Blog - Top Traders, [26] FTMO Blog - 61% Win Rate, [27] FTMO Blog - Choon Chiat

---

### Gold-USD Correlation (Additional Finding)

**Finding: Gold has STRONG INVERSE correlation with USD (DXY). Can be used as macro filter.**

| Scenario | DXY Action | Expected XAUUSD | Strategy |
|----------|------------|-----------------|----------|
| DXY Rising (Strong USD) | Breakout up | Sell-off | Short XAUUSD |
| DXY Falling (Weak USD) | Breakout down | Rally | Long XAUUSD |
| Correlation Breakdown | Volatile | Independent move | Wait for re-alignment |

**Application:** Use DXY direction as a confirmation filter. Long gold signals only when DXY is weak/falling.

**Sources:** [28] PhillipNova, [29] ForexGDP, [30] CME Group

---

### Regime Detection Enhancement

**Finding: Volatility-based regime filtering SIGNIFICANTLY reduces drawdown.**

**Evidence:**
> "Volatility filter reduced maximum daily drawdown from **~56% to ~24%** while maintaining strategy returns."

**Methods for Regime Detection:**
1. **Technical**: ADX, RSI, MACD, moving averages
2. **Structural**: CHoCH (Change of Character), BoS (Break of Structure)
3. **Statistical**: Hidden Markov Models (HMM), Hurst exponent

**Adaptive Multi-Strategy Approach:**
- Trend-following strategies for trending regimes
- Mean-reversion for ranging markets (but AVOID for gold!)
- Breakout strategies during regime shifts
- Volatility-based models for fluctuating markets

**Our Status:** We have Hurst/entropy regime detection but it scores 0.0. Either broken or misconfigured.

**Recommendation:** Simplify regime filter to ADX-based trending detection. More robust, less computationally expensive.

**Sources:** [31] LuxAlgo, [32] QuantStart HMM, [33] QuantInsti

---

### Key Recommendations for SMC Simplification

**CRITICAL CHANGES (Must Implement):**

1. **REDUCE CONFLUENCE FACTORS FROM 9 TO 3-4**
   - Keep: Structure, Order Blocks, FVG, Session Filter
   - Add: Volatility-based regime filter (ADX)
   - Archive: MTF alignment, AMD, Fib, Footprint, Sweep

2. **FIX SEMANTIC COLLISION FIRST**
   - OB/FVG scoring 0.0 may be the root cause
   - After fix, reassess if more factors should stay

3. **FOCUS ON MOMENTUM, NOT MEAN REVERSION**
   - Academic evidence: Gold trends, doesn't mean-revert
   - Remove MEAN_REVERT from strategy options

4. **ADD SIMPLE BASELINE TEST**
   - EMA 20/50 crossover + session filter + Apex risk
   - If this outperforms current SMC, question entire approach

**HIGH PRIORITY CHANGES:**

5. **OPTIMIZE FOR LONDON-NY OVERLAP**
   - Best liquidity and volatility
   - 7:30-10:00 AM ET for scalping

6. **USE WALK-FORWARD VALIDATION**
   - 12 rolling windows (not 3)
   - Purged cross-validation to prevent leakage

7. **TARGET REALISTIC SHARPE**
   - Sharpe 1.5-2.5 is excellent
   - Sharpe >3.0 suggests overfitting

8. **CONSIDER DXY FILTER**
   - Long gold only when DXY weak/falling
   - Additional macro-level confirmation

---

### SMC Research Sources

14. arXiv - Forecast-to-Fill Gold Futures (2511.08571): https://arxiv.org/abs/2511.08571
15. SSRN - Technical Analysis Gold/Silver (2652637): https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2652637
16. BCPublication - Momentum vs Mean Reversion: https://bcpublication.org/index.php/BM/article/download/3890/3791
17. ColibritTrader - Confluence Trading: https://www.colibritrader.com/confluence-in-trading/
18. LiteFinance - Confluence Forex: https://www.litefinance.org/blog/for-beginners/what-is-forex/confluence-forex-trading/
19. TimothySykes - Confluence: https://www.timothysykes.com/blog/confluence-in-trading/
20. QuantifiedStrategies - Simple vs Complex: https://www.quantifiedstrategies.com/simple-vs-complex-trading-strategies/
21. QuantStart - Simple vs Advanced: https://www.quantstart.com/articles/simple-versus-advanced-systematic-trading-strategies-which-is-better/
22. SCIRP - Complexity Research: https://www.scirp.org/journal/paperinformation?paperid=136964
23. Bookmap - Order Flow vs TA: https://bookmap.com/blog/technical-analysis-vs-order-flow
24. OptimusFutures - Order Flow Trading: https://optimusfutures.com/blog/order-flow-trading/
25. FTMO - Choon Chiat Scalping: https://ftmo.com/en/blog/top-ftmo-trader-choon-chiat-scalping-strategy-with-very-high-win-rate/
26. FTMO - 61% Win Rate Gold: https://ftmo.com/en/blog/mastering-one-market-win-rate-61-on-gold-delivered-a-30007-profit/
27. FTMO - Trading Week Ahead Gold: https://ftmo.com/en/blog/trading-week-ahead-is-gold-xauusd-setting-up-for-a-new-all-time-high/
28. PhillipNova - DXY Gold Correlation: https://www.phillipnova.com.sg/educational_articles/why-gold-moves-when-the-dollar-moves/
29. ForexGDP - Gold DXY Analysis: https://www.forexgdp.com/analysis/xauusd/gold-dxy-correlation/
30. CME Group - Gold and USD: https://www.cmegroup.com/openmarkets/metals/2025/Gold-and-the-US-Dollar-An-Evolving-Relationship.html
31. LuxAlgo - Market Regimes: https://www.luxalgo.com/blog/market-regimes-explained-build-winning-trading-strategies/
32. QuantStart - HMM Regime Detection: https://www.quantstart.com/articles/market-regime-detection-using-hidden-markov-models-in-qstrader/
33. QuantInsti - Regime Adaptive Trading: https://blog.quantinsti.com/regime-adaptive-trading-python/

---

### ARGUS Verdict (SMC & Gold Research)

| Aspect | Current State | Recommendation | Confidence |
|--------|---------------|----------------|------------|
| Confluence Factors | 9 (8 broken) | Reduce to 3-4 | **HIGH** |
| SMC on M5 | Possible with HTF | Fix semantic collision | **HIGH** |
| Mean Reversion | Planned | **REMOVE** - Gold trends | **HIGH** |
| Strategy Complexity | ~15K lines | **SIMPLIFY** drastically | **HIGH** |
| Session Optimization | Filtering only | Optimize FOR sessions | **MEDIUM** |
| Regime Filter | Hurst (broken) | Switch to ADX | **MEDIUM** |
| DXY Correlation | Not used | Add as macro filter | **MEDIUM** |

**Combined Verdict (Multi-Strategy + SMC Research):**

The evidence is overwhelming: our current approach is fundamentally over-engineered for the observed trade frequency. The path forward requires:

1. **First**: Fix semantic collision and dead factors
2. **Second**: Validate with simple baseline (EMA crossover)
3. **Third**: Simplify to 3-4 factors if SMC outperforms baseline
4. **Fourth**: Increase trade frequency to 200+/year before ANY advanced architecture
5. **Last**: Only then consider multi-strategy, regime detection, or adaptive selection

**Handoff: ARGUS -> CRUCIBLE (strategy simplification design) -> FORGE (implementation)**

---

*ARGUS v2.4 - "Evidence over intuition. Triangulation over assumption."*
