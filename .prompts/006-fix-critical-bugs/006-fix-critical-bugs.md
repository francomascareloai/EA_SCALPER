# PROMPT 006: Fix All Critical P0 Bugs - Complete Implementation

## Objective

**Complete resolution** of all 12 P0 (blocker-level) bugs found across 4 audits (001-004):
- **5 bugs** from Apex Risk Audit (004) - CRITICAL for account survival
- **4 bugs** from Backtest Code Audit (003) - CRITICAL for realistic validation
- **3 bugs** from Nautilus Plan Audit (001) - CRITICAL for correctness

**Implementation approach**: Phased fixes in priority order:
1. **Phase 1**: Apex Compliance (bugs 8-12) - 3-4 days
2. **Phase 2**: Backtest Realism (bugs 4-7) - 2 days  
3. **Phase 3**: Code Correctness (bugs 1-3) - 2.5 days

**Why this matters**: System is currently **NO-GO for live Apex trading** due to missing time constraints, consistency rule, and backtest realism issues. Apex will **TERMINATE account** if these rules are violated. Must fix before any live deployment.

---

## Context

**Dependencies** (MUST READ ALL):
- @.prompts/001-nautilus-plan-refine/nautilus-plan-audit.md (bugs 1-3)
- @.prompts/002-backtest-data-research/backtest-data-research.md (data quality baseline)
- @.prompts/003-backtest-code-audit/backtest-code-audit.md (bugs 4-7)
- @.prompts/004-apex-risk-audit/apex-risk-audit.md (bugs 8-12)

**Current state**: All modules exist but have critical bugs preventing production use

**Target files** (will be modified):
```
nautilus_gold_scalper/src/
├── risk/
│   ├── prop_firm_manager.py        # Bugs 4, 8, 9, 11, 12
│   ├── circuit_breaker.py          # Bug 10
│   └── position_sizer.py           # Bug 6
├── strategies/
│   ├── gold_scarper_strategy.py    # Bugs 1, 8, 9, 10
│   └── base_strategy.py            # Bug 4
├── signals/
│   └── confluence_scorer.py        # Bug 2
└── execution/
    └── trade_manager.py            # Bug 5

+ NEW FILES:
├── risk/time_constraint_manager.py # Bug 8 (new module)
└── risk/consistency_tracker.py     # Bug 9 (new module)
```

**Dynamic context**:
- !`git status --short` (current changes)
- !`grep -rn "TODO\|FIXME\|BUG" nautilus_gold_scalper/src/ | wc -l` (known issues)

---

## Bug Inventory (12 P0 Blockers)

### 🔴 APEX COMPLIANCE BUGS (HIGHEST PRIORITY)

| Bug | Source | File | Impact | Effort | Owner |
|-----|--------|------|--------|--------|-------|
| **#8** | Audit 004 | NEW: time_constraint_manager.py | Apex TERMINATES if trade after 4:59 PM ET | 2 days | SENTINEL |
| **#9** | Audit 004 | NEW: consistency_tracker.py | Apex TERMINATES if profit > 30%/day | 1 day | SENTINEL |
| **#10** | Audit 004 | circuit_breaker.py + strategy | No graduated DD protection | 0.5 day | FORGE |
| **#11** | Audit 004 | prop_firm_manager.py | Weak termination (blocks trades, doesn't STOP) | 0.25 day | SENTINEL |
| **#12** | Audit 004 | prop_firm_manager.py | Unclear if unrealized P&L in DD calc | 0.5 day | SENTINEL |

### 🟡 BACKTEST REALISM BUGS

| Bug | Source | File | Impact | Effort | Owner |
|-----|--------|------|--------|--------|-------|
| **#4** | Audit 003 | prop_firm_manager.py + base_strategy | Daily DD never resets (no `on_new_day`) | 0.5 day | SENTINEL |
| **#5** | Audit 003 | trade_manager.py + backtest config | Zero slippage/commission = unrealistic results | 0.5 day | FORGE |
| **#6** | Audit 003 | position_sizer.py | Receives price units instead of pips | 0.5 day | FORGE |
| **#7** | Audit 003 | Multiple files | Threshold drift (70 vs 65 vs 50) | 0.5 day | FORGE |

### 🟢 CODE CORRECTNESS BUGS

| Bug | Source | File | Impact | Effort | Owner |
|-----|--------|------|--------|--------|-------|
| **#1** | Audit 001 | gold_scalper_strategy.py | Threshold 65 should be 70 (accepts bad TIER-C signals) | 0.5 hour | FORGE |
| **#2** | Audit 001 | confluence_scorer.py | Config `confluence_min_score` defined but not used | 0.5 hour | FORGE |
| **#3** | Audit 001 | NEW: ninjatrader_adapter.py | 42-line stub needs full implementation | 2 days | FORGE |

---

## Requirements - Detailed Implementation Specs

### 🔴 PHASE 1: APEX COMPLIANCE (CRITICAL - 3-4 days)

#### Bug #8: Time Constraint Manager (2 days - SENTINEL)

**Create NEW module**: `nautilus_gold_scalper/src/risk/time_constraint_manager.py`

**Requirements**:
1. **Timezone handling**: America/New_York (ET) with DST awareness
2. **4-level warnings**:
   - Level 1 (4:00 PM ET): Log warning "1 hour to cutoff"
   - Level 2 (4:30 PM ET): Log urgent "30 min to cutoff - prepare close"
   - Level 3 (4:55 PM ET): Emergency "5 min to cutoff - closing positions"
   - Level 4 (4:59 PM ET): FORCE close ALL positions + block new orders
3. **Continuous checking**: Check time on EVERY `on_bar` / `on_tick`
4. **Override mechanism**: Emergency manual override (for testing only)
5. **Logging**: Structured logging of all time events

**Implementation skeleton**:
```python
from datetime import datetime, time
from zoneinfo import ZoneInfo
from nautilus_trader.model.identifiers import PositionId
from nautilus_trader.trading.strategy import Strategy

class TimeConstraintManager:
    """Enforces Apex 4:59 PM ET position closure requirement."""
    
    def __init__(self, strategy: Strategy):
        self.strategy = strategy
        self.cutoff_time = time(16, 59)  # 4:59 PM
        self.warning_times = {
            "warning": time(16, 0),   # 4:00 PM
            "urgent": time(16, 30),   # 4:30 PM
            "emergency": time(16, 55) # 4:55 PM
        }
        self.et_tz = ZoneInfo("America/New_York")
        self._warnings_issued = set()
    
    def check_time_constraints(self) -> bool:
        """
        Check if time constraints allow trading.
        Returns: True if can trade, False if must close.
        """
        current_et = datetime.now(self.et_tz).time()
        
        # Issue warnings
        for level, warning_time in self.warning_times.items():
            if current_et >= warning_time and level not in self._warnings_issued:
                self._issue_warning(level, current_et)
                self._warnings_issued.add(level)
        
        # Force close at cutoff
        if current_et >= self.cutoff_time:
            self._force_close_all_positions()
            return False  # Block trading
        
        return True  # Can trade
    
    def _force_close_all_positions(self):
        """Emergency close all positions at 4:59 PM ET."""
        for position in self.strategy.cache.positions_open():
            self.strategy.close_position(
                position,
                client_id=self.strategy.client_id,
                tags=["APEX_TIME_CUTOFF"]
            )
        self.strategy.log.critical("APEX TIME CUTOFF: All positions closed at 4:59 PM ET")
    
    def _issue_warning(self, level: str, current_time: time):
        """Log time constraint warnings."""
        # Implementation: structured logging
    
    def reset_daily(self):
        """Reset warnings for new trading day."""
        self._warnings_issued.clear()
```

**Integration points**:
- Add to `gold_scalper_strategy.py`:
  ```python
  self.time_manager = TimeConstraintManager(self)
  
  def on_bar(self, bar: Bar):
      if not self.time_manager.check_time_constraints():
          return  # Block trading after 4:59 PM
      # ... rest of logic
  ```

PLACEHOLDER

---

#### Bug #9: Consistency Rule Tracker (1 day - SENTINEL)

**Create NEW module**: `nautilus_gold_scalper/src/risk/consistency_tracker.py`

**Requirements**:
1. **Total profit tracking**: Cumulative P&L since account start
2. **Daily profit tracking**: Reset at midnight ET
3. **30% limit enforcement**: Block trades if `daily_profit > 0.30 * total_profit`
4. **Action on violation**: Block new trades (don't close existing)
5. **Logging**: Log when approaching limit (20%, 25%, 30%)

**Implementation skeleton**:
```python
from decimal import Decimal
from datetime import datetime
from zoneinfo import ZoneInfo

class ConsistencyTracker:
    """Enforces Apex 30% daily profit consistency rule."""
    
    def __init__(self, initial_balance: Decimal):
        self.initial_balance = initial_balance
        self.total_profit = Decimal("0")
        self.daily_profit = Decimal("0")
        self.consistency_limit = Decimal("0.30")  # 30%
        self.et_tz = ZoneInfo("America/New_York")
        self._limit_hit = False
    
    def update_profit(self, trade_pnl: Decimal):
        """Update profit tracking after trade closes."""
        self.total_profit += trade_pnl
        self.daily_profit += trade_pnl
        
        # Check consistency
        if self.total_profit > 0:  # Only check if in profit
            daily_pct = self.daily_profit / self.total_profit
            
            if daily_pct >= self.consistency_limit:
                self._limit_hit = True
                # Log critical violation
            elif daily_pct >= Decimal("0.25"):
                # Log warning - approaching limit
                pass
    
    def can_trade(self) -> bool:
        """Check if consistency rule allows trading."""
        return not self._limit_hit
    
    def reset_daily(self):
        """Reset daily profit at midnight ET."""
        self.daily_profit = Decimal("0")
        self._limit_hit = False
    
    def get_daily_profit_pct(self) -> Decimal:
        """Calculate daily profit as % of total profit."""
        if self.total_profit <= 0:
            return Decimal("0")
        return (self.daily_profit / self.total_profit) * 100
```

**Integration points**:
- Add to `prop_firm_manager.py`:
  ```python
  self.consistency_tracker = ConsistencyTracker(initial_balance)
  
  def on_position_closed(self, position):
      pnl = position.realized_pnl
      self.consistency_tracker.update_profit(pnl)
  
  def can_trade(self) -> bool:
      return (
          self.check_drawdown() and
          self.consistency_tracker.can_trade()
      )
  ```

**Testing requirements**:\n- [ ] Unit test: 30% limit correctly calculated\n- [ ] Unit test: Blocks trades when limit hit\n- [ ] Unit test: Daily reset works\n- [ ] Integration test: Strategy respects consistency rule\n**Status (2025-12-07):** Implemented in code; tests pending.

---

#### Bug #10: Circuit Breaker Integration (0.5 day - FORGE)

**Existing module**: `circuit_breaker.py` (520 lines, fully implemented but NOT used)

**Requirements**:
1. **Import in strategy**: Add to `gold_scalper_strategy.py`
2. **Initialize in __init__**: Create instance with config
3. **Check before orders**: Call `circuit_breaker.can_trade()` before every order
4. **Update after events**: Call `circuit_breaker.update()` after fills/losses
5. **Hook 6 levels**:
   - Level 1: First loss → reduce size 50%
   - Level 2: Two losses → reduce size 75%
   - Level 3: Three losses → skip next trade
   - Level 4: DD > 8% → reduce size 90%
   - Level 5: Win rate < 40% → skip trades
   - Level 6: Emergency halt

**Implementation changes**:
```python
# In gold_scalper_strategy.py

from nautilus_gold_scalper.src.risk.circuit_breaker import CircuitBreaker

class GoldScalperStrategy(Strategy):
    def __init__(self, config):
        # ... existing code ...
        self.circuit_breaker = CircuitBreaker(
            max_consecutive_losses=3,
            dd_threshold_pct=8.0,
            min_win_rate_pct=40.0
        )
    
    def on_bar(self, bar: Bar):
        # Check circuit breaker BEFORE trade logic
        if not self.circuit_breaker.can_trade():
            self.log.warning(f"Circuit breaker ACTIVE: Level {self.circuit_breaker.current_level}")
            return
        
        # ... existing trade logic ...
    
    def on_position_closed(self, position: Position):
        # Update circuit breaker state
        self.circuit_breaker.update_trade(
            was_winner=position.realized_pnl > 0,
            pnl=position.realized_pnl
        )
```

**Testing requirements**:\n- [ ] Integration test: Circuit breaker triggers at each level\n- [ ] Integration test: Strategy respects can_trade() response\n- [ ] Integration test: Size reduction applied correctly\n**Status (2025-12-07):** Integrated into strategy (pre-trade guard, equity feed, size multiplier, trade result feed); tests pending.

---

#### Bug #11: Strengthen Termination Logic (0.25 day - SENTINEL)

**File**: `prop_firm_manager.py`

**Current issue**: When DD breached, blocks trades but doesn't STOP strategy

**Fix**:
```python
# In prop_firm_manager.py

def check_drawdown(self) -> bool:
    """Check if trailing DD limit breached."""
    current_dd = self.get_current_drawdown_pct()
    
    if current_dd >= self.dd_limit_pct:
        self.log.critical(
            f"APEX TRAILING DD BREACH: {current_dd:.2f}% >= {self.dd_limit_pct:.2f}%"
        )
        
        # CRITICAL: Not just block trades - TERMINATE strategy
        self.strategy.stop()  # Stop strategy execution
        self.strategy.flatten_all_positions()  # Emergency flatten
        
        # Optionally: raise exception to halt backtest/live
        raise RuntimeError(f"Apex DD limit breached: {current_dd:.2f}%")
    
    return True
```

**Testing requirements**:\n- [ ] Unit test: Strategy stops on DD breach\n- [ ] Integration test: Backtest halts on breach (doesn't continue)\n**Status (2025-12-07):** PropFirmManager now stops strategy + flattens positions when breach detected; uses mark-to-market equity.

---

#### Bug #12: Verify Unrealized P&L in DD Calculation (0.5 day - SENTINEL)

**File**: `prop_firm_manager.py`

**Requirement**: Apex includes UNREALIZED P&L in DD calculation (unlike FTMO)

**Verification needed**:
```python
# In prop_firm_manager.py

def get_current_equity(self) -> Decimal:
    """Get current equity INCLUDING unrealized P&L."""
    balance = self.strategy.portfolio.balance_total(self.currency)
    
    # CRITICAL: Must include unrealized P&L
    unrealized_pnl = Decimal("0")
    for position in self.strategy.cache.positions_open():
        unrealized_pnl += position.unrealized_pnl(bar.close)  # Current mark
    
    current_equity = balance + unrealized_pnl
    
    # Update HWM if equity increased
    if current_equity > self.hwm:
        self.hwm = current_equity
        self.log.info(f"New HWM: ${self.hwm:.2f}")
    
    return current_equity

def get_current_drawdown_pct(self) -> Decimal:
    """Calculate trailing DD from HWM."""
    current_equity = self.get_current_equity()  # Includes unrealized
    dd_pct = ((self.hwm - current_equity) / self.hwm) * 100
    return dd_pct
```

**Testing requirements**:
- [ ] Unit test: Unrealized P&L included in equity calc
- [ ] Unit test: HWM updates with unrealized gains
- [ ] Unit test: DD calculated correctly with open positions

---

### 🟡 PHASE 2: BACKTEST REALISM (2 days)

#### Bug #4: Daily Reset Hook (0.5 day - SENTINEL)

**Files**: `prop_firm_manager.py`, `base_strategy.py`, `consistency_tracker.py`, `time_constraint_manager.py`

**Requirement**: Reset daily counters at midnight ET

**Implementation**:
```python
# In base_strategy.py

def on_start(self):
    """Start strategy with daily reset scheduler."""
    # ... existing code ...
    
    # Schedule daily reset at midnight ET
    self.clock.set_timer(
        name="daily_reset",
        interval=timedelta(hours=24),
        callback=self.on_new_day
    )

def on_new_day(self, event):
    """Reset daily counters at midnight ET."""
    self.log.info("=== NEW TRADING DAY - Resetting daily counters ===")
    
    # Reset PropFirmManager daily counters
    if hasattr(self, 'prop_firm_manager'):
        self.prop_firm_manager.reset_daily()
    
    # Reset ConsistencyTracker
    if hasattr(self, 'consistency_tracker'):
        self.consistency_tracker.reset_daily()
    
    # Reset TimeConstraintManager warnings
    if hasattr(self, 'time_manager'):
        self.time_manager.reset_daily()
    
    # Reset CircuitBreaker daily metrics (if applicable)
    if hasattr(self, 'circuit_breaker'):
        self.circuit_breaker.reset_daily_metrics()
```

**PropFirmManager changes**:
```python
# In prop_firm_manager.py

def reset_daily(self):
    """Reset daily drawdown counter (if tracking daily DD)."""
    self.daily_losses = Decimal("0")
    self.log.debug("Daily DD counter reset")
```

**Testing requirements**:
- [ ] Unit test: Daily reset triggers at midnight ET
- [ ] Integration test: Counters actually reset in backtest
- [ ] Integration test: Multi-day backtest resets correctly

---

#### Bug #5: Enable Slippage & Commission (0.5 day - FORGE)

**Files**: `trade_manager.py`, backtest config

**Current issue**: Config has `slippage=0`, `commission=0` but code doesn't use them

**Requirements**:
1. **Slippage modeling**: 5-15 cents for XAUUSD (volatility-adjusted)
2. **Commission modeling**: Per contract/lot (configurable)
3. **Integration**: Apply on EVERY fill

**Implementation**:
```python
# In trade_manager.py or execution layer

class ExecutionModel:
    """Realistic execution with slippage and commission."""
    
    def __init__(self, config):
        self.base_slippage = Decimal("0.10")  # 10 cents XAUUSD
        self.volatility_multiplier = Decimal("1.5")
        self.commission_per_lot = Decimal("5.00")  # $5/lot
    
    def apply_slippage(self, order, current_price: Decimal, atr: Decimal) -> Decimal:
        """Apply volatility-adjusted slippage."""
        # Higher slippage in high volatility
        volatility_factor = atr / Decimal("30.0")  # Normalize by typical ATR
        slippage = self.base_slippage * volatility_factor * self.volatility_multiplier
        
        # Direction matters
        if order.side == OrderSide.BUY:
            fill_price = current_price + slippage  # Worse fill
        else:
            fill_price = current_price - slippage  # Worse fill
        
        return fill_price
    
    def calculate_commission(self, quantity: Decimal) -> Decimal:
        """Calculate commission based on lot size."""
        return self.commission_per_lot * quantity
```

**Backtest config changes**:
```yaml
# In configs/backtest_config.yaml

execution:
  slippage:
    enabled: true
    base_cents: 10  # 10 cents XAUUSD
    volatility_adjusted: true
    multiplier: 1.5
  
  commission:
    enabled: true
    per_lot: 5.0  # $5 per lot
    currency: USD
```

**Testing requirements**:
- [ ] Unit test: Slippage calculation correct
- [ ] Unit test: Commission calculation correct
- [ ] Integration test: Backtest applies slippage+commission on every fill
- [ ] Validation: Compare backtest results with/without costs (should be worse with costs)

---

#### Bug #6: Position Sizer Unit Conversion (0.5 day - FORGE)

**File**: `position_sizer.py`

**Current issue**: Receives price units ($1850.50) instead of pips/points

**Requirements**:
1. **Convert price to pips**: For XAUUSD, 1 pip = $0.01, 1 point = $0.10
2. **Risk calculation**: `risk_amount = balance * risk_pct`
3. **Lot size**: `lots = risk_amount / (stop_loss_pips * pip_value * lot_size)`

**Implementation fix**:
```python
# In position_sizer.py

def calculate_position_size(
    self,
    balance: Decimal,
    risk_pct: Decimal,
    entry_price: Decimal,
    stop_loss_price: Decimal,
    instrument: Instrument
) -> Decimal:
    """Calculate position size in lots."""
    
    # Convert price difference to pips
    price_diff = abs(entry_price - stop_loss_price)
    
    # XAUUSD: 1 pip = $0.01, 1 point = $0.10
    if instrument.symbol == "XAUUSD":
        stop_loss_pips = price_diff / Decimal("0.10")  # Points
    else:
        # Generic: use pip_size from instrument
        stop_loss_pips = price_diff / instrument.price_increment
    
    # Risk amount in dollars
    risk_amount = balance * risk_pct
    
    # Lot size calculation
    # For XAUUSD: 1 lot = 100 oz, pip_value = $10/pip
    pip_value = instrument.pip_value or Decimal("10.0")
    lot_size = instrument.lot_size or Decimal("100.0")
    
    lots = risk_amount / (stop_loss_pips * pip_value / lot_size)
    
    # Round to valid lot increment
    lots = self._round_to_increment(lots, instrument.size_increment)
    
    self.log.debug(
        f"Position sizing: balance=${balance}, risk={risk_pct*100}%, "
        f"stop_pips={stop_loss_pips}, lots={lots}"
    )
    
    return lots
```

**Testing requirements**:
- [ ] Unit test: XAUUSD pip conversion correct
- [ ] Unit test: Lot size calculation correct
- [ ] Unit test: Edge cases (zero stop, huge stop, tiny balance)
- [ ] Integration test: Backtest positions are reasonable size

---

#### Bug #7: Threshold Alignment (0.5 day - FORGE)

**Files**: Multiple (strategy, backtest runners)

**Current issue**: Inconsistent execution thresholds (70 vs 65 vs 50)

**Requirements**:
1. **Single source of truth**: Config file defines threshold
2. **Consistent usage**: All modules read from config
3. **MQL5 alignment**: Use 70 (matches MQL5)

**Implementation**:
```yaml
# In configs/strategy_config.yaml

confluence:
  execution_threshold: 70  # SINGLE SOURCE OF TRUTH (matches MQL5)
  min_score: 70           # Also set here for consistency
```

```python
# In gold_scalper_strategy.py

def __init__(self, config):
    # ... existing code ...
    
    # Read from config (not hardcoded)
    self.execution_threshold = config.get("confluence.execution_threshold", 70)
    
    # Remove hardcoded values like 65, 50
```

```python
# In backtest runners (nautilus_backtest.py, etc.)

# Ensure all scripts use same config
strategy_config = load_config("configs/strategy_config.yaml")
# Pass to strategy initialization
```

**Files to update**:
- [ ] `gold_scalper_strategy.py`: Change 65 → config read
- [ ] `nautilus_backtest.py`: Remove hardcoded 50 → use config
- [ ] `batch_backtest.py`: Remove hardcoded thresholds → use config
- [ ] `confluence_scorer.py`: Read `min_score` from config (Bug #2)

**Testing requirements**:
- [ ] Unit test: All modules read threshold from config
- [ ] Integration test: Changing config changes strategy behavior
- [ ] Validation: Re-run backtest with threshold=70, confirm different results

---

### 🟢 PHASE 3: CODE CORRECTNESS (2.5 days)

#### Bug #1: Threshold 65 → 70 (0.5 hour - FORGE)

**File**: `gold_scalper_strategy.py`

**Simple fix**:
```python
# Line 67 (approximately)
# OLD:
execution_threshold = 65

# NEW:
execution_threshold = 70  # Match MQL5 reference implementation
```

**Testing**:
- [ ] Re-run import validation
- [ ] Grep for other instances of 65

---

#### Bug #2: Enforce confluence_min_score Config (0.5 hour - FORGE)

**File**: `confluence_scorer.py`

**Current issue**: Config variable defined but never checked

**Fix**:
```python
# In confluence_scorer.py

def calculate_confluence_score(self, signal) -> float:
    # ... existing calculation ...
    
    final_score = # ... calculation result ...
    
    # ENFORCE minimum score from config
    if final_score < self.config.confluence_min_score:
        self.log.debug(
            f"Confluence score {final_score} below minimum {self.config.confluence_min_score}"
        )
        return 0.0  # Reject signal
    
    return final_score
```

**Testing**:
- [ ] Unit test: Signals below min_score rejected
- [ ] Integration test: Fewer signals generated when min_score enforced

---

#### Bug #3: NinjaTrader Adapter Full Implementation (2 days - FORGE)

**File**: `nautilus_gold_scalper/src/execution/ninjatrader_adapter.py` (currently 42-line stub)

**Requirements**:
1. **NinjaTrader 8 API integration**: ATI (Automated Trading Interface)
2. **Order management**: Submit, modify, cancel orders
3. **Position tracking**: Query open positions
4. **Fill notifications**: Receive fill events
5. **Error handling**: Connection loss, order rejects

**Implementation approach**:
```python
# Full implementation ~500-600 lines

import asyncio
import aiohttp
from typing import Optional, Dict
from nautilus_trader.adapters.base import LiveDataClient, LiveExecutionClient
from nautilus_trader.model.orders import Order
from nautilus_trader.model.events import OrderFilled

class NinjaTraderAdapter:
    """
    NinjaTrader 8 ATI integration for live trading.
    
    Supports:
    - Order submission (Market, Limit, Stop)
    - Position tracking
    - Fill notifications
    - Error handling & reconnection
    """
    
    def __init__(self, config: Dict):
        self.base_url = config.get("nt_api_url", "http://localhost:8080")
        self.account = config.get("account_name")
        self.session: Optional[aiohttp.ClientSession] = None
        self._connected = False
    
    async def connect(self):
        """Establish connection to NinjaTrader ATI."""
        self.session = aiohttp.ClientSession()
        # Implementation: Connect to NT8 REST API
        # Check account exists, get initial positions, etc.
    
    async def submit_order(self, order: Order) -> str:
        """Submit order to NinjaTrader."""
        # Implementation: POST /order
        # Convert Nautilus Order to NT8 format
        # Return NT8 order ID
    
    async def cancel_order(self, order_id: str):
        """Cancel existing order."""
        # Implementation: DELETE /order/{order_id}
    
    async def get_positions(self) -> List[Position]:
        """Query current positions from NinjaTrader."""
        # Implementation: GET /positions
    
    async def subscribe_fills(self):
        """Subscribe to fill notifications (WebSocket or polling)."""
        # Implementation: WebSocket connection or polling loop
    
    # ... more methods (~400 more lines) ...
```

**Integration**:
- Add to `configs/execution_config.yaml`:
  ```yaml
  live_execution:
    adapter: ninjatrader
    nt_api_url: "http://localhost:8080"
    account_name: "Sim101"
  ```

**Testing requirements**:
- [ ] Unit test: Order format conversion
- [ ] Integration test: Connect to NT8 simulator
- [ ] Integration test: Submit test order, verify fill
- [ ] Manual test: Run strategy with NT8 paper account

**NOTE**: This is a 2-day task - can be DEFERRED if paper trading not immediate priority.

---

## Execution Strategy

### Multi-Droid Coordination

**Primary agents**:
1. **SENTINEL** (Apex risk expert) - Owns bugs 4, 8, 9, 11, 12
2. **FORGE** (Code architect) - Owns bugs 1, 2, 3, 5, 6, 7, 10

**Coordination approach**:
- SENTINEL creates NEW modules (time_constraint_manager, consistency_tracker)
- FORGE modifies EXISTING modules (strategy, position_sizer, etc.)
- Both work in PARALLEL on Phase 1 & 2
- FORGE handles Phase 3 solo

### Phased Execution

**Phase 1: Apex Compliance** (3-4 days)
```
SENTINEL:
├─ Bug #8: TimeConstraintManager (2 days)
├─ Bug #9: ConsistencyTracker (1 day)
├─ Bug #11: Strengthen termination (0.25 day)
└─ Bug #12: Verify unrealized P&L (0.5 day)

FORGE:
└─ Bug #10: Integrate CircuitBreaker (0.5 day)

PARALLEL execution: SENTINEL bugs 8-9-11-12 while FORGE does bug 10
```

**Phase 2: Backtest Realism** (2 days)
```
SENTINEL:
└─ Bug #4: Daily reset hook (0.5 day)

FORGE:
├─ Bug #5: Slippage/commission (0.5 day)
├─ Bug #6: Position sizer units (0.5 day)
└─ Bug #7: Threshold alignment (0.5 day)

PARALLEL execution: SENTINEL bug 4 while FORGE does bugs 5-6-7
```

**Phase 3: Code Correctness** (2.5 days)
```
FORGE:
├─ Bug #1: Threshold 65→70 (0.5 hour)
├─ Bug #2: Enforce config (0.5 hour)
└─ Bug #3: NinjaTrader adapter (2 days) - OPTIONAL DEFER
```

### Testing After Each Phase

**After Phase 1**:
```bash
# Run Apex compliance tests
pytest nautilus_gold_scalper/tests/risk/ -k "apex or time_constraint or consistency"

# Verify no violations in sample backtest
python nautilus_gold_scalper/scripts/run_backtest.py --days 5 --check-apex
```

**After Phase 2**:
```bash
# Run backtest realism tests
pytest nautilus_gold_scalper/tests/ -k "slippage or commission or reset"

# Compare results with/without costs
python scripts/compare_backtest_realism.py
```

**After Phase 3**:
```bash
# Full validation
pytest nautilus_gold_scalper/tests/

# Re-run audit 003 & 004 to verify fixes
# (manual step - re-execute prompts 003 & 004)
```

---

## Output Specification

### Primary Output

**File**: `.prompts/006-fix-critical-bugs/fix-implementation-report.md`

**Structure**:
```markdown
# Critical Bugs Fix - Implementation Report

<metadata>
<start_date>YYYY-MM-DD</start_date>
<completion_date>YYYY-MM-DD</completion_date>
<total_bugs_fixed>12</total_bugs_fixed>
<phases_completed>3/3</phases_completed>
<total_effort_days>7.5</total_effort_days>
<agents_used>SENTINEL, FORGE</agents_used>
</metadata>

## Executive Summary

[300 words - what was fixed, how, results]

## Phase 1: Apex Compliance - Implementation Log

### Bug #8: Time Constraint Manager
**Status**: ✅ FIXED | ⚠️ PARTIAL | ❌ FAILED
**Agent**: SENTINEL
**Effort**: 2 days actual vs 2 days estimated
**Files created**:
- `nautilus_gold_scalper/src/risk/time_constraint_manager.py` (XXX lines)
**Files modified**:
- `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py` (+XX lines)
**Tests added**:
- `tests/risk/test_time_constraint_manager.py` (XX tests)
**Validation**:
- [x] Unit tests pass
- [x] Integration test: Backtest respects 4:59 PM cutoff
- [x] Edge case: DST transition handled
**Evidence**: [Code snippets showing implementation]

[Repeat for bugs #9, #10, #11, #12]

## Phase 2: Backtest Realism - Implementation Log

[Same structure for bugs #4, #5, #6, #7]

## Phase 3: Code Correctness - Implementation Log

[Same structure for bugs #1, #2, #3]

## Testing Summary

### Unit Tests
- Total: XXX tests added
- Passing: XXX/XXX
- Coverage: XX%

### Integration Tests
- Total: XX tests added
- Passing: XX/XX

### Backtest Validation
**Before fixes**:
| Metric | Value |
|--------|-------|
| Sharpe | X.XX |
| Max DD | X.X% |
| Win Rate | XX% |

**After fixes** (with slippage, Apex rules):
| Metric | Value | Change |
|--------|-------|--------|
| Sharpe | X.XX | -X% (expected - more realistic) |
| Max DD | X.X% | +X% (expected - costs applied) |
| Win Rate | XX% | -X% (expected - stricter threshold) |

**Apex violations**:
- Before: XX violations
- After: 0 violations ✅

## Issues Encountered

### Blockers
1. [Issue + resolution]
2. ...

### Partial Fixes
1. [What couldn't be fully fixed + reason + workaround]

## Code Quality Metrics

- Lines added: XXX
- Lines modified: XXX
- Lines deleted: XXX
- New modules: XX
- Modified modules: XX
- Test coverage: XX% → XX%

## GO/NO-GO Re-Assessment

**Previous status**: ⛔ NO-GO (12 P0 blockers)
**Current status**: ✅ GO | ⚠️ CONDITIONAL | ⛔ NO-GO

**Remaining blockers** (if any):
1. [Blocker + reason]
2. ...

**Conditions for GO** (if conditional):
1. [Condition]
2. ...

**Rationale**: [Why this verdict]

## Next Steps

1. [Concrete action - e.g., "Re-run audit 003 & 004 to verify"]
2. [Action]
3. ...

## Appendix: Files Changed

### New Files (XX files)
```
nautilus_gold_scalper/src/risk/time_constraint_manager.py (XXX lines)
nautilus_gold_scalper/src/risk/consistency_tracker.py (XXX lines)
...
```

### Modified Files (XX files)
```
nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py (+XX -XX lines)
...
```

### Test Files (XX files)
```
tests/risk/test_time_constraint_manager.py (XXX lines)
...
```

<open_questions>
- [What remains uncertain after fixes]
</open_questions>

<assumptions>
- [What was assumed during implementation]
</assumptions>

<dependencies>
- [What's needed next - e.g., "Re-audit to verify all fixes"]
</dependencies>
```

### Secondary Output

**File**: `.prompts/006-fix-critical-bugs/SUMMARY.md`

```markdown
# Critical Bugs Fix - Summary

## One-Liner
[E.g., "Fixed all 12 P0 bugs: Apex compliance (5), backtest realism (4), code correctness (3); system now GO for paper trading"]

## Version
v1 - Complete fixes (2025-12-07 to 2025-12-14)

## Key Achievements
• [Achievement 1 - e.g., "Time constraints enforced: 4:59 PM ET cutoff operational"]
• [Achievement 2 - e.g., "Consistency rule: 30% limit tracked and enforced"]
• [Achievement 3 - e.g., "Backtest realism: slippage/commission applied, results 15% worse (expected)"]
• [Total effort: X.X days actual vs 7.5 days estimated]

## Decisions Needed
- [E.g., "Approve paper trading deployment?"]
- [E.g., "Defer NinjaTrader adapter to Phase 2?"]

## Blockers
- [E.g., "NinjaTrader adapter incomplete (deferred)" if applicable]

## Next Step
[E.g., "Re-run audits 003 & 004 to verify all P0s resolved"]
```

---

## Droid Assignment & Coordination

### Primary Execution

**Invoke BOTH droids in PARALLEL** (for Phase 1 & 2):

```python
# Option A: Sequential within phases (safer)
Task(
  subagent_type="sentinel-apex-guardian",
  description="Fix Apex compliance bugs",
  prompt="[Phase 1 SENTINEL section of this prompt]"
)
# After SENTINEL done:
Task(
  subagent_type="forge-code-architect",
  description="Fix code bugs",
  prompt="[Phase 1 FORGE + Phase 2 + Phase 3 sections]"
)

# Option B: True parallel (faster but riskier)
# Launch both at once, they coordinate via git
Task(subagent_type="sentinel-apex-guardian", ...) # Parallel
Task(subagent_type="forge-code-architect", ...)   # Parallel
```

### Orchestration Approach

**Recommended**: Sequential phases with parallel work within phases

```
PHASE 1 START:
  ├─ SENTINEL: bugs 8, 9, 11, 12 (parallel worker 1)
  └─ FORGE: bug 10              (parallel worker 2)
  WAIT for BOTH to complete
  RUN Phase 1 tests

PHASE 2 START:
  ├─ SENTINEL: bug 4 (parallel worker 1)
  └─ FORGE: bugs 5, 6, 7 (parallel worker 2)
  WAIT for BOTH to complete
  RUN Phase 2 tests

PHASE 3 START:
  └─ FORGE: bugs 1, 2, 3 (solo)
  RUN Phase 3 tests

GENERATE REPORT
```

---

## Success Criteria

### Implementation Quality
- [ ] All 12 bugs have code fixes (not just TODO comments)
- [ ] Each fix has unit tests (min 2 tests per bug)
- [ ] Integration tests cover Apex rules end-to-end
- [ ] Backtest runs successfully with all fixes applied
- [ ] No new bugs introduced (regression tests pass)

### Apex Compliance
- [ ] Time constraints: 4:59 PM ET enforced (zero violations)
- [ ] Consistency rule: 30% limit tracked (zero violations)
- [ ] Circuit breaker: Integrated and functional
- [ ] Trailing DD: Strong termination on breach
- [ ] Unrealized P&L: Verified in DD calculation

### Backtest Realism
- [ ] Slippage applied on every fill
- [ ] Commission applied on every fill
- [ ] Daily reset works across multi-day backtests
- [ ] Position sizing uses correct units (pips, not price)
- [ ] Threshold consistent across all modules (70)

### Code Correctness
- [ ] Threshold 70 everywhere (no 65 or 50)
- [ ] Config variables actually used
- [ ] NinjaTrader adapter functional (if not deferred)

### Documentation
- [ ] Implementation report complete with evidence
- [ ] SUMMARY.md has substantive achievements
- [ ] All files changed are documented
- [ ] Next steps are clear and actionable

---

## Tools to Use

**Essential**:
- `Read` - Read existing modules before modifying
- `Edit` - Modify existing files
- `Create` - Create new modules (time_constraint_manager, consistency_tracker)
- `Execute` - Run tests after each fix
- `Grep` - Search for patterns (threshold values, TODO comments)
- `calculator` - Verify DD/sizing math

**Testing**:
```bash
# Unit tests
pytest nautilus_gold_scalper/tests/ -v

# Integration tests (specific)
pytest nautilus_gold_scalper/tests/risk/test_time_constraint_manager.py -v

# Run backtest
python nautilus_gold_scalper/scripts/run_backtest.py --days 30

# Compare results
python scripts/compare_before_after_fixes.py
```

**Git workflow**:
```bash
# Create feature branch
git checkout -b fix/critical-p0-bugs

# Commit after each phase
git add ...
git commit -m "feat: Phase 1 - Apex compliance (bugs 8-12)"

# After all done
git push origin fix/critical-p0-bugs
```

---

## Intelligence Rules

**Depth**: This is comprehensive work - take time to implement correctly, not quickly.

**Testing**: Test EACH bug fix immediately after implementation (don't batch).

**Parallelism**: Use parallel tool calls when possible (Read multiple files, run multiple tests).

**Evidence**: Every "FIXED" status needs code evidence (file:line reference).

**Incremental**: Commit after each phase, not at the end.

---

## Notes

- **Estimated total effort**: 7-8 days (if working full-time)
- **Critical path**: Apex compliance → Backtest realism → Code fixes
- **Optional defer**: Bug #3 (NinjaTrader adapter) can be done later if paper trading not immediate
- **Re-audit after**: Must re-run audits 003 & 004 to verify all fixes
- **User expectation**: "extremamente complexo" - this prompt delivers comprehensive, production-ready fixes

---

## FINAL CHECKPOINT

Before execution, confirm:
- [ ] All 4 audit reports reviewed
- [ ] Understanding of each bug clear
- [ ] Testing strategy defined
- [ ] Git workflow planned
- [ ] Estimated timeline acceptable (7-8 days)
- [ ] Agents assigned (SENTINEL + FORGE)

**Ready to proceed?** Execute this prompt to fix all 12 P0 bugs and achieve GO status for Apex trading.

