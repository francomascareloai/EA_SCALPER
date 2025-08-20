//+------------------------------------------------------------------+
//|                                                         DEMA.mq4 |
//| DEMA = 2 * EMA - EMA of EMA													|
//+------------------------------------------------------------------+
#property link "http://www.forexfactory.com/showthread.php?t=29419"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1  Red
#property indicator_width1  1
//---- input parameters
extern int PERIOD  =12;
//---- indicator buffer
double Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName("DEMA("+PERIOD+")");
   SetIndexBuffer(0,Buffer);
   SetIndexStyle(0,DRAW_LINE);
  }
//+------------------------------------------------------------------+
int start()
  {
   int limit=Bars-1-IndicatorCounted();
//----
   static double lastEMA, lastEMA_of_EMA;
   double weight=2.0/(1.0+PERIOD);
   if(IndicatorCounted()==0)
     {
      Buffer[limit]  =Close[limit];
      lastEMA        =Close[limit];
      lastEMA_of_EMA  =Close[limit];
      limit--;
     }
//----
   //	Calculate old bars (not the latest), if necessary
   for(int i=limit; i > 0; i--)
     {
      lastEMA        =weight*Close[i]   + (1.0-weight)*lastEMA;
      lastEMA_of_EMA  =weight*lastEMA   + (1.0-weight)*lastEMA_of_EMA;
      Buffer[i]=2.0*lastEMA - lastEMA_of_EMA;
     }
//----
   //	(Re)calculate current bar
   double EMA        =weight*Close[0]   + (1.0-weight)*lastEMA,
   EMA_of_EMA  =weight*EMA      + (1.0-weight)*lastEMA_of_EMA;
   Buffer[0]=2.0*EMA - EMA_of_EMA;
//----
   return(0);
  }

//+------------------------------------------------------------------+