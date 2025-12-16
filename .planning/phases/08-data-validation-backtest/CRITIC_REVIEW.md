# CRITIC ADVERSARIAL REVIEW

**Artifact**: Data Validation & Backtesting Pipeline
**Type**: Plan (8 phases, 30+ agents)
**Reviewer**: CRITIC v1.1
**Review Date**: 2025-12-15
**Plan Location**: `.planning/phases/08-data-validation-backtest/`

---

## SEVERITY SUMMARY

| Severity | Count |
|----------|-------|
| CRITICAL | 4 issues |
| HIGH | 6 issues |
| MEDIUM | 4 issues |
| LOW | 3 issues |

---

## CRITICAL ISSUES (must fix before execution)

### 1. Apex Time Zone Calculation Error

**Location**: `03-PHASE-PLAN.md`, lines 242-247

**Current (WRONG)**:
```
| Apex Rule | ET Time | UTC (Summer) | UTC (Winter) |
|-----------|---------|--------------|--------------|
| Block new trades | 4:30 PM | 20:30 | 21:30 |
| Emergency close start | 4:55 PM | 20:55 | 21:55 |
| Force close deadline | 4:59 PM | 20:59 | 21:59 |
```

**Analysis**: The plan states "4:30 PM ET = 21:30 UTC (summer) / 22:30 UTC (winter)" in the task descriptions. This is **1 hour off**.

**Correct Values**:
- Summer (EDT = UTC-4): 4:30 PM EDT = **20:30 UTC**
- Winter (EST = UTC-5): 4:30 PM EST = **21:30 UTC**

The table header appears correct but the task prompts in 3.5 and 3.6 contain the error.

**Impact**: Session validation agents could validate incorrect time boundaries, allowing trades that violate Apex rules to slip through validation. This is a compliance risk with real money consequences.

**Fix**:
1. Update task 3.5 prompt: "4:30 PM ET = 20:30 UTC summer" (currently says 21:30)
2. Update task 3.6 prompt: "4:55-4:59 PM ET = 20:55-20:59 UTC summer" (currently says 21:55-21:59)
3. Add explicit DST handling note

---

### 2. Race Condition in Phase 4 Cleanup

**Location**: `04-PHASE-PLAN.md`, Orchestration section

**Issue**: Task 4.3 (Redundant Data Cleanup) runs in **parallel** with Task 4.1 (Cross-Catalog Consistency) and Task 4.2 (Metadata Audit).

**Current Design**:
```
Task[4.1 Cross-Catalog] || Task[4.2 Metadata] || Task[4.3 Cleanup]
```

**Problem**: Task 4.3 can **delete files before validation confirms they are redundant**. The safety protocol states:
> "DO NOT delete anything until Phase 2 and 3 are PASS"

But it does NOT require waiting for 4.1 and 4.2 within the same phase.

**Impact**:
- Files could be deleted before consistency check completes
- If cleanup runs faster than validation, deleted files cannot be verified
- Potential data loss with no recovery

**Fix**:
```
# Sequential execution required:
Task[4.1] -> Task[4.2] -> Task[4.3]
# Or with parallel validation, sequential cleanup:
(Task[4.1] || Task[4.2]) -> Task[4.3]
```

Add explicit gate: "Task 4.3 BLOCKED until 4.1 AND 4.2 return PASS status"

---

### 3. Phase 6 Scope Creep - Building New Infrastructure

**Location**: `06-PHASE-PLAN.md`, Task 6.1

**Issue**: This is supposed to be a "Data Validation & Backtesting" plan, but Phase 6 requires **building** an "institutional-grade event-driven backtest engine" from scratch.

**From Task 6.1**:
> "Implement institutional-grade event-driven backtest engine"
> "Create nautilus_gold_scalper/backtest/event_engine.py"
> "Create nautilus_gold_scalper/backtest/execution_models.py"
> "Create nautilus_gold_scalper/backtest/metrics.py"

**Analysis**: This is **weeks of development work**, not validation. The plan estimates "3 agents sequential" but building a proper event-driven engine with:
- Realistic execution models
- Position management
- Apex compliance
- Metrics collection

...requires extensive coding, testing, and debugging.

**Impact**:
- Phase 6 will take far longer than estimated
- Phase 7 is completely blocked on Phase 6
- Entire plan timeline is unrealistic
- If engine has bugs, all backtest results are invalid

**Fix Options**:
1. **Use existing infrastructure**: Reference `nautilus_gold_scalper/scripts/run_backtest.py` and `BacktestEngine` from NautilusTrader as the foundation
2. **Split into separate project**: Make Phase 6 a prerequisite project with its own timeline
3. **Reduce scope**: Validate existing backtest capability rather than building new

---

### 4. Strategy Reference Missing

**Location**: All of `06-PHASE-PLAN.md` and `07-PHASE-PLAN.md`

**Issue**: The plan validates data and builds backtest infrastructure but **never explicitly references which trading strategy will be backtested**.

Phase 7 tasks reference "the strategy" generically but don't specify:
- Strategy class name
- Strategy location (file path)
- Strategy configuration/parameters
- Strategy readiness status

**Evidence**: Files exist (`nautilus_gold_scalper/src/strategies/strategy_selector.py`) but plan doesn't reference them.

**Impact**:
- Agents won't know what strategy to load
- Backtest results depend on undefined strategy
- Configuration drift between agents possible

**Fix**:
1. Add to Phase 6 prerequisites: "Strategy code location: `nautilus_gold_scalper/src/strategies/`"
2. Specify strategy class and configuration in Phase 7 prompts
3. Add strategy validation step to Phase 6 (compiles, no obvious look-ahead)

---

## HIGH ISSUES (should fix)

### 5. Parallelism Too Aggressive

**Location**: `PLAN.md`, `00-BRIEF.md`

**Issue**: Plan claims "Unlimited parallelism (user confirmed capacity)" with 30+ agents across phases. CLAUDE.md explicitly warns:
> "Limit fan-out: 2-3 sub-agents per round"

**Contradiction**: The plan overrides safety defaults without acknowledging risks:
- Phase 2: 8 parallel Opus agents
- Phase 3: 6 parallel Opus agents
- Phase 7: 4+ parallel Opus agents

**Impact**:
- Context overflow risk (CLAUDE.md warns "400 Prompt is too long")
- Agent timeout with large data processing
- Orchestrator context exhaustion

**Fix**: Batch agents into rounds of 3-4:
```
Phase 2: Round 1 (2.1, 2.2, 2.3) -> Round 2 (2.4, 2.5, 2.6) -> Round 3 (2.7, 2.8)
Phase 3: Round 1 (ASIAN, LONDON, OVERLAP) -> Round 2 (NY, LATE_NY, EVENING)
```

---

### 6. No Retry/Failure Handling

**Location**: All phase plans

**Issue**: No mechanism defined for:
- Agent timeout
- Agent failure
- Partial completion
- Retry logic

**Impact**: One agent failure blocks entire phase with no recovery path.

**Fix**: Add to each phase:
```yaml
failure_handling:
  max_retries: 2
  timeout_minutes: 30
  partial_completion: "Continue with available results, document gaps"
  escalation: "Notify orchestrator for manual intervention"
```

---

### 7. Monte Carlo Statistical Validity

**Location**: `07-PHASE-PLAN.md`, Task 7.3

**Issue**: Block bootstrap with block size 20 requires sufficient trades:
- Minimum trades: 100 (from thresholds)
- Blocks: 100 / 20 = 5 blocks
- 5000 simulations of 5 blocks = heavy overlap, low diversity

**Impact**: Monte Carlo results may give false confidence due to limited block diversity.

**Fix**:
- Increase minimum trades to 200 (10 blocks minimum)
- Or dynamically adjust block size: `block_size = max(5, num_trades / 20)`
- Add diagnostic: if num_blocks < 10, flag as "LOW_CONFIDENCE"

---

### 8. No External Data Validation

**Location**: Phases 2-5

**Issue**: All validation is internal consistency checking. No comparison against independent data source.

**Risk**: If source CSV had systemic errors, they propagate through:
```
Source CSV (buggy) -> Catalog (buggy) -> Session catalogs (consistently buggy)
```
Consistency check would PASS on garbage data.

**Fix**: Add to Phase 2:
- Task 2.9: External Validation (sample 1 month against independent source)
- Use free API (Yahoo Finance, etc.) for spot-check comparison

---

### 9. DST Edge Cases Not Tested

**Location**: Phase 3 session validation

**Issue**: 22-year dataset (2003-2025) contains 40+ DST transitions. Plan doesn't explicitly test:
- Tick classification during DST transition hours
- Session boundary behavior on transition days
- Spring forward: missing hour (2 AM jumps to 3 AM)
- Fall back: duplicate hour (2 AM occurs twice)

**Impact**: Ticks on DST transition days could be misclassified.

**Fix**: Add DST test cases:
```python
dst_test_dates = [
    "2024-03-10",  # Spring forward
    "2024-11-03",  # Fall back
    # ... add key transition dates
]
# Verify session boundaries correct on these dates
```

---

### 10. WFA Window Coverage Gap

**Location**: `07-PHASE-PLAN.md`, Task 7.2

**Issue**: WFA windows show:
```
Window 12: IS=2023-01 to 2023-08, OOS=2023-09 to 2023-10
```

But baseline backtest uses OOS through 2024-12-31. The WFA doesn't cover 2023-11 through 2024-12 (14 months gap).

**Impact**: WFA validation doesn't cover most recent OOS period.

**Fix**: Extend WFA windows to cover through 2024:
```
Window 12: IS=2023-05 to 2023-12, OOS=2024-01 to 2024-02
Window 13: IS=2023-07 to 2024-02, OOS=2024-03 to 2024-04
... (continue to cover 2024)
```

---

## MEDIUM ISSUES (consider fixing)

### 11. Hardcoded Thresholds Throughout

**Impact**: If Apex rules change, must update multiple files.
**Fix**: Create `configs/validation_thresholds.yaml` referenced by all phases.

### 12. Session Coverage Tolerance Unclear

**Issue**: Phase 3 accepts 95-105% session sum. Why 5% tolerance?
**Fix**: Document expected discrepancy sources (boundary ticks, rounding).

### 13. Performance Benchmarks No Pass/Fail

**Issue**: Phase 5.4 collects metrics but has no defined thresholds.
**Fix**: Add: "Full catalog load < 60s, 1-day query < 1s" etc.

### 14. Cleanup Decision Criteria Vague

**Issue**: "Delete if stride1_COMPLETE is validated" - what's "validated"?
**Fix**: Explicit gate: "Quality score >= 70 AND Phase 2 all PASS"

---

## LOW ISSUES (nice to have)

### 15. Missing MANIFEST.md Template

**Issue**: Output protocol references MANIFEST.md but no template provided.
**Fix**: Add template to plan files.

### 16. Redundant Threshold Documentation

**Issue**: Same thresholds repeated in PLAN.md and Phase 8.
**Fix**: Single source of truth, others reference.

### 17. No Version Control Mechanism

**Issue**: Plan v1.0 but no change tracking.
**Fix**: Add changelog section to plan files.

---

## STRENGTHS (what's good about this plan)

1. **Comprehensive Coverage**: Data quality, sessions, integrity, advanced stats, backtesting
2. **Clear Phase Dependencies**: Explicit prerequisites documented
3. **Apex Integration**: Multiple phases include compliance checks
4. **CRITIC Self-Review**: Every agent prompt mandates adversarial self-review
5. **Output Persistence**: JSON files preserve results across phases
6. **GO/NO-GO Framework**: Clear thresholds with CRITICAL/HIGH weighting
7. **Multiple Validation Methods**: WFA, Monte Carlo, per-session testing
8. **Safety Protocols**: Cleanup has pre-conditions
9. **Efficient Sampling**: Head+tail strategy for large datasets
10. **Cross-Catalog Consistency**: Phase 4.1 validates data integrity

---

## ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| 654.6M ticks are valid | No external verification | Add Phase 2.9: spot-check against independent source |
| Session catalogs correctly partitioned | Only 100K tick sample | Verify full boundary coverage on DST dates |
| Backtest framework will be built in time | Weeks of dev work | Use existing NautilusTrader infrastructure |
| Strategy exists and is ready | Never explicitly referenced | Add strategy location to Phase 7 prompts |
| Opus agents won't timeout on 654M ticks | Large data processing | Add sampling strategy for full-catalog agents |
| Cross-catalog consistency = data correct | Could be consistently wrong | Add external validation checkpoint |
| 2020-2024 is sufficient backtest period | Only 5 years | Add 2008-2010 crisis period stress test |

---

## MANUAL VERIFICATION NEEDED

- [ ] Confirm strategy exists at `nautilus_gold_scalper/src/strategies/`
- [ ] Verify strategy compiles and has no look-ahead in `on_bar()`
- [ ] Confirm `BacktestEngine` from NautilusTrader works with current data format
- [ ] Validate scripts referenced in Phase 5.2 actually exist:
  - `scripts/data/convert_tick_data.py`
  - `scripts/convert_csv_to_nautilus_catalog.py`
- [ ] Confirm disk space sufficient for 5000 MC simulations
- [ ] Test sample Apex time zone conversions manually

---

## RECOMMENDATIONS

### Priority 1: Fix Before Execution
1. Correct Apex UTC time calculations in Phase 3
2. Make Phase 4.3 sequential (after 4.1 and 4.2)
3. Clarify Phase 6 scope: use existing BacktestEngine or split into separate project
4. Add explicit strategy reference to Phase 7 prompts

### Priority 2: Fix for Robustness
5. Reduce parallelism to 3-4 agents per round
6. Add retry/failure handling to each phase
7. Add DST edge case tests
8. Extend WFA windows to cover 2024

### Priority 3: Improve Quality
9. Add external data validation (spot-check)
10. Centralize thresholds in YAML config
11. Add performance benchmark pass/fail criteria
12. Create MANIFEST.md template

---

## VERDICT: APPROVE WITH CONDITIONS

**Confidence**: MEDIUM

**Rationale**:

The plan is well-structured and comprehensive. The data validation portions (Phases 1-5) are thorough and would provide valuable quality assurance. The GO/NO-GO framework in Phase 8 is sound.

However, 4 CRITICAL issues prevent immediate execution:
1. Apex time zone error could cause compliance violations
2. Race condition could corrupt validation results
3. Phase 6 scope is unclear (validation vs development)
4. Strategy reference is missing

**Conditions for Approval**:

| Condition | Action Required | Blocking? |
|-----------|-----------------|-----------|
| Fix Apex UTC times | Update Phase 3 prompts | YES |
| Make Phase 4.3 sequential | Update Phase 4 orchestration | YES |
| Clarify Phase 6 scope | Document existing vs new code | YES |
| Add strategy reference | Update Phase 7 prompts | YES |
| Reduce parallelism | Update agent spawn patterns | Recommended |
| Add failure handling | Add retry logic | Recommended |

**Pre-Mortem Summary**:

Most likely failure mode: **Phase 6 takes weeks instead of hours** because building an event-driven backtest engine is substantial development work. This blocks Phase 7 indefinitely.

Second most likely: **Context overflow** during Phase 2 or 3 when 8+ Opus agents return simultaneously, causing orchestrator to lose critical output details.

**Mitigation**: Use existing NautilusTrader BacktestEngine, batch agents into smaller rounds, persist all outputs to files immediately.

---

*"Every bug found now is a loss prevented later."*

CRITIC v1.1 - Adversarial Quality Guardian
