//+------------------------------------------------------------------+
//|                                                   CCOTBridge.mqh |
//|                                                           Franco |
//|                     EA_SCALPER_XAUUSD - COT Data Integration     |
//|                                                                  |
//| v1.0 - Stub for future COT (Commitment of Traders) integration  |
//|                                                                  |
//| COT data is released weekly by CFTC and provides:               |
//| - Commercial hedger positions (smart money)                     |
//| - Large speculator positions (trend followers)                  |
//| - Small speculator positions (retail)                           |
//|                                                                  |
//| For GOLD (GC futures):                                          |
//| - Commercials LONG = Producers hedging = bearish bias           |
//| - Commercials SHORT = Consumers hedging = bullish bias          |
//| - Net positioning changes indicate sentiment shifts             |
//+------------------------------------------------------------------+
#property copyright "Franco"
#property link      "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| COT Report Types                                                 |
//+------------------------------------------------------------------+
enum ENUM_COT_REPORT_TYPE
{
   COT_LEGACY,           // Legacy report (basic breakdown)
   COT_DISAGGREGATED,    // Disaggregated (producer/swap/managed/other)
   COT_TFF               // Traders in Financial Futures
};

//+------------------------------------------------------------------+
//| COT Participant Types                                            |
//+------------------------------------------------------------------+
enum ENUM_COT_PARTICIPANT
{
   COT_COMMERCIAL,       // Commercial hedgers (producers/consumers)
   COT_LARGE_SPEC,       // Large speculators (managed money)
   COT_SMALL_SPEC,       // Small speculators (retail)
   COT_SWAP_DEALERS,     // Swap dealers (disaggregated)
   COT_MANAGED_MONEY,    // Managed money (disaggregated)
   COT_OTHER_REPORTABLE  // Other reportables
};

//+------------------------------------------------------------------+
//| COT Position Data Structure                                      |
//+------------------------------------------------------------------+
struct SCOTPosition
{
   long     long_contracts;      // Number of long contracts
   long     short_contracts;     // Number of short contracts
   long     spreading;           // Spreading positions
   long     net_position;        // Net position (long - short)
   double   net_change;          // Change from previous week
   double   percent_of_oi;       // Percentage of open interest

   void Reset()
   {
      long_contracts = 0;
      short_contracts = 0;
      spreading = 0;
      net_position = 0;
      net_change = 0;
      percent_of_oi = 0;
   }

   void Calculate()
   {
      net_position = long_contracts - short_contracts;
   }
};

//+------------------------------------------------------------------+
//| COT Report Data Structure                                        |
//+------------------------------------------------------------------+
struct SCOTReport
{
   // Report metadata
   datetime report_date;         // Report date (usually Tuesday)
   datetime as_of_date;          // As-of date (usually Friday close)
   string   contract_name;       // Contract name (e.g., "GOLD - COMEX")
   string   cftc_code;           // CFTC contract code (088691 for Gold)

   // Open Interest
   long     open_interest;       // Total open interest
   long     oi_change;           // Change from previous week

   // Positions by participant type
   SCOTPosition commercial;      // Commercial hedgers
   SCOTPosition large_spec;      // Large speculators
   SCOTPosition small_spec;      // Small speculators (non-reportable)

   // Disaggregated (if available)
   SCOTPosition swap_dealers;    // Swap dealers
   SCOTPosition managed_money;   // Managed money
   SCOTPosition other_reportable;// Other reportables

   // Derived metrics
   double   commercial_net_pct;  // Commercial net as % of OI
   double   spec_net_pct;        // Speculator net as % of OI
   int      weeks_bullish;       // Weeks of bullish positioning
   int      weeks_bearish;       // Weeks of bearish positioning

   // Validity
   bool     is_valid;
   string   error;

   void Reset()
   {
      report_date = 0;
      as_of_date = 0;
      contract_name = "";
      cftc_code = "";
      open_interest = 0;
      oi_change = 0;

      commercial.Reset();
      large_spec.Reset();
      small_spec.Reset();
      swap_dealers.Reset();
      managed_money.Reset();
      other_reportable.Reset();

      commercial_net_pct = 0;
      spec_net_pct = 0;
      weeks_bullish = 0;
      weeks_bearish = 0;

      is_valid = false;
      error = "";
   }
};

//+------------------------------------------------------------------+
//| COT Signal for Trading                                           |
//+------------------------------------------------------------------+
struct SCOTSignal
{
   // Primary signal
   string   bias;                // BULLISH, BEARISH, NEUTRAL
   int      score_adjustment;    // Score adjustment (-15 to +15)
   double   confidence;          // 0.0 to 1.0

   // Detailed metrics
   double   commercial_bias;     // Commercial hedger positioning bias
   double   smart_money_bias;    // Combined commercial + swap dealer bias
   double   momentum;            // Week-over-week change in net positioning

   // Extreme readings (historical percentiles)
   bool     commercial_extreme_long;   // Commercial net at historical high
   bool     commercial_extreme_short;  // Commercial net at historical low
   bool     spec_extreme_long;         // Speculators at extreme long
   bool     spec_extreme_short;        // Speculators at extreme short

   // Validity
   datetime last_update;
   bool     is_valid;

   void Reset()
   {
      bias = "NEUTRAL";
      score_adjustment = 0;
      confidence = 0;
      commercial_bias = 0;
      smart_money_bias = 0;
      momentum = 0;
      commercial_extreme_long = false;
      commercial_extreme_short = false;
      spec_extreme_long = false;
      spec_extreme_short = false;
      last_update = 0;
      is_valid = false;
   }
};

//+------------------------------------------------------------------+
//| Class: CCOTBridge                                                |
//| Purpose: HTTP Bridge to Python Hub for COT Data                  |
//|                                                                  |
//| STUB: This is a placeholder for future implementation           |
//| Integration path: Python Hub -> CFTC API -> Parse -> MQL5       |
//+------------------------------------------------------------------+
class CCOTBridge
{
private:
   string            m_base_url;
   int               m_timeout_ms;
   bool              m_is_connected;
   datetime          m_last_update;
   int               m_update_interval;   // Seconds (COT = weekly, but check daily)

   SCOTReport        m_cached_report;
   SCOTSignal        m_cached_signal;

   // Request counter for diagnostics
   ulong             m_request_count;
   ulong             m_error_count;

   // Historical data for percentile calculations
   double            m_hist_commercial_net[];  // Historical commercial net positions
   int               m_hist_count;
   int               m_hist_max;              // Max history to keep (52 weeks default)

public:
                     CCOTBridge();
                    ~CCOTBridge();

   // Initialization
   bool              Init(string base_url = "http://127.0.0.1:8000", int update_interval = 86400);

   // Main Methods
   bool              GetReport(SCOTReport& report);
   bool              GetSignal(SCOTSignal& signal);
   bool              UpdateData();

   // Signal Calculation
   SCOTSignal        CalculateSignal(const SCOTReport& report);
   int               GetScoreAdjustment();

   // Utility
   bool              IsConnected() const { return m_is_connected; }
   bool              NeedsUpdate() const;
   void              OnTimer();
   string            GetLastError() const { return m_cached_report.error; }

   // Stats
   ulong             GetRequestCount() const { return m_request_count; }
   ulong             GetErrorCount() const { return m_error_count; }

   // Percentile calculation
   double            GetHistoricalPercentile(double value);
   bool              IsExtremeReading(double value, double threshold = 90.0);

private:
   bool              SendRequest(string endpoint, string& response);
   bool              ParseReportResponse(string json, SCOTReport& report);
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CCOTBridge::CCOTBridge() :
   m_base_url("http://127.0.0.1:8000"),
   m_timeout_ms(10000),
   m_is_connected(false),
   m_last_update(0),
   m_update_interval(86400),  // Check daily (COT releases weekly)
   m_request_count(0),
   m_error_count(0),
   m_hist_count(0),
   m_hist_max(52)            // 52 weeks = 1 year history
{
   m_cached_report.Reset();
   m_cached_signal.Reset();
   ArrayResize(m_hist_commercial_net, m_hist_max);
   ArrayInitialize(m_hist_commercial_net, 0);
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CCOTBridge::~CCOTBridge()
{
}

//+------------------------------------------------------------------+
//| Initialization                                                    |
//+------------------------------------------------------------------+
bool CCOTBridge::Init(string base_url = "http://127.0.0.1:8000", int update_interval = 86400)
{
   m_base_url = base_url;
   m_update_interval = update_interval;

   // STUB: In production, test connection to COT endpoint
   // string response;
   // if(!SendRequest("/api/v1/cot/health", response))
   // {
   //    Print("CCOTBridge: Cannot connect to COT endpoint at ", m_base_url);
   //    m_is_connected = false;
   //    return false;
   // }

   Print("CCOTBridge: STUB initialized (not connected to data source)");
   m_is_connected = false;  // STUB: Set to true when implemented

   return true;
}

//+------------------------------------------------------------------+
//| Check if update is needed                                         |
//+------------------------------------------------------------------+
bool CCOTBridge::NeedsUpdate() const
{
   if(!m_cached_report.is_valid)
      return true;

   return (TimeCurrent() - m_last_update) >= m_update_interval;
}

//+------------------------------------------------------------------+
//| Get cached or updated report                                      |
//+------------------------------------------------------------------+
bool CCOTBridge::GetReport(SCOTReport& report)
{
   // STUB: Return empty report until implemented
   report = m_cached_report;
   return m_cached_report.is_valid;
}

//+------------------------------------------------------------------+
//| Get trading signal from COT data                                  |
//+------------------------------------------------------------------+
bool CCOTBridge::GetSignal(SCOTSignal& signal)
{
   // STUB: Return neutral signal until implemented
   signal = m_cached_signal;
   return m_cached_signal.is_valid;
}

//+------------------------------------------------------------------+
//| Update data from Python Hub                                       |
//+------------------------------------------------------------------+
bool CCOTBridge::UpdateData()
{
   // STUB: Implement HTTP request to Python Hub
   m_request_count++;

   // TODO: Implement actual HTTP request and parsing
   // string response;
   // if(!SendRequest("/api/v1/cot/gold", response))
   // {
   //    m_error_count++;
   //    m_cached_report.error = "HTTP request failed";
   //    return false;
   // }
   //
   // SCOTReport new_report;
   // if(!ParseReportResponse(response, new_report))
   // {
   //    m_error_count++;
   //    m_cached_report.error = "Parse failed";
   //    return false;
   // }
   //
   // m_cached_report = new_report;
   // m_cached_signal = CalculateSignal(new_report);
   // m_last_update = TimeCurrent();

   return false;  // STUB: Not implemented
}

//+------------------------------------------------------------------+
//| Calculate trading signal from COT report                          |
//+------------------------------------------------------------------+
SCOTSignal CCOTBridge::CalculateSignal(const SCOTReport& report)
{
   SCOTSignal signal;
   signal.Reset();

   if(!report.is_valid)
      return signal;

   // === COMMERCIAL POSITIONING ===
   // Commercials are typically CORRECT at extremes
   // When commercials are extremely net short = gold bullish (they're hedging future production)
   // When commercials are extremely net long = gold bearish (they're hedging future purchases)

   double commercial_pct = GetHistoricalPercentile((double)report.commercial.net_position);

   // Extreme readings (>90th or <10th percentile)
   signal.commercial_extreme_short = (commercial_pct < 10.0);
   signal.commercial_extreme_long = (commercial_pct > 90.0);

   // === SPECULATOR POSITIONING ===
   // Speculators are typically WRONG at extremes (contrarian indicator)
   // When speculators extremely long = potential top (bearish)
   // When speculators extremely short = potential bottom (bullish)

   double spec_pct = GetHistoricalPercentile((double)report.large_spec.net_position);

   signal.spec_extreme_long = (spec_pct > 90.0);
   signal.spec_extreme_short = (spec_pct < 10.0);

   // === SCORE ADJUSTMENT ===
   // Formula: Based on commercial positioning and speculator extremes
   // Range: -15 to +15

   // Commercial bias (-1 to +1)
   // Negative commercial net (short hedges) = bullish for gold
   signal.commercial_bias = -report.commercial_net_pct / 100.0;

   // Calculate adjustment
   // Example: commercial_net_pct = -20% -> bias = +0.2 -> adjustment = +3
   // Example: commercial_net_pct = +30% -> bias = -0.3 -> adjustment = -4.5
   double raw_adjustment = signal.commercial_bias * 15.0;

   // Boost for extreme readings
   if(signal.commercial_extreme_short)
      raw_adjustment += 5.0;  // Additional bullish boost
   if(signal.commercial_extreme_long)
      raw_adjustment -= 5.0;  // Additional bearish boost

   // Contrarian speculator signal
   if(signal.spec_extreme_long)
      raw_adjustment -= 3.0;  // Specs too bullish = bearish signal
   if(signal.spec_extreme_short)
      raw_adjustment += 3.0;  // Specs too bearish = bullish signal

   // Clamp to range
   signal.score_adjustment = (int)MathRound(MathMax(-15, MathMin(15, raw_adjustment)));

   // Set bias
   if(signal.score_adjustment > 5)
      signal.bias = "BULLISH";
   else if(signal.score_adjustment < -5)
      signal.bias = "BEARISH";
   else
      signal.bias = "NEUTRAL";

   // Confidence based on extreme readings
   signal.confidence = 0.5;  // Base confidence
   if(signal.commercial_extreme_long || signal.commercial_extreme_short)
      signal.confidence += 0.25;
   if(signal.spec_extreme_long || signal.spec_extreme_short)
      signal.confidence += 0.15;

   signal.confidence = MathMin(1.0, signal.confidence);

   signal.last_update = TimeCurrent();
   signal.is_valid = true;

   return signal;
}

//+------------------------------------------------------------------+
//| Get score adjustment (convenience method)                         |
//+------------------------------------------------------------------+
int CCOTBridge::GetScoreAdjustment()
{
   if(!m_cached_signal.is_valid)
      return 0;
   return m_cached_signal.score_adjustment;
}

//+------------------------------------------------------------------+
//| OnTimer - call periodically to update                             |
//+------------------------------------------------------------------+
void CCOTBridge::OnTimer()
{
   if(NeedsUpdate())
   {
      UpdateData();
   }
}

//+------------------------------------------------------------------+
//| Get historical percentile for a value                             |
//+------------------------------------------------------------------+
double CCOTBridge::GetHistoricalPercentile(double value)
{
   if(m_hist_count < 4)
      return 50.0;  // Not enough history

   int count_below = 0;
   for(int i = 0; i < m_hist_count; i++)
   {
      if(m_hist_commercial_net[i] < value)
         count_below++;
   }

   return (double)count_below / m_hist_count * 100.0;
}

//+------------------------------------------------------------------+
//| Check if value is at extreme reading                              |
//+------------------------------------------------------------------+
bool CCOTBridge::IsExtremeReading(double value, double threshold = 90.0)
{
   double pct = GetHistoricalPercentile(value);
   return (pct > threshold || pct < (100.0 - threshold));
}

//+------------------------------------------------------------------+
//| Send HTTP Request (STUB)                                          |
//+------------------------------------------------------------------+
bool CCOTBridge::SendRequest(string endpoint, string& response)
{
   // STUB: Implement WebRequest when Python Hub COT endpoint is ready
   return false;
}

//+------------------------------------------------------------------+
//| Parse Report Response JSON (STUB)                                 |
//+------------------------------------------------------------------+
bool CCOTBridge::ParseReportResponse(string json, SCOTReport& report)
{
   // STUB: Implement JSON parsing when Python Hub COT endpoint is ready
   return false;
}

//+------------------------------------------------------------------+
