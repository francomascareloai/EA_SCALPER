# PLAN: Phase 09 - Final Synthesis

> **Changelog:**
> - 2025-12-16: Applied CRITIC review fixes (C-001 through C-010). Added conflict resolution, quantitative GO/NO-GO, Apex checklist, enhanced issue tracker, timeline, and clarified DAEMON role.

## Objective
Consolidate all phase findings into actionable reports, prioritize issues, and produce GO/NO-GO recommendation for current codebase.

## Inputs

- `PHASE_01_FINDINGS.md` - Core Strategy
- `PHASE_02_FINDINGS.md` - SMC Indicators
- `PHASE_03_FINDINGS.md` - Risk Modules
- `PHASE_04_FINDINGS.md` - Signal Generators
- `PHASE_05_FINDINGS.md` - Execution Layer
- `PHASE_06_FINDINGS.md` - Backtest Scripts
- `PHASE_07_FINDINGS.md` - Test Coverage
- `PHASE_08_FINDINGS.md` - Integration Points

**Note:** This file is numbered `10-PHASE-09-PLAN.md` because it represents the 10th step (Phase 09 synthesis) in the overall audit workflow, which includes phases 01-08 plus this synthesis phase.

## Timeline

**Expected Duration:** 45-90 minutes total
- Mechanical synthesis (aggregation, dedup): 30-45 minutes
- DAEMON strategic overlay: 10-20 minutes
- SENTINEL final review: 10-15 minutes
- Final document assembly: 5-10 minutes

**Milestone Checkpoints:**
- T+30min: All issues aggregated and deduplicated
- T+60min: GO/NO-GO criteria evaluated
- T+90min: All 3 deliverables complete

## Deliverables

### 1. AUDIT_REPORT.md (Master Document)

**Structure:**
```markdown
# Nautilus Deep Audit Report

## Executive Summary
- Total modules reviewed: X
- Critical issues: X
- High issues: X
- Medium issues: X
- Low issues: X
- GO/NO-GO: [DECISION]
- Confidence Level: [HIGH/MEDIUM/LOW]

## Scope Coverage
- Files reviewed: [list]
- Lines analyzed: [count]
- Agents used: [count]

## Key Findings by Category
### Apex Compliance
### Temporal Integrity
### Risk Management
### Signal Quality
### Execution Realism
### Test Coverage

## Critical Issues (P0)
[Detailed list]

## Recommendations
[Prioritized list]

## Next Steps
[Action items with timeline]
```

### 2. ISSUES_TRACKER.md

**Structure:**
```markdown
# Issues Tracker

## Status Values
- **Open**: Not yet addressed
- **In Progress**: Being worked on
- **Fixed**: Resolved (include commit hash)
- **Won't Fix**: Accepted risk with justification
- **Deferred**: Postponed to future milestone

## Critical (P0) - Must Fix Before Live
| ID | Phase | Module | Location | Description | Status | Owner | Effort | Deadline |
|----|-------|--------|----------|-------------|--------|-------|--------|----------|

## High (P1) - Fix Within 1 Week of Live Decision
| ID | Phase | Module | Location | Description | Status | Owner | Effort | Deadline |
|----|-------|--------|----------|-------------|--------|-------|--------|----------|

## Medium (P2) - Fix Within 1 Month of Live Trading
| ID | Phase | Module | Location | Description | Status | Owner | Effort | Deadline |
|----|-------|--------|----------|-------------|--------|-------|--------|----------|

## Low (P3) - Nice to Have / Optimization
| ID | Phase | Module | Location | Description | Status | Owner | Effort | Deadline |
|----|-------|--------|----------|-------------|--------|-------|--------|----------|
```

**Column Definitions:**
- **Phase**: Source phase (01-08)
- **Location**: file:line reference (e.g., `risk_manager.py:142`)
- **Effort**: S (hours), M (days), L (weeks)
- **Deadline**: Relative to live trading start

### 3. RECOMMENDATIONS.md

**Structure:**
```markdown
# Prioritized Recommendations

## Immediate (Blocks Live Trading)
1. [Recommendation]
   - Why: [Reason]
   - Impact: [What happens if not done]
   - Effort: [S/M/L estimate]
   - Deadline: Before first live trade

## Short-Term (Before First Live Trading Month)
[Similar structure]

## Medium-Term (Before Scaling Beyond Initial Capital)
[Similar structure]

## Long-Term (Optimization / Future Releases)
[Similar structure]
```

## Conflict Resolution Protocol

When synthesizing findings from multiple phases:

1. **Duplicate Issues:** Merge by `file:line` reference, keep highest severity assigned by any phase.

2. **Severity Disagreement:** Always take the conservative (higher) severity. Document the disagreement.

3. **Contradicting Findings:** Flag for human review with `[CONFLICT]` marker. Do not auto-resolve.

4. **Same Issue, Different Symptoms:** Create parent issue linking related child issues.

5. **Deduplication Key:** `{file}:{line_range}:{issue_type}`

## Synthesis Process

### Step 1: Aggregate Findings (Mechanical - Generic Agent)
- Read all phase findings
- Extract issues with severity and file:line location
- Apply deduplication using conflict resolution protocol
- Categorize by type (Apex, temporal, risk, etc.)

**Verification Checklist:**
- [ ] Phase 01 issues counted: X
- [ ] Phase 02 issues counted: X
- [ ] Phase 03 issues counted: X
- [ ] Phase 04 issues counted: X
- [ ] Phase 05 issues counted: X
- [ ] Phase 06 issues counted: X
- [ ] Phase 07 issues counted: X
- [ ] Phase 08 issues counted: X
- [ ] Total issues before dedup: X
- [ ] Total issues after dedup: X (reduction explained)
- [ ] No unresolved duplicates in tracker

### Step 2: Prioritize Issues (Mechanical - Generic Agent)
**Severity Matrix:**
| Impact \ Likelihood | High | Medium | Low |
|---------------------|------|--------|-----|
| **High** | CRITICAL | HIGH | MEDIUM |
| **Medium** | HIGH | MEDIUM | LOW |
| **Low** | MEDIUM | LOW | LOW |

**Impact Categories:**
- Account termination (Apex rule violation) = CRITICAL
- Direct money loss (bad trades, wrong sizing) = HIGH
- Suboptimal performance (missed edge) = MEDIUM
- Code quality (style, maintainability) = LOW

**Rationale Requirement:** Each severity assignment MUST include evidence/rationale.

### Step 3: GO/NO-GO Decision

**GO Criteria (ALL must pass with evidence):**

**Apex Compliance (explicit verification):**
- [ ] Trailing DD 5% from HWM: verified in code (cite `file:line`)
- [ ] Includes unrealized P&L in DD calc: verified in code (cite `file:line`)
- [ ] No overnight positions: close-all by 4:59 PM ET verified (cite `file:line`)
- [ ] No new trades after 4:30 PM ET: verified (cite `file:line`)
- [ ] Emergency force-close from 4:55 PM ET: verified (cite `file:line`)
- [ ] Max 30% profit/day consistency rule: verified (cite `file:line`)

**Issue Resolution:**
- [ ] Zero CRITICAL issues (or all CRITICAL fixed with commit hash)
- [ ] Zero HIGH issues without documented workaround AND deadline
- [ ] All HIGH workarounds reviewed by SENTINEL

**Code Quality:**
- [ ] `pytest` suite passes 100% (attach log)
- [ ] `mypy --strict` passes (attach log)
- [ ] No look-ahead bias: all signal generation uses only past data (verified by ORACLE with test)

**NO-GO Triggers (ANY one triggers immediate NO-GO):**
- CRITICAL issue found without fix
- HIGH issue without workaround or deadline
- Any Apex rule not verifiable in code
- Data leakage / look-ahead detected
- Risk module fails pytest
- Emergency close not testable

### Step 4: Strategic Overlay (DAEMON)

**Important:** DAEMON provides strategic review AFTER mechanical synthesis is complete. DAEMON does NOT perform aggregation or categorization.

DAEMON applies strategic lens:

1. **Are we solving the right problem?**
   - Is SMC the right approach for scalping?
   - Is the complexity justified by edge?

2. **What are we missing?**
   - Blind spots in the audit?
   - Assumptions we didn't challenge?

3. **What could make this fail?**
   - Market regime change?
   - Broker behavior?
   - Prop firm rule change?

4. **What's the minimum viable version?**
   - Can we simplify?
   - What can we remove?

### Step 5: Final Review (SENTINEL)

SENTINEL reviews the GO/NO-GO decision with focus on:
- Apex compliance verification
- Risk management completeness
- DD limit enforcement

**SENTINEL can override GO to NO-GO** if any Apex concern is not adequately addressed.

### Step 6: Generate Recommendations
- Prioritize by impact/effort ratio
- Group by dependency
- Create action plan with deadlines relative to live trading start

## Success Criteria
- [ ] All 8 phase findings aggregated
- [ ] Deduplication applied with conflict resolution
- [ ] Issues prioritized by severity with rationale
- [ ] GO/NO-GO decision made with quantitative evidence
- [ ] Apex checklist 100% complete
- [ ] Recommendations prioritized with timeline
- [ ] Action plan created
- [ ] All 3 deliverables completed
- [ ] SENTINEL sign-off obtained

## Agent Responsibilities

**Step 1-2-3: Generic Synthesis Agent (model: opus)**
- Mechanical aggregation
- Deduplication with conflict resolution
- Severity assignment with rationale
- GO/NO-GO criteria evaluation with evidence
- Draft ISSUES_TRACKER.md

**Step 4: DAEMON Agent (model: opus)**
- Strategic overlay only
- Does NOT modify issue tracker
- Provides strategic recommendations section
- CRITIC self-review applied

**Step 5: SENTINEL Agent (model: opus)**
- Final Apex compliance review
- GO/NO-GO sign-off or override
- Risk management validation

**Context Management:**
- Pre-summarize each phase to <500 words before synthesis
- Prevents context overflow in DAEMON
- Use `.planning/phases/08-nautilus-deep-audit/synthesis_summaries/` for phase summaries

## Output Files
- `AUDIT_REPORT.md`
- `ISSUES_TRACKER.md`
- `RECOMMENDATIONS.md`

All in `/home/franco/projetos/EA_SCALPER_XAUUSD/.planning/phases/08-nautilus-deep-audit/`

---

## CRITIC RE-REVIEW (2025-12-16)

### Previous Issues Status

The changelog claims "C-001 through C-010" fixes but does not itemize individual issues. Verification by presence of claimed additions:

| Claimed Fix | Status | Evidence |
|-------------|--------|----------|
| Conflict resolution | VERIFIED | Lines 134-146: 5 rules for duplicates, severity, contradictions |
| Quantitative GO/NO-GO | VERIFIED | Lines 185-214: explicit checkboxes with "cite file:line" evidence requirements |
| Apex checklist | VERIFIED | Lines 189-196: all 6 Apex rules including unrealized P/L in HWM |
| Enhanced issue tracker | VERIFIED | Lines 75-109: Status Values, Effort (S/M/L), Deadline columns |
| Timeline | VERIFIED | Lines 22-33: 45-90 min duration, milestone checkpoints |
| Clarified DAEMON role | VERIFIED | Lines 215-237: explicit "AFTER mechanical synthesis" note |

### New Issues Found

| Severity | Issue | Recommendation |
|----------|-------|----------------|
| LOW | No C-001 to C-010 mapping table | Documentation-only; fixes are present even if not traced individually |
| LOW | No explicit escalation path after SENTINEL NO-GO override | Implicit via ISSUES_TRACKER.md workflow; consider adding explicit "fix and re-run" note |
| MEDIUM | No fallback for missing/incomplete phase findings | Add: "If any PHASE_XX_FINDINGS.md is missing, HALT synthesis and escalate" |

### Verdict

**APPROVED**

All claimed fixes are verified present and correctly implemented. Three new issues found are LOW-MEDIUM severity and non-blocking. The plan is ready for execution.
