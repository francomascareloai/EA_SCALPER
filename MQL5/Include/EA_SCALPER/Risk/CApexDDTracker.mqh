//+------------------------------------------------------------------+
//|                                              CApexDDTracker.mqh |
//|                     EA_SCALPER_XAUUSD - Apex Prop Firm Compliant |
//|                     Migrated from Python nautilus_gold_scalper    |
//+------------------------------------------------------------------+
#ifndef CAPEXDDTRACKER_MQH
#define CAPEXDDTRACKER_MQH

#property copyright "EA_SCALPER_XAUUSD - Apex Compliant Trading System"
#property strict

#include "../Core/Definitions.mqh"
#include "../Core/IRiskGate.mqh"

//+------------------------------------------------------------------+
//| CApexDDTracker                                                    |
//|                                                                   |
//| High-Water Mark based drawdown tracker for Apex prop firms.       |
//| Implements IRiskGate interface for unified risk gate system.      |
//|                                                                   |
//| CRITICAL - Apex Rules:                                           |
//| 1. Trailing DD = 5% from HIGH-WATER MARK (includes unrealized)   |
//| 2. HWM NEVER decreases during session                            |
//| 3. NO overnight positions (close ALL by 4:59 PM ET)              |
//| 4. Max 30% profit/day (consistency rule - LIVE ACCOUNTS ONLY)    |
//|                                                                   |
//| CRITIC FIX #1 - DOUBLE-COUNT PREVENTION:                         |
//| AccountEquity() already includes floating P/L (unrealized).       |
//| DO NOT add unrealized_pnl separately - that would DOUBLE-COUNT!   |
//|                                                                   |
//| Correct:   equity = AccountInfoDouble(ACCOUNT_EQUITY);           |
//| WRONG:     equity = AccountEquity() + GetUnrealizedPnL(); // NO! |
//+------------------------------------------------------------------+

//--- 6-level severity thresholds (matches CLAUDE.md authoritative taxonomy)
//--- These thresholds are for TRAILING DD from HWM
#define APEX_DD_WARN        3.0    // Warning level
#define APEX_DD_CAUTION     3.5    // Caution, reduce exposure
#define APEX_DD_CRITICAL    4.0    // Critical, prepare to halt
#define APEX_DD_HALT        4.5    // HALT trading immediately
#define APEX_DD_TERMINATED  5.0    // APEX LIMIT - ACCOUNT BLOWN

//--- Daily DD thresholds (separate from trailing)
#define APEX_DAILY_WARN     1.5    // Daily warning
#define APEX_DAILY_CAUTION  2.0    // Daily caution
#define APEX_DAILY_REDUCE   2.5    // Daily reduce (50% position)
#define APEX_DAILY_HALT     3.0    // Daily HALT

//--- GlobalVariable key for HWM persistence (survives EA restarts)
#define GV_APEX_HWM_KEY     "EA_APEX_HWM_"

//+------------------------------------------------------------------+
//| Drawdown Analysis Structure                                       |
//+------------------------------------------------------------------+
struct SApexDDAnalysis
{
    // Current equity state
    double            current_equity;        // Current account equity
    double            high_water_mark;       // Session HWM (never decreases)
    double            session_start_equity;  // Equity at session start

    // Trailing DD (from HWM) - APEX KILLER
    double            trailing_dd_abs;       // Absolute trailing DD in currency
    double            trailing_dd_pct;       // Trailing DD as percentage

    // Daily DD (from session start)
    double            daily_dd_abs;          // Absolute daily DD in currency
    double            daily_dd_pct;          // Daily DD as percentage

    // Severity levels
    ENUM_DD_SEVERITY  trailing_severity;     // Trailing DD severity
    ENUM_DD_SEVERITY  daily_severity;        // Daily DD severity (not in enum, use same)
    ENUM_DD_SEVERITY  effective_severity;    // Worst of both

    // Dynamic limits
    double            dynamic_daily_limit;   // Calculated dynamic daily limit
    double            remaining_buffer;      // Buffer before APEX limit

    // Trading permission
    bool              can_trade;             // Overall trading permission
    ENUM_GATE_REASON  gate_reason;           // Reason for blocking
    string            status_message;        // Human-readable status

    void Reset()
    {
        current_equity = 0;
        high_water_mark = 0;
        session_start_equity = 0;
        trailing_dd_abs = 0;
        trailing_dd_pct = 0;
        daily_dd_abs = 0;
        daily_dd_pct = 0;
        trailing_severity = DD_NORMAL;
        daily_severity = DD_NORMAL;
        effective_severity = DD_NORMAL;
        dynamic_daily_limit = 3.0;
        remaining_buffer = 5.0;
        can_trade = true;
        gate_reason = GATE_OK;
        status_message = "Normal";
    }
};

//+------------------------------------------------------------------+
//| CApexDDTracker Class                                              |
//+------------------------------------------------------------------+
class CApexDDTracker : public IRiskGate
{
private:
    //--- State tracking
    double            m_current_equity;
    double            m_hwm;                 // High Water Mark - NEVER decreases
    double            m_session_start_equity;
    datetime          m_session_start_time;

    //--- HWM persistence (GlobalVariable)
    string            m_hwm_key;             // GlobalVariable key for HWM persistence

    //--- Cached analysis
    SApexDDAnalysis   m_analysis;
    datetime          m_last_update;

    //--- Configuration
    bool              m_initialized;

    //--- Internal methods
    void              UpdateInternal();
    ENUM_DD_SEVERITY  ClassifyTrailingSeverity(double dd_pct);
    ENUM_DD_SEVERITY  ClassifyDailySeverity(double dd_pct);

public:
                      CApexDDTracker();
                     ~CApexDDTracker();

    //--- Initialization
    bool              Init(double initial_equity = 0);
    void              ResetSession();

    //--- Core update - MUST call on every tick
    void              Update();

    //--- Getters - Trailing DD (APEX KILLER)
    double            GetHWM()                  { return m_hwm; }
    double            GetTrailingDDAbsolute()   { return m_analysis.trailing_dd_abs; }
    double            GetTrailingDDPercent()    { return m_analysis.trailing_dd_pct; }
    ENUM_DD_SEVERITY  GetTrailingSeverity()     { return m_analysis.trailing_severity; }

    //--- Getters - Daily DD
    double            GetSessionStartEquity()   { return m_session_start_equity; }
    double            GetDailyDDAbsolute()      { return m_analysis.daily_dd_abs; }
    double            GetDailyDDPercent()       { return m_analysis.daily_dd_pct; }

    //--- Dynamic Daily Limit (Task 2.3)
    double            GetDynamicDailyLimit();
    double            GetRemainingBuffer();

    //--- Overall analysis
    SApexDDAnalysis   GetAnalysis()             { return m_analysis; }
    bool              CanTrade()                { return m_analysis.can_trade; }
    string            GetStatusMessage()        { return m_analysis.status_message; }

    //--- IRiskGate interface implementation
    virtual bool              IsBlocked(void)   { return !m_analysis.can_trade; }
    virtual ENUM_GATE_REASON  GetReason(void)   { return m_analysis.gate_reason; }
    virtual string            GetReasonText(void);
    virtual void              OnTick(void)      { Update(); }
    virtual void              Reset(void)       { ResetSession(); }
    virtual string            GetGateName(void) { return "ApexDDTracker"; }

    //--- Debug
    void              PrintStatus();
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CApexDDTracker::CApexDDTracker()
{
    m_current_equity = 0;
    m_hwm = 0;
    m_session_start_equity = 0;
    m_session_start_time = 0;
    m_last_update = 0;
    m_initialized = false;

    m_analysis.Reset();
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CApexDDTracker::~CApexDDTracker()
{
}

//+------------------------------------------------------------------+
//| Initialize tracker                                                |
//+------------------------------------------------------------------+
bool CApexDDTracker::Init(double initial_equity)
{
    //--- Get initial equity
    //--- CRITIC FIX #1: AccountEquity() already includes floating P/L
    if(initial_equity <= 0)
        m_current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
    else
        m_current_equity = initial_equity;

    //--- Validate
    if(m_current_equity <= 0)
    {
        Print("CApexDDTracker: ERROR - Invalid initial equity: ", m_current_equity);
        return false;
    }

    //--- Initialize HWM persistence key (symbol-specific)
    m_hwm_key = GV_APEX_HWM_KEY + _Symbol;

    //--- Initialize all anchors
    m_hwm = m_current_equity;
    m_session_start_equity = m_current_equity;
    m_session_start_time = TimeCurrent();
    m_last_update = TimeCurrent();

    //--- Restore HWM from GlobalVariable if exists (survives EA restart)
    if(GlobalVariableCheck(m_hwm_key))
    {
        double saved_hwm = GlobalVariableGet(m_hwm_key);
        // Only use saved HWM if it's higher (HWM never decreases)
        if(saved_hwm > m_hwm)
        {
            m_hwm = saved_hwm;
            Print("CApexDDTracker: Restored HWM from GlobalVariable: ", DoubleToString(m_hwm, 2));
        }
    }

    //--- Reset analysis
    m_analysis.Reset();
    m_analysis.current_equity = m_current_equity;
    m_analysis.high_water_mark = m_hwm;
    m_analysis.session_start_equity = m_session_start_equity;
    m_analysis.remaining_buffer = 5.0;
    m_analysis.dynamic_daily_limit = GetDynamicDailyLimit();

    m_initialized = true;

    Print("CApexDDTracker: Initialized");
    Print("  Initial Equity: ", DoubleToString(m_current_equity, 2));
    Print("  HWM: ", DoubleToString(m_hwm, 2));
    Print("  HWM Key: ", m_hwm_key);
    Print("  Session Start: ", TimeToString(m_session_start_time));

    return true;
}

//+------------------------------------------------------------------+
//| Reset for new session (daily reset)                               |
//| NOTE: HWM does NOT reset - only daily start equity resets         |
//+------------------------------------------------------------------+
void CApexDDTracker::ResetSession()
{
    //--- CRITIC FIX #1: AccountEquity() already includes floating P/L
    m_current_equity = AccountInfoDouble(ACCOUNT_EQUITY);

    //--- Reset session start (daily DD calculation)
    m_session_start_equity = m_current_equity;
    m_session_start_time = TimeCurrent();

    //--- NOTE: HWM does NOT reset - it's monotonic across the evaluation period
    //--- This is intentional for Apex prop firm rules

    Print("CApexDDTracker: Session reset");
    Print("  Session Start Equity: ", DoubleToString(m_session_start_equity, 2));
    Print("  HWM (unchanged): ", DoubleToString(m_hwm, 2));

    //--- Update analysis
    UpdateInternal();
}

//+------------------------------------------------------------------+
//| Update - MUST call on every tick                                  |
//| CRITIC FIX #1: Uses ONLY AccountEquity() - no double-counting!    |
//+------------------------------------------------------------------+
void CApexDDTracker::Update()
{
    if(!m_initialized)
    {
        Init();
        return;
    }

    UpdateInternal();
}

//+------------------------------------------------------------------+
//| Internal update logic                                             |
//+------------------------------------------------------------------+
void CApexDDTracker::UpdateInternal()
{
    //=========================================================
    // CRITIC FIX #1: AccountEquity() ALREADY includes floating P/L
    // DO NOT add unrealized_pnl separately - that would DOUBLE-COUNT!
    //
    // Correct usage:
    //   m_current_equity = AccountInfoDouble(ACCOUNT_EQUITY);
    //
    // WRONG (double-counts):
    //   m_current_equity = AccountInfoDouble(ACCOUNT_EQUITY) + GetUnrealizedPnL();
    //=========================================================
    m_current_equity = AccountInfoDouble(ACCOUNT_EQUITY);

    //--- Validate equity
    if(m_current_equity <= 0)
    {
        Print("CApexDDTracker: WARNING - Invalid equity: ", m_current_equity);
        return;
    }

    //--- Update HWM (NEVER decreases)
    //--- Formula: HWM = max(HWM, current_equity)
    //--- Example: HWM=50000, equity=52000 -> HWM=52000
    //---          HWM=52000, equity=50000 -> HWM=52000 (unchanged)
    if(m_current_equity > m_hwm)
    {
        m_hwm = m_current_equity;
        //--- Persist HWM to GlobalVariable (survives EA restart)
        GlobalVariableSet(m_hwm_key, m_hwm);
    }

    //--- Calculate Trailing DD (from HWM) - THE APEX KILLER
    //--- Formula: trailing_dd_pct = (HWM - current) / HWM * 100
    //--- Example: HWM=52000, equity=50000
    //---          trailing_dd_pct = (52000-50000) / 52000 * 100 = 3.85%
    m_analysis.trailing_dd_abs = MathMax(0.0, m_hwm - m_current_equity);

    if(m_hwm > 0)
    {
        m_analysis.trailing_dd_pct = (m_analysis.trailing_dd_abs / m_hwm) * 100.0;
    }
    else
    {
        m_analysis.trailing_dd_pct = 0.0;
    }

    //--- Validate trailing DD range
    //--- Assertion: 0 <= trailing_dd_pct <= 100
    if(m_analysis.trailing_dd_pct < 0 || m_analysis.trailing_dd_pct > 100)
    {
        Print("CApexDDTracker: ASSERTION FAILED - Invalid trailing DD%: ",
              DoubleToString(m_analysis.trailing_dd_pct, 2));
        m_analysis.trailing_dd_pct = MathMax(0.0, MathMin(100.0, m_analysis.trailing_dd_pct));
    }

    //--- Calculate Daily DD (from session start)
    //--- Formula: daily_dd_pct = (session_start - current) / session_start * 100
    //--- Example: session_start=50000, equity=49000
    //---          daily_dd_pct = (50000-49000) / 50000 * 100 = 2.0%
    m_analysis.daily_dd_abs = MathMax(0.0, m_session_start_equity - m_current_equity);

    if(m_session_start_equity > 0)
    {
        m_analysis.daily_dd_pct = (m_analysis.daily_dd_abs / m_session_start_equity) * 100.0;
    }
    else
    {
        m_analysis.daily_dd_pct = 0.0;
    }

    //--- Validate daily DD range
    if(m_analysis.daily_dd_pct < 0 || m_analysis.daily_dd_pct > 100)
    {
        Print("CApexDDTracker: ASSERTION FAILED - Invalid daily DD%: ",
              DoubleToString(m_analysis.daily_dd_pct, 2));
        m_analysis.daily_dd_pct = MathMax(0.0, MathMin(100.0, m_analysis.daily_dd_pct));
    }

    //--- Classify severity levels
    m_analysis.trailing_severity = ClassifyTrailingSeverity(m_analysis.trailing_dd_pct);
    m_analysis.daily_severity = ClassifyDailySeverity(m_analysis.daily_dd_pct);

    //--- Effective severity is the WORSE of both
    m_analysis.effective_severity = (ENUM_DD_SEVERITY)MathMax(
        (int)m_analysis.trailing_severity,
        (int)m_analysis.daily_severity
    );

    //--- Update state values
    m_analysis.current_equity = m_current_equity;
    m_analysis.high_water_mark = m_hwm;
    m_analysis.session_start_equity = m_session_start_equity;
    m_analysis.remaining_buffer = GetRemainingBuffer();
    m_analysis.dynamic_daily_limit = GetDynamicDailyLimit();

    //--- Determine trading permission
    //--- HARD BLOCKS from CLAUDE.md:
    //--- Trailing DD >= 4.0% OR Daily DD >= 3.0% -> HALT immediately
    m_analysis.can_trade = true;
    m_analysis.gate_reason = GATE_OK;

    if(m_analysis.trailing_dd_pct >= APEX_DD_CRITICAL)
    {
        m_analysis.can_trade = false;
        m_analysis.gate_reason = GATE_DD_TRAILING;
    }

    if(m_analysis.daily_dd_pct >= APEX_DAILY_HALT)
    {
        m_analysis.can_trade = false;
        m_analysis.gate_reason = CombineGateReasons(m_analysis.gate_reason, GATE_DD_DAILY);
    }

    //--- Generate status message
    if(m_analysis.trailing_severity == DD_TERMINATED)
    {
        m_analysis.status_message = "TERMINATED - Apex limit breached!";
    }
    else if(m_analysis.trailing_severity == DD_HALT || m_analysis.daily_severity >= DD_CRITICAL)
    {
        m_analysis.status_message = "HALT - Trading stopped";
    }
    else if(m_analysis.trailing_severity == DD_CRITICAL)
    {
        m_analysis.status_message = "CRITICAL - Prepare to halt";
    }
    else if(m_analysis.trailing_severity == DD_CAUTION || m_analysis.daily_severity >= DD_CAUTION)
    {
        m_analysis.status_message = "CAUTION - Reduce exposure";
    }
    else if(m_analysis.trailing_severity == DD_WARN || m_analysis.daily_severity >= DD_WARN)
    {
        m_analysis.status_message = "WARNING - Monitor closely";
    }
    else
    {
        m_analysis.status_message = "NORMAL";
    }

    m_last_update = TimeCurrent();
}

//+------------------------------------------------------------------+
//| Classify trailing DD severity (from HWM)                          |
//| Uses 6-level taxonomy from CLAUDE.md                              |
//+------------------------------------------------------------------+
ENUM_DD_SEVERITY CApexDDTracker::ClassifyTrailingSeverity(double dd_pct)
{
    //--- 6-level severity from CLAUDE.md dd_limits taxonomy
    //--- Trailing DD from HWM (includes unrealized) - APEX KILLER

    if(dd_pct >= APEX_DD_TERMINATED)    // 5.0%
        return DD_TERMINATED;
    if(dd_pct >= APEX_DD_HALT)          // 4.5%
        return DD_HALT;
    if(dd_pct >= APEX_DD_CRITICAL)      // 4.0%
        return DD_CRITICAL;
    if(dd_pct >= APEX_DD_CAUTION)       // 3.5%
        return DD_CAUTION;
    if(dd_pct >= APEX_DD_WARN)          // 3.0%
        return DD_WARN;

    return DD_NORMAL;
}

//+------------------------------------------------------------------+
//| Classify daily DD severity (from session start)                   |
//| Uses daily taxonomy from CLAUDE.md                                |
//+------------------------------------------------------------------+
ENUM_DD_SEVERITY CApexDDTracker::ClassifyDailySeverity(double dd_pct)
{
    //--- Daily DD thresholds from CLAUDE.md
    //--- WARN=1.5%, CAUTION=2.0%, REDUCE=2.5%, HALT=3.0%

    if(dd_pct >= APEX_DAILY_HALT)       // 3.0%
        return DD_HALT;
    if(dd_pct >= APEX_DAILY_REDUCE)     // 2.5%
        return DD_CRITICAL;             // Maps to REDUCE action
    if(dd_pct >= APEX_DAILY_CAUTION)    // 2.0%
        return DD_CAUTION;
    if(dd_pct >= APEX_DAILY_WARN)       // 1.5%
        return DD_WARN;

    return DD_NORMAL;
}

//+------------------------------------------------------------------+
//| Get Dynamic Daily Limit (Task 2.3)                                |
//|                                                                   |
//| Formula: dynamic_limit = MIN(3.0%, remaining_buffer * 0.6)        |
//|                                                                   |
//| Example 1: trailing_dd = 0% (fresh account)                       |
//|   remaining_buffer = 5.0 - 0.0 = 5.0%                            |
//|   dynamic = 5.0 * 0.6 = 3.0%                                     |
//|   result = MIN(3.0, 3.0) = 3.0%                                  |
//|                                                                   |
//| Example 2: trailing_dd = 2%                                       |
//|   remaining_buffer = 5.0 - 2.0 = 3.0%                            |
//|   dynamic = 3.0 * 0.6 = 1.8%                                     |
//|   result = MIN(3.0, 1.8) = 1.8%                                  |
//|                                                                   |
//| Example 3: trailing_dd = 4%                                       |
//|   remaining_buffer = 5.0 - 4.0 = 1.0%                            |
//|   dynamic = 1.0 * 0.6 = 0.6%                                     |
//|   result = MIN(3.0, 0.6) = 0.6%                                  |
//+------------------------------------------------------------------+
double CApexDDTracker::GetDynamicDailyLimit()
{
    //--- Calculate remaining buffer before Apex termination
    double remaining_buffer = 5.0 - m_analysis.trailing_dd_pct;

    //--- Apply 60% safety factor
    double dynamic = remaining_buffer * 0.6;

    //--- Clamp to [0, 3.0] range
    //--- Max is 3.0% (default daily limit)
    //--- Min is 0% (no more risk allowed)
    return MathMin(3.0, MathMax(0.0, dynamic));
}

//+------------------------------------------------------------------+
//| Get remaining buffer before Apex termination                      |
//+------------------------------------------------------------------+
double CApexDDTracker::GetRemainingBuffer()
{
    //--- Formula: remaining = 5.0 - trailing_dd_pct
    //--- Example: trailing_dd = 3.5% -> remaining = 1.5%
    return MathMax(0.0, 5.0 - m_analysis.trailing_dd_pct);
}

//+------------------------------------------------------------------+
//| Get reason text (IRiskGate interface)                             |
//+------------------------------------------------------------------+
string CApexDDTracker::GetReasonText(void)
{
    if(m_analysis.gate_reason == GATE_OK)
        return "OK";

    string reasons = "";

    if(HasGateReason(m_analysis.gate_reason, GATE_DD_TRAILING))
    {
        reasons += StringFormat("Trailing DD %.2f%% >= %.1f%%",
                               m_analysis.trailing_dd_pct, APEX_DD_CRITICAL);
    }

    if(HasGateReason(m_analysis.gate_reason, GATE_DD_DAILY))
    {
        if(reasons != "") reasons += " | ";
        reasons += StringFormat("Daily DD %.2f%% >= %.1f%%",
                               m_analysis.daily_dd_pct, APEX_DAILY_HALT);
    }

    return reasons != "" ? reasons : "Unknown";
}

//+------------------------------------------------------------------+
//| Print current status                                              |
//+------------------------------------------------------------------+
void CApexDDTracker::PrintStatus()
{
    Print("=== Apex DD Tracker Status ===");
    Print("Current Equity: ", DoubleToString(m_current_equity, 2));
    Print("HWM: ", DoubleToString(m_hwm, 2));
    Print("Session Start: ", DoubleToString(m_session_start_equity, 2));
    Print("---");
    Print("Trailing DD: ", DoubleToString(m_analysis.trailing_dd_pct, 2),
          "% (", EnumToString(m_analysis.trailing_severity), ")");
    Print("Daily DD: ", DoubleToString(m_analysis.daily_dd_pct, 2),
          "% (", EnumToString(m_analysis.daily_severity), ")");
    Print("---");
    Print("Remaining Buffer: ", DoubleToString(GetRemainingBuffer(), 2), "%");
    Print("Dynamic Daily Limit: ", DoubleToString(GetDynamicDailyLimit(), 2), "%");
    Print("---");
    Print("Can Trade: ", m_analysis.can_trade);
    Print("Gate Reason: ", GateReasonToString(m_analysis.gate_reason));
    Print("Status: ", m_analysis.status_message);
    Print("==============================");
}

#endif // CAPEXDDTRACKER_MQH
//+------------------------------------------------------------------+
