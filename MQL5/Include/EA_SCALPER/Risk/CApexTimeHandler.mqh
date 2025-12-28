//+------------------------------------------------------------------+
//|                                             CApexTimeHandler.mqh |
//|                     EA_SCALPER_XAUUSD - Apex Compliant Trading   |
//|                     DST-Safe Eastern Time Handler (Task 2.4)     |
//+------------------------------------------------------------------+
//| CRITIC FIX #2: Use TimeGMT() as ONLY time base (NOT TimeCurrent) |
//| CRITIC FIX #3: Deterministic DST algorithm with nth-Sunday calc  |
//+------------------------------------------------------------------+
//| DST DISPROOF TEST VECTORS (include in unit tests):               |
//|                                                                  |
//| Spring Forward (2nd Sunday of March at 2:00 AM local):           |
//|   2024-03-10 06:59 UTC -> EST (offset -5) = 01:59 AM ET          |
//|   2024-03-10 07:01 UTC -> EDT (offset -4) = 03:01 AM ET          |
//|                                                                  |
//| Fall Back (1st Sunday of November at 2:00 AM local):             |
//|   2024-11-03 05:59 UTC -> EDT (offset -4) = 01:59 AM ET          |
//|   2024-11-03 06:01 UTC -> EST (offset -5) = 01:01 AM ET          |
//|                                                                  |
//| Edge Cases:                                                      |
//|   2025-03-09 07:00 UTC -> EDT (first tick after DST starts)      |
//|   2025-11-02 06:00 UTC -> EST (first tick after DST ends)        |
//|   2024-12-31 21:59 UTC -> EST (New Year's Eve 4:59 PM ET)        |
//|   2024-07-04 20:30 UTC -> EDT (4:30 PM ET on Independence Day)   |
//+------------------------------------------------------------------+
#ifndef CAPEXTIMEHANDLER_MQH
#define CAPEXTIMEHANDLER_MQH

#property copyright "EA_SCALPER_XAUUSD - Apex Compliant Trading System"
#property strict

#include "../Core/Definitions.mqh"
#include "../Core/CDSTHelper.mqh"  // Shared DST calculation utility

// === APEX TIME THRESHOLDS (in minutes from midnight ET) ===
#define APEX_TIME_BLOCK_NEW_MIN     990   // 4:30 PM ET = 16*60 + 30 = 990
#define APEX_TIME_EMERGENCY_MIN     1015  // 4:55 PM ET = 16*60 + 55 = 1015
#define APEX_TIME_HALTED_MIN        1019  // 4:59 PM ET = 16*60 + 59 = 1019
#define APEX_MARKET_CLOSE_MIN       1020  // 5:00 PM ET = 17*60 = 1020

// === ROLLOVER PROTECTION (5 PM ET +/- buffer) ===
// Forex rollover occurs at 5 PM ET - block trades during this window
// to avoid swap charges and potential spread widening
#define APEX_ROLLOVER_CENTER_MIN    1020  // 5:00 PM ET = 17*60 = 1020
#define APEX_ROLLOVER_BUFFER_MIN    5     // 5 minute buffer before/after
// Rollover window: 4:55 PM - 5:05 PM ET (1015-1025 minutes)

// === DST CONSTANTS - Now defined in CDSTHelper.mqh ===
// Kept here for backward compatibility - values imported from CDSTHelper
// #define DST_START_MONTH, DST_START_NTH_SUNDAY, etc. are in CDSTHelper.mqh

//+------------------------------------------------------------------+
//| CApexTimeHandler - DST-Safe Eastern Time Handler                 |
//| Uses TimeGMT() exclusively per CRITIC FIX #2                     |
//+------------------------------------------------------------------+
class CApexTimeHandler
{
private:
    // Current ET offset (recalculated on each call)
    int               m_et_offset_hours;

    // Broker GMT offset for backtest correction
    int               m_broker_gmt_offset;  // e.g., +2 for FTMO (EET), +3 for FTMO DST

    // Cached state
    ENUM_TIME_STATE   m_current_state;
    datetime          m_last_check_utc;
    int               m_last_minutes_from_midnight;
    bool              m_is_dst;

    // Diagnostic info
    datetime          m_session_start_utc;
    int               m_dst_checks_count;

    // Internal methods - DST now delegated to CDSTHelper
    int               GetMinutesFromMidnightET(datetime utc_time);

public:
    CApexTimeHandler();
    ~CApexTimeHandler() {}

    // Initialization
    bool              Init(int broker_gmt_offset = 2);  // Default: FTMO uses GMT+2 (EET)
    void              Reset();

    // Core time methods - CRITIC FIX #2: All use TimeGMT() internally
    datetime          GetCurrentUTC();                    // Returns TimeGMT()
    datetime          GetCurrentET();                     // Returns ET datetime
    int               GetETOffsetHours();                 // Current offset (-5 or -4)
    bool              IsDST();                            // Is DST currently active?

    // Time state methods
    ENUM_TIME_STATE   GetTimeState();                     // Returns current time state
    int               GetMinutesToState(ENUM_TIME_STATE target);  // Minutes until target state
    int               GetMinutesToClose();                // Minutes until 4:59 PM ET
    int               GetMinutesFromMidnight();           // Minutes from midnight ET

    // State checks
    bool              IsNormalTrading();                  // TIME_NORMAL
    bool              IsBlockNewTrades();                 // TIME_BLOCK_NEW (4:30 PM+)
    bool              IsEmergencyClose();                 // TIME_EMERGENCY (4:55 PM+)
    bool              IsHalted();                         // TIME_HALTED (4:59 PM+)
    bool              CanOpenNewTrade();                  // Convenience method
    bool              IsInRolloverWindow();               // 5 PM ET +/- buffer (swap time)

    // Diagnostic info
    string            GetTimeStateString();
    string            GetDiagnosticInfo();
    datetime          GetSessionStartUTC() { return m_session_start_utc; }
    int               GetDSTChecksCount() { return m_dst_checks_count; }
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CApexTimeHandler::CApexTimeHandler()
{
    m_et_offset_hours = EST_OFFSET_HOURS;  // Default to EST
    m_broker_gmt_offset = 2;               // Default: FTMO uses GMT+2 (EET)
    m_current_state = TIME_NORMAL;
    m_last_check_utc = 0;
    m_last_minutes_from_midnight = 0;
    m_is_dst = false;
    m_session_start_utc = 0;
    m_dst_checks_count = 0;
}

//+------------------------------------------------------------------+
//| Initialize the time handler                                       |
//+------------------------------------------------------------------+
bool CApexTimeHandler::Init(int broker_gmt_offset)
{
    // Store broker GMT offset for backtest timezone correction
    m_broker_gmt_offset = broker_gmt_offset;

    // CRITIC FIX #2: Use TimeGMT() as base
    datetime utc_now = TimeGMT();

    // Calculate initial DST state using shared CDSTHelper
    m_is_dst = CDSTHelper::IsDST(utc_now);
    m_et_offset_hours = CDSTHelper::GetETOffsetHours(utc_now);

    // Record session start
    m_session_start_utc = utc_now;
    m_dst_checks_count = 1;

    // Get initial state
    m_current_state = GetTimeState();

    Print("CApexTimeHandler: Initialized");
    Print("  UTC Time: ", TimeToString(utc_now, TIME_DATE | TIME_SECONDS));
    Print("  ET Time:  ", TimeToString(GetCurrentET(), TIME_DATE | TIME_SECONDS));
    Print("  DST Active: ", m_is_dst ? "YES (EDT, UTC-4)" : "NO (EST, UTC-5)");
    Print("  Time State: ", GetTimeStateString());

    return true;
}

//+------------------------------------------------------------------+
//| Reset state (call at session boundaries)                          |
//+------------------------------------------------------------------+
void CApexTimeHandler::Reset()
{
    m_session_start_utc = TimeGMT();
    m_last_check_utc = 0;
    m_dst_checks_count = 0;
}

// NOTE: GetNthSundayOfMonth and CalculateIsDST have been moved to CDSTHelper.mqh
// See Core/CDSTHelper.mqh for the shared DST calculation utilities

//+------------------------------------------------------------------+
//| Get current UTC time - CRITIC FIX #2: Use TimeGMT() ONLY (LIVE)  |
//| BACKTEST FIX: Convert broker server time to UTC                  |
//+------------------------------------------------------------------+
datetime CApexTimeHandler::GetCurrentUTC()
{
    // In Strategy Tester: use simulated time (TimeCurrent) and convert to UTC
    // In Live: use wall-clock time (TimeGMT)
    if(MQLInfoInteger(MQL_TESTER))
    {
        // In backtest, TimeCurrent() returns broker server time (e.g., GMT+2 for FTMO)
        // Convert to UTC by subtracting the broker's GMT offset
        // Formula: UTC = BrokerTime - BrokerGMTOffset
        // Example: BrokerTime 03:24 GMT+2 → UTC = 03:24 - 2h = 01:24 UTC
        datetime broker_time = TimeCurrent();
        datetime utc_time = broker_time - m_broker_gmt_offset * 3600;
        return utc_time;
    }

    // CRITIC FIX #2: TimeGMT() is the ONLY time source for LIVE
    // DO NOT use TimeCurrent() in live - it returns broker server time which
    // may have unknown offset from UTC/ET
    return TimeGMT();
}

//+------------------------------------------------------------------+
//| Get current Eastern Time                                          |
//+------------------------------------------------------------------+
datetime CApexTimeHandler::GetCurrentET()
{
    datetime utc_now = GetCurrentUTC();

    // Recalculate DST state using shared CDSTHelper (may have changed during session)
    m_is_dst = CDSTHelper::IsDST(utc_now);
    m_et_offset_hours = CDSTHelper::GetETOffsetHours(utc_now);
    m_dst_checks_count++;

    // Use CDSTHelper for conversion
    return CDSTHelper::UTCtoET(utc_now);
}

//+------------------------------------------------------------------+
//| Get current ET offset in hours (-5 for EST, -4 for EDT)          |
//+------------------------------------------------------------------+
int CApexTimeHandler::GetETOffsetHours()
{
    // Ensure we have fresh DST calculation using CDSTHelper
    datetime utc_now = GetCurrentUTC();
    m_is_dst = CDSTHelper::IsDST(utc_now);
    m_et_offset_hours = CDSTHelper::GetETOffsetHours(utc_now);

    return m_et_offset_hours;
}

//+------------------------------------------------------------------+
//| Is DST currently active?                                          |
//+------------------------------------------------------------------+
bool CApexTimeHandler::IsDST()
{
    datetime utc_now = GetCurrentUTC();
    m_is_dst = CDSTHelper::IsDST(utc_now);
    return m_is_dst;
}

//+------------------------------------------------------------------+
//| Get minutes from midnight in Eastern Time                         |
//+------------------------------------------------------------------+
int CApexTimeHandler::GetMinutesFromMidnightET(datetime utc_time)
{
    // Use CDSTHelper for ET conversion
    datetime et_time = CDSTHelper::UTCtoET(utc_time);

    MqlDateTime mdt;
    TimeToStruct(et_time, mdt);

    // Minutes from midnight = hour * 60 + minute
    // Example: 4:30 PM = 16:30 = 16*60 + 30 = 990 minutes
    int minutes = mdt.hour * 60 + mdt.min;

    return minutes;
}

//+------------------------------------------------------------------+
//| Get minutes from midnight (public method)                         |
//+------------------------------------------------------------------+
int CApexTimeHandler::GetMinutesFromMidnight()
{
    datetime utc_now = GetCurrentUTC();
    m_last_minutes_from_midnight = GetMinutesFromMidnightET(utc_now);
    return m_last_minutes_from_midnight;
}

//+------------------------------------------------------------------+
//| Get current time state based on ET time                           |
//+------------------------------------------------------------------+
ENUM_TIME_STATE CApexTimeHandler::GetTimeState()
{
    int minutes = GetMinutesFromMidnight();

    // Determine state based on Apex time gates
    // Note: These thresholds are defined in CLAUDE.md apex_non_negotiables

    if(minutes >= APEX_TIME_HALTED_MIN)      // 4:59 PM ET or later
    {
        m_current_state = TIME_HALTED;
    }
    else if(minutes >= APEX_TIME_EMERGENCY_MIN)  // 4:55 PM ET or later
    {
        m_current_state = TIME_EMERGENCY;
    }
    else if(minutes >= APEX_TIME_BLOCK_NEW_MIN)  // 4:30 PM ET or later
    {
        m_current_state = TIME_BLOCK_NEW;
    }
    else
    {
        m_current_state = TIME_NORMAL;
    }

    m_last_check_utc = GetCurrentUTC();

    return m_current_state;
}

//+------------------------------------------------------------------+
//| Get minutes until a target time state                             |
//+------------------------------------------------------------------+
int CApexTimeHandler::GetMinutesToState(ENUM_TIME_STATE target)
{
    int current_minutes = GetMinutesFromMidnight();
    int target_minutes = 0;

    switch(target)
    {
        case TIME_BLOCK_NEW:
            target_minutes = APEX_TIME_BLOCK_NEW_MIN;
            break;
        case TIME_EMERGENCY:
            target_minutes = APEX_TIME_EMERGENCY_MIN;
            break;
        case TIME_HALTED:
            target_minutes = APEX_TIME_HALTED_MIN;
            break;
        case TIME_NORMAL:
        default:
            return 0;  // Already normal or unknown
    }

    int diff = target_minutes - current_minutes;

    // If negative, we've already passed this threshold
    return (diff > 0) ? diff : 0;
}

//+------------------------------------------------------------------+
//| Get minutes until 4:59 PM ET (hard deadline)                      |
//+------------------------------------------------------------------+
int CApexTimeHandler::GetMinutesToClose()
{
    return GetMinutesToState(TIME_HALTED);
}

//+------------------------------------------------------------------+
//| State check methods                                               |
//+------------------------------------------------------------------+
bool CApexTimeHandler::IsNormalTrading()
{
    return (GetTimeState() == TIME_NORMAL);
}

bool CApexTimeHandler::IsBlockNewTrades()
{
    ENUM_TIME_STATE state = GetTimeState();
    return (state >= TIME_BLOCK_NEW);  // Includes EMERGENCY and HALTED
}

bool CApexTimeHandler::IsEmergencyClose()
{
    ENUM_TIME_STATE state = GetTimeState();
    return (state >= TIME_EMERGENCY);  // Includes HALTED
}

bool CApexTimeHandler::IsHalted()
{
    return (GetTimeState() == TIME_HALTED);
}

bool CApexTimeHandler::CanOpenNewTrade()
{
    return IsNormalTrading();
}

//+------------------------------------------------------------------+
//| IsInRolloverWindow - Check if in 5 PM ET rollover window         |
//|                                                                   |
//| Forex rollover occurs daily at 5 PM ET. During this window:      |
//| - Spreads may widen significantly                                 |
//| - Swaps are charged/credited                                      |
//| - Liquidity may be reduced                                        |
//|                                                                   |
//| Block new trades 5 minutes before and after 5 PM ET.             |
//| Window: 4:55 PM - 5:05 PM ET (1015-1025 minutes from midnight)   |
//+------------------------------------------------------------------+
bool CApexTimeHandler::IsInRolloverWindow()
{
    int minutes = GetMinutesFromMidnight();

    // Rollover window: 5 PM ET +/- 5 minutes (1015-1025 minutes)
    // 4:55 PM ET = 1015 minutes
    // 5:05 PM ET = 1025 minutes
    int window_start = APEX_ROLLOVER_CENTER_MIN - APEX_ROLLOVER_BUFFER_MIN;  // 1015
    int window_end   = APEX_ROLLOVER_CENTER_MIN + APEX_ROLLOVER_BUFFER_MIN;  // 1025

    return (minutes >= window_start && minutes <= window_end);
}

//+------------------------------------------------------------------+
//| Get time state as human-readable string                           |
//+------------------------------------------------------------------+
string CApexTimeHandler::GetTimeStateString()
{
    switch(m_current_state)
    {
        case TIME_NORMAL:      return "NORMAL";
        case TIME_BLOCK_NEW:   return "BLOCK_NEW (4:30 PM+ ET)";
        case TIME_EMERGENCY:   return "EMERGENCY (4:55 PM+ ET)";
        case TIME_HALTED:      return "HALTED (4:59 PM+ ET)";
        default:               return "UNKNOWN";
    }
}

//+------------------------------------------------------------------+
//| Get diagnostic information                                        |
//+------------------------------------------------------------------+
string CApexTimeHandler::GetDiagnosticInfo()
{
    datetime utc = GetCurrentUTC();
    datetime et = GetCurrentET();
    int minutes = GetMinutesFromMidnight();

    string info = StringFormat(
        "ApexTimeHandler Diagnostic:\n"
        "  UTC: %s\n"
        "  ET:  %s\n"
        "  Offset: %d hours (%s)\n"
        "  Minutes from midnight ET: %d\n"
        "  State: %s\n"
        "  Minutes to 4:30 PM: %d\n"
        "  Minutes to 4:55 PM: %d\n"
        "  Minutes to 4:59 PM: %d\n"
        "  DST Checks: %d",
        TimeToString(utc, TIME_DATE | TIME_SECONDS),
        TimeToString(et, TIME_DATE | TIME_SECONDS),
        m_et_offset_hours,
        m_is_dst ? "EDT" : "EST",
        minutes,
        GetTimeStateString(),
        GetMinutesToState(TIME_BLOCK_NEW),
        GetMinutesToState(TIME_EMERGENCY),
        GetMinutesToState(TIME_HALTED),
        m_dst_checks_count
    );

    return info;
}

#endif // CAPEXTIMEHANDLER_MQH
//+------------------------------------------------------------------+
