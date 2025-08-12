//+-----------------------------------------------------------------------+
//|                                  #MTF_Heiken_Ashi.mq4                 |
//|                                      http://www.metaquotes.net;       |    
//|                                      http://www.forex-tsd.com    ki   |
//+-----------------------------------------------------------------------+
#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"



#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Red
#property indicator_color2 DodgerBlue
#property indicator_color4 Red
#property indicator_color5 DodgerBlue
#property indicator_color3  NULL
#property indicator_color6  NULL

#property indicator_width1 3
#property indicator_width2 3
#property indicator_width3 3
#property indicator_width4 0
#property indicator_width5 0
#property indicator_width6 0
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
extern int TimeFrame=60;
extern int Shift=0;
extern int xShift=0;

double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
double ExtMapBuffer5[];
double ExtMapBuffer6[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {

//---- indicator line
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(3, ExtMapBuffer1);
    if(TimeFrame==0) TimeFrame = Period();
   SetIndexShift(3,xShift+Shift*TimeFrame/Period());
     SetIndexLabel(3,"HA hi/lo dn ["+TimeFrame+"]"+Shift+"");
   SetIndexStyle(4,DRAW_HISTOGRAM);
   SetIndexBuffer(4, ExtMapBuffer2);
    SetIndexShift(4, xShift+Shift*TimeFrame/Period());
     SetIndexLabel(4,"HA hi/lo up["+TimeFrame+"]"+Shift+"");
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0, ExtMapBuffer3);
    SetIndexShift(0, xShift+Shift*TimeFrame/Period());
    SetIndexLabel(0,"HA O/Cl dn ["+TimeFrame+"]"+Shift+"");
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1, ExtMapBuffer4);
   SetIndexShift(1, xShift+Shift*TimeFrame/Period());
   SetIndexLabel(1,"HA O/Cl up ["+TimeFrame+"]"+Shift+"");
   SetIndexBuffer(5,ExtMapBuffer5);
   SetIndexBuffer(2,ExtMapBuffer6);
    SetIndexStyle(5,DRAW_HISTOGRAM);
    SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexShift(5, xShift+Shift*TimeFrame/Period());
   SetIndexShift(2, xShift+Shift*TimeFrame/Period());


   if (TimeFrame <= Period()) TimeFrame = Period();

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
      default : TimeFrameStr="Current Timeframe";
   }
   IndicatorShortName("CTI ["+TimeFrameStr+"] ");   
  }
//----
   return(0);
 
//+------------------------------------------------------------------+
//| MTF Parabolic Sar                                         |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   int    i,limit,y=0,counted_bars=IndicatorCounted(),ExtMapBuffer1prev,ExtMapBuffer2prev;
 
// Plot defined time frame on to current time frame
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame); 
   
   limit=Bars-counted_bars+TimeFrame/Period();
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
 
   ExtMapBuffer1[i]=iCustom(NULL,TimeFrame,"Heiken Ashi",0,y);
   ExtMapBuffer2[i]=iCustom(NULL,TimeFrame,"Heiken Ashi",1,y);
   ExtMapBuffer3[i]=iCustom(NULL,TimeFrame,"Heiken Ashi",2,y);
   ExtMapBuffer4[i]=iCustom(NULL,TimeFrame,"Heiken Ashi",3,y);
      ExtMapBuffer5[i]=MathMin(ExtMapBuffer1[i], ExtMapBuffer2[i]);
 	   ExtMapBuffer6[i]=MathMin(ExtMapBuffer3[i], ExtMapBuffer4[i]); 
   }  
     
   //----  Refresh buffers +++++++++++++++++++++++++ upgrade by Raff  
   if (TimeFrame>Period()) {
     int PerINT=TimeFrame/Period()+1;
     datetime TimeArr[]; ArrayResize(TimeArr,PerINT);
     ArrayCopySeries(TimeArr,MODE_TIME,Symbol(),Period()); 
     for(i=0;i<PerINT+1;i++) {if (TimeArr[i]>=TimeArray[0]) {
 /********************************************************     
    Refresh buffers:         buffer[i] = buffer[0];
 ********************************************************/  

   ExtMapBuffer1[i]=ExtMapBuffer1[0];
   ExtMapBuffer2[i]=ExtMapBuffer2[0];
   ExtMapBuffer3[i]=ExtMapBuffer3[0];
   ExtMapBuffer4[i]=ExtMapBuffer4[0];
 
  } } }
//++++++++++++++++++++++++++++++++++++++++++++++++   Raff 
  
   return(0);
  }
//+---------------------------------------------------------------+