//+------------------------------------------------------------------+
//|                                                     MTF_PSAR.mq4 |
//|                                      Copyright © 2006, Keris2112 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Keris2112"
#property link      "http://www.forex-tsd.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue
//#property indicator_level1 70
//#property indicator_level2 30
//#property indicator_level3 50
#property indicator_maximum 100
#property indicator_minimum 0

//---- input parameters
/*************************************************************************
PERIOD_M1   1
PERIOD_M5   5
PERIOD_M15  15
PERIOD_M30  30 
PERIOD_H1   60
PERIOD_H4   240
PERIOD_D1   1440
PERIOD_W1   10080
PERIOD_MN1  43200
You must use the numeric value of the timeframe that you want to use
when you set the TimeFrame' value with the indicator inputs.
**************************************************************************/
extern int TimeFrame=0;
extern int PPeriod=14;

double ExtMapBuffer1[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {

//---- indicator line
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(0,DRAW_LINE);
  // SetIndexArrow(0,159);
//---- name for DataWindow and indicator subwindow label   
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
      default : TimeFrameStr="Current Timeframe";
   }
   IndicatorShortName("RSX_MTF ("+PPeriod+", "+TimeFrameStr+")");   
  }
//----
   return(0);
 
//+------------------------------------------------------------------+
//| MTF Parabolic Sar                                         |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   int    i,limit,y=0,counted_bars=IndicatorCounted();
 
// Plot defined time frame on to current time frame
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame); 
   
   limit=Bars-counted_bars;
   for(i=0,y=0;i<limit;i++)
   {
   if (Time[i]<TimeArray[y]) y++;

/***********************************************************   
   Add your main indicator loop below.  You can add the full
      indicator code or you can just reference an existing
      indicator with its iValue or iCustom.
   Rule 1:  Add extern inputs above for all neccesary values   
   Rule 2:  Use 'TimeFrame' for the indicator time frame
   Rule 3:  Use 'y' for your indicator's shift value
 **********************************************************/ 
 
   ExtMapBuffer1[i]=iCustom(NULL,TimeFrame,"RSX",PPeriod,0,y) ; 
   
   }  
     
//
   
  
  
   return(0);
  }
//+------------------------------------------------------------------+