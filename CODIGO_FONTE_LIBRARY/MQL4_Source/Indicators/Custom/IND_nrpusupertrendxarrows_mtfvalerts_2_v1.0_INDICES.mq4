
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

extern string TimeFrame = "Current time frame";
extern int Nbr_Periods = 10;
extern double Multiplier = 1.7;
extern bool alertsOn = FALSE;
extern bool alertsOnCurrent = FALSE;
extern bool alertsMessage = TRUE;
extern bool alertsNotification = TRUE;
extern bool alertsSound = FALSE;
extern bool alertsEmail = FALSE;
extern int arrowthickness = 1;
extern int linethickness = 2;
double G_ibuf_128[];
double G_ibuf_132[];
double G_ibuf_136[];
double G_ibuf_140[];
double G_ibuf_144[];
string Gs_148;
bool G_bool_156;
bool G_bool_160;
int G_timeframe_164;
string Gs_nothing_168 = "nothing";
datetime G_time_176;
string Gsa_180[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN"};
int Gia_184[] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   IndicatorBuffers(5);
   SetIndexBuffer(0, G_ibuf_128);
   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID, arrowthickness);
   SetIndexArrow(0, 233);
   SetIndexBuffer(1, G_ibuf_132);
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, arrowthickness);
   SetIndexArrow(1, 234);
   SetIndexBuffer(2, G_ibuf_136);
   SetIndexBuffer(3, G_ibuf_140);
   SetIndexBuffer(4, G_ibuf_144);
   Gs_148 = WindowExpertName();
   G_bool_160 = TimeFrame == "calculateValue";
   if (G_bool_160) return (0);
   G_bool_156 = TimeFrame == "returnBars";
   if (G_bool_156) return (0);
   G_timeframe_164 = f0_3(TimeFrame);
   IndicatorShortName(f0_1(G_timeframe_164) + " SuperTrend");
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   double iatr_12;
   double Ld_20;
   double ima_28;
   int shift_36;
   int Li_0 = IndicatorCounted();
   if (Li_0 < 0) return (-1);
   if (Li_0 > 0) Li_0--;
   int Li_4 = MathMin(Bars - Li_0, Bars - 1);
   if (G_bool_156) {
      G_ibuf_128[0] = Li_4 + 1;
      return (0);
   }
   if (G_bool_160 || G_timeframe_164 == Period()) {
      for (int Li_8 = Li_4; Li_8 >= 0; Li_8--) {
         iatr_12 = iATR(NULL, 0, Nbr_Periods, Li_8);
         Ld_20 = Close[Li_8];
         ima_28 = iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_MEDIAN, Li_8);
         G_ibuf_136[Li_8] = ima_28 + Multiplier * iatr_12;
         G_ibuf_140[Li_8] = ima_28 - Multiplier * iatr_12;
         G_ibuf_144[Li_8] = G_ibuf_144[Li_8 + 1];
         if (Ld_20 > G_ibuf_136[Li_8 + 1]) G_ibuf_144[Li_8] = 1;
         if (Ld_20 < G_ibuf_140[Li_8 + 1]) G_ibuf_144[Li_8] = -1;
         if (G_ibuf_144[Li_8] > 0.0) G_ibuf_140[Li_8] = MathMax(G_ibuf_140[Li_8], G_ibuf_140[Li_8 + 1]);
         else G_ibuf_136[Li_8] = MathMin(G_ibuf_136[Li_8], G_ibuf_136[Li_8 + 1]);
         G_ibuf_128[Li_8] = EMPTY_VALUE;
         G_ibuf_132[Li_8] = EMPTY_VALUE;
         if (G_ibuf_144[Li_8] != G_ibuf_144[Li_8 + 1]) {
            if (G_ibuf_144[Li_8] == 1.0) {
               G_ibuf_128[Li_8] = Low[Li_8] - iATR(NULL, 0, 20, Li_8) / 2.0;
               continue;
            }
            G_ibuf_132[Li_8] = High[Li_8] + iATR(NULL, 0, 20, Li_8) / 2.0;
         }
      }
      f0_2();
      return (0);
   }
   Li_4 = MathMax(Li_4, MathMin(Bars - 1, iCustom(NULL, G_timeframe_164, Gs_148, "returnBars", 0, 0) * G_timeframe_164 / Period()));
   for (Li_8 = Li_4; Li_8 >= 0; Li_8--) {
      shift_36 = iBarShift(NULL, G_timeframe_164, Time[Li_8]);
      G_ibuf_144[Li_8] = iCustom(NULL, G_timeframe_164, Gs_148, "calculateValue", Nbr_Periods, Multiplier, alertsOn, alertsOnCurrent, alertsMessage, alertsNotification,
         alertsSound, alertsEmail, 4, shift_36);
      G_ibuf_128[Li_8] = EMPTY_VALUE;
      G_ibuf_132[Li_8] = EMPTY_VALUE;
      if (G_ibuf_144[Li_8] != G_ibuf_144[Li_8 + 1]) {
         if (G_ibuf_144[Li_8] == 1.0) {
            G_ibuf_128[Li_8] = Low[Li_8] - iATR(NULL, 0, 20, Li_8) / 2.0;
            continue;
         }
         G_ibuf_132[Li_8] = High[Li_8] + iATR(NULL, 0, 20, Li_8) / 2.0;
      }
   }
   return (0);
}

// 304CD8F881C2EC9D8467D17452E084AC
void f0_2() {
   int Li_0;
   if (alertsOn) {
      Li_0 = 1;
      if (alertsOnCurrent) Li_0 = 0;
      if (G_ibuf_144[Li_0] != G_ibuf_144[Li_0 + 1]) {
         if (G_ibuf_144[Li_0] == 1.0) f0_4("up");
         if (G_ibuf_144[Li_0] == -1.0) f0_4("down");
      }
   }
}

// DA717D55A7C333716E8D000540764674
void f0_4(string As_0) {
   string Ls_8;
   if (Gs_nothing_168 != As_0 || G_time_176 != Time[0]) {
      Gs_nothing_168 = As_0;
      G_time_176 = Time[0];
      Ls_8 = f0_1(Period()) + " " + Symbol() + " at " + TimeToStr(TimeLocal(), TIME_SECONDS) + " super trend changed to " + As_0;
      if (alertsMessage) Alert(Ls_8);
      if (alertsEmail) SendMail(Symbol() + " super trend", Ls_8);
      if (alertsNotification) SendNotification(Ls_8);
      if (alertsSound) PlaySound("alert2.wav");
   }
}

// B9EDCDEA151586E355292E7EA9BE516E
int f0_3(string As_0) {
   As_0 = f0_0(As_0);
   for (int Li_8 = ArraySize(Gia_184) - 1; Li_8 >= 0; Li_8--)
      if (As_0 == Gsa_180[Li_8] || As_0 == "" + Gia_184[Li_8]) return (MathMax(Gia_184[Li_8], Period()));
   return (Period());
}

// 1368D28A27D3419A04740CF6C5C45FD7
string f0_1(int Ai_0) {
   for (int Li_4 = ArraySize(Gia_184) - 1; Li_4 >= 0; Li_4--)
      if (Ai_0 == Gia_184[Li_4]) return (Gsa_180[Li_4]);
   return ("");
}

// 0385FAB291C6DD1F9F0C732E98E3917D
string f0_0(string As_0) {
   int Li_20;
   string Ls_ret_8 = As_0;
   for (int Li_16 = StringLen(As_0) - 1; Li_16 >= 0; Li_16--) {
      Li_20 = StringGetChar(Ls_ret_8, Li_16);
      if ((Li_20 > '`' && Li_20 < '{') || (Li_20 > 'ß' && Li_20 < 256)) Ls_ret_8 = StringSetChar(Ls_ret_8, Li_16, Li_20 - 32);
      else
         if (Li_20 > -33 && Li_20 < 0) Ls_ret_8 = StringSetChar(Ls_ret_8, Li_16, Li_20 + 224);
   }
   return (Ls_ret_8);
}
