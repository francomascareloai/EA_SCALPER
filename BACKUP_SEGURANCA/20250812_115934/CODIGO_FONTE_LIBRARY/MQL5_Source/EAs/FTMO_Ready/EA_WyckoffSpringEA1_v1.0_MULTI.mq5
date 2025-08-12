//+------------------------------------------------------------------+
//|                                   Wyckoff Springs EA [QuantVue].mq5 |
//|                        Copyright 2025, QuantVue (Adapted for MQL5)|
//|                     https://mozilla.org/MPL/2.0/ (Mozilla License) |
//+------------------------------------------------------------------+
#property copyright "QuantVue (Adapted for MQL5)"
#property link      "https://mozilla.org/MPL/2.0/"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh> // Include Trade.mqh for CTrade class

//--- Input parameters
input int   PivotLength      = 6;        // Pivot Length
input bool  RequireVolume    = false;    // Require Volume Confirmation
input double VolumeThreshold = 1.5;      // Volume Threshold
input int   RangePeriod      = 20;       // Trading Range Period
input double LotSize         = 0.1;      // Lot Size
input double TakeProfitPips  = 50;       // Take Profit (pips, where 1 pip = 0.1)

//--- Global variables
double RangeLowBuffer[];
double pivotPrices[];
int    pivotBars[];
bool   pivotActive[];
int    pivotCount[];
int    maxPivots = 100;
CTrade trade; // Trade object for handling trades

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   // Initialize arrays
   ArrayResize(pivotPrices, maxPivots);
   ArrayResize(pivotBars, maxPivots);
   ArrayResize(pivotActive, maxPivots);
   ArrayResize(pivotCount, maxPivots);
   ArrayInitialize(pivotPrices, EMPTY_VALUE);
   ArrayInitialize(pivotBars, -1);
   ArrayInitialize(pivotActive, false);
   ArrayInitialize(pivotCount, 0);
   
   // Set trade object properties
   trade.SetExpertMagicNumber(123456);
   
   // Validate inputs
   if(PivotLength < 1 || RangePeriod < 1 || LotSize <= 0 || TakeProfitPips < 0)
   {
      Print("Invalid input parameters!");
      return(INIT_PARAMETERS_INCORRECT);
   }
   
   // Verify symbol is XAUUSDc
   if(_Symbol != "XAUUSDc")
   {
      Print("EA is designed for XAUUSDc, current symbol is ", _Symbol);
   }
   
   // Warn about unlimited trades
   Print("Warning: No limit on open trades. Monitor positions closely due to no SL.");
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Clean up chart objects
   ObjectsDeleteAll(0, "WyckoffSpring_");
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick()
{
   // Get rates data
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, _Period, 0, RangePeriod + PivotLength * 2 + 1, rates);
   if(copied <= 0) return;
   
   // Get volume data
   long volume[];
   ArraySetAsSeries(volume, true);
   if(CopyTickVolume(_Symbol, _Period, 0, RangePeriod + PivotLength * 2 + 1, volume) <= 0) return;
   
   // Check if enough bars
   if(copied < PivotLength * 2 + 1 || copied < RangePeriod) return;
   
   int i = 1; // Process the latest complete bar
   double low[], close[];
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   if(CopyLow(_Symbol, _Period, 0, RangePeriod + PivotLength * 2 + 1, low) <= 0) return;
   if(CopyClose(_Symbol, _Period, 0, RangePeriod + PivotLength * 2 + 1, close) <= 0) return;
   
   // Calculate trading range low
   int lowestIdx = iLowest(_Symbol, _Period, MODE_LOW, RangePeriod, i);
   double rangeLow = low[lowestIdx];
   
   // Calculate volume SMA
   double volSum = 0.0;
   for(int j = i; j < i + RangePeriod && j < copied; j++)
   {
      volSum += (double)volume[j];
   }
   double avgVol = volSum / MathMin(RangePeriod, copied);
   bool meetsVolume = !RequireVolume || (volume[i] >= avgVol * VolumeThreshold);
   
   // Detect pivot low
   bool isPivotLow = true;
   double currentLow = low[i + PivotLength];
   for(int j = i; j <= i + PivotLength * 2 && j < copied; j++)
   {
      if(j != i + PivotLength && low[j] <= currentLow)
      {
         isPivotLow = false;
         break;
      }
   }
   
   // Add new pivot low
   if(isPivotLow && currentLow != EMPTY_VALUE)
   {
      for(int j = maxPivots - 1; j > 0; j--)
      {
         pivotPrices[j] = pivotPrices[j - 1];
         pivotBars[j] = pivotBars[j - 1];
         pivotActive[j] = pivotActive[j - 1];
         pivotCount[j] = pivotCount[j - 1];
      }
      pivotPrices[0] = currentLow;
      pivotBars[0] = i + PivotLength;
      pivotActive[0] = true;
      pivotCount[0] = 0;
   }
   
   // Check for spring condition
   for(int j = 0; j < maxPivots; j++)
   {
      if(pivotActive[j] && pivotBars[j] >= 0)
      {
         double pivotPrice = pivotPrices[j];
         int pivotBar = pivotBars[j];
         if(low[i] < pivotPrice && close[i] > pivotPrice && pivotCount[j] <= 3 && low[i] <= rangeLow && meetsVolume)
         {
            // Open buy trade with TP (50 pips = 5.00 = 500 points by default)
            double tp = close[i] + (TakeProfitPips * 10 * _Point);
            trade.Buy(LotSize, _Symbol, 0.0, 0.0, tp, "Wyckoff Spring Buy");
            
            // Draw spring label
            string objName = "WyckoffSpring_" + IntegerToString(i);
            ObjectCreate(0, objName, OBJ_ARROW_UP, 0, rates[i].time, low[i]);
            ObjectSetInteger(0, objName, OBJPROP_COLOR, clrLime);
            ObjectSetInteger(0, objName, OBJPROP_WIDTH, 2);
            Alert("Spring Detected at bar " + IntegerToString(i) + ", Buy order placed at " + DoubleToString(close[i], _Digits) + " with TP at " + DoubleToString(tp, _Digits));
            
            pivotActive[j] = false;
         }
         else if(low[i] < pivotPrice)
         {
            pivotCount[j]++;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Custom function to find lowest low index                           |
//+------------------------------------------------------------------+
int iLowest(string symbol, ENUM_TIMEFRAMES timeframe, int mode, int count, int start)
{
   double prices[];
   ArraySetAsSeries(prices, true);
   ArrayResize(prices, count); // Ensure array is sized correctly
   int copied = CopyLow(symbol, timeframe, start, count, prices);
   if(copied <= 0) return start; // Return start if copy fails
   int lowestIdx = 0;
   double lowest = prices[0];
   for(int i = 1; i < copied; i++)
   {
      if(prices[i] < lowest)
      {
         lowest = prices[i];
         lowestIdx = i;
      }
   }
   return start + lowestIdx;
}