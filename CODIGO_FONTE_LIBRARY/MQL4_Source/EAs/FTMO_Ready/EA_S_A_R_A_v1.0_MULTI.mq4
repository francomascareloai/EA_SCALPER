#property copyright "Tudor Ceban"
#property link      "http://www.rapidresultsmethod.com"

#include <WinUser32.mqh>
#import "wininet.dll"
   int InternetOpenA(string a0, int a1, string a2, string a3, int a4);
   int InternetOpenUrlA(int a0, string a1, string a2, int a3, int a4, int a5);
   int InternetReadFile(int a0, string a1, int a2, int& a3[]);
   int InternetCloseHandle(int a0);
#import

extern string note = " ======= Authentication SETTINGS ======";
extern string username = "";
extern string password = "";
extern double LotSize = 0.1;
extern double RiskPercent = 2.0;
extern int Slippage = 3;
extern int MagicNumber = 9869;
extern bool DynamicSLTP = TRUE;
extern int TakeProfit = 20;
extern int StopLoss = 10;
extern int MinStopLoss = 7;
extern int MaxStopLoss = 15;
extern bool PartialClose = FALSE;
extern int PartialClosePct = 70;
extern int PartialCloseAtPipsProfit = 10;
extern string txt = " ====== Trailing Settings ======";
extern double BreakEvenAtPct = 70.0;
extern int BreakEvenPips = 1;
extern bool UseTrailing = FALSE;
extern bool TrailOnProfit = TRUE;
extern int TrailingStop = 25;
extern int TrailingStep = 2;
extern bool SoundAlert = TRUE;
extern bool EntryPopUp = TRUE;
extern bool CloseOnReverse = FALSE;
bool gi_204 = FALSE;
extern string txtAdv = "====== !!!!! ADVANCED SETTINGS !!!!!  ======";
extern bool ConfirmWithDPI = TRUE;
extern bool ConfirmWith3rdEMA = TRUE;
extern bool ConfirmWith4thEMA = FALSE;
extern int PipsAwayFromCandle = 3;
extern color SLColor = Red;
extern color TPColor = Blue;
extern color BoxColor = Blue;
extern color NonSetupColor = Silver;
extern color UpColor = Green;
extern color DownColor = Blue;
extern color UpTrendColor = Lime;
extern color DownTrendColor = Red;
extern color CurrentUpColor = Yellow;
extern color CurrentDownColor = Red;
int gi_272 = 8;
int gi_276 = 13;
int gi_280 = 5;
int gi_284 = 13;
int gi_288 = 34;
int gi_292 = 89;
double gd_296 = 0.05;
double gd_304 = 0.5;
bool gi_312 = FALSE;
int gi_316 = 7;
int gi_320 = 30;
int gi_324 = 22;
int gi_328 = 30;
double gd_332;
double gd_340;
int gi_348 = 0;
int gi_352 = 0;
string gs_356 = "";
extern color cTrendBG = C'0x37,0x37,0x37';
double gd_368;
int gia_376[9] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};
string gsa_380[9] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN1",
   ""};
int gi_384 = 0;
int gi_388 = 0;
int gia_392[14];
int gia_396[14];
int gia_400[14];
int gia_404[14];
int gi_408;
bool gi_412 = FALSE;
int gi_416 = 0;
bool gi_420 = FALSE;
bool gi_424 = TRUE;
int gia_428[64] = {65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 43, 47};
int gi_432 = 1;
string gs_436;
int gi_444 = 0;
int gi_448 = 0;
int gi_452 = 0;
string gs_456;
int gia_464[1];
string gs_472 = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
int gt_480 = 0;

string ProcessURL(string as_0) {
   string ls_12;
   string ls_20;
   for (int li_8 = StringFind(as_0, " "); li_8 != -1; li_8 = StringFind(as_0, " ")) {
      ls_12 = StringTrimLeft(StringTrimRight(StringSubstr(as_0, 0, StringFind(as_0, " ", 0))));
      ls_20 = StringTrimLeft(StringTrimRight(StringSubstr(as_0, StringFind(as_0, " ", 0))));
      as_0 = ls_12 + "%20" + ls_20;
   }
   return (as_0);
}

void Base64Encode(string as_0, string &as_8) {
   int li_28;
   int li_32;
   int li_36;
   int li_40;
   int li_44;
   int li_48;
   int li_52;
   as_8 = "";
   int li_16 = 0;
   int li_20 = 0;
   int li_24 = StringLen(as_0);
   while (li_16 < li_24) {
      li_36 = StringGetChar(as_0, li_16);
      li_16++;
      if (li_16 >= li_24) {
         li_32 = 0;
         li_28 = 0;
         li_20 = 2;
      } else {
         li_32 = StringGetChar(as_0, li_16);
         li_16++;
         if (li_16 >= li_24) {
            li_28 = 0;
            li_20 = 1;
         } else {
            li_28 = StringGetChar(as_0, li_16);
            li_16++;
         }
      }
      li_40 = li_36 >> 2;
      li_44 = (li_36 & 3 * 16) | li_32 >> 4;
      li_48 = (li_32 & 15 * 4) | li_28 >> 6;
      li_52 = li_28 & 63;
      as_8 = as_8 + CharToStr(gia_428[li_40]);
      as_8 = as_8 + CharToStr(gia_428[li_44]);
      switch (li_20) {
      case 0:
         as_8 = as_8 + CharToStr(gia_428[li_48]);
         as_8 = as_8 + CharToStr(gia_428[li_52]);
         break;
      case 1:
         as_8 = as_8 + CharToStr(gia_428[li_48]);
         as_8 = as_8 + "=";
         break;
      case 2:
         as_8 = as_8 + "==";
      }
   }
}

string LoadURL(string as_0) {
   gi_452 = 0;
   for (gi_444 = FALSE; gi_452 < 3 && gi_444 == FALSE; gi_452++) {
      if (gi_448 != 0) gi_444 = InternetOpenUrlA(gi_448, as_0, 0, 0, -2079850240, 0);
      if (gi_444 == FALSE) {
         InternetCloseHandle(gi_448);
         gi_448 = InternetOpenA("mymt4InetSession", gi_432, 0, 0, 0);
      }
   }
   gs_456 = "";
   gia_464[0] = 1;
   while (gia_464[0] > 0) {
      InternetReadFile(gi_444, gs_472, 200, gia_464);
      if (gia_464[0] > 0) gs_456 = gs_456 + StringSubstr(gs_472, 0, gia_464[0]);
      if (StringSubstr(gs_472, 0, gia_464[0]) == "0") break;
      if (StringSubstr(gs_472, 0, gia_464[0]) == "4") break;
      if (StringSubstr(gs_472, 0, gia_464[0]) == "1") break;
   }
   InternetCloseHandle(gi_444);
   return (gs_456);
}

/* string authentication(string as_0, string as_8) {
   string ls_32;
   string ls_16 = "";
   string ls_24 = "";
   ls_16 = "mode=authenticate&username=" + as_0 + "&password=" + as_8;
   Base64Encode(ls_16, ls_24);
   return (LoadURL(ProcessURL("http://www.rapidresultsmethod.com/authea/member.php?encoded=" + ls_24)));
} */

int init() {
   int li_16;
   int li_20;
   int li_24;
   int li_28;
   if (Point == 0.00001) gd_332 = 0.0001;
   else {
      if (Point == 0.001) gd_332 = 0.01;
      else gd_332 = Point;
   }
   gi_348 = 0;
   gd_340 = Slippage * gd_332 / Point;
   gd_368 = gd_332 * TrailingStop;
   gi_408 = 2;
   if (MarketInfo(Symbol(), MODE_LOTSTEP) == 0.1) gi_408 = 1;
   if (MarketInfo(Symbol(), MODE_LOTSTEP) == 1.0) gi_408 = 0;
   gi_412 = FALSE;
   int li_0 = OrdersTotal();
   for (int li_4 = 0; li_4 < li_0; li_4++) {
      if (OrderSelect(li_4, SELECT_BY_POS, MODE_TRADES) != FALSE)
         if (OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) gi_348 = OrderTicket();
   }
   gi_420 = TRUE;
/*   gi_424 = TRUE;
   gi_416 = 0;
   string ls_8 = "";
   if (gi_424 == TRUE && gi_416 == 0) {
      ls_8 = "\nS.A.R.A. Trading Assistant  \n authenticating...";
      Comment(ls_8);
/*      gi_416 = StrToInteger(authentication(username, password));
      if (gi_416 == 1) {
         gi_420 = TRUE;
         ls_8 = "";
         Comment(ls_8);
      } else {
         ls_8 = "\nS.A.R.A. Trading Assistant \n Authentication FAILED\n\n";
         ls_8 = ls_8 + " Send an email to support@forexprofitmodel.com\n";
         gi_420 = FALSE;
         Comment(ls_8);
      } 
      gi_424 = FALSE; 
   } */
   if (gi_420 == TRUE) {
      objectCreate("SRT_BoxBgA1", 7, 20, CharToStr(103), 126, "Webdings", BoxColor);
      objectCreate("SRT_BoxBgA2", 7, 180, CharToStr(103), 126, "Webdings", BoxColor);
      objectCreate("SRT_BoxBgA3", 7, 213, CharToStr(103), 126, "Webdings", BoxColor);
      ObjectSet("SRT_BoxBgA1", OBJPROP_BACK, TRUE);
      ObjectSet("SRT_BoxBgA2", OBJPROP_BACK, TRUE);
      ObjectSet("BoxBgB2", OBJPROP_BACK, TRUE);
      objectCreate("SRT_BoxBgB1", 11, 23, CharToStr(103), 120, "Webdings", Black);
      objectCreate("SRT_BoxBgB2", 11, 183, CharToStr(103), 120, "Webdings", Black);
      objectCreate("SRT_BoxBgB3", 11, 218, CharToStr(103), 120, "Webdings", Black);
      objectCreate("SRT_Pair", 30, 25, Symbol(), 20, "Verdana", White);
      objectCreate("SRT_Phase", 20, 60, "  ----  Phase   ", 12, "Verdana", NonSetupColor);
      objectCreate("SRT_Direction", 30, 83, " NO TRADE  ", 12, "Verdana", NonSetupColor);
      objectCreate("SRT_Separator", 11, 70, "________", 24, "Verdana", BoxColor);
      objectCreate("SRT_TitanArr", 91, 110, CharToStr(127), 14, "Wingdings", NonSetupColor);
      objectCreate("SRT_TitanPct", 20, 110, "DPI      ", 14, "Verdana", NonSetupColor);
      for (li_4 = 1; li_4 <= 10; li_4++) {
         objectCreate("SRT_TrendMA0" + li_4, 17, 9 * li_4 + 75, "-", 65, "Verdana", cTrendBG);
         objectCreate("SRT_TrendMA1" + li_4, 42, 9 * li_4 + 75, "-", 65, "Verdana", cTrendBG);
      }
      objectCreate("SRT_ST", 132, 140, "ST", 14, "Verdana", NonSetupColor);
      objectCreate("SRT_STArr", 102, 140, CharToStr(127), 14, "Wingdings", NonSetupColor);
      objectCreate("SRT_MT", 130, 170, "MT", 14, "Verdana", NonSetupColor);
      objectCreate("SRT_MTArr", 102, 170, CharToStr(127), 14, "Wingdings", NonSetupColor);
      objectCreate("SRT_LT", 134, 200, "LT", 14, "Verdana", NonSetupColor);
      objectCreate("SRT_LTArr", 102, 200, CharToStr(127), 14, "Wingdings", NonSetupColor);
      objectCreate("SRT_Psar", 115, 230, "psar", 14, "Verdana", NonSetupColor);
      objectCreate("SRT_PsarArr", 91, 231, CharToStr(127), 14, "Wingdings", NonSetupColor);
      objectCreate("SRT_Psar_points", 18, 195, ".....", 40, "Calibri", NonSetupColor);
      objectCreate("SRT_Separator2", 11, 225, "________", 24, "Verdana", Blue);
      objectCreate("SRT_Direction2", 20, 263, " DPI      ", 14, "Verdana", NonSetupColor);
      FirstInit();
      objectCreate("SRT_TimeFrames", 22, 286, gs_356, 9, "Verdana", NonSetupColor);
      for (li_4 = 1; li_4 <= 10; li_4++) {
         objectCreate("SRT_TF1" + li_4, 12, 7 * li_4 + 245, "-", 60, "Verdana", NonSetupColor);
         objectCreate("SRT_TF2" + li_4, 42, 7 * li_4 + 245, "-", 60, "Verdana", NonSetupColor);
         objectCreate("SRT_TF3" + li_4, 72, 7 * li_4 + 245, "-", 60, "Verdana", NonSetupColor);
         objectCreate("SRT_TF4" + li_4, 102, 7 * li_4 + 245, "-", 60, "Verdana", NonSetupColor);
         objectCreate("SRT_TF5" + li_4, 132, 7 * li_4 + 245, "-", 60, "Verdana", NonSetupColor);
      }
      li_16 = 17;
      gia_392[0] = UpColor;
      li_20 = gia_392[0] % 256 / li_16;
      li_24 = gia_392[0] % 65536 / (li_16 * 256);
      li_28 = gia_392[0] % 16777216 / li_16 << 16;
      for (li_4 = 1; li_4 < 10; li_4++) gia_392[li_4] = gia_392[li_4 - 1] - li_20 - li_24 * 256 - li_28 * 256 * 256;
      gia_400[0] = CurrentUpColor;
      li_20 = gia_400[0] % 256 / li_16;
      li_24 = gia_400[0] % 65536 / (li_16 * 256);
      li_28 = gia_400[0] % 16777216 / li_16 << 16;
      for (li_4 = 1; li_4 < 14; li_4++) gia_400[li_4] = gia_400[li_4 - 1] - li_20 - li_24 * 256 - li_28 * 256 * 256;
      gia_396[13] = DownColor;
      li_20 = gia_396[13] % 256 / li_16;
      li_24 = gia_396[13] % 65536 / (li_16 * 256);
      li_28 = gia_396[13] % 16777216 / li_16 << 16;
      for (li_4 = 12; li_4 >= 0; li_4--) gia_396[li_4] = gia_396[li_4 + 1] - li_20 - li_24 * 256 - li_28 * 256 * 256;
      gia_404[13] = CurrentDownColor;
      li_20 = gia_404[13] % 256 / li_16;
      li_24 = gia_404[13] % 65536 / (li_16 * 256);
      li_28 = gia_404[13] % 16777216 / li_16 << 16;
      for (li_4 = 12; li_4 >= 0; li_4--) gia_404[li_4] = gia_404[li_4 + 1] - li_20 - li_24 * 256 - li_28 * 256 * 256;
      update_timeframes();
      WindowRedraw();
   }
   return (0);
}

void update_timeframes() {
   double ld_0;
   double ld_8;
   double ld_16;
   double ld_24;
   int li_40;
   int li_32 = 5;
   int li_36 = 0;
   double ld_44 = iMA(NULL, 0, gi_280, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ld_52 = iMA(NULL, 0, gi_284, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ld_60 = iMA(NULL, 0, gi_288, 0, MODE_EMA, PRICE_CLOSE, 0);
   double ld_68 = iMA(NULL, 0, gi_292, 0, MODE_EMA, PRICE_CLOSE, 0);
   color li_76 = NonSetupColor;
   string ls_80 = "Unordered Phase";
   if (ld_68 > ld_60 && ld_60 > ld_52) {
      li_76 = DownTrendColor;
      ls_80 = "Trending Phase ";
   } else {
      if (ld_68 < ld_60 && ld_60 < ld_52) {
         li_76 = UpTrendColor;
         ls_80 = "Trending Phase ";
      } else {
         if (ld_68 < ld_60 && ld_52 < ld_68) {
            li_76 = DownTrendColor;
            ls_80 = "Emerging Phase";
         } else {
            if (ld_52 > ld_68 && ld_68 > ld_52) {
               li_76 = UpTrendColor;
               ls_80 = "Emerging Phase";
            }
         }
      }
   }
   ObjectSetText("SRT_Phase", ls_80, 12, "Verdana", li_76);
   int li_88 = 127;
   if (ld_44 > ld_52) {
      li_76 = UpTrendColor;
      li_88 = 241;
   } else {
      li_76 = DownTrendColor;
      li_88 = 242;
   }
   ObjectSetText("SRT_ST", "ST", 14, "Verdana", li_76);
   ObjectSetText("SRT_STArr", CharToStr(li_88), 18, "Wingdings", li_76);
   if (ld_52 > ld_60) {
      li_76 = UpTrendColor;
      li_88 = 241;
   } else {
      li_76 = DownTrendColor;
      li_88 = 242;
   }
   ObjectSetText("SRT_MT", "MT", 14, "Verdana", li_76);
   ObjectSetText("SRT_MTArr", CharToStr(li_88), 18, "Wingdings", li_76);
   if (ld_60 > ld_68) {
      li_76 = UpTrendColor;
      li_88 = 241;
   } else {
      li_76 = DownTrendColor;
      li_88 = 242;
   }
   ObjectSetText("SRT_LT", "LT", 14, "Verdana", li_76);
   ObjectSetText("SRT_LTArr", CharToStr(li_88), 18, "Wingdings", li_76);
   double ld_92 = iSAR(NULL, 0, gd_296, gd_304, 0);
   if (Bid > ld_92) {
      li_76 = UpTrendColor;
      li_88 = 241;
   } else {
      li_76 = DownTrendColor;
      li_88 = 242;
   }
   ObjectSetText("SRT_Psar", "psar", 14, "Verdana", li_76);
   ObjectSetText("SRT_PsarArr", CharToStr(li_88), 18, "Wingdings", li_76);
   ObjectSetText("SRT_Psar_points", ".....", 40, "Calibri", li_76);
   ema_trend_locations(ld_44, ld_52, ld_60, ld_68);
   for (int li_100 = gi_352; li_100 < gi_352 + 5; li_100++) {
      ld_0 = iCustom(NULL, gia_376[li_100], "DPI", gi_272, gi_276, 5, 0);
      ld_8 = iCustom(NULL, gia_376[li_100], "DPI", gi_272, gi_276, 6, 0);
      if (ld_0 < 0.0 && ld_8 < 0.0) ld_16 = -1;
      else {
         if (ld_0 > 0.0 && ld_8 > 0.0) ld_16 = 1;
         else {
            if (ld_8 > ld_0) {
               ld_24 = ld_8;
               ld_8 = ld_0;
               ld_0 = ld_24;
            }
            ld_8 = MathAbs(ld_8);
            ld_0 = MathAbs(ld_0);
            if (ld_0 > ld_8) ld_16 = 1;
            else ld_16 = -1;
         }
      }
      if (ld_16 < 0.0) li_40 = 10.0 * ld_16 + 10.0;
      else li_40 = 10.0 * ld_16;
      if (Period() == gia_376[li_100]) {
         for (li_36 = 1; li_36 <= 10; li_36++) {
            if (li_36 <= li_40) ObjectSetText("SRT_TF" + li_32 + "" + li_36, "-", 60, "Verdana", gia_400[li_36 - 1]);
            else ObjectSetText("SRT_TF" + li_32 + "" + li_36, "-", 60, "Verdana", gia_404[li_36 - 1]);
         }
         if (ld_16 < 0.0) {
            ObjectSetText("SRT_Direction2", "DOWN TREND", 14, "Verdana", CurrentDownColor);
            ObjectSetText("SRT_TitanPct", "DPI      DOWN", 14, "Verdana", CurrentDownColor);
            ObjectSetText("SRT_TitanArr", CharToStr(242), 18, "Wingdings", CurrentDownColor);
         } else {
            ObjectSetText("SRT_Direction2", "UP   TREND  ", 14, "Verdana", CurrentUpColor);
            ObjectSetText("SRT_TitanPct", "DPI         UP  ", 14, "Verdana", CurrentUpColor);
            ObjectSetText("SRT_TitanArr", CharToStr(241), 18, "Wingdings", CurrentUpColor);
         }
      } else {
         for (li_36 = 1; li_36 <= 10; li_36++) {
            if (li_36 <= li_40) ObjectSetText("SRT_TF" + li_32 + "" + li_36, "-", 60, "Verdana", gia_392[li_36 - 1]);
            else ObjectSetText("SRT_TF" + li_32 + "" + li_36, "-", 60, "Verdana", gia_396[li_36 - 1]);
         }
      }
      li_32--;
   }
}

void ema_trend_locations(double ad_0, double ad_8, double ad_16, double ad_24) {
   double lda_32[4];
   double ld_44;
   int li_52;
   int lia_36[4] = {0, 1, 2, 3};
   int lia_40[4] = {65535, 255, 16711680, 16777215};
   lda_32[0] = ad_0;
   lda_32[1] = ad_8;
   lda_32[2] = ad_16;
   lda_32[3] = ad_24;
   color li_56 = cTrendBG;
   for (int li_60 = 0; li_60 < 3; li_60++) {
      for (int li_64 = li_60 + 1; li_64 < 4; li_64++) {
         if (lda_32[li_60] < lda_32[li_64]) {
            ld_44 = lda_32[li_60];
            li_52 = lia_36[li_60];
            lda_32[li_60] = lda_32[li_64];
            lia_36[li_60] = lia_36[li_64];
            lda_32[li_64] = ld_44;
            lia_36[li_64] = li_52;
         }
      }
   }
   ObjectSetText("SRT_TrendMA01", "-", 65, "Verdana", lia_40[lia_36[0]]);
   ObjectSetText("SRT_TrendMA11", "-", 65, "Verdana", lia_40[lia_36[0]]);
   ObjectSetText("SRT_TrendMA010", "-", 65, "Verdana", lia_40[lia_36[3]]);
   ObjectSetText("SRT_TrendMA110", "-", 65, "Verdana", lia_40[lia_36[3]]);
   int li_68 = 10 - NormalizeDouble(10.0 * (lda_32[2] - lda_32[3]) / (lda_32[0] - lda_32[3]), 0);
   int li_72 = 10 - NormalizeDouble(10.0 * (lda_32[1] - lda_32[3]) / (lda_32[0] - lda_32[3]), 0);
   if (li_72 > 9) li_72 = 9;
   if (li_68 > 8) li_68 = 8;
   if (li_72 < 3) li_72 = 3;
   if (li_68 < 2) li_68 = 2;
   if (li_68 == li_72) {
      if (li_68 == 2) li_72 = 3;
      else {
         if (li_72 == 9) li_68 = 8;
         else li_72--;
      }
   }
   for (li_60 = 2; li_60 < 10; li_60++) {
      li_56 = cTrendBG;
      if (li_68 == li_60) li_56 = lia_40[lia_36[2]];
      if (li_72 == li_60) li_56 = lia_40[lia_36[1]];
      ObjectSetText("SRT_TrendMA0" + li_60, "-", 65, "Verdana", li_56);
      ObjectSetText("SRT_TrendMA1" + li_60, "-", 65, "Verdana", li_56);
   }
}

void FirstInit() {
   gi_352 = 0;
   for (int li_0 = 0; li_0 < 9; li_0++) {
      if (Period() == gia_376[li_0]) {
         gi_352 = li_0 - 2;
         break;
      }
   }
   if (gi_352 < 0) gi_352 = 0;
   if (gi_352 > 4) gi_352 = 4;
   if (gi_352 == 1) {
      gs_356 = "M5  M15 M30  H1   H4";
      return;
   }
   if (gi_352 == 2) {
      gs_356 = "M15 M30  H1   H4   D1";
      return;
   }
   if (gi_352 == 3) {
      gs_356 = "M30  H1   H4   D1  W1";
      return;
   }
   if (gi_352 == 4) {
      gs_356 = "H1   H4   D1   W1  MN";
      return;
   }
   gs_356 = "M1   M5  M15 M30  H1";
}

int deinit() {
   int li_0;
   string ls_4 = "";
   bool li_12 = TRUE;
   while (li_12) {
      li_12 = FALSE;
      li_0 = ObjectsTotal();
      for (int li_16 = 0; li_16 < li_0; li_16++) {
         ls_4 = ObjectName(li_16);
         if (StringFind(ls_4, "SRT_") != -1) {
            ObjectDelete(ls_4);
            li_12 = TRUE;
         }
      }
   }
   return (0);
}

int start() {
   if (gi_420 == TRUE) {
      if (gi_348 != 0) TrailStop();
      if (gi_348 != 0) check_ticket();
      if (gi_348 != 0) ObjectSetText("SRT_Direction", " TRADE MODE ", 12, "Verdana", White);
      else ObjectSetText("SRT_Direction", " NO TRADE  ", 12, "Verdana", NonSetupColor);
      if (gi_204) CheckOrder();
      else
         if (NewBar()) CheckOrder();
      update_timeframes();
   }
   return (0);
}

int Trading_Hours() {
   if (Hour() == gi_316) {
      if (Minute() < gi_320) return (0);
      return (1);
   }
   if (Hour() == gi_324) {
      if (Minute() >= gi_328) return (0);
      return (1);
   }
   if (gi_324 > gi_316) {
      if (Hour() < gi_316) return (0);
      if (Hour() < gi_324) return (1);
      return (0);
   }
   if (Hour() >= gi_316 && Hour() <= 24) return (1);
   if (Hour() < gi_324) return (1);
   return (0);
}

int OpenTrade(int ai_0) {
   double ld_4;
   double ld_16;
   double ld_24;
   double ld_32;
   if (gi_312 && (!Trading_Hours())) {
      gi_348 = 0;
      return (0);
   }
   int li_12 = 1;
   if (DynamicSLTP) update_SLTP(ai_0);
   if (notify(ai_0)) {
      RefreshRates();
      ld_4 = Ask;
      if (ai_0 == OP_SELL) {
         ld_4 = Bid;
         li_12 = -1;
      }
      ld_16 = MyLotCalc();
      gi_348 = OrderSend(Symbol(), ai_0, ld_16, ld_4, gd_340, 0, 0, 0, MagicNumber);
      if (gi_348 < 0) gi_348 = OrderSend(Symbol(), ai_0, LotSize, ld_4, gd_340, 0, 0, 0, MagicNumber);
      if (gi_348 < 0) {
         Print("Error opening Order " + GetLastError());
         return (0);
      }
      gi_412 = FALSE;
      if (OrderSelect(gi_348, SELECT_BY_TICKET) != FALSE) {
         ld_24 = 0;
         ld_32 = 0;
         if (StopLoss != 0) ld_24 = OrderOpenPrice() - li_12 * gd_332 * StopLoss;
         if (TakeProfit != 0) ld_32 = OrderOpenPrice() + li_12 * gd_332 * TakeProfit;
         OrderModify(gi_348, OrderOpenPrice(), ld_24, ld_32, OrderExpiration());
      }
   }
   return (1);
}

int notify(int ai_0) {
   int li_4;
   string ls_8;
   string ls_16;
   if (SoundAlert) PlaySound("alert.wav");
   if (EntryPopUp) {
      li_4 = -3;
      ls_8 = "BUY";
      if (ai_0 == 1) ls_8 = "SELL";
      ls_16 = Symbol() + " " + Period() + " min chart at " + TimeToStr(TimeCurrent(), TIME_MINUTES) 
      + "\n\n" + ls_8 + " Signal with StopLoss: " + StopLoss + "pips  TakeProfit: " + TakeProfit + "pips";
      ls_16 = ls_16 
      + "\n\n Would you Like to place the Order Now?";
      li_4 = MessageBox(ls_16, "S.A.R.A. Trading Assistant", MB_YESNO|MB_ICONQUESTION);
      if (li_4 == IDYES) return (1);
      return (0);
   }
   return (0);
}

void update_SLTP(int ai_0) {
   StopLoss = 7;
   if (ai_0 == 0) {
      for (int li_4 = 1; li_4 < 30; li_4++) {
         if (is_fractal(li_4, 3) == 0) {
            StopLoss = MathRound((Bid - Low[li_4]) / gd_332);
            break;
         }
      }
   }
   if (ai_0 == 1) {
      for (li_4 = 1; li_4 < 30; li_4++) {
         if (is_fractal(li_4, 3) == 1) {
            StopLoss = MathRound((High[li_4] - Bid) / gd_332);
            break;
         }
      }
   }
   if (StopLoss > MaxStopLoss) StopLoss = MaxStopLoss;
   if (StopLoss < MinStopLoss) StopLoss = MinStopLoss;
   TakeProfit = StopLoss;
}

int is_fractal(int ai_0, int ai_4) {
   int li_8 = 1;
   int li_12 = 0;
   int li_16 = 0;
   while (li_8 < ai_4) {
      if (High[ai_0] > High[ai_0 + li_8]) {
         if (ai_0 - li_8 >= 0) {
            if (High[ai_0] > High[ai_0 - li_8]) li_12++;
         } else li_12++;
      }
      if (Low[ai_0] < Low[ai_0 + li_8]) {
         if (ai_0 - li_8 >= 0) {
            if (Low[ai_0] < Low[ai_0 - li_8]) li_16++;
         } else li_16++;
      }
      li_8++;
   }
   if (li_12 == ai_4 - 1) return (1);
   if (li_16 == ai_4 - 1) return (0);
   return (-1);
}

int NewBar() {
   if (gt_480 == 0) gt_480 = Time[0];
   if (gt_480 != Time[0]) {
      gt_480 = Time[0];
      return (1);
   }
   return (0);
}

void check_ticket() {
   if (OrderSelect(gi_348, SELECT_BY_TICKET) != FALSE) {
      if (OrderCloseTime() != 0) {
         gi_348 = 0;
         return;
      }
      if ((!gi_412) && PartialClose) {
         if (MyTPClose(PartialCloseAtPipsProfit, PartialClosePct)) {
            gi_412 = TRUE;
            return;
         }
      }
   } else gi_348 = 0;
}

void TrailStop() {
   double ld_12;
   int li_0 = 1;
   double ld_4 = 0;
   bool li_28 = FALSE;
   int li_32 = OrdersTotal();
   for (int li_36 = 0; li_36 < li_32; li_36++) {
      if (OrderSelect(li_36, SELECT_BY_POS, MODE_TRADES) != FALSE) {
         if (OrderCloseTime() == 0 && OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) {
            if (OrderType() == OP_BUY) {
               li_0 = 1;
               ld_4 = Bid;
            } else {
               if (OrderType() == OP_SELL) {
                  li_0 = -1;
                  ld_4 = Ask;
               }
            }
            ld_12 = OrderStopLoss();
            if (ld_12 == 0.0) ld_12 = OrderOpenPrice() - li_0 * gd_332 * (TrailingStop + TrailingStep);
            if (BreakEvenAtPct > 0.0)
               if (li_0 * OrderOpenPrice() > li_0 * OrderStopLoss() && li_0 * (ld_4 - OrderOpenPrice()) / MathAbs(OrderTakeProfit() - OrderOpenPrice()) >= BreakEvenAtPct / 100.0) OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + li_0 * BreakEvenPips * gd_332, OrderTakeProfit(), 0);
            if (UseTrailing) li_28 = TRUE;
            while (li_28) {
               li_28 = FALSE;
               if (li_0 * (ld_4 - ld_12) > gd_368 + gd_332 * TrailingStep) {
                  if (TrailOnProfit) {
                     if (li_0 * (ld_4 - OrderOpenPrice()) / gd_332 <= TrailingStop + TrailingStep) continue;
                     if (li_0 * ld_12 < li_0 * OrderOpenPrice()) ld_12 = OrderOpenPrice() + li_0 * gd_332 * TrailingStep;
                     else ld_12 += li_0 * gd_332 * TrailingStep;
                     if (!(OrderModify(OrderTicket(), OrderOpenPrice(), ld_12, OrderTakeProfit(), 0))) continue;
                     li_28 = TRUE;
                     continue;
                  }
                  ld_12 += li_0 * gd_332 * TrailingStep;
                  OrderModify(OrderTicket(), OrderOpenPrice(), ld_12, OrderTakeProfit(), 0);
                  li_28 = TRUE;
               }
            }
         }
      }
   }
}

int MyTPClose(int ai_0, double ad_4) {
   int li_32;
   double ld_12 = Bid;
   int li_20 = 1;
   double ld_24 = 0;
   if (OrderSelect(gi_348, SELECT_BY_TICKET) != FALSE) {
      if (OrderType() == OP_SELL) {
         ld_12 = Ask;
         li_20 = -1;
      }
      if (li_20 * ((ld_12 - OrderOpenPrice()) / gd_332) >= ai_0) {
         ld_24 = MathMax(NormalizeDouble(OrderLots() * (ad_4 / 100.0), gi_408), MarketInfo(Symbol(), MODE_MINLOT));
         if (!(OrderClose(gi_348, ld_24, ld_12, gd_340))) return (0);
         li_32 = OrdersTotal();
         for (int li_36 = 0; li_36 < li_32; li_36++) {
            if (OrderSelect(li_36, SELECT_BY_POS, MODE_TRADES) != FALSE) {
               if (OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) {
                  OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), OrderExpiration());
                  gi_348 = OrderTicket();
                  return (gi_348);
               }
            }
         }
         return (1);
         return (0);
      }
   }
   return (0);
}

int check_open() {
   return (check_signal(0));
}

int check_signal(int ai_0) {
   double ld_16;
   double ld_24;
   double ld_40;
   double ld_48;
   int li_4 = 0;
   int li_8 = 1;
   int li_12 = is_ribbon(ai_0);
   if (li_12 == 0) li_4++;
   if (li_12 == 1) li_4--;
   if (ConfirmWithDPI) {
      li_8++;
      ld_16 = iCustom(NULL, 0, "DPI", gi_272, gi_276, 0, ai_0);
      ld_24 = iCustom(NULL, 0, "DPI", gi_272, gi_276, 1, ai_0);
      if (ld_16 != EMPTY_VALUE || ld_24 != EMPTY_VALUE) li_4--;
      else li_4++;
   }
   double ld_32 = iMA(NULL, 0, gi_284, 0, MODE_EMA, PRICE_CLOSE, ai_0);
   if (ConfirmWith3rdEMA) {
      li_8++;
      ld_40 = iMA(NULL, 0, gi_288, 0, MODE_EMA, PRICE_CLOSE, ai_0);
      if (ld_32 < ld_40) li_4--;
      if (ld_32 > ld_40) li_4++;
   }
   if (ConfirmWith4thEMA) {
      li_8++;
      ld_48 = iMA(NULL, 0, gi_292, 0, MODE_EMA, PRICE_CLOSE, ai_0);
      if (ld_32 < ld_48) li_4--;
      if (ld_32 > ld_48) li_4++;
   }
   if (li_8 == li_4) {
      if (!(!IsTesting())) return (0);
      MyArrowObject(0, ai_0);
      return (0);
   }
   if (li_8 == -li_4) {
      if (!(!IsTesting())) return (1);
      MyArrowObject(1, ai_0);
      return (1);
   }
   return (-1);
}

int is_ribbon(int ai_0) {
   double ld_4;
   double ld_12;
   bool li_20 = TRUE;
   bool li_24 = TRUE;
   bool li_28 = FALSE;
   bool li_32 = FALSE;
   for (int li_36 = 1; li_36 <= 3; li_36++) {
      ld_4 = iMA(NULL, 0, gi_280, 0, MODE_EMA, PRICE_CLOSE, ai_0 + li_36);
      ld_12 = iMA(NULL, 0, gi_284, 0, MODE_EMA, PRICE_CLOSE, ai_0 + li_36);
      if (ld_4 > ld_12) li_20 = FALSE;
      else li_24 = FALSE;
      if (High[ai_0 + li_36] >= ld_12 && li_36 <= 2) li_28 = TRUE;
      if (Low[ai_0 + li_36] <= ld_12 && li_36 <= 2) li_32 = TRUE;
   }
   double ld_40 = iMA(NULL, 0, gi_280, 0, MODE_EMA, PRICE_CLOSE, ai_0);
   double ld_48 = iMA(NULL, 0, gi_284, 0, MODE_EMA, PRICE_CLOSE, ai_0);
   double ld_56 = iMA(NULL, 0, gi_280, 0, MODE_EMA, PRICE_CLOSE, ai_0 + 1);
   double ld_64 = iSAR(NULL, 0, gd_296, gd_304, ai_0);
   if (ld_40 < ld_48 && Close[ai_0 + 1] < ld_56 && Close[ai_0 + 1] < Open[ai_0 + 1] && li_28 && li_20 && bNewSignal(1, ai_0) && ld_64 > Open[ai_0]) return (1);
   if (ld_40 > ld_48 && Close[ai_0 + 1] > ld_56 && Close[ai_0 + 1] > Open[ai_0 + 1] && li_32 && li_24 && bNewSignal(0, ai_0) && ld_64 < Open[ai_0]) return (0);
   return (-1);
}

int bNewSignal(int ai_0, int ai_4) {
   double ld_8;
   for (int li_16 = ai_4 + 1; li_16 < ai_4 + 10; li_16++) {
      ld_8 = iSAR(NULL, 0, gd_296, gd_304, li_16);
      if (ai_0 == 0) {
         if (ld_8 > High[li_16]) return (1);
      } else
         if (ld_8 < Low[li_16]) return (1);
      if (ObjectFind("Arrow_SRT_" + ai_0 + "_" + Time[li_16]) != -1) return (0);
   }
   return (1);
}

void CheckOrder() {
   int li_0 = -1;
   li_0 = check_open();
   if (li_0 != -1) {
      if (gi_348 == 0) {
         OpenTrade(li_0);
         return;
      }
      if (CloseOnReverse) {
         if (OrderSelect(gi_348, SELECT_BY_TICKET) != FALSE) {
            if (OrderType() != li_0) {
               if (OrderType() == OP_BUY) {
                  if (!(OrderClose(gi_348, OrderLots(), Bid, gd_340))) return;
                  OpenTrade(li_0);
                  return;
               }
               if (OrderClose(gi_348, OrderLots(), Ask, gd_340)) OpenTrade(li_0);
            }
         }
      }
   }
}

double MyLotCalc() {
   if (LotSize != 0.0) return (LotSize);
   double ld_0 = RiskPercent * AccountEquity() / 100.0;
   double ld_8 = ld_0 / (StopLoss * MarketInfo(Symbol(), MODE_TICKVALUE)) / (gd_332 / Point);
   if (ld_8 < MarketInfo(Symbol(), MODE_MINLOT)) ld_8 = MarketInfo(Symbol(), MODE_MINLOT);
   if (ld_8 > MarketInfo(Symbol(), MODE_MAXLOT)) ld_8 = MarketInfo(Symbol(), MODE_MAXLOT);
   int li_16 = 2;
   if (MarketInfo(Symbol(), MODE_LOTSTEP) == 0.1) li_16 = 1;
   if (MarketInfo(Symbol(), MODE_LOTSTEP) == 1.0) li_16 = 0;
   ld_8 = NormalizeDouble(ld_8, li_16);
   return (ld_8);
}

void MyArrowObject(int ai_0, int ai_4 = 0) {
   color li_8;
   int li_12;
   double ld_16;
   double ld_24;
   string ls_32;
   int li_40;
   if (ai_0 != -1) {
      li_8 = TPColor;
      li_12 = 241;
      ld_16 = Low[ai_4] - 5.0 * gd_332;
      ld_24 = 0;
      ls_32 = "Arrow_SRT_" + ai_0 + "_" + Time[ai_4];
      li_40 = Time[ai_4];
      if (ai_0 == 1) {
         li_8 = SLColor;
         li_12 = 242;
         ld_16 = High[ai_4] + gd_332 * Period() / 1.0;
      }
      ObjectCreate(ls_32, OBJ_ARROW, 0, li_40, ld_16);
      ObjectSet(ls_32, OBJPROP_COLOR, li_8);
      ObjectSet(ls_32, OBJPROP_ARROWCODE, li_12);
      ObjectSet(ls_32, OBJPROP_WIDTH, 4);
   }
}

void objectCreate(string as_0, int ai_8, int ai_12, string as_16 = "", int ai_24 = 12, string as_28 = "Arial", color ai_36 = -1) {
   ObjectCreate(as_0, OBJ_LABEL, 0, 0, 0);
   ObjectSet(as_0, OBJPROP_CORNER, 1);
   ObjectSet(as_0, OBJPROP_COLOR, ai_36);
   ObjectSet(as_0, OBJPROP_XDISTANCE, ai_8);
   ObjectSet(as_0, OBJPROP_YDISTANCE, ai_12);
   ObjectSetText(as_0, as_16, ai_24, as_28, ai_36);
}