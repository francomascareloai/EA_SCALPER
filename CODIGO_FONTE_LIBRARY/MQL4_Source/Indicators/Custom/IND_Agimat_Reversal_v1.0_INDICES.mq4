

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 DarkGray
#property indicator_color2 DarkGray

extern int ExtDepth = 60;
extern int ExtDeviation = 5;
extern int ExtBackstep = 3;
double G_ibuf_88[];
double G_ibuf_92[];

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   IndicatorBuffers(2);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 233);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 234);
   SetIndexBuffer(0, G_ibuf_88);
   SetIndexBuffer(1, G_ibuf_92);
   SetIndexEmptyValue(0, 0.0);
   IndicatorShortName("ZigZag(" + ExtDepth + "," + ExtDeviation + "," + ExtBackstep + ")");
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   double Ld_16;
   double Ld_24;
   double Ld_32;
   double Ld_40;
   double Ld_48;
   double Ld_56;
   for (int Li_0 = Bars - ExtDepth; Li_0 >= 0; Li_0--) {
      Ld_16 = Low[iLowest(NULL, 0, MODE_LOW, ExtDepth, Li_0)];
      if (Ld_16 == Ld_56) Ld_16 = 0.0;
      else {
         Ld_56 = Ld_16;
         if (Low[Li_0] - Ld_16 > ExtDeviation * Point) Ld_16 = 0.0;
         else {
            for (int Li_4 = 1; Li_4 <= ExtBackstep; Li_4++) {
               Ld_24 = G_ibuf_88[Li_0 + Li_4];
               if (Ld_24 != 0.0 && Ld_24 > Ld_16) G_ibuf_88[Li_0 + Li_4] = 0.0;
            }
         }
      }
      G_ibuf_88[Li_0] = Ld_16;
      Ld_16 = High[iHighest(NULL, 0, MODE_HIGH, ExtDepth, Li_0)];
      if (Ld_16 == Ld_48) Ld_16 = 0.0;
      else {
         Ld_48 = Ld_16;
         if (Ld_16 - High[Li_0] > ExtDeviation * Point) Ld_16 = 0.0;
         else {
            for (Li_4 = 1; Li_4 <= ExtBackstep; Li_4++) {
               Ld_24 = G_ibuf_92[Li_0 + Li_4];
               if (Ld_24 != 0.0 && Ld_24 < Ld_16) G_ibuf_92[Li_0 + Li_4] = 0.0;
            }
         }
      }
      G_ibuf_92[Li_0] = Ld_16;
   }
   Ld_48 = -1;
   int Li_8 = -1;
   Ld_56 = -1;
   int Li_12 = -1;
   for (Li_0 = Bars - ExtDepth; Li_0 >= 0; Li_0--) {
      Ld_32 = G_ibuf_88[Li_0];
      Ld_40 = G_ibuf_92[Li_0];
      if (Ld_32 == 0.0 && Ld_40 == 0.0) continue;
      if (Ld_40 != 0.0) {
         if (Ld_48 > 0.0) {
            if (Ld_48 < Ld_40) G_ibuf_92[Li_8] = 0;
            else G_ibuf_92[Li_0] = 0;
         }
         if (Ld_48 < Ld_40 || Ld_48 < 0.0) {
            Ld_48 = Ld_40;
            Li_8 = Li_0;
         }
         Ld_56 = -1;
      }
      if (Ld_32 != 0.0) {
         if (Ld_56 > 0.0) {
            if (Ld_56 > Ld_32) G_ibuf_88[Li_12] = 0;
            else G_ibuf_88[Li_0] = 0;
         }
         if (Ld_32 < Ld_56 || Ld_56 < 0.0) {
            Ld_56 = Ld_32;
            Li_12 = Li_0;
         }
         Ld_48 = -1;
      }
   }
   for (Li_0 = Bars - 1; Li_0 >= 0; Li_0--) {
      if (Li_0 >= Bars - ExtDepth) G_ibuf_88[Li_0] = 0.0;
      else {
         Ld_24 = G_ibuf_92[Li_0];
         if (Ld_24 != 0.0) G_ibuf_92[Li_0] = Ld_24;
      }
   }
   return (0);
}
