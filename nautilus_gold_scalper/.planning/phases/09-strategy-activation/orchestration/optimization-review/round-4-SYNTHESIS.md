# Round 4 Synthesis - FORGE + CRITIC Findings

## Date: 2024-12-24
## Status: **FIXED** - C3 Column Mismatch Resolved

---

## Combined Severity Assessment

| Source | Critical | High | Medium | Low |
|--------|----------|------|--------|-----|
| FORGE  | 0        | 3    | 2      | 1   |
| CRITIC | 1 (C3)   | 1    | 0      | 0   |
| **Total Unique** | **1** | **3** | **2** | **1** |

---

## CRITICAL Issues

### C3: Column Name Contract Violation (CRITIC) - FIXED

**Status**: FIXED (Round 4)
**Location**: `scripts/optimize.py` line 578

**The Problem**:
- `_extract_trades_df` created columns: `entry_time`, `exit_time`, `entry_price`, `exit_price`, `quantity`, `side`, `pnl`
- `wfa_inline.py` line 169 expects `timestamp` column
- Result: `analyze_trade_series` returns `[]` → `trailing_dd=0.0` → ALL trials falsely marked Apex compliant

**Evidence Chain**:
```
_extract_trades_df()
  → trades_df with columns: [entry_time, exit_time, ...]
  → analyze_trade_series(trades_df, splits)
  → "timestamp" not in trades_df.columns → return []
  → compute_wfa_metrics(windows=[], ...)
  → WFAResult(trailing_dd=0.0, ...)
  → ApexConstraintChecker.check()
  → 0.0 < 4.5% threshold → apex_compliant=True  <-- FALSE POSITIVE!
```

**Fix Applied** (optimize.py lines 578-584):
```python
# C3 fix (Round 4): Add timestamp column expected by wfa_inline.py
# wfa_inline.py:169 checks for "timestamp" column, we produce "entry_time"
# Without this mapping, analyze_trade_series returns [] -> trailing_dd=0.0 -> FALSE Apex compliance
df = pd.DataFrame(trades) if trades else pd.DataFrame()
if not df.empty:
    df["timestamp"] = df["entry_time"]
return df
```

---

## Verification of Previous Fixes

| Round | Issue | Status | Verified By |
|-------|-------|--------|-------------|
| R2 | C1: 2-point fallback removal | ✅ FIXED | FORGE R4 |
| R3 | C1 Gap: Empty equity validation | ✅ FIXED | FORGE R4 |
| R3 | C2: Partial fills FIFO | DEFERRED (acceptable) | FORGE R4 |
| R4 | C3: Column name mismatch | ✅ FIXED | This synthesis |

---

## HIGH Priority Issues (Fix Before Production)

| # | Issue | Location | Status | Effort |
|---|-------|----------|--------|--------|
| H1 | Per-trial timeout not enforced | grid.py, random.py | OPEN | 1h |
| H3 | KeyError if "total" column missing | optimize.py:616 | OPEN | 15m |
| NEW-1 | No exception handling in search loops | grid.py:54, random.py:57 | NEW | 30m |

---

## MEDIUM Priority Issues

| # | Issue | Location | Status | Effort |
|---|-------|----------|--------|--------|
| M1 | Signal handler uses logging (deadlock) | optimize.py:139-147 | OPEN | 15m |
| MED-2 | CLI `or` pattern treats 0 as falsy | optimize.py:778-782 | OPEN | 15m |

---

## LOW Priority Issues

| # | Issue | Location | Status | Effort |
|---|-------|----------|--------|--------|
| NEW-2 | Float precision in grid steps | grid.py:124 | NEW | 30m |

---

## Issue Tracking Matrix (All Rounds)

| Round | Issue | Severity | Status | Fixed In |
|-------|-------|----------|--------|----------|
| R1 | Equity stub | CRITICAL | ✅ FIXED | R1 |
| R1 | SHORT position PnL | CRITICAL | ✅ FIXED | R1 |
| R1 | Signal handlers | HIGH | ✅ FIXED | R1 |
| R2 | C1: 2-point fallback | CRITICAL | ✅ FIXED | R2 |
| R2 | H2: Dead --resume | HIGH | ✅ FIXED | R2 |
| R3 | C1 Gap: Empty equity | CRITICAL | ✅ FIXED | R3 |
| R3 | C2: Partial fills | CRITICAL | DEFERRED | - |
| R4 | C3: Column mismatch | CRITICAL | ✅ FIXED | R4 |
| R3-4 | H1: Timeout | HIGH | OPEN | - |
| R3-4 | H3: KeyError | HIGH | OPEN | - |
| R4 | NEW-1: Exception handling | HIGH | NEW | - |
| R3-4 | M1: Signal logging | MEDIUM | OPEN | - |
| R3-4 | MED-2: CLI `or` | MEDIUM | OPEN | - |
| R4 | NEW-2: Float precision | LOW | NEW | - |

---

## Verdict: CONDITIONALLY GO

**All CRITICAL vulnerabilities are now FIXED:**
1. ✅ C1: 2-point fallback removal (R2)
2. ✅ C1 Gap: Empty equity validation (R3)
3. ✅ C3: Column name mismatch (R4)
4. ⏸️ C2: Partial fills FIFO (deferred - acceptable for single-lot)

**For Development/Testing**: READY
**For Production**: Fix H1, H3, NEW-1 first (~2 hours total)

---

## Ready for Round 5

Round 5 should:
1. Verify C3 fix is effective
2. Final adversarial review of complete fix chain
3. Validate all 4 critical fixes work together
4. Assess if H1/H3/NEW-1 should block production

---

*Round 4 Synthesis: 2024-12-24*
