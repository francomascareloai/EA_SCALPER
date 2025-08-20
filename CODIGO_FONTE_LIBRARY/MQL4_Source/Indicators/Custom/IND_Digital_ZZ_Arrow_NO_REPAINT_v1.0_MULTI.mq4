
#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Silver
#property indicator_color2 Red
#property indicator_color3 Lime
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2

extern int NoiseLevel = 21;
extern int SwitchPercent = 30;
extern int Mode = 1;
extern int OncePerCandle = 1;
extern int MaxBars = 300;
extern int ArrowOffset = 5;
double g_ibuf_100[];
double g_ibuf_104[];
double g_ibuf_108[];
int gi_unused_112 = 3;
bool gi_unused_116 = FALSE;
double gd_152;
double gd_unused_160;
double gd_168 = 0.0;
double gd_176 = 0.0;
double gd_184 = 0.0;
double gd_192 = 0.0;
double gd_200 = 0.0;
int gi_208 = 0;
int gi_212 = 0;
int gi_216 = 0;
int gi_unused_220 = 0;
int gi_unused_224 = -1;
int g_bars_228 = 0;
int g_time_232 = 0;
int gi_unused_236 = 0;

int new_candle() {
   if (g_time_232 != Time[0] || g_bars_228 != Bars) {
      g_time_232 = Time[0];
      g_bars_228 = Bars;
      return (1);
   }
   return (0);
}

int init() {
   IndicatorBuffers(3);
   SetIndexStyle(0, DRAW_SECTION);//, STYLE_SOLID, 1
   SetIndexBuffer(0, g_ibuf_100);
   SetIndexBuffer(1, g_ibuf_104);
   SetIndexBuffer(2, g_ibuf_108);
   SetIndexStyle(1, DRAW_ARROW);//, EMPTY, 0, Red
   SetIndexArrow(1, SYMBOL_ARROWDOWN);
   SetIndexStyle(2, DRAW_ARROW);//, EMPTY, 0, Lime
   SetIndexArrow(2, SYMBOL_ARROWUP);
   SetIndexEmptyValue(0, 0.0);
   IndicatorShortName("ZZ_L");
   gi_unused_236 = 0;
   if (Mode == 0) {
      gd_168 = Close[0] - NoiseLevel / 2 * Point;
      gd_176 = Close[0] + NoiseLevel / 2 * Point;
   } else {
      gd_168 = Open[0] - NoiseLevel / 2 * Point;
      gd_176 = Open[0] + NoiseLevel / 2 * Point;
   }
   gd_200 = Open[0];
   gd_176 = gd_168;
   gd_184 = gd_168;
   gd_192 = gd_168;
   gd_152 = gd_168;
   gd_unused_160 = gd_152;
   return (0);
}

int start() {
   int l_ind_counted_4 = IndicatorCounted();
   if (!new_candle())
      if (OncePerCandle == 1) return (0);
   int li_32 = Bars;
   if (li_32 > MaxBars) li_32 = MaxBars;
   int li_8 = li_32;
   gi_unused_224 = li_8;
   gi_unused_220 = 0;
   g_ibuf_100[1] = gd_200;
   int li_12 = li_8 - 1;
   if (Mode == 0) g_ibuf_100[li_12] = Close[li_12];
   else g_ibuf_100[li_12] = Open[li_12];
   while (li_12 >= 0) {
      GetMoving(li_12);
      if (gi_216 == TRUE) {
         if (gi_208 == 1) {
            g_ibuf_100[li_12] = gd_184;
            g_ibuf_108[li_12] = gd_184 - ArrowOffset * Point;
            g_ibuf_104[li_12] = 0.0;
            if (li_12 == 0) gd_200 = gd_184;
         }
         if (gi_208 == -1) {
            g_ibuf_100[li_12] = gd_192;
            g_ibuf_104[li_12] = gd_192 + ArrowOffset * Point;
            g_ibuf_108[li_12] = 0.0;
            if (li_12 == 0) gd_200 = gd_192;
         }
         gi_216 = FALSE;
      } else {
         if (li_12 == 0) {
            if (gi_208 == 1) g_ibuf_100[0] = gd_176;
            if (gi_208 == -1) g_ibuf_100[0] = gd_168;
         } else {
            g_ibuf_100[li_12] = 0.0;
            g_ibuf_104[li_12] = 0.0;
            g_ibuf_108[li_12] = 0.0;
            if (li_12 == 0) gd_200 = 0.0;
         }
      }
      li_12--;
   }
   return (0);
}

int GetMoving(int ai_0) {
   int li_24 = (gd_176 - gd_168) * SwitchPercent / 100.0;
   if (li_24 < NoiseLevel) li_24 = NoiseLevel;
   if (Mode == 1) gd_152 = Open[ai_0];
   else {
      if (gi_208 != -1) gd_152 = High[ai_0];
      else gd_152 = Low[ai_0];
   }
   if (gi_208 != -1 && gd_152 > gd_176) gd_176 = gd_152;
   if (gi_208 != 1 && gd_152 < gd_168) gd_168 = gd_152;
   if (gd_176 - gd_168 >= NoiseLevel * Point) {
      if (gi_208 != 1 && gd_152 - gd_168 >= li_24 * Point) {
         gi_208 = 1;
         gd_184 = gd_168;
         gd_176 = gd_152;
         gd_unused_160 = gd_152;
      }
      if (gi_208 != -1 && gd_176 - gd_152 >= li_24 * Point) {
         gi_208 = -1;
         gd_192 = gd_176;
         gd_168 = gd_152;
         gd_unused_160 = gd_152;
      }
   }
   if (gi_212 != gi_208) {
      gi_212 = gi_208;
      gi_216 = TRUE;
   }
   return (gi_208);
}