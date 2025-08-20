//+------------------------------------------------------------------+
//|                                                   #i-Targets.mq4 |
//|                                                 Copyright © 2010 |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010"
#property link      ""

#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 White
#property indicator_color2 OrangeRed
#property indicator_color3 Fuchsia
#property indicator_color4 Fuchsia
#property indicator_color5 Green
#property indicator_color6 Lime
#property indicator_color7 Lime

extern int Nmbr_Bars = 85;
extern int Order = 0;
extern double Ecart = 2.2;
double g_ibuf_92[];
double g_ibuf_96[];
double g_ibuf_100[];
double g_ibuf_104[];
double g_ibuf_108[];
double g_ibuf_112[];
double g_ibuf_116[];
double gda_120[20][20];
double gda_124[20];
double gda_128[20];
double gda_132[20];
int gi_136;
int gi_140;
int gi_144;
int gi_148;
int gi_152;
int gi_156;
int gi_160;
double gd_164;
double gd_172;
double gd_180;
double gd_188;
double gd_196;

int init() {
   Comment("");
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, g_ibuf_92);
   SetIndexBuffer(1, g_ibuf_96);
   SetIndexBuffer(2, g_ibuf_100);
   SetIndexBuffer(3, g_ibuf_104);
   SetIndexBuffer(4, g_ibuf_108);
   SetIndexBuffer(5, g_ibuf_112);
   SetIndexBuffer(6, g_ibuf_116);
   return (0);
}

int deinit() {
   Comment("");
   ObjectDelete("REG");
   ObjectDelete("X1");
   ObjectDelete("X2");
   ObjectDelete("X3");
   ObjectDelete("Z1");
   ObjectDelete("Z2");
   ObjectDelete("Z3");
   return (0);
}

int start() {
   if (Year() >= 2035) return (0);
   datetime l_time_0 = 0;
   SetIndexDrawBegin(0, Bars - Nmbr_Bars - 1);
   SetIndexDrawBegin(1, Bars - Nmbr_Bars - 1);
   SetIndexDrawBegin(2, Bars - Nmbr_Bars - 1);
   SetIndexDrawBegin(3, Bars - Nmbr_Bars - 1);
   SetIndexDrawBegin(4, Bars - Nmbr_Bars - 1);
   SetIndexDrawBegin(5, Bars - Nmbr_Bars - 1);
   SetIndexDrawBegin(6, Bars - Nmbr_Bars - 1);
   if (l_time_0 != Time[0]) {
      ObjectDelete("REG");
      ObjectDelete("X1");
      ObjectDelete("X2");
      ObjectDelete("X3");
      ObjectDelete("Z1");
      ObjectDelete("Z2");
      ObjectDelete("Z3");
      l_time_0 = Time[0];
   }
   gi_152 = Order + 1;
   gda_124[1] = Nmbr_Bars + 1;
   for (gi_160 = 1; gi_160 <= gi_152 * 2 - 2; gi_160++) {
      gd_164 = 0;
      for (gi_156 = 0; gi_156 <= Nmbr_Bars; gi_156++) gd_164 += MathPow(gi_156, gi_160);
      gda_124[gi_160 + 1] = gd_164;
   }
   for (gi_160 = 1; gi_160 <= gi_152; gi_160++) {
      gd_164 = 0;
      for (gi_156 = 0; gi_156 <= Nmbr_Bars; gi_156++) {
         if (gi_160 == 1) gd_164 += (High[gi_156] + Low[gi_156]) / 2.0;
         else gd_164 += (High[gi_156] + Low[gi_156]) / 2.0 * MathPow(gi_156, gi_160 - 1);
      }
      gda_128[gi_160] = gd_164;
   }
   for (gi_140 = 1; gi_140 <= gi_152; gi_140++) {
      for (gi_136 = 1; gi_136 <= gi_152; gi_136++) {
         gi_144 = gi_136 + gi_140 - 1;
         gda_120[gi_136][gi_140] = gda_124[gi_144];
      }
   }
   for (gi_144 = 1; gi_144 <= gi_152 - 1; gi_144++) {
      gi_148 = 0;
      gd_188 = 0;
      for (gi_136 = gi_144; gi_136 <= gi_152; gi_136++) {
         if (MathAbs(gda_120[gi_136][gi_144]) > gd_188) {
            gd_188 = MathAbs(gda_120[gi_136][gi_144]);
            gi_148 = gi_136;
         }
      }
      if (gi_148 == 0) return (0);
      if (gi_148 != gi_144) {
         for (gi_140 = 1; gi_140 <= gi_152; gi_140++) {
            gd_196 = gda_120[gi_144][gi_140];
            gda_120[gi_144][gi_140] = gda_120[gi_148][gi_140];
            gda_120[gi_148][gi_140] = gd_196;
         }
         gd_196 = gda_128[gi_144];
         gda_128[gi_144] = gda_128[gi_148];
         gda_128[gi_148] = gd_196;
      }
      for (gi_136 = gi_144 + 1; gi_136 <= gi_152; gi_136++) {
         gd_180 = gda_120[gi_136][gi_144] / gda_120[gi_144][gi_144];
         for (gi_140 = 1; gi_140 <= gi_152; gi_140++) {
            if (gi_140 == gi_144) gda_120[gi_136][gi_140] = 0;
            else gda_120[gi_136][gi_140] = gda_120[gi_136][gi_140] - gd_180 * gda_120[gi_144][gi_140];
         }
         gda_128[gi_136] = gda_128[gi_136] - gd_180 * gda_128[gi_144];
      }
   }
   gda_132[gi_152] = gda_128[gi_152] / gda_120[gi_152][gi_152];
   for (gi_136 = gi_152 - 1; gi_136 >= 1; gi_136--) {
      gd_196 = 0;
      for (gi_140 = 1; gi_140 <= gi_152 - gi_136; gi_140++) {
         gd_196 += (gda_120[gi_136][gi_136 + gi_140]) * (gda_132[gi_136 + gi_140]);
         gda_132[gi_136] = 1 / gda_120[gi_136][gi_136] * (gda_128[gi_136] - gd_196);
      }
   }
   for (gi_156 = 0; gi_156 <= Nmbr_Bars; gi_156++) {
      gd_164 = 0;
      for (gi_144 = 1; gi_144 <= Order; gi_144++) gd_164 += (gda_132[gi_144 + 1]) * MathPow(gi_156, gi_144);
      g_ibuf_92[gi_156] = gda_132[1] + gd_164;
   }
   gd_172 = iStdDev(NULL, 0, Nmbr_Bars, 0, MODE_SMA, PRICE_HIGH, 0) * Ecart;
   for (gi_156 = 0; gi_156 <= Nmbr_Bars; gi_156++) {
      g_ibuf_104[gi_156] = g_ibuf_92[gi_156] + gd_172;
      g_ibuf_100[gi_156] = g_ibuf_92[gi_156] + (g_ibuf_104[gi_156] - g_ibuf_92[gi_156]) / 1.382;
      g_ibuf_96[gi_156] = g_ibuf_92[gi_156] + (g_ibuf_100[gi_156] - g_ibuf_92[gi_156]) / 1.618;
      g_ibuf_116[gi_156] = g_ibuf_92[gi_156] - gd_172;
      g_ibuf_112[gi_156] = g_ibuf_92[gi_156] - (g_ibuf_92[gi_156] - g_ibuf_116[gi_156]) / 1.382;
      g_ibuf_108[gi_156] = g_ibuf_92[gi_156] - (g_ibuf_92[gi_156] - g_ibuf_112[gi_156]) / 1.618;
   }

   return (0);
}