
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

int Gi_76 = 0;
int Gi_80 = 30;
double Gd_84 = 9.0;
int Gi_92;
int Gi_96;
int Gi_100;
int Gi_104;
double Gd_108;
double G_high_116;
double G_low_124;
double G_ibuf_132[];
double G_ibuf_136[];

int init() {
   if (Bars < Gi_76 + Gd_84 || Gi_76 == 0) Gi_96 = Bars - Gd_84;
   else Gi_96 = Gi_76;
   IndicatorBuffers(2);
   IndicatorShortName("Entry Signal");
   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID, 1);
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, 1);
   SetIndexArrow(0, 159);
   SetIndexArrow(1, 159);
   SetIndexBuffer(0, G_ibuf_136);
   SetIndexBuffer(1, G_ibuf_132);
   SetIndexDrawBegin(0, Bars - Gi_96);
   SetIndexDrawBegin(1, Bars - Gi_96);
   ArrayInitialize(G_ibuf_132, 0.0);
   ArrayInitialize(G_ibuf_136, 0.0);
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   int ind_counted_0 = IndicatorCounted();
   if (ind_counted_0 < 0) return (-1);
   if (Gi_96 > Bars - ind_counted_0) Gi_96 = Bars - ind_counted_0;
   for (Gi_92 = 1; Gi_92 < Gi_96; Gi_92++) {
      Gd_108 = 0;
      for (Gi_100 = Gi_92; Gi_100 < Gi_92 + 10; Gi_100++) Gd_108 += (Gi_92 + 10 - Gi_100) * (High[Gi_100] - Low[Gi_100]);
      Gd_108 /= 55.0;
      G_high_116 = High[iHighest(NULL, 0, MODE_HIGH, Gd_84, Gi_92)];
      G_low_124 = Low[iLowest(NULL, 0, MODE_LOW, Gd_84, Gi_92)];
      if (Close[Gi_92] < G_low_124 + (G_high_116 - G_low_124) * Gi_80 / 100.0 && Gi_104 != -1) {
         G_ibuf_136[Gi_92] = Low[Gi_92] - Gd_108 / 2.0;
         Gi_104 = -1;
      }
      if (Close[Gi_92] > G_high_116 - (G_high_116 - G_low_124) * Gi_80 / 100.0 && Gi_104 != 1) {
         G_ibuf_132[Gi_92] = High[Gi_92] + Gd_108 / 2.0;
         Gi_104 = 1;
      }
   }
   return (0);
}
