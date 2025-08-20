//+------------------------------------------------------------------+
//|                                                 MACD_4in1_v2.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|   Legend's settings can be "extern" to be adjustable in MT4.     |
//|   Use TF1_Color etc. and not indicator's color to synchronize    |
//|   indicator and legend's colors. Switch timeframe for immediate  |
//|   update if it's not. (HCY)                                      |
//+-------------------------------------------------------------------
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
#property link      "cja"
#property link      "HOH CHEE YEN"
//----   
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 DeepSkyBlue
#property indicator_color4 DeepSkyBlue
#property indicator_color5 LawnGreen
#property indicator_color6 LawnGreen
#property indicator_color7 Orange
#property indicator_color8 Orange
#property indicator_width1 1
#property indicator_style2 2
#property indicator_width3 1
#property indicator_style4 2
#property indicator_width5 1
#property indicator_style6 2
#property indicator_width7 1
#property indicator_style8 2
#property indicator_level1 0
// Different Currencies may need different Factors to help
// separate the different MACD lines - raise the Factor # on the 
// largest moving MACD lines to enlarge the view of the other 3 MACD Timeframes.
extern double TF1_Factor=12;
extern double TF2_Factor=6;
extern double TF3_Factor=2;
extern double TF4_Factor=1;
/* 
Original setings (HCY)
extern double    MACD_FactorH1 =12;
extern double    MACD_FactorM15=6;
extern double    MACD_FactorM5=2;
extern double    MACD_FactorM1=1;
*/
// Definable timeframes (HCY)
extern int TF1=240;
extern int TF2=60;
extern int TF3=15;
extern int TF4=5;
// Synchronize indicator's and legend's color (HCY)
extern color TF1_Color=Red;
extern color TF2_Color=DeepSkyBlue;
extern color TF3_Color=LawnGreen;
extern color TF4_Color=Orange;
//---- Below can be "extern" to be adjustable in MT4 (HCY)
string Legend_Font="Arial Bold";
int Legend_FontSize=8;
int Legend_StartAt=90;
int Legend_Space=25;
int Legend_YPosition=0;
//--------------------------------------------------------------
int LegendXPos=0;
//---- input parameters
/* 
Settings for different periods (Own preferences): (HCY)
MN,WK,D1:22,11,8 -- D1:11,22,8
WK,D1,H4:30,13,10 -- H4:13,30,10
D1,H4,H1:24,11,8 -- H1:11,24,8
H4,H1,M15:15,7,5 -- M15:7,15,5
H1,M15,M5:12(or 13),6,4 -- M5:6,12,4
M15,M5,M1:15,7,5 -- M1:7,15,5
*/
extern int FastEMA=12;  //8  Faster settings
extern int SlowEMA=26;  //17
extern int SignalSMA=9; //9 
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];
double ExtMapBuffer7[];
double ExtMapBuffer8[];
// Indicator name (HCY)
string IndicatorName="MACD_4in1";
// Set shorter indicator name (HCY)
// string IndicatorName = "M4in1";
// Show proper timeframe string (HCY)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  string GetTimeFrameStr(int TimeFrame) 
  {
   if (TimeFrame==0) TimeFrame=Period();
   switch(TimeFrame)
     {
      case 1 : string TimeFrameStr="M1"; break;
      case 5 : TimeFrameStr="M5"; break;
      case 15 : TimeFrameStr="M15"; break;
      case 30 : TimeFrameStr="M30"; break;
      case 60 : TimeFrameStr="H1"; break;
      case 240 : TimeFrameStr="H4"; break;
      case 1440 : TimeFrameStr="D1"; break;
      case 10080 : TimeFrameStr="W1"; break;
      case 43200 : TimeFrameStr="MN1"; break;
      default : TimeFrameStr="CUR";
     }
   return(TimeFrameStr);
  }
// Show legend (HCY)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  void ShowLegend(int TimeFrame,string LegendName,color LegendColor) 
  {
   if (TimeFrame==0) TimeFrame=Period();
   string TimeFrameStr=GetTimeFrameStr(TimeFrame);
   // Enlarge legend for current timeframe (HCY)
   ObjectCreate(LegendName, OBJ_LABEL, WindowFind(IndicatorName), 0, 0);
     if (Period()==TimeFrame) 
     {
      ObjectSetText(LegendName, TimeFrameStr, Legend_FontSize+Legend_FontSize/3, Legend_Font, LegendColor);
      ObjectSet(LegendName, OBJPROP_CORNER, 0);
      ObjectSet(LegendName, OBJPROP_XDISTANCE, LegendXPos);
      ObjectSet(LegendName, OBJPROP_YDISTANCE, Legend_YPosition);
      LegendXPos=LegendXPos+Legend_Space+Legend_Space/4;
     }
     else 
     {
      ObjectSetText(LegendName, TimeFrameStr, Legend_FontSize, Legend_Font, LegendColor);
      ObjectSet(LegendName, OBJPROP_CORNER, 0);
      ObjectSet(LegendName, OBJPROP_XDISTANCE, LegendXPos);
      ObjectSet(LegendName, OBJPROP_YDISTANCE, Legend_YPosition);
      LegendXPos=LegendXPos+Legend_Space;
     }
   if (StringLen(TimeFrameStr)>2) LegendXPos=LegendXPos+Legend_Space/3;
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorName=IndicatorName+" ("+GetTimeFrameStr(Period())+")";
   IndicatorShortName(IndicatorName);
//---- indicators
   // Synchronize legend and line's colors (HCY)
   SetIndexStyle(0,DRAW_LINE,EMPTY,EMPTY,TF1_Color);
   //   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   // No value displayed at left corner (HCY)
   SetIndexLabel(0,NULL);
   // Synchronize legend and line's colors (HCY)
   SetIndexStyle(1,DRAW_LINE,EMPTY,EMPTY,TF1_Color);
   //   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   // No value displayed at left corner (HCY)
   SetIndexLabel(1,NULL);
   // Synchronize legend and line's colors (HCY)
   SetIndexStyle(2,DRAW_LINE,EMPTY,EMPTY,TF2_Color);
   //   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,ExtMapBuffer3);
   // No value displayed at left corner (HCY)
   SetIndexLabel(2,NULL);
   // Synchronize legend and line's colors (HCY)
   SetIndexStyle(3,DRAW_LINE,EMPTY,EMPTY,TF2_Color);
   //   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,ExtMapBuffer4);
   // No value displayed at left corner (HCY)
   SetIndexLabel(3,NULL);
   // Synchronize legend and line's colors (HCY)
   SetIndexStyle(4,DRAW_LINE,EMPTY,EMPTY,TF3_Color);
   //   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,ExtMapBuffer5);
   // No value displayed at left corner (HCY)
   SetIndexLabel(4,NULL);
   // Synchronize legend and line's colors (HCY)
   SetIndexStyle(5,DRAW_LINE,EMPTY,EMPTY,TF3_Color);
   //   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,ExtMapBuffer6);
   // No value displayed at left corner (HCY)
   SetIndexLabel(5,NULL);
   // Synchronize legend and line's colors (HCY)
   SetIndexStyle(6,DRAW_LINE,EMPTY,EMPTY,TF4_Color);
   //   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,ExtMapBuffer7);
   // No value displayed at left corner (HCY)
   SetIndexLabel(6,NULL);
   // Synchronize legend and line's colors (HCY)
   SetIndexStyle(7,DRAW_LINE,EMPTY,EMPTY,TF4_Color);
   //   SetIndexStyle(7,DRAW_LINE);
   SetIndexBuffer(7,ExtMapBuffer8);
   // No value displayed at left corner (HCY)
   SetIndexLabel(7,NULL);
   // Show legends. (HCY)
   // Note: MT4 is not always sensitive to unload this indicator and initialize to change
   // legend and line colors. Simply switch timeframe for immediate update. (HCY)
   LegendXPos=Legend_StartAt;
   ShowLegend(TF1, "MACD4in1_TF1", TF1_Color);
   ShowLegend(TF2, "MACD4in1_TF2", TF2_Color);
   ShowLegend(TF3, "MACD4in1_TF3", TF3_Color);
   ShowLegend(TF4, "MACD4in1_TF4", TF4_Color);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   // Delete Legends (HCY)
   ObjectDelete("MACD4in1_TF1");
   ObjectDelete("MACD4in1_TF2");
   ObjectDelete("MACD4in1_TF3");
   ObjectDelete("MACD4in1_TF4");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit--;
   
     for(int i=limit;i>=0;i--)
     {
      // Definable timeframes (HCY)
      ExtMapBuffer1[i]=(iMACD(NULL,TF1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,i)/TF1_Factor);
      ExtMapBuffer2[i]=(iMACD(NULL,TF1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,i)/TF1_Factor);
      ExtMapBuffer3[i]=(iMACD(NULL,TF2,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,i)/TF2_Factor);
      ExtMapBuffer4[i]=(iMACD(NULL,TF2,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,i)/TF2_Factor);
      ExtMapBuffer5[i]=(iMACD(NULL,TF3,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,i)/TF3_Factor);
      ExtMapBuffer6[i]=(iMACD(NULL,TF3,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,i)/TF3_Factor);
      ExtMapBuffer7[i]=(iMACD(NULL,TF4,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,i)/TF4_Factor);
      ExtMapBuffer8[i]=(iMACD(NULL,TF4,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,i)/TF4_Factor);
/* 
      Original settings (HCY)
      ExtMapBuffer1[i]=(iMACD(NULL,PERIOD_H1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,i)/MACD_FactorH1); 
      ExtMapBuffer2[i]=(iMACD(NULL,PERIOD_H1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,i)/MACD_FactorH1);  
      ExtMapBuffer3[i]=(iMACD(NULL,PERIOD_M15,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,i)/MACD_FactorM15); 
      ExtMapBuffer4[i]=(iMACD(NULL,PERIOD_M15,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,i)/MACD_FactorM15); 
      ExtMapBuffer5[i]=(iMACD(NULL,PERIOD_M5,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,i)/MACD_FactorM5); 
      ExtMapBuffer6[i]=(iMACD(NULL,PERIOD_M5,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,i)/MACD_FactorM5); 
      ExtMapBuffer7[i]=(iMACD(NULL,PERIOD_M1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_MAIN,i)/MACD_FactorM1); 
      ExtMapBuffer8[i]=(iMACD(NULL,PERIOD_M1,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE,MODE_SIGNAL,i)/MACD_FactorM1);  
*/
     }
   return(0);
  }
//----
//+------------------------------------------------------------------+