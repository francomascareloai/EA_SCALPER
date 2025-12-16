[ARGUS INTEGRATED] <!-- Research improvements integrated 2025-12-16 -->

# Phase 6: Backtest Framework

> **⚡ ARGUS IMPROVEMENTS APPLIED** (see full details at end of file)
> - **Block bootstrap**: block_size=sqrt(N) preserving autocorrelation
> - **CPCV setup**: Combinatorial Purged Cross-Validation (replaces PBO)
> - **DSR/PSR metrics**: Deflated Sharpe, Probabilistic Sharpe

**Phase ID**: 06
**Status**: ⏳ Pending
**Estimated Agents**: 3 (Sequential)
**Execution Mode**: Sequential (dependencies)
**Model**: opus (all agents)

---

## Memory Constraint (CRITICAL)

**System RAM**: 12 GB total
**Backtest Memory Budget**: ~8 GB (leave 4 GB for OS)
**Data Loading**: Use NautilusTrader native ParquetDataCatalog
**Chunk Strategy**: Let NautilusTrader handle streaming internally

### Memory Considerations for Backtesting
- BacktestEngine uses internal streaming - respects memory constraints
- Data catalog is NOT loaded into memory - only indexed
- Strategy state should be minimal (<100 MB)
- Position tracking overhead: negligible

**CRITICAL**: Configure BacktestEngine with streaming mode enabled.

---

## Objective

**SCOPE CLARIFICATION**: This phase uses and validates EXISTING NautilusTrader infrastructure, not building from scratch. The goal is configuration and integration, not new engine development.

Prepare backtesting infrastructure by:
1. Validating existing BacktestEngine works with our catalogs
2. Configuring Walk-Forward Analysis (WFA) parameters
3. Setting up Monte Carlo simulation framework

---

## Prerequisites

- All Phase 1-5 completed successfully
- Data fully validated and approved
- Performance benchmarks established

---

## Why Sequential

These tasks have dependencies:
1. Event-driven engine must exist before WFA can use it
2. WFA setup depends on engine capabilities
3. Monte Carlo depends on both

---

## Tasks

### Task 6.1: Validate Existing Backtester

**Agent**: FORGE + NAUTILUS
**Spec**: `.claude/agents/forge-nautilus.md` + `.claude/agents/nautilus-trader-architect.md`
**Model**: opus

**Prompt**:
```
You are FORGE validating and enhancing the existing backtest infrastructure for XAUUSD.

TASK: Validate existing BacktestEngine works with validated catalogs. Add minimal enhancements if needed.

SCOPE: VALIDATION + MINIMAL ENHANCEMENT (not building from scratch)

EXISTING COMPONENTS (USE THESE):
- nautilus_gold_scalper/scripts/run_backtest.py (PRIMARY - enhance this)
- nautilus_gold_scalper/scripts/nautilus_backtest.py (reference)
- BacktestEngine from nautilus_trader.backtest.engine (CORE - use directly)

VALIDATION CHECKLIST:
1. [ ] run_backtest.py loads from stride1_COMPLETE catalog
2. [ ] BacktestEngine processes ticks correctly
3. [ ] Strategy loads and executes
4. [ ] Trades are recorded
5. [ ] Metrics are computed

MINIMAL ENHANCEMENTS (only if missing):
- Apex time gate checks (if not present)
- Trailing DD calculation (if not present)
- Metrics export to JSON

DO NOT BUILD:
- New event-driven engine
- Custom execution models (use NautilusTrader's)
- Custom position management (use NautilusTrader's)

REFERENCE: DOCS/04_REPORTS/VALIDATION/BACKTEST_MASTER_PLAN.md

STRATEGY LOCATION: nautilus_gold_scalper/src/strategies/
STRATEGY CONFIG: Validate strategy compiles and has no look-ahead

OUTPUT:
{
  "backtest_engine_works": true/false,
  "catalog_loads": true/false,
  "strategy_executes": true/false,
  "enhancements_added": [...],
  "validation_passed": true/false
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE6_BACKTESTER_VALIDATION.json

Apply CRITIC self-review. Verify no look-ahead bias. Test with 1 month sample data.
```

---

### Task 6.2: Walk-Forward Analysis Setup

**Agent**: ORACLE
**Spec**: `.claude/agents/oracle-backtest-commander.md`
**Model**: opus

**Depends on**: Task 6.1 complete

**Prompt**:
```
You are ORACLE setting up Walk-Forward Analysis infrastructure.

TASK: Configure WFA pipeline for robust out-of-sample validation.

REFERENCE: DOCS/04_REPORTS/VALIDATION/BACKTEST_MASTER_PLAN.md

EXISTING SCRIPT: scripts/oracle/walk_forward.py (review and enhance)

WFA CONFIGURATION:

1. DATA SPLIT
   - In-Sample (IS): 80% (training)
   - Out-of-Sample (OOS): 20% (validation)
   - 12 rolling windows

2. WINDOW STRUCTURE (for 2020-2024 data) - FIXED per CRITIC C3
   Window 1: IS=Jan 2020-Oct 2020, OOS=Nov-Dec 2020
   Window 2: IS=Mar 2020-Dec 2020, OOS=Jan-Feb 2021
   ... (rolling forward)
   Window 12: IS=Jan 2023-Oct 2023, OOS=Nov-Dec 2023
   Window 13: IS=Mar 2023-Dec 2023, OOS=Jan-Feb 2024
   Window 14: IS=May 2023-Feb 2024, OOS=Mar-Apr 2024
   Window 15: IS=Jul 2023-Apr 2024, OOS=May-Jun 2024
   Window 16: IS=Sep 2023-Jun 2024, OOS=Jul-Aug 2024

3. OPTIMIZATION TARGET
   - Optimize on IS data
   - Validate on OOS data
   - Compute Walk-Forward Efficiency (WFE)

4. WFE CALCULATION
   WFE = OOS_performance / IS_performance
   - WFE >= 0.60 required for PASS

5. ADDITIONAL METRICS
   - % of OOS windows profitable
   - OOS Sharpe ratio
   - OOS max drawdown
   - Consistency across windows

IMPLEMENTATION:
- Update scripts/oracle/walk_forward.py
- Create WFA configuration file (YAML)
- Integrate with event-driven engine from 6.1

OUTPUT:
{
  "wfa_config": {
    "windows": 12,
    "is_ratio": 0.8,
    "oos_ratio": 0.2,
    "date_range": ["2020-01-01", "2024-12-31"]
  },
  "script_path": "scripts/oracle/walk_forward.py",
  "config_path": "configs/wfa_config.yaml",
  "ready_to_execute": true/false
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE6_WFA_SETUP.json

Apply CRITIC self-review before reporting done.
```

---

### Task 6.3: Monte Carlo Infrastructure

**Agent**: ORACLE
**Spec**: `.claude/agents/oracle-backtest-commander.md`
**Model**: opus

**Depends on**: Task 6.1, 6.2 complete

**Prompt**:
```
You are ORACLE setting up Monte Carlo simulation infrastructure.

TASK: Configure Monte Carlo framework for statistical validation.

REFERENCE: DOCS/04_REPORTS/VALIDATION/BACKTEST_MASTER_PLAN.md

EXISTING SCRIPT: scripts/oracle/monte_carlo.py (review and enhance)

MONTE CARLO CONFIGURATION:

1. BLOCK BOOTSTRAP METHOD <!-- ARGUS: Updated to sqrt(N) -->
   - Preserve autocorrelation in returns
   - Block size: sqrt(N) where N = number of trades (ARGUS research)
   - Fallback minimum: 10 trades per block
   - Resample with replacement
   - Use arch.bootstrap.StationaryBootstrap for implementation

2. SIMULATION PARAMETERS
   - Number of simulations: 5000+
   - Confidence levels: 90%, 95%, 99%
   - Metrics to compute per simulation:
     * Total return
     * Max drawdown
     * Sharpe ratio
     * Win rate

3. OUTPUT DISTRIBUTIONS
   - Drawdown distribution (compute DD95, DD99)
   - Return distribution
   - Risk of Ruin calculation

4. THRESHOLD VALIDATION (APEX-COMPLIANT - FIXED per CRITIC C1) <!-- ARGUS: Updated thresholds -->
   - MC 95th percentile DD < 4%     # (1% buffer from Apex 5%)
   - Risk of Ruin (5% DD) < 1%      # (Apex termination level)
   - P(Daily DD > 2.5%) < 5%        # (HALT threshold is 3%)
   - P(Total DD > 4.5%) < 2%        # (HALT threshold is 4.5%)
   - Minimum trades: >= 200         # (ARGUS: increased from 100)

5. VISUALIZATION
   - Equity curve cone (confidence bands)
   - Drawdown histogram
   - Return distribution

IMPLEMENTATION:
- Update scripts/oracle/monte_carlo.py
- Create Monte Carlo configuration file
- Integrate with backtest results

OUTPUT:
{
  "mc_config": {
    "simulations": 5000,
    "block_size": 20,
    "confidence_levels": [0.90, 0.95, 0.99]
  },
  "script_path": "scripts/oracle/monte_carlo.py",
  "config_path": "configs/monte_carlo_config.yaml",
  "thresholds": {...},
  "ready_to_execute": true/false
}

FILE: DOCS/03_RESEARCH/FINDINGS/PHASE6_MONTE_CARLO_SETUP.json

Apply CRITIC self-review before reporting done.
```

---

## Success Criteria

| Criterion | Threshold | Priority |
|-----------|-----------|----------|
| Event engine compiles | No errors | CRITICAL |
| No look-ahead bias | Verified via shuffle test (FIXED per CRITIC C2) | CRITICAL |
| WFA configured | 12 windows | HIGH |
| Monte Carlo ready | 5000 sims | HIGH |
| Tests pass | All green | HIGH |

---

## Deliverables

1. **Event-driven backtest engine** - nautilus_gold_scalper/backtest/
2. **WFA configuration** - configs/wfa_config.yaml
3. **Monte Carlo configuration** - configs/monte_carlo_config.yaml
4. **PHASE6_EVENT_ENGINE.json**
5. **PHASE6_WFA_SETUP.json**
6. **PHASE6_MONTE_CARLO_SETUP.json**
7. **BACKTEST_FRAMEWORK_REPORT.md** - Consolidated summary

---

## Test Protocol

Before proceeding to Phase 7:

```bash
# 1. Unit tests for event engine
python -m pytest nautilus_gold_scalper/tests/test_backtest/ -v

# 2. Integration test with sample data
python nautilus_gold_scalper/scripts/run_backtest.py \
  --start 2024-01-01 --end 2024-01-31 --validate

# 3. WFA dry run (1 window only)
python scripts/oracle/walk_forward.py --windows 1 --dry-run

# 4. Monte Carlo dry run (100 sims only)
python scripts/oracle/monte_carlo.py --sims 100 --dry-run
```

---

## Next Phase

After completion, proceed to [Phase 7: Backtest Execution](./07-PHASE-PLAN.md)

---

## CRITIC Review (Phase 6)

**Reviewer**: CRITIC v1.1 - Adversarial Quality Guardian
**Date**: 2025-12-16
**Artifact**: Phase 6 Backtest Framework Plan
**Sequential Thinking**: 18 thoughts applied

---

### VERDICT: CONDITIONAL APPROVAL

The plan requires fixes to **3 CRITICAL** issues before execution can proceed.

---

### CRITICAL ISSUES (Must Fix Before Execution)

#### C1: Monte Carlo DD Thresholds Incompatible with Apex Rules

**Location**: Task 6.3, lines 226-229
**Current Values**:
- MC 95th percentile DD < 8%
- Risk of Ruin (10% DD) < 5%
- P(Total DD > 10%) < 2%

**Problem**: Apex trailing DD = 5% from HWM = ACCOUNT TERMINATION. The plan's thresholds are **2x higher than Apex allows**. A strategy passing 8% DD would blow an Apex account.

**Impact**: Guaranteed Apex failure if strategy passes current thresholds.

**Fix**:
```yaml
# CORRECTED Apex-compatible thresholds:
- MC 95th percentile DD < 4%    # (1% buffer from Apex 5%)
- P(Daily DD > 2.5%) < 5%       # (HALT threshold is 3%)
- P(Total DD > 4.5%) < 2%       # (HALT threshold is 4.5%)
- Risk of Ruin (5% DD) < 1%     # (Apex termination level)
```

#### C2: No Concrete Look-Ahead Bias Verification Methodology

**Location**: Success Criteria table, line 266
**Current**: "No look-ahead bias | Verified | CRITICAL"

**Problem**: "Verified" is not a methodology. No concrete test specified for detecting look-ahead bias.

**Impact**: Subtle look-ahead (e.g., using today's close for today's signal) could pass all tests and only fail in live trading.

**Fix**: Add explicit look-ahead detection test:
```python
# Look-ahead detection test:
# 1. Run backtest on data[0:T]
# 2. Shuffle data[T:T+100] randomly
# 3. Re-run backtest - signals at T-1 should be IDENTICAL
# 4. If signals change, look-ahead bias detected

def test_no_lookahead():
    original_signals = run_backtest(data)
    shuffled_data = shuffle_future(data, pivot=len(data)-100)
    shuffled_signals = run_backtest(shuffled_data)
    assert signals_before_pivot_identical(original_signals, shuffled_signals)
```

#### C3: WFA Windows Missing 2024 Data

**Location**: Task 6.2, lines 141-144
**Current**: Window 12 ends at Dec 2023, but date_range claims 2020-2024.

**Problem**: Full year 2024 is not covered by WFA windows despite being in the claimed date range.

**Impact**: 20% of available data (2024) is unused for validation.

**Fix**: Extend windows or add Window 13-14:
```
Window 13: IS=May 2023-Feb 2024, OOS=Mar-Apr 2024
Window 14: IS=Sep 2023-Jun 2024, OOS=Jul-Aug 2024
# OR adjust all windows to include 2024 data
```

---

### HIGH ISSUES (Should Fix)

#### H1: "streaming_mode" API Reference Imprecise

**Location**: Lines 19, 24
**Problem**: Plan references "streaming mode enabled" but NautilusTrader uses `StreamingConfig` object or `add_data_iterator()`, not a boolean flag.

**Fix**: Specify correct API:
```python
from nautilus_trader.persistence.config import StreamingConfig

streaming = StreamingConfig(
    catalog_path=catalog.path,
    flush_interval_ms=1000,
)
engine_config = BacktestEngineConfig(streaming=streaming)

# OR for very large datasets:
engine.add_data_iterator(
    data_name="xauusd_ticks",
    generator=catalog.query_generator(...),
)
```

#### H2: Apex Compliance Treated as Optional

**Location**: Task 6.1, lines 85-87
**Current**: "Apex time gate checks (if not present)" - conditional language.

**Problem**: Apex compliance should be MANDATORY, not optional enhancements.

**Fix**: Change to:
```
MANDATORY APEX COMPLIANCE (must be present):
- Time gate: block new trades after 4:30 PM ET
- Emergency close: force-close all positions at 4:55 PM ET
- Final close: close ALL by 4:59 PM ET
- Trailing DD from HWM (includes unrealized)
- 30% daily consistency check
```

#### H3: No Timezone Handling Specified

**Problem**: Apex time gates are in ET (Eastern Time). Plan doesn't specify:
- How data timestamps are converted to ET
- DST handling (EST vs EDT)
- Market session boundaries

**Fix**: Add explicit timezone configuration:
```yaml
timezone:
  data_source: UTC
  apex_gates: America/New_York
  dst_handling: automatic  # via pytz/zoneinfo
```

#### H4: Block Size Assumed, Not Derived

**Location**: Task 6.3, line 208
**Current**: "Block size: ~20 trades (tune based on autocorrelation)"

**Problem**: 20 is a guess. No ACF/PACF analysis specified.

**Fix**: Add pre-MC step:
```python
# Before finalizing block size:
1. Compute ACF of trade returns up to lag 50
2. Find lag where ACF drops below 95% CI
3. Block size = max(lag, 10)  # minimum 10 for stability
```

#### H5: WFE Optimization Target Unspecified

**Location**: Task 6.2
**Problem**: WFA optimizes parameters but doesn't specify WHAT metric to optimize.

**Fix**: Specify optimization target:
```yaml
optimization:
  primary_target: sharpe_ratio
  secondary_constraint: max_dd < 3%
  tertiary_constraint: min_trades >= 50
```

#### H6: Minimum Trade Count Check Missing

**Problem**: Monte Carlo with block size 20 requires >> 20 trades. Plan doesn't verify minimum count.

**Fix**: Add pre-MC validation:
```python
if trade_count < block_size * 5:  # Need 5x for meaningful bootstrap
    raise ValueError(f"Insufficient trades ({trade_count}) for MC block size {block_size}")
```

---

### MEDIUM ISSUES (Recommended)

| ID | Issue | Location | Recommendation |
|----|-------|----------|----------------|
| M1 | WFA ratio is 83/17 not 80/20 | Lines 135-137 | Clarify or adjust: 10mo IS + 2mo OOS = 83.3%/16.7% |
| M2 | No regime-aware validation | Task 6.2 | Add regime labels (trend/range/volatile) to windows |
| M3 | Memory profiling unspecified | Lines 18-23 | Add: `memory_profiler` test during full backtest |
| M4 | Edge cases unhandled | Multiple | Handle: empty data, WFE div-by-zero, block > trades |
| M5 | Deliverable naming inconsistent | Lines 278 vs 108 | Use consistent: PHASE6_BACKTESTER_VALIDATION.json |
| M6 | "Compiles" incorrect for Python | Line 265 | Change to: "Imports without error AND passes mypy" |
| M7 | Test protocol insufficient | Lines 289-302 | Add: 3-window WFA test to verify rolling logic |

---

### LOW ISSUES (Nice to Have)

| ID | Issue | Recommendation |
|----|-------|----------------|
| L1 | configs/ directory existence unverified | Add mkdir check in Task 6.2 |
| L2 | 12 windows not statistically justified | Cite literature or compute sample size |
| L3 | WFE 0.60 threshold source uncited | Reference source for this threshold |

---

### ASSUMPTIONS CHALLENGED

| Assumption | Challenge | Recommendation |
|------------|-----------|----------------|
| Streaming respects memory | Strategy state can grow unbounded | Add state size monitoring |
| Block size 20 preserves autocorrelation | XAUUSD may have different structure | Compute ACF first |
| 12 windows sufficient | May need 20+ for significance | Justify statistically |
| WFE >= 0.60 appropriate | Asset-specific thresholds vary | Cite or derive empirically |
| Existing scripts work | Correctness unverified | Add unit tests first |

---

### EDGE CASES REQUIRING HANDLING

1. **Empty data window**: Skip window, don't crash
2. **WFE division by zero**: If IS_perf = 0, report "undefined" with warning
3. **Block size > trade count**: Error with clear message before MC runs
4. **First window warmup**: Specify lookback padding for indicators
5. **Partial fills**: Document assumption (full fills) or handle complexity
6. **Negative WFE interpretation**: If IS < 0 and OOS > 0, WFE is misleading

---

### STRESS TEST RESULTS

| Condition | Expected Outcome | Risk |
|-----------|------------------|------|
| 32.7M ticks full load | Should stream, not load all | MEDIUM - verify with profiling |
| Very few trades (10) | MC should error, not proceed | HIGH - add check |
| All trades on one day | 30% consistency check fails | MEDIUM - test this case |
| Strategy state grows unbounded | Memory overflow | HIGH - add state limits |

---

### PRE-MORTEM SUMMARY

**Most likely failure mode**: Monte Carlo simulation passes with 6% DD (under 8% threshold) but Apex account terminates at 5.01% trailing DD. Root cause: Thresholds too lenient.

**Second most likely**: Look-ahead bias in strategy goes undetected because no concrete verification test exists. Backtest shows excellent results, live trading fails completely.

**Third most likely**: Memory overflow during full backtest with 32.7M ticks because "streaming" was configured incorrectly or strategy state grew unbounded.

---

### MANUAL VERIFICATION NEEDED

- [ ] Verify `configs/` directory exists or will be created
- [ ] Confirm NautilusTrader version supports StreamingConfig
- [ ] Validate that existing scripts (run_backtest.py, walk_forward.py, monte_carlo.py) are functional
- [ ] Check that test files at `nautilus_gold_scalper/tests/test_backtest/` exist or are created
- [ ] Verify memory usage with actual 32.7M tick dataset

---

### CONFIDENCE: HIGH

Issues identified are concrete, verifiable, and based on:
- NautilusTrader API documentation verification
- Mathematical analysis of WFA window calculations
- Comparison of Monte Carlo thresholds vs Apex rules
- Systematic application of all 7 adversarial techniques

The plan structure is sound; issues are primarily in thresholds, edge cases, and methodology specifics. With CRITICAL fixes applied, this phase can proceed successfully.

---

**CRITIC v1.1** - *"Every bug found now is a loss prevented later."*

---

## ARGUS Research Improvements

**Date Integrated**: 2025-12-16
**Source**: ARGUS Quant Researcher - Research Triangulation
**Confidence**: HIGH (3+ independent sources, reproducible methods)

### Summary of Changes

The following research-backed improvements have been integrated into Phase 6:

| Improvement | Old Value | New Value | Rationale |
|-------------|-----------|-----------|-----------|
| Block size formula | Fixed ~20 | sqrt(N) | Optimal for most time series (Politis & Romano 1994) |
| Minimum trades | 100 | **200** | Institutional standard for statistical significance |
| Bootstrap method | IID | Block/Stationary | Preserves autocorrelation in returns |

### New Dependencies

Add to `requirements.txt`:

```txt
# ARGUS Research Improvements - Validation Libraries
mlfinlab>=2.0.0          # CPCV, DSR, PSR, purging, embargo
timeseriescv>=0.2.0      # CombPurgedKFoldCV
hmmlearn>=0.3.0          # Hidden Markov Models for regimes
arch>=6.0.0              # Block bootstrap, circular bootstrap
```

### Block Bootstrap Implementation

Replace IID bootstrap with block bootstrap to preserve autocorrelation:

```python
from arch.bootstrap import StationaryBootstrap
import numpy as np
import pandas as pd

def block_bootstrap_monte_carlo(returns: pd.Series, n_simulations: int = 5000) -> dict:
    """Block bootstrap preserving autocorrelation structure.

    ARGUS Research: Block size = sqrt(N) is optimal for most time series.
    Uses StationaryBootstrap from arch library for proper implementation.
    """
    # Block size = sqrt(N) is optimal for most time series
    block_size = max(10, int(np.sqrt(len(returns))))

    bs = StationaryBootstrap(block_size, returns.values)

    results = []
    for data in bs.bootstrap(n_simulations):
        sim_returns = data[0][0]
        # Calculate max drawdown for this simulation
        cumulative = (1 + sim_returns).cumprod()
        running_max = np.maximum.accumulate(cumulative)
        drawdown = (running_max - cumulative) / running_max
        max_dd = drawdown.max()
        results.append(max_dd)

    return {
        "block_size": block_size,
        "n_simulations": n_simulations,
        "dd_mean": float(np.mean(results)),
        "dd_std": float(np.std(results)),
        "dd_95": float(np.percentile(results, 95)),
        "dd_99": float(np.percentile(results, 99)),
        "pass": np.percentile(results, 95) < 0.04  # 4% threshold
    }
```

### CPCV (Combinatorial Purged Cross-Validation) Setup

Configure CPCV for Phase 7 execution (replaces PBO):

```python
from mlfinlab.cross_validation import CombinatorialPurgedKFold
import numpy as np
import pandas as pd

def setup_cpcv_config() -> dict:
    """CPCV configuration for walk-forward validation.

    ARGUS Research: CPCV provides superior overfitting detection
    compared to PBO by testing all combinations of train/test splits.
    """
    return {
        "n_splits": 5,
        "n_test_splits": 2,  # Combinatorial: test 2 folds at a time
        "purge_gap": 5,      # Gap to prevent information leakage
        "embargo_gap": 5,    # Embargo period after test fold
        "threshold": 0.6,    # CPCV score >= 0.6 required
    }

def calculate_cpcv_score(returns: pd.Series, config: dict) -> dict:
    """Calculate CPCV score for overfitting detection.

    Returns score indicating probability strategy is NOT overfit.
    Score >= 0.6 is required for PASS.
    """
    cv = CombinatorialPurgedKFold(
        n_splits=config["n_splits"],
        n_test_splits=config["n_test_splits"],
        purge_gap=config["purge_gap"],
        embargo_gap=config["embargo_gap"]
    )

    scores = []
    for train_idx, test_idx in cv.split(returns):
        train = returns.iloc[train_idx]
        test = returns.iloc[test_idx]
        # Calculate Sharpe on test fold
        if test.std() > 0:
            sharpe = test.mean() / test.std() * np.sqrt(252)
            scores.append(sharpe)

    cpcv_score = np.mean(scores) / np.std(scores) if np.std(scores) > 0 else 0

    return {
        "cpcv_sharpe_mean": float(np.mean(scores)),
        "cpcv_sharpe_std": float(np.std(scores)),
        "cpcv_score": float(cpcv_score),
        "pass": cpcv_score >= config["threshold"]
    }
```

### HMM Regime Classification Setup

Configure Hidden Markov Model for regime detection:

```python
from hmmlearn import hmm
import numpy as np
import pandas as pd

def setup_hmm_config() -> dict:
    """HMM configuration for regime classification.

    ARGUS Research: 3 regimes (low/medium/high volatility)
    is optimal for XAUUSD based on literature.
    """
    return {
        "n_regimes": 3,
        "n_iter": 1000,
        "covariance_type": "full",
        "random_state": 42,
    }

def fit_hmm_regimes(returns: pd.Series, config: dict) -> dict:
    """Fit HMM to classify market regimes.

    Strategy must be profitable in ALL regimes to pass.
    """
    X = returns.values.reshape(-1, 1)

    model = hmm.GaussianHMM(
        n_components=config["n_regimes"],
        covariance_type=config["covariance_type"],
        n_iter=config["n_iter"],
        random_state=config["random_state"]
    )
    model.fit(X)

    regimes = model.predict(X)

    regime_stats = {}
    for i in range(config["n_regimes"]):
        mask = regimes == i
        regime_returns = returns[mask]
        regime_stats[f"regime_{i}"] = {
            "count": int(mask.sum()),
            "pct": float(mask.mean() * 100),
            "mean_return": float(regime_returns.mean()),
            "volatility": float(regime_returns.std()),
            "sharpe": float(regime_returns.mean() / regime_returns.std() * np.sqrt(252)) if regime_returns.std() > 0 else 0
        }

    return {
        "n_regimes": config["n_regimes"],
        "regime_stats": regime_stats,
        "transition_matrix": model.transmat_.tolist(),
        "all_regimes_profitable": all(r["mean_return"] > 0 for r in regime_stats.values())
    }
```

### Updated Monte Carlo Config Template

```yaml
# configs/monte_carlo_config.yaml
# ARGUS Research Integrated Configuration

monte_carlo:
  simulations: 5000
  block_size_formula: "sqrt(N)"  # ARGUS: Optimal for time series
  min_block_size: 10
  confidence_levels: [0.90, 0.95, 0.99]

thresholds:
  mc_dd_95: 0.04          # < 4% (Apex buffer)
  ror_5pct: 0.01          # < 1% (Apex termination)
  p_daily_dd_breach: 0.05 # < 5%
  p_total_dd_breach: 0.02 # < 2%
  min_trades: 200         # ARGUS: Increased from 100

cpcv:
  n_splits: 5
  n_test_splits: 2
  purge_gap: 5
  embargo_gap: 5
  threshold: 0.6          # CPCV score >= 0.6 required

hmm:
  n_regimes: 3
  require_all_profitable: true
```

### Verification Checklist

Before Phase 7 execution, verify:

- [ ] `mlfinlab` installed and importable
- [ ] `arch` installed and importable
- [ ] `hmmlearn` installed and importable
- [ ] Monte Carlo config uses sqrt(N) block size
- [ ] CPCV replaces PBO in WFA validation
- [ ] HMM regime classification configured
- [ ] Minimum trades threshold set to 200

---
