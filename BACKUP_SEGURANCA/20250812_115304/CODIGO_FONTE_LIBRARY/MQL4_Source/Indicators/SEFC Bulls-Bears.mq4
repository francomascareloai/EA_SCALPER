
   
#property copyright "xbox corp - reproduction by SEFC forex"
#property link      " "

#property indicator_separate_window
#property indicator_minimum -0.0001
#property indicator_maximum 0.0001
#property indicator_buffers 3
#property indicator_color1 Black
#property indicator_color2 DeepSkyBlue
#property indicator_color3 Violet

extern int period = 12;
double g_ibuf_80[];
double g_ibuf_84[];
double g_ibuf_88[];
string gs_92 = "";
string gs_100 = "SEFC-Bull-Bear";

int init() {
   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 4);
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 4);
   SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID, 4);
   IndicatorDigits(Digits + 1);
   SetIndexBuffer(0, g_ibuf_80);
   SetIndexBuffer(1, g_ibuf_84);
   SetIndexBuffer(2, g_ibuf_88);
   IndicatorShortName(gs_100);
   SetIndexLabel(1, NULL);
   SetIndexLabel(2, NULL);
   StempelSEFC();
   return (0);
}

int start() {
   double ld_0;
   double ld_8;
   double ld_16;
   int li_28 = IndicatorCounted();
   if (li_28 < 0) return (-1);
   if (li_28 > 0) li_28--;
   int li_24 = Bars - li_28;
   double ld_unused_32 = GetTickCount();
   if (li_24 > 2500) li_24 = 2500;
   double ld_unused_40 = GetTickCount();
   Print("Calculation time is ", 0.2, " seconds");
   double ld_48 = 0;
   double ld_56 = 0;
   double ld_unused_64 = 0;
   double ld_unused_72 = 0;
   double ld_80 = 0;
   double ld_unused_88 = 0;
   double l_low_96 = 0;
   double l_high_104 = 0;
   creataalltext();
   int li_112 = 16777215;
   if (li_28 > 0) li_28--;
   int li_116 = Bars - li_28;
   for (int li_120 = 0; li_120 < li_116; li_120++) {
      l_high_104 = High[iHighest(NULL, 0, MODE_HIGH, period, li_120)];
      l_low_96 = Low[iLowest(NULL, 0, MODE_LOW, period, li_120)];
      ld_16 = (High[li_120] + Low[li_120]) / 2.0;
      ld_48 = 0.66 * ((ld_16 - l_low_96) / (l_high_104 - l_low_96) - 0.5) + 0.67 * ld_56;
      ld_48 = MathMin(MathMax(ld_48, -0.999), 0.999);
      g_ibuf_80[li_120] = MathLog((ld_48 + 1.0) / (1 - ld_48)) / 2.0 + ld_80 / 2.0;
      ld_56 = ld_48;
      ld_80 = g_ibuf_80[li_120];
   }
   bool li_124 = TRUE;
   for (li_120 = li_116 - 2; li_120 >= 0; li_120--) {
      ld_8 = g_ibuf_80[li_120];
      ld_0 = g_ibuf_80[li_120 + 1];
      if ((ld_8 < 0.0 && ld_0 > 0.0) || ld_8 < 0.0) li_124 = FALSE;
      if ((ld_8 > 0.0 && ld_0 < 0.0) || ld_8 > 0.0) li_124 = TRUE;
      if (!li_124) {
         g_ibuf_88[li_120] = ld_8;
         g_ibuf_84[li_120] = 0.0;
         gs_92 = "Saat ini volatile = Bear";
         li_112 = 65535;
      } else {
         g_ibuf_84[li_120] = ld_8;
         g_ibuf_88[li_120] = 0.0;
         gs_92 = "Saat ini volatile = Bull";
         li_112 = 65280;
      }
   }
   settext("SEFC X4bd Repro", gs_92, 12, li_112, 10, 15);
   return (0);
}

void creataalltext() {
   createtext("SEFC x4bd Repro");
   settext("SEFC x4bd Repro", "", 12, White, 10, 15);
}

void createtext(string a_name_0) {
   ObjectCreate(a_name_0, OBJ_LABEL, WindowFind(gs_100), 0, 0);
}

void settext(string a_name_0, string a_text_8, int a_fontsize_16, color a_color_20, int a_x_24, int a_y_28) {
   ObjectSet(a_name_0, OBJPROP_XDISTANCE, a_x_24);
   ObjectSet(a_name_0, OBJPROP_YDISTANCE, a_y_28);
   ObjectSetText(a_name_0, a_text_8, a_fontsize_16, "Arial", a_color_20);
}

void StempelSEFC() {
   ObjectCreate("Original Created by SEFC", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Original Created by SEFC", "SEFC *PALATO* - (Palato = Under earth Kingdom)", 8, "Lucida Handwriting", SpringGreen);
   ObjectSet("Original Created by SEFC", OBJPROP_CORNER, 2);
   ObjectSet("Original Created by SEFC", OBJPROP_XDISTANCE, 5);
   ObjectSet("Original Created by SEFC", OBJPROP_YDISTANCE, 10);
}