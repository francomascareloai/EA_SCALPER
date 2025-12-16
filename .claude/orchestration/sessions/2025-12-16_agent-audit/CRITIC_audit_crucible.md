# CRITIC ADVERSARIAL AUDIT: CRUCIBLE v4.1

```
AGENT: CRITIC
VERSION: v1.1
CLAUDE_MD_VERSION: 3.10.9
STATUS: COMPLETE
```

---

## Artifact Under Review

**Target**: `.claude/agents/crucible-gold-strategist.md`
**Type**: Sub-agent Specification
**Version**: CRUCIBLE v4.1 - Backtest Quality Guardian
**Reviewer**: CRITIC v1.1
**Date**: 2025-12-16

---

## VERDICT: PASS_WITH_NOTES

The specification is functional and covers core realism validation well. However, there are compliance gaps with CLAUDE.md orchestration protocol and several HIGH-severity issues that should be addressed before heavy orchestration use.

---

## SEVERITY SUMMARY

| Severity | Count |
|----------|-------|
| CRITICAL | 0 |
| HIGH | 4 |
| MEDIUM | 8 |
| LOW | 6 |

---

## HIGH ISSUES

### H1: Incomplete Apex Time Gates (Gates 19-22)

**Location**: Gates 19-22 (Prop Firm section)

**Finding**: CLAUDE.md specifies THREE time gates for Apex compliance:
1. 4:30 PM ET - Block new trades
2. 4:55 PM ET - Emergency force-close
3. 4:59 PM ET - Must be flat

CRUCIBLE's Gate 21 only mentions "Flat by 4:59 PM ET", missing the critical 4:30 PM and 4:55 PM gates.

**Impact**: A strategy could pass CRUCIBLE's realism gates while violating Apex's full time gate protocol. This could lead to emergency close failures or late trades.

**Fix**: Add two new gates:
- Gate 21a: "New trade block after 4:30 PM ET"
- Gate 21b: "Emergency force-close active from 4:55 PM ET"

---

### H2: No Structured Output Format

**Location**: Entire specification

**Finding**: CRUCIBLE has no template for structured, parseable output. Compare to CRITIC which has:
```
VERDICT: [BLOCKED / ISSUES_FOUND / PASS_WITH_NOTES]
CRITICAL ISSUES
HIGH ISSUES
...
```

CRUCIBLE's commands (`/realism`, `/slippage`, `/spread`, `/validate`, `/gonogo`, `/propfirm`) have undefined output formats.

**Impact**:
- Inconsistent outputs across invocations
- Harder for downstream agents (ORACLE, SENTINEL) to parse
- No clear PASS/FAIL indicator

**Fix**: Add output template section:
```
## Output Format

CRUCIBLE REALISM ASSESSMENT
===========================
Strategy: [name/description]
Reviewer: CRUCIBLE v4.1

VERDICT: [REALISTIC / CONCERNS / UNREALISTIC]

GATES SUMMARY
-------------
PASSED: [count]/25
FAILED: [list with gate numbers]

CRITICAL GATE FAILURES
---------------------
[Gate #]: [description] - [actual value] vs [required]

XAUUSD PARAMETERS APPLIED
-------------------------
Session: [detected session]
Spread: [applied]
Slippage: [applied]
Latency: [applied]

RECOMMENDATIONS
---------------
1. [action]

HANDOFF TO: [ORACLE/SENTINEL/FORGE]
Status: READY / BLOCKED
```

---

### H3: `/gonogo` Command Ambiguity

**Location**: Commands table

**Finding**: The specification explicitly states:
> "CRUCIBLE proposes; final GO/NO-GO = ORACLE + SENTINEL"

Yet CRUCIBLE has a `/gonogo [strategy]` command described as "Full GO/NO-GO assessment". This creates role confusion.

**Impact**: An operator might invoke `/gonogo` and believe CRUCIBLE can approve live deployment, bypassing ORACLE and SENTINEL.

**Fix Options**:
1. Rename to `/prepare-gonogo` or `/gonogo-assessment` to clarify it's preparation only
2. Add explicit note: "Prepares assessment for ORACLE+SENTINEL final decision"
3. Add to Guardrails: "NEVER claim final GO/NO-GO authority"

---

### H4: Missing Spread vs SL Ratio Validation

**Location**: Execution Gates (1-8)

**Finding**: No gate validates that stop loss distance exceeds expected spread. A strategy with SL tighter than typical spread would pass all gates but fail live.

**Impact**: Strategies with tight SLs could appear realistic in backtest but get stopped out immediately in live due to spread.

**Fix**: Add new gate:
- Gate 4a: "SL distance >= 2x maximum expected spread for session"

Or as part of Gate 4:
- Gate 4 (revised): "Variable spread AND SL > 2x spread"

---

## MEDIUM ISSUES

### M1: Missing Version Reporting

**Location**: Output/header section (missing)

**Finding**: CLAUDE.md v3.10.9 requires:
```
## Agent Output Header
AGENT: [name]
VERSION: [from spec, e.g., FORGE v2.1]
CLAUDE_MD_VERSION: [e.g., 3.10.9]
STATUS: COMPLETE/PARTIAL/FAILED
```

CRUCIBLE has no version output requirement.

**Impact**: Orchestrator cannot verify spec version, risking stale spec usage.

**Fix**: Add to output template.

---

### M2: Self-Review Missing 2 CRITIC Techniques

**Location**: CRITIC Self-Review Protocol section

**Finding**: CRITIC v1.1 defines 7 techniques:
1. INVERSION
2. PRE-MORTEM
3. STRESS TEST
4. REGIME SHIFT
5. APEX TRAP
6. EDGE CASES
7. ASSUMPTION AUDIT

CRUCIBLE's self-review only lists 5: INVERSION, PRE-MORTEM, STRESS TEST, APEX TRAP, EDGE CASES.

Missing: REGIME SHIFT, ASSUMPTION AUDIT

**Impact**: Incomplete adversarial coverage during self-review.

**Fix**: Update line 176 to include all 7 techniques.

---

### M3: Gate 20 Missing "Unrealized" Clarification

**Location**: Gate 20

**Finding**: CLAUDE.md explicitly states:
> "Trailing DD = 5% from HIGH-WATER MARK (includes unrealized)"

Gate 20 says only: "Trailing DD (Apex): <= 5% from HWM (buffer 4%)"

The critical "includes unrealized" is missing.

**Impact**: Could be misinterpreted - someone might calculate HWM only on realized P/L.

**Fix**: Gate 20: "Trailing DD <= 5% from HWM (HWM includes unrealized P/L, buffer 4%)"

---

### M4: "Large Orders" Undefined Threshold

**Location**: Gate 7

**Finding**: Gate 7 says "Partial fills: Enabled for large orders" but doesn't define "large".

**Impact**: Ambiguous - what's large? 5 lots? 10 lots? 50 lots?

**Fix**: Gate 7: "Partial fills: Enabled for orders >= 5 lots"

---

### M5: Statistical Validation Overlap with ORACLE

**Location**: Gates 13-18 (Statistical)

**Finding**: Gates 13-18 cover WFE, OOS, MC 95th DD, parameters. But ORACLE is specifically for "Backtest/WFA/GO-NOGO". This creates role overlap.

**Impact**: Duplicate validation work OR gaps if each agent assumes the other handles it.

**Fix**: Clarify in CRUCIBLE spec:
> "Gates 13-18 are PRE-CHECKS. CRUCIBLE verifies realism prerequisites; ORACLE performs deep statistical validation."

---

### M6: Missing structured_handoff Format

**Location**: Handoffs section

**Finding**: CLAUDE.md v3.10.9 has a structured_handoff format requirement:
```
## HANDOFF: [Source Agent] -> [Target Agent]
### Context
### Decisions Made
### Assumptions
### Risks Identified
### Open Questions
### Next Agent Should
```

CRUCIBLE's handoff section lists targets but no format.

**Impact**: Information loss during handoffs.

**Fix**: Add structured_handoff format requirement to Handoffs section.

---

### M7: Stride-20 Dataset Suitability Assumption

**Location**: CORE section, default dataset

**Finding**: Default dataset is `xauusd_2003_2025_stride20_full.parquet` (stride 20 = 1 tick every 20). For a SCALPER, this reduced granularity might miss critical price movements.

**Impact**: Scalping strategies validated on stride-20 data may behave differently on full tick data.

**Fix**: Add note:
> "Stride-20 data is suitable for swing/day trading. For sub-minute scalping, consider stride-1 or full tick data."

---

### M8: No Error Handling Protocol

**Location**: Entire specification

**Finding**: No protocol for handling errors (invalid data, malformed config, missing files).

**Impact**: CRUCIBLE could fail silently or produce undefined behavior.

**Fix**: Add section:
```
## Error Handling
| Error | Action |
|-------|--------|
| Invalid data file | BLOCK with "Data file invalid/missing" |
| Malformed config | List specific issues, request correction |
| Missing required param | Ask for: [list required params] |
```

---

## LOW ISSUES

### L1: Gate 24 Vague ("DXY, yields handled")

**Location**: Gate 24

**Finding**: "Handled" is undefined. Does it mean filtered? Correlated? Ignored during divergence?

**Fix**: Gate 24: "DXY/yields correlation: Strategy behavior defined for correlation breakdown"

---

### L2: No Flash Crash/Black Swan Gate

**Location**: Execution Gates

**Finding**: No gate for extreme volatility / circuit breaker behavior.

**Fix**: Add Gate 8a: "Circuit breaker: Position reduced/closed if spread > 5x normal"

---

### L3: No Minimum Position Size Validation

**Location**: Execution Gates

**Finding**: No gate for what happens if lot sizing calculation returns 0.

**Fix**: Add to Gate 8 or new gate: "Position size >= minimum lot (0.01)"

---

### L4: Market Order Rejection Not Covered

**Location**: Gate 6

**Finding**: Gate 6 covers limit rejection (1-5%) but not market order rejection.

**Fix**: Gate 6: "Order rejection: Limit 1-5%, Market 0.1-1%"

---

### L5: Regime Detection Without Implementation Guidance

**Location**: Gate 25

**Finding**: "Regime detection: Volatility filtering" but no specific indicators mentioned.

**Fix**: Add example: "(e.g., ATR ratio, Hurst exponent, HMM states)"

---

### L6: No Memory Integration for Learning

**Location**: Entire specification

**Finding**: CLAUDE.md references memory MCP for patterns/decisions. CRUCIBLE doesn't use it.

**Fix**: Optional - Add to CORE:
> "Use memory MCP to store/recall: validated realism configurations, session-specific parameters, failed pattern signatures"

---

## ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| 0.5 pip slippage minimum is realistic | Slippage table shows 0.5-2.0 for market, 1.0-5.0 for stops. Minimum is optimistic. | Consider 1.0 pip minimum for conservative validation |
| 50ms latency is appropriate | Depends on deployment (retail vs VPS vs colo) | Parameterize or add environment context |
| 25 gates are comprehensive | Missing: time gate granularity, spread/SL ratio, flash crash handling | Add 3-4 additional gates as noted |
| CRUCIBLE can assess realism independently | Statistical gates (13-18) overlap with ORACLE | Clarify pre-check vs deep validation scope |

---

## EDGE CASES TESTED

| Scenario | Coverage | Gap |
|----------|----------|-----|
| Position size = 0 | Not covered | Add minimum lot gate |
| Spread > SL | Not covered | Add spread/SL ratio gate |
| Partial fills | Gate 7 | "Large" undefined |
| Limit rejection | Gate 6 | Market rejection missing |
| Weekend gaps | Gate 12 | Covered |
| Flash crash | Not covered | Add circuit breaker gate |
| Correlation breakdown | Gate 24 | Vague definition |

---

## STRESS TEST RESULTS

| Condition | Handling | Notes |
|-----------|----------|-------|
| Spread 2x normal | Session multipliers defined | Good coverage |
| Slippage 5x normal | Not explicit | Only 2x for news defined |
| Asia low liquidity | Gate 23 | "Avoid scalping" - good |
| High impact news | Spread 50-100+ defined | Good |
| HWM with unrealized | Gate 20 (incomplete) | Missing "unrealized" note |

---

## MANUAL VERIFICATION NEEDED

- [ ] Verify Gates 13-18 authority split with ORACLE spec
- [ ] Confirm stride-20 dataset is acceptable for intended scalping timeframe
- [ ] Validate 0.5 pip minimum slippage against historical broker data
- [ ] Review `/gonogo` command behavior in practice

---

## PRE-MORTEM SUMMARY

**Most likely failure mode**: Operator invokes `/gonogo`, believes CRUCIBLE can approve live deployment, bypasses ORACLE/SENTINEL, deploys with compliance gaps.

**Second most likely**: Strategy passes all 25 gates but has SL tighter than typical spread, fails immediately in live.

**Third most likely**: Time gate violation at 4:30 PM or 4:55 PM not caught because only 4:59 PM is checked.

**Mitigation**: Address HIGH issues H1-H4 before heavy orchestration use.

---

## RECOMMENDATIONS (Prioritized)

1. **IMMEDIATE**: Add Gates 21a/21b for 4:30 PM and 4:55 PM time gates
2. **IMMEDIATE**: Add structured output format template
3. **HIGH**: Rename `/gonogo` to `/prepare-gonogo` or add explicit authority limitation
4. **HIGH**: Add spread vs SL ratio validation gate
5. **MEDIUM**: Add version reporting to output
6. **MEDIUM**: Complete self-review technique list (add REGIME SHIFT, ASSUMPTION AUDIT)
7. **MEDIUM**: Add structured_handoff format requirement

---

## CONFIDENCE: HIGH

**Reason**: Thorough review using all 7 CRITIC techniques. Findings are specific, actionable, and traceable to CLAUDE.md requirements. The spec is fundamentally sound but needs compliance updates.

---

*"Every gap found in the spec is a failure prevented in production."*

CRITIC v1.1 - Adversarial Quality Guardian
