//+------------------------------------------------------------------+
//|                                                         Trix.mq4 |
//|                      Copyright © 2011, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//--- input parameters
extern int       EMA=8;
extern int       Signal=3;
//--- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
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
   int    counted_bars=IndicatorCounted();
   
   int nLimit = Bars - EMA;
   int i,a=0;

   double ema1, ema2, ema3;
   double ema2_last, ema3_last;
   double signal_ema, signal_ema_last;
   double k = 2.0 / (EMA+1);
   double k2 = 2.0/(Signal+1);
   double trix;

   for(i = nLimit; i >=0; i--,a++)
   {
         ema1 = iMA(NULL,0,EMA,0,MODE_EMA,PRICE_CLOSE,i);

         if(a == 0) ema2_last = ema1;
         else ema2_last = ema2;

         ema2 = (ema1 * k) + (ema2_last * (1 - k));

         if(a == 0) ema3_last = ema2;
         else ema3_last = ema3;

         ema3 = (ema2 * k) + (ema3_last * (1 - k));

         trix = ( ema3 - ema3_last ) / ema3_last;

         if(a == 0) signal_ema_last = trix;
         else signal_ema_last = signal_ema;

         signal_ema = (trix * k2) + (signal_ema_last * (1 - k2));
         
         ExtMapBuffer1[i] = trix;
         ExtMapBuffer2[i] = signal_ema;
   }
   
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+

