//+------------------------------------------------------------------+
//|                                            Camarilla Channel.mq5 |
//|                              Copyright 2009-2024, MetaQuotes Ltd |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2009-2024, MetaQuotes Ltd"
#property link        "http://www.mql5.com"
#property description "Camarilla Channels"

#property indicator_chart_window
#property indicator_buffers 10
#property indicator_plots   10
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_width3  2
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGreen
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGreen
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrRed
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrRed
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrRed
#property indicator_width8  2
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrRed
#property indicator_type10  DRAW_LINE
#property indicator_color10 clrRed
//--- labels
#property indicator_label1  "H5"
#property indicator_label2  "H4"
#property indicator_label3  "H3"
#property indicator_label4  "H2"
#property indicator_label5  "H1"
#property indicator_label6  "L1"
#property indicator_label7  "L2"
#property indicator_label8  "L3"
#property indicator_label9  "L4"
#property indicator_label10 "L5"

//--- input parameter
input bool InpShowLabel=true; // show price of level

//--- indicator buffers
double    ExtH5Buffer[];
double    ExtH4Buffer[];
double    ExtH3Buffer[];
double    ExtH2Buffer[];
double    ExtH1Buffer[];
double    ExtL1Buffer[];
double    ExtL2Buffer[];
double    ExtL3Buffer[];
double    ExtL4Buffer[];
double    ExtL5Buffer[];

//--- unique prefix to identify indicator objects
string ExtPrefixUniq;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- check current timeframe
   if(PeriodSeconds()>PeriodSeconds(PERIOD_D1))
     {
      Alert("Timeframe of chart must be D1 or lower. Exit");
      return(INIT_FAILED);
     }

//--- define buffers
   SetIndexBuffer(0, ExtH5Buffer);
   SetIndexBuffer(1, ExtH4Buffer);
   SetIndexBuffer(2, ExtH3Buffer);
   SetIndexBuffer(3, ExtH2Buffer);
   SetIndexBuffer(4, ExtH1Buffer);
   SetIndexBuffer(5, ExtL1Buffer);
   SetIndexBuffer(6, ExtL2Buffer);
   SetIndexBuffer(7, ExtL3Buffer);
   SetIndexBuffer(8, ExtL4Buffer);
   SetIndexBuffer(9, ExtL5Buffer);

//--- indicator name
   IndicatorSetString(INDICATOR_SHORTNAME, "Camarilla Channels");
//--- number of digits of indicator value
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

//--- prepare prefix for objects
   string number=StringFormat("%I64d", GetTickCount64());
   ExtPrefixUniq=StringSubstr(number, StringLen(number)-4);
   ExtPrefixUniq=ExtPrefixUniq+"_CH";
   Print("Indicator \"Camarilla Channels\" started, prefix=", ExtPrefixUniq);

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
   static MqlRates LAST_DAY[];    // previous day
   static datetime last_time=0;   // reference time
   static datetime error_time=0;  // error output time

//--- if the indicator has previously been calculated, start from the bar preceding the last one
   int start=prev_calculated-1;

//--- if this is the first calculation of the indicator, start from the first bar on the chart
   if(prev_calculated==0)
      start=0;

//--- calculate levels for all bars in a loop
   for(int i=start; i<rates_total; i++)
     {
      //--- get day opening time for the current bar
      datetime rem_seconds=time[i]%PeriodSeconds(PERIOD_D1);
      datetime open_time=time[i]-rem_seconds;

      //--- if the opening time is different from the reference time, update LAST_DAY - level calculations will be based on this value
      if(open_time!=last_time)
        {
         //--- If you're running the indicator on this symbol for the first time,
         //--- first open the D1 chart for the symbol to initiate immediate downloading of daily bars
         //--- if getting the current timeframe bars for the specified day fails
         if(CopyRates(Symbol(), PERIOD_D1, open_time-1, 1, LAST_DAY)!=-1)
           {
            //--- remember the reference time
            last_time=open_time;
           }
         else
           {
            //--- generate error messages no more than once a minute
            if(TimeCurrent()>=error_time)
              {
               error_time=TimeCurrent()+60;
               Print("Failed to get previous day by CopyRates(Symbol(), PERIOD_D1, error ", GetLastError());
              }
            return(prev_calculated);
           }
        }

      //--- calculate levels
      double range=LAST_DAY[0].high - LAST_DAY[0].low;
      double h5=(LAST_DAY[0].high/LAST_DAY[0].low) * LAST_DAY[0].close;
      double h4=LAST_DAY[0].close + range*1.1/2.0;
      double h3=LAST_DAY[0].close + range*1.1/4.0;
      double h2=LAST_DAY[0].close + range*1.1/6.0;
      double h1=LAST_DAY[0].close + range*1.1/12.0;
      double l1=LAST_DAY[0].close - range*1.1/12.0;
      double l2=LAST_DAY[0].close - range*1.1/6.0;
      double l3=LAST_DAY[0].close - range*1.1/4.0;
      double l4=LAST_DAY[0].close - range*1.1/2.0;
      double l5=LAST_DAY[0].close - (h5 -LAST_DAY[0].close);

      //--- write values into buffers
      ExtH5Buffer[i]=h5;
      ExtH4Buffer[i]=h4;
      ExtH3Buffer[i]=h3;
      ExtH2Buffer[i]=h2;
      ExtH1Buffer[i]=h1;
      ExtL1Buffer[i]=l1;
      ExtL2Buffer[i]=l2;
      ExtL3Buffer[i]=l3;
      ExtL4Buffer[i]=l4;
      ExtL5Buffer[i]=l5;
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
   Print("Indicator \"Camarilla Channels\" stopped, delete all objects with prefix=", ExtPrefixUniq);
   ObjectsDeleteAll(0, ExtPrefixUniq, 0, OBJ_ARROW_RIGHT_PRICE);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//|  Show prices' levels                                             |
//+------------------------------------------------------------------+
void ShowPriceLevels(datetime time, int last_index)
  {
   ShowRightPrice(ExtPrefixUniq+"_H5", time, ExtH5Buffer[last_index], clrGreen);
   ShowRightPrice(ExtPrefixUniq+"_H4", time, ExtH4Buffer[last_index], clrGreen);
   ShowRightPrice(ExtPrefixUniq+"_H3", time, ExtH3Buffer[last_index], clrGreen);
   ShowRightPrice(ExtPrefixUniq+"_H2", time, ExtH2Buffer[last_index], clrGreen);
   ShowRightPrice(ExtPrefixUniq+"_H1", time, ExtH1Buffer[last_index], clrGreen);
   ShowRightPrice(ExtPrefixUniq+"_L1", time, ExtL1Buffer[last_index], clrRed);
   ShowRightPrice(ExtPrefixUniq+"_L2", time, ExtL2Buffer[last_index], clrRed);
   ShowRightPrice(ExtPrefixUniq+"_L3", time, ExtL3Buffer[last_index], clrRed);
   ShowRightPrice(ExtPrefixUniq+"_L4", time, ExtL4Buffer[last_index], clrRed);
   ShowRightPrice(ExtPrefixUniq+"_L5", time, ExtL5Buffer[last_index], clrRed);
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
