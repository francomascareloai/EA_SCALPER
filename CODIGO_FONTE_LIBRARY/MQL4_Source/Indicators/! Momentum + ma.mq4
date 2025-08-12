//+------------------------------------------------------------------+
//|                                                     Momentum.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "2005-2014, MetaQuotes Software Corp."
#property link        "http://www.mql4.com"
#property description "Momentum"
#property strict

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  clrDodgerBlue
#property indicator_color2  clrRed

//
//
//

input int            InpMomPeriod = 14;        // Momentum Period
input int            MaPeriod     = 20;        // Moving average period
input ENUM_MA_METHOD MaMode       = MODE_EMA;  // Ma type

double mom[],ma[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
{
   SetIndexBuffer(0,mom); SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,ma);  SetIndexStyle(1,DRAW_LINE);
   if(InpMomPeriod<=0)
   {
      Print("Wrong input parameter Momentum Period=",InpMomPeriod);
      return(INIT_FAILED);
   }
     
   IndicatorShortName("Mom("+IntegerToString(InpMomPeriod)+")");

return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Momentum                                                         |
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
   int i,limit=rates_total-prev_calculated+1; if (limit>=rates_total) limit=rates_total-1; 

   for (i=limit;i>=0;i--) mom[i] = close[i]*100/close[(int)fmin(rates_total-1,i+InpMomPeriod)];
   for (i=limit;i>=0;i--) ma[i]  = iMAOnArray(mom,0,MaPeriod,0,MaMode,i);
return(rates_total);
}
//+------------------------------------------------------------------+
