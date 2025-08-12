//+------------------------------------------------------------------+
//|                                                  rsi extreme.mq4 |
//|                                           Author: LordoftheMoney |
//|                                Expert advisor is in the codebase |
//|                                                    (Easiest RSI) |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_width1 1
#property indicator_width2 1
#property indicator_color1 DodgerBlue
#property indicator_color2 DodgerBlue
extern int rsiperiod = 14;
double buffy1[];
double buffy2[];
int cb=0;
int bar;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   int  draw;
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,233);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,234);
   SetIndexEmptyValue(0,0.0);
   SetIndexLabel(0,"buy");
   SetIndexLabel(1,"sell");
   SetIndexDrawBegin(0,draw);
   SetIndexDrawBegin(1,draw);
   SetIndexBuffer(0,buffy1);
   SetIndexBuffer(1,buffy2);
   return(0);
  }
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsDeleteAll(0,OBJ_ARROW);
   return(0);
  }
//+------------------------------------------------------------------+
int start()
  {
   if (bar==Time[0]) return(0);
   int cb=IndicatorCounted();
   int x;
   if(Bars<=100) return(0);
   if (cb<0) return(-1);
   if (cb>0) cb--;
   x=Bars-cb;
   for(int i=0; i<x; i++)
   {
    double r1 = iRSI(NULL,0,rsiperiod,PRICE_CLOSE,i);
    double r2 = iRSI(NULL,0,rsiperiod,PRICE_CLOSE,i+1);
     if (r1>30 && r2<30)
      buffy1[i] = Low[i+1];
     bar=Time[0]; 
     if (r1<70 && r2>70)
      buffy2[i] = High[i+1];
     bar=Time[0]; 
   } 

   return(0);
  }
//+------------------------------------------------------------------+