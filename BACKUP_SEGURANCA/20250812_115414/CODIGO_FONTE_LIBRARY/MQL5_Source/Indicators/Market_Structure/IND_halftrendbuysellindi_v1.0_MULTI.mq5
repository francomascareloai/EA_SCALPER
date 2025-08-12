//+------------------------------------------------------------------+
//|                                                    HalfTrend.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 11
#property indicator_plots   5
//--- plot
#property indicator_label1 "UP"
#property indicator_color1 Purple  // up[] DodgerBlue
#property indicator_type1  DRAW_LINE
#property indicator_width1 2

#property indicator_label2 "DN"
#property indicator_color2 Red       // down[]
#property indicator_type2  DRAW_LINE
#property indicator_width2 2

#property indicator_label3 "ATR-LH"
#property indicator_color3 DodgerBlue,Red  // atrlo[],atrhi[]
#property indicator_type3  DRAW_COLOR_HISTOGRAM2
#property indicator_width3 1

#property indicator_label4 "ARR-UP"
#property indicator_color4 DodgerBlue  // arrup[]
#property indicator_type4  DRAW_ARROW
#property indicator_width4 1

#property indicator_label5 "ARR-DOWN"
#property indicator_color5 Red  // arrdwn[]
#property indicator_type5  DRAW_ARROW
#property indicator_width5 1

input int    Amplitude        = 2;
input bool   ShowBars         = false;
input bool   ShowArrows       = true;
input bool   alertsOn         = false;
input bool   alertsOnCurrent  = false;
input bool   alertsMessage    = true;
input bool   alertsSound      = true;
input bool   alertsEmail      = false;

bool nexttrend;
double minhighprice, maxlowprice;
double up[], down[], atrlo[], atrhi[], atrclr[], trend[];
double arrup[], arrdwn[];
int ind_mahi, ind_malo, ind_atr;
double iMAHigh[], iMALow[], iATRx[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, up, INDICATOR_DATA);
   SetIndexBuffer(1, down, INDICATOR_DATA);
   SetIndexBuffer(2, atrlo, INDICATOR_DATA);
   SetIndexBuffer(3, atrhi, INDICATOR_DATA);
   SetIndexBuffer(4, atrclr, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5, arrup, INDICATOR_DATA);
   SetIndexBuffer(6, arrdwn, INDICATOR_DATA);
   SetIndexBuffer(7, trend, INDICATOR_CALCULATIONS);
   SetIndexBuffer(8, iMAHigh, INDICATOR_CALCULATIONS);
   SetIndexBuffer(9, iMALow, INDICATOR_CALCULATIONS);
   SetIndexBuffer(10, iATRx, INDICATOR_CALCULATIONS);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
   ArraySetAsSeries(up, true);
   ArraySetAsSeries(down, true);
   ArraySetAsSeries(atrlo, true);
   ArraySetAsSeries(atrhi, true);
   ArraySetAsSeries(atrclr, true);
   ArraySetAsSeries(arrup, true);
   ArraySetAsSeries(arrdwn, true);
   ArraySetAsSeries(trend, true);
   ArraySetAsSeries(iMAHigh, true);
   ArraySetAsSeries(iMALow, true);
   ArraySetAsSeries(iATRx, true);
   if(!ShowBars)
   {
      PlotIndexSetInteger(2,PLOT_LINE_COLOR,0,clrNONE); 
      PlotIndexSetInteger(2,PLOT_LINE_COLOR,1,clrNONE); 
   }
   else
   {
      PlotIndexSetInteger(2,PLOT_LINE_COLOR,0,clrDodgerBlue); 
      PlotIndexSetInteger(2,PLOT_LINE_COLOR,1,clrRed); 
   }
   if(!ShowArrows)
   {
      PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_NONE);
      PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_NONE);
   }
   else
   {
      PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_ARROW);
      PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_ARROW);
      PlotIndexSetInteger(3, PLOT_ARROW, 225);     //233
      PlotIndexSetInteger(4, PLOT_ARROW, 226);     //234
   }
   ind_mahi = iMA(NULL, 0, Amplitude, 0, MODE_SMA, PRICE_HIGH);
   ind_malo = iMA(NULL, 0, Amplitude, 0, MODE_SMA, PRICE_LOW);
   ind_atr = iATR(NULL, 0, 100);
   if(ind_mahi == INVALID_HANDLE || ind_mahi == INVALID_HANDLE || ind_atr == INVALID_HANDLE)
   {
      PrintFormat("Failed to create handle of the indicators, error code %d", GetLastError());
      return(INIT_FAILED);
   }
   nexttrend = 0;
   minhighprice = iHigh(NULL, 0, Bars(NULL, 0) - 1);
   maxlowprice = iLow(NULL, 0, Bars(NULL, 0) - 1);
   return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  OnCalculate(
   const int        rates_total,       // size of input time series
   const int        prev_calculated,   // number of handled bars at the previous call
   const datetime&  time[],            // Time array
   const double&    open[],            // Open array
   const double&    high[],            // High array
   const double&    low[],             // Low array
   const double&    close[],           // Close array
   const long&      tick_volume[],     // Tick Volume array
   const long&      volume[],          // Real Volume array
   const int&       spread[]           // Spread array
)
{
   int i, limit, to_copy;
   double atr, lowprice_i, highprice_i, lowma, highma;
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   if(prev_calculated > rates_total || prev_calculated < 0) to_copy = rates_total;
   else
   {
      to_copy = rates_total - prev_calculated;
      if(prev_calculated > 0)
         to_copy += 10;
   }
   if(!RefreshBuffers(iMAHigh, iMALow, iATRx, ind_mahi, ind_malo, ind_atr, to_copy))
      return(0);
   if(prev_calculated == 0)
      limit = rates_total - 2;
   else
      limit = rates_total - prev_calculated + 1;
   for(i = limit; i >= 0; i--)
   {
      lowprice_i = iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, Amplitude, i));
      highprice_i = iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, Amplitude, i));
      lowma = NormalizeDouble(iMALow[i], _Digits);
      highma = NormalizeDouble(iMAHigh[i], _Digits);
      trend[i] = trend[i + 1];
      atr = iATRx[i] / 2;
      arrup[i]  = EMPTY_VALUE;
      arrdwn[i] = EMPTY_VALUE;
      if(trend[i + 1] != 1.0)
      {
         maxlowprice = MathMax(lowprice_i, maxlowprice);
         if(highma < maxlowprice && close[i] < low[i + 1])
         {
            trend[i] = 1.0;
            nexttrend = 0;
            minhighprice = highprice_i;
         }
      }
      else
      {
         minhighprice = MathMin(highprice_i, minhighprice);
         if(lowma > minhighprice && close[i] > high[i + 1])
         {
            trend[i] = 0.0;
            nexttrend = 1;
            maxlowprice = lowprice_i;
         }
      }
      //---
      if(trend[i] == 0.0)
      {
         if(trend[i + 1] != 0.0)
         {
            up[i] = down[i + 1];
            up[i + 1] = up[i];
            arrup[i] = up[i] - 2 * atr;
         }
         else
         {
            up[i] = MathMax(maxlowprice, up[i + 1]);
         }
         atrhi[i] = up[i] - atr;
         atrlo[i] = up[i];
         atrclr[i] = 0;
         down[i] = 0.0;
      }
      else
      {
         if(trend[i + 1] != 1.0)
         {
            down[i] = up[i + 1];
            down[i + 1] = down[i];
            arrdwn[i] = down[i] + 2 * atr;
         }
         else
         {
            down[i] = MathMin(minhighprice, down[i + 1]);
         }
         atrhi[i] = down[i] + atr;
         atrlo[i] = down[i];
         atrclr[i] = 1;
         up[i] = 0.0;
      }
   }
   manageAlerts();
   return (rates_total);
}

//+------------------------------------------------------------------+
//| Filling indicator buffers from the indicators                    |
//+------------------------------------------------------------------+
bool RefreshBuffers(double &hi_buffer[],
                    double &lo_buffer[],
                    double &atr_buffer[],
                    int hi_handle,
                    int lo_handle,
                    int atr_handle,
                    int amount
                   )
{
//--- reset error code
   ResetLastError();
//--- fill a part of the iMACDBuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(hi_handle, 0, 0, amount, hi_buffer) < 0)
   {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the MaHigh indicator, error code %d", GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
   }
//--- fill a part of the SignalBuffer array with values from the indicator buffer that has index 1
   if(CopyBuffer(lo_handle, 0, 0, amount, lo_buffer) < 0)
   {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the MaLow indicator, error code %d", GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
   }
//--- fill a part of the StdDevBuffer array with values from the indicator buffer
   if(CopyBuffer(atr_handle, 0, 0, amount, atr_buffer) < 0)
   {
      //--- if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the ATR indicator, error code %d", GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated
      return(false);
   }
//--- everything is fine
   return(true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void manageAlerts()
{
   int whichBar;
   if (alertsOn)
   {
      if (alertsOnCurrent)
         whichBar = 0;
      else
         whichBar = 1;
      if (arrup[whichBar]  != EMPTY_VALUE) doAlert(whichBar, "up");
      if (arrdwn[whichBar] != EMPTY_VALUE) doAlert(whichBar, "down");
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(int forBar, string doWhat)
{
   static string   previousAlert = "nothing";
   static datetime previousTime;
   string message;
   if (previousAlert != doWhat || previousTime != iTime(NULL, 0, forBar))
   {
      previousAlert  = doWhat;
      previousTime   = iTime(NULL, 0, forBar);
      message = StringFormat("%s at %s", Symbol(), TimeToString(TimeLocal(), TIME_SECONDS), " HalfTrend signal ", doWhat);
      if (alertsMessage) Alert(message);
      if (alertsEmail)   SendMail(Symbol(), StringFormat("HalfTrend %s", message));
      if (alertsSound)   PlaySound("alert2.wav");
   }
}

//+------------------------------------------------------------------+
