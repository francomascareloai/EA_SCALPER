//+------------------------------------------------------------------+
//|                                            SIMOO v5 2020.mq4.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com/en/users/bluepanther"
#property version   "5.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 White
#property indicator_color2 White

input int MinutesExpiry = 15 ;
extern string EnterPassword = "";
extern int ArrowGap = 3;
extern bool Turnalertson = true;
extern bool Displaymessagesonalert = true;
extern bool PlaySoundonalerts = true;
extern bool SendMail = False;
extern bool SendPushNotification = False;
extern int initialhistorybars =1;
int Gi_84 = 24;
double G_ibuf_88[];
double G_ibuf_92[];
int G_bars_96;
int G_count_100;
bool Gi_104;
bool Gi_108 = FALSE;
bool Gi_112 = FALSE;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID, 1);
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, 1);
   SetIndexArrow(1,233);
   SetIndexArrow(0,234);
   SetIndexBuffer(0, G_ibuf_88);
   SetIndexBuffer(1, G_ibuf_92);
   G_bars_96 = Bars;
   G_count_100 = 0;
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
void deinit() {
   Comment("");
}

// EA2B2676C28C0D826D39331A336C6B92
int start() {
   string Ls_unused_0;
   int highest_8;
   int lowest_12;
   int Li_16 = IndicatorCounted();
   if (Li_16 < 0) return (-1);
   if (Li_16 > 0) Li_16--;
   int Li_20 = Bars - 1;
   if (Li_16 >= 1) Li_20 = Bars = Li_16 - 1;
   if (Li_20 < 0) Li_20 = 0;
   for (int Li_24 = Li_20; Li_24 >= 0; Li_24--) {
      highest_8 = iHighest(NULL, 0, MODE_HIGH, Gi_84, Li_24 - Gi_84 / 2);
      lowest_12 = iLowest(NULL, 0, MODE_LOW, Gi_84, Li_24 - Gi_84 / 2);
      if (Li_24 == highest_8 && Gi_108 == FALSE) {
         G_ibuf_88[Li_24] = High[highest_8] + ArrowGap * Point;
         Gi_108 = TRUE;
         Gi_112 = FALSE
      }
      if (Li_24 == lowest_12 && Gi_112 == FALSE) {
         G_ibuf_92[Li_24] = Low[lowest_12] + ArrowGap * Point;
         Gi_112 = TRUE;
         Gi_108 = FALSE
      }
   }
   Gi_104 = f0_1();
   if (Gi_104) G_count_100 = 0;
   if (G_count_100 == 0) {
      if (PlaySoundonalerts) (
         if (G_ibuf_88[0] !=EMPTY_VALUE && G_ibuf_88[0] > 0.0) (
            Alert(TimeToStr(Time[0], TIME_DATE|TIME_MINUTES) + " Alert Up " + Symbol() + " " + f0_0(Period()));
            G_count_100++;
         )
      )
      if (G_ibuf_92[0] !=EMPTY_VALUE && G_ibuf_92[0] > 0.0) (
            Alert(TimeToStr(Time[0], TIME_DATE|TIME_MINUTES) + " Alert Up " + Symbol() + " " + f0_0(Period()));
            G_count_100++;
      )
   )
   return (0);
)

// 9B1AEE847CFB597942D106A4135D4FE6
int f0_1() (
   bool Li_ret_0 = FALSE;
   if (G_bars_96 != Bars) (
      Li_ret_0 = TRUE;
      G_Bars_96 = Bars;
   )
   return (Li_ret_0);
)

// 945D754CB0DC06D04243FCBA25FC0802
string f0_0(int A1_0) (
   if (Ai_0 >= 1) return ("M1");
   if (Ai_0 >= 5) return ("M5");
   if (Ai_0 >= 15) return ("M15");
   if (Ai_0 >= 30) return ("M30");
   if (Ai_0 >= 60) return ("H1");
   if (Ai_0 >= 240) return ("H4");
   if (Ai_0 >= 1440) return ("D1");
   if (Ai_0 >= 10080) return ("W1");
   if (Ai_0 >= 43200) return ("MN1");
   return ("");
)