// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68338
//+------------------------------------------------------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------------------------------------------------------+
// modified by banzai from Mario Jemic template 
// July 30th, 2020
// not for sale, rent, auction, nor lease
//+++======================================================================+++
//+++                        Golden MA MTF TT [x5]                         +++
//+++======================================================================+++
#property copyright   "©  GaoShan  &&&&  Tankk,  8  июля  2017,  http://forexsystemsru.com/" 
#property link        "https://forexsystemsru.com/threads/indikatory-sobranie-sochinenij-tankk.86203/"  ////https://forexsystemsru.com/forums/indikatory-foreks.41/
//------
#property description "Оригинальная идея:  GaoShan  @   kirc@yeah.net"
#property description " "
#property description "расширил настройки  :-))" 
#property description " "
#property description "Почта:  tualatine@mail.ru" 
//#property version "2.52"  //из "4.0"
//#property strict
#property indicator_chart_window
#property indicator_buffers 0
//+++======================================================================+++
//+++                   Custom indicator ENUM settings                     +++
//+++======================================================================+++
enum calcPR { CO, OCLH, MEDIAN, TYPICAL, WEIGHTED };
//+++======================================================================+++
//+++                 Custom indicator input parameters                    +++
//+++======================================================================+++

extern ENUM_TIMEFRAMES PeriodGraphics  =  PERIOD_D1;
extern calcPR                   Price  =  TYPICAL;
extern int                  StartPips  =  20;
extern int                 InsidePips  =  1;
extern bool          BeyondBoundaries  =  false;
extern int     HowManyHoursToTheRight  =  4;  //12;
extern bool            StartEndPeriod  =  true;
extern string           note1          = "------------------------------";
extern color              ColorCenter  =  clrDarkSlateBlue,  //LightSteelBlue,
                              ColorHI  =  clrMediumBlue,
                              ColorLO  =  clrMediumVioletRed;   //Brown;
extern int                 SizeCenter  =  5,
                             SizeHiLo  =  4;
extern bool             YesterdayHiLo  =  true;
extern color           YesterdayColor  =  clrOrange;
extern int              YesterdaySize  =  1;
extern ENUM_LINE_STYLE      Yesterday  =  STYLE_DOT;
extern string           note2          = "------------------------------";
extern bool             ShowTextLabels = true;
extern int                   TextSize  =  8;
extern bool                 TagsRight  =  true;
extern color                TextColor  =  clrDimGray;
extern int        ShiftPreviousHiLabel =  -20;//Label Shift +move right -move left
extern int        ShiftPreviousLoLabel =  -20;//Label Shift +move right -move left
extern int            ShiftOtherLabels =  20;//Label Shift +move right -move left
string                          ШРИФТ  =  "Verdana";   //"Arial";

//template code start1
extern string             button_note1          = "------------------------------";
extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_UPPER; // chart btn_corner for anchoring
extern string             btn_text              = "Gold MA";
extern string             btn_Font              = "Arial";
extern int                btn_FontSize          = 10;                             //btn__font size
extern color              btn_text_ON_color     = clrWhite;
extern color              btn_text_OFF_color    = clrRed;
extern color              btn_background_color  = clrDimGray;
extern color              btn_border_color      = clrBlack;
extern int                button_x              = 20;                                     //btn__x
extern int                button_y              = 13;                                     //btn__y
extern int                btn_Width             = 60;                                 //btn__width
extern int                btn_Height            = 20;                                //btn__height
extern string             button_note2          = "------------------------------";

bool                      show_data             = true;
string IndicatorName, IndicatorObjPrefix;
//template code end1
//+++======================================================================+++
//+++                     Custom indicator buffers                         +++
//+++======================================================================+++
double HIGH, LOW, OPEN, CLOSE, MID;
double HI1, HI2, HI3, HI4, HI5;
double LO1, LO2, LO3, LO4, LO5;    int stPIP, inPIP;
double POINT;   datetime LastBarOpenTime;  string PREF;

//+------------------------------------------------------------------------------------------------------------------+
string GenerateIndicatorName(const string target) //don't change anything here
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}
//+------------------------------------------------------------------------------------------------------------------+
string buttonId;

int OnInit()
{
   IndicatorName = GenerateIndicatorName(btn_text);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   
   double val;
   if (GlobalVariableGet(IndicatorName + "_visibility", val))
      show_data = val != 0;

   ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, 1);
   buttonId = IndicatorObjPrefix + "GoldenMA2020";
   createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_ON_color);
   ObjectSetInteger(ChartID(), buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(ChartID(), buttonId, OBJPROP_XDISTANCE, button_x);

// put init() here
   PeriodGraphics = fmax(PeriodGraphics,_Period);    
   stPIP = StartPips;   if (StartPips<0) stPIP = 1;
   inPIP = InsidePips;   if (InsidePips<0) inPIP = 0;
   POINT = _Point;  if (Digits==3 || Digits==5) POINT*=10;
//------
   PREF = stringMTF(PeriodGraphics)+": GoldMA TT ["+ (string)Price+"*"+(string)StartPips+"+"+(string)InsidePips+">"+(string)HowManyHoursToTheRight+"]";
//------

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------------------------------------------------------+
//don't change anything here
void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
{
      ObjectDelete    (ChartID(),buttonID);
      ObjectCreate    (ChartID(),buttonID,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_XSIZE,width);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_YSIZE,height);
      ObjectSetString (ChartID(),buttonID,OBJPROP_FONT,font);
      ObjectSetString (ChartID(),buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_CORNER,btn_corner);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_HIDDEN,1);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(ChartID(),buttonID,OBJPROP_YDISTANCE,9999);
}
//+------------------------------------------------------------------------------------------------------------------+
int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);

//put deinit() here
ALL_OBJ_DELETE();

	return(0);
}
//+------------------------------------------------------------------------------------------------------------------+
void ALL_OBJ_DELETE()
{
   string name;
   for (int s=ObjectsTotal()-1; s>=0; s--) {
        name=ObjectName(s);
        if (StringSubstr(name,0,StringLen(PREF))==PREF) ObjectDelete(name); }  
}
//+++======================================================================+++
bool NewBarTF(int period) 
{
   datetime BarOpenTime=iTime(NULL,period,0);
   if (BarOpenTime!=LastBarOpenTime) {
       LastBarOpenTime=BarOpenTime;
       return (true); } 
   else 
       return (false);
}
//+++======================================================================+++
//don't change anything here
bool recalc = true;

void handleButtonClicks()
{
   if (ObjectGetInteger(ChartID(), buttonId, OBJPROP_STATE))
   {
      ObjectSetInteger(ChartID(), buttonId, OBJPROP_STATE, false);
      show_data = !show_data;
      GlobalVariableSet(IndicatorName + "_visibility", show_data ? 1.0 : 0.0);
      recalc = true;
      start();
   }
}
//+------------------------------------------------------------------------------------------------------------------+
void OnChartEvent(const int id, //don't change anything here
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   handleButtonClicks();
}
//+------------------------------------------------------------------------------------------------------------------+
int start()
{
   handleButtonClicks();
   recalc = false;
   //put start () here
   if (NewBarTF(PeriodGraphics)) ALL_OBJ_DELETE();  //PERIOD_D1
//------
   HIGH  = iHigh(NULL, PeriodGraphics, 1);   //PERIOD_D1
   LOW   = iLow(NULL, PeriodGraphics, 1);
   OPEN  = iOpen(NULL, PeriodGraphics, 1);
   CLOSE = iClose(NULL, PeriodGraphics, 1);
//------   //// enum calcPR { CO, OCLH, MEDIAN, TYPICAL, WEIGHTED };
   if (Price==0) MID = NormalizeDouble((CLOSE + OPEN) / 2, Digits);
   if (Price==1) MID = NormalizeDouble((OPEN + CLOSE + LOW + HIGH) / 4, Digits);
   if (Price==2) MID = NormalizeDouble((HIGH + LOW) / 2, Digits);
   if (Price==3) MID = NormalizeDouble((HIGH + LOW + CLOSE) / 3, Digits);
   if (Price==4) MID = NormalizeDouble((HIGH + LOW + 2 * CLOSE) / 4, Digits);
//------
   HI1 = NormalizeDouble(MID + stPIP * POINT, Digits);
   HI2 = NormalizeDouble(MID + 2 * stPIP * POINT, Digits);
   HI3 = NormalizeDouble(HI1 + MID - LOW - 5 * POINT, Digits);
   HI4 = NormalizeDouble(MID + (HIGH - LOW) + 5 * POINT, Digits);
   HI5 = NormalizeDouble(2 * MID + (HIGH - 2 * LOW) + 5 * POINT, Digits);
//------
   LO1 = NormalizeDouble(MID - stPIP * POINT, Digits);
   LO2 = NormalizeDouble(MID - 2 * stPIP * POINT, Digits);
   LO3 = NormalizeDouble(LO1 + MID - HIGH + 5 * POINT, Digits);
   LO4 = NormalizeDouble(MID - (HIGH - LOW) - 5 * POINT, Digits);
   LO5 = NormalizeDouble(2 * MID - (2 * HIGH - LOW) - 5 * POINT, Digits);
//------
   datetime timeD0 = iTime(NULL, PeriodGraphics, 0);
   datetime timeD1 = iTime(NULL, PeriodGraphics, 1);
   datetime timeCUR = iTime(NULL, 0, 0) + 3600*HowManyHoursToTheRight;
//------
   if (YesterdayHiLo) {
       creatTrendLineObj2("_YHI", timeD1, HIGH, timeCUR, HIGH, YesterdayColor, YesterdaySize, Yesterday);
       creatTrendLineObj2("_YLO", timeD1, LOW, timeCUR, LOW, YesterdayColor, YesterdaySize, Yesterday);
   //------
       if (TextSize>4) {
           datetime precur = timeD1;   if (TagsRight) precur = timeD0;
           if (ShowTextLabels)
           {
             createTextObj("_YHI_tx", precur, HIGH, StringConcatenate("[Previous High]: ", HIGH),ShiftPreviousHiLabel);  //Yesterday
             createTextObj("_YLO_tx", precur, LOW, StringConcatenate("[Previous Low]: ", LOW),ShiftPreviousLoLabel); } }  //Yesterday
           }
//------
   if (StartEndPeriod) {
       creatTrendLineObj2("_YStrt", timeD1, WindowPriceMin()-10*POINT, timeD1, WindowPriceMax()+10*POINT, DarkGray, 1, STYLE_DOT);
       creatTrendLineObj2("_YEnd", timeD0, WindowPriceMin()-10*POINT, timeD0, WindowPriceMax()+10*POINT, DarkGray, 1, STYLE_DOT);
       creatTrendLineObj2("_CEnd", timeD0+60*PeriodGraphics, WindowPriceMin()-10*POINT, timeD0+60*PeriodGraphics, WindowPriceMax()+10*POINT, DarkGray, 1, STYLE_DOT); }  //timeD0+3600*24
//------
   creatTrendLineObj("_HI5", timeD0, HI5, timeCUR, ColorHI, SizeHiLo);
   creatTrendLineObj("_HI4", timeD0, HI4, timeCUR, ColorHI, SizeHiLo);
   creatTrendLineObj("_HI3", timeD0, HI3, timeCUR, ColorHI, SizeHiLo);
   creatTrendLineObj("_HI2", timeD0, HI2, timeCUR, ColorHI, SizeHiLo);
   creatTrendLineObj("_HI1", timeD0, HI1, timeCUR, ColorHI, SizeHiLo);
//------
   creatTrendLineObj("_MID", timeD0, MID, timeCUR, ColorCenter, SizeCenter);  // центральная линия
//------
   creatTrendLineObj("_LO1", timeD0, LO1, timeCUR, ColorLO, SizeHiLo);
   creatTrendLineObj("_LO2", timeD0, LO2, timeCUR, ColorLO, SizeHiLo);
   creatTrendLineObj("_LO3", timeD0, LO3, timeCUR, ColorLO, SizeHiLo);
   creatTrendLineObj("_LO4", timeD0, LO4, timeCUR, ColorLO, SizeHiLo);
   creatTrendLineObj("_LO5", timeD0, LO5, timeCUR, ColorLO, SizeHiLo);
//------
   if (TextSize>4) 
    {
     precur = timeD0;   if (TagsRight) precur = timeCUR;
           if (ShowTextLabels)
           {
     createTextObj("_HI5_tx", precur, HI5, StringConcatenate("[DANGER! STOP BUY HERE!]: ", HI5),ShiftOtherLabels);
     createTextObj("_HI4_tx", precur, HI4, StringConcatenate("[WARNING! OVERBOUGHT]: ", HI4),ShiftOtherLabels);
     createTextObj("_HI3_tx", precur, HI3, StringConcatenate("[Reversal High]: ", HI3),ShiftOtherLabels);
     createTextObj("_HI2_tx", precur, HI2, StringConcatenate("[Buy Area] End: ", HI2),ShiftOtherLabels);
     createTextObj("_HI1_tx", precur, HI1, StringConcatenate("[Buy Area] Start: ", HI1),ShiftOtherLabels);
   //------
     createTextObj("_MID_tx",  precur, MID, StringConcatenate("[Middle Area]: ", MID),ShiftOtherLabels);
   //------
     createTextObj("_LO1_tx", precur, LO1, StringConcatenate("[Sell Area] Start: ", LO1),ShiftOtherLabels);
     createTextObj("_LO2_tx", precur, LO2, StringConcatenate("[Sell Area] End: ", LO2),ShiftOtherLabels);
     createTextObj("_LO3_tx", precur, LO3, StringConcatenate("[Reversal Low]: ", LO3),ShiftOtherLabels);
     createTextObj("_LO4_tx", precur, LO4, StringConcatenate("[WARNING! OVERSOLD]: ", LO4),ShiftOtherLabels);
     createTextObj("_LO5_tx", precur, LO5, StringConcatenate("[DANGER! STOP SELL HERE!]: ", LO5),ShiftOtherLabels);
           }
    }
//------
   if (InsidePips>0)
    {
     int PIPin = inPIP;   if (BeyondBoundaries) PIPin = 1;
   //------
     for (int x=1; x<stPIP/PIPin; x++) 
      {
       creatTrendLineObj(StringConcatenate("_inHiHi", x),  timeD0, HI1 + x * inPIP * POINT, timeCUR, ColorHI, 1);
       creatTrendLineObj(StringConcatenate("_inMidHi", x), timeD0, MID + x * inPIP * POINT, timeCUR, ColorCenter, 1);
       creatTrendLineObj(StringConcatenate("_inMidLo", x), timeD0, MID - x * inPIP * POINT, timeCUR, ColorCenter, 1);
       creatTrendLineObj(StringConcatenate("_inLoLo", x),  timeD0, LO1 - x * inPIP * POINT, timeCUR, ColorLO, 1);
      }
    }
//------
//------
  
      if (show_data)
         {
         ObjectSetInteger(ChartID(),buttonId,OBJPROP_COLOR,btn_text_ON_color);
         WindowRedraw();
         ChartRedraw();
         }
      else
      {
       ObjectSetInteger(ChartID(),buttonId,OBJPROP_COLOR,btn_text_OFF_color);
ALL_OBJ_DELETE();      }
   return(0);
}
//+------------------------------------------------------------------------------------------------------------------+
//+++======================================================================+++
//+++                        Golden MA MTF TT [x5]                         +++
//+++======================================================================+++
void creatTrendLineObj(string Name, int TM1, double PR1, int TM2, color CLR, int SIZE) 
{
   ObjectDelete(PREF+Name);
   ObjectCreate(PREF+Name, OBJ_TREND, 0, TM1, PR1, TM2, PR1);
   ObjectSet(PREF+Name, OBJPROP_COLOR, CLR);
   ObjectSet(PREF+Name, OBJPROP_WIDTH, SIZE);
   ObjectSet(PREF+Name, OBJPROP_RAY, false);
   ObjectSet(PREF+Name, OBJPROP_BACK, true);
   ObjectSet(PREF+Name, OBJPROP_HIDDEN, true);
   ObjectSet(PREF+Name, OBJPROP_SELECTABLE, false);
}
//+++======================================================================+++
//+++                        Golden MA MTF TT [x5]                         +++
//+++======================================================================+++
void creatTrendLineObj2(string Name, int TM1, double PR1, int TM2, double PR2, color CLR, int SIZE, int STL) 
{
   ObjectDelete(PREF+Name);
   ObjectCreate(PREF+Name, OBJ_TREND, 0, TM1, PR1, TM2, PR2);
   ObjectSet(PREF+Name, OBJPROP_COLOR, CLR);
   ObjectSet(PREF+Name, OBJPROP_WIDTH, SIZE);
   ObjectSet(PREF+Name, OBJPROP_STYLE, STL);
   ObjectSet(PREF+Name, OBJPROP_RAY, false);
   ObjectSet(PREF+Name, OBJPROP_BACK, true);
   ObjectSet(PREF+Name, OBJPROP_HIDDEN, true);
   ObjectSet(PREF+Name, OBJPROP_SELECTABLE, false);
}
//+++======================================================================+++
//+++                        Golden MA MTF TT [x5]                         +++
//+++======================================================================+++
void createTextObj(string Name, int TM1, double PR1, string TEXT, int PixelShiftOtherLabels) 
{
   ObjectDelete(PREF+Name);
//      ObjectCreate(nameLabel,OBJ_TEXT,0,Time[0]+Period()*60*ShiftOtherLabels,value);
   ObjectCreate(PREF+Name, OBJ_TEXT, 0, TM1+Period()*60*PixelShiftOtherLabels, PR1);
   ObjectSetText(PREF+Name, TEXT, TextSize, ШРИФТ);
   ObjectSet(PREF+Name, OBJPROP_COLOR, TextColor);
   ObjectSet(PREF+Name, OBJPROP_BACK, false);
   ObjectSet(PREF+Name, OBJPROP_HIDDEN, true);
   ObjectSet(PREF+Name, OBJPROP_SELECTABLE, false);
}
//+++======================================================================+++
//+++                        Golden MA MTF TT [x5]                         +++
//+++======================================================================+++
string stringMTF(int perMTF)
{  
   if (perMTF==0)     perMTF=_Period;
   if (perMTF==1)     return("M1");
   if (perMTF==5)     return("M5");
   if (perMTF==15)    return("M15");
   if (perMTF==30)    return("M30");
   if (perMTF==60)    return("H1");
   if (perMTF==240)   return("H4");
   if (perMTF==1440)  return("D1");
   if (perMTF==10080) return("W1");
   if (perMTF==43200) return("MN1");
   if (perMTF== 2 || 3  || 4  || 6  || 7  || 8  || 9 ||  /// нестандартные периоды для грфиков Renko
               10 || 11 || 12 || 13 || 14 || 16 || 17 || 18) return("M"+(string)_Period);
//------
   return("Period error!");
}
//+++======================================================================+++
//+++                        Golden MA MTF TT [x5]                         +++
//+++======================================================================+++