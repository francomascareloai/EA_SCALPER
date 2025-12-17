# CRITIC ADVERSARIAL REVIEW - Phase 03 Plan

**Artifact:** `/home/franco/projetos/EA_SCALPER_XAUUSD/.planning/phases/08-nautilus-deep-audit/04-PHASE-03-PLAN.md`
**Type:** Plan
**Reviewer:** CRITIC v1.2
**Mode:** EXTERNAL-CRITIC
**Date:** 2025-12-16

---

## VERDICT: APPROVED WITH NOTES

| Severity | Count |
|----------|-------|
| CRITICAL | 0 |
| HIGH | 3 |
| MEDIUM | 4 |
| LOW | 2 |

**Recommendation:** Apply the 5 required fixes below before spawning agents for execution.

---

## HIGH ISSUES (Must Fix)

### H-001: ARGUS Checks Not Assigned to Agents

**Location:** Lines 27-45 (Agent Assignments) vs Lines 435-521 (ARGUS Integration)

**Description:** The ARGUS research section was APPENDED to the plan but NOT INTEGRATED into agent assignments. The TRADOVATE-specific checks (trailing DD never-locks, 30% per-trade loss, 5:1 R:R, commission tracking) are listed but no agent is explicitly assigned to verify them.

**Impact:** During execution, agents will follow their assignments (lines 27-45) and may never see the ARGUS requirements (lines 435-521). These critical TRADOVATE-specific checks could fall through the cracks.

**Fix:** Update agent assignments to include ARGUS scope:
- Agent A: Add "Also verify TRADOVATE trailing DD never-locks behavior (lines 441-444)"
- Agent B: Add "Also verify 30% per-trade loss rule (lines 483-495)"
- Agent C: Add "Also verify commission tracking in DD (line 449)"

---

### H-002: 30% Per-Trade Loss Limit Not in position_sizer.py Checklist

**Location:** Lines 284-292 (position_sizer.py checklist) vs Lines 483-495 (30% per-trade loss calculation)

**Description:** The ARGUS section defines the 30% per-trade loss rule ($750 max on new $50k account), but the CRITIC checklist for position_sizer.py has no verification item for this rule.

**Impact:** Agent C will review position_sizer.py against the existing checklist and miss this critical sizing constraint. Trade sizing could violate the 30% per-trade limit.

**Fix:** Add to position_sizer.py checklist (lines 284-292):
```
| 30% per-trade loss limit respected | [ ] |
| Aggregate P/L tracking for multiple positions | [ ] |
| Buffer to 25% instead of 30% (slippage protection) | [ ] |
```

---

### H-003: 5:1 R:R Enforcement Module Not Identified

**Location:** Lines 512-520 (5:1 R:R Enforcement)

**Description:** The ARGUS section requires SL cannot exceed 5x TP (5:1 R:R rule), with verification items. However, none of the 9 risk modules in scope appear to handle R:R validation.

**Impact:** Without knowing which module enforces R:R, this verification will not occur during Phase 03. Violation of 5:1 rule could lead to payout denial.

**Fix:** Either:
a) Identify which module handles R:R (likely position_sizer.py or prop_firm_manager.py) and add to checklist
b) Mark as "Out of Phase 03 scope - Strategy/Entry module concern" and add to Phase 04 scope

---

## MEDIUM ISSUES

### M-001: TRADOVATE-Specific Stress Scenarios Missing from Stress Test Tables

**Location:** Lines 217-242 (Stress Test Scenarios)

**Description:** The ARGUS section describes TRADOVATE-specific scenarios (gap risk, news slippage, trailing DD behavior) but the stress test tables were not updated.

**Impact:** Agents may not stress test against TRADOVATE-specific edge cases.

**Fix:** Add to drawdown_tracker.py stress tests (after line 225):
| TRADOVATE trailing never-locks | HWM spike 0.5% above safety net then retrace | DD continues, no lock protection |

---

### M-002: Connection Resilience Checks May Be Out of Scope

**Location:** Lines 459-463 (Connection Resilience)

**Description:** ARGUS lists connection handling requirements (disconnect, reconnect, heartbeat). These are infrastructure concerns, not risk module concerns. The 9 modules under review don't handle network connectivity.

**Impact:** Confusion about scope during execution.

**Fix:** Add clarification: "Note: Connection resilience (lines 459-463) is infrastructure scope, not risk module scope. Will be addressed in separate audit or by NAUTILUS."

---

### M-003: Commission Tracking Module Not Identified

**Location:** Line 449 ("Commission tracking in DD")

**Description:** ARGUS requires commissions/fees included in P/L calculation for DD. None of the 9 modules explicitly mentions commission tracking in failure mode analysis.

**Impact:** Commission tracking may not be verified because ownership is unclear.

**Fix:** Clarify: "Commission tracking responsibility: drawdown_tracker.py (equity calculation includes fees)" or identify correct owner.

---

### M-004: Three Different 30% Rules Not Clearly Distinguished

**Location:** Lines 131-142, 483-495, 497-510

**Description:** The plan mentions three different "30%" rules:
1. 30% daily profit cap (original Rule 4)
2. 30% per-trade open loss limit (ARGUS)
3. 30% consistency/windfall at payout (ARGUS)

These could be confused during verification.

**Impact:** Agents may verify one 30% rule thinking they've covered all three.

**Fix:** Add clarification table:

| Rule Name | Description | Module Responsible |
|-----------|-------------|-------------------|
| 30% Daily Profit Cap | No single day > 30% of trailing threshold | consistency_tracker.py |
| 30% Consistency (Windfall) | At payout, no single day > 30% of total profit | consistency_tracker.py |
| 30% Per-Trade Loss | Open negative P/L cannot exceed 30% of profit balance | position_sizer.py |

---

## LOW ISSUES

### L-001: No Time Estimates for Execution Steps

**Location:** Already noted in lines 543-544 (CRITIC RE-REVIEW)

**Status:** Acknowledged, not blocking.

---

### L-002: Test Execution Ownership Not Explicitly Assigned

**Location:** Already noted in lines 543-544 (CRITIC RE-REVIEW)

**Status:** Acknowledged, not blocking. Plan requires tests pass but doesn't specify which agent runs them.

---

## ADVERSARIAL TECHNIQUES APPLIED

### 1. INVERSION
"What would make this plan fail?"
- Found: Agent assignments not updated for ARGUS scope = checks fall through cracks

### 2. PRE-MORTEM
"It's 2026, account blew up. Why?"
- Scenario A: TRADOVATE trailing DD never-locks not verified
- Scenario B: 30% per-trade loss not enforced
- Scenario C: 5:1 R:R ignored

### 3. STRESS TEST
Applied extreme scenarios:
- Multiple positions aggregate 30% edge case identified
- TRADOVATE trailing after safety net stress scenario missing

### 4. REGIME SHIFT
Tested across conditions:
- High volatility (NFP/CPI) stress scenario not in tables
- Low liquidity (Asia session) handling unclear

### 5. APEX TRAP ANALYSIS
Specific prop firm rule analysis:
- Trailing DD never-locks trap: TRADOVATE-specific behavior not in main checklist
- 30% confusion trap: Three different 30% rules could be conflated

### 6. EDGE CASE HUNTING
Boundaries identified:
- 30% per-trade on $0 profit account
- Multiple positions aggregate vs individual
- 5:1 R:R with fractional ticks
- Emergency close retry at 4:59:01

### 7. ASSUMPTION AUDIT
Challenged assumptions:
- Assumption: ARGUS additions will be picked up by agents - FALSE
- Assumption: consistency_tracker handles all 30% rules - UNCLEAR
- Assumption: Some module handles commission tracking - UNCLEAR
- Assumption: 5:1 R:R is enforced somewhere - UNCLEAR

---

## ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| Agents will read ARGUS section | ARGUS appended after agent assignments; agents may stop reading before line 435 | Update agent assignments to include ARGUS scope explicitly |
| consistency_tracker.py handles all 30% rules | Only 61 lines; may only handle daily cap, not windfall or per-trade | Human verify actual implementation |
| Commission tracking exists somewhere | None of 9 modules mention it explicitly | Human verify which module owns this |
| 5:1 R:R is enforced | No module in scope handles R:R validation | Human identify correct module or mark out-of-scope |

---

## MANUAL VERIFICATION NEEDED

- [ ] Inspect consistency_tracker.py to verify which 30% rules it handles
- [ ] Search codebase for 5:1 R:R enforcement
- [ ] Confirm commission tracking implementation in drawdown_tracker.py or elsewhere
- [ ] Confirm connection resilience is out-of-scope for Phase 03
- [ ] Decide if position_sizer.py owns 30% per-trade limit

---

## CONFIDENCE

**Level:** HIGH

**Reason:** Applied all 7 adversarial techniques systematically. Found real integration gaps from ARGUS append (not true integration). Issues are HIGH severity but not CRITICAL. Underlying plan structure is excellent - previous C-001 to C-009 issues were properly fixed. Fixes are well-defined, achievable in 15-30 minutes.

---

## PRE-MORTEM SUMMARY

**Most likely failure mode:** TRADOVATE trailing DD never-locks behavior not verified because it wasn't assigned to any agent's explicit scope.

**Second most likely:** 30% per-trade loss limit not enforced because position_sizer.py CRITIC checklist doesn't include this verification item.

**Mitigation:** Apply the 5 fixes specified above before spawning agents for Phase 03 execution.

---

## WHAT PREVIOUS CRITIC REVIEW MISSED

The CRITIC RE-REVIEW section (lines 524-556) marked the plan APPROVED after verifying C-001 to C-009 were fixed. However, it did NOT verify that the ARGUS additions (lines 435-521) were properly integrated into the execution workflow. The review checked "were old issues fixed?" but not "do new additions create new gaps?"

**Meta-learning:** When reviewing plan updates, always check both:
1. Were previous issues fixed?
2. Do new additions create new integration gaps?

---

## VERDICT JUSTIFICATION

Per the plan's own Pass/Fail Criteria (lines 75-87):
- 0 CRITICAL issues: PASS
- <= 3 HIGH issues with mitigations: BORDERLINE (we have 3 HIGH, mitigations specified)
- All Apex rules verified: AT RISK (ARGUS additions not integrated)

The issues are INTEGRATION gaps, not STRUCTURAL flaws. The plan architecture is sound. With 5 specific fixes applied, the plan meets APPROVED criteria.

**Final Verdict: APPROVED WITH NOTES**

Required action: Apply fixes H-001, H-002, H-003, M-001, M-004 before spawning agents.

---

*CRITIC v1.2 - Adversarial Quality Guardian*
*"Every bug found now is a loss prevented later."*
