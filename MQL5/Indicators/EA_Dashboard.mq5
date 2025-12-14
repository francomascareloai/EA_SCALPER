//+------------------------------------------------------------------+
//|                                                 EA_Dashboard.mq5 |
//|                          EA_SCALPER_XAUUSD - Visual Dashboard     |
//|                                                                  |
//|  Painel visual com todos os filtros do EA:                       |
//|  - Session (Asian/London/NY)                                     |
//|  - Regime (Hurst/Entropy)                                        |
//|  - Footprint (Delta/Imbalance)                                   |
//|  - Spread & Risk Status                                          |
//|  - Confluence Score                                              |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

// Inputs
input group "=== Panel Settings ==="
input int      InpPanelX           = 10;       // Panel X Position
input int      InpPanelY           = 30;       // Panel Y Position
input int      InpFontSize         = 9;        // Font Size
input color    InpBackgroundColor  = C'25,25,35';  // Background Color
input color    InpTextColor        = clrWhite;     // Text Color
input color    InpBullColor        = clrLimeGreen; // Bullish Color
input color    InpBearColor        = clrCrimson;   // Bearish Color
input color    InpNeutralColor     = clrGold;      // Neutral Color
input color    InpBlockedColor     = clrGray;      // Blocked Color

input group "=== Filter Settings ==="
input int      InpGMTOffset        = 0;        // Broker GMT Offset
input int      InpMaxSpread        = 80;       // Max Spread (points)
input double   InpClusterSize      = 0.50;     // Footprint Cluster Size

input group "=== Regime Settings ==="
input int      InpHurstPeriod      = 100;      // Hurst Calculation Period
input int      InpATRPeriod        = 14;       // ATR Period

// Panel dimensions
#define PANEL_WIDTH     220
#define ROW_HEIGHT      18
#define HEADER_HEIGHT   22
#define SECTION_GAP     5

// Object prefix
#define OBJ_PREFIX      "EADash_"

// Session enum
enum ENUM_SESSION_TYPE {
   SESS_ASIAN = 0,
   SESS_LONDON,
   SESS_OVERLAP,
   SESS_NY,
   SESS_LATE_NY,
   SESS_CLOSED
};

// Regime enum
enum ENUM_REGIME_TYPE {
   REG_TRENDING = 0,
   REG_REVERTING,
   REG_RANDOM,
   REG_UNKNOWN
};

// Global state
int g_atr_handle = INVALID_HANDLE;
int g_rsi_handle = INVALID_HANDLE;
datetime g_lastUpdate = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+------------------------------------------------------------------+
int OnInit()
{
   g_atr_handle = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);
   g_rsi_handle = iRSI(_Symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
   
   if(g_atr_handle == INVALID_HANDLE || g_rsi_handle == INVALID_HANDLE)
   {
      Print("EA_Dashboard: Failed to create indicator handles");
      return INIT_FAILED;
   }
   
   CreatePanel();
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, OBJ_PREFIX);
   
   if(g_atr_handle != INVALID_HANDLE)
      IndicatorRelease(g_atr_handle);
   if(g_rsi_handle != INVALID_HANDLE)
      IndicatorRelease(g_rsi_handle);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                               |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   // Update panel every second
   if(TimeCurrent() - g_lastUpdate >= 1)
   {
      UpdatePanel();
      g_lastUpdate = TimeCurrent();
   }
   
   return rates_total;
}

//+------------------------------------------------------------------+
//| Chart event handler                                               |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if(id == CHARTEVENT_CHART_CHANGE)
   {
      UpdatePanel();
   }
}

//+------------------------------------------------------------------+
//| Create panel objects                                              |
//+------------------------------------------------------------------+
void CreatePanel()
{
   int y = InpPanelY;
   int totalRows = 16;
   int panelHeight = HEADER_HEIGHT + (totalRows * ROW_HEIGHT) + (4 * SECTION_GAP) + 10;
   
   // Background
   CreateRectangle(OBJ_PREFIX + "BG", InpPanelX, y, PANEL_WIDTH, panelHeight, InpBackgroundColor);
   
   // Header
   CreateLabel(OBJ_PREFIX + "Header", InpPanelX + 5, y + 3, "EA SCALPER DASHBOARD", InpNeutralColor, InpFontSize + 2, true);
   y += HEADER_HEIGHT;
   
   // Separator
   CreateLine(OBJ_PREFIX + "Sep1", InpPanelX + 5, y, PANEL_WIDTH - 10, clrDimGray);
   y += 5;
   
   // === SESSION SECTION ===
   CreateLabel(OBJ_PREFIX + "SessTitle", InpPanelX + 5, y, "SESSION", clrDodgerBlue, InpFontSize, true);
   y += ROW_HEIGHT;
   
   CreateLabel(OBJ_PREFIX + "SessLabel", InpPanelX + 10, y, "Current:", InpTextColor, InpFontSize, false);
   CreateLabel(OBJ_PREFIX + "SessValue", InpPanelX + 80, y, "---", InpTextColor, InpFontSize, false);
   y += ROW_HEIGHT;
   
   CreateLabel(OBJ_PREFIX + "SessQualLabel", InpPanelX + 10, y, "Quality:", InpTextColor, InpFontSize, false);
   CreateLabel(OBJ_PREFIX + "SessQualValue", InpPanelX + 80, y, "---", InpTextColor, InpFontSize, false);
   y += ROW_HEIGHT;
   
   CreateLabel(OBJ_PREFIX + "TimeLabel", InpPanelX + 10, y, "GMT Time:", InpTextColor, InpFontSize, false);
   CreateLabel(OBJ_PREFIX + "TimeValue", InpPanelX + 80, y, "---", InpTextColor, InpFontSize, false);
   y += ROW_HEIGHT + SECTION_GAP;
   
   // === REGIME SECTION ===
   CreateLabel(OBJ_PREFIX + "RegTitle", InpPanelX + 5, y, "REGIME", clrDodgerBlue, InpFontSize, true);
   y += ROW_HEIGHT;
   
   CreateLabel(OBJ_PREFIX + "RegLabel", InpPanelX + 10, y, "Type:", InpTextColor, InpFontSize, false);
   CreateLabel(OBJ_PREFIX + "RegValue", InpPanelX + 80, y, "---", InpTextColor, InpFontSize, false);
   y += ROW_HEIGHT;
   
   CreateLabel(OBJ_PREFIX + "HurstLabel", InpPanelX + 10, y, "Hurst:", InpTextColor, InpFontSize, false);
   CreateLabel(OBJ_PREFIX + "HurstValue", InpPanelX + 80, y, "---", InpTextColor, InpFontSize, false);
   y += ROW_HEIGHT;
   
   CreateLabel(OBJ_PREFIX + "VolatLabel", InpPanelX + 10, y, "Volatility:", InpTextColor, InpFontSize, false);
   CreateLabel(OBJ_PREFIX + "VolatValue", InpPanelX + 80, y, "---", InpTextColor, InpFontSize, false);
   y += ROW_HEIGHT + SECTION_GAP;
   
   // === FOOTPRINT SECTION ===
   CreateLabel(OBJ_PREFIX + "FPTitle", InpPanelX + 5, y, "ORDER FLOW", clrDodgerBlue, InpFontSize, true);
   y += ROW_HEIGHT;
   
   CreateLabel(OBJ_PREFIX + "DeltaLabel", InpPanelX + 10, y, "Delta:", InpTextColor, InpFontSize, false);
   CreateLabel(OBJ_PREFIX + "DeltaValue", InpPanelX + 80, y, "---", InpTextColor, InpFontSize, false);
   y += ROW_HEIGHT;
   
   CreateLabel(OBJ_PREFIX + "CVDLabel", InpPanelX + 10, y, "CVD Trend:", InpTextColor, InpFontSize, false);
   CreateLabel(OBJ_PREFIX + "CVDValue", InpPanelX + 80, y, "---", InpTextColor, InpFontSize, false);
   y += ROW_HEIGHT;
   
   CreateLabel(OBJ_PREFIX + "ImbLabel", InpPanelX + 10, y, "Imbalance:", InpTextColor, InpFontSize, false);
   CreateLabel(OBJ_PREFIX + "ImbValue", InpPanelX + 80, y, "---", InpTextColor, InpFontSize, false);
   y += ROW_HEIGHT + SECTION_GAP;
   
   // === MARKET CONDITIONS ===
   CreateLabel(OBJ_PREFIX + "MktTitle", InpPanelX + 5, y, "MARKET", clrDodgerBlue, InpFontSize, true);
   y += ROW_HEIGHT;
   
   CreateLabel(OBJ_PREFIX + "SpreadLabel", InpPanelX + 10, y, "Spread:", InpTextColor, InpFontSize, false);
   CreateLabel(OBJ_PREFIX + "SpreadValue", InpPanelX + 80, y, "---", InpTextColor, InpFontSize, false);
   y += ROW_HEIGHT;
   
   CreateLabel(OBJ_PREFIX + "ATRLabel", InpPanelX + 10, y, "ATR:", InpTextColor, InpFontSize, false);
   CreateLabel(OBJ_PREFIX + "ATRValue", InpPanelX + 80, y, "---", InpTextColor, InpFontSize, false);
   y += ROW_HEIGHT;
   
   CreateLabel(OBJ_PREFIX + "RSILabel", InpPanelX + 10, y, "RSI(14):", InpTextColor, InpFontSize, false);
   CreateLabel(OBJ_PREFIX + "RSIValue", InpPanelX + 80, y, "---", InpTextColor, InpFontSize, false);
   y += ROW_HEIGHT + SECTION_GAP;
   
   // === SIGNAL SECTION ===
   CreateLabel(OBJ_PREFIX + "SigTitle", InpPanelX + 5, y, "SIGNAL", clrDodgerBlue, InpFontSize, true);
   y += ROW_HEIGHT;
   
   CreateLabel(OBJ_PREFIX + "BiasLabel", InpPanelX + 10, y, "Bias:", InpTextColor, InpFontSize, false);
   CreateLabel(OBJ_PREFIX + "BiasValue", InpPanelX + 80, y, "---", InpTextColor, InpFontSize, false);
   y += ROW_HEIGHT;
   
   CreateLabel(OBJ_PREFIX + "ConfLabel", InpPanelX + 10, y, "Confluence:", InpTextColor, InpFontSize, false);
   CreateLabel(OBJ_PREFIX + "ConfValue", InpPanelX + 80, y, "---", InpTextColor, InpFontSize, false);
   y += ROW_HEIGHT;
   
   // Trade Status
   CreateLabel(OBJ_PREFIX + "TradeLabel", InpPanelX + 10, y, "Trade:", InpTextColor, InpFontSize, false);
   CreateLabel(OBJ_PREFIX + "TradeValue", InpPanelX + 80, y, "---", InpTextColor, InpFontSize, false);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Update panel values                                               |
//+------------------------------------------------------------------+
void UpdatePanel()
{
   // === SESSION ===
   ENUM_SESSION_TYPE sess = GetCurrentSession();
   string sessName = GetSessionName(sess);
   color sessColor = GetSessionColor(sess);
   string sessQual = GetSessionQuality(sess);
   
   UpdateLabel(OBJ_PREFIX + "SessValue", sessName, sessColor);
   UpdateLabel(OBJ_PREFIX + "SessQualValue", sessQual, sessColor);
   
   // GMT Time
   datetime gmtTime = TimeGMT();
   MqlDateTime dt;
   TimeToStruct(gmtTime, dt);
   string timeStr = StringFormat("%02d:%02d GMT", dt.hour, dt.min);
   UpdateLabel(OBJ_PREFIX + "TimeValue", timeStr, InpTextColor);
   
   // === REGIME ===
   double hurst = CalculateSimpleHurst(InpHurstPeriod);
   ENUM_REGIME_TYPE regime = ClassifyRegime(hurst);
   string regName = GetRegimeName(regime);
   color regColor = GetRegimeColor(regime);
   
   UpdateLabel(OBJ_PREFIX + "RegValue", regName, regColor);
   UpdateLabel(OBJ_PREFIX + "HurstValue", DoubleToString(hurst, 3), regColor);
   
   // Volatility (ATR)
   double atr[];
   ArraySetAsSeries(atr, true);
   if(CopyBuffer(g_atr_handle, 0, 0, 1, atr) > 0)
   {
      string volStr = DoubleToString(atr[0], (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
      UpdateLabel(OBJ_PREFIX + "VolatValue", volStr, InpTextColor);
   }
   
   // === FOOTPRINT ===
   long delta = CalculateBarDelta(0);
   string deltaStr = (delta >= 0 ? "+" : "") + IntegerToString(delta);
   color deltaColor = (delta > 0) ? InpBullColor : (delta < 0) ? InpBearColor : InpNeutralColor;
   UpdateLabel(OBJ_PREFIX + "DeltaValue", deltaStr, deltaColor);
   
   // CVD Trend (compare last 3 bars)
   long delta1 = CalculateBarDelta(1);
   long delta2 = CalculateBarDelta(2);
   string cvdTrend = "FLAT";
   color cvdColor = InpNeutralColor;
   if(delta > delta1 && delta1 > delta2)
   {
      cvdTrend = "RISING";
      cvdColor = InpBullColor;
   }
   else if(delta < delta1 && delta1 < delta2)
   {
      cvdTrend = "FALLING";
      cvdColor = InpBearColor;
   }
   UpdateLabel(OBJ_PREFIX + "CVDValue", cvdTrend, cvdColor);
   
   // Imbalance (simplified)
   string imbStr = "NONE";
   color imbColor = InpNeutralColor;
   if(delta > 500)
   {
      imbStr = "BUY PRESSURE";
      imbColor = InpBullColor;
   }
   else if(delta < -500)
   {
      imbStr = "SELL PRESSURE";
      imbColor = InpBearColor;
   }
   UpdateLabel(OBJ_PREFIX + "ImbValue", imbStr, imbColor);
   
   // === MARKET ===
   int spreadPoints = (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   string spreadStr = IntegerToString(spreadPoints) + " pts";
   color spreadColor = (spreadPoints <= InpMaxSpread) ? InpBullColor : InpBearColor;
   UpdateLabel(OBJ_PREFIX + "SpreadValue", spreadStr, spreadColor);
   
   // ATR
   if(CopyBuffer(g_atr_handle, 0, 0, 1, atr) > 0)
   {
      UpdateLabel(OBJ_PREFIX + "ATRValue", DoubleToString(atr[0], 2), InpTextColor);
   }
   
   // RSI
   double rsi[];
   ArraySetAsSeries(rsi, true);
   if(CopyBuffer(g_rsi_handle, 0, 0, 1, rsi) > 0)
   {
      color rsiColor = InpTextColor;
      if(rsi[0] > 70) rsiColor = InpBearColor;      // Overbought
      else if(rsi[0] < 30) rsiColor = InpBullColor; // Oversold
      UpdateLabel(OBJ_PREFIX + "RSIValue", DoubleToString(rsi[0], 1), rsiColor);
   }
   
   // === SIGNAL ===
   // Bias calculation (simplified)
   string bias = "NEUTRAL";
   color biasColor = InpNeutralColor;
   int bullScore = 0;
   int bearScore = 0;
   
   // Session bias
   if(sess == SESS_LONDON || sess == SESS_OVERLAP) bullScore += 10;
   
   // Regime bias
   if(regime == REG_TRENDING) bullScore += 10;
   else if(regime == REG_RANDOM) bearScore += 20;
   
   // Delta bias
   if(delta > 200) bullScore += 15;
   else if(delta < -200) bearScore += 15;
   
   // RSI bias
   if(CopyBuffer(g_rsi_handle, 0, 0, 1, rsi) > 0)
   {
      if(rsi[0] < 40) bullScore += 10;
      else if(rsi[0] > 60) bearScore += 10;
   }
   
   // Spread bias
   if(spreadPoints > InpMaxSpread) bearScore += 20;
   
   if(bullScore > bearScore + 10)
   {
      bias = "BULLISH";
      biasColor = InpBullColor;
   }
   else if(bearScore > bullScore + 10)
   {
      bias = "BEARISH";
      biasColor = InpBearColor;
   }
   
   UpdateLabel(OBJ_PREFIX + "BiasValue", bias, biasColor);
   
   // Confluence score
   int confScore = MathMax(bullScore, bearScore);
   string confStr = IntegerToString(confScore) + "/100";
   color confColor = InpNeutralColor;
   if(confScore >= 50) confColor = InpBullColor;
   else if(confScore < 30) confColor = InpBearColor;
   UpdateLabel(OBJ_PREFIX + "ConfValue", confStr, confColor);
   
   // Trade status
   string tradeStatus = "WAIT";
   color tradeColor = InpNeutralColor;
   
   bool sessionOK = (sess == SESS_LONDON || sess == SESS_OVERLAP || sess == SESS_NY);
   bool regimeOK = (regime != REG_RANDOM);
   bool spreadOK = (spreadPoints <= InpMaxSpread);
   
   if(sessionOK && regimeOK && spreadOK && confScore >= 40)
   {
      tradeStatus = "READY";
      tradeColor = InpBullColor;
   }
   else if(!sessionOK)
   {
      tradeStatus = "SESSION";
      tradeColor = InpBlockedColor;
   }
   else if(!regimeOK)
   {
      tradeStatus = "REGIME";
      tradeColor = InpBearColor;
   }
   else if(!spreadOK)
   {
      tradeStatus = "SPREAD";
      tradeColor = InpBearColor;
   }
   
   UpdateLabel(OBJ_PREFIX + "TradeValue", tradeStatus, tradeColor);
   
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Get current session                                               |
//+------------------------------------------------------------------+
ENUM_SESSION_TYPE GetCurrentSession()
{
   datetime gmtTime = TimeGMT();
   MqlDateTime dt;
   TimeToStruct(gmtTime, dt);
   
   int hour = dt.hour;
   int dayOfWeek = dt.day_of_week;
   
   // Weekend
   if(dayOfWeek == 0 || dayOfWeek == 6)
      return SESS_CLOSED;
   
   // Session times (GMT)
   if(hour >= 0 && hour < 7)
      return SESS_ASIAN;
   else if(hour >= 7 && hour < 12)
      return SESS_LONDON;
   else if(hour >= 12 && hour < 15)
      return SESS_OVERLAP;
   else if(hour >= 15 && hour < 17)
      return SESS_NY;
   else if(hour >= 17 && hour < 21)
      return SESS_LATE_NY;
   else
      return SESS_CLOSED;
}

//+------------------------------------------------------------------+
//| Get session name                                                  |
//+------------------------------------------------------------------+
string GetSessionName(ENUM_SESSION_TYPE sess)
{
   switch(sess)
   {
      case SESS_ASIAN:    return "ASIAN";
      case SESS_LONDON:   return "LONDON";
      case SESS_OVERLAP:  return "OVERLAP";
      case SESS_NY:       return "NEW YORK";
      case SESS_LATE_NY:  return "LATE NY";
      case SESS_CLOSED:   return "CLOSED";
      default:            return "UNKNOWN";
   }
}

//+------------------------------------------------------------------+
//| Get session color                                                 |
//+------------------------------------------------------------------+
color GetSessionColor(ENUM_SESSION_TYPE sess)
{
   switch(sess)
   {
      case SESS_ASIAN:    return InpNeutralColor;
      case SESS_LONDON:   return InpBullColor;
      case SESS_OVERLAP:  return clrDeepSkyBlue;
      case SESS_NY:       return InpBullColor;
      case SESS_LATE_NY:  return InpNeutralColor;
      case SESS_CLOSED:   return InpBlockedColor;
      default:            return InpBlockedColor;
   }
}

//+------------------------------------------------------------------+
//| Get session quality                                               |
//+------------------------------------------------------------------+
string GetSessionQuality(ENUM_SESSION_TYPE sess)
{
   switch(sess)
   {
      case SESS_ASIAN:    return "LOW";
      case SESS_LONDON:   return "HIGH";
      case SESS_OVERLAP:  return "PRIME";
      case SESS_NY:       return "MEDIUM";
      case SESS_LATE_NY:  return "LOW";
      case SESS_CLOSED:   return "BLOCKED";
      default:            return "BLOCKED";
   }
}

//+------------------------------------------------------------------+
//| Calculate simple Hurst exponent (R/S method simplified)           |
//+------------------------------------------------------------------+
double CalculateSimpleHurst(int period)
{
   double close[];
   ArraySetAsSeries(close, true);
   
   if(CopyClose(_Symbol, PERIOD_CURRENT, 0, period, close) < period)
      return 0.5;
   
   // Calculate returns
   double returns[];
   ArrayResize(returns, period - 1);
   for(int i = 0; i < period - 1; i++)
   {
      if(close[i + 1] > 0)
         returns[i] = MathLog(close[i] / close[i + 1]);
      else
         returns[i] = 0;
   }
   
   // Calculate mean
   double sum = 0;
   for(int i = 0; i < period - 1; i++)
      sum += returns[i];
   double mean = sum / (period - 1);
   
   // Calculate cumulative deviations
   double cumDev[];
   ArrayResize(cumDev, period - 1);
   double cumSum = 0;
   double maxDev = -DBL_MAX;
   double minDev = DBL_MAX;
   
   for(int i = 0; i < period - 1; i++)
   {
      cumSum += (returns[i] - mean);
      cumDev[i] = cumSum;
      if(cumDev[i] > maxDev) maxDev = cumDev[i];
      if(cumDev[i] < minDev) minDev = cumDev[i];
   }
   
   double range = maxDev - minDev;
   
   // Calculate standard deviation
   double sqSum = 0;
   for(int i = 0; i < period - 1; i++)
      sqSum += MathPow(returns[i] - mean, 2);
   double stdDev = MathSqrt(sqSum / (period - 1));
   
   if(stdDev <= 0 || range <= 0)
      return 0.5;
   
   // R/S statistic
   double rs = range / stdDev;
   
   // Hurst = log(R/S) / log(n)
   double hurst = MathLog(rs) / MathLog((double)(period - 1));
   
   // Clamp to valid range
   if(hurst < 0) hurst = 0;
   if(hurst > 1) hurst = 1;
   
   return hurst;
}

//+------------------------------------------------------------------+
//| Classify regime from Hurst                                        |
//+------------------------------------------------------------------+
ENUM_REGIME_TYPE ClassifyRegime(double hurst)
{
   if(hurst > 0.55)
      return REG_TRENDING;
   else if(hurst < 0.45)
      return REG_REVERTING;
   else
      return REG_RANDOM;
}

//+------------------------------------------------------------------+
//| Get regime name                                                   |
//+------------------------------------------------------------------+
string GetRegimeName(ENUM_REGIME_TYPE regime)
{
   switch(regime)
   {
      case REG_TRENDING:  return "TRENDING";
      case REG_REVERTING: return "REVERTING";
      case REG_RANDOM:    return "RANDOM";
      default:            return "UNKNOWN";
   }
}

//+------------------------------------------------------------------+
//| Get regime color                                                  |
//+------------------------------------------------------------------+
color GetRegimeColor(ENUM_REGIME_TYPE regime)
{
   switch(regime)
   {
      case REG_TRENDING:  return InpBullColor;
      case REG_REVERTING: return InpNeutralColor;
      case REG_RANDOM:    return InpBearColor;
      default:            return InpBlockedColor;
   }
}

//+------------------------------------------------------------------+
//| Calculate bar delta from ticks                                    |
//+------------------------------------------------------------------+
long CalculateBarDelta(int barIndex)
{
   datetime barTime = iTime(_Symbol, PERIOD_CURRENT, barIndex);
   int barSeconds = PeriodSeconds(PERIOD_CURRENT);
   datetime barEnd = barTime + barSeconds;
   
   MqlTick ticks[];
   int copied = CopyTicksRange(_Symbol, ticks, COPY_TICKS_ALL,
                               barTime * 1000, barEnd * 1000);
   
   if(copied <= 0)
      return 0;
   
   long delta = 0;
   double lastPrice = 0;
   
   for(int i = 0; i < copied; i++)
   {
      double price = (ticks[i].last > 0) ? ticks[i].last : ticks[i].bid;
      long vol = (ticks[i].volume > 0) ? (long)ticks[i].volume : 1;
      
      int direction = 0;
      
      bool hasBuy = (ticks[i].flags & TICK_FLAG_BUY) != 0;
      bool hasSell = (ticks[i].flags & TICK_FLAG_SELL) != 0;
      
      if(hasBuy && !hasSell)
         direction = 1;
      else if(hasSell && !hasBuy)
         direction = -1;
      else if(ticks[i].ask > 0 && ticks[i].bid > 0)
      {
         double mid = (ticks[i].bid + ticks[i].ask) / 2;
         direction = (price >= mid) ? 1 : -1;
      }
      else if(lastPrice > 0)
      {
         if(price > lastPrice) direction = 1;
         else if(price < lastPrice) direction = -1;
      }
      
      delta += direction * vol;
      lastPrice = price;
   }
   
   return delta;
}

//+------------------------------------------------------------------+
//| Create rectangle object                                           |
//+------------------------------------------------------------------+
void CreateRectangle(string name, int x, int y, int width, int height, color bgColor)
{
   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bgColor);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_BORDER_COLOR, clrDimGray);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Create label object                                               |
//+------------------------------------------------------------------+
void CreateLabel(string name, int x, int y, string text, color textColor, int fontSize, bool bold)
{
   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, textColor);
   ObjectSetString(0, name, OBJPROP_FONT, bold ? "Arial Bold" : "Arial");
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Create horizontal line object                                     |
//+------------------------------------------------------------------+
void CreateLine(string name, int x, int y, int width, color lineColor)
{
   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, 1);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, lineColor);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}

//+------------------------------------------------------------------+
//| Update label text and color                                       |
//+------------------------------------------------------------------+
void UpdateLabel(string name, string text, color textColor)
{
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, textColor);
}
//+------------------------------------------------------------------+
