
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Black
#property indicator_color2 Blue
#property indicator_color3 Red

double G_ibuf_76[];
double G_ibuf_80[];
double G_ibuf_84[];
int Gia_88[9] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};
int Gia_92[9] = {5, 30, 60, 240, 240, 1440, 10080, 43200, 43200};
int G_timeframe_96;

int init() {
   IndicatorBuffers(7);
   SetIndexStyle(0, DRAW_NONE);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexStyle(2, DRAW_HISTOGRAM);
   SetIndexBuffer(0, G_ibuf_76);
   SetIndexBuffer(1, G_ibuf_80);
   SetIndexBuffer(2, G_ibuf_84);
   SetIndexLabel(1, "UP");
   SetIndexLabel(2, "DOWN");
   IndicatorShortName("FSP HTF Trend");
   IndicatorDigits(Digits + 1);
   for (int index_0 = 0; index_0 < 8; index_0++) {
      if (Period() == Gia_88[index_0]) {
         G_timeframe_96 = Gia_92[index_0];
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
      G_ibuf_80[index_8] = EMPTY_VALUE;
      G_ibuf_84[index_8] = EMPTY_VALUE;
      icustom_12 = iCustom(Symbol(), G_timeframe_96, "FSP Fast Entry", 1, iBarShift(Symbol(), G_timeframe_96, Time[index_8]));
      icustom_20 = iCustom(Symbol(), G_timeframe_96, "FSP Fast Entry", 2, iBarShift(Symbol(), G_timeframe_96, Time[index_8]));
      if (icustom_12 == 1.0) {
         G_ibuf_80[index_8] = 1;
         G_ibuf_84[index_8] = 0.0;
      } else {
         if (icustom_20 == 1.0) {
            G_ibuf_84[index_8] = 1;
            G_ibuf_80[index_8] = 0.0;
         }
      }
   }
   return (0);
}
