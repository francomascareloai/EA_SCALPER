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
from datetime import datetime, timezone
from decimal import Decimal
from pathlib import Path
from typing import Any, Literal, cast

import numpy as np
from nautilus_trader.model import Bar, ClientOrderId, QuoteTick
from nautilus_trader.model.enums import OrderSide, PositionSide, TimeInForce
from nautilus_trader.model.events import PositionClosed, PositionOpened
from nautilus_trader.model.objects import Quantity
from numpy.typing import NDArray

from ..core.data_types import ConfluenceResult, FairValueGap, OrderBlock
from ..core.definitions import (
    Direction,
    TradeState,
    WEIGHT_AMD_CYCLE,
    WEIGHT_FIB,
    WEIGHT_FOOTPRINT,
    WEIGHT_FVG,
    WEIGHT_LIQUIDITY_SWEEP,
    WEIGHT_MTF,
    WEIGHT_ORDER_BLOCK,
    WEIGHT_REGIME,
    WEIGHT_STRUCTURE,
    XAUUSD_LOT_SIZE,
    XAUUSD_POINT,
    MarketRegime,
    SignalType,
    TradingSession,
)
from ..execution.trade_manager import TradeManager, TradeInfo
from ..core.exceptions import InsufficientDataError
from ..execution.delayed_executor import DelayedExecutor
from ..execution.economic_calendar import EconomicCalendar

# Import risk management
from ..execution.execution_model import ExecutionCosts, ExecutionModel

# Import HBS (Human Behavior Simulator) for stealth trading
from ..execution.human_config import HumanSimConfig
from ..execution.human_config import get_backtest_config as get_hbs_backtest_config
from ..execution.human_simulator import HBSDecision, HumanBehaviorSimulator
from ..execution.order_lifecycle import OrderLifecycleManager
from ..indicators.amd_cycle_tracker import AMDCycleTracker
from ..indicators.footprint_analyzer import FootprintAnalyzer
from ..indicators.fvg_detector import FVGDetector
from ..indicators.liquidity_sweep import LiquiditySweepDetector
from ..indicators.order_block_detector import OrderBlockDetector
from ..indicators.regime_detector import RegimeDetector

# Import analyzers
from ..indicators.session_filter import SessionFilter
from ..indicators.structure_analyzer import MarketBias, StructureAnalyzer
from ..risk.circuit_breaker import CircuitBreaker
from ..risk.drawdown_tracker import DrawdownTracker
from ..risk.position_sizer import PositionSizer
from ..risk.prop_firm_manager import PropFirmManager
from ..risk.spread_monitor import SpreadMonitor
from ..risk.time_constraint_manager import TimeConstraintManager
from ..signals.confluence_scorer import ConfluenceScorer
from ..signals.trend_follow import (
    TrendDirection,
    TrendFollowCandidate,
    TrendFollowVariant,
    generate_trend_follow_candidates,
)

# Import signal generators
from ..signals.mtf_manager import MTFManager
from nautilus_trader.model.data import DataType

from ..signals.news_calendar import NewsCalendar, NewsTradeAction
from ..signals.news_data import NewsWindowData
from ..utils.metrics import MetricsCalculator, PerformanceMetrics
from ..utils.telemetry import TelemetrySink
from .base_strategy import BaseGoldStrategy, BaseStrategyConfig
from .adaptive_router import AdaptiveEVRouter, RouterArm, RouterContext
from .adaptive_router import Candidate as RouterCandidate
from .strategy_selector import MarketContext, StrategySelector, StrategyType

logger = logging.getLogger(__name__)


class GoldScalperConfig(BaseStrategyConfig):  # type: ignore[misc, unused-ignore]
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

    # Strategy toggles (useful for isolated backtests)
    enable_smc: bool = True

    # TrendFollow (optional; disabled by default)
    enable_trend_follow: bool = False
    # Mode is an optional convenience override for the booleans below:
    # - "PULLBACK_ONLY" | "BREAKOUT_ONLY" | "BOTH"
    trend_follow_mode: str = "BOTH"
    enable_trend_pullback: bool = True
    enable_trend_breakout: bool = True

    # Adaptive EV router (optional; disabled by default)
    router_adaptive_ev: bool = False
    router_min_trades_to_trust: int = 30
    router_score_weight: float = 0.10
    router_dd_penalty_total: float = 0.20
    router_dd_penalty_daily: float = 0.10

    # Session filter tuning (GMT-based)
    session_broker_gmt_offset: int = 0
    session_allow_asian: bool = False
    session_allow_late_ny: bool = False
    session_friday_close_hour: int = 14

    # Structure analyzer tuning
    structure_swing_strength: int = 3
    structure_equal_tolerance_pips: float = 5.0
    structure_break_buffer_pips: float = 2.0
    structure_lookback_bars: int = 100
    structure_min_swing_distance: int = 5
    structure_point: float = 0.0  # 0 => use instrument tick size

    # Order block detector tuning
    ob_displacement_threshold_pips: float = 20.0
    ob_volume_threshold: float = 1.5
    ob_require_structure_break: bool = True
    ob_max_order_blocks: int = 50
    ob_lookback_bars: int = 50
    ob_point: float = 0.0  # 0 => use instrument tick size
    ob_pip_factor: float = 10.0

    # FVG detector tuning
    fvg_min_gap_pips: float = 1.0
    fvg_max_gap_pips: float = 40.0
    fvg_min_displacement_pips: float = 15.0
    fvg_volume_threshold: float = 1.5
    fvg_max_fvgs: int = 50
    fvg_expiry_hours: int = 24
    fvg_point: float = 0.0  # 0 => use instrument tick size
    fvg_pip_factor: float = 10.0

    # Liquidity sweep detector tuning
    sweep_equal_tolerance_pips: float = 3.0
    sweep_min_touches: int = 2
    sweep_min_sweep_depth_pips: float = 5.0
    sweep_max_bars_beyond: int = 3
    sweep_lookback_bars: int = 20
    sweep_swing_strength: int = 3
    sweep_point: float = 0.0  # 0 => use instrument tick size
    sweep_pip_factor: float = 10.0

    # AMD cycle tracker tuning
    amd_min_accumulation_bars: int = 15
    amd_max_accumulation_bars: int = 80
    amd_range_atr_max: float = 1.5
    amd_min_sweep_depth_pips: float = 5.0
    amd_min_displacement_atr: float = 1.5
    amd_equal_tolerance_pips: float = 3.0
    amd_point: float = 0.0  # 0 => use instrument tick size
    amd_pip_factor: float = 10.0

    # MTF manager tuning
    mtf_htf_swing_strength: int = 5
    mtf_mtf_swing_strength: int = 3
    mtf_ltf_swing_strength: int = 2
    mtf_htf_lookback_bars: int = 100
    mtf_mtf_lookback_bars: int = 100
    mtf_ltf_lookback_bars: int = 50
    mtf_structure_point: float = 0.0  # 0 => use instrument tick size

    # Confluence scorer weight caps (0-100)
    confluence_weight_structure: float = WEIGHT_STRUCTURE
    confluence_weight_regime: float = WEIGHT_REGIME
    confluence_weight_order_block: float = WEIGHT_ORDER_BLOCK
    confluence_weight_fvg: float = WEIGHT_FVG
    confluence_weight_liquidity_sweep: float = WEIGHT_LIQUIDITY_SWEEP
    confluence_weight_amd_cycle: float = WEIGHT_AMD_CYCLE
    confluence_weight_fib: float = WEIGHT_FIB
    confluence_weight_mtf: float = WEIGHT_MTF
    confluence_weight_footprint: float = WEIGHT_FOOTPRINT

    # Footprint (order flow) tuning (bars feed uses "estimated" footprint)
    footprint_cluster_size: float = 0.50
    footprint_imbalance_ratio: float = 3.0
    footprint_stacked_min: int = 3
    footprint_absorption_threshold: float = 15.0
    footprint_volume_multiplier: float = 2.0
    footprint_lookback_bars: int = 20
    footprint_stack_decay_30m: float = 0.75
    footprint_stack_decay_60m: float = 0.50
    footprint_score_floor: float = 40.0
    footprint_score_cap: float = 95.0

    # Regime detector tuning
    regime_hurst_period: int = 100
    regime_entropy_period: int = 50
    regime_vr_period: int = 20
    regime_kalman_q: float = 0.01
    regime_kalman_r: float = 0.1
    regime_multiscale_periods: tuple[int, int, int] = (50, 100, 200)

    # Strategy selector tuning (dynamic routing)
    selector_ftmo_safe_mode: bool = False
    selector_allow_news_trading: bool = True
    selector_allow_asian_session: bool = False
    # FORGE-NAUTILUS: Widened Hurst thresholds to reduce random-walk blocking
    # Old: 0.55/0.40 -> ~40-60% block rate (signal starvation)
    # New: 0.58/0.35 -> narrower "random" band, more signals pass
    selector_hurst_trend_threshold: float = 0.58
    selector_hurst_revert_threshold: float = 0.35
    selector_entropy_low_threshold: float = 1.5
    selector_entropy_high_threshold: float = 2.5

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

    # Commission configuration
    # - commission_source=manual: use commission_per_contract directly
    # - commission_source=schedule: derive commission_per_contract from profile+gateway
    commission_source: str = "manual"  # "manual" | "schedule"
    commission_profile: str = "apex"  # "apex" | "ftmo"
    commission_gateway: str = "tradovate"  # "tradovate" | "rithmic"
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
    consistency_cap_pct: float = 30.0
    telemetry_enabled: bool = True
    telemetry_path: str = "logs/telemetry.jsonl"
    telemetry_capture_spread: bool = True
    telemetry_capture_circuit: bool = True
    telemetry_capture_cutoff: bool = True

    # HBS (Human Behavior Simulator) settings
    hbs_enabled: bool = True  # Master switch for HBS
    hbs_mode: str = "backtest"  # "backtest", "live", "paper"
    hbs_account_id: str = ""  # Required for live mode (RNG seed)
    hbs_profit_target: float = 3000.0  # Apex profit target for 30% rule


class GoldScalperStrategy(BaseGoldStrategy):  # type: ignore[misc, unused-ignore]
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
        self._session_filter: SessionFilter | None = None
        self._regime_detector: RegimeDetector | None = None
        self._structure_analyzer: StructureAnalyzer | None = None
        self._footprint_analyzer: FootprintAnalyzer | None = None
        self._ob_detector: OrderBlockDetector | None = None
        self._fvg_detector: FVGDetector | None = None
        self._sweep_detector: LiquiditySweepDetector | None = None
        self._amd_tracker: AMDCycleTracker | None = None

        # Signal generators
        self._mtf_manager: MTFManager | None = None
        self._confluence_scorer: ConfluenceScorer | None = None

        # Risk management
        self._prop_firm: PropFirmManager | None = None
        self._position_sizer: PositionSizer | None = None
        self._drawdown_tracker: DrawdownTracker | None = None
        self._news_calendar: NewsCalendar | None = None
        self._news_size_mult: float = 1.0
        self._dow_size_mult: float = 1.0  # Day-of-week size adjustment (FORGE-NAUTILUS Wave 2)
        self._spread_monitor: SpreadMonitor | None = None
        self._spread_snapshot: Any | None = None
        self._time_manager: TimeConstraintManager | None = None
        self._circuit_breaker: CircuitBreaker | None = None
        self._trading_blocked_today: bool = False
        self._strategy_selector: StrategySelector | None = None
        self._execution_model: ExecutionModel | None = None
        self._fill_costs: dict[str, float] = {}
        self._consistency_tracker = None
        self._last_spread_state: int | None = None
        self._last_cb_level: int | None = None
        self._telemetry: TelemetrySink | None = None

        # Adaptive router attribution (optional)
        self._router: AdaptiveEVRouter | None = None
        self._last_entry_meta: dict[str, object] | None = None
        self._trade_meta_by_pos: dict[str, dict[str, object]] = {}

        # Performance metrics tracking
        self._trade_pnl_history: list[float] = []
        self._metrics_calculator: MetricsCalculator | None = None
        self._last_metrics_emit: int = 0
        # Analysis state (per timeframe)
        # BUG-11 FIX: Explicit timeframe-separated OB/FVG lists to prevent semantic collision.
        # Previously _mtf_order_blocks was overwritten by LTF detection (lines 1921-1937).
        self._htf_bias: MarketBias = MarketBias.RANGING
        # NOTE: _htf_order_blocks and _htf_fvgs are RESERVED for future HTF OB/FVG analysis.
        # Currently only _htf_bias is populated in _on_htf_bar(). The OB/FVG lists are placeholders
        # for when we implement direct OB/FVG detection on H1 timeframe (beyond structure bias).
        # DO NOT remove - they maintain the uniform _htf_/_mtf_/_ltf_ naming convention (BUG-11 fix).
        self._htf_order_blocks: list[OrderBlock] = []  # H1 - direction (RESERVED)
        self._htf_fvgs: list[FairValueGap] = []  # H1 - RESERVED for future implementation
        self._mtf_order_blocks: list[OrderBlock] = []  # M15 - structure zones
        self._mtf_fvgs: list[FairValueGap] = []
        self._ltf_order_blocks: list[OrderBlock] = []  # M5 - entry timing
        self._ltf_fvgs: list[FairValueGap] = []
        self._current_spread: float = float("inf")  # Fail-closed: unknown spread blocks entries

        # HBS (Human Behavior Simulator) components
        self._hbs: HumanBehaviorSimulator | None = None
        self._hbs_calendar: EconomicCalendar | None = None
        self._hbs_delayed_executor: DelayedExecutor | None = None
        self._hbs_order_lifecycle: OrderLifecycleManager | None = None
        self._hbs_last_decision: HBSDecision | None = None
        self._hbs_signals_skipped: int = 0
        self._hbs_signals_delayed: int = 0

        # Trade Manager (CRUCIBLE FIX: active trade management)
        # Trailing stop at 1R, partial profit 50% at 1R, breakeven at 1R
        self._trade_manager: TradeManager | None = None
        self._active_trade_id: str | None = None  # Maps to TradeInfo in TradeManager
        self._sl_modification_in_progress: bool = False  # Gate for SL updates
        self._pending_sl_cancel_order_id: str | None = None  # Old SL being canceled
        self._partial_close_in_progress: bool = False  # Gate for partial closes

        # Avoid log spam for expected warm-up/edge conditions.
        self._log_once_keys: set[str] = set()

    def _log_once(self, key: str, msg: str, *, level: Literal["debug", "info", "warning", "error"] = "debug") -> None:
        if key in self._log_once_keys:
            return
        self._log_once_keys.add(key)
        if level == "debug":
            self.log.debug(msg)
        elif level == "info":
            self.log.info(msg)
        elif level == "warning":
            self.log.warning(msg)
        else:
            self.log.error(msg)

    def _on_strategy_start(self) -> None:
        """Initialize all analyzers and managers."""
        # Session filter (GMT sessions; configurable)
        self._session_filter = SessionFilter(
            broker_gmt_offset=int(getattr(self.config, "session_broker_gmt_offset", 0)),
            allow_asian=bool(getattr(self.config, "session_allow_asian", False)),
            allow_late_ny=bool(getattr(self.config, "session_allow_late_ny", False)),
            friday_close_hour=int(getattr(self.config, "session_friday_close_hour", 14)),
        )

        # Subscribe to strategy-published news state (for replay/logging/ML features).
        self.subscribe_data(DataType(NewsWindowData))

        # Regime detector
        self._regime_detector = RegimeDetector(
            hurst_period=int(getattr(self.config, "regime_hurst_period", 100)),
            entropy_period=int(getattr(self.config, "regime_entropy_period", 50)),
            vr_period=int(getattr(self.config, "regime_vr_period", 20)),
            kalman_q=float(getattr(self.config, "regime_kalman_q", 0.01)),
            kalman_r=float(getattr(self.config, "regime_kalman_r", 0.1)),
            multiscale_periods=list(getattr(self.config, "regime_multiscale_periods", (50, 100, 200))),
        )

        # Structure analyzer (SMC) - configurable
        tick_size = float(self.instrument.price_increment.as_double()) if self.instrument else float(XAUUSD_POINT)
        structure_point = float(getattr(self.config, "structure_point", 0.0)) or tick_size
        self._structure_analyzer = StructureAnalyzer(
            swing_strength=int(getattr(self.config, "structure_swing_strength", 3)),
            equal_tolerance_pips=float(getattr(self.config, "structure_equal_tolerance_pips", 5.0)),
            break_buffer_pips=float(getattr(self.config, "structure_break_buffer_pips", 2.0)),
            lookback_bars=int(getattr(self.config, "structure_lookback_bars", 100)),
            min_swing_distance=int(getattr(self.config, "structure_min_swing_distance", 5)),
            point=float(structure_point),
        )

        # Footprint analyzer (if enabled) - use defaults
        if self.config.use_footprint:
            tick_size = float(self.instrument.price_increment.as_double()) if self.instrument else float(XAUUSD_POINT)
            self._footprint_analyzer = FootprintAnalyzer(
                cluster_size=float(getattr(self.config, "footprint_cluster_size", 0.50)),
                tick_size=float(tick_size),
                imbalance_ratio=float(getattr(self.config, "footprint_imbalance_ratio", 3.0)),
                stacked_min=int(getattr(self.config, "footprint_stacked_min", 3)),
                absorption_threshold=float(getattr(self.config, "footprint_absorption_threshold", 15.0)),
                volume_multiplier=float(getattr(self.config, "footprint_volume_multiplier", 2.0)),
                lookback_bars=int(getattr(self.config, "footprint_lookback_bars", 20)),
                stack_decay_30m=float(getattr(self.config, "footprint_stack_decay_30m", 0.75)),
                stack_decay_60m=float(getattr(self.config, "footprint_stack_decay_60m", 0.50)),
                score_floor=float(getattr(self.config, "footprint_score_floor", 40.0)),
                score_cap=float(getattr(self.config, "footprint_score_cap", 95.0)),
            )

        # SMC detectors - configurable (point defaults to instrument tick size)
        ob_point = float(getattr(self.config, "ob_point", 0.0)) or tick_size
        self._ob_detector = OrderBlockDetector(
            displacement_threshold=float(getattr(self.config, "ob_displacement_threshold_pips", 20.0)),
            volume_threshold=float(getattr(self.config, "ob_volume_threshold", 1.5)),
            require_structure_break=bool(getattr(self.config, "ob_require_structure_break", True)),
            max_order_blocks=int(getattr(self.config, "ob_max_order_blocks", 50)),
            lookback_bars=int(getattr(self.config, "ob_lookback_bars", 50)),
            point=float(ob_point),
            pip_factor=float(getattr(self.config, "ob_pip_factor", 10.0)),
        )
        fvg_point = float(getattr(self.config, "fvg_point", 0.0)) or tick_size
        self._fvg_detector = FVGDetector(
            min_gap_size=float(getattr(self.config, "fvg_min_gap_pips", 1.0)),
            max_gap_size=float(getattr(self.config, "fvg_max_gap_pips", 40.0)),
            min_displacement=float(getattr(self.config, "fvg_min_displacement_pips", 15.0)),
            volume_threshold=float(getattr(self.config, "fvg_volume_threshold", 1.5)),
            max_fvgs=int(getattr(self.config, "fvg_max_fvgs", 50)),
            expiry_hours=int(getattr(self.config, "fvg_expiry_hours", 24)),
            point=float(fvg_point),
            pip_factor=float(getattr(self.config, "fvg_pip_factor", 10.0)),
        )
        sweep_point = float(getattr(self.config, "sweep_point", 0.0)) or tick_size
        self._sweep_detector = LiquiditySweepDetector(
            equal_tolerance=float(getattr(self.config, "sweep_equal_tolerance_pips", 3.0)),
            min_touches=int(getattr(self.config, "sweep_min_touches", 2)),
            min_sweep_depth=float(getattr(self.config, "sweep_min_sweep_depth_pips", 5.0)),
            max_bars_beyond=int(getattr(self.config, "sweep_max_bars_beyond", 3)),
            lookback_bars=int(getattr(self.config, "sweep_lookback_bars", 20)),
            swing_strength=int(getattr(self.config, "sweep_swing_strength", 3)),
            point=float(sweep_point),
            pip_factor=float(getattr(self.config, "sweep_pip_factor", 10.0)),
        )
        amd_point = float(getattr(self.config, "amd_point", 0.0)) or tick_size
        self._amd_tracker = AMDCycleTracker(
            min_accumulation_bars=int(getattr(self.config, "amd_min_accumulation_bars", 15)),
            max_accumulation_bars=int(getattr(self.config, "amd_max_accumulation_bars", 80)),
            range_atr_max=float(getattr(self.config, "amd_range_atr_max", 1.5)),
            min_sweep_depth=float(getattr(self.config, "amd_min_sweep_depth_pips", 5.0)),
            min_displacement_atr=float(getattr(self.config, "amd_min_displacement_atr", 1.5)),
            equal_tolerance=float(getattr(self.config, "amd_equal_tolerance_pips", 3.0)),
            point=float(amd_point),
            pip_factor=float(getattr(self.config, "amd_pip_factor", 10.0)),
        )

        # MTF Manager - configurable
        mtf_point = float(getattr(self.config, "mtf_structure_point", 0.0)) or tick_size
        self._mtf_manager = MTFManager(
            htf_swing_strength=int(getattr(self.config, "mtf_htf_swing_strength", 5)),
            mtf_swing_strength=int(getattr(self.config, "mtf_mtf_swing_strength", 3)),
            ltf_swing_strength=int(getattr(self.config, "mtf_ltf_swing_strength", 2)),
            htf_lookback_bars=int(getattr(self.config, "mtf_htf_lookback_bars", 100)),
            mtf_lookback_bars=int(getattr(self.config, "mtf_mtf_lookback_bars", 100)),
            ltf_lookback_bars=int(getattr(self.config, "mtf_ltf_lookback_bars", 50)),
            structure_point=float(mtf_point),
            regime_hurst_period=int(getattr(self.config, "regime_hurst_period", 100)),
            regime_entropy_period=int(getattr(self.config, "regime_entropy_period", 50)),
            regime_vr_period=int(getattr(self.config, "regime_vr_period", 20)),
            regime_kalman_q=float(getattr(self.config, "regime_kalman_q", 0.01)),
            regime_kalman_r=float(getattr(self.config, "regime_kalman_r", 0.1)),
            regime_multiscale_periods=cast(tuple[int, int, int], getattr(self.config, "regime_multiscale_periods", (50, 100, 200))),
        )

        # Confluence scorer (weights + filters configurable)
        self._confluence_scorer = ConfluenceScorer(
            min_score_to_trade=float(self.config.execution_threshold),
            use_session_filter=bool(self.config.use_session_filter),
            use_regime_filter=bool(self.config.use_regime_filter),
            weight_structure=float(getattr(self.config, "confluence_weight_structure", WEIGHT_STRUCTURE)),
            weight_regime=float(getattr(self.config, "confluence_weight_regime", WEIGHT_REGIME)),
            weight_order_block=float(getattr(self.config, "confluence_weight_order_block", WEIGHT_ORDER_BLOCK)),
            weight_fvg=float(getattr(self.config, "confluence_weight_fvg", WEIGHT_FVG)),
            weight_liquidity_sweep=float(getattr(self.config, "confluence_weight_liquidity_sweep", WEIGHT_LIQUIDITY_SWEEP)),
            weight_amd_cycle=float(getattr(self.config, "confluence_weight_amd_cycle", WEIGHT_AMD_CYCLE)),
            weight_fib=float(getattr(self.config, "confluence_weight_fib", WEIGHT_FIB)),
            weight_mtf=float(getattr(self.config, "confluence_weight_mtf", WEIGHT_MTF)),
            weight_footprint=float(getattr(self.config, "confluence_weight_footprint", WEIGHT_FOOTPRINT)),
        )

        # News calendar (optional)
        if self.config.use_news_filter:
            self._news_calendar = NewsCalendar(events_path=getattr(self.config, "news_events_path", None))

        # Execution realism (per-fill slippage + commission) - requires instrument.
        try:
            assert self.instrument is not None
            tick_size = float(self.instrument.price_increment.as_double())
            slippage_ticks = int(max(0, getattr(self.config, "slippage_ticks", 2)))
            base_cents = int(round(slippage_ticks * tick_size * 100))

            comm_source = str(getattr(self.config, "commission_source", "manual")).strip().lower()
            if comm_source == "schedule":
                from nautilus_gold_scalper.src.execution.commission_schedule import commission_per_side_usd

                profile = str(getattr(self.config, "commission_profile", "apex")).strip().lower()
                gateway = str(getattr(self.config, "commission_gateway", "tradovate")).strip().lower()

                # Infer product from instrument raw symbol.
                raw_symbol = str(getattr(self.instrument, "raw_symbol", "")).strip().lower()
                product = "mgc" if raw_symbol == "mgc" else "xauusd"

                commission_per_lot = commission_per_side_usd(
                    profile=profile,
                    product=product,
                    gateway=gateway,
                )
            else:
                commission_per_lot = float(getattr(self.config, "commission_per_contract", 2.5))

            costs = ExecutionCosts(
                base_slippage_cents=Decimal(str(max(0, base_cents))),
                slippage_multiplier=Decimal(str(getattr(self.config, "slippage_multiplier", 1.5))),
                commission_per_lot=Decimal(str(commission_per_lot)),
            )
            self._execution_model = ExecutionModel(costs)
        except Exception as exc:
            self.log.debug(f"ExecutionModel setup failed, fallback to zero costs: {exc}")
            self._execution_model = None

        # Risk management (if prop firm mode)
        if self.config.prop_firm_enabled:
            from ..risk.prop_firm_manager import PropFirmLimits
            limits = PropFirmLimits(
                account_size=self.config.account_balance,
                daily_loss_limit=self.config.account_balance * float(self.config.daily_loss_limit_pct) / 100,
                trailing_drawdown=self.config.account_balance * float(self.config.total_loss_limit_pct) / 100,
            )
            self._prop_firm = PropFirmManager(limits=limits, raise_on_breach=False)
            self._prop_firm.set_strategy(self)

            # BUG-1 FIX: Pass max_risk_per_trade from config to PositionSizer.
            # Previously, only risk_per_trade was passed, causing PositionSizer to use
            # its default max_risk_per_trade (0.01 = 1%) from definitions.py.
            # Formula: max_risk enforces that actual_risk <= max_risk_per_trade
            # Example: risk_per_trade=0.02, max_risk_per_trade=0.02 -> cap at 2%
            max_risk_config = getattr(self.config, "max_risk_per_trade", None)
            if max_risk_config is None:
                from ..core.definitions import MAX_RISK_PER_TRADE
                max_risk_config = MAX_RISK_PER_TRADE

            self._position_sizer = PositionSizer(
                risk_per_trade=float(self.config.risk_per_trade),
                max_risk_per_trade=float(max_risk_config),
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
            clock=self.clock,
            use_clock_timer=(
                bool(getattr(self.config, "prop_firm_enabled", True))
                and (not bool(self.config.allow_overnight))
                and bool(getattr(self.config, "time_gate_use_clock_timer", True))
            ),
            timer_interval_ns=int(getattr(self.config, "time_gate_timer_interval_ns", 10_000_000_000)),
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

        # Strategy selector (regime/session/safety aware)
        if self.config.use_selector:
            self._strategy_selector = StrategySelector(
                ftmo_safe_mode=bool(getattr(self.config, "selector_ftmo_safe_mode", False)),
                allow_news_trading=bool(getattr(self.config, "selector_allow_news_trading", True)),
                allow_asian_session=bool(getattr(self.config, "selector_allow_asian_session", False)),
                hurst_trend_threshold=float(getattr(self.config, "selector_hurst_trend_threshold", 0.55)),
                hurst_revert_threshold=float(getattr(self.config, "selector_hurst_revert_threshold", 0.40)),
                entropy_low_threshold=float(getattr(self.config, "selector_entropy_low_threshold", 1.5)),
                entropy_high_threshold=float(getattr(self.config, "selector_entropy_high_threshold", 2.5)),
            )

        # Adaptive router (EV w/ DD penalty) - optional
        if bool(getattr(self.config, "router_adaptive_ev", False)):
            self._router = AdaptiveEVRouter(
                seed=1337,
                min_trades_to_trust=int(getattr(self.config, "router_min_trades_to_trust", 30)),
                score_weight=float(getattr(self.config, "router_score_weight", 0.10)),
                dd_penalty_total=float(getattr(self.config, "router_dd_penalty_total", 0.20)),
                dd_penalty_daily=float(getattr(self.config, "router_dd_penalty_daily", 0.10)),
            )

        # HBS (Human Behavior Simulator) initialization
        if getattr(self.config, 'hbs_enabled', True):
            try:
                # Create HBS config based on mode
                raw_mode = getattr(self.config, "hbs_mode", "backtest")
                hbs_mode = cast(
                    Literal["backtest", "live", "paper"],
                    raw_mode if raw_mode in ("backtest", "live", "paper") else "backtest",
                )
                if hbs_mode == "backtest":
                    hbs_config = get_hbs_backtest_config()
                else:
                    # Live/paper mode - need account_id and profit_target
                    hbs_config = HumanSimConfig(
                        mode=hbs_mode,
                        enabled=True,
                        rng_seed_from_date=True,
                        rng_seed_account_id=getattr(self.config, 'hbs_account_id', ''),
                        apex_30pct_rule_enabled=True,
                        apex_profit_target=getattr(self.config, 'hbs_profit_target', 3000.0),
                    )
                    hbs_config.validate()

                # Create economic calendar for event detection
                self._hbs_calendar = EconomicCalendar()

                # Create main HBS instance
                self._hbs = HumanBehaviorSimulator(
                    config=hbs_config,
                    calendar=self._hbs_calendar
                )

                # DelayedExecutor - backtest mode uses immediate execution
                is_live = hbs_mode in ("live", "paper")
                self._hbs_delayed_executor = DelayedExecutor(
                    clock=self.clock,
                    is_live=is_live,
                    max_pending=10
                )

                # Order lifecycle manager for limit order tracking
                self._hbs_order_lifecycle = OrderLifecycleManager()

                self.log.info(f"HBS initialized: mode={hbs_mode}, enabled=True")
            except Exception as exc:
                self.log.warning(f"HBS initialization failed, trading without stealth: {exc}")
                self._hbs = None

        # Trade Manager initialization (CRUCIBLE FIX: active trade management)
        # Replaces static "set and forget" SL/TP with dynamic trailing/breakeven/partials
        # Expected improvement: 0.15R -> 0.60R per trade (4x improvement)
        # Configuration: partial_tp_r=1.0 (50% at 1R), trailing_start_r=1.0 (trail at 1R)
        self._trade_manager = TradeManager(
            partial_tp_r=1.0,           # Take 50% profit at 1R
            partial_tp_percent=0.5,     # Close 50% at partial TP
            trailing_start_r=1.0,       # Start trailing at 1R (also moves to breakeven)
        )
        self.log.info(
            f"TradeManager initialized: partial_tp_r=1.0, partial_tp_percent=0.5, trailing_start_r=1.0"
        )

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

    def on_position_opened(self, event: PositionOpened) -> None:
        super().on_position_opened(event)

        # CRUCIBLE FIX: Fill entry in TradeManager when position is confirmed
        if self._trade_manager and self._active_trade_id:
            try:
                # Get actual fill details from the position
                position = self.cache.position(event.position_id)
                if position:
                    # BUG-12 FIX: Handle both Price objects (with as_double) and raw floats
                    avg_px = position.avg_px_open
                    actual_entry = float(avg_px.as_double()) if hasattr(avg_px, "as_double") else float(avg_px)
                    qty = position.quantity
                    actual_qty = float(qty.as_double()) if hasattr(qty, "as_double") else float(qty)
                    self._trade_manager.fill_entry(
                        trade_id=self._active_trade_id,
                        actual_entry_price=actual_entry,
                        actual_quantity=actual_qty,
                    )
                    self.log.info(
                        f"[TRADE_MANAGER] Trade {self._active_trade_id} filled: "
                        f"entry={actual_entry:.2f}, qty={actual_qty}"
                    )
            except Exception as exc:
                self.log.warning(f"[TRADE_MANAGER] fill_entry failed: {exc}")
                # Clear trade_id to prevent stale state
                self._active_trade_id = None

        if self._router is None:
            self._last_entry_meta = None
            return
        if self._last_entry_meta is None:
            return
        try:
            pos_id = str(getattr(event, "position_id", ""))
            if pos_id:
                self._trade_meta_by_pos[pos_id] = dict(self._last_entry_meta)
        finally:
            self._last_entry_meta = None

    def on_position_closed(self, event: PositionClosed) -> None:
        # CRUCIBLE FIX: Close trade in TradeManager
        if self._trade_manager and self._active_trade_id:
            try:
                # BUG-12 FIX: Handle both Price objects (with as_double) and raw floats
                avg_px_close = getattr(event, "avg_px_close", None)
                if avg_px_close is not None:
                    close_price = float(avg_px_close.as_double()) if hasattr(avg_px_close, "as_double") else float(avg_px_close)
                else:
                    close_price = 0.0

                realized_pnl_val = getattr(event, "realized_pnl", None)
                if realized_pnl_val is not None:
                    realized_pnl = float(realized_pnl_val.as_double()) if hasattr(realized_pnl_val, "as_double") else float(realized_pnl_val)
                else:
                    realized_pnl = None
                self._trade_manager.close_trade(
                    trade_id=self._active_trade_id,
                    close_price=close_price,
                    reason="Position closed",
                    pnl=realized_pnl,
                )
                self.log.info(
                    f"[TRADE_MANAGER] Trade {self._active_trade_id} closed: "
                    f"price={close_price:.2f}, pnl={realized_pnl}"
                )
            except Exception as exc:
                self.log.warning(f"[TRADE_MANAGER] close_trade failed: {exc}")
            finally:
                # Always clear tracking state
                self._active_trade_id = None
                self._sl_modification_in_progress = False
                self._pending_sl_cancel_order_id = None
                self._partial_close_in_progress = False

        if self._router is None:
            super().on_position_closed(event)
            return
        pos_id = str(getattr(event, "position_id", ""))
        meta = self._trade_meta_by_pos.pop(pos_id, None)
        equity_before = float(getattr(self, "_equity_base", 0.0))
        super().on_position_closed(event)
        if meta is None:
            return
        try:
            equity_after = float(getattr(self, "_equity_base", equity_before))
            net_pnl = equity_after - equity_before
            risk_usd_raw = meta.get("risk_usd", 0.0)
            risk_usd = float(risk_usd_raw) if isinstance(risk_usd_raw, (int, float)) else 0.0
            if risk_usd <= 0.0:
                return
            reward_r = float(net_pnl / risk_usd)

            arm_raw = meta.get("arm")
            if not isinstance(arm_raw, str):
                return
            try:
                arm = RouterArm(arm_raw)
            except Exception:
                return

            ctx_raw = meta.get("ctx")
            if not isinstance(ctx_raw, tuple) or len(ctx_raw) != 3:
                return
            ctx = RouterContext(session=str(ctx_raw[0]), regime=str(ctx_raw[1]), vol_bucket=int(ctx_raw[2]))

            if self._router:
                self._router.update(ctx=ctx, arm=arm, reward_r=reward_r)

            if self._telemetry:
                self._telemetry.emit(
                    "router_update",
                    {
                        "arm": arm.value,
                        "reward_r": reward_r,
                        "net_pnl": net_pnl,
                        "risk_usd": risk_usd,
                        "ctx": {"session": ctx.session, "regime": ctx.regime, "vol_bucket": ctx.vol_bucket},
                    },
                )
        except Exception:
            self.log.debug("[ROUTER] post-close update failed", exc_info=True)

    def _check_daily_reset(self, timestamp_ns: int) -> None:
        """
        Reset daily counters at day change using **ET calendar days**.

        Apex rules (cutoff 16:59 ET, no overnight) require resets on the
        Eastern Time boundary; otherwise, after the cutoff the strategy stays
        blocked until 00:00 UTC and misses London/NY next day.
        """
        from datetime import datetime, timezone, tzinfo
        try:
            from zoneinfo import ZoneInfo
            et_tz: tzinfo = ZoneInfo("America/New_York")
        except Exception:  # pragma: no cover
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

            # BUG-6 FIX: Reset execution failsafe at start of new trading day.
            # Previously, failsafe persisted forever once triggered, blocking all future trades.
            # In backtest mode, each day should start fresh. In live, overnight positions are not allowed
            # anyway (Apex rule), so resetting is safe.
            if self._execution_failsafe_triggered:
                self.log.info("[DAILY_RESET] Clearing execution failsafe from previous day")
                self._execution_failsafe_triggered = False

            # Re-enable trading for the new day
            self._is_trading_allowed = True
            self._trading_blocked_today = False
            self.log.info(
                f"[DAILY_RESET] trading_allowed={self._is_trading_allowed} (lifted prior cutoff/blocks)"
            )
            if self._drawdown_tracker:
                try:
                    self._drawdown_tracker.reset_daily()
                except Exception:
                    pass

            # Reset prop firm manager if active
            if self._prop_firm is not None:
                try:
                    now_dt = datetime.fromtimestamp(timestamp_ns / 1e9, tz=timezone.utc)
                    self._prop_firm.on_new_day(current_equity=self._equity_base, now=now_dt)
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
                # Use simulated time for backtests (avoid wall-clock dependence).
                now_dt = datetime.fromtimestamp(timestamp_ns / 1e9, tz=timezone.utc)
                self._circuit_breaker.reset_daily(now=now_dt)

            # HBS session start hook (new trading day)
            if self._hbs:
                try:
                    bar_dt = datetime.fromtimestamp(timestamp_ns / 1e9, tz=et_tz)
                    self._hbs.on_session_start(bar_dt)
                    self.log.debug(f"[HBS] Session started for {current_date_et}")
                except Exception as exc:
                    self.log.debug(f"[HBS] Session start failed: {exc}")

            self._last_reset_date = current_date_et
            self.log.info("Daily reset complete (ET)")

    def _on_strategy_stop(self) -> None:
        """Cleanup analyzers."""
        # HBS session end hook
        if self._hbs:
            try:
                self._hbs.on_session_end()
                self.log.debug("[HBS] Session ended")
            except Exception as exc:
                self.log.debug(f"[HBS] Session end failed: {exc}")

        # Shutdown delayed executor
        if self._hbs_delayed_executor:
            try:
                self._hbs_delayed_executor.shutdown()
                self.log.debug("[HBS] DelayedExecutor shutdown complete")
            except Exception as exc:
                self.log.debug(f"[HBS] DelayedExecutor shutdown failed: {exc}")

        # Emit factor activation counters (always, even if no trades were closed)
        if self._telemetry and self._confluence_scorer:
            try:
                counters = self._confluence_scorer.get_factor_counters()
                self._telemetry.emit('factor_activation_counters', counters.as_dict())
            except Exception:
                pass

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
        min_bars = 3
        if self._ob_detector is not None:
            min_bars = max(min_bars, int(getattr(self._ob_detector, "lookback_bars", 50)))
        if len(self._mtf_bars) < min_bars:
            return

        closes = np.array([b.close.as_double() for b in self._mtf_bars[-100:]])
        highs = np.array([b.high.as_double() for b in self._mtf_bars[-100:]])
        lows = np.array([b.low.as_double() for b in self._mtf_bars[-100:]])
        opens = np.array([b.open.as_double() for b in self._mtf_bars[-100:]])
        volumes = np.array([b.volume.as_double() for b in self._mtf_bars[-100:]])

        # Detect order blocks
        if self._ob_detector:
            try:
                self._mtf_order_blocks = self._ob_detector.detect(
                    opens, highs, lows, closes, volumes
                )
            except InsufficientDataError:
                return

        # Detect FVGs
        if self._fvg_detector:
            try:
                self._mtf_fvgs = self._fvg_detector.detect(
                    opens, highs, lows, closes, volumes
                )
            except InsufficientDataError:
                return

        if self.config.debug_mode:
            self.log.debug(f"MTF: {len(self._mtf_order_blocks)} OBs, {len(self._mtf_fvgs)} FVGs")

    def _on_ltf_bar(self, bar: Bar) -> None:
        """Process M5 bar - Update execution-level analysis."""
        # Ensure daily counters unblock trading when a new ET day starts
        self._check_daily_reset(bar.ts_event)

        # Enforce intraday operational rules (Apex) - only if prop firm mode enabled
        if self.config.prop_firm_enabled and self._time_manager and not self._time_manager.check(bar.ts_event):
            return
        # Main signal checking done in _check_for_signal
        pass

    def _check_for_signal(self, bar: Bar) -> None:
        """Check for trading signal and execute if valid."""
        # Import datetime at function start (used by multiple checks below)
        from datetime import datetime, timezone

        bar_time = datetime.fromtimestamp(bar.ts_event / 1e9, tz=timezone.utc)

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

        # FORGE-NAUTILUS Wave 2: Day-of-week adjustment (Monday/Friday risk)
        # Reset per-bar multiplier
        self._dow_size_mult = 1.0
        if self.config.use_session_filter and self._session_filter:
            can_trade_dow, dow_mult, dow_reason = self._session_filter.get_day_of_week_adjustment(bar_time)
            if not can_trade_dow:
                if should_log:
                    self.log.info(f"[SIGNAL_CHECK] Day-of-week BLOCKED: {dow_reason}")
                if self._telemetry:
                    self._telemetry.emit("signal_reject", {
                        "reason": "day_of_week_filter",
                        "dow_reason": dow_reason,
                        "bar": len(self._ltf_bars)
                    })
                return
            # Store multiplier for position sizing (applied later)
            self._dow_size_mult = dow_mult
            if dow_mult < 1.0 and should_log:
                self.log.info(f"[FILTER] Day-of-week size adjustment: {dow_mult:.2f}x ({dow_reason})")

        # FORGE-NAUTILUS Phase 09: Removed redundant is_regime_stable() gate.
        # Rationale: Confluence scorer already penalizes RANDOM_WALK (-50, INVALID) and
        # TRANSITIONING (-20, 30% weight). The gate was causing ~10k+ false rejections
        # per quarter by blocking even good regimes with high transition_prob estimates.
        # Regime filtering is now handled exclusively by confluence scoring.

        # Apex entry gate (block new trades after 4:30 PM ET)
        # Only apply if prop_firm_enabled - allows backtest without time constraints
        if self.config.prop_firm_enabled and self._time_manager and not self._time_manager.can_open_new(bar.ts_event):
            if should_log:
                self.log.info("[SIGNAL_CHECK] Time manager entry gate BLOCKED (after 4:30 PM ET)")
            if self._telemetry:
                self._telemetry.emit("signal_reject", {"reason": "time_gate_entry", "bar": len(self._ltf_bars)})
            return
        # Check blocked_today flag (only relevant when prop_firm_enabled)
        if self.config.prop_firm_enabled and getattr(self, "_trading_blocked_today", False):
            if should_log:
                self.log.info("[SIGNAL_CHECK] Trading blocked today flag set")
            if self._telemetry:
                self._telemetry.emit("signal_reject", {"reason": "blocked_today", "bar": len(self._ltf_bars)})
            return

        # Check prop firm limits (only if enabled)
        if self.config.prop_firm_enabled and self._prop_firm:
            try:
                if not self._prop_firm.can_trade(now=bar_time):
                    if should_log:
                        self.log.info("[SIGNAL_CHECK] Prop firm manager BLOCKED")
                    if self._telemetry:
                        self._telemetry.emit("signal_reject", {"reason": "prop_firm", "bar": len(self._ltf_bars)})
                    self._is_trading_allowed = False
                    self.log.warning("[BLOCKED] _is_trading_allowed = False (prop_firm.can_trade() returned False)")
                    return
            except Exception as exc:
                super()._trigger_execution_failsafe(reason=f"prop_firm_signal_gate_exception:{type(exc).__name__}")
                return

        # Circuit breaker gate
        if self._circuit_breaker:
            try:
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
                cb_allowed = self._circuit_breaker.can_trade(now=bar_time)
            except Exception as exc:
                super()._trigger_execution_failsafe(reason=f"circuit_breaker_signal_gate_exception:{type(exc).__name__}")
                return
            if not cb_allowed:
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
            try:
                circuit_ok = True if not self._circuit_breaker else self._circuit_breaker.can_trade(now=bar_time)
            except Exception as exc:
                super()._trigger_execution_failsafe(reason=f"circuit_breaker_signal_gate_exception:{type(exc).__name__}")
                return
            spread_ok = True
            if self._spread_monitor is not None:
                spread_ok = bool(self._spread_snapshot.can_trade) if self._spread_snapshot else False

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
                circuit_ok=circuit_ok,
                spread_ok=spread_ok,
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
        if self._consistency_tracker:
            try:
                ok = self._consistency_tracker.can_trade(now=bar_time.astimezone(self._consistency_tracker.et_tz))
            except Exception as exc:
                super()._trigger_execution_failsafe(reason=f"consistency_tracker_gate_exception:{type(exc).__name__}")
                return
            if not ok:
                if should_log:
                    self.log.info("[SIGNAL_CHECK] Consistency tracker BLOCKED (30% daily profit cap)")
                if self._telemetry:
                    self._telemetry.emit("signal_reject", {"reason": "consistency_cap", "bar": len(self._ltf_bars)})
                self._is_trading_allowed = False
                self.log.warning("[BLOCKED] _is_trading_allowed = False (consistency_tracker 30% daily cap)")
                return

        # Circuit breaker guard
        if self._circuit_breaker:
            try:
                cb_guard_ok = self._circuit_breaker.can_trade(now=bar_time)
            except Exception as exc:
                super()._trigger_execution_failsafe(reason=f"circuit_breaker_signal_gate_exception:{type(exc).__name__}")
                return
            if not cb_guard_ok:
                if should_log:
                    self.log.info("[SIGNAL_CHECK] Circuit breaker guard BLOCKED")
                if self._telemetry:
                    self._telemetry.emit("signal_reject", {"reason": "circuit_breaker_guard", "bar": len(self._ltf_bars)})
                self._is_trading_allowed = False
                self.log.warning("[BLOCKED] _is_trading_allowed = False (circuit_breaker.can_trade() returned False)")
                return

        # News filter (uses bar timestamp for backtest realism)
        news_window = None
        if self.config.use_news_filter and self._news_calendar:
            bar_time = datetime.fromtimestamp(bar.ts_event / 1e9, tz=timezone.utc)
            news_window = self._news_calendar.check_news_window(now=bar_time)

            # Publish deterministic, ts_event-aligned news state for downstream consumers (catalog/ML/analysis).
            try:
                ev = news_window.event
                self.publish_data(
                    DataType(NewsWindowData),
                    NewsWindowData(
                        instrument_id=self.config.instrument_id,
                        in_window=bool(news_window.in_window),
                        action=int(news_window.action),
                        minutes_to_event=int(news_window.minutes_to_event),
                        is_before_event=bool(news_window.is_before_event),
                        score_adjustment=int(news_window.score_adjustment),
                        size_multiplier=float(news_window.size_multiplier),
                        event_name=str(ev.event_name) if ev is not None else "",
                        currency=str(ev.currency) if ev is not None else "",
                        impact=int(ev.impact) if ev is not None else 0,
                        reason=str(news_window.reason),
                        ts_event=int(bar.ts_event),
                        ts_init=int(bar.ts_init),
                    ),
                )
            except Exception:
                if should_log:
                    self.log.debug("[NEWS] publish_data failed", exc_info=True)

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

        # Check spread (fail-closed: block entries if spread is unknown or unhealthy)
        spread_score_adj = 0
        if self._spread_monitor is not None and self._spread_snapshot is None:
            # No valid spread data yet - fail closed (block entry)
            if should_log:
                self.log.info("[SIGNAL_CHECK] Spread BLOCKED: no spread snapshot (waiting for first quote)")
            if self._telemetry:
                self._telemetry.emit("signal_reject", {
                    "reason": "spread_missing",
                    "bar": len(self._ltf_bars)
                })
            return
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
        # Block trades when HTF trend is unclear (RANGING or TRANSITION)
        if self.config.require_htf_align:
            # CRITIC FIX: Also block when HTF bias is None (insufficient data)
            # This ensures we don't trade without HTF context when alignment is required
            if self._htf_bias is None:
                if should_log:
                    self.log.info("[SIGNAL_CHECK] HTF bias is None - blocked (insufficient HTF data)")
                if self._telemetry:
                    self._telemetry.emit("signal_reject", {
                        "reason": "htf_bias_none",
                        "bar": len(self._ltf_bars)
                    })
                return
            if self._htf_bias in (MarketBias.RANGING, MarketBias.TRANSITION):
                if should_log:
                    self.log.info(f"[SIGNAL_CHECK] HTF bias {self._htf_bias.name} - blocked (not trending)")
                if self._telemetry:
                    self._telemetry.emit("signal_reject", {
                        "reason": "htf_not_trending",
                        "htf_bias": self._htf_bias.name,
                        "bar": len(self._ltf_bars)
                    })
                return

        # Calculate confluence score (SMC candidate) unless explicitly disabled.
        confluence_result = None
        if bool(getattr(self.config, "enable_smc", True)):
            if should_log:
                self.log.info(f"[SIGNAL_CHECK] Calculating confluence at bar {len(self._ltf_bars)}...")
            confluence_result = self._calculate_confluence(bar)

        # BUG-4 FIX: HTF direction alignment check - block signals opposing HTF bias
        # This prevents SELL signals when HTF (H1) is BULLISH and vice versa.
        # The existing check at lines 1246-1256 only blocks RANGING/TRANSITION,
        # but not opposite direction signals. This gate enforces HTF > LTF priority.
        if self.config.require_htf_align and confluence_result is not None:
            htf_bullish = self._htf_bias == MarketBias.BULLISH
            htf_bearish = self._htf_bias == MarketBias.BEARISH
            signal_buy = confluence_result.direction == SignalType.SIGNAL_BUY
            signal_sell = confluence_result.direction == SignalType.SIGNAL_SELL

            if (htf_bullish and signal_sell) or (htf_bearish and signal_buy):
                if should_log:
                    self.log.info(
                        f"[SIGNAL_CHECK] Direction {confluence_result.direction.name} "
                        f"opposes HTF bias {self._htf_bias.name} - blocked"
                    )
                if self._telemetry:
                    self._telemetry.emit("signal_reject", {
                        "reason": "htf_direction_conflict",
                        "htf_bias": self._htf_bias.name,
                        "signal_direction": confluence_result.direction.name,
                        "bar": len(self._ltf_bars)
                    })
                return

        news_score_adj = news_window.score_adjustment if news_window else 0
        effective_score = (confluence_result.total_score + news_score_adj + spread_score_adj) if confluence_result else 0.0

        # Optional TrendFollow candidates (pullback + breakout)
        trend_candidates: list[TrendFollowCandidate] = []
        if bool(getattr(self.config, "enable_trend_follow", False)):
            try:
                inst = self.instrument
                tick_size = float(inst.price_increment.as_double()) if inst else float(XAUUSD_POINT)
                atr = float(self._get_current_atr())
                atr_p = float(self._get_atr_percentile())
                closes = np.array([b.close.as_double() for b in self._ltf_bars[-300:]], dtype=np.float64)
                highs = np.array([b.high.as_double() for b in self._ltf_bars[-300:]], dtype=np.float64)
                lows = np.array([b.low.as_double() for b in self._ltf_bars[-300:]], dtype=np.float64)
                trend_candidates = generate_trend_follow_candidates(
                    closes=closes,
                    highs=highs,
                    lows=lows,
                    tick_size=tick_size,
                    atr=atr,
                    atr_percentile=atr_p,
                    min_score=float(self.config.execution_threshold),
                )

                mode = str(getattr(self.config, "trend_follow_mode", "BOTH")).strip().upper()
                if mode == "PULLBACK_ONLY":
                    trend_candidates = [c for c in trend_candidates if c.variant == TrendFollowVariant.PULLBACK]
                elif mode == "BREAKOUT_ONLY":
                    trend_candidates = [c for c in trend_candidates if c.variant == TrendFollowVariant.BREAKOUT]
                else:
                    if not bool(getattr(self.config, "enable_trend_pullback", True)):
                        trend_candidates = [c for c in trend_candidates if c.variant != TrendFollowVariant.PULLBACK]
                    if not bool(getattr(self.config, "enable_trend_breakout", True)):
                        trend_candidates = [c for c in trend_candidates if c.variant != TrendFollowVariant.BREAKOUT]
            except Exception as exc:
                self.log.debug(f"[TREND] candidate gen failed: {exc}")
                trend_candidates = []

        if confluence_result is None and not trend_candidates:
            if should_log:
                self.log.info("[SIGNAL_CHECK] Confluence returned None (insufficient data or error)")
            if self._telemetry:
                self._telemetry.emit("signal_reject", {"reason": "confluence_none", "bar": len(self._ltf_bars)})
            return

        # ALWAYS log score calculation (critical for debugging) when SMC exists
        if confluence_result is not None:
            # FORGE-NAUTILUS Wave 2: Enhanced debug logging with tier info
            tier_name = confluence_result.quality.name if confluence_result.quality else "UNKNOWN"
            self.log.info(
                f"[SIGNAL_DEBUG] Score={confluence_result.total_score:.1f}, Tier={tier_name}, "
                f"Direction={confluence_result.direction.name}, Confluences={confluence_result.total_confluences}"
            )
            self.log.info(
                f"[SCORE] Bar {len(self._ltf_bars)}: base={confluence_result.total_score:.1f}, "
                f"news={news_score_adj:+.1f}, spread={spread_score_adj:+.1f}, "
                f"effective={effective_score:.1f}, signal={confluence_result.direction.name}, "
                f"threshold={self.config.execution_threshold}"
            )
            if self._telemetry:
                self._telemetry.emit(
                    "score_calculated",
                    {
                        "bar": len(self._ltf_bars),
                        "base_score": confluence_result.total_score,
                        "news_adj": news_score_adj,
                        "spread_adj": spread_score_adj,
                        "effective_score": effective_score,
                        "signal": confluence_result.direction.name,
                        "threshold": self.config.execution_threshold,
                    },
                )

        self._last_confluence = confluence_result

        # Router/deterministic selection: choose between SMC and TrendFollow variants
        selected_arm: RouterArm = RouterArm.SMC
        selected_score: float = float(effective_score)
        selected_trend: TrendFollowCandidate | None = None

        # Deterministic fallback (if router disabled)
        if trend_candidates:
            best = max(
                trend_candidates,
                key=lambda c: (float(c.score), 1 if c.variant == TrendFollowVariant.PULLBACK else 0),
            )
            if confluence_result is None or float(best.score) > float(selected_score) + 1e-9:
                selected_trend = best
                selected_arm = RouterArm.TREND_PULLBACK if best.variant == TrendFollowVariant.PULLBACK else RouterArm.TREND_BREAKOUT
                selected_score = float(best.score)

        # Adaptive router selection (EV w/ DD penalty) - optional
        if self._router:
            try:
                sess = self._current_session.session.name if self._current_session else "UNKNOWN"
                reg = self._current_regime.regime.name if self._current_regime else "UNKNOWN"
                vol_bucket = int(max(0.0, min(4.0, float(self._get_atr_percentile()) // 20.0)))
                ctx = RouterContext(session=str(sess), regime=str(reg), vol_bucket=int(vol_bucket))

                router_candidates: list[RouterCandidate] = []
                if confluence_result is not None:
                    router_candidates.append(RouterCandidate(arm=RouterArm.SMC, score=float(effective_score), meta={"kind": "smc"}))
                for tc in trend_candidates:
                    arm = RouterArm.TREND_PULLBACK if tc.variant == TrendFollowVariant.PULLBACK else RouterArm.TREND_BREAKOUT
                    router_candidates.append(RouterCandidate(arm=arm, score=float(tc.score), meta={"kind": "trend"}))

                sel = self._router.select(
                    ctx=ctx,
                    candidates=router_candidates,
                    execution_threshold=float(self.config.execution_threshold),
                    daily_dd_pct=float(self._drawdown_tracker.get_daily_drawdown_pct() if self._drawdown_tracker else 0.0),
                    total_dd_pct=float(self._drawdown_tracker.get_total_drawdown_pct() if self._drawdown_tracker else 0.0),
                    prefer=RouterArm.TREND_PULLBACK,
                )
                if sel is not None:
                    selected_arm = sel.arm
                    if selected_arm == RouterArm.SMC:
                        selected_trend = None
                        selected_score = float(effective_score)
                    else:
                        want = TrendFollowVariant.PULLBACK if selected_arm == RouterArm.TREND_PULLBACK else TrendFollowVariant.BREAKOUT
                        selected_trend = max((c for c in trend_candidates if c.variant == want), key=lambda x: float(x.score), default=None)
                        selected_score = float(selected_trend.score) if selected_trend else 0.0

                    if self._telemetry:
                        self._telemetry.emit(
                            "router_select",
                            {
                                "arm": selected_arm.value,
                                "utility": sel.utility,
                                "reason": sel.reason,
                                "sampled_ev": sel.sampled_ev,
                                "dd_penalty": sel.dd_penalty,
                                "ctx": {"session": ctx.session, "regime": ctx.regime, "vol_bucket": ctx.vol_bucket},
                                "scores": {
                                    "smc": float(effective_score) if confluence_result else None,
                                    "trend_pullback": float(
                                        max((c.score for c in trend_candidates if c.variant == TrendFollowVariant.PULLBACK), default=0.0)
                                    ),
                                    "trend_breakout": float(
                                        max((c.score for c in trend_candidates if c.variant == TrendFollowVariant.BREAKOUT), default=0.0)
                                    ),
                                },
                            },
                        )
            except Exception as exc:
                self.log.debug(f"[ROUTER] selection failed: {exc}")

        # Check if selected candidate meets threshold
        if float(selected_score) < self.config.execution_threshold:
            # Verbose logging: show component breakdown when rejecting signal
            if getattr(self.config, "debug_mode", False) and confluence_result:
                self.log.info(
                    f"[SIGNAL_REJECT] Score={selected_score:.1f} < threshold={self.config.execution_threshold} | "
                    f"Struct={confluence_result.structure_score:.1f} Regime={confluence_result.regime_score:.1f} "
                    f"OB={confluence_result.ob_score:.1f} FVG={confluence_result.fvg_score:.1f} "
                    f"Sweep={confluence_result.sweep_score:.1f} AMD={confluence_result.amd_score:.1f} "
                    f"Fib={confluence_result.fib_score:.1f} MTF={confluence_result.mtf_score:.1f} "
                    f"Session={confluence_result.session_score:.1f} | Dir={confluence_result.direction.name}"
                )
            else:
                self.log.info(f"[SIGNAL_CHECK] Score {selected_score:.1f} BELOW threshold {self.config.execution_threshold}")
            if self._telemetry:
                self._telemetry.emit(
                    "signal_reject",
                    {
                        "reason": "score_below_threshold",
                        "score": selected_score,
                        "threshold": self.config.execution_threshold,
                        "bar": len(self._ltf_bars),
                    },
                )
            return

        # Determine signal direction + (optional) precomputed SL distance
        signal = SignalType.SIGNAL_NONE
        sl_distance = 0.0
        if selected_arm == RouterArm.SMC and confluence_result is not None:
            signal = confluence_result.direction
        elif selected_trend is not None:
            signal = SignalType.SIGNAL_BUY if selected_trend.direction == TrendDirection.LONG else SignalType.SIGNAL_SELL
            sl_distance = float(selected_trend.sl_distance)

        if signal == SignalType.SIGNAL_NONE:
            return

        # === HBS (Human Behavior Simulator) Gate ===
        # Pass signal through HBS for stealth execution decisions
        hbs_decision: HBSDecision | None = None
        if self._hbs and self._hbs.config.enabled:
            try:
                bar_time = datetime.fromtimestamp(bar.ts_event / 1e9, tz=timezone.utc)

                # Get current ATR for volatility-based decisions
                current_atr = self._get_current_atr()
                atr_percentile = self._get_atr_percentile()

                # Get current DD for crisis mode
                current_dd = 0.0
                if self._drawdown_tracker:
                    current_dd = self._drawdown_tracker.get_total_drawdown_pct()

                # Make HBS decision
                hbs_decision = self._hbs.decide(
                    signal_score=float(selected_score),
                    current_time=bar_time,
                    current_atr=current_atr,
                    atr_percentile=atr_percentile,
                    current_dd=current_dd
                )
                self._hbs_last_decision = hbs_decision

                # Check if HBS wants to skip this signal
                if hbs_decision.should_skip:
                    self._hbs_signals_skipped += 1
                    self.log.info(
                        f"[HBS] Signal SKIPPED: reason={hbs_decision.skip_reason}, "
                        f"total_skipped={self._hbs_signals_skipped}"
                    )
                    if self._telemetry:
                        self._telemetry.emit("hbs_skip", {
                            "reason": hbs_decision.skip_reason,
                            "signal_score": float(selected_score),
                            "bar": len(self._ltf_bars),
                            "total_skipped": self._hbs_signals_skipped
                        })
                    return

                # Log HBS decision
                if hbs_decision.delay_seconds > 0:
                    self._hbs_signals_delayed += 1

                self.log.debug(
                    f"[HBS] Decision: delay={hbs_decision.delay_seconds:.2f}s, "
                    f"order_type={hbs_decision.order_type}, "
                    f"size_mult={hbs_decision.size_multiplier:.2f}"
                )

            except Exception as exc:
                self.log.warning(f"[HBS] Decision failed, proceeding without HBS: {exc}")
                hbs_decision = None

        # Calculate position size
        if sl_distance <= 0.0:
            sl_distance = self._calculate_sl_distance(bar, signal)

        if sl_distance <= 0:
            return

        # NEW-C-03 FIX: Apply HBS size_multiplier to position sizing
        hbs_size_mult = hbs_decision.size_multiplier if hbs_decision else 1.0
        quantity = self._calculate_position_size(sl_distance, hbs_size_mult)

        if quantity is None or float(quantity) <= 0:
            return

        # Prop firm sizing/limits gate: validate_trade must pass before submitting any order.
        if self.config.prop_firm_enabled and self._prop_firm:
            qty_units = float(quantity.as_double()) if hasattr(quantity, "as_double") else float(quantity)
            risk_usd = float(sl_distance) * qty_units * float(self._instrument_point_value_per_unit())
            try:
                ok, reason = self._prop_firm.validate_trade(risk_amount=risk_usd, contracts=qty_units)
            except Exception as exc:
                super()._trigger_execution_failsafe(reason=f"prop_firm_validate_trade_exception:{type(exc).__name__}")
                return
            if not ok:
                if should_log:
                    self.log.info(f"[SIGNAL_CHECK] Prop firm validate_trade BLOCKED: {reason}")
                if self._telemetry:
                    self._telemetry.emit(
                        "signal_reject",
                        {"reason": "prop_firm_validate_trade", "detail": reason, "bar": len(self._ltf_bars)},
                    )
                return

        # Calculate SL and TP prices (tick/precision aware for spot vs futures)
        from decimal import Decimal

        current_price = bar.close.as_double()
        mode_label = selected_arm.value

        if signal == SignalType.SIGNAL_BUY:
            # Use Decimal for precise price calculations
            current_decimal = Decimal(str(current_price))
            sl_decimal = current_decimal - Decimal(str(sl_distance))
            # For BUY: round SL down (worse case / more conservative risk), TP down (easier to hit).
            sl_price = self._price_from_float(float(sl_decimal), rounding="floor")

            tp_distance = sl_distance * self.config.target_rr_ratio
            tp_decimal = current_decimal + Decimal(str(tp_distance))
            tp_price = self._price_from_float(float(tp_decimal), rounding="floor")

            if confluence_result is not None and selected_arm == RouterArm.SMC:
                self.log.info(
                    f"BUY Signal: mode={mode_label} score={selected_score:.1f} "
                    f"(smc_base={confluence_result.total_score:.1f}) "
                    f"Quality={confluence_result.quality.name} "
                    f"SL={sl_price}, TP={tp_price}"
                )
            else:
                self.log.info(f"BUY Signal: mode={mode_label} score={selected_score:.1f} SL={sl_price}, TP={tp_price}")

            if self._router:
                qty_units = float(quantity.as_double()) if hasattr(quantity, "as_double") else float(quantity)
                risk_usd = float(sl_distance) * qty_units * float(self._instrument_point_value_per_unit())
                sess = self._current_session.session.name if self._current_session else "UNKNOWN"
                reg = self._current_regime.regime.name if self._current_regime else "UNKNOWN"
                vol_bucket = int(max(0.0, min(4.0, float(self._get_atr_percentile()) // 20.0)))
                self._last_entry_meta = {
                    "arm": selected_arm.value,
                    "risk_usd": float(risk_usd),
                    "ctx": (str(sess), str(reg), int(vol_bucket)),
                    "score": float(selected_score),
                    "variant": selected_trend.variant.value if selected_trend else None,
                }
            self._enter_long(quantity, sl_price, tp_price)

            # CRUCIBLE FIX: Create trade in TradeManager for active management
            if self._trade_manager:
                try:
                    qty_decimal = Decimal(str(quantity.as_double()))
                    trade_info = self._trade_manager.create_trade(
                        direction=Direction.LONG,
                        entry_price=float(current_price),
                        stop_loss=float(sl_price.as_double()),
                        take_profit=float(tp_price.as_double()),
                        quantity=qty_decimal,
                        reason=f"SMC/{mode_label} score={selected_score:.1f}",
                    )
                    self._active_trade_id = trade_info.trade_id
                    self.log.info(f"[TRADE_MANAGER] Created trade {trade_info.trade_id} LONG")
                except Exception as exc:
                    self.log.warning(f"[TRADE_MANAGER] Failed to create trade: {exc}")
                    self._active_trade_id = None

        elif signal == SignalType.SIGNAL_SELL:
            # Use Decimal for precise price calculations
            current_decimal = Decimal(str(current_price))
            sl_decimal = current_decimal + Decimal(str(sl_distance))
            # For SELL: round SL up (worse case / more conservative risk), TP up (easier to hit).
            sl_price = self._price_from_float(float(sl_decimal), rounding="ceil")

            tp_distance = sl_distance * self.config.target_rr_ratio
            tp_decimal = current_decimal - Decimal(str(tp_distance))
            tp_price = self._price_from_float(float(tp_decimal), rounding="ceil")

            if confluence_result is not None and selected_arm == RouterArm.SMC:
                self.log.info(
                    f"SELL Signal: mode={mode_label} score={selected_score:.1f} "
                    f"(smc_base={confluence_result.total_score:.1f}) "
                    f"Quality={confluence_result.quality.name} "
                    f"SL={sl_price}, TP={tp_price}"
                )
            else:
                self.log.info(f"SELL Signal: mode={mode_label} score={selected_score:.1f} SL={sl_price}, TP={tp_price}")

            if self._router:
                qty_units = float(quantity.as_double()) if hasattr(quantity, "as_double") else float(quantity)
                risk_usd = float(sl_distance) * qty_units * float(self._instrument_point_value_per_unit())
                sess = self._current_session.session.name if self._current_session else "UNKNOWN"
                reg = self._current_regime.regime.name if self._current_regime else "UNKNOWN"
                vol_bucket = int(max(0.0, min(4.0, float(self._get_atr_percentile()) // 20.0)))
                self._last_entry_meta = {
                    "arm": selected_arm.value,
                    "risk_usd": float(risk_usd),
                    "ctx": (str(sess), str(reg), int(vol_bucket)),
                    "score": float(selected_score),
                    "variant": selected_trend.variant.value if selected_trend else None,
                }
            self._enter_short(quantity, sl_price, tp_price)

            # CRUCIBLE FIX: Create trade in TradeManager for active management
            if self._trade_manager:
                try:
                    qty_decimal = Decimal(str(quantity.as_double()))
                    trade_info = self._trade_manager.create_trade(
                        direction=Direction.SHORT,
                        entry_price=float(current_price),
                        stop_loss=float(sl_price.as_double()),
                        take_profit=float(tp_price.as_double()),
                        quantity=qty_decimal,
                        reason=f"SMC/{mode_label} score={selected_score:.1f}",
                    )
                    self._active_trade_id = trade_info.trade_id
                    self.log.info(f"[TRADE_MANAGER] Created trade {trade_info.trade_id} SHORT")
                except Exception as exc:
                    self.log.warning(f"[TRADE_MANAGER] Failed to create trade: {exc}")
                    self._active_trade_id = None

    def _get_current_atr(self) -> float:
        """Get current ATR value from LTF bars using simple TR calculation."""
        if len(self._ltf_bars) < 14:
            return 0.0

        try:
            highs = np.array([b.high.as_double() for b in self._ltf_bars[-14:]])
            lows = np.array([b.low.as_double() for b in self._ltf_bars[-14:]])
            closes = np.array([b.close.as_double() for b in self._ltf_bars[-15:-1]])

            # True Range = max(H-L, |H-C_prev|, |L-C_prev|)
            tr1 = highs - lows
            tr2 = np.abs(highs - closes)
            tr3 = np.abs(lows - closes)
            tr = np.maximum(tr1, np.maximum(tr2, tr3))

            return float(np.mean(tr))
        except Exception:
            return 0.0

    def _get_atr_percentile(self) -> float:
        """Get current ATR as percentile of recent ATR history (0-100)."""
        if len(self._ltf_bars) < 100:
            return 50.0  # Default to middle

        try:
            # Calculate rolling ATR for last 100 bars
            atr_history = []
            for i in range(86, 0, -1):  # 100-14=86 lookback positions
                slice_bars = self._ltf_bars[-(i+14):-i] if i > 0 else self._ltf_bars[-14:]
                if len(slice_bars) >= 14:
                    highs = np.array([b.high.as_double() for b in slice_bars])
                    lows = np.array([b.low.as_double() for b in slice_bars])
                    closes = np.array([b.close.as_double() for b in slice_bars[:-1]])
                    if len(closes) >= 13:
                        tr1 = highs[1:] - lows[1:]
                        tr2 = np.abs(highs[1:] - closes)
                        tr3 = np.abs(lows[1:] - closes)
                        tr = np.maximum(tr1, np.maximum(tr2, tr3))
                        atr_history.append(float(np.mean(tr)))

            if len(atr_history) < 10:
                return 50.0

            current_atr = self._get_current_atr()
            # Calculate percentile
            percentile = (np.sum(np.array(atr_history) < current_atr) / len(atr_history)) * 100
            return float(percentile)
        except Exception:
            return 50.0

    def _calculate_confluence(self, bar: Bar) -> ConfluenceResult | None:
        """Calculate confluence score from all analysis components."""
        if not self._confluence_scorer:
            if getattr(self.config, "debug_mode", False):
                self.log.debug("[CONFLUENCE] Scorer not initialized")
            return None

        try:
            # Get LTF data
            closes = np.array([b.close.as_double() for b in self._ltf_bars[-200:]])
            highs = np.array([b.high.as_double() for b in self._ltf_bars[-200:]])
            lows = np.array([b.low.as_double() for b in self._ltf_bars[-200:]])
            volumes = np.array([b.volume.as_double() for b in self._ltf_bars[-200:]])

            if len(closes) < 50:
                if getattr(self.config, "debug_mode", False):
                    self.log.debug("[CONFLUENCE] Not enough closes: %s", len(closes))
                return None

            # Analyze individual components
            structure_state = self._analyze_structure_component(highs, lows, closes)
            footprint_score = self._analyze_footprint_component(bar)
            sweeps = self._analyze_sweeps_component(highs, lows, closes)
            amd_cycle = self._analyze_amd_component(highs, lows, closes, volumes)

            # DEBUG: Log component state on first bar of each day for diagnosis
            bar_count = len(self._ltf_bars)
            if getattr(self.config, "debug_mode", False) and bar_count in [72, 360, 361, 362, 363, 364, 365]:
                struct_info = f"bias={structure_state.bias}" if structure_state else "None"
                self.log.debug(
                    "[DEBUG] Bar %s: closes=%s structure=%s fp=%.1f sweeps=%s amd=%s regime=%s MTF_OBs=%s MTF_FVGs=%s LTF_OBs=%s LTF_FVGs=%s",
                    bar_count,
                    len(closes),
                    struct_info,
                    footprint_score,
                    len(sweeps),
                    amd_cycle is not None,
                    self._current_regime.regime if self._current_regime else "None",
                    len(self._mtf_order_blocks),
                    len(self._mtf_fvgs),
                    len(self._ltf_order_blocks),
                    len(self._ltf_fvgs),
                )
            mtf_score, mtf_aligned = self._analyze_mtf_component(structure_state)

            # Analyze regime on LTF - update periodically for dynamic market conditions
            # BUG FIX: Wrapped in try/except to prevent cascade failure.
            # regime_detector requires 200 bars (max of multiscale_periods), not 100.
            # Removed the len(closes) >= 100 check - let the exception handler decide.
            if self._regime_detector:
                if len(self._ltf_bars) % 20 == 0 or self._current_regime is None:
                    try:
                        self._current_regime = self._regime_detector.analyze(closes)
                    except InsufficientDataError:
                        # Expected during warmup - regime stays None until enough data
                        pass
                    except Exception as e:
                        logger.debug(f"Regime detection error: {e}")

            # BUG-11 FIX: Detect order blocks on LTF (refresh every 20 bars)
            # Store in _ltf_order_blocks (not _mtf_order_blocks) to prevent semantic collision
            if self._ob_detector and len(self._ltf_bars) % 20 == 0:
                try:
                    opens = np.array([b.open.as_double() for b in self._ltf_bars[-200:]])
                    self._ltf_order_blocks = self._ob_detector.detect(opens, highs, lows, closes, volumes)
                except Exception as e:
                    logger.debug(f"OB detection error: {e}")

            # BUG-11 FIX: Detect FVGs on LTF (refresh every 20 bars)
            # Store in _ltf_fvgs (not _mtf_fvgs) to prevent semantic collision
            if self._fvg_detector and len(self._ltf_bars) % 20 == 0:
                try:
                    opens = np.array([b.open.as_double() for b in self._ltf_bars[-200:]])
                    self._ltf_fvgs = self._fvg_detector.detect(
                        opens, highs, lows, closes, volumes
                    )
                except Exception as e:
                    logger.debug(f"FVG detection error: {e}")

            # Calculate final confluence
            if len(self._ltf_bars) % 100 == 0:
                if getattr(self.config, "debug_mode", False):
                    self.log.debug(
                        "[CONFLUENCE] structure=%s regime=%s mtf_score=%.1f",
                        structure_state is not None,
                        self._current_regime is not None,
                        mtf_score,
                    )

            # Get current session enum for weight profile
            current_session_enum = TradingSession.SESSION_UNKNOWN
            if self._current_session:
                current_session_enum = self._current_session.session

            # BUG-3 FIX: Pass empty lists [] instead of None to prevent TypeError in calculate_score.
            # BUG-11 FIX: Use M15 OB/FVG (_mtf_*) for structure zones as per design.
            # Formula: None coalesces to [] for list parameters.
            bar_num = len(self._ltf_bars)
            try:
                result = self._confluence_scorer.calculate_score(
                    structure_state=structure_state,
                    regime_analysis=self._current_regime,
                    session_info=self._current_session,
                    order_blocks=self._mtf_order_blocks or [],  # M15 structure zones (BUG-11: kept separate from LTF)
                    fvgs=self._mtf_fvgs or [],  # M15 structure zones (BUG-11: kept separate from LTF)
                    sweeps=sweeps or [],  # BUG-3 FIX: [] if None
                    amd_cycle=amd_cycle,
                    mtf_score=mtf_score,
                    mtf_aligned=mtf_aligned,
                    footprint_score=footprint_score,
                    current_price=float(bar.close.as_double()),
                    current_session=current_session_enum,
                )
            except Exception as e:
                # BUG-3 FIX: Log with bar number for debugging + return empty result instead of None
                self.log.warning(f"[CONFLUENCE] Bar {bar_num}: calculate_score error: {e}")
                return None

            if len(self._ltf_bars) % 100 == 0:
                if result:
                    if getattr(self.config, "debug_mode", False):
                        self.log.debug(
                            "[CONFLUENCE] Result: score=%.1f signal=%s",
                            result.total_score,
                            result.direction,
                        )
                else:
                    if getattr(self.config, "debug_mode", False):
                        self.log.debug("[CONFLUENCE] Result is None from scorer")

            # Detailed verbose logging: show component breakdown every 50 bars
            if result and getattr(self.config, "debug_mode", False) and len(self._ltf_bars) % 50 == 0:
                self.log.info(
                    f"[VERBOSE] Bar {len(self._ltf_bars)} | Score={result.total_score:.1f} | "
                    f"Struct={result.structure_score:.1f} Regime={result.regime_score:.1f} "
                    f"OB={result.ob_score:.1f} FVG={result.fvg_score:.1f} "
                    f"Sweep={result.sweep_score:.1f} AMD={result.amd_score:.1f} "
                    f"Fib={result.fib_score:.1f} MTF={result.mtf_score:.1f} "
                    f"Session={result.session_score:.1f} | Dir={result.direction.name}"
                )

            return result

        except InsufficientDataError as e:
            # Expected early in a run until enough bars accumulate; avoid log spam.
            if self.config.debug_mode:
                # BUG-3 FIX: Add bar context for debugging
                _bar_ctx: int | str = len(self._ltf_bars) if hasattr(self, "_ltf_bars") else "?"
                self.log.debug(f"[CONFLUENCE] Bar {_bar_ctx}: Insufficient data: {e}")
            return None
        except Exception as e:
            # BUG-3 FIX: Add bar context for debugging
            _bar_ctx_ex: int | str = len(self._ltf_bars) if hasattr(self, "_ltf_bars") else "?"
            self.log.exception(f"[CONFLUENCE] Bar {_bar_ctx_ex}: Exception: %s", e)
            return None

    def _analyze_structure_component(
        self,
        highs: NDArray[np.floating[Any]],
        lows: NDArray[np.floating[Any]],
        closes: NDArray[np.floating[Any]],
    ) -> Any | None:
        """Analyze market structure component."""
        if not self._structure_analyzer:
            return None

        try:
            return self._structure_analyzer.analyze(highs, lows, closes)
        except InsufficientDataError:
            return None
        except Exception as e:
            self._log_once("structure_analyzer_error", f"Structure analysis failed: {e}", level="warning")
            return None

    def _analyze_footprint_component(self, bar: Bar) -> float:
        """Analyze footprint/order flow component."""
        if not self._footprint_analyzer or not self.config.use_footprint:
            return 0.0

        try:
            # R2-C-3 FIX: Pass bar timestamp for backtest correctness
            bar_time = datetime.fromtimestamp(bar.ts_event / 1e9, tz=timezone.utc)
            # BUG FIX: Correct argument order (high, low, open, close, volume)
            fp_result = self._footprint_analyzer.analyze_bar(
                bar.high.as_double(),
                bar.low.as_double(),
                bar.open.as_double(),
                bar.close.as_double(),
                int(bar.volume.as_double()),
                timestamp=bar_time,
            )
            return fp_result.score if fp_result else 0.0
        except InsufficientDataError:
            return 0.0
        except Exception as e:
            self._log_once("footprint_analyzer_error", f"Footprint analysis failed: {e}", level="warning")
            return 0.0

    def _analyze_sweeps_component(
        self,
        highs: NDArray[np.floating[Any]],
        lows: NDArray[np.floating[Any]],
        closes: NDArray[np.floating[Any]],
    ) -> list[Any]:
        """Analyze liquidity sweeps component."""
        if not self._sweep_detector:
            return []

        try:
            # detect() returns Tuple[List[LiquidityPool], List[LiquiditySweep]]
            pools, sweeps = self._sweep_detector.detect(highs, lows, closes)
            return list(sweeps)
        except InsufficientDataError:
            return []
        except Exception as e:
            self._log_once("sweep_detector_error", f"Sweep detection failed: {e}", level="warning")
            return []

    def _analyze_amd_component(
        self,
        highs: NDArray[np.floating[Any]],
        lows: NDArray[np.floating[Any]],
        closes: NDArray[np.floating[Any]],
        volumes: NDArray[np.floating[Any]]
    ) -> Any | None:
        """Analyze AMD cycle component."""
        if not self._amd_tracker:
            return None

        try:
            return self._amd_tracker.analyze(highs, lows, closes, volumes)
        except InsufficientDataError:
            return None
        except Exception as e:
            self._log_once("amd_tracker_error", f"AMD tracking failed: {e}", level="warning")
            return None

    def _analyze_mtf_component(self, structure_state: Any | None) -> tuple[float, bool]:
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
        """Calculate stop loss distance based on structure, clamped to limits.

        SL is clamped between MIN_SL_DISTANCE and MAX_SL_DISTANCE to prevent:
        - Too tight SL (premature stops)
        - Too wide SL (excessive single-trade losses - Oracle finding: $2300 losses)

        Formula: clamped_sl = max(MIN_SL, min(raw_sl, MAX_SL))
        Example: raw_sl=80, MIN=15, MAX=50 -> clamped=50
        """
        from ..core.definitions import MAX_SL_DISTANCE, MIN_SL_DISTANCE, DEFAULT_SL_DISTANCE

        raw_sl: float = 0.0

        if not self._structure_analyzer:
            # Fallback to ATR-based SL
            closes = np.array([b.close.as_double() for b in self._ltf_bars[-20:]])
            highs = np.array([b.high.as_double() for b in self._ltf_bars[-20:]])
            lows = np.array([b.low.as_double() for b in self._ltf_bars[-20:]])

            tr = np.maximum(highs - lows, np.abs(highs - np.roll(closes, 1)))
            tr = np.maximum(tr, np.abs(lows - np.roll(closes, 1)))
            atr = float(np.mean(tr[1:]))

            raw_sl = float(atr * 1.5)
        else:
            # Structure-based SL: place behind last swing
            last_low = float(self._structure_analyzer.get_last_swing_low())
            last_high = float(self._structure_analyzer.get_last_swing_high())
            close = float(bar.close.as_double())

            if signal == SignalType.SIGNAL_BUY and last_low > 0:
                # SL below last swing low
                raw_sl = float(close - last_low + (close * 0.0005))

            elif signal == SignalType.SIGNAL_SELL and last_high > 0:
                # SL above last swing high
                raw_sl = float(last_high - close + (close * 0.0005))
            else:
                # Fallback to ATR
                closes = np.array([b.close.as_double() for b in self._ltf_bars[-20:]])
                highs = np.array([b.high.as_double() for b in self._ltf_bars[-20:]])
                lows = np.array([b.low.as_double() for b in self._ltf_bars[-20:]])

                tr = np.maximum(highs - lows, np.abs(highs - np.roll(closes, 1)))
                tr = np.maximum(tr, np.abs(lows - np.roll(closes, 1)))
                atr = float(np.mean(tr[1:]))

                raw_sl = float(atr * 1.5)

        # Clamp SL distance to [MIN_SL_DISTANCE, MAX_SL_DISTANCE]
        # This prevents:
        # - Too tight stops (< MIN_SL_DISTANCE) that get hit by noise
        # - Huge losses (> MAX_SL_DISTANCE) that violate Apex DD limits
        if raw_sl <= 0:
            clamped_sl = DEFAULT_SL_DISTANCE
        else:
            clamped_sl = max(MIN_SL_DISTANCE, min(raw_sl, MAX_SL_DISTANCE))

        # Sanity check assertion
        assert MIN_SL_DISTANCE <= clamped_sl <= MAX_SL_DISTANCE, \
            f"SL clamping failed: {clamped_sl} not in [{MIN_SL_DISTANCE}, {MAX_SL_DISTANCE}]"

        return clamped_sl

    def _calculate_position_size(
        self, sl_distance: float, hbs_size_mult: float = 1.0
    ) -> Quantity | None:
        """Calculate position size based on risk, regime, and HBS.

        Args:
            sl_distance: Stop loss distance in price units
            hbs_size_mult: HBS size multiplier (NEW-C-03 FIX)
        """
        spread_mult = 1.0
        if self._spread_snapshot:
            spread_mult = max(0.0, min(1.0, self._spread_snapshot.size_multiplier))
        inst = self.instrument
        tick_size = float(inst.price_increment.as_double()) if inst is not None else float(XAUUSD_POINT)
        lot_size = float(inst.lot_size.as_double()) if inst is not None else float(XAUUSD_LOT_SIZE)
        point_value_per_unit = float(self._instrument_point_value_per_unit())

        if not self._position_sizer:
            # Default sizing (instrument-aware)
            # BUG-1 FIX: Apply max_risk_per_trade cap even in default path.
            # Previously, this path had NO risk cap, allowing unlimited risk.
            # Formula: capped_risk = min(risk_per_trade, max_risk_per_trade)
            # Example: risk_per_trade=0.03, max_risk_cap=0.02 -> use 0.02
            # CRITIC FIX: Clamp config max_risk to system MAX_RISK_PER_TRADE constant.
            # This prevents user misconfiguration (e.g., 10% max_risk) from bypassing system limits.
            # Formula: effective_max = min(config_max_risk, SYSTEM_MAX_RISK)
            # Example: config=0.05, SYSTEM=0.01 -> use 0.01 (system wins)
            from ..core.definitions import MAX_RISK_PER_TRADE
            config_max_risk = getattr(self.config, "max_risk_per_trade", MAX_RISK_PER_TRADE)
            max_risk_cap = min(float(config_max_risk), float(MAX_RISK_PER_TRADE))
            capped_risk = min(float(self.config.risk_per_trade), max_risk_cap)

            current_equity = self._equity_base
            risk_amount = current_equity * capped_risk
            risk_amount *= getattr(self, "_news_size_mult", 1.0)
            risk_amount *= getattr(self, "_dow_size_mult", 1.0)  # FORGE-NAUTILUS Wave 2: Day-of-week adjustment
            risk_amount *= spread_mult  # reduce size under high spread
            risk_amount *= hbs_size_mult  # NEW-C-03 FIX: apply HBS size multiplier

            denom = max(1e-9, sl_distance * max(1e-9, point_value_per_unit))
            qty_units = float(risk_amount / denom)
            return self._quantity_from_float(qty_units, rounding="floor")

        # Regime-adaptive sizing
        regime_mult = 1.0
        if self._current_regime:
            regime_mult = self._current_regime.size_multiplier

        # Calculate base size
        news_mult = getattr(self, "_news_size_mult", 1.0)
        dow_mult = getattr(self, "_dow_size_mult", 1.0)  # FORGE-NAUTILUS Wave 2: Day-of-week adjustment
        risk_pct = float(self.config.risk_per_trade) * news_mult * dow_mult * spread_mult * hbs_size_mult
        if self._circuit_breaker:
            risk_pct *= self._circuit_breaker.get_size_multiplier()

        # Use PositionSizer.calculate_lot (instrument-aware: "pip" == tick)
        sl_pips = sl_distance / max(1e-9, tick_size)
        pip_value = tick_size * point_value_per_unit * lot_size
        position_size = self._position_sizer.calculate_lot(
            balance=self._equity_base,
            risk_percent=risk_pct,
            stop_loss_pips=sl_pips,
            regime_multiplier=regime_mult,
            pip_value=float(pip_value),
        )

        # Normalize to float and wrap into Quantity
        try:
            pos_val = float(position_size)
        except Exception:
            return None

        if pos_val <= 0:
            return None

        lots = float(pos_val)
        qty_units = lots * lot_size
        return self._quantity_from_float(qty_units, rounding="floor")

    def on_quote_tick(self, tick: QuoteTick) -> None:
        """Track spread for spread filter."""
        super().on_quote_tick(tick)

        # Daily reset guard (ET calendar) to re-enable trading after prior cutoff blocks
        self._check_daily_reset(tick.ts_event)

        # Apex time guard on every tick - only if prop firm mode enabled
        if self.config.prop_firm_enabled and self._time_manager and not self._time_manager.check(tick.ts_event):
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
            except Exception as exc:
                # Fail closed on spread-monitor failure: treat as non-tradable until next good snapshot.
                self._spread_snapshot = None
                self._is_trading_allowed = False
                self._trading_blocked_today = True
                self.log.warning(f"[BLOCKED] spread_monitor_exception:{type(exc).__name__} -> trading halted")

        # Update prop-firm trailing drawdown with mark-to-market equity
        if self._prop_firm:
            equity = self._compute_equity_from_tick(tick)
            if equity is not None:
                try:
                    tick_dt = datetime.fromtimestamp(tick.ts_event / 1e9, tz=timezone.utc)
                    self._prop_firm.update_equity(equity, now=tick_dt)
                    self._prop_firm.ensure_compliance(now=tick_dt)
                    # If ensure_compliance triggers, it will hard-stop; fail-safe fallback.
                    if not self._prop_firm.can_trade(now=tick_dt):
                        super()._trigger_execution_failsafe(reason="prop_firm_dd_breach")
                        return
                except Exception as exc:
                    # Fail closed: do not keep trading if prop-firm compliance check errors.
                    super()._trigger_execution_failsafe(reason=f"prop_firm_intrabar_exception: {type(exc).__name__}")
                    return

        # Circuit breaker equity feed
        if self._circuit_breaker:
            equity = self._compute_equity_from_tick(tick)
            if equity is not None:
                try:
                    tick_dt = datetime.fromtimestamp(tick.ts_event / 1e9, tz=timezone.utc)
                    self._circuit_breaker.update_equity(equity, now=tick_dt)
                    if not self._circuit_breaker.can_trade(now=tick_dt):
                        # Circuit breaker breach while in-position: fail-safe flatten + halt.
                        super()._trigger_execution_failsafe(reason="circuit_breaker_dd_breach")
                        return
                except Exception as exc:
                    super()._trigger_execution_failsafe(reason=f"circuit_breaker_intrabar_exception: {type(exc).__name__}")
                    return

        # CRUCIBLE FIX: Process trade management (trailing/breakeven/partial) on every tick
        if self._position and self._trade_manager and self._active_trade_id:
            self._process_trade_management(tick)

        # TimeConstraintManager handles cutoff/flatten logic

    # ========== Trade Management (CRUCIBLE FIX) ==========

    def _process_trade_management(self, tick: QuoteTick) -> None:
        """
        Process active trade management: trailing stops, breakeven, partial profits.

        CRUCIBLE FIX: Replaces static "set and forget" with dynamic trade management.
        Expected improvement: 0.15R -> 0.60R per trade.

        Called on every quote tick when:
        - Position exists
        - TradeManager initialized
        - Active trade_id tracked
        """
        if not self._trade_manager or not self._active_trade_id or not self._position:
            return

        # Gate: Skip if SL modification in progress (prevent race conditions)
        if self._sl_modification_in_progress:
            return

        # Gate: Skip if partial close in progress
        if self._partial_close_in_progress:
            return

        try:
            # Get current price based on position side (conservative exit price)
            # LONG: use bid (price we'd get if exiting)
            # SHORT: use ask (price we'd get if covering)
            # This matches CLAUDE.md HWM_TRAP_WARNING price_basis rule
            if self._position.side == PositionSide.LONG:
                current_price = float(tick.bid_price.as_double())
            else:
                current_price = float(tick.ask_price.as_double())

            # Update TradeManager with current price
            actions = self._trade_manager.update_price(
                trade_id=self._active_trade_id,
                current_price=current_price,
            )

            if not actions:
                return

            # Process returned actions
            for action_type, action_data in actions.items():
                if action_type == "take_partial":
                    self._handle_partial_action(action_data, current_price)
                elif action_type == "adjust_sl":
                    self._handle_sl_adjust_action(action_data)
                elif action_type == "close_position":
                    self._handle_close_action(action_data)
                elif action_type == "state_changed":
                    # Log state transitions for analysis
                    self.log.info(
                        f"[TRADE_MANAGER] State changed to {action_data.get('new_state', 'UNKNOWN')}: "
                        f"{action_data.get('reason', '')}"
                    )
                elif action_type == "current_r":
                    # Informational: current R multiple (for logging/telemetry)
                    pass

        except Exception as exc:
            self.log.warning(f"[TRADE_MANAGER] _process_trade_management failed: {exc}")

    def _handle_partial_action(self, action_data: dict[str, Any], current_price: float) -> None:
        """
        Handle partial profit taking action from TradeManager.

        Closes a portion of the position to lock in profits.
        """
        if not self._position or self._partial_close_in_progress:
            return

        try:
            close_quantity = action_data.get("quantity", 0.0)
            reason = action_data.get("reason", "partial_tp")

            if close_quantity <= 0:
                return

            # Get current position quantity
            current_qty = float(self._position.quantity.as_double())

            # Ensure we don't try to close more than we have
            close_qty_actual = min(close_quantity, current_qty * 0.5)  # Max 50%

            if close_qty_actual <= 0:
                return

            self._partial_close_in_progress = True

            # Create quantity for partial close
            close_quantity_obj = self._quantity_from_float(close_qty_actual, rounding="floor")

            if close_quantity_obj is None or close_quantity_obj.as_double() <= 0:
                self._partial_close_in_progress = False
                return

            # Submit partial close order
            exit_side = OrderSide.SELL if self._position.side == PositionSide.LONG else OrderSide.BUY
            order = self.order_factory.market(
                instrument_id=self.config.instrument_id,
                order_side=exit_side,
                quantity=close_quantity_obj,
                time_in_force=TimeInForce.IOC,
                reduce_only=True,
            )
            self.submit_order(order)

            # Update TradeManager with partial execution
            if self._trade_manager and self._active_trade_id:
                self._trade_manager.execute_partial(
                    trade_id=self._active_trade_id,
                    closed_quantity=close_qty_actual,
                    close_price=current_price,
                    pnl=None,  # Will be calculated from position close event
                )

            self.log.info(
                f"[TRADE_MANAGER] Partial close submitted: qty={close_qty_actual:.2f}, "
                f"reason={reason}, price={current_price:.2f}"
            )

            # Note: _partial_close_in_progress will be cleared in a future tick
            # after order is filled (we don't track partial order IDs currently)
            # For simplicity, clear after submit (works for IOC orders in backtest)
            self._partial_close_in_progress = False

        except Exception as exc:
            self.log.warning(f"[TRADE_MANAGER] _handle_partial_action failed: {exc}")
            self._partial_close_in_progress = False

    def _handle_sl_adjust_action(self, action_data: dict[str, Any]) -> None:
        """
        Handle stop loss adjustment action from TradeManager.

        Cancels existing SL and submits new one at updated price.
        Used for: trailing stop, breakeven move.
        """
        if not self._position or self._sl_modification_in_progress:
            return

        try:
            new_sl = action_data.get("new_sl", 0.0)
            reason = action_data.get("reason", "sl_adjust")

            if new_sl <= 0:
                return

            # Validate SL move is in the right direction
            # LONG: new SL should be higher than or equal to entry (for breakeven/trail)
            # SHORT: new SL should be lower than or equal to entry (for breakeven/trail)
            if self._trade_manager and self._active_trade_id:
                trade_info = self._trade_manager.get_trade(self._active_trade_id)
                if trade_info:
                    if trade_info.direction == Direction.LONG:
                        # For LONG, SL should only move UP (or stay same)
                        if new_sl < trade_info.current_sl:
                            self.log.debug(f"[TRADE_MANAGER] Skipping SL move down: {new_sl} < {trade_info.current_sl}")
                            return
                    else:
                        # For SHORT, SL should only move DOWN (or stay same)
                        if new_sl > trade_info.current_sl:
                            self.log.debug(f"[TRADE_MANAGER] Skipping SL move up: {new_sl} > {trade_info.current_sl}")
                            return

            self._sl_modification_in_progress = True

            # Cancel existing SL order
            sl_order_id: str | None = getattr(self, "_bracket_sl_client_order_id", None)
            if sl_order_id:
                try:
                    # Find and cancel the existing SL order
                    self.cancel_order(ClientOrderId(sl_order_id))
                    self._pending_sl_cancel_order_id = sl_order_id
                    self.log.debug(f"[TRADE_MANAGER] Canceling old SL: {sl_order_id}")
                except Exception as cancel_exc:
                    self.log.warning(f"[TRADE_MANAGER] Failed to cancel old SL: {cancel_exc}")
                    self._sl_modification_in_progress = False
                    return

            # Submit new SL order at adjusted price
            new_sl_price = self._price_from_float(
                new_sl,
                rounding="floor" if self._position.side == PositionSide.LONG else "ceil"
            )

            exit_side = OrderSide.SELL if self._position.side == PositionSide.LONG else OrderSide.BUY
            sl_order = self.order_factory.stop_market(
                instrument_id=self.config.instrument_id,
                order_side=exit_side,
                quantity=self._position.quantity,
                trigger_price=new_sl_price,
                time_in_force=TimeInForce.GTC,
                reduce_only=True,
            )
            self.submit_order(sl_order)

            # Update tracking
            self._bracket_sl_client_order_id = str(sl_order.client_order_id)
            self._bracket_sl_confirmed = False  # Will be set in on_order_accepted

            # Update TradeManager state
            if self._trade_manager and self._active_trade_id:
                self._trade_manager.adjust_stop_loss(self._active_trade_id, new_sl)

            self.log.info(
                f"[TRADE_MANAGER] SL adjusted: new_sl={new_sl:.2f}, reason={reason}, "
                f"order_id={self._bracket_sl_client_order_id}"
            )

            # Clear modification flag (SL is now pending confirmation)
            self._sl_modification_in_progress = False

        except Exception as exc:
            self.log.warning(f"[TRADE_MANAGER] _handle_sl_adjust_action failed: {exc}")
            self._sl_modification_in_progress = False

    def _handle_close_action(self, action_data: dict[str, Any]) -> None:
        """
        Handle full position close action from TradeManager.

        Closes entire position (e.g., if trailing stop logic triggers internally).
        """
        if not self._position:
            return

        try:
            reason = action_data.get("reason", "trade_manager_close")
            self.log.info(f"[TRADE_MANAGER] Closing position: {reason}")
            self._close_position()
        except Exception as exc:
            self.log.warning(f"[TRADE_MANAGER] _handle_close_action failed: {exc}")

    # ========== Operational helpers ==========
    @staticmethod
    def _parse_cutoff(cutoff_str: str) -> Any:
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


    def _calculate_and_emit_metrics(self) -> PerformanceMetrics | None:
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
    def _compute_equity_from_tick(self, tick: QuoteTick) -> float | None:
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


