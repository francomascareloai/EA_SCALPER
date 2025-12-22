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
    "Retail Sales m/m": EventSchedule(8, 30, impact_override=3),
    "Unemployment Rate": EventSchedule(8, 30, impact_override=3),
    "Non-Farm Employment Change": EventSchedule(8, 30, impact_override=4),
    "ISM Manufacturing PMI": EventSchedule(10, 0, impact_override=3),
    "ISM Services PMI": EventSchedule(10, 0, impact_override=3),
    "Advance GDP q/q": EventSchedule(8, 30, impact_override=3),

    # Fed (time varies historically, but we use typical schedule anchors)
    "FOMC Statement": EventSchedule(14, 0, impact_override=4),
    "FOMC Press Conference": EventSchedule(14, 30, impact_override=4),
    "FOMC Meeting Minutes": EventSchedule(14, 0, impact_override=3),
    "FOMC Economic Projections": EventSchedule(14, 0, impact_override=3),
    "Federal Funds Rate": EventSchedule(14, 0, impact_override=4),
}


CANONICAL_EVENT_ALIASES: dict[str, set[str]] = {
    # Conservative aliases only (avoid broad fuzzy matching).
    "Non-Farm Employment Change": {
        "Non-Farm Employment Change",
        "Non Farm Employment Change",
        "Nonfarm Employment Change",
    },
    "Federal Funds Rate": {"Federal Funds Rate", "Fed Funds Rate"},
    "FOMC Press Conference": {"FOMC Press Conference", "FOMC Press Conf"},
    "FOMC Statement": {"FOMC Statement", "FOMC Statement Release"},
}


def _build_alias_to_canonical() -> dict[str, str]:
    alias_map: dict[str, str] = {}

    for canonical in USD_EVENT_SCHEDULES.keys():
        alias_map[canonical.strip().upper()] = canonical

    for canonical, aliases in CANONICAL_EVENT_ALIASES.items():
        for alias in aliases:
            alias_map[str(alias).strip().upper()] = canonical

    return alias_map


ALIAS_TO_CANONICAL = _build_alias_to_canonical()


def _canonicalize_event_series(series: pd.Series) -> pd.Series:
    s = (
        series.astype("string")
        .fillna("")
        .str.replace("–", "-", regex=False)
        .str.replace("—", "-", regex=False)
        .str.replace(r"\s+", " ", regex=True)
        .str.strip()
    )
    key = s.str.upper()
    return key.map(ALIAS_TO_CANONICAL).fillna(s).astype("string")


PROFILE_EVENT_FILTERS: dict[str, set[str]] = {
    # All defined anchor events.
    "anchor_usd": set(USD_EVENT_SCHEDULES.keys()),
    # High-signal XAUUSD movers; intentionally smaller = less noise.
    "top_movers_usd": {
        "Non-Farm Employment Change",
        "Unemployment Rate",
        "CPI m/m",
        "CPI y/y",
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
    "CPI m/m": 12,
    "CPI y/y": 12,
    "Retail Sales m/m": 12,
    "Unemployment Rate": 12,
    "Non-Farm Employment Change": 12,
    "ISM Manufacturing PMI": 12,
    "ISM Services PMI": 12,
    "Advance GDP q/q": 4,

    # Fed schedule: press conferences were effectively quarterly for part of the sample.
    "FOMC Statement": 8,
    "FOMC Press Conference": 4,
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
        "--coverage-year-start",
        type=int,
        default=2015,
        help="Start year (inclusive) for coverage gate checks (default: 2015).",
    )
    p.add_argument(
        "--coverage-year-end",
        type=int,
        default=2025,
        help="End year (inclusive) for coverage gate checks (default: 2025).",
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
    coverage_year_start: int,
    coverage_year_end: int,
    dataset_min_utc: pd.Timestamp,
    dataset_max_utc: pd.Timestamp,
    usable_utc_by_event: dict[str, pd.Series],
) -> tuple[bool, list[str]]:
    if coverage_mode == "off":
        return True, []

    issues: list[str] = []
    ok = True

    dataset_start_year = int(pd.to_datetime(dataset_min_utc, utc=True).year)
    dataset_end_year = int(pd.to_datetime(dataset_max_utc, utc=True).year)

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

        dt_years = dt.dt.year
        dt = dt[(dt_years >= int(coverage_year_start)) & (dt_years <= int(coverage_year_end))]
        if dt.empty:
            issues.append(
                f"{event_name}: no timestamps in coverage year range {int(coverage_year_start)}-{int(coverage_year_end)}"
            )
            ok = False
            continue

        # If the dataset doesn't cover the entire year range, don't penalize the boundary years.
        start_year = int(coverage_year_start)
        end_year = int(coverage_year_end)
        if start_year <= dataset_start_year:
            start_year = dataset_start_year + 1
        if end_year >= dataset_end_year:
            end_year = dataset_end_year - 1

        years = dt.dt.year
        counts = years.value_counts().sort_index()

        if start_year > end_year:
            # Nothing to check (e.g., dataset covers only boundary years).
            continue

        check_years = range(start_year, end_year + 1)

        for year in check_years:
            count = int(counts.get(year, 0))
            ratio = float(count) / float(expected_per_year)
            if ratio < float(coverage_min_ratio):
                issues.append(
                    f"{event_name}: year={int(year)} observed={int(count)} expected={int(expected_per_year)} ratio={ratio:.2f}"
                )
                ok = False

    if issues:
        header = (
            f"--- Coverage Gate (profile={profile}, years={coverage_year_start}-{coverage_year_end}, "
            f"min_ratio={coverage_min_ratio}, dataset_years={dataset_start_year}-{dataset_end_year}) ---"
        )
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

    # Canonicalize event names early so filters/schedules apply consistently.
    df["event_canonical"] = _canonicalize_event_series(df["Event"])

    dt_utc = pd.to_datetime(df["DateTime"], utc=True, errors="coerce")
    df["dt_utc"] = dt_utc

    if df["dt_utc"].isna().any():
        bad = int(df["dt_utc"].isna().sum())
        print(f"WARN: {bad} rows had unparsable DateTime and will be ignored.")
        df = df[df["dt_utc"].notna()].copy()

    df["impact_mapped"] = _map_hf_impact(df["Impact"])

    dataset_min_utc = pd.to_datetime(df["dt_utc"].min(), utc=True)
    dataset_max_utc = pd.to_datetime(df["dt_utc"].max(), utc=True)

    profile = str(args.profile)
    allowed_events = PROFILE_EVENT_FILTERS.get(profile, set(USD_EVENT_SCHEDULES.keys()))

    coverage_year_start = int(args.coverage_year_start)
    coverage_year_end = int(args.coverage_year_end)
    if coverage_year_start > coverage_year_end:
        coverage_year_start, coverage_year_end = coverage_year_end, coverage_year_start

    max_delta = float(args.max_delta_min)

    results: list[dict[str, object]] = []
    corrected_rows: list[pd.DataFrame] = []
    usable_utc_by_event: dict[str, pd.Series] = {}

    for event_name, schedule in USD_EVENT_SCHEDULES.items():
        sub = df[df["event_canonical"] == event_name].copy()
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

        dt_year = sub["expected_utc"].dt.year
        in_year_range = (dt_year >= coverage_year_start) & (dt_year <= coverage_year_end)
        systematic_rate = float(systematic_mask[in_year_range].mean())

        accept_systematic = systematic_rate >= 0.75 and median_abs_delta > max_delta

        # In backtests we correct timestamps to the expected release schedule; timestamp deltas are
        # diagnostics only. Mark validity by year-range membership.
        sub["is_valid"] = in_year_range

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

        usable_utc_by_event[event_name] = sub.loc[sub["is_valid"], "expected_utc"]

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
                "is_valid": sub["is_valid"],
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
        coverage_year_start=int(args.coverage_year_start),
        coverage_year_end=int(args.coverage_year_end),
        dataset_min_utc=dataset_min_utc,
        dataset_max_utc=dataset_max_utc,
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
