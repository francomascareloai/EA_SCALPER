# PLAN: Phase 00 - Foundation Verification

## Objective
Establish a known baseline before audit begins. Verify foundational code matches documented requirements. Create audit checkpoint.

## Why This Phase is CRITICAL

The CRITIC identified that auditing without verifying the foundation is dangerous:
- If `definitions.py` has wrong thresholds, ALL subsequent analysis is invalid
- If tests are already failing, we don't know what's broken vs what we find
- If code changes during audit, findings become unreliable

## Execution Steps

### Step 1: Create Audit Baseline
```bash
# Create git tag for audit start
git tag -a audit-baseline-$(date +%Y%m%d) -m "Audit baseline before deep review"

# Capture current state
git status > .planning/phases/08-nautilus-deep-audit/orchestration/baseline_git_status.txt
git log --oneline -20 > .planning/phases/08-nautilus-deep-audit/orchestration/baseline_git_log.txt
```

### Step 2: Run Pytest Baseline
```bash
# Capture what's already broken
python3 -m pytest -q --tb=no 2>&1 | tee .planning/phases/08-nautilus-deep-audit/orchestration/baseline_pytest.txt
```

Document:
- Total tests
- Passing tests
- Failing tests (these are PRE-EXISTING, not audit findings)

### Step 3: Verify src/core/definitions.py Against CLAUDE.md

**MANDATORY CHECKS:**

| Constant | Expected Value (CLAUDE.md) | Actual | Match? |
|----------|---------------------------|--------|--------|
| `TIER_S_MIN` | ≥90 | ⬜ | ⬜ |
| `TIER_A_MIN` | ≥80 | ⬜ | ⬜ |
| `TIER_B_MIN` | ≥70 | ⬜ | ⬜ |
| `TIER_C_MIN` | ≥60 | ⬜ | ⬜ |
| `TIER_INVALID` | <60 | ⬜ | ⬜ |
| `DEFAULT_RISK_PER_TRADE` | 0.5% | ⬜ | ⬜ |
| `DEFAULT_MAX_DAILY_LOSS` | 5.0% | ⬜ | ⬜ |

**APEX RULE CONSTANTS:**
| Rule | Expected | Actual | Match? |
|------|----------|--------|--------|
| Trailing DD limit | 5.0% | ⬜ | ⬜ |
| Daily loss warn | 1.5% | ⬜ | ⬜ |
| Daily loss caution | 2.0% | ⬜ | ⬜ |
| Daily loss reduce | 2.5% | ⬜ | ⬜ |
| Daily loss HALT | 3.0% | ⬜ | ⬜ |
| Total DD warn | 3.0% | ⬜ | ⬜ |
| Total DD caution | 3.5% | ⬜ | ⬜ |
| Total DD reduce | 4.0% | ⬜ | ⬜ |
| Total DD HALT | 4.5% | ⬜ | ⬜ |
| Consistency cap | 30% | ⬜ | ⬜ |

### Step 4: Verify src/core/data_types.py

Check dataclass definitions:
- `ConfluenceResult`
- `RegimeAnalysis`
- `SessionInfo`
- `OrderBlock`
- `FairValueGap`

Are all required fields present? Types correct?

### Step 5: Count Lines for Scope Verification

```bash
# Verify scope estimate
find nautilus_gold_scalper/src -name "*.py" -exec wc -l {} \; | sort -rn | head -30
find scripts/backtest -name "*.py" -exec wc -l {} \; | sort -rn | head -30
```

Document actual line counts vs plan estimates.

### Step 6: Create orchestration/ Directory

```bash
mkdir -p .planning/phases/08-nautilus-deep-audit/orchestration
```

This is where all phase outputs will be stored to prevent context overflow.

## Files to Review

| File | Purpose | Check |
|------|---------|-------|
| `src/core/definitions.py` | Thresholds, constants | Match CLAUDE.md |
| `src/core/data_types.py` | Data structures | Complete definitions |
| `src/core/exceptions.py` | Custom exceptions | Proper hierarchy |

## Success Criteria

- [ ] Git tag created
- [ ] Pytest baseline captured
- [ ] All thresholds verified against CLAUDE.md
- [ ] Any mismatches documented as CRITICAL issues
- [ ] Line counts documented
- [ ] orchestration/ directory created
- [ ] `PHASE_00_FINDINGS.md` completed

## Agent

**1 opus agent** (15-20 minutes)
- Direct verification, no parallel needed
- CRITIC self-review for threshold verification

## Output

`orchestration/PHASE_00_FINDINGS.md` containing:
1. Baseline state
2. Pytest results
3. Threshold verification table
4. Scope line counts
5. Any CRITICAL mismatches found

## CRITICAL: If Any Mismatch Found

If `definitions.py` doesn't match CLAUDE.md:
1. Document as CRITICAL-P0 issue
2. DO NOT proceed with other phases
3. Fix definitions first
4. Re-run Phase 00
