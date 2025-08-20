//+------------------------------------------------------------------+
//|                                                 BreakOut_BOX.mq4 |
//|                                                        hapalkos  |
//|                                                       2007.02.10 |
//+------------------------------------------------------------------+
#property copyright "hapalkos"
#property link      ""

#property indicator_chart_window
 
extern int    NumberOfDays = 50;        
extern string periodBegin    = "06:00"; 
extern string periodEnd      = "08:00";   
extern string BoxEnd         = "20:00"; 
extern int    BoxBreakOut_Offset = 5; 
extern color  BoxHLColor         = Navy; 
extern color  BoxBreakOutColor   = RoyalBlue;
extern color  BoxPeriodColor     = OrangeRed;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void init() {

  DeleteObjects();

  datetime dtTradeDate=TimeCurrent();

  for (int i=0; i<NumberOfDays; i++) {
    CreateObjects("BoxHL  "+TimeToStr(dtTradeDate,TIME_DATE), BoxHLColor, True);
    CreateObjects("BoxBreakOut  "+TimeToStr(dtTradeDate,TIME_DATE),BoxBreakOutColor,True);
    CreateObjects("BoxPeriod  "+TimeToStr(dtTradeDate,TIME_DATE),BoxPeriodColor, False);
    dtTradeDate = decrementTradeDate(dtTradeDate);
    while (TimeDayOfWeek(dtTradeDate)>5) dtTradeDate = decrementTradeDate(dtTradeDate);    
    }
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void deinit() {
  DeleteObjects();
return(0);
}

//+------------------------------------------------------------------+
//| Create Rectangles                                                |
//+------------------------------------------------------------------+
void CreateObjects(string sObjName, color cObjColor, bool bProp_Back) {
  ObjectCreate(sObjName, OBJ_RECTANGLE, 0, 0, 0, 0, 0);
  ObjectSet(sObjName, OBJPROP_STYLE, STYLE_SOLID);
  ObjectSet(sObjName, OBJPROP_COLOR, cObjColor);
  ObjectSet(sObjName, OBJPROP_BACK, bProp_Back);
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
    DrawObjects(dtTradeDate, "BoxHL  " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin, periodEnd, BoxEnd, 0);
    DrawObjects(dtTradeDate, "BoxBreakOut  " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin, periodEnd, BoxEnd, BoxBreakOut_Offset);
    DrawObjects(dtTradeDate, "BoxPeriod  " + TimeToStr(dtTradeDate,TIME_DATE), periodBegin, periodEnd, periodEnd, BoxBreakOut_Offset);

    dtTradeDate=decrementTradeDate(dtTradeDate);
    while (TimeDayOfWeek(dtTradeDate) > 5) dtTradeDate = decrementTradeDate(dtTradeDate);
  }
}

void DrawObjects(datetime dtTradeDate, string sObjName, string sTimeBegin, string sTimeEnd, string sTimeObjEnd, int iOffSet) {
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
  string sObjDesc = StringConcatenate("High: ",dPriceHigh,"  Low: ", dPriceLow, " OffSet: ",iOffSet);
  
  ObjectSet(sObjName, OBJPROP_TIME1 , dtTimeBegin);
  ObjectSet(sObjName, OBJPROP_PRICE1, dPriceHigh + iOffSet*Point);
  ObjectSet(sObjName, OBJPROP_TIME2 , dtTimeObjEnd);
  ObjectSet(sObjName, OBJPROP_PRICE2, dPriceLow - iOffSet*Point);
  ObjectSetText(sObjName, sObjDesc,10,"Times New Roman",Black);
}

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

