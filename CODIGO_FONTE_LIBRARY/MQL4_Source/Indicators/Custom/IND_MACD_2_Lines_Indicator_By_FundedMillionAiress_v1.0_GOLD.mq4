//+------------------------------------------------------------------+
//|                                             #MTF_MacD-2 line.mq4 |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 HotPink
#property indicator_color2 Aqua

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
---------------------------------------*/

extern int MacD2lineTime = 0;
extern int FastEMA=8;
extern int SlowEMA=12;
extern int SignalSMA=9;

double ExtMapBuffer0[];
double ExtMapBuffer1[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
  {
   
//---- indicator line

   SetIndexStyle(0,DRAW_LINE,EMPTY,1);
   SetIndexBuffer(0,ExtMapBuffer0);
   SetIndexStyle(1,DRAW_LINE,EMPTY,1);
   SetIndexBuffer(1,ExtMapBuffer1);

//---- name for DataWindow and indicator subwindow label   

   switch(MacD2lineTime)
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
      default : TimeFrameStr="Current Timeframe";
   }
   IndicatorShortName(" #MTF_MacD-2 line ( "+TimeFrameStr+" ) ");

  }

//----

   return(0);
 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int start()
  {

   datetime TimeArray[];
   int    i,limit,y=0,counted_bars=IndicatorCounted(); 

// Plot defined time frame on to current time frame

   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),MacD2lineTime); 
   
   limit= Bars-1;
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
 
   
   ExtMapBuffer0[i]=iCustom(Symbol(),MacD2lineTime,"MacD-2 line",FastEMA,SlowEMA,SignalSMA,0,y);
   ExtMapBuffer1[i]=iCustom(Symbol(),MacD2lineTime,"MacD-2 line",FastEMA,SlowEMA,SignalSMA,1,y); 
   
   }
   return(0);
  }
//+------------------------------------------------------------------+