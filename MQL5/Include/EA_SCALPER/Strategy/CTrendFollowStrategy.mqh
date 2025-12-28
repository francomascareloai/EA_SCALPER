//+------------------------------------------------------------------+
//|                                       CTrendFollowStrategy.mqh   |
//|                         EA_SCALPER_XAUUSD - TrendFollow Module   |
//|                                  v1.0 - Pullback + Breakout      |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property strict

#include <Trade/Trade.mqh>

//+------------------------------------------------------------------+
//| Enums                                                            |
//+------------------------------------------------------------------+
enum ENUM_TREND_MODE
{
   TREND_MODE_PULLBACK,    // Wait for pullback to EMA
   TREND_MODE_BREAKOUT     // Wait for Donchian breakout
};

enum ENUM_TREND_DIRECTION
{
   TREND_NONE,
   TREND_BULLISH,
   TREND_BEARISH
};

//+------------------------------------------------------------------+
//| TrendFollow Signal Result                                        |
//+------------------------------------------------------------------+
struct STrendFollowSignal
{
   ENUM_SIGNAL_TYPE direction;       // BUY, SELL, NONE
   ENUM_TREND_MODE  mode;            // PULLBACK or BREAKOUT
   double           stop_loss;       // Calculated SL
   double           take_profit;     // Calculated TP
   double           entry_price;     // Suggested entry
   double           efficiency_ratio;// ER value
   double           confidence;      // 0-100
   string           reason;          // Why this signal
   bool             is_valid;        // Overall validity

   void Reset()
   {
      direction = SIGNAL_NONE;
      mode = TREND_MODE_PULLBACK;
      stop_loss = 0;
      take_profit = 0;
      entry_price = 0;
      efficiency_ratio = 0;
      confidence = 0;
      reason = "";
      is_valid = false;
   }
};

//+------------------------------------------------------------------+
//| CTrendFollowStrategy Class                                       |
//+------------------------------------------------------------------+
class CTrendFollowStrategy
{
private:
   string            m_symbol;
   ENUM_TIMEFRAMES   m_timeframe;
   bool              m_initialized;

   // Indicator handles
   int               m_ema_fast_handle;    // EMA 20
   int               m_ema_slow_handle;    // EMA 50
   int               m_ema_trend_handle;   // EMA 200 (trend filter)
   int               m_atr_handle;         // ATR for SL sizing

   // Donchian Channel (manual calculation)
   int               m_donchian_period;
   double            m_donchian_high;
   double            m_donchian_low;
   double            m_donchian_mid;

   // Parameters
   int               m_ema_fast_period;
   int               m_ema_slow_period;
   int               m_ema_trend_period;
   int               m_atr_period;
   double            m_er_threshold;       // Efficiency Ratio minimum
   double            m_pullback_atr_mult;  // Pullback zone = X * ATR
   double            m_sl_atr_mult;        // SL = X * ATR
   double            m_tp_rr;              // TP = SL * RR

   // Cached values
   double            m_last_ema_fast;
   double            m_last_ema_slow;
   double            m_last_ema_trend;
   double            m_last_atr;
   double            m_last_er;
   ENUM_TREND_DIRECTION m_current_trend;
   datetime          m_last_update;

   // Internal methods
   bool              UpdateIndicators();
   double            CalculateEfficiencyRatio(int period = 20);
   void              CalculateDonchian(int period);
   ENUM_TREND_DIRECTION DetectTrend();
   bool              IsInPullbackZone(ENUM_TREND_DIRECTION trend);
   bool              HasReversalCandle(ENUM_TREND_DIRECTION trend);
   double            FindSwingLow(int lookback = 10);
   double            FindSwingHigh(int lookback = 10);

public:
                     CTrendFollowStrategy();
                    ~CTrendFollowStrategy();

   // Initialization
   bool              Init(string symbol, ENUM_TIMEFRAMES tf);
   void              Deinit();

   // Configuration
   void              SetERThreshold(double threshold) { m_er_threshold = threshold; }
   void              SetPullbackATRMult(double mult)  { m_pullback_atr_mult = mult; }
   void              SetSLATRMult(double mult)        { m_sl_atr_mult = mult; }
   void              SetTPRR(double rr)               { m_tp_rr = rr; }
   void              SetDonchianPeriod(int period)    { m_donchian_period = period; }

   // Main signal generation
   STrendFollowSignal CheckPullbackEntry();
   STrendFollowSignal CheckBreakoutEntry();
   STrendFollowSignal GetBestSignal();  // Returns best of pullback/breakout

   // Getters
   double            GetEfficiencyRatio()    { return m_last_er; }
   bool              IsTrending()            { return m_last_er >= m_er_threshold; }
   ENUM_TREND_DIRECTION GetCurrentTrend()    { return m_current_trend; }
   double            GetATR()                { return m_last_atr; }
   double            GetDonchianHigh()       { return m_donchian_high; }
   double            GetDonchianLow()        { return m_donchian_low; }
};

//+------------------------------------------------------------------+
//| Constructor                                                       |
//+------------------------------------------------------------------+
CTrendFollowStrategy::CTrendFollowStrategy()
{
   m_symbol = "";
   m_timeframe = PERIOD_M15;
   m_initialized = false;

   m_ema_fast_handle = INVALID_HANDLE;
   m_ema_slow_handle = INVALID_HANDLE;
   m_ema_trend_handle = INVALID_HANDLE;
   m_atr_handle = INVALID_HANDLE;

   // Default parameters
   m_ema_fast_period = 20;
   m_ema_slow_period = 50;
   m_ema_trend_period = 200;
   m_atr_period = 14;
   m_donchian_period = 20;

   m_er_threshold = 0.30;        // 30% minimum for trending
   m_pullback_atr_mult = 0.5;    // Pullback zone = 0.5 ATR from EMA
   m_sl_atr_mult = 1.5;          // SL = 1.5 ATR
   m_tp_rr = 2.0;                // TP = 2R

   m_last_er = 0;
   m_current_trend = TREND_NONE;
   m_last_update = 0;
}

//+------------------------------------------------------------------+
//| Destructor                                                        |
//+------------------------------------------------------------------+
CTrendFollowStrategy::~CTrendFollowStrategy()
{
   Deinit();
}

//+------------------------------------------------------------------+
//| Initialize                                                        |
//+------------------------------------------------------------------+
bool CTrendFollowStrategy::Init(string symbol, ENUM_TIMEFRAMES tf)
{
   m_symbol = symbol;
   m_timeframe = tf;

   // Create indicator handles
   m_ema_fast_handle = iMA(symbol, tf, m_ema_fast_period, 0, MODE_EMA, PRICE_CLOSE);
   m_ema_slow_handle = iMA(symbol, tf, m_ema_slow_period, 0, MODE_EMA, PRICE_CLOSE);
   m_ema_trend_handle = iMA(symbol, tf, m_ema_trend_period, 0, MODE_EMA, PRICE_CLOSE);
   m_atr_handle = iATR(symbol, tf, m_atr_period);

   if(m_ema_fast_handle == INVALID_HANDLE ||
      m_ema_slow_handle == INVALID_HANDLE ||
      m_ema_trend_handle == INVALID_HANDLE ||
      m_atr_handle == INVALID_HANDLE)
   {
      Print("[TrendFollow] ERROR: Failed to create indicator handles");
      return false;
   }

   m_initialized = true;
   Print("[TrendFollow] Initialized on ", symbol, " ", EnumToString(tf));
   return true;
}

//+------------------------------------------------------------------+
//| Deinitialize                                                      |
//+------------------------------------------------------------------+
void CTrendFollowStrategy::Deinit()
{
   if(m_ema_fast_handle != INVALID_HANDLE)  IndicatorRelease(m_ema_fast_handle);
   if(m_ema_slow_handle != INVALID_HANDLE)  IndicatorRelease(m_ema_slow_handle);
   if(m_ema_trend_handle != INVALID_HANDLE) IndicatorRelease(m_ema_trend_handle);
   if(m_atr_handle != INVALID_HANDLE)       IndicatorRelease(m_atr_handle);

   m_ema_fast_handle = INVALID_HANDLE;
   m_ema_slow_handle = INVALID_HANDLE;
   m_ema_trend_handle = INVALID_HANDLE;
   m_atr_handle = INVALID_HANDLE;
   m_initialized = false;
}

//+------------------------------------------------------------------+
//| Update Indicators                                                 |
//+------------------------------------------------------------------+
bool CTrendFollowStrategy::UpdateIndicators()
{
   if(!m_initialized) return false;

   // Cache for 1 bar
   datetime current_bar = iTime(m_symbol, m_timeframe, 0);
   if(current_bar == m_last_update) return true;

   double ema_fast[], ema_slow[], ema_trend[], atr[];

   if(CopyBuffer(m_ema_fast_handle, 0, 0, 3, ema_fast) < 3) return false;
   if(CopyBuffer(m_ema_slow_handle, 0, 0, 3, ema_slow) < 3) return false;
   if(CopyBuffer(m_ema_trend_handle, 0, 0, 3, ema_trend) < 3) return false;
   if(CopyBuffer(m_atr_handle, 0, 0, 3, atr) < 3) return false;

   ArraySetAsSeries(ema_fast, true);
   ArraySetAsSeries(ema_slow, true);
   ArraySetAsSeries(ema_trend, true);
   ArraySetAsSeries(atr, true);

   m_last_ema_fast = ema_fast[1];   // Use completed bar
   m_last_ema_slow = ema_slow[1];
   m_last_ema_trend = ema_trend[1];
   m_last_atr = atr[1];

   // Calculate ER and Donchian
   m_last_er = CalculateEfficiencyRatio(20);
   CalculateDonchian(m_donchian_period);

   // Detect trend
   m_current_trend = DetectTrend();

   m_last_update = current_bar;
   return true;
}

//+------------------------------------------------------------------+
//| Calculate Efficiency Ratio (Kaufman)                              |
//| ER = |Net Change| / Sum(|Individual Changes|)                     |
//| Higher ER = More trending, Lower ER = More choppy                 |
//+------------------------------------------------------------------+
double CTrendFollowStrategy::CalculateEfficiencyRatio(int period)
{
   double close[];
   if(CopyClose(m_symbol, m_timeframe, 0, period + 1, close) < period + 1)
      return 0;

   ArraySetAsSeries(close, true);

   // Net change (direction)
   double net_change = MathAbs(close[0] - close[period]);

   // Sum of absolute changes (volatility)
   double sum_changes = 0;
   for(int i = 0; i < period; i++)
      sum_changes += MathAbs(close[i] - close[i + 1]);

   if(sum_changes == 0) return 0;

   return net_change / sum_changes;
}

//+------------------------------------------------------------------+
//| Calculate Donchian Channel                                        |
//+------------------------------------------------------------------+
void CTrendFollowStrategy::CalculateDonchian(int period)
{
   double high[], low[];
   if(CopyHigh(m_symbol, m_timeframe, 1, period, high) < period) return;
   if(CopyLow(m_symbol, m_timeframe, 1, period, low) < period) return;

   // Validate arrays before accessing
   if(ArraySize(high) == 0 || ArraySize(low) == 0) return;
   int maxIdx = ArrayMaximum(high);
   int minIdx = ArrayMinimum(low);
   if(maxIdx < 0 || minIdx < 0) return;

   m_donchian_high = high[maxIdx];
   m_donchian_low = low[minIdx];
   m_donchian_mid = (m_donchian_high + m_donchian_low) / 2;
}

//+------------------------------------------------------------------+
//| Detect Current Trend                                              |
//+------------------------------------------------------------------+
ENUM_TREND_DIRECTION CTrendFollowStrategy::DetectTrend()
{
   // Trend hierarchy: Fast > Slow > Trend EMA
   // Bullish: Fast > Slow > Trend + Price > Fast
   // Bearish: Fast < Slow < Trend + Price < Fast

   double bid = SymbolInfoDouble(m_symbol, SYMBOL_BID);

   bool fast_above_slow = m_last_ema_fast > m_last_ema_slow;
   bool slow_above_trend = m_last_ema_slow > m_last_ema_trend;
   bool price_above_fast = bid > m_last_ema_fast;

   bool fast_below_slow = m_last_ema_fast < m_last_ema_slow;
   bool slow_below_trend = m_last_ema_slow < m_last_ema_trend;
   bool price_below_fast = bid < m_last_ema_fast;

   if(fast_above_slow && slow_above_trend)
      return TREND_BULLISH;

   if(fast_below_slow && slow_below_trend)
      return TREND_BEARISH;

   return TREND_NONE;
}

//+------------------------------------------------------------------+
//| Check if price is in pullback zone                                |
//+------------------------------------------------------------------+
bool CTrendFollowStrategy::IsInPullbackZone(ENUM_TREND_DIRECTION trend)
{
   double bid = SymbolInfoDouble(m_symbol, SYMBOL_BID);
   double zone = m_pullback_atr_mult * m_last_atr;

   if(trend == TREND_BULLISH)
   {
      // Pullback zone: between EMA fast and EMA fast - zone
      return (bid >= m_last_ema_fast - zone && bid <= m_last_ema_fast + zone * 0.3);
   }
   else if(trend == TREND_BEARISH)
   {
      // Pullback zone: between EMA fast and EMA fast + zone
      return (bid <= m_last_ema_fast + zone && bid >= m_last_ema_fast - zone * 0.3);
   }

   return false;
}

//+------------------------------------------------------------------+
//| Check for reversal candle pattern                                 |
//+------------------------------------------------------------------+
bool CTrendFollowStrategy::HasReversalCandle(ENUM_TREND_DIRECTION trend)
{
   MqlRates rates[];
   if(CopyRates(m_symbol, m_timeframe, 0, 3, rates) < 3) return false;
   ArraySetAsSeries(rates, true);

   // Use completed bar [1]
   double body = rates[1].close - rates[1].open;
   double range = rates[1].high - rates[1].low;
   double body_pct = range > 0 ? MathAbs(body) / range : 0;

   if(trend == TREND_BULLISH)
   {
      // Bullish candle with body > 50% of range
      // And close near high
      bool bullish_body = body > 0;
      bool strong_close = (rates[1].close - rates[1].low) > range * 0.6;
      return bullish_body && strong_close && body_pct > 0.5;
   }
   else if(trend == TREND_BEARISH)
   {
      // Bearish candle with body > 50% of range
      // And close near low
      bool bearish_body = body < 0;
      bool strong_close = (rates[1].high - rates[1].close) > range * 0.6;
      return bearish_body && strong_close && body_pct > 0.5;
   }

   return false;
}

//+------------------------------------------------------------------+
//| Find recent swing low                                             |
//+------------------------------------------------------------------+
double CTrendFollowStrategy::FindSwingLow(int lookback)
{
   double low[];
   if(CopyLow(m_symbol, m_timeframe, 1, lookback, low) < lookback)
      return 0;

   return low[ArrayMinimum(low)];
}

//+------------------------------------------------------------------+
//| Find recent swing high                                            |
//+------------------------------------------------------------------+
double CTrendFollowStrategy::FindSwingHigh(int lookback)
{
   double high[];
   if(CopyHigh(m_symbol, m_timeframe, 1, lookback, high) < lookback)
      return 0;

   return high[ArrayMaximum(high)];
}

//+------------------------------------------------------------------+
//| Check for Pullback Entry                                          |
//+------------------------------------------------------------------+
STrendFollowSignal CTrendFollowStrategy::CheckPullbackEntry()
{
   STrendFollowSignal signal;
   signal.Reset();
   signal.mode = TREND_MODE_PULLBACK;

   if(!UpdateIndicators()) return signal;

   // Check ER threshold
   if(m_last_er < m_er_threshold)
   {
      signal.reason = StringFormat("ER %.2f < %.2f (choppy)", m_last_er, m_er_threshold);
      return signal;
   }

   // Check trend
   if(m_current_trend == TREND_NONE)
   {
      signal.reason = "No clear trend (EMAs not aligned)";
      return signal;
   }

   // Check pullback zone
   if(!IsInPullbackZone(m_current_trend))
   {
      signal.reason = "Price not in pullback zone";
      return signal;
   }

   // Check reversal candle
   if(!HasReversalCandle(m_current_trend))
   {
      signal.reason = "No reversal candle pattern";
      return signal;
   }

   // VALID SIGNAL!
   double bid = SymbolInfoDouble(m_symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(m_symbol, SYMBOL_ASK);

   if(m_current_trend == TREND_BULLISH)
   {
      signal.direction = SIGNAL_BUY;
      signal.entry_price = ask;
      // Validate swing low before using for SL calculation
      double swing_low = FindSwingLow(10);
      if(swing_low <= 0)
      {
         signal.reason = "Failed to find swing low for SL";
         return signal;
      }
      signal.stop_loss = swing_low - m_last_atr * 0.2;
      double sl_distance = signal.entry_price - signal.stop_loss;
      signal.take_profit = signal.entry_price + sl_distance * m_tp_rr;
   }
   else // BEARISH
   {
      signal.direction = SIGNAL_SELL;
      signal.entry_price = bid;
      // Validate swing high before using for SL calculation
      double swing_high = FindSwingHigh(10);
      if(swing_high <= 0)
      {
         signal.reason = "Failed to find swing high for SL";
         return signal;
      }
      signal.stop_loss = swing_high + m_last_atr * 0.2;
      double sl_distance = signal.stop_loss - signal.entry_price;
      signal.take_profit = signal.entry_price - sl_distance * m_tp_rr;
   }

   signal.efficiency_ratio = m_last_er;
   signal.confidence = MathMin(100, m_last_er * 200);  // ER 0.5 = 100%
   signal.reason = StringFormat("Pullback in %s trend, ER=%.2f",
                                m_current_trend == TREND_BULLISH ? "BULL" : "BEAR",
                                m_last_er);
   signal.is_valid = true;

   return signal;
}

//+------------------------------------------------------------------+
//| Check for Breakout Entry                                          |
//+------------------------------------------------------------------+
STrendFollowSignal CTrendFollowStrategy::CheckBreakoutEntry()
{
   STrendFollowSignal signal;
   signal.Reset();
   signal.mode = TREND_MODE_BREAKOUT;

   if(!UpdateIndicators()) return signal;

   // Check ER threshold (for breakouts, slightly lower OK)
   if(m_last_er < m_er_threshold * 0.8)
   {
      signal.reason = StringFormat("ER %.2f too low for breakout", m_last_er);
      return signal;
   }

   MqlRates rates[];
   if(CopyRates(m_symbol, m_timeframe, 0, 2, rates) < 2) return signal;
   ArraySetAsSeries(rates, true);

   double prev_close = rates[1].close;
   double prev_high = rates[1].high;
   double prev_low = rates[1].low;

   // Bullish breakout: close above Donchian high
   bool bullish_breakout = prev_close > m_donchian_high && prev_high > m_donchian_high;

   // Bearish breakout: close below Donchian low
   bool bearish_breakout = prev_close < m_donchian_low && prev_low < m_donchian_low;

   if(!bullish_breakout && !bearish_breakout)
   {
      signal.reason = "No Donchian breakout";
      return signal;
   }

   // Confirm with trend
   if(bullish_breakout && m_current_trend == TREND_BEARISH)
   {
      signal.reason = "Bullish breakout against bearish trend";
      return signal;
   }
   if(bearish_breakout && m_current_trend == TREND_BULLISH)
   {
      signal.reason = "Bearish breakout against bullish trend";
      return signal;
   }

   // Validate Donchian channel values before using for SL
   if(m_donchian_low <= 0 || m_donchian_high <= 0)
   {
      signal.reason = "Invalid Donchian channel values";
      return signal;
   }

   // VALID SIGNAL!
   double bid = SymbolInfoDouble(m_symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(m_symbol, SYMBOL_ASK);

   if(bullish_breakout)
   {
      signal.direction = SIGNAL_BUY;
      signal.entry_price = ask;
      signal.stop_loss = m_donchian_low;
      double sl_distance = signal.entry_price - signal.stop_loss;
      signal.take_profit = signal.entry_price + sl_distance * m_tp_rr;
   }
   else // bearish_breakout
   {
      signal.direction = SIGNAL_SELL;
      signal.entry_price = bid;
      signal.stop_loss = m_donchian_high;
      double sl_distance = signal.stop_loss - signal.entry_price;
      signal.take_profit = signal.entry_price - sl_distance * m_tp_rr;
   }

   signal.efficiency_ratio = m_last_er;
   signal.confidence = MathMin(100, m_last_er * 180);
   signal.reason = StringFormat("Donchian %s breakout, ER=%.2f",
                                bullish_breakout ? "HIGH" : "LOW",
                                m_last_er);
   signal.is_valid = true;

   return signal;
}

//+------------------------------------------------------------------+
//| Get Best Signal (Pullback preferred, then Breakout)               |
//+------------------------------------------------------------------+
STrendFollowSignal CTrendFollowStrategy::GetBestSignal()
{
   // Pullback has priority (higher probability)
   STrendFollowSignal pullback = CheckPullbackEntry();
   if(pullback.is_valid)
      return pullback;

   // Try breakout
   STrendFollowSignal breakout = CheckBreakoutEntry();
   if(breakout.is_valid)
      return breakout;

   // No valid signal
   STrendFollowSignal none;
   none.Reset();
   none.reason = "No TrendFollow signal";
   return none;
}

//+------------------------------------------------------------------+
