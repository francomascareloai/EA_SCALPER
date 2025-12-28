//+------------------------------------------------------------------+
//|                                             CRecoveryManager.mqh |
//|                           EA_SCALPER_XAUUSD - Singularity Edition |
//|                        Recovery/Hedge Entry Management for FTMO   |
//+------------------------------------------------------------------+
//| FORGE-3: Hedge/Recovery Entry Logic                              |
//|                                                                  |
//| Purpose: Allow EA to open new positions when existing position   |
//| is losing, IF a better opportunity exists.                       |
//|                                                                  |
//| Key Principles:                                                  |
//| - Recovery != Martingale (NO lot doubling)                       |
//| - Must have BETTER signal, not just any signal                   |
//| - Respects Apex DD limits at all times                           |
//| - Minimal overhead when disabled                                 |
//+------------------------------------------------------------------+
#ifndef __CRECOVERYMANAGER_MQH__
#define __CRECOVERYMANAGER_MQH__

#property copyright "EA_SCALPER_XAUUSD - Singularity Edition"
#property strict

#include "../Core/Definitions.mqh"

// === RECOVERY ENTRY TYPE ===
enum ENUM_RECOVERY_TYPE
{
   RECOVERY_NONE = 0,        // No recovery entry
   RECOVERY_SAME_DIR,        // Recovery in same direction (add to losing)
   RECOVERY_HEDGE            // Hedge in opposite direction
};

// === RECOVERY RESULT STRUCTURE ===
struct SRecoveryDecision
{
   bool                 allowed;           // Can take recovery entry
   ENUM_RECOVERY_TYPE   recovery_type;     // Type of recovery
   double               size_multiplier;   // Size multiplier (<=1.0, not martingale)
   string               reason;            // Human-readable reason

   void Reset()
   {
      allowed = false;
      recovery_type = RECOVERY_NONE;
      size_multiplier = 0.5;  // Default: half size for recovery
      reason = "";
   }
};

// === RECOVERY MANAGER CLASS ===
class CRecoveryManager
{
private:
   // Configuration
   bool     m_enabled;                      // Master enable switch
   double   m_min_loss_percent;             // Min unrealized loss % to trigger (e.g., -0.5%)
   int      m_score_boost_required;         // New signal must be X points better
   int      m_cooldown_bars;                // Bars since last entry before recovery allowed
   int      m_max_recovery_entries;         // Max recovery entries per day
   bool     m_allow_hedge;                  // Allow opposite-direction hedges
   int      m_hedge_min_score;              // Minimum score for hedge entry (TIER_A = 80)
   double   m_recovery_size_mult;           // Size multiplier for recovery (<=1.0)

   // State tracking
   int      m_recovery_count_today;         // Recoveries taken today
   datetime m_last_entry_time;              // Time of last entry
   int      m_last_entry_bar;               // Bar index of last entry
   datetime m_current_day;                  // Current trading day (for reset)

   // Symbol/magic for context
   string   m_symbol;
   int      m_magic;

   // Internal helper
   int      GetBarsSinceEntry(ENUM_TIMEFRAMES tf);
   bool     IsNewTradingDay();

public:
   CRecoveryManager();
   ~CRecoveryManager();

   //--- Initialization
   bool     Init(bool enabled = true,
                 double min_loss = -0.5,
                 int score_boost = 10,
                 int cooldown = 5,
                 int max_per_day = 2);
   void     SetSymbolMagic(string symbol, int magic) { m_symbol = symbol; m_magic = magic; }

   //--- Configuration setters
   void     SetEnabled(bool enabled) { m_enabled = enabled; }
   void     SetMinLossPercent(double pct) { m_min_loss_percent = pct; }
   void     SetScoreBoostRequired(int boost) { m_score_boost_required = boost; }
   void     SetCooldownBars(int bars) { m_cooldown_bars = bars; }
   void     SetMaxRecoveryPerDay(int max) { m_max_recovery_entries = max; }
   void     SetRecoverySizeMultiplier(double mult) { m_recovery_size_mult = MathMin(1.0, mult); }

   //--- Hedge settings (for AGGRESSIVE profile)
   void     SetAllowHedge(bool allow) { m_allow_hedge = allow; }
   void     SetHedgeMinScore(int score) { m_hedge_min_score = score; }

   //--- Core decision logic
   // Main method: should we allow a recovery/hedge entry?
   SRecoveryDecision ShouldAllowRecoveryEntry(
      double current_unrealized_pnl_pct,     // Existing position P/L as % of equity
      int    new_signal_score,                // New opportunity score (0-100)
      int    existing_signal_score,           // Score when existing position opened
      int    bars_since_entry,                // Bars since last entry
      ENUM_POSITION_TYPE existing_type,       // Current position type (BUY/SELL)
      ENUM_SIGNAL_TYPE   new_signal_type      // New signal type
   );

   // Simplified version (for when you just have P/L and new score)
   bool     CanTakeRecoveryEntry(
      double current_unrealized_pnl_pct,
      int    new_signal_score,
      int    existing_signal_score,
      int    bars_since_entry
   );

   //--- State management
   void     RecordRecoveryEntry();            // Call after successful recovery entry
   void     ResetDailyCounters();             // Call on new trading day
   void     OnTick();                         // Call every tick for daily reset check

   //--- Getters
   bool     IsEnabled() const { return m_enabled; }
   int      GetRecoveryCountToday() const { return m_recovery_count_today; }
   int      GetRemainingRecoveries() const { return m_max_recovery_entries - m_recovery_count_today; }
   double   GetRecoverySizeMultiplier() const { return m_recovery_size_mult; }

   //--- Status/Debug
   string   GetStatusString();
   void     PrintStatus();
};

// === IMPLEMENTATION ===

CRecoveryManager::CRecoveryManager()
{
   m_enabled = false;                 // Disabled by default (must explicitly enable)
   m_min_loss_percent = -0.5;         // Trigger when >= 0.5% unrealized loss
   m_score_boost_required = 10;       // New signal must be 10+ points better
   m_cooldown_bars = 5;               // Wait 5 bars between entries
   m_max_recovery_entries = 2;        // Max 2 recovery entries per day
   m_allow_hedge = false;             // Hedge disabled by default
   m_hedge_min_score = 80;            // TIER_A minimum for hedges
   m_recovery_size_mult = 0.5;        // Half size for recovery

   m_recovery_count_today = 0;
   m_last_entry_time = 0;
   m_last_entry_bar = 0;
   m_current_day = 0;

   m_symbol = _Symbol;
   m_magic = 0;
}

CRecoveryManager::~CRecoveryManager()
{
}

bool CRecoveryManager::Init(bool enabled, double min_loss, int score_boost, int cooldown, int max_per_day)
{
   m_enabled = enabled;

   // Validate and set parameters with safety clamps
   // min_loss should be negative (representing a loss)
   m_min_loss_percent = MathMin(0.0, min_loss);  // Clamp to <= 0

   m_score_boost_required = MathMax(0, score_boost);
   m_cooldown_bars = MathMax(1, cooldown);
   m_max_recovery_entries = MathMax(0, MathMin(5, max_per_day));  // Cap at 5

   // Reset state
   m_recovery_count_today = 0;
   m_last_entry_time = 0;
   m_last_entry_bar = 0;
   m_current_day = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));

   Print("CRecoveryManager: Initialized");
   PrintFormat("  Enabled: %s | Min Loss: %.2f%% | Score Boost: +%d | Cooldown: %d bars | Max/Day: %d",
               enabled ? "YES" : "NO",
               m_min_loss_percent,
               m_score_boost_required,
               m_cooldown_bars,
               m_max_recovery_entries);

   return true;
}

SRecoveryDecision CRecoveryManager::ShouldAllowRecoveryEntry(
   double current_unrealized_pnl_pct,
   int    new_signal_score,
   int    existing_signal_score,
   int    bars_since_entry,
   ENUM_POSITION_TYPE existing_type,
   ENUM_SIGNAL_TYPE   new_signal_type)
{
   SRecoveryDecision result;
   result.Reset();

   // Gate 0: Must be enabled
   if(!m_enabled)
   {
      result.reason = "Recovery disabled";
      return result;
   }

   // Gate 1: Must have losing position
   // Note: pnl_pct should be negative when losing
   if(current_unrealized_pnl_pct >= 0)
   {
      result.reason = "Position is in profit";
      return result;
   }

   // Gate 2: Loss must be significant enough
   // Example: if min_loss = -0.5%, current must be <= -0.5% (more negative)
   if(current_unrealized_pnl_pct > m_min_loss_percent)
   {
      result.reason = StringFormat("Loss %.2f%% < threshold %.2f%%",
                                    current_unrealized_pnl_pct, m_min_loss_percent);
      return result;
   }

   // Determine if this is same direction (recovery) or opposite (hedge)
   bool is_hedge = false;
   if(existing_type == POSITION_TYPE_BUY && new_signal_type == SIGNAL_SELL)
      is_hedge = true;
   if(existing_type == POSITION_TYPE_SELL && new_signal_type == SIGNAL_BUY)
      is_hedge = true;

   // Gate 3a: For HEDGE - check if allowed and meets minimum score
   if(is_hedge)
   {
      if(!m_allow_hedge)
      {
         result.reason = "Hedge entries disabled";
         return result;
      }

      if(new_signal_score < m_hedge_min_score)
      {
         result.reason = StringFormat("Hedge score %d < minimum %d (TIER_A)",
                                       new_signal_score, m_hedge_min_score);
         return result;
      }

      result.recovery_type = RECOVERY_HEDGE;
   }
   else
   {
      // Gate 3b: For RECOVERY - new signal must be BETTER than original
      if(new_signal_score < existing_signal_score + m_score_boost_required)
      {
         result.reason = StringFormat("Score %d < existing %d + boost %d = %d",
                                       new_signal_score,
                                       existing_signal_score,
                                       m_score_boost_required,
                                       existing_signal_score + m_score_boost_required);
         return result;
      }

      result.recovery_type = RECOVERY_SAME_DIR;
   }

   // Gate 4: Cooldown respected
   if(bars_since_entry < m_cooldown_bars)
   {
      result.reason = StringFormat("Cooldown: %d bars < %d required",
                                    bars_since_entry, m_cooldown_bars);
      return result;
   }

   // Gate 5: Daily limit not reached
   if(m_recovery_count_today >= m_max_recovery_entries)
   {
      result.reason = StringFormat("Daily limit reached: %d/%d",
                                    m_recovery_count_today, m_max_recovery_entries);
      return result;
   }

   // All gates passed - allow recovery entry
   result.allowed = true;
   result.size_multiplier = m_recovery_size_mult;  // ALWAYS <= 1.0 (no martingale)

   if(is_hedge)
   {
      result.reason = StringFormat("HEDGE allowed: score %d >= %d, loss %.2f%%",
                                    new_signal_score, m_hedge_min_score,
                                    current_unrealized_pnl_pct);
   }
   else
   {
      result.reason = StringFormat("RECOVERY allowed: score %d > %d+%d, loss %.2f%%",
                                    new_signal_score, existing_signal_score, m_score_boost_required,
                                    current_unrealized_pnl_pct);
   }

   return result;
}

bool CRecoveryManager::CanTakeRecoveryEntry(
   double current_unrealized_pnl_pct,
   int    new_signal_score,
   int    existing_signal_score,
   int    bars_since_entry)
{
   // Simplified version - assumes same direction recovery (not hedge)
   if(!m_enabled) return false;

   // 1. Must have losing position
   if(current_unrealized_pnl_pct >= 0) return false;

   // 2. Loss must be significant enough
   if(current_unrealized_pnl_pct > m_min_loss_percent) return false;

   // 3. New signal must be BETTER than original
   if(new_signal_score < existing_signal_score + m_score_boost_required) return false;

   // 4. Cooldown respected
   if(bars_since_entry < m_cooldown_bars) return false;

   // 5. Daily limit not reached
   if(m_recovery_count_today >= m_max_recovery_entries) return false;

   return true;
}

void CRecoveryManager::RecordRecoveryEntry()
{
   m_recovery_count_today++;
   m_last_entry_time = TimeCurrent();
   m_last_entry_bar = iBars(m_symbol, PERIOD_CURRENT);

   Print("CRecoveryManager: Recovery entry recorded. Count today: ", m_recovery_count_today,
         "/", m_max_recovery_entries);
}

void CRecoveryManager::ResetDailyCounters()
{
   m_recovery_count_today = 0;
   m_current_day = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
   Print("CRecoveryManager: Daily counters reset");
}

void CRecoveryManager::OnTick()
{
   if(IsNewTradingDay())
   {
      ResetDailyCounters();
   }
}

bool CRecoveryManager::IsNewTradingDay()
{
   datetime today = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
   if(today != m_current_day)
   {
      m_current_day = today;
      return true;
   }
   return false;
}

int CRecoveryManager::GetBarsSinceEntry(ENUM_TIMEFRAMES tf)
{
   if(m_last_entry_bar <= 0) return 9999;  // No previous entry

   int current_bars = iBars(m_symbol, tf);
   return current_bars - m_last_entry_bar;
}

string CRecoveryManager::GetStatusString()
{
   return StringFormat("Recovery: %s | Count: %d/%d | MinLoss: %.2f%% | Boost: +%d | Cooldown: %d bars",
                       m_enabled ? "ON" : "OFF",
                       m_recovery_count_today,
                       m_max_recovery_entries,
                       m_min_loss_percent,
                       m_score_boost_required,
                       m_cooldown_bars);
}

void CRecoveryManager::PrintStatus()
{
   Print("=== CRecoveryManager Status ===");
   Print("  Enabled: ", m_enabled ? "YES" : "NO");
   Print("  Recoveries today: ", m_recovery_count_today, "/", m_max_recovery_entries);
   Print("  Min loss trigger: ", DoubleToString(m_min_loss_percent, 2), "%");
   Print("  Score boost required: +", m_score_boost_required);
   Print("  Cooldown bars: ", m_cooldown_bars);
   Print("  Size multiplier: ", DoubleToString(m_recovery_size_mult, 2), "x (NOT martingale)");
   Print("  Hedge allowed: ", m_allow_hedge ? "YES" : "NO");
   if(m_allow_hedge)
      Print("  Hedge min score: ", m_hedge_min_score, " (TIER_A)");
   Print("================================");
}

#endif // __CRECOVERYMANAGER_MQH__
