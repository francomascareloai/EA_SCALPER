#ifndef FTMO_RISKMANAGER_MQH
#define FTMO_RISKMANAGER_MQH
//+------------------------------------------------------------------+
//|                                             FTMO_RiskManager.mqh |
//|                                                           Franco |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Franco"
#property link      "https://www.mql5.com"
#property strict

#include "../Core/Definitions.mqh"
#include "../Core/CDSTHelper.mqh"  // Shared DST calculation utility
#include "../Core/MathUtils.mqh"   // Shared math utilities (NormalizeLotSize)
#include <Trade/Trade.mqh>

//+------------------------------------------------------------------+
//| Class: CFTMO_RiskManager                                         |
//| Purpose: Manages risk according to Prop Firm (FTMO) rules.       |
//+------------------------------------------------------------------+
// GENIUS v1.0: Adaptive Capital Curve - FULLY IMPLEMENTED
// - Kelly criterion ACTIVE and feeding CalculateLotSize
// - 6-factor position sizing: Kelly × Regime × DD × Session × Momentum × Ratchet
// - Profit protection ratchet locks in intraday gains
// - Session-aware scaling (overlap boost, asian reduction)
// - Consecutive win/loss momentum adjustment
class CFTMO_RiskManager
{
private:
   //--- Limits
   double            m_risk_per_trade_percent;
   double            m_max_daily_loss_percent;
   double            m_max_total_loss_percent;
   double            m_soft_stop_percent;
   int               m_max_trades_per_day;
   double            m_regime_multiplier;

   //--- Adaptive Kelly (Phase 1 improvement)
   bool              m_use_adaptive_kelly;     // Toggle adaptive vs fixed sizing
   int               m_kelly_win_count;        // Wins tracked
   int               m_kelly_loss_count;       // Losses tracked
   double            m_kelly_avg_win;          // Average win amount
   double            m_kelly_avg_loss;         // Average loss amount
   double            m_kelly_min_trades;       // Min trades before Kelly activates
   
   //--- Configuration
   int               m_slippage_points;        // Configurable slippage for CloseAllPositions
   string            m_symbol;                 // Symbol filter for CloseAllPositions
   long              m_magic;                  // Magic number filter for CloseAllPositions
   
   //--- GENIUS v1.0: Adaptive Capital Curve
   bool              m_use_genius_sizing;      // Toggle 6-factor adaptive sizing
   int               m_consecutive_wins;       // Win streak counter
   int               m_consecutive_losses;     // Loss streak counter
   double            m_daily_profit_percent;   // Current day P/L as % of start equity
   int               m_gmt_offset;             // Broker GMT offset for session detection
   double            m_session_multiplier;     // Cached session factor (updated on tick)
   double            m_momentum_multiplier;    // Cached momentum factor
   double            m_ratchet_multiplier;     // Cached profit protection factor
   
   //--- Performance Profiling
   ulong             m_last_dd_check_us;       // Last CheckDrawdownLimits duration (microseconds)
   
   //--- State
   double            m_initial_equity;
   double            m_daily_start_equity;
   double            m_current_daily_loss;
   double            m_current_total_loss;
   int               m_trades_today;
   bool              m_trading_halted;
   bool              m_total_hard_breached;
   bool              m_new_trades_paused;   // Soft stop without disabling management
   datetime          m_last_day_check;
   double            m_equity_high_water;
   double            m_total_soft_stop_percent;  // 8% buffer before 10% hard limit
   string            m_gv_daily_key;
   string            m_gv_hwm_key;               // Persist high-water mark
   string            m_gv_halt_key;              // Persist halt latch
   string            m_gv_hard_breach_key;       // Persist total hard breach latch
   int               m_et_offset_hours;          // ET offset for Apex cutoff/reset
   int               m_last_day_of_year_et;      // Track day boundary in ET

public:
                     CFTMO_RiskManager();
                    ~CFTMO_RiskManager();

   //--- Initialization
   bool              Init(double risk_per_trade, double max_daily_loss, double max_total_loss, int max_trades, double soft_stop, double regime_multiplier = 1.0, int et_offset_hours = -5, string symbol = "", long magic = 0);

   //--- Core Logic
   void              OnTick();
   void              OnNewDay(); // Explicit reset hook (for timers/off-tick)
   bool              CanOpenNewTrade();
   double            CalculateLotSize(double sl_points, double regime_multiplier = 1.0);
   double            CalculateLotSizeWithRisk(double sl_points, double custom_risk_percent); // v4.1: Regime-adaptive risk
   void              OnTradeExecuted();
   void              SetRegimeMultiplier(double multiplier)
   {
      m_regime_multiplier = MathMin(MathMax(multiplier, 0.0), 3.0);
   }
   void              FlattenAllPositions() { CloseAllPositions(); }
   
   //--- Adaptive Kelly methods (Phase 1 improvement)
   void              SetUseAdaptiveKelly(bool use) { m_use_adaptive_kelly = use; }
   void              OnTradeResult(double profit_loss);  // Call after trade closes
   double            CalculateKellyFraction();           // Returns optimal f
   double            GetDrawdownAdjustedRisk();          // Risk% adjusted for current DD
   
   //--- GENIUS v1.0: Adaptive Capital Curve methods
   void              SetUseGeniusSizing(bool use) { m_use_genius_sizing = use; }
   void              SetGMTOffset(int offset) { m_gmt_offset = offset; }
   void              SetETOffset(int offset) { m_et_offset_hours = offset; }
   double            CalculateGeniusRisk();              // MASTER: 6-factor adaptive risk%
   double            GetSessionMultiplier();             // Session-aware scaling
   double            GetMomentumMultiplier();            // Win/loss streak scaling
   double            GetProfitRatchetMultiplier();       // Intraday profit protection
   void              UpdateDailyProfit();                // Recalculate daily P/L%
   int               GetConsecutiveWins() const { return m_consecutive_wins; }
   int               GetConsecutiveLosses() const { return m_consecutive_losses; }
   double            GetDailyProfitPercent() const { return m_daily_profit_percent; }
   
   //--- Getters
   bool              IsTradingHalted() const { return m_trading_halted; }
   double            GetCurrentDailyLoss() const { return m_current_daily_loss; }
   double            GetCurrentTotalLoss() const { return m_current_total_loss; }
   double            GetHighWaterMark() const { return m_equity_high_water; }
   double            GetDailyStartEquity() const { return m_daily_start_equity; }
   bool              IsSoftStopActive() const { return m_new_trades_paused; }
   bool              IsTotalHardBreached() const { return m_total_hard_breached; }
   ulong             GetLastDDCheckMicroseconds() const { return m_last_dd_check_us; }
   int               GetTradesToday() const { return m_trades_today; }
   bool              IsAfterCutoffET(int cutoff_hour_et = 16, int cutoff_minute_et = 55) const;
   
   //--- Setters
   void              SetSlippagePoints(int slippage) { m_slippage_points = MathMax(slippage, 10); }

 private:
   void              CheckNewDay();
   void              CheckDrawdownLimits();
   void              CloseAllPositions();
   void              PersistHaltState();
   int               GetETDayOfYear() const;
   datetime          GetETNow() const;
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CFTMO_RiskManager::CFTMO_RiskManager() :
   m_risk_per_trade_percent(0.5),
   m_max_daily_loss_percent(5.0),
   m_max_total_loss_percent(10.0),
   m_soft_stop_percent(4.0),
   m_max_trades_per_day(20),
   m_regime_multiplier(1.0),
   m_use_adaptive_kelly(true),
   m_kelly_win_count(0),
   m_kelly_loss_count(0),
   m_kelly_avg_win(0.0),
   m_kelly_avg_loss(0.0),
   m_kelly_min_trades(20),
   m_slippage_points(50),
   m_use_genius_sizing(true),
   m_consecutive_wins(0),
   m_consecutive_losses(0),
   m_daily_profit_percent(0.0),
   m_gmt_offset(0),
   m_session_multiplier(1.0),
   m_momentum_multiplier(1.0),
   m_ratchet_multiplier(1.0),
   m_last_dd_check_us(0),
   m_initial_equity(0.0),
   m_daily_start_equity(0.0),
   m_current_daily_loss(0.0),
   m_current_total_loss(0.0),
   m_trades_today(0),
   m_trading_halted(false),
   m_total_hard_breached(false),
   m_new_trades_paused(false),
   m_last_day_check(0),
   m_equity_high_water(0.0),
   m_total_soft_stop_percent(8.0),
   m_gv_daily_key("EA_SCALPER_DAILY_START_" + _Symbol),
   m_gv_hwm_key("EA_SCALPER_HWM_" + _Symbol),
   m_gv_halt_key("EA_SCALPER_HALT_" + _Symbol),
   m_gv_hard_breach_key("EA_SCALPER_HARD_" + _Symbol),
   m_et_offset_hours(-5),
   m_last_day_of_year_et(-1)
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CFTMO_RiskManager::~CFTMO_RiskManager()
{
}

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
bool CFTMO_RiskManager::Init(double risk_per_trade, double max_daily_loss, double max_total_loss, int max_trades, double soft_stop, double regime_multiplier/*=1.0*/, int et_offset_hours/*=-5*/, string symbol/*=""*/, long magic/*=0*/)
{
   m_risk_per_trade_percent = risk_per_trade;
   m_max_daily_loss_percent = max_daily_loss;
   m_max_total_loss_percent = max_total_loss;
   m_max_trades_per_day = max_trades;
   m_soft_stop_percent = soft_stop;
   m_regime_multiplier = MathMin(MathMax(regime_multiplier, 0.0), 3.0); // allow 0 to block trades, cap 3x
   m_et_offset_hours = et_offset_hours;

   // Store symbol/magic for filtered flatten operations
   m_symbol = (symbol == "") ? _Symbol : symbol;
   m_magic = magic;

   m_initial_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   if(m_initial_equity <= 0)
   {
      // Fallback to balance to avoid divide-by-zero during early terminal startup
      m_initial_equity = AccountInfoDouble(ACCOUNT_BALANCE);
      if(m_initial_equity <= 0)
      {
         Print("RiskManager: failed to read account equity/balance during Init");
         return false;
      }
   }

   m_daily_start_equity = m_initial_equity;
   m_equity_high_water = m_initial_equity;
   // FTMO CRITICAL: Total soft stop MUST be 8% regardless of daily soft stop
   // This is the buffer before 10% hard limit - DO NOT make this dynamic
   m_total_soft_stop_percent = 8.0;
   
   // Restore daily start equity if persisted (survive terminal restart)
   if(GlobalVariableCheck(m_gv_daily_key))
   {
      double gv_value = GlobalVariableGet(m_gv_daily_key);
      if(gv_value > 0) m_daily_start_equity = gv_value;
   }
   
   // Restore high-water mark if persisted (CRITICAL for total DD calculation)
   if(GlobalVariableCheck(m_gv_hwm_key))
   {
      double hwm_value = GlobalVariableGet(m_gv_hwm_key);
      if(hwm_value > 0) m_equity_high_water = hwm_value;
   }
   
   // Restore halt / hard-breach latches (survive terminal restart)
   if(GlobalVariableCheck(m_gv_halt_key))
   {
      double halt_flag = GlobalVariableGet(m_gv_halt_key);
      m_trading_halted = (halt_flag > 0.0);
   }
   if(GlobalVariableCheck(m_gv_hard_breach_key))
   {
      double hard_flag = GlobalVariableGet(m_gv_hard_breach_key);
      m_total_hard_breached = (hard_flag > 0.0);
      if(m_total_hard_breached)
         m_trading_halted = true; // latch if a total breach ever occurred
   }
   
   m_last_day_check = TimeCurrent();
   m_last_day_of_year_et = GetETDayOfYear();

   m_new_trades_paused = false;
   return true;
}

//+------------------------------------------------------------------+
//| OnTick: Monitor Drawdown                                         |
//+------------------------------------------------------------------+
void CFTMO_RiskManager::OnTick()
{
   CheckNewDay();
   CheckDrawdownLimits();
}

//+------------------------------------------------------------------+
//| Explicit daily reset (for timer-based invocation)                |
//+------------------------------------------------------------------+
void CFTMO_RiskManager::OnNewDay()
{
   CheckNewDay();
}

//+------------------------------------------------------------------+
//| Helper: current ET time with DST-safe calculation                |
//| Uses shared CDSTHelper for consistent DST handling               |
//+------------------------------------------------------------------+
datetime CFTMO_RiskManager::GetETNow() const
{
   // Use CDSTHelper for DST-safe ET calculation
   datetime gmt = TimeGMT();
   return CDSTHelper::UTCtoET(gmt);
}

int CFTMO_RiskManager::GetETDayOfYear() const
{
   MqlDateTime dt;
   TimeToStruct(GetETNow(), dt);
   return dt.day_of_year;
}

bool CFTMO_RiskManager::IsAfterCutoffET(int cutoff_hour_et/*=16*/, int cutoff_minute_et/*=55*/) const
{
   MqlDateTime dt;
   TimeToStruct(GetETNow(), dt);
   int minutes_now = dt.hour * 60 + dt.min;
   int minutes_cutoff = cutoff_hour_et * 60 + cutoff_minute_et;
   return minutes_now >= minutes_cutoff;
}

//+------------------------------------------------------------------+
//| Check for New Day (Reset Daily Stats)                            |
//+------------------------------------------------------------------+
void CFTMO_RiskManager::CheckNewDay()
{
   datetime current_time = TimeCurrent();
   int current_day_et = GetETDayOfYear();

   if(m_last_day_of_year_et < 0)
      m_last_day_of_year_et = current_day_et;

   if(current_day_et != m_last_day_of_year_et)
   {
      // New Day Detected
      m_daily_start_equity = AccountInfoDouble(ACCOUNT_EQUITY);
      m_trades_today = 0;
      m_current_daily_loss = 0.0;
      m_new_trades_paused = false; // allow new trades if soft-stop only
      GlobalVariableSet(m_gv_daily_key, m_daily_start_equity);
      
      // GENIUS: Reset streaks on new day (fresh start)
      m_consecutive_wins = 0;
      m_consecutive_losses = 0;
      m_daily_profit_percent = 0.0;
      
      // Reset Halt ONLY if not in Total Loss Breach
      if(!m_total_hard_breached && m_current_total_loss < m_max_total_loss_percent)
      {
         m_trading_halted = false;
         PersistHaltState();
      }
      
      m_last_day_check = current_time;
      m_last_day_of_year_et = current_day_et;
      Print("RiskManager: New Day Reset. Daily Start Equity: ", m_daily_start_equity);
   }
}

//+------------------------------------------------------------------+
//| Check Drawdown Limits                                            |
//+------------------------------------------------------------------+
void CFTMO_RiskManager::CheckDrawdownLimits()
{
   ulong start_us = GetMicrosecondCount();
   
   double current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   if(current_equity <= 0)
   {
      Print("RiskManager: current equity unavailable, skipping drawdown check");
      m_last_dd_check_us = GetMicrosecondCount() - start_us;
      return;
   }
   if(m_daily_start_equity <= 0)
      m_daily_start_equity = current_equity; // heal state to avoid division by zero
   if(m_initial_equity <= 0)
      m_initial_equity = current_equity;     // heal state to avoid division by zero
   
   // Update high-water mark (conservative FTMO total DD)
   if(current_equity > m_equity_high_water)
   {
      m_equity_high_water = current_equity;
      GlobalVariableSet(m_gv_hwm_key, m_equity_high_water);  // Persist HWM
   }
   if(m_equity_high_water <= 0)
   {
      m_equity_high_water = current_equity;
      GlobalVariableSet(m_gv_hwm_key, m_equity_high_water);
   }
   
   // 1. Calculate Daily Drawdown
   // FTMO: Daily Loss is calculated based on the starting equity of the day
   double daily_dd = 0.0;
   if(current_equity < m_daily_start_equity)
   {
      daily_dd = ((m_daily_start_equity - current_equity) / m_daily_start_equity) * 100.0;
   }
   m_current_daily_loss = daily_dd;
  
   // 2. Calculate Total Drawdown
   // FTMO: Total Loss based on high-water mark is more conservative
   double total_dd = 0.0;
   double baseline = m_equity_high_water;
   if(current_equity < baseline && baseline > 0)
   {
      total_dd = ((baseline - current_equity) / baseline) * 100.0;
   }
   m_current_total_loss = total_dd;

   // 2.5 Calculate Open Risk and Scenario Drawdown (daily DD + open risk to SLs)
   double open_risk_value   = 0.0;
   double open_risk_percent = 0.0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket))
         continue;

      string symbol = PositionGetString(POSITION_SYMBOL);
      double volume = PositionGetDouble(POSITION_VOLUME);
      double sl     = PositionGetDouble(POSITION_SL);
      double price  = PositionGetDouble(POSITION_PRICE_CURRENT);
      long   type   = (long)PositionGetInteger(POSITION_TYPE);

      if(volume <= 0.0 || sl <= 0.0)
         continue;

      double distance = 0.0;
      if(type == POSITION_TYPE_BUY && sl < price)
         distance = price - sl;
      else if(type == POSITION_TYPE_SELL && sl > price)
         distance = sl - price;
      else
         continue;

      double point      = SymbolInfoDouble(symbol, SYMBOL_POINT);
      double tick_value = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
      double tick_size  = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
      if(point <= 0.0 || tick_value <= 0.0 || tick_size <= 0.0)
         continue;

      double value_per_point = tick_value * (point / tick_size);
      if(value_per_point <= 0.0)
         continue;

      double distance_points = distance / point;
      double risk_value      = distance_points * value_per_point * volume;
      if(risk_value > 0.0)
         open_risk_value += risk_value;
   }

   if(open_risk_value > 0.0 && m_daily_start_equity > 0.0)
      open_risk_percent = (open_risk_value / m_daily_start_equity) * 100.0;

   double scenario_dd = m_current_daily_loss + open_risk_percent;
 
   // 3. Check Limits
   // 3a. Daily DD check - FLATTEN on breach (FTMO critical)
   if(m_current_daily_loss >= m_max_daily_loss_percent)
   {
      if(!m_trading_halted) Print("CRITICAL: Max Daily Loss Breached! Halting Trading and Flattening.");
      m_trading_halted = true;
      PersistHaltState();
      CloseAllPositions();  // FTMO requires flatten on daily breach
   }
   
   // 3b. Total DD buffer check (8% soft stop)
   if(m_current_total_loss >= m_total_soft_stop_percent && !m_trading_halted)
   {
      if(!m_new_trades_paused) Print("WARNING: Total DD Buffer (", DoubleToString(m_total_soft_stop_percent, 1), "%) Reached! Pausing New Trades.");
      m_new_trades_paused = true;
   }
   
   // 3c. Total DD hard limit (10% - FLATTEN)
   if(m_current_total_loss >= m_max_total_loss_percent)
   {
      if(!m_trading_halted) Print("CRITICAL: Max Total Loss Breached! Halting Trading.");
      m_trading_halted = true;
      m_total_hard_breached = true;
      PersistHaltState();
      CloseAllPositions();  // Flatten to comply
   }
 
   // 4. Soft Stop Check
   if(scenario_dd >= m_soft_stop_percent)
   {
      // Pause new trades, but keep management active
      if(!m_new_trades_paused) Print("WARNING: Soft Stop Level Reached (scenario DD=", DoubleToString(scenario_dd, 2), "%). Pausing New Trades.");
      m_new_trades_paused = true; 
   }
   else
   {
      // Clear soft-stop if losses recover intraday
      if(m_new_trades_paused && scenario_dd < m_soft_stop_percent * 0.6)
      {
         m_new_trades_paused = false;
         Print("Soft Stop cleared: scenario drawdown recovered.");
      }
   }
   
   // Record profiling (target < 1000us = 1ms)
   m_last_dd_check_us = GetMicrosecondCount() - start_us;
}

//+------------------------------------------------------------------+
//| Can Open New Trade?                                              |
//+------------------------------------------------------------------+
bool CFTMO_RiskManager::CanOpenNewTrade()
{
   if(m_trading_halted) return false;
   if(m_new_trades_paused) return false;
   if(m_trades_today >= m_max_trades_per_day) return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Calculate Lot Size based on Risk %                               |
//+------------------------------------------------------------------+
double CFTMO_RiskManager::CalculateLotSize(double sl_points, double regime_multiplier/*=1.0*/)
{
   if(sl_points <= 0) return 0.0;
   
   // Effective regime factor = external arg * internal state (defaults to 1.0)
   double effective_regime = regime_multiplier * m_regime_multiplier;
   if(effective_regime <= 0.0)
   {
      Print("RiskManager: regime multiplier <= 0, trade blocked by regime filter.");
      return 0.0;
   }
   // Clamp to avoid accidental over-leverage
   effective_regime = MathMin(effective_regime, 3.0); // cap 3x
   effective_regime = MathMax(effective_regime, 0.1); // floor 0.1x

   // Use equity to incorporate floating P/L in live risk
   double account_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   
   // GENIUS v1.0: Use 6-factor adaptive risk OR fallback to fixed
   double risk_percent;
   if(m_use_genius_sizing)
   {
      risk_percent = CalculateGeniusRisk();
      // Log only when significantly different from base
      if(MathAbs(risk_percent - m_risk_per_trade_percent) > 0.1)
         Print("GENIUS sizing: ", DoubleToString(risk_percent, 2), "% (base ", 
               DoubleToString(m_risk_per_trade_percent, 2), "%)");
   }
   else
   {
      risk_percent = m_risk_per_trade_percent;
   }
   
   double risk_amount = account_equity * (risk_percent / 100.0);
   
   double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

   // Division-by-zero guard: tick_size and tick_value must be valid
   if(MathAbs(tick_size) < 0.00001 || MathAbs(tick_value) < 0.00001)
   {
      Print("FTMO_RiskManager: tick_size or tick_value is zero - cannot calculate lot size");
      return 0.0;
   }

   // Lot = Risk / (SL_Points * TickValue_Per_Point)
   // SL is in points. TickValue is per Tick.
   // Value per point = TickValue * (Point / TickSize)

   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double value_per_point = tick_value * (point / tick_size);

   // Division-by-zero guard: value_per_point must be valid
   if(MathAbs(value_per_point) < 0.00001)
   {
      Print("FTMO_RiskManager: value_per_point is zero - cannot calculate lot size");
      return 0.0;
   }

   double lot_size = risk_amount / (sl_points * value_per_point);

   // Apply regime multiplier (0.5 for noisy, 1.0 for prime, 0 blocks trade)
   lot_size *= effective_regime;

   // Normalize Lot Size
   double min_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double max_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double step_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   // Division-by-zero guard: step_lot must be valid
   if(MathAbs(step_lot) < 0.00001)
   {
      Print("FTMO_RiskManager: step_lot is zero - cannot normalize lot size");
      return 0.0;
   }

   lot_size = MathFloor(lot_size / step_lot) * step_lot;
   
   // Enforce risk ceiling when min lot exceeds desired risk
   double risk_at_min = sl_points * value_per_point * min_lot;
   if(lot_size < min_lot)
      lot_size = min_lot;
   if(risk_at_min > risk_amount * 1.02) // allow small slippage
   {
      Print("RiskManager: min lot (", min_lot, ") breaches risk cap. Skipping entry.");
      return 0.0;
   }

   if(lot_size > max_lot) lot_size = max_lot;
   
   return lot_size;
}

//+------------------------------------------------------------------+
//| v4.1: Calculate Lot Size with Custom Risk % (GENIUS)             |
//| Used by Regime-Adaptive Strategy to enforce regime-specific risk |
//+------------------------------------------------------------------+
double CFTMO_RiskManager::CalculateLotSizeWithRisk(double sl_points, double custom_risk_percent)
{
   if(sl_points <= 0 || custom_risk_percent <= 0) return 0.0;

   // Use equity to incorporate floating P/L in live risk
   double account_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double risk_amount = account_equity * (custom_risk_percent / 100.0);

   double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

   // Division-by-zero guard: tick_size and tick_value must be valid
   if(MathAbs(tick_size) < 0.00001 || MathAbs(tick_value) < 0.00001)
   {
      Print("FTMO_RiskManager: tick_size or tick_value is zero - cannot calculate lot size");
      return 0.0;
   }

   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double value_per_point = tick_value * (point / tick_size);

   // Division-by-zero guard: value_per_point must be valid
   if(MathAbs(value_per_point) < 0.00001)
   {
      Print("FTMO_RiskManager: value_per_point is zero - cannot calculate lot size");
      return 0.0;
   }

   double lot_size = risk_amount / (sl_points * value_per_point);

   // Normalize Lot Size
   double min_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double max_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double step_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   // Division-by-zero guard: step_lot must be valid
   if(MathAbs(step_lot) < 0.00001)
   {
      Print("FTMO_RiskManager: step_lot is zero - cannot normalize lot size");
      return 0.0;
   }

   lot_size = MathFloor(lot_size / step_lot) * step_lot;

   // Enforce minimum lot
   // CRITICAL FIX: If min_lot exceeds computed lot, the trade would violate risk cap
   // Return 0 to reject trade rather than force min_lot and breach risk
   if(lot_size < min_lot)
   {
      // Division-by-zero guard for account_equity
      if(MathAbs(account_equity) < 0.01)
      {
         Print("FTMO_RiskManager: account_equity is zero - cannot calculate risk percent");
         return 0.0;
      }
      double min_lot_risk_amount = min_lot * sl_points * value_per_point;
      double min_lot_risk_percent = (min_lot_risk_amount / account_equity) * 100.0;
      Print("RiskManager: min_lot=", DoubleToString(min_lot, 2), " would impose ",
            DoubleToString(min_lot_risk_percent, 2), "% risk, exceeds target ",
            DoubleToString(custom_risk_percent, 2), "% - REJECTING trade");
      return 0.0;  // Block trade to preserve risk cap
   }

   // Enforce maximum lot
   if(lot_size > max_lot)
      lot_size = max_lot;
   
   return lot_size;
}

//+------------------------------------------------------------------+
//| Update Stats after Trade Execution                               |
//+------------------------------------------------------------------+
void CFTMO_RiskManager::OnTradeExecuted()
{
   m_trades_today++;
}

//+------------------------------------------------------------------+
//| Track trade result for Kelly calculation (Phase 1 improvement)   |
//+------------------------------------------------------------------+
void CFTMO_RiskManager::OnTradeResult(double profit_loss)
{
   if(profit_loss > 0)
   {
      // Update win statistics
      double total_wins = m_kelly_avg_win * m_kelly_win_count + profit_loss;
      m_kelly_win_count++;
      m_kelly_avg_win = total_wins / m_kelly_win_count;
      
      // GENIUS: Track consecutive wins
      m_consecutive_wins++;
      m_consecutive_losses = 0;  // Reset loss streak
      
      if(m_consecutive_wins >= 2)
         Print("GENIUS: Win streak ", m_consecutive_wins, " - Momentum multiplier: ", 
               DoubleToString(GetMomentumMultiplier(), 2));
   }
   else if(profit_loss < 0)
   {
      // Update loss statistics (store as positive value)
      double total_losses = m_kelly_avg_loss * m_kelly_loss_count + MathAbs(profit_loss);
      m_kelly_loss_count++;
      m_kelly_avg_loss = total_losses / m_kelly_loss_count;
      
      // GENIUS: Track consecutive losses
      m_consecutive_losses++;
      m_consecutive_wins = 0;  // Reset win streak
      
      if(m_consecutive_losses >= 2)
         Print("GENIUS: Loss streak ", m_consecutive_losses, " - Reducing size to ", 
               DoubleToString(GetMomentumMultiplier() * 100.0, 0), "%");
   }

}

//+------------------------------------------------------------------+
//| Calculate Kelly Fraction (Phase 1 improvement)                    |
//| Kelly f* = (W*R - L) / R where:                                  |
//| W = win rate, L = loss rate, R = avg_win/avg_loss                |
//+------------------------------------------------------------------+
double CFTMO_RiskManager::CalculateKellyFraction()
{
   int total_trades = m_kelly_win_count + m_kelly_loss_count;
   
   // Need minimum trades for reliable estimate
   if(total_trades < m_kelly_min_trades)
      return m_risk_per_trade_percent / 100.0;  // Fallback to fixed
   
   // Avoid division by zero
   if(m_kelly_avg_loss <= 0 || m_kelly_loss_count == 0)
      return m_risk_per_trade_percent / 100.0;
   
   double win_rate = (double)m_kelly_win_count / total_trades;
   double loss_rate = 1.0 - win_rate;
   double win_loss_ratio = m_kelly_avg_win / m_kelly_avg_loss;
   
   // Kelly formula: f* = (W*R - L) / R = W - L/R
   double kelly = (win_rate * win_loss_ratio - loss_rate) / win_loss_ratio;
   
   // Half-Kelly for safety (reduces volatility of returns)
   kelly *= 0.5;
   
   // Clamp to reasonable range [0.1%, 3%]
   kelly = MathMax(0.001, MathMin(0.03, kelly));
   
   return kelly;
}

//+------------------------------------------------------------------+
//| Get risk% adjusted for current drawdown (Phase 1 improvement)    |
//| Reduces position size during drawdown to protect capital         |
//+------------------------------------------------------------------+
double CFTMO_RiskManager::GetDrawdownAdjustedRisk()
{
   double base_risk = m_risk_per_trade_percent;
   
   // Use Kelly if enabled and we have enough data
   if(m_use_adaptive_kelly)
   {
      double kelly = CalculateKellyFraction();
      base_risk = kelly * 100.0;  // Convert to percentage
   }
   
   // Apply drawdown adjustment
   double dd_factor = 1.0;
   
   if(m_current_daily_loss >= 3.0)
   {
      // DD >= 3%: reduce to 25% of normal size
      dd_factor = 0.25;
      Print("RiskManager: DD >= 3%, reducing position size to 25%");
   }
   else if(m_current_daily_loss >= 2.0)
   {
      // DD >= 2%: reduce to 50% of normal size
      dd_factor = 0.50;
      Print("RiskManager: DD >= 2%, reducing position size to 50%");
   }
   else if(m_current_daily_loss >= 1.0)
   {
      // DD >= 1%: reduce to 75% of normal size
      dd_factor = 0.75;
   }
   
   // Also reduce if total DD is high
   if(m_current_total_loss >= 6.0)
   {
      dd_factor *= 0.5;  // Additional 50% reduction
      Print("RiskManager: Total DD >= 6%, additional 50% reduction");
   }
   else if(m_current_total_loss >= 4.0)
   {
      dd_factor *= 0.75;  // Additional 25% reduction
   }
   
   return base_risk * dd_factor;
}

//+------------------------------------------------------------------+
//| GENIUS v1.0: Calculate 6-factor adaptive risk percentage         |
//| Formula: BASE_KELLY × DD_FACTOR × SESSION × MOMENTUM × RATCHET   |
//+------------------------------------------------------------------+
double CFTMO_RiskManager::CalculateGeniusRisk()
{
   // 1. BASE RISK: Start with Kelly-adjusted or fixed risk
   double base_risk = GetDrawdownAdjustedRisk();  // Already includes Kelly + DD factors
   
   // 2. SESSION FACTOR: Adjust for trading session quality
   m_session_multiplier = GetSessionMultiplier();
   
   // 3. MOMENTUM FACTOR: Adjust for win/loss streaks
   m_momentum_multiplier = GetMomentumMultiplier();
   
   // 4. PROFIT RATCHET: Protect intraday gains
   UpdateDailyProfit();
   m_ratchet_multiplier = GetProfitRatchetMultiplier();
   
   // 5. COMBINE ALL FACTORS
   double genius_risk = base_risk * m_session_multiplier * m_momentum_multiplier * m_ratchet_multiplier;
   
   // 6. SAFETY CLAMPS: Never exceed 1.5% or go below 0.1%
   genius_risk = MathMax(0.1, MathMin(1.5, genius_risk));
   
   return genius_risk;
}

//+------------------------------------------------------------------+
//| GENIUS: Session-aware position scaling                           |
//| Peak hours = bigger size, dead hours = smaller size              |
//+------------------------------------------------------------------+
double CFTMO_RiskManager::GetSessionMultiplier()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   // Convert to GMT (adjust for broker offset)
   int gmt_hour = (dt.hour - m_gmt_offset + 24) % 24;
   
   // Session scoring based on XAUUSD liquidity/volatility
   // London/NY Overlap (12-16 GMT): BEST - highest liquidity, tightest spreads
   if(gmt_hour >= 12 && gmt_hour < 16)
      return 1.20;  // +20% size in overlap
   
   // London Session (07-12 GMT): GOOD - institutional flow
   if(gmt_hour >= 7 && gmt_hour < 12)
      return 1.10;  // +10% size
   
   // NY Session (16-21 GMT): GOOD - high volume
   if(gmt_hour >= 16 && gmt_hour < 21)
      return 1.00;  // Standard size
   
   // Late NY / Early Asian (21-00 GMT): CAUTION - liquidity thinning
   if(gmt_hour >= 21 || gmt_hour < 1)
      return 0.70;  // -30% size
   
   // Asian Session (01-07 GMT): LOW - wide spreads, choppy
   if(gmt_hour >= 1 && gmt_hour < 7)
      return 0.50;  // -50% size (XAUUSD is quiet)
   
   return 1.0;  // Default
}

//+------------------------------------------------------------------+
//| GENIUS: Win/loss streak momentum adjustment                      |
//| Hot hand = slightly bigger, cold streak = much smaller           |
//+------------------------------------------------------------------+
double CFTMO_RiskManager::GetMomentumMultiplier()
{
   // WINNING STREAK: Capitalize on momentum (conservative)
   if(m_consecutive_wins >= 4)
      return 1.15;  // +15% after 4+ wins
   else if(m_consecutive_wins >= 2)
      return 1.08;  // +8% after 2-3 wins
   
   // LOSING STREAK: Protect capital aggressively
   if(m_consecutive_losses >= 4)
      return 0.40;  // -60% after 4+ losses (near stopping)
   else if(m_consecutive_losses >= 3)
      return 0.55;  // -45% after 3 losses
   else if(m_consecutive_losses >= 2)
      return 0.70;  // -30% after 2 losses
   else if(m_consecutive_losses >= 1)
      return 0.85;  // -15% after 1 loss
   
   return 1.0;  // No streak = standard
}

//+------------------------------------------------------------------+
//| GENIUS: Profit protection ratchet                                |
//| Lock in gains as daily profit grows - asymmetric return profile  |
//+------------------------------------------------------------------+
double CFTMO_RiskManager::GetProfitRatchetMultiplier()
{
   // If in drawdown, no ratchet (already handled by DD factor)
   if(m_daily_profit_percent <= 0.0)
      return 1.0;
   
   // PROFIT PROTECTION TIERS
   // The more you're up, the more you protect
   if(m_daily_profit_percent >= 3.0)
   {
      // Up 3%+: Coast mode - protect most gains
      return 0.50;  // 50% size to lock in profit
   }
   else if(m_daily_profit_percent >= 2.0)
   {
      // Up 2-3%: Conservative mode
      return 0.65;  // 65% size
   }
   else if(m_daily_profit_percent >= 1.0)
   {
      // Up 1-2%: Slightly cautious
      return 0.80;  // 80% size
   }
   else if(m_daily_profit_percent >= 0.5)
   {
      // Up 0.5-1%: Small buffer protection
      return 0.90;  // 90% size
   }
   
   return 1.0;  // Standard until 0.5% profit
}

//+------------------------------------------------------------------+
//| GENIUS: Update daily profit percentage                           |
//+------------------------------------------------------------------+
void CFTMO_RiskManager::UpdateDailyProfit()
{
   if(m_daily_start_equity <= 0)
   {
      m_daily_profit_percent = 0.0;
      return;
   }
   
   double current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double daily_change = current_equity - m_daily_start_equity;
   m_daily_profit_percent = (daily_change / m_daily_start_equity) * 100.0;
}

//+------------------------------------------------------------------+
//| Close all positions on the current symbol (FTMO hard stop)       |
//+------------------------------------------------------------------+
void CFTMO_RiskManager::CloseAllPositions()
{
   CTrade tradeCloser;  // Non-static - create fresh each call to avoid state leak
   tradeCloser.SetDeviationInPoints(m_slippage_points);  // Configurable slippage
   tradeCloser.SetTypeFilling(ORDER_FILLING_IOC);

   const int MAX_RETRIES = 3;
   const int RETRY_DELAY_MS = 100;

   // Flatten only positions matching this EA's symbol and magic
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket))
         continue;

      // CRITICAL FIX: Filter by symbol and magic to avoid closing unrelated positions
      if(PositionGetString(POSITION_SYMBOL) != m_symbol)
         continue;
      if(m_magic != 0 && PositionGetInteger(POSITION_MAGIC) != m_magic)
         continue;

      // Retry loop for robustness
      bool closed = false;
      for(int attempt = 1; attempt <= MAX_RETRIES && !closed; attempt++)
      {
         if(tradeCloser.PositionClose(ticket))
         {
            closed = true;
            Print("RiskManager: position #", ticket, " closed on attempt ", attempt);
         }
         else
         {
            uint retcode = tradeCloser.ResultRetcode();
            Print("RiskManager: close attempt ", attempt, "/", MAX_RETRIES,
                  " failed for #", ticket, " retcode: ", retcode,
                  " desc: ", tradeCloser.ResultRetcodeDescription());

            // Retry on requote/price changed
            if(retcode == TRADE_RETCODE_REQUOTE || retcode == TRADE_RETCODE_PRICE_CHANGED)
            {
               Sleep(RETRY_DELAY_MS);
               continue;
            }
            else
               break;  // Don't retry on other errors
         }
      }

      if(!closed)
         Print("RiskManager: CRITICAL - failed to close position #", ticket, " after ", MAX_RETRIES, " attempts!");
   }
}

//+------------------------------------------------------------------+
//| Persist halt and breach state                                    |
//+------------------------------------------------------------------+
void CFTMO_RiskManager::PersistHaltState()
{
   GlobalVariableSet(m_gv_halt_key, m_trading_halted ? 1.0 : 0.0);
   GlobalVariableSet(m_gv_hard_breach_key, m_total_hard_breached ? 1.0 : 0.0);
}

#endif // FTMO_RISKMANAGER_MQH
