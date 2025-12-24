"""
ApexOptimizer - Main optimization pipeline class.

Unified optimization for Apex-compliant trading strategies with:
- Three-layer architecture (Search → Validate → Stress)
- Inline WFA validation
- Apex compliance as hard constraints
- Composite objective function
"""

from __future__ import annotations

import logging
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Callable, cast

import pandas as pd

from nautilus_gold_scalper.src.optimization.config import (
    OptimizationConfig,
    ObjectiveConfig,
)
from nautilus_gold_scalper.src.optimization.search.base import SearchStrategy, TrialResult
from nautilus_gold_scalper.src.optimization.search.bayesian import BayesianSearch
from nautilus_gold_scalper.src.optimization.validation.wfa_inline import InlineWFA, WFAResult
from nautilus_gold_scalper.src.optimization.constraints.apex import ApexConstraintChecker
from nautilus_gold_scalper.src.optimization.reporting.summary import SummaryReporter


logger = logging.getLogger(__name__)


class ApexOptimizer:
    """
    Unified optimization pipeline for Apex-compliant trading strategies.

    Three-layer architecture:
    1. SEARCH: Grid/Random/Bayesian parameter exploration
    2. VALIDATE: Inline WFA + Apex compliance checking
    3. STRESS: Monte Carlo + overfitting detection (top N only)

    Usage:
        optimizer = ApexOptimizer.from_yaml("configs/grids/smc_optimization.yaml")
        results = optimizer.run()
        optimizer.generate_handoff("ORACLE")
    """

    def __init__(
        self,
        config: OptimizationConfig,
        backtest_fn: Callable[[dict[str, Any], str, str], tuple[pd.DataFrame, pd.Series]] | None = None,
    ) -> None:
        """
        Initialize ApexOptimizer.

        Args:
            config: Optimization configuration
            backtest_fn: Function that runs backtest with params and returns (trades_df, equity_series)
                         Signature: backtest_fn(params, start_date, end_date) -> (trades_df, equity_series)
        """
        self.config = config
        self._backtest_fn = backtest_fn
        self._results: list[TrialResult] = []
        self._output_dir: Path | None = None

        # Initialize components
        self._wfa = InlineWFA(
            windows=config.validation.inline_wfa.windows,
            is_ratio=config.validation.inline_wfa.is_ratio,
            purge_days=config.validation.inline_wfa.purge_days,
            embargo_days=config.validation.inline_wfa.embargo_days,
        )

        self._apex_checker = ApexConstraintChecker(
            trailing_dd_max=config.constraints.apex.trailing_dd_max,
            daily_profit_max=config.constraints.apex.daily_profit_max,
            overnight_positions_max=config.constraints.apex.overnight_positions,
            time_gate_violations_max=config.constraints.apex.time_gate_violations,
        )

    @classmethod
    def from_yaml(
        cls,
        path: str | Path,
        backtest_fn: Callable[[dict[str, Any], str, str], tuple[pd.DataFrame, pd.Series]] | None = None,
    ) -> "ApexOptimizer":
        """
        Load configuration from YAML file.

        Args:
            path: Path to YAML configuration file
            backtest_fn: Optional backtest function

        Returns:
            Configured ApexOptimizer instance
        """
        config = OptimizationConfig.from_yaml(path)
        return cls(config, backtest_fn)

    def set_backtest_fn(
        self,
        fn: Callable[[dict[str, Any], str, str], tuple[pd.DataFrame, pd.Series]],
    ) -> None:
        """Set the backtest function after initialization."""
        self._backtest_fn = fn

    def run(self) -> list[TrialResult]:
        """
        Execute full optimization pipeline.

        Returns:
            List of TrialResult sorted by score (best first)
        """
        if self._backtest_fn is None:
            raise ValueError("backtest_fn not set. Use set_backtest_fn() or pass to constructor.")

        # Setup output directory
        self._setup_output_dir()

        logger.info(f"Starting optimization: {self.config.name}")
        logger.info(f"Mode: {self.config.search.mode}, Trials: {self.config.search.trials}")
        logger.info(f"Output: {self._output_dir}")

        start_time = time.time()

        # Layer 1 + 2: Search with inline validation
        searcher: SearchStrategy
        if self.config.search.mode == "bayesian":
            searcher = BayesianSearch(self.config)
            self._results = searcher.search(
                objective_fn=self._objective_fn,
                constraint_fn=self._constraint_fn,
            )
            study_stats = searcher.get_study_summary()
        elif self.config.search.mode == "grid":
            from nautilus_gold_scalper.src.optimization.search.grid import GridSearch

            searcher = GridSearch(self.config)
            self._results = searcher.search(
                objective_fn=self._objective_fn,
                constraint_fn=self._constraint_fn,
            )
            study_stats = searcher.get_study_summary()
        elif self.config.search.mode == "random":
            from nautilus_gold_scalper.src.optimization.search.random import RandomSearch

            searcher = RandomSearch(self.config)
            self._results = searcher.search(
                objective_fn=self._objective_fn,
                constraint_fn=self._constraint_fn,
            )
            study_stats = searcher.get_study_summary()
        else:
            raise NotImplementedError(f"Search mode {self.config.search.mode} not yet implemented")

        # Sort by score
        self._results.sort(key=lambda r: r.score, reverse=True)

        # Generate reports
        assert self._output_dir is not None, "Output directory not initialized"
        reporter = SummaryReporter(self._output_dir, self.config)
        report_paths = reporter.generate_reports(self._results, study_stats)

        # Generate handoff if enabled
        if self.config.output.handoff_enabled:
            handoff_path = reporter.generate_handoff(self._results, "ORACLE", study_stats)
            logger.info(f"Handoff generated: {handoff_path}")

        duration = time.time() - start_time
        logger.info(f"Optimization complete in {duration:.1f}s")
        logger.info(f"Total trials: {len(self._results)}")
        logger.info(f"Apex compliant: {sum(1 for r in self._results if r.apex_compliant)}")

        if self._results:
            best = self._results[0]
            logger.info(f"Best score: {best.score:.4f} (SQN={best.sqn:.2f}, WFE={best.wfe:.2f})")

        return self._results

    def _setup_output_dir(self) -> None:
        """Setup output directory with session subfolder."""
        base_dir = Path(self.config.output.dir)

        if self.config.output.session_subfolder:
            timestamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
            self._output_dir = base_dir / timestamp
        else:
            self._output_dir = base_dir

        self._output_dir.mkdir(parents=True, exist_ok=True)

    def _objective_fn(self, params: dict[str, Any]) -> TrialResult:
        """
        Objective function that runs backtest + WFA + scoring.

        Args:
            params: Parameter dictionary

        Returns:
            TrialResult with all metrics
        """
        assert self._backtest_fn is not None

        # Merge with fixed params
        full_params = {**self.config.fixed, **params}

        # Run backtest
        trades_df, equity_series = self._backtest_fn(
            full_params,
            self.config.data.train_start,
            self.config.data.train_end,
        )

        # Ensure trades_df has required columns
        if trades_df.empty:
            return self._empty_result(params)

        # Compute WFA metrics
        splits = self._wfa.compute_window_splits(
            self.config.data.train_start,
            self.config.data.train_end,
        )
        windows = self._wfa.analyze_trade_series(trades_df, splits)
        wfa_result = self._wfa.compute_wfa_metrics(windows, trades_df, equity_series)

        # Check Apex compliance
        apex_result = self._apex_checker.check(
            self._wfa_to_trial_result(wfa_result, params)
        )

        # Compute composite score
        score = self._compute_composite_score(wfa_result, apex_result.score_penalty)

        return TrialResult(
            trial_id=0,  # Will be set by searcher
            params=params,
            sqn=wfa_result.sqn,
            sharpe=wfa_result.sharpe,
            sortino=wfa_result.sortino,
            profit_factor=wfa_result.profit_factor,
            total_pnl=wfa_result.total_pnl,
            trades=wfa_result.total_trades,
            win_rate=wfa_result.win_rate,
            max_drawdown_pct=wfa_result.max_drawdown_pct,
            wfe=wfa_result.wfe,
            wfe_std=wfa_result.wfe_std,
            positive_days_ratio=wfa_result.positive_days_ratio,
            regime_scores=wfa_result.regime_scores,
            trailing_dd=wfa_result.trailing_dd,
            daily_profit_max=wfa_result.daily_profit_max,
            time_gate_violations=wfa_result.time_gate_violations,
            overnight_positions=wfa_result.overnight_positions,
            apex_compliant=apex_result.compliant,
            score=score,
        )

    def _constraint_fn(self, result: TrialResult) -> list[float]:
        """
        Constraint function for Optuna.

        Returns list of constraint values where <= 0 means satisfied.
        """
        return self._apex_checker.get_constraint_values(result)

    def _compute_composite_score(
        self,
        wfa_result: WFAResult,
        apex_penalty: float,
    ) -> float:
        """
        Compute composite objective score.

        Formula: weighted_sum(normalized_metrics) * penalty_factors

        Args:
            wfa_result: WFA validation result
            apex_penalty: Apex compliance penalty factor [0, 1]

        Returns:
            Composite score in range [0, 1]
        """
        obj = self.config.objective

        # Normalize base metrics to [0, 1]
        # Formula: sqn_norm = min(sqn / sqn_max, 1.0)
        # Example: sqn=3.5, max=5.0 → 3.5/5.0 = 0.70
        sqn_norm = min(wfa_result.sqn / obj.sqn_weight.normalize, 1.0)
        sqn_norm = max(0.0, sqn_norm)  # Ensure non-negative

        # WFE: already in [0, 1] range
        wfe_norm = max(0.0, min(1.0, wfa_result.wfe))

        # Consistency: positive days ratio, already in [0, 1]
        consistency_norm = max(0.0, min(1.0, wfa_result.positive_days_ratio))

        # Weighted sum
        # Formula: base = w_sqn*sqn_norm + w_wfe*wfe_norm + w_cons*cons_norm
        # Example: 0.4*0.70 + 0.35*0.65 + 0.25*0.80 = 0.71
        base_score = (
            obj.sqn_weight.weight * sqn_norm +
            obj.wfe_weight.weight * wfe_norm +
            obj.consistency_weight.weight * consistency_norm
        )

        # DD penalty: linear decay above threshold
        # Formula: penalty = max(0, 1 - (dd - threshold) * decay_rate)
        # Example: dd=3.8%, threshold=3.0%, rate=0.5 → 1 - (3.8-3.0)*0.5 = 0.60
        dd_threshold = obj.trailing_dd_penalty.threshold
        dd_decay = obj.trailing_dd_penalty.decay_rate
        if wfa_result.trailing_dd <= dd_threshold:
            dd_penalty = 1.0
        else:
            dd_penalty = max(0.0, 1.0 - (wfa_result.trailing_dd - dd_threshold) * dd_decay)

        # Trades penalty: hard cutoff below minimum
        trades_min = obj.trades_penalty.min_required
        trades_penalty_value = obj.trades_penalty.penalty_below
        trades_penalty = 1.0 if wfa_result.total_trades >= trades_min else trades_penalty_value

        # Final score
        # Formula: final = base * dd_penalty * trades_penalty * apex_penalty
        final_score = base_score * dd_penalty * trades_penalty * apex_penalty

        # Ensure valid range
        final_score = max(0.0, min(1.0, final_score))

        return final_score

    def _wfa_to_trial_result(self, wfa: WFAResult, params: dict[str, Any]) -> TrialResult:
        """Convert WFAResult to TrialResult for constraint checking."""
        return TrialResult(
            trial_id=0,
            params=params,
            sqn=wfa.sqn,
            sharpe=wfa.sharpe,
            sortino=wfa.sortino,
            profit_factor=wfa.profit_factor,
            total_pnl=wfa.total_pnl,
            trades=wfa.total_trades,
            win_rate=wfa.win_rate,
            max_drawdown_pct=wfa.max_drawdown_pct,
            wfe=wfa.wfe,
            wfe_std=wfa.wfe_std,
            positive_days_ratio=wfa.positive_days_ratio,
            regime_scores=wfa.regime_scores,
            trailing_dd=wfa.trailing_dd,
            daily_profit_max=wfa.daily_profit_max,
            time_gate_violations=wfa.time_gate_violations,
            overnight_positions=wfa.overnight_positions,
            apex_compliant=True,  # Will be determined by checker
            score=0.0,
        )

    def _empty_result(self, params: dict[str, Any]) -> TrialResult:
        """Return empty result for failed backtests."""
        return TrialResult(
            trial_id=0,
            params=params,
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
            trailing_dd=100.0,  # Max penalty
            daily_profit_max=100.0,
            time_gate_violations=0,
            overnight_positions=0,
            apex_compliant=False,
            score=-999.0,
        )

    def get_results(self) -> list[TrialResult]:
        """Get optimization results."""
        return self._results

    def get_best_params(self) -> dict[str, Any]:
        """Get best parameters found."""
        if not self._results:
            return {}
        return self._results[0].params

    def get_output_dir(self) -> Path | None:
        """Get output directory path."""
        return self._output_dir
