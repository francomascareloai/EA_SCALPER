//+------------------------------------------------------------------+
//|                                      SitaringMultiCandleTime.mq4 |
//|                                           Written by: SitaringFX |
//|                      Copyright © 2009, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

extern color FontColor=Lime;
extern int Corner=2;
extern int X = 10;
extern int Y = 10;
extern bool ShowM1=true;
extern bool ShowM5=true;
extern bool ShowM15=true;
extern bool ShowM30=true;
extern bool ShowH1=true;
extern bool ShowH4=false;
extern bool ShowD1=false;
extern bool ShowW1=false;
extern bool ShowMN1=false;
extern int FontSize=16;

int init()
  {
//---- indicators
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
   int can_time1, can_time5, can_time15, can_time30, can_time_h1, can_time_h4;
   int can_time_d1, can_time_w1, can_time_mn1;
   int sec;
   
   can_time1 = 60-(TimeCurrent()-iTime(Symbol(), PERIOD_M1,0)) ;
   can_time5 = 60*5-(TimeCurrent()-iTime(Symbol(), PERIOD_M5,0)) ;
   sec = can_time5 % 60;
   can_time5 = can_time5 / 60;
   can_time15 = (60*15-(TimeCurrent()-iTime(Symbol(), PERIOD_M15,0)))/60;
   can_time30 = (60*30-(TimeCurrent()-iTime(Symbol(), PERIOD_M30,0)))/60;
   can_time_h1 = (60*60-(TimeCurrent()-iTime(Symbol(), PERIOD_H1,0)))/60 ;
   can_time_h4 = (60*240-(TimeCurrent()-iTime(Symbol(), PERIOD_H4,0)))/60 ;
   can_time_d1 = (60*1440-(TimeCurrent()-iTime(Symbol(), PERIOD_D1,0)))/60 ;
   can_time_w1 = (60*10080-(TimeCurrent()-iTime(Symbol(), PERIOD_W1,0)))/60;
   can_time_mn1 = (60*43200-(TimeCurrent()-iTime(Symbol(), PERIOD_W1,0)))/60;
   
   string showtime="";
   if (ShowM1) showtime = showtime + "|M1=" + can_time1; 
   if (ShowM5) showtime = showtime + "|M5=" + can_time5 +":" + sec;
   if (ShowM15) showtime = showtime + "|M15=" + can_time15 +":" + sec;
   if (ShowM30) showtime = showtime + "|M30=" + can_time30 +":" + sec;
   if (ShowH1) showtime = showtime + "|H1=" + can_time_h1 +":" + sec;
   if (ShowH4) showtime = showtime + "|H4=" + can_time_h4 +":" + sec;
   if (ShowD1) showtime = showtime + "|D1=" + can_time_d1 +":" + sec;
   if (ShowW1) showtime = showtime + "|W1=" + can_time_w1 +":" + sec;
   if (ShowMN1) showtime = showtime + "|MN1=" + can_time_mn1 +":" + sec;
   
   
   string objName = "Sit_Candle";  
   ObjectDelete(objName);
   ObjectCreate(objName,OBJ_LABEL,0,0,0);
   ObjectSetText(objName,showtime,FontSize,"Arial",FontColor);
   ObjectSet(objName,OBJPROP_CORNER, Corner);
   ObjectSet(objName, OBJPROP_XDISTANCE, X);
   ObjectSet("Sit_Candle", OBJPROP_YDISTANCE, Y); 
  
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+