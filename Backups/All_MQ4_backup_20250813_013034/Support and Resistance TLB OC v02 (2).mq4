#property copyright "Copyright © 2008, Ulterior (FF)"
#property link      "http://localhost"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Black

extern int LB = 3;
extern int maxBarsForPeriod = 1000;
extern bool showM01 = TRUE;
extern bool showM05 = TRUE;
extern bool showM15 = TRUE;
extern bool showM30 = TRUE;
extern bool showH01 = TRUE;
extern bool showH04 = TRUE;
extern bool showD01 = TRUE;
extern bool showW01 = TRUE;
extern bool showMN1 = TRUE;
int gi_120 = 0;
int gi_124 = 0;
int gi_128 = 0;
int gi_132 = 0;
int gi_136 = 0;
int gi_140 = 0;
int gi_144 = 0;
int gi_148 = 0;
int gi_152 = 0;
int gi_156 = 0;
int gi_160 = 0;
int gi_164 = 0;
int gi_168 = 0;
int gi_172 = 0;
int gi_176 = 0;
int gi_180 = 0;
int gi_184 = 0;
int gi_188 = 0;
double gda_192[];
double gda_196[];
double gda_200[];
double gda_204[];
double gda_208[];
double gda_212[];
double gda_216[];
double gda_220[];
double gda_224[];
double gda_228[];
double gda_232[];
double gda_236[];
double gda_240[];
double gda_244[];
double gda_248[];
double gda_252[];
double gda_256[];
double gda_260[];

int init() {
   IndicatorShortName("3 Line Break On Chart +levels");
   set_prevBarTime(1, 0);
   set_prevBarTime(5, 0);
   set_prevBarTime(15, 0);
   set_prevBarTime(30, 0);
   set_prevBarTime(60, 0);
   set_prevBarTime(240, 0);
   set_prevBarTime(1440, 0);
   set_prevBarTime(10080, 0);
   set_prevBarTime(43200, 0);
   return (0);
}

int deinit() {
   DeleteHLineObject(StringConcatenate(getPeriodAsString(1), " Sup"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(1), " Res"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(1), " Sup C"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(1), " Res C"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(5), " Sup"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(5), " Res"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(5), " Sup C"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(5), " Res C"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(15), " Sup"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(15), " Res"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(15), " Sup C"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(15), " Res C"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(30), " Sup"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(30), " Res"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(30), " Sup C"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(30), " Res C"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(60), " Sup"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(60), " Res"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(60), " Sup C"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(60), " Res C"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(240), " Sup"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(240), " Res"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(240), " Sup C"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(240), " Res C"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(1440), " Sup"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(1440), " Res"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(1440), " Sup C"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(1440), " Res C"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(10080), " Sup"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(10080), " Res"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(10080), " Sup C"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(10080), " Res C"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(43200), " Sup"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(43200), " Res"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(43200), " Sup C"));
   DeleteHLineObject(StringConcatenate(getPeriodAsString(43200), " Res C"));
   return (0);
}

double Diap(int ai_0, bool ai_4, int ai_8, int ai_12) {
   double ld_ret_20;
   if (ai_4) {
      ld_ret_20 = get_max(ai_0, ai_12);
      for (int li_16 = 1; li_16 < ai_8; li_16++)
         if (get_max(ai_0, ai_12 - li_16) > ld_ret_20) ld_ret_20 = get_max(ai_0, ai_12 - li_16);
   }
   if (!ai_4) {
      ld_ret_20 = get_min(ai_0, ai_12);
      for (li_16 = 1; li_16 < ai_8; li_16++)
         if (get_min(ai_0, ai_12 - li_16) < ld_ret_20) ld_ret_20 = get_min(ai_0, ai_12 - li_16);
   }
   return (ld_ret_20);
}

void EmulateDoubleBuffer(double ada_0[], int ai_4) {
   if (ArraySize(ada_0) < ai_4) {
      ArraySetAsSeries(ada_0, FALSE);
      ArrayResize(ada_0, ai_4);
      ArraySetAsSeries(ada_0, TRUE);
   }
}

void DeleteHLineObject(string a_name_0) {
   ObjectDelete(a_name_0);
   ObjectDelete(a_name_0 + "_Label");
}

void ShowHLineObject(string a_name_0, int ai_8, int a_style_12, double ad_16, int ai_24) {
   if (ObjectFind(a_name_0) != 0) CreateHLineObject(a_name_0, ai_8, a_style_12, ad_16, ai_24);
   ObjectSet(a_name_0 + "_Label", OBJPROP_PRICE1, ad_16);
   ObjectSet(a_name_0 + "_Label", OBJPROP_TIME1, Time[0] + Period() * ai_24);
   ObjectSet(a_name_0 + "_Label", OBJPROP_STYLE, a_style_12);
   ObjectSet(a_name_0, OBJPROP_PRICE1, ad_16);
}

void CreateHLineObject(string a_text_0, color a_color_8, int a_style_12, double a_price_16, int ai_24) {
   ObjectCreate(a_text_0 + "_Label", OBJ_TEXT, 0, Time[0] + Period() * ai_24, a_price_16);
   ObjectSetText(a_text_0 + "_Label", a_text_0, 7, "Verdana", a_color_8);
   ObjectCreate(a_text_0, OBJ_HLINE, 0, Time[0], a_price_16);
   ObjectSet(a_text_0, OBJPROP_STYLE, a_style_12);
   ObjectSet(a_text_0, OBJPROP_COLOR, a_color_8);
   ObjectSet(a_text_0, OBJPROP_WIDTH, 1);
}

string getPeriodAsString(int ai_0) {
   string ls_ret_4 = 0;
   switch (ai_0) {
   case 1:
      ls_ret_4 = "M1";
      break;
   case 5:
      ls_ret_4 = "M5";
      break;
   case 15:
      ls_ret_4 = "M15";
      break;
   case 30:
      ls_ret_4 = "M30";
      break;
   case 60:
      ls_ret_4 = "H1";
      break;
   case 240:
      ls_ret_4 = "H4";
      break;
   case 1440:
      ls_ret_4 = "D1";
      break;
   case 10080:
      ls_ret_4 = "W1";
      break;
   case 43200:
      ls_ret_4 = "MN1";
   }
   return (ls_ret_4);
}

void set_prevBarTime(int ai_0, int ai_4) {
   switch (ai_0) {
   case 1:
      gi_120 = ai_4;
      return;
   case 5:
      gi_124 = ai_4;
      return;
   case 15:
      gi_128 = ai_4;
      return;
   case 30:
      gi_132 = ai_4;
      return;
   case 60:
      gi_136 = ai_4;
      return;
   case 240:
      gi_140 = ai_4;
      return;
   case 1440:
      gi_144 = ai_4;
      return;
   case 10080:
      gi_148 = ai_4;
      return;
   case 43200:
      gi_152 = ai_4;
      return;
      return;
   }
}

int get_prevBarTime(int ai_0) {
   switch (ai_0) {
   case 1:
      return (gi_120);
      break;
   case 5:
      return (gi_124);
      break;
   case 15:
      return (gi_128);
      break;
   case 30:
      return (gi_132);
      break;
   case 60:
      return (gi_136);
      break;
   case 240:
      return (gi_140);
      break;
   case 1440:
      return (gi_144);
      break;
   case 10080:
      return (gi_148);
      break;
   case 43200:
      return (gi_152);
   }
   return (0);
}

void set_prevBarCount(int ai_0, int ai_4) {
   switch (ai_0) {
   case 1:
      gi_156 = ai_4;
      return;
   case 5:
      gi_160 = ai_4;
      return;
   case 15:
      gi_164 = ai_4;
      return;
   case 30:
      gi_168 = ai_4;
      return;
   case 60:
      gi_172 = ai_4;
      return;
   case 240:
      gi_176 = ai_4;
      return;
   case 1440:
      gi_180 = ai_4;
      return;
   case 10080:
      gi_184 = ai_4;
      return;
   case 43200:
      gi_188 = ai_4;
      return;
      return;
   }
}

int get_prevBarCount(int ai_0) {
   switch (ai_0) {
   case 1:
      return (gi_156);
      break;
   case 5:
      return (gi_160);
      break;
   case 15:
      return (gi_164);
      break;
   case 30:
      return (gi_168);
      break;
   case 60:
      return (gi_172);
      break;
   case 240:
      return (gi_176);
      break;
   case 1440:
      return (gi_180);
      break;
   case 10080:
      return (gi_184);
      break;
   case 43200:
      return (gi_188);
   }
   return (0);
}

void set_max(int ai_0, int ai_4, double ad_8) {
   switch (ai_0) {
   case 1:
      gda_192[ai_4] = ad_8;
      return;
   case 5:
      gda_196[ai_4] = ad_8;
      return;
   case 15:
      gda_200[ai_4] = ad_8;
      return;
   case 30:
      gda_204[ai_4] = ad_8;
      return;
   case 60:
      gda_208[ai_4] = ad_8;
      return;
   case 240:
      gda_212[ai_4] = ad_8;
      return;
   case 1440:
      gda_216[ai_4] = ad_8;
      return;
   case 10080:
      gda_220[ai_4] = ad_8;
      return;
   case 43200:
      gda_224[ai_4] = ad_8;
      return;
      return;
   }
}

double get_max(int ai_0, int ai_4) {
   switch (ai_0) {
   case 1:
      return (gda_192[ai_4]);
      break;
   case 5:
      return (gda_196[ai_4]);
      break;
   case 15:
      return (gda_200[ai_4]);
      break;
   case 30:
      return (gda_204[ai_4]);
      break;
   case 60:
      return (gda_208[ai_4]);
      break;
   case 240:
      return (gda_212[ai_4]);
      break;
   case 1440:
      return (gda_216[ai_4]);
      break;
   case 10080:
      return (gda_220[ai_4]);
      break;
   case 43200:
      return (gda_224[ai_4]);
   }
   return (0.0);
}

void set_min(int ai_0, int ai_4, double ad_8) {
   switch (ai_0) {
   case 1:
      gda_228[ai_4] = ad_8;
      return;
   case 5:
      gda_232[ai_4] = ad_8;
      return;
   case 15:
      gda_236[ai_4] = ad_8;
      return;
   case 30:
      gda_240[ai_4] = ad_8;
      return;
   case 60:
      gda_244[ai_4] = ad_8;
      return;
   case 240:
      gda_248[ai_4] = ad_8;
      return;
   case 1440:
      gda_252[ai_4] = ad_8;
      return;
   case 10080:
      gda_256[ai_4] = ad_8;
      return;
   case 43200:
      gda_260[ai_4] = ad_8;
      return;
      return;
   }
}

double get_min(int ai_0, int ai_4) {
   switch (ai_0) {
   case 1:
      return (gda_228[ai_4]);
      break;
   case 5:
      return (gda_232[ai_4]);
      break;
   case 15:
      return (gda_236[ai_4]);
      break;
   case 30:
      return (gda_240[ai_4]);
      break;
   case 60:
      return (gda_244[ai_4]);
      break;
   case 240:
      return (gda_248[ai_4]);
      break;
   case 1440:
      return (gda_252[ai_4]);
      break;
   case 10080:
      return (gda_256[ai_4]);
      break;
   case 43200:
      return (gda_260[ai_4]);
   }
   return (0.0);
}

void emulate_tlbmaxmin(int ai_0, int ai_4) {
   switch (ai_0) {
   case 1:
      EmulateDoubleBuffer(gda_192, ai_4);
      EmulateDoubleBuffer(gda_228, ai_4);
      return;
   case 5:
      EmulateDoubleBuffer(gda_196, ai_4);
      EmulateDoubleBuffer(gda_232, ai_4);
      return;
   case 15:
      EmulateDoubleBuffer(gda_200, ai_4);
      EmulateDoubleBuffer(gda_236, ai_4);
      return;
   case 30:
      EmulateDoubleBuffer(gda_204, ai_4);
      EmulateDoubleBuffer(gda_240, ai_4);
      return;
   case 60:
      EmulateDoubleBuffer(gda_208, ai_4);
      EmulateDoubleBuffer(gda_244, ai_4);
      return;
   case 240:
      EmulateDoubleBuffer(gda_212, ai_4);
      EmulateDoubleBuffer(gda_248, ai_4);
      return;
   case 1440:
      EmulateDoubleBuffer(gda_216, ai_4);
      EmulateDoubleBuffer(gda_252, ai_4);
      return;
   case 10080:
      EmulateDoubleBuffer(gda_220, ai_4);
      EmulateDoubleBuffer(gda_256, ai_4);
      return;
   case 43200:
      EmulateDoubleBuffer(gda_224, ai_4);
      EmulateDoubleBuffer(gda_260, ai_4);
      return;
      return;
   }
}

void displayPeriod(int a_timeframe_0) {
   int li_4;
   int l_count_8;
   int li_12;
   int li_20;
   double ld_24;
   double ld_32;
   double ld_40;
   double ld_48;
   int l_count_56;
   int l_count_60;
   int li_unused_64;
   if (get_prevBarTime(a_timeframe_0) == 0 || get_prevBarTime(a_timeframe_0) != iTime(Symbol(), a_timeframe_0, 0) || get_prevBarCount(a_timeframe_0) == 0 || get_prevBarCount(a_timeframe_0) != iBars(Symbol(), a_timeframe_0)) {
      set_prevBarTime(a_timeframe_0, iTime(Symbol(), a_timeframe_0, 0));
      set_prevBarCount(a_timeframe_0, iBars(Symbol(), a_timeframe_0));
      li_4 = iBars(Symbol(), a_timeframe_0);
      if (maxBarsForPeriod > 0 && li_4 > maxBarsForPeriod) li_4 = maxBarsForPeriod;
      l_count_8 = 0;
      li_12 = li_4;
      emulate_tlbmaxmin(a_timeframe_0, li_4);
      li_20 = 1;
      while (iClose(Symbol(), a_timeframe_0, li_12 - 1) == iClose(Symbol(), a_timeframe_0, li_12 - 1 - li_20)) {
         li_20++;
         if (li_20 > li_12 - 1) break;
      }
      if (iClose(Symbol(), a_timeframe_0, li_12 - 1) > iClose(Symbol(), a_timeframe_0, li_12 - 1 - li_20)) {
         set_max(a_timeframe_0, 0, iClose(Symbol(), a_timeframe_0, li_12 - 1));
         set_min(a_timeframe_0, 0, iClose(Symbol(), a_timeframe_0, li_12 - 1 - li_20));
      }
      if (iClose(Symbol(), a_timeframe_0, li_12 - 1) < iClose(Symbol(), a_timeframe_0, li_12 - 1 - li_20)) {
         set_max(a_timeframe_0, 0, iClose(Symbol(), a_timeframe_0, li_12 - 1 - li_20));
         set_min(a_timeframe_0, 0, iClose(Symbol(), a_timeframe_0, li_12 - 1));
      }
      for (int li_16 = 1; li_16 < LB; li_16++) {
         while (iClose(Symbol(), a_timeframe_0, li_12 - li_20) <= Diap(a_timeframe_0, 1, li_16, l_count_8) && iClose(Symbol(), a_timeframe_0, li_12 - li_20) >= Diap(a_timeframe_0, 0, li_16, l_count_8)) {
            li_20++;
            if (li_20 > li_12 - 1) break;
         }
         if (li_20 > li_12 - 1) break;
         if (iClose(Symbol(), a_timeframe_0, li_12 - li_20) > get_max(a_timeframe_0, li_16 - 1)) {
            set_max(a_timeframe_0, li_16, iClose(Symbol(), a_timeframe_0, li_12 - li_20));
            set_min(a_timeframe_0, li_16, get_max(a_timeframe_0, li_16 - 1));
            l_count_8++;
         }
         if (iClose(Symbol(), a_timeframe_0, li_12 - li_20) < get_min(a_timeframe_0, li_16 - 1)) {
            set_min(a_timeframe_0, li_16, iClose(Symbol(), a_timeframe_0, li_12 - li_20));
            set_max(a_timeframe_0, li_16, get_min(a_timeframe_0, li_16 - 1));
            l_count_8++;
         }
      }
      for (li_16 = LB; li_16 < li_12; li_16++) {
         while (iClose(Symbol(), a_timeframe_0, li_12 - li_20) <= Diap(a_timeframe_0, 1, LB, l_count_8) && iClose(Symbol(), a_timeframe_0, li_12 - li_20) >= Diap(a_timeframe_0, 0, LB, l_count_8)) {
            li_20++;
            if (li_20 > li_12 - 1) break;
         }
         if (li_20 > li_12 - 1) break;
         if (iClose(Symbol(), a_timeframe_0, li_12 - li_20) > get_max(a_timeframe_0, li_16 - 1)) {
            set_max(a_timeframe_0, li_16, iClose(Symbol(), a_timeframe_0, li_12 - li_20));
            set_min(a_timeframe_0, li_16, get_max(a_timeframe_0, li_16 - 1));
            l_count_8++;
         }
         if (iClose(Symbol(), a_timeframe_0, li_12 - li_20) < get_min(a_timeframe_0, li_16 - 1)) {
            set_min(a_timeframe_0, li_16, iClose(Symbol(), a_timeframe_0, li_12 - li_20));
            set_max(a_timeframe_0, li_16, get_min(a_timeframe_0, li_16 - 1));
            l_count_8++;
         }
      }
      ld_24 = 0;
      ld_32 = 0;
      ld_40 = 0;
      ld_48 = 0;
      l_count_56 = 0;
      l_count_60 = 0;
      li_unused_64 = 0;
      for (li_16 = 1; li_16 <= l_count_8; li_16++) {
         if (get_max(a_timeframe_0, li_16) > get_max(a_timeframe_0, li_16 - 1)) {
            if (l_count_60 >= LB) ld_24 = get_max(a_timeframe_0, li_16 - LB);
            else ld_24 = get_min(a_timeframe_0, li_16 - l_count_60 - 1);
            ld_48 = get_max(a_timeframe_0, li_16);
            ld_40 = 0;
            ld_32 = 0;
            l_count_60++;
            l_count_56 = 0;
         }
         if (get_max(a_timeframe_0, li_16) < get_max(a_timeframe_0, li_16 - 1)) {
            if (l_count_56 >= LB) ld_32 = get_min(a_timeframe_0, li_16 - LB);
            else ld_32 = get_max(a_timeframe_0, li_16 - l_count_56 - 1);
            ld_40 = get_min(a_timeframe_0, li_16);
            ld_24 = 0;
            ld_48 = 0;
            l_count_60 = 0;
            l_count_56++;
         }
      }
      if (ld_24 > 0.0) ShowHLineObject(StringConcatenate(getPeriodAsString(a_timeframe_0), " Sup"), 16711680, STYLE_SOLID, ld_24, 500);
      else DeleteHLineObject(StringConcatenate(getPeriodAsString(a_timeframe_0), " Sup"));
      if (ld_32 > 0.0) ShowHLineObject(StringConcatenate(getPeriodAsString(a_timeframe_0), " Res"), 255, STYLE_SOLID, ld_32, 500);
      else DeleteHLineObject(StringConcatenate(getPeriodAsString(a_timeframe_0), " Res"));
      if (ld_40 > 0.0) ShowHLineObject(StringConcatenate(getPeriodAsString(a_timeframe_0), " Sup C"), 16711680, STYLE_DASHDOTDOT, ld_40, 1200);
      else DeleteHLineObject(StringConcatenate(getPeriodAsString(a_timeframe_0), " Sup C"));
      if (ld_48 > 0.0) ShowHLineObject(StringConcatenate(getPeriodAsString(a_timeframe_0), " Res C"), 255, STYLE_DASHDOTDOT, ld_48, 1200);
      else DeleteHLineObject(StringConcatenate(getPeriodAsString(a_timeframe_0), " Res C"));
   }
}

int start() {
   if (Period() <= PERIOD_M1 && showM01) displayPeriod(PERIOD_M1);
   if (Period() <= PERIOD_M5 && showM05) displayPeriod(PERIOD_M5);
   if (Period() <= PERIOD_M15 && showM15) displayPeriod(PERIOD_M15);
   if (Period() <= PERIOD_M30 && showM30) displayPeriod(PERIOD_M30);
   if (Period() <= PERIOD_H1 && showH01) displayPeriod(PERIOD_H1);
   if (Period() <= PERIOD_H4 && showH04) displayPeriod(PERIOD_H4);
   if (Period() <= PERIOD_D1 && showD01) displayPeriod(PERIOD_D1);
   if (Period() <= PERIOD_W1 && showW01) displayPeriod(PERIOD_W1);
   if (Period() <= PERIOD_MN1 && showMN1) displayPeriod(PERIOD_MN1);
   return (0);
}