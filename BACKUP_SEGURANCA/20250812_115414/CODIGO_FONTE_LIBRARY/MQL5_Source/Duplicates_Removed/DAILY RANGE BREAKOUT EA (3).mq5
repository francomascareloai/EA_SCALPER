//+------------------------------------------------------------------+
//|                                      DAILY RANGE BREAKOUT EA.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

double maximum_price = -DBL_MAX;
double minimum_price = +DBL_MAX;
datetime maximum_time, minimum_time;

bool isHaveDailyRange_Prices = false;
bool isHaveDailyRange_Break = false;

#define RECTANGLE_PREFIX "RANGE RECTANGLE "
#define UPPER_LINE_PREFIX "UPPER LINE"
#define LOWER_LINE_PREFIX "LOWER LINE"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
//---
   
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
//---
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
//---
   
   static datetime midnight = iTime(_Symbol,PERIOD_D1,0);
   static datetime sixAM = midnight + 6 * 3600;
   static datetime scanBarTime = sixAM + 1 * PeriodSeconds(_Period); // next bar
   
   static datetime validBreakTime_start = scanBarTime;
   static datetime validBreakTime_end = midnight + (6+5) * 3600; // 11 AM
   
   //Print("END TIME = ",validBreakTime_end);
   
   //Print("Midnight T = ",midnight,", 6 AM = ",sixAM,", SCAN BAT T = ",scanBarTime);
   
   if (isNewDay()){
      
      midnight = iTime(_Symbol,PERIOD_D1,0);
      sixAM = midnight + 6 * 3600;
      scanBarTime = sixAM + 1 * PeriodSeconds(_Period); // next bar
      
      validBreakTime_start = scanBarTime;
      validBreakTime_end = midnight + (6+5) * 3600; // 11 AM
      
      maximum_price = -DBL_MAX;
      minimum_price = +DBL_MAX;
      
      isHaveDailyRange_Prices = false;
      isHaveDailyRange_Break = false;
   }
   
   if (isNewBar()){
      datetime currentBarTime = iTime(_Symbol,_Period,0);
      
      if (currentBarTime == scanBarTime && !isHaveDailyRange_Prices){
         Print("WE HAVE ENOUGH BARS DATA FOR DOCUMENTATION. MAKE THE DATA EXTRACTION NOW");
         int total_bars = int((sixAM - midnight)/PeriodSeconds(_Period))+1;
         Print("Total bars for scan = ",total_bars);
         int highest_price_bar_index = -1;
         int lowest_price_bar_index = -1;
         
         for (int i=1; i<=total_bars; i++){
            double open_i = open(i);
            double close_i = close(i);
            
            double highest_price_i = (open_i > close_i) ? open_i : close_i;
            double lowest_price_i = (open_i < close_i) ? open_i : close_i;
            
            if (highest_price_i > maximum_price){
               maximum_price = highest_price_i;
               highest_price_bar_index = i;
               maximum_time = time(i);
            }
            if (lowest_price_i < minimum_price){
               minimum_price = lowest_price_i;
               lowest_price_bar_index = i;
               minimum_time = time(i);
            }
         }
         Print("Maximum Price = ",maximum_price,", Bar Index = ",highest_price_bar_index,", Time = ",maximum_time);
         Print("Minimum Price = ",minimum_price,", Bar Index = ",lowest_price_bar_index,", Time = ",minimum_time);
         
         create_Rectangle(RECTANGLE_PREFIX+TimeToString(maximum_time),maximum_time,maximum_price,minimum_time,minimum_price,clrBlue);
         create_Line(UPPER_LINE_PREFIX+TimeToString(midnight),midnight,maximum_price,sixAM,maximum_price,3,clrBlack,DoubleToString(maximum_price,_Digits));
         create_Line(LOWER_LINE_PREFIX+TimeToString(midnight),midnight,minimum_price,sixAM,minimum_price,3,clrRed,DoubleToString(minimum_price,_Digits));
         
         isHaveDailyRange_Prices = true;
      }
   }
   
   double barClose = close(1);
   datetime barTime = time(1);
   
   if (barClose > maximum_price && isHaveDailyRange_Prices && !isHaveDailyRange_Break
       && barTime >= validBreakTime_start && barTime <= validBreakTime_end
   ){
      Print("CLOSE Price broke the HIGH range. ",barClose," > ",maximum_price);
      isHaveDailyRange_Break = true;
      drawBreakPoint(TimeToString(barTime),barTime,barClose,234,clrBlack,-1);
   }
   else if (barClose < minimum_price && isHaveDailyRange_Prices && !isHaveDailyRange_Break
       && barTime >= validBreakTime_start && barTime <= validBreakTime_end
   ){
      Print("CLOSE Price broke the LOW range. ",barClose," < ",minimum_price);
      isHaveDailyRange_Break = true;
      drawBreakPoint(TimeToString(barTime),barTime,barClose,233,clrBlue,+1);
   }
   
   
}
//+------------------------------------------------------------------+

double open(int index){return (iOpen(_Symbol,_Period,index));}
double high(int index){return (iHigh(_Symbol,_Period,index));}
double low(int index){return (iLow(_Symbol,_Period,index));}
double close(int index){return (iClose(_Symbol,_Period,index));}
datetime time(int index){return (iTime(_Symbol,_Period,index));}




bool isNewBar(){
   static int prevbars = 0;
   int currbars = iBars(_Symbol,_Period);
   if (prevbars == currbars) return (false);
   prevbars = currbars;
   return (true);
}

void create_Rectangle(string objName,datetime time1,double price1,
                      datetime time2,double price2,color clr){
   if (ObjectFind(0,objName) < 0){
      ObjectCreate(0,objName,OBJ_RECTANGLE,0,time1,price1,time2,price2);
      
      ObjectSetInteger(0,objName,OBJPROP_TIME,0,time1);
      ObjectSetDouble(0,objName,OBJPROP_PRICE,0,price1);
      ObjectSetInteger(0,objName,OBJPROP_TIME,1,time2);
      ObjectSetDouble(0,objName,OBJPROP_PRICE,1,price2);
      
      ObjectSetInteger(0,objName,OBJPROP_FILL,true);
      ObjectSetInteger(0,objName,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,objName,OBJPROP_BACK,false);
      
      ChartRedraw(0);
   }
}

bool isNewDay(){
   bool newDay = false;
   
   MqlDateTime str_datetime;
   TimeToStruct(TimeCurrent(), str_datetime);
   
   static int prevday = 0;
   int currday = str_datetime.day;
   
   if (prevday == currday){// we are still in current day
      newDay = false;
   }
   else if (prevday != currday){// we have a new day
      Print("WE HAVE A NEW DAY WITH DATE ",currday);
      prevday = currday;
      newDay = true;
   }
   return (newDay);
}

void create_Line(string objName,datetime time1,double price1,
                      datetime time2,double price2,int width,color clr,string text){
   if (ObjectFind(0,objName) < 0){
      ObjectCreate(0,objName,OBJ_TREND,0,time1,price1,time2,price2);
      
      ObjectSetInteger(0,objName,OBJPROP_TIME,0,time1);
      ObjectSetDouble(0,objName,OBJPROP_PRICE,0,price1);
      ObjectSetInteger(0,objName,OBJPROP_TIME,1,time2);
      ObjectSetDouble(0,objName,OBJPROP_PRICE,1,price2);
      
      ObjectSetInteger(0,objName,OBJPROP_WIDTH,width);
      ObjectSetInteger(0,objName,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,objName,OBJPROP_BACK,false);
      
      long scale = 0;
      if (!ChartGetInteger(0,CHART_SCALE,0,scale)){
         Print("UNABLE TO GET THE CHART SCALE. DEFAULT VALUE OF ",scale," IS CONSIDERED.");
      }
      
      int fontsize = 11;
      // 0=minimized, 5 = maximized
      if (scale==0){fontsize=5;}
      else if (scale==1){fontsize=6;}
      else if (scale==2){fontsize=7;}
      else if (scale==3){fontsize=9;}
      else if (scale==4){fontsize=11;}
      else if (scale==5){fontsize=13;}

      string txt = " Right Price";
      string objNameDescr = objName + txt;
      ObjectCreate(0,objNameDescr,OBJ_TEXT,0,time2,price2);
      ObjectSetInteger(0,objNameDescr,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,objNameDescr,OBJPROP_FONTSIZE,fontsize);
      ObjectSetInteger(0,objNameDescr,OBJPROP_ANCHOR,ANCHOR_LEFT);
      ObjectSetString(0,objNameDescr,OBJPROP_TEXT, " " + text);
      ObjectSetString(0,objNameDescr,OBJPROP_FONT,"Calibri");
      
      ChartRedraw(0);
   }
}

void drawBreakPoint(string objName,datetime time,double price,int arrCode,
   color clr,int direction){
   
   if (ObjectFind(0,objName) < 0){
      ObjectCreate(0,objName,OBJ_ARROW,0,time,price);
      ObjectSetInteger(0,objName,OBJPROP_ARROWCODE,arrCode);
      ObjectSetInteger(0,objName,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,12);
      if (direction > 0) ObjectSetInteger(0,objName,OBJPROP_ANCHOR,ANCHOR_TOP);
      if (direction < 0) ObjectSetInteger(0,objName,OBJPROP_ANCHOR,ANCHOR_BOTTOM);
      
      string txt = " Breakout";
      string objNameDescr = objName + txt;
      ObjectCreate(0,objNameDescr,OBJ_TEXT,0,time,price);
      ObjectSetInteger(0,objNameDescr,OBJPROP_COLOR,clr);
      ObjectSetInteger(0,objNameDescr,OBJPROP_FONTSIZE,12);
      if (direction > 0) {
         ObjectSetInteger(0,objNameDescr,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
         ObjectSetString(0,objNameDescr,OBJPROP_TEXT, " " + txt);
      }
      if (direction < 0) {
         ObjectSetInteger(0,objNameDescr,OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
         ObjectSetString(0,objNameDescr,OBJPROP_TEXT, " " + txt);
      }
   }
   ChartRedraw(0);
}
