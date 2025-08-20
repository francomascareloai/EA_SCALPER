/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website: H ttP:/ / ww W.mEtA q uO tE S. net
   E-mail :  s u pP O RT @ MEta Q u Ot eS.N ET
*/
#property copyright "Copyright © 2010 Nikolay Zacharenkov"
#property link      ""

#property indicator_chart_window

#include <WinUser32.mqh>
#import "user32.dll"
   int GetParent(int a0);
   int OpenIcon(int a0);
   int BringWindowToTop(int a0);
   int FlashWindow(int a0, int a1);
#import

extern bool Show_Copyright = FALSE;
extern int nPeriod = 60;
extern int FindFor = 15;
extern int Limit = 300;
extern int LabelPoint = 15;
extern bool LabelShow = TRUE;
extern bool OpenWindows_5Point = TRUE;
extern bool Alert_5Point = TRUE;
extern bool OnlyDiver = FALSE;
extern color WolfBullColor = Blue;
extern color WolfBeerColor = Red;
extern color SweetZoneColor = Yellow;
extern int MACDFastEMA = 12;
extern int MACDSlowEMA = 26;
extern int MACDSignalSMA = 9;
int G_timeframe_136;
bool Gi_140 = FALSE;
bool Gi_144 = FALSE;
int Gi_unused_148;
int Gi_unused_152;
int Gi_unused_156;
int Gi_unused_160;
double Gd_unused_164;
double Gd_unused_172;
double Gd_unused_180;
double Gd_unused_188;
bool Gi_196;
bool Gi_200;
bool Gi_204;
bool Gi_208;
double Gd_212;
double Gd_220;
double Gd_228;
double Gd_236;
bool Gi_244;
int G_shift_248;
int Gi_252;
int Gi_256;
double Gd_260;
double Gd_268;
double Gd_276;
double Gd_284;
bool Gi_292;
int G_shift_296;
int Gi_300;
int Gi_304;
double Gd_308;
double Gd_316;
double Gd_324;
double Gd_332;
double Gda_340[6];
int Gia_344[6];
double Gda_348[6];
int Gia_352[6];
bool Gi_unused_356 = TRUE;
int Gi_360;
int Gi_364 = 0;
bool Gi_unused_368 = TRUE;
bool Gi_372 = FALSE;
int Gi_376;
double Gd_380;
int Gi_388;
double Gd_392;
int Gi_400;
double Gd_404;
int Gi_412;
double Gd_416;
bool Gi_428 = TRUE;
datetime G_time_432 = 0;

int init() {
   for (Gi_360 = 3; Gi_360 <= 5; Gi_360++) {
      ObjectCreate("Trend DN-" + Gi_360, OBJ_TREND, 0, 0, 0, 0, 0);
      ObjectSet("Trend DN-" + Gi_360, OBJPROP_COLOR, WolfBullColor);
      ObjectCreate("Trend UP-" + Gi_360, OBJ_TREND, 0, 0, 0, 0, 0);
      ObjectSet("Trend Up-" + Gi_360, OBJPROP_COLOR, WolfBeerColor);
   }
   for (Gi_360 = 1; Gi_360 <= 2; Gi_360++) {
      ObjectCreate("LabelWolfBeerS-" + Gi_360, OBJ_TEXT, 0, 0, 0);
      ObjectSetText("LabelWolfBeerS-" + Gi_360, "se" + Gi_360, 12, "Times New Roman", WolfBeerColor);
      ObjectCreate("LabelWolfBullS-" + Gi_360, OBJ_TEXT, 0, 0, 0);
      ObjectSetText("LabelWolfBullS-" + Gi_360, "su" + Gi_360, 12, "Times New Roman", WolfBullColor);
      ObjectCreate("ManyWolf-" + Gi_360, OBJ_ARROW, 0, 0, 0);
      ObjectSet("ManyWolf-" + Gi_360, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
      ObjectCreate("SweetTriangle-" + Gi_360, OBJ_TRIANGLE, 0, 0, 0);
      ObjectSet("SweetTriangle-" + Gi_360, OBJPROP_COLOR, SweetZoneColor);
   }
   ObjectCreate("SweetZone-12", OBJ_CHANNEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSet("SweetZone-12", OBJPROP_COLOR, WolfBeerColor);
   ObjectSet("SweetZone-12", OBJPROP_BACK, FALSE);
   ObjectSet("SweetZone-12", OBJPROP_RAY, FALSE);
   ObjectSet("SweetZone-12", OBJPROP_WIDTH, 2);
   ObjectCreate("SweetZone-22", OBJ_CHANNEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSet("SweetZone-22", OBJPROP_COLOR, WolfBullColor);
   ObjectSet("SweetZone-22", OBJPROP_BACK, FALSE);
   ObjectSet("SweetZone-22", OBJPROP_RAY, FALSE);
   ObjectSet("SweetZone-22", OBJPROP_WIDTH, 2);
   return (0);
}

int deinit() {
   for (Gi_360 = 3; Gi_360 <= 5; Gi_360++) {
      ObjectDelete("Trend UP-" + Gi_360);
      ObjectDelete("Trend DN-" + Gi_360);
      ObjectDelete("LABELUP-" + Gi_360);
      ObjectDelete("LABELDOWN-" + Gi_360);
   }
   ObjectDelete("SweetZone-11");
   ObjectDelete("SweetZone-21");
   ObjectDelete("SweetZone-12");
   ObjectDelete("SweetZone-22");
   for (Gi_360 = 1; Gi_360 <= 4; Gi_360++) {
      ObjectDelete("LabelWolfBeerS-" + Gi_360);
      ObjectDelete("LabelWolfBullS-" + Gi_360);
      ObjectDelete("ManyWolf-" + Gi_360);
      ObjectDelete("SweetTriangle-" + Gi_360);
   }
   return (0);
}

int start() {
   string Lsa_0[256];
   bool Li_12;
   string Ls_16;
   int Li_24;
   if (IsConnected()) {
      if (GetLastError() == 0/* NO_ERROR */) {
         for (int index_4 = 0; index_4 < 256; index_4++) Lsa_0[index_4] = CharToStr(index_4);
         if (Show_Copyright == TRUE) {
            Comment(Lsa_0[67] + Lsa_0[111] + Lsa_0[112] + Lsa_0[121] + Lsa_0[114] + Lsa_0[105] + Lsa_0[103] + Lsa_0[104] + Lsa_0[116] + Lsa_0[32] + Lsa_0[169] + Lsa_0[32] + Lsa_0[50] +
               Lsa_0[48] + Lsa_0[49] + Lsa_0[48] + Lsa_0[44] + Lsa_0[32] + Lsa_0[78] + Lsa_0[105] + Lsa_0[107] + Lsa_0[111] + Lsa_0[108] + Lsa_0[97] + Lsa_0[121] + Lsa_0[32] + Lsa_0[90] +
               Lsa_0[97] + Lsa_0[99] + Lsa_0[104] + Lsa_0[97] + Lsa_0[114] + Lsa_0[101] + Lsa_0[110] + Lsa_0[107] + Lsa_0[111] + Lsa_0[118]);
         } else Comment(Lsa_0[32] + Lsa_0[32] + Lsa_0[32] + Lsa_0[32] + Lsa_0[32]);
         Gi_372 = FALSE;
         if (Fun_New_Bar() == 1 || Gi_428 == TRUE || G_timeframe_136 != Period()) {
            Gi_428 = FALSE;
            Gi_372 = TRUE;
            G_timeframe_136 = Period();
            for (Gi_360 = 3; Gi_360 <= 5; Gi_360++) {
               ObjectDelete("Trend UP-" + Gi_360);
               ObjectCreate("Trend UP-" + Gi_360, OBJ_TREND, 0, 0, 0, 0, 0);
               ObjectSet("Trend Up-" + Gi_360, OBJPROP_COLOR, WolfBeerColor);
               ObjectDelete("Trend DN-" + Gi_360);
               ObjectCreate("Trend DN-" + Gi_360, OBJ_TREND, 0, 0, 0, 0, 0);
               ObjectSet("Trend DN-" + Gi_360, OBJPROP_COLOR, WolfBullColor);
            }
            ObjectDelete("SweetZone-12");
            ObjectCreate("SweetZone-12", OBJ_CHANNEL, 0, 0, 0, 0, 0, 0, 0);
            ObjectSet("SweetZone-12", OBJPROP_COLOR, WolfBeerColor);
            ObjectSet("SweetZone-12", OBJPROP_BACK, FALSE);
            ObjectSet("SweetZone-12", OBJPROP_RAY, FALSE);
            ObjectSet("SweetZone-12", OBJPROP_WIDTH, 2);
            ObjectDelete("SweetZone-22");
            ObjectCreate("SweetZone-22", OBJ_CHANNEL, 0, 0, 0, 0, 0, 0, 0);
            ObjectSet("SweetZone-22", OBJPROP_COLOR, WolfBullColor);
            ObjectSet("SweetZone-22", OBJPROP_BACK, FALSE);
            ObjectSet("SweetZone-22", OBJPROP_RAY, FALSE);
            ObjectSet("SweetZone-22", OBJPROP_WIDTH, 2);
            for (Gi_360 = 1; Gi_360 <= 4; Gi_360++) {
               ObjectDelete("LabelWolfBeerS-" + Gi_360);
               ObjectCreate("LabelWolfBeerS-" + Gi_360, OBJ_TEXT, 0, 0, 0);
               ObjectSetText("LabelWolfBeerS-" + Gi_360, "se" + Gi_360, 12, "Times New Roman", WolfBeerColor);
               ObjectDelete("LabelWolfBullS-" + Gi_360);
               ObjectCreate("LabelWolfBullS-" + Gi_360, OBJ_TEXT, 0, 0, 0);
               ObjectSetText("LabelWolfBullS-" + Gi_360, "su" + Gi_360, 12, "Times New Roman", WolfBullColor);
               ObjectDelete("ManyWolf-" + Gi_360);
               ObjectCreate("ManyWolf-" + Gi_360, OBJ_ARROW, 0, 0, 0);
               ObjectSet("ManyWolf-" + Gi_360, OBJPROP_ARROWCODE, SYMBOL_LEFTPRICE);
               ObjectDelete("SweetTriangle-" + Gi_360);
               ObjectCreate("SweetTriangle-" + Gi_360, OBJ_TRIANGLE, 0, 0, 0);
               ObjectSet("SweetTriangle-" + Gi_360, OBJPROP_COLOR, SweetZoneColor);
            }
            Gi_unused_148 = 0;
            Gi_unused_152 = 0;
            Gi_unused_156 = 0;
            Gi_unused_160 = 0;
            Gd_unused_164 = 0;
            Gd_unused_172 = 0;
            Gd_unused_180 = 0;
            Gd_unused_188 = 0;
            Gi_196 = FALSE;
            Gi_200 = FALSE;
            Gi_204 = FALSE;
            Gi_208 = FALSE;
            Gd_212 = 0;
            Gd_220 = 0;
            Gd_228 = 0;
            Gd_236 = 0;
            Gi_244 = FALSE;
            G_shift_248 = 0;
            Gi_252 = 0;
            Gi_256 = 0;
            Gd_260 = 0;
            Gd_268 = 0;
            Gd_276 = 0;
            Gd_284 = 0;
            Gi_292 = FALSE;
            G_shift_296 = 0;
            Gi_300 = 0;
            Gi_304 = 0;
            Gd_308 = 0;
            Gd_316 = 0;
            Gd_324 = 0;
            Gd_332 = 0;
            Gi_144 = FALSE;
            Gi_140 = FALSE;
            for (int Li_8 = FindFor; Li_8 < nPeriod; Li_8 += 5) {
               if (Bars < Limit) Limit = Bars - Li_8;
               for (Gi_364 = Limit; Gi_364 > 0; Gi_364--) {
                  if (Low[Gi_364 + (Li_8 - 1) / 2] == Low[iLowest(NULL, 0, MODE_LOW, Li_8, Gi_364)]) {
                     if (Gia_344[0] <= Gia_352[0] && Low[Gi_364 + (Li_8 - 1) / 2] < Gda_340[0] && Gda_340[0] != 0.0) {
                        Gda_340[0] = Low[Gi_364 + (Li_8 - 1) / 2];
                        Gia_344[0] = Gi_364 + (Li_8 - 1) / 2;
                     } else {
                        if (!(Gia_344[0] <= Gia_352[0] && Low[Gi_364 + (Li_8 - 1) / 2] >= Gda_340[0]) || !(Gda_340[0] != 0.0)) {
                           Gda_340[5] = Gda_340[4];
                           Gda_340[4] = Gda_340[3];
                           Gda_340[3] = Gda_340[2];
                           Gda_340[2] = Gda_340[1];
                           Gda_340[1] = Gda_340[0];
                           Gda_340[0] = Low[Gi_364 + (Li_8 - 1) / 2];
                           Gia_344[5] = Gia_344[4];
                           Gia_344[4] = Gia_344[3];
                           Gia_344[3] = Gia_344[2];
                           Gia_344[2] = Gia_344[1];
                           Gia_344[1] = Gia_344[0];
                           Gia_344[0] = Gi_364 + (Li_8 - 1) / 2;
                        }
                     }
                  }
                  if (High[Gi_364 + (Li_8 - 1) / 2] == High[iHighest(NULL, 0, MODE_HIGH, Li_8, Gi_364)]) {
                     if (Gia_352[0] <= Gia_344[0] && High[Gi_364 + (Li_8 - 1) / 2] > Gda_348[0] && Gda_348[0] != 0.0) {
                        Gda_348[0] = High[Gi_364 + (Li_8 - 1) / 2];
                        Gia_352[0] = Gi_364 + (Li_8 - 1) / 2;
                        continue;
                     }
                     if (Gia_352[0] <= Gia_344[0] && High[Gi_364 + (Li_8 - 1) / 2] <= Gda_348[0] && Gda_348[0] != 0.0) continue;
                     Gda_348[5] = Gda_348[4];
                     Gda_348[4] = Gda_348[3];
                     Gda_348[3] = Gda_348[2];
                     Gda_348[2] = Gda_348[1];
                     Gda_348[1] = Gda_348[0];
                     Gda_348[0] = High[Gi_364 + (Li_8 - 1) / 2];
                     Gia_352[5] = Gia_352[4];
                     Gia_352[4] = Gia_352[3];
                     Gia_352[3] = Gia_352[2];
                     Gia_352[2] = Gia_352[1];
                     Gia_352[1] = Gia_352[0];
                     Gia_352[0] = Gi_364 + (Li_8 - 1) / 2;
                  }
               }
               Analiz(Li_8);
               if (Gi_144 != FALSE && Gi_140 != FALSE) Gi_364 = 0;
            }
            if (Gi_144 != FALSE && Gi_140 != FALSE) Li_8 = nPeriod;
         }
         WindowRedraw();
         if (Gi_372 == TRUE && BullMassage() == 1 || BeerMassage() == 1) {
            Gi_388 = Gi_376;
            Gd_392 = Gd_380;
            Gi_412 = Gi_400;
            Gd_416 = Gd_404;
         } else {
            Li_12 = FALSE;
            if (BeerMassage() == 1 && Gi_388 != Gi_376 || Gd_392 != Gd_380) Li_12 = TRUE;
            if (BullMassage() == 1 && Gi_412 != Gi_400 || Gd_416 != Gd_404) Li_12 = TRUE;
            if (Li_12 != FALSE) {
               if (OnlyDiver == TRUE && ObjectGet("ManyWolf-1", OBJPROP_COLOR) != WolfBeerColor) return;
               if (OnlyDiver == TRUE && ObjectGet("ManyWolf-2", OBJPROP_COLOR) != WolfBeerColor) return;
               if (Alert_5Point == TRUE) {
                  Ls_16 = " ";
                  if (Period() == PERIOD_M1) Ls_16 = "M1";
                  if (Period() == PERIOD_M5) Ls_16 = "M5";
                  if (Period() == PERIOD_M15) Ls_16 = "M15";
                  if (Period() == PERIOD_M30) Ls_16 = "M30";
                  if (Period() == PERIOD_H1) Ls_16 = "H1";
                  if (Period() == PERIOD_H4) Ls_16 = "H4";
                  if (Period() == PERIOD_D1) Ls_16 = "D1";
                  if (Period() == PERIOD_W1) Ls_16 = "W1";
                  if (Period() > PERIOD_W1) Ls_16 = "MN";
                  Alert("На паре ", Symbol(), "(", Ls_16, ") найдены Волны Вульфа");
               } else PlaySound("news.wav");
               if (OpenWindows_5Point == TRUE) {
                  Li_24 = Parent();
                  FlashWindow(Li_24, 1);
                  Li_24 = WindowHandle(Symbol(), 0);
                  Li_24 = GetParent(Li_24);
                  OpenIcon(Li_24);
                  BringWindowToTop(Li_24);
               }
               Gi_388 = Gi_376;
               Gd_392 = Gd_380;
               Gi_412 = Gi_400;
               Gd_416 = Gd_404;
            }
         }
      }
   }
   return (0);
}

void Analiz(int Ai_unused_0) {
   double Ld_4;
   double Ld_12;
   for (int Li_20 = 1; Li_20 < 5; Li_20++) {
      Ld_4 = Razmer(Gia_344[Li_20], Gda_340[Li_20], Gia_352[Li_20], Gda_348[Li_20]);
      Ld_12 = Razmer(Gia_344[Li_20 - 1], Gda_340[Li_20 - 1], Gia_352[Li_20 - 1], Gda_348[Li_20 - 1]);
      if (Gi_144 != TRUE && Ld_12 < Ld_4 && Gda_340[Li_20] <= Gda_340[Li_20 - 1] && Gda_348[Li_20] <= Gda_348[Li_20 - 1] && Gda_340[Li_20 - 1] < Gda_348[Li_20] && Gia_344[Li_20 - 1] < Gia_352[Li_20 - 1] &&
         Gia_352[Li_20 - 1] < Gia_344[Li_20] && Gia_344[Li_20] < Gia_352[Li_20]) {
         if (!(Gia_352[Li_20] == Gi_244 && Gda_348[Li_20] == Gd_260 && Gia_352[Li_20 - 1] == G_shift_248 && Gda_348[Li_20 - 1] == Gd_268 && Gia_344[Li_20] == Gi_252 && Gda_340[Li_20] == Gd_276 &&
            Gia_344[Li_20 - 1] == Gi_256) || !(Gda_340[Li_20 - 1] == Gd_284)) WolfBeerXY(Gia_352[Li_20], Gda_348[Li_20], Gia_352[Li_20 - 1], Gda_348[Li_20 - 1], Gia_344[Li_20], Gda_340[Li_20], Gia_344[Li_20 - 1], Gda_340[Li_20 - 1], STYLE_DASH);
      }
      Ld_4 = Razmer(Gia_352[Li_20 + 1], Gda_348[Li_20 + 1], Gia_344[Li_20], Gda_340[Li_20]);
      Ld_12 = Razmer(Gia_352[Li_20], Gda_348[Li_20], Gia_344[Li_20 - 1], Gda_340[Li_20 - 1]);
      if (Gi_144 != TRUE && Ld_12 < Ld_4 && Gda_340[Li_20] <= Gda_340[Li_20 - 1] && Gda_348[Li_20 + 1] <= Gda_348[Li_20] && Gda_340[Li_20 - 1] < Gda_348[Li_20 + 1] && Gia_344[Li_20] < Gia_352[Li_20 +
         1] && Gia_352[Li_20] < Gia_344[Li_20] && Gia_344[Li_20] < Gia_352[Li_20 + 1]) {
         if (!(Gia_352[Li_20 + 1] == Gi_244 && Gda_348[Li_20 + 1] == Gd_260 && Gia_352[Li_20] == G_shift_248 && Gda_348[Li_20] == Gd_268 && Gia_344[Li_20] == Gi_252 && Gda_340[Li_20] == Gd_276 &&
            Gia_344[Li_20 - 1] == Gi_256) || !(Gda_340[Li_20 - 1] == Gd_284)) WolfBeerXY(Gia_352[Li_20 + 1], Gda_348[Li_20 + 1], Gia_352[Li_20], Gda_348[Li_20], Gia_344[Li_20], Gda_340[Li_20], Gia_344[Li_20 - 1], Gda_340[Li_20 - 1], STYLE_DASH);
      }
      Ld_4 = Razmer(Gia_344[Li_20], Gda_340[Li_20], Gia_352[Li_20], Gda_348[Li_20]);
      Ld_12 = Razmer(Gia_344[Li_20 - 1], Gda_340[Li_20 - 1], Gia_352[Li_20 - 1], Gda_348[Li_20 - 1]);
      if (Gi_140 != TRUE && Ld_12 < Ld_4 && Gda_340[Li_20] >= Gda_340[Li_20 - 1] && Gda_348[Li_20] >= Gda_348[Li_20 - 1] && Gda_348[Li_20 - 1] > Gda_340[Li_20] && Gia_352[Li_20 - 1] < Gia_344[Li_20 - 1] &&
         Gia_344[Li_20 - 1] < Gia_352[Li_20] && Gia_352[Li_20] < Gia_344[Li_20]) {
         if (!(Gia_344[Li_20] == Gi_292 && Gda_340[Li_20] == Gd_308 && Gia_344[Li_20 - 1] == G_shift_296 && Gda_340[Li_20 - 1] == Gd_316 && Gia_352[Li_20] == Gi_300 && Gda_348[Li_20] == Gd_324 &&
            Gia_352[Li_20 - 1] == Gi_304) || !(Gda_348[Li_20 - 1] == Gd_332)) {
            if (!(Gia_344[Li_20] == Gi_196 && Gda_340[Li_20] == Gd_212 && Gia_344[Li_20 - 1] == Gi_200 && Gda_340[Li_20 - 1] == Gd_220 && Gia_352[Li_20] == Gi_204 && Gda_348[Li_20] == Gd_228 &&
               Gia_352[Li_20 - 1] == Gi_208) || !(Gda_348[Li_20 - 1] == Gd_236)) WolfBullXY(Gia_344[Li_20], Gda_340[Li_20], Gia_344[Li_20 - 1], Gda_340[Li_20 - 1], Gia_352[Li_20], Gda_348[Li_20], Gia_352[Li_20 - 1], Gda_348[Li_20 - 1], STYLE_DASH);
         }
      }
      Ld_4 = Razmer(Gia_344[Li_20 + 1], Gda_340[Li_20 + 1], Gia_352[Li_20], Gda_348[Li_20]);
      Ld_12 = Razmer(Gia_344[Li_20], Gda_340[Li_20], Gia_352[Li_20 - 1], Gda_348[Li_20 - 1]);
      if (Gi_140 != TRUE && Ld_12 < Ld_4 && Gda_340[Li_20 + 1] >= Gda_340[Li_20] && Gda_348[Li_20] >= Gda_348[Li_20 - 1] && Gda_348[Li_20 - 1] > Gda_340[Li_20 + 1] && Gia_352[Li_20 - 1] < Gia_344[Li_20] &&
         Gia_344[Li_20] < Gia_352[Li_20] && Gia_352[Li_20] < Gia_344[Li_20 + 1]) {
         if (Gia_344[Li_20 + 1] == Gi_292 && Gda_340[Li_20 + 1] == Gd_308 && Gia_344[Li_20] == G_shift_296 && Gda_340[Li_20] == Gd_316 && Gia_352[Li_20] == Gi_300 && Gda_348[Li_20] == Gd_324 &&
            Gia_352[Li_20 - 1] == Gi_304 && Gda_348[Li_20 - 1] == Gd_332) continue;
         if (Gia_344[Li_20 + 1] == Gi_196 && Gda_340[Li_20 + 1] == Gd_212 && Gia_344[Li_20] == Gi_200 && Gda_340[Li_20] == Gd_220 && Gia_352[Li_20] == Gi_204 && Gda_348[Li_20] == Gd_228 &&
            Gia_352[Li_20 - 1] == Gi_208 && Gda_348[Li_20 - 1] == Gd_236) continue;
         WolfBullXY(Gia_344[Li_20 + 1], Gda_340[Li_20 + 1], Gia_344[Li_20], Gda_340[Li_20], Gia_352[Li_20], Gda_348[Li_20], Gia_352[Li_20 - 1], Gda_348[Li_20 - 1], STYLE_DASH);
      }
   }
}

double Razmer(int Ai_0, double Ad_4, int Ai_12, double Ad_16) {
   double Ld_24;
   Ld_24 = MathSqrt((Ai_0 * Point - Ai_12 * Point) * (Ai_0 * Point - Ai_12 * Point) + (Ad_4 - Ad_16) * (Ad_4 - Ad_16));
   return (Ld_24);
}

void WolfBeerXY(int Ai_0, double Ad_4, int A_shift_12, double Ad_16, int Ai_24, double Ad_28, int Ai_36, double Ad_40, int A_style_48) {
   double Ld_52;
   double Ld_60;
   int Li_68;
   int Li_unused_72;
   double Ld_unused_76;
   int Li_unused_84;
   double Ld_88;
   if (Gi_144 != TRUE) {
      Gi_244 = Ai_0;
      G_shift_248 = A_shift_12;
      Gi_252 = Ai_24;
      Gi_256 = Ai_36;
      Gd_260 = Ad_4;
      Gd_268 = Ad_16;
      Gd_276 = Ad_28;
      Gd_284 = Ad_40;
      Gi_144 = TRUE;
      ObjectSet("Trend Up-3", OBJPROP_STYLE, A_style_48);
      ObjectSet("Trend Up-4", OBJPROP_STYLE, A_style_48);
      ObjectSet("Trend Up-5", OBJPROP_STYLE, STYLE_DASH);
      ObjectSet("Trend Up-5", OBJPROP_WIDTH, 2);
      ObjectMove("Trend UP-3", 0, Time[Ai_0], Ad_4);
      ObjectMove("Trend UP-3", 1, Time[A_shift_12], Ad_16);
      ObjectMove("Trend UP-4", 0, Time[Ai_24], Ad_28);
      ObjectMove("Trend UP-4", 1, Time[Ai_36], Ad_40);
      Ld_52 = ObjectGetValueByShift("Trend UP-3", Ai_24) - ObjectGetValueByShift("Trend UP-4", Ai_24);
      Ld_60 = ObjectGetValueByShift("Trend UP-3", Ai_36) - ObjectGetValueByShift("Trend UP-4", Ai_36);
      if (Ld_52 < Ld_60) {
         Gi_244 = FALSE;
         Gd_260 = 0;
         G_shift_248 = 0;
         Gd_268 = 0;
         Gi_252 = 0;
         Gd_276 = 0;
         Gi_256 = 0;
         Gd_284 = 0;
         Gi_144 = FALSE;
         ObjectDelete("Trend UP-3");
         ObjectCreate("Trend UP-3", OBJ_TREND, 0, 0, 0, 0, 0);
         ObjectSet("Trend Up-3", OBJPROP_COLOR, WolfBeerColor);
         ObjectDelete("Trend UP-4");
         ObjectCreate("Trend UP-4", OBJ_TREND, 0, 0, 0, 0, 0);
         ObjectSet("Trend Up-4", OBJPROP_COLOR, WolfBeerColor);
         ObjectDelete("Trend UP-5");
         ObjectCreate("Trend UP-5", OBJ_TREND, 0, 0, 0, 0, 0);
         ObjectSet("Trend Up-5", OBJPROP_COLOR, WolfBeerColor);
         ObjectDelete("SweetZone-12");
         ObjectCreate("SweetZone-12", OBJ_CHANNEL, 0, 0, 0, 0, 0, 0, 0);
         ObjectSet("SweetZone-12", OBJPROP_COLOR, WolfBeerColor);
         ObjectSet("SweetZone-12", OBJPROP_BACK, FALSE);
         ObjectSet("SweetZone-12", OBJPROP_RAY, FALSE);
         ObjectSet("SweetZone-12", OBJPROP_WIDTH, 2);
         return;
      }
      ObjectMove("Trend UP-5", 0, Time[Ai_0], Ad_4);
      ObjectMove("Trend UP-5", 1, Time[Ai_36], Ad_40);
      ObjectMove("SweetZone-12", 0, Time[Ai_24], Ad_28);
      ObjectMove("SweetZone-12", 1, Time[Ai_36], Ad_40);
      ObjectMove("SweetZone-12", 2, Time[A_shift_12], Ad_16);
      if (LabelShow == TRUE) {
         ObjectMove("LabelWolfBeerS-1", 0, Time[Ai_0], Ad_4 + LabelPoint * 2 * Point);
         ObjectMove("LabelWolfBeerS-2", 0, Time[Ai_24], Ad_28 - LabelPoint * Point);
         ObjectMove("LabelWolfBeerS-3", 0, Time[A_shift_12], Ad_16 + LabelPoint * 2 * Point);
         ObjectMove("LabelWolfBeerS-4", 0, Time[Ai_36], Ad_40 - LabelPoint * Point);
      }
      Li_68 = 0;
      Li_unused_72 = 0;
      Ld_unused_76 = 0;
      Li_unused_84 = 1;
      if (G_shift_248 - (Gi_252 - Gi_256) < 0) Li_68 = 0;
      else Li_68 = G_shift_248 - (Gi_252 - Gi_256);
      ObjectMove("SweetTriangle-2", 0, Time[G_shift_248], Gd_268);
      ObjectMove("SweetTriangle-2", 1, Time[Li_68], ObjectGetValueByShift("Trend UP-3", Li_68));
      Ld_88 = ObjectGetValueByShift("Trend UP-4", Gi_252 - (G_shift_248 - Li_68)) - ObjectGetValueByShift("Trend UP-4", Gi_252);
      ObjectMove("SweetTriangle-2", 2, Time[Li_68], Gd_268 + Ld_88);
      BeerMassage();
   }
}

int BeerMassage() {
   int Li_0 = 0;
   int shift_4 = 0;
   double high_8 = 0;
   bool Li_ret_16 = FALSE;
   if (G_shift_248 - (Gi_252 - Gi_256) < 0) Li_0 = 0;
   else Li_0 = G_shift_248 - (Gi_252 - Gi_256);
   for (int Li_20 = Gi_256; Li_20 >= Li_0; Li_20--) {
      if (ObjectGetValueByShift("Trend UP-3", Li_20) <= High[Li_20]) {
         if (Li_ret_16 == FALSE) {
            shift_4 = Li_20;
            high_8 = High[Li_20];
            Li_ret_16 = TRUE;
         }
         if (high_8 < High[Li_20]) {
            high_8 = High[Li_20];
            shift_4 = Li_20;
         }
      }
   }
   if (Li_ret_16 == TRUE && Gi_144 == TRUE) {
      ObjectMove("ManyWolf-2", 0, Time[shift_4], high_8);
      Gi_376 = ObjectGet("ManyWolf-2", OBJPROP_TIME1);
      Gd_380 = ObjectGet("ManyWolf-2", OBJPROP_PRICE1);
      if (iMACD(NULL, 0, MACDFastEMA, MACDSlowEMA, MACDSignalSMA, PRICE_HIGH, MODE_MAIN, G_shift_248) - iMACD(NULL, 0, MACDFastEMA, MACDSlowEMA, MACDSignalSMA, PRICE_HIGH,
         MODE_MAIN, shift_4) > 0.0) ObjectSet("ManyWolf-2", OBJPROP_COLOR, WolfBeerColor);
      else ObjectSet("ManyWolf-2", OBJPROP_COLOR, WolfBullColor);
   }
   return (Li_ret_16);
}

void WolfBullXY(int Ai_0, double Ad_4, int A_shift_12, double Ad_16, int Ai_24, double Ad_28, int Ai_36, double Ad_40, int A_style_48) {
   double Ld_52;
   double Ld_60;
   int Li_68;
   int Li_unused_72;
   int Li_unused_76;
   double Ld_unused_80;
   double Ld_88;
   if (Gi_140 != TRUE) {
      Gi_292 = Ai_0;
      G_shift_296 = A_shift_12;
      Gi_300 = Ai_24;
      Gi_304 = Ai_36;
      Gd_308 = Ad_4;
      Gd_316 = Ad_16;
      Gd_324 = Ad_28;
      Gd_332 = Ad_40;
      Gi_140 = TRUE;
      ObjectSet("Trend DN-3", OBJPROP_STYLE, A_style_48);
      ObjectSet("Trend DN-4", OBJPROP_STYLE, A_style_48);
      ObjectSet("Trend DN-5", OBJPROP_STYLE, STYLE_DASH);
      ObjectSet("Trend DN-5", OBJPROP_WIDTH, 2);
      ObjectMove("Trend DN-3", 0, Time[Ai_0], Ad_4);
      ObjectMove("Trend DN-3", 1, Time[A_shift_12], Ad_16);
      ObjectMove("Trend DN-4", 0, Time[Ai_24], Ad_28);
      ObjectMove("Trend DN-4", 1, Time[Ai_36], Ad_40);
      Ld_52 = ObjectGetValueByShift("Trend DN-3", Ai_24) - ObjectGetValueByShift("Trend DN-4", Ai_24);
      Ld_60 = ObjectGetValueByShift("Trend DN-3", Ai_36) - ObjectGetValueByShift("Trend DN-4", Ai_36);
      if (Ld_52 > Ld_60) {
         Gi_292 = FALSE;
         Gd_308 = 0;
         G_shift_296 = 0;
         Gd_316 = 0;
         Gi_300 = 0;
         Gd_324 = 0;
         Gi_304 = 0;
         Gd_332 = 0;
         Gi_140 = FALSE;
         ObjectDelete("Trend DN-3");
         ObjectCreate("Trend DN-3", OBJ_TREND, 0, 0, 0, 0, 0);
         ObjectSet("Trend DN-3", OBJPROP_COLOR, WolfBullColor);
         ObjectDelete("Trend DN-4");
         ObjectCreate("Trend DN-4", OBJ_TREND, 0, 0, 0, 0, 0);
         ObjectSet("Trend DN-4", OBJPROP_COLOR, WolfBullColor);
         ObjectDelete("Trend DN-5");
         ObjectCreate("Trend DN-5", OBJ_TREND, 0, 0, 0, 0, 0);
         ObjectSet("Trend DN-5", OBJPROP_COLOR, WolfBullColor);
         ObjectDelete("SweetZone-22");
         ObjectCreate("SweetZone-22", OBJ_CHANNEL, 0, 0, 0, 0, 0, 0, 0);
         ObjectSet("SweetZone-22", OBJPROP_COLOR, WolfBullColor);
         ObjectSet("SweetZone-22", OBJPROP_BACK, FALSE);
         ObjectSet("SweetZone-22", OBJPROP_RAY, FALSE);
         ObjectSet("SweetZone-22", OBJPROP_WIDTH, 2);
         return;
      }
      ObjectMove("Trend DN-5", 0, Time[Ai_0], Ad_4);
      ObjectMove("Trend DN-5", 1, Time[Ai_36], Ad_40);
      ObjectMove("SweetZone-22", 0, Time[Ai_24], Ad_28);
      ObjectMove("SweetZone-22", 1, Time[Ai_36], Ad_40);
      ObjectMove("SweetZone-22", 2, Time[A_shift_12], Ad_16);
      if (LabelShow == TRUE) {
         ObjectMove("LabelWolfBullS-1", 0, Time[Ai_0], Ad_4 - LabelPoint * Point);
         ObjectMove("LabelWolfBullS-2", 0, Time[Ai_24], Ad_28 + LabelPoint * 2 * Point);
         ObjectMove("LabelWolfBullS-3", 0, Time[A_shift_12], Ad_16 - LabelPoint * Point);
         ObjectMove("LabelWolfBullS-4", 0, Time[Ai_36], Ad_40 + LabelPoint * 2 * Point);
      }
      Li_68 = 0;
      Li_unused_72 = 1;
      Li_unused_76 = 0;
      Ld_unused_80 = 0;
      if (G_shift_296 - (Gi_300 - Gi_304) < 0) Li_68 = 0;
      else Li_68 = G_shift_296 - (Gi_300 - Gi_304);
      ObjectMove("SweetTriangle-1", 0, Time[G_shift_296], Gd_316);
      ObjectMove("SweetTriangle-1", 1, Time[Li_68], ObjectGetValueByShift("Trend DN-3", Li_68));
      Ld_88 = ObjectGetValueByShift("Trend DN-4", Gi_300 - (G_shift_296 - Li_68)) - ObjectGetValueByShift("Trend DN-4", Gi_300);
      ObjectMove("SweetTriangle-1", 2, Time[Li_68], Gd_316 + Ld_88);
      BullMassage();
   }
}

int BullMassage() {
   int Li_0 = 0;
   bool Li_ret_4 = FALSE;
   int shift_8 = 0;
   double low_12 = 0;
   if (G_shift_296 - (Gi_300 - Gi_304) < 0) Li_0 = 0;
   else Li_0 = G_shift_296 - (Gi_300 - Gi_304);
   for (int Li_20 = Gi_304; Li_20 >= Li_0; Li_20--) {
      if (ObjectGetValueByShift("Trend DN-3", Li_20) >= Low[Li_20]) {
         if (Li_ret_4 == FALSE) {
            shift_8 = Li_20;
            low_12 = Low[Li_20];
            Li_ret_4 = TRUE;
            continue;
         }
         if (low_12 > Low[Li_20]) {
            low_12 = Low[Li_20];
            shift_8 = Li_20;
         }
      }
   }
   if (Li_ret_4 == TRUE && Gi_140 == TRUE) {
      ObjectMove("ManyWolf-1", 0, Time[shift_8], low_12);
      Gi_400 = ObjectGet("ManyWolf-1", OBJPROP_TIME1);
      Gd_404 = ObjectGet("ManyWolf-1", OBJPROP_PRICE1);
      if (iMACD(NULL, 0, MACDFastEMA, MACDSlowEMA, MACDSignalSMA, PRICE_LOW, MODE_MAIN, G_shift_296) - iMACD(NULL, 0, MACDFastEMA, MACDSlowEMA, MACDSignalSMA, PRICE_LOW,
         MODE_MAIN, shift_8) < 0.0) ObjectSet("ManyWolf-1", OBJPROP_COLOR, WolfBeerColor);
      else ObjectSet("ManyWolf-1", OBJPROP_COLOR, WolfBullColor);
   }
   return (Li_ret_4);
}

int Fun_New_Bar() {
   if (G_time_432 == 0) {
      G_time_432 = Time[0];
      return (0);
   }
   if (G_time_432 != Time[0]) {
      G_time_432 = Time[0];
      return (1);
   }
   return (0);
}

int Parent() {
   int Li_0 = -1;
   bool Li_ret_4 = FALSE;
   while (Li_0 <= 0 && !IsStopped()) {
      Li_0 = WindowHandle(Symbol(), Period());
      Sleep(500);
   }
   while (!IsStopped()) {
      Li_0 = GetParent(Li_0);
      if (Li_0 == 0) break;
      Li_ret_4 = Li_0;
   }
   return (Li_ret_4);
}
