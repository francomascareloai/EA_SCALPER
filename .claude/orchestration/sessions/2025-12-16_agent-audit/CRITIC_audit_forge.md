# CRITIC ADVERSARIAL AUDIT: FORGE-NAUTILUS v1.0

**Artifact**: `.claude/agents/forge-nautilus.md`
**Type**: Sub-agent Specification
**Reviewer**: CRITIC v1.1
**Date**: 2025-12-16
**CLAUDE.md Version**: 3.10.9

---

## VERDICT: ISSUES_FOUND

The FORGE-NAUTILUS v1.0 spec is **functionally solid** but has **critical compliance gaps** that need addressing before production use.

---

## SEVERITY SUMMARY

| Severity | Count |
|----------|-------|
| CRITICAL | 3 |
| HIGH | 7 |
| MEDIUM | 10 |
| LOW | 5 |

---

## CRITICAL ISSUES (Must Fix)

### C1. Missing Version Reporting in Output Format

**Location**: Missing from spec (required by CLAUDE.md 3.10.9)

**Issue**: CLAUDE.md 3.10.9 explicitly requires:
```
## Agent Output Header
AGENT: [name]
VERSION: [from spec, e.g., FORGE v2.1]
CLAUDE_MD_VERSION: [e.g., 3.10.9]
STATUS: COMPLETE/PARTIAL/FAILED
```

FORGE spec has no output format template and doesn't mention version reporting.

**Impact**: Orchestrator cannot verify spec version alignment. Version drift goes undetected.

**Fix**: Add `## OUTPUT FORMAT (MANDATORY)` section with version header template.

---

### C2. Missing 4:55 PM ET Emergency Close Gate

**Location**: HARD GATES section (line 35)

**Issue**: FORGE mentions:
- 4:30 PM block (correct)
- 4:59 PM flat (correct)

But **MISSING**: "emergency force-close from 4:55 PM ET" from CLAUDE.md.

**Impact**: Code could be written that waits until 4:59 PM to close, violating the emergency gate.

**Fix**: Add to HARD GATES: `| Emergency Close | 4:55 PM ET → force-close all positions |`

---

### C3. Missing "Unrealized P/L in HWM" Emphasis

**Location**: HARD GATES section (line 35)

**Issue**: CLAUDE.md explicitly says "Trailing DD = 5% from HIGH-WATER MARK (includes unrealized!)". FORGE just says "trailing DD 5% from HWM" without the critical "(includes unrealized)" detail.

**Impact**: Developer could implement HWM tracking that only considers realized P/L, causing incorrect DD calculation and potential account termination.

**Fix**: Update to: "Trailing DD 5% from HWM **(includes unrealized P/L)**"

---

## HIGH ISSUES (Should Fix)

### H1. No Structured Output Template

**Location**: CORE section (line 21)

**Issue**: Current: "Output: Decision + Rationale + Patch + Validation + 1st/2nd/3rd-order risks + Next step"

This is a list, not a template. Easy to forget components. Inconsistent outputs.

**Fix**: Add explicit markdown template with sections for each component.

---

### H2. Missing REGIME SHIFT in Self-Review Techniques

**Location**: Workflow step 5 (line 95)

**Issue**: FORGE lists 6 CRITIC techniques: "INVERSION, PRE-MORTEM, STRESS TEST, APEX TRAP, EDGE CASES, ASSUMPTION AUDIT"

But CRITIC v1.1 has 7 techniques - **REGIME SHIFT is missing**.

**Impact**: Self-review might not consider how code behaves across different market conditions.

**Fix**: Add REGIME SHIFT to the technique list.

---

### H3. No Explicit Apex Violation Refusal Guidance

**Location**: Missing

**Issue**: Spec says "Ask only if blocking" but also "Apex non-negotiable". What if user explicitly asks for Apex violation?

**Impact**: Agent might struggle with conflicting instructions.

**Fix**: Add: "If user requests action that violates Apex rules → REFUSE and explain why. Apex is non-negotiable regardless of user instructions."

---

### H4. Missing NAUTILUS Escalation for Architecture

**Location**: "When to Call Other Subagents" table (line 165)

**Issue**: Table lists CRUCIBLE, ORACLE, SENTINEL, PERF_OPT, REVIEWER, GIT_GUARDIAN, CRITIC. But **NAUTILUS is missing**.

CLAUDE.md has: "NautilusTrader Architecture → NAUTILUS"

**Impact**: FORGE might make architecture decisions that should be delegated to NAUTILUS.

**Fix**: Add row: `| NautilusTrader architecture | NAUTILUS |`

---

### H5. Missing ARGUS Escalation for Research

**Location**: "When to Call Other Subagents" table

**Issue**: ARGUS (research agent) is not listed. If implementation requires research on papers, ML techniques, or external approaches, FORGE has no guidance.

**Fix**: Add row: `| Research needs (papers, ML) | ARGUS |`

---

### H6. No Maximum Self-Review Iterations

**Location**: Workflow step 5 (line 97)

**Issue**: "If issues found → fix and re-run self-review" has no exit condition.

**Impact**: Could infinite loop if unfixable issue exists.

**Fix**: Add: "Max 3 self-review iterations. If still failing critical/high, escalate to orchestrator with summary."

---

### H7. REVIEWER Position in Handoff Unclear

**Location**: HARD GATES (line 39)

**Issue**: Says "FORGE → REVIEWER → ORACLE → SENTINEL chain mandatory" but this could be interpreted as "FORGE invokes REVIEWER" which is impossible (sub-agents can't spawn sub-agents).

**Impact**: REVIEWER step could be skipped because agent doesn't know how to invoke it.

**Fix**: Clarify: "After FORGE completes, orchestrator MUST route to REVIEWER before ORACLE. FORGE returns with NEEDS_REVIEW status."

---

## MEDIUM ISSUES (Improve Quality)

### M1. No Error Handling Patterns

**Location**: NautilusTrader Patterns section

**Issue**: All examples show happy path. No exception handling, no connection failure handling, no order rejection handling.

**Fix**: Add "Error Handling Patterns" subsection with examples.

---

### M2. No Testing Patterns

**Location**: Missing

**Issue**: "pytest must pass" but no guidance on what to test or how to write tests for strategies.

**Fix**: Add "Testing Patterns" section with unit test examples for strategies.

---

### M3. No HWM Tracking Code Pattern

**Location**: NautilusTrader Patterns section

**Issue**: HWM tracking is critical for Apex but no code example provided.

**Fix**: Add HWM tracking pattern showing how to track both realized and unrealized P/L.

---

### M4. No 30% Consistency Rule Implementation Guidance

**Location**: HARD GATES (line 35)

**Issue**: Mentions "30% max/day" but no implementation guidance. What happens when 30% is reached?

**Fix**: Add section explaining how to track daily profit and what action to take at threshold.

---

### M5. Missing Intermediate DD Levels

**Location**: HARD GATES

**Issue**: CLAUDE.md has: "1.5% warn → 2.0% caution → 2.5% reduce → 3.0% HALT"

FORGE only mentions final HALT levels (4.0%/4.5%).

**Fix**: Add intermediate levels with expected behavior at each.

---

### M6. "Patch" Format Unspecified

**Location**: CORE output (line 21)

**Issue**: "Patch" could mean full file, diff, edit instructions. Unclear.

**Fix**: Clarify: "Patch = Edit tool format (file_path, old_string, new_string) or unified diff"

---

### M7. No Scope Creep Detection

**Location**: Missing

**Issue**: No guidance on when task is too large or when to refuse.

**Fix**: Add: "Max 3 files or 500 LOC per task. Larger = propose task breakdown to orchestrator."

---

### M8. Assumes Tests Exist

**Location**: Workflow step 4 (line 90)

**Issue**: "pytest -q (must pass)" assumes tests exist. What if no tests for the module?

**Fix**: Add: "If no tests exist for touched code, create them before reporting done."

---

### M9. mypy Scope Unclear

**Location**: Workflow step 4

**Issue**: "mypy --strict . (must pass)" - entire repo or just touched files?

**Fix**: Clarify: "mypy --strict on touched files minimum. If existing type errors block, document and proceed."

---

### M10. No Logging Patterns

**Location**: Missing

**Issue**: No guidance on what to log, how to format, integration with existing logging.

**Fix**: Add "Logging Patterns" section.

---

## LOW ISSUES (Nice to Have)

### L1. No Configuration Patterns
**Issue**: How to handle strategy parameters and configuration.

### L2. No State Management Patterns
**Issue**: Persistence across restarts, state recovery.

### L3. No Async Patterns
**Issue**: If NautilusTrader uses async, no guidance provided.

### L4. Green Field Not Addressed
**Issue**: Workflow assumes existing code. No guidance for new projects.

### L5. Stub/Partial Implementation Policy Unclear
**Issue**: Can user request incomplete code? Policy not stated.

---

## ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| CLAUDE.md always up to date | Could have version drift | Add version check in output |
| All MCP tools available | Tools can fail/timeout | Add fallback strategies |
| sequential-thinking reliable | MCP could fail | Add retry/fallback |
| mypy+pytest sufficient | Misses integration tests | Note limitation, defer to ORACLE |
| Self-review as good as external | Cognitive bias | Note self-review limitations |
| nautilus_trader APIs stable | APIs change | Always verify via Context7 |
| on_bar <1ms achievable | Very tight for Python | Add guidance on achieving this |

---

## EDGE CASES TESTED

| Scenario | Result |
|----------|--------|
| No existing code (green field) | Gap - not addressed |
| No tests exist for module | Gap - should say "create them" |
| mypy fails on existing code | Gap - scope unclear |
| ONNX model not available | Gap - dependency coordination missing |
| Backtest fails post-change | Covered - ORACLE in handoff |
| Partial implementation requested | Gap - policy unclear |

---

## STRESS TEST RESULTS

| Condition | Outcome |
|-----------|---------|
| 20 files to refactor | Gap - no scope limit |
| Complex 15-factor strategy | Gap - no task breakdown guidance |
| Urgent production fix | OK - still requires review (correct) |
| Undocumented NT feature | Gap - no source code fallback |
| User requests Apex violation | Gap - no explicit refusal protocol |

---

## MANUAL VERIFICATION NEEDED

- [ ] Verify CLAUDE.md version 3.10.9 is current
- [ ] Verify NAUTILUS agent spec exists and is aligned
- [ ] Verify ARGUS agent spec exists and is aligned
- [ ] Test that Context7 has nautilus_trader docs available
- [ ] Verify 4:55 PM gate is implemented in existing code

---

## PRE-MORTEM SUMMARY

**Most Likely Failure Mode**: HWM calculated without unrealized P/L, leading to incorrect trailing DD and potential account termination.

**Second Most Likely**: Self-review misses look-ahead bias because REGIME SHIFT not applied.

**Third Most Likely**: REVIEWER skipped in handoff, code review gaps reach production.

**Mitigation**:
1. Fix C3 (unrealized P/L emphasis)
2. Fix H2 (add REGIME SHIFT)
3. Fix H7 (clarify REVIEWER mandatory)

---

## CONFIDENCE: HIGH

**Reason**: All identified issues are concrete gaps that can be verified against CLAUDE.md 3.10.9 and CRITIC v1.1 specs. The issues are objective (missing text, missing sections) rather than subjective interpretations.

---

## RECOMMENDATIONS

### Immediate (v1.1 Update)
1. Add OUTPUT FORMAT section with version header
2. Add 4:55 PM emergency close to HARD GATES
3. Add "(includes unrealized P/L)" to HWM description
4. Add REGIME SHIFT to self-review techniques
5. Add NAUTILUS and ARGUS to escalation table
6. Add max 3 iterations for self-review loop
7. Add explicit Apex violation refusal guidance

### Near-term (v1.2 Update)
1. Add Error Handling Patterns section
2. Add Testing Patterns section
3. Add HWM Tracking Pattern
4. Add scope limits and task breakdown guidance
5. Clarify mypy scope and test creation policy

### Long-term
1. Add Configuration Patterns
2. Add State Management Patterns
3. Add Async Patterns (if relevant to NautilusTrader)

---

**CRITIC v1.1 - Adversarial Quality Guardian**
*"Every gap found now is a loss prevented later."*
