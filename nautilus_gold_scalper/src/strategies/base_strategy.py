"""
Base Strategy for Nautilus Gold Scalper.
STREAM F - Trading Strategies (Part 1)

Provides abstract base class for all trading strategies with common functionality:
- Multi-timeframe data management
- Risk management integration
- Position tracking
- Signal generation interface
"""

import json
import math
import random
from abc import abstractmethod
from datetime import date, datetime, timezone
from decimal import Decimal
from typing import Any, Literal

try:
    from nautilus_trader.config import StrategyConfig as NautilusStrategyConfig
except ImportError:  # mypy/CI environments may not have NautilusTrader stubs
    from typing import Any as _Any

    class NautilusStrategyConfig:  # type: ignore[no-redef]
        """Dummy fallback for environments without NautilusTrader."""

        def __init_subclass__(cls, **kwargs: _Any) -> None:
            # Accept kw_only, frozen, etc. kwargs that msgspec.Struct uses
            super().__init_subclass__()


from nautilus_trader.core.message import Event
from nautilus_trader.model import (
    Bar,
    BarType,
    ClientOrderId,
    InstrumentId,
    Position,
    QuoteTick,
)
from nautilus_trader.model.enums import (
    ContingencyType,
    OrderSide,
    OrderType,
    PositionSide,
    TimeInForce,
    TradingState,
)
from nautilus_trader.model.events import (
    OrderAccepted,
    OrderCanceled,
    OrderRejected,
    PositionChanged,
    PositionClosed,
    PositionOpened,
)
from nautilus_trader.model.identifiers import ExecAlgorithmId
from nautilus_trader.model.instruments import Instrument
from nautilus_trader.model.objects import Price, Quantity

try:
    from nautilus_trader.indicators import SpreadAnalyzer
except ImportError:  # pragma: no cover
    SpreadAnalyzer = None

try:
    from nautilus_trader.trading.strategy import Strategy as NautilusStrategy
except ImportError:  # mypy/CI environments may not have NautilusTrader stubs

    class NautilusStrategy:  # type: ignore[no-redef]
        pass


from ..core.data_types import ConfluenceResult, RegimeAnalysis, SessionInfo


def _et_day_key(ts_ns: int) -> date | None:
    try:
        from zoneinfo import ZoneInfo
    except ImportError:
        return None
    return datetime.fromtimestamp(ts_ns / 1e9, tz=ZoneInfo("America/New_York")).date()


from ..core.definitions import (
    MIN_VALID_SCORE,
    TIER_A_MIN,
    TIER_B_MIN,
    TIER_C_MIN,
    TIER_S_MIN,
    XAUUSD_LOT_SIZE,
    SignalQuality,
)
from ..risk.circuit_breaker import CircuitBreakerLevel


def _encode_json_bytes(payload: dict[str, Any]) -> bytes:
    data = json.dumps(payload, separators=(",", ":"), sort_keys=True).encode("utf-8")
    if not isinstance(data, (bytes, bytearray)):
        raise TypeError("Expected bytes from JSON encoding")
    return bytes(data)


def _decode_json_bytes(blob: bytes) -> dict[str, Any]:
    obj = json.loads(blob.decode("utf-8"))
    if not isinstance(obj, dict):
        raise TypeError(f"Expected dict JSON payload, got {type(obj).__name__}")
    return obj


class BaseStrategyConfig(NautilusStrategyConfig, kw_only=True):  # type: ignore[misc,call-arg]
    """Base configuration for gold scalping strategies."""

    instrument_id: InstrumentId

    # Determinism: used to seed per-strategy RNG for any randomized logic.
    seed: int = 42

    # Multi-timeframe bar types
    htf_bar_type: BarType | None = None  # H1 - Direction
    mtf_bar_type: BarType | None = None  # M15 - Structure
    ltf_bar_type: BarType | None = None  # M5 - Execution

    # Bar sizing (minutes)
    # Used by backtest/optimization harnesses for consistent time hierarchy.
    ltf_bar_minutes: int = 5
    mtf_bar_minutes: int = 15
    htf_bar_minutes: int = 60
    management_bar_minutes: int = 60

    # Risk parameters
    risk_per_trade: Decimal = Decimal("0.01")
    max_daily_loss_pct: Decimal = Decimal("5.0")
    max_total_loss_pct: Decimal = Decimal("10.0")
    max_trades_per_day: int = 15

    # Execution parameters
    min_score_to_trade: float = MIN_VALID_SCORE
    min_rr_ratio: float = 1.5

    # Bars timestamp basis (feed=bars): 'open' means bar-open timestamps and must be shifted by the runner.
    # This is primarily for traceability/debugging; it does not affect strategy logic.
    bars_timestamp_basis: str = "open"

    # TWAP execution algorithm (optional). When enabled, entry market orders will be
    # annotated with exec_algorithm_id/params and executed by the registered TWAP algorithm.
    twap_enabled: bool = False
    twap_horizon_secs: float = 30.0
    twap_interval_secs: float = 3.0
    target_rr_ratio: float = 2.5
    max_spread_points: int = 80
    # SpreadAnalyzer: block entries when spread > Nx average (news/volatility protection)
    spread_block_multiplier: float = 2.0
    spread_analyzer_capacity: int = 100  # Rolling window size for spread average

    # Bracket order confirmation timeout (nanoseconds)
    # Default 60 seconds for backtest compatibility with stride tick data
    # In live trading, this can be reduced to 5-10 seconds
    bracket_confirm_timeout_ns: int = 60_000_000_000

    # Feature flags
    use_session_filter: bool = True
    use_regime_filter: bool = True
    use_mtf: bool = True
    use_footprint: bool = True
    use_native_brackets: bool = False  # Use Nautilus native bracket orders (OCO)

    # Debugging
    debug_mode: bool = False

    # WP1: Feed-stall-proof time gate enforcement (live/paper).
    # Uses Nautilus Clock timers to run time checks even when market events stop.
    time_gate_use_clock_timer: bool = True
    time_gate_timer_interval_ns: int = 1_000_000_000

    # News calendar (local file path). If unset, NewsCalendar uses a minimal fallback.
    news_events_path: str | None = None

    slippage_in_fills: bool = False
    # When True, commissions are applied by the backtest engine fee_model.
    fees_in_account: bool = False


class BaseGoldStrategy(NautilusStrategy):  # type: ignore[misc]
    """
    Abstract base class for gold scalping strategies.

    Provides:
    - Multi-timeframe data subscription and management
    - Risk management integration
    - Position and order tracking
    - Signal quality assessment
    - Common event handlers
    """

    def __init__(self, config: BaseStrategyConfig):
        super().__init__(config=config)

        # Determinism: avoid global RNG state for any randomized strategy logic.
        self._rng = random.Random(int(getattr(config, "seed", 42)))

        self.instrument: Instrument | None = None

        # Bar storage
        self._htf_bars: list[Bar] = []
        self._mtf_bars: list[Bar] = []
        self._ltf_bars: list[Bar] = []

        # State tracking
        self._position: Position | None = None
        self._daily_trades: int = 0
        self._daily_pnl: float = 0.0
        self._is_trading_allowed: bool = True
        self._equity_base: float = float(getattr(config, "account_balance", 100_000.0))
        self._tick_counter: int = 0

        # Latest market timestamp (ns) for deterministic time-based guards.
        # NOTE: must exist even in unit tests which don't call on_start().
        self._last_market_ts_ns: int | None = None
        self._last_tick_ts_ns: int | None = None
        self._last_tick_dt: datetime | None = None

        # Persistence (Phase 14): state is session-bound in ET.
        # We fail-closed if a state blob is for a different ET day.
        self._persistence_schema_version: int = 1
        self._persistence_day_key: date | None = None

        # Pending SL/TP for position management
        self._pending_sl: Price | None = None
        self._pending_tp: Price | None = None

        # Execution/order lifecycle tracking (WP0: fail-safe execution)
        self._entry_client_order_id: str | None = None
        self._entry_terminal_ts_ns: int | None = None
        self._entry_terminal_reason: str | None = None
        self._bracket_sl_client_order_id: str | None = None
        self._bracket_sl_order_id: ClientOrderId | None = None
        self._bracket_tp_client_order_id: str | None = None
        self._bracket_sl_confirmed: bool = False
        self._bracket_tp_confirmed: bool = False
        self._bracket_tp_expected: bool = False
        self._bracket_submitted_ts_ns: int | None = None
        self._active_bracket_list_id: str | None = None  # Native bracket order list ID
        self._bracket_confirm_timeout_ns: int = int(
            getattr(config, "bracket_confirm_timeout_ns", 60_000_000_000)
        )
        self._active_position_id: str | None = None
        self._execution_failsafe_triggered: bool = False
        self._trading_blocked_today: bool = False
        self._position_opened_ts_ns: int | None = None

        # Hot-path caches (updated on position lifecycle events)
        self._pos_cache_entry_px: float | None = None
        self._pos_cache_qty: float | None = None
        self._pos_cache_point_value: float | None = None
        self._pos_cache_side: PositionSide | None = None

        # Fail-safe flatten retry (hostile execution can reject a single close attempt).
        self._failsafe_close_retry_count: int = 0
        self._failsafe_close_last_attempt_ts_ns: int | None = None
        self._failsafe_close_retry_interval_ns: int = int(
            getattr(config, "failsafe_close_retry_interval_ns", 2_000_000_000)
        )
        self._failsafe_close_max_attempts: int = int(
            getattr(config, "failsafe_close_max_attempts", 10)
        )

        # Current analysis results
        self._current_regime: RegimeAnalysis | None = None
        self._current_session: SessionInfo | None = None
        self._last_confluence: ConfluenceResult | None = None
        self._execution_model = getattr(self, "_execution_model", None)
        self._fill_costs = getattr(self, "_fill_costs", {})

        # Signal generation thresholds
        self._min_bars_for_signal: int = 50  # Minimum bars required for signal generation

        # DD telemetry tracking (for dd_snapshot emission on new max)
        self._telemetry_max_total_dd_pct: float = 0.0
        self._telemetry_max_daily_dd_pct: float = 0.0

        # SpreadAnalyzer for spread quality monitoring
        # Initialized in on_start() when instrument_id is confirmed
        self._spread_analyzer: Any = None
        self._spread_block_multiplier: float = float(
            getattr(config, "spread_block_multiplier", 2.0)
        )
        self._spread_analyzer_capacity: int = int(getattr(config, "spread_analyzer_capacity", 100))

    # ========== Lifecycle Methods ==========

    def on_start(self) -> None:
        """Initialize strategy on start."""
        # Load instrument
        self.instrument = self.cache.instrument(self.config.instrument_id)
        if self.instrument is None:
            self.log.error(f"Could not find instrument: {self.config.instrument_id}")
            self.stop()
            return

        # Subscribe to bar data
        if self.config.ltf_bar_type:
            self.subscribe_bars(self.config.ltf_bar_type)
            self.log.info(f"Subscribed to LTF bars: {self.config.ltf_bar_type}")

        if self.config.mtf_bar_type:
            self.subscribe_bars(self.config.mtf_bar_type)
            self.log.info(f"Subscribed to MTF bars: {self.config.mtf_bar_type}")

        if self.config.htf_bar_type:
            self.subscribe_bars(self.config.htf_bar_type)
            self.log.info(f"Subscribed to HTF bars: {self.config.htf_bar_type}")

        # Subscribe to quote ticks for spread monitoring
        self.subscribe_quote_ticks(self.config.instrument_id)

        # Initialize SpreadAnalyzer for spread quality monitoring
        if SpreadAnalyzer is not None:
            self._spread_analyzer = SpreadAnalyzer(
                instrument_id=self.config.instrument_id,
                capacity=self._spread_analyzer_capacity,
            )
            self.log.info(
                f"SpreadAnalyzer initialized (capacity={self._spread_analyzer_capacity}, "
                f"block_multiplier={self._spread_block_multiplier}x)"
            )

        # Daily resets are handled using event timestamps (ET) to keep backtests deterministic.
        # Do not rely on wall-clock timers here.

        # Set up periodic DD check timer (Phase 3: clock.set_timer)
        # This runs DD checks every 30 seconds even when no market events arrive
        if getattr(self.config, "time_gate_use_clock_timer", True):
            try:
                from datetime import timedelta as _timedelta

                # DD check timer: every 30 seconds
                self.clock.set_timer(
                    name="dd_check_timer",
                    interval=_timedelta(seconds=30),
                    callback=self._on_dd_check_timer,
                )

                # Time gate check timer: every 60 seconds
                self.clock.set_timer(
                    name="time_gate_timer",
                    interval=_timedelta(seconds=60),
                    callback=self._on_time_gate_timer,
                )

                self.log.info("[TIMER] DD check (30s) and time gate (60s) timers started")
            except Exception as exc:
                self.log.warning(f"[TIMER] Failed to set timers: {exc}")

        # Strategy-specific initialization
        self._on_strategy_start()

        # After a persistence restore, ensure time gates are enforced using the latest
        # known market timestamp. This is fail-closed for Apex compliance.
        if self._last_market_ts_ns is not None:
            self._enforce_time_gates_after_restore(self._last_market_ts_ns)

        self.log.info(f"Strategy started for {self.config.instrument_id}")

    def on_stop(self) -> None:
        """Cleanup on strategy stop."""
        # Cancel all pending orders FIRST (including SL/TP) to avoid orphaned orders
        self.cancel_all_orders(self.config.instrument_id)

        # Then close all open positions (reduce_only=True ensures we never open new positions)
        self.close_all_positions(self.config.instrument_id, reduce_only=True)

        # Unsubscribe from data
        if self.config.ltf_bar_type:
            self.unsubscribe_bars(self.config.ltf_bar_type)
        if self.config.mtf_bar_type:
            self.unsubscribe_bars(self.config.mtf_bar_type)
        if self.config.htf_bar_type:
            self.unsubscribe_bars(self.config.htf_bar_type)

        self.unsubscribe_quote_ticks(self.config.instrument_id)

        # Cancel timers to prevent memory leaks
        try:
            self.clock.cancel_timer("dd_check_timer")
            self.clock.cancel_timer("time_gate_timer")
        except Exception:
            pass  # Timers may not exist if time_gate_use_clock_timer was False

        # Strategy-specific cleanup
        self._on_strategy_stop()

        self.log.info(
            f"Strategy stopped. Daily trades: {self._daily_trades}, PnL: {self._daily_pnl:.2f}"
        )

    def on_reset(self) -> None:
        """Reset strategy state.

        IMPORTANT: Do NOT clear bar history or indicator state here!
        Indicators need historical context to calculate scores correctly.
        Only reset position and daily counters.

        Bug Fix: Scores were resetting to 0.0 after Day 1 because
        on_reset() was clearing all bars, destroying the lookback window.
        """
        # DO NOT clear bar history here.
        # Indicators need historical context to calculate scores correctly.

        # Reset position and trading state only
        self._position = None
        self._daily_trades = 0
        self._daily_pnl = 0.0
        # BUG-6 FIX: Also reset failsafe on reset() for fresh start
        if self._execution_failsafe_triggered:
            self.log.info("[RESET] Clearing execution failsafe")
            self._execution_failsafe_triggered = False
        self._is_trading_allowed = True
        self._trading_blocked_today = False
        self._clear_pending_orders_and_brackets(reason="reset")
        self.log.info("[RESET] Daily reset - preserving indicator state")

        # DO NOT reset regime/session - let them update naturally from incoming bars
        # self._current_regime = None   # Preserved
        # self._current_session = None  # Preserved
        # self._last_confluence = None  # Preserved

    def on_new_day(self, event: Event) -> None:
        """Reset daily counters.

        If the concrete strategy implements `_check_daily_reset(ts_ns)` (ET-calendar reset),
        delegate to it so the reset is performed exactly once per ET day.
        """
        if hasattr(self, "_check_daily_reset"):
            try:
                ts_ns = int(getattr(event, "ts_event", 0) or 0)
                self._check_daily_reset(ts_ns)
                return
            except Exception as exc:
                self.log.debug(f"Delegated daily reset failed: {type(exc).__name__}: {exc}")

        self.log.info("=== NEW TRADING DAY - Resetting daily counters ===")

        # Reset daily counters
        self._daily_trades = 0
        self._daily_pnl = 0.0

        # BUG-6 FIX: Reset execution failsafe at start of new trading day.
        # Previously, failsafe persisted forever once triggered, blocking all future trades.
        # In backtest mode, each day should start fresh. In live, overnight positions are not allowed
        # anyway (Apex rule), so resetting is safe.
        # Formula: new_day = fresh_start (no persistent halt from previous day's cutoff)
        if self._execution_failsafe_triggered:
            self.log.info("[DAILY_RESET] Clearing execution failsafe from previous day")
            self._execution_failsafe_triggered = False

        # Daily blocks now properly reset
        self._is_trading_allowed = True
        self._trading_blocked_today = False
        self._clear_pending_orders_and_brackets(reason="new_day")
        self.log.info(
            f"[DAILY_RESET] _is_trading_allowed = {self._is_trading_allowed} (daily reset)"
        )

        # Compute tick_dt once for all reset operations
        try:
            tick_dt = datetime.fromtimestamp(
                int(getattr(event, "ts_event", 0) or 0) / 1e9, tz=timezone.utc
            )
        except Exception:
            tick_dt = None

        # Reset PropFirmManager daily counters (if exists)
        if getattr(self, "_prop_firm", None):
            try:
                self._prop_firm.on_new_day(
                    current_equity=float(getattr(self, "_equity_base", 0.0)), now=tick_dt
                )
                self.log.info("PropFirmManager daily counters reset")
            except Exception as exc:
                self.log.error(f"Failed to reset PropFirmManager: {type(exc).__name__}: {exc}")

        # Reset ConsistencyTracker (if exists)
        if hasattr(self, "consistency_tracker") and self.consistency_tracker is not None:
            try:
                self.consistency_tracker.reset_daily()
                self.log.info("ConsistencyTracker daily counters reset")
            except Exception as exc:
                self.log.error(f"Failed to reset ConsistencyTracker: {type(exc).__name__}: {exc}")

        # Reset TimeConstraintManager warnings (if exists)
        if getattr(self, "_time_manager", None) is not None:
            try:
                self._time_manager.reset_daily()
                self.log.info("TimeConstraintManager warnings reset")
            except Exception as exc:
                self.log.error(
                    f"Failed to reset TimeConstraintManager: {type(exc).__name__}: {exc}"
                )

        # Reset CircuitBreaker daily metrics (if applicable)
        if getattr(self, "_circuit_breaker", None):
            try:
                # Push current equity update before reset to anchor daily_start_equity correctly
                # This ensures DD tracking is accurate even when flat at day boundary
                self._circuit_breaker.update_equity(self._equity_base, now=tick_dt)
                self._circuit_breaker.reset_daily(now=tick_dt)
                self.log.info("CircuitBreaker daily metrics reset")
            except Exception as exc:
                self.log.warning(f"Failed to reset CircuitBreaker: {type(exc).__name__}: {exc}")

        # Reset daily DD telemetry max tracker (for dd_snapshot emission)
        # IMPORTANT: Only reset daily max, NOT total (session) max
        # Trailing DD is from session HWM and should NOT reset on daily boundary
        self._telemetry_max_daily_dd_pct = 0.0
        # Do NOT reset: self._telemetry_max_total_dd_pct (session-level metric)

        self.log.info("Daily reset complete")

    # ========== Data Handlers ==========

    def on_bar(self, bar: Bar) -> None:
        """Process incoming bar data."""
        fp = getattr(self, "_fine_profiler", None)
        if fp is not None:
            fp.start("base_on_bar")

        # Guard against revision bars (partial updates). We only want final OHLC bars to
        # avoid any look-ahead from in-progress aggregation.
        if getattr(bar, "is_revision", False):
            if fp is not None:
                fp.stop("base_on_bar")
            return

        # WP0: maintain a deterministic market timestamp even if quote ticks stall.
        self._last_market_ts_ns = int(bar.ts_event)
        self._finalize_entry_terminal_if_safe(int(bar.ts_event))
        if self._execution_failsafe_triggered and self._position is not None:
            self._attempt_failsafe_flatten(now_ts_ns=int(bar.ts_event))

        # Debug logging only (avoid stdout prints in hot path)
        total_bars = len(self._ltf_bars) + len(self._mtf_bars) + len(self._htf_bars)
        if total_bars < 5 or total_bars % 100 == 0:
            if getattr(self.config, "debug_mode", False):
                self.log.debug(
                    "[BARS] Received bar=%s total_ltf=%s total_mtf=%s total_htf=%s",
                    bar.bar_type,
                    len(self._ltf_bars),
                    len(self._mtf_bars),
                    len(self._htf_bars),
                )

        # Check for daily reset
        if hasattr(self, "_check_daily_reset"):
            self._check_daily_reset(bar.ts_event)

        # WP0: bracket watchdog also runs on bars (covers quote-tick stalls).
        if (
            self._position is not None
            and not self._execution_failsafe_triggered
            and self._bracket_sl_client_order_id is not None
            and not self._bracket_sl_confirmed
        ):
            if self._bracket_submitted_ts_ns is not None:
                elapsed_ns = int(bar.ts_event) - int(self._bracket_submitted_ts_ns)
                if elapsed_ns > int(self._bracket_confirm_timeout_ns):
                    self._trigger_execution_failsafe(reason="bracket_sl_not_confirmed_timeout")
            elif self._position_opened_ts_ns is not None:
                elapsed_ns = int(bar.ts_event) - int(self._position_opened_ts_ns)
                if elapsed_ns > int(self._bracket_confirm_timeout_ns):
                    self._trigger_execution_failsafe(reason="sl_not_confirmed_after_position_open")

        # Route to appropriate storage
        if self.config.htf_bar_type and bar.bar_type == self.config.htf_bar_type:
            self._htf_bars.append(bar)
            self._trim_bars(self._htf_bars, 500)
            if fp is not None:
                fp.start("base_on_htf_bar")
            self._on_htf_bar(bar)
            if fp is not None:
                fp.stop("base_on_htf_bar")

        elif self.config.mtf_bar_type and bar.bar_type == self.config.mtf_bar_type:
            self._mtf_bars.append(bar)
            self._trim_bars(self._mtf_bars, 500)
            if fp is not None:
                fp.start("base_on_mtf_bar")
            self._on_mtf_bar(bar)
            if fp is not None:
                fp.stop("base_on_mtf_bar")

        elif self.config.ltf_bar_type and bar.bar_type == self.config.ltf_bar_type:
            self._ltf_bars.append(bar)
            self._trim_bars(self._ltf_bars, 1000)
            if fp is not None:
                fp.start("base_on_ltf_bar")
            self._on_ltf_bar(bar)
            if fp is not None:
                fp.stop("base_on_ltf_bar")

            # LTF bar is primary execution timeframe - check for signals
            has_data = self._has_enough_data()

            # Debug: Print every 100 bars (more frequent for debugging)
            if len(self._ltf_bars) % 100 == 0:
                self.log.info(
                    f"[LTF_BAR] #{len(self._ltf_bars)}: trading_allowed={self._is_trading_allowed}, has_data={has_data}, will_check_signal={self._is_trading_allowed and has_data}"
                )

            if self._is_trading_allowed and has_data:
                if fp is not None:
                    fp.start("base_check_for_signal")
                self._check_for_signal(bar)
                if fp is not None:
                    fp.stop("base_check_for_signal")

            elif not has_data and len(self._ltf_bars) % 100 == 0:
                self.log.info(
                    f"[LTF_BAR] Skipping signal check: insufficient data (need {self._min_bars_for_signal} bars, have {len(self._ltf_bars)})"
                )

        if fp is not None:
            fp.stop("base_on_bar")

    def on_quote_tick(self, tick: QuoteTick) -> None:
        """Process quote tick for spread monitoring."""
        fp = getattr(self, "_fine_profiler", None)
        if fp is not None:
            fp.start("base_on_quote_tick")

        tick_ts_ns = int(tick.ts_event)
        self._last_market_ts_ns = tick_ts_ns

        # Cache datetime conversion (hot path).
        if fp is not None:
            fp.start("tick_dt_cache")
        now_dt = self._last_tick_dt
        if now_dt is None or self._last_tick_ts_ns != tick_ts_ns:
            now_dt = datetime.fromtimestamp(tick_ts_ns / 1e9, tz=timezone.utc)
            self._last_tick_dt = now_dt
            self._last_tick_ts_ns = tick_ts_ns
        if fp is not None:
            fp.stop("tick_dt_cache")

        inst = self.instrument
        if inst is None:
            if fp is not None:
                fp.stop("base_on_quote_tick")
            return

        # Update SpreadAnalyzer with the latest quote tick
        # PERF: When no position is open, sample every 50 ticks to reduce overhead.
        # Entry gating happens on bar close (on_bar), so spread stats don't need tick-level updates.
        # At 160K ticks/day, 50-tick sampling still provides ~3200 samples/day (ample for rolling avg).
        # When a position IS open, update every tick for accurate monitoring.
        if fp is not None:
            fp.start("tick_spread_analyzer")
        if self._spread_analyzer is not None:
            position = self._position
            if position is not None or self._tick_counter % 50 == 0:
                self._spread_analyzer.handle_quote_tick(tick)
        if fp is not None:
            fp.stop("tick_spread_analyzer")

        if fp is not None:
            fp.start("tick_entry_terminal")
        self._finalize_entry_terminal_if_safe(tick_ts_ns)
        if fp is not None:
            fp.stop("tick_entry_terminal")

        if self._execution_failsafe_triggered and self._position is not None:
            if fp is not None:
                fp.start("tick_failsafe_flatten")
            self._attempt_failsafe_flatten(now_ts_ns=tick_ts_ns)
            if fp is not None:
                fp.stop("tick_failsafe_flatten")

        if self.config.debug_mode:
            # Hot path: keep numeric conversions local and avoid repeated attribute lookups.
            spread = float(tick.ask_price - tick.bid_price)
            price_inc = float(inst.price_increment)
            spread_points = int(spread / price_inc)

            if spread_points > self.config.max_spread_points:
                self.log.warning(f"Spread too wide: {spread_points} points")

        # WP0: bracket confirmation watchdog (deterministic, ts_event-driven)
        if fp is not None:
            fp.start("tick_bracket_watchdog")
        if (
            self._position is not None
            and not self._execution_failsafe_triggered
            and self._bracket_submitted_ts_ns is not None
            and self._bracket_sl_client_order_id is not None
            and not self._bracket_sl_confirmed
        ):
            # Some venues/backtest engines may not emit OrderAccepted for stop orders
            # until triggered. Treat presence in cache as confirmation.
            try:
                if self._bracket_sl_order_id is None:
                    bracket_id = self._bracket_sl_client_order_id
                    if bracket_id is None:
                        sl_order = None
                    else:
                        self._bracket_sl_order_id = ClientOrderId(bracket_id)
                        sl_order = self.cache.order(self._bracket_sl_order_id)
                else:
                    sl_order = self.cache.order(self._bracket_sl_order_id)
            except Exception:
                sl_order = None
            if sl_order is not None:
                self._bracket_sl_confirmed = True
            else:
                elapsed_ns = tick_ts_ns - int(self._bracket_submitted_ts_ns)
                if elapsed_ns > int(self._bracket_confirm_timeout_ns):
                    self._trigger_execution_failsafe(reason="bracket_sl_not_confirmed_timeout")

        # WP0: if a position is open, SL must be confirmed within a safety window.
        # This covers cases where bracket submission timestamp wasn't set (no quote ticks).
        if (
            self._position is not None
            and not self._execution_failsafe_triggered
            and self._bracket_sl_client_order_id is not None
            and not self._bracket_sl_confirmed
            and self._position_opened_ts_ns is not None
        ):
            elapsed_since_open_ns = tick_ts_ns - int(self._position_opened_ts_ns)
            if elapsed_since_open_ns > int(self._bracket_confirm_timeout_ns):
                self._trigger_execution_failsafe(reason="sl_not_confirmed_after_position_open")
        if fp is not None:
            fp.stop("tick_bracket_watchdog")

        self._tick_counter += 1

        if fp is not None:
            fp.start("tick_compute_equity")
        equity = self._compute_equity_from_tick(tick)
        if fp is not None:
            fp.stop("tick_compute_equity")
        if equity is None:
            if fp is not None:
                fp.stop("base_on_quote_tick")
            return

        # Intrabar drawdown monitoring (mark-to-market)
        position = self._position

        if fp is not None:
            fp.start("tick_dd_tracker")
        drawdown_tracker = getattr(self, "_drawdown_tracker", None)
        if drawdown_tracker is not None and position is not None:
            analysis = drawdown_tracker.update(equity, now=now_dt)
            self._apply_drawdown_limits(analysis)
            if not self._is_trading_allowed:
                if fp is not None:
                    fp.stop("tick_dd_tracker")
                    fp.stop("base_on_quote_tick")
                return
        if fp is not None:
            fp.stop("tick_dd_tracker")

        # Prop-firm manager intrabar enforcement (uses conservative MTM equity)
        if fp is not None:
            fp.start("tick_prop_firm")
        prop_firm = getattr(self, "_prop_firm", None)
        if prop_firm is not None and position is not None:
            try:
                prop_firm.update_equity(equity, now=now_dt)

                # Ensure compliance is sufficient: it checks DD protection and triggers
                # hard stop behavior when configured.
                state = prop_firm.ensure_compliance(now=now_dt)

                # Fast-path: if compliance reports trading not allowed, halt immediately.
                if not state.is_trading_allowed:
                    self._trigger_execution_failsafe(reason="prop_firm_dd_breach")
                    if fp is not None:
                        fp.stop("tick_prop_firm")
                        fp.stop("base_on_quote_tick")
                    return

                # Consistency gate (daily profit cap) is separate; keep it explicit.
                if not prop_firm.can_trade(now=now_dt):
                    self._trigger_execution_failsafe(reason="prop_firm_consistency_block")
                    if fp is not None:
                        fp.stop("tick_prop_firm")
                        fp.stop("base_on_quote_tick")
                    return

            except Exception as exc:
                # Fail closed: if compliance check explodes, do not keep trading.
                self._trigger_execution_failsafe(
                    reason=f"prop_firm_intrabar_exception: {type(exc).__name__}"
                )
                if fp is not None:
                    fp.stop("tick_prop_firm")
                    fp.stop("base_on_quote_tick")
                return
        if fp is not None:
            fp.stop("tick_prop_firm")

        # Circuit breaker intrabar enforcement (uses conservative MTM equity)
        # IMPORTANT: CircuitBreaker `can_trade()` can be False due to cooldowns after consecutive
        # losses (LEVEL_1/2) or temporary risk pauses. That should NOT trigger an emergency
        # flatten + HALT while a position is open; it's an *entry* gate.
        # Only hard lockdown states should force an emergency flatten.
        circuit_breaker = getattr(self, "_circuit_breaker", None)
        if circuit_breaker is not None and position is not None:
            try:
                if fp is not None:
                    fp.start("cb_update_equity")
                (
                    cb_level,
                    daily_dd_pct,
                    total_dd_pct,
                    peak_equity,
                    daily_start_equity,
                ) = circuit_breaker.update_equity_and_get_level_and_drawdown(equity, now=now_dt)
                if fp is not None:
                    fp.stop("cb_update_equity")

                # Emit dd_snapshot telemetry when a new max DD is reached
                # This supplements circuit_state (which only fires on level change)
                # and ensures Apex DD validation never misses peak DD values.
                if fp is not None:
                    fp.start("tick_cb_telemetry")
                telemetry = getattr(self, "_telemetry", None)
                if telemetry and getattr(self.config, "telemetry_capture_circuit", True):
                    emit_snapshot = False

                    # Emit when total_dd exceeds previous max by > 1e-6
                    if total_dd_pct > self._telemetry_max_total_dd_pct + 1e-6:
                        self._telemetry_max_total_dd_pct = total_dd_pct
                        emit_snapshot = True

                    # Emit when daily_dd exceeds previous max by > 1e-6
                    if daily_dd_pct > self._telemetry_max_daily_dd_pct + 1e-6:
                        self._telemetry_max_daily_dd_pct = daily_dd_pct
                        emit_snapshot = True

                    if emit_snapshot:
                        snapshot_payload: dict[str, object] = {
                            "ts": now_dt.isoformat(),
                            "equity": equity,
                            "daily_dd": daily_dd_pct,
                            "total_dd": total_dd_pct,
                            "peak_equity": peak_equity,
                            "daily_start_equity": daily_start_equity,
                            "source": "circuit_breaker",
                        }
                        telemetry.emit("dd_snapshot", snapshot_payload)
                if fp is not None:
                    fp.stop("tick_cb_telemetry")

                if cb_level >= CircuitBreakerLevel.LEVEL_4_CRITICAL:
                    self._trigger_execution_failsafe(
                        reason=f"circuit_breaker_lockdown:{cb_level.name}"
                    )
                    if fp is not None:
                        fp.stop("base_on_quote_tick")
                    return
            except Exception as exc:
                self._trigger_execution_failsafe(
                    reason=f"circuit_breaker_intrabar_exception: {type(exc).__name__}"
                )
                if fp is not None:
                    fp.stop("base_on_quote_tick")
                return

        if fp is not None:
            fp.stop("base_on_quote_tick")

    # ========== Position Event Handlers ==========

    def on_position_opened(self, event: PositionOpened) -> None:
        """Handle position opened event."""
        cache = getattr(self, "cache", None)
        if cache is not None and hasattr(cache, "position"):
            self._position = cache.position(event.position_id)

        self._daily_trades += 1
        # qty calculation moved to execution cost section (avoid duplicate code)

        # Bind lifecycle to the new position and reset bracket confirmation state
        self._active_position_id = str(event.position_id)
        self._position_opened_ts_ns = int(getattr(event, "ts_event", 0) or 0) or None
        self._bracket_sl_confirmed = False
        self._bracket_tp_confirmed = False

        if self._position is None:
            self._trigger_execution_failsafe(reason="position_opened_but_cache_position_missing")
            return

        # Cache position attributes for hot-path equity calculations.
        entry_obj = getattr(self._position, "avg_px_open", 0.0)
        qty_obj = getattr(self._position, "quantity", 0.0)
        self._pos_cache_entry_px = (
            float(entry_obj.as_double()) if hasattr(entry_obj, "as_double") else float(entry_obj)
        )
        self._pos_cache_qty = (
            float(qty_obj.as_double()) if hasattr(qty_obj, "as_double") else float(qty_obj)
        )
        self._pos_cache_side = self._position.side
        self._pos_cache_point_value = float(self._instrument_point_value_per_unit())

        # Entry lock: once a position is opened (and cache resolved), clear the pending entry gate.
        # Keep local copies for diagnostics before clearing.
        entry_cid_at_open = self._entry_client_order_id
        entry_terminal_reason_at_open = self._entry_terminal_reason
        self._entry_client_order_id = None
        self._entry_terminal_ts_ns = None
        self._entry_terminal_reason = None

        self.log.info(
            f"Position OPENED: {self._position.side} "
            f"@ {self._position.avg_px_open} "
            f"(Daily trades: {self._daily_trades})"
        )

        # Capture whether we had protective orders staged at the time the position opened.
        had_pending_protection = bool(self._pending_sl or self._pending_tp)

        # Submit SL/TP orders if pending
        if had_pending_protection:
            self._submit_bracket_orders()

            # WP0: SL is mandatory safety protection; if we failed to submit it, fail-safe immediately.
            if self._bracket_sl_client_order_id is None:
                self._trigger_execution_failsafe(reason="position_opened_without_sl")
                return
        else:
            # WP0: Never allow an open position without protective orders staged.
            opening_oid = getattr(event, "opening_order_id", None)
            try:
                self.log.error(
                    f"[WP0] Position opened without staged protection: "
                    f"opening_order_id={str(opening_oid) if opening_oid is not None else None} "
                    f"entry_client_order_id={entry_cid_at_open} "
                    f"entry_terminal_reason={entry_terminal_reason_at_open}"
                )
            except Exception:
                # Never let diagnostics break the WP0 fail-closed invariant.
                pass
            self._trigger_execution_failsafe(reason="position_opened_without_protective_orders")
            return

        # Apply strategy-side execution costs on entry only for components not already
        # reflected in the engine account (fee_model) or fill prices (fill_model).
        include_slippage = not bool(getattr(self.config, "slippage_in_fills", False))
        include_commission = not bool(getattr(self.config, "fees_in_account", False))
        if self._execution_model and (include_slippage or include_commission):
            # Handle avg_px_open being Price or float
            avg_price = (
                self._position.avg_px_open.as_double()
                if hasattr(self._position.avg_px_open, "as_double")
                else float(self._position.avg_px_open)
            )
            qty = (
                self._position.quantity.as_double()
                if hasattr(self._position.quantity, "as_double")
                else float(self._position.quantity)
            )

            open_cost = self._calculate_execution_cost(
                side="buy" if self._position.side == PositionSide.LONG else "sell",
                price=avg_price,
                quantity=qty,
                include_slippage=include_slippage,
                include_commission=include_commission,
            )
            if open_cost > 0:
                self._daily_pnl -= open_cost
                self._equity_base -= open_cost
                if isinstance(self._fill_costs, dict):
                    self._fill_costs[str(event.position_id)] = open_cost
                self.log.info(f"Execution cost (open): -${open_cost:.2f}")

        # Check if max daily trades reached
        if self._daily_trades >= self.config.max_trades_per_day:
            self._is_trading_allowed = False
            self.log.warning(
                f"[BLOCKED] _is_trading_allowed = False (max daily trades: {self._daily_trades})"
            )

    def on_position_changed(self, event: PositionChanged) -> None:
        """Handle position changed event.

        BUG-5 FIX: When position quantity increases (additional partial fills),
        the SL order must be updated to match the new position quantity.
        Otherwise, some units remain unprotected.
        """
        cache = getattr(self, "cache", None)
        if cache is None or not hasattr(cache, "position"):
            return

        # Capture old quantity before updating position
        old_qty: float = 0.0
        if self._position is not None:
            old_qty = (
                self._position.quantity.as_double()
                if hasattr(self._position.quantity, "as_double")
                else float(self._position.quantity)
            )

        # Update position from cache
        self._position = cache.position(event.position_id)

        if self._position is None:
            return

        # Update hot-path caches (position may have scaled in/out).
        entry_obj = getattr(self._position, "avg_px_open", 0.0)
        qty_obj = getattr(self._position, "quantity", 0.0)
        self._pos_cache_entry_px = (
            float(entry_obj.as_double()) if hasattr(entry_obj, "as_double") else float(entry_obj)
        )
        self._pos_cache_qty = (
            float(qty_obj.as_double()) if hasattr(qty_obj, "as_double") else float(qty_obj)
        )
        self._pos_cache_side = self._position.side
        if self._pos_cache_point_value is None:
            self._pos_cache_point_value = float(self._instrument_point_value_per_unit())

        # Get new quantity
        new_qty = (
            self._position.quantity.as_double()
            if hasattr(self._position.quantity, "as_double")
            else float(self._position.quantity)
        )

        # BUG-5 FIX: If quantity increased and we have an SL order, update it
        # Formula: qty_delta = new_qty - old_qty
        # Example: old_qty=50, new_qty=100 -> delta=50 (positive means increase)
        qty_delta = new_qty - old_qty
        if qty_delta > 0 and self._bracket_sl_client_order_id is not None:
            self._sync_sl_quantity_on_position_increase(new_qty)

    def on_position_closed(self, event: PositionClosed) -> None:
        """Handle position closed event."""
        if self._position and self._position.id == event.position_id:
            pnl = float(self._position.realized_pnl)
            # Handle quantity being Quantity or float
            position_qty = self._position.quantity
            qty = (
                position_qty.as_double()
                if hasattr(position_qty, "as_double")
                else float(position_qty)
            )

            # Handle avg_px_close/avg_px_open being Price or float
            close_px = (
                getattr(self._position, "avg_px_close", self._position.avg_px_open)
                if hasattr(self._position, "avg_px_close")
                else self._position.avg_px_open
            )
            close_price = (
                close_px.as_double() if hasattr(close_px, "as_double") else float(close_px)
            )

            # Apply strategy-side execution costs on close only for components not already
            # reflected in the engine account (fee_model) or fill prices (fill_model).
            close_cost = 0.0
            include_slippage = not bool(getattr(self.config, "slippage_in_fills", False))
            include_commission = not bool(getattr(self.config, "fees_in_account", False))
            if self._execution_model and (include_slippage or include_commission):
                close_cost = self._calculate_execution_cost(
                    side="sell" if self._position.side == PositionSide.LONG else "buy",
                    price=close_price,
                    quantity=qty,
                    include_slippage=include_slippage,
                    include_commission=include_commission,
                )
            net_pnl = pnl - close_cost

            self._daily_pnl += net_pnl
            self._equity_base += net_pnl

            # Track realized PnL for telemetry/metrics and adaptive sizing.
            # BUG-MEM-001: Bound history growth in long-running sessions.
            history = getattr(self, "_trade_pnl_history", None)
            if isinstance(history, list):
                history.append(net_pnl)
                maxlen = int(getattr(self.config, "trade_pnl_history_maxlen", 2000))
                if maxlen > 0 and len(history) > maxlen:
                    del history[:-maxlen]

            if getattr(self, "_position_sizer", None):
                try:
                    self._position_sizer.register_trade_result(net_pnl)
                except Exception as exc:
                    self.log.debug(
                        f"Position sizer trade result update failed: {type(exc).__name__}: {exc}"
                    )

            self.log.info(
                f"Position CLOSED with PnL: {pnl:.2f} (net {-close_cost:.2f} costs applied) "
                f"(Daily PnL: {self._daily_pnl:.2f})"
            )

            if isinstance(self._fill_costs, dict) and str(event.position_id) in self._fill_costs:
                # Keep open cost only for reporting; already applied on entry
                self._fill_costs.pop(str(event.position_id), None)

            # Update drawdown tracker with realized PnL
            if getattr(self, "_drawdown_tracker", None):
                ts_ns = getattr(event, "ts_event", None)
                if not (isinstance(ts_ns, int) and ts_ns > 0):
                    ts_ns = self._last_market_ts_ns

                now_dt: datetime | None
                if isinstance(ts_ns, int) and ts_ns > 0:
                    now_dt = datetime.fromtimestamp(ts_ns / 1e9, tz=timezone.utc)
                else:
                    # Determinism fallback: reuse last known tracker timestamp if available.
                    try:
                        last = self._drawdown_tracker.get_history(last_n=1)
                        now_dt = last[0].timestamp if last else None
                    except Exception:
                        now_dt = None

                analysis = self._drawdown_tracker.update(self._equity_base, pnl=net_pnl, now=now_dt)
                self._apply_drawdown_limits(analysis)

            # Prop-firm tracking: feed realized result
            if getattr(self, "_prop_firm", None):
                try:
                    ts_ns = getattr(event, "ts_event", None)
                    if not (isinstance(ts_ns, int) and ts_ns > 0):
                        ts_ns = self._last_market_ts_ns

                    prop_event_dt: datetime | None
                    if isinstance(ts_ns, int) and ts_ns > 0:
                        prop_event_dt = datetime.fromtimestamp(ts_ns / 1e9, tz=timezone.utc)
                    else:
                        prop_event_dt = None

                    self._prop_firm.register_trade_close(
                        contracts=qty,
                        profit=net_pnl,
                        now=prop_event_dt,
                        equity=float(self._equity_base),
                    )
                except Exception as exc:
                    self.log.debug(f"Prop firm update failed on close: {type(exc).__name__}: {exc}")

            # Circuit breaker trade result
            if getattr(self, "_circuit_breaker", None):
                try:
                    ts_ns = getattr(event, "ts_event", None)
                    if not (isinstance(ts_ns, int) and ts_ns > 0):
                        ts_ns = self._last_market_ts_ns

                    cb_event_dt: datetime | None
                    if isinstance(ts_ns, int) and ts_ns > 0:
                        cb_event_dt = datetime.fromtimestamp(ts_ns / 1e9, tz=timezone.utc)
                    else:
                        cb_event_dt = None

                    # Update equity with realized balance BEFORE registering trade result
                    # This keeps DD consistent after position close (no unrealized component).
                    self._circuit_breaker.update_equity(self._equity_base, now=cb_event_dt)

                    self._circuit_breaker.register_trade_result(
                        pnl=net_pnl, is_win=net_pnl > 0, now=cb_event_dt
                    )
                except Exception as exc:
                    self.log.debug(
                        f"Circuit breaker trade update failed: {type(exc).__name__}: {exc}"
                    )

            # HBS (Human Behavior Simulator) trade result hook
            if getattr(self, "_hbs", None):
                try:
                    # In backtest mode, HBS requires a deterministic current_time.
                    # Prefer event timestamps from the exchange-simulated clock.
                    ts_ns = (
                        getattr(event, "ts_event", None)
                        or getattr(event, "ts_closed", None)
                        or getattr(event, "ts_last", None)
                        or getattr(event, "ts_opened", None)
                    )
                    if not (isinstance(ts_ns, int) and ts_ns > 0):
                        ts_ns = self._last_market_ts_ns

                    hbs_event_dt: datetime | None
                    if isinstance(ts_ns, int) and ts_ns > 0:
                        hbs_event_dt = datetime.fromtimestamp(ts_ns / 1e9, tz=timezone.utc)
                    else:
                        hbs_event_dt = None

                    self._hbs.on_trade_result(
                        win=net_pnl > 0,
                        pnl=net_pnl,
                        current_time=hbs_event_dt,
                    )
                except Exception as exc:
                    self.log.debug(f"HBS trade result update failed: {type(exc).__name__}: {exc}")

            # Check daily loss limit as % of balance
            account_balance = float(
                getattr(self.config, "account_balance", self._equity_base or 100000.0)
            )
            daily_limit_pct = float(
                getattr(
                    self.config,
                    "daily_loss_limit_pct",
                    getattr(self.config, "max_daily_loss_pct", 5.0),
                )
            )
            if 0 < daily_limit_pct <= 1.0:
                daily_limit_pct *= 100.0
            daily_limit_pct = min(daily_limit_pct, 3.0)

            if account_balance > 0:
                # Formula: daily_dd_pct = max(0, -daily_pnl) / account_balance * 100
                # Example: daily_pnl=-1000, balance=50000 -> 2.0%
                daily_loss = max(0.0, -float(self._daily_pnl))
                daily_dd_pct = daily_loss / account_balance * 100.0
                if not (0.0 <= daily_dd_pct <= 100.0):
                    raise ValueError(f"Invalid daily DD%: {daily_dd_pct}")
                if daily_dd_pct >= daily_limit_pct:
                    self._is_trading_allowed = False
                    self.log.error(
                        f"[BLOCKED] _is_trading_allowed = False (daily DD breach: {daily_dd_pct:.2f}% >= {daily_limit_pct:.2f}%)"
                    )

            self._position = None
            self._active_position_id = None
            self._position_opened_ts_ns = None
            self._pos_cache_entry_px = None
            self._pos_cache_qty = None
            self._pos_cache_point_value = None
            self._pos_cache_side = None

    # ========== Trading Methods ==========

    def _enter_long(
        self, quantity: Quantity, sl_price: Price | None = None, tp_price: Price | None = None
    ) -> None:
        """Enter a long position."""
        if self._position is not None or self._entry_client_order_id is not None:
            self.log.warning("Cannot enter long - position already exists or entry pending")
            return

        # Partial fill simulation (single source of truth: _simulate_partial_fill)
        quantity = self._simulate_partial_fill(quantity, side="BUY")

        if quantity.as_double() <= 0:
            self.log.warning("Partial fill simulation resulted in zero quantity; skipping order")
            return

        # WP0: Never allow an entry without an SL staged.
        if sl_price is None:
            self.log.error("[WP0] Refusing to enter LONG without SL price")
            return

        # Native bracket mode: submit atomic bracket order
        if getattr(self.config, "use_native_brackets", False):
            self._submit_native_bracket(
                order_side=OrderSide.BUY,
                quantity=quantity,
                sl_price=sl_price,
                tp_price=tp_price,
            )
            self.log.info(f"Entering LONG (native bracket) with qty={quantity}")
            return

        # Legacy mode: separate entry + bracket orders
        # Queue SL/TP orders BEFORE submitting the entry order.
        # In simulated/backtest execution, an IOC market order may fill synchronously and
        # immediately trigger `on_position_opened` during `submit_order()`. If we stage after
        # `submit_order`, the position can open without protection and triggers a failsafe.
        self._pending_sl = sl_price
        self._pending_tp = tp_price

        twap = self._twap_exec_for_entry()

        # Create market order
        order = self.order_factory.market(
            instrument_id=self.config.instrument_id,
            order_side=OrderSide.BUY,
            quantity=quantity,
            time_in_force=TimeInForce.IOC,
            exec_algorithm_id=twap[0] if twap is not None else None,
            exec_algorithm_params=twap[1] if twap is not None else None,
        )

        # Track entry order id (for IOC reject/cancel cleanup)
        self._entry_client_order_id = str(order.client_order_id)
        self._entry_terminal_ts_ns = None
        self._entry_terminal_reason = None

        try:
            self.submit_order(order)
        except Exception as exc:
            # If entry submission failed, clear staged protection so it can't leak to the next attempt.
            self._clear_pending_orders_and_brackets(
                reason=f"entry_submit_failed:{type(exc).__name__}"
            )
            raise

        self.log.info(f"Entering LONG with qty={quantity} (entry_id={self._entry_client_order_id})")

    def _enter_short(
        self, quantity: Quantity, sl_price: Price | None = None, tp_price: Price | None = None
    ) -> None:
        """Enter a short position."""
        if self._position is not None or self._entry_client_order_id is not None:
            self.log.warning("Cannot enter short - position already exists or entry pending")
            return

        # Partial fill simulation (single source of truth: _simulate_partial_fill)
        quantity = self._simulate_partial_fill(quantity, side="SELL")

        if quantity.as_double() <= 0:
            self.log.warning("Partial fill simulation resulted in zero quantity; skipping order")
            return

        # WP0: Never allow an entry without an SL staged.
        if sl_price is None:
            self.log.error("[WP0] Refusing to enter SHORT without SL price")
            return

        # Native bracket mode: submit atomic bracket order
        if getattr(self.config, "use_native_brackets", False):
            self._submit_native_bracket(
                order_side=OrderSide.SELL,
                quantity=quantity,
                sl_price=sl_price,
                tp_price=tp_price,
            )
            self.log.info(f"Entering SHORT (native bracket) with qty={quantity}")
            return

        # Legacy mode: separate entry + bracket orders
        # Queue SL/TP orders BEFORE submitting the entry order.
        # See `_enter_long` for rationale (synchronous fills in backtest/sim).
        self._pending_sl = sl_price
        self._pending_tp = tp_price

        twap = self._twap_exec_for_entry()

        order = self.order_factory.market(
            instrument_id=self.config.instrument_id,
            order_side=OrderSide.SELL,
            quantity=quantity,
            time_in_force=TimeInForce.IOC,
            exec_algorithm_id=twap[0] if twap is not None else None,
            exec_algorithm_params=twap[1] if twap is not None else None,
        )

        # Track entry order id (for IOC reject/cancel cleanup)
        self._entry_client_order_id = str(order.client_order_id)
        self._entry_terminal_ts_ns = None
        self._entry_terminal_reason = None

        try:
            self.submit_order(order)
        except Exception as exc:
            self._clear_pending_orders_and_brackets(
                reason=f"entry_submit_failed:{type(exc).__name__}"
            )
            raise

        self.log.info(
            f"Entering SHORT with qty={quantity} (entry_id={self._entry_client_order_id})"
        )

    def _close_position(self) -> None:
        """Close current position."""
        if self._position is None:
            return

        # reduce_only=True ensures close intents never flip into a new position.
        self.close_position(self._position, reduce_only=True)
        self.log.info("Closing position")

    def _finalize_entry_terminal_if_safe(self, now_ts_ns: int) -> None:
        if self._entry_terminal_reason is None or self._entry_terminal_ts_ns is None:
            return
        if self._position is not None or self._active_position_id is not None:
            self._entry_terminal_ts_ns = None
            self._entry_terminal_reason = None
            return

        grace_ns = int(getattr(self.config, "entry_terminal_grace_ns", 5_000_000_000))
        elapsed_ns = int(now_ts_ns) - int(self._entry_terminal_ts_ns)
        if elapsed_ns <= grace_ns:
            return

        self._clear_pending_orders_and_brackets(reason=self._entry_terminal_reason)

    def _clear_pending_orders_and_brackets(self, reason: str) -> None:
        # Clear pending SL/TP prices
        self._pending_sl = None
        self._pending_tp = None

        # Clear lifecycle tracking
        self._entry_client_order_id = None
        self._entry_terminal_ts_ns = None
        self._entry_terminal_reason = None
        self._bracket_sl_client_order_id = None
        self._bracket_sl_order_id = None
        self._bracket_tp_client_order_id = None
        self._bracket_sl_confirmed = False
        self._bracket_tp_confirmed = False
        self._bracket_tp_expected = False
        self._active_position_id = None
        self._active_bracket_list_id = None  # Native bracket order list ID
        self._entry_terminal_ts_ns = None
        self._entry_terminal_reason = None
        self._position_opened_ts_ns = None
        self._bracket_submitted_ts_ns = None

        if getattr(self.config, "debug_mode", False):
            self.log.debug(f"[WP0] cleared pending brackets ({reason})")

    def _twap_exec_for_entry(self) -> tuple[ExecAlgorithmId, dict[str, Any]] | None:
        if not bool(getattr(self.config, "twap_enabled", False)):
            return None

        # Guardrail: never allow TWAP orders when we are blocked / failsafe triggered.
        if self._execution_failsafe_triggered or self._trading_blocked_today:
            return None

        horizon_secs = float(getattr(self.config, "twap_horizon_secs", 0.0))
        interval_secs = float(getattr(self.config, "twap_interval_secs", 0.0))

        if not (horizon_secs > 0.0 and interval_secs > 0.0 and interval_secs <= horizon_secs):
            # Fail-closed: TWAP misconfiguration should never silently create unsafe behavior.
            self._trigger_execution_failsafe(reason="twap_invalid_params")
            return None

        return (
            ExecAlgorithmId("TWAP"),
            {"horizon_secs": horizon_secs, "interval_secs": interval_secs},
        )

    def _trigger_execution_failsafe(self, reason: str) -> None:
        """Fail-safe: cancel orders, flatten positions, and halt trading.

        BUG-13 FIX: Try reduce_only=True first, then reduce_only=False on failure.
        """
        if self._execution_failsafe_triggered:
            return
        self._execution_failsafe_triggered = True
        self._failsafe_close_retry_count = 0
        self._failsafe_close_last_attempt_ts_ns = None

        self.log.error(f"[FAILSAFE] {reason} -> cancel_all_orders + close_all_positions + HALT")
        try:
            self.cancel_all_orders(self.config.instrument_id)
        except Exception as exc:
            self.log.debug(f"[FAILSAFE] cancel_all_orders failed: {type(exc).__name__}: {exc}")

        self._attempt_failsafe_flatten(now_ts_ns=self._last_market_ts_ns)

        self._is_trading_allowed = False
        self._trading_blocked_today = True

        self._clear_pending_orders_and_brackets(reason=reason)

    def _attempt_failsafe_flatten(self, *, now_ts_ns: int | None) -> None:
        if self._position is None:
            return

        if now_ts_ns is not None:
            if (
                self._failsafe_close_last_attempt_ts_ns is not None
                and (now_ts_ns - self._failsafe_close_last_attempt_ts_ns)
                < self._failsafe_close_retry_interval_ns
            ):
                return
            self._failsafe_close_last_attempt_ts_ns = int(now_ts_ns)

        if self._failsafe_close_retry_count >= self._failsafe_close_max_attempts:
            self.log.error(
                f"[FAILSAFE] flatten attempts exceeded max={self._failsafe_close_max_attempts}; giving up"
            )
            return

        self._failsafe_close_retry_count += 1
        self.log.error(
            f"[FAILSAFE] flatten attempt #{self._failsafe_close_retry_count} (reduce_only=True)"
        )

        try:
            self.close_all_positions(self.config.instrument_id, reduce_only=True)
        except Exception as exc:
            self.log.debug(
                f"[FAILSAFE] close_all_positions (reduce_only=True) failed: {type(exc).__name__}: {exc}"
            )

    # ========== TradingState Machine (Apex Compliance) ==========

    def _set_trading_state(self, state: TradingState, reason: str) -> None:
        """Set RiskEngine trading state with logging.

        TradingState controls order flow at the RiskEngine level:
        - ACTIVE: Normal operation, all orders allowed
        - REDUCING: Only position-reducing orders allowed (cancels + exits)
        - HALTED: All orders blocked except cancels

        This integrates with Apex compliance time gates and DD thresholds.
        """
        # RiskEngine handle is injected at the engine-layer in backtests (see scripts/backtest/run_backtest.py).
        # In other environments, the handle may be absent; in that case, we only log intent.
        try:
            risk_engine = getattr(self, "_risk_engine", None)
            if risk_engine is None:
                trader = getattr(self, "trader", None)
                if trader is not None:
                    risk_engine = getattr(trader, "risk_engine", None)

            if risk_engine is not None:
                desired_state = state
                # Safety: HALTED may block order submits; never HALT while in-position.
                if desired_state == TradingState.HALTED and self._position is not None:
                    desired_state = TradingState.REDUCING

                current_raw = getattr(risk_engine, "trading_state", None)
                try:
                    if isinstance(current_raw, int):
                        current_state: TradingState | None = TradingState(current_raw)
                    elif isinstance(current_raw, TradingState):
                        current_state = current_raw
                    else:
                        current_state = None
                except Exception:
                    current_state = None

                if current_state != desired_state:
                    risk_engine.set_trading_state(desired_state)
                    self.log.warning(
                        f"[TRADING_STATE] {current_state} -> {desired_state.name}: {reason}"
                    )
                return

            self.log.info(f"[TRADING_STATE] (no risk_engine) Would set {state.name}: {reason}")
        except Exception as exc:
            self.log.debug(f"[TRADING_STATE] Failed to set {state.name}: {exc}")

    def _get_trading_state(self) -> TradingState:
        """Get current RiskEngine trading state.

        Returns ACTIVE if risk engine is not available (e.g., backtest).
        """
        try:
            risk_engine = getattr(self, "_risk_engine", None)
            if risk_engine is None:
                trader = getattr(self, "trader", None)
                if trader is not None:
                    risk_engine = getattr(trader, "risk_engine", None)

            if risk_engine is not None:
                raw = getattr(risk_engine, "trading_state", None)
                if raw is None:
                    return TradingState.ACTIVE
                try:
                    if isinstance(raw, int):
                        return TradingState(raw)
                    if isinstance(raw, TradingState):
                        return raw
                except Exception:
                    return TradingState.ACTIVE
        except Exception:
            pass
        return TradingState.ACTIVE

    def _check_dd_trading_state(self) -> None:
        """Check DD thresholds and update trading state.

        Apex compliance thresholds:
        - Daily DD >= 2.5%: Set REDUCING (only exits allowed)
        - Daily DD >= 3.0% OR Trailing DD >= 4.0%: Set HALTED

        Note: This method only updates the TradingState. Emergency close and
        failsafe logic is handled separately in _apply_drawdown_limits to
        maintain proper separation of concerns.

        Formula example:
        - trailing_dd_pct = (hwm - current_equity) / hwm * 100
        - Example: hwm=52000, equity=50000 → (52000-50000)/52000*100 = 3.85%
        """
        # Get DD values from tracker
        daily_dd = getattr(self._drawdown_tracker, "get_daily_drawdown_pct", lambda: 0.0)()
        trailing_dd = getattr(self._drawdown_tracker, "get_total_drawdown_pct", lambda: 0.0)()

        # Validate DD values are in expected range
        if not (0 <= daily_dd <= 100) or not (0 <= trailing_dd <= 100):
            self.log.warning(
                f"[DD_STATE] Invalid DD values: daily={daily_dd}, trailing={trailing_dd}"
            )
            return

        # HALTED: DD breach - immediate halt
        # Trailing DD >= 4.0% OR Daily DD >= 3.0%
        if trailing_dd >= 4.0 or daily_dd >= 3.0:
            self._set_trading_state(
                TradingState.HALTED,
                f"DD breach: daily={daily_dd:.2f}%, trailing={trailing_dd:.2f}%",
            )
            return

        # REDUCING: DD warning - only position-reducing orders
        # Daily DD >= 2.5%
        if daily_dd >= 2.5:
            self._set_trading_state(TradingState.REDUCING, f"DD warning: daily={daily_dd:.2f}%")
            return

        # ACTIVE: DD within safe limits (restore if previously restricted)
        current_state = self._get_trading_state()
        if current_state != TradingState.ACTIVE:
            # Only restore to ACTIVE if DD is well below thresholds (hysteresis)
            if daily_dd < 2.0 and trailing_dd < 3.5:
                self._set_trading_state(TradingState.ACTIVE, "DD recovered below thresholds")

    # ========== Timer Callbacks (Periodic Checks) ==========

    def _on_dd_check_timer(self, event: Any) -> None:
        """Periodic DD check callback.

        Called every 30 seconds to check DD thresholds even when no market
        events are arriving (e.g., during low-liquidity periods or feed stalls).
        """
        try:
            self._check_dd_trading_state()
        except Exception as exc:
            self.log.debug(f"[TIMER] DD check failed: {exc}")

    def _on_time_gate_timer(self, event: Any) -> None:
        """Periodic time gate check callback.

        Called every 60 seconds to enforce Apex time gates:
        - 4:30 PM ET: Set REDUCING (no new trades)
        - 4:55 PM ET: Set HALTED + emergency close

        Uses event timestamp for deterministic behavior in backtest.
        """
        try:
            # Get current time from event or clock
            ts_ns = getattr(event, "ts_event", None) or self.clock.timestamp_ns()

            # Convert to ET for time gate checks
            try:
                import zoneinfo

                et_tz: Any = zoneinfo.ZoneInfo("America/New_York")
            except ImportError:
                import pytz

                et_tz = pytz.timezone("America/New_York")

            now_utc = datetime.fromtimestamp(ts_ns / 1e9, tz=timezone.utc)
            now_et = now_utc.astimezone(et_tz)
            hour, minute = now_et.hour, now_et.minute

            # 4:55 PM ET: Emergency close
            if hour == 16 and minute >= 55:
                if not self._execution_failsafe_triggered:
                    self._set_trading_state(TradingState.HALTED, "4:55 PM ET - emergency close")
                    self._trigger_execution_failsafe(reason="time_gate_emergency_close")
                return

            # 4:30 PM ET: No new trades
            if hour == 16 and minute >= 30:
                current_state = self._get_trading_state()
                if current_state == TradingState.ACTIVE:
                    self._set_trading_state(TradingState.REDUCING, "4:30 PM ET - no new trades")
                return

        except Exception as exc:
            self.log.debug(f"[TIMER] Time gate check failed: {exc}")

    # ========== Persistence (Phase 14) ==========

    def on_save(self) -> dict[str, bytes]:
        payload: dict[str, Any] = {
            "v": int(self._persistence_schema_version),
            "day_key": self._persistence_day_key.isoformat() if self._persistence_day_key else None,
            "is_trading_allowed": bool(self._is_trading_allowed),
            "trading_blocked_today": bool(self._trading_blocked_today),
            "execution_failsafe_triggered": bool(self._execution_failsafe_triggered),
            "failsafe_close_retry_count": int(self._failsafe_close_retry_count),
            "failsafe_close_last_attempt_ts_ns": self._failsafe_close_last_attempt_ts_ns,
            "last_market_ts_ns": self._last_market_ts_ns,
            "current_regime": getattr(self._current_regime, "regime", None)
            if self._current_regime is not None
            else None,
        }

        if self._entry_client_order_id is not None:
            payload["entry_client_order_id"] = str(self._entry_client_order_id)
        if self._bracket_sl_client_order_id is not None:
            payload["bracket_sl_client_order_id"] = str(self._bracket_sl_client_order_id)
        if self._bracket_tp_client_order_id is not None:
            payload["bracket_tp_client_order_id"] = str(self._bracket_tp_client_order_id)
        if self._active_bracket_list_id is not None:
            payload["active_bracket_list_id"] = str(self._active_bracket_list_id)

        if getattr(self, "_time_manager", None) is not None:
            tm = self._time_manager
            try:
                payload["time_manager"] = {
                    "issued": sorted(list(getattr(tm, "_issued", set()))),
                    "close_orders_submitted": bool(getattr(tm, "_close_orders_submitted", False)),
                    "close_submitted_ts_ns": getattr(tm, "_close_submitted_ts_ns", None),
                    "flatten_complete": bool(getattr(tm, "_flatten_complete", False)),
                    "close_retry_count": int(getattr(tm, "_close_retry_count", 0)),
                    "close_order_ids": [str(x) for x in getattr(tm, "_close_order_ids", [])],
                }
            except Exception:
                # Fail-open for telemetry only; time gates are enforced from clock on restore.
                pass

        return {"base": _encode_json_bytes(payload)}

    def on_load(self, state: dict[str, bytes]) -> None:
        try:
            raw = state.get("base")
            if raw is None:
                return
            payload = _decode_json_bytes(raw)

            if int(payload.get("v", 0)) != int(self._persistence_schema_version):
                raise ValueError("Unsupported persistence schema version")

            # Restore timestamps first so day_key validation can run.
            loaded_last_ts = payload.get("last_market_ts_ns")
            self._last_market_ts_ns = int(loaded_last_ts) if loaded_last_ts is not None else None

            # Validate day boundary (ET) if possible.
            loaded_day = payload.get("day_key")
            if isinstance(loaded_day, str):
                loaded_day_key = date.fromisoformat(loaded_day)
            else:
                loaded_day_key = None

            current_day_key = (
                _et_day_key(self._last_market_ts_ns)
                if self._last_market_ts_ns is not None
                else None
            )
            if (
                loaded_day_key is not None
                and current_day_key is not None
                and loaded_day_key != current_day_key
            ):
                raise ValueError("Persistence state from different ET day")

            self._persistence_day_key = current_day_key or loaded_day_key

            # Restore fail-safe latches (fail-closed): never clear True -> False.
            self._trading_blocked_today = bool(payload.get("trading_blocked_today", False)) or bool(
                self._trading_blocked_today
            )
            self._execution_failsafe_triggered = bool(
                payload.get("execution_failsafe_triggered", False)
            ) or bool(self._execution_failsafe_triggered)

            if self._execution_failsafe_triggered or self._trading_blocked_today:
                self._is_trading_allowed = False
            else:
                self._is_trading_allowed = bool(payload.get("is_trading_allowed", True)) and bool(
                    self._is_trading_allowed
                )

            self._failsafe_close_retry_count = max(
                int(getattr(self, "_failsafe_close_retry_count", 0)),
                int(payload.get("failsafe_close_retry_count", 0) or 0),
            )
            loaded_last_attempt = payload.get("failsafe_close_last_attempt_ts_ns")
            if loaded_last_attempt is not None:
                try:
                    self._failsafe_close_last_attempt_ts_ns = int(loaded_last_attempt)
                except Exception:
                    pass

            # Restore bracket tracking strings (do not reconstruct full Order objects).
            self._entry_client_order_id = payload.get("entry_client_order_id")
            self._bracket_sl_client_order_id = payload.get("bracket_sl_client_order_id")
            self._bracket_tp_client_order_id = payload.get("bracket_tp_client_order_id")
            self._active_bracket_list_id = payload.get("active_bracket_list_id")

            # Restore time-manager idempotency markers (attempted/issued).
            if getattr(self, "_time_manager", None) is not None:
                tm_payload = payload.get("time_manager")
                if isinstance(tm_payload, dict):
                    try:
                        issued = tm_payload.get("issued")
                        if isinstance(issued, list):
                            self._time_manager._issued = set(str(x) for x in issued)
                        self._time_manager._close_orders_submitted = bool(
                            tm_payload.get("close_orders_submitted", False)
                        )
                        self._time_manager._close_submitted_ts_ns = tm_payload.get(
                            "close_submitted_ts_ns"
                        )
                        self._time_manager._flatten_complete = bool(
                            tm_payload.get("flatten_complete", False)
                        )
                        self._time_manager._close_retry_count = int(
                            tm_payload.get("close_retry_count", 0) or 0
                        )
                        close_ids = tm_payload.get("close_order_ids")
                        if isinstance(close_ids, list):
                            self._time_manager._close_order_ids = [
                                ClientOrderId(str(x)) for x in close_ids
                            ]
                    except Exception:
                        # Any issue restoring the time-manager snapshot is non-fatal; enforce from time.
                        pass

            if self._last_market_ts_ns is not None:
                self._enforce_time_gates_after_restore(self._last_market_ts_ns)

        except Exception as exc:
            self.log.error(
                f"[PERSISTENCE] on_load failed -> fail-closed: {type(exc).__name__}: {exc}"
            )
            self._trigger_execution_failsafe(reason="persistence_on_load_failed")

    def _enforce_time_gates_after_restore(self, ts_ns: int) -> None:
        # Enforce both time gates and TradingState at restore time.
        # This is intentionally conservative: any exception is treated as unsafe.
        try:
            if getattr(self, "_time_manager", None) is not None:
                allowed = bool(self._time_manager.check(int(ts_ns)))
                if not allowed:
                    self._is_trading_allowed = False
                    self._trading_blocked_today = True
            # Always run time-gate trading-state updates.
            self._on_time_gate_timer({"ts_event": int(ts_ns)})
        except Exception as exc:
            self.log.error(
                f"[PERSISTENCE] Time gate enforcement failed -> fail-closed: {type(exc).__name__}: {exc}"
            )
            self._trigger_execution_failsafe(reason="persistence_time_gate_enforce_failed")

    # ========== SpreadAnalyzer (Entry Quality Gate) ==========

    def _is_spread_acceptable(self) -> bool:
        """Check if current spread is acceptable for trading.

        Uses SpreadAnalyzer to block entries when spread is abnormally wide,
        which typically indicates:
        - News events
        - Low liquidity periods
        - High volatility
        - Market gaps

        Returns True during warmup (analyzer not yet initialized) to avoid
        blocking trades unnecessarily.

        Formula: Block if current_spread > spread_block_multiplier * average_spread
        Example: average=2.5 pips, multiplier=2.0 → block if current > 5.0 pips
        """
        if self._spread_analyzer is None:
            return True  # No analyzer available

        if not self._spread_analyzer.initialized:
            return True  # Allow during warmup

        try:
            current = float(self._spread_analyzer.current)
            average = float(self._spread_analyzer.average)

            # Validate values
            if average <= 0 or current < 0:
                return True  # Invalid values, allow trading

            threshold = average * self._spread_block_multiplier

            if current > threshold:
                self.log.warning(
                    f"[SPREAD] Blocking entry: current={current:.5f} > "
                    f"{self._spread_block_multiplier}x avg={average:.5f} (threshold={threshold:.5f})"
                )
                return False

            return True
        except Exception as exc:
            self.log.debug(f"[SPREAD] Error checking spread: {exc}")
            return True  # On error, allow trading

    def get_spread_metrics(self) -> dict[str, float]:
        """Get current spread metrics for monitoring/logging.

        Returns:
            Dictionary with current, average, and ratio (current/average).
        """
        if self._spread_analyzer is None or not self._spread_analyzer.initialized:
            return {"current": 0.0, "average": 0.0, "ratio": 0.0}

        try:
            current = float(self._spread_analyzer.current)
            average = float(self._spread_analyzer.average)
            ratio = current / average if average > 0 else 0.0

            return {
                "current": current,
                "average": average,
                "ratio": ratio,
            }
        except Exception:
            return {"current": 0.0, "average": 0.0, "ratio": 0.0}

    def on_order_rejected(self, event: OrderRejected) -> None:
        # Entry rejected: clear pending brackets if no position was opened.
        # NOTE: Some venues may emit cancel/reject before `PositionOpened` on partial/fast fills.
        # Clearing staged protection here can cause a false-positive fail-safe in `on_position_opened`.
        # We therefore only clear staged protection after a grace window.
        if (
            self._entry_client_order_id
            and str(event.client_order_id) == self._entry_client_order_id
        ):
            self._entry_terminal_ts_ns = (
                int(getattr(event, "ts_event", 0) or 0) or self._entry_terminal_ts_ns
            )
            self._entry_terminal_reason = "entry_rejected"
            self._entry_client_order_id = None
            return

        # Bracket rejected while position open:
        # - SL reject is critical -> fail-safe
        # - TP reject is non-fatal (keep SL protection), clear TP tracking
        if (
            self._position is not None
            and str(event.client_order_id) == self._bracket_sl_client_order_id
        ):
            # If we're intentionally flattening (time gate / forced close), SL rejects can be expected.
            if bool(getattr(self, "_forcing_flatten", False)):
                self.log.warning("[WP0] SL rejected during forced flatten; ignoring")
                return
            self._trigger_execution_failsafe(reason="bracket_sl_rejected")
            return

        if (
            self._position is not None
            and str(event.client_order_id) == self._bracket_tp_client_order_id
        ):
            self._bracket_tp_client_order_id = None
            self._bracket_tp_confirmed = False
            if self._bracket_tp_expected:
                self._trigger_execution_failsafe(reason="bracket_tp_rejected")
                return
            self.log.warning("[WP0] TP rejected; continuing with SL protection only")
            return

    def on_order_canceled(self, event: OrderCanceled) -> None:
        # Entry canceled: clear pending brackets if no position was opened.
        # NOTE: Some venues may emit cancel before `PositionOpened` on partial/fast fills.
        # Avoid clearing staged protection too early to prevent false-positive fail-safe.
        if (
            self._entry_client_order_id
            and str(event.client_order_id) == self._entry_client_order_id
        ):
            self._entry_terminal_ts_ns = (
                int(getattr(event, "ts_event", 0) or 0) or self._entry_terminal_ts_ns
            )
            self._entry_terminal_reason = "entry_canceled"
            self._entry_client_order_id = None
            return

        # Bracket canceled while position open:
        # - SL cancel is critical -> fail-safe
        # - TP cancel is non-fatal (keep SL protection), clear TP tracking
        if (
            self._position is not None
            and str(event.client_order_id) == self._bracket_sl_client_order_id
        ):
            # If we're intentionally flattening (time gate / forced close), SL cancels are expected.
            if bool(getattr(self, "_forcing_flatten", False)):
                self.log.warning("[WP0] SL canceled during forced flatten; ignoring")
                return
            self._trigger_execution_failsafe(reason="bracket_sl_canceled")
            return

        if (
            self._position is not None
            and str(event.client_order_id) == self._bracket_tp_client_order_id
        ):
            # TP cancellation is not a safety hazard (SL is the protection). It can happen
            # naturally when a position is closed by SL/market and the broker cancels the TP.
            self._bracket_tp_client_order_id = None
            self._bracket_tp_confirmed = False
            self.log.warning("[WP0] TP canceled; continuing with SL protection only")
            return

    def on_order_accepted(self, event: OrderAccepted) -> None:
        cid = str(event.client_order_id)
        if cid == self._bracket_sl_client_order_id:
            self._bracket_sl_confirmed = True
        elif cid == self._bracket_tp_client_order_id:
            self._bracket_tp_confirmed = True

        # Do NOT fail-safe based on acceptance ordering alone.
        # The SL may be accepted after TP depending on venue/broker routing.
        # We enforce SL presence via a timestamp watchdog in on_quote_tick.

    def _submit_native_bracket(
        self,
        order_side: OrderSide,
        quantity: Quantity,
        sl_price: Price,
        tp_price: Price | None,
    ) -> None:
        """Submit bracket order using native Nautilus API.

        Creates an atomic bracket with OCO contingency:
        - Entry: MARKET order
        - SL: STOP_MARKET (OCO with TP)
        - TP: LIMIT (OCO with SL) - optional

        Args:
            order_side: Direction for entry order (BUY/SELL)
            quantity: Position size
            sl_price: Stop loss trigger price
            tp_price: Take profit limit price (None to skip TP)
        """
        if self.instrument is None:
            self.log.error("Cannot submit native bracket: instrument not loaded")
            return

        # Build bracket order list
        bracket_list = self.order_factory.bracket(
            instrument_id=self.config.instrument_id,
            order_side=order_side,
            quantity=quantity,
            entry_order_type=OrderType.MARKET,
            sl_trigger_price=sl_price,
            tp_price=tp_price,
            contingency_type=ContingencyType.OCO,
            entry_tags=["ENTRY", "NATIVE_BRACKET"],
            sl_tags=["STOP_LOSS", "NATIVE_BRACKET"],
            tp_tags=["TAKE_PROFIT", "NATIVE_BRACKET"] if tp_price else None,
        )

        # Track the order list ID for monitoring
        self._active_bracket_list_id = str(bracket_list.id)

        # Extract individual order IDs for compatibility with existing tracking
        # OrderList contains: [entry, sl, tp] in order
        orders = list(bracket_list.orders)
        if len(orders) >= 1:
            self._entry_client_order_id = str(orders[0].client_order_id)
        if len(orders) >= 2:
            self._bracket_sl_client_order_id = str(orders[1].client_order_id)
            self._bracket_sl_order_id = orders[1].client_order_id
        if len(orders) >= 3 and tp_price:
            self._bracket_tp_client_order_id = str(orders[2].client_order_id)

        # Set bracket state
        self._bracket_tp_expected = tp_price is not None
        self._bracket_sl_confirmed = False
        self._bracket_tp_confirmed = False

        # Start confirmation watchdog
        now_ns = int(getattr(self, "_last_market_ts_ns", 0) or 0)
        self._bracket_submitted_ts_ns = now_ns if now_ns > 0 else None

        # Submit the bracket order list
        self.submit_order_list(bracket_list)

        self.log.info(
            f"Native bracket submitted: entry={self._entry_client_order_id}, "
            f"sl={self._bracket_sl_client_order_id} @ {sl_price}, "
            f"tp={self._bracket_tp_client_order_id} @ {tp_price}"
        )

    def _submit_bracket_orders(self) -> None:
        """Submit SL and TP orders for current position."""
        if self._position is None:
            return

        qty = self._position.quantity

        # Determine exit side (opposite of position)
        if self._position.side == PositionSide.LONG:
            exit_side = OrderSide.SELL
        else:
            exit_side = OrderSide.BUY

        # Reset bracket tracking for this position
        self._bracket_sl_client_order_id = None
        self._bracket_tp_client_order_id = None
        self._bracket_sl_confirmed = False
        self._bracket_tp_confirmed = False
        self._bracket_tp_expected = bool(self._pending_tp is not None)
        self._bracket_submitted_ts_ns = None

        # Submit Stop Loss
        if self._pending_sl:
            sl_order = self.order_factory.stop_market(
                instrument_id=self.config.instrument_id,
                order_side=exit_side,
                quantity=qty,
                trigger_price=self._pending_sl,
                time_in_force=TimeInForce.GTC,
                reduce_only=True,
            )
            self.submit_order(sl_order)
            self._bracket_sl_client_order_id = str(sl_order.client_order_id)
            self._bracket_sl_order_id = sl_order.client_order_id
            self.log.info(
                f"SL order submitted @ {self._pending_sl} (id={self._bracket_sl_client_order_id})"
            )

        # Submit Take Profit
        if self._pending_tp:
            tp_order = self.order_factory.limit(
                instrument_id=self.config.instrument_id,
                order_side=exit_side,
                quantity=qty,
                price=self._pending_tp,
                time_in_force=TimeInForce.GTC,
                reduce_only=True,
            )
            self.submit_order(tp_order)
            self._bracket_tp_client_order_id = str(tp_order.client_order_id)
            self.log.info(
                f"TP order submitted @ {self._pending_tp} (id={self._bracket_tp_client_order_id})"
            )

        # Start confirmation watchdog (timestamp driven, deterministic)
        # We use the latest market timestamp (set in on_quote_tick) when available.
        now_ns = int(getattr(self, "_last_market_ts_ns", 0) or 0)
        self._bracket_submitted_ts_ns = (
            now_ns if now_ns > 0 else int(getattr(self._position, "ts_opened", 0) or 0) or None
        )

        # Clear pending prices (order events confirm protection)
        self._pending_sl = None
        self._pending_tp = None

        # If TP was requested but we failed to create a TP order, this is a fail-safe breach.
        if self._bracket_tp_expected and self._bracket_tp_client_order_id is None:
            self._trigger_execution_failsafe(reason="position_opened_without_tp")
            return

    def _sync_sl_quantity_on_position_increase(self, new_qty: float) -> None:
        """BUG-5 FIX: Update SL order quantity when position quantity increases.

        When additional partial fills increase position size, the existing SL
        order may cover less than the full position, leaving units unprotected.

        This method cancels the existing SL and submits a new one with the
        correct quantity.

        Args:
            new_qty: The new total position quantity to protect.

        Formula: SL quantity must equal position quantity for full protection.
        Example: If position grew from 50 to 100 units, cancel SL(50), submit SL(100).
        """
        if self._position is None:
            return

        if self._bracket_sl_client_order_id is None:
            # No SL to update - this should not happen, but fail-safe
            self._trigger_execution_failsafe(reason="position_increased_without_sl")
            return

        # Get current SL trigger price from cache (need to preserve it)
        sl_trigger_price: Price | None = None
        try:
            # Try to find the SL order in cache to get its trigger price
            # Note: ClientOrderId imported at module level (FORGE recommendation)
            sl_order_id = ClientOrderId(self._bracket_sl_client_order_id)
            sl_order = self.cache.order(sl_order_id)
            if sl_order is not None:
                sl_trigger_price = getattr(sl_order, "trigger_price", None)
        except Exception:
            self.log.warning("[BUG-5] Could not retrieve SL trigger price from cache")

        if sl_trigger_price is None:
            # Cannot proceed without knowing where to place SL
            self._trigger_execution_failsafe(reason="position_increased_sl_price_unknown")
            return

        # Cancel existing SL order
        try:
            # Note: ClientOrderId imported at module level (FORGE recommendation)
            old_sl_order_id = ClientOrderId(self._bracket_sl_client_order_id)
            old_sl_order = self.cache.order(old_sl_order_id)
            if old_sl_order is not None:
                self.cancel_order(old_sl_order)
                self.log.info(
                    f"[BUG-5] Cancelled old SL order (id={self._bracket_sl_client_order_id}) "
                    f"due to position quantity increase"
                )
        except Exception as exc:
            self.log.warning(f"[BUG-5] Failed to cancel old SL order: {type(exc).__name__}: {exc}")

        # Submit new SL order with updated quantity
        if self._position.side == PositionSide.LONG:
            exit_side = OrderSide.SELL
        else:
            exit_side = OrderSide.BUY

        new_sl_qty = self._quantity_from_float(new_qty, rounding="floor")
        new_sl_order = self.order_factory.stop_market(
            instrument_id=self.config.instrument_id,
            order_side=exit_side,
            quantity=new_sl_qty,
            trigger_price=sl_trigger_price,
            time_in_force=TimeInForce.GTC,
            reduce_only=True,
        )

        # CRITICAL: Reset confirmation BEFORE submit so timeout can detect failures
        # BUG-FIX: If submit_order fails, position would be left without SL protection
        self._bracket_sl_confirmed = False
        self._bracket_sl_client_order_id = str(new_sl_order.client_order_id)
        self._bracket_sl_order_id = new_sl_order.client_order_id

        try:
            self.submit_order(new_sl_order)
        except Exception as exc:
            self.log.error(
                f"[BUG-5] CRITICAL: submit_order failed after canceling old SL: {type(exc).__name__}: {exc}"
            )
            self._trigger_execution_failsafe(reason="sl_submit_failed_after_cancel")
            return

        self.log.info(
            f"[BUG-5] Submitted new SL order @ {sl_trigger_price} with qty={new_sl_qty} "
            f"(id={self._bracket_sl_client_order_id})"
        )

    def _simulate_partial_fill(self, quantity: Quantity, side: str) -> Quantity:
        """
        Apply a simple partial fill model:
        - Base probability from config.partial_fill_prob
        - Spread-aware degradation: higher spread ratio => lower fill ratio
        """
        if not hasattr(quantity, "as_double"):
            quantity = self._quantity_from_float(float(quantity), rounding="round")
        fill_ratio = 1.0
        cfg_prob = float(getattr(self.config, "partial_fill_prob", 0.0))
        cfg_ratio = float(getattr(self.config, "partial_fill_ratio", 0.5))
        reject_base = float(getattr(self.config, "fill_reject_base", 0.0))
        reject_spread = float(getattr(self.config, "fill_reject_spread_factor", 0.0))
        fill_model = str(getattr(self.config, "fill_model", "realistic"))

        snap = getattr(self, "_spread_snapshot", None)
        spread_ratio = getattr(snap, "spread_ratio", 1.0) if snap else 1.0
        if snap:
            # degrade size as spread widens; clamp between 0.2 and 1.0
            ratio_factor = 1.0 / max(1.0, spread_ratio)
            fill_ratio *= max(0.2, min(1.0, ratio_factor))
            if not snap.can_trade:
                fill_ratio = 0.0
            # volatility-aware degradation using std_dev normalized by avg spread
            if getattr(snap, "average_spread", 0) > 0:
                vol_factor = min(2.0, getattr(snap, "std_dev", 0) / snap.average_spread)
                fill_ratio *= max(0.3, 1.0 - 0.2 * vol_factor)

        # Optional partial fill probability
        if cfg_prob > 0 and self._rng.random() < cfg_prob:
            fill_ratio *= cfg_ratio

        # Fill rejection modeled by spread + base
        reject_prob = max(0.0, reject_base + max(0.0, spread_ratio - 1.0) * reject_spread)
        if fill_model == "worst_case":
            reject_prob += 0.1
        elif fill_model == "immediate":
            reject_prob = 0.0

        if reject_prob > 0 and self._rng.random() < reject_prob:
            self.log.warning(
                f'{{"event":"fill_reject","side":"{side}","spread_ratio":{spread_ratio:.2f},"reject_prob":{reject_prob:.2f}}}'
            )
            sink = getattr(self, "_telemetry", None)
            if sink:
                sink.emit(
                    "fill_reject",
                    {"side": side, "spread_ratio": spread_ratio, "reject_prob": reject_prob},
                )
            return Quantity.from_str("0")

        if fill_ratio >= 1.0:
            return quantity

        adj = quantity.as_double() * fill_ratio
        self.log.info(
            f'{{"event":"partial_fill","side":"{side}","orig_qty":{quantity.as_double():.2f},"fill_ratio":{fill_ratio:.2f},"new_qty":{adj:.2f}}}'
        )
        sink = getattr(self, "_telemetry", None)
        if sink:
            sink.emit(
                "partial_fill",
                {
                    "side": side,
                    "orig_qty": quantity.as_double(),
                    "fill_ratio": fill_ratio,
                    "new_qty": adj,
                    "spread_ratio": spread_ratio,
                },
            )
        return self._quantity_from_float(max(0.0, adj), rounding="floor")

    # ========== Utility Methods ==========

    def _trim_bars(self, bars: list[Bar], max_count: int) -> None:
        """Keep bar list at max size."""
        if len(bars) > max_count:
            del bars[:-max_count]

    def _has_enough_data(self) -> bool:
        """Check if we have enough data for analysis."""
        min_ltf = 50
        min_mtf = 20 if self.config.use_mtf else 0
        min_htf = 10 if self.config.use_mtf else 0

        return (
            len(self._ltf_bars) >= min_ltf
            and (not self.config.mtf_bar_type or len(self._mtf_bars) >= min_mtf)
            and (not self.config.htf_bar_type or len(self._htf_bars) >= min_htf)
        )

    def _compute_equity_from_tick(self, tick: QuoteTick) -> float | None:
        """Mark-to-market equity using the current tick."""
        if self._position is None or self.instrument is None:
            return None

        # Formula: unrealized_usd = (exit_px - entry_px) * qty_units * point_value
        # Example (LONG): entry=2000.0, bid=2000.5, qty=1.0, point_value=1.0 -> +$0.50
        pos = self._position

        entry = self._pos_cache_entry_px
        qty = self._pos_cache_qty
        point_value = self._pos_cache_point_value

        if entry is None or qty is None or point_value is None or self._pos_cache_side is None:
            entry_obj = getattr(pos, "avg_px_open", 0.0)
            qty_obj = getattr(pos, "quantity", 0.0)
            entry = (
                float(entry_obj.as_double())
                if hasattr(entry_obj, "as_double")
                else float(entry_obj)
            )
            qty = float(qty_obj.as_double()) if hasattr(qty_obj, "as_double") else float(qty_obj)
            point_value = float(self._instrument_point_value_per_unit())

        # Conservative mark-to-market (Apex HWM trap defense):
        # - LONG exits at BID
        # - SHORT exits at ASK
        cached_side = self._pos_cache_side
        side = cached_side if cached_side is not None else pos.side
        if side == PositionSide.LONG:
            bid_obj = getattr(tick, "bid_price", 0.0)
            exit_px = (
                float(bid_obj.as_double()) if hasattr(bid_obj, "as_double") else float(bid_obj)
            )
            unrealized = (exit_px - entry) * qty * point_value
        else:
            ask_obj = getattr(tick, "ask_price", 0.0)
            exit_px = (
                float(ask_obj.as_double()) if hasattr(ask_obj, "as_double") else float(ask_obj)
            )
            unrealized = (entry - exit_px) * qty * point_value

        equity = float(self._equity_base + unrealized)

        # R13-FIX: Replace assert with explicit validation (safe under -O)
        if qty < 0.0:
            self._trigger_execution_failsafe(reason=f"invalid_negative_quantity:{qty}")
            return None

        # Fail closed: non-finite equity corrupts DD/HWM semantics.
        if not math.isfinite(equity):
            self._trigger_execution_failsafe(reason=f"non_finite_equity:{equity}")
            return None
        if not math.isfinite(exit_px) or exit_px <= 0.0:
            self._trigger_execution_failsafe(reason=f"invalid_exit_price:{exit_px}")
            return None
        if not math.isfinite(entry) or entry <= 0.0:
            self._trigger_execution_failsafe(reason=f"invalid_entry_price:{entry}")
            return None
        if not math.isfinite(qty) or qty == 0.0:
            self._trigger_execution_failsafe(reason=f"invalid_quantity:{qty}")
            return None

        return equity

    def _calculate_execution_cost(
        self,
        side: str,
        price: float,
        quantity: float,
        *,
        include_slippage: bool,
        include_commission: bool,
    ) -> float:
        """Calculate per-fill slippage cash cost and/or commission cash cost."""
        try:
            if not self._execution_model or quantity <= 0:
                return 0.0
            if not include_slippage and not include_commission:
                return 0.0

            # Nautilus quantity for XAUUSD is in oz, but our commission model is per-lot.
            # Convert oz -> lots for commission only.
            lot_size_oz = float(XAUUSD_LOT_SIZE)
            if self.instrument is not None:
                try:
                    lot_size_oz = float(self.instrument.lot_size.as_double())
                except Exception:
                    lot_size_oz = float(XAUUSD_LOT_SIZE)

            commission_cost = 0.0
            if include_commission:
                lots = float(quantity) / lot_size_oz if lot_size_oz > 0 else 0.0
                commission_cost = float(self._execution_model.commission(Decimal(str(lots))))

            slip_cost = 0.0
            if include_slippage:
                tick_size: Decimal | None = None
                if self.instrument is not None:
                    try:
                        tick_size = Decimal(str(float(self.instrument.price_increment.as_double())))
                    except Exception:
                        tick_size = None

                slip_price = self._execution_model.apply_slippage(
                    side=side,
                    current_price=Decimal(str(price)),
                    tick_size=tick_size,
                )
                point_value = self._instrument_point_value_per_unit()
                slip_cost = abs(float(slip_price) - float(price)) * float(quantity) * point_value

            return slip_cost + commission_cost
        except Exception as exc:  # pragma: no cover
            self.log.debug(f"Execution cost calc failed: {type(exc).__name__}: {exc}")
            return 0.0

    def _instrument_point_value_per_unit(self) -> float:
        """USD PnL per 1.0 price move for 1.0 quantity unit.

        - Spot XAUUSD: quantity is oz -> $1 move == $1 per oz => 1.0
        - Futures (e.g., MGC): quantity is contracts -> $1 move == multiplier USD per contract
        """
        inst = self.instrument
        if inst is None:
            return 1.0
        mult = getattr(inst, "multiplier", None)
        if mult is None:
            return 1.0
        try:
            return float(mult.as_double())
        except Exception:
            return 1.0

    def _price_from_float(
        self,
        value: float,
        *,
        rounding: Literal["floor", "ceil", "nearest"] = "nearest",
    ) -> Price:
        """Quantize a float to the instrument tick + precision.

        This is critical for futures (e.g., MGC tick=0.1, precision=1).
        """
        from decimal import ROUND_CEILING, ROUND_FLOOR, ROUND_HALF_UP

        inst = self.instrument
        if inst is None:
            tick = Decimal("0.01")
            precision = 2
        else:
            try:
                tick = Decimal(str(float(inst.price_increment.as_double())))
            except Exception:
                tick = Decimal("0.01")
            try:
                precision = int(getattr(inst, "price_precision", 2))
            except Exception:
                precision = 2

        if tick <= 0:
            tick = Decimal("0.01")

        x = Decimal(str(float(value)))
        steps = x / tick
        if rounding == "floor":
            steps = steps.to_integral_value(rounding=ROUND_FLOOR)
        elif rounding == "ceil":
            steps = steps.to_integral_value(rounding=ROUND_CEILING)
        else:
            steps = steps.to_integral_value(rounding=ROUND_HALF_UP)

        px = steps * tick
        return Price(px, precision=precision)

    def _quantity_from_float(
        self, value: float, *, rounding: Literal["floor", "round"] = "floor"
    ) -> Quantity:
        """Quantize a float to the instrument's size increment/precision (safe default: floor)."""
        if value <= 0:
            # PERF: avoid Quantity.from_str("0") parsing on hot paths.
            # Nautilus Quantity.from_int is a dedicated constructor:
            # `external/nautilus_trader/nautilus_trader/model/objects.pyx:529-548`.
            return Quantity.from_int(0)

        inst = self.instrument
        if inst is None:
            precision = 2
            inc = 0.01
            min_qty = 0.0
        else:
            precision = int(getattr(inst, "size_precision", 2))
            try:
                inc = float(inst.size_increment.as_double())
            except Exception:
                inc = 0.0
            try:
                min_q = getattr(inst, "min_quantity", None)
                min_qty = float(min_q.as_double()) if min_q is not None else 0.0
            except Exception:
                min_qty = 0.0

        q = float(value)
        if inc > 0:
            steps_f = q / inc
            if rounding == "round":
                steps = int(round(steps_f))
            else:
                steps = int(math.floor(steps_f + 1e-9))
            q = float(steps) * inc

        if q <= 0 and value > 0:
            q = min_qty if min_qty > 0 else (inc if inc > 0 else value)

        if min_qty > 0 and 0 < q < min_qty:
            q = min_qty

        if precision <= 0:
            return Quantity.from_str(str(int(round(q))))
        return Quantity.from_str(f"{q:.{precision}f}")

    def _apply_drawdown_limits(self, analysis: Any | None) -> None:
        """Block trading when drawdown thresholds are breached."""
        if analysis is None or not getattr(self, "_drawdown_tracker", None):
            return

        # Safety buffers (project non-negotiables):
        # - Daily DD HALT at 3.0%
        # - Trailing (total) DD HALT at 4.0%
        daily_limit_pct_cfg = float(
            getattr(
                self.config, "daily_loss_limit_pct", getattr(self.config, "max_daily_loss_pct", 5.0)
            )
        )
        total_limit_pct_cfg = float(
            getattr(
                self.config,
                "total_loss_limit_pct",
                getattr(self.config, "max_total_loss_pct", 10.0),
            )
        )

        # Config is expected to be percent-points (e.g., 5.0 for 5%). Normalize a common footgun:
        # some callers may provide fractions (e.g., 0.05). Treat <= 1.0 as fraction and convert.
        if 0 < daily_limit_pct_cfg <= 1.0:
            daily_limit_pct_cfg *= 100.0
        if 0 < total_limit_pct_cfg <= 1.0:
            total_limit_pct_cfg *= 100.0

        daily_limit_pct = min(daily_limit_pct_cfg, 3.0)
        total_limit_pct = min(total_limit_pct_cfg, 4.0)

        daily_dd = getattr(self._drawdown_tracker, "get_daily_drawdown_pct", lambda: 0.0)()
        total_dd = getattr(self._drawdown_tracker, "get_total_drawdown_pct", lambda: 0.0)()

        if daily_dd >= daily_limit_pct or total_dd >= total_limit_pct:
            if self._is_trading_allowed:
                self.log.error(
                    f"Drawdown breach: daily {daily_dd:.2f}% (limit {daily_limit_pct:.2f}%), "
                    f"total {total_dd:.2f}% (limit {total_limit_pct:.2f}%). Trading halted."
                )
            self._is_trading_allowed = False
            self._trading_blocked_today = True
            self.log.error(
                f"[BLOCKED] _is_trading_allowed = False (DD breach: daily={daily_dd:.2f}%, total={total_dd:.2f}%)"
            )

            # WP2: breach while in-position must force-flatten open risk (not just block entries).
            if self._position is not None:
                self._trigger_execution_failsafe(
                    reason=(
                        f"drawdown_breach daily={daily_dd:.2f}% (>= {daily_limit_pct:.2f}%) "
                        f"total={total_dd:.2f}% (>= {total_limit_pct:.2f}%)"
                    )
                )

        # Update TradingState machine for Apex compliance
        self._check_dd_trading_state()

    def _get_signal_quality(self, score: float) -> SignalQuality:
        """Determine signal quality tier from score."""
        if score >= TIER_S_MIN:
            return SignalQuality.TIER_S
        elif score >= TIER_A_MIN:
            return SignalQuality.TIER_A
        elif score >= TIER_B_MIN:
            return SignalQuality.TIER_B
        elif score >= TIER_C_MIN:
            return SignalQuality.TIER_C
        else:
            return SignalQuality.TIER_INVALID

    @property
    def is_flat(self) -> bool:
        """Check if no position is open."""
        return self._position is None

    @property
    def is_long(self) -> bool:
        """Check if long position is open."""
        return self._position is not None and self._position.side == PositionSide.LONG

    @property
    def is_short(self) -> bool:
        """Check if short position is open."""
        return self._position is not None and self._position.side == PositionSide.SHORT

    # ========== Abstract Methods (to be implemented by subclasses) ==========

    @abstractmethod
    def _on_strategy_start(self) -> None:
        """Strategy-specific initialization."""
        pass

    @abstractmethod
    def _on_strategy_stop(self) -> None:
        """Strategy-specific cleanup."""
        pass

    @abstractmethod
    def _on_htf_bar(self, bar: Bar) -> None:
        """Process HTF (H1) bar."""
        pass

    @abstractmethod
    def _on_mtf_bar(self, bar: Bar) -> None:
        """Process MTF (M15) bar."""
        pass

    @abstractmethod
    def _on_ltf_bar(self, bar: Bar) -> None:
        """Process LTF (M5) bar."""
        pass

    @abstractmethod
    def _check_for_signal(self, bar: Bar) -> None:
        """Check for trading signal and execute if valid."""
        pass
