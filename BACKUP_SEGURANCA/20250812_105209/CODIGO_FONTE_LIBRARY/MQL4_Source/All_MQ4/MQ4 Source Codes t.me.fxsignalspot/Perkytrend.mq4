//+------------------------------------------------------------------+
//|                                                      Awesome.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
// Basically ADX mainline use..
//when the trend is moving up the histogram is green and rising.
// best signal - when the histgram moves from below the line to above
// it turns green - unless in range market suggests the trend has
// some strength.


#property  copyright "Another perky marvel."
#property  link      "perky_z@yahoo.com"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  Green
#property  indicator_color2  Red
//---- indicator buffers
double     ind_buffer1[];
double     ind_buffer2[];
double     ind_buffer3[];
extern int trendperiod=14;
extern int trendlowerlimit=20;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 1 additional buffer used for counting.
   IndicatorBuffers(3);
   //---- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,3);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,3);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
   SetIndexDrawBegin(0,34);
   SetIndexDrawBegin(1,34);
//---- 3 indicator buffers mapping
   if(!SetIndexBuffer(0,ind_buffer1) &&
      !SetIndexBuffer(1,ind_buffer2) &&
      !SetIndexBuffer(2,ind_buffer3))
      Print("cannot set indicator buffers!");
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("PerkyTrend");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Awesome Oscillator                                               |
//+------------------------------------------------------------------+
int start()
  {
   int    limit;
   int    counted_bars=IndicatorCounted();
   double prev,current;
//---- check for possible errors
   if(counted_bars<0) return(-1);
   //---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- macd counted in the 1-st additional buffer
   for(int i=0; i<limit; i++)
      ind_buffer3[i]=iADX(NULL,0,trendperiod,PRICE_CLOSE,MODE_MAIN,i)-trendlowerlimit;
//---- dispatch values between 2 buffers
   bool up=true;
   for(i=limit-1; i>=0; i--)
     {
      current=ind_buffer3[i];
      prev=ind_buffer3[i+1];
      if(current>prev) up=true;
      if(current<prev) up=false;
      if(!up)
        {
         ind_buffer2[i]=current;
         ind_buffer1[i]=0.0;
        }
      else
        {
         ind_buffer1[i]=current;
         ind_buffer2[i]=0.0;
        }
     }
//---- done
   return(0);
  }