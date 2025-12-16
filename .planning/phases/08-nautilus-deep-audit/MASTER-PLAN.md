# MASTER PLAN: Nautilus Deep Audit (v2.0)

## Changelog
- **v2.0**: Applied CRITIC recommendations
  - Added Phase 00 (Foundation Verification) as BLOCKER
  - Added Phase 04.5 (ML Pipeline Audit)
  - Expanded scope: `src/core/`, `src/ml/`, `src/context/`, `src/utils/`
  - Reduced parallel agents to 2-3 per round (CLAUDE.md compliant)
  - Added orchestration output protocol
  - Added CRITIC verification notes requirement
  - Added temporal verification method
  - Upgraded Phase 07 to opus
  - Added conflict resolution protocol

## Overview

| Attribute | Value |
|-----------|-------|
| **Plan ID** | 08-nautilus-deep-audit |
| **Version** | 2.0 |
| **Created** | 2025-12-15 |
| **Owner** | Franco |
| **Status** | READY FOR APPROVAL |
| **Est. Agents** | ~18 (reduced from 21) |
| **Max Parallel** | 2-3 per round |
| **Est. Lines** | ~20,000+ |

## Purpose

Comprehensive critical analysis of ALL NautilusTrader components:
- Foundation (core definitions, data types)
- Strategies
- Indicators
- Risk modules
- Signal generators
- ML pipeline
- Execution layer
- Backtest scripts
- Tests

**Goal:** Identify bugs, design flaws, Apex compliance gaps, and improvement opportunities BEFORE going live.

## Phase Structure (11 Phases)

| Phase | Plan File | Focus | Agents | Rounds |
|-------|-----------|-------|--------|--------|
| 00 | `01-PHASE-00-PLAN.md` | Foundation Verification | 1 | 1 |
| 01 | `02-PHASE-01-PLAN.md` | Core Strategy | 1-2 | 1 |
| 02 | `03-PHASE-02-PLAN.md` | SMC Indicators | 2+2 | 2 |
| 03 | `04-PHASE-03-PLAN.md` | Risk Modules | 2+1 | 2 |
| 04 | `05-PHASE-04-PLAN.md` | Signal Generators | 2 | 1 |
| 04.5 | `05.5-PHASE-04.5-PLAN.md` | ML Pipeline | 1 | 1 |
| 05 | `06-PHASE-05-PLAN.md` | Execution Layer | 2 | 1 |
| 06 | `07-PHASE-06-PLAN.md` | Backtest Scripts | 2+2 | 2 |
| 07 | `08-PHASE-07-PLAN.md` | Test Coverage | 1 | 1 |
| 08 | `09-PHASE-08-PLAN.md` | Integration Points | 2 | 1 |
| 09 | `10-PHASE-09-PLAN.md` | Final Synthesis | 1 | 1 |

## Critical Protocols

All protocols defined in `PROTOCOLS.md`:

1. **Output Protocol** - Sub-agent outputs to files, summaries to chat
2. **CRITIC Verification** - Mandatory notes section with thought count
3. **Temporal Verification** - Data access trace for 3 random bars
4. **Conflict Resolution** - Handle contradictory findings
5. **Checkpoint Summary** - Context preservation between phases
6. **MANIFEST.md** - Master index of all outputs

## Execution Order

```
Phase 00 (Foundation) ← BLOCKER - MUST PASS
    ↓
Phase 01 (Core Strategy)
    ↓
Phase 02 Round 1 (Indicators A,B) ← 2 parallel
    ↓ checkpoint
Phase 02 Round 2 (Indicators C,D) ← 2 parallel
    ↓
Phase 03 Round 1 (Risk A,B) ← 2 parallel
    ↓ checkpoint
Phase 03 Round 2 (Risk C)
    ↓
Phase 04 (Signals) + Phase 04.5 (ML) ← 2 parallel
    ↓
Phase 05 (Execution) ← 2 parallel
    ↓
Phase 06 Round 1 (Backtest A,B) ← 2 parallel
    ↓ checkpoint
Phase 06 Round 2 (Backtest C,D) ← 2 parallel
    ↓
Phase 07 (Test Coverage)
    ↓
Phase 08 (Integration) ← 2 parallel
    ↓
Phase 09 (Synthesis - DAEMON)
```

## Deliverables

### Per Phase
- `orchestration/PHASE_XX_FINDINGS.md` - Full analysis

### Final (Phase 09)
- `AUDIT_REPORT.md` - Master findings
- `ISSUES_TRACKER.md` - Bug/issue tracker
- `RECOMMENDATIONS.md` - Prioritized improvements
- GO/NO-GO decision

## Success Criteria

- [ ] Phase 00 passes (definitions match CLAUDE.md)
- [ ] All 11 phases completed
- [ ] All modules reviewed with CRITIC (verified via notes)
- [ ] Apex compliance verified (5 rules)
- [ ] No unaddressed CRITICAL issues
- [ ] GO/NO-GO decision documented
- [ ] Action plan created

## Files in this Plan

```
.planning/phases/08-nautilus-deep-audit/
├── 00-BRIEF.md                # High-level brief (updated v2.0)
├── 01-ROADMAP.md              # Phase overview (updated v2.0)
├── 01-PHASE-00-PLAN.md        # Foundation Verification (NEW)
├── 02-PHASE-01-PLAN.md        # Core Strategy
├── 03-PHASE-02-PLAN.md        # SMC Indicators
├── 04-PHASE-03-PLAN.md        # Risk Modules
├── 05-PHASE-04-PLAN.md        # Signal Generators
├── 05.5-PHASE-04.5-PLAN.md    # ML Pipeline (NEW)
├── 06-PHASE-05-PLAN.md        # Execution Layer
├── 07-PHASE-06-PLAN.md        # Backtest Scripts
├── 08-PHASE-07-PLAN.md        # Test Coverage (upgraded to opus)
├── 09-PHASE-08-PLAN.md        # Integration Points
├── 10-PHASE-09-PLAN.md        # Final Synthesis
├── PROTOCOLS.md               # All protocols (NEW)
├── MASTER-PLAN.md             # This file (updated v2.0)
└── orchestration/             # Output directory (NEW)
    └── MANIFEST.md            # Will be created during execution
```

## How to Execute

### Option 1: Phase by Phase (Recommended)
```
/run-plan .planning/phases/08-nautilus-deep-audit/01-PHASE-00-PLAN.md
```
Wait for completion, then:
```
/run-plan .planning/phases/08-nautilus-deep-audit/02-PHASE-01-PLAN.md
```
And so on.

### Option 2: Execute this Master Plan
```
/run-plan .planning/phases/08-nautilus-deep-audit/MASTER-PLAN.md
```
This will orchestrate all phases sequentially.

## CRITIC Review Status

| Item | Status |
|------|--------|
| Phase 00 added | ✅ |
| Scope expanded | ✅ |
| Parallel agents reduced | ✅ |
| Output protocol added | ✅ |
| CRITIC notes template | ✅ |
| Temporal verification method | ✅ |
| Phase 07 upgraded | ✅ |
| Conflict resolution | ✅ |

**All CRITIC recommendations addressed.**
