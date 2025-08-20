//+------------------------------------------------------------------+
//|                                                     MTF_Trix.mq4 |
//|                                                          by Raff |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, raff1410@o2.pl"

#property indicator_separate_window
//---- indicator settings
#property  indicator_buffers 6
#property  indicator_color1 Red
#property  indicator_color2 DeepSkyBlue
#property  indicator_color3 Yellow
#property  indicator_color4 Aqua
#property  indicator_color5 DarkGray
#property  indicator_color6 DarkGray
#property  indicator_width1 1
#property  indicator_width2 1
#property  indicator_width3 0
#property  indicator_width4 0
#property  indicator_width5 1
#property  indicator_width6 1
#property  indicator_style1 STYLE_SOLID
#property  indicator_style2 STYLE_DOT
#property  indicator_style3 STYLE_SOLID
#property  indicator_style4 STYLE_SOLID
#property  indicator_style5 STYLE_SOLID
#property  indicator_style6 STYLE_SOLID

//---- indicator parameters
extern int  TimeFrame      = 0;
extern int  TRIX_Period     = 13;
extern int  Signal_Period = 8;
extern bool Signals      = true;
extern int  CountBars    = 1500;

//---- indicator buffers
double      ind_buffer1[];
double      ind_buffer2[];
double      ind_buffer3[];
double      ind_buffer4[];
double      ind_buffer5[];
double      ind_buffer6[];
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
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- drawing settings
   IndicatorBuffers(7);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,233);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,234);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexStyle(5,DRAW_HISTOGRAM);

//---- indicator buffers mapping
   SetIndexBuffer(0,ind_buffer1);
   SetIndexBuffer(1,ind_buffer2);
   SetIndexBuffer(2,ind_buffer3);
   SetIndexBuffer(3,ind_buffer4);
   SetIndexBuffer(4,ind_buffer5);
   SetIndexBuffer(5,ind_buffer6);
   

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
      default : TimeFrameStr="";
   } 
   string short_name;
   short_name="MTF Trix";
   IndicatorShortName("MTF TRIX index " + TimeFrameStr + " | Period: "+TRIX_Period+", Signal Period: "+Signal_Period+" | ");
  }
//----
   return(0);
 
int start()
  {
   datetime TimeArray[];
   int    i,shift,limit,y=0,counted_bars=IndicatorCounted();
    
// Plot defined timeframe on to current timeframe   
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame); 
   
   limit=Bars-counted_bars;
   for(i=0,y=0;i<limit;i++)
   {
   if (Time[i]<TimeArray[y]) y++; 
   
 /***********************************************************   
   Add your main indicator loop below.  You can reference an existing
      indicator with its iName  or iCustom.
   Rule 1:  Add extern inputs above for all neccesary values   
   Rule 2:  Use 'TimeFrame' for the indicator timeframe
   Rule 3:  Use 'y' for the indicator's shift value
 **********************************************************/  
   ind_buffer1[i]=iCustom(NULL,TimeFrame,"Trix",TRIX_Period,Signal_Period,Signals,CountBars,0,y);
   ind_buffer2[i]=iCustom(NULL,TimeFrame,"Trix",TRIX_Period,Signal_Period,Signals,CountBars,1,y);
   ind_buffer3[i]=iCustom(NULL,TimeFrame,"Trix",TRIX_Period,Signal_Period,Signals,CountBars,2,y);
   ind_buffer4[i]=iCustom(NULL,TimeFrame,"Trix",TRIX_Period,Signal_Period,Signals,CountBars,3,y);
   ind_buffer5[i]=iCustom(NULL,TimeFrame,"Trix",TRIX_Period,Signal_Period,Signals,CountBars,4,y);
   ind_buffer6[i]=iCustom(NULL,TimeFrame,"Trix",TRIX_Period,Signal_Period,Signals,CountBars,4,y);

   }  
     

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++
   if (TimeFrame>Period()) {
     int PerINT=TimeFrame/Period()+1;
     datetime TimeArr[]; ArrayResize(TimeArr,PerINT);
     ArrayCopySeries(TimeArr,MODE_TIME,Symbol(),Period()); 
     for(i=0;i<PerINT+1;i++) {if (TimeArr[i]>=TimeArray[0]) {
//----
 /************************************************ by Raff   
    Refresh buffers:         buffer[i] = buffer[0];
 ********************************************************/  
   ind_buffer1[i]=ind_buffer1[0];
   ind_buffer2[i]=ind_buffer2[0];
   ind_buffer3[i]=ind_buffer3[0];
   ind_buffer4[i]=ind_buffer4[0];
   ind_buffer5[i]=ind_buffer5[0];
   ind_buffer6[i]=ind_buffer6[0];

//----
   } } }
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++


   return(0);
  }
//+------------------------------------------------------------------+