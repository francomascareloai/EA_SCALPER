#property copyright "Polynkov A.A."
#property link      ""

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 CLR_NONE
#property indicator_color2 Gold
#property indicator_color3 Gold
#property indicator_color4 CLR_NONE
#property indicator_color5 CLR_NONE
#property indicator_color6 Tomato
#property indicator_color7 Tomato
#property indicator_color8 Aqua

string gs_76 = "ABHAFXS_Timing";
string gs_unused_84 = "V1.00";
int gi_92 = 123;
int gi_96 = 0;
int gi_unused_100 = 0;
double gd_104 = 1.618;
int gi_unused_112 = 1102;
double g_ibuf_116[];
double g_ibuf_120[];
double g_ibuf_124[];
double g_ibuf_128[];
double g_ibuf_132[];
double g_ibuf_136[];
double g_ibuf_140[];
double g_ibuf_144[];
double gda_148[10][10];
double gda_152[10];
double gda_156[10];
double gda_160[20];
double gd_164;
int g_period_172;
int gi_176;
double gd_180;
double gd_188;
double gd_196;
int gi_204;
int gi_208;
int gi_212;
int gi_216;
int gi_220;
double gd_224;

int init() {
   SetIndexStyle(0, DRAW_NONE, EMPTY, EMPTY, CLR_NONE);
   SetIndexBuffer(0, g_ibuf_116);
   SetIndexStyle(1, DRAW_LINE, STYLE_DASH, 3, Aqua);
   SetIndexBuffer(1, g_ibuf_120);
   SetIndexEmptyValue(0, 0.0);
   SetIndexShift(0, 0);
   SetIndexLabel(0, "UPPER_LINE");
   SetIndexStyle(2, DRAW_LINE, STYLE_DASH, 3, Aqua);
   SetIndexBuffer(2, g_ibuf_124);
   SetIndexEmptyValue(0, 0.0);
   SetIndexShift(0, 0);
   SetIndexLabel(0, "LOWER_LINE");
   SetIndexStyle(3, DRAW_HISTOGRAM, STYLE_DASH, 3, Fuchsia);
   SetIndexBuffer(3, g_ibuf_128);
   SetIndexStyle(4, DRAW_HISTOGRAM, STYLE_DASH, 3, Blue);
   SetIndexBuffer(4, g_ibuf_132);
   SetIndexStyle(5, DRAW_HISTOGRAM, STYLE_DASHDOT, 3, White);
   SetIndexBuffer(5, g_ibuf_136);
   SetIndexStyle(6, DRAW_HISTOGRAM, STYLE_DASHDOT, 3, Lime);
   SetIndexBuffer(6, g_ibuf_140);
   SetIndexStyle(7, DRAW_HISTOGRAM, STYLE_SOLID, 3, Red);
   SetIndexBuffer(7, g_ibuf_144);
   SetIndexEmptyValue(0, 0.0);
   SetIndexShift(0, 0);
   SetIndexLabel(0, "SIGNAL_LINE");
   IndicatorShortName(gs_76);
   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS) + 1.0);
   g_period_172 = MathRound(gi_92);
   gi_220 = gi_96 + 1;
   return (0);
}

int deinit() {
   ObjectsDeleteAll(EMPTY, OBJ_LABEL);
   return (0);
}

int start() {
   int l_index_0;
   double l_iatr_12;
   double l_iatr_20;
   double ld_28;
   int l_ind_counted_4 = IndicatorCounted();
   g_period_172 = gi_92;
   gda_160[1] = g_period_172 + 1;
   SetIndexDrawBegin(0, Bars - g_period_172 - 1);
   SetIndexDrawBegin(1, Bars - g_period_172 - 1);
   SetIndexDrawBegin(2, Bars - g_period_172 - 1);
   SetIndexDrawBegin(3, Bars - g_period_172 - 1);
   SetIndexDrawBegin(4, Bars - g_period_172 - 1);
   SetIndexDrawBegin(5, Bars - g_period_172 - 1);
   SetIndexDrawBegin(6, Bars - g_period_172 - 1);
   SetIndexDrawBegin(7, Bars - g_period_172 - 1);
   for (int li_8 = 1; li_8 <= gi_220 * 2 - 2; li_8++) {
      gd_164 = 0;
      for (gi_176 = l_index_0; gi_176 <= l_index_0 + g_period_172; gi_176++) gd_164 += MathPow(gi_176, li_8);
      gda_160[li_8 + 1] = gd_164;
   }
   for (li_8 = 1; li_8 <= gi_220; li_8++) {
      gd_164 = 0.0;
      for (gi_176 = l_index_0; gi_176 <= l_index_0 + g_period_172; gi_176++) {
         if (li_8 == 1) gd_164 += Close[gi_176];
         else gd_164 += Close[gi_176] * MathPow(gi_176, li_8 - 1);
      }
      gda_152[li_8] = gd_164;
   }
   for (gi_208 = 1; gi_208 <= gi_220; gi_208++) {
      for (gi_204 = 1; gi_204 <= gi_220; gi_204++) {
         gi_212 = gi_204 + gi_208 - 1;
         gda_148[gi_204][gi_208] = gda_160[gi_212];
      }
   }
   for (gi_212 = 1; gi_212 <= gi_220 - 1; gi_212++) {
      gi_216 = 0;
      gd_188 = 0;
      for (gi_204 = gi_212; gi_204 <= gi_220; gi_204++) {
         if (MathAbs(gda_148[gi_204][gi_212]) > gd_188) {
            gd_188 = MathAbs(gda_148[gi_204][gi_212]);
            gi_216 = gi_204;
         }
      }
      if (gi_216 == 0) return (0);
      if (gi_216 != gi_212) {
         for (gi_208 = 1; gi_208 <= gi_220; gi_208++) {
            gd_196 = gda_148[gi_212][gi_208];
            gda_148[gi_212][gi_208] = gda_148[gi_216][gi_208];
            gda_148[gi_216][gi_208] = gd_196;
         }
         gd_196 = gda_152[gi_212];
         gda_152[gi_212] = gda_152[gi_216];
         gda_152[gi_216] = gd_196;
      }
      for (gi_204 = gi_212 + 1; gi_204 <= gi_220; gi_204++) {
         gd_180 = gda_148[gi_204][gi_212] / gda_148[gi_212][gi_212];
         for (gi_208 = 1; gi_208 <= gi_220; gi_208++) {
            if (gi_208 == gi_212) gda_148[gi_204][gi_208] = 0;
            else gda_148[gi_204][gi_208] = gda_148[gi_204][gi_208] - gd_180 * gda_148[gi_212][gi_208];
         }
         gda_152[gi_204] = gda_152[gi_204] - gd_180 * gda_152[gi_212];
      }
   }
   gda_156[gi_220] = gda_152[gi_220] / gda_148[gi_220][gi_220];
   for (gi_204 = gi_220 - 1; gi_204 >= 1; gi_204--) {
      gd_196 = 0;
      for (gi_208 = 1; gi_208 <= gi_220 - gi_204; gi_208++) {
         gd_196 += (gda_148[gi_204][gi_204 + gi_208]) * (gda_156[gi_204 + gi_208]);
         gda_156[gi_204] = 1 / gda_148[gi_204][gi_204] * (gda_152[gi_204] - gd_196);
      }
   }
   for (gi_176 = l_index_0; gi_176 <= l_index_0 + g_period_172; gi_176++) {
      gd_164 = 0;
      for (gi_212 = 1; gi_212 <= gi_96; gi_212++) gd_164 += (gda_156[gi_212 + 1]) * MathPow(gi_176, gi_212);
      g_ibuf_116[gi_176] = gda_156[1] + gd_164;
   }
   gd_224 = 0.0;
   for (gi_176 = l_index_0; gi_176 <= l_index_0 + g_period_172; gi_176++) gd_224 += MathPow(Close[gi_176] - g_ibuf_116[gi_176], 2);
   gd_224 = MathSqrt(gd_224 / (g_period_172 + 1)) * gd_104;
   for (gi_176 = l_index_0; gi_176 <= l_index_0 + g_period_172; gi_176++) {
      g_ibuf_120[gi_176] = g_ibuf_116[gi_176] + gd_224;
      g_ibuf_124[gi_176] = g_ibuf_116[gi_176] - gd_224;
      l_iatr_12 = iATR(Symbol(), 0, 2, 0);
      l_iatr_20 = iATR(Symbol(), 0, g_period_172, 0);
      ld_28 = l_iatr_20 / l_iatr_12;
      if (Digits == 2) {
         g_ibuf_136[gi_176] = NormalizeDouble(g_ibuf_120[gi_176] - ld_28 * l_iatr_20 / 2.0, Digits);
         g_ibuf_140[gi_176] = NormalizeDouble(g_ibuf_124[gi_176] + ld_28 * l_iatr_20 / 2.0, Digits);
      } else {
         if (Digits == 4) {
            g_ibuf_136[gi_176] = NormalizeDouble(g_ibuf_120[gi_176] - ld_28 * l_iatr_20 / 3.0, Digits);
            g_ibuf_140[gi_176] = NormalizeDouble(g_ibuf_124[gi_176] + ld_28 * l_iatr_20 / 3.0, Digits);
         } else {
            g_ibuf_136[gi_176] = NormalizeDouble(g_ibuf_120[gi_176] - ld_28 * l_iatr_20 / 1.5, Digits);
            g_ibuf_140[gi_176] = NormalizeDouble(g_ibuf_124[gi_176] + ld_28 * l_iatr_20 / 1.5, Digits);
         }
      }
   }
   int li_36 = Bars - l_ind_counted_4;
   if (l_ind_counted_4 > 0) li_36++;
   for (l_index_0 = 0; l_index_0 < li_36; l_index_0++) g_ibuf_144[l_index_0] = NormalizeDouble((High[l_index_0] + Low[l_index_0]) / 2.0, Digits);
   return (0);
}