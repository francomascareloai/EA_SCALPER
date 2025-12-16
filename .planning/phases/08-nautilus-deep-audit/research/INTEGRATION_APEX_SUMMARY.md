# ARGUS Integration Summary: Apex Prop Firm Findings

**Date**: 2025-12-16
**Source**: ARGUS_PROP_FIRM_FAILURES.md (47 failure modes identified)
**Integrator**: SENTINEL (Apex Trading Guardian)
**Status**: COMPLETE

---

## Executive Summary

Integrated critical Apex prop firm findings from ARGUS research into the deep audit plan files. Focus on TRADOVATE-specific rules since user operates on TRADOVATE (not RITHMIC).

### Key Context
- **Platform**: TRADOVATE (different behavior from RITHMIC)
- **Position Sizing**: SMALL (conservative approach)
- **Execution Bridge**: NinjaTrader (file-based OTP)
- **Compliance Target**: 100% - zero tolerance for errors

---

## Files Updated

### 1. Phase 03 Plan (Risk Modules)
**File**: `04-PHASE-03-PLAN.md`

**Added Sections**:
- TRADOVATE-Specific Verification table (7 critical checks)
- Platform Error Handling (TRADOVATE-specific) checklist
- Connection Resilience verification
- Gap Risk Mitigation checklist
- Slippage Buffer Verification
- TRADOVATE vs RITHMIC Difference Matrix
- 30% Per-Trade Loss Calculation section
- 30% Consistency Rule Verification
- 5:1 Risk-Reward Enforcement

### 2. Phase 05 Plan (Execution Layer)
**File**: `06-PHASE-05-PLAN.md`

**Added Sections**:
- TRADOVATE Order Rejection Handling Verification table (6 error types)
- Order Rejection Recovery Matrix (5 rejection scenarios)
- Rate Limiting Requirements
- Platform Disconnect Scenario Verification
- NinjaTrader OTP Bridge Verification
- News Window Execution Blocking
- Execution Model Apex Compliance (ApexExecutionConfig class)
- Execution Edge Cases from ARGUS (6 edge cases)

### 3. Protocols (PROTOCOLS.md)
**File**: `PROTOCOLS.md`

**Added Section**: Protocol 14 - Apex Prop Firm Compliance Protocol

**Subsections**:
- A. Trailing Drawdown (CRITICAL) - with TRADOVATE eternal trailing
- B. Time Gates (CRITICAL)
- C. 30% Per-Trade Loss Rule (HIGH)
- D. 30% Consistency Rule (HIGH)
- E. 5:1 Risk-Reward Enforcement (HIGH)
- F. Contract Scaling Rule (PA Only)
- G. News Blackout Windows (HIGH)
- H. Platform Error Handling (TRADOVATE-specific)
- I. Automation Prohibition Awareness
- J. Slippage Buffer Requirements
- Apex Compliance Summary Template

---

## Critical TRADOVATE Differences from RITHMIC

| Feature | RITHMIC | TRADOVATE |
|---------|---------|-----------|
| Trailing stops when EOD balance reaches safety net | YES | **NO (never stops during evaluation)** |
| Safety net locks threshold | YES | Only behavior, not locking |
| Real-time unrealized tracking | YES | YES |

**This is the most critical finding**: On TRADOVATE, the trailing threshold **never stops trailing** during evaluation. This removes the safety net that RITHMIC traders rely on.

---

## Top 10 Critical Items for Audit Verification

| # | Item | Severity | Plan File |
|---|------|----------|-----------|
| 1 | HWM includes unrealized P/L (tick-level) | CRITICAL | Phase 03, PROTOCOLS |
| 2 | TRADOVATE trailing never stops | CRITICAL | Phase 03, PROTOCOLS |
| 3 | Time gates (4:30, 4:55, 4:59 PM ET) | CRITICAL | Phase 03, Phase 05 |
| 4 | SL rejection recovery (naked position) | CRITICAL | Phase 05 |
| 5 | Account-blown error detection | CRITICAL | Phase 05 |
| 6 | 30% per-trade loss limit | HIGH | Phase 03, PROTOCOLS |
| 7 | 30% consistency cap | HIGH | Phase 03, PROTOCOLS |
| 8 | 5:1 R:R enforcement | HIGH | Phase 03, PROTOCOLS |
| 9 | News blackout windows | HIGH | Phase 05, PROTOCOLS |
| 10 | Rate limiting on order modifications | HIGH | Phase 05 |

---

## Trailing DD Trap Example (Must Understand)

```
$50k account, trade spikes to $52k unrealized:
- HWM = $52k (raised by unrealized!)
- New floor = $49.4k ($52k x 0.95 = 5% below HWM)
- Trade retraces and closes at $50.1k realized
- Result: Only $700 buffer left! (lost $1,400 from spike)

The unrealized spike PERMANENTLY raised the HWM.
The threshold never goes back down.
```

---

## Automation Prohibition Warning

**CRITICAL FINDING**: Automation is BANNED on PA/Live accounts

| Phase | Automation Status |
|-------|-------------------|
| Evaluation | Grey area (not explicitly banned) |
| PA (Performance Account) | **BANNED** |
| Live Account | **BANNED** |

**Mitigation Required**: Plan for semi-auto mode (EA provides signals, human executes) for PA/Live accounts.

---

## Recommended Next Steps

1. **Phase 03 Execution**: Apply TRADOVATE-specific verification checklist when auditing risk modules
2. **Phase 05 Execution**: Verify order rejection handling with TRADOVATE error codes
3. **All Phases**: Apply Protocol 14 (Apex Prop Firm Compliance Protocol) verification template
4. **Strategy Planning**: Address automation prohibition for PA/Live transition

---

## Verification Artifacts

After audit completion, the following should be documented:

- [ ] Trailing DD verification trace (code locations)
- [ ] Time gate verification trace (code locations)
- [ ] 30% per-trade limit implementation status
- [ ] 30% consistency cap implementation status
- [ ] 5:1 R:R validation implementation status
- [ ] Order rejection handling implementation status
- [ ] News blackout implementation status
- [ ] Platform error handling implementation status

---

*Integration completed by SENTINEL v3.1*
*Source: ARGUS Research (47 failure modes, 15+ sources triangulated)*
