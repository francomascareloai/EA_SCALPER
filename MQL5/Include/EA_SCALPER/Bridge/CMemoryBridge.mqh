//+------------------------------------------------------------------+
//| CMemoryBridge.mqh - Trade Memory HTTP Client                      |
//| EA_SCALPER_XAUUSD v4.1 - Learning Edition                        |
//|                                                                   |
//| Connects to Python Hub Memory API for:                           |
//| - Checking if situation should be avoided (past losses)          |
//| - Recording completed trades                                      |
//| - Getting risk mode recommendation                                |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD"
#property version   "4.10"
#property strict

#include <Trade\Trade.mqh>

//--- Memory check result structure
struct SMemoryCheckResult
{
   bool     should_trade;      // True if OK to trade
   string   avoid_reason;      // Reason to avoid (if any)
   int      similar_found;     // Number of similar trades found
   double   win_rate;          // Historical win rate
   double   avg_r;             // Average R-multiple
   double   confidence;        // Confidence level (0-1)
};

//--- Risk mode result structure
struct SRiskModeResult
{
   string   mode;              // AGGRESSIVE, NEUTRAL, CONSERVATIVE
   double   size_multiplier;   // Position size multiplier
   int      score_adjustment;  // Score threshold adjustment
   bool     can_trade;         // Can trade in this mode
   string   reasoning;         // Human-readable reason
};

//--- Trade record structure for sending to memory
struct STradeRecordData
{
   long     ticket;
   string   symbol;
   string   direction;
   datetime entry_time;
   datetime exit_time;
   double   entry_price;
   double   exit_price;
   double   stop_loss;
   double   take_profit;
   double   profit_loss;
   double   profit_pips;
   double   r_multiple;
   bool     is_winner;
   string   regime;
   string   session;
   string   spread_state;
   bool     news_window;
   int      confluence_score;
   string   signal_tier;
   // Features (key ones)
   double   hurst;
   double   entropy;
   double   rsi;
   double   atr_norm;
};


//+------------------------------------------------------------------+
//| Memory Bridge Class                                               |
//+------------------------------------------------------------------+
class CMemoryBridge
{
private:
   string   m_hub_url;         // Python Hub base URL
   int      m_timeout_ms;      // HTTP timeout
   bool     m_enabled;         // Feature enabled flag
   bool     m_connected;       // Connection status
   
   // Last results (cached)
   SMemoryCheckResult m_last_check;
   SRiskModeResult    m_last_mode;
   datetime           m_last_check_time;
   int                m_cache_seconds;
   
public:
   //--- Constructor
   CMemoryBridge()
   {
      m_hub_url = "http://localhost:8000";
      m_timeout_ms = 100;  // 100ms timeout (fast fail)
      m_enabled = true;
      m_connected = false;
      m_cache_seconds = 5;  // Cache for 5 seconds
      m_last_check_time = 0;
   }
   
   //--- Initialize
   bool Init(string hub_url = "http://localhost:8000", int timeout_ms = 100)
   {
      m_hub_url = hub_url;
      m_timeout_ms = timeout_ms;
      
      // Test connection
      m_connected = TestConnection();
      
      if(m_connected)
         Print("MemoryBridge: Connected to Python Hub at ", m_hub_url);
      else
         Print("MemoryBridge: Warning - Could not connect to Hub (will operate without memory)");
      
      return m_connected;
   }
   
   //--- Check connection
   bool TestConnection()
   {
      string url = m_hub_url + "/api/v1/memory/health";
      string result;
      
      if(!HttpGet(url, result))
         return false;
      
      return (StringFind(result, "healthy") >= 0);
   }
   
   //--- Check if situation should be avoided
   bool CheckSituation(
      double hurst,
      double entropy,
      double rsi,
      string direction,
      string regime,
      string session,
      SMemoryCheckResult &result
   )
   {
      // Return cached if recent
      if(m_last_check_time > 0 && 
         TimeCurrent() - m_last_check_time < m_cache_seconds &&
         m_last_check.should_trade)
      {
         result = m_last_check;
         return true;
      }
      
      if(!m_enabled || !m_connected)
      {
         // Default: allow trade
         result.should_trade = true;
         result.avoid_reason = "";
         result.similar_found = 0;
         result.confidence = 0;
         return true;
      }
      
      // Build JSON request
      string json = "{";
      json += "\"features\": {";
      json += "\"hurst\": " + DoubleToString(hurst, 4) + ",";
      json += "\"entropy\": " + DoubleToString(entropy, 4) + ",";
      json += "\"rsi\": " + DoubleToString(rsi, 2);
      json += "},";
      json += "\"direction\": \"" + direction + "\",";
      json += "\"regime\": \"" + regime + "\",";
      json += "\"session\": \"" + session + "\"";
      json += "}";
      
      string url = m_hub_url + "/api/v1/memory/check";
      string response;
      
      if(!HttpPost(url, json, response))
      {
         // Fail open - allow trade on error
         result.should_trade = true;
         result.avoid_reason = "";
         result.confidence = 0;
         return true;
      }
      
      // Parse response
      result.should_trade = (StringFind(response, "\"should_trade\": true") >= 0 ||
                            StringFind(response, "\"should_trade\":true") >= 0);
      
      result.avoid_reason = ExtractStringValue(response, "avoid_reason");
      result.similar_found = (int)ExtractDoubleValue(response, "similar_trades_found");
      result.win_rate = ExtractDoubleValue(response, "win_rate");
      result.avg_r = ExtractDoubleValue(response, "avg_r_multiple");
      result.confidence = ExtractDoubleValue(response, "confidence");
      
      // Cache result
      m_last_check = result;
      m_last_check_time = TimeCurrent();
      
      return true;
   }
   
   //--- Record completed trade
   bool RecordTrade(STradeRecordData &trade, string &reflection, string &recommendation)
   {
      if(!m_enabled || !m_connected)
         return false;
      
      // Build JSON
      string json = "{";
      json += "\"ticket\": " + IntegerToString(trade.ticket) + ",";
      json += "\"symbol\": \"" + trade.symbol + "\",";
      json += "\"direction\": \"" + trade.direction + "\",";
      json += "\"entry_time\": \"" + TimeToString(trade.entry_time, TIME_DATE|TIME_SECONDS) + "\",";
      json += "\"exit_time\": \"" + TimeToString(trade.exit_time, TIME_DATE|TIME_SECONDS) + "\",";
      json += "\"entry_price\": " + DoubleToString(trade.entry_price, 5) + ",";
      json += "\"exit_price\": " + DoubleToString(trade.exit_price, 5) + ",";
      json += "\"stop_loss\": " + DoubleToString(trade.stop_loss, 5) + ",";
      json += "\"take_profit\": " + DoubleToString(trade.take_profit, 5) + ",";
      json += "\"profit_loss\": " + DoubleToString(trade.profit_loss, 2) + ",";
      json += "\"profit_pips\": " + DoubleToString(trade.profit_pips, 1) + ",";
      json += "\"r_multiple\": " + DoubleToString(trade.r_multiple, 3) + ",";
      json += "\"is_winner\": " + (trade.is_winner ? "true" : "false") + ",";
      json += "\"features\": {";
      json += "\"hurst\": " + DoubleToString(trade.hurst, 4) + ",";
      json += "\"entropy\": " + DoubleToString(trade.entropy, 4) + ",";
      json += "\"rsi\": " + DoubleToString(trade.rsi, 2) + ",";
      json += "\"atr_norm\": " + DoubleToString(trade.atr_norm, 6);
      json += "},";
      json += "\"regime\": \"" + trade.regime + "\",";
      json += "\"session\": \"" + trade.session + "\",";
      json += "\"spread_state\": \"" + trade.spread_state + "\",";
      json += "\"news_window\": " + (trade.news_window ? "true" : "false") + ",";
      json += "\"confluence_score\": " + IntegerToString(trade.confluence_score) + ",";
      json += "\"signal_tier\": \"" + trade.signal_tier + "\"";
      json += "}";
      
      // Fix datetime format for ISO
      StringReplace(json, ".", "-");  // Date separator
      
      string url = m_hub_url + "/api/v1/memory/record";
      string response;
      
      if(!HttpPost(url, json, response))
         return false;
      
      // Extract reflection and recommendation
      reflection = ExtractStringValue(response, "reflection");
      recommendation = ExtractStringValue(response, "recommendation");
      
      return true;
   }
   
   //--- Get risk mode
   bool GetRiskMode(
      double daily_dd,
      double total_dd,
      double last_result,
      bool is_new_day,
      SRiskModeResult &result
   )
   {
      if(!m_enabled || !m_connected)
      {
         // Default: neutral mode
         result.mode = "NEUTRAL";
         result.size_multiplier = 1.0;
         result.score_adjustment = 0;
         result.can_trade = true;
         result.reasoning = "Memory not connected";
         return true;
      }
      
      // Build JSON
      string json = "{";
      json += "\"daily_dd\": " + DoubleToString(daily_dd, 2) + ",";
      json += "\"total_dd\": " + DoubleToString(total_dd, 2) + ",";
      json += "\"last_trade_result\": " + DoubleToString(last_result, 2) + ",";
      json += "\"is_new_day\": " + (is_new_day ? "true" : "false");
      json += "}";
      
      string url = m_hub_url + "/api/v1/memory/risk-mode";
      string response;
      
      if(!HttpPost(url, json, response))
      {
         // Default on error
         result.mode = "NEUTRAL";
         result.size_multiplier = 1.0;
         result.score_adjustment = 0;
         result.can_trade = true;
         result.reasoning = "Hub connection error";
         return true;
      }
      
      // Parse response
      result.mode = ExtractStringValue(response, "mode");
      result.size_multiplier = ExtractDoubleValue(response, "size_multiplier");
      result.score_adjustment = (int)ExtractDoubleValue(response, "score_adjustment");
      result.can_trade = (StringFind(response, "\"can_trade\": true") >= 0 ||
                         StringFind(response, "\"can_trade\":true") >= 0);
      result.reasoning = ExtractStringValue(response, "reasoning");
      
      // Cache
      m_last_mode = result;
      
      return true;
   }
   
   //--- Getters
   bool IsConnected() { return m_connected; }
   bool IsEnabled() { return m_enabled; }
   void SetEnabled(bool enabled) { m_enabled = enabled; }
   SMemoryCheckResult GetLastCheck() { return m_last_check; }
   SRiskModeResult GetLastMode() { return m_last_mode; }

private:
   //--- HTTP GET request
   bool HttpGet(string url, string &result)
   {
      char post_data[];
      char response[];
      string headers = "Content-Type: application/json\r\n";
      
      int res = WebRequest("GET", url, headers, m_timeout_ms, post_data, response, headers);
      
      if(res == -1)
      {
         int error = GetLastError();
         if(error == 4060)
            Print("MemoryBridge: Add URL to allowed list in Tools > Options > Expert Advisors");
         return false;
      }
      
      if(res != 200)
         return false;
      
      result = CharArrayToString(response);
      return true;
   }
   
   //--- HTTP POST request
   bool HttpPost(string url, string json, string &result)
   {
      char post_data[];
      char response[];
      string headers = "Content-Type: application/json\r\n";
      
      StringToCharArray(json, post_data, 0, StringLen(json));
      
      int res = WebRequest("POST", url, headers, m_timeout_ms, post_data, response, headers);
      
      if(res == -1)
      {
         int error = GetLastError();
         if(error == 4060)
            Print("MemoryBridge: Add URL to allowed list in Tools > Options > Expert Advisors");
         return false;
      }
      
      if(res != 200)
         return false;
      
      result = CharArrayToString(response);
      return true;
   }
   
   //--- Extract string value from JSON
   string ExtractStringValue(string json, string key)
   {
      string search = "\"" + key + "\": \"";
      int start = StringFind(json, search);
      
      if(start < 0)
      {
         search = "\"" + key + "\":\"";
         start = StringFind(json, search);
      }
      
      if(start < 0)
         return "";
      
      start += StringLen(search);
      int end = StringFind(json, "\"", start);
      
      if(end < 0)
         return "";
      
      return StringSubstr(json, start, end - start);
   }
   
   //--- Extract double value from JSON
   double ExtractDoubleValue(string json, string key)
   {
      string search = "\"" + key + "\": ";
      int start = StringFind(json, search);
      
      if(start < 0)
      {
         search = "\"" + key + "\":";
         start = StringFind(json, search);
      }
      
      if(start < 0)
         return 0;
      
      start += StringLen(search);
      
      // Find end of number
      int end = start;
      while(end < StringLen(json))
      {
         ushort ch = StringGetCharacter(json, end);
         if(ch != '.' && ch != '-' && (ch < '0' || ch > '9'))
            break;
         end++;
      }
      
      string value = StringSubstr(json, start, end - start);
      return StringToDouble(value);
   }
};


//+------------------------------------------------------------------+
//| Global memory bridge instance                                     |
//+------------------------------------------------------------------+
CMemoryBridge g_memory_bridge;


//+------------------------------------------------------------------+
//| Helper function: Initialize memory bridge                         |
//+------------------------------------------------------------------+
bool InitMemoryBridge(string hub_url = "http://localhost:8000")
{
   return g_memory_bridge.Init(hub_url);
}


//+------------------------------------------------------------------+
//| Helper function: Check if should trade                            |
//+------------------------------------------------------------------+
bool MemoryAllowsTrade(
   double hurst,
   double entropy,
   double rsi,
   string direction,
   string regime,
   string session,
   string &avoid_reason
)
{
   SMemoryCheckResult result;
   
   if(!g_memory_bridge.CheckSituation(hurst, entropy, rsi, direction, regime, session, result))
      return true;  // Allow on error
   
   avoid_reason = result.avoid_reason;
   return result.should_trade;
}


//+------------------------------------------------------------------+
//| Helper function: Record trade to memory                           |
//+------------------------------------------------------------------+
bool RecordTradeToMemory(
   long ticket,
   string direction,
   datetime entry_time,
   datetime exit_time,
   double entry_price,
   double exit_price,
   double stop_loss,
   double take_profit,
   double profit_loss,
   double profit_pips,
   double r_multiple,
   bool is_winner,
   double hurst,
   double entropy,
   double rsi,
   string regime,
   string session,
   int confluence_score,
   string signal_tier
)
{
   STradeRecordData trade;
   
   trade.ticket = ticket;
   trade.symbol = _Symbol;
   trade.direction = direction;
   trade.entry_time = entry_time;
   trade.exit_time = exit_time;
   trade.entry_price = entry_price;
   trade.exit_price = exit_price;
   trade.stop_loss = stop_loss;
   trade.take_profit = take_profit;
   trade.profit_loss = profit_loss;
   trade.profit_pips = profit_pips;
   trade.r_multiple = r_multiple;
   trade.is_winner = is_winner;
   trade.hurst = hurst;
   trade.entropy = entropy;
   trade.rsi = rsi;
   trade.atr_norm = 0;
   trade.regime = regime;
   trade.session = session;
   trade.spread_state = "NORMAL";
   trade.news_window = false;
   trade.confluence_score = confluence_score;
   trade.signal_tier = signal_tier;
   
   string reflection, recommendation;
   return g_memory_bridge.RecordTrade(trade, reflection, recommendation);
}
//+------------------------------------------------------------------+
