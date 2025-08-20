#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Red
#property indicator_color4 Aqua
#property indicator_color5 Blue
#property indicator_color6 Red

extern int Z = 2;
extern int Z1 = 3;
extern int S = 0;
extern int S1 = 0;
double gd_92;
double gd_100;
double gd_108;
double gd_116 = 0.0;
double gd_124;
double gd_132 = 0.0;
double gd_140;
double gd_148;
int gi_156 = 0;
double gd_unused_168 = 0.0;
int gi_unused_176 = 0;
double g_ibuf_180[];
double g_ibuf_184[];
double g_ibuf_188[];
double g_ibuf_192[];
double g_ibuf_196[];
double g_ibuf_200[];
double g_ibuf_204[];
double g_ibuf_208[];

int init() {
   IndicatorBuffers(8);
   SetIndexBuffer(6, g_ibuf_188);
   SetIndexBuffer(7, g_ibuf_192);
   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS));
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexBuffer(0, g_ibuf_180);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexBuffer(1, g_ibuf_184);
   SetIndexDrawBegin(0, Z1 + 1);
   SetIndexDrawBegin(1, Z1 + 1);
   SetIndexDrawBegin(2, Z1 + 1);
   SetIndexDrawBegin(3, Z1 + 1);
   SetIndexDrawBegin(4, Z1 + 1);
   SetIndexDrawBegin(5, Z1 + 1);
   SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID, 2);
   SetIndexBuffer(2, g_ibuf_196);
   SetIndexStyle(3, DRAW_HISTOGRAM, STYLE_SOLID, 2);
   SetIndexBuffer(3, g_ibuf_200);
   SetIndexStyle(4, DRAW_ARROW, STYLE_DASH, 3);
   SetIndexArrow(4, 108);
   SetIndexBuffer(4, g_ibuf_204);
   SetIndexStyle(5, DRAW_ARROW, STYLE_DASH, 3);
   SetIndexArrow(5, 108);
   SetIndexBuffer(5, g_ibuf_208);
   IndicatorShortName("NeuroTrend");
   SetIndexLabel(0, "NTLine1");
   SetIndexLabel(1, "NTLine2");
   SetIndexLabel(2, "NTBar1");
   SetIndexLabel(3, "NTBar2");
   SetIndexLabel(4, "NTSig1");
   SetIndexLabel(5, "NTSig2");
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   int li_8;
   int li_unused_0 = MarketInfo(Symbol(), MODE_DIGITS);
   if (Bars <= Z1) return (0);
   int l_ind_counted_4 = IndicatorCounted();
   if (l_ind_counted_4 == 0) li_8 = Bars - 1;
   if (l_ind_counted_4 > 0) li_8 = Bars - l_ind_counted_4 - 1;
   for (int li_12 = li_8; li_12 >= 0; li_12--) {
      gd_92 = High[iHighest(NULL, 0, MODE_HIGH, Z, li_12)] + S * Point;
      gd_100 = Low[iLowest(NULL, 0, MODE_LOW, Z, li_12)] - S * Point;
      gd_108 = High[iHighest(NULL, 0, MODE_HIGH, Z1, li_12)] + S1 * Point;
      gd_116 = Low[iLowest(NULL, 0, MODE_LOW, Z1, li_12)] - S1 * Point;
      if (Close[li_12] > g_ibuf_180[li_12 + 1]) gd_124 = gd_100;
      else gd_124 = gd_92;
      if (Close[li_12] > g_ibuf_184[li_12 + 1]) gd_132 = gd_116;
      else gd_132 = gd_108;
      g_ibuf_180[li_12] = gd_124;
      g_ibuf_184[li_12] = gd_132;
      gd_140 = 0.0;
      gd_148 = 0.0;
      if (Close[li_12] < gd_124 && Close[li_12] < gd_132) {
         gd_140 = High[li_12];
         gd_148 = Low[li_12];
      }
      if (Close[li_12] > gd_124 && Close[li_12] > gd_132) {
         gd_140 = Low[li_12];
         gd_148 = High[li_12];
      }
      g_ibuf_196[li_12] = gd_140;
      g_ibuf_200[li_12] = gd_148;
      if (Close[li_12] > gd_132 && Close[li_12] > gd_124 && gi_156 != 1) {
         g_ibuf_204[li_12] = gd_132;
         g_ibuf_208[li_12] = EMPTY_VALUE;
         gi_156 = 1;
      }
      if (Close[li_12] < gd_132 && Close[li_12] < gd_124 && gi_156 != 2) {
         g_ibuf_208[li_12] = gd_132;
         g_ibuf_204[li_12] = EMPTY_VALUE;
         gi_156 = 2;
      }
   }
   return (0);
}
