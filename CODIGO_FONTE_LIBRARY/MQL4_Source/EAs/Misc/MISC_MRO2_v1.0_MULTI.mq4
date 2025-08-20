//+------------------------------------------------------------------+
//|                                                         MRO2.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- input parameters
extern int       periodMRO2=7;
//---- buffers
double RatedRangeBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,RatedRangeBuffer);
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
   double Range,AvrRange;
   int shift,i;
   int    counted_bars=Bars-periodMRO2-1;
//---- TODO: add your code here
   for (shift=counted_bars;shift>=0;shift--)
      {
      Range=0.0;
      for (i=shift+1;i<=shift+periodMRO2;i++)
         {
         Range=Range+MathAbs(High[i]-Low[i]);
         };
      AvrRange=Range/periodMRO2;
      //RatedRangeBuffer[shift]=AvrRange/Point;
      RatedRangeBuffer[shift]=MathAbs(Close[shift+1]-Close[shift+4])/AvrRange;
      };   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+