# Round 4 - FORGE Optimization Infrastructure Audit

```
AGENT: FORGE-NAUTILUS
VERSION: 1.1
CLAUDE_MD_VERSION: 3.10.22
STATUS: COMPLETE
ROUND: 4
FILES_REVIEWED: optimizer.py, grid.py, random.py, optimize.py, base.py, config.py
DATE: 2024-12-24
```

---

## Executive Summary

Round 4 audit verifies the C1 gap fix from Round 3 is correctly implemented and assesses remaining issues. The optimization infrastructure is now safe from the critical false Apex compliance vulnerability.

**VERDICT: CONDITIONALLY GO**
- Safe for development/testing
- For production: fix H1, H3, NEW-1 first

---

## C1 Gap Fix Verification

### Status: VERIFIED CORRECT

**Location**: `src/optimization/optimizer.py` lines 234-242

**Code Review**:
```python
# CRITICAL (C1 fix Round 3): Validate equity series before proceeding
# Empty equity = unknown DD = trial must fail to prevent false Apex compliance
if equity_series is None or len(equity_series) < 2:
    logger.warning(
        f"Trial failed: insufficient equity data "
        f"(len={len(equity_series) if equity_series is not None else 0}). "
        "This can happen when generate_account_report() fails."
    )
    return self._empty_result(params)
```

**Analysis**:
1. Check is placed AFTER backtest_fn returns but BEFORE WFA computation
2. Handles both `None` case and empty Series case
3. Returns `_empty_result(params)` which sets:
   - `trailing_dd=100.0` (fail-safe value)
   - `apex_compliant=False`
   - `score=-999.0`
4. Logging provides diagnostic info for debugging

**Evidence Chain BROKEN**:
```
equity extraction fails
  -> empty pd.Series returned
  -> optimizer.py line 236 catches len(equity_series) < 2
  -> returns _empty_result with trailing_dd=100.0
  -> Apex check: 100.0 <= 5.0? NO -> NON-COMPLIANT
  -> Trial correctly marked as non-compliant
```

**VERDICT**: C1 gap is CLOSED. No false Apex compliance possible from empty equity.

---

## C2 Risk Assessment for Single-Lot Strategies

### Status: APPROPRIATELY DEFERRED

**Issue**: FIFO matching pops entire entry regardless of fill quantity

**Location**: `scripts/optimize.py` lines 517-531

**Risk Analysis for Single-Lot**:

| Scenario | Risk Level | Reason |
|----------|------------|--------|
| Normal single-lot trades | NONE | Entry qty = fill qty always |
| Broker splits 1-lot order | VERY LOW | Rare on futures/CFD |
| Manual size modification | LOW | Requires intervention |
| Future variable sizing | MEDIUM | Would need fix then |

**Conclusion**: For current single-lot strategy, C2 is NOT a practical risk. Deferral is acceptable.

**Recommendation**: Add a runtime assertion when variable sizing is implemented:
```python
assert entry["quantity"] == fill_qty, "Partial fill detected - FIFO fix required"
```

---

## Remaining Issues Assessment

### HIGH Priority (Fix Before Production)

| # | Issue | Location | Status | Effort |
|---|-------|----------|--------|--------|
| H1 | Per-trial timeout not enforced | grid.py, random.py | OPEN | 1h |
| H3 | KeyError if "total" column missing | optimize.py:610 | OPEN | 15m |
| NEW-1 | No exception handling in search loops | grid.py:54, random.py:57 | NEW | 30m |

#### H1: Per-Trial Timeout Not Enforced

**Evidence**:
- `config.py` line 81: `timeout_per_trial: int = 300` (defined)
- `grid.py` lines 53-54: `for trial_id, params in enumerate(...): result = objective_fn(params)` (no timeout)
- `random.py` lines 56-57: same pattern (no timeout)

**Risk**: Single backtest can hang indefinitely, blocking entire optimization.

**Recommended Fix**:
```python
import signal
from contextlib import contextmanager

@contextmanager
def timeout(seconds: int):
    def handler(signum, frame):
        raise TimeoutError(f"Trial exceeded {seconds}s timeout")
    old = signal.signal(signal.SIGALRM, handler)
    signal.alarm(seconds)
    try:
        yield
    finally:
        signal.alarm(0)
        signal.signal(signal.SIGALRM, old)

# In search loop:
try:
    with timeout(self.config.search.timeout_per_trial):
        result = objective_fn(params)
except TimeoutError:
    result = self._empty_result_from_params(params)
```

#### H3: KeyError if "total" Column Missing

**Location**: `scripts/optimize.py` line 610

**Current Code**:
```python
equity_series = account_df["total"].astype(float)
```

**Risk**: If `generate_account_report()` returns DataFrame without "total" column, KeyError crashes the trial instead of graceful failure.

**Recommended Fix**:
```python
if "total" not in account_df.columns:
    logger.warning("Account report missing 'total' column, returning empty equity")
    return pd.Series(dtype=float)
equity_series = account_df["total"].astype(float)
```

#### NEW-1: No Exception Handling in Search Loops

**Location**:
- `grid.py` line 54: `result = objective_fn(params)`
- `random.py` line 57: `result = objective_fn(params)`

**Risk**: Any exception in objective_fn (not just backtest failures) crashes entire optimization run.

**Examples of Uncaught Exceptions**:
- MemoryError during large backtest
- IOError reading data file
- Unexpected parameter type causing TypeError

**Recommended Fix**:
```python
try:
    result = objective_fn(params)
except Exception as e:
    logger.error(f"Trial {trial_id} failed with exception: {e}")
    result = TrialResult(
        trial_id=trial_id,
        params=params,
        sqn=0.0, sharpe=0.0, sortino=0.0, profit_factor=0.0,
        total_pnl=0.0, trades=0, win_rate=0.0, max_drawdown_pct=0.0,
        wfe=0.0, wfe_std=0.0, positive_days_ratio=0.0,
        regime_scores={}, trailing_dd=100.0, daily_profit_max=100.0,
        time_gate_violations=0, overnight_positions=0,
        apex_compliant=False, score=-999.0,
    )
```

---

### MEDIUM Priority (Should Fix)

| # | Issue | Location | Status | Effort |
|---|-------|----------|--------|--------|
| M1 | Signal handler uses logging (deadlock) | optimize.py:139-147 | OPEN | 15m |
| MED-2 | CLI `or` pattern treats 0 as falsy | optimize.py:772-776 | OPEN | 15m |
| M3 | fills may not be chronologically ordered | optimize.py:503 | OPEN | 30m |

#### M1: Signal Handler Logging Deadlock

**Current Code** (optimize.py:139-147):
```python
def _signal_handler(signum: int, frame: Any) -> None:
    global _shutdown_requested
    _shutdown_requested = True
    sig_name = signal.Signals(signum).name
    logging.getLogger(__name__).warning(
        f"Received {sig_name}, initiating graceful shutdown..."
    )
```

**Risk**: If SIGINT arrives while main thread holds logging lock, deadlock occurs.

**Recommended Fix**:
```python
def _signal_handler(signum: int, frame: Any) -> None:
    global _shutdown_requested
    _shutdown_requested = True
    # DO NOT log here - not async-signal-safe

# After main loop:
if _shutdown_requested:
    logger.warning("Graceful shutdown requested via signal")
```

#### MED-2: CLI `or` Pattern Treats 0 as Falsy

**Current Code** (optimize.py:772-776):
```python
mode=args.mode or config.search.mode,
trials=args.trials or config.search.trials,
seed=args.seed or config.search.seed,
```

**Problem**: `--seed 0` becomes falsy, config value used instead of user's explicit 0.

**Recommended Fix**:
```python
mode=args.mode if args.mode is not None else config.search.mode,
trials=args.trials if args.trials is not None else config.search.trials,
seed=args.seed if args.seed is not None else config.search.seed,
```

---

### LOW Priority

| # | Issue | Location | Status | Effort |
|---|-------|----------|--------|--------|
| NEW-2 | Float precision in grid steps | grid.py:124 | NEW | 30m |

#### NEW-2: Float Precision in Grid Steps

**Current Code** (grid.py:124):
```python
yield low + i * spec.step
```

**Risk**: Accumulated floating-point error may cause last value != high.

**Example**: step=0.1, range=(0, 1) may yield 0.9999999... instead of 1.0

**Recommended Fix**: Use `np.linspace` or round to step precision.

---

## Issue Tracking Matrix

| Round | Issue | Severity | Status | Verified By |
|-------|-------|----------|--------|-------------|
| R2 | C1: 2-point fallback | CRITICAL | FIXED | R4-FORGE |
| R3 | C1 Gap: Empty equity | CRITICAL | FIXED | R4-FORGE |
| R3 | C2: Partial fills | CRITICAL | DEFERRED (acceptable) | R4-FORGE |
| R3 | H1: Timeout | HIGH | OPEN | - |
| R3 | H3: KeyError | HIGH | OPEN | - |
| R4 | NEW-1: Exception handling | HIGH | NEW | - |
| R3 | M1: Signal logging | MEDIUM | OPEN | - |
| R3 | MED-2: CLI `or` | MEDIUM | OPEN | - |
| R3 | M3: Fill ordering | MEDIUM | OPEN | - |
| R4 | NEW-2: Float precision | LOW | NEW | - |

---

## Recommendations

### For Development/Testing (NOW)
1. Proceed with optimizations - C1 gap is closed
2. Monitor for hangs (H1 not fixed)
3. Watch logs for KeyError on "total" column

### For Production (BEFORE GO-LIVE)
1. **MUST FIX**: H1 (timeout), H3 (KeyError), NEW-1 (exception handling)
2. **SHOULD FIX**: M1 (signal deadlock), MED-2 (CLI 0)
3. **CAN DEFER**: M3 (fill ordering), NEW-2 (float precision), C2 (partial fills)

---

## Verdict

**CONDITIONALLY GO**

The critical C1 vulnerability is confirmed fixed. The optimization infrastructure is safe for development and testing.

Before production deployment:
- Fix H1, H3, NEW-1 (estimated 2 hours total)
- Consider M1, MED-2 (estimated 30 minutes total)

C2 (partial fill FIFO) remains correctly deferred for single-lot strategy.

---

## Next Actions

1. [x] Verify C1 gap fix
2. [x] Assess C2 for single-lot
3. [x] Review remaining issues
4. [x] Find new issues
5. [ ] **Round 5**: Implement H1 timeout wrapper
6. [ ] **Round 5**: Add safe column access for H3
7. [ ] **Round 5**: Add exception handling for NEW-1
8. [ ] Re-run CRITIC for Round 5 verification

---

*Round 4 FORGE audit complete: 2024-12-24*
