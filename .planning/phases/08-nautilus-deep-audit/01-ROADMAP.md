# ROADMAP: Deep Audit - Nautilus Strategies & Infrastructure (v2.0)

## Changelog
- v2.0: Added Phase 00, Phase 04.5, reduced parallel agents, added output protocol
- v2.1: Phase 00 COMPLETE (2025-12-16) - Foundation verified, all thresholds match

## Progress
- **Phases Completed:** 11/11 (audit scope)
- **Current Phase:** Post-Audit Remediation (WP0–WP5)

## Phase Overview

| Phase | Focus | Agents | Rounds | Priority | Status |
|-------|-------|--------|--------|----------|--------|
| 00 | Foundation Verification | 1 | 1 | P0 - BLOCKER | COMPLETE |
| 01 | Core Strategy Audit | 1-2 | 1 | P0 - CRITICAL | COMPLETE (BLOCKED) |
| 02 | Indicators SMC Audit | 2+2 | 2 | P0 - CRITICAL | COMPLETE (R0+R1+R2) |
| 03 | Risk Modules Audit | 2+1 | 2 | P0 - CRITICAL | COMPLETE (REMEDIATED + R2) |
| 04 | Signal Generators Audit | 2 | 1 | P1 - HIGH | COMPLETE (BLOCKED) |
| 04.5 | ML Pipeline Audit | 1 | 1 | P0 - CRITICAL | COMPLETE (BLOCKED) |
| 05 | Execution Layer Audit | 2 | 1 | P1 - HIGH | COMPLETE (BLOCKED) |
| 06 | Backtest Scripts Audit | 2+2 | 2 | P1 - HIGH | COMPLETE (BLOCKED) |
| 07 | Test Coverage Analysis | 1 | 1 | P2 - MEDIUM | COMPLETE (BLOCK) |
| 08 | Integration Points Audit | 2 | 1 | P1 - HIGH | COMPLETE (BLOCKED) |
| 09 | Final Synthesis | 1 | 1 | P0 - CRITICAL | COMPLETE (NO-GO) |

**Total Agents:** ~18 (reduced from 21)
**Max Parallel:** 2-3 per round (CLAUDE.md compliant)

---

## Phase 00: Foundation Verification (NEW - BLOCKER)

**Files:**
- `src/core/definitions.py` - Thresholds, Apex constants
- `src/core/data_types.py` - Data structures
- `src/core/exceptions.py` - Custom exceptions

**Tasks:**
1. Create git tag `audit-baseline-YYYYMMDD`
2. Run pytest baseline
3. Verify ALL thresholds against CLAUDE.md
4. Count lines for scope verification
5. Create orchestration/ directory

**Agent:** 1 opus
**Blocking:** If definitions don't match CLAUDE.md, STOP audit

---

## Phase 01: Core Strategy Audit

**Files (~1,400 lines):**
- `gold_scalper_strategy.py`
- `base_strategy.py`
- `strategy_selector.py`

**CRITIC Focus:**
- Apex compliance (5 rules)
- Look-ahead bias
- Performance budget
- Position lifecycle

**Agent:** 1 FORGE (opus)

---

## Phase 02: Indicators SMC Audit (SPLIT INTO 2 ROUNDS)

**Files (~4,100 lines):**

### Round 1 (2 agents parallel)
**Agent A:** `regime_detector.py` + `session_filter.py` + `amd_cycle_tracker.py` (~860 lines)
**Agent B:** `order_block_detector.py` + `fvg_detector.py` (~1,179 lines)

### Round 2 (2 agents parallel)
**Agent C:** `liquidity_sweep.py` + `structure_analyzer.py` (~1,232 lines)
**Agent D:** `footprint_analyzer.py` + `mtf_manager.py` (~1,120 lines)

**Checkpoint between rounds**

**CRITIC Focus:**
- SMC logic correctness
- Look-ahead bias (temporal verification method)
- Edge cases

**Agents:** 2+2 FORGE (opus)

---

## Phase 03: Risk Modules Audit (SPLIT INTO 2 ROUNDS)

**Files (~2,989 lines):**

### Round 1 (2 agents parallel)
**Agent A:** `drawdown_tracker.py` + `dd_protection.py` + `prop_firm_manager.py` (~935 lines)
**Agent B:** `circuit_breaker.py` + `time_constraint_manager.py` (~648 lines)

### Round 2 (1 agent)
**Agent C:** `position_sizer.py` + `spread_monitor.py` + `var_calculator.py` + `consistency_tracker.py` (~1,330 lines)

**Checkpoint between rounds**

**CRITIC Focus:**
- Apex compliance verification (all 5 rules)
- Trailing DD from HIGH-WATER MARK
- Time gate enforcement

**Agents:** 2+1 SENTINEL (opus)

---

## Phase 04: Signal Generators Audit

**Files (~3,450 lines):**
- `confluence_scorer.py` (1002 lines)
- `entry_optimizer.py` (699 lines)
- `mtf_manager.py` (395 lines)
- `news_calendar.py` (628 lines)
- `news_trader.py` (688 lines)

**Agent A:** `confluence_scorer.py` + `mtf_manager.py` (~1,397 lines)
**Agent B:** `entry_optimizer.py` + `news_calendar.py` + `news_trader.py` (~2,015 lines)

**CRITIC Focus:**
- Scoring thresholds match CLAUDE.md
- Look-ahead in news data
- MTF temporal alignment

**Agents:** 2 CRUCIBLE (opus)

---

## Phase 04.5: ML Pipeline Audit (NEW - CRITICAL)

**Files (~500 lines):**
- `src/ml/feature_engineering.py`
- `src/ml/ensemble_predictor.py`
- `src/ml/model_trainer.py`

**Why Critical:**
ML is the #1 look-ahead danger zone. Features calculated from future data = instant failure.

**CRITIC Focus:**
- Feature engineering temporal integrity
- No future data in training
- Inference uses only past data

**Agent:** 1 FORGE (opus) with exhaustive temporal trace

---

## Phase 05: Execution Layer Audit

**Files (~908 lines):**
- `trade_manager.py` (633 lines)
- `base_adapter.py` (128 lines)
- `execution_model.py` (42 lines)
- `mt5_adapter.py` (44 lines)
- `ninjatrader_adapter.py` (42 lines)

**Also include:**
- `src/context/holiday_detector.py` (~100 lines)

**Agent A:** `trade_manager.py` + `execution_model.py` (~675 lines)
**Agent B:** Adapters + `holiday_detector.py` (~314 lines)

**CRITIC Focus:**
- Order lifecycle
- Slippage realism
- Holiday handling

**Agents:** 2 FORGE (opus)

---

## Phase 06: Backtest Scripts Audit (SPLIT INTO 2 ROUNDS)

**Files (~10,000+ lines):**

### Round 1 (2 agents parallel) - Core Strategies
**Agent A:** `ea_logic_full.py` (2696 lines)
**Agent B:** `ea_logic_python.py` + `adaptive_kelly.py` + `ea_logic_compat.py` (~1,558 lines)

### Round 2 (2 agents parallel) - Validation Scripts
**Agent C:** `fibonacci_analyzer.py` + `spread_analyzer.py` (~990 lines)
**Agent D:** `monte_carlo_degradation.py` + `wfa_filter_study.py` + `realistic_backtester.py`

**Checkpoint between rounds**

**CRITIC Focus:**
- Consistency with main strategy
- Data leakage detection
- Monte Carlo correctness
- Walk-forward correctness

**Agents:** 2+2 general-purpose (opus)

---

## Phase 07: Test Coverage Analysis

**Files:** `nautilus_gold_scalper/tests/` (all)

**Focus:**
- Coverage gaps
- Critical paths untested
- Edge case coverage

**Agent:** 1 general-purpose (opus) ← UPGRADED from haiku

---

## Phase 08: Integration Points Audit

**Focus:**
- Strategy ↔ Risk integration
- Indicator ↔ Strategy data flow
- Signal ↔ Execution handoff
- Time synchronization

**Agent A:** Strategy-Risk-Execution flow
**Agent B:** Indicator-Signal-Strategy flow

**Agents:** 2 NAUTILUS (opus)

---

## Phase 09: Final Synthesis

**Inputs:** All PHASE_XX_FINDINGS.md files

**Deliverables:**
1. `AUDIT_REPORT.md` - Master findings
2. `ISSUES_TRACKER.md` - All issues
3. `RECOMMENDATIONS.md` - Prioritized actions
4. GO/NO-GO decision

**Agent:** 1 DAEMON (opus)

---

## Execution Order

```
Phase 00 (Foundation) ← BLOCKER
    ↓
Phase 01 (Core Strategy)
    ↓
Phase 02 Round 1 (Indicators A,B)
    ↓ checkpoint
Phase 02 Round 2 (Indicators C,D)
    ↓
Phase 03 Round 1 (Risk A,B)
    ↓ checkpoint
Phase 03 Round 2 (Risk C)
    ↓
Phase 04 (Signals) + Phase 04.5 (ML) ← can run parallel
    ↓
Phase 05 (Execution)
    ↓
Phase 06 Round 1 (Backtest A,B)
    ↓ checkpoint
Phase 06 Round 2 (Backtest C,D)
    ↓
Phase 07 (Test Coverage)
    ↓
Phase 08 (Integration)
    ↓
Phase 09 (Synthesis)
```

---

## Checkpoint Protocol

After each phase/round:
1. Write findings to `orchestration/PHASE_XX_FINDINGS.md`
2. Create brief summary (≤300 words) in chat
3. If context heavy, consider fresh conversation for next phase
4. Update MANIFEST.md

---

## ARGUS Research: Backtest Validation Best Practices

**Researched:** 2025-12-23
**Agent:** ARGUS v2.4
**CLAUDE_MD_VERSION:** 3.10.21
**STATUS:** COMPLETE

### Executive Summary

This research addresses gaps identified in ORACLE review: no DSR implementation, no holdout methodology, insufficient sample size validation. Below are state-of-the-art practices from Marcos Lopez de Prado and academic literature.

---

### 1. Walk-Forward Analysis (WFA) - State of the Art

**Best Practices:**
- **Rolling windows preferred** over anchored (better simulates real trading conditions)
- **Optimization window:** 2-4 years of historical data
- **OOS validation period:** 3-6 months per fold
- **In-sample/OOS ratio:** 70-80% optimization / 20-30% validation

**Number of Folds:**
- Minimum 5-6 folds for statistical validity
- For our 22-year dataset (2003-2025): recommend 8-10 folds
- Each fold should span different market regimes

**Walk-Forward Efficiency (WFE):**
- Formula: `WFE = OOS_Performance / IS_Performance`
- WFE > 50-60%: Strategy maintains robustness
- WFE approaching 100%: Investigate for overfitting (too good)
- WFE consistently low: Likely overfitting

**4-Stage Validation Framework:**
1. Traditional backtesting (eliminate flawed concepts)
2. Walk-forward analysis (validate across regimes)
3. Holdout sample (final 10-20% untouched)
4. Paper trading (3-6 months live data, no capital)

**Source:** https://surmount.ai/blogs/walk-forward-analysis-vs-backtesting-pros-cons-best-practices

---

### 2. Deflated Sharpe Ratio (DSR)

**Purpose:** Estimates probability that observed Sharpe Ratio is a true positive (not statistical fluke from multiple testing and non-normal returns).

**Formula:**
```
DSR = Phi[(SR - SR0) * sqrt(T-1) / sqrt(1 - skew*SR + ((kurtosis-1)/4)*SR^2)]
```

Where:
- `Phi` = CDF of standard normal distribution
- `SR` = observed annualized Sharpe Ratio
- `SR0` = expected maximum Sharpe under null (from N trials)
- `T` = backtest horizon (trading days)
- `skew`, `kurtosis` = sample moments of returns

**SR0 Approximation (critical):**
```
SR0 = sqrt(Var[SR]) * [(1-gamma) * Z^-1(1 - 1/N) + gamma * Z^-1(1 - 1/(N*e))]
```
- `N` = number of independent trials (ALL backtests run, not just best)
- Must track ALL optimization attempts

**Thresholds:**
| DSR Value | Interpretation |
|-----------|----------------|
| > 0.95 | High confidence (true positive) |
| > 0.80 | Practical threshold (recommended) |
| < 0.50 | Likely false positive (reject) |

**CRITICAL:** Must record ALL trials/backtests, not just successful ones. DSR is meaningless without accurate trial count.

**Python Implementation:**
```python
from scipy.stats import norm
import numpy as np

def deflated_sharpe_ratio(sharpe, sharpe_variance, n_trials, n_days, skew, kurtosis):
    """
    Compute Deflated Sharpe Ratio.

    Args:
        sharpe: Observed annualized Sharpe Ratio
        sharpe_variance: Variance of Sharpe across trials
        n_trials: Number of independent backtests/trials
        n_days: Backtest horizon in trading days
        skew: Sample skewness of returns
        kurtosis: Sample excess kurtosis of returns

    Returns:
        DSR: Probability that true SR > 0
    """
    # Expected max Sharpe under null hypothesis
    sr0 = np.sqrt(sharpe_variance) * (
        (1 - 0.5772) * norm.ppf(1 - 1/n_trials) +
        0.5772 * norm.ppf(1 - 1/(n_trials * np.e))
    )

    # DSR calculation
    numerator = (sharpe - sr0) * np.sqrt(n_days - 1)
    denominator = np.sqrt(1 - skew * sharpe + ((kurtosis - 1) / 4) * sharpe**2)

    return norm.cdf(numerator / denominator)
```

**Sources:**
- https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2460551 (Bailey & Lopez de Prado)
- https://www.davidhbailey.com/dhbpapers/deflated-sharpe.pdf

---

### 3. Probability of Backtest Overfitting (PBO)

**Definition:** PBO quantifies the risk that a backtested strategy profits from noise rather than signal.

**Methodology: Combinatorially Symmetric Cross-Validation (CSCV)**
1. Generate matrix: N strategies x T periods
2. Create many combinatorial IS/OOS splits (1000+)
3. For each split: select best IS strategy, compare OOS to mean OOS
4. PBO = proportion where best IS performer < avg OOS performance

**Key Outputs:**
- **PBO Value:** Probability of overfitting (0-1)
- **Performance Degradation:** Slope of IS vs OOS rank correlation
- **Stochastic Dominance:** Probability OOS outperforms threshold

**Thresholds:**
| PBO Value | Interpretation |
|-----------|----------------|
| < 15% | Excellent (low overfitting risk) |
| < 25% | Acceptable (our current gate) |
| 25-50% | Concerning (investigate) |
| > 50% | Likely overfit (reject) |

**Implementation Options:**
- R: `pbo` package (CRAN)
- Python: Custom implementation using numpy/scipy
- Requires: matrix of strategy returns across periods

**R Example:**
```r
require(pbo)
my_pbo <- pbo(m, s=8, f=sharpe, threshold=0)
summary(my_pbo)  # p_bo, slope, ar^2, p_loss
histogram(my_pbo, type="density")
xyplot(my_pbo, plotType="degradation")
```

**Sources:**
- https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2326253 (Bailey et al.)
- https://cran.r-project.org/web/packages/pbo/vignettes/pbo.html

---

### 4. Combinatorial Purged Cross-Validation (CPCV) vs Traditional WFA

**Why CPCV is Superior:**
Standard k-fold CV fails in finance due to:
- Autocorrelation in returns
- Non-IID data
- Look-ahead bias from adjacent folds

**CPCV Key Features:**
- **Purging:** Removes training observations overlapping with test signal calculation
- **Embargoing:** Adds buffer period after test set to prevent indirect leakage
- **Combinatorial:** Creates hundreds of backtest paths from diverse historical sequences

**Comparison:**
| Aspect | Traditional WFA | CPCV |
|--------|-----------------|------|
| Data leakage prevention | Partial | Comprehensive |
| Number of test paths | Limited (1 per fold) | Many (combinatorial) |
| Autocorrelation handling | Poor | Excellent |
| Implementation complexity | Simple | Moderate |
| Computational cost | Low | High (parallelizable) |

**skfolio Implementation:**
```python
from skfolio.model_selection import CombinatorialPurgedCV

cv = CombinatorialPurgedCV(
    n_folds=10,      # Total folds
    n_test_folds=2   # Test folds per combination
)

# View structure
print(cv.summary(X_train))

# Cross-validate
population = cross_val_predict(model, X_train, cv=cv)
```

**Recommendation:** Use CPCV for final validation, traditional WFA for initial development/filtering.

**Sources:**
- Lopez de Prado, "Advances in Financial Machine Learning" (2018)
- https://skfolio.org/generated/skfolio.model_selection.CombinatorialPurgedCV.html
- https://blog.quantinsti.com/cross-validation-embargo-purging-combinatorial/

---

### 5. Minimum Sample Size Requirements

**Academic Consensus:**
| Sample Size | Validity Level | Use Case |
|-------------|----------------|----------|
| 30 trades | Bare minimum | Initial screening only |
| 100 trades | Statistical significance | Basic validation |
| 200-300 trades | Meaningful metrics | Daily strategies |
| 1000+ trades | High confidence | Intraday strategies |

**Statistical Basis:**
- Cochran's formula: 70% confidence with 5% margin requires ~109 trades
- 95% confidence with 5% margin requires ~384 trades
- T-tests require n > 30 for CLT assumptions

**Beyond Trade Count:**
- Minimum time span: 5+ years (to capture regime changes)
- Must include: bull markets, bear markets, ranging periods
- Must include: high volatility, low volatility regimes

**Our Validation Gate (Updated Recommendation):**
```
sample_requirements:
  min_trades: 200
  min_years: 5
  required_regimes:
    - trend_up (min 1 period)
    - trend_down (min 1 period)
    - ranging (min 1 period)
    - high_volatility (min 1 period)
    - low_volatility (min 1 period)
```

**Sources:**
- https://gainium.io/blog/strategy-performance-metrics
- https://www.stat.berkeley.edu/~aldous/157/Papers/harvey.pdf (Harvey et al.)

---

### 6. Holdout Methodology

**Best Practices:**
- **Holdout size:** 20-30% of data (final block, never touched during development)
- **Time-ordered:** Must be contiguous future block, not random samples
- **Purpose:** Final "truth test" after all optimization

**Implementation:**
```
Total Data: 2003-2025 (22 years)
├── Development Set (80%): 2003-2020 (17 years)
│   ├── Training: used for optimization
│   └── WFA/CPCV validation: cross-validation folds
└── Holdout Set (20%): 2021-2025 (4+ years)
    └── NEVER touched until final validation
```

**Regime Change Handling:**
- Use rolling windows within development set
- In-sample lookback: 9-12 years (capture multiple regimes)
- If holdout contains unseen regime (e.g., 2022 inflation shock): acknowledge limitation
- Combine with Monte Carlo to stress-test regime robustness

**Critical Rules:**
1. NEVER optimize on holdout data
2. NEVER peek at holdout during development
3. Only ONE final test on holdout
4. If holdout fails, return to development (cannot re-test same holdout)

**Sources:**
- https://bsic.it/backtesting-series-episode-2-cross-validation-techniques/
- https://rpc.cfainstitute.org/sites/default/files/-/media/documents/article/rf-brief/investment-model-validation.pdf

---

### 7. Monte Carlo Validation

**Purpose:** Tests robustness beyond single historical path by randomizing trade sequences.

**Methodology:**
1. Run initial backtest to get trade list
2. Shuffle trade order (bootstrap resampling)
3. Run 1000+ iterations
4. Analyze distribution of outcomes

**Key Metrics:**
| Metric | Purpose |
|--------|---------|
| Equity curve distribution | Check consistency across paths |
| Expected return (mean) | Average performance |
| Max drawdown (95th percentile) | Worst-case risk |
| Win/loss ratio distribution | Stability check |

**Our Gate: MC95DD < 4%**
- 95th percentile max drawdown must be < 4%
- Provides buffer before Apex's 5% trailing DD limit
- Accounts for sequence risk not visible in single backtest

**Implementation Guidance:**
```python
def monte_carlo_backtest(trades: list, n_iterations: int = 1000) -> dict:
    """
    Monte Carlo simulation by shuffling trade order.

    Returns distribution of max drawdowns, final equity, etc.
    """
    results = []
    for _ in range(n_iterations):
        shuffled = np.random.permutation(trades)
        equity_curve = np.cumsum(shuffled)
        max_dd = calculate_max_drawdown(equity_curve)
        results.append({
            'max_dd': max_dd,
            'final_equity': equity_curve[-1],
            'min_equity': equity_curve.min()
        })

    return {
        'mc95_dd': np.percentile([r['max_dd'] for r in results], 95),
        'mc99_dd': np.percentile([r['max_dd'] for r in results], 99),
        'mean_final_equity': np.mean([r['final_equity'] for r in results])
    }
```

**Sources:**
- https://www.tradingheroes.com/monte-carlo-simulation-backtesting/
- https://www.blog.quantreo.com/monte-carlo-backtesting/

---

### 8. SQN (System Quality Number) Thresholds

**Van Tharp's SQN Formula:**
```
SQN = sqrt(min(N, 100)) * (mean_R / std_R)
```
Where:
- N = number of trades (capped at 100)
- mean_R = average R-multiple (profit/initial risk)
- std_R = standard deviation of R-multiples

**Interpretation:**
| SQN | Quality | Tradability |
|-----|---------|-------------|
| < 1.0 | Poor | Difficult to trade profitably |
| 1.0-1.99 | Below average | Challenging |
| 2.0-2.49 | Average | Workable with good sizing |
| 2.5-2.99 | Good | Reliable |
| 3.0-4.0 | Excellent | Easy to scale |
| > 4.0 | Outstanding | Very rare |

**Our Current Gate:** SQN >= 2.0 (Average)
**Recommendation:** Consider SQN >= 2.5 for production (Good)

**Limitations:**
- Punishes high-variance trend-following systems
- Requires R-multiple tracking (not just P&L)
- Use alongside other metrics

**Sources:**
- Van Tharp Institute: https://vantharpinstitute.com/
- https://indextrader.com.au/van-tharps-sqn/

---

### 9. Key Recommendations for Our Plan

Based on this research, we should update our validation methodology:

#### A. Update Validation Gates (CLAUDE.md ml_validation)

**Current:**
```yaml
approval_gate:
  WFE: >= 0.6
  SQN: >= 2.0
  PSR: >= 0.85
  DSR: > 0
  PBO: < 25%
  MC95DD: < 4%
```

**Recommended:**
```yaml
approval_gate:
  WFE: >= 0.60         # Keep (industry standard)
  SQN: >= 2.5          # Upgrade from 2.0 (Good vs Average)
  PSR: >= 0.85         # Keep (strong threshold)
  DSR: >= 0.80         # Upgrade from >0 (practical threshold)
  PBO: < 25%           # Keep (acceptable)
  MC95DD: < 4%         # Keep (Apex safety buffer)

sample_requirements:
  min_trades: 200
  min_years: 5
  holdout_pct: 20%     # ADD: untouched final validation
  required_regimes:    # ADD: regime diversity
    - trend
    - range
    - high_volatility
```

#### B. Implement CPCV

Replace or augment traditional WFA with CPCV:
- Use `skfolio.model_selection.CombinatorialPurgedCV`
- Configure: n_folds=10, n_test_folds=2
- Generates 45+ unique backtest paths

#### C. Trial Tracking for DSR

DSR requires tracking ALL optimization trials:
- Create `trial_registry.json` or database
- Log every backtest: parameters, Sharpe, returns
- Calculate DSR using total trial count

#### D. Holdout Protocol

Implement strict holdout:
- Reserve 2021-2025 data (4+ years) as holdout
- NEVER touch during development
- Single final validation test

#### E. Validation Pipeline

```
1. Development Phase (2003-2020 data)
   ├── Initial backtest (sanity check)
   ├── WFA with 8-10 rolling folds
   ├── CPCV validation (45+ paths)
   ├── DSR calculation (track all trials)
   ├── PBO calculation (CSCV method)
   └── Monte Carlo (1000+ iterations)

2. Final Validation (2021-2025 holdout)
   ├── Single backtest on holdout
   ├── Compare metrics to development
   ├── Performance degradation analysis
   └── GO/NO-GO decision

3. Paper Trading (3-6 months live data)
   ├── Real-time execution simulation
   ├── Slippage/spread verification
   └── Time gate verification
```

---

### 10. Implementation Priority

| Priority | Task | Effort | Impact |
|----------|------|--------|--------|
| P0 | Update DSR threshold to >= 0.80 | Low | High |
| P0 | Implement holdout split (20% reserved) | Medium | Critical |
| P1 | Add trial tracking for DSR validity | Medium | High |
| P1 | Implement CPCV with skfolio | Medium | High |
| P2 | Update SQN threshold to >= 2.5 | Low | Medium |
| P2 | Add regime diversity requirements | Medium | Medium |

---

### Sources (Full List)

1. Bailey, D.H. & Lopez de Prado, M. (2014). "The Deflated Sharpe Ratio" - https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2460551
2. Bailey, D.H. et al. (2014). "Probability of Backtest Overfitting" - https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2326253
3. Lopez de Prado, M. (2018). "Advances in Financial Machine Learning" - Wiley
4. skfolio Documentation - https://skfolio.org
5. CRAN pbo Package - https://cran.r-project.org/web/packages/pbo/vignettes/pbo.html
6. Van Tharp Institute - https://vantharpinstitute.com/
7. Walk-Forward Best Practices - https://surmount.ai/blogs/walk-forward-analysis-vs-backtesting-pros-cons-best-practices
8. QuantInsti CPCV Tutorial - https://blog.quantinsti.com/cross-validation-embargo-purging-combinatorial/
9. Bailey, D.H. et al. "Deflated Sharpe Ratio" - https://www.davidhbailey.com/dhbpapers/deflated-sharpe.pdf
10. Harvey, C.R. et al. "Backtesting" - https://www.stat.berkeley.edu/~aldous/157/Papers/harvey.pdf

---

**ARGUS Verdict:** MEDIUM-HIGH confidence. Research is comprehensive with authoritative sources (Lopez de Prado, academic papers, established libraries). Key gaps in our current methodology identified. Recommendations are actionable and aligned with Apex/XAUUSD constraints.

**Next Handoff:** ORACLE (implement updated validation gates) or FORGE (implement CPCV/DSR code)
