//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//by Gilani
// currencyTimeZone - adjust to the timezone of the relevant currency.
// serverTimeZone - timezone of the source of data source feed (+1 Russian zone for MetaTrader)
// blue bars represent open market hours
// red  bars represent close mrket hours
// the bars grows according to the hours of the day

#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

extern int currencyTimeZone = -5;
extern string market = "USA";
int serverTimeZone = +1;
int marketOpensAt = 8;
int marketClosesAt = 16;

double open[];
double close[];

int init()
  {
//---- indicators
//----
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,open);
   SetIndexLabel(0,"Blue");
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,close);
   SetIndexLabel(1,"Red");
//----
   IndicatorShortName("Trading Hours: "+market);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- TODO: add your code here
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int ExtCountedBars=IndicatorCounted();
   if(ExtCountedBars<0) return(-1);
   if(ExtCountedBars>0) ExtCountedBars--;
   limit=Bars-ExtCountedBars;

   for (int x=limit;x>=0;x--) {      
      int gmt = MathMod (24+TimeHour(Time[x])-serverTimeZone, 24);
      int hour = MathMod(24+currencyTimeZone+gmt, 24);

      if ((hour >= marketOpensAt) && (hour <= marketClosesAt)) {         

      if (hour==0) hour=24;
         open[x]=hour;
         close[x]=0;
      } else {
         if (hour==0) hour=24;
         open[x]=0;
         close[x]= -hour;
         
      }
   }
   
      return(0);
  }
//+------------------------------------------------------------------+