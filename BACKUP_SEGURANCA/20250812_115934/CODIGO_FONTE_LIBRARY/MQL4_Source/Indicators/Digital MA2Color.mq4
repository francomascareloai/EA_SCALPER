#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Yellow

extern int SignalPeriod = 28;
int Gi_80 = 0;
extern int NR_SLIPE = 3;
int G_applied_price_88 = PRICE_CLOSE;
extern double FilterNumber = 3.0;
bool Gi_100 = TRUE;
int Gi_104 = 0;
extern int lineWidth = 3;
extern int barsToDrawLine = 10000;
extern bool skipSingleBarSignal = FALSE;
extern int aTake_Profit = 150;
extern int aStop_Loss = 150;
extern bool aAlerts = TRUE;
extern bool EmailOn = TRUE;
datetime G_time_136;
string Gs_148;
string Gs_156 = "fx_NR_Scalping";
double G_ibuf_164[];
double G_ibuf_168[];
double G_ibuf_172[];
double G_ibuf_176[];
int Gi_180;
string Gs_184;
int Gi_unused_192 = 0;

string GetTimeFrameStr() {
   string timeframe_4;
   switch (Period()) {
   case PERIOD_M1:
      timeframe_4 = "M1";
      break;
   case PERIOD_M5:
      timeframe_4 = "M5";
      break;
   case PERIOD_M15:
      timeframe_4 = "M15";
      break;
   case PERIOD_M30:
      timeframe_4 = "M30";
      break;
   case PERIOD_H1:
      timeframe_4 = "H1";
      break;
   case PERIOD_H4:
      timeframe_4 = "H4";
      break;
   case PERIOD_D1:
      timeframe_4 = "D1";
      break;
   case PERIOD_W1:
      timeframe_4 = "W1";
      break;
   case PERIOD_MN1:
      timeframe_4 = "MN1";
      break;
   default:
      timeframe_4 = Period();
   }
   return (timeframe_4);
}

void DisplayAlert(string As_0, double Ad_8, double Ad_16, double Ad_24) {
   string Ls_32;
   string Ls_40;
   string Ls_48;
   string Ls_56;
   if (Time[0] != G_time_136) {
      G_time_136 = Time[0];
      if (Gs_148 != As_0) {
         Gs_148 = As_0;
         if (Ad_8 != 0.0) Ls_48 = " @ Price " + DoubleToStr(Ad_8, 4);
         else Ls_48 = "";
         if (Ad_16 != 0.0) Ls_40 = ", TakeProfit   " + DoubleToStr(Ad_16, 4);
         else Ls_40 = "";
         if (Ad_24 != 0.0) Ls_32 = ", StopLoss   " + DoubleToStr(Ad_24, 4);
         else Ls_32 = "";
         Ls_56 = Gs_184 + "Scalping " + aRperiodf() + " Alert " + As_0 
            + "\n" 
            + As_0 + Ls_48 + Ls_40 + Ls_32 
         + "\nDate & Time = " + TimeToStr(TimeCurrent(), TIME_DATE) + " " + TimeHour(TimeCurrent()) + ":" + TimeMinute(TimeCurrent()) + " ";
         Alert(Ls_56, Symbol(), ", ", Period(), " minutes chart");
         PlaySound("alert.wav");
         if (EmailOn) SendMail(Gs_184, Ls_56);
      }
   }
}

int init() {
   IndicatorBuffers(4);
   SetIndexBuffer(0, G_ibuf_164);
   SetIndexBuffer(1, G_ibuf_168);
   SetIndexBuffer(2, G_ibuf_172);
   SetIndexBuffer(3, G_ibuf_176);
   if (Gi_100) {
      SetIndexStyle(0, DRAW_ARROW, EMPTY, lineWidth - 3);
      SetIndexStyle(1, DRAW_ARROW, EMPTY, lineWidth - 3);
      SetIndexStyle(2, DRAW_ARROW, EMPTY, lineWidth - 3);
      SetIndexArrow(0, 159);
      SetIndexArrow(1, 159);
      SetIndexArrow(2, 159);
   } else {
      SetIndexStyle(0, DRAW_LINE);
      SetIndexStyle(1, DRAW_LINE);
      SetIndexStyle(2, DRAW_LINE);
   }
   Gi_180 = SignalPeriod + MathFloor(MathSqrt(SignalPeriod));
   SetIndexDrawBegin(0, Gi_180);
   SetIndexDrawBegin(1, Gi_180);
   SetIndexDrawBegin(2, Gi_180);
   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS) + 1.0);
   IndicatorShortName("Scalping(" + SignalPeriod + ")");
   SetIndexLabel(0, "Scalping");
   Gs_184 = Symbol() + " (" + GetTimeFrameStr() + "):  ";
   Gs_148 = "";
   ArrayInitialize(G_ibuf_164, EMPTY_VALUE);
   ArrayInitialize(G_ibuf_172, EMPTY_VALUE);
   ArrayInitialize(G_ibuf_168, EMPTY_VALUE);
   return (0);
}

int deinit() {
   DelObj();
   return (0);
}

int start() {
   double ima_on_arr_20;
   int Li_unused_28;
   int ind_counted_8 = IndicatorCounted();
   if (ind_counted_8 < 1) {
      for (int Li_4 = 0; Li_4 <= Gi_180; Li_4++) G_ibuf_176[Bars - Li_4] = 0;
      for (Li_4 = 0; Li_4 <= SignalPeriod; Li_4++) {
         G_ibuf_164[Bars - Li_4] = EMPTY_VALUE;
         G_ibuf_168[Bars - Li_4] = EMPTY_VALUE;
         G_ibuf_172[Bars - Li_4] = EMPTY_VALUE;
      }
   }
   int Li_0 = Bars - ind_counted_8;
   for (Li_4 = 1; Li_4 < Li_0; Li_4++) {
      G_ibuf_176[Li_4] = 2.0 * iMA(NULL, 0, MathFloor(SignalPeriod / FilterNumber), Gi_80, NR_SLIPE, G_applied_price_88, Li_4) - iMA(NULL, 0, SignalPeriod, Gi_80, NR_SLIPE,
         G_applied_price_88, Li_4);
   }
   double ima_on_arr_12 = iMAOnArray(G_ibuf_176, 0, MathFloor(MathSqrt(SignalPeriod)), 0, NR_SLIPE, 1);
   for (Li_4 = 2; Li_4 < Li_0 + 1; Li_4++) {
      ima_on_arr_20 = iMAOnArray(G_ibuf_176, 0, MathFloor(MathSqrt(SignalPeriod)), 0, NR_SLIPE, Li_4);
      Li_unused_28 = 0;
      if (ima_on_arr_20 > ima_on_arr_12) {
         G_ibuf_172[Li_4 - 1] = ima_on_arr_12 - Gi_104 * Point;
         Li_unused_28 = 1;
      } else {
         if (ima_on_arr_20 < ima_on_arr_12) {
            G_ibuf_164[Li_4 - 1] = ima_on_arr_12 + Gi_104 * Point;
            Li_unused_28 = 2;
         } else {
            G_ibuf_164[Li_4 - 1] = EMPTY_VALUE;
            G_ibuf_168[Li_4 - 1] = ima_on_arr_12;
            G_ibuf_172[Li_4 - 1] = EMPTY_VALUE;
            Li_unused_28 = 3;
         }
      }
      if (ind_counted_8 > 0) {
      }
      ima_on_arr_12 = ima_on_arr_20;
   }
   if (Li_0 > barsToDrawLine) Li_0 = barsToDrawLine;
   for (Li_4 = 2; Li_4 <= Li_0; Li_4++) {
      if (G_ibuf_164[Li_4 - 1] != EMPTY_VALUE) {
         if (G_ibuf_164[Li_4] != EMPTY_VALUE) drawLineSegment(Li_4 - 1, Li_4, 1);
         else drawLineSegment(Li_4 - 1, Li_4, 10);
      }
      if (G_ibuf_172[Li_4 - 1] != EMPTY_VALUE) {
         if (G_ibuf_172[Li_4] != EMPTY_VALUE) {
            drawLineSegment(Li_4 - 1, Li_4, -1);
            continue;
         }
         drawLineSegment(Li_4 - 1, Li_4, -10);
      }
   }
   if (aAlerts) {
      if ((skipSingleBarSignal == FALSE && G_ibuf_172[1] != EMPTY_VALUE && G_ibuf_172[2] == EMPTY_VALUE) || (skipSingleBarSignal == TRUE && G_ibuf_172[1] != EMPTY_VALUE &&
         G_ibuf_172[2] != EMPTY_VALUE && G_ibuf_172[3] == EMPTY_VALUE)) DisplayAlert("Sell signal", Close[1], aGetTPs(), aGetSLs());
      if ((skipSingleBarSignal == FALSE && G_ibuf_164[1] != EMPTY_VALUE && G_ibuf_164[2] == EMPTY_VALUE) || (skipSingleBarSignal == TRUE && G_ibuf_164[1] != EMPTY_VALUE &&
         G_ibuf_164[2] != EMPTY_VALUE && G_ibuf_164[3] == EMPTY_VALUE)) DisplayAlert("Buy signal", Close[1], aGetTPl(), aGetSLl());
   }
   return (0);
}

double aGetTPs() {
   return (Bid - aTake_Profit * Point);
}

double aGetTPl() {
   return (Ask + aTake_Profit * Point);
}

double aGetSLs() {
   return (Bid + aStop_Loss * Point);
}

double aGetSLl() {
   return (Ask - aStop_Loss * Point);
}

int aRperiodf() {
   return (10000.0 * (SignalPeriod * Point));
}

void DelObj() {
   string name_0;
   int str_len_12;
   for (int Li_8 = ObjectsTotal() - 1; Li_8 >= 0; Li_8--) {
      name_0 = ObjectName(Li_8);
      str_len_12 = StringLen(Gs_156);
      if (StringSubstr(name_0, 0, str_len_12) == Gs_156) ObjectDelete(name_0);
   }
}

void drawLineSegment(int Ai_0, int Ai_4, int Ai_8) {
   double price_20;
   double price_28;
   color color_36;
   if (Ai_8 > 0) {
      price_20 = G_ibuf_164[Ai_0];
      if (Ai_8 == 1) price_28 = G_ibuf_164[Ai_4];
      else price_28 = G_ibuf_172[Ai_4];
      color_36 = Lime;
   } else {
      price_20 = G_ibuf_172[Ai_0];
      if (Ai_8 == -1) price_28 = G_ibuf_172[Ai_4];
      else price_28 = G_ibuf_164[Ai_4];
      color_36 = Red;
   }
   int time_12 = Time[Ai_0];
   int time_16 = Time[Ai_4];
   if (price_20 == EMPTY_VALUE || price_28 == EMPTY_VALUE) {
      Print("Empty value for price line encountered!");
      return;
   }
   string name_40 = Gs_156 + "_segment_" + color_36 + time_12 + "_" + time_16;
   ObjectDelete(name_40);
   ObjectCreate(name_40, OBJ_TREND, 0, time_12, price_20, time_16, price_28, 0, 0);
   ObjectSet(name_40, OBJPROP_WIDTH, lineWidth);
   ObjectSet(name_40, OBJPROP_COLOR, color_36);
   ObjectSet(name_40, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(name_40, OBJPROP_RAY, FALSE);
}
