//+------------------------------------------------------------------+
//|                                             SidewaysDetector.mq4 |
//|                                                          mwfx108 |
//|                                                mwfx108@gmail.com |
//+------------------------------------------------------------------+
//| Need a custom Indicator or EA for MT4, MT5, cAlgo, NinjaTrader?  |
//| Contact me at mwfx108@gmail.com to ask for details and prices.   |
//+------------------------------------------------------------------+
#property copyright "mwfx108"
#property link      "mwfx108@gmail.com"
#property version   "1.06"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Variables and Types                                              |
//+------------------------------------------------------------------+
struct Zone
{
   int Start;
   int End;
   double Low;
   double High;
};
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
// Multiplier for the average zone height. The bigger, the lower the zones
extern double  Average_Weight = 1.0;
// Number of consecutive bars within a zone
extern int     Min_Zone_Width = 3;
// Tolerance in points above a low / high of a bar
extern int     Tolerance = 20;
// Color of the zone
extern color   Rectangle_Color = clrNavy;
// Number of last zones to show. 0 = Show all zones
extern int     Show_N_Last_Zones = 2;
// Number of bars to process. 0 = All
extern int     Num_Bars = 500;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
  
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---
  
   RemoveObjects();
  
//---
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//---
  
   int numBars = Num_Bars > 0 ? Num_Bars : rates_total;
   Zone zones[];
  
   GetZones(zones, numBars);
   DrawZones(zones);
   ArrayFree(zones);
  
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Get sideways zones.                                              |
//| This algorithm detects sideways markets and is based on the      |
//| assumption that the markets always move sideways, except when    |
//| they are not.                                                    |
//+------------------------------------------------------------------+
void GetZones(Zone &zones[], int numBars)
{
//---
  
   double avgZoneHeight = 0, tolerancePt = Tolerance * Point;
  
   // --- Two passes:
   // Pass 1: Get average height of zone to filter big movements as the beginning of a zone
   // Pass 2: Add valid zones to a list
   for (int pass = 1; pass <= 2; pass++)
   {
      bool hasBrokenRange = false;
      double rangeHigh = High[numBars - 1] + tolerancePt, rangeLow = Low[numBars - 1] - tolerancePt;
      int zoneStart = numBars - 1, zoneEnd = 0, zoneSize = 0, zonesCounter = 0;
      
      ArrayFree(zones);
      
      // Iterate through all bars, beginning at the very first bar of the chart
      for (int i = numBars - 2; i >= 0; i--)
      {
         zoneSize = zoneStart - i;
         zoneEnd = i;
        
         // Check if a bar opened or closed above range high or range low
         if (Open[i] > rangeHigh || Open[i] < rangeLow || Close[i] > rangeHigh || Close[i] < rangeLow)
         {
            // Check if number of bars in zone is bigger or equal the required width
            if (zoneSize >= Min_Zone_Width)
            {
               // On first pass, add up the height of all zones found
               if (pass == 1)
               {
                  avgZoneHeight += MathAbs(rangeHigh - rangeLow);
               }
              
               // On second pass, add the zone to a list
               if (pass == 2)
                  AddZone(zones, zoneStart, zoneEnd + 1, rangeLow, rangeHigh);
                  
               zonesCounter++;
            }
            
            hasBrokenRange = true;
            zoneStart = i;
            rangeHigh = High[i] + tolerancePt;
            rangeLow = Low[i] - tolerancePt;
            
            // Pass 2: If bar height is bigger than the expected average zone height, skip this bar
            if (pass == 2 && MathAbs(High[i] - Low[i]) >= avgZoneHeight)
            {
               zoneStart = -1;
               rangeHigh = 0;
               rangeLow = 0;
               continue;
            }
         }
         else
            hasBrokenRange = false;
      }
      
      // After first pass, calculate the average zone height
      // and weight it a bit more to filter out big movements
      if (pass == 1)
         avgZoneHeight /= zonesCounter * Average_Weight;
      
      // Check if we have an open zone after pass 2
      if (pass == 2 && !hasBrokenRange && zoneSize >= Min_Zone_Width)
         AddZone(zones, zoneStart, 0, rangeLow, rangeHigh);
   }
  
//---
}
//+------------------------------------------------------------------+
//| Display zones on the chart                                       |
//+------------------------------------------------------------------+
void DrawZones(Zone &zones[])
{
//---  
    
   RemoveObjects();
   int zonesCounter = ArraySize(zones);
   for (int i = 0; i < zonesCounter; i++)
   {
      // Show the N last zones only
      if (Show_N_Last_Zones > 0 && i < zonesCounter - Show_N_Last_Zones)
         continue;
        
      string objName = "SD_Zone_" + IntegerToString(i);
      Zone zone = zones[i];
      ObjectCreate(objName, OBJ_RECTANGLE, 0, Time[zone.Start], zone.High, Time[zone.End], zone.Low);
      ObjectSetInteger(0, objName, OBJPROP_COLOR, Rectangle_Color);
      ObjectSetInteger(0, objName, OBJPROP_BACK, 1);
   }
  
//---
}
//+------------------------------------------------------------------+
//| Add a zone to the list                                           |
//+------------------------------------------------------------------+
void AddZone(Zone &zones[], int start, int end, double low, double high)
{
//---
  
   int size = ArraySize(zones);
   ArrayResize(zones, size + 1);
   zones[size].Start = start;
   zones[size].End = end;
   zones[size].Low = low;
   zones[size].High = high;
  
//---  
}  
//+------------------------------------------------------------------+
//| Remove our chart objects                                         |
//+------------------------------------------------------------------+
void RemoveObjects()
{
//---
  
   for (int i = ObjectsTotal(); i >= 0; i--)
   {
      string objName = ObjectName(i);
      if (StringFind(objName, "SD_Zone_") >= 0)
         ObjectDelete(objName);
   }
  
//---
}
//+------------------------------------------------------------------+