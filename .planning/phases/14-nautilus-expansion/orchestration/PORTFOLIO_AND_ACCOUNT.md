# NautilusTrader — Portfolio & Account Management (Full Findings)

Created: 2025-12-27
Source: Explorer subagent output (portfolio/account scan)
Purpose: Preserve complete scope for later implementation work.

---

## 1) Portfolio-level position management

**File (as captured)**: `/home/franco/projetos/nautilus_trader/nautilus_trader/portfolio/portfolio.pyx`

Key methods (as captured):

| Method | Description | Apex use |
|---|---|---|
| `net_position(instrument_id)` | net position quantity | per-instrument exposure |
| `is_flat(instrument_id)` | no open position | verify closed at time gate |
| `is_net_long(instrument_id)` | net long | direction |
| `is_net_short(instrument_id)` | net short | direction |
| `net_exposure(instrument_id, price)` | exposure in Money | total $ at risk |
| `net_exposures(venue)` | all exposures | aggregate venue exposure |

Example (from explorer reference): `/home/franco/projetos/nautilus_trader/examples/backtest/example_05_using_portfolio/strategy.py` (lines 116-148)
```python
def show_portfolio_info(self, intro_message: str = ""):
    is_flat = self.portfolio.is_flat(self.config.instrument.id)
    net_position = self.portfolio.net_position(self.config.instrument.id)
    net_exposure = self.portfolio.net_exposure(self.config.instrument.id)

    realized_pnl = self.portfolio.realized_pnl(self.config.instrument.id)
    unrealized_pnl = self.portfolio.unrealized_pnl(self.config.instrument.id)

    margins_init = self.portfolio.margins_init(self.config.instrument.venue)
    margins_maint = self.portfolio.margins_maint(self.config.instrument.venue)
    balances_locked = self.portfolio.balances_locked(self.config.instrument.venue)
```

---

## 2) Account state tracking and reporting

**Files (as captured)**
- `/home/franco/projetos/nautilus_trader/nautilus_trader/accounting/accounts/base.pyx`
- `/home/franco/projetos/nautilus_trader/nautilus_trader/accounting/accounts/margin.pyx`

Account base methods (as captured):

| Method | Returns | Description |
|---|---|---|
| `starting_balances()` | dict[Currency, Money] | initial balances |
| `balances()` | dict[Currency, AccountBalance] | current balances |
| `balances_total()` | dict[Currency, Money] | totals |
| `balances_free()` | dict[Currency, Money] | free |
| `balances_locked()` | dict[Currency, Money] | locked |
| `balance_total(currency)` | Money | total |
| `balance_free(currency)` | Money | free |
| `balance_locked(currency)` | Money | locked |
| `commissions()` | dict[Currency, Money] | total commissions |

Margin account extras (as captured):

| Method | Returns | Description |
|---|---|---|
| `margins()` | dict[InstrumentId, MarginBalance] | all margins |
| `margins_init()` | dict[InstrumentId, Money] | init/order margins |
| `margins_maint()` | dict[InstrumentId, Money] | maintenance margins |
| `leverages()` | dict[InstrumentId, Decimal] | leverage |

Account event publish (as captured):
```python
self._msgbus.publish_c(
    topic=f"events.account.{account.id}",
    msg=account_state,
)
```

---

## 3) Equity curve / PnL tracking

**File (as captured)**: `/home/franco/projetos/nautilus_trader/nautilus_trader/analysis/analyzer.py`

PortfolioAnalyzer fields (as captured):
```python
class PortfolioAnalyzer:
    def __init__(self):
        self._account_balances_starting: dict[Currency, Money] = {}
        self._account_balances: dict[Currency, Money] = {}
        self._positions: list[Position] = []
        self._realized_pnls: dict[Currency, pd.Series] = {}
        self._returns: pd.Series = pd.Series(dtype=float64)
```

Stats include (as captured): MaxDrawdown, SharpeRatio, SortinoRatio, CalmarRatio, WinRate, ProfitFactor, etc.

MaxDrawdown core logic (as captured):
```rust
let mut cumulative = 1.0;
let mut running_max = 1.0;
let mut max_drawdown = 0.0;

for &ret in returns.values() {
    cumulative *= 1.0 + ret;
    if cumulative > running_max {
        running_max = cumulative;
    }
    let drawdown = (running_max - cumulative) / running_max;
    if drawdown > max_drawdown {
        max_drawdown = drawdown;
    }
}
Some(-max_drawdown)
```

Note: returns-based DD != Apex equity+unrealized DD.

---

## 4) Multi-instrument portfolio handling

Portfolio supports multi-instrument aggregation and venue-level aggregation.

Venue-level methods (as captured):
- `realized_pnls(venue)`, `unrealized_pnls(venue)`, `total_pnls(venue)`, `net_exposures(venue)`

Per-instrument methods (as captured):
- `realized_pnl(instrument_id)`, `unrealized_pnl(instrument_id, price)`, `total_pnl(instrument_id)`, `net_exposure(instrument_id, price)`

---

## 5) Account balance monitoring (reports)

**Location (as captured)**: `/home/franco/projetos/nautilus_trader/docs/concepts/reports.md` (lines 139-170)

Example (as captured):
```python
from nautilus_trader.model.identifiers import Venue
venue = Venue("APEX")
account_report = trader.generate_account_report(venue)
```

Report columns (as captured):
- `ts_event`, `account_id`, `total`, `free`, `locked`, `margins`

---

## Apex HWM / DD tracking — gap analysis (captured)

Not built-in (as captured):
1. Trailing HWM tracking (equity + unrealized, tick-by-tick)
2. Trailing DD calculation from HWM
3. Session-based HWM reset

Proposed tracker concept (as captured):
```python
class ApexHWMTracker:
    def __init__(self, starting_equity: float):
        self.starting_equity = starting_equity
        self.hwm = starting_equity

    def update(self, current_equity: float, unrealized_pnl: float) -> tuple[float, float]:
        total_equity = current_equity + unrealized_pnl
        if total_equity > self.hwm:
            self.hwm = total_equity

        trailing_dd_pct = (self.hwm - total_equity) / self.hwm * 100
        daily_dd_pct = (self.starting_equity - total_equity) / self.starting_equity * 100
        return trailing_dd_pct, daily_dd_pct
```

Integration points (captured):
1. Subscribe to `events.account.*` on MessageBus
2. Use `portfolio.unrealized_pnl(instrument_id)` per tick
3. Use `account.balance_total()` for realized equity
4. Call update on every quote tick for open positions
