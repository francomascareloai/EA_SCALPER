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
        "--max-delta-min",
        type=float,
        default=5.0,
        help="Max absolute delta in minutes to consider a timestamp aligned (default: 5).",
    )
    p.add_argument(
        "--out-csv",
        default=None,
        help=(
            "Optional output CSV path (NewsCalendar schema). If provided, will write a strict, USD-only calendar "
            "with expected ET->UTC timestamps for anchor events."
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

    max_delta = float(args.max_delta_min)

    results: list[dict[str, object]] = []
    corrected_rows: list[pd.DataFrame] = []

    for event_name, schedule in USD_EVENT_SCHEDULES.items():
        sub = df[df["Event"].astype("string") == event_name].copy()
        if sub.empty:
            results.append(
                {
                    "event": event_name,
                    "count": 0,
                    "match_rate": None,
                    "median_abs_delta_min": None,
                    "utc_hhmm_top": {},
                }
            )
            continue

        expected_utc, abs_delta = _expected_utc_series(sub["dt_utc"], schedule)
        sub["expected_utc"] = expected_utc
        sub["abs_delta_min"] = abs_delta
        sub["aligned"] = sub["abs_delta_min"] <= max_delta

        utc_hhmm_top = (
            sub["dt_utc"].dt.strftime("%H:%M").value_counts().head(6).to_dict()  # type: ignore[call-arg]
        )

        results.append(
            {
                "event": event_name,
                "count": int(len(sub)),
                "match_rate": float(sub["aligned"].mean()),
                "median_abs_delta_min": float(sub["abs_delta_min"].median()),
                "utc_hhmm_top": utc_hhmm_top,
            }
        )

        # Build corrected output rows
        out = pd.DataFrame(
            {
                "time_utc": sub["expected_utc"].dt.strftime("%Y-%m-%dT%H:%M:%SZ"),
                "event_name": event_name,
                "currency": currency,
                "impact": int(schedule.impact_override) if schedule.impact_override is not None else sub["impact_mapped"],
                "buffer_before_min": 30,
                "buffer_after_min": 30,
                "is_valid": sub["aligned"],
                "abs_delta_min": sub["abs_delta_min"],
            }
        )

        if not args.include_unmatched:
            out = out[out["is_valid"]].copy()

        corrected_rows.append(out)

    # Print summary
    print(f"Currency={currency} | max_delta_min={max_delta}")
    print("--- Timezone Gate (anchor events) ---")
    for r in results:
        event = r["event"]
        count = r["count"]
        match_rate = r["match_rate"]
        med = r["median_abs_delta_min"]
        top = r["utc_hhmm_top"]
        if count == 0:
            print(f"- {event}: MISSING")
            continue
        print(
            f"- {event}: n={count}, match_rate={match_rate:.3f}, median_abs_delta_min={med:.1f}, utc_hhmm_top={top}"
        )

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
