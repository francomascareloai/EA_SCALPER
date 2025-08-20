//+------------------------------------------------------------------+
//|                                    Sidus v.2 Entry Indicator.mq4 |
//|                                                                  |
//|                                                   Ideas by Sidus |
//+------------------------------------------------------------------+
#property copyright "Sidus"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 DodgerBlue
#property indicator_color2 Yellow
#property indicator_color3 Magenta
#property indicator_color4 Lime

#include <WinUser32.mqh>
//---- input parameters
extern int       FastEMA=70;
extern int       SlowEMA=105;
extern int       RSIPeriod=14;
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
   SetIndexStyle(1,DRAW_LINE,1,3);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_ARROW,1,3);
   SetIndexArrow(2,233);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexEmptyValue(2,0.0);
   SetIndexStyle(3,DRAW_ARROW,1,3);
   SetIndexArrow(3,234);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexEmptyValue(3,0.0);
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
   for(int i=0; i<limit; i++)
   {
     //---- ma_shift set to 0 because SetIndexShift called abowe
     ExtMapBuffer1[i]=iMA(NULL,0,FastEMA,0,MODE_EMA,PRICE_CLOSE,i);
     ExtMapBuffer2[i]=iMA(NULL,0,SlowEMA,0,MODE_EMA,PRICE_CLOSE,i);
     rsi_sig = iRSI(NULL, 0, RSIPeriod, PRICE_CLOSE, i);
     
     pipdiffCurrent=(ExtMapBuffer1[i]-ExtMapBuffer2[i]);

     Comment("pipdiffCurrent = "+pipdiffCurrent+" ");
     if (pipdiffCurrent>0 && rsi_sig>50) 
     {
       sigCurrent = 1;  //Up
     }
     else if (pipdiffCurrent<0 && rsi_sig<50)
     {
       sigCurrent = 2;  //Down
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
        ExtMapBuffer4[i-1] = High[i-1]-5*Point;
        //ExtMapBuffer3[i] = Ask;
        entry=true;
        entry_point=Ask;
     } 
     else if (sigCurrent==2 && sigPrevious==1)
     {
        ExtMapBuffer3[i-1] = Low[i-1]-5*Point;
        //ExtMapBuffer4[i] = Bid;
        entry=true;
        entry_point=Bid;
     }


     sigPrevious=sigCurrent;
     pipdiffPrevious=pipdiffCurrent;
   }

   //----
   if(Alerts && entry)
   {
     PlaySound("alert.wav");
     if (sigPrevious==1)
     {
        MessageBox("Entry point: buy at "+entry_point+"!!", "Entry Point", MB_OK);
     }
     else if (sigPrevious==2)
     {
        MessageBox("Entry point: sell at "+entry_point+"!!", "Entry Point", MB_OK);
     }

     entry=false;
   }
RefreshRates();

//----
   return(0);
  }
//+------------------------------------------------------------------+

