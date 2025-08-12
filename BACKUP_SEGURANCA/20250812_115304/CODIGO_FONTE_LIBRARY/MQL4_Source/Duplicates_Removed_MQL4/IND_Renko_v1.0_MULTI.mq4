
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 SteelBlue
#property indicator_color2 Crimson

extern double BoxSize = 10.0;
double G_ibuf_84[];
double G_ibuf_88[];
double G_ibuf_92[];
double G_ibuf_96[];

int init() {
   IndicatorBuffers(4);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, G_ibuf_84);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(1, G_ibuf_88);
   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, G_ibuf_92);
   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, G_ibuf_96);
   SetIndexLabel(0, "Up");
   SetIndexLabel(1, "Dn");
   IndicatorDigits(Digits);
   Comment("Renko |" + BoxSize);
   return (0);
}

int deinit() {
   Comment("");
   return (0);
}

int start() {
   double Ld_0;
   double Ld_8;
   double Ld_24;
   double Ld_32;
   double pips_44;
   int Li_52 = IndicatorCounted();
   if (Li_52 < 0) return (-1);
   if (Li_52 > 0) Li_52--;
   G_ibuf_84[Bars] = Close[Bars];
   G_ibuf_88[Bars] = Close[Bars];
   G_ibuf_92[Bars] = Close[Bars];
   G_ibuf_96[Bars] = Close[Bars];
   if (Digits == 5 || Digits == 3) pips_44 = NormalizeDouble(10.0 * BoxSize, Digits);
   else pips_44 = NormalizeDouble(BoxSize, Digits);
   double Ld_16 = NormalizeDouble(Point * pips_44, Digits);
   int Li_40 = Bars - Li_52;
   for (int Li_56 = Li_40; Li_56 >= 0; Li_56--) {
      Ld_0 = NormalizeDouble(High[Li_56] - (G_ibuf_92[Li_56 + 1]) - Ld_16, Digits);
      Ld_8 = NormalizeDouble(Low[Li_56] - (G_ibuf_96[Li_56 + 1]) + Ld_16, Digits);
      if (Ld_0 >= 0.0) {
         Ld_32 = NormalizeDouble((High[Li_56] - (G_ibuf_92[Li_56 + 1])) / Ld_16, Digits);
         Ld_24 = NormalizeDouble(MathFloor(Ld_32), Digits);
         G_ibuf_92[Li_56] = G_ibuf_92[Li_56 + 1] + Ld_16 * Ld_24;
         G_ibuf_96[Li_56] = G_ibuf_92[Li_56] - Ld_16 * Ld_24;
         G_ibuf_84[Li_56] = G_ibuf_92[Li_56];
         G_ibuf_88[Li_56] = G_ibuf_96[Li_56];
         G_ibuf_96[Li_56] = G_ibuf_92[Li_56] - Ld_16;
      } else {
         if (Ld_8 <= 0.0) {
            Ld_32 = NormalizeDouble((G_ibuf_96[Li_56 + 1] - Low[Li_56]) / Ld_16, Digits);
            Ld_24 = NormalizeDouble(MathFloor(Ld_32), Digits);
            G_ibuf_96[Li_56] = G_ibuf_96[Li_56 + 1] - Ld_16 * Ld_24;
            G_ibuf_92[Li_56] = G_ibuf_96[Li_56] + Ld_16 * Ld_24;
            G_ibuf_88[Li_56] = G_ibuf_92[Li_56];
            G_ibuf_84[Li_56] = G_ibuf_96[Li_56];
            G_ibuf_92[Li_56] = G_ibuf_96[Li_56] + Ld_16;
         } else {
            G_ibuf_92[Li_56] = G_ibuf_92[Li_56 + 1];
            G_ibuf_96[Li_56] = G_ibuf_96[Li_56 + 1];
            if (G_ibuf_84[Li_56 + 1] > G_ibuf_88[Li_56 + 1]) {
               G_ibuf_84[Li_56] = G_ibuf_84[Li_56 + 1];
               G_ibuf_88[Li_56] = G_ibuf_84[Li_56] - Ld_16;
            }
            if (G_ibuf_88[Li_56 + 1] > G_ibuf_84[Li_56 + 1]) {
               G_ibuf_84[Li_56] = G_ibuf_84[Li_56 + 1];
               G_ibuf_88[Li_56] = G_ibuf_84[Li_56] + Ld_16;
            }
         }
      }
   }
   return (0);
}