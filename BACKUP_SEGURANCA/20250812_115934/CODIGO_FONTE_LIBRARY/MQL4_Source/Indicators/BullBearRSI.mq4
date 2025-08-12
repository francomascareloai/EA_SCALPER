#property indicator_separate_window
#property indicator_minimum -0.0001
#property indicator_maximum 0.0001
#property indicator_buffers 3
#property indicator_color1 Black
#property indicator_color2 DeepSkyBlue
#property indicator_color3 Violet

extern int period = 12;
double gda_80[];
double gda_84[];
double gda_88[];
string gs_92 = "";
string gs_bstrend_100 = "BSTrend";

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 4);
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 4);
   SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID, 4);
   IndicatorDigits(Digits + 1);
   SetIndexBuffer(0, gda_80);
   SetIndexBuffer(1, gda_84);
   SetIndexBuffer(2, gda_88);
   IndicatorShortName(gs_bstrend_100);
   SetIndexLabel(1, NULL);
   SetIndexLabel(2, NULL);
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   double ld_0;
   double ld_8;
   double ld_16;
   int li_24 = IndicatorCounted();
   if (li_24 < 0) return (-1);
   if (li_24 > 0) li_24--;
   int li_28 = Bars - li_24;
   double ld_32 = GetTickCount();
   if (li_28 > 2500) li_28 = 2500;
   double ld_40 = GetTickCount();
   Print("Calculation time is ", 0.2, " seconds");
   double ld_48 = 0;
   double ld_56 = 0;
   double ld_64 = 0;
   double ld_72 = 0;
   double ld_80 = 0;
   double ld_88 = 0;
   double ld_96 = 0;
   double ld_104 = 0;
   f0_0();
   int li_112 = 16777215;
   if (li_24 > 0) li_24--;
   int li_116 = Bars - li_24;
   for (int li_120 = 0; li_120 < li_116; li_120++) {
      ld_104 = High[iHighest(NULL, 0, MODE_HIGH, period, li_120)];
      ld_96 = Low[iLowest(NULL, 0, MODE_LOW, period, li_120)];
      ld_16 = (High[li_120] + Low[li_120]) / 2.0;
      ld_48 = 0.66 * ((ld_16 - ld_96) / (ld_104 - ld_96) - 0.5) + 0.67 * ld_56;
      ld_48 = MathMin(MathMax(ld_48, -0.999), 0.999);
      gda_80[li_120] = MathLog((ld_48 + 1.0) / (1 - ld_48)) / 2.0 + ld_80 / 2.0;
      ld_56 = ld_48;
      ld_80 = gda_80[li_120];
   }
   bool li_124 = TRUE;
   for (li_120 = li_116 - 2; li_120 >= 0; li_120--) {
      ld_8 = gda_80[li_120];
      ld_0 = gda_80[li_120 + 1];
      if ((ld_8 < 0.0 && ld_0 > 0.0) || ld_8 < 0.0) li_124 = FALSE;
      if ((ld_8 > 0.0 && ld_0 < 0.0) || ld_8 > 0.0) li_124 = TRUE;
      if (!li_124) {
         gda_88[li_120] = ld_8;
         gda_84[li_120] = 0.0;
         gs_92 = "Downtrend";
         li_112 = 65535;
      } else {
         gda_84[li_120] = ld_8;
         gda_88[li_120] = 0.0;
         gs_92 = "Uptrend";
         li_112 = 65280;
      }
   }
   f0_1("BSTrend", gs_92, 12, li_112, 10, 15);
   return (0);
}

// 158D7E1197BD06A8E626874DE72FAA46
void f0_0() {
   f0_2("BSTrend");
   f0_1("BSTrend", "", 12, White, 10, 15);
}

// EA3A0E828966333DF661A5256929317B
void f0_2(string as_0) {
   ObjectCreate(as_0, OBJ_LABEL, WindowFind(gs_bstrend_100), 0, 0);
}

// E586BD4368DDB26061EE3FD85A4A2925
void f0_1(string as_0, string as_8, int ai_16, color ai_20, int ai_24, int ai_28) {
   ObjectSet(as_0, OBJPROP_XDISTANCE, ai_24);
   ObjectSet(as_0, OBJPROP_YDISTANCE, ai_28);
   ObjectSetText(as_0, as_8, ai_16, "Arial", ai_20);
}