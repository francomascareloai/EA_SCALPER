//+------------------------------------------------------------------+
//|                                                 NRTR Channel.mq5 |
//|                              Copyright 2009-2024, MetaQuotes Ltd |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2009-2024, MetaQuotes Ltd"
#property link        "http://www.mql5.com"
#property description "NRTR Channel"
//---
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   4
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDeepSkyBlue
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDeepSkyBlue
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrLightSalmon
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrLightSalmon
//--- labels
#property indicator_label1  "Long Resistance"
#property indicator_label2  "Long Support"
#property indicator_label3  "Short Support"
#property indicator_label4  "Short Resistance"

//--- inputs
input int    InpATRPeriod=40;    // ATR period
input double InpkATR     =2.0;   // ATR multiplier
input bool   InpShowLabel=true;  // show price of level

//--- uptrend buffers
double ExtCeilingBuffer[];
double ExtBuyBuffer[];
//--- downtrend buffers
double ExtSellBuffer[];
double ExtFloorBuffer[];
//--- auxiliary buffers
double ExtTrendBuffer[];
double ExtATRBuffer[];

//--- indicator handle
int    ExtATRHandle;

#define UP_TREND    1
#define DOWN_TREND -1

//--- unique prefix to identify indicator objects
string ExtPrefixUniq;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- define buffers and plots
   SetIndexBuffer(0, ExtCeilingBuffer);
   PlotIndexSetInteger(0, PLOT_ARROW, 159);

   SetIndexBuffer(1, ExtBuyBuffer);
   PlotIndexSetInteger(1, PLOT_ARROW, 251);

   SetIndexBuffer(2, ExtSellBuffer);
   PlotIndexSetInteger(2, PLOT_ARROW, 251);

   SetIndexBuffer(3, ExtFloorBuffer);
   PlotIndexSetInteger(3, PLOT_ARROW, 159);

   SetIndexBuffer(4, ExtTrendBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, ExtATRBuffer, INDICATOR_CALCULATIONS);

//--- indicator name
   IndicatorSetString(INDICATOR_SHORTNAME, "NRTR Channel");
//--- number of digits of indicator value
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

//---- Get the indicator handle
   ExtATRHandle=iATR(NULL, 0, InpATRPeriod);

//--- prepare prefix for objects
   string number=StringFormat("%I64d", GetTickCount64());
   ExtPrefixUniq=StringSubstr(number, StringLen(number)-4);
   ExtPrefixUniq=ExtPrefixUniq+"_NRTR";
   Print("Indicator \"_NRTR Channel\" started, prefix=", ExtPrefixUniq);

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
//--- if the indicator has previously been calculated, start from the bar preceding the last one
   int start=prev_calculated-2;

//--- if this is the first calculation of the indicator, set the calculation start and the trend direction
   if(prev_calculated==0)
     {
      start=InpATRPeriod;
      ArrayFill(ExtSellBuffer, 0, rates_total, EMPTY_VALUE);
      ArrayFill(ExtBuyBuffer, 0, rates_total, EMPTY_VALUE);
      ArrayFill(ExtCeilingBuffer, 0, rates_total, EMPTY_VALUE);
      ArrayFill(ExtFloorBuffer, 0, rates_total, EMPTY_VALUE);
      ArrayFill(ExtTrendBuffer, 0, rates_total, EMPTY_VALUE);

      //--- trend direction
      if(close[start-1]>low[start-1])
        {
         ExtTrendBuffer[start-1]=UP_TREND;
         ExtCeilingBuffer[start-1]=close[start-1];
         ExtBuyBuffer [start-1]=close[start-1]-InpkATR*ExtATRBuffer[start-1];
        }
      else
        {
         ExtTrendBuffer[start-1]=DOWN_TREND;
         ExtFloorBuffer[start-1]=close[start-1];
         ExtSellBuffer[start-1]=close[start-1]+InpkATR*ExtATRBuffer[start-1];
        }
     }

//--- indicator values in the buffer
   if(CopyBuffer(ExtATRHandle, 0, 0, rates_total, ExtATRBuffer)<0)
      return(0);

//--- calculate levels for all bars in a loop
   for(int i=start; i<rates_total; i++)
     {
      //--- if there was an uptrend on the previous bar
      if(ExtTrendBuffer[i-1]>0)
        {
         //--- if Low of the current bar is higher than the resistance level on the previous bar
         if(low[i]>ExtCeilingBuffer[i-1])
           {
            //--- update resistance levels
            ExtCeilingBuffer[i]=close[i];      // uptrend resistance level
            ExtFloorBuffer[i]=EMPTY_VALUE;     // empty downtrend resistance level
            //--- update support levels
            ExtBuyBuffer[i]=close[i]-InpkATR*ExtATRBuffer[i];
            ExtSellBuffer[i]=EMPTY_VALUE;
            //--- set the sign of an uptrend on the current bar
            ExtTrendBuffer[i]=UP_TREND;
            continue;
           }

         //--- if closed lower than the previous-bar support level
         if(close[i]<ExtBuyBuffer[i-1])
           {
            ExtTrendBuffer[i]=DOWN_TREND;                          // downtrend
            //--- set levels for the downtrend
            ExtFloorBuffer[i]=close[i];                            // resistance level
            ExtSellBuffer[i]=close[i]+InpkATR * ExtATRBuffer[i];   // support
            //--- delete uptrend levels
            ExtCeilingBuffer[i]=EMPTY_VALUE;
            ExtBuyBuffer[i]=EMPTY_VALUE;
            continue;
           }
        }
      else  // if there was a downtrend on the previous bar
        {
         //--- if High of the current bar is lower than the resistance level on the previous bar
         if(high[i]<ExtFloorBuffer[i-1])
           {
            //--- update resistance levels
            ExtFloorBuffer[i]=close[i];        // downtrend resistance level
            ExtCeilingBuffer[i]=EMPTY_VALUE;   // empty uptrend resistance level
            //--- update support levels
            ExtSellBuffer[i]=close[i]+InpkATR*ExtATRBuffer[i];
            ExtBuyBuffer[i]=EMPTY_VALUE;
            //--- set the sign of a downtrend on the current bar
            ExtTrendBuffer[i]=DOWN_TREND;
            continue;
           }

         //--- if closed higher than the previous-bar support level
         if(close[i]>ExtSellBuffer[i-1])
           {
            ExtTrendBuffer[i]=UP_TREND;                        // uptrend
            //--- set levels for the uptrend
            ExtCeilingBuffer[i]=close[i];                      // resistance level
            ExtBuyBuffer[i]=close[i]-InpkATR*ExtATRBuffer[i];  // support
            //--- delete downtrend levels
            ExtFloorBuffer[i]=EMPTY_VALUE;
            ExtSellBuffer[i]=EMPTY_VALUE;
            continue;
           }
        }

      //--- if we reached this code line, the trend has not changed
      //--- so, copy the previous buffer values
      ExtSellBuffer[i]   = ExtSellBuffer[i-1];
      ExtBuyBuffer[i]    = ExtBuyBuffer[i-1];
      ExtCeilingBuffer[i]= ExtCeilingBuffer[i-1];
      ExtFloorBuffer[i]  = ExtFloorBuffer[i-1];
      ExtTrendBuffer[i]  = ExtTrendBuffer[i-1];
     }

//--- draw labels on levels
   if(InpShowLabel)
     {
      ShowPriceLevels(time[rates_total-1], rates_total-1);
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
   Print("Indicator \"NRTR Channel\" stopped, delete all objects with prefix=", ExtPrefixUniq);
   ObjectsDeleteAll(0, ExtPrefixUniq, 0, OBJ_ARROW_RIGHT_PRICE);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//|  Show prices' levels                                             |
//+------------------------------------------------------------------+
void ShowPriceLevels(datetime time, int last_index)
  {
   color clr;
   double up, dn;
//--- define color and levels
   if(ExtTrendBuffer[last_index]==UP_TREND)
     {
      clr=clrDeepSkyBlue;
      up=ExtCeilingBuffer[last_index];
      dn=ExtBuyBuffer[last_index];
     }
   else
     {
      clr=clrLightSalmon;
      up=ExtSellBuffer[last_index];
      dn=ExtFloorBuffer[last_index];
     }

   ShowRightPrice(ExtPrefixUniq+"_Res", time, up, clr);
   ShowRightPrice(ExtPrefixUniq+"_Sup", time, dn, clr);
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
   int width=scale>2 ? 2:1;  // if chart scale > 1, then label size = 2

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
