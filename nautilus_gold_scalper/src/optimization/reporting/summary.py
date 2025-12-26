"""
Summary reporter for optimization results.

Generates JSON, CSV, and Parquet reports from optimization runs.
"""

from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import TYPE_CHECKING, Any

import pandas as pd

if TYPE_CHECKING:
    from src.optimization.config import OptimizationConfig
    from src.optimization.search.base import TrialResult


class SummaryReporter:
    """
    Generate summary reports from optimization results.

    Outputs:
    - summary.json: Full results with all metrics
    - summary.csv: Tabular summary for analysis
    - top_n.json: Top N candidates with detailed params
    """

    def __init__(
        self,
        output_dir: str | Path,
        config: OptimizationConfig,
    ) -> None:
        """
        Initialize reporter.

        Args:
            output_dir: Directory for output files
            config: Optimization configuration
        """
        self.output_dir = Path(output_dir)
        self.config = config
        self.output_dir.mkdir(parents=True, exist_ok=True)

    def generate_reports(
        self,
        results: list[TrialResult],
        study_stats: dict[str, Any] | None = None,
    ) -> dict[str, Path]:
        """
        Generate all configured reports.

        Args:
            results: List of trial results
            study_stats: Optional study statistics

        Returns:
            Dictionary of report type to file path
        """
        paths: dict[str, Path] = {}

        # Sort by score for most modes.
        # For Successive Halving, preserve the incoming ordering which is already
        # arranged to prioritize last-rung (highest-fidelity) evaluations.
        if self.config.search.mode == "successive_halving":
            sorted_results = list(results)
        else:
            sorted_results = sorted(results, key=lambda r: r.score, reverse=True)

        # Generate configured reports
        if "json" in self.config.output.reports:
            paths["json"] = self._write_json(sorted_results, study_stats)

        if "csv" in self.config.output.reports:
            paths["csv"] = self._write_csv(sorted_results)

        if "parquet" in self.config.output.reports:
            paths["parquet"] = self._write_parquet(sorted_results)

        # Always write top N
        top_n = self.config.stress_test.top_n
        paths["top"] = self._write_top_n(sorted_results[:top_n])

        return paths

    def _write_json(
        self,
        results: list[TrialResult],
        study_stats: dict[str, Any] | None,
    ) -> Path:
        """Write full JSON report."""
        path = self.output_dir / "summary.json"

        data = {
            "metadata": {
                "name": self.config.name,
                "version": self.config.version,
                "generated_at": datetime.now(timezone.utc).isoformat(),
                "n_trials": len(results),
                "n_apex_compliant": sum(1 for r in results if r.apex_compliant),
            },
            "study_stats": study_stats or {},
            "results": [self._result_to_dict(r) for r in results],
        }

        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, default=str)

        return path

    def _write_csv(self, results: list[TrialResult]) -> Path:
        """Write CSV summary."""
        path = self.output_dir / "summary.csv"

        rows = []
        for r in results:
            row = {
                "trial_id": r.trial_id,
                "score": r.score,
                "sqn": r.sqn,
                "sharpe": r.sharpe,
                "wfe": r.wfe,
                "trades": r.trades,
                "total_pnl": r.total_pnl,
                "trailing_dd": r.trailing_dd,
                "daily_profit_max": r.daily_profit_max,
                "positive_days_ratio": r.positive_days_ratio,
                "pbo": r.pbo,
                "apex_compliant": r.apex_compliant,
                "pruned": r.pruned,
                "duration_seconds": r.duration_seconds,
            }
            # Add params as flattened columns
            for key, value in r.params.items():
                row[f"param_{key}"] = value
            rows.append(row)

        df = pd.DataFrame(rows)
        df.to_csv(path, index=False)

        return path

    def _write_parquet(self, results: list[TrialResult]) -> Path:
        """Write Parquet file for further analysis."""
        path = self.output_dir / "summary.parquet"

        rows = [self._result_to_dict(r) for r in results]
        df = pd.DataFrame(rows)
        df.to_parquet(path, index=False)

        return path

    def _write_top_n(self, top_results: list[TrialResult]) -> Path:
        """Write detailed top N candidates."""
        path = self.output_dir / "top_candidates.json"

        data = {
            "generated_at": datetime.now(timezone.utc).isoformat(),
            "n_candidates": len(top_results),
            "candidates": [
                {
                    "rank": i + 1,
                    **self._result_to_dict(r),
                }
                for i, r in enumerate(top_results)
            ],
        }

        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, default=str)

        return path

    def _result_to_dict(self, result: TrialResult) -> dict[str, Any]:
        """Convert TrialResult to dictionary."""
        return {
            "trial_id": result.trial_id,
            "params": result.params,
            "score": result.score,
            "metrics": {
                "sqn": result.sqn,
                "sharpe": result.sharpe,
                "sortino": result.sortino,
                "profit_factor": result.profit_factor,
                "total_pnl": result.total_pnl,
                "trades": result.trades,
                "win_rate": result.win_rate,
                "max_drawdown_pct": result.max_drawdown_pct,
            },
            "validation": {
                "wfe": result.wfe,
                "wfe_std": result.wfe_std,
                "positive_days_ratio": result.positive_days_ratio,
                "regime_scores": result.regime_scores,
            },
            "apex": {
                "trailing_dd": result.trailing_dd,
                "daily_profit_max": result.daily_profit_max,
                "time_gate_violations": result.time_gate_violations,
                "overnight_positions": result.overnight_positions,
                "compliant": result.apex_compliant,
            },
            "stress": {
                "mc_95_dd": result.mc_95_dd,
                "mc_99_dd": result.mc_99_dd,
                "degradation_survived": result.degradation_survived,
                "pbo": result.pbo,
            },
            "meta": {
                "duration_seconds": result.duration_seconds,
                "output_dir": result.output_dir,
                "pruned": result.pruned,
            },
        }

    def generate_handoff(
        self,
        results: list[TrialResult],
        target: str = "ORACLE",
        study_stats: dict[str, Any] | None = None,
        *,
        ghost_summary: dict[str, Any] | None = None,
        stratification_summary: dict[str, Any] | None = None,
    ) -> Path:
        """
        Generate structured handoff document for target agent.

        Args:
            results: List of trial results
            target: Target agent (ORACLE or SENTINEL)
            study_stats: Optional study statistics

        Returns:
            Path to handoff markdown file
        """
        path = self.output_dir / f"HANDOFF_{target}.md"

        if self.config.search.mode == "successive_halving":
            sorted_results = list(results)
        else:
            sorted_results = sorted(results, key=lambda r: r.score, reverse=True)
        top_n = sorted_results[: self.config.stress_test.top_n]
        compliant = [r for r in sorted_results if r.apex_compliant]

        # Count rejections by reason
        rejections: dict[str, int] = {}
        for r in sorted_results:
            if r.trailing_dd >= self.config.constraints.apex.trailing_dd_max:
                rejections["Trailing DD >= limit"] = rejections.get("Trailing DD >= limit", 0) + 1
            if r.wfe < self.config.constraints.validation.wfe_min:
                rejections["WFE < min"] = rejections.get("WFE < min", 0) + 1
            if r.trades < self.config.constraints.validation.min_trades:
                rejections["Trades < min"] = rejections.get("Trades < min", 0) + 1

        content = self._format_handoff(
            top_n=top_n,
            compliant_count=len(compliant),
            total_count=len(sorted_results),
            rejections=rejections,
            study_stats=study_stats or {},
            target=target,
            ghost_summary=ghost_summary,
            stratification_summary=stratification_summary,
        )

        with open(path, "w", encoding="utf-8") as f:
            f.write(content)

        return path

    def _format_handoff(
        self,
        top_n: list[TrialResult],
        compliant_count: int,
        total_count: int,
        rejections: dict[str, int],
        study_stats: dict[str, Any],
        target: str,
        ghost_summary: dict[str, Any] | None,
        stratification_summary: dict[str, Any] | None,
    ) -> str:
        """Format handoff document content."""
        timestamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")

        # Build params table
        params_table = "| Parameter | Range | Best Value |\n|-----------|-------|------------|\n"
        if top_n:
            best = top_n[0]
            for spec in self.config.parameters:
                if spec.range:
                    value = best.params.get(spec.name, "N/A")
                    params_table += (
                        f"| {spec.name} | [{spec.range[0]}, {spec.range[1]}] | {value} |\n"
                    )

        # Build top candidates table
        top_table = "| Rank | Score | SQN | WFE | DD% | Trades | Consistency |\n"
        top_table += "|------|-------|-----|-----|-----|--------|-------------|\n"
        for i, r in enumerate(top_n):
            top_table += (
                f"| {i + 1} | {r.score:.3f} | {r.sqn:.1f} | {r.wfe:.2f} | "
                f"{r.trailing_dd:.1f} | {r.trades} | {r.positive_days_ratio:.2f} |\n"
            )

        # Build rejections table
        reject_table = "| Reason | Count |\n|--------|-------|\n"
        for reason, count in rejections.items():
            reject_table += f"| {reason} | {count} |\n"

        ghost_block = ""
        if ghost_summary is not None:
            delta = float(ghost_summary.get("sharpe_delta", 0.0))
            p_value = float(ghost_summary.get("p_value", 1.0))
            sims = int(ghost_summary.get("sims", 0))
            thr = float(self.config.stress_test.ghost_test.sharpe_delta_min)
            pmax = float(self.config.stress_test.ghost_test.p_value_max)
            verdict = "PASS" if (delta >= thr and p_value <= pmax) else "FAIL"

            ghost_block = (
                "\n### Ghost Test (Signal vs Baseline)\n"
                f"- Sharpe(full): {ghost_summary.get('sharpe_full')}\n"
                f"- Sharpe(baseline mean±std): {ghost_summary.get('sharpe_baseline_mean')} ± {ghost_summary.get('sharpe_baseline_std')}\n"
                f"- ΔSharpe(full-baseline): {delta:.3f} (threshold {thr:.3f})\n"
                f"- p-value(one-sided): {p_value:.4f} (max {pmax:.4f})\n"
                f"- sims: {sims}\n"
                f"- verdict: **{verdict}**\n"
            )

        strat_block = ""
        if stratification_summary is not None:
            strat_json = json.dumps(stratification_summary, indent=2, default=str)
            strat_block = "\n### Stratification Summary\n```json\n" + strat_json + "\n```\n"

        content = f"""## HANDOFF: APEX_OPTIMIZER → {target}

### Run Metadata
- **Run ID**: opt_{timestamp}
- **Config**: {self.config.name}
- **Mode**: {self.config.search.mode.upper()}
- **Trials**: {study_stats.get("n_complete", 0)} completed, {study_stats.get("n_pruned", 0)} pruned
- **Duration**: {study_stats.get("duration_seconds", 0):.1f}s
- **Apex Compliant**: {compliant_count}/{total_count} ({100 * compliant_count / max(1, total_count):.1f}%)

### Search Space Summary
{params_table}

### Top {len(top_n)} Candidates (Apex-Compliant)
{top_table}

### Apex Rejection Summary
{reject_table}
{ghost_block}{strat_block}
### Recommendations for {target}
1. **Validate top candidates** with full CPCV
2. **Run Monte Carlo stress test** on top 3
3. Generate final GO/NO-GO recommendation

### Files Generated
- `summary.json` - Full results
- `summary.csv` - Tabular summary
- `top_candidates.json` - Top {len(top_n)} config params

### Next Agent Should
- [ ] Run CPCV validation on top candidates
- [ ] Perform Monte Carlo stress test
- [ ] Generate final GO/NO-GO recommendation
"""

        return content
