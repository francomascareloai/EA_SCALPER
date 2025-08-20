/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website:  HTt p: / /W WW . mE t A Q u OteS .Ne T
   E-mail :  s UppORT@ m ET aqU o t e S. N eT
*/
#property copyright "Domas4 and Traderathome - public domain code"
#property link      "email: traderathome@msn.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Green
#property indicator_color2 Maroon
#property indicator_color3 Lime
#property indicator_color4 Red
#property indicator_color5 CLR_NONE

extern bool Indicator_On = TRUE;
extern bool Use_For_Forex = TRUE;
extern bool Use_Day_Formula = TRUE;
extern string Exit_Period_Choices = "M1, M5, M15, M30, H1, H4, D1";
extern string Exit_If_Period_Greater_Than = "H1";
extern string _ = "";
extern string Part_1 = "Day Candle & Session Box Settings:";
extern bool Show_DayCandle = TRUE;
extern int Shift_DayCandle_right = 49;
extern bool Show_Today_Box = TRUE;
extern color Today_Box_Color = C'0x1E,0x21,0x24';
extern bool Show_Yesterday_Box = TRUE;
extern color Yesterday_Box_Color = C'0x14,0x12,0x29';
extern string __ = "";
extern string Part_2 = "Pivot Line Start/Stop Settings:";
extern string note1 = "Start with fullscreen lines, enter \'1\'";
extern string note2 = "Start lines at Day Separator, enter \'2\'";
extern string note3 = "Start lines at current candle, enter \'3\'";
extern int StartLines = 2;
extern bool StopLines_At_Current_Candle = FALSE;
extern string ___ = "";
extern string Part_3 = "Pivot Line Color & Selection Settings:";
extern color CentralPivot_Color = Blue;
extern int CP_LineStyle_01234 = 0;
extern int CP_SolidLine_Thickness = 1;
extern color Resistance_Pivots_Color = FireBrick;
extern int R_LineStyle_01234 = 0;
extern int R_SolidLineThickness = 1;
extern color Support_Pivots_Color = Green;
extern int S_LineStyle_01234 = 0;
extern int S_SolidLineThickness = 1;
extern bool Show_MidPivots = TRUE;
extern color MidPivots_Color = C'0x6C,0x6C,0x00';
extern int mP_LineStyle_01234 = 2;
extern int mP_SolidLineThickness = 1;
extern string ____ = "";
extern string Part_4 = "Pivot Label Settings:";
extern color PivotLabels_Color = DarkGray;
extern string PivotLabels_FontStyle = "Arial";
extern int PivotLabels_Fontsize = 9;
extern bool Show_Price_in_PivotLabels = TRUE;
extern string note4 = "Show_RightMargin_Prices and";
extern string note5 = "Shift_Pivotlabels_PerCent_Left";
extern string note6 = "work only when lines are fullscreen.";
extern bool Show_RightMargin_Prices = TRUE;
extern bool Preeminate_MarginLabels_Lines = TRUE;
extern int Shift_PivotLabels_PerCent_Left = 100;
extern bool Subordinate_Labels = FALSE;
extern string _____ = "";
extern string Part_5 = "Today Separator Settings:";
extern bool Show_Separator = TRUE;
extern color Separator_Color = C'0x6C,0x6C,0x00';
extern int Separator_LineStyle_01234 = 2;
extern int Separator_SolidLineThickness = 2;
extern bool Show_SeparatorLabel = TRUE;
extern color SeparatorLabel_Color = C'0x6C,0x6C,0x00';
extern string SeparatorLabel_FontStyle = "Arial Bold";
extern int SeparatorLabel_FontSize = 11;
extern int LabelOnChart_TopBot_12 = 2;
extern string ______ = "";
extern string Part_6 = "Data Comment Settings:";
extern bool Show_Data_Comment = TRUE;
extern color Data_Comment_Background_Color = C'0x0F,0x0F,0x0F';
extern int Days_Used_For_Range_Data = 30;
int Gi_420;
int Gi_424;
int Gi_428;
int Gi_432;
int Gi_436;
int Gi_440;
int Gi_444;
double Gd_448;
double Gd_456;
double Gd_464;
double Gd_472;
double Gd_480;
double Gd_488;
double Gd_496;
double Gd_504;
double Gd_512;
double Gd_520;
double Gd_528;
double Gd_536;
double Gd_544;
double Gd_552;
double Gd_560;
double Gda_568[];
double Gda_572[];
double Gda_576[];
double Gda_580[];
string Gs_592;

int init() {
   string Ls_0;
   if (Use_For_Forex) {
      Ls_0 = StringSubstr(Symbol(), 3, 3);
      if (Ls_0 == "JPY") Gi_420 = 2;
      else Gi_420 = 4;
   }
   SetIndexBuffer(0, Gda_568);
   SetIndexBuffer(1, Gda_572);
   SetIndexBuffer(2, Gda_580);
   SetIndexBuffer(3, Gda_576);
   if (Show_DayCandle) {
      for (int Li_8 = 0; Li_8 < 4; Li_8++) {
         SetIndexStyle(Li_8, DRAW_HISTOGRAM);
         SetIndexShift(Li_8, Shift_DayCandle_right);
         SetIndexLabel(Li_8, "[PivotsD] DayCandle");
      }
   } else for (Li_8 = 0; Li_8 < 4; Li_8++) SetIndexStyle(Li_8, DRAW_NONE);
   return (0);
}

int deinit() {
   string Ls_8;
   int Li_0 = ObjectsTotal();
   for (int Li_4 = Li_0; Li_4 >= 0; Li_4--) {
      Ls_8 = ObjectName(Li_4);
      if (StringSubstr(Ls_8, 0, 9) == "[PivotsD]") ObjectDelete(Ls_8);
   }
   Comment("");
   return (0);
}

int start() {
   int Li_0;
   string Ls_4;
   string Ls_12;
   string Ls_20;
   string Ls_28;
   string Ls_36;
   string Ls_44;
   string Ls_52;
   string Ls_60;
   string Ls_68;
   string Ls_76;
   string Ls_84;
   string Ls_92;
   string Ls_100;
   string Ls_108;
   string Ls_116;
   string Ls_124;
   string Ls_132;
   string Ls_140;
   string Ls_148;
   string Ls_156;
   string Ls_164;
   string Ls_172;
   string Ls_180;
   string Ls_188;
   string Ls_196;
   string Ls_204;
   string Ls_212;
   string Ls_220;
   string Ls_228;
   string Ls_236;
   string Ls_244;
   string Ls_252;
   string Ls_260;
   string Ls_268;
   string Ls_276;
   double Ld_288;
   double Ld_296;
   double Ld_304;
   double Ld_312;
   double Ld_320;
   double Ld_328;
   int Li_436;
   int Li_440;
   string Ls_448;
   int Li_456;
   int Li_460;
   int Li_464;
   int Li_468;
   int Li_472;
   int Li_476;
   string Ls_480;
   string Ls_488;
   string Ls_496;
   string Ls_504;
   int Li_512;
   string Ls_516;
   deinit();
   if (Indicator_On == FALSE) return (0);
   if (Exit_If_Period_Greater_Than == "M1") Li_0 = 1;
   if (Exit_If_Period_Greater_Than == "M5") Li_0 = 5;
   if (Exit_If_Period_Greater_Than == "M15") Li_0 = 15;
   if (Exit_If_Period_Greater_Than == "M30") Li_0 = 30;
   if (Exit_If_Period_Greater_Than == "H1") Li_0 = 60;
   if (Exit_If_Period_Greater_Than == "H4") Li_0 = 240;
   if (Exit_If_Period_Greater_Than == "D1") Li_0 = 1440;
   if (Period() > Li_0) {
      deinit();
      return (-1);
   }
   if (Use_Day_Formula) {
      Ls_4 = "    DPV";
      Ls_36 = "    DS1";
      Ls_60 = "    DR1";
      Ls_84 = "    DS2";
      Ls_108 = "    DR2";
      Ls_132 = "    DS3";
      Ls_156 = "    DR3";
      Ls_268 = "    m";
   } else {
      Ls_4 = "    FPV";
      Ls_36 = "    FS1";
      Ls_60 = "    FR1";
      Ls_84 = "    FS2";
      Ls_108 = "    FR2";
      Ls_132 = "    FS3";
      Ls_156 = "    FR3";
      Ls_180 = "    FS4";
      Ls_204 = "    FR4";
      Ls_228 = "    FS5";
      Ls_252 = "    FR5";
      Ls_268 = "    m";
   }
   Gi_424 = 1440;
   Gi_428 = iBarShift(NULL, Gi_424, Time[0]) + 1;
   Gi_444 = iTime(NULL, Gi_424, Gi_428);
   Gi_432 = TimeDayOfWeek(Gi_444);
   switch (Gi_432) {
   case 5:
      Ls_276 = "Monday";
      break;
   case 0:
      Gi_428 = iBarShift(NULL, Gi_424, Time[0]) + 2;
      Ls_276 = "Monday";
      break;
   case 1:
      Ls_276 = "Tuesday";
      break;
   case 2:
      Ls_276 = "Wednesday";
      break;
   case 3:
      Ls_276 = "Thursday";
      break;
   case 4:
      Ls_276 = "Friday";
   }
   Gd_472 = NormalizeDouble(iClose(NULL, Gi_424, Gi_428), 4);
   Gd_448 = NormalizeDouble(iHigh(NULL, Gi_424, Gi_428), 4);
   Gd_456 = NormalizeDouble(iLow(NULL, Gi_424, Gi_428), 4);
   Gd_464 = Gd_448 - Gd_456;
   Gd_480 = NormalizeDouble((Gd_448 + Gd_456 + Gd_472) / 3.0, 4);
   if (Use_Day_Formula) {
      Gd_488 = 2.0 * Gd_480 - Gd_456;
      Gd_496 = 2.0 * Gd_480 - Gd_448;
      Gd_504 = Gd_480 + (Gd_488 - Gd_496);
      Gd_512 = Gd_480 - (Gd_488 - Gd_496);
      Gd_520 = 2.0 * Gd_480 + (Gd_448 - 2.0 * Gd_456);
      Gd_528 = 2.0 * Gd_480 - (2.0 * Gd_448 - Gd_456);
   } else {
      Gd_552 = Gd_480 + 2.618 * Gd_464;
      Gd_536 = Gd_480 + 1.618 * Gd_464;
      Gd_520 = Gd_480 + Gd_464;
      Gd_504 = Gd_480 + 0.618 * Gd_464;
      Gd_488 = Gd_480 + Gd_464 / 2.0;
      Gd_496 = Gd_480 - Gd_464 / 2.0;
      Gd_512 = Gd_480 - 0.618 * Gd_464;
      Gd_528 = Gd_480 - Gd_464;
      Gd_544 = Gd_480 - 1.618 * Gd_464;
      Gd_560 = Gd_480 - 2.618 * Gd_464;
   }
   if (CP_LineStyle_01234 > 0) CP_SolidLine_Thickness = FALSE;
   if (R_LineStyle_01234 > 0) R_SolidLineThickness = FALSE;
   if (S_LineStyle_01234 > 0) S_SolidLineThickness = FALSE;
   drawLine("R3", Gd_520, Resistance_Pivots_Color, R_LineStyle_01234, R_SolidLineThickness);
   drawLabel(Ls_156, Gd_520, PivotLabels_Color);
   drawLine("R2", Gd_504, Resistance_Pivots_Color, R_LineStyle_01234, R_SolidLineThickness);
   drawLabel(Ls_108, Gd_504, PivotLabels_Color);
   drawLine("R1", Gd_488, Resistance_Pivots_Color, R_LineStyle_01234, R_SolidLineThickness);
   drawLabel(Ls_60, Gd_488, PivotLabels_Color);
   drawLine("PIVOT", Gd_480, CentralPivot_Color, CP_LineStyle_01234, CP_SolidLine_Thickness);
   drawLabel(Ls_4, Gd_480, PivotLabels_Color);
   drawLine("S1", Gd_496, Support_Pivots_Color, S_LineStyle_01234, S_SolidLineThickness);
   drawLabel(Ls_36, Gd_496, PivotLabels_Color);
   drawLine("S2", Gd_512, Support_Pivots_Color, S_LineStyle_01234, S_SolidLineThickness);
   drawLabel(Ls_84, Gd_512, PivotLabels_Color);
   drawLine("S3", Gd_528, Support_Pivots_Color, S_LineStyle_01234, S_SolidLineThickness);
   drawLabel(Ls_132, Gd_528, PivotLabels_Color);
   if (Use_Day_Formula == FALSE) {
      drawLine("R5", Gd_552, Resistance_Pivots_Color, R_LineStyle_01234, R_SolidLineThickness);
      drawLabel(Ls_252, Gd_552, PivotLabels_Color);
      drawLine("R4", Gd_536, Resistance_Pivots_Color, R_LineStyle_01234, R_SolidLineThickness);
      drawLabel(Ls_204, Gd_536, PivotLabels_Color);
      drawLine("S4", Gd_544, Support_Pivots_Color, S_LineStyle_01234, S_SolidLineThickness);
      drawLabel(Ls_180, Gd_544, PivotLabels_Color);
      drawLine("S5", Gd_560, Support_Pivots_Color, S_LineStyle_01234, S_SolidLineThickness);
      drawLabel(Ls_228, Gd_560, PivotLabels_Color);
   }
   if (Show_MidPivots) {
      if (mP_LineStyle_01234 > 0) mP_SolidLineThickness = FALSE;
      drawLine("MR3", (Gd_504 + Gd_520) / 2.0, MidPivots_Color, mP_LineStyle_01234, mP_SolidLineThickness);
      drawLabel(Ls_268 + "R3", (Gd_504 + Gd_520) / 2.0, PivotLabels_Color);
      drawLine("MR2", (Gd_488 + Gd_504) / 2.0, MidPivots_Color, mP_LineStyle_01234, mP_SolidLineThickness);
      drawLabel(Ls_268 + "R2", (Gd_488 + Gd_504) / 2.0, PivotLabels_Color);
      drawLine("MR1", (Gd_480 + Gd_488) / 2.0, MidPivots_Color, mP_LineStyle_01234, mP_SolidLineThickness);
      drawLabel(Ls_268 + "R1", (Gd_480 + Gd_488) / 2.0, PivotLabels_Color);
      drawLine("MS1", (Gd_480 + Gd_496) / 2.0, MidPivots_Color, mP_LineStyle_01234, mP_SolidLineThickness);
      drawLabel(Ls_268 + "S1", (Gd_480 + Gd_496) / 2.0, PivotLabels_Color);
      drawLine("MS2", (Gd_496 + Gd_512) / 2.0, MidPivots_Color, mP_LineStyle_01234, mP_SolidLineThickness);
      drawLabel(Ls_268 + "S2", (Gd_496 + Gd_512) / 2.0, PivotLabels_Color);
      drawLine("MS3", (Gd_512 + Gd_528) / 2.0, MidPivots_Color, mP_LineStyle_01234, mP_SolidLineThickness);
      drawLabel(Ls_268 + "S3", (Gd_512 + Gd_528) / 2.0, PivotLabels_Color);
      if (Use_Day_Formula == FALSE) {
         drawLine("MR5", (Gd_536 + Gd_552) / 2.0, MidPivots_Color, mP_LineStyle_01234, mP_SolidLineThickness);
         drawLabel(Ls_268 + "R5", (Gd_536 + Gd_552) / 2.0, PivotLabels_Color);
         drawLine("MR4", (Gd_520 + Gd_536) / 2.0, MidPivots_Color, mP_LineStyle_01234, mP_SolidLineThickness);
         drawLabel(Ls_268 + "R4", (Gd_520 + Gd_536) / 2.0, PivotLabels_Color);
         drawLine("MS4", (Gd_528 + Gd_544) / 2.0, MidPivots_Color, mP_LineStyle_01234, mP_SolidLineThickness);
         drawLabel(Ls_268 + "S4", (Gd_528 + Gd_544) / 2.0, PivotLabels_Color);
         drawLine("MS5", (Gd_544 + Gd_560) / 2.0, MidPivots_Color, mP_LineStyle_01234, mP_SolidLineThickness);
         drawLabel(Ls_268 + "S5", (Gd_544 + Gd_560) / 2.0, PivotLabels_Color);
      }
   }
   if (Show_Separator) {
      if (Show_SeparatorLabel) {
         Ld_288 = WindowPriceMax();
         Ld_296 = WindowPriceMin();
         Ld_304 = Ld_288 - Ld_296;
         Ld_312 = Ld_304 / 5000.0;
         Ld_320 = Ld_304 / (350 / SeparatorLabel_FontSize);
         Ld_328 = Ld_288 - Ld_312;
         if (LabelOnChart_TopBot_12 == 2) Ld_328 = Ld_296 + Ld_320;
      }
      Separator(" Today Separator", Ls_276, iTime(NULL, PERIOD_D1, 0), Separator_Color, Separator_LineStyle_01234, Separator_SolidLineThickness, Ld_328);
   }
   int Li_336 = MarketInfo(Symbol(), MODE_DIGITS);
   double Ld_340 = 1;
   if (Li_336 == 3 || Li_336 == 5) Ld_340 = 10.0;
   Gi_440 = iBarShift(NULL, PERIOD_D1, Time[0]);
   double Ld_348 = iHigh(NULL, PERIOD_D1, Gi_440);
   double Ld_356 = iLow(NULL, PERIOD_D1, Gi_440);
   double Ld_364 = iOpen(NULL, PERIOD_D1, Gi_440);
   double Ld_372 = iClose(NULL, PERIOD_D1, Gi_440);
   double Ld_380 = (Ld_372 - iOpen(NULL, PERIOD_D1, Gi_440)) / (Point * Ld_340);
   double Ld_388 = iTime(NULL, PERIOD_D1, Gi_440);
   double Ld_396 = iTime(NULL, 0, 0);
   Gi_436 = iBarShift(NULL, PERIOD_D1, Time[1380 / Period()]);
   double Ld_404 = iHigh(NULL, PERIOD_D1, Gi_436);
   double Ld_412 = iLow(NULL, PERIOD_D1, Gi_436);
   double Ld_420 = iTime(NULL, PERIOD_D1, Gi_436);
   double Ld_428 = iTime(NULL, PERIOD_D1, Gi_440);
   if (Show_DayCandle) {
      Li_436 = 0;
      if (Ld_380 > 0.0) {
         Gda_568[Li_436] = Ld_348;
         Gda_572[Li_436] = Ld_356;
      } else {
         Gda_568[Li_436] = Ld_356;
         Gda_572[Li_436] = Ld_348;
      }
      Gda_580[Li_436] = Ld_372;
      Gda_576[Li_436] = Ld_364 + 0.000001;
      Li_440 = 0;
      for (int Li_444 = Bars - 1; Li_440 < 4; Li_440++) SetIndexDrawBegin(Li_440, Li_444);
   }
   if (Show_Today_Box) colorTFbox("[PivotsD] TFBoxToday", Ld_388, Ld_396, Ld_348, Ld_356, Today_Box_Color);
   if (Show_Yesterday_Box) colorTFbox("[PivotsD] TFBoxYesterday", Ld_420, Ld_428, Ld_404, Ld_412, Yesterday_Box_Color);
   if (Show_Data_Comment) {
      Ls_448 = "[PivotsD] Data Box";
      ObjectCreate(Ls_448, OBJ_LABEL, 0, 0, 0, 0, 0);
      ObjectSetText(Ls_448, "g", 92, "Webdings");
      ObjectSet(Ls_448, OBJPROP_CORNER, 0);
      ObjectSet(Ls_448, OBJPROP_XDISTANCE, 0);
      ObjectSet(Ls_448, OBJPROP_YDISTANCE, 13);
      ObjectSet(Ls_448, OBJPROP_COLOR, Data_Comment_Background_Color);
      ObjectSet(Ls_448, OBJPROP_BACK, FALSE);
      Li_456 = 0;
      Li_460 = Days_Used_For_Range_Data;
      for (Li_440 = 0; Li_440 < Li_460; Li_440++) Li_456 = Li_456 + (iHigh(NULL, PERIOD_D1, Li_440) - iLow(NULL, PERIOD_D1, Li_440)) / Point;
      Li_456 = Li_456 / Li_460 + 1;
      Li_476 = Time[0] + 60 * Period() - TimeCurrent();
      Li_472 = Li_476 % 60;
      Ls_480 = Li_472;
      if (Li_472 < 10) Ls_480 = "0" + Ls_480;
      Li_468 = (Li_476 - Li_476 % 60) / 60;
      for (Li_440 = 0; Li_440 < 24; Li_440++) {
         if (Li_468 >= 60) {
            Li_468 -= 60;
            Li_464++;
         }
         Ls_488 = Li_468;
         if (Li_468 < 10) Ls_488 = "0" + Ls_488;
         Ls_496 = Li_464;
         if (Li_464 < 10) Ls_496 = "0" + Ls_496;
         Ls_504 = Ls_488 + ":" + Ls_480;
         if (Li_464 >= 1) Ls_504 = Ls_496 + ":" + Ls_488 + ":" + Ls_480;
         if (Period() > PERIOD_D1) Ls_504 = "OFF";
      }
      Li_512 = MarketInfo(Symbol(), MODE_SPREAD);
      Ls_516 = "\n --------  PivotsD_v5  --------\n";
      Ls_516 = Ls_516 + "   Range  Today:   " + DoubleToStr(MathRound((Ld_348 - Ld_356) / Point), 0) 
      + "\n";
      Ls_516 = Ls_516 + "         Yesterday:   " + DoubleToStr(MathRound((Ld_404 - Ld_412) / Point), 0) 
      + "\n";
      Ls_516 = Ls_516 + "   " + Days_Used_For_Range_Data + " Day Range:   " + Li_456 
      + "\n";
      Ls_516 = Ls_516 + "       Next Bar In:   " + Ls_504 
      + "\n";
      Ls_516 = Ls_516 + "             Spread:    " + Li_512 
      + "\n";
      Ls_516 = Ls_516 + "       Swap  Long:   " + DoubleToStr(MarketInfo(Symbol(), MODE_SWAPLONG), 2) 
      + "\n";
      Ls_516 = Ls_516 + "      Swap  Short:   " + DoubleToStr(MarketInfo(Symbol(), MODE_SWAPSHORT), 2) 
      + "\n";
      Comment(Ls_516);
   }
   return (0);
}

void drawLabel(string As_0, double Ad_8, color Ai_16) {
   bool Li_28;
   int Li_36;
   string Ls_44;
   string Ls_20 = "[PivotsD] " + As_0 + " Label";
   if (Use_For_Forex) Gs_592 = DoubleToStr(Ad_8, Gi_420);
   else Gs_592 = DoubleToStr(Ad_8, Digits);
   if (Show_Price_in_PivotLabels && StrToInteger(As_0) == 0) As_0 = As_0 + "   " + Gs_592;
   if (Shift_PivotLabels_PerCent_Left < 0) Shift_PivotLabels_PerCent_Left = 0;
   if (Shift_PivotLabels_PerCent_Left > 100) Shift_PivotLabels_PerCent_Left = 100;
   int Li_32 = WindowFirstVisibleBar() * Shift_PivotLabels_PerCent_Left / 100;
   int Li_40 = Time[1];
   if (Time[0] > iTime(NULL, PERIOD_D1, 0)) Li_40 = iTime(NULL, PERIOD_D1, 0);
   if (StartLines == 1) Li_28 = TRUE;
   if (StartLines == 2 && Li_40 <= iTime(NULL, 0, WindowFirstVisibleBar())) Li_28 = TRUE;
   if (Li_28 == TRUE) {
      Li_36 = Time[Li_32];
      if (Show_Price_in_PivotLabels) Ls_44 = "                                 ";
      else Ls_44 = "                 ";
   } else {
      if (Show_Price_in_PivotLabels) Ls_44 = "                              ";
      else Ls_44 = "              ";
      if (StartLines == 2) Li_36 = Li_40;
      else Li_36 = Time[0];
   }
   if (ObjectFind(Ls_20) != 0) {
      ObjectCreate(Ls_20, OBJ_TEXT, 0, Li_36, Ad_8);
      ObjectSetText(Ls_20, Ls_44 + As_0, PivotLabels_Fontsize, PivotLabels_FontStyle, Ai_16);
      ObjectSet(Ls_20, OBJPROP_BACK, FALSE);
      if (Subordinate_Labels) ObjectSet(Ls_20, OBJPROP_BACK, TRUE);
   } else ObjectMove(Ls_20, 0, Li_36, Ad_8);
}

void drawLine(string As_0, double Ad_8, color Ai_16, int Ai_20, int Ai_24) {
   int Li_60;
   int Li_64;
   bool Li_72;
   string Ls_28 = "[PivotsD] " + As_0 + " Line";
   int Li_36 = Ai_20;
   int Li_40 = Ai_24;
   int Li_44 = 1;
   if (Li_36 == STYLE_SOLID) Li_44 = Li_40;
   bool Li_48 = FALSE;
   bool Li_52 = TRUE;
   int Li_56 = 2;
   int Li_68 = Time[1];
   if (Time[1] >= iTime(NULL, PERIOD_D1, 0)) Li_68 = iTime(NULL, PERIOD_D1, 0);
   if (StartLines == 1) Li_72 = TRUE;
   if (StartLines == 2 && Li_68 <= iTime(NULL, 0, WindowFirstVisibleBar())) Li_72 = TRUE;
   if (Li_72 == TRUE) {
      Li_60 = iTime(NULL, 0, WindowFirstVisibleBar());
      Li_64 = Time[0];
      Li_48 = TRUE;
      if (Show_RightMargin_Prices) {
         Li_56 = 1;
         if (Preeminate_MarginLabels_Lines) Li_52 = FALSE;
      }
   } else {
      if (StartLines == 2) {
         Li_60 = Li_68;
         Li_64 = Time[0];
         Li_56 = 2;
         Li_48 = TRUE;
      } else {
         if (StartLines == 3) {
            Li_60 = Time[1];
            Li_64 = Time[0];
            Li_56 = 2;
            Li_48 = TRUE;
         }
      }
   }
   if (StopLines_At_Current_Candle && StartLines != 3) {
      Li_56 = 2;
      Li_48 = FALSE;
   }
   if (ObjectFind(Ls_28) != 0) {
      ObjectCreate(Ls_28, Li_56, 0, Li_60, Ad_8, Li_64, Ad_8);
      ObjectSet(Ls_28, OBJPROP_STYLE, Li_36);
      ObjectSet(Ls_28, OBJPROP_WIDTH, Li_44);
      ObjectSet(Ls_28, OBJPROP_COLOR, Ai_16);
      ObjectSet(Ls_28, OBJPROP_BACK, Li_52);
      ObjectSet(Ls_28, OBJPROP_RAY, Li_48);
      return;
   }
   ObjectMove(Ls_28, 0, Li_60, Ad_8);
   ObjectMove(Ls_28, 1, Li_64, Ad_8);
}

void colorTFbox(string As_0, double Ad_8, double Ad_16, double Ad_24, double Ad_32, color Ai_40) {
   string Ls_44 = "[PivotsD] " + As_0;
   if (ObjectFind(Ls_44) != 0) {
      ObjectCreate(Ls_44, OBJ_RECTANGLE, 0, 0, 0);
      ObjectSet(Ls_44, OBJPROP_TIME1, Ad_8);
      ObjectSet(Ls_44, OBJPROP_TIME2, Ad_16);
      ObjectSet(Ls_44, OBJPROP_PRICE1, Ad_24);
      ObjectSet(Ls_44, OBJPROP_PRICE2, Ad_32);
      ObjectSet(Ls_44, OBJPROP_COLOR, Ai_40);
      return;
   }
   ObjectMove(Ls_44, 1, Ad_8, Ad_24);
   ObjectMove(Ls_44, 0, Ad_16, Ad_32);
}

void Separator(string As_0, string As_8, int Ai_16, color Ai_20, int Ai_24, int Ai_28, double Ad_32) {
   int Li_40 = Ai_24;
   int Li_44 = Ai_28;
   int Li_48 = 1;
   if (Li_40 == STYLE_SOLID) Li_48 = Li_44;
   string Ls_52 = "[PivotsD] " + As_0;
   string Ls_60 = Ls_52 + " Label";
   if (ObjectFind(Ls_52) != 0) {
      ObjectCreate(Ls_52, OBJ_TREND, 0, Ai_16, 0, Ai_16, 100);
      ObjectSet(Ls_52, OBJPROP_STYLE, Li_40);
      ObjectSet(Ls_52, OBJPROP_WIDTH, Li_48);
      ObjectSet(Ls_52, OBJPROP_COLOR, Ai_20);
      ObjectSet(Ls_52, OBJPROP_BACK, TRUE);
   } else {
      ObjectMove(Ls_52, 0, Ai_16, 0);
      ObjectMove(Ls_52, 1, Ai_16, 100);
   }
   if (Show_SeparatorLabel) {
      if (ObjectFind(Ls_60) != 0) {
         ObjectCreate(Ls_60, OBJ_TEXT, 0, Ai_16, Ad_32);
         ObjectSetText(Ls_60, As_8, SeparatorLabel_FontSize, SeparatorLabel_FontStyle, SeparatorLabel_Color);
         ObjectSet(Ls_60, OBJPROP_BACK, FALSE);
         if (Subordinate_Labels) ObjectSet(Ls_60, OBJPROP_BACK, TRUE);
      } else ObjectMove(Ls_60, 0, Ai_16, Ad_32);
   }
}
