# NautilusTrader — Risk Engine & Sizing (Full Findings)

Created: 2025-12-27
Source: Explorer subagent output (risk management scan)
Purpose: Preserve complete scope for later implementation work.

---

## 1) RiskEngineConfig — Core Pre-Trade Risk Controls

**File (as discovered)**: `/home/franco/projetos/EA_SCALPER_XAUUSD/.venv/lib/python3.12/site-packages/nautilus_trader/risk/config.py`

| Feature | Config Parameter | Default | Description |
|---|---|---:|---|
| Bypass mode | `bypass: bool` | `False` | If True, bypasses all pre-trade risk checks and rate limits (still checks duplicate IDs) |
| Submit rate limit | `max_order_submit_rate: str` | `"100/00:00:01"` | Maximum rate of submit order commands per timedelta |
| Modify rate limit | `max_order_modify_rate: str` | `"100/00:00:01"` | Maximum rate of modify order commands per timedelta |
| Max notional per order | `max_notional_per_order: dict[str, int]` | `{}` | Maximum notional value per order per instrument ID |
| Debug mode | `debug: bool` | `False` | Extra debug logging |

**Example (as captured)**
```python
from nautilus_trader.risk.config import RiskEngineConfig

risk_config = RiskEngineConfig(
    bypass=False,
    max_order_submit_rate="10/00:00:01",
    max_order_modify_rate="5/00:00:01",
    max_notional_per_order={
        "XAUUSD.APEX": 50000,
    },
    debug=False,
)
```

**Apex relevance (as captured)**
- Submit/modify throttles reduce rapid-fire order storms
- Max notional caps prevent single-trade exposure spikes
- `bypass=True` must never be used in live

---

## 2) TradingState — Global Trading State Control

**File (as discovered)**: `/home/franco/projetos/EA_SCALPER_XAUUSD/.venv/lib/python3.12/site-packages/nautilus_trader/risk/engine.pyx`

| State | Value | Behavior |
|---|---:|---|
| `ACTIVE` | 1 | Normal trading (all allowed) |
| `HALTED` | 2 | Trading denied except cancels |
| `REDUCING` | 3 | Only orders that reduce open positions allowed |

**Example (as captured)**
```python
from nautilus_trader.model.enums import TradingState

risk_engine.set_trading_state(TradingState.REDUCING)
risk_engine.set_trading_state(TradingState.HALTED)
risk_engine.set_trading_state(TradingState.ACTIVE)
```

---

## 3) Built-in Pre-Trade Risk Checks

**File (as discovered)**: `/home/franco/projetos/EA_SCALPER_XAUUSD/.venv/lib/python3.12/site-packages/nautilus_trader/risk/engine.pyx`

The RiskEngine performs these checks automatically (as captured):

| Check | Description | Denial Reason |
|---|---|---|
| Reduce-only validation | Ensures reduce_only orders actually reduce position | "Reduce only order would increase position" |
| Instrument exists | Validates instrument in cache | "Instrument not found" |
| Price precision | Validates price precision matches instrument | "price invalid (precision > instrument)" |
| Price positive | Ensures non-option prices are positive | "price invalid (not positive)" |
| Quantity precision | Validates quantity precision | "quantity invalid (precision > size_precision)" |
| Quantity min/max | Validates instrument limits | "quantity invalid (> max / < min)" |
| GTD expiry | Ensures GTD orders haven't expired | "GTD already passed" |
| Notional limit | Checks max_notional_per_order | "NOTIONAL_EXCEEDS_MAX_PER_ORDER" |
| Min notional instrument | Checks instrument min_notional | "NOTIONAL_LESS_THAN_MIN_FOR_INSTRUMENT" |
| Max notional instrument | Checks instrument max_notional | "NOTIONAL_GREATER_THAN_MAX_FOR_INSTRUMENT" |
| Balance check | Order doesn't exceed free balance | "NOTIONAL_EXCEEDS_FREE_BALANCE" |
| Cumulative notional | Cumulative orders don't exceed balance | "CUM_NOTIONAL_EXCEEDS_FREE_BALANCE" |

---

## 4) Throttler Component

**File (as discovered)**: `/home/franco/projetos/EA_SCALPER_XAUUSD/.venv/lib/python3.12/site-packages/nautilus_trader/common/component.pyx` (line 2893 per explorer)

Generic rate limiter that can buffer or drop messages exceeding the limit.

**Example (as captured)**
```python
from nautilus_trader.common.component import Throttler

throttler = Throttler(
    name="ORDER_SUBMIT",
    limit=10,
    interval=pd.Timedelta(seconds=1),
    output_send=handle_allowed,
    output_drop=handle_dropped,
    clock=clock,
)

throttler.send(command)
```

---

## 5) Position Sizing — FixedRiskSizer

**File (as discovered)**: `/home/franco/projetos/EA_SCALPER_XAUUSD/.venv/lib/python3.12/site-packages/nautilus_trader/risk/sizing.pyx`

**Example (as captured)**
```python
from nautilus_trader.risk.sizing import FixedRiskSizer
from decimal import Decimal

sizer = FixedRiskSizer(instrument)

quantity = sizer.calculate(
    entry=Price.from_str("2650.00"),
    stop_loss=Price.from_str("2645.00"),
    equity=Money(50000, USD),
    risk=Decimal("0.01"),
    commission_rate=Decimal("0.0001"),
    exchange_rate=Decimal("1.0"),
    hard_limit=Decimal("10"),
    unit_batch_size=Decimal("0.01"),
    units=1,
)
```

---

## 6) Portfolio Position Tracking (selected methods)

**File (as discovered)**: `/home/franco/projetos/EA_SCALPER_XAUUSD/.venv/lib/python3.12/site-packages/nautilus_trader/portfolio/base.pyx`

| Method | Returns | Description |
|---|---|---|
| `is_net_long(instrument_id)` | bool | net long |
| `is_net_short(instrument_id)` | bool | net short |
| `is_flat(instrument_id)` | bool | no position |
| `is_completely_flat()` | bool | all positions closed |
| `net_position(instrument_id)` | Decimal | net position |
| `net_exposure(instrument_id)` | Money | net exposure |
| `unrealized_pnl(instrument_id)` | Money | unrealized PnL |
| `realized_pnl(instrument_id)` | Money | realized PnL |
| `total_pnl(instrument_id)` | Money | realized + unrealized |
| `net_exposures(venue)` | dict | all exposures |

---

## 7) LiveRiskEngineConfig (live trading extensions)

**File (as discovered)**: `/home/franco/projetos/EA_SCALPER_XAUUSD/.venv/lib/python3.12/site-packages/nautilus_trader/live/config.py`

| Parameter | Type | Default | Description |
|---|---|---:|---|
| `qsize` | PositiveInt | 100_000 | Queue size for internal buffers |
| `graceful_shutdown_on_exception` | bool | False | Graceful shutdown on exception |

**Example (as captured)**
```python
from nautilus_trader.live.config import LiveRiskEngineConfig

live_risk_config = LiveRiskEngineConfig(
    bypass=False,
    max_order_submit_rate="5/00:00:01",
    max_order_modify_rate="3/00:00:01",
    max_notional_per_order={
        "XAUUSD.APEX": 25000,
    },
    qsize=10_000,
    graceful_shutdown_on_exception=True,
)
```

---

## 8) BacktestVenueConfig — simulation risk features

**File (as discovered)**: `/home/franco/projetos/EA_SCALPER_XAUUSD/.venv/lib/python3.12/site-packages/nautilus_trader/backtest/config.py`

| Parameter | Default | Description |
|---|---:|---|
| `reject_stop_orders` | True | reject stop if trigger price in market |
| `support_gtd_orders` | True | support GTD |
| `support_contingent_orders` | True | support OCO/OTO/OUO |
| `use_reduce_only` | True | honor reduce_only |
| `frozen_account` | False | freeze balances |
| `fill_model` | None | custom fill model |
| `latency_model` | None | custom latency model |
| `fee_model` | None | custom fee model |

**Example (as captured)**
```python
from nautilus_trader.backtest.config import BacktestVenueConfig

venue_config = BacktestVenueConfig(
    name="APEX",
    oms_type="HEDGING",
    account_type="MARGIN",
    starting_balances=["50000 USD"],
    default_leverage=50.0,
    reject_stop_orders=True,
    use_reduce_only=True,
    frozen_account=False,
)
```

---

## 9) Runtime Risk Methods (RiskEngine)

| Method | Description |
|---|---|
| `set_trading_state(state)` | Change global trading state |
| `set_max_notional_per_order(instrument_id, value)` | Dynamically set max notional |
| `max_order_submit_rate()` | Get submit rate limit |
| `max_order_modify_rate()` | Get modify rate limit |
| `max_notionals_per_order()` | Get max notional settings |

---

## 10) Recommendations captured for Apex

- Use portfolio unrealized PnL and conservative bid/ask for equity tracking (HWM-trap safe)
- Use TradingState transitions for DD/time-gates
- Use FixedRiskSizer for consistent per-trade risk control
- Configure submit/modify throttles and max notionals
