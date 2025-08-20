//+------------------------------------------------------------------+
//| TheTurtleTradingChannel_Raw.mq4
//| Copyright © Pointzero-indicator.com
//+------------------------------------------------------------------+
#property copyright "Copyright © Pointzero-indicator.com"
#property link      "http://www.pointzero-indicator.com"

//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 DodgerBlue
#property indicator_color2 Red
#property indicator_color3 DarkSlateGray
#property indicator_color4 DarkSlateGray
#property indicator_width1 3
#property indicator_width2 3
#property indicator_width3 1
#property indicator_width4 1
#property indicator_style3 STYLE_DOT
#property indicator_style4 STYLE_DOT

//---- indicator parameters
extern bool CalculateOnBarClose = true;
extern int  TradePeriod         = 10;
extern int  StopPeriod          = 5;

//---- indicator buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   // Drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexStyle(3,DRAW_LINE);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   
   // Name and labels
   IndicatorShortName("Turtle Channel Raw("+ TradePeriod +"-"+ StopPeriod +")");
   SetIndexLabel(0,"Upper line");
   SetIndexLabel(1,"Lower line");
   SetIndexLabel(2,"Longs Stop line");
   SetIndexLabel(3,"Shorts Stop line");
   
   // Buffers
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(2,ExtMapBuffer3);    
   SetIndexBuffer(3,ExtMapBuffer4);
   
   // Us :-)
   Comment("Copyright © http://www.pointzero-indicator.com");
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
     // More vars here too...
     int start = 0;
     int limit;
     int counted_bars = IndicatorCounted();

     // check for possible errors
     if(counted_bars < 0) 
        return(-1);
        
     // Only check these
     limit = Bars - 1 - counted_bars;
     
     // Check if ignore bar 0
     if(CalculateOnBarClose == true) { start = 1; }
     
     // Check the signal foreach bar
     for(int i = limit; i >= start; i--)
     {           
         // Highs and lows
         double rhigh = iHigh(Symbol(),Period(),iHighest(Symbol(), Period(), MODE_HIGH, TradePeriod,i+1));
         double rlow  = iLow(Symbol(),Period(),iLowest(Symbol(), Period(), MODE_LOW, TradePeriod, i+1));
         double shigh = iHigh(Symbol(),Period(),iHighest(Symbol(), Period(), MODE_HIGH, StopPeriod,i+1));
         double slow  = iLow(Symbol(),Period(),iLowest(Symbol(), Period(), MODE_LOW, StopPeriod, i+1));
         
         // It might be recalculating bar zero
         ExtMapBuffer1[i] = rhigh;
         ExtMapBuffer2[i] = rlow;
         ExtMapBuffer3[i] = shigh;
         ExtMapBuffer4[i] = slow;
     }
   
   // Bye Bye
   return(0);
}