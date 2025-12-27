"""
Validate Apex-style prop-firm compliance on a trades/fills CSV.

Checks:
- Cutoff time (default 16:59 ET) and overnight exposure.
- Trailing drawdown using cumulative realized PnL (if available).
- Consistency rule: daily profit must stay < 30% of total profit.

Usage:
    python -m nautilus_gold_scalper.scripts.validate_apex_compliance \\
        --trades logs/backtest_latest/fills.csv \\
        --positions logs/backtest_latest/positions.csv \\
        --telemetry logs/backtest_latest/telemetry.jsonl \\
        --account-size 100000

Outputs a JSON summary (optional) and prints violations.

Note on DD calculation (INSTITUTIONAL-GRADE):
    By default, --require-telemetry is True, meaning telemetry MUST be provided
    for DD validation to pass. This is because Apex trailing DD uses HWM + unrealized
    equity, which cannot be accurately computed from realized-only fills/positions.

    When --telemetry is provided, DD is extracted from circuit_state/dd_snapshot events
    which track unrealized equity intrabar (most accurate for Apex compliance).

    Use --no-require-telemetry for approximate realized-only DD (NOT recommended for
    production Apex compliance validation). In this mode, trailing DD is computed from
    cumulative closed-position profits, which may underestimate DD during adverse
    excursions before position close.
"""

from __future__ import annotations

import argparse
import json
from datetime import time, timezone, tzinfo
from pathlib import Path
from typing import NamedTuple

import pandas as pd

try:
    from zoneinfo import ZoneInfo

    ET_TZ: tzinfo = ZoneInfo("America/New_York")
except Exception:  # pragma: no cover
    ET_TZ = timezone.utc


class TelemetryDDResult(NamedTuple):
    """Result of parsing telemetry for DD values."""

    max_total_dd_pct: float | None
    max_daily_dd_pct: float | None
    parse_error: bool


def _parse_telemetry_dd(telemetry_path: Path) -> TelemetryDDResult:
    """
    Parse telemetry JSONL and extract max DD values from circuit_state and dd_snapshot events.

    The circuit_state events contain:
    - daily_dd: Daily drawdown percentage (from session start)
    - total_dd: Trailing drawdown percentage (from HWM, includes unrealized)

    The dd_snapshot events contain the same fields and are emitted whenever a new
    max DD is reached (on every tick, not just level changes), providing more
    accurate peak DD values for Apex compliance validation.

    Returns:
        TelemetryDDResult with max values. If the file cannot be parsed due to IO or
        JSON decoding errors, returns (None, None, True) so callers can explicitly
        fall back to fills/positions.

    Note: "strict" behavior (treating missing DD events as a failure) is handled
    at the call site, because it depends on CLI flags.
    """
    if not telemetry_path.exists():
        return TelemetryDDResult(None, None, False)

    max_total_dd: float | None = None
    max_daily_dd: float | None = None

    try:
        with telemetry_path.open("r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    record = json.loads(line)
                except json.JSONDecodeError:
                    # Malformed telemetry: mark as parse error so callers can fall back.
                    return TelemetryDDResult(None, None, True)

                event_type = record.get("event")
                # Parse both circuit_state and dd_snapshot events for DD values
                if event_type not in ("circuit_state", "dd_snapshot"):
                    continue

                # Extract DD values (already in percentage form from CircuitBreakerState)
                total_dd = record.get("total_dd")
                daily_dd = record.get("daily_dd")

                if total_dd is not None:
                    try:
                        total_dd_float = float(total_dd)
                        if max_total_dd is None or total_dd_float > max_total_dd:
                            max_total_dd = total_dd_float
                    except (ValueError, TypeError):
                        pass

                if daily_dd is not None:
                    try:
                        daily_dd_float = float(daily_dd)
                        if max_daily_dd is None or daily_dd_float > max_daily_dd:
                            max_daily_dd = daily_dd_float
                    except (ValueError, TypeError):
                        pass

    except OSError:
        # File read error: mark as parse error so callers can fall back.
        return TelemetryDDResult(None, None, True)

    return TelemetryDDResult(max_total_dd, max_daily_dd, False)


def _parse_time(s: str) -> time:
    parts = s.split(":")
    return time(int(parts[0]), int(parts[1]) if len(parts) > 1 else 0)


def _parse_timestamp_column(df: pd.DataFrame) -> pd.Series:
    """Find and parse a timestamp column into timezone-aware UTC datetimes."""
    candidates = [
        "ts_closed",  # positions.csv: prefer closed timestamp
        "ts_opened",  # positions.csv: fallback to opened timestamp
        "ts_event",
        "ts_event_ns",
        "ts_last",
        "ts_init",
        "timestamp",
        "time",
        "datetime",
    ]
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


def _load_positions_pnl_and_ts(
    positions_path: Path,
) -> tuple[pd.Series | None, pd.Series | None]:
    """
    Load positions CSV and extract realized PnL + timestamps.

    Returns:
        (pnl_series, ts_utc_series) - both may be None if parsing fails.
    """
    if not positions_path.exists():
        return None, None

    df = pd.read_csv(positions_path)
    if df.empty:
        return None, None

    pnl = _parse_pnl_column(df)
    if pnl is None:
        return None, None

    ts_utc = _parse_timestamp_column(df)
    return pnl, ts_utc


def _count_overnight_for_group(group_df: pd.DataFrame, ts_col: str) -> int:
    """
    Count overnight violations for a single position group.

    Tracks position via signed quantity (BUY=+1, SELL=-1) * filled_qty.
    An overnight violation occurs when a position is opened on one ET date
    and closed (or still open at end) on a different ET date.

    Returns count of such overnight episodes.
    """
    if group_df.empty:
        return 0

    # Sort chronologically by ET timestamp
    df = group_df.sort_values(ts_col).reset_index(drop=True)

    overnight_count = 0
    position = 0.0
    open_date = None  # ET date when position went from 0 to nonzero

    # Tolerance for floating point comparison (1e-9 handles lot sizing precision)
    tol = 1e-9

    def is_flat(pos: float) -> bool:
        return abs(pos) < tol

    for _, row in df.iterrows():
        # Compute signed delta: BUY=+1, SELL=-1
        side = str(row.get("side", "")).upper()
        sign = 1.0 if side == "BUY" else -1.0 if side == "SELL" else 0.0

        # Prefer filled_qty over quantity
        qty = row.get("filled_qty")
        if pd.isna(qty):
            qty = row.get("quantity", 0.0)
        qty = float(qty) if not pd.isna(qty) else 0.0

        delta = sign * qty
        was_flat = is_flat(position)
        position += delta
        now_flat = is_flat(position)

        ts_et = row[ts_col]
        current_date = ts_et.date()

        # Detect open: flat -> non-flat
        if was_flat and not now_flat:
            open_date = current_date

        # Detect close: non-flat -> flat
        elif not was_flat and now_flat:
            if open_date is not None and open_date != current_date:
                overnight_count += 1
            open_date = None

    # If still in position at end of stream, check if overnight
    if not is_flat(position) and open_date is not None:
        # Use last event date as reference
        last_date = df[ts_col].iloc[-1].date()
        if open_date != last_date:
            overnight_count += 1

    return overnight_count


def check_cutoff_and_overnight(
    df: pd.DataFrame, ts_utc: pd.Series, cutoff: time
) -> tuple[int, int]:
    """
    Return (cutoff_violations, overnight_violations).

    - cutoff_violations: count of fills with ET time >= cutoff.
    - overnight_violations: count of position-holding episodes that span an ET
      date boundary (opened on one ET date, closed on a different ET date).

    Position tracking uses signed quantity (BUY=+1, SELL=-1) * filled_qty.
    Groups by available columns among [account_id, instrument_id, strategy_id,
    trader_id]. If none present, treats all fills as a single stream.

    Fallback: if required column 'side' is missing, falls back to legacy
    day-boundary transition counting (may overcount on multi-day backtests).
    """
    # Ensure chronological ordering for cutoff check
    sorted_idx = ts_utc.argsort()
    ts_sorted = ts_utc.iloc[sorted_idx]

    ts_et = ts_sorted.dt.tz_convert(ET_TZ)
    cutoff_viol = int((ts_et.dt.time >= cutoff).sum())

    # --- Position-aware overnight detection ---
    # Check if we have required columns for position tracking
    if "side" not in df.columns:
        # Fallback to legacy day-boundary heuristic (may overcount)
        # This preserves old behavior when fills lack side info.
        if len(ts_et) <= 1:
            return cutoff_viol, 0
        day_bucket = ts_et.dt.floor("D")
        transitions = int(day_bucket.ne(day_bucket.shift(1)).sum()) - 1
        overnight = max(0, transitions)
        return cutoff_viol, overnight

    # Build working dataframe with ET timestamps
    work_df = df.iloc[sorted_idx].copy()
    work_df["_ts_et"] = ts_et.values

    # Determine grouping columns (use those present in data)
    group_candidates = ["account_id", "instrument_id", "strategy_id", "trader_id"]
    group_cols = [c for c in group_candidates if c in work_df.columns]

    if not group_cols:
        # No grouping columns; treat as single stream
        overnight = _count_overnight_for_group(work_df, "_ts_et")
    else:
        # Sum overnight violations across all groups
        overnight = 0
        for _, grp_df in work_df.groupby(group_cols, dropna=False):
            overnight += _count_overnight_for_group(grp_df, "_ts_et")

    return cutoff_viol, overnight


def check_trailing_dd(pnl_series: pd.Series, account_size: float, dd_limit: float) -> float:
    """Compute max trailing DD percentage given per-fill PnL."""
    equity = account_size + pnl_series.cumsum()
    hwm = equity.cummax()
    dd = (hwm - equity) / hwm
    return float(dd.max()) if len(dd) else 0.0


def check_consistency(pnl_series: pd.Series, ts_utc: pd.Series, limit: float) -> float:
    """Return max daily/total profit ratio (0-1).

    NOTE: Consistency checks are not meaningful with only a single trading day of data.
    In that case daily_profit == total_profit, yielding a ratio of 1.0 and a false
    "violation" for any limit < 1.0. We therefore apply the rule only when the
    sample spans at least 2 ET dates.
    """
    if pnl_series is None or pnl_series.empty:
        return 0.0
    df = pd.DataFrame({"pnl": pnl_series, "ts": ts_utc.dt.tz_convert(ET_TZ)})
    df["date"] = df["ts"].dt.date

    daily = df.groupby("date")["pnl"].sum()
    if len(daily) < 2:
        return 0.0

    total = df["pnl"].sum()
    if total <= 0:
        return 0.0
    ratios = daily / total
    return float(ratios.max())


def validate_compliance_from_paths(
    *,
    trades_path: Path,
    positions_path: Path | None = None,
    telemetry_path: Path | None = None,
    account_size: float = 100_000.0,
    dd_limit: float = 0.05,
    daily_dd_limit: float = 0.03,
    consistency_limit: float = 0.30,
    cutoff: str = "16:59",
    require_telemetry: bool = True,
    telemetry_strict: bool | None = None,
    output_path: Path | None = None,
) -> dict[str, object]:
    """
    Validate Apex prop-firm compliance from file paths (in-process, no subprocess).

    This is the programmatic API for certification mode. Returns a summary dict
    with the same structure as the CLI output.

    Args:
        trades_path: Path to fills/trades CSV (required).
        positions_path: Optional path to positions CSV.
        telemetry_path: Optional path to telemetry JSONL.
        account_size: Starting equity for DD calculation.
        dd_limit: Trailing DD hard limit (fraction, e.g., 0.05 = 5%).
        daily_dd_limit: Daily DD hard limit (fraction, e.g., 0.03 = 3%).
        consistency_limit: Daily profit / total profit limit (fraction).
        cutoff: Cutoff time ET in HH:MM format.
        require_telemetry: If True, telemetry is required for DD validation.
        telemetry_strict: When require_telemetry=False, controls fallback behavior.
        output_path: Optional path to write JSON output.

    Returns:
        Summary dict with 'passed' bool and 'violations' list.

    Raises:
        FileNotFoundError: If trades_path does not exist.
    """
    if telemetry_strict is None:
        telemetry_strict = telemetry_path is not None

    if not trades_path.exists():
        raise FileNotFoundError(f"Trades file not found: {trades_path}")

    df = pd.read_csv(trades_path)
    ts_utc = _parse_timestamp_column(df)
    pnl = _parse_pnl_column(df)
    pnl_ts = ts_utc

    pnl_source = "fills"
    if positions_path is not None:
        pos_pnl, pos_ts = _load_positions_pnl_and_ts(positions_path)
        if pos_pnl is not None and pos_ts is not None:
            pnl = pos_pnl
            pnl_ts = pos_ts
            pnl_source = "positions"

    cutoff_time = _parse_time(cutoff)
    cutoff_viol, overnight_viol = check_cutoff_and_overnight(df, ts_utc, cutoff_time)

    max_dd: float | None = None
    max_daily_dd: float | None = None
    dd_source: str | None = None
    dd_is_mtm_unrealized: bool = False
    telemetry_strict_failed = False

    violations: list[str] = []

    if require_telemetry:
        if telemetry_path is None:
            violations.append(
                "Telemetry is required for DD validation (trailing DD uses HWM + unrealized). "
                "Provide telemetry_path or set require_telemetry=False for approximate realized-only DD."
            )
        else:
            telem_result = _parse_telemetry_dd(telemetry_path)
            dd_source = "telemetry"

            if telem_result.parse_error:
                violations.append(
                    "Telemetry file is malformed or unreadable. "
                    "DD validation requires valid telemetry with circuit_state or dd_snapshot events."
                )
            elif telem_result.max_total_dd_pct is None:
                violations.append(
                    "Telemetry provided but no DD events found (circuit_state or dd_snapshot). "
                    "DD validation requires telemetry with intrabar unrealized equity tracking."
                )
            else:
                max_dd = telem_result.max_total_dd_pct / 100.0
                max_daily_dd = (
                    telem_result.max_daily_dd_pct / 100.0
                    if telem_result.max_daily_dd_pct is not None
                    else None
                )
                dd_is_mtm_unrealized = True
    else:
        if telemetry_path is not None:
            telem_result = _parse_telemetry_dd(telemetry_path)
            if telem_result.max_total_dd_pct is not None:
                max_dd = telem_result.max_total_dd_pct / 100.0
                max_daily_dd = (
                    telem_result.max_daily_dd_pct / 100.0
                    if telem_result.max_daily_dd_pct is not None
                    else None
                )
                dd_source = "telemetry"
                dd_is_mtm_unrealized = True
            elif telem_result.parse_error:
                dd_source = None
            elif telemetry_strict:
                telemetry_strict_failed = True
                dd_source = "telemetry"

        if dd_source is None and pnl is not None:
            max_dd = check_trailing_dd(pnl, account_size, dd_limit)
            dd_source = pnl_source

    consistency_ratio = (
        check_consistency(pnl, pnl_ts, consistency_limit) if pnl is not None else None
    )

    if telemetry_strict_failed:
        violations.append(
            "Telemetry provided but no DD events found (strict mode requires circuit_state or dd_snapshot events)"
        )

    if cutoff_viol > 0:
        violations.append(f"Cutoff violations: {cutoff_viol}")
    if overnight_viol > 0:
        violations.append(f"Overnight exposures detected: {overnight_viol}")
    if max_dd is not None and max_dd > dd_limit:
        violations.append(f"Trailing DD {max_dd * 100:.2f}% exceeds limit {dd_limit * 100:.2f}%")
    if max_daily_dd is not None and max_daily_dd > daily_dd_limit:
        violations.append(
            f"Daily DD {max_daily_dd * 100:.2f}% exceeds limit {daily_dd_limit * 100:.2f}%"
        )
    if consistency_ratio is not None and consistency_ratio >= consistency_limit:
        violations.append(
            f"Consistency ratio {consistency_ratio * 100:.2f}% >= limit {consistency_limit * 100:.2f}%"
        )

    summary: dict[str, object] = {
        "trades_file": str(trades_path),
        "positions_file": str(positions_path) if positions_path else None,
        "telemetry_file": str(telemetry_path) if telemetry_path else None,
        "require_telemetry": require_telemetry,
        "telemetry_strict": telemetry_strict,
        "dd_source": dd_source,
        "dd_is_mtm_unrealized": dd_is_mtm_unrealized,
        "cutoff_time_et": cutoff,
        "cutoff_violations": cutoff_viol,
        "overnight_violations": overnight_viol,
        "max_trailing_dd_pct": None if max_dd is None else round(max_dd * 100, 2),
        "max_daily_dd_pct": None if max_daily_dd is None else round(max_daily_dd * 100, 2),
        "dd_limit_pct": dd_limit * 100,
        "daily_dd_limit_pct": daily_dd_limit * 100,
        "consistency_ratio_pct": None
        if consistency_ratio is None
        else round(consistency_ratio * 100, 2),
        "consistency_limit_pct": consistency_limit * 100,
        "passed": len(violations) == 0,
        "violations": violations,
    }

    if output_path:
        output_path.parent.mkdir(parents=True, exist_ok=True)
        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(summary, f, indent=2)

    return summary


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
        "--positions",
        type=Path,
        default=None,
        help="Optional path to positions CSV (provides realized_pnl for DD/consistency)",
    )
    parser.add_argument(
        "--telemetry",
        type=Path,
        default=None,
        help="Optional path to telemetry JSONL (provides intrabar DD from circuit_state events)",
    )
    parser.add_argument(
        "--account-size", type=float, default=100_000.0, help="Starting equity for DD calc"
    )
    parser.add_argument(
        "--dd-limit",
        type=float,
        default=0.05,
        help="Trailing DD hard limit (fraction, e.g., 0.05 = 5 percent Apex)",
    )
    parser.add_argument(
        "--consistency-limit",
        type=float,
        default=0.25,
        help="Daily profit / total profit limit (fraction)",
    )
    parser.add_argument("--cutoff", type=str, default="16:59", help="Cutoff time ET HH:MM")
    parser.add_argument("--output", type=Path, default=None, help="Optional JSON output path")
    parser.add_argument(
        "--require-telemetry",
        action=argparse.BooleanOptionalAction,
        default=True,
        help=(
            "Require telemetry for DD validation (institutional-grade). "
            "When True (default), validation FAILS if telemetry is missing, unparseable, "
            "or contains no DD events. Use --no-require-telemetry for approximate "
            "realized-only DD (not recommended for Apex compliance)."
        ),
    )
    parser.add_argument(
        "--telemetry-strict",
        action=argparse.BooleanOptionalAction,
        default=None,
        help=(
            "When --no-require-telemetry is used with --telemetry, this controls whether "
            "missing DD events fails or falls back to realized PnL. "
            "Ignored when --require-telemetry is True (strictness is implied). "
            "Default: True when --telemetry is provided."
        ),
    )
    parser.add_argument(
        "--daily-dd-limit",
        type=float,
        default=0.03,
        help="Daily DD hard limit (fraction, e.g., 0.03 = 3 percent HALT per CLAUDE.md)",
    )
    args = parser.parse_args()

    # Resolve require_telemetry (already has default=True)
    require_telemetry: bool = args.require_telemetry

    # Resolve telemetry-strict default: True when telemetry provided, False otherwise
    # Only matters when require_telemetry=False (when True, strictness is implied)
    telemetry_strict = args.telemetry_strict
    if telemetry_strict is None:
        telemetry_strict = args.telemetry is not None

    if not args.trades.exists():
        raise FileNotFoundError(f"Trades file not found: {args.trades}")

    df = pd.read_csv(args.trades)
    ts_utc = _parse_timestamp_column(df)
    pnl = _parse_pnl_column(df)
    pnl_ts = ts_utc  # timestamps associated with pnl entries

    # If positions CSV is provided and fills-derived pnl is unavailable,
    # use positions-derived pnl for DD and consistency calculations.
    pnl_source = "fills"
    if args.positions is not None:
        pos_pnl, pos_ts = _load_positions_pnl_and_ts(args.positions)
        if pos_pnl is not None and pos_ts is not None:
            # Prefer positions if fills has no pnl, or always use positions if provided
            if pnl is None:
                pnl = pos_pnl
                pnl_ts = pos_ts
                pnl_source = "positions"
            else:
                # Both available: prefer positions for more accurate per-position pnl
                pnl = pos_pnl
                pnl_ts = pos_ts
                pnl_source = "positions"

    cutoff_time = _parse_time(args.cutoff)
    cutoff_viol, overnight_viol = check_cutoff_and_overnight(df, ts_utc, cutoff_time)

    # DD calculation: institutional-grade requires telemetry for HWM+unrealized tracking
    max_dd: float | None = None
    max_daily_dd: float | None = None
    dd_source: str | None = None
    dd_is_mtm_unrealized: bool = False  # True only if valid telemetry DD extracted
    telemetry_strict_failed = False  # FAIL when telemetry-strict=True and no DD events

    violations: list[str] = []

    if require_telemetry:
        # INSTITUTIONAL-GRADE: Telemetry is REQUIRED for DD validation
        if args.telemetry is None:
            # No telemetry provided at all: FAIL CLOSED
            violations.append(
                "Telemetry is required for DD validation (trailing DD uses HWM + unrealized). "
                "Provide --telemetry or pass --no-require-telemetry for approximate realized-only DD."
            )
        else:
            # Telemetry provided - parse and validate
            telem_result = _parse_telemetry_dd(args.telemetry)
            dd_source = "telemetry"  # Indicate attempted source regardless of outcome

            if telem_result.parse_error:
                # Telemetry is malformed/unreadable: FAIL CLOSED
                violations.append(
                    "Telemetry file is malformed or unreadable. "
                    "DD validation requires valid telemetry with circuit_state or dd_snapshot events."
                )
            elif telem_result.max_total_dd_pct is None:
                # Telemetry parsed but no DD events: FAIL CLOSED
                violations.append(
                    "Telemetry provided but no DD events found (circuit_state or dd_snapshot). "
                    "DD validation requires telemetry with intrabar unrealized equity tracking."
                )
            else:
                # Valid telemetry with DD data: SUCCESS
                max_dd = telem_result.max_total_dd_pct / 100.0
                max_daily_dd = (
                    telem_result.max_daily_dd_pct / 100.0
                    if telem_result.max_daily_dd_pct is not None
                    else None
                )
                dd_is_mtm_unrealized = True
    else:
        # FALLBACK MODE: telemetry optional, realized-only DD acceptable
        if args.telemetry is not None:
            telem_result = _parse_telemetry_dd(args.telemetry)
            if telem_result.max_total_dd_pct is not None:
                # Telemetry DD is already in percentage form (e.g., 3.5 = 3.5%)
                # Convert to fraction for comparison with dd_limit
                max_dd = telem_result.max_total_dd_pct / 100.0
                max_daily_dd = (
                    telem_result.max_daily_dd_pct / 100.0
                    if telem_result.max_daily_dd_pct is not None
                    else None
                )
                dd_source = "telemetry"
                dd_is_mtm_unrealized = True
            elif telem_result.parse_error:
                # Telemetry is malformed/unreadable; fall back to fills/positions.
                dd_source = None
            elif telemetry_strict:
                # Telemetry file was readable, but DD events are missing.
                telemetry_strict_failed = True
                dd_source = "telemetry"  # Indicate attempted source

        # Fallback to realized PnL if telemetry not available/parseable (and not strict-failed)
        if dd_source is None and pnl is not None:
            max_dd = check_trailing_dd(pnl, args.account_size, args.dd_limit)
            dd_source = pnl_source
            # dd_is_mtm_unrealized stays False (realized-only)

    consistency_ratio = (
        check_consistency(pnl, pnl_ts, args.consistency_limit) if pnl is not None else None
    )

    # Strict telemetry failure (only applies when require_telemetry=False)
    if telemetry_strict_failed:
        violations.append(
            "Telemetry provided but no DD events found (strict mode requires circuit_state or dd_snapshot events)"
        )

    if cutoff_viol > 0:
        violations.append(f"Cutoff violations: {cutoff_viol}")
    if overnight_viol > 0:
        violations.append(f"Overnight exposures detected: {overnight_viol}")
    if max_dd is not None and max_dd > args.dd_limit:
        violations.append(
            f"Trailing DD {max_dd * 100:.2f}% exceeds limit {args.dd_limit * 100:.2f}%"
        )
    # Daily DD limit check (only when telemetry available with valid DD)
    if max_daily_dd is not None and max_daily_dd > args.daily_dd_limit:
        violations.append(
            f"Daily DD {max_daily_dd * 100:.2f}% exceeds limit {args.daily_dd_limit * 100:.2f}%"
        )
    if consistency_ratio is not None and consistency_ratio >= args.consistency_limit:
        violations.append(
            f"Consistency ratio {consistency_ratio * 100:.2f}% >= limit {args.consistency_limit * 100:.2f}%"
        )

    summary: dict[str, object] = {
        "trades_file": str(args.trades),
        "positions_file": str(args.positions) if args.positions else None,
        "telemetry_file": str(args.telemetry) if args.telemetry else None,
        "require_telemetry": require_telemetry,
        "telemetry_strict": telemetry_strict,
        "dd_source": dd_source,
        "dd_is_mtm_unrealized": dd_is_mtm_unrealized,
        "cutoff_time_et": args.cutoff,
        "cutoff_violations": cutoff_viol,
        "overnight_violations": overnight_viol,
        "max_trailing_dd_pct": None if max_dd is None else round(max_dd * 100, 2),
        "max_daily_dd_pct": None if max_daily_dd is None else round(max_daily_dd * 100, 2),
        "dd_limit_pct": args.dd_limit * 100,
        "daily_dd_limit_pct": args.daily_dd_limit * 100,
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
        with open(args.output, "w", encoding="utf-8") as f:
            json.dump(summary, f, indent=2)


if __name__ == "__main__":
    main()
