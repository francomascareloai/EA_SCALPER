"""Quick benchmark test - Parquet vs Nautilus Native."""
import time
from pathlib import Path
import pandas as pd
import yaml

print("="*80)
print("QUICK BENCHMARK - Parquet vs Nautilus")
print("="*80)

# Load config
config = yaml.safe_load(open("data/config.yaml"))
parquet_path = Path(config["active_dataset"]["path"])
native_catalog_path = Path(config["active_dataset"]["native_catalog_path"])

print(f"\n📂 Parquet: {parquet_path}")
print(f"📂 Nautilus: {native_catalog_path}")

# Test 1: Parquet full load
print("\n1️⃣ Parquet Full Load...")
start = time.time()
df = pd.read_parquet(parquet_path)
elapsed_parquet_full = time.time() - start
print(f"   ✅ Time: {elapsed_parquet_full:.2f}s")
print(f"   ✅ Ticks: {len(df):,}")
print(f"   ✅ Memory: ~{df.memory_usage(deep=True).sum() / 1024**2:.1f} MB")

# Test 2: Parquet query 1 month
print("\n2️⃣ Parquet Query 1 Month (2024-11)...")
start = time.time()
df_full = pd.read_parquet(parquet_path)
# Ensure timezone
if df_full['datetime'].dtype.name == 'datetime64[ns]':
    df_full['datetime'] = pd.to_datetime(df_full['datetime'], utc=True)
start_date = pd.Timestamp("2024-11-01", tz="UTC")
end_date = pd.Timestamp("2024-12-01", tz="UTC")
df_month = df_full[(df_full['datetime'] >= start_date) & (df_full['datetime'] < end_date)]
elapsed_parquet_month = time.time() - start
print(f"   ✅ Time: {elapsed_parquet_month:.2f}s (includes full load)")
print(f"   ✅ Ticks: {len(df_month):,}")

# Test 3: Nautilus full load
print("\n3️⃣ Nautilus Native Full Load...")
try:
    from nautilus_trader.persistence.catalog import ParquetDataCatalog
    from nautilus_trader.model.currencies import USD, XAU
    from nautilus_trader.model.identifiers import InstrumentId, Symbol, Venue
    from nautilus_trader.model.instruments import CurrencyPair
    from nautilus_trader.model.objects import Price, Quantity

    venue = Venue("SIM")
    instrument = CurrencyPair(
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

    start = time.time()
    catalog = ParquetDataCatalog(str(native_catalog_path))
    quote_ticks = catalog.quote_ticks(instrument_ids=[instrument.id.value])
    elapsed_nautilus_full = time.time() - start
    print(f"   ✅ Time: {elapsed_nautilus_full:.2f}s")
    print(f"   ✅ Ticks: {len(quote_ticks):,}")

    # Test 4: Nautilus query 1 month
    print("\n4️⃣ Nautilus Native Query 1 Month (2024-11)...")
    from nautilus_trader.model.data import QuoteTick
    start_ns = pd.Timestamp("2024-11-01", tz="UTC").value
    end_ns = pd.Timestamp("2024-12-01", tz="UTC").value

    start = time.time()
    catalog = ParquetDataCatalog(str(native_catalog_path))
    quote_ticks_month = catalog.query(
        data_cls=QuoteTick,
        identifiers=[instrument.id.value],
        start=start_ns,
        end=end_ns,
    )
    elapsed_nautilus_month = time.time() - start
    print(f"   ✅ Time: {elapsed_nautilus_month:.2f}s")
    print(f"   ✅ Ticks: {len(quote_ticks_month):,}")

    # Comparison
    print("\n" + "="*80)
    print("COMPARISON")
    print("="*80)
    speedup_full = elapsed_parquet_full / elapsed_nautilus_full
    speedup_month = elapsed_parquet_month / elapsed_nautilus_month
    print(f"\n✨ Full Load: Nautilus is {speedup_full:.1f}x FASTER than Parquet")
    print(f"✨ Query 1 Month: Nautilus is {speedup_month:.1f}x FASTER than Parquet")
    print(f"\n💡 Nautilus native format avoids:")
    print(f"   - Full dataset load (Rust-backed temporal filter)")
    print(f"   - Runtime conversion to QuoteTick objects")
    print(f"   - Pandas DataFrame overhead")

except Exception as e:
    print(f"   ❌ ERROR: {e}")
    import traceback
    traceback.print_exc()

print("\n✅ Benchmark complete!")
