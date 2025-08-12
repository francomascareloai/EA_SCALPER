//+------------------------------------------------------------------+
//|                                                         TEMA.mq4 |
//|                      Copyright © 2007, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.ru/"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 DarkBlue
#property  indicator_width1  2
//---- input parameters
extern int       EMA_period=14;
//---- buffers
double TemaBuffer[];
double Ema[];
double EmaOfEma[];
double EmaOfEmaOfEma[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(4);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,TemaBuffer);
   SetIndexBuffer(1,Ema);
   SetIndexBuffer(2,EmaOfEma);
   SetIndexBuffer(3,EmaOfEmaOfEma);

   IndicatorShortName("TEMA("+EMA_period+")");
   
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
int start()
  {
   int i,limit,limit2,limit3,counted_bars=IndicatorCounted();
//----
   if (counted_bars==0)
      {
      limit=Bars-1;
      limit2=limit-EMA_period;
      limit3=limit2-EMA_period;
      }
   if (counted_bars>0)
      {
      limit=Bars-counted_bars-1;
      limit2=limit;
      limit3=limit2;
      }
   for (i=limit;i>=0;i--) Ema[i]=iMA(NULL,0,EMA_period,0,MODE_EMA,PRICE_CLOSE,i);
   for (i=limit2;i>=0;i--) EmaOfEma[i]=iMAOnArray(Ema,0,EMA_period,0,MODE_EMA,i);
   for (i=limit3;i>=0;i--) EmaOfEmaOfEma[i]=iMAOnArray(EmaOfEma,0,EMA_period,0,MODE_EMA,i);
   for (i=limit3;i>=0;i--) TemaBuffer[i]=3*Ema[i]-3*EmaOfEma[i]+EmaOfEmaOfEma[i];
//----
   return(0);
  }
//+------------------------------------------------------------------+