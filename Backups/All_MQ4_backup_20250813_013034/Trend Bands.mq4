//+------------------------------------------------------------------+
//|                                                  Trend Bands.mq4 |
//|                                              Dwt5 and adoleh2000 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Yellow
#property indicator_color2 Magenta
#property indicator_color3 Yellow


double upper[], middle1[], middle2, lower[];
extern int period = 34;


int init()
  {
   SetIndexStyle(0,DRAW_LINE,EMPTY,2);
   SetIndexShift(0,0);
   SetIndexDrawBegin(0,0);
   SetIndexBuffer(0,upper);

   SetIndexStyle(1,DRAW_LINE,EMPTY,3);
   SetIndexShift(1,0);
   SetIndexDrawBegin(1,0);
   SetIndexBuffer(1,middle1);
   
   SetIndexStyle(2,DRAW_LINE,EMPTY,2);
   SetIndexShift(2,0);
   SetIndexDrawBegin(2,0);
   SetIndexBuffer(2,lower);
    

//---- indicators
//----
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
int start() {
   int limit;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   double avg;
   
   for(int x=0; x<limit; x++) {
      middle1[x] = iMA(NULL, 0, period, 0, MODE_EMA, PRICE_TYPICAL, x);// drawn line
      middle2= iMA(NULL, 0, period, 0, MODE_SMA, PRICE_TYPICAL, x);// only used to calculate outer bands

      avg  = findAvg(period, x);
      upper[x] = middle2 + (3.5*avg);
      lower[x] = middle2 - (3.5*avg);
   }
   return(0);
  }
//+------------------------------------------------------------------+


   double findAvg(int period, int shift) {
      double sum=0;
      for (int x=shift;x<(shift+period);x++) {     
         sum += High[x]-Low[x];
      }
      sum = sum/period;
      return (sum);
   }