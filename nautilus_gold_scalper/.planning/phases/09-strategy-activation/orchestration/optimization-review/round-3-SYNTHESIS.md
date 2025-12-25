# Round 3 Synthesis - FORGE + CRITIC Findings

## Date: 2024-12-24
## Status: **NO-GO** - Fix C1 gap and C2 before proceeding

---

## Combined Severity Assessment

| Source | Critical | High | Medium | Low |
|--------|----------|------|--------|-----|
| FORGE  | 0        | 2    | 3      | 5   |
| CRITIC | 2        | 2    | 4      | 1   |
| **Total Unique** | **2** | **3** | **4** | **3** |

---

## CRITICAL Issues (MUST FIX IMMEDIATELY)

### C1: Empty Equity Still Produces False Apex Compliance (CRITIC)
**Status**: Round 2 fix is INCOMPLETE
**Location**: `optimize.py` (fixed), but `optimizer.py` and `wfa_inline.py` don't validate

**The Gap**:
1. `_extract_equity_series` correctly returns empty Series on failure (line 646)
2. BUT: `optimizer.py` line 231 only checks `if trades_df.empty`, NOT equity_series
3. Empty Series is NOT None, so `if equity_series is not None` passes
4. `wfa_inline.py` line 398: `if len(equity_series) < 2: return 0.0`
5. **Result**: `trailing_dd = 0.0` → APEX COMPLIANT (FALSE POSITIVE!)

**Fix Required in optimizer.py**:
```python
# AFTER line 229 (after calling backtest_fn):
if equity_series is None or len(equity_series) < 2:
    logger.warning(f"Trial failed: insufficient equity data (len={len(equity_series) if equity_series is not None else 0})")
    return self._empty_result(params)
```

### C2: FIFO Matching Ignores Quantity Mismatch (FORGE + CRITIC)
**Location**: `optimize.py` lines 517-531
**Impact**: PnL can be 2x overstated for partial fills

**Problem**: Current code pops entire entry regardless of fill quantity:
```python
entry = long_positions[instrument_id].pop(0)  # Pops full qty=2 entry
pnl = (fill_price - entry["entry_price"]) * entry["quantity"]  # Uses full qty!
```

**Example**:
- SELL 2 lots @ 2000 (SHORT entry)
- BUY 1 lot @ 1990 (partial close)
- **Expected**: PnL = (2000-1990) * 1 = +$10
- **Actual**: PnL = (2000-1990) * 2 = +$20 (2x overstatement!)
- Remaining 1 lot is LOST

---

## HIGH Issues (FIX BEFORE PRODUCTION)

| # | Issue | Source | Location |
|---|-------|--------|----------|
| H1 | No per-trial timeout enforced | FORGE | grid.py, random.py |
| H2 | RNG state potentially shared in parallel | FORGE+CRITIC | optimize.py:848 |
| H3 | KeyError if "total" column missing | FORGE | optimize.py:610 |

---

## MEDIUM Issues (SHOULD FIX)

| # | Issue | Source | Effort |
|---|-------|--------|--------|
| M1 | Signal handler uses logging (deadlock) | FORGE | 15m |
| MED-2 | CLI `or` pattern treats 0 as falsy | FORGE | 15m |
| M3 | fills may not be chronologically ordered | CRITIC | 30m |
| NEW-1 | Config cross-field validation missing | FORGE | 2h |

---

## Verification of Round 2 Fixes

| Fix | Status | Verified By |
|-----|--------|-------------|
| C1 (2-point fallback removal) | ✅ CODE CORRECT | FORGE |
| C1 (downstream validation) | ❌ INCOMPLETE | CRITIC |
| H2 (--resume removed) | ✅ COMPLETE | FORGE + CRITIC |

---

## Implementation Priority for Round 3 Fixes

### Phase 0: BLOCKING (Before Round 4)
1. **C1 Gap Fix** - Add equity validation in optimizer.py line 231
2. **C2 Fix** - Proper FIFO matching with quantity residuals

### Phase 1: High Priority (Before Production)
3. H1 - Per-trial timeout wrapper
4. H3 - Safe "total" column access
5. M1 - Remove logging from signal handler

### Phase 2: Correctness (Day 2)
6. MED-2 - CLI `is not None` checks
7. M3 - Sort fills by ts_event before processing

---

## Fastest Disproof Tests (30 min each)

### Test 1: Empty Equity False Compliance (CRITIC)
```python
def test_empty_equity_false_compliance():
    """Prove empty equity produces trailing_dd=0.0"""
    equity_series = pd.Series(dtype=float, name='equity')
    wfa = InlineWFA(windows=3, is_ratio=0.25)
    result = wfa._compute_max_drawdown(equity_series)
    assert result > 0.0, f"VULNERABILITY: Empty equity returned DD={result}"
```

### Test 2: Partial Fill PnL Error (FORGE)
```python
def test_partial_fill_pnl():
    """Prove partial fills cause 33% PnL error"""
    # SHORT 2 lots @ 2000
    # BUY 1 lot @ 1990 (partial)
    # BUY 1 lot @ 1980 (remainder)
    # Expected: $30, Actual with bug: $20
```

---

## Verdict: NO-GO

**MUST FIX before proceeding:**
1. C1 gap - Empty equity validation in optimizer.py
2. C2 - Partial fill handling

**Recommended before Round 4:**
3. Per-trial timeout (H1)
4. Safe column access (H3)

---

## Next Actions

1. [x] Create round-3-SYNTHESIS.md
2. [ ] **IMMEDIATE**: Fix C1 gap in optimizer.py
3. [ ] **IMMEDIATE**: Fix C2 partial fills in optimize.py
4. [ ] Run Round 4 with C1+C2 fixes verified

---

*Synthesis generated from Round 3 FORGE + CRITIC outputs*
