
#property indicator_chart_window
extern string UniqueID                    = "BoxBreakout ";
extern bool   Platform_5_Digits           = false;
extern string TC_start                    = "22:00";
extern bool   Same_Day                    = false;
extern string TC_end                      = "06:00";
extern string TC_projection_end           = "15:00";
extern double TC_Breakout_Offset          = 0;
extern bool   TC_Breakout_box_solid       = false;
extern int    Past_Days                   = 15;
extern bool   TC_price                    = true;
extern color  TC_color                    = NavajoWhite;
extern int    TC_style                    = 0;
extern int    TC_width                    = 0;
extern bool   TC_solid                    = false;
extern color  TC_Prj_Obj_HI_clr           = RoyalBlue;
extern int    TC_Prj_Obj_HI_width         = 0;
extern int    TC_Prj_Obj_HI_style         = 2;
extern color  TC_Prj_Obj_LO_clr           = Crimson;
extern int    TC_Prj_Obj_LO_width         = 0;
extern int    TC_Prj_Obj_LO_style         = 2;
extern color  TC_price_clr                = NavajoWhite;
extern bool   BrokerHasSundayData         = false;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
 
int      d, i, dig, round, modifier, BarBegin, BarEnd;
int      iYear, iMonth, iDay, iHour, iMinute;
double   PriceHigh, PriceLow, bo, range1, range2;
string   TCObj_Hprice, TCObj_Lprice, TCObj_range, Hprice, Lprice, range3;
datetime TradeDate, TimeBegin, TimeEnd, TCobjprjend;
double buffH1[];
double buffH2[];
double buffL1[];
double buffL2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()
{
   IndicatorBuffers(4);
   SetIndexBuffer(0,buffH1); SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(1,buffL1);   
   SetIndexBuffer(2,buffH2);   
   SetIndexBuffer(3,buffL2);   
   dig = MarketInfo(Symbol(), MODE_DIGITS);
   modifier = 1;
      if(dig == 3 || dig == 5) modifier = 10;
   
   return(0);
}
  
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+

int deinit()
{
   string lookFor       = UniqueID;
   int    lookForLength = StringLen(lookFor);   
   for(i = ObjectsTotal() - 1; i >= 0; i--)
   {
      string name = ObjectName(i);
         if(StringSubstr(name, 0, lookForLength) == lookFor) ObjectDelete(name);
   }         
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int start()
   {   
      TradeDate = TimeCurrent();
      for (d = 0; d < Past_Days; d++)
      {       
         DrawTC(TradeDate, UniqueID + "_TC00 " + TimeToStr(TradeDate,TIME_DATE), TC_start, TC_end, TC_projection_end, 0, Same_Day);
         DrawTC(TradeDate, UniqueID + "_TC01 " + TimeToStr(TradeDate,TIME_DATE), TC_start, TC_end, TC_projection_end, 1, Same_Day);
         DrawTC(TradeDate, UniqueID + "_TC02 " + TimeToStr(TradeDate,TIME_DATE), TC_start, TC_end, TC_projection_end, 2, Same_Day);
         
         TradeDate = decrementTradeDateb(TradeDate);
         while (TimeDayOfWeek(TradeDate) > 5 || TimeDayOfWeek(TradeDate) < 1 ) TradeDate = decrementTradeDateb(TradeDate);       
      }
   }
//+-------------------------------------------------------------------------------------------+
//| DrawTC sub-routine to draw custom Time Channels                                           |
//+-------------------------------------------------------------------------------------------+

void DrawTC(datetime TradeDate, string TCObj, string TCstart, string TCend, string TCprjend, int ID, bool Same_Day)
{
                TimeBegin = StrToTime(TimeToStr(TradeDate, TIME_DATE) + " " + TCstart);
   if(Same_Day) TimeBegin = StrToTime(TimeToStr(TradeDate, TIME_DATE) + " " + TCstart) + 86400;
   TimeEnd      = StrToTime(TimeToStr(TradeDate, TIME_DATE) + " " + TCend)    + 86400;
   TCobjprjend  = StrToTime(TimeToStr(TradeDate, TIME_DATE) + " " + TCprjend) + 86400;

   //
   //
   //
   //
   //
      
   if(TimeDayOfWeek(TradeDate) == 5)
   {
      if (BrokerHasSundayData)
            int timeDiff = 2*PERIOD_D1*60;
      else      timeDiff = 3*PERIOD_D1*60;
      TimeBegin   = TimeBegin   + timeDiff;
      TimeEnd     = TimeEnd     + timeDiff;
      TCobjprjend = TCobjprjend + timeDiff;
   }
   
   
   BarBegin     = iBarShift(NULL, 0, TimeBegin) + 1;
   BarEnd       = iBarShift(NULL, 0, TimeEnd)   + 1;  
   
   PriceHigh    = High[Highest(NULL, 0, MODE_HIGH, (BarBegin - BarEnd), BarEnd)];
   PriceLow     = Low [Lowest (NULL, 0, MODE_LOW , (BarBegin - BarEnd), BarEnd)];
   bo           = TC_Breakout_Offset * (Point * modifier);
   range1       = PriceHigh - ((PriceHigh - PriceLow) / 2);
   range2       = (PriceHigh - PriceLow) / (Point * modifier);
   TCObj_Hprice = UniqueID + "_TC10 " + TimeToStr(TradeDate,TIME_DATE);
   TCObj_Lprice = UniqueID + "_TC11 " + TimeToStr(TradeDate,TIME_DATE);
   TCObj_range  = UniqueID + "_TC12 " + TimeToStr(TradeDate,TIME_DATE);
   Hprice       = DoubleToStr(PriceHigh, dig);
   Lprice       = DoubleToStr(PriceLow,  dig);
   round        = 0;
   if(Platform_5_Digits) round = 1;
   range3       = DoubleToStr(range2,  round);
   
   if(ID == 0)
   {  
      ObjectCreate(TCObj, OBJ_RECTANGLE,  0, 0, 0, 0, 0);
         ObjectSet(TCObj, OBJPROP_TIME1,  TimeBegin);
         ObjectSet(TCObj, OBJPROP_TIME2,  TimeEnd);
         ObjectSet(TCObj, OBJPROP_PRICE1, PriceHigh);  
         ObjectSet(TCObj, OBJPROP_PRICE2, PriceLow);
         ObjectSet(TCObj, OBJPROP_STYLE,  TC_style);
         ObjectSet(TCObj, OBJPROP_COLOR,  TC_color);
         ObjectSet(TCObj, OBJPROP_BACK,   TC_solid);
         ObjectSet(TCObj, OBJPROP_WIDTH,  TC_width);
      
   }
         int finish = iBarShift(NULL,0,TCobjprjend);
         for (int k=finish; k<BarBegin; k++)
         {
            if (k>=BarEnd)
            {
               buffH1[k] = PriceHigh;
               buffL1[k] = PriceLow;
               buffH2[k] = EMPTY_VALUE;
               buffL2[k] = EMPTY_VALUE;
            }
            if (k<BarEnd)
            {
               buffH2[k] = PriceHigh;
               buffL2[k] = PriceLow;
               buffH1[k] = EMPTY_VALUE;
               buffL1[k] = EMPTY_VALUE;
            }               
         }         
   if(TC_Breakout_Offset <= 0)
   {
      if(ID == 1)
      {
         ObjectCreate(TCObj, OBJ_TREND,      0, 0, 0, 0);
            ObjectSet(TCObj, OBJPROP_TIME1,  TimeEnd);
            ObjectSet(TCObj, OBJPROP_TIME2,  TCobjprjend);
            ObjectSet(TCObj, OBJPROP_PRICE1, PriceHigh);  
            ObjectSet(TCObj, OBJPROP_PRICE2, PriceHigh);
            ObjectSet(TCObj, OBJPROP_STYLE,  TC_Prj_Obj_HI_style);
            ObjectSet(TCObj, OBJPROP_COLOR,  TC_Prj_Obj_HI_clr);      
            ObjectSet(TCObj, OBJPROP_WIDTH,  TC_Prj_Obj_HI_width);
            ObjectSet(TCObj, OBJPROP_BACK,   false);
            ObjectSet(TCObj, OBJPROP_RAY,    false);
      }

      if(ID == 2)
      {
         ObjectCreate(TCObj, OBJ_TREND,      0, 0, 0, 0);
            ObjectSet(TCObj, OBJPROP_TIME1,  TimeEnd);
            ObjectSet(TCObj, OBJPROP_TIME2,  TCobjprjend);
            ObjectSet(TCObj, OBJPROP_PRICE1, PriceLow);  
            ObjectSet(TCObj, OBJPROP_PRICE2, PriceLow);
            ObjectSet(TCObj, OBJPROP_STYLE,  TC_Prj_Obj_LO_style);
            ObjectSet(TCObj, OBJPROP_COLOR,  TC_Prj_Obj_LO_clr);      
            ObjectSet(TCObj, OBJPROP_WIDTH,  TC_Prj_Obj_LO_width);
            ObjectSet(TCObj, OBJPROP_BACK,   false);
            ObjectSet(TCObj, OBJPROP_RAY,    false);
      }
   
      if(TC_price)
      {
         
         ObjectCreate  (TCObj_Hprice, OBJ_TEXT, 0, TimeBegin - 3600, PriceHigh);
         ObjectSet     (TCObj_Hprice, OBJPROP_BACK, false);
         ObjectSetText (TCObj_Hprice, Hprice, 9, "Verdana Italic", TC_price_clr);
         ObjectMove    (TCObj_Hprice, 0, TimeBegin - 3600, PriceHigh);
         
         ObjectCreate  (TCObj_Lprice, OBJ_TEXT, 0, TimeBegin - 3600, PriceLow);
         ObjectSet     (TCObj_Lprice, OBJPROP_BACK, false);
         ObjectSetText (TCObj_Lprice, Lprice, 9, "Verdana Italic", TC_price_clr);
         ObjectMove    (TCObj_Lprice, 0, TimeBegin - 3600, PriceLow);
         
         ObjectCreate  (TCObj_range, OBJ_TEXT, 0, TimeBegin - 3600, range1);
         ObjectSet     (TCObj_range, OBJPROP_BACK, false);
         ObjectSetText (TCObj_range, range3, 11, "Verdana Bold Italic", TC_price_clr);
         ObjectMove    (TCObj_range, 0, TimeBegin - 3600, range1);
      }
   }
   
   else
   {
      Hprice = DoubleToStr(PriceHigh + bo, dig);
      Lprice = DoubleToStr(PriceLow  - bo, dig);
      if(ID == 1)
      {
         ObjectCreate(TCObj, OBJ_RECTANGLE,  0, 0, 0, 0, 0);
            ObjectSet(TCObj, OBJPROP_TIME1,  TimeEnd);
            ObjectSet(TCObj, OBJPROP_TIME2,  TCobjprjend);
            ObjectSet(TCObj, OBJPROP_PRICE1, PriceHigh);  
            ObjectSet(TCObj, OBJPROP_PRICE2, PriceHigh + bo);
            ObjectSet(TCObj, OBJPROP_COLOR,  TC_Prj_Obj_HI_clr);
            ObjectSet(TCObj, OBJPROP_BACK,   TC_Breakout_box_solid);
      }

      if(ID == 2)
      {
         ObjectCreate(TCObj, OBJ_RECTANGLE,  0, 0, 0, 0, 0);
            ObjectSet(TCObj, OBJPROP_TIME1,  TimeEnd);
            ObjectSet(TCObj, OBJPROP_TIME2,  TCobjprjend);
            ObjectSet(TCObj, OBJPROP_PRICE1, PriceLow);  
            ObjectSet(TCObj, OBJPROP_PRICE2, PriceLow - bo);
            ObjectSet(TCObj, OBJPROP_COLOR,  TC_Prj_Obj_LO_clr);
            ObjectSet(TCObj, OBJPROP_BACK,   TC_Breakout_box_solid);
      }
   
      if(TC_price)
      {
         
         ObjectCreate  (TCObj_Hprice, OBJ_TEXT, 0, TimeEnd - 3600, PriceHigh + 1.5 * bo);
         ObjectSet     (TCObj_Hprice, OBJPROP_BACK, false);
         ObjectSetText (TCObj_Hprice, Hprice, 9, "Verdana Italic", TC_Prj_Obj_HI_clr);
         ObjectMove    (TCObj_Hprice, 0, TimeEnd - 3600, PriceHigh + 1.5 * bo);
         
         ObjectCreate  (TCObj_Lprice, OBJ_TEXT, 0, TimeEnd - 3600, PriceLow - bo);
         ObjectSet     (TCObj_Lprice, OBJPROP_BACK, false);
         ObjectSetText (TCObj_Lprice, Lprice, 9, "Verdana Italic", TC_Prj_Obj_LO_clr);
         ObjectMove    (TCObj_Lprice, 0, TimeEnd - 3600, PriceLow - bo);
         
         ObjectCreate  (TCObj_range, OBJ_TEXT, 0, TimeBegin - 3600, range1);
         ObjectSet     (TCObj_range, OBJPROP_BACK, false);
         ObjectSetText (TCObj_range, range3, 11, "Verdana Bold Italic", TC_price_clr);
         ObjectMove    (TCObj_range, 0, TimeBegin - 3600, range1);
      }
   }
}


datetime decrementTradeDateb(datetime TimeDate)
{
   return(TimeDate-PERIOD_D1*60);
}