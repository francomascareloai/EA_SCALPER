
#property indicator_chart_window
#property indicator_minimum -1.2
#property indicator_maximum 1.2
#property indicator_levelcolor Lime
#property indicator_buffers 1
#property indicator_color1 Blue
#property indicator_width1 3
#property indicator_level1 0.8
#property indicator_level2 -0.8

int gi_76 = 22;
extern int FilterPeriod = 22;
double gd_84 = 1.0;
int gi_92 = 0;
extern int SL_distance_pips = 20;
double g_ibuf_100[];
double gda_104[];
double g_ibuf_108[];
int gi_112 = 14;
double gda_116[];
double gd_120;
int gia_128[];
int gia_132[];
int gi_136 = 0;
int g_time_140 = 0;
string gs_144 = "www.mql54.com";
string g_name_152;
datetime g_time_160;

void f0_7(string as_0, double ad_8, double ad_16, double ad_24) {
   string ls_32;
   string ls_40;
   string ls_48;
   if (Time[0] != g_time_160) {
      g_time_160 = Time[0];
      if (ad_24 != 0.0) ls_48 = " - price " + DoubleToStr(ad_24, 4);
      else ls_48 = "";
      if (ad_8 != 0.0) ls_40 = ", TakeProfit on " + DoubleToStr(ad_8, 4);
      else ls_40 = "";
      if (ad_16 != 0.0) ls_32 = ", StopLoss on " + DoubleToStr(ad_16, 4);
      else ls_32 = "";
      Alert("www.mql54.com " + as_0 + ls_48 + ls_40 + ls_32 + " ", Symbol(), ", ", Period(), " minute chart");
   }
}

void f0_0(int ai_0) {
   int li_4;
   int count_8;
   int li_12;
   int li_16;
   double ld_20;
   switch (gi_92) {
   case 0:
      gda_104[ai_0] = iMA(NULL, 0, gi_76 + 1, 0, MODE_LWMA, PRICE_CLOSE, ai_0);
      break;
   case 1:
      gda_104[ai_0] = iMA(NULL, 0, gi_76 + 1, 0, MODE_LWMA, PRICE_OPEN, ai_0);
      break;
   case 2:
      gda_104[ai_0] = iMA(NULL, 0, gi_76 + 1, 0, MODE_LWMA, PRICE_HIGH, ai_0);
      break;
   case 3:
      gda_104[ai_0] = iMA(NULL, 0, gi_76 + 1, 0, MODE_LWMA, PRICE_LOW, ai_0);
      break;
   case 4:
      gda_104[ai_0] = iMA(NULL, 0, gi_76 + 1, 0, MODE_LWMA, PRICE_MEDIAN, ai_0);
      break;
   case 5:
      gda_104[ai_0] = iMA(NULL, 0, gi_76 + 1, 0, MODE_LWMA, PRICE_TYPICAL, ai_0);
      break;
   case 6:
      gda_104[ai_0] = iMA(NULL, 0, gi_76 + 1, 0, MODE_LWMA, PRICE_WEIGHTED, ai_0);
      break;
   default:
      gda_104[ai_0] = iMA(NULL, 0, gi_76 + 1, 0, MODE_LWMA, PRICE_WEIGHTED, ai_0);
   }
   for (int li_32 = ai_0 + gi_76 + 2; li_32 > ai_0; li_32--) {
      ld_20 = 0.0;
      li_4 = 0;
      count_8 = 0;
      li_12 = li_32 + gi_76;
      li_16 = li_32 - gi_76;
      if (li_16 < ai_0) li_16 = ai_0;
      while (li_12 >= li_32) {
         count_8++;
         ld_20 += count_8 * f0_4(li_12);
         li_4 += count_8;
         li_12--;
      }
      while (li_12 >= li_16) {
         count_8--;
         ld_20 += count_8 * f0_4(li_12);
         li_4 += count_8;
         li_12--;
      }
      gda_104[li_32] = ld_20 / li_4;
   }
}

double f0_4(int ai_0) {
   switch (gi_92) {
   case 0:
      return (Close[ai_0]);
   case 1:
      return (Open[ai_0]);
   case 2:
      return (High[ai_0]);
   case 3:
      return (Low[ai_0]);
   case 4:
      return ((High[ai_0] + Low[ai_0]) / 2.0);
   case 5:
      return ((Close[ai_0] + High[ai_0] + Low[ai_0]) / 3.0);
   case 6:
      return ((2.0 * Close[ai_0] + High[ai_0] + Low[ai_0]) / 4.0);
   }
   return (Close[ai_0]);
}

void f0_8(int ai_0) {
   double ld_4 = gda_104[ArrayMaximum(gda_104, FilterPeriod, ai_0)];
   double ld_12 = gda_104[ArrayMinimum(gda_104, FilterPeriod, ai_0)];
   g_ibuf_108[ai_0] = (2.0 * (gd_84 + 2.0) * gda_104[ai_0] - (ld_4 + ld_12)) / 2.0 / (gd_84 + 1.0);
}

double f0_1(double ada_0[], int ai_4) {
   double ld_8;
   for (int index_16 = 0; index_16 < ai_4; index_16++) ld_8 += MathPow(ada_0[index_16] - index_16 - 1.0, 2);
   double ld_ret_20 = 1 - 6.0 * ld_8 / (MathPow(ai_4, 3) - ai_4);
   return (ld_ret_20);
}

void f0_5(int aia_0[]) {
   double ld_4;
   double ld_12;
   int index_20;
   int li_24;
   int li_28;
   int li_32;
   double lda_36[];
   ArrayResize(lda_36, gi_112);
   ArrayCopy(gia_132, aia_0);
   for (int index_40 = 0; index_40 < gi_112; index_40++) lda_36[index_40] = index_40 + 1;
   ArraySort(gia_132, WHOLE_ARRAY, 0, MODE_DESCEND);
   for (index_40 = 0; index_40 < gi_112 - 1; index_40++) {
      if (gia_132[index_40] == gia_132[index_40 + 1]) {
         li_24 = gia_132[index_40];
         index_20 = index_40 + 1;
         li_28 = 1;
         ld_12 = index_40 + 1;
         while (index_20 < gi_112) {
            if (gia_132[index_20] != li_24) break;
            li_28++;
            ld_12 += index_20 + 1;
            index_20++;
         }
         ld_4 = li_28;
         ld_12 /= ld_4;
         for (int li_44 = index_40; li_44 < index_20; li_44++) lda_36[li_44] = ld_12;
         index_40 = index_20;
      }
   }
   for (index_40 = 0; index_40 < gi_112; index_40++) {
      li_32 = aia_0[index_40];
      for (index_20 = 0; index_20 < gi_112; index_20++) {
         if (li_32 == gia_132[index_20]) {
            gda_116[index_40] = lda_36[index_20];
            break;
         }
      }
   }
}

int init() {
   IndicatorBuffers(3);
   SetIndexBuffer(0, g_ibuf_100);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexBuffer(1, gda_104);
   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(2, g_ibuf_108);
   SetIndexStyle(2, DRAW_NONE);
   ArrayResize(gda_116, gi_112);
   ArrayResize(gia_128, gi_112);
   ArrayResize(gia_132, gi_112);
   if (gi_112 > 30) IndicatorShortName("www.mql54.com");
   else IndicatorShortName("BuySellWait");
   gd_120 = MathPow(10, Digits);
   return (0);
}

int deinit() {
   f0_3("");
   return (0);
}

int start() {
   int li_0;
   int li_4;
   int li_8;
   double open_24;
   double time_32;
   double ld_40;
   int li_48;
   int ind_counted_12 = IndicatorCounted();
   if (gi_112 > 30) return (-1);
   if (ind_counted_12 == 0) {
      li_0 = Bars - (gi_112 + FilterPeriod + gi_76 + 4);
      li_4 = Bars - (gi_76 + 2);
      li_8 = Bars - (FilterPeriod + gi_76 + 3);
   }
   if (ind_counted_12 > 0) {
      li_0 = Bars - ind_counted_12 + 1;
      li_4 = li_0;
      li_8 = li_0;
   }
   for (int li_16 = li_4; li_16 >= 0; li_16--) f0_0(li_16);
   for (li_16 = li_8; li_16 >= 0; li_16--) f0_8(li_16);
   for (li_16 = li_0; li_16 >= 0; li_16--) {
      for (int index_20 = 0; index_20 < gi_112; index_20++) gia_128[index_20] = (g_ibuf_108[li_16 + index_20]) * gd_120;
      f0_5(gia_128);
      g_ibuf_100[li_16] = f0_1(gda_116, gi_112);
      if (g_ibuf_100[li_16] > 1.0) g_ibuf_100[li_16] = 1.0;
      if (g_ibuf_100[li_16] < -1.0) g_ibuf_100[li_16] = -1.0;
   }
   if (Time[0] <= g_time_140) return (0);
   g_time_140 = Time[0];
   gi_136 = 0;
   f0_3("");
   for (int li_52 = 300; li_52 >= 0; li_52--) {
      open_24 = Open[li_52];
      time_32 = Time[li_52];
      if (gi_136 >= 0) {
         if (g_ibuf_100[li_52 + 2] >= 0.8 && g_ibuf_100[li_52 + 1] <= 0.8) {
            gi_136 = -1;
            ld_40 = High[1] + SL_distance_pips * Point;
            li_48 = 255;
            if (li_52 == 0) {
               f0_7("Sell signal", 0, ld_40, open_24);
               li_48 = 16711680;
            }
            f0_2(time_32, open_24, gi_136, li_48);
         }
      }
      if (gi_136 <= 0) {
         if (g_ibuf_100[li_52 + 2] <= -0.8 && g_ibuf_100[li_52 + 1] >= -0.8) {
            gi_136 = 1;
            ld_40 = Low[1] + SL_distance_pips * Point;
            li_48 = 65280;
            if (li_52 == 0) {
               f0_7("Buy signal", 0, ld_40, open_24);
               li_48 = 16711680;
            }
            f0_2(time_32, open_24, gi_136, li_48);
         }
      }
   }
   f0_6();
   return (0);
}

void f0_6() {
   g_name_152 = gs_144 + "www.mql54.com";
   string text_0 = "www.mql54.com -  Current Signal: ";
   if (gi_136 == 0) text_0 = text_0 + "Wait";
   if (gi_136 < 0) text_0 = text_0 + "Sell";
   if (gi_136 > 0) text_0 = text_0 + "Buy";
   int li_8 = WindowBarsPerChart();
   int li_12 = 60 * Period();
   double ld_16 = High[iHighest(NULL, 0, MODE_HIGH, li_8 * 4 / 5, 0)];
   double ld_24 = Low[iLowest(NULL, 0, MODE_LOW, li_8 * 4 / 5, 0)];
   double datetime_32 = Time[0] + (li_8 / 75 + 10) * li_12;
   double price_40 = ld_24 + (ld_16 - ld_24) / 10.0;
   double ld_48 = MathMax(7, 3.0 * MathCeil(li_8 / 5.0 / 3.0) + 1.0 - 3.0) * li_12;
   ObjectDelete(g_name_152);
   ObjectCreate(g_name_152, OBJ_TEXT, 0, datetime_32, price_40, 0, 0, 0, 0);
   ObjectSetText(g_name_152, text_0);
   ObjectSet(g_name_152, OBJPROP_COLOR, Red);
}

void f0_2(int a_datetime_0, double a_price_4, int ai_12, color a_color_16) {
   int li_20;
   if (ai_12 > 0) {
      li_20 = 233;
      a_price_4 -= 1.0 * Point;
   } else {
      li_20 = 234;
      a_price_4 += 10.0 * Point;
   }
   g_name_152 = gs_144 + "signalArrow" + a_price_4 + a_datetime_0 + li_20;
   ObjectDelete(g_name_152);
   ObjectCreate(g_name_152, OBJ_ARROW, 0, a_datetime_0, a_price_4, 0, 0, 0, 0);
   ObjectSet(g_name_152, OBJPROP_WIDTH, 2);
   ObjectSet(g_name_152, OBJPROP_ARROWCODE, li_20);
   ObjectSet(g_name_152, OBJPROP_COLOR, a_color_16);
}

void f0_3(string as_0) {
   string name_8;
   int li_20;
   string ls_24;
   for (int li_16 = ObjectsTotal() - 1; li_16 >= 0; li_16--) {
      name_8 = ObjectName(li_16);
      li_20 = StringLen(as_0) + StringLen(gs_144);
      ls_24 = as_0 + gs_144;
      if (StringSubstr(name_8, 0, li_20) == ls_24) ObjectDelete(name_8);
   }
}