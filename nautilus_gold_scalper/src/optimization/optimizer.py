"""
ApexOptimizer - Main optimization pipeline class.

Unified optimization for Apex-compliant trading strategies with:
- Three-layer architecture (Search → Validate → Stress)
- Inline WFA validation
- Apex compliance as hard constraints
- Composite objective function

This version adds memory controls for grid/random search:
- Optional on-disk streaming of TrialResult rows to Parquet
- Optional cap on results kept in RAM (top-N by score)
"""

from __future__ import annotations

import logging
import time
from collections.abc import Callable
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import pandas as pd

from src.optimization.checkpointing import (
    DEFAULT_CHECKPOINT_FILENAME,
    CheckpointError,
    CheckpointManager,
    compute_config_fingerprint,
    load_checkpoint,
    quarantine_corrupt_checkpoint,
    trial_result_from_dict,
)
from src.optimization.config import OptimizationConfig
from src.optimization.constraints.apex import ApexConstraintChecker
from src.optimization.reporting.summary import SummaryReporter
from src.optimization.search.base import SearchStrategy, TrialResult
from src.optimization.validation.wfa_inline import InlineWFA, WFAResult

logger = logging.getLogger(__name__)


def _expand_dotpaths(flat_params: dict[str, Any]) -> dict[str, Any]:
    """Expand dotpath keys into nested dict structure.

    Example:
        {"execution.mean_revert_bb_period": 20, "risk.max_positions": 1}
        ->
        {"execution": {"mean_revert_bb_period": 20}, "risk": {"max_positions": 1}}

    Keys without dots are kept at root level.
    """
    result: dict[str, Any] = {}
    for key, value in flat_params.items():
        parts = key.split(".")
        if len(parts) == 1:
            # No dot, keep at root
            result[key] = value
        else:
            # Traverse/create nested structure
            current = result
            for part in parts[:-1]:
                if part not in current:
                    current[part] = {}
                current = current[part]
            current[parts[-1]] = value
    return result


class ApexOptimizer:
    """Unified optimization pipeline for Apex-compliant trading strategies."""

    def __init__(
        self,
        config: OptimizationConfig,
        backtest_fn: Callable[[dict[str, Any], str, str], tuple[pd.DataFrame, pd.Series]]
        | None = None,
    ) -> None:
        self.config = config
        self._backtest_fn = backtest_fn
        self._results: list[TrialResult] = []
        self._output_dir: Path | None = None

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
        backtest_fn: Callable[[dict[str, Any], str, str], tuple[pd.DataFrame, pd.Series]]
        | None = None,
    ) -> ApexOptimizer:
        config = OptimizationConfig.from_yaml(path)
        return cls(config, backtest_fn)

    def set_backtest_fn(
        self,
        fn: Callable[[dict[str, Any], str, str], tuple[pd.DataFrame, pd.Series]],
    ) -> None:
        self._backtest_fn = fn

    def run(self, *, resume_from: str | Path | None = None) -> list[TrialResult]:
        if self._backtest_fn is None:
            raise ValueError("backtest_fn not set. Use set_backtest_fn() or pass to constructor.")

        self._setup_output_dir()

        logger.info(f"Starting optimization: {self.config.name}")
        logger.info(f"Mode: {self.config.search.mode}, Trials: {self.config.search.trials}")
        logger.info(f"Output: {self._output_dir}")

        assert self._output_dir is not None

        start_time = time.time()

        mode = self.config.search.mode

        config_fp = compute_config_fingerprint(self.config)

        # ---------------------------------------------------------------------
        # Checkpoint loading (resume)
        # ---------------------------------------------------------------------
        resume_trial_id = 0
        resume_seed_results: list[TrialResult] = []

        resume_path: Path | None = None
        if resume_from is not None:
            resume_path = Path(resume_from)
        elif self.config.output.checkpoint_enabled:
            # Default checkpoint path inside output dir for this session.
            resume_path = self._output_dir / DEFAULT_CHECKPOINT_FILENAME

        if resume_from is not None:
            if resume_path is None:
                raise ValueError("resume_from provided but resolve failed")
            if resume_path.exists():
                try:
                    ckpt = load_checkpoint(resume_path)
                except CheckpointError:
                    # Quarantine and start fresh.
                    corrupt_path = quarantine_corrupt_checkpoint(resume_path)
                    logger.warning(
                        "Checkpoint corrupted; moved to %s and starting fresh", corrupt_path
                    )
                else:
                    if ckpt.config_fingerprint != config_fp:
                        raise ValueError(
                            "Checkpoint config fingerprint mismatch; refusing to resume with different config"
                        )
                    if ckpt.mode and ckpt.mode != mode:
                        raise ValueError(
                            f"Checkpoint mode mismatch: {ckpt.mode} vs current {mode}; refusing to resume"
                        )
                    resume_trial_id = int(ckpt.resume_from_trial_id)
                    # Resume seeds only the (bounded) top-N results from the checkpoint.
                    # Deterministic trial skipping avoids re-running already completed trials.
                    resume_seed_results = [trial_result_from_dict(r) for r in ckpt.top_results]

                    logger.info(
                        "Resuming from checkpoint %s at trial_id=%d",
                        resume_path,
                        resume_trial_id,
                    )
            else:
                raise FileNotFoundError(f"Checkpoint not found: {resume_path}")

        # ---------------------------------------------------------------------
        # Result persistence / streaming
        # ---------------------------------------------------------------------
        on_result = None
        streamer = None
        if self.config.output.results_parquet:
            from src.optimization.streaming.persistence import (
                ParquetResultSink,
                ResultStreamer,
            )

            base_dir = Path(self.config.output.results_parquet)
            if not base_dir.is_absolute():
                base_dir = self._output_dir / base_dir

            sink = ParquetResultSink(
                base_dir,
                flush_every=self.config.output.results_flush_every,
            )
            streamer = ResultStreamer(sink)
            on_result = streamer

        searcher: SearchStrategy
        study_stats: dict[str, Any]

        # ---------------------------------------------------------------------
        # Checkpoint save hook (as on_result wrapper)
        # ---------------------------------------------------------------------
        checkpoint_mgr: CheckpointManager | None = None
        if self.config.output.checkpoint_enabled:
            # Keep top-N in checkpoint to avoid huge JSON.
            keep_top_n = self.config.output.max_results_in_ram or 500
            keep_top_n = max(1, int(keep_top_n))

            ckpt_path = self._output_dir / DEFAULT_CHECKPOINT_FILENAME
            checkpoint_mgr = CheckpointManager(
                ckpt_path,
                mode=mode,
                config_fingerprint=config_fp,
                interval=int(self.config.output.checkpoint_interval),
                keep_top_n=keep_top_n,
                ignore_trial_id_lt=resume_trial_id,
            )

            if resume_seed_results:
                checkpoint_mgr.seed_top_results(resume_seed_results)

        def combined_on_result(result: TrialResult) -> None:
            if on_result is not None:
                on_result(result)
            if checkpoint_mgr is not None:
                checkpoint_mgr(result)

        on_result_effective = (
            combined_on_result if (on_result is not None or checkpoint_mgr is not None) else None
        )

        if mode == "bayesian":
            from src.optimization.search.bayesian import BayesianSearch

            if resume_trial_id:
                raise ValueError(
                    "Resume not supported for bayesian mode (Optuna storage not configured)"
                )

            searcher = BayesianSearch(self.config)
        elif mode == "grid":
            from src.optimization.search.grid import GridSearch

            searcher = GridSearch(
                self.config,
                on_result=on_result_effective,
                max_results_in_ram=self.config.output.max_results_in_ram,
                start_trial_id=resume_trial_id,
                seed_results=resume_seed_results,
            )
        elif mode == "random":
            from src.optimization.search.random import RandomSearch

            searcher = RandomSearch(
                self.config,
                on_result=on_result_effective,
                max_results_in_ram=self.config.output.max_results_in_ram,
                start_trial_id=resume_trial_id,
                seed_results=resume_seed_results,
            )
        elif mode == "successive_halving":
            from src.optimization.search.successive_halving import SuccessiveHalvingSearch

            searcher = SuccessiveHalvingSearch(
                self.config,
                on_result=on_result_effective,
                max_results_in_ram=self.config.output.max_results_in_ram,
                objective_fn_with_fidelity=self._objective_fn_with_fidelity,
                start_trial_id=resume_trial_id,
                seed_results=resume_seed_results,
            )
        else:
            raise NotImplementedError(f"Search mode {mode} not yet implemented")

        self._results = searcher.search(
            objective_fn=self._objective_fn,
            constraint_fn=self._constraint_fn,
        )
        study_stats = searcher.get_study_summary()

        # Force a final checkpoint save (especially useful if interval > remaining trials).
        if checkpoint_mgr is not None:
            checkpoint_mgr.force_save(progress=int(study_stats.get("n_trials", 0)))

        self._results.sort(key=lambda r: r.score, reverse=True)

        reporter = SummaryReporter(self._output_dir, self.config)
        report_paths = reporter.generate_reports(self._results, study_stats)

        # Layer 3b: Ghost Test (cheap falsification gate)
        ghost_summary: dict[str, Any] | None = None
        if self.config.stress_test.ghost_test.enabled and self._results:
            try:
                from src.optimization.stress.ghost_test import (
                    ghost_test_summary_dict,
                    run_ghost_test,
                )

                best_params = dict(self._results[0].params)
                full_params = {**self.config.fixed, **best_params}
                trades_df, _equity_series = self._backtest_fn(
                    full_params,
                    self.config.data.train_start,
                    self.config.data.train_end,
                )

                ghost = run_ghost_test(
                    trades_df,
                    sims=self.config.stress_test.ghost_test.sims,
                    seed=self.config.search.seed + self.config.stress_test.ghost_test.seed_offset,
                )
                ghost_summary = ghost_test_summary_dict(ghost)

                logger.info(
                    "Ghost Test: Sharpe(full)=%.3f, baseline=%.3f±%.3f, Δ=%.3f, p=%.4f (sims=%d)",
                    ghost.sharpe_full,
                    ghost.sharpe_baseline_mean,
                    ghost.sharpe_baseline_std,
                    ghost.sharpe_delta,
                    ghost.p_value,
                    ghost.sims,
                )
            except Exception:
                logger.exception("Ghost test failed; continuing without ghost results")

        if self.config.output.handoff_enabled:
            handoff_path = reporter.generate_handoff(
                self._results, "ORACLE", study_stats, ghost_summary=ghost_summary
            )
            logger.info(f"Handoff generated: {handoff_path}")

        duration = time.time() - start_time
        logger.info(f"Optimization complete in {duration:.1f}s")
        logger.info(f"Total trials retained in RAM: {len(self._results)}")
        logger.info(f"Apex compliant: {sum(1 for r in self._results if r.apex_compliant)}")

        if self._results:
            best = self._results[0]
            logger.info(f"Best score: {best.score:.4f} (SQN={best.sqn:.2f}, WFE={best.wfe:.2f})")

        if streamer is not None:
            streamer.close()
            logger.info(
                f"Streamed results parquet dataset at: {self.config.output.results_parquet}"
            )
            _ = report_paths

        return self._results

    def _setup_output_dir(self) -> None:
        base_dir = Path(self.config.output.dir)

        if self.config.output.session_subfolder:
            timestamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
            self._output_dir = base_dir / timestamp
        else:
            self._output_dir = base_dir

        self._output_dir.mkdir(parents=True, exist_ok=True)

    def _objective_fn(self, params: dict[str, Any]) -> TrialResult:
        return self._objective_fn_with_fidelity(
            params,
            self.config.data.train_start,
            self.config.data.train_end,
            self.config.validation.inline_wfa.windows,
        )

    def _objective_fn_with_fidelity(
        self,
        params: dict[str, Any],
        train_start: str,
        train_end: str,
        wfa_windows: int,
    ) -> TrialResult:
        assert self._backtest_fn is not None

        # Merge fixed + trial params, then expand dotpaths into nested structure
        # e.g., {"execution.mean_revert_bb_period": 20} -> {"execution": {"mean_revert_bb_period": 20}}
        flat_params = {**self.config.fixed, **params}
        full_params = _expand_dotpaths(flat_params)

        trades_df, equity_series = self._backtest_fn(
            full_params,
            train_start,
            train_end,
        )

        if trades_df.empty:
            return self._empty_result(params)

        wfa = InlineWFA(
            windows=wfa_windows,
            is_ratio=self.config.validation.inline_wfa.is_ratio,
            purge_days=self.config.validation.inline_wfa.purge_days,
            embargo_days=self.config.validation.inline_wfa.embargo_days,
        )

        splits = wfa.compute_window_splits(train_start, train_end)
        if not splits:
            # If we cannot compute any valid WFA split (e.g., too short range vs purge/embargo),
            # treat the trial as invalid to avoid false robustness/compliance.
            return self._empty_result(params)

        windows = wfa.analyze_trade_series(trades_df, splits)
        if not windows:
            return self._empty_result(params)

        wfa_result = wfa.compute_wfa_metrics(windows, trades_df, equity_series)

        apex_result = self._apex_checker.check(self._wfa_to_trial_result(wfa_result, params))

        score = self._compute_composite_score(wfa_result, apex_result.score_penalty)

        return TrialResult(
            trial_id=0,
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
        values = self._apex_checker.get_constraint_values(result)
        return list(values)

    def _compute_composite_score(
        self,
        wfa_result: WFAResult,
        apex_penalty: float,
    ) -> float:
        obj = self.config.objective

        # Normalize base metrics to [0, 1]
        # Formula: sqn_norm = min(sqn / sqn_max, 1.0)
        # Example: sqn=3.5, max=5.0 → 3.5/5.0 = 0.70
        sqn_norm = min(wfa_result.sqn / float(obj.sqn_weight.normalize), 1.0)
        sqn_norm = max(0.0, sqn_norm)

        wfe_norm = max(0.0, min(1.0, wfa_result.wfe))
        consistency_norm = max(0.0, min(1.0, wfa_result.positive_days_ratio))

        base_score = (
            float(obj.sqn_weight.weight) * float(sqn_norm)
            + float(obj.wfe_weight.weight) * float(wfe_norm)
            + float(obj.consistency_weight.weight) * float(consistency_norm)
        )

        dd_threshold = float(obj.trailing_dd_penalty.threshold)
        dd_decay = float(obj.trailing_dd_penalty.decay_rate)
        if wfa_result.trailing_dd <= dd_threshold:
            dd_penalty = 1.0
        else:
            dd_penalty = max(0.0, 1.0 - (wfa_result.trailing_dd - dd_threshold) * dd_decay)

        trades_min = int(obj.trades_penalty.min_required)
        trades_penalty_value = float(obj.trades_penalty.penalty_below)
        trades_penalty = 1.0 if wfa_result.total_trades >= trades_min else trades_penalty_value

        final_score = (
            float(base_score) * float(dd_penalty) * float(trades_penalty) * float(apex_penalty)
        )
        final_score = max(0.0, min(1.0, float(final_score)))
        return float(final_score)

    def _wfa_to_trial_result(self, wfa: WFAResult, params: dict[str, Any]) -> TrialResult:
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
            apex_compliant=True,
            score=0.0,
        )

    def _empty_result(self, params: dict[str, Any]) -> TrialResult:
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
            trailing_dd=100.0,
            daily_profit_max=100.0,
            time_gate_violations=0,
            overnight_positions=0,
            apex_compliant=False,
            score=-999.0,
        )

    def get_results(self) -> list[TrialResult]:
        return self._results

    def get_best_params(self) -> dict[str, Any]:
        if not self._results:
            return {}
        return dict(self._results[0].params)

    def get_output_dir(self) -> Path | None:
        return self._output_dir
