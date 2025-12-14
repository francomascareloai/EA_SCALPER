//+------------------------------------------------------------------+
//|                                              CEntryOptimizer.mqh |
//|                           EA_SCALPER_XAUUSD - Singularity Edition |
//|                                                                  |
//|  ENTRY OPTIMIZATION IS CRUCIAL FOR MAXIMUM R:R                   |
//|                                                                  |
//|  THE PROBLEM:                                                    |
//|  - Most traders enter at MARKET price                            |
//|  - This leaves money on the table                                |
//|  - Poor entry = worse R:R = lower profitability                  |
//|                                                                  |
//|  THE SOLUTION:                                                   |
//|  - Wait for price to retrace to OPTIMAL entry zone               |
//|  - Use FVG 50% fill for precision entries                        |
//|  - Use OB refinement (70% of zone) for better price              |
//|                                                                  |
//|  ENTRY PRIORITY:                                                 |
//|  1. FVG 50% fill - Most precise, best R:R                        |
//|  2. OB 70% retest - Good precision, structural                   |
//|  3. Market entry - Only if signal is very strong                 |
//|                                                                  |
//|  THE MATH:                                                       |
//|  Market entry: 1.5:1 R:R × 55% = 0.275R expectancy               |
//|  OB retest:    2.5:1 R:R × 55% = 0.625R expectancy               |
//|  FVG fill:     3.0:1 R:R × 55% = 0.85R  expectancy               |
//|                                                                  |
//|  5-10 pips better entry = 2-3x better expectancy!                |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD - Singularity Edition"
#property strict

#include "../Core/Definitions.mqh"

//+------------------------------------------------------------------+
//| Entry Type Enumeration                                            |
//+------------------------------------------------------------------+
enum ENUM_ENTRY_TYPE
{
   ENTRY_NONE = 0,
   ENTRY_MARKET,               // Immediate market entry
   ENTRY_FVG_FILL,             // Wait for FVG fill
   ENTRY_OB_RETEST,            // Wait for OB retest
   ENTRY_LIMIT_ORDER           // Place limit order at optimal level
};

//+------------------------------------------------------------------+
//| Entry Quality                                                     |
//+------------------------------------------------------------------+
enum ENUM_ENTRY_QUALITY
{
   ENTRY_QUALITY_POOR = 0,
   ENTRY_QUALITY_ACCEPTABLE,
   ENTRY_QUALITY_GOOD,
   ENTRY_QUALITY_OPTIMAL
};

//+------------------------------------------------------------------+
//| Optimal Entry Structure                                           |
//+------------------------------------------------------------------+
struct SOptimalEntry
{
   ENUM_ENTRY_TYPE   type;
   ENUM_ENTRY_QUALITY quality;
   ENUM_SIGNAL_TYPE  direction;
   double            optimal_price;       // Best entry price
   double            acceptable_high;     // Acceptable entry range high
   double            acceptable_low;      // Acceptable entry range low
   double            stop_loss;           // Structural stop loss
   double            take_profit_1;       // TP1 (1.5-2R)
   double            take_profit_2;       // TP2 (2.5-3R)
   double            take_profit_3;       // TP3 (4R+)
   double            risk_reward;         // Expected R:R at optimal entry
   double            zone_source_high;    // OB/FVG zone high
   double            zone_source_low;     // OB/FVG zone low
   string            zone_type;           // "FVG" or "OB"
   int               max_wait_bars;       // How long to wait for optimal
   datetime          valid_until;         // Entry validity expiry
   bool              is_valid;
   
   void Reset()
   {
      type = ENTRY_NONE;
      quality = ENTRY_QUALITY_POOR;
      direction = SIGNAL_NONE;
      optimal_price = 0;
      acceptable_high = 0;
      acceptable_low = 0;
      stop_loss = 0;
      take_profit_1 = 0;
      take_profit_2 = 0;
      take_profit_3 = 0;
      risk_reward = 0;
      zone_source_high = 0;
      zone_source_low = 0;
      zone_type = "";
      max_wait_bars = 0;
      valid_until = 0;
      is_valid = false;
   }
};

//+------------------------------------------------------------------+
//| Entry Optimizer Class                                             |
//+------------------------------------------------------------------+
class CEntryOptimizer
{
private:
   // Configuration
   double            m_min_rr_ratio;            // Minimum R:R to accept
   double            m_target_rr_ratio;         // Target R:R
   double            m_fvg_fill_percent;        // FVG fill target (0.5 = 50%)
   double            m_ob_retest_percent;       // OB retest target (0.7 = 70%)
   int               m_max_wait_bars;           // Max bars to wait for entry
   double            m_sl_buffer_atr;           // SL buffer in ATR units
   
   // XAUUSD SCALPING LIMITS (em points; 1 point = _Point)
   double            m_max_sl_points;           // Max distance in points
   double            m_min_sl_points;           // Min distance in points
   double            m_default_sl_points;       // Default SL distance in points
   
   // State
   SOptimalEntry     m_current_entry;
   
   // Indicator handles
   int               m_atr_handle;
   
   // Internal methods
   double            CalculateRiskReward(double entry, double sl, double tp);
   SOptimalEntry     OptimizeForBuy(double fvg_low, double fvg_high, double ob_low, double ob_high, 
                                     double sweep_low, double current_price, double atr);
   SOptimalEntry     OptimizeForSell(double fvg_low, double fvg_high, double ob_low, double ob_high,
                                      double sweep_high, double current_price, double atr);
   
public:
   CEntryOptimizer();
   ~CEntryOptimizer() 
   { 
      if(m_atr_handle != INVALID_HANDLE) 
         IndicatorRelease(m_atr_handle); 
   }
   
   // Initialization - MTF v3.20: M5 for precision entries
   bool              Initialize(string symbol = NULL, ENUM_TIMEFRAMES tf = PERIOD_M5);
   
   // Main optimization method
   SOptimalEntry     CalculateOptimalEntry(
                        ENUM_SIGNAL_TYPE direction,
                        double fvg_low, double fvg_high,      // FVG zone (0 if none)
                        double ob_low, double ob_high,         // OB zone (0 if none)
                        double sweep_level,                    // Level that was swept
                        double current_price
                     );
   
   // Entry checks
   bool              ShouldEnterNow(double current_price);
   bool              IsInOptimalZone(double current_price);
   bool              IsInAcceptableZone(double current_price);
   bool              HasExpired();
   
   // Current entry access
   SOptimalEntry     GetCurrentEntry() { return m_current_entry; }
   ENUM_ENTRY_TYPE   GetEntryType() { return m_current_entry.type; }
   double            GetOptimalPrice() { return m_current_entry.optimal_price; }
   double            GetStopLoss() { return m_current_entry.stop_loss; }
   double            GetTP1() { return m_current_entry.take_profit_1; }
   double            GetTP2() { return m_current_entry.take_profit_2; }
   double            GetTP3() { return m_current_entry.take_profit_3; }
   double            GetRiskReward() { return m_current_entry.risk_reward; }
   
   // Configuration
   void              SetMinRR(double rr) { m_min_rr_ratio = rr; }
   void              SetTargetRR(double rr) { m_target_rr_ratio = rr; }
   void              SetFVGFillPercent(double pct) { m_fvg_fill_percent = pct; }
   void              SetOBRetestPercent(double pct) { m_ob_retest_percent = pct; }
   void              SetMaxWaitBars(int bars) { m_max_wait_bars = bars; }
   
   // SL Limits for Scalping (CRITICAL for XAUUSD)
   void              SetMaxSLPoints(double pts) { m_max_sl_points = pts; }
   void              SetMinSLPoints(double pts) { m_min_sl_points = pts; }
   void              SetDefaultSLPoints(double pts) { m_default_sl_points = pts; }
   
   // Reset
   void              Reset() { m_current_entry.Reset(); }
   
   // Info
   string            GetEntryInfo();
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CEntryOptimizer::CEntryOptimizer()
{
   m_min_rr_ratio = 1.5;           // Minimum 1.5:1 R:R
   m_target_rr_ratio = 2.5;        // Target 2.5:1 R:R
   m_fvg_fill_percent = 0.5;       // 50% FVG fill
   m_ob_retest_percent = 0.7;      // 70% OB retest
   m_max_wait_bars = 10;           // Wait max 10 bars
   m_sl_buffer_atr = 0.2;          // 0.2 ATR buffer for SL
   
   // XAUUSD SCALPING LIMITS - CRITICAL FOR PROP FIRMS
   // Valores são em points (1 point = _Point). Para XAUUSD (_Point=0.01),
   // 5000 points = $50, 1500 = $15, 3000 = $30.
   m_max_sl_points = 5000.0;       // Max ~$50
   m_min_sl_points = 1500.0;       // Min ~$15
   m_default_sl_points = 3000.0;   // Default ~$30 se não houver estrutura
   
   m_atr_handle = INVALID_HANDLE;
   m_current_entry.Reset();
}

//+------------------------------------------------------------------+
//| Initialize - MTF v3.20: Default to M5 for precision entries      |
//+------------------------------------------------------------------+
bool CEntryOptimizer::Initialize(string symbol, ENUM_TIMEFRAMES tf)
{
   if(symbol == NULL) symbol = _Symbol;
   
   // Use M5 for ATR to get tighter, more precise SL calculations
   m_atr_handle = iATR(symbol, tf, 14);
   if(m_atr_handle == INVALID_HANDLE)
   {
      Print("CEntryOptimizer: Failed to create ATR handle");
      return false;
   }
   
   Print("CEntryOptimizer: Initialized with target R:R = ", m_target_rr_ratio);
   Print("CEntryOptimizer: Using M5 timeframe for precision entries (MTF v3.20)");
   return true;
}

//+------------------------------------------------------------------+
//| Calculate Risk:Reward ratio                                       |
//+------------------------------------------------------------------+
double CEntryOptimizer::CalculateRiskReward(double entry, double sl, double tp)
{
   double risk = MathAbs(entry - sl);
   double reward = MathAbs(tp - entry);
   
   if(risk <= 0) return 0;
   return reward / risk;
}

//+------------------------------------------------------------------+
//| Main optimization method                                          |
//+------------------------------------------------------------------+
SOptimalEntry CEntryOptimizer::CalculateOptimalEntry(
   ENUM_SIGNAL_TYPE direction,
   double fvg_low, double fvg_high,
   double ob_low, double ob_high,
   double sweep_level,
   double current_price)
{
   m_current_entry.Reset();
   
   if(direction == SIGNAL_NONE)
      return m_current_entry;
   
   // Get ATR
   double atr_buf[];
   if(CopyBuffer(m_atr_handle, 0, 0, 1, atr_buf) <= 0)
      return m_current_entry;
   double atr = atr_buf[0];
   
   if(direction == SIGNAL_BUY)
      m_current_entry = OptimizeForBuy(fvg_low, fvg_high, ob_low, ob_high, sweep_level, current_price, atr);
   else
      m_current_entry = OptimizeForSell(fvg_low, fvg_high, ob_low, ob_high, sweep_level, current_price, atr);
   
   return m_current_entry;
}

//+------------------------------------------------------------------+
//| Optimize entry for BUY signal                                     |
//+------------------------------------------------------------------+
SOptimalEntry CEntryOptimizer::OptimizeForBuy(double fvg_low, double fvg_high, 
                                               double ob_low, double ob_high,
                                               double sweep_low, double current_price, double atr)
{
   SOptimalEntry entry;
   entry.Reset();
   entry.direction = SIGNAL_BUY;
   
   bool has_fvg = (fvg_low > 0 && fvg_high > 0 && fvg_high > fvg_low);
   bool has_ob = (ob_low > 0 && ob_high > 0 && ob_high > ob_low);
   
   // Distancias em preco a partir de pontos configurados
   double max_sl_price = m_max_sl_points * _Point;
   double min_sl_price = m_min_sl_points * _Point;
   double default_sl_price = m_default_sl_points * _Point;

   // PRIORITY 1: FVG 50% fill (best entry)
   if(has_fvg && fvg_low < current_price)
   {
      double fvg_mid = fvg_low + (fvg_high - fvg_low) * m_fvg_fill_percent;
      
      entry.type = ENTRY_FVG_FILL;
      entry.optimal_price = fvg_mid;
      entry.acceptable_low = fvg_low;
      entry.acceptable_high = fvg_high;
      entry.zone_type = "FVG";
      entry.zone_source_low = fvg_low;
      entry.zone_source_high = fvg_high;
      
      // Stop loss - APPLY SCALPING LIMITS
      double raw_sl = (sweep_low > 0) ? sweep_low - (atr * m_sl_buffer_atr) : 0;
      double sl_distance = entry.optimal_price - raw_sl;
      
      // Clamp SL distance between min and max (prices, not “points”)
      if(raw_sl <= 0 || sl_distance > max_sl_price)
         entry.stop_loss = entry.optimal_price - default_sl_price;
      else if(sl_distance < min_sl_price)
         entry.stop_loss = entry.optimal_price - min_sl_price;
      else
         entry.stop_loss = raw_sl;
      
      // Take profits based on clamped risk
      double risk = entry.optimal_price - entry.stop_loss;
      entry.take_profit_1 = entry.optimal_price + risk * 1.5;  // 1.5R
      entry.take_profit_2 = entry.optimal_price + risk * 2.5;  // 2.5R
      entry.take_profit_3 = entry.optimal_price + risk * 4.0;  // 4R
      
      entry.risk_reward = CalculateRiskReward(entry.optimal_price, entry.stop_loss, entry.take_profit_2);
      entry.quality = ENTRY_QUALITY_OPTIMAL;
      entry.is_valid = true;
   }
   // PRIORITY 2: OB retest (good entry)
   else if(has_ob && ob_low < current_price)
   {
      double ob_entry = ob_low + (ob_high - ob_low) * m_ob_retest_percent;
      
      entry.type = ENTRY_OB_RETEST;
      entry.optimal_price = ob_entry;
      entry.acceptable_low = ob_low;
      entry.acceptable_high = ob_high;
      entry.zone_type = "OB";
      entry.zone_source_low = ob_low;
      entry.zone_source_high = ob_high;
      
      // Stop loss - APPLY SCALPING LIMITS
      double raw_sl = ob_low - (atr * m_sl_buffer_atr);
      if(sweep_low > 0 && sweep_low < raw_sl)
         raw_sl = sweep_low - (atr * m_sl_buffer_atr);
      
      double sl_distance = entry.optimal_price - raw_sl;
      
      if(raw_sl <= 0 || sl_distance > max_sl_price)
         entry.stop_loss = entry.optimal_price - default_sl_price;
      else if(sl_distance < min_sl_price)
         entry.stop_loss = entry.optimal_price - min_sl_price;
      else
         entry.stop_loss = raw_sl;
      
      double risk = entry.optimal_price - entry.stop_loss;
      entry.take_profit_1 = entry.optimal_price + risk * 1.5;
      entry.take_profit_2 = entry.optimal_price + risk * 2.5;
      entry.take_profit_3 = entry.optimal_price + risk * 4.0;
      
      entry.risk_reward = CalculateRiskReward(entry.optimal_price, entry.stop_loss, entry.take_profit_2);
      entry.quality = ENTRY_QUALITY_GOOD;
      entry.is_valid = true;
   }
   // PRIORITY 3: Market entry (acceptable if signal is strong)
   else
   {
      entry.type = ENTRY_MARKET;
      entry.optimal_price = current_price;
      entry.acceptable_low = current_price - atr * 0.2;
      entry.acceptable_high = current_price + atr * 0.2;
      entry.zone_type = "MARKET";
      
      // Use default scalping SL for market entries
      entry.stop_loss = current_price - default_sl_price;
      
      double risk = current_price - entry.stop_loss;
      entry.take_profit_1 = current_price + risk * 1.5;
      entry.take_profit_2 = current_price + risk * 2.5;
      entry.take_profit_3 = current_price + risk * 4.0;
      
      entry.risk_reward = CalculateRiskReward(current_price, entry.stop_loss, entry.take_profit_2);
      
      // Always valid with proper SL now
      entry.quality = ENTRY_QUALITY_ACCEPTABLE;
      entry.is_valid = true;
   }
   
   entry.max_wait_bars = m_max_wait_bars;
   entry.valid_until = TimeCurrent() + m_max_wait_bars * PeriodSeconds(PERIOD_M15);
   
   return entry;
}

//+------------------------------------------------------------------+
//| Optimize entry for SELL signal                                    |
//+------------------------------------------------------------------+
SOptimalEntry CEntryOptimizer::OptimizeForSell(double fvg_low, double fvg_high,
                                                double ob_low, double ob_high,
                                                double sweep_high, double current_price, double atr)
{
   SOptimalEntry entry;
   entry.Reset();
   entry.direction = SIGNAL_SELL;
   
   bool has_fvg = (fvg_low > 0 && fvg_high > 0 && fvg_high > fvg_low);
   bool has_ob = (ob_low > 0 && ob_high > 0 && ob_high > ob_low);
   
   double max_sl_price = m_max_sl_points * _Point;
   double min_sl_price = m_min_sl_points * _Point;
   double default_sl_price = m_default_sl_points * _Point;
   
   // PRIORITY 1: FVG 50% fill
   if(has_fvg && fvg_high > current_price)
   {
      double fvg_mid = fvg_high - (fvg_high - fvg_low) * m_fvg_fill_percent;
      
      entry.type = ENTRY_FVG_FILL;
      entry.optimal_price = fvg_mid;
      entry.acceptable_low = fvg_low;
      entry.acceptable_high = fvg_high;
      entry.zone_type = "FVG";
      entry.zone_source_low = fvg_low;
      entry.zone_source_high = fvg_high;
      
      // Stop loss - APPLY SCALPING LIMITS
      double raw_sl = (sweep_high > 0) ? sweep_high + (atr * m_sl_buffer_atr) : 0;
      double sl_distance = raw_sl - entry.optimal_price;
      
      // Clamp SL distance between min and max (prices, não “points” crus)
      if(raw_sl <= 0 || sl_distance > max_sl_price)
         entry.stop_loss = entry.optimal_price + default_sl_price;
      else if(sl_distance < min_sl_price)
         entry.stop_loss = entry.optimal_price + min_sl_price;
      else
         entry.stop_loss = raw_sl;
      
      double risk = entry.stop_loss - entry.optimal_price;
      entry.take_profit_1 = entry.optimal_price - risk * 1.5;
      entry.take_profit_2 = entry.optimal_price - risk * 2.5;
      entry.take_profit_3 = entry.optimal_price - risk * 4.0;
      
      entry.risk_reward = CalculateRiskReward(entry.optimal_price, entry.stop_loss, entry.take_profit_2);
      entry.quality = ENTRY_QUALITY_OPTIMAL;
      entry.is_valid = true;
   }
   // PRIORITY 2: OB retest
   else if(has_ob && ob_high > current_price)
   {
      double ob_entry = ob_high - (ob_high - ob_low) * m_ob_retest_percent;
      
      entry.type = ENTRY_OB_RETEST;
      entry.optimal_price = ob_entry;
      entry.acceptable_low = ob_low;
      entry.acceptable_high = ob_high;
      entry.zone_type = "OB";
      entry.zone_source_low = ob_low;
      entry.zone_source_high = ob_high;
      
      // Stop loss - APPLY SCALPING LIMITS
      double raw_sl = ob_high + (atr * m_sl_buffer_atr);
      if(sweep_high > 0 && sweep_high > raw_sl)
         raw_sl = sweep_high + (atr * m_sl_buffer_atr);
      
      double sl_distance = raw_sl - entry.optimal_price;
      
      if(raw_sl <= 0 || sl_distance > max_sl_price)
         entry.stop_loss = entry.optimal_price + default_sl_price;
      else if(sl_distance < min_sl_price)
         entry.stop_loss = entry.optimal_price + min_sl_price;
      else
         entry.stop_loss = raw_sl;
      
      double risk = entry.stop_loss - entry.optimal_price;
      entry.take_profit_1 = entry.optimal_price - risk * 1.5;
      entry.take_profit_2 = entry.optimal_price - risk * 2.5;
      entry.take_profit_3 = entry.optimal_price - risk * 4.0;
      
      entry.risk_reward = CalculateRiskReward(entry.optimal_price, entry.stop_loss, entry.take_profit_2);
      entry.quality = ENTRY_QUALITY_GOOD;
      entry.is_valid = true;
   }
   // PRIORITY 3: Market entry
   else
   {
      entry.type = ENTRY_MARKET;
      entry.optimal_price = current_price;
      entry.acceptable_low = current_price - atr * 0.2;
      entry.acceptable_high = current_price + atr * 0.2;
      entry.zone_type = "MARKET";
      
      // Use default scalping SL for market entries
      entry.stop_loss = current_price + default_sl_price;
      
      double risk = entry.stop_loss - current_price;
      entry.take_profit_1 = current_price - risk * 1.5;
      entry.take_profit_2 = current_price - risk * 2.5;
      entry.take_profit_3 = current_price - risk * 4.0;
      
      entry.risk_reward = CalculateRiskReward(current_price, entry.stop_loss, entry.take_profit_2);
      
      // Always valid with proper SL now
      entry.quality = ENTRY_QUALITY_ACCEPTABLE;
      entry.is_valid = true;
   }
   
   entry.max_wait_bars = m_max_wait_bars;
   entry.valid_until = TimeCurrent() + m_max_wait_bars * PeriodSeconds(PERIOD_M15);
   
   return entry;
}

//+------------------------------------------------------------------+
//| Check if should enter now                                         |
//+------------------------------------------------------------------+
bool CEntryOptimizer::ShouldEnterNow(double current_price)
{
   if(!m_current_entry.is_valid) return false;
   if(HasExpired()) return false;
   
   // If market entry, enter immediately
   if(m_current_entry.type == ENTRY_MARKET)
      return true;
   
   // For FVG/OB entries, check if price is in zone
   return IsInAcceptableZone(current_price);
}

//+------------------------------------------------------------------+
//| Check if price is in optimal zone                                 |
//+------------------------------------------------------------------+
bool CEntryOptimizer::IsInOptimalZone(double current_price)
{
   if(!m_current_entry.is_valid) return false;
   
   double tolerance = MathAbs(m_current_entry.acceptable_high - m_current_entry.acceptable_low) * 0.1;
   
   return (MathAbs(current_price - m_current_entry.optimal_price) <= tolerance);
}

//+------------------------------------------------------------------+
//| Check if price is in acceptable zone                              |
//+------------------------------------------------------------------+
bool CEntryOptimizer::IsInAcceptableZone(double current_price)
{
   if(!m_current_entry.is_valid) return false;
   
   return (current_price >= m_current_entry.acceptable_low && 
           current_price <= m_current_entry.acceptable_high);
}

//+------------------------------------------------------------------+
//| Check if entry has expired                                        |
//+------------------------------------------------------------------+
bool CEntryOptimizer::HasExpired()
{
   return (TimeCurrent() > m_current_entry.valid_until);
}

//+------------------------------------------------------------------+
//| Get entry info string                                             |
//+------------------------------------------------------------------+
string CEntryOptimizer::GetEntryInfo()
{
   if(!m_current_entry.is_valid)
      return "No valid entry";
   
   string info = "Entry: " + m_current_entry.zone_type;
   info += " | Dir: " + (m_current_entry.direction == SIGNAL_BUY ? "BUY" : "SELL");
   info += " | Optimal: " + DoubleToString(m_current_entry.optimal_price, _Digits);
   info += " | SL: " + DoubleToString(m_current_entry.stop_loss, _Digits);
   info += " | R:R: " + DoubleToString(m_current_entry.risk_reward, 2);
   info += " | Quality: ";
   
   switch(m_current_entry.quality)
   {
      case ENTRY_QUALITY_OPTIMAL:    info += "OPTIMAL"; break;
      case ENTRY_QUALITY_GOOD:       info += "GOOD"; break;
      case ENTRY_QUALITY_ACCEPTABLE: info += "ACCEPTABLE"; break;
      default:                       info += "POOR"; break;
   }
   
   return info;
}
