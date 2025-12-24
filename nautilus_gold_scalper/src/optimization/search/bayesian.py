"""
Bayesian optimization using Optuna.

Implements Tree-structured Parzen Estimator (TPE) search with:
- Apex compliance as hard constraints
- WFA-based pruning for early termination
- Composite objective function
"""

from __future__ import annotations

import logging
import time
from concurrent.futures import ProcessPoolExecutor, TimeoutError as FuturesTimeoutError
from dataclasses import dataclass
from typing import TYPE_CHECKING, Any, Callable

import optuna
from optuna.samplers import TPESampler, CmaEsSampler, RandomSampler
from optuna.pruners import MedianPruner

from src.optimization.config import (
    OptimizationConfig,
    ParameterSpec,
)
from src.optimization.search.base import (
    SearchStrategy,
    TrialResult,
    ObjectiveFn,
    ConstraintFn,
)

if TYPE_CHECKING:
    pass


logger = logging.getLogger(__name__)


@dataclass
class OptunaStudyStats:
    """Statistics from Optuna study."""

    n_trials: int
    n_complete: int
    n_pruned: int
    n_failed: int
    best_value: float
    best_params: dict[str, Any]
    duration_seconds: float


class BayesianSearch(SearchStrategy):
    """
    Bayesian optimization search using Optuna TPE.

    Features:
    - TPE sampler for efficient parameter space exploration
    - Constraint-based optimization for Apex compliance
    - Median pruner for early stopping of bad trials
    - Parallel trial execution
    """

    def __init__(
        self,
        config: OptimizationConfig,
        objective_fn: Callable[[dict[str, Any]], TrialResult] | None = None,
    ) -> None:
        """
        Initialize Bayesian search.

        Args:
            config: Optimization configuration
            objective_fn: Optional objective function to use
        """
        super().__init__(config)
        self._study: optuna.Study | None = None
        self._results: list[TrialResult] = []
        self._objective_fn = objective_fn
        self._start_time: float = 0.0

    def search(
        self,
        objective_fn: ObjectiveFn,
        constraint_fn: ConstraintFn | None = None,
    ) -> list[TrialResult]:
        """
        Execute Bayesian search.

        Args:
            objective_fn: Function that takes params dict and returns TrialResult
            constraint_fn: Optional function that returns constraint violations

        Returns:
            List of TrialResult sorted by score (best first)
        """
        self._objective_fn = objective_fn
        self._results = []
        self._start_time = time.time()

        # Create sampler based on config
        sampler = self._create_sampler()

        # Create pruner for early stopping
        pruner = MedianPruner(
            n_startup_trials=5,
            n_warmup_steps=3,
            interval_steps=1,
        )

        # Create study
        # Note: constraints_func is set on sampler if using TPE with constraints
        self._study = optuna.create_study(
            direction="maximize",
            sampler=sampler,
            pruner=pruner,
            study_name=self.config.name,
        )

        # Define objective wrapper
        def optuna_objective(trial: optuna.Trial) -> float:
            return self._run_trial(trial, objective_fn, constraint_fn)

        # Configure callbacks
        callbacks = []
        if self.config.search.early_stop.enabled:
            callbacks.append(self._create_early_stop_callback())

        # Run optimization
        n_jobs = self.config.search.parallelism
        timeout = self.config.search.timeout_per_trial * self.config.search.trials

        try:
            self._study.optimize(
                optuna_objective,
                n_trials=self.config.search.trials,
                n_jobs=n_jobs if n_jobs > 1 else 1,
                timeout=timeout,
                callbacks=callbacks,
                show_progress_bar=True,
                catch=(Exception,),  # Catch and log exceptions
            )
        except KeyboardInterrupt:
            logger.warning("Optimization interrupted by user")

        # Sort results by score
        self._results.sort(key=lambda r: r.score, reverse=True)

        return self._results

    def _create_sampler(self) -> optuna.samplers.BaseSampler:
        """Create Optuna sampler based on config."""
        seed = self.config.search.seed
        sampler_type = self.config.search.sampler.lower()

        if sampler_type == "tpe":
            return TPESampler(
                seed=seed,
                n_startup_trials=10,
                multivariate=True,
            )
        elif sampler_type == "cmaes":
            return CmaEsSampler(seed=seed)
        elif sampler_type == "random":
            return RandomSampler(seed=seed)
        else:
            logger.warning(f"Unknown sampler {sampler_type}, using TPE")
            return TPESampler(seed=seed)

    def _run_trial(
        self,
        trial: optuna.Trial,
        objective_fn: ObjectiveFn,
        constraint_fn: ConstraintFn | None,
    ) -> float:
        """
        Run a single Optuna trial.

        Args:
            trial: Optuna trial object
            objective_fn: Objective function
            constraint_fn: Optional constraint function

        Returns:
            Objective value (score to maximize)
        """
        start_time = time.time()

        try:
            # Sample parameters
            params = self._sample_params(trial)

            # Run objective function (includes backtest + WFA)
            result = objective_fn(params)

            # Store result
            result_with_meta = TrialResult(
                trial_id=trial.number,
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
                time_gate_violations=result.time_gate_violations,
                overnight_positions=result.overnight_positions,
                apex_compliant=result.apex_compliant,
                score=result.score,
                duration_seconds=time.time() - start_time,
                output_dir=result.output_dir,
                pruned=False,
            )

            self._results.append(result_with_meta)

            # Store user attributes for constraints/analysis
            trial.set_user_attr("trailing_dd", result.trailing_dd)
            trial.set_user_attr("wfe", result.wfe)
            trial.set_user_attr("trades", result.trades)
            trial.set_user_attr("apex_compliant", result.apex_compliant)

            # Check constraints
            if constraint_fn is not None:
                constraints = constraint_fn(result)
                trial.set_user_attr("constraints", constraints)

                # If any constraint violated, return very negative score
                if any(c > 0 for c in constraints):
                    return -999.0

            # Early pruning based on WFE
            min_wfe = self.config.validation.inline_wfa.early_prune_wfe
            if result.wfe < min_wfe:
                logger.debug(f"Trial {trial.number}: WFE {result.wfe:.3f} < {min_wfe}, pruning")
                raise optuna.TrialPruned()

            return result.score

        except optuna.TrialPruned:
            # Record pruned trial
            pruned_result = TrialResult(
                trial_id=trial.number,
                params=self._sample_params(trial),
                sqn=0.0,
                sharpe=0.0,
                sortino=0.0,
                profit_factor=0.0,
                total_pnl=0.0,
                trades=0,
                win_rate=0.0,
                max_drawdown_pct=0.0,
                wfe=0.0,
                wfe_std=0.0,
                positive_days_ratio=0.0,
                regime_scores={},
                trailing_dd=0.0,
                daily_profit_max=0.0,
                time_gate_violations=0,
                overnight_positions=0,
                apex_compliant=False,
                score=-999.0,
                duration_seconds=time.time() - start_time,
                pruned=True,
            )
            self._results.append(pruned_result)
            raise

        except Exception as e:
            logger.error(f"Trial {trial.number} failed: {e}")
            return -999.0

    def _sample_params(self, trial: optuna.Trial) -> dict[str, Any]:
        """
        Sample parameters from Optuna trial.

        Args:
            trial: Optuna trial object

        Returns:
            Dictionary of parameter values
        """
        params: dict[str, Any] = {}

        for spec in self.config.parameters:
            if spec.param_type == "float":
                assert spec.range is not None
                low, high = spec.range
                if spec.step:
                    # Discrete float with step
                    value = trial.suggest_float(
                        spec.name,
                        low,
                        high,
                        step=spec.step,
                    )
                elif spec.log_scale:
                    value = trial.suggest_float(
                        spec.name,
                        low,
                        high,
                        log=True,
                    )
                else:
                    value = trial.suggest_float(spec.name, low, high)
                params[spec.name] = value

            elif spec.param_type == "int":
                assert spec.range is not None
                low, high = int(spec.range[0]), int(spec.range[1])
                step = int(spec.step) if spec.step else 1
                value = trial.suggest_int(spec.name, low, high, step=step)
                params[spec.name] = value

            elif spec.param_type == "categorical":
                assert spec.choices is not None
                value = trial.suggest_categorical(spec.name, spec.choices)
                params[spec.name] = value

        return params

    def _create_early_stop_callback(self) -> Callable[[optuna.Study, optuna.FrozenTrial], None]:
        """Create early stopping callback."""
        patience = self.config.search.early_stop.patience
        min_delta = self.config.search.early_stop.min_delta
        best_value: float | None = None
        trials_without_improvement = 0

        def callback(study: optuna.Study, trial: optuna.FrozenTrial) -> None:
            nonlocal best_value, trials_without_improvement

            if trial.state != optuna.trial.TrialState.COMPLETE:
                return

            current_value = trial.value
            if current_value is None:
                return

            if best_value is None or current_value > best_value + min_delta:
                best_value = current_value
                trials_without_improvement = 0
            else:
                trials_without_improvement += 1

            if trials_without_improvement >= patience:
                logger.info(
                    f"Early stopping: no improvement in {patience} trials "
                    f"(best: {best_value:.4f})"
                )
                study.stop()

        return callback

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
        }

    def get_stats(self) -> OptunaStudyStats:
        """Get detailed study statistics."""
        summary = self.get_study_summary()
        return OptunaStudyStats(
            n_trials=summary.get("n_trials", 0),
            n_complete=summary.get("n_complete", 0),
            n_pruned=summary.get("n_pruned", 0),
            n_failed=summary.get("n_failed", 0),
            best_value=summary.get("best_value", 0.0) or 0.0,
            best_params=summary.get("best_params", {}),
            duration_seconds=summary.get("duration_seconds", 0.0),
        )
