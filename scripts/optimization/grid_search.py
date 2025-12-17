#!/usr/bin/env python3
"""
Grid Search Optimizer for Gold Scalper Strategy
Runs parameter sweeps to find optimal configuration.

Usage:
    python scripts/optimization/grid_search.py --period 2024-09-01:2024-10-31
"""
import argparse
import json
import sys
import subprocess
import itertools
from datetime import datetime
from pathlib import Path
from typing import Any
import yaml

# Project root
PROJECT_ROOT = Path(__file__).parent.parent.parent

# Parameter grid to search
PARAM_GRID = {
    # Confluence thresholds
    "execution_threshold": [40, 50, 60, 70, 80],

    # Filters on/off
    "use_session_filter": [True, False],
    "use_regime_filter": [True, False],

    # Time cutoff
    "cutoff_et": ["16:30", "16:55"],

    # Overnight
    "allow_overnight": [False],  # Must be False for Apex!
}

# Quick grid for faster testing
QUICK_GRID = {
    "execution_threshold": [40, 50, 60],
    "use_session_filter": [False],  # Must be False to allow Late NY session (1-5 PM ET)
    "use_regime_filter": [True, False],
    "cutoff_et": ["16:55"],
    "allow_overnight": [False],
}


def generate_combinations(grid: dict) -> list[dict]:
    """Generate all parameter combinations from grid."""
    keys = list(grid.keys())
    values = [grid[k] for k in keys]
    combinations = []
    for combo in itertools.product(*values):
        combinations.append(dict(zip(keys, combo)))
    return combinations


def update_config(config_path: Path, params: dict) -> dict:
    """Update strategy config with parameters and return original."""
    with open(config_path) as f:
        config = yaml.safe_load(f)

    original = {}

    # Save originals and update
    if "execution_threshold" in params:
        original["confluence.execution_threshold"] = config["confluence"]["execution_threshold"]
        original["execution.execution_threshold"] = config["execution"]["execution_threshold"]
        config["confluence"]["execution_threshold"] = params["execution_threshold"]
        config["execution"]["execution_threshold"] = params["execution_threshold"]

    if "use_session_filter" in params:
        original["execution.use_session_filter"] = config["execution"]["use_session_filter"]
        config["execution"]["use_session_filter"] = params["use_session_filter"]

    if "use_regime_filter" in params:
        original["execution.use_selector"] = config["execution"]["use_selector"]
        config["execution"]["use_selector"] = params["use_regime_filter"]

    if "cutoff_et" in params:
        original["time.cutoff_et"] = config["time"]["cutoff_et"]
        config["time"]["cutoff_et"] = params["cutoff_et"]

    if "allow_overnight" in params:
        original["execution.allow_overnight"] = config["execution"]["allow_overnight"]
        config["execution"]["allow_overnight"] = params["allow_overnight"]

    with open(config_path, 'w') as f:
        yaml.dump(config, f, default_flow_style=False, sort_keys=False)

    return original


def restore_config(config_path: Path, original: dict):
    """Restore config to original values."""
    with open(config_path) as f:
        config = yaml.safe_load(f)

    for key, value in original.items():
        parts = key.split(".")
        if len(parts) == 2:
            config[parts[0]][parts[1]] = value

    with open(config_path, 'w') as f:
        yaml.dump(config, f, default_flow_style=False, sort_keys=False)


def run_backtest(start_date: str, end_date: str, timeout: int = 600) -> dict:
    """Run backtest and parse results."""
    cmd = [
        sys.executable, str(PROJECT_ROOT / "nautilus_gold_scalper/scripts/backtest/run_backtest.py"),
        "--start", start_date,
        "--end", end_date,
    ]

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout,
            cwd=str(PROJECT_ROOT),
        )
        output = result.stdout + result.stderr

        # Parse key metrics from output
        metrics = parse_backtest_output(output)
        metrics["exit_code"] = result.returncode
        return metrics

    except subprocess.TimeoutExpired:
        return {"error": "timeout", "trades": 0}
    except Exception as e:
        return {"error": str(e), "trades": 0}


def parse_backtest_output(output: str) -> dict:
    """Extract metrics from backtest output."""
    metrics = {
        "trades": 0,
        "win_rate": 0.0,
        "profit_factor": 0.0,
        "sharpe": 0.0,
        "pnl": 0.0,
        "max_dd": 0.0,
    }

    lines = output.split("\n")
    for line in lines:
        line_lower = line.lower()

        if "total positions:" in line_lower:
            try:
                metrics["trades"] = int(line.split(":")[-1].strip())
            except:
                pass

        if "win rate:" in line_lower:
            try:
                val = line.split(":")[-1].strip()
                metrics["win_rate"] = float(val)
            except:
                pass

        if "profit factor:" in line_lower:
            try:
                val = line.split(":")[-1].strip()
                if val != "nan":
                    metrics["profit_factor"] = float(val)
            except:
                pass

        if "sharpe ratio" in line_lower:
            try:
                val = line.split(":")[-1].strip()
                if val != "nan":
                    metrics["sharpe"] = float(val)
            except:
                pass

        if "pnl (total):" in line_lower and "%" not in line_lower:
            try:
                val = line.split(":")[-1].strip()
                metrics["pnl"] = float(val)
            except:
                pass

    return metrics


def score_result(metrics: dict) -> float:
    """Score a result for ranking. Higher is better."""
    if metrics.get("error") or metrics.get("trades", 0) < 5:
        return -1000

    # Weighted score
    score = 0.0

    # Trades: want at least 20, cap bonus at 50
    trades = min(metrics.get("trades", 0), 50)
    score += trades * 2  # 0-100 points

    # Win rate: 0-50 points
    wr = metrics.get("win_rate", 0)
    score += wr * 50

    # Profit factor: 0-50 points (capped at 2.0)
    pf = min(metrics.get("profit_factor", 0), 2.0)
    score += pf * 25

    # Sharpe: can be negative, -50 to +50
    sharpe = max(min(metrics.get("sharpe", 0), 2.0), -2.0)
    score += sharpe * 25

    # PnL bonus/penalty
    pnl = metrics.get("pnl", 0)
    score += min(max(pnl, -100), 100)  # -100 to +100

    return score


def main():
    parser = argparse.ArgumentParser(description="Grid search for strategy optimization")
    parser.add_argument("--period", default="2024-10-01:2024-10-31",
                       help="Date range as START:END")
    parser.add_argument("--quick", action="store_true",
                       help="Use reduced grid for faster search")
    parser.add_argument("--timeout", type=int, default=420,
                       help="Timeout per backtest in seconds")
    parser.add_argument("--output", default=None,
                       help="Output JSON file for results")
    args = parser.parse_args()

    start_date, end_date = args.period.split(":")
    grid = QUICK_GRID if args.quick else PARAM_GRID
    combinations = generate_combinations(grid)

    print(f"=" * 60)
    print(f"GRID SEARCH OPTIMIZER")
    print(f"=" * 60)
    print(f"Period: {start_date} to {end_date}")
    print(f"Combinations to test: {len(combinations)}")
    print(f"Grid mode: {'QUICK' if args.quick else 'FULL'}")
    print(f"Timeout per test: {args.timeout}s")
    print(f"=" * 60)

    config_path = PROJECT_ROOT / "nautilus_gold_scalper/configs/strategy_config.yaml"
    results = []

    for i, params in enumerate(combinations, 1):
        print(f"\n[{i}/{len(combinations)}] Testing: {params}")

        # Update config
        original = update_config(config_path, params)

        try:
            # Run backtest
            metrics = run_backtest(start_date, end_date, args.timeout)
            metrics["params"] = params
            metrics["score"] = score_result(metrics)
            results.append(metrics)

            print(f"  -> Trades: {metrics.get('trades', 0)}, "
                  f"WR: {metrics.get('win_rate', 0):.2f}, "
                  f"PF: {metrics.get('profit_factor', 0):.2f}, "
                  f"Sharpe: {metrics.get('sharpe', 0):.2f}, "
                  f"Score: {metrics['score']:.1f}")

        finally:
            # Restore config
            restore_config(config_path, original)

    # Sort by score
    results.sort(key=lambda x: x.get("score", -9999), reverse=True)

    print(f"\n{'=' * 60}")
    print("TOP 5 CONFIGURATIONS")
    print(f"{'=' * 60}")

    for i, r in enumerate(results[:5], 1):
        print(f"\n#{i} (Score: {r['score']:.1f})")
        print(f"   Params: {r['params']}")
        print(f"   Trades: {r.get('trades', 0)}, WR: {r.get('win_rate', 0):.2f}, "
              f"PF: {r.get('profit_factor', 0):.2f}, Sharpe: {r.get('sharpe', 0):.2f}")

    # Save results
    output_path = args.output or f"grid_search_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    output_path = PROJECT_ROOT / ".planning/phases/08-data-validation-backtest/outputs" / output_path

    with open(output_path, 'w') as f:
        json.dump({
            "run_time": datetime.now().isoformat(),
            "period": f"{start_date} to {end_date}",
            "grid": grid,
            "results": results,
        }, f, indent=2, default=str)

    print(f"\nResults saved to: {output_path}")

    # Return best config
    if results and results[0]["score"] > 0:
        print(f"\n{'=' * 60}")
        print("RECOMMENDED CONFIGURATION")
        print(f"{'=' * 60}")
        best = results[0]["params"]
        for k, v in best.items():
            print(f"  {k}: {v}")
        return 0
    else:
        print("\nNo good configuration found. Consider different parameter ranges.")
        return 1


if __name__ == "__main__":
    sys.exit(main())
