# MASTER PLAN: Nautilus Deep Audit

## Overview

| Attribute | Value |
|-----------|-------|
| **Plan ID** | 08-nautilus-deep-audit |
| **Created** | 2025-12-15 |
| **Owner** | Franco |
| **Status** | DRAFT - PENDING APPROVAL |
| **Est. Agents** | 20+ (with parallel execution) |
| **Est. Lines** | ~18,000+ |

## Purpose

Comprehensive critical analysis of ALL NautilusTrader components in this project:
- Strategies
- Indicators
- Risk modules
- Signal generators
- Execution layer
- Backtest scripts
- Tests

**Goal:** Identify bugs, design flaws, Apex compliance gaps, and improvement opportunities BEFORE going live.

## Phase Structure

| Phase | Plan File | Focus | Agents |
|-------|-----------|-------|--------|
| 01 | `02-PHASE-01-PLAN.md` | Core Strategy | 1-2 |
| 02 | `03-PHASE-02-PLAN.md` | SMC Indicators | 4 parallel |
| 03 | `04-PHASE-03-PLAN.md` | Risk Modules | 3 parallel |
| 04 | `05-PHASE-04-PLAN.md` | Signal Generators | 2 parallel |
| 05 | `06-PHASE-05-PLAN.md` | Execution Layer | 2 parallel |
| 06 | `07-PHASE-06-PLAN.md` | Backtest Scripts | 5 parallel |
| 07 | `08-PHASE-07-PLAN.md` | Test Coverage | 1 (haiku) |
| 08 | `09-PHASE-08-PLAN.md` | Integration Points | 2 parallel |
| 09 | `10-PHASE-09-PLAN.md` | Final Synthesis | 1 (DAEMON) |

## Execution Order

```
Phase 01 (Core Strategy)
    ↓ (findings inform Phase 02-05)
Phases 02, 03, 04, 05 (parallel possible)
    ↓
Phase 06 (Backtest Scripts - depends on strategy understanding)
    ↓
Phase 07 (Test Coverage - depends on knowing what exists)
    ↓
Phase 08 (Integration - depends on all modules reviewed)
    ↓
Phase 09 (Final Synthesis - depends on all phase findings)
```

## CRITIC Protocol (Mandatory)

Every phase MUST include CRITIC self-review:
- Use sequential-thinking MCP (12-15 thoughts)
- Apply adversarial lens
- Check Apex compliance
- Verify temporal integrity
- Document assumptions challenged

Reference: `.claude/agents/critic-adversarial.md`

## Deliverables

### Per Phase
- `PHASE_XX_FINDINGS.md` in this directory

### Final
- `AUDIT_REPORT.md` - Master findings
- `ISSUES_TRACKER.md` - Bug/issue tracker
- `RECOMMENDATIONS.md` - Prioritized improvements

## Success Criteria

- [ ] All 9 phases completed
- [ ] All modules reviewed with CRITIC
- [ ] Apex compliance verified (5 rules)
- [ ] No unaddressed CRITICAL issues
- [ ] GO/NO-GO decision documented
- [ ] Action plan created

## Approval

To approve this plan and begin execution, confirm:
1. Scope is correct
2. Phase priorities are correct
3. Parallel execution is acceptable
4. Resource commitment understood

---

**Files in this plan:**

```
.planning/phases/08-nautilus-deep-audit/
├── 00-BRIEF.md           # High-level brief
├── 01-ROADMAP.md         # Phase overview
├── 02-PHASE-01-PLAN.md   # Core Strategy
├── 03-PHASE-02-PLAN.md   # SMC Indicators
├── 04-PHASE-03-PLAN.md   # Risk Modules
├── 05-PHASE-04-PLAN.md   # Signal Generators
├── 06-PHASE-05-PLAN.md   # Execution Layer
├── 07-PHASE-06-PLAN.md   # Backtest Scripts
├── 08-PHASE-07-PLAN.md   # Test Coverage
├── 09-PHASE-08-PLAN.md   # Integration Points
├── 10-PHASE-09-PLAN.md   # Final Synthesis
└── MASTER-PLAN.md        # This file
```
