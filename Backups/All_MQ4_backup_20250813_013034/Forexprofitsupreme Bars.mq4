
#property copyright "Copyright 2013 © Forexprofitsupreme"
#property link      "www.Forexprofitsupreme.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Red

extern int RSI_Period = 21;
extern int RSI_Price = 0;
extern int Overbought = 50;
extern int Oversold = 50;
extern int BarWidth = 1;
extern int CandleWidth = 3;
double g_ibuf_100[];
double g_ibuf_104[];
double g_ibuf_108[];
double g_ibuf_112[];

int init() {
   IndicatorShortName("RSI Candles:(" + RSI_Period + ")");
   IndicatorBuffers(4);
   SetIndexBuffer(0, g_ibuf_100);
   SetIndexBuffer(1, g_ibuf_104);
   SetIndexBuffer(2, g_ibuf_108);
   SetIndexBuffer(3, g_ibuf_112);
   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, BarWidth);
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, BarWidth);
   SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID, CandleWidth);
   SetIndexStyle(3, DRAW_HISTOGRAM, STYLE_SOLID, CandleWidth);
   return (0);
}

double f0_1(int ai_0 = 0) {
   return (iRSI(NULL, 0, RSI_Period, RSI_Price, ai_0));
}

void f0_0(int ai_0, int ai_4) {
   double ld_24 = MathMax(Open[ai_4], Close[ai_4]);
   double ld_32 = MathMin(Open[ai_4], Close[ai_4]);
   double high_8 = High[ai_4];
   double low_16 = Low[ai_4];
   g_ibuf_100[ai_4] = low_16;
   g_ibuf_108[ai_4] = ld_32;
   g_ibuf_104[ai_4] = low_16;
   g_ibuf_112[ai_4] = ld_32;
   switch (ai_0) {
   case 1:
      g_ibuf_100[ai_4] = high_8;
      g_ibuf_108[ai_4] = ld_24;
      return;
   case 2:
      g_ibuf_104[ai_4] = high_8;
      g_ibuf_112[ai_4] = ld_24;
      return;
      return;
   }
}

int start() {
   double ld_4;
   for (int li_0 = MathMax(Bars - 1 - IndicatorCounted(), 1); li_0 >= 0; li_0--) {
      ld_4 = f0_1(li_0);
      if (ld_4 > Overbought) f0_0(1, li_0);
      else
         if (ld_4 < Oversold) f0_0(2, li_0);
   }
   return (0);
}