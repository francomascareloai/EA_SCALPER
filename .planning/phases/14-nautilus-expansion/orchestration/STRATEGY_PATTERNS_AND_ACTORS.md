# NautilusTrader — Strategy Patterns & Actors (Full Findings)

Created: 2025-12-27
Source: Explorer subagent output (advanced strategy patterns scan)
Purpose: Preserve complete scope for later implementation work.

---

## Files analyzed (as captured)

- `/home/franco/projetos/EA_SCALPER_XAUUSD/.venv/lib/python3.12/site-packages/nautilus_trader/trading/controller.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/.venv/lib/python3.12/site-packages/nautilus_trader/trading/trader.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/.venv/lib/python3.12/site-packages/nautilus_trader/trading/messages.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/.venv/lib/python3.12/site-packages/nautilus_trader/common/actor.pyx`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/.venv/lib/python3.12/site-packages/nautilus_trader/common/signal.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/.venv/lib/python3.12/site-packages/nautilus_trader/examples/strategies/signal_strategy.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/.venv/lib/python3.12/site-packages/nautilus_trader/examples/strategies/orderbook_imbalance.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/.venv/lib/python3.12/site-packages/nautilus_trader/examples/strategies/market_maker.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/.venv/lib/python3.12/site-packages/nautilus_trader/examples/strategies/ema_cross_bracket.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/.venv/lib/python3.12/site-packages/nautilus_trader/examples/strategies/ema_cross_twap.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/.venv/lib/python3.12/site-packages/nautilus_trader/examples/strategies/volatility_market_maker.py`
- `/home/franco/projetos/EA_SCALPER_XAUUSD/.venv/lib/python3.12/site-packages/nautilus_trader/examples/algorithms/twap.py`

---

## Pattern 1: Controller pattern (multi-strategy orchestration)

**Enables**: Create/start/stop/remove strategies via commands at runtime.

**Location**: `.../nautilus_trader/trading/controller.py`

**Example (as captured)**
```python
from nautilus_trader.trading.controller import Controller
from nautilus_trader.trading.trader import Trader
from nautilus_trader.trading.messages import CreateStrategy, StartStrategy, StopStrategy

class MyController(Controller):
    def __init__(self, trader: Trader) -> None:
        super().__init__(trader)

    def execute(self, command: Command) -> None:
        if isinstance(command, CreateStrategy):
            self.create_strategy_from_config(command.strategy_config, command.start)
        elif isinstance(command, StartStrategy):
            self.start_strategy_from_id(command.strategy_id)
        elif isinstance(command, StopStrategy):
            self.stop_strategy_from_id(command.strategy_id)
```

---

## Pattern 2: Signal publishing pattern (actor communication)

**Enables**: Inter-strategy comms via publish/subscribe on MessageBus.

**Location**: `.../nautilus_trader/common/actor.pyx` (line 2569 per explorer)

**Example (as captured)**
```python
class SignalStrategy(Strategy):
    def on_quote_tick(self, tick: QuoteTick) -> None:
        self.counter += 1
        self.publish_signal(name="counter", value=self.counter, ts_event=tick.ts_event)

class ConsumerStrategy(Strategy):
    def on_start(self) -> None:
        self.subscribe_data(DataType(SignalCounter))

    def on_data(self, data: Data) -> None:
        if isinstance(data, SignalCounter):
            self.log.info(f"Received signal: {data.value}")
```

---

## Pattern 3: Custom data publishing pattern

**Enables**: Publish arbitrary custom data types across actors/strategies.

**Location**: `.../nautilus_trader/common/actor.pyx` (line 2550 per explorer)

**Example (as captured)**
```python
from nautilus_trader.model.data import DataType
from nautilus_trader.core.data import Data

class RegimeData(Data):
    def __init__(self, regime: str, confidence: float, ts_event: int, ts_init: int):
        self.regime = regime
        self.confidence = confidence
        self._ts_event = ts_event
        self._ts_init = ts_init

self.publish_data(DataType(RegimeData), regime_data)
self.subscribe_data(DataType(RegimeData))

def on_data(self, data: Data) -> None:
    if isinstance(data, RegimeData):
        self._current_regime = data.regime
```

---

## Pattern 4: Execution algorithm pattern (order flow control)

**Enables**: Separate execution logic from strategy logic.

**Location**: `.../examples/algorithms/twap.py`

**Example (as captured)**
```python
from nautilus_trader.execution.algorithm import ExecAlgorithm
from nautilus_trader.model.identifiers import ExecAlgorithmId

class TWAPExecAlgorithm(ExecAlgorithm):
    def on_order(self, order: Order) -> None:
        exec_params = order.exec_algorithm_params
        horizon_secs = exec_params.get("horizon_secs")
        interval_secs = exec_params.get("interval_secs")

        spawned_order = self.spawn_market(primary=order, quantity=chunk_qty)
        self.submit_order(spawned_order)

        self.clock.set_timer(
            name=order.client_order_id.value,
            interval=timedelta(seconds=interval_secs),
            callback=self.on_time_event,
        )

class MyStrategy(Strategy):
    def buy(self) -> None:
        order = self.order_factory.market(
            instrument_id=self.instrument_id,
            order_side=OrderSide.BUY,
            quantity=large_qty,
            exec_algorithm_id=ExecAlgorithmId("TWAP"),
            exec_algorithm_params={"horizon_secs": 30, "interval_secs": 3},
        )
        self.submit_order(order)
```

---

## Pattern 5: Bracket order pattern

**Enables**: Submit entry+SL+TP as a managed order group.

**Location**: `.../examples/strategies/ema_cross_bracket.py`

**Example (as captured)**
```python
from nautilus_trader.model.orders.list import OrderList

def buy(self, last_bar: Bar) -> None:
    bracket_distance = self.atr.value * self.config.bracket_distance_atr

    order_list: OrderList = self.order_factory.bracket(
        instrument_id=self.instrument_id,
        order_side=OrderSide.BUY,
        quantity=self.instrument.make_qty(self.config.trade_size),
        time_in_force=TimeInForce.GTD,
        expire_time=self.clock.utc_now() + timedelta(seconds=30),
        entry_price=self.instrument.make_price(last_bar.close),
        entry_trigger_price=self.instrument.make_price(last_bar.close),
        sl_trigger_price=self.instrument.make_price(last_bar.close - bracket_distance),
        tp_price=self.instrument.make_price(last_bar.close + bracket_distance),
        entry_order_type=OrderType.LIMIT_IF_TOUCHED,
        emulation_trigger=TriggerType.DEFAULT,
    )

    self.submit_order_list(order_list)
```

---

## Pattern 6: State management pattern (save/load)

**Enables**: Persist and restore strategy state across restarts.

**Location**: example noted as `.../examples/strategies/ema_cross_bracket.py`

**Example (as captured)**
```python
def on_save(self) -> dict[str, bytes]:
    return {
        "position_count": str(self._position_count).encode(),
        "last_signal": self._last_signal.encode(),
        "hwm": str(self._hwm).encode(),
    }

def on_load(self, state: dict[str, bytes]) -> None:
    self._position_count = int(state.get("position_count", b"0").decode())
    self._last_signal = state.get("last_signal", b"").decode()
    self._hwm = float(state.get("hwm", b"0").decode())
```

---

## Pattern 7: Event-driven order replacement (market maker)

**Enables**: Replace orders based on fill events.

**Location**: `.../examples/strategies/volatility_market_maker.py`

**Example (as captured)**
```python
def on_event(self, event: Event) -> None:
    if isinstance(event, OrderFilled):
        if self.buy_order and event.order_side == OrderSide.BUY:
            if self.buy_order.is_closed:
                self.create_buy_order(last_quote)
        elif self.sell_order and event.order_side == OrderSide.SELL:
            if self.sell_order.is_closed:
                self.create_sell_order(last_quote)
```

---

## Pattern 8: Position inventory management (skew)

**Enables**: Adjust behavior based on current inventory.

**Location**: `.../examples/strategies/market_maker.py`

**Example (as captured)**
```python
def on_event(self, event: Event) -> None:
    if isinstance(event, (PositionOpened, PositionChanged)):
        signed_qty = event.quantity.as_decimal()
        if event.side == PositionSide.SHORT:
            signed_qty = -signed_qty
        self._adj = (signed_qty / self.max_size) * Decimal("0.01")
    elif isinstance(event, PositionClosed):
        self._adj = Decimal(0)


def on_order_book_deltas(self, deltas: OrderBookDeltas) -> None:
    mid = (bid_price + ask_price) / 2
    val = self._mid + self._adj
    self.buy(price=val * Decimal("1.01"))
    self.sell(price=val * Decimal("0.99"))
```

---

## Pattern 9: Indicator registration pattern

**Enables**: Auto-update indicators without manual calls.

**Location**: `.../nautilus_trader/common/actor.pyx` (line 764 per explorer)

**Example (as captured)**
```python
def on_start(self) -> None:
    self.register_indicator_for_bars(self.config.bar_type, self.atr)
    self.register_indicator_for_bars(self.config.bar_type, self.fast_ema)
    self.register_indicator_for_bars(self.config.bar_type, self.slow_ema)


def on_bar(self, bar: Bar) -> None:
    if not self.indicators_initialized():
        return
    if self.fast_ema.value > self.slow_ema.value:
        self.buy()
```

---

## Pattern 10: Order throttling pattern

**Enables**: Rate limit to prevent over-trading.

**Location**: `.../examples/strategies/orderbook_imbalance.py`

**Example (as captured)**
```python
class OrderBookImbalance(Strategy):
    def __init__(self, config):
        self._last_trigger_timestamp: datetime | None = None

    def check_trigger(self) -> None:
        seconds_since_last = (self.clock.utc_now() - self._last_trigger_timestamp).total_seconds()

        if larger > self.config.trigger_min_size and ratio < self.config.trigger_imbalance_ratio:
            if len(self.cache.orders_inflight(strategy_id=self.id)) > 0:
                self.log.info("Already have orders in flight - skipping")
            elif seconds_since_last < self.config.min_seconds_between_triggers:
                self.log.info("Time since last order < min_seconds - skipping")
            else:
                self._last_trigger_timestamp = self.clock.utc_now()
                self.submit_order(order)
```

---

## Architecture recommendations captured

1. Regime detection actor publishes regime signals (trending/ranging/volatile).
2. Controller starts/stops SMC vs MR strategies based on regime.
3. Custom execution algos for compliance.
4. Use on_save/on_load for HWM/DD recovery.
5. Signal bus architecture: RegimeActor + RiskGuardActor → execution strategies.
