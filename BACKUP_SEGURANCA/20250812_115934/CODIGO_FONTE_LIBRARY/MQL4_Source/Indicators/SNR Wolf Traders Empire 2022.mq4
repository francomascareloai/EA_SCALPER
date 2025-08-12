//+------------------------------------------------------------------+
//|                      Indicator: SNR Wolf Traders Empire 2022.mq4 |
//|                                       Created with EABuilder.com |
//|                                        https://www.eabuilder.com |
//+------------------------------------------------------------------+
#property copyright "Created with EABuilder.com"
#property link      "https://www.eabuilder.com"
#property version   "1.00"
#property description "THIS INDICATORS IS SIMILAR FOR "
#property description "TECHNICAL TRADER AND SMC TRADERS create by"
#property description "CONSCIOUS WOLF BOY"
#property description ""
#property description "JOIN THEIR TELEGRAM"
#property description "t.me/WolfTradersEmpire"

#include <stdlib.mqh>
#include <stderror.mqh>

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 1

#property indicator_type1 DRAW_ARROW
#property indicator_width1 1
#property indicator_color1 0xFFAA00
#property indicator_label1 "Buy"

//--- indicator buffers
double Buffer1[];

double myPoint; //initialized in OnInit

//--- Custom functions ----------------------------------------------- 

double ExampleFunction()
{
   return(High[1] - Low[1]);
}
SystemOutPrint("WOLF RUNNER STRATEGY LITTLE SISTER by Conscious Wolf Boy");

//--- End of custom functions ----------------------------------------

void myAlert(string type, string message)
  {
   if(type == "print")
      Print(message);
   else if(type == "error")
     {
      Print(type+" | SNR Wolf Traders Empire 2022 @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
   else if(type == "order")
     {
     }
   else if(type == "modify")
     {
     }
  }

double TrendlinePriceUpper(int shift) //returns current price on the highest horizontal line or trendline found in the chart
  {
   int obj_total = ObjectsTotal();
   double maxprice = -1;
   for(int i = obj_total - 1; i >= 0; i--)
     {
      string name = ObjectName(i);
      double price;
      if(ObjectType(name) == OBJ_HLINE && StringFind(name, "#", 0) < 0
      && (price = ObjectGet(name, OBJPROP_PRICE1)) > maxprice
      && price > 0)
         maxprice = price;
      else if(ObjectType(name) == OBJ_TREND && StringFind(name, "#", 0) < 0
      && (price = ObjectGetValueByShift(name, shift)) > maxprice
      && price > 0)
         maxprice = price;
     }
   return(maxprice); //not found => -1
  }

double TrendlinePriceLower(int shift) //returns current price on the lowest horizontal line or trendline found in the chart
  {
   int obj_total = ObjectsTotal();
   double minprice = MathPow(10, 308);
   for(int i = obj_total - 1; i >= 0; i--)
     {
      string name = ObjectName(i);
      double price;
      if(ObjectType(name) == OBJ_HLINE && StringFind(name, "#", 0) < 0
      && (price = ObjectGet(name, OBJPROP_PRICE1)) < minprice
      && price > 0)
         minprice = price;
      else if(ObjectType(name) == OBJ_TREND && StringFind(name, "#", 0) < 0
      && (price = ObjectGetValueByShift(name, shift)) < minprice
      && price > 0)
         minprice = price;
     }
   if (minprice > MathPow(10, 307))
      minprice = -1; //not found => -1
   return(minprice);
  }

void DrawLine(string objname, double price, int count, int start_index) //creates or modifies existing object if necessary
  {
   if((price < 0) && ObjectFind(objname) >= 0)
     {
      ObjectDelete(objname);
     }
   else if(ObjectFind(objname) >= 0 && ObjectType(objname) == OBJ_TREND)
     {
      ObjectSet(objname, OBJPROP_TIME1, Time[start_index]);
      ObjectSet(objname, OBJPROP_PRICE1, price);
      ObjectSet(objname, OBJPROP_TIME2, Time[start_index+count-1]);
      ObjectSet(objname, OBJPROP_PRICE2, price);
     }
   else
     {
      ObjectCreate(objname, OBJ_TREND, 0, Time[start_index], price, Time[start_index+count-1], price);
      ObjectSet(objname, OBJPROP_RAY, false);
      ObjectSet(objname, OBJPROP_COLOR, C'0x00,0x00,0xFF');
      ObjectSet(objname, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(objname, OBJPROP_WIDTH, 2);
     }
  }

double Support(int time_interval, bool fixed_tod, int hh, int mm, bool draw, int shift)
  {
   int start_index = shift;
   int count = time_interval / 60 / Period();
   if(fixed_tod)
     {
      datetime start_time;
      if(shift == 0)
	     start_time = TimeCurrent();
      else
         start_time = Time[shift-1];
      datetime dt = StringToTime(StringConcatenate(TimeToString(start_time, TIME_DATE)," ",hh,":",mm)); //closest time hh:mm
      if (dt > start_time)
         dt -= 86400; //go 24 hours back
      int dt_index = iBarShift(NULL, 0, dt, true);
      datetime dt2 = dt;
      while(dt_index < 0 && dt > Time[Bars-1-count]) //bar not found => look a few days back
        {
         dt -= 86400; //go 24 hours back
         dt_index = iBarShift(NULL, 0, dt, true);
        }
      if (dt_index < 0) //still not found => find nearest bar
         dt_index = iBarShift(NULL, 0, dt2, false);
      start_index = dt_index + 1; //bar after S/R opens at dt
     }
   double ret = Low[iLowest(NULL, 0, MODE_LOW, count, start_index)];
   if (draw) DrawLine("Support", ret, count, start_index);
   return(ret);
  }

double Resistance(int time_interval, bool fixed_tod, int hh, int mm, bool draw, int shift)
  {
   int start_index = shift;
   int count = time_interval / 60 / Period();
   if(fixed_tod)
     {
      datetime start_time;
      if(shift == 0)
	     start_time = TimeCurrent();
      else
         start_time = Time[shift-1];
      datetime dt = StringToTime(StringConcatenate(TimeToString(start_time, TIME_DATE)," ",hh,":",mm)); //closest time hh:mm
      if (dt > start_time)
         dt -= 86400; //go 24 hours back
      int dt_index = iBarShift(NULL, 0, dt, true);
      datetime dt2 = dt;
      while(dt_index < 0 && dt > Time[Bars-1-count]) //bar not found => look a few days back
        {
         dt -= 86400; //go 24 hours back
         dt_index = iBarShift(NULL, 0, dt, true);
        }
      if (dt_index < 0) //still not found => find nearest bar
         dt_index = iBarShift(NULL, 0, dt2, false);
      start_index = dt_index + 1; //bar after S/R opens at dt
     }
   double ret = High[iHighest(NULL, 0, MODE_HIGH, count, start_index)];
   if (draw) DrawLine("Resistance", ret, count, start_index);
   return(ret);
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {   
   IndicatorBuffers(1);
   SetIndexBuffer(0, Buffer1);
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexArrow(0, 241);
   //initialize myPoint
   myPoint = Point();
   if(Digits() == 5 || Digits() == 3)
     {
      myPoint *= 10;
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   int limit = rates_total - prev_calculated;
   //--- counting from 0 to rates_total
   ArraySetAsSeries(Buffer1, true);
   //--- initial zero
   if(prev_calculated < 1)
     {
      ArrayInitialize(Buffer1, EMPTY_VALUE);
     }
   else
      limit++;
   
   if(TrendlinePriceUpper(0) < 0 && TrendlinePriceLower(0) < 0) return(rates_total);
   //--- main loop
   for(int i = limit-1; i >= 0; i--)
     {
      if (i >= MathMin(5000-1, rates_total-1-50)) continue; //omit some old rates to prevent "Array out of range" or slow calculation   
      
      int barshift_H4 = iBarShift(Symbol(), PERIOD_H4, Time[i]);
      if(barshift_H4 < 0) continue;
      
      //Indicator Buffer 1
      if(iBands(NULL, PERIOD_H4, 200, 2, 0, PRICE_CLOSE, MODE_LOWER, barshift_H4) == Resistance(4 * 3600, false, 00, 00, true, i) //Bollinger Bands is equal to Resistance
      && iBands(NULL, PERIOD_H4, 200, 2, 0, PRICE_CLOSE, MODE_LOWER, barshift_H4) == Support(4 * 3600, false, 00, 00, true, i) //Bollinger Bands is equal to Support
      && iSAR(NULL, PERIOD_H4, 0.005, 0.005, barshift_H4) == TrendlinePriceUpper(i) //Parabolic SAR is equal to Upper Trendline
      && iSAR(NULL, PERIOD_H4, 0.005, 0.005, barshift_H4) == TrendlinePriceLower(i) //Parabolic SAR is equal to Lower Trendline
      )
        {
         Buffer1[i] = Low[i]; //Set indicator value at Candlestick Low
        }
      else
        {
         Buffer1[i] = EMPTY_VALUE;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+