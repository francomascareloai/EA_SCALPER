# CRITIC ADVERSARIAL REVIEW: Agent Ecosystem Workflow Gaps

**Artifact**: EA_SCALPER_XAUUSD Agent Ecosystem Workflow
**Type**: Workflow / Process / Orchestration Protocol
**Reviewer**: CRITIC v1.1 (Adversarial Quality Guardian)
**Review Date**: 2025-12-15
**Sequential Thinking**: 15 thoughts applied

---

## SEVERITY SUMMARY

| Severity | Count |
|----------|-------|
| CRITICAL | 4 issues |
| HIGH | 5 issues |
| MEDIUM | 4 issues |
| LOW | 2 issues |

---

## CONTEXT ANALYZED

The planned workflow for EA_SCALPER_XAUUSD agent ecosystem:
1. Use /create-plan to create structured plans with phases
2. Run CRITIC review on each plan before execution
3. Execute phase by phase with multiple agents per phase
4. Outputs persisted via orchestration_output_protocol (CLAUDE.md v3.10.8)

Files examined:
- `.claude/agents/critic-adversarial.md` (CRITIC spec)
- `.claude/agents/daemon-strategic-advisor.md` (DAEMON spec)
- `.claude/commands/genius.md` (/genius command)
- `.claude/orchestration/README.md` (output protocol)
- `.planning/phases/08-nautilus-deep-audit/PROTOCOLS.md` (existing protocols)
- `.planning/phases/08-data-validation-backtest/CRITIC_REVIEW.md` (existing CRITIC review)
- `CLAUDE.md` (core orchestration instructions)

---

## ADVERSARIAL TECHNIQUES APPLIED

### 1. INVERSION: How Could This Workflow FAIL?

**Identified Failure Modes:**

1. **Plan creation without validation** - /create-plan doesn't exist as a command. Users create manual plans with arbitrary structure, no template enforcement, no cost/time estimation.

2. **CRITIC bottleneck** - Every plan requires CRITIC review (12-15 thoughts). CRITIC fatigue leads to rubber-stamping over time.

3. **Context overflow despite protocol** - Output protocol assumes agents ALWAYS follow instructions. No verification that files were written. Summary size violations multiply across agents.

4. **Inter-agent communication gap** - Agents write to files but protocol doesn't specify how Agent B READS Agent A's findings. Files as message passing without consistency guarantees.

5. **Plan rigidity** - Plans are static markdown. No dynamic branching, no early termination, no scope adjustment mid-execution.

6. **Apex authority diffusion** - Multiple agents check Apex (CRITIC, ORACLE, SENTINEL) but each assumes "someone else will catch it."

---

### 2. PRE-MORTEM: The 2026 Account Termination

**Scenario: The Perfect Storm**

Timeline:
- Day 1-3: Plan created and CRITIC reviewed
- Day 5-7: Phases 1-4 execute with 6+ agents
- Day 7: FORGE writes code with subtle look-ahead bug (bars[0] instead of bars[-1])
- Day 8: CRITIC self-review runs but agent is rushed (12 thoughts instead of 15), misses bug
- Day 10: ORACLE backtests pass (WFE 0.65, SQN 2.8) because look-ahead makes metrics BETTER
- Day 11: SENTINEL signs off on risk
- Day 12: GO/NO-GO positive, strategy goes live
- Day 20: First loss streak, DD reaches 3%
- Day 22: DD reaches 4.5%, HALT triggered but 15 minutes late due to unrealized PnL lag
- Day 23: Account terminated

**Root Causes:**
1. Look-ahead bug survived 4 layers of review (FORGE, CRITIC, ORACLE, SENTINEL)
2. Each layer assumed "someone else would catch it"
3. Bug made backtests look BETTER, so metrics passed
4. No live paper trading / simulation phase in workflow
5. Unrealized PnL tracking never stress-tested

---

### 3. STRESS TEST: Pressure Scenarios

**Scenario 1: Context Overflow During Massive Orchestration**

Current Protection: orchestration_output_protocol says persist to files

Stress Sequence:
1. User spawns Phase 3 with 6 session validators in parallel
2. Each processes 100K+ ticks, returns 500+ word summary
3. 6 x 500 = 3000 words to orchestrator
4. Orchestrator already has 50K tokens from prior phases
5. MANIFEST creation requires reading all 6 outputs
6. Context exceeds limit -> summarization truncates MANIFEST

**Gap**: No VERIFICATION that file was written before agent returns.

**Scenario 2: Tight Deadline Pressure**

User: "We have 2 hours to validate and go live"

What happens:
- CRITIC reviews rushed (fewer thoughts)
- Sequential rounds become parallel
- Agents skip deep analysis
- Edge cases marked "LOW priority" and ignored

**Gap**: No "minimum quality" gate that BLOCKS execution regardless of time pressure.

---

### 4. REGIME SHIFT: Mid-Plan Changes

**Scenario: New Apex Rule Mid-Execution**

- Day 4: Phase 2 complete
- Day 5: Apex announces "Maximum 20% profit on any single trade"
- Day 6: Need to update all phases, re-run validations

**Gaps:**

1. **No version control for plans** - Plans are static .md files. Can't track:
   - What changed?
   - Which agents ran with old version?
   - Need to re-run those phases?

2. **No dependency invalidation** - No mechanism to mark "Phase 3 results INVALID because assumptions changed"

3. **Context stale detection** - Agents load CLAUDE.md at start. If updated mid-session, agents have stale rules.

4. **No plan branching** - Can't create alternate path if phase is impossible (like Phase 6 building engine from scratch)

**Evidence**: CRITIC_REVIEW.md found Phase 6 was asking to BUILD engine from scratch in a "validation" plan. Classic scope creep not caught in plan creation.

---

### 5. APEX TRAP ANALYSIS: Compliance Slip-Through Paths

Despite having SENTINEL as final authority, CRITIC checking artifacts, and ORACLE validating backtests:

**Path 1: Unrealized PnL Blind Spot**
- Strategy makes profitable trade
- Unrealized profit raises HWM
- Price reverses before close
- Realized profit lower, but HWM already set
- Future DD measured from HIGHER HWM
- Backtest tracks closed trades -> doesn't see this
- LIVE: hits DD from unrealized spike

**Path 2: Emergency Close Failure Chain**
- 4:55 PM ET: Emergency close triggered
- Exchange latency -> order rejected
- Retry at 4:56 -> partial fill
- 4:58: still have position
- 4:59: VIOLATED
- No EXECUTION VERIFICATION that close happened

**Path 3: 30% Consistency Rule**
- Day 1: +35% of monthly target
- Days 2-20: small profits
- ORACLE validates Sharpe, WFE (not daily distribution)
- SENTINEL focuses on DD, not consistency
- LIVE: Account flagged for inconsistency

**Path 4: Time Zone DST Edge**
- Strategy hardcodes 4:30 PM as 21:30 UTC
- DST switches: 4:30 PM is now 20:30 UTC
- Strategy blocks at 21:30 UTC (5:30 PM ET!)
- Trades placed in forbidden window
- CRITIC_REVIEW.md found this in PLAN, but who verifies CODE matches corrected plan?

**Path 5: Cascade Under Stress**
- Market gaps 3% overnight
- 9:30 AM: Account shows -3.5% DD (from gap)
- Strategy sees opportunity, places trades
- DD hits 4.5%
- HALT should trigger but strategy in "opportunity mode"

**Meta-Problem**: Static review cannot catch runtime edge cases. Only simulation/paper trading can.

---

### 6. EDGE CASES: Workflow Breakers

**Edge Case 1: Circular Agent Dependency**
- FORGE implements A
- CRITIC needs ORACLE validation
- ORACLE needs feature B from FORGE
- FORGE needs SENTINEL approval
- SENTINEL needs ORACLE validation of A
-> DEADLOCK

No cycle detection or escalation.

**Edge Case 2: Agent Contradictions**
- CRITIC: "HWM calculation wrong"
- FORGE: "HWM matches spec"
- Who arbitrates?
- PROTOCOLS.md: Conflict resolved in Phase 9
- But what if conflict in Phase 2? Wait until Phase 9?

**Edge Case 3: Empty Results**
- ORACLE runs backtest
- Strategy generates 0 trades
- Metrics undefined
- Pass? Fail? Retry?

**Edge Case 4: Partial Agent Completion**
- Agent writes file, crashes before returning
- File exists but not in MANIFEST
- No recovery mechanism

**Edge Case 5: Model Downgrade**
- Plan specifies Opus
- Rate limits -> Haiku fallback
- No verification correct model used

**Edge Case 6: Session Persistence Gap**
- Session A starts Phase 3
- Session expires
- Session B must manually read MANIFEST to continue

**Edge Case 7: Conflicting Plans**
- Plan A for feature X
- Plan B for feature Y (same files)
- No plan coordination

---

### 7. ASSUMPTION AUDIT: What Might Be Wrong?

| Assumption | Reality | Challenge |
|------------|---------|-----------|
| Agents follow instructions perfectly | Agents are probabilistic | Need verification hooks |
| CRITIC prevents all bugs | CRITIC can't run code | CRITIC is a layer, not THE defense |
| File persistence solves overflow | Files need read/write verification | Protocol handles writing, not reading |
| Parallel agents are independent | Race conditions possible | Assume no interaction, but may modify same files |
| Plans created correctly | /create-plan doesn't exist | Manual plans may miss sections |
| All agents have same context | CLAUDE.md changes mid-session | No snapshot mechanism |
| Apex rules are static | Prop firms change rules | No versioning/notification |

---

## CRITICAL ISSUES (Must Fix)

### CRIT-1: No Simulation/Paper Trading Phase

**Location**: Overall workflow design
**Impact**: Backtest -> Live is too direct. Look-ahead bugs, execution issues, and runtime edge cases only surface with real money at risk.
**Evidence**: Pre-mortem scenario shows how bugs survive all review layers
**Fix**: Add MANDATORY paper trading phase between validated backtest and live. Run for minimum 1 week with real data feed but no money.

### CRIT-2: Self-Review Lacks Independence

**Location**: CRITIC protocol ("CRITIC is invoked BY SUB-AGENTS, not orchestrator")
**Impact**: Agent reviews its own work. No conflict of interest protection. Agent motivated to find "nothing wrong."
**Evidence**: Protocol explicitly makes self-review the norm, external review the exception
**Fix**: Separate CRITIC agent reviews other agent's work. Self-review is first pass, independent review is mandatory for CRITICAL artifacts.

### CRIT-3: No Runtime Verification of Apex Compliance

**Location**: All review is static (code/plan analysis)
**Impact**: Unrealized PnL, emergency close, 30% consistency - none verified in runtime
**Evidence**: Apex traps 1-5 all involve runtime behavior, not code structure
**Fix**:
- Add unrealized PnL tracking test in simulation
- Add emergency close stress test (force close at 4:55 with latency injection)
- Add daily consistency check in backtest metrics

### CRIT-4: /create-plan Command Missing

**Location**: Workflow assumes /create-plan exists
**Impact**: Manual plan creation without validation, template enforcement, or CRITIC pre-review
**Evidence**: Glob for *create*plan* returned no results
**Fix**: Create /create-plan command with:
- Template enforcement
- Scope estimation
- CRITIC validation before save
- Version tracking

---

## HIGH ISSUES (Should Fix)

### HIGH-1: Context Overflow Despite Protocol

**Location**: orchestration_output_protocol
**Impact**: No verification files written. Summary size violations multiply.
**Fix**:
- Add file existence check before agent returns "COMPLETE"
- Hard limit: 200 words max per summary, enforced
- Context budget tracker before spawning

### HIGH-2: Inter-Agent Communication Fragile

**Location**: Files as message passing
**Impact**: No consistency guarantees. Agent B may read partial file.
**Fix**:
- Add completion markers to files
- MANIFEST must be atomic write
- Consider actual message queue (Redis, SQLite)

### HIGH-3: Plan Rigidity

**Location**: Static .md files in .planning/
**Impact**: No dynamic branching, early termination, or scope adjustment
**Fix**:
- Add checkpoint gates between phases
- Allow ABORT decision at any phase
- Plan metadata tracks modifications

### HIGH-4: CRITIC Fatigue

**Location**: Repeated reviews
**Impact**: Review quality degrades over time
**Evidence**: First review thorough (17 issues), later reviews may rubber-stamp
**Fix**:
- Rotate review approaches (different techniques each time)
- External CRITIC for high-stakes reviews
- Track review depth metrics (thought count actually used)

### HIGH-5: Model Downgrade Undetected

**Location**: model_policy in CLAUDE.md
**Impact**: Opus -> Haiku fallback may not be detected
**Fix**:
- Log model used in each agent's output
- Block trading-critical tasks if model != opus

---

## MEDIUM ISSUES (Consider Fixing)

### MED-1: No Plan Versioning

**Location**: .planning/ structure
**Fix**: Git-based versioning with change tracking per phase

### MED-2: Cross-Session Recovery Manual

**Location**: MANIFEST reading
**Fix**: Add "resume" command that reads MANIFEST and restores state

### MED-3: Conflict Resolution Deferred

**Location**: PROTOCOLS.md - "Conflict resolved in Phase 09"
**Fix**: Blocking conflicts trigger immediate escalation, not deferral

### MED-4: DST Handling Fragile

**Location**: Time zone calculations
**Fix**: Central timezone module with DST table, used by all agents

---

## LOW ISSUES (Nice to Have)

### LOW-1: No Session Cleanup Policy

**Location**: .claude/orchestration/sessions/
**Fix**: Auto-archive after 7 days (already mentioned but not enforced)

### LOW-2: No Progress Tracking

**Location**: During phase execution
**Fix**: Heartbeat mechanism for long-running agents

---

## ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| All review layers catch all bugs | Layers have same blind spots (no code execution) | Add execution-based testing |
| Agents read their own work critically | Self-interest bias | External review for critical work |
| Files are reliable communication | Race conditions, partial writes | Add completion markers |
| Plans are complete when created | Scope creep, missing sections | Template + validation |
| Apex rules are documented correctly | Found DST error in existing plan | External source verification |

---

## EDGE CASES TESTED

| Scenario | Result |
|----------|--------|
| Circular dependency | FAIL - No cycle detection |
| Agent contradiction | PARTIAL - Resolution deferred too long |
| Empty backtest results | UNKNOWN - No defined behavior |
| Partial agent completion | FAIL - No recovery |
| Model downgrade | FAIL - No detection |
| Session persistence | PARTIAL - Manual MANIFEST read required |
| Conflicting plans | FAIL - No coordination |

---

## STRESS TEST RESULTS

| Condition | Outcome |
|-----------|---------|
| 6 agents parallel | Likely overflow without strict summary limits |
| Tight deadline | Quality degrades, gate bypassed |
| DST transition | Incorrect time calculations |
| Exchange latency spike | Emergency close fails |
| Market gap overnight | DD from gap not handled in strategy |

---

## MANUAL VERIFICATION NEEDED

- [ ] Verify /create-plan command exists or needs creation
- [ ] Confirm paper trading phase can be added to workflow
- [ ] Test emergency close with latency injection
- [ ] Validate unrealized PnL tracking in current strategy code
- [ ] Verify 30% daily consistency check exists in ORACLE metrics
- [ ] Confirm MANIFEST atomic write mechanism
- [ ] Test context overflow scenario with 6 parallel agents

---

## RECOMMENDATIONS

### Priority 1: Fix Before Production

1. **Add paper trading phase** - Mandatory before live
2. **Create external CRITIC** - Not self-review for critical artifacts
3. **Add runtime Apex tests** - Unrealized PnL, emergency close, consistency
4. **Create /create-plan** - With template and validation

### Priority 2: Fix for Robustness

5. **Add file verification** - Confirm write before "COMPLETE"
6. **Implement checkpoint gates** - Abort/modify between phases
7. **Add model verification** - Log and enforce model used
8. **Reduce CRITIC fatigue** - External review for stakes

### Priority 3: Improve Quality

9. **Plan versioning** - Git-based change tracking
10. **Resume command** - Cross-session state recovery
11. **DST centralization** - Single timezone module
12. **Progress tracking** - Heartbeat for long agents

---

## VERDICT: ISSUES_FOUND

**Confidence**: HIGH

**Rationale**: Applied all 7 adversarial techniques with 15 sequential thinking steps. Examined actual files including existing CRITIC_REVIEW.md which proves review gaps exist (DST time zone error was caught by CRITIC, meaning earlier review missed it).

---

## PRE-MORTEM SUMMARY

**Most likely failure mode**: Look-ahead bug survives all review layers because each layer assumes another will catch it, and no layer actually EXECUTES code. Strategy goes live with inflated backtest metrics, real performance is worse, DD exceeds limits.

**Second most likely**: Context overflow during large orchestration causes MANIFEST to be incomplete, subsequent phases operate on partial information, leading to contradictory outputs and eventual GO decision with unvalidated components.

**Third most likely**: Emergency close fails at 4:55 PM ET due to exchange latency, no retry mechanism, position held overnight, account terminated.

**Mitigation**:
1. Add paper trading phase (catches runtime bugs)
2. External CRITIC for critical artifacts (removes self-interest bias)
3. Runtime Apex tests in simulation (proves compliance works)
4. File verification before completion (prevents lost outputs)
5. Checkpoint gates (allows early abort)

---

## CRITIC SELF-REVIEW NOTES

### Verification
- Sequential thinking thoughts used: 15
- Adversarial techniques applied: INVERSION, PRE-MORTEM, STRESS TEST, REGIME SHIFT, APEX TRAP, EDGE CASES, ASSUMPTION AUDIT (all 7)

### Issues Found During Self-Review
1. Initially focused too much on technical gaps, added more Apex-specific paths
2. Clarified that /create-plan doesn't exist (verified via Glob)
3. Added evidence from existing CRITIC_REVIEW.md to support claims

### Assumptions Challenged
1. "Output protocol is sufficient" -> No, needs verification hooks
2. "Self-review is adequate" -> No, conflicts of interest exist
3. "Static review catches bugs" -> No, runtime testing required

### Confidence Level
HIGH - Multiple sources of evidence, concrete file examination, systematic technique application

---

*"Every bug found now is a loss prevented later."*

CRITIC v1.1 - Adversarial Quality Guardian
