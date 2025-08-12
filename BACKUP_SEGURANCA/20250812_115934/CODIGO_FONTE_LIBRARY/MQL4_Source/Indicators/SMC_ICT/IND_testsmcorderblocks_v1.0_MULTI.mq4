//+------------------------------------------------------------------+
//|                                           SMC Order Blocks      |
//|                                  Copyright 2024, SMC Trader     |
//|                                             https://smc.com     |
//+------------------------------------------------------------------+
#property copyright "SMC Trader"
#property link      "https://smc.com"
#property version   "1.5"
#property strict
#property indicator_chart_window
#property indicator_buffers 4

// Indicator buffers
double BullishOB[];
double BearishOB[];
double FVG_Up[];
double FVG_Down[];

// Input parameters
input int LookbackPeriod = 50;       // Lookback period for order blocks
input bool ShowFVG = true;           // Show Fair Value Gaps
input bool ShowBOS = true;           // Show Break of Structure
input bool ShowCHoCH = true;         // Show Change of Character
input color BullishColor = clrBlue;  // Bullish order block color
input color BearishColor = clrRed;   // Bearish order block color

// Global variables
double lastHigh, lastLow;
int swingHighIndex, swingLowIndex;
bool marketStructure = true; // true = bullish, false = bearish

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   // Set indicator buffers
   SetIndexBuffer(0, BullishOB);
   SetIndexBuffer(1, BearishOB);
   SetIndexBuffer(2, FVG_Up);
   SetIndexBuffer(3, FVG_Down);
   
   // Set indicator styles
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexStyle(3, DRAW_ARROW);
   
   SetIndexArrow(0, 233); // Up arrow for bullish OB
   SetIndexArrow(1, 234); // Down arrow for bearish OB
   SetIndexArrow(2, 159); // FVG up
   SetIndexArrow(3, 159); // FVG down
   
   // Set colors
   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID, 2, BullishColor);
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, 2, BearishColor);
   
   // Set indicator name
   IndicatorShortName("SMC Order Blocks & FVG");
   
   Print("SMC Order Blocks indicator initialized");
   return(INIT_SUCCEEDED);
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
   int start = prev_calculated;
   if(start == 0) start = LookbackPeriod;
   
   for(int i = start; i < rates_total - 1; i++)
   {
      // Initialize buffers
      BullishOB[i] = EMPTY_VALUE;
      BearishOB[i] = EMPTY_VALUE;
      FVG_Up[i] = EMPTY_VALUE;
      FVG_Down[i] = EMPTY_VALUE;
      
      // Detect order blocks
      DetectOrderBlocks(i, high, low, close, open);
      
      // Detect Fair Value Gaps
      if(ShowFVG)
         DetectFVG(i, high, low, close);
      
      // Detect market structure changes
      if(ShowBOS || ShowCHoCH)
         DetectMarketStructure(i, high, low);
   }
   
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Detect Order Blocks                                             |
//+------------------------------------------------------------------+
void DetectOrderBlocks(int index, const double &high[], const double &low[], 
                      const double &close[], const double &open[])
{
   if(index < LookbackPeriod) return;
   
   // Look for bullish order block
   bool isBullishOB = false;
   for(int j = 1; j <= LookbackPeriod; j++)
   {
      if(close[index-j] > open[index-j] && // Green candle
         high[index-j+1] < high[index-j] && // Previous high broken
         low[index] > low[index-j]) // Current low above OB low
      {
         isBullishOB = true;
         break;
      }
   }
   
   if(isBullishOB)
      BullishOB[index] = low[index] - 10 * Point;
   
   // Look for bearish order block
   bool isBearishOB = false;
   for(int j = 1; j <= LookbackPeriod; j++)
   {
      if(close[index-j] < open[index-j] && // Red candle
         low[index-j+1] > low[index-j] && // Previous low broken
         high[index] < high[index-j]) // Current high below OB high
      {
         isBearishOB = true;
         break;
      }
   }
   
   if(isBearishOB)
      BearishOB[index] = high[index] + 10 * Point;
}

//+------------------------------------------------------------------+
//| Detect Fair Value Gaps                                          |
//+------------------------------------------------------------------+
void DetectFVG(int index, const double &high[], const double &low[], const double &close[])
{
   if(index < 3) return;
   
   // Bullish FVG: Gap between candle 1 high and candle 3 low
   if(low[index-2] > high[index] && close[index-1] > close[index-2])
   {
      FVG_Up[index-1] = low[index-2];
   }
   
   // Bearish FVG: Gap between candle 1 low and candle 3 high  
   if(high[index-2] < low[index] && close[index-1] < close[index-2])
   {
      FVG_Down[index-1] = high[index-2];
   }
}

//+------------------------------------------------------------------+
//| Detect Market Structure (BOS/CHoCH)                             |
//+------------------------------------------------------------------+
void DetectMarketStructure(int index, const double &high[], const double &low[])
{
   if(index < 10) return;
   
   // Find swing highs and lows
   bool isSwingHigh = true;
   bool isSwingLow = true;
   
   for(int j = 1; j <= 5; j++)
   {
      if(high[index-j] >= high[index-5] || high[index-j+1] >= high[index-5])
         isSwingHigh = false;
      if(low[index-j] <= low[index-5] || low[index-j+1] <= low[index-5])
         isSwingLow = false;
   }
   
   // Update market structure
   if(isSwingHigh && high[index] > lastHigh)
   {
      if(!marketStructure) // Was bearish, now bullish = CHoCH
         Comment("CHoCH Detected - Bullish at ", TimeToStr(Time[index]));
      else // Was bullish, still bullish = BOS
         Comment("BOS Detected - Bullish at ", TimeToStr(Time[index]));
      
      marketStructure = true;
      lastHigh = high[index];
   }
   
   if(isSwingLow && low[index] < lastLow)
   {
      if(marketStructure) // Was bullish, now bearish = CHoCH
         Comment("CHoCH Detected - Bearish at ", TimeToStr(Time[index]));
      else // Was bearish, still bearish = BOS
         Comment("BOS Detected - Bearish at ", TimeToStr(Time[index]));
      
      marketStructure = false;
      lastLow = low[index];
   }
}