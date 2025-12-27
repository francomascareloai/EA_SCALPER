# NautilusTrader — Execution Algorithms & Order Management (Full Findings)

Created: 2025-12-27
Source: Explorer subagent output (ExecAlgorithm / order management scan)
Purpose: Preserve complete scope (no retrabalho) for later implementation work.

---

## 1) Execution Algorithms (ExecAlgorithm)

### 1.1 TWAP (Time-Weighted Average Price)

**Location**: `/home/franco/projetos/nautilus_trader/nautilus_trader/examples/algorithms/twap.py`

**What it does**
- Splits a large order into smaller child orders executed at regular intervals over a specified time horizon
- Reduces market impact by spreading execution across time
- Immediately submits first order, with primary order submitted at the end

**Key parameters**
- `horizon_secs`: total execution time window
- `interval_secs`: time between individual order executions

**Code example**
```python
from nautilus_trader.examples.algorithms.twap import TWAPExecAlgorithm, TWAPExecAlgorithmConfig

# Add algorithm to engine
exec_algorithm = TWAPExecAlgorithm()
engine.add_exec_algorithm(exec_algorithm)

# Create order with TWAP execution
order = self.order_factory.market(
    instrument_id=instrument_id,
    order_side=OrderSide.BUY,
    quantity=Quantity.from_int(100),
    exec_algorithm_id=ExecAlgorithmId("TWAP"),
    exec_algorithm_params={
        "horizon_secs": 60.0,
        "interval_secs": 10.0,
    },
)
```

**Gold Scalper application ideas**
- Reduce slippage on larger position entries during volatile XAUUSD moments
- Execute emergency close orders gradually to reduce impact
- Spread risk-off closing across time near time-gate deadlines

---

### 1.2 ExecAlgorithm Base Class (for custom algorithms)

**Location**: `/home/franco/projetos/nautilus_trader/nautilus_trader/execution/algorithm.pyx`

**Key methods (as found in exploration)**
```python
class CustomExecAlgorithm(ExecAlgorithm):
    def on_order(self, order: Order) -> None:
        """Handle incoming orders - override this"""
        pass

    def spawn_market(self, primary, quantity, time_in_force, reduce_only, tags) -> MarketOrder:
        """Spawn a MARKET child order from primary"""

    def spawn_limit(self, primary, quantity, price, time_in_force, ...) -> LimitOrder:
        """Spawn a LIMIT child order"""

    def spawn_market_to_limit(self, primary, quantity, ...) -> MarketToLimitOrder:
        """Spawn a MARKET_TO_LIMIT child order"""

    def submit_order(self, order: Order) -> None:
        """Submit spawned or primary order to RiskEngine"""

    def modify_order(self, order, quantity, price, trigger_price) -> None:
        """Modify an existing order"""

    def modify_order_in_place(self, order, quantity, price, trigger_price) -> None:
        """Modify INITIALIZED order immediately without sending to venue"""

    def cancel_order(self, order) -> None:
        """Cancel an order"""
```

**Spawned order ID convention**
```
{primary_client_order_id}-E{spawn_sequence}
# Example: O-20230404-001-000-E1
```

**Gold Scalper application ideas**
- Build custom execution algorithm that adapts slicing based on spread/volatility
- Implement execution that backs off or cancels when risk state is REDUCING/HALTED

---

## 2) Bracket Order Factory

**Location**: `/home/franco/projetos/nautilus_trader/nautilus_trader/common/factories.pyx` (lines 1193-1243 per explorer)

**What it does**
- Creates entry + take-profit + stop-loss as a linked order list
- Supports multiple entry types: MARKET, LIMIT, STOP_LIMIT, MARKET_IF_TOUCHED, LIMIT_IF_TOUCHED
- Configurable TP/SL order types including trailing stops
- Per-leg exec algorithm assignment

**Signature example (as captured)**
```python
order_list = self.order_factory.bracket(
    instrument_id=instrument_id,
    order_side=OrderSide.BUY,
    quantity=Quantity.from_str("0.1"),

    # Contingency type
    contingency_type=ContingencyType.OUO,  # OTO, OCO, or OUO
    emulation_trigger=TriggerType.NO_TRIGGER,

    # Entry order
    entry_order_type=OrderType.MARKET_IF_TOUCHED,
    entry_trigger_price=Price.from_str("2000.00"),
    time_in_force=TimeInForce.GTD,
    expire_time=datetime.now() + timedelta(seconds=30),
    entry_exec_algorithm_id=ExecAlgorithmId("TWAP"),
    entry_exec_algorithm_params={"horizon_secs": 10, "interval_secs": 2},

    # Take-profit order
    tp_order_type=OrderType.LIMIT,
    tp_price=Price.from_str("2050.00"),
    tp_post_only=True,
    tp_exec_algorithm_id=None,

    # Stop-loss order
    sl_order_type=OrderType.TRAILING_STOP_MARKET,
    sl_trigger_price=Price.from_str("1980.00"),
    sl_trailing_offset=Decimal("5.0"),
    sl_trailing_offset_type=TrailingOffsetType.PRICE,
    sl_exec_algorithm_id=None,
)

self.submit_order_list(order_list)
```

**Supported order types (as listed by explorer)**
- Entry: `MARKET`, `LIMIT`, `STOP_LIMIT`, `MARKET_IF_TOUCHED`, `LIMIT_IF_TOUCHED`
- TP: `LIMIT`, `LIMIT_IF_TOUCHED`, `TRAILING_STOP_LIMIT`
- SL: `STOP_MARKET`, `STOP_LIMIT`, `TRAILING_STOP_MARKET`, `TRAILING_STOP_LIMIT`

**Gold Scalper application ideas**
- Use trailing stop SL to lock in moves and reduce HWM-trap risk
- Assign exec algorithm only to entry leg; keep SL/TP immediate
- Use OUO for quantity sync when partial fills happen

---

## 3) Contingent Order Types (OCO / OTO / OUO)

**Location**: `/home/franco/projetos/nautilus_trader/nautilus_trader/execution/manager.pyx`

### 3.1 OTO (One-Triggers-Other)

**Behavior (as captured)**
- Parent triggers child orders when filled
- Partial-trigger model: children released pro-rata on each partial fill
- Full-trigger model: children released only after parent fully fills

**Gold Scalper application ideas**
- Entry triggers SL/TP automatically
- Partial-trigger ensures protection starts immediately on first fill

### 3.2 OCO (One-Cancels-Other)

**Behavior (as captured)**
- Multiple linked orders where execution of one cancels the others

**Gold Scalper application ideas**
- Link SL and TP so one cancels the other
- Prevent orphan orders after position close

### 3.3 OUO (One-Updates-Other)

**Behavior (as captured)**
- Execution of one reduces quantity of linked orders
- Best-effort proportional quantity update

**Gold Scalper application ideas**
- Partial TP reduces SL quantity to match remaining position

---

## 4) Order Modification / Amendment Patterns

**Location**: `/home/franco/projetos/nautilus_trader/nautilus_trader/execution/algorithm.pyx` (lines 1135-1257 per explorer)

### 4.1 Modify Order (live orders)

```python
self.modify_order(
    order=order,
    quantity=Quantity.from_str("0.05"),
    price=Price.from_str("2010.00"),
    trigger_price=Price.from_str("1990.00"),
)
```

**Behavior (as captured)**
- Generates `ModifyOrder` command to RiskEngine
- Uses Cancel/Replace request on FIX venues
- Falls back to cancel-and-replace if venue doesn’t support modify

**Validation (as captured)**
- At least one value must differ from original
- Cannot modify closed or PENDING_CANCEL orders

### 4.2 Modify Order In-Place (pre-submission)

```python
self.modify_order_in_place(
    order=order,
    quantity=new_quantity,
    price=new_price,
    trigger_price=new_trigger_price,
)
```

**Behavior (as captured)**
- Applies changes immediately without sending to venue
- Intended for INITIALIZED or RELEASED orders

**Gold Scalper application ideas**
- Tighten stop distance when approaching DD thresholds
- Adjust TP levels based on volatility regime changes

---

## 5) Reduce-Only Order Handling

**Location**: `/home/franco/projetos/nautilus_trader/docs/concepts/orders.md` (lines 169-177 per explorer)

**Behavior (as captured for SimulatedExchange)**
- Order canceled if associated position closes
- Order quantity reduced as position size decreases

**Code example**
```python
order = self.order_factory.stop_market(
    instrument_id=instrument_id,
    order_side=OrderSide.SELL,
    quantity=Quantity.from_str("0.1"),
    trigger_price=Price.from_str("1950.00"),
    reduce_only=True,
)
```

**Gold Scalper application ideas**
- All SL/TP should be reduce_only=True
- Prevent accidental position flips after manual close

---

## 6) Order Emulation (local order types)

**Location**: `/home/franco/projetos/nautilus_trader/docs/concepts/orders.md` (lines 689-860 per explorer)

**What it does**
- Emulates advanced order types locally when venue doesn’t support them
- Monitors market price and releases appropriate MARKET/LIMIT when triggered

**Emulation triggers (as captured)**
- `NO_TRIGGER`: disabled
- `DEFAULT` / `BID_ASK`: trigger on quotes
- `LAST_PRICE`: trigger on trades
- `MID_POINT`: trigger on mid price
- `MARK_PRICE`: mark price (derivatives)

**Emulated types (as captured)**
| Order Type | Released As |
|---|---|
| LIMIT | MARKET |
| STOP_MARKET | MARKET |
| STOP_LIMIT | LIMIT |
| MARKET_IF_TOUCHED | MARKET |
| LIMIT_IF_TOUCHED | LIMIT |
| TRAILING_STOP_MARKET | MARKET |
| TRAILING_STOP_LIMIT | LIMIT |

**Code example**
```python
order = self.order_factory.stop_limit(
    instrument_id=instrument_id,
    order_side=OrderSide.SELL,
    quantity=Quantity.from_str("0.1"),
    price=Price.from_str("1948.00"),
    trigger_price=Price.from_str("1950.00"),
    emulation_trigger=TriggerType.BID_ASK,
)
```

**Gold Scalper application ideas**
- Emulate trailing stops if broker doesn’t support them natively
- Use quote-based trigger (BID_ASK) for FX/metals realism

---

## 7) OrderManager (contingency handler)

**Location**: `/home/franco/projetos/nautilus_trader/nautilus_trader/execution/manager.pyx`

**Key methods (as captured)**
```python
handle_order_filled(filled: OrderFilled)
handle_contingencies(order: Order)
handle_contingencies_update(order: Order)
modify_order_quantity(order: Order, new_quantity: Quantity)
cancel_order(order: Order)
```

**Behavior for OTO on fill (as captured)**
1. Get position_id and client_id from parent
2. Calculate parent_filled_qty (considers exec_spawn_id)
3. For each linked child order:
   - Update child quantity to match parent filled qty
   - Submit child orders

---

## 8) Smart Order Routing (component chain)

**Routing chain (as captured)**
```
Strategy -> OrderEmulator -> ExecAlgorithm -> RiskEngine -> ExecutionEngine -> ExecutionClient
```

**Routing decisions (as captured)**
1. If `emulation_trigger != NO_TRIGGER` → OrderEmulator
2. If `exec_algorithm_id` set → ExecAlgorithm
3. All orders pass through RiskEngine pre-trade checks
4. Client routing via `client_id` or venue inference

**Example (as captured)**
```python
from nautilus_trader.examples.strategies.ema_cross_bracket_algo import EMACrossBracketAlgo

config = EMACrossBracketAlgoConfig(
    instrument_id=instrument_id,
    bar_type=bar_type,
    trade_size=Decimal("0.1"),
    bracket_distance_atr=3.0,

    # Entry uses TWAP
    entry_exec_algorithm_id=ExecAlgorithmId("TWAP"),
    entry_exec_algorithm_params={"horizon_secs": 30, "interval_secs": 5},

    # SL/TP no algorithm
    sl_exec_algorithm_id=None,
    tp_exec_algorithm_id=None,
)
```

---

## 9) Display Quantity (Iceberg / hidden)

**Location**: `/home/franco/projetos/nautilus_trader/nautilus_trader/common/factories.pyx`

**What it does**
- `display_qty=0` creates hidden order
- Partial display to book

**Code example**
```python
order = self.order_factory.limit(
    instrument_id=instrument_id,
    order_side=OrderSide.BUY,
    quantity=Quantity.from_str("10.0"),
    price=Price.from_str("2000.00"),
    display_qty=Quantity.from_str("1.0"),
)
```

---

## 10) Implementation Recommendations (captured)

### 10.1 TWAP for emergency close
```python
emergency_order = self.order_factory.market(
    instrument_id=self.instrument_id,
    order_side=close_side,
    quantity=position.quantity,
    reduce_only=True,
    exec_algorithm_id=ExecAlgorithmId("TWAP"),
    exec_algorithm_params={
        "horizon_secs": 300,
        "interval_secs": 30,
    },
)
```

### 10.2 Trailing stops for HWM protection
```python
bracket = self.order_factory.bracket(
    instrument_id=instrument_id,
    order_side=OrderSide.BUY,
    quantity=quantity,

    sl_order_type=OrderType.TRAILING_STOP_MARKET,
    sl_trigger_price=initial_sl_price,
    sl_trailing_offset=Decimal(str(atr_value * 1.5)),
    sl_trailing_offset_type=TrailingOffsetType.PRICE,

    tp_order_type=OrderType.LIMIT,
    tp_price=tp_price,
)
```

### 10.3 Custom Apex-aware exec algorithm (concept)
```python
class ApexSafeExecAlgorithm(ExecAlgorithm):
    """Execution algorithm that respects Apex HWM/DD constraints."""

    def on_order(self, order: Order) -> None:
        trailing_dd = self.get_trailing_dd()

        if trailing_dd >= 0.04:
            self.log.warning("Trailing DD at HALT level, canceling order")
            self.cancel_order(order)
            return

        if trailing_dd >= 0.035:
            self._execute_cautiously(order)
        else:
            self.submit_order(order)
```

### 10.4 Dynamic order modification for DD protection (concept)
```python
def check_and_adjust_stops(self):
    trailing_dd_pct = self.calculate_trailing_dd()

    for order in self.cache.orders_open(instrument_id=self.instrument_id):
        if order.is_reduce_only and order.order_type in [OrderType.STOP_MARKET, OrderType.TRAILING_STOP_MARKET]:
            if trailing_dd_pct >= 0.03:
                new_trigger = self._calculate_tighter_stop(order, factor=0.8)
                self.modify_order(order, trigger_price=new_trigger)
```

---

## Key referenced paths (from explorer)
- `/home/franco/projetos/nautilus_trader/nautilus_trader/examples/algorithms/twap.py`
- `/home/franco/projetos/nautilus_trader/nautilus_trader/execution/algorithm.pyx`
- `/home/franco/projetos/nautilus_trader/nautilus_trader/common/factories.pyx:1193`
- `/home/franco/projetos/nautilus_trader/nautilus_trader/execution/manager.pyx`
- `/home/franco/projetos/nautilus_trader/docs/concepts/execution.md`
- `/home/franco/projetos/nautilus_trader/docs/concepts/orders.md`
- `/home/franco/projetos/nautilus_trader/nautilus_trader/examples/strategies/ema_cross_bracket_algo.py`
- `/home/franco/projetos/nautilus_trader/nautilus_trader/execution/config.py`
