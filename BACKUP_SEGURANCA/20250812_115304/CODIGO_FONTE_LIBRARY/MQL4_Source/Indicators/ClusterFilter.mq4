//+------------------------------------------------------------------+
//|                                                ClusterFilter.mq4 |
//|                                              Copyright 2017, Tor |
//|                                             http://einvestor.ru/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013-2014, Gruzdev Konstantin"
#property link      "https://login.mql5.com/ru/users/Lizar"
#property version   "1.00"

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot Label1 
//--- indicator buffers
double    ExtBuffer_MA[];
double    ExtBuffer_EMA[];
double    ExtBuffer_CF[];
//--- parameters MA
input int       ext_period_MA=2;//Period MA
//---
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtBuffer_MA);
   SetIndexBuffer(1,ExtBuffer_EMA);
   SetIndexBuffer(2,ExtBuffer_CF);
//--- sets first bar from what index will be drawn
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2,clrGold);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2,clrGreen);
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,3,clrRed);

//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
   ArraySetAsSeries(ExtBuffer_MA,false);
   ArraySetAsSeries(ExtBuffer_EMA,false);
   ArraySetAsSeries(ExtBuffer_CF,false);
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
   int begin=0;
   ArraySetAsSeries(close,false);
   CalculateSimpleMA(rates_total,prev_calculated,begin,close);
   CalculateEMA(rates_total,prev_calculated,begin,close);
   CalculateCF(rates_total,prev_calculated,begin,close);
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|   simple moving average                                          |
//+------------------------------------------------------------------+
void CalculateSimpleMA(int rates_total,int prev_calculated,int begin,const double &price[])
  {
   int i,limit;
//--- first calculation or number of bars was changed
   if(prev_calculated==0)// first calculation
     {
      limit=ext_period_MA+begin;
      //--- set empty value for first limit bars
      for(i=0;i<limit-1;i++){ ExtBuffer_MA[i]=0.0; }
      //--- calculate first visible value
      double firstValue=0;
      for(i=begin;i<limit;i++)
        {
         firstValue+=price[i];
        }
      firstValue/=ext_period_MA;
      ExtBuffer_MA[limit-1]=firstValue;
        }else{ limit=prev_calculated-1;
     }
//--- main loop
   for(i=limit;i<rates_total && !IsStopped();i++)
      ExtBuffer_MA[i]=ExtBuffer_MA[i-1]+(price[i]-price[i-ext_period_MA])/ext_period_MA;
//---
  }
//+------------------------------------------------------------------+
//|  exponential moving average                                      |
//+------------------------------------------------------------------+
void CalculateEMA(int rates_total,int prev_calculated,int begin,const double &price[])
  {
   int    i,limit;
   double SmoothFactor=2.0/(1.0+ext_period_MA);
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      limit=ext_period_MA+begin;
      ExtBuffer_EMA[begin]=price[begin];
      for(i=begin+1;i<limit;i++)
         ExtBuffer_EMA[i]=price[i]*SmoothFactor+ExtBuffer_EMA[i-1]*(1.0-SmoothFactor);
     }
   else limit=prev_calculated-1;
//--- main loop
   for(i=limit;i<rates_total && !IsStopped();i++)
      ExtBuffer_EMA[i]=price[i]*SmoothFactor+ExtBuffer_EMA[i-1]*(1.0-SmoothFactor);
//---
  }
//+------------------------------------------------------------------+
//|  simple cluster filter                                           |
//+------------------------------------------------------------------+
void CalculateCF(int rates_total,int prev_calculated,int begin,const double &price[])
  {
   int    i,limit;
//--- first calculation or number of bars was changed
   if(prev_calculated==0)
     {
      limit=ext_period_MA+begin;
      for(i=begin;i<limit;i++)
         ExtBuffer_CF[i]=ExtBuffer_EMA[i];
     }
   else limit=prev_calculated-1;
//--- main loop
   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      if(ExtBuffer_CF[i-1]>ExtBuffer_CF[i-2])
        {
         if(ExtBuffer_CF[i-1]<ExtBuffer_MA[i] && ExtBuffer_CF[i-1]<ExtBuffer_EMA[i])
           {
            ExtBuffer_CF[i]=fmin(ExtBuffer_MA[i],ExtBuffer_EMA[i]);
            continue;
           }
         if(ExtBuffer_CF[i-1]<ExtBuffer_MA[i] && ExtBuffer_CF[i-1]>ExtBuffer_EMA[i])
           {
            ExtBuffer_CF[i]=ExtBuffer_MA[i];
            continue;
           }
         if(ExtBuffer_CF[i-1]>ExtBuffer_MA[i] && ExtBuffer_CF[i-1]<ExtBuffer_EMA[i])
           {
            ExtBuffer_CF[i]=ExtBuffer_EMA[i];
            continue;
           }
         ExtBuffer_CF[i]=fmax(ExtBuffer_MA[i],ExtBuffer_EMA[i]);
        }
      else
        {
         if(ExtBuffer_CF[i-1]>ExtBuffer_MA[i] && ExtBuffer_CF[i-1]>ExtBuffer_EMA[i])
           {
            ExtBuffer_CF[i]=fmax(ExtBuffer_MA[i],ExtBuffer_EMA[i]);
            continue;
           }
         if(ExtBuffer_CF[i-1]>ExtBuffer_MA[i] && ExtBuffer_CF[i-1]<ExtBuffer_EMA[i])
           {
            ExtBuffer_CF[i]=ExtBuffer_MA[i];
            continue;
           }
         if(ExtBuffer_CF[i-1]<ExtBuffer_MA[i] && ExtBuffer_CF[i-1]>ExtBuffer_EMA[i])
           {
            ExtBuffer_CF[i]=ExtBuffer_EMA[i];
            continue;
           }
         ExtBuffer_CF[i]=fmin(ExtBuffer_MA[i],ExtBuffer_EMA[i]);
        }
     }
//---
  }

//+------------------------------------------------------------------+
