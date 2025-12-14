//+------------------------------------------------------------------+
//|                                         CNewsWindowDetector.mqh |
//|                                                           Franco |
//|                   EA_SCALPER_XAUUSD v4.0 - News Trading Support  |
//+------------------------------------------------------------------+
#property copyright "Franco"
#property link      "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Design Decisions (from pre-implementation analysis):             |
//| 1. Use TimeGMT() for all time comparisons (not TimeCurrent)      |
//| 2. Support both HTTP API and local CSV file                       |
//| 3. Cache events in memory for fast OnTick access                  |
//| 4. Fail gracefully - if detection fails, allow trading           |
//| 5. All timestamps in UTC (Unix epoch)                            |
//+------------------------------------------------------------------+

//--- News Impact Levels
enum ENUM_NEWS_IMPACT
{
   NEWS_IMPACT_HIGH = 3,
   NEWS_IMPACT_MEDIUM = 2,
   NEWS_IMPACT_LOW = 1,
   NEWS_IMPACT_NONE = 0
};

//--- Trading Actions based on news
enum ENUM_NEWS_ACTION
{
   NEWS_ACTION_NORMAL = 0,      // No news nearby, trade normally
   NEWS_ACTION_CAUTION = 1,     // News approaching, reduce size
   NEWS_ACTION_PREPOSITION = 2, // Can pre-position for news
   NEWS_ACTION_STRADDLE = 3,    // Setup straddle before news
   NEWS_ACTION_PULLBACK = 4,    // Wait for pullback after news
   NEWS_ACTION_BLOCK = 5        // Too close to news, no trading
};

//+------------------------------------------------------------------+
//| Economic Event Structure                                          |
//+------------------------------------------------------------------+
struct SEconomicEvent
{
   datetime          time_utc;       // Event time in UTC
   string            event_name;     // Event name
   string            currency;       // Currency (USD for gold-relevant)
   ENUM_NEWS_IMPACT  impact;         // Impact level
   double            forecast;       // Expected value
   double            previous;       // Previous value
   double            actual;         // Actual value (0 if not released)
   bool              is_valid;       // Is this event valid?
   
   void Reset()
   {
      time_utc = 0;
      event_name = "";
      currency = "USD";
      impact = NEWS_IMPACT_NONE;
      forecast = 0;
      previous = 0;
      actual = 0;
      is_valid = false;
   }
};

//+------------------------------------------------------------------+
//| News Window Result Structure                                      |
//+------------------------------------------------------------------+
struct SNewsWindowResult
{
   bool              in_window;         // Are we in a news window?
   ENUM_NEWS_ACTION  action;            // Recommended action
   SEconomicEvent    event;             // The event (if any)
   int               minutes_to_event;  // Minutes until event (negative = passed)
   bool              is_before_event;   // True if event hasn't happened yet
   int               score_adjustment;  // Score adjustment for confluence
   double            size_multiplier;   // Position size multiplier
   string            reason;            // Human-readable reason
   
   void Reset()
   {
      in_window = false;
      action = NEWS_ACTION_NORMAL;
      event.Reset();
      minutes_to_event = 9999;
      is_before_event = true;
      score_adjustment = 0;
      size_multiplier = 1.0;
      reason = "No news";
   }
};

//+------------------------------------------------------------------+
//| Class: CNewsWindowDetector                                        |
//| Purpose: Detect news events and determine trading windows         |
//+------------------------------------------------------------------+
class CNewsWindowDetector
{
private:
   //--- Configuration
   int               m_minutes_before_high;    // Window before HIGH impact
   int               m_minutes_after_high;     // Window after HIGH impact
   int               m_minutes_before_medium;  // Window before MEDIUM impact
   int               m_minutes_after_medium;   // Window after MEDIUM impact
   int               m_broker_gmt_offset;      // Broker's GMT offset
   
   //--- Data sources
   string            m_python_hub_url;         // Python Hub URL
   string            m_csv_file_path;          // Path to CSV file
   bool              m_use_python_hub;         // Use HTTP API or CSV?
   int               m_http_timeout_ms;        // HTTP timeout
   
   //--- Cached events
   SEconomicEvent    m_events[];               // Cached events
   datetime          m_last_cache_update;      // Last cache update time
   int               m_cache_ttl_minutes;      // Cache TTL
   
   //--- State
   bool              m_initialized;
   SNewsWindowResult m_last_result;
   datetime          m_last_check_time;
   
public:
                     CNewsWindowDetector();
                    ~CNewsWindowDetector();
   
   //--- Initialization
   bool              Init(int minutes_before = 30, int minutes_after = 15);
   void              SetPythonHub(string url) { m_python_hub_url = url; m_use_python_hub = true; }
   void              SetCSVFile(string path) { m_csv_file_path = path; m_use_python_hub = false; }
   void              SetBrokerGMTOffset(int offset) { m_broker_gmt_offset = offset; }
   void              SetWindowTimes(int before_high, int after_high, int before_med, int after_med);
   
   //--- Main Methods
   SNewsWindowResult CheckNewsWindow();
   bool              IsInNewsWindow() { return CheckNewsWindow().in_window; }
   bool              ShouldBlockTrading() { return CheckNewsWindow().action == NEWS_ACTION_BLOCK; }
   ENUM_NEWS_ACTION  GetRecommendedAction() { return CheckNewsWindow().action; }
   
   //--- Event Access
   bool              GetNextHighImpactEvent(SEconomicEvent &event);
   bool              GetEventsForToday(SEconomicEvent &events[]);
   int               GetMinutesToNextEvent();
   
   //--- Score Integration
   int               GetScoreAdjustment() { return CheckNewsWindow().score_adjustment; }
   double            GetSizeMultiplier() { return CheckNewsWindow().size_multiplier; }
   
   //--- Status
   bool              IsInitialized() const { return m_initialized; }
   int               GetCachedEventCount() const { return ArraySize(m_events); }
   datetime          GetLastUpdateTime() const { return m_last_cache_update; }
   
   //--- Utility
   void              PrintStatus();
   void              RefreshCache();

private:
   //--- Data Loading
   bool              LoadFromPythonHub();
   bool              LoadFromCSV();
   bool              ParseCSVLine(string line, SEconomicEvent &event);
   
   //--- Time Utilities
   datetime          GetCurrentTimeUTC();
   datetime          BrokerTimeToUTC(datetime broker_time);
   datetime          UTCToBrokerTime(datetime utc_time);
   
   //--- Cache Management
   bool              IsCacheValid();
   void              SortEventsByTime();
   
   //--- HTTP Communication
   bool              HttpGet(string url, string &response);
   bool              ParseJsonSignal(string json, SNewsWindowResult &result);
   
   //--- Impact Parsing
   ENUM_NEWS_IMPACT  StringToImpact(string impact_str);
   string            ImpactToString(ENUM_NEWS_IMPACT impact);
   string            ActionToString(ENUM_NEWS_ACTION action);
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CNewsWindowDetector::CNewsWindowDetector()
{
   m_minutes_before_high = 30;
   m_minutes_after_high = 15;
   m_minutes_before_medium = 15;
   m_minutes_after_medium = 10;
   m_broker_gmt_offset = 0;
   
   m_python_hub_url = "http://127.0.0.1:8000";
   m_csv_file_path = "EA_SCALPER/economic_calendar.csv";
   m_use_python_hub = true;
   m_http_timeout_ms = 5000;
   
   m_last_cache_update = 0;
   m_cache_ttl_minutes = 60;  // Refresh cache every hour
   
   m_initialized = false;
   m_last_check_time = 0;
   m_last_result.Reset();
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CNewsWindowDetector::~CNewsWindowDetector()
{
   ArrayFree(m_events);
}

//+------------------------------------------------------------------+
//| Initialize the detector                                           |
//+------------------------------------------------------------------+
bool CNewsWindowDetector::Init(int minutes_before = 30, int minutes_after = 15)
{
   m_minutes_before_high = minutes_before;
   m_minutes_after_high = minutes_after;
   m_minutes_before_medium = minutes_before / 2;
   m_minutes_after_medium = minutes_after / 2;
   
   // Try to load initial data
   RefreshCache();
   
   m_initialized = true;
   
   Print("CNewsWindowDetector: Initialized with ", ArraySize(m_events), " events cached");
   Print("CNewsWindowDetector: Window = ", m_minutes_before_high, " min before / ", 
         m_minutes_after_high, " min after (HIGH impact)");
   
   return true;
}

//+------------------------------------------------------------------+
//| Set window times for different impact levels                      |
//+------------------------------------------------------------------+
void CNewsWindowDetector::SetWindowTimes(int before_high, int after_high, int before_med, int after_med)
{
   m_minutes_before_high = before_high;
   m_minutes_after_high = after_high;
   m_minutes_before_medium = before_med;
   m_minutes_after_medium = after_med;
}

//+------------------------------------------------------------------+
//| Main method: Check if we're in a news window                      |
//+------------------------------------------------------------------+
SNewsWindowResult CNewsWindowDetector::CheckNewsWindow()
{
   // Use cached result if checked recently (within 5 seconds)
   datetime now = GetCurrentTimeUTC();
   if(m_last_check_time > 0 && (now - m_last_check_time) < 5)
      return m_last_result;
   
   m_last_check_time = now;
   m_last_result.Reset();
   
   // Try Python Hub first (has real-time data)
   if(m_use_python_hub)
   {
      string response;
      string url = m_python_hub_url + "/api/v1/calendar/signal?minutes_before=" + 
                   IntegerToString(m_minutes_before_high) + 
                   "&minutes_after=" + IntegerToString(m_minutes_after_high);
      
      if(HttpGet(url, response))
      {
         if(ParseJsonSignal(response, m_last_result))
            return m_last_result;
      }
   }
   
   // Fallback to cached events
   if(!IsCacheValid())
      RefreshCache();
   
   // Search through cached events
   int now_ts = (int)now;
   
   for(int i = 0; i < ArraySize(m_events); i++)
   {
      if(!m_events[i].is_valid)
         continue;
      
      int event_ts = (int)m_events[i].time_utc;
      int diff_seconds = event_ts - now_ts;
      int diff_minutes = diff_seconds / 60;
      
      // Check based on impact level
      int window_before, window_after;
      
      if(m_events[i].impact == NEWS_IMPACT_HIGH)
      {
         window_before = m_minutes_before_high;
         window_after = m_minutes_after_high;
      }
      else if(m_events[i].impact == NEWS_IMPACT_MEDIUM)
      {
         window_before = m_minutes_before_medium;
         window_after = m_minutes_after_medium;
      }
      else
      {
         continue;  // Skip LOW impact
      }
      
      // Check if within window
      if(diff_minutes >= -window_after && diff_minutes <= window_before)
      {
         m_last_result.in_window = true;
         m_last_result.event = m_events[i];
         m_last_result.minutes_to_event = diff_minutes;
         m_last_result.is_before_event = (diff_minutes > 0);
         
         // Determine action
         if(MathAbs(diff_minutes) <= 5)
         {
            m_last_result.action = NEWS_ACTION_BLOCK;
            m_last_result.score_adjustment = -50;
            m_last_result.size_multiplier = 0.0;
            m_last_result.reason = "Too close to " + m_events[i].event_name;
         }
         else if(diff_minutes > 0 && diff_minutes <= 15)
         {
            m_last_result.action = NEWS_ACTION_STRADDLE;
            m_last_result.score_adjustment = -30;
            m_last_result.size_multiplier = 0.25;
            m_last_result.reason = "Straddle window for " + m_events[i].event_name;
         }
         else if(diff_minutes > 15)
         {
            m_last_result.action = NEWS_ACTION_PREPOSITION;
            m_last_result.score_adjustment = -15;
            m_last_result.size_multiplier = 0.5;
            m_last_result.reason = "Pre-position window for " + m_events[i].event_name;
         }
         else if(diff_minutes < 0 && diff_minutes >= -5)
         {
            m_last_result.action = NEWS_ACTION_BLOCK;
            m_last_result.score_adjustment = -40;
            m_last_result.size_multiplier = 0.0;
            m_last_result.reason = "Just after " + m_events[i].event_name;
         }
         else
         {
            m_last_result.action = NEWS_ACTION_PULLBACK;
            m_last_result.score_adjustment = -20;
            m_last_result.size_multiplier = 0.5;
            m_last_result.reason = "Pullback window for " + m_events[i].event_name;
         }
         
         return m_last_result;
      }
      
      // Check for caution zone (extended window)
      if(diff_minutes > window_before && diff_minutes <= window_before * 2)
      {
         m_last_result.in_window = false;
         m_last_result.action = NEWS_ACTION_CAUTION;
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
bool CNewsWindowDetector::GetNextHighImpactEvent(SEconomicEvent &event)
{
   if(!IsCacheValid())
      RefreshCache();
   
   datetime now = GetCurrentTimeUTC();
   
   for(int i = 0; i < ArraySize(m_events); i++)
   {
      if(m_events[i].is_valid && 
         m_events[i].impact == NEWS_IMPACT_HIGH &&
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
//| Get minutes to next event                                         |
//+------------------------------------------------------------------+
int CNewsWindowDetector::GetMinutesToNextEvent()
{
   SEconomicEvent next_event;
   if(GetNextHighImpactEvent(next_event))
   {
      datetime now = GetCurrentTimeUTC();
      return (int)((next_event.time_utc - now) / 60);
   }
   return 9999;
}

//+------------------------------------------------------------------+
//| Refresh cache from data source                                    |
//+------------------------------------------------------------------+
void CNewsWindowDetector::RefreshCache()
{
   bool success = false;
   
   if(m_use_python_hub)
      success = LoadFromPythonHub();
   
   if(!success)
      success = LoadFromCSV();
   
   if(success)
   {
      m_last_cache_update = GetCurrentTimeUTC();
      SortEventsByTime();
      Print("CNewsWindowDetector: Cache refreshed with ", ArraySize(m_events), " events");
   }
   else
   {
      Print("CNewsWindowDetector: Warning - Failed to refresh cache");
   }
}

//+------------------------------------------------------------------+
//| Load events from Python Hub                                       |
//+------------------------------------------------------------------+
bool CNewsWindowDetector::LoadFromPythonHub()
{
   string response;
   string url = m_python_hub_url + "/api/v1/calendar/events?hours=168";  // 1 week
   
   if(!HttpGet(url, response))
      return false;
   
   // Parse JSON array (simplified parsing)
   // Format: [{"timestamp_utc":123456,"event":"NFP",...},...]
   
   ArrayFree(m_events);
   
   int count = 0;
   int pos = 0;
   
   while((pos = StringFind(response, "\"timestamp_utc\":", pos)) >= 0)
   {
      ArrayResize(m_events, count + 1);
      m_events[count].Reset();
      
      // Parse timestamp
      int ts_start = pos + 16;
      int ts_end = StringFind(response, ",", ts_start);
      string ts_str = StringSubstr(response, ts_start, ts_end - ts_start);
      m_events[count].time_utc = (datetime)StringToInteger(ts_str);
      
      // Parse event name
      int evt_start = StringFind(response, "\"event\":\"", pos) + 9;
      int evt_end = StringFind(response, "\"", evt_start);
      m_events[count].event_name = StringSubstr(response, evt_start, evt_end - evt_start);
      
      // Parse impact
      int imp_start = StringFind(response, "\"impact\":\"", pos) + 10;
      int imp_end = StringFind(response, "\"", imp_start);
      string impact_str = StringSubstr(response, imp_start, imp_end - imp_start);
      m_events[count].impact = StringToImpact(impact_str);
      
      m_events[count].currency = "USD";
      m_events[count].is_valid = true;
      
      count++;
      pos = ts_end;
   }
   
   return count > 0;
}

//+------------------------------------------------------------------+
//| Load events from CSV file                                         |
//+------------------------------------------------------------------+
bool CNewsWindowDetector::LoadFromCSV()
{
   int handle = FileOpen(m_csv_file_path, FILE_READ | FILE_CSV | FILE_ANSI, ',');
   
   if(handle == INVALID_HANDLE)
   {
      Print("CNewsWindowDetector: Cannot open CSV file: ", m_csv_file_path);
      return false;
   }
   
   ArrayFree(m_events);
   int count = 0;
   
   // Skip header
   if(!FileIsEnding(handle))
      FileReadString(handle);
   
   while(!FileIsEnding(handle))
   {
      string line = FileReadString(handle);
      
      if(StringLen(line) < 10)
         continue;
      
      SEconomicEvent event;
      if(ParseCSVLine(line, event))
      {
         ArrayResize(m_events, count + 1);
         m_events[count] = event;
         count++;
      }
   }
   
   FileClose(handle);
   
   return count > 0;
}

//+------------------------------------------------------------------+
//| Parse a single CSV line                                           |
//+------------------------------------------------------------------+
bool CNewsWindowDetector::ParseCSVLine(string line, SEconomicEvent &event)
{
   event.Reset();
   
   string parts[];
   int num_parts = StringSplit(line, ',', parts);
   
   if(num_parts < 4)
      return false;
   
   // timestamp_utc,event,currency,impact,forecast,previous,actual
   event.time_utc = (datetime)StringToInteger(parts[0]);
   event.event_name = parts[1];
   event.currency = parts[2];
   event.impact = StringToImpact(parts[3]);
   
   if(num_parts > 4 && StringLen(parts[4]) > 0)
      event.forecast = StringToDouble(parts[4]);
   if(num_parts > 5 && StringLen(parts[5]) > 0)
      event.previous = StringToDouble(parts[5]);
   if(num_parts > 6 && StringLen(parts[6]) > 0)
      event.actual = StringToDouble(parts[6]);
   
   event.is_valid = (event.time_utc > 0 && StringLen(event.event_name) > 0);
   
   return event.is_valid;
}

//+------------------------------------------------------------------+
//| HTTP GET request                                                  |
//+------------------------------------------------------------------+
bool CNewsWindowDetector::HttpGet(string url, string &response)
{
   char data[];
   char result[];
   string headers;
   
   int res = WebRequest("GET", url, "", NULL, m_http_timeout_ms, data, 0, result, headers);
   
   if(res == -1)
   {
      int error = GetLastError();
      if(error == 4014)
         Print("CNewsWindowDetector: Add ", url, " to WebRequest allowed URLs");
      return false;
   }
   
   if(res != 200)
      return false;
   
   response = CharArrayToString(result);
   return true;
}

//+------------------------------------------------------------------+
//| Parse JSON signal response                                        |
//+------------------------------------------------------------------+
bool CNewsWindowDetector::ParseJsonSignal(string json, SNewsWindowResult &result)
{
   result.Reset();
   
   // Parse in_news_window
   int pos = StringFind(json, "\"in_news_window\":");
   if(pos >= 0)
   {
      int val_start = pos + 17;
      result.in_window = (StringFind(json, "true", val_start) == val_start);
   }
   
   // Parse score_adjustment
   pos = StringFind(json, "\"score_adjustment\":");
   if(pos >= 0)
   {
      int val_start = pos + 19;
      int val_end = StringFind(json, ",", val_start);
      if(val_end < 0) val_end = StringFind(json, "}", val_start);
      result.score_adjustment = (int)StringToInteger(StringSubstr(json, val_start, val_end - val_start));
   }
   
   // Parse block_trade
   pos = StringFind(json, "\"block_trade\":");
   if(pos >= 0)
   {
      int val_start = pos + 14;
      if(StringFind(json, "true", val_start) == val_start)
         result.action = NEWS_ACTION_BLOCK;
   }
   
   // Parse action
   pos = StringFind(json, "\"action\":\"");
   if(pos >= 0)
   {
      int val_start = pos + 10;
      int val_end = StringFind(json, "\"", val_start);
      string action_str = StringSubstr(json, val_start, val_end - val_start);
      
      if(action_str == "NORMAL") result.action = NEWS_ACTION_NORMAL;
      else if(action_str == "CAUTION") result.action = NEWS_ACTION_CAUTION;
      else if(action_str == "PREPOSITION") result.action = NEWS_ACTION_PREPOSITION;
      else if(action_str == "STRADDLE") result.action = NEWS_ACTION_STRADDLE;
      else if(action_str == "PULLBACK") result.action = NEWS_ACTION_PULLBACK;
      else if(action_str == "BLOCK") result.action = NEWS_ACTION_BLOCK;
   }
   
   // Parse minutes_to_event
   pos = StringFind(json, "\"minutes_to_event\":");
   if(pos >= 0)
   {
      int val_start = pos + 19;
      int val_end = StringFind(json, ",", val_start);
      if(val_end < 0) val_end = StringFind(json, "}", val_start);
      string val_str = StringSubstr(json, val_start, val_end - val_start);
      if(val_str != "null")
         result.minutes_to_event = (int)StringToInteger(val_str);
   }
   
   // Parse event_name
   pos = StringFind(json, "\"event_name\":\"");
   if(pos >= 0)
   {
      int val_start = pos + 14;
      int val_end = StringFind(json, "\"", val_start);
      result.event.event_name = StringSubstr(json, val_start, val_end - val_start);
      result.event.is_valid = (StringLen(result.event.event_name) > 0);
   }
   
   // Set size multiplier based on action
   switch(result.action)
   {
      case NEWS_ACTION_BLOCK:
         result.size_multiplier = 0.0;
         break;
      case NEWS_ACTION_STRADDLE:
      case NEWS_ACTION_PULLBACK:
         result.size_multiplier = 0.25;
         break;
      case NEWS_ACTION_PREPOSITION:
         result.size_multiplier = 0.5;
         break;
      case NEWS_ACTION_CAUTION:
         result.size_multiplier = 0.75;
         break;
      default:
         result.size_multiplier = 1.0;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Get current time in UTC                                           |
//+------------------------------------------------------------------+
datetime CNewsWindowDetector::GetCurrentTimeUTC()
{
   return TimeGMT();
}

//+------------------------------------------------------------------+
//| Convert broker time to UTC                                        |
//+------------------------------------------------------------------+
datetime CNewsWindowDetector::BrokerTimeToUTC(datetime broker_time)
{
   return broker_time - m_broker_gmt_offset * 3600;
}

//+------------------------------------------------------------------+
//| Convert UTC to broker time                                        |
//+------------------------------------------------------------------+
datetime CNewsWindowDetector::UTCToBrokerTime(datetime utc_time)
{
   return utc_time + m_broker_gmt_offset * 3600;
}

//+------------------------------------------------------------------+
//| Check if cache is still valid                                     |
//+------------------------------------------------------------------+
bool CNewsWindowDetector::IsCacheValid()
{
   if(ArraySize(m_events) == 0)
      return false;
   
   datetime now = GetCurrentTimeUTC();
   int age_minutes = (int)((now - m_last_cache_update) / 60);
   
   return age_minutes < m_cache_ttl_minutes;
}

//+------------------------------------------------------------------+
//| Sort events by time                                               |
//+------------------------------------------------------------------+
void CNewsWindowDetector::SortEventsByTime()
{
   int n = ArraySize(m_events);
   
   for(int i = 0; i < n - 1; i++)
   {
      for(int j = 0; j < n - i - 1; j++)
      {
         if(m_events[j].time_utc > m_events[j + 1].time_utc)
         {
            SEconomicEvent temp = m_events[j];
            m_events[j] = m_events[j + 1];
            m_events[j + 1] = temp;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Convert impact string to enum                                     |
//+------------------------------------------------------------------+
ENUM_NEWS_IMPACT CNewsWindowDetector::StringToImpact(string impact_str)
{
   StringToUpper(impact_str);
   
   if(impact_str == "HIGH" || impact_str == "3")
      return NEWS_IMPACT_HIGH;
   if(impact_str == "MEDIUM" || impact_str == "2")
      return NEWS_IMPACT_MEDIUM;
   if(impact_str == "LOW" || impact_str == "1")
      return NEWS_IMPACT_LOW;
   
   return NEWS_IMPACT_NONE;
}

//+------------------------------------------------------------------+
//| Convert impact enum to string                                     |
//+------------------------------------------------------------------+
string CNewsWindowDetector::ImpactToString(ENUM_NEWS_IMPACT impact)
{
   switch(impact)
   {
      case NEWS_IMPACT_HIGH:   return "HIGH";
      case NEWS_IMPACT_MEDIUM: return "MEDIUM";
      case NEWS_IMPACT_LOW:    return "LOW";
      default:                 return "NONE";
   }
}

//+------------------------------------------------------------------+
//| Convert action enum to string                                     |
//+------------------------------------------------------------------+
string CNewsWindowDetector::ActionToString(ENUM_NEWS_ACTION action)
{
   switch(action)
   {
      case NEWS_ACTION_NORMAL:      return "NORMAL";
      case NEWS_ACTION_CAUTION:     return "CAUTION";
      case NEWS_ACTION_PREPOSITION: return "PREPOSITION";
      case NEWS_ACTION_STRADDLE:    return "STRADDLE";
      case NEWS_ACTION_PULLBACK:    return "PULLBACK";
      case NEWS_ACTION_BLOCK:       return "BLOCK";
      default:                      return "UNKNOWN";
   }
}

//+------------------------------------------------------------------+
//| Print current status                                              |
//+------------------------------------------------------------------+
void CNewsWindowDetector::PrintStatus()
{
   Print("=== CNewsWindowDetector Status ===");
   Print("Initialized: ", m_initialized);
   Print("Cached Events: ", ArraySize(m_events));
   Print("Cache Age (min): ", (int)((GetCurrentTimeUTC() - m_last_cache_update) / 60));
   Print("Using Python Hub: ", m_use_python_hub);
   
   SNewsWindowResult result = CheckNewsWindow();
   Print("In News Window: ", result.in_window);
   Print("Action: ", ActionToString(result.action));
   Print("Score Adjustment: ", result.score_adjustment);
   Print("Size Multiplier: ", result.size_multiplier);
   
   if(result.event.is_valid)
   {
      Print("Next Event: ", result.event.event_name);
      Print("Minutes to Event: ", result.minutes_to_event);
   }
   
   Print("================================");
}

//+------------------------------------------------------------------+
