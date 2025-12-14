"""
Batch backtester to sweep multiple strategy parameter combinations.

Usage (examples):
  python scripts/batch_backtest.py --start 2024-01-01 --end 2024-12-31 --max-runs 10
  python scripts/batch_backtest.py --start 2020-01-01 --end 2025-12-31 --max-runs 50

Notes:
- Uses the same data file as run_backtest.py
- Writes a summary CSV to reports/backtests/batch_summary_<timestamp>.csv
- Each run creates a temporary YAML derived from configs/strategy_config.yaml
"""
from __future__ import annotations

import argparse
import itertools
import tempfile
from pathlib import Path
from datetime import datetime
import yaml
import pandas as pd

from run_backtest import load_data, BacktestEngine


BASE_CONFIG = Path("configs/strategy_config.yaml")
DATA_PATH = Path("..") / "Python_Agent_Hub" / "ml_pipeline" / "data" / "Bars_2020-2025XAUUSD_ftmo-M5-No Session.csv"
REPORT_DIR = Path("reports/backtests")


def build_param_grid():
    """Return a list of parameter dicts (cartesian product) trimmed later by max_runs."""
    min_score = [50, 60, 70]
    risk_pct = [0.005, 0.01, 0.015]  # 0.5%, 1%, 1.5%
    spread_warn = [1.5, 2.0]
    spread_block = [3.5, 4.5]
    stack_decay_30 = [0.6, 0.75]
    stack_decay_60 = [0.45, 0.55]
    absorption_threshold = [12.0, 15.0]

    grid = []
    for ms, rp, sw, sb, sd30, sd60, abs_th in itertools.product(
        min_score, risk_pct, spread_warn, spread_block, stack_decay_30, stack_decay_60, absorption_threshold
    ):
        grid.append(
            {
                "min_score_to_trade": ms,
                "max_risk_per_trade": rp,
                "spread_warning": sw,
                "spread_block": sb,
                "stack_decay_30m": sd30,
                "stack_decay_60m": sd60,
                "absorption_threshold": abs_th,
            }
        )
    return grid


def make_config(base_cfg: dict, params: dict) -> str:
    """Write a temp YAML merging base config with param overrides; return file path."""
    cfg = base_cfg.copy()
    cfg.setdefault("confluence", {})
    cfg.setdefault("risk", {})
    cfg.setdefault("spread", {})
    cfg.setdefault("footprint", {})

    cfg["confluence"]["min_score_to_trade"] = params["min_score_to_trade"]
    cfg["risk"]["max_risk_per_trade"] = params["max_risk_per_trade"]
    cfg["spread"]["warning_ratio"] = params["spread_warning"]
    cfg["spread"]["block_ratio"] = params["spread_block"]
    cfg["footprint"]["stack_decay_30m"] = params["stack_decay_30m"]
    cfg["footprint"]["stack_decay_60m"] = params["stack_decay_60m"]
    cfg["footprint"]["absorption_threshold"] = params["absorption_threshold"]

    tmp = tempfile.NamedTemporaryFile(delete=False, suffix=".yaml")
    with open(tmp.name, "w") as f:
        yaml.safe_dump(cfg, f)
    return tmp.name


def run_batch(start: str, end: str, max_runs: int):
    if not DATA_PATH.exists():
        raise FileNotFoundError(f"Data file not found: {DATA_PATH}")
    if not BASE_CONFIG.exists():
        raise FileNotFoundError(f"Base config not found: {BASE_CONFIG}")

    base_cfg = yaml.safe_load(BASE_CONFIG.read_text())

    df = load_data(str(DATA_PATH), start_date=start, end_date=end)
    param_grid = build_param_grid()
    runs = param_grid[: max_runs]

    results = []
    REPORT_DIR.mkdir(parents=True, exist_ok=True)

    for idx, params in enumerate(runs, 1):
        print(f"\n=== Run {idx}/{len(runs)} | params={params} ===")
        cfg_path = make_config(base_cfg, params)
        engine = BacktestEngine(initial_balance=100_000.0, use_circuit_breaker=False, config_path=cfg_path)
        engine.run(df, lookback=200)

        # Aggregate stats
        total_trades = len(engine.trades)
        winners = sum(1 for t in engine.trades if t["pnl_dollars"] > 0)
        losers = total_trades - winners
        win_rate = (winners / total_trades * 100) if total_trades else 0.0
        pnl = sum(t["pnl_dollars"] for t in engine.trades)
        ret_pct = (engine.balance - engine.initial_balance) / engine.initial_balance * 100
        max_dd_pct = engine.max_drawdown_pct * 100

        # Profit factor
        win_sum = sum(t["pnl_dollars"] for t in engine.trades if t["pnl_dollars"] > 0)
        loss_sum = -sum(t["pnl_dollars"] for t in engine.trades if t["pnl_dollars"] < 0)
        pf = win_sum / loss_sum if loss_sum > 0 else 0.0

        strat_pnl = {}
        for t in engine.trades:
            strat_pnl.setdefault(t["strategy"], 0.0)
            strat_pnl[t["strategy"]] += t["pnl_dollars"]

        results.append(
            {
                **params,
                "total_trades": total_trades,
                "win_rate": win_rate,
                "pnl": pnl,
                "ret_pct": ret_pct,
                "max_dd_pct": max_dd_pct,
                "profit_factor": pf,
                "pnl_trend": strat_pnl.get("STRATEGY_TREND_FOLLOW", 0.0),
                "pnl_mean_revert": strat_pnl.get("STRATEGY_MEAN_REVERT", 0.0),
            }
        )

    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    summary_path = REPORT_DIR / f"batch_summary_{ts}.csv"
    pd.DataFrame(results).to_csv(summary_path, index=False)
    print(f"\nBatch summary saved to {summary_path}")

    # Show top performers
    df_res = pd.DataFrame(results)
    print("\nTop 5 by return:")
    print(df_res.sort_values("ret_pct", ascending=False).head(5)[["ret_pct", "profit_factor", "total_trades", "max_dd_pct", "min_score_to_trade", "max_risk_per_trade", "spread_warning", "spread_block"]])
    print("\nTop 5 by profit factor:")
    print(df_res.sort_values("profit_factor", ascending=False).head(5)[["profit_factor", "ret_pct", "total_trades", "max_dd_pct", "min_score_to_trade", "max_risk_per_trade", "spread_warning", "spread_block"]])


def parse_args():
    p = argparse.ArgumentParser(description="Batch backtester for Nautilus Gold Scalper.")
    p.add_argument("--start", type=str, default="2024-01-01", help="Start date (YYYY-MM-DD)")
    p.add_argument("--end", type=str, default="2024-12-31", help="End date (YYYY-MM-DD)")
    p.add_argument("--max-runs", type=int, default=50, help="Number of parameter combos to run")
    return p.parse_args()


if __name__ == "__main__":
    args = parse_args()
    run_batch(start=args.start, end=args.end, max_runs=args.max_runs)
