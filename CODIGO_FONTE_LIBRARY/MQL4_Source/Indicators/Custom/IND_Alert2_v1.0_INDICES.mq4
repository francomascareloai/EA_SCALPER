
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Lime
#property indicator_color2 OrangeRed
#property indicator_color3 Yellow
#property indicator_color4 Yellow
#property indicator_color5 White
#property indicator_color6 Red

extern double Period1 = 5.0;
extern double Period2 = 12.0;
extern double Period3 = 35.0;
extern string Dev_Step_1 = "5,3";
extern string Dev_Step_2 = "5,3";
extern string Dev_Step_3 = "5,3";
extern int Symbol_1_Kod = 159;
extern int Symbol_2_Kod = 159;
extern int Symbol_3_Kod = 82;
extern string _____ = "";
extern bool Box.Alerts = FALSE;
extern bool Email.Alerts = FALSE;
extern bool Sound.Alerts = TRUE;
extern bool Alert.Lv1 = FALSE;
extern bool Alert.Lv2 = TRUE;
extern bool Alert.Lv3 = TRUE;
string Gs_168 = "stage one level high.wav";
string Gs_176 = "stage one level low.wav";
string Gs_184 = "stage two level high.wav";
string Gs_192 = "stage two level low.wav";
string Gs_200 = "stage three level high.wav";
string Gs_208 = "stage three level low.wav";
double G_ibuf_216[];
double G_ibuf_220[];
double G_ibuf_224[];
double G_ibuf_228[];
double G_ibuf_232[];
double G_ibuf_236[];
int Gi_unused_240;
int Gi_unused_244;
int Gi_unused_248;
int Gi_252;
int Gi_256;
int Gi_260;
int Gi_264;
int Gi_268;
int Gi_272;
string Gs_276;
string Gs_284;
string Gs_292;
int G_digits_300;
int G_timeframe_304;
bool Gi_308;
bool Gi_312;
bool Gi_316;
int G_bars_320 = -1;
int Gi_unused_324 = 65535;

int init() {
   int Lia_8[];
   G_timeframe_304 = Period();
   Gs_284 = TimeFrameToString(G_timeframe_304);
   Gs_276 = Symbol();
   G_digits_300 = Digits;
   Gs_292 = "tbb" + Gs_276 + Gs_284;
   if (Period1 > 0.0) Gi_unused_240 = MathCeil(Period1 * Period());
   else Gi_unused_240 = 0;
   if (Period2 > 0.0) Gi_unused_244 = MathCeil(Period2 * Period());
   else Gi_unused_244 = 0;
   if (Period3 > 0.0) Gi_unused_248 = MathCeil(Period3 * Period());
   else Gi_unused_248 = 0;
   if (Period1 > 0.0) {
      SetIndexStyle(0, DRAW_ARROW);
      SetIndexArrow(0, Symbol_1_Kod);
      SetIndexBuffer(0, G_ibuf_216);
      SetIndexEmptyValue(0, 0.0);
      SetIndexStyle(1, DRAW_ARROW);
      SetIndexArrow(1, Symbol_1_Kod);
      SetIndexBuffer(1, G_ibuf_220);
      SetIndexEmptyValue(1, 0.0);
   }
   if (Period2 > 0.0) {
      SetIndexStyle(2, DRAW_ARROW);
      SetIndexArrow(2, Symbol_2_Kod);
      SetIndexBuffer(2, G_ibuf_224);
      SetIndexEmptyValue(2, 0.0);
      SetIndexStyle(3, DRAW_ARROW);
      SetIndexArrow(3, Symbol_2_Kod);
      SetIndexBuffer(3, G_ibuf_228);
      SetIndexEmptyValue(3, 0.0);
   }
   if (Period3 > 0.0) {
      SetIndexStyle(4, DRAW_ARROW);
      SetIndexArrow(4, Symbol_3_Kod);
      SetIndexBuffer(4, G_ibuf_232);
      SetIndexEmptyValue(4, 0.0);
      SetIndexStyle(5, DRAW_ARROW);
      SetIndexArrow(5, Symbol_3_Kod);
      SetIndexBuffer(5, G_ibuf_236);
      SetIndexEmptyValue(5, 0.0);
   }
   int Li_unused_0 = 0;
   int Li_unused_4 = 0;
   int Li_12 = 0;
   if (IntFromStr(Dev_Step_1, Li_12, Lia_8) == 1) {
      Gi_256 = Lia_8[1];
      Gi_252 = Lia_8[0];
   }
   if (IntFromStr(Dev_Step_2, Li_12, Lia_8) == 1) {
      Gi_264 = Lia_8[1];
      Gi_260 = Lia_8[0];
   }
   if (IntFromStr(Dev_Step_3, Li_12, Lia_8) == 1) {
      Gi_272 = Lia_8[1];
      Gi_268 = Lia_8[0];
   }
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   string Ls_0;
   if (Bars != G_bars_320) {
      Gi_308 = TRUE;
      Gi_312 = TRUE;
      Gi_316 = TRUE;
   }
   if (Period1 > 0.0) CountZZ(G_ibuf_216, G_ibuf_220, Period1, Gi_252, Gi_256);
   if (Period2 > 0.0) CountZZ(G_ibuf_224, G_ibuf_228, Period2, Gi_260, Gi_264);
   if (Period3 > 0.0) CountZZ(G_ibuf_232, G_ibuf_236, Period3, Gi_268, Gi_272);
   string Ls_8 = Gs_276 + "  " + Gs_284 + " at " + DoubleToStr(Close[0], G_digits_300);
   if (Gi_308 && Alert.Lv1) {
      if (G_ibuf_216[0] != 0.0) {
         Gi_308 = FALSE;
         Ls_0 = " ZZS: Level 1 Low;  ";
         if (Box.Alerts) Alert(Ls_0, Ls_8);
         if (Email.Alerts) SendMail(Ls_0, Ls_8);
         if (Sound.Alerts) PlaySound(Gs_176);
      }
      if (G_ibuf_220[0] != 0.0) {
         Gi_308 = FALSE;
         Ls_0 = " ZZS: Level 1 High; ";
         if (Box.Alerts) Alert(Ls_0, Ls_8);
         if (Email.Alerts) SendMail(Ls_0, Ls_8);
         if (Sound.Alerts) PlaySound(Gs_168);
      }
   }
   if (Gi_312 && Alert.Lv2) {
      if (G_ibuf_224[0] != 0.0) {
         Gi_312 = FALSE;
         Ls_0 = " ZZS: Level 2 Low;  ";
         if (Box.Alerts) Alert(Ls_0, Ls_8);
         if (Email.Alerts) SendMail(Ls_0, Ls_8);
         if (Sound.Alerts) PlaySound(Gs_192);
      }
      if (G_ibuf_228[0] != 0.0) {
         Gi_312 = FALSE;
         Ls_0 = " ZZS: Level 2 High; ";
         if (Box.Alerts) Alert(Ls_0, Ls_8);
         if (Email.Alerts) SendMail(Ls_0, Ls_8);
         if (Sound.Alerts) PlaySound(Gs_184);
      }
   }
   if (Gi_316 && Alert.Lv3) {
      if (G_ibuf_232[0] != 0.0) {
         Gi_316 = FALSE;
         Ls_0 = " ZZS: Level 3 Low;  ";
         if (Box.Alerts) Alert(Ls_0, Ls_8);
         if (Email.Alerts) SendMail(Ls_0, Ls_8);
         if (Sound.Alerts) PlaySound(Gs_208);
      }
      if (G_ibuf_236[0] != 0.0) {
         Gi_316 = FALSE;
         Ls_0 = " ZZS: Level 3 High; ";
         if (Box.Alerts) Alert(Ls_0, Ls_8);
         if (Email.Alerts) SendMail(Ls_0, Ls_8);
         if (Sound.Alerts) PlaySound(Gs_200);
      }
   }
   G_bars_320 = Bars;
   return (0);
}

string TimeFrameToString(int Ai_0) {
   string Ls_ret_4;
   switch (Ai_0) {
   case 1:
      Ls_ret_4 = "M1";
      break;
   case 5:
      Ls_ret_4 = "M5";
      break;
   case 15:
      Ls_ret_4 = "M15";
      break;
   case 30:
      Ls_ret_4 = "M30";
      break;
   case 60:
      Ls_ret_4 = "H1";
      break;
   case 240:
      Ls_ret_4 = "H4";
      break;
   case 1440:
      Ls_ret_4 = "D1";
      break;
   case 10080:
      Ls_ret_4 = "W1";
      break;
   case 43200:
      Ls_ret_4 = "MN";
   }
   return (Ls_ret_4);
}

int CountZZ(double &Ada_0[], double &Ada_4[], int Ai_8, int Ai_12, int Ai_16) {
   double Ld_36;
   double Ld_44;
   double Ld_52;
   double Ld_60;
   double Ld_68;
   double Ld_76;
   for (int Li_20 = Bars - Ai_8; Li_20 >= 0; Li_20--) {
      Ld_36 = Low[iLowest(NULL, 0, MODE_LOW, Ai_8, Li_20)];
      if (Ld_36 == Ld_76) Ld_36 = 0.0;
      else {
         Ld_76 = Ld_36;
         if (Low[Li_20] - Ld_36 > Ai_12 * Point) Ld_36 = 0.0;
         else {
            for (int Li_24 = 1; Li_24 <= Ai_16; Li_24++) {
               Ld_44 = Ada_0[Li_20 + Li_24];
               if (Ld_44 != 0.0 && Ld_44 > Ld_36) Ada_0[Li_20 + Li_24] = 0.0;
            }
         }
      }
      Ada_0[Li_20] = Ld_36;
      Ld_36 = High[iHighest(NULL, 0, MODE_HIGH, Ai_8, Li_20)];
      if (Ld_36 == Ld_68) Ld_36 = 0.0;
      else {
         Ld_68 = Ld_36;
         if (Ld_36 - High[Li_20] > Ai_12 * Point) Ld_36 = 0.0;
         else {
            for (Li_24 = 1; Li_24 <= Ai_16; Li_24++) {
               Ld_44 = Ada_4[Li_20 + Li_24];
               if (Ld_44 != 0.0 && Ld_44 < Ld_36) Ada_4[Li_20 + Li_24] = 0.0;
            }
         }
      }
      Ada_4[Li_20] = Ld_36;
   }
   Ld_68 = -1;
   int Li_28 = -1;
   Ld_76 = -1;
   int Li_32 = -1;
   for (Li_20 = Bars - Ai_8; Li_20 >= 0; Li_20--) {
      Ld_52 = Ada_0[Li_20];
      Ld_60 = Ada_4[Li_20];
      if (Ld_52 == 0.0 && Ld_60 == 0.0) continue;
      if (Ld_60 != 0.0) {
         if (Ld_68 > 0.0) {
            if (Ld_68 < Ld_60) Ada_4[Li_28] = 0;
            else Ada_4[Li_20] = 0;
         }
         if (Ld_68 < Ld_60 || Ld_68 < 0.0) {
            Ld_68 = Ld_60;
            Li_28 = Li_20;
         }
         Ld_76 = -1;
      }
      if (Ld_52 != 0.0) {
         if (Ld_76 > 0.0) {
            if (Ld_76 > Ld_52) Ada_0[Li_32] = 0;
            else Ada_0[Li_20] = 0;
         }
         if (Ld_52 < Ld_76 || Ld_76 < 0.0) {
            Ld_76 = Ld_52;
            Li_32 = Li_20;
         }
         Ld_68 = -1;
      }
   }
   for (Li_20 = Bars - 1; Li_20 >= 0; Li_20--) {
      if (Li_20 >= Bars - Ai_8) Ada_0[Li_20] = 0.0;
      else {
         Ld_44 = Ada_4[Li_20];
         if (Ld_44 != 0.0) Ada_4[Li_20] = Ld_44;
      }
   }
   return (0);
}

int Str2Massive(string As_0, int &Ai_8, int &Aia_12[]) {
   int Li_20;
   int str2int_16 = StrToInteger(As_0);
   if (str2int_16 > 0) {
      Ai_8++;
      Li_20 = ArrayResize(Aia_12, Ai_8);
      if (Li_20 == 0) return (-1);
      Aia_12[Ai_8 - 1] = str2int_16;
      return (1);
   }
   return (0);
}

int IntFromStr(string As_0, int &Ai_8, int Aia_12[]) {
   string Ls_28;
   if (StringLen(As_0) == 0) return (-1);
   string Ls_16 = As_0;
   int Li_24 = 0;
   Ai_8 = 0;
   ArrayResize(Aia_12, Ai_8);
   while (StringLen(Ls_16) > 0) {
      Li_24 = StringFind(Ls_16, ",");
      if (Li_24 > 0) {
         Ls_28 = StringSubstr(Ls_16, 0, Li_24);
         Ls_16 = StringSubstr(Ls_16, Li_24 + 1, StringLen(Ls_16));
      } else {
         if (StringLen(Ls_16) > 0) {
            Ls_28 = Ls_16;
            Ls_16 = "";
         }
      }
      if (Str2Massive(Ls_28, Ai_8, Aia_12) == 0) return (-2);
   }
   return (1);
}
