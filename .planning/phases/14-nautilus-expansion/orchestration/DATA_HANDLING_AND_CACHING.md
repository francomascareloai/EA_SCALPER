# NautilusTrader — Data Handling & Caching (Full Findings)

Created: 2025-12-27
Source: Explorer subagent output (data handling/caching scan)
Purpose: Preserve complete scope for later implementation work.

---

## 1) Data Catalog Features (Beyond basic ParquetDataCatalog)

### 1.1 ParquetDataCatalog with dual backend architecture

**Location (as captured)**: `/home/franco/projetos/nautilus_trader/docs/concepts/data.md`

**What it does**
- Rust backend: high-performance query engine for core data types (OrderBookDelta, QuoteTick, TradeTick, Bar, MarkPriceUpdate)
- PyArrow backend: flexible fallback for custom data types and advanced filtering
- Supports local and cloud storage (S3, GCS, Azure) via fsspec integration

**Example (as captured)**
```python
from nautilus_trader.persistence.catalog import ParquetDataCatalog

catalog = ParquetDataCatalog("/path/to/catalog")

catalog = ParquetDataCatalog(
    path="s3://my-bucket/nautilus-data/",
    fs_protocol="s3",
    fs_storage_options={
        "key": "access-key",
        "secret": "secret-key",
    }
)

quotes = catalog.query(
    data_cls=QuoteTick,
    identifiers=["EUR/USD.SIM"],
    start="2024-01-01",
    end="2024-01-02",
    where="bid > 1.1000",
)
```

### 1.2 Catalog operations (consolidate/reset/delete)

**Location (as captured)**: `/home/franco/projetos/nautilus_trader/docs/concepts/data.md`

**What it does**
- `consolidate_catalog()`: combine small parquet files into larger files
- `consolidate_catalog_by_period()`: split into fixed time periods
- `reset_file_names()`: align filenames with content timestamps
- `delete_data_range()`: remove data in a time range

**Example (as captured)**
```python
import pandas as pd

catalog.consolidate_catalog_by_period(period=pd.Timedelta(days=1))

catalog.delete_data_range(
    data_cls=TradeTick,
    identifier="XAU/USD.SIM",
    start="2024-01-01",
    end="2024-01-31",
)
```

---

## 2) Bar Aggregation Options

### 2.1 Aggregation class suite

**Location (as captured)**: `/home/franco/projetos/nautilus_trader/nautilus_trader/data/aggregation.pyx`

| Aggregator | Description | Bar type |
|---|---|---|
| TickBarAggregator | aggregate after N ticks | TICK |
| TickImbalanceBarAggregator | tick imbalance threshold | TICK_IMBALANCE |
| TickRunsBarAggregator | sequential buy/sell run counting | TICK_RUNS |
| VolumeBarAggregator | after N volume | VOLUME |
| VolumeImbalanceBarAggregator | volume imbalance | VOLUME_IMBALANCE |
| VolumeRunsBarAggregator | sequential volume runs | VOLUME_RUNS |
| ValueBarAggregator | dollar/value-based bars | VALUE |
| ValueImbalanceBarAggregator | dollar imbalance | VALUE_IMBALANCE |
| ValueRunsBarAggregator | dollar runs | VALUE_RUNS |
| RenkoBarAggregator | fixed price movement bars | RENKO |
| TimeBarAggregator | time-based ms/s/min/hour/day/week/month/year | TIME |

### 2.2 RenkoBarAggregator

**Location (as captured)**: `/home/franco/projetos/nautilus_trader/nautilus_trader/data/aggregation.pyx` (lines 1178-1326)

**What it does**
- Creates bars when price moves by a fixed amount (brick size in ticks)

**Example (as captured)**
```python
bar_type = BarType.from_str("XAU/USD.SIM-10-RENKO-LAST-INTERNAL")
self.subscribe_bars(bar_type)
```

### 2.3 Bar-to-bar aggregation (composite bars)

**Location (as captured)**: `/home/franco/projetos/nautilus_trader/examples/backtest/example_03_bar_aggregation/strategy.py`

**What it does**
- Creates higher timeframe bars from smaller timeframe bars using `@` syntax

**Example (as captured)**
```python
bar_type_5min = BarType.from_str(
    f"{instrument_id}-5-MINUTE-LAST-INTERNAL@1-MINUTE-EXTERNAL"
)
self.subscribe_bars(bar_type_5min)

hourly_bar_type = BarType.from_str(
    "XAU/USD-1-HOUR-LAST-INTERNAL@5-MINUTE-INTERNAL"
)
```

---

## 3) Data Validation & Cleaning

### 3.1 Data Wranglers

**Location (as captured)**: `/home/franco/projetos/nautilus_trader/nautilus_trader/persistence/wranglers.pyx`

Wranglers available:
- `OrderBookDeltaDataWrangler`
- `QuoteTickDataWrangler`
- `TradeTickDataWrangler`
- `BarDataWrangler`

**What they do**
- Convert pandas DataFrames to Nautilus objects
- Precision-aware fixed-point conversion
- Validate non-empty
- Standardize timestamps to UTC
- Drop NaNs in critical columns
- Support `ts_init_delta` for simulating latency

**Example (as captured)**
```python
from nautilus_trader.persistence.wranglers import (
    TradeTickDataWrangler,
    QuoteTickDataWrangler,
    BarDataWrangler,
)

wrangler = TradeTickDataWrangler(instrument)
ticks = wrangler.process(df, ts_init_delta=1000)

quote_wrangler = QuoteTickDataWrangler(instrument)
ticks = quote_wrangler.process_bar_data(
    bid_data=bid_df,
    ask_data=ask_df,
    timestamp_is_close=True,
    random_seed=42,
)
```

### 3.2 preprocess_bar_data function

**Location (as captured)**: `/home/franco/projetos/nautilus_trader/nautilus_trader/persistence/wranglers.pyx` (lines 54-88)

What it does (as captured):
- Ensures index name is "timestamp"
- Standardizes to UTC and removes timezone
- Drops rows with NaN in OHLCV columns
- Handles raw fixed-point scaling

---

## 4) Historical Data Request Patterns

### 4.1 request_bars() / subscribe_bars()

**Location (as captured)**: `/home/franco/projetos/nautilus_trader/docs/concepts/data.md`

**Example (as captured)**
```python
def on_start(self) -> None:
    bar_type = BarType.from_str("XAU/USD.SIM-5-MINUTE-LAST-INTERNAL")

    self.register_indicator_for_bars(bar_type, self.ema)

    self.request_bars(bar_type)
    self.subscribe_bars(bar_type)

def on_historical_data(self, data):
    pass

def on_bar(self, bar):
    pass
```

### 4.2 request_aggregated_bars()

**Location (as captured)**: `/home/franco/projetos/nautilus_trader/docs/concepts/data.md`

**Example (as captured)**
```python
self.request_aggregated_bars([
    BarType.from_str("XAU/USD.SIM-100-VOLUME-LAST-INTERNAL")
])
```

---

## 5) Data persistence and replay

### 5.1 StreamingConfig for capture

**Location (as captured)**: `/home/franco/projetos/nautilus_trader/nautilus_trader/persistence/config.py`

**Example (as captured)**
```python
from nautilus_trader.persistence.config import StreamingConfig, RotationMode
import pandas as pd

streaming_config = StreamingConfig(
    catalog_path="/path/to/streaming/catalog",
    fs_protocol="file",
    flush_interval_ms=1000,
    replace_existing=False,
    rotation_mode=RotationMode.DAILY,
    rotation_interval=pd.Timedelta(hours=1),
    max_file_size=1024 * 1024 * 100,
    include_types=[TradeTick, Bar],
)
```

### 5.2 Cache capacity

**Location (as captured)**: `/home/franco/projetos/nautilus_trader/docs/concepts/cache.md`

**Example (as captured)**
```python
from nautilus_trader.config import CacheConfig, BacktestEngineConfig

engine_config = BacktestEngineConfig(
    cache=CacheConfig(
        tick_capacity=10_000,
        bar_capacity=5_000,
    ),
)

last_bar = self.cache.bar(self.bar_type, index=0)
prev_bar = self.cache.bar(self.bar_type, index=1)
bar_count = self.cache.bar_count(self.bar_type)
```

### 5.3 Data iterator for large datasets

**Location (as captured)**: `/home/franco/projetos/nautilus_trader/docs/concepts/backtesting.md`

**Example (as captured)**
```python
def data_generator():
    for chunk_file in sorted(chunk_files):
        yield load_chunk(chunk_file)

engine.add_data_iterator(
    data_name="xauusd_ticks",
    generator=data_generator(),
)
```

### 5.4 Deferred sorting optimization

**Location (as captured)**: `/home/franco/projetos/nautilus_trader/docs/concepts/backtesting.md`

**Example (as captured)**
```python
engine.add_data(xauusd_bars, sort=False)
engine.add_data(eurusd_bars, sort=False)
engine.sort_data()
engine.run()
```

---

## XAUUSD recommendations captured

- Load via ParquetDataCatalog (Rust backend for speed)
- Use iterators to avoid memory blowups with 32.7M ticks
- Consider Renko bars for noise filtering
- Configure cache capacities based on lookback needs
