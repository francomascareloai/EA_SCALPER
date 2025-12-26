"""
Validate Apex-style prop-firm compliance on a trades/fills CSV.

Checks:
- Cutoff time (default 16:59 ET) and overnight exposure.
- Trailing drawdown using cumulative realized PnL (if available).
- Consistency rule: daily profit must stay < 30% of total profit.

Usage:
    python -m nautilus_gold_scalper.scripts.validate_apex_compliance \\
        --trades logs/backtest_latest/fills.csv \\
        --account-size 100000

Outputs a JSON summary (optional) and prints violations.
"""

from __future__ import annotations

import argparse
from datetime import time, timezone, tzinfo
from pathlib import Path

import pandas as pd

try:
    from zoneinfo import ZoneInfo

    ET_TZ: tzinfo = ZoneInfo("America/New_York")
except Exception:  # pragma: no cover
    ET_TZ = timezone.utc


def _parse_time(s: str) -> time:
    parts = s.split(":")
    return time(int(parts[0]), int(parts[1]) if len(parts) > 1 else 0)


def _parse_timestamp_column(df: pd.DataFrame) -> pd.Series:
    """Find and parse a timestamp column into timezone-aware UTC datetimes."""
    candidates = ["ts_event", "ts_event_ns", "timestamp", "time", "datetime"]
    col = None
    for c in candidates:
        if c in df.columns:
            col = c
            break
    if col is None:
        raise ValueError(
            "No timestamp column found (expected one of ts_event|timestamp|time|datetime)"
        )

    series = df[col]
    # If numeric, assume nanoseconds since epoch
    if pd.api.types.is_numeric_dtype(series):
        series = pd.to_datetime(series, unit="ns", utc=True)
    else:
        series = pd.to_datetime(series, utc=True, errors="coerce")
    if series.isna().any():
        raise ValueError("Timestamp parsing produced NaT values; check input file.")
    return series


def _parse_pnl_column(df: pd.DataFrame) -> pd.Series | None:
    """Best-effort extraction of realized PnL per fill/trade."""
    candidates = ["realized_pnl", "pnl", "pnl_quote", "fill_pnl", "pnl_usd"]
    col = None
    for c in candidates:
        if c in df.columns:
            col = c
            break
    if col is None:
        return None

    series = df[col].copy()
    if series.dtype == object:
        series = series.astype(str).str.replace(" USD", "", regex=False)
    series = pd.to_numeric(series, errors="coerce")
    if series.isna().all():
        return None
    series = series.fillna(0.0)
    return series


def check_cutoff_and_overnight(ts_utc: pd.Series, cutoff: time) -> tuple[int, int]:
    """Return (cutoff_violations, overnight_violations)."""
    # Ensure chronological ordering for boundary detection.
    ts_utc = ts_utc.sort_values()

    ts_et = ts_utc.dt.tz_convert(ET_TZ)
    cutoff_viol = int((ts_et.dt.time >= cutoff).sum())

    # BUG-LIVE-004: `Series.dt.date` produces Python `date` objects (dtype=object),
    # and `diff()` can raise TypeError. Use timezone-aware day buckets instead.
    if len(ts_et) <= 1:
        return cutoff_viol, 0

    day_bucket = ts_et.dt.floor("D")
    # Count day-boundary transitions between consecutive fills.
    transitions = int(day_bucket.ne(day_bucket.shift(1)).sum()) - 1
    overnight = max(0, transitions)

    return cutoff_viol, overnight


def check_trailing_dd(pnl_series: pd.Series, account_size: float, dd_limit: float) -> float:
    """Compute max trailing DD percentage given per-fill PnL."""
    equity = account_size + pnl_series.cumsum()
    hwm = equity.cummax()
    dd = (hwm - equity) / hwm
    return float(dd.max()) if len(dd) else 0.0


def check_consistency(pnl_series: pd.Series, ts_utc: pd.Series, limit: float) -> float:
    """Return max daily/total profit ratio (0-1)."""
    if pnl_series is None or pnl_series.empty:
        return 0.0
    df = pd.DataFrame({"pnl": pnl_series, "ts": ts_utc.dt.tz_convert(ET_TZ)})
    df["date"] = df["ts"].dt.date
    daily = df.groupby("date")["pnl"].sum()
    total = df["pnl"].sum()
    if total <= 0:
        return 0.0
    ratios = daily / total
    return float(ratios.max())


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Validate Apex prop-firm compliance on trades/fills CSV"
    )
    parser.add_argument(
        "--trades",
        type=Path,
        default=Path("logs/backtest_latest/fills.csv"),
        help="Path to fills/trades CSV",
    )
    parser.add_argument(
        "--account-size", type=float, default=100_000.0, help="Starting equity for DD calc"
    )
    parser.add_argument(
        "--dd-limit",
        type=float,
        default=0.05,
        help="Trailing DD hard limit (fraction, e.g., 0.05 = 5% Apex)",
    )
    parser.add_argument(
        "--consistency-limit",
        type=float,
        default=0.25,
        help="Daily profit / total profit limit (fraction)",
    )
    parser.add_argument("--cutoff", type=str, default="16:59", help="Cutoff time ET HH:MM")
    parser.add_argument("--output", type=Path, default=None, help="Optional JSON output path")
    args = parser.parse_args()

    if not args.trades.exists():
        raise FileNotFoundError(f"Trades file not found: {args.trades}")

    df = pd.read_csv(args.trades)
    ts_utc = _parse_timestamp_column(df)
    pnl = _parse_pnl_column(df)

    cutoff_time = _parse_time(args.cutoff)
    cutoff_viol, overnight_viol = check_cutoff_and_overnight(ts_utc, cutoff_time)

    max_dd = check_trailing_dd(pnl, args.account_size, args.dd_limit) if pnl is not None else None
    consistency_ratio = (
        check_consistency(pnl, ts_utc, args.consistency_limit) if pnl is not None else None
    )

    violations = []
    if cutoff_viol > 0:
        violations.append(f"Cutoff violations: {cutoff_viol}")
    if overnight_viol > 0:
        violations.append(f"Overnight exposures detected: {overnight_viol}")
    if max_dd is not None and max_dd > args.dd_limit:
        violations.append(
            f"Trailing DD {max_dd * 100:.2f}% exceeds limit {args.dd_limit * 100:.2f}%"
        )
    if consistency_ratio is not None and consistency_ratio >= args.consistency_limit:
        violations.append(
            f"Consistency ratio {consistency_ratio * 100:.2f}% >= limit {args.consistency_limit * 100:.2f}%"
        )

    summary = {
        "trades_file": str(args.trades),
        "cutoff_time_et": args.cutoff,
        "cutoff_violations": cutoff_viol,
        "overnight_violations": overnight_viol,
        "max_trailing_dd_pct": None if max_dd is None else round(max_dd * 100, 2),
        "dd_limit_pct": args.dd_limit * 100,
        "consistency_ratio_pct": None
        if consistency_ratio is None
        else round(consistency_ratio * 100, 2),
        "consistency_limit_pct": args.consistency_limit * 100,
        "passed": len(violations) == 0,
        "violations": violations,
    }

    print("=== Apex Compliance Check ===")
    for k, v in summary.items():
        if k == "violations":
            continue
        print(f"{k}: {v}")
    if violations:
        print("\nVIOLATIONS:")
        for v in violations:
            print(f"- {v}")
    else:
        print("\nPASS: No compliance violations detected.")

    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        import json

        with open(args.output, "w", encoding="utf-8") as f:
            json.dump(summary, f, indent=2)


if __name__ == "__main__":
    main()
