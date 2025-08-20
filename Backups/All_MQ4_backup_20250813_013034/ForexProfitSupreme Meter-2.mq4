//+------------------------------------------------------------------+
//|                                     ForexProfitSupreme Meter.mq4 |
//|                               Copyright © 2015, MQL Software Co. |
//|                            programmed by Gelfrad Burharden, 2015 |
//|                    http://www.odesk.com/users/~~a2ddafb47c4d4561 |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2013, forexprofitsupreme"
#property link      "http://www.forexprofitsupreme.com"

#property indicator_chart_window

extern bool CurrenciesWindowBelowTable = FALSE;
extern bool ShowCurrencies = TRUE;
extern bool ShowCurrenciesSorted = TRUE;
extern bool ShowSymbolsSorted = TRUE;
extern string SymbolPrefix = "";
extern string DontShowThisPairs = "NZDCHF";
extern color HandleBackGroundColor = LightSlateGray;
extern color DataTableBackGroundColor_1 = LightSteelBlue;
extern color DataTableBackGroundColor_2 = Lavender;
extern color CurrencysBackGroundColor = LightSlateGray;
extern color HandleTextColor = White;
extern color DataTableTextColor = Black;
extern color CurrencysTextColor = White;
extern color TrendUpArrowsColor = MediumBlue;
extern color TrendDownArrowsColor = Red;

int gia_144[] = {255, 17919, 5275647, 65535, 3145645, 65280};
string gs_148;
int gia_156[10];
int gia_168[10];
int gia_172[21] = {15, 23, 31, 35, 43, 47, 55, 67, 75, 83, 87, 91, 95, 99, 119, 123, 127, 143, 148, 156, 164};
int gia_176[21] = {11, 17, 23, 26, 32, 35, 41, 50, 56, 62, 65, 68, 71, 74, 89, 92, 95, 107, 110, 116, 122};
int gia_180[21] = {4, 5, 6, 7, 9, 10, 12, 15, 17, 19, 20, 21, 22, 23, 28, 29, 30, 34, 36, 38, 40};
int gia_184[21] = {-3, -2, -1, -1, -2, 0, -1, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0};
string gsa_188[8] = {"USD", "EUR", "GBP", "CHF", "JPY", "CAD", "AUD", "NZD"};
int gia_192[8] = {9639167, 16711680, 16711680, 65535, 65535, 9639167, 16711680, 16711680};

string symbBuff[28] = {"EURUSD", "GBPUSD", "AUDUSD", "USDJPY", "USDCHF", "USDCAD", "EURAUD", "EURCAD", "EURCHF", "EURGBP", "EURJPY", "GBPJPY", "GBPCHF", "NZDUSD", "AUDCAD", "AUDJPY", "CHFJPY",
      "AUDNZD", "NZDJPY", "NZDCAD", "NZDCHF", "GBPNZD", "EURNZD", "GBPCAD", "GBPAUD", "AUDCHF", "CADCHF", "CADJPY"};

string workSymbBuf[28];

int gia_208[6];
double gda_212[28][3];
int g_color_216;
int g_color_220;
int g_color_224;
int g_color_228;
int g_color_236;
int g_color_240;
int g_color_244;
int g_color_248;
int g_color_252;
string gs_256 = "";
bool gi_264 = FALSE;
int gi_268;

int f0_6(string as_0, int ai_8, int ai_12, int ai_16, int ai_20 = 1, int ai_24 = 1, int ai_28 = 0, int ai_32 = 0, int ai_36 = 0, int ai_40 = 0, int ai_44 = 0, string as_48 = "", int ai_56 = 16777215) {
   int li_60;
   int li_80;
   string ls_112;
   int li_120;
   if (ai_40 != 0 && ai_40 != 1) ai_40 = 0;
   if (ai_44 < 0) ai_44 = 0;
   if (as_48 != "") {
      if (f0_9(as_48)) {
         ai_12 += gia_156[0];
         ai_16 += gia_156[1];
         ai_40 = gia_156[6];
         ai_44 = gia_156[8];
         ai_32 += gia_156[4];
         li_60 = gia_156[9] + 1;
      }
   }
   gia_168[0] = ai_12;
   gia_168[1] = ai_16;
   gia_168[2] = ai_12 + ai_20 * gia_172[ai_28] - 1;
   gia_168[3] = ai_16 + ai_24 * gia_172[ai_28] - (ai_24 * 2 - 1);
   gia_168[6] = ai_32;
   gia_168[9] = ai_8;
   int li_84 = 1;
   int li_88 = gia_172[ai_28] - 2;
   int li_92 = gia_176[ai_28];
   string ls_96 = "";
   string ls_104 = "g";
   if (ai_20 == 1 && ai_24 == 1) {
      gia_168[4] = 0;
      gia_168[5] = 0;
      gia_168[7] = li_60;
      gia_168[8] = li_60;
      ls_96 = f0_7(as_0, gia_168, as_48);
      if (!f0_4(ls_96, gia_168[0], gia_168[1] + gia_184[ai_28], ls_104, li_92, ai_40, ai_56, ai_44)) Print(GetLastError());
      if (ai_36 == ai_56) return (0);
      gia_168[4] = 0;
      gia_168[5] = 1;
      gia_168[7] = li_60;
      gia_168[8] = li_60 + 1;
      ls_96 = f0_7(as_0, gia_168, as_48);
      if (!f0_4(ls_96, gia_168[0] + li_84, gia_168[1] + li_84 + gia_184[ai_28], ls_104, li_92 - li_84, ai_40, ai_36, ai_44)) Print(GetLastError());
   } else {
      for (int li_64 = 1; li_64 < ai_20; li_64++) ls_104 = ls_104 + "g";
      for (int count_68 = 0; count_68 < ai_24; count_68++) {
         gia_168[4] = li_80 / 10;
         gia_168[5] = li_80 % 10;
         gia_168[7] = li_60;
         gia_168[8] = li_60;
         ls_96 = f0_7(as_0, gia_168, as_48);
         if (!f0_4(ls_96, gia_168[0], gia_168[1] + li_88 * count_68 + gia_184[ai_28], ls_104, li_92, ai_40, ai_56, ai_44)) Print(GetLastError());
         li_80++;
      }
      if (ai_36 == ai_56) return (0);
      gia_168[7] = li_60;
      gia_168[8] = li_60 + 1;
      for (count_68 = 0; count_68 < ai_24; count_68++) {
         if (ai_20 > 1) {
            gia_168[4] = li_80 / 10;
            gia_168[5] = li_80 % 10;
            ls_96 = f0_7(as_0, gia_168, as_48);
            ls_112 = "g";
            li_120 = ai_20 / 10 + 1;
            for (int count_72 = 0; count_72 < li_120; count_72++) ls_112 = ls_112 + "g";
            if (!f0_4(ls_96, gia_168[0] + li_84, gia_168[1] + (li_88 * count_68 - count_68) + gia_184[ai_28] + ai_24, ls_112, li_92 - li_84, ai_40, ai_36, ai_44)) Print(GetLastError());
            li_80++;
         }
         gia_168[4] = li_80 / 10;
         gia_168[5] = li_80 % 10;
         ls_96 = f0_7(as_0, gia_168, as_48);
         if (!f0_4(ls_96, gia_168[0] + (ai_20 * 2 - li_84), gia_168[1] + (li_88 * count_68 - count_68) + gia_184[ai_28] + ai_24, ls_104, li_92 - li_84, ai_40, ai_36, ai_44)) Print(GetLastError());
         li_80++;
      }
      if (ai_24 < 2) return (0);
      for (count_72 = 0; count_72 <= ai_24 / li_88; count_72++) {
         gia_168[4] = li_80 / 10;
         gia_168[5] = li_80 % 10;
         ls_96 = f0_7(as_0, gia_168, as_48);
         if (!f0_4(ls_96, gia_168[0] + ai_20 * 2 - li_84, gia_168[1] + li_84 + gia_184[ai_28] + (li_88 - 1) * count_72, ls_104, li_92 - li_84, ai_40, ai_36, ai_44)) Print(GetLastError());
         li_80++;
         if (ai_20 > 1) {
            gia_168[4] = li_80 / 10;
            gia_168[5] = li_80 % 10;
            ls_96 = f0_7(as_0, gia_168, as_48);
            ls_112 = "g";
            li_120 = ai_20 / 10 + 1;
            for (int count_76 = 0; count_76 < li_120; count_76++) ls_112 = ls_112 + "g";
            if (!f0_4(ls_96, gia_168[0] + li_84, gia_168[1] + li_84 + gia_184[ai_28] + (li_88 - 1) * count_72, ls_112, li_92 - li_84, ai_40, ai_36, ai_44)) Print(GetLastError());
            li_80++;
         }
      }
   }
   return (0);
}

int f0_2(string as_0, string as_8, int ai_16, string as_20, string as_28, int ai_36, bool ai_40 = TRUE, int ai_44 = 0, int ai_48 = 0, int ai_52 = 0, int ai_56 = 0, int ai_60 = 0, int ai_64 = 0, int ai_68 = 0) {
   int li_unused_108;
   double ld_112;
   double ld_120;
   int lia_72[19] = {10, 14, 20, 26, 32, 35, 41, 50, 56, 62, 65, 68, 71, 74, 77, 86, 89, 92, 95};
   int lia_76[7] = {0, 3, 2, 3, 2, 3, 4};
   int li_80 = 0;
   int li_84 = 0;
   int li_88 = 0;
   int li_unused_92 = 0;
   int li_96 = 0;
   int li_100 = 0;
   int li_unused_104 = 0;
   if (as_8 != "") {
      if (f0_9(as_8)) {
         ai_60 = gia_156[6];
         ai_64 = gia_156[8];
         li_80 = gia_156[0];
         li_84 = gia_156[1];
         li_88 = gia_156[2];
         li_96 += gia_156[4] + 1;
         li_100 = gia_156[9] + 1;
         ai_60 = gia_156[6];
         ai_64 = gia_156[8];
         li_unused_108 = gia_156[5];
         if (ai_56 == 0) ai_56 = lia_72[ai_52];
         if (ai_40) {
            ld_112 = StringLen(as_20) * ai_56 / 1.6;
            ld_120 = li_88 - li_80;
            ai_44 = li_80 + (ld_120 - ld_112) / 2.0 + ai_44;
            ai_48 = li_84 + lia_76[ai_52];
            if (as_28 == "Webdings") {
               if (ai_52 == 0) {
                  ai_56 = 11;
                  ai_44 = li_80;
                  ai_48 = li_84 - 3;
               } else {
                  ai_56 = 20;
                  ai_44 = li_80 - 2;
                  ai_48 = li_84 - 4;
               }
            } else {
               if (as_28 == "Wingdings") {
                  ai_56 = 11;
                  ai_44 = li_80 + 1;
                  ai_48 = li_84 + 2;
               }
            }
         } else {
            ai_44 += li_80;
            ai_48 += li_84;
         }
      }
   }
   gia_168[0] = ai_44;
   gia_168[1] = ai_48;
   gia_168[6] = li_96;
   gia_168[7] = li_100;
   gia_168[8] = li_100;
   gia_168[9] = ai_16;
   as_0 = f0_7(as_0, gia_168, as_8);
   if (!f0_4(as_0, ai_44, ai_48, as_20, ai_56, ai_60, ai_36, ai_64, as_28, ai_68)) return (GetLastError());
   return (0);
}

int f0_10(string as_0, int ai_8, int ai_12, int ai_16, int ai_20 = 3, int ai_24 = 1, int ai_28 = 1, int ai_32 = 0, int ai_36 = 7346457, int ai_40 = 0, int ai_44 = 0, string as_48 = "", int ai_56 = 16777215) {
   string ls_60;
   string ls_unused_68;
   int li_76;
   int li_80;
   int li_84;
   if (ai_8 < 70 || ai_8 > 75) return (1);
   if (ai_36 == 0) ai_36 = 9109504;
   if (ai_28 <= 1) ai_28 = 1;
   switch (ai_8) {
   case 70:
      if (ai_20 < 3) ai_20 = 3;
      f0_6(as_0, ai_8, ai_12, ai_16, ai_20, ai_24, ai_28, ai_32, ai_36, ai_40, ai_44, as_48, ai_56);
      break;
   case 71:
      if (ai_20 < 3) ai_20 = 3;
      f0_6(as_0, ai_8, ai_12, ai_16, ai_20, ai_24, ai_28, ai_32, ai_36, ai_40, ai_44, as_48, ai_56);
      if (ai_40 == 0) li_76 = gia_168[2] - gia_168[0] - (7 * (ai_28 - 1) + 19);
      else li_76 = 4;
      ls_60 = StringSubstr(as_0, 0, 2) + "CL" + StringSubstr(as_0, 2);
      f0_6(ls_60, 52, li_76, 4, 1, 1, ai_28 - 1, ai_32 + 1, ai_36, ai_40, ai_44, as_0, ai_56);
      f0_2("Clt", ls_60, 69, StringSetChar("", 0, 'r'), "Webdings", ai_56, 1, 4, 4, ai_28 - 1);
      break;
   case 72:
      if (ai_20 < 3) ai_20 = 3;
      f0_6(as_0, ai_8, ai_12, ai_16, ai_20, ai_24, ai_28, ai_32, ai_36, ai_40, ai_44, as_48, ai_56);
      if (ai_40 == 0) li_76 = gia_168[2] - gia_168[0] - (7 * (ai_28 - 1) + 19);
      else li_76 = 4;
      ls_60 = StringSubstr(as_0, 0, 2) + "HD" + StringSubstr(as_0, 2);
      f0_6(ls_60, 53, li_80, 4, 1, 1, ai_28 - 1, ai_32 + 1, ai_36, ai_40, ai_44, as_0, ai_56);
      f0_2("Hdt", ls_60, 69, StringSetChar("", 0, '0'), "Webdings", ai_56, 1, 4, 4, ai_28 - 1);
      break;
   case 73:
      if (ai_20 < 3) ai_20 = 3;
      f0_6(as_0, ai_8, ai_12, ai_16, ai_20, ai_24, ai_28, ai_32, ai_36, ai_40, ai_44, as_48, ai_56);
      if (ai_40 == 0) {
         li_76 = gia_168[2] - gia_168[0] - (7 * (ai_28 - 1) + 19);
         li_80 = gia_168[2] - gia_168[0] - (15 * (ai_28 - 1) + 37);
      } else {
         li_76 = 4;
         li_80 = 7 * (ai_28 - 1) + 23;
      }
      ls_60 = StringSubstr(as_0, 0, 2) + "CL" + StringSubstr(as_0, 2);
      f0_6(ls_60, 52, li_76, 4, 1, 1, ai_28 - 1, ai_32 + 1, ai_36, ai_40, ai_44, as_0, ai_56);
      f0_2("Clt", ls_60, 69, StringSetChar("", 0, 'r'), "Webdings", ai_56, 1, 4, 4, ai_28 - 1);
      ls_60 = StringSubstr(as_0, 0, 2) + "HD" + StringSubstr(as_0, 2);
      f0_6(ls_60, 53, li_80, 4, 1, 1, ai_28 - 1, ai_32 + 1, ai_36, ai_40, ai_44, as_0, ai_56);
      f0_2("Hdt", ls_60, 69, StringSetChar("", 0, '0'), "Webdings", ai_56, 1, 4, 4, ai_28 - 1);
      break;
   case 74:
      if (ai_20 < 3) ai_20 = 3;
      f0_6(as_0, ai_8, ai_12, ai_16, ai_20, ai_24, ai_28, ai_32, ai_36, ai_40, ai_44, as_48, ai_56);
      if (ai_40 == 0) {
         li_76 = gia_168[2] - gia_168[0] - (7 * (ai_28 - 1) + 19);
         li_80 = gia_168[2] - gia_168[0] - (15 * (ai_28 - 1) + 37);
         li_84 = gia_168[2] - gia_168[0] - (23 * (ai_28 - 1) + 55);
      } else {
         li_76 = 4;
         li_80 = 7 * (ai_28 - 1) + 23;
         li_84 = 14 * (ai_28 - 1) + 42;
      }
      ls_60 = StringSubstr(as_0, 0, 2) + "CL" + StringSubstr(as_0, 2);
      f0_6(ls_60, 52, li_76, 4, 1, 1, ai_28 - 1, ai_32 + 1, ai_36, ai_40, ai_44, as_0, ai_56);
      f0_2("Clt", ls_60, 69, StringSetChar("", 0, 'r'), "Webdings", ai_56, 1, 4, 4, ai_28 - 1);
      ls_60 = StringSubstr(as_0, 0, 2) + "HD" + StringSubstr(as_0, 2);
      f0_6(ls_60, 53, li_80, 4, 1, 1, ai_28 - 1, ai_32 + 1, ai_36, ai_40, ai_44, as_0, ai_56);
      f0_2("Hdt", ls_60, 69, StringSetChar("", 0, '0'), "Webdings", ai_56, 1, 4, 4, ai_28 - 1);
      ls_60 = StringSubstr(as_0, 0, 2) + "ST" + StringSubstr(as_0, 2);
      f0_6(ls_60, 55, li_84, 4, 1, 1, ai_28 - 1, ai_32 + 1, ai_36, ai_40, ai_44, as_0, ai_56);
      f0_2("Stt", ls_60, 69, StringSetChar("", 0, '@'), "Webdings", ai_56, 1, 4, 4, ai_28 - 1);
      break;
   default:
      return (1);
   }
   return (0);
}

int f0_1(string as_0, string as_8, int ai_16, int ai_20, int ai_24 = 1, int ai_28 = 1, int ai_32 = 0, double ad_36 = 0.0, double ad_44 = 1.0, double ad_52 = 1.0, int ai_60 = -1, int ai_64 = -1, int ai_68 = -1) {
   int li_80;
   int li_84;
   int li_88;
   int li_92;
   int li_96;
   int li_100;
   int li_104;
   int li_112;
   int li_116;
   string ls_unused_124;
   string ls_unused_132;
   int li_188;
   int li_192;
   if (as_8 == "") {
      if (ai_64 < 0) ai_64 = 0;
      if (ai_68 < 0) ai_68 = 16777215;
   } else {
      if (!f0_9(as_8)) return (-1);
      if (ai_64 < 0) ai_64 = 0;
      if (ai_68 < 0) ai_68 = 16777215;
      li_92 = gia_156[4] + 1;
   }
   if (ai_28 > 2) ai_28 = 2;
   if (ai_24 > 8) ai_24 = 8;
   if (ai_32 > 3) ai_32 = 3;
   if (ai_32 < 0) ai_32 = 0;
   switch (ai_32) {
   case 0:
      li_80 = ai_24;
      li_84 = 1;
      break;
   case 1:
      li_80 = 1;
      li_84 = ai_24;
      break;
   case 2:
      li_80 = ai_24;
      li_84 = 1;
      break;
   case 3:
      li_80 = 1;
      li_84 = ai_24;
   }
   f0_11(as_0, as_8, 30, ai_16, ai_20, li_80, li_84, ai_28, ai_64, ai_68, li_92);
   f0_9(as_0);
   int li_120 = gia_156[6];
   if (ai_32 % 2 == 0) {
      switch (li_80) {
      case 1:
         li_88 = 1;
         break;
      case 2:
         li_88 = 2;
         break;
      case 3:
         li_88 = 2;
         break;
      case 4:
         li_88 = 2;
         break;
      case 5:
         li_88 = 3;
         break;
      case 6:
         li_88 = 3;
         break;
      case 7:
         li_88 = 3;
         break;
      case 8:
         li_88 = 4;
      }
   } else {
      switch (li_84) {
      case 1:
         li_88 = 1;
         break;
      case 2:
         li_88 = 2;
         break;
      case 3:
         li_88 = 3;
         break;
      case 4:
         li_88 = 3;
         break;
      case 5:
         li_88 = 4;
         break;
      case 6:
         li_88 = 5;
         break;
      case 7:
         li_88 = 4;
         break;
      case 8:
         li_88 = 4;
      }
   }
   switch (ai_32) {
   case 0:
      switch (ai_28) {
      case 0:
         if (li_120 == 0) {
            li_96 = 1;
            li_100 = -2;
            li_104 = 9;
            li_112 = 5 * li_80 - 1;
            li_116 = 0;
         }
         if (li_120 != 1) break;
         li_96 = gia_156[2] - gia_156[0] - 1;
         li_100 = 17;
         li_104 = 9;
         li_112 = 5 * li_80 - 1;
         li_116 = 180;
         break;
      case 1:
         if (li_120 == 0) {
            li_96 = 1;
            li_100 = -2;
            li_104 = 9;
            li_112 = li_80 * 8 - li_88;
            li_116 = 0;
         }
         if (li_120 != 1) break;
         li_96 = gia_156[2] - gia_156[0] - 1;
         li_100 = 17;
         li_104 = 9;
         li_112 = li_80 * 8 - li_88;
         li_116 = 180;
         break;
      case 2:
         if (li_120 == 0) {
            li_96 = 1;
            li_100 = -5;
            li_104 = 15;
            li_112 = 5 * li_80;
            li_116 = 0;
         }
         if (li_120 != 1) break;
         li_96 = gia_156[2] - gia_156[0] - 1;
         li_100 = 28;
         li_104 = 15;
         li_112 = 5 * li_80;
         li_116 = 180;
      }
      break;
   case 1:
      switch (ai_28) {
      case 0:
         if (li_84 > 6) li_88++;
         if (li_120 == 0) {
            li_96 = -3;
            li_100 = gia_156[3] - gia_156[1];
            li_104 = 9;
            li_112 = 5 * li_84 - li_88;
            li_116 = 90;
         }
         if (li_120 != 1) break;
         li_96 = -3;
         li_100 = gia_156[3] - gia_156[1] - 1;
         li_104 = 9;
         li_112 = 5 * li_84 - li_88;
         li_116 = 270;
         break;
      case 1:
         if (li_120 == 0) {
            li_96 = -3;
            li_100 = gia_156[3] - gia_156[1];
            li_104 = 9;
            li_112 = 7 * li_84 - 1;
            li_116 = 90;
         }
         if (li_120 != 1) break;
         li_96 = -3;
         li_100 = gia_156[3] - gia_156[1] - 1;
         li_104 = 9;
         li_112 = 7 * li_84 - 1;
         li_116 = 270;
         break;
      case 2:
         if (li_120 == 0) {
            li_96 = -6;
            li_100 = gia_156[3] - gia_156[1];
            li_104 = 14;
            li_112 = 7 * li_84 - (li_84 + li_84 / 4);
            li_116 = 90;
         }
         if (li_120 != 1) break;
         li_96 = -6;
         li_100 = gia_156[3] - gia_156[1] + 1;
         li_104 = 14;
         li_112 = 7 * li_84 - (li_84 + li_84 / 4);
         li_116 = 270;
      }
      break;
   case 2:
      switch (ai_28) {
      case 0:
         if (li_120 == 1) {
            li_96 = 2;
            li_100 = -2;
            li_104 = 9;
            li_112 = 5 * li_80 - 1;
            li_116 = 0;
         }
         if (li_120 != 0) break;
         li_96 = gia_156[2] - gia_156[0];
         li_100 = 17;
         li_104 = 9;
         li_112 = 5 * li_80 - 1;
         li_116 = 180;
         break;
      case 1:
         if (li_120 == 1) {
            li_96 = 2;
            li_100 = -2;
            li_104 = 9;
            li_112 = li_80 * 8 - li_88;
            li_116 = 0;
         }
         if (li_120 != 0) break;
         li_96 = gia_156[2] - gia_156[0];
         li_100 = 17;
         li_104 = 9;
         li_112 = li_80 * 8 - li_88;
         li_116 = 180;
         break;
      case 2:
         if (li_120 == 1) {
            li_96 = 1;
            li_100 = -5;
            li_104 = 15;
            li_112 = 5 * li_80;
            li_116 = 0;
         }
         if (li_120 != 0) break;
         li_96 = gia_156[2] - gia_156[0] - 1;
         li_100 = 28;
         li_104 = 15;
         li_112 = 5 * li_80;
         li_116 = 180;
      }
      break;
   case 3:
      switch (ai_28) {
      case 0:
         if (li_120 == 0) {
            li_96 = 18;
            li_100 = 1;
            li_104 = 9;
            li_112 = 5 * li_84 - li_88;
            li_116 = 270;
         }
         if (li_120 != 1) break;
         li_96 = 18;
         li_100 = 1;
         li_104 = 9;
         li_112 = 5 * li_84 - li_88;
         li_116 = 90;
         break;
      case 1:
         if (li_120 == 0) {
            li_96 = 18;
            li_100 = 1;
            li_104 = 9;
            li_112 = 7 * li_84 - 1;
            li_116 = 270;
         }
         if (li_120 != 1) break;
         li_96 = 18;
         li_100 = 2;
         li_104 = 9;
         li_112 = 7 * li_84 - 1;
         li_116 = 90;
         break;
      case 2:
         if (li_120 == 0) {
            li_96 = 28;
            li_100 = 1;
            li_104 = 14;
            li_112 = 7 * li_84 - (li_84 + li_84 / 4);
            li_116 = 270;
         }
         if (li_120 != 1) break;
         li_96 = 28;
         li_100 = 1;
         li_104 = 14;
         li_112 = 7 * li_84 - (li_84 + li_84 / 4);
         li_116 = 90;
      }
   }
   double ld_172 = (ad_44 - ad_36) / MathAbs(li_112);
   string ls_180 = "";
   for (int count_72 = 0; count_72 < li_112; count_72++) {
      if (ad_52 <= ad_36 + ld_172 * count_72) break;
      ls_180 = ls_180 + "|";
   }
   if (ai_60 < 0) {
      li_188 = ArraySize(gia_144) - 1;
      li_192 = count_72 / (li_112 / li_188);
      if (li_192 > li_188) li_192 = li_188;
      ai_60 = gia_144[li_192];
   }
   f0_2("LedIn", as_0, 69, ls_180, "Arial black", ai_60, 0, li_96, li_100, 0, li_104, 0, 0, li_116);
   if (ai_28 > 0) {
      if (ai_32 == 1 || ai_32 == 3) li_96 += ai_28 - 1 + 8;
      else li_100 += 8;
      f0_2("LedIn", as_0, 69, ls_180, "Arial black", ai_60, 0, li_96, li_100, 0, li_104, 0, 0, li_116);
   }
   return (0);
}

string f0_7(string as_0, int aia_8[10], string as_12 = "chart") {
   string ls_unused_20 = "";
   if (as_12 == "") as_12 = "chart";
   return (StringConcatenate("wnd:", "z_", aia_8[6], StringSetChar("", 0, aia_8[7] + 97), StringSetChar("", 0, aia_8[8] + 97), ":", "c_", aia_8[9], ":", "lu_", aia_8[0],
      "_", aia_8[1], ":", "rd_", aia_8[2], "_", aia_8[3], ":", "id", aia_8[4], "", aia_8[5], ":", "#", as_0, "|", as_12));
}

int f0_11(string as_0, string as_8, int ai_16, int ai_20 = 0, int ai_24 = 0, int ai_28 = 1, int ai_32 = 1, int ai_36 = 1, int ai_40 = 0, int ai_44 = 16777215, int ai_48 = 0, int ai_52 = 0, int ai_56 = 0) {
   string ls_60;
   string ls_68;
   switch (ai_16) {
   case 30:
      f0_6(as_0, ai_16, ai_20, ai_24, ai_28, ai_32, ai_36, ai_48, ai_40, ai_52, ai_56, as_8, ai_44);
      break;
   case 40:
      f0_6(as_0, ai_16, ai_20, ai_24, ai_28, ai_32, ai_36, ai_48, ai_40, ai_52, ai_56, as_8, ai_44);
      break;
   case 70:
      f0_10(as_0, ai_16, ai_20, ai_24, ai_28, ai_32, ai_36, ai_48, ai_40, ai_52, ai_56, as_8, ai_44);
      break;
   case 71:
      f0_10(as_0, ai_16, ai_20, ai_24, ai_28, ai_32, ai_36, ai_48, ai_40, ai_52, ai_56, as_8, ai_44);
      break;
   case 72:
      f0_10(as_0, ai_16, ai_20, ai_24, ai_28, ai_32, ai_36, ai_48, ai_40, ai_52, ai_56, as_8, ai_44);
      break;
   case 73:
      f0_10(as_0, ai_16, ai_20, ai_24, ai_28, ai_32, ai_36, ai_48, ai_40, ai_52, ai_56, as_8, ai_44);
      break;
   case 74:
      f0_10(as_0, ai_16, ai_20, ai_24, ai_28, ai_32, ai_36, ai_48, ai_40, ai_52, ai_56, as_8, ai_44);
      break;
   case 44:
      ls_60 = "RevBb";
      ls_68 = "Revtt";
      f0_6(ls_60, 44, ai_20, ai_24, 4, 1, 0, ai_48 + 1, 16711935, ai_52, ai_56, as_8, ai_44);
      f0_2(ls_68, ls_60, 69, "Revers", "Tahoma", ai_44);
      break;
   case 43:
      ls_60 = "ClBb";
      ls_68 = "Clott";
      f0_6(ls_60, 43, ai_20, ai_24, 4, 1, 0, ai_48 + 1, 65535, ai_52, ai_56, as_8, ai_44);
      f0_2(ls_68, ls_60, 69, "Close", "Tahoma", 0);
      break;
   case 42:
      ls_60 = "Sbb";
      ls_68 = "Seltt";
      f0_6(ls_60, 42, ai_20, ai_24, 4, 1, 0, ai_48 + 1, 4678655, ai_52, ai_56, as_8, ai_44);
      f0_2(ls_68, ls_60, 69, "Sell", "Tahoma", ai_44);
      break;
   case 41:
      ls_60 = "Bbb";
      ls_68 = "Buytt";
      f0_6(ls_60, 41, ai_20, ai_24, 4, 1, 0, ai_48 + 1, 16748574, ai_52, ai_56, as_8, ai_44);
      f0_2(ls_68, ls_60, 69, "Buy", "Tahoma", ai_44);
      break;
   case 52:
      ls_60 = "Cls";
      ls_68 = "Clt";
      f0_6(ls_60, 52, ai_20, 4, 1, 1, 0, ai_48 + 1, ai_40, ai_52, ai_56, as_8, ai_44);
      f0_2(ls_68, ls_60, 69, StringSetChar("", 0, 'r'), "Webdings", ai_44);
      break;
   case 53:
      ls_60 = "Hid";
      ls_68 = "Hdt";
      f0_6(ls_60, 53, ai_20, 4, 1, 1, 0, ai_48 + 1, ai_40, ai_52, ai_56, as_8, ai_44);
      f0_2(ls_68, ls_60, 69, StringSetChar("", 0, '0'), "Webdings", ai_44);
      break;
   case 54:
      ls_60 = "Shw";
      ls_68 = "Sht";
      f0_6(ls_60, 54, ai_20, 4, 1, 1, 0, ai_48 + 1, ai_40, ai_52, ai_56, as_8, ai_44);
      f0_2(ls_68, ls_60, 69, StringSetChar("", 0, '2'), "Webdings", ai_44);
      break;
   case 55:
      ls_60 = "Set";
      ls_68 = "Stt";
      f0_6(ls_60, 55, ai_20, 4, 1, 1, 0, ai_48 + 1, ai_40, ai_52, ai_56, as_8, ai_44);
      f0_2(ls_68, ls_60, 69, StringSetChar("", 0, '@'), "Webdings", ai_44);
      break;
   case 56:
      ls_60 = "Alr";
      ls_68 = "Altx";
      f0_6(ls_60, 56, ai_20, 4, 1, 1, 0, ai_48 + 1, ai_40, ai_52, ai_56, as_8, 12632256);
      f0_2(ls_68, ls_60, 69, StringSetChar("", 0, ']'), "Webdings", 12632256);
      break;
   case 57:
      ls_60 = "Snd";
      ls_68 = "Sndtx";
      f0_6(ls_60, 57, ai_20, 4, 1, 1, 0, ai_48 + 1, ai_40, ai_52, ai_56, as_8, 12632256);
      f0_2(ls_68, ls_60, 57, StringSetChar("", 0, '¯'), "Webdings", 12632256);
      break;
   case 58:
      ls_60 = "Mil";
      ls_68 = "Mltx";
      f0_6(ls_60, 58, ai_20, 4, 1, 1, 0, ai_48 + 1, ai_40, ai_52, ai_56, as_8, 12632256);
      f0_2(ls_68, ls_60, 58, StringSetChar("", 0, '*'), "Wingdings", 12632256);
      break;
   case 60:
      ls_60 = as_0;
      ls_68 = "Lftx";
      f0_6(ls_60, 60, ai_20, ai_24, 1, 1, 0, ai_48 + 1, ai_40, ai_52, ai_56, as_8, ai_44);
      f0_2(ls_68, ls_60, 60, StringSetChar("", 0, '3'), "Webdings", ai_44);
      break;
   case 61:
      ls_60 = as_0;
      ls_68 = "Rttx";
      f0_6(ls_60, 61, ai_20, ai_24, 1, 1, 0, ai_48 + 1, ai_40, ai_52, ai_56, as_8, ai_44);
      f0_2(ls_68, ls_60, 61, StringSetChar("", 0, '4'), "Webdings", ai_44);
      break;
   case 62:
      ls_60 = as_0;
      ls_68 = "Uptx";
      f0_6(ls_60, 62, ai_20, ai_24, 1, 1, 0, ai_48 + 1, ai_40, ai_52, ai_56, as_8, ai_44);
      f0_2(ls_68, ls_60, 62, StringSetChar("", 0, '5'), "Webdings", ai_44);
      break;
   case 63:
      ls_60 = as_0;
      ls_68 = "Dntx";
      f0_6(ls_60, 63, ai_20, ai_24, 1, 1, 0, ai_48 + 1, ai_40, ai_52, ai_56, as_8, ai_44);
      f0_2(ls_68, ls_60, 63, StringSetChar("", 0, '6'), "Webdings", ai_44);
      break;
   case 59:
      ls_60 = as_0;
      ls_68 = "Sltx";
      f0_6(ls_60, 59, ai_20, ai_24, 1, 1, 0, ai_48 + 1, ai_40, ai_52, ai_56, as_8, ai_44);
      f0_2(ls_68, ls_60, 59, StringSetChar("", 0, 'a'), "Webdings", ai_44);
      break;
   default:
      return (0);
   }
   return (1);
}

int f0_9(string as_0) {
   int li_12;
   int li_16;
   string name_20;
   int li_28;
   for (int objs_total_8 = ObjectsTotal(); objs_total_8 >= 0; objs_total_8--) {
      name_20 = ObjectName(objs_total_8);
      li_28 = StringFind(name_20, as_0);
      if (li_28 >= 0) {
         if (li_28 != StringFind(name_20, "|") + 1) {
            li_12 = StringFind(name_20, "z_") + 2;
            gia_156[4] = StrToInteger(StringSubstr(name_20, li_12, 1));
            gia_156[9] = StrToInteger(StringGetChar(StringSubstr(name_20, li_12 + 3, 1), 0));
            li_12 = StringFind(name_20, ":c_") + 3;
            gia_156[5] = StrToInteger(StringSubstr(name_20, li_12, 2));
            li_12 = StringFind(name_20, "lu_") + 3;
            li_16 = StringFind(name_20, "_", li_12);
            gia_156[0] = StrToInteger(StringSubstr(name_20, li_12, li_16 - li_12));
            li_12 = StringFind(name_20, ":", li_16);
            gia_156[1] = StrToInteger(StringSubstr(name_20, li_16 + 1, li_12 - li_16 + 1));
            li_12 = StringFind(name_20, "rd_") + 3;
            li_16 = StringFind(name_20, "_", li_12);
            gia_156[2] = StrToInteger(StringSubstr(name_20, li_12, li_16 - li_12));
            li_12 = StringFind(name_20, ":", li_16);
            gia_156[3] = StrToInteger(StringSubstr(name_20, li_16 + 1, li_12 - li_16 + 1));
            gia_156[6] = ObjectGet(name_20, OBJPROP_CORNER);
            gia_156[7] = ObjectGet(name_20, OBJPROP_COLOR);
            gia_156[8] = ObjectFind(name_20);
            gs_148 = StringSubstr(name_20, StringFind(name_20, "|") + 1);
            return (1);
         }
      }
   }
   ArrayInitialize(gia_156, -1);
   gs_148 = 0;
   return (0);
}

void f0_3(string as_0) {
   int li_12;
   int li_16;
   string name_28;
   string ls_44;
   string lsa_52[5000];
   string lsa_56[5000];
   int li_64;
   int li_68;
   string ls_72;
   string ls_80;
   int li_60 = GetTickCount();
   for (int li_8 = ObjectsTotal() - 1; li_8 >= 0; li_8--) {
      name_28 = ObjectName(li_8);
      if (StringFind(name_28, "wnd:") >= 0) {
         if (StringFind(name_28, "#" + as_0) > 0) {
            ObjectDelete(name_28);
            continue;
         }
         if (StringFind(name_28, "|" + as_0) > 0) {
            li_64 = StringFind(name_28, "#") + 1;
            li_68 = StringFind(name_28, "|" + as_0) - li_64;
            lsa_52[li_12] = StringSubstr(name_28, li_64, li_68);
            li_12++;
            ObjectDelete(name_28);
            continue;
         }
         lsa_56[li_16] = name_28;
         li_16++;
      }
   }
   ArrayResize(lsa_56, li_16);
   for (li_8 = 0; li_8 < li_12; li_8++) {
      ls_72 = "|" + lsa_52[li_8];
      for (int index_20 = 0; index_20 < li_16; index_20++) {
         name_28 = lsa_56[index_20];
         if (name_28 != "") {
            if (StringFind(name_28, ls_72) >= 0) {
               li_64 = StringFind(name_28, "#") + 1;
               li_68 = StringFind(name_28, ls_72) - li_64;
               ls_80 = StringSubstr(name_28, li_64, li_68);
               if (ls_44 != ls_80) {
                  ls_44 = ls_80;
                  lsa_52[li_12] = ls_44;
                  li_12++;
               }
               lsa_56[index_20] = "";
               ObjectDelete(name_28);
            }
         }
      }
   }
}

void f0_8(string as_0, bool ai_8 = TRUE) {
   int objs_total_12 = 0;
   string name_16 = "";
   if (ai_8) {
      for (objs_total_12 = ObjectsTotal(); objs_total_12 >= 0; objs_total_12--) {
         name_16 = ObjectName(objs_total_12);
         if (StringFind(name_16, as_0) >= 0) ObjectDelete(name_16);
      }
   } else {
      for (objs_total_12 = ObjectsTotal(); objs_total_12 >= 0; objs_total_12--) {
         name_16 = ObjectName(objs_total_12);
         if (StringFind(name_16, "#" + as_0) >= 0) ObjectDelete(name_16);
      }
   }
}

bool f0_4(string as_0, int a_x_8, int a_y_12, string a_text_16 = "c", int a_fontsize_24 = 14, int a_corner_28 = 0, color a_color_32 = 0, int a_window_36 = 0, string a_fontname_40 = "Webdings", int a_angle_48 = FALSE) {
   if (a_window_36 > WindowsTotal() - 1) a_window_36 = WindowsTotal() - 1;
   if (StringLen(as_0) < 1) return (FALSE);
   ObjectDelete(as_0);
   ObjectCreate(as_0, OBJ_LABEL, a_window_36, 0, 0);
   ObjectSet(as_0, OBJPROP_XDISTANCE, a_x_8);
   ObjectSet(as_0, OBJPROP_YDISTANCE, a_y_12);
   ObjectSet(as_0, OBJPROP_CORNER, a_corner_28);
   ObjectSet(as_0, OBJPROP_BACK, FALSE);
   ObjectSet(as_0, OBJPROP_ANGLE, a_angle_48);
   ObjectSetText(as_0, a_text_16, a_fontsize_24, a_fontname_40, a_color_32);
   return (TRUE);
}

void Find_Pref_Suf()
   {
      
   }

void init() {
   int cntr;
   string curSymb;
   string resStr = "";
   
   string curPref = "";
   string curSuff = "";
   
   g_color_216 = HandleBackGroundColor;
   g_color_220 = DataTableBackGroundColor_1;
   g_color_224 = DataTableBackGroundColor_2;
   g_color_228 = CurrencysBackGroundColor;
   g_color_236 = HandleTextColor;
   g_color_240 = DataTableTextColor;
   g_color_244 = CurrencysTextColor;
   g_color_248 = TrendUpArrowsColor;
   g_color_252 = TrendDownArrowsColor;
   
   // ----  Begin Symbol Converter ----
   int a = 0;
   int b = 0;
   
   while(a<28)
      {
         curSymb = symbBuff[a];
         
         if(StringLen(Symbol())==6)a=28;
         
         if(StringLen(Symbol())!=6)
            {
               // Find Prefix
               if(StringFind(Symbol(),curSymb,0)!=0 && StringFind(Symbol(),curSymb,0)!=-1)
                  {
                     b = StringFind(Symbol(),curSymb,0);
                     curPref = StringSubstr(Symbol(),0,b);
                     curSuff = "";
                     a=28;
                  }
               
               // Find Suffix
               if(StringFind(Symbol(),curSymb,0)==0 && StringFind(Symbol(),curSymb,0)!=-1)
                  {
                     b = StringLen(Symbol()) - 6;
                     curSuff = StringSubstr(Symbol(),6,b);
                     curPref = "";
                     a=28;
                  }
            }
         a++;
      }
   
   // -----  End Symbol Converter  ----
   
   for (int i = 0; i < 28; i++) {
      curSymb = symbBuff[i];
      if (StringLen(SymbolPrefix) > 1) {
         gi_264 = TRUE;
         if (StringFind(SymbolPrefix, "|") == 0) {
            gs_256 = StringSubstr(SymbolPrefix, 1);
            curSymb = curSymb + gs_256;
            gi_268 = -StringLen(symbBuff[i]);
         }
         if (StringFind(SymbolPrefix, "|") == StringLen(SymbolPrefix) - 1) {
            gs_256 = StringSubstr(SymbolPrefix, 0, StringFind(SymbolPrefix, "|"));
            curSymb = gs_256 + curSymb;
            gi_268 = StringLen(gs_256) - 1;
         }
      }
      if (MarketInfo((curPref + curSymb + curSuff), MODE_POINT) == 0.0000) resStr = resStr + ":" + symbBuff[i];
      else {
         workSymbBuf[cntr] = curSymb;
         
         curSymb = symbBuff[i];
         curSymb = curPref + curSymb + curSuff;
         workSymbBuf[cntr] = curSymb;
         
         cntr++;
      }
      
   }
   ArrayResize(workSymbBuf, cntr);
   if (UninitializeReason() != REASON_CHARTCHANGE) {
      if (resStr != "") {
         resStr = "Some currency pairs are not available\n for calculating the indices.\n" + resStr;
         resStr = resStr 
         + "\nCalculation formula will be changed.";
         Alert(resStr);
      }
   }
}

void deinit() {
   string ls_0 = "Curs";
   string ls_8 = "Pows";
   f0_3("Header");
   f0_3("Window");
   f0_3(ls_0);
   f0_3(ls_8);
}

void start() {
   int li_20;
   int li_28;
   int color_32;
   int color_36;
   int li_40;
   double lda_44[8][2];
   string ls_84;
   int li_unused_92;
   double ld_96;
   int li_24 = 4;
   string ls_48 = "Curs";
   string ls_unused_56 = "Pows";
   int li_unused_72 = 0;
   if (ShowCurrencies && (!CurrenciesWindowBelowTable)) {
      f0_11("Window", "", 30, 4, 18, 18, 1, 0, g_color_216, g_color_216, 0, 0, 0);
      f0_11("Header", "", 30, 260, 18, 1, 1, 0, g_color_216, g_color_216, 0, 0, 0);
      f0_2("hdTxt", "Window", 69, "ForexProfitSupreme Meter", "Courier new", g_color_236, 0, 34, -2, 0, 11);
   } else {
      f0_11("Window", "", 30, 4, 18, 11, 1, 0, g_color_216, g_color_216, 0, 0, 0);
      f0_2("hdTxt", "Window", 69, "ForexProfitSupreme Meter", "Courier new", g_color_236, 0, 1, -2, 0, 11);
   }
   int li_16 = 14;
   li_24 = 2;
   ArrayInitialize(gda_212, 0);
   int index_4 = f0_0();
   if (ShowSymbolsSorted) ArraySort(gda_212, WHOLE_ARRAY, 0, MODE_DESCEND);
   int count_8 = 0;
   string ls_76 = "";
   for (int index_0 = 0; index_0 < index_4; index_0++) {
      li_40 = gda_212[index_0][1];
      if (StringFind(DontShowThisPairs, symbBuff[index_0]) < 0) {
         if (count_8 % 2 != 0) color_36 = g_color_220;
         else color_36 = g_color_224;
         f0_8("cWnd" + index_0);
         f0_11("cWnd" + index_0, "Window", 30, 0, li_16 + li_24, 11, 1, 0, color_36, color_36, 0, 0, 0);
         if (li_40 >= 0) {
            if (gi_264) {
               if (gi_268 < 0) ls_76 = StringSubstr(workSymbBuf[li_40], 0, -gi_268);
               else ls_76 = StringSubstr(workSymbBuf[li_40], gi_268);
            } else ls_76 = workSymbBuf[li_40];
         } else ls_76 = "LOADING";
         f0_2(ls_76 + "wnd", "cWnd" + index_0, 69, ls_76, "Courier new", g_color_240, 0, 4, -2, 0, 11);
         if (li_40 >= 0) {
            f0_8(index_0 + "sLED");
            if (gda_212[index_0][0] < 0.0) {
               li_28 = 2;
               li_20 = -14;
               color_32 = g_color_252;
               f0_1(index_0 + "sLED", "Window", li_20 + 75, li_16 + 0 + li_24, 2, 0, li_28, 0, 100, -gda_212[index_0][0], color_32, color_36, color_36);
               f0_2(index_0 + "TrDn", "cWnd" + index_0, 69, StringSetChar("", 0, 'Ú'), "Wingdings", color_32, 0, 99, -2, 0, 14);
               if (gda_212[index_0][0] < -99.99) f0_2("strench", "cWnd" + index_0, 69, "-100", "Courier new", g_color_240, 0, 122, -1, 0, 10);
               else f0_2("strench", "cWnd" + index_0, 69, DoubleToStr(gda_212[index_0][0], 1), "Courier new", g_color_240, 0, 122, -1, 0, 10);
            } else {
               li_28 = 0;
               li_20 = 14;
               color_32 = g_color_248;
               f0_1(index_0 + "sLED", "Window", li_20 + 75, li_16 + 0 + li_24, 2, 0, li_28, 0, 100, gda_212[index_0][0], color_32, color_36, color_36);
               f0_2(index_0 + "TrUp", "cWnd" + index_0, 69, StringSetChar("", 0, 'Ù'), "Wingdings", color_32, 0, 65, -3, 0, 14);
               if (gda_212[index_0][0] > 99.99) f0_2("strench", "cWnd" + index_0, 69, "100.0", "Courier new", g_color_240, 0, 122, -1, 0, 10);
               else f0_2("strench", "cWnd" + index_0, 69, DoubleToStr(gda_212[index_0][0], 1), "Courier new", g_color_240, 0, 130, -1, 0, 10);
            }
         }
         li_24 += 16;
         count_8++;
      }
   }
   if (ShowCurrencies) {
      if (!CurrenciesWindowBelowTable) {
         li_20 = li_24;
         f0_11(ls_48, "Window", 30, 166, 16, 7, 9, 0, g_color_228, g_color_228, 0, 0, 0);
         ls_84 = "Led" + index_0;
         li_unused_92 = gia_208[index_0];
         li_24 = 0;
         for (index_4 = 0; index_4 < 8; index_4++) {
            ld_96 = f0_5(gsa_188[index_4]);
            lda_44[index_4][0] = ld_96;
            lda_44[index_4][1] = index_4;
         }
         if (ShowCurrenciesSorted) ArraySort(lda_44, WHOLE_ARRAY, 0, MODE_DESCEND);
         for (index_4 = 0; index_4 < 8; index_4++) {
            ld_96 = lda_44[index_4][0];
            li_40 = lda_44[index_4][1];
            f0_2("CuCur" + index_4, ls_48, 69, gsa_188[li_40], "Courier new", g_color_244, 0, 5, li_24 + 0, 0, 11);
            f0_2("CuDig" + index_4, ls_48, 69, DoubleToStr(lda_44[index_4][0], 1), "Courier new", g_color_244, 0, 78, li_24 + 1, 0, 10);
            f0_1("sLED" + index_4, ls_48, 32, li_24 + 2, 3, 0, 0, 0, 10, ld_96, -1, g_color_228, g_color_228);
            li_24 += 14;
         }
      } else {
         f0_11(ls_48, "Window", 30, 0, li_24 + 14, 11, 6, 0, g_color_228, g_color_228, 0, 0, 0);
         ls_84 = "Led" + index_0;
         li_unused_92 = gia_208[index_0];
         li_24 = 0;
         for (index_4 = 0; index_4 < 8; index_4++) {
            ld_96 = f0_5(gsa_188[index_4]);
            lda_44[index_4][0] = ld_96;
            lda_44[index_4][1] = index_4;
         }
         if (ShowCurrenciesSorted) ArraySort(lda_44, WHOLE_ARRAY, 0, MODE_DESCEND);
         for (index_4 = 0; index_4 < 8; index_4++) {
            ld_96 = lda_44[index_4][0];
            li_40 = lda_44[index_4][1];
            f0_2("CuCur" + index_4, ls_48, 69, gsa_188[li_40], "Courier new", g_color_244, 0, li_24 + 3, 76, 0, 12, 0, 0, 90);
            f0_1("sLED" + index_4, ls_48, li_24 + 1, 0, 2, 1, 1, 0, 10, ld_96, -1, g_color_228, g_color_228);
            li_24 += 20;
         }
      }
   }
   WindowRedraw();
}

int f0_0() {
   double ihigh_24;
   double ilow_32;
   double iopen_40;
   double iclose_48;
   double point_56;
   double ld_64;
   double ld_72;
   int li_unused_4 = 0;
   int timeframe_12 = 1440;
   string symbol_16 = "";
   int arr_size_8 = ArraySize(workSymbBuf);
   ArrayResize(gda_212, arr_size_8);
   for (int index_0 = 0; index_0 < arr_size_8; index_0++) {
      symbol_16 = workSymbBuf[index_0];
      point_56 = MarketInfo(symbol_16, MODE_POINT);
      if (point_56 == 0.0) {
         init();
         gda_212[index_0][1] = -1;
      } else {
         ihigh_24 = iHigh(symbol_16, timeframe_12, 0);
         ilow_32 = iLow(symbol_16, timeframe_12, 0);
         iopen_40 = iOpen(symbol_16, timeframe_12, 0);
         iclose_48 = iClose(symbol_16, timeframe_12, 0);
         if (iopen_40 > iclose_48) {
            ld_64 = (ihigh_24 - ilow_32) * point_56;
            if (ld_64 == 0.0) {
               init();
               gda_212[index_0][1] = -1;
               continue;
            }
            ld_72 = (ihigh_24 - iclose_48) / ld_64 * point_56 / (-0.01);
         } else {
            ld_64 = (ihigh_24 - ilow_32) * point_56;
            if (ld_64 == 0.0) {
               init();
               gda_212[index_0][1] = -1;
               continue;
            }
            ld_72 = 100.0 * ((iclose_48 - ilow_32) / ld_64 * point_56);
         }
         gda_212[index_0][0] = ld_72;
         gda_212[index_0][1] = index_0;
         gda_212[index_0][2] = 1;
      }
   }
   return (arr_size_8);
}

double f0_5(string as_0) {
   double point_20;
   int li_36;
   string ls_40;
   double ld_48;
   double ld_56;
   int count_8 = 0;
   double ld_ret_12 = 0;
   int timeframe_28 = 1440;
   for (int index_32 = 0; index_32 < ArraySize(workSymbBuf); index_32++) {
      li_36 = 0;
      ls_40 = workSymbBuf[index_32];
      if (as_0 == StringSubstr(ls_40, 0, 3) || as_0 == StringSubstr(ls_40, 3, 3)) {
         point_20 = MarketInfo(ls_40, MODE_POINT);
         if (point_20 == 0.0) {
            init();
            continue;
         }
         ld_48 = (iHigh(ls_40, timeframe_28, 0) - iLow(ls_40, timeframe_28, 0)) * point_20;
         if (ld_48 == 0.0) {
            init();
            continue;
         }
         ld_56 = 100.0 * ((MarketInfo(ls_40, MODE_BID) - iLow(ls_40, timeframe_28, 0)) / ld_48 * point_20);
         if (ld_56 > 3.0) li_36 = 1;
         if (ld_56 > 10.0) li_36 = 2;
         if (ld_56 > 25.0) li_36 = 3;
         if (ld_56 > 40.0) li_36 = 4;
         if (ld_56 > 50.0) li_36 = 5;
         if (ld_56 > 60.0) li_36 = 6;
         if (ld_56 > 75.0) li_36 = 7;
         if (ld_56 > 90.0) li_36 = 8;
         if (ld_56 > 97.0) li_36 = 9;
         count_8++;
         if (as_0 == StringSubstr(ls_40, 3, 3)) li_36 = 9 - li_36;
         ld_ret_12 += li_36;
      }
   }
   if (count_8 > 0) ld_ret_12 /= count_8;
   else ld_ret_12 = 0;
   return (ld_ret_12);
}