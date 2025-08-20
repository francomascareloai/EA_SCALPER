

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Yellow
#property indicator_color2 Lime
#property indicator_color3 Red
#property indicator_color4 Aqua

extern int dist2 = 21;
extern int dist1 = 14;
double G_ibuf_84[];
double G_ibuf_88[];
double G_ibuf_92[];
double G_ibuf_96[];

int init() {
   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID, 2);
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, 2);
   SetIndexStyle(2, DRAW_ARROW, STYLE_SOLID, 2);
   SetIndexStyle(3, DRAW_ARROW, STYLE_SOLID, 2);
   SetIndexArrow(1, 333);
   SetIndexArrow(0, 334);
   SetIndexArrow(1, 233);
   SetIndexArrow(0, 234);
   SetIndexBuffer(0, G_ibuf_84);
   SetIndexBuffer(1, G_ibuf_88);
   SetIndexBuffer(2, G_ibuf_92);
   SetIndexBuffer(3, G_ibuf_96);
   return (0);
}

int start() {
   int highest_20;
   int lowest_24;
   int highest_28;
   int lowest_32;
   int Li_0 = IndicatorCounted();
   if (Li_0 < 0) return (-1);
   if (Li_0 > 0) Li_0--;
   int Li_16 = Bars - 1;
   if (Li_0 >= 1) Li_16 = Bars - Li_0 - 1;
   if (Li_16 < 0) Li_16 = 0;
   for (int Li_8 = Li_16; Li_8 >= 0; Li_8--) {
      highest_28 = iHighest(NULL, 0, MODE_HIGH, dist1, Li_8 - dist1 / 2);
      lowest_32 = iLowest(NULL, 0, MODE_LOW, dist1, Li_8 - dist1 / 2);
      highest_20 = iHighest(NULL, 0, MODE_HIGH, dist2, Li_8 - dist2 / 2);
      lowest_24 = iLowest(NULL, 0, MODE_LOW, dist2, Li_8 - dist2 / 2);
      if (Li_8 == highest_20) G_ibuf_84[Li_8] = High[highest_20] + 10.0 * Point;
      if (Li_8 == lowest_24) G_ibuf_88[Li_8] = Low[lowest_24] - 10.0 * Point;
      if (Li_8 == highest_28) G_ibuf_92[Li_8] = High[highest_28] + 4.0 * Point;
      if (Li_8 == lowest_32) G_ibuf_96[Li_8] = Low[lowest_32] - 4.0 * Point;
   }
   return (0);
}
