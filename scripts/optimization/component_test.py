#!/usr/bin/env python3
"""
Component Isolation Test for Gold Scalper Strategy
Tests each strategy component in isolation to understand contribution.

Usage:
    python scripts/optimization/component_test.py --period 2024-10-01:2024-10-31
"""
import argparse
import json
import sys
import subprocess
from datetime import datetime
from pathlib import Path
import yaml

# Project root
PROJECT_ROOT = Path(__file__).parent.parent.parent

# Test configurations - each isolates a component
TEST_CONFIGS = {
    # Baseline - minimum viable config
    "baseline": {
        "name": "Baseline (MTF+Footprint OFF)",
        "changes": {
            "confluence.min_score_to_trade": 30,
            "confluence.execution_threshold": 30,
            "execution.execution_threshold": 30,
            "execution.use_mtf": False,
            "execution.use_footprint": False,
            "execution.use_session_filter": False,
            "execution.use_regime_filter": False,
            "execution.use_selector": False,
            "fibonacci.enabled": False,
        }
    },

    # Test MTF alone
    "mtf_only": {
        "name": "MTF Only",
        "changes": {
            "confluence.min_score_to_trade": 30,
            "confluence.execution_threshold": 30,
            "execution.execution_threshold": 30,
            "execution.use_mtf": True,
            "execution.use_footprint": False,
            "execution.use_session_filter": False,
            "execution.use_regime_filter": False,
            "execution.use_selector": False,
            "fibonacci.enabled": False,
        }
    },

    # Test Footprint alone
    "footprint_only": {
        "name": "Footprint Only",
        "changes": {
            "confluence.min_score_to_trade": 30,
            "confluence.execution_threshold": 30,
            "execution.execution_threshold": 30,
            "execution.use_mtf": False,
            "execution.use_footprint": True,
            "execution.use_session_filter": False,
            "execution.use_regime_filter": False,
            "execution.use_selector": False,
            "fibonacci.enabled": False,
        }
    },

    # Test Fibonacci alone
    "fib_only": {
        "name": "Fibonacci Only",
        "changes": {
            "confluence.min_score_to_trade": 30,
            "confluence.execution_threshold": 30,
            "execution.execution_threshold": 30,
            "execution.use_mtf": False,
            "execution.use_footprint": False,
            "execution.use_session_filter": False,
            "execution.use_regime_filter": False,
            "execution.use_selector": False,
            "fibonacci.enabled": True,
        }
    },

    # Test MTF + Footprint
    "mtf_footprint": {
        "name": "MTF + Footprint",
        "changes": {
            "confluence.min_score_to_trade": 35,
            "confluence.execution_threshold": 35,
            "execution.execution_threshold": 35,
            "execution.use_mtf": True,
            "execution.use_footprint": True,
            "execution.use_session_filter": False,
            "execution.use_regime_filter": False,
            "execution.use_selector": False,
            "fibonacci.enabled": False,
        }
    },

    # Test All components with low threshold
    "all_low": {
        "name": "All Components (threshold=35)",
        "changes": {
            "confluence.min_score_to_trade": 35,
            "confluence.execution_threshold": 35,
            "execution.execution_threshold": 35,
            "execution.use_mtf": True,
            "execution.use_footprint": True,
            "execution.use_session_filter": False,
            "execution.use_regime_filter": False,
            "execution.use_selector": True,
            "fibonacci.enabled": True,
        }
    },

    # Test with relaxed footprint settings
    "relaxed_footprint": {
        "name": "Relaxed Footprint Settings",
        "changes": {
            "confluence.min_score_to_trade": 30,
            "confluence.execution_threshold": 30,
            "execution.execution_threshold": 30,
            "execution.use_mtf": True,
            "execution.use_footprint": True,
            "execution.use_session_filter": False,
            "execution.use_regime_filter": False,
            "execution.use_selector": False,
            "fibonacci.enabled": False,
            "footprint.imbalance_ratio": 2.0,  # Was 3.0
            "footprint.stacked_min": 2,  # Was 3
            "footprint.score_floor": 30.0,  # Was 40.0
        }
    },

    # Test with regime selector ON
    "regime_selector": {
        "name": "Regime Selector ON",
        "changes": {
            "confluence.min_score_to_trade": 35,
            "confluence.execution_threshold": 35,
            "execution.execution_threshold": 35,
            "execution.use_mtf": True,
            "execution.use_footprint": True,
            "execution.use_session_filter": False,
            "execution.use_regime_filter": False,
            "execution.use_selector": True,
            "fibonacci.enabled": False,
        }
    },

    # Test regime selector at threshold 30
    "regime_t30": {
        "name": "Regime Selector (threshold=30)",
        "changes": {
            "confluence.min_score_to_trade": 30,
            "confluence.execution_threshold": 30,
            "execution.execution_threshold": 30,
            "execution.use_mtf": True,
            "execution.use_footprint": True,
            "execution.use_session_filter": False,
            "execution.use_regime_filter": False,
            "execution.use_selector": True,
            "fibonacci.enabled": False,
        }
    },

    # Test all components at threshold 30 WITHOUT regime selector
    "all_t30_no_regime": {
        "name": "All (t30, no regime)",
        "changes": {
            "confluence.min_score_to_trade": 30,
            "confluence.execution_threshold": 30,
            "execution.execution_threshold": 30,
            "execution.use_mtf": True,
            "execution.use_footprint": True,
            "execution.use_session_filter": False,
            "execution.use_regime_filter": False,
            "execution.use_selector": False,
            "fibonacci.enabled": True,
        }
    },

    # Test threshold 25 with all components
    "all_t25": {
        "name": "All (t25, with regime)",
        "changes": {
            "confluence.min_score_to_trade": 25,
            "confluence.execution_threshold": 25,
            "execution.execution_threshold": 25,
            "execution.use_mtf": True,
            "execution.use_footprint": True,
            "execution.use_session_filter": False,
            "execution.use_regime_filter": False,
            "execution.use_selector": True,
            "fibonacci.enabled": True,
        }
    },

    # Test production-like config (t40 no regime)
    "production_t40": {
        "name": "Production (t40, no regime)",
        "changes": {
            "confluence.min_score_to_trade": 40,
            "confluence.execution_threshold": 40,
            "execution.execution_threshold": 40,
            "execution.use_mtf": True,
            "execution.use_footprint": True,
            "execution.use_session_filter": False,
            "execution.use_regime_filter": False,
            "execution.use_selector": False,
            "fibonacci.enabled": True,
        }
    },
}


def update_config(config_path: Path, changes: dict) -> dict:
    """Update config with changes, return original values."""
    with open(config_path) as f:
        config = yaml.safe_load(f)

    original = {}

    for key, value in changes.items():
        parts = key.split(".")
        if len(parts) == 2:
            section, param = parts
            if section in config and param in config[section]:
                original[key] = config[section][param]
                config[section][param] = value
            else:
                print(f"Warning: {key} not found in config")

    with open(config_path, 'w') as f:
        yaml.dump(config, f, default_flow_style=False, sort_keys=False)

    return original


def restore_config(config_path: Path, original: dict):
    """Restore original config values."""
    with open(config_path) as f:
        config = yaml.safe_load(f)

    for key, value in original.items():
        parts = key.split(".")
        if len(parts) == 2:
            section, param = parts
            config[section][param] = value

    with open(config_path, 'w') as f:
        yaml.dump(config, f, default_flow_style=False, sort_keys=False)


def run_backtest(start_date: str, end_date: str, timeout: int = 420) -> dict:
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
        "fills": 0,
        "win_rate": 0.0,
        "profit_factor": 0.0,
        "sharpe": 0.0,
        "pnl": 0.0,
        "pnl_gross": 0.0,
        "commissions": 0.0,
    }

    lines = output.split("\n")
    for line in lines:
        line_lower = line.lower()

        if "order fills:" in line_lower:
            try:
                metrics["fills"] = int(line.split(":")[-1].strip())
                metrics["trades"] = metrics["fills"] // 2  # 2 fills per round-trip
            except:
                pass

        if "total pnl (net" in line_lower:
            try:
                # Extract value like "$-16.24 (-0.02%)"
                val = line.split(":")[-1].strip()
                val = val.split("(")[0].strip()
                val = val.replace("$", "").replace(",", "")
                metrics["pnl"] = float(val)
            except:
                pass

        if "commissions:" in line_lower:
            try:
                val = line.split(":")[-1].strip()
                val = val.split("(")[0].strip()
                val = val.replace("$", "").replace(",", "")
                metrics["commissions"] = float(val)
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

    return metrics


def main():
    parser = argparse.ArgumentParser(description="Component isolation test")
    parser.add_argument("--period", default="2024-10-01:2024-10-31",
                       help="Date range as START:END")
    parser.add_argument("--timeout", type=int, default=420,
                       help="Timeout per backtest in seconds")
    parser.add_argument("--tests", nargs="+", default=None,
                       help="Specific tests to run (default: all)")
    parser.add_argument("--output", default=None,
                       help="Output JSON file for results")
    args = parser.parse_args()

    start_date, end_date = args.period.split(":")

    # Select tests to run
    if args.tests:
        tests = {k: v for k, v in TEST_CONFIGS.items() if k in args.tests}
    else:
        tests = TEST_CONFIGS

    print("=" * 70)
    print("COMPONENT ISOLATION TEST")
    print("=" * 70)
    print(f"Period: {start_date} to {end_date}")
    print(f"Tests to run: {len(tests)}")
    print(f"Timeout per test: {args.timeout}s")
    print("=" * 70)

    config_path = PROJECT_ROOT / "nautilus_gold_scalper/configs/strategy_config.yaml"
    results = []

    for test_id, test_config in tests.items():
        print(f"\n[{test_id}] {test_config['name']}")
        print(f"  Changes: {list(test_config['changes'].keys())}")

        # Apply changes
        original = update_config(config_path, test_config["changes"])

        try:
            # Run backtest
            metrics = run_backtest(start_date, end_date, args.timeout)
            metrics["test_id"] = test_id
            metrics["test_name"] = test_config["name"]
            metrics["changes"] = test_config["changes"]
            results.append(metrics)

            print(f"  -> Trades: {metrics.get('trades', 0)}, "
                  f"PnL: ${metrics.get('pnl', 0):.2f}, "
                  f"WR: {metrics.get('win_rate', 0):.2f}, "
                  f"Sharpe: {metrics.get('sharpe', 0):.2f}")

        finally:
            # Restore config
            restore_config(config_path, original)

    # Sort by trades (more is better for finding signals)
    results.sort(key=lambda x: (x.get("trades", 0), x.get("pnl", -9999)), reverse=True)

    print(f"\n{'=' * 70}")
    print("RESULTS SUMMARY (sorted by trade count)")
    print(f"{'=' * 70}")

    print(f"\n{'Test Name':<35} {'Trades':>7} {'PnL':>10} {'WR':>7} {'Sharpe':>8}")
    print("-" * 70)
    for r in results:
        print(f"{r['test_name']:<35} {r.get('trades', 0):>7} "
              f"${r.get('pnl', 0):>8.2f} {r.get('win_rate', 0):>6.2f} "
              f"{r.get('sharpe', 0):>8.2f}")

    # Save results
    output_path = args.output or f"component_test_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    output_path = PROJECT_ROOT / ".planning/phases/08-data-validation-backtest/outputs" / output_path

    with open(output_path, 'w') as f:
        json.dump({
            "run_time": datetime.now().isoformat(),
            "period": f"{start_date} to {end_date}",
            "results": results,
        }, f, indent=2, default=str)

    print(f"\nResults saved to: {output_path}")

    # Recommendation
    if results:
        best = results[0]
        print(f"\n{'=' * 70}")
        print("RECOMMENDATION")
        print(f"{'=' * 70}")
        print(f"Best config: {best['test_name']}")
        print(f"Trades: {best.get('trades', 0)}, PnL: ${best.get('pnl', 0):.2f}")
        if best.get('trades', 0) >= 5:
            print("This config generates enough trades for further analysis")
        else:
            print("WARNING: Low trade count - consider relaxing thresholds further")

    return 0


if __name__ == "__main__":
    sys.exit(main())
