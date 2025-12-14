"""
Base Strategy for Nautilus Gold Scalper.
STREAM F - Trading Strategies (Part 1)

Provides abstract base class for all trading strategies with common functionality:
- Multi-timeframe data management
- Risk management integration
- Position tracking
- Signal generation interface
"""
from abc import abstractmethod
from decimal import Decimal
from typing import Dict, List, Optional, Any
import random

from nautilus_trader.config import StrategyConfig
from nautilus_trader.core.message import Event
from nautilus_trader.model import Bar, BarType, QuoteTick, TradeTick
from nautilus_trader.model import InstrumentId, Position, PositionId
from nautilus_trader.model.instruments import Instrument
from nautilus_trader.model.orders import Order
from nautilus_trader.model.enums import OrderSide, PositionSide, OrderType, TimeInForce
from nautilus_trader.model.events import PositionOpened, PositionChanged, PositionClosed
from nautilus_trader.model.objects import Price, Quantity
from nautilus_trader.trading.strategy import Strategy

from datetime import datetime, timezone

from ..core.definitions import (
    SignalType, SignalQuality, MarketRegime, TradingSession,
    TIER_S_MIN, TIER_A_MIN, TIER_B_MIN, TIER_C_MIN, TIER_INVALID,
    DEFAULT_RISK_PER_TRADE, DEFAULT_MAX_DAILY_LOSS,
)
from ..core.data_types import ConfluenceResult, RegimeAnalysis, SessionInfo


class BaseStrategyConfig(StrategyConfig, frozen=True):
    """Base configuration for gold scalping strategies."""
    instrument_id: InstrumentId
    
    # Multi-timeframe bar types
    htf_bar_type: Optional[BarType] = None  # H1 - Direction
    mtf_bar_type: Optional[BarType] = None  # M15 - Structure
    ltf_bar_type: Optional[BarType] = None  # M5 - Execution
    
    # Risk parameters
    risk_per_trade: Decimal = Decimal("0.5")
    max_daily_loss_pct: Decimal = Decimal("5.0")
    max_total_loss_pct: Decimal = Decimal("10.0")
    max_trades_per_day: int = 15
    
    # Execution parameters
    min_score_to_trade: float = TIER_INVALID
    min_rr_ratio: float = 1.5
    target_rr_ratio: float = 2.5
    max_spread_points: int = 80
    
    # Feature flags
    use_session_filter: bool = True
    use_regime_filter: bool = True
    use_mtf: bool = True
    use_footprint: bool = True
    
    # Debugging
    debug_mode: bool = False


class BaseGoldStrategy(Strategy):
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
        
        self.instrument: Optional[Instrument] = None
        
        # Bar storage
        self._htf_bars: List[Bar] = []
        self._mtf_bars: List[Bar] = []
        self._ltf_bars: List[Bar] = []
        
        # State tracking
        self._position: Optional[Position] = None
        self._daily_trades: int = 0
        self._daily_pnl: float = 0.0
        self._is_trading_allowed: bool = True
        self._equity_base: float = float(getattr(config, "account_balance", 100_000.0))
        self._tick_counter: int = 0
        
        # Pending SL/TP for position management
        self._pending_sl: Optional[Price] = None
        self._pending_tp: Optional[Price] = None
        
        # Current analysis results
        self._current_regime: Optional[RegimeAnalysis] = None
        self._current_session: Optional[SessionInfo] = None
        self._last_confluence: Optional[ConfluenceResult] = None
        self._execution_model = getattr(self, "_execution_model", None)
        self._fill_costs = getattr(self, "_fill_costs", {})
        
        # Signal generation thresholds
        self._min_bars_for_signal: int = 50  # Minimum bars required for signal generation
    
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
        
        # Schedule daily reset at midnight ET (Bug #4 fix)
        # Note: In backtesting, this ensures multi-day resets work correctly
        # In live trading, this handles daily counter resets for Apex rules
        from datetime import timedelta
        try:
            self.clock.set_timer(
                name="daily_reset",
                interval=timedelta(days=1),
                callback=self.on_new_day,
            )
            self.log.info("Daily reset timer scheduled for midnight ET")
        except Exception as e:
            self.log.warning(f"Could not schedule daily timer: {e}")
        
        # Strategy-specific initialization
        self._on_strategy_start()
        
        self.log.info(f"Strategy started for {self.config.instrument_id}")
    
    def on_stop(self) -> None:
        """Cleanup on strategy stop."""
        # Close all open positions
        self.close_all_positions(self.config.instrument_id)
        
        # Cancel all pending orders
        self.cancel_all_orders(self.config.instrument_id)
        
        # Unsubscribe from data
        if self.config.ltf_bar_type:
            self.unsubscribe_bars(self.config.ltf_bar_type)
        if self.config.mtf_bar_type:
            self.unsubscribe_bars(self.config.mtf_bar_type)
        if self.config.htf_bar_type:
            self.unsubscribe_bars(self.config.htf_bar_type)
        
        self.unsubscribe_quote_ticks(self.config.instrument_id)
        
        # Strategy-specific cleanup
        self._on_strategy_stop()
        
        self.log.info(f"Strategy stopped. Daily trades: {self._daily_trades}, PnL: {self._daily_pnl:.2f}")
    
    def on_reset(self) -> None:
        """Reset strategy state."""
        self._htf_bars.clear()
        self._mtf_bars.clear()
        self._ltf_bars.clear()
        self._position = None
        self._daily_trades = 0
        self._daily_pnl = 0.0
        self._is_trading_allowed = True
        self.log.info(f"[INIT] _is_trading_allowed = True (initial state)")
        self._current_regime = None
        self._current_session = None
        self._last_confluence = None
    
    def on_new_day(self, event: Event) -> None:
        """
        Reset daily counters at midnight ET.
        
        Bug #4 Fix: Ensures daily metrics reset correctly across multi-day backtests
        and live trading for Apex compliance (daily loss limits, consistency rule, etc.)
        """
        self.log.info("=== NEW TRADING DAY - Resetting daily counters ===")
        
        # Reset daily counters
        self._daily_trades = 0
        self._daily_pnl = 0.0
        self._is_trading_allowed = True
        self.log.info(f"[DAILY_RESET] _is_trading_allowed = True (daily reset)")
        
        # Reset PropFirmManager daily counters (if exists)
        if hasattr(self, 'prop_firm_manager') and self.prop_firm_manager is not None:
            try:
                if hasattr(self.prop_firm_manager, 'reset_daily'):
                    self.prop_firm_manager.reset_daily()
                    self.log.info("PropFirmManager daily counters reset")
            except Exception as e:
                self.log.error(f"Failed to reset PropFirmManager: {e}")
        
        # Reset ConsistencyTracker (if exists)
        if hasattr(self, 'consistency_tracker') and self.consistency_tracker is not None:
            try:
                self.consistency_tracker.reset_daily()
                self.log.info("ConsistencyTracker daily counters reset")
            except Exception as e:
                self.log.error(f"Failed to reset ConsistencyTracker: {e}")
        
        # Reset TimeConstraintManager warnings (if exists)
        if hasattr(self, 'time_manager') and self.time_manager is not None:
            try:
                self.time_manager.reset_daily()
                self.log.info("TimeConstraintManager warnings reset")
            except Exception as e:
                self.log.error(f"Failed to reset TimeConstraintManager: {e}")
        
        # Reset CircuitBreaker daily metrics (if applicable)
        if hasattr(self, 'circuit_breaker') and self.circuit_breaker is not None:
            try:
                if hasattr(self.circuit_breaker, 'reset_daily_metrics'):
                    self.circuit_breaker.reset_daily_metrics()
                    self.log.info("CircuitBreaker daily metrics reset")
            except Exception as e:
                self.log.warning(f"Failed to reset CircuitBreaker: {e}")
        
        self.log.info("Daily reset complete")
    
    # ========== Data Handlers ==========
    
    def on_bar(self, bar: Bar) -> None:
        """Process incoming bar data."""
        # Debug: Always print to verify bars are arriving
        total_bars = len(self._ltf_bars) + len(self._mtf_bars) + len(self._htf_bars)
        if total_bars < 5 or total_bars % 100 == 0:
            print(f"[BARS] Received bar: {bar.bar_type}, total ltf={len(self._ltf_bars)}")
            self.log.info(f"Received bar type: {bar.bar_type}")
        
        # Check for daily reset
        if hasattr(self, '_check_daily_reset'):
            self._check_daily_reset(bar.ts_init)
        
        # Route to appropriate storage
        if self.config.htf_bar_type and bar.bar_type == self.config.htf_bar_type:
            self._htf_bars.append(bar)
            self._trim_bars(self._htf_bars, 500)
            self._on_htf_bar(bar)
            
        elif self.config.mtf_bar_type and bar.bar_type == self.config.mtf_bar_type:
            self._mtf_bars.append(bar)
            self._trim_bars(self._mtf_bars, 500)
            self._on_mtf_bar(bar)
            
        elif self.config.ltf_bar_type and bar.bar_type == self.config.ltf_bar_type:
            self._ltf_bars.append(bar)
            self._trim_bars(self._ltf_bars, 1000)
            self._on_ltf_bar(bar)
            
            # LTF bar is primary execution timeframe - check for signals
            has_data = self._has_enough_data()
            
            # Debug: Print every 100 bars (more frequent for debugging)
            if len(self._ltf_bars) % 100 == 0:
                self.log.info(f"[LTF_BAR] #{len(self._ltf_bars)}: trading_allowed={self._is_trading_allowed}, has_data={has_data}, will_check_signal={self._is_trading_allowed and has_data}")
            
            if self._is_trading_allowed and has_data:
                self._check_for_signal(bar)
            elif not has_data and len(self._ltf_bars) % 100 == 0:
                self.log.info(f"[LTF_BAR] Skipping signal check: insufficient data (need {self._min_bars_for_signal} bars, have {len(self._ltf_bars)})")
    
    def on_quote_tick(self, tick: QuoteTick) -> None:
        """Process quote tick for spread monitoring."""
        if not self.instrument:
            return
        
        spread = float(tick.ask_price - tick.bid_price)
        spread_points = int(spread / self.instrument.price_increment)
        
        if spread_points > self.config.max_spread_points:
            if self.config.debug_mode:
                self.log.warning(f"Spread too wide: {spread_points} points")

        # Intrabar drawdown monitoring (mark-to-market)
        self._tick_counter += 1
        if getattr(self, "_drawdown_tracker", None) and self._position:
            equity = self._compute_equity_from_tick(tick)
            if equity is not None:
                now_dt = datetime.fromtimestamp(tick.ts_event / 1e9, tz=timezone.utc)
                analysis = self._drawdown_tracker.update(equity, now=now_dt)
                self._apply_drawdown_limits(analysis)
    
    # ========== Position Event Handlers ==========
    
    def on_position_opened(self, event: PositionOpened) -> None:
        """Handle position opened event."""
        self._position = self.cache.position(event.position_id)
        self._daily_trades += 1
        # qty calculation moved to execution cost section (avoid duplicate code)
        
        self.log.info(
            f"Position OPENED: {self._position.side} "
            f"@ {self._position.avg_px_open} "
            f"(Daily trades: {self._daily_trades})"
        )
        
        # Submit SL/TP orders if pending
        if self._pending_sl or self._pending_tp:
            self._submit_bracket_orders()

        # Apply execution costs (slippage + commission) on entry
        # Handle avg_px_open being Price or float
        avg_price = self._position.avg_px_open.as_double() if hasattr(self._position.avg_px_open, 'as_double') else float(self._position.avg_px_open)
        qty = self._position.quantity.as_double() if hasattr(self._position.quantity, 'as_double') else float(self._position.quantity)
        
        open_cost = self._calculate_execution_cost(
            side="buy" if self._position.side == PositionSide.LONG else "sell",
            price=avg_price,
            quantity=qty,
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
            self.log.warning(f"[BLOCKED] _is_trading_allowed = False (max daily trades: {self._daily_trades})")
    
    def on_position_changed(self, event: PositionChanged) -> None:
        """Handle position changed event."""
        self._position = self.cache.position(event.position_id)
    
    def on_position_closed(self, event: PositionClosed) -> None:
        """Handle position closed event."""
        if self._position and self._position.id == event.position_id:
            pnl = float(self._position.realized_pnl)
            # Handle quantity being Quantity or float
            position_qty = self._position.quantity
            qty = position_qty.as_double() if hasattr(position_qty, 'as_double') else float(position_qty)
            
            # Handle avg_px_close/avg_px_open being Price or float
            close_px = getattr(self._position, "avg_px_close", self._position.avg_px_open) if hasattr(self._position, "avg_px_close") else self._position.avg_px_open
            close_price = close_px.as_double() if hasattr(close_px, 'as_double') else float(close_px)

            close_cost = self._calculate_execution_cost(
                side="sell" if self._position.side == PositionSide.LONG else "buy",
                price=close_price,
                quantity=qty,
            )
            net_pnl = pnl - close_cost

            self._daily_pnl += net_pnl
            self._equity_base += net_pnl

            # Track realized PnL for telemetry/metrics and adaptive sizing
            if hasattr(self, "_trade_pnl_history"):
                try:
                    self._trade_pnl_history.append(net_pnl)
                except Exception:
                    pass

            if getattr(self, "_position_sizer", None):
                try:
                    self._position_sizer.register_trade_result(net_pnl)
                except Exception:
                    self.log.debug("Position sizer trade result update failed", exc_info=True)
            
            self.log.info(
                f"Position CLOSED with PnL: {pnl:.2f} (net {-close_cost:.2f} costs applied) "
                f"(Daily PnL: {self._daily_pnl:.2f})"
            )

            if isinstance(self._fill_costs, dict) and str(event.position_id) in self._fill_costs:
                # Keep open cost only for reporting; already applied on entry
                self._fill_costs.pop(str(event.position_id), None)
            
            # Update drawdown tracker with realized PnL
            if getattr(self, "_drawdown_tracker", None):
                now_dt = datetime.now(timezone.utc)
                analysis = self._drawdown_tracker.update(self._equity_base, pnl=net_pnl, now=now_dt)
                self._apply_drawdown_limits(analysis)
            
            # Prop-firm tracking: feed realized result
            if getattr(self, "_prop_firm", None):
                try:
                    self._prop_firm.register_trade_close(contracts=qty, profit=net_pnl)
                except Exception as exc:
                    self.log.debug(f"Prop firm update failed on close: {exc}")

            # Circuit breaker trade result
            if getattr(self, "_circuit_breaker", None):
                try:
                    self._circuit_breaker.register_trade_result(pnl=net_pnl, is_win=net_pnl > 0)
                except Exception as exc:
                    self.log.debug(f"Circuit breaker trade update failed: {exc}")
            
            # Check daily loss limit as % of balance
            account_balance = float(getattr(self.config, "account_balance", self._equity_base or 100000.0))
            daily_limit_pct = float(getattr(self.config, "daily_loss_limit_pct", getattr(self.config, "max_daily_loss_pct", 5.0)))
            if account_balance > 0:
                daily_dd_pct = abs(self._daily_pnl) / account_balance * 100.0
                if daily_dd_pct >= daily_limit_pct:
                    self._is_trading_allowed = False
                    self.log.error(f"[BLOCKED] _is_trading_allowed = False (daily DD breach: {daily_dd_pct:.2f}% >= {daily_limit_pct:.2f}%)")
            
            self._position = None
    
    # ========== Trading Methods ==========
    
    def _enter_long(self, quantity: Quantity, sl_price: Optional[Price] = None, tp_price: Optional[Price] = None) -> None:
        """Enter a long position."""
        if self._position is not None:
            self.log.warning("Cannot enter long - position already exists")
            return
        
        # Partial fill simulation
        if getattr(self.config, "partial_fill_prob", 0) > 0:
            if random.random() < float(self.config.partial_fill_prob):
                ratio = float(self.config.partial_fill_ratio)
                quantity = Quantity.from_str(f"{quantity.as_double() * ratio:.2f}")
                self.log.info(f"Partial fill simulated (LONG): qty adjusted to {quantity}")

        # Partial fill simulation
        quantity = self._simulate_partial_fill(quantity, side="BUY")

        if quantity.as_double() <= 0:
            self.log.warning("Partial fill simulation resulted in zero quantity; skipping order")
            return

        # Create market order
        order = self.order_factory.market(
            instrument_id=self.config.instrument_id,
            order_side=OrderSide.BUY,
            quantity=quantity,
            time_in_force=TimeInForce.IOC,
        )
        self.submit_order(order)
        
        # Queue SL/TP orders if provided (handled in on_position_opened)
        self._pending_sl = sl_price
        self._pending_tp = tp_price
        
        self.log.info(f"Entering LONG with qty={quantity}")
    
    def _enter_short(self, quantity: Quantity, sl_price: Optional[Price] = None, tp_price: Optional[Price] = None) -> None:
        """Enter a short position."""
        if self._position is not None:
            self.log.warning("Cannot enter short - position already exists")
            return
        
        # Partial fill simulation
        if getattr(self.config, "partial_fill_prob", 0) > 0:
            if random.random() < float(self.config.partial_fill_prob):
                quantity = quantity * Decimal(str(self.config.partial_fill_ratio))
                self.log.info(f"Partial fill simulated (SHORT): qty adjusted to {quantity}")

        # Partial fill simulation
        quantity = self._simulate_partial_fill(quantity, side="SELL")

        if quantity.as_double() <= 0:
            self.log.warning("Partial fill simulation resulted in zero quantity; skipping order")
            return

        order = self.order_factory.market(
            instrument_id=self.config.instrument_id,
            order_side=OrderSide.SELL,
            quantity=quantity,
            time_in_force=TimeInForce.IOC,
        )
        self.submit_order(order)
        
        self._pending_sl = sl_price
        self._pending_tp = tp_price
        
        self.log.info(f"Entering SHORT with qty={quantity}")
    
    def _close_position(self) -> None:
        """Close current position."""
        if self._position is None:
            return
        
        self.close_position(self._position)
        self.log.info("Closing position")
    
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
        
        # Submit Stop Loss
        if self._pending_sl:
            sl_order = self.order_factory.stop_market(
                instrument_id=self.instrument.id,
                order_side=exit_side,
                quantity=qty,
                trigger_price=self._pending_sl,
                time_in_force=TimeInForce.GTC,
                reduce_only=True,
            )
            self.submit_order(sl_order)
            self.log.info(f"SL order submitted @ {self._pending_sl}")
        
        # Submit Take Profit
        if self._pending_tp:
            tp_order = self.order_factory.limit(
                instrument_id=self.instrument.id,
                order_side=exit_side,
                quantity=qty,
                price=self._pending_tp,
                time_in_force=TimeInForce.GTC,
                reduce_only=True,
            )
            self.submit_order(tp_order)
        self.log.info(f"TP order submitted @ {self._pending_tp}")
        
        # Clear pending
        self._pending_sl = None
        self._pending_tp = None

    def _simulate_partial_fill(self, quantity: Quantity, side: str) -> Quantity:
        """
        Apply a simple partial fill model:
        - Base probability from config.partial_fill_prob
        - Spread-aware degradation: higher spread ratio => lower fill ratio
        """
        if not hasattr(quantity, "as_double"):
            quantity = Quantity.from_str(f"{float(quantity):.2f}")
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
        if cfg_prob > 0 and random.random() < cfg_prob:
            fill_ratio *= cfg_ratio

        # Fill rejection modeled by spread + base
        reject_prob = max(0.0, reject_base + max(0.0, spread_ratio - 1.0) * reject_spread)
        if fill_model == "worst_case":
            reject_prob += 0.1
        elif fill_model == "immediate":
            reject_prob = 0.0

        if reject_prob > 0 and random.random() < reject_prob:
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
        return Quantity.from_str(str(round(max(0.0, adj), 2)))
    
    # ========== Utility Methods ==========
    
    def _trim_bars(self, bars: List[Bar], max_count: int) -> None:
        """Keep bar list at max size."""
        if len(bars) > max_count:
            del bars[:-max_count]
    
    def _has_enough_data(self) -> bool:
        """Check if we have enough data for analysis."""
        min_ltf = 50
        min_mtf = 20 if self.config.use_mtf else 0
        min_htf = 10 if self.config.use_mtf else 0
        
        return (
            len(self._ltf_bars) >= min_ltf and
            (not self.config.mtf_bar_type or len(self._mtf_bars) >= min_mtf) and
            (not self.config.htf_bar_type or len(self._htf_bars) >= min_htf)
        )

    def _compute_equity_from_tick(self, tick: QuoteTick) -> Optional[float]:
        """Mark-to-market equity using the current tick."""
        if self._position is None or self.instrument is None:
            return None

        mid = (tick.bid_price.as_double() + tick.ask_price.as_double()) / 2.0
        entry = self._position.avg_px_open.as_double()
        qty = self._position.quantity.as_double()
        point_value = 1.0  # adjust per broker if needed

        if self._position.side == PositionSide.LONG:
            unrealized = (mid - entry) * qty * point_value
        else:
            unrealized = (entry - mid) * qty * point_value

        # _equity_base already includes realized PnL; avoid double-counting _daily_pnl
        return self._equity_base + unrealized

    def _calculate_execution_cost(self, side: str, price: float, quantity: float) -> float:
        """
        Calculate per-fill slippage + commission using configured ExecutionModel.
        """
        try:
            if not self._execution_model or quantity <= 0:
                return 0.0
            slip_price = self._execution_model.apply_slippage(
                side=side,
                current_price=Decimal(str(price)),
            )
            slip_cost = abs(float(slip_price) - float(price)) * float(quantity)
            commission_cost = float(self._execution_model.commission(Decimal(str(quantity))))
            return slip_cost + commission_cost
        except Exception as exc:  # pragma: no cover
            self.log.debug(f"Execution cost calc failed: {exc}")
            return 0.0

    def _apply_drawdown_limits(self, analysis: Optional[Any]) -> None:
        """Block trading when drawdown thresholds are breached."""
        if analysis is None or not getattr(self, "_drawdown_tracker", None):
            return

        daily_limit_pct = float(getattr(self.config, "daily_loss_limit_pct", getattr(self.config, "max_daily_loss_pct", 5.0)))
        total_limit_pct = float(getattr(self.config, "total_loss_limit_pct", getattr(self.config, "max_total_loss_pct", 10.0)))

        daily_dd = getattr(self._drawdown_tracker, "get_daily_drawdown_pct", lambda: 0.0)()
        total_dd = getattr(self._drawdown_tracker, "get_total_drawdown_pct", lambda: 0.0)()

        if daily_dd >= daily_limit_pct or total_dd >= total_limit_pct:
            if self._is_trading_allowed:
                self.log.error(
                    f"Drawdown breach: daily {daily_dd:.2f}% (limit {daily_limit_pct}%), "
                    f"total {total_dd:.2f}% (limit {total_limit_pct}%). Trading halted."
                )
            self._is_trading_allowed = False
            self.log.error(f"[BLOCKED] _is_trading_allowed = False (DD breach: daily={daily_dd:.2f}%, total={total_dd:.2f}%)")
            if self._position:
                self._close_position()
    
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
