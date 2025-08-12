/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website:  ht TP: / /w ww. m etaq U O tE S.NEt
   E-mail : sU P pO RT@ me TaQ U o T ES .n Et
*/
#property copyright "Copyright © 2007, cja Trading"
#property link      "ccjjaa@gmail.com"

#property indicator_chart_window

extern int Dynamic_Number = 789789;
extern string $$$$$$$$$$$$$$$$$$$$$$$$$$ = "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$";
extern string Please_NOTE__Currency_Symbol = " must be  EURUSD  not  eurusd";
extern string Currency_Symbol = "";
extern string $$$$$$$$$$$$$$$$$$$$$$$$$$$ = "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$";
extern int BarsShift_Side = 0;
extern int BarsShift_UP_DN = 20;
extern int WindowToUse = 0;
extern string $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ = "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$";
extern string $$$$$$$$$$$$$$$$$$$$$$$$$ = "Title &  Border Color Settings";
extern color Border_color = SlateGray;
extern color BackGround_color = Black;
extern color Currency_color = DarkOrange;
extern color PeriodTitles_color = Silver;
extern color DynamicTitle_color = Gray;
extern color DottedSeparator_color = SlateGray;
extern string $$$$$$$$$$$$$$$$$$$$$$$$ = "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$";
extern string $$$$$$$$$$$$$$$$$$$$$$ = "AutoUP Bar Color Settings";
extern string NOTE_Auto_UPColors_avaliable = "* Lime  * Olive * SeaGreen * Gray";
extern string _ = "* RoyalBlue * Blue * Gold";
extern color AutoUP_color = Lime;
extern string $$$$$$$$$$$$$$$$$$$$$$$$$$$$$ = "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$";
extern string $$$$$$$$$$$$$$$$$$$$$ = "AutoDN Bar Color Settings";
extern string NOTE_Auto_DNColors_avaliable = "* Red  * Magenta * RoyalBlue * Gray";
extern string _. = "* MediumVioletRed * Blue * Orange";
extern color AutoDN_color = Red;
extern string $$$$$$$$$$$$$$$$$$$$$$$$$$$$ = "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$";
extern string $$$$$$$$$$$$$$$$$$$$$$$ = "Manual Bar Color Settings";
extern color UPcolor_1 = Lime;
extern color UPcolor_2 = Lime;
extern color UPcolor_3 = Lime;
extern color UPcolor_4 = C'0x00,0xDC,0x00';
extern color UPcolor_5 = C'0x00,0xC8,0x00';
extern color UPcolor_6 = C'0x00,0xA0,0x00';
extern color UPcolor_7 = C'0x00,0x82,0x00';
extern color UPcolor_8 = DarkGreen;
extern color UPcolor_9 = C'0x00,0x50,0x00';
extern color DNcolor_1 = Red;
extern color DNcolor_2 = Red;
extern color DNcolor_3 = Red;
extern color DNcolor_4 = Red;
extern color DNcolor_5 = C'0xDC,0x00,0x00';
extern color DNcolor_6 = C'0xB4,0x00,0x00';
extern color DNcolor_7 = C'0x96,0x00,0x00';
extern color DNcolor_8 = C'0x78,0x00,0x00';
extern color DNcolor_9 = C'0x64,0x00,0x00';
extern color EQUALcolor = Silver;
int Gi_328;
string Gs_dummy_332;
double Gd_unused_340;

int CreateDynamic(string A_name_0, int A_y_8, int A_x_12) {
   ObjectCreate(A_name_0, OBJ_LABEL, WindowToUse, 0, 0);
   ObjectSet(A_name_0, OBJPROP_CORNER, 0);
   ObjectSet(A_name_0, OBJPROP_XDISTANCE, A_x_12);
   ObjectSet(A_name_0, OBJPROP_YDISTANCE, A_y_8);
   ObjectSet(A_name_0, OBJPROP_BACK, FALSE);
   return (0);
}

int init() {
   if (AutoUP_color == Blue) {
      UPcolor_1 = C'0x6E,0x6E,0xFF';
      UPcolor_2 = C'0x5E,0x5E,0xFF';
      UPcolor_3 = C'0x4A,0x4A,0xFF';
      UPcolor_4 = C'0x36,0x36,0xFF';
      UPcolor_5 = Blue;
      UPcolor_6 = C'0x00,0x00,0xDC';
      UPcolor_7 = C'0x00,0x00,0xBE';
      UPcolor_8 = C'0x00,0x00,0xA0';
      UPcolor_9 = C'0x00,0x00,0x8C';
   }
   if (AutoDN_color == Blue) {
      DNcolor_1 = C'0x6E,0x6E,0xFF';
      DNcolor_2 = C'0x5E,0x5E,0xFF';
      DNcolor_3 = C'0x4A,0x4A,0xFF';
      DNcolor_4 = C'0x36,0x36,0xFF';
      DNcolor_5 = Blue;
      DNcolor_6 = C'0x00,0x00,0xDC';
      DNcolor_7 = C'0x00,0x00,0xBE';
      DNcolor_8 = C'0x00,0x00,0xA0';
      DNcolor_9 = C'0x00,0x00,0x8C';
   }
   if (AutoUP_color == SeaGreen) {
      UPcolor_1 = C'0x66,0xCC,0x94';
      UPcolor_2 = C'0x54,0xC7,0x88';
      UPcolor_3 = C'0x46,0xC1,0x7D';
      UPcolor_4 = C'0x3C,0xB5,0x72';
      UPcolor_5 = C'0x37,0xA8,0x6A';
      UPcolor_6 = C'0x31,0x93,0x5C';
      UPcolor_7 = C'0x2C,0x7E,0x53';
      UPcolor_8 = C'0x26,0x6E,0x49';
      UPcolor_9 = C'0x22,0x5F,0x3F';
   }
   if (AutoUP_color == Gold) {
      UPcolor_1 = Gold;
      UPcolor_2 = Gold;
      UPcolor_3 = Gold;
      UPcolor_4 = C'0xDC,0xBE,0x00';
      UPcolor_5 = C'0xD2,0xB4,0x00';
      UPcolor_6 = C'0xB4,0xA0,0x00';
      UPcolor_7 = C'0xA0,0x82,0x00';
      UPcolor_8 = C'0x82,0x6E,0x00';
      UPcolor_9 = C'0x6E,0x5A,0x00';
   }
   if (AutoDN_color == Orange) {
      DNcolor_1 = C'0xFF,0xBE,0x3C';
      DNcolor_2 = C'0xFF,0xB4,0x1E';
      DNcolor_3 = C'0xFF,0xAA,0x0D';
      DNcolor_4 = C'0xFF,0x96,0x0B';
      DNcolor_5 = C'0xFF,0x82,0x09';
      DNcolor_6 = C'0xF0,0x78,0x00';
      DNcolor_7 = C'0xDC,0x6E,0x00';
      DNcolor_8 = C'0xBE,0x5A,0x00';
      DNcolor_9 = C'0x96,0x46,0x00';
   }
   if (AutoUP_color == Gray) {
      UPcolor_1 = C'0xB4,0xB4,0xB4';
      UPcolor_2 = C'0xA5,0xA5,0xA5';
      UPcolor_3 = C'0x96,0x96,0x96';
      UPcolor_4 = C'0x87,0x87,0x87';
      UPcolor_5 = C'0x78,0x78,0x78';
      UPcolor_6 = DimGray;
      UPcolor_7 = C'0x5A,0x5A,0x5A';
      UPcolor_8 = C'0x4B,0x4B,0x4B';
      UPcolor_9 = C'0x3C,0x3C,0x3C';
   }
   if (AutoDN_color == Gray) {
      DNcolor_1 = C'0xB4,0xB4,0xB4';
      DNcolor_2 = C'0xA5,0xA5,0xA5';
      DNcolor_3 = C'0x96,0x96,0x96';
      DNcolor_4 = C'0x87,0x87,0x87';
      DNcolor_5 = C'0x78,0x78,0x78';
      DNcolor_6 = DimGray;
      DNcolor_7 = C'0x5A,0x5A,0x5A';
      DNcolor_8 = C'0x4B,0x4B,0x4B';
      DNcolor_9 = C'0x3C,0x3C,0x3C';
   }
   if (AutoUP_color == RoyalBlue) {
      UPcolor_1 = C'0x98,0xAE,0xEF';
      UPcolor_2 = C'0x8B,0xA4,0xED';
      UPcolor_3 = C'0x7E,0x9A,0xEB';
      UPcolor_4 = C'0x66,0x87,0xE8';
      UPcolor_5 = C'0x52,0x77,0xE4';
      UPcolor_6 = C'0x42,0x6A,0xE1';
      UPcolor_7 = C'0x2E,0x5A,0xDE';
      UPcolor_8 = C'0x20,0x4B,0xCC';
      UPcolor_9 = C'0x1B,0x3E,0xA7';
   }
   if (AutoDN_color == RoyalBlue) {
      DNcolor_1 = C'0x98,0xAE,0xEF';
      DNcolor_2 = C'0x8B,0xA4,0xED';
      DNcolor_3 = C'0x7E,0x9A,0xEB';
      DNcolor_4 = C'0x66,0x87,0xE8';
      DNcolor_5 = C'0x52,0x77,0xE4';
      DNcolor_6 = C'0x42,0x6A,0xE1';
      DNcolor_7 = C'0x2E,0x5A,0xDE';
      DNcolor_8 = C'0x20,0x4B,0xCC';
      DNcolor_9 = C'0x1B,0x3E,0xA7';
   }
   if (AutoDN_color == MediumVioletRed) {
      DNcolor_1 = C'0xEE,0x60,0xB9';
      DNcolor_2 = C'0xEA,0x37,0xA7';
      DNcolor_3 = C'0xDB,0x17,0x92';
      DNcolor_4 = C'0xC4,0x15,0x83';
      DNcolor_5 = C'0xB3,0x13,0x77';
      DNcolor_6 = C'0x9F,0x11,0x6A';
      DNcolor_7 = C'0x8C,0x0F,0x5E';
      DNcolor_8 = C'0x7C,0x0D,0x52';
      DNcolor_9 = C'0x68,0x0C,0x47';
   }
   if (AutoUP_color == Olive) {
      UPcolor_1 = C'0xDF,0xDF,0x00';
      UPcolor_2 = C'0xCB,0xCB,0x00';
      UPcolor_3 = C'0xB7,0xB7,0x00';
      UPcolor_4 = C'0xA3,0xA3,0x00';
      UPcolor_5 = C'0x8F,0x8F,0x00';
      UPcolor_6 = C'0x7B,0x7B,0x00';
      UPcolor_7 = C'0x67,0x67,0x00';
      UPcolor_8 = C'0x53,0x53,0x00';
      UPcolor_9 = C'0x3F,0x3F,0x00';
   }
   if (AutoDN_color == Fuchsia) {
      DNcolor_1 = C'0xFF,0xA0,0xFF';
      DNcolor_2 = C'0xFF,0x82,0xFF';
      DNcolor_3 = C'0xFF,0x64,0xFF';
      DNcolor_4 = C'0xFF,0x50,0xFF';
      DNcolor_5 = C'0xFA,0x00,0xFA';
      DNcolor_6 = C'0xDC,0x00,0xDC';
      DNcolor_7 = C'0xBE,0x00,0xBE';
      DNcolor_8 = C'0xA0,0x00,0xA0';
      DNcolor_9 = C'0x82,0x00,0x82';
   }
   return (0);
}

int deinit() {
   ObjectDelete("ALLTrend_UP");
   ObjectDelete("ALLTrend_DOWN");
   ObjectDelete("SIG_LEVEL" + Dynamic_Number);
   ObjectDelete("SIG_LEVEL_1" + Dynamic_Number);
   ObjectDelete("SIG_LEVEL_2" + Dynamic_Number);
   ObjectDelete("SIG_LEVEL_3" + Dynamic_Number);
   ObjectDelete("SIG_LEVEL_4" + Dynamic_Number);
   ObjectDelete("SIG_LEVEL_5" + Dynamic_Number);
   ObjectDelete("SIG_LEVEL_6" + Dynamic_Number);
   ObjectDelete("SIG_LEVEL_7" + Dynamic_Number);
   ObjectDelete("SIG_LEVEL_8" + Dynamic_Number);
   ObjectDelete("SIG_LEVEL_9" + Dynamic_Number);
   ObjectDelete("SIG_LEVEL_10" + Dynamic_Number);
   ObjectDelete("SIG_LEVEL_11" + Dynamic_Number);
   ObjectDelete("SIG_LEVEL_12" + Dynamic_Number);
   ObjectDelete("SIG_LEVEL_13" + Dynamic_Number);
   ObjectDelete("SIG_LEVEL_14" + Dynamic_Number);
   ObjectDelete("SIG_LEVEL_15" + Dynamic_Number);
   ObjectDelete("SIG_LEVEL_16" + Dynamic_Number);
   ObjectDelete("SIG_LEVEL_17" + Dynamic_Number);
   ObjectDelete("H4_LEVEL" + Dynamic_Number);
   ObjectDelete("H4_LEVEL_1" + Dynamic_Number);
   ObjectDelete("H4_LEVEL_2" + Dynamic_Number);
   ObjectDelete("H4_LEVEL_3" + Dynamic_Number);
   ObjectDelete("H4_LEVEL_4" + Dynamic_Number);
   ObjectDelete("H4_LEVEL_5" + Dynamic_Number);
   ObjectDelete("H4_LEVEL_6" + Dynamic_Number);
   ObjectDelete("H4_LEVEL_7" + Dynamic_Number);
   ObjectDelete("H4_LEVEL_8" + Dynamic_Number);
   ObjectDelete("H4_LEVEL_9" + Dynamic_Number);
   ObjectDelete("H4_LEVEL_10" + Dynamic_Number);
   ObjectDelete("H4_LEVEL_11" + Dynamic_Number);
   ObjectDelete("H4_LEVEL_12" + Dynamic_Number);
   ObjectDelete("H4_LEVEL_13" + Dynamic_Number);
   ObjectDelete("H4_LEVEL_14" + Dynamic_Number);
   ObjectDelete("H4_LEVEL_15" + Dynamic_Number);
   ObjectDelete("H4_LEVEL_16" + Dynamic_Number);
   ObjectDelete("H4_LEVEL_17" + Dynamic_Number);
   ObjectDelete("M30_LEVEL" + Dynamic_Number);
   ObjectDelete("M30_LEVEL_1" + Dynamic_Number);
   ObjectDelete("M30_LEVEL_2" + Dynamic_Number);
   ObjectDelete("M30_LEVEL_3" + Dynamic_Number);
   ObjectDelete("M30_LEVEL_4" + Dynamic_Number);
   ObjectDelete("M30_LEVEL_5" + Dynamic_Number);
   ObjectDelete("M30_LEVEL_6" + Dynamic_Number);
   ObjectDelete("M30_LEVEL_7" + Dynamic_Number);
   ObjectDelete("M30_LEVEL_8" + Dynamic_Number);
   ObjectDelete("M30_LEVEL_9" + Dynamic_Number);
   ObjectDelete("M30_LEVEL_10" + Dynamic_Number);
   ObjectDelete("M30_LEVEL_11" + Dynamic_Number);
   ObjectDelete("M30_LEVEL_12" + Dynamic_Number);
   ObjectDelete("M30_LEVEL_13" + Dynamic_Number);
   ObjectDelete("M30_LEVEL_14" + Dynamic_Number);
   ObjectDelete("M30_LEVEL_15" + Dynamic_Number);
   ObjectDelete("M30_LEVEL_16" + Dynamic_Number);
   ObjectDelete("M30_LEVEL_17" + Dynamic_Number);
   ObjectDelete("M5_LEVEL" + Dynamic_Number);
   ObjectDelete("M5_LEVEL_1" + Dynamic_Number);
   ObjectDelete("M5_LEVEL_2" + Dynamic_Number);
   ObjectDelete("M5_LEVEL_3" + Dynamic_Number);
   ObjectDelete("M5_LEVEL_4" + Dynamic_Number);
   ObjectDelete("M5_LEVEL_5" + Dynamic_Number);
   ObjectDelete("M5_LEVEL_6" + Dynamic_Number);
   ObjectDelete("M5_LEVEL_7" + Dynamic_Number);
   ObjectDelete("M5_LEVEL_8" + Dynamic_Number);
   ObjectDelete("M5_LEVEL_9" + Dynamic_Number);
   ObjectDelete("M5_LEVEL_10" + Dynamic_Number);
   ObjectDelete("M5_LEVEL_11" + Dynamic_Number);
   ObjectDelete("M5_LEVEL_12" + Dynamic_Number);
   ObjectDelete("M5_LEVEL_13" + Dynamic_Number);
   ObjectDelete("M5_LEVEL_14" + Dynamic_Number);
   ObjectDelete("M5_LEVEL_15" + Dynamic_Number);
   ObjectDelete("M5_LEVEL_16" + Dynamic_Number);
   ObjectDelete("M5_LEVEL_17" + Dynamic_Number);
   ObjectDelete("TREND_Display" + Dynamic_Number);
   ObjectDelete("TREND_Display1" + Dynamic_Number);
   ObjectDelete("TREND_Display2" + Dynamic_Number);
   ObjectDelete("TREND_Display3" + Dynamic_Number);
   ObjectDelete("TREND_Display4" + Dynamic_Number);
   ObjectDelete("TREND_Display5" + Dynamic_Number);
   ObjectDelete("TREND_Display6" + Dynamic_Number);
   ObjectDelete("TREND_Display7" + Dynamic_Number);
   ObjectDelete("TREND_Display8" + Dynamic_Number);
   ObjectDelete("SIG_RESULTS" + Dynamic_Number);
   ObjectDelete("EXPIRED" + Dynamic_Number);
   ObjectDelete("EXPIRED1" + Dynamic_Number);
   ObjectDelete("EXPIRED2" + Dynamic_Number);
   ObjectDelete("EXPIRED3" + Dynamic_Number);
   ObjectDelete("EXPIRED4" + Dynamic_Number);
   ObjectDelete("EXPIRED5" + Dynamic_Number);
   ObjectDelete("EXPIRED6" + Dynamic_Number);
   ObjectDelete("EXPIRED7" + Dynamic_Number);
   ObjectDelete("EXPIRED8" + Dynamic_Number);
   ObjectDelete("BCKGRND01" + Dynamic_Number);
   ObjectDelete("BCKGRND02" + Dynamic_Number);
   ObjectDelete("BCKGRND03" + Dynamic_Number);
   ObjectDelete("BCKGRND04" + Dynamic_Number);
   return (0);
}

int start() {
   int Li_unused_0;
   double Ld_4;
   double Ld_12;
   double Ld_20;
   double Ld_28;
   double Ld_36;
   double Ld_44;
   double Ld_52;
   double Ld_60;
   double Ld_68;
   double Ld_76;
   double Ld_84;
   double Ld_92;
   double Ld_100;
   double Ld_108;
   double Ld_116;
   double Ld_124;
   double Ld_132;
   double Ld_140;
   double Ld_148;
   double Ld_156;
   double Ld_164;
   double Ld_172;
   double Ld_180;
   double Ld_188;
   double Ld_196;
   double Ld_204;
   double Ld_212;
   double Ld_220;
   double Ld_228;
   double Ld_236;
   double Ld_244;
   double Ld_252;
   double Ld_260;
   double Ld_268;
   double Ld_276;
   double Ld_284;
   double Ld_292;
   double Ld_300;
   double Ld_308;
   double Ld_unused_316;
   double Ld_324;
   double Ld_332;
   double Ld_340;
   double Ld_348;
   double Ld_356;
   double Ld_364;
   double Ld_372;
   double Ld_380;
   double Ld_388;
   double Ld_396;
   double Ld_404;
   double Ld_412;
   double Ld_420;
   double Ld_428;
   double Ld_436;
   double Ld_444;
   double Ld_452;
   double Ld_460;
   double Ld_468;
   double Ld_476;
   double Ld_484;
   double Ld_492;
   double Ld_500;
   double Ld_508;
   double Ld_516;
   double Ld_524;
   double Ld_532;
   double Ld_540;
   double Ld_548;
   double Ld_556;
   double Ld_564;
   double Ld_572;
   double Ld_580;
   double Ld_588;
   double Ld_596;
   double Ld_604;
   double Ld_612;
   double Ld_620;
   double Ld_628;
   double Ld_636;
   double Ld_644;
   double Ld_652;
   double Ld_660;
   double Ld_668;
   double Ld_676;
   double Ld_684;
   double Ld_692;
   double Ld_700;
   double Ld_708;
   double Ld_716;
   double Ld_724;
   double Ld_732;
   double Ld_740;
   double Ld_748;
   double Ld_756;
   double Ld_764;
   double Ld_772;
   double Ld_780;
   double Ld_788;
   double Ld_796;
   double Ld_804;
   double Ld_812;
   double Ld_820;
   double Ld_828;
   double Ld_836;
   double Ld_844;
   double Ld_852;
   double Ld_860;
   double Ld_868;
   double Ld_876;
   double Ld_884;
   double Ld_892;
   double Ld_900;
   double Ld_908;
   double Ld_916;
   double Ld_924;
   double Ld_932;
   double Ld_940;
   double Ld_948;
   double Ld_956;
   double Ld_964;
   double Ld_972;
   double Ld_980;
   double Ld_988;
   double Ld_996;
   double Ld_1004;
   double Ld_1012;
   double Ld_1020;
   double Ld_1028;
   double Ld_1036;
   double Ld_1044;
   double Ld_1052;
   double Ld_1060;
   double Ld_1068;
   double Ld_1076;
   double Ld_1084;
   double Ld_1092;
   double Ld_1100;
   double Ld_1108;
   double Ld_1116;
   double Ld_1124;
   double Ld_1132;
   double Ld_1140;
   double Ld_1148;
   double Ld_1156;
   double Ld_1164;
   double Ld_1172;
   double Ld_1180;
   double Ld_1188;
   double Ld_1196;
   double Ld_1204;
   double Ld_1212;
   double Ld_1220;
   double Ld_1228;
   double Ld_1236;
   double Ld_1244;
   double Ld_1252;
   double Ld_1260;
   double Ld_1268;
   double Ld_1276;
   double Ld_1284;
   double Ld_1292;
   double Ld_1300;
   double Ld_1308;
   double Ld_1316;
   double Ld_1324;
   double Ld_1332;
   double Ld_1340;
   double Ld_1348;
   double Ld_1356;
   double Ld_1364;
   double Ld_1372;
   double Ld_1380;
   double Ld_1388;
   double Ld_1396;
   double Ld_1404;
   double Ld_1412;
   double Ld_1420;
   double Ld_1428;
   double Ld_1436;
   double Ld_1444;
   double Ld_1452;
   double Ld_1460;
   double Ld_1468;
   double Ld_1476;
   double Ld_1484;
   double Ld_1492;
   double Ld_1500;
   double Ld_1508;
   double Ld_1516;
   double Ld_1524;
   double Ld_1532;
   double Ld_1540;
   double Ld_1548;
   double Ld_1556;
   double Ld_1564;
   double Ld_1572;
   double Ld_1580;
   double Ld_1588;
   double Ld_1596;
   double Ld_1604;
   double Ld_1612;
   double Ld_1620;
   double Ld_1628;
   double Ld_1636;
   double Ld_1644;
   double Ld_1652;
   double Ld_1660;
   double Ld_1668;
   double Ld_1676;
   double Ld_1684;
   double Ld_1692;
   double Ld_1700;
   double Ld_1708;
   double Ld_1716;
   double Ld_1724;
   double Ld_1732;
   double Ld_1740;
   double Ld_1748;
   double Ld_1756;
   double Ld_1764;
   double Ld_1772;
   double Ld_1780;
   double Ld_1788;
   double Ld_1796;
   double Ld_1804;
   double Ld_1812;
   double Ld_1820;
   double Ld_1828;
   double Ld_1836;
   double Ld_1844;
   double Ld_1852;
   double Ld_1860;
   double Ld_1868;
   double Ld_1876;
   double Ld_1884;
   double Ld_1892;
   double Ld_1900;
   double Ld_1908;
   double Ld_1916;
   double Ld_1924;
   double Ld_1932;
   double Ld_1940;
   double Ld_1948;
   double Ld_1956;
   double Ld_1964;
   double Ld_1972;
   double Ld_1980;
   double Ld_1988;
   double Ld_1996;
   double Ld_2004;
   double Ld_2012;
   double Ld_2020;
   double Ld_2028;
   double Ld_2036;
   double Ld_2044;
   double Ld_2052;
   double Ld_2060;
   double Ld_2068;
   double Ld_2076;
   double Ld_2084;
   double Ld_2092;
   double Ld_2100;
   double Ld_2108;
   double Ld_2116;
   double Ld_2124;
   double Ld_2132;
   double Ld_2140;
   double Ld_2148;
   double Ld_2156;
   double Ld_2164;
   double Ld_2172;
   double Ld_2180;
   double Ld_2188;
   double Ld_2196;
   double Ld_2204;
   double Ld_2212;
   double Ld_2220;
   double Ld_2228;
   double Ld_2236;
   double Ld_2244;
   double Ld_2252;
   double Ld_2260;
   double Ld_2268;
   double Ld_2276;
   double Ld_2284;
   double Ld_2292;
   double Ld_2300;
   double Ld_2308;
   double Ld_2316;
   double Ld_2324;
   double Ld_2332;
   double Ld_2340;
   double Ld_2348;
   double Ld_2356;
   double Ld_2364;
   double Ld_2372;
   double Ld_2380;
   double Ld_2388;
   double Ld_2396;
   double Ld_2404;
   double Ld_2412;
   double Ld_2420;
   double Ld_2428;
   double Ld_2436;
   double Ld_2444;
   double Ld_2452;
   double Ld_2460;
   double Ld_2468;
   double Ld_2476;
   double Ld_2484;
   double Ld_2492;
   double Ld_2500;
   double Ld_2508;
   double Ld_2516;
   double Ld_2524;
   double Ld_2532;
   double Ld_2540;
   double Ld_2548;
   double Ld_2556;
   double Ld_2564;
   double Ld_2572;
   double Ld_2580;
   double Ld_2588;
   double Ld_2596;
   double Ld_2604;
   double Ld_2612;
   double Ld_2620;
   double Ld_2628;
   double Ld_2636;
   double Ld_2644;
   double Ld_2652;
   double Ld_2660;
   double Ld_2668;
   double Ld_2676;
   double Ld_2684;
   double Ld_2692;
   double Ld_2700;
   double Ld_2708;
   double Ld_2716;
   double Ld_2724;
   double Ld_2732;
   double Ld_2740;
   double Ld_2748;
   double Ld_2756;
   double Ld_2764;
   double Ld_2772;
   double Ld_2780;
   double Ld_2788;
   double Ld_2796;
   double Ld_2804;
   double Ld_2812;
   double Ld_2820;
   double Ld_2828;
   double Ld_2836;
   double Ld_2844;
   double Ld_2852;
   double Ld_2860;
   double Ld_2868;
   double Ld_2876;
   double Ld_2884;
   double Ld_2892;
   double Ld_2900;
   double Ld_2908;
   double Ld_2916;
   double Ld_2924;
   double Ld_2932;
   double Ld_2940;
   double Ld_2948;
   double Ld_2956;
   double Ld_2964;
   double Ld_2972;
   double Ld_2980;
   double Ld_2988;
   double Ld_2996;
   double Ld_3004;
   double Ld_3012;
   double Ld_3020;
   double Ld_3028;
   double Ld_3036;
   double Ld_3044;
   double Ld_3052;
   double Ld_3060;
   double Ld_3068;
   double Ld_3076;
   double Ld_3084;
   double Ld_3092;
   double Ld_3100;
   double Ld_3108;
   double Ld_3116;
   double Ld_3124;
   double Ld_3132;
   double Ld_3140;
   double Ld_3148;
   double Ld_3156;
   double Ld_3164;
   double Ld_3172;
   double Ld_3180;
   double Ld_3188;
   double Ld_3196;
   double Ld_3204;
   double Ld_3212;
   double Ld_3220;
   double Ld_3228;
   double Ld_3236;
   double Ld_3244;
   double Ld_3252;
   double Ld_3260;
   double Ld_3268;
   double Ld_3276;
   double Ld_3284;
   double Ld_3292;
   double Ld_3300;
   double Ld_3308;
   double Ld_3316;
   double Ld_3324;
   double Ld_3332;
   double Ld_3340;
   double Ld_3348;
   double Ld_3356;
   double Ld_3364;
   double Ld_3372;
   double Ld_3380;
   double Ld_3388;
   double Ld_3396;
   double Ld_3404;
   double Ld_3412;
   double Ld_3420;
   double Ld_3428;
   double Ld_3436;
   double Ld_3444;
   color color_3452;
   color color_3456;
   color color_3460;
   color color_3464;
   color color_3468;
   color color_3472;
   color color_3476;
   color color_3480;
   color color_3484;
   color color_3488;
   color color_3492;
   color color_3496;
   color color_3500;
   color color_3504;
   color color_3508;
   color color_3512;
   color color_3516;
   color color_3520;
   color color_3524;
   color color_3528;
   color color_3532;
   color color_3536;
   color color_3540;
   color color_3544;
   color color_3548;
   color color_3552;
   color color_3556;
   color color_3560;
   color color_3564;
   color color_3568;
   color color_3572;
   color color_3576;
   color color_3580;
   color color_3584;
   color color_3588;
   color color_3592;
   color color_3596;
   color color_3600;
   color color_3604;
   color color_3608;
   color color_3612;
   color color_3616;
   color color_3620;
   color color_3624;
   color color_3628;
   color color_3632;
   color color_3636;
   color color_3640;
   color color_3644;
   color color_3648;
   color color_3652;
   color color_3656;
   color color_3660;
   color color_3664;
   color color_3668;
   color color_3672;
   color color_3676;
   color color_3680;
   color color_3684;
   color color_3688;
   color color_3692;
   color color_3696;
   color color_3700;
   color color_3704;
   color color_3708;
   color color_3712;
   color color_3716;
   color color_3720;
   color color_3724;
   color color_3728;
   color color_3732;
   color color_3736;
   color color_3740;
   double Ld_3744 = NormalizeDouble(MarketInfo(Symbol(), MODE_BID), Digits);
   double ima_3752 = iMA(Symbol(), PERIOD_M1, 1, 0, MODE_EMA, PRICE_CLOSE, 1);
   string Ls_unused_3760 = "";
   if (ima_3752 > Ld_3744) {
      Ls_unused_3760 = "";
      Li_unused_0 = 9109504;
      Gd_unused_340 = 36095;
   }
   if (ima_3752 < Ld_3744) {
      Ls_unused_3760 = "";
      Li_unused_0 = 12632256;
      Gd_unused_340 = 255;
   }
   if (ima_3752 == Ld_3744) {
      Ls_unused_3760 = "";
      Li_unused_0 = 36095;
      Gd_unused_340 = 16711680;
   }
   if (BarsShift_UP_DN < 0) return (0);
   if (Currency_Symbol == "") Currency_Symbol = Symbol();
   if (StringFind(Currency_Symbol, "JPY", 0) != -1) Gi_328 = 2;
   else Gi_328 = 4;
   double Ld_3768 = NormalizeDouble(MarketInfo(Currency_Symbol, MODE_BID), Gi_328);
   double Ld_3776 = (iHigh(Currency_Symbol, PERIOD_M1, 0) + iLow(Currency_Symbol, PERIOD_M1, 0) + iClose(Currency_Symbol, PERIOD_M1, 0)) / 3.0;
   double Ld_3784 = (iHigh(Currency_Symbol, PERIOD_M1, 1) + iLow(Currency_Symbol, PERIOD_M1, 1) + iClose(Currency_Symbol, PERIOD_M1, 1)) / 3.0;
   double Ld_3792 = (iHigh(Currency_Symbol, PERIOD_M1, 2) + iLow(Currency_Symbol, PERIOD_M1, 2) + iClose(Currency_Symbol, PERIOD_M1, 2)) / 3.0;
   double Ld_3800 = (iHigh(Currency_Symbol, PERIOD_M1, 3) + iLow(Currency_Symbol, PERIOD_M1, 3) + iClose(Currency_Symbol, PERIOD_M1, 3)) / 3.0;
   double Ld_3808 = (iHigh(Currency_Symbol, PERIOD_M1, 4) + iLow(Currency_Symbol, PERIOD_M1, 4) + iClose(Currency_Symbol, PERIOD_M1, 4)) / 3.0;
   double Ld_3816 = (iHigh(Currency_Symbol, PERIOD_M1, 5) + iLow(Currency_Symbol, PERIOD_M1, 5) + iClose(Currency_Symbol, PERIOD_M1, 5)) / 3.0;
   double Ld_3824 = 2.0 * Ld_3776 + (iHigh(Currency_Symbol, PERIOD_M1, 0) - 2.0 * iLow(Currency_Symbol, PERIOD_M1, 0));
   double Ld_3832 = 2.0 * Ld_3784 + (iHigh(Currency_Symbol, PERIOD_M1, 1) - 2.0 * iLow(Currency_Symbol, PERIOD_M1, 1));
   double Ld_3840 = 2.0 * Ld_3792 + (iHigh(Currency_Symbol, PERIOD_M1, 2) - 2.0 * iLow(Currency_Symbol, PERIOD_M1, 2));
   double Ld_3848 = 2.0 * Ld_3800 + (iHigh(Currency_Symbol, PERIOD_M1, 3) - 2.0 * iLow(Currency_Symbol, PERIOD_M1, 3));
   double Ld_3856 = 2.0 * Ld_3808 + (iHigh(Currency_Symbol, PERIOD_M1, 4) - 2.0 * iLow(Currency_Symbol, PERIOD_M1, 4));
   double Ld_3864 = 2.0 * Ld_3816 + (iHigh(Currency_Symbol, PERIOD_M1, 5) - 2.0 * iLow(Currency_Symbol, PERIOD_M1, 5));
   double Ld_3872 = Ld_3776 + (iHigh(Currency_Symbol, PERIOD_M1, 0) - iLow(Currency_Symbol, PERIOD_M1, 0));
   double Ld_3880 = Ld_3784 + (iHigh(Currency_Symbol, PERIOD_M1, 1) - iLow(Currency_Symbol, PERIOD_M1, 1));
   double Ld_3888 = Ld_3792 + (iHigh(Currency_Symbol, PERIOD_M1, 2) - iLow(Currency_Symbol, PERIOD_M1, 2));
   double Ld_3896 = Ld_3800 + (iHigh(Currency_Symbol, PERIOD_M1, 3) - iLow(Currency_Symbol, PERIOD_M1, 3));
   double Ld_3904 = Ld_3808 + (iHigh(Currency_Symbol, PERIOD_M1, 4) - iLow(Currency_Symbol, PERIOD_M1, 4));
   double Ld_3912 = Ld_3816 + (iHigh(Currency_Symbol, PERIOD_M1, 5) - iLow(Currency_Symbol, PERIOD_M1, 5));
   double Ld_3920 = 2.0 * Ld_3776 - iLow(Currency_Symbol, PERIOD_M1, 0);
   double Ld_3928 = 2.0 * Ld_3784 - iLow(Currency_Symbol, PERIOD_M1, 1);
   double Ld_3936 = 2.0 * Ld_3792 - iLow(Currency_Symbol, PERIOD_M1, 2);
   double Ld_3944 = 2.0 * Ld_3800 - iLow(Currency_Symbol, PERIOD_M1, 3);
   double Ld_3952 = 2.0 * Ld_3808 - iLow(Currency_Symbol, PERIOD_M1, 4);
   double Ld_3960 = 2.0 * Ld_3816 - iLow(Currency_Symbol, PERIOD_M1, 5);
   double Ld_3968 = (iHigh(Currency_Symbol, PERIOD_M1, 0) + iLow(Currency_Symbol, PERIOD_M1, 0) + iClose(Currency_Symbol, PERIOD_M1, 0)) / 3.0;
   double Ld_3976 = (iHigh(Currency_Symbol, PERIOD_M1, 1) + iLow(Currency_Symbol, PERIOD_M1, 1) + iClose(Currency_Symbol, PERIOD_M1, 1)) / 3.0;
   double Ld_3984 = (iHigh(Currency_Symbol, PERIOD_M1, 2) + iLow(Currency_Symbol, PERIOD_M1, 2) + iClose(Currency_Symbol, PERIOD_M1, 2)) / 3.0;
   double Ld_3992 = (iHigh(Currency_Symbol, PERIOD_M1, 3) + iLow(Currency_Symbol, PERIOD_M1, 3) + iClose(Currency_Symbol, PERIOD_M1, 3)) / 3.0;
   double Ld_4000 = (iHigh(Currency_Symbol, PERIOD_M1, 4) + iLow(Currency_Symbol, PERIOD_M1, 4) + iClose(Currency_Symbol, PERIOD_M1, 4)) / 3.0;
   double Ld_4008 = (iHigh(Currency_Symbol, PERIOD_M1, 5) + iLow(Currency_Symbol, PERIOD_M1, 5) + iClose(Currency_Symbol, PERIOD_M1, 5)) / 3.0;
   double Ld_4016 = 2.0 * Ld_3776 - iHigh(Currency_Symbol, PERIOD_M1, 0);
   double Ld_4024 = 2.0 * Ld_3784 - iHigh(Currency_Symbol, PERIOD_M1, 1);
   double Ld_4032 = 2.0 * Ld_3792 - iHigh(Currency_Symbol, PERIOD_M1, 2);
   double Ld_4040 = 2.0 * Ld_3800 - iHigh(Currency_Symbol, PERIOD_M1, 3);
   double Ld_4048 = 2.0 * Ld_3808 - iHigh(Currency_Symbol, PERIOD_M1, 4);
   double Ld_4056 = 2.0 * Ld_3816 - iHigh(Currency_Symbol, PERIOD_M1, 5);
   double Ld_4064 = Ld_3776 - (iHigh(Currency_Symbol, PERIOD_M1, 0) - iLow(Currency_Symbol, PERIOD_M1, 0));
   double Ld_4072 = Ld_3784 - (iHigh(Currency_Symbol, PERIOD_M1, 1) - iLow(Currency_Symbol, PERIOD_M1, 1));
   double Ld_4080 = Ld_3792 - (iHigh(Currency_Symbol, PERIOD_M1, 2) - iLow(Currency_Symbol, PERIOD_M1, 2));
   double Ld_4088 = Ld_3800 - (iHigh(Currency_Symbol, PERIOD_M1, 3) - iLow(Currency_Symbol, PERIOD_M1, 3));
   double Ld_4096 = Ld_3808 - (iHigh(Currency_Symbol, PERIOD_M1, 4) - iLow(Currency_Symbol, PERIOD_M1, 4));
   double Ld_4104 = Ld_3816 - (iHigh(Currency_Symbol, PERIOD_M1, 5) - iLow(Currency_Symbol, PERIOD_M1, 5));
   double Ld_4112 = 2.0 * Ld_3776 - (2.0 * iHigh(Currency_Symbol, PERIOD_M1, 0) - iLow(Currency_Symbol, PERIOD_M1, 0));
   double Ld_4120 = 2.0 * Ld_3784 - (2.0 * iHigh(Currency_Symbol, PERIOD_M1, 1) - iLow(Currency_Symbol, PERIOD_M1, 1));
   double Ld_4128 = 2.0 * Ld_3792 - (2.0 * iHigh(Currency_Symbol, PERIOD_M1, 2) - iLow(Currency_Symbol, PERIOD_M1, 2));
   double Ld_4136 = 2.0 * Ld_3800 - (2.0 * iHigh(Currency_Symbol, PERIOD_M1, 3) - iLow(Currency_Symbol, PERIOD_M1, 3));
   double Ld_4144 = 2.0 * Ld_3808 - (2.0 * iHigh(Currency_Symbol, PERIOD_M1, 4) - iLow(Currency_Symbol, PERIOD_M1, 4));
   double Ld_4152 = 2.0 * Ld_3816 - (2.0 * iHigh(Currency_Symbol, PERIOD_M1, 5) - iLow(Currency_Symbol, PERIOD_M1, 5));
   if (Ld_3776 > Ld_3768) {
      Ld_4 = 0;
      Ld_284 = 1;
   }
   if (Ld_3776 < Ld_3768) {
      Ld_4 = 1;
      Ld_284 = 0;
   }
   if (Ld_3784 > Ld_3768) {
      Ld_12 = 0;
      Ld_292 = 1;
   }
   if (Ld_3784 < Ld_3768) {
      Ld_12 = 1;
      Ld_292 = 0;
   }
   if (Ld_3792 > Ld_3768) {
      Ld_20 = 0;
      Ld_300 = 1;
   }
   if (Ld_3792 < Ld_3768) {
      Ld_20 = 1;
      Ld_300 = 0;
   }
   if (Ld_3800 > Ld_3768) {
      Ld_28 = 0;
      Ld_308 = 1;
   }
   if (Ld_3800 < Ld_3768) {
      Ld_28 = 1;
      Ld_308 = 0;
   }
   if (Ld_3808 > Ld_3768) {
      Ld_4 = 0;
      Ld_unused_316 = 1;
   }
   if (Ld_3808 < Ld_3768) {
      Ld_4 = 1;
      Ld_unused_316 = 0;
   }
   if (Ld_3920 > Ld_3768) {
      Ld_36 = 0;
      Ld_324 = 1;
   }
   if (Ld_3920 < Ld_3768) {
      Ld_36 = 1;
      Ld_324 = 0;
   }
   if (Ld_3928 > Ld_3768) {
      Ld_44 = 0;
      Ld_332 = 1;
   }
   if (Ld_3928 < Ld_3768) {
      Ld_44 = 1;
      Ld_332 = 0;
   }
   if (Ld_3936 > Ld_3768) {
      Ld_52 = 0;
      Ld_340 = 1;
   }
   if (Ld_3936 < Ld_3768) {
      Ld_52 = 1;
      Ld_340 = 0;
   }
   if (Ld_3944 > Ld_3768) {
      Ld_60 = 0;
      Ld_348 = 1;
   }
   if (Ld_3944 < Ld_3768) {
      Ld_60 = 1;
      Ld_348 = 0;
   }
   if (Ld_3952 > Ld_3768) {
      Ld_68 = 0;
      Ld_356 = 1;
   }
   if (Ld_3952 < Ld_3768) {
      Ld_68 = 1;
      Ld_356 = 0;
   }
   if (Ld_3960 > Ld_3768) {
      Ld_76 = 0;
      Ld_364 = 1;
   }
   if (Ld_3960 < Ld_3768) {
      Ld_76 = 1;
      Ld_364 = 0;
   }
   if (Ld_4016 > Ld_3768) {
      Ld_84 = 0;
      Ld_372 = 1;
   }
   if (Ld_4016 < Ld_3768) {
      Ld_84 = 1;
      Ld_372 = 0;
   }
   if (Ld_4024 > Ld_3768) {
      Ld_92 = 0;
      Ld_380 = 1;
   }
   if (Ld_4024 < Ld_3768) {
      Ld_92 = 1;
      Ld_380 = 0;
   }
   if (Ld_4032 > Ld_3768) {
      Ld_100 = 0;
      Ld_388 = 1;
   }
   if (Ld_4032 < Ld_3768) {
      Ld_100 = 1;
      Ld_388 = 0;
   }
   if (Ld_4040 > Ld_3768) {
      Ld_108 = 0;
      Ld_396 = 1;
   }
   if (Ld_4040 < Ld_3768) {
      Ld_108 = 1;
      Ld_396 = 0;
   }
   if (Ld_4048 > Ld_3768) {
      Ld_116 = 0;
      Ld_404 = 1;
   }
   if (Ld_4048 < Ld_3768) {
      Ld_116 = 1;
      Ld_404 = 0;
   }
   if (Ld_4056 > Ld_3768) {
      Ld_124 = 0;
      Ld_412 = 1;
   }
   if (Ld_4056 < Ld_3768) {
      Ld_124 = 1;
      Ld_412 = 0;
   }
   if (Ld_3872 > Ld_3768) {
      Ld_132 = 0;
      Ld_420 = 1;
   }
   if (Ld_3872 < Ld_3768) {
      Ld_132 = 1;
      Ld_420 = 0;
   }
   if (Ld_3880 > Ld_3768) {
      Ld_140 = 0;
      Ld_428 = 1;
   }
   if (Ld_3880 < Ld_3768) {
      Ld_140 = 1;
      Ld_428 = 0;
   }
   if (Ld_3888 > Ld_3768) {
      Ld_148 = 0;
      Ld_436 = 1;
   }
   if (Ld_3888 < Ld_3768) {
      Ld_148 = 1;
      Ld_436 = 0;
   }
   if (Ld_3896 > Ld_3768) {
      Ld_156 = 0;
      Ld_444 = 1;
   }
   if (Ld_3896 < Ld_3768) {
      Ld_156 = 1;
      Ld_444 = 0;
   }
   if (Ld_3904 > Ld_3768) {
      Ld_164 = 0;
      Ld_452 = 1;
   }
   if (Ld_3904 < Ld_3768) {
      Ld_164 = 1;
      Ld_452 = 0;
   }
   if (Ld_3912 > Ld_3768) {
      Ld_172 = 0;
      Ld_460 = 1;
   }
   if (Ld_3912 < Ld_3768) {
      Ld_172 = 1;
      Ld_460 = 0;
   }
   if (Ld_4064 > Ld_3768) {
      Ld_180 = 0;
      Ld_468 = 1;
   }
   if (Ld_4064 < Ld_3768) {
      Ld_180 = 1;
      Ld_468 = 0;
   }
   if (Ld_4072 > Ld_3768) {
      Ld_188 = 0;
      Ld_476 = 1;
   }
   if (Ld_4072 < Ld_3768) {
      Ld_188 = 1;
      Ld_476 = 0;
   }
   if (Ld_4080 > Ld_3768) {
      Ld_196 = 0;
      Ld_484 = 1;
   }
   if (Ld_4080 < Ld_3768) {
      Ld_196 = 1;
      Ld_484 = 0;
   }
   if (Ld_4088 > Ld_3768) {
      Ld_204 = 0;
      Ld_492 = 1;
   }
   if (Ld_4088 < Ld_3768) {
      Ld_204 = 1;
      Ld_492 = 0;
   }
   if (Ld_4096 > Ld_3768) {
      Ld_212 = 0;
      Ld_500 = 1;
   }
   if (Ld_4096 < Ld_3768) {
      Ld_212 = 1;
      Ld_500 = 0;
   }
   if (Ld_4104 > Ld_3768) {
      Ld_220 = 0;
      Ld_508 = 1;
   }
   if (Ld_4104 < Ld_3768) {
      Ld_220 = 1;
      Ld_508 = 0;
   }
   if (Ld_3824 > Ld_3768) {
      Ld_228 = 0;
      Ld_516 = 1;
   }
   if (Ld_3824 < Ld_3768) {
      Ld_228 = 1;
      Ld_516 = 0;
   }
   if (Ld_3832 > Ld_3768) {
      Ld_236 = 0;
      Ld_524 = 1;
   }
   if (Ld_3832 < Ld_3768) {
      Ld_236 = 1;
      Ld_524 = 0;
   }
   if (Ld_3840 > Ld_3768) {
      Ld_244 = 0;
      Ld_532 = 1;
   }
   if (Ld_3840 < Ld_3768) {
      Ld_244 = 1;
      Ld_532 = 0;
   }
   if (Ld_3848 > Ld_3768) {
      Ld_252 = 0;
      Ld_548 = 1;
   }
   if (Ld_3848 < Ld_3768) {
      Ld_252 = 1;
      Ld_548 = 0;
   }
   if (Ld_3856 > Ld_3768) {
      Ld_268 = 0;
      Ld_556 = 1;
   }
   if (Ld_3856 < Ld_3768) {
      Ld_268 = 1;
      Ld_556 = 0;
   }
   if (Ld_3864 > Ld_3768) {
      Ld_276 = 0;
      Ld_564 = 1;
   }
   if (Ld_3864 < Ld_3768) {
      Ld_276 = 1;
      Ld_564 = 0;
   }
   double Ld_4160 = Ld_4 + Ld_12 + Ld_20 + Ld_28 + Ld_4 + Ld_36 + Ld_44 + Ld_52 + Ld_60 + Ld_68 + Ld_76 + Ld_84 + Ld_92 + Ld_100 + Ld_108 + Ld_116 + Ld_124 + Ld_132 +
      Ld_140 + Ld_148 + Ld_156 + Ld_164 + Ld_172 + Ld_180 + Ld_188 + Ld_196 + Ld_204 + Ld_212 + Ld_220 + Ld_228 + Ld_236 + Ld_244 + Ld_252 + Ld_260 + Ld_268 + Ld_276;
   double Ld_4168 = Ld_284 + Ld_292 + Ld_300 + Ld_308 + Ld_284 + Ld_324 + Ld_332 + Ld_340 + Ld_348 + Ld_356 + Ld_364 + Ld_372 + Ld_380 + Ld_388 + Ld_396 + Ld_404 + Ld_412 +
      Ld_420 + Ld_428 + Ld_436 + Ld_444 + Ld_452 + Ld_460 + Ld_468 + Ld_476 + Ld_484 + Ld_492 + Ld_500 + Ld_508 + Ld_516 + Ld_524 + Ld_532 + Ld_540 + Ld_548 + Ld_556 + Ld_564;
   string dbl2str_4176 = DoubleToStr(100.0 * (Ld_4160 / 36.0), 0);
   string dbl2str_4184 = DoubleToStr(100 - StrToDouble(dbl2str_4176), 0);
   double Ld_4192 = (iHigh(Currency_Symbol, PERIOD_M5, 0) + iLow(Currency_Symbol, PERIOD_M5, 0) + iClose(Currency_Symbol, PERIOD_M5, 0)) / 3.0;
   double Ld_4200 = (iHigh(Currency_Symbol, PERIOD_M5, 1) + iLow(Currency_Symbol, PERIOD_M5, 1) + iClose(Currency_Symbol, PERIOD_M5, 1)) / 3.0;
   double Ld_4208 = (iHigh(Currency_Symbol, PERIOD_M5, 2) + iLow(Currency_Symbol, PERIOD_M5, 2) + iClose(Currency_Symbol, PERIOD_M5, 2)) / 3.0;
   double Ld_4216 = (iHigh(Currency_Symbol, PERIOD_M5, 3) + iLow(Currency_Symbol, PERIOD_M5, 3) + iClose(Currency_Symbol, PERIOD_M5, 3)) / 3.0;
   double Ld_4224 = (iHigh(Currency_Symbol, PERIOD_M5, 4) + iLow(Currency_Symbol, PERIOD_M5, 4) + iClose(Currency_Symbol, PERIOD_M5, 4)) / 3.0;
   double Ld_4232 = (iHigh(Currency_Symbol, PERIOD_M5, 5) + iLow(Currency_Symbol, PERIOD_M5, 5) + iClose(Currency_Symbol, PERIOD_M5, 5)) / 3.0;
   double Ld_4240 = 2.0 * Ld_4192 + (iHigh(Currency_Symbol, PERIOD_M5, 0) - 2.0 * iLow(Currency_Symbol, PERIOD_M5, 0));
   double Ld_4248 = 2.0 * Ld_4200 + (iHigh(Currency_Symbol, PERIOD_M5, 1) - 2.0 * iLow(Currency_Symbol, PERIOD_M5, 1));
   double Ld_4256 = 2.0 * Ld_4208 + (iHigh(Currency_Symbol, PERIOD_M5, 2) - 2.0 * iLow(Currency_Symbol, PERIOD_M5, 2));
   double Ld_4264 = 2.0 * Ld_4216 + (iHigh(Currency_Symbol, PERIOD_M5, 3) - 2.0 * iLow(Currency_Symbol, PERIOD_M5, 3));
   double Ld_4272 = 2.0 * Ld_4224 + (iHigh(Currency_Symbol, PERIOD_M5, 4) - 2.0 * iLow(Currency_Symbol, PERIOD_M5, 4));
   double Ld_4280 = 2.0 * Ld_4232 + (iHigh(Currency_Symbol, PERIOD_M5, 5) - 2.0 * iLow(Currency_Symbol, PERIOD_M5, 5));
   double Ld_4288 = Ld_4192 + (iHigh(Currency_Symbol, PERIOD_M5, 0) - iLow(Currency_Symbol, PERIOD_M5, 0));
   double Ld_4296 = Ld_4200 + (iHigh(Currency_Symbol, PERIOD_M5, 1) - iLow(Currency_Symbol, PERIOD_M5, 1));
   double Ld_4304 = Ld_4208 + (iHigh(Currency_Symbol, PERIOD_M5, 2) - iLow(Currency_Symbol, PERIOD_M5, 2));
   double Ld_4312 = Ld_4216 + (iHigh(Currency_Symbol, PERIOD_M5, 3) - iLow(Currency_Symbol, PERIOD_M5, 3));
   double Ld_4320 = Ld_4224 + (iHigh(Currency_Symbol, PERIOD_M5, 4) - iLow(Currency_Symbol, PERIOD_M5, 4));
   double Ld_4328 = Ld_4232 + (iHigh(Currency_Symbol, PERIOD_M5, 5) - iLow(Currency_Symbol, PERIOD_M5, 5));
   double Ld_4336 = 2.0 * Ld_4192 - iLow(Currency_Symbol, PERIOD_M5, 0);
   double Ld_4344 = 2.0 * Ld_4200 - iLow(Currency_Symbol, PERIOD_M5, 1);
   double Ld_4352 = 2.0 * Ld_4208 - iLow(Currency_Symbol, PERIOD_M5, 2);
   double Ld_4360 = 2.0 * Ld_4216 - iLow(Currency_Symbol, PERIOD_M5, 3);
   double Ld_4368 = 2.0 * Ld_4224 - iLow(Currency_Symbol, PERIOD_M5, 4);
   double Ld_4376 = 2.0 * Ld_4232 - iLow(Currency_Symbol, PERIOD_M5, 5);
   double Ld_4384 = (iHigh(Currency_Symbol, PERIOD_M5, 0) + iLow(Currency_Symbol, PERIOD_M5, 0) + iClose(Currency_Symbol, PERIOD_M5, 0)) / 3.0;
   double Ld_4392 = (iHigh(Currency_Symbol, PERIOD_M5, 1) + iLow(Currency_Symbol, PERIOD_M5, 1) + iClose(Currency_Symbol, PERIOD_M5, 1)) / 3.0;
   double Ld_4400 = (iHigh(Currency_Symbol, PERIOD_M5, 2) + iLow(Currency_Symbol, PERIOD_M5, 2) + iClose(Currency_Symbol, PERIOD_M5, 2)) / 3.0;
   double Ld_4408 = (iHigh(Currency_Symbol, PERIOD_M5, 3) + iLow(Currency_Symbol, PERIOD_M5, 3) + iClose(Currency_Symbol, PERIOD_M5, 3)) / 3.0;
   double Ld_4416 = (iHigh(Currency_Symbol, PERIOD_M5, 4) + iLow(Currency_Symbol, PERIOD_M5, 4) + iClose(Currency_Symbol, PERIOD_M5, 4)) / 3.0;
   double Ld_4424 = (iHigh(Currency_Symbol, PERIOD_M5, 5) + iLow(Currency_Symbol, PERIOD_M5, 5) + iClose(Currency_Symbol, PERIOD_M5, 5)) / 3.0;
   double Ld_4432 = 2.0 * Ld_4192 - iHigh(Currency_Symbol, PERIOD_M5, 0);
   double Ld_4440 = 2.0 * Ld_4200 - iHigh(Currency_Symbol, PERIOD_M5, 1);
   double Ld_4448 = 2.0 * Ld_4208 - iHigh(Currency_Symbol, PERIOD_M5, 2);
   double Ld_4456 = 2.0 * Ld_4216 - iHigh(Currency_Symbol, PERIOD_M5, 3);
   double Ld_4464 = 2.0 * Ld_4224 - iHigh(Currency_Symbol, PERIOD_M5, 4);
   double Ld_4472 = 2.0 * Ld_4232 - iHigh(Currency_Symbol, PERIOD_M5, 5);
   double Ld_4480 = Ld_4192 - (iHigh(Currency_Symbol, PERIOD_M5, 0) - iLow(Currency_Symbol, PERIOD_M5, 0));
   double Ld_4488 = Ld_4200 - (iHigh(Currency_Symbol, PERIOD_M5, 1) - iLow(Currency_Symbol, PERIOD_M5, 1));
   double Ld_4496 = Ld_4208 - (iHigh(Currency_Symbol, PERIOD_M5, 2) - iLow(Currency_Symbol, PERIOD_M5, 2));
   double Ld_4504 = Ld_4216 - (iHigh(Currency_Symbol, PERIOD_M5, 3) - iLow(Currency_Symbol, PERIOD_M5, 3));
   double Ld_4512 = Ld_4224 - (iHigh(Currency_Symbol, PERIOD_M5, 4) - iLow(Currency_Symbol, PERIOD_M5, 4));
   double Ld_4520 = Ld_4232 - (iHigh(Currency_Symbol, PERIOD_M5, 5) - iLow(Currency_Symbol, PERIOD_M5, 5));
   double Ld_4528 = 2.0 * Ld_4192 - (2.0 * iHigh(Currency_Symbol, PERIOD_M5, 0) - iLow(Currency_Symbol, PERIOD_M5, 0));
   double Ld_4536 = 2.0 * Ld_4200 - (2.0 * iHigh(Currency_Symbol, PERIOD_M5, 1) - iLow(Currency_Symbol, PERIOD_M5, 1));
   double Ld_4544 = 2.0 * Ld_4208 - (2.0 * iHigh(Currency_Symbol, PERIOD_M5, 2) - iLow(Currency_Symbol, PERIOD_M5, 2));
   double Ld_4552 = 2.0 * Ld_4216 - (2.0 * iHigh(Currency_Symbol, PERIOD_M5, 3) - iLow(Currency_Symbol, PERIOD_M5, 3));
   double Ld_4560 = 2.0 * Ld_4224 - (2.0 * iHigh(Currency_Symbol, PERIOD_M5, 4) - iLow(Currency_Symbol, PERIOD_M5, 4));
   double Ld_4568 = 2.0 * Ld_4232 - (2.0 * iHigh(Currency_Symbol, PERIOD_M5, 5) - iLow(Currency_Symbol, PERIOD_M5, 5));
   if (Ld_4192 > Ld_3768) {
      Ld_572 = 0;
      Ld_860 = 1;
   }
   if (Ld_4192 < Ld_3768) {
      Ld_572 = 1;
      Ld_860 = 0;
   }
   if (Ld_4200 > Ld_3768) {
      Ld_580 = 0;
      Ld_868 = 1;
   }
   if (Ld_4200 < Ld_3768) {
      Ld_580 = 1;
      Ld_868 = 0;
   }
   if (Ld_4208 > Ld_3768) {
      Ld_588 = 0;
      Ld_876 = 1;
   }
   if (Ld_4208 < Ld_3768) {
      Ld_588 = 1;
      Ld_876 = 0;
   }
   if (Ld_4216 > Ld_3768) {
      Ld_596 = 0;
      Ld_884 = 1;
   }
   if (Ld_4216 < Ld_3768) {
      Ld_596 = 1;
      Ld_884 = 0;
   }
   if (Ld_4224 > Ld_3768) {
      Ld_604 = 0;
      Ld_892 = 1;
   }
   if (Ld_4224 < Ld_3768) {
      Ld_604 = 1;
      Ld_892 = 0;
   }
   if (Ld_4336 > Ld_3768) {
      Ld_612 = 0;
      Ld_900 = 1;
   }
   if (Ld_4336 < Ld_3768) {
      Ld_612 = 1;
      Ld_900 = 0;
   }
   if (Ld_4344 > Ld_3768) {
      Ld_620 = 0;
      Ld_908 = 1;
   }
   if (Ld_4344 < Ld_3768) {
      Ld_620 = 1;
      Ld_908 = 0;
   }
   if (Ld_4352 > Ld_3768) {
      Ld_628 = 0;
      Ld_916 = 1;
   }
   if (Ld_4352 < Ld_3768) {
      Ld_628 = 1;
      Ld_916 = 0;
   }
   if (Ld_4360 > Ld_3768) {
      Ld_636 = 0;
      Ld_924 = 1;
   }
   if (Ld_4360 < Ld_3768) {
      Ld_636 = 1;
      Ld_924 = 0;
   }
   if (Ld_4368 > Ld_3768) {
      Ld_644 = 0;
      Ld_932 = 1;
   }
   if (Ld_4368 < Ld_3768) {
      Ld_644 = 1;
      Ld_932 = 0;
   }
   if (Ld_4376 > Ld_3768) {
      Ld_652 = 0;
      Ld_940 = 1;
   }
   if (Ld_4376 < Ld_3768) {
      Ld_652 = 1;
      Ld_940 = 0;
   }
   if (Ld_4432 > Ld_3768) {
      Ld_660 = 0;
      Ld_948 = 1;
   }
   if (Ld_4432 < Ld_3768) {
      Ld_660 = 1;
      Ld_948 = 0;
   }
   if (Ld_4440 > Ld_3768) {
      Ld_668 = 0;
      Ld_956 = 1;
   }
   if (Ld_4440 < Ld_3768) {
      Ld_668 = 1;
      Ld_956 = 0;
   }
   if (Ld_4448 > Ld_3768) {
      Ld_676 = 0;
      Ld_964 = 1;
   }
   if (Ld_4448 < Ld_3768) {
      Ld_676 = 1;
      Ld_964 = 0;
   }
   if (Ld_4456 > Ld_3768) {
      Ld_684 = 0;
      Ld_972 = 1;
   }
   if (Ld_4456 < Ld_3768) {
      Ld_684 = 1;
      Ld_972 = 0;
   }
   if (Ld_4464 > Ld_3768) {
      Ld_692 = 0;
      Ld_980 = 1;
   }
   if (Ld_4464 < Ld_3768) {
      Ld_692 = 1;
      Ld_980 = 0;
   }
   if (Ld_4472 > Ld_3768) {
      Ld_700 = 0;
      Ld_988 = 1;
   }
   if (Ld_4472 < Ld_3768) {
      Ld_700 = 1;
      Ld_988 = 0;
   }
   if (Ld_4288 > Ld_3768) {
      Ld_708 = 0;
      Ld_996 = 1;
   }
   if (Ld_4288 < Ld_3768) {
      Ld_708 = 1;
      Ld_996 = 0;
   }
   if (Ld_4296 > Ld_3768) {
      Ld_716 = 0;
      Ld_1004 = 1;
   }
   if (Ld_4296 < Ld_3768) {
      Ld_716 = 1;
      Ld_1004 = 0;
   }
   if (Ld_4304 > Ld_3768) {
      Ld_724 = 0;
      Ld_1012 = 1;
   }
   if (Ld_4304 < Ld_3768) {
      Ld_724 = 1;
      Ld_1012 = 0;
   }
   if (Ld_4312 > Ld_3768) {
      Ld_732 = 0;
      Ld_1020 = 1;
   }
   if (Ld_4312 < Ld_3768) {
      Ld_732 = 1;
      Ld_1020 = 0;
   }
   if (Ld_4320 > Ld_3768) {
      Ld_740 = 0;
      Ld_1028 = 1;
   }
   if (Ld_4320 < Ld_3768) {
      Ld_740 = 1;
      Ld_1028 = 0;
   }
   if (Ld_4328 > Ld_3768) {
      Ld_748 = 0;
      Ld_1036 = 1;
   }
   if (Ld_4328 < Ld_3768) {
      Ld_748 = 1;
      Ld_1036 = 0;
   }
   if (Ld_4480 > Ld_3768) {
      Ld_756 = 0;
      Ld_1044 = 1;
   }
   if (Ld_4480 < Ld_3768) {
      Ld_756 = 1;
      Ld_1044 = 0;
   }
   if (Ld_4488 > Ld_3768) {
      Ld_764 = 0;
      Ld_1052 = 1;
   }
   if (Ld_4488 < Ld_3768) {
      Ld_764 = 1;
      Ld_1052 = 0;
   }
   if (Ld_4496 > Ld_3768) {
      Ld_772 = 0;
      Ld_1060 = 1;
   }
   if (Ld_4496 < Ld_3768) {
      Ld_772 = 1;
      Ld_1060 = 0;
   }
   if (Ld_4504 > Ld_3768) {
      Ld_780 = 0;
      Ld_1068 = 1;
   }
   if (Ld_4504 < Ld_3768) {
      Ld_780 = 1;
      Ld_1068 = 0;
   }
   if (Ld_4512 > Ld_3768) {
      Ld_788 = 0;
      Ld_1076 = 1;
   }
   if (Ld_4512 < Ld_3768) {
      Ld_788 = 1;
      Ld_1076 = 0;
   }
   if (Ld_4520 > Ld_3768) {
      Ld_796 = 0;
      Ld_1084 = 1;
   }
   if (Ld_4520 < Ld_3768) {
      Ld_796 = 1;
      Ld_1084 = 0;
   }
   if (Ld_4240 > Ld_3768) {
      Ld_804 = 0;
      Ld_1092 = 1;
   }
   if (Ld_4240 < Ld_3768) {
      Ld_804 = 1;
      Ld_1092 = 0;
   }
   if (Ld_4248 > Ld_3768) {
      Ld_812 = 0;
      Ld_1100 = 1;
   }
   if (Ld_4248 < Ld_3768) {
      Ld_812 = 1;
      Ld_1100 = 0;
   }
   if (Ld_4256 > Ld_3768) {
      Ld_820 = 0;
      Ld_1108 = 1;
   }
   if (Ld_4256 < Ld_3768) {
      Ld_820 = 1;
      Ld_1108 = 0;
   }
   if (Ld_4264 > Ld_3768) {
      Ld_828 = 0;
      Ld_1124 = 1;
   }
   if (Ld_4264 < Ld_3768) {
      Ld_828 = 1;
      Ld_1124 = 0;
   }
   if (Ld_4272 > Ld_3768) {
      Ld_844 = 0;
      Ld_1132 = 1;
   }
   if (Ld_4272 < Ld_3768) {
      Ld_844 = 1;
      Ld_1132 = 0;
   }
   if (Ld_4280 > Ld_3768) {
      Ld_852 = 0;
      Ld_1140 = 1;
   }
   if (Ld_4280 < Ld_3768) {
      Ld_852 = 1;
      Ld_1140 = 0;
   }
   double Ld_4576 = Ld_572 + Ld_580 + Ld_588 + Ld_596 + Ld_604 + Ld_612 + Ld_620 + Ld_628 + Ld_636 + Ld_644 + Ld_652 + Ld_660 + Ld_668 + Ld_676 + Ld_684 + Ld_692 + Ld_700 +
      Ld_708 + Ld_716 + Ld_724 + Ld_732 + Ld_740 + Ld_748 + Ld_756 + Ld_764 + Ld_772 + Ld_780 + Ld_788 + Ld_796 + Ld_804 + Ld_812 + Ld_820 + Ld_828 + Ld_836 + Ld_844 + Ld_852 +
      Ld_4 + Ld_12 + Ld_20 + Ld_28 + Ld_4 + Ld_36 + Ld_44 + Ld_52 + Ld_60 + Ld_68 + Ld_76 + Ld_84 + Ld_92 + Ld_100 + Ld_108 + Ld_116 + Ld_124 + Ld_132 + Ld_140 + Ld_148 +
      Ld_156 + Ld_164 + Ld_172 + Ld_180 + Ld_188 + Ld_196 + Ld_204 + Ld_212 + Ld_220 + Ld_228 + Ld_236 + Ld_244 + Ld_252 + Ld_260 + Ld_268 + Ld_276;
   double Ld_4584 = Ld_860 + Ld_868 + Ld_876 + Ld_884 + Ld_892 + Ld_900 + Ld_908 + Ld_916 + Ld_924 + Ld_932 + Ld_940 + Ld_948 + Ld_956 + Ld_964 + Ld_972 + Ld_980 + Ld_988 +
      Ld_996 + Ld_1004 + Ld_1012 + Ld_1020 + Ld_1028 + Ld_1036 + Ld_1044 + Ld_1052 + Ld_1060 + Ld_1068 + Ld_1076 + Ld_1084 + Ld_1092 + Ld_1100 + Ld_1108 + Ld_1116 + Ld_1124 +
      Ld_1132 + Ld_1140 + Ld_284 + Ld_292 + Ld_300 + Ld_308 + Ld_284 + Ld_324 + Ld_332 + Ld_340 + Ld_348 + Ld_356 + Ld_364 + Ld_372 + Ld_380 + Ld_388 + Ld_396 + Ld_404 +
      Ld_412 + Ld_420 + Ld_428 + Ld_436 + Ld_444 + Ld_452 + Ld_460 + Ld_468 + Ld_476 + Ld_484 + Ld_492 + Ld_500 + Ld_508 + Ld_516 + Ld_524 + Ld_532 + Ld_540 + Ld_548 + Ld_556 +
      Ld_564;
   string dbl2str_4592 = DoubleToStr(100.0 * (Ld_4576 / 72.0), 0);
   string dbl2str_4600 = DoubleToStr(100 - StrToDouble(dbl2str_4592), 0);
   double Ld_4608 = (iHigh(Currency_Symbol, PERIOD_M15, 0) + iLow(Currency_Symbol, PERIOD_M15, 0) + iClose(Currency_Symbol, PERIOD_M15, 0)) / 3.0;
   double Ld_4616 = (iHigh(Currency_Symbol, PERIOD_M15, 1) + iLow(Currency_Symbol, PERIOD_M15, 1) + iClose(Currency_Symbol, PERIOD_M15, 1)) / 3.0;
   double Ld_4624 = (iHigh(Currency_Symbol, PERIOD_M15, 2) + iLow(Currency_Symbol, PERIOD_M15, 2) + iClose(Currency_Symbol, PERIOD_M15, 2)) / 3.0;
   double Ld_4632 = (iHigh(Currency_Symbol, PERIOD_M15, 3) + iLow(Currency_Symbol, PERIOD_M15, 3) + iClose(Currency_Symbol, PERIOD_M15, 3)) / 3.0;
   double Ld_4640 = (iHigh(Currency_Symbol, PERIOD_M15, 4) + iLow(Currency_Symbol, PERIOD_M15, 4) + iClose(Currency_Symbol, PERIOD_M15, 4)) / 3.0;
   double Ld_4648 = (iHigh(Currency_Symbol, PERIOD_M15, 5) + iLow(Currency_Symbol, PERIOD_M15, 5) + iClose(Currency_Symbol, PERIOD_M15, 5)) / 3.0;
   double Ld_4656 = 2.0 * Ld_4608 + (iHigh(Currency_Symbol, PERIOD_M15, 0) - 2.0 * iLow(Currency_Symbol, PERIOD_M15, 0));
   double Ld_4664 = 2.0 * Ld_4616 + (iHigh(Currency_Symbol, PERIOD_M15, 1) - 2.0 * iLow(Currency_Symbol, PERIOD_M15, 1));
   double Ld_4672 = 2.0 * Ld_4624 + (iHigh(Currency_Symbol, PERIOD_M15, 2) - 2.0 * iLow(Currency_Symbol, PERIOD_M15, 2));
   double Ld_4680 = 2.0 * Ld_4632 + (iHigh(Currency_Symbol, PERIOD_M15, 3) - 2.0 * iLow(Currency_Symbol, PERIOD_M15, 3));
   double Ld_4688 = 2.0 * Ld_4640 + (iHigh(Currency_Symbol, PERIOD_M15, 4) - 2.0 * iLow(Currency_Symbol, PERIOD_M15, 4));
   double Ld_4696 = 2.0 * Ld_4648 + (iHigh(Currency_Symbol, PERIOD_M15, 5) - 2.0 * iLow(Currency_Symbol, PERIOD_M15, 5));
   double Ld_4704 = Ld_4608 + (iHigh(Currency_Symbol, PERIOD_M15, 0) - iLow(Currency_Symbol, PERIOD_M15, 0));
   double Ld_4712 = Ld_4616 + (iHigh(Currency_Symbol, PERIOD_M15, 1) - iLow(Currency_Symbol, PERIOD_M15, 1));
   double Ld_4720 = Ld_4624 + (iHigh(Currency_Symbol, PERIOD_M15, 2) - iLow(Currency_Symbol, PERIOD_M15, 2));
   double Ld_4728 = Ld_4632 + (iHigh(Currency_Symbol, PERIOD_M15, 3) - iLow(Currency_Symbol, PERIOD_M15, 3));
   double Ld_4736 = Ld_4640 + (iHigh(Currency_Symbol, PERIOD_M15, 4) - iLow(Currency_Symbol, PERIOD_M15, 4));
   double Ld_4744 = Ld_4648 + (iHigh(Currency_Symbol, PERIOD_M15, 5) - iLow(Currency_Symbol, PERIOD_M15, 5));
   double Ld_4752 = 2.0 * Ld_4608 - iLow(Currency_Symbol, PERIOD_M15, 0);
   double Ld_4760 = 2.0 * Ld_4616 - iLow(Currency_Symbol, PERIOD_M15, 1);
   double Ld_4768 = 2.0 * Ld_4624 - iLow(Currency_Symbol, PERIOD_M15, 2);
   double Ld_4776 = 2.0 * Ld_4632 - iLow(Currency_Symbol, PERIOD_M15, 3);
   double Ld_4784 = 2.0 * Ld_4640 - iLow(Currency_Symbol, PERIOD_M15, 4);
   double Ld_4792 = 2.0 * Ld_4648 - iLow(Currency_Symbol, PERIOD_M15, 5);
   double Ld_4800 = (iHigh(Currency_Symbol, PERIOD_M15, 0) + iLow(Currency_Symbol, PERIOD_M15, 0) + iClose(Currency_Symbol, PERIOD_M15, 0)) / 3.0;
   double Ld_4808 = (iHigh(Currency_Symbol, PERIOD_M15, 1) + iLow(Currency_Symbol, PERIOD_M15, 1) + iClose(Currency_Symbol, PERIOD_M15, 1)) / 3.0;
   double Ld_4816 = (iHigh(Currency_Symbol, PERIOD_M15, 2) + iLow(Currency_Symbol, PERIOD_M15, 2) + iClose(Currency_Symbol, PERIOD_M15, 2)) / 3.0;
   double Ld_4824 = (iHigh(Currency_Symbol, PERIOD_M15, 3) + iLow(Currency_Symbol, PERIOD_M15, 3) + iClose(Currency_Symbol, PERIOD_M15, 3)) / 3.0;
   double Ld_4832 = (iHigh(Currency_Symbol, PERIOD_M15, 4) + iLow(Currency_Symbol, PERIOD_M15, 4) + iClose(Currency_Symbol, PERIOD_M15, 4)) / 3.0;
   double Ld_4840 = (iHigh(Currency_Symbol, PERIOD_M15, 5) + iLow(Currency_Symbol, PERIOD_M15, 5) + iClose(Currency_Symbol, PERIOD_M15, 5)) / 3.0;
   double Ld_4848 = 2.0 * Ld_4608 - iHigh(Currency_Symbol, PERIOD_M15, 0);
   double Ld_4856 = 2.0 * Ld_4616 - iHigh(Currency_Symbol, PERIOD_M15, 1);
   double Ld_4864 = 2.0 * Ld_4624 - iHigh(Currency_Symbol, PERIOD_M15, 2);
   double Ld_4872 = 2.0 * Ld_4632 - iHigh(Currency_Symbol, PERIOD_M15, 3);
   double Ld_4880 = 2.0 * Ld_4640 - iHigh(Currency_Symbol, PERIOD_M15, 4);
   double Ld_4888 = 2.0 * Ld_4648 - iHigh(Currency_Symbol, PERIOD_M15, 5);
   double Ld_4896 = Ld_4608 - (iHigh(Currency_Symbol, PERIOD_M15, 0) - iLow(Currency_Symbol, PERIOD_M15, 0));
   double Ld_4904 = Ld_4616 - (iHigh(Currency_Symbol, PERIOD_M15, 1) - iLow(Currency_Symbol, PERIOD_M15, 1));
   double Ld_4912 = Ld_4624 - (iHigh(Currency_Symbol, PERIOD_M15, 2) - iLow(Currency_Symbol, PERIOD_M15, 2));
   double Ld_4920 = Ld_4632 - (iHigh(Currency_Symbol, PERIOD_M15, 3) - iLow(Currency_Symbol, PERIOD_M15, 3));
   double Ld_4928 = Ld_4640 - (iHigh(Currency_Symbol, PERIOD_M15, 4) - iLow(Currency_Symbol, PERIOD_M15, 4));
   double Ld_4936 = Ld_4648 - (iHigh(Currency_Symbol, PERIOD_M15, 5) - iLow(Currency_Symbol, PERIOD_M15, 5));
   double Ld_4944 = 2.0 * Ld_4608 - (2.0 * iHigh(Currency_Symbol, PERIOD_M15, 0) - iLow(Currency_Symbol, PERIOD_M15, 0));
   double Ld_4952 = 2.0 * Ld_4616 - (2.0 * iHigh(Currency_Symbol, PERIOD_M15, 1) - iLow(Currency_Symbol, PERIOD_M15, 1));
   double Ld_4960 = 2.0 * Ld_4624 - (2.0 * iHigh(Currency_Symbol, PERIOD_M15, 2) - iLow(Currency_Symbol, PERIOD_M15, 2));
   double Ld_4968 = 2.0 * Ld_4632 - (2.0 * iHigh(Currency_Symbol, PERIOD_M15, 3) - iLow(Currency_Symbol, PERIOD_M15, 3));
   double Ld_4976 = 2.0 * Ld_4640 - (2.0 * iHigh(Currency_Symbol, PERIOD_M15, 4) - iLow(Currency_Symbol, PERIOD_M15, 4));
   double Ld_4984 = 2.0 * Ld_4648 - (2.0 * iHigh(Currency_Symbol, PERIOD_M15, 5) - iLow(Currency_Symbol, PERIOD_M15, 5));
   if (Ld_4608 > Ld_3768) {
      Ld_1148 = 0;
      Ld_1436 = 1;
   }
   if (Ld_4608 < Ld_3768) {
      Ld_1148 = 1;
      Ld_1436 = 0;
   }
   if (Ld_4616 > Ld_3768) {
      Ld_1156 = 0;
      Ld_1444 = 1;
   }
   if (Ld_4616 < Ld_3768) {
      Ld_1156 = 1;
      Ld_1444 = 0;
   }
   if (Ld_4624 > Ld_3768) {
      Ld_1164 = 0;
      Ld_1452 = 1;
   }
   if (Ld_4624 < Ld_3768) {
      Ld_1164 = 1;
      Ld_1452 = 0;
   }
   if (Ld_4632 > Ld_3768) {
      Ld_1172 = 0;
      Ld_1460 = 1;
   }
   if (Ld_4632 < Ld_3768) {
      Ld_1172 = 1;
      Ld_1460 = 0;
   }
   if (Ld_4640 > Ld_3768) {
      Ld_1180 = 0;
      Ld_1468 = 1;
   }
   if (Ld_4640 < Ld_3768) {
      Ld_1180 = 1;
      Ld_1468 = 0;
   }
   if (Ld_4752 > Ld_3768) {
      Ld_1188 = 0;
      Ld_1476 = 1;
   }
   if (Ld_4752 < Ld_3768) {
      Ld_1188 = 1;
      Ld_1476 = 0;
   }
   if (Ld_4760 > Ld_3768) {
      Ld_1196 = 0;
      Ld_1484 = 1;
   }
   if (Ld_4760 < Ld_3768) {
      Ld_1196 = 1;
      Ld_1484 = 0;
   }
   if (Ld_4768 > Ld_3768) {
      Ld_1204 = 0;
      Ld_1492 = 1;
   }
   if (Ld_4768 < Ld_3768) {
      Ld_1204 = 1;
      Ld_1492 = 0;
   }
   if (Ld_4776 > Ld_3768) {
      Ld_1212 = 0;
      Ld_1500 = 1;
   }
   if (Ld_4776 < Ld_3768) {
      Ld_1212 = 1;
      Ld_1500 = 0;
   }
   if (Ld_4784 > Ld_3768) {
      Ld_1220 = 0;
      Ld_1508 = 1;
   }
   if (Ld_4784 < Ld_3768) {
      Ld_1220 = 1;
      Ld_1508 = 0;
   }
   if (Ld_4792 > Ld_3768) {
      Ld_1228 = 0;
      Ld_1516 = 1;
   }
   if (Ld_4792 < Ld_3768) {
      Ld_1228 = 1;
      Ld_1516 = 0;
   }
   if (Ld_4848 > Ld_3768) {
      Ld_1236 = 0;
      Ld_1524 = 1;
   }
   if (Ld_4848 < Ld_3768) {
      Ld_1236 = 1;
      Ld_1524 = 0;
   }
   if (Ld_4856 > Ld_3768) {
      Ld_1244 = 0;
      Ld_1532 = 1;
   }
   if (Ld_4856 < Ld_3768) {
      Ld_1244 = 1;
      Ld_1532 = 0;
   }
   if (Ld_4864 > Ld_3768) {
      Ld_1252 = 0;
      Ld_1540 = 1;
   }
   if (Ld_4864 < Ld_3768) {
      Ld_1252 = 1;
      Ld_1540 = 0;
   }
   if (Ld_4872 > Ld_3768) {
      Ld_1260 = 0;
      Ld_1548 = 1;
   }
   if (Ld_4872 < Ld_3768) {
      Ld_1260 = 1;
      Ld_1548 = 0;
   }
   if (Ld_4880 > Ld_3768) {
      Ld_1268 = 0;
      Ld_1556 = 1;
   }
   if (Ld_4880 < Ld_3768) {
      Ld_1268 = 1;
      Ld_1556 = 0;
   }
   if (Ld_4888 > Ld_3768) {
      Ld_1276 = 0;
      Ld_1564 = 1;
   }
   if (Ld_4888 < Ld_3768) {
      Ld_1276 = 1;
      Ld_1564 = 0;
   }
   if (Ld_4704 > Ld_3768) {
      Ld_1284 = 0;
      Ld_1572 = 1;
   }
   if (Ld_4704 < Ld_3768) {
      Ld_1284 = 1;
      Ld_1572 = 0;
   }
   if (Ld_4712 > Ld_3768) {
      Ld_1292 = 0;
      Ld_1580 = 1;
   }
   if (Ld_4712 < Ld_3768) {
      Ld_1292 = 1;
      Ld_1580 = 0;
   }
   if (Ld_4720 > Ld_3768) {
      Ld_1300 = 0;
      Ld_1588 = 1;
   }
   if (Ld_4720 < Ld_3768) {
      Ld_1300 = 1;
      Ld_1588 = 0;
   }
   if (Ld_4728 > Ld_3768) {
      Ld_1308 = 0;
      Ld_1596 = 1;
   }
   if (Ld_4728 < Ld_3768) {
      Ld_1308 = 1;
      Ld_1596 = 0;
   }
   if (Ld_4736 > Ld_3768) {
      Ld_1316 = 0;
      Ld_1604 = 1;
   }
   if (Ld_4736 < Ld_3768) {
      Ld_1316 = 1;
      Ld_1604 = 0;
   }
   if (Ld_4744 > Ld_3768) {
      Ld_1324 = 0;
      Ld_1612 = 1;
   }
   if (Ld_4744 < Ld_3768) {
      Ld_1324 = 1;
      Ld_1612 = 0;
   }
   if (Ld_4896 > Ld_3768) {
      Ld_1332 = 0;
      Ld_1620 = 1;
   }
   if (Ld_4896 < Ld_3768) {
      Ld_1332 = 1;
      Ld_1620 = 0;
   }
   if (Ld_4904 > Ld_3768) {
      Ld_1340 = 0;
      Ld_1628 = 1;
   }
   if (Ld_4904 < Ld_3768) {
      Ld_1340 = 1;
      Ld_1628 = 0;
   }
   if (Ld_4912 > Ld_3768) {
      Ld_1348 = 0;
      Ld_1636 = 1;
   }
   if (Ld_4912 < Ld_3768) {
      Ld_1348 = 1;
      Ld_1636 = 0;
   }
   if (Ld_4920 > Ld_3768) {
      Ld_1356 = 0;
      Ld_1644 = 1;
   }
   if (Ld_4920 < Ld_3768) {
      Ld_1356 = 1;
      Ld_1644 = 0;
   }
   if (Ld_4928 > Ld_3768) {
      Ld_1364 = 0;
      Ld_1652 = 1;
   }
   if (Ld_4928 < Ld_3768) {
      Ld_1364 = 1;
      Ld_1652 = 0;
   }
   if (Ld_4936 > Ld_3768) {
      Ld_1372 = 0;
      Ld_1660 = 1;
   }
   if (Ld_4936 < Ld_3768) {
      Ld_1372 = 1;
      Ld_1660 = 0;
   }
   if (Ld_4656 > Ld_3768) {
      Ld_1380 = 0;
      Ld_1668 = 1;
   }
   if (Ld_4656 < Ld_3768) {
      Ld_1380 = 1;
      Ld_1668 = 0;
   }
   if (Ld_4664 > Ld_3768) {
      Ld_1388 = 0;
      Ld_1676 = 1;
   }
   if (Ld_4664 < Ld_3768) {
      Ld_1388 = 1;
      Ld_1676 = 0;
   }
   if (Ld_4672 > Ld_3768) {
      Ld_1396 = 0;
      Ld_1684 = 1;
   }
   if (Ld_4672 < Ld_3768) {
      Ld_1396 = 1;
      Ld_1684 = 0;
   }
   if (Ld_4680 > Ld_3768) {
      Ld_1404 = 0;
      Ld_1700 = 1;
   }
   if (Ld_4680 < Ld_3768) {
      Ld_1404 = 1;
      Ld_1700 = 0;
   }
   if (Ld_4688 > Ld_3768) {
      Ld_1420 = 0;
      Ld_1708 = 1;
   }
   if (Ld_4688 < Ld_3768) {
      Ld_1420 = 1;
      Ld_1708 = 0;
   }
   if (Ld_4696 > Ld_3768) {
      Ld_1428 = 0;
      Ld_1716 = 1;
   }
   if (Ld_4696 < Ld_3768) {
      Ld_1428 = 1;
      Ld_1716 = 0;
   }
   double Ld_4992 = Ld_1148 + Ld_1156 + Ld_1164 + Ld_1172 + Ld_1180 + Ld_1188 + Ld_1196 + Ld_1204 + Ld_1212 + Ld_1220 + Ld_1228 + Ld_1236 + Ld_1244 + Ld_1252 + Ld_1260 +
      Ld_1268 + Ld_1276 + Ld_1284 + Ld_1292 + Ld_1300 + Ld_1308 + Ld_1316 + Ld_1324 + Ld_1332 + Ld_1340 + Ld_1348 + Ld_1356 + Ld_1364 + Ld_1372 + Ld_1260 + Ld_1388 + Ld_1396 +
      Ld_1404 + Ld_1412 + Ld_1420 + Ld_1428;
   double Ld_5000 = Ld_1436 + Ld_1444 + Ld_1452 + Ld_1460 + Ld_1468 + Ld_1476 + Ld_1484 + Ld_1492 + Ld_1500 + Ld_1508 + Ld_1516 + Ld_1524 + Ld_1532 + Ld_1540 + Ld_1548 +
      Ld_1556 + Ld_1564 + Ld_1572 + Ld_1580 + Ld_1588 + Ld_1596 + Ld_1604 + Ld_1612 + Ld_1620 + Ld_1628 + Ld_1636 + Ld_1644 + Ld_1652 + Ld_1660 + Ld_1548 + Ld_1676 + Ld_1684 +
      Ld_1692 + Ld_1700 + Ld_1708 + Ld_1716;
   string dbl2str_5008 = DoubleToStr(100.0 * (Ld_4992 / 36.0), 0);
   string dbl2str_5016 = DoubleToStr(100 - StrToDouble(dbl2str_5008), 0);
   double Ld_5024 = (iHigh(Currency_Symbol, PERIOD_M30, 0) + iLow(Currency_Symbol, PERIOD_M30, 0) + iClose(Currency_Symbol, PERIOD_M30, 0)) / 3.0;
   double Ld_5032 = (iHigh(Currency_Symbol, PERIOD_M30, 1) + iLow(Currency_Symbol, PERIOD_M30, 1) + iClose(Currency_Symbol, PERIOD_M30, 1)) / 3.0;
   double Ld_5040 = (iHigh(Currency_Symbol, PERIOD_M30, 2) + iLow(Currency_Symbol, PERIOD_M30, 2) + iClose(Currency_Symbol, PERIOD_M30, 2)) / 3.0;
   double Ld_5048 = (iHigh(Currency_Symbol, PERIOD_M30, 3) + iLow(Currency_Symbol, PERIOD_M30, 3) + iClose(Currency_Symbol, PERIOD_M30, 3)) / 3.0;
   double Ld_5056 = (iHigh(Currency_Symbol, PERIOD_M30, 4) + iLow(Currency_Symbol, PERIOD_M30, 4) + iClose(Currency_Symbol, PERIOD_M30, 4)) / 3.0;
   double Ld_5064 = (iHigh(Currency_Symbol, PERIOD_M30, 5) + iLow(Currency_Symbol, PERIOD_M30, 5) + iClose(Currency_Symbol, PERIOD_M30, 5)) / 3.0;
   double Ld_5072 = 2.0 * Ld_5024 + (iHigh(Currency_Symbol, PERIOD_M30, 0) - 2.0 * iLow(Currency_Symbol, PERIOD_M30, 0));
   double Ld_5080 = 2.0 * Ld_5032 + (iHigh(Currency_Symbol, PERIOD_M30, 1) - 2.0 * iLow(Currency_Symbol, PERIOD_M30, 1));
   double Ld_5088 = 2.0 * Ld_5040 + (iHigh(Currency_Symbol, PERIOD_M30, 2) - 2.0 * iLow(Currency_Symbol, PERIOD_M30, 2));
   double Ld_5096 = 2.0 * Ld_5048 + (iHigh(Currency_Symbol, PERIOD_M30, 3) - 2.0 * iLow(Currency_Symbol, PERIOD_M30, 3));
   double Ld_5104 = 2.0 * Ld_5056 + (iHigh(Currency_Symbol, PERIOD_M30, 4) - 2.0 * iLow(Currency_Symbol, PERIOD_M30, 4));
   double Ld_5112 = 2.0 * Ld_5064 + (iHigh(Currency_Symbol, PERIOD_M30, 5) - 2.0 * iLow(Currency_Symbol, PERIOD_M30, 5));
   double Ld_5120 = Ld_5024 + (iHigh(Currency_Symbol, PERIOD_M30, 0) - iLow(Currency_Symbol, PERIOD_M30, 0));
   double Ld_5128 = Ld_5032 + (iHigh(Currency_Symbol, PERIOD_M30, 1) - iLow(Currency_Symbol, PERIOD_M30, 1));
   double Ld_5136 = Ld_5040 + (iHigh(Currency_Symbol, PERIOD_M30, 2) - iLow(Currency_Symbol, PERIOD_M30, 2));
   double Ld_5144 = Ld_5048 + (iHigh(Currency_Symbol, PERIOD_M30, 3) - iLow(Currency_Symbol, PERIOD_M30, 3));
   double Ld_5152 = Ld_5056 + (iHigh(Currency_Symbol, PERIOD_M30, 4) - iLow(Currency_Symbol, PERIOD_M30, 4));
   double Ld_5160 = Ld_5064 + (iHigh(Currency_Symbol, PERIOD_M30, 5) - iLow(Currency_Symbol, PERIOD_M30, 5));
   double Ld_5168 = 2.0 * Ld_5024 - iLow(Currency_Symbol, PERIOD_M30, 0);
   double Ld_5176 = 2.0 * Ld_5032 - iLow(Currency_Symbol, PERIOD_M30, 1);
   double Ld_5184 = 2.0 * Ld_5040 - iLow(Currency_Symbol, PERIOD_M30, 2);
   double Ld_5192 = 2.0 * Ld_5048 - iLow(Currency_Symbol, PERIOD_M30, 3);
   double Ld_5200 = 2.0 * Ld_5056 - iLow(Currency_Symbol, PERIOD_M30, 4);
   double Ld_5208 = 2.0 * Ld_5064 - iLow(Currency_Symbol, PERIOD_M30, 5);
   double Ld_5216 = (iHigh(Currency_Symbol, PERIOD_M30, 0) + iLow(Currency_Symbol, PERIOD_M30, 0) + iClose(Currency_Symbol, PERIOD_M30, 0)) / 3.0;
   double Ld_5224 = (iHigh(Currency_Symbol, PERIOD_M30, 1) + iLow(Currency_Symbol, PERIOD_M30, 1) + iClose(Currency_Symbol, PERIOD_M30, 1)) / 3.0;
   double Ld_5232 = (iHigh(Currency_Symbol, PERIOD_M30, 2) + iLow(Currency_Symbol, PERIOD_M30, 2) + iClose(Currency_Symbol, PERIOD_M30, 2)) / 3.0;
   double Ld_5240 = (iHigh(Currency_Symbol, PERIOD_M30, 3) + iLow(Currency_Symbol, PERIOD_M30, 3) + iClose(Currency_Symbol, PERIOD_M30, 3)) / 3.0;
   double Ld_5248 = (iHigh(Currency_Symbol, PERIOD_M30, 4) + iLow(Currency_Symbol, PERIOD_M30, 4) + iClose(Currency_Symbol, PERIOD_M30, 4)) / 3.0;
   double Ld_5256 = (iHigh(Currency_Symbol, PERIOD_M30, 5) + iLow(Currency_Symbol, PERIOD_M30, 5) + iClose(Currency_Symbol, PERIOD_M30, 5)) / 3.0;
   double Ld_5264 = 2.0 * Ld_5024 - iHigh(Currency_Symbol, PERIOD_M30, 0);
   double Ld_5272 = 2.0 * Ld_5032 - iHigh(Currency_Symbol, PERIOD_M30, 1);
   double Ld_5280 = 2.0 * Ld_5040 - iHigh(Currency_Symbol, PERIOD_M30, 2);
   double Ld_5288 = 2.0 * Ld_5048 - iHigh(Currency_Symbol, PERIOD_M30, 3);
   double Ld_5296 = 2.0 * Ld_5056 - iHigh(Currency_Symbol, PERIOD_M30, 4);
   double Ld_5304 = 2.0 * Ld_5064 - iHigh(Currency_Symbol, PERIOD_M30, 5);
   double Ld_5312 = Ld_5024 - (iHigh(Currency_Symbol, PERIOD_M30, 0) - iLow(Currency_Symbol, PERIOD_M30, 0));
   double Ld_5320 = Ld_5032 - (iHigh(Currency_Symbol, PERIOD_M30, 1) - iLow(Currency_Symbol, PERIOD_M30, 1));
   double Ld_5328 = Ld_5040 - (iHigh(Currency_Symbol, PERIOD_M30, 2) - iLow(Currency_Symbol, PERIOD_M30, 2));
   double Ld_5336 = Ld_5048 - (iHigh(Currency_Symbol, PERIOD_M30, 3) - iLow(Currency_Symbol, PERIOD_M30, 3));
   double Ld_5344 = Ld_5056 - (iHigh(Currency_Symbol, PERIOD_M30, 4) - iLow(Currency_Symbol, PERIOD_M30, 4));
   double Ld_5352 = Ld_5064 - (iHigh(Currency_Symbol, PERIOD_M30, 5) - iLow(Currency_Symbol, PERIOD_M30, 5));
   double Ld_5360 = 2.0 * Ld_5024 - (2.0 * iHigh(Currency_Symbol, PERIOD_M30, 0) - iLow(Currency_Symbol, PERIOD_M30, 0));
   double Ld_5368 = 2.0 * Ld_5032 - (2.0 * iHigh(Currency_Symbol, PERIOD_M30, 1) - iLow(Currency_Symbol, PERIOD_M30, 1));
   double Ld_5376 = 2.0 * Ld_5040 - (2.0 * iHigh(Currency_Symbol, PERIOD_M30, 2) - iLow(Currency_Symbol, PERIOD_M30, 2));
   double Ld_5384 = 2.0 * Ld_5048 - (2.0 * iHigh(Currency_Symbol, PERIOD_M30, 3) - iLow(Currency_Symbol, PERIOD_M30, 3));
   double Ld_5392 = 2.0 * Ld_5056 - (2.0 * iHigh(Currency_Symbol, PERIOD_M30, 4) - iLow(Currency_Symbol, PERIOD_M30, 4));
   double Ld_5400 = 2.0 * Ld_5064 - (2.0 * iHigh(Currency_Symbol, PERIOD_M30, 5) - iLow(Currency_Symbol, PERIOD_M30, 5));
   if (Ld_5024 > Ld_3768) {
      Ld_1724 = 0;
      Ld_2012 = 1;
   }
   if (Ld_5024 < Ld_3768) {
      Ld_1724 = 1;
      Ld_2012 = 0;
   }
   if (Ld_5032 > Ld_3768) {
      Ld_1732 = 0;
      Ld_2020 = 1;
   }
   if (Ld_5032 < Ld_3768) {
      Ld_1732 = 1;
      Ld_2020 = 0;
   }
   if (Ld_5040 > Ld_3768) {
      Ld_1740 = 0;
      Ld_2028 = 1;
   }
   if (Ld_5040 < Ld_3768) {
      Ld_1740 = 1;
      Ld_2028 = 0;
   }
   if (Ld_5048 > Ld_3768) {
      Ld_1748 = 0;
      Ld_2036 = 1;
   }
   if (Ld_5048 < Ld_3768) {
      Ld_1748 = 1;
      Ld_2036 = 0;
   }
   if (Ld_5056 > Ld_3768) {
      Ld_1756 = 0;
      Ld_2044 = 1;
   }
   if (Ld_5056 < Ld_3768) {
      Ld_1756 = 1;
      Ld_2044 = 0;
   }
   if (Ld_5168 > Ld_3768) {
      Ld_1764 = 0;
      Ld_2052 = 1;
   }
   if (Ld_5168 < Ld_3768) {
      Ld_1764 = 1;
      Ld_2052 = 0;
   }
   if (Ld_5176 > Ld_3768) {
      Ld_1772 = 0;
      Ld_2060 = 1;
   }
   if (Ld_5176 < Ld_3768) {
      Ld_1772 = 1;
      Ld_2060 = 0;
   }
   if (Ld_5184 > Ld_3768) {
      Ld_1780 = 0;
      Ld_2068 = 1;
   }
   if (Ld_5184 < Ld_3768) {
      Ld_1780 = 1;
      Ld_2068 = 0;
   }
   if (Ld_5192 > Ld_3768) {
      Ld_1788 = 0;
      Ld_2076 = 1;
   }
   if (Ld_5192 < Ld_3768) {
      Ld_1788 = 1;
      Ld_2076 = 0;
   }
   if (Ld_5200 > Ld_3768) {
      Ld_1796 = 0;
      Ld_2084 = 1;
   }
   if (Ld_5200 < Ld_3768) {
      Ld_1796 = 1;
      Ld_2084 = 0;
   }
   if (Ld_5208 > Ld_3768) {
      Ld_1804 = 0;
      Ld_2092 = 1;
   }
   if (Ld_5208 < Ld_3768) {
      Ld_1804 = 1;
      Ld_2092 = 0;
   }
   if (Ld_5264 > Ld_3768) {
      Ld_1812 = 0;
      Ld_2100 = 1;
   }
   if (Ld_5264 < Ld_3768) {
      Ld_1812 = 1;
      Ld_2100 = 0;
   }
   if (Ld_5272 > Ld_3768) {
      Ld_1820 = 0;
      Ld_2108 = 1;
   }
   if (Ld_5272 < Ld_3768) {
      Ld_1820 = 1;
      Ld_2108 = 0;
   }
   if (Ld_5280 > Ld_3768) {
      Ld_1828 = 0;
      Ld_2116 = 1;
   }
   if (Ld_5280 < Ld_3768) {
      Ld_1828 = 1;
      Ld_2116 = 0;
   }
   if (Ld_5288 > Ld_3768) {
      Ld_1836 = 0;
      Ld_2124 = 1;
   }
   if (Ld_5288 < Ld_3768) {
      Ld_1836 = 1;
      Ld_2124 = 0;
   }
   if (Ld_5296 > Ld_3768) {
      Ld_1844 = 0;
      Ld_2132 = 1;
   }
   if (Ld_5296 < Ld_3768) {
      Ld_1844 = 1;
      Ld_2132 = 0;
   }
   if (Ld_5304 > Ld_3768) {
      Ld_1852 = 0;
      Ld_2140 = 1;
   }
   if (Ld_5304 < Ld_3768) {
      Ld_1852 = 1;
      Ld_2140 = 0;
   }
   if (Ld_5120 > Ld_3768) {
      Ld_1860 = 0;
      Ld_2148 = 1;
   }
   if (Ld_5120 < Ld_3768) {
      Ld_1860 = 1;
      Ld_2148 = 0;
   }
   if (Ld_5128 > Ld_3768) {
      Ld_1868 = 0;
      Ld_2156 = 1;
   }
   if (Ld_5128 < Ld_3768) {
      Ld_1868 = 1;
      Ld_2156 = 0;
   }
   if (Ld_5136 > Ld_3768) {
      Ld_1876 = 0;
      Ld_2164 = 1;
   }
   if (Ld_5136 < Ld_3768) {
      Ld_1876 = 1;
      Ld_2164 = 0;
   }
   if (Ld_5144 > Ld_3768) {
      Ld_1884 = 0;
      Ld_2172 = 1;
   }
   if (Ld_5144 < Ld_3768) {
      Ld_1884 = 1;
      Ld_2172 = 0;
   }
   if (Ld_5152 > Ld_3768) {
      Ld_1892 = 0;
      Ld_2180 = 1;
   }
   if (Ld_5152 < Ld_3768) {
      Ld_1892 = 1;
      Ld_2180 = 0;
   }
   if (Ld_5160 > Ld_3768) {
      Ld_1900 = 0;
      Ld_2188 = 1;
   }
   if (Ld_5160 < Ld_3768) {
      Ld_1900 = 1;
      Ld_2188 = 0;
   }
   if (Ld_5312 > Ld_3768) {
      Ld_1908 = 0;
      Ld_2196 = 1;
   }
   if (Ld_5312 < Ld_3768) {
      Ld_1908 = 1;
      Ld_2196 = 0;
   }
   if (Ld_5320 > Ld_3768) {
      Ld_1916 = 0;
      Ld_2204 = 1;
   }
   if (Ld_5320 < Ld_3768) {
      Ld_1916 = 1;
      Ld_2204 = 0;
   }
   if (Ld_5328 > Ld_3768) {
      Ld_1924 = 0;
      Ld_2212 = 1;
   }
   if (Ld_5328 < Ld_3768) {
      Ld_1924 = 1;
      Ld_2212 = 0;
   }
   if (Ld_5336 > Ld_3768) {
      Ld_1932 = 0;
      Ld_2220 = 1;
   }
   if (Ld_5336 < Ld_3768) {
      Ld_1932 = 1;
      Ld_2220 = 0;
   }
   if (Ld_5344 > Ld_3768) {
      Ld_1940 = 0;
      Ld_2228 = 1;
   }
   if (Ld_5344 < Ld_3768) {
      Ld_1940 = 1;
      Ld_2228 = 0;
   }
   if (Ld_5352 > Ld_3768) {
      Ld_1948 = 0;
      Ld_2236 = 1;
   }
   if (Ld_5352 < Ld_3768) {
      Ld_1948 = 1;
      Ld_2236 = 0;
   }
   if (Ld_5072 > Ld_3768) {
      Ld_1956 = 0;
      Ld_2244 = 1;
   }
   if (Ld_5072 < Ld_3768) {
      Ld_1956 = 1;
      Ld_2244 = 0;
   }
   if (Ld_5080 > Ld_3768) {
      Ld_1964 = 0;
      Ld_2252 = 1;
   }
   if (Ld_5080 < Ld_3768) {
      Ld_1964 = 1;
      Ld_2252 = 0;
   }
   if (Ld_5088 > Ld_3768) {
      Ld_1972 = 0;
      Ld_2260 = 1;
   }
   if (Ld_5088 < Ld_3768) {
      Ld_1972 = 1;
      Ld_2260 = 0;
   }
   if (Ld_5096 > Ld_3768) {
      Ld_1980 = 0;
      Ld_2276 = 1;
   }
   if (Ld_5096 < Ld_3768) {
      Ld_1980 = 1;
      Ld_2276 = 0;
   }
   if (Ld_5104 > Ld_3768) {
      Ld_1996 = 0;
      Ld_2284 = 1;
   }
   if (Ld_5104 < Ld_3768) {
      Ld_1996 = 1;
      Ld_2284 = 0;
   }
   if (Ld_5112 > Ld_3768) {
      Ld_2004 = 0;
      Ld_2292 = 1;
   }
   if (Ld_5112 < Ld_3768) {
      Ld_2004 = 1;
      Ld_2292 = 0;
   }
   double Ld_5408 = Ld_1724 + Ld_1732 + Ld_1740 + Ld_1748 + Ld_1756 + Ld_1764 + Ld_1772 + Ld_1780 + Ld_1788 + Ld_1796 + Ld_1804 + Ld_1812 + Ld_1820 + Ld_1828 + Ld_1836 +
      Ld_1844 + Ld_1852 + Ld_1860 + Ld_1868 + Ld_1876 + Ld_1884 + Ld_1892 + Ld_1900 + Ld_1908 + Ld_1916 + Ld_1924 + Ld_1932 + Ld_1940 + Ld_1948 + Ld_1956 + Ld_1964 + Ld_1972 +
      Ld_1980 + Ld_1988 + Ld_1996 + Ld_2004 + Ld_1148 + Ld_1156 + Ld_1164 + Ld_1172 + Ld_1180 + Ld_1188 + Ld_1196 + Ld_1204 + Ld_1212 + Ld_1220 + Ld_1228 + Ld_1236 + Ld_1244 +
      Ld_1252 + Ld_1260 + Ld_1268 + Ld_1276 + Ld_1284 + Ld_1292 + Ld_1300 + Ld_1308 + Ld_1316 + Ld_1324 + Ld_1332 + Ld_1340 + Ld_1348 + Ld_1356 + Ld_1364 + Ld_1372 + Ld_1380 +
      Ld_1388 + Ld_1396 + Ld_1404 + Ld_1412 + Ld_1420 + Ld_1428;
   double Ld_5416 = Ld_2012 + Ld_2020 + Ld_2028 + Ld_2036 + Ld_2044 + Ld_2052 + Ld_2060 + Ld_2068 + Ld_2076 + Ld_2084 + Ld_2092 + Ld_2100 + Ld_2108 + Ld_2116 + Ld_2124 +
      Ld_2132 + Ld_2140 + Ld_2148 + Ld_2156 + Ld_2164 + Ld_2172 + Ld_2180 + Ld_2188 + Ld_2196 + Ld_2204 + Ld_2212 + Ld_2220 + Ld_2228 + Ld_2236 + Ld_2244 + Ld_2252 + Ld_2260 +
      Ld_2268 + Ld_2276 + Ld_2284 + Ld_2292 + Ld_1436 + Ld_1444 + Ld_1452 + Ld_1460 + Ld_1468 + Ld_1476 + Ld_1484 + Ld_1492 + Ld_1500 + Ld_1508 + Ld_1516 + Ld_1524 + Ld_1532 +
      Ld_1540 + Ld_1548 + Ld_1556 + Ld_1564 + Ld_1572 + Ld_1580 + Ld_1588 + Ld_1596 + Ld_1604 + Ld_1612 + Ld_1620 + Ld_1628 + Ld_1636 + Ld_1644 + Ld_1652 + Ld_1660 + Ld_1668 +
      Ld_1676 + Ld_1684 + Ld_1692 + Ld_1700 + Ld_1708 + Ld_1716;
   string dbl2str_5424 = DoubleToStr(100.0 * (Ld_5408 / 72.0), 0);
   string dbl2str_5432 = DoubleToStr(100 - StrToDouble(dbl2str_5424), 0);
   double Ld_5440 = (iHigh(Currency_Symbol, PERIOD_H1, 0) + iLow(Currency_Symbol, PERIOD_H1, 0) + iClose(Currency_Symbol, PERIOD_H1, 0)) / 3.0;
   double Ld_5448 = (iHigh(Currency_Symbol, PERIOD_H1, 1) + iLow(Currency_Symbol, PERIOD_H1, 1) + iClose(Currency_Symbol, PERIOD_H1, 1)) / 3.0;
   double Ld_5456 = (iHigh(Currency_Symbol, PERIOD_H1, 2) + iLow(Currency_Symbol, PERIOD_H1, 2) + iClose(Currency_Symbol, PERIOD_H1, 2)) / 3.0;
   double Ld_5464 = (iHigh(Currency_Symbol, PERIOD_H1, 3) + iLow(Currency_Symbol, PERIOD_H1, 3) + iClose(Currency_Symbol, PERIOD_H1, 3)) / 3.0;
   double Ld_5472 = (iHigh(Currency_Symbol, PERIOD_H1, 4) + iLow(Currency_Symbol, PERIOD_H1, 4) + iClose(Currency_Symbol, PERIOD_H1, 4)) / 3.0;
   double Ld_5480 = (iHigh(Currency_Symbol, PERIOD_H1, 5) + iLow(Currency_Symbol, PERIOD_H1, 5) + iClose(Currency_Symbol, PERIOD_H1, 5)) / 3.0;
   double Ld_5488 = 2.0 * Ld_5440 + (iHigh(Currency_Symbol, PERIOD_H1, 0) - 2.0 * iLow(Currency_Symbol, PERIOD_H1, 0));
   double Ld_5496 = 2.0 * Ld_5448 + (iHigh(Currency_Symbol, PERIOD_H1, 1) - 2.0 * iLow(Currency_Symbol, PERIOD_H1, 1));
   double Ld_5504 = 2.0 * Ld_5456 + (iHigh(Currency_Symbol, PERIOD_H1, 2) - 2.0 * iLow(Currency_Symbol, PERIOD_H1, 2));
   double Ld_5512 = 2.0 * Ld_5464 + (iHigh(Currency_Symbol, PERIOD_H1, 3) - 2.0 * iLow(Currency_Symbol, PERIOD_H1, 3));
   double Ld_5520 = 2.0 * Ld_5472 + (iHigh(Currency_Symbol, PERIOD_H1, 4) - 2.0 * iLow(Currency_Symbol, PERIOD_H1, 4));
   double Ld_5528 = 2.0 * Ld_5480 + (iHigh(Currency_Symbol, PERIOD_H1, 5) - 2.0 * iLow(Currency_Symbol, PERIOD_H1, 5));
   double Ld_5536 = Ld_5440 + (iHigh(Currency_Symbol, PERIOD_H1, 0) - iLow(Currency_Symbol, PERIOD_H1, 0));
   double Ld_5544 = Ld_5448 + (iHigh(Currency_Symbol, PERIOD_H1, 1) - iLow(Currency_Symbol, PERIOD_H1, 1));
   double Ld_5552 = Ld_5456 + (iHigh(Currency_Symbol, PERIOD_H1, 2) - iLow(Currency_Symbol, PERIOD_H1, 2));
   double Ld_5560 = Ld_5464 + (iHigh(Currency_Symbol, PERIOD_H1, 3) - iLow(Currency_Symbol, PERIOD_H1, 3));
   double Ld_5568 = Ld_5472 + (iHigh(Currency_Symbol, PERIOD_H1, 4) - iLow(Currency_Symbol, PERIOD_H1, 4));
   double Ld_5576 = Ld_5480 + (iHigh(Currency_Symbol, PERIOD_H1, 5) - iLow(Currency_Symbol, PERIOD_H1, 5));
   double Ld_5584 = 2.0 * Ld_5440 - iLow(Currency_Symbol, PERIOD_H1, 0);
   double Ld_5592 = 2.0 * Ld_5448 - iLow(Currency_Symbol, PERIOD_H1, 1);
   double Ld_5600 = 2.0 * Ld_5456 - iLow(Currency_Symbol, PERIOD_H1, 2);
   double Ld_5608 = 2.0 * Ld_5464 - iLow(Currency_Symbol, PERIOD_H1, 3);
   double Ld_5616 = 2.0 * Ld_5472 - iLow(Currency_Symbol, PERIOD_H1, 4);
   double Ld_5624 = 2.0 * Ld_5480 - iLow(Currency_Symbol, PERIOD_H1, 5);
   double Ld_5632 = (iHigh(Currency_Symbol, PERIOD_H1, 0) + iLow(Currency_Symbol, PERIOD_H1, 0) + iClose(Currency_Symbol, PERIOD_H1, 0)) / 3.0;
   double Ld_5640 = (iHigh(Currency_Symbol, PERIOD_H1, 1) + iLow(Currency_Symbol, PERIOD_H1, 1) + iClose(Currency_Symbol, PERIOD_H1, 1)) / 3.0;
   double Ld_5648 = (iHigh(Currency_Symbol, PERIOD_H1, 2) + iLow(Currency_Symbol, PERIOD_H1, 2) + iClose(Currency_Symbol, PERIOD_H1, 2)) / 3.0;
   double Ld_5656 = (iHigh(Currency_Symbol, PERIOD_H1, 3) + iLow(Currency_Symbol, PERIOD_H1, 3) + iClose(Currency_Symbol, PERIOD_H1, 3)) / 3.0;
   double Ld_5664 = (iHigh(Currency_Symbol, PERIOD_H1, 4) + iLow(Currency_Symbol, PERIOD_H1, 4) + iClose(Currency_Symbol, PERIOD_H1, 4)) / 3.0;
   double Ld_5672 = (iHigh(Currency_Symbol, PERIOD_H1, 5) + iLow(Currency_Symbol, PERIOD_H1, 5) + iClose(Currency_Symbol, PERIOD_H1, 5)) / 3.0;
   double Ld_5680 = 2.0 * Ld_5440 - iHigh(Currency_Symbol, PERIOD_H1, 0);
   double Ld_5688 = 2.0 * Ld_5448 - iHigh(Currency_Symbol, PERIOD_H1, 1);
   double Ld_5696 = 2.0 * Ld_5456 - iHigh(Currency_Symbol, PERIOD_H1, 2);
   double Ld_5704 = 2.0 * Ld_5464 - iHigh(Currency_Symbol, PERIOD_H1, 3);
   double Ld_5712 = 2.0 * Ld_5472 - iHigh(Currency_Symbol, PERIOD_H1, 4);
   double Ld_5720 = 2.0 * Ld_5480 - iHigh(Currency_Symbol, PERIOD_H1, 5);
   double Ld_5728 = Ld_5440 - (iHigh(Currency_Symbol, PERIOD_H1, 0) - iLow(Currency_Symbol, PERIOD_H1, 0));
   double Ld_5736 = Ld_5448 - (iHigh(Currency_Symbol, PERIOD_H1, 1) - iLow(Currency_Symbol, PERIOD_H1, 1));
   double Ld_5744 = Ld_5456 - (iHigh(Currency_Symbol, PERIOD_H1, 2) - iLow(Currency_Symbol, PERIOD_H1, 2));
   double Ld_5752 = Ld_5464 - (iHigh(Currency_Symbol, PERIOD_H1, 3) - iLow(Currency_Symbol, PERIOD_H1, 3));
   double Ld_5760 = Ld_5472 - (iHigh(Currency_Symbol, PERIOD_H1, 4) - iLow(Currency_Symbol, PERIOD_H1, 4));
   double Ld_5768 = Ld_5480 - (iHigh(Currency_Symbol, PERIOD_H1, 5) - iLow(Currency_Symbol, PERIOD_H1, 5));
   double Ld_5776 = 2.0 * Ld_5440 - (2.0 * iHigh(Currency_Symbol, PERIOD_H1, 0) - iLow(Currency_Symbol, PERIOD_H1, 0));
   double Ld_5784 = 2.0 * Ld_5448 - (2.0 * iHigh(Currency_Symbol, PERIOD_H1, 1) - iLow(Currency_Symbol, PERIOD_H1, 1));
   double Ld_5792 = 2.0 * Ld_5456 - (2.0 * iHigh(Currency_Symbol, PERIOD_H1, 2) - iLow(Currency_Symbol, PERIOD_H1, 2));
   double Ld_5800 = 2.0 * Ld_5464 - (2.0 * iHigh(Currency_Symbol, PERIOD_H1, 3) - iLow(Currency_Symbol, PERIOD_H1, 3));
   double Ld_5808 = 2.0 * Ld_5472 - (2.0 * iHigh(Currency_Symbol, PERIOD_H1, 4) - iLow(Currency_Symbol, PERIOD_H1, 4));
   double Ld_5816 = 2.0 * Ld_5480 - (2.0 * iHigh(Currency_Symbol, PERIOD_H1, 5) - iLow(Currency_Symbol, PERIOD_H1, 5));
   if (Ld_5440 > Ld_3768) {
      Ld_2300 = 0;
      Ld_2588 = 1;
   }
   if (Ld_5440 < Ld_3768) {
      Ld_2300 = 1;
      Ld_2588 = 0;
   }
   if (Ld_5448 > Ld_3768) {
      Ld_2308 = 0;
      Ld_2596 = 1;
   }
   if (Ld_5448 < Ld_3768) {
      Ld_2308 = 1;
      Ld_2596 = 0;
   }
   if (Ld_5456 > Ld_3768) {
      Ld_2316 = 0;
      Ld_2604 = 1;
   }
   if (Ld_5456 < Ld_3768) {
      Ld_2316 = 1;
      Ld_2604 = 0;
   }
   if (Ld_5464 > Ld_3768) {
      Ld_2324 = 0;
      Ld_2612 = 1;
   }
   if (Ld_5464 < Ld_3768) {
      Ld_2324 = 1;
      Ld_2612 = 0;
   }
   if (Ld_5472 > Ld_3768) {
      Ld_2332 = 0;
      Ld_2620 = 1;
   }
   if (Ld_5472 < Ld_3768) {
      Ld_2332 = 1;
      Ld_2620 = 0;
   }
   if (Ld_5584 > Ld_3768) {
      Ld_2340 = 0;
      Ld_2628 = 1;
   }
   if (Ld_5584 < Ld_3768) {
      Ld_2340 = 1;
      Ld_2628 = 0;
   }
   if (Ld_5592 > Ld_3768) {
      Ld_2348 = 0;
      Ld_2636 = 1;
   }
   if (Ld_5592 < Ld_3768) {
      Ld_2348 = 1;
      Ld_2636 = 0;
   }
   if (Ld_5600 > Ld_3768) {
      Ld_2356 = 0;
      Ld_2644 = 1;
   }
   if (Ld_5600 < Ld_3768) {
      Ld_2356 = 1;
      Ld_2644 = 0;
   }
   if (Ld_5608 > Ld_3768) {
      Ld_2364 = 0;
      Ld_2652 = 1;
   }
   if (Ld_5608 < Ld_3768) {
      Ld_2364 = 1;
      Ld_2652 = 0;
   }
   if (Ld_5616 > Ld_3768) {
      Ld_2372 = 0;
      Ld_2660 = 1;
   }
   if (Ld_5616 < Ld_3768) {
      Ld_2372 = 1;
      Ld_2660 = 0;
   }
   if (Ld_5624 > Ld_3768) {
      Ld_2380 = 0;
      Ld_2668 = 1;
   }
   if (Ld_5624 < Ld_3768) {
      Ld_2380 = 1;
      Ld_2668 = 0;
   }
   if (Ld_5680 > Ld_3768) {
      Ld_2388 = 0;
      Ld_2676 = 1;
   }
   if (Ld_5680 < Ld_3768) {
      Ld_2388 = 1;
      Ld_2676 = 0;
   }
   if (Ld_5688 > Ld_3768) {
      Ld_2396 = 0;
      Ld_2684 = 1;
   }
   if (Ld_5688 < Ld_3768) {
      Ld_2396 = 1;
      Ld_2684 = 0;
   }
   if (Ld_5696 > Ld_3768) {
      Ld_2404 = 0;
      Ld_2692 = 1;
   }
   if (Ld_5696 < Ld_3768) {
      Ld_2404 = 1;
      Ld_2692 = 0;
   }
   if (Ld_5704 > Ld_3768) {
      Ld_2412 = 0;
      Ld_2700 = 1;
   }
   if (Ld_5704 < Ld_3768) {
      Ld_2412 = 1;
      Ld_2700 = 0;
   }
   if (Ld_5712 > Ld_3768) {
      Ld_2420 = 0;
      Ld_2708 = 1;
   }
   if (Ld_5712 < Ld_3768) {
      Ld_2420 = 1;
      Ld_2708 = 0;
   }
   if (Ld_5720 > Ld_3768) {
      Ld_2428 = 0;
      Ld_2716 = 1;
   }
   if (Ld_5720 < Ld_3768) {
      Ld_2428 = 1;
      Ld_2716 = 0;
   }
   if (Ld_5536 > Ld_3768) {
      Ld_2436 = 0;
      Ld_2724 = 1;
   }
   if (Ld_5536 < Ld_3768) {
      Ld_2436 = 1;
      Ld_2724 = 0;
   }
   if (Ld_5544 > Ld_3768) {
      Ld_2444 = 0;
      Ld_2732 = 1;
   }
   if (Ld_5544 < Ld_3768) {
      Ld_2444 = 1;
      Ld_2732 = 0;
   }
   if (Ld_5552 > Ld_3768) {
      Ld_2452 = 0;
      Ld_2740 = 1;
   }
   if (Ld_5552 < Ld_3768) {
      Ld_2452 = 1;
      Ld_2740 = 0;
   }
   if (Ld_5560 > Ld_3768) {
      Ld_2460 = 0;
      Ld_2748 = 1;
   }
   if (Ld_5560 < Ld_3768) {
      Ld_2460 = 1;
      Ld_2748 = 0;
   }
   if (Ld_5568 > Ld_3768) {
      Ld_2468 = 0;
      Ld_2756 = 1;
   }
   if (Ld_5568 < Ld_3768) {
      Ld_2468 = 1;
      Ld_2756 = 0;
   }
   if (Ld_5576 > Ld_3768) {
      Ld_2476 = 0;
      Ld_2764 = 1;
   }
   if (Ld_5576 < Ld_3768) {
      Ld_2476 = 1;
      Ld_2764 = 0;
   }
   if (Ld_5728 > Ld_3768) {
      Ld_2484 = 0;
      Ld_2772 = 1;
   }
   if (Ld_5728 < Ld_3768) {
      Ld_2484 = 1;
      Ld_2772 = 0;
   }
   if (Ld_5736 > Ld_3768) {
      Ld_2492 = 0;
      Ld_2780 = 1;
   }
   if (Ld_5736 < Ld_3768) {
      Ld_2492 = 1;
      Ld_2780 = 0;
   }
   if (Ld_5744 > Ld_3768) {
      Ld_2500 = 0;
      Ld_2788 = 1;
   }
   if (Ld_5744 < Ld_3768) {
      Ld_2500 = 1;
      Ld_2788 = 0;
   }
   if (Ld_5752 > Ld_3768) {
      Ld_2508 = 0;
      Ld_2796 = 1;
   }
   if (Ld_5752 < Ld_3768) {
      Ld_2508 = 1;
      Ld_2796 = 0;
   }
   if (Ld_5760 > Ld_3768) {
      Ld_2516 = 0;
      Ld_2804 = 1;
   }
   if (Ld_5760 < Ld_3768) {
      Ld_2516 = 1;
      Ld_2804 = 0;
   }
   if (Ld_5768 > Ld_3768) {
      Ld_2524 = 0;
      Ld_2812 = 1;
   }
   if (Ld_5768 < Ld_3768) {
      Ld_2524 = 1;
      Ld_2812 = 0;
   }
   if (Ld_5488 > Ld_3768) {
      Ld_2532 = 0;
      Ld_2820 = 1;
   }
   if (Ld_5488 < Ld_3768) {
      Ld_2532 = 1;
      Ld_2820 = 0;
   }
   if (Ld_5496 > Ld_3768) {
      Ld_2540 = 0;
      Ld_2828 = 1;
   }
   if (Ld_5496 < Ld_3768) {
      Ld_2540 = 1;
      Ld_2828 = 0;
   }
   if (Ld_5504 > Ld_3768) {
      Ld_2548 = 0;
      Ld_2836 = 1;
   }
   if (Ld_5504 < Ld_3768) {
      Ld_2548 = 1;
      Ld_2836 = 0;
   }
   if (Ld_5512 > Ld_3768) {
      Ld_2556 = 0;
      Ld_2852 = 1;
   }
   if (Ld_5512 < Ld_3768) {
      Ld_2556 = 1;
      Ld_2852 = 0;
   }
   if (Ld_5520 > Ld_3768) {
      Ld_2572 = 0;
      Ld_2860 = 1;
   }
   if (Ld_5520 < Ld_3768) {
      Ld_2572 = 1;
      Ld_2860 = 0;
   }
   if (Ld_5528 > Ld_3768) {
      Ld_2580 = 0;
      Ld_2868 = 1;
   }
   if (Ld_5528 < Ld_3768) {
      Ld_2580 = 1;
      Ld_2868 = 0;
   }
   double Ld_5824 = Ld_2300 + Ld_2308 + Ld_2316 + Ld_2324 + Ld_2332 + Ld_2340 + Ld_2348 + Ld_2356 + Ld_2364 + Ld_2372 + Ld_2380 + Ld_2388 + Ld_2396 + Ld_2404 + Ld_2412 +
      Ld_2420 + Ld_2428 + Ld_2436 + Ld_2444 + Ld_2452 + Ld_2460 + Ld_2468 + Ld_2476 + Ld_2484 + Ld_2492 + Ld_2500 + Ld_2508 + Ld_2516 + Ld_2524 + Ld_2532 + Ld_2540 + Ld_2548 +
      Ld_2556 + Ld_2564 + Ld_2572 + Ld_2580;
   double Ld_5832 = Ld_2588 + Ld_2596 + Ld_2604 + Ld_2612 + Ld_2620 + Ld_2628 + Ld_2636 + Ld_2644 + Ld_2652 + Ld_2660 + Ld_2668 + Ld_2676 + Ld_2684 + Ld_2692 + Ld_2700 +
      Ld_2708 + Ld_2716 + Ld_2724 + Ld_2732 + Ld_2740 + Ld_2748 + Ld_2756 + Ld_2764 + Ld_2772 + Ld_2780 + Ld_2788 + Ld_2796 + Ld_2804 + Ld_2812 + Ld_2820 + Ld_2828 + Ld_2836 +
      Ld_2844 + Ld_2852 + Ld_2860 + Ld_2868;
   string dbl2str_5840 = DoubleToStr(100.0 * (Ld_5824 / 36.0), 0);
   string dbl2str_5848 = DoubleToStr(100 - StrToDouble(dbl2str_5840), 0);
   double Ld_5856 = (iHigh(Currency_Symbol, PERIOD_H4, 0) + iLow(Currency_Symbol, PERIOD_H4, 0) + iClose(Currency_Symbol, PERIOD_H4, 0)) / 3.0;
   double Ld_5864 = (iHigh(Currency_Symbol, PERIOD_H4, 1) + iLow(Currency_Symbol, PERIOD_H4, 1) + iClose(Currency_Symbol, PERIOD_H4, 1)) / 3.0;
   double Ld_5872 = (iHigh(Currency_Symbol, PERIOD_H4, 2) + iLow(Currency_Symbol, PERIOD_H4, 2) + iClose(Currency_Symbol, PERIOD_H4, 2)) / 3.0;
   double Ld_5880 = (iHigh(Currency_Symbol, PERIOD_H4, 3) + iLow(Currency_Symbol, PERIOD_H4, 3) + iClose(Currency_Symbol, PERIOD_H4, 3)) / 3.0;
   double Ld_5888 = (iHigh(Currency_Symbol, PERIOD_H4, 4) + iLow(Currency_Symbol, PERIOD_H4, 4) + iClose(Currency_Symbol, PERIOD_H4, 4)) / 3.0;
   double Ld_5896 = (iHigh(Currency_Symbol, PERIOD_H4, 5) + iLow(Currency_Symbol, PERIOD_H4, 5) + iClose(Currency_Symbol, PERIOD_H4, 5)) / 3.0;
   double Ld_5904 = 2.0 * Ld_5856 + (iHigh(Currency_Symbol, PERIOD_H4, 0) - 2.0 * iLow(Currency_Symbol, PERIOD_H4, 0));
   double Ld_5912 = 2.0 * Ld_5864 + (iHigh(Currency_Symbol, PERIOD_H4, 1) - 2.0 * iLow(Currency_Symbol, PERIOD_H4, 1));
   double Ld_5920 = 2.0 * Ld_5872 + (iHigh(Currency_Symbol, PERIOD_H4, 2) - 2.0 * iLow(Currency_Symbol, PERIOD_H4, 2));
   double Ld_5928 = 2.0 * Ld_5880 + (iHigh(Currency_Symbol, PERIOD_H4, 3) - 2.0 * iLow(Currency_Symbol, PERIOD_H4, 3));
   double Ld_5936 = 2.0 * Ld_5888 + (iHigh(Currency_Symbol, PERIOD_H4, 4) - 2.0 * iLow(Currency_Symbol, PERIOD_H4, 4));
   double Ld_5944 = 2.0 * Ld_5896 + (iHigh(Currency_Symbol, PERIOD_H4, 5) - 2.0 * iLow(Currency_Symbol, PERIOD_H4, 5));
   double Ld_5952 = Ld_5856 + (iHigh(Currency_Symbol, PERIOD_H4, 0) - iLow(Currency_Symbol, PERIOD_H4, 0));
   double Ld_5960 = Ld_5864 + (iHigh(Currency_Symbol, PERIOD_H4, 1) - iLow(Currency_Symbol, PERIOD_H4, 1));
   double Ld_5968 = Ld_5872 + (iHigh(Currency_Symbol, PERIOD_H4, 2) - iLow(Currency_Symbol, PERIOD_H4, 2));
   double Ld_5976 = Ld_5880 + (iHigh(Currency_Symbol, PERIOD_H4, 3) - iLow(Currency_Symbol, PERIOD_H4, 3));
   double Ld_5984 = Ld_5888 + (iHigh(Currency_Symbol, PERIOD_H4, 4) - iLow(Currency_Symbol, PERIOD_H4, 4));
   double Ld_5992 = Ld_5896 + (iHigh(Currency_Symbol, PERIOD_H4, 5) - iLow(Currency_Symbol, PERIOD_H4, 5));
   double Ld_6000 = 2.0 * Ld_5856 - iLow(Currency_Symbol, PERIOD_H4, 0);
   double Ld_6008 = 2.0 * Ld_5864 - iLow(Currency_Symbol, PERIOD_H4, 1);
   double Ld_6016 = 2.0 * Ld_5872 - iLow(Currency_Symbol, PERIOD_H4, 2);
   double Ld_6024 = 2.0 * Ld_5880 - iLow(Currency_Symbol, PERIOD_H4, 3);
   double Ld_6032 = 2.0 * Ld_5888 - iLow(Currency_Symbol, PERIOD_H4, 4);
   double Ld_6040 = 2.0 * Ld_5896 - iLow(Currency_Symbol, PERIOD_H4, 5);
   double Ld_6048 = (iHigh(Currency_Symbol, PERIOD_H4, 0) + iLow(Currency_Symbol, PERIOD_H4, 0) + iClose(Currency_Symbol, PERIOD_H4, 0)) / 3.0;
   double Ld_6056 = (iHigh(Currency_Symbol, PERIOD_H4, 1) + iLow(Currency_Symbol, PERIOD_H4, 1) + iClose(Currency_Symbol, PERIOD_H4, 1)) / 3.0;
   double Ld_6064 = (iHigh(Currency_Symbol, PERIOD_H4, 2) + iLow(Currency_Symbol, PERIOD_H4, 2) + iClose(Currency_Symbol, PERIOD_H4, 2)) / 3.0;
   double Ld_6072 = (iHigh(Currency_Symbol, PERIOD_H4, 3) + iLow(Currency_Symbol, PERIOD_H4, 3) + iClose(Currency_Symbol, PERIOD_H4, 3)) / 3.0;
   double Ld_6080 = (iHigh(Currency_Symbol, PERIOD_H4, 4) + iLow(Currency_Symbol, PERIOD_H4, 4) + iClose(Currency_Symbol, PERIOD_H4, 4)) / 3.0;
   double Ld_6088 = (iHigh(Currency_Symbol, PERIOD_H4, 5) + iLow(Currency_Symbol, PERIOD_H4, 5) + iClose(Currency_Symbol, PERIOD_H4, 5)) / 3.0;
   double Ld_6096 = 2.0 * Ld_5856 - iHigh(Currency_Symbol, PERIOD_H4, 0);
   double Ld_6104 = 2.0 * Ld_5864 - iHigh(Currency_Symbol, PERIOD_H4, 1);
   double Ld_6112 = 2.0 * Ld_5872 - iHigh(Currency_Symbol, PERIOD_H4, 2);
   double Ld_6120 = 2.0 * Ld_5880 - iHigh(Currency_Symbol, PERIOD_H4, 3);
   double Ld_6128 = 2.0 * Ld_5888 - iHigh(Currency_Symbol, PERIOD_H4, 4);
   double Ld_6136 = 2.0 * Ld_5896 - iHigh(Currency_Symbol, PERIOD_H4, 5);
   double Ld_6144 = Ld_5856 - (iHigh(Currency_Symbol, PERIOD_H4, 0) - iLow(Currency_Symbol, PERIOD_H4, 0));
   double Ld_6152 = Ld_5864 - (iHigh(Currency_Symbol, PERIOD_H4, 1) - iLow(Currency_Symbol, PERIOD_H4, 1));
   double Ld_6160 = Ld_5872 - (iHigh(Currency_Symbol, PERIOD_H4, 2) - iLow(Currency_Symbol, PERIOD_H4, 2));
   double Ld_6168 = Ld_5880 - (iHigh(Currency_Symbol, PERIOD_H4, 3) - iLow(Currency_Symbol, PERIOD_H4, 3));
   double Ld_6176 = Ld_5888 - (iHigh(Currency_Symbol, PERIOD_H4, 4) - iLow(Currency_Symbol, PERIOD_H4, 4));
   double Ld_6184 = Ld_5896 - (iHigh(Currency_Symbol, PERIOD_H4, 5) - iLow(Currency_Symbol, PERIOD_H4, 5));
   double Ld_6192 = 2.0 * Ld_5856 - (2.0 * iHigh(Currency_Symbol, PERIOD_H4, 0) - iLow(Currency_Symbol, PERIOD_H4, 0));
   double Ld_6200 = 2.0 * Ld_5864 - (2.0 * iHigh(Currency_Symbol, PERIOD_H4, 1) - iLow(Currency_Symbol, PERIOD_H4, 1));
   double Ld_6208 = 2.0 * Ld_5872 - (2.0 * iHigh(Currency_Symbol, PERIOD_H4, 2) - iLow(Currency_Symbol, PERIOD_H4, 2));
   double Ld_6216 = 2.0 * Ld_5880 - (2.0 * iHigh(Currency_Symbol, PERIOD_H4, 3) - iLow(Currency_Symbol, PERIOD_H4, 3));
   double Ld_6224 = 2.0 * Ld_5888 - (2.0 * iHigh(Currency_Symbol, PERIOD_H4, 4) - iLow(Currency_Symbol, PERIOD_H4, 4));
   double Ld_6232 = 2.0 * Ld_5896 - (2.0 * iHigh(Currency_Symbol, PERIOD_H4, 5) - iLow(Currency_Symbol, PERIOD_H4, 5));
   if (Ld_5856 > Ld_3768) {
      Ld_2876 = 0;
      Ld_3164 = 1;
   }
   if (Ld_5856 < Ld_3768) {
      Ld_2876 = 1;
      Ld_3164 = 0;
   }
   if (Ld_5864 > Ld_3768) {
      Ld_2884 = 0;
      Ld_3172 = 1;
   }
   if (Ld_5864 < Ld_3768) {
      Ld_2884 = 1;
      Ld_3172 = 0;
   }
   if (Ld_5872 > Ld_3768) {
      Ld_2892 = 0;
      Ld_3180 = 1;
   }
   if (Ld_5872 < Ld_3768) {
      Ld_2892 = 1;
      Ld_3180 = 0;
   }
   if (Ld_5880 > Ld_3768) {
      Ld_2900 = 0;
      Ld_3188 = 1;
   }
   if (Ld_5880 < Ld_3768) {
      Ld_2900 = 1;
      Ld_3188 = 0;
   }
   if (Ld_5888 > Ld_3768) {
      Ld_2908 = 0;
      Ld_3196 = 1;
   }
   if (Ld_5888 < Ld_3768) {
      Ld_2908 = 1;
      Ld_3196 = 0;
   }
   if (Ld_6000 > Ld_3768) {
      Ld_2916 = 0;
      Ld_3204 = 1;
   }
   if (Ld_6000 < Ld_3768) {
      Ld_2916 = 1;
      Ld_3204 = 0;
   }
   if (Ld_6008 > Ld_3768) {
      Ld_2924 = 0;
      Ld_3212 = 1;
   }
   if (Ld_6008 < Ld_3768) {
      Ld_2924 = 1;
      Ld_3212 = 0;
   }
   if (Ld_6016 > Ld_3768) {
      Ld_2932 = 0;
      Ld_3220 = 1;
   }
   if (Ld_6016 < Ld_3768) {
      Ld_2932 = 1;
      Ld_3220 = 0;
   }
   if (Ld_6024 > Ld_3768) {
      Ld_2940 = 0;
      Ld_3228 = 1;
   }
   if (Ld_6024 < Ld_3768) {
      Ld_2940 = 1;
      Ld_3228 = 0;
   }
   if (Ld_6032 > Ld_3768) {
      Ld_2948 = 0;
      Ld_3236 = 1;
   }
   if (Ld_6032 < Ld_3768) {
      Ld_2948 = 1;
      Ld_3236 = 0;
   }
   if (Ld_6040 > Ld_3768) {
      Ld_2956 = 0;
      Ld_3244 = 1;
   }
   if (Ld_6040 < Ld_3768) {
      Ld_2956 = 1;
      Ld_3244 = 0;
   }
   if (Ld_6096 > Ld_3768) {
      Ld_2964 = 0;
      Ld_3252 = 1;
   }
   if (Ld_6096 < Ld_3768) {
      Ld_2964 = 1;
      Ld_3252 = 0;
   }
   if (Ld_6104 > Ld_3768) {
      Ld_2972 = 0;
      Ld_3260 = 1;
   }
   if (Ld_6104 < Ld_3768) {
      Ld_2972 = 1;
      Ld_3260 = 0;
   }
   if (Ld_6112 > Ld_3768) {
      Ld_2980 = 0;
      Ld_3268 = 1;
   }
   if (Ld_6112 < Ld_3768) {
      Ld_2980 = 1;
      Ld_3268 = 0;
   }
   if (Ld_6120 > Ld_3768) {
      Ld_2988 = 0;
      Ld_3276 = 1;
   }
   if (Ld_6120 < Ld_3768) {
      Ld_2988 = 1;
      Ld_3276 = 0;
   }
   if (Ld_6128 > Ld_3768) {
      Ld_2996 = 0;
      Ld_3284 = 1;
   }
   if (Ld_6128 < Ld_3768) {
      Ld_2996 = 1;
      Ld_3284 = 0;
   }
   if (Ld_6136 > Ld_3768) {
      Ld_3004 = 0;
      Ld_3292 = 1;
   }
   if (Ld_6136 < Ld_3768) {
      Ld_3004 = 1;
      Ld_3292 = 0;
   }
   if (Ld_5952 > Ld_3768) {
      Ld_3012 = 0;
      Ld_3300 = 1;
   }
   if (Ld_5952 < Ld_3768) {
      Ld_3012 = 1;
      Ld_3300 = 0;
   }
   if (Ld_5960 > Ld_3768) {
      Ld_3020 = 0;
      Ld_3308 = 1;
   }
   if (Ld_5960 < Ld_3768) {
      Ld_3020 = 1;
      Ld_3308 = 0;
   }
   if (Ld_5968 > Ld_3768) {
      Ld_3028 = 0;
      Ld_3316 = 1;
   }
   if (Ld_5968 < Ld_3768) {
      Ld_3028 = 1;
      Ld_3316 = 0;
   }
   if (Ld_5976 > Ld_3768) {
      Ld_3036 = 0;
      Ld_3324 = 1;
   }
   if (Ld_5976 < Ld_3768) {
      Ld_3036 = 1;
      Ld_3324 = 0;
   }
   if (Ld_5984 > Ld_3768) {
      Ld_3044 = 0;
      Ld_3332 = 1;
   }
   if (Ld_5984 < Ld_3768) {
      Ld_3044 = 1;
      Ld_3332 = 0;
   }
   if (Ld_5992 > Ld_3768) {
      Ld_3052 = 0;
      Ld_3340 = 1;
   }
   if (Ld_5992 < Ld_3768) {
      Ld_3052 = 1;
      Ld_3340 = 0;
   }
   if (Ld_6144 > Ld_3768) {
      Ld_3060 = 0;
      Ld_3348 = 1;
   }
   if (Ld_6144 < Ld_3768) {
      Ld_3060 = 1;
      Ld_3348 = 0;
   }
   if (Ld_6152 > Ld_3768) {
      Ld_3068 = 0;
      Ld_3356 = 1;
   }
   if (Ld_6152 < Ld_3768) {
      Ld_3068 = 1;
      Ld_3356 = 0;
   }
   if (Ld_6160 > Ld_3768) {
      Ld_3076 = 0;
      Ld_3364 = 1;
   }
   if (Ld_6160 < Ld_3768) {
      Ld_3076 = 1;
      Ld_3364 = 0;
   }
   if (Ld_6168 > Ld_3768) {
      Ld_3084 = 0;
      Ld_3372 = 1;
   }
   if (Ld_6168 < Ld_3768) {
      Ld_3084 = 1;
      Ld_3372 = 0;
   }
   if (Ld_6176 > Ld_3768) {
      Ld_3092 = 0;
      Ld_3380 = 1;
   }
   if (Ld_6176 < Ld_3768) {
      Ld_3092 = 1;
      Ld_3380 = 0;
   }
   if (Ld_6184 > Ld_3768) {
      Ld_3100 = 0;
      Ld_3388 = 1;
   }
   if (Ld_6184 < Ld_3768) {
      Ld_3100 = 1;
      Ld_3388 = 0;
   }
   if (Ld_5904 > Ld_3768) {
      Ld_3108 = 0;
      Ld_3396 = 1;
   }
   if (Ld_5904 < Ld_3768) {
      Ld_3108 = 1;
      Ld_3396 = 0;
   }
   if (Ld_5912 > Ld_3768) {
      Ld_3116 = 0;
      Ld_3404 = 1;
   }
   if (Ld_5912 < Ld_3768) {
      Ld_3116 = 1;
      Ld_3404 = 0;
   }
   if (Ld_5920 > Ld_3768) {
      Ld_3124 = 0;
      Ld_3412 = 1;
   }
   if (Ld_5920 < Ld_3768) {
      Ld_3124 = 1;
      Ld_3412 = 0;
   }
   if (Ld_5928 > Ld_3768) {
      Ld_3132 = 0;
      Ld_3428 = 1;
   }
   if (Ld_5928 < Ld_3768) {
      Ld_3132 = 1;
      Ld_3428 = 0;
   }
   if (Ld_5936 > Ld_3768) {
      Ld_3148 = 0;
      Ld_3436 = 1;
   }
   if (Ld_5936 < Ld_3768) {
      Ld_3148 = 1;
      Ld_3436 = 0;
   }
   if (Ld_5944 > Ld_3768) {
      Ld_3156 = 0;
      Ld_3444 = 1;
   }
   if (Ld_5944 < Ld_3768) {
      Ld_3156 = 1;
      Ld_3444 = 0;
   }
   double Ld_6240 = Ld_2876 + Ld_2884 + Ld_2892 + Ld_2900 + Ld_2908 + Ld_2916 + Ld_2924 + Ld_2932 + Ld_2940 + Ld_2948 + Ld_2956 + Ld_2964 + Ld_2972 + Ld_2980 + Ld_2988 +
      Ld_2996 + Ld_3004 + Ld_3012 + Ld_3020 + Ld_3028 + Ld_3036 + Ld_3044 + Ld_3052 + Ld_3060 + Ld_3068 + Ld_3076 + Ld_3084 + Ld_3092 + Ld_3100 + Ld_3108 + Ld_3116 + Ld_3124 +
      Ld_3132 + Ld_3140 + Ld_3148 + Ld_3156 + Ld_2300 + Ld_2308 + Ld_2316 + Ld_2324 + Ld_2332 + Ld_2340 + Ld_2348 + Ld_2356 + Ld_2364 + Ld_2372 + Ld_2380 + Ld_2388 + Ld_2396 +
      Ld_2404 + Ld_2412 + Ld_2420 + Ld_2428 + Ld_2436 + Ld_2444 + Ld_2452 + Ld_2460 + Ld_2468 + Ld_2476 + Ld_2484 + Ld_2492 + Ld_2500 + Ld_2508 + Ld_2516 + Ld_2524 + Ld_2532 +
      Ld_2540 + Ld_2548 + Ld_2556 + Ld_2564 + Ld_2572 + Ld_2580;
   double Ld_6248 = Ld_3164 + Ld_3172 + Ld_3180 + Ld_3188 + Ld_3196 + Ld_3204 + Ld_3212 + Ld_3220 + Ld_3228 + Ld_3236 + Ld_3244 + Ld_3252 + Ld_3260 + Ld_3268 + Ld_3276 +
      Ld_3284 + Ld_3292 + Ld_3300 + Ld_3308 + Ld_3316 + Ld_3324 + Ld_3332 + Ld_3340 + Ld_3348 + Ld_3356 + Ld_3364 + Ld_3372 + Ld_3380 + Ld_3388 + Ld_3396 + Ld_3404 + Ld_3412 +
      Ld_3420 + Ld_3428 + Ld_3436 + Ld_3444 + Ld_2588 + Ld_2596 + Ld_2604 + Ld_2612 + Ld_2620 + Ld_2628 + Ld_2636 + Ld_2644 + Ld_2652 + Ld_2660 + Ld_2668 + Ld_2676 + Ld_2684 +
      Ld_2692 + Ld_2700 + Ld_2708 + Ld_2716 + Ld_2724 + Ld_2732 + Ld_2740 + Ld_2748 + Ld_2756 + Ld_2764 + Ld_2772 + Ld_2780 + Ld_2788 + Ld_2796 + Ld_2804 + Ld_2812 + Ld_2820 +
      Ld_2828 + Ld_2836 + Ld_2844 + Ld_2852 + Ld_2860 + Ld_2868;
   string dbl2str_6256 = DoubleToStr(100.0 * (Ld_6240 / 72.0), 0);
   string dbl2str_6264 = DoubleToStr(100 - StrToDouble(dbl2str_6256), 0);
   double Ld_6272 = Ld_572 + Ld_580 + Ld_588 + Ld_596 + Ld_604 + Ld_612 + Ld_620 + Ld_628 + Ld_636 + Ld_644 + Ld_652 + Ld_660 + Ld_668 + Ld_676 + Ld_684 + Ld_692 + Ld_700 +
      Ld_708 + Ld_716 + Ld_724 + Ld_732 + Ld_740 + Ld_748 + Ld_756 + Ld_764 + Ld_772 + Ld_780 + Ld_788 + Ld_796 + Ld_804 + Ld_812 + Ld_820 + Ld_828 + Ld_836 + Ld_844 + Ld_852 +
      Ld_4 + Ld_12 + Ld_20 + Ld_28 + Ld_4 + Ld_36 + Ld_44 + Ld_52 + Ld_60 + Ld_68 + Ld_76 + Ld_84 + Ld_92 + Ld_100 + Ld_108 + Ld_116 + Ld_124 + Ld_132 + Ld_140 + Ld_148 +
      Ld_156 + Ld_164 + Ld_172 + Ld_180 + Ld_188 + Ld_196 + Ld_204 + Ld_212 + Ld_220 + Ld_228 + Ld_236 + Ld_244 + Ld_252 + Ld_260 + Ld_268 + Ld_276 + Ld_1724 + Ld_1732 +
      Ld_1740 + Ld_1748 + Ld_1756 + Ld_1764 + Ld_1772 + Ld_1780 + Ld_1788 + Ld_1796 + Ld_1804 + Ld_1812 + Ld_1820 + Ld_1828 + Ld_1836 + Ld_1844 + Ld_1852 + Ld_1860 + Ld_1868 +
      Ld_1876 + Ld_1884 + Ld_1892 + Ld_1900 + Ld_1908 + Ld_1916 + Ld_1924 + Ld_1932 + Ld_1940 + Ld_1948 + Ld_1956 + Ld_1964 + Ld_1972 + Ld_1980 + Ld_1988 + Ld_1996 + Ld_2004 +
      Ld_1148 + Ld_1156 + Ld_1164 + Ld_1172 + Ld_1180 + Ld_1188 + Ld_1196 + Ld_1204 + Ld_1212 + Ld_1220 + Ld_1228 + Ld_1236 + Ld_1244 + Ld_1252 + Ld_1260 + Ld_1268 + Ld_1276 +
      Ld_1284 + Ld_1292 + Ld_1300 + Ld_1308 + Ld_1316 + Ld_1324 + Ld_1332 + Ld_1340 + Ld_1348 + Ld_1356 + Ld_1364 + Ld_1372 + Ld_1380 + Ld_1388 + Ld_1396 + Ld_1404 + Ld_1412 +
      Ld_1420 + Ld_1428 + Ld_2876 + Ld_2884 + Ld_2892 + Ld_2900 + Ld_2908 + Ld_2916 + Ld_2924 + Ld_2932 + Ld_2940 + Ld_2948 + Ld_2956 + Ld_2964 + Ld_2972 + Ld_2980 + Ld_2988 +
      Ld_2996 + Ld_3004 + Ld_3012 + Ld_3020 + Ld_3028 + Ld_3036 + Ld_3044 + Ld_3052 + Ld_3060 + Ld_3068 + Ld_3076 + Ld_3084 + Ld_3092 + Ld_3100 + Ld_3108 + Ld_3116 + Ld_3124 +
      Ld_3132 + Ld_3140 + Ld_3148 + Ld_3156 + Ld_2300 + Ld_2308 + Ld_2316 + Ld_2324 + Ld_2332 + Ld_2340 + Ld_2348 + Ld_2356 + Ld_2364 + Ld_2372 + Ld_2380 + Ld_2388 + Ld_2396 +
      Ld_2404 + Ld_2412 + Ld_2420 + Ld_2428 + Ld_2436 + Ld_2444 + Ld_2452 + Ld_2460 + Ld_2468 + Ld_2476 + Ld_2484 + Ld_2492 + Ld_2500 + Ld_2508 + Ld_2516 + Ld_2524 + Ld_2532 +
      Ld_2540 + Ld_2548 + Ld_2556 + Ld_2564 + Ld_2572 + Ld_2580;
   double Ld_6280 = Ld_860 + Ld_868 + Ld_876 + Ld_884 + Ld_892 + Ld_900 + Ld_908 + Ld_916 + Ld_924 + Ld_932 + Ld_940 + Ld_948 + Ld_956 + Ld_964 + Ld_972 + Ld_980 + Ld_988 +
      Ld_996 + Ld_1004 + Ld_1012 + Ld_1020 + Ld_1028 + Ld_1036 + Ld_1044 + Ld_1052 + Ld_1060 + Ld_1068 + Ld_1076 + Ld_1084 + Ld_1092 + Ld_1100 + Ld_1108 + Ld_1116 + Ld_1124 +
      Ld_1132 + Ld_1140 + Ld_284 + Ld_292 + Ld_300 + Ld_308 + Ld_284 + Ld_324 + Ld_332 + Ld_340 + Ld_348 + Ld_356 + Ld_364 + Ld_372 + Ld_380 + Ld_388 + Ld_396 + Ld_404 +
      Ld_412 + Ld_420 + Ld_428 + Ld_436 + Ld_444 + Ld_452 + Ld_460 + Ld_468 + Ld_476 + Ld_484 + Ld_492 + Ld_500 + Ld_508 + Ld_516 + Ld_524 + Ld_532 + Ld_540 + Ld_548 + Ld_556 +
      Ld_564 + Ld_2012 + Ld_2020 + Ld_2028 + Ld_2036 + Ld_2044 + Ld_2052 + Ld_2060 + Ld_2068 + Ld_2076 + Ld_2084 + Ld_2092 + Ld_2100 + Ld_2108 + Ld_2116 + Ld_2124 + Ld_2132 +
      Ld_2140 + Ld_2148 + Ld_2156 + Ld_2164 + Ld_2172 + Ld_2180 + Ld_2188 + Ld_2196 + Ld_2204 + Ld_2212 + Ld_2220 + Ld_2228 + Ld_2236 + Ld_2244 + Ld_2252 + Ld_2260 + Ld_2268 +
      Ld_2276 + Ld_2284 + Ld_2292 + Ld_1436 + Ld_1444 + Ld_1452 + Ld_1460 + Ld_1468 + Ld_1476 + Ld_1484 + Ld_1492 + Ld_1500 + Ld_1508 + Ld_1516 + Ld_1524 + Ld_1532 + Ld_1540 +
      Ld_1548 + Ld_1556 + Ld_1564 + Ld_1572 + Ld_1580 + Ld_1588 + Ld_1596 + Ld_1604 + Ld_1612 + Ld_1620 + Ld_1628 + Ld_1636 + Ld_1644 + Ld_1652 + Ld_1660 + Ld_1668 + Ld_1676 +
      Ld_1684 + Ld_1692 + Ld_1700 + Ld_1708 + Ld_1716 + Ld_3164 + Ld_3172 + Ld_3180 + Ld_3188 + Ld_3196 + Ld_3204 + Ld_3212 + Ld_3220 + Ld_3228 + Ld_3236 + Ld_3244 + Ld_3252 +
      Ld_3260 + Ld_3268 + Ld_3276 + Ld_3284 + Ld_3292 + Ld_3300 + Ld_3308 + Ld_3316 + Ld_3324 + Ld_3332 + Ld_3340 + Ld_3348 + Ld_3356 + Ld_3364 + Ld_3372 + Ld_3380 + Ld_3388 +
      Ld_3396 + Ld_3404 + Ld_3412 + Ld_3420 + Ld_3428 + Ld_3436 + Ld_3444 + Ld_2588 + Ld_2596 + Ld_2604 + Ld_2612 + Ld_2620 + Ld_2628 + Ld_2636 + Ld_2644 + Ld_2652 + Ld_2660 +
      Ld_2668 + Ld_2676 + Ld_2684 + Ld_2692 + Ld_2700 + Ld_2708 + Ld_2716 + Ld_2724 + Ld_2732 + Ld_2740 + Ld_2748 + Ld_2756 + Ld_2764 + Ld_2772 + Ld_2780 + Ld_2788 + Ld_2796 +
      Ld_2804 + Ld_2812 + Ld_2820 + Ld_2828 + Ld_2836 + Ld_2844 + Ld_2852 + Ld_2860 + Ld_2868;
   string dbl2str_6288 = DoubleToStr(100.0 * (Ld_6272 / 216.0), 0);
   string dbl2str_6296 = DoubleToStr(100 - StrToDouble(dbl2str_6288), 0);
   string text_6304 = "";
   string text_6312 = "";
   string text_6320 = "";
   string text_6328 = "";
   string text_6336 = "";
   string text_6344 = "";
   string text_6352 = "";
   string text_6360 = "";
   string text_6368 = "";
   string text_6376 = "";
   string text_6384 = "";
   string text_6392 = "";
   string text_6400 = "";
   string text_6408 = "";
   string text_6416 = "";
   string text_6424 = "";
   string text_6432 = "";
   string text_6440 = "";
   if (StrToDouble(dbl2str_6288) >= 90.0) {
      text_6304 = "-";
      color_3452 = UPcolor_1;
   }
   if (StrToDouble(dbl2str_6288) >= 80.0) {
      text_6312 = "-";
      color_3456 = UPcolor_2;
   }
   if (StrToDouble(dbl2str_6288) >= 70.0) {
      text_6320 = "-";
      color_3460 = UPcolor_3;
   }
   if (StrToDouble(dbl2str_6288) >= 60.0) {
      text_6328 = "-";
      color_3464 = UPcolor_4;
   }
   if (StrToDouble(dbl2str_6288) >= 50.0) {
      text_6336 = "-";
      color_3468 = UPcolor_5;
   }
   if (StrToDouble(dbl2str_6288) >= 40.0) {
      text_6344 = "-";
      color_3472 = UPcolor_6;
   }
   if (StrToDouble(dbl2str_6288) >= 30.0) {
      text_6352 = "-";
      color_3476 = UPcolor_7;
   }
   if (StrToDouble(dbl2str_6288) >= 20.0) {
      text_6360 = "-";
      color_3480 = UPcolor_8;
   }
   if (StrToDouble(dbl2str_6288) >= 0.0) {
      text_6368 = "-";
      color_3484 = UPcolor_9;
   }
   if (StrToDouble(dbl2str_6296) > 90.0) {
      text_6376 = "-";
      color_3488 = DNcolor_1;
   }
   if (StrToDouble(dbl2str_6296) > 80.0) {
      text_6384 = "-";
      color_3492 = DNcolor_2;
   }
   if (StrToDouble(dbl2str_6296) > 70.0) {
      text_6392 = "-";
      color_3496 = DNcolor_3;
   }
   if (StrToDouble(dbl2str_6296) > 60.0) {
      text_6400 = "-";
      color_3500 = DNcolor_4;
   }
   if (StrToDouble(dbl2str_6296) > 50.0) {
      text_6408 = "-";
      color_3504 = DNcolor_5;
   }
   if (StrToDouble(dbl2str_6296) > 40.0) {
      text_6416 = "-";
      color_3508 = DNcolor_6;
   }
   if (StrToDouble(dbl2str_6296) > 30.0) {
      text_6424 = "-";
      color_3512 = DNcolor_7;
   }
   if (StrToDouble(dbl2str_6296) > 20.0) {
      text_6432 = "-";
      color_3516 = DNcolor_8;
   }
   if (StrToDouble(dbl2str_6296) > 0.0) {
      text_6440 = "-";
      color_3520 = DNcolor_9;
   }
   string text_6448 = "";
   if (StrToDouble(dbl2str_6288) >= 90.0) {
      text_6448 = "+ UP Xtreme +";
      color_3524 = UPcolor_1;
   }
   if (StrToDouble(dbl2str_6296) >= 90.0) {
      text_6448 = "+ DN Xtreme +";
      color_3524 = DNcolor_1;
   }
   if (StrToDouble(dbl2str_6288) >= 75.0 && StrToDouble(dbl2str_6288) < 90.0) {
      text_6448 = "+ UP Strong +";
      color_3524 = UPcolor_1;
   }
   if (StrToDouble(dbl2str_6296) >= 75.0 && StrToDouble(dbl2str_6296) < 90.0) {
      text_6448 = "+ DN Strong +";
      color_3524 = DNcolor_1;
   }
   if (StrToDouble(dbl2str_6288) >= 60.0 && StrToDouble(dbl2str_6288) < 75.0) {
      text_6448 = "+ UP Medium +";
      color_3524 = UPcolor_4;
   }
   if (StrToDouble(dbl2str_6296) >= 60.0 && StrToDouble(dbl2str_6296) < 75.0) {
      text_6448 = "+ DN Medium +";
      color_3524 = DNcolor_5;
   }
   if (StrToDouble(dbl2str_6288) >= 55.0 && StrToDouble(dbl2str_6288) < 60.0) {
      text_6448 = "+  UP Weak  +";
      color_3524 = UPcolor_7;
   }
   if (StrToDouble(dbl2str_6296) >= 55.0 && StrToDouble(dbl2str_6296) < 60.0) {
      text_6448 = "+  Dn Weak  +";
      color_3524 = DNcolor_6;
   }
   if (StrToDouble(dbl2str_6296) >= 50.0 && StrToDouble(dbl2str_6296) < 55.0) {
      text_6448 = "+   Neutral   +";
      color_3524 = EQUALcolor;
   }
   if (StrToDouble(dbl2str_6288) >= 50.0 && StrToDouble(dbl2str_6288) < 55.0) {
      text_6448 = "+   Neutral   +";
      color_3524 = EQUALcolor;
   }
   CreateDynamic("SIG_RESULTS" + Dynamic_Number, BarsShift_UP_DN + 106, BarsShift_Side + 18);
   ObjectSetText("SIG_RESULTS" + Dynamic_Number, text_6448, 10, "Tahoma Bold", color_3524);
   CreateDynamic("SIG_LEVEL" + Dynamic_Number, BarsShift_UP_DN + 25, BarsShift_Side + 20);
   ObjectSetText("SIG_LEVEL" + Dynamic_Number, text_6304, 40, "Tahoma", color_3452);
   CreateDynamic("SIG_LEVEL_1" + Dynamic_Number, BarsShift_UP_DN + 30, BarsShift_Side + 20);
   ObjectSetText("SIG_LEVEL_1" + Dynamic_Number, text_6312, 40, "Tahoma", color_3456);
   CreateDynamic("SIG_LEVEL_2" + Dynamic_Number, BarsShift_UP_DN + 35, BarsShift_Side + 20);
   ObjectSetText("SIG_LEVEL_2" + Dynamic_Number, text_6320, 40, "Tahoma", color_3460);
   CreateDynamic("SIG_LEVEL_3" + Dynamic_Number, BarsShift_UP_DN + 40, BarsShift_Side + 20);
   ObjectSetText("SIG_LEVEL_3" + Dynamic_Number, text_6328, 40, "Tahoma", color_3464);
   CreateDynamic("SIG_LEVEL_4" + Dynamic_Number, BarsShift_UP_DN + 45, BarsShift_Side + 20);
   ObjectSetText("SIG_LEVEL_4" + Dynamic_Number, text_6336, 40, "Tahoma", color_3468);
   CreateDynamic("SIG_LEVEL_5" + Dynamic_Number, BarsShift_UP_DN + 50, BarsShift_Side + 20);
   ObjectSetText("SIG_LEVEL_5" + Dynamic_Number, text_6344, 40, "Tahoma", color_3472);
   CreateDynamic("SIG_LEVEL_6" + Dynamic_Number, BarsShift_UP_DN + 55, BarsShift_Side + 20);
   ObjectSetText("SIG_LEVEL_6" + Dynamic_Number, text_6352, 40, "Tahoma", color_3476);
   CreateDynamic("SIG_LEVEL_7" + Dynamic_Number, BarsShift_UP_DN + 60, BarsShift_Side + 20);
   ObjectSetText("SIG_LEVEL_7" + Dynamic_Number, text_6360, 40, "Tahoma", color_3480);
   CreateDynamic("SIG_LEVEL_8" + Dynamic_Number, BarsShift_UP_DN + 65, BarsShift_Side + 20);
   ObjectSetText("SIG_LEVEL_8" + Dynamic_Number, text_6368, 40, "Tahoma", color_3484);
   CreateDynamic("SIG_LEVEL_9" + Dynamic_Number, BarsShift_UP_DN + 65, BarsShift_Side + 20);
   ObjectSetText("SIG_LEVEL_9" + Dynamic_Number, text_6376, 40, "Tahoma", color_3488);
   CreateDynamic("SIG_LEVEL_10" + Dynamic_Number, BarsShift_UP_DN + 60, BarsShift_Side + 20);
   ObjectSetText("SIG_LEVEL_10" + Dynamic_Number, text_6384, 40, "Tahoma", color_3492);
   CreateDynamic("SIG_LEVEL_11" + Dynamic_Number, BarsShift_UP_DN + 55, BarsShift_Side + 20);
   ObjectSetText("SIG_LEVEL_11" + Dynamic_Number, text_6392, 40, "Tahoma", color_3496);
   CreateDynamic("SIG_LEVEL_12" + Dynamic_Number, BarsShift_UP_DN + 50, BarsShift_Side + 20);
   ObjectSetText("SIG_LEVEL_12" + Dynamic_Number, text_6400, 40, "Tahoma", color_3500);
   CreateDynamic("SIG_LEVEL_13" + Dynamic_Number, BarsShift_UP_DN + 45, BarsShift_Side + 20);
   ObjectSetText("SIG_LEVEL_13" + Dynamic_Number, text_6408, 40, "Tahoma", color_3504);
   CreateDynamic("SIG_LEVEL_14" + Dynamic_Number, BarsShift_UP_DN + 40, BarsShift_Side + 20);
   ObjectSetText("SIG_LEVEL_14" + Dynamic_Number, text_6416, 40, "Tahoma", color_3508);
   CreateDynamic("SIG_LEVEL_15" + Dynamic_Number, BarsShift_UP_DN + 35, BarsShift_Side + 20);
   ObjectSetText("SIG_LEVEL_15" + Dynamic_Number, text_6424, 40, "Tahoma", color_3512);
   CreateDynamic("SIG_LEVEL_16" + Dynamic_Number, BarsShift_UP_DN + 30, BarsShift_Side + 20);
   ObjectSetText("SIG_LEVEL_16" + Dynamic_Number, text_6432, 40, "Tahoma", color_3516);
   CreateDynamic("SIG_LEVEL_17" + Dynamic_Number, BarsShift_UP_DN + 25, BarsShift_Side + 20);
   ObjectSetText("SIG_LEVEL_17" + Dynamic_Number, text_6440, 40, "Tahoma", color_3520);
   string text_6456 = "";
   string text_6464 = "";
   string text_6472 = "";
   string text_6480 = "";
   string text_6488 = "";
   string text_6496 = "";
   string text_6504 = "";
   string text_6512 = "";
   string text_6520 = "";
   string text_6528 = "";
   string text_6536 = "";
   string text_6544 = "";
   string text_6552 = "";
   string text_6560 = "";
   string text_6568 = "";
   string text_6576 = "";
   string text_6584 = "";
   string text_6592 = "";
   if (StrToDouble(dbl2str_6256) >= 90.0) {
      text_6456 = "-";
      color_3528 = UPcolor_1;
   }
   if (StrToDouble(dbl2str_6256) >= 80.0) {
      text_6464 = "-";
      color_3532 = UPcolor_2;
   }
   if (StrToDouble(dbl2str_6256) >= 70.0) {
      text_6472 = "-";
      color_3536 = UPcolor_3;
   }
   if (StrToDouble(dbl2str_6256) >= 60.0) {
      text_6480 = "-";
      color_3540 = UPcolor_4;
   }
   if (StrToDouble(dbl2str_6256) >= 50.0) {
      text_6488 = "-";
      color_3544 = UPcolor_5;
   }
   if (StrToDouble(dbl2str_6256) >= 40.0) {
      text_6496 = "-";
      color_3548 = UPcolor_6;
   }
   if (StrToDouble(dbl2str_6256) >= 30.0) {
      text_6504 = "-";
      color_3552 = UPcolor_7;
   }
   if (StrToDouble(dbl2str_6256) >= 20.0) {
      text_6512 = "-";
      color_3556 = UPcolor_8;
   }
   if (StrToDouble(dbl2str_6256) >= 0.0) {
      text_6520 = "-";
      color_3560 = UPcolor_9;
   }
   if (StrToDouble(dbl2str_6264) > 90.0) {
      text_6528 = "-";
      color_3564 = DNcolor_1;
   }
   if (StrToDouble(dbl2str_6264) > 80.0) {
      text_6536 = "-";
      color_3568 = DNcolor_2;
   }
   if (StrToDouble(dbl2str_6264) > 70.0) {
      text_6544 = "-";
      color_3572 = DNcolor_3;
   }
   if (StrToDouble(dbl2str_6264) > 60.0) {
      text_6552 = "-";
      color_3576 = DNcolor_4;
   }
   if (StrToDouble(dbl2str_6264) > 50.0) {
      text_6560 = "-";
      color_3580 = DNcolor_5;
   }
   if (StrToDouble(dbl2str_6264) > 40.0) {
      text_6568 = "-";
      color_3584 = DNcolor_6;
   }
   if (StrToDouble(dbl2str_6264) > 30.0) {
      text_6576 = "-";
      color_3588 = DNcolor_7;
   }
   if (StrToDouble(dbl2str_6264) > 20.0) {
      text_6584 = "-";
      color_3592 = DNcolor_8;
   }
   if (StrToDouble(dbl2str_6264) > 0.0) {
      text_6592 = "-";
      color_3596 = DNcolor_9;
   }
   CreateDynamic("H4_LEVEL" + Dynamic_Number, BarsShift_UP_DN + 25, BarsShift_Side + 36);
   ObjectSetText("H4_LEVEL" + Dynamic_Number, text_6456, 40, "Tahoma", color_3528);
   CreateDynamic("H4_LEVEL_1" + Dynamic_Number, BarsShift_UP_DN + 30, BarsShift_Side + 36);
   ObjectSetText("H4_LEVEL_1" + Dynamic_Number, text_6464, 40, "Tahoma", color_3532);
   CreateDynamic("H4_LEVEL_2" + Dynamic_Number, BarsShift_UP_DN + 35, BarsShift_Side + 36);
   ObjectSetText("H4_LEVEL_2" + Dynamic_Number, text_6472, 40, "Tahoma", color_3536);
   CreateDynamic("H4_LEVEL_3" + Dynamic_Number, BarsShift_UP_DN + 40, BarsShift_Side + 36);
   ObjectSetText("H4_LEVEL_3" + Dynamic_Number, text_6480, 40, "Tahoma", color_3540);
   CreateDynamic("H4_LEVEL_4" + Dynamic_Number, BarsShift_UP_DN + 45, BarsShift_Side + 36);
   ObjectSetText("H4_LEVEL_4" + Dynamic_Number, text_6488, 40, "Tahoma", color_3544);
   CreateDynamic("H4_LEVEL_5" + Dynamic_Number, BarsShift_UP_DN + 50, BarsShift_Side + 36);
   ObjectSetText("H4_LEVEL_5" + Dynamic_Number, text_6496, 40, "Tahoma", color_3548);
   CreateDynamic("H4_LEVEL_6" + Dynamic_Number, BarsShift_UP_DN + 55, BarsShift_Side + 36);
   ObjectSetText("H4_LEVEL_6" + Dynamic_Number, text_6504, 40, "Tahoma", color_3552);
   CreateDynamic("H4_LEVEL_7" + Dynamic_Number, BarsShift_UP_DN + 60, BarsShift_Side + 36);
   ObjectSetText("H4_LEVEL_7" + Dynamic_Number, text_6512, 40, "Tahoma", color_3556);
   CreateDynamic("H4_LEVEL_8" + Dynamic_Number, BarsShift_UP_DN + 65, BarsShift_Side + 36);
   ObjectSetText("H4_LEVEL_8" + Dynamic_Number, text_6520, 40, "Tahoma", color_3560);
   CreateDynamic("H4_LEVEL_9" + Dynamic_Number, BarsShift_UP_DN + 65, BarsShift_Side + 36);
   ObjectSetText("H4_LEVEL_9" + Dynamic_Number, text_6528, 40, "Tahoma", color_3564);
   CreateDynamic("H4_LEVEL_10" + Dynamic_Number, BarsShift_UP_DN + 60, BarsShift_Side + 36);
   ObjectSetText("H4_LEVEL_10" + Dynamic_Number, text_6536, 40, "Tahoma", color_3568);
   CreateDynamic("H4_LEVEL_11" + Dynamic_Number, BarsShift_UP_DN + 55, BarsShift_Side + 36);
   ObjectSetText("H4_LEVEL_11" + Dynamic_Number, text_6544, 40, "Tahoma", color_3572);
   CreateDynamic("H4_LEVEL_12" + Dynamic_Number, BarsShift_UP_DN + 50, BarsShift_Side + 36);
   ObjectSetText("H4_LEVEL_12" + Dynamic_Number, text_6552, 40, "Tahoma", color_3576);
   CreateDynamic("H4_LEVEL_13" + Dynamic_Number, BarsShift_UP_DN + 45, BarsShift_Side + 36);
   ObjectSetText("H4_LEVEL_13" + Dynamic_Number, text_6560, 40, "Tahoma", color_3580);
   CreateDynamic("H4_LEVEL_14" + Dynamic_Number, BarsShift_UP_DN + 40, BarsShift_Side + 36);
   ObjectSetText("H4_LEVEL_14" + Dynamic_Number, text_6568, 40, "Tahoma", color_3584);
   CreateDynamic("H4_LEVEL_15" + Dynamic_Number, BarsShift_UP_DN + 35, BarsShift_Side + 36);
   ObjectSetText("H4_LEVEL_15" + Dynamic_Number, text_6576, 40, "Tahoma", color_3588);
   CreateDynamic("H4_LEVEL_16" + Dynamic_Number, BarsShift_UP_DN + 30, BarsShift_Side + 36);
   ObjectSetText("H4_LEVEL_16" + Dynamic_Number, text_6584, 40, "Tahoma", color_3592);
   CreateDynamic("H4_LEVEL_17" + Dynamic_Number, BarsShift_UP_DN + 25, BarsShift_Side + 36);
   ObjectSetText("H4_LEVEL_17" + Dynamic_Number, text_6592, 40, "Tahoma", color_3596);
   string text_6600 = "";
   string text_6608 = "";
   string text_6616 = "";
   string text_6624 = "";
   string text_6632 = "";
   string text_6640 = "";
   string text_6648 = "";
   string text_6656 = "";
   string text_6664 = "";
   string text_6672 = "";
   string text_6680 = "";
   string text_6688 = "";
   string text_6696 = "";
   string text_6704 = "";
   string text_6712 = "";
   string text_6720 = "";
   string text_6728 = "";
   string text_6736 = "";
   if (StrToDouble(dbl2str_5424) >= 90.0) {
      text_6600 = "-";
      color_3600 = UPcolor_1;
   }
   if (StrToDouble(dbl2str_5424) >= 80.0) {
      text_6608 = "-";
      color_3604 = UPcolor_2;
   }
   if (StrToDouble(dbl2str_5424) >= 70.0) {
      text_6616 = "-";
      color_3608 = UPcolor_3;
   }
   if (StrToDouble(dbl2str_5424) >= 60.0) {
      text_6624 = "-";
      color_3612 = UPcolor_4;
   }
   if (StrToDouble(dbl2str_5424) >= 50.0) {
      text_6632 = "-";
      color_3616 = UPcolor_5;
   }
   if (StrToDouble(dbl2str_5424) >= 40.0) {
      text_6640 = "-";
      color_3620 = UPcolor_6;
   }
   if (StrToDouble(dbl2str_5424) >= 30.0) {
      text_6648 = "-";
      color_3624 = UPcolor_7;
   }
   if (StrToDouble(dbl2str_5424) >= 20.0) {
      text_6656 = "-";
      color_3628 = UPcolor_8;
   }
   if (StrToDouble(dbl2str_5424) >= 0.0) {
      text_6664 = "-";
      color_3632 = UPcolor_9;
   }
   if (StrToDouble(dbl2str_5432) > 90.0) {
      text_6672 = "-";
      color_3636 = DNcolor_1;
   }
   if (StrToDouble(dbl2str_5432) > 80.0) {
      text_6680 = "-";
      color_3640 = DNcolor_2;
   }
   if (StrToDouble(dbl2str_5432) > 70.0) {
      text_6688 = "-";
      color_3644 = DNcolor_3;
   }
   if (StrToDouble(dbl2str_5432) > 60.0) {
      text_6696 = "-";
      color_3648 = DNcolor_4;
   }
   if (StrToDouble(dbl2str_5432) > 50.0) {
      text_6704 = "-";
      color_3652 = DNcolor_5;
   }
   if (StrToDouble(dbl2str_5432) > 40.0) {
      text_6712 = "-";
      color_3656 = DNcolor_6;
   }
   if (StrToDouble(dbl2str_5432) > 30.0) {
      text_6720 = "-";
      color_3660 = DNcolor_7;
   }
   if (StrToDouble(dbl2str_5432) > 20.0) {
      text_6728 = "-";
      color_3664 = DNcolor_8;
   }
   if (StrToDouble(dbl2str_5432) > 0.0) {
      text_6736 = "-";
      color_3668 = DNcolor_9;
   }
   CreateDynamic("M30_LEVEL" + Dynamic_Number, BarsShift_UP_DN + 25, BarsShift_Side + 52);
   ObjectSetText("M30_LEVEL" + Dynamic_Number, text_6600, 40, "Tahoma", color_3600);
   CreateDynamic("M30_LEVEL_1" + Dynamic_Number, BarsShift_UP_DN + 30, BarsShift_Side + 52);
   ObjectSetText("M30_LEVEL_1" + Dynamic_Number, text_6608, 40, "Tahoma", color_3604);
   CreateDynamic("M30_LEVEL_2" + Dynamic_Number, BarsShift_UP_DN + 35, BarsShift_Side + 52);
   ObjectSetText("M30_LEVEL_2" + Dynamic_Number, text_6616, 40, "Tahoma", color_3608);
   CreateDynamic("M30_LEVEL_3" + Dynamic_Number, BarsShift_UP_DN + 40, BarsShift_Side + 52);
   ObjectSetText("M30_LEVEL_3" + Dynamic_Number, text_6624, 40, "Tahoma", color_3612);
   CreateDynamic("M30_LEVEL_4" + Dynamic_Number, BarsShift_UP_DN + 45, BarsShift_Side + 52);
   ObjectSetText("M30_LEVEL_4" + Dynamic_Number, text_6632, 40, "Tahoma", color_3616);
   CreateDynamic("M30_LEVEL_5" + Dynamic_Number, BarsShift_UP_DN + 50, BarsShift_Side + 52);
   ObjectSetText("M30_LEVEL_5" + Dynamic_Number, text_6640, 40, "Tahoma", color_3620);
   CreateDynamic("M30_LEVEL_6" + Dynamic_Number, BarsShift_UP_DN + 55, BarsShift_Side + 52);
   ObjectSetText("M30_LEVEL_6" + Dynamic_Number, text_6648, 40, "Tahoma", color_3624);
   CreateDynamic("M30_LEVEL_7" + Dynamic_Number, BarsShift_UP_DN + 60, BarsShift_Side + 52);
   ObjectSetText("M30_LEVEL_7" + Dynamic_Number, text_6656, 40, "Tahoma", color_3628);
   CreateDynamic("M30_LEVEL_8" + Dynamic_Number, BarsShift_UP_DN + 65, BarsShift_Side + 52);
   ObjectSetText("M30_LEVEL_8" + Dynamic_Number, text_6664, 40, "Tahoma", color_3632);
   CreateDynamic("M30_LEVEL_9" + Dynamic_Number, BarsShift_UP_DN + 65, BarsShift_Side + 52);
   ObjectSetText("M30_LEVEL_9" + Dynamic_Number, text_6672, 40, "Tahoma", color_3636);
   CreateDynamic("M30_LEVEL_10" + Dynamic_Number, BarsShift_UP_DN + 60, BarsShift_Side + 52);
   ObjectSetText("M30_LEVEL_10" + Dynamic_Number, text_6680, 40, "Tahoma", color_3640);
   CreateDynamic("M30_LEVEL_11" + Dynamic_Number, BarsShift_UP_DN + 55, BarsShift_Side + 52);
   ObjectSetText("M30_LEVEL_11" + Dynamic_Number, text_6688, 40, "Tahoma", color_3644);
   CreateDynamic("M30_LEVEL_12" + Dynamic_Number, BarsShift_UP_DN + 50, BarsShift_Side + 52);
   ObjectSetText("M30_LEVEL_12" + Dynamic_Number, text_6696, 40, "Tahoma", color_3648);
   CreateDynamic("M30_LEVEL_13" + Dynamic_Number, BarsShift_UP_DN + 45, BarsShift_Side + 52);
   ObjectSetText("M30_LEVEL_13" + Dynamic_Number, text_6704, 40, "Tahoma", color_3652);
   CreateDynamic("M30_LEVEL_14" + Dynamic_Number, BarsShift_UP_DN + 40, BarsShift_Side + 52);
   ObjectSetText("M30_LEVEL_14" + Dynamic_Number, text_6712, 40, "Tahoma", color_3656);
   CreateDynamic("M30_LEVEL_15" + Dynamic_Number, BarsShift_UP_DN + 35, BarsShift_Side + 52);
   ObjectSetText("M30_LEVEL_15" + Dynamic_Number, text_6720, 40, "Tahoma", color_3660);
   CreateDynamic("M30_LEVEL_16" + Dynamic_Number, BarsShift_UP_DN + 30, BarsShift_Side + 52);
   ObjectSetText("M30_LEVEL_16" + Dynamic_Number, text_6728, 40, "Tahoma", color_3664);
   CreateDynamic("M30_LEVEL_17" + Dynamic_Number, BarsShift_UP_DN + 25, BarsShift_Side + 52);
   ObjectSetText("M30_LEVEL_17" + Dynamic_Number, text_6736, 40, "Tahoma", color_3668);
   string text_6744 = "";
   string text_6752 = "";
   string text_6760 = "";
   string text_6768 = "";
   string text_6776 = "";
   string text_6784 = "";
   string text_6792 = "";
   string text_6800 = "";
   string text_6808 = "";
   string text_6816 = "";
   string text_6824 = "";
   string text_6832 = "";
   string text_6840 = "";
   string text_6848 = "";
   string text_6856 = "";
   string text_6864 = "";
   string text_6872 = "";
   string text_6880 = "";
   if (StrToDouble(dbl2str_4592) >= 90.0) {
      text_6744 = "-";
      color_3672 = UPcolor_1;
   }
   if (StrToDouble(dbl2str_4592) >= 80.0) {
      text_6752 = "-";
      color_3676 = UPcolor_2;
   }
   if (StrToDouble(dbl2str_4592) >= 70.0) {
      text_6760 = "-";
      color_3680 = UPcolor_3;
   }
   if (StrToDouble(dbl2str_4592) >= 60.0) {
      text_6768 = "-";
      color_3684 = UPcolor_4;
   }
   if (StrToDouble(dbl2str_4592) >= 50.0) {
      text_6776 = "-";
      color_3688 = UPcolor_5;
   }
   if (StrToDouble(dbl2str_4592) >= 40.0) {
      text_6784 = "-";
      color_3692 = UPcolor_6;
   }
   if (StrToDouble(dbl2str_4592) >= 30.0) {
      text_6792 = "-";
      color_3696 = UPcolor_7;
   }
   if (StrToDouble(dbl2str_4592) >= 20.0) {
      text_6800 = "-";
      color_3700 = UPcolor_8;
   }
   if (StrToDouble(dbl2str_4592) >= 0.0) {
      text_6808 = "-";
      color_3704 = UPcolor_9;
   }
   if (StrToDouble(dbl2str_4600) > 90.0) {
      text_6816 = "-";
      color_3708 = DNcolor_1;
   }
   if (StrToDouble(dbl2str_4600) > 80.0) {
      text_6824 = "-";
      color_3712 = DNcolor_2;
   }
   if (StrToDouble(dbl2str_4600) > 70.0) {
      text_6832 = "-";
      color_3716 = DNcolor_3;
   }
   if (StrToDouble(dbl2str_4600) > 60.0) {
      text_6840 = "-";
      color_3720 = DNcolor_4;
   }
   if (StrToDouble(dbl2str_4600) > 50.0) {
      text_6848 = "-";
      color_3724 = DNcolor_5;
   }
   if (StrToDouble(dbl2str_4600) > 40.0) {
      text_6856 = "-";
      color_3728 = DNcolor_6;
   }
   if (StrToDouble(dbl2str_4600) > 30.0) {
      text_6864 = "-";
      color_3732 = DNcolor_7;
   }
   if (StrToDouble(dbl2str_4600) > 20.0) {
      text_6872 = "-";
      color_3736 = DNcolor_8;
   }
   if (StrToDouble(dbl2str_4600) > 0.0) {
      text_6880 = "-";
      color_3740 = DNcolor_9;
   }
   CreateDynamic("M5_LEVEL" + Dynamic_Number, BarsShift_UP_DN + 25, BarsShift_Side + 68);
   ObjectSetText("M5_LEVEL" + Dynamic_Number, text_6744, 40, "Tahoma", color_3672);
   CreateDynamic("M5_LEVEL_1" + Dynamic_Number, BarsShift_UP_DN + 30, BarsShift_Side + 68);
   ObjectSetText("M5_LEVEL_1" + Dynamic_Number, text_6752, 40, "Tahoma", color_3676);
   CreateDynamic("M5_LEVEL_2" + Dynamic_Number, BarsShift_UP_DN + 35, BarsShift_Side + 68);
   ObjectSetText("M5_LEVEL_2" + Dynamic_Number, text_6760, 40, "Tahoma", color_3680);
   CreateDynamic("M5_LEVEL_3" + Dynamic_Number, BarsShift_UP_DN + 40, BarsShift_Side + 68);
   ObjectSetText("M5_LEVEL_3" + Dynamic_Number, text_6768, 40, "Tahoma", color_3684);
   CreateDynamic("M5_LEVEL_4" + Dynamic_Number, BarsShift_UP_DN + 45, BarsShift_Side + 68);
   ObjectSetText("M5_LEVEL_4" + Dynamic_Number, text_6776, 40, "Tahoma", color_3688);
   CreateDynamic("M5_LEVEL_5" + Dynamic_Number, BarsShift_UP_DN + 50, BarsShift_Side + 68);
   ObjectSetText("M5_LEVEL_5" + Dynamic_Number, text_6784, 40, "Tahoma", color_3692);
   CreateDynamic("M5_LEVEL_6" + Dynamic_Number, BarsShift_UP_DN + 55, BarsShift_Side + 68);
   ObjectSetText("M5_LEVEL_6" + Dynamic_Number, text_6792, 40, "Tahoma", color_3696);
   CreateDynamic("M5_LEVEL_7" + Dynamic_Number, BarsShift_UP_DN + 60, BarsShift_Side + 68);
   ObjectSetText("M5_LEVEL_7" + Dynamic_Number, text_6800, 40, "Tahoma", color_3700);
   CreateDynamic("M5_LEVEL_8" + Dynamic_Number, BarsShift_UP_DN + 65, BarsShift_Side + 68);
   ObjectSetText("M5_LEVEL_8" + Dynamic_Number, text_6808, 40, "Tahoma", color_3704);
   CreateDynamic("M5_LEVEL_9" + Dynamic_Number, BarsShift_UP_DN + 65, BarsShift_Side + 68);
   ObjectSetText("M5_LEVEL_9" + Dynamic_Number, text_6816, 40, "Tahoma", color_3708);
   CreateDynamic("M5_LEVEL_10" + Dynamic_Number, BarsShift_UP_DN + 60, BarsShift_Side + 68);
   ObjectSetText("M5_LEVEL_10" + Dynamic_Number, text_6824, 40, "Tahoma", color_3712);
   CreateDynamic("M5_LEVEL_11" + Dynamic_Number, BarsShift_UP_DN + 55, BarsShift_Side + 68);
   ObjectSetText("M5_LEVEL_11" + Dynamic_Number, text_6832, 40, "Tahoma", color_3716);
   CreateDynamic("M5_LEVEL_12" + Dynamic_Number, BarsShift_UP_DN + 50, BarsShift_Side + 68);
   ObjectSetText("M5_LEVEL_12" + Dynamic_Number, text_6840, 40, "Tahoma", color_3720);
   CreateDynamic("M5_LEVEL_13" + Dynamic_Number, BarsShift_UP_DN + 45, BarsShift_Side + 68);
   ObjectSetText("M5_LEVEL_13" + Dynamic_Number, text_6848, 40, "Tahoma", color_3724);
   CreateDynamic("M5_LEVEL_14" + Dynamic_Number, BarsShift_UP_DN + 40, BarsShift_Side + 68);
   ObjectSetText("M5_LEVEL_14" + Dynamic_Number, text_6856, 40, "Tahoma", color_3728);
   CreateDynamic("M5_LEVEL_15" + Dynamic_Number, BarsShift_UP_DN + 35, BarsShift_Side + 68);
   ObjectSetText("M5_LEVEL_15" + Dynamic_Number, text_6864, 40, "Tahoma", color_3732);
   CreateDynamic("M5_LEVEL_16" + Dynamic_Number, BarsShift_UP_DN + 30, BarsShift_Side + 68);
   ObjectSetText("M5_LEVEL_16" + Dynamic_Number, text_6872, 40, "Tahoma", color_3736);
   CreateDynamic("M5_LEVEL_17" + Dynamic_Number, BarsShift_UP_DN + 25, BarsShift_Side + 68);
   ObjectSetText("M5_LEVEL_17" + Dynamic_Number, text_6880, 40, "Tahoma", color_3740);
   CreateDynamic("TREND_Display" + Dynamic_Number, BarsShift_UP_DN + 10, BarsShift_Side + 21);
   ObjectSetText("TREND_Display" + Dynamic_Number, "Dynamic Trend", 10, "Tahoma Bold", DynamicTitle_color);
   CreateDynamic("TREND_Display1" + Dynamic_Number, BarsShift_UP_DN + 23, BarsShift_Side + 21);
   ObjectSetText("TREND_Display1" + Dynamic_Number, "" + Currency_Symbol + "", 17, "Tahoma Narrow", Currency_color);
   CreateDynamic("TREND_Display2" + Dynamic_Number, BarsShift_UP_DN + 45, BarsShift_Side + 20);
   ObjectSetText("TREND_Display2" + Dynamic_Number, "Curr  H4 / H1   to   M5 / M1", 6, "Tahoma Narrow", PeriodTitles_color);
   CreateDynamic("TREND_Display3" + Dynamic_Number, BarsShift_UP_DN + 4, BarsShift_Side + 19);
   ObjectSetText("TREND_Display3" + Dynamic_Number, "--------------------------------", 7, "Tahoma Narrow", DottedSeparator_color);
   CreateDynamic("TREND_Display4" + Dynamic_Number, BarsShift_UP_DN + 82, BarsShift_Side + 88);
   ObjectSetText("TREND_Display4" + Dynamic_Number, dbl2str_6288 + "%", 10, "Tahoma Narrow", UPcolor_4);
   CreateDynamic("TREND_Display5" + Dynamic_Number, BarsShift_UP_DN + 62, BarsShift_Side + 88);
   ObjectSetText("TREND_Display5" + Dynamic_Number, dbl2str_6296 + "%", 10, "Tahoma Narrow", DNcolor_4);
   CreateDynamic("TREND_Display6" + Dynamic_Number, BarsShift_UP_DN + 99, BarsShift_Side + 20);
   ObjectSetText("TREND_Display6" + Dynamic_Number, "-------------------------------- ", 7, "Tahoma", DottedSeparator_color);
   CreateDynamic("TREND_Display7" + Dynamic_Number, BarsShift_UP_DN + 50, BarsShift_Side + 20);
   ObjectSetText("TREND_Display7" + Dynamic_Number, "-------------------------------- ", 7, "Tahoma", DottedSeparator_color);
   CreateDynamic("TREND_Display8" + Dynamic_Number, BarsShift_UP_DN + 117, BarsShift_Side + 20);
   ObjectSetText("TREND_Display8" + Dynamic_Number, "-------------------------------- ", 7, "Tahoma", DottedSeparator_color);
   return (0);
}
