"""
DelayedExecutor: Handles HBS delay scheduling for live mode.

In BACKTEST mode: Delays are informational only (immediate execution).
In LIVE mode: Actual delayed execution via asyncio/threading.

CRITICAL for Apex stealth: delays MUST be real in live mode.

H-NEW-1 FIX: Uses threading.Event for startup synchronization (no busy-wait).
H-NEW-5 FIX: Checks cancel flag BEFORE executing delayed callback.
"""

import asyncio
import logging
import threading
from collections.abc import Callable
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Any

from nautilus_trader.common.component import Clock

logger = logging.getLogger(__name__)


@dataclass
class PendingExecution:
    """A delayed execution waiting to fire."""

    execute_at: datetime
    callback: Callable[[], None]
    order_params: dict[str, Any]
    created_at: datetime
    cancelled: bool = False
    # H-NEW-4: Context-aware cancellation params
    entry_price: float = 0.0
    cancel_if_price_moves_ticks: int = 5
    cancel_after_seconds: float = 30.0


class DelayedExecutor:
    """
    Manages delayed order execution for HBS.

    In backtest: Logs delay but executes immediately (no real time).
    In live: Schedules actual delayed execution.

    Usage:
        executor = DelayedExecutor(clock, is_live=True)

        # Schedule a delayed execution
        pending = executor.schedule(
            delay_seconds=1.5,
            callback=lambda: strategy.execute_order(order_params),
            order_params={"side": "BUY", "qty": 1.0},
        )

        # Cancel if needed
        executor.cancel_pending(pending)

        # At session end
        executor.cancel_all()
        executor.shutdown()
    """

    def __init__(
        self,
        clock: Clock,
        is_live: bool,
        max_pending: int = 10,
    ):
        self._clock = clock
        self._is_live = is_live
        self._max_pending = max_pending

        # Pending executions (live mode only)
        self._pending: list[PendingExecution] = []
        self._pending_lock = threading.Lock()

        # Event loop for async scheduling (live mode)
        self._loop: asyncio.AbstractEventLoop | None = None
        self._ready = threading.Event()  # H-NEW-1 FIX: Use Event instead of busy-wait
        self._shutdown_requested = False

        if is_live:
            self._start_executor_loop()

        logger.info(f"DelayedExecutor initialized: is_live={is_live}")

    def _start_executor_loop(self) -> None:
        """Start background event loop for delayed executions."""

        def run_loop() -> None:
            self._loop = asyncio.new_event_loop()
            asyncio.set_event_loop(self._loop)
            self._ready.set()  # H-NEW-1 FIX: Signal ready
            try:
                self._loop.run_forever()
            finally:
                self._loop.close()

        thread = threading.Thread(target=run_loop, daemon=True, name="HBS-DelayedExecutor")
        thread.start()

        # H-NEW-1 FIX: Wait with timeout instead of busy-wait
        if not self._ready.wait(timeout=5.0):
            raise RuntimeError("Delayed executor thread failed to start within 5s")

        logger.info("DelayedExecutor event loop started")

    def schedule(
        self,
        delay_seconds: float,
        callback: Callable[[], None],
        order_params: dict[str, Any],
        entry_price: float = 0.0,
        cancel_if_price_moves_ticks: int = 5,
        cancel_after_seconds: float = 30.0,
    ) -> PendingExecution | None:
        """
        Schedule delayed execution.

        In backtest: Execute immediately, log delay for analysis.
        In live: Actually delay execution.

        Args:
            delay_seconds: How long to wait before executing
            callback: Function to call after delay
            order_params: Order parameters for logging/tracking
            entry_price: Price at scheduling (for H-NEW-4 context-aware cancel)
            cancel_if_price_moves_ticks: Cancel if price moves this many ticks
            cancel_after_seconds: Cancel if not executed within this time

        Returns:
            PendingExecution for live mode, None for backtest
        """
        now = self._clock.utc_now()

        if not self._is_live:
            # BACKTEST MODE: Execute immediately, record delay for metrics
            logger.debug(
                "[BACKTEST] HBS delay %.2fs (executing immediately) order_params=%s",
                delay_seconds,
                order_params,
            )
            try:
                callback()
            except Exception:
                logger.error(
                    "[BACKTEST] Callback failed order_params=%s",
                    order_params,
                    exc_info=True,
                )
            return None

        # LIVE MODE: Schedule actual delayed execution
        execute_at = now + timedelta(seconds=delay_seconds)

        pending = PendingExecution(
            execute_at=execute_at,
            callback=callback,
            order_params=order_params,
            created_at=now,
            entry_price=entry_price,
            cancel_if_price_moves_ticks=cancel_if_price_moves_ticks,
            cancel_after_seconds=cancel_after_seconds,
        )

        with self._pending_lock:
            # Limit pending queue
            if len(self._pending) >= self._max_pending:
                logger.warning(f"Pending queue full ({self._max_pending}), dropping oldest")
                oldest = self._pending.pop(0)
                oldest.cancelled = True
            self._pending.append(pending)

        # Schedule in event loop
        if self._loop and not self._shutdown_requested:
            asyncio.run_coroutine_threadsafe(
                self._delayed_execute(pending, delay_seconds),
                self._loop,
            )

        logger.info(f"[LIVE] Scheduled execution in {delay_seconds:.2f}s at {execute_at}")
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
                logger.info("Delayed execution cancelled before firing")
                return

            if self._shutdown_requested:
                logger.info("Delayed execution skipped: executor shutting down")
                return

            # H-NEW-5 FIX: Check if session is still valid (time gate)
            current_time = self._clock.utc_now()
            # Check if we're significantly past the scheduled time (session may have ended)
            if pending.execute_at:
                time_drift = (current_time - pending.execute_at).total_seconds()
                if time_drift > 60.0:  # More than 1 minute late = session likely ended
                    logger.warning(
                        "Delayed execution skipped: %.1fs late (session may have ended)",
                        time_drift,
                    )
                    self._pending.remove(pending)
                    return

        try:
            pending.callback()
            logger.info("Delayed execution fired successfully")
        except Exception:
            logger.error("Delayed execution failed", exc_info=True)
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
                logger.info(f"Cancelled pending execution scheduled for {pending.execute_at}")
                return True
        return False

    def cancel_all(self) -> int:
        """Cancel all pending executions (e.g., session end)."""
        with self._pending_lock:
            count = len(self._pending)
            for p in self._pending:
                p.cancelled = True
            self._pending.clear()
        if count > 0:
            logger.info(f"Cancelled {count} pending executions")
        return count

    def get_pending_count(self) -> int:
        """Get number of pending executions."""
        with self._pending_lock:
            return len(self._pending)

    def check_context_cancellations(self, current_price: float, tick_size: float) -> int:
        """
        H-NEW-4 FIX: Check if any pending orders should be cancelled based on context.

        Called periodically (e.g., on each tick) to check if:
        - Price has moved too far from entry
        - Order has been pending too long

        Args:
            current_price: Current market price
            tick_size: Tick size for the instrument

        Returns:
            Number of orders cancelled
        """
        cancelled = 0
        now = self._clock.utc_now()

        # BUG-LIVE-003: Guard against invalid tick_size.
        # If tick_size is <= 0, skip the price-distance check to avoid ZeroDivisionError
        # and rely on time-based cancellation.
        price_check_enabled = tick_size > 0
        if not price_check_enabled:
            logger.warning(f"Invalid tick_size={tick_size}; disabling price-based cancellation")

        with self._pending_lock:
            to_cancel = []
            for pending in self._pending:
                if pending.cancelled:
                    continue

                # Check price movement
                if price_check_enabled and pending.entry_price > 0:
                    price_diff_ticks = abs(current_price - pending.entry_price) / tick_size
                    if price_diff_ticks >= pending.cancel_if_price_moves_ticks:
                        logger.info(f"Context cancel: price moved {price_diff_ticks:.1f} ticks")
                        to_cancel.append(pending)
                        continue

                # Check time elapsed
                elapsed = (now - pending.created_at).total_seconds()
                if elapsed >= pending.cancel_after_seconds:
                    logger.info(f"Context cancel: pending for {elapsed:.1f}s")
                    to_cancel.append(pending)

            for pending in to_cancel:
                pending.cancelled = True
                self._pending.remove(pending)
                cancelled += 1

        return cancelled

    def shutdown(self) -> None:
        """Clean shutdown of executor."""
        logger.info("DelayedExecutor shutting down...")
        self._shutdown_requested = True
        self.cancel_all()
        if self._loop:
            self._loop.call_soon_threadsafe(self._loop.stop)
        logger.info("DelayedExecutor shutdown complete")
