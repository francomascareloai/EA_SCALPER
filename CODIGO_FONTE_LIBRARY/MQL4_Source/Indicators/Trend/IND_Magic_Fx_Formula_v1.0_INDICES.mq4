/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website: HtTP : / /wW w .Me T A q u o TES.NeT
   E-mail : SU P P OrT@ m ET a qU o t es.nE T
*/
#property copyright "Copyright © 2014,MAGIC FX FORMULA"
#property link      "http://www.magicfxformula.com/"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Crimson
#property indicator_color2 DodgerBlue
#property indicator_color3 DodgerBlue
#property indicator_color4 Crimson
#property indicator_color5 DodgerBlue
#property indicator_color6 Crimson

extern bool AlertON = TRUE;
extern bool Email = TRUE;
bool Gi_84 = FALSE;
bool Gi_88 = FALSE;
string Gs_verdana_92 = "Verdana";
string Gs_100;
datetime G_time_108;
int Gi_112 = 1;
int Gi_116 = 2;
int Gi_120 = 1;
int G_shift_124 = 999;
color G_color_128 = Red;
color G_color_132 = Lime;
int G_period_136 = 9;
int Gi_140 = 4;
int Gi_144 = 200;
int Gi_148 = 234;
int Gi_152 = 233;
int G_fontsize_156 = 20;
double G_ibuf_160[];
double G_ibuf_164[];
double G_ibuf_168[];
double G_ibuf_172[];
double G_ibuf_176[];
double G_ibuf_180[];

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   SetIndexBuffer(0, G_ibuf_160);
   SetIndexStyle(0, DRAW_LINE, STYLE_DASHDOTDOT, 0);
   SetIndexArrow(0, 159);
   SetIndexDrawBegin(0, G_period_136);
   SetIndexBuffer(1, G_ibuf_164);
   SetIndexStyle(1, DRAW_LINE, STYLE_DASHDOTDOT, 0);
   SetIndexArrow(1, 159);
   SetIndexDrawBegin(1, G_period_136);
   SetIndexBuffer(2, G_ibuf_168);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 1);
   SetIndexArrow(2, 158);
   SetIndexDrawBegin(2, G_period_136);
   SetIndexBuffer(3, G_ibuf_172);
   SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, 1);
   SetIndexArrow(3, 158);
   SetIndexDrawBegin(3, G_period_136);
   SetIndexBuffer(4, G_ibuf_176);
   SetIndexStyle(4, DRAW_NONE, STYLE_DASHDOTDOT, 2);
   SetIndexDrawBegin(4, G_period_136);
   SetIndexBuffer(5, G_ibuf_180);
   SetIndexStyle(5, DRAW_NONE, STYLE_DASHDOTDOT, 2);
   SetIndexDrawBegin(5, G_period_136);
   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS));
   Gs_100 = " MagicFxFormula(" + AlertON + "," + Gi_140 + ")";
   IndicatorShortName(Gs_100);
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
void deinit() {
   if (ObjectFind("Arrow" + Gs_100) == 0) ObjectsDeleteAll();
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   int Li_0;
   double Lda_4[25000];
   double Lda_8[25000];
   double Lda_12[25000];
   double Lda_16[25000];
   double Ld_20;
   double close_28;
   for (int shift_36 = G_shift_124; shift_36 > 0; shift_36--) {
      G_ibuf_160[shift_36] = 0;
      G_ibuf_164[shift_36] = 0;
      G_ibuf_168[shift_36] = 0;
      G_ibuf_172[shift_36] = 0;
      G_ibuf_176[shift_36] = EMPTY_VALUE;
      G_ibuf_180[shift_36] = EMPTY_VALUE;
   }
   for (shift_36 = G_shift_124 - G_period_136 - 1; shift_36 > 0; shift_36--) {
      Lda_4[shift_36] = iBands(NULL, 0, G_period_136, Gi_140, 0, PRICE_CLOSE, MODE_UPPER, shift_36);
      Lda_8[shift_36] = iBands(NULL, 0, G_period_136, Gi_140, 0, PRICE_CLOSE, MODE_LOWER, shift_36);
      if (Close[shift_36] > Lda_4[shift_36 + 1]) Li_0 = 1;
      if (Close[shift_36] < Lda_8[shift_36 + 1]) Li_0 = -1;
      if (Li_0 > 0 && Lda_8[shift_36] < Lda_8[shift_36 + 1]) Lda_8[shift_36] = Lda_8[shift_36 + 1];
      if (Li_0 < 0 && Lda_4[shift_36] > Lda_4[shift_36 + 1]) Lda_4[shift_36] = Lda_4[shift_36 + 1];
      Lda_12[shift_36] = Lda_4[shift_36] + (Gi_112 - 1) / 2.0 * (Lda_4[shift_36] - Lda_8[shift_36]);
      Lda_16[shift_36] = Lda_8[shift_36] - (Gi_112 - 1) / 2.0 * (Lda_4[shift_36] - Lda_8[shift_36]);
      if (Li_0 > 0 && Lda_16[shift_36] < Lda_16[shift_36 + 1]) Lda_16[shift_36] = Lda_16[shift_36 + 1];
      if (Li_0 < 0 && Lda_12[shift_36] > Lda_12[shift_36 + 1]) Lda_12[shift_36] = Lda_12[shift_36 + 1];
      if (Li_0 > 0) {
         if (Gi_116 > 0 && G_ibuf_160[shift_36 + 1] == -1.0) {
            G_ibuf_168[shift_36] = Lda_16[shift_36];
            G_ibuf_160[shift_36] = Lda_16[shift_36];
            if (Gi_120 > 0) G_ibuf_176[shift_36] = Lda_16[shift_36];
            if (AlertON == TRUE && shift_36 == 1 && (!Gi_84)) {
               Ld_20 = Low[1];
               if (Low[2] < Ld_20) Ld_20 = Low[2];
               if (Low[3] < Ld_20) Ld_20 = Low[3];
               if (Low[4] < Ld_20) Ld_20 = Low[4];
               Ld_20 -= Gi_144 * Point;
               close_28 = Close[1];
               f0_4("LONG SIGNAL", 0, Ld_20, close_28);
               Gi_84 = TRUE;
               Gi_88 = FALSE;
            }
         } else {
            G_ibuf_160[shift_36] = Lda_16[shift_36];
            if (Gi_120 > 0) G_ibuf_176[shift_36] = Lda_16[shift_36];
            G_ibuf_168[shift_36] = -1;
         }
         if (Gi_116 == 2) G_ibuf_160[shift_36] = 0;
         G_ibuf_172[shift_36] = -1;
         G_ibuf_164[shift_36] = -1.0;
         G_ibuf_180[shift_36] = EMPTY_VALUE;
      }
      if (Li_0 < 0) {
         if (Gi_116 > 0 && G_ibuf_164[shift_36 + 1] == -1.0) {
            G_ibuf_172[shift_36] = Lda_12[shift_36];
            G_ibuf_164[shift_36] = Lda_12[shift_36];
            if (Gi_120 > 0) G_ibuf_180[shift_36] = Lda_12[shift_36];
            if (AlertON == TRUE && shift_36 == 1 && (!Gi_88)) {
               Ld_20 = High[1];
               if (High[2] > Ld_20) Ld_20 = High[2];
               if (High[3] > Ld_20) Ld_20 = High[3];
               if (High[4] > Ld_20) Ld_20 = High[4];
               Ld_20 += Gi_144 * Point;
               close_28 = Close[1];
               f0_4("SHORT SIGNAL", 0, Ld_20, close_28);
               Gi_88 = TRUE;
               Gi_84 = FALSE;
            }
         } else {
            G_ibuf_164[shift_36] = Lda_12[shift_36];
            if (Gi_120 > 0) G_ibuf_180[shift_36] = Lda_12[shift_36];
            G_ibuf_172[shift_36] = -1;
         }
         if (Gi_116 == 2) G_ibuf_164[shift_36] = 0;
         G_ibuf_168[shift_36] = -1;
         G_ibuf_160[shift_36] = -1.0;
         G_ibuf_176[shift_36] = EMPTY_VALUE;
      }
      if (G_ibuf_176[shift_36 + 1] == EMPTY_VALUE)
         if (!G_ibuf_176[shift_36] == EMPTY_VALUE) f0_3(Time[shift_36], G_ibuf_176[shift_36]);
      if (G_ibuf_180[shift_36 + 1] == EMPTY_VALUE)
         if (!G_ibuf_180[shift_36] == EMPTY_VALUE) f0_2(Time[shift_36], G_ibuf_180[shift_36]);
   }
   if (!G_ibuf_176[1] == EMPTY_VALUE)
      if (G_ibuf_180[1] == EMPTY_VALUE) f0_0(0);
   if (!G_ibuf_180[1] == EMPTY_VALUE)
      if (G_ibuf_176[1] == EMPTY_VALUE) f0_0(1);
   return (0);
}

// C7B6DA90613EE927421D7A7FC4708AFB
void f0_3(int A_datetime_0, double Ad_4) {
   if (ObjectFind("TextUp" + A_datetime_0) == -1)
      if (ObjectCreate("TextUp" + A_datetime_0, OBJ_TEXT, 0, A_datetime_0, f0_1(Ad_4 - 90.0 * Point))) ObjectSetText("TextUp" + A_datetime_0, CharToStr(108), G_fontsize_156, "Wingdings", G_color_132);
}

// 6A2268FFB9953B8035EB0FACC158A7AE
void f0_2(int A_datetime_0, double Ad_4) {
   if (ObjectFind("TextDn" + A_datetime_0) == -1)
      if (ObjectCreate("TextDn" + A_datetime_0, OBJ_TEXT, 0, A_datetime_0, f0_1(Ad_4 + 230.0 * Point))) ObjectSetText("TextDn" + A_datetime_0, CharToStr(108), G_fontsize_156, "Wingdings", G_color_128);
}

// 37C77F63CFBAF988AA4AB795B41E4919
void f0_0(int Ai_0) {
   color color_4 = CLR_NONE;
   string text_8 = "";
   string text_16 = "";
   if (Ai_0 == 0) {
      color_4 = G_color_132;
      text_8 = CharToStr(Gi_152);
      text_16 = "BUY";
   }
   if (Ai_0 == 1) {
      color_4 = G_color_128;
      text_8 = CharToStr(Gi_148);
      text_16 = "SELL";
   }
   if (ObjectFind("Arrow" + Gs_100) == -1) ObjectCreate("Arrow" + Gs_100, OBJ_LABEL, 0, 0, 0);
   ObjectSet("Arrow" + Gs_100, OBJPROP_CORNER, 1);
   ObjectSet("Arrow" + Gs_100, OBJPROP_YDISTANCE, 65);
   ObjectSet("Arrow" + Gs_100, OBJPROP_XDISTANCE, 35);
   ObjectSetText("Arrow" + Gs_100, text_8, G_fontsize_156 * 2, "WingDings", color_4);
   if (ObjectFind("Text" + Gs_100) == -1) ObjectCreate("Text" + Gs_100, OBJ_LABEL, 0, 0, 0);
   ObjectSet("Text" + Gs_100, OBJPROP_CORNER, 1);
   ObjectSet("Text" + Gs_100, OBJPROP_YDISTANCE, 10);
   ObjectSet("Text" + Gs_100, OBJPROP_XDISTANCE, 30);
   ObjectSetText("Text" + Gs_100, text_16, G_fontsize_156, Gs_verdana_92, color_4);
}

// DC16B65F78868A7505621A9669D808D2
void f0_4(string As_0, double Ad_8, double Ad_16, double Ad_24) {
   string Ls_32;
   string Ls_40;
   string Ls_48;
   string Ls_56;
   string Ls_64;
   if (Time[0] != G_time_108) {
      G_time_108 = Time[0];
      if (Ad_24 != 0.0) Ls_48 = " at price " + DoubleToStr(Ad_24, 5);
      else Ls_48 = "";
      if (Ad_8 != 0.0) Ls_40 = ", TakeProfit at " + DoubleToStr(Ad_8, 5);
      else Ls_40 = "";
      if (Ad_16 != 0.0) Ls_32 = ", StopLoss at " + DoubleToStr(Ad_16, 5);
      else Ls_32 = "";
      Alert(" MagicFxFormula: " + As_0 + Ls_48 + Ls_40 + Ls_32 + " ", Symbol(), ", ", Period(), " min chart");
      Ls_56 = " MagicFxFormula - " + As_0 + Ls_48;
      Ls_64 = " MagicFxFormula: " + As_0 + Ls_48 + Ls_40 + Ls_32 + " " + Symbol() + ", " + Period() + " min chart";
      if (Email) SendMail(Ls_56, Ls_64);
   }
}

// 445EF29A6CB6F7125051CB33F107C122
double f0_1(double Ad_0) {
   return (NormalizeDouble(Ad_0, Digits));
}
