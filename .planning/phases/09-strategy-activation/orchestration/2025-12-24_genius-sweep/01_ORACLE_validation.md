# ORACLE Validation Gap Analysis

## ORACLE Output
AGENT: ORACLE
VERSION: 3.4
CLAUDE_MD_VERSION: 3.10.23
STATUS: COMPLETE

---

## Executive Summary

This analysis identifies **16 validation gaps** in the current backtesting and optimization pipeline. The gaps are prioritized into three tiers:

- **CRITICAL (6 gaps)**: Block any GO decision until resolved
- **HIGH (6 gaps)**: Required for statistical rigor
- **MEDIUM (4 gaps)**: Improve quality but not blocking

**Key Finding:** The optimization pipeline lacks the core statistical machinery required by CLAUDE.md for approval: Monte Carlo simulation, PSR/DSR/PBO overfitting metrics, and true walk-forward analysis with parameter re-optimization.

---

## Files Analyzed

| File | Purpose |
|------|---------|
| `.planning/phases/09-strategy-activation/05-FALSIFICATION_TESTS.md` | Planned falsification tests (all pending) |
| `nautilus_gold_scalper/src/optimization/optimizer.py` | Main optimization pipeline |
| `nautilus_gold_scalper/src/optimization/validation/wfa_inline.py` | Inline WFA implementation |
| `nautilus_gold_scalper/src/optimization/constraints/apex.py` | Apex compliance checker |
| `.planning/phases/09-strategy-activation/orchestration/PHASE_00C_PORTFOLIO_REVIEW.md` | Portfolio decisions |

---

## CRITICAL Gaps (Block GO Decision)

### GAP-C1: No True Walk-Forward Analysis

**Current State:**
- InlineWFA runs a SINGLE backtest with fixed parameters
- Then slices trades by date to compute IS/OOS metrics
- This is NOT true WFA

**True WFA Requirement:**
1. Optimize parameters on IS period
2. Freeze parameters
3. Run on OOS period
4. Repeat for each window

**Impact:** Current WFE metric does NOT measure parameter stability, only temporal stability of a fixed parameter set.

**Evidence:**
```python
# wfa_inline.py line 82
# Key difference from full WFA: uses a single backtest per config
# with internal windowing, rather than N separate backtests.
```

**Fix Required:**
- Implement true WFA with parameter re-optimization per window
- OR explicitly document InlineWFA limitations and add compensating tests

---

### GAP-C2: No Monte Carlo Simulation

**Current State:**
- optimizer.py runs single backtest per parameter set
- No block bootstrap MC implemented
- No MC95DD calculation

**CLAUDE.md Requirements:**
- Monte Carlo: 5000 runs, block bootstrap
- MC95DD < 4% for approval

**Impact:** Cannot distinguish signal from noise. Cannot estimate tail risk.

**Evidence:**
```python
# optimizer.py - No Monte Carlo import or usage
# wfa_inline.py line 274:
trailing_dd = max_dd  # Approximation
```

**Fix Required:**
- Implement block bootstrap Monte Carlo (preserve autocorrelation)
- Compute: MC50DD, MC95DD, MC99DD, survival rate
- Add to optimization pipeline and reporting

---

### GAP-C3: No PSR/DSR/PBO Overfitting Metrics

**Current State:**
- PSR (Probabilistic Sharpe Ratio): NOT computed
- DSR (Deflated Sharpe Ratio): NOT computed
- PBO (Probability of Backtest Overfitting): NOT computed

**CLAUDE.md Requirements:**
- PSR >= 0.85
- DSR > 0 (CRITICAL - DSR < 0 = confirmed overfitting)
- PBO <= 15%

**Impact:** Cannot detect overfitting. Core validation gates unimplemented.

**Fix Required:**
- Implement Bailey-Lopez de Prado PSR calculation
- Implement DSR with multiple testing correction
- Implement CSCV-based PBO calculation

---

### GAP-C4: Incorrect HWM/Trailing DD Calculation

**Current State:**
```python
# wfa_inline.py line 274
trailing_dd = max_dd  # Approximation
```

**Apex Reality:**
- HWM includes UNREALIZED PnL (tick-by-tick)
- Floor = HWM * 0.95 (permanently raised by floating profit)
- Current approximation significantly UNDERSTATES risk

**Impact:** Strategy may pass validation but blow Apex account in live.

**Fix Required:**
- Implement tick-by-tick HWM tracking with unrealized PnL
- Use conservative price basis (BID for LONG exit, ASK for SHORT exit)
- Track HWM trap events (floating profit that raised floor)

---

### GAP-C5: No Execution Realism in Optimization

**Current State:**
- optimizer.py uses raw backtest results
- No slippage model
- No spread widening model
- No latency model

**CLAUDE.md GATE 2.5 Requirements:**
- BASELINE scenario
- CONSERVATIVE scenario (spread * 1.5, slippage = max(0.5 * spread, tick_size))

**Impact:** Optimized parameters may be fragile to execution costs.

**Fix Required:**
- Integrate slippage/spread/latency models into backtest function
- Run both BASELINE and CONSERVATIVE scenarios for each trial
- Reject if CONSERVATIVE fails thresholds

---

### GAP-C6: Falsification Tests Not Executed

**Current State:**
All tests in 05-FALSIFICATION_TESTS.md marked as pending:
- [ ] Ghost Test (Null Signal)
- [ ] Apex HWM Survival Monte Carlo
- [ ] Shifted Levels Test
- [ ] Wick Destruction Test
- [ ] Permutation Importance

**Impact:** Core claims about SMC edge remain unvalidated.

**Fix Required:**
- Execute P0 tests immediately (Ghost Test, Apex Survival)
- Execute P1 tests if P0 passes (Shifted Levels, Wick Destruction)
- Document results in orchestration folder

---

## HIGH Gaps (Required for Rigor)

### GAP-H1: No Holdout Test Set

**Current State:**
All data used in optimization + WFA windows.

**Best Practice:**
Reserve final 10-20% of data as holdout (NEVER seen during optimization).

**Impact:** Cannot detect data dredging across entire optimization process.

**Fix Required:**
- Reserve 2024-06-01 to 2025-11-28 as final holdout
- Only validate on holdout AFTER all optimization complete
- Single use - no iteration allowed

---

### GAP-H2: Regime-Conditional Metrics Empty

**Current State:**
```python
# wfa_inline.py line 296
regime_scores={},  # Computed in Layer 3 if needed
```

**Required:**
Performance breakdown by regime (trend/range/volatile).

**Impact:** Strategy may pass globally but fail in specific regimes.

**Fix Required:**
- Add regime tagging to trades
- Compute metrics per regime
- Require passing thresholds in ALL regimes

---

### GAP-H3: No Statistical Significance Testing

**Current State:**
- Point estimates only (Sharpe=X, WFE=Y)
- No confidence intervals
- No hypothesis tests

**Impact:** Cannot distinguish real edge from noise.

**Fix Required:**
- Add bootstrap 95% CI on all metrics
- Implement permutation tests for comparisons
- Calculate effect sizes (Cohen's d)

---

### GAP-H4: Inconsistent Sample Size Requirements

**Current State:**
| Source | Minimum Trades |
|--------|----------------|
| CLAUDE.md | 100 |
| wfa_inline.py is_valid() | 50 |
| Config trades_penalty | Variable |

**Impact:** May approve strategies with insufficient trades.

**Fix Required:**
- Standardize to 100 minimum (CLAUDE.md requirement)
- Add minimum trades per WFA window (e.g., 20+)
- Enforce programmatically

---

### GAP-H5: No Data Quality GATE 0

**Current State:**
optimizer.py has no pre-validation of data quality.

**CLAUDE.md GATE 0 Requirements:**
- File exists and readable
- No null/NaN in critical columns
- Timestamps monotonically increasing
- Price/spread within valid ranges

**Impact:** Backtest could run on corrupted data.

**Fix Required:**
- Add validate_data() function to optimizer.py
- Run before any optimization
- Fail fast on CRITICAL issues

---

### GAP-H6: No Parameter Stability Analysis

**Current State:**
Single optimal parameter set selected without stability analysis.

**Missing:**
- Plateau analysis (sharp peak vs wide plateau)
- Sensitivity heatmaps around optimal
- Parameter correlation analysis

**Impact:** Sharp peaks are unstable and likely overfit.

**Fix Required:**
- Add sensitivity analysis module
- Generate parameter heatmaps
- Require "plateau" optima over "peak" optima

---

## MEDIUM Gaps (Improve Quality)

### GAP-M1: WFA Window Count Mismatch

**Current:** 5 windows (wfa_inline.py default)
**CLAUDE.md:** 12 windows

**Fix:** Update default or document rationale for 5.

---

### GAP-M2: IS Ratio Potentially Too High

**Current:** 80% IS, 20% OOS
**CLAUDE.md:** 70% IS mentioned

**Fix:** Validate 70/30 split or document rationale for 80/20.

---

### GAP-M3: No Anchored WFA

**Current:** Only rolling window WFA implemented.

**Missing:** Anchored (expanding window) WFA for comparison.

**Fix:** Implement anchored WFA variant for robustness.

---

### GAP-M4: No Formal Look-Ahead Audit

**Current:** No systematic review of signal generation code.

**Risk:** Single look-ahead bug invalidates entire backtest.

**Fix:** Create look-ahead audit checklist and apply to all indicator/signal code.

---

## Recommended Improvements (Prioritized)

### Priority 1: BLOCKING (Must fix before any GO decision)

| ID | Action | Effort | Impact |
|----|--------|--------|--------|
| 1.1 | Implement Monte Carlo with HWM tracking | 2-3 days | Enables MC95DD gate |
| 1.2 | Implement PSR/DSR/PBO calculations | 2 days | Enables overfitting detection |
| 1.3 | Run Ghost Test | 0.5 day | Cheap disproof of SMC edge claim |
| 1.4 | Run Apex HWM Survival MC | 0.5 day | Validate survival under constraints |
| 1.5 | Fix trailing_dd approximation | 1 day | Accurate Apex risk estimation |
| 1.6 | Add execution realism (CONSERVATIVE scenario) | 1 day | Validate robustness to costs |

### Priority 2: REQUIRED (Before production validation)

| ID | Action | Effort | Impact |
|----|--------|--------|--------|
| 2.1 | Reserve holdout test set | 0.5 day | Detect data dredging |
| 2.2 | Implement regime-conditional metrics | 1 day | Regime-specific validation |
| 2.3 | Add bootstrap confidence intervals | 1 day | Distinguish signal from noise |
| 2.4 | Fix sample size inconsistencies | 0.5 day | Consistent enforcement |
| 2.5 | Implement Data Quality GATE 0 | 0.5 day | Catch data issues early |
| 2.6 | Add parameter stability analysis | 1 day | Detect overfit peaks |

### Priority 3: ENHANCE (Improve rigor)

| ID | Action | Effort | Impact |
|----|--------|--------|--------|
| 3.1 | Increase WFA windows to 12 | 0.5 day | More robust WFE |
| 3.2 | Validate IS ratio (70 vs 80) | 0.5 day | Better OOS coverage |
| 3.3 | Implement anchored WFA | 1 day | Alternative robustness view |
| 3.4 | Create look-ahead audit checklist | 0.5 day | Prevent temporal leakage |

---

## New Tests Recommended

### Test N1: Monte Carlo Survival Rate

**Purpose:** Validate survival under hostile conditions.

**Design:**
```python
for path in range(5000):
    # Block bootstrap trade sequence
    # Track HWM with unrealized PnL (tick-by-tick)
    # Check if equity < floor at any point
    if blown: survival_failures += 1

survival_rate = (5000 - survival_failures) / 5000
mc95_dd = np.percentile(all_max_dds, 95)
```

**Pass Criteria:**
- Survival rate >= 95%
- MC95DD < 4.0%
- MC99DD < 4.5%

---

### Test N2: Parameter Sensitivity Heatmap

**Purpose:** Detect sharp peaks (overfit) vs plateaus (robust).

**Design:**
```python
for param1 in grid(optimal_param1 * [0.8, 0.9, 1.0, 1.1, 1.2]):
    for param2 in grid(optimal_param2 * [0.8, 0.9, 1.0, 1.1, 1.2]):
        score = backtest(param1, param2)
        heatmap[param1][param2] = score
```

**Pass Criteria:**
- Performance degrades < 20% within +/- 20% of optimal params
- No "knife edge" optimality

---

### Test N3: Regime-Conditional Validation

**Purpose:** Ensure strategy works in all market conditions.

**Design:**
```python
for regime in [TREND, RANGE, TRANSITION]:
    trades_in_regime = filter(trades, regime)
    metrics = compute_metrics(trades_in_regime)
    assert metrics.sqn >= 1.5
    assert metrics.win_rate >= 0.40
```

**Pass Criteria:**
- SQN >= 1.5 in each regime
- Win rate >= 40% in each regime
- No regime with negative expectancy

---

### Test N4: Look-Ahead Audit

**Purpose:** Systematic verification of temporal correctness.

**Design:**
For each signal/indicator:
1. Document data inputs (which bars/ticks used)
2. Verify only closed bars used for calculation
3. Verify fill price is achievable at signal time
4. Create regression test with future data zeroed

**Pass Criteria:**
- All signal code passes temporal correctness review
- Regression tests pass

---

## Pre-Live Validation Checklist

### GATE 0: Data Quality
- [ ] File exists and readable
- [ ] No null/NaN in critical columns
- [ ] Timestamps monotonically increasing
- [ ] Price range $500-$5000 for XAUUSD
- [ ] Spread bounds 0 < spread < 100 pips
- [ ] No gaps > 4 hours during trading hours

### GATE 1: Sample Size
- [ ] Total trades >= 200
- [ ] Period >= 5 years (2003-2025)
- [ ] Trades per regime >= 50

### GATE 2: Performance Metrics
- [ ] Sharpe >= 1.5
- [ ] SQN >= 2.0
- [ ] Profit Factor >= 1.8
- [ ] Win Rate 40-75%

### GATE 2.5: Execution Realism
- [ ] BASELINE scenario passes
- [ ] CONSERVATIVE scenario passes (spread * 1.5, slippage modeled)
- [ ] Delta metrics documented (Baseline vs Conservative)

### GATE 3: Walk-Forward Analysis
- [ ] WFE >= 0.60
- [ ] WFE consistent across 12 windows
- [ ] WFE_std < 0.3

### GATE 4: Monte Carlo
- [ ] 5000 runs completed
- [ ] MC95DD < 4.0%
- [ ] MC99DD < 4.5%
- [ ] Survival rate >= 95%

### GATE 5: Overfitting Detection
- [ ] PSR >= 0.85
- [ ] DSR > 0 (CRITICAL)
- [ ] PBO <= 15%
- [ ] Parameter sensitivity passes (plateau not peak)

### GATE 6: Apex Consistency
- [ ] No single day > 30% of total profit
- [ ] Time gates verified (4:30 PM block, 4:55 PM force-close)
- [ ] HWM tracking with unrealized verified

### GATE 7: Falsification Tests
- [ ] Ghost Test passed (SMC adds edge)
- [ ] Shifted Levels Test passed (if SMC kept)
- [ ] Apex HWM Survival MC passed

### GATE 8: Paper Trading
- [ ] Duration >= 2 weeks
- [ ] Trades >= 20
- [ ] Time gates working correctly
- [ ] HWM/Floor tracking correct
- [ ] No overnight positions
- [ ] Slippage within assumptions

---

## Statistical Rigor Improvements

### 1. Implement Bailey-Lopez de Prado PSR

```python
def compute_psr(sharpe: float, n_trades: int, skew: float, kurtosis: float) -> float:
    """
    Probabilistic Sharpe Ratio.

    Formula: PSR = P(SR* > 0)
    where SR* is the true Sharpe ratio
    """
    if n_trades < 2:
        return 0.0

    # Standard error of Sharpe
    se_sr = np.sqrt((1 + 0.5 * sharpe**2 - skew * sharpe +
                    ((kurtosis - 3) / 4) * sharpe**2) / n_trades)

    # PSR = P(SR > 0) using normal CDF
    psr = norm.cdf(sharpe / se_sr)
    return float(psr)
```

### 2. Implement Deflated Sharpe Ratio

```python
def compute_dsr(sharpe: float, n_trades: int, n_trials: int, var_sr: float) -> float:
    """
    Deflated Sharpe Ratio (corrects for multiple testing).

    DSR < 0 = confirmed overfitting
    """
    # Expected maximum Sharpe under null (pure luck)
    e_max_sr = expected_max_sr(n_trials, var_sr)

    # Deflated Sharpe
    dsr = sharpe - e_max_sr
    return float(dsr)

def expected_max_sr(n_trials: int, var_sr: float) -> float:
    """Euler-Mascheroni correction for max of n trials."""
    gamma = 0.5772156649  # Euler-Mascheroni
    return np.sqrt(var_sr) * (
        (1 - gamma) * norm.ppf(1 - 1/n_trials) +
        gamma * norm.ppf(1 - 1/(n_trials * np.e))
    )
```

### 3. Implement PBO via CSCV

```python
def compute_pbo(returns_matrix: np.ndarray, n_combinations: int = 16) -> float:
    """
    Probability of Backtest Overfitting via Combinatorial Symmetric Cross-Validation.

    PBO > 25% = HIGH overfitting risk
    """
    overfit_count = 0

    for combo in combinations(range(n_combinations), n_combinations // 2):
        is_idx = list(combo)
        oos_idx = [i for i in range(n_combinations) if i not in is_idx]

        # Best IS performance
        is_sharpes = [compute_sharpe(returns_matrix[:, i]) for i in is_idx]
        best_is_idx = np.argmax(is_sharpes)

        # OOS performance of best IS
        oos_sharpe = compute_sharpe(returns_matrix[:, oos_idx[best_is_idx]])

        # Is OOS in bottom half?
        oos_rank = rank(oos_sharpe, oos_sharpes)
        if oos_rank > 0.5:
            overfit_count += 1

    pbo = overfit_count / comb(n_combinations, n_combinations // 2)
    return float(pbo)
```

---

## Conclusion

The current validation pipeline has significant gaps that would prevent a defensible GO decision. The most critical issues are:

1. **No Monte Carlo simulation** - Cannot estimate tail risk or survival probability
2. **No PSR/DSR/PBO** - Cannot detect overfitting
3. **Incorrect HWM calculation** - Understates Apex DD risk
4. **Falsification tests not run** - Core claims unvalidated

**Recommended Next Steps:**
1. Implement Monte Carlo with HWM tracking (GAP-C2, GAP-C4)
2. Implement PSR/DSR/PBO (GAP-C3)
3. Run Ghost Test and Apex Survival MC (GAP-C6)
4. Reserve holdout test set (GAP-H1)
5. Add execution realism scenarios (GAP-C5)

**Estimated Effort:** 8-12 days for Priority 1+2 items.

**DECISION: NO-GO** until critical gaps resolved.

---

*ORACLE v3.4 - Statistical Truth-Seeker*
*Analysis Date: 2025-12-24*
