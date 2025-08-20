//+------------------------------------------------------------------+
//|    copyright:Ma ning
//    e-mail: maningok@163.com
//       msn:man2078@msn.com                                        
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red
#property indicator_level1 0
//---- buffers
double ha,ha1;
double signal[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM, 0, 1, Red);
   SetIndexBuffer(0, signal);
   SetIndexEmptyValue(0,0.0);
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
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
   for (int i=Bars-1;i>=0;i--)
   {
   ha1=ha; ha=iMA(NULL,0,3,0,MODE_EMA,PRICE_WEIGHTED,i);      
   signal[i]=ha-ha1;
   }
   //----
   return(0);
  }
//+------------------------------------------------------------------+