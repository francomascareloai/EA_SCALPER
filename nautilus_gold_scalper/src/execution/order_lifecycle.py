"""
OrderLifecycleManager: Tracks limit and stop-limit orders through their lifecycle.

CRITICAL: HBS uses 25% limit orders + 5% stop-limit orders.
These have different lifecycle states than market orders.

R2-C-3 FIX: All datetime operations accept current_time parameter to avoid
datetime.now()/datetime.utcnow() temporal violations in backtests.

States:
- PENDING: Order submitted, waiting for fill
- PARTIAL: Partially filled
- FILLED: Fully filled
- CANCELLED: User/system cancelled
- EXPIRED: Time-in-force expired (e.g., IOC)
- REJECTED: Broker rejected
"""

import logging
import threading
from collections.abc import Callable
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from enum import Enum, auto
from zoneinfo import ZoneInfo

logger = logging.getLogger(__name__)

# Use UTC for internal timestamps
UTC = ZoneInfo("UTC")


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


def _utc_now() -> datetime:
    """Get current UTC time with timezone info.

    R2-C-3: This is ONLY used as a fallback for live mode.
    In backtest mode, callers should always provide current_time.
    """
    return datetime.now(UTC)


@dataclass
class TrackedOrder:
    """An order being tracked through its lifecycle.

    R2-C-3 FIX: created_at/updated_at should be set explicitly by caller
    using current_time parameter, not via default_factory with datetime.utcnow().
    The factory now uses timezone-aware UTC.
    """
    order_id: str
    order_type: OrderType
    direction: str  # "LONG" or "SHORT"
    requested_qty: float
    filled_qty: float = 0.0
    limit_price: float | None = None
    stop_price: float | None = None
    state: OrderState = OrderState.PENDING
    # R2-C-3 FIX: Use timezone-aware UTC, or better yet, set explicitly
    created_at: datetime = field(default_factory=_utc_now)
    updated_at: datetime = field(default_factory=_utc_now)
    fill_price: float | None = None
    # HBS tracking
    hbs_delay_applied: float = 0.0
    hbs_size_multiplier: float = 1.0
    # PnL (set when closed)
    realized_pnl: float | None = None


class OrderLifecycleManager:
    """
    Manages limit/stop-limit order lifecycle for HBS tracking.

    HBS needs to know when limits fill (or don't) to adjust behavior.
    - High limit fill rate → market might be trending, adjust skip rate
    - Low limit fill rate → consider wider limits or use markets

    Usage:
        manager = OrderLifecycleManager(
            on_fill_callback=strategy._on_hbs_order_filled,
            on_cancel_callback=strategy._on_hbs_order_cancelled,
        )

        # When placing an order
        tracked = manager.track_order(
            order_id="123",
            order_type=OrderType.LIMIT,
            direction="LONG",
            qty=1.0,
            limit_price=2000.50,
        )

        # When order fills
        manager.on_fill("123", filled_qty=1.0, fill_price=2000.50)

        # Get metrics
        fill_rate = manager.get_limit_fill_rate()
    """

    def __init__(
        self,
        on_fill_callback: Callable[["TrackedOrder", bool], None] | None = None,
        on_cancel_callback: Callable[["TrackedOrder"], None] | None = None,
        on_expire_callback: Callable[["TrackedOrder"], None] | None = None,
    ):
        self._on_fill = on_fill_callback
        self._on_cancel = on_cancel_callback
        self._on_expire = on_expire_callback

        # Order tracking
        self._orders: dict[str, TrackedOrder] = {}
        self._lock = threading.Lock()

        # Metrics
        self._total_limits_submitted = 0
        self._total_limits_filled = 0
        self._total_limits_cancelled = 0
        self._total_limits_expired = 0
        self._total_limits_rejected = 0

        logger.info("OrderLifecycleManager initialized")

    def track_order(
        self,
        order_id: str,
        order_type: OrderType,
        direction: str,
        qty: float,
        limit_price: float | None = None,
        stop_price: float | None = None,
        hbs_delay: float = 0.0,
        hbs_size_mult: float = 1.0,
        current_time: datetime | None = None,
    ) -> TrackedOrder:
        """Start tracking a new order.

        R2-C-3 FIX: Accept current_time for backtest correctness.
        """
        if current_time is None:
            current_time = _utc_now()

        order = TrackedOrder(
            order_id=order_id,
            order_type=order_type,
            direction=direction,
            requested_qty=qty,
            limit_price=limit_price,
            stop_price=stop_price,
            hbs_delay_applied=hbs_delay,
            hbs_size_multiplier=hbs_size_mult,
            created_at=current_time,
            updated_at=current_time,
        )

        with self._lock:
            self._orders[order_id] = order
            if order_type in (OrderType.LIMIT, OrderType.STOP_LIMIT):
                self._total_limits_submitted += 1

        logger.debug(f"Tracking order {order_id}: {order_type.name} {direction}")
        return order

    def on_fill(
        self,
        order_id: str,
        filled_qty: float,
        fill_price: float | None = None,
        is_partial: bool = False,
        is_winner: bool = True,
        realized_pnl: float | None = None,
        current_time: datetime | None = None,
    ) -> None:
        """Handle order fill event.

        R2-C-3 FIX: Accept current_time for backtest correctness.
        """
        if current_time is None:
            current_time = _utc_now()

        with self._lock:
            order = self._orders.get(order_id)
            if not order:
                logger.warning(f"Fill for unknown order: {order_id}")
                return

            order.filled_qty += filled_qty
            order.updated_at = current_time
            order.fill_price = fill_price
            order.realized_pnl = realized_pnl

            if is_partial:
                order.state = OrderState.PARTIAL
            else:
                order.state = OrderState.FILLED
                if order.order_type in (OrderType.LIMIT, OrderType.STOP_LIMIT):
                    self._total_limits_filled += 1

        logger.info(
            f"Order {order_id} filled: qty={filled_qty}, "
            f"price={fill_price}, winner={is_winner}"
        )

        if self._on_fill and order.state == OrderState.FILLED:
            self._on_fill(order, is_winner)

    def on_cancel(
        self,
        order_id: str,
        reason: str = "",
        current_time: datetime | None = None,
    ) -> None:
        """Handle order cancellation.

        R2-C-3 FIX: Accept current_time for backtest correctness.
        """
        if current_time is None:
            current_time = _utc_now()

        with self._lock:
            order = self._orders.get(order_id)
            if not order:
                return

            order.state = OrderState.CANCELLED
            order.updated_at = current_time
            if order.order_type in (OrderType.LIMIT, OrderType.STOP_LIMIT):
                self._total_limits_cancelled += 1

        logger.info(f"Order {order_id} cancelled: {reason}")
        if self._on_cancel:
            self._on_cancel(order)

    def on_expire(
        self,
        order_id: str,
        current_time: datetime | None = None,
    ) -> None:
        """Handle order expiration (time-in-force).

        R2-C-3 FIX: Accept current_time for backtest correctness.
        """
        if current_time is None:
            current_time = _utc_now()

        with self._lock:
            order = self._orders.get(order_id)
            if not order:
                return

            order.state = OrderState.EXPIRED
            order.updated_at = current_time
            if order.order_type in (OrderType.LIMIT, OrderType.STOP_LIMIT):
                self._total_limits_expired += 1

        logger.info(f"Order {order_id} expired")
        if self._on_expire:
            self._on_expire(order)

    def on_reject(
        self,
        order_id: str,
        reason: str = "",
        current_time: datetime | None = None,
    ) -> None:
        """Handle order rejection.

        R2-C-3 FIX: Accept current_time for backtest correctness.
        """
        if current_time is None:
            current_time = _utc_now()

        with self._lock:
            order = self._orders.get(order_id)
            if not order:
                return

            order.state = OrderState.REJECTED
            order.updated_at = current_time
            if order.order_type in (OrderType.LIMIT, OrderType.STOP_LIMIT):
                self._total_limits_rejected += 1

        logger.warning(f"Order {order_id} rejected: {reason}")

    def get_order(self, order_id: str) -> TrackedOrder | None:
        """Get a tracked order by ID."""
        with self._lock:
            return self._orders.get(order_id)

    def get_pending_orders(self) -> list[TrackedOrder]:
        """Get all pending (unfilled) orders."""
        with self._lock:
            return [
                o for o in self._orders.values()
                if o.state in (OrderState.PENDING, OrderState.PARTIAL)
            ]

    def get_limit_fill_rate(self) -> float:
        """
        Get fill rate for limit orders.

        Used by HBS to potentially adjust order type distribution:
        - Low fill rate (<50%) → increase market order percentage
        - High fill rate (>80%) → can use more limits
        """
        with self._lock:
            if self._total_limits_submitted == 0:
                return 0.0
            return self._total_limits_filled / self._total_limits_submitted

    def get_metrics(self) -> dict[str, float]:
        """Get all lifecycle metrics."""
        with self._lock:
            return {
                "limits_submitted": self._total_limits_submitted,
                "limits_filled": self._total_limits_filled,
                "limits_cancelled": self._total_limits_cancelled,
                "limits_expired": self._total_limits_expired,
                "limits_rejected": self._total_limits_rejected,
                "fill_rate": self.get_limit_fill_rate(),
            }

    def clear_completed(
        self,
        older_than_hours: int = 24,
        current_time: datetime | None = None,
    ) -> int:
        """
        Clean up completed orders older than specified hours.

        R2-C-3 FIX: Accept current_time for backtest correctness.

        Args:
            older_than_hours: Remove orders completed more than X hours ago
            current_time: Current timestamp (for backtest correctness)

        Returns:
            Number of orders removed
        """
        if current_time is None:
            current_time = _utc_now()

        cutoff = current_time - timedelta(hours=older_than_hours)
        removed = 0

        with self._lock:
            to_remove = []
            for order_id, order in self._orders.items():
                if order.state in (OrderState.FILLED, OrderState.CANCELLED,
                                   OrderState.EXPIRED, OrderState.REJECTED):
                    if order.updated_at < cutoff:
                        to_remove.append(order_id)

            for order_id in to_remove:
                del self._orders[order_id]
                removed += 1

        if removed > 0:
            logger.info(f"Cleaned up {removed} completed orders")
        return removed

    def reset_metrics(self) -> None:
        """Reset all metrics (e.g., start of new session)."""
        with self._lock:
            self._total_limits_submitted = 0
            self._total_limits_filled = 0
            self._total_limits_cancelled = 0
            self._total_limits_expired = 0
            self._total_limits_rejected = 0
        logger.info("OrderLifecycleManager metrics reset")
