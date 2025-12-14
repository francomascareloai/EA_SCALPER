//+------------------------------------------------------------------+
//|                                               CTradeManager.mqh |
//|                           EA_SCALPER_XAUUSD - Singularity Edition |
//|                        Trade Management State Machine for FTMO    |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD - Singularity Edition"
#property strict

#include <Trade\Trade.mqh>
#include "../Core/Definitions.mqh"
#include "../Analysis/CRegimeDetector.mqh"     // v4.1: For SRegimeStrategy
#include "../Analysis/CStructureAnalyzer.mqh"  // v4.2: For structure-based trailing
#include "../Analysis/CFootprintAnalyzer.mqh"  // v4.2: For footprint exit signals
#include "../Signal/CConfluenceScorer.mqh"     // v4.2: For Bayesian learning callback (full include needed)
#include "../Risk/FTMO_RiskManager.mqh"        // v4.2: For Kelly learning callback

// === TRADE STATE ENUMERATION ===
enum ENUM_TRADE_STATE
{
   TRADE_STATE_IDLE = 0,           // No active trade
   TRADE_STATE_ENTRY_PENDING,      // Waiting for entry confirmation
   TRADE_STATE_POSITION_OPEN,      // Position is open
   TRADE_STATE_BREAKEVEN,          // At breakeven (SL moved to entry)
   TRADE_STATE_PARTIAL_TP,         // Partial TP taken
   TRADE_STATE_TRAILING,           // Trailing stop active
   TRADE_STATE_CLOSING,            // In process of closing
   TRADE_STATE_CLOSED              // Trade completed
};

// === TRADE MANAGEMENT MODE ===
enum ENUM_MANAGEMENT_MODE
{
   MGMT_FIXED_RR,                  // Fixed R:R ratio
   MGMT_TRAILING_ATR,              // ATR-based trailing
   MGMT_PARTIAL_TP,                // Multiple TPs with partial close
   MGMT_DYNAMIC                    // Dynamic based on market conditions
};

// === TRADE INFO STRUCTURE ===
struct STradeInfo
{
   ulong                ticket;              // Position ticket
   ENUM_TRADE_STATE     state;               // Current state
   ENUM_POSITION_TYPE   type;                // BUY or SELL
   double               entry_price;         // Entry price
   double               initial_sl;          // Initial stop loss
   double               current_sl;          // Current stop loss
   double               tp1;                 // Take profit 1 (partial)
   double               tp2;                 // Take profit 2 (partial)
   double               tp3;                 // Take profit 3 (final)
   double               initial_lots;        // Initial position size
   double               current_lots;        // Current position size
   double               highest_price;       // Highest price since entry (for trailing)
   double               lowest_price;        // Lowest price since entry (for trailing)
   datetime             entry_time;          // Entry timestamp
   double               entry_score;         // Confluence score at entry
   double               realized_pnl;        // Realized P/L from partials
   int                  partials_taken;      // Number of partial TPs taken
   string               entry_reason;        // Entry reason for logging
};

// === TRADE MANAGER CLASS ===
class CTradeManager
{
private:
   // Trade object
   CTrade               m_trade;
   
   // Active trade info
   STradeInfo           m_active_trade;
   bool                 m_has_active_trade;
   
   // Settings
   int                  m_magic_number;
   int                  m_slippage;
   string               m_symbol;
   ENUM_MANAGEMENT_MODE m_mgmt_mode;
   
   // Management parameters
   double               m_breakeven_trigger;     // R multiple to move to BE (e.g., 1.0 = 1R)
   double               m_partial1_trigger;      // R multiple for first partial (e.g., 1.5R)
   double               m_partial1_percent;      // Percent to close at TP1 (e.g., 0.33)
   double               m_partial2_trigger;      // R multiple for second partial
   double               m_partial2_percent;      // Percent to close at TP2
   double               m_trailing_start;        // R multiple to start trailing
   double               m_trailing_step;         // ATR multiple for trailing step
   
   // ATR for dynamic calculations
   int                  m_atr_handle;
   double               m_current_atr;
   
   // GENIUS FIX P2: Race condition guard - prevents reentrant operations
   bool                 m_operation_in_progress;
   
   // GENIUS FIX P3: Persistence keys for restart recovery
   string               m_gv_partials_key;       // GlobalVariable key for partials_taken
   string               m_gv_state_key;          // GlobalVariable key for trade state
   string               m_gv_initial_lots_key;   // GlobalVariable key for initial lots
   string               m_gv_initial_sl_key;     // GlobalVariable key for initial SL (risk reference)
   string               m_gv_highest_price_key;  // GlobalVariable key for highest price (trailing)
   string               m_gv_lowest_price_key;   // GlobalVariable key for lowest price (trailing)
   string               m_gv_trade_start_bar_key; // v4.2: GlobalVariable key for trade start bar time
   
   // v4.1: Regime-Adaptive Strategy (GENIUS)
   SRegimeStrategy      m_regime_strategy;       // Current regime strategy parameters
   bool                 m_regime_strategy_active; // Is regime strategy being used?
   bool                 m_trailing_enabled;       // Trailing enabled for this trade
   bool                 m_time_exit_enabled;      // Time exit enabled for this trade
   int                  m_max_trade_bars;         // Maximum bars to hold
   datetime             m_trade_start_bar_time;   // Bar time when trade started
   
   // v4.2: GENIUS Structure-Based Trailing (FASE 2)
   CStructureAnalyzer*  m_structure;             // Structure analyzer for swing levels
   bool                 m_use_structure_trail;   // Use structure-based trailing
   double               m_structure_buffer_atr;  // Buffer from swing level (ATR mult)
   
   // v4.2: GENIUS Footprint Exit Integration (FASE 3)
   CFootprintAnalyzer*  m_footprint;             // Footprint analyzer for exit signals
   bool                 m_use_footprint_exit;    // Use footprint for exit decisions
   int                  m_absorption_exit_conf;  // Min confidence for absorption exit
   
   // v4.2: GENIUS Bayesian Learning Callback (FASE 3)
   CConfluenceScorer*   m_confluence_scorer;     // For RecordTradeOutcome callback
   bool                 m_use_learning_callback; // Enable learning on trade close
   
   // v4.2: GENIUS Kelly Learning Callback (RiskManager integration)
   CFTMO_RiskManager*   m_risk_manager;          // For OnTradeResult callback (Kelly stats)
   bool                 m_use_kelly_callback;    // Enable Kelly learning on trade close
   
   // Internal helper for GV persistence
   void                 PersistState();
   void                 LoadPersistedState();
   
   // Internal methods
   void                 UpdateATR();
   double               GetCurrentRMultiple();
   double               CalculateTrailingStop();
   bool                 MoveToBreakeven();
   bool                 TakePartialProfit(double percent, int partial_num);
   bool                 UpdateTrailingStop();
   void                 LogStateChange(ENUM_TRADE_STATE old_state, ENUM_TRADE_STATE new_state);
   bool                 ModifyPositionWithRetry(ulong ticket, double new_sl, double new_tp);
   bool                 ClosePositionWithRetry(ulong ticket);
   
   // v4.2: GENIUS Structure and Footprint helpers (FASE 2 & 3)
   double               GetStructureTrailLevel();   // Get swing-based trail level
   bool                 CheckFootprintExit();       // Check for footprint exit signals
   
public:
   CTradeManager();
   ~CTradeManager();
   
   // Initialization
   bool                 Init(int magic, int slippage, string symbol = "");
   void                 SetManagementMode(ENUM_MANAGEMENT_MODE mode);
   void                 SetBreakevenTrigger(double r_multiple) { m_breakeven_trigger = r_multiple; }
   void                 SetPartialTP1(double r_mult, double pct) { m_partial1_trigger = r_mult; m_partial1_percent = pct; }
   void                 SetPartialTP2(double r_mult, double pct) { m_partial2_trigger = r_mult; m_partial2_percent = pct; }
   void                 SetTrailingParams(double start_r, double step_atr) { m_trailing_start = start_r; m_trailing_step = step_atr; }
   
   // Quick config: 40/30/30 split at specified R levels
   void                 ConfigurePartials(double tp1_r, double tp2_r, double tp1_pct = 0.40, double tp2_pct = 0.50)
   {
      m_partial1_trigger = tp1_r;
      m_partial1_percent = tp1_pct;
      m_partial2_trigger = tp2_r;
      m_partial2_percent = tp2_pct;
      m_trailing_start = tp2_r;
   }
   
   // v4.1: Apply regime-specific strategy parameters (GENIUS)
   // Call this BEFORE opening a trade to configure management for current regime
   void                 ApplyRegimeStrategy(const SRegimeStrategy &strategy)
   {
      m_regime_strategy = strategy;
      m_regime_strategy_active = true;
      
      // Apply breakeven trigger
      m_breakeven_trigger = strategy.be_trigger_r;
      
      // Apply partial TP parameters
      m_partial1_trigger = strategy.tp1_r;
      m_partial1_percent = strategy.partial1_pct;
      m_partial2_trigger = strategy.tp2_r;
      m_partial2_percent = strategy.partial2_pct;
      
      // Apply trailing parameters
      m_trailing_enabled = strategy.use_trailing;
      if(strategy.use_trailing)
      {
         m_trailing_start = strategy.trailing_start_r;
         m_trailing_step = strategy.trailing_step_atr;
      }
      
      // Apply time exit parameters
      m_time_exit_enabled = strategy.use_time_exit;
      m_max_trade_bars = strategy.max_bars;
      
      // Log the strategy being applied
      PrintFormat("CTradeManager: Applied %s strategy - BE:%.1fR, TP1:%.1fR@%.0f%%, TP2:%.1fR@%.0f%%, Trail:%s, TimeExit:%s(%d bars)",
         strategy.philosophy,
         strategy.be_trigger_r,
         strategy.tp1_r, strategy.partial1_pct * 100,
         strategy.tp2_r, strategy.partial2_pct * 100,
         strategy.use_trailing ? "YES" : "NO",
         strategy.use_time_exit ? "YES" : "NO",
         strategy.max_bars);
   }
   
   // Reset to default (non-regime) management
   void                 ResetToDefaultStrategy()
   {
      m_regime_strategy_active = false;
      m_trailing_enabled = true;  // Default: trailing on
      m_time_exit_enabled = false;
      m_max_trade_bars = 100;
      
      // Restore defaults
      m_breakeven_trigger = 1.0;
      m_partial1_trigger = 1.5;
      m_partial1_percent = 0.40;
      m_partial2_trigger = 2.5;
      m_partial2_percent = 0.50;
      m_trailing_start = 2.5;
      m_trailing_step = 0.5;
   }
   
   // Get current strategy info
   bool                 IsRegimeStrategyActive() { return m_regime_strategy_active; }
   SRegimeStrategy      GetCurrentStrategy() { return m_regime_strategy; }
   
   // v4.2: GENIUS Analyzer Attachments (FASE 2 & 3)
   void AttachStructureAnalyzer(CStructureAnalyzer* structure) 
   { 
      m_structure = structure; 
      m_use_structure_trail = (structure != NULL);
      if(m_use_structure_trail)
         Print("CTradeManager: Structure analyzer attached - Structure-based trailing ENABLED");
   }
   
   void AttachFootprintAnalyzer(CFootprintAnalyzer* footprint)
   {
      m_footprint = footprint;
      m_use_footprint_exit = (footprint != NULL);
      if(m_use_footprint_exit)
         Print("CTradeManager: Footprint analyzer attached - Footprint exits ENABLED");
   }
   
   void SetStructureTrailBuffer(double atr_mult) { m_structure_buffer_atr = atr_mult; }
   void SetAbsorptionExitConfidence(int conf) { m_absorption_exit_conf = conf; }
   bool IsStructureTrailingEnabled() { return m_use_structure_trail && m_structure != NULL; }
   bool IsFootprintExitEnabled() { return m_use_footprint_exit && m_footprint != NULL; }
   
   // v4.2: GENIUS Bayesian Learning Integration
   void AttachConfluenceScorer(CConfluenceScorer* scorer)
   {
      m_confluence_scorer = scorer;
      m_use_learning_callback = (scorer != NULL);
      if(m_use_learning_callback)
         Print("CTradeManager: Confluence Scorer attached - Bayesian Learning ENABLED");
   }
   
   // v4.2: GENIUS Kelly Learning Integration (RiskManager)
   void AttachRiskManager(CFTMO_RiskManager* rm)
   {
      m_risk_manager = rm;
      m_use_kelly_callback = (rm != NULL);
      if(m_use_kelly_callback)
         Print("CTradeManager: RiskManager attached - Kelly Learning ENABLED");
   }
   
   // Trade operations
   bool                 OpenTrade(ENUM_SIGNAL_TYPE signal, double lots, double sl, double tp, 
                                  double score, string reason);
   bool                 OpenTradeWithTPs(ENUM_SIGNAL_TYPE signal, double lots, double sl,
                                         double tp1, double tp2, double tp3,
                                         double score, string reason);
   bool                 CloseTrade(string reason = "Manual close");
   bool                 ClosePartial(double percent, string reason = "Partial TP");
   
   // State machine update (call on every tick)
   void                 OnTick();
   
   // Accessors
   bool                 HasActiveTrade() { return m_has_active_trade; }
   ENUM_TRADE_STATE     GetState() { return m_active_trade.state; }
   STradeInfo           GetTradeInfo() { return m_active_trade; }
   double               GetUnrealizedPnL();
   double               GetTotalPnL();
   
   // Position sync (after EA restart)
   bool                 SyncWithExistingPosition();
};

// === IMPLEMENTATION ===

CTradeManager::CTradeManager()
{
   m_has_active_trade = false;
   m_magic_number = 0;
   m_slippage = 50;
   m_symbol = _Symbol;
   m_mgmt_mode = MGMT_PARTIAL_TP;
   m_atr_handle = INVALID_HANDLE;
   m_current_atr = 0;
   
   // GENIUS FIX P2: Initialize race condition guard
   m_operation_in_progress = false;
   
   // GENIUS FIX P3: Initialize GV keys (will be set properly in Init)
   m_gv_partials_key = "";
   m_gv_state_key = "";
   m_gv_initial_lots_key = "";
   m_gv_initial_sl_key = "";
   m_gv_highest_price_key = "";
   m_gv_lowest_price_key = "";
   m_gv_trade_start_bar_key = "";  // v4.2
   
   // v4.1: Initialize regime strategy variables (GENIUS)
   m_regime_strategy_active = false;
   m_trailing_enabled = true;       // Default: trailing ON
   m_time_exit_enabled = false;     // Default: time exit OFF
   m_max_trade_bars = 100;          // Default: 100 bars max
   m_trade_start_bar_time = 0;
   ZeroMemory(m_regime_strategy);
   
   // v4.2: Initialize GENIUS extensions (FASE 2 & 3)
   m_structure = NULL;
   m_use_structure_trail = false;
   m_structure_buffer_atr = 0.2;    // Default: 0.2 ATR buffer from swing level
   m_footprint = NULL;
   m_use_footprint_exit = false;
   m_absorption_exit_conf = 60;     // Default: 60% confidence for absorption exit
   
   // v4.2: GENIUS Bayesian Learning
   m_confluence_scorer = NULL;
   m_use_learning_callback = false;
   
   // v4.2: GENIUS Kelly Learning
   m_risk_manager = NULL;
   m_use_kelly_callback = false;
   
   // Default management parameters (FTMO optimized)
   // Strategy: 40% at TP1, 30% at TP2, trail remaining 30%
   m_breakeven_trigger = 1.0;      // Move to BE at 1R profit
   m_partial1_trigger = 1.5;       // First partial at 1.5R
   m_partial1_percent = 0.40;      // Close 40% at TP1
   m_partial2_trigger = 2.5;       // Second partial at 2.5R
   m_partial2_percent = 0.50;      // Close 50% of remaining (= 30% of original)
   m_trailing_start = 2.5;         // Start trailing after TP2
   m_trailing_step = 0.5;          // Trail by 0.5 ATR
   
   ZeroMemory(m_active_trade);
}

CTradeManager::~CTradeManager()
{
   if(m_atr_handle != INVALID_HANDLE)
      IndicatorRelease(m_atr_handle);
}

bool CTradeManager::Init(int magic, int slippage, string symbol)
{
   m_magic_number = magic;
   m_slippage = slippage;
   m_symbol = (symbol == "") ? _Symbol : symbol;
   
   m_trade.SetExpertMagicNumber(magic);
   m_trade.SetDeviationInPoints(slippage);
   m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   
   // GENIUS FIX P3: Setup GlobalVariable keys for state persistence
   string base_key = "TM_" + m_symbol + "_" + IntegerToString(magic) + "_";
   m_gv_partials_key = base_key + "PARTIALS";
   m_gv_state_key = base_key + "STATE";
   m_gv_initial_lots_key = base_key + "INITLOTS";
   m_gv_initial_sl_key = base_key + "INITSL";
   m_gv_highest_price_key = base_key + "HIGH";
   m_gv_lowest_price_key = base_key + "LOW";
   m_gv_trade_start_bar_key = base_key + "STARTBAR";  // v4.2: For time exit persistence
   
   // Initialize ATR
   m_atr_handle = iATR(m_symbol, PERIOD_H1, 14);
   if(m_atr_handle == INVALID_HANDLE)
   {
      Print("CTradeManager: Failed to create ATR indicator");
      return false;
   }
   
   // Sync with existing position if any (includes loading persisted state)
   SyncWithExistingPosition();
   
   Print("CTradeManager: Initialized for ", m_symbol, " Magic: ", m_magic_number);
   return true;
}

void CTradeManager::SetManagementMode(ENUM_MANAGEMENT_MODE mode)
{
   m_mgmt_mode = mode;
   Print("CTradeManager: Management mode set to ", EnumToString(mode));
}

void CTradeManager::UpdateATR()
{
   if(m_atr_handle == INVALID_HANDLE)
      return;

   double atr[];
   ArraySetAsSeries(atr, true);
   ArrayResize(atr, 1);
   if(CopyBuffer(m_atr_handle, 0, 0, 1, atr) > 0)
      m_current_atr = atr[0];
   else
      Print("CTradeManager: failed to read ATR buffer");
}

double CTradeManager::GetCurrentRMultiple()
{
   if(!m_has_active_trade) return 0;
   
   double current_price = (m_active_trade.type == POSITION_TYPE_BUY) 
      ? SymbolInfoDouble(m_symbol, SYMBOL_BID) 
      : SymbolInfoDouble(m_symbol, SYMBOL_ASK);
   
   double risk = MathAbs(m_active_trade.entry_price - m_active_trade.initial_sl);
   if(risk <= 0) return 0;
   
   double profit = (m_active_trade.type == POSITION_TYPE_BUY)
      ? current_price - m_active_trade.entry_price
      : m_active_trade.entry_price - current_price;
   
   return profit / risk;
}

bool CTradeManager::OpenTrade(ENUM_SIGNAL_TYPE signal, double lots, double sl, double tp, 
                               double score, string reason)
{
   if(m_has_active_trade)
   {
      Print("CTradeManager: Cannot open trade - already have active position");
      return false;
   }
   
   if(signal == SIGNAL_NONE) return false;
   
   double price = (signal == SIGNAL_BUY) 
      ? SymbolInfoDouble(m_symbol, SYMBOL_ASK) 
      : SymbolInfoDouble(m_symbol, SYMBOL_BID);
   if(sl == 0.0)
   {
      Print("CTradeManager: SL not provided - blocking order to enforce hard protection");
      return false;
   }
   double bid = SymbolInfoDouble(m_symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
   double point = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
   double spread_pts = (ask - bid) / point;
   double max_spread_pts = m_slippage * 2;
   if(spread_pts > max_spread_pts)
   {
      Print("CTradeManager: spread too wide (", spread_pts, " pts) > max ", max_spread_pts, " pts");
      return false;
   }
   
   // Validate SL/TP
   int stops_lvl = (int)SymbolInfoInteger(m_symbol, SYMBOL_TRADE_STOPS_LEVEL);
   int freeze_lvl = (int)SymbolInfoInteger(m_symbol, SYMBOL_TRADE_FREEZE_LEVEL);
   double min_stop = MathMax(stops_lvl, freeze_lvl) * _Point;
   if(MathAbs(price - sl) < min_stop || MathAbs(tp - price) < min_stop)
   {
      Print("CTradeManager: SL/TP too close to price");
      return false;
   }
   // Directional sanity: SL must be on the protective side; TP on the profit side
   if(signal == SIGNAL_BUY && (sl >= price || tp <= price))
   {
      Print("CTradeManager: invalid SL/TP placement for BUY");
      return false;
   }
   if(signal == SIGNAL_SELL && (sl <= price || tp >= price))
   {
      Print("CTradeManager: invalid SL/TP placement for SELL");
      return false;
   }
   
   // Retry loop for requotes and price changes
   int max_retries = 3;
   bool result = false;
   
   for(int attempt = 0; attempt < max_retries; attempt++)
   {
      // Refresh price on retry
      if(attempt > 0)
      {
         price = (signal == SIGNAL_BUY) 
            ? SymbolInfoDouble(m_symbol, SYMBOL_ASK) 
            : SymbolInfoDouble(m_symbol, SYMBOL_BID);
         bid = SymbolInfoDouble(m_symbol, SYMBOL_BID);
         ask = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
         spread_pts = (ask - bid) / point;
         if(spread_pts > max_spread_pts)
         {
            Print("CTradeManager: spread too wide on retry (", spread_pts, " pts) > max ", max_spread_pts, " pts");
            return false;
         }

         // Re-validate stop distances with refreshed price
         if(MathAbs(price - sl) < min_stop || MathAbs(tp - price) < min_stop)
         {
            Print("CTradeManager: SL/TP too close after price change");
            return false;
         }

         if(signal == SIGNAL_BUY && (sl >= price || tp <= price))
         {
            Print("CTradeManager: invalid SL/TP placement for BUY after price change");
            return false;
         }
         if(signal == SIGNAL_SELL && (sl <= price || tp >= price))
         {
            Print("CTradeManager: invalid SL/TP placement for SELL after price change");
            return false;
         }
         Sleep(100); // Brief pause before retry
      }
      
      if(signal == SIGNAL_BUY)
         result = m_trade.Buy(lots, m_symbol, price, sl, tp, reason);
      else
         result = m_trade.Sell(lots, m_symbol, price, sl, tp, reason);
      
      if(result)
         break; // Success
      
      uint retcode = m_trade.ResultRetcode();
      
      // Retry only on requote, price changed, or off quotes
      if(retcode == TRADE_RETCODE_REQUOTE || 
         retcode == TRADE_RETCODE_PRICE_CHANGED ||
         retcode == TRADE_RETCODE_PRICE_OFF)
      {
         Print("CTradeManager: Retry ", attempt + 1, "/", max_retries, " - ", m_trade.ResultRetcodeDescription());
         continue;
      }
      
      // Non-retriable error
      Print("CTradeManager: Trade failed - ", m_trade.ResultRetcodeDescription(), " (retcode ", retcode, ", last error ", GetLastError(), ")");
      return false;
   }
   
   if(!result)
   {
      Print("CTradeManager: Trade failed after ", max_retries, " retries");
      return false;
   }
   
   // Initialize trade info
   m_active_trade.ticket = m_trade.ResultDeal();
   m_active_trade.state = TRADE_STATE_POSITION_OPEN;
   m_active_trade.type = (signal == SIGNAL_BUY) ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
   m_active_trade.entry_price = m_trade.ResultPrice();
   m_active_trade.initial_sl = sl;
   m_active_trade.current_sl = sl;
   m_active_trade.tp1 = tp;
   m_active_trade.tp2 = 0;
   m_active_trade.tp3 = 0;
   m_active_trade.initial_lots = lots;
   m_active_trade.current_lots = lots;
   m_active_trade.highest_price = m_active_trade.entry_price;
   m_active_trade.lowest_price = m_active_trade.entry_price;
   m_active_trade.entry_time = TimeCurrent();
   m_active_trade.entry_score = score;
   m_active_trade.realized_pnl = 0;
   m_active_trade.partials_taken = 0;
   m_active_trade.entry_reason = reason;
   
   m_has_active_trade = true;
   
   // v4.1: Record trade start bar time for time exit logic (GENIUS)
   m_trade_start_bar_time = iTime(m_symbol, PERIOD_CURRENT, 0);
   
   // GENIUS FIX P3: Persist initial state for restart recovery
   PersistState();
   
   Print("CTradeManager: Trade opened - ", (signal == SIGNAL_BUY ? "BUY" : "SELL"),
         " @ ", m_active_trade.entry_price, " SL: ", sl, " TP: ", tp,
         " Score: ", score, " Reason: ", reason);
   
   return true;
}

bool CTradeManager::OpenTradeWithTPs(ENUM_SIGNAL_TYPE signal, double lots, double sl,
                                      double tp1, double tp2, double tp3,
                                      double score, string reason)
{
   // Open trade with TP1 as initial take profit (broker order)
   // TP2 and TP3 stored for partial management
   if(!OpenTrade(signal, lots, sl, tp1, score, reason))
      return false;
   
   // Store additional TP levels for partial management
   m_active_trade.tp1 = tp1;
   m_active_trade.tp2 = tp2;
   m_active_trade.tp3 = tp3;
   
   // Calculate R multiples for each TP
   double risk = MathAbs(m_active_trade.entry_price - sl);
   if(risk > 0)
   {
      double r1 = MathAbs(tp1 - m_active_trade.entry_price) / risk;
      double r2 = MathAbs(tp2 - m_active_trade.entry_price) / risk;
      
      // Auto-configure partials based on TP levels
      m_partial1_trigger = r1;
      m_partial2_trigger = r2;
      m_trailing_start = r2;
   }
   
   Print("CTradeManager: Multi-TP trade - TP1: ", tp1, " (40%), TP2: ", tp2, " (30%), TP3: ", tp3, " (trail)");
   return true;
}

bool CTradeManager::CloseTrade(string reason)
{
   if(!m_has_active_trade) return false;
   
   // Find position by magic number
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetInteger(POSITION_MAGIC) == m_magic_number &&
            PositionGetString(POSITION_SYMBOL) == m_symbol)
         {
            // v4.2 GENIUS: Calculate final P/L BEFORE closing for Bayesian learning
            // Use POSITION_PROFIT (includes swap/commission) to avoid deprecated POSITION_COMMISSION
            double final_pnl = PositionGetDouble(POSITION_PROFIT)
                             + m_active_trade.realized_pnl;  // Include partial profits
            
            if(ClosePositionWithRetry(ticket))
            {
               ENUM_TRADE_STATE old_state = m_active_trade.state;
               m_active_trade.state = TRADE_STATE_CLOSED;
               m_has_active_trade = false;
               LogStateChange(old_state, TRADE_STATE_CLOSED);
               
               // v4.2 GENIUS: Bayesian Learning Callback
               if(m_use_learning_callback && m_confluence_scorer != NULL)
               {
                  bool was_win = (final_pnl > 0);
                  m_confluence_scorer.RecordTradeOutcome(was_win);
                  Print("CTradeManager: Bayesian Learning - Trade ", 
                        (was_win ? "WIN" : "LOSS"), " recorded (PnL: ", 
                        DoubleToString(final_pnl, 2), ")");
               }
               
               // v4.2 GENIUS: Kelly Learning Callback (RiskManager)
               if(m_use_kelly_callback && m_risk_manager != NULL)
               {
                  m_risk_manager.OnTradeResult(final_pnl);
                  Print("CTradeManager: Kelly Learning - Trade result ", 
                        DoubleToString(final_pnl, 2), " recorded | ",
                        "Wins: ", m_risk_manager.GetConsecutiveWins(),
                        " Losses: ", m_risk_manager.GetConsecutiveLosses());
               }
               
               Print("CTradeManager: Trade closed - ", reason, 
                     " | Final PnL: ", DoubleToString(final_pnl, 2));
               return true;
            }
         }
      }
   }
   return false;
}

bool CTradeManager::ClosePartial(double percent, string reason)
{
   if(!m_has_active_trade) return false;
   if(percent <= 0 || percent >= 1) return false;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetInteger(POSITION_MAGIC) != m_magic_number ||
            PositionGetString(POSITION_SYMBOL) != m_symbol)
            continue;

         double pos_volume   = PositionGetDouble(POSITION_VOLUME);
         double min_vol      = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);
         double step_vol     = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP);
         int vol_digits = (step_vol > 0) ? (int)MathRound(-MathLog10(step_vol)) : 2;

         if(pos_volume <= 0 || step_vol <= 0) return false;

         double close_vol = pos_volume * percent;
         // round down to step
         close_vol = MathFloor(close_vol / step_vol) * step_vol;
         close_vol = NormalizeDouble(close_vol, vol_digits);

         if(close_vol < min_vol)
         {
            // if remaining is small, close all; else fail
            if(pos_volume <= min_vol * 1.1)
               close_vol = pos_volume;
            else
               return false;
         }

         // Retry loop for requotes and price changes during partial close
         int max_retries = 3;
         bool ok = false;
         
         for(int attempt = 0; attempt < max_retries; attempt++)
         {
            if(attempt > 0)
            {
               Sleep(100); // Brief pause before retry
               // Re-select position to refresh data
               if(!PositionSelectByTicket(ticket))
               {
                  Print("CTradeManager: Position no longer exists during partial close retry");
                  return false;
               }
               // Recalculate volume in case position changed
               pos_volume = PositionGetDouble(POSITION_VOLUME);
               if(pos_volume <= 0) return false;
               close_vol = pos_volume * percent;
               close_vol = MathFloor(close_vol / step_vol) * step_vol;
               close_vol = NormalizeDouble(close_vol, vol_digits);
               if(close_vol < min_vol)
               {
                  if(pos_volume <= min_vol * 1.1)
                     close_vol = pos_volume;
                  else
                     return false;
               }
            }
            
            ok = m_trade.PositionClosePartial(ticket, close_vol);
            
            if(ok)
               break; // Success
            
            uint retcode = m_trade.ResultRetcode();
            
            // Retry only on requote, price changed, or off quotes
            if(retcode == TRADE_RETCODE_REQUOTE || 
               retcode == TRADE_RETCODE_PRICE_CHANGED ||
               retcode == TRADE_RETCODE_PRICE_OFF)
            {
               Print("CTradeManager: Partial close retry ", attempt + 1, "/", max_retries, " - ", m_trade.ResultRetcodeDescription());
               continue;
            }
            
            // Non-retriable error
            Print("CTradeManager: partial close failed - ", m_trade.ResultRetcodeDescription(), " (retcode ", retcode, ", last error ", GetLastError(), ")");
            return false;
         }
         
         if(!ok)
         {
            Print("CTradeManager: partial close failed after ", max_retries, " retries");
            return false;
         }

         double partial_profit = 0;
         ulong deal_id = m_trade.ResultDeal();
         if(deal_id > 0)
         {
            HistoryDealSelect(deal_id); // Ensure deal is selected
            partial_profit = HistoryDealGetDouble(deal_id, DEAL_PROFIT)
               + HistoryDealGetDouble(deal_id, DEAL_COMMISSION)
               + HistoryDealGetDouble(deal_id, DEAL_SWAP);
         }
         m_active_trade.realized_pnl += partial_profit;
         
         // Re-select position to get updated volume
         if(PositionSelectByTicket(ticket))
            m_active_trade.current_lots = PositionGetDouble(POSITION_VOLUME);
         else
            m_active_trade.current_lots = 0; // Position fully closed
         
         m_active_trade.partials_taken++;

         // GENIUS FIX P5: Update broker TP to next target with retry
         if(PositionSelectByTicket(ticket))
         {
            double current_sl = PositionGetDouble(POSITION_SL);
            double new_tp = 0;
            
            if(m_active_trade.partials_taken == 1 && m_active_trade.tp2 > 0)
               new_tp = m_active_trade.tp2;
            else if(m_active_trade.partials_taken >= 2 && m_active_trade.tp3 > 0)
               new_tp = m_active_trade.tp3;
            
            if(new_tp > 0)
            {
               // Retry loop for TP modification (critical for partial management)
               int modify_retries = 3;
               bool modify_ok = false;
               
               for(int m_attempt = 0; m_attempt < modify_retries; m_attempt++)
               {
                  if(m_attempt > 0)
                  {
                     Sleep(50);
                     if(!PositionSelectByTicket(ticket)) break; // Position gone
                     current_sl = PositionGetDouble(POSITION_SL);
                  }
                  
                  modify_ok = m_trade.PositionModify(ticket, current_sl, new_tp);
                  
                  if(modify_ok)
                  {
                     Print("CTradeManager: TP updated to ", new_tp, " after partial ", m_active_trade.partials_taken);
                     break;
                  }
                  
                  uint mod_retcode = m_trade.ResultRetcode();
                  if(mod_retcode == TRADE_RETCODE_REQUOTE || 
                     mod_retcode == TRADE_RETCODE_PRICE_CHANGED ||
                     mod_retcode == TRADE_RETCODE_PRICE_OFF)
                  {
                     Print("CTradeManager: TP modify retry ", m_attempt + 1, "/", modify_retries);
                     continue;
                  }
                  
                  // Non-retriable error
                  Print("CTradeManager: TP modify failed - ", m_trade.ResultRetcodeDescription(), 
                        " (retcode ", mod_retcode, ") - TP remains at previous level");
                  break;
               }
            }
         }

         Print("CTradeManager: Partial close ", DoubleToString(close_vol, vol_digits), " lots. Reason: ", reason);
         return true;
      }
   }

   return false;
}

void CTradeManager::OnTick()
{
   if(!m_has_active_trade) return;
   
   // GENIUS FIX P2: Race condition guard - prevent reentrant operations
   // This can happen if OnTick is called while a previous operation (with Sleep) is pending
   if(m_operation_in_progress)
   {
      return; // Skip this tick, operation in progress
   }
   
   UpdateATR();
   
   // Check if position still exists
   bool position_exists = false;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetInteger(POSITION_MAGIC) == m_magic_number &&
            PositionGetString(POSITION_SYMBOL) == m_symbol)
         {
            position_exists = true;
            break;
         }
      }
   }
   
   if(!position_exists)
   {
      // Position was closed (by SL/TP or manually)
      ENUM_TRADE_STATE old_state = m_active_trade.state;
      m_active_trade.state = TRADE_STATE_CLOSED;
      m_has_active_trade = false;
      LogStateChange(old_state, TRADE_STATE_CLOSED);
      Print("CTradeManager: Position no longer exists - closed externally");
      return;
   }
   
   // Update high/low tracking
   double current_price = (m_active_trade.type == POSITION_TYPE_BUY)
      ? SymbolInfoDouble(m_symbol, SYMBOL_BID)
      : SymbolInfoDouble(m_symbol, SYMBOL_ASK);
   
   bool extremes_updated = false;
   if(current_price > m_active_trade.highest_price)
   {
      m_active_trade.highest_price = current_price;
      extremes_updated = true;
   }
   if(current_price < m_active_trade.lowest_price)
   {
      m_active_trade.lowest_price = current_price;
      extremes_updated = true;
   }
   if(extremes_updated)
      PersistState();
   
   // State machine logic
   double r_multiple = GetCurrentRMultiple();
   ENUM_TRADE_STATE old_state = m_active_trade.state;
   
   switch(m_active_trade.state)
   {
      case TRADE_STATE_POSITION_OPEN:
         // Check for breakeven
         if(r_multiple >= m_breakeven_trigger && m_mgmt_mode != MGMT_FIXED_RR)
         {
            if(MoveToBreakeven())
            {
               m_active_trade.state = TRADE_STATE_BREAKEVEN;
               LogStateChange(old_state, TRADE_STATE_BREAKEVEN);
            }
         }
         break;
         
      case TRADE_STATE_BREAKEVEN:
         // Check for partial TP1
         if(r_multiple >= m_partial1_trigger && m_active_trade.partials_taken == 0 &&
            (m_mgmt_mode == MGMT_PARTIAL_TP || m_mgmt_mode == MGMT_DYNAMIC))
         {
            if(TakePartialProfit(m_partial1_percent, 1))
            {
               m_active_trade.state = TRADE_STATE_PARTIAL_TP;
               LogStateChange(old_state, TRADE_STATE_PARTIAL_TP);
            }
         }
         // Or start trailing
         else if(r_multiple >= m_trailing_start && m_mgmt_mode == MGMT_TRAILING_ATR)
         {
            m_active_trade.state = TRADE_STATE_TRAILING;
            LogStateChange(old_state, TRADE_STATE_TRAILING);
         }
         break;
         
      case TRADE_STATE_PARTIAL_TP:
         // Check for partial TP2
         if(r_multiple >= m_partial2_trigger && m_active_trade.partials_taken == 1)
         {
            TakePartialProfit(m_partial2_percent, 2);
         }
         // Start trailing after partials
         if(r_multiple >= m_trailing_start)
         {
            m_active_trade.state = TRADE_STATE_TRAILING;
            LogStateChange(old_state, TRADE_STATE_TRAILING);
         }
         break;
         
      case TRADE_STATE_TRAILING:
         // Update trailing stop (v4.1: only if trailing enabled for this regime)
         if(m_trailing_enabled)
            UpdateTrailingStop();
         break;
   }
   
   // v4.2 GENIUS: Footprint exit check (FASE 3)
   // Check for absorption/exhaustion signals that suggest reversal
   if(m_use_footprint_exit && m_footprint != NULL)
   {
      CheckFootprintExit();  // May close, partial, or tighten trail
   }
   
   // v4.1: Time exit logic (GENIUS) - close if max bars exceeded
   if(m_time_exit_enabled && m_has_active_trade && m_trade_start_bar_time > 0)
   {
      datetime current_bar = iTime(m_symbol, PERIOD_CURRENT, 0);
      // Count bars elapsed
      int bars_elapsed = Bars(m_symbol, PERIOD_CURRENT, m_trade_start_bar_time, current_bar);
      
      if(bars_elapsed >= m_max_trade_bars)
      {
         Print("CTradeManager: TIME EXIT triggered - ", bars_elapsed, " bars >= ", m_max_trade_bars, " max");
         CloseTrade("Time exit - max bars reached (" + IntegerToString(m_max_trade_bars) + ")");
      }
   }
}

bool CTradeManager::MoveToBreakeven()
{
   if(!m_has_active_trade) return false;
   
   // Add small buffer (2 points) to ensure profit
   double buffer = 2 * _Point;
   double new_sl = (m_active_trade.type == POSITION_TYPE_BUY)
      ? m_active_trade.entry_price + buffer
      : m_active_trade.entry_price - buffer;
   int stops_lvl = (int)SymbolInfoInteger(m_symbol, SYMBOL_TRADE_STOPS_LEVEL);
   int freeze_lvl = (int)SymbolInfoInteger(m_symbol, SYMBOL_TRADE_FREEZE_LEVEL);
   double min_dist = MathMax(stops_lvl, freeze_lvl) * _Point;
   double current_price = (m_active_trade.type == POSITION_TYPE_BUY)
      ? SymbolInfoDouble(m_symbol, SYMBOL_BID)
      : SymbolInfoDouble(m_symbol, SYMBOL_ASK);
   
   // Already at or better than BE
   if(m_active_trade.type == POSITION_TYPE_BUY && m_active_trade.current_sl >= new_sl)
      return true;
   if(m_active_trade.type == POSITION_TYPE_SELL && m_active_trade.current_sl <= new_sl)
      return true;
   if(MathAbs(current_price - new_sl) < min_dist)
      return false; // freeze/stops guard
   
   // Modify position
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetInteger(POSITION_MAGIC) == m_magic_number &&
            PositionGetString(POSITION_SYMBOL) == m_symbol)
         {
            double current_tp = PositionGetDouble(POSITION_TP);
            if(ModifyPositionWithRetry(ticket, new_sl, current_tp))
            {
               m_active_trade.current_sl = new_sl;
               PersistState();
               Print("CTradeManager: Moved to breakeven @ ", new_sl);
               return true;
            }
         }
      }
   }
   return false;
}

bool CTradeManager::TakePartialProfit(double percent, int partial_num)
{
   if(!m_has_active_trade) return false;
   
   // GENIUS FIX P2: Set operation guard to prevent race conditions
   m_operation_in_progress = true;
   
   string reason = StringFormat("Partial TP %d @ %.2fR", partial_num, GetCurrentRMultiple());
   bool result = ClosePartial(percent, reason);
   
   // GENIUS FIX P3: Persist state after successful partial close
   if(result)
   {
      PersistState();
   }
   
   // GENIUS FIX P2: Clear operation guard
   m_operation_in_progress = false;
   
   return result;
}

bool CTradeManager::UpdateTrailingStop()
{
   if(!m_has_active_trade || m_current_atr <= 0) return false;
   
   double new_sl = CalculateTrailingStop();
   int stops_lvl = (int)SymbolInfoInteger(m_symbol, SYMBOL_TRADE_STOPS_LEVEL);
   int freeze_lvl = (int)SymbolInfoInteger(m_symbol, SYMBOL_TRADE_FREEZE_LEVEL);
   double min_dist = MathMax(stops_lvl, freeze_lvl) * _Point;
   double current_price = (m_active_trade.type == POSITION_TYPE_BUY)
      ? SymbolInfoDouble(m_symbol, SYMBOL_BID)
      : SymbolInfoDouble(m_symbol, SYMBOL_ASK);
   
   // Only move SL in profitable direction
   bool should_update = false;
   if(m_active_trade.type == POSITION_TYPE_BUY && new_sl > m_active_trade.current_sl)
      should_update = true;
   if(m_active_trade.type == POSITION_TYPE_SELL && new_sl < m_active_trade.current_sl)
      should_update = true;
   
   if(!should_update) return false;
   if(MathAbs(current_price - new_sl) < min_dist) return false; // freeze/stops guard
   
   // Modify position
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetInteger(POSITION_MAGIC) == m_magic_number &&
            PositionGetString(POSITION_SYMBOL) == m_symbol)
         {
            double current_tp = PositionGetDouble(POSITION_TP);
            if(ModifyPositionWithRetry(ticket, new_sl, current_tp))
            {
               m_active_trade.current_sl = new_sl;
               PersistState();
               Print("CTradeManager: Trailing stop updated to ", new_sl);
               return true;
            }
         }
      }
   }
   return false;
}

double CTradeManager::CalculateTrailingStop()
{
   // v4.2 GENIUS: ATR-based trailing as baseline
   double trail_distance = m_current_atr * m_trailing_step;
   double atr_trail = 0;
   
   if(m_active_trade.type == POSITION_TYPE_BUY)
      atr_trail = m_active_trade.highest_price - trail_distance;
   else
      atr_trail = m_active_trade.lowest_price + trail_distance;
   
   // v4.2 GENIUS: Structure-based trailing - never trail THROUGH a valid swing level
   // This prevents getting stopped out by noise ABOVE a swing low (for longs)
   if(m_use_structure_trail && m_structure != NULL)
   {
      double structure_trail = GetStructureTrailLevel();
      
      if(structure_trail > 0)  // Valid structure level found
      {
         if(m_active_trade.type == POSITION_TYPE_BUY)
         {
            // For BUY: use the LOWER of the two (protect more)
            // If structure level is below ATR trail, use ATR (tighter)
            // If ATR trail is below structure level, use structure (respect swing)
            double final_trail = MathMax(atr_trail, structure_trail);
            
            // Only use structure if it's better (higher SL = more protection)
            if(structure_trail > atr_trail)
            {
               Print("CTradeManager: STRUCTURE TRAIL - Using swing low @ ", structure_trail,
                     " instead of ATR @ ", atr_trail, " (+", (structure_trail - atr_trail) / _Point, " pts protection)");
            }
            return final_trail;
         }
         else // SELL
         {
            // For SELL: use the HIGHER of the two (protect more)
            double final_trail = MathMin(atr_trail, structure_trail);
            
            if(structure_trail < atr_trail)
            {
               Print("CTradeManager: STRUCTURE TRAIL - Using swing high @ ", structure_trail,
                     " instead of ATR @ ", atr_trail, " (+", (atr_trail - structure_trail) / _Point, " pts protection)");
            }
            return final_trail;
         }
      }
   }
   
   return atr_trail;  // Fallback to ATR-only trailing
}

// ═══════════════════════════════════════════════════════════════════════════
// v4.2 GENIUS: GetStructureTrailLevel - Find nearest valid swing for trailing
// For BUY: Find swing lows BELOW current price (potential support)
// For SELL: Find swing highs ABOVE current price (potential resistance)
// ═══════════════════════════════════════════════════════════════════════════
double CTradeManager::GetStructureTrailLevel()
{
   if(m_structure == NULL) return 0;
   
   double current_price = (m_active_trade.type == POSITION_TYPE_BUY)
      ? SymbolInfoDouble(m_symbol, SYMBOL_BID)
      : SymbolInfoDouble(m_symbol, SYMBOL_ASK);
   
   double buffer = m_current_atr * m_structure_buffer_atr;  // Buffer from swing level
   double structure_level = 0;
   
   if(m_active_trade.type == POSITION_TYPE_BUY)
   {
      // Find the highest swing low that is:
      // 1. Below current price
      // 2. Not broken
      // 3. Above our current SL (or we'd be giving back protection)
      SSwingPoint last_low = m_structure.GetLastLow();
      SSwingPoint prev_low;
      
      // Get state for prev_low
      SStructureState state = m_structure.GetState();
      prev_low = state.prev_low;
      
      // Check last swing low
      if(last_low.is_valid && !last_low.is_broken && 
         last_low.price < current_price &&
         last_low.price > m_active_trade.current_sl)
      {
         structure_level = last_low.price - buffer;  // Trail BELOW the swing low
      }
      
      // Check previous swing low if it's higher (better protection)
      if(prev_low.is_valid && !prev_low.is_broken &&
         prev_low.price < current_price &&
         prev_low.price > m_active_trade.current_sl)
      {
         double prev_level = prev_low.price - buffer;
         if(prev_level > structure_level)
            structure_level = prev_level;
      }
   }
   else // SELL
   {
      // Find the lowest swing high that is:
      // 1. Above current price
      // 2. Not broken
      // 3. Below our current SL
      SSwingPoint last_high = m_structure.GetLastHigh();
      SSwingPoint prev_high;
      
      SStructureState state = m_structure.GetState();
      prev_high = state.prev_high;
      
      // Check last swing high
      if(last_high.is_valid && !last_high.is_broken &&
         last_high.price > current_price &&
         last_high.price < m_active_trade.current_sl)
      {
         structure_level = last_high.price + buffer;  // Trail ABOVE the swing high
      }
      
      // Check previous swing high if it's lower (better protection)
      if(prev_high.is_valid && !prev_high.is_broken &&
         prev_high.price > current_price &&
         prev_high.price < m_active_trade.current_sl)
      {
         double prev_level = prev_high.price + buffer;
         if(prev_level < structure_level || structure_level == 0)
            structure_level = prev_level;
      }
   }
   
   return structure_level;
}

// ═══════════════════════════════════════════════════════════════════════════
// v4.2 GENIUS: CheckFootprintExit - Check for footprint-based exit signals
// Detects when order flow turns against the position (absorption/exhaustion)
// Returns true if an exit signal is detected
// ═══════════════════════════════════════════════════════════════════════════
bool CTradeManager::CheckFootprintExit()
{
   if(m_footprint == NULL || !m_use_footprint_exit) return false;
   if(!m_has_active_trade) return false;
   
   // Only check when in profit (don't exit losing trades on footprint)
   double r_mult = GetCurrentRMultiple();
   if(r_mult < 0.5) return false;  // Need at least 0.5R profit to consider footprint exit
   
   bool exit_signal = false;
   string exit_reason = "";
   
   if(m_active_trade.type == POSITION_TYPE_BUY)
   {
      // For BUY: Look for SELL absorption (sellers stepping in at highs)
      // This suggests buying pressure is being absorbed = potential reversal
      if(m_footprint.HasSellAbsorption())
      {
         SAbsorptionZone sell_abs = m_footprint.GetBestAbsorption(ABSORPTION_SELL);
         
         if(sell_abs.confidence >= m_absorption_exit_conf)
         {
            // High confidence sell absorption detected
            exit_signal = true;
            exit_reason = StringFormat("SELL ABSORPTION (conf:%d) - buyers being absorbed at highs", 
                                        sell_abs.confidence);
         }
      }
      
      // Also check for stacked sell imbalances (aggressive sellers)
      SFootprintSignal fp_signal = m_footprint.GetSignal();
      if(fp_signal.hasStackedSellImbalance && r_mult >= 1.0)
      {
         exit_signal = true;
         exit_reason = "STACKED SELL IMBALANCE - aggressive selling detected";
      }
   }
   else // SELL position
   {
      // For SELL: Look for BUY absorption (buyers stepping in at lows)
      // This suggests selling pressure is being absorbed = potential reversal
      if(m_footprint.HasBuyAbsorption())
      {
         SAbsorptionZone buy_abs = m_footprint.GetBestAbsorption(ABSORPTION_BUY);
         
         if(buy_abs.confidence >= m_absorption_exit_conf)
         {
            exit_signal = true;
            exit_reason = StringFormat("BUY ABSORPTION (conf:%d) - sellers being absorbed at lows",
                                        buy_abs.confidence);
         }
      }
      
      // Also check for stacked buy imbalances (aggressive buyers)
      SFootprintSignal fp_signal = m_footprint.GetSignal();
      if(fp_signal.hasStackedBuyImbalance && r_mult >= 1.0)
      {
         exit_signal = true;
         exit_reason = "STACKED BUY IMBALANCE - aggressive buying detected";
      }
   }
   
   if(exit_signal)
   {
      Print("CTradeManager: FOOTPRINT EXIT SIGNAL @ ", DoubleToString(r_mult, 2), "R - ", exit_reason);
      
      // Take action based on profit level
      if(r_mult >= 2.0)
      {
         // Good profit - close remaining position
         CloseTrade("Footprint exit @ " + DoubleToString(r_mult, 2) + "R: " + exit_reason);
         return true;
      }
      else if(r_mult >= 1.0 && m_active_trade.partials_taken < 2)
      {
         // Decent profit - accelerate partial taking
         Print("CTradeManager: Accelerating partial due to footprint signal");
         TakePartialProfit(0.50, m_active_trade.partials_taken + 1);  // Take 50%
         
         // Also tighten trailing
         m_trailing_step *= 0.5;  // Halve trailing distance temporarily
         return true;
      }
      else if(r_mult >= 0.5)
      {
         // Small profit - just tighten trailing aggressively
         Print("CTradeManager: Tightening trail due to footprint signal");
         m_trailing_step *= 0.5;
         return true;
      }
   }
   
   return false;
}

double CTradeManager::GetUnrealizedPnL()
{
   if(!m_has_active_trade) return 0;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetInteger(POSITION_MAGIC) == m_magic_number &&
            PositionGetString(POSITION_SYMBOL) == m_symbol)
         {
            return PositionGetDouble(POSITION_PROFIT);
         }
      }
   }
   return 0;
}

double CTradeManager::GetTotalPnL()
{
   return m_active_trade.realized_pnl + GetUnrealizedPnL();
}

bool CTradeManager::SyncWithExistingPosition()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
      {
         if(PositionGetInteger(POSITION_MAGIC) == m_magic_number &&
            PositionGetString(POSITION_SYMBOL) == m_symbol)
         {
            // Found existing position - sync state
            m_active_trade.ticket = ticket;
            m_active_trade.type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
            m_active_trade.entry_price = PositionGetDouble(POSITION_PRICE_OPEN);
            m_active_trade.current_sl = PositionGetDouble(POSITION_SL);
            m_active_trade.initial_sl = m_active_trade.current_sl;
            m_active_trade.tp1 = PositionGetDouble(POSITION_TP);
            m_active_trade.current_lots = PositionGetDouble(POSITION_VOLUME);
            m_active_trade.initial_lots = m_active_trade.current_lots;
            m_active_trade.entry_time = (datetime)PositionGetInteger(POSITION_TIME);
            m_active_trade.highest_price = m_active_trade.entry_price;
            m_active_trade.lowest_price = m_active_trade.entry_price;
            
            // GENIUS FIX P3: Load persisted state (partials_taken, initial_lots, etc)
            LoadPersistedState();
            
            // Determine current state based on persisted data
            double r = GetCurrentRMultiple();
            
            // Use persisted state if available, otherwise infer from position
            if(m_active_trade.partials_taken >= 2)
               m_active_trade.state = TRADE_STATE_TRAILING;
            else if(m_active_trade.partials_taken == 1)
               m_active_trade.state = TRADE_STATE_PARTIAL_TP;
            else if(r >= m_trailing_start)
               m_active_trade.state = TRADE_STATE_TRAILING;
            else if(m_active_trade.current_sl >= m_active_trade.entry_price - _Point && 
                    m_active_trade.type == POSITION_TYPE_BUY)
               m_active_trade.state = TRADE_STATE_BREAKEVEN;
            else if(m_active_trade.current_sl <= m_active_trade.entry_price + _Point && 
                    m_active_trade.type == POSITION_TYPE_SELL)
               m_active_trade.state = TRADE_STATE_BREAKEVEN;
            else
               m_active_trade.state = TRADE_STATE_POSITION_OPEN;
            
            m_has_active_trade = true;
            Print("CTradeManager: Synced with existing position #", m_active_trade.ticket,
                  " State: ", EnumToString(m_active_trade.state),
                  " Partials: ", m_active_trade.partials_taken,
                  " InitLots: ", m_active_trade.initial_lots);
            return true;
         }
      }
   }
   
   // GENIUS FIX P3: No position found - clear persisted state
   if(GlobalVariableCheck(m_gv_partials_key))
      GlobalVariableDel(m_gv_partials_key);
   if(GlobalVariableCheck(m_gv_state_key))
      GlobalVariableDel(m_gv_state_key);
   if(GlobalVariableCheck(m_gv_initial_lots_key))
      GlobalVariableDel(m_gv_initial_lots_key);
   // FORGE FIX: Also clear the additional GVs
   if(m_gv_initial_sl_key != "" && GlobalVariableCheck(m_gv_initial_sl_key))
      GlobalVariableDel(m_gv_initial_sl_key);
   if(m_gv_highest_price_key != "" && GlobalVariableCheck(m_gv_highest_price_key))
      GlobalVariableDel(m_gv_highest_price_key);
   if(m_gv_lowest_price_key != "" && GlobalVariableCheck(m_gv_lowest_price_key))
      GlobalVariableDel(m_gv_lowest_price_key);
   
   return false;
}

void CTradeManager::LogStateChange(ENUM_TRADE_STATE old_state, ENUM_TRADE_STATE new_state)
{
   Print("CTradeManager: State change ",
         EnumToString(old_state), " -> ", EnumToString(new_state),
         " @ ", GetCurrentRMultiple(), "R");
}

// ═══════════════════════════════════════════════════════════════════════════
// FORGE FIX: ModifyPositionWithRetry - was declared but not implemented
// Retry loop for position modification (SL/TP changes)
// ═══════════════════════════════════════════════════════════════════════════
bool CTradeManager::ModifyPositionWithRetry(ulong ticket, double new_sl, double new_tp)
{
   if(ticket == 0) return false;
   
   int max_retries = 3;
   
   for(int attempt = 0; attempt < max_retries; attempt++)
   {
      if(attempt > 0)
      {
         Sleep(50);
         if(!PositionSelectByTicket(ticket))
         {
            Print("CTradeManager: Position ", ticket, " no longer exists during modify retry");
            return false;
         }
      }
      
      if(m_trade.PositionModify(ticket, new_sl, new_tp))
         return true;
      
      uint retcode = m_trade.ResultRetcode();
      
      // Retry on requote/price change
      if(retcode == TRADE_RETCODE_REQUOTE || 
         retcode == TRADE_RETCODE_PRICE_CHANGED ||
         retcode == TRADE_RETCODE_PRICE_OFF)
      {
         Print("CTradeManager: Modify retry ", attempt + 1, "/", max_retries, 
               " - ", m_trade.ResultRetcodeDescription());
         continue;
      }
      
      // Non-retriable error
      Print("CTradeManager: Modify failed - ", m_trade.ResultRetcodeDescription(),
            " (retcode ", retcode, ", error ", GetLastError(), ")");
      return false;
   }
   
   Print("CTradeManager: Modify failed after ", max_retries, " retries");
   return false;
}

// ═══════════════════════════════════════════════════════════════════════════
// FORGE FIX: ClosePositionWithRetry - was declared but not implemented
// Retry loop for position close (full close)
// ═══════════════════════════════════════════════════════════════════════════
bool CTradeManager::ClosePositionWithRetry(ulong ticket)
{
   if(ticket == 0) return false;
   
   int max_retries = 3;
   
   for(int attempt = 0; attempt < max_retries; attempt++)
   {
      if(attempt > 0)
      {
         Sleep(100);
         if(!PositionSelectByTicket(ticket))
         {
            // Position already closed
            Print("CTradeManager: Position ", ticket, " already closed");
            return true;
         }
      }
      
      if(m_trade.PositionClose(ticket))
         return true;
      
      uint retcode = m_trade.ResultRetcode();
      
      // Retry on requote/price change
      if(retcode == TRADE_RETCODE_REQUOTE || 
         retcode == TRADE_RETCODE_PRICE_CHANGED ||
         retcode == TRADE_RETCODE_PRICE_OFF)
      {
         Print("CTradeManager: Close retry ", attempt + 1, "/", max_retries,
               " - ", m_trade.ResultRetcodeDescription());
         continue;
      }
      
      // Non-retriable error
      Print("CTradeManager: Close failed - ", m_trade.ResultRetcodeDescription(),
            " (retcode ", retcode, ", error ", GetLastError(), ")");
      return false;
   }
   
   Print("CTradeManager: Close failed after ", max_retries, " retries");
   return false;
}

// ═══════════════════════════════════════════════════════════════════════════
// GENIUS FIX P3: State Persistence Functions
// These ensure partials_taken and initial_lots survive EA restart
// ═══════════════════════════════════════════════════════════════════════════

void CTradeManager::PersistState()
{
   if(!m_has_active_trade) return;
   if(m_gv_partials_key == "" || m_gv_state_key == "" || m_gv_initial_lots_key == "") return;
   
   // Persist partials_taken
   GlobalVariableSet(m_gv_partials_key, (double)m_active_trade.partials_taken);
   
   // Persist state
   GlobalVariableSet(m_gv_state_key, (double)m_active_trade.state);
   
   // Persist initial_lots (important to know original position size)
   GlobalVariableSet(m_gv_initial_lots_key, m_active_trade.initial_lots);
   
   // FORGE FIX: Persist initial_sl (critical for R-multiple calculation)
   if(m_gv_initial_sl_key != "")
      GlobalVariableSet(m_gv_initial_sl_key, m_active_trade.initial_sl);
   
   // FORGE FIX: Persist highest/lowest price (critical for trailing stop after restart)
   if(m_gv_highest_price_key != "")
      GlobalVariableSet(m_gv_highest_price_key, m_active_trade.highest_price);
   if(m_gv_lowest_price_key != "")
      GlobalVariableSet(m_gv_lowest_price_key, m_active_trade.lowest_price);
   
   // v4.2: Persist trade start bar time (critical for time exit after restart)
   if(m_gv_trade_start_bar_key != "" && m_trade_start_bar_time > 0)
      GlobalVariableSet(m_gv_trade_start_bar_key, (double)m_trade_start_bar_time);
   
   Print("CTradeManager: State persisted - Partials: ", m_active_trade.partials_taken,
         " State: ", EnumToString(m_active_trade.state),
         " InitLots: ", m_active_trade.initial_lots,
         " InitSL: ", m_active_trade.initial_sl,
         " High: ", m_active_trade.highest_price,
         " Low: ", m_active_trade.lowest_price,
         " StartBar: ", m_trade_start_bar_time);
}

void CTradeManager::LoadPersistedState()
{
   if(m_gv_partials_key == "" || m_gv_state_key == "" || m_gv_initial_lots_key == "") return;
   
   // Load partials_taken if exists
   if(GlobalVariableCheck(m_gv_partials_key))
   {
      m_active_trade.partials_taken = (int)GlobalVariableGet(m_gv_partials_key);
      Print("CTradeManager: Loaded persisted partials_taken: ", m_active_trade.partials_taken);
   }
   
   // Load initial_lots if exists (use it to restore correct initial position)
   if(GlobalVariableCheck(m_gv_initial_lots_key))
   {
      double persisted_initial = GlobalVariableGet(m_gv_initial_lots_key);
      if(persisted_initial > 0)
      {
         m_active_trade.initial_lots = persisted_initial;
         Print("CTradeManager: Loaded persisted initial_lots: ", m_active_trade.initial_lots);
      }
   }
   
   // FORGE FIX: Load initial_sl if exists (critical for R-multiple calculation)
   if(m_gv_initial_sl_key != "" && GlobalVariableCheck(m_gv_initial_sl_key))
   {
      double persisted_sl = GlobalVariableGet(m_gv_initial_sl_key);
      if(persisted_sl > 0)
      {
         m_active_trade.initial_sl = persisted_sl;
         Print("CTradeManager: Loaded persisted initial_sl: ", m_active_trade.initial_sl);
      }
   }
   
   // FORGE FIX: Load highest/lowest price if exists (critical for trailing stop)
   if(m_gv_highest_price_key != "" && GlobalVariableCheck(m_gv_highest_price_key))
   {
      double persisted_high = GlobalVariableGet(m_gv_highest_price_key);
      if(persisted_high > 0)
      {
         m_active_trade.highest_price = persisted_high;
         Print("CTradeManager: Loaded persisted highest_price: ", m_active_trade.highest_price);
      }
   }
   
   if(m_gv_lowest_price_key != "" && GlobalVariableCheck(m_gv_lowest_price_key))
   {
      double persisted_low = GlobalVariableGet(m_gv_lowest_price_key);
      if(persisted_low > 0)
      {
         m_active_trade.lowest_price = persisted_low;
         Print("CTradeManager: Loaded persisted lowest_price: ", m_active_trade.lowest_price);
      }
   }
   
   // Load state if exists (as hint, but we also infer from position)
   if(GlobalVariableCheck(m_gv_state_key))
   {
      ENUM_TRADE_STATE persisted_state = (ENUM_TRADE_STATE)(int)GlobalVariableGet(m_gv_state_key);
      Print("CTradeManager: Persisted state hint: ", EnumToString(persisted_state));
   }
   
   // v4.2: Load trade start bar time if exists (critical for time exit)
   if(m_gv_trade_start_bar_key != "" && GlobalVariableCheck(m_gv_trade_start_bar_key))
   {
      datetime persisted_start_bar = (datetime)GlobalVariableGet(m_gv_trade_start_bar_key);
      if(persisted_start_bar > 0)
      {
         m_trade_start_bar_time = persisted_start_bar;
         Print("CTradeManager: Loaded persisted trade_start_bar_time: ", m_trade_start_bar_time);
      }
   }
}
