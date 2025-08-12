//+------------------------------------------------------------------+
//|                                                                  |
//|                 Copyright © 1999-2008, MetaQuotes Software Corp. |
//|                                         http://www.metaquotes.ru |
//+------------------------------------------------------------------+
#property copyright "© 2007 Takbir"
#property link      "www.stigal.com"
//----
#define major   1
#define minor   1
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_width1  1
#property indicator_width2  1
//----
double UpperFr[];
double LowerFr[];
//----
int Bars_left=5;
int Bars_right=5;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void init()
  {
   SetIndexBuffer(0, UpperFr);
   SetIndexBuffer(1, LowerFr);
   //
   SetIndexEmptyValue(0, 0);
   SetIndexEmptyValue(1, 0);
   //
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 217);
   //
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 218);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void start()
  {
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+Bars_left;
//-----
   double dy=0;
     for(int i=1; i<=20; i++) 
     {
      dy+=0.3*(High[i]-Low[i])/20;
     }
   for(i=1+Bars_right; i<=limit+Bars_left; i++)
     {
      UpperFr[i]=0;
      LowerFr[i]=0;
//----
      if (IsUpperFr(i)) UpperFr[i]=High[i] + dy;
      if (IsLowerFr(i)) LowerFr[i]=Low[i] - dy;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsUpperFr(int bar)
  {
   for(int i=1; i<=Bars_left; i++)
     {
      if (bar+i>=Bars) return(false);

      if (High[bar] < High[bar+i]) return(false);
     }
   for(i=1; i<=Bars_right; i++)
     {
      if (bar-i < 0) return(false);
      if (High[bar] < High[bar-i]) return(false);
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsLowerFr(int bar)
  {
   for(int i=1; i<=Bars_left; i++)
     {
      if (bar+i>=Bars) return(false);
      if (Low[bar] > Low[bar+i]) return(false);
     }
   for(i=1; i<=Bars_right; i++)
     {
      if (bar-i < 0) return(false);
      if (Low[bar] > Low[bar-i]) return(false);
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+