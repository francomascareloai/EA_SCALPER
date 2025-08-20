//+------------------------------------------------------------------+
//|                                    PATHFINDER SIGNAL_v.1.02.mq4  |
//|                           Copyright 2020 Bostonmarket@gmail.com  |
//|                                                                  | 
//|               PATHFINDER SIGNAL - With Alerts                    |  
//|                                                                  |
//|        Version 1.02  Completed 2020 (www.Forex-joy.com)          |
//|                                                                  |
//|               a)   Complete Code rewrite                         |
//|               b)   Added Entry / Exit Signal Arrows Option       | 
//|               c)   Added Audio, Visual and eMail alerts          | 
//|                                                                  |
//|         GIFTS AND DONATIONS ACCEPTED                             | 
//|   All my indicators should be considered donationware. That is   |
//|   you are free to use them for your personal use, and are        |
//|   under no obligation to pay for them. However, if you do find   |
//|   this or any of my other indicators help you with your trading  |
//|   then any Gift or Donation as a show of appreciation is         |
//|   gratefully accepted.                                           |
//|                                                                  |
//|   Gifts or Donations also keep me motivated in producing more    |
//|   great free indicators. :-)                                     |
//|                                                                  |  
//+------------------------------------------------------------------+                                                                

#property copyright "PATHFINDER SIGNAL_v.1.02 Copyright 2020 Boston Market CO USA"
#property link      "http://www.Forex-joy.com/"
#property strict

#property indicator_chart_window
#property indicator_buffers 2
#property  indicator_color1 clrMagenta 
#property  indicator_color2 clrLime
#property indicator_width1 3
#property indicator_width2 3
//==================================
enum MYENUM
 { 
   Var0,
   Var1 
 }; 
//============================
input double BBDev=2;
input int    BBPeriod=20;
input int    MAPeriod=2;
input int    RSIPeriod=9;
input int    RSILevel=30;
extern color  ArrowDnColor = Magenta;
extern color  ArrowUpColor = Lime;
extern int    ArrowDnCode  = 234;
extern int    ArrowUpCode  = 233;
extern int    ArrowSize    = 3;
extern int    ArrowsGap = 2;
extern bool  AlertsMessage = true; 
extern bool  AlertsSound   = false;
extern bool  AlertsEmail   = false;
extern bool  AlertsMobile  = false;
//==================================
input MYENUM SignalBar     = Var0;  

datetime TimeBar; 
//=================================

double buyBf[];
double sellBf[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, buyBf);
   SetIndexStyle(0, DRAW_ARROW, EMPTY,ArrowSize,ArrowUpColor);
   SetIndexArrow(0, ArrowUpCode);
   SetIndexDrawBegin(0,0.0);
   SetIndexBuffer(1,sellBf);
   SetIndexStyle(1, DRAW_ARROW, EMPTY,ArrowSize,ArrowDnColor);
   SetIndexArrow(1, ArrowDnCode);
   SetIndexDrawBegin(1,0.0);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   for(int i=0;i<1111;i++)
     {
      double ma1=iMA(NULL,0,MAPeriod,0,0,0,i);
      double ma2=iMA(NULL,0,MAPeriod,0,0,0,i+1);

      double rsi1=iRSI(NULL,0,RSIPeriod,0,i);
      double rsi2=iRSI(NULL,0,RSIPeriod,0,i+1);

      double hi=iBands(NULL,0,BBPeriod,BBDev,0,0,1,i);
      double lo=iBands(NULL,0,BBPeriod,BBDev,0,0,2,i);

      if(ma1>lo && ma2<lo && rsi1>RSILevel && rsi2<RSILevel)
        {
         buyBf[i]=low[i]-5*ArrowsGap *Point;
        }
      if(ma1<hi && ma2>hi && rsi1<100-RSILevel && rsi2>100-RSILevel)
        {
         sellBf[i]=high[i]+5*ArrowsGap *Point;
       }
 }   
//==================================================================================================  
if(AlertsMessage || AlertsEmail || AlertsMobile || AlertsSound)
 { 
      string  message1   =  StringConcatenate(Symbol(), " M", Period()," ", " PATHFINDER SIGNAL : BUY!");
      string  message2   =  StringConcatenate(Symbol(), " M", Period()," ", " PATHFINDER SIGNAL : SELL!");
       
    if(TimeBar!=Time[0] && buyBf[SignalBar]!=0 && buyBf[SignalBar]!=EMPTY_VALUE && 
                          (buyBf[1+SignalBar]==0 || buyBf[1+SignalBar]==EMPTY_VALUE))
     { 
        if (AlertsMessage)Alert(message1);
        if (AlertsEmail)  SendMail(Symbol()+" ATTAR ARROW ",message1);
        if (AlertsMobile) SendNotification(message1);
        if (AlertsSound)  PlaySound("wait.wav");
        TimeBar=Time[0];
     }
    if(TimeBar!=Time[0] && sellBf[SignalBar]!=0 && sellBf[SignalBar]!=EMPTY_VALUE && 
                          (sellBf[1+SignalBar]==0 || sellBf[1+SignalBar]==EMPTY_VALUE))
     { 
        if (AlertsMessage)Alert(message2);
        if (AlertsEmail)  SendMail(Symbol()+" ATTAR ARROW ",message2);
        if (AlertsMobile) SendNotification(message2);
        if (AlertsSound)  PlaySound("wait.wav");
        TimeBar=Time[0];
       
       
    }         
      
 }
//==================================================================
   return(0);
  }

//+------------------------------------------------------------------+
//| Period String                                                    |
//+------------------------------------------------------------------+
string PeriodString()
  {
    switch (_Period) 
     {
        case PERIOD_M1:  return("M1");
        case PERIOD_M5:  return("M5");
        case PERIOD_M15: return("M15");
        case PERIOD_M30: return("M30");
        case PERIOD_H1:  return("H1");
        case PERIOD_H4:  return("H4");
        case PERIOD_D1:  return("D1");
        case PERIOD_W1:  return("W1");
        case PERIOD_MN1: return("MN1");
        default: return("M"+(string)_Period);
     }  
    return("M"+(string)_Period); 
  } 
