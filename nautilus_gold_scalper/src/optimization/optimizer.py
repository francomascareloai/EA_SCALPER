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
        backtest_fn: Callable[..., tuple[pd.DataFrame, pd.Series]] | None = None,
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
            daily_dd_max=config.constraints.apex.daily_dd_max,
            daily_profit_max=config.constraints.apex.daily_profit_max,
            overnight_positions_max=config.constraints.apex.overnight_positions,
            time_gate_violations_max=config.constraints.apex.time_gate_violations,
        )

    @classmethod
    def from_yaml(
        cls,
        path: str | Path,
        backtest_fn: Callable[..., tuple[pd.DataFrame, pd.Series]] | None = None,
    ) -> ApexOptimizer:
        config = OptimizationConfig.from_yaml(path)
        return cls(config, backtest_fn)

    def set_backtest_fn(
        self,
        fn: Callable[..., tuple[pd.DataFrame, pd.Series]],
    ) -> None:
        self._backtest_fn = fn

    def run(self, *, resume_from: str | Path | None = None) -> list[TrialResult]:
        if self._backtest_fn is None:
            raise ValueError("backtest_fn not set. Use set_backtest_fn() or pass to constructor.")

        self._setup_output_dir()

        logger.info(f"Starting optimization: {self.config.name}")
        logger.info(f"Mode: {self.config.search.mode}, Trials: {self.config.search.trials}")
        logger.info(f"Output: {self._output_dir}")

        # R12-FIX: Replace assert with explicit validation (assert disabled with -O).
        if self._output_dir is None:
            raise RuntimeError("_output_dir is None - cannot proceed with optimization")

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
                        logger.warning(
                            "Checkpoint config fingerprint mismatch; quarantining %s and starting fresh",
                            resume_path,
                        )
                        quarantine_corrupt_checkpoint(resume_path)
                    else:
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
        elif mode == "levy":
            from src.optimization.search.levy_enhanced import LevyEnhancedSearch

            searcher = LevyEnhancedSearch(
                self.config,
                on_result=on_result_effective,
                max_results_in_ram=self.config.output.max_results_in_ram,
                warmup_samples=20,
                n_elite=5,
            )
        elif mode == "successive_halving":
            from src.optimization.search.successive_halving import SuccessiveHalvingSearch

            if resume_trial_id:
                raise ValueError(
                    "Resume not supported for successive_halving: deterministic promotion requires full rung state"
                )

            searcher = SuccessiveHalvingSearch(
                self.config,
                on_result=on_result_effective,
                max_results_in_ram=self.config.output.max_results_in_ram,
                objective_fn_with_fidelity=self._objective_fn_with_fidelity,
                start_trial_id=resume_trial_id,
                seed_results=resume_seed_results,
            )
        elif mode == "bohb":
            from src.optimization.search.bohb import BOHBSearch

            if resume_trial_id:
                raise ValueError(
                    "Resume not supported for BOHB mode (Optuna storage not configured)"
                )

            # BOHB uses Hyperband-style multi-fidelity with TPE
            sh_cfg = self.config.search.successive_halving
            searcher = BOHBSearch(
                self.config,
                on_result=on_result_effective,
                max_results_in_ram=self.config.output.max_results_in_ram,
                objective_fn_with_fidelity=self._objective_fn_with_fidelity,
                min_resource=min(sh_cfg.wfa_windows) if sh_cfg.wfa_windows else 1,
                max_resource=max(sh_cfg.wfa_windows) if sh_cfg.wfa_windows else 5,
                reduction_factor=sh_cfg.eta,
            )
        elif mode == "asha":
            from src.optimization.search.asha import ASHASearch

            if resume_trial_id:
                raise ValueError("Resume not supported for ASHA: async state not persisted")

            # ASHA provides asynchronous multi-fidelity optimization
            searcher = ASHASearch(
                self.config,
                on_result=on_result_effective,
                max_results_in_ram=self.config.output.max_results_in_ram,
                objective_fn_with_fidelity=self._objective_fn_with_fidelity,
                n_workers=self.config.search.parallelism,
                reduction_factor=self.config.search.successive_halving.eta,
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

        # IMPORTANT: Multi-fidelity modes (SH, BOHB, ASHA) return results ordered to prioritize
        # last-rung (highest fidelity) evaluations. Do not destroy that ordering.
        if mode not in ("successive_halving", "bohb", "asha"):
            self._results.sort(key=lambda r: r.score, reverse=True)

        # Layer 3a: Stress (MC DD percentiles + degradation) for top candidates.
        # NOTE: This is executed before report generation so artifacts include stress metrics.
        if self.config.stress_test.enabled and self._results:
            try:
                from src.optimization.stress.degradation import compute_degradation_survived
                from src.optimization.stress.monte_carlo_dd import (
                    compute_mc_drawdown_percentiles_from_trades,
                )

                top_n = max(1, int(self.config.stress_test.top_n))
                apex_compliant = [x for x in self._results if x.apex_compliant]
                candidates = list((apex_compliant or self._results)[:top_n])

                dd_limit_pct = min(
                    float(self.config.constraints.apex.trailing_dd_max),
                    float(self.config.constraints.anti_overfit.mc95_dd_max),
                )

                # Keep candidate trade artifacts in-memory for any downstream stress metrics.
                # Keyed by trial_id for deterministic association.
                candidate_trades: dict[int, Any] = {}

                for r in candidates:
                    # Merge fixed + trial params, then expand dotpaths into nested structure.
                    flat_params = {**self.config.fixed, **dict(r.params)}
                    full_params = _expand_dotpaths(flat_params)

                    trades_df, equity_series = self._backtest_fn(
                        full_params,
                        self.config.data.train_start,
                        self.config.data.train_end,
                    )

                    candidate_trades[int(r.trial_id)] = trades_df

                    if self.config.stress_test.monte_carlo.enabled:
                        start_equity = (
                            float(equity_series.iloc[0])
                            if equity_series is not None and not equity_series.empty
                            else float("nan")
                        )
                        seed = int(self.config.search.seed) + int(r.trial_id) + 10_000
                        mc = compute_mc_drawdown_percentiles_from_trades(
                            trades_df,
                            start_equity=start_equity,
                            simulations=int(self.config.stress_test.monte_carlo.simulations),
                            seed=seed,
                            block_bootstrap=bool(
                                self.config.stress_test.monte_carlo.block_bootstrap
                            ),
                            block_size=str(self.config.stress_test.monte_carlo.block_size),
                        )
                        r.mc_95_dd = float(mc.mc_95_dd)
                        r.mc_99_dd = float(mc.mc_99_dd)

                    if self.config.stress_test.degradation.enabled:
                        start_equity = (
                            float(equity_series.iloc[0])
                            if equity_series is not None and not equity_series.empty
                            else float("nan")
                        )
                        r.degradation_survived = compute_degradation_survived(
                            trades_df,
                            start_equity=start_equity,
                            rates=list(self.config.stress_test.degradation.rates),
                            dd_limit_pct=dd_limit_pct,
                        )

                # Layer 3a.1: Candidate-set PBO (CSCV-like rank-based proxy)
                # This computes a single PBO value for the *candidate set* (top_n cohort).
                # It is derived from inline WFA windows on the already-generated trades_df.
                try:
                    from src.optimization.stress.pbo_cscv import (
                        CandidateWindowMetrics,
                        compute_candidate_set_pbo_rank_based,
                    )
                    from src.optimization.validation.wfa_inline import InlineWFA

                    # study_stats is expected to be a dict from SearchStrategy.get_study_summary().
                    # Guard anyway to avoid crashing stress metrics when a search implementation
                    # returns None unexpectedly.
                    if study_stats is None:
                        study_stats = {}

                    wfa_cfg = self.config.validation.inline_wfa
                    wfa = InlineWFA(
                        windows=int(wfa_cfg.windows),
                        is_ratio=float(wfa_cfg.is_ratio),
                        purge_days=int(wfa_cfg.purge_days),
                        embargo_days=int(wfa_cfg.embargo_days),
                    )
                    splits = wfa.compute_window_splits(
                        self.config.data.train_start,
                        self.config.data.train_end,
                    )

                    window_metrics: list[CandidateWindowMetrics] = []
                    expected_windows = len(splits)
                    if expected_windows <= 0:
                        raise ValueError("PBO: no valid WFA splits available")
                    for r in candidates:
                        trades_df = candidate_trades.get(int(r.trial_id))
                        if trades_df is None:
                            continue
                        windows = wfa.analyze_trade_series(trades_df, splits)
                        # If a candidate cannot be windowed consistently, drop it from the cohort
                        # (fail-closed behavior occurs downstream if <2 candidates remain).
                        if len(windows) != expected_windows:
                            continue

                        # Use SQN as the ranking signal (dimensionless, robust vs PnL scale).
                        is_scores = [float(w.is_sqn) for w in windows]
                        oos_scores = [float(w.oos_sqn) for w in windows]
                        window_metrics.append(
                            CandidateWindowMetrics(
                                candidate_id=int(r.trial_id),
                                is_scores=is_scores,
                                oos_scores=oos_scores,
                            )
                        )

                    pbo_value = compute_candidate_set_pbo_rank_based(window_metrics)
                    for r in candidates:
                        r.pbo = float(pbo_value)

                    study_stats["pbo_candidate_set"] = float(pbo_value)
                    study_stats["pbo_max"] = float(self.config.constraints.anti_overfit.pbo_max)
                    study_stats["pbo_pass"] = bool(
                        float(pbo_value) <= float(self.config.constraints.anti_overfit.pbo_max)
                    )
                except Exception as exc:
                    # FAIL-CLOSED: If PBO gate is enabled but fails to compute,
                    # mark all candidates as BLOCKED to prevent false sense of security.
                    # See 12-11-OPTIMIZATION-ROADMAP.md TIER 1.2
                    logger.critical(
                        "Candidate-set PBO computation failed (%s: %s) - BLOCKING all candidates "
                        "(fail-closed behavior, stress gate enabled but unusable)",
                        type(exc).__name__,
                        str(exc),
                        exc_info=True,
                    )
                    for r in candidates:
                        r.pbo = 1.0  # Worst-case PBO (100% probability of overfit)
                        r.score = -999.0  # Block from promotion
                        r.apex_compliant = False
            except Exception as exc:
                # FAIL-CLOSED: If Layer 3 stress gates (MC/degradation/PBO) are enabled but fail,
                # mark all candidates as BLOCKED. Never silently proceed without safety checks.
                # See 12-11-OPTIMIZATION-ROADMAP.md TIER 1.2
                logger.critical(
                    "Layer 3 stress computation failed (%s: %s) - BLOCKING all candidates "
                    "(fail-closed behavior, stress tests enabled but unusable)",
                    type(exc).__name__,
                    str(exc),
                    exc_info=True,
                )
                # Mark candidates as non-compliant with worst-case metrics
                top_n = max(1, int(self.config.stress_test.top_n))
                apex_compliant = [x for x in self._results if x.apex_compliant]
                candidates_to_block = list((apex_compliant or self._results)[:top_n])
                for r in candidates_to_block:
                    r.mc_95_dd = 100.0  # Worst-case DD
                    r.mc_99_dd = 100.0
                    r.score = -999.0  # Block from promotion
                    r.apex_compliant = False

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
                flat_params = {**self.config.fixed, **best_params}
                full_params = _expand_dotpaths(flat_params)

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
            except Exception as exc:
                # FAIL-CLOSED: Ghost test is a falsification gate. If enabled but fails,
                # block the best result to prevent false confidence in edge.
                # See 12-11-OPTIMIZATION-ROADMAP.md TIER 1.2
                logger.critical(
                    "Ghost test failed (%s: %s) - BLOCKING best candidate "
                    "(fail-closed behavior, falsification gate enabled but unusable)",
                    type(exc).__name__,
                    str(exc),
                    exc_info=True,
                )
                if self._results:
                    self._results[0].score = -999.0
                    self._results[0].apex_compliant = False

        # Layer 3c: Overfitting Detection (cliff/island/regime-bias)
        overfit_summary: dict[str, int] | None = None
        overfitting_cfg = self.config.stress_test.overfitting_detection
        if (
            overfitting_cfg.cliff_check
            or overfitting_cfg.island_check
            or overfitting_cfg.regime_bias_check
        ) and self._results:
            try:
                from src.optimization.constraints.anti_overfit import (
                    detect_cliff,
                    detect_island,
                    detect_regime_bias,
                )

                top_n = max(1, int(self.config.stress_test.top_n))
                candidates = self._results[:top_n]

                # Island detection runs ONCE outside the loop (checks best vs rest)
                island_warnings = []
                if overfitting_cfg.island_check:
                    island_warnings = detect_island(
                        results=self._results,
                        top_k=min(5, len(self._results) - 1),
                        neighbor_threshold=0.10,
                    )

                for idx, r in enumerate(candidates):
                    all_warnings = []

                    if overfitting_cfg.cliff_check:
                        all_warnings.extend(
                            detect_cliff(
                                best_params=r.params,
                                param_specs=self.config.parameters,
                                tolerance=0.05,
                            )
                        )

                    # Attach island warnings ONLY to best candidate (idx=0)
                    if idx == 0 and island_warnings:
                        all_warnings.extend(island_warnings)

                    if overfitting_cfg.regime_bias_check:
                        all_warnings.extend(
                            detect_regime_bias(
                                result=r,
                                min_coverage=0.20,
                            )
                        )

                    # Store as list of dicts for serialization
                    if all_warnings:
                        r.overfit_warnings = [w.to_dict() for w in all_warnings]

                # Summarize for logging
                if candidates and candidates[0].overfit_warnings:
                    # Reconstruct warnings for summary
                    best_warnings = candidates[0].overfit_warnings
                    overfit_summary = {}
                    for w in best_warnings:
                        key = str(w.get("type", "UNKNOWN"))
                        overfit_summary[key] = overfit_summary.get(key, 0) + 1

                    logger.info(
                        "Overfitting detection: %d warnings for best trial: %s",
                        len(best_warnings),
                        overfit_summary,
                    )
                else:
                    logger.info("Overfitting detection: no warnings for top candidates")

            except Exception:
                # FAIL-CLOSED: Overfitting detection is a safety gate. If enabled but fails,
                # add worst-case warning to prevent false confidence.
                # See 12-11-OPTIMIZATION-ROADMAP.md TIER 1.2
                logger.critical(
                    "Overfitting detection failed - adding UNKNOWN warning to candidates "
                    "(fail-closed behavior, overfit gate enabled but unusable)"
                )
                top_n = max(1, int(self.config.stress_test.top_n))
                candidates_to_warn = self._results[:top_n]
                for r in candidates_to_warn:
                    if not hasattr(r, "overfit_warnings") or r.overfit_warnings is None:
                        r.overfit_warnings = []
                    r.overfit_warnings.append(
                        {
                            "type": "DETECTION_FAILED",
                            "severity": "CRITICAL",
                            "message": "Overfitting detection failed - cannot verify config safety",
                        }
                    )

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
            "ticks",
            None,
        )

    def _objective_fn_with_fidelity(
        self,
        params: dict[str, Any],
        train_start: str,
        train_end: str,
        wfa_windows: int,
        feed_mode: str = "ticks",
        bars_file: str | None = None,
    ) -> TrialResult:
        # R12-FIX: Replace assert with explicit validation (assert disabled with -O).
        if self._backtest_fn is None:
            raise RuntimeError("_backtest_fn is None - cannot run objective function")

        # Merge fixed + trial params, then expand dotpaths into nested structure
        # e.g., {"execution.mean_revert_bb_period": 20} -> {"execution": {"mean_revert_bb_period": 20}}
        flat_params = {**self.config.fixed, **params}
        full_params = _expand_dotpaths(flat_params)

        try:
            trades_df, equity_series = self._backtest_fn(
                full_params,
                train_start,
                train_end,
                feed_mode=feed_mode,
                bars_file=bars_file,
            )
        except Exception as exc:
            # Treat invalid/unrunnable parameter combinations as failed trials (fail-closed).
            logger.error(
                "Backtest failed for trial params (%s): %s",
                type(exc).__name__,
                exc,
            )
            return self._empty_result(params)

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

        # Apex gating: only valid for tick-based runs (requires conservative MTM from bid/ask QuoteTicks).
        if str(feed_mode) == "ticks":
            apex_result = self._apex_checker.check(self._wfa_to_trial_result(wfa_result, params))
            apex_penalty = apex_result.score_penalty
            apex_compliant = apex_result.compliant
        else:
            # Bars-only prescreen is ranking-only. It must not claim compliance.
            apex_penalty = 1.0
            apex_compliant = False

        score = self._compute_composite_score(wfa_result, apex_penalty)

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
            daily_dd=wfa_result.daily_dd,
            time_gate_violations=wfa_result.time_gate_violations,
            overnight_positions=wfa_result.overnight_positions,
            apex_compliant=apex_compliant,
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
        import math  # Local import to ensure availability

        obj = self.config.objective

        # CRITICAL: Guard against NaN/Inf in metrics before normalization.
        # Python min(1.0, NaN) returns 1.0 which would treat corrupt metrics as best-case.
        # If any core metric is non-finite, return worst-case score.
        if not (
            math.isfinite(wfa_result.sqn)
            and math.isfinite(wfa_result.wfe)
            and math.isfinite(wfa_result.positive_days_ratio)
            and math.isfinite(wfa_result.win_rate)
            and math.isfinite(wfa_result.trailing_dd)
        ):
            logger.warning(
                "Non-finite WFA metrics detected (NaN/Inf) - returning worst-case score 0.0"
            )
            return 0.0

        # Normalize base metrics to [0, 1]
        # Formula: sqn_norm = min(sqn / sqn_max, 1.0)
        # Example: sqn=3.5, max=5.0 → 3.5/5.0 = 0.70
        sqn_norm = min(wfa_result.sqn / float(obj.sqn_weight.normalize), 1.0)
        sqn_norm = max(0.0, sqn_norm)

        # Use WFE normalization from config (like SQN) for consistency.
        # Formula: wfe_norm = clamp(wfe / wfe_max, 0, 1)
        # Example: wfe=1.2, normalize=2.0 → 1.2/2.0 = 0.60
        wfe_max = float(obj.wfe_weight.normalize) if obj.wfe_weight.normalize > 0 else 1.0
        wfe_norm = max(0.0, min(1.0, wfa_result.wfe / wfe_max))

        # Configurable consistency source (schema supports win-rate variants too).
        source = (obj.consistency_weight.source or "positive_days_ratio").strip().lower()
        if source in ("positive_days_ratio", "positive_days"):
            consistency_raw = float(wfa_result.positive_days_ratio)
        elif source in ("win_rate", "winrate"):
            consistency_raw = float(wfa_result.win_rate)
        elif source in ("win_rate_pct", "winrate_pct"):
            consistency_raw = float(wfa_result.win_rate) * 100.0
        else:
            raise ValueError(
                f"Unknown objective.composite.consistency source: {obj.consistency_weight.source!r}"
            )

        # Normalize into [0, 1] for stable scoring. If provided as percent, scale by normalize.
        # Formula: consistency_norm = clamp(consistency_raw / normalize, 0, 1)
        # Example: win_rate_pct=55, normalize=100 -> 0.55
        denom = float(obj.consistency_weight.normalize)
        if denom <= 0:
            raise ValueError(f"consistency_weight.normalize must be > 0, got {denom}")
        consistency_norm = consistency_raw / denom
        consistency_norm = max(0.0, min(1.0, float(consistency_norm)))

        base_score = (
            float(obj.sqn_weight.weight) * float(sqn_norm)
            + float(obj.wfe_weight.weight) * float(wfe_norm)
            + float(obj.consistency_weight.weight) * float(consistency_norm)
        )

        # NOTE: DD penalty is now handled ONLY by apex_penalty (from ApexConstraintChecker).
        # Previously, we had a separate dd_penalty here which caused double-counting:
        # - objective.trailing_dd_penalty started at configured threshold
        # - apex_penalty also penalized DD starting at 3% buffer
        # This double-penalization distorted the objective, over-selecting low-DD configs.
        # Now we skip the objective dd_penalty; Apex penalty is the single source of DD pressure.
        # Config fields trailing_dd_penalty.threshold/decay_rate are now deprecated (ignored).

        trades_min = int(obj.trades_penalty.min_required)
        trades_penalty_value = float(obj.trades_penalty.penalty_below)
        trades_penalty = 1.0 if wfa_result.total_trades >= trades_min else trades_penalty_value

        # Final score: base * trades_penalty * apex_penalty (no separate dd_penalty)
        final_score = float(base_score) * float(trades_penalty) * float(apex_penalty)
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
            daily_dd=wfa.daily_dd,
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
            daily_dd=100.0,
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
