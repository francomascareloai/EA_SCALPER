# CRITIC ADVERSARIAL REVIEW
==========================

**Artifact**: PROTOCOLS.md (Nautilus Deep Audit)
**Type**: Protocol/Plan Documentation
**Reviewer**: CRITIC v1.2
**Mode**: EXTERNAL-CRITIC
**Date**: 2025-12-16
**Sequential Thoughts Used**: 15

---

## VERDICT: APPROVED WITH NOTES

The PROTOCOLS.md file is comprehensive and well-structured. The new Protocols 11-14 from ARGUS research add valuable capabilities. However, there is 1 CRITICAL gap and several HIGH gaps that should be addressed before or during audit execution.

---

## ISSUE SUMMARY

| Severity | Count | Status |
|----------|-------|--------|
| CRITICAL | 1 | Open |
| HIGH | 6 | Open |
| MEDIUM | 6 | Open |
| LOW | 4 | Open |
| **TOTAL** | **17** | |

---

## CRITICAL ISSUES (Must Fix)

### C-001: Missing SQN Red Flag Threshold in Protocol 13

**Location**: Protocol 13 - Statistical Validation Metrics
**Description**: Protocol 13 includes SQN >= 2.0 as minimum threshold but is MISSING the SQN > 7.0 suspicious threshold from CLAUDE.md validation standards.

**CLAUDE.md says**: "SQN >=2.0 | >7.0 = suspicious"
**Protocol 13 says**: Only "SQN >= 2.0"

**Impact**: An overfit strategy with SQN = 10.0 would PASS Protocol 13 validation but is likely overfit. This could lead to deploying an overfit strategy that loses money in live trading.

**Fix**: Add to Protocol 13 Required Metrics table:
```
| Metric | Full Name | Threshold | Red Flag | Source |
|--------|-----------|-----------|----------|--------|
| SQN | System Quality Number | >= 2.0 | > 7.0 suspicious | Existing project standard |
```

---

## HIGH ISSUES

### H-001: Missing MC95 DD Threshold in Protocol 13

**Location**: Protocol 13 - Statistical Validation Metrics
**Description**: CLAUDE.md includes "MC95 DD <4% | >5% = FAIL (Apex buffer)" but Protocol 13 does not include Monte Carlo 95th percentile drawdown.

**Impact**: Strategy could pass Protocol 13 but have excessive drawdown risk under Monte Carlo simulation.

**Fix**: Add MC95 DD < 4% to Protocol 13 Required Metrics table.

---

### H-002: Protocol 11 Missing Jupyter Notebook Support

**Location**: Protocol 11 - Dangerous Pattern Detection
**Description**: All grep patterns use `--type py` which only matches `.py` files. Jupyter notebooks (`.ipynb`) contain Python code that could have look-ahead bugs.

**Impact**: Look-ahead bugs in notebooks would not be detected by the pattern scan.

**Fix**: Either:
- Add `--glob '*.ipynb'` patterns with JSON extraction, OR
- Add note clarifying notebooks must be reviewed manually/separately

---

### H-003: Protocol 11 Missing MQL5 Scope Clarification

**Location**: Protocol 11 - Dangerous Pattern Detection
**Description**: Project includes MQL5 code in `MQL5/Experts/` but Protocol 11 only covers Python patterns.

**Impact**: MQL5 look-ahead bugs would not be detected.

**Fix**: Add explicit scope statement: "This protocol covers Python code only. MQL5 code review is handled separately by FORGE agent using MQL5-specific patterns."

---

### H-004: Tick-Level vs Bar-Level Confusion in Protocol 14

**Location**: Protocol 14 - Section A (Trailing Drawdown)
**Description**: Verification checklist says "Tick-level HWM update confirmed" but NautilusTrader backtesting operates on bars, not ticks.

**Impact**: Reviewers may expect tick-level precision in bar-based backtest, creating confusion or false verification.

**Fix**: Clarify: "HWM update granularity: Tick-level in live trading, bar-close-level in backtesting. Verify appropriate level for context."

---

### H-005: News Blackout Implementation Missing Details

**Location**: Protocol 14 - Section G (News Blackout Windows)
**Description**: Has verification checkboxes for "Economic calendar integration" and "Spread monitoring" but no implementation details.

**Impact**: Boxes could be checked without actual implementation. NFP/FOMC events could cause catastrophic slippage.

**Fix**: Add implementation requirements:
- Specify calendar data source (Forex Factory API, Investing.com, local file)
- Specify integration method (polling frequency, parsing logic)
- Add code location requirement like other sections

---

### H-006: Assertion in Verification Template Could Crash Production

**Location**: Protocol 12 - NautilusTrader Configuration Verification
**Description**: Runtime verification code uses `assert current_time >= bar.ts_event` which will raise AssertionError if condition fails.

**Impact**: If verification code is left in production strategy, assertion failure would crash the strategy unexpectedly.

**Fix**: Replace with logging:
```python
def on_bar(self, bar: Bar) -> None:
    current_time = self.clock.utc_now()
    if current_time < bar.ts_event:
        self.log.error(f"TEMPORAL VIOLATION: Processing bar before close! current={current_time}, bar.ts_event={bar.ts_event}")
        return  # Skip processing this bar
```

---

## MEDIUM ISSUES

### M-001: No ripgrep Fallback in Protocol 11

**Location**: Protocol 11 - Dangerous Pattern Detection
**Description**: Commands use `rg` which may not be installed on all systems.

**Fix**: Add note: "Requires ripgrep (rg). Install via: `apt install ripgrep` or `brew install ripgrep`. Alternative grep commands available on request."

---

### M-002: DSR Calculation Not Implementable

**Location**: Protocol 13 - Statistical Validation Metrics
**Description**: DSR formula provided is conceptual/pseudocode, not implementable without additional context.

**Fix**: Add reference: "Implementation: See Bailey & Lopez de Prado (2014) or use `mlfinlab.cross_validation.ml_cross_val_score` with purging."

---

### M-003: TRADOVATE Error Messages Brittle

**Location**: Protocol 14 - Section H (Platform Error Handling)
**Description**: Uses exact string matching for error messages which could break if TRADOVATE changes wording.

**Fix**: Recommend partial string or regex matching:
```python
if "administrators only" in error_msg:  # instead of exact match
    halt_trading()
```

---

### M-004: Protocols 11-14 Not in Protocol 7 Enforcement

**Location**: Protocol 7 - Protocol Compliance Check
**Description**: Protocol 7 enforces Protocols 1-10 but new Protocols 11-14 have no enforcement mechanism.

**Fix**: Update Protocol 7 checklist to include:
- [ ] Protocol 11 pattern scan completed (for code review phases)
- [ ] Protocol 12 config verification done (for Nautilus phases)
- [ ] Protocol 13 metrics computed (for validation phases)
- [ ] Protocol 14 Apex checklist completed (for all phases)

---

### M-005: PBO Threshold Inconsistency

**Location**: Protocol 13 vs CLAUDE.md
**Description**:
- Protocol 13: PBO < 20%
- CLAUDE.md: PBO < 25%

**Impact**: Documentation inconsistency creates confusion about which threshold applies.

**Fix**: Align to single value. Recommend 20% since it's stricter. Update CLAUDE.md or add note to Protocol 13 that it uses stricter threshold.

---

### M-006: Missing Empty Results Guidance in Protocol 11

**Location**: Protocol 11 - Dangerous Pattern Detection
**Description**: No guidance on interpreting results when all patterns return 0 matches.

**Fix**: Add guidance: "If all critical patterns return 0 matches, this is expected for well-written code. Verify the scan scope was correct (files exist, paths valid). Zero matches does NOT mean code is look-ahead free - manual review still required."

---

## LOW ISSUES

### L-001: No Version Dating on Apex Rules

**Location**: Protocol 14
**Description**: Apex rules may change over time but no "verified as of" date.

**Fix**: Add header: "Rules verified as of: 2025-12-16. Verify against current Apex documentation before use."

---

### L-002: Missing NautilusTrader Version Specification

**Location**: Protocol 12
**Description**: Config names may change between NT versions.

**Fix**: Add note: "Verified for NautilusTrader 1.x. Config names may differ in later versions."

---

### L-003: Contract Scaling Marked "Lower Priority"

**Location**: Protocol 14 - Section F
**Description**: States "lower priority but must be verified if max size is used" which could cause oversight.

**Fix**: Remove "lower priority" qualifier or add explicit skip condition: "Skip if position size always < 50% max contracts."

---

### L-004: 30% Rule Disambiguation Needed

**Location**: Protocol 14 - Sections C and D
**Description**: Two different 30% rules (per-trade loss vs daily consistency) could confuse reviewers.

**Fix**: Add explicit note at start of Section D: "Note: This is DIFFERENT from the 30% per-trade loss rule in Section C. Section C limits open P/L, Section D limits daily profit concentration."

---

## ADVERSARIAL TECHNIQUES APPLIED

### 1. INVERSION - What would make these protocols FAIL?
- grep commands failing silently without ripgrep
- Patterns missing notebook/MQL5 coverage
- Statistical validation passing overfit strategies

### 2. PRE-MORTEM - It's 2026, account blew up, why?
- Protocol 13 passed overfit strategy (SQN = 10, no red flag)
- News blackout boxes checked but not implemented
- Automation prohibition ignored, account terminated

### 3. STRESS TEST - Extreme conditions
- Large codebase (1000+ files) - no timeout guidance
- Flash crash through close window
- Assertion crash in production

### 4. REGIME SHIFT - Requirements change
- NautilusTrader version update changes config names
- Apex tightens rules
- Moving to different prop firm

### 5. APEX TRAP ANALYSIS
- Trailing DD HWM spike trap documented correctly
- Tick vs bar level confusion
- 30% rules could be conflated

### 6. EDGE CASE HUNTING
- Empty grep results
- Config files don't exist
- DST transition moment
- Partial fill handling

### 7. ASSUMPTION AUDIT
- ripgrep availability assumed
- Python-only codebase assumed
- Economic calendar exists assumed
- TRADOVATE error messages stable assumed

---

## TEMPORAL CORRECTNESS CHECK

**Not applicable** - This is a protocol document, not trading code. Temporal verification is defined IN the protocols (Protocol 3, 11, 12) for use during code review.

---

## ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Conclusion |
|------------|-----------|------------|
| ripgrep is available | What if only grep installed? | Add fallback or dependency note |
| Codebase is Python-only | MQL5 code exists in project | Clarify scope |
| Protocol 13 aligns with CLAUDE.md | SQN > 7.0 and MC95 DD missing | CRITICAL - must align |
| Economic calendar is integrated | No implementation specified | HIGH - add requirements |

---

## MANUAL VERIFICATION NEEDED

- [ ] Confirm Protocol 13 thresholds align with CLAUDE.md before using for validation
- [ ] Verify NautilusTrader config names against current NT version documentation
- [ ] Check that PLAN.md references Protocol 11 for relevant phases
- [ ] Verify economic calendar data source exists and is integrated
- [ ] Confirm ripgrep is available on execution systems

---

## PRE-MORTEM SUMMARY

**Most likely failure mode**: Protocol 13 passes an overfit strategy because SQN > 7.0 red flag and MC95 DD < 4% are not included. Strategy looks good on paper but bleeds money in live trading.

**Second most likely**: News blackout verification (Protocol 14 Section G) is checked as complete but not actually implemented. NFP release causes 800-pip slippage and significant DD.

**Third most likely**: Automation prohibition (Protocol 14 Section I) is acknowledged but project proceeds anyway. Account terminated on PA/Live for automation detection.

**Mitigation**:
1. Add SQN > 7.0 and MC95 DD < 4% to Protocol 13 immediately
2. Expand Protocol 14 Section G with specific implementation requirements
3. Make project-level decision on automation prohibition before proceeding to PA

---

## CONFIDENCE LEVEL: HIGH

**Reason**: The issues found are clear documentation gaps. The protocols are otherwise well-structured and comprehensive. The fixes are straightforward additions, not architectural changes. The document can be used for the audit with awareness of the identified gaps.

---

## CRITIC SELF-REVIEW NOTES

### Verification
- Sequential thinking thoughts used: 15
- Adversarial techniques applied: All 7 with specific examples

### Techniques Applied (with examples)
1. **INVERSION**: Identified grep commands failing silently, statistical validation gaps
2. **PRE-MORTEM**: Constructed 3 detailed failure scenarios with root causes
3. **STRESS TEST**: Tested large codebase, flash crash, assertion crash scenarios
4. **REGIME SHIFT**: Considered NT version changes, Apex rule tightening, prop firm switch
5. **APEX TRAP**: Found tick/bar confusion, 30% rule disambiguation need
6. **EDGE CASES**: Empty results, missing configs, DST transition, partial fills
7. **ASSUMPTION AUDIT**: Challenged ripgrep, Python-only, calendar, error messages

### Issues Found During Self-Review
1. Initially classified automation prohibition as CRITICAL but it's actually documented - downgraded to awareness item
2. Reconsidered assertion crash severity - it's in verification template, not production code - classified as HIGH not CRITICAL
3. Verified PBO threshold inconsistency direction (20% is stricter than 25% - not a regression)

### Assumptions Challenged
1. "Protocol 13 is complete" -> Missing SQN red flag and MC95 DD
2. "All code is Python" -> MQL5 exists in project
3. "Tick-level is accurate for backtesting" -> Bars not ticks in NT backtest

### Confidence Level
HIGH - Issues are documentation gaps with clear fixes. No architectural problems.

---

*CRITIC v1.2 - Adversarial Quality Guardian*
*"Every bug found now is a loss prevented later."*
