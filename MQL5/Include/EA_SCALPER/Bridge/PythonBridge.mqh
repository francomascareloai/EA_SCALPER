//+------------------------------------------------------------------+
//|                                                 PythonBridge.mqh |
//|                                                           Franco |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Franco"
#property link      "https://www.mql5.com"
#property strict

//+------------------------------------------------------------------+
//| Class: CPythonBridge                                             |
//| Purpose: HTTP Bridge to Python Agent Hub                         |
//+------------------------------------------------------------------+
class CPythonBridge
{
private:
   string            m_base_url;
   int               m_timeout_ms;
   bool              m_is_connected;
   datetime          m_last_health_check;
   
   // Request Counter
   ulong             m_request_counter;

public:
                     CPythonBridge();
                    ~CPythonBridge();

   //--- Initialization
   bool              Init(string base_url = "http://127.0.0.1:8000");
   
   //--- Health Check
   bool              CheckHealth();
   
   //--- Analysis Requests (Fast Lane)
   bool              RequestTechnicalScore(int& out_score, string& out_error);
   
   //--- Utility
   bool              IsConnected() const { return m_is_connected; }
   void              OnTimer();

private:
   string            GenerateRequestId();
   bool              SendHttpRequest(string endpoint, string json_body, string& response, int timeout_ms = 5000);
   bool              ParseTechnicalResponse(string json_response, int& score, string& error);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPythonBridge::CPythonBridge() :
   m_base_url("http://127.0.0.1:8000"),
   m_timeout_ms(5000),
   m_is_connected(false),
   m_last_health_check(0),
   m_request_counter(0)
{
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPythonBridge::~CPythonBridge()
{
}

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
bool CPythonBridge::Init(string base_url = "http://127.0.0.1:8000")
{
   m_base_url = base_url;
   
   // Initial Health Check
   if(!CheckHealth())
   {
      Print("PythonBridge: Failed to connect to Agent Hub at ", m_base_url);
      return false;
   }
   
   Print("PythonBridge: Connected to Agent Hub at ", m_base_url);
   m_is_connected = true;
   return true;
}

//+------------------------------------------------------------------+
//| Health Check                                                     |
//+------------------------------------------------------------------+
bool CPythonBridge::CheckHealth()
{
   string response;
   if(!SendHttpRequest("/health", "", response, 2000))
   {
      m_is_connected = false;
      return false;
   }
   
   // Simple check: if we got a response, consider it healthy
   if(StringFind(response, "healthy") >= 0)
   {
      m_is_connected = true;
      m_last_health_check = TimeCurrent();
      return true;
   }
   
   m_is_connected = false;
   return false;
}

//+------------------------------------------------------------------+
//| Request Technical Score (Fast Lane)                              |
//+------------------------------------------------------------------+
bool CPythonBridge::RequestTechnicalScore(int& out_score, string& out_error)
{
   if(!m_is_connected)
   {
      out_error = "Not connected to Agent Hub";
      return false;
   }
   
   // Build JSON Request
   string req_id = GenerateRequestId();
   double current_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   string json_body = StringFormat(
      "{\"schema_version\":\"1.0\",\"req_id\":\"%s\",\"timestamp\":%.0f,\"timeout_ms\":200,\"symbol\":\"%s\",\"timeframe\":\"M15\",\"current_price\":%.5f}",
      req_id,
      (double)TimeCurrent(),
      _Symbol,
      current_price
   );
   
   string response;
   if(!SendHttpRequest("/api/v1/technical", json_body, response, 300))
   {
      out_error = "HTTP request failed";
      return false;
   }
   
   // Parse Response
   return ParseTechnicalResponse(response, out_score, out_error);
}

//+------------------------------------------------------------------+
//| OnTimer: Periodic Health Check                                   |
//+------------------------------------------------------------------+
void CPythonBridge::OnTimer()
{
   // Check health every 60 seconds
   if(TimeCurrent() - m_last_health_check > 60)
   {
      CheckHealth();
   }
}

//+------------------------------------------------------------------+
//| Generate Unique Request ID                                       |
//+------------------------------------------------------------------+
string CPythonBridge::GenerateRequestId()
{
   m_request_counter++;
   return StringFormat("MQL5_%llu_%d", GetTickCount64(), m_request_counter);
}

//+------------------------------------------------------------------+
//| Send HTTP Request                                                |
//+------------------------------------------------------------------+
bool CPythonBridge::SendHttpRequest(string endpoint, string json_body, string& response, int timeout_ms = 5000)
{
   string url = m_base_url + endpoint;
   string headers = "Content-Type: application/json\r\n";
   
   char post_data[];
   char result_data[];
   string result_headers;
   
   if(json_body != "")
   {
      StringToCharArray(json_body, post_data, 0, StringLen(json_body));
   }
   
   ResetLastError();
   int res = WebRequest(
      "POST",
      url,
      headers,
      timeout_ms,
      post_data,
      result_data,
      result_headers
   );
   
   if(res == -1)
   {
      int error = GetLastError();
      Print("WebRequest Error: ", error, " - ", ErrorDescription(error));
      Print("URL: ", url);
      Print("Make sure URL is in MT5 Tools -> Options -> Expert Advisors -> Allow WebRequest for listed URL");
      return false;
   }
   
   if(res != 200)
   {
      Print("HTTP Error: ", res);
      return false;
   }
   
   response = CharArrayToString(result_data);
   return true;
}

//+------------------------------------------------------------------+
//| Parse Technical Response                                         |
//+------------------------------------------------------------------+
bool CPythonBridge::ParseTechnicalResponse(string json_response, int& score, string& error)
{
   // Simple JSON parsing (for MVP)
   // In production, use a proper JSON library
   
   int tech_pos = StringFind(json_response, "tech_subscore");
   if(tech_pos < 0)
   {
      error = "Invalid response format";
      return false;
   }
   
   // Extract score value (very basic parsing)
   int colon_pos = StringFind(json_response, ":", tech_pos);
   int comma_pos = StringFind(json_response, ",", colon_pos);
   if(comma_pos < 0) comma_pos = StringFind(json_response, "}", colon_pos);
   
   string score_str = StringSubstr(json_response, colon_pos + 1, comma_pos - colon_pos - 1);
   StringTrimLeft(score_str);
   StringTrimRight(score_str);
   
   score = (int)StringToInteger(score_str);
   
   // Check for error field
   if(StringFind(json_response, "\"error\":null") < 0 && StringFind(json_response, "\"error\": null") < 0)
   {
      // There might be an error
      int error_pos = StringFind(json_response, "\"error\":");
      if(error_pos >= 0)
      {
         int quote_start = StringFind(json_response, "\"", error_pos + 8);
         int quote_end = StringFind(json_response, "\"", quote_start + 1);
         if(quote_start >= 0 && quote_end > quote_start)
         {
            error = StringSubstr(json_response, quote_start + 1, quote_end - quote_start - 1);
            return false;
         }
      }
   }
   
   return true;
}
