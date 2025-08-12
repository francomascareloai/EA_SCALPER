/********************************************************************\
|                                         TriggerLine with Arrow.mq5 |
|                                                           Viktorov |
|                                                  v4forex@yandex.ru |
\********************************************************************/
#property copyright "Viktorov"
#property link      "v4forex@yandex.ru"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   4
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkViolet, clrCrimson
#property indicator_width1  2
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkViolet, clrCrimson
#property indicator_width2  2
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrDarkViolet
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrCrimson

input int   period      =  24;        // Period
input int   LSMA_Period =  6;
input bool  ShowArrow   =  true;

int length;
int lsma_length;
double lengthvar;

double sum[1];
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ColorIndBuffer1[];
double ColorIndBuffer2[];
double wt[];
double lsma_ma[];
double arrowUp[];
double arrowDn[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, ExtMapBuffer1, INDICATOR_DATA);
   SetIndexBuffer(1, ColorIndBuffer1, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, ExtMapBuffer2, INDICATOR_DATA);
   SetIndexBuffer(3, ColorIndBuffer2, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4, arrowUp, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_ARROW, 217);
   SetIndexBuffer(5, arrowDn, INDICATOR_DATA);
   PlotIndexSetInteger(3, PLOT_ARROW, 218);
   SetIndexBuffer(6, wt, INDICATOR_CALCULATIONS);
   SetIndexBuffer(7, lsma_ma, INDICATOR_CALCULATIONS);
   //PlotIndexSetString(0, PLOT_LABEL, "wt");
   //PlotIndexSetString(1, PLOT_LABEL, "lsma_ma");
   PlotIndexSetString(2, PLOT_LABEL, "arrowUp");
   PlotIndexSetString(3, PLOT_LABEL, "arrowDn");
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, 15);
   PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, -15);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   ArraySetAsSeries(ExtMapBuffer1, true);
   ArraySetAsSeries(ColorIndBuffer1, true);
   ArraySetAsSeries(ExtMapBuffer2, true);
   ArraySetAsSeries(ColorIndBuffer2, true);
   ArraySetAsSeries(arrowUp, true);
   ArraySetAsSeries(arrowDn, true);
   ArraySetAsSeries(wt, true);
   ArraySetAsSeries(lsma_ma, true);
   ArrayInitialize(wt, INT_MAX);
   length = period;
   lsma_length = LSMA_Period;
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
    ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
  ArraySetAsSeries(open, true);
   int shift = 0, i = 0, j = 0, limit = prev_calculated <= 0 ? rates_total-fmax(period, LSMA_Period) : rates_total-prev_calculated;
    for(shift = limit; shift >= 0 && !IsStopped(); shift--)
     {
      sum[0] = 0;
       for(i = length; i > 0 ; i--)
        {
         lengthvar = length + 1;
          lengthvar /= 3;
           double tmp = 0;
          tmp = (i - lengthvar)*open[length-i+shift];
         sum[0] += tmp;
        }
         wt[shift] = sum[0]*6/(length*(length+1));  
          j = shift;
           lsma_ma[shift] = wt[j+1] + (wt[j]-wt[j+1])* 2/(lsma_length+1);
          ExtMapBuffer1[shift] = wt[shift];
         ExtMapBuffer2[shift] = lsma_ma[shift]; 
          ColorIndBuffer1[shift] = 0.0;
           ColorIndBuffer2[shift] = 0.0;
          if(wt[shift] < lsma_ma[shift])
           {
            ColorIndBuffer1[shift] = 1.0;
            ColorIndBuffer2[shift] = 1.0;
           }
        arrowUp[shift] = 0;
       arrowDn[shift] = 0;
      if(ShowArrow && ExtMapBuffer1[shift+1] < ExtMapBuffer2[shift+1] && ExtMapBuffer1[shift] >= ExtMapBuffer2[shift])
       arrowUp[shift] = fmin(low[shift], fmin(ExtMapBuffer1[shift], ExtMapBuffer2[shift]));
      if(ShowArrow && ExtMapBuffer1[shift+1] > ExtMapBuffer2[shift+1] && ExtMapBuffer1[shift] <= ExtMapBuffer2[shift])
       arrowDn[shift] = fmax(high[shift], fmax(ExtMapBuffer1[shift], ExtMapBuffer2[shift]));
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
