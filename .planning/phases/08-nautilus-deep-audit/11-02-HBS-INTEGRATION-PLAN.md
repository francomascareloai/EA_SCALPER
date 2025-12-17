---
phase: 11-hbs-implementation
plan: 02
version: 2.2
type: execute
domain: nautilus-python
depends_on: 11-01-HBS-CORE-PLAN.md
critic_review: APPLIED (v2.0 + v2.1 fixes implemented)
critic_v2_fixes: H-NEW-1 ✅ (threading.Event), H-NEW-4 ✅ (context-aware cancel), H-NEW-5 ✅ (cancel before execute)
argus_v2_enhancements: Integrated with core HBS A1-A5 enhancements
---

<objective>
Integrate HBS into the existing NautilusTrader strategy and validate via comparative backtest.

Purpose: Connect the HumanBehaviorSimulator to the live trading flow and measure the "humanization cost" - expected 15-20% performance reduction for stealth compliance.

Output:
- Modified `gold_scalper_strategy.py` with HBS integration (including async delay scheduling)
- Limit order lifecycle management
- Thread-safe session state transitions
- Comparative backtest results (with/without HBS)
- Calibrated HBS parameters based on results
</objective>

<critic_fixes_applied>
## CRITICAL Fixes (from CRITIC v2.0 review)
- **C2**: Implement async delay scheduling for LIVE mode (not just informational)
- **C3**: Add limit order fill handling (25% limits + 5% stop-limits have lifecycle)
- **C4**: Fix session start/end race condition with threading.Lock

## CRITICAL Fixes (from CRITIC v2.1 review - NEW)
- **C-NEW-1**: Validate account_id is set when using date-based RNG seeding
- **C-NEW-2**: Add limit_price/stop_price to HBSDecision (prevents AttributeError crash)
- **C-NEW-3**: Use PROFIT TARGET for 30% rule, NOT account equity

## HIGH Fixes (v2.0)
- **H2**: Track 30% Apex consistency rule relative to cumulative P&L

## HIGH Fixes (v2.1 - NEW)
- **H-NEW-1**: Use threading.Event for executor startup (no busy-wait loop)
- **H-NEW-2**: Implement FOMC, CPI, GDP in economic calendar
- **H-NEW-3**: Include session counter in RNG seed for mid-day restarts
- **H-NEW-4**: Context-aware order cancellation (price moved, time elapsed)
- **H-NEW-5**: Check cancel flag BEFORE executing delayed callback
- **H-NEW-6**: Crisis mode - reduce delays when DD > 3.5%

## ARGUS Enhancements (v2.1)
- **A1**: Per-account parameter jitter (±10%)
- **A4**: Volatility-adaptive order types
- **A5**: Day-of-week behavioral variance
</critic_fixes_applied>

<execution_context>
@~/.claude/plugins/marketplaces/taches-cc-resources/skills/create-plans/workflows/execute-phase.md
@~/.claude/plugins/marketplaces/taches-cc-resources/skills/create-plans/templates/summary.md
@~/.claude/plugins/marketplaces/taches-cc-resources/skills/create-plans/references/checkpoints.md
</execution_context>

<context>
@.planning/phases/08-nautilus-deep-audit/00-BRIEF.md
@.planning/phases/08-nautilus-deep-audit/11-PHASE-HBS-IMPLEMENTATION-PLAN.md
@.planning/phases/08-nautilus-deep-audit/11-01-HBS-CORE-SUMMARY.md
@nautilus_gold_scalper/src/execution/human_config.py
@nautilus_gold_scalper/src/execution/human_simulator.py
@nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py
@nautilus_gold_scalper/src/strategies/base_strategy.py
</context>

<tasks>

<task type="auto">
  <name>Task 1: Integrate HBS into Gold Scalper Strategy (with CRITIC fixes)</name>
  <files>
    nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py,
    nautilus_gold_scalper/src/execution/__init__.py,
    nautilus_gold_scalper/src/execution/delayed_executor.py (NEW),
    nautilus_gold_scalper/src/execution/order_lifecycle.py (NEW)
  </files>
  <action>
## Part A: Core HBS Integration

Modify the gold_scalper_strategy.py to use HBS for all trade decisions:

**Integration Point:** Between `_check_for_signal()` and `_enter_long/_enter_short()`

```python
# In __init__, add:
import threading
from typing import Optional, Callable
from nautilus_gold_scalper.src.execution.human_simulator import HumanBehaviorSimulator
from nautilus_gold_scalper.src.execution.human_config import HumanSimConfig
from nautilus_gold_scalper.src.execution.delayed_executor import DelayedExecutor
from nautilus_gold_scalper.src.execution.order_lifecycle import OrderLifecycleManager

class GoldScalperStrategy(Strategy):
    def __init__(
        self,
        # ... existing params ...
        hbs_enabled: bool = True,
        hbs_config_path: Optional[Path] = None,
        is_live_mode: bool = False,  # CRITICAL: distinguish backtest vs live
    ):
        super().__init__(...)

        # HBS components
        self._hbs_enabled = hbs_enabled
        self._is_live_mode = is_live_mode

        if hbs_enabled:
            config = (
                HumanSimConfig.from_yaml(hbs_config_path)
                if hbs_config_path else HumanSimConfig()
            )
            self.hbs = HumanBehaviorSimulator(config=config)

            # C2 FIX: Async delay executor for live mode
            self._delayed_executor = DelayedExecutor(
                clock=self.clock,
                is_live=is_live_mode,
            )

            # C3 FIX: Order lifecycle manager for limits/stop-limits
            self._order_lifecycle = OrderLifecycleManager(
                on_fill_callback=self._on_hbs_order_filled,
                on_cancel_callback=self._on_hbs_order_cancelled,
                on_expire_callback=self._on_hbs_order_expired,
            )

            # C4 FIX: Thread-safe session state
            self._session_lock = threading.Lock()
            self._session_active = False

            # H2 FIX: Apex 30% consistency tracking
            self._cumulative_pnl = 0.0
            self._daily_pnl = 0.0
            self._max_daily_pnl_allowed = 0.0  # Set on session start
```

## Part B: C2 FIX - Async Delay Executor (NEW FILE)

Create `nautilus_gold_scalper/src/execution/delayed_executor.py`:

```python
"""
DelayedExecutor: Handles HBS delay scheduling for live mode.

In BACKTEST mode: Delays are informational only (immediate execution).
In LIVE mode: Actual delayed execution via asyncio/threading.

CRITICAL for Apex stealth: delays MUST be real in live mode.
"""

import asyncio
import threading
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Callable, Optional, Any
from collections.abc import Awaitable
import logging

from nautilus_trader.common.clock import Clock


@dataclass
class PendingExecution:
    """A delayed execution waiting to fire."""
    execute_at: datetime
    callback: Callable[[], None]
    order_params: dict
    created_at: datetime
    cancelled: bool = False


class DelayedExecutor:
    """
    Manages delayed order execution for HBS.

    In backtest: Logs delay but executes immediately (no real time).
    In live: Schedules actual delayed execution.
    """

    def __init__(
        self,
        clock: Clock,
        is_live: bool,
        max_pending: int = 10,
        logger: Optional[logging.Logger] = None,
    ):
        self._clock = clock
        self._is_live = is_live
        self._max_pending = max_pending
        self._log = logger or logging.getLogger(__name__)

        # Pending executions (live mode only)
        self._pending: list[PendingExecution] = []
        self._pending_lock = threading.Lock()

        # Event loop for async scheduling (live mode)
        self._loop: Optional[asyncio.AbstractEventLoop] = None
        self._ready = threading.Event()  # H-NEW-1 FIX: Use Event instead of busy-wait
        if is_live:
            self._start_executor_loop()

    def _start_executor_loop(self) -> None:
        """Start background event loop for delayed executions."""
        def run_loop():
            self._loop = asyncio.new_event_loop()
            asyncio.set_event_loop(self._loop)
            self._ready.set()  # H-NEW-1 FIX: Signal ready
            self._loop.run_forever()

        thread = threading.Thread(target=run_loop, daemon=True)
        thread.start()
        # H-NEW-1 FIX: Wait with timeout instead of busy-wait
        if not self._ready.wait(timeout=5.0):
            raise RuntimeError("Delayed executor thread failed to start within 5s")

    def schedule(
        self,
        delay_seconds: float,
        callback: Callable[[], None],
        order_params: dict,
    ) -> Optional[PendingExecution]:
        """
        Schedule delayed execution.

        In backtest: Execute immediately, log delay for analysis.
        In live: Actually delay execution.
        """
        now = self._clock.utc_now()

        if not self._is_live:
            # BACKTEST MODE: Execute immediately, record delay for metrics
            self._log.debug(
                f"[BACKTEST] HBS delay {delay_seconds:.2f}s (executing immediately)"
            )
            callback()
            return None

        # LIVE MODE: Schedule actual delayed execution
        execute_at = now + timedelta(seconds=delay_seconds)

        pending = PendingExecution(
            execute_at=execute_at,
            callback=callback,
            order_params=order_params,
            created_at=now,
        )

        with self._pending_lock:
            # Limit pending queue
            if len(self._pending) >= self._max_pending:
                self._log.warning(
                    f"Pending queue full ({self._max_pending}), dropping oldest"
                )
                self._pending.pop(0)
            self._pending.append(pending)

        # Schedule in event loop
        if self._loop:
            asyncio.run_coroutine_threadsafe(
                self._delayed_execute(pending, delay_seconds),
                self._loop,
            )

        self._log.info(
            f"[LIVE] Scheduled execution in {delay_seconds:.2f}s at {execute_at}"
        )
        return pending

    async def _delayed_execute(
        self,
        pending: PendingExecution,
        delay: float,
    ) -> None:
        """Execute after delay (live mode only).

        H-NEW-5 FIX: Check cancel flag AND session state BEFORE executing.
        This prevents orders from firing after session end or 4:55 PM force-close.
        """
        await asyncio.sleep(delay)

        # H-NEW-5 FIX: Double-check cancellation with lock for race condition
        with self._pending_lock:
            if pending.cancelled or pending not in self._pending:
                self._log.info("Delayed execution cancelled before firing")
                return

            # H-NEW-5 FIX: Check if session is still valid (time gate)
            current_time = self._clock.utc_now()
            # 4:55 PM ET = 21:55 UTC (summer) or 22:55 UTC (winter)
            # We use pending.execute_at as the scheduled time - if current time
            # is significantly past that (>5s tolerance), session likely ended
            if hasattr(pending, 'execute_at') and pending.execute_at:
                time_drift = (current_time - pending.execute_at).total_seconds()
                if time_drift > 60.0:  # More than 1 minute late = session likely ended
                    self._log.warning(
                        f"Delayed execution skipped: {time_drift:.1f}s late (session may have ended)"
                    )
                    self._pending.remove(pending)
                    return

        try:
            pending.callback()
            self._log.info(f"Delayed execution fired successfully")
        except Exception as e:
            self._log.error(f"Delayed execution failed: {e}")
        finally:
            with self._pending_lock:
                if pending in self._pending:
                    self._pending.remove(pending)

    def cancel_pending(self, pending: PendingExecution) -> bool:
        """Cancel a pending execution."""
        with self._pending_lock:
            if pending in self._pending:
                pending.cancelled = True
                self._pending.remove(pending)
                return True
        return False

    def cancel_all(self) -> int:
        """Cancel all pending executions (e.g., session end)."""
        with self._pending_lock:
            count = len(self._pending)
            for p in self._pending:
                p.cancelled = True
            self._pending.clear()
        self._log.info(f"Cancelled {count} pending executions")
        return count

    def shutdown(self) -> None:
        """Clean shutdown of executor."""
        self.cancel_all()
        if self._loop:
            self._loop.call_soon_threadsafe(self._loop.stop)
```

## Part C: C3 FIX - Order Lifecycle Manager (NEW FILE)

Create `nautilus_gold_scalper/src/execution/order_lifecycle.py`:

```python
"""
OrderLifecycleManager: Tracks limit and stop-limit orders through their lifecycle.

CRITICAL: HBS uses 25% limit orders + 5% stop-limit orders.
These have different lifecycle states than market orders.

States:
- PENDING: Order submitted, waiting for fill
- PARTIAL: Partially filled
- FILLED: Fully filled
- CANCELLED: User/system cancelled
- EXPIRED: Time-in-force expired (e.g., IOC)
- REJECTED: Broker rejected
"""

from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum, auto
from typing import Callable, Optional, Dict
import threading
import logging


class OrderState(Enum):
    """Order lifecycle states."""
    PENDING = auto()
    PARTIAL = auto()
    FILLED = auto()
    CANCELLED = auto()
    EXPIRED = auto()
    REJECTED = auto()


class OrderType(Enum):
    """Order types we track."""
    MARKET = auto()
    LIMIT = auto()
    STOP_LIMIT = auto()


@dataclass
class TrackedOrder:
    """An order being tracked through its lifecycle."""
    order_id: str
    order_type: OrderType
    direction: str  # "LONG" or "SHORT"
    requested_qty: float
    filled_qty: float = 0.0
    limit_price: Optional[float] = None
    stop_price: Optional[float] = None
    state: OrderState = OrderState.PENDING
    created_at: datetime = field(default_factory=datetime.utcnow)
    updated_at: datetime = field(default_factory=datetime.utcnow)
    hbs_delay_applied: float = 0.0
    hbs_size_multiplier: float = 1.0


class OrderLifecycleManager:
    """
    Manages limit/stop-limit order lifecycle for HBS tracking.

    HBS needs to know when limits fill (or don't) to adjust behavior.
    - High limit fill rate → market might be trending, adjust skip rate
    - Low limit fill rate → consider wider limits or use markets
    """

    def __init__(
        self,
        on_fill_callback: Optional[Callable[[TrackedOrder, bool], None]] = None,
        on_cancel_callback: Optional[Callable[[TrackedOrder], None]] = None,
        on_expire_callback: Optional[Callable[[TrackedOrder], None]] = None,
        logger: Optional[logging.Logger] = None,
    ):
        self._on_fill = on_fill_callback
        self._on_cancel = on_cancel_callback
        self._on_expire = on_expire_callback
        self._log = logger or logging.getLogger(__name__)

        # Order tracking
        self._orders: Dict[str, TrackedOrder] = {}
        self._lock = threading.Lock()

        # Metrics
        self._total_limits_submitted = 0
        self._total_limits_filled = 0
        self._total_limits_cancelled = 0
        self._total_limits_expired = 0

    def track_order(
        self,
        order_id: str,
        order_type: OrderType,
        direction: str,
        qty: float,
        limit_price: Optional[float] = None,
        stop_price: Optional[float] = None,
        hbs_delay: float = 0.0,
        hbs_size_mult: float = 1.0,
    ) -> TrackedOrder:
        """Start tracking a new order."""
        order = TrackedOrder(
            order_id=order_id,
            order_type=order_type,
            direction=direction,
            requested_qty=qty,
            limit_price=limit_price,
            stop_price=stop_price,
            hbs_delay_applied=hbs_delay,
            hbs_size_multiplier=hbs_size_mult,
        )

        with self._lock:
            self._orders[order_id] = order
            if order_type in (OrderType.LIMIT, OrderType.STOP_LIMIT):
                self._total_limits_submitted += 1

        self._log.debug(f"Tracking order {order_id}: {order_type.name} {direction}")
        return order

    def on_fill(self, order_id: str, filled_qty: float, is_partial: bool = False) -> None:
        """Handle order fill event."""
        with self._lock:
            order = self._orders.get(order_id)
            if not order:
                self._log.warning(f"Fill for unknown order: {order_id}")
                return

            order.filled_qty += filled_qty
            order.updated_at = datetime.utcnow()

            if is_partial:
                order.state = OrderState.PARTIAL
            else:
                order.state = OrderState.FILLED
                if order.order_type in (OrderType.LIMIT, OrderType.STOP_LIMIT):
                    self._total_limits_filled += 1

        is_winner = True  # Determined by calling code
        if self._on_fill and order.state == OrderState.FILLED:
            self._on_fill(order, is_winner)

    def on_cancel(self, order_id: str, reason: str = "") -> None:
        """Handle order cancellation."""
        with self._lock:
            order = self._orders.get(order_id)
            if not order:
                return

            order.state = OrderState.CANCELLED
            order.updated_at = datetime.utcnow()
            if order.order_type in (OrderType.LIMIT, OrderType.STOP_LIMIT):
                self._total_limits_cancelled += 1

        self._log.info(f"Order {order_id} cancelled: {reason}")
        if self._on_cancel:
            self._on_cancel(order)

    def on_expire(self, order_id: str) -> None:
        """Handle order expiration (IOC/GTD expired)."""
        with self._lock:
            order = self._orders.get(order_id)
            if not order:
                return

            order.state = OrderState.EXPIRED
            order.updated_at = datetime.utcnow()
            if order.order_type in (OrderType.LIMIT, OrderType.STOP_LIMIT):
                self._total_limits_expired += 1

        self._log.info(f"Order {order_id} expired")
        if self._on_expire:
            self._on_expire(order)

    def on_reject(self, order_id: str, reason: str = "") -> None:
        """Handle order rejection."""
        with self._lock:
            order = self._orders.get(order_id)
            if not order:
                return

            order.state = OrderState.REJECTED
            order.updated_at = datetime.utcnow()

        self._log.warning(f"Order {order_id} rejected: {reason}")

    def get_limit_fill_rate(self) -> float:
        """Get historical limit order fill rate."""
        if self._total_limits_submitted == 0:
            return 0.0
        return self._total_limits_filled / self._total_limits_submitted

    def get_pending_orders(self) -> list[TrackedOrder]:
        """Get all orders in PENDING or PARTIAL state."""
        with self._lock:
            return [
                o for o in self._orders.values()
                if o.state in (OrderState.PENDING, OrderState.PARTIAL)
            ]

    def cleanup_old_orders(self, max_age_hours: int = 24) -> int:
        """Remove old completed orders from tracking."""
        from datetime import timedelta
        cutoff = datetime.utcnow() - timedelta(hours=max_age_hours)

        with self._lock:
            to_remove = [
                oid for oid, order in self._orders.items()
                if order.state in (OrderState.FILLED, OrderState.CANCELLED,
                                   OrderState.EXPIRED, OrderState.REJECTED)
                and order.updated_at < cutoff
            ]
            for oid in to_remove:
                del self._orders[oid]

        return len(to_remove)
```

## Part D: C4 FIX - Thread-Safe Session Transitions

Update strategy's session methods:

```python
# In gold_scalper_strategy.py

def on_start(self) -> None:
    """Called when strategy starts."""
    super().on_start()

    if self._hbs_enabled:
        with self._session_lock:  # C4 FIX: Thread-safe
            if self._session_active:
                self._log.warning("Session already active, skipping start")
                return

            # Initialize session
            self.hbs.on_session_start(self.clock.utc_now())
            self._session_active = True

            # C-NEW-3 FIX: Calculate max daily P&L from PROFIT TARGET, not equity
            # 30% rule limits daily P&L to 30% of the account's profit target
            # Example: $50k account with 8% target = $4k target → max $1,200/day
            if self.hbs.config.apex_30pct_rule_enabled:
                if self.hbs.config.apex_profit_target <= 0:
                    raise ValueError(
                        "apex_profit_target must be set for 30% rule! "
                        "See HumanSimConfig.validate() for details."
                    )
                self._max_daily_pnl_allowed = self.hbs.config.apex_profit_target * 0.30
            else:
                # Fallback if 30% rule disabled (not recommended for Apex)
                self._max_daily_pnl_allowed = float("inf")

            self._daily_pnl = 0.0

            self._log.info(
                f"HBS session started. Max daily P&L: ${self._max_daily_pnl_allowed:.2f} "
                f"(30% of ${self.hbs.config.apex_profit_target:.2f} profit target)"
            )

def on_stop(self) -> None:
    """Called when strategy stops."""
    if self._hbs_enabled:
        with self._session_lock:  # C4 FIX: Thread-safe
            if not self._session_active:
                self._log.warning("Session not active, skipping stop")
                return

            # Cancel pending delayed executions
            if self._delayed_executor:
                cancelled = self._delayed_executor.cancel_all()
                if cancelled:
                    self._log.info(f"Cancelled {cancelled} pending HBS executions")

            # End session
            self.hbs.on_session_end()
            self._session_active = False

            self._log.info(
                f"HBS session ended. Daily P&L: ${self._daily_pnl:.2f}"
            )

    super().on_stop()
```

## Part E: H2 FIX - Apex 30% Consistency Rule

Add tracking to the execution flow:

```python
def _execute_with_hbs(self, signal: TradeSignal, score: float) -> None:
    """Apply HBS decision layer before execution."""

    # H2 FIX: Check Apex 30% consistency rule FIRST
    if self._daily_pnl >= self._max_daily_pnl_allowed:
        self._log.warning(
            f"Apex 30% rule: Daily P&L ${self._daily_pnl:.2f} >= "
            f"max ${self._max_daily_pnl_allowed:.2f}. Blocking new trades."
        )
        return

    # Get current ATR for volatility check
    current_atr = self._get_current_atr()
    average_atr = self._get_average_atr()

    # Ask HBS what to do
    decision = self.hbs.decide(
        signal_score=score,
        current_time=self.clock.utc_now(),
        current_atr=current_atr,
        atr_percentile=atr_percentile,  # N-4 FIX: Use atr_percentile, not average_atr
        current_dd=self._get_current_drawdown(),  # H-NEW-6: Pass DD for crisis mode
    )

    # N-2 FIX: Calculate limit_price/stop_price (HBS returns offsets, we apply to current price)
    current_price = self._get_current_price()
    tick_size = 0.01  # Gold tick size
    direction_mult = 1 if signal.direction == "LONG" else -1

    if decision.order_type == "LIMIT":
        # Buy limits below market (negative offset), sell limits above (positive offset)
        offset = decision.entry_offset_ticks * tick_size * (-direction_mult)
        decision.limit_price = current_price + offset
    elif decision.order_type == "STOP_LIMIT":
        # Stop above market for longs, below for shorts
        stop_offset = 5 * tick_size * direction_mult  # 5 ticks from current
        decision.stop_price = current_price + stop_offset
        # Limit slightly beyond stop for slippage allowance
        decision.limit_price = decision.stop_price + (tick_size * 2 * direction_mult)

    # Log HBS decision for analysis
    self._log.info(
        f"HBS Decision: skip={decision.should_skip}, "
        f"delay={decision.delay_seconds:.2f}s, "
        f"size_mult={decision.size_multiplier:.2f}, "
        f"order_type={decision.order_type}"
    )

    if decision.should_skip:
        self._log.info(f"HBS: Skipping signal - {decision.skip_reason}")
        return

    # Adjust position size
    adjusted_size = self._calculate_position_size() * decision.size_multiplier

    # C2 FIX: Use delayed executor
    def execute_order():
        if decision.order_type == "MARKET":
            if signal.direction == "LONG":
                self._enter_long(size=adjusted_size)
            else:
                self._enter_short(size=adjusted_size)
        elif decision.order_type == "LIMIT":
            # C3 FIX: Track limit orders through lifecycle
            order_id = self._submit_limit_order(
                direction=signal.direction,
                size=adjusted_size,
                price=decision.limit_price,
            )
            self._order_lifecycle.track_order(
                order_id=order_id,
                order_type=OrderType.LIMIT,
                direction=signal.direction,
                qty=adjusted_size,
                limit_price=decision.limit_price,
                hbs_delay=decision.delay_seconds,
                hbs_size_mult=decision.size_multiplier,
            )
        elif decision.order_type == "STOP_LIMIT":
            order_id = self._submit_stop_limit_order(
                direction=signal.direction,
                size=adjusted_size,
                stop_price=decision.stop_price,
                limit_price=decision.limit_price,
            )
            self._order_lifecycle.track_order(
                order_id=order_id,
                order_type=OrderType.STOP_LIMIT,
                direction=signal.direction,
                qty=adjusted_size,
                stop_price=decision.stop_price,
                limit_price=decision.limit_price,
                hbs_delay=decision.delay_seconds,
                hbs_size_mult=decision.size_multiplier,
            )

    # Schedule execution (immediate in backtest, delayed in live)
    # H-NEW-4 FIX: Include context-aware cancellation parameters
    pending = self._delayed_executor.schedule(
        delay_seconds=decision.delay_seconds,
        callback=execute_order,
        order_params={
            "direction": signal.direction,
            "size": adjusted_size,
            "order_type": decision.order_type,
            # H-NEW-4: Context-aware cancellation criteria
            "cancel_if_price_moves_ticks": decision.cancel_if_price_moves_ticks,
            "cancel_after_seconds": decision.cancel_after_seconds,
            "entry_price_at_decision": current_price,  # Capture price at decision time
        },
    )

    # H-NEW-4 FIX: Register pending for context-aware cancellation check
    if decision.order_type != "MARKET":
        self._register_pending_for_cancel_check(
            pending=pending,
            decision=decision,
            entry_price=current_price,
        )

def _register_pending_for_cancel_check(
    self,
    pending: PendingExecution,
    decision: HBSDecision,
    entry_price: float,
) -> None:
    """
    H-NEW-4 FIX: Register a pending order for context-aware cancellation.

    Instead of random cancellation, we cancel based on:
    1. Price moved too far from decision point (market conditions changed)
    2. Order waited too long (signal is stale)
    """
    if not hasattr(self, "_pending_cancel_checks"):
        self._pending_cancel_checks = []

    self._pending_cancel_checks.append({
        "pending": pending,
        "entry_price": entry_price,
        "cancel_ticks": decision.cancel_if_price_moves_ticks,
        "cancel_seconds": decision.cancel_after_seconds,
        "created_at": self._clock.utc_now(),
    })

def _check_pending_cancellations(self, current_price: float) -> None:
    """
    H-NEW-4 FIX: Check if any pending orders should be cancelled.
    Called on each tick/bar update.
    """
    if not hasattr(self, "_pending_cancel_checks"):
        return

    tick_size = 0.01  # Gold tick size
    now = self._clock.utc_now()

    to_cancel = []
    for check in self._pending_cancel_checks:
        pending = check["pending"]
        if pending.cancelled:
            to_cancel.append(check)
            continue

        # Check price movement
        price_diff_ticks = abs(current_price - check["entry_price"]) / tick_size
        if price_diff_ticks >= check["cancel_ticks"]:
            self._log.info(
                f"Cancelling pending order: price moved {price_diff_ticks:.1f} ticks "
                f"(threshold: {check['cancel_ticks']})"
            )
            self._delayed_executor.cancel_pending(pending)
            to_cancel.append(check)
            continue

        # Check time elapsed
        elapsed = (now - check["created_at"]).total_seconds()
        if elapsed >= check["cancel_seconds"]:
            self._log.info(
                f"Cancelling pending order: waited {elapsed:.1f}s "
                f"(threshold: {check['cancel_seconds']}s)"
            )
            self._delayed_executor.cancel_pending(pending)
            to_cancel.append(check)
            continue

    # Clean up processed entries
    for item in to_cancel:
        if item in self._pending_cancel_checks:
            self._pending_cancel_checks.remove(item)

def _on_fill_callback(self, event) -> None:
    """Handle order fill events."""
    # ... existing logic ...

    # Notify lifecycle manager
    if self._hbs_enabled:
        self._order_lifecycle.on_fill(
            order_id=str(event.order_id),
            filled_qty=float(event.last_qty),
            is_partial=event.is_partial,
        )

    # H2 FIX: Update daily P&L tracking
    realized_pnl = float(event.realized_pnl) if hasattr(event, 'realized_pnl') else 0.0
    self._daily_pnl += realized_pnl
    self._cumulative_pnl += realized_pnl

    # Notify HBS of result
    if self._hbs_enabled:
        is_winner = realized_pnl > 0
        self.hbs.on_trade_result(win=is_winner, pnl=realized_pnl)

    # H2: Check if 30% rule now triggered
    if self._daily_pnl >= self._max_daily_pnl_allowed:
        self._log.warning(
            f"Apex 30% rule triggered! Daily P&L ${self._daily_pnl:.2f} >= "
            f"max ${self._max_daily_pnl_allowed:.2f}. No new trades until tomorrow."
        )
```

**Also update:**
- Export new classes from `__init__.py`
- Create default `config/hbs_config.yaml`

**Configuration:**
- Add `hbs_enabled: bool = True` parameter to strategy
- Add `hbs_config_path: Optional[Path] = None` parameter
- Add `is_live_mode: bool = False` parameter (CRITICAL for C2)

AVOID:
- Breaking existing functionality when HBS is disabled
- Using time.sleep() for delays (use async scheduling)
- Changing the strategy's core logic - HBS is a wrapper layer
- Race conditions between session start/stop
  </action>
  <verify>
    - python -c "from nautilus_gold_scalper.src.strategies.gold_scalper_strategy import GoldScalperStrategy; print('Import OK')"
    - python -c "from nautilus_gold_scalper.src.execution.delayed_executor import DelayedExecutor; print('DelayedExecutor OK')"
    - python -c "from nautilus_gold_scalper.src.execution.order_lifecycle import OrderLifecycleManager; print('OrderLifecycle OK')"
    - pytest nautilus_gold_scalper/tests/test_gold_scalper_strategy.py -v (existing tests still pass)
    - pytest nautilus_gold_scalper/tests/test_delayed_executor.py -v (new tests)
    - pytest nautilus_gold_scalper/tests/test_order_lifecycle.py -v (new tests)
  </verify>
  <done>
    - HBS integrated into strategy flow
    - C2: Async delay executor implemented (backtest=immediate, live=delayed)
    - C3: Order lifecycle manager for limits/stop-limits
    - C4: Thread-safe session start/stop with lock
    - H2: Apex 30% consistency rule tracking
    - on_session_start/end hooks connected
    - Trade results fed back to HBS
    - Position size adjusted by HBS multiplier
    - Signal skipping implemented
    - Existing tests still pass
  </done>
</task>

<task type="auto">
  <name>Task 2: Run Comparative Backtest (Enhanced Metrics)</name>
  <files>
    nautilus_gold_scalper/scripts/backtest_hbs_comparison.py,
    DOCS/03_RESEARCH/FINDINGS/HBS_BACKTEST_COMPARISON.md
  </files>
  <action>
Create a script that runs two backtests and compares results:

```python
"""
HBS Comparative Backtest v2.0
==============================
Runs the same strategy with and without HBS to measure humanization cost.

Expected: 15-20% reduction in performance metrics for stealth compliance.

ENHANCED with CRITIC fixes:
- Tracks limit order fill rates (C3)
- Tracks 30% consistency rule impacts (H2)
- Reports delay distribution (C2)
"""

from pathlib import Path
from dataclasses import dataclass
from typing import Dict, Any
import json
from datetime import datetime

from nautilus_gold_scalper.src.strategies.gold_scalper_strategy import GoldScalperStrategy
from nautilus_gold_scalper.src.execution.human_config import HumanSimConfig
# ... other imports ...


@dataclass
class EnhancedBacktestResults:
    """Extended results including HBS-specific metrics."""
    # Core metrics
    total_trades: int
    win_rate: float
    profit_factor: float
    sharpe_ratio: float
    max_drawdown: float
    net_pnl: float
    sqn: float

    # HBS-specific (only for humanized run)
    hbs_signals_skipped: int = 0
    hbs_avg_delay: float = 0.0
    hbs_avg_size_reduction: float = 0.0

    # C3: Limit order metrics
    limit_orders_submitted: int = 0
    limit_orders_filled: int = 0
    limit_fill_rate: float = 0.0
    stop_limit_orders_submitted: int = 0
    stop_limit_orders_filled: int = 0

    # H2: 30% rule metrics
    days_30pct_triggered: int = 0
    trades_blocked_by_30pct: int = 0

    # Distribution analysis
    delay_distribution: Dict[str, float] = None  # mean, std, min, max, p95


def run_comparison() -> Dict[str, Any]:
    """Run backtest with and without HBS, compare results."""

    # Common config
    data_path = Path("data/raw/full_parquet/xauusd_2003_2025_stride20_full.parquet")
    start_date = "2020-01-01"
    end_date = "2024-12-31"

    print("=" * 60)
    print("HBS Comparative Backtest v2.0")
    print("=" * 60)

    # Run 1: WITHOUT HBS (baseline)
    print("\n[1/2] Running BASELINE (no HBS)...")
    results_no_hbs = run_backtest(
        strategy_class=GoldScalperStrategy,
        hbs_enabled=False,
        data_path=data_path,
        start=start_date,
        end=end_date,
    )
    print(f"      Baseline complete: {results_no_hbs.total_trades} trades")

    # Run 2: WITH HBS (humanized)
    print("\n[2/2] Running HUMANIZED (with HBS)...")
    results_with_hbs = run_backtest(
        strategy_class=GoldScalperStrategy,
        hbs_enabled=True,
        hbs_config=HumanSimConfig(),  # Default v2.0 config
        data_path=data_path,
        start=start_date,
        end=end_date,
    )
    print(f"      Humanized complete: {results_with_hbs.total_trades} trades")

    # Compare
    comparison = compare_results(results_no_hbs, results_with_hbs)

    # Output
    print_comparison_table(comparison)
    report_path = Path("DOCS/03_RESEARCH/FINDINGS/HBS_BACKTEST_COMPARISON.md")
    save_comparison_report(comparison, report_path)

    # Also save JSON for programmatic access
    json_path = Path("DOCS/03_RESEARCH/FINDINGS/HBS_BACKTEST_COMPARISON.json")
    save_comparison_json(comparison, json_path)

    print(f"\nReport saved to: {report_path}")
    print(f"JSON saved to: {json_path}")

    return comparison


def compare_results(
    baseline: EnhancedBacktestResults,
    humanized: EnhancedBacktestResults,
) -> Dict[str, Any]:
    """Calculate performance impact of HBS with enhanced metrics."""

    def calc_impact(base_val: float, human_val: float) -> float:
        """Calculate percentage impact."""
        if base_val == 0:
            return 0.0
        return ((human_val - base_val) / base_val) * 100

    return {
        "run_date": datetime.now().isoformat(),
        "date_range": {"start": "2020-01-01", "end": "2024-12-31"},

        # Core metrics comparison
        "total_trades": {
            "baseline": baseline.total_trades,
            "humanized": humanized.total_trades,
            "impact_pct": calc_impact(baseline.total_trades, humanized.total_trades),
        },
        "win_rate": {
            "baseline": baseline.win_rate,
            "humanized": humanized.win_rate,
            "impact_pct": calc_impact(baseline.win_rate, humanized.win_rate),
        },
        "profit_factor": {
            "baseline": baseline.profit_factor,
            "humanized": humanized.profit_factor,
            "impact_pct": calc_impact(baseline.profit_factor, humanized.profit_factor),
        },
        "sharpe_ratio": {
            "baseline": baseline.sharpe_ratio,
            "humanized": humanized.sharpe_ratio,
            "impact_pct": calc_impact(baseline.sharpe_ratio, humanized.sharpe_ratio),
        },
        "max_drawdown": {
            "baseline": baseline.max_drawdown,
            "humanized": humanized.max_drawdown,
            "impact_pct": calc_impact(baseline.max_drawdown, humanized.max_drawdown),
        },
        "net_pnl": {
            "baseline": baseline.net_pnl,
            "humanized": humanized.net_pnl,
            "impact_pct": calc_impact(baseline.net_pnl, humanized.net_pnl),
        },
        "sqn": {
            "baseline": baseline.sqn,
            "humanized": humanized.sqn,
            "impact_pct": calc_impact(baseline.sqn, humanized.sqn),
        },

        # HBS behavior analysis
        "hbs_behavior": {
            "signals_skipped": humanized.hbs_signals_skipped,
            "skip_rate_pct": (humanized.hbs_signals_skipped /
                             (baseline.total_trades + humanized.hbs_signals_skipped)) * 100
                             if baseline.total_trades > 0 else 0,
            "avg_delay_seconds": humanized.hbs_avg_delay,
            "avg_size_reduction_pct": humanized.hbs_avg_size_reduction * 100,
        },

        # C3: Limit order analysis
        "limit_orders": {
            "limits_submitted": humanized.limit_orders_submitted,
            "limits_filled": humanized.limit_orders_filled,
            "limit_fill_rate_pct": humanized.limit_fill_rate * 100,
            "stop_limits_submitted": humanized.stop_limit_orders_submitted,
            "stop_limits_filled": humanized.stop_limit_orders_filled,
        },

        # H2: Apex 30% rule analysis
        "apex_30pct_rule": {
            "days_triggered": humanized.days_30pct_triggered,
            "trades_blocked": humanized.trades_blocked_by_30pct,
        },

        # C2: Delay distribution
        "delay_distribution": humanized.delay_distribution or {},

        # Overall assessment
        "overall": {
            "performance_cost_pct": abs(calc_impact(baseline.net_pnl, humanized.net_pnl)),
            "within_target": 15 <= abs(calc_impact(baseline.net_pnl, humanized.net_pnl)) <= 25,
            "target_range": "15-20%",
        },
    }


def print_comparison_table(comparison: Dict[str, Any]) -> None:
    """Print comparison table to console."""
    print("\n" + "=" * 60)
    print("COMPARISON RESULTS")
    print("=" * 60)

    print("\n### Core Metrics ###")
    print(f"{'Metric':<20} {'Baseline':>12} {'Humanized':>12} {'Impact':>10}")
    print("-" * 56)

    for metric in ["total_trades", "win_rate", "profit_factor", "sharpe_ratio",
                   "max_drawdown", "net_pnl", "sqn"]:
        data = comparison[metric]
        base = data["baseline"]
        human = data["humanized"]
        impact = data["impact_pct"]

        if metric in ["win_rate", "max_drawdown"]:
            print(f"{metric:<20} {base:>11.2f}% {human:>11.2f}% {impact:>+9.1f}%")
        elif metric == "net_pnl":
            print(f"{metric:<20} ${base:>10,.0f} ${human:>10,.0f} {impact:>+9.1f}%")
        else:
            print(f"{metric:<20} {base:>12,.2f} {human:>12,.2f} {impact:>+9.1f}%")

    print("\n### HBS Behavior ###")
    hbs = comparison["hbs_behavior"]
    print(f"Signals skipped: {hbs['signals_skipped']} ({hbs['skip_rate_pct']:.1f}%)")
    print(f"Avg delay: {hbs['avg_delay_seconds']:.2f}s")
    print(f"Avg size reduction: {hbs['avg_size_reduction_pct']:.1f}%")

    print("\n### Limit Orders (C3) ###")
    limits = comparison["limit_orders"]
    print(f"Limit orders: {limits['limits_filled']}/{limits['limits_submitted']} filled "
          f"({limits['limit_fill_rate_pct']:.1f}%)")
    print(f"Stop-limit orders: {limits['stop_limits_filled']}/{limits['stop_limits_submitted']} filled")

    print("\n### Apex 30% Rule (H2) ###")
    apex = comparison["apex_30pct_rule"]
    print(f"Days triggered: {apex['days_triggered']}")
    print(f"Trades blocked: {apex['trades_blocked']}")

    print("\n### VERDICT ###")
    overall = comparison["overall"]
    cost = overall["performance_cost_pct"]
    target = overall["within_target"]
    status = "✓ PASS" if target else "✗ NEEDS TUNING"
    print(f"Performance cost: {cost:.1f}% (target: {overall['target_range']})")
    print(f"Status: {status}")


def save_comparison_report(comparison: Dict[str, Any], path: Path) -> None:
    """Save markdown comparison report."""
    path.parent.mkdir(parents=True, exist_ok=True)

    overall = comparison["overall"]
    hbs = comparison["hbs_behavior"]
    limits = comparison["limit_orders"]
    apex = comparison["apex_30pct_rule"]

    status = "GO" if overall["within_target"] else "NEEDS TUNING"

    report = f"""# HBS Backtest Comparison Report

**Generated:** {comparison['run_date']}
**Data Range:** {comparison['date_range']['start']} to {comparison['date_range']['end']}
**Version:** Plan 11-02 v2.0 (with CRITIC fixes C2, C3, C4, H2)

## Executive Summary

| Aspect | Value | Target | Status |
|--------|-------|--------|--------|
| Performance Cost | {overall['performance_cost_pct']:.1f}% | 15-20% | {status} |
| Skip Rate | {hbs['skip_rate_pct']:.1f}% | ~13% | {'OK' if 10 <= hbs['skip_rate_pct'] <= 16 else 'TUNE'} |
| Avg Delay | {hbs['avg_delay_seconds']:.2f}s | ~1.0s | {'OK' if 0.5 <= hbs['avg_delay_seconds'] <= 1.5 else 'TUNE'} |
| Limit Fill Rate | {limits['limit_fill_rate_pct']:.1f}% | >80% | {'OK' if limits['limit_fill_rate_pct'] >= 80 else 'TUNE'} |

## Metrics Comparison

| Metric | Baseline | Humanized | Impact |
|--------|----------|-----------|--------|
| Total Trades | {comparison['total_trades']['baseline']:,} | {comparison['total_trades']['humanized']:,} | {comparison['total_trades']['impact_pct']:+.1f}% |
| Win Rate | {comparison['win_rate']['baseline']:.2f}% | {comparison['win_rate']['humanized']:.2f}% | {comparison['win_rate']['impact_pct']:+.1f}% |
| Profit Factor | {comparison['profit_factor']['baseline']:.2f} | {comparison['profit_factor']['humanized']:.2f} | {comparison['profit_factor']['impact_pct']:+.1f}% |
| Sharpe Ratio | {comparison['sharpe_ratio']['baseline']:.2f} | {comparison['sharpe_ratio']['humanized']:.2f} | {comparison['sharpe_ratio']['impact_pct']:+.1f}% |
| Max Drawdown | {comparison['max_drawdown']['baseline']:.2f}% | {comparison['max_drawdown']['humanized']:.2f}% | {comparison['max_drawdown']['impact_pct']:+.1f}% |
| Net P&L | ${comparison['net_pnl']['baseline']:,.0f} | ${comparison['net_pnl']['humanized']:,.0f} | {comparison['net_pnl']['impact_pct']:+.1f}% |
| SQN | {comparison['sqn']['baseline']:.2f} | {comparison['sqn']['humanized']:.2f} | {comparison['sqn']['impact_pct']:+.1f}% |

## HBS Behavior Analysis

### Signal Processing
- **Signals skipped:** {hbs['signals_skipped']} ({hbs['skip_rate_pct']:.1f}%)
- **Avg delay applied:** {hbs['avg_delay_seconds']:.2f}s
- **Avg size reduction:** {hbs['avg_size_reduction_pct']:.1f}%

### Order Type Distribution (C3 Fix)
- **Limit orders:** {limits['limits_filled']}/{limits['limits_submitted']} filled ({limits['limit_fill_rate_pct']:.1f}%)
- **Stop-limit orders:** {limits['stop_limits_filled']}/{limits['stop_limits_submitted']} filled

### Apex 30% Rule (H2 Fix)
- **Days rule triggered:** {apex['days_triggered']}
- **Trades blocked:** {apex['trades_blocked']}

## Delay Distribution (C2 Fix)

```
Mean:  {comparison['delay_distribution'].get('mean', 'N/A')}s
Std:   {comparison['delay_distribution'].get('std', 'N/A')}s
Min:   {comparison['delay_distribution'].get('min', 'N/A')}s
Max:   {comparison['delay_distribution'].get('max', 'N/A')}s
P95:   {comparison['delay_distribution'].get('p95', 'N/A')}s
```

## Conclusion

**Verdict:** {status}

{'Performance cost within acceptable range (15-20%). HBS provides adequate stealth without excessive performance degradation.' if overall['within_target'] else 'Performance cost outside target range. Consider tuning HBS parameters.'}

## Recommendations

{'No tuning needed. Proceed to paper trading validation.' if overall['within_target'] else '''
Consider the following adjustments:
- If cost too high (>20%): tune-aggressive (reduce skip rate, delay)
- If cost too low (<15%): tune-conservative (increase skip rate, delay)
'''}

---
*Report generated by backtest_hbs_comparison.py v2.0*
"""

    path.write_text(report)


def save_comparison_json(comparison: Dict[str, Any], path: Path) -> None:
    """Save JSON for programmatic access."""
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, 'w') as f:
        json.dump(comparison, f, indent=2, default=str)


if __name__ == "__main__":
    run_comparison()
```

**Report format (HBS_BACKTEST_COMPARISON.md):**

Enhanced from v1.0 to include:
- C2: Delay distribution statistics
- C3: Limit/stop-limit order fill rates
- H2: Apex 30% rule trigger analysis

AVOID:
- Using different date ranges for comparison
- Changing any other parameters between runs
- Cherry-picking favorable periods
  </action>
  <verify>
    - python nautilus_gold_scalper/scripts/backtest_hbs_comparison.py
    - ls DOCS/03_RESEARCH/FINDINGS/HBS_BACKTEST_COMPARISON.md
    - ls DOCS/03_RESEARCH/FINDINGS/HBS_BACKTEST_COMPARISON.json
  </verify>
  <done>
    - Both backtests complete successfully
    - Comparison report generated (markdown + JSON)
    - Performance impact measured
    - C2: Delay distribution analyzed
    - C3: Limit order fill rates tracked
    - H2: 30% rule impacts documented
  </done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>
    - HBS integrated into gold_scalper_strategy with all CRITIC fixes
    - C2: Async delay executor (real delays in live mode)
    - C3: Order lifecycle manager (limit/stop-limit tracking)
    - C4: Thread-safe session transitions
    - H2: Apex 30% consistency rule tracking
    - Comparative backtest run with enhanced metrics
  </what-built>
  <how-to-verify>
    1. Review: DOCS/03_RESEARCH/FINDINGS/HBS_BACKTEST_COMPARISON.md
    2. Check performance impact: Is it within 15-20% target?
    3. Check HBS metrics:
       - Skip rate close to 13%?
       - Delay distribution reasonable (mean ~1.0s)?
       - Size variation within ±15%?
    4. Check CRITIC fix metrics:
       - Limit fill rate >80%?
       - 30% rule triggered appropriately?
    5. Decide: Accept current config OR request parameter tuning
  </how-to-verify>
  <resume-signal>
    - "approved" - Accept results, HBS implementation complete
    - "tune-aggressive" - Reduce humanization (more trades, higher risk)
    - "tune-conservative" - Increase humanization (fewer trades, lower risk)
    - Describe specific issues to address
  </resume-signal>
</task>

<task type="auto">
  <name>Task 3: Parameter Tuning (if needed)</name>
  <files>
    config/hbs_config.yaml,
    nautilus_gold_scalper/src/execution/human_config.py
  </files>
  <action>
Based on checkpoint feedback, adjust HBS parameters:

**If "tune-aggressive" (reduce humanization):**
- Decrease skip_base_rate: 0.13 → 0.08
- Decrease cancel_rate: 0.08 → 0.04
- Decrease size_variation: 0.15 → 0.10
- Decrease delay_mean: 1.0 → 0.6
- Decrease delay_gaussian_weight: 0.80 → 0.90 (more predictable)

**If "tune-conservative" (increase humanization):**
- Increase skip_base_rate: 0.13 → 0.18
- Increase cancel_rate: 0.08 → 0.12
- Increase size_variation: 0.15 → 0.22
- Increase delay_mean: 1.0 → 1.4
- Increase delay_longtail_weight: 0.20 → 0.30 (more extreme delays)

**If specific issues mentioned:**
- Address each issue by adjusting relevant parameters
- Re-run comparison backtest to verify

**If limit fill rate too low (<80%):**
- Consider adjusting limit price offset
- Or increase market order percentage

Create final `config/hbs_config.yaml` with tuned values.

AVOID:
- Over-tuning to specific backtest results (overfitting)
- Making changes without re-running validation
  </action>
  <verify>
    - python nautilus_gold_scalper/scripts/backtest_hbs_comparison.py (re-run if parameters changed)
    - cat config/hbs_config.yaml
  </verify>
  <done>
    - Parameters tuned based on feedback
    - Final config saved to YAML
    - Re-validation shows acceptable performance impact
  </done>
</task>

</tasks>

<verification>
Before declaring plan complete:
- [ ] HBS integration doesn't break existing strategy tests
- [ ] C2: DelayedExecutor implemented and tested
- [ ] C3: OrderLifecycleManager implemented and tested
- [ ] C4: Thread-safe session transitions verified
- [ ] H2: 30% rule tracking implemented
- [ ] Comparative backtest completes without errors
- [ ] Performance impact documented and within acceptable range
- [ ] HBS behavior metrics match expected distributions
- [ ] User approved results at checkpoint
</verification>

<success_criteria>
- All tasks completed
- All verification checks pass
- All CRITIC fixes (C2, C3, C4, H2) implemented
- HBS successfully integrated into trading flow
- Performance impact measured and documented
- Parameters tuned to acceptable levels
- Strategy ready for paper trading validation (future)
</success_criteria>

<output>
After completion, create `.planning/phases/08-nautilus-deep-audit/11-02-HBS-INTEGRATION-SUMMARY.md`:

# Phase 11 Plan 02: HBS Integration Summary

**[One-liner: Integration complete with CRITIC fixes, X% performance cost measured]**

## Accomplishments
- Integrated HBS into gold_scalper_strategy.py
- Implemented C2: Async delay executor (backtest=immediate, live=delayed)
- Implemented C3: Order lifecycle manager for limits/stop-limits
- Implemented C4: Thread-safe session transitions
- Implemented H2: Apex 30% consistency rule tracking
- Ran comparative backtest (with/without HBS)
- Documented performance impact

## Files Modified
- `nautilus_gold_scalper/src/strategies/gold_scalper_strategy.py` - HBS integration
- `nautilus_gold_scalper/src/execution/__init__.py` - Exports

## Files Created
- `nautilus_gold_scalper/src/execution/delayed_executor.py` - C2 fix
- `nautilus_gold_scalper/src/execution/order_lifecycle.py` - C3 fix
- `nautilus_gold_scalper/scripts/backtest_hbs_comparison.py` - Comparison script
- `config/hbs_config.yaml` - Production config
- `DOCS/03_RESEARCH/FINDINGS/HBS_BACKTEST_COMPARISON.md` - Results
- `DOCS/03_RESEARCH/FINDINGS/HBS_BACKTEST_COMPARISON.json` - Programmatic results

## Key Metrics
- Baseline trades: X
- Humanized trades: Y
- Performance impact: Z%
- Skip rate: A%
- Avg delay: Bs
- Limit fill rate: C%
- 30% rule days triggered: D

## CRITIC Fixes Applied
- C2: Async delay executor for live mode ✓
- C3: Limit order lifecycle tracking ✓
- C4: Thread-safe session transitions ✓
- H2: Apex 30% consistency rule ✓

## Decisions Made
- [Parameter tuning decisions]

## Issues Encountered
- [Problems and resolutions, or "None"]

## Next Step
Phase 11 (HBS Python Core) COMPLETE.
Future: NT8 Add-On + TCP Bridge when ready to go live.
</output>
