# PHASE 02 Round 0: MTF Manager Temporal Integrity Analysis

**AGENT:** FORGE-NAUTILUS
**VERSION:** 1.1
**CLAUDE_MD_VERSION:** 3.10.14
**DATE:** 2025-12-17
**STATUS:** COMPLETE

---

## Executive Summary

**FILE UNDER REVIEW:** `nautilus_gold_scalper/src/indicators/mtf_manager.py` (~672 lines)

**VERDICT: CLEAN FOR ROUND 1**

No CRITICAL or HIGH temporal integrity issues found. The MTFManager is a passive indicator class that does NOT introduce look-ahead bias. However, 2 MEDIUM and 3 LOW design issues were identified that shift risk to callers.

---

## Severity Counts

| Severity | Count |
|----------|-------|
| CRITICAL | 0 |
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 3 |

---

## ARGUS Dangerous Pattern Grep Results

### Pattern 1: Forward-looking shift (`.shift(-N)`)
```bash
rg "\.shift\s*\(\s*-\d" --type py nautilus_gold_scalper/src/indicators/mtf_manager.py
```
**Result:** No matches. CLEAN.

### Pattern 2: Forward-looking rolling
```bash
rg "rolling.*\.shift\s*\(\s*-" --type py nautilus_gold_scalper/src/indicators/mtf_manager.py
```
**Result:** No matches. CLEAN.

### Pattern 3: Full-sample statistics
```bash
rg "np\.mean|np\.max|np\.min" --type py nautilus_gold_scalper/src/indicators/mtf_manager.py
```
**Result:** 5 matches found (lines 408, 409, 426, 529, 530)

**Analysis:**
- Lines 408-409: `np.mean(gains)` and `np.mean(losses)` in RSI calculation - operates on sliced array `prices[-period - 1:]`. CLEAN.
- Line 426: `np.mean(ranges)` in ATR calculation - operates on sliced array. CLEAN.
- Lines 529-530: `np.max(recent_prices)` and `np.min(recent_prices)` for swing points - operates on sliced array `prices[-lookback:]`. CLEAN.

All statistical operations use historical slices, NOT full sample. No look-ahead.

### Pattern 4: Nautilus timestamp configuration
```bash
rg "timestamp_on_close|ts_init_delta|bar_execution" --type py nautilus_gold_scalper/src/indicators/mtf_manager.py
```
**Result:** No matches. NOT APPLICABLE - This is a pure computation class, not a NautilusTrader Actor.

---

## Temporal Verification Protocol Results

### Step 1: Data Access Points Identified

| Location | Code | Description |
|----------|------|-------------|
| Line 215 | `prices[-1]` | Current price in analyze_timeframe() |
| Line 389 | `prices[-1]` | EMA fallback for insufficient data |
| Line 404 | `prices[-period - 1:]` | RSI deltas calculation |
| Line 425 | `prices[-period - 1:]` | ATR ranges calculation |
| Line 506 | `prices[-1] - prices[-period - 1]` | Momentum calculation |
| Lines 528-530 | `prices[-lookback:]` | Swing point detection |
| Lines 391-396 | `prices[0]`, `prices[1:]` | EMA iteration |

**Total Access Points:** 7 identified

### Step 2: Access Verification

| Access Pattern | Valid? | Explanation |
|----------------|--------|-------------|
| `prices[-1]` | CONDITIONAL | Valid ONLY if caller passes completed bars |
| `prices[-period - 1:]` | YES | Historical slice, always completed |
| `prices[-lookback:]` | YES | Historical slice, always completed |
| Full array iteration (EMA) | CONDITIONAL | Valid ONLY if array excludes forming bar |

### Step 3: Timestamp Trace Analysis

**Scenario 1: 2024-01-15 10:45:00 UTC (M15 bar just completed)**
- M1 bars: 45 completed M1 bars available (10:00-10:44)
- M5 bars: 9 completed M5 bars available (10:00-10:40)
- M15 bars: 3 completed M15 bars available (10:00, 10:15, 10:30)
- H1 bar: 10:00-11:00 is FORMING (incomplete)

**RISK:** If caller passes forming H1 bar, `prices[-1]` would access incomplete data.
MTFManager has NO guard against this.

**Scenario 2: 2024-01-15 11:01:00 UTC (H1 bar just completed)**
- All timeframe data would be valid
- This is the CORRECT state to call `get_mtf_bias()`

**Scenario 3: 2024-01-15 11:05:30 UTC (M5 just completed)**
- M1: Up to 11:04 completed
- M5: 11:00-11:05 just completed
- M15: 11:00-11:15 FORMING
- H1: 11:00-12:00 FORMING

**CONCLUSION:** The MTFManager has NO internal protection against forming bar access. Temporal integrity depends ENTIRELY on the caller.

---

## Detailed Findings

### [M-001] NO HTF BAR COMPLETION VERIFICATION
**Severity:** MEDIUM
**Location:** mtf_manager.py (entire class design)

**Description:**
The MTFManager class trusts callers to pass only completed bars. There is no internal guard to detect or reject forming bar data.

**Code Evidence:**
```python
def get_mtf_bias(
    self,
    h1_prices: NDArray[np.floating[Any]],  # No timestamp parameter
    m15_prices: NDArray[np.floating[Any]],
    m5_prices: NDArray[np.floating[Any]],
    m1_prices: NDArray[np.floating[Any]],
) -> dict[str, MTFTrend]:
```

**Risk:**
- Caller error could pass forming bars, causing look-ahead in downstream signals
- H1 bar takes 60 minutes to complete; during that time, LTF trades based on incomplete H1 analysis

**Mitigation Options:**
1. Add optional `bar_close_timestamp` parameter to `analyze_timeframe()`
2. Document requirement explicitly in docstring (currently implicit)
3. Add validation in Strategy layer (caller responsibility)

**Recommended Action:** Document requirement; add optional timestamp parameter for explicit verification.

---

### [M-002] PERFORMANCE BORDERLINE
**Severity:** MEDIUM
**Location:** Lines 391-397 (`_calculate_ema`)

**Description:**
EMA calculation uses O(n) Python loop over all prices. With 4 timeframes and 2 EMAs each (8 calls), total complexity is O(8n). With 1000 bars, this may exceed the 0.5ms threshold.

**Code Evidence:**
```python
def _calculate_ema(self, prices: NDArray[np.floating[Any]], period: int) -> float:
    alpha = 2.0 / (period + 1)
    ema = float(prices[0])
    for price in prices[1:]:  # O(n) loop
        ema = alpha * price + (1 - alpha) * ema
    return float(ema)
```

**Risk:**
- Potential latency spike on hot path
- May contribute to exceeding OnTick < 50ms budget when combined with other indicators

**Mitigation Options:**
1. Vectorize EMA with NumPy (use `scipy.ndimage.uniform_filter1d` or custom vectorized)
2. Use incremental EMA update (only process new bar, cache previous EMA)
3. Profile actual latency before optimizing (may be acceptable)

**Recommended Action:** Profile with realistic bar counts; optimize if threshold exceeded.

---

### [L-001] NO GAP DETECTION
**Severity:** LOW
**Location:** Line 506 (`_calculate_momentum`)

**Description:**
Momentum calculation uses simple price difference without detecting overnight/weekend gaps.

**Code Evidence:**
```python
def _calculate_momentum(self, prices: NDArray[np.floating[Any]], period: int = 10) -> float:
    momentum = float(prices[-1] - prices[-period - 1])  # No gap check
    return momentum
```

**Risk:**
After a weekend gap (e.g., +$30), momentum would show abnormally high value, potentially triggering false signals.

**Mitigation:** Add gap detection or session-aware momentum calculation. Low priority as SessionFilter should handle session boundaries.

---

### [L-002] NO WARMUP PROPERTY EXPOSED
**Severity:** LOW
**Location:** Lines 200-204

**Description:**
The minimum warmup bars are validated internally but not exposed as a queryable property.

**Code Evidence:**
```python
min_bars = max(50, self.lookback_bars)
if len(prices) < min_bars:
    raise InsufficientDataError(...)
```

**Risk:**
Callers must guess minimum warmup bars or catch `InsufficientDataError`.

**Mitigation:** Add `required_warmup_bars` property.

---

### [L-003] `last_update` IS WALL CLOCK, NOT BAR TIME
**Severity:** LOW
**Location:** Line 246

**Description:**
`last_update` is set to wall clock time, not bar close timestamp.

**Code Evidence:**
```python
analysis.last_update = datetime.now(timezone.utc)  # Wall clock
```

**Risk:**
Cannot verify HTF/LTF temporal alignment after the fact by comparing bar close times.

**Mitigation:** Accept optional `bar_close_time` parameter and store it instead of wall clock.

---

## Edge Case Analysis

| Edge Case | Status | Notes |
|-----------|--------|-------|
| Insufficient data | GOOD | Raises `InsufficientDataError` at line 202 |
| First bar after warmup | CLEAN | Protected by min_bars check |
| Division by zero | CLEAN | Guarded at lines 411, 467 |
| Gap handling | MINOR | No explicit gap detection |
| Session boundaries | DELEGATED | Handled by SessionFilter (caller) |

---

## Unit Test Status

**File:** `nautilus_gold_scalper/tests/test_indicators/test_mtf_manager.py`
**Tests:** 25 total
**Status:** ALL PASSED (1.32s)

**Coverage:**
- Initialization and reset
- Trend detection (bullish, bearish, ranging)
- Alignment scoring (perfect, good, conflicting)
- Trade permission (long, short, weak)
- Helper methods (EMA, RSI, ATR, trend determination)
- Edge cases (zero ATR, NaN prices, position size ranges)

---

## NautilusTrader Configuration Checklist

| Config | Status | Notes |
|--------|--------|-------|
| `ts_init_delta` | N/A | Pure computation class, no Nautilus integration |
| `bars_timestamp_on_close` | N/A | Does not receive Bar objects |
| `bar_execution` | N/A | Not an Actor/Strategy |
| `on_bar()` semantics | N/A | Receives raw price arrays, not Bar events |

---

## Architecture Notes

The MTFManager is a **PASSIVE INDICATOR CLASS**:
- Does NOT subscribe to bars
- Does NOT have `on_bar()` / `on_quote_tick()` handlers
- Does NOT interact with NautilusTrader Actor lifecycle
- Receives price arrays via method parameters
- Caller (Strategy layer) is responsible for providing completed bars

This design is acceptable but shifts temporal integrity responsibility to the caller. The Strategy layer MUST ensure:
1. HTF bars are complete before calling `get_mtf_bias()`
2. All price arrays exclude the current forming bar
3. Proper synchronization between timeframes

---

## CRITIC Self-Review Checklist

| Check | Status | Notes |
|-------|--------|-------|
| Uses only completed bars | CONDITIONAL | Depends on caller |
| Temporal Verification Protocol applied | COMPLETE | 7 access points traced |
| Bar indexing documented | YES | All `prices[-N]` patterns identified |
| Edge cases handled | YES | Zero ATR, insufficient data |
| Performance < 0.5ms per call | BORDERLINE | EMA is O(n), needs profiling |
| State reset mechanism | YES | reset() methods exist |
| Dependencies clear | YES | No external indicator dependencies |
| Unit tests exist AND pass | YES | 25/25 passed |

---

## Recommendations

### Immediate (Before Round 1 Completes)
1. Document in MTFManager docstring: "All price arrays MUST contain only completed bars"

### Short-term (Before Production)
2. Add optional `bar_close_timestamp` parameter for explicit temporal verification
3. Profile EMA performance with realistic bar counts (1000+ bars)

### Long-term (Optimization)
4. Vectorize EMA calculation or implement incremental update
5. Add gap detection to momentum calculation

---

## Round 0 Gate Status

**PASS** - No CRITICAL or HIGH temporal integrity issues found.

Round 1 may proceed with parallel indicator review. Agents should verify that callers of MTFManager (Strategy layer) pass only completed bars.

---

## Files Reviewed

| File | Lines | Status |
|------|-------|--------|
| `nautilus_gold_scalper/src/indicators/mtf_manager.py` | 672 | ANALYZED |
| `nautilus_gold_scalper/tests/test_indicators/test_mtf_manager.py` | 392 | VERIFIED (25 tests pass) |

**Word Count:** ~1,800 words (analysis content)
