///+------------------------------------------------------------------+
//|                                             MTF_MACD_inColor.mq4 |
//|                                      Copyright © 2006, Keris2112 |
//|  1June06 Stache  added traditional view and 2-color Histogram                                                               |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Keris2112"
#property link      "http://www.forex-tsd.com"


#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Chartreuse
#property indicator_width1 1
#property indicator_color2 Red
#property indicator_width2 1
#property indicator_color3 Lime
#property indicator_width3 3
#property indicator_color4 Red
#property indicator_width4 3

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
---------------------------------------
PRICE_CLOSE    0 Close price. 
PRICE_OPEN     1 Open price. 
PRICE_HIGH     2 High price. 
PRICE_LOW      3 Low price. 
PRICE_MEDIAN   4 Median price, (high+low)/2. 
PRICE_TYPICAL  5 Typical price, (high+low+close)/3. 
PRICE_WEIGHTED 6 Weighted close price, (high+low+close+close)/4. 
You must use the numeric value of the Applied Price that you want to use
when you set the 'applied_price' value with the indicator inputs.
**************************************************************************/
extern int TimeFrame=0;
extern int FastEMA=7;
extern int SlowEMA=19;
extern int SignalSMA=7;
extern int applied_price=0;


double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexDrawBegin(1,SignalSMA);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
   
   SetIndexBuffer(0,ExtMapBuffer1); 
   SetIndexBuffer(1,ExtMapBuffer2); 
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexBuffer(3,ExtMapBuffer4);
//---- name for DataWindow and indicator subwindow label   
   switch(TimeFrame)
   {
      case 1 : string TimeFrameStr="Period_M1"; break;
      case 5 : TimeFrameStr="Period_M5"; break;
      case 15 : TimeFrameStr="Period_M15"; break;
      case 30 : TimeFrameStr="Period_M30"; break;
      case 60 : TimeFrameStr="Period_H1"; break;
      case 240 : TimeFrameStr="Period_H4"; break;
      case 1440 : TimeFrameStr="Period_D1"; break;
      case 10080 : TimeFrameStr="Period_W1"; break;
      case 43200 : TimeFrameStr="Period_MN1"; break;
      default : TimeFrameStr="ChartTimeframe";
   }
   IndicatorShortName("MTF_MACD_inColor("+FastEMA+","+SlowEMA+","+SignalSMA+") ("+TimeFrameStr+")");

  }
//----
   return(0);
 
//+------------------------------------------------------------------+
//| MTF MACD                                            |
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
   Add your main indicator loop below.  You can reference an existing
      indicator with its iName  or iCustom.
   Rule 1:  Add extern inputs above for all neccesary values   
   Rule 2:  Use 'TimeFrame' for the indicator time frame
   Rule 3:  Use 'y' for your indicator's shift value
 **********************************************************/  
 
   ExtMapBuffer1[i]=iMACD(NULL,TimeFrame,FastEMA,SlowEMA,SignalSMA,applied_price,0,y); 
   ExtMapBuffer2[i]=iMACD(NULL,TimeFrame,FastEMA,SlowEMA,SignalSMA,applied_price,1,y);
   ExtMapBuffer3[i]=ExtMapBuffer1[i]-ExtMapBuffer2[i];
   ExtMapBuffer4[i]=ExtMapBuffer1[i]-ExtMapBuffer2[i];
   
   if (ExtMapBuffer1[i] <= ExtMapBuffer2[i]) 
      
     ExtMapBuffer3[i]=0;
  
   else ExtMapBuffer4[i]=0;
   
   }  
     
//
   
  
  
   return(0);
  }
//+------------------