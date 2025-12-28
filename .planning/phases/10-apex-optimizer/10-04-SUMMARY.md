# Phase 10 Plan 04: Monte Carlo Layer 3 Summary

## Status: ✅ COMPLETE

**Implemented:** Prior to 2025-12-28
**Validation:** Integrated into optimizer.py, tests passing

---

## Accomplishments

### 1. Created `monte_carlo_dd.py` module

**Location:** `nautilus_gold_scalper/src/optimization/stress/monte_carlo_dd.py`

**Implements:**
- `compute_mc_drawdown_percentiles()` - MC DD from equity series
- `compute_mc_drawdown_percentiles_from_trades()` - MC DD from trade PnL deltas
- `MonteCarloDDResult` - Frozen dataclass with `mc_95_dd`, `mc_99_dd`
- `_max_drawdown_pct()` - HWM-based max drawdown calculation
- `_block_bootstrap_indices()` - Block bootstrap resampling for autocorrelation preservation

**Key features:**
- Block bootstrap preserves autocorrelation structure
- Fail-closed design: returns 100% DD on invalid/missing data
- Configurable `block_size` with auto-heuristic (n^1/3)
- Sanity bounds [0, 100] on output

### 2. Created `ghost_test.py` module

**Location:** `nautilus_gold_scalper/src/optimization/stress/ghost_test.py`

**Implements:**
- `run_ghost_test()` - Runs permutation baseline test
- `GhostTestResult` - Frozen dataclass with sharpe comparison metrics
- `ghost_test_summary_dict()` - Converts result to JSON-serializable dict

**Key features:**
- Compares strategy Sharpe vs permuted baseline (block bootstrap)
- One-sided p-value: P(baseline >= observed)
- Fast disproof tool: if baseline ≈ original, edge is not in signal generation

### 3. Added stress fields to TrialResult

**Location:** `nautilus_gold_scalper/src/optimization/search/base.py:47-52`

```python
# Stress test results (populated in Layer 3)
mc_95_dd: float | None = None
mc_99_dd: float | None = None
degradation_survived: list[float] | None = None
pbo: float | None = None
```

### 4. Integrated into optimizer.py (Layer 3a, 3b)

**Location:** `nautilus_gold_scalper/src/optimization/optimizer.py:344-520`

**Layer 3a (lines 345-478):**
- Runs Monte Carlo DD for top_n candidates when `stress_test.monte_carlo.enabled`
- Runs degradation survival test when `stress_test.degradation.enabled`
- Computes candidate-set PBO (rank-based proxy)
- Populates `r.mc_95_dd`, `r.mc_99_dd`, `r.degradation_survived`, `r.pbo`

**Layer 3b (lines 483-520):**
- Runs Ghost Test for best candidate when `stress_test.ghost_test.enabled`
- Computes sharpe delta and p-value
- Passes `ghost_summary` to handoff generation

### 5. Additional stress modules

**Location:** `nautilus_gold_scalper/src/optimization/stress/`

- `degradation.py` - Degradation survival tests (slippage/latency stress)
- `pbo_cscv.py` - PBO/CSCV validation (Probability of Backtest Overfitting)

---

## Files Created/Modified

### Created:
- `nautilus_gold_scalper/src/optimization/stress/monte_carlo_dd.py` (244 lines)
- `nautilus_gold_scalper/src/optimization/stress/ghost_test.py` (131 lines)
- `nautilus_gold_scalper/src/optimization/stress/degradation.py`
- `nautilus_gold_scalper/src/optimization/stress/pbo_cscv.py`
- `nautilus_gold_scalper/src/optimization/stress/__init__.py`

### Modified:
- `nautilus_gold_scalper/src/optimization/search/base.py` (added stress fields)
- `nautilus_gold_scalper/src/optimization/optimizer.py` (added Layer 3a, 3b)
- `nautilus_gold_scalper/src/optimization/reporting/summary.py` (stress fields in reports)

---

## Configuration

**Location:** `nautilus_gold_scalper/src/optimization/config.py`

```python
class MonteCarloConfig:
    enabled: bool = True
    simulations: int = 1000
    block_bootstrap: bool = True
    block_size: str = "auto"

class GhostTestConfig:
    enabled: bool = True
    sims: int = 500
    seed_offset: int = 42

class StressTestConfig:
    enabled: bool = True
    top_n: int = 5
    monte_carlo: MonteCarloConfig
    ghost_test: GhostTestConfig
    degradation: DegradationConfig
    overfitting_detection: OverfittingDetectionConfig
```

---

## Decisions Made

1. **Block bootstrap over simple permutation:** Preserves autocorrelation structure in trade sequences

2. **Trade PnL deltas over returns:** Avoids division artifacts at small equity values

3. **Fail-closed design:** Returns 100% DD (worst case) when data is invalid/missing

4. **Ghost Test scope:** Runs on best candidate only (not all top_n) for speed

5. **Separation of concerns:** Each stress test is a standalone module, orchestrated by optimizer.py

---

## Validation

```bash
# Tests
./.venv/bin/pytest -q nautilus_gold_scalper/tests/test_optimization/

# Type checking
./.venv/bin/mypy --strict nautilus_gold_scalper/src/optimization/stress/
```

---

## Algorithm Details

### Monte Carlo DD (Block Bootstrap)

```
1. Extract trade PnL deltas: Δ = [pnl_1, pnl_2, ..., pnl_n]
2. For each simulation i = 1..sims:
   a. Generate block bootstrap indices (preserves autocorrelation)
   b. Resample deltas: Δ' = Δ[bootstrap_indices]
   c. Construct equity curve: E[t] = start_equity + cumsum(Δ'[:t])
   d. Compute max DD%: (HWM - min_after_hwm) / HWM * 100
3. Return percentiles: MC95DD = percentile(DD_samples, 95)
```

### Ghost Test (Baseline Falsification)

```
1. Compute Sharpe of original trade sequence
2. For each simulation i = 1..sims:
   a. Block-permute trade PnL (preserves distribution + some autocorrelation)
   b. Compute Sharpe of permuted sequence
3. Compare: p_value = P(baseline_sharpe >= original_sharpe)
4. If p_value > 0.05: signal component may not be the edge source
```

---

## Next Step

- Plan 10-05: ✅ Anti-Overfit Detectors (COMPLETE)
- Plan 10-06: Wire stress metrics into handoff format
