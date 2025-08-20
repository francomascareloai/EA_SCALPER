//+------------------------------------------------------------------+
//|                                               BreakOutPANCA-EAGLE.mq4 |
//|                                                        hapalkos  |
//|                                                       2007.11.20 |
//|   ++ modified so that rectangles do not overlay                  |
//|   ++ this makes color selection more versatile                   |
//|   ++ code consolidated                                           |
//+------------------------------------------------------------------+
#property copyright "hapalkos"
#property link      ""

#property indicator_chart_window
 
extern int    NumberOfDays = 50;        
extern string periodBegin    = "00:00"; 
extern string periodEnd      = "05:30";   
extern string BoxEnd         = "23:00"; 
extern int    BoxBreakOut_Offset = 10; 
extern color  BoxHLColor         = MidnightBlue; 
extern color  BoxBreakOutColor   = LimeGreen;
extern color  BoxPeriodColor     = OrangeRed;

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
//| Remove all Rectangles                                            |
//+------------------------------------------------------------------+
void DeleteObjects() {
    ObjectsDeleteAll(0,OBJ_RECTANGLE);     
 return(0); 
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void start() {
  datetime dtTradeDate=TimeCurrent();

  for (int i=0; i<NumberOfDays; i++) {
  
    DrawObjects(dtTradeDate, "BoxHL  " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin, periodEnd, BoxEnd, BoxHLColor, 0, 1);
    DrawObjects(dtTradeDate, "BoxBreakOut_High  " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin, periodEnd, BoxEnd, BoxBreakOutColor, BoxBreakOut_Offset,2);
    DrawObjects(dtTradeDate, "BoxBreakOut_Low  " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin, periodEnd, BoxEnd, BoxBreakOutColor, BoxBreakOut_Offset,3);
    DrawObjects(dtTradeDate, "BoxPeriod  " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin, periodEnd, periodEnd, BoxPeriodColor, BoxBreakOut_Offset,4);

    dtTradeDate=decrementTradeDate(dtTradeDate);
    while (TimeDayOfWeek(dtTradeDate) > 5) dtTradeDate = decrementTradeDate(dtTradeDate);
  }
}

//+------------------------------------------------------------------+
//| Create Rectangles                                                |
//+------------------------------------------------------------------+

void DrawObjects(datetime dtTradeDate, string sObjName, string sTimeBegin, string sTimeEnd, string sTimeObjEnd, color cObjColor, int iOffSet, int iForm) {
  datetime dtTimeBegin, dtTimeEnd, dtTimeObjEnd;
  double   dPriceHigh,  dPriceLow;
  int      iBarBegin,   iBarEnd;

  dtTimeBegin = StrToTime(TimeToStr(dtTradeDate, TIME_DATE) + " " + sTimeBegin);
  dtTimeEnd = StrToTime(TimeToStr(dtTradeDate, TIME_DATE) + " " + sTimeEnd);
  dtTimeObjEnd = StrToTime(TimeToStr(dtTradeDate, TIME_DATE) + " " + sTimeObjEnd);
      
  iBarBegin = iBarShift(NULL, 0, dtTimeBegin);
  iBarEnd = iBarShift(NULL, 0, dtTimeEnd);
  dPriceHigh = High[Highest(NULL, 0, MODE_HIGH, iBarBegin-iBarEnd, iBarEnd)];
  dPriceLow = Low [Lowest (NULL, 0, MODE_LOW , iBarBegin-iBarEnd, iBarEnd)];
 
  ObjectCreate(sObjName, OBJ_RECTANGLE, 0, 0, 0, 0, 0);
  
  ObjectSet(sObjName, OBJPROP_TIME1 , dtTimeBegin);
  ObjectSet(sObjName, OBJPROP_TIME2 , dtTimeObjEnd);
  
//---- High-Low Rectangle
   if(iForm==1){  
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceHigh);  
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceLow);
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(sObjName, OBJPROP_COLOR, cObjColor);
      ObjectSet(sObjName, OBJPROP_BACK, True);
   }
   
//---- Upper Rectangle
  if(iForm==2){
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceHigh);
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceHigh + iOffSet*Point);
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(sObjName, OBJPROP_COLOR, cObjColor);
      ObjectSet(sObjName, OBJPROP_BACK, True);
   }
 
 //---- Lower Rectangle 
  if(iForm==3){
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceLow - iOffSet*Point);
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceLow);
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(sObjName, OBJPROP_COLOR, cObjColor);
      ObjectSet(sObjName, OBJPROP_BACK, True);
   }

//---- Period Rectangle
  if(iForm==4){
      ObjectSet(sObjName, OBJPROP_PRICE1, dPriceHigh + iOffSet*Point);
      ObjectSet(sObjName, OBJPROP_PRICE2, dPriceLow - iOffSet*Point);
      ObjectSet(sObjName, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(sObjName, OBJPROP_COLOR, cObjColor);
      ObjectSet(sObjName, OBJPROP_WIDTH, 2);
      ObjectSet(sObjName, OBJPROP_BACK, False);
   }   
      string sObjDesc = StringConcatenate("High: ",dPriceHigh,"  Low: ", dPriceLow, " OffSet: ",iOffSet);  
      ObjectSetText(sObjName, sObjDesc,10,"Times New Roman",Black);
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

