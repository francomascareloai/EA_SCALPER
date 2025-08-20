//+------------------------------------------------------------------+
//|                                                   VWAP_Close.mq4 |
//|                                                              STS |
//|                                                                  |
//+------------------------------------------------------------------+

#property link      ""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Indigo
#property indicator_width1 3
#property indicator_width2 3
//---- input parameters
extern int period=12;
extern int shift=0;
//---- buffers
double ExtMapBuffer1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexShift(0,shift);
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
//----
   int i,bar;
   bar = Bars-counted_bars;
   
   for (i=0;i<=bar;i++){
      double sum1,sum2;
      int ntmp;
      sum1=0;
      sum2=0;
      for (ntmp=0;ntmp<=period;ntmp++){
         sum1=sum1+Close[i+ntmp]*Volume[i+ntmp];
         sum2=sum2+Volume[i+ntmp];
      }
      
      if(sum2 > 0){
       ExtMapBuffer1[i]=sum1/sum2;
      }
   
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+