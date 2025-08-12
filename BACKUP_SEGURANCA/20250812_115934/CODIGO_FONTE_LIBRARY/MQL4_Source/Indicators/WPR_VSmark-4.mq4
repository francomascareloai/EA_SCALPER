#property copyright "Copyright © 2005, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net/"

#property indicator_separate_window
#property indicator_minimum -100.0
#property indicator_maximum 0.0
#property indicator_levelcolor Black
#property indicator_levelstyle 0
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 Aqua
#property indicator_color3 Blue
#property indicator_color4 Black
#property indicator_color5 Blue
#property indicator_width1 1
#property indicator_level1 -20.0
#property indicator_width2 2
#property indicator_level2 -80.0

extern int ExtWPRPeriod1 = 21;
extern int ExtWPRPeriod2 = 55;
extern int ExtWPRPeriod3 = 77;
extern int ExtWPRPeriod4 = 277;
extern int ExtWPRPeriod5 = 50;
double GL_ibuf_96[];
double GL_ibuf_100[];
double GL_ibuf_104[];
double GL_ibuf_108[];
double GL_ibuf_112[];

int init() {
   SetIndexBuffer(0, GL_ibuf_96);
   SetIndexBuffer(1, GL_ibuf_100);
   SetIndexBuffer(2, GL_ibuf_104);
   SetIndexBuffer(3, GL_ibuf_108);
   SetIndexBuffer(4, GL_ibuf_112);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexStyle(3, DRAW_LINE);
   SetIndexStyle(4, DRAW_LINE);
   string LCs_0 = "WPR_VSmark";
   IndicatorShortName(LCs_0);
   SetIndexLabel(0, NULL);
   SetIndexLabel(1, ExtWPRPeriod2);
   SetIndexLabel(2, NULL);
   SetIndexLabel(3, NULL);
   SetIndexLabel(4, NULL);
   SetIndexDrawBegin(0, ExtWPRPeriod1);
   SetIndexDrawBegin(0, ExtWPRPeriod2);
   SetIndexDrawBegin(0, ExtWPRPeriod3);
   SetIndexDrawBegin(0, ExtWPRPeriod4);
   SetIndexDrawBegin(0, ExtWPRPeriod5);
   return (0);
}

int start() {
   double high_28;
   double low_36;
   if (Bars <= ExtWPRPeriod4) return (0);
   int ind_counted_24 = IndicatorCounted();
   int LCi_0 = Bars - ExtWPRPeriod1 - 1;
   if (ind_counted_24 > ExtWPRPeriod1) LCi_0 = Bars - ind_counted_24 - 1;
   while (LCi_0 >= 0) {
      high_28 = High[iHighest(NULL, 0, MODE_HIGH, ExtWPRPeriod1, LCi_0)];
      low_36 = Low[iLowest(NULL, 0, MODE_LOW, ExtWPRPeriod1, LCi_0)];
      if (!CompareDouble(high_28 - low_36, 0.0)) GL_ibuf_96[LCi_0] = (high_28 - Close[LCi_0]) / (-0.01) / (high_28 - low_36);
      LCi_0--;
   }
   int LCi_4 = Bars - ExtWPRPeriod2 - 1;
   if (ind_counted_24 > ExtWPRPeriod2) LCi_4 = Bars - ind_counted_24 - 1;
   while (LCi_4 >= 0) {
      high_28 = High[iHighest(NULL, 0, MODE_HIGH, ExtWPRPeriod2, LCi_4)];
      low_36 = Low[iLowest(NULL, 0, MODE_LOW, ExtWPRPeriod2, LCi_4)];
      if (!CompareDouble(high_28 - low_36, 0.0)) GL_ibuf_100[LCi_4] = (high_28 - Close[LCi_4]) / (-0.01) / (high_28 - low_36);
      LCi_4--;
   }
   int LCi_8 = Bars - ExtWPRPeriod3 - 1;
   if (ind_counted_24 > ExtWPRPeriod3) LCi_8 = Bars - ind_counted_24 - 1;
   while (LCi_8 >= 0) {
      high_28 = High[iHighest(NULL, 0, MODE_HIGH, ExtWPRPeriod3, LCi_8)];
      low_36 = Low[iLowest(NULL, 0, MODE_LOW, ExtWPRPeriod3, LCi_8)];
      if (!CompareDouble(high_28 - low_36, 0.0)) GL_ibuf_104[LCi_8] = (high_28 - Close[LCi_8]) / (-0.01) / (high_28 - low_36);
      LCi_8--;
   }
   int LCi_12 = Bars - ExtWPRPeriod4 - 1;
   if (ind_counted_24 > ExtWPRPeriod4) LCi_12 = Bars - ind_counted_24 - 1;
   while (LCi_12 >= 0) {
      high_28 = High[iHighest(NULL, 0, MODE_HIGH, ExtWPRPeriod4, LCi_12)];
      low_36 = Low[iLowest(NULL, 0, MODE_LOW, ExtWPRPeriod4, LCi_12)];
      if (!CompareDouble(high_28 - low_36, 0.0)) GL_ibuf_108[LCi_12] = (high_28 - Close[LCi_12]) / (-0.01) / (high_28 - low_36);
      LCi_12--;
   }
   int LCi_16 = Bars - ExtWPRPeriod5 - 1;
   if (ind_counted_24 > ExtWPRPeriod5) LCi_16 = Bars - ind_counted_24 - 1;
   while (LCi_16 >= 0) {
      high_28 = High[iHighest(NULL, 0, MODE_HIGH, ExtWPRPeriod5, LCi_16)];
      low_36 = Low[iLowest(NULL, 0, MODE_LOW, ExtWPRPeriod5, LCi_16)];
      if (!CompareDouble(high_28 - low_36, 0.0)) GL_ibuf_112[LCi_16] = -50;
      LCi_16--;
   }
   return (0);
}

bool CompareDouble(double ARd_0, double ARd_8) {
   bool bool_16 = NormalizeDouble(ARd_0 - ARd_8, 8) == 0.0;
   return (bool_16);
}