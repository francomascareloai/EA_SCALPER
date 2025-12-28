"""BOHB (Bayesian Optimization + Hyperband) search strategy.

Combines TPE-based Bayesian optimization with Hyperband's multi-fidelity
resource allocation for efficient hyperparameter optimization.

Key benefits:
- ~3-10x faster than standard Bayesian optimization
- Automatic early stopping of poor configurations
- Better exploration via multi-fidelity evaluation

This implementation uses Optuna's HyperbandPruner with TPE sampler.
"""

from __future__ import annotations

import logging
import threading
import time
from collections.abc import Callable
from typing import Any

import optuna
from optuna.pruners import HyperbandPruner
from optuna.samplers import TPESampler

from src.optimization.config import OptimizationConfig
from src.optimization.search.base import (
    ConstraintFn,
    ObjectiveFn,
    SearchStrategy,
    TrialResult,
)

logger = logging.getLogger(__name__)


class BOHBSearch(SearchStrategy):
    """BOHB (Bayesian Optimization + Hyperband) search strategy.

    Combines:
    - TPE sampler for intelligent parameter suggestion
    - HyperbandPruner for multi-fidelity resource allocation

    This is typically 3-10x faster than pure Bayesian optimization
    for the same quality of results.
    """

    def __init__(
        self,
        config: OptimizationConfig,
        *,
        on_result: Callable[[TrialResult], None] | None = None,
        max_results_in_ram: int | None = None,
        objective_fn_with_fidelity: (
            Callable[[dict[str, Any], str, str, int, str, str | None], TrialResult] | None
        ) = None,
        min_resource: int = 1,
        max_resource: int = 5,
        reduction_factor: int = 3,
    ) -> None:
        """Initialize BOHB search.

        Args:
            config: Optimization configuration
            on_result: Optional callback for each result
            max_results_in_ram: Cap on results kept in memory
            objective_fn_with_fidelity: Fidelity-aware objective function
            min_resource: Minimum resource (WFA windows) for early evaluation
            max_resource: Maximum resource (WFA windows) for full evaluation
            reduction_factor: Hyperband reduction factor (eta)
        """
        super().__init__(config, on_result=on_result, max_results_in_ram=max_results_in_ram)
        self._objective_fidelity = objective_fn_with_fidelity
        self._study: optuna.Study | None = None
        self._start_time: float = 0.0
        self._results_lock = threading.Lock()
        self._bohb_results: list[TrialResult] = []  # Separate list for BOHB

        # Hyperband parameters
        self._min_resource = min_resource
        self._max_resource = max_resource
        self._reduction_factor = reduction_factor

    def search(
        self,
        objective_fn: ObjectiveFn,
        constraint_fn: ConstraintFn | None = None,
    ) -> list[TrialResult]:
        """Execute BOHB search.

        Args:
            objective_fn: Fallback objective function (used if fidelity-aware not provided)
            constraint_fn: Optional constraint function for Apex compliance

        Returns:
            List of TrialResult sorted by score (best first)
        """
        self._start_time = time.time()
        self._bohb_results = []

        # Create TPE sampler with good defaults for BOHB
        sampler = TPESampler(
            seed=self.config.search.seed,
            n_startup_trials=max(5, self._min_resource * 2),
            multivariate=True,
        )

        # Create Hyperband pruner
        # n_brackets controls the number of Hyperband brackets
        # More brackets = more exploration, fewer = more exploitation
        pruner = HyperbandPruner(
            min_resource=self._min_resource,
            max_resource=self._max_resource,
            reduction_factor=self._reduction_factor,
        )

        self._study = optuna.create_study(
            direction="maximize",
            sampler=sampler,
            pruner=pruner,
            study_name=f"{self.config.name}_bohb",
        )

        def optuna_objective(trial: optuna.Trial) -> float:
            return self._run_trial(trial, objective_fn, constraint_fn)

        # Calculate timeout
        timeout = self.config.search.timeout_per_trial * self.config.search.trials

        try:
            self._study.optimize(
                optuna_objective,
                n_trials=self.config.search.trials,
                n_jobs=1,  # Force single-threaded for reproducibility
                timeout=timeout,
                show_progress_bar=True,
                catch=(Exception,),
            )
        except KeyboardInterrupt:
            logger.warning("BOHB optimization interrupted by user")

        # Sort results by score (best first)
        self._bohb_results.sort(key=lambda r: r.score, reverse=True)
        return self._bohb_results

    def _run_trial(
        self,
        trial: optuna.Trial,
        objective_fn: ObjectiveFn,
        constraint_fn: ConstraintFn | None,
    ) -> float:
        """Run a single BOHB trial with multi-fidelity evaluation."""
        start_time = time.time()

        try:
            params = self._sample_params(trial)

            # Determine resource level based on trial state
            # Hyperband will suggest intermediate reports to decide pruning
            for resource in range(self._min_resource, self._max_resource + 1):
                # Compute WFA windows for this resource level
                wfa_windows = resource

                # Run evaluation at current fidelity
                if self._objective_fidelity is not None:
                    result = self._objective_fidelity(
                        params,
                        self.config.data.train_start,
                        self.config.data.train_end,
                        wfa_windows,
                        "ticks",
                        None,
                    )
                else:
                    result = objective_fn(params)

                # Report intermediate value for pruning decision
                trial.report(result.score, resource)

                # Check if should prune
                if trial.should_prune():
                    # Record pruned result
                    pruned_result = self._create_result(
                        trial.number, params, result, start_time, pruned=True
                    )
                    with self._results_lock:
                        self._record_result(pruned_result)
                        self._bohb_results.append(pruned_result)
                    raise optuna.TrialPruned()

            # Final evaluation completed - record result
            final_result = self._create_result(
                trial.number, params, result, start_time, pruned=False
            )

            # Apply constraints
            if constraint_fn is not None:
                constraints = constraint_fn(result)
                trial.set_user_attr("constraints", constraints)
                if any(c > 0 for c in constraints):
                    final_result.apex_compliant = False
                    final_result.score = -999.0

            with self._results_lock:
                self._record_result(final_result)
                self._bohb_results.append(final_result)

            return float(final_result.score)

        except optuna.TrialPruned:
            raise

        except Exception:
            logger.error("BOHB trial %s failed", trial.number, exc_info=True)
            return -999.0

    def _sample_params(self, trial: optuna.Trial) -> dict[str, Any]:
        """Sample parameters from Optuna trial."""
        params: dict[str, Any] = {}

        for spec in self.config.parameters:
            if spec.param_type == "float":
                if spec.range is None:
                    raise ValueError(f"spec.range required for float parameter '{spec.name}'")
                low, high = spec.range
                if spec.step:
                    value = trial.suggest_float(spec.name, low, high, step=spec.step)
                elif spec.log_scale:
                    value = trial.suggest_float(spec.name, low, high, log=True)
                else:
                    value = trial.suggest_float(spec.name, low, high)
                params[spec.name] = value

            elif spec.param_type == "int":
                if spec.range is None:
                    raise ValueError(f"spec.range required for int parameter '{spec.name}'")
                low, high = int(spec.range[0]), int(spec.range[1])
                step = int(spec.step) if spec.step else 1
                params[spec.name] = trial.suggest_int(spec.name, low, high, step=step)

            elif spec.param_type == "categorical":
                if spec.choices is None:
                    raise ValueError(
                        f"spec.choices required for categorical parameter '{spec.name}'"
                    )
                params[spec.name] = trial.suggest_categorical(spec.name, spec.choices)

        return params

    def _create_result(
        self,
        trial_id: int,
        params: dict[str, Any],
        result: TrialResult,
        start_time: float,
        *,
        pruned: bool,
    ) -> TrialResult:
        """Create a TrialResult with proper metadata."""
        return TrialResult(
            trial_id=trial_id,
            params=params,
            sqn=result.sqn,
            sharpe=result.sharpe,
            sortino=result.sortino,
            profit_factor=result.profit_factor,
            total_pnl=result.total_pnl,
            trades=result.trades,
            win_rate=result.win_rate,
            max_drawdown_pct=result.max_drawdown_pct,
            wfe=result.wfe,
            wfe_std=result.wfe_std,
            positive_days_ratio=result.positive_days_ratio,
            regime_scores=result.regime_scores,
            trailing_dd=result.trailing_dd,
            daily_profit_max=result.daily_profit_max,
            daily_dd=result.daily_dd,
            time_gate_violations=result.time_gate_violations,
            overnight_positions=result.overnight_positions,
            apex_compliant=result.apex_compliant,
            score=result.score if not pruned else -999.0,
            duration_seconds=time.time() - start_time,
            pruned=pruned,
        )

    def get_best_params(self) -> dict[str, Any]:
        """Get best parameters found during search."""
        if self._study is None or self._study.best_trial is None:
            return {}
        return dict(self._study.best_trial.params)

    def get_study_summary(self) -> dict[str, Any]:
        """Get summary statistics from the search."""
        if self._study is None:
            return {}

        trials = self._study.trials
        complete = [t for t in trials if t.state == optuna.trial.TrialState.COMPLETE]
        pruned = [t for t in trials if t.state == optuna.trial.TrialState.PRUNED]
        failed = [t for t in trials if t.state == optuna.trial.TrialState.FAIL]

        return {
            "n_trials": len(trials),
            "n_complete": len(complete),
            "n_pruned": len(pruned),
            "n_failed": len(failed),
            "best_value": self._study.best_value if self._study.best_trial else None,
            "best_params": self.get_best_params(),
            "duration_seconds": time.time() - self._start_time,
            "mode": "bohb",
            "min_resource": self._min_resource,
            "max_resource": self._max_resource,
            "reduction_factor": self._reduction_factor,
        }
