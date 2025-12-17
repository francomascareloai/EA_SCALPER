# PLAN: Phase 04 - Signal Generators Audit

> **Changelog:**
> - 2025-12-17: **CRITICAL** - Added mandatory delegation enforcement (Protocol 0). Orchestrator MUST NOT read source files directly.
> - 2025-12-16: Applied CRITIC v1.1 review fixes (C-001 through C-012): Changed agents to REVIEWER, added Apex time gate checks, defined look-ahead test protocol, rebalanced workload, added synthesis step, specified output format, expanded checklists.

---

## ⚠️ MANDATORY DELEGATION (Protocol 0)

> **CRITICAL: The orchestrator MUST NOT read source files directly.**
>
> This phase analyzes ~3,412 lines of signal generation code. Reading these files directly will cause context overflow.

### Orchestrator Behavior

```
❌ WRONG (causes context overflow):
   Orchestrator reads 5 signal generator files directly
   Orchestrator performs scoring logic verification in main context
   → CONTEXT OVERFLOW → Summarization → LOST DETAILS

✅ CORRECT (sustainable):
   Orchestrator spawns REVIEWER sub-agents with delegation prompt
   Each REVIEWER reads assigned files, verifies logic, writes findings
   Each REVIEWER returns 300-word summary to orchestrator
   Orchestrator synthesizes and updates MANIFEST.md
```

### Required Sub-Agent Prompts

**Agent A (Scoring/Entry Chain):**
```
Execute Phase 04 Agent A (Scoring/Entry Chain) of the Nautilus Deep Audit.

DELEGATION PROTOCOL (MANDATORY):
1. YOU read the source files - orchestrator has NOT read them
2. Files to analyze:
   - nautilus_gold_scalper/src/signals/confluence_scorer.py (1002 lines)
   - nautilus_gold_scalper/src/signals/entry_optimizer.py (699 lines)
   - nautilus_gold_scalper/src/signals/mtf_manager.py (395 lines)
3. Focus: Score thresholds, entry logic, MTF alignment, look-ahead detection
4. Write COMPLETE analysis to: .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_04_A_SCORING_FINDINGS.md
5. Return ONLY summary (max 300 words) with issue counts and threshold verification

Plan file: .planning/phases/08-nautilus-deep-audit/05-PHASE-04-PLAN.md
```

**Agent B (News Modules):**
```
Execute Phase 04 Agent B (News Modules) of the Nautilus Deep Audit.

DELEGATION PROTOCOL (MANDATORY):
1. YOU read the source files - orchestrator has NOT read them
2. Files to analyze:
   - nautilus_gold_scalper/src/signals/news_calendar.py (628 lines)
   - nautilus_gold_scalper/src/signals/news_trader.py (688 lines)
3. Focus: News timing, blackout windows, look-ahead in event detection
4. Write COMPLETE analysis to: .planning/phases/08-nautilus-deep-audit/orchestration/PHASE_04_B_NEWS_FINDINGS.md
5. Return ONLY summary (max 300 words) with issue counts

Plan file: .planning/phases/08-nautilus-deep-audit/05-PHASE-04-PLAN.md
```

---

## Objective
Critical analysis of signal generation modules to verify scoring logic correctness, MTF confluence implementation, news filter accuracy, and **Apex compliance** (time gates, DD integration).

## Files Under Review

| File | Lines | Responsibility |
|------|-------|----------------|
| `confluence_scorer.py` | 1002 | Score aggregation |
| `entry_optimizer.py` | 699 | Entry optimization |
| `mtf_manager.py` | 395 | MTF signal management |
| `news_calendar.py` | 628 | News event handling |
| `news_trader.py` | 688 | News-based signals |

**Total:** ~3,412 lines

## Pre-Review Verification

Before agents begin, orchestrator must verify:
- [ ] **Threshold source confirmed**: Check `DOCS/06_REFERENCE/CLAUDE_REFERENCE.md` AND code constants for authoritative threshold definitions
- [ ] **Interface contracts documented**: Map dependencies between confluence_scorer <-> entry_optimizer

## Execution Plan

### Parallel Agent Assignment

**Agent A (REVIEWER):** Scoring, Confluence, and Entry
- `confluence_scorer.py` (1002 lines)
- `entry_optimizer.py` (699 lines)
- `mtf_manager.py` (395 lines)
- **~2,096 lines**

**Agent B (REVIEWER):** News Modules
- `news_calendar.py` (628 lines)
- `news_trader.py` (688 lines)
- **~1,316 lines**

> **Note:** Workload balanced per CRITIC feedback. Agent A handles scoring/entry chain, Agent B specializes in news modules (which require deep look-ahead analysis).

### Post-Parallel Synthesis Step

After both agents complete:
1. Orchestrator reviews both outputs
2. Cross-module dependency analysis (confluence_scorer <-> entry_optimizer interface)
3. Integration issue identification
4. Consolidated PHASE_04_FINDINGS.md creation

## CRITICAL ANALYSIS AREAS

### confluence_scorer.py (LARGEST MODULE)

**Scoring Logic Verification:**
1. Score thresholds match authoritative source?
   - TIER_S: >=90
   - TIER_A: >=80
   - TIER_B: >=70
   - TIER_C: >=60
   - TIER_INVALID: <60

2. Component weights documented?
3. Score inflation/deflation patterns?
4. Edge cases:
   - All components missing?
   - Conflicting signals?
   - Regime mismatch?

**Questions to Answer:**
- What's the execution_threshold? (Should be 70 = TIER_B_MIN)
- How are partial confluences handled?
- Is there score capping at 100? (Cannot exceed)
- Negative score handling?
- NaN/Inf mathematical edge cases?
- Look-ahead in any component?

### mtf_manager.py

**MTF Logic Verification:**
1. HTF (H1) -> Direction filter
2. MTF (M15) -> Structure zones
3. LTF (M5) -> Execution

**Questions to Answer:**
- Is HTF bar confirmed before MTF uses it?
- Temporal alignment correct?
- What if MTF contradicts HTF?
- Bar completion detection?
- Bar buffer sufficient for longest lookback?
- Session boundary handling (Asia/London/NY)?

### entry_optimizer.py

**Entry Optimization Verification:**
1. Fibonacci level integration?
2. OB/FVG zone refinement?
3. Entry price calculation?

**Questions to Answer:**
- How is optimal entry determined?
- Risk/reward calculation correct?
- **Spread cost included in R:R calculation?**
- **Slippage buffer in entry price?**
- Look-ahead in optimization?
- Edge: zone fully mitigated?
- Partial zone mitigation handling?
- **Time gate (4:30 PM ET) compliance?**

### news_calendar.py

**News Filter Verification:**
1. Data source?
2. Event parsing?
3. Time buffer before/after?

**Questions to Answer:**
- Look-ahead in news data? (CRITICAL - see test protocol below)
- How far ahead are events known?
- Impact classification (high/medium/low)?
- Timezone handling?
- Historical backtest mode vs live mode distinction?
- News data source rate limiting?
- Fallback when news data unavailable?

### news_trader.py

**News Signal Verification:**
1. Trade around news logic?
2. Size reduction near news?
3. Entry/exit timing?

**Questions to Answer:**
- Is this active or just filtering?
- Integration with main strategy?
- Look-ahead concerns?

## Look-Ahead Test Protocol (MANDATORY)

**For News Modules (CRITICAL):**

The following test MUST be performed to verify no look-ahead bias:

1. **Trace Test**: For any bar at time T, trace all accessed news data
2. **Temporal Assertion**: `news_event.timestamp <= bar.timestamp` must ALWAYS be true
3. **Result Access Test**: News event RESULTS (actual vs forecast, impact) can ONLY be accessed if `current_bar.timestamp > news_event.release_timestamp`
4. **Negative Test**: Attempt to access future news results - must fail or return None

**For MTF Modules:**
1. **Bar Completion Trace**: When accessing H1 data from M5 bar, verify H1 bar is CLOSED
2. **Temporal Assertion**: `htf_bar.close_time <= ltf_bar.timestamp` must be true

## Apex Compliance Verification (MANDATORY)

All signal modules must be checked for:

| Check | Module(s) | Requirement |
|-------|-----------|-------------|
| Time Gate 4:30 PM ET | entry_optimizer, confluence_scorer | Block new signal generation after 4:30 PM ET |
| Time Gate 4:55 PM ET | all | Emergency mode - no new signals |
| DD Buffer Integration | confluence_scorer | Score penalty when DD > 3.0%? |
| Weekend Gap Handling | all | No signals during weekend gaps |

## CRITIC Checklist

### Scoring (confluence_scorer.py)
| Check | Status |
|-------|--------|
| Thresholds match authoritative source | ⬜ |
| No look-ahead in scoring | ⬜ |
| Edge cases handled | ⬜ |
| Score normalization correct | ⬜ |
| Component weight transparency | ⬜ |
| Unit tests exist | ⬜ |
| Score capping at 100 verified | ⬜ |
| Negative score handling | ⬜ |
| NaN/Inf mathematical edge cases | ⬜ |
| Thread safety (if multi-context) | ⬜ |
| **Time gate (4:30 PM ET) compliance** | ⬜ |
| **DD buffer score penalty** | ⬜ |

### MTF (mtf_manager.py)
| Check | Status |
|-------|--------|
| Temporal alignment verified | ⬜ |
| HTF confirmed before use | ⬜ |
| Conflict resolution documented | ⬜ |
| Performance acceptable | ⬜ |
| Bar buffer sufficient for lookback | ⬜ |
| Session boundary handling | ⬜ |
| Resampling logic correct (if applicable) | ⬜ |

### Entry (entry_optimizer.py)
| Check | Status |
|-------|--------|
| Fibonacci calculation correct | ⬜ |
| Zone validation logic | ⬜ |
| R:R calculation accurate | ⬜ |
| Spread cost included in R:R | ⬜ |
| Slippage buffer in entry price | ⬜ |
| No look-ahead | ⬜ |
| Partial zone mitigation handling | ⬜ |
| **Time gate (4:30 PM ET) compliance** | ⬜ |

### News (news_calendar.py + news_trader.py)
| Check | Status |
|-------|--------|
| No look-ahead in news data | ⬜ |
| **Explicit test: cannot access news result before event timestamp** | ⬜ |
| Data source reliable? | ⬜ |
| Timezone handling correct | ⬜ |
| Impact classification accurate | ⬜ |
| Buffer times configurable | ⬜ |
| Historical backtest vs live mode distinction | ⬜ |
| Fallback when news data unavailable | ⬜ |

## Specific Questions

1. **Score threshold 70**: Does this match `TIER_B_MIN` from definitions?
2. **MTF confluence requirement**: 50.0 - how is this calculated?
3. **News score penalty**: -15 - is this applied correctly?
4. **News size multiplier**: 0.5 - how does this integrate with position_sizer?

## Output Format (MANDATORY)

Each agent must produce output in this format:

```markdown
# Agent [A/B] - Signal Generators Audit Findings

## Summary
- Modules reviewed: [list]
- Lines analyzed: [count]
- Issues found: CRITICAL: X | HIGH: Y | MEDIUM: Z | LOW: W

## Module: [module_name.py]

### Overview
[Brief description of module purpose and responsibilities]

### Findings

| ID | Severity | Issue | Location | Recommendation |
|----|----------|-------|----------|----------------|
| P04-XXX | CRITICAL/HIGH/MEDIUM/LOW | Description | file:line | Fix recommendation |

### Checklist Results
[Completed checklist with ✅/❌/⚠️]

### Look-Ahead Verification
[Explicit trace showing temporal correctness OR violations found]

### Apex Compliance
[Time gate verification results]

## Cross-Module Dependencies
[Interface contracts verified, any issues found]

## Recommendations
[Prioritized list of fixes needed]
```

## Success Criteria

- [ ] All 5 signal modules reviewed with explicit evidence
- [ ] Scoring logic verified against authoritative source (with source cited)
- [ ] Look-ahead test protocol executed with trace evidence for news modules
- [ ] MTF temporal alignment verified with bar timestamp traces
- [ ] News filter temporal integrity confirmed with explicit test results
- [ ] **Apex time gate (4:30 PM ET) compliance verified for entry_optimizer and confluence_scorer**
- [ ] **Cross-module interface contracts verified (confluence_scorer <-> entry_optimizer)**
- [ ] `PHASE_04_FINDINGS.md` completed with required format
- [ ] `MANIFEST.md` created per orchestration_output_protocol

## Agents

**2 parallel REVIEWER agents (model: opus)**
- Agent A: Scoring, Confluence, Entry (2,096 lines)
- Agent B: News modules (1,316 lines)
- Must apply CRITIC self-review internally
- Must use specified output format
- Focus on look-ahead prevention and Apex compliance

## Output

**Primary:** `PHASE_04_FINDINGS.md` in this directory (consolidated from both agents)

**Manifest:** `MANIFEST.md` with:
- Session datetime
- Agent outputs and status
- Severity counts
- Synthesis summary
- Next steps

---

## CRITIC RE-REVIEW (2025-12-16)

### Previous Issues Status
| ID | Issue | Status |
|----|-------|--------|
| C-001 | Agent type should be REVIEWER not generic | FIXED (lines 31, 39, 278) |
| C-002 | Workload imbalance between agents | FIXED (Agent A: 2,096, Agent B: 1,316 lines) |
| C-003 | Missing Apex time gate checks | FIXED (lines 109, 154-164, 180-181, 204, 271) |
| C-004 | No look-ahead test protocol defined | FIXED (lines 139-152, mandatory protocol) |
| C-005 | Missing synthesis step after parallel agents | FIXED (lines 44-51) |
| C-006 | Output format not specified | FIXED (lines 225-262, detailed template) |
| C-007 | Checklists too sparse | FIXED (lines 165-216, expanded per module) |
| C-008 | DD buffer integration not checked | FIXED (line 162, 181-182) |
| C-009 | Score edge cases not listed | FIXED (lines 64-77) |
| C-010 | News look-ahead verification weak | FIXED (lines 139-152, temporal assertions) |
| C-011 | MTF temporal alignment check missing | FIXED (lines 150-152, bar completion trace) |
| C-012 | Success criteria vague | FIXED (lines 265-274, explicit checklist) |

### New Issues Found
None. Minor observation: Pre-review verification (lines 23-25) could explicitly name "orchestrator" as verifier, but this is trivial and implicit from context.

### Verdict
**APPROVED** - All 12 previous issues properly addressed. Plan is ready for execution.
