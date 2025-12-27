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
import random
import time
from datetime import datetime, timezone
from decimal import Decimal
from pathlib import Path
from typing import Any, Literal, cast

import numpy as np
from nautilus_trader.model import Bar, ClientOrderId, QuoteTick
from nautilus_trader.model.data import DataType
from nautilus_trader.model.enums import OrderSide, PositionSide, TimeInForce
from nautilus_trader.model.events import PositionClosed, PositionOpened
from nautilus_trader.model.objects import Quantity
from numpy.typing import NDArray

from ..context.holiday_detector import HolidayDetector
from ..core.data_types import ConfluenceResult, FairValueGap, OrderBlock
from ..core.definitions import (
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
    Direction,
    SignalType,
    TradingSession,
)
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
from ..execution.trade_manager import TradeManager
from ..indicators.amd_cycle_tracker import AMDCycleTracker
from ..indicators.footprint_analyzer import FootprintAnalyzer
from ..indicators.fvg_detector import FVGDetector
from ..indicators.liquidity_sweep import LiquiditySweepDetector
from ..indicators.order_block_detector import OrderBlockDetector
from ..indicators.regime_detector import RegimeDetector

# Import analyzers
from ..indicators.session_filter import SessionFilter
from ..indicators.structure_analyzer import MarketBias, StructureAnalyzer
from ..ml.entry_filter import OnnxEntryFilter
from ..risk.circuit_breaker import CircuitBreaker
from ..risk.drawdown_tracker import DrawdownTracker
from ..risk.exposure_caps import ExposureCaps
from ..risk.position_sizer import PositionSizer
from ..risk.prop_firm_manager import PropFirmManager
from ..risk.spread_monitor import SpreadMonitor
from ..risk.time_constraint_manager import TimeConstraintManager
from ..risk.unified_risk_policy import UnifiedRiskPolicy
from ..risk.virtual_gate import VirtualGate, VirtualGateInput
from ..risk.volatility_spacing import VolatilitySpacing
from ..signals.confluence_scorer import ConfluenceScorer
from ..signals.mean_revert import MeanRevertCandidate, generate_mean_revert_candidates

# Import signal generators
from ..signals.mtf_manager import MTFManager
from ..signals.news_calendar import NewsCalendar, NewsTradeAction, NewsWindow
from ..signals.news_data import NewsWindowData
from ..signals.trend_follow import (
    TrendDirection,
    TrendFollowCandidate,
    TrendFollowVariant,
    compute_psar_series,
    generate_trend_follow_candidates,
)
from ..utils.metrics import MetricsCalculator, PerformanceMetrics
from ..utils.telemetry import TelemetrySink
from .adaptive_router import AdaptiveEVRouter, RouterArm, RouterContext
from .adaptive_router import Candidate as RouterCandidate
from .base_strategy import BaseGoldStrategy, BaseStrategyConfig
from .strategy_selector import NewsImpact, StrategySelector, StrategyType

logger = logging.getLogger(__name__)


class GoldScalperConfig(BaseStrategyConfig):  # type: ignore[misc, unused-ignore]
    """Configuration for Gold Scalper Strategy."""

    # Timeframe configuration (minutes). Used for:
    # - Consistency checks and telemetry
    # - MTFManager semantic correctness (htf/mtf/ltf must be distinct)
    # - Management rate-limiting (management_bar_minutes)
    # Defaults follow CRUCIBLE recommendation: Entry=M15, Management=H1.
    ltf_bar_minutes: int = 15
    mtf_bar_minutes: int = 30
    htf_bar_minutes: int = 60
    management_bar_minutes: int = 60

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

    # Parabolic SAR (PSAR) - optional alignment filter (disabled by default)
    psar_enabled: bool = False
    psar_step: float = 0.02
    psar_max: float = 0.20
    psar_use_prev_bar: bool = True
    psar_trend_use_prev_bar: bool | None = None
    psar_smc_use_prev_bar: bool | None = None
    psar_apply_to_trend: bool = (
        False  # Disabled: evidence shows direction gates cause adverse selection
    )
    psar_apply_to_smc: bool = False

    # Strategy toggles (useful for isolated backtests)
    enable_smc: bool = True

    # TrendFollow (optional; disabled by default)
    enable_trend_follow: bool = False
    # Mode is an optional convenience override for the booleans below:
    # - "PULLBACK_ONLY" | "BREAKOUT_ONLY" | "BOTH"
    trend_follow_mode: str = "BOTH"
    enable_trend_pullback: bool = True
    enable_trend_breakout: bool = True

    # TrendFollow moving average type
    trend_ma_type: str = "EMA"  # EMA | SMA | WMA | HMA

    # TrendFollow core MA periods
    trend_ema_fast: int = 20
    trend_ema_slow: int = 50
    trend_pullback_lookback: int = 10

    # TrendFollow breakout variant tuning ("ER-gated breakout")
    # These are generic and do not rely on any proprietary EA implementation.
    trend_breakout_lookback: int = 30
    trend_min_atr_percentile_breakout: float = 65.0

    # Donchian breakout is the default to preserve existing behavior.
    trend_enable_donchian_breakout: bool = True

    # Optional swing breakout (StructureAnalyzer-style confirmed swings + ATR buffers).
    trend_enable_swing_breakout: bool = False
    trend_swing_strength: int = 3
    trend_swing_lookback_bars: int = 120

    # Breakout buffers
    trend_breakout_entry_buffer_atr_mult: float = 0.0
    trend_breakout_sl_buffer_atr_mult: float = 0.25

    # Pullback strictness
    trend_pullback_require_recross: bool = False
    trend_pullback_recross_lookback: int = 1

    trend_er_enabled: bool = False
    trend_er_period: int = 48
    trend_er_smoothing: int = 3
    trend_er_min: float = 0.30

    # TrendFollow signal-level tuning (CLI-sweepable via --trend-* args)
    trend_sep_ticks_min: float = 4.0  # EMA separation threshold in ticks
    trend_touch_dist_mult: float = 0.35  # Touch distance as ATR multiplier
    trend_min_score: float = 60.0  # Minimum signal score threshold

    ghost_mode: bool = False  # Ghost Test: replace signals with random
    ghost_seed: int = 1337  # Ghost Test seed (deterministic runs)

    trend_direction_mode: str = "NORMAL"  # NORMAL | INVERT (ablation test)

    # MeanRevert (optional; disabled by default)
    enable_mean_revert: bool = False
    # When true, MeanRevert runs even if StrategySelector would block / route elsewhere.
    # Intended for controlled evaluation (ablation/reachability), not default trading.
    force_mean_revert: bool = False
    mean_revert_bb_period: int = 20
    mean_revert_bb_k: float = 2.0
    mean_revert_rsi_period: int = 14
    mean_revert_rsi_oversold: float = 30.0
    mean_revert_rsi_overbought: float = 70.0
    mean_revert_max_atr_percentile: float = 70.0
    mean_revert_er_enabled: bool = False
    mean_revert_er_period: int = 48
    mean_revert_er_smoothing: int = 3
    mean_revert_er_max: float = 0.30

    # Optional regime stability gate (disabled by default).
    # If enabled, blocks new trades during regime transitions.
    regime_stability_min_bars: int = 0
    regime_stability_max_transition_prob: float = 1.0

    # TradeManager tuning (R-based) — configurable to test breakout-style management
    # Examples: trade_trailing_start_r=1.7 to mirror TrailingActCoef, target_rr_ratio=4.8 to mirror ProfitTargetCoef.
    trade_partial_tp_r: float = 1.0
    trade_partial_tp_percent: float = 0.5
    trade_trailing_start_r: float = 1.0

    # Optional per-arm TP RR overrides (if 0.0 => use BaseStrategyConfig.target_rr_ratio)
    trend_target_rr_ratio: float = 0.0
    mean_revert_target_rr_ratio: float = 0.0

    def resolve_tp_rr(self, *, arm: RouterArm) -> float:
        tp_rr = float(self.target_rr_ratio)
        if arm in (RouterArm.TREND_PULLBACK, RouterArm.TREND_BREAKOUT):
            override = float(self.trend_target_rr_ratio)
            if override > 0.0:
                tp_rr = override
        elif arm == RouterArm.MEAN_REVERT:
            override = float(self.mean_revert_target_rr_ratio)
            if override > 0.0:
                tp_rr = override
        return tp_rr

    # Phase 11 safety layer (entry-only)
    max_concurrent_positions: int = 1
    max_concurrent_instruments: int = 1
    vol_spacing_min_seconds: float = 0.0
    vol_spacing_max_seconds: float = 300.0
    vol_spacing_reference_atr: float = 1.0

    # Phase 11 safety layer: VirtualGate (entry-only, bar-only)
    virtual_gate_enabled: bool = True
    virtual_gate_lookback_bars: int = 20
    virtual_gate_range_spike_multiplier: float = 3.0
    virtual_gate_cluster_spike_multiplier: float = 2.5
    virtual_gate_cluster_max_fraction: float = 0.30
    virtual_gate_fail_open_on_insufficient_history: bool = True

    # Adaptive EV router (enabled by default for strategy arm selection)
    router_adaptive_ev: bool = True
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

    # Position sizing - ATR multiplier for SL distance calculation
    # Formula: sl_pips = atr_value * atr_multiplier
    # Example: ATR=2.5, atr_multiplier=1.5 -> SL = 3.75 pips
    atr_multiplier: float = 1.5

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
    spread_warmup_block_trading: bool = False

    # EDGE-1: Gap cooldown after market reopen / data gaps
    gap_reopen_threshold_minutes: float = 30.0
    gap_reopen_cooldown_minutes: float = 15.0

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

    # ML scaffolding (disabled by default).
    # Intended for offline-trained, deterministic inference (ONNX) and dataset capture.
    ml_filter_enabled: bool = False
    ml_filter_mode: str = "log_only"  # "log_only" | "gate"
    ml_filter_min_p_edge: float = 0.55
    ml_filter_model_path: str | None = None

    # When enabled, emits per-decision snapshots to telemetry for offline dataset building.
    ml_capture_enabled: bool = False

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

        # Configuration sanity checks
        if (
            (not bool(getattr(self.config, "enable_smc", True)))
            and (not bool(getattr(self.config, "enable_trend_follow", False)))
            and (not bool(getattr(self.config, "enable_mean_revert", False)))
        ):
            logger.warning(
                "[CONFIG] All paths disabled (enable_smc=false, enable_trend_follow=false, enable_mean_revert=false); strategy will not trade"
            )

        # Note: trend_follow_mode is validated and fail-closed in the signal path using _log_once.
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

        # Phase 11 safety layer components (entry-only)
        self._last_entry_ts_ns: int | None = None
        # FIX EDGE-2: Track last event timestamp to detect regressive timestamps
        self._last_event_ts_ns: int = 0
        # EDGE-1: Gap cooldown after market reopen / data gaps
        self._gap_last_seen_ts_ns: int = 0
        self._gap_cooldown_until_ts_ns: int | None = None
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
        self._execution_failsafe_triggered: bool = False

        # Unified entry gating surface (Phase 11 Safety Layer)
        self._exposure_caps = ExposureCaps(
            max_concurrent_positions=int(getattr(self.config, "max_concurrent_positions", 1)),
            max_concurrent_instruments=int(getattr(self.config, "max_concurrent_instruments", 1)),
        )
        self._volatility_spacing = VolatilitySpacing(
            min_cooldown_seconds=float(getattr(self.config, "vol_spacing_min_seconds", 0.0)),
            max_cooldown_seconds=float(getattr(self.config, "vol_spacing_max_seconds", 300.0)),
            reference_volatility=float(getattr(self.config, "vol_spacing_reference_atr", 1.0)),
        )
        self._virtual_gate = None
        if bool(getattr(self.config, "virtual_gate_enabled", True)):
            self._virtual_gate = VirtualGate(
                lookback_bars=int(getattr(self.config, "virtual_gate_lookback_bars", 20)),
                range_spike_multiplier=float(
                    getattr(self.config, "virtual_gate_range_spike_multiplier", 3.0)
                ),
                cluster_spike_multiplier=float(
                    getattr(self.config, "virtual_gate_cluster_spike_multiplier", 2.5)
                ),
                cluster_max_fraction=float(
                    getattr(self.config, "virtual_gate_cluster_max_fraction", 0.30)
                ),
                fail_open_on_insufficient_history=bool(
                    getattr(self.config, "virtual_gate_fail_open_on_insufficient_history", True)
                ),
            )

        self._unified_risk_policy = UnifiedRiskPolicy(
            exposure_caps=self._exposure_caps,
            news_guard=None,
            volatility_spacing=self._volatility_spacing,
            virtual_gate=self._virtual_gate,
        )

        # Adaptive router attribution (optional)
        self._router: AdaptiveEVRouter | None = None
        self._last_entry_meta: dict[str, object] | None = None
        self._trade_meta_by_pos: dict[str, dict[str, object]] = {}

        # Performance metrics tracking
        self._trade_pnl_history: list[float] = []
        self._metrics_calculator: MetricsCalculator | None = None
        self._last_metrics_emit: int = 0

        # BUG-PERF-001: Avoid repeated ATR computations and O(n^2) loops in hot path.
        # Cache key includes last completed LTF bar ts_event.
        # Note: Current ATR and ATR percentile are cached independently.
        self._atr_cache_current_key: tuple[int, int] | None = None
        self._atr_cache_current: float = 0.0
        self._atr_cache_percentile_key: tuple[int, int] | None = None
        self._atr_cache_percentile: float = 50.0

        # Analysis state (per timeframe)
        # BUG-11 FIX: Explicit timeframe-separated OB/FVG lists to prevent semantic collision.
        # Previously _mtf_order_blocks was overwritten by LTF detection (lines 1921-1937).
        # NOTE: Bias is fail-closed during warmup (RANGING blocks entries when require_htf_align=True).
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

        # ML entry filter (ONNX) - fail-open.
        self._ml_filter: OnnxEntryFilter | None = None
        self._ml_filter_initialized: bool = False

    def _log_once(
        self, key: str, msg: str, *, level: Literal["debug", "info", "warning", "error"] = "debug"
    ) -> None:
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
        self._last_mgmt_update_ts_ns: int | None = None
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
            multiscale_periods=list(
                getattr(self.config, "regime_multiscale_periods", (50, 100, 200))
            ),
        )

        # Structure analyzer (SMC) - configurable
        tick_size = (
            float(self.instrument.price_increment.as_double())
            if self.instrument
            else float(XAUUSD_POINT)
        )
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
            tick_size = (
                float(self.instrument.price_increment.as_double())
                if self.instrument
                else float(XAUUSD_POINT)
            )
            self._footprint_analyzer = FootprintAnalyzer(
                cluster_size=float(getattr(self.config, "footprint_cluster_size", 0.50)),
                tick_size=float(tick_size),
                imbalance_ratio=float(getattr(self.config, "footprint_imbalance_ratio", 3.0)),
                stacked_min=int(getattr(self.config, "footprint_stacked_min", 3)),
                absorption_threshold=float(
                    getattr(self.config, "footprint_absorption_threshold", 15.0)
                ),
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
            displacement_threshold=float(
                getattr(self.config, "ob_displacement_threshold_pips", 20.0)
            ),
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

        if bool(getattr(self.config, "use_mtf", True)):
            ltf_minutes = int(getattr(self.config, "ltf_bar_minutes", 15))
            mtf_minutes = int(getattr(self.config, "mtf_bar_minutes", 30))
            htf_minutes = int(getattr(self.config, "htf_bar_minutes", 60))

            if not (0 < ltf_minutes < mtf_minutes < htf_minutes):
                raise ValueError(
                    f"Invalid timeframe hierarchy: ltf={ltf_minutes}, mtf={mtf_minutes}, htf={htf_minutes} "
                    "(must satisfy ltf < mtf < htf)"
                )

            from ..signals.mtf_manager import Timeframe as MTFTimeframe

            ltf_tf = MTFTimeframe(ltf_minutes)
            mtf_tf = MTFTimeframe(mtf_minutes)
            htf_tf = MTFTimeframe(htf_minutes)

            self._mtf_manager = MTFManager(
                htf=htf_tf,
                mtf=mtf_tf,
                ltf=ltf_tf,
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
                regime_multiscale_periods=cast(
                    tuple[int, int, int],
                    getattr(self.config, "regime_multiscale_periods", (50, 100, 200)),
                ),
            )

        if self._mtf_manager is None:
            self.log.info("MTFManager disabled")

        # Confluence scorer (weights + filters configurable)
        self._confluence_scorer = ConfluenceScorer(
            min_score_to_trade=float(self.config.execution_threshold),
            use_session_filter=bool(self.config.use_session_filter),
            use_regime_filter=bool(self.config.use_regime_filter),
            weight_structure=float(
                getattr(self.config, "confluence_weight_structure", WEIGHT_STRUCTURE)
            ),
            weight_regime=float(getattr(self.config, "confluence_weight_regime", WEIGHT_REGIME)),
            weight_order_block=float(
                getattr(self.config, "confluence_weight_order_block", WEIGHT_ORDER_BLOCK)
            ),
            weight_fvg=float(getattr(self.config, "confluence_weight_fvg", WEIGHT_FVG)),
            weight_liquidity_sweep=float(
                getattr(self.config, "confluence_weight_liquidity_sweep", WEIGHT_LIQUIDITY_SWEEP)
            ),
            weight_amd_cycle=float(
                getattr(self.config, "confluence_weight_amd_cycle", WEIGHT_AMD_CYCLE)
            ),
            weight_fib=float(getattr(self.config, "confluence_weight_fib", WEIGHT_FIB)),
            weight_mtf=float(getattr(self.config, "confluence_weight_mtf", WEIGHT_MTF)),
            weight_footprint=float(
                getattr(self.config, "confluence_weight_footprint", WEIGHT_FOOTPRINT)
            ),
        )

        # News calendar (optional)
        if self.config.use_news_filter:
            self._news_calendar = NewsCalendar(
                events_path=getattr(self.config, "news_events_path", None)
            )

        # Execution realism (per-fill slippage + commission) - requires instrument.
        try:
            # R11-FIX: Replace assert with explicit check (assert disabled with -O).
            if self.instrument is None:
                raise RuntimeError("Instrument not initialized - cannot set up execution model")
            tick_size = float(self.instrument.price_increment.as_double())
            slippage_ticks = int(max(0, getattr(self.config, "slippage_ticks", 2)))
            base_cents = int(round(slippage_ticks * tick_size * 100))

            comm_source = str(getattr(self.config, "commission_source", "manual")).strip().lower()
            commission_per_lot: float | None

            if comm_source == "schedule":
                from nautilus_gold_scalper.src.execution.commission_schedule import (
                    commission_per_side_usd,
                )

                profile = str(getattr(self.config, "commission_profile", "apex")).strip().lower()
                gateway = (
                    str(getattr(self.config, "commission_gateway", "tradovate")).strip().lower()
                )

                raw_symbol = str(getattr(self.instrument, "raw_symbol", "")).strip().lower()
                if raw_symbol.startswith("mgc"):
                    product = "mgc"
                else:
                    product = "xauusd"

                try:
                    commission_per_lot = float(
                        commission_per_side_usd(
                            profile=profile,
                            product=product,
                            gateway=gateway,
                        )
                    )
                except Exception as exc:
                    commission_per_lot = float(getattr(self.config, "commission_per_contract", 2.5))
                    self.log.warning(
                        f"[EXEC_COSTS] commission schedule lookup failed (profile={profile}, gateway={gateway}, product={product}, raw_symbol={raw_symbol}); "
                        f"fallback commission_per_contract={commission_per_lot:.4f}. Error={type(exc).__name__}: {exc}"
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
            self.log.debug(
                f"ExecutionModel setup failed, fallback to zero costs: {type(exc).__name__}: {exc}"
            )
            self._execution_model = None

        # Risk management (if prop firm mode)
        if self.config.prop_firm_enabled:
            from ..risk.prop_firm_manager import PropFirmLimits

            limits = PropFirmLimits(
                account_size=self.config.account_balance,
                daily_loss_limit=self.config.account_balance
                * float(self.config.daily_loss_limit_pct)
                / 100,
                trailing_drawdown=self.config.account_balance
                * float(self.config.total_loss_limit_pct)
                / 100,
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

            # Get ATR multiplier from config (default 1.5 if not set)
            atr_mult = float(getattr(self.config, "atr_multiplier", 1.5))

            self._position_sizer = PositionSizer(
                risk_per_trade=float(self.config.risk_per_trade),
                max_risk_per_trade=float(max_risk_config),
                atr_multiplier=atr_mult,
            )

            self._drawdown_tracker = DrawdownTracker(
                initial_equity=float(self.config.account_balance),
                max_daily=float(self.config.daily_loss_limit_pct) / 100.0,
                max_total=float(self.config.total_loss_limit_pct) / 100.0,
                day_boundary_tz="America/New_York",
            )
            # Initialize prop-firm state with starting equity
            self._prop_firm.initialize(starting_equity=float(self.config.account_balance))
            # Expose consistency tracker for strategy-level guards/resets
            self._consistency_tracker = getattr(self._prop_firm, "_consistency", None)
            if self._consistency_tracker:
                try:
                    self._consistency_tracker.consistency_limit = Decimal(
                        str(self.config.consistency_cap_pct / 100.0)
                    )
                except Exception:
                    pass

        # Telemetry sink
        self._telemetry = TelemetrySink(
            Path(getattr(self.config, "telemetry_path", "logs/telemetry.jsonl")),
            enabled=bool(getattr(self.config, "telemetry_enabled", True)),
        )

        # ML filter setup (fail-open). Load at startup to avoid first-call latency.
        # NOTE: do not load in hot path; do not stop trading if model is missing.
        ml_enabled = bool(getattr(self.config, "ml_filter_enabled", False))
        ml_path = getattr(self.config, "ml_filter_model_path", None)
        if ml_enabled and ml_path:
            try:
                self._ml_filter = OnnxEntryFilter(Path(str(ml_path)))
                self._ml_filter.initialize()
                self._ml_filter_initialized = True
                if self._telemetry:
                    self._telemetry.emit(
                        "ml_filter_init",
                        {
                            "enabled": True,
                            "mode": str(getattr(self.config, "ml_filter_mode", "log_only")),
                            "model_path": str(ml_path),
                            "status": "ok" if self._ml_filter.init_error is None else "degraded",
                            "error": self._ml_filter.init_error,
                        },
                    )
            except Exception as exc:
                self._ml_filter = None
                self._ml_filter_initialized = False
                self._log_once(
                    "ml_filter_init_failed",
                    f"[ML_FILTER] init failed (fail-open): {type(exc).__name__}: {exc}",
                    level="warning",
                )
                if self._telemetry:
                    self._telemetry.emit(
                        "ml_filter_init",
                        {
                            "enabled": True,
                            "mode": str(getattr(self.config, "ml_filter_mode", "log_only")),
                            "model_path": str(ml_path),
                            "status": "failed",
                            "error": f"{type(exc).__name__}",
                        },
                    )
        elif ml_enabled and not ml_path:
            self._log_once(
                "ml_filter_missing_path",
                "[ML_FILTER] enabled but ml_filter_model_path is not set (fail-open)",
                level="warning",
            )
            if self._telemetry:
                self._telemetry.emit(
                    "ml_filter_init",
                    {
                        "enabled": True,
                        "mode": str(getattr(self.config, "ml_filter_mode", "log_only")),
                        "model_path": None,
                        "status": "missing_path",
                        "error": None,
                    },
                )

        # Initialize metrics calculator
        self._metrics_calculator = MetricsCalculator(risk_free_rate=0.05, trading_days_per_year=252)

        # Spread monitor (risk realism)
        self._spread_monitor = SpreadMonitor(
            symbol="XAUUSD",
            history_size=int(self.config.spread_history_size),
            warning_ratio=float(self.config.spread_warning_ratio),
            block_ratio=float(self.config.spread_block_ratio),
            max_spread_pips=float(self.config.max_spread_pips),
            update_interval=int(self.config.spread_update_interval),
            pip_factor=float(self.config.spread_pip_factor),
            warmup_block_trading=bool(getattr(self.config, "spread_warmup_block_trading", False)),
        )

        # Apex time cutoff manager
        self._time_manager = TimeConstraintManager(
            strategy=self,
            allow_overnight=self.config.allow_overnight,
            cutoff=self._parse_cutoff(self.config.flatten_time_et),
            warning=self._parse_cutoff(self.config.time_warning_et),
            urgent=self._parse_cutoff(self.config.time_urgent_et),
            emergency=self._parse_cutoff(self.config.time_emergency_et),
            telemetry=self._telemetry
            if getattr(self.config, "telemetry_capture_cutoff", True)
            else None,
            # R9-FIX: Pass prop_firm_enabled so TimeConstraintManager can
            # override allow_overnight=True when prop_firm_enabled=True.
            prop_firm_enabled=bool(getattr(self.config, "prop_firm_enabled", True)),
            clock=self.clock,
            use_clock_timer=(
                bool(getattr(self.config, "prop_firm_enabled", True))
                and bool(getattr(self.config, "time_gate_use_clock_timer", True))
            ),
            timer_interval_ns=int(
                getattr(self.config, "time_gate_timer_interval_ns", 10_000_000_000)
            ),
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
                allow_asian_session=bool(
                    getattr(self.config, "selector_allow_asian_session", False)
                ),
                hurst_trend_threshold=float(
                    getattr(self.config, "selector_hurst_trend_threshold", 0.55)
                ),
                hurst_revert_threshold=float(
                    getattr(self.config, "selector_hurst_revert_threshold", 0.40)
                ),
                entropy_low_threshold=float(
                    getattr(self.config, "selector_entropy_low_threshold", 1.5)
                ),
                entropy_high_threshold=float(
                    getattr(self.config, "selector_entropy_high_threshold", 2.5)
                ),
                holiday_detector=HolidayDetector(),
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
        if getattr(self.config, "hbs_enabled", True):
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
                        rng_seed_account_id=getattr(self.config, "hbs_account_id", ""),
                        apex_30pct_rule_enabled=True,
                        apex_profit_target=getattr(self.config, "hbs_profit_target", 3000.0),
                    )
                    hbs_config.validate()

                # Create economic calendar for event detection
                self._hbs_calendar = EconomicCalendar()

                # Create main HBS instance
                self._hbs = HumanBehaviorSimulator(config=hbs_config, calendar=self._hbs_calendar)

                # DelayedExecutor - backtest mode uses immediate execution
                is_live = hbs_mode in ("live", "paper")
                self._hbs_delayed_executor = DelayedExecutor(
                    clock=self.clock, is_live=is_live, max_pending=10
                )

                # Order lifecycle manager for limit order tracking
                self._hbs_order_lifecycle = OrderLifecycleManager()

                self.log.info(f"HBS initialized: mode={hbs_mode}, enabled=True")
            except Exception as exc:
                self.log.warning(
                    f"HBS initialization failed, trading without stealth: {type(exc).__name__}: {exc}"
                )
                self._hbs = None

        # Trade Manager initialization (CRUCIBLE FIX: active trade management)
        # Replaces static "set and forget" SL/TP with dynamic trailing/breakeven/partials
        partial_tp_r = float(getattr(self.config, "trade_partial_tp_r", 1.0))
        partial_tp_percent = float(getattr(self.config, "trade_partial_tp_percent", 0.5))
        trailing_start_r = float(getattr(self.config, "trade_trailing_start_r", 1.0))

        self._trade_manager = TradeManager(
            partial_tp_r=partial_tp_r,
            partial_tp_percent=partial_tp_percent,
            trailing_start_r=trailing_start_r,
        )
        self.log.info(
            "TradeManager initialized: "
            f"partial_tp_r={partial_tp_r}, partial_tp_percent={partial_tp_percent}, trailing_start_r={trailing_start_r}"
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
        required: list[tuple[str, object]] = [
            ("structure_analyzer", self._structure_analyzer),
            ("regime_detector", self._regime_detector),
            ("confluence_scorer", self._confluence_scorer),
            ("ob_detector", self._ob_detector),
            ("fvg_detector", self._fvg_detector),
            ("sweep_detector", self._sweep_detector),
            ("session_filter", self._session_filter),
        ]

        # MTF is optional depending on config.
        if bool(getattr(self.config, "use_mtf", True)):
            required.append(("mtf_manager", self._mtf_manager))

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
                    actual_entry = (
                        float(avg_px.as_double()) if hasattr(avg_px, "as_double") else float(avg_px)
                    )
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
                self.log.warning(f"[TRADE_MANAGER] fill_entry failed: {type(exc).__name__}: {exc}")
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
                    close_price = (
                        float(avg_px_close.as_double())
                        if hasattr(avg_px_close, "as_double")
                        else float(avg_px_close)
                    )
                else:
                    close_price = 0.0

                realized_pnl_val = getattr(event, "realized_pnl", None)
                if realized_pnl_val is not None:
                    realized_pnl = (
                        float(realized_pnl_val.as_double())
                        if hasattr(realized_pnl_val, "as_double")
                        else float(realized_pnl_val)
                    )
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
                self.log.warning(f"[TRADE_MANAGER] close_trade failed: {type(exc).__name__}: {exc}")
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
            ctx = RouterContext(
                session=str(ctx_raw[0]), regime=str(ctx_raw[1]), vol_bucket=int(ctx_raw[2])
            )

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
                        "ctx": {
                            "session": ctx.session,
                            "regime": ctx.regime,
                            "vol_bucket": ctx.vol_bucket,
                        },
                    },
                )
        except Exception as exc:
            self.log.debug(f"[ROUTER] post-close update failed: {type(exc).__name__}: {exc}")

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

        if not hasattr(self, "_last_reset_date"):
            self._last_reset_date = current_date_et
            # EDGE-1: Initialize gap guard state on first tick/bar
            self._gap_cooldown_until_ts_ns = None
            self._gap_last_seen_ts_ns = int(timestamp_ns)
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

            # EDGE-1: Reset gap guard for new ET trading day
            self._gap_cooldown_until_ts_ns = None
            self._gap_last_seen_ts_ns = int(timestamp_ns)

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
                except Exception as exc:
                    self.log.debug(
                        f"PropFirmManager daily reset failed: {type(exc).__name__}: {exc}"
                    )

            # Reset drawdown tracker if active
            if self._drawdown_tracker is not None and hasattr(self._drawdown_tracker, "on_new_day"):
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
                    self.log.debug(f"[HBS] Session start failed: {type(exc).__name__}: {exc}")

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
                self.log.debug(f"[HBS] Session end failed: {type(exc).__name__}: {exc}")

        # Shutdown delayed executor
        if self._hbs_delayed_executor:
            try:
                self._hbs_delayed_executor.shutdown()
                self.log.debug("[HBS] DelayedExecutor shutdown complete")
            except Exception as exc:
                self.log.debug(
                    f"[HBS] DelayedExecutor shutdown failed: {type(exc).__name__}: {exc}"
                )

        # Emit factor activation counters (always, even if no trades were closed)
        if self._telemetry and self._confluence_scorer:
            try:
                counters = self._confluence_scorer.get_factor_counters()
                self._telemetry.emit("factor_activation_counters", counters.as_dict())
            except Exception:
                pass

        # Calculate and emit final performance metrics
        self._calculate_and_emit_metrics()

        self.log.info("Gold Scalper Strategy cleanup complete")

    @staticmethod
    def _bars_to_np(
        bars: list[Bar],
        *,
        max_bars: int,
        field: Literal["open", "high", "low", "close", "volume"],
        dtype: type[np.floating[Any]] = np.float64,
    ) -> NDArray[np.floating[Any]]:
        """Fast conversion from Bar list to 1D numpy array.

        BUG-PERF-002: Avoid intermediate Python lists in hot paths.
        """
        if not bars:
            return np.array([], dtype=dtype)

        max_bars_i = int(max_bars)
        if max_bars_i <= 0:
            return np.array([], dtype=dtype)

        slice_bars = bars[-max_bars_i:]
        count = len(slice_bars)

        if field == "open":
            return np.fromiter((b.open.as_double() for b in slice_bars), dtype=dtype, count=count)
        if field == "high":
            return np.fromiter((b.high.as_double() for b in slice_bars), dtype=dtype, count=count)
        if field == "low":
            return np.fromiter((b.low.as_double() for b in slice_bars), dtype=dtype, count=count)
        if field == "close":
            return np.fromiter((b.close.as_double() for b in slice_bars), dtype=dtype, count=count)
        return np.fromiter((b.volume.as_double() for b in slice_bars), dtype=dtype, count=count)

    def _on_htf_bar(self, bar: Bar) -> None:
        """Process H1 bar - Update directional bias."""
        if not self._structure_analyzer:
            return

        closes = self._bars_to_np(self._htf_bars, max_bars=200, field="close")
        highs = self._bars_to_np(self._htf_bars, max_bars=200, field="high")
        lows = self._bars_to_np(self._htf_bars, max_bars=200, field="low")

        if len(closes) < 50:
            return

        slice_bars = self._htf_bars[-200:]
        timestamps = np.fromiter(
            (int(b.ts_event) for b in slice_bars),
            dtype=np.int64,
            count=len(slice_bars),
        ).view("datetime64[ns]")

        # Analyze structure for bias
        state = self._structure_analyzer.analyze(highs, lows, closes, timestamps)
        self._htf_bias = state.bias

        # Update regime (do NOT block trading here - check in _check_for_signal instead)
        if self._regime_detector:
            try:
                self._current_regime = self._regime_detector.analyze(closes)
                self.log.info(f"[HTF_REGIME] Regime detected: {self._current_regime.regime}")
            except InsufficientDataError:
                # Expected early in a run until enough HTF bars accumulate.
                self._current_regime = None

        if self.config.debug_mode:
            self.log.debug(
                f"HTF Bias: {self._htf_bias}, Regime: {self._current_regime.regime if self._current_regime else 'N/A'}"
            )

    def _on_mtf_bar(self, bar: Bar) -> None:
        """Process M15 bar - Update structure zones."""
        min_bars = 3
        if self._ob_detector is not None:
            min_bars = max(min_bars, int(getattr(self._ob_detector, "lookback_bars", 50)))
        if len(self._mtf_bars) < min_bars:
            return

        closes = self._bars_to_np(self._mtf_bars, max_bars=100, field="close")
        highs = self._bars_to_np(self._mtf_bars, max_bars=100, field="high")
        lows = self._bars_to_np(self._mtf_bars, max_bars=100, field="low")
        opens = self._bars_to_np(self._mtf_bars, max_bars=100, field="open")
        volumes = self._bars_to_np(self._mtf_bars, max_bars=100, field="volume")

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
                self._mtf_fvgs = self._fvg_detector.detect(opens, highs, lows, closes, volumes)
            except InsufficientDataError:
                return

        if self.config.debug_mode:
            self.log.debug(f"MTF: {len(self._mtf_order_blocks)} OBs, {len(self._mtf_fvgs)} FVGs")

    def _on_ltf_bar(self, bar: Bar) -> None:
        """Process M5 bar - Update execution-level analysis."""
        # Ensure daily counters unblock trading when a new ET day starts
        self._check_daily_reset(bar.ts_event)

        # Enforce intraday operational rules (Apex) - only if prop firm mode enabled
        if (
            self.config.prop_firm_enabled
            and self._time_manager
            and not self._time_manager.check(bar.ts_event)
        ):
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
            self.log.info(
                f"[SIGNAL_CHECK] Bar {len(self._ltf_bars)}: flat={self.is_flat}, allowed={self._is_trading_allowed}"
            )

        # Safety checks
        if not self.instrument:
            logger.error("Cannot check signal: instrument not loaded")
            if self._telemetry:
                self._telemetry.emit(
                    "signal_reject", {"reason": "no_instrument", "bar": len(self._ltf_bars)}
                )
            return

        if not self._is_trading_allowed:
            if should_log:
                self.log.info("[SIGNAL_CHECK] Trading not allowed (general flag)")
            if self._telemetry:
                self._telemetry.emit(
                    "signal_reject", {"reason": "trading_not_allowed", "bar": len(self._ltf_bars)}
                )
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
                    self.log.info(
                        f"[SIGNAL_CHECK] Session filter BLOCKED: {self._current_session.session.name if self._current_session else 'UNKNOWN'}"
                    )
                if self._telemetry:
                    self._telemetry.emit(
                        "signal_reject",
                        {
                            "reason": "session_filter",
                            "session": self._current_session.session.name
                            if self._current_session
                            else "UNKNOWN",
                            "bar": len(self._ltf_bars),
                        },
                    )
                return

        # FORGE-NAUTILUS Wave 2: Day-of-week adjustment (Monday/Friday risk)
        # Reset per-bar multiplier
        self._dow_size_mult = 1.0
        if self.config.use_session_filter and self._session_filter:
            can_trade_dow, dow_mult, dow_reason = self._session_filter.get_day_of_week_adjustment(
                bar_time
            )
            if not can_trade_dow:
                if should_log:
                    self.log.info(f"[SIGNAL_CHECK] Day-of-week BLOCKED: {dow_reason}")
                if self._telemetry:
                    self._telemetry.emit(
                        "signal_reject",
                        {
                            "reason": "day_of_week_filter",
                            "dow_reason": dow_reason,
                            "bar": len(self._ltf_bars),
                        },
                    )
                return
            # Store multiplier for position sizing (applied later)
            self._dow_size_mult = dow_mult
            if dow_mult < 1.0 and should_log:
                self.log.info(
                    f"[FILTER] Day-of-week size adjustment: {dow_mult:.2f}x ({dow_reason})"
                )

        # Optional: regime stability gate
        # Default is disabled (min_bars=0, max_transition_prob=1.0) to avoid signal starvation.
        min_bars = int(getattr(self.config, "regime_stability_min_bars", 0))
        max_tp = float(getattr(self.config, "regime_stability_max_transition_prob", 1.0))
        if min_bars > 0:
            if self._current_regime is None:
                # Fail-closed: if the user explicitly enabled the gate, do not trade until HTF regime is available.
                self._log_once(
                    "regime_stability_no_regime",
                    "[CONFIG] regime_stability_min_bars>0 but current_regime is None (HTF regime not initialized yet) - blocked",
                    level="warning",
                )
                return
            if self._regime_detector is None:
                # Fail-closed: if the detector is missing, the gate cannot be enforced.
                self._log_once(
                    "regime_stability_no_detector",
                    "[CONFIG] regime_stability_min_bars>0 but regime_detector is None - blocked",
                    level="warning",
                )
                return

            is_stable, regime_reason = self._regime_detector.is_regime_stable(
                min_bars=min_bars,
                max_transition_prob=max_tp,
            )
            if not is_stable:
                if should_log:
                    self.log.info(f"[SIGNAL_CHECK] Regime unstable: {regime_reason}")
                if self._telemetry:
                    self._telemetry.emit(
                        "signal_reject",
                        {
                            "reason": "regime_unstable",
                            "regime_reason": regime_reason,
                            "bar": len(self._ltf_bars),
                        },
                    )
                return

        # News filter (uses bar timestamp for backtest realism)
        news_window: NewsWindow | None = None
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
            except Exception as exc:
                if should_log:
                    self.log.debug(f"[NEWS] publish_data failed: {type(exc).__name__}: {exc}")

            if news_window.action == NewsTradeAction.BLOCK:
                if should_log:
                    self.log.info(f"[SIGNAL_CHECK] News filter BLOCKED: {news_window.reason}")
                if self._telemetry:
                    self._telemetry.emit(
                        "signal_reject",
                        {
                            "reason": "news_filter",
                            "news_reason": news_window.reason,
                            "bar": len(self._ltf_bars),
                        },
                    )
                return
            # apply conservative size/score adjustments
            self._news_size_mult = max(news_window.size_multiplier, 0.0)

        # EDGE-1: Gap cooldown after market reopen / data gaps
        gap_threshold_ns = int(float(self.config.gap_reopen_threshold_minutes) * 60.0 * 1e9)
        gap_cooldown_ns = int(float(self.config.gap_reopen_cooldown_minutes) * 60.0 * 1e9)

        if self._gap_last_seen_ts_ns <= 0:
            self._gap_last_seen_ts_ns = int(bar.ts_event)
            self._gap_cooldown_until_ts_ns = None
        else:
            gap_ns = int(bar.ts_event) - int(self._gap_last_seen_ts_ns)
            if gap_ns < 0:
                # Regressive timestamps handled elsewhere; fail closed here
                gap_ns = 0

            if gap_threshold_ns > 0 and gap_ns >= gap_threshold_ns:
                self._gap_cooldown_until_ts_ns = int(bar.ts_event) + gap_cooldown_ns
                if should_log:
                    self.log.warning(
                        f"[GAP] Detected data gap: {gap_ns / 1e9:.1f}s >= {gap_threshold_ns / 1e9:.1f}s; "
                        f"cooldown={gap_cooldown_ns / 1e9 / 60.0:.1f}m"
                    )

            self._gap_last_seen_ts_ns = int(bar.ts_event)

        if self._gap_cooldown_until_ts_ns is not None and int(bar.ts_event) < int(
            self._gap_cooldown_until_ts_ns
        ):
            if should_log:
                self.log.info(
                    f"[SIGNAL_CHECK] GAP cooldown active until {self._gap_cooldown_until_ts_ns}; blocking new entries"
                )
            return

        # Unified safety policy surface (Phase 11)
        # NOTE: This is entry-only gating; forced close / flatten must bypass it.
        time_gate_ok = True
        if self.config.prop_firm_enabled and self._time_manager:
            time_gate_ok = bool(self._time_manager.can_open_new(bar.ts_event))

        blocked_today = bool(
            self.config.prop_firm_enabled and getattr(self, "_trading_blocked_today", False)
        )

        prop_firm_ok = True
        if self.config.prop_firm_enabled and self._prop_firm:
            try:
                prop_firm_ok = bool(self._prop_firm.can_trade(now=bar_time))
            except Exception as exc:
                super()._trigger_execution_failsafe(
                    reason=f"prop_firm_signal_gate_exception:{type(exc).__name__}"
                )
                return

        cb_guard_ok = True
        if self._circuit_breaker:
            try:
                cb_guard_ok = bool(self._circuit_breaker.can_trade(now=bar_time))
            except Exception as exc:
                super()._trigger_execution_failsafe(
                    reason=f"circuit_breaker_signal_gate_exception:{type(exc).__name__}"
                )
                return

        open_positions_count = 1 if self._position is not None else 0
        open_instruments_count = 1 if self._position is not None else 0

        # Volatility proxy for spacing: use ATR (already computed deterministically from bars).
        atr = float(self._get_current_atr())

        decision = self._unified_risk_policy.evaluate_entry(
            time_gate_ok=time_gate_ok,
            blocked_today=blocked_today,
            prop_firm_ok=prop_firm_ok,
            circuit_ok=cb_guard_ok,
            must_flatten=False,
            open_positions_count=open_positions_count,
            open_instruments_count=open_instruments_count,
            news_window=news_window,
            now_utc=bar_time,
            last_entry_ts_ns=self._last_entry_ts_ns,
            now_ts_ns=int(bar.ts_event),
            volatility=atr,
            virtual_gate_input=(
                None
                if self._virtual_gate is None
                else VirtualGateInput(
                    decision_ts_ns=int(bar.ts_event),
                    bar_ts_ns=[
                        int(b.ts_event)
                        for b in self._ltf_bars[
                            -(int(getattr(self.config, "virtual_gate_lookback_bars", 20)) + 1) : -1
                        ]
                    ],
                    bar_highs=[
                        float(b.high.as_double())
                        for b in self._ltf_bars[
                            -(int(getattr(self.config, "virtual_gate_lookback_bars", 20)) + 1) : -1
                        ]
                    ],
                    bar_lows=[
                        float(b.low.as_double())
                        for b in self._ltf_bars[
                            -(int(getattr(self.config, "virtual_gate_lookback_bars", 20)) + 1) : -1
                        ]
                    ],
                )
            ),
            # NOTE: Avoid double-applying `news_window.size_multiplier`.
            # UnifiedRiskPolicy already applies `news_window.size_multiplier` to `size_factor`.
            base_size_factor=1.0,
        )

        if not decision.can_open_new:
            if should_log:
                self.log.info(
                    f"[SIGNAL_CHECK] UnifiedRiskPolicy BLOCKED: {','.join(decision.reasons) if decision.reasons else 'unknown'}"
                )
            if self._telemetry and decision.reasons:
                # Use the first reason for existing dashboards; keep details in log.
                self._telemetry.emit(
                    "signal_reject",
                    {
                        "ts": bar_time.isoformat(),
                        "reason": decision.reasons[0],
                        "bar": len(self._ltf_bars),
                    },
                )
            if (not prop_firm_ok) and self.config.prop_firm_enabled:
                self._is_trading_allowed = False
                self.log.warning(
                    "[BLOCKED] _is_trading_allowed = False (prop_firm.can_trade() returned False)"
                )
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
                                "ts": bar_time.isoformat(),
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
                super()._trigger_execution_failsafe(
                    reason=f"circuit_breaker_signal_gate_exception:{type(exc).__name__}"
                )
                return
            if not cb_allowed:
                if should_log:
                    self.log.info(
                        f"[SIGNAL_CHECK] Circuit breaker BLOCKED (level={cb_state.level.name})"
                    )
                if self._telemetry:
                    self._telemetry.emit(
                        "signal_reject",
                        {
                            "ts": bar_time.isoformat(),
                            "reason": "circuit_breaker",
                            "level": cb_state.level.name,
                            "bar": len(self._ltf_bars),
                        },
                    )
                return

        # Strategy selector gate (regime/session/safety context)
        selected_strategy: StrategyType | None = None
        if self._strategy_selector:
            try:
                circuit_ok = (
                    True
                    if not self._circuit_breaker
                    else self._circuit_breaker.can_trade(now=bar_time)
                )
            except Exception as exc:
                super()._trigger_execution_failsafe(
                    reason=f"circuit_breaker_signal_gate_exception:{type(exc).__name__}"
                )
                return
            spread_ok = True
            if self._spread_monitor is not None:
                spread_ok = (
                    bool(self._spread_snapshot.can_trade) if self._spread_snapshot else False
                )

            self._strategy_selector.set_regime(
                hurst=self._current_regime.hurst_exponent if self._current_regime else 0.5,
                entropy=self._current_regime.shannon_entropy if self._current_regime else 2.0,
            )

            # IMPORTANT: Use selector's internal context update so session/weekend/holiday
            # detection (including HolidayDetector) is not bypassed.
            self._strategy_selector.update_context(
                circuit_ok=circuit_ok,
                spread_ok=spread_ok,
                spread_ratio=self._spread_snapshot.spread_ratio
                if self._spread_snapshot and hasattr(self._spread_snapshot, "spread_ratio")
                else 1.0,
                daily_dd_percent=self._drawdown_tracker.get_daily_drawdown_pct()
                if self._drawdown_tracker
                else 0.0,
                total_dd_percent=self._drawdown_tracker.get_total_drawdown_pct()
                if self._drawdown_tracker
                else 0.0,
                in_news_window=bool(getattr(self, "_news_size_mult", 1.0) < 1.0),
                minutes_to_news=(
                    int(getattr(news_window, "minutes_to_event", 999))
                    if news_window is not None
                    else 999
                ),
                news_impact=(
                    NewsImpact.IMPACT_HIGH
                    if (
                        news_window is not None
                        and getattr(getattr(news_window, "event", None), "impact", None) is not None
                        and int(getattr(getattr(news_window, "event", None), "impact", 0)) >= 3
                    )
                    else (
                        NewsImpact.IMPACT_MEDIUM
                        if (
                            news_window is not None
                            and getattr(getattr(news_window, "event", None), "impact", None)
                            is not None
                            and int(getattr(getattr(news_window, "event", None), "impact", 0)) == 2
                        )
                        else NewsImpact.IMPACT_LOW
                    )
                ),
                atr=float(self._get_current_atr()),
                bar_time=bar_time,
            )

            selection = self._strategy_selector.select_strategy()
            selected_strategy = selection.strategy

            # Evaluation mode: force MeanRevert even when selector would block (e.g. RANDOM_WALK).
            # Safety gates still apply (spread/circuit/time/prop-firm).
            if (
                selection.strategy == StrategyType.STRATEGY_NONE
                and bool(getattr(self.config, "enable_mean_revert", False))
                and bool(getattr(self.config, "force_mean_revert", False))
            ):
                selected_strategy = StrategyType.STRATEGY_MEAN_REVERT
            elif selection.strategy in (
                StrategyType.STRATEGY_NONE,
                StrategyType.STRATEGY_SAFE_MODE,
            ):
                if should_log:
                    self.log.info(
                        f"[SIGNAL_CHECK] Strategy selector BLOCKED: {selection.strategy.name}, reason={selection.reason}"
                    )
                if self._telemetry:
                    self._telemetry.emit(
                        "signal_reject",
                        {
                            "reason": "strategy_selector",
                            "strategy": selection.strategy.name,
                            "selector_reason": selection.reason,
                            "bar": len(self._ltf_bars),
                        },
                    )
                return

        # Consistency rule (30% daily of cumulative profit)
        if self._consistency_tracker:
            try:
                ok = self._consistency_tracker.can_trade(
                    now=bar_time.astimezone(self._consistency_tracker.et_tz)
                )
            except Exception as exc:
                super()._trigger_execution_failsafe(
                    reason=f"consistency_tracker_gate_exception:{type(exc).__name__}"
                )
                return
            if not ok:
                if should_log:
                    self.log.info(
                        "[SIGNAL_CHECK] Consistency tracker BLOCKED (30% daily profit cap)"
                    )
                if self._telemetry:
                    self._telemetry.emit(
                        "signal_reject", {"reason": "consistency_cap", "bar": len(self._ltf_bars)}
                    )
                self._is_trading_allowed = False
                self.log.warning(
                    "[BLOCKED] _is_trading_allowed = False (consistency_tracker 30% daily cap)"
                )
                return

        # Check spread (fail-closed: block entries if spread is unknown or unhealthy)
        spread_score_adj = 0
        if self._spread_monitor is not None and self._spread_snapshot is None:
            # No valid spread data yet - fail closed (block entry)
            if should_log:
                self.log.info(
                    "[SIGNAL_CHECK] Spread BLOCKED: no spread snapshot (waiting for first quote)"
                )
            if self._telemetry:
                self._telemetry.emit(
                    "signal_reject", {"reason": "spread_missing", "bar": len(self._ltf_bars)}
                )
            return
        if self._spread_snapshot:
            if not self._spread_snapshot.can_trade:
                if should_log:
                    self.log.info(f"[SIGNAL_CHECK] Spread BLOCKED: {self._spread_snapshot.reason}")
                if self._telemetry:
                    self._telemetry.emit(
                        "signal_reject",
                        {
                            "reason": "spread_monitor",
                            "spread_reason": self._spread_snapshot.reason,
                            "bar": len(self._ltf_bars),
                        },
                    )
                return
            spread_score_adj = self._spread_snapshot.score_adjustment

        if self._current_spread > self.config.max_spread_points:
            if should_log:
                self.log.info(
                    f"[SIGNAL_CHECK] Spread too high: {self._current_spread} > {self.config.max_spread_points}"
                )
            if self._telemetry:
                self._telemetry.emit(
                    "signal_reject",
                    {
                        "reason": "spread_too_high",
                        "spread": self._current_spread,
                        "max": self.config.max_spread_points,
                        "bar": len(self._ltf_bars),
                    },
                )
            return

        # HTF alignment check (only if required)
        # Block trades when HTF trend is unclear (RANGING or TRANSITION)
        if self.config.require_htf_align:
            # CRITIC FIX: Also block when HTF bias is None (insufficient data)
            # This ensures we don't trade without HTF context when alignment is required
            if self._htf_bias is None:
                if should_log:
                    self.log.info(
                        "[SIGNAL_CHECK] HTF bias is None - blocked (insufficient HTF data)"
                    )
                if self._telemetry:
                    self._telemetry.emit(
                        "signal_reject", {"reason": "htf_bias_none", "bar": len(self._ltf_bars)}
                    )
                return
            if self._htf_bias in (MarketBias.RANGING, MarketBias.TRANSITION):
                if should_log:
                    self.log.info(
                        f"[SIGNAL_CHECK] HTF bias {self._htf_bias.name} - blocked (not trending)"
                    )
                if self._telemetry:
                    self._telemetry.emit(
                        "signal_reject",
                        {
                            "reason": "htf_not_trending",
                            "htf_bias": self._htf_bias.name,
                            "bar": len(self._ltf_bars),
                        },
                    )
                return

        # Calculate confluence score (SMC candidate) unless explicitly disabled.
        confluence_result = None
        if bool(getattr(self.config, "enable_smc", True)):
            if should_log:
                self.log.info(
                    f"[SIGNAL_CHECK] Calculating confluence at bar {len(self._ltf_bars)}..."
                )
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
                    self._telemetry.emit(
                        "signal_reject",
                        {
                            "reason": "htf_direction_conflict",
                            "htf_bias": self._htf_bias.name,
                            "signal_direction": confluence_result.direction.name,
                            "bar": len(self._ltf_bars),
                        },
                    )
                return

        news_score_adj = news_window.score_adjustment if news_window else 0
        effective_score = (
            (confluence_result.total_score + news_score_adj + spread_score_adj)
            if confluence_result
            else 0.0
        )

        try:
            inst = self.instrument
            tick_size = float(inst.price_increment.as_double()) if inst else float(XAUUSD_POINT)
            atr = float(self._get_current_atr())
            atr_p = float(self._get_atr_percentile())
            closes = self._bars_to_np(self._ltf_bars, max_bars=300, field="close")
            highs = self._bars_to_np(self._ltf_bars, max_bars=300, field="high")
            lows = self._bars_to_np(self._ltf_bars, max_bars=300, field="low")
        except Exception as exc:
            self.log.debug(f"[SIGNALS] LTF extraction failed: {type(exc).__name__}: {exc}")
            tick_size = float(XAUUSD_POINT)
            atr = 0.0
            atr_p = 0.0
            closes = np.array([], dtype=np.float64)
            highs = np.array([], dtype=np.float64)
            lows = np.array([], dtype=np.float64)

        # Optional TrendFollow candidates (pullback + breakout)
        trend_candidates: list[TrendFollowCandidate] = []
        if bool(getattr(self.config, "enable_trend_follow", False)):
            try:
                trend_candidates = generate_trend_follow_candidates(
                    closes=closes,
                    highs=highs,
                    lows=lows,
                    tick_size=tick_size,
                    atr=atr,
                    atr_percentile=atr_p,
                    ema_fast=int(getattr(self.config, "trend_ema_fast", 20)),
                    ema_slow=int(getattr(self.config, "trend_ema_slow", 50)),
                    ma_type=str(getattr(self.config, "trend_ma_type", "EMA")),
                    pullback_lookback=int(getattr(self.config, "trend_pullback_lookback", 10)),
                    breakout_lookback=int(getattr(self.config, "trend_breakout_lookback", 30)),
                    min_atr_percentile_breakout=float(
                        getattr(self.config, "trend_min_atr_percentile_breakout", 65.0)
                    ),
                    donchian_breakout_enabled=bool(
                        getattr(self.config, "trend_enable_donchian_breakout", True)
                    ),
                    swing_breakout_enabled=bool(
                        getattr(self.config, "trend_enable_swing_breakout", False)
                    ),
                    swing_strength=int(getattr(self.config, "trend_swing_strength", 3)),
                    swing_lookback_bars=int(getattr(self.config, "trend_swing_lookback_bars", 120)),
                    breakout_entry_buffer_atr_mult=float(
                        getattr(self.config, "trend_breakout_entry_buffer_atr_mult", 0.0)
                    ),
                    breakout_sl_buffer_atr_mult=float(
                        getattr(self.config, "trend_breakout_sl_buffer_atr_mult", 0.25)
                    ),
                    pullback_require_recross=bool(
                        getattr(self.config, "trend_pullback_require_recross", False)
                    ),
                    pullback_recross_lookback=int(
                        getattr(self.config, "trend_pullback_recross_lookback", 1)
                    ),
                    er_enabled=bool(getattr(self.config, "trend_er_enabled", False)),
                    er_period=int(getattr(self.config, "trend_er_period", 48)),
                    er_smoothing=int(getattr(self.config, "trend_er_smoothing", 3)),
                    er_min=float(getattr(self.config, "trend_er_min", 0.30)),
                    min_score=float(getattr(self.config, "trend_min_score", 60.0)),
                    sep_ticks_min=float(getattr(self.config, "trend_sep_ticks_min", 4.0)),
                    touch_dist_mult=float(getattr(self.config, "trend_touch_dist_mult", 0.35)),
                )

                # Direction ablations (TrendFollow only):
                # - ghost_mode: randomize LONG/SHORT deterministically (tests signal direction value)
                # - trend_direction_mode=INVERT: flip LONG<->SHORT (tests inversion hypothesis)
                if trend_candidates:
                    direction_mode = (
                        str(getattr(self.config, "trend_direction_mode", "NORMAL")).strip().upper()
                    )
                    if direction_mode == "INVERT":
                        inverted: list[TrendFollowCandidate] = []
                        for cand in trend_candidates:
                            if cand.direction == TrendDirection.LONG:
                                new_dir = TrendDirection.SHORT
                            else:
                                new_dir = TrendDirection.LONG
                            inverted.append(
                                TrendFollowCandidate(
                                    variant=cand.variant,
                                    direction=new_dir,
                                    score=cand.score,
                                    sl_distance=cand.sl_distance,
                                    reason=f"invert_{cand.reason}",
                                    meta={
                                        **cand.meta,
                                        "invert": True,
                                        "original_dir": cand.direction.name,
                                    },
                                )
                            )
                        trend_candidates = inverted

                    if bool(getattr(self.config, "ghost_mode", False)):
                        seed = int(getattr(self.config, "ghost_seed", 1337))
                        rng = random.Random(seed)

                        randomized: list[TrendFollowCandidate] = []
                        for cand in trend_candidates:
                            new_dir = rng.choice([TrendDirection.LONG, TrendDirection.SHORT])
                            randomized.append(
                                TrendFollowCandidate(
                                    variant=cand.variant,
                                    direction=new_dir,
                                    score=cand.score,
                                    sl_distance=cand.sl_distance,
                                    reason=f"ghost_{cand.reason}",
                                    meta={
                                        **cand.meta,
                                        "ghost": True,
                                        "ghost_seed": seed,
                                        "original_dir": cand.direction.name,
                                    },
                                )
                            )
                        trend_candidates = randomized

                mode = str(getattr(self.config, "trend_follow_mode", "BOTH")).strip().upper()
                valid_modes = {"PULLBACK_ONLY", "BREAKOUT_ONLY", "BOTH"}
                if mode not in valid_modes:
                    # Fail-closed: treat as disabled (do not silently increase aggressiveness).
                    trend_candidates = []
                    self._log_once(
                        "trend_follow_mode_invalid",
                        f"[CONFIG] Invalid trend_follow_mode={mode!r}; TrendFollow disabled",
                        level="warning",
                    )

                if mode == "PULLBACK_ONLY":
                    trend_candidates = [
                        c for c in trend_candidates if c.variant == TrendFollowVariant.PULLBACK
                    ]
                elif mode == "BREAKOUT_ONLY":
                    trend_candidates = [
                        c
                        for c in trend_candidates
                        if c.variant
                        in (TrendFollowVariant.BREAKOUT, TrendFollowVariant.SWING_BREAKOUT)
                    ]
                else:
                    if not bool(getattr(self.config, "enable_trend_pullback", True)):
                        trend_candidates = [
                            c for c in trend_candidates if c.variant != TrendFollowVariant.PULLBACK
                        ]
                    if not bool(getattr(self.config, "enable_trend_breakout", True)):
                        trend_candidates = [
                            c
                            for c in trend_candidates
                            if c.variant
                            not in (TrendFollowVariant.BREAKOUT, TrendFollowVariant.SWING_BREAKOUT)
                        ]
            except Exception as exc:
                self.log.debug(f"[TREND] candidate gen failed: {type(exc).__name__}: {exc}")
                trend_candidates = []

        # Optional MeanRevert candidates (BB + RSI)
        mean_candidates: list[MeanRevertCandidate] = []
        if bool(getattr(self.config, "enable_mean_revert", False)) and (
            selected_strategy == StrategyType.STRATEGY_MEAN_REVERT
        ):
            try:
                mean_candidates = generate_mean_revert_candidates(
                    closes=closes,
                    highs=highs,
                    lows=lows,
                    tick_size=tick_size,
                    atr=atr,
                    atr_percentile=atr_p,
                    bb_period=int(getattr(self.config, "mean_revert_bb_period", 20)),
                    bb_k=float(getattr(self.config, "mean_revert_bb_k", 2.0)),
                    rsi_period=int(getattr(self.config, "mean_revert_rsi_period", 14)),
                    rsi_oversold=float(getattr(self.config, "mean_revert_rsi_oversold", 30.0)),
                    rsi_overbought=float(getattr(self.config, "mean_revert_rsi_overbought", 70.0)),
                    max_atr_percentile=float(
                        getattr(self.config, "mean_revert_max_atr_percentile", 70.0)
                    ),
                    er_enabled=bool(getattr(self.config, "mean_revert_er_enabled", False)),
                    er_period=int(getattr(self.config, "mean_revert_er_period", 48)),
                    er_smoothing=int(getattr(self.config, "mean_revert_er_smoothing", 3)),
                    er_max=float(getattr(self.config, "mean_revert_er_max", 0.30)),
                    min_score=float(self.config.execution_threshold),
                )
            except Exception as exc:
                self.log.debug(f"[MEAN] candidate gen failed: {type(exc).__name__}: {exc}")
                mean_candidates = []

        # Optional Parabolic SAR (PSAR) alignment filter (t-1 by default).
        # This is applied *after* candidates are generated so we can block only the paths we want.
        if bool(getattr(self.config, "psar_enabled", False)):
            try:
                psar_step = float(getattr(self.config, "psar_step", 0.02))
                psar_max = float(getattr(self.config, "psar_max", 0.20))

                # Sanity: PSAR params must be positive and bounded.
                if psar_step <= 0.0 or psar_max <= 0.0:
                    raise ValueError("psar_step/psar_max must be > 0")
                if psar_step > psar_max:
                    raise ValueError("psar_step must be <= psar_max")

                sar = compute_psar_series(
                    highs=highs, lows=lows, closes=closes, af_step=psar_step, af_max=psar_max
                )
                if sar.size >= 2:
                    # NOTE: PSAR gating is direction-dependent.
                    # When signal candidates and PSAR reference different bars (t vs t-1), it can
                    # systematically reject the "correct" direction around flips.
                    apply_trend = bool(getattr(self.config, "psar_apply_to_trend", True))
                    apply_smc = bool(getattr(self.config, "psar_apply_to_smc", False))

                    default_use_prev = bool(getattr(self.config, "psar_use_prev_bar", True))
                    trend_use_prev = getattr(self.config, "psar_trend_use_prev_bar", None)
                    smc_use_prev = getattr(self.config, "psar_smc_use_prev_bar", None)

                    if apply_trend and trend_candidates:
                        use_prev = (
                            default_use_prev if trend_use_prev is None else bool(trend_use_prev)
                        )
                        idx = -2 if use_prev else -1
                        psar_value = float(sar[idx])
                        price_ref = float(closes[idx])

                        before = len(trend_candidates)
                        trend_candidates = [
                            c
                            for c in trend_candidates
                            if (c.direction == TrendDirection.LONG and price_ref > psar_value)
                            or (c.direction == TrendDirection.SHORT and price_ref < psar_value)
                        ]
                        if before > 0 and not trend_candidates and self._telemetry:
                            self._telemetry.emit(
                                "signal_reject",
                                {
                                    "reason": "psar_trend_alignment",
                                    "bar": len(self._ltf_bars),
                                    "psar": psar_value,
                                    "price": price_ref,
                                    "idx": idx,
                                },
                            )

                    if apply_smc and confluence_result is not None:
                        use_prev = default_use_prev if smc_use_prev is None else bool(smc_use_prev)
                        idx = -2 if use_prev else -1
                        psar_value = float(sar[idx])
                        price_ref = float(closes[idx])

                        allow_buy = price_ref > psar_value
                        allow_sell = price_ref < psar_value
                        if (
                            confluence_result.direction == SignalType.SIGNAL_BUY and not allow_buy
                        ) or (
                            confluence_result.direction == SignalType.SIGNAL_SELL and not allow_sell
                        ):
                            if self._telemetry:
                                self._telemetry.emit(
                                    "signal_reject",
                                    {
                                        "reason": "psar_smc_alignment",
                                        "bar": len(self._ltf_bars),
                                        "psar": psar_value,
                                        "price": price_ref,
                                        "idx": idx,
                                        "direction": confluence_result.direction.name,
                                    },
                                )
                            confluence_result = None
            except Exception as exc:
                # Fail open: PSAR is experimental and must never block trading due to misconfig.
                self.log.debug(f"[PSAR] filter skipped: {type(exc).__name__}: {exc}")

        if confluence_result is None and not trend_candidates and not mean_candidates:
            if should_log:
                self.log.info(
                    "[SIGNAL_CHECK] Confluence returned None (insufficient data or error)"
                )
            if self._telemetry:
                self._telemetry.emit(
                    "signal_reject", {"reason": "confluence_none", "bar": len(self._ltf_bars)}
                )
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
                        "ts": bar_time.isoformat(),
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

        # Router/deterministic selection: choose between SMC, TrendFollow variants, and MeanRevert
        selected_arm: RouterArm = RouterArm.SMC
        selected_score: float = float(effective_score)
        selected_trend: TrendFollowCandidate | None = None
        selected_mean: MeanRevertCandidate | None = None

        # Deterministic fallback (if router disabled)
        if trend_candidates:
            best_trend = max(
                trend_candidates,
                key=lambda c: (
                    float(c.score),
                    1 if c.variant == TrendFollowVariant.PULLBACK else 0,
                ),
            )
            if confluence_result is None or float(best_trend.score) > float(selected_score) + 1e-9:
                selected_trend = best_trend
                selected_mean = None
                selected_arm = (
                    RouterArm.TREND_PULLBACK
                    if best_trend.variant == TrendFollowVariant.PULLBACK
                    else RouterArm.TREND_BREAKOUT
                )
                selected_score = float(best_trend.score)

        if mean_candidates:
            best_mean = max(mean_candidates, key=lambda c: float(c.score))
            if confluence_result is None or float(best_mean.score) > float(selected_score) + 1e-9:
                selected_trend = None
                selected_mean = best_mean
                selected_arm = RouterArm.MEAN_REVERT
                selected_score = float(best_mean.score)

        # Adaptive router selection (EV w/ DD penalty) - optional
        if self._router:
            try:
                sess = self._current_session.session.name if self._current_session else "UNKNOWN"
                reg = self._current_regime.regime.name if self._current_regime else "UNKNOWN"
                # BUG-IND-004: Percentile is in [0, 100], bucket should be 0..4.
                # Use int(percentile // 20) which yields 0..5, then clamp.
                atr_p = float(self._get_atr_percentile())
                vol_bucket = int(max(0, min(4, int(atr_p // 20.0))))
                ctx = RouterContext(session=str(sess), regime=str(reg), vol_bucket=int(vol_bucket))

                router_candidates: list[RouterCandidate] = []
                if confluence_result is not None:
                    router_candidates.append(
                        RouterCandidate(
                            arm=RouterArm.SMC, score=float(effective_score), meta={"kind": "smc"}
                        )
                    )
                for tc in trend_candidates:
                    arm = (
                        RouterArm.TREND_PULLBACK
                        if tc.variant == TrendFollowVariant.PULLBACK
                        else RouterArm.TREND_BREAKOUT
                    )
                    router_candidates.append(
                        RouterCandidate(arm=arm, score=float(tc.score), meta={"kind": "trend"})
                    )
                for mc in mean_candidates:
                    router_candidates.append(
                        RouterCandidate(
                            arm=RouterArm.MEAN_REVERT, score=float(mc.score), meta={"kind": "mean"}
                        )
                    )

                sel = self._router.select(
                    ctx=ctx,
                    candidates=router_candidates,
                    execution_threshold=float(self.config.execution_threshold),
                    daily_dd_pct=float(
                        self._drawdown_tracker.get_daily_drawdown_pct()
                        if self._drawdown_tracker
                        else 0.0
                    ),
                    total_dd_pct=float(
                        self._drawdown_tracker.get_total_drawdown_pct()
                        if self._drawdown_tracker
                        else 0.0
                    ),
                    prefer=RouterArm.TREND_PULLBACK,
                )
                if sel is not None:
                    selected_arm = sel.arm
                    if selected_arm == RouterArm.SMC:
                        selected_trend = None
                        selected_mean = None
                        selected_score = float(effective_score)
                    elif selected_arm in (RouterArm.TREND_PULLBACK, RouterArm.TREND_BREAKOUT):
                        selected_mean = None
                        want = (
                            TrendFollowVariant.PULLBACK
                            if selected_arm == RouterArm.TREND_PULLBACK
                            else None
                        )
                        if want is not None:
                            selected_trend = max(
                                (c for c in trend_candidates if c.variant == want),
                                key=lambda x: float(x.score),
                                default=None,
                            )
                        else:
                            selected_trend = max(
                                (
                                    c
                                    for c in trend_candidates
                                    if c.variant
                                    in (
                                        TrendFollowVariant.BREAKOUT,
                                        TrendFollowVariant.SWING_BREAKOUT,
                                    )
                                ),
                                key=lambda x: float(x.score),
                                default=None,
                            )
                        selected_score = float(selected_trend.score) if selected_trend else 0.0
                    elif selected_arm == RouterArm.MEAN_REVERT:
                        selected_trend = None
                        selected_mean = max(
                            mean_candidates, key=lambda x: float(x.score), default=None
                        )
                        selected_score = float(selected_mean.score) if selected_mean else 0.0
                    else:
                        selected_trend = None
                        selected_mean = None
                        selected_score = 0.0

                    if self._telemetry:
                        self._telemetry.emit(
                            "router_select",
                            {
                                "arm": selected_arm.value,
                                "utility": sel.utility,
                                "reason": sel.reason,
                                "sampled_ev": sel.sampled_ev,
                                "dd_penalty": sel.dd_penalty,
                                "ctx": {
                                    "session": ctx.session,
                                    "regime": ctx.regime,
                                    "vol_bucket": ctx.vol_bucket,
                                },
                                "scores": {
                                    "smc": float(effective_score) if confluence_result else None,
                                    "trend_pullback": float(
                                        max(
                                            (
                                                c.score
                                                for c in trend_candidates
                                                if c.variant == TrendFollowVariant.PULLBACK
                                            ),
                                            default=0.0,
                                        )
                                    ),
                                    "trend_breakout": float(
                                        max(
                                            (
                                                c.score
                                                for c in trend_candidates
                                                if c.variant
                                                in (
                                                    TrendFollowVariant.BREAKOUT,
                                                    TrendFollowVariant.SWING_BREAKOUT,
                                                )
                                            ),
                                            default=0.0,
                                        )
                                    ),
                                    "mean_revert": float(
                                        max((c.score for c in mean_candidates), default=0.0)
                                    ),
                                },
                            },
                        )
            except Exception as exc:
                self.log.debug(f"[ROUTER] selection failed: {type(exc).__name__}: {exc}")

        # ML dataset snapshot (post-selection, pre-threshold): capture context + selection outcome.
        # Must never impact trading logic. Guarded by config.ml_capture_enabled.
        self._emit_ml_snapshot(
            stage="post_selection",
            payload={
                "ts_event": int(bar.ts_event),
                "instrument_id": str(getattr(self.config, "instrument_id", "")),
                "bar": int(len(self._ltf_bars)),
                "open": float(bar.open.as_double()),
                "high": float(bar.high.as_double()),
                "low": float(bar.low.as_double()),
                "close": float(bar.close.as_double()),
                "session": self._current_session.session.name
                if self._current_session
                else "UNKNOWN",
                "regime": self._current_regime.regime.name if self._current_regime else "UNKNOWN",
                "vol_bucket": int(max(0, min(4, int(float(self._get_atr_percentile()) // 20.0)))),
                "atr": float(self._get_current_atr()),
                "atr_percentile": float(self._get_atr_percentile()),
                "spread_points": float(self._current_spread),
                "news_in_window": bool(news_window.in_window) if news_window else False,
                "news_action": int(getattr(news_window.action, "value", news_window.action))
                if news_window
                else 0,
                "news_minutes_to_event": int(news_window.minutes_to_event) if news_window else 0,
                "arm": str(selected_arm.value),
                "selected_score": float(selected_score),
                "execution_threshold": float(self.config.execution_threshold),
                "smc_score": float(effective_score) if confluence_result is not None else None,
                "trend_best_score": float(
                    max((float(c.score) for c in trend_candidates), default=0.0)
                )
                if trend_candidates
                else None,
                "mean_best_score": float(
                    max((float(c.score) for c in mean_candidates), default=0.0)
                )
                if mean_candidates
                else None,
            },
        )

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
                self.log.info(
                    f"[SIGNAL_CHECK] Score {selected_score:.1f} BELOW threshold {self.config.execution_threshold}"
                )
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
            # HTF alignment for TrendFollow (prevent counter-trend entries when alignment is required).
            # If HTF bias is bullish, block SHORT trend candidates; if bearish, block LONG.
            if self.config.require_htf_align:
                htf_bullish = self._htf_bias == MarketBias.BULLISH
                htf_bearish = self._htf_bias == MarketBias.BEARISH
                trend_is_long = selected_trend.direction == TrendDirection.LONG
                if (htf_bullish and not trend_is_long) or (htf_bearish and trend_is_long):
                    if should_log:
                        self.log.info(
                            f"[SIGNAL_CHECK] TrendFollow direction {selected_trend.direction.value} "
                            f"opposes HTF bias {self._htf_bias.name} - blocked"
                        )
                    if self._telemetry:
                        self._telemetry.emit(
                            "signal_reject",
                            {
                                "reason": "htf_direction_conflict",
                                "htf_bias": self._htf_bias.name,
                                "signal_direction": selected_trend.direction.value,
                                "bar": len(self._ltf_bars),
                            },
                        )
                    return

            signal = (
                SignalType.SIGNAL_BUY
                if selected_trend.direction == TrendDirection.LONG
                else SignalType.SIGNAL_SELL
            )
            sl_distance = float(selected_trend.sl_distance)
        elif selected_mean is not None:
            # MeanRevert is only enabled when selector chooses MEAN_REVERT.
            signal = (
                SignalType.SIGNAL_BUY
                if selected_mean.direction == TrendDirection.LONG
                else SignalType.SIGNAL_SELL
            )
            sl_distance = float(selected_mean.sl_distance)

        if signal == SignalType.SIGNAL_NONE:
            return

        # === ML Entry Filter Gate (fail-open) ===
        # Runs after all existing safety gates and before HBS/position sizing.
        # In log_only mode it never blocks; in gate mode it blocks when p_edge < threshold.
        if bool(getattr(self.config, "ml_filter_enabled", False)) and self._ml_filter is not None:
            try:
                direction = (
                    TrendDirection.LONG.value
                    if signal == SignalType.SIGNAL_BUY
                    else TrendDirection.SHORT.value
                )
                payload = {
                    "open": float(bar.open.as_double()),
                    "high": float(bar.high.as_double()),
                    "low": float(bar.low.as_double()),
                    "close": float(bar.close.as_double()),
                    "atr": float(self._get_current_atr()),
                    "atr_percentile": float(self._get_atr_percentile()),
                    "spread_points": float(self._current_spread),
                    "selected_score": float(selected_score),
                    "execution_threshold": float(self.config.execution_threshold),
                }

                t0 = time.perf_counter_ns()
                decision_ml = self._ml_filter.predict(
                    payload,
                    direction=direction,
                    min_p_edge=float(getattr(self.config, "ml_filter_min_p_edge", 0.0)),
                    mode=str(getattr(self.config, "ml_filter_mode", "log_only")),
                )
                dt_ms = (time.perf_counter_ns() - t0) / 1e6

                if self._telemetry:
                    self._telemetry.emit(
                        "ml_filter_predict",
                        {
                            "direction": direction,
                            "mode": str(getattr(self.config, "ml_filter_mode", "log_only")),
                            "min_p_edge": float(getattr(self.config, "ml_filter_min_p_edge", 0.0)),
                            "p_edge": decision_ml.p_edge,
                            "should_trade": decision_ml.should_trade,
                            "reason": decision_ml.reason,
                            "latency_ms": float(decision_ml.latency_ms)
                            if decision_ml.latency_ms is not None
                            else float(dt_ms),
                            "bar": len(self._ltf_bars),
                        },
                    )

                if float(decision_ml.latency_ms or dt_ms) > 5.0 and self._telemetry:
                    self._telemetry.emit(
                        "ml_filter_slow",
                        {
                            "latency_ms": float(decision_ml.latency_ms or dt_ms),
                            "threshold_ms": 5.0,
                            "bar": len(self._ltf_bars),
                        },
                    )

                # Only gate if mode is gate and decision says no.
                if not decision_ml.should_trade:
                    if self._telemetry:
                        self._telemetry.emit(
                            "signal_reject",
                            {"reason": "ml_filter", "bar": len(self._ltf_bars)},
                        )
                    return
            except Exception as exc:
                self._log_once(
                    "ml_filter_apply_failed",
                    f"[ML_FILTER] apply failed (fail-open): {type(exc).__name__}: {exc}",
                    level="warning",
                )

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
                    current_dd=current_dd,
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
                        self._telemetry.emit(
                            "hbs_skip",
                            {
                                "reason": hbs_decision.skip_reason,
                                "signal_score": float(selected_score),
                                "bar": len(self._ltf_bars),
                                "total_skipped": self._hbs_signals_skipped,
                            },
                        )
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
                self.log.warning(
                    f"[HBS] Decision failed, proceeding without HBS: {type(exc).__name__}: {exc}"
                )
                hbs_decision = None

        # Calculate position size
        if sl_distance <= 0.0:
            sl_distance = self._calculate_sl_distance(bar, signal)

        if sl_distance <= 0:
            return

        # Phase 11 safety sizing: UnifiedRiskPolicy.size_factor is applied via _news_size_mult.
        # (Existing sizing pipeline multiplies _news_size_mult into risk_amount / risk_pct.)
        self._news_size_mult = float(decision.size_factor)

        # NEW-C-03 FIX: Apply HBS size_multiplier to position sizing
        hbs_size_mult = hbs_decision.size_multiplier if hbs_decision else 1.0
        quantity = self._calculate_position_size(sl_distance, hbs_size_mult)

        if quantity is None or float(quantity) <= 0:
            return

        # Prop firm sizing/limits gate: validate_trade must pass before submitting any order.
        if self.config.prop_firm_enabled and self._prop_firm:
            qty_units = (
                float(quantity.as_double()) if hasattr(quantity, "as_double") else float(quantity)
            )
            risk_usd = (
                float(sl_distance) * qty_units * float(self._instrument_point_value_per_unit())
            )
            try:
                ok, reason = self._prop_firm.validate_trade(
                    risk_amount=risk_usd, contracts=qty_units
                )
            except Exception as exc:
                super()._trigger_execution_failsafe(
                    reason=f"prop_firm_validate_trade_exception:{type(exc).__name__}"
                )
                return
            if not ok:
                if should_log:
                    self.log.info(f"[SIGNAL_CHECK] Prop firm validate_trade BLOCKED: {reason}")
                if self._telemetry:
                    self._telemetry.emit(
                        "signal_reject",
                        {
                            "reason": "prop_firm_validate_trade",
                            "detail": reason,
                            "bar": len(self._ltf_bars),
                        },
                    )
                return

        # Calculate SL and TP prices (tick/precision aware for spot vs futures)
        from decimal import Decimal

        current_price = bar.close.as_double()
        mode_label = selected_arm.value

        tp_rr = float(self.config.resolve_tp_rr(arm=selected_arm))

        if signal == SignalType.SIGNAL_BUY:
            # Use Decimal for precise price calculations
            current_decimal = Decimal(str(current_price))
            sl_decimal = current_decimal - Decimal(str(sl_distance))
            # For BUY: round SL down (worse case / more conservative risk), TP down (easier to hit).
            sl_price = self._price_from_float(float(sl_decimal), rounding="floor")

            tp_distance = sl_distance * tp_rr
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
                self.log.info(
                    f"BUY Signal: mode={mode_label} score={selected_score:.1f} SL={sl_price}, TP={tp_price}"
                )

            if self._router:
                qty_units = (
                    float(quantity.as_double())
                    if hasattr(quantity, "as_double")
                    else float(quantity)
                )
                risk_usd = (
                    float(sl_distance) * qty_units * float(self._instrument_point_value_per_unit())
                )
                sess = self._current_session.session.name if self._current_session else "UNKNOWN"
                reg = self._current_regime.regime.name if self._current_regime else "UNKNOWN"
                # BUG-IND-004: Percentile is in [0, 100], bucket should be 0..4.
                # Use int(percentile // 20) which yields 0..5, then clamp.
                atr_p = float(self._get_atr_percentile())
                vol_bucket = int(max(0, min(4, int(atr_p // 20.0))))
                self._last_entry_meta = {
                    "arm": selected_arm.value,
                    "risk_usd": float(risk_usd),
                    "ctx": (str(sess), str(reg), int(vol_bucket)),
                    "score": float(selected_score),
                    "variant": selected_trend.variant.value
                    if selected_trend
                    else (selected_mean.variant.value if selected_mean else None),
                }
            self._enter_long(quantity, sl_price, tp_price)
            self._last_entry_ts_ns = int(bar.ts_event)

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
                    self.log.warning(
                        f"[TRADE_MANAGER] Failed to create trade: {type(exc).__name__}: {exc}"
                    )
                    self._active_trade_id = None

        elif signal == SignalType.SIGNAL_SELL:
            # Use Decimal for precise price calculations
            current_decimal = Decimal(str(current_price))
            sl_decimal = current_decimal + Decimal(str(sl_distance))
            # For SELL: round SL up (worse case / more conservative risk), TP up (easier to hit).
            sl_price = self._price_from_float(float(sl_decimal), rounding="ceil")

            tp_distance = sl_distance * tp_rr
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
                self.log.info(
                    f"SELL Signal: mode={mode_label} score={selected_score:.1f} SL={sl_price}, TP={tp_price}"
                )

            if self._router:
                qty_units = (
                    float(quantity.as_double())
                    if hasattr(quantity, "as_double")
                    else float(quantity)
                )
                risk_usd = (
                    float(sl_distance) * qty_units * float(self._instrument_point_value_per_unit())
                )
                sess = self._current_session.session.name if self._current_session else "UNKNOWN"
                reg = self._current_regime.regime.name if self._current_regime else "UNKNOWN"
                # BUG-IND-004: Percentile is in [0, 100], bucket should be 0..4.
                # Use int(percentile // 20) which yields 0..5, then clamp.
                atr_p = float(self._get_atr_percentile())
                vol_bucket = int(max(0, min(4, int(atr_p // 20.0))))
                self._last_entry_meta = {
                    "arm": selected_arm.value,
                    "risk_usd": float(risk_usd),
                    "ctx": (str(sess), str(reg), int(vol_bucket)),
                    "score": float(selected_score),
                    "variant": selected_trend.variant.value
                    if selected_trend
                    else (selected_mean.variant.value if selected_mean else None),
                }
            self._enter_short(quantity, sl_price, tp_price)
            self._last_entry_ts_ns = int(bar.ts_event)

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
                    self.log.warning(
                        f"[TRADE_MANAGER] Failed to create trade: {type(exc).__name__}: {exc}"
                    )
                    self._active_trade_id = None

    def _get_current_atr(self) -> float:
        """Get current ATR value from LTF bars using simple TR calculation."""
        # Need 15 bars: 14 TR values require 14 previous closes.
        if len(self._ltf_bars) < 15:
            return 0.0

        # BUG-PERF-001: compute at most once per completed LTF bar.
        key = (len(self._ltf_bars), int(self._ltf_bars[-1].ts_event))
        if self._atr_cache_current_key == key:
            return float(self._atr_cache_current)

        try:
            highs = self._bars_to_np(self._ltf_bars, max_bars=14, field="high")
            lows = self._bars_to_np(self._ltf_bars, max_bars=14, field="low")
            prev_closes = self._bars_to_np(self._ltf_bars[-15:-1], max_bars=14, field="close")

            # True Range = max(H-L, |H-C_prev|, |L-C_prev|)
            tr1 = highs - lows
            tr2 = np.abs(highs - prev_closes)
            tr3 = np.abs(lows - prev_closes)
            tr = np.maximum(tr1, np.maximum(tr2, tr3))

            atr = float(np.mean(tr))
            if not np.isfinite(atr) or atr < 0.0:
                atr = 0.0
        except Exception:
            atr = 0.0

        self._atr_cache_current_key = key
        self._atr_cache_current = float(atr)
        return float(atr)

    def _get_atr_percentile(self) -> float:
        """Get current ATR as percentile of recent ATR history (0-100)."""
        if len(self._ltf_bars) < 100:
            return 50.0  # Default to middle

        # BUG-PERF-001: compute at most once per completed LTF bar.
        key = (len(self._ltf_bars), int(self._ltf_bars[-1].ts_event))
        if self._atr_cache_percentile_key == key:
            return float(self._atr_cache_percentile)

        try:
            # BUG-PERF-003: Previous implementation recomputed ~86 ATR windows per call
            # with repeated list->np.array conversions (O(n^2) per bar). Replace with a
            # single pass over true-range series and a sliding mean.
            highs = self._bars_to_np(self._ltf_bars, max_bars=102, field="high")
            lows = self._bars_to_np(self._ltf_bars, max_bars=102, field="low")
            prev_closes = self._bars_to_np(self._ltf_bars[-103:-1], max_bars=102, field="close")

            tr1 = highs[1:] - lows[1:]
            tr2 = np.abs(highs[1:] - prev_closes)
            tr3 = np.abs(lows[1:] - prev_closes)
            tr = np.maximum(tr1, np.maximum(tr2, tr3))

            window = 14
            if tr.size < window:
                percentile = 50.0
            else:
                csum = np.cumsum(tr, dtype=np.float64)
                sums = csum[window - 1 :] - np.concatenate(
                    [np.zeros(1, dtype=np.float64), csum[:-window]]
                )
                atr_series = sums / float(window)

                if atr_series.size < 10:
                    percentile = 50.0
                else:
                    current_atr = float(self._get_current_atr())
                    percentile = float(
                        (np.sum(atr_series < current_atr) / float(atr_series.size)) * 100.0
                    )

            percentile = float(max(0.0, min(100.0, percentile)))
        except Exception:
            percentile = 50.0

        self._atr_cache_percentile_key = key
        self._atr_cache_percentile = float(percentile)
        return float(percentile)

    def _calculate_confluence(self, bar: Bar) -> ConfluenceResult | None:
        """Calculate confluence score from all analysis components."""
        if not self._confluence_scorer:
            if getattr(self.config, "debug_mode", False):
                self.log.debug("[CONFLUENCE] Scorer not initialized")
            return None

        try:
            # Get LTF data
            closes = self._bars_to_np(self._ltf_bars, max_bars=200, field="close")
            highs = self._bars_to_np(self._ltf_bars, max_bars=200, field="high")
            lows = self._bars_to_np(self._ltf_bars, max_bars=200, field="low")
            volumes = self._bars_to_np(self._ltf_bars, max_bars=200, field="volume")

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
            if getattr(self.config, "debug_mode", False) and bar_count in [
                72,
                360,
                361,
                362,
                363,
                364,
                365,
            ]:
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
                    except Exception:
                        logger.debug("Regime detection error", exc_info=True)

            # BUG-11 FIX: Detect order blocks on LTF (refresh every 20 bars)
            # Store in _ltf_order_blocks (not _mtf_order_blocks) to prevent semantic collision
            if self._ob_detector and len(self._ltf_bars) % 20 == 0:
                try:
                    opens = self._bars_to_np(self._ltf_bars, max_bars=200, field="open")
                    self._ltf_order_blocks = self._ob_detector.detect(
                        opens, highs, lows, closes, volumes
                    )
                except Exception:
                    logger.debug("OB detection error", exc_info=True)

            # BUG-11 FIX: Detect FVGs on LTF (refresh every 20 bars)
            # Store in _ltf_fvgs (not _mtf_fvgs) to prevent semantic collision
            if self._fvg_detector and len(self._ltf_bars) % 20 == 0:
                try:
                    opens = self._bars_to_np(self._ltf_bars, max_bars=200, field="open")
                    self._ltf_fvgs = self._fvg_detector.detect(opens, highs, lows, closes, volumes)
                except Exception:
                    logger.debug("FVG detection error", exc_info=True)

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
                    order_blocks=self._mtf_order_blocks
                    or [],  # M15 structure zones (BUG-11: kept separate from LTF)
                    fvgs=self._mtf_fvgs
                    or [],  # M15 structure zones (BUG-11: kept separate from LTF)
                    sweeps=sweeps or [],  # BUG-3 FIX: [] if None
                    amd_cycle=amd_cycle,
                    mtf_score=mtf_score,
                    mtf_aligned=mtf_aligned,
                    footprint_score=footprint_score,
                    current_price=float(bar.close.as_double()),
                    current_session=current_session_enum,
                )
            except Exception as exc:
                # BUG-3 FIX: Nautilus `Logger.warning` does not accept `exc_info=`; include error inline.
                self.log.warning(
                    "[CONFLUENCE] Bar %s: calculate_score error: %s: %s",
                    bar_num,
                    type(exc).__name__,
                    exc,
                )
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
            if (
                result
                and getattr(self.config, "debug_mode", False)
                and len(self._ltf_bars) % 50 == 0
            ):
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
                # BUG-3 FIX: Nautilus Logger does not accept exc_info; include error inline.
                _bar_ctx: int | str = len(self._ltf_bars) if hasattr(self, "_ltf_bars") else "?"
                self.log.debug(
                    "[CONFLUENCE] Bar %s: Insufficient data: %s",
                    _bar_ctx,
                    e,
                )
            return None
        except Exception as exc:
            # BUG-3 FIX: Nautilus Logger does not accept exc_info; include error inline.
            _bar_ctx_ex: int | str = len(self._ltf_bars) if hasattr(self, "_ltf_bars") else "?"
            self.log.error(
                "[CONFLUENCE] Bar %s: Exception: %s: %s",
                _bar_ctx_ex,
                type(exc).__name__,
                exc,
            )
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
            slice_bars = self._ltf_bars[-200:]
            timestamps = np.fromiter(
                (int(b.ts_event) for b in slice_bars),
                dtype=np.int64,
                count=len(slice_bars),
            ).view("datetime64[ns]")
            return self._structure_analyzer.analyze(highs, lows, closes, timestamps)
        except InsufficientDataError:
            return None
        except Exception as e:
            self._log_once(
                "structure_analyzer_error", f"Structure analysis failed: {e}", level="warning"
            )
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
            self._log_once(
                "footprint_analyzer_error", f"Footprint analysis failed: {e}", level="warning"
            )
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
        volumes: NDArray[np.floating[Any]],
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

        # BUG-IND-003: Prevent accidental look-ahead from HTF/MTF bars which may arrive
        # interleaved but with ts_event > current LTF bar ts_event.
        current_ltf_ts = int(self._ltf_bars[-1].ts_event)
        htf_bars = [b for b in self._htf_bars if int(b.ts_event) <= current_ltf_ts]
        mtf_bars = [b for b in self._mtf_bars if int(b.ts_event) <= current_ltf_ts]

        htf_highs = self._bars_to_np(htf_bars, max_bars=200, field="high")
        htf_lows = self._bars_to_np(htf_bars, max_bars=200, field="low")
        htf_closes = self._bars_to_np(htf_bars, max_bars=200, field="close")
        mtf_highs = self._bars_to_np(mtf_bars, max_bars=200, field="high")
        mtf_lows = self._bars_to_np(mtf_bars, max_bars=200, field="low")
        mtf_closes = self._bars_to_np(mtf_bars, max_bars=200, field="close")
        ltf_highs = self._bars_to_np(self._ltf_bars, max_bars=200, field="high")
        ltf_lows = self._bars_to_np(self._ltf_bars, max_bars=200, field="low")
        ltf_closes = self._bars_to_np(self._ltf_bars, max_bars=200, field="close")

        htf_slice = htf_bars[-200:]
        mtf_slice = mtf_bars[-200:]
        ltf_slice = self._ltf_bars[-200:]

        htf_ts = np.fromiter(
            (int(b.ts_event) for b in htf_slice),
            dtype=np.int64,
            count=len(htf_slice),
        ).view("datetime64[ns]")
        mtf_ts = np.fromiter(
            (int(b.ts_event) for b in mtf_slice),
            dtype=np.int64,
            count=len(mtf_slice),
        ).view("datetime64[ns]")
        ltf_ts = np.fromiter(
            (int(b.ts_event) for b in ltf_slice),
            dtype=np.int64,
            count=len(ltf_slice),
        ).view("datetime64[ns]")

        mtf_result = self._mtf_manager.analyze(
            htf_data={
                "highs": htf_highs,
                "lows": htf_lows,
                "closes": htf_closes,
                "timestamps": htf_ts,
            },
            mtf_data={
                "highs": mtf_highs,
                "lows": mtf_lows,
                "closes": mtf_closes,
                "timestamps": mtf_ts,
            },
            ltf_data={
                "highs": ltf_highs,
                "lows": ltf_lows,
                "closes": ltf_closes,
                "timestamps": ltf_ts,
            },
            current_price=self._ltf_bars[-1].close.as_double(),
            session_ok=self._current_session.is_trading_allowed if self._current_session else True,
        )
        return mtf_result.mtf_score, mtf_result.is_aligned

    def _calculate_sl_distance(self, bar: Bar, signal: SignalType) -> float:
        """Calculate stop loss distance based on structure, clamped to limits.

        SL is clamped between MIN_SL_DISTANCE and MAX_SL_DISTANCE to prevent:
        - Too tight SL (premature stops)
        - Too wide SL (excessive single-trade losses - Oracle finding: $2300 losses)

        Formula: clamped_sl = max(MIN_SL, min(raw_sl, MAX_SL))
        Example: raw_sl=80, MIN=15, MAX=50 -> clamped=50
        """
        from ..core.definitions import DEFAULT_SL_DISTANCE, MAX_SL_DISTANCE, MIN_SL_DISTANCE

        raw_sl: float = 0.0

        if not self._structure_analyzer:
            # Fallback to ATR-based SL
            closes = self._bars_to_np(self._ltf_bars, max_bars=20, field="close")
            highs = self._bars_to_np(self._ltf_bars, max_bars=20, field="high")
            lows = self._bars_to_np(self._ltf_bars, max_bars=20, field="low")

            # Temporal safety: avoid np.roll() wraparound (could accidentally reference last bar).
            prev_close = np.empty_like(closes)
            prev_close[0] = closes[0]
            prev_close[1:] = closes[:-1]

            tr = np.maximum(highs - lows, np.abs(highs - prev_close))
            tr = np.maximum(tr, np.abs(lows - prev_close))

            # Use completed bars only. If we don't have enough data, fail closed with DEFAULT_SL_DISTANCE.
            tr_tail = tr[1:]
            atr = float(np.mean(tr_tail)) if tr_tail.size > 0 else 0.0
            if not np.isfinite(atr) or atr <= 0.0:
                atr = 0.0

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
                closes = self._bars_to_np(self._ltf_bars, max_bars=20, field="close")
                highs = self._bars_to_np(self._ltf_bars, max_bars=20, field="high")
                lows = self._bars_to_np(self._ltf_bars, max_bars=20, field="low")

                prev_close = np.empty_like(closes)
                prev_close[0] = closes[0]
                prev_close[1:] = closes[:-1]

                tr = np.maximum(highs - lows, np.abs(highs - prev_close))
                tr = np.maximum(tr, np.abs(lows - prev_close))

                tr_tail = tr[1:]
                atr = float(np.mean(tr_tail)) if tr_tail.size > 0 else 0.0
                if not np.isfinite(atr) or atr <= 0.0:
                    atr = 0.0

                raw_sl = float(atr * 1.5)

        # Clamp SL distance to [MIN_SL_DISTANCE, MAX_SL_DISTANCE]
        # This prevents:
        # - Too tight stops (< MIN_SL_DISTANCE) that get hit by noise
        # - Huge losses (> MAX_SL_DISTANCE) that violate Apex DD limits
        if raw_sl <= 0:
            clamped_sl: float = float(DEFAULT_SL_DISTANCE)
        else:
            clamped_sl = float(max(MIN_SL_DISTANCE, min(raw_sl, MAX_SL_DISTANCE)))

        # R11-FIX: Replace assert with explicit check (assert disabled with -O).
        # This is an APEX-CRITICAL safety invariant that must never be bypassed.
        if not (MIN_SL_DISTANCE <= clamped_sl <= MAX_SL_DISTANCE):
            raise ValueError(
                f"SL clamping failed: {clamped_sl} not in [{MIN_SL_DISTANCE}, {MAX_SL_DISTANCE}]"
            )

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
        tick_size = (
            float(inst.price_increment.as_double()) if inst is not None else float(XAUUSD_POINT)
        )
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
            risk_amount *= getattr(
                self, "_dow_size_mult", 1.0
            )  # FORGE-NAUTILUS Wave 2: Day-of-week adjustment
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
        dow_mult = getattr(
            self, "_dow_size_mult", 1.0
        )  # FORGE-NAUTILUS Wave 2: Day-of-week adjustment
        risk_pct = (
            float(self.config.risk_per_trade) * news_mult * dow_mult * spread_mult * hbs_size_mult
        )
        if self._circuit_breaker:
            risk_pct *= self._circuit_breaker.get_size_multiplier()

        # Use PositionSizer.calculate_lot (instrument-aware: "pip" == tick)
        sl_pips = sl_distance / max(1e-9, tick_size)
        pip_value = tick_size * point_value_per_unit * lot_size

        # FIX RISK-1: Pass current drawdown for throttling
        # The position sizer applies size reduction as drawdown approaches limits
        current_dd_pct = 0.0
        if self._drawdown_tracker:
            # Use trailing (peak-to-valley) drawdown for throttle - this is Apex-critical
            # Convert from percentage (3.5) to decimal (0.035)
            current_dd_pct = self._drawdown_tracker.get_total_drawdown_pct() / 100.0

        position_size = self._position_sizer.calculate_lot(
            balance=self._equity_base,
            risk_percent=risk_pct,
            stop_loss_pips=sl_pips,
            regime_multiplier=regime_mult,
            pip_value=float(pip_value),
            current_drawdown_pct=current_dd_pct,
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

        # FIX EDGE-2: Guard against regressive timestamps (rare but lethal edge case)
        # If feed delivers ts_event going backwards, daily reset and time gates could fail
        ts_ns = int(tick.ts_event)
        if ts_ns < self._last_event_ts_ns:
            self.log.warning(
                f"[TIMESTAMP] Regressive timestamp detected: {ts_ns} < {self._last_event_ts_ns}, "
                f"delta={self._last_event_ts_ns - ts_ns}ns - skipping tick"
            )
            return
        self._last_event_ts_ns = ts_ns

        # Daily reset guard (ET calendar) to re-enable trading after prior cutoff blocks
        self._check_daily_reset(tick.ts_event)

        # Apex time guard on every tick - only if prop firm mode enabled
        if (
            self.config.prop_firm_enabled
            and self._time_manager
            and not self._time_manager.check(tick.ts_event)
        ):
            return

        spread = float(tick.ask_price - tick.bid_price)
        if self.instrument:
            self._current_spread = int(spread / self.instrument.price_increment)
        if self._spread_monitor:
            try:
                now_dt = getattr(self, "_last_tick_dt", None)
                if now_dt is None:
                    now_dt = datetime.fromtimestamp(tick.ts_event / 1e9, tz=timezone.utc)
                snapshot = self._spread_monitor.update(
                    bid=tick.bid_price.as_double(),
                    ask=tick.ask_price.as_double(),
                    now=now_dt,
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
                        tick_time = datetime.fromtimestamp(tick.ts_event / 1e9, tz=timezone.utc)
                        self._telemetry.emit(
                            "spread_state",
                            {
                                "ts": tick_time.isoformat(),
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
                self.log.warning(
                    f"[BLOCKED] spread_monitor_exception:{type(exc).__name__} -> trading halted"
                )

        # Prop-firm + circuit-breaker enforcement runs in BaseStrategy.on_quote_tick.

        # Trade management: optionally rate-limited by management timeframe.
        if self._position and self._trade_manager and self._active_trade_id:
            mgmt_min = int(getattr(self.config, "management_bar_minutes", 0) or 0)
            if mgmt_min <= 0:
                self._process_trade_management(tick)
            else:
                interval_ns = mgmt_min * 60 * 1_000_000_000
                last_ns = int(getattr(self, "_last_mgmt_update_ts_ns", 0) or 0)
                now_ns = int(tick.ts_event)
                if last_ns == 0 or now_ns - last_ns >= interval_ns:
                    self._last_mgmt_update_ts_ns = now_ns
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
                    state_payload = action_data if isinstance(action_data, dict) else {}
                    new_state = state_payload.get("new_state", "UNKNOWN")
                    reason = state_payload.get("reason", "")
                    if not isinstance(action_data, dict):
                        reason = f"non_dict_payload:{type(action_data).__name__}:{action_data}" + (
                            f" | {reason}" if reason else ""
                        )

                    self.log.info(f"[TRADE_MANAGER] State changed to {new_state}: {reason}")
                elif action_type == "current_r":
                    # Informational: current R multiple (for logging/telemetry)
                    pass

        except Exception as exc:
            # Nautilus `Logger.warning` does not accept `exc_info=`; include error inline.
            self.log.warning(
                f"[TRADE_MANAGER] _process_trade_management failed: {type(exc).__name__}: {exc}"
            )

    def _handle_partial_action(self, action_data: dict[str, Any], current_price: float) -> None:
        """
        Handle partial profit taking action from TradeManager.

        Closes a portion of the position to lock in profits.
        """
        if not self._position or self._partial_close_in_progress:
            return

        try:
            # BUG-EXEC-003: `TradeManager.update_price()` returns a Decimal quantity.
            # Keep Decimal for trade-state accounting, but convert to float for Nautilus Quantity helpers.
            raw_qty = action_data.get("quantity", Decimal("0"))
            reason = action_data.get("reason", "partial_tp")

            close_qty_dec = raw_qty if isinstance(raw_qty, Decimal) else Decimal(str(raw_qty))
            if close_qty_dec <= 0:
                return

            # Get current position quantity
            current_qty = float(self._position.quantity.as_double())

            # Ensure we don't try to close more than we have
            close_qty_actual = min(float(close_qty_dec), current_qty * 0.5)  # Max 50%

            if close_qty_actual <= 0:
                return

            self._partial_close_in_progress = True

            # Create quantity for partial close
            close_quantity_obj = self._quantity_from_float(close_qty_actual, rounding="floor")

            if close_quantity_obj is None or close_quantity_obj.as_double() <= 0:
                self._partial_close_in_progress = False
                return

            # Submit partial close order
            exit_side = (
                OrderSide.SELL if self._position.side == PositionSide.LONG else OrderSide.BUY
            )
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
                    closed_quantity=Decimal(str(close_qty_actual)),
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
            # Nautilus Logger does not accept exc_info; include error inline.
            self.log.warning(
                "[TRADE_MANAGER] _handle_partial_action failed: %s: %s",
                type(exc).__name__,
                exc,
            )
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
                            self.log.debug(
                                f"[TRADE_MANAGER] Skipping SL move down: {new_sl} < {trade_info.current_sl}"
                            )
                            return
                    else:
                        # For SHORT, SL should only move DOWN (or stay same)
                        if new_sl > trade_info.current_sl:
                            self.log.debug(
                                f"[TRADE_MANAGER] Skipping SL move up: {new_sl} > {trade_info.current_sl}"
                            )
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
                new_sl, rounding="floor" if self._position.side == PositionSide.LONG else "ceil"
            )

            exit_side = (
                OrderSide.SELL if self._position.side == PositionSide.LONG else OrderSide.BUY
            )
            sl_order = self.order_factory.stop_market(
                instrument_id=self.config.instrument_id,
                order_side=exit_side,
                quantity=self._position.quantity,
                trigger_price=new_sl_price,
                time_in_force=TimeInForce.GTC,
                reduce_only=True,
            )

            # CRITICAL: Reset confirmation BEFORE submit so timeout can detect failures
            # BUG-FIX: If submit_order fails, position would be left without SL protection
            self._bracket_sl_confirmed = False
            self._bracket_sl_client_order_id = str(sl_order.client_order_id)

            try:
                self.submit_order(sl_order)
            except Exception as exc:
                # Nautilus Logger does not accept exc_info; include error inline.
                self.log.error(
                    "[TRADE_MANAGER] CRITICAL: submit_order failed after canceling old SL: %s: %s",
                    type(exc).__name__,
                    exc,
                )
                self._sl_modification_in_progress = False
                self._trigger_execution_failsafe(reason="sl_submit_failed_after_cancel")
                return

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
            # Nautilus Logger does not accept exc_info; include error inline.
            self.log.warning(
                "[TRADE_MANAGER] _handle_sl_adjust_action failed: %s: %s",
                type(exc).__name__,
                exc,
            )
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
            # Nautilus Logger does not accept exc_info; include error inline.
            self.log.warning(
                "[TRADE_MANAGER] _handle_close_action failed: %s: %s",
                type(exc).__name__,
                exc,
            )

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

    def _emit_ml_snapshot(self, *, stage: str, payload: dict[str, object]) -> None:
        """Emit ML dataset snapshot to telemetry (never affects trading logic)."""
        if not self._telemetry:
            return
        if not bool(getattr(self.config, "ml_capture_enabled", False)):
            return

        try:
            record = dict(payload)
            record["stage"] = str(stage)
            self._telemetry.emit("ml_snapshot", record)
        except Exception:
            return

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
                self._telemetry.emit("performance_metrics", metrics.to_dict())

            # Log summary
            self.log.info(
                f"Performance Metrics: Sharpe={metrics.sharpe_ratio:.2f}, "
                f"Sortino={metrics.sortino_ratio:.2f}, Calmar={metrics.calmar_ratio:.2f}, "
                f"SQN={metrics.sqn:.2f}, WinRate={metrics.win_rate:.1f}%, "
                f"ProfitFactor={metrics.profit_factor:.2f}, MaxDD={metrics.max_drawdown_pct:.2f}%"
            )

            return metrics
        except Exception as exc:
            self.log.error(f"Failed to calculate metrics: {type(exc).__name__}: {exc}")
            return None
