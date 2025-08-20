#property copyright "wall.street.binary@gmail.com"
#property link      "secrets.wall.streer@gmail.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Lime

extern int Risk = 3;
extern double ArrowsGap = 1.0;
double G_ibuf_88[];
double G_ibuf_92[];
double G_ibuf_96[];

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   IndicatorBuffers(3);
   SetIndexBuffer(0, G_ibuf_88);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 234);
   SetIndexBuffer(1, G_ibuf_92);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 233);
   SetIndexBuffer(2, G_ibuf_96);
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   int period_28;
   double Ld_32;
   bool Li_44;
   bool Li_48;
   int Li_0 = IndicatorCounted();
   if (Li_0 < 0) return (-1);
   if (Li_0 > 0) Li_0--;
   int Li_4 = MathMin(Bars - Li_0, Bars - 1);
   double Ld_8 = Risk + 67.0;
   double Ld_16 = 33.0 - Risk;
   for (int Li_24 = Li_4; Li_24 >= 0; Li_24--) {
      period_28 = Risk * 2 + 3;
      Ld_32 = 0;
      for (int count_40 = 0; count_40 < 10; count_40++) Ld_32 += High[Li_24 + count_40] - (Low[Li_24 + count_40]);
      Ld_32 /= 10.0;
      Li_44 = FALSE;
      for (count_40 = 0; count_40 < 6 && !Li_44; count_40++) Li_44 = MathAbs(Open[Li_24 + count_40] - (Close[Li_24 + count_40 + 1])) >= 2.0 * Ld_32;
      Li_48 = FALSE;
      for (count_40 = 0; count_40 < 9 && !Li_48; count_40++) Li_48 = MathAbs(Close[Li_24 + count_40 + 3] - (Close[Li_24 + count_40])) >= 4.6 * Ld_32;
      if (Li_44) period_28 = 3;
      if (Li_48) period_28 = 4;
      G_ibuf_96[Li_24] = iWPR(NULL, 0, period_28, Li_24) + 100.0;
      G_ibuf_88[Li_24] = EMPTY_VALUE;
      G_ibuf_92[Li_24] = EMPTY_VALUE;
      if (G_ibuf_96[Li_24] < Ld_16) {
         for (count_40 = 1; Li_24 + count_40 < Bars && G_ibuf_96[Li_24 + count_40] >= Ld_16 && G_ibuf_96[Li_24 + count_40] <= Ld_8; count_40++) {
         }
         if (G_ibuf_96[Li_24 + count_40] > Ld_8) G_ibuf_88[Li_24] = High[Li_24] + Ld_32 * ArrowsGap;
      }
      if (G_ibuf_96[Li_24] > Ld_8) {
         for (count_40 = 1; Li_24 + count_40 < Bars && G_ibuf_96[Li_24 + count_40] >= Ld_16 && G_ibuf_96[Li_24 + count_40] <= Ld_8; count_40++) {
         }
         if (G_ibuf_96[Li_24 + count_40] < Ld_16) G_ibuf_92[Li_24] = Low[Li_24] - Ld_32 * ArrowsGap;
      }
   }
   return (0);
}
