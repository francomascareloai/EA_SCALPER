//+------------------------------------------------------------------+
//|                                      Elliott Wave Oscillator.mq4 |
//|                                                tonyc2a@yahoo.com |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "tonyc2a@yahoo.com"
#property link      ""

#property indicator_separate_window
#property indicator_color1 DarkKhaki

//---- buffers
double Buffer1[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexBuffer(0,Buffer1);
   SetIndexLabel(0,"EWO");
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
int start()
  {
   int    counted_bars=IndicatorCounted();
   double MA5,MA35;
//---- TODO: add your code here
   for(int i=Bars;i>=0;i--){
      MA5=iMA(NULL,0,5,0,MODE_SMA,PRICE_MEDIAN,i);
      MA35=iMA(NULL,0,35,0,MODE_SMA,PRICE_MEDIAN,i);
      
      Buffer1[i]=MA5-MA35;
      }
//----
   return(0);
  }
//+------------------------------------------------------------------+