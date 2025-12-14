# NautilusTrader Patterns & Best Practices

## Event-Driven Architecture

### The MessageBus

Everything in NautilusTrader flows through the MessageBus:
- Data events (bars, ticks)
- Order events (submitted, filled, rejected)
- Position events (opened, changed, closed)
- Custom signals (from Actors)

```
DataEngine → MessageBus → Strategy.on_bar()
Strategy.submit_order() → MessageBus → ExecEngine → Adapter
Adapter → MessageBus → Strategy.on_order_filled()
```

### Event Flow Pattern

```python
# DO: React to events
def on_order_filled(self, event: OrderFilled) -> None:
    # React to fill, maybe set SL/TP
    self._set_stop_loss(event.position_id)

# DON'T: Poll for state
def on_bar(self, bar: Bar) -> None:
    # BAD: Polling for fills
    # for order in self.orders:
    #     if order.is_filled():
    #         ...
    pass
```

---

## Strategy Lifecycle

### Initialization Sequence

```
1. __init__()      → Setup instance variables
2. on_start()      → Subscribe to data, load historical
3. [data flows]    → on_bar(), on_quote_tick()
4. on_stop()       → Cleanup, close positions
5. on_reset()      → Reset state (optional)
```

### Critical: super().__init__()

```python
# CORRECT
def __init__(self, config: MyConfig) -> None:
    super().__init__(config)  # MUST be first!
    self.instrument_id = InstrumentId.from_str(config.instrument_id)

# WRONG - Strategy won't initialize properly
def __init__(self, config: MyConfig) -> None:
    self.instrument_id = InstrumentId.from_str(config.instrument_id)
    # Missing super().__init__(config) - BROKEN!
```

---

## Cache Access Patterns

### Getting Instruments

```python
# In on_start()
self.instrument = self.cache.instrument(self.instrument_id)
if self.instrument is None:
    self.log.error(f"Instrument not found: {self.instrument_id}")
    self.stop()
    return
```

### Getting Positions

```python
# Current position for instrument
position = self.cache.position(self.instrument_id)

# All open positions
open_positions = self.cache.positions_open()

# Positions for specific instrument
instrument_positions = self.cache.positions_open(instrument_id=self.instrument_id)
```

### Getting Orders

```python
# Pending orders
pending = self.cache.orders_pending(instrument_id=self.instrument_id)

# All orders
all_orders = self.cache.orders(instrument_id=self.instrument_id)
```

---

## Order Submission Patterns

### Market Order

```python
order = self.order_factory.market(
    instrument_id=self.instrument_id,
    order_side=OrderSide.BUY,
    quantity=Quantity.from_str("1.0"),
    time_in_force=TimeInForce.IOC,
)
self.submit_order(order)
```

### Limit Order

```python
order = self.order_factory.limit(
    instrument_id=self.instrument_id,
    order_side=OrderSide.BUY,
    quantity=Quantity.from_str("1.0"),
    price=Price.from_str("1950.50"),
    time_in_force=TimeInForce.GTC,
)
self.submit_order(order)
```

### Bracket Order (Entry + SL + TP)

```python
entry = self.order_factory.market(
    instrument_id=self.instrument_id,
    order_side=OrderSide.BUY,
    quantity=Quantity.from_str("1.0"),
)

bracket = self.order_factory.bracket(
    instrument_id=self.instrument_id,
    entry_order=entry,
    sl_trigger_price=Price.from_str("1940.00"),
    tp_price=Price.from_str("1970.00"),
)
self.submit_order_list(bracket)
```

---

## Handler Performance Patterns

### Fast on_bar Handler

```python
def on_bar(self, bar: Bar) -> None:
    """Must be < 1ms."""
    # Fast path: check if we should trade
    if not self._should_evaluate(bar):
        return
    
    # Numpy for calculations
    self._prices.append(bar.close.as_double())
    if len(self._prices) > self._max_prices:
        self._prices.pop(0)
    
    # Vectorized analysis
    signal = self._fast_signal_check()
    if signal:
        self._execute(signal)
```

### Avoid in Hot Path

```python
# DON'T: Heavy computation in on_bar
def on_bar(self, bar: Bar) -> None:
    # BAD: DataFrame creation
    df = pd.DataFrame(self._prices)
    df['sma'] = df['price'].rolling(20).mean()
    
    # BAD: String formatting
    msg = f"Processing bar at {datetime.now()}"
    
    # BAD: Disk I/O
    with open('log.txt', 'a') as f:
        f.write(msg)
```

---

## Configuration Patterns

### Pydantic Config

```python
from nautilus_trader.config import StrategyConfig

class MyConfig(StrategyConfig):
    """Immutable, validated configuration."""
    
    # Required
    instrument_id: str
    bar_type: str
    
    # Optional with defaults
    ema_fast: int = 8
    ema_slow: int = 21
    risk_per_trade: float = 0.01
    
    # Validation via Field
    max_position_size: float = Field(default=1.0, gt=0.0, le=10.0)


# Usage in Strategy
class MyStrategy(Strategy):
    def __init__(self, config: MyConfig) -> None:
        super().__init__(config)
        self._ema_fast = config.ema_fast  # Typed, validated
```

---

## Common Pitfalls

### 1. Missing super().__init__()

```python
# BROKEN - Strategy won't work
def __init__(self, config):
    self.my_var = "foo"
    # Forgot super().__init__(config)!

# CORRECT
def __init__(self, config: MyConfig) -> None:
    super().__init__(config)  # ALWAYS FIRST
    self.my_var = "foo"
```

### 2. Instrument Not Loaded

```python
# WRONG - instrument might be None
def on_start(self) -> None:
    self.instrument = self.cache.instrument(self.instrument_id)
    self.tick_size = self.instrument.price_precision  # AttributeError!

# CORRECT - Always check
def on_start(self) -> None:
    self.instrument = self.cache.instrument(self.instrument_id)
    if self.instrument is None:
        self.log.error(f"Cannot find {self.instrument_id}")
        self.stop()
        return
    self.tick_size = self.instrument.price_precision
```

### 3. Wrong Type for Price/Quantity

```python
# WRONG - float causes type errors
order = self.order_factory.market(
    instrument_id=self.instrument_id,
    order_side=OrderSide.BUY,
    quantity=1.0,  # TypeError!
)

# CORRECT - Use proper types
order = self.order_factory.market(
    instrument_id=self.instrument_id,
    order_side=OrderSide.BUY,
    quantity=Quantity.from_str("1.0"),
)
```

### 4. Not Handling Events

```python
# WRONG - Submit and forget
def on_bar(self, bar: Bar) -> None:
    order = self.order_factory.market(...)
    self.submit_order(order)
    # What if rejected? What about SL/TP?

# CORRECT - Event-driven follow-up
def on_order_filled(self, event: OrderFilled) -> None:
    self._place_stop_loss(event.position_id)

def on_order_rejected(self, event: OrderRejected) -> None:
    self.log.warning(f"Order rejected: {event.reason}")
```

### 5. Slow on_bar Handlers

```python
# WRONG - Heavy computation blocks event loop
def on_bar(self, bar: Bar) -> None:
    df = pd.DataFrame([b.close for b in self.bars])  # Slow!
    signals = self.ml_model.predict(df)  # Very slow!
    
# CORRECT - Pre-compute, use numpy
def on_bar(self, bar: Bar) -> None:
    self._close_buffer.append(bar.close.as_double())
    if len(self._close_buffer) >= self._lookback:
        signal = np.mean(self._close_buffer[-20:])  # Fast
```

---

## Anti-Patterns to Avoid

### 1. Polling Instead of Events

```python
# ANTI-PATTERN: Polling state
def on_bar(self, bar: Bar) -> None:
    for order in self.cache.orders():
        if order.status == OrderStatus.FILLED:  # BAD
            self._handle_fill(order)

# CORRECT: React to events
def on_order_filled(self, event: OrderFilled) -> None:
    self._handle_fill(event)
```

### 2. Global State

```python
# ANTI-PATTERN: Global mutable state
_signals = []  # BAD - shared between instances

class MyStrategy(Strategy):
    def on_bar(self, bar):
        _signals.append(bar)  # Race conditions!

# CORRECT: Instance state
class MyStrategy(Strategy):
    def __init__(self, config):
        super().__init__(config)
        self._signals = []  # Instance-specific
```

### 3. Blocking I/O in Handlers

```python
# ANTI-PATTERN: Blocking I/O
def on_bar(self, bar: Bar) -> None:
    with open('log.txt', 'a') as f:  # BLOCKS!
        f.write(str(bar))
    response = requests.get(url)  # BLOCKS!

# CORRECT: Use framework logging, async for external
def on_bar(self, bar: Bar) -> None:
    self.log.info(f"Bar: {bar}")  # Non-blocking
```

### 4. Not Using InstrumentId Properly

```python
# ANTI-PATTERN: String comparison
if str(bar.bar_type.instrument_id) == "XAUUSD.SIM":  # Fragile

# CORRECT: Proper comparison
if bar.bar_type.instrument_id == self.instrument_id:  # Type-safe
```

---

## Performance Tips

### 1. Use numpy for Calculations

```python
# Pre-allocate arrays
self._closes = np.zeros(self._max_lookback, dtype=np.float64)
self._idx = 0

def on_bar(self, bar: Bar) -> None:
    self._closes[self._idx % self._max_lookback] = bar.close.as_double()
    self._idx += 1
```

### 2. Minimize Object Creation

```python
# Cache frequently used values
def on_start(self) -> None:
    self._price_precision = self.instrument.price_precision
    self._quantity_precision = self.instrument.size_precision

# Reuse objects
def on_bar(self, bar: Bar) -> None:
    # DON'T: self._my_indicator = MovingAverage(20)
    # DO: Update existing indicator
    self._ma.update(bar.close)
```

### 3. Early Exit in Handlers

```python
def on_bar(self, bar: Bar) -> None:
    # Fast rejection paths
    if not self._is_trading_time():
        return
    if self._has_position():
        return
    if not self._signal_valid():
        return
    
    # Only reach here if actually trading
    self._enter_position()
```

### 4. Batch Database Operations

```python
# In backtest post-processing, not in handlers
def on_stop(self) -> None:
    # Batch write results
    trades = self.cache.trades(self.instrument_id)
    self._write_to_db(trades)  # Single batch operation
```

---

## Testing Patterns

### Unit Test Setup

```python
import pytest
from nautilus_trader.test_kit.stubs.component import TestComponentStubs

@pytest.fixture
def strategy():
    config = MyConfig(
        instrument_id="XAUUSD.SIM",
        bar_type="XAUUSD.SIM-1-MINUTE-LAST-EXTERNAL",
    )
    return MyStrategy(config=config)

def test_signal_generation(strategy):
    bar = TestComponentStubs.bar_5decimal()
    strategy.on_bar(bar)
    assert strategy._signal is not None
```

### Integration Test

```python
def test_backtest_run():
    engine = BacktestEngine(config=BacktestEngineConfig())
    engine.add_venue(...)
    engine.add_data(...)
    engine.add_strategy(MyStrategy(config))
    engine.run()
    
    assert engine.trader.strategy_states[strategy.id] == ComponentState.STOPPED
```
