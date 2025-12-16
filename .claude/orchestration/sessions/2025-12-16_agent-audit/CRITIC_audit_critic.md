# CRITIC ADVERSARIAL SELF-AUDIT

**Agent**: CRITIC v1.1
**Target**: `.claude/agents/critic-adversarial.md`
**Date**: 2025-12-16
**Auditor**: CRITIC (meta-review)

---

## VERDICT: ISSUES_FOUND

**Severity Summary**:
| Severity | Count |
|----------|-------|
| CRITICAL | 2 |
| HIGH | 7 |
| MEDIUM | 9 |
| LOW | 4 |
| **TOTAL** | **22** |

---

## CRITICAL ISSUES (Must Fix)

### C1. No Meta-Review/Calibration Mechanism

**Location**: Missing from spec entirely

**Description**: CRITIC has no mechanism to detect its own blind spots or calibrate its effectiveness. The spec assumes CRITIC is correct, but this is unvalidated. Without external calibration, systematic blind spots could persist indefinitely.

**Impact**: CRITIC could be systematically missing entire categories of bugs and never know it. False negative rate is unknown and unmeasured.

**Proposed Fix**: Add "CRITIC CALIBRATION PROTOCOL" section:
```markdown
## CALIBRATION PROTOCOL

### Monthly Calibration
1. Sample 5 past CRITIC reviews from previous 30 days
2. For each review, compare CRITIC findings to:
   - Bugs found in paper trading
   - Bugs found in live trading
   - Issues caught by other agents later
3. Calculate metrics:
   - False Negative Rate: bugs missed / total bugs
   - False Positive Rate: non-bugs flagged / total flags
   - Severity Accuracy: predicted severity vs actual impact
4. Identify PATTERN of misses (data? ML? integration?)
5. Update checklists to address pattern

### External Validation
- Quarterly: DAEMON reviews CRITIC's effectiveness
- After major failure: Root cause analysis of CRITIC miss
```

---

### C2. Missing Temporal Correctness Audit Methodology

**Location**: Checklist says "No look-ahead/data leakage" but no HOW

**Description**: The spec identifies temporal correctness as critical but provides no concrete methodology for detecting look-ahead bias. Reviewers are told WHAT to check but not HOW.

**Impact**: Look-ahead bugs are subtle and often missed by surface-level review. A strategy could appear profitable in backtest due to future data leakage.

**Proposed Fix**: Add "TEMPORAL CORRECTNESS AUDIT" section:
```markdown
## TEMPORAL CORRECTNESS AUDIT PROTOCOL

### For Each Signal/Calculation:
1. TRACE data dependencies back to source
2. For each data point, ask: "When did this value EXIST?"
3. Verify: decision_time >= data_availability_time + latency

### Common Look-Ahead Patterns to Hunt:
- Using bar.close before bar is complete
- Features calculated with future rows (shift direction wrong)
- Indicators using "future" parameter or centered windows
- Data joins that peek forward
- Labels/targets derived from future prices

### Red Flags in NautilusTrader:
- Accessing `bar.close` in `on_bar` for the CURRENT bar
- Using `data[-1]` when data includes future
- Any `shift(-N)` in pandas (look-ahead if N > 0)

### Verification Steps:
1. For each indicator: print timestamp of inputs vs decision time
2. Add assertions: `assert input_time < decision_time`
3. Test with synthetic data where future differs from past
```

---

## HIGH ISSUES (Should Fix)

### H1. Missing ML/ONNX Adversarial Checklist

**Location**: Missing from CHECKLISTS BY ARTIFACT TYPE

**Description**: Project uses ONNX models heavily but CRITIC has no ML-specific review checklist. Label leakage, distribution shift, and model staleness are not covered.

**Impact**: An overfitted or data-leaking ML model could pass CRITIC review and cause losses in live trading.

**Proposed Fix**: Add section:
```markdown
### For ML MODELS / ONNX

```
ML CORRECTNESS
[ ] No label leakage (target not in features)
[ ] Train/test/validation split temporal (no shuffling time series)
[ ] Feature calculation uses ONLY past data
[ ] Model inputs at inference match training distribution
[ ] Model retraining schedule defined

OVERFITTING
[ ] WFE >= 0.6 (walk-forward efficiency)
[ ] PBO < 25% (probability of backtest overfitting)
[ ] Performance degrades gracefully as sample shrinks
[ ] Out-of-sample != in-sample performance (gap expected)

ONNX SPECIFICS
[ ] ONNX export matches Python model output
[ ] Input normalization parameters saved and applied correctly
[ ] Model version tracked (prevent stale model in production)
[ ] Fallback behavior if ONNX inference fails
```
```

---

### H2. Missing Data Quality Adversarial Checklist

**Location**: Missing from CHECKLISTS BY ARTIFACT TYPE

**Description**: Project uses 32.7M tick parquet file but CRITIC has no data quality review. Gaps, outliers, and survivorship bias are not checked.

**Impact**: Garbage in, garbage out. Strategy trained on bad data will fail in production.

**Proposed Fix**: Add section:
```markdown
### For DATA ARTIFACTS

```
COMPLETENESS
[ ] No unexpected gaps in time series
[ ] Weekend/holiday gaps are expected (not data issues)
[ ] All expected symbols/instruments present
[ ] Date range covers required period

QUALITY
[ ] No duplicate timestamps
[ ] Prices in valid range (no negative, no outliers > 10 std)
[ ] Spread/bid-ask reasonable (not zero, not huge)
[ ] Volume/tick count plausible

BIAS
[ ] Survivorship bias addressed (delisted instruments?)
[ ] Selection bias acknowledged
[ ] Look-ahead in data preparation (forward-fill careful)
[ ] Timezone consistency across sources
```
```

---

### H3. No Verification Protocol for Claimed Fixes

**Location**: WHEN INVOKED section, step 3-4

**Description**: Spec says "Loop until CRITIC returns PASS_WITH_NOTES" but no mechanism ensures claimed fixes are actually applied. Sub-agent could say "fixed" without fixing.

**Impact**: Bugs flagged by CRITIC could remain in production if sub-agent falsely claims resolution.

**Proposed Fix**: Add:
```markdown
## FIX VERIFICATION PROTOCOL

When sub-agent claims issue is fixed:
1. CRITIC re-runs the SPECIFIC check that failed
2. CRITIC verifies the fix addresses root cause, not symptom
3. If fix is cosmetic/incomplete, issue remains OPEN
4. Loop continues until verification passes

Note: "I fixed it" is not sufficient. Evidence required.
```

---

### H4. CRITIC Not in Authority Hierarchy for Disputes

**Location**: WHEN TO ESCALATE + CLAUDE.md decision_priority

**Description**: CLAUDE.md says "SENTINEL > ORACLE > CRUCIBLE" but CRITIC is not in hierarchy. If CRITIC and FORGE disagree, who wins?

**Impact**: Deadlocks, inconsistent decisions, wasted time.

**Proposed Fix**:
- Update CLAUDE.md decision_priority to: `SENTINEL > ORACLE > CRUCIBLE > CRITIC`
- Add to CRITIC spec: "CRITIC is advisory. If disagreement with implementing agent, escalate to SENTINEL for final decision."

---

### H5. Invocation Model Ambiguity

**Location**: CRITIC spec vs CLAUDE.md conflict

**Description**:
- CLAUDE.md says: "Sub-agent reads CRITIC spec and applies it internally" (self-review)
- CRITIC spec says: "CRITIC is invoked BY SUB-AGENTS" (spawn CRITIC)

Which is correct? Ambiguity could lead to no one actually doing proper review.

**Impact**: Sub-agent does shallow self-review instead of rigorous CRITIC analysis.

**Proposed Fix**: Clarify in CLAUDE.md:
```markdown
## CRITIC Invocation Model

PRIMARY: Sub-agent applies CRITIC checklist internally (self-review)
FALLBACK: For CRITICAL artifacts, orchestrator spawns CRITIC as separate agent

Self-review is faster; spawned CRITIC is more rigorous.
Use spawned CRITIC for: go-live decisions, architecture, risk sizing.
```

---

### H6. No User Escalation Path

**Location**: WHEN TO ESCALATE table

**Description**: Escalation targets are always other agents. No path for "this is so critical a human must decide."

**Impact**: Truly critical findings (potential account blow-up) might be handled by agents without human awareness.

**Proposed Fix**: Add to escalation table:
```markdown
| Finding | Escalate To |
|---------|-------------|
| **Potential account termination** | USER (IMMEDIATE) |
| **Apex rule ambiguity** | USER (clarify interpretation) |
| **Multiple CRITICAL unresolved** | USER (may need project pause) |
```

---

### H7. No Cross-Artifact Analysis Methodology

**Location**: Missing from ADVERSARIAL TECHNIQUES

**Description**: CRITIC assumes single artifact review. Bugs often exist in INTERACTION between files (strategy calls risk manager with wrong params, data loader feeds wrong format to strategy).

**Impact**: Integration bugs missed because each file looks correct in isolation.

**Proposed Fix**: Add technique:
```markdown
### 8. CROSS-ARTIFACT ANALYSIS

When reviewing system of components:
1. Map data flow between artifacts
2. Check type/format compatibility at boundaries
3. Verify assumptions made by A match guarantees provided by B
4. Test failure modes: what if A fails? Does B handle it?
5. Check initialization order dependencies
```

---

## MEDIUM ISSUES

### M1. No Thinking Depth Calibration

**Description**: Spec says 12-15 thoughts for all reviews. But go-live decisions should be 20-25+.

**Fix**: Add thinking depth guidelines by stakes:
- Standard review: 12-15 thoughts
- Risk/Apex changes: 15-18 thoughts
- Go-live decisions: 20-25 thoughts

---

### M2. No Feedback Loop for Checklist Improvement

**Description**: Checklists are static. Lessons from bugs found later are not incorporated.

**Fix**: Add "After any production bug, review if CRITIC checklist should be updated" to calibration protocol.

---

### M3. Large Artifact Handling Missing

**Description**: No guidance for 2000+ line files.

**Fix**: Add: "For large artifacts, prioritize: 1) entry/exit points, 2) error handling, 3) hot paths, 4) sample remaining. Document coverage %."

---

### M4. Incomplete Artifact Protocol Missing

**Description**: "Review half my strategy" has no protocol.

**Fix**: Add: "For incomplete artifacts, review what exists + flag dependencies/assumptions that need validation when complete."

---

### M5. Competence Boundary Missing

**Description**: When should CRITIC say "I can't properly review this"?

**Fix**: Add: "If artifact requires domain expertise outside trading/Python/MQL5 (e.g., GPU kernels, advanced cryptography), escalate to specialist or flag as 'LIMITED REVIEW'."

---

### M6. Output Format Missing Key Fields

**Description**: No severity counts, timestamps, artifact version, fix time estimates.

**Fix**: Add to output format header:
```
Review Date: [timestamp]
Artifact Version: [git hash or version]
Severity Counts: CRITICAL=N, HIGH=N, MEDIUM=N, LOW=N
Estimated Fix Time: [hours/days]
```

---

### M7. Incomplete DD Limit Escalation

**Description**: CRITIC checklist says "DD limits respected" but doesn't list the full escalation ladder from CLAUDE.md.

**Fix**: Add explicit levels: 1.5% warn, 2.0% caution, 2.5% reduce, 3.0% HALT (daily); 3.0% warn, 3.5% caution, 4.0% caution, 4.5% HALT, 5.0% TERMINATED (total).

---

### M8. Performance Requirements Context Unclear

**Description**: Spec mentions "<1ms" for on_bar but mixes Python and MQL5 contexts.

**Fix**: Separate clearly:
- Python/NautilusTrader: on_bar <1ms, on_quote_tick <100us
- MQL5: OnTick <50ms
- ONNX inference: <5ms (both)

---

### M9. No Risk-Calibrated Invocation

**Description**: Minor bugfix and go-live get same review intensity.

**Fix**: Add invocation intensity levels:
- LITE: Minor fixes, docs (5-8 thoughts)
- STANDARD: Normal code (12-15 thoughts)
- INTENSIVE: Risk/Apex/go-live (18-25 thoughts)

---

## LOW ISSUES

### L1. Version Inconsistency

**Description**: Header says "CRITIC v1.1", footer says "CRITIC v1.0"

**Fix**: Standardize to v1.1 throughout.

---

### L2. Forced Findings Philosophy

**Description**: "NEVER approve without finding at least ONE concern" could force false positives.

**Fix**: Consider adding "CLEAN PASS" verdict for genuinely excellent code (rare), with explicit statement that adversarial search was thorough.

---

### L3. Missing Proactive Triggers

**Description**: Good triggers exist, but missing: "passed all tests", "simple change", "legacy code".

**Fix**: Add these to PROACTIVE BEHAVIOR table.

---

### L4. No Priority Framework for Conflicts

**Description**: What if bug fix would make Apex compliance worse?

**Fix**: Add: "When concerns conflict, Apex compliance > performance > elegance. Escalate to SENTINEL if trade-off is significant."

---

## ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| 12-15 thoughts is enough | Arbitrary. Some bugs need 25+ | Calibrate based on past discoveries |
| Sub-agents will invoke CRITIC | No enforcement | Add audit trail / mandatory flag |
| CRITIC checklists are complete | Written once, never updated | Add calibration protocol |
| PASS_WITH_NOTES is cleanest | Normalizes low-severity findings | Consider CLEAN_PASS |
| Calculator MCP always works | Could fail | Add fallback (manual verification note) |

---

## EDGE CASES TESTED

| Scenario | Result |
|----------|--------|
| CRITIC reviewing CRITIC | Fundamental blind spot - shared biases likely |
| Perfect code submitted | Spec forces finding concern (potentially dishonest) |
| 2000-line artifact | No guidance - coverage unknown |
| CRITIC vs FORGE dispute | No authority hierarchy - deadlock possible |
| Domain outside expertise | No escape valve - could give false confidence |

---

## STRESS TEST RESULTS

| Condition | Outcome |
|-----------|---------|
| 5 artifacts submitted together | No cross-artifact protocol - integration bugs missed |
| Time pressure ("5 min review") | Guardrail exists but no minimum viable review defined |
| MCP tool failures | Spec assumes tools work - no fallback |
| Conflicting severities | No framework for trade-offs |

---

## MANUAL VERIFICATION NEEDED

- [ ] Have checklists been updated based on past bugs?
- [ ] Is there a record of CRITIC's false negative rate?
- [ ] Does team actually invoke CRITIC or skip it under deadline pressure?
- [ ] When was last external review of CRITIC's effectiveness?

---

## CONFIDENCE: MEDIUM

**Reason**:
- Applied all 7 adversarial techniques systematically
- Used 15 sequential thoughts for analysis
- BUT: I AM CRITIC reviewing CRITIC
- Shared biases are inherently undetectable by self-review
- Recommend external validation by DAEMON or human

---

## PRE-MORTEM SUMMARY

**Most likely failure mode**: CRITIC misses a look-ahead bug because the temporal correctness checklist is too vague, leading to an overfitted strategy passing review and blowing up in live trading.

**Second most likely**: ML model has label leakage that CRITIC doesn't catch because there's no ML-specific checklist, causing false confidence in WFE/SQN metrics.

**Mitigation**:
1. Add temporal correctness audit methodology (CRITICAL)
2. Add ML/ONNX checklist (HIGH)
3. Implement calibration protocol to catch future blind spots (CRITICAL)

---

## RECOMMENDATIONS PRIORITY

| Priority | Issue | Effort |
|----------|-------|--------|
| 1 | C1: Calibration protocol | Medium |
| 2 | C2: Temporal audit methodology | Medium |
| 3 | H1: ML/ONNX checklist | Low |
| 4 | H2: Data quality checklist | Low |
| 5 | H5: Clarify invocation model | Low |
| 6 | H3: Fix verification protocol | Low |
| 7 | H6: User escalation path | Low |
| 8 | H4 + H7: Authority + cross-artifact | Medium |

---

*CRITIC v1.1 - Adversarial Self-Audit*
*"Quis custodiet ipsos custodes?" - Now with an answer: calibration protocol + external review*
