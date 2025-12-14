//+------------------------------------------------------------------+
//|                                               CSessionFilter.mqh |
//|                           EA_SCALPER_XAUUSD - Singularity Edition |
//|                                                                  |
//|  SESSION DYNAMICS FOR XAUUSD                                     |
//|                                                                  |
//|  XAUUSD has very distinct behavior by session:                   |
//|                                                                  |
//|  ASIAN (00:00-07:00 GMT):                                        |
//|  - LOW volatility, range-bound                                   |
//|  - Accumulation phase typically occurs here                      |
//|  - DO NOT TRADE - use for analysis only                          |
//|                                                                  |
//|  LONDON (07:00-12:00 GMT):                                       |
//|  - HIGH volatility, trend initiation                             |
//|  - Manipulation + Distribution phases often start here           |
//|  - BEST TRADING WINDOW - primary session                         |
//|  - "London Judas Swing" often fakes Asian levels                 |
//|                                                                  |
//|  NY (12:00-17:00 GMT):                                           |
//|  - HIGH volatility, especially overlap (12:00-15:00)             |
//|  - Continuation of London move OR reversal                       |
//|  - GOOD TRADING WINDOW - secondary session                       |
//|                                                                  |
//|  LATE SESSION (17:00-00:00 GMT):                                 |
//|  - LOW liquidity, erratic moves                                  |
//|  - Avoid new positions                                           |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD - Singularity Edition"
#property strict

//+------------------------------------------------------------------+
//| Session Type Enumeration                                          |
//+------------------------------------------------------------------+
enum ENUM_TRADING_SESSION
{
   SESSION_UNKNOWN = 0,
   SESSION_ASIAN,               // 00:00-07:00 GMT
   SESSION_LONDON,              // 07:00-12:00 GMT
   SESSION_LONDON_NY_OVERLAP,   // 12:00-15:00 GMT (BEST)
   SESSION_NY,                  // 15:00-17:00 GMT
   SESSION_LATE_NY,             // 17:00-21:00 GMT
   SESSION_WEEKEND              // Saturday-Sunday
};

//+------------------------------------------------------------------+
//| Session Quality for Trading                                       |
//+------------------------------------------------------------------+
enum ENUM_SESSION_QUALITY
{
   SESSION_QUALITY_BLOCKED = 0,   // Do not trade
   SESSION_QUALITY_LOW,           // Reduced size only
   SESSION_QUALITY_MEDIUM,        // Normal trading
   SESSION_QUALITY_HIGH,          // Optimal window
   SESSION_QUALITY_PRIME          // Best of the best
};

//+------------------------------------------------------------------+
//| Day of Week Quality                                               |
//+------------------------------------------------------------------+
enum ENUM_DAY_QUALITY
{
   DAY_QUALITY_BLOCKED = 0,     // Weekend
   DAY_QUALITY_LOW,             // Monday, Friday afternoon
   DAY_QUALITY_MEDIUM,          // Thursday
   DAY_QUALITY_HIGH             // Tuesday, Wednesday
};

//+------------------------------------------------------------------+
//| Session Time Window Structure                                     |
//+------------------------------------------------------------------+
struct SSessionWindow
{
   int               start_hour;
   int               start_minute;
   int               end_hour;
   int               end_minute;
   ENUM_SESSION_QUALITY quality;
   string            name;
};

//+------------------------------------------------------------------+
//| Session Filter Class                                              |
//+------------------------------------------------------------------+
class CSessionFilter
{
private:
   // Session windows (GMT)
   SSessionWindow    m_asian;
   SSessionWindow    m_london;
   SSessionWindow    m_overlap;
   SSessionWindow    m_ny;
   SSessionWindow    m_late;
   
   // Broker GMT offset
   int               m_gmt_offset;        // Hours difference from GMT
   
   // Configuration
   bool              m_allow_asian;       // Override to allow Asian
   bool              m_allow_late_ny;     // Override to allow late NY
   bool              m_friday_close_early;// Close positions Friday afternoon
   int               m_friday_close_hour; // Hour to close on Friday (GMT)
   
   // State
   ENUM_TRADING_SESSION m_current_session;
   ENUM_SESSION_QUALITY m_current_quality;
   ENUM_DAY_QUALITY  m_day_quality;
   
   // Internal methods
   int               GetGMTHour();
   int               GetGMTMinute();
   bool              IsInWindow(SSessionWindow &window, int gmt_hour, int gmt_minute);
   void              UpdateCurrentSession();
   ENUM_DAY_QUALITY  GetDayQuality(int day_of_week);
   
public:
   CSessionFilter();
   ~CSessionFilter() {}
   
   // Initialization
   bool              Initialize(int gmt_offset = 0);
   void              SetGMTOffset(int offset) { m_gmt_offset = offset; }
   
   // Main check - call before any trade decision
   bool              IsTradingAllowed();
   
   // Detailed checks
   ENUM_TRADING_SESSION GetCurrentSession();
   ENUM_SESSION_QUALITY GetSessionQuality();
   ENUM_DAY_QUALITY  GetDayQuality() { return m_day_quality; }
   
   // Time-based utilities
   bool              IsLondonSession();
   bool              IsNYSession();
   bool              IsOverlapSession();
   bool              IsAsianSession();
   bool              IsWeekend();
   bool              IsFridayAfternoon();
   
   // Optimal windows
   bool              IsOptimalWindow();      // Best time to trade
   bool              IsAcceptableWindow();   // Okay to trade
   
   // Minutes until next session
   int               MinutesToLondonOpen();
   int               MinutesToNYOpen();
   int               MinutesToOverlap();
   
   // Configuration
   void              AllowAsianTrading(bool allow) { m_allow_asian = allow; }
   void              AllowLateNYTrading(bool allow) { m_allow_late_ny = allow; }
   void              SetFridayCloseHour(int hour) { m_friday_close_hour = hour; }
   void              SetFridayCloseEarly(bool enable) { m_friday_close_early = enable; }
   
   // Score contribution
   int               GetSessionScore();      // 0-100 score for confluence
   
   // Info
   string            GetSessionName();
   string            GetSessionInfo();
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CSessionFilter::CSessionFilter()
{
   // Default GMT offset (most brokers use GMT+2 or GMT+3)
   m_gmt_offset = 0;
   
   // Asian Session: 00:00-07:00 GMT
   m_asian.start_hour = 0;
   m_asian.start_minute = 0;
   m_asian.end_hour = 7;
   m_asian.end_minute = 0;
   m_asian.quality = SESSION_QUALITY_BLOCKED;
   m_asian.name = "Asian";
   
   // London Session: 07:00-16:00 GMT (spec)
   m_london.start_hour = 7;
   m_london.start_minute = 0;
   m_london.end_hour = 16;
   m_london.end_minute = 0;
   m_london.quality = SESSION_QUALITY_HIGH;
   m_london.name = "London";
   
   // London/NY Overlap: 12:00-16:00 GMT
   m_overlap.start_hour = 12;
   m_overlap.start_minute = 0;
   m_overlap.end_hour = 16;
   m_overlap.end_minute = 0;
   m_overlap.quality = SESSION_QUALITY_PRIME;
   m_overlap.name = "London/NY Overlap";
   
   // NY Session: 16:00-21:00 GMT (post-overlap continuation)
   m_ny.start_hour = 16;
   m_ny.start_minute = 0;
   m_ny.end_hour = 21;
   m_ny.end_minute = 0;
   m_ny.quality = SESSION_QUALITY_MEDIUM;
   m_ny.name = "New York";
   
   // Late NY: 21:00-00:00 GMT
   m_late.start_hour = 21;
   m_late.start_minute = 0;
   m_late.end_hour = 0;   // crosses midnight
   m_late.end_minute = 0;
   m_late.quality = SESSION_QUALITY_LOW;
   m_late.name = "Late NY";
   
   // Configuration defaults
   m_allow_asian = false;
   m_allow_late_ny = false;
   m_friday_close_early = true;
   m_friday_close_hour = 14; // Close Friday positions by 14:00 GMT
   
   m_current_session = SESSION_UNKNOWN;
   m_current_quality = SESSION_QUALITY_BLOCKED;
   m_day_quality = DAY_QUALITY_MEDIUM;
}

//+------------------------------------------------------------------+
//| Initialize                                                        |
//+------------------------------------------------------------------+
bool CSessionFilter::Initialize(int gmt_offset)
{
   m_gmt_offset = gmt_offset;
   
   // Detect broker GMT offset automatically if possible
   // Most brokers show server time which is GMT+2 or GMT+3
   // For now, use provided offset
   
   UpdateCurrentSession();
   
   Print("CSessionFilter: Initialized with GMT offset ", m_gmt_offset);
   Print("CSessionFilter: Current session - ", GetSessionName());
   
   return true;
}

//+------------------------------------------------------------------+
//| Get current hour in GMT                                           |
//+------------------------------------------------------------------+
int CSessionFilter::GetGMTHour()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   int gmt_hour = dt.hour - m_gmt_offset;
   if(gmt_hour < 0) gmt_hour += 24;
   if(gmt_hour >= 24) gmt_hour -= 24;
   
   return gmt_hour;
}

//+------------------------------------------------------------------+
//| Get current minute                                                |
//+------------------------------------------------------------------+
int CSessionFilter::GetGMTMinute()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   return dt.min;
}

//+------------------------------------------------------------------+
//| Check if current time is in a window                              |
//+------------------------------------------------------------------+
bool CSessionFilter::IsInWindow(SSessionWindow &window, int gmt_hour, int gmt_minute)
{
   int current_minutes = gmt_hour * 60 + gmt_minute;
   int start_minutes = window.start_hour * 60 + window.start_minute;
   int end_minutes = window.end_hour * 60 + window.end_minute;
   
   // Handle overnight windows (e.g., 22:00 to 06:00)
   if(start_minutes > end_minutes)
   {
      return (current_minutes >= start_minutes || current_minutes < end_minutes);
   }
   
   return (current_minutes >= start_minutes && current_minutes < end_minutes);
}

//+------------------------------------------------------------------+
//| Update current session state                                      |
//+------------------------------------------------------------------+
void CSessionFilter::UpdateCurrentSession()
{
   int gmt_hour = GetGMTHour();
   int gmt_minute = GetGMTMinute();
   
   // Check day of week
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   if(dt.day_of_week == 0 || dt.day_of_week == 6)
   {
      m_current_session = SESSION_WEEKEND;
      m_current_quality = SESSION_QUALITY_BLOCKED;
      m_day_quality = DAY_QUALITY_BLOCKED;
      return;
   }
   
   m_day_quality = GetDayQuality(dt.day_of_week);
   
   // Check sessions in priority order
   if(IsInWindow(m_overlap, gmt_hour, gmt_minute))
   {
      m_current_session = SESSION_LONDON_NY_OVERLAP;
      m_current_quality = m_overlap.quality;
   }
   else if(IsInWindow(m_london, gmt_hour, gmt_minute))
   {
      m_current_session = SESSION_LONDON;
      m_current_quality = m_london.quality;
   }
   else if(IsInWindow(m_ny, gmt_hour, gmt_minute))
   {
      m_current_session = SESSION_NY;
      m_current_quality = m_ny.quality;
   }
   else if(IsInWindow(m_late, gmt_hour, gmt_minute))
   {
      m_current_session = SESSION_LATE_NY;
      m_current_quality = m_allow_late_ny ? SESSION_QUALITY_LOW : SESSION_QUALITY_BLOCKED;
   }
   else if(IsInWindow(m_asian, gmt_hour, gmt_minute))
   {
      m_current_session = SESSION_ASIAN;
      m_current_quality = m_allow_asian ? SESSION_QUALITY_LOW : SESSION_QUALITY_BLOCKED;
   }
   else
   {
      // Between sessions (21:00-00:00)
      m_current_session = SESSION_UNKNOWN;
      m_current_quality = SESSION_QUALITY_BLOCKED;
   }
   
   // Friday afternoon override
   if(dt.day_of_week == 5 && gmt_hour >= m_friday_close_hour && m_friday_close_early)
   {
      m_current_quality = SESSION_QUALITY_BLOCKED;
   }
}

//+------------------------------------------------------------------+
//| Get day quality based on day of week                              |
//+------------------------------------------------------------------+
ENUM_DAY_QUALITY CSessionFilter::GetDayQuality(int day_of_week)
{
   switch(day_of_week)
   {
      case 0: return DAY_QUALITY_BLOCKED;   // Sunday
      case 1: return DAY_QUALITY_LOW;       // Monday (market finding direction)
      case 2: return DAY_QUALITY_HIGH;      // Tuesday (best day typically)
      case 3: return DAY_QUALITY_HIGH;      // Wednesday (continuation)
      case 4: return DAY_QUALITY_MEDIUM;    // Thursday (often retracement)
      case 5: return DAY_QUALITY_LOW;       // Friday (weekend positioning)
      case 6: return DAY_QUALITY_BLOCKED;   // Saturday
   }
   return DAY_QUALITY_MEDIUM;
}

//+------------------------------------------------------------------+
//| Main check - Is trading allowed right now?                        |
//+------------------------------------------------------------------+
bool CSessionFilter::IsTradingAllowed()
{
   UpdateCurrentSession();
   
   // Never trade on weekends
   if(m_current_session == SESSION_WEEKEND)
      return false;
   
   // Check session quality
   if(m_current_quality == SESSION_QUALITY_BLOCKED)
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Get current session                                               |
//+------------------------------------------------------------------+
ENUM_TRADING_SESSION CSessionFilter::GetCurrentSession()
{
   UpdateCurrentSession();
   return m_current_session;
}

//+------------------------------------------------------------------+
//| Get session quality                                               |
//+------------------------------------------------------------------+
ENUM_SESSION_QUALITY CSessionFilter::GetSessionQuality()
{
   UpdateCurrentSession();
   return m_current_quality;
}

//+------------------------------------------------------------------+
//| Quick checks                                                      |
//+------------------------------------------------------------------+
bool CSessionFilter::IsLondonSession()
{
   return (GetCurrentSession() == SESSION_LONDON || 
           GetCurrentSession() == SESSION_LONDON_NY_OVERLAP);
}

bool CSessionFilter::IsNYSession()
{
   return (GetCurrentSession() == SESSION_NY || 
           GetCurrentSession() == SESSION_LONDON_NY_OVERLAP);
}

bool CSessionFilter::IsOverlapSession()
{
   return (GetCurrentSession() == SESSION_LONDON_NY_OVERLAP);
}

bool CSessionFilter::IsAsianSession()
{
   return (GetCurrentSession() == SESSION_ASIAN);
}

bool CSessionFilter::IsWeekend()
{
   return (GetCurrentSession() == SESSION_WEEKEND);
}

bool CSessionFilter::IsFridayAfternoon()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   int gmt_hour = GetGMTHour();
   
   return (dt.day_of_week == 5 && gmt_hour >= m_friday_close_hour);
}

//+------------------------------------------------------------------+
//| Optimal window check                                              |
//+------------------------------------------------------------------+
bool CSessionFilter::IsOptimalWindow()
{
   UpdateCurrentSession();
   return (m_current_quality == SESSION_QUALITY_PRIME || 
           m_current_quality == SESSION_QUALITY_HIGH);
}

bool CSessionFilter::IsAcceptableWindow()
{
   UpdateCurrentSession();
   return (m_current_quality >= SESSION_QUALITY_MEDIUM);
}

//+------------------------------------------------------------------+
//| Minutes to session opens                                          |
//+------------------------------------------------------------------+
int CSessionFilter::MinutesToLondonOpen()
{
   int gmt_hour = GetGMTHour();
   int gmt_minute = GetGMTMinute();
   
   int current_minutes = gmt_hour * 60 + gmt_minute;
   int london_start = m_london.start_hour * 60 + m_london.start_minute;
   
   if(current_minutes < london_start)
      return london_start - current_minutes;
   else
      return (24 * 60 - current_minutes) + london_start;
}

int CSessionFilter::MinutesToNYOpen()
{
   int gmt_hour = GetGMTHour();
   int gmt_minute = GetGMTMinute();
   
   int current_minutes = gmt_hour * 60 + gmt_minute;
   int ny_start = m_overlap.start_hour * 60; // NY opens with overlap
   
   if(current_minutes < ny_start)
      return ny_start - current_minutes;
   else
      return (24 * 60 - current_minutes) + ny_start;
}

int CSessionFilter::MinutesToOverlap()
{
   int gmt_hour = GetGMTHour();
   int gmt_minute = GetGMTMinute();
   
   int current_minutes = gmt_hour * 60 + gmt_minute;
   int overlap_start = m_overlap.start_hour * 60 + m_overlap.start_minute;
   
   if(current_minutes < overlap_start)
      return overlap_start - current_minutes;
   else
      return (24 * 60 - current_minutes) + overlap_start;
}

//+------------------------------------------------------------------+
//| Get session score for confluence (0-100)                          |
//+------------------------------------------------------------------+
int CSessionFilter::GetSessionScore()
{
   UpdateCurrentSession();
   
   int session_score = 0;
   int day_score = 0;
   
   // Session component (max 70)
   switch(m_current_quality)
   {
      case SESSION_QUALITY_PRIME:   session_score = 70; break;
      case SESSION_QUALITY_HIGH:    session_score = 55; break;
      case SESSION_QUALITY_MEDIUM:  session_score = 40; break;
      case SESSION_QUALITY_LOW:     session_score = 20; break;
      default:                      session_score = 0; break;
   }
   
   // Day component (max 30)
   switch(m_day_quality)
   {
      case DAY_QUALITY_HIGH:   day_score = 30; break;
      case DAY_QUALITY_MEDIUM: day_score = 20; break;
      case DAY_QUALITY_LOW:    day_score = 10; break;
      default:                 day_score = 0; break;
   }
   
   // First 2 hours of session bonus
   int gmt_hour = GetGMTHour();
   if(m_current_session == SESSION_LONDON && gmt_hour < 9)
      session_score += 10; // Extra points for London open
   
   return MathMin(100, session_score + day_score);
}

//+------------------------------------------------------------------+
//| Get session name                                                  |
//+------------------------------------------------------------------+
string CSessionFilter::GetSessionName()
{
   switch(m_current_session)
   {
      case SESSION_ASIAN:              return "Asian";
      case SESSION_LONDON:             return "London";
      case SESSION_LONDON_NY_OVERLAP:  return "London/NY Overlap";
      case SESSION_NY:                 return "New York";
      case SESSION_LATE_NY:            return "Late NY";
      case SESSION_WEEKEND:            return "Weekend";
      default:                         return "Unknown";
   }
}

//+------------------------------------------------------------------+
//| Get detailed session info                                         |
//+------------------------------------------------------------------+
string CSessionFilter::GetSessionInfo()
{
   UpdateCurrentSession();
   
   string info = "Session: " + GetSessionName();
   info += " | Quality: ";
   
   switch(m_current_quality)
   {
      case SESSION_QUALITY_PRIME:   info += "PRIME"; break;
      case SESSION_QUALITY_HIGH:    info += "HIGH"; break;
      case SESSION_QUALITY_MEDIUM:  info += "MEDIUM"; break;
      case SESSION_QUALITY_LOW:     info += "LOW"; break;
      case SESSION_QUALITY_BLOCKED: info += "BLOCKED"; break;
   }
   
   info += " | GMT Hour: " + IntegerToString(GetGMTHour());
   info += " | Score: " + IntegerToString(GetSessionScore());
   
   return info;
}
