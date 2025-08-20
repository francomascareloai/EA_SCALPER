//+------------------------------------------------------------------+
//|                                                    InsideBar.mq4 |
//|                                      Copyright © 2006, Eli Hayun |
//|                                          http://www.elihayun.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Eli Hayun"
#property link      "http://www.elihayun.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//---- input parameters
extern int       NumPrevBars=4;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY, 4);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY, 4);
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
   int limit;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   for (int i=0; i<limit; i++)
   {
      ExtMapBuffer1[i] = 0; ExtMapBuffer2[i] = 0;
      if ( (Low[i] > Low[i+1]) && (High[i] < High[i+1]))
      {
         ExtMapBuffer1[i] = Close[i];
         ExtMapBuffer2[i] = Open[i];
      }
      double r0 = MathAbs(Open[i] - Close[i]);
      double r1 = MathAbs(Open[i+1] - Close[i+1]);
      double r2 = MathAbs(Open[i+2] - Close[i+2]);
      double r3 = MathAbs(Open[i+3] - Close[i+3]);
      double r4 = MathAbs(Open[i+4] - Close[i+4]);
      
      if (r0 < r1 && r0 < r2 && r0 < r3 && r0 < r4)
      {
         ExtMapBuffer1[i] = Close[i];
         ExtMapBuffer2[i] = Open[i];
      }       
   }
   if (ExtMapBuffer1[1]  != 0 && NewBar())
   {
      Comment(TimeToStr(Time[0])," Inside bar"); Print(Symbol(), " Inside bar");
      PlaySound("expert.wav");
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+

bool NewBar()
{
   static datetime dt  = 0;
   if (dt != Time[0])
   {
      dt = Time[0];
      return(true);
   }
   return(false);
}


