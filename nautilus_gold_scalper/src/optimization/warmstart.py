"""Warm-starting utilities for optimization.

Enables reusing results from previous optimization runs to:
- Initialize samplers with good starting points
- Skip already-evaluated configurations
- Transfer knowledge between related optimization sessions

Key features:
- Load previous results from checkpoint/parquet
- Deduplicate configurations by parameter hash
- Inject warm-start knowledge into any search strategy
"""

from __future__ import annotations

import hashlib
import json
import logging
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import numpy as np

from src.optimization.config import OptimizationConfig
from src.optimization.search.base import TrialResult

logger = logging.getLogger(__name__)


def _hash_params(params: dict[str, Any]) -> str:
    """Create a deterministic hash of parameter dictionary."""
    # Sort keys for determinism
    sorted_params = sorted(params.items())
    param_str = json.dumps(sorted_params, sort_keys=True, default=str)
    return hashlib.sha256(param_str.encode()).hexdigest()[:16]


@dataclass
class WarmStartConfig:
    """Configuration for warm-starting optimization."""

    # Sources for warm-start data
    checkpoint_paths: list[Path]
    parquet_paths: list[Path]

    # Filtering options
    min_score: float = 0.0
    apex_only: bool = False
    max_results: int = 100

    # Knowledge transfer
    transfer_mode: str = "top_k"  # 'top_k', 'all', 'elite_mutate'
    top_k: int = 20
    elite_mutation_prob: float = 0.3


class WarmStartProvider:
    """Provides warm-start capabilities for optimization searches."""

    def __init__(
        self,
        config: OptimizationConfig,
        warm_start_config: WarmStartConfig | None = None,
    ) -> None:
        """Initialize warm-start provider.

        Args:
            config: Optimization configuration
            warm_start_config: Optional warm-start configuration
        """
        self.config = config
        self.warm_start_config = warm_start_config or WarmStartConfig(
            checkpoint_paths=[],
            parquet_paths=[],
        )

        self._historical_results: list[TrialResult] = []
        self._seen_hashes: set[str] = set()

    def load_historical_results(self) -> list[TrialResult]:
        """Load historical results from all configured sources."""
        results: list[TrialResult] = []

        # Load from checkpoints
        for path in self.warm_start_config.checkpoint_paths:
            if path.exists():
                try:
                    ckpt_results = self._load_from_checkpoint(path)
                    results.extend(ckpt_results)
                    logger.info(f"Loaded {len(ckpt_results)} results from checkpoint: {path}")
                except Exception:
                    logger.exception(f"Failed to load checkpoint: {path}")

        # Load from parquet files
        for path in self.warm_start_config.parquet_paths:
            if path.exists():
                try:
                    pq_results = self._load_from_parquet(path)
                    results.extend(pq_results)
                    logger.info(f"Loaded {len(pq_results)} results from parquet: {path}")
                except Exception:
                    logger.exception(f"Failed to load parquet: {path}")

        # Filter results
        filtered = self._filter_results(results)

        # Deduplicate
        unique = self._deduplicate_results(filtered)

        self._historical_results = unique
        return unique

    def _load_from_checkpoint(self, path: Path) -> list[TrialResult]:
        """Load results from a checkpoint file."""
        from src.optimization.checkpointing import load_checkpoint, trial_result_from_dict

        ckpt = load_checkpoint(path)
        return [trial_result_from_dict(r) for r in ckpt.top_results]

    def _load_from_parquet(self, path: Path) -> list[TrialResult]:
        """Load results from a parquet file or directory."""
        import pandas as pd

        if path.is_dir():
            # Load all parquet files in directory
            dfs = []
            for pq_file in path.glob("*.parquet"):
                dfs.append(pd.read_parquet(pq_file))
            if not dfs:
                return []
            df = pd.concat(dfs, ignore_index=True)
        else:
            df = pd.read_parquet(path)

        results = []
        for _, row in df.iterrows():
            try:
                result = self._row_to_trial_result(row)
                results.append(result)
            except Exception:
                logger.warning("Failed to parse row from parquet")
                continue

        return results

    def _row_to_trial_result(self, row: Any) -> TrialResult:
        """Convert a DataFrame row to TrialResult."""
        # Handle params column which may be JSON or dict
        params = row.get("params", {})
        if isinstance(params, str):
            params = json.loads(params)

        return TrialResult(
            trial_id=int(row.get("trial_id", 0)),
            params=dict(params),
            sqn=float(row.get("sqn", 0.0)),
            sharpe=float(row.get("sharpe", 0.0)),
            sortino=float(row.get("sortino", 0.0)),
            profit_factor=float(row.get("profit_factor", 0.0)),
            total_pnl=float(row.get("total_pnl", 0.0)),
            trades=int(row.get("trades", 0)),
            win_rate=float(row.get("win_rate", 0.0)),
            max_drawdown_pct=float(row.get("max_drawdown_pct", 0.0)),
            wfe=float(row.get("wfe", 0.0)),
            wfe_std=float(row.get("wfe_std", 0.0)),
            positive_days_ratio=float(row.get("positive_days_ratio", 0.0)),
            regime_scores=dict(row.get("regime_scores", {})),
            trailing_dd=float(row.get("trailing_dd", 0.0)),
            daily_profit_max=float(row.get("daily_profit_max", 0.0)),
            daily_dd=float(row.get("daily_dd", 0.0)),
            time_gate_violations=int(row.get("time_gate_violations", 0)),
            overnight_positions=int(row.get("overnight_positions", 0)),
            apex_compliant=bool(row.get("apex_compliant", False)),
            score=float(row.get("score", 0.0)),
        )

    def _filter_results(self, results: list[TrialResult]) -> list[TrialResult]:
        """Filter results based on warm-start config."""
        filtered = []

        for r in results:
            # Score filter
            if r.score < self.warm_start_config.min_score:
                continue

            # Apex compliance filter
            if self.warm_start_config.apex_only and not r.apex_compliant:
                continue

            filtered.append(r)

        # Sort by score and limit
        filtered.sort(key=lambda x: x.score, reverse=True)
        return filtered[: self.warm_start_config.max_results]

    def _deduplicate_results(self, results: list[TrialResult]) -> list[TrialResult]:
        """Remove duplicate configurations."""
        unique = []

        for r in results:
            param_hash = _hash_params(r.params)
            if param_hash not in self._seen_hashes:
                self._seen_hashes.add(param_hash)
                unique.append(r)

        return unique

    def get_seed_configurations(self) -> list[dict[str, Any]]:
        """Get configurations to seed a new optimization run.

        Returns parameter dictionaries that can be used to initialize
        the search space.
        """
        mode = self.warm_start_config.transfer_mode

        if mode == "top_k":
            # Return top K configurations
            results = self._historical_results[: self.warm_start_config.top_k]
            return [r.params for r in results]

        elif mode == "all":
            # Return all historical configurations
            return [r.params for r in self._historical_results]

        elif mode == "elite_mutate":
            # Return top K plus mutations
            elite = self._historical_results[: self.warm_start_config.top_k]
            seeds = [r.params for r in elite]

            # Add mutations of elite configurations
            rng = np.random.default_rng(self.config.search.seed)
            for r in elite:
                if rng.random() < self.warm_start_config.elite_mutation_prob:
                    mutated = self._mutate_params(r.params, rng)
                    seeds.append(mutated)

            return seeds

        else:
            logger.warning(f"Unknown transfer_mode: {mode}, using top_k")
            return [r.params for r in self._historical_results[: self.warm_start_config.top_k]]

    def _mutate_params(
        self,
        params: dict[str, Any],
        rng: np.random.Generator,
    ) -> dict[str, Any]:
        """Apply random mutation to a configuration."""
        mutated = dict(params)

        for spec in self.config.parameters:
            # Only mutate some parameters
            if rng.random() > 0.3:
                continue

            if spec.param_type == "categorical":
                if spec.choices:
                    mutated[spec.name] = rng.choice(spec.choices)

            elif spec.range is not None:
                low, high = spec.range
                current = float(params.get(spec.name, (low + high) / 2))

                # Apply small perturbation
                width = high - low
                delta = rng.normal(0, width * 0.1)
                new_value = current + delta
                new_value = max(low, min(high, new_value))

                if spec.param_type == "int":
                    mutated[spec.name] = int(round(new_value))
                else:
                    if spec.step:
                        new_value = low + round((new_value - low) / spec.step) * spec.step
                    mutated[spec.name] = float(new_value)

        return mutated

    def is_evaluated(self, params: dict[str, Any]) -> bool:
        """Check if a configuration has already been evaluated."""
        param_hash = _hash_params(params)
        return param_hash in self._seen_hashes

    def get_historical_score(self, params: dict[str, Any]) -> float | None:
        """Get the historical score for a configuration if available."""
        param_hash = _hash_params(params)

        for r in self._historical_results:
            if _hash_params(r.params) == param_hash:
                return float(r.score)

        return None


def create_warm_start_provider(
    config: OptimizationConfig,
    *,
    checkpoint_paths: list[str | Path] | None = None,
    parquet_paths: list[str | Path] | None = None,
    min_score: float = 0.0,
    apex_only: bool = False,
    top_k: int = 20,
) -> WarmStartProvider:
    """Factory function to create a configured WarmStartProvider.

    Args:
        config: Optimization configuration
        checkpoint_paths: List of checkpoint file paths
        parquet_paths: List of parquet file/directory paths
        min_score: Minimum score filter
        apex_only: Only include apex-compliant results
        top_k: Number of top results to use for seeding

    Returns:
        Configured WarmStartProvider
    """
    warm_config = WarmStartConfig(
        checkpoint_paths=[Path(p) for p in (checkpoint_paths or [])],
        parquet_paths=[Path(p) for p in (parquet_paths or [])],
        min_score=min_score,
        apex_only=apex_only,
        top_k=top_k,
    )

    provider = WarmStartProvider(config, warm_config)
    provider.load_historical_results()

    return provider
