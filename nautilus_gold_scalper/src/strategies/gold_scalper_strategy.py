"""
Gold Scalper Strategy - Main XAUUSD trading strategy.
STREAM F - Trading Strategies (Part 2)

Implements the complete SMC (Smart Money Concepts) trading system:
- Multi-timeframe analysis (H1/M15/M5)
- Regime-adaptive execution
- Order flow confirmation
- Prop firm risk management
"""
import logging
import numpy as np
from datetime import datetime, timezone
from decimal import Decimal
from typing import Dict, List, Optional, Any
import random
from pathlib import Path

logger = logging.getLogger(__name__)

from nautilus_trader.config import StrategyConfig
from nautilus_trader.model import Bar, BarType, QuoteTick, TradeTick
from nautilus_trader.model import InstrumentId
from nautilus_trader.model.objects import Price, Quantity

from .base_strategy import BaseGoldStrategy, BaseStrategyConfig
from ..core.definitions import (
    SignalType, SignalQuality, MarketRegime, TradingSession,
    TIER_INVALID, XAUUSD_POINT,
)
from ..indicators.structure_analyzer import MarketBias
from ..core.data_types import ConfluenceResult, RegimeAnalysis, SessionInfo, OrderBlock, FairValueGap

# Import analyzers
from ..indicators.session_filter import SessionFilter
from ..indicators.regime_detector import RegimeDetector
from ..indicators.structure_analyzer import StructureAnalyzer
from ..indicators.footprint_analyzer import FootprintAnalyzer
from ..indicators.order_block_detector import OrderBlockDetector
from ..indicators.fvg_detector import FVGDetector
from ..indicators.liquidity_sweep import LiquiditySweepDetector
from ..indicators.amd_cycle_tracker import AMDCycleTracker

# Import signal generators
from ..signals.mtf_manager import MTFManager
from ..signals.confluence_scorer import ConfluenceScorer
from ..signals.news_calendar import NewsCalendar, NewsTradeAction

# Import risk management
from ..execution.execution_model import ExecutionCosts, ExecutionModel
from ..risk.prop_firm_manager import PropFirmManager
from ..risk.position_sizer import PositionSizer
from ..risk.drawdown_tracker import DrawdownTracker
from ..risk.spread_monitor import SpreadMonitor, SpreadState
from ..risk.circuit_breaker import CircuitBreaker
from ..risk.time_constraint_manager import TimeConstraintManager
from .strategy_selector import StrategySelector, StrategyType, MarketContext
from ..utils.telemetry import TelemetrySink
from ..utils.metrics import MetricsCalculator, PerformanceMetrics


class GoldScalperConfig(BaseStrategyConfig, frozen=True):
    """Configuration for Gold Scalper Strategy."""
    
    # Scoring thresholds
    execution_threshold: int = 70  # TIER_B_MIN - match MQL5 (Bug #2 fix)
    min_mtf_confluence: float = 50.0
    
    # MTF requirements
    require_htf_align: bool = True
    require_mtf_zone: bool = False
    require_ltf_confirm: bool = False
    
    # Mode settings
    aggressive_mode: bool = False
    use_footprint_boost: bool = True
    use_bandit_context: bool = False
    
    # Prop firm settings (Apex/Tradovate)
    prop_firm_enabled: bool = True
    account_balance: float = 100000.0
    daily_loss_limit_pct: float = 5.0
    total_loss_limit_pct: float = 5.0  # Apex trailing DD limit
    
    # News / event filters
    use_news_filter: bool = True
    news_score_penalty: int = -15
    news_size_multiplier: float = 0.5

    # Operational/Apex rules
    flatten_time_et: str = "16:59"  # HH:MM ET hard cutoff
    allow_overnight: bool = False
    slippage_ticks: int = 2
    slippage_multiplier: float = 1.5
    commission_per_contract: float = 2.5
    latency_ms: int = 0
    partial_fill_prob: float = 0.0  # 0-1
    partial_fill_ratio: float = 0.5  # fraction to fill if partial triggers
    use_selector: bool = True
    fill_reject_base: float = 0.0
    fill_reject_spread_factor: float = 0.0
    fill_model: str = "realistic"
    max_spread_pips: float = 50.0
    spread_warning_ratio: float = 2.0
    spread_block_ratio: float = 5.0
    spread_history_size: int = 200
    spread_update_interval: int = 1
    spread_pip_factor: float = 10.0
    time_warning_et: str = "16:00"
    time_urgent_et: str = "16:30"
    time_emergency_et: str = "16:55"
    cb_level_1_losses: int = 3
    cb_level_2_losses: int = 5
    cb_level_3_dd: float = 3.0
    cb_level_4_dd: float = 4.0
    cb_level_5_dd: float = 4.5
    cb_cooldown_1: int = 5
    cb_cooldown_2: int = 15
    cb_cooldown_3: int = 30
    cb_cooldown_4: int = 1440
    cb_size_mult_2: float = 0.75
    cb_size_mult_3: float = 0.5
    cb_auto_recovery: bool = True
    consistency_cap_pct: float = 25.0  # 25% limit (5% margin below Apex 30% for safety)
    telemetry_enabled: bool = True
    telemetry_path: str = "logs/telemetry.jsonl"
    telemetry_capture_spread: bool = True
    telemetry_capture_circuit: bool = True
    telemetry_capture_cutoff: bool = True


class GoldScalperStrategy(BaseGoldStrategy):
    """
    XAUUSD Gold Scalping Strategy using Smart Money Concepts.
    
    Architecture:
    - HTF (H1): Direction filter - NEVER trade against H1 trend
    - MTF (M15): Structure zones - OB, FVG, Liquidity levels
    - LTF (M5): Execution - Entry confirmation & tight SL
    
    Features:
    - SMC order block detection
    - Fair value gap analysis
    - Liquidity sweep identification
    - AMD cycle tracking
    - Order flow (footprint) confirmation
    - Regime-adaptive sizing
    - Prop firm risk management
    """
    
    def __init__(self, config: GoldScalperConfig):
        super().__init__(config=config)
        
        # Analyzers
        self._session_filter: Optional[SessionFilter] = None
        self._regime_detector: Optional[RegimeDetector] = None
        self._structure_analyzer: Optional[StructureAnalyzer] = None
        self._footprint_analyzer: Optional[FootprintAnalyzer] = None
        self._ob_detector: Optional[OrderBlockDetector] = None
        self._fvg_detector: Optional[FVGDetector] = None
        self._sweep_detector: Optional[LiquiditySweepDetector] = None
        self._amd_tracker: Optional[AMDCycleTracker] = None
        
        # Signal generators
        self._mtf_manager: Optional[MTFManager] = None
        self._confluence_scorer: Optional[ConfluenceScorer] = None
        
        # Risk management
        self._prop_firm: Optional[PropFirmManager] = None
        self._position_sizer: Optional[PositionSizer] = None
        self._drawdown_tracker: Optional[DrawdownTracker] = None
        self._news_calendar: Optional[NewsCalendar] = None
        self._news_size_mult: float = 1.0
        self._spread_monitor: Optional[SpreadMonitor] = None
        self._spread_snapshot: Optional[Any] = None
        self._time_manager: Optional[TimeConstraintManager] = None
        self._circuit_breaker: Optional[CircuitBreaker] = None
        self._trading_blocked_today: bool = False
        self._strategy_selector: Optional[StrategySelector] = None
        self._execution_model: Optional[ExecutionModel] = None
        self._fill_costs: Dict[str, float] = {}
        self._consistency_tracker = None
        self._last_spread_state: Optional[int] = None
        self._last_cb_level: Optional[int] = None
        self._telemetry: Optional[TelemetrySink] = None
        
        
        # Performance metrics tracking
        self._trade_pnl_history: List[float] = []
        self._metrics_calculator: Optional[MetricsCalculator] = None
        self._last_metrics_emit: int = 0
        # Analysis state (per timeframe)
        self._htf_bias: MarketBias = MarketBias.RANGING
        self._mtf_order_blocks: List[OrderBlock] = []
        self._mtf_fvgs: List[FairValueGap] = []
        self._current_spread: float = 0.0
    
    def _on_strategy_start(self) -> None:
        """Initialize all analyzers and managers."""
        # Session filter (TEMPORARY DEBUG: Allow all sessions)
        self._session_filter = SessionFilter(
            allow_asian=True,   # TEMPORARY DEBUG
            allow_late_ny=True,  # TEMPORARY DEBUG
        )
        
        # Regime detector
        self._regime_detector = RegimeDetector(
            hurst_period=100,
            entropy_period=50,
        )
        
        # Structure analyzer - use defaults
        self._structure_analyzer = StructureAnalyzer()
        
        # Footprint analyzer (if enabled) - use defaults
        if self.config.use_footprint:
            self._footprint_analyzer = FootprintAnalyzer()
        
        # SMC detectors - use defaults
        self._ob_detector = OrderBlockDetector()
        self._fvg_detector = FVGDetector()
        self._sweep_detector = LiquiditySweepDetector()
        self._amd_tracker = AMDCycleTracker()
        
        # MTF Manager - use defaults
        self._mtf_manager = MTFManager()
        
        # Confluence scorer - pass execution threshold from config (Bug #4 fix)
        self._confluence_scorer = ConfluenceScorer(
            min_score_to_trade=float(self.config.execution_threshold)
        )
        
        # News calendar (optional)
        if self.config.use_news_filter:
            self._news_calendar = NewsCalendar()
        
        # Risk management (if prop firm mode)
        if self.config.prop_firm_enabled:
            from ..risk.prop_firm_manager import PropFirmLimits
            limits = PropFirmLimits(
                account_size=self.config.account_balance,
                daily_loss_limit=self.config.account_balance * float(self.config.daily_loss_limit_pct) / 100,
                trailing_drawdown=self.config.account_balance * float(self.config.total_loss_limit_pct) / 100,
            )
            self._prop_firm = PropFirmManager(limits=limits)
            self._prop_firm.set_strategy(self)
            
            self._position_sizer = PositionSizer(
                risk_per_trade=float(self.config.risk_per_trade) / 100,
            )
            
            self._drawdown_tracker = DrawdownTracker(
                initial_equity=float(self.config.account_balance),
                max_daily=float(self.config.daily_loss_limit_pct) / 100.0,
                max_total=float(self.config.total_loss_limit_pct) / 100.0,
            )
            # Initialize prop-firm state with starting equity
            self._prop_firm.initialize(starting_equity=float(self.config.account_balance))
            # Expose consistency tracker for strategy-level guards/resets
            self._consistency_tracker = getattr(self._prop_firm, "_consistency", None)
            if self._consistency_tracker:
                try:
                    self._consistency_tracker.consistency_limit = Decimal(str(self.config.consistency_cap_pct / 100.0))
                except Exception:
                    pass

        # Telemetry sink
        self._telemetry = TelemetrySink(
            Path(getattr(self.config, "telemetry_path", "logs/telemetry.jsonl")),
            enabled=bool(getattr(self.config, "telemetry_enabled", True)),
        )
        
        # Initialize metrics calculator
        self._metrics_calculator = MetricsCalculator(
            risk_free_rate=0.05,
            trading_days_per_year=252
        )

        # Spread monitor (risk realism)
        self._spread_monitor = SpreadMonitor(
            symbol="XAUUSD",
            history_size=int(self.config.spread_history_size),
            warning_ratio=float(self.config.spread_warning_ratio),
            block_ratio=float(self.config.spread_block_ratio),
            max_spread_pips=float(self.config.max_spread_pips),
            update_interval=int(self.config.spread_update_interval),
            pip_factor=float(self.config.spread_pip_factor),
        )

        # Apex time cutoff manager
        self._time_manager = TimeConstraintManager(
            strategy=self,
            allow_overnight=self.config.allow_overnight,
            cutoff=self._parse_cutoff(self.config.flatten_time_et),
            warning=self._parse_cutoff(self.config.time_warning_et),
            urgent=self._parse_cutoff(self.config.time_urgent_et),
            emergency=self._parse_cutoff(self.config.time_emergency_et),
            telemetry=self._telemetry if getattr(self.config, "telemetry_capture_cutoff", True) else None,
        )

        # Circuit breaker integration
        self._circuit_breaker = CircuitBreaker(
            daily_loss_limit=float(self.config.daily_loss_limit_pct) / 100.0,
            total_loss_limit=float(self.config.total_loss_limit_pct) / 100.0,
        )
        if self._circuit_breaker:
            self._circuit_breaker.LEVEL_1_LOSSES = int(self.config.cb_level_1_losses)
            self._circuit_breaker.LEVEL_2_LOSSES = int(self.config.cb_level_2_losses)
            self._circuit_breaker.LEVEL_3_DD = float(self.config.cb_level_3_dd)
            self._circuit_breaker.LEVEL_4_DD = float(self.config.cb_level_4_dd)
            self._circuit_breaker.LEVEL_5_DD = float(self.config.cb_level_5_dd)
            self._circuit_breaker.LEVEL_1_COOLDOWN = int(self.config.cb_cooldown_1)
            self._circuit_breaker.LEVEL_2_COOLDOWN = int(self.config.cb_cooldown_2)
            self._circuit_breaker.LEVEL_3_COOLDOWN = int(self.config.cb_cooldown_3)
            self._circuit_breaker.LEVEL_4_COOLDOWN = int(self.config.cb_cooldown_4)
            self._circuit_breaker.LEVEL_2_SIZE_MULT = float(self.config.cb_size_mult_2)
            self._circuit_breaker.LEVEL_3_SIZE_MULT = float(self.config.cb_size_mult_3)
            self._circuit_breaker._enable_auto_recovery = bool(self.config.cb_auto_recovery)

        # Execution realism (per-fill slippage + commission)
        try:
            base_cents = Decimal(str(max(1, getattr(self.config, "slippage_ticks", 2))))
            comm_per_lot = Decimal(str(getattr(self.config, "commission_per_contract", 2.5)))
            costs = ExecutionCosts(
                base_slippage_cents=base_cents,
                slippage_multiplier=Decimal(str(getattr(self.config, "slippage_multiplier", 1.5))),
                commission_per_lot=comm_per_lot,
            )
            self._execution_model = ExecutionModel(costs)
        except Exception as exc:
            self.log.debug(f"ExecutionModel setup failed, fallback to zero costs: {exc}")
            self._execution_model = None

        # Strategy selector (regime/session/safety aware)
        if self.config.use_selector:
            self._strategy_selector = StrategySelector()
        
        # Validate all critical analyzers
        if not self._validate_analyzers():
            self.log.error("Analyzer validation failed - stopping strategy")
            self.stop()
            return
        
        self.log.info("Gold Scalper Strategy initialized with all analyzers")
    
    def _validate_analyzers(self) -> bool:
        """
        Verify all critical analyzers are properly initialized.
        
        Returns:
            True if all required analyzers are functional, False otherwise
        """
        required = [
            ('structure_analyzer', self._structure_analyzer),
            ('regime_detector', self._regime_detector),
            ('confluence_scorer', self._confluence_scorer),
            ('mtf_manager', self._mtf_manager),
            ('ob_detector', self._ob_detector),
            ('fvg_detector', self._fvg_detector),
            ('sweep_detector', self._sweep_detector),
            ('session_filter', self._session_filter),
        ]
        
        for name, analyzer in required:
            if analyzer is None:
                self.log.error(f"Critical analyzer not initialized: {name}")
                return False
        
        self.log.info("All critical analyzers validated successfully")
        return True
    
    def _check_daily_reset(self, timestamp_ns: int) -> None:
        """
        Reset daily counters at day change using **ET calendar days**.
        
        Apex rules (cutoff 16:59 ET, no overnight) require resets on the
        Eastern Time boundary; otherwise, after the cutoff the strategy stays
        blocked until 00:00 UTC and misses London/NY next day.
        """
        from datetime import datetime
        try:
            from zoneinfo import ZoneInfo
            et_tz = ZoneInfo("America/New_York")
        except Exception:  # pragma: no cover
            from datetime import timezone
            et_tz = timezone.utc
        
        current_date_et = datetime.fromtimestamp(timestamp_ns / 1e9, tz=et_tz).date()
        
        if not hasattr(self, '_last_reset_date'):
            self._last_reset_date = current_date_et
            return
        
        if current_date_et != self._last_reset_date:
            self.log.info(f"=== NEW TRADING DAY (ET): {current_date_et} ===")
            
            # Reset daily counters
            self._daily_trades = 0
            self._daily_pnl = 0.0
            # Re-enable trading after prior-day cutoff/blocks
            self._is_trading_allowed = True
            self._trading_blocked_today = False
            self.log.info("[DAILY_RESET] trading_allowed=True (lifted prior cutoff/blocks)")
            if self._drawdown_tracker:
                try:
                    self._drawdown_tracker.reset_daily()
                except Exception:
                    pass
            
            # Reset prop firm manager if active
            if self._prop_firm is not None:
                try:
                    self._prop_firm.on_new_day(current_equity=self._equity_base)
                except Exception:
                    self.log.debug("PropFirmManager daily reset failed", exc_info=True)
            
            # Reset drawdown tracker if active
            if self._drawdown_tracker is not None and hasattr(self._drawdown_tracker, 'on_new_day'):
                self._drawdown_tracker.on_new_day()

            if self._time_manager:
                self._time_manager.reset_daily()
            if self._consistency_tracker:
                self._consistency_tracker.reset_daily()
            if self._circuit_breaker:
                self._circuit_breaker.reset_daily()
            
            self._last_reset_date = current_date_et
            self.log.info("Daily reset complete (ET)")
    
    def _on_strategy_stop(self) -> None:
        """Cleanup analyzers."""
        # Calculate and emit final performance metrics
        self._calculate_and_emit_metrics()
        
        self.log.info("Gold Scalper Strategy cleanup complete")
    
    def _on_htf_bar(self, bar: Bar) -> None:
        """Process H1 bar - Update directional bias."""
        if not self._structure_analyzer:
            return
        
        # Extract OHLCV from bars
        closes = np.array([b.close.as_double() for b in self._htf_bars[-200:]])
        highs = np.array([b.high.as_double() for b in self._htf_bars[-200:]])
        lows = np.array([b.low.as_double() for b in self._htf_bars[-200:]])
        
        if len(closes) < 50:
            return
        
        # Analyze structure for bias
        state = self._structure_analyzer.analyze(highs, lows, closes)
        self._htf_bias = state.bias
        
        # Update regime (do NOT block trading here - check in _check_for_signal instead)
        if self._regime_detector:
            self._current_regime = self._regime_detector.analyze(closes)
            self.log.info(f"[HTF_REGIME] Regime detected: {self._current_regime.regime}")
        
        if self.config.debug_mode:
            self.log.debug(f"HTF Bias: {self._htf_bias}, Regime: {self._current_regime.regime if self._current_regime else 'N/A'}")
    
    def _on_mtf_bar(self, bar: Bar) -> None:
        """Process M15 bar - Update structure zones."""
        if len(self._mtf_bars) < 30:
            return
        
        closes = np.array([b.close.as_double() for b in self._mtf_bars[-100:]])
        highs = np.array([b.high.as_double() for b in self._mtf_bars[-100:]])
        lows = np.array([b.low.as_double() for b in self._mtf_bars[-100:]])
        opens = np.array([b.open.as_double() for b in self._mtf_bars[-100:]])
        volumes = np.array([b.volume.as_double() for b in self._mtf_bars[-100:]])
        
        # Detect order blocks
        if self._ob_detector:
            self._mtf_order_blocks = self._ob_detector.detect(
                opens, highs, lows, closes, volumes
            )
        
        # Detect FVGs
        if self._fvg_detector:
            self._mtf_fvgs = self._fvg_detector.detect(
                highs, lows, closes
            )
        
        if self.config.debug_mode:
            self.log.debug(f"MTF: {len(self._mtf_order_blocks)} OBs, {len(self._mtf_fvgs)} FVGs")
    
    def _on_ltf_bar(self, bar: Bar) -> None:
        """Process M5 bar - Update execution-level analysis."""
        # Ensure daily counters unblock trading when a new ET day starts
        self._check_daily_reset(bar.ts_event)

        # Enforce intraday operational rules (Apex)
        if self._time_manager and not self._time_manager.check(bar.ts_event):
            return
        # Main signal checking done in _check_for_signal
        pass
    
    def _check_for_signal(self, bar: Bar) -> None:
        """Check for trading signal and execute if valid."""
        # Import datetime at function start (used by multiple checks below)
        from datetime import datetime, timezone
        
        # Debug: Log periodically
        log_interval = 100  # Log every 100 bars for visibility
        should_log = len(self._ltf_bars) % log_interval == 0
        
        if should_log:
            self.log.info(f"[SIGNAL_CHECK] Bar {len(self._ltf_bars)}: flat={self.is_flat}, allowed={self._is_trading_allowed}")
        
        # Safety checks
        if not self.instrument:
            logger.error("Cannot check signal: instrument not loaded")
            if self._telemetry:
                self._telemetry.emit("signal_reject", {"reason": "no_instrument", "bar": len(self._ltf_bars)})
            return
        
        if not self._is_trading_allowed:
            if should_log:
                self.log.info("[SIGNAL_CHECK] Trading not allowed (general flag)")
            if self._telemetry:
                self._telemetry.emit("signal_reject", {"reason": "trading_not_allowed", "bar": len(self._ltf_bars)})
            return
        
        # Reset per-bar news multiplier
        self._news_size_mult = 1.0
        
        if not self.is_flat:
            if should_log:
                self.log.info("[SIGNAL_CHECK] Already in position - skipping")
            return  # Already in a position
        
        # Check session (only if enabled)
        if self.config.use_session_filter and self._session_filter:
            # Use bar timestamp for backtesting, not current time!
            bar_time = datetime.fromtimestamp(bar.ts_event / 1e9, tz=timezone.utc)
            self._current_session = self._session_filter.get_session_info(bar_time)
            
            if not self._current_session.is_trading_allowed:
                if should_log:
                    self.log.info(f"[SIGNAL_CHECK] Session filter BLOCKED: {self._current_session.session.name if self._current_session else 'UNKNOWN'}")
                if self._telemetry:
                    self._telemetry.emit("signal_reject", {
                        "reason": "session_filter",
                        "session": self._current_session.session.name if self._current_session else "UNKNOWN",
                        "bar": len(self._ltf_bars)
                    })
                return

        # Apex cutoff / overnight guard (block new trades after cutoff)
        if self._time_manager and not self._time_manager.check(bar.ts_event):
            if should_log:
                self.log.info("[SIGNAL_CHECK] Time manager BLOCKED (apex cutoff or outside hours)")
            if self._telemetry:
                self._telemetry.emit("signal_reject", {"reason": "time_cutoff", "bar": len(self._ltf_bars)})
            return
        if getattr(self, "_trading_blocked_today", False):
            if should_log:
                self.log.info("[SIGNAL_CHECK] Trading blocked today flag set")
            if self._telemetry:
                self._telemetry.emit("signal_reject", {"reason": "blocked_today", "bar": len(self._ltf_bars)})
            return
        
        # Check prop firm limits (only if enabled)
        if self.config.prop_firm_enabled and self._prop_firm and not self._prop_firm.can_trade():
            if should_log:
                self.log.info("[SIGNAL_CHECK] Prop firm manager BLOCKED")
            if self._telemetry:
                self._telemetry.emit("signal_reject", {"reason": "prop_firm", "bar": len(self._ltf_bars)})
            self._is_trading_allowed = False
            self.log.warning(f"[BLOCKED] _is_trading_allowed = False (prop_firm.can_trade() returned False)")
            return

        # Circuit breaker gate
        if self._circuit_breaker:
            cb_state = self._circuit_breaker.get_state()
            if self._last_cb_level != cb_state.level:
                self._last_cb_level = cb_state.level
                self.log.warning(
                    f'{{"event":"circuit_state","level":"{cb_state.level.name}","can_trade":{cb_state.can_trade},'
                    f'"size_mult":{cb_state.size_multiplier:.2f},"daily_dd":{cb_state.daily_dd_percent:.2f},'
                    f'"total_dd":{cb_state.total_dd_percent:.2f},"consec_losses":{cb_state.consecutive_losses}}}'
                )
                if self._telemetry and getattr(self.config, "telemetry_capture_circuit", True):
                    self._telemetry.emit(
                        "circuit_state",
                        {
                            "level": cb_state.level.name,
                            "can_trade": cb_state.can_trade,
                            "size_mult": cb_state.size_multiplier,
                            "daily_dd": cb_state.daily_dd_percent,
                            "total_dd": cb_state.total_dd_percent,
                            "consec_losses": cb_state.consecutive_losses,
                        },
                    )
            if not cb_state.can_trade:
                if should_log:
                    self.log.info(f"[SIGNAL_CHECK] Circuit breaker BLOCKED (level={cb_state.level.name})")
                if self._telemetry:
                    self._telemetry.emit("signal_reject", {
                        "reason": "circuit_breaker",
                        "level": cb_state.level.name,
                        "bar": len(self._ltf_bars)
                    })
                return

        # Strategy selector gate (regime/session/safety context)
        if self._strategy_selector:
            context = MarketContext(
                hurst=self._current_regime.hurst_exponent if self._current_regime else 0.5,
                entropy=self._current_regime.shannon_entropy if self._current_regime else 2.0,
                is_trending=self._current_regime.regime == MarketRegime.REGIME_PRIME_TRENDING if self._current_regime else False,
                is_reverting=self._current_regime.regime in [MarketRegime.REGIME_PRIME_REVERTING, MarketRegime.REGIME_NOISY_REVERTING] if self._current_regime else False,
                is_random=self._current_regime.regime == MarketRegime.REGIME_RANDOM_WALK if self._current_regime else True,
                is_london=self._current_session.session == TradingSession.SESSION_LONDON if self._current_session else False,
                is_newyork=self._current_session.session == TradingSession.SESSION_NY if self._current_session else False,
                is_overlap=self._current_session.session == TradingSession.SESSION_LONDON_NY_OVERLAP if self._current_session else False,
                is_asian=self._current_session.session == TradingSession.SESSION_ASIAN if self._current_session else False,
                circuit_ok=True if not self._circuit_breaker else self._circuit_breaker.can_trade(),
                spread_ok=self._spread_snapshot.can_trade if self._spread_snapshot else True,
                spread_ratio=self._spread_snapshot.spread_ratio if self._spread_snapshot and hasattr(self._spread_snapshot, "spread_ratio") else 1.0,
                daily_dd_percent=self._drawdown_tracker.get_daily_drawdown_pct() if self._drawdown_tracker else 0.0,
                total_dd_percent=self._drawdown_tracker.get_total_drawdown_pct() if self._drawdown_tracker else 0.0,
            )
            selection = self._strategy_selector.select_strategy(context)
            if selection.strategy in (StrategyType.STRATEGY_NONE, StrategyType.STRATEGY_SAFE_MODE):
                if should_log:
                    self.log.info(f"[SIGNAL_CHECK] Strategy selector BLOCKED: {selection.strategy.name}, reason={selection.reason}")
                if self._telemetry:
                    self._telemetry.emit("signal_reject", {
                        "reason": "strategy_selector",
                        "strategy": selection.strategy.name,
                        "selector_reason": selection.reason,
                        "bar": len(self._ltf_bars)
                    })
                return

        # Consistency rule (30% daily of cumulative profit)
        if self._consistency_tracker and not self._consistency_tracker.can_trade():
            if should_log:
                self.log.info("[SIGNAL_CHECK] Consistency tracker BLOCKED (30% daily profit cap)")
            if self._telemetry:
                self._telemetry.emit("signal_reject", {"reason": "consistency_cap", "bar": len(self._ltf_bars)})
            self._is_trading_allowed = False
            self.log.warning(f"[BLOCKED] _is_trading_allowed = False (consistency_tracker 30% daily cap)")
            return

        # Circuit breaker guard
        if self._circuit_breaker and not self._circuit_breaker.can_trade():
            if should_log:
                self.log.info("[SIGNAL_CHECK] Circuit breaker guard BLOCKED")
            if self._telemetry:
                self._telemetry.emit("signal_reject", {"reason": "circuit_breaker_guard", "bar": len(self._ltf_bars)})
            self._is_trading_allowed = False
            self.log.warning(f"[BLOCKED] _is_trading_allowed = False (circuit_breaker.can_trade() returned False)")
            return
        
        # News filter (uses bar timestamp for backtest realism)
        news_window = None
        if self.config.use_news_filter and self._news_calendar:
            bar_time = datetime.fromtimestamp(bar.ts_event / 1e9, tz=timezone.utc)
            news_window = self._news_calendar.check_news_window(now=bar_time)
            if news_window.action == NewsTradeAction.BLOCK:
                if should_log:
                    self.log.info(f"[SIGNAL_CHECK] News filter BLOCKED: {news_window.reason}")
                if self._telemetry:
                    self._telemetry.emit("signal_reject", {
                        "reason": "news_filter",
                        "news_reason": news_window.reason,
                        "bar": len(self._ltf_bars)
                    })
                return
            # apply conservative size/score adjustments
            self._news_size_mult = max(news_window.size_multiplier, 0.0)
        
        # Check spread
        spread_score_adj = 0
        spread_size_mult = 1.0
        if self._spread_snapshot:
            if not self._spread_snapshot.can_trade:
                if should_log:
                    self.log.info(f"[SIGNAL_CHECK] Spread BLOCKED: {self._spread_snapshot.reason}")
                if self._telemetry:
                    self._telemetry.emit("signal_reject", {
                        "reason": "spread_monitor",
                        "spread_reason": self._spread_snapshot.reason,
                        "bar": len(self._ltf_bars)
                    })
                return
            spread_score_adj = self._spread_snapshot.score_adjustment
            spread_size_mult = self._spread_snapshot.size_multiplier

        if self._current_spread > self.config.max_spread_points:
            if should_log:
                self.log.info(f"[SIGNAL_CHECK] Spread too high: {self._current_spread} > {self.config.max_spread_points}")
            if self._telemetry:
                self._telemetry.emit("signal_reject", {
                    "reason": "spread_too_high",
                    "spread": self._current_spread,
                    "max": self.config.max_spread_points,
                    "bar": len(self._ltf_bars)
                })
            return
        
        # HTF alignment check (only if required)
        if self.config.require_htf_align:
            if self._htf_bias == MarketBias.RANGING:
                if should_log:
                    self.log.info("[SIGNAL_CHECK] HTF bias RANGING - blocked")
                if self._telemetry:
                    self._telemetry.emit("signal_reject", {"reason": "htf_ranging", "bar": len(self._ltf_bars)})
                return
        
        # Calculate confluence score
        if should_log:
            self.log.info(f"[SIGNAL_CHECK] Calculating confluence at bar {len(self._ltf_bars)}...")
        confluence_result = self._calculate_confluence(bar)
        
        if confluence_result is None:
            if should_log:
                self.log.info(f"[SIGNAL_CHECK] Confluence returned None (insufficient data or error)")
            if self._telemetry:
                self._telemetry.emit("signal_reject", {"reason": "confluence_none", "bar": len(self._ltf_bars)})
            return
        
        news_score_adj = news_window.score_adjustment if news_window else 0
        effective_score = confluence_result.total_score + news_score_adj + spread_score_adj
        
        # ALWAYS log score calculation (critical for debugging)
        self.log.info(
            f"[SCORE] Bar {len(self._ltf_bars)}: base={confluence_result.total_score:.1f}, "
            f"news={news_score_adj:+.1f}, spread={spread_score_adj:+.1f}, "
            f"effective={effective_score:.1f}, signal={confluence_result.direction.name}, "
            f"threshold={self.config.execution_threshold}"
        )
        if self._telemetry:
            self._telemetry.emit("score_calculated", {
                "bar": len(self._ltf_bars),
                "base_score": confluence_result.total_score,
                "news_adj": news_score_adj,
                "spread_adj": spread_score_adj,
                "effective_score": effective_score,
                "signal": confluence_result.direction.name,
                "threshold": self.config.execution_threshold
            })
        
        self._last_confluence = confluence_result
        
        # Check if score meets threshold
        if effective_score < self.config.execution_threshold:
            self.log.info(f"[SIGNAL_CHECK] Score {effective_score:.1f} BELOW threshold {self.config.execution_threshold}")
            if self._telemetry:
                self._telemetry.emit("signal_reject", {
                    "reason": "score_below_threshold",
                    "score": effective_score,
                    "threshold": self.config.execution_threshold,
                    "bar": len(self._ltf_bars)
                })
            return
        
        # Determine signal direction
        signal = confluence_result.direction
        
        if signal == SignalType.SIGNAL_NONE:
            return
        
        # Calculate position size
        sl_distance = self._calculate_sl_distance(bar, signal)
        
        if sl_distance <= 0:
            return
        
        quantity = self._calculate_position_size(sl_distance)
        
        if quantity is None or float(quantity) <= 0:
            return
        
        # Calculate SL and TP prices
        from decimal import Decimal, ROUND_DOWN
        
        current_price = bar.close.as_double()
        
        if signal == SignalType.SIGNAL_BUY:
            # Use Decimal for precise price calculations
            current_decimal = Decimal(str(current_price))
            sl_decimal = current_decimal - Decimal(str(sl_distance))
            sl_price = Price(sl_decimal.quantize(Decimal('0.01'), rounding=ROUND_DOWN), precision=2)
            
            tp_distance = sl_distance * self.config.target_rr_ratio
            tp_decimal = current_decimal + Decimal(str(tp_distance))
            tp_price = Price(tp_decimal.quantize(Decimal('0.01'), rounding=ROUND_DOWN), precision=2)
            
            self.log.info(
                f"BUY Signal: Score={confluence_result.total_score:.1f}, "
                f"Quality={confluence_result.quality.name}, "
                f"SL={sl_price}, TP={tp_price}"
            )
            self._enter_long(quantity, sl_price, tp_price)
            
        elif signal == SignalType.SIGNAL_SELL:
            # Use Decimal for precise price calculations
            current_decimal = Decimal(str(current_price))
            sl_decimal = current_decimal + Decimal(str(sl_distance))
            sl_price = Price(sl_decimal.quantize(Decimal('0.01'), rounding=ROUND_DOWN), precision=2)
            
            tp_distance = sl_distance * self.config.target_rr_ratio
            tp_decimal = current_decimal - Decimal(str(tp_distance))
            tp_price = Price(tp_decimal.quantize(Decimal('0.01'), rounding=ROUND_DOWN), precision=2)
            
            self.log.info(
                f"SELL Signal: Score={confluence_result.total_score:.1f}, "
                f"Quality={confluence_result.quality.name}, "
                f"SL={sl_price}, TP={tp_price}"
            )
            self._enter_short(quantity, sl_price, tp_price)
    
    def _calculate_confluence(self, bar: Bar) -> Optional[ConfluenceResult]:
        """Calculate confluence score from all analysis components."""
        if not self._confluence_scorer:
            print("[CONFLUENCE] Scorer not initialized")
            return None
        
        try:
            # Get LTF data
            closes = np.array([b.close.as_double() for b in self._ltf_bars[-200:]])
            highs = np.array([b.high.as_double() for b in self._ltf_bars[-200:]])
            lows = np.array([b.low.as_double() for b in self._ltf_bars[-200:]])
            volumes = np.array([b.volume.as_double() for b in self._ltf_bars[-200:]])
            
            if len(closes) < 50:
                print(f"[CONFLUENCE] Not enough closes: {len(closes)}")
                return None
            
            # Analyze individual components
            structure_state = self._analyze_structure_component(highs, lows, closes)
            footprint_score = self._analyze_footprint_component(bar)
            sweeps = self._analyze_sweeps_component(highs, lows, closes)
            amd_cycle = self._analyze_amd_component(highs, lows, closes, volumes)
            mtf_score, mtf_aligned = self._analyze_mtf_component(structure_state)
            
            # Analyze regime on LTF if HTF regime not available
            if self._current_regime is None and self._regime_detector and len(closes) >= 100:
                self._current_regime = self._regime_detector.analyze(closes)
            
            # Detect order blocks on LTF (refresh every 20 bars)
            if self._ob_detector and len(self._ltf_bars) % 20 == 0:
                try:
                    self._mtf_order_blocks = self._ob_detector.detect(highs, lows, closes, volumes)
                except Exception as e:
                    logger.debug(f"OB detection error: {e}")
            
            # Detect FVGs on LTF (refresh every 20 bars)
            if self._fvg_detector and len(self._ltf_bars) % 20 == 0:
                try:
                    self._mtf_fvgs = self._fvg_detector.detect(highs, lows, closes)
                except Exception as e:
                    logger.debug(f"FVG detection error: {e}")
            
            # Calculate final confluence
            if len(self._ltf_bars) % 100 == 0:
                print(f"[CONFLUENCE] structure={structure_state is not None}, regime={self._current_regime is not None}, mtf_score={mtf_score:.1f}")
            
            # Get current session enum for weight profile
            current_session_enum = TradingSession.SESSION_UNKNOWN
            if self._current_session:
                current_session_enum = self._current_session.session
            
            result = self._confluence_scorer.calculate_score(
                structure_state=structure_state,
                regime_analysis=self._current_regime,
                session_info=self._current_session,
                order_blocks=self._mtf_order_blocks,
                fvgs=self._mtf_fvgs,
                sweeps=sweeps,
                amd_cycle=amd_cycle,
                mtf_score=mtf_score,
                mtf_aligned=mtf_aligned,
                footprint_score=footprint_score,
                current_session=current_session_enum,
            )
            
            if len(self._ltf_bars) % 100 == 0:
                if result:
                    print(f"[CONFLUENCE] Result: score={result.total_score:.1f}, signal={result.direction}")
                else:
                    print(f"[CONFLUENCE] Result is None from scorer")
            
            return result
            
        except Exception as e:
            print(f"[CONFLUENCE] Exception: {e}")
            return None
    
    def _analyze_structure_component(self, highs: np.ndarray, lows: np.ndarray, closes: np.ndarray) -> Optional[Any]:
        """Analyze market structure component."""
        if not self._structure_analyzer:
            return None
        
        try:
            return self._structure_analyzer.analyze(highs, lows, closes)
        except Exception as e:
            logger.error(f"Structure analysis failed: {e}")
            return None
    
    def _analyze_footprint_component(self, bar: Bar) -> float:
        """Analyze footprint/order flow component."""
        if not self._footprint_analyzer or not self.config.use_footprint:
            return 0.0
        
        try:
            fp_result = self._footprint_analyzer.analyze_bar(
                bar.open.as_double(),
                bar.high.as_double(),
                bar.low.as_double(),
                bar.close.as_double(),
                int(bar.volume.as_double()),
            )
            return fp_result.score if fp_result else 0.0
        except Exception as e:
            logger.error(f"Footprint analysis failed: {e}")
            return 0.0
    
    def _analyze_sweeps_component(self, highs: np.ndarray, lows: np.ndarray, closes: np.ndarray) -> List[Any]:
        """Analyze liquidity sweeps component."""
        if not self._sweep_detector:
            return []
        
        try:
            # detect() returns Tuple[List[LiquidityPool], List[LiquiditySweep]]
            pools, sweeps = self._sweep_detector.detect(highs, lows, closes)
            return sweeps
        except Exception as e:
            logger.error(f"Sweep detection failed: {e}")
            return []
    
    def _analyze_amd_component(
        self, 
        highs: np.ndarray, 
        lows: np.ndarray, 
        closes: np.ndarray, 
        volumes: np.ndarray
    ) -> Optional[Any]:
        """Analyze AMD cycle component."""
        if not self._amd_tracker:
            return None
        
        try:
            return self._amd_tracker.analyze(highs, lows, closes, volumes)
        except Exception as e:
            logger.error(f"AMD tracking failed: {e}")
            return None
    
    def _analyze_mtf_component(self, structure_state: Optional[Any]) -> tuple[float, bool]:
        """Analyze multi-timeframe alignment component using bar data."""
        if not self._mtf_manager or not self.config.use_mtf:
            return 0.0, False
        
        # Need enough history on each TF
        if len(self._htf_bars) < 50 or len(self._mtf_bars) < 50 or len(self._ltf_bars) < 50:
            return 0.0, False
        
        try:
            htf_highs = np.array([b.high.as_double() for b in self._htf_bars[-200:]])
            htf_lows  = np.array([b.low.as_double() for b in self._htf_bars[-200:]])
            htf_closes= np.array([b.close.as_double() for b in self._htf_bars[-200:]])
            mtf_highs = np.array([b.high.as_double() for b in self._mtf_bars[-200:]])
            mtf_lows  = np.array([b.low.as_double() for b in self._mtf_bars[-200:]])
            mtf_closes= np.array([b.close.as_double() for b in self._mtf_bars[-200:]])
            ltf_highs = np.array([b.high.as_double() for b in self._ltf_bars[-200:]])
            ltf_lows  = np.array([b.low.as_double() for b in self._ltf_bars[-200:]])
            ltf_closes= np.array([b.close.as_double() for b in self._ltf_bars[-200:]])
            
            mtf_result = self._mtf_manager.analyze(
                htf_data={"highs": htf_highs, "lows": htf_lows, "closes": htf_closes},
                mtf_data={"highs": mtf_highs, "lows": mtf_lows, "closes": mtf_closes},
                ltf_data={"highs": ltf_highs, "lows": ltf_lows, "closes": ltf_closes},
                current_price=self._ltf_bars[-1].close.as_double(),
                session_ok=self._current_session.is_trading_allowed if self._current_session else True,
            )
            return mtf_result.mtf_score, mtf_result.is_aligned
        except Exception as e:
            logger.error(f"MTF analysis failed: {e}")
            return 0.0, False
    
    def _calculate_sl_distance(self, bar: Bar, signal: SignalType) -> float:
        """Calculate stop loss distance based on structure."""
        if not self._structure_analyzer:
            # Fallback to ATR-based SL
            closes = np.array([b.close.as_double() for b in self._ltf_bars[-20:]])
            highs = np.array([b.high.as_double() for b in self._ltf_bars[-20:]])
            lows = np.array([b.low.as_double() for b in self._ltf_bars[-20:]])
            
            tr = np.maximum(highs - lows, np.abs(highs - np.roll(closes, 1)))
            tr = np.maximum(tr, np.abs(lows - np.roll(closes, 1)))
            atr = np.mean(tr[1:])
            
            return atr * 1.5
        
        # Structure-based SL: place behind last swing
        last_low = self._structure_analyzer.get_last_swing_low()
        last_high = self._structure_analyzer.get_last_swing_high()
        
        if signal == SignalType.SIGNAL_BUY and last_low > 0:
            # SL below last swing low
            return bar.close.as_double() - last_low + (bar.close.as_double() * 0.0005)
        
        elif signal == SignalType.SIGNAL_SELL and last_high > 0:
            # SL above last swing high
            return last_high - bar.close.as_double() + (bar.close.as_double() * 0.0005)
        
        # Fallback to ATR
        closes = np.array([b.close.as_double() for b in self._ltf_bars[-20:]])
        highs = np.array([b.high.as_double() for b in self._ltf_bars[-20:]])
        lows = np.array([b.low.as_double() for b in self._ltf_bars[-20:]])
        
        tr = np.maximum(highs - lows, np.abs(highs - np.roll(closes, 1)))
        tr = np.maximum(tr, np.abs(lows - np.roll(closes, 1)))
        atr = np.mean(tr[1:])
        
        return atr * 1.5
    
    def _calculate_position_size(self, sl_distance: float) -> Optional[Quantity]:
        """Calculate position size based on risk and regime."""
        spread_mult = 1.0
        if self._spread_snapshot:
            spread_mult = max(0.0, min(1.0, self._spread_snapshot.size_multiplier))
        if not self._position_sizer:
            # Default sizing
            current_equity = self._equity_base
            risk_amount = current_equity * float(self.config.risk_per_trade) / 100
            risk_amount *= getattr(self, "_news_size_mult", 1.0)
            risk_amount *= spread_mult  # reduce size under high spread
            point_value = 1.0  # Gold point value (adjust per broker)
            lots = risk_amount / (sl_distance * point_value)
            return Quantity.from_str(str(round(max(0.01, lots), 2)))
        
        # Regime-adaptive sizing
        regime_mult = 1.0
        if self._current_regime:
            regime_mult = self._current_regime.size_multiplier
        
        # Calculate base size
        news_mult = getattr(self, "_news_size_mult", 1.0)
        risk_pct = float(self.config.risk_per_trade) * news_mult * spread_mult
        if self._circuit_breaker:
            risk_pct *= self._circuit_breaker.get_size_multiplier()
        
        # Use PositionSizer.calculate_lot
        sl_pips = sl_distance / XAUUSD_POINT  # convert price distance to pips (0.01 per point)
        position_size = self._position_sizer.calculate_lot(
            balance=self._equity_base,
            risk_percent=risk_pct,
            stop_loss_pips=sl_pips,
            regime_multiplier=regime_mult,
            pip_value=self.instrument.pip_value.as_double() if self.instrument and hasattr(self.instrument, "pip_value") else 10.0,
        )
        
        # Normalize to float and wrap into Quantity
        try:
            pos_val = float(position_size)
        except Exception:
            return None
        
        if pos_val <= 0:
            return None
        
        return Quantity.from_str(str(round(max(0.01, pos_val), 2)))
    
    def on_quote_tick(self, tick: QuoteTick) -> None:
        """Track spread for spread filter."""
        super().on_quote_tick(tick)

        # Daily reset guard (ET calendar) to re-enable trading after prior cutoff blocks
        self._check_daily_reset(tick.ts_event)

        # Apex time guard on every tick
        if self._time_manager and not self._time_manager.check(tick.ts_event):
            return
        
        spread = float(tick.ask_price - tick.bid_price)
        if self.instrument:
            self._current_spread = int(spread / self.instrument.price_increment)
        if self._spread_monitor:
            try:
                snapshot = self._spread_monitor.update(
                    bid=tick.bid_price.as_double(),
                    ask=tick.ask_price.as_double(),
                )
                self._spread_snapshot = snapshot
                # Structured spread log on state change
                if self._last_spread_state != snapshot.status:
                    self._last_spread_state = snapshot.status
                    self.log.info(
                        f"[SPREAD] state={snapshot.status.name} pts={snapshot.current_spread_points:.2f} "
                        f"pips={snapshot.current_spread_pips:.2f} ratio={snapshot.spread_ratio:.2f} can_trade={snapshot.can_trade}"
                    )
                    if self._telemetry and getattr(self.config, "telemetry_capture_spread", True):
                        self._telemetry.emit(
                            "spread_state",
                            {
                                "state": snapshot.status.name,
                                "points": snapshot.current_spread_points,
                                "pips": snapshot.current_spread_pips,
                                "ratio": snapshot.spread_ratio,
                                "can_trade": snapshot.can_trade,
                                "size_multiplier": snapshot.size_multiplier,
                                "score_adjustment": snapshot.score_adjustment,
                            },
                        )
            except Exception:
                self._spread_snapshot = None
        
        # Update prop-firm trailing drawdown with mark-to-market equity
        if self._prop_firm:
            equity = self._compute_equity_from_tick(tick)
            if equity is not None:
                try:
                    self._prop_firm.update_equity(equity)
                    # stop immediately if breach occurs
                    if not self._prop_firm.can_trade():
                        return
                except Exception as exc:
                    logger.debug(f"Prop firm equity update failed: {exc}")

        # Circuit breaker equity feed
        if self._circuit_breaker:
            equity = self._compute_equity_from_tick(tick)
            if equity is not None:
                try:
                    self._circuit_breaker.update_equity(equity)
                except Exception as exc:
                    logger.debug(f"Circuit breaker equity update failed: {exc}")

        # TimeConstraintManager handles cutoff/flatten logic

    # ========== Operational helpers ==========
    @staticmethod
    def _parse_cutoff(cutoff_str: str):
        """Parse HH:MM string to time."""
        from datetime import time
        if isinstance(cutoff_str, time):
            return cutoff_str
        if not cutoff_str:
            return time(16, 59)
        parts = str(cutoff_str).split(":")
        hour = int(parts[0])
        minute = int(parts[1]) if len(parts) > 1 else 0
        return time(hour=hour, minute=minute)


    def _calculate_and_emit_metrics(self) -> Optional[PerformanceMetrics]:
        """Calculate and emit performance metrics to telemetry."""
        if not self._metrics_calculator or not self._trade_pnl_history:
            return None
        
        try:
            metrics = self._metrics_calculator.calculate(
                pnl_series=self._trade_pnl_history,
                initial_balance=float(self.config.account_balance),
            )
            
            # Emit to telemetry
            if self._telemetry:
                self._telemetry.emit('performance_metrics', metrics.to_dict())
            
            # Log summary
            self.log.info(
                f"Performance Metrics: Sharpe={metrics.sharpe_ratio:.2f}, "
                f"Sortino={metrics.sortino_ratio:.2f}, Calmar={metrics.calmar_ratio:.2f}, "
                f"SQN={metrics.sqn:.2f}, WinRate={metrics.win_rate:.1f}%, "
                f"ProfitFactor={metrics.profit_factor:.2f}, MaxDD={metrics.max_drawdown_pct:.2f}%"
            )
            
            return metrics
        except Exception as exc:
            self.log.error(f"Failed to calculate metrics: {exc}")
            return None
    def _compute_equity_from_tick(self, tick: QuoteTick) -> Optional[float]:
        """
        Compute mark-to-market equity including unrealized PnL.
        """
        try:
            equity = float(self._equity_base)
            if self._position:
                from nautilus_trader.model.enums import PositionSide
                mkt_price = tick.bid_price if self._position.side == PositionSide.LONG else tick.ask_price
                unreal = self._position.unrealized_pnl(mkt_price)
                equity += float(unreal)
            return equity
        except Exception as exc:
            self.log.debug(f"Equity computation failed: {exc}")
            return None


