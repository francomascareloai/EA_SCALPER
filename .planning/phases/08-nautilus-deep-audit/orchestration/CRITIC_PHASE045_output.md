# CRITIC ADVERSARIAL REVIEW
==========================

**Artifact:** `.planning/phases/08-nautilus-deep-audit/05.5-PHASE-04.5-PLAN.md`
**Type:** Plan
**Reviewer:** CRITIC v1.2
**Mode:** EXTERNAL-CRITIC
**Date:** 2025-12-16

---

## VERDICT: APPROVED WITH NOTES

---

## Issue Summary

| Severity | Count |
|----------|-------|
| CRITICAL | 0 |
| HIGH | 1 |
| MEDIUM | 5 |
| LOW | 6 |

---

## HIGH ISSUES (should fix before execution)

### H-001: PBO Threshold Conflict

**Location:** Plan line 374 vs CLAUDE.md line 43

**Description:**
- Plan specifies: `PBO < 20%`
- CLAUDE.md specifies: `PBO < 25%`

**Impact:** Inconsistent validation criteria could cause wrong GO/NO-GO decisions. Agent might reject a valid model (if using 20%) or accept an overfit model (if using 25%).

**Fix Options:**
1. Align plan to CLAUDE.md: Change to `PBO < 25%`
2. Keep stricter threshold but add explicit justification: "ML audit uses PBO < 20% (stricter than project default of 25%) due to higher overfitting risk in ML pipelines"

**Recommendation:** Option 2 - stricter threshold for ML is reasonable, but must be explicitly documented.

---

## MEDIUM ISSUES (recommended improvements)

### M-001: Grep Patterns Miss Variable-Based Leakage

**Location:** Lines 326-345

**Description:** Pattern `\.shift\s*\(\s*-\d` catches `df.shift(-3)` but NOT:
- `shift_val = -3; df.shift(shift_val)`
- `df.shift(config.get('shift'))`
- `df.shift(-horizon)` where horizon is defined elsewhere

**Impact:** False negatives - leakage exists but grep doesn't find it.

**Fix:** Add note: "Grep commands are SCREENING ONLY. Manual code trace is AUTHORITATIVE. Agent must state 'I manually traced feature X and confirmed temporal integrity' for each unique feature pattern."

---

### M-002: Walk-Forward Validation is Optional

**Location:** Lines 83-84

**Description:** Current text: "Is walk-forward validation used? If so, document the schedule."

This implies WF might not exist, which is acceptable.

**Impact:** Could approve ML pipeline without proper out-of-sample validation.

**Fix:** Change to: "Walk-forward validation is MANDATORY for trading ML. If not present, flag as CRITICAL issue."

---

### M-003: PBO/DSR Calculation Methods Unspecified

**Location:** Lines 374-378

**Description:** Plan requires:
- PBO < 20%
- DSR > 0
- WFE >= 0.6

But doesn't specify:
- What library/implementation to use
- How many combinations for CPCV
- Purge/embargo periods for PBO calculation

**Impact:** Agent doesn't know HOW to calculate these metrics.

**Fix:** Add: "Use mlfinlab library for PBO calculation via CPCV. Minimum 10 combinations. Purge period = 1 day minimum. For DSR, use formula from Bailey & Lopez de Prado (2014)."

---

### M-004: Jupyter Notebooks Not Searched

**Location:** Line 19

**Description:** File discovery searches only `*.py` files. ML prototyping often happens in Jupyter notebooks.

**Impact:** Could miss ML code in `.ipynb` files.

**Fix:** Change line 19 to: "Search for: `*.py` AND `*.ipynb` files containing 'feature', 'train', 'model', 'predict', 'onnx'"

---

### M-005: Overly Broad Grep Pattern 7

**Location:** Line 344

**Description:** Pattern searches for `.mean()`, `.std()`, `.min()`, `.max()` - these are extremely common and will produce hundreds of false positives.

**Impact:** Noise makes real issues harder to spot.

**Fix:** Narrow pattern to ML-specific contexts:
```bash
# Instead of broad search:
rg "\.mean\(\)|\.std\(\)|\.min\(\)|\.max\(\)" --type py src/ml/

# Use contextual search:
rg "scaler.*fit.*mean|normalize.*std" --type py src/ml/
```

---

## LOW ISSUES (minor gaps, not blocking)

### L-001: Timezone Handling Not Mentioned

**Description:** Feature data in UTC vs bars in ET could cause subtle look-ahead (hours difference).

**Recommendation:** Add checklist item: "Verify all data sources use consistent timezone (or explicit conversion)"

---

### L-002: Duplicate Timestamp Handling Not Mentioned

**Description:** Duplicate timestamps in data could cause misalignment.

**Recommendation:** Add to edge cases: "Check for duplicate timestamps"

---

### L-003: DST Transition Handling Not Mentioned

**Description:** Daylight Saving Time transitions could cause missing/duplicate hours.

**Recommendation:** Add to edge cases: "Verify behavior around DST transitions (March/November)"

---

### L-004: Minimum Test Set Size Not Specified

**Description:** Plan doesn't specify minimum number of samples in test set.

**Recommendation:** Add: "Test set must contain >= 100 samples for statistical significance"

---

### L-005: Multi-Horizon Target Alignment Not Addressed

**Description:** If model predicts multiple horizons (1-bar, 5-bar, 20-bar), each needs separate alignment verification.

**Recommendation:** Add: "If multi-horizon, verify alignment for EACH prediction horizon"

---

### L-006: Edge-of-Data Window Behavior Not Checked

**Description:** Rolling windows at start of data produce NaN or incomplete calculations.

**Recommendation:** Add checklist item: "Verify handling of incomplete windows at data start"

---

## TEMPORAL CORRECTNESS CHECK

| Check | Status |
|-------|--------|
| Data access points documented | PASS - Lines 94-131 |
| Timestamp ordering template | PASS - Lines 103-129 |
| Look-ahead indicator checks | PASS - Lines 47-59 |
| Bar completion verification | PASS - Lines 118-119 |

**Overall:** PASS - The plan has comprehensive temporal verification methodology.

---

## ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| ML code is in Python | Could be in MQL5 for live inference | Confirm inference environment |
| Files at src/ml/ | Could be elsewhere | ADDRESSED by File Discovery Protocol |
| ONNX is serialization format | Could be pickle, joblib, h5 | Generalize serialization checks |
| Single model or homogeneous ensemble | Heterogeneous ensemble needs per-model verification | Require explicit per-model verification |
| Binary classification | Multi-class/ranking have different leakage patterns | Clarify expected model types |

---

## EDGE CASES TESTED

| Scenario | Plan Coverage |
|----------|---------------|
| Files don't exist | COVERED - File Discovery Protocol escalates |
| Rolling window at data start | NOT COVERED |
| All NaN features | PARTIALLY COVERED (imputation check exists) |
| ONNX not used | PARTIALLY COVERED (plan focuses on ONNX) |
| Multi-model ensemble | PARTIALLY COVERED |
| External API predictions | NOT COVERED |
| Multi-horizon targets | NOT COVERED |

---

## STRESS TEST RESULTS

| Condition | Outcome |
|-----------|---------|
| Grep finds 0 matches | Plan relies on grep + manual trace - should work |
| Grep finds 1000+ matches | Pattern 7 too broad - will create noise |
| ML pipeline doesn't exist yet | File Discovery Protocol escalates - correct |
| Agent has low confidence | Escalation path exists (lines 219-223) - correct |

---

## MANUAL VERIFICATION NEEDED

- [ ] Confirm which PBO threshold is correct (20% in plan vs 25% in CLAUDE.md)
- [ ] Verify ARGUS source document exists at referenced path
- [ ] Confirm expected ML file paths match actual codebase structure

---

## CONFIDENCE: HIGH

**Reasons:**
1. Complete plan file reviewed (429 lines)
2. Cross-referenced with CLAUDE.md thresholds
3. All 7 adversarial techniques applied systematically
4. Previous CRITIC fixes (C-001 through C-012) verified
5. Issues found are concrete and actionable

---

## PRE-MORTEM SUMMARY

**Most likely failure mode:** Grep-based detection gives false sense of security. Agent runs grep commands, finds nothing, concludes "no leakage." But actual leakage exists in non-pattern-matching forms (variable indirection, custom functions).

**Second most likely:** PBO threshold confusion causes wrong decision. Agent uses 20% from plan, rejects valid model. Or uses 25% from CLAUDE.md, accepts overfit model.

**Mitigation:**
1. Resolve PBO threshold conflict BEFORE executing phase
2. Add explicit note: "Grep is screening only; manual trace is authoritative"
3. Require agent to state: "I manually traced feature X and confirmed temporal integrity"

---

## PREVIOUS CRITIC FIXES VERIFICATION

All 12 previous issues (C-001 through C-012) were verified as FIXED:

| ID | Issue | Verification |
|----|-------|--------------|
| C-001 | Temporal trace template logic | FIXED - Line 115-119 uses <= correctly |
| C-002 | Encoder/discretization checks | FIXED - Lines 51-52, checklist items |
| C-003 | Pandas-specific traps | FIXED - Lines 54-59 |
| C-004 | File discovery protocol | FIXED - Lines 16-23 |
| C-005 | DIFF verification | FIXED - Lines 171-180 |
| C-006 | Walk-forward mentioned | FIXED - Lines 83-84, 156 |
| C-007 | Ensemble weight tuning | FIXED - Lines 68-69, 160 |
| C-008 | Current bar clarification | FIXED - Line 131 |
| C-009 | Feature tracing minimum | FIXED - Line 148 |
| C-010 | Normalization params | FIXED - Lines 177-180, 169 |
| C-011 | Confidence escalation | FIXED - Lines 219-223 |
| C-012 | Online learning check | FIXED - Line 159 |

---

## ARGUS INTEGRATION REVIEW

The ARGUS integration (lines 279-429) adds valuable content:

**Strengths:**
- Three types of ML leakage clearly explained
- Code examples showing WRONG vs RIGHT patterns
- Seven grep commands for automated screening
- Statistical validation metrics (PBO/DSR/WFE)
- Impact quantification (50%+ return inflation)

**Weaknesses:**
- PBO threshold conflicts with CLAUDE.md (H-001)
- Grep pattern 7 too broad (M-005)
- Calculation methods not specified (M-003)
- NautilusTrader config checks are scope creep (minor)

---

## RECOMMENDED FIXES BEFORE EXECUTION

### Required (HIGH):
1. **H-001:** Add to line 374: "Note: ML audit uses PBO < 20% threshold (stricter than project default of 25% in CLAUDE.md) due to higher overfitting risk in ML pipelines."

### Recommended (MEDIUM):
2. **M-002:** Change line 83-84 to: "Walk-forward validation is MANDATORY for trading ML. Document the schedule. If not present, flag as CRITICAL issue."

3. **M-003:** Add after line 378: "Implementation: Use mlfinlab library for CPCV-based PBO calculation. Minimum 10 combinations. Purge period >= 1 day."

4. **M-001:** Add to section header (line 318): "NOTE: These grep commands are SCREENING ONLY. Manual code trace is AUTHORITATIVE and must be performed for ALL unique feature patterns."

---

## CONCLUSION

The Phase 04.5 ML Pipeline Audit plan is fundamentally sound and provides comprehensive coverage for detecting look-ahead bias and data leakage. The ARGUS integration adds valuable detection patterns and academic backing.

One HIGH issue (PBO threshold conflict) should be resolved before execution. Five MEDIUM issues represent improvements that would strengthen the audit but are not blocking.

**The plan can proceed after resolving H-001.**

---

*CRITIC v1.2 - Adversarial Quality Guardian*
*"Every bug found now is a loss prevented later."*
