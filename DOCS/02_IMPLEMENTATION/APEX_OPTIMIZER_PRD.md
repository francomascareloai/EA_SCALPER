# Apex Optimizer - Product Requirements Document

**Version**: 1.0
**Author**: Franco / Claude
**Date**: 2024-12-24
**Status**: Draft

---

## 1. Executive Summary

### Problem Statement

O pipeline atual de otimização de parâmetros é fragmentado:
- Grid search → (manual) → WFA → (manual) → Monte Carlo → (manual) → GO/NO-GO
- Configs ruins consomem o mesmo compute que boas
- Sem busca adaptativa (Bayesian)
- WFA é pós-processo, não detecta overfitting durante busca
- Sem detecção automática de overfitting (cliffs, islands, regime bias)

### Solution

**Apex Optimizer**: Sistema unificado de otimização com:
- 3-layer architecture (Search → Validate → Stress)
- WFA inline durante busca (early-pruning de configs ruins)
- Optuna para busca Bayesian eficiente
- Apex compliance como constraint (não penalty)
- Auto-handoff para ORACLE/SENTINEL

### Success Metrics

| Metric | Target |
|--------|--------|
| Compute savings vs grid search | >50% (via early pruning) |
| False positive rate (overfitted configs) | <10% |
| Time to find top-5 candidates | <2h for 200 trials |
| Apex-compliant candidates per run | >20% |

---

## 2. Architecture

### 2.1 Three-Layer Design

```
┌─────────────────────────────────────────────────────────────────┐
│                      APEX OPTIMIZER                              │
├─────────────────────────────────────────────────────────────────┤
│  LAYER 1: SEARCH (Exploration)                                   │
│  ┌─────────────┬─────────────┬─────────────┬─────────────────┐  │
│  │    Grid     │   Random    │  Bayesian   │  Coarse-Fine    │  │
│  │  (<100)     │ (100-500)   │  (Optuna)   │  (Adaptive)     │  │
│  └─────────────┴─────────────┴─────────────┴─────────────────┘  │
│                              │                                   │
│                              ▼                                   │
├─────────────────────────────────────────────────────────────────┤
│  LAYER 2: VALIDATE (Inline WFA per candidate)                    │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ • 5-window rolling WFA                                      ││
│  │ • Early-prune if WFE < 0.5                                  ││
│  │ • Apex constraint check (DD, time gates, consistency)       ││
│  │ • Regime coverage check (trend/range/volatile)              ││
│  └─────────────────────────────────────────────────────────────┘│
│                              │                                   │
│                              ▼ (Top N only)                      │
├─────────────────────────────────────────────────────────────────┤
│  LAYER 3: STRESS (Robustness Testing)                            │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │ • Monte Carlo block bootstrap (5000 sims)                   ││
│  │ • Degradation test (winners→losers 10-30%)                  ││
│  │ • Overfitting detection (cliff/island/regime bias)          ││
│  │ • CPCV for PBO estimation                                   ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
              ┌───────────────────────────────┐
              │   Structured Handoff          │
              │   → ORACLE (validation)       │
              │   → SENTINEL (compliance)     │
              └───────────────────────────────┘
```

### 2.2 Module Structure

```
nautilus_gold_scalper/
└── src/
    └── optimization/
        ├── __init__.py
        ├── optimizer.py              # ApexOptimizer main class
        ├── config.py                 # YAML spec loader + validation
        │
        ├── search/
        │   ├── __init__.py
        │   ├── base.py               # SearchStrategy ABC
        │   ├── grid.py               # Cartesian grid search
        │   ├── random.py             # Latin Hypercube sampling (LHS-like)
        │   ├── bayesian.py           # Optuna TPE/CMA-ES
        │   └── successive_halving.py # Multi-fidelity (uses LHS-like generator)
        │
        ├── validation/
        │   ├── __init__.py
        │   ├── wfa_inline.py         # Inline WFA during search
        │   └── cpcv.py               # Combinatorial Purged CV
        │
        ├── stress/
        │   ├── __init__.py
        │   ├── monte_carlo.py        # MC block bootstrap
        │   └── degradation.py        # Winners→losers test
        │
        ├── constraints/
        │   ├── __init__.py
        │   ├── apex.py               # Apex compliance checker
        │   └── anti_overfit.py       # Cliff/island/regime detection
        │
        └── reporting/
            ├── __init__.py
            ├── summary.py            # JSON/CSV/Parquet reports
            └── handoff.py            # Structured handoff generator
```

---

## 3. Functional Requirements

### 3.1 YAML Configuration Spec

```yaml
# Example: nautilus_gold_scalper/configs/grids/smc_optimization.yaml

metadata:
  name: "SMC Strategy Optimization v1"
  version: "1.0"
  description: "Optimize SMC confluence and execution parameters"
  author: "Franco"
  created: "2024-12-24"

# ─────────────────────────────────────────────────────────────
# SEARCH CONFIGURATION
# ─────────────────────────────────────────────────────────────
search:
  mode: bayesian          # grid | random | lhs | bayesian | successive_halving

  # Bayesian-specific
  trials: 200             # Number of Optuna trials
  sampler: tpe            # tpe | cmaes | random

  # Grid-specific (ignored if mode != grid)
  max_grid_size: 1000     # Safety cap

  # Random-specific
  n_samples: 200          # For Latin Hypercube
  seed: 42

  # Execution
  parallelism: 4          # Concurrent trials (ProcessPool)
  timeout_per_trial: 300  # Seconds (5 min)

  # Early stopping
  early_stop:
    enabled: true
    patience: 30          # Stop if no improvement in N trials
    min_delta: 0.01       # Minimum improvement threshold
    plateau_trials: 50    # Stop if top-10 unchanged for N trials

# ─────────────────────────────────────────────────────────────
# PARAMETERS TO OPTIMIZE
# ─────────────────────────────────────────────────────────────
parameters:
  # Format: dotpath -> {type, range, step?, log_scale?, categorical?}

  # Confluence scoring weights
  confluence.scoring.weights.structure:
    type: float
    range: [0.15, 0.40]
    step: 0.05
    description: "Weight for structure/BOS signals"

  confluence.scoring.weights.liquidity:
    type: float
    range: [0.10, 0.35]
    step: 0.05
    description: "Weight for liquidity sweep signals"

  confluence.scoring.weights.fvg:
    type: float
    range: [0.10, 0.30]
    step: 0.05
    description: "Weight for FVG/imbalance signals"

  confluence.min_threshold:
    type: float
    range: [0.45, 0.75]
    step: 0.05
    description: "Minimum confluence score to trigger entry"

  # Execution parameters
  execution.atr_multiplier:
    type: float
    range: [1.5, 3.5]
    step: 0.25
    description: "ATR multiplier for SL distance"

  execution.sl_pips:
    type: int
    range: [15, 45]
    step: 5
    description: "Fixed SL in pips (fallback if ATR unavailable)"

  execution.tp_ratio:
    type: float
    range: [1.5, 3.0]
    step: 0.25
    description: "Risk:Reward ratio for TP"

  # Risk parameters
  risk.max_risk_pct:
    type: float
    range: [0.5, 2.0]
    step: 0.25
    description: "Max risk per trade as % of equity"

  # Session filters
  session.london_weight:
    type: float
    range: [0.8, 1.2]
    step: 0.1
    description: "Multiplier for London session trades"

  session.ny_weight:
    type: float
    range: [0.8, 1.2]
    step: 0.1
    description: "Multiplier for NY session trades"

# ─────────────────────────────────────────────────────────────
# FIXED PARAMETERS (not optimized)
# ─────────────────────────────────────────────────────────────
fixed:
  session.start: "08:00"
  session.end: "16:30"
  time_gate.block_new: "16:30"
  time_gate.force_close: "16:55"
  risk.max_positions: 1
  execution.slippage_pips: 1.0

# ─────────────────────────────────────────────────────────────
# CONSTRAINTS (hard limits)
# ─────────────────────────────────────────────────────────────
constraints:
  apex:
    trailing_dd_max: 4.5        # Buffer before 5% Apex limit
    daily_profit_max: 29.0      # Buffer before 30% consistency rule
    overnight_positions: 0      # Must be zero
    time_gate_violations: 0     # Must be zero

  validation:
    wfe_min: 0.6                # Walk-forward efficiency
    sqn_min: 2.0                # System Quality Number
    psr_min: 0.85               # Probabilistic Sharpe Ratio
    min_trades: 200             # Statistical significance
    min_years: 5                # Sample coverage

  anti_overfit:
    pbo_max: 0.25               # Probability of Backtest Overfitting
    mc95_dd_max: 4.0            # Monte Carlo 95th percentile DD

# ─────────────────────────────────────────────────────────────
# OBJECTIVE FUNCTION
# ─────────────────────────────────────────────────────────────
objective:
  direction: maximize

  # Primary metric or composite
  metric: composite             # sqn | sharpe | wfe | profit_factor | composite

  # Composite formula (if metric == composite)
  composite:
    sqn:
      weight: 0.40
      normalize: 5.0            # Cap at SQN=5 for normalization
    wfe:
      weight: 0.35
      normalize: 1.0            # Already 0-1
    consistency:
      weight: 0.25
      source: positive_days_ratio
      normalize: 1.0

  # Penalty factors (multiplicative)
  penalties:
    trailing_dd:
      threshold: 3.0            # Start penalizing above 3%
      decay_rate: 0.5           # Penalty = max(0, 1 - (dd-threshold)*rate)
    trades:
      min_required: 200
      penalty_below: 0.5        # Multiply score by 0.5 if <200 trades

# ─────────────────────────────────────────────────────────────
# INLINE VALIDATION (Layer 2)
# ─────────────────────────────────────────────────────────────
validation:
  inline_wfa:
    enabled: true
    windows: 5                  # Number of rolling windows
    is_ratio: 0.8               # In-sample ratio per window
    purge_days: 5               # Gap between IS and OOS
    embargo_days: 2             # Gap at end of OOS
    early_prune_wfe: 0.5        # Prune trial if WFE below this

  regime_check:
    enabled: true
    regimes: [trend, range, volatile]
    min_coverage: 0.7           # Each regime must have 70% of mean performance
    classifier: volatility      # volatility | hmm | hurst

# ─────────────────────────────────────────────────────────────
# STRESS TESTING (Layer 3 - Top N only)
# ─────────────────────────────────────────────────────────────
stress_test:
  enabled: true
  top_n: 5                      # Only stress top 5 candidates

  monte_carlo:
    enabled: true
    simulations: 5000
    block_bootstrap: true
    block_size: auto            # n^(1/3) heuristic
    confidence_levels: [0.95, 0.99]

  degradation:
    enabled: true
    rates: [0.10, 0.20, 0.30]   # Convert 10/20/30% winners to losers
    must_survive: 0.20          # Must survive 20% degradation

  overfitting_detection:
    cliff_check: true           # Check if best params at boundary
    island_check: true          # Check if best is isolated
    regime_bias_check: true     # Check regime coverage imbalance

# ─────────────────────────────────────────────────────────────
# DATA CONFIGURATION
# ─────────────────────────────────────────────────────────────
data:
  path: "data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet"

  # Train/test split (for final holdout validation)
  train_range:
    start: "2010-01-01"
    end: "2022-12-31"

  test_range:
    start: "2023-01-01"
    end: "2024-12-31"

  # WFA uses train_range only (test_range is final holdout)

# ─────────────────────────────────────────────────────────────
# OUTPUT CONFIGURATION
# ─────────────────────────────────────────────────────────────
output:
  dir: "logs/optimization"
  session_subfolder: true       # Create timestamped subfolder

  reports:
    - json                      # Full results
    - csv                       # Summary table
    - parquet                   # For further analysis

  artifacts:
    - params.json               # Per-trial params
    - metrics.json              # Per-trial metrics
    - wfa_details.json          # WFA window breakdown

  checkpointing:
    enabled: true
    interval: 10                # Checkpoint every N trials
    resume_on_restart: true

  handoff:
    enabled: true
    target_agents: [ORACLE, SENTINEL]
    format: markdown
```

### 3.2 Core Classes

#### 3.2.1 ApexOptimizer (Main Entry Point)

```python
from dataclasses import dataclass
from pathlib import Path
from typing import Literal

@dataclass
class OptimizationResult:
    """Result from a single optimization trial."""
    trial_id: int
    params: dict[str, object]

    # Performance metrics
    sqn: float
    sharpe: float
    sortino: float
    profit_factor: float
    total_pnl: float
    trades: int
    win_rate: float

    # Validation metrics
    wfe: float
    wfe_std: float
    regime_scores: dict[str, float]

    # Apex compliance
    trailing_dd: float
    daily_profit_max: float
    time_gate_violations: int
    overnight_positions: int
    apex_compliant: bool

    # Stress test (if run)
    mc_95_dd: float | None
    mc_99_dd: float | None
    degradation_survived: list[float] | None

    # Composite score
    score: float

    # Metadata
    output_dir: Path
    duration_seconds: float


class ApexOptimizer:
    """
    Unified optimization pipeline for Apex-compliant trading strategies.

    Usage:
        optimizer = ApexOptimizer.from_yaml("configs/grids/smc_optimization.yaml")
        results = optimizer.run()
        optimizer.generate_handoff("ORACLE")
    """

    def __init__(
        self,
        config: OptimizationConfig,
        backtest_runner: BacktestRunner,
    ) -> None:
        self.config = config
        self.runner = backtest_runner
        self._study: optuna.Study | None = None
        self._results: list[OptimizationResult] = []

    @classmethod
    def from_yaml(cls, path: str | Path) -> "ApexOptimizer":
        """Load configuration from YAML file."""
        config = OptimizationConfig.from_yaml(path)
        runner = BacktestRunner(
            initial_balance=50_000.0,
            product="xauusd",
            gateway="tradovate",
        )
        return cls(config, runner)

    def run(self) -> list[OptimizationResult]:
        """
        Execute full optimization pipeline:
        1. Layer 1: Search (grid/random/bayesian)
        2. Layer 2: Inline WFA validation
        3. Layer 3: Stress testing (top N only)
        """
        # Select search strategy
        searcher = self._create_searcher()

        # Run search with inline validation
        self._results = searcher.search(
            objective_fn=self._objective,
            constraint_fn=self._constraint,
        )

        # Stress test top N
        if self.config.stress_test.enabled:
            top_n = self._results[:self.config.stress_test.top_n]
            self._run_stress_tests(top_n)

        # Generate reports
        self._generate_reports()

        return self._results

    def _objective(self, trial: optuna.Trial) -> float:
        """Optuna objective function with inline WFA."""
        # Sample parameters
        params = self._sample_params(trial)

        # Run inline WFA
        wfa_result = self._run_inline_wfa(params)

        # Early pruning
        if wfa_result.wfe < self.config.validation.early_prune_wfe:
            raise optuna.TrialPruned()

        # Store user attributes for constraint function
        trial.set_user_attr("trailing_dd", wfa_result.trailing_dd)
        trial.set_user_attr("wfe", wfa_result.wfe)
        trial.set_user_attr("trades", wfa_result.trades)

        # Compute composite score
        return self._compute_composite_score(wfa_result)

    def _constraint(self, trial: optuna.FrozenTrial) -> list[float]:
        """Constraint function for Apex compliance."""
        return [
            trial.user_attrs["trailing_dd"] - self.config.constraints.apex.trailing_dd_max,
            -trial.user_attrs["wfe"] + self.config.constraints.validation.wfe_min,
            self.config.constraints.validation.min_trades - trial.user_attrs["trades"],
        ]

    def generate_handoff(self, target: Literal["ORACLE", "SENTINEL"]) -> str:
        """Generate structured handoff document for target agent."""
        return HandoffGenerator.generate(
            results=self._results,
            config=self.config,
            target=target,
        )
```

#### 3.2.2 Composite Score Function

```python
def compute_composite_score(
    result: WFAResult,
    config: ObjectiveConfig,
) -> float:
    """
    Multi-objective scoring that balances performance, robustness, and compliance.

    Formula: weighted_sum(normalized_metrics) * penalty_factors

    Args:
        result: WFA validation result with all metrics
        config: Objective configuration with weights and thresholds

    Returns:
        Composite score in range [0, 1] (higher is better)
    """
    # ─────────────────────────────────────────────────────────
    # Step 1: Normalize base metrics to [0, 1]
    # ─────────────────────────────────────────────────────────

    # SQN: cap at configured max (typically 5.0)
    # Formula: sqn_norm = min(sqn / sqn_max, 1.0)
    # Example: sqn=3.5, max=5.0 → 3.5/5.0 = 0.70
    sqn_norm = min(result.sqn / config.composite.sqn.normalize, 1.0)

    # WFE: already in [0, 1] range
    wfe_norm = result.wfe

    # Consistency: positive days ratio, already in [0, 1]
    consistency_norm = result.positive_days_ratio

    # ─────────────────────────────────────────────────────────
    # Step 2: Weighted sum
    # ─────────────────────────────────────────────────────────

    # Formula: base = w_sqn*sqn_norm + w_wfe*wfe_norm + w_cons*cons_norm
    # Example: 0.4*0.70 + 0.35*0.65 + 0.25*0.80 = 0.28 + 0.23 + 0.20 = 0.71
    base_score = (
        config.composite.sqn.weight * sqn_norm +
        config.composite.wfe.weight * wfe_norm +
        config.composite.consistency.weight * consistency_norm
    )

    # ─────────────────────────────────────────────────────────
    # Step 3: Apply penalty factors (multiplicative)
    # ─────────────────────────────────────────────────────────

    # DD penalty: linear decay above threshold
    # Formula: penalty = max(0, 1 - (dd - threshold) * decay_rate)
    # Example: dd=3.8%, threshold=3.0%, rate=0.5 → 1 - (3.8-3.0)*0.5 = 0.60
    dd_threshold = config.penalties.trailing_dd.threshold
    dd_decay = config.penalties.trailing_dd.decay_rate
    if result.trailing_dd <= dd_threshold:
        dd_penalty = 1.0
    else:
        dd_penalty = max(0.0, 1.0 - (result.trailing_dd - dd_threshold) * dd_decay)

    # Trades penalty: hard cutoff below minimum
    # Formula: penalty = 1.0 if trades >= min else fixed_penalty
    # Example: trades=150, min=200, penalty=0.5 → 0.5
    trades_min = config.penalties.trades.min_required
    trades_penalty_value = config.penalties.trades.penalty_below
    trades_penalty = 1.0 if result.trades >= trades_min else trades_penalty_value

    # ─────────────────────────────────────────────────────────
    # Step 4: Final score
    # ─────────────────────────────────────────────────────────

    # Formula: final = base * dd_penalty * trades_penalty
    # Example: 0.71 * 0.60 * 1.0 = 0.426
    final_score = base_score * dd_penalty * trades_penalty

    # Assert valid range
    assert 0.0 <= final_score <= 1.0, f"Invalid score: {final_score}"

    return final_score
```

### 3.3 CLI Interface

```bash
# ─────────────────────────────────────────────────────────────
# Quick exploration (Bayesian, 100 trials)
# ─────────────────────────────────────────────────────────────
python -m nautilus_gold_scalper.optimize \
    --config configs/grids/smc_optimization.yaml \
    --mode bayesian \
    --trials 100 \
    --parallelism 4

# ─────────────────────────────────────────────────────────────
# Full grid search (small parameter space)
# ─────────────────────────────────────────────────────────────
python -m nautilus_gold_scalper.optimize \
    --config configs/grids/smc_optimization.yaml \
    --mode grid \
    --dry-run  # Just show grid size, don't execute

# ─────────────────────────────────────────────────────────────
# Successive halving (multi-fidelity)
# ─────────────────────────────────────────────────────────────
python -m nautilus_gold_scalper.optimize \
    --config configs/grids/smc_optimization.yaml \
    --mode successive_halving \
    --trials 200

# ─────────────────────────────────────────────────────────────
# Stress test existing results
# ─────────────────────────────────────────────────────────────
python -m nautilus_gold_scalper.optimize \
    --stress-only \
    --input logs/optimization/20241224_123456/summary.json \
    --top 5 \
    --mc-sims 5000

# ─────────────────────────────────────────────────────────────
# Resume from checkpoint
# ─────────────────────────────────────────────────────────────
python -m nautilus_gold_scalper.optimize \
    --resume logs/optimization/20241224_123456/checkpoint.json

# ─────────────────────────────────────────────────────────────
# Generate handoff for ORACLE
# ─────────────────────────────────────────────────────────────
python -m nautilus_gold_scalper.optimize \
    --handoff ORACLE \
    --input logs/optimization/20241224_123456/summary.json
```

---

## 4. Non-Functional Requirements

### 4.1 Performance

| Metric | Target | Rationale |
|--------|--------|-----------|
| Single trial execution | <60s | Fast feedback loop |
| Inline WFA (5 windows) | <30s | Must not dominate trial time |
| 200 Bayesian trials | <2h | Reasonable wait for results |
| Monte Carlo (5000 sims) | <5min per config | Stress testing is post-filter |
| Memory per worker | <4GB | Run 4 workers on 16GB machine |

### 4.2 Reliability

| Requirement | Implementation |
|-------------|----------------|
| Crash recovery | Checkpoint every 10 trials |
| Timeout handling | Kill trial after 5min, log, continue |
| Fail-fast | Abort if 5 consecutive failures |
| Data integrity | Atomic writes to checkpoint/results |

### 4.3 Observability

| Requirement | Implementation |
|-------------|----------------|
| Progress tracking | tqdm + periodic logging |
| Trial details | Per-trial JSON in output dir |
| Optuna dashboard | Optional --dashboard flag |
| Structured logs | JSON logging with trial_id |

---

## 5. Apex Compliance Integration

### 5.1 Constraint Checks (Layer 2)

Every trial MUST check these Apex constraints:

| Constraint | Threshold | Action if Violated |
|------------|-----------|-------------------|
| Trailing DD | ≥4.5% | Return -999 score |
| Daily profit max | ≥30% | Return -999 score |
| Time gate violations | >0 | Return -999 score |
| Overnight positions | >0 | Return -999 score |

### 5.2 Validation Gates (Layer 2)

Trials must pass BEFORE stress testing:

| Gate | Threshold | Action if Failed |
|------|-----------|-----------------|
| WFE | <0.5 | Prune trial early |
| SQN | <1.5 | Prune trial early |
| Trades | <100 | Prune trial early |

### 5.3 Stress Gates (Layer 3)

Final candidates must pass:

| Gate | Threshold | Consequence |
|------|-----------|-------------|
| MC 95% DD | ≥4.0% | Mark as HIGH_RISK |
| Degradation 20% | Not survived | Mark as FRAGILE |
| PBO | >25% | Mark as LIKELY_OVERFIT |

---

## 6. Anti-Overfitting Detection

### 6.1 Parameter Cliff Detection

```python
def detect_cliff(
    best_params: dict[str, float],
    param_ranges: dict[str, tuple[float, float]],
) -> list[str]:
    """
    Detect if best parameters are at range boundaries.

    If optimum is at edge, we may not have found true optimum.
    """
    warnings = []
    for param, value in best_params.items():
        if param not in param_ranges:
            continue
        lo, hi = param_ranges[param]
        tolerance = (hi - lo) * 0.05  # 5% of range

        if abs(value - lo) < tolerance:
            warnings.append(f"CLIFF_LOW: {param}={value} near min={lo}")
        elif abs(value - hi) < tolerance:
            warnings.append(f"CLIFF_HIGH: {param}={value} near max={hi}")

    return warnings
```

### 6.2 Island Detection

```python
def detect_island(
    results: list[OptimizationResult],
    top_k: int = 1,
    neighbor_threshold: float = 1.5,
) -> list[str]:
    """
    Detect if top configs are isolated "islands" with poor neighbors.

    A good optimum should have decent neighbors - isolated peaks are suspicious.
    """
    warnings = []

    for i, result in enumerate(results[:top_k]):
        # Find neighbors (within 10% of each param)
        neighbors = find_param_neighbors(result, results, tolerance=0.1)

        if len(neighbors) < 3:
            warnings.append(f"SPARSE: Config {i} has <3 neighbors")
            continue

        neighbor_scores = [n.score for n in neighbors]
        mean_neighbor = sum(neighbor_scores) / len(neighbor_scores)

        if result.score > mean_neighbor * neighbor_threshold:
            warnings.append(
                f"ISLAND: Config {i} score={result.score:.3f} >> "
                f"neighbor_mean={mean_neighbor:.3f}"
            )

    return warnings
```

### 6.3 Regime Bias Detection

```python
def detect_regime_bias(
    result: OptimizationResult,
    min_coverage: float = 0.7,
) -> list[str]:
    """
    Detect if config only works in specific market regimes.

    Good strategies should work across trend/range/volatile conditions.
    """
    warnings = []

    regime_scores = result.regime_scores  # {"trend": 0.8, "range": 0.4, "volatile": 0.6}
    mean_score = sum(regime_scores.values()) / len(regime_scores)

    for regime, score in regime_scores.items():
        coverage = score / mean_score if mean_score > 0 else 0
        if coverage < min_coverage:
            warnings.append(
                f"REGIME_BIAS: {regime} score={score:.3f} is "
                f"{coverage:.1%} of mean={mean_score:.3f}"
            )

    return warnings
```

---

## 7. Structured Handoff Format

```markdown
## HANDOFF: APEX_OPTIMIZER → ORACLE

### Run Metadata
- **Run ID**: opt_20241224_143052
- **Config**: configs/grids/smc_optimization.yaml
- **Mode**: Bayesian (TPE)
- **Trials**: 200 completed, 12 pruned
- **Duration**: 1h 47min
- **Apex Compliant**: 156/200 (78%)

### Search Space Summary
| Parameter | Range | Best Value |
|-----------|-------|------------|
| confluence.min_threshold | [0.45, 0.75] | 0.60 |
| execution.atr_multiplier | [1.5, 3.5] | 2.25 |
| execution.tp_ratio | [1.5, 3.0] | 2.0 |
| risk.max_risk_pct | [0.5, 2.0] | 1.0 |

### Top 5 Candidates (Apex-Compliant)

| Rank | Score | SQN | WFE | DD% | Trades | Consistency |
|------|-------|-----|-----|-----|--------|-------------|
| 1 | 0.782 | 3.4 | 0.72 | 2.8 | 423 | 0.76 |
| 2 | 0.756 | 3.1 | 0.68 | 3.1 | 389 | 0.74 |
| 3 | 0.741 | 2.9 | 0.71 | 2.5 | 412 | 0.71 |
| 4 | 0.728 | 3.2 | 0.65 | 3.3 | 356 | 0.73 |
| 5 | 0.715 | 2.8 | 0.69 | 2.9 | 401 | 0.70 |

### Apex Rejection Summary
| Reason | Count |
|--------|-------|
| Trailing DD ≥ 4.5% | 28 |
| WFE < 0.6 | 12 |
| Trades < 200 | 4 |

### Overfitting Analysis
- **Cliff Detection**: CLEAR (no params at boundaries)
- **Island Detection**: CLEAR (top configs have similar neighbors)
- **Regime Bias**: WARNING - Config #3 underperforms in range markets

### Stress Test Results (Top 5)

| Rank | MC 95% DD | MC 99% DD | Degr. 20% | PBO |
|------|-----------|-----------|-----------|-----|
| 1 | 3.2% | 4.1% | PASS | 18% |
| 2 | 3.5% | 4.4% | PASS | 21% |
| 3 | 3.1% | 3.9% | FAIL | 24% |
| 4 | 3.8% | 4.8% | PASS | 19% |
| 5 | 3.4% | 4.2% | PASS | 22% |

### Recommendations for ORACLE
1. **Validate Config #1 and #2** with full CPCV (they have best stress results)
2. **Investigate Config #3** regime bias in range markets
3. **Skip Config #4** - MC 99% DD of 4.8% is too close to Apex limit
4. Run full 10-year WFA on Configs #1, #2, #5

### Files Generated
- `summary.json` - Full results
- `top5_params.json` - Top 5 config params
- `wfa_details/` - Per-config WFA breakdown
- `stress_results/` - MC and degradation data

### Next Agent Should
- [ ] Run CPCV validation on Configs #1, #2
- [ ] Perform regime-specific analysis on Config #3
- [ ] Generate final GO/NO-GO recommendation
```

---

## 8. Implementation Phases

### Phase 1: Core Infrastructure (MVP)
**Effort**: 500-700 LOC
**Duration**: ~2 sessions

| Component | Description | Priority |
|-----------|-------------|----------|
| `optimizer.py` | ApexOptimizer main class | P0 |
| `config.py` | YAML loader + validation | P0 |
| `bayesian.py` | Optuna integration | P0 |
| `wfa_inline.py` | Inline WFA (5 windows) | P0 |
| `apex.py` | Apex constraint checker | P0 |
| `summary.py` | JSON/CSV report generation | P1 |

**Deliverables**:
- Working Bayesian search with inline WFA
- Apex compliance as hard constraint
- Basic reporting

### Phase 2: Robustness Layer
**Effort**: 300-400 LOC
**Duration**: ~1 session

| Component | Description | Priority |
|-----------|-------------|----------|
| `monte_carlo.py` | MC block bootstrap (adapt existing) | P0 |
| `degradation.py` | Winners→losers test | P1 |
| `anti_overfit.py` | Cliff/island/regime detection | P1 |
| `cpcv.py` | Combinatorial Purged CV | P2 |

**Deliverables**:
- Monte Carlo stress testing
- Overfitting detection suite
- Enhanced confidence scoring

### Phase 3: Production Features
**Effort**: 400-500 LOC
**Duration**: ~1-2 sessions

| Component | Description | Priority |
|-----------|-------------|----------|
| Distributed execution | ProcessPool → Dask/Ray | P1 |
| `handoff.py` | Structured handoff generator | P0 |
| Dashboard | Optuna Dashboard integration | P2 |
| Checkpointing | Resume from crash | P1 |
| CLI polish | argparse improvements | P2 |

**Deliverables**:
- Auto-handoff to ORACLE/SENTINEL
- Crash recovery
- Optional visualization dashboard

---

## 9. Dependencies

### Required (Phase 1)
```
optuna>=3.0.0          # Bayesian optimization
pandas>=2.0.0          # Data manipulation
pyyaml>=6.0            # Config loading
tqdm>=4.60.0           # Progress bars
```

### Optional (Phase 2-3)
```
optuna-dashboard       # Web UI for Optuna
dask[distributed]      # Distributed execution
scikit-learn           # For CPCV, regime classification
scipy                  # Statistical tests
```

---

## 10. Risks and Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Optuna version incompatibility | HIGH | LOW | Pin version, test on install |
| WFA inline too slow | MEDIUM | MEDIUM | Reduce windows (3 vs 5), parallel |
| Memory overflow on large grids | HIGH | MEDIUM | Enforce grid caps, batch processing |
| False positive from early pruning | MEDIUM | LOW | Conservative prune threshold (0.5) |
| Overfitting to validation set | HIGH | MEDIUM | Final holdout test mandatory |

---

## 11. Success Criteria

### Phase 1 Complete When:
- [ ] Can run 100 Bayesian trials via CLI
- [ ] Inline WFA runs and prunes correctly
- [ ] Apex violations are rejected
- [ ] JSON report is generated
- [ ] All tests pass

### Phase 2 Complete When:
- [ ] Monte Carlo stress test runs on top N
- [ ] Overfitting detection flags suspicious configs
- [ ] Stress results included in reports

### Phase 3 Complete When:
- [ ] Handoff document auto-generated
- [ ] Can resume from checkpoint
- [ ] Dashboard available (optional)

---

## 12. Open Questions

1. **CPCV window count**: How many combinatorial paths? (affects compute significantly)
2. **Regime classifier**: Use HMM or simple volatility bins?
3. **Dashboard**: Worth the dependency overhead for this project?
4. **Distributed**: Dask vs Ray vs simple multiprocessing?

---

## Appendix A: Existing Code Reuse

| Existing File | Reuse Strategy |
|---------------|----------------|
| `grid_search_eval20d.py` | Extract dotpath logic, ranking |
| `walk_forward.py` | Adapt WalkForwardAnalyzer for inline |
| `monte_carlo.py` | Direct import/adapt |
| `rigorous_validator.py` | Reference for metric calculation |
| `scale-runner.md` | Design patterns, handoff format |

---

## Appendix B: Glossary

| Term | Definition |
|------|------------|
| WFE | Walk-Forward Efficiency: OOS_performance / IS_performance |
| SQN | System Quality Number: mean(returns) / std(returns) * sqrt(N) |
| PSR | Probabilistic Sharpe Ratio: P(true Sharpe > 0) |
| PBO | Probability of Backtest Overfitting |
| CPCV | Combinatorial Purged Cross-Validation |
| TPE | Tree-structured Parzen Estimator (Optuna default) |
| HWM | High-Water Mark (peak equity, never decreases in session) |
