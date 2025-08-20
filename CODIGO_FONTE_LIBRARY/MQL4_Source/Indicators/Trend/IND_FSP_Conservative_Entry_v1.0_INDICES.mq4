

#property indicator_separate_window
#property indicator_minimum -0.05
#property indicator_maximum 1.5
#property indicator_buffers 5
#property indicator_color1 Black
#property indicator_color2 Blue
#property indicator_color3 Red
#property indicator_color4 Black
#property indicator_color5 Black

double G_ibuf_76[];
double G_ibuf_80[];
double G_ibuf_84[];
double G_ibuf_88[];
double G_ibuf_92[];

int init() {
   SetIndexStyle(0, DRAW_NONE);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexStyle(2, DRAW_HISTOGRAM);
   SetIndexStyle(3, DRAW_NONE);
   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(0, G_ibuf_84);
   SetIndexBuffer(1, G_ibuf_76);
   SetIndexBuffer(2, G_ibuf_80);
   SetIndexBuffer(3, G_ibuf_88);
   SetIndexBuffer(4, G_ibuf_92);
   SetIndexLabel(1, "UP");
   SetIndexLabel(2, "DOWN");
   IndicatorShortName("FSP Conservative Entry");
   IndicatorDigits(Digits + 1);
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   double Ld_4;
   double Ld_52;
   int Li_0 = IndicatorCounted();
   double Ld_12 = 0;
   double Ld_20 = 0;
   double Ld_28 = 0;
   double low_36 = 0;
   double high_44 = 0;
   double Ld_60 = 0;
   double Ld_68 = 0;
   double Ld_76 = 0;
   double low_84 = 0;
   double high_92 = 0;
   if (Li_0 > 0) Li_0--;
   int Li_100 = Bars - Li_0;
   if (Li_100 < 35) Li_100 = 35;
   for (int Li_104 = 0; Li_104 < Li_100; Li_104++) {
      high_44 = High[iHighest(NULL, 0, MODE_HIGH, 84, Li_104)];
      low_36 = Low[iLowest(NULL, 0, MODE_LOW, 84, Li_104)];
      Ld_4 = (Close[Li_104] + High[Li_104] + Low[Li_104]) / 3.0;
      Ld_12 = 0.66 * ((Ld_4 - low_36) / (high_44 - low_36) - 0.5) + 0.67 * Ld_20;
      Ld_12 = MathMin(MathMax(Ld_12, -0.999), 0.999);
      G_ibuf_84[Li_104] = MathLog((Ld_12 + 1.0) / (1 - Ld_12)) / 2.0 + Ld_28 / 2.0;
      Ld_20 = Ld_12;
      Ld_28 = G_ibuf_84[Li_104];
   }
   for (Li_104 = 0; Li_104 < Li_100 - 2; Li_104++) G_ibuf_92[Li_104] = iMAOnArray(G_ibuf_84, 0, 20, 5, MODE_SMA, Li_104);
   for (Li_104 = 0; Li_104 < Li_100; Li_104++) {
      high_92 = High[iHighest(NULL, 0, MODE_HIGH, 14, Li_104)];
      low_84 = Low[iLowest(NULL, 0, MODE_LOW, 14, Li_104)];
      Ld_52 = (Close[Li_104] + High[Li_104] + Low[Li_104]) / 3.0;
      Ld_60 = 0.66 * ((Ld_52 - low_84) / (high_92 - low_84) - 0.5) + 0.67 * Ld_68;
      Ld_60 = MathMin(MathMax(Ld_60, -0.999), 0.999);
      G_ibuf_88[Li_104] = MathLog((Ld_60 + 1.0) / (1 - Ld_60)) / 2.0 + Ld_76 / 2.0;
      Ld_68 = Ld_60;
      Ld_76 = G_ibuf_88[Li_104];
   }
   for (Li_104 = 0; Li_104 < Li_100; Li_104++) {
      G_ibuf_76[Li_104] = EMPTY_VALUE;
      G_ibuf_80[Li_104] = EMPTY_VALUE;
      if (G_ibuf_88[Li_104] > 0.0 && G_ibuf_84[Li_104] > 0.0 && G_ibuf_84[Li_104] > G_ibuf_92[Li_104]) {
         G_ibuf_76[Li_104] = 1;
         G_ibuf_80[Li_104] = 0.0;
      }
      if (G_ibuf_88[Li_104] < 0.0 && G_ibuf_84[Li_104] < 0.0 && G_ibuf_84[Li_104] < G_ibuf_92[Li_104]) {
         G_ibuf_80[Li_104] = 1;
         G_ibuf_76[Li_104] = 0.0;
      }
   }
   return (0);
}
