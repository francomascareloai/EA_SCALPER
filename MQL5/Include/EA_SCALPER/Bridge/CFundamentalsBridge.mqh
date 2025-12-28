//+------------------------------------------------------------------+
//|                                         CFundamentalsBridge.mqh |
//|                                                           Franco |
//|                     EA_SCALPER_XAUUSD - Fundamentals Integration |
//+------------------------------------------------------------------+
#property copyright "Franco"
#property link      "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property strict

// Note: Uses native MQL5 WebRequest() - no external dependencies
// Ensure Python Hub URL is added to Tools -> Options -> Expert Advisors -> Allow WebRequest

//+------------------------------------------------------------------+
//| Estrutura para sinal de fundamentals                              |
//+------------------------------------------------------------------+
struct SFundamentalsSignal
{
   string         signal;           // STRONG_BUY, BUY, NEUTRAL, SELL, STRONG_SELL
   double         score;            // -10 to +10
   int            score_adjustment; // Points to add to technical score
   double         size_multiplier;  // 0.5 to 1.0
   double         confidence;       // 0.0 to 1.0
   string         bias;             // BULLISH, NEUTRAL, BEARISH
   
   // Components
   double         macro_score;
   double         oil_score;
   double         etf_score;
   double         sentiment_score;
   
   datetime       timestamp;
   bool           is_valid;
   string         error;
   
   void           Reset()
   {
      signal = "NEUTRAL";
      score = 0;
      score_adjustment = 0;
      size_multiplier = 0.5;
      confidence = 0.0;
      bias = "NEUTRAL";
      macro_score = 0;
      oil_score = 0;
      etf_score = 0;
      sentiment_score = 0;
      timestamp = 0;
      is_valid = false;
      error = "";
   }
};

//+------------------------------------------------------------------+
//| Class: CFundamentalsBridge                                        |
//| Purpose: HTTP Bridge to Python Agent Hub - Fundamentals Endpoints |
//+------------------------------------------------------------------+
class CFundamentalsBridge
{
private:
   string            m_base_url;
   int               m_timeout_ms;
   bool              m_is_connected;
   datetime          m_last_update;
   int               m_update_interval;  // Seconds between updates
   
   SFundamentalsSignal m_cached_signal;  // Cached signal
   
   // Request counter for diagnostics
   ulong             m_request_count;
   ulong             m_error_count;

public:
                     CFundamentalsBridge();
                    ~CFundamentalsBridge();

   // Initialization
   bool              Init(string base_url = "http://127.0.0.1:8000", int update_interval = 300);
   
   // Main Methods
   bool              GetSignal(SFundamentalsSignal& signal);
   bool              UpdateSignal();
   
   // Individual Components (if needed)
   double            GetMacroScore();
   double            GetOilScore();
   double            GetSentimentScore();
   
   // Utility
   bool              IsConnected() const { return m_is_connected; }
   bool              NeedsUpdate() const;
   void              OnTimer();
   string            GetLastError() const { return m_cached_signal.error; }
   
   // Stats
   ulong             GetRequestCount() const { return m_request_count; }
   ulong             GetErrorCount() const { return m_error_count; }

private:
   bool              SendRequest(string endpoint, string& response);
   bool              ParseSignalResponse(string json, SFundamentalsSignal& signal);
   double            ParseDouble(string json, string key);
   int               ParseInt(string json, string key);
   string            ParseString(string json, string key);
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CFundamentalsBridge::CFundamentalsBridge() :
   m_base_url("http://127.0.0.1:8000"),
   m_timeout_ms(5000),
   m_is_connected(false),
   m_last_update(0),
   m_update_interval(300),  // 5 minutes default
   m_request_count(0),
   m_error_count(0)
{
   m_cached_signal.Reset();
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CFundamentalsBridge::~CFundamentalsBridge()
{
}

//+------------------------------------------------------------------+
//| Initialization                                                    |
//+------------------------------------------------------------------+
bool CFundamentalsBridge::Init(string base_url = "http://127.0.0.1:8000", int update_interval = 300)
{
   m_base_url = base_url;
   m_update_interval = update_interval;
   
   // Test connection with health endpoint
   string response;
   if(!SendRequest("/api/v1/health", response))
   {
      Print("CFundamentalsBridge: Cannot connect to Agent Hub at ", m_base_url);
      m_is_connected = false;
      return false;
   }
   
   Print("CFundamentalsBridge: Connected to Agent Hub at ", m_base_url);
   m_is_connected = true;
   
   // Initial signal fetch
   UpdateSignal();
   
   return true;
}

//+------------------------------------------------------------------+
//| Check if update is needed                                         |
//+------------------------------------------------------------------+
bool CFundamentalsBridge::NeedsUpdate() const
{
   if(!m_cached_signal.is_valid)
      return true;
   
   return (TimeCurrent() - m_last_update) >= m_update_interval;
}

//+------------------------------------------------------------------+
//| Get cached or updated signal                                      |
//+------------------------------------------------------------------+
bool CFundamentalsBridge::GetSignal(SFundamentalsSignal& signal)
{
   // Update if needed
   if(NeedsUpdate())
   {
      if(!UpdateSignal())
      {
         // Return cached even if stale
         signal = m_cached_signal;
         return m_cached_signal.is_valid;
      }
   }
   
   signal = m_cached_signal;
   return m_cached_signal.is_valid;
}

//+------------------------------------------------------------------+
//| Update signal from Python Hub                                     |
//+------------------------------------------------------------------+
bool CFundamentalsBridge::UpdateSignal()
{
   m_request_count++;
   
   string response;
   if(!SendRequest("/api/v1/signal", response))
   {
      m_error_count++;
      m_cached_signal.error = "HTTP request failed";
      return false;
   }
   
   SFundamentalsSignal new_signal;
   if(!ParseSignalResponse(response, new_signal))
   {
      m_error_count++;
      m_cached_signal.error = "Parse failed: " + response;
      return false;
   }
   
   m_cached_signal = new_signal;
   m_cached_signal.is_valid = true;
   m_cached_signal.timestamp = TimeCurrent();
   m_last_update = TimeCurrent();
   
   Print("CFundamentalsBridge: Signal updated - ", new_signal.signal, 
         " Score: ", new_signal.score, 
         " Adj: ", new_signal.score_adjustment);
   
   return true;
}

//+------------------------------------------------------------------+
//| OnTimer - call periodically to update                             |
//+------------------------------------------------------------------+
void CFundamentalsBridge::OnTimer()
{
   if(NeedsUpdate())
   {
      UpdateSignal();
   }
}

//+------------------------------------------------------------------+
//| Get individual macro score                                        |
//+------------------------------------------------------------------+
double CFundamentalsBridge::GetMacroScore()
{
   if(NeedsUpdate())
      UpdateSignal();
   return m_cached_signal.macro_score;
}

//+------------------------------------------------------------------+
//| Get individual oil score                                          |
//+------------------------------------------------------------------+
double CFundamentalsBridge::GetOilScore()
{
   if(NeedsUpdate())
      UpdateSignal();
   return m_cached_signal.oil_score;
}

//+------------------------------------------------------------------+
//| Get sentiment score                                               |
//+------------------------------------------------------------------+
double CFundamentalsBridge::GetSentimentScore()
{
   if(NeedsUpdate())
      UpdateSignal();
   return m_cached_signal.sentiment_score;
}

//+------------------------------------------------------------------+
//| Send HTTP Request                                                 |
//+------------------------------------------------------------------+
bool CFundamentalsBridge::SendRequest(string endpoint, string& response)
{
   string url = m_base_url + endpoint;

   char post_data[];
   char result_data[];
   string result_headers;

   // MQL5 WebRequest signature:
   // int WebRequest(string method, string url, string headers, int timeout,
   //                char &data[], char &result[], string &result_headers)
   int res = WebRequest(
      "GET",              // Method
      url,                // URL
      "",                 // Headers (empty for GET)
      m_timeout_ms,       // Timeout
      post_data,          // POST data (empty for GET)
      result_data,        // Response data
      result_headers      // Response headers
   );

   // WebRequest returns -1 on error
   if(res == -1)
   {
      int error = GetLastError();
      Print("CFundamentalsBridge: WebRequest error ", error);

      if(error == 4014)
         Print("Add ", m_base_url, " to Tools -> Options -> Expert Advisors -> Allow WebRequest");

      return false;
   }

   // Convert result to string
   response = CharArrayToString(result_data, 0, WHOLE_ARRAY, CP_UTF8);

   return (res >= 200 && res < 300);
}

//+------------------------------------------------------------------+
//| Parse Signal Response JSON                                        |
//+------------------------------------------------------------------+
bool CFundamentalsBridge::ParseSignalResponse(string json, SFundamentalsSignal& signal)
{
   signal.Reset();
   
   // Parse main fields
   signal.signal = ParseString(json, "signal");
   signal.score = ParseDouble(json, "score");
   signal.score_adjustment = ParseInt(json, "score_adjustment");
   signal.size_multiplier = ParseDouble(json, "size_multiplier");
   signal.confidence = ParseDouble(json, "confidence");
   
   // Parse fundamentals components
   int fund_start = StringFind(json, "\"fundamentals\":");
   if(fund_start >= 0)
   {
      int fund_end = StringFind(json, "}", fund_start);
      string fund_json = StringSubstr(json, fund_start, fund_end - fund_start + 1);
      signal.bias = ParseString(fund_json, "bias");
      
      // Parse components
      int comp_start = StringFind(fund_json, "\"components\":");
      if(comp_start >= 0)
      {
         int comp_end = StringFind(fund_json, "}", comp_start);
         string comp_json = StringSubstr(fund_json, comp_start, comp_end - comp_start + 1);
         signal.macro_score = ParseDouble(comp_json, "macro_score");
         signal.oil_score = ParseDouble(comp_json, "oil_score");
         signal.etf_score = ParseDouble(comp_json, "etf_score");
      }
   }
   
   // Parse sentiment
   int sent_start = StringFind(json, "\"sentiment\":");
   if(sent_start >= 0)
   {
      int sent_end = StringFind(json, "}", sent_start);
      string sent_json = StringSubstr(json, sent_start, sent_end - sent_start + 1);
      signal.sentiment_score = ParseDouble(sent_json, "score");
   }
   
   // Validate
   if(StringLen(signal.signal) < 3)
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Parse Double from JSON                                            |
//+------------------------------------------------------------------+
double CFundamentalsBridge::ParseDouble(string json, string key)
{
   string search = "\"" + key + "\":";
   int pos = StringFind(json, search);
   if(pos < 0) return 0.0;
   
   pos += StringLen(search);
   
   // Skip whitespace
   while(pos < StringLen(json) && (StringGetCharacter(json, pos) == ' ' || StringGetCharacter(json, pos) == '\t'))
      pos++;
   
   // Find end of number
   int end = pos;
   while(end < StringLen(json))
   {
      ushort ch = StringGetCharacter(json, end);
      if((ch >= '0' && ch <= '9') || ch == '.' || ch == '-' || ch == '+')
         end++;
      else
         break;
   }
   
   string value = StringSubstr(json, pos, end - pos);
   return StringToDouble(value);
}

//+------------------------------------------------------------------+
//| Parse Int from JSON                                               |
//+------------------------------------------------------------------+
int CFundamentalsBridge::ParseInt(string json, string key)
{
   return (int)ParseDouble(json, key);
}

//+------------------------------------------------------------------+
//| Parse String from JSON                                            |
//+------------------------------------------------------------------+
string CFundamentalsBridge::ParseString(string json, string key)
{
   string search = "\"" + key + "\":";
   int pos = StringFind(json, search);
   if(pos < 0) return "";
   
   pos += StringLen(search);
   
   // Skip whitespace
   while(pos < StringLen(json) && (StringGetCharacter(json, pos) == ' ' || StringGetCharacter(json, pos) == '\t'))
      pos++;
   
   // Check for string start
   if(StringGetCharacter(json, pos) != '"')
      return "";
   
   pos++;  // Skip opening quote
   
   // Find closing quote
   int end = StringFind(json, "\"", pos);
   if(end < 0) return "";
   
   return StringSubstr(json, pos, end - pos);
}

//+------------------------------------------------------------------+
