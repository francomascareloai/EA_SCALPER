//+------------------------------------------------------------------+
//|                                               BreakOut_BOX_5.mq4 |
//|                                                        hapalkos  |
//|                                                       2007.02.16 |
//|      Code based on TIME1_modified.mq4 shown below                |
//|         posted to Forex Factory by glenn5t                       |
//|      Concept of the break-out box form by Markj                  |
//|                                                                  |
//|   ++ modified so that rectangles do not overlay                  |
//|   ++ this makes color selection more versatile                   |
//|  +++ code consolidated to facilitate changes                     |
//|  +++ changed Period B rectangle and added offset value           |
//|  +++ corrected error in bar selection code                       |
//| ++++ added ability to cross 00:00(nextDayA, nextDayB)            |
//| ++++ added Unique ID to allow for multiple indicators            |
//| ++++ added ability to delete rectangles specific to an indicator |
//|+++++ added Open/Close boxes and lines per Accrete                |
//|+++++ added Alerts - can be used with Tesla's Alerter EA          |
//+------------------------------------------------------------------+
#property copyright "hapalkos"
#property link      ""

#property indicator_chart_window               // Configuration for Asian Session

extern string UniqueID        = "Asian Session";  // --- Server Time --- GMT+2 ---
extern int    NumberOfDays    = 50;        
extern string periodA_begin   = "05:00";     // Day0  Sydney Open
extern string periodA_end     = "09:00";     // Day0  Frankfurt Open
extern int    nextDayA        = 0;           // Set to zero if periodA_begin and periodA_end are on the same day.
                                             // Set to one if periodA_end is on the next day.
extern string periodB_end     = "15:00";     // Day0  New York Open
extern int    nextDayB        = 0;           // Set to zero if periodA_begin and periodB_end are on the same day.
                                             // Set to one if periodB_end is on the next day.
extern color  rectAB_color1      = PowderBlue; 
extern color  rectAB_color2      = LightCoral;  // second rectangle color to indicate relative position of Open/Close
extern bool   rectAB_background  = true;        // true - filled solid; false - outline
extern color  rectA_color        = Crimson;
extern bool   rectA_background   = false;       // true - filled solid; false - outline
extern color  rectB1_color       = Orange;
extern bool   rectB1_background  = false;       // true - filled solid; false - outline
extern int    rectB1_band        = 0;           // Box Break-Out Band for the Period B rectangle
extern color  rectsB2_color      = SkyBlue;
extern bool   rectsB2_background = true;        // true - filled solid, false - outline
extern int    rectsB2_band       = 5;           // Box Break-Out Band for the two upper and lower rectangles
extern bool   OpenClose          = false;        // false - High/Low boxes;  true - Open/Close boxes
extern bool   rectA_close_begin  = true;        // false - period A close indication line begins at end of period A;  true - period A close line is drawn from beginning of period A
extern bool   periodB_ALERTS     = false;       // Alerts are set on the upper and lower sides of the upper and lower rectangles - rectsB2
                                                // rectsB2_band determines the location of the Alerts
                                                // Alert_xx added to the decription so that Alerts can be activated by Tesla's Alerter EA

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init() {
  DeleteObjects();
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void deinit() {
  DeleteObjects();
return(0);
}

//+------------------------------------------------------------------+
//| Remove all indicator Rectangles                                  |
//+------------------------------------------------------------------+
void DeleteObjects() {
      datetime dtTradeDate=TimeCurrent();
      
      if(OpenClose) string sRectABname = " BoxOC  ";
         else sRectABname = " BoxHL  ";

  for (int i=0; i<NumberOfDays; i++) {
  
    ObjectDelete(UniqueID + sRectABname + TimeToStr(dtTradeDate,TIME_DATE));
    ObjectDelete(UniqueID + " BoxOpen  " + TimeToStr(dtTradeDate,TIME_DATE));
    ObjectDelete(UniqueID + " BoxClose  " + TimeToStr(dtTradeDate,TIME_DATE));    
    ObjectDelete(UniqueID + " BoxBO_High  " + TimeToStr(dtTradeDate,TIME_DATE));
    ObjectDelete(UniqueID + " BoxBO_HIGH ALERT " + TimeToStr(dtTradeDate,TIME_DATE));
    ObjectDelete(UniqueID + " BoxBO_Low  " + TimeToStr(dtTradeDate,TIME_DATE));
    ObjectDelete(UniqueID + " BoxBO_LOW ALERT  " + TimeToStr(dtTradeDate,TIME_DATE));    
    ObjectDelete(UniqueID + " BoxPeriodA  " + TimeToStr(dtTradeDate,TIME_DATE));
    ObjectDelete(UniqueID + " BoxPeriodB  " + TimeToStr(dtTradeDate,TIME_DATE));
    ObjectsDeleteAll(0,OBJ_TEXT);
    
    dtTradeDate=decrementTradeDate(dtTradeDate);
    while (TimeDayOfWeek(dtTradeDate) > 5 || TimeDayOfWeek(dtTradeDate) < 1 ) dtTradeDate = decrementTradeDate(dtTradeDate);     // Removed Sundays from plots
    }     
 return(0); 
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void start() {
  datetime dtTradeDate=TimeCurrent();
  
        if(OpenClose) string sRectABname = " BoxOC  ";
         else sRectABname = " BoxHL  ";

  for (int i=0; i<NumberOfDays; i++) {
  
    DrawObjects(dtTradeDate, UniqueID + sRectABname+ TimeToStr(dtTradeDate,TIME_DATE), periodA_begin, periodA_end, periodB_end, rectAB_color1,rectAB_color2, 0, 1, rectAB_background,nextDayA,nextDayB,OpenClose,false);
    DrawObjects(dtTradeDate, UniqueID + " BoxOpen  " + TimeToStr(dtTradeDate,TIME_DATE), periodA_begin, periodA_end, periodB_end, rectAB_color1,rectAB_color2, 0, 6, false,nextDayA,nextDayB,OpenClose, true);
    DrawObjects(dtTradeDate, UniqueID + " BoxClose  " + TimeToStr(dtTradeDate,TIME_DATE), periodA_begin, periodA_end, periodB_end, rectAB_color1,rectAB_color2,  0, 7, false,nextDayA,nextDayB,OpenClose,false);
    DrawObjects(dtTradeDate, UniqueID + " BoxBO_High  " + TimeToStr(dtTradeDate,TIME_DATE), periodA_begin, periodA_end, periodB_end, rectsB2_color,rectAB_color2,  rectsB2_band,2,rectsB2_background,nextDayA,nextDayB,OpenClose,false);
    if(periodB_ALERTS) DrawObjects(dtTradeDate, UniqueID + " BoxBO_HIGH ALERT " + TimeToStr(dtTradeDate,TIME_DATE), periodA_begin, periodA_end, periodB_end, rectsB2_color,rectAB_color2,  rectsB2_band,8,false,nextDayA,nextDayB,OpenClose,false);
    DrawObjects(dtTradeDate, UniqueID + " BoxBO_Low  " + TimeToStr(dtTradeDate,TIME_DATE), periodA_begin, periodA_end, periodB_end, rectsB2_color,rectAB_color2,  rectsB2_band,3,rectsB2_background,nextDayA,nextDayB,OpenClose,false);
    if(periodB_ALERTS) DrawObjects(dtTradeDate, UniqueID + " BoxBO_LOW ALERT  " + TimeToStr(dtTradeDate,TIME_DATE), periodA_begin, periodA_end, periodB_end, rectsB2_color,rectAB_color2,  rectsB2_band,9,false,nextDayA,nextDayB,OpenClose,false);
    DrawObjects(dtTradeDate, UniqueID + " BoxPeriodA  " + TimeToStr(dtTradeDate,TIME_DATE), periodA_begin, periodA_end, periodA_end, rectA_color,rectAB_color2,  0,4, rectA_background,nextDayA,nextDayB,OpenClose,false);
    DrawObjects(dtTradeDate, UniqueID + " BoxPeriodB  " + TimeToStr(dtTradeDate,TIME_DATE), periodA_begin, periodA_end, periodB_end, rectB1_color,rectAB_color2,  rectB1_band,5, rectB1_background,nextDayA,nextDayB,OpenClose, false);
    
    dtTradeDate=decrementTradeDate(dtTradeDate);
    while (TimeDayOfWeek(dtTradeDate) > 5 || TimeDayOfWeek(dtTradeDate) < 1 ) dtTradeDate = decrementTradeDate(dtTradeDate);     // Removed Sundays from plots
  }
}

//+------------------------------------------------------------------+
//| Create Objects - Rectangles and Trend lines                      |
//+------------------------------------------------------------------+

void DrawObjects(datetime dtTradeDate, string sObjName, string sTimeBegin, string sTimeEnd, string sTimeObjEnd, color cObjColor1, color cObjColor2, int iOffSet, int iForm, bool background, int nextDayA, int nextDayB, bool OpenClose, bool rectA_close_begin) {
  datetime dtTimeBegin, dtTimeEnd, dtTimeObjEnd;
  double   dPriceHigh,  dPriceLow, dPriceOpen, dPriceClose;
  int      iBarBegin,   iBarEnd;
  string   sObjDesc;

  dtTimeBegin = StrToTime(TimeToStr(dtTradeDate, TIME_DATE) + " " + sTimeBegin);
  dtTimeEnd = StrToTime(TimeToStr(dtTradeDate, TIME_DATE) + " " + sTimeEnd);
  dtTimeObjEnd = StrToTime(TimeToStr(dtTradeDate, TIME_DATE) + " " + sTimeObjEnd);
  
  if(nextDayA == 1) dtTimeEnd = dtTimeEnd + 86400;
  if(nextDayB == 1) dtTimeObjEnd = dtTimeObjEnd + 86400;
  if(nextDayA == 1 && TimeDayOfWeek(dtTradeDate) == 5) dtTimeEnd = dtTimeEnd + (2 * 86400);
  if(nextDayB == 1 && TimeDayOfWeek(dtTradeDate) == 5) dtTimeObjEnd = dtTimeObjEnd + (2 * 86400);
      
  iBarBegin = iBarShift(NULL, 0, dtTimeBegin)+1;                                    // added 1 to bar count to correct calculation for highest price for the period
  iBarEnd = iBarShift(NULL, 0, dtTimeEnd)+1;                                        // added 1 to bar count to correct calculation for lowest price for the period 
  
   dPriceHigh  = High[Highest(NULL, 0, MODE_HIGH, (iBarBegin)-iBarEnd, iBarEnd)];
   dPriceLow   = Low [Lowest (NULL, 0, MODE_LOW , (iBarBegin)-iBarEnd, iBarEnd)];
   dPriceOpen  = Open[iBarBegin-1];                                                 // Open/Close added to enable Open/Close rectangles
   dPriceClose = Close[iBarEnd];
   
      if(OpenClose){                                                                // Selection of extremes of Open/Close values
         dPriceHigh = MathMax(dPriceOpen, dPriceClose);
         dPriceLow  = MathMin(dPriceOpen, dPriceClose); 
         }
  
//---- High-Low Rectangle - Period A and B combined
   if(iForm==1){  
      ObjectCreate(sObjName, OBJ_RECTANGLE, 0, 0, 0, 0, 0);
      ObjectSet(sObjName, OBJPROP_TIME1 , dtTimeBegin);
      ObjectSet(sObjName, OBJPROP_TIME2 , dtTimeObjEnd);
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceHigh);  
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceLow);
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_SOLID);
      if(dPriceClose<dPriceOpen && OpenClose==true) cObjColor1 = cObjColor2;        // Color change of rectangle dependent on Open/Close positions
      ObjectSet(sObjName, OBJPROP_COLOR, cObjColor1);
      ObjectSet(sObjName, OBJPROP_BACK, background);
   }
   
//---- Upper Rectangle  - Period B
  if(iForm==2){
      ObjectCreate(sObjName, OBJ_RECTANGLE, 0, 0, 0, 0, 0);
      ObjectSet(sObjName, OBJPROP_TIME1 , dtTimeEnd);
      ObjectSet(sObjName, OBJPROP_TIME2 , dtTimeObjEnd);
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceHigh);
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceHigh + iOffSet*Point);
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(sObjName, OBJPROP_COLOR, cObjColor1);
      ObjectSet(sObjName, OBJPROP_BACK, background);

if(iOffSet>0){                                                                                                 // SCREEN TEXT       
string  sObjName_text_up = StringConcatenate(sObjName, "_text");        // SCREEN TEXT                         // SCREEN TEXT
      {                                                                                                        // SCREEN TEXT
      ObjectCreate(sObjName_text_up, OBJ_TEXT, 0,dtTimeEnd-420, dPriceHigh + iOffSet*Point+2*Point);           // SCREEN TEXT
      string      sObjNameOBprice_up = DoubleToStr(dPriceHigh + iOffSet*Point,4);                              // SCREEN TEXT
      ObjectSetText(sObjName_text_up,sObjNameOBprice_up, 8, "Arial", Black);     //dPriceHigh + iOffSet*Point, // SCREEN TEXT
      ObjectMove(sObjName_text_up, 0, dtTimeEnd-420, dPriceHigh + iOffSet*Point+2*Point);                      // SCREEN TEXT
      }                                                                                                        // SCREEN TEXT 
   }
   }
 
 //---- Lower Rectangle - Period B
  if(iForm==3){
      ObjectCreate(sObjName, OBJ_RECTANGLE, 0, 0, 0, 0, 0);
      ObjectSet(sObjName, OBJPROP_TIME1 , dtTimeEnd);
      ObjectSet(sObjName, OBJPROP_TIME2 , dtTimeObjEnd);
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceLow - iOffSet*Point);
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceLow);
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(sObjName, OBJPROP_COLOR, cObjColor1);
      ObjectSet(sObjName, OBJPROP_BACK, background);

if(iOffSet>0){                                                                                                    // SCREEN TEXT         
      string  sObjName_text_down = StringConcatenate(sObjName, "_text");    // SCREEN TEXT                        // SCREEN TEXT 
      {                                                                                                           // SCREEN TEXT 
      ObjectCreate(sObjName_text_down, OBJ_TEXT, 0,dtTimeEnd-420, dPriceLow - iOffSet*Point);                     // SCREEN TEXT 
      string      sObjNameOBprice_down = DoubleToStr(dPriceLow - iOffSet*Point,4);                                // SCREEN TEXT 
      ObjectSetText(sObjName_text_down,sObjNameOBprice_down, 8, "Arial", Black);    //dPriceHigh + iOffSet*Point, // SCREEN TEXT 
      ObjectMove(sObjName_text_down, 0, dtTimeEnd-420, dPriceLow - iOffSet*Point);                                // SCREEN TEXT 
      }                                                                                                           // SCREEN TEXT 
   }
   }

//---- Period A Rectangle
  if(iForm==4){
      ObjectCreate(sObjName, OBJ_RECTANGLE, 0, 0, 0, 0, 0);
      ObjectSet(sObjName, OBJPROP_TIME1 , dtTimeBegin);
      ObjectSet(sObjName, OBJPROP_TIME2 , dtTimeEnd);
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceHigh);
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceLow);
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(sObjName, OBJPROP_COLOR, cObjColor1);
      ObjectSet(sObjName, OBJPROP_WIDTH, 1);
      ObjectSet(sObjName, OBJPROP_BACK, background);
      sObjDesc = StringConcatenate("High: ",dPriceHigh,"  Low: ", dPriceLow);  
      ObjectSetText(sObjName, sObjDesc,10,"Times New Roman",Black);
   }   
//---- Period B Rectangle
  if(iForm==5){
      ObjectCreate(sObjName, OBJ_RECTANGLE, 0, 0, 0, 0, 0);
      ObjectSet(sObjName, OBJPROP_TIME1 , dtTimeEnd);
      ObjectSet(sObjName, OBJPROP_TIME2 , dtTimeObjEnd);
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceHigh + iOffSet*Point);
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceLow - iOffSet*Point);
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(sObjName, OBJPROP_COLOR, cObjColor1);
      ObjectSet(sObjName, OBJPROP_WIDTH, 1);
      ObjectSet(sObjName, OBJPROP_BACK, background);
   }     
//---- Period A Open Line
  if(iForm==6){
      ObjectCreate(sObjName,OBJ_TREND,0,0,0,0);
      ObjectSet(sObjName, OBJPROP_TIME1 , dtTimeBegin);
      ObjectSet(sObjName, OBJPROP_TIME2 , dtTimeObjEnd);
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceOpen);
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceOpen);
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_DASH);
      ObjectSet(sObjName, OBJPROP_COLOR, Green);
      ObjectSet(sObjName, OBJPROP_WIDTH, 1);
      ObjectSet(sObjName, OBJPROP_BACK, background);
      ObjectSet(sObjName, OBJPROP_RAY,false);
   }     
//---- Period A Close Line
rectA_close_begin = true;
  if(iForm==7){
      ObjectCreate(sObjName,OBJ_TREND,0,0,0,0);
      ObjectSet(sObjName, OBJPROP_TIME1 , dtTimeEnd);
      if(rectA_close_begin) ObjectSet(sObjName, OBJPROP_TIME1, dtTimeBegin);
      ObjectSet(sObjName, OBJPROP_TIME2 , dtTimeObjEnd);
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceClose);
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceClose);
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_DASHDOTDOT);
      ObjectSet(sObjName, OBJPROP_COLOR, Red);
      ObjectSet(sObjName, OBJPROP_WIDTH, 1);
      ObjectSet(sObjName, OBJPROP_BACK, background);
      ObjectSet(sObjName, OBJPROP_RAY,false);
   }        
//---- Period B HIGH Alert
  if(iForm==8){
      ObjectCreate(sObjName,OBJ_TREND,0,0,0,0);
      ObjectSet(sObjName, OBJPROP_TIME1 , dtTimeEnd);
      ObjectSet(sObjName, OBJPROP_TIME2 , dtTimeObjEnd);
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceHigh + iOffSet*Point);
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceHigh + iOffSet*Point);
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(sObjName, OBJPROP_COLOR, cObjColor1);
      ObjectSet(sObjName, OBJPROP_WIDTH, 1);
      ObjectSet(sObjName, OBJPROP_BACK, background);
      ObjectSet(sObjName, OBJPROP_RAY,false);
      sObjDesc = StringConcatenate("Period B - HIGH Alert_01 - ",dPriceHigh + iOffSet*Point);  
      ObjectSetText(sObjName, sObjDesc,10,"Times New Roman",Black);
//      if(Bid >= (dPriceHigh + iOffSet*Point)) Alert(sObjName," - ",dPriceHigh + iOffSet*Point);
   }     
//---- Period B LOW Alert
  if(iForm==9){
      ObjectCreate(sObjName,OBJ_TREND,0,0,0,0);
      ObjectSet(sObjName, OBJPROP_TIME1 , dtTimeEnd);
      ObjectSet(sObjName, OBJPROP_TIME2 , dtTimeObjEnd);
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceLow - iOffSet*Point);
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceLow - iOffSet*Point);
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(sObjName, OBJPROP_COLOR, cObjColor1);
      ObjectSet(sObjName, OBJPROP_WIDTH, 1);
      ObjectSet(sObjName, OBJPROP_BACK, background);
      ObjectSet(sObjName, OBJPROP_RAY,false);
      sObjDesc = StringConcatenate("Period B - LOW Alert_01 - ",dPriceLow - iOffSet*Point);  
      ObjectSetText(sObjName, sObjDesc,10,"Times New Roman",Black);  
//      if(Bid <= (dPriceLow - iOffSet*Point)) Alert(sObjName," - ",dPriceLow - iOffSet*Point);    
   }           
}

//+------------------------------------------------------------------+
//| Decrement Date to draw objects in the past                       |
//+------------------------------------------------------------------+

datetime decrementTradeDate (datetime dtTimeDate) {
   int iTimeYear=TimeYear(dtTimeDate);
   int iTimeMonth=TimeMonth(dtTimeDate);
   int iTimeDay=TimeDay(dtTimeDate);
   int iTimeHour=TimeHour(dtTimeDate);
   int iTimeMinute=TimeMinute(dtTimeDate);

   iTimeDay--;
   if (iTimeDay==0) {
     iTimeMonth--;
     if (iTimeMonth==0) {
       iTimeYear--;
       iTimeMonth=12;
     }
    
     // Thirty days hath September...  
     if (iTimeMonth==4 || iTimeMonth==6 || iTimeMonth==9 || iTimeMonth==11) iTimeDay=30;
     // ...all the rest have thirty-one...
     if (iTimeMonth==1 || iTimeMonth==3 || iTimeMonth==5 || iTimeMonth==7 || iTimeMonth==8 || iTimeMonth==10 || iTimeMonth==12) iTimeDay=31;
     // ...except...
     if (iTimeMonth==2) if (MathMod(iTimeYear, 4)==0) iTimeDay=29; else iTimeDay=28;
   }
  return(StrToTime(iTimeYear + "." + iTimeMonth + "." + iTimeDay + " " + iTimeHour + ":" + iTimeMinute));
}

//+------------------------------------------------------------------+
//
//
//

/*
//+------------------------------------------------------------------+
//|                                                        times.mq4 |
//|                                                                  |
//|               Made/Modified by sh _j .                           |
//+------------------------------------------------------------------+
#property copyright "Morning Star"
#property link      "http://Grand Forex.ir"

#property indicator_chart_window

 
extern int    NumberOfDays = 50;        
extern string AsiaBegin    = "01:00";   
extern string AsiaEnd      = "09:00";   
extern color  AsiaColor    = Red; 
extern string EurBegin     = "09:00";   
extern string EurEnd       = "16:00";   
extern color  EurColor     = Blue;       
extern string USABegin     = "16:00";   
extern string USAEnd       = "23:00";   
extern color  USAColor     = Tan; 


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init() {
  DeleteObjects();
  for (int i=0; i<NumberOfDays; i++) {
    CreateObjects("AS"+i, AsiaColor);
    CreateObjects("EU"+i, EurColor);
    CreateObjects("US"+i, USAColor);
  }
  Comment("");
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void deinit() {
  DeleteObjects();
  Comment("");
}

 
void CreateObjects(string no, color cl) {
  ObjectCreate(no, OBJ_RECTANGLE, 0, 0,0, 0,0);
  ObjectSet(no, OBJPROP_STYLE, STYLE_SOLID);
  ObjectSet(no, OBJPROP_COLOR, cl);
  ObjectSet(no, OBJPROP_BACK, True);
}

//+------------------------------------------------------------------+
//| Удаление объектов индикатора                                     |
//+------------------------------------------------------------------+
void DeleteObjects() {
  for (int i=0; i<NumberOfDays; i++) {
    ObjectDelete("AS"+i);
    ObjectDelete("EU"+i);
    ObjectDelete("US"+i);
  }
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void start() {
  datetime dt=CurTime();

  for (int i=0; i<NumberOfDays; i++) {
    DrawObjects(dt, "AS"+i, AsiaBegin, AsiaEnd);
    DrawObjects(dt, "EU"+i, EurBegin, EurEnd);
    DrawObjects(dt, "US"+i, USABegin, USAEnd);
    dt=decDateTradeDay(dt);
    while (TimeDayOfWeek(dt)>5) dt=decDateTradeDay(dt);
  }
}

  
void DrawObjects(datetime dt, string no, string tb, string te) {
  datetime t1, t2;
  double   p1, p2;
  int      b1, b2;

  t1=StrToTime(TimeToStr(dt, TIME_DATE)+" "+tb);
  t2=StrToTime(TimeToStr(dt, TIME_DATE)+" "+te);
  b1=iBarShift(NULL, 0, t1);
  b2=iBarShift(NULL, 0, t2);
  p1=High[Highest(NULL, 0, MODE_HIGH, b1-b2, b2)];
  p2=Low [Lowest (NULL, 0, MODE_LOW , b1-b2, b2)];
  ObjectSet(no, OBJPROP_TIME1 , t1);
  ObjectSet(no, OBJPROP_PRICE1, p1);
  ObjectSet(no, OBJPROP_TIME2 , t2);
  ObjectSet(no, OBJPROP_PRICE2, p2);
}


datetime decDateTradeDay (datetime dt) {
  int ty=TimeYear(dt);
  int tm=TimeMonth(dt);
  int td=TimeDay(dt);
  int th=TimeHour(dt);
  int ti=TimeMinute(dt);

  td--;
  if (td==0) {
    tm--;
    if (tm==0) {
      ty--;
      tm=12;
    }
    if (tm==1 || tm==3 || tm==5 || tm==7 || tm==8 || tm==10 || tm==12) td=31;
    if (tm==2) if (MathMod(ty, 4)==0) td=29; else td=28;
    if (tm==4 || tm==6 || tm==9 || tm==11) td=30;
  }
  return(StrToTime(ty+"."+tm+"."+td+" "+th+":"+ti));
}
//+------------------------------------------------------------------+
*/

