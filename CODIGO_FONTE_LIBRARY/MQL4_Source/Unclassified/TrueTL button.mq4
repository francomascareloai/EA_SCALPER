// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68781

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window

#include <WinUser32.mqh>
#import "user32.dll"
   int RegisterWindowMessageA(string a0);
#import

extern bool  Auto_Refresh               = TRUE;
extern int   Normal_TL_Period           = 500;
extern bool  Three_Touch                = TRUE;
extern bool  M1_Fast_Analysis           = TRUE;
extern bool  M5_Fast_Analysis           = TRUE;
extern bool  Mark_Highest_and_Lowest_TL = TRUE;
extern int   Expiration_Day_Alert       = 5;
extern color Normal_TL_Color            = clrDarkGreen;
extern color Long_TL_Color              = clrGoldenrod;
extern int   Three_Touch_TL_Widht       = 2;
extern color Three_Touch_TL_Color       = clrDimGray;
extern int   button_x                   = 20;
extern int   button_y                   = 30;
double ExtBuffer01;
//+------------------------------------------------------------------+
//Visibility controller v1.0
class VisibilityCotroller
{
   string buttonId;
   string visibilityId;
   bool   show_data;
   bool   recalc;
public:
//+------------------------------------------------------------------+
   void Init(string id, string indicatorName, string caption, int x, int y)
   {
      recalc = false;
      visibilityId = indicatorName + "_visibility";
      double val;
      if (GlobalVariableGet(visibilityId, val))
         show_data = val != 0;
         
      buttonId = id;
      ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
      createButton(buttonId, caption, 65, 20, "Impact", 8, clrDarkRed, clrBlack, clrWhite);
      ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, x);
      ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, y);
   }
//+------------------------------------------------------------------+
   bool HandleButtonClicks()
   {
      if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
      {
         ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
         show_data = !show_data;
         GlobalVariableSet(visibilityId, show_data ? 1.0 : 0.0);
         recalc = true;
         return true;
      }
      return false;
   }
//+------------------------------------------------------------------+
   bool IsRecalcNeeded()
   {
      return recalc;
   }
//+------------------------------------------------------------------+
   void ResetRecalc()
   {
      recalc = false;
   }
//+------------------------------------------------------------------+
   bool IsVisible()
   {
      return show_data;
   }
//+------------------------------------------------------------------+
private:
   void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
   {
      ObjectDelete(0,buttonID);
      ObjectCreate(0,buttonID,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
      ObjectSetString(0,buttonID,OBJPROP_FONT,font);
      ObjectSetString(0,buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,buttonID,OBJPROP_CORNER,2);
      ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
   }
};
//+------------------------------------------------------------------+
VisibilityCotroller _visibility;

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}
//+------------------------------------------------------------------+
int init() {
   IndicatorName = GenerateIndicatorName("TrueTL");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   _visibility.Init("_" + IndicatorObjPrefix + "CloseButton", "My indicator", "TrueTL", button_x, button_y);

   ObjectCreate(IndicatorObjPrefix + "calctl",    OBJ_HLINE, 0, 0, 0);
   ObjectCreate(IndicatorObjPrefix + "visibletl", OBJ_HLINE, 0, 0, 0);
   ObjectCreate(IndicatorObjPrefix + "downmax",   OBJ_TREND, 0, 0, 0, 0, 0);
   ObjectCreate(IndicatorObjPrefix + "upmax",     OBJ_TREND, 0, 0, 0, 0, 0);
   return (0);
}
//+------------------------------------------------------------------+
void Clean()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
}
//+------------------------------------------------------------------+
int deinit() {
   ObjectsDeleteAll(ChartID(), "_" + IndicatorObjPrefix);
   Clean();
   return (0);
}
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (_visibility.HandleButtonClicks())
      start();
}
//+------------------------------------------------------------------+
int start() {
   int TrendLine20;
   int Shift21;
   double doubleTrendLine22;
   int TrendLine23;
   int TrendLine24;
   double Semafor01;
   int Semafor02;
   double doubleSemafor03;
   int Semafor04;
   double doubleSemafor05;
   int wolf01;
   int wolf02;
   double wolf03;
   double wolf04;
   double wolf05;
   double Elliott01;
   double Elliott02;
   double Elliott03;
   double Elliott04;
   double Elliott05;
   double UpTrendLine01;
   double UpTrendLine02;
   double DownTrendLine01;
   int Counter01;
   int Counter02;
   if (Normal_TL_Period > 1000 || Normal_TL_Period < 100) 
      Normal_TL_Period = 500;

   _visibility.HandleButtonClicks();
   if (!_visibility.IsVisible())
   {
      ExtBuffer01 = 0;
      Clean();
      ObjectCreate(IndicatorObjPrefix + "calctl",    OBJ_HLINE, 0, 0, 0);
      ObjectCreate(IndicatorObjPrefix + "visibletl", OBJ_HLINE, 0, 0, 0);
      ObjectCreate(IndicatorObjPrefix + "downmax",   OBJ_TREND, 0, 0, 0, 0, 0);
      ObjectCreate(IndicatorObjPrefix + "upmax",     OBJ_TREND, 0, 0, 0, 0, 0);
      return 0;
   }
   bool refreshed = _visibility.IsRecalcNeeded();
   _visibility.ResetRecalc();

   int Mando = MathMax(0, WindowFirstVisibleBar() - WindowBarsPerChart());
   double maxbars01 = Bars;
   if (ExtBuffer01 == 0) 
      ExtBuffer01 = maxbars01;
   if (maxbars01 > ExtBuffer01) {
      ExtBuffer01 = maxbars01;
      if (Auto_Refresh == TRUE && Mando == 0) 
         ObjectSet(IndicatorObjPrefix + "calctl", OBJPROP_PRICE1, -1);
   }
   if (Auto_Refresh == TRUE && (IndicatorCounted() == 0 || refreshed)) 
      ObjectSet(IndicatorObjPrefix + "calctl", OBJPROP_PRICE1, -1);
   if (ObjectGet(IndicatorObjPrefix + "visibletl", OBJPROP_PRICE1) == -1.0) {
      for (int ForexStation = 0; ForexStation <= 100; ForexStation++) {
         ObjectDelete(IndicatorObjPrefix + "downtrendline" + IntegerToString(ForexStation));
         ObjectDelete(IndicatorObjPrefix + "uptrendline"   + IntegerToString(ForexStation));
         ObjectDelete(IndicatorObjPrefix + "downtrendline" + IntegerToString(ForexStation) + "tt");
         ObjectDelete(IndicatorObjPrefix + "uptrendline"   + IntegerToString(ForexStation) + "tt");
      }
   }
   if (ObjectGet(IndicatorObjPrefix + "calctl", OBJPROP_PRICE1) == -1.0 && ObjectGet("visibletl", OBJPROP_PRICE1) == 0.0) {
      for (int ForexStation = 0; ForexStation <= 100; ForexStation++) {
         ObjectDelete(IndicatorObjPrefix + "downtrendline" + IntegerToString(ForexStation));
         ObjectDelete(IndicatorObjPrefix + "uptrendline"   + IntegerToString(ForexStation));
         ObjectDelete(IndicatorObjPrefix + "downtrendline" + IntegerToString(ForexStation) + "tt");
         ObjectDelete(IndicatorObjPrefix + "uptrendline"   + IntegerToString(ForexStation) + "tt");
      }
      TrendLine20 = 150000;
      if (Period() == PERIOD_M1 && M1_Fast_Analysis == TRUE) TrendLine20 = 8000;
      if (Period() == PERIOD_M5 && M5_Fast_Analysis == TRUE) TrendLine20 = 2400;
      if (Period() == PERIOD_MN1) {
         TrendLine20 = 150;
         Three_Touch = FALSE;
         Normal_TL_Period = 150;
      }
      //Functions fmax(), fmin(), MathMax(), MathMin() can work with integer types without typecasting them to the type of double.
      //https://docs.mql4.com/math/mathmin
      Shift21 = Mando + MathMin(Bars - Mando - 10, TrendLine20);
      doubleTrendLine22 = iHigh(NULL, 0, Shift21);
      TrendLine24 = Mando + MathMin(Bars - Mando - 10, TrendLine20);
      Semafor01 = iHigh(NULL, 0, TrendLine24);
      for (int Line01 = 1; Line01 < 50; Line01++) {
         if ((iFractals(NULL, 0, MODE_UPPER, Mando + Line01) > 0.0 && Line01 > 2) || (Close[Mando + Line01 + 1] > Open[Mando + Line01 + 1] && Close[Mando + Line01 + 1] - (Low[Mando +
            Line01 + 1]) < 0.6 * (High[Mando + Line01 + 1] - (Low[Mando + Line01 + 1])) && Close[Mando + Line01] < Open[Mando + Line01]) || (Close[Mando + Line01 + 1] <= Open[Mando +
            Line01 + 1] && Close[Mando + Line01] < Open[Mando + Line01]) || (Close[Mando + Line01] < Open[Mando + Line01] && Close[Mando + Line01] < Low[Mando + Line01 + 1])) {
            TrendLine23 = Mando + Line01;
            break;
         }
      }
      for (int LineCounter01 = 1; LineCounter01 <= 30; LineCounter01++) {
         if (Shift21 > TrendLine23 + 6.0) {
            ObjectCreate(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01), OBJ_TREND, 0, iTime(NULL, 0, Shift21), doubleTrendLine22, iTime(NULL, 0, Shift21), doubleTrendLine22);
            for (int Line01 = Shift21; Line01 >= TrendLine23; Line01--) {
               if (ObjectGet(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01), OBJPROP_PRICE1) == ObjectGet(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01), OBJPROP_PRICE2)) {
                  ObjectMove(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01), 1, iTime(NULL, 0, Line01 - 1), iHigh(NULL, 0, Line01 - 1));
                  Shift21 = Line01 - 1;
                  doubleTrendLine22 = iHigh(NULL, 0, Line01 - 1);
               }
               //https://docs.mql4.com/objects/objectgetvaluebyshift == double
               doubleSemafor03 = ObjectGetValueByShift(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01), Line01);
               if (doubleSemafor03 < iHigh(NULL, 0, Line01)) {
                  ObjectMove(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01), 1, iTime(NULL, 0, Line01), iHigh(NULL, 0, Line01));
                  Shift21 = Line01;
                  doubleTrendLine22 = iHigh(NULL, 0, Line01);
               }
            }
         }
         if (ObjectGet(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01), OBJPROP_PRICE1) < ObjectGet(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01), OBJPROP_PRICE2)) ObjectDelete(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01));
         // https://docs.mql4.com/series/ibarshift = integer
         // https://docs.mql4.com/objects/objectget = double
         if (iBarShift(NULL, 0, ObjectGet(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01), OBJPROP_TIME1)) - Mando >= Normal_TL_Period) {
            ObjectSet(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01), OBJPROP_COLOR, Long_TL_Color);
            ObjectSetText(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01), "Long");
         } else {
            ObjectSet(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01), OBJPROP_COLOR, Normal_TL_Color);
            ObjectSetText(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01), "Normal");
         }
      }
      for (int Line01 = 1; Line01 < 50; Line01++) {
         if ((iFractals(NULL, 0, MODE_LOWER, Mando + Line01) > 0.0 && Line01 > 2) || (Close[Mando + Line01 + 1] < Open[Mando + Line01 + 1] && High[Mando + Line01 + 1] - (Close[Mando +
            Line01 + 1]) < 0.6 * (High[Mando + Line01 + 1] - (Low[Mando + Line01 + 1])) && Close[Mando + Line01] > Open[Mando + Line01]) || (Close[Mando + Line01 + 1] >= Open[Mando +
            Line01 + 1] && Close[Mando + Line01] > Open[Mando + Line01]) || (Close[Mando + Line01] > Open[Mando + Line01] && Close[Mando + Line01] > High[Mando + Line01 + 1])) {
            Semafor02 = Mando + Line01;
            break;
         }
      }
      for (int LineCounter01 = 1; LineCounter01 <= 30; LineCounter01++) {
         if (TrendLine24 > Semafor02 + 6.0) {
            ObjectCreate(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01), OBJ_TREND, 0, iTime(NULL, 0, TrendLine24), Semafor01, iTime(NULL, 0, TrendLine24), Semafor01);
            for (int Line01 = TrendLine24; Line01 >= Semafor02; Line01--) {
               if (ObjectGet(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01), OBJPROP_TIME1) == ObjectGet(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01), OBJPROP_TIME2)) {
                  ObjectMove(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01), 1, iTime(NULL, 0, Line01 - 1), iLow(NULL, 0, Line01 - 1));
                  TrendLine24 = Line01 - 1;
                  Semafor01 = iLow(NULL, 0, Line01 - 1);
               }
               doubleSemafor03 = ObjectGetValueByShift(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01), Line01);
               if (iLow(NULL, 0, Line01) < doubleSemafor03) {
                  ObjectMove(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01), 1, iTime(NULL, 0, Line01), iLow(NULL, 0, Line01));
                  TrendLine24 = Line01;
                  Semafor01 = iLow(NULL, 0, Line01);
               }
            }
         }
         if (ObjectGet(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01), OBJPROP_PRICE1) > ObjectGet(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01), OBJPROP_PRICE2)) ObjectDelete(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01));
         if (iBarShift(NULL, 0, ObjectGet(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01), OBJPROP_TIME1)) - Mando >= Normal_TL_Period) {
            ObjectSet(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01), OBJPROP_COLOR, Long_TL_Color);
            ObjectSetText(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01), "Long");
         } else {
            ObjectSet(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01), OBJPROP_COLOR, Normal_TL_Color);
            ObjectSetText(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01), "Normal");
         }
      }
      if (Three_Touch == TRUE && Bars > 1000) {
         for (int LineCounter01 = 1; LineCounter01 <= 30; LineCounter01++) {
            // https://docs.mql4.com/objects/objectget = double
            doubleSemafor05 = ObjectGet(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01), OBJPROP_TIME1);
            wolf01 = iBarShift(NULL, 0, NormalizeDouble(doubleSemafor05,0));
            Semafor04 = TrendLine23;
            wolf02 = wolf01 - Semafor04;
            if (wolf02 < MathMin(Normal_TL_Period, 1000) && wolf02 > 6.0) {
               ObjectCreate(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01) + "tt", OBJ_TREND, 0, iTime(NULL, 0, wolf01), iHigh(NULL, 0, wolf01), iTime(NULL, 0, Semafor04), iHigh(NULL, 0, Semafor04));
               ObjectSet(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01) + "tt", OBJPROP_WIDTH, 2);
               Elliott05 = iATR(NULL, 0, wolf02, Mando) / Point / 10.0;
               UpTrendLine01 = 8.0 * Elliott05;
               wolf03 = 0;
               wolf04 = 0.0;
               wolf05 = 0.0;
               for (int aCounter001 = Semafor04; aCounter001 <= wolf01; aCounter001++) {
                  if (wolf04 == 0.0 && wolf05 >= 3.0 && aCounter001 > Semafor04) {
                     Elliott03 = 0;
                     Elliott04 = ObjectGet(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01) + "tt", OBJPROP_PRICE2);
                     for (int YetCounter01 = 1; YetCounter01 <= 5; YetCounter01++) {
                        if (Elliott03 >= 3.0) wolf03 = 1;
                        if (wolf03 == 0.0) {
                           ObjectSet(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01) + "tt", OBJPROP_PRICE2, Elliott04 + (YetCounter01 - 3) * Point);
                           Elliott03 = 0;
                           for (int YetCounter02 = Semafor04; YetCounter02 <= wolf01; YetCounter02++) {
                              doubleSemafor03 = ObjectGetValueByShift(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01) + "tt", YetCounter02);
                              if (doubleSemafor03 + Elliott05 * Point > iHigh(NULL, 0, YetCounter02) && doubleSemafor03 - Elliott05 * Point < iHigh(NULL, 0, YetCounter02)) {
                                 Elliott03++;
                                 YetCounter02++;
                              }
                           }
                        }
                     }
                  }
                  if (wolf03 == 0.0 && aCounter001 == wolf01) ObjectDelete(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01) + "tt");
                  if (wolf03 == 1.0 && aCounter001 == wolf01) {
                     Elliott01 = ObjectGetValueByShift(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01), Semafor04);
                     Elliott02 = ObjectGetValueByShift(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01) + "tt", Semafor04);
                     if (MathAbs(Elliott01 - Elliott02) > UpTrendLine01 * Point) ObjectDelete(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01) + "tt");
                  }
                  if (wolf03 == 0.0 && aCounter001 <= wolf01) ObjectMove(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01) + "tt", 1, iTime(NULL, 0, aCounter001), iHigh(NULL, 0, aCounter001));
                  if (wolf03 == 0.0) {
                     wolf04 = 0.0;
                     wolf05 = 0.0;
                     for (int Line01 = Semafor04; Line01 <= wolf01; Line01++) {
                        doubleSemafor03 = ObjectGetValueByShift(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01) + "tt", Line01);
                        if (iClose(NULL, 0, Line01) > ObjectGetValueByShift(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01) + "tt", Line01)) wolf04++;
                        if (doubleSemafor03 + 2.0 * Elliott05 * Point > iHigh(NULL, 0, Line01) && doubleSemafor03 - 2.0 * Elliott05 * Point < iHigh(NULL, 0, Line01)) {
                           wolf05++;
                           Line01++;
                        }
                     }
                  }
               }
            }
         }
         for (int LineCounter01 = 1; LineCounter01 <= 30; LineCounter01++) {
            doubleSemafor05 = ObjectGet(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01), OBJPROP_TIME1);
            wolf01 = iBarShift(NULL, 0, NormalizeDouble(doubleSemafor05,0));
            Semafor04 = Semafor02;
            wolf02 = wolf01 - Semafor04;
            if (wolf02 < MathMin(Normal_TL_Period, 1000) && wolf02 > 6.0) {
               ObjectCreate(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01) + "tt", OBJ_TREND, 0, iTime(NULL, 0, wolf01), iLow(NULL, 0, wolf01), iTime(NULL, 0, wolf01), iLow(NULL, 0, wolf01));
               ObjectSet(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01) + "tt", OBJPROP_WIDTH, 2);
               Elliott05 = iATR(NULL, 0, wolf02, Mando) / Point / 10.0;
               UpTrendLine01 = 8.0 * Elliott05;
               wolf03 = 0;
               wolf05 = 0.0;
               for (int aCounter001 = Semafor04; aCounter001 <= wolf01; aCounter001++) {
                  if (wolf04 == 0.0 && wolf05 >= 3.0 && aCounter001 > Semafor04 && wolf03 == 0.0) {
                     Elliott03 = 0;
                     Elliott04 = ObjectGet(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01) + "tt", OBJPROP_PRICE2);
                     for (int YetCounter01 = 1; YetCounter01 <= 5; YetCounter01++) {
                        if (Elliott03 >= 3.0) wolf03 = 1;
                        if (wolf03 == 0.0) {
                           ObjectSet(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01) + "tt", OBJPROP_PRICE2, Elliott04 + (YetCounter01 - 3) * Point);
                           Elliott03 = 0;
                           for (int YetCounter02 = Semafor04; YetCounter02 <= wolf01; YetCounter02++) {
                              doubleSemafor03 = ObjectGetValueByShift(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01) + "tt", YetCounter02);
                              if (doubleSemafor03 + Elliott05 * Point > iLow(NULL, 0, YetCounter02) && doubleSemafor03 - Elliott05 * Point < iLow(NULL, 0, YetCounter02)) {
                                 Elliott03++;
                                 YetCounter02++;
                              }
                           }
                        }
                     }
                  }
                  if (wolf03 == 0.0 && aCounter001 == wolf01) ObjectDelete(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01) + "tt");
                  if (wolf03 == 1.0 && aCounter001 == wolf01) {
                     Elliott01 = ObjectGetValueByShift(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01), Semafor04);
                     Elliott02 = ObjectGetValueByShift(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01) + "tt", Semafor04);
                     if (MathAbs(Elliott01 - Elliott02) > UpTrendLine01 * Point) ObjectDelete(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01) + "tt");
                  }
                  if (wolf03 == 0.0 && aCounter001 < wolf01) ObjectMove(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01) + "tt", 1, iTime(NULL, 0, aCounter001), iLow(NULL, 0, aCounter001));
                  if (wolf03 == 0.0) {
                     wolf04 = 0.0;
                     wolf05 = 0.0;
                     for (int Line01 = Semafor04; Line01 <= wolf01; Line01++) {
                        doubleSemafor03 = ObjectGetValueByShift(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01) + "tt", Line01);
                        if (iClose(NULL, 0, Line01) < ObjectGetValueByShift(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01) + "tt", Line01)) wolf04++;
                        if (doubleSemafor03 + 2.0 * Elliott05 * Point > iLow(NULL, 0, Line01) && doubleSemafor03 - 2.0 * Elliott05 * Point < iLow(NULL, 0, Line01)) {
                           wolf05++;
                           Line01++;
                        }
                     }
                  }
               }
            }
         }
         for (int Line01 = 0; Line01 <= 30; Line01++) {
            if (ObjectGetValueByShift(IndicatorObjPrefix + "uptrendline" + IntegerToString(Line01) + "tt", Mando + 1) > 0.0) {
               ObjectSet(IndicatorObjPrefix + "uptrendline" + IntegerToString(Line01), OBJPROP_WIDTH, Three_Touch_TL_Widht);
               ObjectSet(IndicatorObjPrefix + "uptrendline" + IntegerToString(Line01), OBJPROP_COLOR, Three_Touch_TL_Color);
               ObjectSetText(IndicatorObjPrefix + "uptrendline" + IntegerToString(Line01), "3t");
               ObjectDelete(IndicatorObjPrefix + "uptrendline" + IntegerToString(Line01) + "tt");
            }
         }
         for (int Line01 = 0; Line01 <= 30; Line01++) {
            if (ObjectGetValueByShift(IndicatorObjPrefix + "downtrendline" + IntegerToString(Line01) + "tt", Mando + 1) > 0.0) {
               ObjectSet(IndicatorObjPrefix + "downtrendline" + IntegerToString(Line01), OBJPROP_WIDTH, Three_Touch_TL_Widht);
               ObjectSet(IndicatorObjPrefix + "downtrendline" + IntegerToString(Line01), OBJPROP_COLOR, Three_Touch_TL_Color);
               ObjectSetText(IndicatorObjPrefix + "downtrendline" + IntegerToString(Line01), "3t");
               ObjectDelete(IndicatorObjPrefix + "downtrendline" + IntegerToString(Line01) + "tt");
            }
         }
      }
      for (int LineCounter01 = 0; LineCounter01 <= 30; LineCounter01++) {
         if (ObjectGet(IndicatorObjPrefix + "downtrendline" + IntegerToString(((LineCounter01 - 1))), OBJPROP_PRICE1) == 0.0 && ObjectGet(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01), OBJPROP_PRICE1) > 0.0 && Mark_Highest_and_Lowest_TL == TRUE) {
            ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_TIME1, iTime(NULL, 0, Mando + 6));
            ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_PRICE1, ObjectGetValueByShift(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01), Mando + 6));
            ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_TIME2, iTime(NULL, 0, Mando + 3));
            ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_PRICE2, ObjectGetValueByShift(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01), Mando + 3));
            ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_COLOR, ObjectGet(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01), OBJPROP_COLOR));
            ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_WIDTH, 5);
            ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_STYLE, STYLE_SOLID);
            ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_RAY, FALSE);
            ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_BACK, FALSE);
         }
         if (ObjectGet(IndicatorObjPrefix + "uptrendline" + IntegerToString(((LineCounter01 - 1))), OBJPROP_PRICE1) == 0.0 && ObjectGet(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01), OBJPROP_PRICE1) > 0.0 && Mark_Highest_and_Lowest_TL == TRUE) {
            ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_TIME1, iTime(NULL, 0, Mando + 6));
            ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_PRICE1, ObjectGetValueByShift(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01), Mando + 6));
            ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_TIME2, iTime(NULL, 0, Mando + 3));
            ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_PRICE2, ObjectGetValueByShift(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01), Mando + 3));
            ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_COLOR, ObjectGet(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01), OBJPROP_COLOR));
            ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_WIDTH, 5);
            ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_STYLE, STYLE_SOLID);
            ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_RAY, FALSE);
            ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_BACK, FALSE);
         }
      }
      UpTrendLine02 = 0;
      DownTrendLine01 = 0;
      for (int LineCounter01 = 1; LineCounter01 <= 30; LineCounter01++) {
         UpTrendLine02 += ObjectGet(IndicatorObjPrefix + "downtrendline" + IntegerToString(LineCounter01), OBJPROP_PRICE1);
         DownTrendLine01 += ObjectGet(IndicatorObjPrefix + "uptrendline" + IntegerToString(LineCounter01), OBJPROP_PRICE1);
      }
      if (UpTrendLine02 == 0.0) {
         ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_TIME1, 0);
         ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_PRICE1, 0);
         ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_TIME2, 0);
         ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_PRICE2, 0);
      }
      if (DownTrendLine01 == 0.0) {
         ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_TIME1, 0);
         ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_PRICE1, 0);
         ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_TIME2, 0);
         ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_PRICE2, 0);
      }
      ObjectSet(IndicatorObjPrefix + "calctl", OBJPROP_PRICE1, 0);
   }
   if (Auto_Refresh == TRUE && (IndicatorCounted() == 0 || refreshed)) {
      ObjectSet(IndicatorObjPrefix + "calctl", OBJPROP_PRICE1, -1);
      Counter01 = WindowHandle(Symbol(), Period());
      Counter02 = RegisterWindowMessageA("MetaTrader4_Internal_Message");
      PostMessageA(Counter01, Counter02, 2, 1);
   }
   return (0);
}