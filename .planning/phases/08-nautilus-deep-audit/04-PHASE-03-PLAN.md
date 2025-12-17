# PLAN: Phase 03 - Risk Modules Audit

> **Changelog:**
> - 2025-12-17: **CRITICAL** - Added mandatory delegation enforcement (Protocol 0). Orchestrator MUST NOT read source files directly.
> - 2025-12-16: Applied CRITIC review fixes (C-001 to C-010): Added integration verification step, consolidation process, rebalanced agent workload, failure mode analysis, pass/fail criteria, stress scenarios, numerical precision checks, output format specification, and test coverage requirements.

---

## ⚠️ MANDATORY DELEGATION (Protocol 0)

> **CRITICAL: The orchestrator MUST NOT read source files directly.**
>
> This phase analyzes ~2,913 lines of risk-critical code. Reading these files directly will cause context overflow.

### Orchestrator Behavior

```
❌ WRONG (causes context overflow):
   Orchestrator reads 9 risk module files directly
   Orchestrator performs Apex compliance checks in main context
   → CONTEXT OVERFLOW → Summarization → LOST CRITICAL RISK DETAILS

✅ CORRECT (sustainable):
   Orchestrator spawns SENTINEL sub-agents with delegation prompt
   Each SENTINEL reads assigned files, verifies Apex compliance, writes findings
   Each SENTINEL returns 300-word summary to orchestrator
   Orchestrator consolidates and updates MANIFEST.md
```

### Required Sub-Agent Prompts

**Agent A (DD Stack):**
```
Execute Phase 03 Agent A (DD Stack) of the Nautilus Deep Audit.

DELEGATION PROTOCOL (MANDATORY):
1. YOU read the source files - orchestrator has NOT read them
2. Files to analyze:
   - nautilus_gold_scalper/src/risk/drawdown_tracker.py (358 lines) - CRITICAL
   - nautilus_gold_scalper/src/risk/dd_protection.py (298 lines)
   - nautilus_gold_scalper/src/risk/circuit_breaker.py (540 lines)
3. Focus: DD calculation from HWM, unrealized P/L inclusion, protection actions
4. Write COMPLETE analysis to: .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_03_A_DD_FINDINGS.md
5. Return ONLY summary (max 300 words) with issue counts and Apex compliance status

Plan file: .planning/phases/08-nautilus-deep-audit/04-PHASE-03-PLAN.md
```

**Agent B (Apex Rules Stack):**
```
Execute Phase 03 Agent B (Apex Rules Stack) of the Nautilus Deep Audit.

DELEGATION PROTOCOL (MANDATORY):
1. YOU read the source files - orchestrator has NOT read them
2. Files to analyze:
   - nautilus_gold_scalper/src/risk/time_constraint_manager.py (108 lines) - CRITICAL
   - nautilus_gold_scalper/src/risk/consistency_tracker.py (61 lines)
   - nautilus_gold_scalper/src/risk/prop_firm_manager.py (279 lines)
3. Focus: Time gates (4:30, 4:55, 4:59 PM ET), 30% rule, DST handling
4. Write COMPLETE analysis to: .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_03_B_APEX_FINDINGS.md
5. Return ONLY summary (max 300 words) with issue counts and time gate verification

Plan file: .planning/phases/08-nautilus-deep-audit/04-PHASE-03-PLAN.md
```

**Agent C (Sizing Stack):**
```
Execute Phase 03 Agent C (Sizing Stack) of the Nautilus Deep Audit.

DELEGATION PROTOCOL (MANDATORY):
1. YOU read the source files - orchestrator has NOT read them
2. Files to analyze:
   - nautilus_gold_scalper/src/risk/position_sizer.py (397 lines)
   - nautilus_gold_scalper/src/risk/spread_monitor.py (525 lines)
   - nautilus_gold_scalper/src/risk/var_calculator.py (347 lines)
3. Focus: Lot sizing, spread impact, VaR integration, 30% per-trade loss rule
4. Write COMPLETE analysis to: .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_03_C_SIZING_FINDINGS.md
5. Return ONLY summary (max 300 words) with issue counts

Plan file: .planning/phases/08-nautilus-deep-audit/04-PHASE-03-PLAN.md
```

---

## Objective
Deep critical analysis of all risk management modules to ensure Apex compliance, correct DD tracking, and proper circuit breaker behavior.

## Files Under Review

| File | Lines | Apex Relevance |
|------|-------|----------------|
| `circuit_breaker.py` | 540 | Loss limits, cooldowns |
| `consistency_tracker.py` | 61 | 30% rule |
| `dd_protection.py` | 298 | DD limit enforcement |
| `drawdown_tracker.py` | 358 | DD calculation (CRITICAL) |
| `position_sizer.py` | 397 | Lot sizing |
| `prop_firm_manager.py` | 279 | Apex rules orchestration |
| `spread_monitor.py` | 525 | Spread tracking |
| `time_constraint_manager.py` | 108 | Time gates (CRITICAL) |
| `var_calculator.py` | 347 | Value at Risk |

**Total:** ~2,913 lines

## Execution Plan

### Step 1: Parallel Agent Assignment (Rebalanced by Coupling)

**Agent A (SENTINEL):** DD Stack (~1,196 lines)
- `drawdown_tracker.py` - CRITICAL (358 lines)
- `dd_protection.py` (298 lines)
- `circuit_breaker.py` (540 lines)
- Focus: DD calculation, protection actions, escalation logic

**Agent B (SENTINEL):** Apex Rules Stack (~448 lines)
- `time_constraint_manager.py` - CRITICAL (108 lines)
- `consistency_tracker.py` (61 lines)
- `prop_firm_manager.py` (279 lines)
- Focus: Time gates, 30% rule, rule orchestration and priority

**Agent C (SENTINEL):** Sizing Stack (~1,269 lines)
- `position_sizer.py` (397 lines)
- `spread_monitor.py` (525 lines)
- `var_calculator.py` (347 lines)
- Focus: Lot sizing, spread impact, VaR integration

### Step 2: Integration Verification (After Parallel Execution)

One SENTINEL agent reviews cross-module integration:
- **Call chains:** strategy -> risk modules -> execution
- **Data flow:** equity source -> DD tracker -> protection -> CB
- **Priority verification:** DD > Time > Consistency confirmed in code
- **Single gatekeeper:** Verify prop_firm_manager.can_trade() is THE entry point
- **Caller discipline:** Verify strategy always calls risk checks before entry
- **Order of operations:** position_sizer.calculate() called AFTER DD check

### Step 3: Consolidation and Conflict Resolution

**Consolidation Owner:** Orchestrator

**Process:**
1. Collect all 3 agent outputs (Step 1) + integration output (Step 2)
2. Merge findings into single `PHASE_03_FINDINGS.md`
3. Resolve conflicts (e.g., Agent A says DD correct, Agent C says sizing uses wrong balance)
4. Cross-reference: ensure no module-to-module gaps
5. Apply verdict criteria (see Pass/Fail Criteria below)

**Conflict Resolution Priority:**
- If agents disagree on correctness: investigate code directly, conservative interpretation wins
- If severity differs: use higher severity
- If Apex rule ambiguous: fail-safe interpretation

## Pass/Fail Criteria

**BLOCKED (Requires Fix Before Proceeding):**
- Any CRITICAL issue found
- More than 3 HIGH issues found
- Any Apex rule NOT verified as compliant
- Any module with fail-open behavior (must be fail-safe)
- Missing unit tests for CRITICAL modules

**APPROVED:**
- 0 CRITICAL issues
- <= 3 HIGH issues (with mitigations documented)
- All 5 Apex rules verified as compliant
- All modules fail-safe on exception
- Unit tests exist and pass for all modules

## APEX COMPLIANCE VERIFICATION (MANDATORY)

### Rule 1: Trailing Drawdown = 5% from HIGH-WATER MARK
**Critical Questions:**
- Is DD calculated from HIGH-WATER MARK (not initial balance)?
- Does HIGH-WATER MARK include unrealized P&L?
- Is trailing mechanism correctly implemented?
- Reset behavior on new high?
- **Edge:** HWM behavior when unrealized drops but realized unchanged?

**Specific Checks:**
- [ ] HWM updates on every tick with unrealized P&L
- [ ] DD = (HWM - current_equity) / HWM
- [ ] 5% threshold triggers immediate halt
- [ ] 4.0% buffer triggers early warning

### Rule 2: No Overnight Positions
**Critical Questions:**
- Is 4:59 PM ET cutoff enforced?
- What happens if close fails?
- Market order vs limit for emergency close?
- Weekend/holiday handling?
- **Edge:** What if close order sent at 4:58:59 but not filled by 4:59?

**Specific Checks:**
- [ ] Uses market order for emergency close (not limit)
- [ ] Has retry logic for failed closes
- [ ] Position check runs every second from 4:55 PM

### Rule 3: Time Gates
**Critical Questions:**
- 4:30 PM ET: Block new trades?
- 4:55 PM ET: Emergency close initiated?
- Timezone handling (ET with DST)?
- What if position entry at 4:29 PM, still open?
- **Edge:** Priority conflict with circuit_breaker cooldown?

**Specific Checks:**
- [ ] Timezone = America/New_York (pytz or zoneinfo)
- [ ] DST transitions tested
- [ ] Time gate overrides CB cooldown (can always close)

### Rule 4: Max 30% Profit in Single Day
**Critical Questions:**
- How is daily profit calculated?
- Is this hard block or warning?
- Reset timing (midnight ET)?
- What happens at 29.5%?
- **Edge:** Unrealized vs realized treatment - what happens to OPEN positions at 30%?

**Specific Checks:**
- [ ] Includes unrealized P&L in 30% check
- [ ] At 30%: close all positions, block new trades
- [ ] Resets at 00:00 ET

### Rule 5: DD Safety Buffers
**Critical Questions:**
- Trailing DD >= 4.0% -> HALT?
- Total DD >= 4.5% -> HALT?
- HALT = no new trades + close existing?
- Recovery mechanism?

**Specific Checks:**
- [ ] 4.0% trailing -> HALT state
- [ ] 4.5% total -> TERMINATE (no recovery)
- [ ] HALT prevents ALL trading, not just new entries

## Failure Mode Analysis (Per Module)

### drawdown_tracker.py
| Failure | Expected Behavior |
|---------|-------------------|
| Exception in update() | Fail-safe: assume worst DD, block trading |
| Stale equity data | Fail-safe: use last known, trigger warning |
| NaN/Inf in calculation | Fail-safe: set DD to limit, block trading |

### time_constraint_manager.py
| Failure | Expected Behavior |
|---------|-------------------|
| Exception in is_trading_allowed() | Fail-safe: return False |
| Timezone library unavailable | Fail-safe: assume 4:30 PM ET always |
| Clock drift/desync | Fail-safe: use conservative time offset |

### circuit_breaker.py
| Failure | Expected Behavior |
|---------|-------------------|
| Exception in check() | Fail-safe: assume triggered, block trading |
| State corruption | Fail-safe: reset to most restrictive level |
| Cooldown timer fails | Fail-safe: keep cooldown active indefinitely |

### position_sizer.py
| Failure | Expected Behavior |
|---------|-------------------|
| Exception in calculate() | Fail-safe: return 0 lots (no trade) |
| Invalid equity | Fail-safe: return 0 lots |
| Division by zero (SL=0) | Fail-safe: reject trade |

### prop_firm_manager.py
| Failure | Expected Behavior |
|---------|-------------------|
| Exception in can_trade() | Fail-safe: return False |
| Broker connection lost | Fail-safe: assume worst state, block trading |
| Rule conflict | Fail-safe: most restrictive rule wins |

### spread_monitor.py
| Failure | Expected Behavior |
|---------|-------------------|
| Exception in check() | Fail-safe: assume high spread, block trade |
| Invalid spread data | Fail-safe: use max historical spread |

### var_calculator.py
| Failure | Expected Behavior |
|---------|-------------------|
| Exception in calculate() | Fail-safe: assume max VaR, reduce position |
| Insufficient historical data | Fail-safe: use conservative default |

### consistency_tracker.py
| Failure | Expected Behavior |
|---------|-------------------|
| Exception in check() | Fail-safe: assume 30% reached, block trading |
| Invalid P&L data | Fail-safe: conservative interpretation |

### dd_protection.py
| Failure | Expected Behavior |
|---------|-------------------|
| Exception in protect() | Fail-safe: close all positions |
| Tracker unavailable | Fail-safe: assume worst DD |

## Stress Test Scenarios (CRITICAL Modules)

### drawdown_tracker.py Stress Tests
| Scenario | Expected |
|----------|----------|
| Rapid 3% gain then 4% loss in 1 second | HWM updates correctly, DD = 4% from new HWM |
| Gap open: 2% loss overnight (simulated) | DD immediately reflects gap |
| 100 updates per second | No race conditions, latest value wins |
| Floating point: 4.999999% vs 5.000001% | Uses >= 5.0 with proper precision |

### time_constraint_manager.py Stress Tests
| Scenario | Expected |
|----------|----------|
| DST spring forward (2 AM -> 3 AM) | 4:30 PM ET correct |
| DST fall back (2 AM -> 1 AM) | 4:30 PM ET correct |
| Position opened at 4:29:59 PM | Allowed, but flagged for 4:30 check |
| Emergency close at 4:55 while CB in cooldown | Emergency close OVERRIDES CB |
| Market close order fails, retry at 4:56, 4:57, 4:58 | Keeps retrying until filled or 4:59 |

### Numerical Precision Verification
| Check | Requirement |
|-------|-------------|
| DD calculation precision | >= 4 decimal places or use Decimal |
| Comparison operators | Use `>=` not `>` for limits |
| Rounding direction | Always round TOWARD limit (conservative) |
| Our 4.99% vs Apex's calculation | Must match within 0.01% |

## CRITIC Checklist per Module

### drawdown_tracker.py (CRITICAL)
| Check | Status |
|-------|--------|
| Uses HIGH-WATER MARK, not initial balance | [] |
| Includes unrealized P&L in HWM | [] |
| Trailing mechanism correct | [] |
| Reset on new high correct | [] |
| Edge: rapid gain then loss | [] |
| Edge: gap open against position | [] |
| Thread-safe if multi-threaded | [] |
| Numerical precision (>= 4 decimals) | [] |
| Fail-safe on exception | [] |

### time_constraint_manager.py (CRITICAL)
| Check | Status |
|-------|--------|
| Timezone = ET (America/New_York) | [] |
| DST transitions handled | [] |
| 4:30 PM warning implemented | [] |
| 4:55 PM emergency close | [] |
| 4:59 PM hard cutoff | [] |
| Edge: position opened at 4:29:59 | [] |
| Overrides circuit_breaker for close | [] |
| Fail-safe on exception | [] |

### circuit_breaker.py
| Check | Status |
|-------|--------|
| Level 1: 3 losses -> 5min cooldown | [] |
| Level 2: 5 losses -> 15min + size reduction | [] |
| Level 3: 3% DD -> 30min cooldown | [] |
| Level 4: 4% DD -> day halt | [] |
| Level 5: 4.5% DD -> terminated | [] |
| Escalation logic correct | [] |
| Recovery/reset mechanism | [] |
| Does NOT block emergency close | [] |
| Fail-safe on exception | [] |

### position_sizer.py
| Check | Status |
|-------|--------|
| Risk per trade configurable | [] |
| Uses current equity (not balance) | [] |
| Respects CB size reduction | [] |
| Min/max lot limits | [] |
| Spread impact on sizing | [] |
| Fail-safe on exception (0 lots) | [] |

### prop_firm_manager.py
| Check | Status |
|-------|--------|
| Orchestrates all rules | [] |
| Priority: DD > Time > Consistency | [] |
| HALT state management | [] |
| Rule violation logging | [] |
| Is THE gatekeeper (single entry point) | [] |
| Fail-safe on exception | [] |

### spread_monitor.py
| Check | Status |
|-------|--------|
| Spread calculation correct | [] |
| Historical tracking working | [] |
| Warning/block thresholds | [] |
| Impact on trade decisions | [] |
| Fail-safe on exception | [] |

### var_calculator.py
| Check | Status |
|-------|--------|
| VaR calculation method | [] |
| Confidence level (95%? 99%?) | [] |
| Integration with sizing | [] |
| Historical data requirements | [] |
| Fail-safe on exception | [] |

### consistency_tracker.py
| Check | Status |
|-------|--------|
| 30% daily profit cap | [] |
| Includes unrealized P&L | [] |
| Calculation method | [] |
| Action when exceeded | [] |
| Fail-safe on exception | [] |

### dd_protection.py
| Check | Status |
|-------|--------|
| Integration with tracker | [] |
| Protection actions correct | [] |
| Recovery handling | [] |
| Fail-safe on exception | [] |

## Test Coverage Requirements

| Module | Unit Tests Required | Status |
|--------|---------------------|--------|
| drawdown_tracker.py | HWM update, DD calculation, edge cases | [] |
| time_constraint_manager.py | Time checks, DST, emergency close | [] |
| circuit_breaker.py | All 5 levels, escalation, recovery | [] |
| position_sizer.py | Sizing calculation, limits | [] |
| prop_firm_manager.py | Rule priority, HALT state | [] |
| spread_monitor.py | Spread tracking, thresholds | [] |
| var_calculator.py | VaR calculation | [] |
| consistency_tracker.py | 30% cap calculation | [] |
| dd_protection.py | Protection actions | [] |

**Requirement:** All unit tests must PASS before APPROVED verdict.

## Success Criteria
- [ ] All 9 risk modules reviewed
- [ ] All 5 Apex rules verified with specific checks
- [ ] DD calculation confirmed correct (HWM + unrealized)
- [ ] Time gate logic verified (including DST)
- [ ] Circuit breaker escalation correct
- [ ] All modules fail-safe on exception
- [ ] Unit tests exist and pass for all modules
- [ ] Integration verification completed
- [ ] `PHASE_03_FINDINGS.md` completed with standard format

## Agents

**Step 1: 3 parallel SENTINEL agents (model: opus)**
- Agent A: DD Stack (drawdown_tracker + dd_protection + circuit_breaker)
- Agent B: Apex Rules Stack (time_constraint_manager + consistency_tracker + prop_firm_manager)
- Agent C: Sizing Stack (position_sizer + spread_monitor + var_calculator)
- Each must apply CRITIC self-review internally
- Each must verify Apex compliance explicitly
- Each must check failure modes (fail-safe behavior)

**Step 2: 1 SENTINEL agent (model: opus)**
- Integration verification
- Cross-module call chain analysis
- Data flow verification

## Output Format

`PHASE_03_FINDINGS.md` must follow this structure:

```markdown
# Phase 03 Findings: Risk Modules

## Summary
- Total issues: X (C: X, H: X, M: X, L: X)
- Verdict: BLOCKED / APPROVED

## Apex Compliance Matrix

| Rule | Status | Verified By | Notes |
|------|--------|-------------|-------|
| 5% Trailing DD from HWM | [] | Agent A | |
| No overnight (4:59 PM ET) | [] | Agent B | |
| Block new trades 4:30 PM | [] | Agent B | |
| Emergency close 4:55 PM | [] | Agent B | |
| Max 30% daily profit | [] | Agent B | |
| DD buffer 4.0%/4.5% HALT | [] | Agent A | |

## Critical Issues (BLOCKERS)
[Table: ID, Module, Issue, Impact, Recommendation]

## High Issues
[Table: ID, Module, Issue, Impact, Recommendation]

## Medium Issues
[Table: ID, Module, Issue, Impact, Recommendation]

## Low Issues
[Table: ID, Module, Issue, Impact, Recommendation]

## Failure Mode Analysis
[Summary of fail-safe/fail-open behavior per module]

## Integration Verification
[Cross-module analysis results]

## Test Coverage
[Status per module]

## Verdict
**BLOCKED** / **APPROVED**
[Justification]
```

---

*Plan ready for execution.*

---

## ARGUS Integration (2025-12-16)

### TRADOVATE-Specific Verification

**Critical Context**: User operates on TRADOVATE (not RITHMIC). Trailing DD behavior differs significantly.

| Check | Requirement | Impact | Status |
|-------|-------------|--------|--------|
| Trailing DD NEVER locks on TRADOVATE | During evaluation, trailing continues even after reaching safety net | CRITICAL - cannot assume lock behavior | [ ] |
| HWM includes unrealized (tick-level) | Every tick with unrealized P/L updates HWM, not just closed trades | CRITICAL - spike then retrace = lost buffer | [ ] |
| 30% per-trade loss limit | Open negative P/L cannot exceed 30% of profit balance | HIGH - $750 max on new $50k account | [ ] |
| 30% consistency cap | No single day > 30% of total profit at payout | HIGH - windfall trap | [ ] |
| 5:1 R:R enforcement | SL cannot exceed 5x TP | HIGH - payout denial risk | [ ] |
| Contract scaling 50% | Half contracts until safety net reached (PA only) | MEDIUM - user plans small size anyway | [ ] |
| Commission tracking in DD | Commissions and fees included in P/L calculation | HIGH - hidden DD erosion | [ ] |

### Additional Items from ARGUS Research

**Platform Error Handling (TRADOVATE-specific):**
- [ ] Rate limiting on order modifications (30 sec cooldown after cancel)
- [ ] OCO ID cannot be reused error handling
- [ ] Atomic order operation error recovery
- [ ] Session count maximum handling

**Connection Resilience:**
- [ ] Disconnect handling with exponential backoff
- [ ] Position verification on reconnect
- [ ] Heartbeat/data feed monitoring
- [ ] Auto-close on disconnect recovery

**Gap Risk Mitigation:**
- [ ] Gold gap statistics awareness (0.64% avg daily gap)
- [ ] Session open gap handling (0.3-0.5% common)
- [ ] Weekend gap blocking (1-3% possible)

**Slippage Buffer Verification:**
- [ ] Size for 150% of planned SL (slippage buffer)
- [ ] News slippage buffer (50-100+ ticks worse during NFP/CPI/FOMC)
- [ ] Stop-loss as market order understanding (price not guaranteed)

### TRADOVATE vs RITHMIC Difference Matrix

| Feature | RITHMIC | TRADOVATE | Verification Required |
|---------|---------|-----------|----------------------|
| Trailing stops when EOD balance reaches safety net | YES | NO (never stops) | [ ] Code handles both or TRADOVATE-only |
| Safety net locks threshold | YES | Only behavior, not locking | [ ] No false assumptions about locking |
| Real-time unrealized tracking | YES | YES | [ ] Tick-level HWM update confirmed |

### 30% Per-Trade Loss Calculation

**For new accounts with no profit:**
- Max open loss = 30% x trailing threshold = 30% x $2,500 = $750

**For accounts with profit balance:**
- Max open loss = 30% x profit balance

**Verification:**
- [ ] Position sizer respects 30% per-trade limit
- [ ] Dynamic recalculation based on current profit balance
- [ ] Aggregate P/L tracking for multiple positions
- [ ] Buffer to 25% instead of 30% (slippage protection)

### 30% Consistency Rule Verification

**Formula:** Highest Profit Day / 0.3 = Minimum Required Profit Before Payout

**Example trap:**
- Best day = $1,500 profit
- Minimum total needed = $5,000
- If only $4,000 total = DENIED (37.5% > 30%)

**Verification:**
- [ ] Daily profit tracking exists
- [ ] Consistency ratio computed daily
- [ ] Warning at 25% of trailing threshold ($625 on $50k)
- [ ] Hard cap at 30% of trailing threshold ($750 on $50k)

### 5:1 Risk-Reward Enforcement

**Rule:** SL cannot exceed 5x TP (e.g., 10 tick TP = max 50 tick SL)

**Verification:**
- [ ] R:R validation at trade entry
- [ ] Parameter validation prevents >5:1
- [ ] Logging of actual R:R for each trade
- [ ] Recommended conservative cap at 4:1

---

## CRITIC RE-REVIEW (2025-12-16)

### Previous Issues Status
| ID | Issue | Status |
|----|-------|--------|
| C-001 | Integration verification step missing | FIXED |
| C-002 | Consolidation process missing | FIXED |
| C-003 | Agent workload imbalanced | FIXED (coupling-based) |
| C-004 | Failure mode analysis missing | FIXED |
| C-005 | Pass/fail criteria missing | FIXED |
| C-006 | Stress scenarios missing | FIXED |
| C-007 | Numerical precision checks missing | FIXED |
| C-008 | Output format specification missing | FIXED |
| C-009 | Test coverage requirements missing | FIXED |

### New Issues Found
None of CRITICAL or HIGH severity.

Minor observations (LOW):
- No time estimates for execution steps
- Test execution ownership not explicitly assigned to agents

### Verdict
**APPROVED**

All claimed fixes were verified as applied. The plan is comprehensive with:
- All 5 Apex rules covered with specific checklists
- Failure mode analysis for all 9 modules
- Clear pass/fail criteria
- Detailed output format template
- Test coverage requirements

Ready for execution.
