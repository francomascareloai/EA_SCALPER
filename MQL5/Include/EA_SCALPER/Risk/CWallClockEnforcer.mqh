//+------------------------------------------------------------------+
//|                                            CWallClockEnforcer.mqh |
//|                     EA_SCALPER_XAUUSD - Apex Compliant Trading    |
//|                     Wall-Clock Time Enforcement (Task 2.5)        |
//+------------------------------------------------------------------+
//| CRITIC FIX #4: Idempotent OnTimer design                          |
//| - Works even if OnTimer was delayed by minutes                    |
//| - Flatten only executes ONCE per session                          |
//| - Gap detection warns if >60s between checks                      |
//+------------------------------------------------------------------+
//| DST DISPROOF TEST VECTORS (same as CApexTimeHandler):             |
//|                                                                   |
//| Spring Forward (2nd Sunday of March at 2:00 AM local):            |
//|   2024-03-10 06:59 UTC -> EST (offset -5) = 01:59 AM ET           |
//|   2024-03-10 07:01 UTC -> EDT (offset -4) = 03:01 AM ET           |
//|                                                                   |
//| Fall Back (1st Sunday of November at 2:00 AM local):              |
//|   2024-11-03 05:59 UTC -> EDT (offset -4) = 01:59 AM ET           |
//|   2024-11-03 06:01 UTC -> EST (offset -5) = 01:01 AM ET           |
//|                                                                   |
//| IDEMPOTENT TEST SCENARIOS:                                        |
//|   1. Timer fires at exactly 4:59 PM ET -> flatten once            |
//|   2. Timer delayed, fires at 5:05 PM ET -> still flatten once     |
//|   3. Multiple rapid timer calls -> only first flatten executes    |
//|   4. EA restart after 4:59 PM ET -> detect + flatten immediately  |
//+------------------------------------------------------------------+
#ifndef CWALLCLOCKENFORCER_MQH
#define CWALLCLOCKENFORCER_MQH

#property copyright "EA_SCALPER_XAUUSD - Apex Compliant Trading System"
#property strict

#include <Trade\Trade.mqh>
#include "../Core/Definitions.mqh"
#include "CApexTimeHandler.mqh"

// === FLATTEN CONSTANTS ===
#define FLATTEN_MAX_RETRIES         3       // Max retries for emergency flatten
#define FLATTEN_RETRY_DELAY_MS      200     // Delay between retries
#define GAP_WARNING_THRESHOLD_SEC   60      // Warn if >60s gap between checks
#define POSITION_CHECK_INTERVAL_SEC 1       // How often to check in emergency

//+------------------------------------------------------------------+
//| CWallClockEnforcer - Idempotent Deadline Enforcement              |
//| CRITIC FIX #4: Works even if OnTimer is delayed by minutes       |
//+------------------------------------------------------------------+
class CWallClockEnforcer
{
private:
    // Time handler reference
    CApexTimeHandler* m_time_handler;
    bool              m_owns_time_handler;    // Did we create it?

    // Trade executor
    CTrade            m_trade;
    int               m_magic_number;
    string            m_symbol;

    // CRITIC FIX #4: Idempotent state - flatten only once per session
    bool              m_flatten_executed;      // Has flatten been executed THIS session?
    bool              m_block_new_warned;      // Have we warned about 4:30 PM?
    bool              m_emergency_warned;      // Have we warned about 4:55 PM?
    datetime          m_flatten_time;          // When was flatten executed?
    int               m_flatten_positions_closed;  // How many positions closed?
    int               m_flatten_retries_used;  // How many retries were needed?

    // Session tracking
    datetime          m_session_deadline_utc;  // Computed once per session
    datetime          m_last_check_utc;        // Last time we checked
    int               m_check_count;           // Number of checks this session
    int               m_gap_warnings;          // Number of gap warnings issued

    // Logging
    bool              m_verbose;               // Verbose logging?

    // Internal methods
    bool              ExecuteEmergencyFlatten(string reason);
    bool              ClosePositionWithRetry(ulong ticket);
    void              ComputeSessionDeadline();
    void              CheckForGaps();

public:
    CWallClockEnforcer();
    ~CWallClockEnforcer();

    // Initialization
    bool              Init(int magic, string symbol = "", bool verbose = true);
    void              AttachTimeHandler(CApexTimeHandler* handler);  // Use external handler
    void              Reset();  // Reset for new session

    // CRITIC FIX #4: Main idempotent check - call from OnTimer or OnTick
    // This method is SAFE to call multiple times - flatten only executes once
    void              CheckAndEnforce();

    // Status accessors
    bool              IsFlattenExecuted() { return m_flatten_executed; }
    datetime          GetFlattenTime() { return m_flatten_time; }
    int               GetFlattenPositionsClosed() { return m_flatten_positions_closed; }
    int               GetCheckCount() { return m_check_count; }
    int               GetGapWarnings() { return m_gap_warnings; }

    // Time accessors (delegate to time handler)
    ENUM_TIME_STATE   GetTimeState();
    int               GetMinutesToClose();
    bool              CanOpenNewTrade();
    bool              IsEmergencyClose();
    bool              IsHalted();

    // Gate interface
    ENUM_GATE_REASON  GetGateReason();
    bool              IsBlocked();
    string            GetReasonText();

    // Diagnostic
    string            GetDiagnosticInfo();
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CWallClockEnforcer::CWallClockEnforcer()
{
    m_time_handler = NULL;
    m_owns_time_handler = false;
    m_magic_number = 0;
    m_symbol = _Symbol;
    m_verbose = true;

    // CRITIC FIX #4: Idempotent state - initialize to "not yet executed"
    m_flatten_executed = false;
    m_block_new_warned = false;
    m_emergency_warned = false;
    m_flatten_time = 0;
    m_flatten_positions_closed = 0;
    m_flatten_retries_used = 0;

    // Session tracking
    m_session_deadline_utc = 0;
    m_last_check_utc = 0;
    m_check_count = 0;
    m_gap_warnings = 0;
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CWallClockEnforcer::~CWallClockEnforcer()
{
    if(m_owns_time_handler && m_time_handler != NULL)
    {
        delete m_time_handler;
        m_time_handler = NULL;
    }
}

//+------------------------------------------------------------------+
//| Initialize the enforcer                                           |
//+------------------------------------------------------------------+
bool CWallClockEnforcer::Init(int magic, string symbol, bool verbose)
{
    m_magic_number = magic;
    m_symbol = (symbol == "") ? _Symbol : symbol;
    m_verbose = verbose;

    // Setup trade object
    m_trade.SetExpertMagicNumber(magic);
    m_trade.SetDeviationInPoints(50);
    m_trade.SetTypeFilling(ORDER_FILLING_IOC);

    // Create time handler if not attached
    if(m_time_handler == NULL)
    {
        m_time_handler = new CApexTimeHandler();
        m_owns_time_handler = true;
        if(!m_time_handler.Init())
        {
            Print("CWallClockEnforcer: Failed to initialize time handler");
            return false;
        }
    }

    // Compute session deadline (once per session)
    ComputeSessionDeadline();

    // CRITIC FIX #4: Check if we're already past deadline on startup
    // This handles the case where EA restarts after 4:59 PM
    if(m_time_handler.IsHalted() && !m_flatten_executed)
    {
        Print("CWallClockEnforcer: WARNING - EA started after 4:59 PM ET deadline!");
        Print("CWallClockEnforcer: Executing immediate emergency flatten...");
        ExecuteEmergencyFlatten("EA restart after deadline");
    }

    m_last_check_utc = TimeGMT();

    Print("CWallClockEnforcer: Initialized for ", m_symbol, " Magic: ", m_magic_number);
    Print("  Session deadline UTC: ", TimeToString(m_session_deadline_utc, TIME_DATE | TIME_SECONDS));
    Print("  Current state: ", m_time_handler.GetTimeStateString());
    Print("  Flatten executed: ", m_flatten_executed ? "YES" : "NO");

    return true;
}

//+------------------------------------------------------------------+
//| Attach external time handler (instead of creating own)            |
//+------------------------------------------------------------------+
void CWallClockEnforcer::AttachTimeHandler(CApexTimeHandler* handler)
{
    // Clean up existing if we own it
    if(m_owns_time_handler && m_time_handler != NULL)
    {
        delete m_time_handler;
    }

    m_time_handler = handler;
    m_owns_time_handler = false;  // Don't delete it in destructor

    // Recompute deadline with new handler
    if(m_time_handler != NULL)
    {
        ComputeSessionDeadline();
    }
}

//+------------------------------------------------------------------+
//| Compute session deadline in UTC (once per session)                |
//+------------------------------------------------------------------+
void CWallClockEnforcer::ComputeSessionDeadline()
{
    if(m_time_handler == NULL) return;

    // Get current ET and extract date
    datetime et_now = m_time_handler.GetCurrentET();
    MqlDateTime mdt;
    TimeToStruct(et_now, mdt);

    // Build deadline: today at 4:59 PM ET
    mdt.hour = 16;
    mdt.min = 59;
    mdt.sec = 0;
    datetime deadline_et = StructToTime(mdt);

    // Convert ET deadline to UTC
    int offset = m_time_handler.GetETOffsetHours();
    m_session_deadline_utc = deadline_et - offset * 3600;

    // If we're past the deadline, it means tomorrow's deadline
    // (but for Apex this shouldn't happen as market closes)
    if(TimeGMT() > m_session_deadline_utc + 3600)  // More than 1 hour past
    {
        // This is a new session - deadline was yesterday
        // For futures, market reopens Sunday evening
        // Just recompute for current day
        Print("CWallClockEnforcer: Session deadline appears to be in the past - new session?");
    }
}

//+------------------------------------------------------------------+
//| Reset for new trading session                                     |
//+------------------------------------------------------------------+
void CWallClockEnforcer::Reset()
{
    m_flatten_executed = false;
    m_block_new_warned = false;
    m_emergency_warned = false;
    m_flatten_time = 0;
    m_flatten_positions_closed = 0;
    m_flatten_retries_used = 0;
    m_check_count = 0;
    m_gap_warnings = 0;

    if(m_time_handler != NULL)
    {
        m_time_handler.Reset();
        ComputeSessionDeadline();
    }

    m_last_check_utc = TimeGMT();

    Print("CWallClockEnforcer: Reset for new session");
}

//+------------------------------------------------------------------+
//| Check for gaps between timer calls                                |
//+------------------------------------------------------------------+
void CWallClockEnforcer::CheckForGaps()
{
    datetime now_utc = TimeGMT();

    if(m_last_check_utc > 0)
    {
        long gap_seconds = (long)(now_utc - m_last_check_utc);

        if(gap_seconds > GAP_WARNING_THRESHOLD_SEC)
        {
            m_gap_warnings++;
            Print("CWallClockEnforcer: WARNING - ", gap_seconds,
                  " second gap since last check! (threshold: ", GAP_WARNING_THRESHOLD_SEC, "s)");
            Print("  This may indicate timer issues or system load.");
            Print("  Gap warnings this session: ", m_gap_warnings);
        }
    }

    m_last_check_utc = now_utc;
}

//+------------------------------------------------------------------+
//| CRITIC FIX #4: Main idempotent check and enforce method           |
//| SAFE to call multiple times - flatten only executes ONCE          |
//+------------------------------------------------------------------+
void CWallClockEnforcer::CheckAndEnforce()
{
    if(m_time_handler == NULL)
    {
        Print("CWallClockEnforcer: ERROR - Time handler not initialized!");
        return;
    }

    m_check_count++;

    // Check for gaps (timer reliability monitoring)
    CheckForGaps();

    // Get current time state
    ENUM_TIME_STATE state = m_time_handler.GetTimeState();

    // === STATE MACHINE ===

    // 1. HALTED (4:59 PM ET+): Execute emergency flatten
    if(state >= TIME_HALTED)
    {
        // CRITIC FIX #4: IDEMPOTENT - only execute flatten ONCE
        if(!m_flatten_executed)
        {
            Print("CWallClockEnforcer: TIME_HALTED - Executing emergency flatten");
            ExecuteEmergencyFlatten("Hard deadline 4:59 PM ET");
            m_flatten_executed = true;
            m_flatten_time = TimeGMT();
        }
        // If already executed, just return silently (idempotent)
        return;
    }

    // 2. EMERGENCY (4:55 PM ET): Warn and prepare
    if(state >= TIME_EMERGENCY)
    {
        if(!m_emergency_warned)
        {
            int minutes_to_close = m_time_handler.GetMinutesToClose();
            Print("CWallClockEnforcer: EMERGENCY - ", minutes_to_close,
                  " minutes to hard close! Prepare for automatic flatten.");
            Alert("APEX EMERGENCY: ", minutes_to_close, " minutes to mandatory close!");
            m_emergency_warned = true;
        }

        // Don't flatten yet, but check more frequently
        // EA should call this every 1 second during emergency
        return;
    }

    // 3. BLOCK_NEW (4:30 PM ET): Warn about new trade restriction
    if(state >= TIME_BLOCK_NEW)
    {
        if(!m_block_new_warned)
        {
            int minutes_to_close = m_time_handler.GetMinutesToClose();
            Print("CWallClockEnforcer: BLOCK_NEW - New trades blocked. ",
                  minutes_to_close, " minutes to hard close.");
            m_block_new_warned = true;
        }
        return;
    }

    // 4. NORMAL: Nothing special to do
    // Just record that we checked (for gap detection)
}

//+------------------------------------------------------------------+
//| Execute emergency flatten with retries                            |
//+------------------------------------------------------------------+
bool CWallClockEnforcer::ExecuteEmergencyFlatten(string reason)
{
    Print("CWallClockEnforcer: ===== EMERGENCY FLATTEN =====");
    Print("  Reason: ", reason);
    Print("  Time: ", TimeToString(TimeGMT(), TIME_DATE | TIME_SECONDS), " UTC");

    int positions_closed = 0;
    int positions_failed = 0;

    // Loop through all positions for our symbol and magic
    for(int attempt = 0; attempt < FLATTEN_MAX_RETRIES; attempt++)
    {
        if(attempt > 0)
        {
            Print("CWallClockEnforcer: Flatten retry ", attempt + 1, "/", FLATTEN_MAX_RETRIES);
            Sleep(FLATTEN_RETRY_DELAY_MS);
        }

        bool any_remaining = false;

        for(int i = PositionsTotal() - 1; i >= 0; i--)
        {
            ulong ticket = PositionGetTicket(i);
            if(!PositionSelectByTicket(ticket))
                continue;

            // Check magic and symbol
            if(PositionGetInteger(POSITION_MAGIC) != m_magic_number)
                continue;

            if(PositionGetString(POSITION_SYMBOL) != m_symbol)
                continue;

            // Found a position that needs closing
            any_remaining = true;

            Print("CWallClockEnforcer: Closing position #", ticket,
                  " Volume: ", PositionGetDouble(POSITION_VOLUME),
                  " Profit: ", PositionGetDouble(POSITION_PROFIT));

            if(ClosePositionWithRetry(ticket))
            {
                positions_closed++;
            }
            else
            {
                positions_failed++;
                Print("CWallClockEnforcer: FAILED to close position #", ticket);
            }
        }

        if(!any_remaining)
        {
            // All positions closed
            break;
        }

        m_flatten_retries_used = attempt + 1;
    }

    m_flatten_positions_closed = positions_closed;

    Print("CWallClockEnforcer: ===== FLATTEN COMPLETE =====");
    Print("  Positions closed: ", positions_closed);
    Print("  Positions failed: ", positions_failed);
    Print("  Retries used: ", m_flatten_retries_used);

    if(positions_failed > 0)
    {
        Alert("CRITICAL: Failed to close ", positions_failed, " positions!");
        return false;
    }

    return true;
}

//+------------------------------------------------------------------+
//| Close a single position with retry logic                          |
//+------------------------------------------------------------------+
bool CWallClockEnforcer::ClosePositionWithRetry(ulong ticket)
{
    for(int retry = 0; retry < FLATTEN_MAX_RETRIES; retry++)
    {
        if(retry > 0)
        {
            Sleep(FLATTEN_RETRY_DELAY_MS);

            // Re-select position
            if(!PositionSelectByTicket(ticket))
            {
                // Position no longer exists - success
                return true;
            }
        }

        if(m_trade.PositionClose(ticket))
        {
            return true;
        }

        uint retcode = m_trade.ResultRetcode();

        // Retry on retriable errors
        if(retcode == TRADE_RETCODE_REQUOTE ||
           retcode == TRADE_RETCODE_PRICE_CHANGED ||
           retcode == TRADE_RETCODE_PRICE_OFF ||
           retcode == TRADE_RETCODE_CONNECTION ||
           retcode == TRADE_RETCODE_TIMEOUT)
        {
            Print("CWallClockEnforcer: Close retry ", retry + 1, " - ", m_trade.ResultRetcodeDescription());
            continue;
        }

        // Non-retriable error
        Print("CWallClockEnforcer: Close failed - ", m_trade.ResultRetcodeDescription(),
              " (retcode ", retcode, ")");
        break;
    }

    return false;
}

//+------------------------------------------------------------------+
//| Time state accessors (delegate to time handler)                   |
//+------------------------------------------------------------------+
ENUM_TIME_STATE CWallClockEnforcer::GetTimeState()
{
    if(m_time_handler == NULL) return TIME_HALTED;  // Fail-safe
    return m_time_handler.GetTimeState();
}

int CWallClockEnforcer::GetMinutesToClose()
{
    if(m_time_handler == NULL) return 0;
    return m_time_handler.GetMinutesToClose();
}

bool CWallClockEnforcer::CanOpenNewTrade()
{
    if(m_time_handler == NULL) return false;
    return m_time_handler.CanOpenNewTrade();
}

bool CWallClockEnforcer::IsEmergencyClose()
{
    if(m_time_handler == NULL) return true;  // Fail-safe
    return m_time_handler.IsEmergencyClose();
}

bool CWallClockEnforcer::IsHalted()
{
    if(m_time_handler == NULL) return true;  // Fail-safe
    return m_time_handler.IsHalted();
}

//+------------------------------------------------------------------+
//| Gate interface methods                                            |
//+------------------------------------------------------------------+
ENUM_GATE_REASON CWallClockEnforcer::GetGateReason()
{
    if(m_time_handler == NULL) return GATE_TIME;

    ENUM_TIME_STATE state = m_time_handler.GetTimeState();

    if(state >= TIME_BLOCK_NEW)
        return GATE_TIME;

    return GATE_OK;
}

bool CWallClockEnforcer::IsBlocked()
{
    return (GetGateReason() != GATE_OK);
}

string CWallClockEnforcer::GetReasonText()
{
    if(m_time_handler == NULL)
        return "TimeHandler not initialized";

    ENUM_TIME_STATE state = m_time_handler.GetTimeState();

    switch(state)
    {
        case TIME_HALTED:
            return "HALTED: Past 4:59 PM ET - market closed";
        case TIME_EMERGENCY:
            return "EMERGENCY: 4:55 PM ET - positions being closed";
        case TIME_BLOCK_NEW:
            return "BLOCK_NEW: After 4:30 PM ET - no new trades";
        case TIME_NORMAL:
        default:
            return "NORMAL: Trading allowed";
    }
}

//+------------------------------------------------------------------+
//| Get diagnostic information                                        |
//+------------------------------------------------------------------+
string CWallClockEnforcer::GetDiagnosticInfo()
{
    string time_info = "";
    if(m_time_handler != NULL)
    {
        time_info = m_time_handler.GetDiagnosticInfo();
    }

    string info = StringFormat(
        "\nWallClockEnforcer Diagnostic:\n"
        "  Checks performed: %d\n"
        "  Gap warnings: %d\n"
        "  Block new warned: %s\n"
        "  Emergency warned: %s\n"
        "  Flatten executed: %s\n"
        "  Flatten time: %s\n"
        "  Positions closed: %d\n"
        "  Retries used: %d\n"
        "  Session deadline UTC: %s\n"
        "\n%s",
        m_check_count,
        m_gap_warnings,
        m_block_new_warned ? "YES" : "NO",
        m_emergency_warned ? "YES" : "NO",
        m_flatten_executed ? "YES" : "NO",
        m_flatten_time > 0 ? TimeToString(m_flatten_time, TIME_DATE | TIME_SECONDS) : "N/A",
        m_flatten_positions_closed,
        m_flatten_retries_used,
        TimeToString(m_session_deadline_utc, TIME_DATE | TIME_SECONDS),
        time_info
    );

    return info;
}

#endif // CWALLCLOCKENFORCER_MQH
//+------------------------------------------------------------------+
