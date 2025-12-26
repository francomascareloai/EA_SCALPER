from __future__ import annotations

import argparse
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import TYPE_CHECKING, Any

import numpy as np
import polars as pl
import yaml

if TYPE_CHECKING:
    from numpy.typing import NDArray


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[3]


def _parse_date_utc(date_str: str, *, end_inclusive: bool) -> datetime:
    """Parse a date/datetime string into a tz-aware UTC datetime."""

    s = str(date_str)
    if s.endswith("Z"):
        s = s[:-1] + "+00:00"

    d = datetime.fromisoformat(s)
    if d.tzinfo is None:
        d = d.replace(tzinfo=timezone.utc)
    else:
        d = d.astimezone(timezone.utc)

    if end_inclusive:
        return d + timedelta(days=1)
    return d


def _load_default_ticks_path() -> Path:
    root = _repo_root()
    cfg_path = root / "data" / "config.yaml"
    cfg: Any = yaml.safe_load(cfg_path.read_text(encoding="utf-8"))
    if not isinstance(cfg, dict):
        raise ValueError(f"Invalid YAML config (expected mapping): {cfg_path}")

    active = cfg.get("active_dataset", {})
    if not isinstance(active, dict):
        raise ValueError(f"Invalid YAML config (active_dataset not mapping): {cfg_path}")

    path = active.get("path")
    if not path:
        raise ValueError(f"`active_dataset.path` not found in {cfg_path}")

    return (root / str(path)).resolve()


def _quantize_brick_to_tick(*, brick_usd: float, tick_size: float) -> float:
    """Quantize brick size to an instrument tick.

    # Formula: brick_q = round(brick_usd / tick_size) * tick_size
    # Example: brick_usd=0.75, tick_size=0.01 -> round(75) * 0.01 = 0.75
    """

    if tick_size <= 0:
        raise ValueError(f"tick_size must be > 0, got {tick_size!r}")
    if brick_usd <= 0:
        raise ValueError(f"brick_usd must be > 0, got {brick_usd!r}")

    scaled = brick_usd / tick_size
    q = float(np.rint(scaled))
    brick_q = q * tick_size

    # Sanity: keep within reasonable bounds
    assert brick_q > 0, f"Invalid brick size after quantize: {brick_q}"
    return float(brick_q)


def _build_renko_ohlc(
    *,
    timestamps: NDArray[np.datetime64],
    prices: NDArray[np.float64],
    brick: float,
    reversal_mult: int,
) -> pl.DataFrame:
    if reversal_mult < 1:
        raise ValueError(f"reversal_mult must be >= 1, got {reversal_mult!r}")
    if brick <= 0:
        raise ValueError(f"brick must be > 0, got {brick!r}")
    if timestamps.size == 0:
        raise ValueError("No ticks to build Renko")

    # Use the first price as the initial anchor.
    last_close = float(prices[0])
    if not np.isfinite(last_close):
        raise ValueError("First Renko price is not finite")

    direction = 0  # -1 down, +1 up, 0 unknown
    wick_high = last_close
    wick_low = last_close

    out_ts: list[datetime] = []
    out_o: list[float] = []
    out_h: list[float] = []
    out_l: list[float] = []
    out_c: list[float] = []
    out_v: list[int] = []

    def _emit(*, ts: datetime, close: float) -> None:
        nonlocal last_close, wick_high, wick_low

        open_ = last_close
        close_ = float(close)
        high_ = max(wick_high, open_, close_)
        low_ = min(wick_low, open_, close_)

        out_ts.append(ts)
        out_o.append(open_)
        out_h.append(high_)
        out_l.append(low_)
        out_c.append(close_)
        out_v.append(0)

        last_close = close_
        wick_high = last_close
        wick_low = last_close

    for ts_raw, p_raw in zip(timestamps, prices, strict=True):
        p = float(p_raw)
        if not np.isfinite(p):
            continue

        # Ensure Python datetime for output.
        ts: datetime
        if isinstance(ts_raw, np.datetime64):
            ts = ts_raw.astype("datetime64[ns]").astype(datetime)
        else:
            ts = ts_raw

        wick_high = max(wick_high, p)
        wick_low = min(wick_low, p)

        while True:
            if direction >= 0:
                if p >= last_close + brick:
                    direction = 1
                    _emit(ts=ts, close=last_close + brick)
                    continue
                if direction == 1 and p <= last_close - reversal_mult * brick:
                    direction = -1
                    _emit(ts=ts, close=last_close - brick)
                    continue

            if direction <= 0:
                if p <= last_close - brick:
                    direction = -1
                    _emit(ts=ts, close=last_close - brick)
                    continue
                if direction == -1 and p >= last_close + reversal_mult * brick:
                    direction = 1
                    _emit(ts=ts, close=last_close + brick)
                    continue

            break

    if not out_ts:
        raise ValueError("Renko produced 0 bricks for the selected window")

    df = pl.DataFrame(
        {
            "timestamp": out_ts,
            "open": out_o,
            "high": out_h,
            "low": out_l,
            "close": out_c,
            "volume": out_v,
        }
    )

    df = (
        df.with_columns(pl.col("timestamp").cast(pl.Datetime(time_unit="ns"), strict=False))
        .sort("timestamp")
        .with_columns(pl.col("timestamp").dt.replace_time_zone("UTC").alias("timestamp"))
    )
    return df


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Build Renko OHLCV bricks from tick parquet.")
    p.add_argument("--start", required=True, help="Start date (YYYY-MM-DD or ISO datetime, UTC).")
    p.add_argument(
        "--end",
        required=True,
        help="End date (YYYY-MM-DD or ISO datetime). Date-only is inclusive full day; datetime is inclusive instant.",
    )
    p.add_argument(
        "--ticks-parquet",
        default=None,
        help="Input tick parquet. Defaults to `data/config.yaml:active_dataset.path`.",
    )
    p.add_argument("--brick-usd", type=float, required=True, help="Brick size in USD (e.g., 0.75).")
    p.add_argument(
        "--tick-size",
        type=float,
        default=0.01,
        help="Instrument tick size in USD (default: 0.01 for XAUUSD spot in our sim).",
    )
    p.add_argument(
        "--price",
        choices=["bid", "mid", "ask"],
        default="bid",
        help="Price stream used to build bricks (default: bid, conservative).",
    )
    p.add_argument(
        "--reversal-mult",
        type=int,
        default=2,
        help="Reversal threshold multiplier in bricks (classic Renko uses 2).",
    )
    p.add_argument(
        "--out",
        default=None,
        help="Output parquet path (default: data/derived/renko/xauusd_renko_<brick>_<start>_<end>.parquet).",
    )
    return p.parse_args()


def main() -> int:
    args = parse_args()
    root = _repo_root()

    ticks_path = Path(args.ticks_parquet) if args.ticks_parquet else _load_default_ticks_path()
    if not ticks_path.exists():
        raise FileNotFoundError(f"Tick parquet not found: {ticks_path}")

    start_dt = _parse_date_utc(str(args.start), end_inclusive=False)
    end_dt = _parse_date_utc(str(args.end), end_inclusive=False)
    end_is_date_only = len(str(args.end)) == 10

    brick_q = _quantize_brick_to_tick(
        brick_usd=float(args.brick_usd), tick_size=float(args.tick_size)
    )

    out_path = (
        Path(args.out)
        if args.out
        else root
        / "data"
        / "derived"
        / "renko"
        / f"xauusd_renko_{brick_q:.4f}_{args.start}_{args.end}_{args.price}_rev{int(args.reversal_mult)}.parquet"
    )
    out_path.parent.mkdir(parents=True, exist_ok=True)

    # Treat input ticks as UTC (our dataset timestamps are UTC, but may be tz-naive in Parquet).
    lf = pl.scan_parquet(str(ticks_path)).select(["datetime", "bid", "ask"])
    lf = lf.with_columns(
        pl.col("datetime")
        .cast(pl.Datetime(time_unit="ns", time_zone="UTC"), strict=False)
        .alias("datetime")
    )
    if end_is_date_only:
        end_dt_exclusive = end_dt + timedelta(days=1)
        end_filter = pl.col("datetime") < pl.lit(end_dt_exclusive)
    else:
        end_filter = pl.col("datetime") <= pl.lit(end_dt)

    lf = lf.filter((pl.col("datetime") >= pl.lit(start_dt)) & end_filter).sort("datetime")

    if args.price == "bid":
        lf = lf.select([pl.col("datetime").alias("datetime"), pl.col("bid").alias("price")])
    elif args.price == "ask":
        lf = lf.select([pl.col("datetime").alias("datetime"), pl.col("ask").alias("price")])
    else:
        lf = lf.select(
            [
                pl.col("datetime").alias("datetime"),
                ((pl.col("bid") + pl.col("ask")) / 2.0).alias("price"),
            ]
        )

    try:
        df_ticks = lf.collect(engine="streaming")
    except TypeError:  # pragma: no cover
        df_ticks = lf.collect()

    if df_ticks.is_empty():
        raise ValueError(f"No ticks in window {args.start}..{args.end} from {ticks_path}")

    timestamps = df_ticks.get_column("datetime").to_numpy()
    prices = df_ticks.get_column("price").to_numpy()

    bricks = _build_renko_ohlc(
        timestamps=timestamps,
        prices=prices,
        brick=float(brick_q),
        reversal_mult=int(args.reversal_mult),
    )

    bricks.write_parquet(out_path)
    print(f"Wrote {bricks.height:,} Renko bricks -> {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
