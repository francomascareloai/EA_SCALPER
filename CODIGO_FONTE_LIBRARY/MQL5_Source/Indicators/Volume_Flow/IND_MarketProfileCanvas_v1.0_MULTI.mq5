//+------------------------------------------------------------------+
//|                                         MarketProfile Canvas.mq5 |
//|                              Copyright 2009-2024, MetaQuotes Ltd |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

#include<Canvas\Canvas.mqh>
#include <Generic\ArrayList.mqh>

//--- input parameters
input uint  InpStartDate       =0;           // day number to start calculation
input uint  InpShowDays        =7;           // number of days to show
input int   InpMultiplier      =1;           // histogram length multiplier
input color InpAsiaSession     =clrGold;     // Asian session
input color InpEuropeSession   =clrBlue;     // European session
input color InpAmericaSession  =clrViolet;   // American session
input uchar InpTransparency    =150;         // transparency, 0 = invisible
input uint  InpEuropeStartHour =8;           // European session opening hour
input uint  InpAmericaStartHour=14;          // American session opening hour

//--- unique prefix to identify indicator objects
string ExtPrefixUniq;

//--- forward class declaration
class CMarketProfile;
//--- collection of pointers of CMarketProfile type
CArrayList<CMarketProfile*> mp_list;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- prepare prefix for objects
   string number=StringFormat("%I64d", GetTickCount64());
   ExtPrefixUniq=StringSubstr(number, StringLen(number)-4);
   Print("Indicator \"Market Profile Canvas\" started, prefix=", ExtPrefixUniq);

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
      //--- and we don't need to calculate Market Profile for the first day
      if(InpStartDate!=0)
        {
         //--- if the opening time has not been updated
         if(open_time==current_open)
            return(rates_total);  // no calculation needed, exit
        }
      //--- otherwise, updated the opening time
      open_time=current_open;
      //--- further in the code, we will calculate Market Profile for only one day
      lastday=InpStartDate+1;
     }

//--- make calculations for the specified days range
   for(uint day=InpStartDate; day<lastday; day++)
     {
      //--- get the day with the 'day' index
      MqlRates day_rate[];
      //--- if getting the current day failed
      //--- if you're running the indicator on weekend or holiday when there are no ticks
      //--- first open D1 chart for the symbol
      if(CopyRates(Symbol(), PERIOD_D1, day, 1, day_rate)==-1)
         return(prev_calculated); // exit and try the next call

      //--- get the beginning and end of the day
      datetime start_time=day_rate[0].time;
      datetime stop_time=start_time+PeriodSeconds(PERIOD_D1)-1;

      //--- get current day bars
      MqlRates bars_in_day[];
      if(CopyRates(Symbol(), PERIOD_CURRENT, start_time, stop_time, bars_in_day)==-1)
         return(prev_calculated); // exit and try the next call

      CMarketProfile *market_profile;
      //--- if Market Profile calculations and drawing have already been done earlier
      if(prev_calculated>0) // then update the profile of the current day having the index of 0
        {
         //--- search for the required CMarketProfile profile in the mp_list collection: it must be there
         market_profile=GetMarketProfileByDate(ExtPrefixUniq, start_time);
         //--- check
         if(market_profile==NULL)
           {
            PrintFormat("Market Profile not found for %s. Indicator will be recalculated for all specified days",
                        TimeToString(start_time, TIME_DATE));
            return(0);  // exit with zero value to ensure all calculations are done again
           }
         //--- the CMarketProfile object not found; pass valid High/Low values and a set of current-timeframe bars to it
         market_profile.SetHiLoBars(day_rate[0].high, day_rate[0].low, bars_in_day);
        }
      else
        {
         //--- create a new object to store the profile
         market_profile = new CMarketProfile(ExtPrefixUniq, start_time, stop_time, day_rate[0].high, day_rate[0].low, bars_in_day);
         //--- add the created CMarketProfile to the collection
         mp_list.Add(market_profile);
        }
      //--- set drawing parameters
      market_profile.UpdateSizes();
      //--- calculate profiles for each session
      market_profile.CalculateSessions();
      //--- draw the profile
      market_profile.Draw(InpMultiplier);
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
//--- delete all our Market Profile graphical objects after use
   Print("Indicator \"Market Profile Canvas\" stopped, delete all objects CMarketProfile with prefix=", ExtPrefixUniq);
   int size=mp_list.Count();
   for(int i=0; i<size; i++)
     {
      CMarketProfile *market_profile;
      mp_list.TryGetValue(i, market_profile);
      if(market_profile!=NULL)
         if(CheckPointer(market_profile)!=POINTER_INVALID)
            delete market_profile;
     }
   ChartRedraw(0);
//---
  }

//+------------------------------------------------------------------+
//| Custom indicator chart's event handler                           |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
  {
//--- do not handle user events
   if(id>=CHARTEVENT_CUSTOM)
      return;

//--- there have been changes on the chart
   if(CHARTEVENT_CHART_CHANGE==id)
     {
      int size=mp_list.Count();
      for(int i=0; i<size; i++)
        {
         CMarketProfile *market_profile;
         mp_list.TryGetValue(i, market_profile);
         if(market_profile)
            if(market_profile.isVisibleOnChart())
              {
               market_profile.UpdateSizes();
               market_profile.Draw(InpMultiplier);
              }
        }
      //--- update the chart after calculating all Market Profiles
      ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
//| Returns CMarketProfile or NULL by the date                       |
//+------------------------------------------------------------------+
CMarketProfile* GetMarketProfileByDate(string prefix, datetime time)
  {
   int size=mp_list.Count();
   for(int i=0; i<size; i++)
     {
      CMarketProfile *market_profile;
      mp_list.TryGetValue(i, market_profile);
      if(market_profile!=NULL)
         if(CheckPointer(market_profile)!=POINTER_INVALID)
           {
            //--- check that the received market_profile pointer was created for the specified 'time' date
            if(market_profile.Check(prefix, time))
               return(market_profile);   // CMarketProfile object found by date
           }
     }
//--- not found
   return(NULL);
  }
//+------------------------------------------------------------------+
//| Class to store and draw Market Profile for the daily bar         |
//+------------------------------------------------------------------+
class CMarketProfile
  {
public:
                     CMarketProfile() {};
                     CMarketProfile(string prefix, datetime time1, datetime time2, double high, double low, MqlRates &bars[]);
                    ~CMarketProfile(void);

   //--- checks if the object is created for the specified 'time' date
   bool              Check(string prefix, datetime time);
   //--- sets High/Low and a set of current-timeframe bars
   void              SetHiLoBars(double high, double low, MqlRates &bars[]);
   //--- sets drawing parameters
   void              UpdateSizes(void);
   //--- is the profile in the visible part of the chart?
   bool              isVisibleOnChart(void);
   //--- has the chart scale changed?
   bool              isChartScaleChanged(void);
   //--- calculate the profile by sessions
   bool              CalculateSessions(void);
   //--- draw the profile
   void              Draw(double multiplier=1.0);
   //---
protected:
   CCanvas           m_canvas;      // canvas object to draw the profile
   uchar             m_alpha;       // alpha channel value that sets transparency
   string            m_prefix;      // unique prefix of OBJ_BITMAP object
   string            m_name;        // name of the OBJ_BITMAP object used in m_canvas
   double            m_high;        // day High
   double            m_low;         // day Low
   datetime          m_time1;       // day beginning
   datetime          m_time2;       // day end
   int               m_day_size_pt; // daily bar height in points
   int               m_height;      // daily bar height in pixels on the chart
   int               m_width;       // daily bar width in pixels on the chart
   MqlRates          m_bars[];      // current-timeframe bars between m_time1 and m_time2
   vector            m_asia;        // Asian session counters
   vector            m_europe;      // European session counters
   vector            m_america;     // American session counters
   double            m_vert_scale;  // factor conversion box -> y
   double            m_hor_scale;   // factor conversion count -> x
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void CMarketProfile::CMarketProfile(string prefix, datetime time1, datetime time2, double high, double low, MqlRates &bars[]):
   m_prefix(prefix),
   m_time1(time1),
   m_time2(time2),
   m_high(high),
   m_low(low),
   m_vert_scale(NULL),
   m_hor_scale(NULL)
  {
   ArrayCopy(m_bars, bars);
   m_name=ExtPrefixUniq+"_MP_"+TimeToString(time1, TIME_DATE);
   m_day_size_pt=(int)((m_high-m_low)/SymbolInfoDouble(Symbol(), SYMBOL_POINT));
//--- set the sizes of vectors for trading sessions
   m_asia=vector::Zeros(m_day_size_pt);
   m_europe=vector::Zeros(m_day_size_pt);
   m_america=vector::Zeros(m_day_size_pt);
//--- create an object
   UpdateSizes();
//--- if it is the first tick at the day opening, the canvas sizes will be equal to zero - set 1 px for both coordinates
   m_height=m_height?m_height:1;
   m_width=m_width?m_width:1;
   if(m_canvas.CreateBitmap(m_name, m_time1, m_high, m_width, m_height, COLOR_FORMAT_ARGB_NORMALIZE))
      ObjectSetInteger(0, m_name, OBJPROP_BACK, true);
   else
     {
      Print("Error creating canvas: ", GetLastError());
      Print("time1=", m_time1, "  high=", m_high, "  width=", m_width, "  height=", m_height);
     }
  }
//+------------------------------------------------------------------+
//| Checks if CMarketProfile object is for the specified 'time' date |
//+------------------------------------------------------------------+
bool CMarketProfile::Check(string prefix, datetime time)
  {
   string calculated= prefix+"_MP_"+TimeToString(time, TIME_DATE);
   return (m_name==(calculated));
  };
//+------------------------------------------------------------------+
//| Sets High/Low and a set of current-timeframe bars                |
//+------------------------------------------------------------------+
void CMarketProfile::SetHiLoBars(double high, double low, MqlRates &bars[])
  {
//--- if the day's High changed, move the OBJ_BITMAP object linked by m_name
   if(high>m_high)
     {
      m_high=high;
      if(!ObjectSetDouble(0, m_name, OBJPROP_PRICE, m_high))
         PrintFormat("Failed to update canvas for %s, error %d", TimeToString(m_time1, TIME_DATE), GetLastError());
     }
   ArrayCopy(m_bars, bars);
   m_high=high;
   m_low=low;
//--- day range in points
   m_day_size_pt=(int)((m_high-m_low)/SymbolInfoDouble(Symbol(), SYMBOL_POINT));
//--- re-set the sizes of vectors for trading sessions
   m_asia=vector::Zeros(m_day_size_pt);
   m_europe=vector::Zeros(m_day_size_pt);
   m_america=vector::Zeros(m_day_size_pt);
  }
//+------------------------------------------------------------------+
//|  Sets drawing parameters                                         |
//+------------------------------------------------------------------+
void CMarketProfile::UpdateSizes(void)
  {
//--- convert time/price to x/y coordinates
   int x1, y1, x2, y2;
   ChartTimePriceToXY(0, 0, m_time1, m_high, x1, y1);
   ChartTimePriceToXY(0, 0, m_time2, m_low,  x2, y2);
//--- calculate window size
   m_height=y2-y1;
   m_width =x2-x1;
//--- calculate coefficients for converting boxes and counters into chart pixels
   m_vert_scale=double(m_height)/(m_day_size_pt);
   m_hor_scale =double(m_width*PeriodSeconds(PERIOD_CURRENT))/PeriodSeconds(PERIOD_D1);

   m_canvas.Resize(m_width, m_height);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
void CMarketProfile::~CMarketProfile(void)
  {
//--- delete all our graphical objects after use
   ObjectsDeleteAll(0, m_prefix, 0, OBJ_BITMAP);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//|  Checks that the profile is in the visible part of the chart     |
//+------------------------------------------------------------------+
bool CMarketProfile::isVisibleOnChart(void)
  {
   long last_bar=ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
   long first_bar=last_bar+-ChartGetInteger(0, CHART_VISIBLE_BARS);
   first_bar=first_bar>0?first_bar:0;
   datetime left =iTime(Symbol(), Period(), (int)last_bar);
   datetime right=iTime(Symbol(), Period(), (int)first_bar);
//--- return check result
   return((m_time1>= left && m_time1 <=right) || (m_time2>= left && m_time2 <=right));
  }
//+------------------------------------------------------------------+
//| Prepares profile arrays by sessions                              |
//+------------------------------------------------------------------+
bool CMarketProfile::CalculateSessions(void)
  {
   double point=SymbolInfoDouble(Symbol(), SYMBOL_POINT);
   if(ArraySize(m_bars)==0)
      return(false);
//---- iterate through all bars of the current day and mark the boxes they fall into
   int size=ArraySize(m_bars);
   for(int i=0; i<size; i++)
     {
      MqlDateTime bar_time;
      TimeToStruct(m_bars[i].time, bar_time);
      uint        hour     =bar_time.hour;
      int         start_box=(int)((m_bars[i].low-m_low)/point);
      int         stop_box =(int)((m_bars[i].high-m_low)/point);

      //--- American session
      if(hour>=InpAmericaStartHour)
        {
         for(int ind=start_box; ind<stop_box; ind++)
            m_america[ind]++;
        }
      else
        {
         //--- European session
         if(hour>=InpEuropeStartHour && hour<InpAmericaStartHour)
            for(int ind=start_box; ind<stop_box; ind++)
               m_europe[ind]++;
         else
            //--- Asian session
            for(int ind=start_box; ind<stop_box; ind++)
               m_asia[ind]++;
        }
     }
//--- session vectors are ready
   return(true);
  }
//+------------------------------------------------------------------+
//|  Draw Market Profile on the canvas                               |
//+------------------------------------------------------------------+
void CMarketProfile::Draw(double multiplier=1.0)
  {
//--- sum the sessions for drawing
   vector total_profile=m_asia+m_europe+m_america;   // profile including all sessions
   vector europe_asia=m_asia+m_europe;               // profile as the sum of the European and Asian sessions

//--- set a transparent background, any color
   m_canvas.Erase(ColorToARGB(clrBlack, 0));

//--- draw the American session with rectangles
   int x1=0; // to draw a rectangle, the left corner always starts at zero
   int y1, x2, y2;
   int size=(int)total_profile.Size();
   for(int i=0; i<size; i++)
     {
      //--- skip zero values, do not draw
      if(total_profile[i]==0)
         continue;
      //--- calculate the bottom point to draw the rectangle
      y1=m_height-int(i*m_vert_scale);                    // x1=0  always
      y2=(int)(y1+m_vert_scale);                          // top point of the rectangle
      x2=(int)(total_profile[i]*m_hor_scale*multiplier);  // right corner of the rectangle
      m_canvas.FillRectangle(x1, y1, x2, y2, ColorToARGB(InpAmericaSession, InpTransparency));
     }

//--- draw the European session with rectangles
   for(int i=0; i<size; i++)
     {
      //--- skip zero values, do not draw
      if(total_profile[i]==0)
         continue;
      //--- calculate 2 points to draw the rectangle
      y1=m_height-int(i*m_vert_scale);
      y2=(int)(y1+m_vert_scale);
      x2=(int)(europe_asia[i]*m_hor_scale*multiplier);
      m_canvas.FillRectangle(x1, y1, x2, y2, ColorToARGB(InpEuropeSession, InpTransparency));
     }

//--- draw the Asian session with rectangles
   for(int i=0; i<size; i++)
     {
      //--- skip zero values, do not draw
      if(total_profile[i]==0)
         continue;
      //--- calculate 2 points to draw the rectangle
      y1=m_height-int(i*m_vert_scale);
      y2=(int)(y1+m_vert_scale);
      x2=(int)(m_asia[i]*m_hor_scale*multiplier);
      m_canvas.FillRectangle(x1, y1, x2, y2, ColorToARGB(InpAsiaSession, InpTransparency));
     }
//--- update the OBJ_BITMAP object without refreshing the chart
   m_canvas.Update(false);
  }
//+------------------------------------------------------------------+
