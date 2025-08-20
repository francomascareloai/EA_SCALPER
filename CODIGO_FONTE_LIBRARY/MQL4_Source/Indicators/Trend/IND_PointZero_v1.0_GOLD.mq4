#property copyright "Copyright © Pointzero-indicator.com"
#property link      "http://www.pointzero-indicator.com"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 LightBlue
#property indicator_color2 LightPink
#property indicator_color3 LightBlue
#property indicator_color4 LightPink
#property indicator_color5 DeepSkyBlue
#property indicator_color6 Tomato
#property indicator_color7 Blue
#property indicator_color8 Tomato

//#include <stdlib.mqh>

int gia_76[] = {33, 42, 39, 40, 41, 59, 58, 64, 38, 61, 43, 36, 47, 63, 35, 91, 93};
extern bool CalculateOnBarClose = TRUE;
extern bool Signals = TRUE;
extern int ChannelPeriod = 5;
extern int ChannelSize = 2;
extern int Sensitivity = 4;
extern bool DisplayAlerts = FALSE;
extern bool EmailAlerts = FALSE;
extern string AlertCaption = "My Alert Name";
double g_ibuf_116[];
double g_ibuf_120[];
double g_ibuf_124[];
double g_ibuf_128[];
double g_ibuf_132[];
double g_ibuf_136[];
double g_ibuf_140[];
double g_ibuf_144[];
int g_count_148 = 0;
int g_count_152 = 0;
int gi_156 = EMPTY_VALUE;
int gi_160 = EMPTY_VALUE;
double gd_164;
double gd_172;
string gs_188;
string gs_196;
datetime g_time_204;
int gi_208 = 1;
int gi_212 = EMPTY_VALUE;
extern string NameSecondIndi = "PointZeroOscillator"; // название 2-ого индикатора

string f0_8(string as_0) {
   int lia_36[16];
   int lia_40[16];
   int lia_52[4];
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
      f0_6(lia_36, ls_64);
      f0_14(lt_20, li_24, li_28, li_32, lia_36);
   }
   ArrayInitialize(lia_40, 0);
   ArrayInitialize(lia_52, 0);
   int li_56 = 0;
   if (li_12 > 0) {
      li_72 = li_12 % 4;
      li_16 = li_12 - li_72;
      if (li_16 > 0) {
         ls_64 = StringSubstr(as_0, count_44 * 64, li_16);
         li_56 = f0_6(lia_40, ls_64);
      }
      for (int index_48 = 0; index_48 < li_72; index_48++) lia_52[index_48] = StringGetChar(as_0, count_44 * 64 + li_16 + index_48);
   }
   lia_52[index_48] = 128;
   lia_40[li_56] = f0_22(lia_52);
   if (li_12 >= 56) {
      f0_14(lt_20, li_24, li_28, li_32, lia_40);
      ArrayInitialize(lia_40, 0);
   }
   lia_40[14] = str_len_8 * 8;
   lia_40[15] = str_len_8 >> 1 & EMPTY_VALUE >> 28;
   f0_14(lt_20, li_24, li_28, li_32, lia_40);
   return (StringConcatenate(f0_7(lt_20), f0_7(li_24), f0_7(li_28), f0_7(li_32)));
}

int f0_9(int ai_0, int ai_4, int ai_8) {
   return (ai_0 & ai_4 | ai_0 & ai_8);
}

int f0_23(int ai_0, int ai_4, int ai_8) {
   return (ai_0 & ai_8 | ai_4 & ai_8);
}

int f0_18(int ai_0, int ai_4, int ai_8) {
   return (ai_0 ^ ai_4 ^ ai_8);
}

int f0_20(int ai_0, int ai_4, int ai_8) {
   return (ai_4 ^ ai_0 | ai_8);
}

int f0_13(int ai_0, int ai_4) {
   int li_ret_8 = ai_0 + ai_4;
   return (li_ret_8);
}

int f0_3(int ai_0, int ai_4, int ai_8, int ai_12, int ai_16, int ai_20, int ai_24) {
   ai_0 = f0_13(ai_0, f0_13(f0_13(f0_9(ai_4, ai_8, ai_12), ai_16), ai_24));
   return (f0_13(f0_12(ai_0, ai_20), ai_4));
}

int f0_11(int ai_0, int ai_4, int ai_8, int ai_12, int ai_16, int ai_20, int ai_24) {
   ai_0 = f0_13(ai_0, f0_13(f0_13(f0_23(ai_4, ai_8, ai_12), ai_16), ai_24));
   return (f0_13(f0_12(ai_0, ai_20), ai_4));
}

int f0_24(int ai_0, int ai_4, int ai_8, int ai_12, int ai_16, int ai_20, int ai_24) {
   ai_0 = f0_13(ai_0, f0_13(f0_13(f0_18(ai_4, ai_8, ai_12), ai_16), ai_24));
   return (f0_13(f0_12(ai_0, ai_20), ai_4));
}

int f0_4(int ai_0, int ai_4, int ai_8, int ai_12, int ai_16, int ai_20, int ai_24) {
   ai_0 = f0_13(ai_0, f0_13(f0_13(f0_20(ai_4, ai_8, ai_12), ai_16), ai_24));
   return (f0_13(f0_12(ai_0, ai_20), ai_4));
}

int f0_12(int ai_0, int ai_4) {
   if (ai_4 == 32) return (ai_0);
   int li_ret_8 = ai_0 << ai_4 | ai_0 >> 1 & EMPTY_VALUE >> (31 - ai_4);
   return (li_ret_8);
}

int f0_6(int &aia_0[16], string as_4) {
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

string f0_7(int ai_0) {
   string ls_12;
   int lia_20[4];
   string str_concat_4 = "";
   lia_20[0] = ai_0 & 255;
   for (int li_24 = 1; li_24 < 4; li_24++) lia_20[li_24] = ai_0 >> 1 & EMPTY_VALUE >> (li_24 * 8 - 1) & 255;
   for (int index_28 = 0; index_28 < 4; index_28++) {
      ls_12 = f0_16(lia_20[index_28]);
      str_concat_4 = StringConcatenate(str_concat_4, ls_12);
   }
   return (str_concat_4);
}

string f0_16(int ai_0) {
   int li_4;
   string str_concat_8;
   for (int count_16 = 0; count_16 < 2; count_16++) {
      li_4 = ai_0 % 16;
      ai_0 = (ai_0 - li_4) / 16;
      str_concat_8 = StringConcatenate(f0_17(li_4), str_concat_8);
   }
   return (str_concat_8);
}

string f0_17(int ai_0) {
   int li_12;
   string ls_4 = "0";
   if (ai_0 < 10) li_12 = ai_0 + 48;
   else li_12 = ai_0 + 97 - 10;
   return (StringSetChar(ls_4, 0, li_12));
}

int f0_22(int aia_0[4]) {
   return (aia_0[0] | (aia_0[1] * 256) | aia_0[2] << 16 | aia_0[3] << 24);
}

void f0_14(int &ai_0, int &ai_4, int &ai_8, int &ai_12, int aia_16[16]) {
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
   ai_0 = f0_3(ai_0, ai_4, ai_8, ai_12, aia_16[0], li_36, -680876936);
   ai_12 = f0_3(ai_12, ai_0, ai_4, ai_8, aia_16[1], li_40, -389564586);
   ai_8 = f0_3(ai_8, ai_12, ai_0, ai_4, aia_16[2], li_44, 606105819);
   ai_4 = f0_3(ai_4, ai_8, ai_12, ai_0, aia_16[3], li_48, -1044525330);
   ai_0 = f0_3(ai_0, ai_4, ai_8, ai_12, aia_16[4], li_36, -176418897);
   ai_12 = f0_3(ai_12, ai_0, ai_4, ai_8, aia_16[5], li_40, D'11.01.2008 20:40:26');
   ai_8 = f0_3(ai_8, ai_12, ai_0, ai_4, aia_16[6], li_44, -1473231341);
   ai_4 = f0_3(ai_4, ai_8, ai_12, ai_0, aia_16[7], li_48, -45705983);
   ai_0 = f0_3(ai_0, ai_4, ai_8, ai_12, aia_16[8], li_36, D'02.02.2026 13:30:16');
   ai_12 = f0_3(ai_12, ai_0, ai_4, ai_8, aia_16[9], li_40, -1958414417);
   ai_8 = f0_3(ai_8, ai_12, ai_0, ai_4, aia_16[10], li_44, -42063);
   ai_4 = f0_3(ai_4, ai_8, ai_12, ai_0, aia_16[11], li_48, -1990404162);
   ai_0 = f0_3(ai_0, ai_4, ai_8, ai_12, aia_16[12], li_36, D'09.03.2027 15:48:02');
   ai_12 = f0_3(ai_12, ai_0, ai_4, ai_8, aia_16[13], li_40, -40341101);
   ai_8 = f0_3(ai_8, ai_12, ai_0, ai_4, aia_16[14], li_44, -1502002290);
   ai_4 = f0_3(ai_4, ai_8, ai_12, ai_0, aia_16[15], li_48, D'08.03.2009 20:02:09');
   ai_0 = f0_11(ai_0, ai_4, ai_8, ai_12, aia_16[1], li_52, -165796510);
   ai_12 = f0_11(ai_12, ai_0, ai_4, ai_8, aia_16[6], li_56, -1069501632);
   ai_8 = f0_11(ai_8, ai_12, ai_0, ai_4, aia_16[11], li_60, 643717713);
   ai_4 = f0_11(ai_4, ai_8, ai_12, ai_0, aia_16[0], li_64, -373897302);
   ai_0 = f0_11(ai_0, ai_4, ai_8, ai_12, aia_16[5], li_52, -701558691);
   ai_12 = f0_11(ai_12, ai_0, ai_4, ai_8, aia_16[10], li_56, 38016083);
   ai_8 = f0_11(ai_8, ai_12, ai_0, ai_4, aia_16[15], li_60, -660478335);
   ai_4 = f0_11(ai_4, ai_8, ai_12, ai_0, aia_16[4], li_64, -405537848);
   ai_0 = f0_11(ai_0, ai_4, ai_8, ai_12, aia_16[9], li_52, 568446438);
   ai_12 = f0_11(ai_12, ai_0, ai_4, ai_8, aia_16[14], li_56, -1019803690);
   ai_8 = f0_11(ai_8, ai_12, ai_0, ai_4, aia_16[3], li_60, -187363961);
   ai_4 = f0_11(ai_4, ai_8, ai_12, ai_0, aia_16[8], li_64, D'14.11.2006 20:11:41');
   ai_0 = f0_11(ai_0, ai_4, ai_8, ai_12, aia_16[13], li_52, -1444681467);
   ai_12 = f0_11(ai_12, ai_0, ai_4, ai_8, aia_16[2], li_56, -51403784);
   ai_8 = f0_11(ai_8, ai_12, ai_0, ai_4, aia_16[7], li_60, D'27.12.2024 20:41:13');
   ai_4 = f0_11(ai_4, ai_8, ai_12, ai_0, aia_16[12], li_64, -1926607734);
   ai_0 = f0_24(ai_0, ai_4, ai_8, ai_12, aia_16[5], li_68, -378558);
   ai_12 = f0_24(ai_12, ai_0, ai_4, ai_8, aia_16[8], li_72, -2022574463);
   ai_8 = f0_24(ai_8, ai_12, ai_0, ai_4, aia_16[11], li_76, D'11.04.2028 03:49:22');
   ai_4 = f0_24(ai_4, ai_8, ai_12, ai_0, aia_16[14], li_80, -35309556);
   ai_0 = f0_24(ai_0, ai_4, ai_8, ai_12, aia_16[1], li_68, -1530992060);
   ai_12 = f0_24(ai_12, ai_0, ai_4, ai_8, aia_16[4], li_72, D'03.05.2010 15:29:13');
   ai_8 = f0_24(ai_8, ai_12, ai_0, ai_4, aia_16[7], li_76, -155497632);
   ai_4 = f0_24(ai_4, ai_8, ai_12, ai_0, aia_16[10], li_80, -1094730640);
   ai_0 = f0_24(ai_0, ai_4, ai_8, ai_12, aia_16[13], li_68, 681279174);
   ai_12 = f0_24(ai_12, ai_0, ai_4, ai_8, aia_16[0], li_72, -358537222);
   ai_8 = f0_24(ai_8, ai_12, ai_0, ai_4, aia_16[3], li_76, -722521979);
   ai_4 = f0_24(ai_4, ai_8, ai_12, ai_0, aia_16[6], li_80, 76029189);
   ai_0 = f0_24(ai_0, ai_4, ai_8, ai_12, aia_16[9], li_68, -640364487);
   ai_12 = f0_24(ai_12, ai_0, ai_4, ai_8, aia_16[12], li_72, -421815835);
   ai_8 = f0_24(ai_8, ai_12, ai_0, ai_4, aia_16[15], li_76, 530742520);
   ai_4 = f0_24(ai_4, ai_8, ai_12, ai_0, aia_16[2], li_80, -995338651);
   ai_0 = f0_4(ai_0, ai_4, ai_8, ai_12, aia_16[0], li_84, -198630844);
   ai_12 = f0_4(ai_12, ai_0, ai_4, ai_8, aia_16[7], li_88, D'16.09.2005 19:23:35');
   ai_8 = f0_4(ai_8, ai_12, ai_0, ai_4, aia_16[14], li_92, -1416354905);
   ai_4 = f0_4(ai_4, ai_8, ai_12, ai_0, aia_16[5], li_96, -57434055);
   ai_0 = f0_4(ai_0, ai_4, ai_8, ai_12, aia_16[12], li_84, D'20.11.2023 14:06:11');
   ai_12 = f0_4(ai_12, ai_0, ai_4, ai_8, aia_16[3], li_88, -1894986606);
   ai_8 = f0_4(ai_8, ai_12, ai_0, ai_4, aia_16[10], li_92, -1051523);
   ai_4 = f0_4(ai_4, ai_8, ai_12, ai_0, aia_16[1], li_96, -2054922799);
   ai_0 = f0_4(ai_0, ai_4, ai_8, ai_12, aia_16[8], li_84, D'12.05.2029 22:49:19');
   ai_12 = f0_4(ai_12, ai_0, ai_4, ai_8, aia_16[15], li_88, -30611744);
   ai_8 = f0_4(ai_8, ai_12, ai_0, ai_4, aia_16[6], li_92, -1560198380);
   ai_4 = f0_4(ai_4, ai_8, ai_12, ai_0, aia_16[13], li_96, D'27.06.2011 07:14:09');
   ai_0 = f0_4(ai_0, ai_4, ai_8, ai_12, aia_16[4], li_84, -145523070);
   ai_12 = f0_4(ai_12, ai_0, ai_4, ai_8, aia_16[11], li_88, -1120210379);
   ai_8 = f0_4(ai_8, ai_12, ai_0, ai_4, aia_16[2], li_92, 718787259);
   ai_4 = f0_4(ai_4, ai_8, ai_12, ai_0, aia_16[9], li_96, -343485551);
   ai_0 = f0_13(ai_0, li_20);
   ai_4 = f0_13(ai_4, li_24);
   ai_8 = f0_13(ai_8, li_28);
   ai_12 = f0_13(ai_12, li_32);
}

int init() {
   string lsa_4[256];
   IndicatorBuffers(8);
   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexBuffer(0, g_ibuf_116);
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexBuffer(1, g_ibuf_120);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(2, g_ibuf_124);
   SetIndexStyle(3, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(3, g_ibuf_128);
   SetIndexStyle(4, DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexBuffer(4, g_ibuf_132);
   SetIndexStyle(5, DRAW_HISTOGRAM, STYLE_SOLID);
   SetIndexBuffer(5, g_ibuf_136);
   SetIndexStyle(6, DRAW_ARROW, STYLE_DOT);
   SetIndexArrow(6, 233);
   SetIndexBuffer(6, g_ibuf_140);
   SetIndexStyle(7, DRAW_ARROW, STYLE_DOT);
   SetIndexArrow(7, 234);
   SetIndexBuffer(7, g_ibuf_144);
   IndicatorShortName("Point Zero");
   switch (Sensitivity) {
   case 5:
      gd_164 = 0.05;
      gd_172 = 0.5;
      break;
   case 4:
      gd_164 = 0.04;
      gd_172 = 0.4;
      break;
   case 3:
      gd_164 = 0.03;
      gd_172 = 0.3;
      break;
   case 2:
      gd_164 = 0.02;
      gd_172 = 0.2;
      break;
   case 1:
      gd_164 = 0.01;
      gd_172 = 0.1;
      break;
   default:
      gd_164 = 0.05;
      gd_172 = 0.5;
   }
   if (ChannelSize < 1) ChannelSize = 1;
   for (int index_8 = 0; index_8 < 256; index_8++) lsa_4[index_8] = CharToStr(index_8);
   gs_188 = lsa_4[104] + lsa_4[116] + lsa_4[116] + lsa_4[112] + lsa_4[58] + lsa_4[47] + lsa_4[47] + lsa_4[119] + lsa_4[119] + lsa_4[119] + lsa_4[46] + lsa_4[112] + lsa_4[111] +
      lsa_4[105] + lsa_4[110] + lsa_4[116] + lsa_4[122] + lsa_4[101] + lsa_4[114] + lsa_4[111] + lsa_4[45] + lsa_4[105] + lsa_4[110] + lsa_4[100] + lsa_4[105] + lsa_4[99] +
      lsa_4[97] + lsa_4[116] + lsa_4[111] + lsa_4[114] + lsa_4[46] + lsa_4[99] + lsa_4[111] + lsa_4[109];
   gs_196 = lsa_4[67] + lsa_4[111] + lsa_4[112] + lsa_4[121] + lsa_4[114] + lsa_4[105] + lsa_4[103] + lsa_4[104] + lsa_4[116] + lsa_4[32] + lsa_4[169] + lsa_4[32] + lsa_4[80] +
      lsa_4[111] + lsa_4[105] + lsa_4[110] + lsa_4[116] + lsa_4[122] + lsa_4[101] + lsa_4[114] + lsa_4[111] + lsa_4[45] + lsa_4[105] + lsa_4[110] + lsa_4[100] + lsa_4[105] +
      lsa_4[99] + lsa_4[97] + lsa_4[116] + lsa_4[111] + lsa_4[114] + lsa_4[46] + lsa_4[99] + lsa_4[111] + lsa_4[109];
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   int li_0;
   double ld_20;
   double ld_28;
   double icustom_36;
   double icustom_44;
   double isar_52;
   double ld_60;
   double ld_68;
   double ld_76;
   double ld_84;
   double ihigh_92;
   double ilow_100;
   double iclose_108;
   double iopen_116;
   double iatr_124;
   double ld_132;
   double ld_140;
   double ld_148;
   string ls_156;
   string ls_164;
   if (Bars <= 10) return (0);
   int li_4 = 0;
   int ind_counted_8 = IndicatorCounted();
   int li_12 = Bars - 1 - ind_counted_8;
   if (ind_counted_8 < 0) return (-1);
   if (CalculateOnBarClose == 1) li_4 = 1;
   for (int li_16 = li_12; li_16 >= li_4; li_16--) {
      ld_20 = f0_10(li_16);
      ld_28 = f0_5(li_16);
      icustom_36 = iCustom(Symbol(), 0, NameSecondIndi, CalculateOnBarClose, ChannelPeriod, 6, li_16);
      icustom_44 = iCustom(Symbol(), 0, NameSecondIndi, CalculateOnBarClose, ChannelPeriod, 7, li_16);
      isar_52 = iSAR(Symbol(), 0, gd_164, gd_172, li_16);
      ld_60 = f0_19(li_16, 0);
      ld_68 = f0_0(li_16, 0);
      ld_76 = f0_21(li_16, 0);
      ld_84 = f0_1(li_16, 0);
      ihigh_92 = iHigh(Symbol(), 0, li_16);
      ilow_100 = iLow(Symbol(), 0, li_16);
      iclose_108 = iClose(Symbol(), 0, li_16);
      iopen_116 = iOpen(Symbol(), 0, li_16);
      iatr_124 = iATR(Symbol(), 0, 30, li_16);
      ld_132 = iatr_124 / 10.0 * ChannelSize;
      g_ibuf_116[li_16] = EMPTY_VALUE;
      g_ibuf_120[li_16] = EMPTY_VALUE;
      g_ibuf_124[li_16] = EMPTY_VALUE;
      g_ibuf_128[li_16] = EMPTY_VALUE;
      g_ibuf_132[li_16] = EMPTY_VALUE;
      g_ibuf_136[li_16] = EMPTY_VALUE;
      g_ibuf_140[li_16] = EMPTY_VALUE;
      g_ibuf_144[li_16] = EMPTY_VALUE;
      gi_212 = EMPTY_VALUE;
      gi_156 = EMPTY_VALUE;
      if (icustom_36 > icustom_44) {
         ld_140 = icustom_36 + ld_132;
         ld_148 = icustom_44 - ld_132;
         if (ld_28 < ld_20 && isar_52 > ihigh_92) {
            gi_156 = 1;
            if (li_16 > 0) {
               g_count_152++;
               g_count_148 = 0;
            }
            ls_156 = "Strong Downtrend";
            ls_164 = "SELL @ Stop-loss at " + DoubleToStr(isar_52, Digits);
            if (gi_160 != TRUE && Signals == TRUE) {
               g_ibuf_144[li_16 + 2] = EMPTY_VALUE;
               g_ibuf_144[li_16 + 3] = EMPTY_VALUE;
               if (ld_60 != 0.0) g_ibuf_144[li_16 + 2] = ld_60;
               else {
                  if (ld_76 != 0.0) g_ibuf_144[li_16 + 3] = ld_76;
                  else g_ibuf_144[li_16 + 2] = isar_52;
               }
               if (li_16 > 0) {
                  gi_212 = 1;
                  gi_160 = TRUE;
               }
            }
         } else {
            ls_164 = "Trail stop-loss to " + DoubleToStr(icustom_44, Digits);
            ls_156 = "Downtrend";
            if (li_16 > 0) {
               g_count_152 = 0;
               g_count_148 = 0;
            }
         }
         if (gi_156 == 1 && g_count_152 <= 5) {
            g_ibuf_120[li_16] = 0;
            g_ibuf_116[li_16] = 0;
            g_ibuf_136[li_16] = ld_140;
            g_ibuf_132[li_16] = ld_148;
         } else {
            g_ibuf_120[li_16] = ld_140;
            g_ibuf_116[li_16] = ld_148;
            g_ibuf_132[li_16] = 0;
            g_ibuf_136[li_16] = 0;
         }
         g_ibuf_128[li_16] = ld_148;
         g_ibuf_124[li_16] = ld_140;
      } else {
         ld_140 = icustom_36 - ld_132;
         ld_148 = icustom_44 + ld_132;
         if (ld_28 > ld_20 && isar_52 < ilow_100) {
            gi_156 = 0;
            if (li_16 > 0) {
               g_count_148++;
               g_count_152 = 0;
            }
            ls_156 = "Strong Uptrend";
            ls_164 = "BUY @ Stop-loss at " + DoubleToStr(isar_52, Digits);
            if (gi_160 != FALSE && Signals == TRUE) {
               g_ibuf_140[li_16 + 2] = EMPTY_VALUE;
               g_ibuf_140[li_16 + 3] = EMPTY_VALUE;
               if (ld_68 != 0.0) g_ibuf_140[li_16 + 2] = ld_68;
               else {
                  if (ld_84 != 0.0) g_ibuf_140[li_16 + 3] = ld_84;
                  else g_ibuf_140[li_16 + 2] = isar_52;
               }
               if (li_16 > 0) {
                  gi_212 = 0;
                  gi_160 = FALSE;
               }
            }
         } else {
            ls_164 = "Trail stop-loss to " + DoubleToStr(icustom_36, Digits);
            ls_156 = "Uptrend";
            if (li_16 > 0) {
               g_count_152 = 0;
               g_count_148 = 0;
            }
         }
         if (gi_156 == 0 && g_count_148 <= 5) {
            g_ibuf_120[li_16] = 0;
            g_ibuf_116[li_16] = 0;
            g_ibuf_136[li_16] = ld_140;
            g_ibuf_132[li_16] = ld_148;
         } else {
            g_ibuf_120[li_16] = ld_140;
            g_ibuf_116[li_16] = ld_148;
            g_ibuf_132[li_16] = 0;
            g_ibuf_136[li_16] = 0;
         }
         g_ibuf_128[li_16] = ld_140;
         g_ibuf_124[li_16] = ld_148;
      }
      Comment("\n---\n" + "POINT ZERO INDICATOR\n" + "---\n" + "Trend: " + ls_156 
         + "\n" 
         + "Suggestion: " + ls_164 
      + "\n---\n" + gs_196);
   }
   if (g_time_204 != Time[0]) {
      if (gi_212 == 0 && gi_208 == FALSE) {
         if (DisplayAlerts == TRUE) Alert("Point Zero (" + AlertCaption + ") [" + Symbol() + "] Change to Uptrend");
         if (EmailAlerts == TRUE) SendMail("Point Zero (" + AlertCaption + ") [" + Symbol() + "]", Symbol() + ": Change to Uptrend");
      } else {
         if (gi_212 == 1 && gi_208 == FALSE) {
            if (DisplayAlerts == TRUE) Alert("Point Zero (" + AlertCaption + ") [" + Symbol() + "] Change to Downtrend");
            if (EmailAlerts == TRUE) SendMail("Point Zero (" + AlertCaption + ") [" + Symbol() + "]", Symbol() + ": Change to Downtrend");
         }
      }
      g_time_204 = Time[0];
      gi_208 = FALSE;
   }
   return (0);
}

double f0_10(int ai_0 = 1) {
   return (iCustom(Symbol(), 0, "Heiken Ashi", 2, ai_0));
}

double f0_5(int ai_0 = 1) {
   return (iCustom(Symbol(), 0, "Heiken Ashi", 3, ai_0));
}

double f0_19(int ai_0 = 1, bool ai_4 = FALSE) {
   double ihigh_8 = iHigh(Symbol(), 0, ai_0 + 2);
   double ihigh_16 = iHigh(Symbol(), 0, ai_0);
   double ihigh_24 = iHigh(Symbol(), 0, ai_0 + 1);
   double ihigh_32 = iHigh(Symbol(), 0, ai_0 + 3);
   double ihigh_40 = iHigh(Symbol(), 0, ai_0 + 4);
   double ilow_48 = iLow(Symbol(), 0, ai_0);
   double ilow_56 = iLow(Symbol(), 0, ai_0 + 3);
   if (ihigh_8 > ihigh_16 && ihigh_8 > ihigh_24 && ihigh_8 > ihigh_32 && ihigh_8 > ihigh_40 && ai_4 == FALSE || ilow_48 < ilow_56) return (ihigh_8);
   return (0);
}

double f0_0(int ai_0 = 1, bool ai_4 = FALSE) {
   double ilow_8 = iLow(Symbol(), 0, ai_0 + 2);
   double ilow_16 = iLow(Symbol(), 0, ai_0);
   double ilow_24 = iLow(Symbol(), 0, ai_0 + 1);
   double ilow_32 = iLow(Symbol(), 0, ai_0 + 3);
   double ilow_40 = iLow(Symbol(), 0, ai_0 + 4);
   double ihigh_48 = iHigh(Symbol(), 0, ai_0);
   double ihigh_56 = iHigh(Symbol(), 0, ai_0 + 3);
   if (ilow_8 < ilow_16 && ilow_8 < ilow_24 && ilow_8 < ilow_32 && ilow_8 < ilow_40 && ai_4 == FALSE || ihigh_48 > ihigh_56) return (ilow_8);
   return (0);
}

double f0_21(int ai_0 = 1, bool ai_4 = FALSE) {
   double ihigh_8 = iHigh(Symbol(), 0, ai_0 + 3);
   double ihigh_16 = iHigh(Symbol(), 0, ai_0);
   double ihigh_24 = iHigh(Symbol(), 0, ai_0 + 1);
   double ihigh_32 = iHigh(Symbol(), 0, ai_0 + 2);
   double ihigh_40 = iHigh(Symbol(), 0, ai_0 + 4);
   double ihigh_48 = iHigh(Symbol(), 0, ai_0 + 5);
   double ihigh_56 = iHigh(Symbol(), 0, ai_0 + 6);
   double ilow_64 = iLow(Symbol(), 0, ai_0);
   double ilow_72 = iLow(Symbol(), 0, ai_0 + 5);
   if (ihigh_8 > ihigh_16 && ihigh_8 > ihigh_24 && ihigh_8 > ihigh_32 && ihigh_8 > ihigh_40 && ihigh_8 > ihigh_48 && ihigh_8 > ihigh_56 && ai_4 == FALSE || ilow_64 < ilow_72) return (ihigh_8);
   return (0);
}

double f0_1(int ai_0 = 1, bool ai_4 = FALSE) {
   double ilow_8 = iLow(Symbol(), 0, ai_0 + 3);
   double ilow_16 = iLow(Symbol(), 0, ai_0);
   double ilow_24 = iLow(Symbol(), 0, ai_0 + 1);
   double ilow_32 = iLow(Symbol(), 0, ai_0 + 2);
   double ilow_40 = iLow(Symbol(), 0, ai_0 + 4);
   double ilow_48 = iLow(Symbol(), 0, ai_0 + 5);
   double ilow_56 = iLow(Symbol(), 0, ai_0 + 6);
   double ihigh_64 = iHigh(Symbol(), 0, ai_0);
   double ihigh_72 = iHigh(Symbol(), 0, ai_0 + 5);
   if (ilow_8 < ilow_16 && ilow_8 < ilow_24 && ilow_8 < ilow_32 && ilow_8 < ilow_40 && ilow_8 < ilow_48 && ilow_8 < ilow_56 && ai_4 == FALSE || ihigh_64 > ihigh_72) return (ilow_8);
   return (0);
}