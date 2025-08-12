#property copyright "Copyright © Pointzero-indicator.com"
#property link      "http://www.pointzero-indicator.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 DodgerBlue
#property indicator_color2 Red

//#include <stdlib.mqh>

int gia_76[] = {33, 42, 39, 40, 41, 59, 58, 64, 38, 61, 43, 36, 47, 63, 35, 91, 93};
extern bool CalculateOnBarClose = TRUE;
extern int OsPeriod = 20;
double g_ibuf_88[];
double g_ibuf_92[];
double g_ibuf_96[];
double g_ibuf_100[];
double g_ibuf_104[];
double g_ibuf_108[];
double g_ibuf_112[];
double g_ibuf_116[];
int g_period_120 = 2;

string f0_5(string as_0) {
   int lia_36[16];
   int lia_40[16];
   int lia_52[16];
   string ls_64;
   int li_72;
   int str_len_8 = StringLen(as_0);
   int li_12 = str_len_8 % 64;
   int li_16 = (str_len_8 - li_12) / 64;
   datetime lt_20 = D'26.11.2024 02:23:13';
   int li_24 = -271733879;
   int li_28 = -1732584194;
   int li_32 = 271733878;
   for (int count_44 = 0; count_44 < li_16; count_44++) {
      ls_64 = StringSubstr(as_0, count_44 * 64, 64);
      f0_3(lia_36, ls_64);
      f0_10(lt_20, li_24, li_28, li_32, lia_36);
   }
   ArrayInitialize(lia_40, 0);
   ArrayInitialize(lia_52, 0);
   int li_56 = 0;
   if (li_12 > 0) {
      li_72 = li_12 % 4;
      li_16 = li_12 - li_72;
      if (li_16 > 0) {
         ls_64 = StringSubstr(as_0, count_44 * 64, li_16);
         li_56 = f0_3(lia_40, ls_64);
      }
      for (int index_48 = 0; index_48 < li_72; index_48++) lia_52[index_48] = StringGetChar(as_0, count_44 * 64 + li_16 + index_48);
   }
   lia_52[index_48] = 128;
   lia_40[li_56] = f0_16(lia_52);
   if (li_12 >= 56) {
      f0_10(lt_20, li_24, li_28, li_32, lia_40);
      ArrayInitialize(lia_40, 0);
   }
   lia_40[14] = str_len_8 * 8;
   lia_40[15] = str_len_8 >> 1 & EMPTY_VALUE >> 28;
   f0_10(lt_20, li_24, li_28, li_32, lia_40);
   return (StringConcatenate(f0_4(lt_20), f0_4(li_24), f0_4(li_28), f0_4(li_32)));
}

int f0_6(int ai_0, int ai_4, int ai_8) {
   return (ai_0 & ai_4 | ai_0 & ai_8);
}

int f0_17(int ai_0, int ai_4, int ai_8) {
   return (ai_0 & ai_8 | ai_4 & ai_8);
}

int f0_14(int ai_0, int ai_4, int ai_8) {
   return (ai_0 ^ ai_4 ^ ai_8);
}

int f0_15(int ai_0, int ai_4, int ai_8) {
   return (ai_4 ^ ai_0 | ai_8);
}

int f0_9(int ai_0, int ai_4) {
   int li_ret_8 = ai_0 + ai_4;
   return (li_ret_8);
}

int f0_1(int ai_0, int ai_4, int ai_8, int ai_12, int ai_16, int ai_20, int ai_24) {
   ai_0 = f0_9(ai_0, f0_9(f0_9(f0_6(ai_4, ai_8, ai_12), ai_16), ai_24));
   return (f0_9(f0_8(ai_0, ai_20), ai_4));
}

int f0_7(int ai_0, int ai_4, int ai_8, int ai_12, int ai_16, int ai_20, int ai_24) {
   ai_0 = f0_9(ai_0, f0_9(f0_9(f0_17(ai_4, ai_8, ai_12), ai_16), ai_24));
   return (f0_9(f0_8(ai_0, ai_20), ai_4));
}

int f0_18(int ai_0, int ai_4, int ai_8, int ai_12, int ai_16, int ai_20, int ai_24) {
   ai_0 = f0_9(ai_0, f0_9(f0_9(f0_14(ai_4, ai_8, ai_12), ai_16), ai_24));
   return (f0_9(f0_8(ai_0, ai_20), ai_4));
}

int f0_2(int ai_0, int ai_4, int ai_8, int ai_12, int ai_16, int ai_20, int ai_24) {
   ai_0 = f0_9(ai_0, f0_9(f0_9(f0_15(ai_4, ai_8, ai_12), ai_16), ai_24));
   return (f0_9(f0_8(ai_0, ai_20), ai_4));
}

int f0_8(int ai_0, int ai_4) {
   if (ai_4 == 32) return (ai_0);
   int li_ret_8 = ai_0 << ai_4 | ai_0 >> 1 & EMPTY_VALUE >> (31 - ai_4);
   return (li_ret_8);
}

int f0_3(int &aia_0[16], string as_4) {
   int li_12 = StringLen(as_4);
   if (li_12 % 4 != 0) li_12 -= li_12 % 4;
   int arr_size_24 = ArraySize(aia_0);
   if (arr_size_24 < li_12 / 4) ArrayResize(aia_0, li_12 / 4);
   int index_16 = 0;
   for (int li_20 = 0; li_20 < li_12; li_20 += 4) {
      aia_0[index_16] = StringGetChar(as_4, li_20) | (StringGetChar(as_4, li_20 + 1) * 256) | StringGetChar(as_4, li_20 + 2) << 16 | StringGetChar(as_4, li_20 + 3) << 24;
      index_16++;
   }
   return (li_12 / 4);
}

string f0_4(int ai_0) {
   string ls_12;
   int lia_20[4];
   string str_concat_4 = "";
   lia_20[0] = ai_0 & 255;
   for (int li_24 = 1; li_24 < 4; li_24++) lia_20[li_24] = ai_0 >> 1 & EMPTY_VALUE >> (li_24 * 8 - 1) & 255;
   for (int index_28 = 0; index_28 < 4; index_28++) {
      ls_12 = f0_12(lia_20[index_28]);
      str_concat_4 = StringConcatenate(str_concat_4, ls_12);
   }
   return (str_concat_4);
}

string f0_12(int ai_0) {
   int li_4;
   string str_concat_8;
   for (int count_16 = 0; count_16 < 2; count_16++) {
      li_4 = ai_0 % 16;
      ai_0 = (ai_0 - li_4) / 16;
      str_concat_8 = StringConcatenate(f0_13(li_4), str_concat_8);
   }
   return (str_concat_8);
}

string f0_13(int ai_0) {
   int li_12;
   string ls_4 = "0";
   if (ai_0 < 10) li_12 = ai_0 + 48;
   else li_12 = ai_0 + 97 - 10;
   return (StringSetChar(ls_4, 0, li_12));
}

int f0_16(int aia_0[4]) {
   return (aia_0[0] | (aia_0[1] * 256) | aia_0[2] << 16 | aia_0[3] << 24);
}

void f0_10(int &ai_0, int &ai_4, int &ai_8, int &ai_12, int aia_16[16]) {
   int li_36 = 7;
   int li_40 = 12;
   int li_44 = 17;
   int li_48 = 22;
   int li_52 = 5;
   int li_56 = 9;
   int li_60 = 14;
   int li_64 = 20;
   int li_68 = 4;
   int li_72 = 11;
   int li_76 = 16;
   int li_80 = 23;
   int li_84 = 6;
   int li_88 = 10;
   int li_92 = 15;
   int li_96 = 21;
   int li_20 = ai_0;
   int li_24 = ai_4;
   int li_28 = ai_8;
   int li_32 = ai_12;
   ai_0 = f0_1(ai_0, ai_4, ai_8, ai_12, aia_16[0], li_36, -680876936);
   ai_12 = f0_1(ai_12, ai_0, ai_4, ai_8, aia_16[1], li_40, -389564586);
   ai_8 = f0_1(ai_8, ai_12, ai_0, ai_4, aia_16[2], li_44, 606105819);
   ai_4 = f0_1(ai_4, ai_8, ai_12, ai_0, aia_16[3], li_48, -1044525330);
   ai_0 = f0_1(ai_0, ai_4, ai_8, ai_12, aia_16[4], li_36, -176418897);
   ai_12 = f0_1(ai_12, ai_0, ai_4, ai_8, aia_16[5], li_40, D'11.01.2008 20:40:26');
   ai_8 = f0_1(ai_8, ai_12, ai_0, ai_4, aia_16[6], li_44, -1473231341);
   ai_4 = f0_1(ai_4, ai_8, ai_12, ai_0, aia_16[7], li_48, -45705983);
   ai_0 = f0_1(ai_0, ai_4, ai_8, ai_12, aia_16[8], li_36, D'02.02.2026 13:30:16');
   ai_12 = f0_1(ai_12, ai_0, ai_4, ai_8, aia_16[9], li_40, -1958414417);
   ai_8 = f0_1(ai_8, ai_12, ai_0, ai_4, aia_16[10], li_44, -42063);
   ai_4 = f0_1(ai_4, ai_8, ai_12, ai_0, aia_16[11], li_48, -1990404162);
   ai_0 = f0_1(ai_0, ai_4, ai_8, ai_12, aia_16[12], li_36, D'09.03.2027 15:48:02');
   ai_12 = f0_1(ai_12, ai_0, ai_4, ai_8, aia_16[13], li_40, -40341101);
   ai_8 = f0_1(ai_8, ai_12, ai_0, ai_4, aia_16[14], li_44, -1502002290);
   ai_4 = f0_1(ai_4, ai_8, ai_12, ai_0, aia_16[15], li_48, D'08.03.2009 20:02:09');
   ai_0 = f0_7(ai_0, ai_4, ai_8, ai_12, aia_16[1], li_52, -165796510);
   ai_12 = f0_7(ai_12, ai_0, ai_4, ai_8, aia_16[6], li_56, -1069501632);
   ai_8 = f0_7(ai_8, ai_12, ai_0, ai_4, aia_16[11], li_60, 643717713);
   ai_4 = f0_7(ai_4, ai_8, ai_12, ai_0, aia_16[0], li_64, -373897302);
   ai_0 = f0_7(ai_0, ai_4, ai_8, ai_12, aia_16[5], li_52, -701558691);
   ai_12 = f0_7(ai_12, ai_0, ai_4, ai_8, aia_16[10], li_56, 38016083);
   ai_8 = f0_7(ai_8, ai_12, ai_0, ai_4, aia_16[15], li_60, -660478335);
   ai_4 = f0_7(ai_4, ai_8, ai_12, ai_0, aia_16[4], li_64, -405537848);
   ai_0 = f0_7(ai_0, ai_4, ai_8, ai_12, aia_16[9], li_52, 568446438);
   ai_12 = f0_7(ai_12, ai_0, ai_4, ai_8, aia_16[14], li_56, -1019803690);
   ai_8 = f0_7(ai_8, ai_12, ai_0, ai_4, aia_16[3], li_60, -187363961);
   ai_4 = f0_7(ai_4, ai_8, ai_12, ai_0, aia_16[8], li_64, D'14.11.2006 20:11:41');
   ai_0 = f0_7(ai_0, ai_4, ai_8, ai_12, aia_16[13], li_52, -1444681467);
   ai_12 = f0_7(ai_12, ai_0, ai_4, ai_8, aia_16[2], li_56, -51403784);
   ai_8 = f0_7(ai_8, ai_12, ai_0, ai_4, aia_16[7], li_60, D'27.12.2024 20:41:13');
   ai_4 = f0_7(ai_4, ai_8, ai_12, ai_0, aia_16[12], li_64, -1926607734);
   ai_0 = f0_18(ai_0, ai_4, ai_8, ai_12, aia_16[5], li_68, -378558);
   ai_12 = f0_18(ai_12, ai_0, ai_4, ai_8, aia_16[8], li_72, -2022574463);
   ai_8 = f0_18(ai_8, ai_12, ai_0, ai_4, aia_16[11], li_76, D'11.04.2028 03:49:22');
   ai_4 = f0_18(ai_4, ai_8, ai_12, ai_0, aia_16[14], li_80, -35309556);
   ai_0 = f0_18(ai_0, ai_4, ai_8, ai_12, aia_16[1], li_68, -1530992060);
   ai_12 = f0_18(ai_12, ai_0, ai_4, ai_8, aia_16[4], li_72, D'03.05.2010 15:29:13');
   ai_8 = f0_18(ai_8, ai_12, ai_0, ai_4, aia_16[7], li_76, -155497632);
   ai_4 = f0_18(ai_4, ai_8, ai_12, ai_0, aia_16[10], li_80, -1094730640);
   ai_0 = f0_18(ai_0, ai_4, ai_8, ai_12, aia_16[13], li_68, 681279174);
   ai_12 = f0_18(ai_12, ai_0, ai_4, ai_8, aia_16[0], li_72, -358537222);
   ai_8 = f0_18(ai_8, ai_12, ai_0, ai_4, aia_16[3], li_76, -722521979);
   ai_4 = f0_18(ai_4, ai_8, ai_12, ai_0, aia_16[6], li_80, 76029189);
   ai_0 = f0_18(ai_0, ai_4, ai_8, ai_12, aia_16[9], li_68, -640364487);
   ai_12 = f0_18(ai_12, ai_0, ai_4, ai_8, aia_16[12], li_72, -421815835);
   ai_8 = f0_18(ai_8, ai_12, ai_0, ai_4, aia_16[15], li_76, 530742520);
   ai_4 = f0_18(ai_4, ai_8, ai_12, ai_0, aia_16[2], li_80, -995338651);
   ai_0 = f0_2(ai_0, ai_4, ai_8, ai_12, aia_16[0], li_84, -198630844);
   ai_12 = f0_2(ai_12, ai_0, ai_4, ai_8, aia_16[7], li_88, D'16.09.2005 19:23:35');
   ai_8 = f0_2(ai_8, ai_12, ai_0, ai_4, aia_16[14], li_92, -1416354905);
   ai_4 = f0_2(ai_4, ai_8, ai_12, ai_0, aia_16[5], li_96, -57434055);
   ai_0 = f0_2(ai_0, ai_4, ai_8, ai_12, aia_16[12], li_84, D'20.11.2023 14:06:11');
   ai_12 = f0_2(ai_12, ai_0, ai_4, ai_8, aia_16[3], li_88, -1894986606);
   ai_8 = f0_2(ai_8, ai_12, ai_0, ai_4, aia_16[10], li_92, -1051523);
   ai_4 = f0_2(ai_4, ai_8, ai_12, ai_0, aia_16[1], li_96, -2054922799);
   ai_0 = f0_2(ai_0, ai_4, ai_8, ai_12, aia_16[8], li_84, D'12.05.2029 22:49:19');
   ai_12 = f0_2(ai_12, ai_0, ai_4, ai_8, aia_16[15], li_88, -30611744);
   ai_8 = f0_2(ai_8, ai_12, ai_0, ai_4, aia_16[6], li_92, -1560198380);
   ai_4 = f0_2(ai_4, ai_8, ai_12, ai_0, aia_16[13], li_96, D'27.06.2011 07:14:09');
   ai_0 = f0_2(ai_0, ai_4, ai_8, ai_12, aia_16[4], li_84, -145523070);
   ai_12 = f0_2(ai_12, ai_0, ai_4, ai_8, aia_16[11], li_88, -1120210379);
   ai_8 = f0_2(ai_8, ai_12, ai_0, ai_4, aia_16[2], li_92, 718787259);
   ai_4 = f0_2(ai_4, ai_8, ai_12, ai_0, aia_16[9], li_96, -343485551);
   ai_0 = f0_9(ai_0, li_20);
   ai_4 = f0_9(ai_4, li_24);
   ai_8 = f0_9(ai_8, li_28);
   ai_12 = f0_9(ai_12, li_32);
}

int init() {
   IndicatorBuffers(8);
   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexBuffer(0, g_ibuf_88);
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexBuffer(1, g_ibuf_92);
   SetIndexBuffer(2, g_ibuf_96);
   SetIndexBuffer(3, g_ibuf_100);
   SetIndexBuffer(4, g_ibuf_104);
   SetIndexBuffer(5, g_ibuf_108);
   SetIndexBuffer(6, g_ibuf_112);
   SetIndexBuffer(7, g_ibuf_116);
   g_period_120 = MathCeil(OsPeriod / 3);
   if (g_period_120 < 2) g_period_120 = 2;
   IndicatorShortName("Point Zero Oscillator (" + OsPeriod + ")");
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   double ima_16;
   double ima_24;
   double ima_32;
   double ima_40;
   double ld_48;
   double ld_56;
   double ld_64;
   double ld_72;
   double ld_120;
   double ld_128;
   double ld_136;
   double ld_144;
   double ld_152;
   if (Bars <= 10) return (0);
   int li_4 = 0;
   int ind_counted_12 = IndicatorCounted();
   if (CalculateOnBarClose == TRUE) li_4 = 1;
   if (ind_counted_12 < 0) return (-1);
   int li_8 = Bars - 1 - ind_counted_12;
   for (int li_112 = li_8; li_112 >= li_4; li_112--) {
      ima_16 = iMA(NULL, 0, OsPeriod, 0, MODE_SMMA, PRICE_CLOSE, li_112);
      ima_24 = iMA(NULL, 0, OsPeriod, 0, MODE_SMMA, PRICE_LOW, li_112);
      ima_32 = iMA(NULL, 0, OsPeriod, 0, MODE_SMMA, PRICE_OPEN, li_112);
      ima_40 = iMA(NULL, 0, OsPeriod, 0, MODE_SMMA, PRICE_HIGH, li_112);
      ld_48 = (g_ibuf_96[li_112 + 1] + (g_ibuf_100[li_112 + 1])) / 2.0;
      ld_72 = (ima_16 + ima_40 + ima_32 + ima_24) / 4.0;
      ld_56 = MathMax(High[li_112], MathMax(ld_48, ld_72));
      ld_64 = MathMin(Low[li_112], MathMin(ld_48, ld_72));
      if (ld_48 < ld_72) {
         g_ibuf_104[li_112] = ld_64;
         g_ibuf_108[li_112] = ld_56;
      } else {
         g_ibuf_104[li_112] = ld_56;
         g_ibuf_108[li_112] = ld_64;
      }
      g_ibuf_96[li_112] = ld_48;
      g_ibuf_100[li_112] = ld_72;
   }
   for (int bars_116 = Bars; bars_116 >= li_4; bars_116--) {
      g_ibuf_112[bars_116] = iMAOnArray(g_ibuf_96, Bars, g_period_120, 0, MODE_SMMA, bars_116);
      g_ibuf_116[bars_116] = iMAOnArray(g_ibuf_100, Bars, g_period_120, 0, MODE_SMMA, bars_116);
      ld_120 = (g_ibuf_112[bars_116 + 2] + (g_ibuf_116[bars_116 + 2])) / 2.0;
      ld_128 = (g_ibuf_112[bars_116 + 1] + (g_ibuf_116[bars_116 + 1])) / 2.0;
      ld_136 = (g_ibuf_112[bars_116] + g_ibuf_116[bars_116]) / 2.0;
      ld_144 = ld_136 - ld_128;
      ld_152 = ld_128 - ld_120;
      if (ld_144 < ld_152) {
         g_ibuf_92[bars_116] = ld_144;
         g_ibuf_88[bars_116] = 0;
      } else {
         g_ibuf_88[bars_116] = ld_144;
         g_ibuf_92[bars_116] = 0;
      }
   }
   return (0);
}