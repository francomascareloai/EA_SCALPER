# ROADMAP v2: Strategy Activation & Validation (REVISED)

## Metadata

| Field | Value |
|-------|-------|
| Version | 2.0 |
| Created | 2025-12-23 |
| Supersedes | 01-ROADMAP.md (v1.3) |
| Agent Reviews Incorporated | FORGE, CRUCIBLE, ORACLE, SENTINEL, ARGUS (x2) |
| CLAUDE_MD_VERSION | 3.10.21 |

## Changelog

- **v2.0 (2025-12-23)**: Complete revision incorporating all 7 agent reviews
  - Added Phase -1 (Baseline Validation) per CRUCIBLE
  - Added Phase 07 (Paper Trading) per SENTINEL - MANDATORY
  - Added Phase 08 (Production Readiness) per SENTINEL
  - REMOVED Phase 04 (Mean Revert) per ARGUS research
  - MERGED Phase 01 into Phase 02
  - Enhanced Phase 06 with DSR, PBO, CPCV, holdout per ORACLE
  - Fixed all file paths per FORGE
  - Reduced confluence factors from 9 to 3-4 per ARGUS
  - Archived AdaptiveEVRouter per ARGUS (insufficient trade frequency)
  - Timeline adjusted from 6-8 weeks to 10-12 weeks (realistic + mandatory phases)

---

## Executive Summary

### What Changed

| Aspect | v1.0 | v2.0 | Rationale |
|--------|------|------|-----------|
| **Phases** | 7 (00-06) | 9 (-1 to 08) | Added baseline, paper trading, production readiness |
| **Mean Revert** | Phase 04 planned | REMOVED | Gold trends, doesn't mean-revert (ARGUS research) |
| **Confluence Factors** | 9 factors | 3-4 factors | 8 factors score 0, over-engineered (CRUCIBLE/ARGUS) |
| **Router** | AdaptiveEVRouter active | ARCHIVED | Thompson sampling invalid with 7 trades (ARGUS) |
| **Validation** | WFE, SQN, PSR, MC95DD | +DSR, +PBO, +CPCV, +holdout | ORACLE blocking issues |
| **Paper Trading** | After GO decision | BEFORE GO decision | SENTINEL: CLAUDE.md mandate |
| **Timeline** | 6-8 weeks | 10-12 weeks | Realistic + mandatory phases |
| **File Paths** | Incorrect | Corrected | FORGE: add nautilus_gold_scalper/ prefix |

### Why This Revision

Seven agent reviews identified critical gaps in v1.0:

1. **FORGE**: All file paths wrong, _archive/ doesn't exist, duplicate tasks
2. **CRUCIBLE**: 8 of 9 factors dead, need simple baseline, over-engineered
3. **ORACLE**: No DSR, no holdout, MC unspecified, PBO missing
4. **SENTINEL**: No paper trading before GO, no broker SL verification
5. **ARGUS Research 1**: Remove AdaptiveEVRouter, simplify architecture
6. **ARGUS Research 2**: Reduce to 3-4 factors, remove MEAN_REVERT

**Bottom Line**: v1.0 was strategy-focused but production-blind. v2.0 adds the mandatory operational safety phases and fixes statistical rigor gaps.

---

## Decision Required (Blocks Phase 00 Start)

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

---

## Phase Overview

| Phase | Focus | Priority | Status | Duration | Key Deliverables |
|-------|-------|----------|--------|----------|------------------|
| **-1** | **Baseline Validation** | **P0 - BLOCKER** | Not started | 2 days | EMA baseline metrics |
| **00** | **Pre-Activation Sprint** | **P0 - BLOCKER** | Not started | 3 weeks | Fixed foundations |
| **02** | **SMC Audit + Cleanup** | **P0 - CRITICAL** | Blocked by 00 | 2 weeks | Validated SMC |
| **03** | **TrendFollow Activation** | **P0 - CRITICAL** | Blocked by 02 | 1 week | Validated TrendFollow |
| **05** | **Simplified Framework** | **P1 - HIGH** | Blocked by 03 | 3 days | Regime filter only |
| **06** | **Enhanced Validation** | **P0 - CRITICAL** | Blocked by 05 | 2 weeks | DSR, PBO, CPCV, holdout |
| **07** | **Paper Trading** | **P0 - MANDATORY** | Blocked by 06 | 2 weeks | Live data verification |
| **08** | **Production Readiness** | **P0 - MANDATORY** | Blocked by 07 | 1 week | SENTINEL sign-off |

**Removed:** Phase 01 (merged into 02), Phase 04 (Mean Revert - gold doesn't mean-revert)

**Total Timeline:** 10-12 weeks to production (vs 6-8 weeks in v1.0)

---

## Phase -1: Baseline Validation (NEW)

**Objective:** Establish simple strategy baseline that SMC must outperform to justify its complexity.

**Rationale (CRUCIBLE):** "A 15,000-line system that produces 7 trades in 6 months is not sophisticated - it's broken. Before spending weeks on SMC, prove SMC beats a simple baseline."

### Tasks

| ID | Task | Time | Agent |
|----|------|------|-------|
| BL-001 | Create EMA 20/50 crossover strategy | 2 hrs | FORGE |
| BL-002 | Add session filter (block Asian, allow London/NY/Overlap) | 1 hr | FORGE |
| BL-003 | Apply same Apex risk management (DD limits, time gates) | 1 hr | FORGE |
| BL-004 | Run backtest on 2003-2019 (training set) | 2 hrs | ORACLE |
| BL-005 | Record baseline metrics (WFE, SQN, Sharpe, MaxDD, trade count) | 1 hr | ORACLE |

### GO/NO-GO Criteria

| Criterion | Target | Required |
|-----------|--------|----------|
| Trades generated | >= 200 | YES |
| Baseline metrics recorded | Complete | YES |
| Sharpe ratio | > 0 | YES |

**Decision Gate:**
- IF current SMC (post-fixes) cannot beat EMA baseline -> STOP, fundamental strategy review needed
- IF SMC beats EMA -> Proceed to Phase 00

---

## Phase 00: Pre-Activation Sprint (REVISED)

**Objective:** Fix critical blockers discovered during deep analysis AND incorporate all agent review feedback.

**Duration:** 3 weeks (increased from 2 weeks per FORGE recommendation)

### Week 1: Critical Blockers (Days 1-5)

#### Day 0: Setup (BLOCKING - Do First)

| ID | Task | Time | Notes |
|----|------|------|-------|
| SETUP-001 | Create `nautilus_gold_scalper/_archive/legacy/` directory | 15 min | FORGE: _archive/ doesn't exist |
| SETUP-002 | Create git branch `phase-00-sprint` | 15 min | Rollback strategy |
| SETUP-003 | Document config authority decision (yaml vs code) | 30 min | FORGE: reconcile conflicts |

#### Days 1-2: MTF & Semantic Collision (13 hours)

**MTF Manager Duplication (6 hours)**

| ID | Task | Time | File (Corrected Path) |
|----|------|------|----------------------|
| MTF-001 | Add deprecation warning | 30 min | `nautilus_gold_scalper/src/indicators/mtf_manager.py` |
| MTF-002 | Create comprehensive tests | 3 hrs | `tests/test_signals/test_mtf_manager.py` (NEW) |
| MTF-003 | Validate strategy still works (quick backtest) | 1 hr | - |
| MTF-004 | Verify coverage increased (>= 70% for mtf_manager) | 30 min | - |
| MTF-005 | Archive legacy mtf_manager.py | 1 hr | Move to `_archive/legacy/` |

**Semantic Collision Fix (7 hours)** - REQUIRES DECISION 1

| ID | Task | Time | Notes |
|----|------|------|-------|
| SEM-001 | Rename variables | 1 hr | `_mtf_order_blocks` -> `_htf_order_blocks`, etc. |
| SEM-002 | Fix OB/FVG detection logic | 2 hrs | Separate HTF/MTF/LTF |
| SEM-003 | Update confluence scorer call | 30 min | - |
| SEM-004 | Run baseline backtest BEFORE fix | 1 hr | Document current state |
| SEM-005 | Run validation backtest AFTER fix | 1 hr | Compare to SEM-004 |
| SEM-006 | Document changes | 30 min | BUGFIX_LOG + CHANGELOG |
| SEM-007 | **Add diagnostic logging for all 9 factors** | 1 hr | CRUCIBLE: log every factor score per bar |

#### Days 3-4: Confluence Simplification (NEW - per ARGUS)

| ID | Task | Time | Notes |
|----|------|------|-------|
| SIMP-001 | Run 1-month diagnostic backtest | 2 hrs | Analyze factor activation rates |
| SIMP-002 | Archive non-contributing factors | 3 hrs | Keep: Structure, OB, FVG, Session |
| SIMP-003 | Update confluence_scorer.py | 2 hrs | Reduce from 9 to 4 factors |
| SIMP-004 | Lower threshold from 35 to 25 | 30 min | More trades |
| SIMP-005 | Archive AdaptiveEVRouter | 1 hr | ARGUS: Thompson sampling invalid |
| SIMP-006 | Simplify StrategySelector to regime filter only | 2 hrs | ARGUS: over-engineered |

**Checkpoint 1 (Day 4 end):** Run 3-month validation backtest

| Gate | Target | Action if Failed |
|------|--------|------------------|
| Trades in 3 months | >= 50 | STOP, investigate root cause |
| OB/FVG score | > 0 on some bars | STOP, semantic fix failed |

#### Day 5: Test Coverage & Apex Compliance (8 hours)

| ID | Task | Time | Notes |
|----|------|------|-------|
| COV-001 | Time Gates Tests | 2 hrs | 4:30 PM block, 4:55 PM emergency, 4:59 PM flatten |
| COV-002 | DD Breach Tests | 2 hrs | Include HWM with BID/ASK prices (SENTINEL) |
| COV-003 | Circuit Breaker Level Tests | 2 hrs | All 5 levels per SENTINEL |
| APEX-001 | Timezone standardization audit | 1 hr | Grep all utcnow(), timezone.utc |
| APEX-002 | Add clock drift validation | 1 hr | NTP sync, degraded mode times |

### Week 2: Archive & Dead Code Removal (Days 6-8)

**Note:** Phase 01 tasks merged here (per consolidation)

| ID | Task | Time | Notes |
|----|------|------|-------|
| ARCH-001 | Archive ea_logic_full.py | 30 min | `scripts/backtest/strategies/` -> `_archive/legacy/` |
| ARCH-002 | Archive ea_logic_python.py | 30 min | - |
| ARCH-003 | Archive ea_logic_compat.py | 30 min | - |
| ARCH-004 | Archive footprint_analyzer.py | 30 min | No futures data |
| ARCH-005 | Archive footprint test files | 30 min | FORGE: handle test dependencies |
| ARCH-006 | Remove NEWS_TRADER from StrategySelector | 1 hr | Return STRATEGY_NONE |
| ARCH-007 | Verify no import errors | 1 hr | Run full test suite |

### Week 3: Ablation & Documentation (Days 9-15)

#### Ablation Study (Days 9-12)

| ID | Task | Time | Notes |
|----|------|------|-------|
| ABL-001 | Create 5 ablation configs | 2 hrs | Baseline + 4 configs (one per factor) |
| ABL-002 | Run baseline backtest (4 factors) | 2 hrs | Full 2003-2019 dataset |
| ABL-003 | Run 4 ablation variants | 8 hrs | Disable each factor one at a time |
| ABL-004 | Collect & compare results | 2 hrs | Focus on trade count + WFE impact |
| ABL-005 | Create ABLATION_RESULTS.md | 2 hrs | Document which factors contribute |

#### Documentation (Days 13-15)

| ID | Task | Time | Notes |
|----|------|------|-------|
| DOC-001 | Create ARCHITECTURE.md | 3 hrs | Simplified architecture diagram |
| DOC-002 | Update this ROADMAP with findings | 1 hr | - |
| DOC-003 | Create Phase 02 handoff document | 2 hrs | - |

### Phase 00 GO/NO-GO Criteria

| Criterion | Current | Target | Required |
|-----------|---------|--------|----------|
| File paths corrected | DONE | All correct | YES |
| _archive/ directory exists | DONE | Created | YES |
| Semantic collision fixed | Broken | OB/FVG > 0 | YES |
| Confluence factors reduced | 9 | 3-4 | YES |
| Threshold lowered | 35 | 25 | YES |
| AdaptiveEVRouter archived | Active | Archived | YES |
| Pre-ablation trades | 7 | >= 50 in 3 months | YES |
| Test coverage (line) | 52.68% | >= 70% | YES |
| Test coverage (branch) | 28.66% | >= 50% | YES |
| CRITICAL issues | 34 | <= 10 | YES |
| HWM tests include BID/ASK | Missing | Added | YES |
| Circuit breaker tests | Binary | All 5 levels | YES |

---

## Phase 02: SMC Audit + Cleanup (Consolidated)

**Objective:** Validate simplified SMC (3-4 factors) has edge that beats baseline.

**Duration:** 2 weeks

### Tasks

| ID | Task | Time | Agent |
|----|------|------|-------|
| SMC-001 | Audit remaining indicators (Structure, OB, FVG) | 6 hrs | CRUCIBLE |
| SMC-002 | Audit simplified confluence_scorer.py | 3 hrs | CRUCIBLE |
| SMC-003 | Run SMC-only backtest (2003-2019 training set) | 4 hrs | ORACLE |
| SMC-004 | Compare to EMA baseline from Phase -1 | 2 hrs | ORACLE |
| SMC-005 | Calculate WFE on 12 rolling windows | 4 hrs | ORACLE |
| SMC-006 | Document findings in SMC_AUDIT_RESULTS.md | 2 hrs | CRUCIBLE |

### GO/NO-GO Criteria

| Criterion | Target | Required |
|-----------|--------|----------|
| WFE (12-window rolling) | >= 0.6 | YES |
| SQN | >= 2.0 | YES |
| Min Trades | >= 200 | YES |
| SMC vs EMA baseline | SMC >= EMA | YES |

**Decision Gate:**
- IF SMC < EMA baseline -> Focus on TrendFollow only, consider archiving SMC
- IF SMC >= EMA -> Proceed to Phase 03

---

## Phase 03: TrendFollow Activation

**Objective:** Validate TrendFollow strategy as simpler alternative/complement to SMC.

**Duration:** 1 week

**Rationale (CRUCIBLE):** Run TrendFollow BEFORE SMC deep audit. It's simpler (~200 lines vs ~4,000), more likely to work.

### Tasks

| ID | Task | Time | Agent |
|----|------|------|-------|
| TF-001 | Audit trend_follow.py (196 lines) | 2 hrs | CRUCIBLE |
| TF-002 | Run TrendFollow-only backtest (2003-2019) | 3 hrs | ORACLE |
| TF-003 | Test PULLBACK only variant | 2 hrs | ORACLE |
| TF-004 | Test BREAKOUT only variant | 2 hrs | ORACLE |
| TF-005 | Compare to SMC and EMA baseline | 2 hrs | ORACLE |
| TF-006 | Calculate correlation with SMC signals | 1 hr | ORACLE |

### GO/NO-GO Criteria

| Criterion | Target | Required |
|-----------|--------|----------|
| WFE | >= 0.6 | YES |
| SQN | >= 2.0 | YES |
| Min Trades | >= 200 | YES |
| Correlation with SMC | < 0.5 | DESIRED (diversification) |

---

## Phase 05: Simplified Framework (REVISED)

**Objective:** Implement minimal framework - regime filter only, no complex router.

**Duration:** 3 days (reduced from 1 week)

**Changes from v1.0:**
- **REMOVED:** AdaptiveEVRouter (Thompson sampling invalid with current trade frequency)
- **REMOVED:** StrategySelector 6-gate architecture (over-engineered)
- **ADDED:** Simple regime filter based on validated strategies

### Tasks

| ID | Task | Time | Notes |
|----|------|------|-------|
| FW-001 | Verify AdaptiveEVRouter archived | 30 min | Done in Phase 00 |
| FW-002 | Simplify StrategySelector | 4 hrs | Reduce to: regime + session gates only |
| FW-003 | Test regime filter behavior | 2 hrs | - |
| FW-004 | Document simplified architecture | 2 hrs | - |

### Architecture After Simplification

```
Signal Flow (Simplified):
  Bar arrives
    -> Session Filter (block Asian, allow London/NY/Overlap)
    -> Regime Filter (block RANDOM_WALK per Hurst)
    -> Strategy Selection:
       - IF trending regime: Use TrendFollow (if validated)
       - ELSE: Use SMC (if validated)
       - IF neither validated: Use best performer from Phase 02/03
    -> Confluence Check (3-4 factors)
    -> Risk Management (Apex DD/time gates)
    -> Trade Execution
```

### GO/NO-GO Criteria

| Criterion | Target | Required |
|-----------|--------|----------|
| Simplified selector working | YES | YES |
| No Thompson sampling | Archived | YES |
| Integration test passing | YES | YES |

---

## Phase 06: Enhanced Validation (REVISED per ORACLE)

**Objective:** Rigorous statistical validation with all ORACLE requirements.

**Duration:** 2 weeks

### Methodology Enhancements (per ORACLE review)

| Element | v1.0 | v2.0 |
|---------|------|------|
| WFA windows | 3 folds | 12 rolling windows |
| WFA structure | Simple | CPCV (Combinatorially Symmetric Cross-Validation) |
| Holdout period | None | 2020-2025 (20% most recent) |
| Monte Carlo runs | Unspecified | 5000 runs, block bootstrap |
| DSR | Missing | >= 0.80 required |
| PBO | Missing | < 25% required |
| Purge gap | None | Max trade duration |

### Tasks

| ID | Task | Time | Agent |
|----|------|------|-------|
| VAL-001 | Reserve holdout (2020-2025) - DO NOT TOUCH | 30 min | ORACLE |
| VAL-002 | Run 12-window CPCV on training set (2003-2019) | 8 hrs | ORACLE |
| VAL-003 | Calculate DSR (Deflated Sharpe Ratio) | 2 hrs | ORACLE |
| VAL-004 | Calculate PBO (Probability Backtest Overfitting) | 4 hrs | ORACLE |
| VAL-005 | Run Monte Carlo (5000 runs, block bootstrap) | 6 hrs | ORACLE |
| VAL-006 | Report MC95DD, MC5DD, P(profitable year) | 2 hrs | ORACLE |
| VAL-007 | Run regime-stratified validation | 4 hrs | ORACLE |
| VAL-008 | Transaction cost sensitivity (30/50/100 pip spread) | 3 hrs | ORACLE |
| VAL-009 | Final holdout validation (2020-2025) | 4 hrs | ORACLE |
| VAL-010 | Create VALIDATION_RESULTS.md | 3 hrs | ORACLE |

### GO/NO-GO Criteria (ENHANCED)

| Criterion | Target | Required |
|-----------|--------|----------|
| WFE (12-window CPCV) | >= 0.6 | YES |
| SQN | >= 2.0 | YES |
| PSR | >= 0.85 | YES |
| **DSR (NEW)** | **>= 0.80** | **YES** |
| **PBO (NEW)** | **< 25%** | **YES** |
| MC95DD | < 4% | YES |
| MC5DD (tail risk) | < 3% | YES |
| **Holdout validation (NEW)** | Positive return | **YES** |
| Min trades (per window) | >= 50 | YES |
| Total trades | >= 200 | YES |

---

## Phase 07: Paper Trading (NEW - MANDATORY per SENTINEL)

**Objective:** Validate strategy with live data feed before production.

**Duration:** 2 weeks (minimum per CLAUDE.md production_workflow)

**Rationale (SENTINEL):** "Phase 09 goes directly from Phase 06 backtest to production. This violates CLAUDE.md mandate and is a BLOCKING issue."

### Requirements

1. **Run strategy on LIVE data stream** (not backtest replay)
2. **Track unrealized PnL and HWM exactly as Apex would**
3. **Verify time gates work correctly:**
   - 4:30 PM ET: Block new trades
   - 4:55 PM ET: Emergency force-close begins
   - 4:59 PM ET: Must be flat (no positions)
4. **Confirm emergency close executes within latency budget**
5. **Log all trades, entries, exits, and slippage observed**
6. **Test broker SL acceptance** (server-side stops as backup)

### Tasks

| ID | Task | Time | Agent |
|----|------|------|-------|
| PT-001 | Deploy strategy to paper trading environment | 4 hrs | FORGE |
| PT-002 | Configure live data feed | 2 hrs | FORGE |
| PT-003 | Configure paper trading logging | 2 hrs | FORGE |
| PT-004 | Run for 10 trading days (minimum) | Continuous | SENTINEL (monitor) |
| PT-005 | Daily review of trades and metrics | 30 min/day | SENTINEL |
| PT-006 | Test broker SL acceptance | 2 hrs | SENTINEL |
| PT-007 | Document any issues found | Continuous | FORGE |
| PT-008 | Create PAPER_TRADING_RESULTS.md | 2 hrs | SENTINEL |

### GO/NO-GO Criteria

| Criterion | Target | Required |
|-----------|--------|----------|
| Duration | >= 10 trading days | YES |
| Critical issues | 0 | YES |
| Time gates verified | All 3 working | YES |
| HWM tracking correct | BID/ASK not MID | YES |
| Broker SL accepted | YES | YES |
| Paper DD breach | None | YES |
| Slippage within budget | < 2 pips average | YES |

---

## Phase 08: Production Readiness (NEW per SENTINEL)

**Objective:** Final verification of operational safety and SENTINEL sign-off.

**Duration:** 1 week

**Rationale (SENTINEL):** "The plan addresses 'does the strategy have edge?' but not 'what happens when things fail in live trading?'"

### Tasks

| ID | Task | Time | Agent |
|----|------|------|-------|
| PR-001 | Circuit breaker level testing (all 5 levels) | 4 hrs | SENTINEL |
| PR-002 | Emergency close protocol with retry logic | 3 hrs | SENTINEL |
| PR-003 | Network disconnect simulation | 2 hrs | SENTINEL |
| PR-004 | Broker rejection scenarios | 2 hrs | SENTINEL |
| PR-005 | Clock drift scenarios | 2 hrs | SENTINEL |
| PR-006 | Data staleness detection test | 2 hrs | SENTINEL |
| PR-007 | HWM calculation verification (BID/ASK) | 2 hrs | SENTINEL |
| PR-008 | Multi-position aggregation test (if applicable) | 2 hrs | SENTINEL |
| PR-009 | CRITIC adversarial review of production code | 4 hrs | CRITIC |
| PR-010 | SENTINEL formal sign-off | 2 hrs | SENTINEL |
| PR-011 | Create PRODUCTION_READINESS_REPORT.md | 3 hrs | SENTINEL |

### Circuit Breaker Levels (per SENTINEL spec)

| Level | DD Range | Size Multiplier | Strategy Restriction | Close By |
|-------|----------|-----------------|---------------------|----------|
| 0 (NORMAL) | < 3% | 1.0 (100%) | All | 4:59 PM |
| 1 (WARNING) | 3-3.5% | 1.0 (100%) | A+B only | 4:30 PM |
| 2 (CAUTION) | 3.5-4% | 0.5 (50%) | A only | 4:00 PM |
| 3 (SOFT STOP) | 4-4.5% | 0.0 (0%) | No new trades | Immediate close |
| 4 (EMERGENCY) | >= 4.5% | 0.0 (0%) | Close all | IMMEDIATE |

### GO/NO-GO Criteria (FINAL GATE)

| Criterion | Target | Required |
|-----------|--------|----------|
| All circuit breaker levels verified | 5/5 | YES |
| Emergency close retry logic verified | Working | YES |
| Failure modes tested | All passed | YES |
| CRITIC adversarial review | No critical issues | YES |
| **SENTINEL sign-off** | **OBTAINED** | **YES (BLOCKING)** |

**SENTINEL NO-GO = FINAL. No override possible.**

---

## Execution Order

```
Phase -1: Baseline Validation (2 days)
    Run EMA 20/50 + session + Apex risk backtest
    Target: 200+ trades, record baseline metrics
    DECISION: SMC must beat EMA to proceed
    |
    v
Phase 00: Pre-Activation Sprint (3 weeks)
    Week 1: Semantic fix, confluence simplification, pre-ablation gate
    Week 2: Archive dead code, merge Phase 01 cleanup
    Week 3: Ablation study, documentation
    GATE: All 12 GO/NO-GO criteria must pass
    |
    v
Phase 02: SMC Audit (2 weeks)
    Audit simplified SMC (3-4 factors)
    12-window WFA validation
    GATE: SMC >= EMA baseline
    |
    v
Phase 03: TrendFollow Activation (1 week)
    Validate simpler alternative
    Calculate correlation with SMC
    GATE: WFE >= 0.6, 200+ trades
    |
    v
Phase 05: Simplified Framework (3 days)
    Regime filter only (no router)
    Integration testing
    GATE: Working integration
    |
    v
Phase 06: Enhanced Validation (2 weeks)
    DSR, PBO, CPCV, holdout
    Monte Carlo 5000 runs
    Regime-stratified validation
    GATE: All ORACLE criteria pass
    |
    v
Phase 07: Paper Trading (2 weeks) [MANDATORY]
    Live data feed, real-time tracking
    Verify time gates, broker SL
    GATE: 0 critical issues
    |
    v
Phase 08: Production Readiness (1 week) [MANDATORY]
    Failure mode testing
    SENTINEL formal sign-off
    GATE: SENTINEL approval
    |
    v
PRODUCTION GO/NO-GO
```

**Critical Decision Points:**

| Gate | If Failed |
|------|-----------|
| Phase -1 (EMA baseline) | SMC < EMA: STOP, fundamental review |
| Phase 00 (Pre-ablation) | < 50 trades: STOP, investigate |
| Phase 02 (SMC audit) | SMC < EMA: Focus TrendFollow only |
| Phase 06 (Validation) | Any metric fails: Iterate, no GO |
| Phase 07 (Paper trading) | Critical issues: Fix before production |
| Phase 08 (Production) | SENTINEL NO-GO: FINAL, no override |

---

## Agent Allocation

| Phase | Agents | Model | Notes |
|-------|--------|-------|-------|
| Phase -1 | 1 ORACLE + 1 FORGE | opus | Baseline test |
| Phase 00 | 4 FORGE + 1 ORACLE + 1 SENTINEL | opus | Heavy implementation |
| Phase 02 | 2 CRUCIBLE + 1 ORACLE | opus | Strategy audit |
| Phase 03 | 1 CRUCIBLE + 1 ORACLE | opus | TrendFollow validation |
| Phase 05 | 1 FORGE | opus | Framework simplification |
| Phase 06 | 2 ORACLE + 1 CRITIC | opus | Enhanced validation |
| Phase 07 | 1 SENTINEL + 1 FORGE | opus | Paper trading setup + monitoring |
| Phase 08 | 1 SENTINEL + 1 CRITIC | opus | Production readiness |

**Total:** ~15 agent invocations
**Max Parallel:** 2-3 per round (default, per CORE orchestration rules)

---

## Success Metrics (Consolidated)

| Metric | Threshold | Required | Phase |
|--------|-----------|----------|-------|
| Baseline trades | >= 200 | YES | Phase -1 |
| CRITICAL issues | <= 10 | YES | Phase 00 |
| Test coverage (line) | >= 70% | YES | Phase 00 |
| Test coverage (branch) | >= 50% | YES | Phase 00 |
| Pre-ablation trades | >= 50 in 3 months | YES | Phase 00 |
| Confluence factors | 3-4 | YES | Phase 00 |
| WFE | >= 0.6 | YES | Phase 02, 03, 06 |
| SQN | >= 2.0 | YES | Phase 02, 03, 06 |
| PSR | >= 0.85 | YES | Phase 02, 03, 06 |
| **DSR** | **>= 0.80** | **YES** | Phase 06 |
| **PBO** | **< 25%** | **YES** | Phase 06 |
| MC95DD | < 4% | YES | Phase 06 |
| MC5DD (tail risk) | < 3% | YES | Phase 06 |
| **Holdout validation** | **Positive** | **YES** | Phase 06 |
| Min trades | >= 200 | YES | All backtests |
| Paper trading duration | >= 10 days | YES | Phase 07 |
| Paper trading issues | 0 critical | YES | Phase 07 |
| **SENTINEL sign-off** | **Obtained** | **YES** | Phase 08 |

---

## Appendix: Agent Review Summary

The following agent reviews are incorporated in full in 01-ROADMAP.md (v1.3):

| Agent | Focus | Key Issues Identified |
|-------|-------|----------------------|
| **FORGE** | Implementation | File paths wrong, _archive/ missing, duplicate tasks |
| **CRUCIBLE** | Strategy | 8/9 factors dead, need baseline, over-engineered |
| **ORACLE** | Validation | No DSR, no holdout, MC unspecified, PBO missing |
| **SENTINEL** | Apex Compliance | No paper trading, no broker SL, HWM unverified |
| **ARGUS (Multi-Strategy)** | Research | Remove router, simplify architecture |
| **ARGUS (SMC/Gold)** | Research | Reduce factors, remove mean revert |

All detailed findings remain in 01-ROADMAP.md for reference. This v2.0 document is the AUTHORITATIVE execution plan.

---

## Summary: What Changed from v1.0

| Change | Rationale | Impact |
|--------|-----------|--------|
| Added Phase -1 (Baseline) | CRUCIBLE: Prove SMC > simple | +2 days, prevents wasted effort |
| Removed Phase 04 (Mean Revert) | ARGUS: Gold trends | -1 week |
| Merged Phase 01 into 02 | Reduce overhead | More efficient |
| Added Phase 07 (Paper Trading) | SENTINEL: MANDATORY | +2 weeks, required by CLAUDE.md |
| Added Phase 08 (Production) | SENTINEL: Safety | +1 week |
| Enhanced Phase 06 | ORACLE: DSR, PBO, CPCV, holdout | Higher quality validation |
| Fixed file paths | FORGE: All incorrect | Execution will work |
| Reduced factors 9 -> 3-4 | ARGUS/CRUCIBLE: 8 are dead | Simpler, more robust |
| Archived AdaptiveEVRouter | ARGUS: Invalid with 7 trades | Simpler architecture |
| Timeline 6-8 -> 10-12 weeks | FORGE + mandatory phases | Realistic + complete |

---

**Document Status:** COMPLETE - Ready for Phase -1 execution pending Decision 1 approval.

**Next Action:** User approves Decision 1 (Semantic Collision) -> Execute Phase -1 (Baseline Validation)

---

*ROADMAP v2.0 | Consolidated from 7 Agent Reviews | 2025-12-23*
