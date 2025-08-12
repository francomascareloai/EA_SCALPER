//+------------------------------------------------------------------+
//|                                                    FN Signal.mq4 |
//|                                                          Belomor |
//|                                                 belomor@inbox.ru |
//+------------------------------------------------------------------+
#property copyright "Belomor"
#property link      "belomor@inbox.ru"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Silver
//---- input parameters
extern int       FN=34;
extern double    Deviation=3.0;
extern int       FastEMA=5;
extern int       SlowEMA=13;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(4);
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,3);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,3);
   SetIndexStyle(2,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexBuffer(3,ExtMapBuffer4);
   if(FN<2)
   FN=2;
   if(Deviation<0)
   Deviation=1;
   if(FastEMA<1)
   FastEMA=1;
   if(SlowEMA<1)
   SlowEMA=1;
   IndicatorShortName("FNCD ("+FN+","+FastEMA+","+SlowEMA+")");
   SetIndexDrawBegin(0,FN+SlowEMA);
   SetIndexDrawBegin(1,FN+SlowEMA);
   SetIndexLabel(0,"FN Up");
   SetIndexLabel(1,"FN Down");
   SetIndexEmptyValue(0,0);
   SetIndexEmptyValue(1,0);
   IndicatorDigits(4);
//----
   return(0);
  }
  
double NormalizedX(int F_period, int i)
   {
   double result;
   double A;
   double S;
   double C;
   if(i<Bars-F_period)
   {
   C=Close[i];
   A=iMA(NULL,0,F_period,0,MODE_SMA,PRICE_CLOSE,i);
   S=iStdDev(NULL,0,F_period,MODE_SMA,0,PRICE_CLOSE,i);
   result=(C-A)/S;
   }
   else
   result=0;
   return(result);
   }
   
double FisherNormalizedX(int F_period, double Dev, int i)
   {
   double result;
   double X;
   if(i<Bars-F_period && Dev>0)
   {
   X=NormalizedX(F_period,i)/Dev;
   if(X>0.99)
   X=0.99;
   if(X<-0.99)
   X=-0.99;
   result=0.5*MathLog((1+X)/(1-X));
   }
   else
   result=0;
   return(result);
   }
   
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars=IndicatorCounted();
//---- check for possible errors
   if(counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   for(int i=0; i<limit; i++)
      ExtMapBuffer4[i]=FisherNormalizedX(FN,Deviation,i);
   for(i=0; i<limit; i++)
      ExtMapBuffer3[i]=iMAOnArray(ExtMapBuffer4,Bars,SlowEMA,0,MODE_EMA,i);
   for(i=0; i<limit; i++)
      {
      if(iMAOnArray(ExtMapBuffer4,Bars,FastEMA,0,MODE_EMA,i)>ExtMapBuffer3[i])
         {
         ExtMapBuffer1[i]=iMAOnArray(ExtMapBuffer4,Bars,FastEMA,0,MODE_EMA,i);
         ExtMapBuffer2[i]=0;
         }
      else
         {
         ExtMapBuffer1[i]=0;
         ExtMapBuffer2[i]=iMAOnArray(ExtMapBuffer4,Bars,FastEMA,0,MODE_EMA,i);
         }
      }
//---- done
   return(0);
  }
//+------------------------------------------------------------------+