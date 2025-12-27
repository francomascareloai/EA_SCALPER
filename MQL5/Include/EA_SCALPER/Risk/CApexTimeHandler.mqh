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

// === APEX TIME THRESHOLDS (in minutes from midnight ET) ===
#define APEX_TIME_BLOCK_NEW_MIN     990   // 4:30 PM ET = 16*60 + 30 = 990
#define APEX_TIME_EMERGENCY_MIN     1015  // 4:55 PM ET = 16*60 + 55 = 1015
#define APEX_TIME_HALTED_MIN        1019  // 4:59 PM ET = 16*60 + 59 = 1019
#define APEX_MARKET_CLOSE_MIN       1020  // 5:00 PM ET = 17*60 = 1020

// === DST CONSTANTS (US Daylight Saving Time Rules) ===
// DST starts: 2nd Sunday of March at 2:00 AM local (EST->EDT)
// DST ends:   1st Sunday of November at 2:00 AM local (EDT->EST)
#define DST_START_MONTH             3     // March
#define DST_START_NTH_SUNDAY        2     // 2nd Sunday
#define DST_END_MONTH               11    // November
#define DST_END_NTH_SUNDAY          1     // 1st Sunday
#define DST_TRANSITION_HOUR_UTC     7     // 2:00 AM EST = 7:00 UTC (spring forward)
#define DST_TRANSITION_END_HOUR_UTC 6     // 2:00 AM EDT = 6:00 UTC (fall back)

// === ET OFFSET FROM UTC ===
#define EST_OFFSET_HOURS            (-5)  // Eastern Standard Time: UTC-5
#define EDT_OFFSET_HOURS            (-4)  // Eastern Daylight Time: UTC-4

//+------------------------------------------------------------------+
//| CApexTimeHandler - DST-Safe Eastern Time Handler                 |
//| Uses TimeGMT() exclusively per CRITIC FIX #2                     |
//+------------------------------------------------------------------+
class CApexTimeHandler
{
private:
    // Current ET offset (recalculated on each call)
    int               m_et_offset_hours;

    // Cached state
    ENUM_TIME_STATE   m_current_state;
    datetime          m_last_check_utc;
    int               m_last_minutes_from_midnight;
    bool              m_is_dst;

    // Diagnostic info
    datetime          m_session_start_utc;
    int               m_dst_checks_count;

    // Internal methods
    int               GetNthSundayOfMonth(int year, int month, int nth);
    bool              CalculateIsDST(datetime utc_time);
    int               GetMinutesFromMidnightET(datetime utc_time);

public:
    CApexTimeHandler();
    ~CApexTimeHandler() {}

    // Initialization
    bool              Init();
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
bool CApexTimeHandler::Init()
{
    // CRITIC FIX #2: Use TimeGMT() as base
    datetime utc_now = TimeGMT();

    // Calculate initial DST state
    m_is_dst = CalculateIsDST(utc_now);
    m_et_offset_hours = m_is_dst ? EDT_OFFSET_HOURS : EST_OFFSET_HOURS;

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

//+------------------------------------------------------------------+
//| CRITIC FIX #3: Get the nth Sunday of a given month               |
//| Deterministic algorithm using Zeller-like day-of-week calculation|
//+------------------------------------------------------------------+
int CApexTimeHandler::GetNthSundayOfMonth(int year, int month, int nth)
{
    // Create MqlDateTime for the 1st of the month
    MqlDateTime mdt;
    ZeroMemory(mdt);
    mdt.year = year;
    mdt.mon = month;
    mdt.day = 1;
    mdt.hour = 12;  // Noon to avoid DST edge issues

    // Convert to datetime and back to get day_of_week
    datetime first_of_month = StructToTime(mdt);
    TimeToStruct(first_of_month, mdt);

    // day_of_week: 0=Sunday, 1=Monday, ..., 6=Saturday
    int first_dow = mdt.day_of_week;

    // Calculate days until first Sunday
    // If first_dow is 0 (Sunday), days_to_first_sunday = 0
    // If first_dow is 1 (Monday), days_to_first_sunday = 6
    // Formula: (7 - first_dow) % 7
    int days_to_first_sunday = (7 - first_dow) % 7;

    // Calculate the day of the nth Sunday
    // 1st Sunday = 1 + days_to_first_sunday
    // nth Sunday = 1 + days_to_first_sunday + (nth - 1) * 7
    int day = 1 + days_to_first_sunday + (nth - 1) * 7;

    // Validate result (should be between 1-31)
    if(day < 1 || day > 31)
    {
        Print("CApexTimeHandler: ERROR - GetNthSundayOfMonth returned invalid day: ", day);
        return 1;  // Fallback to 1st
    }

    return day;
}

//+------------------------------------------------------------------+
//| CRITIC FIX #3: Deterministic DST calculation                      |
//| US DST: 2nd Sunday March 2:00 AM -> 1st Sunday November 2:00 AM  |
//+------------------------------------------------------------------+
bool CApexTimeHandler::CalculateIsDST(datetime utc_time)
{
    m_dst_checks_count++;

    MqlDateTime mdt;
    TimeToStruct(utc_time, mdt);

    int year = mdt.year;
    int month = mdt.mon;
    int day = mdt.day;
    int hour_utc = mdt.hour;

    // Calculate DST boundaries for this year
    int dst_start_day = GetNthSundayOfMonth(year, DST_START_MONTH, DST_START_NTH_SUNDAY);
    int dst_end_day = GetNthSundayOfMonth(year, DST_END_MONTH, DST_END_NTH_SUNDAY);

    // Before March: No DST
    if(month < DST_START_MONTH)
        return false;

    // After November: No DST
    if(month > DST_END_MONTH)
        return false;

    // Between April and October: DST is active
    if(month > DST_START_MONTH && month < DST_END_MONTH)
        return true;

    // March: Check if we're past the transition
    if(month == DST_START_MONTH)
    {
        if(day < dst_start_day)
            return false;
        if(day > dst_start_day)
            return true;
        // On the transition day: DST starts at 7:00 UTC (2:00 AM EST -> 3:00 AM EDT)
        // At 6:59 UTC = 1:59 AM EST (no DST)
        // At 7:00 UTC = 3:00 AM EDT (DST active)
        return (hour_utc >= DST_TRANSITION_HOUR_UTC);
    }

    // November: Check if we're before the transition
    if(month == DST_END_MONTH)
    {
        if(day < dst_end_day)
            return true;
        if(day > dst_end_day)
            return false;
        // On the transition day: DST ends at 6:00 UTC (2:00 AM EDT -> 1:00 AM EST)
        // At 5:59 UTC = 1:59 AM EDT (DST active)
        // At 6:00 UTC = 1:00 AM EST (no DST)
        return (hour_utc < DST_TRANSITION_END_HOUR_UTC);
    }

    // Should not reach here
    return false;
}

//+------------------------------------------------------------------+
//| Get current UTC time - CRITIC FIX #2: Use TimeGMT() ONLY         |
//+------------------------------------------------------------------+
datetime CApexTimeHandler::GetCurrentUTC()
{
    // CRITIC FIX #2: TimeGMT() is the ONLY time source
    // DO NOT use TimeCurrent() - it returns broker server time which
    // may have unknown offset from UTC/ET
    return TimeGMT();
}

//+------------------------------------------------------------------+
//| Get current Eastern Time                                          |
//+------------------------------------------------------------------+
datetime CApexTimeHandler::GetCurrentET()
{
    datetime utc_now = GetCurrentUTC();

    // Recalculate DST state (may have changed during session)
    m_is_dst = CalculateIsDST(utc_now);
    m_et_offset_hours = m_is_dst ? EDT_OFFSET_HOURS : EST_OFFSET_HOURS;

    // Formula: ET = UTC + offset_hours * 3600
    // Note: offset is negative (-5 or -4), so this subtracts from UTC
    // Example: 21:00 UTC + (-5 * 3600) = 16:00 EST = 4:00 PM ET
    return utc_now + m_et_offset_hours * 3600;
}

//+------------------------------------------------------------------+
//| Get current ET offset in hours (-5 for EST, -4 for EDT)          |
//+------------------------------------------------------------------+
int CApexTimeHandler::GetETOffsetHours()
{
    // Ensure we have fresh DST calculation
    datetime utc_now = GetCurrentUTC();
    m_is_dst = CalculateIsDST(utc_now);
    m_et_offset_hours = m_is_dst ? EDT_OFFSET_HOURS : EST_OFFSET_HOURS;

    return m_et_offset_hours;
}

//+------------------------------------------------------------------+
//| Is DST currently active?                                          |
//+------------------------------------------------------------------+
bool CApexTimeHandler::IsDST()
{
    datetime utc_now = GetCurrentUTC();
    m_is_dst = CalculateIsDST(utc_now);
    return m_is_dst;
}

//+------------------------------------------------------------------+
//| Get minutes from midnight in Eastern Time                         |
//+------------------------------------------------------------------+
int CApexTimeHandler::GetMinutesFromMidnightET(datetime utc_time)
{
    // Calculate ET from UTC
    bool is_dst = CalculateIsDST(utc_time);
    int offset = is_dst ? EDT_OFFSET_HOURS : EST_OFFSET_HOURS;
    datetime et_time = utc_time + offset * 3600;

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
