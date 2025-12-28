//+------------------------------------------------------------------+
//|                                                   CDSTHelper.mqh |
//|                       EA_SCALPER_XAUUSD - Shared DST Utilities   |
//|                         Extracted from CApexTimeHandler.mqh      |
//+------------------------------------------------------------------+
//| PURPOSE: Centralized DST calculation for America/New_York        |
//| Used by: CApexTimeHandler, FTMO_RiskManager, CWallClockEnforcer  |
//+------------------------------------------------------------------+
//| DST RULES (US Daylight Saving Time):                             |
//|   DST starts: 2nd Sunday of March at 2:00 AM local (EST->EDT)    |
//|   DST ends:   1st Sunday of November at 2:00 AM local (EDT->EST) |
//+------------------------------------------------------------------+
#ifndef CDSTHELPER_MQH
#define CDSTHELPER_MQH

#property copyright "EA_SCALPER_XAUUSD"
#property strict

// === DST CONSTANTS (US Daylight Saving Time Rules) ===
#define DST_START_MONTH              3     // March
#define DST_START_NTH_SUNDAY         2     // 2nd Sunday
#define DST_END_MONTH                11    // November
#define DST_END_NTH_SUNDAY           1     // 1st Sunday
#define DST_TRANSITION_HOUR_UTC      7     // 2:00 AM EST = 7:00 UTC (spring forward)
#define DST_TRANSITION_END_HOUR_UTC  6     // 2:00 AM EDT = 6:00 UTC (fall back)

// === ET OFFSET FROM UTC ===
#define EST_OFFSET_HOURS             (-5)  // Eastern Standard Time: UTC-5
#define EDT_OFFSET_HOURS             (-4)  // Eastern Daylight Time: UTC-4

//+------------------------------------------------------------------+
//| CDSTHelper - Static utility class for DST calculations           |
//+------------------------------------------------------------------+
class CDSTHelper
{
public:
    //--- Primary public methods

    //+------------------------------------------------------------------+
    //| Returns true if given UTC date is in US DST (America/New_York)  |
    //| Uses deterministic nth-Sunday algorithm                         |
    //+------------------------------------------------------------------+
    static bool IsDST(datetime utc_time)
    {
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
            return (hour_utc < DST_TRANSITION_END_HOUR_UTC);
        }

        // Should not reach here
        return false;
    }

    //+------------------------------------------------------------------+
    //| Get ET offset from UTC (-4 during DST, -5 during standard)      |
    //+------------------------------------------------------------------+
    static int GetETOffsetHours(datetime utc_time)
    {
        return IsDST(utc_time) ? EDT_OFFSET_HOURS : EST_OFFSET_HOURS;
    }

    //+------------------------------------------------------------------+
    //| Convert UTC to ET                                                |
    //+------------------------------------------------------------------+
    static datetime UTCtoET(datetime utc_time)
    {
        int offset = GetETOffsetHours(utc_time);
        // Formula: ET = UTC + offset_hours * 3600
        // Note: offset is negative (-5 or -4), so this subtracts from UTC
        return utc_time + offset * 3600;
    }

    //+------------------------------------------------------------------+
    //| Convert ET to UTC (inverse of UTCtoET)                           |
    //+------------------------------------------------------------------+
    static datetime ETtoUTC(datetime et_time, bool assume_dst)
    {
        int offset = assume_dst ? EDT_OFFSET_HOURS : EST_OFFSET_HOURS;
        // Formula: UTC = ET - offset_hours * 3600
        return et_time - offset * 3600;
    }

private:
    //+------------------------------------------------------------------+
    //| Get the nth Sunday of a given month                              |
    //| Deterministic algorithm using day-of-week calculation            |
    //+------------------------------------------------------------------+
    static int GetNthSundayOfMonth(int year, int month, int nth)
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
            Print("CDSTHelper: ERROR - GetNthSundayOfMonth returned invalid day: ", day);
            return 1;  // Fallback to 1st
        }

        return day;
    }
};

#endif // CDSTHELPER_MQH
//+------------------------------------------------------------------+
