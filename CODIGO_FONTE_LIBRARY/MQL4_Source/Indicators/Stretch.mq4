//+------------------------------------------------------------------+
//| Stretch.mq4
//| Copyright http://www.pointzero-trading.com
//+------------------------------------------------------------------+
#property copyright "Copyright © Pointzero-trading.com"
#property link      "http://www.pointzero-trading.com"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 MediumSeaGreen
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 1
#property indicator_style2 STYLE_DOT
#define MaMethod 2

//--External variables
extern int StPeriod   = 10;
extern int AvPeriod   = 12;

//-- Buffers
double FextMapBuffer1[];
double FextMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
int init()
  {
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,FextMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,FextMapBuffer2);
   IndicatorShortName("Stretch ("+StPeriod+","+AvPeriod+")");
   Comment("Copyright © http://www.pointzero-trading.com");
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
// Start, limit, etc..
   int start=1;
   int limit;
   int counted_bars=IndicatorCounted();

// nothing else to do?
   if(counted_bars < 0)        return(-1);
   if(counted_bars>0) counted_bars--;

// do not check repeated bars
   limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+StPeriod;

// Iteration
   for(int pos=limit; pos>=start; pos--)
     {
      // Stretch for today
      double sum=0;
      FextMapBuffer1[pos]=EMPTY_VALUE;
      for(int i=0; i<StPeriod; i++)
        {
         double oh = MathAbs(High[pos+i] - Open[pos+i]);
         double ol = MathAbs(Open[pos+i] - Low[pos+i]);
         if(ol<oh) sum+=ol; else sum+=oh;
        }
      FextMapBuffer1[pos]=sum/StPeriod;
     }
   for(pos=limit; pos>=start; pos--) FextMapBuffer2[pos]=iMAOnArray(FextMapBuffer1,Bars,AvPeriod,0,MaMethod,pos);
   return(0);
  }
//+------------------------------------------------------------------+
