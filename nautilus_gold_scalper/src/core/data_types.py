"""
Data types and structures for Nautilus Gold Scalper.
Migrated from MQL5 structs in Definitions.mqh
"""
from dataclasses import dataclass, field
from datetime import datetime

from .definitions import (
    DEFAULT_MAX_DAILY_LOSS,
    DEFAULT_MAX_TOTAL_LOSS,
    DEFAULT_RISK_PER_TRADE,
    AbsorptionType,
    AMDPhase,
    EntryMode,
    FootprintSignal,
    FVGQuality,
    FVGState,
    FVGType,
    ImbalanceType,
    LiquidityQuality,
    LiquidityState,
    LiquidityType,
    MarketRegime,
    OrderBlockQuality,
    OrderBlockState,
    OrderBlockType,
    SessionQuality,
    SignalQuality,
    SignalType,
    StructureType,
    TradingSession,
)


@dataclass
class RegimeAnalysis:
    """Result of market regime analysis."""
    regime: MarketRegime = MarketRegime.REGIME_UNKNOWN

    # Core metrics
    hurst_exponent: float = 0.5
    shannon_entropy: float = 0.0
    variance_ratio: float = 1.0

    # Multi-scale Hurst
    hurst_short: float = 0.5     # 50-bar
    hurst_medium: float = 0.5    # 100-bar
    hurst_long: float = 0.5      # 200-bar
    multiscale_agreement: float = 0.0  # 0-100

    # Transition detection
    transition_probability: float = 0.0
    bars_in_regime: int = 0
    regime_velocity: float = 0.0
    previous_regime: MarketRegime = MarketRegime.REGIME_UNKNOWN
    kalman_trend_velocity: float = 0.0  # Kalman filter trend velocity

    # Outputs
    size_multiplier: float = 1.0
    score_adjustment: int = 0
    confidence: float = 0.0
    recommended_entry_mode: EntryMode = EntryMode.ENTRY_MODE_DISABLED

    calculation_time: datetime | None = None
    is_valid: bool = False
    diagnosis: str = ""


@dataclass
class SessionInfo:
    """Information about current trading session."""
    session: TradingSession = TradingSession.SESSION_UNKNOWN
    quality: SessionQuality = SessionQuality.SESSION_QUALITY_BLOCKED

    is_trading_allowed: bool = False
    hours_until_close: float = 0.0
    volatility_factor: float = 1.0
    spread_factor: float = 1.0

    reason: str = ""


@dataclass
class FootprintBar:
    """Footprint/order flow data for a single bar."""
    timestamp: datetime | None = None

    # Volume profile
    total_volume: int = 0
    delta: int = 0  # ask_volume - bid_volume
    poc_price: float = 0.0  # Point of Control
    vah_price: float = 0.0  # Value Area High
    val_price: float = 0.0  # Value Area Low

    # Imbalances
    imbalance_type: ImbalanceType = ImbalanceType.IMBALANCE_NONE
    stacked_imbalances: int = 0

    # Absorption
    absorption_type: AbsorptionType = AbsorptionType.ABSORPTION_NONE
    absorption_strength: float = 0.0

    # Signal
    signal: FootprintSignal = FootprintSignal.FP_SIGNAL_NONE
    signal_strength: float = 0.0


@dataclass
class StructurePoint:
    """Market structure point (HH, HL, LH, LL, BOS, CHoCH)."""
    timestamp: datetime | None = None
    price: float = 0.0
    structure_type: StructureType = StructureType.STRUCTURE_UNKNOWN

    is_confirmed: bool = False
    strength: float = 0.0
    bar_index: int = 0


@dataclass
class OrderBlock:
    """Detected order block (SMC)."""
    timestamp: datetime | None = None

    high_price: float = 0.0
    low_price: float = 0.0
    refined_entry: float = 0.0  # 50-70% mitigation level

    ob_type: OrderBlockType = OrderBlockType.OB_BULLISH
    state: OrderBlockState = OrderBlockState.OB_STATE_ACTIVE
    quality: OrderBlockQuality = OrderBlockQuality.OB_QUALITY_LOW

    direction: SignalType = SignalType.SIGNAL_NONE
    strength: float = 0.0
    volume_ratio: float = 0.0
    displacement_size: float = 0.0

    is_fresh: bool = True
    is_institutional: bool = False
    is_valid: bool = True
    touch_count: int = 0
    probability_score: float = 0.0

    # Confluence factors
    has_fvg_confluence: bool = False
    has_liquidity_confluence: bool = False
    has_structure_confluence: bool = False
    confluence_score: float = 0.0


@dataclass
class FairValueGap:
    """Detected Fair Value Gap (SMC)."""
    timestamp: datetime | None = None

    upper_level: float = 0.0
    lower_level: float = 0.0
    mid_level: float = 0.0
    optimal_entry: float = 0.0

    fvg_type: FVGType = FVGType.FVG_BULLISH
    state: FVGState = FVGState.FVG_STATE_OPEN
    quality: FVGQuality = FVGQuality.FVG_QUALITY_LOW

    direction: SignalType = SignalType.SIGNAL_NONE
    gap_size_points: float = 0.0
    fill_percentage: float = 0.0
    displacement_size: float = 0.0

    is_fresh: bool = True
    is_institutional: bool = False
    is_valid: bool = True
    has_volume_spike: bool = False

    # Confluence factors
    has_ob_confluence: bool = False
    has_liquidity_confluence: bool = False
    has_structure_confluence: bool = False
    confluence_score: float = 0.0

    # Timing
    age_in_bars: int = 0
    time_decay_factor: float = 1.0
    size_atr_ratio: float = 0.0


@dataclass
class LiquidityPool:
    """Institutional liquidity pool."""
    timestamp: datetime | None = None

    price_level: float = 0.0
    liquidity_type: LiquidityType = LiquidityType.LIQUIDITY_NONE
    state: LiquidityState = LiquidityState.LIQUIDITY_UNTAPPED
    quality: LiquidityQuality = LiquidityQuality.LIQUIDITY_QUALITY_LOW

    volume_estimate: float = 0.0
    sweep_probability: float = 0.0
    sweep_distance: float = 0.0

    is_target: bool = False
    is_fresh: bool = True
    is_institutional: bool = False
    touch_count: int = 0
    reaction_strength: float = 0.0

    # Timeframe significance
    is_weekly_level: bool = False
    is_daily_level: bool = False
    is_session_level: bool = False

    # Confluence
    has_ob_confluence: bool = False
    has_fvg_confluence: bool = False
    has_structure_confluence: bool = False
    confluence_score: float = 0.0


@dataclass
class LiquiditySweep:
    """Detected liquidity sweep."""
    timestamp: datetime | None = None

    swept_level: float = 0.0
    sweep_high: float = 0.0
    sweep_low: float = 0.0

    direction: SignalType = SignalType.SIGNAL_NONE
    strength: float = 0.0
    volume_spike: float = 0.0

    is_confirmed: bool = False
    is_institutional: bool = False


@dataclass
class AMDCycle:
    """AMD (Accumulation-Manipulation-Distribution) cycle state."""
    current_phase: AMDPhase = AMDPhase.AMD_UNKNOWN
    phase_start_time: datetime | None = None
    phase_duration_bars: int = 0

    accumulation_high: float = 0.0
    accumulation_low: float = 0.0
    manipulation_high: float = 0.0
    manipulation_low: float = 0.0

    expected_direction: SignalType = SignalType.SIGNAL_NONE
    confidence: float = 0.0

    is_valid: bool = False

    # compatibility alias
    @property
    def phase(self) -> AMDPhase:
        return self.current_phase


@dataclass
class ConfluenceResult:
    """Result of confluence scoring."""
    # Direction
    direction: SignalType = SignalType.SIGNAL_NONE
    quality: SignalQuality = SignalQuality.QUALITY_INVALID

    # Main score (0-100)
    total_score: float = 0.0

    # Component scores
    structure_score: float = 0.0
    regime_score: float = 0.0
    sweep_score: float = 0.0
    amd_score: float = 0.0
    ob_score: float = 0.0
    fvg_score: float = 0.0
    fib_score: float = 0.0
    premium_discount: float = 0.0
    mtf_score: float = 0.0
    footprint_score: float = 0.0
    footprint_direction: SignalType = SignalType.SIGNAL_NONE
    session_score: float = 0.0

    # Adjustments
    regime_adjustment: int = 0
    confluence_bonus: int = 0

    # Counts
    bullish_factors: int = 0
    bearish_factors: int = 0
    total_confluences: int = 0

    # GENIUS v4.0+ enhancements
    sequence_steps: int = 0  # ICT 7-step sequence completion
    multiplier_adjustments: dict[str, float] = field(default_factory=dict)  # alignment, freshness, divergence

    # Trade setup
    entry_price: float = 0.0
    stop_loss: float = 0.0
    take_profit_1: float = 0.0
    take_profit_2: float = 0.0
    risk_reward: float = 0.0

    # Filters passed
    session_filter_ok: bool = False
    spread_filter_ok: bool = False
    regime_filter_ok: bool = False

    diagnosis: str = ""


@dataclass
class RiskState:
    """Current risk state."""
    # Limits
    risk_per_trade: float = DEFAULT_RISK_PER_TRADE
    max_daily_loss: float = DEFAULT_MAX_DAILY_LOSS
    max_total_loss: float = DEFAULT_MAX_TOTAL_LOSS

    # Account state
    initial_balance: float = 0.0
    current_balance: float = 0.0
    current_equity: float = 0.0
    daily_starting_balance: float = 0.0
    high_water_mark: float = 0.0

    # Current P&L
    current_daily_pnl: float = 0.0
    current_daily_pnl_pct: float = 0.0
    current_total_pnl: float = 0.0
    current_drawdown: float = 0.0
    current_drawdown_pct: float = 0.0

    # Trading status
    trades_today: int = 0
    total_open_risk: float = 0.0

    # Flags
    is_trading_allowed: bool = True
    is_daily_limit_hit: bool = False
    is_total_limit_hit: bool = False
    trading_halted: bool = False

    # Kelly
    kelly_fraction: float = 0.25
    win_rate: float = 0.5
    avg_win: float = 0.0
    avg_loss: float = 0.0


@dataclass
class TradeSignal:
    """Trade signal to be executed."""
    timestamp: datetime | None = None
    symbol: str = "XAUUSD"

    direction: SignalType = SignalType.SIGNAL_NONE
    quality: SignalQuality = SignalQuality.QUALITY_INVALID

    entry_price: float = 0.0
    stop_loss: float = 0.0
    take_profit: float = 0.0

    lot_size: float = 0.0
    risk_amount: float = 0.0
    risk_percent: float = 0.0

    confluence_score: float = 0.0
    regime: MarketRegime = MarketRegime.REGIME_UNKNOWN
    session: TradingSession = TradingSession.SESSION_UNKNOWN

    reason: str = ""
    is_valid: bool = False


@dataclass
class PositionData:
    """Open position tracking data."""
    ticket: int = 0
    symbol: str = "XAUUSD"
    direction: SignalType = SignalType.SIGNAL_NONE

    entry_time: datetime | None = None
    entry_price: float = 0.0

    initial_sl: float = 0.0
    initial_tp: float = 0.0
    current_sl: float = 0.0
    current_tp: float = 0.0

    lot_size: float = 0.0

    # Performance tracking
    highest_price: float = 0.0
    lowest_price: float = 0.0
    peak_profit: float = 0.0
    current_profit: float = 0.0
    peak_r_multiple: float = 0.0
    current_r_multiple: float = 0.0

    # Entry context
    confluence_score_at_entry: float = 0.0
    regime_at_entry: MarketRegime = MarketRegime.REGIME_UNKNOWN

    # Management flags
    has_moved_to_breakeven: bool = False
    has_taken_partial: bool = False
    partial_count: int = 0

    # Exit triggers
    momentum_reversal_detected: bool = False
    structure_break_detected: bool = False
    volume_exhaustion_detected: bool = False


@dataclass
class PerformanceMetrics:
    """Trading performance metrics."""
    total_profit: float = 0.0
    total_trades: int = 0
    winning_trades: int = 0
    losing_trades: int = 0

    win_rate: float = 0.0
    profit_factor: float = 0.0

    max_drawdown: float = 0.0
    max_drawdown_pct: float = 0.0
    current_drawdown: float = 0.0

    sharpe_ratio: float = 0.0
    sortino_ratio: float = 0.0
    calmar_ratio: float = 0.0

    avg_win: float = 0.0
    avg_loss: float = 0.0
    avg_rr: float = 0.0
    expectancy: float = 0.0

    largest_win: float = 0.0
    largest_loss: float = 0.0

    is_prop_firm_compliant: bool = True
