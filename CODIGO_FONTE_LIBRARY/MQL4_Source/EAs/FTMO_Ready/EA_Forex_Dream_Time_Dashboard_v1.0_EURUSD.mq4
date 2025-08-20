/*
   Forex  Dream Time []
   Website: http://dreamtime.com
   E-mail : dreamtime@puremail.com
*/
#property copyright "Copyright © 2010, Forex Dream Time, By Dream"
#property link      "         "

#property indicator_chart_window

extern string ___________________________ = "Font Size & Corner & Calculation";
extern int Font_Size = 14;
extern int Corner = 3;
extern bool Show_Calc = TRUE;
int g_color_96 = Yellow;
string gsa_100[] = {"GBPJPY", "GBPUSD", "EURCHF", "EURGBP", "EURJPY", "EURUSD", "USDCAD", "USDCHF", "USDJPY"};
string gsa_104[] = {"Symbol", "Signal ", "Entry1", "Entry2 ", "TP1  ", "TP2   ", "SL    "};
int g_index_108;

int init() {
   IndicatorShortName("Forex Dream Time Dashboard");
   ObjectsDeleteAll(0, OBJ_LABEL);
   return (0);
}

int deinit() {
   ObjectsDeleteAll();
   return (0);
}

int start() {
   string l_text_4;
   color l_color_100;
   int li_104;
   int li_108;
   double ld_112;
   double ld_120;
   double ld_128;
   double ld_136;
   double ld_144;
   double ld_152;
   string l_text_200;
   string l_text_208;
   int l_ind_counted_0 = IndicatorCounted();
   double ld_12 = 0;
   double ld_20 = 0;
   double ld_28 = 0;
   double ld_36 = 0;
   double ld_44 = 0;
   double ld_52 = 0;
   double ld_60 = 0;
   double ld_68 = 0;
   double ld_76 = 0;
   double ld_84 = 0;
   double ld_92 = 0;
   for (g_index_108 = 6; g_index_108 >= 0; g_index_108--) {
      ObjectCreate(gsa_104[g_index_108] + "@0", OBJ_LABEL, 0, 0, 0);
      ObjectSetText(gsa_104[g_index_108] + "@0", gsa_104[g_index_108], 9, "Arial Black", Black);
      ObjectSet(gsa_104[g_index_108] + "@0", OBJPROP_XDISTANCE, 65 * g_index_108 + 15);
      ObjectSet(gsa_104[g_index_108] + "@0", OBJPROP_YDISTANCE, 5);
      ObjectSet(gsa_104[g_index_108] + "@0", OBJPROP_CORNER, 1);
      ObjectCreate(g_index_108 + "_", OBJ_LABEL, 0, 0, 0);
      ObjectSetText(g_index_108 + "_", "______________________________", 10, "Arial", White);
      ObjectSet(g_index_108 + "_", OBJPROP_XDISTANCE, 65 * g_index_108 + 85);
      ObjectSet(g_index_108 + "_", OBJPROP_YDISTANCE, 5);
      ObjectSet(g_index_108 + "_", OBJPROP_CORNER, 1);
      ObjectSet(g_index_108 + "_", OBJPROP_ANGLE, 90);
   }
   for (g_index_108 = 0; g_index_108 <= 8; g_index_108++) {
      ObjectCreate("_", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("_", "_________________________________________________________", 11, "Arial", White);
      ObjectSet("_", OBJPROP_XDISTANCE, 5);
      ObjectSet("_", OBJPROP_YDISTANCE, 199);
      ObjectSet("_", OBJPROP_CORNER, 1);
      ObjectCreate("_1", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("_1", "_________________________________________________________", 11, "Arial", White);
      ObjectSet("_1", OBJPROP_XDISTANCE, 5);
      ObjectSet("_1", OBJPROP_YDISTANCE, 9);
      ObjectSet("_1", OBJPROP_CORNER, 1);
      ObjectCreate("1_1", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("1_1", "______________________________", 10, "Arial", White);
      ObjectSet("1_1", OBJPROP_XDISTANCE, 18);
      ObjectSet("1_1", OBJPROP_YDISTANCE, 5);
      ObjectSet("1_1", OBJPROP_CORNER, 1);
      ObjectSet("1_1", OBJPROP_ANGLE, 90);
      li_104 = 100;
      li_108 = 3;
      if (StringFind(gsa_100[g_index_108], "JPY", 0) == -1) li_104 = 10000;
      if (StringFind(gsa_100[g_index_108], "JPY", 0) == -1) li_108 = 5;
      ld_12 = iOpen(gsa_100[g_index_108], PERIOD_D1, 0) * li_104;
      ld_20 = MathMod(180.0 * MathSqrt(ld_12) - 225.0, 360);
      if (ld_20 >= 90.0) {
         ld_36 = NormalizeDouble(ld_20 / 90.0, 0);
         ld_60 = ld_20 / ld_36;
         ld_84 = ld_60 / 180.0;
         ld_28 = ld_36;
         ld_52 = ld_60;
         ld_76 = ld_84;
      } else {
         ld_44 = NormalizeDouble(90 / ld_20, 0);
         ld_68 = ld_20 * ld_44;
         ld_92 = ld_68 / 180.0;
         ld_28 = ld_44;
         ld_52 = ld_68;
         ld_76 = ld_92;
      }
      ld_152 = MathSqrt(ld_12);
      if (ld_20 >= 0.0 && ld_20 <= 90.0) {
         ld_112 = ld_12 / li_104;
         ld_120 = (ld_152 - ld_76 / 2.0) * (ld_152 - ld_76 / 2.0) / li_104;
         ld_128 = (ld_152 + ld_76 / 2.0) * (ld_152 + ld_76 / 2.0) / li_104;
         ld_136 = (ld_152 + ld_76) * (ld_152 + ld_76) / li_104;
         ld_144 = (ld_152 - ld_76) * (ld_152 - ld_76) / li_104;
         Level("ENTRY1", ld_112, White, 2);
         Level("ENTRY2", ld_120, Orange, 2);
         Level("TARGT1", ld_128, Lime, 2);
         Level("TARGT2", ld_136, Green, 2);
         Level("STPLOSE", ld_144, Red, 2);
      }
      if (ld_20 >= 180.0 && ld_20 <= 270.0) {
         ld_112 = ld_12 / li_104;
         ld_120 = (ld_152 - ld_76 / 2.0) * (ld_152 - ld_76 / 2.0) / li_104;
         ld_128 = (ld_152 + ld_76 / 2.0) * (ld_152 + ld_76 / 2.0) / li_104;
         ld_136 = (ld_152 + ld_76) * (ld_152 + ld_76) / li_104;
         ld_144 = (ld_152 - ld_76) * (ld_152 - ld_76) / li_104;
         Level("ENTRY1", ld_112, White, 2);
         Level("ENTRY2", ld_120, Orange, 2);
         Level("TARGT1", ld_128, Lime, 2);
         Level("TARGT2", ld_136, Green, 2);
         Level("STPLOSE", ld_144, Red, 2);
      }
      if (ld_20 >= 91.0 && ld_20 < 180.0) {
         ld_112 = ld_12 / li_104;
         ld_120 = (ld_152 + ld_76 / 2.0) * (ld_152 + ld_76 / 2.0) / li_104;
         ld_128 = (ld_152 - ld_76 / 2.0) * (ld_152 - ld_76 / 2.0) / li_104;
         ld_136 = (ld_152 - ld_76) * (ld_152 - ld_76) / li_104;
         ld_144 = (ld_152 + ld_76) * (ld_152 + ld_76) / li_104;
         Level("ENTRY1", ld_112, White, 2);
         Level("ENTRY2", ld_120, Orange, 2);
         Level("TARGT1", ld_128, Lime, 2);
         Level("TARGT2", ld_136, Green, 2);
         Level("STPLOSE", ld_144, Red, 2);
      }
      if (ld_20 >= 271.0 && ld_20 <= 360.0) {
         ld_112 = ld_12 / li_104;
         ld_120 = (ld_152 + ld_76 / 2.0) * (ld_152 + ld_76 / 2.0) / li_104;
         ld_128 = (ld_152 - ld_76 / 2.0) * (ld_152 - ld_76 / 2.0) / li_104;
         ld_136 = (ld_152 - ld_76) * (ld_152 - ld_76) / li_104;
         ld_144 = (ld_152 + ld_76) * (ld_152 + ld_76) / li_104;
         Level("ENTRY1", ld_112, White, 2);
         Level("ENTRY2", ld_120, Orange, 2);
         Level("TARGT1", ld_128, Lime, 2);
         Level("TARGT2", ld_136, Green, 2);
         Level("STPLOSE", ld_144, Red, 2);
      }
      if (ld_112 > ld_144) {
         l_text_4 = "BUY";
         l_color_100 = Lime;
      } else {
         l_text_4 = "SELL";
         l_color_100 = White;
      }
      ObjectCreate(gsa_100[g_index_108] + "@0", OBJ_LABEL, 0, 0, 0);
      ObjectSetText(gsa_100[g_index_108] + "@0", gsa_100[g_index_108], 10, "Arial", l_color_100);
      ObjectSet(gsa_100[g_index_108] + "@0", OBJPROP_XDISTANCE, 8);
      ObjectSet(gsa_100[g_index_108] + "@0", OBJPROP_YDISTANCE, 20 * g_index_108 + 30);
      ObjectSet(gsa_100[g_index_108] + "@0", OBJPROP_CORNER, 1);
      ObjectCreate(g_index_108 + "signal", OBJ_LABEL, 0, 0, 0);
      ObjectSetText(g_index_108 + "signal", l_text_4, 10, "Arial", l_color_100);
      ObjectSet(g_index_108 + "signal", OBJPROP_XDISTANCE, 85);
      ObjectSet(g_index_108 + "signal", OBJPROP_YDISTANCE, 20 * g_index_108 + 30);
      ObjectSet(g_index_108 + "signal", OBJPROP_CORNER, 1);
      ObjectCreate(g_index_108 + "Entry", OBJ_LABEL, 0, 0, 0);
      ObjectSetText(g_index_108 + "Entry", DoubleToStr(ld_112, MarketInfo(gsa_100[g_index_108], MODE_DIGITS)), 10, "Arial", l_color_100);
      ObjectSet(g_index_108 + "Entry", OBJPROP_XDISTANCE, 145);
      ObjectSet(g_index_108 + "Entry", OBJPROP_YDISTANCE, 20 * g_index_108 + 30);
      ObjectSet(g_index_108 + "Entry", OBJPROP_CORNER, 1);
      ObjectCreate(g_index_108 + "Entry2", OBJ_LABEL, 0, 0, 0);
      ObjectSetText(g_index_108 + "Entry2", DoubleToStr(ld_120, MarketInfo(gsa_100[g_index_108], MODE_DIGITS)), 10, "Arial", l_color_100);
      ObjectSet(g_index_108 + "Entry2", OBJPROP_XDISTANCE, 210);
      ObjectSet(g_index_108 + "Entry2", OBJPROP_YDISTANCE, 20 * g_index_108 + 30);
      ObjectSet(g_index_108 + "Entry2", OBJPROP_CORNER, 1);
      ObjectCreate(g_index_108 + "TP1", OBJ_LABEL, 0, 0, 0);
      ObjectSetText(g_index_108 + "TP1", DoubleToStr(ld_128, MarketInfo(gsa_100[g_index_108], MODE_DIGITS)), 10, "Arial", l_color_100);
      ObjectSet(g_index_108 + "TP1", OBJPROP_XDISTANCE, 275);
      ObjectSet(g_index_108 + "TP1", OBJPROP_YDISTANCE, 20 * g_index_108 + 30);
      ObjectSet(g_index_108 + "TP1", OBJPROP_CORNER, 1);
      ObjectCreate(g_index_108 + "TP2", OBJ_LABEL, 0, 0, 0);
      ObjectSetText(g_index_108 + "TP2", DoubleToStr(ld_136, MarketInfo(gsa_100[g_index_108], MODE_DIGITS)), 10, "Arial", l_color_100);
      ObjectSet(g_index_108 + "TP2", OBJPROP_XDISTANCE, 340);
      ObjectSet(g_index_108 + "TP2", OBJPROP_YDISTANCE, 20 * g_index_108 + 30);
      ObjectSet(g_index_108 + "TP2", OBJPROP_CORNER, 1);
      ObjectCreate(g_index_108 + "SL", OBJ_LABEL, 0, 0, 0);
      ObjectSetText(g_index_108 + "SL", DoubleToStr(ld_144, MarketInfo(gsa_100[g_index_108], MODE_DIGITS)), 10, "Arial", l_color_100);
      ObjectSet(g_index_108 + "SL", OBJPROP_XDISTANCE, 405);
      ObjectSet(g_index_108 + "SL", OBJPROP_YDISTANCE, 20 * g_index_108 + 30);
      ObjectSet(g_index_108 + "SL", OBJPROP_CORNER, 1);
      ObjectCreate("_2", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("_2", "g", 140, "Webdings", DimGray);
      ObjectSet("_2", OBJPROP_XDISTANCE, 5);
      ObjectSet("_2", OBJPROP_YDISTANCE, 27);
      ObjectSet("_2", OBJPROP_CORNER, 1);
      ObjectSet("_2", OBJPROP_BACK, TRUE);
      ObjectCreate("_3", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("_3", "g", 140, "Webdings", DimGray);
      ObjectSet("_3", OBJPROP_XDISTANCE, 185);
      ObjectSet("_3", OBJPROP_YDISTANCE, 27);
      ObjectSet("_3", OBJPROP_CORNER, 1);
      ObjectSet("_3", OBJPROP_BACK, TRUE);
      ObjectCreate("_4", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("_4", "g", 140, "Webdings", DimGray);
      ObjectSet("_4", OBJPROP_XDISTANCE, 273);
      ObjectSet("_4", OBJPROP_YDISTANCE, 27);
      ObjectSet("_4", OBJPROP_CORNER, 1);
      ObjectSet("_4", OBJPROP_BACK, TRUE);
      ObjectCreate("_5", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("_5", "|", 210, "Webdings", Silver);
      ObjectSet("_5", OBJPROP_XDISTANCE, 1);
      ObjectSet("_5", OBJPROP_YDISTANCE, 153);
      ObjectSet("_5", OBJPROP_CORNER, 1);
      ObjectSet("_5", OBJPROP_BACK, TRUE);
      ObjectSet("_5", OBJPROP_ANGLE, 270);
      ObjectCreate("_6", OBJ_LABEL, 0, 0, 0);
      ObjectSetText("_6", "|", 210, "Webdings", Silver);
      ObjectSet("_6", OBJPROP_XDISTANCE, 173);
      ObjectSet("_6", OBJPROP_YDISTANCE, 153);
      ObjectSet("_6", OBJPROP_CORNER, 1);
      ObjectSet("_6", OBJPROP_BACK, TRUE);
      ObjectSet("_6", OBJPROP_ANGLE, 270);
   }
   string l_dbl2str_160 = DoubleToStr(ld_112, li_108);
   string l_dbl2str_168 = DoubleToStr(ld_120, li_108);
   string l_dbl2str_176 = DoubleToStr(ld_128, li_108);
   string l_dbl2str_184 = DoubleToStr(ld_136, li_108);
   string l_dbl2str_192 = DoubleToStr(ld_144, li_108);
   string l_name_216 = "Calculation1";
   string l_name_224 = "Calculation2";
   if (Show_Calc == TRUE) {
      l_text_200 = l_text_200 + "   " + "OP : " + l_dbl2str_160 + "   " + "P.Angle : " + DoubleToStr(ld_20, 0) + "   " + "Adjustment: " + DoubleToStr(ld_28, 0);
      ObjectCreate(l_name_216, OBJ_LABEL, 0, 0, 0);
      ObjectSetText(l_name_216, l_text_200, 8, "Arial Bold", White);
      ObjectSet(l_name_216, OBJPROP_CORNER, 1);
      ObjectSet(l_name_216, OBJPROP_XDISTANCE, 500);
      ObjectSet(l_name_216, OBJPROP_YDISTANCE, 10);
      l_text_208 = l_text_208 + "   " + "Corrected P.Angle : " + DoubleToStr(ld_52, 0) + "   " + "Factor : " + DoubleToStr(ld_76, 5);
      ObjectCreate(l_name_224, OBJ_LABEL, 0, 0, 0);
      ObjectSetText(l_name_224, l_text_208, 8, "Arial Bold", White);
      ObjectSet(l_name_224, OBJPROP_CORNER, 1);
      ObjectSet(l_name_224, OBJPROP_XDISTANCE, 510);
      ObjectSet(l_name_224, OBJPROP_YDISTANCE, 20);
   }
   int li_240 = Time[0] + 60 * Period() - TimeCurrent();
   double ld_232 = li_240 / 60.0;
   int li_244 = li_240 % 60;
   li_240 = (li_240 - li_240 % 60) / 60;
   Comment(li_240 + " minutes " + li_244 + " seconds left to bar end");
   ObjectDelete("time");
   if (ObjectFind("time") != 0) {
      ObjectCreate("time", OBJ_TEXT, 0, Time[0], Close[0] + 0.0005);
      ObjectSetText("time", "                  <" + li_240 + ":" + li_244, 8, "Arial", g_color_96);
   } else ObjectMove("time", 0, Time[0], Close[0] + 0.0005);
   return (0);
}

int Level(string a_name_0, double a_price_8, color a_color_16, int a_width_20) {
   if (ObjectFind(a_name_0) != 0) {
      ObjectCreate(a_name_0, OBJ_HLINE, 0, Time[0], a_price_8);
      ObjectSet(a_name_0, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(a_name_0, OBJPROP_COLOR, a_color_16);
      ObjectSet(a_name_0, OBJPROP_WIDTH, a_width_20);
      ObjectCreate(a_name_0, OBJ_TEXT, 0, Time[0], a_price_8);
      ObjectSetText(a_name_0, "", 8, "Arial", a_color_16);
   } else ObjectMove(a_name_0, 0, Time[0], a_price_8);
   return (0);
}