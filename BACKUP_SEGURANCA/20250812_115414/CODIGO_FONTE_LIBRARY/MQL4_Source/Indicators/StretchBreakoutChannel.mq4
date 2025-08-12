//+------------------------------------------------------------------+
//| StretchBreakoutChannel.mq4
//| Copyright http://www.pointzero-trading.com
//+------------------------------------------------------------------+
#property copyright "Copyright © Pointzero-trading.com"
#property link      "http://www.pointzero-trading.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 2
#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID

//-- External variables
extern int StPeriod   = 10;

//-- Buffers
double FextMapBuffer1[];
double FextMapBuffer2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
int init()
{   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0, FextMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,FextMapBuffer2);        
   IndicatorShortName("Stretch Breakout Channel ("+ StPeriod +")");
   Comment("Copyright © http://www.pointzero-trading.com");
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   // Start, limit, etc..
   int start = 0;
   int limit;
   int counted_bars = IndicatorCounted();
   
   // nothing else to do?
   if(counted_bars < 0) 
       return(-1);

   // do not check repeated bars
   limit = Bars - 1 - counted_bars;
   
   // Iteration
   for(int pos = limit; pos >= start; pos--)
   {
      int dshift = iBarShift(Symbol(), PERIOD_D1, Time[pos], false);
      double stretch = iCustom(Symbol(), PERIOD_D1, "Stretch", StPeriod, 0, dshift+1);
      double OPEN = iOpen(Symbol(),  PERIOD_D1, dshift);
      FextMapBuffer1[pos] = OPEN + stretch;
      FextMapBuffer2[pos] = OPEN - stretch;
   }
   return(0);
}