//+------------------------------------------------------------------+
//|                                                  CNewsTrader.mqh |
//|                                                           Franco |
//|                   EA_SCALPER_XAUUSD v4.0 - News Trading Strategy |
//+------------------------------------------------------------------+
#property copyright "Franco"
#property link      "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
#include "..\Context\CNewsWindowDetector.mqh"

//+------------------------------------------------------------------+
//| News Trading Modes                                                |
//+------------------------------------------------------------------+
enum ENUM_NEWS_MODE
{
   NEWS_MODE_NONE = 0,           // No news trade
   NEWS_MODE_PREPOSITION = 1,    // Pre-position before release
   NEWS_MODE_PULLBACK = 2,       // Wait for pullback after spike
   NEWS_MODE_STRADDLE = 3        // Buy stop + Sell stop (OCO)
};

//+------------------------------------------------------------------+
//| News Trade Direction                                              |
//+------------------------------------------------------------------+
enum ENUM_NEWS_DIRECTION
{
   NEWS_DIR_NONE = 0,
   NEWS_DIR_BULLISH = 1,         // Expect gold up (dovish/weak USD)
   NEWS_DIR_BEARISH = 2,         // Expect gold down (hawkish/strong USD)
   NEWS_DIR_UNCERTAIN = 3        // Use straddle
};

//+------------------------------------------------------------------+
//| News Trade Setup                                                  |
//+------------------------------------------------------------------+
struct SNewsTradeSetup
{
   ENUM_NEWS_MODE    mode;
   ENUM_NEWS_DIRECTION direction;
   
   string            event_name;
   datetime          event_time;
   int               minutes_to_event;
   
   double            entry_price;
   double            stop_loss;
   double            take_profit_1;
   double            take_profit_2;
   double            take_profit_3;
   
   double            lot_size;
   double            risk_percent;
   
   bool              is_valid;
   string            reason;
   
   // Straddle specific
   double            buy_stop_price;
   double            sell_stop_price;
   double            straddle_distance;
   
   void Reset()
   {
      mode = NEWS_MODE_NONE;
      direction = NEWS_DIR_NONE;
      event_name = "";
      event_time = 0;
      minutes_to_event = 0;
      entry_price = 0;
      stop_loss = 0;
      take_profit_1 = 0;
      take_profit_2 = 0;
      take_profit_3 = 0;
      lot_size = 0;
      risk_percent = 0.25;
      is_valid = false;
      reason = "";
      buy_stop_price = 0;
      sell_stop_price = 0;
      straddle_distance = 0;
   }
};

//+------------------------------------------------------------------+
//| News Trade Result                                                 |
//+------------------------------------------------------------------+
struct SNewsTradeResult
{
   bool              success;
   ulong             ticket;
   ulong             ticket_2;     // For straddle (second order)
   string            message;
   double            actual_entry;
   double            slippage;
};

//+------------------------------------------------------------------+
//| Class: CNewsTrader                                                |
//| Purpose: Execute news-based trading strategies                    |
//|                                                                   |
//| 3 Modes:                                                          |
//| 1. PRE-POSITION: Enter 5-10 min before with directional bias      |
//| 2. PULLBACK: Wait for spike, enter on 38-50% retracement          |
//| 3. STRADDLE: Buy stop + Sell stop, OCO (One-Cancels-Other)        |
//+------------------------------------------------------------------+
class CNewsTrader
{
private:
   //--- Configuration
   string            m_symbol;
   int               m_magic;
   
   //--- Mode settings
   int               m_preposition_minutes;  // Enter X min before
   int               m_pullback_wait_sec;    // Wait X sec after release
   double            m_pullback_retrace_pct; // Enter at X% retracement
   double            m_straddle_distance;    // Distance from price for stops
   
   //--- Risk settings
   double            m_news_risk_percent;    // Risk % for news trades
   double            m_max_spread_pips;      // Max spread during news
   int               m_max_slippage;         // Max slippage points
   
   //--- R:R settings
   double            m_min_rr;               // Minimum R:R
   double            m_tp1_rr;               // TP1 R multiple
   double            m_tp2_rr;               // TP2 R multiple
   double            m_tp3_rr;               // TP3 R multiple
   
   //--- State
   CTrade            m_trade;
   bool              m_has_pending_news;
   SNewsTradeSetup   m_current_setup;
   datetime          m_last_trade_time;
   
   //--- Straddle management
   ulong             m_straddle_buy_ticket;
   ulong             m_straddle_sell_ticket;
   bool              m_straddle_active;
   
   //--- Spike tracking for pullback
   double            m_spike_high;
   double            m_spike_low;
   datetime          m_spike_start_time;
   bool              m_spike_detected;
   
public:
                     CNewsTrader();
                    ~CNewsTrader();
   
   //--- Initialization
   bool              Init(string symbol = "", int magic = 12345);
   void              SetRiskPercent(double percent) { m_news_risk_percent = percent; }
   void              SetPrepositionMinutes(int min) { m_preposition_minutes = min; }
   void              SetPullbackWaitSec(int sec) { m_pullback_wait_sec = sec; }
   void              SetPullbackRetrace(double pct) { m_pullback_retrace_pct = pct; }
   void              SetStraddleDistance(double dist) { m_straddle_distance = dist; }
   void              SetMaxSpread(double pips) { m_max_spread_pips = pips; }
   
   //--- Main analysis
   SNewsTradeSetup   AnalyzeNewsSetup(const SNewsWindowResult &news_window);
   ENUM_NEWS_DIRECTION DetermineDirection(const string &event_name, double forecast, double previous);
   ENUM_NEWS_MODE    DetermineMode(const SNewsWindowResult &news_window, ENUM_NEWS_DIRECTION direction);
   
   //--- Execution
   SNewsTradeResult  ExecutePreposition(const SNewsTradeSetup &setup);
   SNewsTradeResult  ExecutePullback(const SNewsTradeSetup &setup);
   SNewsTradeResult  ExecuteStraddle(const SNewsTradeSetup &setup);
   
   //--- Trade management
   void              ManageOpenTrades();
   void              ManageStraddle();
   void              CancelOCO(ulong triggered_ticket);
   
   //--- Pullback detection
   void              TrackSpike(double price);
   bool              IsPullbackEntry(double current_price);
   double            GetPullbackEntry();
   
   //--- Status
   bool              HasActiveNewsTrade();
   SNewsTradeSetup   GetCurrentSetup() { return m_current_setup; }
   void              PrintSetup(const SNewsTradeSetup &setup);
   
private:
   double            CalculateLotSize(double sl_points);
   double            GetCurrentSpread();
   bool              IsSpreadAcceptable();
   void              SetupTPLevels(SNewsTradeSetup &setup, bool is_buy);
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CNewsTrader::CNewsTrader()
{
   m_symbol = "";
   m_magic = 12345;
   
   m_preposition_minutes = 5;
   m_pullback_wait_sec = 45;
   m_pullback_retrace_pct = 0.382;  // 38.2% Fib
   m_straddle_distance = 50;        // 50 points
   
   m_news_risk_percent = 0.25;      // 0.25% risk for news
   m_max_spread_pips = 30;
   m_max_slippage = 50;
   
   m_min_rr = 1.5;
   m_tp1_rr = 1.5;
   m_tp2_rr = 2.5;
   m_tp3_rr = 4.0;
   
   m_has_pending_news = false;
   m_last_trade_time = 0;
   
   m_straddle_buy_ticket = 0;
   m_straddle_sell_ticket = 0;
   m_straddle_active = false;
   
   m_spike_high = 0;
   m_spike_low = DBL_MAX;
   m_spike_start_time = 0;
   m_spike_detected = false;
   
   m_current_setup.Reset();
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CNewsTrader::~CNewsTrader()
{
}

//+------------------------------------------------------------------+
//| Initialize                                                        |
//+------------------------------------------------------------------+
bool CNewsTrader::Init(string symbol = "", int magic = 12345)
{
   m_symbol = symbol == "" ? _Symbol : symbol;
   m_magic = magic;
   
   m_trade.SetExpertMagicNumber(m_magic);
   m_trade.SetDeviationInPoints(m_max_slippage);
   m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   
   Print("CNewsTrader: Initialized for ", m_symbol);
   Print("  Risk: ", m_news_risk_percent, "%");
   Print("  Pre-position: ", m_preposition_minutes, " min before");
   Print("  Pullback wait: ", m_pullback_wait_sec, " sec");
   Print("  Straddle distance: ", m_straddle_distance, " points");
   
   return true;
}

//+------------------------------------------------------------------+
//| Analyze news window and create setup                              |
//+------------------------------------------------------------------+
SNewsTradeSetup CNewsTrader::AnalyzeNewsSetup(const SNewsWindowResult &news_window)
{
   SNewsTradeSetup setup;
   setup.Reset();
   
   // Check if we should trade this news
   if(!news_window.in_window)
   {
      setup.reason = "Not in news window";
      return setup;
   }
   
   // Only HIGH impact events
   if(news_window.event.impact != NEWS_IMPACT_HIGH)
   {
      setup.reason = "Not high impact";
      return setup;
   }
   
   // Check spread
   if(!IsSpreadAcceptable())
   {
      setup.reason = "Spread too high";
      return setup;
   }
   
   // Copy event info
   setup.event_name = news_window.event.event_name;
   setup.event_time = news_window.event.time_utc;
   setup.minutes_to_event = news_window.minutes_to_event;
   setup.risk_percent = m_news_risk_percent;
   
   // Determine expected direction
   setup.direction = DetermineDirection(
      news_window.event.event_name,
      news_window.event.forecast,
      news_window.event.previous
   );
   
   // Determine trading mode
   setup.mode = DetermineMode(news_window, setup.direction);
   
   if(setup.mode == NEWS_MODE_NONE)
   {
      setup.reason = "No valid mode";
      return setup;
   }
   
   // Calculate entry/SL/TP based on mode
   double ask = SymbolInfoDouble(m_symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(m_symbol, SYMBOL_BID);
   double atr = iATR(m_symbol, PERIOD_M5, 14);
   double atr_value = 0;
   
   if(CopyBuffer(atr, 0, 0, 1, &atr_value) <= 0)
      atr_value = 30 * _Point;  // Default
   
   switch(setup.mode)
   {
      case NEWS_MODE_PREPOSITION:
         if(setup.direction == NEWS_DIR_BULLISH)
         {
            setup.entry_price = ask;
            setup.stop_loss = bid - atr_value * 1.5;
            SetupTPLevels(setup, true);
         }
         else if(setup.direction == NEWS_DIR_BEARISH)
         {
            setup.entry_price = bid;
            setup.stop_loss = ask + atr_value * 1.5;
            SetupTPLevels(setup, false);
         }
         break;
         
      case NEWS_MODE_PULLBACK:
         // Entry calculated after spike detection
         setup.entry_price = 0;  // Will be set later
         break;
         
      case NEWS_MODE_STRADDLE:
         setup.straddle_distance = MathMax(m_straddle_distance, atr_value);
         setup.buy_stop_price = ask + setup.straddle_distance;
         setup.sell_stop_price = bid - setup.straddle_distance;
         setup.stop_loss = atr_value * 2;  // SL distance
         break;
   }
   
   // Calculate lot size
   if(setup.mode != NEWS_MODE_PULLBACK)
   {
      double sl_points = MathAbs(setup.entry_price - setup.stop_loss) / _Point;
      if(setup.mode == NEWS_MODE_STRADDLE)
         sl_points = setup.stop_loss / _Point;
      
      setup.lot_size = CalculateLotSize(sl_points);
   }
   
   setup.is_valid = true;
   setup.reason = "Setup ready";
   
   return setup;
}

//+------------------------------------------------------------------+
//| Determine expected direction from event                           |
//+------------------------------------------------------------------+
ENUM_NEWS_DIRECTION CNewsTrader::DetermineDirection(const string &event_name, 
                                                      double forecast, 
                                                      double previous)
{
   // NFP Logic
   if(StringFind(event_name, "Non-Farm") >= 0 || StringFind(event_name, "NFP") >= 0)
   {
      // Strong jobs = hawkish = USD up = Gold down
      if(forecast > previous + 50)
         return NEWS_DIR_BEARISH;
      else if(forecast < previous - 50)
         return NEWS_DIR_BULLISH;
      else
         return NEWS_DIR_UNCERTAIN;
   }
   
   // CPI Logic
   if(StringFind(event_name, "CPI") >= 0)
   {
      // High inflation = hawkish = USD up = Gold down
      if(forecast > previous)
         return NEWS_DIR_BEARISH;
      else if(forecast < previous)
         return NEWS_DIR_BULLISH;
      else
         return NEWS_DIR_UNCERTAIN;
   }
   
   // Fed Rate Decision
   if(StringFind(event_name, "Fed") >= 0 || StringFind(event_name, "FOMC") >= 0)
   {
      // Rate hike = hawkish = USD up = Gold down
      if(forecast > previous)
         return NEWS_DIR_BEARISH;
      else if(forecast < previous)
         return NEWS_DIR_BULLISH;
      else
         return NEWS_DIR_UNCERTAIN;  // Hold - wait for statement
   }
   
   // GDP Logic
   if(StringFind(event_name, "GDP") >= 0)
   {
      // Strong GDP = hawkish = USD up = Gold down
      if(forecast > previous + 0.5)
         return NEWS_DIR_BEARISH;
      else if(forecast < previous - 0.5)
         return NEWS_DIR_BULLISH;
      else
         return NEWS_DIR_UNCERTAIN;
   }
   
   // Unemployment
   if(StringFind(event_name, "Unemployment") >= 0)
   {
      // Low unemployment = hawkish = USD up = Gold down
      if(forecast < previous - 0.1)
         return NEWS_DIR_BEARISH;
      else if(forecast > previous + 0.1)
         return NEWS_DIR_BULLISH;
      else
         return NEWS_DIR_UNCERTAIN;
   }
   
   // Default: uncertain, use straddle
   return NEWS_DIR_UNCERTAIN;
}

//+------------------------------------------------------------------+
//| Determine trading mode                                            |
//+------------------------------------------------------------------+
ENUM_NEWS_MODE CNewsTrader::DetermineMode(const SNewsWindowResult &news_window, 
                                           ENUM_NEWS_DIRECTION direction)
{
   int minutes = news_window.minutes_to_event;
   
   // Before event
   if(minutes > 0)
   {
      // Pre-position zone: 5-10 minutes before
      if(minutes <= m_preposition_minutes && minutes >= 2)
      {
         if(direction == NEWS_DIR_BULLISH || direction == NEWS_DIR_BEARISH)
            return NEWS_MODE_PREPOSITION;
         else
            return NEWS_MODE_STRADDLE;
      }
      
      // Too early - wait
      return NEWS_MODE_NONE;
   }
   
   // After event
   if(minutes <= 0)
   {
      int seconds_after = -minutes * 60;
      
      // Pullback zone: 30-120 seconds after
      if(seconds_after >= 30 && seconds_after <= 120)
      {
         if(m_spike_detected)
            return NEWS_MODE_PULLBACK;
      }
      
      // Too late
      if(seconds_after > 180)
         return NEWS_MODE_NONE;
   }
   
   return NEWS_MODE_NONE;
}

//+------------------------------------------------------------------+
//| Execute pre-position trade                                        |
//+------------------------------------------------------------------+
SNewsTradeResult CNewsTrader::ExecutePreposition(const SNewsTradeSetup &setup)
{
   SNewsTradeResult result;
   result.success = false;
   result.ticket = 0;
   result.ticket_2 = 0;
   result.slippage = 0;
   
   if(!setup.is_valid || setup.mode != NEWS_MODE_PREPOSITION)
   {
      result.message = "Invalid setup for pre-position";
      return result;
   }
   
   // Check spread again
   if(!IsSpreadAcceptable())
   {
      result.message = "Spread too high";
      return result;
   }
   
   bool success = false;
   string comment = "NEWS_PRE_" + setup.event_name;
   
   if(setup.direction == NEWS_DIR_BULLISH)
   {
      success = m_trade.Buy(setup.lot_size, m_symbol, 0, 
                           setup.stop_loss, setup.take_profit_1, comment);
   }
   else if(setup.direction == NEWS_DIR_BEARISH)
   {
      success = m_trade.Sell(setup.lot_size, m_symbol, 0,
                            setup.stop_loss, setup.take_profit_1, comment);
   }
   
   if(success)
   {
      result.success = true;
      result.ticket = m_trade.ResultOrder();
      result.actual_entry = m_trade.ResultPrice();
      result.slippage = MathAbs(result.actual_entry - setup.entry_price) / _Point;
      result.message = "Pre-position executed";
      
      m_last_trade_time = TimeGMT();
      m_current_setup = setup;
      
      Print("CNewsTrader: Pre-position ", (setup.direction == NEWS_DIR_BULLISH ? "BUY" : "SELL"),
            " @ ", result.actual_entry, " SL: ", setup.stop_loss, " TP: ", setup.take_profit_1);
   }
   else
   {
      result.message = "Order failed: " + IntegerToString(GetLastError());
   }
   
   return result;
}

//+------------------------------------------------------------------+
//| Execute pullback trade                                            |
//+------------------------------------------------------------------+
SNewsTradeResult CNewsTrader::ExecutePullback(const SNewsTradeSetup &setup)
{
   SNewsTradeResult result;
   result.success = false;
   result.ticket = 0;
   result.message = "Pullback not implemented yet";
   
   // TODO: Implement pullback entry logic
   // Wait for spike, then enter on retracement
   
   return result;
}

//+------------------------------------------------------------------+
//| Execute straddle (buy stop + sell stop)                           |
//+------------------------------------------------------------------+
SNewsTradeResult CNewsTrader::ExecuteStraddle(const SNewsTradeSetup &setup)
{
   SNewsTradeResult result;
   result.success = false;
   result.ticket = 0;
   result.ticket_2 = 0;
   
   if(!setup.is_valid || setup.mode != NEWS_MODE_STRADDLE)
   {
      result.message = "Invalid setup for straddle";
      return result;
   }
   
   string comment = "NEWS_STRAD_" + setup.event_name;
   
   // Calculate SL and TP for buy stop
   double buy_sl = setup.buy_stop_price - setup.stop_loss;
   double buy_tp = setup.buy_stop_price + setup.stop_loss * m_tp1_rr;
   
   // Calculate SL and TP for sell stop
   double sell_sl = setup.sell_stop_price + setup.stop_loss;
   double sell_tp = setup.sell_stop_price - setup.stop_loss * m_tp1_rr;
   
   // Place buy stop
   bool buy_ok = m_trade.BuyStop(setup.lot_size, setup.buy_stop_price, m_symbol,
                                  buy_sl, buy_tp, ORDER_TIME_GTC, 0, comment + "_BUY");
   
   if(buy_ok)
   {
      m_straddle_buy_ticket = m_trade.ResultOrder();
   }
   
   // Place sell stop
   bool sell_ok = m_trade.SellStop(setup.lot_size, setup.sell_stop_price, m_symbol,
                                    sell_sl, sell_tp, ORDER_TIME_GTC, 0, comment + "_SELL");
   
   if(sell_ok)
   {
      m_straddle_sell_ticket = m_trade.ResultOrder();
   }
   
   if(buy_ok && sell_ok)
   {
      result.success = true;
      result.ticket = m_straddle_buy_ticket;
      result.ticket_2 = m_straddle_sell_ticket;
      result.message = "Straddle placed";
      
      m_straddle_active = true;
      m_last_trade_time = TimeGMT();
      m_current_setup = setup;
      
      Print("CNewsTrader: Straddle placed");
      Print("  Buy Stop @ ", setup.buy_stop_price, " SL: ", buy_sl, " TP: ", buy_tp);
      Print("  Sell Stop @ ", setup.sell_stop_price, " SL: ", sell_sl, " TP: ", sell_tp);
   }
   else
   {
      // Cancel any placed orders
      if(buy_ok)
         m_trade.OrderDelete(m_straddle_buy_ticket);
      if(sell_ok)
         m_trade.OrderDelete(m_straddle_sell_ticket);
      
      result.message = "Straddle failed: " + IntegerToString(GetLastError());
   }
   
   return result;
}

//+------------------------------------------------------------------+
//| Manage straddle - OCO logic                                       |
//+------------------------------------------------------------------+
void CNewsTrader::ManageStraddle()
{
   if(!m_straddle_active)
      return;
   
   bool buy_exists = false;
   bool sell_exists = false;
   bool buy_filled = false;
   bool sell_filled = false;
   
   // Check buy stop order status
   if(m_straddle_buy_ticket > 0)
   {
      if(OrderSelect(m_straddle_buy_ticket))
      {
         buy_exists = true;
      }
      else
      {
         // Order might be filled - check positions
         if(PositionSelectByTicket(m_straddle_buy_ticket))
            buy_filled = true;
      }
   }
   
   // Check sell stop order status
   if(m_straddle_sell_ticket > 0)
   {
      if(OrderSelect(m_straddle_sell_ticket))
      {
         sell_exists = true;
      }
      else
      {
         if(PositionSelectByTicket(m_straddle_sell_ticket))
            sell_filled = true;
      }
   }
   
   // OCO: If one is filled, cancel the other
   if(buy_filled && sell_exists)
   {
      m_trade.OrderDelete(m_straddle_sell_ticket);
      Print("CNewsTrader: OCO - Buy filled, canceled Sell stop");
      m_straddle_sell_ticket = 0;
   }
   
   if(sell_filled && buy_exists)
   {
      m_trade.OrderDelete(m_straddle_buy_ticket);
      Print("CNewsTrader: OCO - Sell filled, canceled Buy stop");
      m_straddle_buy_ticket = 0;
   }
   
   // Check if straddle is done
   if(!buy_exists && !sell_exists && !buy_filled && !sell_filled)
   {
      m_straddle_active = false;
      m_straddle_buy_ticket = 0;
      m_straddle_sell_ticket = 0;
   }
}

//+------------------------------------------------------------------+
//| Track spike for pullback entry                                    |
//+------------------------------------------------------------------+
void CNewsTrader::TrackSpike(double price)
{
   if(m_spike_start_time == 0)
   {
      m_spike_start_time = TimeGMT();
      m_spike_high = price;
      m_spike_low = price;
   }
   
   if(price > m_spike_high)
      m_spike_high = price;
   if(price < m_spike_low)
      m_spike_low = price;
   
   // Detect spike if range > threshold
   double range = m_spike_high - m_spike_low;
   double threshold = 50 * _Point;  // 50 points minimum spike
   
   if(range > threshold)
      m_spike_detected = true;
}

//+------------------------------------------------------------------+
//| Check if pullback entry conditions met                            |
//+------------------------------------------------------------------+
bool CNewsTrader::IsPullbackEntry(double current_price)
{
   if(!m_spike_detected)
      return false;
   
   double range = m_spike_high - m_spike_low;
   double retrace_level = m_spike_high - range * m_pullback_retrace_pct;
   
   // For bullish spike pullback
   if(current_price <= retrace_level && current_price > m_spike_low)
      return true;
   
   // For bearish spike pullback
   retrace_level = m_spike_low + range * m_pullback_retrace_pct;
   if(current_price >= retrace_level && current_price < m_spike_high)
      return true;
   
   return false;
}

//+------------------------------------------------------------------+
//| Calculate lot size                                                |
//+------------------------------------------------------------------+
double CNewsTrader::CalculateLotSize(double sl_points)
{
   if(sl_points <= 0)
      return 0;
   
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double risk_amount = equity * m_news_risk_percent / 100.0;
   
   double tick_value = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_VALUE);
   double tick_size = SymbolInfoDouble(m_symbol, SYMBOL_TRADE_TICK_SIZE);
   
   if(tick_size <= 0 || tick_value <= 0)
      return 0;
   
   double point_value = tick_value / tick_size * _Point;
   double lot = risk_amount / (sl_points * point_value);
   
   // Normalize
   double min_lot = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MIN);
   double max_lot = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_MAX);
   double step = SymbolInfoDouble(m_symbol, SYMBOL_VOLUME_STEP);
   
   lot = MathFloor(lot / step) * step;
   lot = MathMax(min_lot, MathMin(max_lot, lot));
   
   return NormalizeDouble(lot, 2);
}

//+------------------------------------------------------------------+
//| Get current spread in pips                                        |
//+------------------------------------------------------------------+
double CNewsTrader::GetCurrentSpread()
{
   double spread = SymbolInfoInteger(m_symbol, SYMBOL_SPREAD) / 10.0;  // Convert to pips
   return spread;
}

//+------------------------------------------------------------------+
//| Check if spread acceptable for news trading                       |
//+------------------------------------------------------------------+
bool CNewsTrader::IsSpreadAcceptable()
{
   return GetCurrentSpread() <= m_max_spread_pips;
}

//+------------------------------------------------------------------+
//| Setup TP levels for position                                      |
//+------------------------------------------------------------------+
void CNewsTrader::SetupTPLevels(SNewsTradeSetup &setup, bool is_buy)
{
   double sl_distance = MathAbs(setup.entry_price - setup.stop_loss);
   
   if(is_buy)
   {
      setup.take_profit_1 = setup.entry_price + sl_distance * m_tp1_rr;
      setup.take_profit_2 = setup.entry_price + sl_distance * m_tp2_rr;
      setup.take_profit_3 = setup.entry_price + sl_distance * m_tp3_rr;
   }
   else
   {
      setup.take_profit_1 = setup.entry_price - sl_distance * m_tp1_rr;
      setup.take_profit_2 = setup.entry_price - sl_distance * m_tp2_rr;
      setup.take_profit_3 = setup.entry_price - sl_distance * m_tp3_rr;
   }
}

//+------------------------------------------------------------------+
//| Check if has active news trade                                    |
//+------------------------------------------------------------------+
bool CNewsTrader::HasActiveNewsTrade()
{
   // Check for straddle orders
   if(m_straddle_active)
      return true;
   
   // Check for any position from this EA
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(PositionSelectByTicket(PositionGetTicket(i)))
      {
         if(PositionGetInteger(POSITION_MAGIC) == m_magic)
         {
            string comment = PositionGetString(POSITION_COMMENT);
            if(StringFind(comment, "NEWS_") >= 0)
               return true;
         }
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Print setup details                                               |
//+------------------------------------------------------------------+
void CNewsTrader::PrintSetup(const SNewsTradeSetup &setup)
{
   Print("=== News Trade Setup ===");
   Print("Event: ", setup.event_name);
   Print("Time: ", TimeToString(setup.event_time, TIME_DATE | TIME_MINUTES));
   Print("Minutes to event: ", setup.minutes_to_event);
   Print("Mode: ", EnumToString(setup.mode));
   Print("Direction: ", EnumToString(setup.direction));
   Print("Entry: ", setup.entry_price);
   Print("SL: ", setup.stop_loss);
   Print("TP1: ", setup.take_profit_1);
   Print("Lot: ", setup.lot_size);
   Print("Valid: ", setup.is_valid);
   Print("Reason: ", setup.reason);
   Print("========================");
}

//+------------------------------------------------------------------+
//| Manage open trades (partials, trailing)                           |
//+------------------------------------------------------------------+
void CNewsTrader::ManageOpenTrades()
{
   ManageStraddle();
   
   // TODO: Add partial TP management
   // TODO: Add trailing stop logic
}

//+------------------------------------------------------------------+
