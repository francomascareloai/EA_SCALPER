//+------------------------------------------------------------------+
//|                                                   SMC_Visual.mq5 |
//|                         FORGE v3.1 - Visual SMC Indicator        |
//|                     Order Blocks, FVG, Sessions, Structure       |
//+------------------------------------------------------------------+
#property copyright "FORGE v3.1"
#property link      "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

//--- Input parameters
input group "=== ORDER BLOCKS ==="
input bool     InpShowOB          = true;           // Show Order Blocks
input color    InpBullOBColor     = clrDodgerBlue;  // Bullish OB Color
input color    InpBearOBColor     = clrCrimson;     // Bearish OB Color
input double   InpOBDisplacement  = 2.0;            // Min Displacement (ATR mult)
input int      InpOBMaxAge        = 50;             // Max OB Age (bars)

input group "=== FAIR VALUE GAPS ==="
input bool     InpShowFVG         = true;           // Show FVGs
input color    InpBullFVGColor    = clrLimeGreen;   // Bullish FVG Color
input color    InpBearFVGColor    = clrOrangeRed;   // Bearish FVG Color
input double   InpFVGMinGap       = 0.5;            // Min Gap (points)

input group "=== SESSIONS ==="
input bool     InpShowSessions    = true;           // Show Sessions
input color    InpAsianColor      = clrDarkSlateGray; // Asian Session Color
input color    InpLondonColor     = clrDarkGreen;   // London Session Color
input color    InpNYColor         = clrDarkBlue;    // NY Session Color

input group "=== STRUCTURE ==="
input bool     InpShowStructure   = true;           // Show Structure (HH/HL/LL/LH)
input int      InpSwingStrength   = 3;              // Swing Strength (bars)
input color    InpHHColor         = clrLime;        // Higher High Color
input color    InpHLColor         = clrGreen;       // Higher Low Color
input color    InpLHColor         = clrOrange;      // Lower High Color
input color    InpLLColor         = clrRed;         // Lower Low Color

input group "=== LIQUIDITY ==="
input bool     InpShowLiquidity   = true;           // Show Liquidity Levels
input color    InpBSLColor        = clrGold;        // BSL Color (buy-side)
input color    InpSSLColor        = clrMagenta;     // SSL Color (sell-side)

input group "=== SETTINGS ==="
input int      InpMaxObjects      = 100;            // Max Objects on Chart
input int      InpLookback        = 200;            // Lookback Bars

//--- Global variables
int g_atrHandle;
double g_atr[];
string g_prefix = "SMC_";
int g_objectCount = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization                                    |
//+------------------------------------------------------------------+
int OnInit()
{
   g_atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
   if(g_atrHandle == INVALID_HANDLE)
   {
      Print("Failed to create ATR handle");
      return INIT_FAILED;
   }
   
   ArraySetAsSeries(g_atr, true);
   
   // Clean old objects
   DeleteAllObjects();
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   DeleteAllObjects();
   if(g_atrHandle != INVALID_HANDLE)
      IndicatorRelease(g_atrHandle);
}

//+------------------------------------------------------------------+
//| Delete all indicator objects                                       |
//+------------------------------------------------------------------+
void DeleteAllObjects()
{
   ObjectsDeleteAll(0, g_prefix);
   g_objectCount = 0;
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                                |
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
   // Only update every 5 seconds to save CPU
   static datetime lastUpdate = 0;
   if(TimeCurrent() - lastUpdate < 5) return rates_total;
   lastUpdate = TimeCurrent();
   
   // Set arrays as series
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
   // Copy ATR
   if(CopyBuffer(g_atrHandle, 0, 0, InpLookback, g_atr) < InpLookback)
      return prev_calculated;
   
   // Clean old objects
   DeleteAllObjects();
   
   int limit = MathMin(rates_total - 10, InpLookback);
   
   // Draw components
   if(InpShowSessions)
      DrawSessions(time, high, low, limit);
   
   if(InpShowStructure)
      DrawStructure(time, high, low, limit);
   
   if(InpShowOB)
      DrawOrderBlocks(time, open, high, low, close, limit);
   
   if(InpShowFVG)
      DrawFVGs(time, high, low, limit);
   
   if(InpShowLiquidity)
      DrawLiquidityLevels(time, high, low, limit);
   
   ChartRedraw(0);
   
   return rates_total;
}

//+------------------------------------------------------------------+
//| Draw Order Blocks                                                  |
//+------------------------------------------------------------------+
void DrawOrderBlocks(const datetime &time[], const double &open[], 
                     const double &high[], const double &low[], 
                     const double &close[], int limit)
{
   for(int i = 5; i < limit - 3 && g_objectCount < InpMaxObjects; i++)
   {
      if(g_atr[i] <= 0) continue;
      
      // Bullish OB: bearish candle before bullish move
      if(close[i] < open[i])  // bearish candle
      {
         double displacement = 0;
         for(int j = 1; j <= 3; j++)
         {
            if(i - j >= 0)
               displacement = MathMax(displacement, high[i-j] - close[i]);
         }
         
         if(displacement >= g_atr[i] * InpOBDisplacement)
         {
            // Check if not yet mitigated
            bool valid = true;
            for(int k = i - 1; k >= 0 && k >= i - InpOBMaxAge; k--)
            {
               if(low[k] < low[i])  // mitigated
               {
                  valid = false;
                  break;
               }
            }
            
            if(valid)
               CreateOBRectangle("OB_BULL_" + IntegerToString(i), 
                                time[i], open[i], 
                                time[MathMax(0, i - InpOBMaxAge)], low[i],
                                InpBullOBColor, "BULL OB");
         }
      }
      
      // Bearish OB: bullish candle before bearish move  
      if(close[i] > open[i])  // bullish candle
      {
         double displacement = 0;
         for(int j = 1; j <= 3; j++)
         {
            if(i - j >= 0)
               displacement = MathMax(displacement, close[i] - low[i-j]);
         }
         
         if(displacement >= g_atr[i] * InpOBDisplacement)
         {
            bool valid = true;
            for(int k = i - 1; k >= 0 && k >= i - InpOBMaxAge; k--)
            {
               if(high[k] > high[i])
               {
                  valid = false;
                  break;
               }
            }
            
            if(valid)
               CreateOBRectangle("OB_BEAR_" + IntegerToString(i),
                                time[i], high[i],
                                time[MathMax(0, i - InpOBMaxAge)], open[i],
                                InpBearOBColor, "BEAR OB");
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Draw Fair Value Gaps                                               |
//+------------------------------------------------------------------+
void DrawFVGs(const datetime &time[], const double &high[], 
              const double &low[], int limit)
{
   for(int i = 2; i < limit && g_objectCount < InpMaxObjects; i++)
   {
      // Bullish FVG: gap up
      double gap_bull = low[i-2] - high[i];
      if(gap_bull >= InpFVGMinGap)
      {
         CreateFVGRectangle("FVG_BULL_" + IntegerToString(i),
                           time[i-1], low[i-2],
                           time[0], high[i],
                           InpBullFVGColor, "BULL FVG");
      }
      
      // Bearish FVG: gap down
      double gap_bear = low[i] - high[i-2];
      if(gap_bear >= InpFVGMinGap)
      {
         CreateFVGRectangle("FVG_BEAR_" + IntegerToString(i),
                           time[i-1], low[i],
                           time[0], high[i-2],
                           InpBearFVGColor, "BEAR FVG");
      }
   }
}

//+------------------------------------------------------------------+
//| Draw Session Boxes                                                 |
//+------------------------------------------------------------------+
void DrawSessions(const datetime &time[], const double &high[], 
                  const double &low[], int limit)
{
   MqlDateTime dt;
   datetime sessionStart = 0;
   double sessionHigh = 0, sessionLow = DBL_MAX;
   int currentSession = -1;  // 0=Asian, 1=London, 2=NY
   
   for(int i = limit - 1; i >= 0; i--)
   {
      TimeToStruct(time[i], dt);
      int hour = dt.hour;
      
      int newSession = -1;
      if(hour >= 0 && hour < 8)
         newSession = 0;  // Asian
      else if(hour >= 8 && hour < 13)
         newSession = 1;  // London
      else if(hour >= 13 && hour < 21)
         newSession = 2;  // NY
      
      if(newSession != currentSession && newSession >= 0)
      {
         // Draw previous session
         if(currentSession >= 0 && sessionStart != 0 && g_objectCount < InpMaxObjects)
         {
            color clr = (currentSession == 0) ? InpAsianColor : 
                       (currentSession == 1) ? InpLondonColor : InpNYColor;
            string name = (currentSession == 0) ? "ASIAN" : 
                         (currentSession == 1) ? "LONDON" : "NY";
            
            CreateSessionBox("SESSION_" + name + "_" + IntegerToString(i),
                           sessionStart, sessionHigh,
                           time[i], sessionLow, clr, name);
         }
         
         // Start new session
         currentSession = newSession;
         sessionStart = time[i];
         sessionHigh = high[i];
         sessionLow = low[i];
      }
      else if(currentSession >= 0)
      {
         sessionHigh = MathMax(sessionHigh, high[i]);
         sessionLow = MathMin(sessionLow, low[i]);
      }
   }
}

//+------------------------------------------------------------------+
//| Draw Structure (HH/HL/LH/LL)                                       |
//+------------------------------------------------------------------+
void DrawStructure(const datetime &time[], const double &high[], 
                   const double &low[], int limit)
{
   double lastSwingHigh = 0, lastSwingLow = DBL_MAX;
   double prevSwingHigh = 0, prevSwingLow = DBL_MAX;
   int n = InpSwingStrength;
   
   for(int i = n; i < limit - n && g_objectCount < InpMaxObjects; i++)
   {
      // Check for swing high
      bool isSwingHigh = true;
      for(int j = 1; j <= n; j++)
      {
         if(high[i] <= high[i-j] || high[i] <= high[i+j])
         {
            isSwingHigh = false;
            break;
         }
      }
      
      if(isSwingHigh)
      {
         prevSwingHigh = lastSwingHigh;
         lastSwingHigh = high[i];
         
         if(prevSwingHigh > 0)
         {
            if(lastSwingHigh > prevSwingHigh)
               CreateSwingLabel("HH_" + IntegerToString(i), time[i], high[i], 
                              InpHHColor, "HH", true);
            else
               CreateSwingLabel("LH_" + IntegerToString(i), time[i], high[i],
                              InpLHColor, "LH", true);
         }
      }
      
      // Check for swing low
      bool isSwingLow = true;
      for(int j = 1; j <= n; j++)
      {
         if(low[i] >= low[i-j] || low[i] >= low[i+j])
         {
            isSwingLow = false;
            break;
         }
      }
      
      if(isSwingLow)
      {
         prevSwingLow = lastSwingLow;
         lastSwingLow = low[i];
         
         if(prevSwingLow < DBL_MAX)
         {
            if(lastSwingLow > prevSwingLow)
               CreateSwingLabel("HL_" + IntegerToString(i), time[i], low[i],
                              InpHLColor, "HL", false);
            else
               CreateSwingLabel("LL_" + IntegerToString(i), time[i], low[i],
                              InpLLColor, "LL", false);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Draw Liquidity Levels                                              |
//+------------------------------------------------------------------+
void DrawLiquidityLevels(const datetime &time[], const double &high[],
                         const double &low[], int limit)
{
   // Find equal highs (BSL) and equal lows (SSL)
   double tolerance = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 50;  // 5 pips
   
   for(int i = 1; i < limit - 1 && g_objectCount < InpMaxObjects; i++)
   {
      // Check for equal highs
      for(int j = i + 5; j < MathMin(i + 30, limit); j++)
      {
         if(MathAbs(high[i] - high[j]) <= tolerance)
         {
            // Found equal highs - BSL
            CreateLiquidityLine("BSL_" + IntegerToString(i) + "_" + IntegerToString(j),
                              time[j], high[i], time[0], InpBSLColor, "BSL");
            break;
         }
      }
      
      // Check for equal lows
      for(int j = i + 5; j < MathMin(i + 30, limit); j++)
      {
         if(MathAbs(low[i] - low[j]) <= tolerance)
         {
            // Found equal lows - SSL
            CreateLiquidityLine("SSL_" + IntegerToString(i) + "_" + IntegerToString(j),
                              time[j], low[i], time[0], InpSSLColor, "SSL");
            break;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Create Order Block Rectangle                                       |
//+------------------------------------------------------------------+
void CreateOBRectangle(string name, datetime t1, double p1, 
                       datetime t2, double p2, color clr, string tooltip)
{
   string objName = g_prefix + name;
   
   ObjectCreate(0, objName, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, objName, OBJPROP_FILL, true);
   ObjectSetInteger(0, objName, OBJPROP_BACK, true);
   ObjectSetInteger(0, objName, OBJPROP_WIDTH, 1);
   ObjectSetString(0, objName, OBJPROP_TOOLTIP, tooltip);
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   
   // Make semi-transparent by using style
   ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_SOLID);
   
   g_objectCount++;
}

//+------------------------------------------------------------------+
//| Create FVG Rectangle                                               |
//+------------------------------------------------------------------+
void CreateFVGRectangle(string name, datetime t1, double p1,
                        datetime t2, double p2, color clr, string tooltip)
{
   string objName = g_prefix + name;
   
   ObjectCreate(0, objName, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, objName, OBJPROP_FILL, true);
   ObjectSetInteger(0, objName, OBJPROP_BACK, true);
   ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_DOT);
   ObjectSetString(0, objName, OBJPROP_TOOLTIP, tooltip);
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   
   g_objectCount++;
}

//+------------------------------------------------------------------+
//| Create Session Box                                                 |
//+------------------------------------------------------------------+
void CreateSessionBox(string name, datetime t1, double p1,
                      datetime t2, double p2, color clr, string tooltip)
{
   string objName = g_prefix + name;
   
   ObjectCreate(0, objName, OBJ_RECTANGLE, 0, t1, p1, t2, p2);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, objName, OBJPROP_FILL, false);
   ObjectSetInteger(0, objName, OBJPROP_BACK, true);
   ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_DASH);
   ObjectSetString(0, objName, OBJPROP_TOOLTIP, tooltip + " Session");
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   
   g_objectCount++;
}

//+------------------------------------------------------------------+
//| Create Swing Label                                                 |
//+------------------------------------------------------------------+
void CreateSwingLabel(string name, datetime t, double price, 
                      color clr, string text, bool above)
{
   string objName = g_prefix + name;
   
   ObjectCreate(0, objName, OBJ_TEXT, 0, t, price);
   ObjectSetString(0, objName, OBJPROP_TEXT, text);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, objName, OBJPROP_ANCHOR, above ? ANCHOR_LOWER : ANCHOR_UPPER);
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   
   g_objectCount++;
}

//+------------------------------------------------------------------+
//| Create Liquidity Line                                              |
//+------------------------------------------------------------------+
void CreateLiquidityLine(string name, datetime t1, double price,
                         datetime t2, color clr, string tooltip)
{
   string objName = g_prefix + name;
   
   ObjectCreate(0, objName, OBJ_TREND, 0, t1, price, t2, price);
   ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2);
   ObjectSetInteger(0, objName, OBJPROP_STYLE, STYLE_DASHDOT);
   ObjectSetInteger(0, objName, OBJPROP_RAY_RIGHT, true);
   ObjectSetString(0, objName, OBJPROP_TOOLTIP, tooltip + " @ " + DoubleToString(price, _Digits));
   ObjectSetInteger(0, objName, OBJPROP_SELECTABLE, false);
   
   g_objectCount++;
}
//+------------------------------------------------------------------+
