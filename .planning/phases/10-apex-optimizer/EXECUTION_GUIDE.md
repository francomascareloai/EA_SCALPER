# Phase 10: Apex Optimizer - Execution Guide

## Overview
Este guia contém instruções passo-a-passo para completar os trabalhos pendentes da Fase 10.

**Status Atual:** ~75% completo
**Prioridade:** 10-05 (Critical) → 10-03 (High) → 10-06 (Medium) → 10-01 (Low)

---

## Quick Reference

```bash
# Validation commands (run after EVERY change)
./.venv/bin/pytest -q nautilus_gold_scalper/tests/test_optimization/
./.venv/bin/mypy --strict nautilus_gold_scalper/src/optimization
```

---

## Priority 1: Plan 10-05 - Anti-Overfit Detectors (CRITICAL)

### Status: ❌ NOT STARTED

### What to Implement

#### Task 1: Create `anti_overfit.py`

**File:** `nautilus_gold_scalper/src/optimization/constraints/anti_overfit.py`

```python
"""Anti-overfit detection for optimization results."""
from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from src.optimization.search.base import TrialResult
    from src.optimization.config import ParameterSpec

@dataclass
class OverfitWarning:
    """Warning about potential overfitting."""
    type: str  # CLIFF_LOW, CLIFF_HIGH, ISLAND, REGIME_BIAS
    parameter: str | None
    severity: str  # WARN, CRITICAL
    message: str


def detect_cliff(
    best_params: dict[str, float],
    param_specs: list[ParameterSpec],
    tolerance: float = 0.05,
) -> list[OverfitWarning]:
    """
    Detect if best params are at edge of parameter range.

    Args:
        best_params: The optimized parameters
        param_specs: Parameter specifications with min/max
        tolerance: How close to edge is "cliff" (default 5%)

    Returns:
        List of CLIFF_LOW or CLIFF_HIGH warnings
    """
    warnings = []
    for spec in param_specs:
        if spec.name not in best_params:
            continue
        value = best_params[spec.name]
        range_size = spec.max - spec.min

        # Check low edge
        if (value - spec.min) / range_size < tolerance:
            warnings.append(OverfitWarning(
                type="CLIFF_LOW",
                parameter=spec.name,
                severity="WARN",
                message=f"{spec.name}={value:.4f} is within {tolerance*100:.0f}% of min={spec.min}"
            ))

        # Check high edge
        if (spec.max - value) / range_size < tolerance:
            warnings.append(OverfitWarning(
                type="CLIFF_HIGH",
                parameter=spec.name,
                severity="WARN",
                message=f"{spec.name}={value:.4f} is within {tolerance*100:.0f}% of max={spec.max}"
            ))

    return warnings


def detect_island(
    results: list[TrialResult],
    top_k: int = 5,
    neighbor_threshold: float = 0.10,
) -> list[OverfitWarning]:
    """
    Detect if best result is isolated (no good neighbors).

    Args:
        results: All trial results sorted by score
        top_k: How many top results to check
        neighbor_threshold: Parameter distance threshold (default 10%)

    Returns:
        List of ISLAND warnings if best is isolated
    """
    warnings = []
    if len(results) < top_k + 1:
        return warnings

    best = results[0]
    top_results = results[1:top_k+1]

    # Check if any top result is "close" to best
    has_neighbor = False
    for result in top_results:
        if _params_are_close(best.params, result.params, neighbor_threshold):
            has_neighbor = True
            break

    if not has_neighbor:
        warnings.append(OverfitWarning(
            type="ISLAND",
            parameter=None,
            severity="CRITICAL",
            message=f"Best result has no neighbors in top {top_k+1} within {neighbor_threshold*100:.0f}% param distance"
        ))

    return warnings


def detect_regime_bias(
    result: TrialResult,
    min_coverage: float = 0.20,
) -> list[OverfitWarning]:
    """
    Detect if result performs well only in specific regime.

    Args:
        result: Trial result with regime_scores dict
        min_coverage: Minimum performance ratio vs best regime (default 20%)

    Returns:
        List of REGIME_BIAS warnings
    """
    warnings = []

    # Check if regime_scores available
    if not hasattr(result, 'regime_scores') or not result.regime_scores:
        return warnings  # Degrade gracefully - no warning if data unavailable

    scores = result.regime_scores
    if not scores:
        return warnings

    max_score = max(scores.values())
    if max_score <= 0:
        return warnings

    for regime, score in scores.items():
        ratio = score / max_score if max_score > 0 else 0
        if ratio < min_coverage:
            warnings.append(OverfitWarning(
                type="REGIME_BIAS",
                parameter=None,
                severity="WARN",
                message=f"Regime '{regime}' has only {ratio*100:.1f}% of best regime performance"
            ))

    return warnings


def _params_are_close(
    params1: dict[str, float],
    params2: dict[str, float],
    threshold: float,
) -> bool:
    """Check if two param sets are within threshold distance."""
    common_keys = set(params1.keys()) & set(params2.keys())
    if not common_keys:
        return False

    for key in common_keys:
        v1, v2 = params1[key], params2[key]
        if v1 == 0 and v2 == 0:
            continue
        max_val = max(abs(v1), abs(v2))
        if abs(v1 - v2) / max_val > threshold:
            return False

    return True
```

#### Task 2: Integrate into optimizer.py

Add after stress testing (around line 400):

```python
# Run anti-overfit detection for top candidates
if self.config.stress_test.overfitting_detection.enabled:
    from src.optimization.constraints.anti_overfit import (
        detect_cliff, detect_island, detect_regime_bias, OverfitWarning
    )

    for r in candidates:
        warnings: list[OverfitWarning] = []
        warnings.extend(detect_cliff(r.params, self.config.parameters))
        warnings.extend(detect_island(candidates))
        warnings.extend(detect_regime_bias(r))
        r.overfit_warnings = warnings  # Add field to TrialResult
```

#### Task 3: Create tests

**File:** `nautilus_gold_scalper/tests/test_optimization/test_anti_overfit.py`

```python
"""Tests for anti-overfit detection."""
import pytest
from src.optimization.constraints.anti_overfit import (
    detect_cliff, detect_island, detect_regime_bias, OverfitWarning
)

class TestDetectCliff:
    def test_cliff_low_detected(self):
        # param at 2% of range should trigger
        ...

    def test_cliff_high_detected(self):
        # param at 98% of range should trigger
        ...

    def test_no_cliff_in_middle(self):
        # param at 50% should NOT trigger
        ...

class TestDetectIsland:
    def test_island_detected_when_isolated(self):
        ...

    def test_no_island_with_neighbors(self):
        ...

class TestDetectRegimeBias:
    def test_regime_bias_detected(self):
        ...

    def test_graceful_degradation_no_regime_scores(self):
        ...
```

### Validation
```bash
./.venv/bin/pytest -q nautilus_gold_scalper/tests/test_optimization/test_anti_overfit.py
./.venv/bin/mypy --strict nautilus_gold_scalper/src/optimization/constraints/anti_overfit.py
```

---

## Priority 2: Plan 10-03 - Constraint Tests (HIGH)

### Status: ⚠️ Implementation done, tests missing

### What to Create

**File:** `nautilus_gold_scalper/tests/test_optimization/test_constraints_semantics.py`

```python
"""Tests for Apex constraint semantics - edge cases."""
import pytest
from src.optimization.constraints.apex import ApexConstraintChecker
from src.optimization.search.base import TrialResult

class TestTrailingDDLimits:
    """Test trailing DD at exact boundaries."""

    def test_trailing_dd_exactly_at_limit(self):
        """4.5% trailing DD should still pass (just at HALT threshold)."""
        checker = ApexConstraintChecker()
        result = _make_result(trailing_dd=4.5)
        values = checker.get_constraint_values(result)
        # Should be exactly 0 (on the line)
        assert values[0] == 0.0

    def test_trailing_dd_below_limit(self):
        """4.49% should pass with margin."""
        checker = ApexConstraintChecker()
        result = _make_result(trailing_dd=4.49)
        values = checker.get_constraint_values(result)
        assert values[0] < 0  # Negative = satisfied

    def test_trailing_dd_above_limit(self):
        """4.51% should FAIL."""
        checker = ApexConstraintChecker()
        result = _make_result(trailing_dd=4.51)
        values = checker.get_constraint_values(result)
        assert values[0] > 0  # Positive = violated

class TestDailyProfitMax:
    def test_daily_profit_at_limit(self):
        """30% daily profit should be at limit."""
        ...

    def test_daily_profit_above_limit(self):
        """31% daily profit should FAIL."""
        ...

class TestTimeGateViolations:
    def test_zero_violations_passes(self):
        ...

    def test_one_violation_fails(self):
        """Any time_gate_violations > 0 should FAIL."""
        ...

class TestOvernightPositions:
    def test_zero_overnight_passes(self):
        ...

    def test_one_overnight_fails(self):
        """Any overnight_positions > 0 should FAIL."""
        ...

class TestWFEMinimum:
    def test_wfe_at_minimum(self):
        """WFE = 0.6 should pass."""
        ...

    def test_wfe_below_minimum(self):
        """WFE = 0.59 should FAIL."""
        ...

class TestTradesMinimum:
    def test_trades_at_minimum(self):
        """200 trades should pass."""
        ...

    def test_trades_below_minimum(self):
        """199 trades should FAIL."""
        ...

def _make_result(**kwargs) -> TrialResult:
    """Helper to create TrialResult with defaults."""
    defaults = {
        'trial_id': 1,
        'params': {},
        'score': 1.0,
        'sharpe': 1.0,
        'wfe': 0.7,
        'trades': 250,
        'trailing_dd': 3.0,
        'daily_dd': 1.5,
        'daily_profit_max': 15.0,
        'time_gate_violations': 0,
        'overnight_positions': 0,
        'apex_compliant': True,
    }
    defaults.update(kwargs)
    return TrialResult(**defaults)
```

### Validation
```bash
./.venv/bin/pytest -q nautilus_gold_scalper/tests/test_optimization/test_constraints_semantics.py -v
```

---

## Priority 3: Plan 10-06 - Stratification (MEDIUM)

### Status: ⚠️ Ghost Test done, Stratification placeholder

### What to Implement

#### Add Stratification Computation in optimizer.py

Around line 500, after ghost test:

```python
# Compute stratification summary if trades have session/regime columns
stratification_summary = None
if self.config.stress_test.stratification.enabled:
    stratification_summary = self._compute_stratification(candidates[0])

def _compute_stratification(self, result: TrialResult) -> dict[str, dict[str, float]] | None:
    """Compute performance breakdown by session/regime."""
    trades_df = self._last_trades_df  # Need to cache this during backtest
    if trades_df is None:
        return None

    summary = {}

    # By session (if column exists)
    if 'session' in trades_df.columns:
        session_stats = trades_df.groupby('session')['pnl'].agg(['sum', 'count', 'mean'])
        summary['session'] = session_stats.to_dict('index')

    # By regime (if column exists)
    if 'regime' in trades_df.columns:
        regime_stats = trades_df.groupby('regime')['pnl'].agg(['sum', 'count', 'mean'])
        summary['regime'] = regime_stats.to_dict('index')

    return summary if summary else None
```

---

## Priority 4: Plan 10-01 - Cleanup (LOW)

### Decision: Keep Alternative Implementation

The backtest integration works via `scripts/optimize.py`. Options:

**Option A (Recommended):** Document the alternative path
- Update `src/optimization/__main__.py` to redirect to `scripts/optimize.py`
- Create `10-01-SUMMARY.md` explaining the decision

**Option B:** Refactor to match original plan
- Extract `create_backtest_fn()` to `backtest_adapter.py`
- Wire into `__main__.py`
- More work, unclear benefit

### Quick Fix for __main__.py

Replace placeholder (lines 205-217) with:

```python
print("=" * 60)
print("NOTE: For full optimization with backtest, use:")
print("  python scripts/optimize.py --config <yaml> [--mode <mode>]")
print("")
print("This CLI (src.optimization.__main__) is for dry-run/validation only.")
print("=" * 60)
```

---

## Execution Order Summary

```
┌─────────────────────────────────────────────────────────────┐
│  Step 1: Plan 10-05 (CRITICAL)                              │
│  - Create anti_overfit.py                                   │
│  - Add overfit_warnings to TrialResult                      │
│  - Create test_anti_overfit.py                              │
│  - Run: pytest + mypy                                       │
├─────────────────────────────────────────────────────────────┤
│  Step 2: Plan 10-03 (HIGH)                                  │
│  - Create test_constraints_semantics.py                     │
│  - Run: pytest                                              │
├─────────────────────────────────────────────────────────────┤
│  Step 3: Plan 10-06 (MEDIUM)                                │
│  - Implement _compute_stratification()                      │
│  - Wire into handoff                                        │
│  - Create test_handoff_format.py                            │
│  - Run: pytest + mypy                                       │
├─────────────────────────────────────────────────────────────┤
│  Step 4: Plan 10-01 (LOW)                                   │
│  - Update __main__.py placeholder                           │
│  - Create 10-01-SUMMARY.md                                  │
├─────────────────────────────────────────────────────────────┤
│  Step 5: Create Missing Summaries                           │
│  - 10-03-SUMMARY.md                                         │
│  - 10-04-SUMMARY.md                                         │
│  - 10-05-SUMMARY.md                                         │
│  - 10-06-SUMMARY.md                                         │
└─────────────────────────────────────────────────────────────┘
```

---

## Final Validation Checklist

```bash
# All tests pass
./.venv/bin/pytest -q

# Type checking passes
./.venv/bin/mypy --strict nautilus_gold_scalper/src/optimization

# Dry-run works
python -m nautilus_gold_scalper.src.optimization \
  --config nautilus_gold_scalper/configs/grids/smc_optimization.yaml \
  --dry-run

# Full optimization works (via scripts/)
python scripts/optimize.py \
  --config nautilus_gold_scalper/configs/grids/smc_optimization_fast.yaml \
  --mode successive_halving \
  --dry-run
```

---

## Files to Create/Modify

| File | Action | Priority |
|------|--------|----------|
| `src/optimization/constraints/anti_overfit.py` | CREATE | CRITICAL |
| `src/optimization/search/base.py` | MODIFY (add overfit_warnings field) | CRITICAL |
| `src/optimization/optimizer.py` | MODIFY (wire anti-overfit) | CRITICAL |
| `tests/test_optimization/test_anti_overfit.py` | CREATE | CRITICAL |
| `tests/test_optimization/test_constraints_semantics.py` | CREATE | HIGH |
| `src/optimization/optimizer.py` | MODIFY (stratification) | MEDIUM |
| `tests/test_optimization/test_handoff_format.py` | CREATE | MEDIUM |
| `src/optimization/__main__.py` | MODIFY (update placeholder) | LOW |
| `10-01-SUMMARY.md` | CREATE | LOW |
| `10-03-SUMMARY.md` | CREATE | LOW |
| `10-04-SUMMARY.md` | CREATE | LOW |
| `10-05-SUMMARY.md` | CREATE | LOW |
| `10-06-SUMMARY.md` | CREATE | LOW |

---

*Generated: 2025-12-28*
