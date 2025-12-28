//+------------------------------------------------------------------+
//|                                           CAdaptiveRouter.mqh    |
//|                    EA_SCALPER_XAUUSD - Adaptive Strategy Router  |
//|                                  v1.0 - Rule-Based Routing       |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Strategy Types                                                    |
//+------------------------------------------------------------------+
enum ENUM_STRATEGY_TYPE
{
   STRATEGY_SMC,            // Order blocks, FVG, sweeps (ICT/SMC)
   STRATEGY_TREND_FOLLOW,   // EMA pullback, Donchian breakout
   STRATEGY_MEAN_REVERT,    // Bollinger band reversal, RSI extremes
   STRATEGY_SAFE_MODE,      // Ultra conservative / minimal trading
   STRATEGY_NONE            // No valid strategy - don't trade
};

//+------------------------------------------------------------------+
//| Session Types (for routing adjustments)                           |
//| NOTE: Prefixed with ROUTER_ to avoid conflict with CSessionFilter |
//+------------------------------------------------------------------+
enum ENUM_ROUTER_SESSION
{
   ROUTER_SESSION_ASIAN,
   ROUTER_SESSION_LONDON,
   ROUTER_SESSION_NY_OVERLAP,      // London + NY overlap (best liquidity)
   ROUTER_SESSION_NY_AFTERNOON,
   ROUTER_SESSION_OFF_HOURS
};

//+------------------------------------------------------------------+
//| Router Decision Result                                            |
//+------------------------------------------------------------------+
struct SRouterDecision
{
   ENUM_STRATEGY_TYPE primary_strategy;
   ENUM_STRATEGY_TYPE fallback_strategy;
   double             confidence;         // 0-100
   double             size_multiplier;    // 0.0 - 1.0
   string             reason;
   bool               allow_trade;

   void Reset()
   {
      primary_strategy = STRATEGY_NONE;
      fallback_strategy = STRATEGY_NONE;
      confidence = 0;
      size_multiplier = 0;
      reason = "";
      allow_trade = false;
   }
};

//+------------------------------------------------------------------+
//| CAdaptiveRouter Class                                             |
//+------------------------------------------------------------------+
class CAdaptiveRouter
{
private:
   bool              m_initialized;

   // Routing rule parameters
   double            m_hurst_trend_threshold;    // Above this = trending
   double            m_hurst_revert_threshold;   // Below this = mean reverting
   double            m_min_confidence;           // Minimum to allow trade

   // Session adjustments
   double            m_session_conf_ny_overlap;
   double            m_session_conf_london;
   double            m_session_conf_asian;

   // Volatility adjustments
   double            m_vol_low_threshold;        // Below = low vol
   double            m_vol_high_threshold;       // Above = high vol

   // Internal methods
   double            GetSessionAdjustment(ENUM_ROUTER_SESSION session);
   double            GetVolatilityAdjustment(double vol_percentile);

public:
                     CAdaptiveRouter();
                    ~CAdaptiveRouter();

   bool              Init();
   void              Deinit();

   // Main routing decision
   SRouterDecision   SelectStrategy(
                        ENUM_MARKET_REGIME regime,
                        ENUM_ROUTER_SESSION session,
                        double volatility_percentile
                     );

   // Route by individual factors
   ENUM_STRATEGY_TYPE RouteByRegime(ENUM_MARKET_REGIME regime);
   double             GetRegimeConfidence(ENUM_MARKET_REGIME regime);
   double             GetRegimeSizeMultiplier(ENUM_MARKET_REGIME regime);

   // Configuration
   void              SetHurstThresholds(double trend, double revert)
                     {
                        m_hurst_trend_threshold = trend;
                        m_hurst_revert_threshold = revert;
                     }
   void              SetMinConfidence(double conf) { m_min_confidence = conf; }

   // Debug
   string            StrategyToString(ENUM_STRATEGY_TYPE strategy);
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CAdaptiveRouter::CAdaptiveRouter()
{
   m_initialized = false;

   // Default thresholds (aligned with Python)
   m_hurst_trend_threshold = 0.55;
   m_hurst_revert_threshold = 0.45;
   m_min_confidence = 40.0;

   // Session confidence adjustments
   m_session_conf_ny_overlap = 20.0;   // +20% confidence
   m_session_conf_london = 10.0;       // +10% confidence
   m_session_conf_asian = -20.0;       // -20% confidence

   // Volatility thresholds
   m_vol_low_threshold = 25.0;         // Below 25th percentile = low vol
   m_vol_high_threshold = 75.0;        // Above 75th percentile = high vol
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CAdaptiveRouter::~CAdaptiveRouter()
{
   Deinit();
}

//+------------------------------------------------------------------+
//| Initialize                                                        |
//+------------------------------------------------------------------+
bool CAdaptiveRouter::Init()
{
   m_initialized = true;
   Print("[AdaptiveRouter] Initialized - Rule-based strategy routing");
   return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                      |
//+------------------------------------------------------------------+
void CAdaptiveRouter::Deinit()
{
   m_initialized = false;
}

//+------------------------------------------------------------------+
//| Main Strategy Selection                                           |
//+------------------------------------------------------------------+
SRouterDecision CAdaptiveRouter::SelectStrategy(
   ENUM_MARKET_REGIME regime,
   ENUM_ROUTER_SESSION session,
   double volatility_percentile)
{
   SRouterDecision decision;
   decision.Reset();

   if(!m_initialized)
   {
      decision.reason = "Router not initialized";
      return decision;
   }

   // 1. Route by regime (primary factor)
   decision.primary_strategy = RouteByRegime(regime);
   decision.confidence = GetRegimeConfidence(regime);
   decision.size_multiplier = GetRegimeSizeMultiplier(regime);

   // 2. Apply session adjustment
   double session_adj = GetSessionAdjustment(session);
   decision.confidence += session_adj;

   // 3. Apply volatility adjustment
   double vol_adj = GetVolatilityAdjustment(volatility_percentile);
   decision.confidence += vol_adj;

   // 4. Clamp confidence
   decision.confidence = MathMax(0, MathMin(100, decision.confidence));

   // 5. Determine if we should trade
   decision.allow_trade = (decision.confidence >= m_min_confidence &&
                          decision.primary_strategy != STRATEGY_NONE &&
                          decision.primary_strategy != STRATEGY_SAFE_MODE);

   // 6. Set fallback strategy
   switch(decision.primary_strategy)
   {
      case STRATEGY_TREND_FOLLOW:
         decision.fallback_strategy = STRATEGY_SMC;
         break;
      case STRATEGY_SMC:
         decision.fallback_strategy = STRATEGY_TREND_FOLLOW;
         break;
      case STRATEGY_MEAN_REVERT:
         decision.fallback_strategy = STRATEGY_SMC;
         break;
      default:
         decision.fallback_strategy = STRATEGY_NONE;
   }

   // 7. Build reason string
   decision.reason = StringFormat("%s | Regime=%s Session=%s Vol=%.0f%% | Conf=%.0f%% Size=%.0fx",
      StrategyToString(decision.primary_strategy),
      EnumToString(regime),
      EnumToString(session),
      volatility_percentile,
      decision.confidence,
      decision.size_multiplier);

   return decision;
}

//+------------------------------------------------------------------+
//| Route by Regime (Core Logic)                                      |
//+------------------------------------------------------------------+
ENUM_STRATEGY_TYPE CAdaptiveRouter::RouteByRegime(ENUM_MARKET_REGIME regime)
{
   switch(regime)
   {
      case REGIME_PRIME_TRENDING:
         return STRATEGY_TREND_FOLLOW;  // Best for pure trends

      case REGIME_NOISY_TRENDING:
         return STRATEGY_SMC;           // SMC works in noisy trends

      case REGIME_PRIME_REVERTING:
         return STRATEGY_MEAN_REVERT;   // Best for mean reversion

      case REGIME_NOISY_REVERTING:
         return STRATEGY_SMC;           // SMC for noisy reversions

      case REGIME_RANDOM_WALK:
         return STRATEGY_SAFE_MODE;     // Don't trade random walk

      case REGIME_TRANSITIONING:
         return STRATEGY_SAFE_MODE;     // Wait for clarity

      case REGIME_UNKNOWN:
      default:
         return STRATEGY_NONE;
   }
}

//+------------------------------------------------------------------+
//| Get Confidence by Regime                                          |
//+------------------------------------------------------------------+
double CAdaptiveRouter::GetRegimeConfidence(ENUM_MARKET_REGIME regime)
{
   switch(regime)
   {
      case REGIME_PRIME_TRENDING:    return 85.0;
      case REGIME_NOISY_TRENDING:    return 60.0;
      case REGIME_PRIME_REVERTING:   return 75.0;
      case REGIME_NOISY_REVERTING:   return 50.0;
      case REGIME_RANDOM_WALK:       return 20.0;
      case REGIME_TRANSITIONING:     return 30.0;
      case REGIME_UNKNOWN:
      default:                       return 0.0;
   }
}

//+------------------------------------------------------------------+
//| Get Size Multiplier by Regime                                     |
//+------------------------------------------------------------------+
double CAdaptiveRouter::GetRegimeSizeMultiplier(ENUM_MARKET_REGIME regime)
{
   switch(regime)
   {
      case REGIME_PRIME_TRENDING:    return 1.0;
      case REGIME_NOISY_TRENDING:    return 0.7;
      case REGIME_PRIME_REVERTING:   return 0.8;
      case REGIME_NOISY_REVERTING:   return 0.5;
      case REGIME_RANDOM_WALK:       return 0.0;
      case REGIME_TRANSITIONING:     return 0.25;
      case REGIME_UNKNOWN:
      default:                       return 0.0;
   }
}

//+------------------------------------------------------------------+
//| Get Session Adjustment                                            |
//+------------------------------------------------------------------+
double CAdaptiveRouter::GetSessionAdjustment(ENUM_ROUTER_SESSION session)
{
   switch(session)
   {
      case ROUTER_SESSION_NY_OVERLAP:   return m_session_conf_ny_overlap;  // +20
      case ROUTER_SESSION_LONDON:       return m_session_conf_london;      // +10
      case ROUTER_SESSION_NY_AFTERNOON: return 0.0;
      case ROUTER_SESSION_ASIAN:        return m_session_conf_asian;       // -20
      case ROUTER_SESSION_OFF_HOURS:    return -30.0;
      default:                          return 0.0;
   }
}

//+------------------------------------------------------------------+
//| Get Volatility Adjustment                                         |
//+------------------------------------------------------------------+
double CAdaptiveRouter::GetVolatilityAdjustment(double vol_percentile)
{
   // Optimal volatility is in the middle (25-75 percentile)
   // Too low = no movement, too high = choppy

   if(vol_percentile < m_vol_low_threshold)
   {
      // Low volatility - reduce confidence
      return -15.0;
   }
   else if(vol_percentile > m_vol_high_threshold)
   {
      // High volatility - slightly reduce (choppy)
      return -10.0;
   }
   else if(vol_percentile >= 40 && vol_percentile <= 60)
   {
      // Optimal volatility band
      return 10.0;
   }

   return 0.0;
}

//+------------------------------------------------------------------+
//| Strategy to String                                                |
//+------------------------------------------------------------------+
string CAdaptiveRouter::StrategyToString(ENUM_STRATEGY_TYPE strategy)
{
   switch(strategy)
   {
      case STRATEGY_SMC:          return "SMC";
      case STRATEGY_TREND_FOLLOW: return "TREND_FOLLOW";
      case STRATEGY_MEAN_REVERT:  return "MEAN_REVERT";
      case STRATEGY_SAFE_MODE:    return "SAFE_MODE";
      case STRATEGY_NONE:         return "NONE";
      default:                    return "UNKNOWN";
   }
}

//+------------------------------------------------------------------+
