#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Red
#property indicator_color5 Green
#property indicator_color6 Red



int g_period_76 = 20;
int gi_80 = 1;
double gd_84 = 1.0;
int gi_92 = 1;
int gi_96 = 1;
extern int Nbars = 1000;
extern bool eMailAlerts_On = FALSE;
double g_ibuf_108[];
double g_ibuf_112[];
double g_ibuf_116[];
double g_ibuf_120[];
double g_ibuf_124[];
double g_ibuf_128[];
extern bool SoundON = TRUE;
bool gi_136 = FALSE;
bool gi_140 = FALSE;

int init() {

   SetIndexBuffer(0, g_ibuf_108);
   SetIndexBuffer(1, g_ibuf_112);
   SetIndexBuffer(2, g_ibuf_116);
   SetIndexBuffer(3, g_ibuf_120);
   SetIndexBuffer(4, g_ibuf_124);
   SetIndexBuffer(5, g_ibuf_128);
   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID, 2);
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, 2);
   SetIndexStyle(2, DRAW_ARROW, STYLE_SOLID, 5);
   SetIndexStyle(3, DRAW_ARROW, STYLE_SOLID, 5);
   SetIndexStyle(4, DRAW_LINE);
   SetIndexStyle(5, DRAW_LINE);
   SetIndexArrow(0, 159);
   SetIndexArrow(1, 159);
   SetIndexArrow(2, 233);
   SetIndexArrow(3, 234);
   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS));
   string ls_0 = "ProFX01(" + g_period_76 + "," + gi_80 + ")";
   IndicatorShortName(ls_0);
   SetIndexLabel(0, "UpTrend Stop");
   SetIndexLabel(1, "DownTrend Stop");
   SetIndexLabel(2, "UpTrend Signal");
   SetIndexLabel(3, "DownTrend Signal");
   SetIndexLabel(4, "UpTrend Line");
   SetIndexLabel(5, "DownTrend Line");
   SetIndexDrawBegin(0, g_period_76);
   SetIndexDrawBegin(1, g_period_76);
   SetIndexDrawBegin(2, g_period_76);
   SetIndexDrawBegin(3, g_period_76);
   SetIndexDrawBegin(4, g_period_76);
   SetIndexDrawBegin(5, g_period_76);
   return (0);
}

string GetPeriodStr(int ai_0) {
   string ls_ret_4;
   if (ai_0 == 1) ls_ret_4 = "M1";
   if (ai_0 == 5) ls_ret_4 = "M5";
   if (ai_0 == 15) ls_ret_4 = "M15";
   if (ai_0 == 30) ls_ret_4 = "M30";
   if (ai_0 == 60) ls_ret_4 = "H1";
   if (ai_0 == 240) ls_ret_4 = "H4";
   if (ai_0 == 1440) ls_ret_4 = "D1";
   if (ai_0 == 10080) ls_ret_4 = "W1";
   if (ai_0 == 43200) ls_ret_4 = "MN1";
   return (ls_ret_4);
}

int start() {
   Comment("Www.ForexWinners.Net");
   int li_12;
   double lda_16[25000];
   double lda_20[25000];
   double lda_24[25000];
   double lda_28[25000];

   ObjectCreate("IndName", OBJ_LABEL, 0, 0, 0);
   ObjectSet("IndName", OBJPROP_CORNER, 2);
   ObjectSet("IndName", OBJPROP_XDISTANCE, 3);
   ObjectSet("IndName", OBJPROP_YDISTANCE, 3);
   ObjectSet("IndName", OBJPROP_BACK, TRUE);
   ObjectSetText("IndName", "", 9, "Times New Roman", White);
   for (int l_shift_8 = Nbars; l_shift_8 >= 0; l_shift_8--) {
      g_ibuf_108[l_shift_8] = 0;
      g_ibuf_112[l_shift_8] = 0;
      g_ibuf_116[l_shift_8] = 0;
      g_ibuf_120[l_shift_8] = 0;
      g_ibuf_124[l_shift_8] = EMPTY_VALUE;
      g_ibuf_128[l_shift_8] = EMPTY_VALUE;
   }
   for (l_shift_8 = Nbars - g_period_76 - 1; l_shift_8 >= 0; l_shift_8--) {
      lda_16[l_shift_8] = iBands(NULL, 0, g_period_76, gi_80, 0, PRICE_CLOSE, MODE_UPPER, l_shift_8);
      lda_20[l_shift_8] = iBands(NULL, 0, g_period_76, gi_80, 0, PRICE_CLOSE, MODE_LOWER, l_shift_8);
      if (Close[l_shift_8] > lda_16[l_shift_8 + 1]) li_12 = 1;
      if (Close[l_shift_8] < lda_20[l_shift_8 + 1]) li_12 = -1;
      if (li_12 > 0 && lda_20[l_shift_8] < lda_20[l_shift_8 + 1]) lda_20[l_shift_8] = lda_20[l_shift_8 + 1];
      if (li_12 < 0 && lda_16[l_shift_8] > lda_16[l_shift_8 + 1]) lda_16[l_shift_8] = lda_16[l_shift_8 + 1];
      lda_24[l_shift_8] = lda_16[l_shift_8] + (gd_84 - 1.0) / 2.0 * (lda_16[l_shift_8] - lda_20[l_shift_8]);
      lda_28[l_shift_8] = lda_20[l_shift_8] - (gd_84 - 1.0) / 2.0 * (lda_16[l_shift_8] - lda_20[l_shift_8]);
      if (li_12 > 0 && lda_28[l_shift_8] < lda_28[l_shift_8 + 1]) lda_28[l_shift_8] = lda_28[l_shift_8 + 1];
      if (li_12 < 0 && lda_24[l_shift_8] > lda_24[l_shift_8 + 1]) lda_24[l_shift_8] = lda_24[l_shift_8 + 1];
      if (li_12 > 0) {
         if (gi_92 > 0 && g_ibuf_108[l_shift_8 + 1] == -1.0) {
            g_ibuf_116[l_shift_8] = lda_28[l_shift_8];
            g_ibuf_108[l_shift_8] = lda_28[l_shift_8];
            if (gi_96 > 0) g_ibuf_124[l_shift_8] = lda_28[l_shift_8];
            if (SoundON == TRUE && l_shift_8 == 0 && !gi_136) {
               Alert("ProFx Alert UP", Symbol(), "-", Period());
               if (eMailAlerts_On) SendMail("ProFx Alert", "ProFx Alert UP - " + Symbol() + " - " + GetPeriodStr(Period()));
               gi_136 = TRUE;
               gi_140 = FALSE;
            }
         } else {
            g_ibuf_108[l_shift_8] = lda_28[l_shift_8];
            if (gi_96 > 0) g_ibuf_124[l_shift_8] = lda_28[l_shift_8];
            g_ibuf_116[l_shift_8] = -1;
         }
         if (gi_92 == 2) g_ibuf_108[l_shift_8] = 0;
         g_ibuf_120[l_shift_8] = -1;
         g_ibuf_112[l_shift_8] = -1.0;
         g_ibuf_128[l_shift_8] = EMPTY_VALUE;
      }
      if (li_12 < 0) {
         if (gi_92 > 0 && g_ibuf_112[l_shift_8 + 1] == -1.0) {
            g_ibuf_120[l_shift_8] = lda_24[l_shift_8];
            g_ibuf_112[l_shift_8] = lda_24[l_shift_8];
            if (gi_96 > 0) g_ibuf_128[l_shift_8] = lda_24[l_shift_8];
            if (SoundON == TRUE && l_shift_8 == 0 && !gi_140) {
               Alert("ProFx Alert DOWN", Symbol(), "-", Period());
               if (eMailAlerts_On) SendMail("ProFx Alert", "ProFx Alert DOWN - " + Symbol() + " - " + GetPeriodStr(Period()));
               gi_140 = TRUE;
               gi_136 = FALSE;
            }
         } else {
            g_ibuf_112[l_shift_8] = lda_24[l_shift_8];
            if (gi_96 > 0) g_ibuf_128[l_shift_8] = lda_24[l_shift_8];
            g_ibuf_120[l_shift_8] = -1;
         }
         if (gi_92 == 2) g_ibuf_112[l_shift_8] = 0;
         g_ibuf_116[l_shift_8] = -1;
         g_ibuf_108[l_shift_8] = -1.0;
         g_ibuf_124[l_shift_8] = EMPTY_VALUE;
      }
   }
   return (0);
}

int deinit() {
   ObjectDelete("IndName");

   return (0);
}