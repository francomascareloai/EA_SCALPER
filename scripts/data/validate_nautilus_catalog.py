"""Validate a Nautilus ParquetDataCatalog for QuoteTicks.

Validates:
- Catalog can be opened
- Basic query works for a time window
- Tick invariants: ts monotonic, bid<=ask, finite values
"""

from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
import pandas as pd

from nautilus_trader.model.currencies import USD, XAU
from nautilus_trader.model.identifiers import InstrumentId, Symbol, Venue
from nautilus_trader.model.instruments import CurrencyPair
from nautilus_trader.model.objects import Price, Quantity
from nautilus_trader.model.data import QuoteTick
from nautilus_trader.persistence.catalog import ParquetDataCatalog


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


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Validate Nautilus native tick catalog")
    p.add_argument("--catalog", type=Path, required=True)
    p.add_argument("--venue", type=str, default="SIM")
    p.add_argument("--start", type=str, required=True, help="UTC start date")
    p.add_argument("--end", type=str, required=True, help="UTC end date")
    p.add_argument("--max-ticks", type=int, default=200_000)
    return p.parse_args()


def main() -> None:
    args = parse_args()
    if not args.catalog.exists():
        raise FileNotFoundError(str(args.catalog))

    instrument = create_xauusd_instrument(args.venue)
    catalog = ParquetDataCatalog(str(args.catalog.resolve()))

    start_ns = pd.Timestamp(args.start, tz="UTC").value
    end_ns = pd.Timestamp(args.end, tz="UTC").value

    ticks = catalog.query(
        data_cls=QuoteTick,
        instrument_ids=[instrument.id.value],
        start=start_ns,
        end=end_ns,
    )
    ticks = list(ticks)
    if not ticks:
        raise ValueError("No ticks returned for requested window")
    if len(ticks) > args.max_ticks:
        ticks = ticks[: args.max_ticks]

    ts = np.array([t.ts_event for t in ticks], dtype=np.int64)
    bid = np.array([float(t.bid_price) for t in ticks], dtype=np.float64)
    ask = np.array([float(t.ask_price) for t in ticks], dtype=np.float64)

    if not np.all(np.isfinite(ts)):
        raise ValueError("Non-finite timestamps")
    if not np.all(np.isfinite(bid)) or not np.all(np.isfinite(ask)):
        raise ValueError("Non-finite bid/ask")
    if np.any(bid > ask):
        raise ValueError("Found bid > ask")
    if np.any(np.diff(ts) < 0):
        raise ValueError("Timestamps not monotonic non-decreasing")

    print("[OK] Catalog validated")
    print(f"  path={args.catalog}")
    print(f"  ticks_checked={len(ticks):,}")
    print(f"  window={args.start}..{args.end}")


if __name__ == "__main__":
    main()
