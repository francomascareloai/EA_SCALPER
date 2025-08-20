//+------------------------------------------------------------------+
//|                             Sidus v.2 mod NL Entry Indicator.mq4 |
//|                                                                  |
//|                                                   Ideas by Sidus |
//|         modified May 2011 by nlenz                               |
//|         new: no repainting, alerts at close of candle            |
//|         draws the arrows at a consistent distance                |
//|         different logic - may give different signals             |
//|         than original                                            |
//|         Fixed the width settings so they can be modified         |
//+------------------------------------------------------------------+
#property copyright "Sidus"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_width1 2
#property indicator_color2 Red
#property indicator_width2 2
#property indicator_color3 Blue
#property indicator_width3 3
#property indicator_color4 Red
#property indicator_width4 3

#include <WinUser32.mqh>
//---- input parameters
extern int       FastEMA=14;
extern int       SlowEMA=21;
extern int       RSIPeriod=17;
extern bool      Alerts=false;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
//double rsi_sig[];
//---- variables
int sigCurrent=0;
int sigPrevious=0;
double pipdiffCurrent=0;
double pipdiffPrevious=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,233);
   SetIndexBuffer(2,ExtMapBuffer3);
   //SetIndexEmptyValue(2,0.0);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,234);
   SetIndexBuffer(3,ExtMapBuffer4);
  // SetIndexEmptyValue(3,0.0);
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
   int limit;
   int counted_bars=IndicatorCounted();
   double rsi_sig=0;
   bool entry=false;
   double entry_point=0;
   
   //---- check for possible errors
   if(counted_bars<0) return(-1);
   //---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   //---- main loop
   for(int i=limit - 1; i>0; i--)
   {
     //---- ma_shift set to 0 because SetIndexShift called abowe
     ExtMapBuffer1[i]=iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i);
     ExtMapBuffer2[i]=iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
     rsi_sig = iRSI(NULL, 0, RSIPeriod, PRICE_CLOSE, i);
     
     pipdiffCurrent=(ExtMapBuffer2[i]-ExtMapBuffer1[i]);

     Comment("pipdiffCurrent = "+pipdiffCurrent+" ");
     if (pipdiffCurrent>0 && rsi_sig<50) 
     {
       sigCurrent = 1;  //Down
     }
     else if (pipdiffCurrent<0 && rsi_sig>50)
     {
       sigCurrent = 2;  //Up
     }
/*
     if (pipdiffCurrent>0) 
     {
       sigCurrent = 1;  //Up
     }
     else if (pipdiffCurrent<0)
     {
       sigCurrent = 2;  //Down
     }
*/     

     if (sigCurrent==1 && sigPrevious==2)
     {
        ExtMapBuffer4[i] = High[i]+iATR(NULL,0,4,i);
        //ExtMapBuffer3[i] = Ask;
        entry=true;
        entry_point=Close[i];
     } 
     else if (sigCurrent==2 && sigPrevious==1)
     {
        ExtMapBuffer3[i] = Low[i]-iATR(NULL,0,4,i);
        //ExtMapBuffer4[i] = Bid;
        entry=true;
        entry_point=Close[i];
     }


     sigPrevious=sigCurrent;
     pipdiffPrevious=pipdiffCurrent;
   }

   //----
   if(Alerts && entry)
   {
     //PlaySound("alert.wav");
     if (sigCurrent==1)
     {
        Alert("Entry point: sell at "+entry_point+"!!", "Entry Point");
     }
     else if (sigCurrent==2)
     {
        Alert("Entry point: buy at "+entry_point+"!!", "Entry Point");
     }

     entry=false;
   }
RefreshRates();

//----
   return(0);
  }
//+------------------------------------------------------------------+

