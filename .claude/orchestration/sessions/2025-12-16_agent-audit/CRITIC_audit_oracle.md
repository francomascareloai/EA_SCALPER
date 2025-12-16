# CRITIC ADVERSARIAL AUDIT: ORACLE v3.2

**Artifact**: `.claude/agents/oracle-backtest-commander.md`
**Type**: Agent Specification
**Reviewer**: CRITIC v1.1
**Date**: 2025-12-16
**Sequential Thoughts Used**: 15

---

## VERDICT: ISSUES_FOUND

---

## SEVERITY SUMMARY

| Severity | Count |
|----------|-------|
| CRITICAL | 4 |
| HIGH | 8 |
| MEDIUM | 10 |
| LOW | 3 |
| **TOTAL** | **25** |

---

## CRITICAL ISSUES (Must Fix)

### CRITICAL-1: Data Quality Validation Missing

**Location**: Missing section (should be before Gate 1)

**Issue**: The spec references "Default dataset: xauusd_2003_2025_stride20_full.parquet" but has no protocol for validating data quality before running statistical tests.

**Impact**: Garbage-in = garbage-out. All statistical tests (WFA, MC, DSR) are meaningless on corrupted data. Data could have:
- Price spikes from bad ticks
- Gaps during trading hours
- Look-ahead leakage baked into the data source
- Timestamp ordering issues

**Fix**: Add "Gate 0: Data Quality" section:
```
GATE 0: Data Quality (PREREQUISITE)
  [ ] No gaps > 1 hour during trading sessions
  [ ] No price spikes > 5 standard deviations
  [ ] Timestamps are monotonically increasing
  [ ] Coverage verified for all required regimes
  [ ] Data source documented and validated
```

---

### CRITICAL-2: HWM Calculation Method Unspecified

**Location**: Lines 120-131 (Apex Trading Specific)

**Issue**: The spec says "HWM Includes: Unrealized P&L" but provides no algorithm for how HWM is calculated in backtest. This is THE core Apex metric.

**Impact**: Different implementations could calculate HWM differently:
- End-of-bar vs real-time
- Including vs excluding unrealized
- Reset conditions

**Fix**: Add explicit algorithm:
```python
# HWM Calculation (MANDATORY implementation)
HWM[t] = max(HWM[t-1], Balance[t] + UnrealizedPnL[t])
Floor[t] = HWM[t] * 0.95
TrailingDD[t] = (HWM[t] - (Balance[t] + UnrealizedPnL[t])) / HWM[t]
# Must calculate on EVERY tick/bar, not just trade close
```

---

### CRITICAL-3: Paper Trading Validation Role Missing

**Location**: Not present (required by CLAUDE.md v3.10.9)

**Issue**: CLAUDE.md production_workflow defines mandatory paper trading phase:
```
<phase name="2_paper_trading" mandatory="true">
  <duration>Minimum 1 week with live data feed, no real money</duration>
```

ORACLE has no role defined for validating paper trading results.

**Impact**:
- Gap in validation pipeline
- No criteria for paper-to-backtest divergence
- No definition of what constitutes "pass" for paper trading

**Fix**: Add section:
```
## Paper Trading Validation (Post-Backtest)

ORACLE validates paper trading results against backtest expectations:

| Metric | Max Divergence |
|--------|----------------|
| Win Rate | +/- 10% of backtest |
| Avg Trade P&L | +/- 20% of backtest |
| Max DD | Must not exceed 4% |
| Time Gate Compliance | 100% required |

Requirements:
- Minimum 1 week duration
- Minimum 20 paper trades
- All sessions covered (London, NY)
```

---

### CRITICAL-4: Monte Carlo Block Size Unspecified

**Location**: Lines 47-48, 173-175

**Issue**: "Block Bootstrap (5000 runs, preserving autocorrelation)" is mentioned but block SIZE is critical and unspecified.

**Impact**:
- Too small block = destroys autocorrelation structure
- Too large block = insufficient randomization
- Results vary dramatically based on block size choice
- Invalid Monte Carlo if block size is wrong

**Fix**: Add specification:
```
Monte Carlo Configuration:
- Method: Stationary Bootstrap (automatic block selection)
- OR: Block size = min(average_trade_duration, 1_day)
- Runs: 5000 minimum
- Percentiles reported: 5th, 25th, 50th, 75th, 95th, 99th
- Block selection rationale MUST be documented
```

---

## HIGH ISSUES

### HIGH-1: Consistency Rule (30% max/day) Not a Gate

**Location**: Line 124 (mentioned) but missing from Gates 1-5

**Issue**: "Max 30% profit in single day" is listed in the Apex table but NOT included in the GO/NO-GO workflow. A strategy could pass all 5 gates but violate consistency.

**Impact**: Approved strategy could fail Apex consistency rule immediately on first big winning day.

**Fix**: Add Gate 6: Apex Compliance:
```
GATE 6: Apex Compliance
  [ ] No single day profit > 30% of total period profit
  [ ] No overnight positions in test period
  [ ] All trades closed by 4:59 PM ET
  [ ] No new trades after 4:30 PM ET
  [ ] Daily DD never exceeded 3%
```

---

### HIGH-2: Execution Realism Not Verified

**Location**: Lines 33-35, Handoff table line 193

**Issue**: The handoff table shows "<- CRUCIBLE: Execution realism verified" but ORACLE has no mechanism to VERIFY that CRUCIBLE actually did this validation.

**Impact**: Could validate statistics on unrealistic execution assumptions (0 spread, 0 slippage).

**Fix**: Add verification checklist:
```
## Execution Realism Verification
Before proceeding with statistical validation:
[ ] CRUCIBLE handoff received
[ ] Spread assumption documented: ____ pips
[ ] Slippage assumption documented: ____ pips
[ ] If spread < 2 pips XAUUSD: FLAG as suspicious
[ ] If slippage = 0: FLAG as suspicious
```

---

### HIGH-3: CAUTION Decision Underspecified

**Location**: Line 183

**Issue**: "1-2 minor fails -> CAUTION" but no definition of what constitutes "minor" vs "major" failure.

**Impact**: Inconsistent CAUTION decisions. One run might say CAUTION, another NO-GO, for same data.

**Fix**: Add severity matrix:
```
## Metric Severity Classification

| Metric | Minor Fail | Major Fail |
|--------|------------|------------|
| WFE | 0.55-0.60 | < 0.55 |
| PSR | 0.80-0.85 | < 0.80 |
| DSR | 0.00-0.50 | < 0.00 |
| PBO | 25%-35% | > 35% |
| MC95 DD | 4.0%-4.5% | > 4.5% |

Decision Matrix:
- 0 fails: GO
- 1 minor fail: CAUTION with specific warning
- 2+ minor fails: CAUTION with strong warning
- 1+ major fail: NO-GO
- ANY critical metric fail: NO-GO
```

---

### HIGH-4: WFA Window Construction Unspecified

**Location**: Lines 59, 103-105, 167-170

**Issue**: "12 windows, 70% IS" but no specification for:
- Overlapping vs non-overlapping windows
- Window start date selection method
- Minimum trades per window

**Impact**: Windows could be cherry-picked to start at favorable points.

**Fix**: Add specification:
```
## WFA Window Construction Rules
- Windows: 12 non-overlapping
- IS/OOS split: 70%/30%
- Window selection: Sequential from data start (no optimization)
- Minimum trades per OOS window: 8
- If any window has < 8 OOS trades: CAUTION flag
- Report per-window metrics, not just average
```

---

### HIGH-5: DSR Calculation Parameters Unspecified

**Location**: Lines 48, 89-90, 109

**Issue**: DSR (Deflated Sharpe Ratio) requires:
- Number of strategies tested
- Number of parameters optimized
- Backtest length

The spec doesn't tell ORACLE how to obtain these values.

**Impact**: DSR calculation could be wrong or impossible without inputs.

**Fix**: Add requirement:
```
## DSR Inputs (MUST be provided or inferred)
- N_strategies: Number of strategy variants tested
- N_params: Number of parameters optimized
- T: Number of observations (bars/ticks)
- Reference: Bailey, Borwein, Lopez de Prado (2014)

If not provided, ask: "How many strategy variants were tested?"
```

---

### HIGH-6: Output Format Non-Compliant with CLAUDE.md

**Location**: Lines 240-258

**Issue**: CLAUDE.md v3.10.9 requires:
```
Every sub-agent MUST include in output: AGENT_VERSION: [version from spec header]
```
ORACLE's report format lacks:
- AGENT header
- VERSION header
- CLAUDE_MD_VERSION
- STATUS field

**Impact**: Non-compliant with orchestration protocol.

**Fix**: Update report format:
```
ORACLE VALIDATION REPORT
========================
AGENT: ORACLE
VERSION: 3.2
CLAUDE_MD_VERSION: 3.10.9
STATUS: COMPLETE

Strategy: [NAME]
...
```

---

### HIGH-7: Self-Review Trigger Confusion

**Location**: Lines 196, 202-211

**Issue**: The handoff table shows "-> CRITIC Self-Review" as if it's a handoff to another agent. But CLAUDE.md says sub-agents cannot spawn other sub-agents, so it must be internal self-review.

The language is confusing and could lead to incorrect implementation.

**Impact**: Confusion about whether to spawn CRITIC externally or apply internally.

**Fix**: Clarify in spec:
```
## CRITIC Self-Review Protocol (INTERNAL - not a handoff)

NOTE: Sub-agents cannot spawn other sub-agents. CRITIC is applied
via SELF-REVIEW, not external invocation.

Process:
1. ORACLE reads `.claude/agents/critic-adversarial.md`
2. ORACLE applies CRITIC techniques INTERNALLY (12-15 thoughts)
3. If issues found: ORACLE fixes and repeats
4. Loop until confident all critical issues resolved
5. Only THEN issue final decision
```

---

### HIGH-8: Live Performance Monitoring Missing

**Location**: Not present

**Issue**: After GO decision, ORACLE has no defined role for:
- Monitoring live performance
- Detecting strategy degradation
- Triggering re-validation

**Impact**: Strategy could degrade post-GO with no detection mechanism.

**Fix**: Add section:
```
## Post-GO Monitoring Triggers

ORACLE should be re-invoked if:
- Live Sharpe falls below 80% of backtest
- Live max DD exceeds backtest max DD
- Win rate drops > 15% from backtest
- 30 consecutive losing trades
- Any trailing DD > 3.5%

Monitoring period: First 30 days of live trading
```

---

## MEDIUM ISSUES

### MEDIUM-1: Regime Coverage Ambiguity

**Location**: Lines 34, 159

**Issue**: "Multiple regimes covered" but no definition of:
- What regimes must be included
- How to verify coverage
- What percentage of data each regime needs

**Fix**: Define required regimes:
```
Required regimes (each must have >= 10% of trades):
- Trending up (20-day SMA slope > 0.5%)
- Trending down (20-day SMA slope < -0.5%)
- Ranging (ATR/Price < threshold)
- High volatility (VIX equivalent > 80th percentile)
- Low volatility (VIX equivalent < 20th percentile)
```

---

### MEDIUM-2: Borderline Threshold Handling

**Location**: Lines 88-92, 145-149

**Issue**: Thresholds like "WFE >= 0.60" don't specify handling of exact boundary (is 0.600000 PASS or FAIL?).

**Fix**: Add precision note:
```
All thresholds are inclusive (>= means >= exactly)
Precision: 4 decimal places
WFE = 0.5999 -> FAIL
WFE = 0.6000 -> PASS (but flag as borderline)
```

---

### MEDIUM-3: Session-Specific Performance Not Required

**Location**: Not present

**Issue**: XAUUSD behaves very differently across sessions (London, NY, Asia). No requirement to analyze session-specific performance.

**Fix**: Add requirement:
```
## Session Analysis (RECOMMENDED)
Report performance by session:
- Asia (00:00-08:00 GMT)
- London (08:00-16:00 GMT)
- NY (13:00-21:00 GMT)

Flag if any session has negative expectancy.
```

---

### MEDIUM-4: Weekend Gap Handling Not Specified

**Location**: Not present

**Issue**: Gold can gap 1-2% on Monday open. No mention of gap risk analysis.

**Fix**: Add:
```
Weekend Gap Analysis:
- Identify all Monday gaps > 0.5%
- Verify strategy handles gap scenarios
- Flag if strategy holds positions through weekend
```

---

### MEDIUM-5: Account Size Impact Not Analyzed

**Location**: Line 50

**Issue**: "$50k-$300k accounts" mentioned but no analysis of how different sizes affect validation.

**Fix**: Add note:
```
Account size considerations:
- Slippage increases with position size
- Same DD% = different absolute values
- Validate at target account size, not minimum
```

---

### MEDIUM-6: Confidence Level Missing from Output

**Location**: Line 31 vs Lines 240-258

**Issue**: MANDATORY THINKING PROTOCOL says output includes "CONFIDENCE_LEVEL" but report format doesn't have this field.

**Fix**: Add CONFIDENCE field to report format.

---

### MEDIUM-7: Metrics Not Included in Report (Only PASS/FAIL)

**Location**: Lines 249-253

**Issue**: Report shows "GATE 1: Sample Size [PASS/FAIL]" but not actual values. Downstream agents need to see WFE=0.72, not just "PASS".

**Fix**: Update format:
```
GATE 3: Walk-Forward (WFE)  [PASS] (WFE=0.72, target=0.60)
```

---

### MEDIUM-8: No File Path for Detailed Results

**Location**: Lines 240-258

**Issue**: For large validations, detailed results should be written to file per CLAUDE.md context_budget_protocol. Report format doesn't include paths.

**Fix**: Add:
```
Detailed Results: .planning/validation/[strategy]_[date]_oracle.md
Plots: .planning/validation/[strategy]_[date]_plots/
```

---

### MEDIUM-9: Escalation Threshold Ambiguity

**Location**: Lines 16-17

**Issue**: "ask only if missing trades/period/costs/params" but what counts as "missing"? If trades=80, is that "missing" or just low?

**Fix**: Clarify:
```
Missing = not provided at all
Low = provided but below minimum (e.g., trades < 100)
For "low": Issue NO-GO with explanation, don't ask
For "missing": Ask once, then proceed with conservative assumptions
```

---

### MEDIUM-10: Recovery from DD Not Analyzed

**Location**: Not present

**Issue**: Spec focuses on max DD but not recovery time. A 3.5% DD that takes 2 months to recover is problematic.

**Fix**: Add:
```
Underwater Analysis:
- Report max underwater period (days)
- Flag if any underwater period > 30 days
- Recovery factor: Total profit / Max DD
```

---

## LOW ISSUES

### LOW-1: Multiple Instruments Handling

**Issue**: Spec is XAUUSD-focused but no guidance on multi-instrument validation.

---

### LOW-2: Concurrent Validation State

**Issue**: No mention of state management for simultaneous validation requests.

---

### LOW-3: Benchmark Comparison Missing

**Issue**: No requirement to compare against buy-and-hold or naive strategies.

---

## ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| e2b is available and reliable | External service could fail | Add fallback calculation method |
| 12 WFA windows is sufficient | Arbitrary number | Justify or make configurable |
| 5000 MC runs is sufficient | May not be for tail percentiles | Report confidence interval on estimate |
| Block bootstrap preserves structure | Different autocorrelation patterns exist | Require autocorrelation analysis first |
| DSR formula is correctly implemented | Multiple formulations exist | Reference specific paper/formula |
| Data is clean | Not verified | Add data quality gate |

---

## EDGE CASES TESTED

| Edge Case | Result |
|-----------|--------|
| WFE exactly 0.60 | Ambiguous - boundary handling unclear |
| 5000 trades | No upper guidance |
| WFE good but DSR barely positive | No weighted decision matrix |
| Session-specific losses | Not detected |
| MC 95th exactly 4.0% | Ambiguous |
| Partial WFA results | No error handling |
| < 20 trades per window | Not flagged |

---

## STRESS TEST RESULTS

| Condition | Outcome |
|-----------|---------|
| e2b timeout | No fallback specified |
| Conflicting metrics | No resolution protocol |
| Different sessions | Not analyzed separately |
| Weekend gaps | Not considered |
| Large position slippage | Not scaled by size |

---

## MANUAL VERIFICATION NEEDED

- [ ] Verify e2b implements DSR correctly per original paper
- [ ] Confirm block bootstrap block size selection method
- [ ] Validate HWM calculation matches Apex's method exactly
- [ ] Test WFA window construction produces non-cherry-picked windows
- [ ] Verify time gate checks work with backtest data

---

## PRE-MORTEM SUMMARY

**Most likely failure mode**: Data quality issue not detected, invalidating all statistics. Strategy passed validation on corrupted data.

**Second most likely**: HWM calculated differently than Apex, leading to surprising violation on first profitable run.

**Third most likely**: Strategy passes statistical tests but violates 30% consistency rule (not in gates).

**Mitigation**: Add Gate 0 (Data Quality), add explicit HWM algorithm, add Gate 6 (Apex Compliance).

---

## POSITIVE ASPECTS

+ Well-structured with clear sections and tables
+ 10 Core Principles are excellent and memorable
+ Guardrails (NEVER Do) are explicit and correct
+ Gate-based workflow is a sound foundation
+ Handoff chain is defined
+ Proactive behavior table is helpful for trigger detection
+ Red Flags section captures common issues
+ Quote-based principles add personality and memorability

---

## RECOMMENDATIONS PRIORITY

1. **IMMEDIATE**: Add Gate 0 (Data Quality) and Gate 6 (Apex Compliance)
2. **IMMEDIATE**: Add explicit HWM calculation algorithm
3. **HIGH**: Update output format for CLAUDE.md compliance
4. **HIGH**: Add CAUTION severity matrix
5. **HIGH**: Add paper trading validation protocol
6. **MEDIUM**: Specify MC block size selection
7. **MEDIUM**: Add session-specific analysis requirement
8. **LOW**: Add benchmark comparison

---

## CONFIDENCE

**Level**: HIGH

**Reason**: Thorough 15-thought sequential analysis using all 7 CRITIC techniques (INVERSION, PRE-MORTEM, STRESS TEST, REGIME SHIFT, APEX TRAP, EDGE CASES, ASSUMPTION AUDIT). Found 25 issues across all severity levels. Analysis covered scope, boundaries, edge cases, Apex compliance, self-review protocol, and missing capabilities.

---

*"Every bug found now is a loss prevented later."*

CRITIC v1.1 - Adversarial Quality Guardian
