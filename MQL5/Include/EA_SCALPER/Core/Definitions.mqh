//+------------------------------------------------------------------+
//|                                                  Definitions.mqh |
//|                           Autonomous Expert Advisor for XAUUSD Trading |
//|                                      Common Definitions & Structures |
//+------------------------------------------------------------------+
#property copyright "Developed by Autonomous AI Agent - FTMO Elite Trading System"
#property strict

// === ENUMERATIONS ===
enum ENUM_LOT_SIZE_METHOD
{
   LOT_FIXED = 0,           // Fixed lot size
   LOT_PERCENT_RISK = 1,    // Percentage risk-based
   LOT_ADAPTIVE = 2         // Adaptive based on performance
};

enum ENUM_ORDER_BLOCK_TYPE
{
   OB_BULLISH = 0,
   OB_BEARISH = 1,
   OB_BREAKER = 2
};

enum ENUM_ORDER_BLOCK_STATE
{
   OB_STATE_ACTIVE = 0,        // Order block is active
   OB_STATE_TESTED = 1,        // Order block has been tested
   OB_STATE_MITIGATED = 2,     // Order block has been mitigated
   OB_STATE_REFINED = 3,       // Order block has been refined
   OB_STATE_DISABLED = 4       // Order block is disabled
};

enum ENUM_OB_QUALITY
{
   OB_QUALITY_LOW = 0,         // Low quality order block
   OB_QUALITY_MEDIUM = 1,      // Medium quality order block
   OB_QUALITY_HIGH = 2,        // High quality order block
   OB_QUALITY_ELITE = 3        // Elite institutional order block
};

enum ENUM_FVG_TYPE
{
   FVG_BULLISH = 0,
   FVG_BEARISH = 1,
   FVG_BALANCED = 2
};

enum ENUM_FVG_STATE
{
   FVG_STATE_OPEN = 0,         // FVG is open and unfilled
   FVG_STATE_PARTIAL = 1,      // FVG is partially filled
   FVG_STATE_FILLED = 2,       // FVG is completely filled
   FVG_STATE_EXPIRED = 3       // FVG has expired (time-based)
};

enum ENUM_FVG_QUALITY
{
   FVG_QUALITY_LOW = 0,        // Low quality FVG
   FVG_QUALITY_MEDIUM = 1,     // Medium quality FVG
   FVG_QUALITY_HIGH = 2,       // High quality FVG
   FVG_QUALITY_ELITE = 3       // Elite institutional FVG
};

enum ENUM_SIGNAL_TYPE
{
   SIGNAL_NONE = 0,
   SIGNAL_BUY = 1,
   SIGNAL_SELL = 2
};

enum ENUM_LIQUIDITY_TYPE
{
   LIQUIDITY_NONE = 0,         // No liquidity
   LIQUIDITY_BSL = 1,          // Buy Side Liquidity
   LIQUIDITY_SSL = 2,          // Sell Side Liquidity
   LIQUIDITY_EQH = 3,          // Equal Highs
   LIQUIDITY_EQL = 4,          // Equal Lows
   LIQUIDITY_POOLS = 5,        // Liquidity Pools
   LIQUIDITY_WEEKLY = 6,       // Weekly Liquidity
   LIQUIDITY_DAILY = 7,        // Daily Liquidity
   LIQUIDITY_SESSION = 8       // Session Liquidity
};

enum ENUM_LIQUIDITY_STATE
{
   LIQUIDITY_UNTAPPED = 0,     // Liquidity not swept
   LIQUIDITY_SWEPT = 1,        // Liquidity has been swept
   LIQUIDITY_PARTIAL = 2,      // Partially swept
   LIQUIDITY_EXPIRED = 3       // Time-based expiry
};

enum ENUM_LIQUIDITY_QUALITY
{
   LIQUIDITY_QUALITY_LOW = 0,     // Low quality liquidity
   LIQUIDITY_QUALITY_MEDIUM = 1,  // Medium quality liquidity
   LIQUIDITY_QUALITY_HIGH = 2,    // High quality liquidity
   LIQUIDITY_QUALITY_ELITE = 3    // Elite institutional liquidity
};

enum ENUM_SESSION_TYPE_LEGACY
{
   SESSION_TYPE_ASIAN = 0,
   SESSION_TYPE_LONDON = 1,
   SESSION_TYPE_NY = 2,
   SESSION_TYPE_OVERLAP = 3
};

// === STRUCTURE DEFINITIONS ===
struct SAdvancedOrderBlock
{
    datetime            formation_time;         // When order block formed
    double              high_price;             // Order block high
    double              low_price;              // Order block low
    double              refined_entry;          // Optimal entry within OB
    ENUM_ORDER_BLOCK_TYPE type;                // Bullish/Bearish/Breaker
    ENUM_ORDER_BLOCK_STATE state;              // Active/Tested/Mitigated
    ENUM_OB_QUALITY     quality;               // Quality classification
    
    // Advanced Properties
    bool                is_fresh;               // Untested order block
    bool                is_institutional;       // Institutional size
    double              strength;               // OB strength (0-100)
    double              volume_profile;         // Associated volume
    double              displacement_size;      // Size of displacement move
    bool                has_liquidity;          // Contains liquidity pool
    double              reaction_quality;       // Quality of reaction (0-1)
    int                 touch_count;            // Number of times tested
    double              probability_score;      // Success probability (0-100)
    bool                is_premium;             // Premium/Discount zone
    int                 origin_timeframe;       // Timeframe where OB formed (ENUM_TIMEFRAME)
    
    // Confluence Factors
    bool                has_fvg_confluence;     // FVG confluence
    bool                has_liquidity_confluence; // Liquidity confluence
    bool                has_structure_confluence; // Structure confluence
    double              confluence_score;       // Total confluence score
};

struct SEliteFairValueGap
{
    datetime            formation_time;         // When FVG formed
    double              upper_level;            // FVG top boundary
    double              lower_level;            // FVG bottom boundary
    double              mid_level;              // FVG middle (50%)
    double              optimal_entry;          // Calculated optimal entry
    ENUM_FVG_TYPE       type;                  // Bullish/Bearish/Balanced
    ENUM_FVG_STATE      state;                 // Open/Partial/Filled/Expired
    ENUM_FVG_QUALITY    quality;               // Quality classification
    
    // Advanced Properties
    double              fill_percentage;        // How much filled (0-100%)
    double              expected_reaction;      // Price reaction probability
    double              displacement_size;      // Size of creating displacement
    bool                has_volume_spike;       // Volume spike confirmation
    bool                is_institutional;       // Institutional FVG
    double              gap_size_points;        // Gap size in points
    int                 origin_timeframe;       // Origin timeframe (ENUM_TIMEFRAME)
    double              quality_score;          // FVG quality (0-100)
    bool                is_in_premium;          // Premium/Discount location
    int                 confluence_count;       // Number of confluences
    
    // Confluence Factors
    bool                has_ob_confluence;      // Order Block confluence
    bool                has_liquidity_confluence; // Liquidity confluence
    bool                has_structure_confluence; // Structure confluence
    double              confluence_score;       // Total confluence score
    
    // Reaction Analysis
    double              historical_success_rate; // Historical success rate
    int                 touch_count;            // Times price approached
    double              average_reaction_size;  // Average reaction size
    bool                has_strong_reaction;    // Strong reaction expected
    
    // Timing Analysis
    int                 age_in_bars;           // Age in bars
    datetime            expiry_time;           // Expected expiry time
    bool                is_fresh;              // Fresh unfilled FVG
    double              time_decay_factor;     // Time-based decay factor
};

struct SInstitutionalLiquidityPool
{
    datetime            formation_time;         // When liquidity level identified
    double              price_level;            // Exact liquidity level
    ENUM_LIQUIDITY_TYPE type;                  // Type of liquidity
    ENUM_LIQUIDITY_STATE state;               // Current state
    ENUM_LIQUIDITY_QUALITY quality;           // Quality classification
    
    // Volume and Size Analysis
    double              volume_estimate;       // Estimated volume at level
    double              accumulation_size;     // Size of accumulation
    double              institutional_footprint; // Institution size indicator
    bool                has_orders_confluence; // Multiple order levels
    
    // Sweep Analysis
    double              sweep_probability;     // Likelihood of sweep (0-1)
    bool                is_target;            // Primary liquidity target
    double              sweep_distance;       // Distance for valid sweep
    double              protection_level;     // Stop placement level
    
    // Historical Analysis
    int                 touch_count;          // Times price approached
    double              reaction_strength;    // Historical reaction strength
    double              average_reaction_size; // Average reaction from level
    bool                has_strong_reaction;  // Strong reaction expected
    
    // Timeframe Significance
    int                 significance_tf;      // Most significant timeframe (ENUM_TIMEFRAME)
    bool                is_weekly_level;      // Weekly liquidity
    bool                is_daily_level;       // Daily liquidity
    bool                is_session_level;     // Session liquidity
    
    // Confluence Factors
    bool                has_ob_confluence;    // Order Block confluence
    bool                has_fvg_confluence;   // FVG confluence
    bool                has_structure_confluence; // Structure confluence
    double              confluence_score;     // Total confluence score
    
    // Advanced Properties
    double              quality_score;        // Overall quality score
    bool                is_institutional;     // Institutional level
    double              time_decay_factor;    // Time-based decay
    int                 age_in_bars;         // Age in bars
    datetime            expiry_time;         // Expected expiry
    bool                is_fresh;            // Fresh unswept liquidity
};

struct SConfluenceSignal
{
    ENUM_SIGNAL_TYPE    signal_type;
    double              confidence_score;
    double              entry_price;
    double              stop_loss;
    double              take_profit;
    double              risk_reward_ratio;
    
    // Individual scores
    double              orderblock_score;
    double              fvg_score;
    double              liquidity_score;
    double              structure_score;
    double              priceaction_score;
    double              timeframe_score;
    
    // Filters
    bool                session_filter_ok;
    bool                news_filter_ok;
    bool                spread_filter_ok;
    bool                time_filter_ok;
};

struct SPerformanceMetrics
{
    double              total_profit;
    double              total_trades;
    double              win_rate;
    double              profit_factor;
    double              max_drawdown;
    double              sharpe_ratio;
    double              current_drawdown;
    bool                ftmo_compliant;
};

// === POSITION DATA STRUCTURE ===
struct SAutonomousPositionData
{
    ulong               ticket;
    datetime            entry_time;
    double              entry_price;
    double              initial_sl;
    double              initial_tp;
    double              current_sl;
    double              current_tp;
    ENUM_POSITION_TYPE  position_type;
    
    // Performance metrics
    double              highest_price;          // Highest price reached (for buy)
    double              lowest_price;           // Lowest price reached (for sell)
    double              peak_profit;            // Max profit reached
    double              current_profit;         // Current profit
    double              peak_r_multiple;        // Max R-multiple reached
    double              current_r_multiple;     // Current R-multiple
    
    // AI factors
    double              confluence_score_at_entry;
    double              market_sentiment_score;
    
    // Management flags
    bool                has_moved_to_breakeven;
    bool                has_taken_partial_profit;
    int                 partial_profit_count;
    
    // Exit triggers
    bool                momentum_reversal_detected;
    bool                structure_break_detected;
    bool                volume_exhaustion_detected;
    bool                time_based_exit_triggered;
    
    datetime            last_update_time;
};

// === FTMO COMPLIANCE STRUCTURE ===
struct SFTMOCompliance
{
    // Account Status
    double              initial_balance;        // Account balance at start
    double              current_balance;        // Current balance
    double              current_equity;         // Current equity
    double              daily_starting_balance; // Balance at start of day
    
    // Drawdown Tracking
    double              daily_loss_current;     // Current daily loss %
    double              max_drawdown_current;   // Current max drawdown %
    double              account_high_water_mark; // Highest balance achieved
    
    // Limits (from inputs)
    double              daily_loss_limit;       // Max daily loss %
    double              max_drawdown_limit;     // Max total drawdown %
    int                 max_trades_per_day;     // Max trades allowed
    double              max_risk_per_trade;     // Max risk per trade %
    
    // Trading Status
    int                 trades_today_count;     // Number of trades today
    bool                daily_limit_breached;   // Daily limit flag
    bool                max_drawdown_breached;  // Max drawdown flag
    bool                trading_halted;         // Master switch
    bool                is_compliant;           // Overall compliance status
    
    // Risk Metrics
    double              total_open_risk;        // Total risk in open positions
    double              largest_loss_trade;     // Largest single loss
    datetime            last_check_time;        // Last check timestamp
    datetime            daily_reset_time;       // When daily stats reset
    
    // Violation Tracking
    int                 violation_count;        // Number of violations
    string              last_violation_reason;  // Last violation reason
    datetime            last_violation_time;    // Last violation time
    
    // Conservative factors
    double              safety_buffer;          // Safety buffer (default 20%)
    bool                weekend_gap_protection; // Weekend gap protection
    bool                news_trading_halt;      // News-based trading halt
};
