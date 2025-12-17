# PLAN: Phase 01 - Core Strategy Audit

> **Changelog:**
> - 2025-12-17: **CRITICAL** - Added mandatory delegation enforcement (Protocol 0). Orchestrator MUST NOT read source files directly.
> - 2025-12-16: Applied CRITIC review fixes (C-001, C-002, H-001, H-002, H-003, M-001 through M-005, L-001, L-002). Added Step 0, look-ahead patterns, HWM verification, blocking criteria, time estimates.

---

## ⚠️ MANDATORY DELEGATION (Protocol 0)

> **CRITICAL: The orchestrator MUST NOT read source files directly.**
>
> This phase analyzes ~1600 lines of code. Reading these files directly into the orchestrator's context will cause context overflow and loss of critical details.

### Orchestrator Behavior

```
❌ WRONG (causes context overflow):
   Orchestrator reads gold_scalper_strategy.py (800 lines)
   Orchestrator reads base_strategy.py (600 lines)
   Orchestrator performs CRITIC analysis (15+ thoughts)
   → CONTEXT OVERFLOW → Summarization → LOST DETAILS

✅ CORRECT (sustainable):
   Orchestrator spawns FORGE sub-agent with delegation prompt
   FORGE reads all files, analyzes, writes to PHASE_01_FINDINGS.md
   FORGE returns 300-word summary to orchestrator
   Orchestrator updates MANIFEST.md
   → Context stays clean → Full details preserved in file
```

### Required Sub-Agent Prompt

The orchestrator MUST spawn a sub-agent with this prompt structure:

```
Execute Phase 01 of the Nautilus Deep Audit.

DELEGATION PROTOCOL (MANDATORY):
1. YOU read the source files - orchestrator has NOT read them
2. Files to analyze:
   - nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py
   - nautilus_gold_scalper/src/strategies/base_strategy.py
   - nautilus_gold_scalper/src/strategies/strategy_selector.py
3. Follow the analysis steps in this plan file
4. Write COMPLETE analysis to: .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_01_FINDINGS.md
5. Return ONLY a summary (max 300 words) containing:
   - Top 3-5 findings
   - Issue counts: X CRITICAL, Y HIGH, Z MEDIUM, W LOW
   - Output file path
   - Status: COMPLETE/PARTIAL/FAILED
6. DO NOT return full code snippets in chat - use file:line references

Plan file: .planning/phases/08-nautilus-deep-audit/02-PHASE-01-PLAN.md
```

---

## Objective
Deep critical analysis of the main trading strategy (`GoldScalperStrategy`) and its base class to identify bugs, design flaws, and Apex compliance gaps.

## Files Under Review

| File | Lines | Priority |
|------|-------|----------|
| `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py` | ~800 | P0 |
| `nautilus_gold_scalper/src/strategies/base_strategy.py` | ~600 | P0 |
| `nautilus_gold_scalper/src/strategies/strategy_selector.py` | ~200 | P1 |

---

## Blocking Conditions

> **CRITICAL:** If any of these conditions occur, STOP and report immediately. Do NOT proceed to the next step.

- Files not found at expected paths --> BLOCK, report immediately
- CRITICAL Apex violation found --> BLOCK, mandatory fix required before proceeding
- `on_stop()` does not close positions --> BLOCK, mandatory fix
- Look-ahead bias confirmed in signal generation --> BLOCK, architectural issue

---

## Execution Steps

### Step 0: Pre-Flight Check (Est: 5 min)
- Verify all 3 target files exist at expected paths
- Check file sizes are reasonable (not empty, not truncated)
- Confirm files are readable (no permission issues)
- If ANY file missing --> BLOCK and report

### Step 1: Read and Understand Architecture (Est: 15 min)
- Read all 3 files completely
- Map the inheritance hierarchy
- Document component dependencies
- Identify entry/exit paths

### Step 2: CRITIC Analysis - base_strategy.py (Est: 30 min)
**Focus areas:**
1. **Lifecycle management**
   - `on_start()` initialization correctness
   - `on_stop()` cleanup (positions closed? orders cancelled?)
   - Timer handling for daily reset
   - Trading clock timezone verification (ET/EST/EDT handling)

2. **Position tracking**
   - `_position` state consistency
   - `_daily_trades` counter accuracy
   - `_daily_pnl` calculation

3. **Edge cases**
   - Multiple positions (allowed?)
   - Partial fills handling
   - Order rejection recovery

4. **NautilusTrader-specific checks**
   - `on_stop()` properly cancels all open orders
   - `on_stop()` closes all positions (not just flags)
   - Clock/timer uses correct timezone

**CRITIC Protocol:** MANDATORY: Invoke MCP `sequential-thinking` tool with 12-15 thoughts minimum

### Step 3: CRITIC Analysis - gold_scalper_strategy.py (Est: 45 min)
**Focus areas:**
1. **Apex compliance**
   - Trailing DD tracking (see HWM Verification checklist below)
   - Time gate enforcement (see Time Gates Clarification below)
   - Overnight position prevention
   - 30% consistency cap (see Consistency Cap Verification below)

2. **Signal generation**
   - Look-ahead bias check (see Look-Ahead Bias Patterns below)
   - MTF confluence logic
   - Score threshold application

3. **Trade execution**
   - SL/TP calculation correctness
   - Position sizing integration
   - Order submission flow

4. **Performance**
   - `on_bar` execution time (must be <1ms) - check for blocking calls, loops, I/O
   - `on_quote_tick` execution time (must be <100us) - minimal logic only
   - Any blocking operations? Network calls? File I/O?

**CRITIC Protocol:** MANDATORY: Invoke MCP `sequential-thinking` tool with 15+ thoughts (exhaustive analysis)

### Step 4: CRITIC Analysis - strategy_selector.py (Est: 20 min)
**Focus areas:**
1. **Selection logic correctness**
   - Regime-to-strategy mapping
   - Fallback behavior
   - State transitions

2. **Edge cases**
   - Unknown regime handling
   - Selector disabled scenarios

**CRITIC Protocol:** MANDATORY: Invoke MCP `sequential-thinking` tool with 8-10 thoughts

### Step 5: Cross-Module Integration Check (Est: 20 min)
**Concrete integration points to verify:**
- Data flow: How does regime detection flow to strategy selection?
- State sync: Is position state consistent across base and child strategy?
- Timer coordination: Do reset timers in different modules conflict?
- Order lifecycle: Is order state properly propagated through inheritance chain?
- Event handling: Are `on_event()` handlers properly chaining to parent?

### Step 6: Document Findings (Est: 15 min)
- Create `PHASE_01_FINDINGS.md`
- Classify issues by severity
- Document assumptions challenged
- List recommended fixes

**Total Estimated Time: ~2.5 hours**

---

## Look-Ahead Bias Patterns to Check

> **CRITICAL:** These patterns indicate potential look-ahead bias. Check each one explicitly.

| Pattern | What to Look For | Violation? |
|---------|------------------|------------|
| `bar.close` usage | Used only after bar completion confirmed (bar is not current/forming bar) | [ ] |
| `bar.high` / `bar.low` | Not used for entry signals on forming bars | [ ] |
| `self._bars[-1]` | Access includes completion check before using for signals | [ ] |
| TA indicator calculation | Uses only completed bars, not partial/forming data | [ ] |
| Quote vs Bar mixing | Quote tick data not used as if it were bar data | [ ] |
| Indicator indexing | No `[0]` or `[-1]` on indicators without confirming bar state | [ ] |

**Grep patterns to run:**
```bash
rg "bar\.close" nautilus_gold_scalper/src/strategies/
rg "bar\.high|bar\.low" nautilus_gold_scalper/src/strategies/
rg "_bars\[-1\]" nautilus_gold_scalper/src/strategies/
rg "\.value\[0\]|\.value\[-1\]" nautilus_gold_scalper/src/strategies/
```

---

## Trailing DD HWM Verification

> **CRITICAL:** Apex trailing DD MUST be calculated from HIGH-WATER MARK including unrealized P/L.

| Check | Requirement | Pass/Fail |
|-------|-------------|-----------|
| HWM includes unrealized P/L | HWM = max(closed P/L + open position unrealized P/L), NOT just closed P/L | [ ] |
| HWM update trigger | Updates on every tick/bar when equity > previous HWM | [ ] |
| Floor calculation | floor = HWM * 0.95 (5% trailing) | [ ] |
| Current equity calculation | current_equity = balance + unrealized_pnl (open position) | [ ] |
| Violation detection | If current_equity < floor --> HALT trading | [ ] |

---

## 30% Consistency Cap Verification

> **HIGH:** Must prevent any single day from contributing >30% of profit.

| Check | What to Look For | Pass/Fail |
|-------|------------------|-----------|
| Daily profit tracking | `_daily_pnl` or equivalent field exists and updates correctly | [ ] |
| Account size reference | 30% calculated against account balance or specified base | [ ] |
| Enforcement mechanism | Trading halted when daily profit approaches/exceeds 30% threshold | [ ] |
| Reset behavior | Daily profit resets at market open (not midnight) | [ ] |

---

## Time Gates Clarification

| Time (ET) | Gate Type | Required Behavior |
|-----------|-----------|-------------------|
| 4:30 PM | Block New Trades | No new positions may be opened after this time |
| 4:55 PM | Force Close Start | Begin emergency close of all open positions |
| 4:59 PM | All Closed Deadline | ALL positions MUST be closed by this time |
| Friday | Early Close | Check for Friday-specific early close (if market closes early) |

**Timezone verification:**
- Code must handle ET (Eastern Time), including EST/EDT transitions
- Check for hardcoded timezone strings vs proper timezone library usage

---

## Success Criteria
- [ ] Step 0: All 3 files verified to exist
- [ ] All 3 files reviewed with CRITIC protocol (MCP sequential-thinking tool)
- [ ] Apex compliance verified (5 rules) using detailed checklists above
- [ ] No look-ahead bias found OR documented with specific pattern
- [ ] HWM verification confirms unrealized P/L inclusion
- [ ] 30% consistency cap mechanism verified
- [ ] Performance concerns identified
- [ ] `PHASE_01_FINDINGS.md` completed

---

## Agents

**Primary:** FORGE (model: opus)
- Responsible for deep code analysis
- Must apply CRITIC self-review internally using MCP sequential-thinking tool
- Self-reports confidence level in findings summary

**Fallback:** Orchestrator spawns dedicated CRITIC agent if:
- FORGE confidence < 0.9 (self-reported in findings)
- Orchestrator detects incomplete analysis
- Any CRITICAL issue requires second opinion

---

## CRITIC Checklist for This Phase

| Check | Pass/Fail |
|-------|-----------|
| Trailing DD from HIGH-WATER MARK (incl. unrealized P/L) | [ ] |
| No trades after 4:30 PM ET | [ ] |
| Force close starts from 4:55 PM ET | [ ] |
| ALL positions closed by 4:59 PM ET | [ ] |
| 30% consistency cap enforced (mechanism verified) | [ ] |
| on_stop() cancels all open orders | [ ] |
| on_stop() closes all positions | [ ] |
| No look-ahead in on_bar() (all patterns checked) | [ ] |
| Performance budget respected (<1ms on_bar, <100us on_quote_tick) | [ ] |
| Partial fill handling | [ ] |
| Order rejection recovery | [ ] |
| Timezone handling (ET/EST/EDT) | [ ] |

---

## Output

**Output File:** `.planning/phases/08-nautilus-deep-audit/orchestration/PHASE_01_FINDINGS.md`

---

## MANDATORY EXECUTION PROTOCOL

### Before Starting
1. Read `PROTOCOLS.md` for full protocol details
2. Read `EXECUTION-TEMPLATE.md` for prompt templates
3. Create output file immediately
4. Execute Step 0 (pre-flight check) FIRST

### During Execution
Write findings DIRECTLY to the output file as you go. Do NOT accumulate in memory.

### Output File Structure
```markdown
# Phase 01 Findings: Core Strategy Audit

## Executive Summary
[Brief summary of findings]

## Files Analyzed
- gold_scalper_strategy.py: [status]
- base_strategy.py: [status]
- strategy_selector.py: [status]

## Issues Found

### CRITICAL
- [Issue description, file:line, impact]

### HIGH
- [Issue description, file:line, impact]

### MEDIUM
- [...]

### LOW
- [...]

## Checklist Results

### Look-Ahead Bias Patterns
[Copy from plan with Pass/Fail filled in]

### Trailing DD HWM Verification
[Copy from plan with Pass/Fail filled in]

### 30% Consistency Cap
[Copy from plan with Pass/Fail filled in]

### Time Gates
[Copy from plan with Pass/Fail filled in]

### CRITIC Checklist
[Copy from plan with Pass/Fail filled in]

## CRITIC Self-Review Notes

### Verification
- Sequential thinking thoughts used: [NUMBER >= 12]
- MCP sequential-thinking tool invoked: [YES - MANDATORY]
- Adversarial techniques applied: [INVERSION, PRE-MORTEM, APEX TRAP, etc.]

### Issues Found During Self-Review
1. [Issue] --> [How addressed]

### Assumptions Challenged
1. [Assumption] --> [Challenge] --> [Conclusion]

### Confidence Level: [LOW/MEDIUM/HIGH]
[Justification]

---

## Checkpoint Summary

### Phase: 01
### Status: [COMPLETE/PARTIAL/BLOCKED]
### Issues: X CRITICAL, Y HIGH, Z MEDIUM, W LOW
### Blocking: [any blocking issues - if CRITICAL found, list here]
### Next Phase Ready: [YES/NO/BLOCKED]
```

### Return to Chat
After writing findings file, return ONLY:
- Top 3-5 findings (bullets)
- Issue counts
- File path written
- Status: COMPLETE/BLOCKED
- If BLOCKED: reason and required fix

---

## Session Handoff

If this is the last phase in the session:
1. Verify findings file is complete
2. Update `orchestration/MANIFEST.md`
3. Create `orchestration/HANDOFF_SESSION_N.md` with next steps

---

## CRITIC RE-REVIEW (2025-12-16)

### Previous Issues Status
| ID | Issue | Status |
|----|-------|--------|
| C-001 | Missing blocking conditions / no pre-flight check | FIXED |
| C-002 | Missing look-ahead bias patterns checklist | FIXED |
| H-001 | HWM verification details missing | FIXED |
| H-002 | 30% consistency cap not specified | FIXED |
| H-003 | Time gates not clarified | FIXED |
| M-001 | Time estimates missing | FIXED |
| M-002 | Performance budget not specified | FIXED |
| M-003 | NautilusTrader-specific checks missing | FIXED |
| M-004 | Integration points vague | FIXED |
| M-005 | Success criteria incomplete | FIXED |
| L-001 | CRITIC checklist incomplete | FIXED |
| L-002 | Output structure not detailed enough | FIXED |

### New Issues Found
None.

### Verdict
APPROVED - All 12 claimed fixes verified. Plan is comprehensive and ready for execution.
