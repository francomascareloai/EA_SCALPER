#property copyright "60SecondTrades.com"
#property link      ""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red

extern int ADXbars = 4;
extern int CountBars = 5000;
extern bool AlertOn = false,
            EmailOn = false,
            AlertOnClosedCandle = false;
double G_ibuf_84[];
double G_ibuf_88[];
double G_iadx_92;
double G_iadx_100;
double G_iadx_108;
double G_iadx_116;
int SignalCandle = 0;
datetime Alerted=0;

int init() {
   IndicatorBuffers(2);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 108);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 108);
   SetIndexBuffer(0, G_ibuf_84);
   SetIndexBuffer(1, G_ibuf_88);
   if (AlertOnClosedCandle) SignalCandle=1;
   return (0);
}

int start() {
   if (CountBars >= Bars) CountBars = Bars;
   SetIndexDrawBegin(0, Bars - CountBars);
   SetIndexDrawBegin(1, Bars - CountBars);
   int ind_counted_8 = IndicatorCounted();
   if (ind_counted_8 < 0) return (-1);
   if (ind_counted_8 < 1) {
      for (int Li_0 = 1; Li_0 <= CountBars; Li_0++) G_ibuf_84[CountBars - Li_0] = 0.0;
      for (Li_0 = 1; Li_0 <= CountBars; Li_0++) G_ibuf_88[CountBars - Li_0] = 0.0;
   }
   for (int Li_4 = CountBars; Li_4 >= 0; Li_4--) {
      G_iadx_92 = iADX(NULL, 0, ADXbars, PRICE_CLOSE, MODE_PLUSDI, Li_4 - 1);
      G_iadx_100 = iADX(NULL, 0, ADXbars, PRICE_CLOSE, MODE_PLUSDI, Li_4);
      G_iadx_108 = iADX(NULL, 0, ADXbars, PRICE_CLOSE, MODE_MINUSDI, Li_4 - 1);
      G_iadx_116 = iADX(NULL, 0, ADXbars, PRICE_CLOSE, MODE_MINUSDI, Li_4);
      if (G_iadx_92 > G_iadx_108 && G_iadx_100 < G_iadx_116) G_ibuf_84[Li_4] = Low[Li_4] - 5.0 * Point;
      if (G_iadx_92 < G_iadx_108 && G_iadx_100 > G_iadx_116) G_ibuf_88[Li_4] = High[Li_4] + 5.0 * Point;
   }
   if (G_ibuf_84[SignalCandle]!=EMPTY_VALUE && G_ibuf_84[SignalCandle]>0 && Alerted!=Time[0]) {
      if (AlertOn) Alert ("SixtySecondTrades Buy Alert on "+Symbol()+"["+Period()+"m]");
      if (EmailOn) SendMail ("SixtySecondTrades Buy Alert!","SixtySecondTrades Buy Alert on "+Symbol()+"["+Period()+"m]");
      Alerted=Time[0];
      }
   if (G_ibuf_88[SignalCandle]!=EMPTY_VALUE && G_ibuf_88[SignalCandle]>0 && Alerted!=Time[0]) {
      if (AlertOn) Alert ("SixtySecondTrades Sell Alert on "+Symbol()+"["+Period()+"m]");
      if (EmailOn) SendMail ("SixtySecondTrades Sell Alert!","SixtySecondTrades Sell Alert on "+Symbol()+"["+Period()+"m]");
      Alerted=Time[0];
      }
   return (0);
}
