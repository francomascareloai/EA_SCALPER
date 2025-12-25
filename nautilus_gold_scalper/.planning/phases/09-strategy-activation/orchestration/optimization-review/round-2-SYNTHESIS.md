# Round 2 Synthesis - FORGE + CRITIC Findings

## Date: 2024-12-24
## Status: CONDITIONAL-GO - Fix C1 and H2 before production

---

## Combined Severity Assessment

| Source | Critical | High | Medium | Low |
|--------|----------|------|--------|-----|
| FORGE  | 0        | 2    | 6      | 1   |
| CRITIC | 1        | 3    | 6      | 2   |
| **Total Unique** | **1** | **4** | **8** | **2** |

---

## CRITICAL Issues (MUST FIX IMMEDIATELY)

### C1: 2-Point Equity Fallback Masks True DD (CRITIC)
**Location**: `scripts/optimize.py` lines 638-652
**Impact**: FALSE APEX COMPLIANT → Account termination in production
**Attack Path**:
1. `generate_account_report()` fails (transient error, wrong venue)
2. Fallback creates 2-point series: [initial, final]
3. Trailing DD computed as ~0% (no intermediate points)
4. ApexConstraintChecker passes
5. User deploys "compliant" strategy
6. True DD was 6%+ → ACCOUNT BLOWN

**Fix Required**: FAIL the trial on fallback, don't just warn:
```python
logger.error("CRITICAL: Cannot extract equity. Trial FAILED.")
return pd.Series(dtype=float, name="equity")  # Empty = trial fails
```

---

## HIGH Issues (FIX BEFORE PRODUCTION)

| # | Issue | Source | Location |
|---|-------|--------|----------|
| H2 | `--resume` flag is dead code | FORGE+CRITIC | lines 386-391 |
| H3 | KeyError if "total" column missing | CRITIC | line 611 |
| H5 | Parallel RNG not isolated | FORGE | lines 856-858 |
| NEW-5 | No per-trial timeout in grid/random | FORGE | config.py |
| H1 | Partial fill handling breaks FIFO | CRITIC | lines 517-558 |

---

## MEDIUM Issues (SHOULD FIX)

| # | Issue | Source | Effort |
|---|-------|--------|--------|
| MED-2 | CLI `or` pattern treats 0 as falsy | FORGE | 1h |
| MED-3 | Config cross-field validation missing | FORGE | 2h |
| MED-5 | Indicator warmup not handled | FORGE | 2h |
| NEW-1 | Overly broad `except Exception` | FORGE | 1h |
| NEW-4 | Empty DataFrame as error indicator | FORGE | 1h |
| NEW-7 | No checkpoint persistence | FORGE | 4h |
| M1 | Signal handler uses logging (deadlock risk) | CRITIC | 30m |
| M2 | Windows atomic write not truly atomic | CRITIC | 1h |

---

## Implementation Priority for Round 2 Fixes

### Phase 0: BLOCKING FIXES (Before Round 3)
1. **C1 Fix** - 2-point equity fallback must FAIL trial
2. **H2 Fix** - Remove dead `--resume` flag (or implement)
3. **Add PnL sanity check** - Compare computed vs engine PnL

### Phase 1: Critical Correctness (Day 1)
4. H5 - Parallel RNG isolation with SeedSequence
5. NEW-5 - Per-trial timeout wrapper

### Phase 2: Robustness (Day 2)
6. H1 - Partial fill handling with qty matching
7. H3 - Safe column access for "total"
8. MED-2 - CLI `is not None` checks

### Phase 3: Quality (Day 3)
9. MED-3 - Config cross-field validation
10. NEW-1 - Specific exception types
11. M1 - Remove logging from signal handler

---

## Verification Done by Round 2

| Round 1 Fix | Status | Verified By |
|-------------|--------|-------------|
| Trade PnL for LONG | ✅ CORRECT | CRITIC |
| Trade PnL for SHORT | ✅ CORRECT | CRITIC |
| Equity extraction (primary) | ✅ CORRECT | CRITIC |
| Equity extraction (fallback) | ❌ FLAWED | CRITIC (C1) |
| Signal handlers | ✅ MOSTLY CORRECT | CRITIC (minor M1) |
| Atomic writes | ✅ CORRECT (POSIX) | CRITIC |
| Global mutable state | ✅ FIXED | FORGE |

---

## Genius-Level Recommendations from Round 2

### G-1: Idempotent Trial Execution
- Each trial gets deterministic hash from (params, seed)
- Enables caching, dedup, and reproducibility

### G-2: Trial Result Versioning
- Schema version in results for forward compatibility
- Safe migration between optimization versions

### G-3: Distributed Execution Ready
- TrialExecutor protocol abstraction
- Swap LocalExecutor → DaskExecutor → RayExecutor via config

### G-4: Metric Store with Lineage
- Full audit trail with git hash, config hash, data hash
- Cross-run comparisons

---

## Fastest Disproof Test (30 min)

From CRITIC - prove C1 exists:
```python
def test_false_apex_compliance_via_2point_fallback():
    """Prove 2-point fallback masks DD violations."""
    # Mock runner with failing generate_account_report
    # Verify equity has only 2 points
    # Verify computed trailing_dd < 1% when true DD was 6%
    # This PASSES, proving the vulnerability exists
```

---

## Verdict: CONDITIONAL-GO

**GO after fixing:**
1. C1 - 2-point equity fallback (CRITICAL - account safety)
2. H2 - Dead --resume flag (HIGH - user confusion)

**Recommended before production:**
3. PnL sanity check (HIGH - metric accuracy)
4. Parallel RNG isolation (HIGH - reproducibility)
5. Per-trial timeout (HIGH - prevents hangs)

---

## Next Actions

1. [ ] **IMMEDIATE**: Fix C1 - change fallback to fail trial
2. [ ] **IMMEDIATE**: Fix H2 - remove --resume argument
3. [ ] Add PnL sanity check
4. [ ] Run Round 3 with C1+H2 fixes verified

---

*Synthesis generated from Round 2 FORGE + CRITIC outputs*
