//+------------------------------------------------------------------+
//|                                             Donchian Channel.mq5 |
//|                              Copyright 2009-2024, MetaQuotes Ltd |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2009-2024, MetaQuotes Ltd"
#property link        "http://www.mql5.com"
#property description "Donchian Channel"
//---
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
#property indicator_label1  "Upper Donchian"
#property indicator_label2  "Middle Donchian"
#property indicator_label3  "Lower Donchian"

//--- input parameter
input int  InpDonchianPeriod=20;    // period of the channel
input bool InpShowLabel     =true;  // show price of the level

//--- indicator buffers
double    ExtUpBuffer[];
double    ExtMdBuffer[];
double    ExtDnBuffer[];

//--- unique prefix to identify indicator objects
string ExtPrefixUniq;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- define buffers
   SetIndexBuffer(0, ExtUpBuffer);
   SetIndexBuffer(1, ExtMdBuffer);
   SetIndexBuffer(2, ExtDnBuffer);

//--- set a 1-bar offset for each line
   PlotIndexSetInteger(0, PLOT_SHIFT, 1);
   PlotIndexSetInteger(1, PLOT_SHIFT, 1);
   PlotIndexSetInteger(2, PLOT_SHIFT, 1);

//--- indicator name
   IndicatorSetString(INDICATOR_SHORTNAME, "Donchian Channel");
//--- number of digits of indicator value
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

//--- prepare prefix for objects
   string number=StringFormat("%I64d", GetTickCount64());
   ExtPrefixUniq=StringSubstr(number, StringLen(number)-4);
   ExtPrefixUniq=ExtPrefixUniq+"_DN";
   Print("Indicator \"Donchian Channels\" started, prefix=", ExtPrefixUniq);

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
   int start=prev_calculated-1;

//--- if this is the first calculation of the indicator, then move by InpDonchianPeriod bars form the beginning
   if(prev_calculated==0)
      start=InpDonchianPeriod+1;

//--- calculate levels for all bars in a loop
   for(int i=start; i<rates_total; i++)
     {
      //--- get max/min values for the last InpDonchianPeriod bars
      int    highest_bar_index=ArrayMaximum(high, i-InpDonchianPeriod+1, InpDonchianPeriod);
      int    lowest_bar_index=ArrayMinimum(low, i-InpDonchianPeriod+1, InpDonchianPeriod);;
      double highest=high[highest_bar_index];
      double lowest=low[lowest_bar_index];

      //--- write values into buffers
      ExtUpBuffer[i]=highest;
      ExtDnBuffer[i]=lowest;
      ExtMdBuffer[i]=(highest+lowest)/2;
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
   Print("Indicator \"Donchian Channels\" stopped, delete all objects with prefix=", ExtPrefixUniq);
   ObjectsDeleteAll(0, ExtPrefixUniq, 0, OBJ_ARROW_RIGHT_PRICE);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//|  Show prices' levels                                             |
//+------------------------------------------------------------------+
void ShowPriceLevels(datetime time, int last_index)
  {
   ShowRightPrice(ExtPrefixUniq+"_UP", time, ExtUpBuffer[last_index], clrBlue);
   ShowRightPrice(ExtPrefixUniq+"_MD", time, ExtMdBuffer[last_index], clrGray);
   ShowRightPrice(ExtPrefixUniq+"_Dn", time, ExtDnBuffer[last_index], clrRed);
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
