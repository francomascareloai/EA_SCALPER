# ARGUS Look-Ahead Detection Integration Summary

**Date:** 2025-12-16
**Source:** ARGUS_LOOKAHEAD_DETECTION.md
**Integrated Into:** 03-PHASE-02-PLAN.md, 05.5-PHASE-04.5-PLAN.md, PROTOCOLS.md

---

## Executive Summary

Successfully integrated 17 dangerous code patterns and NautilusTrader-specific configuration checks from ARGUS research into the audit plans. The integration adds:

- **12 grep command patterns** for automated detection
- **5 NautilusTrader configuration checks**
- **3 new protocols** (11, 12, 13)
- **2 new statistical metrics** (PBO, DSR)
- **3 types of ML leakage** detection

---

## Files Modified

### 1. 03-PHASE-02-PLAN.md (Indicators Audit)

**Added Section:** "ARGUS Integration: Look-Ahead Detection (2025-12-16)"

**Key Additions:**
- 6 grep command patterns for indicator review
- Grep pattern checklist table
- NautilusTrader configuration checklist
- Signal lagging requirements table
- Integration with Temporal Verification Protocol (Steps 0 and 5)

### 2. 05.5-PHASE-04.5-PLAN.md (ML Pipeline Audit)

**Added Section:** "ARGUS Integration: ML Leakage Detection (2025-12-16)"

**Key Additions:**
- Three types of ML data leakage (overlap, multi-test, pre-processing)
- Code examples of wrong vs right patterns
- 7 ML leakage grep commands
- ML leakage checklist with severity levels
- NautilusTrader configuration for ML
- Statistical validation metrics (PBO < 20%, DSR > 0)
- Enhanced feature engineering temporal trace template
- Impact quantification (50%+ backtest inflation possible)

### 3. PROTOCOLS.md

**Added Sections:**
- **Protocol 11:** Dangerous Pattern Detection Protocol
- **Protocol 12:** NautilusTrader Configuration Verification Protocol
- **Protocol 13:** Statistical Validation Metrics Protocol

---

## Key Patterns Integrated

### Critical Patterns (HALT on Match)

| # | Pattern | Grep Command |
|---|---------|--------------|
| 1 | Forward-looking shift | `rg "\.shift\s*\(\s*-\d" --type py` |
| 2 | Forward-looking rolling | `rg "rolling.*\.shift\s*\(\s*-" --type py` |
| 3 | bfill (fills from future) | `rg "\.bfill\(\)" --type py` |

### ML-Specific Patterns (HIGH severity)

| # | Pattern | Grep Command |
|---|---------|--------------|
| 4 | SMOTE/resampling | `rg "SMOTE\|fit_resample" --type py` |
| 5 | Feature selection | `rg "SelectKBest\|RFE\|feature_selection.*fit" --type py` |
| 6 | Target encoding | `rg "TargetEncoder\|target_encode" --type py` |
| 7 | Imputation | `rg "SimpleImputer\|KNNImputer\|fillna.*method" --type py` |

### NautilusTrader Configuration Checks

| Config | Required Value | Purpose |
|--------|---------------|---------|
| `ts_init_delta` | = bar_interval_ns | Ensures ts_init at bar close |
| `bars_timestamp_on_close` | True | Bars timestamped when complete |
| `bar_execution` | True | Simulates intrabar OHLC path |
| `bar_adaptive_high_low_ordering` | Document | Affects fill simulation |
| `bar_build_delay` | > 0 | Processing delay simulation |

---

## Statistical Validation Thresholds Added

| Metric | Threshold | Purpose |
|--------|-----------|---------|
| PBO (Probability of Backtest Overfitting) | < 20% | Detect overfitting |
| DSR (Deflated Sharpe Ratio) | > 0 | Correct for selection bias |

These supplement existing thresholds:
- WFE >= 0.6
- SQN >= 2.0
- PSR >= 0.85

---

## Protocol Integration Summary

| Protocol | New? | Content |
|----------|------|---------|
| 11 | NEW | Dangerous Pattern Detection |
| 12 | NEW | NautilusTrader Configuration Verification |
| 13 | NEW | Statistical Validation Metrics |
| 3 | ENHANCED | Temporal Verification now includes Protocol 11 as Step 0 |

---

## Usage During Audit

### For Phases 02, 03, 04, 05 (Code Review Phases)

1. Run all grep commands from Protocol 11 FIRST
2. Document any matches in Pattern Detection Results table
3. HALT if any CRITICAL pattern found
4. Proceed with manual review only after CRITICAL patterns cleared
5. Verify NautilusTrader configuration per Protocol 12

### For Phase 04.5 (ML Pipeline)

1. Run ML-specific grep commands (patterns 4-7)
2. Trace feature engineering order vs train/test split
3. Verify all preprocessing happens AFTER split
4. Calculate PBO and DSR per Protocol 13 thresholds

---

## Impact Assessment

**Estimated Detection Improvement:**
- Automated grep patterns can catch 70%+ of common look-ahead bugs before manual review
- NIH/PMC research shows Active Learning achieves F2=0.72 for ML leakage detection
- Yang et al. static analysis achieves 92.9% accuracy

**Risk Mitigation:**
- ARGUS research shows look-ahead bias can inflate backtest returns by 50%+
- Early detection prevents wasted effort on fatally flawed strategies

---

## Verification

Integration verified by reading updated files and confirming:
- [x] Phase 02 plan includes grep commands and checklists
- [x] Phase 04.5 plan includes ML leakage types and patterns
- [x] PROTOCOLS.md includes three new protocols (11, 12, 13)
- [x] All 17 dangerous patterns from ARGUS research are represented
- [x] NautilusTrader-specific checks are included
- [x] PBO and DSR thresholds are defined

---

## Next Steps

1. Execute Phase 00 baseline capture
2. Run Protocol 11 pattern detection before each code review phase
3. Verify NautilusTrader configuration early in Phase 02
4. Calculate PBO/DSR during final validation (Phase 07)

---

*Generated by FORGE subagent on 2025-12-16*
