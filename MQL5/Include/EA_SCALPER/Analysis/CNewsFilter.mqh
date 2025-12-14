//+------------------------------------------------------------------+
//|                                                 CNewsFilter.mqh |
//|                           EA_SCALPER_XAUUSD - Singularity Edition |
//|                                                                  |
//|  HIGH-IMPACT NEWS AVOIDANCE                                      |
//|                                                                  |
//|  WHY AVOID NEWS:                                                 |
//|  - Spreads widen 10-50x during major releases                    |
//|  - Slippage can be 50+ pips                                      |
//|  - Price action becomes random (no edge)                         |
//|  - Stop hunting becomes extreme                                  |
//|  - Even correct direction trades get stopped out                 |
//|                                                                  |
//|  CRITICAL NEWS FOR XAUUSD:                                       |
//|  1. NFP (Non-Farm Payrolls) - First Friday of month              |
//|  2. FOMC (Fed Rate Decision) - 8x per year                       |
//|  3. CPI (Inflation) - Monthly                                    |
//|  4. Core PCE - Fed's preferred inflation gauge                   |
//|  5. GDP - Quarterly                                              |
//|  6. Jobless Claims - Weekly (less impact)                        |
//|                                                                  |
//|  STRATEGY:                                                       |
//|  - Block new entries 30 min before high-impact news              |
//|  - Stay out 30 min after release (initial volatility)            |
//|  - Allow manual override for brave traders                       |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD - Singularity Edition"
#property strict

//+------------------------------------------------------------------+
//| News Impact Level                                                 |
//+------------------------------------------------------------------+
enum ENUM_NEWS_IMPACT
{
   NEWS_IMPACT_NONE = 0,
   NEWS_IMPACT_LOW,
   NEWS_IMPACT_MEDIUM,
   NEWS_IMPACT_HIGH,
   NEWS_IMPACT_CRITICAL     // FOMC, NFP - stay completely out
};

//+------------------------------------------------------------------+
//| News Event Structure                                              |
//+------------------------------------------------------------------+
struct SNewsEvent
{
   string            name;
   datetime          event_time;
   ENUM_NEWS_IMPACT  impact;
   int               buffer_before_min;   // Minutes to block before
   int               buffer_after_min;    // Minutes to block after
   bool              affects_gold;        // Directly affects XAUUSD
   
   void Reset()
   {
      name = "";
      event_time = 0;
      impact = NEWS_IMPACT_NONE;
      buffer_before_min = 0;
      buffer_after_min = 0;
      affects_gold = false;
   }
};

//+------------------------------------------------------------------+
//| News Filter Class                                                 |
//+------------------------------------------------------------------+
class CNewsFilter
{
private:
   // Settings
   int               m_default_buffer_before;   // Default minutes before
   int               m_default_buffer_after;    // Default minutes after
   bool              m_filter_enabled;
   bool              m_block_high_impact;
   bool              m_block_medium_impact;
   int               m_gmt_offset;              // Broker GMT offset
   
   // Scheduled news events (current month)
   SNewsEvent        m_events[];
   int               m_event_count;
   
   // State
   SNewsEvent        m_next_event;
   bool              m_in_blackout;
   
   // Internal
   void              LoadMonthlySchedule(int year, int month);
   void              AddEvent(string name, datetime time, ENUM_NEWS_IMPACT impact, 
                             int buf_before = 30, int buf_after = 30, bool gold_specific = true);
   datetime          GetFirstFriday(int year, int month);
   datetime          GetNthWeekday(int year, int month, int weekday, int n);
   
public:
   CNewsFilter();
   ~CNewsFilter() {}
   
   // Initialization
   bool              Initialize(int gmt_offset = 0);
   void              RefreshSchedule();
   
   // Main check
   bool              IsTradingAllowed();
   bool              IsInBlackoutWindow();
   
   // Event info
   SNewsEvent        GetNextEvent();
   int               MinutesToNextEvent();
   string            GetCurrentStatus();
   
   // Configuration
   void              SetEnabled(bool enabled) { m_filter_enabled = enabled; }
   void              SetBuffers(int before, int after) { m_default_buffer_before = before; m_default_buffer_after = after; }
   void              SetGMTOffset(int offset) { m_gmt_offset = offset; }
   void              BlockHighImpact(bool block) { m_block_high_impact = block; }
   void              BlockMediumImpact(bool block) { m_block_medium_impact = block; }
   
   // Manual event addition
   void              AddCustomEvent(string name, datetime time, ENUM_NEWS_IMPACT impact);
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CNewsFilter::CNewsFilter()
{
   m_default_buffer_before = 30;    // 30 min before
   m_default_buffer_after = 30;     // 30 min after
   m_filter_enabled = true;
   m_block_high_impact = true;
   m_block_medium_impact = false;
   m_gmt_offset = 0;
   m_event_count = 0;
   m_in_blackout = false;
   m_next_event.Reset();
   
   ArrayResize(m_events, 50);
}

//+------------------------------------------------------------------+
//| Initialize                                                        |
//+------------------------------------------------------------------+
bool CNewsFilter::Initialize(int gmt_offset = 0)
{
   m_gmt_offset = gmt_offset;
   
   // Load current and next month schedule
   MqlDateTime dt;
   TimeCurrent(dt);
   LoadMonthlySchedule(dt.year, dt.mon);
   
   // Also load next month
   int next_month = dt.mon + 1;
   int next_year = dt.year;
   if(next_month > 12) { next_month = 1; next_year++; }
   LoadMonthlySchedule(next_year, next_month);
   
   Print("CNewsFilter: Initialized with ", m_event_count, " events scheduled");
   return true;
}

//+------------------------------------------------------------------+
//| Refresh schedule (call monthly)                                   |
//+------------------------------------------------------------------+
void CNewsFilter::RefreshSchedule()
{
   m_event_count = 0;
   Initialize(m_gmt_offset);
}

//+------------------------------------------------------------------+
//| Load monthly news schedule                                        |
//| Note: Times are in GMT, adjust for broker time                    |
//+------------------------------------------------------------------+
void CNewsFilter::LoadMonthlySchedule(int year, int month)
{
   // NFP - First Friday of month at 13:30 GMT (8:30 EST)
   datetime nfp = GetFirstFriday(year, month);
   nfp += 13 * 3600 + 30 * 60;  // 13:30 GMT
   AddEvent("NFP", nfp, NEWS_IMPACT_CRITICAL, 60, 60, true);
   
   // CPI - Usually around 13th of month at 13:30 GMT
   // Approximate: 2nd Tuesday or Wednesday
   datetime cpi = GetNthWeekday(year, month, 2, 2);  // 2nd Tuesday
   cpi += 13 * 3600 + 30 * 60;
   AddEvent("CPI", cpi, NEWS_IMPACT_CRITICAL, 30, 45, true);
   
   // Core PCE - Last Friday of month (approx)
   datetime pce = GetNthWeekday(year, month, 5, 4);  // 4th Friday
   pce += 13 * 3600 + 30 * 60;
   AddEvent("Core PCE", pce, NEWS_IMPACT_HIGH, 30, 30, true);
   
   // Jobless Claims - Every Thursday at 13:30 GMT
   for(int week = 1; week <= 5; week++)
   {
      datetime claims = GetNthWeekday(year, month, 4, week);  // Thursday
      if(claims > 0)
      {
         claims += 13 * 3600 + 30 * 60;
         AddEvent("Jobless Claims", claims, NEWS_IMPACT_MEDIUM, 15, 15, false);
      }
   }
   
   // FOMC - 8x per year, typically on Wednesday
   // Major months: Jan, Mar, May, Jun, Jul, Sep, Nov, Dec
   // Only add if this is an FOMC month
   int fomc_months[] = {1, 3, 5, 6, 7, 9, 11, 12};
   bool is_fomc_month = false;
   for(int i = 0; i < ArraySize(fomc_months); i++)
   {
      if(month == fomc_months[i]) { is_fomc_month = true; break; }
   }
   
   if(is_fomc_month)
   {
      // FOMC usually 3rd Wednesday at 19:00 GMT (2:00 PM EST)
      datetime fomc = GetNthWeekday(year, month, 3, 3);  // 3rd Wednesday
      fomc += 19 * 3600;
      AddEvent("FOMC", fomc, NEWS_IMPACT_CRITICAL, 120, 60, true);
   }
   
   // GDP - End of month (preliminary) at 13:30 GMT
   // Usually 3rd or 4th Thursday
   datetime gdp = GetNthWeekday(year, month, 4, 4);  // 4th Thursday
   gdp += 13 * 3600 + 30 * 60;
   AddEvent("GDP", gdp, NEWS_IMPACT_HIGH, 30, 30, true);
}

//+------------------------------------------------------------------+
//| Add event to schedule                                             |
//+------------------------------------------------------------------+
void CNewsFilter::AddEvent(string name, datetime time, ENUM_NEWS_IMPACT impact,
                           int buf_before, int buf_after, bool gold_specific)
{
   // Only add future events
   if(time <= TimeCurrent()) return;
   
   // Adjust for GMT offset
   time += m_gmt_offset * 3600;
   
   if(m_event_count >= ArraySize(m_events))
      ArrayResize(m_events, m_event_count + 20);
   
   m_events[m_event_count].name = name;
   m_events[m_event_count].event_time = time;
   m_events[m_event_count].impact = impact;
   m_events[m_event_count].buffer_before_min = buf_before;
   m_events[m_event_count].buffer_after_min = buf_after;
   m_events[m_event_count].affects_gold = gold_specific;
   
   m_event_count++;
}

//+------------------------------------------------------------------+
//| Get first Friday of month                                         |
//+------------------------------------------------------------------+
datetime CNewsFilter::GetFirstFriday(int year, int month)
{
   MqlDateTime dt;
   dt.year = year;
   dt.mon = month;
   dt.day = 1;
   dt.hour = 0;
   dt.min = 0;
   dt.sec = 0;
   
   datetime first = StructToTime(dt);
   TimeToStruct(first, dt);
   
   // Find first Friday (day_of_week = 5)
   int days_until_friday = (5 - dt.day_of_week + 7) % 7;
   if(days_until_friday == 0 && dt.day_of_week != 5) days_until_friday = 7;
   
   return first + days_until_friday * 86400;
}

//+------------------------------------------------------------------+
//| Get Nth weekday of month                                          |
//+------------------------------------------------------------------+
datetime CNewsFilter::GetNthWeekday(int year, int month, int weekday, int n)
{
   MqlDateTime dt;
   dt.year = year;
   dt.mon = month;
   dt.day = 1;
   dt.hour = 0;
   dt.min = 0;
   dt.sec = 0;
   
   datetime first = StructToTime(dt);
   TimeToStruct(first, dt);
   
   // Find first occurrence of weekday
   int days_until = (weekday - dt.day_of_week + 7) % 7;
   datetime first_occurrence = first + days_until * 86400;
   
   // Add (n-1) weeks
   datetime result = first_occurrence + (n - 1) * 7 * 86400;
   
   // Verify still in same month
   TimeToStruct(result, dt);
   if(dt.mon != month) return 0;
   
   return result;
}

//+------------------------------------------------------------------+
//| Main trading allowed check                                        |
//+------------------------------------------------------------------+
bool CNewsFilter::IsTradingAllowed()
{
   if(!m_filter_enabled) return true;
   
   return !IsInBlackoutWindow();
}

//+------------------------------------------------------------------+
//| Check if currently in blackout window                             |
//+------------------------------------------------------------------+
bool CNewsFilter::IsInBlackoutWindow()
{
   datetime now = TimeCurrent();
   m_in_blackout = false;
   m_next_event.Reset();
   
   for(int i = 0; i < m_event_count; i++)
   {
      // Skip if impact not blocked
      if(m_events[i].impact == NEWS_IMPACT_MEDIUM && !m_block_medium_impact)
         continue;
      if(m_events[i].impact == NEWS_IMPACT_LOW)
         continue;
      if((m_events[i].impact == NEWS_IMPACT_HIGH || m_events[i].impact == NEWS_IMPACT_CRITICAL) && !m_block_high_impact)
         continue;
      
      datetime event_time = m_events[i].event_time;
      datetime blackout_start = event_time - m_events[i].buffer_before_min * 60;
      datetime blackout_end = event_time + m_events[i].buffer_after_min * 60;
      
      // Currently in blackout?
      if(now >= blackout_start && now <= blackout_end)
      {
         m_in_blackout = true;
         m_next_event = m_events[i];
         return true;
      }
      
      // Track next upcoming event
      if(event_time > now && m_next_event.event_time == 0)
      {
         m_next_event = m_events[i];
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Get next scheduled event                                          |
//+------------------------------------------------------------------+
SNewsEvent CNewsFilter::GetNextEvent()
{
   if(m_next_event.event_time == 0)
      IsInBlackoutWindow();  // This will populate m_next_event
   
   return m_next_event;
}

//+------------------------------------------------------------------+
//| Minutes to next event                                             |
//+------------------------------------------------------------------+
int CNewsFilter::MinutesToNextEvent()
{
   if(m_next_event.event_time == 0)
      IsInBlackoutWindow();
   
   if(m_next_event.event_time == 0) return 99999;
   
   int seconds = (int)(m_next_event.event_time - TimeCurrent());
   return seconds / 60;
}

//+------------------------------------------------------------------+
//| Get current status string                                         |
//+------------------------------------------------------------------+
string CNewsFilter::GetCurrentStatus()
{
   if(!m_filter_enabled)
      return "News filter: DISABLED";
   
   if(m_in_blackout)
   {
      return "NEWS BLACKOUT: " + m_next_event.name + 
             " | Impact: " + EnumToString(m_next_event.impact);
   }
   
   if(m_next_event.event_time > 0)
   {
      int mins = MinutesToNextEvent();
      return "Next: " + m_next_event.name + " in " + IntegerToString(mins) + " min";
   }
   
   return "No upcoming high-impact news";
}

//+------------------------------------------------------------------+
//| Add custom event                                                  |
//+------------------------------------------------------------------+
void CNewsFilter::AddCustomEvent(string name, datetime time, ENUM_NEWS_IMPACT impact)
{
   AddEvent(name, time, impact, m_default_buffer_before, m_default_buffer_after, true);
}
