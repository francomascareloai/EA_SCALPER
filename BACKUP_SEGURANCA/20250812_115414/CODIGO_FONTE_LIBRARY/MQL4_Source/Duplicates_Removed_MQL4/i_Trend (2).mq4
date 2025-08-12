#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 LimeGreen
#property indicator_color2 Red

extern int Bands_Mode_0_2 = 0;
extern int Power_Price_0_6 = 0;
extern int Price_Type_0_3 = 0;
extern int Bands_Period = 20;
extern int Bands_Deviation = 2;
extern int Power_Period = 13;
extern int CountBars = 20000;
double gda_104[];
double gda_108[];

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   IndicatorBuffers(2);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(0, gda_104);
   SetIndexBuffer(1, gda_108);
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   int li_8;
   double ld_16;
   double ld_24;
   SetIndexDrawBegin(0, Bars - CountBars + Bands_Period + 1);
   SetIndexDrawBegin(1, Bars - CountBars + Bands_Period + 1);
   int li_12 = IndicatorCounted();
   if (Bars <= Bands_Period) return (0);
   if (li_12 < Bands_Period) {
      for (int li_0 = 1; li_0 <= Bands_Period; li_0++) gda_104[Bars - li_0] = 0.0;
      for (li_0 = 1; li_0 <= Bands_Period; li_0++) gda_108[Bars - li_0] = 0.0;
   }
   li_0 = CountBars - Bands_Period - 1;
   if (Bands_Mode_0_2 == 1) li_8 = 1;
   if (Bands_Mode_0_2 == 2) li_8 = 2;
   if (Bands_Mode_0_2 == 0) li_8 = 0;
   if (Power_Price_0_6 == 1) ld_16 = 1;
   if (Power_Price_0_6 == 2) ld_16 = 2;
   if (Power_Price_0_6 == 3) ld_16 = 3;
   if (Power_Price_0_6 == 4) ld_16 = 4;
   if (Power_Price_0_6 == 5) ld_16 = 5;
   if (Power_Price_0_6 == 6) ld_16 = 6;
   if (Power_Price_0_6 == 6) ld_16 = 0;
   for (li_0 = CountBars - 1; li_0 >= 0; li_0--) {
      if (Price_Type_0_3 == 1) ld_24 = Open[li_0];
      if (Price_Type_0_3 == 2) ld_24 = High[li_0];
      if (Price_Type_0_3 == 3) ld_24 = Low[li_0];
      if (Price_Type_0_3 == 0) ld_24 = Close[li_0];
      gda_104[li_0] = ld_24 - iBands(NULL, 0, Bands_Period, Bands_Deviation, 0, li_8, ld_16, li_0);
      gda_108[li_0] = -(iBearsPower(NULL, 0, Power_Period, ld_16, li_0) + iBullsPower(NULL, 0, Power_Period, ld_16, li_0));
   }
   return (0);
}