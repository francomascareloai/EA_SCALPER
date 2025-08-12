//+------------------------------------------------------------------+
//|                                              Keltner Channel.mq5 |
//|                              Copyright 2009-2024, MetaQuotes Ltd |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2009-2024, MetaQuotes Ltd"
#property link        "http://www.mql5.com"
#property description "Keltner Channel"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
//--- labels
#property indicator_label1  "Upper Keltner"
#property indicator_label2  "Middle Keltner"
#property indicator_label3  "Lower Keltner"

//--- input parameters
input int    InpEMAPeriod=20;    // Period of EMA
input int    InpATRPeriod=10;    // Period of ATR
input double InpATRFactor=2.0;   // ATR multiplier
input bool   InpShowLabel=true;  // Show price of level


//--- global variables for parameters
int    ExtEMAPeriod;
int    ExtATRPeriod;
double ExtATRFactor;

//--- indicator buffers
double ExtUppBuffer[];
double ExtEMABuffer[];
double ExtDwnBuffer[];

//--- indicator handles
int    ExtEMAHandle;
int    ExtATRHandle;

//--- unique prefix to identify indicator objects
string ExtPrefixUniq;
int    ExtPeriod;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- check for input values
   if(InpEMAPeriod<10)
     {
      ExtEMAPeriod=20;
      PrintFormat("Incorrect value for input variable InpEMAPeriod=%d. Indicator will use value=%d for calculations.",
                  InpEMAPeriod, ExtEMAPeriod);
     }
   else
      ExtEMAPeriod=InpEMAPeriod;

   if(InpATRPeriod<3)
     {
      ExtATRPeriod=10;
      PrintFormat("Incorrect value for input variable InpATRPeriod=%d. Indicator will use value=%d for calculations.",
                  InpATRPeriod, ExtATRPeriod);
     }
   else
      ExtATRPeriod=InpATRPeriod;

   if(InpATRFactor<1.0)
     {
      ExtATRFactor=2.0;
      PrintFormat("Incorrect value for input variable InpBandsDeviations=%f. Indicator will use value=%f for calculations.",
                  InpATRFactor, ExtATRFactor);
     }
   else
      ExtATRFactor=InpATRFactor;

//--- define buffers
   SetIndexBuffer(0, ExtUppBuffer);
   SetIndexBuffer(1, ExtEMABuffer);
   SetIndexBuffer(2, ExtDwnBuffer);

//--- indexes draw begin settings
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, InpEMAPeriod+1);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, InpEMAPeriod+1);
   PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, InpEMAPeriod+1);

//--- set a 1-bar offset for each line
   PlotIndexSetInteger(0, PLOT_SHIFT, 1);
   PlotIndexSetInteger(1, PLOT_SHIFT, 1);
   PlotIndexSetInteger(2, PLOT_SHIFT, 1);

//--- set drawing line empty value
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0.0);

//--- indicator name
   IndicatorSetString(INDICATOR_SHORTNAME, "Keltner Channel");
//--- number of digits of indicator value
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

//--- create indicators
   ExtEMAHandle=iMA(NULL, 0, InpEMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
   ExtATRHandle=iATR(NULL, 0, InpATRPeriod);

   ExtPeriod=PeriodSeconds(_Period);

//--- prepare prefix for objects
   string number=StringFormat("%I64d", GetTickCount64());
   ExtPrefixUniq=StringSubstr(number, StringLen(number)-4);
   ExtPrefixUniq=ExtPrefixUniq+"_KLT";
   Print("Indicator \"Keltner Channels\" started, prefix=", ExtPrefixUniq);

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
//--- if this is the first calculation of the indicator
   if(prev_calculated==0)
     {
      //--- populate the beginning values, for which the indicator cannot be calculated, with empty values
      ArrayFill(ExtUppBuffer, 0, rates_total, 0);
      ArrayFill(ExtEMABuffer, 0, rates_total, 0);
      ArrayFill(ExtDwnBuffer, 0, rates_total, 0);

      //--- get EMA values into the indicator buffer
      if(CopyBuffer(ExtEMAHandle, 0, 0, rates_total, ExtEMABuffer)<0)
         return(0);

      //--- get ATR indicator values into a dynamic array
      double atr[];
      if(CopyBuffer(ExtATRHandle, 0, 0, rates_total, atr)<0)
         return(0);

      //--- shift from the beginning by the required number of bars
      int start=MathMax(InpEMAPeriod, InpATRPeriod)+1;

      //--- fill in the values of the upper and lower channel borders
      for(int i=start; i<rates_total; i++)
        {
         ExtUppBuffer[i]=ExtEMABuffer[i]+InpATRFactor*atr[i];
         ExtDwnBuffer[i]=ExtEMABuffer[i]-InpATRFactor*atr[i];
        }

      //--- succesfully calculated
      return(rates_total);
     }

//--- if the indicator has previously been calculated, calculate values for the last 2 bars
   int start=prev_calculated-2;
   for(int i=start; i<rates_total; i++)
     {
      //--- for element-by-element copying from the indicator, use the reverse index
      int reverse_index=rates_total-i;

      //--- get indicator values
      double ema[];
      if(CopyBuffer(ExtEMAHandle, 0, reverse_index, 1, ema)<0)
         return(prev_calculated);
      double atr[];
      if(CopyBuffer(ExtATRHandle, 0, reverse_index, 1, atr)<0)
         return(prev_calculated);

      //--- write values into buffers
      ExtEMABuffer[i]=ema[0];
      ExtUppBuffer[i]=ema[0]+InpATRFactor*atr[0];
      ExtDwnBuffer[i]=ema[0]-InpATRFactor*atr[0];
     }

//--- draw labels on levels
   if(InpShowLabel)
     {
      ShowPriceLevels(time[rates_total-1]+ExtPeriod, rates_total-1);
      ChartRedraw();
     }

//--- succesfully calculated
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- delete all our graphical objects after use
   Print("Indicator \"Keltner Channels\" stopped, delete all objects with prefix=", ExtPrefixUniq);
   ObjectsDeleteAll(0, ExtPrefixUniq, 0, OBJ_ARROW_RIGHT_PRICE);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//|  Show prices' levels                                             |
//+------------------------------------------------------------------+
void ShowPriceLevels(datetime time, int last_index)
  {
   ShowRightPrice(ExtPrefixUniq+"_Upp", time, ExtUppBuffer[last_index], clrBlue);
   ShowRightPrice(ExtPrefixUniq+"_EMA", time, ExtEMABuffer[last_index], clrGray);
   ShowRightPrice(ExtPrefixUniq+"_DWN", time, ExtDwnBuffer[last_index], clrRed);
  }
//+------------------------------------------------------------------+
//| Create or Update "Right Price Label" object                      |
//+------------------------------------------------------------------+
bool ShowRightPrice(const string name, datetime time, double price, color clr)
  {
   if(!ObjectCreate(0, name, OBJ_ARROW_RIGHT_PRICE, 0, time, price))
     {
      ObjectMove(0, name, 0, time, price);
      return(false);
     }

//--- make the label size adaptive
   long scale=2;
   if(!ChartGetInteger(0, CHART_SCALE, 0, scale))
     {
      //--- output an error message to the Experts journal
      Print(__FUNCTION__+", ChartGetInteger(CHART_SCALE) failed, error = ", GetLastError());
     }
   int width=scale>1 ? 2:1;  // if chart scale > 1, then label size = 2

   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);

   return(true);
  }
//+------------------------------------------------------------------+
