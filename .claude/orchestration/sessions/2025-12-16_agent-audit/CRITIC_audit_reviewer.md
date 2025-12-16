# CRITIC Adversarial Audit: REVIEWER v2.1

**Artifact**: `.claude/agents/generic-code-reviewer.md`
**Type**: Agent Specification
**Reviewer**: CRITIC v1.1
**Date**: 2025-12-16
**CLAUDE_MD_VERSION**: 3.10.9

---

## VERDICT: BLOCKED

The REVIEWER v2.1 specification has significant gaps that could lead to information loss in the handoff chain and inconsistent review quality. Must fix CRITICAL and HIGH issues before operational use.

---

## CRITICAL ISSUES (1)

### 1. Missing AGENT_VERSION in Output Template
**Location**: Lines 59-81 (Output Template section)
**Impact**: Violates CLAUDE.md v3.10.9 mandatory version_reporting requirement. Orchestrator cannot verify spec version used, leading to potential reproducibility issues and undetected version mismatches.
**CLAUDE.md Requirement**:
```
Every sub-agent MUST include in output: AGENT_VERSION: [version from spec header]
...
AGENT: [name]
VERSION: [from spec, e.g., FORGE v2.1]
CLAUDE_MD_VERSION: [e.g., 3.10.9]
STATUS: COMPLETE/PARTIAL/FAILED
```
**Fix**: Add version header to output template:
```text
REVIEW SUMMARY
AGENT: REVIEWER
VERSION: v2.1
CLAUDE_MD_VERSION: [from context]
STATUS: COMPLETE/PARTIAL/FAILED

Scope: [files/areas]
Verdict: [APPROVE / CHANGES_REQUIRED / BLOCK]
...
```

---

## HIGH ISSUES (5)

### 2. Self-Review Protocol Contradiction
**Location**: Lines 88-96 (CRITIC Self-Review Protocol)
**Impact**: The spec says "Read `.claude/agents/critic-adversarial.md` for full CRITIC protocol" but CLAUDE.md explicitly states "Sub-agents cannot spawn other sub-agents. CRITIC is applied via SELF-REVIEW." This ambiguity could cause:
- Operational failure if REVIEWER tries to spawn CRITIC
- Reduced rigor if the instruction is ignored
- Inconsistent behavior across invocations

**Fix**: Replace current wording with explicit self-review instruction:
```markdown
## CRITIC Self-Review Protocol (INTERNAL - NO SUB-AGENT)

Before issuing final review verdict, apply adversarial self-review internally:
1. Use sequential-thinking MCP (12-15 thoughts) with adversarial mindset
2. Apply techniques from critic-adversarial.md internally:
   - INVERSION: "What bugs did I miss?"
   - PRE-MORTEM: "Why will this code fail in production?"
   - APEX TRAP: "How can this violate prop firm rules?"
   - EDGE CASES: "What boundary conditions aren't handled?"
3. Check: Apex compliance, causality/look-ahead, time gates, sizing bounds
4. Challenge all assumptions about code behavior
5. Only issue APPROVE when confident no critical issues remain
NOTE: Do NOT spawn CRITIC as sub-agent. This IS your self-review.
```

### 3. Missing Structured Handoff Format
**Location**: Lines 83-84 (Handoffs section)
**Impact**: CLAUDE.md defines structured_handoff protocol with Context, Decisions Made, Assumptions, Risks, Open Questions, Next Agent Should. REVIEWER's output template doesn't comply, causing information loss when handing off to ORACLE/SENTINEL.
**CLAUDE.md Requirement**: See structured_handoff section
**Fix**: Add to output template:
```text
## HANDOFF: REVIEWER -> [ORACLE/SENTINEL]

### Context
- Task: [what was reviewed]
- Files: [list of files analyzed]

### Decisions Made
- [decision + rationale]

### Assumptions
- [assumption - why safe]

### Risks Identified
- [risk + severity]

### Open Questions for Next Agent
- [question for ORACLE/SENTINEL]

### Next Agent Should
- [specific validation action]
```

### 4. No Escalation Table
**Location**: Missing entirely
**Impact**: CRITIC spec has explicit "WHEN TO ESCALATE" table. REVIEWER lacks this, leading to ambiguity about when to hand off vs. fix vs. block. In trading systems, unclear escalation = delayed response to critical issues.
**Fix**: Add section:
```markdown
## Escalation Table

| Finding | Escalate To | Action |
|---------|-------------|--------|
| Apex violation detected | SENTINEL | BLOCK + mandatory handoff |
| Statistical issues (WFE, SQN suspicious) | ORACLE | Flag for validation |
| Implementation bugs (fixable) | FORGE | Return for fixes |
| Strategy design flaws | CRUCIBLE | Redesign needed |
| Architecture problems | NAUTILUS | Review needed |
| Performance budget exceeded | PERF_OPT | Profile + fix |
| Security issue | Immediate BLOCK | Notify user |
```

### 5. Missing NautilusTrader-Specific Patterns
**Location**: Technical Checklist section
**Impact**: CRITIC spec explicitly mentions NautilusTrader lifecycle (on_start, on_bar, on_stop), cleanup requirements, and temporal discipline. REVIEWER lacks this domain knowledge, potentially missing Nautilus-specific bugs.
**Fix**: Add section:
```markdown
## NautilusTrader Code Review Checklist

### Lifecycle
- [ ] Strategy implements on_start, on_bar, on_stop correctly
- [ ] on_stop closes ALL positions and cancels ALL orders
- [ ] on_start initializes state correctly (no stale data)

### Temporal Discipline
- [ ] on_bar only uses data from COMPLETED bars
- [ ] No look-ahead in indicator calculations
- [ ] Proper bar completion check before signal generation

### Event Handling
- [ ] on_quote_tick respects <100us budget
- [ ] on_bar respects <1ms budget
- [ ] No blocking calls in event handlers
- [ ] Proper error handling for failed orders

### Actor Pattern
- [ ] Actors don't hold trading state
- [ ] Clean separation of concerns
- [ ] Proper message passing (no direct method calls across actors)
```

### 6. No CONFIDENCE Field in Output
**Location**: Output Template (lines 59-81)
**Impact**: CRITIC outputs CONFIDENCE: HIGH/MEDIUM/LOW with rationale. REVIEWER doesn't, making it harder for orchestrator/downstream agents to assess review reliability.
**Fix**: Add to output template:
```text
CONFIDENCE: [HIGH / MEDIUM / LOW]
Reason: [why this confidence level - what couldn't be verified?]
```

---

## MEDIUM ISSUES (7)

### 7. No Language-Specific Guidance
**Impact**: Python/Nautilus and MQL5 have different idioms, error handling, and type systems. Single checklist may misapply rules.
**Fix**: Add language-specific sub-sections to Technical Checklist.

### 8. No Scope/Size Limits for Review
**Impact**: Spec says "delegate to Explorer for large diffs" but doesn't define "large". 100 lines? 500? 1000?
**Fix**: Add: "For diffs >500 lines or >10 files, delegate to Explorer sub-agent for summary before detailed review of critical paths."

### 9. Missing PROJECT CONTEXT Section
**Impact**: CRITIC has explicit EA_SCALPER_XAUUSD context. REVIEWER just says "inherits from CLAUDE.md" which may not be in context.
**Fix**: Add compact project context section similar to CRITIC's.

### 10. No Edge Case Handling Guidance
**Impact**: What if diff is empty? Binary files? Test-only changes? Non-code files?
**Fix**: Add:
```markdown
## Edge Case Handling

| Case | Action |
|------|--------|
| Empty diff | Report "No changes to review" + verify git status |
| Binary files (ONNX, images) | Flag for manual review, skip code analysis |
| Test-only changes | Apply Technical Checklist only, skip Trading Blockers |
| Config files (YAML, JSON) | Review for security (secrets, keys), schema validity |
| Documentation only | Skip technical review, check for outdated info |
```

### 11. Performance Budget Inconsistency
**Impact**: Spec says "on_quote_tick <100us" but CLAUDE.md says "OnTick <50ms" (MQL5 terminology). Mixed budgets confuse review.
**Fix**: Clarify these are different contexts (Nautilus vs MQL5) or align numbers.

### 12. Missing Security Checklist Details
**Impact**: "no secrets committed/logged" is insufficient. Need patterns to look for.
**Fix**: Add security checklist:
- [ ] No hardcoded API keys, passwords, tokens
- [ ] .env files not committed
- [ ] Credentials not in logs
- [ ] Input validation on external data
- [ ] No eval() or exec() on untrusted input

### 13. Missing Validation Thresholds Table
**Impact**: CRITIC has WFE, SQN, PSR thresholds with red flags. REVIEWER can't verify metric validity in code.
**Fix**: Copy thresholds table from CRITIC or reference it explicitly.

---

## LOW ISSUES (4)

### 14. No Metrics Capture Requirement
**Impact**: No requirement to report lines reviewed, time taken, issues by category.

### 15. No Timeout/Abort Guidance
**Impact**: Long-running reviews might block pipeline with no graceful degradation.

### 16. No Dependency Review Guidance
**Impact**: Changes to requirements.txt, pyproject.toml not covered.

### 17. No Multi-PR Analysis Guidance
**Impact**: Code depending on unmerged changes not addressed.

---

## ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| CLAUDE.md is always in context | Sub-agent spawning may have minimal context | Explicitly reference CLAUDE.md at start OR embed critical rules |
| git repository is clean | Uncommitted changes, detached HEAD could exist | Add git state validation to pre-flight |
| "Trading logic" is clearly distinguishable | Helper functions, utilities blur the line | Define explicit file path patterns that trigger trading rules |
| Performance can be assessed from code | True perf needs profiling | Acknowledge static analysis limits, flag for PERF_OPT if suspicious |
| Handoff chain is executed correctly | No enforcement mechanism | Add explicit verification that prior/next agent was invoked |

---

## EDGE CASES TESTED

| Scenario | Current Handling | Gap |
|----------|-----------------|-----|
| Empty diff | Not addressed | Undefined behavior |
| 5000+ line diff | "Delegate to Explorer" | No threshold defined |
| Test-only changes | Apply full checklist | Overkill, wasted effort |
| Binary files in diff | Not addressed | May fail or skip silently |
| Merge conflict markers | Not addressed | Could APPROVE broken code |
| Generated code (FORGE) | Not addressed | Should be extra skeptical |

---

## STRESS TEST RESULTS

| Condition | Expected Behavior | Actual Behavior (Spec) |
|-----------|------------------|------------------------|
| Time pressure ("deploy in 30 min") | Maintain rigor, refuse shortcuts | No explicit resistance guidance |
| Conflicting evidence | Escalate uncertainty | No conflict resolution protocol |
| Partial context | Request more info | No explicit handling |
| Prior agent disagreement | Structured resolution | No guidance |

---

## MANUAL VERIFICATION NEEDED

- [ ] Verify REVIEWER actually loads CLAUDE.md when spawned as sub-agent
- [ ] Test handoff to ORACLE with current output format - is info preserved?
- [ ] Verify self-review is actually executed (add logging/tracing)
- [ ] Test with NautilusTrader code - does it catch lifecycle issues?
- [ ] Test with large diffs - does Explorer delegation work?

---

## CONFIDENCE: MEDIUM

**Rationale**: The spec functions for basic reviews but has:
- Confirmed CRITICAL violation of version reporting
- Multiple HIGH gaps in handoff chain compliance
- Missing domain knowledge compared to CRITIC spec
- Untested edge cases

---

## PRE-MORTEM SUMMARY

**Most likely failure mode**: REVIEWER issues APPROVE for code with subtle look-ahead bias because it lacks specific detection patterns for Nautilus temporal violations.

**Second most likely**: Information loss in handoff to ORACLE because structured handoff format not used. ORACLE makes suboptimal decisions based on incomplete context.

**Third most likely**: Version mismatch goes undetected. REVIEWER v2.0 spec is used when v2.1 expected, causing inconsistent behavior that's hard to trace.

**Mitigation**:
1. Fix CRITICAL issue immediately (add version to output)
2. Add NautilusTrader-specific checklist
3. Implement structured handoff format
4. Add explicit look-ahead detection patterns

---

## RECOMMENDATIONS SUMMARY

| Priority | Action | Effort |
|----------|--------|--------|
| P0 | Add AGENT_VERSION to output template | 5 min |
| P1 | Clarify self-review as internal (no sub-agent) | 10 min |
| P1 | Add structured handoff format | 15 min |
| P1 | Add escalation table | 10 min |
| P1 | Add NautilusTrader checklist | 20 min |
| P1 | Add CONFIDENCE field | 5 min |
| P2 | Add edge case handling table | 15 min |
| P2 | Add security checklist details | 10 min |
| P2 | Add scope/size limits | 5 min |

**Total estimated effort**: ~1.5 hours for full remediation

---

*CRITIC v1.1 - Adversarial Quality Guardian*
*"Every gap found now is a failure prevented later."*
