#!/usr/bin/env python3
"""
studio.py - Unified runner for EA parity backtests
Usage:
  python scripts/backtest/studio.py --ticks data/processed/ticks_2024.parquet --max-ticks 2000000
Options:
  --ticks PATH           Tick file (parquet/csv)
  --max-ticks N          Max ticks to load from tail (default: 2_000_000)
  --mode {ea,legacy}     Use EA parity (default: ea) or legacy MA cross
  --output PATH          Optional CSV for trades
"""

import argparse
import os
from pathlib import Path
import pandas as pd

from scripts.backtest.tick_backtester import BacktestConfig, TickBacktester, ExecutionMode


def load_ticks(path: str, max_ticks: int):
    path = Path(path)
    if path.suffix.lower() == ".parquet":
        df = pd.read_parquet(path)
        if max_ticks:
            df = df.tail(max_ticks)
        # Expect columns: timestamp, bid, ask or mid_price/spread
        if "bid" in df.columns and "ask" in df.columns:
            df["mid_price"] = (df["bid"] + df["ask"]) / 2
            df["spread"] = df["ask"] - df["bid"]
        elif "mid_price" not in df.columns:
            raise ValueError("Parquet must have bid/ask or mid_price")
        return df
    else:
        # CSV tail read
        file_size = os.path.getsize(path)
        bytes_to_read = min(max_ticks * 40, file_size) if max_ticks else file_size
        rows = []
        with open(path, "rb") as f:
            f.seek(max(0, file_size - bytes_to_read))
            f.readline()
            for line in f:
                parts = line.decode("utf-8").strip().split(",")
                if len(parts) < 3:
                    continue
                rows.append(parts)
        df = pd.DataFrame(rows, columns=["datetime", "bid", "ask"])
        df["bid"] = df["bid"].astype(float)
        df["ask"] = df["ask"].astype(float)
        df["mid_price"] = (df["bid"] + df["ask"]) / 2
        df["spread"] = df["ask"] - df["bid"]
        df["datetime"] = pd.to_datetime(df["datetime"])
        df = df.set_index("datetime")
        return df


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--ticks", required=True)
    ap.add_argument("--max-ticks", type=int, default=2_000_000)
    ap.add_argument("--mode", choices=["ea", "legacy"], default="ea")
    ap.add_argument("--output", help="Optional trades CSV")
    args = ap.parse_args()

    ticks = load_ticks(args.ticks, args.max_ticks)
    cfg = BacktestConfig(
        execution_mode=ExecutionMode.PESSIMISTIC,
        use_ea_logic=args.mode == "ea",
        bar_timeframe="5min",
    )

    bt = TickBacktester(cfg)
    results = bt.run(args.ticks, max_ticks=args.max_ticks)

    if args.output:
        import pandas as pd

        trades = pd.DataFrame([t.__dict__ for t in bt.trades])
        trades.to_csv(args.output, index=False)
        print(f"[studio] Trades saved to {args.output}")

    print(results["metrics"])


if __name__ == "__main__":
    main()
