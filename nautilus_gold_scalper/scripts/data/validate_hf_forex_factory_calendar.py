from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path

import numpy as np
import pandas as pd


@dataclass(frozen=True)
class EventSchedule:
    hour_et: int
    minute_et: int
    impact_override: int | None = None


ET = "America/New_York"


USD_EVENT_SCHEDULES: dict[str, EventSchedule] = {
    # US macro (typical release times)
    "CPI m/m": EventSchedule(8, 30, impact_override=3),
    "CPI y/y": EventSchedule(8, 30, impact_override=3),
    "Core CPI m/m": EventSchedule(8, 30, impact_override=3),
    "Core CPI y/y": EventSchedule(8, 30, impact_override=3),
    "PPI m/m": EventSchedule(8, 30, impact_override=2),
    "Core PPI m/m": EventSchedule(8, 30, impact_override=2),
    "Core PCE Price Index m/m": EventSchedule(8, 30, impact_override=3),
    "Retail Sales m/m": EventSchedule(8, 30, impact_override=3),
    "Core Retail Sales m/m": EventSchedule(8, 30, impact_override=2),
    "Unemployment Rate": EventSchedule(8, 30, impact_override=3),
    "Non-Farm Employment Change": EventSchedule(8, 30, impact_override=4),
    "Average Hourly Earnings m/m": EventSchedule(8, 30, impact_override=3),
    "ADP Non-Farm Employment Change": EventSchedule(8, 15, impact_override=2),
    "Unemployment Claims": EventSchedule(8, 30, impact_override=2),
    "JOLTS Job Openings": EventSchedule(10, 0, impact_override=2),
    "Personal Spending m/m": EventSchedule(8, 30, impact_override=2),
    "Trade Balance": EventSchedule(8, 30, impact_override=2),
    "Industrial Production m/m": EventSchedule(9, 15, impact_override=2),
    "Capacity Utilization Rate": EventSchedule(9, 15, impact_override=1),
    "Building Permits": EventSchedule(8, 30, impact_override=1),
    "Housing Starts": EventSchedule(8, 30, impact_override=1),
    "Existing Home Sales": EventSchedule(10, 0, impact_override=1),
    "New Home Sales": EventSchedule(10, 0, impact_override=1),
    "CB Consumer Confidence": EventSchedule(10, 0, impact_override=1),
    "Durable Goods Orders m/m": EventSchedule(8, 30, impact_override=2),
    "Core Durable Goods Orders m/m": EventSchedule(8, 30, impact_override=2),
    "Philly Fed Manufacturing Index": EventSchedule(8, 30, impact_override=2),
    "Empire State Manufacturing Index": EventSchedule(8, 30, impact_override=2),
    "Chicago PMI": EventSchedule(9, 45, impact_override=1),
    "ISM Manufacturing PMI": EventSchedule(10, 0, impact_override=3),
    "ISM Services PMI": EventSchedule(10, 0, impact_override=3),
    "Flash Manufacturing PMI": EventSchedule(9, 45, impact_override=1),
    "Flash Services PMI": EventSchedule(9, 45, impact_override=1),
    "Prelim UoM Consumer Sentiment": EventSchedule(10, 0, impact_override=1),
    "Revised UoM Consumer Sentiment": EventSchedule(10, 0, impact_override=1),
    "Advance GDP q/q": EventSchedule(8, 30, impact_override=3),
    "Prelim GDP q/q": EventSchedule(8, 30, impact_override=3),
    "Final GDP q/q": EventSchedule(8, 30, impact_override=3),
    "Advance GDP Price Index q/q": EventSchedule(8, 30, impact_override=2),
    "Prelim GDP Price Index q/q": EventSchedule(8, 30, impact_override=2),
    "Final GDP Price Index q/q": EventSchedule(8, 30, impact_override=2),

    # Fed (time varies historically, but we use typical schedule anchors)
    "FOMC Statement": EventSchedule(14, 0, impact_override=4),
    "FOMC Press Conference": EventSchedule(14, 30, impact_override=4),
    "FOMC Meeting Minutes": EventSchedule(14, 0, impact_override=3),
    "FOMC Economic Projections": EventSchedule(14, 0, impact_override=3),
    "Federal Funds Rate": EventSchedule(14, 0, impact_override=4),
}


PROFILE_EVENT_FILTERS: dict[str, set[str]] = {
    # All defined anchor events.
    "anchor_usd": set(USD_EVENT_SCHEDULES.keys()),
    # High-signal XAUUSD movers; intentionally smaller = less noise.
    "top_movers_usd": {
        "Non-Farm Employment Change",
        "Unemployment Rate",
        "CPI m/m",
        "CPI y/y",
        "Core CPI m/m",
        "Retail Sales m/m",
        "ISM Manufacturing PMI",
        "ISM Services PMI",
        "Advance GDP q/q",
        "FOMC Statement",
        "Federal Funds Rate",
        "FOMC Press Conference",
    },
    # Only the most market-moving events.
    "critical_only_usd": {
        "Non-Farm Employment Change",
        "FOMC Statement",
        "Federal Funds Rate",
        "FOMC Press Conference",
        "CPI m/m",
        "CPI y/y",
    },
}


EXPECTED_PER_YEAR: dict[str, int] = {
    # Monthly (approx 12/year)
    "CPI m/m": 12,
    "CPI y/y": 12,
    "Core CPI m/m": 12,
    "Core CPI y/y": 12,
    "PPI m/m": 12,
    "Core PPI m/m": 12,
    "Core PCE Price Index m/m": 12,
    "Retail Sales m/m": 12,
    "Core Retail Sales m/m": 12,
    "Unemployment Rate": 12,
    "Non-Farm Employment Change": 12,
    "Average Hourly Earnings m/m": 12,
    "ADP Non-Farm Employment Change": 12,
    "JOLTS Job Openings": 12,
    "Personal Spending m/m": 12,
    "Trade Balance": 12,
    "Industrial Production m/m": 12,
    "Capacity Utilization Rate": 12,
    "Building Permits": 12,
    "Housing Starts": 12,
    "Existing Home Sales": 12,
    "New Home Sales": 12,
    "CB Consumer Confidence": 12,
    "Durable Goods Orders m/m": 12,
    "Core Durable Goods Orders m/m": 12,
    "Philly Fed Manufacturing Index": 12,
    "Empire State Manufacturing Index": 12,
    "Chicago PMI": 12,
    "ISM Manufacturing PMI": 12,
    "ISM Services PMI": 12,
    "Flash Manufacturing PMI": 12,
    "Flash Services PMI": 12,
    "Prelim UoM Consumer Sentiment": 12,
    "Revised UoM Consumer Sentiment": 12,

    # Weekly
    "Unemployment Claims": 52,

    # Quarterly (approx 4/year)
    "Advance GDP q/q": 4,
    "Prelim GDP q/q": 4,
    "Final GDP q/q": 4,
    "Advance GDP Price Index q/q": 4,
    "Prelim GDP Price Index q/q": 4,
    "Final GDP Price Index q/q": 4,

    # Fed schedule (typically 8/year; projections are fewer)
    "FOMC Statement": 8,
    "FOMC Press Conference": 8,
    "FOMC Meeting Minutes": 8,
    "FOMC Economic Projections": 4,
    "Federal Funds Rate": 8,
}


HF_IMPACT_MAP: dict[str, int] = {
    "HIGH IMPACT EXPECTED": 3,
    "MEDIUM IMPACT EXPECTED": 2,
    "LOW IMPACT EXPECTED": 1,
    "NON-ECONOMIC": 0,
}


def _parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description=(
            "Validate (and optionally correct) the HuggingFace ForexFactory calendar timestamps "
            "against expected US (ET) release times for anchor events.\n\n"
            "This is a falsification-first gate: if the timestamps don't align, do not trust the dataset for backtests."
        )
    )
    p.add_argument(
        "--input-parquet",
        default=str(
            Path(__file__).resolve().parents[2]
            / "data"
            / "raw"
            / "forex_factory_calendar_0000.parquet"
        ),
        help="Path to HF parquet file (default: nautilus_gold_scalper/data/raw/forex_factory_calendar_0000.parquet).",
    )
    p.add_argument(
        "--currency",
        default="USD",
        help="Currency to validate (default: USD).",
    )
    p.add_argument(
        "--profile",
        default="anchor_usd",
        choices=["anchor_usd", "top_movers_usd", "critical_only_usd"],
        help=(
            "Validation profile controlling which events are emitted to the output CSV. "
            "anchor_usd=all anchor events, top_movers_usd=high-signal subset, critical_only_usd=only top-impact."
        ),
    )
    p.add_argument(
        "--max-delta-min",
        type=float,
        default=5.0,
        help="Max absolute delta in minutes to consider a timestamp aligned (default: 5).",
    )
    p.add_argument(
        "--coverage-mode",
        default="warn",
        choices=["off", "warn", "fail"],
        help=(
            "Coverage gate: validate expected event frequency by year for each anchor event. "
            "off=skip, warn=print warnings, fail=non-zero exit code."
        ),
    )
    p.add_argument(
        "--coverage-min-ratio",
        type=float,
        default=0.7,
        help=(
            "Minimum observed/expected ratio per year for coverage gate (default: 0.7). "
            "Example: 0.7 means allow up to 30% missing."
        ),
    )
    p.add_argument(
        "--out-csv",
        default=None,
        help=(
            "Optional output CSV path (NewsCalendar schema). If provided, will write a strict, USD-only calendar "
            "with expected ET->UTC timestamps for selected anchor events."
        ),
    )
    p.add_argument(
        "--include-unmatched",
        action="store_true",
        help="If set, include unmatched rows in output CSV (marked is_valid=false).",
    )
    return p.parse_args()


def _expected_utc_series(dt_utc: pd.Series, schedule: EventSchedule) -> tuple[pd.Series, pd.Series]:
    """Return (best_expected_utc, best_abs_delta_minutes)."""
    dt_utc = pd.to_datetime(dt_utc, utc=True, errors="coerce")
    dt_et = dt_utc.dt.tz_convert(ET)
    base = dt_et.dt.normalize()

    release_offset = pd.Timedelta(hours=schedule.hour_et, minutes=schedule.minute_et)

    expected0 = (base + release_offset).dt.tz_convert("UTC")
    expected_minus = (base - pd.Timedelta(days=1) + release_offset).dt.tz_convert("UTC")
    expected_plus = (base + pd.Timedelta(days=1) + release_offset).dt.tz_convert("UTC")

    delta0 = (dt_utc - expected0).abs().dt.total_seconds() / 60.0
    delta_minus = (dt_utc - expected_minus).abs().dt.total_seconds() / 60.0
    delta_plus = (dt_utc - expected_plus).abs().dt.total_seconds() / 60.0

    best_delta = np.minimum(delta0, np.minimum(delta_minus, delta_plus))

    choose_minus = (delta_minus <= delta0) & (delta_minus <= delta_plus)
    choose_plus = (delta_plus < delta0) & (delta_plus < delta_minus)

    best_expected = expected0.copy()
    best_expected = best_expected.where(~choose_minus, expected_minus)
    best_expected = best_expected.where(~choose_plus, expected_plus)

    return best_expected, best_delta


def _map_hf_impact(series: pd.Series) -> pd.Series:
    s = series.astype("string").fillna("").str.strip().str.upper()
    return s.map(HF_IMPACT_MAP).fillna(0).astype("int64")


def _apply_coverage_gate(
    *,
    profile: str,
    coverage_mode: str,
    coverage_min_ratio: float,
    usable_utc_by_event: dict[str, pd.Series],
) -> tuple[bool, list[str]]:
    if coverage_mode == "off":
        return True, []

    issues: list[str] = []
    ok = True

    for event_name, expected_utc in usable_utc_by_event.items():
        expected_per_year = EXPECTED_PER_YEAR.get(event_name)
        if expected_per_year is None or expected_per_year <= 0:
            continue

        dt = pd.to_datetime(expected_utc, utc=True, errors="coerce")
        dt = dt[dt.notna()]
        if dt.empty:
            issues.append(f"{event_name}: no timestamps after alignment")
            ok = False
            continue

        years = dt.dt.year
        counts = years.value_counts().sort_index()

        min_year = int(years.min())
        max_year = int(years.max())
        # Avoid false failures due to partial-year boundaries.
        check_years = range(min_year + 1, max_year) if max_year - min_year >= 2 else []

        for year in check_years:
            count = int(counts.get(year, 0))
            ratio = float(count) / float(expected_per_year)
            if ratio < float(coverage_min_ratio):
                issues.append(
                    f"{event_name}: year={int(year)} observed={int(count)} expected={int(expected_per_year)} ratio={ratio:.2f}"
                )
                ok = False

    if issues:
        header = f"--- Coverage Gate (profile={profile}, min_ratio={coverage_min_ratio}) ---"
        print(header)
        for msg in issues[:200]:
            print(f"- {msg}")
        if len(issues) > 200:
            print(f"... ({len(issues) - 200} more)")

    if not ok and coverage_mode == "fail":
        return False, issues

    return True, issues


def main() -> int:
    args = _parse_args()

    input_path = Path(args.input_parquet).expanduser().resolve()
    if not input_path.exists():
        raise FileNotFoundError(str(input_path))

    df = pd.read_parquet(input_path, columns=["DateTime", "Currency", "Impact", "Event"])

    currency = str(args.currency).strip().upper()
    df = df[df["Currency"].astype("string").str.upper() == currency].copy()

    dt_utc = pd.to_datetime(df["DateTime"], utc=True, errors="coerce")
    df["dt_utc"] = dt_utc

    if df["dt_utc"].isna().any():
        bad = int(df["dt_utc"].isna().sum())
        print(f"WARN: {bad} rows had unparsable DateTime and will be ignored.")
        df = df[df["dt_utc"].notna()].copy()

    df["impact_mapped"] = _map_hf_impact(df["Impact"])

    profile = str(args.profile)
    allowed_events = PROFILE_EVENT_FILTERS.get(profile, set(USD_EVENT_SCHEDULES.keys()))

    max_delta = float(args.max_delta_min)

    results: list[dict[str, object]] = []
    corrected_rows: list[pd.DataFrame] = []
    usable_utc_by_event: dict[str, pd.Series] = {}

    for event_name, schedule in USD_EVENT_SCHEDULES.items():
        sub = df[df["Event"].astype("string") == event_name].copy()
        if sub.empty:
            results.append(
                {
                    "event": event_name,
                    "count": 0,
                    "aligned_rate": None,
                    "median_abs_delta_min": None,
                    "systematic_delta_min": None,
                    "systematic_rate": None,
                    "utc_hhmm_top": {},
                }
            )
            continue

        expected_utc, abs_delta = _expected_utc_series(sub["dt_utc"], schedule)
        sub["expected_utc"] = expected_utc
        sub["abs_delta_min"] = abs_delta

        aligned = sub["abs_delta_min"] <= max_delta
        median_abs_delta = float(sub["abs_delta_min"].median())

        # If the dataset has a consistent offset (e.g., a timezone encoding issue),
        # treat those rows as usable after schedule-based correction.
        systematic_mask = (sub["abs_delta_min"] - median_abs_delta).abs() <= max_delta
        systematic_rate = float(systematic_mask.mean())
        accept_systematic = systematic_rate >= 0.80 and median_abs_delta > max_delta

        usable = aligned | (systematic_mask if accept_systematic else False)
        sub["usable"] = usable

        utc_hhmm_top = (
            sub["dt_utc"].dt.strftime("%H:%M").value_counts().head(6).to_dict()  # type: ignore[call-arg]
        )

        results.append(
            {
                "event": event_name,
                "count": int(len(sub)),
                "aligned_rate": float(aligned.mean()),
                "median_abs_delta_min": median_abs_delta,
                "systematic_delta_min": median_abs_delta if accept_systematic else None,
                "systematic_rate": systematic_rate if accept_systematic else None,
                "utc_hhmm_top": utc_hhmm_top,
            }
        )

        usable_utc_by_event[event_name] = sub.loc[sub["usable"], "expected_utc"]

        if event_name not in allowed_events:
            continue

        # Build corrected output rows
        out = pd.DataFrame(
            {
                "time_utc": sub["expected_utc"].dt.strftime("%Y-%m-%dT%H:%M:%SZ"),
                "event_name": event_name,
                "currency": currency,
                "impact": int(schedule.impact_override)
                if schedule.impact_override is not None
                else sub["impact_mapped"],
                "buffer_before_min": 30,
                "buffer_after_min": 30,
                "is_valid": sub["usable"],
                "abs_delta_min": sub["abs_delta_min"],
            }
        )

        if not args.include_unmatched:
            out = out[out["is_valid"]].copy()

        corrected_rows.append(out)

    # Print summary
    print(f"Currency={currency} | profile={profile} | max_delta_min={max_delta}")
    print("--- Timezone Gate (anchor events) ---")
    for r in results:
        event = r["event"]
        count = r["count"]
        aligned_rate = r["aligned_rate"]
        med = r["median_abs_delta_min"]
        sys_delta = r["systematic_delta_min"]
        sys_rate = r["systematic_rate"]
        top = r["utc_hhmm_top"]
        if count == 0:
            print(f"- {event}: MISSING")
            continue

        extra = ""
        if sys_delta is not None and sys_rate is not None:
            extra = f", systematic_delta_min={sys_delta:.1f} (rate={sys_rate:.3f})"

        print(
            f"- {event}: n={count}, aligned_rate={aligned_rate:.3f}, median_abs_delta_min={med:.1f}{extra}, utc_hhmm_top={top}"
        )

    coverage_ok, _ = _apply_coverage_gate(
        profile=profile,
        coverage_mode=str(args.coverage_mode),
        coverage_min_ratio=float(args.coverage_min_ratio),
        usable_utc_by_event=usable_utc_by_event,
    )
    if not coverage_ok:
        return 2

    if args.out_csv:
        out_path = Path(args.out_csv).expanduser().resolve()
        out_path.parent.mkdir(parents=True, exist_ok=True)

        if corrected_rows:
            out_all = pd.concat(corrected_rows, ignore_index=True)
        else:
            out_all = pd.DataFrame(
                columns=[
                    "time_utc",
                    "event_name",
                    "currency",
                    "impact",
                    "buffer_before_min",
                    "buffer_after_min",
                    "is_valid",
                    "abs_delta_min",
                ]
            )

        out_all = out_all.sort_values(["time_utc", "event_name"], kind="mergesort")
        out_all.to_csv(out_path, index=False)

        valid_count = int(out_all["is_valid"].sum()) if "is_valid" in out_all.columns else 0
        print(f"--- Output ---")
        print(f"Wrote {len(out_all)} rows to {out_path} (valid={valid_count})")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
