//+------------------------------------------------------------------+
//|                                                    Filter_AO.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2004, MetaQuotes Software Corp."
#property  link      "http://www.metaquotes.net/"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  Lime
#property  indicator_color2  Red
//---- indicator buffers
double     ind_buffer1[];
double     ind_buffer2[];
double     ind_buffer3[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- 1 additional buffer used for counting.
   IndicatorBuffers(3);
   //---- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,2);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
   SetIndexDrawBegin(0,34);
   SetIndexDrawBegin(1,34);
//---- 3 indicator buffers mapping
   if(!SetIndexBuffer(0,ind_buffer1) &&
      !SetIndexBuffer(1,ind_buffer2) &&
      !SetIndexBuffer(2,ind_buffer3))
      Print("cannot set indicator buffers!");
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("Filter_AO");
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
      ind_buffer3[i]=iMA(NULL,0,15,0,MODE_EMA,PRICE_CLOSE,i)-iMA(NULL,0,102,0,MODE_EMA,PRICE_CLOSE,i);
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