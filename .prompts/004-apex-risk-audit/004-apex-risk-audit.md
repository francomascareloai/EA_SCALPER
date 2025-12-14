# PROMPT 004: Apex Trading Risk Management Audit

## Objective

**Complete audit** of Apex Trading risk management implementation to ensure compliance with Apex rules (NOT FTMO):
- Validate trailing drawdown (10% from HWM, not fixed)
- Verify time-based position closure (4:59 PM ET deadline)
- Check consistency rule (max 30% profit in one day)
- Validate position sizing for Apex constraints
- Identify gaps, misconfigurations, and FTMO remnants

**Why it matters**: Apex rules are STRICTER than FTMO (trailing DD follows equity highs). User mentioned "gestão de risco não está adequada" and plan changed from FTMO to Apex. Need to verify COMPLETE migration of risk logic.

---

## Context

**Dependencies**:
- @.prompts/001-nautilus-plan-refine/nautilus-plan-audit.md (module status)
- @.prompts/003-backtest-code-audit/backtest-code-audit.md (risk module integration)

**Target files**:
- `nautilus_gold_scalper/src/risk/prop_firm_manager.py`
- `nautilus_gold_scalper/src/risk/position_sizer.py`
- `nautilus_gold_scalper/src/risk/drawdown_tracker.py`
- `nautilus_gold_scalper/src/risk/circuit_breaker.py`
- `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py` (risk integration)

**Known issues**:
1. Plan says "Apex Prop Firm" but risk modules may still have FTMO logic
2. Trailing DD is CRITICAL difference: Apex tracks HWM, FTMO doesn't
3. Time constraints (4:59 PM ET) may not be enforced
4. Consistency rule (30%) may not be checked

**Dynamic context**:
- !`grep -rn "FTMO\|ftmo" nautilus_gold_scalper/src/risk/` (FTMO remnants)
- !`grep -rn "Apex\|apex\|APEX" nautilus_gold_scalper/src/risk/` (Apex config)
- !`grep -rn "trailing.*dd\|HWM\|high.*water" nautilus_gold_scalper/src/risk/` (trailing DD)
- !`grep -rn "4:59\|cutoff\|ET\|time.*constraint" nautilus_gold_scalper/src/` (time checks)

---

## Requirements

### 1. Apex vs FTMO Rule Comparison

**Document differences**:

| Rule | FTMO | Apex | Implementation Status |
|------|------|------|----------------------|
| Daily DD | 5% fixed from start balance | N/A (only trailing) | ? |
| Overall DD | 10% fixed from start balance | 10% trailing from HWM | ? |
| HWM tracking | Not used | CRITICAL - tracks equity peak | ? |
| Unrealized P&L | Excluded from DD calc | INCLUDED in DD calc | ? |
| Time constraint | None | Must close by 4:59 PM ET | ? |
| Overnight | Allowed (with risk) | FORBIDDEN | ? |
| Consistency | None | Max 30% profit in one day | ? |
| Violation | Account reset | Account TERMINATED | ? |

**Validate**: Does codebase implement Apex column (NOT FTMO column)?

### 2. Trailing Drawdown Audit

**Critical logic**:
```python
# CORRECT (Apex):
HWM = max(HWM, current_equity)  # Track peak equity
current_DD = (HWM - current_equity) / HWM * 100
if current_DD > 10.0:
    TERMINATE_ACCOUNT()

# WRONG (FTMO):
current_DD = (start_balance - current_equity) / start_balance * 100
if current_DD > 10.0:
    RESET_ACCOUNT()
```

**Check in code**:
- Is HWM tracked correctly?
- Does HWM include unrealized P&L?
- Is DD calculated as `(HWM - current_equity) / HWM`?
- Is threshold exactly 10% (not 10.5% or buffer)?
- Is it checked on EVERY tick/trade update?

**Inspect**:
```bash
Read("nautilus_gold_scalper/src/risk/drawdown_tracker.py")
Read("nautilus_gold_scalper/src/risk/prop_firm_manager.py")
# Look for HWM tracking, DD formula, update frequency
```

### 3. Time Constraint Audit

**Apex rules**:
- 4:00 PM ET: Warning - prepare to close
- 4:30 PM ET: Urgent - start closing positions
- 4:55 PM ET: Emergency - close ALL positions
- 4:59 PM ET: DEADLINE - must be flat

**Check in code**:
- Are time checks present?
- Is timezone handled correctly (ET = America/New_York)?
- Are warnings/alerts triggered at each level?
- Is position closure FORCED at deadline?
- What happens if close fails (network issue)?

**Inspect**:
```bash
grep -rn "4:59\|cutoff\|deadline\|ET.*time\|America/New_York" nautilus_gold_scalper/
# Look for time checks, timezone handling, forced closure
```

### 4. Consistency Rule Audit

**Apex rule**: Max 30% of total profit in a single day

**Example**:
- Account at $50k, made $500 total profit over 10 days
- Day 11: If profit > $150 (30% of $500), stop trading for the day

**Check in code**:
- Is total profit tracked?
- Is daily profit tracked?
- Is 30% limit enforced?
- Does it stop new trades or close existing?

**Inspect**:
```bash
grep -rn "consistency\|30.*percent\|profit.*limit\|daily.*profit" nautilus_gold_scalper/
```

### 5. Position Sizing Audit

**Apex considerations**:
- Max risk/trade: 0.5-1% (conservative near HWM)
- Must account for trailing DD buffer (e.g., 8% buffer = only 2% room)
- Kelly criterion may be too aggressive
- ATR-based sizing more stable

**Check in code**:
- Does position_sizer.py consider trailing DD?
- Is max risk/trade configurable and enforced?
- Is Kelly capped (e.g., max 0.25 Kelly)?
- Is sizing reduced when close to DD limit?

**Inspect**:
```bash
Read("nautilus_gold_scalper/src/risk/position_sizer.py")
# Look for DD-aware sizing, Kelly capping, dynamic adjustment
```

### 6. Circuit Breaker Validation

**6 levels documented** (from plan):
1. Level 1: First loss
2. Level 2: Two losses in row
3. Level 3: Three losses in row
4. Level 4: DD approaching threshold
5. Level 5: Win rate degradation
6. Level 6: Emergency halt

**Verify**:
- Are all 6 levels implemented?
- What triggers each level?
- What actions are taken (reduce size, skip trades, halt)?
- Are thresholds configurable?
- Is circuit breaker actually called in strategy?

**Inspect**:
```bash
Read("nautilus_gold_scalper/src/risk/circuit_breaker.py")
grep -rn "circuit.*breaker\|CircuitBreaker" nautilus_gold_scalper/src/strategies/
```

### 7. Integration Validation

**Check strategy integration**:
- Does `gold_scalper_strategy.py` import risk modules?
- Are risk checks performed BEFORE order submission?
- Are risk updates performed AFTER fills/cancels?
- Is HWM updated on every equity change?
- Are time checks performed continuously?

**Execution flow**:
```
on_bar/on_tick:
  ├─> Update equity
  ├─> Update HWM (if equity > HWM)
  ├─> Check trailing DD → HALT if violated
  ├─> Check time → CLOSE if past 4:59 PM
  ├─> Check consistency → SKIP if limit hit
  ├─> Calculate position size (DD-aware)
  ├─> Check circuit breaker → REDUCE or SKIP if triggered
  └─> Submit order (if all checks pass)
```

**Validate**: Is this flow present?

### 8. Configuration Audit

**Check config files**:
- `configs/risk_config.yaml` or similar
- Are Apex limits hardcoded or configurable?
- Are defaults SAFE (conservative)?

**Example safe config**:
```yaml
prop_firm: "apex"  # NOT "ftmo"
trailing_dd_limit: 10.0  # percent
dd_buffer: 2.0  # stop trading at 8% to avoid breach
time_cutoff: "16:59"  # 4:59 PM
consistency_limit: 30.0  # percent of total profit
max_risk_per_trade: 0.5  # percent of balance
```

### 9. Gap Identification

**Missing features**:
- Alerts/notifications when approaching limits?
- Logging of risk events (DD changes, time warnings)?
- Backtesting mode vs live mode (stricter in live)?
- Emergency contact (halt trading remotely)?

---

## Droid Assignment

**Use SENTINEL droid** for this task:
- Expert in Apex Trading risk management
- Knows trailing DD, time constraints, consistency rules
- Can calculate position sizing with DD buffers
- Provides GO/NO-GO risk assessments

Invoke with:
```
Task(
  subagent_type="sentinel-apex-guardian",
  description="Apex risk audit",
  prompt="[This entire prompt]"
)
```

---

## Output Specification

### Primary Output

**File**: `.prompts/004-apex-risk-audit/apex-risk-audit.md`

**Structure**:
```markdown
# Apex Trading Risk Management Audit Report

<metadata>
<confidence>HIGH|MEDIUM|LOW</confidence>
<apex_compliance_score>0-10</apex_compliance_score>
<critical_issues>N</critical_issues>
<ftmo_remnants>N</ftmo_remnants>
</metadata>

## Executive Summary

[300 words - compliance status, critical gaps, GO/NO-GO for live trading]

## Rule Comparison: Apex vs FTMO

| Rule | FTMO | Apex | Status | Issues |
|------|------|------|--------|--------|
| Overall DD | Fixed 10% | Trailing 10% HWM | ✅/❌ | [Details] |
| HWM tracking | Not used | Critical | ✅/❌ | [Details] |
| Unrealized P&L | Excluded | Included | ✅/❌ | [Details] |
| Time constraint | None | 4:59 PM ET | ✅/❌ | [Details] |
| Overnight | Allowed | Forbidden | ✅/❌ | [Details] |
| Consistency | None | 30% max | ✅/❌ | [Details] |

**Compliance Score**: X/10 - [Rationale]

## Trailing Drawdown Audit

### Implementation Status
**Status**: ✅ CORRECT | ⚠️ PARTIAL | ❌ INCORRECT

### HWM Tracking
**Code**: [File:line reference]
**Logic**: [Show formula]
**Validation**: [Is it correct?]
**Issues**: [If any]

### DD Calculation
**Formula**: `current_DD = (HWM - current_equity) / HWM * 100`
**Implemented**: ✅ YES | ❌ NO
**Includes unrealized P&L**: ✅ YES | ❌ NO
**Update frequency**: [Every tick/trade/bar?]

### Violation Handling
**Action**: [Terminate account / Reset / Warning?]
**Correct for Apex**: ✅ YES | ❌ NO

## Time Constraint Audit

### Time Checks Implementation
| Level | Time | Action | Implemented | Issues |
|-------|------|--------|-------------|--------|
| Warning | 4:00 PM | Alert | ✅/❌ | [...] |
| Urgent | 4:30 PM | Start close | ✅/❌ | [...] |
| Emergency | 4:55 PM | Close all | ✅/❌ | [...] |
| Deadline | 4:59 PM | Must be flat | ✅/❌ | [...] |

**Timezone**: [Correct ET handling? Evidence]
**Forced closure**: [Is it implemented? Evidence]

## Consistency Rule Audit

**Implementation Status**: ✅ IMPLEMENTED | ⚠️ PARTIAL | ❌ MISSING

**Total profit tracking**: [How? Evidence]
**Daily profit tracking**: [How? Evidence]
**30% limit enforcement**: [How? Evidence]
**Action when hit**: [Stop trades / Close positions?]

## Position Sizing Audit

### DD-Aware Sizing
**Status**: ✅ IMPLEMENTED | ❌ MISSING
**Logic**: [How does it account for trailing DD?]
**Evidence**: [Code reference]

### Kelly Criterion
**Status**: ✅ IMPLEMENTED | ❌ NOT USED
**Capping**: [Max Kelly factor? e.g., 0.25]
**Safe for Apex**: ✅ YES | ❌ TOO AGGRESSIVE

### ATR-Based Sizing
**Status**: ✅ IMPLEMENTED | ❌ NOT USED
**Parameters**: [Window, multiplier]
**Safe for Apex**: ✅ YES | ❌ ISSUES

### Max Risk/Trade
**Value**: X% of balance
**Enforced**: ✅ YES | ❌ NO
**Configurable**: ✅ YES | ❌ HARDCODED
**Safe for Apex**: ✅ YES (≤1%) | ❌ TOO HIGH

## Circuit Breaker Validation

### Implementation Status
**Levels present**: X/6
**Fully functional**: ✅ YES | ⚠️ PARTIAL | ❌ NO

| Level | Trigger | Action | Status | Issues |
|-------|---------|--------|--------|--------|
| 1 | First loss | Reduce size 50% | ✅/❌ | [...] |
| 2 | 2 losses | Reduce size 75% | ✅/❌ | [...] |
| 3 | 3 losses | Skip next trade | ✅/❌ | [...] |
| 4 | DD > 8% | Reduce size 90% | ✅/❌ | [...] |
| 5 | Win rate < 40% | Skip trades | ✅/❌ | [...] |
| 6 | Emergency | Halt all | ✅/❌ | [...] |

**Integration**: [Is it called in strategy? Evidence]

## Strategy Integration Validation

### Execution Flow
**Correct flow present**: ✅ YES | ❌ NO

**Checks performed BEFORE order**:
- [ ] Trailing DD check
- [ ] Time constraint check
- [ ] Consistency rule check
- [ ] Circuit breaker check
- [ ] Position size calculation

**Updates AFTER fills**:
- [ ] Equity update
- [ ] HWM update
- [ ] Profit tracking
- [ ] Circuit breaker state

**Evidence**: [Code references showing flow]

## Configuration Audit

### Config File
**Location**: [Path or "NOT FOUND"]
**Apex configured**: ✅ YES | ❌ STILL FTMO

### Values
```yaml
prop_firm: [VALUE]
trailing_dd_limit: [VALUE]
dd_buffer: [VALUE]
time_cutoff: [VALUE]
consistency_limit: [VALUE]
max_risk_per_trade: [VALUE]
```

**Safe defaults**: ✅ YES | ❌ TOO AGGRESSIVE

## FTMO Remnants

**Found**: N references to FTMO

| File | Line | Issue | Fix |
|------|------|-------|-----|
| [...] | [...] | [...] | [...] |

## Gap Analysis

### Critical Gaps (P0)
1. [Gap + impact + proposed fix]
2. ...

### Important Gaps (P1)
1. [Gap + impact + proposed fix]
2. ...

### Minor Gaps (P2)
1. [Gap + proposed enhancement]
2. ...

## GO/NO-GO Assessment

**Current Status**: ⛔ NO-GO | ⚠️ CONDITIONAL | ✅ GO

**Blockers** (if NO-GO):
1. [Critical issue preventing live trading]
2. ...

**Conditions** (if CONDITIONAL):
1. [Issue to fix before live + effort estimate]
2. ...

**Rationale**: [Why this verdict]

## Recommendations

### Immediate Actions (P0)
1. [Action + effort estimate]
2. ...

### Important Actions (P1)
1. [Action + effort estimate]
2. ...

### Enhancements (P2)
1. [Nice-to-have feature]
2. ...

## Next Steps

1. [Concrete action]
2. [Concrete action]
3. ...

<open_questions>
- [What remains uncertain]
</open_questions>

<assumptions>
- [What was assumed]
</assumptions>

<dependencies>
- [What's needed to proceed]
</dependencies>
```

### Secondary Output

**File**: `.prompts/004-apex-risk-audit/SUMMARY.md`

```markdown
# Apex Risk Audit - Summary

## One-Liner
[E.g., "Trailing DD not implemented; time constraints missing; NO-GO for live Apex trading"]

## Version
v1 - Initial audit (2025-12-07)

## Key Findings
• [Critical finding 1]
• [Critical finding 2]
• [Critical finding 3]
• [Compliance score: X/10]

## Decisions Needed
- [E.g., "Approve 5-day effort to implement full Apex compliance"]

## Blockers
- [E.g., "Trailing DD logic must be rewritten before live"]

## Next Step
[E.g., "Implement trailing DD with HWM tracking"]
```

---

## Tools to Use

**Essential**:
- `Read` - Read risk modules
- `Grep` - Search for FTMO remnants, Apex config, time checks
- `calculator` - Validate DD formulas, position sizing math

**Validation**:
```bash
# FTMO remnants
grep -rn "FTMO\|ftmo" nautilus_gold_scalper/src/risk/

# Apex config
grep -rn "Apex\|apex\|trailing.*dd\|HWM" nautilus_gold_scalper/src/risk/

# Time checks
grep -rn "4:59\|cutoff\|ET.*time\|America/New_York" nautilus_gold_scalper/

# Consistency
grep -rn "consistency\|30.*percent" nautilus_gold_scalper/
```

---

## Success Criteria

**Audit Completeness**:
- [ ] All Apex rules verified with evidence
- [ ] Trailing DD logic validated (formula, HWM, frequency)
- [ ] Time constraints checked (4 levels, timezone, enforcement)
- [ ] Consistency rule assessed
- [ ] Position sizing Apex-compatible
- [ ] Circuit breaker fully validated
- [ ] FTMO remnants identified

**Output Quality**:
- [ ] Compliance score justified with evidence
- [ ] GO/NO-GO verdict clear and actionable
- [ ] Recommendations prioritized with effort
- [ ] SUMMARY.md has substantive assessment

**Validation**:
- [ ] At least 3 risk modules inspected in detail
- [ ] Trailing DD formula verified with calculator
- [ ] Integration flow traced in strategy code

---

## Intelligence Rules

**Depth**: Apex compliance is CRITICAL - be meticulous.

**Evidence**: Every status claim needs code reference.

**Calculations**: Use calculator tool to verify DD/sizing math.

---

## Notes

- User suspects "gestão de risco não está adequada"
- Trailing DD is THE critical Apex difference vs FTMO
- This audit determines if system is safe for live Apex trading
