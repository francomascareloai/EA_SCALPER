//+------------------------------------------------------------------+
//|                                            CStrategySelector.mqh |
//|                                                           Franco |
//|                   EA_SCALPER_XAUUSD v4.0 - Strategy Selector      |
//+------------------------------------------------------------------+
#property copyright "Franco"
#property link      "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property strict

#include "..\Safety\SafetyIndex.mqh"
#include "..\Context\CNewsWindowDetector.mqh"
#include "..\Context\CHolidayDetector.mqh"

//+------------------------------------------------------------------+
//| Available Strategies                                              |
//+------------------------------------------------------------------+
enum ENUM_STRATEGY_TYPE
{
   STRATEGY_NONE = 0,           // No trading
   STRATEGY_NEWS_TRADER = 1,    // News event trading
   STRATEGY_TREND_FOLLOW = 2,   // Trending market (Hurst > 0.55)
   STRATEGY_MEAN_REVERT = 3,    // Mean-reverting (Hurst < 0.45)
   STRATEGY_SMC_SCALPER = 4,    // Default SMC scalping
   STRATEGY_SAFE_MODE = 5       // Reduced risk mode
};

//+------------------------------------------------------------------+
//| Market Context                                                    |
//+------------------------------------------------------------------+
struct SMarketContext
{
   // Regime
   double            hurst;
   double            entropy;
   bool              is_trending;
   bool              is_reverting;
   bool              is_random;
   
   // News
   bool              in_news_window;
   bool              news_imminent;  // < 5 min
   int               minutes_to_news;
   ENUM_NEWS_IMPACT  news_impact;
   
   // Session
   bool              is_london;
   bool              is_newyork;
   bool              is_overlap;     // Best time
   bool              is_asian;
   bool              is_weekend;
   
   // Holiday
   bool              is_holiday;
   bool              reduced_liquidity;
   
   // Safety
   bool              circuit_ok;
   bool              spread_ok;
   double            spread_ratio;
   
   // FTMO
   double            daily_dd_percent;
   double            total_dd_percent;
   bool              near_dd_limit;  // > 3%
   
   // Technical
   double            atr;
   double            volatility_percentile;
   bool              high_volatility;
   
   void Reset()
   {
      hurst = 0.5;
      entropy = 2.0;
      is_trending = false;
      is_reverting = false;
      is_random = true;
      
      in_news_window = false;
      news_imminent = false;
      minutes_to_news = 999;
      news_impact = IMPACT_LOW;
      
      is_london = false;
      is_newyork = false;
      is_overlap = false;
      is_asian = false;
      is_weekend = false;
      
      is_holiday = false;
      reduced_liquidity = false;
      
      circuit_ok = true;
      spread_ok = true;
      spread_ratio = 1.0;
      
      daily_dd_percent = 0;
      total_dd_percent = 0;
      near_dd_limit = false;
      
      atr = 0;
      volatility_percentile = 50;
      high_volatility = false;
   }
};

//+------------------------------------------------------------------+
//| Strategy Selection Result                                         |
//+------------------------------------------------------------------+
struct SStrategySelection
{
   ENUM_STRATEGY_TYPE strategy;
   double             size_multiplier;  // 0.0 - 1.0
   int                score_adjustment; // Bonus/penalty
   string             reason;
   bool               can_trade;
   
   // Confidence levels
   double             regime_confidence;
   double             timing_confidence;
   double             overall_confidence;
   
   void Reset()
   {
      strategy = STRATEGY_NONE;
      size_multiplier = 0;
      score_adjustment = 0;
      reason = "Not analyzed";
      can_trade = false;
      regime_confidence = 0;
      timing_confidence = 0;
      overall_confidence = 0;
   }
};

//+------------------------------------------------------------------+
//| Class: CStrategySelector                                          |
//| Purpose: Select optimal strategy based on market context          |
//|                                                                   |
//| Decision Hierarchy:                                               |
//| 1. SAFETY FIRST - Circuit breaker, spread, FTMO                   |
//| 2. NEWS CHECK - If in window, use NewsTrader                      |
//| 3. REGIME CHECK - Trend/Revert/Random                             |
//| 4. SESSION CHECK - London/NY best, avoid Asia                     |
//| 5. SELECT STRATEGY - Based on all factors                         |
//+------------------------------------------------------------------+
class CStrategySelector
{
private:
   //--- Configuration
   string            m_symbol;
   bool              m_ftmo_safe_mode;    // Extra conservative
   bool              m_allow_news_trading;
   bool              m_allow_asian_session;
   
   //--- Thresholds
   double            m_hurst_trend;       // > this = trending
   double            m_hurst_revert;      // < this = reverting
   double            m_entropy_low;       // < this = low noise
   double            m_entropy_high;      // > this = high noise
   
   //--- Components
   CSafetyManager*   m_safety;
   CNewsWindowDetector* m_news_detector;
   CHolidayDetector* m_holiday_detector;
   
   //--- State
   SMarketContext    m_context;
   SStrategySelection m_selection;
   datetime          m_last_update;
   
   //--- Regime (from Python or local)
   double            m_current_hurst;
   double            m_current_entropy;
   
public:
                     CStrategySelector();
                    ~CStrategySelector();
   
   //--- Initialization
   bool              Init(string symbol = "");
   void              SetSafetyManager(CSafetyManager* safety) { m_safety = safety; }
   void              SetNewsDetector(CNewsWindowDetector* detector) { m_news_detector = detector; }
   void              SetHolidayDetector(CHolidayDetector* detector) { m_holiday_detector = detector; }
   
   //--- Configuration
   void              SetFTMOSafeMode(bool enable) { m_ftmo_safe_mode = enable; }
   void              SetAllowNewsTrading(bool allow) { m_allow_news_trading = allow; }
   void              SetAllowAsianSession(bool allow) { m_allow_asian_session = allow; }
   void              SetHurstThresholds(double trend, double revert);
   void              SetEntropyThresholds(double low, double high);
   
   //--- Main selection
   SStrategySelection SelectStrategy();
   SStrategySelection SelectStrategy(const SMarketContext &context);
   
   //--- Context update
   void              UpdateContext();
   void              SetRegime(double hurst, double entropy);
   SMarketContext    GetContext() { return m_context; }
   
   //--- Status
   ENUM_STRATEGY_TYPE GetCurrentStrategy() { return m_selection.strategy; }
   bool              CanTrade() { return m_selection.can_trade; }
   double            GetSizeMultiplier() { return m_selection.size_multiplier; }
   string            GetStrategyName(ENUM_STRATEGY_TYPE strategy);
   void              PrintSelection();
   
private:
   void              UpdateSessionInfo();
   void              UpdateRegimeInfo();
   void              UpdateSafetyInfo();
   void              UpdateNewsInfo();
   void              UpdateHolidayInfo();
   
   SStrategySelection EvaluateStrategies();
   double            CalculateConfidence();
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CStrategySelector::CStrategySelector()
{
   m_symbol = "";
   m_ftmo_safe_mode = false;
   m_allow_news_trading = true;
   m_allow_asian_session = false;
   
   m_hurst_trend = 0.55;
   m_hurst_revert = 0.45;
   m_entropy_low = 1.5;
   m_entropy_high = 2.5;
   
   m_safety = NULL;
   m_news_detector = NULL;
   m_holiday_detector = NULL;
   
   m_current_hurst = 0.5;
   m_current_entropy = 2.0;
   
   m_last_update = 0;
   
   m_context.Reset();
   m_selection.Reset();
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CStrategySelector::~CStrategySelector()
{
}

//+------------------------------------------------------------------+
//| Initialize                                                        |
//+------------------------------------------------------------------+
bool CStrategySelector::Init(string symbol = "")
{
   m_symbol = symbol == "" ? _Symbol : symbol;
   
   Print("CStrategySelector: Initialized for ", m_symbol);
   Print("  FTMO Safe Mode: ", m_ftmo_safe_mode);
   Print("  News Trading: ", m_allow_news_trading);
   Print("  Asian Session: ", m_allow_asian_session);
   Print("  Hurst thresholds: <", m_hurst_revert, " / >", m_hurst_trend);
   Print("  Entropy thresholds: <", m_entropy_low, " / >", m_entropy_high);
   
   return true;
}

//+------------------------------------------------------------------+
//| Set Hurst thresholds                                              |
//+------------------------------------------------------------------+
void CStrategySelector::SetHurstThresholds(double trend, double revert)
{
   m_hurst_trend = trend;
   m_hurst_revert = revert;
}

//+------------------------------------------------------------------+
//| Set Entropy thresholds                                            |
//+------------------------------------------------------------------+
void CStrategySelector::SetEntropyThresholds(double low, double high)
{
   m_entropy_low = low;
   m_entropy_high = high;
}

//+------------------------------------------------------------------+
//| Update regime from external source                                |
//+------------------------------------------------------------------+
void CStrategySelector::SetRegime(double hurst, double entropy)
{
   m_current_hurst = hurst;
   m_current_entropy = entropy;
}

//+------------------------------------------------------------------+
//| Main strategy selection                                           |
//+------------------------------------------------------------------+
SStrategySelection CStrategySelector::SelectStrategy()
{
   UpdateContext();
   return SelectStrategy(m_context);
}

//+------------------------------------------------------------------+
//| Select strategy based on context                                  |
//+------------------------------------------------------------------+
SStrategySelection CStrategySelector::SelectStrategy(const SMarketContext &context)
{
   m_context = context;
   m_selection = EvaluateStrategies();
   return m_selection;
}

//+------------------------------------------------------------------+
//| Update all context information                                    |
//+------------------------------------------------------------------+
void CStrategySelector::UpdateContext()
{
   m_context.Reset();
   
   UpdateSafetyInfo();
   UpdateSessionInfo();
   UpdateRegimeInfo();
   UpdateNewsInfo();
   UpdateHolidayInfo();
   
   m_last_update = TimeGMT();
}

//+------------------------------------------------------------------+
//| Update safety information                                         |
//+------------------------------------------------------------------+
void CStrategySelector::UpdateSafetyInfo()
{
   if(m_safety != NULL)
   {
      SSafetyGate gate = m_safety->Check();
      m_context.circuit_ok = gate.circuit_ok;
      m_context.spread_ok = gate.spread_ok;
      
      SCircuitStatus* circuit = NULL;
      CCircuitBreaker* cb = m_safety->GetCircuitBreaker();
      if(cb != NULL)
      {
         SCircuitStatus status = cb->GetStatus();
         m_context.daily_dd_percent = status.daily_dd_percent;
         m_context.total_dd_percent = status.total_dd_percent;
         m_context.near_dd_limit = (status.daily_dd_percent >= 3.0);
      }
      
      CSpreadMonitor* sm = m_safety->GetSpreadMonitor();
      if(sm != NULL)
      {
         SSpreadAnalysis spread = sm->GetAnalysis();
         m_context.spread_ratio = spread.spread_ratio;
      }
   }
   else
   {
      m_context.circuit_ok = true;
      m_context.spread_ok = true;
   }
}

//+------------------------------------------------------------------+
//| Update session information                                        |
//+------------------------------------------------------------------+
void CStrategySelector::UpdateSessionInfo()
{
   MqlDateTime dt;
   TimeToStruct(TimeGMT(), dt);
   
   int hour = dt.hour;
   int day = dt.day_of_week;
   
   // Weekend check
   m_context.is_weekend = (day == 0 || day == 6);
   
   // Session detection (GMT)
   m_context.is_asian = (hour >= 0 && hour < 7);
   m_context.is_london = (hour >= 7 && hour < 16);
   m_context.is_newyork = (hour >= 13 && hour < 22);
   m_context.is_overlap = (hour >= 13 && hour < 16);  // Best hours
}

//+------------------------------------------------------------------+
//| Update regime information                                         |
//+------------------------------------------------------------------+
void CStrategySelector::UpdateRegimeInfo()
{
   m_context.hurst = m_current_hurst;
   m_context.entropy = m_current_entropy;
   
   // Classify regime
   m_context.is_trending = (m_context.hurst > m_hurst_trend);
   m_context.is_reverting = (m_context.hurst < m_hurst_revert);
   m_context.is_random = (!m_context.is_trending && !m_context.is_reverting);
   
   // High entropy = high noise
   m_context.high_volatility = (m_context.entropy > m_entropy_high);
}

//+------------------------------------------------------------------+
//| Update news information                                           |
//+------------------------------------------------------------------+
void CStrategySelector::UpdateNewsInfo()
{
   if(m_news_detector != NULL)
   {
      SNewsWindowResult news = m_news_detector->Check();
      m_context.in_news_window = news.in_window;
      m_context.minutes_to_news = news.minutes_to_event;
      m_context.news_imminent = (news.minutes_to_event <= 5 && news.minutes_to_event > 0);
      m_context.news_impact = news.event.impact;
   }
}

//+------------------------------------------------------------------+
//| Update holiday information                                        |
//+------------------------------------------------------------------+
void CStrategySelector::UpdateHolidayInfo()
{
   if(m_holiday_detector != NULL)
   {
      SHolidayInfo holiday = m_holiday_detector->Check();
      m_context.is_holiday = holiday.is_holiday;
      m_context.reduced_liquidity = (holiday.size_multiplier < 1.0);
   }
}

//+------------------------------------------------------------------+
//| Evaluate and select best strategy                                 |
//+------------------------------------------------------------------+
SStrategySelection CStrategySelector::EvaluateStrategies()
{
   SStrategySelection result;
   result.Reset();
   
   //=================================================================
   // GATE 1: ABSOLUTE BLOCKS
   //=================================================================
   
   // Circuit breaker
   if(!m_context.circuit_ok)
   {
      result.strategy = STRATEGY_NONE;
      result.can_trade = false;
      result.reason = "Circuit breaker active";
      return result;
   }
   
   // Spread too high
   if(!m_context.spread_ok)
   {
      result.strategy = STRATEGY_NONE;
      result.can_trade = false;
      result.reason = "Spread too high";
      return result;
   }
   
   // Weekend
   if(m_context.is_weekend)
   {
      result.strategy = STRATEGY_NONE;
      result.can_trade = false;
      result.reason = "Weekend - market closed";
      return result;
   }
   
   //=================================================================
   // GATE 2: FTMO SAFE MODE
   //=================================================================
   
   if(m_ftmo_safe_mode || m_context.near_dd_limit)
   {
      // Near DD limit - ultra conservative
      if(m_context.daily_dd_percent >= 3.5)
      {
         result.strategy = STRATEGY_NONE;
         result.can_trade = false;
         result.reason = "FTMO Safe: DD too high";
         return result;
      }
      
      // Safe mode active
      result.strategy = STRATEGY_SAFE_MODE;
      result.size_multiplier = 0.25;
      result.score_adjustment = -20;
      result.can_trade = true;
      result.reason = "FTMO Safe Mode active";
      
      // Block news trading in safe mode
      if(m_context.in_news_window)
      {
         result.strategy = STRATEGY_NONE;
         result.can_trade = false;
         result.reason = "FTMO Safe: No news trading";
         return result;
      }
      
      return result;
   }
   
   //=================================================================
   // GATE 3: NEWS CHECK
   //=================================================================
   
   if(m_allow_news_trading && m_context.in_news_window)
   {
      // High impact news - use news trader
      if(m_context.news_impact == NEWS_IMPACT_HIGH)
      {
         result.strategy = STRATEGY_NEWS_TRADER;
         result.size_multiplier = 0.5;  // Reduced size for news
         result.score_adjustment = 0;
         result.can_trade = true;
         result.reason = "High impact news window";
         return result;
      }
      
      // Medium impact - reduce normal trading
      if(m_context.news_impact == IMPACT_MEDIUM)
      {
         result.size_multiplier = 0.5;
         result.score_adjustment = -15;
         // Continue to regime selection
      }
   }
   
   // News imminent - block all trading
   if(m_context.news_imminent && m_context.news_impact == NEWS_IMPACT_HIGH)
   {
      result.strategy = STRATEGY_NONE;
      result.can_trade = false;
      result.reason = "High impact news in < 5 min";
      return result;
   }
   
   //=================================================================
   // GATE 4: SESSION CHECK
   //=================================================================
   
   // Asian session
   if(m_context.is_asian && !m_allow_asian_session)
   {
      result.strategy = STRATEGY_NONE;
      result.can_trade = false;
      result.reason = "Asian session blocked";
      return result;
   }
   
   // Best time: London/NY overlap
   if(m_context.is_overlap)
   {
      result.timing_confidence = 1.0;
      result.score_adjustment += 10;
   }
   else if(m_context.is_london || m_context.is_newyork)
   {
      result.timing_confidence = 0.8;
   }
   else
   {
      result.timing_confidence = 0.5;
      result.size_multiplier = MathMin(result.size_multiplier + 0.5, 0.5);
   }
   
   //=================================================================
   // GATE 5: HOLIDAY CHECK
   //=================================================================
   
   if(m_context.is_holiday)
   {
      result.size_multiplier = MathMin(result.size_multiplier + 0.5, 0.5);
      result.score_adjustment -= 10;
      result.reason = "Holiday - reduced liquidity";
   }
   
   //=================================================================
   // GATE 6: REGIME SELECTION
   //=================================================================
   
   // Random walk - no trade
   if(m_context.is_random)
   {
      result.strategy = STRATEGY_NONE;
      result.can_trade = false;
      result.reason = "Random walk regime (Hurst ~0.5)";
      return result;
   }
   
   // High noise - reduce confidence
   if(m_context.high_volatility)
   {
      result.size_multiplier = MathMin(result.size_multiplier + 0.5, 0.5);
      result.score_adjustment -= 15;
   }
   
   // Trending market
   if(m_context.is_trending)
   {
      result.strategy = STRATEGY_TREND_FOLLOW;
      result.regime_confidence = (m_context.hurst - 0.5) / 0.5;  // Normalize
      
      if(m_context.entropy < m_entropy_low)
      {
         // Prime trending: high Hurst, low entropy
         result.size_multiplier = 1.0;
         result.score_adjustment += 15;
         result.reason = "Prime trending regime";
      }
      else
      {
         // Noisy trending
         result.size_multiplier = 0.5;
         result.reason = "Noisy trending regime";
      }
   }
   // Mean reverting market
   else if(m_context.is_reverting)
   {
      result.strategy = STRATEGY_MEAN_REVERT;
      result.regime_confidence = (0.5 - m_context.hurst) / 0.5;  // Normalize
      
      if(m_context.entropy < m_entropy_low)
      {
         // Prime reverting
         result.size_multiplier = 1.0;
         result.score_adjustment += 10;
         result.reason = "Prime reverting regime";
      }
      else
      {
         // Noisy reverting
         result.size_multiplier = 0.5;
         result.reason = "Noisy reverting regime";
      }
   }
   // Default: SMC Scalper
   else
   {
      result.strategy = STRATEGY_SMC_SCALPER;
      result.size_multiplier = 0.75;
      result.reason = "Default SMC scalping";
   }
   
   result.can_trade = true;
   result.overall_confidence = CalculateConfidence();
   
   return result;
}

//+------------------------------------------------------------------+
//| Calculate overall confidence                                      |
//+------------------------------------------------------------------+
double CStrategySelector::CalculateConfidence()
{
   double regime_weight = 0.5;
   double timing_weight = 0.3;
   double safety_weight = 0.2;
   
   double regime_score = m_selection.regime_confidence;
   double timing_score = m_selection.timing_confidence;
   double safety_score = (m_context.circuit_ok && m_context.spread_ok) ? 1.0 : 0.0;
   
   return regime_score * regime_weight + 
          timing_score * timing_weight + 
          safety_score * safety_weight;
}

//+------------------------------------------------------------------+
//| Get strategy name                                                 |
//+------------------------------------------------------------------+
string CStrategySelector::GetStrategyName(ENUM_STRATEGY_TYPE strategy)
{
   switch(strategy)
   {
      case STRATEGY_NONE:         return "NONE";
      case STRATEGY_NEWS_TRADER:  return "NEWS_TRADER";
      case STRATEGY_TREND_FOLLOW: return "TREND_FOLLOW";
      case STRATEGY_MEAN_REVERT:  return "MEAN_REVERT";
      case STRATEGY_SMC_SCALPER:  return "SMC_SCALPER";
      case STRATEGY_SAFE_MODE:    return "SAFE_MODE";
      default:                    return "UNKNOWN";
   }
}

//+------------------------------------------------------------------+
//| Print selection details                                           |
//+------------------------------------------------------------------+
void CStrategySelector::PrintSelection()
{
   Print("=== Strategy Selection ===");
   Print("Strategy: ", GetStrategyName(m_selection.strategy));
   Print("Can Trade: ", m_selection.can_trade);
   Print("Size Mult: ", m_selection.size_multiplier);
   Print("Score Adj: ", m_selection.score_adjustment);
   Print("Reason: ", m_selection.reason);
   Print("--- Context ---");
   Print("Hurst: ", m_context.hurst, " Entropy: ", m_context.entropy);
   Print("Trending: ", m_context.is_trending, " Reverting: ", m_context.is_reverting);
   Print("Session: London=", m_context.is_london, " NY=", m_context.is_newyork);
   Print("News Window: ", m_context.in_news_window);
   Print("DD: Daily=", m_context.daily_dd_percent, "% Total=", m_context.total_dd_percent, "%");
   Print("==========================");
}

//+------------------------------------------------------------------+
