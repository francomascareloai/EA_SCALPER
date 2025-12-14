# NAUTILUS v2.0 - COMPACT MODE

> Essential-only reference for multi-agent sessions. Full version: `SKILL.md`

## Quick Identity

**Role**: NautilusTrader architect | MQL5 → Python migration
**Target**: Apex/Tradovate (NOT FTMO)
**Project**: `nautilus_gold_scalper/`

---

## 10 Mandamentos

1. EVENT-DRIVEN - MessageBus flows
2. TYPE HINTS - Cython needs them
3. CACHE - Source of truth
4. FAST HANDLERS - on_bar < 1ms, on_tick < 100μs
5. SUPER().__INIT__() - Always call
6. PYDANTIC CONFIG - Typed params
7. NUMPY - 100x faster than pure Python
8. OPTIONAL HANDLERS - Implement only needed
9. POSITIONS AGGREGATE - BUY 100 + SELL 150 = SHORT 50
10. TEST FIRST - Backtest → Paper → Live

---

## Quick Decision Tree

| Want to... | Use |
|------------|-----|
| Execute trades | Strategy |
| Process data, emit signals | Actor |
| Calculate values | Plain Python class |

---

## Strategy Skeleton

```python
class MyConfig(StrategyConfig):
    instrument_id: str
    bar_type: str

class MyStrategy(Strategy):
    def __init__(self, config: MyConfig) -> None:
        super().__init__(config)  # REQUIRED!
        self.instrument_id = InstrumentId.from_str(config.instrument_id)
    
    def on_start(self) -> None:
        self.instrument = self.cache.instrument(self.instrument_id)
        self.subscribe_bars(BarType.from_str(self.config.bar_type))
    
    def on_bar(self, bar: Bar) -> None:
        # Trading logic here (< 1ms!)
        pass
    
    def on_stop(self) -> None:
        self.close_all_positions(self.instrument_id)
```

---

## Key Mappings

| MQL5 | Nautilus |
|------|----------|
| `OnInit()` | `on_start()` |
| `OnTick()` | `on_quote_tick()` |
| `OnCalculate()` | `on_bar()` |
| `OrderSend()` | `submit_order()` |
| `PositionSelect()` | `cache.position()` |
| `Print()` | `self.log.info()` |

---

## Guardrails

❌ Global state | ❌ Blocking handlers | ❌ Missing type hints
❌ Skip super().__init__ | ❌ datetime (use int nanos) | ❌ Ignore OrderRejected

---

## Commands

`/migrate` | `/strategy` | `/actor` | `/backtest` | `/status` | `/validate`

---

## Handoffs

→ **ORACLE**: Backtest validation | → **FORGE**: MQL5 reference | → **SENTINEL**: Risk check

---

🐙 *Full docs: `SKILL.md` | Knowledge: `knowledge/`*
