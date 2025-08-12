//+------------------------------------------------------------------+
//|                                        Test Trend Indicator.mq4 |
//|                        Copyright 2025, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrBlue
#property indicator_color2 clrRed

// Input parameters
input int FastMA = 10;
input int SlowMA = 20;
input ENUM_MA_METHOD MAMethod = MODE_SMA;
input ENUM_APPLIED_PRICE AppliedPrice = PRICE_CLOSE;

// Indicator buffers
double FastBuffer[];
double SlowBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   // Set indicator buffers
   SetIndexBuffer(0, FastBuffer);
   SetIndexBuffer(1, SlowBuffer);
   
   // Set indicator labels
   SetIndexLabel(0, "Fast MA");
   SetIndexLabel(1, "Slow MA");
   
   // Set indicator style
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2);
   
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
   int limit = rates_total - prev_calculated;
   if(prev_calculated > 0) limit++;
   
   for(int i = 0; i < limit; i++)
   {
      FastBuffer[i] = iMA(Symbol(), Period(), FastMA, 0, MAMethod, AppliedPrice, i);
      SlowBuffer[i] = iMA(Symbol(), Period(), SlowMA, 0, MAMethod, AppliedPrice, i);
   }
   
   return(rates_total);
}