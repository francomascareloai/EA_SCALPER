//+------------------------------------------------------------------+
//|                                         CNewsCalendarNative.mqh |
//|                                                           Franco |
//|          EA_SCALPER_XAUUSD - Native MQL5 Economic Calendar       |
//+------------------------------------------------------------------+
//| Uses MQL5 built-in economic calendar - NO external APIs needed!  |
//| Real-time data directly from MetaQuotes servers.                 |
//+------------------------------------------------------------------+
#property copyright "Franco"
#property link      "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| News Impact Levels (Native calendar enum - prefixed to avoid     |
//| conflicts with CNewsWindowDetector)                              |
//+------------------------------------------------------------------+
enum ENUM_NATIVE_NEWS_IMPACT
{
   NATIVE_NEWS_CRITICAL = 4,   // FOMC, NFP
   NATIVE_NEWS_HIGH = 3,       // CPI, GDP
   NATIVE_NEWS_MEDIUM = 2,     // Retail Sales, PMI
   NATIVE_NEWS_LOW = 1,        // Consumer Confidence
   NATIVE_NEWS_NONE = 0
};

//+------------------------------------------------------------------+
//| Trading Actions based on news proximity                          |
//+------------------------------------------------------------------+
enum ENUM_NEWS_TRADE_ACTION
{
   NEWS_ACTION_TRADE_NORMAL = 0,     // No news nearby
   NEWS_ACTION_TRADE_CAUTION = 1,    // News approaching, reduce size
   NEWS_ACTION_PREPOSITION = 2,      // Can pre-position for news
   NEWS_ACTION_STRADDLE = 3,         // Setup straddle before news
   NEWS_ACTION_PULLBACK = 4,         // Wait for pullback after news
   NEWS_ACTION_BLOCK = 5             // Too close, no trading
};

//+------------------------------------------------------------------+
//| Gold-Relevant Event Names to track                               |
//+------------------------------------------------------------------+
const string GOLD_EVENTS[] = {
   "Interest Rate Decision",
   "Fed Interest Rate Decision",
   "FOMC Statement",
   "FOMC Press Conference",
   "Nonfarm Payrolls",
   "Non-Farm Employment",
   "Unemployment Rate",
   "CPI",
   "Consumer Price Index",
   "Core CPI",
   "PPI",
   "Producer Price Index",
   "Core PPI",
   "GDP",
   "Gross Domestic Product",
   "Initial Jobless Claims",
   "Continuing Jobless Claims",
   "Retail Sales",
   "Core Retail Sales",
   "ISM Manufacturing",
   "ISM Services",
   "Durable Goods",
   "Trade Balance",
   "PCE",
   "Core PCE",
   "Powell",
   "Yellen",
   "ADP Employment"
};

//+------------------------------------------------------------------+
//| News Event Structure (simplified)                                 |
//+------------------------------------------------------------------+
struct SNewsEventNative
{
   ulong                event_id;       // Event ID from calendar
   ulong                value_id;       // Value ID
   datetime             time_utc;       // Event time (trade server time)
   string               event_name;     // Event name
   string               currency;       // Currency (USD)
   ENUM_NATIVE_NEWS_IMPACT impact;       // Our impact level
   double               forecast;       // Forecast value
   double               previous;       // Previous value
   double               actual;         // Actual value (if released)
   bool                 is_valid;       // Valid event?
   
   void Reset()
   {
      event_id = 0;
      value_id = 0;
      time_utc = 0;
      event_name = "";
      currency = "USD";
      impact = NATIVE_NEWS_NONE;
      forecast = 0;
      previous = 0;
      actual = 0;
      is_valid = false;
   }
};

//+------------------------------------------------------------------+
//| News Window Result Structure                                      |
//+------------------------------------------------------------------+
struct SNewsWindowNative
{
   bool                    in_window;         // Are we in a news window?
   ENUM_NEWS_TRADE_ACTION  action;            // Recommended action
   SNewsEventNative        event;             // The event causing window
   int                     minutes_to_event;  // Minutes until event (negative = passed)
   bool                    is_before_event;   // True if event hasn't happened
   int                     score_adjustment;  // Confluence score adjustment
   double                  size_multiplier;   // Position size multiplier
   string                  reason;            // Human-readable reason
   
   void Reset()
   {
      in_window = false;
      action = NEWS_ACTION_TRADE_NORMAL;
      event.Reset();
      minutes_to_event = 9999;
      is_before_event = true;
      score_adjustment = 0;
      size_multiplier = 1.0;
      reason = "No news nearby";
   }
};

//+------------------------------------------------------------------+
//| Class: CNewsCalendarNative                                        |
//| Purpose: Use MQL5 native calendar for news detection              |
//+------------------------------------------------------------------+
class CNewsCalendarNative
{
private:
   //--- Configuration
   int               m_minutes_before_high;    // Window before HIGH impact
   int               m_minutes_after_high;     // Window after HIGH impact
   int               m_minutes_before_medium;  // Window before MEDIUM impact
   int               m_minutes_after_medium;   // Window after MEDIUM impact
   
   //--- Cached events
   SNewsEventNative  m_events[];               // Cached events
   datetime          m_last_cache_update;      // Last cache update
   int               m_cache_ttl_minutes;      // Cache TTL (refresh interval)
   
   //--- State
   bool              m_initialized;
   bool              m_calendar_available;     // Is calendar API available?
   SNewsWindowNative m_last_result;
   datetime          m_last_check_time;
   
public:
                     CNewsCalendarNative();
                    ~CNewsCalendarNative();
   
   //--- Initialization
   bool              Init(int minutes_before = 30, int minutes_after = 15);
   void              SetWindowTimes(int before_high, int after_high, int before_med, int after_med);
   
   //--- Main Methods
   SNewsWindowNative CheckNewsWindow();
   bool              IsInNewsWindow() { return CheckNewsWindow().in_window; }
   bool              ShouldBlockTrading() { return CheckNewsWindow().action == NEWS_ACTION_BLOCK; }
   ENUM_NEWS_TRADE_ACTION GetRecommendedAction() { return CheckNewsWindow().action; }
   
   //--- Event Access
   bool              GetNextHighImpactEvent(SNewsEventNative &event);
   bool              GetEventsForToday(SNewsEventNative &events[]);
   int               GetMinutesToNextEvent();
   
   //--- Score Integration
   int               GetScoreAdjustment() { return CheckNewsWindow().score_adjustment; }
   double            GetSizeMultiplier() { return CheckNewsWindow().size_multiplier; }
   
   //--- Status
   bool              IsInitialized() const { return m_initialized; }
   bool              IsCalendarAvailable() const { return m_calendar_available; }
   int               GetCachedEventCount() const { return ArraySize(m_events); }
   datetime          GetLastUpdateTime() const { return m_last_cache_update; }
   
   //--- Utility
   void              PrintStatus();
   void              RefreshCache();

private:
   //--- Data Loading from MQL5 Calendar
   bool              LoadFromNativeCalendar();
   bool              IsGoldRelevantEvent(const string &event_name);
   ENUM_NATIVE_NEWS_IMPACT ConvertImportance(ENUM_CALENDAR_EVENT_IMPORTANCE importance, const string &event_name);
   
   //--- Cache Management
   bool              IsCacheValid();
   void              SortEventsByTime();
   
   //--- String helpers
   string            ImpactToString(ENUM_NATIVE_NEWS_IMPACT impact);
   string            ActionToString(ENUM_NEWS_TRADE_ACTION action);
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CNewsCalendarNative::CNewsCalendarNative()
{
   m_minutes_before_high = 30;
   m_minutes_after_high = 15;
   m_minutes_before_medium = 15;
   m_minutes_after_medium = 10;
   
   m_last_cache_update = 0;
   m_cache_ttl_minutes = 30;  // Refresh every 30 min
   
   m_initialized = false;
   m_calendar_available = false;
   m_last_check_time = 0;
   m_last_result.Reset();
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CNewsCalendarNative::~CNewsCalendarNative()
{
   ArrayFree(m_events);
}

//+------------------------------------------------------------------+
//| Initialize the detector                                           |
//+------------------------------------------------------------------+
bool CNewsCalendarNative::Init(int minutes_before = 30, int minutes_after = 15)
{
   m_minutes_before_high = minutes_before;
   m_minutes_after_high = minutes_after;
   m_minutes_before_medium = minutes_before / 2;
   m_minutes_after_medium = minutes_after / 2;
   
   // Test if calendar API is available
   MqlCalendarCountry countries[];
   m_calendar_available = (CalendarCountries(countries) > 0);
   
   if(!m_calendar_available)
   {
      Print("CNewsCalendarNative: WARNING - Calendar API not available!");
      Print("CNewsCalendarNative: This may be a demo limitation or terminal setting.");
      Print("CNewsCalendarNative: Will allow trading (fail-safe mode).");
   }
   else
   {
      Print("CNewsCalendarNative: Calendar API available, found ", ArraySize(countries), " countries");
   }
   
   // Load initial data
   RefreshCache();
   
   m_initialized = true;
   
   Print("CNewsCalendarNative: Initialized with ", ArraySize(m_events), " USD events cached");
   Print("CNewsCalendarNative: Window = ", m_minutes_before_high, " min before / ", 
         m_minutes_after_high, " min after (HIGH impact)");
   
   return true;
}

//+------------------------------------------------------------------+
//| Set window times for different impact levels                      |
//+------------------------------------------------------------------+
void CNewsCalendarNative::SetWindowTimes(int before_high, int after_high, int before_med, int after_med)
{
   m_minutes_before_high = before_high;
   m_minutes_after_high = after_high;
   m_minutes_before_medium = before_med;
   m_minutes_after_medium = after_med;
}

//+------------------------------------------------------------------+
//| Load events from MQL5 Native Calendar                             |
//+------------------------------------------------------------------+
bool CNewsCalendarNative::LoadFromNativeCalendar()
{
   if(!m_calendar_available)
      return false;
   
   ArrayFree(m_events);
   
   // Get events for next 7 days
   datetime from_time = TimeTradeServer();
   datetime to_time = from_time + 7 * 24 * 60 * 60;  // +7 days
   
   // Get USD events (affects Gold directly)
   MqlCalendarValue values[];
   string currency = "USD";
   
   int count = CalendarValueHistory(values, from_time, to_time, NULL, currency);
   
   if(count <= 0)
   {
      int error = GetLastError();
      if(error != 0)
         Print("CNewsCalendarNative: CalendarValueHistory error: ", error);
      return false;
   }
   
   Print("CNewsCalendarNative: Fetched ", count, " USD calendar values");
   
   // Process each value
   int valid_count = 0;
   ArrayResize(m_events, count);
   
   for(int i = 0; i < count; i++)
   {
      // Get event details
      MqlCalendarEvent event_info;
      if(!CalendarEventById(values[i].event_id, event_info))
         continue;
      
      // Filter: only Gold-relevant events
      if(!IsGoldRelevantEvent(event_info.name))
         continue;
      
      // Filter: only HIGH and MODERATE importance
      if(event_info.importance != CALENDAR_IMPORTANCE_HIGH && 
         event_info.importance != CALENDAR_IMPORTANCE_MODERATE)
         continue;
      
      // Populate our structure
      m_events[valid_count].value_id = values[i].id;
      m_events[valid_count].event_id = values[i].event_id;
      m_events[valid_count].time_utc = values[i].time;
      m_events[valid_count].event_name = event_info.name;
      m_events[valid_count].currency = "USD";
      m_events[valid_count].impact = ConvertImportance(event_info.importance, event_info.name);
      
      // Get values (divide by 1,000,000 as per MQL5 docs)
      m_events[valid_count].forecast = values[i].HasForecastValue() ? values[i].GetForecastValue() : 0;
      m_events[valid_count].previous = values[i].HasPreviousValue() ? values[i].GetPreviousValue() : 0;
      m_events[valid_count].actual = values[i].HasActualValue() ? values[i].GetActualValue() : 0;
      m_events[valid_count].is_valid = true;
      
      valid_count++;
   }
   
   ArrayResize(m_events, valid_count);
   
   Print("CNewsCalendarNative: Filtered to ", valid_count, " Gold-relevant events");
   
   return valid_count > 0;
}

//+------------------------------------------------------------------+
//| Check if event is relevant for Gold trading                       |
//+------------------------------------------------------------------+
bool CNewsCalendarNative::IsGoldRelevantEvent(const string &event_name)
{
   string name_lower = event_name;
   StringToLower(name_lower);
   
   for(int i = 0; i < ArraySize(GOLD_EVENTS); i++)
   {
      string keyword = GOLD_EVENTS[i];
      StringToLower(keyword);
      
      if(StringFind(name_lower, keyword) >= 0)
         return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Convert MQL5 importance to our impact level                       |
//+------------------------------------------------------------------+
ENUM_NATIVE_NEWS_IMPACT CNewsCalendarNative::ConvertImportance(ENUM_CALENDAR_EVENT_IMPORTANCE importance, const string &event_name)
{
   string name_lower = event_name;
   StringToLower(name_lower);
   
   // CRITICAL events (always stay out completely)
   if(StringFind(name_lower, "fomc") >= 0 ||
      StringFind(name_lower, "fed interest") >= 0 ||
      StringFind(name_lower, "nonfarm") >= 0 ||
      StringFind(name_lower, "non-farm") >= 0 ||
      StringFind(name_lower, "powell") >= 0)
   {
      return NATIVE_NEWS_CRITICAL;
   }
   
   // Map MQL5 importance to our levels
   if(importance == CALENDAR_IMPORTANCE_HIGH)
      return NATIVE_NEWS_HIGH;
   else if(importance == CALENDAR_IMPORTANCE_MODERATE)
      return NATIVE_NEWS_MEDIUM;
   else
      return NATIVE_NEWS_LOW;
}

//+------------------------------------------------------------------+
//| Main method: Check if we're in a news window                      |
//+------------------------------------------------------------------+
SNewsWindowNative CNewsCalendarNative::CheckNewsWindow()
{
   // Use cached result if checked recently (within 5 seconds)
   datetime now = TimeTradeServer();
   if(m_last_check_time > 0 && (now - m_last_check_time) < 5)
      return m_last_result;
   
   m_last_check_time = now;
   m_last_result.Reset();
   
   // If calendar not available, allow trading (fail-safe)
   if(!m_calendar_available)
   {
      m_last_result.reason = "Calendar unavailable - trading allowed";
      return m_last_result;
   }
   
   // Refresh cache if needed
   if(!IsCacheValid())
      RefreshCache();
   
   // No events? Allow trading
   if(ArraySize(m_events) == 0)
   {
      m_last_result.reason = "No upcoming news events";
      return m_last_result;
   }
   
   int now_ts = (int)now;
   
   // Search through cached events
   for(int i = 0; i < ArraySize(m_events); i++)
   {
      if(!m_events[i].is_valid)
         continue;
      
      int event_ts = (int)m_events[i].time_utc;
      int diff_seconds = event_ts - now_ts;
      int diff_minutes = diff_seconds / 60;
      
      // Determine window based on impact level
      int window_before, window_after;
      
      if(m_events[i].impact == NATIVE_NEWS_CRITICAL || m_events[i].impact == NATIVE_NEWS_HIGH)
      {
         window_before = m_minutes_before_high;
         window_after = m_minutes_after_high;
      }
      else if(m_events[i].impact == NATIVE_NEWS_MEDIUM)
      {
         window_before = m_minutes_before_medium;
         window_after = m_minutes_after_medium;
      }
      else
      {
         continue;  // Skip LOW impact
      }
      
      // CRITICAL events get extended window
      if(m_events[i].impact == NATIVE_NEWS_CRITICAL)
      {
         window_before = (int)(window_before * 1.5);  // 45 min before
         window_after = (int)(window_after * 1.5);    // 22 min after
      }
      
      // Check if within news window
      if(diff_minutes >= -window_after && diff_minutes <= window_before)
      {
         m_last_result.in_window = true;
         m_last_result.event = m_events[i];
         m_last_result.minutes_to_event = diff_minutes;
         m_last_result.is_before_event = (diff_minutes > 0);
         
         // Determine action and adjustments
         if(m_events[i].impact == NATIVE_NEWS_CRITICAL)
         {
            // CRITICAL = ALWAYS BLOCK
            m_last_result.action = NEWS_ACTION_BLOCK;
            m_last_result.score_adjustment = -100;
            m_last_result.size_multiplier = 0.0;
            m_last_result.reason = "CRITICAL: " + m_events[i].event_name + " - NO TRADING";
         }
         else if(MathAbs(diff_minutes) <= 5)
         {
            // Too close to any HIGH/MED event
            m_last_result.action = NEWS_ACTION_BLOCK;
            m_last_result.score_adjustment = -50;
            m_last_result.size_multiplier = 0.0;
            m_last_result.reason = "Too close to " + m_events[i].event_name;
         }
         else if(diff_minutes > 0 && diff_minutes <= 10)
         {
            // 5-10 min before = Straddle opportunity
            m_last_result.action = NEWS_ACTION_STRADDLE;
            m_last_result.score_adjustment = -30;
            m_last_result.size_multiplier = 0.25;
            m_last_result.reason = "Straddle window: " + m_events[i].event_name;
         }
         else if(diff_minutes > 10)
         {
            // 10+ min before = Pre-position possible
            m_last_result.action = NEWS_ACTION_PREPOSITION;
            m_last_result.score_adjustment = -15;
            m_last_result.size_multiplier = 0.5;
            m_last_result.reason = "Pre-position: " + m_events[i].event_name + " in " + IntegerToString(diff_minutes) + "m";
         }
         else if(diff_minutes < 0 && diff_minutes >= -5)
         {
            // Just after = Still dangerous
            m_last_result.action = NEWS_ACTION_BLOCK;
            m_last_result.score_adjustment = -40;
            m_last_result.size_multiplier = 0.0;
            m_last_result.reason = "Just released: " + m_events[i].event_name;
         }
         else
         {
            // 5-15 min after = Pullback opportunity
            m_last_result.action = NEWS_ACTION_PULLBACK;
            m_last_result.score_adjustment = -20;
            m_last_result.size_multiplier = 0.5;
            m_last_result.reason = "Pullback window: " + m_events[i].event_name;
         }
         
         return m_last_result;
      }
      
      // Check for caution zone (extended warning)
      if(diff_minutes > window_before && diff_minutes <= window_before * 2)
      {
         m_last_result.in_window = false;
         m_last_result.action = NEWS_ACTION_TRADE_CAUTION;
         m_last_result.event = m_events[i];
         m_last_result.minutes_to_event = diff_minutes;
         m_last_result.score_adjustment = -5;
         m_last_result.size_multiplier = 0.75;
         m_last_result.reason = "Caution: " + m_events[i].event_name + " in " + 
                                IntegerToString(diff_minutes) + " min";
      }
   }
   
   return m_last_result;
}

//+------------------------------------------------------------------+
//| Get next HIGH impact event                                        |
//+------------------------------------------------------------------+
bool CNewsCalendarNative::GetNextHighImpactEvent(SNewsEventNative &event)
{
   if(!IsCacheValid())
      RefreshCache();
   
   datetime now = TimeTradeServer();
   
   for(int i = 0; i < ArraySize(m_events); i++)
   {
      if(m_events[i].is_valid && 
         (m_events[i].impact == NATIVE_NEWS_HIGH || m_events[i].impact == NATIVE_NEWS_CRITICAL) &&
         m_events[i].time_utc > now)
      {
         event = m_events[i];
         return true;
      }
   }
   
   event.Reset();
   return false;
}

//+------------------------------------------------------------------+
//| Get events for today                                              |
//+------------------------------------------------------------------+
bool CNewsCalendarNative::GetEventsForToday(SNewsEventNative &events[])
{
   if(!IsCacheValid())
      RefreshCache();
   
   datetime now = TimeTradeServer();
   MqlDateTime dt;
   TimeToStruct(now, dt);
   
   // Start and end of today
   datetime day_start = StringToTime(IntegerToString(dt.year) + "." + 
                                      IntegerToString(dt.mon) + "." + 
                                      IntegerToString(dt.day) + " 00:00:00");
   datetime day_end = day_start + 24 * 60 * 60 - 1;
   
   ArrayFree(events);
   int count = 0;
   
   for(int i = 0; i < ArraySize(m_events); i++)
   {
      if(m_events[i].is_valid && 
         m_events[i].time_utc >= day_start && 
         m_events[i].time_utc <= day_end)
      {
         ArrayResize(events, count + 1);
         events[count] = m_events[i];
         count++;
      }
   }
   
   return count > 0;
}

//+------------------------------------------------------------------+
//| Get minutes to next event                                         |
//+------------------------------------------------------------------+
int CNewsCalendarNative::GetMinutesToNextEvent()
{
   SNewsEventNative next_event;
   if(GetNextHighImpactEvent(next_event))
   {
      datetime now = TimeTradeServer();
      return (int)((next_event.time_utc - now) / 60);
   }
   return 9999;
}

//+------------------------------------------------------------------+
//| Refresh cache from MQL5 calendar                                  |
//+------------------------------------------------------------------+
void CNewsCalendarNative::RefreshCache()
{
   bool success = LoadFromNativeCalendar();
   
   if(success)
   {
      m_last_cache_update = TimeTradeServer();
      SortEventsByTime();
      Print("CNewsCalendarNative: Cache refreshed with ", ArraySize(m_events), " events");
   }
   else
   {
      Print("CNewsCalendarNative: Warning - Cache refresh failed");
   }
}

//+------------------------------------------------------------------+
//| Check if cache is still valid                                     |
//+------------------------------------------------------------------+
bool CNewsCalendarNative::IsCacheValid()
{
   if(ArraySize(m_events) == 0)
      return false;
   
   datetime now = TimeTradeServer();
   int age_minutes = (int)((now - m_last_cache_update) / 60);
   
   return age_minutes < m_cache_ttl_minutes;
}

//+------------------------------------------------------------------+
//| Sort events by time                                               |
//+------------------------------------------------------------------+
void CNewsCalendarNative::SortEventsByTime()
{
   int n = ArraySize(m_events);
   
   for(int i = 0; i < n - 1; i++)
   {
      for(int j = 0; j < n - i - 1; j++)
      {
         if(m_events[j].time_utc > m_events[j + 1].time_utc)
         {
            SNewsEventNative temp = m_events[j];
            m_events[j] = m_events[j + 1];
            m_events[j + 1] = temp;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Convert impact to string                                          |
//+------------------------------------------------------------------+
string CNewsCalendarNative::ImpactToString(ENUM_NATIVE_NEWS_IMPACT impact)
{
   switch(impact)
   {
      case NATIVE_NEWS_CRITICAL: return "CRITICAL";
      case NATIVE_NEWS_HIGH:     return "HIGH";
      case NATIVE_NEWS_MEDIUM:   return "MEDIUM";
      case NATIVE_NEWS_LOW:      return "LOW";
      default:                   return "NONE";
   }
}

//+------------------------------------------------------------------+
//| Convert action to string                                          |
//+------------------------------------------------------------------+
string CNewsCalendarNative::ActionToString(ENUM_NEWS_TRADE_ACTION action)
{
   switch(action)
   {
      case NEWS_ACTION_TRADE_NORMAL:  return "NORMAL";
      case NEWS_ACTION_TRADE_CAUTION: return "CAUTION";
      case NEWS_ACTION_PREPOSITION:   return "PREPOSITION";
      case NEWS_ACTION_STRADDLE:      return "STRADDLE";
      case NEWS_ACTION_PULLBACK:      return "PULLBACK";
      case NEWS_ACTION_BLOCK:         return "BLOCK";
      default:                        return "UNKNOWN";
   }
}

//+------------------------------------------------------------------+
//| Print current status                                              |
//+------------------------------------------------------------------+
void CNewsCalendarNative::PrintStatus()
{
   Print("=== CNewsCalendarNative Status ===");
   Print("Initialized: ", m_initialized);
   Print("Calendar API Available: ", m_calendar_available);
   Print("Cached Events: ", ArraySize(m_events));
   Print("Cache Age (min): ", (int)((TimeTradeServer() - m_last_cache_update) / 60));
   
   SNewsWindowNative result = CheckNewsWindow();
   Print("In News Window: ", result.in_window);
   Print("Action: ", ActionToString(result.action));
   Print("Score Adjustment: ", result.score_adjustment);
   Print("Size Multiplier: ", result.size_multiplier);
   Print("Reason: ", result.reason);
   
   if(result.event.is_valid)
   {
      Print("Event: ", result.event.event_name);
      Print("Impact: ", ImpactToString(result.event.impact));
      Print("Time: ", TimeToString(result.event.time_utc, TIME_DATE | TIME_MINUTES));
      Print("Minutes to Event: ", result.minutes_to_event);
   }
   
   // List upcoming events
   Print("--- Upcoming Events ---");
   datetime now = TimeTradeServer();
   int shown = 0;
   for(int i = 0; i < ArraySize(m_events) && shown < 5; i++)
   {
      if(m_events[i].time_utc > now)
      {
         int mins = (int)((m_events[i].time_utc - now) / 60);
         Print("  ", TimeToString(m_events[i].time_utc, TIME_DATE | TIME_MINUTES), 
               " | ", ImpactToString(m_events[i].impact),
               " | ", m_events[i].event_name,
               " (in ", mins, " min)");
         shown++;
      }
   }
   
   Print("================================");
}

//+------------------------------------------------------------------+
