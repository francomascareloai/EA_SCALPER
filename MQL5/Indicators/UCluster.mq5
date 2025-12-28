//+------------------------------------------------------------------+
//|                                                     UCluster.mq5 |
//|                          EA_SCALPER_XAUUSD - Custom Footprint    |
//|                                                                  |
//|  Full Cluster/Footprint Visualization:                          |
//|  - Volume Profile per bar (bid/ask clusters)                    |
//|  - Delta at each price level                                    |
//|  - POC (Point of Control) - highest volume level                |
//|  - VAH/VAL (Value Area High/Low)                                |
//|  - Imbalance Detection (stacked + diagonal)                     |
//|  - CVD Line in subwindow                                        |
//|                                                                  |
//|  Inspired by commercial U-Cluster but built for XAUUSD          |
//+------------------------------------------------------------------+
#property copyright "EA_SCALPER_XAUUSD"
#property version   "1.00"
#property description "Custom Footprint/Cluster Chart for XAUUSD"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3

// Plot 1: POC Line
#property indicator_label1  "POC"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGold
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

// Plot 2: VAH Line
#property indicator_label2  "VAH"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_DOT
#property indicator_width2  1

// Plot 3: VAL Line
#property indicator_label3  "VAL"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrangeRed
#property indicator_style3  STYLE_DOT
#property indicator_width3  1

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "=== Cluster Settings ==="
input double   InpClusterSize        = 2.50;      // Cluster Size (pts) - XAUUSD: 2-5
input int      InpBarsToProcess      = 100;       // Bars to process
input double   InpValueAreaPct       = 0.70;      // Value Area % (0.70 = 70%)

input group "=== Imbalance Detection ==="
input bool     InpShowImbalances     = true;      // Show Imbalances
input double   InpImbalanceRatio     = 3.0;       // Imbalance Ratio (3:1 = strong)
input int      InpStackedMinLevels   = 3;         // Min levels for Stacked Imbalance
input color    InpBidImbalanceColor  = clrCrimson;    // Bid Imbalance (selling pressure)
input color    InpAskImbalanceColor  = clrLimeGreen;  // Ask Imbalance (buying pressure)

input group "=== Visual Settings ==="
input bool     InpShowClusterBoxes   = true;      // Show Cluster Volume Boxes
input bool     InpShowDelta          = true;      // Show Delta Numbers
input int      InpMaxObjectsPerBar   = 50;        // Max objects per bar
input int      InpFontSize           = 7;         // Font size for delta
input color    InpPositiveDelta      = clrLime;   // Positive delta color
input color    InpNegativeDelta      = clrRed;    // Negative delta color
input color    InpPOCBoxColor        = clrGold;   // POC level highlight

input group "=== Display Mode (YuClusters style) ==="
enum ENUM_DISPLAY_MODE
{
   MODE_DELTA,           // Delta only
   MODE_DELTA_PCT,       // Delta % (of larger side)
   MODE_BID_ASK_SUM,     // BID + ASK (total)
   MODE_BID_ASK_SPLIT,   // BID x ASK (left/right)
   MODE_DELTA_BG         // Delta with colored background
};
input ENUM_DISPLAY_MODE InpDisplayMode = MODE_DELTA_BG;  // Display Mode
input int      InpMinVolumeFilter    = 10;        // Min volume to display (filter noise)
input bool     InpShowVolumeProfile  = true;      // Show side volume profile bars
input int      InpProfileBarWidth    = 3;         // Profile bar width (pixels equiv)

input group "=== Performance ==="
input int      InpMaxTotalObjects    = 2000;      // Max total objects
input bool     InpOnlyCurrentBar     = false;     // Only show current bar clusters
input int      InpUpdateMs           = 250;       // Min update interval (ms)

//+------------------------------------------------------------------+
//| Structures                                                       |
//+------------------------------------------------------------------+
struct SClusterLevel
{
   double price;       // Cluster center price
   long   bidVolume;   // Volume at bid (sells)
   long   askVolume;   // Volume at ask (buys)
   long   delta;       // askVolume - bidVolume
   long   totalVolume; // bidVolume + askVolume
   bool   bidImbalance;// Bid imbalance detected
   bool   askImbalance;// Ask imbalance detected
};

struct SBarProfile
{
   datetime       barTime;
   double         pocPrice;
   double         vahPrice;
   double         valPrice;
   long           totalVolume;
   long           totalDelta;
   SClusterLevel  levels[];
   int            levelCount;
   int            stackedBidStart;  // First level of stacked bid imbalance
   int            stackedBidCount;  // Count of stacked bid imbalance
   int            stackedAskStart;  // First level of stacked ask imbalance
   int            stackedAskCount;  // Count of stacked ask imbalance
};

//+------------------------------------------------------------------+
//| Buffers                                                          |
//+------------------------------------------------------------------+
double g_poc[];
double g_vah[];
double g_val[];
double g_delta[];
double g_bidVol[];
double g_askVol[];

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
string g_prefix = "UCL_";
int g_objectCount = 0;
SBarProfile g_barProfiles[];

// Throttle redraw/update to avoid heavy object churn on every tick
ulong g_last_update_msc = 0;

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, g_poc, INDICATOR_DATA);
   SetIndexBuffer(1, g_vah, INDICATOR_DATA);
   SetIndexBuffer(2, g_val, INDICATOR_DATA);
   SetIndexBuffer(3, g_delta, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, g_bidVol, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, g_askVol, INDICATOR_CALCULATIONS);

   ArraySetAsSeries(g_poc, true);
   ArraySetAsSeries(g_vah, true);
   ArraySetAsSeries(g_val, true);
   ArraySetAsSeries(g_delta, true);
   ArraySetAsSeries(g_bidVol, true);
   ArraySetAsSeries(g_askVol, true);

   IndicatorSetString(INDICATOR_SHORTNAME, "UCluster");
   IndicatorSetInteger(INDICATOR_DIGITS, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));

   // Instance-specific prefix to avoid cross-chart collisions
   g_prefix = "UCL_" + IntegerToString((int)ChartID()) + "_";

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Deinitialization - Clean up objects                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, g_prefix);
}

//+------------------------------------------------------------------+
//| Normalize price to cluster level                                 |
//+------------------------------------------------------------------+
double NormalizeToCluster(double price, double clusterSize)
{
   return MathRound(price / clusterSize) * clusterSize;
}

//+------------------------------------------------------------------+
//| Build cluster profile for a bar                                  |
//+------------------------------------------------------------------+
void BuildBarProfile(int barIndex, SBarProfile &profile)
{
   profile.barTime = iTime(_Symbol, _Period, barIndex);
   profile.pocPrice = 0;
   profile.vahPrice = 0;
   profile.valPrice = 0;
   profile.totalVolume = 0;
   profile.totalDelta = 0;
   profile.levelCount = 0;
   profile.stackedBidStart = -1;
   profile.stackedBidCount = 0;
   profile.stackedAskStart = -1;
   profile.stackedAskCount = 0;

   datetime barTime = profile.barTime;
   int barSeconds = PeriodSeconds(_Period);
   datetime barEnd = barTime + barSeconds;

   MqlTick ticks[];
   ulong from_msc = (ulong)barTime * 1000ULL;
   ulong to_msc = (ulong)barEnd * 1000ULL;
   if(to_msc > 0) to_msc -= 1ULL; // end-exclusive to avoid double counting boundary ticks

   int copied = CopyTicksRange(_Symbol, ticks, COPY_TICKS_ALL,
                               (long)from_msc, (long)to_msc);

   if(copied <= 0)
      return;

   double clusterSize = InpClusterSize;
   if(clusterSize <= 0) clusterSize = 2.50;

   // Build cluster levels from ticks
   SClusterLevel tempLevels[];
   int tempCount = 0;
   double lastPrice = 0;

   for(int i = 0; i < copied; i++)
   {
      double price = (ticks[i].last > 0) ? ticks[i].last : ticks[i].bid;
      double clusterPrice = NormalizeToCluster(price, clusterSize);
      long vol = (ticks[i].volume > 0) ? (long)ticks[i].volume : 1;

      // Determine direction (bid or ask)
      bool isBid = false;
      bool isAsk = false;

      bool hasBuy = (ticks[i].flags & TICK_FLAG_BUY) != 0;
      bool hasSell = (ticks[i].flags & TICK_FLAG_SELL) != 0;

      if(hasBuy && !hasSell)
         isAsk = true;
      else if(hasSell && !hasBuy)
         isBid = true;
      else if(ticks[i].ask > 0 && ticks[i].bid > 0)
      {
         double mid = (ticks[i].bid + ticks[i].ask) / 2;
         if(price >= mid)
            isAsk = true;
         else
            isBid = true;
      }
      else if(lastPrice > 0)
      {
         if(price > lastPrice) isAsk = true;
         else if(price < lastPrice) isBid = true;
      }

      // Find or create cluster level
      int foundIdx = -1;
      for(int j = 0; j < tempCount; j++)
      {
         if(MathAbs(tempLevels[j].price - clusterPrice) < clusterSize / 2)
         {
            foundIdx = j;
            break;
         }
      }

      if(foundIdx >= 0)
      {
         if(isBid)
            tempLevels[foundIdx].bidVolume += vol;
         else if(isAsk)
            tempLevels[foundIdx].askVolume += vol;
         tempLevels[foundIdx].totalVolume += vol;
      }
      else
      {
         ArrayResize(tempLevels, tempCount + 1);
         tempLevels[tempCount].price = clusterPrice;
         tempLevels[tempCount].bidVolume = isBid ? vol : 0;
         tempLevels[tempCount].askVolume = isAsk ? vol : 0;
         tempLevels[tempCount].totalVolume = vol;
         tempLevels[tempCount].bidImbalance = false;
         tempLevels[tempCount].askImbalance = false;
         tempCount++;
      }

      profile.totalVolume += vol;
      lastPrice = price;
   }

   if(tempCount == 0)
      return;

   // Sort levels by price (ascending)
   for(int i = 0; i < tempCount - 1; i++)
   {
      for(int j = i + 1; j < tempCount; j++)
      {
         if(tempLevels[i].price > tempLevels[j].price)
         {
            SClusterLevel temp = tempLevels[i];
            tempLevels[i] = tempLevels[j];
            tempLevels[j] = temp;
         }
      }
   }

   // Calculate delta and detect imbalances
   for(int i = 0; i < tempCount; i++)
   {
      tempLevels[i].delta = tempLevels[i].askVolume - tempLevels[i].bidVolume;
      profile.totalDelta += tempLevels[i].delta;

      // Imbalance detection
      if(InpShowImbalances && tempLevels[i].bidVolume > 0 && tempLevels[i].askVolume > 0)
      {
         double ratio = (double)tempLevels[i].bidVolume / (double)tempLevels[i].askVolume;
         if(ratio >= InpImbalanceRatio)
            tempLevels[i].bidImbalance = true;  // Strong selling
         else if(ratio <= 1.0 / InpImbalanceRatio)
            tempLevels[i].askImbalance = true;  // Strong buying
      }
      else if(InpShowImbalances)
      {
         if(tempLevels[i].bidVolume > 0 && tempLevels[i].askVolume == 0)
            tempLevels[i].bidImbalance = true;
         else if(tempLevels[i].askVolume > 0 && tempLevels[i].bidVolume == 0)
            tempLevels[i].askImbalance = true;
      }
   }

   // Find POC (highest volume level)
   int pocIdx = 0;
   long maxVol = 0;
   for(int i = 0; i < tempCount; i++)
   {
      if(tempLevels[i].totalVolume > maxVol)
      {
         maxVol = tempLevels[i].totalVolume;
         pocIdx = i;
      }
   }
   profile.pocPrice = tempLevels[pocIdx].price;

   // Calculate Value Area (70% of volume)
   long targetVol = (long)(profile.totalVolume * InpValueAreaPct);
   long currentVol = maxVol;
   int upperIdx = pocIdx;
   int lowerIdx = pocIdx;

   profile.vahPrice = profile.pocPrice;
   profile.valPrice = profile.pocPrice;

   while(currentVol < targetVol && (upperIdx < tempCount - 1 || lowerIdx > 0))
   {
      long upperVol = 0, lowerVol = 0;

      if(upperIdx < tempCount - 1)
         upperVol = tempLevels[upperIdx + 1].totalVolume;
      if(lowerIdx > 0)
         lowerVol = tempLevels[lowerIdx - 1].totalVolume;

      if(upperVol >= lowerVol && upperIdx < tempCount - 1)
      {
         upperIdx++;
         currentVol += upperVol;
         profile.vahPrice = tempLevels[upperIdx].price;
      }
      else if(lowerIdx > 0)
      {
         lowerIdx--;
         currentVol += lowerVol;
         profile.valPrice = tempLevels[lowerIdx].price;
      }
      else
         break;
   }

   // Detect stacked imbalances (consecutive levels with same imbalance)
   int bidStack = 0, askStack = 0;
   int bidStackStart = -1, askStackStart = -1;

   for(int i = 0; i < tempCount; i++)
   {
      // Bid imbalance stacking
      if(tempLevels[i].bidImbalance)
      {
         if(bidStack == 0) bidStackStart = i;
         bidStack++;
      }
      else
      {
         if(bidStack >= InpStackedMinLevels)
         {
            profile.stackedBidStart = bidStackStart;
            profile.stackedBidCount = bidStack;
         }
         bidStack = 0;
         bidStackStart = -1;
      }

      // Ask imbalance stacking
      if(tempLevels[i].askImbalance)
      {
         if(askStack == 0) askStackStart = i;
         askStack++;
      }
      else
      {
         if(askStack >= InpStackedMinLevels)
         {
            profile.stackedAskStart = askStackStart;
            profile.stackedAskCount = askStack;
         }
         askStack = 0;
         askStackStart = -1;
      }
   }

   // Check end of array
   if(bidStack >= InpStackedMinLevels)
   {
      profile.stackedBidStart = bidStackStart;
      profile.stackedBidCount = bidStack;
   }
   if(askStack >= InpStackedMinLevels)
   {
      profile.stackedAskStart = askStackStart;
      profile.stackedAskCount = askStack;
   }

   // Copy levels to profile
   ArrayResize(profile.levels, tempCount);
   for(int i = 0; i < tempCount; i++)
      profile.levels[i] = tempLevels[i];
   profile.levelCount = tempCount;
}

//+------------------------------------------------------------------+
//| Draw cluster visualization for a bar                             |
//+------------------------------------------------------------------+
void DrawBarCluster(int barIndex, const SBarProfile &profile)
{
   if(profile.levelCount == 0)
      return;

   if(g_objectCount >= InpMaxTotalObjects)
      return;

   datetime barTime = profile.barTime;
   int barSeconds = PeriodSeconds(_Period);
   double clusterSize = InpClusterSize > 0 ? InpClusterSize : 2.50;

   // Find max volume for scaling
   long maxLevelVol = 1;
   for(int i = 0; i < profile.levelCount; i++)
   {
      if(profile.levels[i].totalVolume > maxLevelVol)
         maxLevelVol = profile.levels[i].totalVolume;
   }

   int objectsThisBar = 0;

   for(int i = 0; i < profile.levelCount && objectsThisBar < InpMaxObjectsPerBar; i++)
   {
      if(g_objectCount >= InpMaxTotalObjects)
         break;

      SClusterLevel lvl = profile.levels[i];

      // Volume filter - skip low volume clusters
      if(lvl.totalVolume < InpMinVolumeFilter)
         continue;

      double priceTop = lvl.price + clusterSize / 2;
      double priceBot = lvl.price - clusterSize / 2;

      // Draw cluster box with color based on delta/mode
      if(InpShowClusterBoxes)
      {
         string boxName = g_prefix + "box_" + IntegerToString(barIndex) + "_" + IntegerToString(i);

         color boxColor;
         double intensity = 0;

         // Determine color based on display mode
         if(InpDisplayMode == MODE_DELTA_BG || InpDisplayMode == MODE_DELTA)
         {
            if(lvl.bidImbalance)
               boxColor = InpBidImbalanceColor;
            else if(lvl.askImbalance)
               boxColor = InpAskImbalanceColor;
            else if(lvl.delta > 0)
            {
               intensity = MathMin(1.0, (double)lvl.delta / 500);
               boxColor = ColorLerp(clrDimGray, InpPositiveDelta, intensity);
            }
            else if(lvl.delta < 0)
            {
               intensity = MathMin(1.0, (double)MathAbs(lvl.delta) / 500);
               boxColor = ColorLerp(clrDimGray, InpNegativeDelta, intensity);
            }
            else
               boxColor = clrDimGray;
         }
         else if(InpDisplayMode == MODE_BID_ASK_SUM || InpDisplayMode == MODE_BID_ASK_SPLIT)
         {
            // Color by volume intensity
            intensity = MathMin(1.0, (double)lvl.totalVolume / (double)maxLevelVol);
            boxColor = ColorLerp(clrDimGray, clrDodgerBlue, intensity);
         }
         else // MODE_DELTA_PCT
         {
            double pct = 0;
            if(lvl.totalVolume > 0)
               pct = (double)MathAbs(lvl.delta) / (double)lvl.totalVolume;
            intensity = MathMin(1.0, pct);
            if(lvl.delta > 0)
               boxColor = ColorLerp(clrDimGray, InpPositiveDelta, intensity);
            else
               boxColor = ColorLerp(clrDimGray, InpNegativeDelta, intensity);
         }

         // POC highlight
         if(MathAbs(lvl.price - profile.pocPrice) < clusterSize / 2)
            boxColor = InpPOCBoxColor;

         ObjectCreate(0, boxName, OBJ_RECTANGLE, 0, barTime, priceTop, barTime + barSeconds, priceBot);
         ObjectSetInteger(0, boxName, OBJPROP_COLOR, boxColor);
         ObjectSetInteger(0, boxName, OBJPROP_FILL, true);
         ObjectSetInteger(0, boxName, OBJPROP_BACK, true);
         ObjectSetInteger(0, boxName, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, boxName, OBJPROP_HIDDEN, true);

         g_objectCount++;
         objectsThisBar++;
      }

      // Draw text based on display mode
      if(InpShowDelta && objectsThisBar < InpMaxObjectsPerBar)
      {
         string textName = g_prefix + "txt_" + IntegerToString(barIndex) + "_" + IntegerToString(i);
         datetime textTime = barTime + barSeconds / 2;
         string displayText = "";
         color textColor = clrWhite;

         switch(InpDisplayMode)
         {
            case MODE_DELTA:
               if(lvl.delta != 0)
               {
                  displayText = IntegerToString(lvl.delta);
                  textColor = lvl.delta > 0 ? InpPositiveDelta : InpNegativeDelta;
               }
               break;

            case MODE_DELTA_PCT:
               if(lvl.totalVolume > 0)
               {
                  double pct = (double)MathAbs(lvl.delta) / (double)lvl.totalVolume * 100;
                  displayText = IntegerToString((int)pct) + "%";
                  textColor = lvl.delta > 0 ? InpPositiveDelta : InpNegativeDelta;
               }
               break;

            case MODE_BID_ASK_SUM:
               displayText = IntegerToString(lvl.totalVolume);
               textColor = clrWhite;
               break;

            case MODE_BID_ASK_SPLIT:
               // Show as "BID x ASK"
               displayText = IntegerToString(lvl.bidVolume) + "x" + IntegerToString(lvl.askVolume);
               if(lvl.bidVolume > lvl.askVolume)
                  textColor = InpNegativeDelta;
               else if(lvl.askVolume > lvl.bidVolume)
                  textColor = InpPositiveDelta;
               else
                  textColor = clrWhite;
               break;

            case MODE_DELTA_BG:
               if(lvl.delta != 0)
               {
                  displayText = IntegerToString(lvl.delta);
                  // White text on colored background for contrast
                  textColor = clrWhite;
               }
               break;
         }

         if(StringLen(displayText) > 0)
         {
            ObjectCreate(0, textName, OBJ_TEXT, 0, textTime, lvl.price);
            ObjectSetString(0, textName, OBJPROP_TEXT, displayText);
            ObjectSetInteger(0, textName, OBJPROP_COLOR, textColor);
            ObjectSetInteger(0, textName, OBJPROP_FONTSIZE, InpFontSize);
            ObjectSetString(0, textName, OBJPROP_FONT, "Arial Bold");
            ObjectSetInteger(0, textName, OBJPROP_ANCHOR, ANCHOR_CENTER);
            ObjectSetInteger(0, textName, OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, textName, OBJPROP_HIDDEN, true);

            g_objectCount++;
            objectsThisBar++;
         }
      }
   }

   // Draw volume profile bar on the side (like YuClusters)
   if(InpShowVolumeProfile && profile.levelCount > 0)
   {
      // Draw a simple profile line showing volume distribution
      for(int i = 0; i < profile.levelCount && objectsThisBar < InpMaxObjectsPerBar; i++)
      {
         if(g_objectCount >= InpMaxTotalObjects)
            break;

         SClusterLevel lvl = profile.levels[i];
         if(lvl.totalVolume < InpMinVolumeFilter)
            continue;

         // Width proportional to volume
         double widthRatio = (double)lvl.totalVolume / (double)maxLevelVol;
         int barWidth = (int)(widthRatio * barSeconds * 0.3); // 30% of bar width max
         if(barWidth < 1) barWidth = 1;

         string profName = g_prefix + "prof_" + IntegerToString(barIndex) + "_" + IntegerToString(i);
         datetime profStart = barTime + barSeconds;
         datetime profEnd = profStart + barWidth;

         // POC gets special color
         color profColor = clrDimGray;
         if(MathAbs(lvl.price - profile.pocPrice) < clusterSize / 2)
            profColor = InpPOCBoxColor;
         else if(lvl.price >= profile.valPrice && lvl.price <= profile.vahPrice)
            profColor = clrDodgerBlue;  // Value area

         ObjectCreate(0, profName, OBJ_RECTANGLE, 0,
                      profStart, lvl.price + clusterSize/2,
                      profEnd, lvl.price - clusterSize/2);
         ObjectSetInteger(0, profName, OBJPROP_COLOR, profColor);
         ObjectSetInteger(0, profName, OBJPROP_FILL, true);
         ObjectSetInteger(0, profName, OBJPROP_BACK, true);
         ObjectSetInteger(0, profName, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, profName, OBJPROP_HIDDEN, true);

         g_objectCount++;
         objectsThisBar++;
      }
   }

   // Draw stacked imbalance zones
   if(InpShowImbalances)
   {
      // Stacked Bid Imbalance (selling pressure - institutional selling)
      if(profile.stackedBidStart >= 0 && profile.stackedBidCount >= InpStackedMinLevels)
      {
         double zoneTop = profile.levels[profile.stackedBidStart + profile.stackedBidCount - 1].price + clusterSize / 2;
         double zoneBot = profile.levels[profile.stackedBidStart].price - clusterSize / 2;

         string zoneName = g_prefix + "sbid_" + IntegerToString(barIndex);
         ObjectCreate(0, zoneName, OBJ_RECTANGLE, 0, barTime, zoneTop, barTime + barSeconds * 3, zoneBot);
         ObjectSetInteger(0, zoneName, OBJPROP_COLOR, InpBidImbalanceColor);
         ObjectSetInteger(0, zoneName, OBJPROP_FILL, true);
         ObjectSetInteger(0, zoneName, OBJPROP_BACK, true);
         ObjectSetInteger(0, zoneName, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, zoneName, OBJPROP_WIDTH, 2);
         ObjectSetInteger(0, zoneName, OBJPROP_SELECTABLE, false);
         g_objectCount++;
      }

      // Stacked Ask Imbalance (buying pressure - institutional buying)
      if(profile.stackedAskStart >= 0 && profile.stackedAskCount >= InpStackedMinLevels)
      {
         double zoneTop = profile.levels[profile.stackedAskStart + profile.stackedAskCount - 1].price + clusterSize / 2;
         double zoneBot = profile.levels[profile.stackedAskStart].price - clusterSize / 2;

         string zoneName = g_prefix + "sask_" + IntegerToString(barIndex);
         ObjectCreate(0, zoneName, OBJ_RECTANGLE, 0, barTime, zoneTop, barTime + barSeconds * 3, zoneBot);
         ObjectSetInteger(0, zoneName, OBJPROP_COLOR, InpAskImbalanceColor);
         ObjectSetInteger(0, zoneName, OBJPROP_FILL, true);
         ObjectSetInteger(0, zoneName, OBJPROP_BACK, true);
         ObjectSetInteger(0, zoneName, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(0, zoneName, OBJPROP_WIDTH, 2);
         ObjectSetInteger(0, zoneName, OBJPROP_SELECTABLE, false);
         g_objectCount++;
      }
   }
}

//+------------------------------------------------------------------+
//| Color interpolation helper                                       |
//+------------------------------------------------------------------+
color ColorLerp(color c1, color c2, double t)
{
   t = MathMax(0, MathMin(1, t));
   int r1 = (c1 >> 0) & 0xFF;
   int g1 = (c1 >> 8) & 0xFF;
   int b1 = (c1 >> 16) & 0xFF;
   int r2 = (c2 >> 0) & 0xFF;
   int g2 = (c2 >> 8) & 0xFF;
   int b2 = (c2 >> 16) & 0xFF;

   int r = (int)(r1 + t * (r2 - r1));
   int g = (int)(g1 + t * (g2 - g1));
   int b = (int)(b1 + t * (b2 - b1));

   return (color)((b << 16) | (g << 8) | r);
}

//+------------------------------------------------------------------+
//| Main calculation function                                        |
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
   ArraySetAsSeries(time, true);

   // Throttle heavy updates to avoid re-creating thousands of objects on every tick
   if(InpUpdateMs > 0)
   {
      ulong now_msc = GetMicrosecondCount() / 1000ULL;
      if(g_last_update_msc > 0 && now_msc - g_last_update_msc < (ulong)InpUpdateMs)
         return(rates_total);
      g_last_update_msc = now_msc;
   }

   int limit = rates_total - prev_calculated;
   if(limit <= 0) limit = 1;

   if(limit > InpBarsToProcess)
      limit = InpBarsToProcess;

   // On full recalculation, clean objects
   if(prev_calculated == 0)
   {
      ObjectsDeleteAll(0, g_prefix);
      g_objectCount = 0;
      ArrayResize(g_barProfiles, 0);
   }

   // Process bars
   for(int i = 0; i < limit && i < rates_total; i++)
   {
      SBarProfile profile;
      BuildBarProfile(i, profile);

      // Store buffer values
      g_poc[i] = profile.pocPrice;
      g_vah[i] = profile.vahPrice;
      g_val[i] = profile.valPrice;
      g_delta[i] = (double)profile.totalDelta;

      // Calculate bid/ask totals
      long bidTotal = 0, askTotal = 0;
      for(int j = 0; j < profile.levelCount; j++)
      {
         bidTotal += profile.levels[j].bidVolume;
         askTotal += profile.levels[j].askVolume;
      }
      g_bidVol[i] = (double)bidTotal;
      g_askVol[i] = (double)askTotal;

      // Draw visualization (only for recent bars or if showing only current)
      bool shouldDraw = false;
      if(InpOnlyCurrentBar)
         shouldDraw = (i == 0);
      else
         shouldDraw = (i < 20);  // Draw last 20 bars visually

      if(shouldDraw && InpShowClusterBoxes)
      {
         // Delete old objects for this bar (only those created by this instance)
         ObjectsDeleteAll(0, g_prefix + "box_" + IntegerToString(i) + "_");
         ObjectsDeleteAll(0, g_prefix + "txt_" + IntegerToString(i) + "_");
         ObjectsDeleteAll(0, g_prefix + "prof_" + IntegerToString(i) + "_");
         ObjectDelete(0, g_prefix + "sbid_" + IntegerToString(i));
         ObjectDelete(0, g_prefix + "sask_" + IntegerToString(i));

         DrawBarCluster(i, profile);
      }
   }

   ChartRedraw(0);
   return(rates_total);
}
//+------------------------------------------------------------------+
