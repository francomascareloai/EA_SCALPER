//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "SAR FOREX"
#property link      "http://www.sarforex.com"
#property strict

#property indicator_separate_window
#property indicator_minimum -1.0
#property indicator_maximum 2.0

#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Lime
#property indicator_color3 Yellow


double Buf_s[];
double Buf_b[];
double trend[];

input int   History  = 500;
extern int  Period_1 = 5;     // Period MA-1
extern int  Period_2 = 200;   // Period MA-2
extern bool AlertOn  = TRUE;
input int   SignalBar= 1;
input ENUM_TIMEFRAMES   TimeFrame   = PERIOD_CURRENT;
ENUM_TIMEFRAMES timeframe;
int index=-1,max;
string shot_name=WindowExpertName();
datetime TimeBar;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   timeframe=TimeFrame;
   if(TimeFrame<=_Period) timeframe=(ENUM_TIMEFRAMES)_Period;
   max=timeframe/_Period*fmax(Period_1,Period_2)+2;
   IndicatorShortName("SARFOREX fix");

   SetIndexBuffer(0, trend);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexLabel(0, "Trend");
   SetIndexDrawBegin(0,MathMax(Period_1,Period_2));

   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexLabel(1, "BUY");
   SetIndexBuffer(1, Buf_b);
   SetIndexDrawBegin(1,MathMax(Period_1,Period_2));

   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexLabel(2, "SELL");
   SetIndexBuffer(2, Buf_s);
   SetIndexDrawBegin(2,MathMax(Period_1,Period_2));

   TimeBar = Time[0];
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
   int sig, limit,i;
   string txt;
   limit=fmin(rates_total-prev_calculated-2,rates_total-max);
   if(History>0) limit=fmin(limit,History);

   if(_Period>=timeframe)
     {
      for(i=limit; i>=0; i--)
        {
         sig = f0_0(i);
         Buf_b[i] = Buf_b[i+1];
         Buf_s[i] = Buf_s[i+1];
         if(sig == 1)
           {
            Buf_b[i] = 1;
            Buf_s[i]=EMPTY_VALUE;
           }
         if(sig == 2)
           {
            Buf_s[i] = 0;
            Buf_b[i]=EMPTY_VALUE;
           }
         trend[i] = 0;
         if(Buf_b[i] == 1.0)
            trend[i] = 1;
        }
     }
   else
     {
      for(i=limit; i>=0; i--)
        {
         index=iBarShift(_Symbol,timeframe,time[i],false);
         trend[i]=iCustom(_Symbol,timeframe,shot_name,History,Period_1,Period_2,AlertOn,SignalBar,timeframe,0,index);
         Buf_b[i]=iCustom(_Symbol,timeframe,shot_name,History,Period_1,Period_2,AlertOn,SignalBar,timeframe,1,index);
         Buf_s[i]=iCustom(_Symbol,timeframe,shot_name,History,Period_1,Period_2,AlertOn,SignalBar,timeframe,2,index);
        }
     }
   for(i=limit; i>=0; i--)
     {
     }

   if(AlertOn)
     {
      txt = "";
      if(TimeBar!=Time[0] && trend[0+SignalBar]>trend[1+SignalBar])
        {
         txt = "SAR FOREX fix" + " " + Symbol() + " " + (string)Period() + " BUY";
         Alert(txt);
         TimeBar = Time[0];
        }
      if(TimeBar!=Time[0] && trend[0+SignalBar]<trend[1+SignalBar])
        {
         txt = "SAR FOREX fix" + " " + Symbol() + " " + (string)Period() + " SELL";
         Alert(txt);
         TimeBar = Time[0];
        }
     }
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int f0_0(int Ai_0)
  {
   double ima_4 = 0;
   double ima_12 = 0;
   double ima_20 = 0;
   double ima_28 = 0;
   double ima_36 = 0;
   double ima_44 = 0;
   double ima_52 = 0;
   double ima_60 = 0;

   ima_4  = iMA(NULL, 0, Period_1, 0, MODE_EMA, PRICE_CLOSE, Ai_0);
   ima_12 = iMA(NULL, 0, Period_2, 0, MODE_SMA, PRICE_HIGH,  Ai_0);
   ima_20 = iMA(NULL, 0, Period_2, 0, MODE_SMA, PRICE_LOW,   Ai_0);
   ima_28 = iMA(NULL, 0, Period_1, 0, MODE_EMA, PRICE_CLOSE, Ai_0 + 1);
   ima_36 = iMA(NULL, 0, Period_2, 0, MODE_SMA, PRICE_HIGH,  Ai_0 + 1);
   ima_44 = iMA(NULL, 0, Period_2, 0, MODE_SMA, PRICE_LOW,   Ai_0 + 1);
//ima_52 = iMA(NULL, 0, 200, 0, MODE_SMA, PRICE_CLOSE, Ai_0);
//ima_60 = iMA(NULL, 0, 200, 0, MODE_SMA, PRICE_CLOSE, Ai_0 + 25);

   if(ima_4 > ima_12 && ima_28 < ima_36)
      return (1);
   if(ima_4 < ima_20 && ima_28 > ima_44)
      return (2);

   return (0);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
