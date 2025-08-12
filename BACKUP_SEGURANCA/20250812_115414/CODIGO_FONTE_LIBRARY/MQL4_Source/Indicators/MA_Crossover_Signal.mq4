//+------------------------------------------------------------------+
//|                                         EMA-Crossover_Signal.mq4 |
//|         Copyright © 2005, Jason Robinson (jnrtrading)            |
//|                   http://www.jnrtading.co.uk                     |
//+------------------------------------------------------------------+

/*
  +------------------------------------------------------------------+
  | Allows you to enter two ema periods and it will then show you at |
  | Which point they crossed over. It is more usful on the shorter   |
  | periods that get obscured by the bars / candlesticks and when    |
  | the zoom level is out. Also allows you then to remove the emas   |
  | from the chart. (emas are initially set at 5 and 6)              |
  +------------------------------------------------------------------+
*/   
#property copyright "Copyright © 2005, Jason Robinson (jnrtrading)"
#property link      "http://www.jnrtrading.co.uk"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 DodgerBlue
#property indicator_color2 Red

double CrossUp[];
double CrossDown[];
extern int FasterMode = 1; //0=sma, 1=ema, 2=smma, 3=lwma
extern int FasterMA =   13;
extern int SlowerMode = 1; //0=sma, 1=ema, 2=smma, 3=lwma
extern int SlowerMA =   25;
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
   double fasterMAnow, slowerMAnow, fasterMAprevious, slowerMAprevious, fasterMAafter, slowerMAafter;
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
      for (counter=i ;counter<=i+9;counter++)
      {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
      }
      Range=AvgRange/10;
       
      fasterMAnow = iMA(NULL, 0, FasterMA, 0, FasterMode, PRICE_CLOSE, i);
      fasterMAprevious = iMA(NULL, 0, FasterMA, 0, FasterMode, PRICE_CLOSE, i+1);
      fasterMAafter = iMA(NULL, 0, FasterMA, 0, FasterMode, PRICE_CLOSE, i-1);

      slowerMAnow = iMA(NULL, 0, SlowerMA, 0, SlowerMode, PRICE_CLOSE, i);
      slowerMAprevious = iMA(NULL, 0, SlowerMA, 0, SlowerMode, PRICE_CLOSE, i+1);
      slowerMAafter = iMA(NULL, 0, SlowerMA, 0, SlowerMode, PRICE_CLOSE, i-1);
      
      if ((fasterMAnow > slowerMAnow) && (fasterMAprevious < slowerMAprevious) && (fasterMAafter > slowerMAafter)) {
         CrossUp[i] = Low[i] - Range*0.5;
      }
      else if ((fasterMAnow < slowerMAnow) && (fasterMAprevious > slowerMAprevious) && (fasterMAafter < slowerMAafter)) {
         CrossDown[i] = High[i] + Range*0.5;
      }
   }
   return(0);
}

