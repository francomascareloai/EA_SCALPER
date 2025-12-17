"""
Core definitions for the Gold Scalper - NautilusTrader Edition.

Migrated from: MQL5/Include/EA_SCALPER/Core/Definitions.mqh
"""
from enum import IntEnum


class Direction(IntEnum):
    """Trade direction."""
    NONE = 0
    LONG = 1
    SHORT = -1


class SignalType(IntEnum):
    """Signal types for trading."""
    SIGNAL_NONE = 0
    SIGNAL_BUY = 1
    SIGNAL_SELL = -1

    # Aliases for backward compatibility
    NONE = 0
    BUY = 1
    SELL = -1


class SignalQuality(IntEnum):
    """Quality classification for trade signals."""
    QUALITY_INVALID = 0
    QUALITY_LOW = 1
    QUALITY_MEDIUM = 2
    QUALITY_HIGH = 3
    QUALITY_ELITE = 4

    # Backward-compatible tier aliases used by strategy/scorer code.
    TIER_INVALID = QUALITY_INVALID
    TIER_C = QUALITY_LOW
    TIER_B = QUALITY_MEDIUM
    TIER_A = QUALITY_HIGH
    TIER_S = QUALITY_ELITE


class TradeState(IntEnum):
    """Current state of a trade."""
    NONE = 0
    PENDING = 1
    OPEN = 2
    PARTIAL_CLOSE = 3
    CLOSED = 4
    CANCELLED = 5
    BREAKEVEN = 6
    TRAILING = 7


class TradingSession(IntEnum):
    """Trading session types for XAUUSD."""
    SESSION_UNKNOWN = 0
    SESSION_ASIAN = 1              # 00:00-07:00 GMT - Low volatility, range-bound
    SESSION_LONDON = 2             # 07:00-12:00 GMT - High volatility, trend initiation
    SESSION_LONDON_NY_OVERLAP = 3  # 12:00-15:00 GMT - HIGHEST volatility, PRIME window
    SESSION_NY = 4                 # 15:00-17:00 GMT - High volatility, continuation/reversal
    SESSION_LATE_NY = 5            # 17:00-21:00 GMT - Low liquidity, erratic
    SESSION_WEEKEND = 6            # Market closed


class SessionQuality(IntEnum):
    """Quality rating for trading sessions."""
    SESSION_QUALITY_BLOCKED = 0    # No trading allowed
    SESSION_QUALITY_LOW = 1        # Poor trading conditions
    SESSION_QUALITY_MEDIUM = 2     # Average trading conditions
    SESSION_QUALITY_HIGH = 3       # Good trading conditions
    SESSION_QUALITY_PRIME = 4      # Optimal trading conditions


class MarketRegime(IntEnum):
    """Market regime classification based on Hurst and Shannon entropy."""
    REGIME_PRIME_TRENDING = 0       # H > 0.55, S < 1.5 - Strong trend
    REGIME_NOISY_TRENDING = 1       # H > 0.55, S >= 1.5 - Trend with noise
    REGIME_PRIME_REVERTING = 2      # H < 0.45, S < 1.5 - Mean reverting
    REGIME_NOISY_REVERTING = 3      # H < 0.45, S >= 1.5 - Noisy mean reversion
    REGIME_RANDOM_WALK = 4          # NOT TRADEABLE
    REGIME_TRANSITIONING = 5        # Between regimes
    REGIME_UNKNOWN = 6              # Unable to classify


class OrderBlockType(IntEnum):
    """Order block types (Smart Money Concepts)."""
    OB_BULLISH = 0
    OB_BEARISH = 1
    OB_BREAKER = 2


class OrderBlockState(IntEnum):
    """Order block state."""
    OB_STATE_ACTIVE = 0
    OB_STATE_TESTED = 1
    OB_STATE_MITIGATED = 2
    OB_STATE_REFINED = 3
    OB_STATE_DISABLED = 4


class OrderBlockQuality(IntEnum):
    """Order block quality classification."""
    OB_QUALITY_LOW = 0
    OB_QUALITY_MEDIUM = 1
    OB_QUALITY_HIGH = 2
    OB_QUALITY_ELITE = 3


class FVGType(IntEnum):
    """Fair Value Gap types."""
    FVG_BULLISH = 0
    FVG_BEARISH = 1
    FVG_BALANCED = 2


class FVGState(IntEnum):
    """Fair Value Gap state."""
    FVG_STATE_OPEN = 0
    FVG_STATE_PARTIAL = 1
    FVG_STATE_FILLED = 2
    FVG_STATE_EXPIRED = 3


class FVGQuality(IntEnum):
    """Fair Value Gap quality classification."""
    FVG_QUALITY_LOW = 0
    FVG_QUALITY_MEDIUM = 1
    FVG_QUALITY_HIGH = 2
    FVG_QUALITY_ELITE = 3


class LiquidityType(IntEnum):
    """Institutional liquidity types."""
    LIQUIDITY_NONE = 0
    LIQUIDITY_BSL = 1          # Buy Side Liquidity
    LIQUIDITY_SSL = 2          # Sell Side Liquidity
    LIQUIDITY_EQH = 3          # Equal Highs
    LIQUIDITY_EQL = 4          # Equal Lows
    LIQUIDITY_POOLS = 5
    LIQUIDITY_WEEKLY = 6
    LIQUIDITY_DAILY = 7
    LIQUIDITY_SESSION = 8


class LiquidityState(IntEnum):
    """Liquidity state."""
    LIQUIDITY_UNTAPPED = 0
    LIQUIDITY_SWEPT = 1
    LIQUIDITY_PARTIAL = 2
    LIQUIDITY_EXPIRED = 3


class LiquidityQuality(IntEnum):
    """Liquidity quality classification."""
    LIQUIDITY_QUALITY_LOW = 0
    LIQUIDITY_QUALITY_MEDIUM = 1
    LIQUIDITY_QUALITY_HIGH = 2
    LIQUIDITY_QUALITY_ELITE = 3


class ImbalanceType(IntEnum):
    """Order flow imbalance types."""
    IMBALANCE_NONE = 0
    IMBALANCE_BULLISH = 1
    IMBALANCE_BEARISH = 2
    IMBALANCE_STACKED_BULL = 3  # Multiple stacked bullish imbalances
    IMBALANCE_STACKED_BEAR = 4  # Multiple stacked bearish imbalances
    # Aliases expected in tests
    IMBALANCE_BUY = IMBALANCE_BULLISH
    IMBALANCE_SELL = IMBALANCE_BEARISH


class AbsorptionType(IntEnum):
    """Volume absorption patterns."""
    ABSORPTION_NONE = 0
    ABSORPTION_BULLISH = 1      # Large bid absorption
    ABSORPTION_BEARISH = 2      # Large ask absorption
    ABSORPTION_EXHAUSTION = 3   # Volume exhaustion
    # Aliases for compatibility
    ABSORPTION_BUY = ABSORPTION_BULLISH
    ABSORPTION_SELL = ABSORPTION_BEARISH


class FootprintSignal(IntEnum):
    """Footprint/order flow signals."""
    FP_SIGNAL_NONE = 0
    FP_SIGNAL_BUY = 1
    FP_SIGNAL_SELL = 2
    FP_SIGNAL_REVERSAL_UP = 3
    FP_SIGNAL_REVERSAL_DOWN = 4
    FP_SIGNAL_STRONG_BUY = 5
    FP_SIGNAL_STRONG_SELL = 6
    FP_SIGNAL_WEAK_BUY = 7
    FP_SIGNAL_WEAK_SELL = 8
    FP_SIGNAL_NEUTRAL = 9


class StructureType(IntEnum):
    """Market structure types."""
    STRUCTURE_UNKNOWN = 0
    STRUCTURE_HH = 1            # Higher High
    STRUCTURE_HL = 2            # Higher Low
    STRUCTURE_LH = 3            # Lower High
    STRUCTURE_LL = 4            # Lower Low
    STRUCTURE_BOS = 5           # Break of Structure
    STRUCTURE_CHOCH = 6         # Change of Character


class AMDPhase(IntEnum):
    """AMD (Accumulation-Manipulation-Distribution) cycle phases."""
    AMD_UNKNOWN = 0
    AMD_ACCUMULATION = 1        # Smart money accumulating
    AMD_MANIPULATION = 2        # Liquidity sweep/fake-out
    AMD_DISTRIBUTION = 3        # Smart money distributing
    AMD_REACCUMULATION = 4      # Re-accumulation phase


class EntryMode(IntEnum):
    """Entry modes adapted to market regime."""
    ENTRY_MODE_BREAKOUT = 0     # Trending regime
    ENTRY_MODE_PULLBACK = 1     # Noisy trending
    ENTRY_MODE_MEAN_REVERT = 2  # Reverting regime
    ENTRY_MODE_CONFIRMATION = 3 # Transitioning
    ENTRY_MODE_DISABLED = 4     # Random/Unknown - NO TRADING


# === CONSTANTS ===

# Risk Management Defaults
DEFAULT_RISK_PER_TRADE = 0.01   # 1% per trade
DEFAULT_MAX_DAILY_LOSS = 0.05   # 5% daily loss limit (FTMO)
DEFAULT_MAX_TOTAL_LOSS = 0.10   # 10% total loss limit (FTMO)
DEFAULT_SOFT_STOP = 0.04        # 4% soft stop (warning before hard limit)
MAX_TRADES_PER_DAY = 15         # Maximum trades per day
MAX_RISK_PER_TRADE = 0.01       # Hard cap per trade (FTMO-friendly)

# Signal Quality Tiers (0-100 score thresholds)
TIER_S_MIN = 90                 # Elite setup, full position
TIER_A_MIN = 80                 # High quality, standard position
TIER_B_MIN = 70                 # Tradeable, reduced position
TIER_C_MIN = 60                 # Marginal, minimal position
TIER_INVALID = 60               # Below this = no trade

# Confluence Scoring Weights
WEIGHT_STRUCTURE = 15           # BOS/CHoCH/Bias weight
WEIGHT_REGIME = 10              # Regime detector weight
WEIGHT_LIQUIDITY_SWEEP = 12     # Liquidity sweep weight
WEIGHT_AMD_CYCLE = 10           # AMD cycle weight
WEIGHT_ORDER_BLOCK = 15         # Order block weight
WEIGHT_FVG = 10                 # Fair value gap weight
WEIGHT_FIB = 10                 # Fibonacci confluence weight
WEIGHT_PREMIUM_DISCOUNT = 10    # Premium/discount zone weight
WEIGHT_MTF = 15                 # Multi-timeframe alignment weight
WEIGHT_FOOTPRINT = 10           # Order flow weight

# Confluence Bonuses/Penalties
BONUS_HIGH_CONFLUENCE = 10      # Bonus for high confluence
PENALTY_RANDOM_WALK = -50       # Penalty for random walk regime

# XAUUSD Constants
XAUUSD_POINT = 0.01             # Point size for XAUUSD
XAUUSD_TICK_SIZE = 0.01         # Tick size for XAUUSD
XAUUSD_LOT_SIZE = 100.0         # Standard lot size (100 oz)
XAUUSD_MIN_LOT = 0.01           # Minimum lot size
XAUUSD_MAX_LOT = 100.0          # Maximum lot size
XAUUSD_LOT_STEP = 0.01          # Lot size step
XAUUSD_TICK_VALUE = 1.0         # Tick value in USD

# Position Sizing Constants
DEFAULT_KELLY_FRACTION = 0.25   # Default Kelly fraction
MIN_KELLY_FRACTION = 0.1        # Minimum Kelly fraction
MAX_KELLY_FRACTION = 0.5        # Maximum Kelly fraction
DEFAULT_ATR_MULTIPLIER = 1.5    # Default ATR multiplier for SL
