# CRITIC ADVERSARIAL REVIEW: Orchestration Structure & GO/NO-GO Decision

**Artifact**: Data Validation & Backtesting Pipeline (Phase 08)
**Type**: Plan/Strategy/Orchestration
**Reviewer**: CRITIC v1.1
**Date**: 2025-12-15
**Sequential Thinking**: 15 thoughts applied

---

## VERDICT: CONDITIONAL

**Must fix 4 CRITICAL issues before execution.**

---

## ISSUE SUMMARY

| Severity | Count | Action Required |
|----------|-------|-----------------|
| CRITICAL | 4 | Must fix before execution |
| HIGH | 4 | Should fix before execution |
| MEDIUM | 5 | Address during execution |
| LOW | 4 | Nice to have |

---

## CRITICAL ISSUES (Must Fix)

### C1: Monte Carlo DD Threshold Mismatch

**Location**: PLAN.md line 166-167, 08-PHASE-PLAN.md line 84

**Current**: `MC 95th DD < 8%`
**CLAUDE.md Specifies**: `MC95 DD < 4%`

**Impact**: Could approve a strategy with 7.5% expected DD. Apex trailing DD is 5% from HWM. An 8% threshold leaves NO safety buffer. Strategy could pass validation but violate Apex limits in live trading.

**Fix**: Change threshold to `< 4%` per CLAUDE.md safety buffer.

---

### C2: Missing Total DD Criterion

**Location**: 08-PHASE-PLAN.md Backtest Criteria section (absent)

**Current**: No total DD threshold defined in GO/NO-GO criteria.
**CLAUDE.md Specifies**: `Total DD >= 4.5% -> HALT`

**Impact**: Could miss total drawdown violations. Strategy might pass all backtest criteria but have unacceptable total DD exposure.

**Fix**: Add new row to Backtest Criteria:
```
| Total Max DD | < 4.5% | Phase 7 | CRITICAL |
```

---

### C3: Trailing DD Buffer Missing

**Location**: 08-PHASE-PLAN.md line 98

**Current**: `Trailing DD max < 5%`
**CLAUDE.md Specifies**: `Trailing DD >= 4% -> HALT` (safety buffer)

**Impact**: 5% threshold = exactly Apex limit = NO SAFETY MARGIN. Any slippage, gap, or unexpected volatility pushes over limit and terminates account.

**Fix**: Change to `< 4%` to maintain 1% buffer before Apex limit.

---

### C4: Context Overflow Risk Unmitigated

**Location**: PLAN.md Phase 2 instructions, 00-BRIEF.md

**Current**:
- Claims "Parallel Execution: Unlimited (user confirmed capacity)"
- Plans 8 parallel opus agents in Phase 2 alone
- 8 agents x ~15k tokens each = 120k tokens = context overflow

**Impact**: Context overflow causes summarization, losing critical findings. Phase 8 decision based on incomplete/truncated data. Could issue GO on corrupted information.

**Fix**:
1. Enforce 3-4 agents per round per CLAUDE.md recommendation
2. Remove "unlimited" claim from 00-BRIEF.md
3. Change to: "Parallel Execution: 3-4 agents per round (context safety)"

---

## HIGH ISSUES

### H1: HWM Unrealized P/L Not Tested

**Location**: 08-PHASE-PLAN.md Apex Compliance section

**Issue**: Apex calculates trailing DD from High-Water Mark which INCLUDES unrealized P/L. No explicit test case for this scenario.

**Scenario**:
1. Trade opens, gains +3% unrealized
2. HWM rises by 3%
3. Trade reverses to -2% realized
4. DD from HWM = 5% = TERMINATED

**Impact**: Strategy passes validation but fails live due to HWM trap.

**Fix**: Add criterion:
```
| HWM unrealized scenario | Tested | Phase 7 | HIGH |
```

---

### H2: No Error Handling for Malformed Outputs

**Location**: 08-PHASE-PLAN.md Phase 8 process

**Issue**: Phase 8 says "Load all PHASE*.json files" but no validation that files are:
- Present
- Valid JSON
- Complete
- Schema-compliant

**Impact**: If any agent returns malformed output, Phase 8 parsing fails or produces incorrect decision.

**Fix**: Add prerequisite step:
```
0. VALIDATE ALL OUTPUTS
   - Check all expected JSON files exist
   - Validate JSON parseable
   - Verify required fields present
   - Fail fast if validation fails
```

---

### H3: Inconsistent PSR Threshold

**Location**: 08-PHASE-PLAN.md line 84 vs CLAUDE.md

**Current**: `PSR >= 0.90`
**CLAUDE.md Specifies**: `PSR >= 0.85`

**Impact**: Less severe than MC DD but still a discrepancy. Could reject valid strategy that meets CLAUDE.md threshold.

**Fix**: Either:
- Change to 0.85 to match CLAUDE.md, OR
- Document why 0.90 is intentionally stricter

---

### H4: Missing Regime-Adjusted Thresholds

**Location**: 08-PHASE-PLAN.md GO/NO-GO Criteria

**Issue**: All thresholds are static. No adjustment for market conditions. Phase 2.6 collects regime data (Hurst) but it's not used in GO/NO-GO.

**Impact**: Strategy may pass in trending regime but fail in ranging. Thresholds don't account for regime distribution.

**Fix**: Add criterion:
```
| Regime diversity | All 3 regimes > 10% | Phase 2.6 | HIGH |
```

Consider regime-conditional WFE thresholds:
- WFE_trend >= 0.5
- WFE_range >= 0.6
- WFE_volatile >= 0.55

---

## MEDIUM ISSUES

### M1: Monte Carlo Sample Size Justification Missing

**Location**: 07-PHASE-PLAN (if exists), PLAN.md Phase 7

**Issue**: States "5000+ simulations" with no justification. Industry often uses 10,000+ for reliable 95th percentile estimation.

**Impact**: Tail risk underestimation possible with 5000 samples.

**Recommendation**: Either increase to 10,000 or document statistical justification for 5000.

---

### M2: No Conflict Resolution Mechanism

**Location**: Throughout plan

**Issue**: Multiple agents validate same data. Could produce conflicting results. No arbiter specified.

**Scenario**:
- Phase 2.8 (quality score) says: 72/100 PASS
- Phase 4.2 (metadata audit) implies: 65/100
- Which is authoritative?

**Recommendation**: Define conflict resolution: latest agent wins, highest severity wins, or explicit arbiter.

---

### M3: Phase 6 Dependencies May Be Inverted

**Location**: 00-ROADMAP.md lines 175-179

**Issue**: Description unclear on actual dependency order.
- 6.1 Event-driven backtester "Depends On: 6.2"
- 6.2 WFA configuration "Depends On: 6.3"
- 6.3 Monte Carlo setup "Depends On: -"

This implies: 6.3 -> 6.2 -> 6.1 (bottom-up)
But execution instructions say sequential 6.1 -> 6.2 -> 6.3

**Recommendation**: Clarify actual dependency order and fix documentation.

---

### M4: SENTINEL vs ORACLE Decision Authority Unclear

**Location**: 08-PHASE-PLAN.md lines 142-143

**Issue**: Says "ORACLE + SENTINEL review" but doesn't clarify:
- Is this one agent or two?
- How do they coordinate?
- Who has final authority if they disagree?

**Recommendation**: Either:
- Designate one as primary, one as reviewer
- Or document explicit escalation path

---

### M5: Checkpoint Protocol Vague

**Location**: PLAN.md Checkpoint Protocol section

**Issue**: Says "Consider fresh context if heavy" but:
- No specific token threshold
- No automatic trigger
- Relies on orchestrator judgment

**Recommendation**: Define specific trigger: "If context exceeds 80k tokens, checkpoint and restart"

---

## LOW ISSUES

### L1: Naming Convention Inconsistency

**Issue**: PHASE2_* vs PHASE3_SESSION_* - inconsistent prefix patterns.

---

### L2: No Version Control for JSON Outputs

**Issue**: If re-run, previous results overwritten. Should use timestamped outputs.

---

### L3: Missing Link Validation

**Issue**: Related Documents section has relative paths that could break if files moved.

---

### L4: Coverage Threshold Conservative

**Issue**: 36 month coverage threshold seems low given 22 years of available data. Could be 60+ months for robustness.

---

## ASSUMPTIONS CHALLENGED

### Assumption 1: "User confirmed unlimited capacity"

**Original**: 00-BRIEF.md states unlimited parallel execution confirmed.

**Challenge**: What does "capacity" mean? API rate limits? Context window? Memory?

**Reality**:
- Context window = limited (~128k tokens)
- API rate limits = apply to opus
- 8 parallel opus agents = likely context overflow

**Recommendation**: Test with 3 agents first, measure actual capacity before committing to unlimited.

---

### Assumption 2: "All outputs to JSON files"

**Original**: Plan assumes agents write structured JSON.

**Challenge**: What if agent writes markdown or freeform text? Phase 8 expects JSON.

**Recommendation**: Define strict JSON schema per output type.

---

### Assumption 3: "Dependencies are phase-level"

**Original**: ROADMAP shows phase-level dependencies only.

**Challenge**: Task-level dependencies within phases unclear. Example: Does 6.1 need 6.2's output?

**Recommendation**: Document task-level dependencies explicitly.

---

### Assumption 4: "CRITIC self-review is sufficient"

**Original**: Plan says agents apply CRITIC internally.

**Challenge**: Self-review has blind spots. Agents may not catch their own biases.

**Recommendation**: For Phase 8 (final decision), consider external CRITIC review.

---

### Assumption 5: "5000+ Monte Carlo simulations sufficient"

**Original**: Phase 7 specifies 5000+ simulations.

**Challenge**: Industry often uses 10,000+ for reliable 95th percentile. 5000 may underestimate tail risk.

**Recommendation**: Use 10,000 minimum or document statistical justification.

---

## EDGE CASES TESTED

| Scenario | Tested? | Risk |
|----------|---------|------|
| Agent returns partial results | Not specified | HIGH - decision on incomplete data |
| Conflicting agent assessments | Not specified | MEDIUM - no arbiter |
| Phase 4 cleanup partial failure | Not specified | MEDIUM - unclear recovery |
| Session catalog missing | Not specified | MEDIUM - agent may fail cryptically |
| Monte Carlo insufficient samples | Not specified | MEDIUM - invalid statistics |
| Baseline returns 0 trades | Not specified | LOW - unclear if data or strategy issue |

---

## STRESS TEST RESULTS

| Condition | Outcome |
|-----------|---------|
| 8 parallel opus agents | Context overflow likely (~120k tokens) |
| One agent timeout | No fallback specified - phase hangs? |
| Agent disagrees with threshold | No conflict resolution |
| HWM spike from unrealized P/L | Not tested in criteria |
| 4:58 PM position with slippage | Force-close slippage not modeled |
| Model fallback to non-opus | Inconsistent quality possible |

---

## MANUAL VERIFICATION NEEDED

- [ ] Verify CLAUDE.md thresholds are authoritative (MC95 4%, Trailing 4%, Total 4.5%)
- [ ] Confirm API rate limits for parallel opus agents (test 3-4 first)
- [ ] Validate all 6 session catalogs exist before Phase 3
- [ ] Define JSON schema requirements per output type
- [ ] Clarify ORACLE vs SENTINEL authority in Phase 8
- [ ] Create explicit HWM unrealized P/L test case
- [ ] Verify Monte Carlo 5000 samples is statistically justified
- [ ] Define context checkpoint trigger threshold
- [ ] Review Phase 6 dependency order for accuracy
- [ ] Plan for Phase 4 partial cleanup failure recovery

---

## CONFIDENCE: HIGH

**Reasons**:
1. Threshold discrepancies are objective facts (8% vs 4% in documents)
2. Apex rules are well-documented and non-negotiable
3. Context overflow is a known risk explicitly mentioned in CLAUDE.md
4. Missing criteria (Total DD) is a clear gap
5. All issues traceable to specific lines in documents

**Potential Blind Spots**:
1. Haven't read actual agent specs to verify implementation
2. Existing validation scripts might handle some edge cases
3. "APPROVED WITH CONDITIONS" note suggests prior review happened
4. Assuming CLAUDE.md is authoritative over PLAN.md

---

## PRE-MORTEM SUMMARY

### Most Likely Failure Mode: Threshold Misalignment

The 8% MC DD threshold could approve a strategy with 7.5% expected DD. This strategy passes all GO/NO-GO criteria. Live trading: actual DD hits 6% during news spike. Apex terminates account for exceeding 5% trailing DD. Post-mortem reveals threshold should have been 4%. All validation was "successful" but strategy fails anyway.

### Second Most Likely: Context Overflow

8 parallel agents spawn in Phase 2. Each produces 5,000+ words of output. Orchestrator context fills up. One agent finds critical gap issue. Context summarization loses this finding. Phase 8 decision based on incomplete data. GO issued when should have been NO-GO. Strategy trades on corrupted data.

### Third Most Likely: HWM Trap

Strategy validated with 4.5% max DD. Live trading: early profitable trade raises HWM. Then market reverses. DD calculated from elevated HWM. What looked like 4% DD is actually 5.5% from HWM. Account terminated despite "passing" validation. Failure mode not tested in backtest criteria.

---

## REQUIRED FIXES BEFORE EXECUTION

### Mandatory (CRITICAL):

1. **MC DD Threshold**: Change from `< 8%` to `< 4%` in:
   - PLAN.md line 166-167
   - 08-PHASE-PLAN.md line 84

2. **Add Total DD Criterion**: Add to 08-PHASE-PLAN.md:
   ```
   | Total Max DD | < 4.5% | Phase 7 | CRITICAL |
   ```

3. **Trailing DD Buffer**: Change from `< 5%` to `< 4%` in:
   - 08-PHASE-PLAN.md line 98

4. **Enforce Batching**:
   - Remove "Parallel Execution: Unlimited" from 00-BRIEF.md
   - Change to "3-4 agents per round (context safety)"
   - Update PLAN.md Phase 2/3/5/7 instructions to enforce rounds

### Recommended (HIGH):

5. Add HWM unrealized test case to Phase 7
6. Add output validation step to Phase 8
7. Align PSR threshold (0.85 vs 0.90)
8. Add regime diversity criterion

---

## UPON FIXING

The plan structure is sound:
- Phase sequencing is logical
- Agent assignments are appropriate
- GO/NO-GO decision logic is correct
- Output protocol is well-defined
- Checkpoint strategy is reasonable

With threshold corrections and batching enforcement, this plan can proceed.

---

## ESCALATION

| Finding | Escalate To |
|---------|-------------|
| Threshold discrepancies | SENTINEL (for Apex compliance verification) |
| Context overflow risk | Orchestrator (for batching enforcement) |
| Missing HWM test | ORACLE (for backtest criteria update) |
| Phase 8 authority | User (for final decision ownership) |

---

*"Every bug found now is a loss prevented later."*

**CRITIC v1.1 - Adversarial Quality Guardian**
