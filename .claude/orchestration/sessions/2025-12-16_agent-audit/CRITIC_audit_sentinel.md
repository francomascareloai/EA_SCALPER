# CRITIC Adversarial Audit: SENTINEL v3.1

**Artifact**: `.claude/agents/sentinel-apex-guardian.md`
**Type**: Agent Specification
**Reviewer**: CRITIC v1.1
**Date**: 2025-12-16
**CLAUDE_MD_VERSION**: 3.10.9

---

## VERDICT: ISSUES_FOUND

**Severity Counts**: 2 CRITICAL | 7 HIGH | 5 MEDIUM | 4 LOW

---

## CRITICAL ISSUES (Must Fix Before Production)

### CRITICAL-1: No Failure Handling for Emergency Close

**Location**: Time Zones section (lines 181-188)

**Issue**: The spec mandates "4:55 PM - EVERYTHING flat" but provides no protocol for when this fails.

**Scenarios not handled**:
- Market halted/illiquid at 4:55 PM
- Execution latency causes close to complete after 4:59 PM
- Order rejected due to spread/margin
- Connection drops during close attempt

**Impact**: Position held overnight = Apex violation = potential account termination.

**Fix**: Add explicit failure handling:
```
EMERGENCY_CLOSE_PROTOCOL:
1. Attempt market close at 4:55 PM ET
2. If fails → RETRY with 10-second intervals
3. If 3 retries fail → ESCALATE to manual (SMS/email)
4. Mandatory broker-side SL at 4:50 PM as backstop
5. Log all attempts for post-mortem
```

### CRITICAL-2: No Broker-Side Safety Mechanism

**Location**: Entire spec (implicit omission)

**Issue**: The spec relies 100% on client-side execution. No mention of server-side stop-loss or hedging as backup.

**Impact**: If client disconnects, crashes, or freezes, positions have no protection.

**Fix**: Mandate broker-side hard stops:
```
BROKER_SAFETY_LAYER:
- All positions MUST have broker-side SL set at max acceptable loss
- Update SL to HWM-5% floor at each HWM update
- Time-based: Set hard SL at 4:50 PM that guarantees close by 4:59 PM
```

---

## HIGH ISSUES

### HIGH-1: No Input Validation Protocol

**Location**: CORE section (lines 14-20)

**Issue**: Spec says "Missing data → conservative NO-GO" but doesn't define:
- How to detect missing/stale data
- Maximum acceptable staleness for HWM, equity, time
- Validation checks (e.g., HWM >= Current Equity sanity check)

**Fix**: Add explicit validation:
```
DATA_VALIDATION:
- HWM: Reject if stale > 5 seconds
- Equity: Validate against broker API every tick
- Time: Cross-validate with 2+ sources, handle DST explicitly
- Sanity: Assert HWM >= Realized Equity always
```

### HIGH-2: Ambiguous HWM Persistence Rules

**Location**: Apex Rules section (lines 70-88)

**Issue**: The "TRAILING DD TRAP" example shows HWM raised by unrealized P/L, but doesn't clarify:
- Does HWM persist after position closes?
- What happens with partial closes?
- Does HWM reset at EOD?

**Impact**: Miscalculating HWM = incorrect floor = false safety.

**Fix**: Add explicit HWM rules:
```
HWM_RULES:
- HWM = max(previous_HWM, current_equity + unrealized_PL)
- HWM NEVER decreases during trading day
- HWM is locked once set; partial closes don't reduce it
- EOD HWM becomes next day's starting HWM
- Verify against Apex's actual methodology
```

### HIGH-3: No Minimum SL-to-Spread Ratio

**Location**: Lot Sizing Formula (lines 151-176)

**Issue**: Formula uses SL_pips but doesn't mandate minimum SL relative to current spread.

**Impact**: If spread widens, a tight SL could be hit immediately on entry.

**Fix**: Add constraint:
```
SL_CONSTRAINT:
- Minimum SL = max(user_SL, 3 * current_spread)
- If user_SL < 3 * spread → NO_TRADE or warn user
```

### HIGH-4: Unclear Apex HWM Methodology Match

**Location**: Apex Rules section (lines 70-88)

**Issue**: Spec assumes HWM calculation matches Apex's, but this isn't verified.

**Questions unanswered**:
- Does Apex use real-time HWM or EOD?
- How does Apex handle gaps?
- What's Apex's exact unrealized P/L inclusion logic?

**Fix**:
```
APEX_VERIFICATION:
- Document Apex's official HWM methodology
- Add test cases comparing our calculation vs Apex
- If discrepancy found → use Apex's method
```

### HIGH-5: No Manual Escalation Protocol

**Location**: Handoffs section (lines 191-199)

**Issue**: Handoffs to other agents exist, but no "ALERT HUMAN" trigger.

**When needed**:
- All automated paths fail
- Conflicting agent decisions (SENTINEL vs ORACLE)
- DD near 4.5% with open positions

**Fix**: Add escalation:
```
HUMAN_ESCALATION:
- Triggers: Connection failure, 3x close retry fail, DD > 4.3%, agent conflict
- Methods: SMS, email, Slack webhook
- Format: "[URGENT] SENTINEL: [situation]. Action required by [deadline]"
```

### HIGH-6: Missing Audit Trail Requirement

**Location**: Entire spec (implicit omission)

**Issue**: No requirement to log decisions persistently.

**Impact**: Post-mortem analysis impossible if things go wrong.

**Fix**:
```
AUDIT_TRAIL:
- Log every GO/NO-GO decision with: timestamp, inputs, calculation, decision, rationale
- Store in persistent file (not just memory)
- Format: JSON for machine parsing
- Retention: 30 days minimum
```

### HIGH-7: Recovery from DD > 4.5% is Logically Impossible

**Location**: Recovery Protocol (lines 134-149)

**Issue**: "DD > 4.5% → HALT until DD < 3.5%"

**Problem**: If HALTED, no trading allowed. If no trading, how does DD recover?
- HWM doesn't decrease
- Equity doesn't increase without trading
- Result: Permanent HALT (stuck state)

**Fix**: Clarify recovery mechanism:
```
DD_RECOVERY:
- If DD > 4.5%: HALT trading, but DD can recover via:
  1. Apex account reset (if available)
  2. Wait for HWM decay (if Apex allows)
  3. Manual injection of capital (not allowed in prop firm)
- If recovery impossible: Account is effectively terminated → escalate to user
```

---

## MEDIUM ISSUES

### MEDIUM-1: Missing Fallback for Regime Detection

**Location**: Lot Sizing Formula (lines 169-174)

**Issue**: Regime multiplier requires input from CRUCIBLE but no fallback defined.

**Fix**:
```
REGIME_FALLBACK:
- If CRUCIBLE unavailable: assume MEAN_REVERTING (0.50 multiplier)
- If regime stale > 15 min: reduce to conservative multiplier
```

### MEDIUM-2: No Partial Fill or Rejection Handling

**Location**: Entire spec (implicit omission)

**Issue**: Position sizing assumes full fill. Partial fills or rejections not handled.

**Fix**: Add protocol:
```
EXECUTION_HANDLING:
- Partial fill: Recalculate risk with actual fill size
- Rejection: Log reason, retry once, then escalate
- Track fill rate for execution quality monitoring
```

### MEDIUM-3: 30% Consistency Rule Lacks Implementation Details

**Location**: Apex Rules (line 78), /consistency command

**Issue**: "Max 30% profit/day of total profit target" - but:
- What is "total profit target"? Not defined.
- How is it tracked?
- What action when approaching 30%?

**Fix**: Define explicitly:
```
CONSISTENCY_RULE:
- Total profit target = Apex challenge goal (e.g., $3k for $50k account)
- Daily max = 30% of target = $900
- At 25%: WARNING
- At 28%: REDUCE size to extend runway
- At 30%: STOP trading for day
```

### MEDIUM-4: MCP Availability Assumptions

**Location**: CORE section (lines 18-19)

**Issue**: "Tools: calculator (sizing), time (ET), memory (circuit-breaker state)" - but no fallback if MCP unavailable.

**Fix**:
```
MCP_FALLBACKS:
- Calculator: Use inline Python arithmetic as backup
- Time: Use system time with manual DST offset
- Memory: Persist circuit-breaker state to file as backup
```

### MEDIUM-5: Output Format Missing Required Fields

**Location**: Status Output Format (lines 239-263)

**Issue**: Per CLAUDE.md v3.10.9 `version_reporting`, agents must include:
- AGENT_VERSION
- CLAUDE_MD_VERSION

Also missing:
- Explicit GO/NO-GO field
- REASONING field
- DATA_SOURCES used
- ASSUMPTIONS made

**Fix**: Update output template:
```
SENTINEL APEX STATUS
====================
AGENT: SENTINEL
VERSION: v3.1
CLAUDE_MD_VERSION: 3.10.9
STATUS: [NORMAL/WARNING/CAUTION/SOFT STOP/EMERGENCY]
DECISION: [GO/NO-GO/ESCALATE]
...existing fields...
REASONING: [why this decision]
DATA_SOURCES: [HWM from X, time from Y]
ASSUMPTIONS: [list any]
```

---

## LOW ISSUES

### LOW-1: "Risky" Undefined at 4:45 PM Close Decision

**Location**: Time Zones section (line 186): "4:45 PM - Close ALL if risky"

**Issue**: Subjective term without definition.

**Fix**: Define explicitly: "Risky = DD > 2.5% OR position size > 50% max OR unrealized loss > 1%"

### LOW-2: Self-Review Protocol Could Be More Risk-Specific

**Location**: CRITIC Self-Review Protocol (lines 203-212)

**Issue**: Generic CRITIC techniques applied, but risk-specific checklist items would be more effective.

**Fix**: Add risk-specific checklist:
```
SENTINEL_SELF_REVIEW_CHECKLIST:
[ ] HWM includes unrealized? Verified?
[ ] Floor calculation: HWM * 0.95? (not 0.90)
[ ] Time converted to ET correctly? DST handled?
[ ] All multipliers applied? DD × Time × Regime?
[ ] Buffer maintained? (DD < 4%, not just < 5%)
```

### LOW-3: No Emergency Communication Channel

**Location**: Entire spec (implicit omission)

**Issue**: If all automated systems fail, no way to alert human.

**Fix**: Add emergency channel configuration (Slack webhook, SMS, email).

### LOW-4: "Win" Undefined in Recovery Protocol

**Location**: Recovery Protocol (line 140): "3 consecutive wins"

**Issue**: What defines a "win"?

**Fix**: "Win = trade closed with realized profit > transaction costs"

---

## ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| Calculator MCP always available | What if MCP is down? | Define fallback |
| Time MCP provides accurate ET | DST transitions? System clock sync? | Validate time source |
| CRUCIBLE provides regime timely | What if handoff fails? | Default regime |
| Memory MCP persists correctly | What if reset? | File-based backup |
| Apex HWM matches our calculation | Never verified | Verify with Apex |
| Close commands always execute | Market/broker can fail | Retry + broker SL |

---

## EDGE CASES TESTED

| Edge Case | Spec Coverage | Result |
|-----------|---------------|--------|
| Position size = 0 | Handled via multipliers | PASS |
| Spread > SL | Not handled | FAIL (need constraint) |
| Partial fill | Not handled | FAIL (need protocol) |
| Connection drop at 4:54 PM | Not handled | FAIL (critical gap) |
| DD exactly at 4.5% | HALT triggered | PASS |
| HWM after partial close | Ambiguous | FAIL (need clarity) |
| Regime unknown | Not handled | FAIL (need fallback) |
| Conflicting agent verdicts | Not handled | FAIL (need synthesis) |

---

## STRESS TEST RESULTS

| Condition | Spec Response | Adequacy |
|-----------|---------------|----------|
| Flash crash at 4:50 PM | Time multiplier blocks new trades | Partial (existing positions?) |
| Spread 5x normal | No protection | FAIL |
| Connection drops at 4:54 PM | No retry/fallback | FAIL |
| Gap after weekend | No gap handling | Not addressed |
| Low liquidity session | Regime multiplier | Partial (if CRUCIBLE works) |

---

## MANUAL VERIFICATION NEEDED

- [ ] Verify Apex's official HWM calculation methodology matches spec
- [ ] Confirm Apex's exact overnight position penalty (violation type)
- [ ] Test emergency close execution at broker level
- [ ] Validate time zone conversion with DST edge cases
- [ ] Confirm 30% consistency rule interpretation with Apex

---

## PRE-MORTEM SUMMARY

**Most Likely Failure Mode**: Emergency close at 4:55 PM fails due to connection/execution issues, leading to overnight position and Apex violation.

**Second Most Likely**: HWM calculation diverges from Apex's methodology, leading to false safety perception and unexpected account termination.

**Third Most Likely**: DD > 4.5% HALT creates permanent stuck state with no recovery path.

**Mitigations**:
1. Add broker-side hard SL as backstop
2. Implement retry logic with human escalation
3. Verify HWM methodology against Apex documentation
4. Clarify recovery protocol for extreme DD scenarios

---

## CONFIDENCE: MEDIUM

**Reason**: The spec demonstrates solid understanding of Apex rules and has comprehensive DD tier system. However, operational resilience (failure handling, fallbacks, edge cases) is weak. The critical gaps around emergency close and broker-side safety must be addressed before production use.

---

## RECOMMENDED ACTIONS

1. **Immediate (CRITICAL)**: Add emergency close failure handling with retry and human escalation
2. **Immediate (CRITICAL)**: Mandate broker-side SL as backstop
3. **Before Production (HIGH)**: Verify HWM methodology against Apex
4. **Before Production (HIGH)**: Add audit trail logging
5. **Before Production (HIGH)**: Clarify recovery from DD > 4.5%
6. **Quality (MEDIUM)**: Add MCP fallbacks, regime fallback, output format updates

---

*"The market will test every edge case. We must test them first."*

CRITIC v1.1 - Adversarial Quality Guardian
