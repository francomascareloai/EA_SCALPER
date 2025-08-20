
#property copyright "Copyright 2008, www.LearnForexLive.com"
#property link      "http://www.LearnForexLive.com"

#property indicator_chart_window
#property indicator_minimum -10.0
#property indicator_maximum 10.0

int g_color_76 = Black;
int g_color_80 = LimeGreen;
int g_color_84 = Red;

int g_color_88 = DimGray;
int gi_92 = 16777215;
int gi_96 = 16777215;
int gi_100 = 6908265;
int gi_104 = 42495;
int gi_unused_108 = 3329330;
int gi_unused_112 = 255;
int gi_116 = 6908265;
int gi_unused_120 = 12632256;
int gi_124 = 44;
int gi_128 = 20;
int gi_unused_132 = 9;
int gi_136 = 20;
bool gi_140 = FALSE;
int gi_144 = 1;
double gd_148 = 0.5;
bool gi_156 = TRUE;
int gia_192[7] = {5, 15, 30, 60, 240, 1440, 10080};
string gsa_196[28];
string gsa_200[7] = {"M5", "M15", "M30", "H", "H4", "D", "W1"};
string gsa_204[8] = {"USD", "EUR", "GBP", "CHF", "JPY", "CAD", "AUD", "NZD"};
string gsa_208[28] = {"EURUSD", "GBPUSD", "USDCHF", "USDJPY", "USDCAD", "AUDUSD", "NZDUSD", "EURGBP", "EURCHF", "EURJPY", "EURCAD", "EURAUD", "EURNZD", "GBPCHF", "GBPJPY", "GBPCAD", "GBPAUD", "GBPNZD", "CHFJPY", "CADCHF", "AUDCHF", "NZDCHF", "CADJPY", "AUDJPY", "NZDJPY", "AUDCAD", "NZDCAD", "AUDNZD"};
int gia_212[56] = {1, 0, 2, 0, 0, 3, 0, 4, 0, 5, 6, 0, 7, 0, 1, 2, 1, 3, 1, 4, 1, 5, 1, 6, 1, 7, 2, 3, 2, 4, 2, 5, 2, 6, 2, 7, 3, 4, 5, 3, 6, 3, 7, 3, 5, 4, 6, 4, 7, 4, 6, 5, 7, 5, 6, 7};
double gda_216[8][7];
double gda_220[8][7];
double gda_224[8][7];
int gia_228[5][5];
int gi_232 = 0;
int gi_236 = 100;
int gi_unused_240 = 30;
int gi_unused_244 = 20;
int gi_248 = 60;
int g_index_252;
int g_index_256;
int g_index_260;

void initVLine(string as_0, string as_8, string as_16, int ai_24) {
   objectCreate("V" + as_0 + "_10" + as_8, ai_24, 194);
   objectCreate("V" + as_0 + "_9" + as_8, ai_24, 186);
   objectCreate("V" + as_0 + "_8" + as_8, ai_24, 178);
   objectCreate("V" + as_0 + "_7" + as_8, ai_24, 170);
   objectCreate("V" + as_0 + "_6" + as_8, ai_24, 162);
   objectCreate("V" + as_0 + "_5" + as_8, ai_24, 154);
   objectCreate("V" + as_0 + "_4" + as_8, ai_24, 146);
   objectCreate("V" + as_0 + "_3" + as_8, ai_24, 138);
   objectCreate("V" + as_0 + "_2" + as_8, ai_24, 130);
   objectCreate("V" + as_0 + "_1" + as_8, ai_24, 122);
   objectCreate("V" + as_0 + as_8, ai_24 + 2, 134, as_16, 7, "Arial Narrow", gi_96);
   objectCreate("V" + as_0 + "p" + as_8, ai_24 + 4, 125, DoubleToStr(9, 0), 8, "Arial Narrow", Blue);
   objectCreate("V" + as_0 + "arrow" + as_8, ai_24 + 4, 114, "l", 8, "Wingdings", Green);
   objectCreate("V" + as_0 + "_-1" + as_8, ai_24, 82);
   objectCreate("V" + as_0 + "_-2" + as_8, ai_24, 74);
   objectCreate("V" + as_0 + "_-3" + as_8, ai_24, 66);
   objectCreate("V" + as_0 + "_-4" + as_8, ai_24, 58);
   objectCreate("V" + as_0 + "_-5" + as_8, ai_24, 50);
   objectCreate("V" + as_0 + "_-6" + as_8, ai_24, 42);
   objectCreate("V" + as_0 + "_-7" + as_8, ai_24, 34);
   objectCreate("V" + as_0 + "_-8" + as_8, ai_24, 26);
   objectCreate("V" + as_0 + "_-9" + as_8, ai_24, 18);
   objectCreate("V" + as_0 + "_-10" + as_8, ai_24, 10);
}

void initMeter(string as_0, string as_8, int ai_16) {
   initVLine("1", as_8, "USD", ai_16);
   initVLine("2", as_8, "EUR", ai_16 + 20);
   initVLine("3", as_8, "GBP", ai_16 + 40);
   initVLine("4", as_8, "CHF", ai_16 + 60);
   initVLine("5", as_8, "JPY", ai_16 + 80);
   initVLine("6", as_8, "CAD", ai_16 + 100);
   initVLine("7", as_8, "AUD", ai_16 + 120);
   initVLine("8", as_8, "NZD", ai_16 + 140);
   objectCreate("line1" + as_8, ai_16 + 2, 26, "---------------------------------------", 10, "Arial", gi_100);
   objectCreate("line2" + as_8, ai_16 + 2, 108, "---------------------------------------", 10, "Arial", gi_100);
   objectCreate("line3" + as_8, ai_16 + 2, 139, "---------------------------------------", 10, "Arial", gi_100);
   objectCreate("line4" + as_8, ai_16 + 2, 220, "---------------------------------------", 10, "Arial", gi_100);
   objectCreate("V" + as_8 + "title", ai_16 + 50, 230, as_0, 10, "Arial", gi_92);
   objectCreate("Header", ai_16 - 1020, 270, "Forex Currency Index", 12, "Arial Bold", gi_104);
}

void paintVLine(string as_0, string as_8, double ad_16, double ad_24) {
   if (ad_16 > ad_24 + gd_148) ObjectSetText("V" + as_0 + "arrow" + as_8, CharToStr(233), 8, "Wingdings", g_color_80);
   else {
      if (ad_16 < ad_24 - gd_148) ObjectSetText("V" + as_0 + "arrow" + as_8, CharToStr(234), 8, "Wingdings", g_color_84);
      else ObjectSetText("V" + as_0 + "arrow" + as_8, CharToStr(108), 8, "Wingdings", g_color_88);
   }
   ad_16 = MathRound(ad_16);
   if (ad_16 > 9.0) ObjectSet("V" + as_0 + "_10" + as_8, OBJPROP_COLOR, g_color_80);
   else ObjectSet("V" + as_0 + "_10" + as_8, OBJPROP_COLOR, g_color_76);
   if (ad_16 > 8.0) ObjectSet("V" + as_0 + "_9" + as_8, OBJPROP_COLOR, g_color_80);
   else ObjectSet("V" + as_0 + "_9" + as_8, OBJPROP_COLOR, g_color_76);
   if (ad_16 > 7.0) ObjectSet("V" + as_0 + "_8" + as_8, OBJPROP_COLOR, g_color_80);
   else ObjectSet("V" + as_0 + "_8" + as_8, OBJPROP_COLOR, g_color_76);
   if (ad_16 > 6.0) ObjectSet("V" + as_0 + "_7" + as_8, OBJPROP_COLOR, g_color_80);
   else ObjectSet("V" + as_0 + "_7" + as_8, OBJPROP_COLOR, g_color_76);
   if (ad_16 > 5.0) ObjectSet("V" + as_0 + "_6" + as_8, OBJPROP_COLOR, g_color_80);
   else ObjectSet("V" + as_0 + "_6" + as_8, OBJPROP_COLOR, g_color_76);
   if (ad_16 > 4.0) ObjectSet("V" + as_0 + "_5" + as_8, OBJPROP_COLOR, g_color_80);
   else ObjectSet("V" + as_0 + "_5" + as_8, OBJPROP_COLOR, g_color_76);
   if (ad_16 > 3.0) ObjectSet("V" + as_0 + "_4" + as_8, OBJPROP_COLOR, g_color_88);
   else ObjectSet("V" + as_0 + "_4" + as_8, OBJPROP_COLOR, g_color_76);
   if (ad_16 > 2.0) ObjectSet("V" + as_0 + "_3" + as_8, OBJPROP_COLOR, g_color_88);
   else ObjectSet("V" + as_0 + "_3" + as_8, OBJPROP_COLOR, g_color_76);
   if (ad_16 > 1.0) ObjectSet("V" + as_0 + "_2" + as_8, OBJPROP_COLOR, g_color_88);
   else ObjectSet("V" + as_0 + "_2" + as_8, OBJPROP_COLOR, g_color_76);
   if (ad_16 > 0.0) ObjectSet("V" + as_0 + "_1" + as_8, OBJPROP_COLOR, g_color_88);
   else ObjectSet("V" + as_0 + "_1" + as_8, OBJPROP_COLOR, g_color_76);
   if (ad_16 > 0.0) ObjectSetText("V" + as_0 + "p" + as_8, DoubleToStr(ad_16, 0), 8, "Arial Narrow", g_color_80);
   else ObjectSetText("V" + as_0 + "p" + as_8, DoubleToStr(ad_16, 0), 8, "Arial Narrow", g_color_84);
   if (ad_16 < 0.0) ObjectSet("V" + as_0 + "_-1" + as_8, OBJPROP_COLOR, g_color_88);
   else ObjectSet("V" + as_0 + "_-1" + as_8, OBJPROP_COLOR, g_color_76);
   if (ad_16 < -1.0) ObjectSet("V" + as_0 + "_-2" + as_8, OBJPROP_COLOR, g_color_88);
   else ObjectSet("V" + as_0 + "_-2" + as_8, OBJPROP_COLOR, g_color_76);
   if (ad_16 < -2.0) ObjectSet("V" + as_0 + "_-3" + as_8, OBJPROP_COLOR, g_color_88);
   else ObjectSet("V" + as_0 + "_-3" + as_8, OBJPROP_COLOR, g_color_76);
   if (ad_16 < -3.0) ObjectSet("V" + as_0 + "_-4" + as_8, OBJPROP_COLOR, g_color_88);
   else ObjectSet("V" + as_0 + "_-4" + as_8, OBJPROP_COLOR, g_color_76);
   if (ad_16 < -4.0) ObjectSet("V" + as_0 + "_-5" + as_8, OBJPROP_COLOR, g_color_84);
   else ObjectSet("V" + as_0 + "_-5" + as_8, OBJPROP_COLOR, g_color_76);
   if (ad_16 < -5.0) ObjectSet("V" + as_0 + "_-6" + as_8, OBJPROP_COLOR, g_color_84);
   else ObjectSet("V" + as_0 + "_-6" + as_8, OBJPROP_COLOR, g_color_76);
   if (ad_16 < -6.0) ObjectSet("V" + as_0 + "_-7" + as_8, OBJPROP_COLOR, g_color_84);
   else ObjectSet("V" + as_0 + "_-7" + as_8, OBJPROP_COLOR, g_color_76);
   if (ad_16 < -7.0) ObjectSet("V" + as_0 + "_-8" + as_8, OBJPROP_COLOR, g_color_84);
   else ObjectSet("V" + as_0 + "_-8" + as_8, OBJPROP_COLOR, g_color_76);
   if (ad_16 < -8.0) ObjectSet("V" + as_0 + "_-9" + as_8, OBJPROP_COLOR, g_color_84);
   else ObjectSet("V" + as_0 + "_-9" + as_8, OBJPROP_COLOR, g_color_76);
   if (ad_16 < -9.0) {
      ObjectSet("V" + as_0 + "_-10" + as_8, OBJPROP_COLOR, g_color_84);
      return;
   }
   ObjectSet("V" + as_0 + "_-10" + as_8, OBJPROP_COLOR, g_color_76);
}

void paintMeter(string as_0, double ad_8, double ad_16, double ad_24, double ad_32, double ad_40, double ad_48, double ad_56, double ad_64, double ad_72, double ad_80, double ad_88, double ad_96, double ad_104, double ad_112, double ad_120, double ad_128) {
   paintVLine("1", as_0, ad_8, ad_16);
   paintVLine("2", as_0, ad_24, ad_32);
   paintVLine("3", as_0, ad_40, ad_48);
   paintVLine("4", as_0, ad_56, ad_64);
   paintVLine("5", as_0, ad_72, ad_80);
   paintVLine("6", as_0, ad_88, ad_96);
   paintVLine("7", as_0, ad_104, ad_112);
   paintVLine("8", as_0, ad_120, ad_128);
}

void initGraph() {
   initMeter("  5MIN", "M1", 10);
   initMeter("15MIN", "M2", 180);
   initMeter("30MIN", "M3", 350);
   initMeter("1HOUR", "M4", 520);
   initMeter("4HOURS", "M5", 690);
   initMeter("DAILY", "M6", 860);
   initMeter("WEEKLY", "M7", 1030);
}

void objectCreate(string a_name_0, int a_x_8, int a_y_12, string a_text_16 = "-", int a_fontsize_24 = 42, string a_fontname_28 = "Arial", color a_color_36 = -1) {
   int l_window_40 = WindowOnDropped();
   ObjectCreate(a_name_0, OBJ_LABEL, l_window_40, 0, 0);
   ObjectSet(a_name_0, OBJPROP_CORNER, 2);
   ObjectSet(a_name_0, OBJPROP_COLOR, a_color_36);
   ObjectSet(a_name_0, OBJPROP_XDISTANCE, a_x_8);
   ObjectSet(a_name_0, OBJPROP_YDISTANCE, a_y_12);
   ObjectSetText(a_name_0, a_text_16, a_fontsize_24, a_fontname_28, a_color_36);
}

int init() {
   ObjectsDeleteAll();
   string ls_0 = "";
   if (StringLen(Symbol()) == 7) ls_0 = "m";
   for (g_index_252 = 0; g_index_252 <= 27; g_index_252++) gsa_196[g_index_252] = gsa_208[g_index_252] + ls_0;
   return (0);
}

int deinit() {
   ObjectsDeleteAll();
   return (0);
}

int start() {
   color l_color_28;
   string l_text_32;
   int l_y_40;
   if (gi_156) {
      initGraph();
      gi_156 = FALSE;
   }
   if (Time[0] == gi_232) return (0);
   gi_232 = Time[0];
   ArrayCopy(gda_220, gda_216, 0, 0, WHOLE_ARRAY);
   ArrayInitialize(gda_216, 0);
   ArrayInitialize(gda_224, 0);
   for (g_index_256 = 0; g_index_256 <= 6; g_index_256++) for (g_index_252 = 0; g_index_252 <= 27; g_index_252++) SetCurrencyValue(gsa_196[g_index_252], gia_192[g_index_256], g_index_256);
   for (g_index_256 = 0; g_index_256 <= 6; g_index_256++) for (g_index_252 = 0; g_index_252 <= 27; g_index_252++) SetCurrencyValuePrev(gsa_196[g_index_252], gia_192[g_index_256], g_index_256);
   int li_12 = gi_236;
   string l_dbl2str_16 = DoubleToStr(gda_216[g_index_260][g_index_256], 2);
   int l_count_24 = 0;
   for (l_count_24 = 0; l_count_24 < 7; l_count_24++) {
      paintMeter("M" + DoubleToStr(l_count_24 + 1, 0), gda_216[0][l_count_24], gda_224[0][l_count_24], gda_216[1][l_count_24], gda_224[1][l_count_24], gda_216[2][l_count_24], gda_224[2][l_count_24], gda_216[3][l_count_24], gda_224[3][l_count_24], gda_216[4][l_count_24], gda_224[4][l_count_24], gda_216[5][l_count_24], gda_224[5][l_count_24], gda_216[6][l_count_24], gda_224[6][l_count_24], gda_216[7][l_count_24], gda_224[7][l_count_24]);
      Print("CV : " + gda_216[0][l_count_24] + "," + gda_216[1][l_count_24] + "," + gda_216[2][l_count_24] + "," + gda_216[3][l_count_24] + "," + gda_216[4][l_count_24] +
         "," + gda_216[5][l_count_24] + "," + gda_216[6][l_count_24] + "," + gda_216[7][l_count_24]);
      Print("CV_PREV : " + gda_224[0][l_count_24] + "," + gda_224[1][l_count_24] + "," + gda_224[2][l_count_24] + "," + gda_224[3][l_count_24] + "," + gda_224[4][l_count_24] +
         "," + gda_224[5][l_count_24] + "," + gda_224[6][l_count_24] + "," + gda_224[7][l_count_24]);
   }
   ObjectsRedraw();
   if (gi_140) {
      l_color_28 = gi_116;
      l_text_32 = "";
      l_y_40 = gi_248;
      for (g_index_260 = 0; g_index_260 <= 7; g_index_260++) {
         li_12 = gi_236;
         for (g_index_256 = 0; g_index_256 <= 6; g_index_256++) {
            if (gda_216[g_index_260][g_index_256] > gda_220[g_index_260][g_index_256] + 0.7) {
               l_color_28 = LimeGreen;
               l_text_32 = "l";
            }
            if (gda_216[g_index_260][g_index_256] < gda_220[g_index_260][g_index_256] - 0.7) {
               l_color_28 = Red;
               l_text_32 = "l";
            }
            if (gda_216[g_index_260][g_index_256] == gda_220[g_index_260][g_index_256]) l_color_28 = gi_116;
            ObjectCreate("E" + g_index_260 + g_index_256, OBJ_LABEL, 0, 0, 0);
            ObjectSetText("E" + g_index_260 + g_index_256, l_text_32, 7, "Wingdings", l_color_28);
            ObjectSet("E" + g_index_260 + g_index_256, OBJPROP_XDISTANCE, li_12 + 15);
            ObjectSet("E" + g_index_260 + g_index_256, OBJPROP_YDISTANCE, l_y_40);
            li_12 += gi_124;
         }
         l_y_40 += gi_128;
      }
   }
   return (0);
}

void SetCurrencyValue(string a_symbol_0, int a_timeframe_8, int ai_12) {
   ArrayInitialize(gia_228, 0);
   int l_count_40 = 0;
   int l_count_44 = 0;
   int l_count_48 = 0;
   int l_count_52 = 0;
   int l_count_56 = 0;
   int l_count_60 = 0;
   int l_count_64 = 0;
   int l_count_68 = 0;
   int l_count_72 = 0;
   int l_count_76 = 0;
   int l_count_80 = 0;
   int l_count_84 = 0;
   int l_count_88 = 0;
   int l_count_92 = 0;
   int l_count_96 = 0;
   int l_count_100 = 0;
   int l_count_104 = 0;
   int l_count_108 = 0;
   int l_count_112 = 0;
   int l_count_116 = 0;
   int l_count_120 = 0;
   int l_count_124 = 0;
   double ld_128 = 0;
   double ld_136 = 0;
   for (int li_16 = gi_136; li_16 >= 1; li_16--) {
      if (iMA(a_symbol_0, a_timeframe_8, 50, 0, MODE_SMA, PRICE_CLOSE, li_16) > iMA(a_symbol_0, a_timeframe_8, 100, 0, MODE_SMA, PRICE_CLOSE, li_16)) l_count_40++;
      if (iMA(a_symbol_0, a_timeframe_8, 50, 0, MODE_SMA, PRICE_CLOSE, li_16) < iMA(a_symbol_0, a_timeframe_8, 100, 0, MODE_SMA, PRICE_CLOSE, li_16)) l_count_84++;
      if (iMA(a_symbol_0, a_timeframe_8, 30, 0, MODE_SMA, PRICE_CLOSE, li_16) > iMA(a_symbol_0, a_timeframe_8, 50, 0, MODE_SMA, PRICE_CLOSE, li_16)) l_count_44++;
      if (iMA(a_symbol_0, a_timeframe_8, 30, 0, MODE_SMA, PRICE_CLOSE, li_16) < iMA(a_symbol_0, a_timeframe_8, 50, 0, MODE_SMA, PRICE_CLOSE, li_16)) l_count_88++;
      if (iMA(a_symbol_0, a_timeframe_8, 10, 0, MODE_EMA, PRICE_CLOSE, li_16) > iMA(a_symbol_0, a_timeframe_8, 30, 0, MODE_SMA, PRICE_CLOSE, li_16)) l_count_48++;
      if (iMA(a_symbol_0, a_timeframe_8, 10, 0, MODE_EMA, PRICE_CLOSE, li_16) < iMA(a_symbol_0, a_timeframe_8, 30, 0, MODE_SMA, PRICE_CLOSE, li_16)) l_count_92++;
      if (iLow(a_symbol_0, a_timeframe_8, li_16) > iMA(a_symbol_0, a_timeframe_8, 100, 0, MODE_SMA, PRICE_CLOSE, li_16)) l_count_52++;
      if (iHigh(a_symbol_0, a_timeframe_8, li_16) < iMA(a_symbol_0, a_timeframe_8, 100, 0, MODE_SMA, PRICE_CLOSE, li_16)) l_count_96++;
      if (iClose(a_symbol_0, a_timeframe_8, li_16) > iMA(a_symbol_0, a_timeframe_8, 50, 0, MODE_SMA, PRICE_CLOSE, li_16)) l_count_56++;
      if (iClose(a_symbol_0, a_timeframe_8, li_16) < iMA(a_symbol_0, a_timeframe_8, 50, 0, MODE_SMA, PRICE_CLOSE, li_16)) l_count_100++;
      if (iClose(a_symbol_0, a_timeframe_8, li_16) > iMA(a_symbol_0, a_timeframe_8, 30, 0, MODE_SMA, PRICE_CLOSE, li_16)) l_count_60++;
      if (iClose(a_symbol_0, a_timeframe_8, li_16) < iMA(a_symbol_0, a_timeframe_8, 30, 0, MODE_SMA, PRICE_CLOSE, li_16)) l_count_104++;
      if (iMA(a_symbol_0, a_timeframe_8, 50, 0, MODE_SMA, PRICE_CLOSE, li_16 - 1) > iMA(a_symbol_0, a_timeframe_8, 50, 0, MODE_SMA, PRICE_CLOSE, li_16)) l_count_64++;
      if (iMA(a_symbol_0, a_timeframe_8, 50, 0, MODE_SMA, PRICE_CLOSE, li_16 - 1) < iMA(a_symbol_0, a_timeframe_8, 50, 0, MODE_SMA, PRICE_CLOSE, li_16)) l_count_108++;
      if (iMA(a_symbol_0, a_timeframe_8, 30, 0, MODE_SMA, PRICE_CLOSE, li_16 - 5) > iMA(a_symbol_0, a_timeframe_8, 30, 0, MODE_SMA, PRICE_CLOSE, li_16)) l_count_68++;
      if (iMA(a_symbol_0, a_timeframe_8, 30, 0, MODE_SMA, PRICE_CLOSE, li_16 - 5) < iMA(a_symbol_0, a_timeframe_8, 30, 0, MODE_SMA, PRICE_CLOSE, li_16)) l_count_112++;
   }
   if (iAO(a_symbol_0, a_timeframe_8, 0) > 0.0) l_count_72++;
   if (iAO(a_symbol_0, a_timeframe_8, 0) < 0.0) l_count_116++;
   if (iSAR(a_symbol_0, a_timeframe_8, 0.01, 0.1, 0) > iHigh(a_symbol_0, a_timeframe_8, 0)) l_count_120++;
   if (iSAR(a_symbol_0, a_timeframe_8, 0.01, 0.1, 0) < iLow(a_symbol_0, a_timeframe_8, 0)) l_count_76++;
   if (iADX(a_symbol_0, a_timeframe_8, 14, PRICE_CLOSE, MODE_PLUSDI, 0) > iADX(a_symbol_0, a_timeframe_8, 14, PRICE_CLOSE, MODE_MINUSDI, 0)) l_count_80++;
   if (iADX(a_symbol_0, a_timeframe_8, 14, PRICE_CLOSE, MODE_PLUSDI, 0) < iADX(a_symbol_0, a_timeframe_8, 14, PRICE_CLOSE, MODE_MINUSDI, 0)) l_count_124++;
   if (l_count_40 == gi_136) {
      ld_128 += 0.12987;
      ld_136 -= 0.12987;
   }
   if (l_count_84 == gi_136) {
      ld_128 -= 0.12987;
      ld_136 += 0.12987;
   }
   if (l_count_44 == gi_136) {
      ld_128 += 0.12987;
      ld_136 -= 0.12987;
   }
   if (l_count_88 == gi_136) {
      ld_128 -= 0.12987;
      ld_136 += 0.12987;
   }
   if (l_count_48 == gi_136) {
      ld_128 += 0.12987;
      ld_136 -= 0.12987;
   }
   if (l_count_92 == gi_136) {
      ld_128 -= 0.12987;
      ld_136 += 0.12987;
   }
   if (l_count_52 == gi_136) {
      ld_128 += 0.12987;
      ld_136 -= 0.12987;
   }
   if (l_count_96 == gi_136) {
      ld_128 -= 0.12987;
      ld_136 += 0.12987;
   }
   if (l_count_56 == gi_136) {
      ld_128 += 0.12987;
      ld_136 -= 0.12987;
   }
   if (l_count_100 == gi_136) {
      ld_128 -= 0.12987;
      ld_136 += 0.12987;
   }
   if (l_count_60 == gi_136) {
      ld_128 += 0.12987;
      ld_136 -= 0.12987;
   }
   if (l_count_104 == gi_136) {
      ld_128 -= 0.12987;
      ld_136 += 0.12987;
   }
   if (l_count_64 == gi_136) {
      ld_128 += 0.12987;
      ld_136 -= 0.12987;
   }
   if (l_count_108 == gi_136) {
      ld_128 -= 0.12987;
      ld_136 += 0.12987;
   }
   if (l_count_68 == gi_136) {
      ld_128 += 0.12987;
      ld_136 -= 0.12987;
   }
   if (l_count_116 == gi_136) {
      ld_128 -= 0.12987;
      ld_136 += 0.12987;
   }
   if (l_count_72 == 1) {
      ld_128 += 0.12987;
      ld_136 -= 0.12987;
   }
   if (l_count_116 == 1) {
      ld_128 -= 0.12987;
      ld_136 += 0.12987;
   }
   if (l_count_76 == 1) {
      ld_128 += 0.12987;
      ld_136 -= 0.12987;
   }
   if (l_count_120 == 1) {
      ld_128 -= 0.12987;
      ld_136 += 0.12987;
   }
   if (l_count_80 == 1) {
      ld_128 += 0.12987;
      ld_136 -= 0.12987;
   }
   if (l_count_124 == 1) {
      ld_128 -= 0.12987;
      ld_136 += 0.12987;
   }
   for (int l_index_144 = 0; l_index_144 <= 27; l_index_144++)
      if (gsa_196[l_index_144] == a_symbol_0) break;
   int li_32 = 2 * l_index_144;
   int li_36 = l_index_144 << 1 + 1;
   int li_20 = gia_212[li_32];
   int li_24 = gia_212[li_36];
   gda_216[li_20][ai_12] += ld_128;
   gda_216[li_24][ai_12] += ld_136;
}

void SetCurrencyValuePrev(string a_symbol_0, int a_timeframe_8, int ai_12) {
   ArrayInitialize(gia_228, 0);
   int l_count_40 = 0;
   int l_count_44 = 0;
   int l_count_48 = 0;
   int l_count_52 = 0;
   int l_count_56 = 0;
   int l_count_60 = 0;
   int l_count_64 = 0;
   int l_count_68 = 0;
   int l_count_72 = 0;
   int l_count_76 = 0;
   int l_count_80 = 0;
   int l_count_84 = 0;
   int l_count_88 = 0;
   int l_count_92 = 0;
   int l_count_96 = 0;
   int l_count_100 = 0;
   int l_count_104 = 0;
   int l_count_108 = 0;
   int l_count_112 = 0;
   int l_count_116 = 0;
   int l_count_120 = 0;
   int l_count_124 = 0;
   double ld_128 = 0;
   double ld_136 = 0;
   for (int li_16 = gi_136; li_16 >= 1; li_16--) {
      if (iMA(a_symbol_0, a_timeframe_8, 50, 0, MODE_SMA, PRICE_CLOSE, li_16 + gi_144) > iMA(a_symbol_0, a_timeframe_8, 100, 0, MODE_SMA, PRICE_CLOSE, li_16 + gi_144)) l_count_40++;
      if (iMA(a_symbol_0, a_timeframe_8, 50, 0, MODE_SMA, PRICE_CLOSE, li_16) < iMA(a_symbol_0, a_timeframe_8, 100, 0, MODE_SMA, PRICE_CLOSE, li_16)) l_count_84++;
      if (iMA(a_symbol_0, a_timeframe_8, 30, 0, MODE_SMA, PRICE_CLOSE, li_16 + gi_144) > iMA(a_symbol_0, a_timeframe_8, 50, 0, MODE_SMA, PRICE_CLOSE, li_16 + gi_144)) l_count_44++;
      if (iMA(a_symbol_0, a_timeframe_8, 30, 0, MODE_SMA, PRICE_CLOSE, li_16) < iMA(a_symbol_0, a_timeframe_8, 50, 0, MODE_SMA, PRICE_CLOSE, li_16)) l_count_88++;
      if (iMA(a_symbol_0, a_timeframe_8, 10, 0, MODE_EMA, PRICE_CLOSE, li_16 + gi_144) > iMA(a_symbol_0, a_timeframe_8, 30, 0, MODE_SMA, PRICE_CLOSE, li_16 + gi_144)) l_count_48++;
      if (iMA(a_symbol_0, a_timeframe_8, 10, 0, MODE_EMA, PRICE_CLOSE, li_16 + gi_144) < iMA(a_symbol_0, a_timeframe_8, 30, 0, MODE_SMA, PRICE_CLOSE, li_16 + gi_144)) l_count_92++;
      if (iLow(a_symbol_0, a_timeframe_8, li_16 + gi_144) > iMA(a_symbol_0, a_timeframe_8, 100, 0, MODE_SMA, PRICE_CLOSE, li_16 + gi_144)) l_count_52++;
      if (iHigh(a_symbol_0, a_timeframe_8, li_16 + gi_144) < iMA(a_symbol_0, a_timeframe_8, 100, 0, MODE_SMA, PRICE_CLOSE, li_16 + gi_144)) l_count_96++;
      if (iClose(a_symbol_0, a_timeframe_8, li_16 + gi_144) > iMA(a_symbol_0, a_timeframe_8, 50, 0, MODE_SMA, PRICE_CLOSE, li_16 + gi_144)) l_count_56++;
      if (iClose(a_symbol_0, a_timeframe_8, li_16 + gi_144) < iMA(a_symbol_0, a_timeframe_8, 50, 0, MODE_SMA, PRICE_CLOSE, li_16 + gi_144)) l_count_100++;
      if (iClose(a_symbol_0, a_timeframe_8, li_16 + gi_144) > iMA(a_symbol_0, a_timeframe_8, 30, 0, MODE_SMA, PRICE_CLOSE, li_16 + gi_144)) l_count_60++;
      if (iClose(a_symbol_0, a_timeframe_8, li_16 + gi_144) < iMA(a_symbol_0, a_timeframe_8, 30, 0, MODE_SMA, PRICE_CLOSE, li_16 + gi_144)) l_count_104++;
      if (iMA(a_symbol_0, a_timeframe_8, 50, 0, MODE_SMA, PRICE_CLOSE, li_16 - (gi_144 + 5)) > iMA(a_symbol_0, a_timeframe_8, 50, 0, MODE_SMA, PRICE_CLOSE, li_16 + gi_144)) l_count_64++;
      if (iMA(a_symbol_0, a_timeframe_8, 50, 0, MODE_SMA, PRICE_CLOSE, li_16 - (gi_144 + 5)) < iMA(a_symbol_0, a_timeframe_8, 50, 0, MODE_SMA, PRICE_CLOSE, li_16 + gi_144)) l_count_108++;
      if (iMA(a_symbol_0, a_timeframe_8, 30, 0, MODE_SMA, PRICE_CLOSE, li_16 - (gi_144 + 5)) > iMA(a_symbol_0, a_timeframe_8, 30, 0, MODE_SMA, PRICE_CLOSE, li_16 + gi_144)) l_count_68++;
      if (iMA(a_symbol_0, a_timeframe_8, 30, 0, MODE_SMA, PRICE_CLOSE, li_16 - (gi_144 + 5)) < iMA(a_symbol_0, a_timeframe_8, 30, 0, MODE_SMA, PRICE_CLOSE, li_16 + gi_144)) l_count_112++;
   }
   if (iAO(a_symbol_0, a_timeframe_8, gi_144 + 0) > 0.0) l_count_72++;
   if (iAO(a_symbol_0, a_timeframe_8, gi_144 + 0) < 0.0) l_count_116++;
   if (iSAR(a_symbol_0, a_timeframe_8, 0.01, 0.1, gi_144 + 0) > iHigh(a_symbol_0, a_timeframe_8, gi_144 + 0)) l_count_120++;
   if (iSAR(a_symbol_0, a_timeframe_8, 0.01, 0.1, gi_144 + 0) < iLow(a_symbol_0, a_timeframe_8, gi_144 + 0)) l_count_76++;
   if (iADX(a_symbol_0, a_timeframe_8, 14, PRICE_CLOSE, MODE_PLUSDI, gi_144 + 0) > iADX(a_symbol_0, a_timeframe_8, 14, PRICE_CLOSE, MODE_MINUSDI, gi_144 + 0)) l_count_80++;
   if (iADX(a_symbol_0, a_timeframe_8, 14, PRICE_CLOSE, MODE_PLUSDI, gi_144 + 0) < iADX(a_symbol_0, a_timeframe_8, 14, PRICE_CLOSE, MODE_MINUSDI, gi_144 + 0)) l_count_124++;
   if (l_count_40 == gi_136) {
      ld_128 += 0.12987;
      ld_136 -= 0.12987;
   }
   if (l_count_84 == gi_136) {
      ld_128 -= 0.12987;
      ld_136 += 0.12987;
   }
   if (l_count_44 == gi_136) {
      ld_128 += 0.12987;
      ld_136 -= 0.12987;
   }
   if (l_count_88 == gi_136) {
      ld_128 -= 0.12987;
      ld_136 += 0.12987;
   }
   if (l_count_48 == gi_136) {
      ld_128 += 0.12987;
      ld_136 -= 0.12987;
   }
   if (l_count_92 == gi_136) {
      ld_128 -= 0.12987;
      ld_136 += 0.12987;
   }
   if (l_count_52 == gi_136) {
      ld_128 += 0.12987;
      ld_136 -= 0.12987;
   }
   if (l_count_96 == gi_136) {
      ld_128 -= 0.12987;
      ld_136 += 0.12987;
   }
   if (l_count_56 == gi_136) {
      ld_128 += 0.12987;
      ld_136 -= 0.12987;
   }
   if (l_count_100 == gi_136) {
      ld_128 -= 0.12987;
      ld_136 += 0.12987;
   }
   if (l_count_60 == gi_136) {
      ld_128 += 0.12987;
      ld_136 -= 0.12987;
   }
   if (l_count_104 == gi_136) {
      ld_128 -= 0.12987;
      ld_136 += 0.12987;
   }
   if (l_count_64 == gi_136) {
      ld_128 += 0.12987;
      ld_136 -= 0.12987;
   }
   if (l_count_108 == gi_136) {
      ld_128 -= 0.12987;
      ld_136 += 0.12987;
   }
   if (l_count_68 == gi_136) {
      ld_128 += 0.12987;
      ld_136 -= 0.12987;
   }
   if (l_count_112 == gi_136) {
      ld_128 -= 0.12987;
      ld_136 += 0.12987;
   }
   if (l_count_72 == 1) {
      ld_128 += 0.12987;
      ld_136 -= 0.12987;
   }
   if (l_count_116 == 1) {
      ld_128 -= 0.12987;
      ld_136 += 0.12987;
   }
   if (l_count_76 == 1) {
      ld_128 += 0.12987;
      ld_136 -= 0.12987;
   }
   if (l_count_120 == 1) {
      ld_128 -= 0.12987;
      ld_136 += 0.12987;
   }
   if (l_count_80 == 1) {
      ld_128 += 0.12987;
      ld_136 -= 0.12987;
   }
   if (l_count_124 == 1) {
      ld_128 -= 0.12987;
      ld_136 += 0.12987;
   }
   for (int l_index_144 = 0; l_index_144 <= 27; l_index_144++)
      if (gsa_196[l_index_144] == a_symbol_0) break;
   int li_32 = 2 * l_index_144;
   int li_36 = l_index_144 << 1 + 1;
   int li_20 = gia_212[li_32];
   int li_24 = gia_212[li_36];
   gda_224[li_20][ai_12] += ld_128;
   gda_224[li_24][ai_12] += ld_136;
}