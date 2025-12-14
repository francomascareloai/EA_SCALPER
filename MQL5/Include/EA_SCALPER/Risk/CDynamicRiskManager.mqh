//+------------------------------------------------------------------+
//|                                          CDynamicRiskManager.mqh |
//|                           EA_SCALPER_XAUUSD - Singularity Edition |
//|                        Dynamic Risk Management for FTMO Compliance |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD - Singularity Edition"
#property strict

#include "../Core/Definitions.mqh"
#include "../Analysis/CRegimeDetector.mqh"

// === RISK MODE ENUMERATION ===
enum ENUM_RISK_MODE
{
   RISK_MODE_NORMAL,           // Normal trading
   RISK_MODE_CAUTIOUS,         // Reduced risk after losses
   RISK_MODE_AGGRESSIVE,       // Increased risk on winning streak
   RISK_MODE_RECOVERY,         // Recovery mode after drawdown
   RISK_MODE_EMERGENCY,        // Emergency - no new trades
   RISK_MODE_HALTED            // Trading halted - FTMO limit reached
};

// === RISK STATE STRUCTURE ===
struct SRiskState
{
   ENUM_RISK_MODE    mode;
   double            current_risk_pct;      // Current risk per trade
   double            daily_dd_pct;          // Current daily drawdown %
   double            total_dd_pct;          // Total drawdown from peak %
   double            daily_pnl;             // Today's P/L
   double            weekly_pnl;            // This week's P/L
   int               consecutive_wins;
   int               consecutive_losses;
   int               trades_today;
   datetime          last_trade_time;
   bool              can_trade;             // Overall trading permission
   string            status_message;        // Human-readable status
};

// === FTMO LIMITS ===
#define FTMO_MAX_DAILY_DD      5.0    // 5% max daily loss
#define FTMO_MAX_TOTAL_DD      10.0   // 10% max total loss
#define FTMO_SOFT_DAILY_DD     4.0    // 4% soft limit (reduce risk)
#define FTMO_SOFT_TOTAL_DD     8.0    // 8% soft limit (reduce risk)
#define FTMO_WARN_DAILY_DD     3.0    // 3% warning level
#define FTMO_WARN_TOTAL_DD     6.0    // 6% warning level

// === DYNAMIC RISK MANAGER CLASS ===
class CDynamicRiskManager
{
private:
   // Account tracking
   double            m_initial_balance;
   double            m_peak_equity;
   double            m_daily_start_equity;
   datetime          m_daily_start_time;
   double            m_weekly_start_equity;
   datetime          m_weekly_start_time;
   
   // Risk parameters
   double            m_base_risk_pct;        // Base risk (e.g., 0.5%)
   double            m_max_risk_pct;         // Maximum risk (e.g., 1.0%)
   double            m_min_risk_pct;         // Minimum risk (e.g., 0.25%)
   int               m_max_trades_per_day;
   int               m_max_consecutive_losses;
   double            m_cooldown_hours;       // Hours to wait after losses
   
   // Performance tracking
   int               m_consecutive_wins;
   int               m_consecutive_losses;
   int               m_trades_today;
   double            m_daily_pnl;
   datetime          m_last_trade_time;
   datetime          m_cooldown_until;
   
   // Current state
   SRiskState        m_state;
   CRegimeDetector*  m_regime;              // Optional regime detector
   
   // Internal methods
   void              UpdateDailyTracking();
   void              UpdateWeeklyTracking();
   double            CalculateDynamicRisk();
   ENUM_RISK_MODE    DetermineRiskMode();
   void              UpdateState();
   
public:
   CDynamicRiskManager();
   ~CDynamicRiskManager();
   
   // Initialization
   bool              Init(double base_risk = 0.5, double max_risk = 1.0, double min_risk = 0.25);
   void              SetMaxTradesPerDay(int max_trades) { m_max_trades_per_day = max_trades; }
   void              SetMaxConsecutiveLosses(int max_losses) { m_max_consecutive_losses = max_losses; }
   void              SetCooldownHours(double hours) { m_cooldown_hours = hours; }
   void              AttachRegimeDetector(CRegimeDetector* regime) { m_regime = regime; }
   
   // Core methods
   void              OnTick();                          // Call every tick
   void              OnNewDay();                        // Call on new day
   void              OnTradeResult(double pnl);         // Call after trade closes
   
   // Risk calculation
   double            GetCurrentRiskPercent();           // Get current risk %
   double            GetPositionSize(double sl_points); // Calculate lot size
   double            GetRegimeMultiplier();             // Regime-based adjustment
   
   // Status checks
   bool              CanOpenTrade();                    // Overall trading permission
   bool              IsTradingHalted();                 // FTMO limit reached
   bool              IsInCooldown();                    // In cooldown period
   bool              IsEmergencyMode();                 // Emergency mode active
   
   // State access
   SRiskState        GetState() { return m_state; }
   ENUM_RISK_MODE    GetRiskMode() { return m_state.mode; }
   double            GetDailyDD() { return m_state.daily_dd_pct; }
   double            GetTotalDD() { return m_state.total_dd_pct; }
   string            GetStatusMessage() { return m_state.status_message; }
   
   // Manual controls
   void              ResetDailyStats();
   void              ForceEmergencyMode(string reason);
   void              ClearEmergencyMode();
};

// === IMPLEMENTATION ===

CDynamicRiskManager::CDynamicRiskManager()
{
   m_initial_balance = 0;
   m_peak_equity = 0;
   m_daily_start_equity = 0;
   m_daily_start_time = 0;
   m_weekly_start_equity = 0;
   m_weekly_start_time = 0;
   
   m_base_risk_pct = 0.5;
   m_max_risk_pct = 1.0;
   m_min_risk_pct = 0.25;
   m_max_trades_per_day = 20;
   m_max_consecutive_losses = 3;
   m_cooldown_hours = 1.0;
   
   m_consecutive_wins = 0;
   m_consecutive_losses = 0;
   m_trades_today = 0;
   m_daily_pnl = 0;
   m_last_trade_time = 0;
   m_cooldown_until = 0;
   
   m_regime = NULL;
   
   ZeroMemory(m_state);
   m_state.mode = RISK_MODE_NORMAL;
   m_state.can_trade = true;
}

CDynamicRiskManager::~CDynamicRiskManager()
{
}

bool CDynamicRiskManager::Init(double base_risk, double max_risk, double min_risk)
{
   m_base_risk_pct = base_risk;
   m_max_risk_pct = max_risk;
   m_min_risk_pct = min_risk;
   
   m_initial_balance = AccountInfoDouble(ACCOUNT_BALANCE);
   m_peak_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   m_daily_start_equity = m_peak_equity;
   m_daily_start_time = TimeCurrent();
   m_weekly_start_equity = m_peak_equity;
   m_weekly_start_time = TimeCurrent();
   
   UpdateState();
   
   Print("CDynamicRiskManager: Initialized");
   Print("  Base Risk: ", m_base_risk_pct, "%, Max: ", m_max_risk_pct, "%, Min: ", m_min_risk_pct, "%");
   Print("  Initial Balance: ", m_initial_balance);
   
   return true;
}

void CDynamicRiskManager::OnTick()
{
   // Update peak equity
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   if(equity > m_peak_equity)
      m_peak_equity = equity;
   
   // Check for new day
   UpdateDailyTracking();
   UpdateWeeklyTracking();
   
   // Update state
   UpdateState();
}

void CDynamicRiskManager::UpdateDailyTracking()
{
   MqlDateTime now, start;
   TimeToStruct(TimeCurrent(), now);
   TimeToStruct(m_daily_start_time, start);
   
   // Check if new day
   if(now.day != start.day || now.mon != start.mon)
   {
      OnNewDay();
   }
}

void CDynamicRiskManager::UpdateWeeklyTracking()
{
   MqlDateTime now, start;
   TimeToStruct(TimeCurrent(), now);
   TimeToStruct(m_weekly_start_time, start);
   
   // Check if new week (Monday)
   if(now.day_of_week == 1 && start.day_of_week != 1)
   {
      m_weekly_start_equity = AccountInfoDouble(ACCOUNT_EQUITY);
      m_weekly_start_time = TimeCurrent();
      Print("CDynamicRiskManager: New week started. Weekly equity: ", m_weekly_start_equity);
   }
}

void CDynamicRiskManager::OnNewDay()
{
   m_daily_start_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   m_daily_start_time = TimeCurrent();
   m_trades_today = 0;
   m_daily_pnl = 0;
   
   // Reset consecutive counters but not completely
   // Keep some memory of recent performance
   if(m_consecutive_losses > 0)
      m_consecutive_losses = MathMax(0, m_consecutive_losses - 1);
   if(m_consecutive_wins > 0)
      m_consecutive_wins = MathMax(0, m_consecutive_wins - 1);
   
   // Clear cooldown
   m_cooldown_until = 0;
   
   // Reset emergency if DD recovered
   if(m_state.mode == RISK_MODE_EMERGENCY && m_state.total_dd_pct < FTMO_SOFT_TOTAL_DD)
   {
      m_state.mode = RISK_MODE_CAUTIOUS;
      Print("CDynamicRiskManager: Exiting emergency mode - DD recovered");
   }
   
   Print("CDynamicRiskManager: New day started. Daily equity: ", m_daily_start_equity);
   
   UpdateState();
}

void CDynamicRiskManager::OnTradeResult(double pnl)
{
   m_daily_pnl += pnl;
   m_trades_today++;
   m_last_trade_time = TimeCurrent();
   
   if(pnl >= 0)
   {
      m_consecutive_wins++;
      m_consecutive_losses = 0;
   }
   else
   {
      m_consecutive_losses++;
      m_consecutive_wins = 0;
      
      // Set cooldown after consecutive losses
      if(m_consecutive_losses >= m_max_consecutive_losses)
      {
         m_cooldown_until = TimeCurrent() + (int)(m_cooldown_hours * 3600);
         Print("CDynamicRiskManager: Cooldown activated until ", TimeToString(m_cooldown_until));
      }
   }
   
   UpdateState();
}

void CDynamicRiskManager::UpdateState()
{
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   
   // Calculate drawdowns
   m_state.daily_dd_pct = (m_daily_start_equity - equity) / m_daily_start_equity * 100.0;
   m_state.total_dd_pct = (m_peak_equity - equity) / m_peak_equity * 100.0;
   m_state.daily_pnl = m_daily_pnl;
   m_state.weekly_pnl = equity - m_weekly_start_equity;
   m_state.consecutive_wins = m_consecutive_wins;
   m_state.consecutive_losses = m_consecutive_losses;
   m_state.trades_today = m_trades_today;
   m_state.last_trade_time = m_last_trade_time;
   
   // Determine risk mode
   m_state.mode = DetermineRiskMode();
   
   // Calculate current risk
   m_state.current_risk_pct = CalculateDynamicRisk();
   
   // Determine if can trade
   m_state.can_trade = CanOpenTrade();
   
   // Generate status message
   StringConcatenate(m_state.status_message,
      EnumToString(m_state.mode), " | ",
      "Risk: ", DoubleToString(m_state.current_risk_pct, 2), "% | ",
      "Daily DD: ", DoubleToString(m_state.daily_dd_pct, 2), "% | ",
      "Total DD: ", DoubleToString(m_state.total_dd_pct, 2), "%"
   );
}

ENUM_RISK_MODE CDynamicRiskManager::DetermineRiskMode()
{
   // Check FTMO hard limits first
   if(m_state.daily_dd_pct >= FTMO_MAX_DAILY_DD || 
      m_state.total_dd_pct >= FTMO_MAX_TOTAL_DD)
   {
      return RISK_MODE_HALTED;
   }
   
   // Check soft limits
   if(m_state.daily_dd_pct >= FTMO_SOFT_DAILY_DD || 
      m_state.total_dd_pct >= FTMO_SOFT_TOTAL_DD)
   {
      return RISK_MODE_EMERGENCY;
   }
   
   // Check warning levels
   if(m_state.daily_dd_pct >= FTMO_WARN_DAILY_DD || 
      m_state.total_dd_pct >= FTMO_WARN_TOTAL_DD)
   {
      return RISK_MODE_RECOVERY;
   }
   
   // Check consecutive losses
   if(m_consecutive_losses >= m_max_consecutive_losses)
   {
      return RISK_MODE_CAUTIOUS;
   }
   
   // Check winning streak
   if(m_consecutive_wins >= 3 && m_state.daily_pnl > 0)
   {
      return RISK_MODE_AGGRESSIVE;
   }
   
   return RISK_MODE_NORMAL;
}

double CDynamicRiskManager::CalculateDynamicRisk()
{
   double risk = m_base_risk_pct;
   
   // Adjust based on mode
   switch(m_state.mode)
   {
      case RISK_MODE_HALTED:
         risk = 0;
         break;
         
      case RISK_MODE_EMERGENCY:
         risk = m_min_risk_pct * 0.5;  // Half of minimum
         break;
         
      case RISK_MODE_RECOVERY:
         risk = m_min_risk_pct;
         break;
         
      case RISK_MODE_CAUTIOUS:
         risk = m_base_risk_pct * 0.5;
         break;
         
      case RISK_MODE_AGGRESSIVE:
         risk = MathMin(m_base_risk_pct * 1.5, m_max_risk_pct);
         break;
         
      case RISK_MODE_NORMAL:
      default:
         risk = m_base_risk_pct;
         break;
   }
   
   // Apply regime adjustment
   risk *= GetRegimeMultiplier();
   
   // Ensure within bounds
   risk = MathMax(0, MathMin(risk, m_max_risk_pct));
   
   return risk;
}

double CDynamicRiskManager::GetRegimeMultiplier()
{
   if(m_regime == NULL) return 1.0;
   
   SRegimeAnalysis analysis = m_regime.GetLastAnalysis();
   return analysis.size_multiplier;
}

double CDynamicRiskManager::GetCurrentRiskPercent()
{
   return m_state.current_risk_pct;
}

double CDynamicRiskManager::GetPositionSize(double sl_points)
{
   if(!CanOpenTrade() || sl_points <= 0) return 0;
   
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double risk_amount = equity * (m_state.current_risk_pct / 100.0);
   
   double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tick_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   if(tick_value <= 0 || point <= 0) return 0;
   
   // Convert SL points to ticks
   double sl_ticks = sl_points * (point / tick_size);
   
   // Calculate lots
   double lots = risk_amount / (sl_ticks * tick_value);
   
   // Normalize to symbol requirements
   double min_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double max_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   lots = MathFloor(lots / step) * step;
   lots = MathMax(min_lot, MathMin(lots, max_lot));
   
   return lots;
}

bool CDynamicRiskManager::CanOpenTrade()
{
   // Check FTMO limits
   if(IsTradingHalted()) return false;
   
   // Check emergency mode
   if(IsEmergencyMode()) return false;
   
   // Check cooldown
   if(IsInCooldown()) return false;
   
   // Check max trades per day
   if(m_trades_today >= m_max_trades_per_day)
   {
      Print("CDynamicRiskManager: Max trades per day reached (", m_max_trades_per_day, ")");
      return false;
   }
   
   // Check regime if available
   if(m_regime != NULL && !m_regime.IsTradingAllowed())
   {
      return false;
   }
   
   return true;
}

bool CDynamicRiskManager::IsTradingHalted()
{
   return m_state.mode == RISK_MODE_HALTED;
}

bool CDynamicRiskManager::IsEmergencyMode()
{
   return m_state.mode == RISK_MODE_EMERGENCY;
}

bool CDynamicRiskManager::IsInCooldown()
{
   return TimeCurrent() < m_cooldown_until;
}

void CDynamicRiskManager::ResetDailyStats()
{
   m_daily_start_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   m_daily_start_time = TimeCurrent();
   m_trades_today = 0;
   m_daily_pnl = 0;
   UpdateState();
}

void CDynamicRiskManager::ForceEmergencyMode(string reason)
{
   m_state.mode = RISK_MODE_EMERGENCY;
   m_state.can_trade = false;
   Print("CDynamicRiskManager: EMERGENCY MODE ACTIVATED - ", reason);
   Alert("EA Emergency Mode: ", reason);
}

void CDynamicRiskManager::ClearEmergencyMode()
{
   if(m_state.total_dd_pct < FTMO_SOFT_TOTAL_DD && 
      m_state.daily_dd_pct < FTMO_SOFT_DAILY_DD)
   {
      m_state.mode = RISK_MODE_CAUTIOUS;
      Print("CDynamicRiskManager: Emergency mode cleared");
   }
   else
   {
      Print("CDynamicRiskManager: Cannot clear emergency - DD still too high");
   }
}
