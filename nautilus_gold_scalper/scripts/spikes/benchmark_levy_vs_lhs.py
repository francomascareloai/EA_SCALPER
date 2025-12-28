#!/usr/bin/env python3
"""Spike: Compare LHS baseline vs Lévy-Enhanced search.

This benchmark compares optimization strategies on a synthetic multi-modal
fitness landscape that mimics trading strategy optimization characteristics:
- Multiple local optima (like different trading regimes)
- Noisy evaluations (like Monte Carlo variance)
- Some parameters more important than others

Usage:
    .venv/bin/python nautilus_gold_scalper/scripts/spikes/benchmark_levy_vs_lhs.py

Output:
    Comparison metrics: best score, convergence speed, exploration efficiency
"""

from __future__ import annotations

import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import numpy as np

# Add project root to path
project_root = Path(__file__).parent.parent.parent.parent
sys.path.insert(0, str(project_root))

from src.optimization.config import OptimizationConfig, ParameterSpec, SearchConfig
from src.optimization.search.base import TrialResult
from src.optimization.search.levy_enhanced import LevyEnhancedSearch
from src.optimization.search.random import RandomSearch


@dataclass
class BenchmarkResult:
    """Results from a single benchmark run."""

    strategy: str
    best_score: float
    best_params: dict[str, Any]
    n_evaluations: int
    time_seconds: float
    convergence_history: list[float]  # Best score at each evaluation
    extra_metrics: dict[str, Any]


def create_synthetic_fitness_landscape(seed: int = 42) -> callable:
    """Create a synthetic fitness function mimicking trading optimization.

    Characteristics:
    - Multi-modal: multiple local optima at different "regimes"
    - Noisy: small random perturbations (like MC variance)
    - Asymmetric: some optima are harder to find
    - Parameter interactions: some params only matter in certain ranges
    """
    rng = np.random.default_rng(seed)

    # Define 3 "regime" optima with different difficulties
    optima = [
        {"center": [0.3, 0.4, 0.5, 0.6], "scale": 0.15, "height": 85},  # Easy to find
        {"center": [0.7, 0.2, 0.8, 0.3], "scale": 0.10, "height": 95},  # Harder, better
        {"center": [0.5, 0.9, 0.1, 0.7], "scale": 0.08, "height": 100},  # Hardest, best
    ]

    def fitness(params: dict[str, Any]) -> float:
        # Normalize params to [0, 1]
        x = np.array(
            [
                (params.get("param_a", 50) - 0) / 100,
                (params.get("param_b", 50) - 0) / 100,
                (params.get("param_c", 1.5) - 1.0) / 2.0,
                (params.get("param_d", 0.5) - 0) / 1.0,
            ]
        )

        # Calculate contribution from each optimum (Gaussian)
        score = 0.0
        for opt in optima:
            center = np.array(opt["center"])
            scale = opt["scale"]
            height = opt["height"]

            dist = np.linalg.norm(x - center)
            contribution = height * np.exp(-(dist**2) / (2 * scale**2))
            score = max(score, contribution)

        # Add noise (like MC variance) - ~5% relative noise
        noise = rng.normal(0, score * 0.05)
        score += noise

        # Penalty for extreme parameters (like Apex compliance)
        if params.get("param_a", 50) > 90:
            score *= 0.8  # Penalty for too aggressive
        if params.get("param_d", 0.5) < 0.1:
            score *= 0.9  # Penalty for too conservative

        return float(max(0, score))

    return fitness


def create_test_config(n_samples: int = 100, seed: int = 42) -> OptimizationConfig:
    """Create a test optimization config."""
    return OptimizationConfig(
        parameters=[
            ParameterSpec(name="param_a", param_type="int", range=(0, 100), step=5),
            ParameterSpec(name="param_b", param_type="int", range=(0, 100), step=5),
            ParameterSpec(name="param_c", param_type="float", range=(1.0, 3.0), step=0.1),
            ParameterSpec(name="param_d", param_type="float", range=(0.0, 1.0), step=0.05),
        ],
        search=SearchConfig(
            mode="random",
            n_samples=n_samples,
            seed=seed,
        ),
        constraints=None,  # type: ignore
        output=None,  # type: ignore
    )


def run_benchmark(
    strategy_name: str,
    search_class: type,
    config: OptimizationConfig,
    fitness_fn: callable,
    **kwargs: Any,
) -> BenchmarkResult:
    """Run a single benchmark."""
    convergence_history: list[float] = []
    best_so_far = float("-inf")

    def objective_fn(params: dict[str, Any]) -> TrialResult:
        nonlocal best_so_far
        score = fitness_fn(params)
        best_so_far = max(best_so_far, score)
        convergence_history.append(best_so_far)

        return TrialResult(
            trial_id=len(convergence_history),
            params=params,
            score=score,
            apex_compliant=True,
            sqn=score / 20,
            sharpe=score / 25,
            sortino=score / 22,
            profit_factor=1 + score / 50,
            total_pnl=score * 10,
            trades=50,
            win_rate=0.5 + score / 200,
            max_drawdown_pct=5 - score / 25,
            wfe=score / 100,
            wfe_std=0.1,
            positive_days_ratio=0.6,
            regime_scores={"trending": score / 100, "ranging": score / 120},
            trailing_dd=2.0,
            daily_profit_max=score * 5,
            daily_dd=1.5,
            time_gate_violations=0,
            overnight_positions=0,
        )

    search = search_class(config, **kwargs)

    start_time = time.perf_counter()
    results = search.search(objective_fn)
    elapsed = time.perf_counter() - start_time

    summary = search.get_study_summary()

    return BenchmarkResult(
        strategy=strategy_name,
        best_score=results[0].score if results else 0,
        best_params=results[0].params if results else {},
        n_evaluations=len(convergence_history),
        time_seconds=elapsed,
        convergence_history=convergence_history,
        extra_metrics=summary.get("levy_metrics", {}),
    )


def print_comparison(results: list[BenchmarkResult]) -> None:
    """Print comparison table."""
    print("\n" + "=" * 70)
    print("BENCHMARK RESULTS: LHS vs Lévy-Enhanced Search")
    print("=" * 70)

    # Header
    print(f"\n{'Strategy':<20} {'Best Score':>12} {'Evals':>8} {'Time (s)':>10} {'Score@50':>10}")
    print("-" * 70)

    for r in results:
        score_at_50 = (
            r.convergence_history[49]
            if len(r.convergence_history) > 49
            else r.convergence_history[-1]
        )
        print(
            f"{r.strategy:<20} {r.best_score:>12.2f} {r.n_evaluations:>8} {r.time_seconds:>10.3f} {score_at_50:>10.2f}"
        )

    print("-" * 70)

    # Analysis
    lhs_result = next((r for r in results if "LHS" in r.strategy), None)
    levy_result = next((r for r in results if "Lévy" in r.strategy), None)

    if lhs_result and levy_result:
        print("\n📊 ANALYSIS:")

        # Best score comparison
        score_diff = levy_result.best_score - lhs_result.best_score
        score_pct = (score_diff / lhs_result.best_score) * 100 if lhs_result.best_score > 0 else 0
        winner = "Lévy" if score_diff > 0 else "LHS"
        print(f"  • Best Score: {winner} wins by {abs(score_diff):.2f} ({abs(score_pct):.1f}%)")

        # Convergence speed (score at 50% of evaluations)
        mid_point = len(lhs_result.convergence_history) // 2
        lhs_mid = (
            lhs_result.convergence_history[mid_point]
            if mid_point < len(lhs_result.convergence_history)
            else lhs_result.best_score
        )
        levy_mid = (
            levy_result.convergence_history[mid_point]
            if mid_point < len(levy_result.convergence_history)
            else levy_result.best_score
        )
        faster = "Lévy" if levy_mid > lhs_mid else "LHS"
        print(
            f"  • Convergence Speed (score @ 50%): {faster} is faster ({levy_mid:.2f} vs {lhs_mid:.2f})"
        )

        # Lévy-specific metrics
        if levy_result.extra_metrics:
            print("\n  📈 Lévy-Enhanced Metrics:")
            for key, value in levy_result.extra_metrics.items():
                print(f"     {key}: {value}")

    # Verdict
    print("\n" + "=" * 70)
    if lhs_result and levy_result:
        if levy_result.best_score > lhs_result.best_score * 1.05:
            print("✅ VERDICT: Lévy-Enhanced is BETTER (>5% improvement)")
            print("   → Recommend integrating into production optimizer")
        elif lhs_result.best_score > levy_result.best_score * 1.05:
            print("❌ VERDICT: LHS baseline is BETTER (>5% better)")
            print("   → Lévy techniques not worth the complexity")
        else:
            print("🔶 VERDICT: SIMILAR performance (<5% difference)")
            print("   → Test on real backtest objective before deciding")
    print("=" * 70)


def main() -> None:
    """Run the benchmark comparison."""
    print("🧪 Spike: Comparing LHS vs Lévy-Enhanced Search")
    print("=" * 70)

    # Configuration
    N_SAMPLES = 150  # Number of evaluations per strategy
    N_RUNS = 3  # Number of runs to average
    SEED_BASE = 42

    all_lhs_scores: list[float] = []
    all_levy_scores: list[float] = []

    for run in range(N_RUNS):
        seed = SEED_BASE + run * 100
        print(f"\n--- Run {run + 1}/{N_RUNS} (seed={seed}) ---")

        config = create_test_config(n_samples=N_SAMPLES, seed=seed)
        fitness_fn = create_synthetic_fitness_landscape(seed=seed)

        results: list[BenchmarkResult] = []

        # Benchmark LHS (baseline)
        print("  Running LHS baseline...", end=" ", flush=True)
        lhs_result = run_benchmark(
            "LHS (baseline)",
            RandomSearch,
            config,
            fitness_fn,
        )
        results.append(lhs_result)
        all_lhs_scores.append(lhs_result.best_score)
        print(f"done (best={lhs_result.best_score:.2f})")

        # Benchmark Lévy-Enhanced
        print("  Running Lévy-Enhanced...", end=" ", flush=True)
        levy_result = run_benchmark(
            "Lévy-Enhanced",
            LevyEnhancedSearch,
            config,
            fitness_fn,
            warmup_samples=20,
            n_elite=5,
        )
        results.append(levy_result)
        all_levy_scores.append(levy_result.best_score)
        print(f"done (best={levy_result.best_score:.2f})")

    # Final comparison (last run details + aggregate)
    print_comparison(results)

    # Aggregate stats
    print(f"\n📊 AGGREGATE STATS ({N_RUNS} runs):")
    print(f"  LHS:  mean={np.mean(all_lhs_scores):.2f}, std={np.std(all_lhs_scores):.2f}")
    print(f"  Lévy: mean={np.mean(all_levy_scores):.2f}, std={np.std(all_levy_scores):.2f}")

    mean_improvement = (
        (np.mean(all_levy_scores) - np.mean(all_lhs_scores)) / np.mean(all_lhs_scores) * 100
    )
    print(f"\n  Lévy improvement: {mean_improvement:+.1f}%")

    if mean_improvement > 5:
        print("\n✅ CONCLUSION: Lévy techniques show consistent improvement")
    elif mean_improvement < -5:
        print("\n❌ CONCLUSION: LHS is consistently better - skip Lévy integration")
    else:
        print("\n🔶 CONCLUSION: Results are mixed - need real backtest validation")


if __name__ == "__main__":
    main()
