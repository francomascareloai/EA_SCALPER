//+------------------------------------------------------------------+
//|                                              CSpreadMonitor.mqh |
//|                                                           Franco |
//|                   EA_SCALPER_XAUUSD v4.0 - Safety Layer          |
//|                   Implements IRiskGate for unified gate system    |
//+------------------------------------------------------------------+
#property copyright "Franco"
#property link      "EA_SCALPER_XAUUSD"
#property version   "2.00"
#property strict

#include "../Core/Definitions.mqh"
#include "../Core/IRiskGate.mqh"

//+------------------------------------------------------------------+
//| Spread Status                                                     |
//+------------------------------------------------------------------+
enum ENUM_SPREAD_STATUS
{
   SPREAD_NORMAL = 0,     // Normal spread
   SPREAD_ELEVATED = 1,   // Above average but acceptable
   SPREAD_HIGH = 2,       // Warning level
   SPREAD_EXTREME = 3,    // Trading not recommended
   SPREAD_BLOCKED = 4     // No trading allowed
};

//+------------------------------------------------------------------+
//| Spread Analysis Result                                            |
//+------------------------------------------------------------------+
struct SSpreadAnalysis
{
   ENUM_SPREAD_STATUS status;
   
   double            current_spread;      // Current spread in points
   double            current_spread_pips; // Current spread in pips
   
   double            average_spread;      // Moving average of spread
   double            max_spread;          // Max observed
   double            min_spread;          // Min observed
   double            std_dev;             // Standard deviation
   
   double            spread_ratio;        // Current / Average ratio
   double            z_score;             // Statistical deviation
   
   double            size_multiplier;     // Position size adjustment (0.0-1.0)
   int               score_adjustment;    // Signal score adjustment
   
   bool              can_trade;           // OK to open positions
   string            reason;              // Human readable reason
   
   void Reset()
   {
      status = SPREAD_NORMAL;
      current_spread = 0;
      current_spread_pips = 0;
      average_spread = 0;
      max_spread = 0;
      min_spread = 0;
      std_dev = 0;
      spread_ratio = 1.0;
      z_score = 0;
      size_multiplier = 1.0;
      score_adjustment = 0;
      can_trade = true;
      reason = "Normal";
   }
};

//+------------------------------------------------------------------+
//| Class: CSpreadMonitor                                             |
//| Purpose: Monitor spread and adjust trading accordingly            |
//| Implements: IRiskGate interface for unified gate system           |
//|                                                                   |
//| Design Philosophy:                                                |
//| - Track rolling average of last N spread samples                  |
//| - Detect abnormal spread (statistically or by ratio)              |
//| - Reduce position size during high spread                         |
//| - Block trading during extreme spread                             |
//|                                                                   |
//| Gate Behavior:                                                    |
//| - Returns GATE_SPREAD when spread > max_spread_points             |
//| - max_spread_points default: 80 (8 pips for XAUUSD)               |
//+------------------------------------------------------------------+
class CSpreadMonitor : public IRiskGate
{
private:
   //--- Configuration
   string            m_symbol;
   int               m_history_size;      // Samples to keep
   double            m_warning_ratio;     // Warn when spread > avg * ratio
   double            m_block_ratio;       // Block when spread > avg * ratio
   double            m_max_spread_pips;   // Absolute max spread allowed (pips)
   int               m_max_spread_points; // Absolute max spread allowed (points)

   //--- Spread history
   double            m_spread_history[];
   int               m_history_index;
   int               m_samples_collected;

   //--- Statistics
   double            m_sum;
   double            m_sum_sq;
   double            m_min_observed;
   double            m_max_observed;

   //--- Status cache
   SSpreadAnalysis   m_analysis;
   datetime          m_last_update;
   int               m_update_interval;   // Seconds between updates

   //--- Point/pip conversion
   double            m_pip_factor;        // Points per pip (10 for JPY, 1 otherwise)

public:
                     CSpreadMonitor();
                    ~CSpreadMonitor();

   //--- Initialization
   bool              Init(string symbol = "", int history_size = 100);
   void              SetWarningRatio(double ratio) { m_warning_ratio = ratio; }
   void              SetBlockRatio(double ratio) { m_block_ratio = ratio; }
   void              SetMaxSpreadPips(double pips) { m_max_spread_pips = pips; }
   void              SetMaxSpreadPoints(int points) { m_max_spread_points = points; }
   void              SetUpdateInterval(int seconds) { m_update_interval = seconds; }

   //--- Main check
   SSpreadAnalysis   Check();
   bool              CanTrade() { Check(); return m_analysis.can_trade; }
   double            GetSizeMultiplier() { Check(); return m_analysis.size_multiplier; }
   int               GetScoreAdjustment() { Check(); return m_analysis.score_adjustment; }

   //--- Status access
   ENUM_SPREAD_STATUS GetStatus() { Check(); return m_analysis.status; }
   SSpreadAnalysis   GetAnalysis() { Check(); return m_analysis; }

   //--- Raw values
   double            GetCurrentSpread();
   double            GetCurrentSpreadPips();
   double            GetAverageSpread() { return m_analysis.average_spread; }
   double            GetMedianSpread();
   double            GetZScore() { Check(); return m_analysis.z_score; }

   //--- Utility
   void              Reset();
   void              PrintStatus();
   string            GetStatusString();

   //--- IRiskGate interface implementation
   virtual bool              IsBlocked(void);
   virtual ENUM_GATE_REASON  GetReason(void);
   virtual string            GetReasonText(void);
   virtual void              OnTick(void) { Check(); }
   virtual string            GetGateName(void) { return "SpreadMonitor"; }

private:
   void              RecordSpread(double spread);
   void              UpdateStatistics();
   void              AnalyzeSpread();
   double            CalculateStdDev();
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CSpreadMonitor::CSpreadMonitor()
{
   m_symbol = "";
   m_history_size = 100;
   m_warning_ratio = 2.0;    // Warn at 2x normal
   m_block_ratio = 5.0;      // Block at 5x normal
   m_max_spread_pips = 50.0; // Absolute max 50 pips
   m_max_spread_points = 80; // Default 80 points (8 pips for XAUUSD)

   m_history_index = 0;
   m_samples_collected = 0;

   m_sum = 0;
   m_sum_sq = 0;
   m_min_observed = DBL_MAX;
   m_max_observed = 0;

   m_last_update = 0;
   m_update_interval = 1;

   m_pip_factor = 1.0;

   m_analysis.Reset();
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CSpreadMonitor::~CSpreadMonitor()
{
   ArrayFree(m_spread_history);
}

//+------------------------------------------------------------------+
//| Initialize                                                        |
//+------------------------------------------------------------------+
bool CSpreadMonitor::Init(string symbol = "", int history_size = 100)
{
   m_symbol = symbol == "" ? _Symbol : symbol;
   m_history_size = history_size;
   
   // Allocate history array
   ArrayResize(m_spread_history, m_history_size);
   ArrayFill(m_spread_history, 0, m_history_size, 0);
   
   // Reset counters
   m_history_index = 0;
   m_samples_collected = 0;
   m_sum = 0;
   m_sum_sq = 0;
   m_min_observed = DBL_MAX;
   m_max_observed = 0;
   
   // Determine pip factor (for JPY pairs, 1 pip = 100 points)
   int digits = (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
   if(digits == 3 || digits == 2)
      m_pip_factor = 10.0;  // JPY pairs
   else if(digits == 5 || digits == 4)
      m_pip_factor = 10.0;  // Standard pairs with 5 digits
   else
      m_pip_factor = 1.0;
   
   // For XAUUSD specifically
   if(StringFind(m_symbol, "XAU") >= 0)
      m_pip_factor = 10.0;  // 1 pip = 10 points for gold
   
   Print("CSpreadMonitor: Initialized for ", m_symbol);
   Print("  History size: ", m_history_size);
   Print("  Warning ratio: ", m_warning_ratio, "x");
   Print("  Block ratio: ", m_block_ratio, "x");
   Print("  Max spread: ", m_max_spread_pips, " pips");
   Print("  Pip factor: ", m_pip_factor);
   
   return true;
}

//+------------------------------------------------------------------+
//| Main check function                                               |
//+------------------------------------------------------------------+
SSpreadAnalysis CSpreadMonitor::Check()
{
   // Rate limit checks
   datetime now = TimeGMT();
   if(now - m_last_update < m_update_interval)
      return m_analysis;
   
   m_last_update = now;
   
   // Get current spread
   double current = GetCurrentSpread();
   
   // Record to history
   RecordSpread(current);
   
   // Update statistics
   UpdateStatistics();
   
   // Analyze and set status
   AnalyzeSpread();
   
   return m_analysis;
}

//+------------------------------------------------------------------+
//| Get current spread in points                                      |
//+------------------------------------------------------------------+
double CSpreadMonitor::GetCurrentSpread()
{
   return (double)SymbolInfoInteger(m_symbol, SYMBOL_SPREAD);
}

//+------------------------------------------------------------------+
//| Get current spread in pips                                        |
//+------------------------------------------------------------------+
double CSpreadMonitor::GetCurrentSpreadPips()
{
   return GetCurrentSpread() / m_pip_factor;
}

//+------------------------------------------------------------------+
//| Record spread to history                                          |
//+------------------------------------------------------------------+
void CSpreadMonitor::RecordSpread(double spread)
{
   // Remove old value from sums if history is full
   if(m_samples_collected >= m_history_size)
   {
      double old_val = m_spread_history[m_history_index];
      m_sum -= old_val;
      m_sum_sq -= old_val * old_val;
   }
   
   // Add new value
   m_spread_history[m_history_index] = spread;
   m_sum += spread;
   m_sum_sq += spread * spread;
   
   // Update min/max
   if(spread < m_min_observed)
      m_min_observed = spread;
   if(spread > m_max_observed)
      m_max_observed = spread;
   
   // Advance index
   m_history_index = (m_history_index + 1) % m_history_size;
   
   if(m_samples_collected < m_history_size)
      m_samples_collected++;
}

//+------------------------------------------------------------------+
//| Update statistics                                                 |
//+------------------------------------------------------------------+
void CSpreadMonitor::UpdateStatistics()
{
   if(m_samples_collected == 0)
      return;
   
   // Average
   m_analysis.average_spread = m_sum / m_samples_collected;
   
   // Standard deviation
   m_analysis.std_dev = CalculateStdDev();
   
   // Min/Max
   m_analysis.min_spread = m_min_observed;
   m_analysis.max_spread = m_max_observed;
}

//+------------------------------------------------------------------+
//| Calculate standard deviation                                      |
//+------------------------------------------------------------------+
double CSpreadMonitor::CalculateStdDev()
{
   if(m_samples_collected < 2)
      return 0;
   
   double mean = m_sum / m_samples_collected;
   double variance = (m_sum_sq / m_samples_collected) - (mean * mean);
   
   if(variance <= 0)
      return 0;
   
   return MathSqrt(variance);
}

//+------------------------------------------------------------------+
//| Analyze spread and determine status                               |
//+------------------------------------------------------------------+
void CSpreadMonitor::AnalyzeSpread()
{
   double current = GetCurrentSpread();
   double current_pips = current / m_pip_factor;
   
   m_analysis.current_spread = current;
   m_analysis.current_spread_pips = current_pips;
   
   // Need some history before making decisions
   if(m_samples_collected < 10)
   {
      m_analysis.status = SPREAD_NORMAL;
      m_analysis.size_multiplier = 1.0;
      m_analysis.score_adjustment = 0;
      m_analysis.can_trade = true;
      m_analysis.reason = "Collecting data";
      return;
   }
   
   // Calculate ratio to average
   if(m_analysis.average_spread > 0)
      m_analysis.spread_ratio = current / m_analysis.average_spread;
   else
      m_analysis.spread_ratio = 1.0;
   
   // Calculate Z-score
   if(m_analysis.std_dev > 0)
      m_analysis.z_score = (current - m_analysis.average_spread) / m_analysis.std_dev;
   else
      m_analysis.z_score = 0;
   
   //--- Determine status and adjustments

   // BLOCKED: Absolute max exceeded (check both points and pips thresholds)
   // Task 2.2: max_spread_points (default 80) is the primary gate
   if(current > (double)m_max_spread_points)
   {
      m_analysis.status = SPREAD_BLOCKED;
      m_analysis.size_multiplier = 0.0;
      m_analysis.score_adjustment = -100;
      m_analysis.can_trade = false;
      m_analysis.reason = StringFormat("Spread %.0f exceeds max %d points",
                                        current, m_max_spread_points);
      return;
   }

   // Also check pips threshold (legacy support)
   if(current_pips >= m_max_spread_pips)
   {
      m_analysis.status = SPREAD_BLOCKED;
      m_analysis.size_multiplier = 0.0;
      m_analysis.score_adjustment = -100;
      m_analysis.can_trade = false;
      m_analysis.reason = StringFormat("Spread %.1f pips exceeds max %.1f",
                                        current_pips, m_max_spread_pips);
      return;
   }
   
   // EXTREME: Very high ratio
   if(m_analysis.spread_ratio >= m_block_ratio)
   {
      m_analysis.status = SPREAD_EXTREME;
      m_analysis.size_multiplier = 0.0;
      m_analysis.score_adjustment = -50;
      m_analysis.can_trade = false;
      m_analysis.reason = StringFormat("Spread %.1fx normal (%.1f pips)", 
                                        m_analysis.spread_ratio, current_pips);
      return;
   }
   
   // HIGH: Warning ratio exceeded
   if(m_analysis.spread_ratio >= m_warning_ratio * 1.5)
   {
      m_analysis.status = SPREAD_HIGH;
      m_analysis.size_multiplier = 0.25;
      m_analysis.score_adjustment = -30;
      m_analysis.can_trade = true;  // Allow but reduced
      m_analysis.reason = StringFormat("High spread %.1fx normal", m_analysis.spread_ratio);
      return;
   }
   
   // ELEVATED: Above warning threshold
   if(m_analysis.spread_ratio >= m_warning_ratio)
   {
      m_analysis.status = SPREAD_ELEVATED;
      m_analysis.size_multiplier = 0.5;
      m_analysis.score_adjustment = -15;
      m_analysis.can_trade = true;
      m_analysis.reason = StringFormat("Elevated spread %.1fx normal", m_analysis.spread_ratio);
      return;
   }
   
   // Also check Z-score for statistical anomalies
   if(m_analysis.z_score > 3.0)
   {
      m_analysis.status = SPREAD_HIGH;
      m_analysis.size_multiplier = 0.5;
      m_analysis.score_adjustment = -20;
      m_analysis.can_trade = true;
      m_analysis.reason = StringFormat("Statistical anomaly (Z=%.1f)", m_analysis.z_score);
      return;
   }
   
   if(m_analysis.z_score > 2.0)
   {
      m_analysis.status = SPREAD_ELEVATED;
      m_analysis.size_multiplier = 0.75;
      m_analysis.score_adjustment = -10;
      m_analysis.can_trade = true;
      m_analysis.reason = StringFormat("Above average (Z=%.1f)", m_analysis.z_score);
      return;
   }
   
   // NORMAL
   m_analysis.status = SPREAD_NORMAL;
   m_analysis.size_multiplier = 1.0;
   m_analysis.score_adjustment = 0;
   m_analysis.can_trade = true;
   m_analysis.reason = "Normal";
}

//+------------------------------------------------------------------+
//| Reset statistics                                                  |
//+------------------------------------------------------------------+
void CSpreadMonitor::Reset()
{
   ArrayFill(m_spread_history, 0, m_history_size, 0);
   m_history_index = 0;
   m_samples_collected = 0;
   m_sum = 0;
   m_sum_sq = 0;
   m_min_observed = DBL_MAX;
   m_max_observed = 0;
   
   m_analysis.Reset();
   
   Print("CSpreadMonitor: Statistics reset");
}

//+------------------------------------------------------------------+
//| Print status                                                      |
//+------------------------------------------------------------------+
void CSpreadMonitor::PrintStatus()
{
   Check();
   
   Print("=== Spread Monitor Status ===");
   Print("Status: ", GetStatusString());
   Print("Current: ", DoubleToString(m_analysis.current_spread_pips, 1), " pips");
   Print("Average: ", DoubleToString(m_analysis.average_spread / m_pip_factor, 1), " pips");
   Print("Ratio: ", DoubleToString(m_analysis.spread_ratio, 2), "x");
   Print("Z-Score: ", DoubleToString(m_analysis.z_score, 2));
   Print("Min/Max: ", DoubleToString(m_analysis.min_spread / m_pip_factor, 1), " / ", 
                      DoubleToString(m_analysis.max_spread / m_pip_factor, 1), " pips");
   Print("Size Mult: ", DoubleToString(m_analysis.size_multiplier, 2));
   Print("Score Adj: ", m_analysis.score_adjustment);
   Print("Can Trade: ", m_analysis.can_trade);
   Print("Reason: ", m_analysis.reason);
   Print("Samples: ", m_samples_collected, " / ", m_history_size);
   Print("=============================");
}

//+------------------------------------------------------------------+
//| Get status string                                                 |
//+------------------------------------------------------------------+
string CSpreadMonitor::GetStatusString()
{
   switch(m_analysis.status)
   {
      case SPREAD_NORMAL:   return "NORMAL";
      case SPREAD_ELEVATED: return "ELEVATED";
      case SPREAD_HIGH:     return "HIGH";
      case SPREAD_EXTREME:  return "EXTREME";
      case SPREAD_BLOCKED:  return "BLOCKED";
      default:              return "UNKNOWN";
   }
}

//+------------------------------------------------------------------+
//| Get median spread (for statistical analysis)                      |
//+------------------------------------------------------------------+
double CSpreadMonitor::GetMedianSpread()
{
   if(m_samples_collected == 0)
      return 0.0;

   // Copy history for sorting (don't modify original)
   double sorted[];
   int count = MathMin(m_samples_collected, m_history_size);
   ArrayResize(sorted, count);

   for(int i = 0; i < count; i++)
   {
      sorted[i] = m_spread_history[i];
   }

   // Sort ascending
   ArraySort(sorted);

   // Return median
   if(count % 2 == 0)
   {
      // Even: average of two middle values
      return (sorted[count/2 - 1] + sorted[count/2]) / 2.0;
   }
   else
   {
      // Odd: middle value
      return sorted[count/2];
   }
}

//+------------------------------------------------------------------+
//| IRiskGate: Check if trading is blocked                            |
//| Blocks when current spread > max_spread_points OR status=BLOCKED  |
//+------------------------------------------------------------------+
bool CSpreadMonitor::IsBlocked(void)
{
   Check();

   // Check max_spread_points threshold
   double current = GetCurrentSpread();
   if(current > (double)m_max_spread_points)
      return true;

   // Also check status-based blocking
   return (m_analysis.status == SPREAD_BLOCKED ||
           m_analysis.status == SPREAD_EXTREME);
}

//+------------------------------------------------------------------+
//| IRiskGate: Get the reason for blocking                            |
//+------------------------------------------------------------------+
ENUM_GATE_REASON CSpreadMonitor::GetReason(void)
{
   if(!IsBlocked())
      return GATE_OK;

   return GATE_SPREAD;
}

//+------------------------------------------------------------------+
//| IRiskGate: Get human-readable reason text                         |
//+------------------------------------------------------------------+
string CSpreadMonitor::GetReasonText(void)
{
   if(!IsBlocked())
      return "OK";

   double current = GetCurrentSpread();

   // Check max_spread_points first (primary threshold)
   if(current > (double)m_max_spread_points)
   {
      return StringFormat("Spread %.0f > max %d points",
                         current, m_max_spread_points);
   }

   // Status-based message
   return StringFormat("Spread %s: %.1f pips (%.1fx normal)",
                      GetStatusString(),
                      m_analysis.current_spread_pips,
                      m_analysis.spread_ratio);
}

//+------------------------------------------------------------------+
