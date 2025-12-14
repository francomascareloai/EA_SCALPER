# MQL5 to NautilusTrader Mapping Guide

## Quick Reference Table

| MQL5 Concept | NautilusTrader Equivalent |
|--------------|---------------------------|
| `OnInit()` | `on_start()` |
| `OnDeinit()` | `on_stop()` |
| `OnTick()` | `on_quote_tick()` |
| `OnTimer()` | `clock.set_timer()` + handler |
| `OnBar()` / new bar detection | `on_bar()` |
| `input` parameters | `StrategyConfig` fields |
| `CTrade` | `self.order_factory` + `self.submit_order()` |
| `CPositionInfo` | `self.cache.position()` |
| `CSymbolInfo` | `self.cache.instrument()` |
| `OrderSend()` | `self.submit_order()` |
| `PositionClose()` | `self.close_position()` |
| `PositionModify()` | `self.modify_order()` |
| `iMA()`, `iRSI()`, etc. | Custom `Indicator` class |
| `Alert()`, `Print()` | `self.log.info()`, `self.log.warning()` |
| `MagicNumber` | `StrategyId` (auto-managed) |
| `CArrayDouble` | `numpy.ndarray` |

---

## Lifecycle Mapping

### MQL5 Entry Points → Nautilus Handlers

```
MQL5                          NautilusTrader
═════════════════════════════════════════════════════
OnInit()                  →   __init__() + on_start()
OnDeinit()               →   on_stop()
OnTick()                 →   on_quote_tick()
OnTimer()                →   on_event() (TimeEvent)
OnBar() [manual]         →   on_bar() [automatic]
OnTrade()                →   on_order_*(), on_position_*()
OnTradeTransaction()     →   on_order_filled(), on_order_rejected()
```

### Detailed Mappings

#### OnInit() → __init__() + on_start()

```python
# MQL5
int OnInit() {
    trade.SetExpertMagicNumber(123456);
    trade.SetDeviationInPoints(10);
    
    ArraySetAsSeries(maBuffer, true);
    maHandle = iMA(_Symbol, PERIOD_M1, 20, 0, MODE_EMA, PRICE_CLOSE);
    
    return INIT_SUCCEEDED;
}

# NautilusTrader
class MyStrategy(Strategy):
    def __init__(self, config: MyConfig) -> None:
        super().__init__(config)  # Handles ID assignment
        
        # Instance state
        self._ma_period = config.ma_period
        self._ma_buffer: list[float] = []
        
    def on_start(self) -> None:
        # Get instrument (like SymbolInfo)
        self.instrument = self.cache.instrument(self.instrument_id)
        if self.instrument is None:
            self.log.error(f"Instrument not found")
            self.stop()
            return
        
        # Subscribe to data
        self.subscribe_bars(self.bar_type)
```

#### OnTick() → on_quote_tick()

```python
# MQL5
void OnTick() {
    MqlTick tick;
    SymbolInfoTick(_Symbol, tick);
    double bid = tick.bid;
    double ask = tick.ask;
    
    if (bid > threshold) {
        // Execute logic
    }
}

# NautilusTrader
def on_quote_tick(self, tick: QuoteTick) -> None:
    bid = tick.bid.as_double()
    ask = tick.ask.as_double()
    
    if bid > self._threshold:
        # Execute logic
        pass
```

#### New Bar Detection → on_bar()

```python
# MQL5 (manual bar detection)
datetime lastBarTime = 0;

void OnTick() {
    datetime currentBarTime = iTime(_Symbol, PERIOD_M1, 0);
    if (currentBarTime != lastBarTime) {
        lastBarTime = currentBarTime;
        OnNewBar();  // Custom function
    }
}

void OnNewBar() {
    double open = iOpen(_Symbol, PERIOD_M1, 0);
    double high = iHigh(_Symbol, PERIOD_M1, 0);
    double low = iLow(_Symbol, PERIOD_M1, 0);
    double close = iClose(_Symbol, PERIOD_M1, 0);
}

# NautilusTrader (automatic!)
def on_bar(self, bar: Bar) -> None:
    # Called automatically on each new bar
    open_price = bar.open.as_double()
    high_price = bar.high.as_double()
    low_price = bar.low.as_double()
    close_price = bar.close.as_double()
    volume = bar.volume.as_double()
```

---

## Order Management Mapping

### CTrade → order_factory + submit_order

```python
# MQL5
CTrade trade;
trade.SetExpertMagicNumber(123456);

// Market Buy
trade.Buy(0.1, _Symbol, 0, sl, tp, "My comment");

// Market Sell
trade.Sell(0.1, _Symbol, 0, sl, tp, "My comment");

// Pending Orders
trade.BuyLimit(0.1, price, _Symbol, sl, tp);
trade.SellStop(0.1, price, _Symbol, sl, tp);

# NautilusTrader
# Market Buy
order = self.order_factory.market(
    instrument_id=self.instrument_id,
    order_side=OrderSide.BUY,
    quantity=Quantity.from_str("0.1"),
    time_in_force=TimeInForce.IOC,
)
self.submit_order(order)

# Market Sell
order = self.order_factory.market(
    instrument_id=self.instrument_id,
    order_side=OrderSide.SELL,
    quantity=Quantity.from_str("0.1"),
    time_in_force=TimeInForce.IOC,
)
self.submit_order(order)

# Limit Order (like BuyLimit)
order = self.order_factory.limit(
    instrument_id=self.instrument_id,
    order_side=OrderSide.BUY,
    quantity=Quantity.from_str("0.1"),
    price=Price.from_str("1950.00"),
    time_in_force=TimeInForce.GTC,
)
self.submit_order(order)

# Stop Order (like SellStop)
order = self.order_factory.stop_market(
    instrument_id=self.instrument_id,
    order_side=OrderSide.SELL,
    quantity=Quantity.from_str("0.1"),
    trigger_price=Price.from_str("1940.00"),
    time_in_force=TimeInForce.GTC,
)
self.submit_order(order)
```

### Bracket Orders (Entry + SL + TP)

```python
# MQL5 - SL/TP set with order
trade.Buy(0.1, _Symbol, 0, sl_price, tp_price);

# NautilusTrader - Bracket order
entry = self.order_factory.market(
    instrument_id=self.instrument_id,
    order_side=OrderSide.BUY,
    quantity=Quantity.from_str("0.1"),
)

bracket = self.order_factory.bracket(
    instrument_id=self.instrument_id,
    entry_order=entry,
    sl_trigger_price=Price.from_str(str(sl_price)),
    tp_price=Price.from_str(str(tp_price)),
)
self.submit_order_list(bracket)
```

### Position Close

```python
# MQL5
CPositionInfo pos;
if (pos.Select(_Symbol)) {
    trade.PositionClose(_Symbol);
}

# NautilusTrader
position = self.cache.position(self.instrument_id)
if position is not None and position.is_open:
    self.close_position(position)
```

---

## Position/Order Info Mapping

### CPositionInfo → cache.position()

```python
# MQL5
CPositionInfo pos;
if (pos.Select(_Symbol)) {
    double volume = pos.Volume();
    double profit = pos.Profit();
    ENUM_POSITION_TYPE type = pos.PositionType();
    double openPrice = pos.PriceOpen();
    double sl = pos.StopLoss();
    double tp = pos.TakeProfit();
}

# NautilusTrader
position = self.cache.position(self.instrument_id)
if position is not None and position.is_open:
    quantity = position.quantity.as_double()  # Like Volume
    unrealized_pnl = position.unrealized_pnl(...)  # Like Profit
    side = position.side  # PositionSide.LONG or SHORT
    avg_open = position.avg_px_open.as_double()  # Like PriceOpen
    # Note: SL/TP are separate orders, not position properties
```

### COrderInfo → cache.orders()

```python
# MQL5
COrderInfo order;
for (int i = OrdersTotal() - 1; i >= 0; i--) {
    if (order.SelectByIndex(i)) {
        double volume = order.VolumeCurrent();
        double price = order.PriceOpen();
        ENUM_ORDER_TYPE type = order.OrderType();
    }
}

# NautilusTrader
pending_orders = self.cache.orders_pending(instrument_id=self.instrument_id)
for order in pending_orders:
    quantity = order.quantity.as_double()
    price = order.price.as_double() if order.price else None
    order_type = order.order_type  # OrderType enum
    side = order.side  # OrderSide.BUY or SELL
```

---

## Symbol Info Mapping

### CSymbolInfo → cache.instrument()

```python
# MQL5
CSymbolInfo symbol;
symbol.Name(_Symbol);
symbol.RefreshRates();

double point = symbol.Point();
double tickSize = symbol.TickSize();
double tickValue = symbol.TickValue();
int digits = symbol.Digits();
double bid = symbol.Bid();
double ask = symbol.Ask();
double minLot = symbol.LotsMin();
double maxLot = symbol.LotsMax();

# NautilusTrader
instrument = self.cache.instrument(self.instrument_id)

# Price precision
digits = instrument.price_precision  # Like Digits
price_increment = instrument.price_increment  # Like TickSize

# Lot size
min_quantity = instrument.min_quantity
max_quantity = instrument.max_quantity

# For current prices, use ticks
tick = self.cache.quote_tick(self.instrument_id)
if tick:
    bid = tick.bid.as_double()
    ask = tick.ask.as_double()
```

---

## Indicator Mapping

### iMA, iRSI, etc. → Custom Indicators

```python
# MQL5
int maHandle = iMA(_Symbol, PERIOD_M1, 20, 0, MODE_EMA, PRICE_CLOSE);
double maBuffer[];
CopyBuffer(maHandle, 0, 0, 3, maBuffer);
double currentMA = maBuffer[0];

# NautilusTrader - Using nautilus_trader.indicators
from nautilus_trader.indicators.average.ema import ExponentialMovingAverage

class MyStrategy(Strategy):
    def __init__(self, config):
        super().__init__(config)
        self._ema = ExponentialMovingAverage(period=20)
    
    def on_bar(self, bar: Bar) -> None:
        self._ema.update_raw(bar.close.as_double())
        
        if self._ema.initialized:
            current_ma = self._ema.value
```

### Custom Indicator Class

```python
# MQL5 Custom Indicator
class CMyIndicator {
private:
    int m_period;
    double m_buffer[];
public:
    bool Calculate(double price);
    double GetValue(int shift);
};

# NautilusTrader
from nautilus_trader.indicators.base.indicator import Indicator
from nautilus_trader.model.data import Bar

class MyIndicator(Indicator):
    def __init__(self, period: int) -> None:
        super().__init__([])
        self._period = period
        self._values: list[float] = []
        self._value: float = 0.0
    
    @property
    def value(self) -> float:
        return self._value
    
    def handle_bar(self, bar: Bar) -> None:
        self._values.append(bar.close.as_double())
        if len(self._values) > self._period:
            self._values.pop(0)
        
        if len(self._values) >= self._period:
            self._value = sum(self._values) / len(self._values)
            self._set_initialized(True)
    
    def reset(self) -> None:
        self._values.clear()
        self._value = 0.0
        self._set_initialized(False)
```

---

## Common Patterns Translation

### Trailing Stop

```python
# MQL5
void TrailingStop() {
    CPositionInfo pos;
    if (pos.Select(_Symbol)) {
        double newSL = SymbolInfoDouble(_Symbol, SYMBOL_BID) - trailingPoints * _Point;
        if (newSL > pos.StopLoss() + _Point) {
            trade.PositionModify(_Symbol, newSL, pos.TakeProfit());
        }
    }
}

# NautilusTrader - Modify SL order
def _update_trailing_stop(self) -> None:
    position = self.cache.position(self.instrument_id)
    if position is None or not position.is_open:
        return
    
    tick = self.cache.quote_tick(self.instrument_id)
    if tick is None:
        return
    
    current_price = tick.bid.as_double()
    new_sl = current_price - self._trailing_distance
    
    # Find existing SL order and modify
    sl_orders = [o for o in self.cache.orders_pending(self.instrument_id)
                 if o.order_type == OrderType.STOP_MARKET]
    
    if sl_orders:
        # Cancel old SL and submit new one
        self.cancel_order(sl_orders[0])
        new_sl_order = self.order_factory.stop_market(
            instrument_id=self.instrument_id,
            order_side=OrderSide.SELL,
            quantity=position.quantity,
            trigger_price=Price.from_str(f"{new_sl:.2f}"),
        )
        self.submit_order(new_sl_order)
```

### Session Filter

```python
# MQL5
bool IsTradingTime() {
    MqlDateTime tm;
    TimeToStruct(TimeCurrent(), tm);
    int hour = tm.hour;
    return (hour >= 8 && hour < 17);  // London session
}

# NautilusTrader
def _is_trading_time(self) -> bool:
    """Check if within trading session."""
    current_time = self.clock.utc_now()
    hour = current_time.hour
    return 8 <= hour < 17  # London session UTC
```

---

## Error Handling Mapping

```python
# MQL5
if (!trade.Buy(volume, _Symbol, 0, sl, tp)) {
    Print("Order failed: ", trade.ResultRetcode());
    Print("Description: ", trade.ResultRetcodeDescription());
}

# NautilusTrader - Event-based
def on_order_rejected(self, event: OrderRejected) -> None:
    self.log.error(f"Order rejected: {event.reason}")
    # Handle rejection (e.g., retry, adjust, alert)

def on_order_canceled(self, event: OrderCanceled) -> None:
    self.log.warning(f"Order canceled: {event.client_order_id}")
```

---

## Data Types Mapping

| MQL5 Type | NautilusTrader Type |
|-----------|---------------------|
| `double` | `float` or `Decimal` |
| `datetime` | `pd.Timestamp` |
| `ENUM_ORDER_TYPE` | `OrderType` enum |
| `ENUM_POSITION_TYPE` | `PositionSide` enum |
| `ENUM_TIMEFRAMES` | `BarAggregation` |
| `MqlTick` | `QuoteTick` or `TradeTick` |
| `MqlRates` | `Bar` |
| `color` | Not applicable (no UI) |

---

## Key Differences to Remember

1. **No Magic Numbers**: NautilusTrader uses `StrategyId` automatically
2. **No Manual Bar Detection**: `on_bar()` is called automatically
3. **Event-Driven**: React to events instead of polling
4. **Type Safety**: Use `Price`, `Quantity` types, not raw floats
5. **Immutable Config**: Configuration is validated Pydantic models
6. **No Global State**: Everything is instance-based
7. **Async/Non-blocking**: Handlers must be fast, no blocking I/O
8. **SL/TP as Orders**: Stop loss/take profit are separate order objects
