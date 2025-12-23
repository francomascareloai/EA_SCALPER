# PRE-ACTIVATION CHECKLIST - Phase 09

## Purpose
Comprehensive checklist of ALL tasks that must be completed before strategy activation.
Each item maps to detailed specs in `02-CRITICAL_ISSUES_AUDIT.md`.

---

## Status Legend
- ⬜ Not Started
- 🔄 In Progress
- ✅ Complete
- ⚠️ Blocked (waiting on decision/dependency)
- ❌ Failed (needs rework)

---

## WEEK 1: CRITICAL BLOCKERS

### Day 1-2: MTF \u0026 Semantic Collision (13 hours total)

#### MTF Manager Duplication (Category 1) - 6 hours
- ⬜ **MTF-001**: Add deprecation warning to `src/indicators/mtf_manager.py`
  - Edit file to add `warnings.warn()` at module level
  - Update docstring with deprecation notice
  - Est: 30 min

- ⬜ **MTF-002**: Create `tests/test_signals/test_mtf_manager.py`
  - Test bullish alignment detection
  - Test bearish alignment detection
  - Test ranging/no-alignment scenarios
  - Test premium/discount zone logic
  - Test BOS/CHoCH integration
  - Test regime blocking (random walk blocks trades)
  - Est: 3 hours

- ⬜ **MTF-003**: Validate strategy still works
  - Run unit tests (expect deprecation warnings)
  - Run integration test (strategy orchestration)
  - Run quick backtest (1 month) to ensure no regression
  - Est: 1 hour

- ⬜ **MTF-004**: Verify coverage increased
  - Run `pytest --cov=src/signals/mtf_manager`
  - Target: ≥70% line coverage for mtf_manager.py
  - Est: 30 min

- ⬜ **MTF-005**: Archive `src/indicators/mtf_manager.py`
  - Create `_archive/indicators/` directory
  - Move file with git history
  - Update any lingering imports (should be none after tests migrate)
  - Est: 1 hour

**Checkpoint 1**: Coverage increased, all tests pass, strategy works
**Blocking**: None (can start immediately)

---

#### Semantic Collision Fix (Category 2) - 7 hours

⚠️ **USER DECISION REQUIRED**: Which timeframe for scorer?
- [ ] **Option A**: MTF (M15) - SMC structural zones (RECOMMENDED)
- [ ] **Option B**: LTF (M5) - Precise entry timing
- [ ] **Option C**: Both (combined list)

**Once decided:**

- ⬜ **SEM-001**: Rename variables in `gold_scalper_strategy.py`
  - Change `_mtf_order_blocks` → `_htf_order_blocks`, `_mtf_order_blocks`, `_ltf_order_blocks`
  - Change `_mtf_fvgs` → `_htf_fvgs`, `_mtf_fvgs`, `_ltf_fvgs`
  - Update all references (declarations, usage, logging)
  - Est: 1 hour

- ⬜ **SEM-002**: Fix OB/FVG detection logic
  - Implement separate detection for HTF/MTF/LTF
  - Use `_htf_bars`, `_mtf_bars`, `_ltf_bars` correctly
  - Ensure no overwriting
  - Est: 2 hours

- ⬜ **SEM-003**: Update confluence scorer call
  - Pass correct timeframe OBs/FVGs based on decision
  - Update logging to show which timeframe is used
  - Est: 30 min

- ⬜ **SEM-004**: Run baseline backtest BEFORE fix
  - Full backtest (2003-2025) with current (buggy) code
  - Record: WFE, SQN, PF, trade count, max DD
  - Est: 1 hour

- ⬜ **SEM-005**: Run validation backtest AFTER fix
  - Same config, same data
  - Compare metrics (expect improvement)
  - Est: 1 hour

- ⬜ **SEM-006**: Document changes
  - Update BUGFIX_LOG.md
  - Update CHANGELOG.md
  - Create before/after comparison table
  - Est: 30 min

**Checkpoint 2**: Semantic collision fixed, metrics improved or stable
**Blocking**: User decision on timeframe

---

### Day 3-4: Test Coverage (12-18 hours)

#### Critical Path Tests (Category 4.A) - 12 hours

- ⬜ **COV-001**: Time Gates Tests (2 hours)
  - `test_time_gate_4_30_blocks_new_trades()`
  - `test_time_gate_4_55_emergency_close()`
  - `test_time_gate_4_59_hard_flatten()`
  - `test_timezone_et_vs_utc()`
  - `test_dst_transition()`
  - Est: 2 hours

- ⬜ **COV-002**: DD Breach Flatten Tests (2 hours)
  - `test_trailing_dd_4_5_triggers_flatten()`
  - `test_daily_dd_3_0_triggers_halt()`
  - `test_hwm_tracking_with_unrealized()`
  - `test_failsafe_latch_prevents_trading()`
  - `test_hwm_trap_scenario()` (unrealized profit raises floor)
  - Est: 2 hours

- ⬜ **COV-003**: Execution Failsafe Tests (2 hours)
  - `test_bracket_rejection_triggers_watchdog()`
  - `test_watchdog_flattens_naked_position()`
  - `test_order_lifecycle_tracking()`
  - `test_emergency_close_cancels_first()`
  - Est: 2 hours

- ⬜ **COV-004**: Confluence Scoring Tests (3 hours)
  - `test_all_9_factors_contribute()`
  - `test_ict_sequence_validation()` (regression for at_poi fix)
  - `test_session_specific_weights()`
  - `test_phase1_multipliers()` (alignment, freshness, divergence)
  - `test_score_threshold_65()`
  - Est: 3 hours

- ⬜ **COV-005**: MTF Integration Tests (3 hours)
  - `test_htf_mtf_ltf_bar_subscriptions()`
  - `test_alignment_detection()`
  - `test_regime_blocking()`
  - `test_premium_discount_logic()`
  - `test_mtf_score_calculation()`
  - Est: 3 hours

**Checkpoint 3**: Coverage ≥70% line / 50% branch
**Blocking**: MTF duplication fix (COV-005 depends on MTF-002)

---

### Day 5: Apex \u0026 Temporal (4 hours)

#### Apex Compliance (Category 6) - 3 hours

- ⬜ **APEX-001**: Timezone standardization audit
  - Grep for all `utcnow()`, `timezone.utc`, `GMT` references
  - List modules using UTC vs ET
  - Create standardization plan
  - Est: 1 hour

- ⬜ **APEX-002**: Implement timezone standardization
  - Change all daily boundaries to `America/New_York`
  - Add fail-safe degraded mode (4:20 PM block, 4:45 PM close)
  - Add ZoneInfo availability check at startup
  - Est: 1.5 hours

- ⬜ **APEX-003**: Add timezone edge case tests
  - `test_dst_transition_spring()` (2 AM → 3 AM)
  - `test_dst_transition_fall()` (2 AM → 1 AM)
  - `test_degraded_mode_times()`
  - Est: 30 min

#### Temporal Integrity (Category 3) - 1 hour

- ⬜ **TEMP-001**: Deprecate EA parity scripts
  - Add deprecation warnings to:
    - `ea_logic_full.py`
    - `ea_logic_python.py`
    - `ea_logic_compat.py`
  - Update docs: "Use main strategy for validation"
  - Est: 30 min

- ⬜ **TEMP-002**: Document validation approach
  - Update `VALIDATION.md`: "Don't use MC/WFA until refactored"
  - Document: "Use ORACLE backtest instead"
  - Est: 30 min

**Checkpoint 4**: All Apex gates validated, temporal integrity documented
**Blocking**: None

---

## WEEK 2: EDGE DISCOVERY \u0026 VALIDATION

### Day 6-8: Ablation Study (14 hours)

#### Design Phase (Category 7.A) - 2 hours

- ⬜ **ABL-001**: Create ablation config variants
  - Baseline (all 9 factors enabled)
  - Config 1: Disable Structure
  - Config 2: Disable Regime
  - Config 3: Disable OB
  - Config 4: Disable FVG
  - Config 5: Disable Sweep
  - Config 6: Disable AMD
  - Config 7: Disable Fib
  - Config 8: Disable MTF
  - Config 9: Disable Footprint
  - Store in `.planning/phases/09-strategy-activation/ablation/configs/`
  - Est: 1 hour

- ⬜ **ABL-002**: Design statistical analysis
  - Define metrics to track: WFE, SQN, PF, trade_count, max_DD
  - Define significance threshold: p < 0.05
  - Prepare spreadsheet template
  - Est: 1 hour

#### Execution Phase (Category 7.A) - 8 hours

- ⬜ **ABL-003**: Run baseline backtest
  - Full dataset (2003-2025)
  - All 9 factors enabled
  - Record baseline metrics
  - Est: 1 hour

- ⬜ **ABL-004**: Run ablation variants (parallel if possible)
  - Run configs 1-9 (each disables one factor)
  - Collect metrics for each
  - **Agent**: ORACLE (opus) × 9 (can run in parallel)
  - Est: 6 hours (1h each if sequential, 1h total if parallel)

- ⬜ **ABL-005**: Collect \u0026 compare results
  - Aggregate all metrics into spreadsheet
  - Calculate Δ (change from baseline)
  - Run t-test for statistical significance
  - Est: 1 hour

#### Analysis Phase (Category 7.A) - 3 hours

- ⬜ **ABL-006**: Identify non-contributing factors
  - Factors with Δ ≈ 0 (no impact)
  - Factors with NEGATIVE impact (make it worse!)
  - Factors with POSITIVE impact (keep these)
  - Est: 1 hour

- ⬜ **ABL-007**: Create simplification proposal
  - Recommend which factors to REMOVE
  - Recommend new weights for remaining factors
  - Target: 3-5 factors (down from 9)
  - Est: 1 hour

- ⬜ **ABL-008**: Document findings
  - Create `ABLATION_RESULTS.md`
  - Include metrics table, charts, recommendations
  - Store in `.planning/phases/09-strategy-activation/ablation/`
  - Est: 1 hour

**Checkpoint 5**: Evidence-based factor list (3-5 factors)
**Blocking**: Semantic collision fix (ABL needs correct OB/FVG data)

---

#### Simplification Phase (Category 7.B) - 6 hours

⚠️ **CHECKPOINT**: Get user approval on factors to remove before proceeding

- ⬜ **SIMP-001**: Remove non-contributing factors from `confluence_scorer.py`
  - Comment out factor scoring methods
  - Update weight allocation
  - Reduce total parameters
  - Est: 2 hours

- ⬜ **SIMP-002**: Update tests for simplified scorer
  - Adjust test expectations
  - Remove tests for deleted factors
  - Est: 1 hour

- ⬜ **SIMP-003**: Run validation backtest (simplified)
  - Same full dataset
  - Compare to baseline (expect same or better)
  - Est: 1 hour

- ⬜ **SIMP-004**: Document simplification
  - Update CHANGELOG.md
  - Update confluence_scorer.py docstring
  - Create migration guide (old → new scoring)
  - Est: 1 hour

- ⬜ **SIMP-005**: Update Phase 02 plan
  - Adjust SMC audit scope based on simplified factors
  - Update expected effort
  - Est: 1 hour

**Checkpoint 6**: Simplified scorer validated, performs same or better
**Blocking**: ABL-008 (need analysis results)

---

### Day 9-10: Documentation \u0026 Prep (6 hours)

#### Architecture Documentation (Category 8) - 4 hours

- ⬜ **DOC-001**: Create ARCHITECTURE.md
  - Strategy hierarchy diagram (mermaid)
  - StrategySelector decision tree (6 gates explained)
  - AdaptiveEVRouter arms \u0026 Thompson sampling
  - Signal generation flow (end-to-end)
  - Risk management layers (diagram)
  - Est: 3 hours

- ⬜ **DOC-002**: Auto-generate class hierarchy
  - Use LSP to extract class structure
  - Generate inheritance diagram
  - Keep synchronized with code (make target)
  - Est: 1 hour

#### Final Prep (Category 8) - 2 hours

- ⬜ **DOC-003**: Update 01-ROADMAP.md
  - Mark Week 1-2 tasks complete
  - Update status for Phase 02
  - Add findings summary
  - Est: 30 min

- ⬜ **DOC-004**: Create Phase 02 handoff document
  - Summary of Week 1-2 accomplishments
  - Updated blocker count (target: ≤10 CRITICAL)
  - Test coverage report
  - Ablation study executive summary
  - GO/NO-GO recommendation
  - Est: 1.5 hours

**Checkpoint 7**: Documentation complete, ready for Phase 02
**Blocking**: All Week 1-2 tasks

---

## WEEK 2 CHECKPOINT: Pre-Phase-02 GO/NO-GO

### Criteria

| Criterion | Target | Status | Evidence |
|-----------|--------|--------|----------|
| MTF duplication resolved | ✅ | ⬜ | MTF-005 complete |
| Semantic collision fixed | ✅ | ⬜ | SEM-006 complete |
| Test coverage ≥70% line | ✅ | ⬜ | COV-005 complete |
| Test coverage ≥50% branch | ✅ | ⬜ | COV-005 complete |
| Apex compliance verified | ✅ | ⬜ | APEX-003 complete |
| Ablation study complete | ✅ | ⬜ | ABL-008 complete |
| Simplification complete | ✅ | ⬜ | SIMP-005 complete |
| CRITICAL issues ≤10 | ✅ | ⬜ | Updated ISSUES_TRACKER.md |
| Documentation complete | ✅ | ⬜ | DOC-004 complete |

### Verdict

**Current**: ❌ NO-GO (not started)

**After Week 1-2**: ___ (update based on checklist completion)

**Next Steps**: If GO → Proceed to Phase 02 SMC Deep Audit

---

## USER DECISIONS REQUIRED (Block Week 1 Start)

Before starting Week 1, Franco must decide:

### ⚠️ Decision 1: Semantic Collision - OB/FVG Timeframe
**Question**: Which timeframe should confluence scorer use?

- [ ] **Option A (RECOMMENDED)**: MTF (M15) - SMC structural zones
  - Aligns with SMC philosophy (M15 = structure)
  - More reliable, less noise
  - **Recommendation**: Choose this

- [ ] **Option B**: LTF (M5) - Precise entry timing
  - More granular
  - More noise, less reliable

- [ ] **Option C**: Both (combined list)
  - Maximum information
  - More complex, risk of conflicts

**Required for**: SEM-001 (Day 1-2)

---

### ⚠️ Decision 2: Execution Adapters (Optional - can defer)
**Question**: Using MT5/Ninja adapters in production?

- [ ] **YES** → Fix adapters (6-8 hours, add to backlog)
- [ ] **NO** → Archive adapters (1 hour, add to Day 5)

**Impact**: Not blocking Week 1-2 (Nautilus execution works)

---

### ⚠️ Decision 3: TradeManager (Optional - can defer)
**Question**: Want partial TP / trailing stops?

- [ ] **YES** → Integrate TradeManager (4-6 hours, Phase 02+)
- [ ] **NO** → Archive TradeManager (1 hour, add to Day 5)

**Impact**: Not blocking Week 1-2

---

### ⚠️ Decision 4: Mean Revert Strategy (Optional - Phase 04)
**Question**: Implement, remove, or defer STRATEGY_MEAN_REVERT?

- [ ] **Implement** → Create mean_revert.py (Phase 04)
- [ ] **Remove** → Delete enum (Phase 01)
- [ ] **Defer** → Return SMC when selected (Phase 04)

**Impact**: Not blocking Week 1-2

---

## SUMMARY \u0026 NEXT STEPS

**Total Effort**: ~40-50 hours (Week 1-2)
**Critical Path**: MTF → Semantic → Coverage → Ablation
**Blocking Decisions**: Decision 1 (Semantic Collision) MUST be made before Day 1

**Once Decision 1 is made**:
1. Start MTF-001 (Week 1, Day 1)
2. Follow checklist sequentially
3. Check off items as completed
4. Report blockers immediately
5. Checkpoint after each day

**Success Metric**: All GO/NO-GO criteria ✅ before Phase 02

---

## TRACKING

**Started**: ___ (date)
**Week 1 Complete**: ___ (date)
**Week 2 Complete**: ___ (date)
**GO/NO-GO Decision**: ___ (date)

**Items Complete**: 0 / 46
**Progress**: 0%

---

*Update this checklist daily with status changes*
