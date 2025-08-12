#property indicator_chart_window

string gs_76 = "";
extern string Custom_Indicator = "";
extern string Label0 = "";
extern string Input_Days = "Enter number of days to calculate.";
extern int Day_x = 5;
extern string Label1 = "=== Corner settings ===";
extern string Upper_Corner_Help = "0 = Upper Left, 1 = Right";
extern string Lower_Corner_Help = "2 = Lower Left, 3 = Right";
extern int Corner = 2;
extern string Label2 = "=== Color settings ===";
extern string Color_Help = "Select ADR color:";
extern color ADR_Color = Goldenrod;
extern color Daily_High_Color = LimeGreen;
extern color Daily_Low_Color = Fuchsia;
extern string Label3 = "=== Display settings ===";
extern string Display_Help = "Enter Yes or No";
extern string Show_Daily_High_Low_Lines = "Yes";
extern string Show_Weekly_Lines = "Yes";
extern string Show_Mini_ADR = "No";
extern string Label4 = "=== Font settings ===";
extern string Font_Size_Help = "Font size can be 6 to 14";
extern int Font_Size = 8;
extern int Vertical_Spacing_Adjustment = 0;
int gia_248[34][2];
int gi_252 = 1;
int gi_256 = 100;
int gi_260 = 3;
bool gi_268 = TRUE;
int gi_unused_272 = 5;
int gi_unused_276 = 15;
double gd_280;
double gd_288;
string gs_296 = "";
string gs_304 = "";
string gs_312;
string gs_320;
string gs_328;
string gs_336;
string gs_344;
string gs_352;
string gs_360;
string g_dbl2str_368;
string g_dbl2str_376;
string g_dbl2str_384;
string g_dbl2str_392;
string g_dbl2str_400;
string gs_408;
string gs_416;
string gs_424;
string gs_432;
string gs_440;
string gs_448;
string gs_456;
string gs_464;
string g_dbl2str_472;
string g_dbl2str_480;
string g_dbl2str_488;
string g_dbl2str_496;
string g_dbl2str_504;
string g_dbl2str_512;
string g_dbl2str_520;
string g_dbl2str_528;
string gs_536 = "";
int gi_544;
bool gi_548;
bool gi_552;
int gi_556;
bool gi_560 = TRUE;
int g_time_564 = 0;
bool gi_568 = TRUE;
int gi_unused_572 = 0;
int g_time_576 = 0;

int init() {
   string ls_unused_0;
   string str_concat_8 = StringConcatenate(gs_536, gs_76);
   gs_536 = Decrypt(str_concat_8);
   if (gi_260 > 3) gi_260 = 3;
   if (Font_Size < 6) Font_Size = 6;
   else
      if (Font_Size > 14) Font_Size = 14;
   if (Corner < 0) Corner = 0;
   else
      if (Corner > 3) Corner = 3;
   gi_544 = IsYes(Show_Weekly_Lines);
   gi_548 = IsYes(Show_Mini_ADR);
   gi_552 = IsYes(Show_Daily_High_Low_Lines);
   DeleteObjs();
   if (Digits == 5 || Digits == 3) gi_556 = 10;
   else gi_556 = 1;
   return (0);
}

int deinit() {
   DeleteObjs();
   return (0);
}

int start() {
   if (!gi_268) return (0);
   if (!gi_548) NormalDisplay();
   else MiniDisplay();
   if (gi_544 && Period() < PERIOD_W1) ShowWeekLines();
   return (0);
}

void NormalDisplay() {
   int day_of_week_56;
   double ld_148;
   double ld_0 = 0;
   double ld_8 = 0;
   double ld_16 = 0;
   double ld_24 = 0;
   double ilow_32 = 0;
   double ihigh_40 = 0;
   int li_48 = 0;
   if (gi_560) {
      //SetTextData();
      //createLabelObjects();
      gi_560 = FALSE;
   }
   double ld_76 = 0;
   double ld_116 = 0;
   double ld_124 = 0;
   double ld_132 = 0;
   double ld_140 = 0;
   double ld_68 = (iHigh(NULL, PERIOD_D1, 1) - iLow(NULL, PERIOD_D1, 1)) / Point;
   ld_24 = 0.0;
   double ld_84 = 0.0;
   double ld_92 = 0.0;
   ld_76 = 0.0;
   int count_52 = 0;
   int count_60 = 0;
   int count_64 = 0;
   for (li_48 = 1; li_48 < 220; li_48++) {
      count_52++;
      if (count_52 > 220) break;
      day_of_week_56 = TimeDayOfWeek(iTime(NULL, PERIOD_D1, li_48));
      if (day_of_week_56 != 0) {
         if (day_of_week_56 == 5 && count_64 == 0) count_64 = 1;
         count_60++;
         ld_148 = iHigh(NULL, PERIOD_D1, li_48) - iLow(NULL, PERIOD_D1, li_48);
         if (count_60 <= Day_x) ld_24 += ld_148;
         if (count_64 > 0 && count_64 <= 5) {
            ld_76 += ld_148;
            count_64++;
         }
         if (count_60 <= 22) ld_84 += ld_148;
         if (count_60 <= 180) ld_92 += ld_148;
         if (count_60 >= 180) break;
      }
   }
   double ld_100 = NormalizeDouble(ld_24 / Day_x / Point, 0);
   ld_0 = NormalizeDouble(ld_100 / 2.0 * Point, Digits);
   ld_76 = NormalizeDouble(0.2 * ld_76 / Point, 0);
   ld_84 = NormalizeDouble(ld_84 / 22.0 / Point, 0);
   ld_92 = NormalizeDouble(ld_92 / 180.0 / Point, 0);
   ilow_32 = iLow(NULL, PERIOD_D1, 0);
   ihigh_40 = iHigh(NULL, PERIOD_D1, 0);
   ld_116 = (ihigh_40 - Ask) / Point;
   ld_124 = (Bid - ilow_32) / Point;
   ld_8 = iOpen(NULL, PERIOD_D1, 0) + ld_0;
   ld_16 = iOpen(NULL, PERIOD_D1, 0) - ld_0;
   ld_132 = (ld_8 - Ask) / Point;
   ld_140 = (Bid - ld_16) / Point;
   g_dbl2str_368 = DoubleToStr(ld_100 / gi_556, 0);
   g_dbl2str_376 = DoubleToStr(ld_68 / gi_556, 0);
   g_dbl2str_384 = DoubleToStr(ld_76 / gi_556, 0);
   g_dbl2str_392 = DoubleToStr(ld_84 / gi_556, 0);
   g_dbl2str_400 = DoubleToStr(ld_92 / gi_556, 0);
   g_dbl2str_472 = DoubleToStr(ld_8, Digits);
   g_dbl2str_480 = DoubleToStr(ihigh_40, Digits);
   g_dbl2str_488 = DoubleToStr(ilow_32, Digits);
   g_dbl2str_496 = DoubleToStr(ld_16, Digits);
   g_dbl2str_504 = DoubleToStr(ld_116 / gi_556, 0);
   g_dbl2str_512 = DoubleToStr(ld_132 / gi_556, 0);
   g_dbl2str_520 = DoubleToStr(ld_124 / gi_556, 0);
   g_dbl2str_528 = DoubleToStr(ld_140 / gi_556, 0);
   if (gi_552) DoADRHighLowLines(ld_8, ld_16);
   updateText();
}

void DoADRHighLowLines(double ad_0, double ad_8) {
   if (g_time_564 != Time[0]) {
      CreateHTLine("TextPlace_ADRHighLine", "ADR High", 0, ad_0, 0, ad_0, STYLE_SOLID, 3, Daily_High_Color, TRUE, FALSE);
      CreateHTLine("TextPlace_ADRLowLine", "ADR Low", 0, ad_8, 0, ad_8, STYLE_SOLID, 3, Daily_Low_Color, TRUE, FALSE);
      g_time_564 = Time[0];
   }
}

void MiniDisplay() {
   int day_of_week_8;
   string ls_unused_64;
   string ls_unused_72;
   double ld_84;
   int li_100;
   int li_104;
   int li_108;
   int li_unused_116;
   int count_4 = 0;
   double ld_16 = 0.0;
   string ls_40 = StringSubstr(gs_536, 16);
   string str_concat_48 = StringConcatenate("ADR Pro Calculator", ls_40);
   string ls_unused_56 = "";
   switch (Font_Size) {
   case 6:
      gi_252 = 0;
      break;
   case 7:
      gi_252 = 0;
      break;
   case 8:
      gi_252 = 2;
      break;
   case 9:
      gi_252 = 3;
      break;
   case 10:
      gi_252 = 4;
      break;
   case 11:
      gi_252 = 5;
      break;
   case 12:
      gi_252 = 7;
      break;
   case 13:
      gi_252 = 7;
      break;
   case 14:
      gi_252 = 8;
   }
   gi_252 += Vertical_Spacing_Adjustment;
   int li_0 = 1;
   count_4 = 0;
   int count_12 = 0;
   ld_16 = 0.0;
   for (li_0 = 1; li_0 < 10; li_0++) {
      count_4++;
      if (count_4 > 10) break;
      day_of_week_8 = TimeDayOfWeek(iTime(NULL, PERIOD_D1, li_0));
      if (day_of_week_8 != 0) {
         count_12++;
         ld_84 = iHigh(NULL, PERIOD_D1, li_0) - iLow(NULL, PERIOD_D1, li_0);
         if (count_12 <= Day_x) ld_16 += ld_84;
         if (count_12 >= Day_x) break;
      }
   }
   ld_16 /= Day_x;
   double ld_24 = iOpen(NULL, PERIOD_D1, 0) + ld_16 / 2.0;
   double ld_32 = iOpen(NULL, PERIOD_D1, 0) - ld_16 / 2.0;
   string str_concat_92 = StringConcatenate("ADR: ", Day_x, " days / ", DoubleToStr(ld_16 / gi_556 / Point, 0), " pips | ADR H/L: ", DoubleToStr(ld_24, Digits), " / ",
      DoubleToStr(ld_32, Digits));
   if (gi_568) {
      ObjectDelete("TextPlace_mini1");
      ObjectDelete("TextPlace_mini2");
      count_4 = 0;
      switch (Corner) {
      case 0:
         li_100 = 15;
         li_104 = gi_252 + 27;
         li_108 = 5;
         break;
      case 1:
         li_100 = 15;
         li_104 = gi_252 + 27;
         li_108 = 15;
         break;
      case 2:
         li_100 = gi_252 + 20;
         li_104 = 8;
         li_108 = 5;
         break;
      case 3:
         li_100 = gi_252 + 20;
         li_104 = 8;
         li_108 = 15;
      }
      li_unused_116 = 0;
      myObjCreate("TextPlace_mini1", li_108, li_100, str_concat_48);
      myObjCreate("TextPlace_mini2", li_108, li_104, str_concat_92);
      gi_568 = FALSE;
   }
   ObjectSetText("TextPlace_mini1", str_concat_48, Font_Size, "Tahoma", ADR_Color);
   ObjectSetText("TextPlace_mini2", str_concat_92, Font_Size, "Tahoma", ADR_Color);
   if (gi_552) DoADRHighLowLines(ld_24, ld_32);
}

void ShowWeekLines() {
   int li_8;
   int day_of_week_12;
   int count_16;
   double ld_28;
   double iclose_36;
   double ld_44;
   int li_56;
   int li_60;
   double ld_64;
   double ld_72;
   double ld_80;
   double ld_88;
   double ld_96;
   double ld_104;
   double ld_112;
   double ld_120;
   double ld_128;
   double ld_136;
   int li_unused_0 = 0;
   int li_4 = 0;
   string ls_unused_20 = "";
   if (Time[0] != g_time_576) {
      if (TimeDayOfWeek(iTime(NULL, PERIOD_D1, li_4)) > 5 && TimeDayOfWeek(iTime(NULL, PERIOD_D1, li_4)) < 1) Alert("ADR Template ", Symbol(), "  Waiting for start of week at 5:00 PM Eastern.");
      else {
         li_8 = 0;
         for (li_4 = 1; li_4 <= 12; li_4++) {
            if (li_8 == 0 && TimeDayOfWeek(iTime(NULL, PERIOD_D1, li_4)) == 5) {
               li_8 = li_4;
               break;
            }
         }
         iclose_36 = iClose(NULL, PERIOD_D1, li_8);
         ld_28 = 0.0;
         for (li_8 = li_4; li_8 <= li_4 + 4; li_8++) ld_28 += iHigh(NULL, PERIOD_D1, li_8) - iLow(NULL, PERIOD_D1, li_8);
         ld_28 = MathRound(ld_28 / 5.0 / Point / gi_556);
         g_time_576 = Time[0];
         ld_44 = 0.0;
         li_4 = 1;
         li_8 = 0;
         count_16 = 0;
         for (li_4 = 1; li_4 < 35; li_4++) {
            li_8++;
            if (li_8 > 35) break;
            day_of_week_12 = TimeDayOfWeek(iTime(NULL, PERIOD_D1, li_4));
            if (day_of_week_12 != 0) {
               ld_44 += iHigh(NULL, PERIOD_D1, li_4) - iLow(NULL, PERIOD_D1, li_4);
               count_16++;
               if (count_16 >= 22) break;
            }
         }
         ld_44 = MathRound(ld_44 / 22.0 / Point / gi_556);
         li_56 = (ld_28 + ld_44) / 2.0;
         li_60 = li_56 / 2;
         ld_64 = iclose_36 + li_56 * Point * gi_556;
         CreateHTLine("TextPlace_WklyHigh", "Wk Hi    ", gi_256, ld_64, 0, ld_64, STYLE_SOLID, 2, Green, TRUE, FALSE);
         ld_72 = iclose_36 - li_56 * Point * gi_556;
         CreateHTLine("TextPlace_WklyLow", "Wk Lo    ", gi_256, ld_72, 0, ld_72, STYLE_SOLID, 2, Red, TRUE, FALSE);
         ld_80 = iclose_36 + li_60 * Point * gi_556;
         CreateHTLine("TextPlace_WklyMidHigh", "Wk Mid Hi", gi_256, ld_80, 0, ld_80, STYLE_SOLID, 2, MediumSeaGreen, TRUE, FALSE);
         ld_88 = iclose_36 - li_60 * Point * gi_556;
         CreateHTLine("TextPlace_WklyMidLow", "Wk Mid Lo", gi_256, ld_88, 0, ld_88, STYLE_SOLID, 2, MediumVioletRed, TRUE, FALSE);
         ld_96 = ld_64 + li_60 * Point * gi_556;
         CreateHTLine("TextPlace_WklyExtHigh_1", "Wk Ex Hi 1", gi_256, ld_96, 0, ld_96, STYLE_DASH, 1, Green, TRUE, FALSE);
         ld_104 = ld_96 + li_60 * Point * gi_556;
         CreateHTLine("TextPlace_WklyExtHigh_2", "Wk Ex Hi 2", gi_256, ld_104, 0, ld_104, STYLE_DASH, 1, Green, TRUE, FALSE);
         ld_112 = ld_104 + li_60 * Point * gi_556;
         CreateHTLine("TextPlace_WklyExtHigh_3", "Wk Ex Hi 3", gi_256, ld_112, 0, ld_112, STYLE_DASH, 1, Green, TRUE, FALSE);
         ld_120 = ld_72 - li_60 * Point * gi_556;
         CreateHTLine("TextPlace_WklyExtLow_1", "Wk Ex Lo 1", gi_256, ld_120, 0, ld_120, STYLE_DASH, 1, Red, TRUE, FALSE);
         ld_128 = ld_120 - li_60 * Point * gi_556;
         CreateHTLine("TextPlace_WklyExtLow_2", "Wk Ex Lo 2", gi_256, ld_128, 0, ld_128, STYLE_DASH, 1, Red, TRUE, FALSE);
         ld_136 = ld_128 - li_60 * Point * gi_556;
         CreateHTLine("TextPlace_WklyExtLow_3", "Wk Ex Lo 3", gi_256, ld_136, 0, ld_136, STYLE_DASH, 1, Red, TRUE, FALSE);
      }
   }
}

void CreateHTLine(string a_name_0, string as_8, int ai_16, double a_price_20, int ai_28, double a_price_32, int a_style_40, int a_width_44, color a_color_48, int a_bool_52, int a_bool_56) {
   int width_76;
   int li_80 = 4;
   int time_60 = Time[ai_16];
   int datetime_64 = Time[ai_28];
   if (as_8 == "ADR High" || as_8 == "ADR Low") datetime_64 = Time[0] + 60 * Period() * (li_80 + 1);
   ObjectDelete(a_name_0);
   ai_28 += 5 * (60 * Period());
   ObjectCreate(a_name_0, OBJ_TREND, 0, time_60, a_price_20, datetime_64, a_price_32);
   ObjectSet(a_name_0, OBJPROP_STYLE, a_style_40);
   if (a_style_40 == STYLE_SOLID) ObjectSet(a_name_0, OBJPROP_WIDTH, a_width_44);
   ObjectSet(a_name_0, OBJPROP_COLOR, a_color_48);
   ObjectSet(a_name_0, OBJPROP_BACK, a_bool_52);
   ObjectSet(a_name_0, OBJPROP_RAY, a_bool_56);
   string name_84 = a_name_0 + "_Lab";
   switch (gi_260) {
   case 0: return;
   case 1:
      datetime_64 = Time[ai_16];
      break;
   case 2:
      ai_16 /= 2;
      datetime_64 = Time[ai_16];
      break;
   case 3:
      datetime_64 = Time[0] + 6 * (60 * Period());
   }
   if (as_8 == "ADR High" || as_8 == "ADR Low") {
      datetime_64 = Time[0] + 60 * Period() * li_80;
      if (Font_Size < 9) width_76 = 1;
      else width_76 = 2;
      ObjectDelete(name_84);
      ObjectCreate(name_84, OBJ_ARROW, 0, datetime_64, a_price_20);
      ObjectSet(name_84, OBJPROP_COLOR, a_color_48);
      ObjectSet(name_84, OBJPROP_ARROWCODE, SYMBOL_RIGHTPRICE);
      ObjectSet(name_84, OBJPROP_WIDTH, width_76);
      return;
   }
   ObjectDelete(name_84);
   ObjectCreate(name_84, OBJ_TEXT, 0, datetime_64, a_price_20);
   string str_concat_68 = StringConcatenate(DoubleToStr(a_price_20, Digits), "  ", as_8);
   ObjectSetText(name_84, str_concat_68, Font_Size, "Tahoma", a_color_48);
}

void updateText() {
   ObjectSetText("TextPlace_davgTxt", g_dbl2str_368, Font_Size, "Tahoma", ADR_Color);
   ObjectSetText("TextPlace_D1Txt", g_dbl2str_376, Font_Size, "Tahoma", ADR_Color);
   ObjectSetText("TextPlace_D5Txt", g_dbl2str_384, Font_Size, "Tahoma", ADR_Color);
   ObjectSetText("TextPlace_DyTxt", g_dbl2str_392, Font_Size, "Tahoma", ADR_Color);
   ObjectSetText("TextPlace_DzTxt", g_dbl2str_400, Font_Size, "Tahoma", ADR_Color);
   ObjectSetText("TextPlace_thigh", g_dbl2str_480, Font_Size, "Tahoma", ADR_Color);
   ObjectSetText("TextPlace_tlow", g_dbl2str_488, Font_Size, "Tahoma", ADR_Color);
   ObjectSetText("TextPlace_roomup", g_dbl2str_504, Font_Size, "Tahoma", ADR_Color);
   ObjectSetText("TextPlace_roomdn", g_dbl2str_520, Font_Size, "Tahoma", ADR_Color);
   ObjectSetText("TextPlace_adrhigh", g_dbl2str_472, Font_Size, "Tahoma", ADR_Color);
   ObjectSetText("TextPlace_adrlow", g_dbl2str_496, Font_Size, "Tahoma", ADR_Color);
   ObjectSetText("TextPlace_aroomup", g_dbl2str_512, Font_Size, "Tahoma", ADR_Color);
   ObjectSetText("TextPlace_aroomdn", g_dbl2str_528, Font_Size, "Tahoma", ADR_Color);
}

void createLabelObjects() {
   myObjCreate("TextPlace_Head1", gia_248[0][0], gia_248[0][1], gs_304);
   myObjCreate("TextPlace_Name", gia_248[1][0], gia_248[1][1], gs_536);
   myObjCreate("TextPlace_Head2", gia_248[2][0], gia_248[2][1], gs_296);
   myObjCreate("TextPlace_ADRhead", gia_248[3][0], gia_248[3][1], gs_312);
   myObjCreate("TextPlace_dayLbl", gia_248[4][0], gia_248[4][1], gs_320);
   myObjCreate("TextPlace_yesTxt", gia_248[5][0], gia_248[5][1], gs_328);
   myObjCreate("TextPlace_wkTxt", gia_248[6][0], gia_248[6][1], gs_336);
   myObjCreate("TextPlace_mnTxt", gia_248[7][0], gia_248[7][1], gs_344);
   myObjCreate("TextPlace_lstTxt", gia_248[8][0], gia_248[8][1], gs_352);
   myObjCreate("TextPlace_PIPhead", gia_248[9][0], gia_248[9][1], gs_360);
   myObjCreate("TextPlace_davgTxt", gia_248[10][0], gia_248[10][1], g_dbl2str_368);
   myObjCreate("TextPlace_D1Txt", gia_248[11][0], gia_248[11][1], g_dbl2str_376);
   myObjCreate("TextPlace_D5Txt", gia_248[12][0], gia_248[12][1], g_dbl2str_384);
   myObjCreate("TextPlace_DyTxt", gia_248[13][0], gia_248[13][1], g_dbl2str_392);
   myObjCreate("TextPlace_DzTxt", gia_248[14][0], gia_248[14][1], g_dbl2str_400);
   myObjCreate("TextPlace_Head3", gia_248[15][0], gia_248[15][1], gs_296);
   myObjCreate("TextPlace_tHighLbl", gia_248[16][0], gia_248[16][1], gs_408);
   myObjCreate("TextPlace_thigh", gia_248[17][0], gia_248[17][1], g_dbl2str_480);
   myObjCreate("TextPlace_aHighLbl", gia_248[18][0], gia_248[18][1], gs_416);
   myObjCreate("TextPlace_adrhigh", gia_248[19][0], gia_248[19][1], g_dbl2str_472);
   myObjCreate("TextPlace_tLowLbl", gia_248[20][0], gia_248[20][1], gs_424);
   myObjCreate("TextPlace_tlow", gia_248[21][0], gia_248[21][1], g_dbl2str_488);
   myObjCreate("TextPlace_aLowLbl", gia_248[22][0], gia_248[22][1], gs_432);
   myObjCreate("TextPlace_adrlow", gia_248[23][0], gia_248[23][1], g_dbl2str_496);
   myObjCreate("TextPlace_ptthLbl", gia_248[24][0], gia_248[24][1], gs_440);
   myObjCreate("TextPlace_roomup", gia_248[25][0], gia_248[25][1], g_dbl2str_504);
   myObjCreate("TextPlace_ptahLbl", gia_248[26][0], gia_248[26][1], gs_448);
   myObjCreate("TextPlace_aroomup", gia_248[27][0], gia_248[27][1], g_dbl2str_512);
   myObjCreate("TextPlace_pttlLbl", gia_248[28][0], gia_248[28][1], gs_456);
   myObjCreate("TextPlace_roomdn", gia_248[29][0], gia_248[29][1], g_dbl2str_520);
   myObjCreate("TextPlace_ptalLbl", gia_248[30][0], gia_248[30][1], gs_464);
   myObjCreate("TextPlace_aroomdn", gia_248[31][0], gia_248[31][1], g_dbl2str_528);
}

void myObjCreate(string a_name_0, int a_x_8, int a_y_12, string a_text_16) {
   ObjectCreate(a_name_0, OBJ_LABEL, 0, 0, 0);
   ObjectSet(a_name_0, OBJPROP_XDISTANCE, a_x_8);
   ObjectSet(a_name_0, OBJPROP_YDISTANCE, a_y_12);
   ObjectSet(a_name_0, OBJPROP_CORNER, Corner);
   ObjectSetText(a_name_0, a_text_16, Font_Size, "Tahoma", ADR_Color);
}

string Decrypt(string as_0) {
   int li_16;
   int str_len_8 = StringLen(as_0);
   for (int li_12 = 0; li_12 < str_len_8; li_12++) {
      li_16 = StringGetChar(as_0, li_12);
      li_16 -= 5;
      as_0 = StringSetChar(as_0, li_12, li_16);
   }
   return (as_0);
}


/*
void SetTextData() {
   int index_0;
   int li_8;
   string ls_16;
   int li_44;
   bool li_12 = TRUE;
   if (Font_Size < 6) Font_Size = 6;
   else
      if (Font_Size > 14) Font_Size = 14;
   if (Corner == 0 || Corner == 2) li_12 = TRUE;
   else li_12 = FALSE;
   switch (Font_Size) {
   case 6:
      gd_280 = 0.8;
      gd_288 = 0.8;
      li_8 = 5;
      if (li_12) ls_16 = "========";
      else ls_16 = "=======";
      break;
   case 7:
      gd_280 = 0.9;
      gd_288 = 0.84;
      li_8 = 3;
      if (li_12) ls_16 = "=======";
      else ls_16 = "======";
      break;
   case 8:
      gd_280 = 0.99;
      gd_288 = 1.0;
      li_8 = 0;
      if (li_12) ls_16 = "==========";
      else ls_16 = "==========";
      break;
   case 9:
      gd_280 = 1.3;
      gd_288 = 1.0;
      if (li_12) ls_16 = "===========";
      else ls_16 = "==========";
      break;
   case 10:
      gd_280 = 1.3;
      gd_288 = 1.05;
      if (li_12) ls_16 = "===========";
      else ls_16 = "==========";
      break;
   case 11:
      gd_280 = 1.52;
      gd_288 = 1.2;
      if (li_12) ls_16 = "=============";
      else ls_16 = "============";
      break;
   case 12:
      gd_280 = 1.64;
      gd_288 = 1.4;
      if (li_12) ls_16 = "=========";
      else ls_16 = "========";
      break;
   case 13:
      gd_280 = 1.73;
      gd_288 = 1.5;
      if (li_12) ls_16 = "===========";
      else ls_16 = "==========";
      break;
   case 14:
      gd_280 = 1.77;
      gd_288 = 1.6;
      if (li_12) ls_16 = "==========";
      else ls_16 = "========";
   }
   gs_296 = "==============================" + ls_16;
   if (Corner == 0) {
      int lia_28[34][2] = {5, 14,
   5, 27,
   5, 36,
   5, 46,
   49, 46,
   94, 46,
   153, 46,
   198, 46,
   247, 46,
   5, 58,
   49, 58,
   94, 58,
   153, 58,
   198, 58,
   247, 58,
   5, 69,
   5, 80,
   113, 80,
   158, 80,
   257, 80,
   5, 92,
   113, 92,
   158, 92,
   257, 92,
   5, 103,
   113, 103,
   158, 103,
   257, 103,
   5, 115,
   113, 115,
   158, 115,
   257, 115,
   0, 0};
      index_0 = 0;
      for (int li_4 = Vertical_Spacing_Adjustment; lia_28[index_0][1] > 0; index_0++) {
         gia_248[index_0][0] = lia_28[index_0][0] * gd_280;
         gia_248[index_0][1] = lia_28[index_0][1] * gd_288 + li_4 + li_8;
         if (lia_28[index_0][1] != lia_28[index_0 + 1][1]) li_4 += Vertical_Spacing_Adjustment;
      }
   } else {
      if (Corner == 1) {
         int lia_32[34][2] = {10, 14,
   9, 27,
   9, 36,
   265, 46,
   217, 46,
   158, 46,
   113, 46,
   64, 46,
   9, 46,
   265, 58,
   217, 58,
   158, 58,
   113, 58,
   64, 58,
   9, 58,
   9, 69,
   232, 80,
   153, 80,
   94, 80,
   9, 80,
   232, 92,
   153, 92,
   94, 92,
   9, 92,
   198, 103,
   153, 103,
   61, 103,
   9, 103,
   198, 115,
   153, 115,
   61, 115,
   9, 115,
   0, 0};
         index_0 = 0;
         for (li_4 = Vertical_Spacing_Adjustment; lia_32[index_0][1] > 0; index_0++) {
            gia_248[index_0][0] = lia_32[index_0][0] * gd_280;
            gia_248[index_0][1] = lia_32[index_0][1] * gd_288 + li_4 + li_8;
            if (lia_32[index_0][1] != lia_32[index_0 + 1][1]) li_4 += Vertical_Spacing_Adjustment;
         }
      } else {
         if (Corner == 2) {
            int lia_36[34][2] = {5, 103,
   5, 91,
   5, 80,
   5, 70,
   49, 70,
   94, 70,
   153, 70,
   198, 70,
   247, 70,
   5, 58,
   49, 58,
   94, 58,
   153, 58,
   198, 58,
   247, 58,
   5, 47,
   5, 37,
   113, 37,
   158, 37,
   257, 37,
   5, 25,
   113, 25,
   158, 25,
   257, 25,
   5, 13,
   113, 13,
   158, 13,
   257, 13,
   5, 1,
   113, 1,
   158, 1,
   257, 1,
   0, 0};
            for (index_0 = 0; lia_36[index_0][1] > 0; index_0++) {
               gia_248[index_0][0] = lia_36[index_0][0] * gd_280;
               gia_248[index_0][1] = lia_36[index_0][1] * gd_288;
            }
            li_4 = 0;
            for (index_0 -= 4; index_0 >= 0; index_0--) {
               gia_248[index_0][1] += li_4;
               if (lia_36[index_0][1] != lia_36[index_0 + 1][1]) li_4 += Vertical_Spacing_Adjustment;
            }
         } else {
            if (Corner == 3) {
               index_0 = 0;
               int lia_40[34][2] = {10, 103,
   9, 91,
   9, 80,
   265, 70,
   217, 70,
   158, 70,
   113, 70,
   64, 70,
   9, 70,
   265, 58,
   217, 58,
   158, 58,
   113, 58,
   64, 58,
   9, 58,
   9, 47,
   232, 37,
   153, 37,
   94, 37,
   9, 37,
   232, 25,
   153, 25,
   94, 25,
   9, 25,
   198, 13,
   153, 13,
   61, 13,
   9, 13,
   198, 1,
   153, 1,
   61, 1,
   9, 1,
   0, 0};
               for (index_0 = 0; lia_40[index_0][1] > 0; index_0++) {
                  gia_248[index_0][0] = lia_40[index_0][0] * gd_280;
                  gia_248[index_0][1] = lia_40[index_0][1] * gd_288;
               }
               li_4 = 0;
               for (index_0--; index_0 >= 0; index_0--) {
                  gia_248[index_0][1] += li_4;
                  if (lia_40[index_0][1] != lia_40[index_0 + 1][1]) li_4 += Vertical_Spacing_Adjustment;
               }
            }
         }
      }
   }
   if (Corner > 1) {
      if (Font_Size < 8) li_44 = 3;
      else li_44 = 1;
      li_4 = ArrayRange(gia_248, 0);
      for (index_0 = 0; index_0 < li_4; index_0++) gia_248[index_0][1] += li_44;
   }
   if (!li_12) {
      if (Font_Size == 9) {
         gia_248[9][0] += 2;
         gia_248[16][0] += 5;
         gia_248[18][0] += 4;
         gia_248[24][0] += 5;
         gia_248[26][0] += 5;
         gia_248[28][0] += 2;
         gia_248[30][0] += 2;
      } else {
         if (Font_Size == 10) {
            gia_248[9][0] += 0;
            gia_248[16][0] += 3;
            gia_248[18][0] += 2;
            gia_248[24][0] += 3;
            gia_248[26][0] += 3;
            gia_248[28][0]++;
            gia_248[30][0]++;
         } else {
            if (Font_Size == 11) {
               gia_248[9][0] += 3;
               gia_248[16][0] += 3;
               gia_248[18][0] += 2;
               gia_248[24][0] += 9;
               gia_248[26][0] += 7;
               gia_248[28][0] += 7;
               gia_248[30][0] += 5;
            } else {
               if (Font_Size == 12) {
                  gia_248[9][0] += 2;
                  gia_248[16][0] += 2;
                  gia_248[18][0] += 2;
                  gia_248[24][0] += 3;
                  gia_248[26][0] += 2;
                  gia_248[28][0]++;
                  gia_248[30][0] += 0;
               } else {
                  if (Font_Size == 13) {
                     gia_248[9][0] += 2;
                     gia_248[16][0] += 5;
                     gia_248[18][0] += 2;
                     gia_248[24][0] += 7;
                     gia_248[26][0] += 2;
                     gia_248[28][0] += 5;
                     gia_248[30][0] += 0;
                     gia_248[20][0] += 3;
                  } else {
                     if (Font_Size == 14) {
                        gia_248[9][0] += 2;
                        gia_248[16][0] += 0;
                        gia_248[18][0] += 2;
                        gia_248[24][0] += 0;
                        gia_248[26][0] += 0;
                        gia_248[28][0] = gia_248[28][0] - 2;
                        gia_248[30][0] = gia_248[30][0] - 2;
                        gia_248[20][0] = gia_248[20][0] - 2;
                     }
                  }
               }
            }
         }
      }
   }
   if (Digits == 5 || Digits == 3) ls_16 = ls_16 + "=";
   gs_304 = "";
   gs_312 = "ADR:";
   gs_328 = "Yesterday";
   gs_336 = "Weekly";
   gs_344 = "Monthly";
   gs_352 = "180 Days";
   gs_360 = "Pips:";
   gs_408 = "Today High:";
   gs_416 = "ADR High:";
   gs_424 = "Today Low: ";
   gs_432 = "ADR Low: ";
   gs_440 = "Pips to Today High:";
   gs_448 = "Pips to ADR High:";
   gs_456 = "Pips to Today Low: ";
   gs_464 = "Pips to ADR Low: ";
   gs_320 = "" + Day_x + " days";
}
*/
void DeleteObjs() {
   int objs_total_8;
   string name_16;
   int count_4 = 1;
   for (int li_12 = 6; li_12 > 0; li_12--) {
      objs_total_8 = ObjectsTotal();
      count_4 = 0;
      for (int li_0 = 0; li_0 <= objs_total_8; li_0++) {
         name_16 = ObjectName(li_0);
         if (StringSubstr(name_16, 0, 10) == "TextPlace_")
            if (ObjectDelete(name_16)) count_4++;
      }
      if (count_4 == 0) break;
   }
}

string ToCaps(string as_0) {
   int li_16;
   int str_len_8 = StringLen(as_0);
   for (int li_12 = 0; li_12 < str_len_8; li_12++) {
      li_16 = StringGetChar(as_0, li_12);
      if (li_16 >= 'a') as_0 = StringSetChar(as_0, li_12, li_16 - 32);
   }
   return (as_0);
}

int IsYes(string as_0) {
   as_0 = ToCaps(as_0);
   if (StringFind(as_0, "Y") > -1) return (1);
   return (0);
}