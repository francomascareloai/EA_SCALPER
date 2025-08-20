#property copyright "by Squalou and mer071898"
#property link      "http://www.forexfactory.com/showthread.php?t=247220"
#property description "not for sale, rent, nor auction"

#property indicator_chart_window

#define VERSION "3 Tier London Breakout Indicator V.3.2c"

extern string Info                    = VERSION;
extern string StartTime               = "06:00";
extern string EndTime                 = "09:14";
extern string SessionEndTime          = "04:30";
extern color  SessionColor            = clrLinen;
extern int    NumDays                 = 200;
extern int    MinBoxSizeInPips        = 15;
extern int    MaxBoxSizeInPips        = 80;
extern bool   LimitBoxToMaxSize       = true;
extern bool   StickBoxToLatestExtreme = false;
extern bool   StickBoxOusideSRlevels  = false;
extern double TP1Factor               = 1.000;
       double TP2Factor;
extern double TP3Factor               = 2.618;
       double TP4Factor;
extern double TP5Factor               = 4.236;
extern string TP2_help                = "TP2 is half-way between TP1 and TP3";
extern string TP4_help                = "TP4 is half-way between TP3 and TP5";
       double SLFactor                = 1.000;
extern double LevelsResizeFactor      = 1.0;
extern color  BoxColorOK              = clrLightBlue;
extern color  BoxColorNOK             = clrRed;
extern color  BoxColorMAX             = clrOrange;
extern color  LevelColor              = clrBlack;
extern int    FibLength               = 14;
extern bool   showProfitZone          = true;
extern color  ProfitColor             = C'176,255,176';
extern string objPrefix               = "LB2-";
extern bool   ShowBreakoutArrow       = true;
extern color  BuyArrowColor           = clrLime;
extern color  SellArrowColor          = clrRed;
extern int    BreakoutArrowSize       = 3;
extern bool   ShowTP5Cross            = true;
extern color  TP5CrossColor           = clrRed;
extern int    TP5CrossSize            = 3;
extern string button_note1            = "------------------------------";
extern int    btn_Subwindow           = 0;
extern ENUM_BASE_CORNER btn_corner    = CORNER_LEFT_UPPER;
extern string btn_text                = "LONDON";
extern string btn_Font                = "Arial";
extern int    btn_FontSize            = 9;
extern color  btn_text_ON_color       = clrLime;
extern color  btn_text_OFF_color      = clrRed;
extern color  btn_background_color    = clrDimGray;
extern color  btn_border_color        = clrBlack;
extern int    button_x                = 20;
extern int    button_y                = 25;
extern int    btn_Width               = 80;
extern int    btn_Height              = 20;
extern string UniqueButtonID          = "LondonBreakOut";
extern string button_note2            = "------------------------------";

bool show_data, recalc=false;
string IndicatorObjPrefix, buttonId;

double pip;
int digits;
int BarsBack;

double BuyEntry,BuyTP1,BuyTP2,BuyTP3,BuyTP4,BuyTP5,BuySL;
double SellEntry,SellTP1,SellTP2,SellTP3,SellTP4,SellTP5,SellSL;
int SL_pips,TP1_pips,TP2_pips,TP3_pips,TP4_pips,TP5_pips;
double TP1FactorInput,TP2FactorInput,TP3FactorInput,TP4FactorInput,TP5FactorInput,SLFactorInput;
datetime tBoxStart,tBoxEnd,tSessionStart,tSessionEnd,tLastComputedSessionStart,tLastComputedSessionEnd;
double boxHigh,boxLow,boxExtent,boxMedianPrice;

int StartShift;
int EndShift;
datetime alreadyDrawn;

int OnInit()
{
   IndicatorDigits(Digits);
   IndicatorObjPrefix = "_" + btn_text + "_";
   buttonId = "_" + IndicatorObjPrefix + UniqueButtonID + "_BT_";
   if (ObjectFind(buttonId)<0) 
      createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_ON_color);
   ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, button_x);

   init2();

   show_data = ObjectGetInteger(0, buttonId, OBJPROP_STATE);
   
   if (show_data) ObjectSetInteger(0,buttonId,OBJPROP_COLOR,btn_text_ON_color); 
   else ObjectSetInteger(0,buttonId,OBJPROP_COLOR,btn_text_OFF_color);
   return(INIT_SUCCEEDED);
}

void createButton(string buttonID,string buttonText,int width2,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
{
   ObjectDelete    (0,buttonID);
   ObjectCreate    (0,buttonID,OBJ_BUTTON,btn_Subwindow,0,0);
   ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
   ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
   ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
   ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
   ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width2);
   ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
   ObjectSetString (0,buttonID,OBJPROP_FONT,font);
   ObjectSetString (0,buttonID,OBJPROP_TEXT,buttonText);
   ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
   ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
   ObjectSetInteger(0,buttonID,OBJPROP_CORNER,btn_corner);
   ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
   ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
   ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
   ObjectSetInteger(0, buttonId, OBJPROP_STATE, true);
}

void OnDeinit(const int reason) 
{
   if(reason != REASON_CHARTCHANGE) ObjectDelete(buttonId);
   deinit2();
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if(id==CHARTEVENT_OBJECT_CREATE || id==CHARTEVENT_OBJECT_DELETE) return;
   if(id==CHARTEVENT_MOUSE_MOVE    || id==CHARTEVENT_MOUSE_WHEEL)   return;

   if (id==CHARTEVENT_OBJECT_CLICK && sparam == buttonId)
   {
      show_data = ObjectGetInteger(0, buttonId, OBJPROP_STATE);
      
      if (show_data)
      {
         ObjectSetInteger(0,buttonId,OBJPROP_COLOR,btn_text_ON_color); 
         init2();
         recalc=true;
         mystart();
      }
      else
      {
         ObjectSetInteger(0,buttonId,OBJPROP_COLOR,btn_text_OFF_color);
         deinit2();
      }
   }
}

int init2()  {
   Comment (Info+" ["+StartTime+"-"+EndTime+"] end "+SessionEndTime+" min "+DoubleToStr(MinBoxSizeInPips,0)+"p,"+" max "+DoubleToStr(MaxBoxSizeInPips,0)+"p,"
            +DoubleToStr(TP1Factor,1)+"/"+DoubleToStr(TP3Factor,1)+"/"+DoubleToStr(TP5Factor,1));

   RemoveObjects(objPrefix);	
   getpip();	

   BarsBack = NumDays*(PERIOD_D1/Period());
   alreadyDrawn = 0;

   TP1FactorInput = TP1Factor;
   TP3FactorInput = TP3Factor;
   TP5FactorInput = TP5Factor;
   SLFactorInput  = SLFactor;

   TP2Factor = (TP1Factor+TP3Factor)/2;
   TP4Factor = (TP3Factor+TP5Factor)/2;

   if (StickBoxOusideSRlevels==true) {
      LimitBoxToMaxSize = true;
      StickBoxToLatestExtreme = true;
   }

   return(0);
}

int deinit2()  {
   RemoveObjects(objPrefix);	
   return(0);
}

int start() {return(mystart()); }

int mystart()
{
   int i, limit, counted_bars=IndicatorCounted();
   if (show_data)
   {
      if(recalc) 
      {
         counted_bars = 0;
         recalc=false;
      }

      limit = MathMin(BarsBack,Bars-counted_bars-1);

      for (i=limit; i>=0; i--) {
         new_tick(i);
      }
   }
   return(0);
}

void new_tick(int i)
{
   datetime now = Time[i];
   compute_LB_Indi_LEVELS(now);
   show_boxes(now);
   check_breakouts_and_tp5(i);
}

void compute_LB_Indi_LEVELS(datetime now)
{
   int boxStartShift,boxEndShift;

   if (now >= tSessionStart && now <= tSessionEnd) return;

   tBoxStart = StrToTime(TimeToStr(now,TIME_DATE) + " "  + StartTime);
   tBoxEnd   = StrToTime(TimeToStr(now,TIME_DATE) + " "  + EndTime);
   if (tBoxStart > tBoxEnd) tBoxStart -= 86400;
   if (now < tBoxEnd) {
      tBoxStart -= 86400;
      tBoxEnd   -= 86400;
      while ((TimeDayOfWeek(tBoxStart)==0 || TimeDayOfWeek(tBoxStart)==6)
          && (TimeDayOfWeek(tBoxEnd)==0 || TimeDayOfWeek(tBoxEnd)==6) ) {
         tBoxStart -= 86400;
         tBoxEnd   -= 86400;
      }
   }

   tSessionStart = tBoxEnd;
   tSessionEnd = StrToTime(TimeToStr(tSessionStart,TIME_DATE) + " "  + SessionEndTime);
   if (tSessionStart > tSessionEnd) tSessionEnd = tSessionEnd + 86400;
   if (TimeDayOfWeek(tSessionEnd)==6) tSessionEnd += 2*86400;
   if (TimeDayOfWeek(tSessionEnd)==0) tSessionEnd += 86400;
   tLastComputedSessionStart = tSessionStart;
   tLastComputedSessionEnd   = tSessionEnd;

   boxStartShift = iBarShift(NULL,0,tBoxStart);
   boxEndShift   = iBarShift(NULL,0,tBoxEnd);
   boxHigh = High[iHighest(NULL,0,MODE_HIGH,(boxStartShift-boxEndShift+1),boxEndShift)];
   boxLow  = Low[iLowest(NULL,0,MODE_LOW,(boxStartShift-boxEndShift+1),boxEndShift)];
   boxMedianPrice = (boxHigh+boxLow)/2;
   boxExtent = boxHigh - boxLow;

   if (boxExtent >= MaxBoxSizeInPips * pip && LimitBoxToMaxSize==true) {
      if (StickBoxToLatestExtreme==true) {
         int boxStartShiftM1 = iBarShift(NULL,PERIOD_M1,tBoxStart);
         int boxEndShiftM1   = iBarShift(NULL,PERIOD_M1,tBoxEnd);
         int boxHighShift    = iHighest(NULL,PERIOD_M1,MODE_HIGH,(boxStartShiftM1-boxEndShiftM1+1),boxEndShiftM1);
         int boxLowShift     = iLowest(NULL,PERIOD_M1,MODE_LOW,(boxStartShiftM1-boxEndShiftM1+1),boxEndShiftM1);
         boxExtent = MaxBoxSizeInPips * pip;
         if (boxHighShift <= boxLowShift) {
            if (StickBoxOusideSRlevels==true) {
               boxMedianPrice = boxHigh + boxExtent/2;
            } else {
               boxMedianPrice = boxHigh - boxExtent/2;
            }
         } else {
            if (StickBoxOusideSRlevels==true) {
               boxMedianPrice = boxLow - boxExtent/2;
            } else {
               boxMedianPrice = boxLow + boxExtent/2;
            }
         }
      } else {
         boxExtent      = MaxBoxSizeInPips * pip;
         boxMedianPrice = iMA(NULL,0,boxStartShift-boxEndShift,0,MODE_EMA,PRICE_MEDIAN,boxEndShift);
      }
   }
   
   boxExtent *= LevelsResizeFactor;
   boxHigh = NormalizeDouble(boxMedianPrice + boxExtent/2,Digits);
   boxLow  = NormalizeDouble(boxMedianPrice - boxExtent/2,Digits);

   TP1Factor = TP1FactorInput;
   TP3Factor = TP3FactorInput;
   TP5Factor = TP5FactorInput;
   SLFactor  = SLFactorInput;

   BuyEntry  = boxHigh;
   SellEntry = boxLow;

   if (TP1Factor < 10) TP1_pips = boxExtent*TP1Factor/pip;
   else { TP1_pips = TP1Factor; TP1Factor = TP1_pips*pip/boxExtent; }
   BuyTP1  = NormalizeDouble(BuyEntry  + TP1_pips*pip,Digits);
   SellTP1 = NormalizeDouble(SellEntry - TP1_pips*pip,Digits);

   if (TP3Factor < 10) TP3_pips = boxExtent*TP3Factor/pip;
   else { TP3_pips = TP3Factor; TP3Factor = TP3_pips*pip/boxExtent; }
   BuyTP3  = NormalizeDouble(BuyEntry  + TP3_pips*pip,Digits);
   SellTP3 = NormalizeDouble(SellEntry - TP3_pips*pip,Digits);

   TP2Factor = (TP1Factor+TP3Factor)/2;
   if (TP2Factor < 10) TP2_pips = boxExtent*TP2Factor/pip;
   else { TP2_pips = TP2Factor; TP2Factor = TP2_pips*pip/boxExtent; }
   BuyTP2  = NormalizeDouble(BuyEntry  + TP2_pips*pip,Digits);
   SellTP2 = NormalizeDouble(SellEntry - TP2_pips*pip,Digits);

   if (TP5Factor < 10) TP5_pips = boxExtent*TP5Factor/pip;
   else { TP5_pips = TP5Factor; TP5Factor = TP5_pips*pip/boxExtent; }
   BuyTP5  = NormalizeDouble(BuyEntry  + TP5_pips*pip,Digits);
   SellTP5 = NormalizeDouble(SellEntry - TP5_pips*pip,Digits);

   TP4Factor = (TP3Factor+TP5Factor)/2;
   if (TP4Factor < 10) TP4_pips = boxExtent*TP4Factor/pip;
   else { TP4_pips = TP4Factor; TP4Factor = TP4_pips*pip/boxExtent; }
   BuyTP4  = NormalizeDouble(BuyEntry  + TP4_pips*pip,Digits);
   SellTP4 = NormalizeDouble(SellEntry - TP4_pips*pip,Digits);

   if (SLFactor < 10) SL_pips = boxExtent*SLFactor/pip;
   else { SL_pips = SLFactor; SLFactor = SL_pips*pip/boxExtent; }
   BuySL  = NormalizeDouble(BuyEntry  - SL_pips*pip,Digits);
   SellSL = NormalizeDouble(SellEntry + SL_pips*pip,Digits);
}

void check_breakouts_and_tp5(int i)
{
   if (!show_data || i >= Bars-1) return;

   datetime currentTime = Time[i];
   double high = High[i];
   double low = Low[i];
   string objname;

   if (ShowBreakoutArrow && currentTime >= tSessionStart && currentTime <= tSessionEnd) {
      if (high >= BuyEntry && iHigh(NULL, 0, i+1) < BuyEntry) {
         objname = objPrefix + "BuyArrow-" + TimeToStr(currentTime, TIME_DATE | TIME_MINUTES);
         ObjectCreate(objname, OBJ_ARROW_UP, 0, currentTime, low - 2*pip);
         ObjectSetInteger(0, objname, OBJPROP_COLOR, BuyArrowColor);
         ObjectSetInteger(0, objname, OBJPROP_WIDTH, BreakoutArrowSize);
         ObjectSetInteger(0, objname, OBJPROP_ARROWCODE, 233);
      }
      if (low <= SellEntry && iLow(NULL, 0, i+1) > SellEntry) {
         objname = objPrefix + "SellArrow-" + TimeToStr(currentTime, TIME_DATE | TIME_MINUTES);
         ObjectCreate(objname, OBJ_ARROW_DOWN, 0, currentTime, high + 2*pip);
         ObjectSetInteger(0, objname, OBJPROP_COLOR, SellArrowColor);
         ObjectSetInteger(0, objname, OBJPROP_WIDTH, BreakoutArrowSize);
         ObjectSetInteger(0, objname, OBJPROP_ARROWCODE, 234);
      }
   }

   if (ShowTP5Cross && TP5Factor > 0 && currentTime >= tSessionStart && currentTime <= tSessionEnd) {
      if (high >= BuyTP5 && iHigh(NULL, 0, i+1) < BuyTP5) {
         objname = objPrefix + "BuyTP5Cross-" + TimeToStr(currentTime, TIME_DATE | TIME_MINUTES);
         ObjectCreate(objname, OBJ_ARROW, 0, currentTime, BuyTP5);
         ObjectSetInteger(0, objname, OBJPROP_COLOR, TP5CrossColor);
         ObjectSetInteger(0, objname, OBJPROP_WIDTH, TP5CrossSize);
         ObjectSetInteger(0, objname, OBJPROP_ARROWCODE, 251);
      }
      if (low <= SellTP5 && iLow(NULL, 0, i+1) > SellTP5) {
         objname = objPrefix + "SellTP5Cross-" + TimeToStr(currentTime, TIME_DATE | TIME_MINUTES);
         ObjectCreate(objname, OBJ_ARROW, 0, currentTime, SellTP5);
         ObjectSetInteger(0, objname, OBJPROP_COLOR, TP5CrossColor);
         ObjectSetInteger(0, objname, OBJPROP_WIDTH, TP5CrossSize);
         ObjectSetInteger(0, objname, OBJPROP_ARROWCODE, 251);
      }
   }
}

void show_boxes(datetime now)
{
   static datetime alreadyDrawn2=0;

   drawBoxOnce (objPrefix+"Session-"+TimeToStr(tSessionStart,TIME_DATE | TIME_SECONDS),tSessionStart,0,tSessionEnd,BuyEntry*2,SessionColor,1, STYLE_SOLID, true);

   if (alreadyDrawn2 != tBoxEnd) {
      alreadyDrawn2 = tBoxEnd;
   
      string boxName = objPrefix+"Box-"+TimeToStr(now,TIME_DATE)+"-"+StartTime+"-"+EndTime;
      if (boxExtent >= MaxBoxSizeInPips * pip) {
         if (LimitBoxToMaxSize==false) {
            drawBox (boxName,tBoxStart,boxLow,tBoxEnd,boxHigh,BoxColorNOK,1, STYLE_SOLID, true);
            DrawLbl(objPrefix+"Lbl-"+TimeToStr(now,TIME_DATE)+"-"+StartTime+"-"+EndTime, "NO TRADE! ("+DoubleToStr(boxExtent/pip,0)+"p)", tBoxStart+(tBoxEnd-tBoxStart)/2,boxLow, 12, "Arial Black", LevelColor, 3);
         } else {
            drawBox (boxName,tBoxStart,boxLow,tBoxEnd,boxHigh,BoxColorMAX,1, STYLE_SOLID, true);
            DrawLbl(objPrefix+"Lbl-"+TimeToStr(now,TIME_DATE)+"-"+StartTime+"-"+EndTime, "MAX LIMIT! ("+DoubleToStr(boxExtent/pip,0)+"p)", tBoxStart+(tBoxEnd-tBoxStart)/2,boxLow, 12, "Arial Black", LevelColor, 3);
         }
      } else if (boxExtent >= MinBoxSizeInPips * pip) {
         drawBox (boxName,tBoxStart,boxLow,tBoxEnd,boxHigh,BoxColorOK,1, STYLE_SOLID, true);
         DrawLbl(objPrefix+"Lbl-"+TimeToStr(now,TIME_DATE)+"-"+StartTime+"-"+EndTime, DoubleToStr(boxExtent/pip,0)+"p", tBoxStart+(tBoxEnd-tBoxStart)/2,boxLow, 12, "Arial Black", LevelColor, 3);
      } else {
         drawBox (boxName,tBoxStart,boxLow,tBoxEnd,boxHigh,BoxColorNOK,1, STYLE_SOLID, true);
         DrawLbl(objPrefix+"Lbl-"+TimeToStr(now,TIME_DATE)+"-"+StartTime+"-"+EndTime, "Caution! ("+DoubleToStr(boxExtent/pip,0)+"p)", tBoxStart+(tBoxEnd-tBoxStart)/2,boxLow, 12, "Arial Black", BoxColorNOK, 3);
      }
      DrawLbl(objPrefix+"Lbl2-"+TimeToStr(now,TIME_DATE)+"-"+StartTime+"-"+EndTime,"BO", tBoxStart+(tBoxEnd-tBoxStart)/2,boxLow-6*pip, 24, "Arial Black", LevelColor, 2);

      if (showProfitZone) {
         double UpperTP,LowerTP;
         if (TP5Factor>0) {
            UpperTP = BuyTP5;
            LowerTP = SellTP5;
         } else {
            UpperTP = BuyTP3;
            LowerTP = SellTP3;
         }
         drawBox (objPrefix+"BuyProfitZone-" +TimeToStr(tSessionStart,TIME_DATE),tSessionStart,BuyTP1,tSessionEnd,UpperTP,ProfitColor,1, STYLE_SOLID, true);
         drawBox (objPrefix+"SellProfitZone-"+TimeToStr(tSessionStart,TIME_DATE),tSessionStart,SellTP1,tSessionEnd,LowerTP,ProfitColor,1, STYLE_SOLID, true);
      }

      string objname = objPrefix+"Fibo-" + tBoxEnd;
      ObjectCreate(objname,OBJ_FIBO,0,tBoxStart,SellEntry,tBoxStart+FibLength*60*10,BuyEntry);
      ObjectSet(objname,OBJPROP_RAY,false);
      ObjectSet(objname,OBJPROP_LEVELCOLOR,LevelColor); 
      ObjectSet(objname,OBJPROP_FIBOLEVELS,12);
      ObjectSet(objname,OBJPROP_LEVELSTYLE,STYLE_SOLID);
      _SetFibLevel(objname,0,0.0,"Entry Buy= %$");  
      _SetFibLevel(objname,1,1.0,"Entry Sell= %$");
      _SetFibLevel(objname,2,-TP1Factor, "Buy Target 1= %$  (+"+DoubleToStr(TP1_pips,0)+"p)");
      _SetFibLevel(objname,3,1+TP1Factor,"Sell Target 1= %$  (+"+DoubleToStr(TP1_pips,0)+"p)");
      _SetFibLevel(objname,4,-TP2Factor, "Buy Target 2= %$  (+"+DoubleToStr(TP2_pips,0)+"p)");
      _SetFibLevel(objname,5,1+TP2Factor,"Sell Target 2= %$  (+"+DoubleToStr(TP2_pips,0)+"p)");
      _SetFibLevel(objname,6,-TP3Factor, "Buy Target 3= %$  (+"+DoubleToStr(TP3_pips,0)+"p)");
      _SetFibLevel(objname,7,1+TP3Factor,"Sell Target 3= %$  (+"+DoubleToStr(TP3_pips,0)+"p)");
      if (TP5Factor>0) {
         _SetFibLevel(objname,8,-TP4Factor, "Buy Target 4= %$  (+"+DoubleToStr(TP4_pips,0)+"p)");
         _SetFibLevel(objname,9,1+TP4Factor,"Sell Target 4= %$  (+"+DoubleToStr(TP4_pips,0)+"p)");
         _SetFibLevel(objname,10,-TP5Factor, "Buy Target 5= %$  (+"+DoubleToStr(TP5_pips,0)+"p)");
         _SetFibLevel(objname,11,1+TP5Factor,"Sell Target 5= %$  (+"+DoubleToStr(TP5_pips,0)+"p)");
      }
   }
}

void _SetFibLevel(string objname, int level, double value, string description)
{
   ObjectSet(objname,OBJPROP_FIRSTLEVEL+level,value);
   ObjectSetFiboDescription(objname,level,description);
}

void getpip()
{
   if(Digits==2 || Digits==4) pip = Point;
   else if(Digits==3 || Digits==5) pip = 10*Point;
   else if(Digits==6) pip = 100*Point;
      
   if (Digits == 3 || Digits == 2) digits = 2;
   else digits = 4;
}

void RemoveObjects(string Pref)
{   
   int i;
   string objname = "";

   for (i = ObjectsTotal(); i >= 0; i--) {
      objname = ObjectName(i);
      if (StringFind(objname, Pref, 0) > -1) ObjectDelete(objname);
   }
}

void drawBox (
   string objname,
   datetime tStart, double vStart, 
   datetime tEnd,   double vEnd,
   color c, int width, int style, bool bg
)
{
   if (ObjectFind(objname) == -1) {
      ObjectCreate(objname, OBJ_RECTANGLE, 0, tStart,vStart,tEnd,vEnd);
   } else {
      ObjectSet(objname, OBJPROP_TIME1, tStart);
      ObjectSet(objname, OBJPROP_TIME2, tEnd);
      ObjectSet(objname, OBJPROP_PRICE1, vStart);
      ObjectSet(objname, OBJPROP_PRICE2, vEnd);
   }

   ObjectSet(objname,OBJPROP_COLOR, c);
   ObjectSet(objname, OBJPROP_BACK, bg);
   ObjectSet(objname, OBJPROP_WIDTH, width);
   ObjectSet(objname, OBJPROP_STYLE, style);
}

void drawBoxOnce (
   string objname,
   datetime tStart, double vStart, 
   datetime tEnd,   double vEnd,
   color c, int width, int style, bool bg
)
{
   if (ObjectFind(objname) != -1) return;
   
   ObjectCreate(objname, OBJ_RECTANGLE, 0, tStart,vStart,tEnd,vEnd);
   ObjectSet(objname,OBJPROP_COLOR, c);
   ObjectSet(objname, OBJPROP_BACK, bg);
   ObjectSet(objname, OBJPROP_WIDTH, width);
   ObjectSet(objname, OBJPROP_STYLE, style);
}

void DrawLbl(string objname, string s, int LTime, double LPrice, int FSize, string Font, color c, int width)
{
   if (ObjectFind(objname) < 0) {
      ObjectCreate(objname, OBJ_TEXT, 0, LTime, LPrice);
   } else {
      if (ObjectType(objname) == OBJ_TEXT) {
         ObjectSet(objname, OBJPROP_TIME1, LTime);
         ObjectSet(objname, OBJPROP_PRICE1, LPrice);
      }
   }

   ObjectSet(objname, OBJPROP_FONTSIZE, FSize);
   ObjectSetText(objname, s, FSize, Font, c);
}