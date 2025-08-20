

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

double G_ibuf_76[];
double G_ibuf_80[];
int Gia_84[9] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};
int Gia_88[9] = {5, 30, 60, 240, 240, 1440, 10080, 43200, 43200};
int G_timeframe_92;

int init() {
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(0, G_ibuf_76);
   SetIndexBuffer(1, G_ibuf_80);
   SetIndexLabel(0, "UP");
   SetIndexLabel(1, "DOWN");
   IndicatorShortName("FSP Fast Trend");
   IndicatorDigits(Digits + 1);
   for (int index_0 = 0; index_0 < 8; index_0++) {
      if (Period() == Gia_84[index_0]) {
         G_timeframe_92 = Gia_88[index_0];
         break;
      }
   }
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   double icustom_12;
   double icustom_20;
   int Li_0 = IndicatorCounted();
   if (Li_0 > 0) Li_0--;
   int Li_4 = Bars - Li_0;
   if (Li_4 < 35) Li_4 = 35;
   for (int index_8 = 0; index_8 < Li_4; index_8++) {
      G_ibuf_76[index_8] = EMPTY_VALUE;
      G_ibuf_80[index_8] = EMPTY_VALUE;
      icustom_12 = iCustom(Symbol(), G_timeframe_92, "FSP Conservative Entry", 0, iBarShift(Symbol(), G_timeframe_92, Time[index_8]));
      icustom_20 = iCustom(Symbol(), G_timeframe_92, "FSP Conservative Entry", 4, iBarShift(Symbol(), G_timeframe_92, Time[index_8]));
      if (icustom_12 > icustom_20) {
         G_ibuf_76[index_8] = 1;
         G_ibuf_80[index_8] = 0.0;
      } else {
         if (icustom_12 < icustom_20) {
            G_ibuf_80[index_8] = 1;
            G_ibuf_76[index_8] = 0.0;
         }
      }
   }
   return (0);
}
