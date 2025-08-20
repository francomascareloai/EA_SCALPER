/*
 
   
   
*/
#property copyright "forexeasy uruguay"


#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red

double g_ibuf_76[];
double g_ibuf_80[];
int g_period_84 = 1;
int g_period_88 = 18;
extern bool SoundON = TRUE;
double g_time_96;

int init() {
   SetIndexStyle(0, DRAW_ARROW, EMPTY);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, g_ibuf_76);
   SetIndexStyle(1, DRAW_ARROW, EMPTY);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, g_ibuf_80);
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   int li_8;
   double l_ima_12;
   double l_ima_20;
   double l_ima_28;
   double l_ima_36;
   double l_ima_44;
   double l_ima_52;
   double ld_60;
   double ld_68;

   int li_76 = IndicatorCounted();
   if (li_76 < 0) return (-1);
   if (li_76 > 0) li_76--;
   int li_0 = Bars + 1 - li_76;
   for (int li_4 = 0; li_4 <= li_0; li_4++) {
      li_8 = li_4;
      ld_60 = 0;
      ld_68 = 0;
      for (li_8 = li_4; li_8 <= li_4 + 9; li_8++) ld_68 += MathAbs(High[li_8] - Low[li_8]);
      ld_60 = ld_68 / 10.0;
      l_ima_12 = iMA(NULL, 0, g_period_84, 0, MODE_EMA, PRICE_CLOSE, li_4);
      l_ima_28 = iMA(NULL, 0, g_period_84, 0, MODE_EMA, PRICE_CLOSE, li_4 + 1);
      l_ima_44 = iMA(NULL, 0, g_period_84, 0, MODE_EMA, PRICE_CLOSE, li_4 - 1);
      l_ima_20 = iMA(NULL, 0, g_period_88, 0, MODE_EMA, PRICE_CLOSE, li_4);
      l_ima_36 = iMA(NULL, 0, g_period_88, 0, MODE_EMA, PRICE_CLOSE, li_4 + 1);
      l_ima_52 = iMA(NULL, 0, g_period_88, 0, MODE_EMA, PRICE_CLOSE, li_4 - 1);
double TENKAN = iIchimoku(NULL, 0, 9, 26, 52, MODE_TENKANSEN, li_4);
double KIJUN = iIchimoku(NULL, 0, 9, 26, 52, MODE_KIJUNSEN, li_4);
double SENKOU = iIchimoku(NULL, 0, 9, 26, 52, MODE_SENKOUSPANB, li_4);
      if (TENKAN>KIJUN && TENKAN>SENKOU && l_ima_12 > l_ima_20 && l_ima_28 < l_ima_36 && l_ima_44 > l_ima_52) g_ibuf_76[li_4] = Low[li_4] - ld_60 / 2.0;
      else
         if (TENKAN<KIJUN && TENKAN<SENKOU && l_ima_12 < l_ima_20 && l_ima_28 > l_ima_36 && l_ima_44 < l_ima_52) g_ibuf_80[li_4] = High[li_4] + ld_60 / 2.0;
      if (TENKAN>KIJUN && TENKAN>SENKOU && l_ima_12 > l_ima_20 && l_ima_28 < l_ima_36 && l_ima_44 > l_ima_52) {
         g_ibuf_76[li_4] = Low[li_4] - ld_60 / 2.0;
         if (SoundON == TRUE && g_time_96 != Time[0]) {
            Alert("ScalpPro Buy Trade Imminent ", Symbol(), Period());
            g_time_96 = Time[0];
         }
      } else {
         if (TENKAN<KIJUN && TENKAN<SENKOU && l_ima_12 < l_ima_20 && l_ima_28 > l_ima_36 && l_ima_44 < l_ima_52) {
            g_ibuf_80[li_4] = High[li_4] + ld_60 / 2.0;
            if (SoundON == TRUE && g_time_96 != Time[0]) {
               Alert("ScalpPro Sell Trade Imminent ", Symbol(), Period());
               g_time_96 = Time[0];
            }
         }
      }
   }
   return (0);
}