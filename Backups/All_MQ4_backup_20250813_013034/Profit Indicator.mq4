
#property copyright "joker.com$"
#property link      "joker.com$"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_color3 CLR_NONE
#property indicator_color4 CLR_NONE
#property indicator_color5 Yellow
#property indicator_color6 CLR_NONE
#property indicator_color7 CLR_NONE
#property indicator_color8 CLR_NONE

string gs_unused_76 = "*** OSMA Settings ***";
int gi_unused_84 = 12;
int gi_unused_88 = 26;
int gi_unused_92 = 9;
string gs_unused_96 = "*** Indicator Settings ***";
bool gi_unused_104 = TRUE;
bool gi_unused_108 = TRUE;
string gs_unused_112 = "";
string gs_unused_120 = "";
double gd_128 = 0.0;
double gd_136 = 0.0;
double gd_unused_144 = 0.0;
double gd_152 = 0.0;
double gd_160 = 0.0;
double gd_168 = 0.0;
int gi_unused_176 = 0;
int gi_unused_180 = 0;
double g_ibuf_184[1000];
double g_ibuf_188[1000];
double g_ibuf_192[1000];
double g_ibuf_196[1000];
double g_ibuf_200[1000];
extern int period = 80;
extern int price = 0;
bool gi_212 = FALSE;
bool gi_216 = FALSE;
extern int MA1period = 9;
extern int MA2period = 45;
extern string TypeHelp = "SMA- 0, EMA - 1, SMMA - 2, LWMA- 3";
extern string TypeHelp2 = "settings TypeMA1=0, TypeMA2=3";
extern int TypeMA1 = 0;
extern int TypeMA2 = 3;
string gs_dummy_252;
int g_ibuf_260[];
int g_ibuf_264[];
double gda_unused_268[];
double gda_unused_272[];
double g_ibuf_292[];
double gda_296[];
double g_ibuf_300[];
double g_ibuf_304[];
double gda_308[1000];
string gs_dummy_392;
string gs_dummy_400;
string gs_dummy_408;
string gs_dummy_416;
string gs_dummy_424;
string gs_dummy_432;
string gsa_unused_440[];
string gs_unused_444 = "false";
string gs_unused_452 = "false";
int gi_unused_460 = -1;
int gi_unused_464 = -1;
string gs_dummy_468;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 3, Lime);
   SetIndexBuffer(0, g_ibuf_184);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 3, Red);
   SetIndexBuffer(1, g_ibuf_188);
   SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID, 1, CLR_NONE);
   SetIndexLabel(2, "line");
   SetIndexBuffer(2, g_ibuf_192);
   SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, 1, CLR_NONE);
   SetIndexLabel(3, "MA1 " + MA1period);
   SetIndexStyle(4, DRAW_LINE, STYLE_SOLID, 1, Yellow);
   SetIndexLabel(4, "MA2 " + MA2period);
   SetIndexBuffer(3, g_ibuf_196);
   SetIndexBuffer(4, g_ibuf_200);
   SetIndexStyle(5, DRAW_LINE, STYLE_SOLID, 1, CLR_NONE);
   SetIndexStyle(6, DRAW_HISTOGRAM, STYLE_SOLID, 1, CLR_NONE);
   SetIndexStyle(7, DRAW_LINE, STYLE_SOLID, 3, CLR_NONE);
   SetIndexStyle(8, DRAW_NONE);
   SetIndexStyle(9, DRAW_NONE);
   SetIndexStyle(10, DRAW_NONE);
   SetIndexBuffer(6, g_ibuf_300);
   SetIndexBuffer(7, g_ibuf_304);
   SetIndexBuffer(8, g_ibuf_292);

   ObjectCreate("Symbol1", OBJ_LABEL, 0, 0, 0, 0, 0);
   ObjectCreate("Symbol2", OBJ_LABEL, 0, 0, 0, 0, 0);
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   for (int li_0 = ObjectsTotal() - 1; li_0 >= 0; li_0--) {
   }
   ObjectDelete("Symbol1");
   ObjectDelete("Symbol2");
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   //int li_0 = 90;
   //int li_4 = 2013;
   //int year_8 = TimeYear(TimeCurrent());
  // int day_of_year_12 = TimeDayOfYear(TimeCurrent());
   //if (day_of_year_12 > li_0) Alert("Account Being Disabled Renew Subscription");
   //if (year_8 > li_4) return (-1);
   //if (day_of_year_12 > li_0) return (-1);
   string text_16 = " ASAK ";
   string text_24 = " Janus Trader ";
   ObjectSetText("Symbol1", text_16, "", "Arial Black", Lime);
   ObjectSet("Symbol1", OBJPROP_XDISTANCE, 3);
   ObjectSet("Symbol1", OBJPROP_YDISTANCE, 30);
   ObjectSet("Symbol1", OBJPROP_COLOR, Red);
   ObjectSet("Symbol1", OBJPROP_CORNER, "111");
   ObjectSetText("Symbol2", text_24, "6", "Arial Black", Lime);
   ObjectSet("Symbol2", OBJPROP_XDISTANCE, 3);
   ObjectSet("Symbol2", OBJPROP_YDISTANCE, 50);
   ObjectSet("Symbol2", OBJPROP_COLOR, Red);
   ObjectSet("Symbol2", OBJPROP_CORNER, "111");
   int ind_counted_32 = IndicatorCounted();
   if (ind_counted_32 < 0) ind_counted_32 = 0;
   f0_1(ind_counted_32);
   return (0);
}

// D56848A2C0A935EE72F1D2B79A260D92
void f0_1(int ai_0) {
   int li_12;
   int li_16;
   double price_20;
   double ld_unused_28;
   double low_36;
   double high_44;
   double ld_52;
   for (int li_4 = Bars - ai_0; li_4 >= 1; li_4--) f0_0(li_4);
   li_4 = Bars - ai_0;
   if (li_4 >= 1) {
      li_12 = IndicatorCounted();
      low_36 = 0;
      high_44 = 0;
      ld_52 = 1.2;
      if (li_12 > 0) li_12--;
      li_16 = Bars - li_12;
      if (gi_212) li_16 = 100;
      for (li_4 = 0; li_4 < li_16; li_4++) {
         high_44 = High[iHighest(NULL, 0, MODE_HIGH, period, li_4)];
         low_36 = Low[iLowest(NULL, 0, MODE_LOW, period, li_4)];
         switch (price) {
         case 1:
            price_20 = Open[li_4];
            break;
         case 2:
            price_20 = Close[li_4];
            break;
         case 3:
            price_20 = High[li_4];
            break;
         case 4:
            price_20 = Low[li_4];
            break;
         case 5:
            price_20 = (High[li_4] + Low[li_4] + Close[li_4]) / 3.0;
            break;
         case 6:
            price_20 = (Open[li_4] + High[li_4] + Low[li_4] + Close[li_4]) / 4.0;
            break;
         case 7:
            price_20 = (Open[li_4] + Close[li_4]) / 2.0;
            break;
         default:
            price_20 = (High[li_4] + Low[li_4]) / 2.0;
         }
         gd_128 = 0.66 * ((price_20 - low_36) / (high_44 - low_36) - 0.5) + 0.67 * gd_136;
         gd_128 = MathMin(MathMax(gd_128, -0.999), 0.999);
         gd_152 = MathArctan(MathLog((gd_128 + 1.0) / (1 - gd_128)) / 2.0 + gd_160 / 2.0);
         g_ibuf_184[li_4] = 0;
         g_ibuf_188[li_4] = 0;
         if (gd_152 < 0.0 && gd_160 > 0.0) {
            if (gi_216) {
               ObjectCreate("EXIT: " + DoubleToStr(li_4, 0), OBJ_TEXT, 0, Time[li_4], price_20);
               ObjectSetText("EXIT: " + DoubleToStr(li_4, 0), "EXIT AT " + DoubleToStr(price_20, 4), 7, "Arial", White);
            }
            gi_unused_176 = 0;
         }
         if (gd_152 > 0.0 && gd_160 < 0.0) {
            if (gi_216) {
               ObjectCreate("EXIT: " + DoubleToStr(li_4, 0), OBJ_TEXT, 0, Time[li_4], price_20);
               ObjectSetText("EXIT: " + DoubleToStr(li_4, 0), "EXIT AT " + DoubleToStr(price_20, 4), 7, "Arial", White);
            }
            gi_unused_180 = 0;
         }
         if (gd_152 >= 0.0) {
            g_ibuf_184[li_4] = gd_152;
            g_ibuf_192[li_4] = gd_152;
         } else {
            g_ibuf_188[li_4] = gd_152;
            g_ibuf_192[li_4] = gd_152;
         }
         ld_unused_28 = li_4;
         if (gd_152 < (-ld_52) && gd_152 > gd_160 && gd_160 <= gd_168) gi_unused_180 = 1;
         if (gd_152 > ld_52 && gd_152 < gd_160 && gd_160 >= gd_168) gi_unused_176 = 1;
         gd_136 = gd_128;
         gd_168 = gd_160;
         gd_160 = gd_152;
      }
      for (li_4 = 0; li_4 < li_16; li_4++) g_ibuf_196[li_4] = iMAOnArray(g_ibuf_192, Bars, MA1period, 0, TypeMA1, li_4);
      for (li_4 = 0; li_4 < li_16; li_4++) g_ibuf_200[li_4] = iMAOnArray(g_ibuf_196, Bars, MA2period, 0, TypeMA2, li_4);
   }
}

// 5D0DC635FCFF50BE5D2C45F7BD7BE050
void f0_0(int ai_0) {
   g_ibuf_304[ai_0] = g_ibuf_196[ai_0];
   gda_308[ai_0] = g_ibuf_200[ai_0];
   if (g_ibuf_304[ai_0] > 0.0) {
      gda_296[ai_0] = gda_308[ai_0];
      g_ibuf_300[ai_0] = 0;
      return;
   }
   if (g_ibuf_304[ai_0] < 0.0) {
      g_ibuf_300[ai_0] = gda_308[ai_0];
      gda_296[ai_0] = 0;
      return;
   }
   g_ibuf_300[ai_0] = 0;
   gda_296[ai_0] = 0;
}