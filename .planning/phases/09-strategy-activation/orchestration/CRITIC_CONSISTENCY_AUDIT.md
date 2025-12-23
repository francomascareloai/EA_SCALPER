# CRITIC CONSISTENCY AUDIT - Phase 09 Documentation

## Metadata

| Field | Value |
|-------|-------|
| Reviewer | CRITIC v1.2 |
| Date | 2025-12-23 |
| Mode | EXTERNAL-CRITIC |
| Sequential Thinking | 15 thoughts applied |
| CLAUDE_MD_VERSION | 3.10.21 |

---

## VERDICT: BLOCKED

**Fundamental inconsistencies prevent coherent execution. User must choose between v1 and v2 approaches, then cleanup contradicting documents.**

---

## Executive Summary

The Phase 09 documentation contains **two fundamentally incompatible approaches**:

| Approach | Philosophy | Factors | Router | Phases | Timeline |
|----------|-----------|---------|--------|--------|----------|
| **v1 (Original)** | Activate ALL strategies for robustness | 9 factors | Enable AdaptiveEVRouter | 7 phases (00-06) | 6-8 weeks |
| **v2 (Revised)** | Simplify ONE strategy first | 3-4 factors | Archive AdaptiveEVRouter | 9 phases (-1 to 08) | 10-12 weeks |

**Problem**: Detailed phase plans (02-PHASE-01-PLAN.md through 07-PHASE-06-PLAN.md) follow v1 approach, but v2 brief is marked "READY FOR EXECUTION". No coherent execution path exists.

---

## CRITICAL ISSUES (7)

### CRITICAL-001: Phase Count Contradiction

**Documents in conflict:**
- `01-ROADMAP.md` (v1.3): 7 phases (00-06), 6-8 weeks
- `01-ROADMAP-v2.md`: 9 phases (-1 to 08), 10-12 weeks
- `00-BRIEF-v2.md`: 4 phases (00-04), 8-10 weeks

**Impact**: Which phase structure to follow? Different phase numbers mean different deliverables.

**Fix**: Delete or archive all v1 roadmap/phase files if v2 is chosen.

---

### CRITICAL-002: Factor Count Contradiction

**Documents in conflict:**
- `00-BRIEF.md` (v1): Validate 9 SMC indicators
- `00-BRIEF-v2.md`: Reduce to 3-4 factors (Structure, OB, FVG, Session)
- `08-SIMPLIFICATION_PLAN.md`: Reduce to 4 factors, archive 5 others
- Phase plans: Reference validating all 9 factors

**Impact**: Code changes depend on this decision. Cannot proceed without clarity.

**Fix**:
- If v2 chosen: Archive Phase Plans 02-07 (they reference 9 factors)
- Update `02-CRITICAL_ISSUES_AUDIT.md` Category 7 (ablation study) to reflect 4 factors

---

### CRITICAL-003: MeanRevert Strategy Decision Already Made (Orphaned Phase)

**Documents in conflict:**
- `05-PHASE-04-PLAN.md`: Entire phase for "Mean Revert Research" with 3 options (IMPLEMENT/REMOVE/DEFER)
- `00-BRIEF-v2.md`: Already decided REMOVE ("gold trends, doesn't mean-revert")
- `01-ROADMAP-v2.md`: "Removed Phase 04 (Mean Revert) per ARGUS research"

**Impact**: Phase 04 plan is **ORPHANED**. Following it contradicts v2 decision.

**Fix**: Archive `05-PHASE-04-PLAN.md` or delete it entirely.

---

### CRITICAL-004: AdaptiveEVRouter Decision Contradiction

**Documents in conflict:**
- `06-PHASE-05-PLAN.md` Task 05-03: "Enable Router by Default" (`router_adaptive_ev=True`)
- `07-PHASE-06-PLAN.md` Config E: Tests with Router active
- `00-BRIEF-v2.md`: "Archive AdaptiveEVRouter" (Thompson sampling invalid)
- `01-ROADMAP-v2.md`: "ARCHIVED AdaptiveEVRouter per ARGUS"
- `08-SIMPLIFICATION_PLAN.md`: "Set `router_adaptive_ev = False`, Archive `adaptive_router.py`"

**Impact**: Phase 05-06 plans are **INVALID** if v2 is followed.

**Fix**: Archive `06-PHASE-05-PLAN.md` and `07-PHASE-06-PLAN.md`.

---

### CRITICAL-005: StrategySelector Gate Count Contradiction

**Documents in conflict:**
- `06-PHASE-05-PLAN.md` Task 05-01: Validates all 6 gates (Safety, FTMO, News, Session, Holiday, Regime)
- `00-BRIEF-v2.md`: "Reduce 6 gates to 2: regime filter + session gate"
- `03-PRE_ACTIVATION_CHECKLIST-v2.md` ARCH-002: "Simplify StrategySelector to regime filter only"

**Impact**: Phase 05 plan tests 6 gates that v2 says should not exist.

**Fix**: If v2 chosen, Phase 05 plan is invalid.

---

### CRITICAL-006: Success Metrics Mismatch

**Documents in conflict:**
- Phase plans (02-07): Use WFE, SQN, PSR, MC95DD only
- `00-BRIEF-v2.md`: Adds **DSR >= 0.80** and **PBO < 25%** as mandatory
- `01-ROADMAP-v2.md`: Adds holdout validation (2020-2025) as mandatory

**Impact**: Phase plans do not include mandatory v2 metrics.

**Fix**: If following v2, phase plan GO/NO-GO criteria are incomplete.

---

### CRITICAL-007: No Coherent Execution Plan Exists

**Problem**:
- Phase Plans (02-PHASE-01-PLAN through 07-PHASE-06-PLAN) follow v1 approach
- v2 Brief is marked "READY FOR EXECUTION"
- 03-PRE_ACTIVATION_CHECKLIST-v2.md follows v2
- But there are NO detailed phase plans for v2 approach

**Impact**: Cannot execute Phase 02-06 using either set of documents coherently.

**Fix**:
- OPTION A: Create new phase plans aligned with v2 (Phases 02, 03, 05, 06, 07, 08 per v2 structure)
- OPTION B: Revert to v1 approach and archive v2 documents
- Must choose one path

---

## HIGH ISSUES (4)

### HIGH-001: Orphaned Phase Plan Files

If v2 approach is chosen, these files are **OBSOLETE**:

| File | Reason |
|------|--------|
| `02-PHASE-01-PLAN.md` | v2 merges Phase 01 into Phase 02 |
| `03-PHASE-02-PLAN.md` | References 9 factors, not 4 |
| `04-PHASE-03-PLAN.md` | References enabling TrendFollow before validating SMC beats baseline |
| `05-PHASE-04-PLAN.md` | Mean Revert - v2 already decided REMOVE |
| `06-PHASE-05-PLAN.md` | Router enabling - v2 says archive router |
| `07-PHASE-06-PLAN.md` | Multi-strategy with router - v2 says single strategy first |

**Fix**: Archive all 6 files to `_archive/planning/v1-phase-plans/`

---

### HIGH-002: Duplicate Content (DRY Violation)

The same content appears in multiple places:

| Content | Appears In |
|---------|------------|
| Empirical Observations (7 trades, Score=0.0, 1/9 factors) | 00-BRIEF.md, 01-ROADMAP.md, 02-CRITICAL_ISSUES_AUDIT.md |
| User Decisions Required (4 decisions) | 01-ROADMAP.md, 03-PRE_ACTIVATION_CHECKLIST.md, 02-CRITICAL_ISSUES_AUDIT.md |
| Phase 00 Task List | 01-ROADMAP.md, 03-PRE_ACTIVATION_CHECKLIST.md |
| Agent Review Summary | 01-ROADMAP.md, 03-PRE_ACTIVATION_CHECKLIST-v2.md, 01-ROADMAP-v2.md |

**Impact**: Maintenance burden. If one is updated, others become inconsistent.

**Fix**:
- Keep canonical content in ONE place
- Other docs reference via link: "See [03-PRE_ACTIVATION_CHECKLIST-v2.md] for task list"

---

### HIGH-003: Missing Cross-References

**Problems:**
- `00-BRIEF.md` (v1) has no "SUPERSEDED BY" notice pointing to v2
- `01-ROADMAP.md` (v1.3) references `03-PRE_ACTIVATION_CHECKLIST.md` (v1), not v2
- Phase plans don't reference v2 documents at all
- `08-SIMPLIFICATION_PLAN.md` is not referenced by any roadmap

**Fix**: Add clear supersession notices and update all cross-references.

---

### HIGH-004: Timeline Contradiction

| Document | Phase 00 Duration | Total Timeline |
|----------|-------------------|----------------|
| `01-ROADMAP.md` | 2 weeks | 6-8 weeks |
| `03-PRE_ACTIVATION_CHECKLIST.md` | 2 weeks, 40-50 hours | - |
| `03-PRE_ACTIVATION_CHECKLIST-v2.md` | 3 weeks + 2 weeks paper = 5 weeks | ~100 hours |
| `00-BRIEF-v2.md` | 3 weeks | 8-10 weeks |
| `01-ROADMAP-v2.md` | 3 weeks | 10-12 weeks |

**Impact**: Resource planning is impossible with conflicting timelines.

**Fix**: Settle on v2 timeline (10-12 weeks) and archive v1 estimates.

---

## MEDIUM ISSUES (2)

### MEDIUM-001: Terminology Inconsistencies

| Term | Variant 1 | Variant 2 | Variant 3 |
|------|-----------|-----------|-----------|
| Phase 00 name | "Pre-Activation Sprint" | "Phase 00" | "Simplification Sprint" |
| Strategy enum | "SMC_SCALPER" | "STRATEGY_SMC_SCALPER" | - |
| Order Block | "Order Blocks" | "OB" | "OBs" |
| Multi-timeframe | "MTF" | "MTF Alignment" | "Multi-Timeframe" |

**Fix**: Standardize terminology. Suggest: "Phase 00", "SMC_SCALPER", "OB", "MTF".

---

### MEDIUM-002: File Numbering Confusion

The file numbering scheme is overloaded:
- `02-CRITICAL_ISSUES_AUDIT.md` - Document type numbered as 02
- `02-PHASE-01-PLAN.md` - Phase 01 plan numbered as 02

Both start with "02-" but serve completely different purposes.

**Fix**: Use clearer naming convention:
- `DOC-02-CRITICAL_ISSUES_AUDIT.md` for document types
- `PHASE-01-PLAN.md` for phase plans
- Or move phase plans to subdirectory: `phases/01-cleanup/PLAN.md`

---

## ORPHANED REFERENCES

| Reference | Found In | Status |
|-----------|----------|--------|
| `orchestration/TRENDFOLLOW_BACKTEST_RESULTS.md` | Phase 03 plan | Does not exist |
| `orchestration/MEAN_REVERT_RESEARCH.md` | Phase 04 plan | Does not exist, phase orphaned |
| `orchestration/INTEGRATION_TEST_RESULTS.md` | Phase 05 plan | Does not exist |
| `orchestration/DAEMON_STRATEGIC_REVIEW.md` | Phase 06 plan | Does not exist |
| `03-PRE_ACTIVATION_CHECKLIST.md` | Referenced by 01-ROADMAP.md | Superseded by v2 |
| `08-SIMPLIFICATION_PLAN.md` | Not referenced | Orphaned document |

---

## OUTDATED CONTENT

These documents contain content contradicted by v2:

| Document | Outdated Content |
|----------|-----------------|
| `00-BRIEF.md` | "Activate ALL strategies" (v2 says simplify first) |
| `00-BRIEF.md` | Status: "DRAFT" (should say "SUPERSEDED") |
| `03-PRE_ACTIVATION_CHECKLIST.md` | 46 tasks, 2 weeks (v2 has 52 tasks, 3 weeks + paper) |
| `04-EXECUTIVE_SUMMARY.md` | "6 phases", "2-week sprint" (v2 has 9 phases, 3 weeks) |
| `02-CRITICAL_ISSUES_AUDIT.md` | Category 7 ablation for 9 factors (v2 says 4 factors) |

---

## DEFINITIVE ACTION LIST

### STEP 1: User Decision Required

**QUESTION**: Which approach do you want to follow?

- [ ] **OPTION A: v2 Simplification-First** (RECOMMENDED by all agent reviews)
  - Simplify to 4 factors
  - Archive AdaptiveEVRouter
  - Archive Mean Revert
  - 10-12 weeks timeline
  - Includes mandatory paper trading

- [ ] **OPTION B: v1 Multi-Strategy Activation** (Original plan)
  - Keep 9 factors
  - Enable AdaptiveEVRouter
  - Decide on Mean Revert
  - 6-8 weeks timeline
  - No mandatory paper trading

**BLOCKING**: Cannot proceed until decision is made.

---

### STEP 2: If v2 Chosen (Recommended)

#### Archive these files:
```
mv 00-BRIEF.md _archive/planning/v1/
mv 01-ROADMAP.md _archive/planning/v1/
mv 03-PRE_ACTIVATION_CHECKLIST.md _archive/planning/v1/
mv 04-EXECUTIVE_SUMMARY.md _archive/planning/v1/  # Update first with supersession notice
mv 02-PHASE-01-PLAN.md _archive/planning/v1-phase-plans/
mv 03-PHASE-02-PLAN.md _archive/planning/v1-phase-plans/
mv 04-PHASE-03-PLAN.md _archive/planning/v1-phase-plans/
mv 05-PHASE-04-PLAN.md _archive/planning/v1-phase-plans/
mv 06-PHASE-05-PLAN.md _archive/planning/v1-phase-plans/
mv 07-PHASE-06-PLAN.md _archive/planning/v1-phase-plans/
```

#### Rename v2 files to remove version suffix:
```
mv 00-BRIEF-v2.md 00-BRIEF.md
mv 01-ROADMAP-v2.md 01-ROADMAP.md
mv 03-PRE_ACTIVATION_CHECKLIST-v2.md 03-PRE_ACTIVATION_CHECKLIST.md
```

#### Update remaining files:
- `02-CRITICAL_ISSUES_AUDIT.md`: Update Category 7 to reflect 4-factor ablation
- `08-SIMPLIFICATION_PLAN.md`: Rename to proper position in sequence or integrate into checklist

#### Create missing phase plans (or use checklist as execution guide):
- Phase -1 Plan (Baseline Validation)
- Phase 02 Plan (SMC Audit - simplified)
- Phase 03 Plan (TrendFollow)
- Phase 05 Plan (Simplified Framework)
- Phase 06 Plan (Enhanced Validation)
- Phase 07 Plan (Paper Trading)
- Phase 08 Plan (Production Readiness)

---

### STEP 3: If v1 Chosen

#### Archive these files:
```
mv 00-BRIEF-v2.md _archive/planning/v2/
mv 01-ROADMAP-v2.md _archive/planning/v2/
mv 03-PRE_ACTIVATION_CHECKLIST-v2.md _archive/planning/v2/
mv 08-SIMPLIFICATION_PLAN.md _archive/planning/v2/
```

#### Update v1 files:
- Add DSR, PBO metrics to GO/NO-GO criteria (per ORACLE feedback)
- Add paper trading phase (per CLAUDE.md requirement)
- Fix file paths (per FORGE feedback)

---

### STEP 4: After Cleanup

1. **Create PLANNING_INDEX.md** listing all current planning documents
2. **Remove duplicate content** - keep canonical version, link to it
3. **Standardize terminology** across all documents
4. **Verify all cross-references** point to current files

---

## SUMMARY

| Category | Count |
|----------|-------|
| CRITICAL Issues | 7 |
| HIGH Issues | 4 |
| MEDIUM Issues | 2 |
| Orphaned References | 6 |
| Outdated Documents | 5 |
| Files to Archive (if v2) | 10 |
| Files to Rename (if v2) | 3 |

**VERDICT**: BLOCKED until user chooses v1 or v2 approach.

**RECOMMENDATION**: Follow v2 (simplification-first) as it incorporates all 7 agent reviews and addresses empirical evidence that 8/9 factors are dead.

---

## MANUAL VERIFICATION NEEDED

- [ ] User confirms v1 or v2 choice
- [ ] User approves file archival plan
- [ ] User confirms 10-12 week timeline acceptable (if v2)
- [ ] User confirms Decision 1 (OB/FVG timeframe) before Phase 00 can start

---

## CONFIDENCE: HIGH

**Reason**: All 10+ documents were read and compared systematically. Contradictions are objective and verifiable by comparing document text.

---

## PRE-MORTEM SUMMARY

**Most likely failure mode**: User attempts to execute using mix of v1 and v2 documents, leading to confusion and wasted effort.

**Second most likely**: Documents are not cleaned up, future agents reference wrong versions.

**Mitigation**: Execute cleanup BEFORE starting Phase 00. Do not proceed until single coherent document set exists.

---

*CRITIC v1.2 - Adversarial Quality Guardian*
*"Every inconsistency found now is a confusion prevented later."*
