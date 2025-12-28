# Phase 12-11: Advanced Optimization Roadmap

**Date:** 2025-12-28
**Version:** 1.0
**Status:** PLANNED (awaiting review)
**Sources:** ARGUS Research + CRITIC Adversarial Review
**Philosophy:** FALSIFICATION-FIRST | CONSTRAINT-BEFORE-OBJECTIVE | SURVIVAL > RETURNS

---

## Executive Summary

This document consolidates findings from ARGUS (state-of-the-art research) and CRITIC (adversarial review) to create a comprehensive optimization improvement roadmap. The goal is to transform the optimization pipeline into a "combat machine" - robust, efficient, and aligned with Apex survival constraints.

### Key Insight

> "Optimizing the optimizer is higher ROI than optimizing the strategy."

Current system has **critical gaps** identified by CRITIC that could cause real losses, plus **high-impact opportunities** identified by ARGUS that could 3-10x efficiency.

---

## TIER 1: CRITICAL FIXES (Security Bugs)

These are **bugs that could cause real losses**. Must fix before any new optimization runs.

### 1.1 Apex-Aware Promotion in Bars Mode

**Problem:** Multi-fidelity promotion is biased. Bars rungs don't apply Apex constraints, promoting "good-in-bars / dead-in-ticks" configs.

**Location:** `src/optimization/search/successive_halving.py:142`

```python
# CURRENT (BROKEN):
if constraint_fn is not None and str(feed_mode) == "ticks":
    constraints = constraint_fn(result)
    # Only applies constraints in ticks mode!
```

**Fix Required:**
- Apply time gate checks (4:30 PM block, overnight) even in bars mode
- Bars have timestamps - can detect violations
- Don't promote configs that would die in ticks

**Impact:** CRITICAL - without this, we're optimizing for the wrong objective
**Effort:** 4-6 hours
**Priority:** P0 (BLOCKER)

---

### 1.2 Stress Gates Fail-Closed

**Problem:** Exceptions in PBO/MC95DD/ghost test result in "continue without" - safety rails silently disappear.

**Location:** `src/optimization/optimizer.py:475`, `:518`

```python
# CURRENT (FAIL-OPEN):
except Exception:
    logger.exception("Failed to compute PBO")
    # Continues without PBO gate!
```

**Fix Required:**
- If stress gate is ENABLED but fails to compute → mark candidates as BLOCKED
- Never silently proceed without safety gates
- Log CRITICAL warning when stress gate fails

**Impact:** CRITICAL - false sense of security
**Effort:** 2-4 hours
**Priority:** P0 (BLOCKER)

---

### 1.3 Rank Correlation Validation

**Problem:** We trust multi-fidelity promotion without measuring if low-fidelity actually correlates with high-fidelity.

**CRITIC Finding:**
> "If correlation is actually low/negative in volatile regimes, adaptive promotion is actively harmful."

**Location:** `src/optimization/adaptive_fidelity.py:125` sets `rank_correlation=0.5` by fiat, not measured.

**Fix Required:**
- Before trusting multi-fidelity: measure Spearman(rung0, rungN) on a calibration cohort
- If correlation < 0.3: don't use low-fidelity for pruning
- Log correlation metrics for auditing

**Validation Test:**
```python
# Pick 50 configs, run rung0 and last rung, compute correlation
def validate_fidelity_correlation(configs: list, n_sample: int = 50) -> float:
    sample = random.sample(configs, min(n_sample, len(configs)))
    scores_rung0 = [run_rung0(c) for c in sample]
    scores_rungN = [run_rungN(c) for c in sample]
    correlation, pvalue = spearmanr(scores_rung0, scores_rungN)

    if correlation < 0.3:
        logger.critical(f"Low fidelity correlation: {correlation:.2f} - multi-fidelity INVALID")
        return False
    return True
```

**Impact:** CRITICAL - invalid multi-fidelity wastes compute and promotes bad configs
**Effort:** 4-6 hours
**Priority:** P0 (BLOCKER)

---

## TIER 2: HIGH IMPACT IMPROVEMENTS

These provide significant ROI and should be implemented after TIER 1 fixes.

### 2.1 Constraint-First Scoring (PSR/CVaR/Omega)

**ARGUS Finding:** Impact 9/10, highest ROI improvement

**Problem:** Current scoring optimizes profit without survival constraints baked in. Configs can "look good" but violate Apex constraints.

**Solution:** Constraint-first scalarization:
1. FIRST: Check hard constraints (PBO, MC95DD, Apex DD, min_trades)
2. If ANY violated → score = -999 (eliminated)
3. ONLY for feasible set: optimize advanced metrics

**Advanced Metrics to Implement:**

#### Probabilistic Sharpe Ratio (PSR)
```python
def probabilistic_sharpe_ratio(returns: np.ndarray, sr_threshold: float = 0.0) -> float:
    """
    Probability that true Sharpe exceeds threshold.

    Formula: PSR(SR*) = Φ((SR_obs - SR*) / σ(SR))
    where σ(SR) = √((1 + γ₃·SR/2 + (γ₄-3)·SR²/4) / n)

    Penalizes:
    - Negative skewness (fat left tail)
    - Excess kurtosis (extreme events)
    - Small sample size
    """
    n = len(returns)
    if n < 20:
        return 0.0

    sr_obs = returns.mean() / returns.std() * np.sqrt(252)  # Annualized
    skew = scipy.stats.skew(returns)
    kurt = scipy.stats.kurtosis(returns)  # Excess kurtosis

    # Standard error of Sharpe ratio
    sr_std = np.sqrt((1 + 0.5 * skew * sr_obs + (kurt / 4) * sr_obs**2) / n)

    # Probability true SR > threshold
    psr = scipy.stats.norm.cdf((sr_obs - sr_threshold) / sr_std)
    return float(psr)
```

#### Conditional Value at Risk (CVaR)
```python
def conditional_var(returns: np.ndarray, alpha: float = 0.05) -> float:
    """
    Expected loss in worst alpha% of cases.

    Formula: CVaR_α = E[Loss | Loss > VaR_α]

    Directly optimizes tail risk - aligns with Apex "survival-first".
    """
    var = np.percentile(returns, alpha * 100)
    cvar = returns[returns <= var].mean()
    return float(-cvar)  # Return as positive number (risk measure)
```

#### Omega Ratio
```python
def omega_ratio(returns: np.ndarray, threshold: float = 0.0) -> float:
    """
    Ratio of gains above threshold to losses below.

    Formula: Omega(τ) = ∫[τ,∞] (1-F(r)) dr / ∫[-∞,τ] F(r) dr

    Captures ALL moments (not just mean/variance like Sharpe).
    Better for fat-tailed return distributions.
    """
    gains = returns[returns > threshold] - threshold
    losses = threshold - returns[returns <= threshold]

    if losses.sum() == 0:
        return float('inf')

    return float(gains.sum() / losses.sum())
```

#### Modified Kelly Fraction
```python
def modified_kelly(win_rate: float, avg_win: float, avg_loss: float,
                   dd_buffer: float = 0.04, max_dd: float = 0.05) -> float:
    """
    Kelly fraction with Apex DD safety buffer.

    Formula: f* = (p·b - q) / b · (1 - DD_buffer/max_DD)

    where:
    - p = win rate
    - b = avg_win / avg_loss (odds)
    - q = 1 - p
    - DD_buffer = current distance to Apex limit
    """
    if avg_loss == 0:
        return 0.0

    b = avg_win / avg_loss
    q = 1 - win_rate
    kelly = (win_rate * b - q) / b

    # Scale down as approaching DD limit
    safety_factor = 1 - (dd_buffer / max_dd)

    return float(max(0, kelly * safety_factor * 0.5))  # Half-Kelly for safety
```

**Composite Score Formula:**
```python
def constraint_first_score(result: TrialResult) -> float:
    """
    Constraint-first scoring: feasibility THEN optimality.
    """
    # HARD CONSTRAINTS (elimination)
    if result.pbo > 0.25:  # >25% probability of backtest overfit
        return -999.0
    if result.mc_95_dd >= 0.04:  # 95th percentile DD >= 4%
        return -999.0
    if result.max_trailing_dd >= 0.04:
        return -999.0
    if result.trades < 20:  # Statistical significance
        return -999.0
    if not result.apex_compliant:
        return -999.0

    # SOFT OPTIMIZATION (for feasible configs only)
    psr = probabilistic_sharpe_ratio(result.returns, sr_threshold=0.5)
    omega = omega_ratio(result.returns, threshold=0.0)
    cvar = conditional_var(result.returns, alpha=0.05)

    # Weighted combination (survival-focused)
    score = (
        0.40 * psr +                    # Confidence in edge
        0.30 * min(omega / 3.0, 1.0) +  # Gain/loss ratio (capped)
        0.20 * (1 - cvar / 0.05) +      # Tail risk (lower is better)
        0.10 * result.wfe               # Walk-forward efficiency
    )

    return float(score)
```

**Impact:** 9/10 - fundamentally changes what we optimize for
**Effort:** 1-2 days
**Priority:** P1 (HIGH)

---

### 2.2 CMA-ES Refinement Stage

**ARGUS Finding:** Impact 8/10, Low effort (already imported!)

**Problem:** After ASHA/SH produces elites, we stop. Local refinement could polish them further.

**Discovery:** CMA-ES is already imported in our codebase!
```python
# /src/optimization/search/bayesian.py:20
from optuna.samplers import CmaEsSampler, RandomSampler, TPESampler
```

**Solution:** Add CMA-ES as final refinement stage:
1. ASHA/SH produces top-10 elites
2. CMA-ES refines each elite in local neighborhood
3. Use highest-fidelity (ticks) for refinement
4. Only refine Apex-compliant configs

**Implementation:**
```python
class CMAESRefinementStage:
    """Local refinement of elites using CMA-ES."""

    def __init__(self, config: OptimizationConfig, n_refinement_trials: int = 50):
        self.config = config
        self.n_trials = n_refinement_trials

    def refine_elite(self, elite_params: dict, objective_fn: Callable) -> dict:
        """Refine a single elite configuration."""

        # Create study with CMA-ES sampler centered on elite
        sampler = CmaEsSampler(
            seed=self.config.search.seed,
            x0=elite_params,  # Start from elite
            sigma0=0.1,       # Small step size (local search)
        )

        study = optuna.create_study(
            direction="maximize",
            sampler=sampler,
        )

        def optuna_objective(trial):
            params = self._sample_around_elite(trial, elite_params)
            result = objective_fn(params)
            return result.score

        study.optimize(optuna_objective, n_trials=self.n_trials)
        return study.best_params

    def _sample_around_elite(self, trial, elite: dict) -> dict:
        """Sample parameters in neighborhood of elite."""
        params = {}
        for spec in self.config.parameters:
            if spec.param_type == "float" and spec.range:
                low, high = spec.range
                elite_val = elite.get(spec.name, (low + high) / 2)
                # Narrow range around elite (±20% of range)
                width = (high - low) * 0.2
                narrow_low = max(low, elite_val - width)
                narrow_high = min(high, elite_val + width)
                params[spec.name] = trial.suggest_float(spec.name, narrow_low, narrow_high)
            # ... handle other types
        return params
```

**Impact:** 8/10 - polishes elites for extra edge
**Effort:** 4-6 hours (already have dependency)
**Priority:** P1 (HIGH)

---

### 2.3 Random Signal Baseline Test (Ghost Test v2)

**CRITIC Finding:** Current ghost test doesn't falsify signals

> "Ghost test permutes existing trades; it cannot falsify 'signals add edge' if trade selection itself is the edge."

**Problem:** We need to know if our signals add value or if filters do all the work.

**Solution:** Two-part falsification:

**Test A (Current):** Permute trade PnL ordering → tests path-dependence
**Test B (NEW):** Random signal with same filters → tests signal value

```python
class RandomSignalBaseline:
    """
    Falsification test: do signals add edge beyond filters?

    Runs strategy with:
    - Same time gates (4:30 PM block, overnight)
    - Same regime filters
    - Same session filters
    - Same spread/slippage model
    - RANDOM entry direction
    """

    def __init__(self, strategy: Strategy, n_simulations: int = 100):
        self.strategy = strategy
        self.n_simulations = n_simulations

    def run_baseline(self, data: pd.DataFrame) -> BaselineResult:
        """Run random signal baseline."""
        results = []

        for seed in range(self.n_simulations):
            rng = np.random.default_rng(seed)

            # Use all original filters but random direction
            baseline_strategy = self._create_random_signal_strategy(rng)
            result = backtest(data, baseline_strategy)
            results.append(result)

        return BaselineResult(
            mean_sharpe=np.mean([r.sharpe for r in results]),
            std_sharpe=np.std([r.sharpe for r in results]),
            apex_survival_rate=np.mean([r.apex_compliant for r in results]),
        )

    def is_signal_valuable(self, real_result: TrialResult,
                           baseline: BaselineResult) -> tuple[bool, float]:
        """
        Test if real signal beats random baseline.

        Returns (is_valuable, p_value)
        """
        # Z-test: is real Sharpe significantly better than baseline?
        z = (real_result.sharpe - baseline.mean_sharpe) / baseline.std_sharpe
        p_value = 1 - scipy.stats.norm.cdf(z)

        is_valuable = p_value < 0.05 and z > 1.0
        return is_valuable, p_value
```

**Interpretation:**
- If random baseline ≈ real strategy (p ≥ 0.05): **signals are placebo**
- If random baseline << real strategy (p < 0.05): **signals add edge**

**Impact:** 8/10 - prevents optimizing noise
**Effort:** 1-2 days
**Priority:** P1 (HIGH)

---

### 2.4 HEBO Sampler via OptunaHub

**ARGUS Finding:** Impact 7/10, won NeurIPS 2020 BBO Challenge

**What is HEBO?**
- Heteroscedastic Evolutionary Bayesian Optimization
- Handles noisy + non-stationary objectives better than TPE
- Uses input/output warping for robustness

**Integration Path:**
```python
# pip install optunahub
import optunahub

class HEBOSearch(SearchStrategy):
    """HEBO-based search using OptunaHub."""

    def search(self, objective_fn, constraint_fn=None):
        # Load HEBO sampler from OptunaHub
        hebo_module = optunahub.load_module("samplers/hebo")
        sampler = hebo_module.HEBOSampler(seed=self.config.search.seed)

        study = optuna.create_study(
            direction="maximize",
            sampler=sampler,
        )

        # ... rest of search logic
```

**When to Use:**
- Noisy objectives (high variance in backtest results)
- Non-stationary search spaces
- When TPE seems to get stuck

**Impact:** 7/10 - better exploration in noisy landscapes
**Effort:** 4-6 hours
**Priority:** P2 (MEDIUM)

---

## TIER 3: FUTURE ENHANCEMENTS

These are valuable but require more effort or have dependencies.

### 3.1 TuRBO (Trust Region BO)

**What:** Local Bayesian optimization with adaptive trust regions
**When:** High-dimensional parameter spaces (>20 params)
**Library:** BoTorch
**Effort:** HIGH
**Priority:** P3

### 3.2 RGPE Meta-Learning

**What:** Ensemble surrogates from past optimization runs
**When:** After defining "task similarity" and curating warm-start archives
**Library:** BoTorch / automl/transfer-hpo-framework
**Effort:** HIGH
**Priority:** P3

### 3.3 Population-Based Training (PBT)

**What:** DeepMind's asynchronous evolutionary scheme
**When:** ONLY if we can checkpoint/resume partial backtests
**Verdict:** NO-GO for current backtest architecture
**Priority:** P4 (DEFERRED)

---

## FALSIFICATION TESTS

Before trusting any optimization result, run these tests:

### Test 1: Fidelity Validity
```
CLAIM: "Low-fidelity ranks correlate with tick/Apex ranks."
METHOD: 50 configs, run rung0 + last rung, compute Spearman
FAIL: correlation < 0.3 OR top-5 overlap < 2/5
```

### Test 2: Apex HWM Trap Realism
```
CLAIM: "Prescreen doesn't select HWM-trap configs."
METHOD: Top-10 after prescreen, run 1-week ticks with conservative marking
FAIL: Any config breaches trailing DD buffer (≥4.0%)
```

### Test 3: Edge Attribution
```
CLAIM: "Signals add edge beyond filters."
METHOD: Random signal baseline with identical filters
FAIL: Random performance within noise (p ≥ 0.05)
```

### Test 4: Sampler Placebo
```
CLAIM: "Sobol is better than random/LHS for THIS objective."
METHOD: 128 trials × 10 seeds, compare best Apex-compliant score
FAIL: No statistically meaningful improvement (p ≥ 0.05)
```

### Test 5: Execution Hostility
```
CLAIM: "Chosen configs survive realistic friction."
METHOD: Rerun top configs with 2-3x spread, 5x slippage
FAIL: MC95DD ≥ 4% OR frequent time-gate misses
```

---

## Implementation Order

```
PHASE 1: CRITICAL FIXES (Week 1)
├── 1.1 Apex-aware promotion in bars [P0]
├── 1.2 Stress gates fail-closed [P0]
└── 1.3 Rank correlation validation [P0]

PHASE 2: HIGH IMPACT (Week 2-3)
├── 2.1 Constraint-first scoring (PSR/CVaR) [P1]
├── 2.2 CMA-ES refinement stage [P1]
└── 2.3 Random signal baseline test [P1]

PHASE 3: ENHANCEMENTS (Week 4+)
├── 2.4 HEBO sampler [P2]
├── 3.1 TuRBO for high-dim [P3]
└── 3.2 RGPE meta-learning [P3]
```

---

## Success Criteria

After implementing TIER 1 + TIER 2:

| Metric | Before | Target |
|--------|--------|--------|
| Fidelity rank correlation | Unknown | ≥ 0.5 |
| Apex survival rate (optimized configs) | ~30% | ≥ 70% |
| False positive rate (signals) | Unknown | Measured |
| Optimization efficiency | Baseline | +3-5x |
| Stress gate reliability | Fail-open | Fail-closed |

---

## References

### Papers
- Bailey & López de Prado (2012) - "The Sharpe Ratio Efficient Frontier"
- Rockafellar & Uryasev (2000) - "Optimization of Conditional Value-at-Risk"
- Keating & Shadwick (2002) - "A Universal Performance Measure" (Omega)
- Hansen (2016) - "The CMA Evolution Strategy: A Tutorial"
- Falkner et al. (2018) - "BOHB: Robust and Efficient Hyperparameter Optimization"
- Cowen-Rivers et al. (2020) - "HEBO: Heteroscedastic Evolutionary Bayesian Optimization"
- Eriksson et al. (2019) - "Scalable Global Optimization via Local Bayesian Optimization" (TuRBO)

### Code
- Optuna: https://optuna.org/
- OptunaHub HEBO: https://hub.optuna.org/samplers/hebo/
- pycma: https://github.com/CMA-ES/pycma
- BoTorch: https://botorch.org/

---

**AGENT:** ORCHESTRATOR
**VERSION:** 1.0
**CLAUDE_MD_VERSION:** 3.10.30
**STATUS:** PLANNED (awaiting Franco review)

---

*"The best optimizer is the one that knows when NOT to trade."* — CRITIC

*End of Optimization Roadmap*
