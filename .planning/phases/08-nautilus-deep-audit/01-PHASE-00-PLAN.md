# PLAN: Phase 00 - Foundation Verification

> **Changelog:** 2025-12-16 - Applied CRITIC fixes (C-001 through C-010): reordered steps, fixed file paths, added mypy baseline, clarified expected values source, added Apex constant search step, added venv activation, specified source of truth.

## Objective
Establish a known baseline before audit begins. Verify foundational code matches documented requirements. Create audit checkpoint.

## Source of Truth
**Root CLAUDE.md** (`/home/franco/projetos/EA_SCALPER_XAUUSD/CLAUDE.md`) is the source of truth for Apex rules and compliance thresholds.

## Why This Phase is CRITICAL

The CRITIC identified that auditing without verifying the foundation is dangerous:
- If `definitions.py` has wrong thresholds, ALL subsequent analysis is invalid
- If tests are already failing, we don't know what's broken vs what we find
- If code changes during audit, findings become unreliable

## Execution Steps

### Step 1: Create orchestration/ Directory (~1 min)
```bash
# MUST be first - other steps write output here
mkdir -p .planning/phases/08-nautilus-deep-audit/orchestration
```

This is where all phase outputs will be stored to prevent context overflow.

### Step 2: Create Audit Baseline (~2 min)
```bash
source .venv/bin/activate

# Create git tag for audit start
git tag -a audit-baseline-$(date +%Y%m%d) -m "Audit baseline before deep review" 2>&1 | tee .planning/phases/08-nautilus-deep-audit/orchestration/git_tag_result.txt

# Capture current state
git status > .planning/phases/08-nautilus-deep-audit/orchestration/baseline_git_status.txt
git log --oneline -20 > .planning/phases/08-nautilus-deep-audit/orchestration/baseline_git_log.txt
```

### Step 3: Run Pytest and Mypy Baseline (~3 min)
```bash
source .venv/bin/activate

# Capture what's already broken
python3 -m pytest -q --tb=no 2>&1 | tee .planning/phases/08-nautilus-deep-audit/orchestration/baseline_pytest.txt

# Capture mypy baseline (CLAUDE.md validation_gate requires mypy --strict)
python3 -m mypy --strict nautilus_gold_scalper/ 2>&1 | tee .planning/phases/08-nautilus-deep-audit/orchestration/baseline_mypy.txt
```

Document:
- Total tests / Passing tests / Failing tests (pre-existing, not audit findings)
- Total mypy errors / warnings (pre-existing baseline)

### Step 4: Locate Apex Constants in Codebase (~2 min)

Before verifying Apex constants, find where they are actually defined:
```bash
source .venv/bin/activate

# Search for Apex-related constants
grep -rn "trailing\|apex\|hwm\|high.water" nautilus_gold_scalper/src/ 2>&1 | tee .planning/phases/08-nautilus-deep-audit/orchestration/apex_constants_search.txt

# Search for drawdown limits
grep -rn "DD_\|HALT\|WARN\|CAUTION" nautilus_gold_scalper/src/ 2>&1 | tee -a .planning/phases/08-nautilus-deep-audit/orchestration/apex_constants_search.txt

# Search for time gates
grep -rn "4:30\|4:55\|4:59\|16:30\|16:55\|16:59" nautilus_gold_scalper/src/ 2>&1 | tee -a .planning/phases/08-nautilus-deep-audit/orchestration/apex_constants_search.txt
```

Document which files contain Apex-related constants (may be in risk manager, sentinel, or separate apex module rather than definitions.py).

### Step 5: Verify nautilus_gold_scalper/src/core/definitions.py (~3 min)

**NOTE:** definitions.py contains internal code constants (tiers, defaults). Apex compliance rules are verified separately based on Step 4 findings.

**Code Constants (Internal Consistency):**

| Constant | Current Value | Notes |
|----------|--------------|-------|
| `TIER_S_MIN` | ⬜ | Internal tier threshold |
| `TIER_A_MIN` | ⬜ | Internal tier threshold |
| `TIER_B_MIN` | ⬜ | Internal tier threshold |
| `TIER_C_MIN` | ⬜ | Internal tier threshold |
| `TIER_INVALID` | ⬜ | Internal tier threshold |
| `DEFAULT_RISK_PER_TRADE` | ⬜ | Code default (may differ from Apex limits) |
| `DEFAULT_MAX_DAILY_LOSS` | ⬜ | Code default (may differ from Apex limits) |

Extract values programmatically:
```bash
source .venv/bin/activate
python3 -c "
from nautilus_gold_scalper.src.core.definitions import *
import inspect
members = [(name, getattr(__import__('nautilus_gold_scalper.src.core.definitions', fromlist=[name]), name))
           for name in dir() if name.isupper() and not name.startswith('_')]
for name, val in sorted(members):
    print(f'{name}={val}')
" 2>&1 | tee .planning/phases/08-nautilus-deep-audit/orchestration/definitions_values.txt
```

**Apex Compliance Rules (from CLAUDE.md - MANDATORY):**

| Rule | CLAUDE.md Value | Location Found (Step 4) | Actual | Match? |
|------|-----------------|------------------------|--------|--------|
| Trailing DD limit | 5.0% from HWM | ⬜ | ⬜ | ⬜ |
| Daily loss warn | 1.5% | ⬜ | ⬜ | ⬜ |
| Daily loss caution | 2.0% | ⬜ | ⬜ | ⬜ |
| Daily loss reduce | 2.5% | ⬜ | ⬜ | ⬜ |
| Daily loss HALT | 3.0% | ⬜ | ⬜ | ⬜ |
| Total DD warn | 3.0% | ⬜ | ⬜ | ⬜ |
| Total DD caution | 3.5% | ⬜ | ⬜ | ⬜ |
| Total DD reduce | 4.0% | ⬜ | ⬜ | ⬜ |
| Total DD HALT | 4.5% | ⬜ | ⬜ | ⬜ |
| Consistency cap | 30%/day max profit | ⬜ | ⬜ | ⬜ |
| Trade cutoff | 4:30 PM ET | ⬜ | ⬜ | ⬜ |
| Emergency close | 4:55 PM ET | ⬜ | ⬜ | ⬜ |
| Flat deadline | 4:59 PM ET | ⬜ | ⬜ | ⬜ |

**NOTE:** If Step 4 shows Apex constants are NOT yet implemented, document as "NOT IMPLEMENTED" rather than "MISMATCH". Implementation gaps are different from mismatches.

### Step 6: Verify nautilus_gold_scalper/src/core/data_types.py (~2 min)

Check dataclass definitions:
- `ConfluenceResult`
- `RegimeAnalysis`
- `SessionInfo`
- `OrderBlock`
- `FairValueGap`

Are all required fields present? Types correct?

### Step 7: Verify nautilus_gold_scalper/src/core/exceptions.py (~1 min)

Check custom exception hierarchy is properly defined.

### Step 8: Count Lines for Scope Verification (~2 min)

```bash
# Verify scope estimate
find nautilus_gold_scalper/src -name "*.py" -exec wc -l {} \; | sort -rn | head -30
find scripts/backtest -name "*.py" -exec wc -l {} \; | sort -rn | head -30
```

Document actual line counts vs plan estimates.

## Files to Review

| File | Purpose | Check |
|------|---------|-------|
| `nautilus_gold_scalper/src/core/definitions.py` | Thresholds, constants | Document values |
| `nautilus_gold_scalper/src/core/data_types.py` | Data structures | Complete definitions |
| `nautilus_gold_scalper/src/core/exceptions.py` | Custom exceptions | Proper hierarchy |
| Files from Step 4 search | Apex constants | Match CLAUDE.md |

## Success Criteria

- [ ] orchestration/ directory created (Step 1)
- [ ] Git tag created
- [ ] Pytest baseline captured
- [ ] Mypy baseline captured
- [ ] Apex constant locations identified
- [ ] All Apex thresholds verified against CLAUDE.md OR documented as NOT IMPLEMENTED
- [ ] Any mismatches documented as CRITICAL issues
- [ ] Line counts documented
- [ ] `PHASE_00_FINDINGS.md` completed

## Agent

**1 opus agent** (~15-20 minutes total)
- Step 1: 1 min
- Step 2: 2 min
- Step 3: 3 min
- Step 4: 2 min
- Step 5: 3 min
- Step 6: 2 min
- Step 7: 1 min
- Step 8: 2 min
- Findings doc: 4 min

Direct verification, no parallel needed. CRITIC self-review for threshold verification.

## Output

`orchestration/PHASE_00_FINDINGS.md` containing:
1. Baseline state (git tag, status)
2. Pytest results (pass/fail counts)
3. Mypy results (error counts)
4. Apex constant locations (from grep)
5. Threshold verification tables
6. Scope line counts
7. Any CRITICAL mismatches or implementation gaps found

## CRITICAL: If Any Mismatch Found

If Apex constants don't match CLAUDE.md:
1. Document as CRITICAL-P0 issue
2. DO NOT proceed with other phases
3. Fix constants first
4. Re-run Phase 00

If Apex constants are NOT IMPLEMENTED:
1. Document as HIGH-P1 implementation gap
2. Proceed with audit (this is a finding, not a blocker)
3. Add to audit scope: "Apex implementation status"

## Rollback Procedure

If Phase 00 fails:
1. Delete git tag: `git tag -d audit-baseline-YYYYMMDD`
2. Fix identified issues
3. Re-run Phase 00 from Step 1

---

## CRITIC RE-REVIEW (2025-12-16)

### Previous Issues Status

| ID | Issue | Status |
|----|-------|--------|
| C-001 | Step ordering - mkdir must be first | FIXED |
| C-002 | File paths inconsistent | FIXED |
| C-003 | Missing mypy baseline | FIXED |
| C-004 | Expected values source unclear | FIXED |
| C-005 | No Apex constant search before verification | FIXED |
| C-006 | Missing venv activation in bash steps | FIXED |
| C-007 | Source of truth not specified | FIXED |
| C-008 | Table completeness (all DD levels) | FIXED |
| C-009 | Missing NOT IMPLEMENTED handling | FIXED |
| C-010 | Rollback procedure incomplete | FIXED |

### New Issues Found

None. Plan is well-structured with:
- Complete Apex coverage (all DD levels, time gates, consistency rule)
- Proper grep patterns for constant discovery
- Clear success criteria
- Rollback procedure for failures

### Verdict

**APPROVED** - Ready for execution.
