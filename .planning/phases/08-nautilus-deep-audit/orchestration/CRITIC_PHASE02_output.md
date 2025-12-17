# CRITIC ADVERSARIAL REVIEW
==========================

**Artifact:** Phase 02 Plan - SMC Indicators Audit
**File:** `/home/franco/projetos/EA_SCALPER_XAUUSD/.planning/phases/08-nautilus-deep-audit/03-PHASE-02-PLAN.md`
**Type:** Plan/Audit Protocol
**Reviewer:** CRITIC v1.2
**Mode:** EXTERNAL-CRITIC
**Date:** 2025-12-16

---

## VERDICT: APPROVED WITH NOTES

The plan is well-structured and ready for execution. The ARGUS integration is appropriately scoped for indicator audit. Two MEDIUM issues identified are enhancement recommendations that can be optionally incorporated before execution.

---

## ISSUE SUMMARY

| Severity | Count |
|----------|-------|
| CRITICAL | 0 |
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 7 |

---

## MEDIUM ISSUES

### M-001: Missing Grep Pattern for `center=True` Rolling Windows

**Location:** Section "Indicator-Specific Verification" (line 389)
**Description:** Line 389 states "Rolling calculations - center=False confirmed" as a verification item, but there is no corresponding grep pattern in the "Dangerous Pattern Grep Commands" section (lines 320-345).

**Impact:** A centered rolling window (`df.rolling(..., center=True)`) would look ahead into future data. If present in indicator code and not grepped, it could be missed by agents who rely primarily on automated pattern detection.

**Fix:** Add Pattern 7 to grep commands section:
```bash
# Pattern 7: Centered rolling window (looks ahead into future)
rg "rolling.*center\s*=\s*True" --type py nautilus_gold_scalper/
```

Also add to Grep Pattern Checklist table:
| Centered rolling | `rg "rolling.*center\s*=\s*True"` | [ ] | Any match = CRITICAL |

---

### M-002: Session Filter Audit Missing Explicit Apex Time Gates

**Location:** Section "Specific Questions to Answer > Session Filter" (lines 214-215)
**Description:** Current questions are: "Timezone handling (ET vs UTC)? DST transitions? Holiday detection?"

These cover general timezone concerns but do not explicitly mention Apex prop firm time gates:
- 4:30 PM ET: Block new trade entries
- 4:55 PM ET: Emergency force-close initiation
- 4:59 PM ET: Hard close all positions

**Impact:** If session_filter.py is used to enforce trading windows, reviewers might not verify these specific Apex requirements without explicit guidance.

**Fix:** Add to Session Filter questions:
```
### Session Filter
1. Timezone handling (ET vs UTC)?
2. DST transitions?
3. Holiday detection?
4. **Apex time gates enforced? (4:30 PM entry cutoff, 4:55 PM force-close start, 4:59 PM hard close)**
```

---

## LOW ISSUES

### L-001: Protocol Step Numbering Confusion

**Location:** Lines 391-396 (Integration with Temporal Verification Protocol)
**Description:** New steps are added as "Step 0 (NEW - before Step 1)" and "Step 5 (NEW - after Step 4)" while keeping original Steps 1-4. This creates confusing numbering (0, 1, 2, 3, 4, 5).

**Fix:** Consider renumbering to Steps 1-6 with clear sequence, or explicitly state "Extended Protocol" with Steps 0-5.

---

### L-002: Grep Pattern Single-Digit Limitation

**Location:** Line 329, Pattern 1
**Description:** Pattern `\.shift\s*\(\s*-\d` uses `\d` which matches single digits only. A shift like `.shift(-10)` would not match.

**Likelihood:** Very low - trading code rarely uses large negative shifts.
**Fix:** Change to `\.shift\s*\(\s*-\d+` to catch multi-digit values.

---

### L-003: Signal Lagging Table "0 bars*" Potential Confusion

**Location:** Lines 372-378 (Signal Lagging Requirements table)
**Description:** Entry "SMC zones (OB/FVG) | 0 bars*" could confuse reviewers. The asterisk note clarifies but the "0 bars" might initially suggest no temporal discipline needed.

**Mitigation:** The asterisk note is adequate. Consider rephrasing: "Zone from completed bar, entry on next bar touch (implicit 1-bar lag)".

---

### L-004: Config Checklist Location Pattern Vague

**Location:** Lines 361-367 (NautilusTrader Configuration Checklist)
**Description:** "Location Pattern" column entries like "BarDataWrangler init" don't specify which files to search. Agents might not know where to find these configurations.

**Mitigation:** Agents can use the provided grep patterns (Pattern 5 and 6) to locate these. Consider adding example file paths or more specific search guidance.

---

### L-005: No Explicit Grep Output Documentation Requirement

**Location:** Agent Output Requirements (lines 229-240)
**Description:** Agents are required to provide "Top 3-5 key findings" and severity counts, but not explicitly required to paste grep command outputs as proof of execution.

**Mitigation:** Agent findings would naturally include grep results if violations found. Consider adding: "Include grep command outputs showing matches or 'no matches found'."

---

### L-006: No Guidance for Zero Grep Matches

**Location:** Section "Dangerous Pattern Grep Commands"
**Description:** If grep patterns return zero matches, it's unclear whether this means (a) code is clean, or (b) pattern failed to work. No verification guidance provided.

**Fix:** Add note: "Zero matches = code clean for this pattern. Verify at least one pattern produces output to confirm grep is working (e.g., Pattern 3 should have matches in any Python codebase)."

---

### L-007: Indicator Call Site Verification Missing

**Location:** Assumption about bar completion (implicitly throughout)
**Description:** Plan verifies indicators use completed bars, but doesn't explicitly require verifying WHERE indicators are called from (on_bar vs on_quote_tick vs other).

**Mitigation:** If indicator is called from on_quote_tick() and accesses bars, temporal issues could occur. Consider adding: "Verify indicator invocation points are from on_bar() handlers only."

---

## ADVERSARIAL TECHNIQUES APPLIED

### 1. INVERSION ("What would make this FAIL?")
- Grep patterns missing edge cases (multi-digit shifts, centered rolling)
- Config location vagueness
- Protocol step numbering confusion
- **Finding:** 2 items escalated to issues

### 2. PRE-MORTEM ("It's 2026, account blew up. Why?")
- Most likely: Greps not run/proven, agents rushed
- Second: Cross-indicator temporal issues slipped through parallel review
- **Mitigation in plan:** Temporal Verification Protocol requires manual 3-timestamp tracing; Re-review triggers for cross-dependencies

### 3. STRESS TEST (Extreme conditions)
- 500+ matches for Pattern 3 (.mean()/.std()): Grep scope appropriately narrowed to `nautilus_gold_scalper/`
- Library calls (pandas/TA-Lib) with implicit look-ahead: Not explicitly covered, but Temporal Verification Protocol manual tracing would catch
- **Finding:** Plan handles stress scenarios adequately

### 4. REGIME SHIFT (Market conditions change)
- Not directly applicable to plan review
- Plan appropriately scoped to temporal integrity, not market regime testing
- **Finding:** No issues

### 5. APEX TRAP ANALYSIS (Prop firm compliance)
- Time gate compliance: Session Filter questions cover timezone but not explicit Apex times
- DD calculation timing: Out of scope for indicator audit (risk management)
- **Finding:** 1 issue escalated (M-002)

### 6. EDGE CASES (Boundary conditions)
- File missing: Agents will naturally discover
- Round 0 timeout: Operational concern, not correctness
- Zero grep matches: Needs guidance
- Missing unit tests: Implied non-blocking
- **Finding:** Several low-priority items

### 7. ASSUMPTION AUDIT
- Grep patterns sufficient: Validated - manual protocol provides backup
- Round 0 catches all MTF issues: Partially - caller usage needs verification
- Parallel agents independent: Validated - re-review trigger exists
- 0.5ms threshold: Reasonable - stricter than 1ms on_bar budget
- bars[-1] completed in on_bar: Valid assumption for NautilusTrader
- **Finding:** 1 low item (L-007)

---

## TEMPORAL CORRECTNESS CHECK

| Check | Status |
|-------|--------|
| Data access points verified | DEFERRED (plan review, not code) |
| Timestamp ordering confirmed | N/A (plan review) |
| Look-ahead indicators | Plan correctly marks as BLOCKING |
| Bar completion verified | Plan includes explicit verification steps |

**Overall:** PASS for plan review - temporal correctness is properly emphasized and marked BLOCKING.

---

## ASSUMPTIONS CHALLENGED

### Assumption: "6 grep patterns are sufficient"
**Challenge:** ARGUS documented 17 patterns; only 6 included.
**Resolution:** Plan correctly excludes ML-specific patterns (Feature Selection, SMOTE, Target Encoding, Imputation) which are not relevant for indicator code review. Scoping is intentional and appropriate.

### Assumption: "0 bars lag for SMC zones is correct"
**Challenge:** Could this mean no temporal discipline?
**Resolution:** Asterisk note clarifies: zones identified from completed bars, entry on subsequent price action. Semantically correct - zone IDENTIFICATION is instant, trade EXECUTION follows.

### Assumption: "Parallel agents can work independently"
**Challenge:** Cross-dependencies between agents (e.g., order_block depends on structure_analyzer).
**Resolution:** Plan has explicit re-review trigger (lines 257-261) for cross-dependency issues.

---

## EDGE CASES TESTED

| Scenario | Result |
|----------|--------|
| Indicator file doesn't exist | Agents will discover; no explicit check needed |
| Grep returns 500+ matches | Scope limited to nautilus_gold_scalper/ - manageable |
| No unit tests exist | Non-blocking per success criteria |
| Zero grep matches | Needs guidance (L-006) |
| MTF correct but caller misuses | Temporal Verification Protocol catches via timestamp tracing |

---

## STRESS TEST RESULTS

| Condition | Outcome |
|-----------|---------|
| Large file (>1000 lines) | Plan's largest is ~670 lines; manageable |
| Library with implicit look-ahead | Manual temporal tracing would catch |
| Config files don't exist | Would be flagged as finding (config needed) |
| Round 0 times out | Operational; plan doesn't define SLA |

---

## MANUAL VERIFICATION NEEDED

- [ ] Verify grep patterns work on codebase (run Pattern 3, expect matches)
- [ ] Confirm indicator files exist at listed paths
- [ ] Review NautilusTrader documentation for bar completion semantics
- [ ] Verify session_filter.py handles Apex time gates if intended

---

## CONFIDENCE: HIGH

**Reasons:**
1. Plan structure is solid after C-001 to C-010 fixes
2. ARGUS integration is appropriately scoped
3. Look-ahead is correctly marked BLOCKING
4. Temporal Verification Protocol is comprehensive with 3-timestamp tracing
5. Orchestration output protocol ensures findings are captured
6. Re-review triggers exist for cross-dependencies

---

## PRE-MORTEM SUMMARY

**Most likely failure mode:** Agents rushing through temporal tracing without full diligence, or skipping grep execution.

**Second most likely:** Subtle cross-indicator temporal issue (e.g., structure_analyzer returns data that order_block_detector uses incorrectly) slipping through parallel review despite re-review trigger.

**Mitigation:**
- Temporal Verification Protocol's 3-timestamp trace requirement provides verification checkpoint
- Re-review trigger ensures cross-dependency issues are flagged
- Consolidation step cross-validates findings

---

## RECOMMENDATIONS

### Required (MEDIUM):
1. Add grep pattern for `center=True` rolling windows
2. Add Apex time gates to Session Filter questions

### Optional (LOW):
3. Renumber protocol steps to 1-6
4. Fix regex for multi-digit negative shifts
5. Clarify zero grep match handling
6. Add indicator call site verification guidance

---

*CRITIC v1.2 - "Every bug found now is a loss prevented later."*
