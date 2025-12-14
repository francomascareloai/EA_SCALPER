"""Convert generic parquet ticks (datetime/bid/ask) to Nautilus native ParquetDataCatalog.

Usage (default paths follow data/config.yaml):
    python scripts/convert_parquet_to_nautilus_native.py \
        --input data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet \
        --output data/catalog_native/xauusd_2003_2025_stride20_full \
        --chunk-size 1000000

Notes:
- Expects columns: datetime (tz-aware or naive UTC), bid, ask.
- Writes QuoteTick objects grouped by instrument_id to ParquetDataCatalog (rust-backed).
- Bars are not generated; BacktestEngine can aggregate internally.
"""

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Iterator

import pandas as pd
import pyarrow.parquet as pq
from nautilus_trader.model.currencies import USD, XAU
from nautilus_trader.model.identifiers import InstrumentId, Symbol, Venue
from nautilus_trader.model.instruments import CurrencyPair
from nautilus_trader.model.objects import Price, Quantity
from nautilus_trader.persistence.catalog import ParquetDataCatalog
from nautilus_trader.persistence.wranglers import QuoteTickDataWrangler


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Convert generic parquet ticks to Nautilus native catalog")
    parser.add_argument("--input", type=Path, required=True, help="Input parquet with datetime/bid/ask")
    parser.add_argument(
        "--output",
        type=Path,
        required=True,
        help="Output directory for ParquetDataCatalog (will be created if missing)",
    )
    parser.add_argument("--chunk-size", type=int, default=1_000_000, help="Rows per chunk when streaming parquet")
    parser.add_argument("--start-date", type=str, default=None, help="UTC start date filter (inclusive)")
    parser.add_argument("--end-date", type=str, default=None, help="UTC end date filter (inclusive)")
    parser.add_argument(
        "--default-volume",
        type=float,
        default=1.0,
        help="Default size used when bid_size/ask_size not present",
    )
    return parser.parse_args()


def create_xauusd_instrument(venue_code: str = "SIM") -> CurrencyPair:
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


def iter_parquet_batches(parquet_path: Path, batch_size: int) -> Iterator[pd.DataFrame]:
    parquet_file = pq.ParquetFile(parquet_path)
    for batch in parquet_file.iter_batches(batch_size=batch_size, columns=["datetime", "bid", "ask"]):
        yield batch.to_pandas()


def main() -> None:
    args = parse_args()

    if not args.input.exists():
        raise FileNotFoundError(f"Input parquet not found: {args.input}")

    args.output.mkdir(parents=True, exist_ok=True)

    instrument = create_xauusd_instrument()
    wrangler = QuoteTickDataWrangler(instrument)
    catalog = ParquetDataCatalog(str(args.output.resolve()))

    start_ts = pd.Timestamp(args.start_date, tz="UTC") if args.start_date else None
    end_ts = pd.Timestamp(args.end_date, tz="UTC") if args.end_date else None

    total_rows = 0
    total_ticks = 0
    chunk_idx = 0

    for batch_df in iter_parquet_batches(args.input, args.chunk_size):
        batch_df["datetime"] = pd.to_datetime(batch_df["datetime"], utc=True)

        if start_ts is not None:
            batch_df = batch_df[batch_df["datetime"] >= start_ts]
        if end_ts is not None:
            batch_df = batch_df[batch_df["datetime"] <= end_ts]
        if batch_df.empty:
            continue

        tick_df = pd.DataFrame(
            {
                "bid_price": batch_df["bid"].astype(float),
                "ask_price": batch_df["ask"].astype(float),
                "bid_size": args.default_volume,
                "ask_size": args.default_volume,
            },
            index=pd.DatetimeIndex(batch_df["datetime"], name="timestamp"),
        )

        ticks = wrangler.process(tick_df, default_volume=args.default_volume, ts_init_delta=0)

        if not ticks:
            continue

        catalog.write_data(
            ticks,
            start=int(tick_df.index[0].value),
            end=int(tick_df.index[-1].value),
            skip_disjoint_check=True,
        )

        chunk_idx += 1
        total_rows += len(batch_df)
        total_ticks += len(ticks)
        print(f"[chunk {chunk_idx}] rows={len(batch_df):,} ticks_written={len(ticks):,} total_ticks={total_ticks:,}")

    print(f"\n[OK] Conversion complete -> {args.output}")
    print(f"Total rows processed: {total_rows:,}")
    print(f"Total ticks written: {total_ticks:,}")


if __name__ == "__main__":
    main()
