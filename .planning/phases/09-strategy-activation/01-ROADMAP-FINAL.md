# ROADMAP FINAL: Strategy Activation & Validation

**Document:** 01-ROADMAP-FINAL.md
**Version:** 1.0
**Created:** 2025-12-23
**Status:** READY FOR EXECUTION
**Philosophy:** FIX FIRST, VALIDATE SECOND, SIMPLIFY IF NECESSARY

---

## Philosophy: FIX FIRST, VALIDATE SECOND

> "Better to have a war machine than a weak little pistol."

This roadmap follows a fundamentally different approach from previous versions (v1 and v2):

| Previous Approach | This Approach |
|-------------------|---------------|
| Observe 8/9 factors scoring 0 | Recognize this as a BUG SYMPTOM |
| Conclude "system is over-engineered" | Investigate root cause FIRST |
| Pre-decide to simplify to 3-4 factors | Fix bugs, THEN validate full system |
| Archive complexity before testing | DISABLE components, don't archive |

### The Core Principle

1. **The current 9-factor system is NOT WORKING because of BUGS, not complexity**
2. **FIX the bugs first** (semantic collision, file paths, trade clustering)
3. **RUN the FIXED system** with all 9 factors at multiple thresholds
4. **VALIDATE**: Does the fixed system produce enough trades with edge?
5. **IF YES**: Keep the complexity - we have a war machine
6. **IF NO**: THEN consider simplification as Plan B

### Why This Matters

The CRITIC review identified **confirmation bias** in previous planning:
- All agents concluded "simplify" based on a BROKEN system
- No counterfactual test: "What happens if we fix the bugs and keep 9 factors?"
- Trade clustering (all 7 trades in Jan 2-10) was noted but never investigated
- Decisions were made BEFORE gathering diagnostic data

This roadmap corrects that error by following **falsification-first** protocol:
- State the claim: "9 factors are unnecessary complexity"
- Design fastest disproof test: Fix semantic collision, run 9-factor system
- If 50+ trades with 4+ factors firing: Claim DISPROVED

---

## Decision Log

These decisions have been made by the user (Franco):

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **OB/FVG Timeframe** | M15 (MTF) | SMC philosophy - structural zones on M15, entry on M5 |
| **9 Confluence Factors** | KEEP ALL | Fix bugs first, validate before removing |
| **AdaptiveEVRouter** | DISABLE (not archive) | Preserve optionality for when trade frequency increases |
| **StrategySelector** | KEEP | Validate gates work before simplifying |
| **TREND_FOLLOW Strategy** | KEEP | Validate after SMC_SCALPER |
| **MEAN_REVERT Strategy** | VALIDATE FIRST | Research says gold doesn't mean-revert, but test empirically |
| **Simplification** | PLAN B | Only if fixed system fails validation |

---

## Phase Overview

| Phase | Plan File | Focus | Duration | GO/NO-GO Gate |
|-------|-----------|-------|----------|---------------|
| **00** | (inline below) | Critical Bug Fixes | 1 week | All 9 factors score > 0 in test |
| **01** | `02-PHASE-01-PLAN.md` | Cleanup & Consolidation | 3 days | Dead code archived, architecture documented |
| **02** | `03-PHASE-02-PLAN.md` | SMC_SCALPER Deep Audit | 2 weeks | All indicators validated, backtest passes |
| **03** | `04-PHASE-03-PLAN.md` | TREND_FOLLOW Activation | 1 week | Strategy enabled with edge verified |
| **04** | `05-PHASE-04-PLAN.md` | MEAN_REVERT Decision | 3 days | User decision: implement/remove/defer |
| **05** | `06-PHASE-05-PLAN.md` | Framework Integration | 1 week | Selector + Router validated |
| **06** | `07-PHASE-06-PLAN.md` | Multi-Strategy Backtest | 1 week | Combined metrics meet targets |
| **07** | (inline below) | Paper Trading | 2 weeks | No critical issues |
| **08** | (inline below) | Production Readiness | 1 week | SENTINEL sign-off |

**Total Timeline:** 10-11 weeks

**Note:** Phase 00, 07, and 08 are NEW phases added by the FIX FIRST approach. Phases 01-06 use the detailed v1 plans.

---

## Detailed Phase Plans

The detailed task breakdowns are in separate files for easy execution:

| Phase | Plan File | Focus |
|-------|-----------|-------|
| 01 | `02-PHASE-01-PLAN.md` | Cleanup & Consolidation (dead code, NEWS_TRADER, MTF manager) |
| 02 | `03-PHASE-02-PLAN.md` | SMC_SCALPER Deep Audit (OB, FVG, Sweep, Structure, Regime, Scorer) |
| 03 | `04-PHASE-03-PLAN.md` | TREND_FOLLOW Activation (pullback + breakout) |
| 04 | `05-PHASE-04-PLAN.md` | MEAN_REVERT Decision (research + implement/remove/defer) |
| 05 | `06-PHASE-05-PLAN.md` | Framework Integration (Selector + Router validation) |
| 06 | `07-PHASE-06-PLAN.md` | Multi-Strategy Backtest (individual vs combined) |

**These detailed plans are the executable specifications. The sections below are executive summaries.**

---

## Phase 00: Critical Bug Fixes (1 week) - NEW PHASE

### Objective
Fix all known bugs that prevent the 9-factor system from functioning correctly.

### 00-01: Semantic Collision Fix (Priority 0) - Day 1-2

**Problem:** Variable `_mtf_order_blocks` is overwritten by LTF detection. Confluence scorer receives M5 data thinking it is M15 structural zones.

**User Decision:** Use M15 for OB/FVG (Option A from 02-CRITICAL_ISSUES_AUDIT.md)

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

**Owner:** FORGE (opus)
**Effort:** 4-6 hours

### 00-02: File Path Fixes (Priority 0) - Day 2

**Problem:** Paths in planning docs don't match actual codebase structure.

**Corrected Paths:**
| Planned Path | Actual Path | Exists |
|--------------|-------------|--------|
| `src/indicators/mtf_manager.py` | `nautilus_gold_scalper/src/indicators/mtf_manager.py` | YES (legacy) |
| `src/signals/mtf_manager.py` | `nautilus_gold_scalper/src/signals/mtf_manager.py` | YES (production) |
| `tests/test_signals/test_mtf_manager.py` | Does not exist | MISSING |

**Fix:**
1. Create `_archive/` directory structure
2. Add deprecation warning to legacy `indicators/mtf_manager.py`
3. Create tests for production `signals/mtf_manager.py`
4. Handle footprint test dependencies (tests reference removed code)

**Owner:** FORGE (opus)
**Effort:** 3-4 hours

### 00-03: Known Bug Fixes - Day 3-4

**Already Fixed:**
- [x] Score=0.0 session adjustment (commit 58b84178)

**Still Open:**

| Bug | Description | Investigation |
|-----|-------------|---------------|
| Trade Clustering | All 7 trades Jan 2-10, ZERO after | Check for state reset issues, memory leaks, MTF bar accumulation |
| bracket_sl_canceled | Failsafe triggers repeatedly | Investigate bracket order rejection cause |
| Temporal Integrity | MC/WFA scripts use leaky EA parity | Use main strategy backtest instead |

**Trade Clustering Investigation:**
1. Add logging for factor scores at week boundaries
2. Compare factor activations: week 1 vs week 10 vs week 20
3. Check for state variables that grow unbounded
4. Verify MTF bar buffers don't overflow

**Owner:** FORGE (opus)
**Effort:** 6-8 hours

### 00-04: Diagnostic Logging - Day 4-5

**Purpose:** Understand exactly why each factor scores what it does.

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
```

**Owner:** FORGE (opus)
**Effort:** 2 hours

### Phase 00 GO/NO-GO Gate

**Criteria:**
- [ ] All 9 factors can score > 0 (verify with diagnostic logs)
- [ ] No division by zero or null handling errors
- [ ] Test suite passes (`mypy --strict`, `pytest -q`)
- [ ] File paths corrected and documented

**Decision:**
| Outcome | Action |
|---------|--------|
| All factors can fire | Proceed to Phase 01 |
| 5+ factors fire | Proceed with caution, document non-firing |
| < 5 factors fire | Investigate further before Phase 01 |

---

## Phase 01: Diagnostic & Baseline (3 days)

### Objective
Run the FIXED system and gather data to make informed decisions.

### 01-01: Run Fixed System (Day 1)

**Backtest Configuration:**
- Dataset: `xauusd_2003_2025_stride20_full.parquet`
- Period: 2024-01-01 to 2024-06-30 (6 months)
- All 9 factors enabled
- Threshold: 35 (original)

**Metrics to Capture:**
| Metric | Before Fix | After Fix | Delta |
|--------|------------|-----------|-------|
| Total Trades | 7 | ? | ? |
| Factors Firing | 1 | ? | ? |
| Win Rate | 42.9% | ? | ? |
| Net PnL | +$319 | ? | ? |

**Factor Activation Report:**
| Factor | Fires > 0 | Avg Score | Max Score |
|--------|-----------|-----------|-----------|
| Structure | ? | ? | ? |
| Regime | ? | ? | ? |
| OB | ? | ? | ? |
| FVG | ? | ? | ? |
| Sweep | ? | ? | ? |
| AMD | ? | ? | ? |
| Fib | ? | ? | ? |
| MTF | ? | ? | ? |
| Footprint | ? | ? | ? |

**Owner:** ORACLE (opus)
**Effort:** 2-3 hours

### 01-02: Threshold Sensitivity Analysis (Day 1-2)

**Test Configurations:**
| Config | Threshold | Expected Trades | Selectivity |
|--------|-----------|-----------------|-------------|
| A | 35 | Baseline | High |
| B | 30 | +20-30% | Medium-High |
| C | 25 | +50-100% | Medium |
| D | 20 | +100%+ | Lower |

**Analysis:**
- Plot trades vs threshold
- Plot WFE vs threshold (find optimal)
- Identify minimum threshold for 200+ trades/6mo

**Owner:** ORACLE (opus)
**Effort:** 3-4 hours

### 01-03: Simple Baseline (For Comparison ONLY) (Day 2-3)

**Purpose:** Provide a REFERENCE point, not a replacement.

**Baseline Strategy:**
- EMA 20/50 crossover
- Same session filter as SMC
- Same risk management
- Same Apex compliance

**Comparison:**
| Metric | SMC 9-Factor | EMA Baseline | Delta |
|--------|--------------|--------------|-------|
| Trades | ? | ? | ? |
| WFE | ? | ? | ? |
| SQN | ? | ? | ? |
| Edge per Trade | ? | ? | ? |

**Important:** This comparison is to establish a BAR, not to decide on simplification yet.

**Owner:** ORACLE (opus)
**Effort:** 2-3 hours

### Phase 01 GO/NO-GO Gate

**Criteria:**
- [ ] Fixed system produces 50+ trades in 6 months
- [ ] At least 4 factors contribute (score > 0)
- [ ] No regression in win rate or PnL

**Decision:**
| Outcome | Action |
|---------|--------|
| 50+ trades, 4+ factors | PROCEED to Phase 02 with full 9-factor system |
| 50+ trades, < 4 factors | PROCEED but flag for ablation study |
| < 50 trades | TRIGGER Plan B (Simplification) |

---

## Phase 02: Full System Validation (1 week)

### Objective
Validate the fixed 9-factor system meets all success criteria.

### 02-01: Extended Backtest (Day 1-3)

**Configuration:**
- Period: 2003-2020 (development)
- Holdout: 2021-2025 (NEVER optimize on this)
- Optimal threshold from Phase 01

**Validation Metrics:**
| Metric | Target | Actual | Pass? |
|--------|--------|--------|-------|
| Trade Count | >= 200 in 6mo equivalent | ? | ? |
| WFE | >= 0.6 | ? | ? |
| SQN | >= 2.0 | ? | ? |
| PSR | >= 0.85 | ? | ? |
| DSR | >= 0.80 | ? | ? |
| PBO | < 25% | ? | ? |
| MC95DD | < 4% | ? | ? |

### 02-02: Walk-Forward Analysis (Day 3-4)

**Configuration:**
- 12 windows
- IS: 2 years, OOS: 6 months
- Purge gap: 1 week

**Output:**
- WFE per window
- Aggregate WFE
- Stability analysis

### 02-03: Monte Carlo Stress Test (Day 4-5)

**Configuration:**
- 5000 runs
- Block bootstrap (block size = avg trade duration)
- Shuffle trades, resample with replacement

**Output:**
- MC 95th percentile DD
- MC 99th percentile DD (must be < 5% for Apex)
- Confidence intervals

### 02-04: Holdout Validation (Day 5)

**CRITICAL:** First time touching 2021-2025 data.

**Configuration:**
- Apply model trained on 2003-2020
- Run on 2021-2025 (5 years)
- NO parameter adjustment allowed

**Decision:**
| Holdout WFE | Action |
|-------------|--------|
| >= 0.5 | EXCELLENT - edge persists |
| 0.3 - 0.5 | CAUTION - investigate regime shift |
| < 0.3 | LIKELY OVERFITTED |

### Phase 02 GO/NO-GO Gate

**Criteria (ALL must pass):**
- [ ] WFE >= 0.6
- [ ] SQN >= 2.0
- [ ] PSR >= 0.85
- [ ] DSR >= 0.80
- [ ] PBO < 25%
- [ ] MC95DD < 4%
- [ ] Holdout WFE >= 0.5

**Decision:**
| Outcome | Action |
|---------|--------|
| All pass | PROCEED to Phase 03 |
| Most pass, 1-2 marginal | CONDITIONAL proceed with monitoring |
| Multiple failures | TRIGGER Plan B or HALT |

---

## Phase 03: Strategy-by-Strategy Audit (2 weeks)

### Objective
Validate each strategy individually before combining.

### 03-01: SMC_SCALPER Deep Audit (Week 1)

**Focus Areas:**
1. Factor contribution analysis (mini-ablation)
2. Session-specific performance
3. Regime-specific performance
4. Trade distribution across time

**Deliverable:** `orchestration/SMC_SCALPER_AUDIT.md`

### 03-02: TREND_FOLLOW Validation (Week 2, Day 1-3)

**Focus Areas:**
1. EMA crossover + session filter
2. Compare to SMC_SCALPER
3. Correlation analysis

**Decision:**
| Comparison | Action |
|------------|--------|
| SMC >> TrendFollow | Focus on SMC |
| SMC ~ TrendFollow | Keep both for diversification |
| SMC << TrendFollow | Consider simplification |

### 03-03: MEAN_REVERT Assessment (Week 2, Day 4-5)

**Research Context:** ARGUS found gold exhibits positive time series momentum, suggesting mean reversion may not work.

**Test:**
- Run mean revert strategy on XAUUSD
- Compare to momentum baseline
- If underperforms: DEFER (not archive)

**Decision:**
| Outcome | Action |
|---------|--------|
| Positive edge | KEEP for diversification |
| No edge | DEFER (keep code, disable in selector) |
| Negative edge | DEFER and document |

### Phase 03 GO/NO-GO Gate

**Criteria:**
- [ ] At least 1 strategy meets all criteria
- [ ] Strategy correlation < 0.7 (if keeping multiple)
- [ ] No critical issues found

---

## Phase 04: Framework Integration (1 week)

### Objective
Validate that StrategySelector and AdaptiveEVRouter work correctly.

### 04-01: StrategySelector Gate Validation

**6 Gates to Test:**
| Gate | Purpose | Test |
|------|---------|------|
| Safety | DD limits | Verify blocks when approaching limits |
| FTMO | Consistency | Verify 30% rule enforcement |
| News | High-impact events | Verify filtering |
| Session | Trading windows | Verify Asian block |
| Holiday | Market closures | Verify no trading |
| Regime | Random walk detection | Verify blocking |

### 04-02: AdaptiveEVRouter (DISABLED MODE)

**Status:** Router DISABLED, not archived.

**Test:**
- Verify static allocation works (100% to selected strategy)
- Verify Thompson sampling code still compiles
- Document re-enablement criteria

**Re-enablement Criteria:**
- Trade frequency > 200/year per strategy
- Multiple strategies have validated edge
- Correlation matrix can be computed

### Phase 04 GO/NO-GO Gate

**Criteria:**
- [ ] All 6 selector gates work correctly
- [ ] Static allocation functions properly
- [ ] Router code compiles (for future use)

---

## Phase 05: Multi-Strategy Backtest (1 week)

### Objective
Validate combined strategy performance.

### 05-01: Combined Backtest

**Configurations:**
| Config | Setup |
|--------|-------|
| A | SMC_SCALPER only |
| B | TREND_FOLLOW only |
| C | SMC + TREND (selector only) |
| D | SMC + TREND + Router (if enabled) |

### 05-02: Diversification Benefit Analysis

**Metrics:**
| Metric | SMC | TF | Combined | Benefit |
|--------|-----|----|---------| --------|
| WFE | ? | ? | ? | ? |
| SQN | ? | ? | ? | ? |
| MaxDD | ? | ? | ? | ? |
| Sharpe | ? | ? | ? | ? |

**Expected:** Combined should have lower DD than either individual.

### Phase 05 GO/NO-GO Gate

**Criteria:**
- [ ] Combined WFE >= 0.6
- [ ] Combined MC95DD < 4%
- [ ] Diversification benefit > 0 (or equal)

---

## Phase 06: Paper Trading (2 weeks - MANDATORY)

### Objective
Validate the system works with LIVE data before risking real money.

### Requirements (per CLAUDE.md production_workflow)

**Duration:** Minimum 2 weeks

**Setup:**
- Live data feed (not backtest replay)
- Track unrealized PnL and HWM exactly as Apex would
- NO real money at risk

**Verification Points:**

| ID | Test | Criterion |
|----|------|-----------|
| PT-001 | Time gate 4:30 PM | New trades blocked |
| PT-002 | Time gate 4:55 PM | Emergency close initiates |
| PT-003 | Time gate 4:59 PM | Position flat verified |
| PT-004 | HWM tracking | Uses BID/ASK not MID |
| PT-005 | Trailing DD | Correct calculation from HWM |
| PT-006 | Broker SL | Exists as backup |
| PT-007 | Latency | < 50ms on-tick |

**Logging:**
- All trades (entry, exit, PnL)
- All signals (even those not executed)
- Time gate events
- DD calculations

### Phase 06 GO/NO-GO Gate

**Criteria:**
- [ ] No critical issues in 2 weeks
- [ ] All time gates verified
- [ ] HWM calculation verified
- [ ] Latency within budget

**Decision:**
| Outcome | Action |
|---------|--------|
| No issues | PROCEED to Phase 07 |
| Minor issues | FIX and restart 1-week paper trading |
| Critical issues | HALT and investigate |

---

## Phase 07: Production Readiness (1 week)

### Objective
Final checks before deploying real money.

### 07-01: External CRITIC Review

**Per CLAUDE.md production_workflow:**
- Spawn EXTERNAL CRITIC (fresh context)
- Review all validation artifacts
- Catch blind spots the team missed

### 07-02: SENTINEL Final Approval

**Apex Compliance Checklist:**
- [ ] Trailing DD < 5% from HWM
- [ ] Daily DD < 3% halt
- [ ] Close all by 4:59 PM ET
- [ ] Block new trades after 4:30 PM ET
- [ ] Emergency close from 4:55 PM ET
- [ ] HWM uses BID/ASK
- [ ] Broker-side SL as backup

### 07-03: Deployment Checklist

**Technical:**
- [ ] All tests pass
- [ ] Coverage >= 70% line, >= 50% branch
- [ ] No mypy errors
- [ ] Latency verified

**Operational:**
- [ ] Runbook documented
- [ ] Alerting configured
- [ ] Rollback procedure documented
- [ ] Emergency contact list

### Phase 07 GO/NO-GO Gate

**FINAL GATE - ALL MUST PASS:**
- [ ] CRITIC review: No critical issues
- [ ] SENTINEL approval: Obtained
- [ ] All validation metrics: GREEN
- [ ] Paper trading: PASSED
- [ ] Deployment checklist: COMPLETE

**Decision:**
| Outcome | Action |
|---------|--------|
| All pass | **GO** - Deploy to smallest account ($50k) |
| Any fail | **NO-GO** - Address issues, re-run relevant phases |

---

## Success Metrics (From CLAUDE.md)

These are the MANDATORY thresholds. No shortcuts.

| Metric | Threshold | Description |
|--------|-----------|-------------|
| WFE | >= 0.6 | Walk-Forward Efficiency |
| SQN | >= 2.0 | System Quality Number |
| PSR | >= 0.85 | Probabilistic Sharpe Ratio |
| DSR | >= 0.80 | Deflated Sharpe Ratio |
| PBO | < 25% | Probability Backtest Overfitting |
| MC95DD | < 4% | Monte Carlo 95th percentile DD |
| Min Trades | >= 200 | Minimum for statistical validity |
| Holdout | Positive | Edge on 2021-2025 |

---

## What We're KEEPING (Not Archiving)

| Component | Status | Rationale |
|-----------|--------|-----------|
| **All 9 confluence factors** | ENABLED | Fix bugs first, then validate |
| **AdaptiveEVRouter** | DISABLED (not archived) | Preserve optionality |
| **StrategySelector** | ENABLED | Validate gates work |
| **TREND_FOLLOW strategy** | TO VALIDATE | May provide diversification |
| **MEAN_REVERT strategy** | TO VALIDATE | Research says no edge, but test empirically |
| **All SMC indicators** | ENABLED | Core to strategy |

**Key Principle:** DISABLE components, don't ARCHIVE them. Keep code in main branch for optionality.

---

## Simplification is PLAN B

**Trigger Conditions for Plan B:**

| Gate | Condition | Action |
|------|-----------|--------|
| Phase 00 | < 5 factors fire after bug fix | Investigate, then Plan B |
| Phase 01 | < 50 trades after fix | Trigger Plan B |
| Phase 02 | WFE < 0.5 | Trigger Plan B |
| Phase 02 | Holdout WFE < 0.3 | Trigger Plan B |
| Any | SMC < EMA baseline by 20%+ | Trigger Plan B |

**Plan B Steps (from 08-SIMPLIFICATION_PLAN.md):**

1. Reduce factors from 9 to 3-4 (Structure, OB, FVG, Session)
2. Set non-contributing factors to weight 0
3. Lower threshold to 50 (new scale)
4. Archive AdaptiveEVRouter (only if Plan B triggered)
5. Simplify StrategySelector to 2 gates

**Important:** Plan B is ONLY triggered if the FIXED system fails. We do NOT pre-decide simplification.

---

## Hard Exit Criteria

**Conditions under which we STOP the project:**

| Gate | Condition | Action |
|------|-----------|--------|
| Pre-Phase 00 | EMA baseline beats SMC after fix | STOP |
| Phase 00 | Bugs cannot be fixed after 2 weeks | STOP or PIVOT |
| Phase 02 | WFE < 0.3 on development set | STOP |
| Holdout | Negative return on 2021-2025 | STOP |
| Any | Engineering hours > 400 with no progress | HARD PAUSE |
| Any | Franco loses interest | STOP |

**Fallback Options:**
1. Higher timeframe SMC (H4/D1 where ICT designed it)
2. Different market (NQ/ES futures)
3. Simple trend following
4. Manual discretionary trading (14 signals/year is manageable)

---

## Document Cleanup

**After this roadmap is approved:**

1. **Archive to `_archive/planning/v1-v2/`:**
   - 00-BRIEF.md (v1)
   - 00-BRIEF-v2.md
   - 01-ROADMAP.md (v1)
   - 01-ROADMAP-v2.md
   - 03-PRE_ACTIVATION_CHECKLIST.md (v1)
   - 03-PRE_ACTIVATION_CHECKLIST-v2.md
   - 02-PHASE-01-PLAN.md through 07-PHASE-06-PLAN.md (all v1 phase plans)

2. **Keep (this is the source of truth):**
   - 01-ROADMAP-FINAL.md (THIS DOCUMENT)
   - 02-CRITICAL_ISSUES_AUDIT.md (technical reference)
   - 08-SIMPLIFICATION_PLAN.md (Plan B reference)
   - orchestration/*.md (agent reviews for reference)

3. **Create:**
   - PLANNING_INDEX.md listing all current documents
   - Update DOCS/_INDEX.md with Phase 09 links

---

## Empirical Observations (Reference)

### Current State (Before Fixes)

**From 6-month backtest (2024-01-01 to 2024-06-30):**
| Metric | Value |
|--------|-------|
| Total Trades | 7 |
| Win Rate | 42.9% (3W/4L) |
| Net PnL | +$319 |
| Trade Frequency | ~1.2/month |

**Factor Scores (During Asian Session):**
```
structure=15.0, regime=0.0, ob=0.0, fvg=0.0, sweep=0.0, amd=0.0, fib=0.0, mtf=0.0, footprint=0.0
```

**Score Ranges by Session:**
| Session | Score Range | Threshold (35) | Result |
|---------|-------------|----------------|--------|
| Asian | 16-22 | Below | No trades (expected) |
| London Open | 30-40 | Borderline | Some trades |
| Overlap (Prime) | 44-52 | Above | Trades execute |
| NY Session | 35-48 | Above | Trades execute |

**Trade Clustering:** All 7 trades occurred Jan 2-10, 2024. ZERO trades after Jan 10.

### Root Causes Identified

1. **Semantic Collision:** `_mtf_order_blocks` overwritten by LTF data
2. **Trade Clustering:** Time-dependent bug (state reset? memory leak?)
3. **Footprint:** No futures data (dead code since day one)
4. **Session Adjustment:** Was killing scores (FIXED in commit 58b84178)

---

## Agent Responsibilities

| Phase | Lead Agent | Support Agents |
|-------|------------|----------------|
| 00 | FORGE | - |
| 01 | ORACLE | FORGE |
| 02 | ORACLE | CRUCIBLE |
| 03 | CRUCIBLE | ORACLE, FORGE |
| 04 | FORGE | SENTINEL |
| 05 | ORACLE | CRUCIBLE |
| 06 | FORGE | SENTINEL |
| 07 | SENTINEL | CRITIC |

**Handoff Chain (for trading logic):**
```
FORGE -> REVIEWER -> ORACLE -> SENTINEL
```

---

## Risk Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Semantic fix doesn't restore OB/FVG | MEDIUM | HIGH | Diagnostic logging before/after |
| Trade clustering is unsolvable | LOW | HIGH | Investigate state management |
| Fixed system still produces < 50 trades | MEDIUM | HIGH | Plan B (simplification) |
| SMC approach is fundamentally flawed | LOW | HIGH | Baseline comparison, fallback options |
| Timeline extends beyond 11 weeks | MEDIUM | MEDIUM | 50% buffer in estimates |

---

## Appendix: DAEMON Strategic Concerns

DAEMON raised economic rationality concerns:
- Expected value calculation: ~$11.67/hour at 300 hours invested
- SMC crowding: patterns widely known, edge may be arbitraged away
- Opportunity cost: alternative strategies may have better ROI

**User Decision:** Proceed anyway (learning value, Nautilus skills transfer)

**Hard Exit Gate Added:** If engineering hours > 400 with no progress, HARD PAUSE for strategic review.

---

## Appendix: CRITIC Key Findings

1. **Confirmation Bias:** Previous agents concluded "simplify" without testing fixed system
2. **Trade Clustering:** Noted but never investigated (may reveal different root cause)
3. **Counterfactual Missing:** "What if we fix bugs and keep 9 factors?" was never tested
4. **Archive vs Disable:** DISABLE preserves optionality; ARCHIVE causes code rot

**This roadmap addresses all CRITIC concerns by:**
- Testing fixed system BEFORE simplifying
- Investigating trade clustering in Phase 00
- Running counterfactual test in Phase 01
- Using DISABLE not ARCHIVE for components

---

*"A 9-factor confluence system where 8 factors score zero is BROKEN, not sophisticated. Fix the foundation before deciding to remove floors."*

---

**AGENT:** FORGE-NAUTILUS (acting as MASTER PLANNER)
**VERSION:** 1.1
**CLAUDE_MD_VERSION:** 3.10.21
**STATUS:** COMPLETE

---

*End of Roadmap*
