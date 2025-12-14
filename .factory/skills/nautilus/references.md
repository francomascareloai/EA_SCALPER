# NAUTILUS References

## Official Documentation

### NautilusTrader
- **Main Docs**: https://nautilustrader.io/docs/
- **API Reference**: https://nautilustrader.io/docs/api_reference/
- **GitHub**: https://github.com/nautechsystems/nautilus_trader
- **Examples**: https://github.com/nautechsystems/nautilus_trader/tree/develop/examples

### Key Documentation Pages
- **Getting Started**: https://nautilustrader.io/docs/getting_started/
- **Strategies**: https://nautilustrader.io/docs/concepts/strategies
- **Actors**: https://nautilustrader.io/docs/concepts/actors
- **Backtesting**: https://nautilustrader.io/docs/tutorials/backtest_fx_bars
- **Data Catalog**: https://nautilustrader.io/docs/concepts/data_catalog

---

## Context7 Library Access

### Query NautilusTrader Docs
```
Use context7___get-library-docs with:
- context7CompatibleLibraryID: "/nautechsystems/nautilus_trader"
- topic: "strategy" | "actor" | "backtest" | "catalog" | "events"
- mode: "code" for examples, "info" for concepts
```

### Common Topics
| Topic | Use For |
|-------|---------|
| `strategy` | Strategy class, lifecycle, trading |
| `actor` | Actor pattern, data processing |
| `backtest` | BacktestNode, configuration |
| `catalog` | ParquetDataCatalog, data loading |
| `events` | Order events, position events |
| `orders` | Order types, submission |
| `config` | Pydantic configuration |

---

## Project Documentation

### Internal Docs
- **Migration Plan**: `DOCS/02_IMPLEMENTATION/NAUTILUS_MIGRATION_MASTER_PLAN.md`
- **Implementation Plan**: `DOCS/02_IMPLEMENTATION/PLAN_v1.md`
- **Progress Tracker**: `DOCS/02_IMPLEMENTATION/PROGRESS.md`

### Code Reference
- **Project Root**: `nautilus_gold_scalper/`
- **Migrated Modules**: `nautilus_gold_scalper/src/indicators/`
- **MQL5 Source**: `MQL5/Include/EA_SCALPER/`
- **Module Index**: `MQL5/Include/EA_SCALPER/INDEX.md`

---

## RAG Knowledge Bases

### MQL5 Documentation (Syntax)
```
Use mql5-docs___query_documents for:
- MQL5 function syntax
- Trading operations reference
- MetaTrader 5 API
```

### Trading Books (Concepts)
```
Use mql5-books___query_documents for:
- Trading strategies
- Risk management
- Machine learning for trading
- Statistical validation
```

---

## Key Classes Reference

### Strategy Class
```python
from nautilus_trader.trading.strategy import Strategy
from nautilus_trader.config import StrategyConfig

# Lifecycle: on_start → on_bar/on_tick → on_stop
# Key methods: submit_order, close_position, cache access
```

### Actor Class
```python
from nautilus_trader.common.actor import Actor
from nautilus_trader.config import ActorConfig

# Similar to Strategy but NO trading
# Use: publish_signal, data processing
```

### Key Imports
```python
# Models
from nautilus_trader.model import Bar, QuoteTick, Quantity, Price
from nautilus_trader.model.enums import OrderSide, TimeInForce
from nautilus_trader.model.identifiers import InstrumentId
from nautilus_trader.model.orders import MarketOrder, LimitOrder

# Events
from nautilus_trader.model.events import OrderFilled, PositionOpened, PositionClosed

# Backtest
from nautilus_trader.backtest.node import BacktestNode, BacktestRunConfig
from nautilus_trader.persistence.catalog import ParquetDataCatalog
```

---

## External Resources

### Python Performance
- NumPy Documentation: https://numpy.org/doc/
- Cython: https://cython.org/
- Polars: https://pola-rs.github.io/polars/

### Trading Research
- QuantConnect: https://www.quantconnect.com/docs
- Zipline: https://zipline.ml4trading.io/
- Backtrader: https://www.backtrader.com/docu/

---

## MCP Tools for NAUTILUS

| Need | Tool |
|------|------|
| NautilusTrader docs | `context7___get-library-docs` |
| MQL5 syntax | `mql5-docs___query_documents` |
| Trading concepts | `mql5-books___query_documents` |
| GitHub repos | `github___search_repositories` |
| Code search | `github___search_code` |
| Python sandbox | `e2b___run_code` |

---

## Version Info

- **NautilusTrader**: v1.180+ (latest stable)
- **Python**: 3.10+ required
- **NumPy**: 1.24+
- **Pydantic**: 2.0+
