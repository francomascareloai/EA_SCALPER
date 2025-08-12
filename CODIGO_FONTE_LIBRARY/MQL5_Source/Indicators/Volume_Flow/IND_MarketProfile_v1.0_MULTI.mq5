//+------------------------------------------------------------------+
//|                                                MarketProfile.mq5 |
//|                              Copyright 2009-2024, MetaQuotes Ltd |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

//--- input parameters
input uint  InpStartDate       =0;           // day number to start calculation
input uint  InpShowDays        =3;           // number of days to display
input int   InpMultiplier      =1;           // histogram length multiplier
input color InpAsiaSession     =clrGold;     // Asian session
input color InpEuropeSession   =clrBlue;     // European session
input color InpAmericaSession  =clrViolet;   // American session
input uint  InpEuropeStartHour =8;           // European session opening hour
input uint  InpAmericaStartHour=14;          // American session opening hour

//--- unique prefix to identify indicator objects
string ExtPrefixUniq;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- prepare prefix for objects
   string number=StringFormat("%I64d", GetTickCount64());
   ExtPrefixUniq=StringSubstr(number, StringLen(number)-4);
   Print("Indicator \"Market Profile\" started, prefix=", ExtPrefixUniq);

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
//--- opening time of the current daily bar
   datetime static open_time=0;

//--- number of the last day for calculations
   uint lastday=InpStartDate+InpShowDays;

//--- if the calculation has already been done
   if(prev_calculated!=0)
     {
      datetime current_open=iTime(Symbol(), PERIOD_D1, 0);
      //---  no calculation needed for the first day
      if(InpStartDate!=0)
        {
         //--- if the opening time has not been updated
         if(current_open==open_time)
            return(rates_total);  // no calculation needed, exit
        }
      //--- update the opening time
      open_time=current_open;
      //--- further in the code calculate only one day
      lastday=InpStartDate+1;
     }

//--- calculate for the specified number of days
   for(uint day=InpStartDate; day<lastday; day++)
     {
      //--- get the day with the 'day' index
      MqlRates day_rate[];
      //--- if getting the current day failed
      //--- if you're running the indicator on weekend or holiday when there are no ticks
      //--- first open D1 chart for the symbol
      if(CopyRates(Symbol(), PERIOD_D1, day, 1, day_rate)==-1)
         return(prev_calculated); // exit and try the next call

      //--- get the range of the day in points
      double high_day=day_rate[0].high;
      double low_day=day_rate[0].low;
      double point=SymbolInfoDouble(Symbol(), SYMBOL_POINT);
      int    day_size=(int)((high_day-low_day)/point);

      //--- prepare an array of boxes to check the price
      int boxes_asia[], boxes_europe[], boxes_america[];
      ArrayResize(boxes_asia, day_size);
      ArrayResize(boxes_europe, day_size);
      ArrayResize(boxes_america, day_size);
      ZeroMemory(boxes_asia);
      ZeroMemory(boxes_europe);
      ZeroMemory(boxes_america);

      //--- get current day bars
      MqlRates bars_in_day[];
      datetime start_time=day_rate[0].time+PeriodSeconds(PERIOD_D1)-1;
      datetime stop_time=day_rate[0].time;
      //--- if you're running the indicator on weekend or holiday when there are no ticks
      //--- first open D1 chart for the symbol
      //--- if getting the current timeframe bars for the specified day fails
      if(CopyRates(Symbol(), PERIOD_CURRENT, start_time, stop_time, bars_in_day)==-1)
         return(prev_calculated); // exit and try the next call

      //---- iterate through all bars of the current day and mark the boxes they fall into
      int size=ArraySize(bars_in_day);
      for(int i=0; i<size; i++)
        {
         int         start_box=(int)((bars_in_day[i].low-low_day)/point);
         int         stop_box=(int)((bars_in_day[i].high-low_day)/point);
         MqlDateTime bar_time;
         TimeToStruct(bars_in_day[i].time, bar_time);
         uint        hour=bar_time.hour;

         if(hour>=InpAmericaStartHour)
           {
            for(int ind=start_box; ind<stop_box; ind++)
               boxes_america[ind]++;
           }
         else
           {
            if(hour>=InpEuropeStartHour && hour<InpAmericaStartHour)
               for(int ind=start_box; ind<stop_box; ind++)
                  boxes_europe[ind]++;
            else
               for(int ind=start_box; ind<stop_box; ind++)
                  boxes_asia[ind]++;
           }
        }

      //--- draw the profile
      string day_prefix=TimeToString(day_rate[0].time, TIME_DATE);
      int    box_length=PeriodSeconds(PERIOD_CURRENT);

      //--- Asia
      for(int ind=0; ind<day_size; ind++)
        {
         if(boxes_asia[ind]>0)
           {
            double   price=low_day+ind*point;
            datetime time1=day_rate[0].time;
            datetime time2=time1+boxes_asia[ind]*box_length*InpMultiplier;
            string   prefix=ExtPrefixUniq+"_"+day_prefix+"_Asia_"+StringFormat("%.5f", price);

            DrawBox(prefix, price, time1, time2, InpAsiaSession);
           }
        }

      //--- Europe
      for(int ind=0; ind<day_size; ind++)
        {
         if(boxes_europe[ind]>0)
           {
            double   price=low_day+ind*point;
            datetime time1=day_rate[0].time+boxes_asia[ind]*box_length*InpMultiplier;
            datetime time2=time1+boxes_europe[ind]*box_length*InpMultiplier;
            string   prefix=ExtPrefixUniq+"_"+day_prefix+"_Europe_"+StringFormat("%.5f", price);

            DrawBox(prefix, price, time1, time2, InpEuropeSession);
           }
        }

      //--- America
      for(int ind=0; ind<day_size; ind++)
        {
         if(boxes_america[ind]>0)
           {
            double   price=low_day+ind*point;
            datetime time1=day_rate[0].time+(boxes_asia[ind]+boxes_europe[ind])*box_length*InpMultiplier;
            datetime time2=time1+boxes_america[ind]*box_length*InpMultiplier;
            string   prefix=ExtPrefixUniq+"_"+day_prefix+"_America_"+StringFormat("%.5f", price);

            DrawBox(prefix, price, time1, time2, InpAmericaSession);
           }
        }
     }

//--- redraw all objects
   ChartRedraw(0);

//--- return value of prev_calculated for the next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- delete all our graphical objects after use
   Print("Indicator \"Market Profile\" stopped, delete all objects with prefix=", ExtPrefixUniq);
   ObjectsDeleteAll(0, ExtPrefixUniq, 0, OBJ_RECTANGLE);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Draw color box                                                   |
//+------------------------------------------------------------------+
void DrawBox(string bar_prefix, double price, datetime time1, datetime time2, color clr)
  {
   ObjectCreate(0, bar_prefix, OBJ_RECTANGLE, 0, time1, price, time2, price);
   ObjectSetInteger(0, bar_prefix, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, bar_prefix, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(0, bar_prefix, OBJPROP_WIDTH, 1);
   ObjectSetString(0, bar_prefix, OBJPROP_TOOLTIP, "\n");
   ObjectSetInteger(0, bar_prefix, OBJPROP_BACK, true);
  }
//+------------------------------------------------------------------+
