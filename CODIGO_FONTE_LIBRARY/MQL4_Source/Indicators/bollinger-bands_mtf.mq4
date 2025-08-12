//+------------------------------------------------------------------+
//|                                          Bollinger-Bands_MTF.mq4 |
//|        ©2011 Best-metatrader-indicators.com. All rights reserved |
//|                        http://www.best-metatrader-indicators.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011 Best-metatrader-indicators.com."
#property link      "http://www.best-metatrader-indicators.com"
//----
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 DodgerBlue
#property indicator_color2 Tomato
#property indicator_color3 Tomato
//---- indicator parameters
extern string TimeFrameNote="TimeFrame =0 - Current Timeframe, =1 - 1MIN, =5 - 5MIN, =5 - 5MIN, =15 - 15MIN, =30 - 30MIN, =60 - 1H, =240 - 4H, =1440 - D1, =10080 - W1, =43200 - MN1";
extern int TimeFrame=0;
extern int    BandsPeriod=20;
extern int    BandsShift=0;
extern double BandsDeviations=2.0;
extern int    BandsAppliedPrice=0;
//---- buffers
double MovingBuffer[];
double UpperBuffer[];
double LowerBuffer[];
string Copyright="\xA9 WWW.BEST-METATRADER-INDICATORS.COM";  
string MPrefix="FI";
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MovingBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,UpperBuffer);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,LowerBuffer);
//----
   SetIndexDrawBegin(0,BandsPeriod+BandsShift);
   SetIndexDrawBegin(1,BandsPeriod+BandsShift);
   SetIndexDrawBegin(2,BandsPeriod+BandsShift);
//---- name for DataWindow and indicator subwindow label   
   switch(TimeFrame)
     {
      case 1 : string TimeFrameStr="TF: M1"; break;
      case 5 : TimeFrameStr="TF: M5"; break;
      case 15 : TimeFrameStr="TF: M15"; break;
      case 30 : TimeFrameStr="TF: M30"; break;
      case 60 : TimeFrameStr="TF: H1"; break;
      case 240 : TimeFrameStr="TF: H4"; break;
      case 1440 : TimeFrameStr="TF: D1"; break;
      case 10080 : TimeFrameStr="TF: W1"; break;
      case 43200 : TimeFrameStr="TF: MN1"; break;
      default : TimeFrameStr="Current Timeframe";
     }
   IndicatorShortName("Bollinger Bands MTF (Period: "+BandsPeriod+", "+TimeFrameStr+")");
   DL("001", Copyright, 5, 20,Gold,"Arial",10,0); 
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ClearObjects(); 
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   int    i,limit,y=0,counted_bars=IndicatorCounted();

   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame);
   limit=Bars-counted_bars;
   for(i=0,y=0;i<limit;i++)
     {
      if (Time[i]<TimeArray[y]) y++;
//----
      MovingBuffer[i]=iBands(NULL,TimeFrame,BandsPeriod,BandsDeviations,BandsShift,BandsAppliedPrice,MODE_MAIN,y);
      UpperBuffer[i]=iBands(NULL,TimeFrame,BandsPeriod,BandsDeviations,BandsShift,BandsAppliedPrice,MODE_UPPER,y);
      LowerBuffer[i]=iBands(NULL,TimeFrame,BandsPeriod,BandsDeviations,BandsShift,BandsAppliedPrice,MODE_LOWER,y);
     }
   //----
   return(0);
  }
//+------------------------------------------------------------------+
//| DL function                                                      |
//+------------------------------------------------------------------+
 void DL(string label, string text, int x, int y, color clr, string FontName = "Arial",int FontSize = 12, int typeCorner = 1)
 
{
   string labelIndicator = MPrefix + label;   
   if (ObjectFind(labelIndicator) == -1)
   {
      ObjectCreate(labelIndicator, OBJ_LABEL, 0, 0, 0);
  }
   
   ObjectSet(labelIndicator, OBJPROP_CORNER, typeCorner);
   ObjectSet(labelIndicator, OBJPROP_XDISTANCE, x);
   ObjectSet(labelIndicator, OBJPROP_YDISTANCE, y);
   ObjectSetText(labelIndicator, text, FontSize, FontName, clr);
  
}  

//+------------------------------------------------------------------+
//| ClearObjects function                                            |
//+------------------------------------------------------------------+
void ClearObjects() 
{ 
  for(int i=0;i<ObjectsTotal();i++) 
  if(StringFind(ObjectName(i),MPrefix)==0) { ObjectDelete(ObjectName(i)); i--; } 
}
//+------------------------------------------------------------------+

