/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website:  htT p: / /w W W. M e T aQuot E S.N e t
   E-mail : su Pp O Rt @ Me TaQU OT eS. n Et
*/
#property copyright "IndicatorForex.com"
#property link      "IndicatorForex.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Green

extern int IPeriod = 20;
double Gda_80[];
double Gda_84[];
double Gda_88[];

int init() {
   if (ObjectType("lbl") != 23) ObjectDelete("lbl");
   if (ObjectFind("lbl") == -1) ObjectCreate("lbl", OBJ_LABEL, 0, Time[5], Close[5]);
   ObjectSetText("lbl", "Donchian Bands, IndicatorForex.com");
   ObjectSet("lbl", OBJPROP_XDISTANCE, 20);
   ObjectSet("lbl", OBJPROP_YDISTANCE, 20);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, Gda_80);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, Gda_84);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, Gda_88);
   return (0);
}

int deinit() {
   ObjectDelete("lbl");
   return (0);
}

int start() {
   if (ObjectType("lbl") != 23) ObjectDelete("lbl");
   if (ObjectFind("lbl") == -1) ObjectCreate("lbl", OBJ_LABEL, 0, Time[5], Close[5]);
   ObjectSetText("lbl", "Donchian Bands, IndicatorForex.com");
   ObjectSet("lbl", OBJPROP_XDISTANCE, 20);
   ObjectSet("lbl", OBJPROP_YDISTANCE, 20);
   for (int Li_0 = 0; Li_0 < Bars; Li_0++) {
      Gda_80[Li_0] = High[iHighest(Symbol(), 0, MODE_HIGH, IPeriod, Li_0 + 1)];
      Gda_84[Li_0] = Low[iLowest(Symbol(), 0, MODE_LOW, IPeriod, Li_0 + 1)];
      Gda_88[Li_0] = (Gda_80[Li_0] + Gda_84[Li_0]) / 2.0;
   }
   return (0);
}
