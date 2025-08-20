//+------------------------------------------------------------------+
//|                                                   Multi EMAs.mq4 |
//|                         Copyright © 2006, Ronald Verwer/ROVERCOM |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2006, Ronald Verwer/ROVERCOM"
//---- indicator settings
#property  indicator_chart_window
#property  indicator_buffers 3
#property  indicator_color1  Red
#property  indicator_color2  Green
#property  indicator_color3  Blue
#property  indicator_width1  2
#property  indicator_width2  2
#property  indicator_width3  2
//---- indicator parameters
extern int FirstEMA=5;
extern int SecondEMA=13;
extern int ThirdEMA=62;
extern int Price_Type=4;
//---- indicator buffers
double x1[];
double x2[];
double x3[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexDrawBegin(0,ThirdEMA);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);
//---- 3 indicator buffers mapping
   if(!SetIndexBuffer(0,x1) &&
      !SetIndexBuffer(1,x2) &&
      !SetIndexBuffer(2,x3))
      Print("cannot set indicator buffers!");
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("MultiEMA("+FirstEMA+","+SecondEMA+","+ThirdEMA+")");
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Multi Exponential Moving Averages                                |
//+------------------------------------------------------------------+
int start()
  {
   int i,limit;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//---- macd counted in the 1-st additional buffer
   for(i=limit; i>=0; i--)
      x1[i]=iMA(NULL,0,FirstEMA,0,MODE_EMA,Price_Type,i);//(High[i]+Low[i])/2,i);
   for(i=limit; i>=0; i--)
      x2[i] = iMAOnArray(x1,Bars,SecondEMA,0,MODE_EMA,i);
   for(i=limit; i>=0; i--)
      x3[i] = iMAOnArray(x2,Bars,ThirdEMA,0,MODE_EMA,i);
//---- done
   return(0);
  }
//+------------------------------------------------------------------+

