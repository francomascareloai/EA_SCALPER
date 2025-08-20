//+------------------------------------------------------------------+
//|                                         SMA-Crossover_Signal.mq4 |
//|         Copyright © 2005, Jason Robinson (jnrtrading)            |
//|                   http://www.jnrtading.co.uk                     |
//+------------------------------------------------------------------+

/*
  +-------------------------------------------------------------------+
  | Allows you to enter two sma periods and it will then show you at |
  | Which point they crossed over. It is more usful on the shorter    |
  | periods that get obscured by the bars / candlesticks and when     |
  | the zoom level is out. Also allows you then to remove the emas    |
  | from the chart. (smas are initially set at 9 and 18)              |
  +-------------------------------------------------------------------+
*/   
#property copyright "Copyright © 2005, Jason Robinson (jnrtrading)"
#property link      "http://www.jnrtrading.co.uk"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 SpringGreen
#property indicator_color2 Red

double CrossUp[];
double CrossDown[];
extern int FasterSMA = 9;
extern int SlowerSMA = 18;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_ARROW, EMPTY);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, CrossUp);
   SetIndexStyle(1, DRAW_ARROW, EMPTY);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, CrossDown);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
   int limit, i, counter;
   double fasterSMAnow, slowerSMAnow, fasterSMAprevious, slowerSMAprevious, fasterSMAafter, slowerSMAafter;
   double Range, AvgRange;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;

   limit=Bars-counted_bars;
   
   for(i = 0; i <= limit; i++) {
   
      counter=i;
      Range=0;
      AvgRange=0;
      for (counter=i ;counter<=i+9;counter++) {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
      }
      Range=AvgRange/10;
       
      fasterSMAnow = iMA(NULL, 0, FasterSMA, 0, MODE_SMA, PRICE_CLOSE, i);
      fasterSMAprevious = iMA(NULL, 0, FasterSMA, 0, MODE_SMA, PRICE_CLOSE, i+1);
      fasterSMAafter = iMA(NULL, 0, FasterSMA, 0, MODE_SMA, PRICE_CLOSE, i-1);

      slowerSMAnow = iMA(NULL, 0, SlowerSMA, 0, MODE_SMA, PRICE_CLOSE, i);
      slowerSMAprevious = iMA(NULL, 0, SlowerSMA, 0, MODE_SMA, PRICE_CLOSE, i+1);
      slowerSMAafter = iMA(NULL, 0, SlowerSMA, 0, MODE_SMA, PRICE_CLOSE, i-1);
      
      if ((fasterSMAnow > slowerSMAnow) && (fasterSMAprevious < slowerSMAprevious) && (fasterSMAafter > slowerSMAafter)) {
         CrossUp[i] = Low[i] - Range*0.5;
      }
      else if ((fasterSMAnow < slowerSMAnow) && (fasterSMAprevious > slowerSMAprevious) && (fasterSMAafter < slowerSMAafter)) {
         CrossDown[i] = High[i] + Range*0.5;
      }
   }
   return(0);
}

