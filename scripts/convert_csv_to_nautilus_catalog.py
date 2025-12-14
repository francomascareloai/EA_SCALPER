"""Stream FTMO tick CSV into a Nautilus ParquetDataCatalog (native format).

The master CSV has *no header* and uses:
- datetime: "%Y%m%d %H:%M:%S.%f" (UTC)
- bid, ask, spread, volume

This script supports:
- downsampling via --stride
- slicing via --start-date/--end-date
- optional session catalogs via --session (GMT windows)

Example (smoke test):
    .venv/bin/python scripts/convert_csv_to_nautilus_catalog.py \
      --start-date 2003-05-05 --end-date 2003-05-06 \
      --stride 200000 --chunk-size 200000 \
      --output data/catalog_native_smoke_test
"""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

import numpy as np
import pandas as pd
from nautilus_trader.model.currencies import USD, XAU
from nautilus_trader.model.identifiers import InstrumentId, Symbol, Venue
from nautilus_trader.model.instruments import CurrencyPair
from nautilus_trader.model.objects import Price, Quantity
from nautilus_trader.persistence.catalog import ParquetDataCatalog
from nautilus_trader.persistence.wranglers import QuoteTickDataWrangler


@dataclass(frozen=True)
class SessionWindow:
    name: str
    start_hour_gmt: int
    end_hour_gmt: int


SESSION_WINDOWS: dict[str, SessionWindow] = {
    "ASIAN": SessionWindow("ASIAN", 0, 7),
    "LONDON": SessionWindow("LONDON", 7, 12),
    "OVERLAP": SessionWindow("OVERLAP", 12, 15),
    "NY": SessionWindow("NY", 15, 17),
    "LATE_NY": SessionWindow("LATE_NY", 17, 21),
}


def _session_mask(dt_utc: pd.Series, session: SessionWindow) -> pd.Series:
    hours = pd.DatetimeIndex(dt_utc).hour
    if session.start_hour_gmt < session.end_hour_gmt:
        return (hours >= session.start_hour_gmt) & (hours < session.end_hour_gmt)
    return (hours >= session.start_hour_gmt) | (hours < session.end_hour_gmt)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Convert CSV ticks to Nautilus ParquetDataCatalog")
    parser.add_argument(
        "--input",
        type=Path,
        default=Path("Python_Agent_Hub/ml_pipeline/data/CSV_2003-2025XAUUSD_ftmo_all-TICK-No Session.csv"),
        help="Input CSV with columns datetime,bid,ask,spread,volume (no header)",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("data/catalog_native/xauusd_2003_2025_stride20_full"),
        help="Output directory for ParquetDataCatalog",
    )
    parser.add_argument("--chunk-size", type=int, default=2_000_000, help="CSV rows per chunk")
    parser.add_argument("--stride", type=int, default=20, help="Take every Nth tick for downsampling")
    parser.add_argument("--start-date", type=str, default=None, help="UTC start date (inclusive)")
    parser.add_argument("--end-date", type=str, default=None, help="UTC end date (inclusive)")
    parser.add_argument("--default-volume", type=float, default=1.0, help="Fallback size when volume missing")
    parser.add_argument("--venue", type=str, default="SIM", help="Venue code for InstrumentId")
    parser.add_argument(
        "--session",
        type=str,
        default=None,
        choices=sorted(SESSION_WINDOWS.keys()),
        help="Optional GMT session filter (ASIAN/LONDON/OVERLAP/NY/LATE_NY).",
    )
    parser.add_argument(
        "--fail-on-disjoint",
        action="store_true",
        help="Fail if timestamps move backwards between chunks (global monotonicity check).",
    )
    return parser.parse_args()


def create_xauusd_instrument(venue_code: str) -> CurrencyPair:
    venue = Venue(venue_code)
    return CurrencyPair(
        instrument_id=InstrumentId(Symbol("XAU/USD"), venue),
        raw_symbol=Symbol("XAUUSD"),
        base_currency=XAU,
        quote_currency=USD,
        price_precision=2,
        size_precision=2,
        price_increment=Price.from_str("0.01"),
        size_increment=Quantity.from_str("0.01"),
        lot_size=Quantity.from_str("1"),
        max_quantity=Quantity.from_str("100"),
        min_quantity=Quantity.from_str("0.01"),
        max_price=Price.from_str("10000.00"),
        min_price=Price.from_str("100.00"),
        margin_init=0,
        margin_maint=0,
        maker_fee=0,
        taker_fee=0,
        ts_event=0,
        ts_init=0,
    )


def main() -> None:
    args = parse_args()

    if not args.input.exists():
        raise FileNotFoundError(f"Input CSV not found: {args.input}")

    args.output.mkdir(parents=True, exist_ok=True)

    instrument = create_xauusd_instrument(args.venue)
    wrangler = QuoteTickDataWrangler(instrument)
    catalog = ParquetDataCatalog(str(args.output.resolve()))

    start_ts = pd.Timestamp(args.start_date, tz="UTC") if args.start_date else None
    end_ts = pd.Timestamp(args.end_date, tz="UTC") if args.end_date else None
    session_window = SESSION_WINDOWS[args.session] if args.session else None

    total_rows = 0
    total_ticks = 0
    chunk_idx = 0
    last_ts_ns: Optional[int] = None

    csv_iter = pd.read_csv(
        args.input,
        names=["datetime", "bid", "ask", "spread", "volume"],
        usecols=[0, 1, 2, 3, 4],
        header=None,
        chunksize=args.chunk_size,
    )

    for chunk in csv_iter:
        chunk_idx += 1
        chunk["datetime"] = pd.to_datetime(
            chunk["datetime"],
            format="%Y%m%d %H:%M:%S.%f",
            errors="coerce",
            utc=True,
        )
        chunk["bid"] = pd.to_numeric(chunk["bid"], errors="coerce")
        chunk["ask"] = pd.to_numeric(chunk["ask"], errors="coerce")
        chunk["volume"] = pd.to_numeric(chunk["volume"], errors="coerce")

        if args.stride > 1:
            chunk = chunk.iloc[:: args.stride]

        if start_ts is not None:
            chunk = chunk[chunk["datetime"] >= start_ts]
        if end_ts is not None:
            chunk = chunk[chunk["datetime"] <= end_ts]

        if session_window is not None:
            chunk = chunk[_session_mask(chunk["datetime"], session_window)]

        # Drop rows with missing or non-finite bid/ask/datetime
        chunk = chunk.dropna(subset=["datetime", "bid", "ask"])
        chunk = chunk[chunk["bid"].apply(pd.notna) & chunk["ask"].apply(pd.notna)]
        chunk = chunk[np.isfinite(chunk["bid"]) & np.isfinite(chunk["ask"])]
        if chunk.empty:
            continue

        chunk = chunk.sort_values("datetime")

        if args.fail_on_disjoint:
            first_ns = int(pd.Timestamp(chunk["datetime"].iloc[0]).value)
            if last_ts_ns is not None and first_ns < last_ts_ns:
                raise ValueError(
                    f"Disjoint timestamps between chunks: chunk={chunk_idx} "
                    f"first={chunk['datetime'].iloc[0]} < prev_last_ns={last_ts_ns}"
                )

        size_series = chunk["volume"].fillna(args.default_volume).astype(float)
        tick_df = pd.DataFrame(
            {
                "bid_price": chunk["bid"].astype(float).reset_index(drop=True),
                "ask_price": chunk["ask"].astype(float).reset_index(drop=True),
                "bid_size": size_series.reset_index(drop=True),
                "ask_size": size_series.reset_index(drop=True),
                "timestamp": pd.DatetimeIndex(chunk["datetime"].reset_index(drop=True), name="timestamp"),
            }
        ).set_index("timestamp")

        tick_df = tick_df.replace([pd.NA, float("inf"), float("-inf")], pd.NA).dropna()
        if tick_df.empty:
            continue

        ticks = wrangler.process(tick_df, default_volume=args.default_volume, ts_init_delta=0)
        if not ticks:
            continue

        catalog.write_data(
            ticks,
            start=int(tick_df.index[0].value),
            end=int(tick_df.index[-1].value),
            skip_disjoint_check=True,
        )

        last_ts_ns = int(tick_df.index[-1].value)

        total_rows += len(chunk)
        total_ticks += len(ticks)
        print(
            f"[chunk {chunk_idx}] rows={len(chunk):,} ticks_written={len(ticks):,} "
            f"total_rows={total_rows:,} total_ticks={total_ticks:,}"
        )

    print(f"\n[OK] CSV -> Nautilus catalog complete at {args.output}")
    print(f"Total rows processed: {total_rows:,}")
    print(f"Total ticks written: {total_ticks:,}")


if __name__ == "__main__":
    main()
