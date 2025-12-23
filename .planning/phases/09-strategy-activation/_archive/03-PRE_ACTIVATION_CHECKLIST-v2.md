# PRE-ACTIVATION CHECKLIST v2.0 - Phase 09

## Version History

| Version | Date | Changes |
|---------|------|---------|
| v2.0 | 2025-12-23 | **MAJOR UPDATE**: Incorporated feedback from 7 agent reviews (FORGE, CRUCIBLE, ORACLE, SENTINEL, ARGUS x3). See Change Summary below. |
| v1.0 | 2025-12-23 | Initial checklist with 46 tasks across 2 weeks |

## Change Summary (v1.0 -> v2.0)

### FORGE Review (Implementation)
- [x] Fixed ALL file paths - added `nautilus_gold_scalper/` prefix
- [x] Added Pre-Phase 00 task to create `_archive/legacy/` directory FIRST
- [x] Added handling for footprint test files before archiving source
- [x] Removed duplicate tasks between Phase 00 and Phase 01
- [x] Added git branching strategy
- [x] Increased time estimates by 50% (2 weeks -> 3 weeks)

### CRUCIBLE Review (Strategy)
- [x] Added Pre-Phase 00 baseline test (EMA 20/50)
- [x] Added diagnostic logging BEFORE ablation
- [x] Added decision gate after ablation with "abandon SMC" criteria
- [x] Added minimum 200 trades requirement for all GO/NO-GO decisions
- [x] Reordered tasks: semantic collision -> diagnostic logging -> ablation

### ORACLE Review (Validation)
- [x] Reserved 2020-2025 as TRUE holdout (ablation on 2003-2019 ONLY)
- [x] Added DSR >= 0.80 as GO/NO-GO criterion
- [x] Specified MC methodology: 5000 runs, block bootstrap
- [x] Added PBO < 25% threshold
- [x] Added 12 rolling windows for WFA specification

### SENTINEL Review (Risk & Apex Compliance)
- [x] Added Paper Trading Phase (2 weeks) BEFORE production GO
- [x] Added broker-side SL verification task
- [x] Added HWM calculation verification (BID for LONG, ASK for SHORT)
- [x] Added circuit breaker graduated response tests
- [x] Added emergency close protocol tests with retry logic

### ARGUS 1 (Multi-Strategy Research)
- [x] Added task to archive AdaptiveEVRouter (insufficient trade frequency)
- [x] Added task to simplify StrategySelector to regime filter + session gate
- [x] Updated architecture for single strategy focus first

### ARGUS 2 (SMC/Gold Research)
- [x] Added task to reduce confluence factors from 9 to 3-4
- [x] Updated session optimization to focus on London-NY overlap
- [x] Added task to remove/archive MEAN_REVERT strategy

### ARGUS 3 (Validation Research)
- [x] Updated DSR threshold to >= 0.80
- [x] Added CPCV recommendation for cross-validation
- [x] Added trial tracking notes for DSR validity

---

## Purpose

Comprehensive checklist of ALL tasks that must be completed before strategy activation.
Each item maps to detailed specs in `02-CRITICAL_ISSUES_AUDIT.md`.

**Key Changes in v2:** This checklist now spans **3 weeks** (up from 2) with additional Pre-Phase 00 setup tasks and a mandatory Paper Trading phase before any production GO decision.

---

## Status Legend
- [ ] Not Started
- [~] In Progress
- [x] Complete
- [!] Blocked (waiting on decision/dependency)
- [-] Failed (needs rework)

---

## USER DECISIONS REQUIRED (Block Phase 00 Start)

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

**Impact:** Blocks SEM-001 task (Day 1-2). Must decide before starting.

### Decision 2-4: Optional (Can Defer)
- **Decision 2:** MT5/Ninja adapters (YES fix / NO archive) - Not blocking
- **Decision 3:** TradeManager integration (YES integrate / NO archive) - Not blocking
- **Decision 4:** STRATEGY_MEAN_REVERT - **RECOMMENDED: REMOVE** (gold trends, doesn't mean-revert per ARGUS research)

---

## PRE-PHASE 00: Baseline & Setup (BEFORE Week 1)

**Objective:** Establish baseline, prepare infrastructure, and validate approach before investing in fixes.

**Time Estimate:** 8-10 hours (1 day)

### Infrastructure Setup

- [ ] **SETUP-001**: Create archive directory structure
  - Create `nautilus_gold_scalper/_archive/legacy/`
  - Create `nautilus_gold_scalper/_archive/indicators/`
  - Create `nautilus_gold_scalper/_archive/execution/`
  - Create `nautilus_gold_scalper/_archive/tests/`
  - Est: 15 min

- [ ] **SETUP-002**: Git branching strategy
  - Create branch: `phase-00/pre-activation-sprint`
  - Document commit strategy: checkpoint after each major task
  - Set up branch protection on main
  - Est: 30 min

- [ ] **SETUP-003**: Verify file paths in planning docs
  - Confirm all paths use `nautilus_gold_scalper/` prefix
  - Update any remaining incorrect paths
  - Est: 15 min

### Simple Baseline Test (CRITICAL - per CRUCIBLE)

- [ ] **BASELINE-001**: Create simple EMA baseline strategy
  - Create `nautilus_gold_scalper/src/strategies/ema_baseline.py`
  - Implement EMA 20/50 crossover
  - Apply same session filter (London-NY overlap only)
  - Apply same Apex risk management (trailing DD, time gates)
  - **Purpose:** This is the BAR that SMC must clear to justify complexity
  - Est: 2 hours

- [ ] **BASELINE-002**: Run baseline backtest (2003-2019)
  - Run on train dataset ONLY (holdout is 2020-2025)
  - Record metrics: trades, WFE, SQN, PF, max_DD
  - Target: 200+ trades minimum
  - Est: 1 hour

- [ ] **BASELINE-003**: Document baseline results
  - Create `.planning/phases/09-strategy-activation/baseline/BASELINE_RESULTS.md`
  - Record all metrics as comparison benchmark
  - Est: 30 min

**Pre-Phase 00 Checkpoint:** Archive directories created, git branch ready, baseline results documented.

---

## WEEK 1: CRITICAL FIXES (Days 1-5)

### Day 1-2: Semantic Collision Fix (10 hours)

**Blocking:** Requires Decision 1 (OB/FVG Timeframe)

- [ ] **SEM-001**: Rename variables in gold_scalper_strategy.py
  - File: `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
  - Change `_mtf_order_blocks` -> `_htf_order_blocks`, `_mtf_order_blocks`, `_ltf_order_blocks`
  - Change `_mtf_fvgs` -> `_htf_fvgs`, `_mtf_fvgs`, `_ltf_fvgs`
  - Update all references (declarations, usage, logging)
  - Est: 1.5 hours

- [ ] **SEM-002**: Fix OB/FVG detection logic
  - File: `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py`
  - Implement separate detection for HTF/MTF/LTF
  - Use `_htf_bars`, `_mtf_bars`, `_ltf_bars` correctly
  - Ensure no overwriting between timeframes
  - Est: 3 hours

- [ ] **SEM-003**: Update confluence scorer call
  - File: `nautilus_gold_scalper/src/signals/confluence_scorer.py`
  - Pass correct timeframe OBs/FVGs based on Decision 1
  - Update logging to show which timeframe is used
  - Est: 1 hour

- [ ] **SEM-004**: Run validation backtest AFTER fix
  - Full backtest (2003-2019 train set only)
  - Compare to baseline results
  - Check if OB/FVG factors now score > 0
  - Est: 1.5 hours

- [ ] **SEM-005**: Document changes
  - Update `nautilus_gold_scalper/BUGFIX_LOG.md`
  - Update `CHANGELOG.md`
  - Create before/after comparison table
  - Est: 1 hour

- [ ] **SEM-006**: Commit checkpoint
  - `git commit -m "fix(strategy): semantic collision - separate HTF/MTF/LTF OB/FVG"`
  - Est: 15 min

**Day 1-2 Checkpoint:** Semantic collision fixed, OB/FVG factors scoring > 0

---

### Day 2-3: Diagnostic Logging (NEW - per CRUCIBLE) (4 hours)

- [ ] **DIAG-001**: Add per-bar factor logging
  - File: `nautilus_gold_scalper/src/signals/confluence_scorer.py`
  - Log every factor's raw score on each bar (debug level)
  - Format: `factor=X, raw_score=Y, weighted=Z`
  - Est: 1.5 hours

- [ ] **DIAG-002**: Run 1-month diagnostic backtest
  - Enable debug logging
  - Use July 2024 (recent, high volatility month)
  - Capture full factor activation logs
  - Est: 1 hour

- [ ] **DIAG-003**: Analyze factor activation rates
  - Parse logs to count: how often does each factor fire?
  - Create activation rate table:
    | Factor | Bars Analyzed | Times Fired | Activation Rate |
  - Identify factors that NEVER or RARELY fire
  - Est: 1.5 hours

**Day 2-3 Checkpoint:** Factor activation rates documented, dead factors identified

---

### Day 3-4: Factor Reduction (per ARGUS) (8 hours)

**Objective:** Reduce from 9 factors to 3-4 based on evidence

**KEEP (evidence supports):**
1. Structure (BOS/CHoCH) - WORKING
2. Order Blocks - FIX semantic collision (done in SEM-xxx)
3. FVG - FIX semantic collision (done in SEM-xxx)
4. Session Filter - WORKING

**ARCHIVE (per ARGUS research):**
5. MTF alignment - redundant with session
6. AMD (Accumulation/Manipulation/Distribution) - low activation
7. Fibonacci - low activation
8. Footprint - NO DATA (no futures data)
9. Liquidity Sweep - low activation

- [ ] **FACTOR-001**: Archive footprint analyzer + tests
  - Move `nautilus_gold_scalper/src/indicators/footprint_analyzer.py` -> `_archive/indicators/`
  - Move `nautilus_gold_scalper/tests/test_indicators/test_footprint_analyzer.py` -> `_archive/tests/`
  - Move `nautilus_gold_scalper/tests/test_indicators/test_footprint_analyzer_signal.py` -> `_archive/tests/`
  - Move `nautilus_gold_scalper/tests/test_indicators/test_footprint_configurable.py` -> `_archive/tests/`
  - Update imports if any remain
  - Est: 1 hour

- [ ] **FACTOR-002**: Archive legacy MTF manager
  - Move `nautilus_gold_scalper/src/indicators/mtf_manager.py` -> `_archive/indicators/`
  - Move `nautilus_gold_scalper/tests/test_indicators/test_mtf_manager.py` -> `_archive/tests/`
  - Verify `nautilus_gold_scalper/src/signals/mtf_manager.py` is canonical
  - Est: 45 min

- [ ] **FACTOR-003**: Disable non-contributing factors in scorer
  - File: `nautilus_gold_scalper/src/signals/confluence_scorer.py`
  - Set weights to 0 for: AMD, Fib, MTF_alignment, Sweep
  - Keep: Structure, OB, FVG, Session
  - Add config flag `use_simplified_scoring: bool = True`
  - Est: 2 hours

- [ ] **FACTOR-004**: Simplify regime detection (per ARGUS)
  - Current: Complex Hurst/entropy (scores 0.0)
  - Replace with simple ADX-based trending detection
  - Simpler, more robust, less computationally expensive
  - Est: 2 hours

- [ ] **FACTOR-005**: Update tests for simplified scorer
  - Adjust test expectations for 4 factors instead of 9
  - Remove/archive tests for deleted factors
  - Est: 1.5 hours

- [ ] **FACTOR-006**: Commit checkpoint
  - `git commit -m "refactor(scorer): reduce from 9 to 4 confluence factors"`
  - Est: 15 min

**Day 3-4 Checkpoint:** Simplified to 4 factors, tests passing

---

### Day 4: Architecture Simplification (per ARGUS) (4 hours)

- [ ] **ARCH-001**: Archive AdaptiveEVRouter
  - **Rationale:** Thompson sampling requires O(ln(T)) samples to converge. With ~7 trades in 6 months, the algorithm is permanently in cold-start mode and cannot learn.
  - Move `nautilus_gold_scalper/src/execution/adaptive_router.py` -> `_archive/execution/`
  - Move related tests if any
  - Est: 45 min

- [ ] **ARCH-002**: Simplify StrategySelector
  - Current: 6 gates for strategy selection
  - Simplify to: regime filter (ADX) + session gate
  - Keep only single strategy path for now
  - Re-introduce complexity ONLY when trade frequency exceeds 200/year
  - Est: 2 hours

- [ ] **ARCH-003**: Remove/archive MEAN_REVERT option
  - **Rationale (per ARGUS):** Gold trends, doesn't mean-revert at M5. Academic evidence shows momentum significantly outperforms mean reversion for gold.
  - Archive or remove `STRATEGY_MEAN_REVERT` enum path
  - Update StrategySelector to not return it
  - Est: 45 min

- [ ] **ARCH-004**: Commit checkpoint
  - `git commit -m "refactor(arch): simplify to single strategy + regime filter"`
  - Est: 15 min

**Day 4 Checkpoint:** Architecture simplified for current trade frequency

---

### Day 5: Apex Compliance & Test Coverage (8 hours)

#### Apex Compliance Tests (per SENTINEL)

- [ ] **APEX-001**: Timezone standardization audit
  - Grep for all `utcnow()`, `timezone.utc`, `GMT` references in `nautilus_gold_scalper/`
  - List modules using UTC vs ET
  - Create standardization plan
  - Est: 1 hour

- [ ] **APEX-002**: Implement timezone standardization
  - Change all daily boundaries to `America/New_York`
  - Add fail-safe degraded mode (4:20 PM block, 4:45 PM close)
  - Add ZoneInfo availability check at startup
  - Est: 1.5 hours

- [ ] **APEX-003**: Add HWM calculation verification tests (CRITICAL)
  - **Per SENTINEL:** HWM must use conservative prices
  - Test BID price for LONG unrealized PnL
  - Test ASK price for SHORT unrealized PnL
  - Test MID price is NEVER used
  - Test HWM monotonic increase intraday
  - Test HWM EOD reset
  - File: `nautilus_gold_scalper/tests/test_risk/test_hwm_calculation.py`
  - Est: 2 hours

- [ ] **APEX-004**: Add circuit breaker level tests (per SENTINEL)
  - Test Level 0 (NORMAL): < 3% DD, 100% size
  - Test Level 1 (WARNING): 3-3.5% DD, 100% size, close by 4:30 PM
  - Test Level 2 (CAUTION): 3.5-4% DD, 50% size, close by 4:00 PM
  - Test Level 3 (SOFT STOP): 4-4.5% DD, 0% size, no new trades
  - Test Level 4 (EMERGENCY): >= 4.5% DD, close all immediately
  - File: `nautilus_gold_scalper/tests/test_risk/test_circuit_breakers.py`
  - Est: 2 hours

- [ ] **APEX-005**: Add broker-side SL verification task (per SENTINEL)
  - Document broker-side backstop procedures
  - Create verification checklist for live deployment
  - File: `.planning/phases/09-strategy-activation/BROKER_SL_VERIFICATION.md`
  - Est: 45 min

- [ ] **APEX-006**: Commit checkpoint
  - `git commit -m "feat(apex): HWM and circuit breaker tests"`
  - Est: 15 min

**Week 1 Checkpoint:** Critical fixes complete, tests passing, architecture simplified

---

## WEEK 2: VALIDATION (Days 6-10)

### Day 6-7: Ablation Study (10 hours)

**CRITICAL:** Run ablation on 2003-2019 ONLY. Reserve 2020-2025 as TRUE holdout.

- [ ] **ABL-001**: Create ablation config variants
  - Store in `.planning/phases/09-strategy-activation/ablation/configs/`
  - Baseline (all 4 remaining factors enabled)
  - Config 1: Disable Structure
  - Config 2: Disable OB
  - Config 3: Disable FVG
  - Config 4: Disable Session
  - Config 5: Random entry baseline (same risk management)
  - Est: 1 hour

- [ ] **ABL-002**: Design statistical analysis
  - Define metrics: WFE, SQN, PF, trade_count, max_DD, DSR
  - Define significance threshold: p < 0.05
  - Specify: 5000 MC runs, block bootstrap (block size = avg trade duration)
  - Prepare spreadsheet template
  - Est: 1 hour

- [ ] **ABL-003**: Run baseline backtest (2003-2019)
  - All 4 factors enabled
  - Record baseline metrics
  - Verify minimum 200 trades (if not, threshold issue)
  - Est: 1.5 hours

- [ ] **ABL-004**: Run ablation variants
  - Run configs 1-5 on 2003-2019 dataset
  - Collect metrics for each
  - Est: 4 hours (can parallelize if resources allow)

- [ ] **ABL-005**: Collect & compare results
  - Aggregate all metrics into spreadsheet
  - Calculate Delta (change from baseline)
  - Run t-test for statistical significance
  - Est: 1.5 hours

- [ ] **ABL-006**: Identify factor contributions
  - Factors with Delta >= 0 (no impact or negative): candidate for removal
  - Factors with POSITIVE impact (make it worse when removed): KEEP
  - Document which factors are truly contributing
  - Est: 1 hour

**Day 6-7 Checkpoint:** Ablation results documented, factor contributions identified

---

### Day 8: Decision Gate (per CRUCIBLE) (2 hours)

**CRITICAL:** This is the "abandon SMC" checkpoint

- [ ] **GATE-001**: Compare SMC to baseline
  - IF SMC (all factors) > EMA baseline by > 10%: PROCEED with SMC
  - IF SMC <= EMA baseline: STOP SMC development, focus on TrendFollow
  - IF structure alone provides 90%+ of edge: SIMPLIFY to structure + session only
  - Est: 1 hour

- [ ] **GATE-002**: Document decision
  - File: `.planning/phases/09-strategy-activation/GATE_DECISION.md`
  - Record: comparison table, decision made, rationale
  - Est: 1 hour

**Day 8 Checkpoint:** GO/NO-GO decision on SMC approach documented

---

### Day 8-9: Simplification Implementation (if SMC GO) (6 hours)

**Skip if GATE-001 decided to abandon SMC**

- [ ] **SIMP-001**: Remove non-contributing factors permanently
  - Based on ABL-006 findings
  - Remove factor code from confluence_scorer.py
  - Update weight allocation
  - Est: 2 hours

- [ ] **SIMP-002**: Run final validation backtest (2003-2019)
  - Simplified system
  - Compare to ablation baseline (expect same or better)
  - Est: 1.5 hours

- [ ] **SIMP-003**: Run TRUE holdout validation (2020-2025)
  - **FIRST TIME touching holdout data**
  - Record: WFE, SQN, PSR, DSR, MC95DD, trade count
  - This is the REAL performance estimate
  - Est: 1.5 hours

- [ ] **SIMP-004**: Document simplification
  - Update CHANGELOG.md
  - Update confluence_scorer.py docstring
  - Create migration guide (old -> new scoring)
  - Est: 1 hour

**Day 8-9 Checkpoint:** Simplified system validated on holdout

---

### Day 9-10: Documentation & Final Prep (6 hours)

- [ ] **DOC-001**: Create ARCHITECTURE.md
  - File: `nautilus_gold_scalper/ARCHITECTURE.md`
  - Strategy hierarchy diagram (mermaid)
  - Signal generation flow (end-to-end)
  - Risk management layers (diagram)
  - Simplified StrategySelector decision tree
  - Est: 3 hours

- [ ] **DOC-002**: Update ROADMAP.md with findings
  - Mark Week 1-2 tasks complete
  - Update status for subsequent phases
  - Add ablation findings summary
  - Est: 1 hour

- [ ] **DOC-003**: Create Phase 00 completion report
  - Summary of Week 1-2 accomplishments
  - Ablation study executive summary
  - GATE decision documentation
  - Updated blocker count (target: <= 10 CRITICAL)
  - Test coverage report
  - Ready for Phase 01 or Paper Trading?
  - Est: 2 hours

**Week 2 Checkpoint:** Documentation complete, ready for paper trading phase

---

## WEEK 3+: PAPER TRADING PHASE (MANDATORY per CLAUDE.md)

**Per SENTINEL review:** CLAUDE.md production_workflow mandates "Phase 2: Paper Trading - Minimum 2 weeks with live data feed" BEFORE any production GO decision.

### Paper Trading Requirements

- [ ] **PAPER-001**: Set up paper trading environment
  - Connect to live data feed (not backtest replay)
  - Enable all logging
  - Configure real-time HWM and DD tracking
  - Est: 4 hours

- [ ] **PAPER-002**: Run 2-week paper trading session
  - No real money at risk
  - Track all trades, entries, exits
  - Observe slippage between expected and simulated fills
  - Duration: 10 trading days minimum
  - Est: 2 weeks (monitoring, not coding)

- [ ] **PAPER-003**: Verify time gates in real-time
  - Confirm 4:30 PM ET block works correctly
  - Confirm 4:55 PM ET emergency close triggers
  - Confirm 4:59 PM ET hard flatten works
  - Test at least one DST transition if timing allows
  - Est: Ongoing verification

- [ ] **PAPER-004**: Verify HWM/DD tracking accuracy
  - Compare paper trading HWM to manual calculation
  - Verify unrealized PnL uses correct prices (BID/ASK not MID)
  - Verify circuit breaker levels trigger at correct thresholds
  - Est: Ongoing verification

- [ ] **PAPER-005**: Document paper trading results
  - File: `.planning/phases/09-strategy-activation/PAPER_TRADING_RESULTS.md`
  - Record: trade count, P/L, slippage observed, any issues
  - Est: 2 hours

**Paper Trading Checkpoint:** 2 weeks complete with no critical issues

---

## FINAL GO/NO-GO CRITERIA (Updated per all reviews)

### Validation Metrics (per ORACLE)

| Metric | Threshold | Validation Method | Required |
|--------|-----------|-------------------|----------|
| WFE | >= 0.6 | 12 rolling windows (2yr IS, 6mo OOS) | YES |
| SQN | >= 2.0 | All OOS periods | YES |
| PSR | >= 0.85 | Annualized | YES |
| **DSR** | **>= 0.80** | Bailey-Lopez de Prado formula | **YES (NEW)** |
| **PBO** | **< 25%** | CSCV cross-validation | **YES (NEW)** |
| MC95DD | < 4% | 5000 runs, block bootstrap | YES |
| Min Trades | >= 200 | Across all OOS periods | YES |
| Holdout Performance | >= 80% of train | 2020-2025 holdout | YES |

### Apex Compliance (per SENTINEL)

| Criterion | Target | Validation | Required |
|-----------|--------|------------|----------|
| Time gates verified | All pass | Real-time (paper trading) | YES |
| HWM uses BID/ASK | Verified | Unit tests | YES |
| Circuit breakers | All 5 levels pass | Unit tests | YES |
| Emergency close protocol | Verified | Integration test | YES |
| Broker-side SL | Documented | Verification checklist | YES |
| Paper trading | 2 weeks | No critical issues | YES |

### Implementation Quality (per FORGE)

| Criterion | Target | Current | Required |
|-----------|--------|---------|----------|
| Test coverage (line) | >= 70% | ~52% | YES |
| Test coverage (branch) | >= 50% | ~29% | YES |
| mypy --strict | Pass | ? | YES |
| pytest | All pass | ? | YES |
| CRITICAL issues | <= 10 | 34 | YES |

### Strategy Validation (per CRUCIBLE/ARGUS)

| Criterion | Target | Validation | Required |
|-----------|--------|------------|----------|
| SMC > EMA baseline | >= 10% improvement | Ablation comparison | YES |
| Trade frequency | >= 200/year | OOS validation | YES |
| Factor count | 3-4 | Simplified scorer | YES |
| Architecture | Single strategy | Simplified selector | YES |

---

## Summary & Timeline

**Total Effort (with 50% buffer per FORGE):**
- Pre-Phase 00: 8-10 hours (1 day)
- Week 1: 34 hours (5 days)
- Week 2: 24 hours (5 days)
- Week 3+: Paper trading (2 weeks, monitoring)

**Total Timeline:** 3 weeks coding + 2 weeks paper trading = **5 weeks to production GO decision**

**Critical Path:**
```
USER DECISION 1 (Semantic Collision)
    |
Pre-Phase 00: Baseline + Setup (1 day)
    |
Week 1: Semantic Fix -> Diagnostic -> Factor Reduction -> Apex Tests
    |
Week 2: Ablation (2003-2019 only) -> GATE Decision -> Simplification -> Docs
    |
Week 3+: Paper Trading (2 weeks, MANDATORY)
    |
FINAL GO/NO-GO (All criteria must pass)
```

---

## Tracking

**Started:** ___ (date)
**Pre-Phase 00 Complete:** ___ (date)
**Week 1 Complete:** ___ (date)
**Week 2 Complete:** ___ (date)
**Paper Trading Complete:** ___ (date)
**GO/NO-GO Decision:** ___ (date)

**Items Complete:** 0 / 52
**Progress:** 0%

---

## Agent Review Summary

| Agent | Verdict | Key Additions |
|-------|---------|---------------|
| FORGE | CONDITIONAL | File paths fixed, 50% time buffer, git strategy |
| CRUCIBLE | CONDITIONAL | Baseline test, diagnostic logging, abandon criteria |
| ORACLE | CONDITIONAL | Holdout period, DSR >= 0.80, MC 5000 runs, PBO < 25% |
| SENTINEL | BLOCKED -> CONDITIONAL | Paper trading, HWM tests, circuit breakers, broker SL |
| ARGUS (Multi-Strategy) | N/A | Archive AdaptiveEVRouter, single strategy focus |
| ARGUS (SMC/Gold) | N/A | 4 factors max, remove mean revert, session focus |
| ARGUS (Validation) | N/A | DSR >= 0.80, CPCV, trial tracking |

**All feedback incorporated into this v2 checklist.**

---

*Update this checklist daily with status changes*

---

```
AGENT: FORGE-NAUTILUS
VERSION: 1.1
CLAUDE_MD_VERSION: 3.10.21
STATUS: COMPLETE
```
