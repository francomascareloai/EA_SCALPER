//+------------------------------------------------------------------+
//|                                             CCircuitBreaker.mqh |
//|                                                           Franco |
//|                   EA_SCALPER_XAUUSD v4.0 - Safety Layer          |
//+------------------------------------------------------------------+
#property copyright "Franco"
#property link      "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Circuit Breaker State                                             |
//+------------------------------------------------------------------+
enum ENUM_CIRCUIT_STATE
{
   CIRCUIT_NORMAL = 0,      // Trading normally
   CIRCUIT_WARNING = 1,     // Approaching limits
   CIRCUIT_TRIGGERED = 2,   // Circuit breaker active
   CIRCUIT_COOLDOWN = 3     // In cooldown period
};

//+------------------------------------------------------------------+
//| Trigger Reason                                                    |
//+------------------------------------------------------------------+
enum ENUM_TRIGGER_REASON
{
   TRIGGER_NONE = 0,
   TRIGGER_DAILY_DD = 1,         // Daily drawdown limit hit
   TRIGGER_TOTAL_DD = 2,         // Total drawdown limit hit
   TRIGGER_CONSECUTIVE_LOSS = 3, // Too many consecutive losses
   TRIGGER_MANUAL = 4,           // Manually triggered
   TRIGGER_EMERGENCY = 5         // Emergency stop
};

//+------------------------------------------------------------------+
//| Circuit Breaker Status                                            |
//+------------------------------------------------------------------+
struct SCircuitStatus
{
   ENUM_CIRCUIT_STATE state;
   ENUM_TRIGGER_REASON trigger_reason;
   
   double            current_equity;
   double            daily_start_equity;
   double            peak_equity;
   double            initial_balance;
   
   double            daily_dd_percent;
   double            total_dd_percent;
   double            daily_dd_limit;
   double            total_dd_limit;
   
   int               consecutive_losses;
   int               max_consecutive_losses;
   
   datetime          trigger_time;
   datetime          cooldown_end;
   int               cooldown_minutes;
   
   bool              can_trade;
   string            reason;
   
   void Reset()
   {
      state = CIRCUIT_NORMAL;
      trigger_reason = TRIGGER_NONE;
      current_equity = 0;
      daily_start_equity = 0;
      peak_equity = 0;
      initial_balance = 0;
      daily_dd_percent = 0;
      total_dd_percent = 0;
      daily_dd_limit = 2.5;       // APEX: 3% max, trigger at 2.5%
      total_dd_limit = 4.0;       // APEX: 5% max, trigger at 4%
      consecutive_losses = 0;
      max_consecutive_losses = 5;
      trigger_time = 0;
      cooldown_end = 0;
      cooldown_minutes = 120;
      can_trade = true;
      reason = "Normal";
   }
};

//+------------------------------------------------------------------+
//| Class: CCircuitBreaker                                            |
//| Purpose: Protect account from catastrophic losses                 |
//|                                                                   |
//| APEX Rules Implemented:                                           |
//| - Max Trailing DD: 5% from HWM (we trigger at 4% for safety)      |
//| - Max Daily DD: 3% (we trigger at 2.5% for safety buffer)         |
//+------------------------------------------------------------------+
class CCircuitBreaker
{
private:
   //--- Configuration
   double            m_daily_dd_limit;      // Daily DD limit (%)
   double            m_total_dd_limit;      // Total DD limit (%)
   double            m_warning_threshold;   // Warning at this % of limit
   int               m_max_consecutive;     // Max consecutive losses
   int               m_cooldown_minutes;    // Cooldown after trigger
   
   //--- State tracking
   double            m_initial_balance;     // Starting balance
   double            m_daily_start_equity;  // Equity at day start
   double            m_peak_equity;         // High water mark
   int               m_consecutive_losses;  // Current loss streak
   
   //--- Trigger state
   ENUM_CIRCUIT_STATE m_state;
   ENUM_TRIGGER_REASON m_trigger_reason;
   datetime          m_trigger_time;
   datetime          m_cooldown_end;
   datetime          m_last_day;
   
   //--- Status cache
   SCircuitStatus    m_status;
   datetime          m_last_update;
   
public:
                     CCircuitBreaker();
                    ~CCircuitBreaker();
   
   //--- Initialization (APEX-aligned defaults)
   bool              Init(double daily_dd = 2.5, double total_dd = 4.0,
                          int max_consecutive = 5, int cooldown_min = 120);
   void              SetLimits(double daily_dd, double total_dd);
   void              SetConsecutiveLossLimit(int max_losses) { m_max_consecutive = max_losses; }
   void              SetCooldownMinutes(int minutes) { m_cooldown_minutes = minutes; }
   
   //--- Main Check (call on every tick or timer)
   bool              Check();
   bool              CanTrade() { Check(); return m_status.can_trade; }
   
   //--- State access
   ENUM_CIRCUIT_STATE GetState() { Check(); return m_state; }
   SCircuitStatus    GetStatus() { Check(); return m_status; }
   bool              IsTriggered() { return m_state == CIRCUIT_TRIGGERED; }
   bool              IsInCooldown() { return m_state == CIRCUIT_COOLDOWN; }
   
   //--- Drawdown info
   double            GetDailyDD() { Check(); return m_status.daily_dd_percent; }
   double            GetTotalDD() { Check(); return m_status.total_dd_percent; }
   double            GetEquity() { return AccountInfoDouble(ACCOUNT_EQUITY); }
   
   //--- Events
   void              OnTradeResult(bool is_win, double profit_loss);
   void              OnNewDay();
   
   //--- Manual controls
   void              TriggerEmergency(string reason);
   void              Reset();
   void              ManualReset();
   
   //--- Utility
   void              PrintStatus();
   string            GetStatusString();

private:
   void              UpdateStatus();
   void              CheckDailyDD();
   void              CheckTotalDD();
   void              CheckConsecutiveLosses();
   void              CheckCooldown();
   void              TriggerCircuit(ENUM_TRIGGER_REASON reason, string message);
   void              StartCooldown();
   bool              IsNewDay();
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CCircuitBreaker::CCircuitBreaker()
{
   //--- APEX limits (with safety buffer):
   //--- Apex Max Trailing DD = 5% -> trigger at 4%
   //--- Apex Max Daily DD = 3% -> trigger at 2.5%
   m_daily_dd_limit = 2.5;       // Daily DD limit (APEX: 3% max)
   m_total_dd_limit = 4.0;       // Trailing DD limit (APEX: 5% max)
   m_warning_threshold = 0.75;   // Warn at 75% of limit
   m_max_consecutive = 5;
   m_cooldown_minutes = 120;
   
   m_initial_balance = 0;
   m_daily_start_equity = 0;
   m_peak_equity = 0;
   m_consecutive_losses = 0;
   
   m_state = CIRCUIT_NORMAL;
   m_trigger_reason = TRIGGER_NONE;
   m_trigger_time = 0;
   m_cooldown_end = 0;
   m_last_day = 0;
   
   m_last_update = 0;
   m_status.Reset();
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CCircuitBreaker::~CCircuitBreaker()
{
}

//+------------------------------------------------------------------+
//| Initialize                                                        |
//| @param daily_dd:  Daily DD limit % (APEX: 3% max, trigger at 2.5)|
//| @param total_dd:  Trailing DD limit % (APEX: 5% max, trigger at 4)|
//+------------------------------------------------------------------+
bool CCircuitBreaker::Init(double daily_dd = 2.5, double total_dd = 4.0,
                            int max_consecutive = 5, int cooldown_min = 120)
{
   m_daily_dd_limit = daily_dd;
   m_total_dd_limit = total_dd;
   m_max_consecutive = max_consecutive;
   m_cooldown_minutes = cooldown_min;
   
   // Initialize tracking values
   m_initial_balance = AccountInfoDouble(ACCOUNT_BALANCE);
   m_daily_start_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   m_peak_equity = m_daily_start_equity;
   m_consecutive_losses = 0;
   
   m_state = CIRCUIT_NORMAL;
   m_trigger_reason = TRIGGER_NONE;
   
   MqlDateTime dt;
   TimeToStruct(TimeGMT(), dt);
   m_last_day = dt.day;
   
   // Initial status update
   UpdateStatus();
   
   Print("CCircuitBreaker: Initialized");
   Print("  Daily DD Limit: ", m_daily_dd_limit, "%");
   Print("  Total DD Limit: ", m_total_dd_limit, "%");
   Print("  Max Consecutive Losses: ", m_max_consecutive);
   Print("  Cooldown: ", m_cooldown_minutes, " minutes");
   Print("  Initial Balance: ", m_initial_balance);
   
   return true;
}

//+------------------------------------------------------------------+
//| Set limits                                                        |
//+------------------------------------------------------------------+
void CCircuitBreaker::SetLimits(double daily_dd, double total_dd)
{
   m_daily_dd_limit = daily_dd;
   m_total_dd_limit = total_dd;
}

//+------------------------------------------------------------------+
//| Main check function                                               |
//+------------------------------------------------------------------+
bool CCircuitBreaker::Check()
{
   // Don't check too frequently
   datetime now = TimeGMT();
   if(now - m_last_update < 1)  // Max 1 check per second
      return m_status.can_trade;
   
   m_last_update = now;
   
   // Check for new day
   if(IsNewDay())
      OnNewDay();
   
   // Update peak equity
   double current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   if(current_equity > m_peak_equity)
      m_peak_equity = current_equity;
   
   // Check cooldown first
   CheckCooldown();
   
   // If in cooldown, don't check other triggers
   if(m_state == CIRCUIT_COOLDOWN)
   {
      UpdateStatus();
      return false;
   }
   
   // If already triggered, stay triggered
   if(m_state == CIRCUIT_TRIGGERED)
   {
      UpdateStatus();
      return false;
   }
   
   // Check all triggers
   CheckDailyDD();
   CheckTotalDD();
   CheckConsecutiveLosses();
   
   // Update status
   UpdateStatus();
   
   return m_status.can_trade;
}

//+------------------------------------------------------------------+
//| Check daily drawdown                                              |
//+------------------------------------------------------------------+
void CCircuitBreaker::CheckDailyDD()
{
   if(m_state == CIRCUIT_TRIGGERED)
      return;
   
   double current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double daily_dd = (m_daily_start_equity - current_equity) / m_daily_start_equity * 100;
   
   if(daily_dd >= m_daily_dd_limit)
   {
      TriggerCircuit(TRIGGER_DAILY_DD, 
         StringFormat("Daily DD %.2f%% exceeded limit %.2f%%", daily_dd, m_daily_dd_limit));
   }
   else if(daily_dd >= m_daily_dd_limit * m_warning_threshold)
   {
      if(m_state == CIRCUIT_NORMAL)
      {
         m_state = CIRCUIT_WARNING;
         Print("CCircuitBreaker: WARNING - Daily DD at ", DoubleToString(daily_dd, 2), "%");
      }
   }
}

//+------------------------------------------------------------------+
//| Check total drawdown                                              |
//+------------------------------------------------------------------+
void CCircuitBreaker::CheckTotalDD()
{
   if(m_state == CIRCUIT_TRIGGERED)
      return;
   
   double current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double total_dd = (m_peak_equity - current_equity) / m_peak_equity * 100;
   
   if(total_dd >= m_total_dd_limit)
   {
      TriggerCircuit(TRIGGER_TOTAL_DD,
         StringFormat("Total DD %.2f%% exceeded limit %.2f%%", total_dd, m_total_dd_limit));
   }
   else if(total_dd >= m_total_dd_limit * m_warning_threshold)
   {
      if(m_state == CIRCUIT_NORMAL)
      {
         m_state = CIRCUIT_WARNING;
         Print("CCircuitBreaker: WARNING - Total DD at ", DoubleToString(total_dd, 2), "%");
      }
   }
}

//+------------------------------------------------------------------+
//| Check consecutive losses                                          |
//+------------------------------------------------------------------+
void CCircuitBreaker::CheckConsecutiveLosses()
{
   if(m_state == CIRCUIT_TRIGGERED)
      return;
   
   if(m_consecutive_losses >= m_max_consecutive)
   {
      TriggerCircuit(TRIGGER_CONSECUTIVE_LOSS,
         StringFormat("%d consecutive losses exceeded limit %d", 
                      m_consecutive_losses, m_max_consecutive));
   }
}

//+------------------------------------------------------------------+
//| Check cooldown                                                    |
//+------------------------------------------------------------------+
void CCircuitBreaker::CheckCooldown()
{
   if(m_state != CIRCUIT_COOLDOWN)
      return;
   
   if(TimeGMT() >= m_cooldown_end)
   {
      m_state = CIRCUIT_NORMAL;
      m_trigger_reason = TRIGGER_NONE;
      Print("CCircuitBreaker: Cooldown ended, trading resumed");
   }
}

//+------------------------------------------------------------------+
//| Trigger circuit breaker                                           |
//+------------------------------------------------------------------+
void CCircuitBreaker::TriggerCircuit(ENUM_TRIGGER_REASON reason, string message)
{
   m_state = CIRCUIT_TRIGGERED;
   m_trigger_reason = reason;
   m_trigger_time = TimeGMT();
   
   Print("=== CIRCUIT BREAKER TRIGGERED ===");
   Print("Reason: ", message);
   Print("Time: ", TimeToString(m_trigger_time, TIME_DATE | TIME_MINUTES));
   Print("=================================");
   
   // Alert the trader
   Alert("EA CIRCUIT BREAKER: ", message);
   
   // Start cooldown
   StartCooldown();
}

//+------------------------------------------------------------------+
//| Start cooldown period                                             |
//+------------------------------------------------------------------+
void CCircuitBreaker::StartCooldown()
{
   m_state = CIRCUIT_COOLDOWN;
   m_cooldown_end = TimeGMT() + m_cooldown_minutes * 60;
   
   Print("CCircuitBreaker: Cooldown started for ", m_cooldown_minutes, " minutes");
   Print("CCircuitBreaker: Trading will resume at ", 
         TimeToString(m_cooldown_end, TIME_DATE | TIME_MINUTES));
}

//+------------------------------------------------------------------+
//| On trade result                                                   |
//+------------------------------------------------------------------+
void CCircuitBreaker::OnTradeResult(bool is_win, double profit_loss)
{
   if(is_win)
   {
      m_consecutive_losses = 0;
   }
   else
   {
      m_consecutive_losses++;
      Print("CCircuitBreaker: Consecutive losses: ", m_consecutive_losses);
      
      // Check immediately after loss
      Check();
   }
}

//+------------------------------------------------------------------+
//| On new day                                                        |
//+------------------------------------------------------------------+
void CCircuitBreaker::OnNewDay()
{
   m_daily_start_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   
   MqlDateTime dt;
   TimeToStruct(TimeGMT(), dt);
   m_last_day = dt.day;
   
   // Don't reset if in triggered state (serious issue)
   if(m_state == CIRCUIT_WARNING)
   {
      m_state = CIRCUIT_NORMAL;
      Print("CCircuitBreaker: New day - state reset to NORMAL");
   }
   
   Print("CCircuitBreaker: New day started, daily equity: ", m_daily_start_equity);
}

//+------------------------------------------------------------------+
//| Check if new day                                                  |
//+------------------------------------------------------------------+
bool CCircuitBreaker::IsNewDay()
{
   MqlDateTime dt;
   TimeToStruct(TimeGMT(), dt);
   return dt.day != m_last_day;
}

//+------------------------------------------------------------------+
//| Trigger emergency stop                                            |
//+------------------------------------------------------------------+
void CCircuitBreaker::TriggerEmergency(string reason)
{
   TriggerCircuit(TRIGGER_EMERGENCY, "EMERGENCY: " + reason);
}

//+------------------------------------------------------------------+
//| Reset state                                                       |
//+------------------------------------------------------------------+
void CCircuitBreaker::Reset()
{
   m_initial_balance = AccountInfoDouble(ACCOUNT_BALANCE);
   m_daily_start_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   m_peak_equity = m_daily_start_equity;
   m_consecutive_losses = 0;
   
   m_state = CIRCUIT_NORMAL;
   m_trigger_reason = TRIGGER_NONE;
   m_trigger_time = 0;
   m_cooldown_end = 0;
   
   UpdateStatus();
   
   Print("CCircuitBreaker: State reset");
}

//+------------------------------------------------------------------+
//| Manual reset (careful!)                                           |
//+------------------------------------------------------------------+
void CCircuitBreaker::ManualReset()
{
   Print("CCircuitBreaker: MANUAL RESET requested");
   Reset();
}

//+------------------------------------------------------------------+
//| Update status structure                                           |
//+------------------------------------------------------------------+
void CCircuitBreaker::UpdateStatus()
{
   m_status.state = m_state;
   m_status.trigger_reason = m_trigger_reason;
   
   m_status.current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   m_status.daily_start_equity = m_daily_start_equity;
   m_status.peak_equity = m_peak_equity;
   m_status.initial_balance = m_initial_balance;
   
   // Calculate DDs
   if(m_daily_start_equity > 0)
      m_status.daily_dd_percent = (m_daily_start_equity - m_status.current_equity) / m_daily_start_equity * 100;
   else
      m_status.daily_dd_percent = 0;
   
   if(m_peak_equity > 0)
      m_status.total_dd_percent = (m_peak_equity - m_status.current_equity) / m_peak_equity * 100;
   else
      m_status.total_dd_percent = 0;
   
   m_status.daily_dd_limit = m_daily_dd_limit;
   m_status.total_dd_limit = m_total_dd_limit;
   
   m_status.consecutive_losses = m_consecutive_losses;
   m_status.max_consecutive_losses = m_max_consecutive;
   
   m_status.trigger_time = m_trigger_time;
   m_status.cooldown_end = m_cooldown_end;
   m_status.cooldown_minutes = m_cooldown_minutes;
   
   // Determine if can trade
   m_status.can_trade = (m_state == CIRCUIT_NORMAL || m_state == CIRCUIT_WARNING);
   
   // Build reason string
   switch(m_state)
   {
      case CIRCUIT_NORMAL:
         m_status.reason = "Normal";
         break;
      case CIRCUIT_WARNING:
         m_status.reason = StringFormat("Warning: DD at %.1f%%", 
                           MathMax(m_status.daily_dd_percent, m_status.total_dd_percent));
         break;
      case CIRCUIT_TRIGGERED:
         m_status.reason = "TRIGGERED - Trading blocked";
         break;
      case CIRCUIT_COOLDOWN:
         int remaining = (int)((m_cooldown_end - TimeGMT()) / 60);
         m_status.reason = StringFormat("Cooldown: %d min remaining", remaining);
         break;
   }
}

//+------------------------------------------------------------------+
//| Print status                                                      |
//+------------------------------------------------------------------+
void CCircuitBreaker::PrintStatus()
{
   Check();
   
   Print("=== Circuit Breaker Status ===");
   Print("State: ", GetStatusString());
   Print("Can Trade: ", m_status.can_trade);
   Print("Daily DD: ", DoubleToString(m_status.daily_dd_percent, 2), "% / ", m_status.daily_dd_limit, "%");
   Print("Total DD: ", DoubleToString(m_status.total_dd_percent, 2), "% / ", m_status.total_dd_limit, "%");
   Print("Consecutive Losses: ", m_status.consecutive_losses, " / ", m_status.max_consecutive_losses);
   Print("Equity: ", m_status.current_equity);
   Print("Peak: ", m_status.peak_equity);
   Print("Reason: ", m_status.reason);
   Print("==============================");
}

//+------------------------------------------------------------------+
//| Get status string                                                 |
//+------------------------------------------------------------------+
string CCircuitBreaker::GetStatusString()
{
   switch(m_state)
   {
      case CIRCUIT_NORMAL:    return "NORMAL";
      case CIRCUIT_WARNING:   return "WARNING";
      case CIRCUIT_TRIGGERED: return "TRIGGERED";
      case CIRCUIT_COOLDOWN:  return "COOLDOWN";
      default:                return "UNKNOWN";
   }
}

//+------------------------------------------------------------------+
