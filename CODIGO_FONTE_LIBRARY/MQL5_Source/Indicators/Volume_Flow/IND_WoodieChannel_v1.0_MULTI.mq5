//+------------------------------------------------------------------+
//|                                           Woodie Channel.mq5.mq5 |
//|                              Copyright 2009-2024, MetaQuotes Ltd |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "2009-2024, MetaQuotes Ltd"
#property link        "http://www.mql5.com"
#property description "Woodie Channels"

#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   9
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGreen
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrBlue
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrRed
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrRed
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrRed
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrRed

//--- labels
#property indicator_label1  "R4"
#property indicator_label2  "R3"
#property indicator_label3  "R2"
#property indicator_label4  "R1"
#property indicator_label5  "PP"
#property indicator_label6  "S1"
#property indicator_label7  "S2"
#property indicator_label8  "S3"
#property indicator_label9  "S4"

//--- input parameter
input bool InpShowLabel=true; // show price of level

//--- indicator buffers
double        ExtR4Buffer[];
double        ExtR3Buffer[];
double        ExtR2Buffer[];
double        ExtR1Buffer[];
double        ExtPPBuffer[];
double        ExtS1Buffer[];
double        ExtS2Buffer[];
double        ExtS3Buffer[];
double        ExtS4Buffer[];

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
   SetIndexBuffer(0, ExtR4Buffer);
   SetIndexBuffer(1, ExtR3Buffer);
   SetIndexBuffer(2, ExtR2Buffer);
   SetIndexBuffer(3, ExtR1Buffer);
   SetIndexBuffer(4, ExtPPBuffer);
   SetIndexBuffer(5, ExtS1Buffer);
   SetIndexBuffer(6, ExtS2Buffer);
   SetIndexBuffer(7, ExtS3Buffer);
   SetIndexBuffer(8, ExtS4Buffer);

//--- indicator name
   IndicatorSetString(INDICATOR_SHORTNAME, "Woodie Channels");
//--- number of digits of indicator value
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

//--- prepare prefix for objects
   string number=StringFormat("%I64d", GetTickCount64());
   ExtPrefixUniq=StringSubstr(number, StringLen(number)-4);
   ExtPrefixUniq=ExtPrefixUniq+"_WD";
   Print("Indicator \"Woodie Channels\" started, prefix=", ExtPrefixUniq);

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
      double pp=(LAST_DAY[0].high+LAST_DAY[0].low+2* LAST_DAY[0].close)/4;
      double r1=2*pp-LAST_DAY[0].low;
      double r2=pp+(LAST_DAY[0].high-LAST_DAY[0].low);
      double r3=r2+(r1-pp);
      double r4=r3+(r2-pp);
      double s1=2*pp -LAST_DAY[0].high;
      double s2=pp-(LAST_DAY[0].high-LAST_DAY[0].low);
      double s3=s2-(pp-s1);
      double s4=s3-(pp-s2);

      //--- write values into buffers
      ExtR4Buffer[i]=r4;
      ExtR3Buffer[i]=r3;
      ExtR2Buffer[i]=r2;
      ExtR1Buffer[i]=r1;
      ExtPPBuffer[i]=pp;
      ExtS1Buffer[i]=s1;
      ExtS2Buffer[i]=s2;
      ExtS3Buffer[i]=s3;
      ExtS4Buffer[i]=s4;
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
   Print("Indicator \"Woodie Channel\" stopped, delete all objects with prefix=", ExtPrefixUniq);
   ObjectsDeleteAll(0, ExtPrefixUniq, 0, OBJ_ARROW_RIGHT_PRICE);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//|  Show prices' levels                                             |
//+------------------------------------------------------------------+
void ShowPriceLevels(datetime time, int last_index)
  {
   ShowRightPrice(ExtPrefixUniq+"_R4", time, ExtR4Buffer[last_index], clrGreen);
   ShowRightPrice(ExtPrefixUniq+"_R3", time, ExtR3Buffer[last_index], clrGreen);
   ShowRightPrice(ExtPrefixUniq+"_R2", time, ExtR2Buffer[last_index], clrGreen);
   ShowRightPrice(ExtPrefixUniq+"_R1", time, ExtR1Buffer[last_index], clrGreen);
   ShowRightPrice(ExtPrefixUniq+"_PP", time, ExtPPBuffer[last_index], clrBlue);
   ShowRightPrice(ExtPrefixUniq+"_S1", time, ExtS1Buffer[last_index], clrRed);
   ShowRightPrice(ExtPrefixUniq+"_S2", time, ExtS2Buffer[last_index], clrRed);
   ShowRightPrice(ExtPrefixUniq+"_S3", time, ExtS3Buffer[last_index], clrRed);
   ShowRightPrice(ExtPrefixUniq+"_S4", time, ExtS4Buffer[last_index], clrRed);
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
