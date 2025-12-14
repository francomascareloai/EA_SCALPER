# NautilusTrader Backtest Configuration Guide

## Complete BacktestNode Setup

### Minimal Working Example

```python
from nautilus_trader.backtest.node import BacktestNode, BacktestVenueConfig
from nautilus_trader.config import BacktestEngineConfig, BacktestDataConfig, BacktestRunConfig
from nautilus_trader.persistence.catalog import ParquetDataCatalog
from nautilus_trader.model.identifiers import Venue

# 1. Load data catalog
catalog = ParquetDataCatalog("./data/catalog")

# 2. Configure venue
venue_config = BacktestVenueConfig(
    name="SIM",
    oms_type="NETTING",
    account_type="MARGIN",
    base_currency="USD",
    starting_balances=["100000 USD"],
)

# 3. Configure data
data_config = BacktestDataConfig(
    catalog_path="./data/catalog",
    data_cls="nautilus_trader.model.data.Bar",
    instrument_id="XAUUSD.SIM",
)

# 4. Configure engine
engine_config = BacktestEngineConfig(
    trader_id="BACKTEST-001",
)

# 5. Configure strategy
strategy_config = MyStrategyConfig(
    instrument_id="XAUUSD.SIM",
    bar_type="XAUUSD.SIM-1-MINUTE-LAST-EXTERNAL",
    # ... strategy params
)

# 6. Build and run
run_config = BacktestRunConfig(
    engine=engine_config,
    venues=[venue_config],
    data=[data_config],
    strategies=[strategy_config],
)

node = BacktestNode(configs=[run_config])
results = node.run()
```

---

## Venue Configuration

### XAUUSD/Gold Configuration

```python
venue_config = BacktestVenueConfig(
    name="SIM",
    oms_type="NETTING",  # One position per instrument
    account_type="MARGIN",
    base_currency="USD",
    starting_balances=["100000 USD"],
    
    # Commission (approximate for gold)
    # $7 per lot round-trip = $3.50 per side
    default_commission=CommissionSpec(
        type="PER_CONTRACT",
        value=3.50,
    ),
    
    # Margin requirements for gold
    # 1 lot = 100 oz, $5000 margin typical
    default_leverage=20,  # 5% margin = 20:1
    
    # Execution settings
    latency_ms=50,  # Simulated execution latency
    fill_model="NO_SLIPPAGE",  # or "SLIPPAGE"
)
```

### OMS Types

| OMS Type | Description | Use Case |
|----------|-------------|----------|
| `NETTING` | One position per instrument | Forex, CFDs, Futures |
| `HEDGING` | Multiple positions allowed | Some brokers |

### Account Types

| Account Type | Description |
|--------------|-------------|
| `CASH` | Cash account, no margin |
| `MARGIN` | Margin account with leverage |
| `BETTING` | Spread betting accounts |

---

## Data Configuration

### Bar Data

```python
data_config = BacktestDataConfig(
    catalog_path="./data/catalog",
    data_cls="nautilus_trader.model.data.Bar",
    instrument_id="XAUUSD.SIM",
    
    # Filter by date range
    start="2024-01-01",
    end="2024-06-30",
    
    # Filter by bar type
    bar_types=["XAUUSD.SIM-1-MINUTE-LAST-EXTERNAL"],
)
```

### Tick Data

```python
data_config = BacktestDataConfig(
    catalog_path="./data/catalog",
    data_cls="nautilus_trader.model.data.QuoteTick",
    instrument_id="XAUUSD.SIM",
    start="2024-01-01",
    end="2024-06-30",
)
```

### Multiple Instruments

```python
data_configs = [
    BacktestDataConfig(
        catalog_path="./data/catalog",
        data_cls="nautilus_trader.model.data.Bar",
        instrument_id="XAUUSD.SIM",
    ),
    BacktestDataConfig(
        catalog_path="./data/catalog",
        data_cls="nautilus_trader.model.data.Bar",
        instrument_id="EURUSD.SIM",
    ),
]
```

---

## Data Catalog Setup

### Creating a Catalog

```python
from nautilus_trader.persistence.catalog import ParquetDataCatalog
from nautilus_trader.persistence.catalog.parquet import ParquetDataCatalog
from nautilus_trader.model.instruments import CurrencyPair
from nautilus_trader.model.data import Bar, BarType
from nautilus_trader.model.identifiers import InstrumentId, Venue
from nautilus_trader.model.currencies import USD, XAU

# Define instrument
XAUUSD = CurrencyPair(
    instrument_id=InstrumentId.from_str("XAUUSD.SIM"),
    raw_symbol=Symbol("XAUUSD"),
    base_currency=XAU,
    quote_currency=USD,
    price_precision=2,
    size_precision=2,
    price_increment=Price.from_str("0.01"),
    size_increment=Quantity.from_str("0.01"),
    lot_size=Quantity.from_str("1"),  # 1 lot = 100 oz
    max_quantity=Quantity.from_str("100"),
    min_quantity=Quantity.from_str("0.01"),
    max_price=Price.from_str("10000.00"),
    min_price=Price.from_str("100.00"),
    margin_init=Decimal("0.05"),  # 5% initial margin
    margin_maint=Decimal("0.03"),  # 3% maintenance
    ts_event=0,
    ts_init=0,
)

# Create catalog
catalog = ParquetDataCatalog("./data/catalog")

# Write instrument
catalog.write_data([XAUUSD])

# Write bars (from pandas DataFrame)
bars = convert_df_to_bars(df, bar_type, XAUUSD)
catalog.write_data(bars)
```

### Converting CSV to Bars

```python
import pandas as pd
from nautilus_trader.model.data import Bar, BarType
from nautilus_trader.model.objects import Price, Quantity

def csv_to_bars(csv_path: str, bar_type: BarType, instrument_id: InstrumentId) -> list[Bar]:
    df = pd.read_csv(csv_path, parse_dates=['time'])
    
    bars = []
    for _, row in df.iterrows():
        bar = Bar(
            bar_type=bar_type,
            open=Price.from_str(f"{row['open']:.2f}"),
            high=Price.from_str(f"{row['high']:.2f}"),
            low=Price.from_str(f"{row['low']:.2f}"),
            close=Price.from_str(f"{row['close']:.2f}"),
            volume=Quantity.from_str(f"{row['volume']:.2f}"),
            ts_event=pd.Timestamp(row['time']).value,
            ts_init=pd.Timestamp(row['time']).value,
        )
        bars.append(bar)
    
    return bars
```

---

## Engine Configuration

### Full Engine Config

```python
engine_config = BacktestEngineConfig(
    trader_id="BACKTEST-001",
    
    # Logging
    log_level="INFO",  # DEBUG, INFO, WARNING, ERROR
    
    # Risk settings
    bypass_logging=False,
    
    # Cache settings
    cache_database=None,  # Use in-memory cache
    
    # Streaming mode (for large datasets)
    streaming=False,
)
```

### Logging Levels

```python
# For debugging
engine_config = BacktestEngineConfig(
    log_level="DEBUG",
    bypass_logging=False,
)

# For performance (minimal logging)
engine_config = BacktestEngineConfig(
    log_level="ERROR",
    bypass_logging=True,
)
```

---

## Strategy Configuration

### Pydantic Config Pattern

```python
from pydantic import Field
from nautilus_trader.config import StrategyConfig

class GoldScalperConfig(StrategyConfig, frozen=True):
    """Gold scalper strategy configuration."""
    
    # Required - no defaults
    instrument_id: str
    bar_type: str
    
    # Indicators
    ema_fast: int = Field(default=8, ge=1, le=100)
    ema_slow: int = Field(default=21, ge=1, le=200)
    atr_period: int = Field(default=14, ge=1, le=50)
    
    # Entry
    min_atr: float = Field(default=0.5, gt=0)
    signal_threshold: float = Field(default=0.65, ge=0, le=1)
    
    # Risk
    risk_per_trade: float = Field(default=0.01, gt=0, le=0.1)
    max_positions: int = Field(default=1, ge=1, le=10)
    
    # Session
    trading_hours_start: int = Field(default=8, ge=0, le=23)
    trading_hours_end: int = Field(default=17, ge=0, le=23)


# Usage
config = GoldScalperConfig(
    instrument_id="XAUUSD.SIM",
    bar_type="XAUUSD.SIM-1-MINUTE-LAST-EXTERNAL",
    ema_fast=12,
    ema_slow=26,
    risk_per_trade=0.005,
)
```

---

## Run Configuration

### Single Run

```python
run_config = BacktestRunConfig(
    engine=engine_config,
    venues=[venue_config],
    data=[data_config],
    strategies=[strategy_config],
)

node = BacktestNode(configs=[run_config])
results = node.run()
```

### Parameter Sweep (Multiple Runs)

```python
configs = []

for ema_fast in [8, 12, 16]:
    for ema_slow in [21, 26, 34]:
        if ema_fast >= ema_slow:
            continue  # Skip invalid combos
            
        strategy_config = GoldScalperConfig(
            instrument_id="XAUUSD.SIM",
            bar_type="XAUUSD.SIM-1-MINUTE-LAST-EXTERNAL",
            ema_fast=ema_fast,
            ema_slow=ema_slow,
        )
        
        run_config = BacktestRunConfig(
            engine=engine_config,
            venues=[venue_config],
            data=[data_config],
            strategies=[strategy_config],
        )
        configs.append(run_config)

# Run all configurations
node = BacktestNode(configs=configs)
all_results = node.run()
```

---

## Results Analysis

### Accessing Results

```python
results = node.run()

# Per-strategy results
for result in results:
    stats = result.stats
    
    # Key metrics
    total_trades = stats.get("total_trades")
    win_rate = stats.get("win_rate")
    profit_factor = stats.get("profit_factor")
    sharpe_ratio = stats.get("sharpe_ratio")
    max_drawdown = stats.get("max_drawdown_pct")
    
    print(f"Trades: {total_trades}")
    print(f"Win Rate: {win_rate:.2%}")
    print(f"Profit Factor: {profit_factor:.2f}")
    print(f"Sharpe: {sharpe_ratio:.2f}")
    print(f"Max DD: {max_drawdown:.2%}")
```

### Trade Analysis

```python
# Get fills from cache
fills = result.engine.cache.fills()

# Convert to DataFrame
import pandas as pd

trade_data = []
for fill in fills:
    trade_data.append({
        'time': fill.ts_event,
        'side': str(fill.side),
        'quantity': fill.quantity.as_double(),
        'price': fill.avg_px.as_double(),
        'pnl': fill.last_px.as_double(),
    })

df = pd.DataFrame(trade_data)
```

### Equity Curve

```python
# Get account balance history
balances = result.engine.cache.account_balance_history()

# Plot
import matplotlib.pyplot as plt

times = [b.ts_event for b in balances]
values = [b.total.as_double() for b in balances]

plt.figure(figsize=(12, 6))
plt.plot(times, values)
plt.title("Equity Curve")
plt.xlabel("Time")
plt.ylabel("Balance (USD)")
plt.show()
```

---

## Walk-Forward Analysis Setup

```python
from datetime import datetime, timedelta

def run_walk_forward(
    data_start: datetime,
    data_end: datetime,
    train_months: int = 6,
    test_months: int = 1,
) -> list:
    """Run walk-forward analysis."""
    
    results = []
    current = data_start
    
    while current + timedelta(days=(train_months + test_months) * 30) <= data_end:
        # Training period
        train_start = current
        train_end = current + timedelta(days=train_months * 30)
        
        # Testing period
        test_start = train_end
        test_end = test_start + timedelta(days=test_months * 30)
        
        # Run optimization on training data
        best_params = optimize_params(train_start, train_end)
        
        # Test on out-of-sample
        oos_result = run_backtest(test_start, test_end, best_params)
        
        results.append({
            'train_period': (train_start, train_end),
            'test_period': (test_start, test_end),
            'params': best_params,
            'oos_result': oos_result,
        })
        
        # Roll forward
        current = test_end
    
    return results
```

---

## Common Issues & Solutions

### Issue: "Instrument not found"

```python
# Make sure instrument is in catalog
instruments = catalog.instruments()
print([i.id for i in instruments])

# Verify instrument_id matches exactly
# Wrong: "XAUUSD" 
# Right: "XAUUSD.SIM"
```

### Issue: "No data for bar type"

```python
# Check available bar types
bar_types = catalog.bar_types()
print(bar_types)

# Make sure bar_type string matches exactly
# Format: "{instrument_id}-{step}-{aggregation}-{price_type}-{source}"
# Example: "XAUUSD.SIM-1-MINUTE-LAST-EXTERNAL"
```

### Issue: Slow backtest

```python
# 1. Use streaming for large datasets
engine_config = BacktestEngineConfig(
    streaming=True,
)

# 2. Reduce logging
engine_config = BacktestEngineConfig(
    log_level="ERROR",
    bypass_logging=True,
)

# 3. Pre-filter data
data_config = BacktestDataConfig(
    start="2024-01-01",
    end="2024-03-31",  # Shorter period
)
```

### Issue: Memory errors

```python
# Use streaming mode
engine_config = BacktestEngineConfig(
    streaming=True,
)

# Process in chunks
for chunk_start, chunk_end in date_chunks:
    data_config = BacktestDataConfig(
        start=chunk_start,
        end=chunk_end,
    )
    # Run and aggregate results
```

---

## Best Practices

1. **Always validate data first**: Check bar counts, gaps, duplicates
2. **Start small**: Test with 1 month before running full period
3. **Use realistic costs**: Commission, spread, slippage
4. **Match live conditions**: Same timeframes, instruments, constraints
5. **Version control configs**: Track all parameter combinations
6. **Log key decisions**: Record why parameters were chosen
7. **Separate train/test**: Never optimize on test data
