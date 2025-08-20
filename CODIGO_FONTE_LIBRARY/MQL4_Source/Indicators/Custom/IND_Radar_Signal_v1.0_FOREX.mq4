/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website: h T tp: // WWW . M e TA QuO T eS . NeT
   E-mail :  Sup porT@m e t aQu o TE s.N Et
*/
#property copyright "Copyright © 2010 www.radarsignal.in"
#property link      "www.radarsignal.in"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 CLR_NONE
#property indicator_color2 CLR_NONE
#property indicator_color3 CLR_NONE
#property indicator_color4 CLR_NONE
#property indicator_color5 Maroon
#property indicator_color6 Green
#property indicator_color7 Maroon
#property indicator_color8 Green

string Gs_unused_76 = "10000000";
string Gs_84 = "NO";
double G_ibuf_92[];
double G_ibuf_96[];
double G_ibuf_100[];
double G_ibuf_104[];
bool Gi_108;
int G_period_112 = 25;
double Gd_116 = 5.0;
double G_ibuf_124[];
double G_ibuf_128[];
double G_ibuf_132[];
double G_ibuf_136[];
double Gd_140;
double Gd_148;
double Gd_156;
double G_price_164;
double G_angle_172;
int G_datetime_180;
string G_dbl2str_184;
string G_dbl2str_192;
string G_fontname_200;
string G_text_208;
int Gi_216;
int Gi_220;
int Gi_224;
int G_fontsize_228;
int G_angle_232;
double G_angle_236;
string G_text_244;
string G_text_252;
string Gsa_260[];
string Gsa_unused_264[];
color G_color_268;
int Gi_272 = 1;
int Gi_276 = 0;
int G_y_280 = 0;
int Gi_unused_284 = 62;
int Gi_unused_288 = 27;
bool Gi_292 = FALSE;
int G_window_296 = 0;
bool Gi_300 = FALSE;
bool Gi_unused_304 = FALSE;
string Gs_308 = "";
bool Gi_316 = TRUE;
color G_color_320 = C'0xA0,0xA0,0xA0';
int Gi_unused_324 = 5589835;
int Gi_unused_328 = 0;
int Gi_332 = 0;
color G_color_336 = C'0x0F,0x0F,0x21';
int Gi_unused_340 = 4534320;
int Gi_unused_344 = 3088673;
int Gi_unused_348 = 0;
string Gs_unused_352 = "";
double G_timeframe_360;
string Gs_unused_368 = "=== Moving Average Settings ===";
int G_period_376 = 3;
int G_period_380 = 7;
int G_period_384 = 20;
int G_period_388 = 50;
int G_period_392 = 90;
int G_period_396 = 150;
int G_ma_method_400 = MODE_SMA;
int G_ma_method_404 = MODE_EMA;
int G_ma_method_408 = MODE_SMMA;
int G_applied_price_412 = PRICE_CLOSE;
string Gs_unused_416 = "=== CCI Settings ===";
int G_period_424 = 14;
string Gs_unused_428 = "=== MACD Settings ===";
int G_period_436 = 12;
int G_period_440 = 26;
int G_period_444 = 9;
string Gs_unused_448 = "=== BULLS BEARS Settings ===";
int G_period_456 = 13;
string Gs_unused_460 = "=== STOCHASTIC Settings ===";
int G_period_468 = 5;
int G_period_472 = 3;
int G_slowing_476 = 3;
int G_timeframe_480;
int G_timeframe_484;
int G_timeframe_488;
int G_timeframe_492;
int G_timeframe_496;
int G_timeframe_500;
int G_timeframe_504;
int G_timeframe_508;
int G_timeframe_512;
string Gs_unused_516;
string Gs_unused_524;
int Gi_532;
string Gs_unused_536;
int Gi_544;
string Gs_unused_548;
int Gi_556;
string Gs_unused_560;
string Gs_unused_568;
int Gi_576;
double Gd_unused_580;
int Gi_unused_588;
int Gi_unused_592;
int Gi_unused_596;
int Gi_unused_600;
int Gi_unused_604;
int Gi_unused_608;
color G_color_612;
color G_color_616;
int Gi_unused_620;
int Gi_unused_624;
int Gi_unused_628;
int Gi_unused_632;
int Gi_unused_636;
int Gi_unused_640 = 3342110;
int G_color_644 = C'0x19,0xFF,0x2D';
int G_color_648 = C'0x14,0xFF,0x28';
int G_color_652 = C'0x0C,0xFF,0x20';
int G_color_656 = C'0x04,0xFF,0x18';
int G_color_660 = C'0x00,0xFF,0x14';
int G_color_664 = C'0x00,0xFA,0x14';
int G_color_668 = C'0x00,0xF0,0x14';
int G_color_672 = C'0x00,0xE6,0x14';
int G_color_676 = C'0x00,0xDC,0x14';
int G_color_680 = C'0x00,0xD1,0x14';
int G_color_684 = C'0x00,0xC6,0x14';
int G_color_688 = C'0x00,0xB7,0x14';
int G_color_692 = C'0x00,0xAC,0x14';
int G_color_696 = C'0x00,0x9F,0x14';
int G_color_700 = C'0x00,0x94,0x14';
int G_color_704 = C'0x00,0x87,0x14';
int G_color_708 = C'0x00,0x79,0x14';
int G_color_712 = C'0x00,0x6A,0x14';
int G_color_716 = C'0x00,0x5E,0x14';
int G_color_720 = C'0x00,0x55,0x14';
int G_color_724 = C'0x00,0x50,0x14';
int G_color_728 = C'0x00,0x4D,0x14';
int G_color_732 = C'0x00,0x4B,0x14';
bool G_color_736 = 5588550;
int G_color_740 = C'0x23,0x5F,0xEB';
int Gi_unused_744 = 15425315;
int G_color_748 = C'0x23,0x5F,0xEB';
int G_color_752 = C'0x23,0x5F,0xEB';
int Gi_756 = 15425315;
int G_color_760 = C'0xFF,0x0B,0x00';
int G_color_764 = C'0xFF,0x09,0x00';
int G_color_768 = C'0xFF,0x06,0x00';
int G_color_772 = C'0xFF,0x02,0x00';
int G_color_776 = C'0xFD,0x00,0x14';
int G_color_780 = C'0xFA,0x00,0x14';
int G_color_784 = C'0xF8,0x00,0x14';
int G_color_788 = C'0xF4,0x00,0x14';
int G_color_792 = C'0xF0,0x00,0x14';
int G_color_796 = C'0xEB,0x00,0x14';
int G_color_800 = C'0xE6,0x00,0x14';
int G_color_804 = C'0xE1,0x00,0x14';
int G_color_808 = C'0xDD,0x00,0x14';
int G_color_812 = C'0xD9,0x00,0x14';
int G_color_816 = C'0xD5,0x00,0x00';
int G_color_820 = C'0xD1,0x00,0x00';
int G_color_824 = C'0xCD,0x00,0x00';
int G_color_828 = C'0xC8,0x00,0x00';
int G_color_832 = C'0xC3,0x00,0x00';
int G_color_836 = C'0xBE,0x00,0x00';
int G_color_840 = C'0xB9,0x00,0x00';
int G_color_844 = C'0xB4,0x00,0x00';
int G_color_848 = C'0xAF,0x00,0x00';
int G_color_852 = C'0xAA,0x00,0x00';
int G_color_856 = C'0x07,0x07,0x10';
int G_color_860 = C'0x0A,0x0A,0x14';
int G_color_864 = C'0x11,0x11,0x1B';
int G_color_868 = C'0x19,0x19,0x23';
int G_color_872 = C'0x20,0x20,0x2A';
int G_color_876 = C'0x27,0x27,0x31';
int G_color_880 = C'0x2E,0x2E,0x3C';
int G_color_884 = C'0x35,0x35,0x3F';
int G_color_888 = C'0x3C,0x3C,0x46';
int G_color_892 = C'0x43,0x43,0x4D';
int G_color_896 = C'0x4A,0x4A,0x54';
int G_color_900 = C'0x51,0x51,0x5B';
int G_color_904 = C'0x58,0x58,0x62';
int G_color_908 = C'0x5F,0x5F,0x69';
int G_color_912 = C'0x66,0x66,0x70';
int G_color_916 = C'0x6D,0x6D,0x77';
int G_color_920 = C'0x73,0x73,0x7D';
int G_color_924 = C'0x78,0x78,0x82';
int G_color_928 = C'0x7C,0x7C,0x86';
int G_color_932 = C'0x80,0x80,0x8A';
int G_color_936 = C'0x84,0x84,0x8E';
int G_color_940 = C'0x88,0x88,0x92';
int G_color_944 = C'0x8C,0x8C,0x96';
int Gi_unused_948 = 10129552;
int Gi_952;
int Gi_956;
string Gs_unused_960;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   Gs_84 = "NO";
   SetIndexBuffer(0, G_ibuf_92);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexLabel(0, "Trend Up");
   SetIndexBuffer(1, G_ibuf_96);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexLabel(1, "Trend Down");
   SetIndexBuffer(2, G_ibuf_100);
   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexLabel(2, "Trend Up Low");
   SetIndexBuffer(3, G_ibuf_104);
   SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexLabel(3, "Trend Up High");
   SetIndexBuffer(4, G_ibuf_124);
   SetIndexStyle(4, DRAW_HISTOGRAM, STYLE_SOLID, 0, C'0x01,0x80,0x00');
   SetIndexBuffer(5, G_ibuf_128);
   SetIndexStyle(5, DRAW_HISTOGRAM, STYLE_SOLID, 0, Maroon);
   SetIndexBuffer(6, G_ibuf_132);
   SetIndexStyle(6, DRAW_HISTOGRAM, STYLE_SOLID, 0, Maroon);
   SetIndexBuffer(7, G_ibuf_136);
   SetIndexStyle(7, DRAW_HISTOGRAM, STYLE_SOLID, 0, Maroon);
   if (Gi_316) {
      Gi_unused_640 = 15763806;
      G_color_644 = C'0x50,0x80,0xEF';
      G_color_648 = C'0x4B,0x7C,0xEF';
      G_color_652 = C'0x46,0x78,0xEE';
      G_color_656 = C'0x43,0x76,0xED';
      G_color_660 = C'0x40,0x74,0xED';
      G_color_664 = C'0x3D,0x72,0xED';
      G_color_668 = C'0x3A,0x6B,0xED';
      G_color_672 = C'0x35,0x65,0xED';
      G_color_676 = C'0x30,0x5F,0xEC';
      G_color_680 = C'0x2B,0x59,0xE6';
      G_color_684 = C'0x26,0x53,0xD7';
      G_color_688 = C'0x21,0x4D,0xC8';
      G_color_692 = C'0x1C,0x48,0xB9';
      G_color_696 = C'0x18,0x43,0xAA';
      G_color_700 = C'0x14,0x3E,0x9B';
      G_color_704 = C'0x10,0x39,0x8D';
      G_color_708 = C'0x0D,0x34,0x7F';
      G_color_712 = C'0x0B,0x2F,0x67';
      G_color_716 = C'0x0A,0x2A,0x59';
      G_color_720 = C'0x09,0x25,0x4B';
      G_color_724 = C'0x08,0x20,0x41';
      G_color_728 = C'0x07,0x1A,0x37';
      G_color_732 = C'0x06,0x13,0x2A';
      G_color_736 = Black;
      G_color_740 = C'0x23,0x5F,0xEB';
      Gi_unused_744 = 10526880;
      G_color_748 = C'0xAA,0xAA,0xAA';
      Gi_756 = 15425315;
   }
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   string Ls_unused_0;
   ObjectsDeleteAll();
   f0_0();
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   bool Li_0;
   bool Li_4;
   int Lia_8[5000];
   double Lda_12[5000];
   double Lda_16[5000];
   double Ld_20;
   double iatr_28;
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
   double Ld_316;
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
   string Ls_unused_2276;
   string Ls_unused_2284;
   string Ls_unused_2292;
   string Ls_unused_2300;
   string Ls_unused_2308;
   string Ls_unused_2316;
   string Ls_unused_2324;
   string Ls_unused_2332;
   string Ls_unused_2340;
   color color_2348;
   color color_2352;
   color color_2356;
   color color_2360;
   color color_2364;
   color color_2368;
   color color_2372;
   color color_2376;
   color color_2380;
   color color_2384;
   color color_2388;
   color color_2392;
   color color_2396;
   color color_2400;
   color color_2404;
   color color_2408;
   color color_2412;
   color color_2416;
   color color_2420;
   color color_2424;
   color color_2428;
   color color_2432;
   color color_2436;
   color color_2440;
   color color_2444;
   color color_2448;
   color color_2452;
   color color_2456;
   color color_2460;
   color color_2464;
   color color_2468;
   color color_2472;
   color color_2476;
   color color_2480;
   color color_2484;
   color color_2488;
   color color_2492;
   color color_2496;
   color color_2500;
   color color_2504;
   color color_2508;
   color color_2512;
   color color_2516;
   color color_2520;
   color color_2524;
   color color_2528;
   color color_2532;
   color color_2536;
   color color_2540;
   color color_2544;
   color color_2548;
   int Li_unused_2552;
   int Li_unused_2556;
   int corner_2560;
   int Li_2564;
   int Li_2568;
   int Li_2572;
   int Li_2576;
   int Li_unused_2580;
   int Li_unused_2584;
   int Li_2588;
   int Li_2592;
   int Li_unused_2596;
   int Li_unused_2600;
   int Li_unused_2604;
   int Li_unused_2608;
   int Li_unused_2612;
   int Li_unused_2616;
   int Li_unused_2620;
   int Li_unused_2624;
   int Li_unused_2628;
   int Li_unused_2632;
   int angle_2636;
   int Li_unused_2640;
   int Li_unused_2644;
   string Ls_2648;
   string dbl2str_2656;
   double ima_2664;
   double ima_2672;
   double ima_2680;
   double ima_2688;
   double ima_2696;
   double ima_2704;
   double ima_2712;
   double ima_2720;
   double ima_2728;
   double ima_2736;
   double ima_2744;
   double ima_2752;
   double ima_2760;
   double ima_2768;
   double ima_2776;
   double ima_2784;
   double ima_2792;
   double ima_2800;
   double ima_2808;
   double ima_2816;
   double ima_2824;
   double ima_2832;
   double ima_2840;
   double ima_2848;
   double ima_2856;
   double ima_2864;
   double ima_2872;
   double ima_2880;
   double ima_2888;
   double ima_2896;
   double ima_2904;
   double ima_2912;
   double ima_2920;
   double ima_2928;
   double ima_2936;
   double ima_2944;
   double ima_2952;
   double ima_2960;
   double ima_2968;
   double ima_2976;
   double ima_2984;
   double ima_2992;
   double ima_3000;
   double ima_3008;
   double ima_3016;
   double ima_3024;
   double ima_3032;
   double ima_3040;
   double ima_3048;
   double ima_3056;
   double ima_3064;
   double ima_3072;
   double ima_3080;
   double ima_3088;
   double ima_3096;
   double ima_3104;
   double ima_3112;
   double ima_3120;
   double ima_3128;
   double ima_3136;
   double ima_3144;
   double ima_3152;
   double ima_3160;
   double ima_3168;
   double ima_3176;
   double ima_3184;
   double ima_3192;
   double ima_3200;
   double ima_3208;
   double ima_3216;
   double icci_3224;
   double icci_3232;
   double icci_3240;
   double icci_3248;
   double icci_3256;
   double icci_3264;
   double icci_3272;
   double imacd_3280;
   double imacd_3288;
   double imacd_3296;
   double imacd_3304;
   double imacd_3312;
   double imacd_3320;
   double imacd_3328;
   double imacd_3336;
   double imacd_3344;
   double imacd_3352;
   double imacd_3360;
   double imacd_3368;
   double imacd_3376;
   double imacd_3384;
   double iadx_3392;
   double iadx_3400;
   double iadx_3408;
   double iadx_3416;
   double iadx_3424;
   double iadx_3432;
   double iadx_3440;
   double iadx_3448;
   double iadx_3456;
   double iadx_3464;
   double iadx_3472;
   double iadx_3480;
   double iadx_3488;
   double iadx_3496;
   double ibullspower_3504;
   double ibullspower_3512;
   double ibullspower_3520;
   double ibullspower_3528;
   double ibullspower_3536;
   double ibullspower_3544;
   double ibullspower_3552;
   double ibearspower_3560;
   double ibearspower_3568;
   double ibearspower_3576;
   double ibearspower_3584;
   double ibearspower_3592;
   double ibearspower_3600;
   double ibearspower_3608;
   double istochastic_3616;
   double istochastic_3624;
   double istochastic_3632;
   double istochastic_3640;
   double istochastic_3648;
   double istochastic_3656;
   double istochastic_3664;
   double istochastic_3672;
   double istochastic_3680;
   double istochastic_3688;
   double istochastic_3696;
   double istochastic_3704;
   double istochastic_3712;
   double istochastic_3720;
   double irsi_3728;
   double irsi_3736;
   double irsi_3744;
   double irsi_3752;
   double irsi_3760;
   double irsi_3768;
   double irsi_3776;
   double iobv_3784;
   double iobv_3792;
   double iobv_3800;
   double iobv_3808;
   double iobv_3816;
   double iobv_3824;
   double iobv_3832;
   double iobv_3840;
   double iobv_3848;
   double iobv_3856;
   double iobv_3864;
   double iobv_3872;
   double iobv_3880;
   double iobv_3888;
   double iforce_3896;
   double iforce_3904;
   double iforce_3912;
   double iforce_3920;
   double iforce_3928;
   double iforce_3936;
   double iforce_3944;
   double imomentum_3952;
   double imomentum_3960;
   double imomentum_3968;
   double imomentum_3976;
   double imomentum_3984;
   double imomentum_3992;
   double imomentum_4000;
   double idemarker_4008;
   double idemarker_4016;
   double idemarker_4024;
   double idemarker_4032;
   double idemarker_4040;
   double idemarker_4048;
   double idemarker_4056;
   double iac_4064;
   double iac_4072;
   double iac_4080;
   double iac_4088;
   double iac_4096;
   double iac_4104;
   double iac_4112;
   double iwpr_4120;
   double iwpr_4128;
   double iwpr_4136;
   double iwpr_4144;
   double iwpr_4152;
   double iwpr_4160;
   double iwpr_4168;
   double iosma_4176;
   double iosma_4184;
   double iosma_4192;
   double iosma_4200;
   double iosma_4208;
   double iosma_4216;
   double iosma_4224;
   double isar_4232;
   double isar_4240;
   double isar_4248;
   double isar_4256;
   double isar_4264;
   double isar_4272;
   double isar_4280;
   double Ld_4288;
   double Ld_4296;
   double Ld_4304;
   double Ld_4312;
   double Ld_4320;
   double Ld_4328;
   double Ld_4336;
   double Ld_4344;
   double Ld_4352;
   double Ld_4360;
   double Ld_4368;
   double Ld_4376;
   double Ld_4384;
   double Ld_4392;
   double Ld_4400;
   double Ld_4408;
   double Ld_4416;
   double Ld_4424;
   string symbol_4432;
   string dbl2str_4440;
   string dbl2str_4448;
   string dbl2str_4456;
   string dbl2str_4464;
   string dbl2str_4472;
   string dbl2str_4480;
   double Ld_4488;
   double idemarker_4496;
   double idemarker_4504;
   double imfi_4512;
   double irvi_4520;
   double irvi_4528;
   double iao_4536;
   double iao_4544;
   int Li_4552;
   double Ld_4556;
   string Ls_4564;
   if (Gs_84 == "YES") return (0);
   ObjectCreate("50Alimeter", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("50Alimeter", " ", 1, "Arial Black", Black);
   ObjectSet("50Alimeter", OBJPROP_CORNER, 0);
   ObjectSet("50Alimeter", OBJPROP_XDISTANCE, Gi_276 - 50);
   ObjectSet("50Alimeter", OBJPROP_YDISTANCE, G_y_280);
   ObjectSet("50Alimeter", OBJPROP_ANGLE, 0);
   int Li_4572 = IndicatorCounted();
   if (Li_4572 < 0) return (-1);
   if (Li_4572 > 0) Li_4572--;
   int Li_4576 = Bars - Li_4572;
   for (int bars_4580 = Bars; bars_4580 >= 0; bars_4580--) {
      G_ibuf_92[bars_4580] = EMPTY_VALUE;
      G_ibuf_96[bars_4580] = EMPTY_VALUE;
      iatr_28 = iATR(NULL, 0, G_period_112, bars_4580);
      Ld_20 = (High[bars_4580] + Low[bars_4580]) / 2.0;
      Lda_12[bars_4580] = Ld_20 + Gd_116 * iatr_28;
      Lda_16[bars_4580] = Ld_20 - Gd_116 * iatr_28;
      Lia_8[bars_4580] = 1;
      if (Close[bars_4580 + 1] > Lda_12[bars_4580 + 1]) {
         Lia_8[bars_4580] = 1;
         if (Lia_8[bars_4580 + 1] == -1) Gi_108 = TRUE;
      } else {
         if (Close[bars_4580 + 1] < Lda_16[bars_4580 + 1]) {
            Lia_8[bars_4580] = -1;
            if (Lia_8[bars_4580 + 1] == 1) Gi_108 = TRUE;
         } else {
            if (Lia_8[bars_4580 + 1] == 1) {
               Lia_8[bars_4580] = 1;
               Gi_108 = FALSE;
            } else {
               if (Lia_8[bars_4580 + 1] == -1) {
                  Lia_8[bars_4580] = -1;
                  Gi_108 = FALSE;
               }
            }
         }
      }
      if (Lia_8[bars_4580] < 0 && Lia_8[bars_4580 + 1] > 0) Li_0 = TRUE;
      else Li_0 = FALSE;
      if (Lia_8[bars_4580] > 0 && Lia_8[bars_4580 + 1] < 0) Li_4 = TRUE;
      else Li_4 = FALSE;
      if (Lia_8[bars_4580] > 0 && Lda_16[bars_4580] < Lda_16[bars_4580 + 1]) Lda_16[bars_4580] = Lda_16[bars_4580 + 1];
      if (Lia_8[bars_4580] < 0 && Lda_12[bars_4580] > Lda_12[bars_4580 + 1]) Lda_12[bars_4580] = Lda_12[bars_4580 + 1];
      if (Li_0 == TRUE) Lda_12[bars_4580] = Ld_20 + Gd_116 * iatr_28;
      if (Li_4 == TRUE) Lda_16[bars_4580] = Ld_20 - Gd_116 * iatr_28;
      if (Lia_8[bars_4580] == 1) {
         G_ibuf_92[bars_4580] = Lda_16[bars_4580];
         G_ibuf_100[bars_4580] = Lda_16[bars_4580] + 25.0 * Gd_148 / 100.0;
         if (Gi_108 == TRUE) {
            G_ibuf_92[bars_4580 + 1] = G_ibuf_96[bars_4580 + 1];
            G_ibuf_100[bars_4580 + 1] = G_ibuf_96[bars_4580 + 1];
            Gi_108 = FALSE;
            if (ObjectDescription("50Alimeter") != "BUY") {
               ObjectSetText("50Alimeter", "BUY", 1, "Arial Black", Black);
               Gd_140 = Open[bars_4580];
               G_datetime_180 = iTime(Symbol(), Period(), bars_4580);
               Gd_148 = Gd_140 - Lda_16[bars_4580];
               G_price_164 = Lda_16[bars_4580];
            }
            G_angle_172 = Lda_16[0];
            G_dbl2str_184 = DoubleToStr(Close[0] - Gd_140, MarketInfo(Symbol(), MODE_DIGITS));
            G_dbl2str_192 = DoubleToStr(G_ibuf_92[0], MarketInfo(Symbol(), MODE_DIGITS));
         }
      } else {
         if (Lia_8[bars_4580] == -1) {
            G_ibuf_96[bars_4580] = Lda_12[bars_4580];
            G_ibuf_104[bars_4580] = Lda_12[bars_4580] - 25.0 * Gd_148 / 100.0;
            if (Gi_108 == TRUE) {
               G_ibuf_96[bars_4580 + 1] = G_ibuf_92[bars_4580 + 1];
               G_ibuf_104[bars_4580 + 1] = G_ibuf_92[bars_4580 + 1];
               Gi_108 = FALSE;
               if (ObjectDescription("50Alimeter") != "SELL") {
                  ObjectSetText("50Alimeter", "SELL", 1, "Arial Black", Black);
                  Gd_140 = Open[bars_4580];
                  G_datetime_180 = iTime(Symbol(), Period(), bars_4580);
                  Gd_148 = Lda_12[bars_4580] - Gd_140;
                  G_price_164 = Lda_12[bars_4580];
               }
               G_dbl2str_184 = DoubleToStr(Gd_140 - Close[0], MarketInfo(Symbol(), MODE_DIGITS));
               G_dbl2str_192 = DoubleToStr(G_ibuf_96[0], MarketInfo(Symbol(), MODE_DIGITS));
               G_angle_172 = Lda_12[0];
            }
         }
      }
   }
   for (bars_4580 = 0; bars_4580 < 4; bars_4580++) {
      if (bars_4580 == 1 || bars_4580 == 2) ObjectCreate("*****TrendTop" + bars_4580, OBJ_RECTANGLE, 0, G_datetime_180, G_price_164, TimeCurrent(), G_price_164);
      else ObjectCreate("*****TrendTop" + bars_4580, OBJ_TREND, 0, G_datetime_180, G_price_164, TimeCurrent(), G_price_164);
      if (bars_4580 == 0) {
         for (int count_4584 = 0; count_4584 < 7; count_4584++) {
            if (count_4584 == 0) {
               Gi_216 = 6;
               G_angle_236 = 65535;
            }
            if (count_4584 == 1) {
               Gi_216 = 8;
               G_angle_236 = 3;
            }
            if (count_4584 == 2) {
               Gi_216 = 0;
               G_angle_236 = G_datetime_180;
            }
            if (count_4584 == 3) {
               Gi_216 = 1;
               G_angle_236 = Gd_140;
            }
            if (count_4584 == 4) {
               Gi_216 = 2;
               G_angle_236 = TimeCurrent() + 50000 * Period();
            }
            if (count_4584 == 5) {
               Gi_216 = 3;
               G_angle_236 = Gd_140;
            }
            if (count_4584 == 6) {
               Gi_216 = 10;
               G_angle_236 = 1;
            }
            ObjectSet("*****TrendTop" + bars_4580, Gi_216, G_angle_236);
         }
      }
      if (bars_4580 == 1) {
         for (count_4584 = 0; count_4584 < 7; count_4584++) {
            if (count_4584 == 0) {
               if (ObjectDescription("50Alimeter") == "SELL") {
                  Gi_216 = 6;
                  G_angle_236 = 128;
               }
               if (ObjectDescription("50Alimeter") == "BUY") {
                  Gi_216 = 6;
                  G_angle_236 = 16384;
               }
            }
            if (count_4584 == 1) {
               Gi_216 = 8;
               G_angle_236 = 5;
            }
            if (count_4584 == 2) {
               Gi_216 = 0;
               G_angle_236 = G_datetime_180;
            }
            if (count_4584 == 3) {
               Gi_216 = 1;
               G_angle_236 = G_angle_172;
            }
            if (count_4584 == 4) {
               Gi_216 = 2;
               G_angle_236 = TimeCurrent() + 50000 * Period();
            }
            if (count_4584 == 5) {
               Gi_216 = 3;
               if (ObjectDescription("50Alimeter") == "SELL") G_angle_236 = Lda_12[0] - 25.0 * Gd_148 / 100.0;
               if (ObjectDescription("50Alimeter") == "BUY") G_angle_236 = Lda_16[0] + 25.0 * Gd_148 / 100.0;
            }
            if (count_4584 == 6) {
               Gi_216 = 9;
               G_angle_236 = 1;
            }
            ObjectSet("*****TrendTop" + bars_4580, Gi_216, G_angle_236);
         }
      }
      if (bars_4580 == 2) {
         for (count_4584 = 0; count_4584 < 7; count_4584++) {
            if (count_4584 == 0) {
               if (ObjectDescription("50Alimeter") == "SELL") {
                  Gi_216 = 6;
                  G_angle_236 = 255;
               }
               if (ObjectDescription("50Alimeter") == "BUY") {
                  Gi_216 = 6;
                  G_angle_236 = 32768;
               }
            }
            if (count_4584 == 1) {
               Gi_216 = 8;
               G_angle_236 = 5;
            }
            if (count_4584 == 2) {
               Gi_216 = 0;
               G_angle_236 = G_datetime_180;
            }
            if (count_4584 == 3) {
               Gi_216 = 1;
               G_angle_236 = G_angle_172;
            }
            if (count_4584 == 4) {
               Gi_216 = 2;
               G_angle_236 = TimeCurrent() + 50000 * Period();
            }
            if (count_4584 == 5) {
               Gi_216 = 3;
               if (ObjectDescription("50Alimeter") == "SELL") G_angle_236 = Lda_12[0] - 25.0 * Gd_148 / 100.0;
               if (ObjectDescription("50Alimeter") == "BUY") G_angle_236 = Lda_16[0] + 25.0 * Gd_148 / 100.0;
            }
            if (count_4584 == 6) {
               Gi_216 = 9;
               G_angle_236 = 0;
            }
            ObjectSet("*****TrendTop" + bars_4580, Gi_216, G_angle_236);
         }
      }
      if (bars_4580 == 3) {
         for (count_4584 = 0; count_4584 < 7; count_4584++) {
            if (count_4584 == 0) {
               Gi_216 = 6;
               G_angle_236 = 16711680;
            }
            if (count_4584 == 1) {
               Gi_216 = 8;
               G_angle_236 = 5;
            }
            if (count_4584 == 2) {
               Gi_216 = 0;
               G_angle_236 = G_datetime_180;
            }
            if (count_4584 == 3) {
               Gi_216 = 10;
               G_angle_236 = 1;
            }
            if (count_4584 == 4) {
               Gi_216 = 2;
               G_angle_236 = TimeCurrent() + 50000 * Period();
               ObjectCreate("*****Target", OBJ_TEXT, 0, G_datetime_180, 0);
               ObjectSetText("*****Target", "Target", 8, "Arial Black", Blue);
            }
            if (count_4584 == 5) {
               if (ObjectDescription("50Alimeter") == "SELL") {
                  if (Gd_140 <= Lda_12[0] - 25.0 * Gd_148 / 100.0) {
                     Gi_216 = 1;
                     G_angle_236 = Gd_140 - Gd_148;
                     ObjectSet("*****Target", OBJPROP_TIME1, G_datetime_180);
                     ObjectSet("*****Target", OBJPROP_PRICE1, Gd_140 - Gd_148);
                     Gd_156 = Gd_140 - Gd_148;
                  }
                  if (Gd_140 > Lda_12[0] - 25.0 * Gd_148 / 100.0) {
                     Gi_216 = 1;
                     G_angle_236 = Lda_12[0] - 25.0 * Gd_148 / 100.0 - Gd_148;
                     ObjectSet("*****Target", OBJPROP_TIME1, G_datetime_180);
                     ObjectSet("*****Target", OBJPROP_PRICE1, Lda_12[0] - 25.0 * Gd_148 / 100.0 - Gd_148);
                     Gd_156 = Lda_12[0] - 25.0 * Gd_148 / 100.0 - Gd_148;
                  }
               }
               if (ObjectDescription("50Alimeter") == "BUY") {
                  if (Gd_140 >= Lda_16[0] + 25.0 * Gd_148 / 100.0) {
                     Gi_216 = 1;
                     G_angle_236 = Gd_140 + Gd_148;
                     ObjectSet("*****Target", OBJPROP_TIME1, G_datetime_180);
                     ObjectSet("*****Target", OBJPROP_PRICE1, Gd_140 + Gd_148);
                     Gd_156 = Gd_140 + Gd_148;
                  }
                  if (Gd_140 < Lda_16[0] + 25.0 * Gd_148 / 100.0) {
                     Gi_216 = 1;
                     G_angle_236 = Lda_16[0] + 25.0 * Gd_148 / 100.0 + Gd_148;
                     ObjectSet("*****Target", OBJPROP_TIME1, G_datetime_180);
                     ObjectSet("*****Target", OBJPROP_PRICE1, Lda_16[0] + 25.0 * Gd_148 / 100.0 + Gd_148);
                     Gd_156 = Lda_16[0] + 25.0 * Gd_148 / 100.0 + Gd_148;
                  }
               }
            }
            if (count_4584 == 6) {
               if (ObjectDescription("50Alimeter") == "SELL") {
                  if (Gd_140 <= Lda_12[0] - 25.0 * Gd_148 / 100.0) {
                     Gi_216 = 3;
                     G_angle_236 = Gd_140 - Gd_148;
                  }
                  if (Gd_140 > Lda_12[0] - 25.0 * Gd_148 / 100.0) {
                     Gi_216 = 3;
                     G_angle_236 = Lda_12[0] - 25.0 * Gd_148 / 100.0 - Gd_148;
                  }
               }
               if (ObjectDescription("50Alimeter") == "BUY") {
                  if (Gd_140 >= Lda_16[0] + 25.0 * Gd_148 / 100.0) {
                     Gi_216 = 3;
                     G_angle_236 = Gd_140 + Gd_148;
                  }
                  if (Gd_140 < Lda_16[0] + 25.0 * Gd_148 / 100.0) {
                     Gi_216 = 3;
                     G_angle_236 = Lda_16[0] + 25.0 * Gd_148 / 100.0 + Gd_148;
                  }
               }
            }
            ObjectSet("*****TrendTop" + bars_4580, Gi_216, G_angle_236);
         }
      }
   }
   ObjectCreate("*****TrendTop40", OBJ_TEXT, 0, G_datetime_180, 0);
   ObjectCreate("*****TrendTop41", OBJ_TEXT, 0, G_datetime_180, 0);
   for (count_4584 = 0; count_4584 < 2; count_4584++) {
      if (count_4584 == 0) {
         Gi_216 = G_datetime_180;
         G_angle_236 = Gd_140;
         if (ObjectDescription("50Alimeter") == "SELL") G_text_244 = "SELL Entry";
         if (ObjectDescription("50Alimeter") == "BUY") G_text_244 = "BUY Entry";
      }
      if (count_4584 == 1) {
         Gi_216 = TimeCurrent() + 2000 * Period();
         if (ObjectDescription("50Alimeter") == "SELL") {
            G_text_244 = "Safe SELL Entry";
            G_angle_236 = (Lda_12[0] - 25.0 * Gd_148 / 100.0 + G_angle_172) / 2.0;
         }
         if (ObjectDescription("50Alimeter") == "BUY") {
            G_angle_236 = (Lda_16[0] + 25.0 * Gd_148 / 100.0 + G_angle_172) / 2.0;
            G_text_244 = "Safe BUY Entry";
         }
      }
      ObjectSetText("*****TrendTop4" + count_4584, G_text_244, 8, "Arial Black", Yellow);
      ObjectSet("*****TrendTop4" + count_4584, OBJPROP_TIME1, Gi_216);
      ObjectSet("*****TrendTop4" + count_4584, OBJPROP_PRICE1, G_angle_236);
   }
   for (Gi_272 = 1; Gi_272 < 10; Gi_272++) {
      Li_unused_2556 = 30;
      corner_2560 = 0;
      Li_2564 = 95;
      Li_2568 = 52;
      Li_2572 = 141;
      Li_2576 = 48;
      Li_unused_2580 = 160;
      Li_unused_2584 = 45;
      Li_2588 = 91;
      Li_2592 = 7;
      Li_unused_2596 = 3;
      Li_unused_2600 = 91;
      Li_unused_2604 = 0;
      Li_unused_2608 = -5;
      Li_unused_2612 = 0;
      Li_unused_2616 = 0;
      Li_unused_2620 = 5;
      Li_unused_2624 = 5;
      Li_unused_2628 = 309;
      Li_unused_2632 = 0;
      angle_2636 = 0;
      Li_unused_2640 = 3;
      Li_unused_2644 = 0;
      f0_0();
      if (Gi_292 == TRUE) {
         corner_2560 = 4;
         Li_2564 = 78;
         Li_2568 = 107;
         Li_2572 = 124;
         Li_2576 = 107;
         Li_unused_2580 = 194;
         Li_unused_2584 = 46;
         Li_2588 = 227;
         Li_2592 = 153;
         Li_unused_2600 = 228;
         Li_unused_2596 = 156;
         Li_unused_2612 = 9;
         Li_unused_2616 = 5;
         Li_unused_2620 = 9;
         Li_unused_2624 = 8;
         Li_unused_2628 = 338;
         Li_unused_2632 = 4;
         angle_2636 = 180;
         Li_unused_2640 = 5;
         Li_unused_2644 = 6;
      }
      if (Gi_300 == FALSE) {
         Li_unused_2604 = -109;
         Li_unused_2608 = -114;
         Gs_unused_516 = "/////////";
      }
      if (Gi_300 == TRUE) Gs_unused_516 = "////////////";
      if (Gs_308 == "") Gs_308 = Symbol();
      Ls_2648 = StringSubstr(Gs_308, 0, 6);
      dbl2str_2656 = DoubleToStr(MarketInfo(Gs_308, MODE_BID), MarketInfo(Gs_308, MODE_DIGITS));
      if (Gi_272 == 1) G_timeframe_360 = 1.0;
      if (Gi_272 == 2) G_timeframe_360 = 5.0;
      if (Gi_272 == 3) G_timeframe_360 = 15.0;
      if (Gi_272 == 4) G_timeframe_360 = 30.0;
      if (Gi_272 == 5) G_timeframe_360 = 60.0;
      if (Gi_272 == 6) G_timeframe_360 = 240.0;
      if (Gi_272 == 7) G_timeframe_360 = 1440.0;
      if (Gi_272 == 8) G_timeframe_360 = 10080.0;
      if (Gi_272 == 9) G_timeframe_360 = 43200.0;
      if (G_timeframe_360 == 1.0) Gs_unused_352 = "M1";
      if (G_timeframe_360 == 5.0) Gs_unused_352 = "M5";
      if (G_timeframe_360 == 15.0) Gs_unused_352 = "M15";
      if (G_timeframe_360 == 30.0) Gs_unused_352 = "M30";
      if (G_timeframe_360 == 60.0) Gs_unused_352 = "H1";
      if (G_timeframe_360 == 240.0) Gs_unused_352 = "H4";
      if (G_timeframe_360 == 1440.0) Gs_unused_352 = "D1";
      if (G_timeframe_360 == 10080.0) Gs_unused_352 = "W1";
      if (G_timeframe_360 == 43200.0) Gs_unused_352 = "MN";
      if (G_timeframe_360 == 1.0) G_timeframe_480 = 15;
      if (G_timeframe_360 == 5.0) G_timeframe_480 = 30;
      if (G_timeframe_360 == 15.0) G_timeframe_480 = 60;
      if (G_timeframe_360 == 30.0) G_timeframe_480 = 60;
      if (G_timeframe_360 == 60.0) G_timeframe_480 = 240;
      if (G_timeframe_360 == 240.0) G_timeframe_480 = 240;
      if (G_timeframe_360 == 1440.0) G_timeframe_480 = 1440;
      if (G_timeframe_360 == 10080.0) G_timeframe_480 = 10080;
      if (G_timeframe_360 == 43200.0) G_timeframe_480 = 43200;
      if (G_timeframe_360 == 1.0) G_timeframe_484 = 5;
      if (G_timeframe_360 == 5.0) G_timeframe_484 = 15;
      if (G_timeframe_360 == 15.0) G_timeframe_484 = 30;
      if (G_timeframe_360 == 30.0) G_timeframe_484 = 60;
      if (G_timeframe_360 == 60.0) G_timeframe_484 = 240;
      if (G_timeframe_360 == 240.0) G_timeframe_484 = 240;
      if (G_timeframe_360 == 1440.0) G_timeframe_484 = 1440;
      if (G_timeframe_360 == 10080.0) G_timeframe_484 = 10080;
      if (G_timeframe_360 == 43200.0) G_timeframe_484 = 43200;
      if (G_timeframe_360 == 1.0) {
         G_timeframe_488 = 15;
         G_timeframe_492 = 5;
         G_timeframe_496 = 30;
         G_timeframe_500 = 60;
         G_timeframe_504 = 1;
         G_timeframe_508 = 30;
         G_timeframe_512 = 60;
      }
      if (G_timeframe_360 == 5.0) {
         G_timeframe_488 = 30;
         G_timeframe_492 = 15;
         G_timeframe_496 = 240;
         G_timeframe_500 = 60;
         G_timeframe_504 = 15;
         G_timeframe_508 = 60;
         G_timeframe_512 = 5;
      }
      if (G_timeframe_360 == 15.0) {
         G_timeframe_488 = 60;
         G_timeframe_492 = 15;
         G_timeframe_496 = 30;
         G_timeframe_500 = 240;
         G_timeframe_504 = 30;
         G_timeframe_508 = 1440;
         G_timeframe_512 = 5;
      }
      if (G_timeframe_360 == 30.0) {
         G_timeframe_488 = 60;
         G_timeframe_492 = 30;
         G_timeframe_496 = 240;
         G_timeframe_500 = 1440;
         G_timeframe_504 = 240;
         G_timeframe_508 = 30;
         G_timeframe_512 = 15;
      }
      if (G_timeframe_360 == 60.0) {
         G_timeframe_488 = 60;
         G_timeframe_492 = 240;
         G_timeframe_496 = 1440;
         G_timeframe_500 = 30;
         G_timeframe_504 = 1440;
         G_timeframe_508 = 240;
         G_timeframe_512 = 15;
      }
      if (G_timeframe_360 == 240.0) {
         G_timeframe_488 = 240;
         G_timeframe_492 = 1440;
         G_timeframe_496 = 1440;
         G_timeframe_500 = 60;
         G_timeframe_504 = 240;
         G_timeframe_508 = 10080;
         G_timeframe_512 = 30;
      }
      if (G_timeframe_360 == 1440.0) {
         G_timeframe_488 = 1440;
         G_timeframe_492 = 240;
         G_timeframe_496 = 10080;
         G_timeframe_500 = 240;
         G_timeframe_504 = 1440;
         G_timeframe_508 = 60;
         G_timeframe_512 = 10080;
      }
      if (G_timeframe_360 == 10080.0) {
         G_timeframe_488 = 10080;
         G_timeframe_492 = 10080;
         G_timeframe_496 = 10080;
         G_timeframe_500 = 1440;
         G_timeframe_504 = 1440;
         G_timeframe_508 = 1440;
         G_timeframe_512 = 240;
      }
      if (G_timeframe_360 == 43200.0) {
         G_timeframe_488 = 43200;
         G_timeframe_492 = 43200;
         G_timeframe_496 = 10080;
         G_timeframe_500 = 10080;
         G_timeframe_504 = 1440;
         G_timeframe_508 = 1440;
         G_timeframe_512 = 1440;
      }
      ima_2664 = iMA(Gs_308, G_timeframe_512, G_period_376, 0, G_ma_method_400, G_applied_price_412, 0);
      ima_2672 = iMA(Gs_308, G_timeframe_512, G_period_396, 0, G_ma_method_408, G_applied_price_412, 0);
      if (ima_2664 >= ima_2672) {
         Ld_1604 = 1;
         Ld_1660 = 0;
      }
      if (ima_2664 < ima_2672) {
         Ld_1604 = 0;
         Ld_1660 = 1;
      }
      ima_2680 = iMA(Gs_308, G_timeframe_508, G_period_376, 0, G_ma_method_400, G_applied_price_412, 0);
      ima_2688 = iMA(Gs_308, G_timeframe_508, G_period_396, 0, G_ma_method_408, G_applied_price_412, 0);
      if (ima_2680 >= ima_2688) {
         Ld_1612 = 1;
         Ld_1668 = 0;
      }
      if (ima_2680 < ima_2688) {
         Ld_1612 = 0;
         Ld_1668 = 1;
      }
      ima_2696 = iMA(Gs_308, G_timeframe_504, G_period_376, 0, G_ma_method_400, G_applied_price_412, 0);
      ima_2704 = iMA(Gs_308, G_timeframe_504, G_period_396, 0, G_ma_method_408, G_applied_price_412, 0);
      if (ima_2696 >= ima_2704) {
         Ld_1620 = 1;
         Ld_1676 = 0;
      }
      if (ima_2696 < ima_2704) {
         Ld_1620 = 0;
         Ld_1676 = 1;
      }
      ima_2712 = iMA(Gs_308, G_timeframe_500, G_period_376, 0, G_ma_method_400, G_applied_price_412, 0);
      ima_2720 = iMA(Gs_308, G_timeframe_500, G_period_396, 0, G_ma_method_408, G_applied_price_412, 0);
      if (ima_2712 >= ima_2720) {
         Ld_1628 = 2;
         Ld_1684 = 0;
      }
      if (ima_2712 < ima_2720) {
         Ld_1628 = 0;
         Ld_1684 = 2;
      }
      ima_2728 = iMA(Gs_308, G_timeframe_488, G_period_376, 0, G_ma_method_400, G_applied_price_412, 0);
      ima_2736 = iMA(Gs_308, G_timeframe_488, G_period_396, 0, G_ma_method_408, G_applied_price_412, 0);
      if (ima_2728 >= ima_2736) {
         Ld_1636 = 3;
         Ld_1692 = 0;
      }
      if (ima_2728 < ima_2736) {
         Ld_1636 = 0;
         Ld_1692 = 3;
      }
      ima_2744 = iMA(Gs_308, G_timeframe_492, G_period_376, 0, G_ma_method_400, G_applied_price_412, 0);
      ima_2752 = iMA(Gs_308, G_timeframe_492, G_period_396, 0, G_ma_method_408, G_applied_price_412, 0);
      if (ima_2744 >= ima_2752) {
         Ld_1644 = 2;
         Ld_1700 = 0;
      }
      if (ima_2744 < ima_2752) {
         Ld_1644 = 0;
         Ld_1700 = 2;
      }
      ima_2760 = iMA(Gs_308, G_timeframe_496, G_period_376, 0, G_ma_method_400, G_applied_price_412, 0);
      ima_2768 = iMA(Gs_308, G_timeframe_496, G_period_396, 0, G_ma_method_408, G_applied_price_412, 0);
      if (ima_2760 >= ima_2768) {
         Ld_1652 = 2;
         Ld_1708 = 0;
      }
      if (ima_2760 < ima_2768) {
         Ld_1652 = 0;
         Ld_1708 = 2;
      }
      ima_2776 = iMA(Gs_308, G_timeframe_512, G_period_380, 0, G_ma_method_400, G_applied_price_412, 0);
      ima_2784 = iMA(Gs_308, G_timeframe_512, G_period_380, 0, G_ma_method_400, G_applied_price_412, 1);
      if (ima_2776 >= ima_2784) {
         Ld_1492 = 1;
         Ld_1548 = 0;
      }
      if (ima_2776 < ima_2784) {
         Ld_1492 = 0;
         Ld_1548 = 1;
      }
      ima_2792 = iMA(Gs_308, G_timeframe_508, G_period_380, 0, G_ma_method_400, G_applied_price_412, 0);
      ima_2800 = iMA(Gs_308, G_timeframe_508, G_period_380, 0, G_ma_method_400, G_applied_price_412, 1);
      if (ima_2792 >= ima_2800) {
         Ld_1500 = 1;
         Ld_1556 = 0;
      }
      if (ima_2792 < ima_2800) {
         Ld_1500 = 0;
         Ld_1556 = 1;
      }
      ima_2808 = iMA(Gs_308, G_timeframe_504, G_period_380, 0, G_ma_method_400, G_applied_price_412, 0);
      ima_2816 = iMA(Gs_308, G_timeframe_504, G_period_380, 0, G_ma_method_400, G_applied_price_412, 1);
      if (ima_2808 >= ima_2816) {
         Ld_1508 = 1;
         Ld_1564 = 0;
      }
      if (ima_2808 < ima_2816) {
         Ld_1508 = 0;
         Ld_1564 = 1;
      }
      ima_2824 = iMA(Gs_308, G_timeframe_500, G_period_380, 0, G_ma_method_400, G_applied_price_412, 0);
      ima_2832 = iMA(Gs_308, G_timeframe_500, G_period_380, 0, G_ma_method_400, G_applied_price_412, 1);
      if (ima_2824 >= ima_2832) {
         Ld_1516 = 2;
         Ld_1572 = 0;
      }
      if (ima_2824 < ima_2832) {
         Ld_1516 = 0;
         Ld_1572 = 2;
      }
      ima_2840 = iMA(Gs_308, G_timeframe_488, G_period_380, 0, G_ma_method_400, G_applied_price_412, 0);
      ima_2848 = iMA(Gs_308, G_timeframe_488, G_period_380, 0, G_ma_method_400, G_applied_price_412, 1);
      if (ima_2840 >= ima_2848) {
         Ld_1524 = 3;
         Ld_1580 = 0;
      }
      if (ima_2840 < ima_2848) {
         Ld_1524 = 0;
         Ld_1580 = 3;
      }
      ima_2856 = iMA(Gs_308, G_timeframe_492, G_period_380, 0, G_ma_method_400, G_applied_price_412, 0);
      ima_2864 = iMA(Gs_308, G_timeframe_492, G_period_380, 0, G_ma_method_400, G_applied_price_412, 1);
      if (ima_2856 >= ima_2864) {
         Ld_1532 = 2;
         Ld_1588 = 0;
      }
      if (ima_2856 < ima_2864) {
         Ld_1532 = 0;
         Ld_1588 = 2;
      }
      ima_2872 = iMA(Gs_308, G_timeframe_496, G_period_380, 0, G_ma_method_400, G_applied_price_412, 0);
      ima_2880 = iMA(Gs_308, G_timeframe_496, G_period_380, 0, G_ma_method_400, G_applied_price_412, 1);
      if (ima_2872 >= ima_2880) {
         Ld_1540 = 2;
         Ld_1596 = 0;
      }
      if (ima_2872 < ima_2880) {
         Ld_1540 = 0;
         Ld_1596 = 2;
      }
      ima_2888 = iMA(Gs_308, G_timeframe_512, G_period_384, 0, G_ma_method_404, G_applied_price_412, 0);
      ima_2896 = iMA(Gs_308, G_timeframe_512, G_period_384, 0, G_ma_method_404, G_applied_price_412, 1);
      if (ima_2888 >= ima_2896) {
         Ld_36 = 1;
         Ld_484 = 0;
      }
      if (ima_2888 < ima_2896) {
         Ld_36 = 0;
         Ld_484 = 1;
      }
      ima_2904 = iMA(Gs_308, G_timeframe_508, G_period_384, 0, G_ma_method_404, G_applied_price_412, 0);
      ima_2912 = iMA(Gs_308, G_timeframe_508, G_period_384, 0, G_ma_method_404, G_applied_price_412, 1);
      if (ima_2904 >= ima_2912) {
         Ld_44 = 1;
         Ld_492 = 0;
      }
      if (ima_2904 < ima_2912) {
         Ld_44 = 0;
         Ld_492 = 1;
      }
      ima_2920 = iMA(Gs_308, G_timeframe_504, G_period_384, 0, G_ma_method_404, G_applied_price_412, 0);
      ima_2928 = iMA(Gs_308, G_timeframe_504, G_period_384, 0, G_ma_method_404, G_applied_price_412, 1);
      if (ima_2920 >= ima_2928) {
         Ld_52 = 1;
         Ld_500 = 0;
      }
      if (ima_2920 < ima_2928) {
         Ld_52 = 0;
         Ld_500 = 1;
      }
      ima_2936 = iMA(Gs_308, G_timeframe_500, G_period_384, 0, G_ma_method_404, G_applied_price_412, 0);
      ima_2944 = iMA(Gs_308, G_timeframe_500, G_period_384, 0, G_ma_method_404, G_applied_price_412, 1);
      if (ima_2936 >= ima_2944) {
         Ld_60 = 2;
         Ld_508 = 0;
      }
      if (ima_2936 < ima_2944) {
         Ld_60 = 0;
         Ld_508 = 2;
      }
      ima_2952 = iMA(Gs_308, G_timeframe_488, G_period_384, 0, G_ma_method_404, G_applied_price_412, 0);
      ima_2960 = iMA(Gs_308, G_timeframe_488, G_period_384, 0, G_ma_method_404, G_applied_price_412, 1);
      if (ima_2952 >= ima_2960) {
         Ld_68 = 3;
         Ld_516 = 0;
      }
      if (ima_2952 < ima_2960) {
         Ld_68 = 0;
         Ld_516 = 3;
      }
      ima_2968 = iMA(Gs_308, G_timeframe_492, G_period_384, 0, G_ma_method_404, G_applied_price_412, 0);
      ima_2976 = iMA(Gs_308, G_timeframe_492, G_period_384, 0, G_ma_method_404, G_applied_price_412, 1);
      if (ima_2968 >= ima_2976) {
         Ld_76 = 2;
         Ld_524 = 0;
      }
      if (ima_2968 < ima_2976) {
         Ld_76 = 0;
         Ld_524 = 2;
      }
      ima_2984 = iMA(Gs_308, G_timeframe_496, G_period_384, 0, G_ma_method_404, G_applied_price_412, 0);
      ima_2992 = iMA(Gs_308, G_timeframe_496, G_period_384, 0, G_ma_method_404, G_applied_price_412, 1);
      if (ima_2984 >= ima_2992) {
         Ld_84 = 2;
         Ld_532 = 0;
      }
      if (ima_2984 < ima_2992) {
         Ld_84 = 0;
         Ld_532 = 2;
      }
      ima_3000 = iMA(Gs_308, G_timeframe_512, G_period_388, 0, G_ma_method_404, G_applied_price_412, 0);
      ima_3008 = iMA(Gs_308, G_timeframe_512, G_period_388, 0, G_ma_method_404, G_applied_price_412, 1);
      if (ima_3000 >= ima_3008) {
         Ld_92 = 1;
         Ld_540 = 0;
      }
      if (ima_3000 < ima_3008) {
         Ld_92 = 0;
         Ld_540 = 1;
      }
      ima_3016 = iMA(Gs_308, G_timeframe_508, G_period_388, 0, G_ma_method_404, G_applied_price_412, 0);
      ima_3024 = iMA(Gs_308, G_timeframe_508, G_period_388, 0, G_ma_method_404, G_applied_price_412, 1);
      if (ima_3016 >= ima_3024) {
         Ld_100 = 1;
         Ld_548 = 0;
      }
      if (ima_3016 < ima_3024) {
         Ld_100 = 0;
         Ld_548 = 1;
      }
      ima_3032 = iMA(Gs_308, G_timeframe_504, G_period_388, 0, G_ma_method_404, G_applied_price_412, 0);
      ima_3040 = iMA(Gs_308, G_timeframe_504, G_period_388, 0, G_ma_method_404, G_applied_price_412, 1);
      if (ima_3032 >= ima_3040) {
         Ld_108 = 1;
         Ld_556 = 0;
      }
      if (ima_3032 < ima_3040) {
         Ld_108 = 0;
         Ld_556 = 1;
      }
      ima_3048 = iMA(Gs_308, G_timeframe_500, G_period_388, 0, G_ma_method_404, G_applied_price_412, 0);
      ima_3056 = iMA(Gs_308, G_timeframe_500, G_period_388, 0, G_ma_method_404, G_applied_price_412, 1);
      if (ima_3048 >= ima_3056) {
         Ld_116 = 2;
         Ld_564 = 0;
      }
      if (ima_3048 < ima_3056) {
         Ld_116 = 0;
         Ld_564 = 2;
      }
      ima_3064 = iMA(Gs_308, G_timeframe_488, G_period_388, 0, G_ma_method_404, G_applied_price_412, 0);
      ima_3072 = iMA(Gs_308, G_timeframe_488, G_period_388, 0, G_ma_method_404, G_applied_price_412, 1);
      if (ima_3064 >= ima_3072) {
         Ld_124 = 3;
         Ld_572 = 0;
      }
      if (ima_3064 < ima_3072) {
         Ld_124 = 0;
         Ld_572 = 3;
      }
      ima_3080 = iMA(Gs_308, G_timeframe_492, G_period_388, 0, G_ma_method_404, G_applied_price_412, 0);
      ima_3088 = iMA(Gs_308, G_timeframe_492, G_period_388, 0, G_ma_method_404, G_applied_price_412, 1);
      if (ima_3080 >= ima_3088) {
         Ld_132 = 2;
         Ld_580 = 0;
      }
      if (ima_3080 < ima_3088) {
         Ld_132 = 0;
         Ld_580 = 2;
      }
      ima_3096 = iMA(Gs_308, G_timeframe_496, G_period_388, 0, G_ma_method_404, G_applied_price_412, 0);
      ima_3104 = iMA(Gs_308, G_timeframe_496, G_period_388, 0, G_ma_method_404, G_applied_price_412, 1);
      if (ima_3096 >= ima_3104) {
         Ld_140 = 2;
         Ld_588 = 0;
      }
      if (ima_3096 < ima_3104) {
         Ld_140 = 0;
         Ld_588 = 2;
      }
      ima_3112 = iMA(Gs_308, G_timeframe_512, G_period_392, 0, G_ma_method_408, G_applied_price_412, 0);
      ima_3120 = iMA(Gs_308, G_timeframe_512, G_period_392, 0, G_ma_method_408, G_applied_price_412, 1);
      if (ima_3112 >= ima_3120) {
         Ld_148 = 1;
         Ld_596 = 0;
      }
      if (ima_3112 < ima_3120) {
         Ld_148 = 0;
         Ld_596 = 1;
      }
      ima_3128 = iMA(Gs_308, G_timeframe_508, G_period_392, 0, G_ma_method_408, G_applied_price_412, 0);
      ima_3136 = iMA(Gs_308, G_timeframe_508, G_period_392, 0, G_ma_method_408, G_applied_price_412, 1);
      if (ima_3128 >= ima_3136) {
         Ld_156 = 1;
         Ld_604 = 0;
      }
      if (ima_3128 < ima_3136) {
         Ld_156 = 0;
         Ld_604 = 1;
      }
      ima_3144 = iMA(Gs_308, G_timeframe_504, G_period_392, 0, G_ma_method_408, G_applied_price_412, 0);
      ima_3152 = iMA(Gs_308, G_timeframe_504, G_period_392, 0, G_ma_method_408, G_applied_price_412, 1);
      if (ima_3144 >= ima_3152) {
         Ld_164 = 1;
         Ld_612 = 0;
      }
      if (ima_3144 < ima_3152) {
         Ld_164 = 0;
         Ld_612 = 1;
      }
      ima_3160 = iMA(Gs_308, G_timeframe_500, G_period_392, 0, G_ma_method_408, G_applied_price_412, 0);
      ima_3168 = iMA(Gs_308, G_timeframe_500, G_period_392, 0, G_ma_method_408, G_applied_price_412, 1);
      if (ima_3160 >= ima_3168) {
         Ld_172 = 2;
         Ld_620 = 0;
      }
      if (ima_3160 < ima_3168) {
         Ld_172 = 0;
         Ld_620 = 2;
      }
      ima_3176 = iMA(Gs_308, G_timeframe_488, G_period_392, 0, G_ma_method_408, G_applied_price_412, 0);
      ima_3184 = iMA(Gs_308, G_timeframe_488, G_period_392, 0, G_ma_method_408, G_applied_price_412, 1);
      if (ima_3176 >= ima_3184) {
         Ld_180 = 3;
         Ld_628 = 0;
      }
      if (ima_3176 < ima_3184) {
         Ld_180 = 0;
         Ld_628 = 3;
      }
      ima_3192 = iMA(Gs_308, G_timeframe_492, G_period_392, 0, G_ma_method_408, G_applied_price_412, 0);
      ima_3200 = iMA(Gs_308, G_timeframe_492, G_period_392, 0, G_ma_method_408, G_applied_price_412, 1);
      if (ima_3192 >= ima_3200) {
         Ld_188 = 2;
         Ld_636 = 0;
      }
      if (ima_3192 < ima_3200) {
         Ld_188 = 0;
         Ld_636 = 2;
      }
      ima_3208 = iMA(Gs_308, G_timeframe_496, G_period_392, 0, G_ma_method_408, G_applied_price_412, 0);
      ima_3216 = iMA(Gs_308, G_timeframe_496, G_period_392, 0, G_ma_method_408, G_applied_price_412, 1);
      if (ima_3208 >= ima_3216) {
         Ld_196 = 2;
         Ld_644 = 0;
      }
      if (ima_3208 < ima_3216) {
         Ld_196 = 0;
         Ld_644 = 2;
      }
      icci_3224 = iCCI(Gs_308, G_timeframe_512, G_period_424, G_applied_price_412, 0);
      if (icci_3224 >= 0.0) {
         Ld_204 = 1;
         Ld_652 = 0;
      }
      if (icci_3224 < 0.0) {
         Ld_204 = 0;
         Ld_652 = 1;
      }
      icci_3232 = iCCI(Gs_308, G_timeframe_508, G_period_424, G_applied_price_412, 0);
      if (icci_3232 >= 0.0) {
         Ld_212 = 1;
         Ld_660 = 0;
      }
      if (icci_3232 < 0.0) {
         Ld_212 = 0;
         Ld_660 = 1;
      }
      icci_3240 = iCCI(Gs_308, G_timeframe_504, G_period_424, G_applied_price_412, 0);
      if (icci_3240 >= 0.0) {
         Ld_220 = 1;
         Ld_668 = 0;
      }
      if (icci_3240 < 0.0) {
         Ld_220 = 0;
         Ld_668 = 1;
      }
      icci_3248 = iCCI(Gs_308, G_timeframe_500, G_period_424, G_applied_price_412, 0);
      if (icci_3248 >= 0.0) {
         Ld_228 = 2;
         Ld_676 = 0;
      }
      if (icci_3248 < 0.0) {
         Ld_228 = 0;
         Ld_676 = 2;
      }
      icci_3256 = iCCI(Gs_308, G_timeframe_488, G_period_424, G_applied_price_412, 0);
      if (icci_3256 >= 0.0) {
         Ld_236 = 3;
         Ld_684 = 0;
      }
      if (icci_3256 < 0.0) {
         Ld_236 = 0;
         Ld_684 = 3;
      }
      icci_3264 = iCCI(Gs_308, G_timeframe_492, G_period_424, G_applied_price_412, 0);
      if (icci_3264 >= 0.0) {
         Ld_244 = 2;
         Ld_692 = 0;
      }
      if (icci_3264 < 0.0) {
         Ld_244 = 0;
         Ld_692 = 2;
      }
      icci_3272 = iCCI(Gs_308, G_timeframe_496, G_period_424, G_applied_price_412, 0);
      if (icci_3272 >= 0.0) {
         Ld_252 = 2;
         Ld_700 = 0;
      }
      if (icci_3272 < 0.0) {
         Ld_252 = 0;
         Ld_700 = 2;
      }
      imacd_3280 = iMACD(Gs_308, G_timeframe_512, G_period_436, G_period_440, G_period_444, PRICE_CLOSE, MODE_MAIN, 0);
      imacd_3288 = iMACD(Gs_308, G_timeframe_512, G_period_436, G_period_440, G_period_444, PRICE_CLOSE, MODE_SIGNAL, 0);
      if (imacd_3280 >= imacd_3288) {
         Ld_260 = 1;
         Ld_708 = 0;
      }
      if (imacd_3280 < imacd_3288) {
         Ld_260 = 0;
         Ld_708 = 1;
      }
      imacd_3296 = iMACD(Gs_308, G_timeframe_508, G_period_436, G_period_440, G_period_444, PRICE_CLOSE, MODE_MAIN, 0);
      imacd_3304 = iMACD(Gs_308, G_timeframe_508, G_period_436, G_period_440, G_period_444, PRICE_CLOSE, MODE_SIGNAL, 0);
      if (imacd_3296 >= imacd_3304) {
         Ld_268 = 1;
         Ld_716 = 0;
      }
      if (imacd_3296 < imacd_3304) {
         Ld_268 = 0;
         Ld_716 = 1;
      }
      imacd_3312 = iMACD(Gs_308, G_timeframe_504, G_period_436, G_period_440, G_period_444, PRICE_CLOSE, MODE_MAIN, 0);
      imacd_3320 = iMACD(Gs_308, G_timeframe_504, G_period_436, G_period_440, G_period_444, PRICE_CLOSE, MODE_SIGNAL, 0);
      if (imacd_3312 >= imacd_3320) {
         Ld_276 = 1;
         Ld_724 = 0;
      }
      if (imacd_3312 < imacd_3320) {
         Ld_276 = 0;
         Ld_724 = 1;
      }
      imacd_3328 = iMACD(Gs_308, G_timeframe_500, G_period_436, G_period_440, G_period_444, PRICE_CLOSE, MODE_MAIN, 0);
      imacd_3336 = iMACD(Gs_308, G_timeframe_500, G_period_436, G_period_440, G_period_444, PRICE_CLOSE, MODE_SIGNAL, 0);
      if (imacd_3328 >= imacd_3336) {
         Ld_284 = 2;
         Ld_732 = 0;
      }
      if (imacd_3328 < imacd_3336) {
         Ld_284 = 0;
         Ld_732 = 2;
      }
      imacd_3344 = iMACD(Gs_308, G_timeframe_488, G_period_436, G_period_440, G_period_444, PRICE_CLOSE, MODE_MAIN, 0);
      imacd_3352 = iMACD(Gs_308, G_timeframe_488, G_period_436, G_period_440, G_period_444, PRICE_CLOSE, MODE_SIGNAL, 0);
      if (imacd_3344 >= imacd_3352) {
         Ld_292 = 3;
         Ld_740 = 0;
      }
      if (imacd_3344 < imacd_3352) {
         Ld_292 = 0;
         Ld_740 = 3;
      }
      imacd_3360 = iMACD(Gs_308, G_timeframe_492, G_period_436, G_period_440, G_period_444, PRICE_CLOSE, MODE_MAIN, 0);
      imacd_3368 = iMACD(Gs_308, G_timeframe_492, G_period_436, G_period_440, G_period_444, PRICE_CLOSE, MODE_SIGNAL, 0);
      if (imacd_3360 >= imacd_3368) {
         Ld_300 = 2;
         Ld_748 = 0;
      }
      if (imacd_3360 < imacd_3368) {
         Ld_300 = 0;
         Ld_748 = 2;
      }
      imacd_3376 = iMACD(Gs_308, G_timeframe_496, G_period_436, G_period_440, G_period_444, PRICE_CLOSE, MODE_MAIN, 0);
      imacd_3384 = iMACD(Gs_308, G_timeframe_496, G_period_436, G_period_440, G_period_444, PRICE_CLOSE, MODE_SIGNAL, 0);
      if (imacd_3376 >= imacd_3384) {
         Ld_308 = 2;
         Ld_756 = 0;
      }
      if (imacd_3376 < imacd_3384) {
         Ld_308 = 0;
         Ld_756 = 2;
      }
      iadx_3392 = iADX(Gs_308, G_timeframe_512, G_period_424, G_applied_price_412, MODE_PLUSDI, 0);
      iadx_3400 = iADX(Gs_308, G_timeframe_512, G_period_424, G_applied_price_412, MODE_MINUSDI, 0);
      if (iadx_3392 >= iadx_3400) {
         Ld_316 = 1;
         Ld_764 = 0;
      }
      if (iadx_3392 < iadx_3400) {
         Ld_316 = 0;
         Ld_764 = 1;
      }
      iadx_3408 = iADX(Gs_308, G_timeframe_508, G_period_424, G_applied_price_412, MODE_PLUSDI, 0);
      iadx_3416 = iADX(Gs_308, G_timeframe_508, G_period_424, G_applied_price_412, MODE_MINUSDI, 0);
      if (iadx_3408 >= iadx_3416) {
         Ld_324 = 1;
         Ld_772 = 0;
      }
      if (iadx_3408 < iadx_3416) {
         Ld_324 = 0;
         Ld_772 = 1;
      }
      iadx_3424 = iADX(Gs_308, G_timeframe_504, G_period_424, G_applied_price_412, MODE_PLUSDI, 0);
      iadx_3432 = iADX(Gs_308, G_timeframe_504, G_period_424, G_applied_price_412, MODE_MINUSDI, 0);
      if (iadx_3424 >= iadx_3432) {
         Ld_332 = 1;
         Ld_780 = 0;
      }
      if (iadx_3424 < iadx_3432) {
         Ld_332 = 0;
         Ld_780 = 1;
      }
      iadx_3440 = iADX(Gs_308, G_timeframe_500, G_period_424, G_applied_price_412, MODE_PLUSDI, 0);
      iadx_3448 = iADX(Gs_308, G_timeframe_500, G_period_424, G_applied_price_412, MODE_MINUSDI, 0);
      if (iadx_3440 >= iadx_3448) {
         Ld_340 = 2;
         Ld_788 = 0;
      }
      if (iadx_3440 < iadx_3448) {
         Ld_340 = 0;
         Ld_788 = 2;
      }
      iadx_3456 = iADX(Gs_308, G_timeframe_488, G_period_424, G_applied_price_412, MODE_PLUSDI, 0);
      iadx_3464 = iADX(Gs_308, G_timeframe_488, G_period_424, G_applied_price_412, MODE_MINUSDI, 0);
      if (iadx_3456 >= iadx_3464) {
         Ld_348 = 3;
         Ld_796 = 0;
      }
      if (iadx_3456 < iadx_3464) {
         Ld_348 = 0;
         Ld_796 = 3;
      }
      iadx_3472 = iADX(Gs_308, G_timeframe_492, G_period_424, G_applied_price_412, MODE_PLUSDI, 0);
      iadx_3480 = iADX(Gs_308, G_timeframe_492, G_period_424, G_applied_price_412, MODE_MINUSDI, 0);
      if (iadx_3472 >= iadx_3480) {
         Ld_356 = 2;
         Ld_804 = 0;
      }
      if (iadx_3472 < iadx_3480) {
         Ld_356 = 0;
         Ld_804 = 2;
      }
      iadx_3488 = iADX(Gs_308, G_timeframe_496, G_period_424, G_applied_price_412, MODE_PLUSDI, 0);
      iadx_3496 = iADX(Gs_308, G_timeframe_496, G_period_424, G_applied_price_412, MODE_MINUSDI, 0);
      if (iadx_3488 >= iadx_3496) {
         Ld_364 = 2;
         Ld_812 = 0;
      }
      if (iadx_3488 < iadx_3496) {
         Ld_364 = 0;
         Ld_812 = 2;
      }
      ibullspower_3504 = iBullsPower(Gs_308, G_timeframe_512, G_period_456, G_applied_price_412, 0);
      if (ibullspower_3504 >= 0.0) {
         Ld_372 = 1;
         Ld_820 = 0;
      }
      if (ibullspower_3504 < 0.0) {
         Ld_372 = 0;
         Ld_820 = 1;
      }
      ibullspower_3512 = iBullsPower(Gs_308, G_timeframe_508, G_period_456, G_applied_price_412, 0);
      if (ibullspower_3512 >= 0.0) {
         Ld_380 = 1;
         Ld_828 = 0;
      }
      if (ibullspower_3512 < 0.0) {
         Ld_380 = 0;
         Ld_828 = 1;
      }
      ibullspower_3520 = iBullsPower(Gs_308, G_timeframe_504, G_period_456, G_applied_price_412, 0);
      if (ibullspower_3520 >= 0.0) {
         Ld_388 = 1;
         Ld_836 = 0;
      }
      if (ibullspower_3520 < 0.0) {
         Ld_388 = 0;
         Ld_836 = 1;
      }
      ibullspower_3528 = iBullsPower(Gs_308, G_timeframe_500, G_period_456, G_applied_price_412, 0);
      if (ibullspower_3528 >= 0.0) {
         Ld_396 = 2;
         Ld_844 = 0;
      }
      if (ibullspower_3528 < 0.0) {
         Ld_396 = 0;
         Ld_844 = 2;
      }
      ibullspower_3536 = iBullsPower(Gs_308, G_timeframe_488, G_period_456, G_applied_price_412, 0);
      if (ibullspower_3536 >= 0.0) {
         Ld_404 = 3;
         Ld_852 = 0;
      }
      if (ibullspower_3536 < 0.0) {
         Ld_404 = 0;
         Ld_852 = 3;
      }
      ibullspower_3544 = iBullsPower(Gs_308, G_timeframe_492, G_period_456, G_applied_price_412, 0);
      if (ibullspower_3544 >= 0.0) {
         Ld_412 = 2;
         Ld_860 = 0;
      }
      if (ibullspower_3544 < 0.0) {
         Ld_412 = 0;
         Ld_860 = 2;
      }
      ibullspower_3552 = iBullsPower(Gs_308, G_timeframe_496, G_period_456, G_applied_price_412, 0);
      if (ibullspower_3552 >= 0.0) {
         Ld_420 = 2;
         Ld_868 = 0;
      }
      if (ibullspower_3552 < 0.0) {
         Ld_420 = 0;
         Ld_868 = 2;
      }
      ibearspower_3560 = iBearsPower(Gs_308, G_timeframe_512, G_period_456, G_applied_price_412, 0);
      if (ibearspower_3560 > 0.0) {
         Ld_428 = 1;
         Ld_876 = 0;
      }
      if (ibearspower_3560 <= 0.0) {
         Ld_428 = 0;
         Ld_876 = 1;
      }
      ibearspower_3568 = iBearsPower(Gs_308, G_timeframe_508, G_period_456, G_applied_price_412, 0);
      if (ibearspower_3568 > 0.0) {
         Ld_436 = 1;
         Ld_884 = 0;
      }
      if (ibearspower_3568 <= 0.0) {
         Ld_436 = 0;
         Ld_884 = 1;
      }
      ibearspower_3576 = iBearsPower(Gs_308, G_timeframe_504, G_period_456, G_applied_price_412, 0);
      if (ibearspower_3576 > 0.0) {
         Ld_444 = 1;
         Ld_892 = 0;
      }
      if (ibearspower_3576 <= 0.0) {
         Ld_444 = 0;
         Ld_892 = 1;
      }
      ibearspower_3584 = iBearsPower(Gs_308, G_timeframe_500, G_period_456, G_applied_price_412, 0);
      if (ibearspower_3584 > 0.0) {
         Ld_452 = 2;
         Ld_900 = 0;
      }
      if (ibearspower_3584 <= 0.0) {
         Ld_452 = 0;
         Ld_900 = 2;
      }
      ibearspower_3592 = iBearsPower(Gs_308, G_timeframe_488, G_period_456, G_applied_price_412, 0);
      if (ibearspower_3592 > 0.0) {
         Ld_460 = 3;
         Ld_908 = 0;
      }
      if (ibearspower_3592 <= 0.0) {
         Ld_460 = 0;
         Ld_908 = 3;
      }
      ibearspower_3600 = iBearsPower(Gs_308, G_timeframe_492, G_period_456, G_applied_price_412, 0);
      if (ibearspower_3600 > 0.0) {
         Ld_468 = 2;
         Ld_916 = 0;
      }
      if (ibearspower_3600 <= 0.0) {
         Ld_468 = 0;
         Ld_916 = 2;
      }
      ibearspower_3608 = iBearsPower(Gs_308, G_timeframe_496, G_period_456, G_applied_price_412, 0);
      if (ibearspower_3608 > 0.0) {
         Ld_476 = 2;
         Ld_924 = 0;
      }
      if (ibearspower_3608 <= 0.0) {
         Ld_476 = 0;
         Ld_924 = 2;
      }
      istochastic_3616 = iStochastic(Gs_308, G_timeframe_512, G_period_468, G_period_472, G_slowing_476, MODE_SMA, 1, MODE_MAIN, 0);
      istochastic_3624 = iStochastic(Gs_308, G_timeframe_512, G_period_468, G_period_472, G_slowing_476, MODE_SMA, 1, MODE_SIGNAL, 0);
      if (istochastic_3616 >= istochastic_3624) {
         Ld_932 = 1;
         Ld_1212 = 0;
      }
      if (istochastic_3616 < istochastic_3624) {
         Ld_932 = 0;
         Ld_1212 = 1;
      }
      istochastic_3632 = iStochastic(Gs_308, G_timeframe_508, G_period_468, G_period_472, G_slowing_476, MODE_SMA, 1, MODE_MAIN, 0);
      istochastic_3640 = iStochastic(Gs_308, G_timeframe_508, G_period_468, G_period_472, G_slowing_476, MODE_SMA, 1, MODE_SIGNAL, 0);
      if (istochastic_3632 >= istochastic_3640) {
         Ld_940 = 1;
         Ld_1220 = 0;
      }
      if (istochastic_3632 < istochastic_3640) {
         Ld_940 = 0;
         Ld_1220 = 1;
      }
      istochastic_3648 = iStochastic(Gs_308, G_timeframe_504, G_period_468, G_period_472, G_slowing_476, MODE_SMA, 1, MODE_MAIN, 0);
      istochastic_3656 = iStochastic(Gs_308, G_timeframe_504, G_period_468, G_period_472, G_slowing_476, MODE_SMA, 1, MODE_SIGNAL, 0);
      if (istochastic_3648 >= istochastic_3656) {
         Ld_948 = 1;
         Ld_1228 = 0;
      }
      if (istochastic_3648 < istochastic_3656) {
         Ld_948 = 0;
         Ld_1228 = 1;
      }
      istochastic_3664 = iStochastic(Gs_308, G_timeframe_500, G_period_468, G_period_472, G_slowing_476, MODE_SMA, 1, MODE_MAIN, 0);
      istochastic_3672 = iStochastic(Gs_308, G_timeframe_500, G_period_468, G_period_472, G_slowing_476, MODE_SMA, 1, MODE_SIGNAL, 0);
      if (istochastic_3664 >= istochastic_3672) {
         Ld_956 = 2;
         Ld_1236 = 0;
      }
      if (istochastic_3664 < istochastic_3672) {
         Ld_956 = 0;
         Ld_1236 = 2;
      }
      istochastic_3680 = iStochastic(Gs_308, G_timeframe_488, G_period_468, G_period_472, G_slowing_476, MODE_SMA, 1, MODE_MAIN, 0);
      istochastic_3688 = iStochastic(Gs_308, G_timeframe_488, G_period_468, G_period_472, G_slowing_476, MODE_SMA, 1, MODE_SIGNAL, 0);
      if (istochastic_3680 >= istochastic_3688) {
         Ld_964 = 3;
         Ld_1244 = 0;
      }
      if (istochastic_3680 < istochastic_3688) {
         Ld_964 = 0;
         Ld_1244 = 3;
      }
      istochastic_3696 = iStochastic(Gs_308, G_timeframe_492, G_period_468, G_period_472, G_slowing_476, MODE_SMA, 1, MODE_MAIN, 0);
      istochastic_3704 = iStochastic(Gs_308, G_timeframe_492, G_period_468, G_period_472, G_slowing_476, MODE_SMA, 1, MODE_SIGNAL, 0);
      if (istochastic_3696 >= istochastic_3704) {
         Ld_972 = 2;
         Ld_1252 = 0;
      }
      if (istochastic_3696 < istochastic_3704) {
         Ld_972 = 0;
         Ld_1252 = 2;
      }
      istochastic_3712 = iStochastic(Gs_308, G_timeframe_496, G_period_468, G_period_472, G_slowing_476, MODE_SMA, 1, MODE_MAIN, 0);
      istochastic_3720 = iStochastic(Gs_308, G_timeframe_496, G_period_468, G_period_472, G_slowing_476, MODE_SMA, 1, MODE_SIGNAL, 0);
      if (istochastic_3712 >= istochastic_3720) {
         Ld_980 = 2;
         Ld_1260 = 0;
      }
      if (istochastic_3712 < istochastic_3720) {
         Ld_980 = 0;
         Ld_1260 = 2;
      }
      irsi_3728 = iRSI(Gs_308, G_timeframe_512, G_period_424, PRICE_CLOSE, 0);
      if (irsi_3728 >= 50.0) {
         Ld_988 = 1;
         Ld_1268 = 0;
      }
      if (irsi_3728 < 50.0) {
         Ld_988 = 0;
         Ld_1268 = 1;
      }
      irsi_3736 = iRSI(Gs_308, G_timeframe_508, G_period_424, PRICE_CLOSE, 0);
      if (irsi_3736 >= 50.0) {
         Ld_996 = 1;
         Ld_1276 = 0;
      }
      if (irsi_3736 < 50.0) {
         Ld_996 = 0;
         Ld_1276 = 1;
      }
      irsi_3744 = iRSI(Gs_308, G_timeframe_504, G_period_424, PRICE_CLOSE, 0);
      if (irsi_3744 >= 50.0) {
         Ld_1004 = 1;
         Ld_1284 = 0;
      }
      if (irsi_3744 < 50.0) {
         Ld_1004 = 0;
         Ld_1284 = 1;
      }
      irsi_3752 = iRSI(Gs_308, G_timeframe_500, G_period_424, PRICE_CLOSE, 0);
      if (irsi_3752 >= 50.0) {
         Ld_1012 = 2;
         Ld_1292 = 0;
      }
      if (irsi_3752 < 50.0) {
         Ld_1012 = 0;
         Ld_1292 = 2;
      }
      irsi_3760 = iRSI(Gs_308, G_timeframe_488, G_period_424, PRICE_CLOSE, 0);
      if (irsi_3760 >= 50.0) {
         Ld_1020 = 3;
         Ld_1300 = 0;
      }
      if (irsi_3760 < 50.0) {
         Ld_1020 = 0;
         Ld_1300 = 3;
      }
      irsi_3768 = iRSI(Gs_308, G_timeframe_492, G_period_424, PRICE_CLOSE, 0);
      if (irsi_3768 >= 50.0) {
         Ld_1028 = 2;
         Ld_1308 = 0;
      }
      if (irsi_3768 < 50.0) {
         Ld_1028 = 0;
         Ld_1308 = 2;
      }
      irsi_3776 = iRSI(Gs_308, G_timeframe_496, G_period_424, PRICE_CLOSE, 0);
      if (irsi_3776 >= 50.0) {
         Ld_1036 = 2;
         Ld_1316 = 0;
      }
      if (irsi_3776 < 50.0) {
         Ld_1036 = 0;
         Ld_1316 = 2;
      }
      iobv_3784 = iOBV(Gs_308, G_timeframe_512, PRICE_CLOSE, 0);
      iobv_3792 = iOBV(Gs_308, G_timeframe_512, PRICE_CLOSE, 20);
      if (iobv_3784 > iobv_3792) {
         Ld_1828 = 1;
         Ld_1884 = 0;
      }
      if (iobv_3784 <= iobv_3792) {
         Ld_1828 = 0;
         Ld_1884 = 1;
      }
      iobv_3800 = iOBV(Gs_308, G_timeframe_508, PRICE_CLOSE, 0);
      iobv_3808 = iOBV(Gs_308, G_timeframe_508, PRICE_CLOSE, 20);
      if (iobv_3800 > iobv_3808) {
         Ld_1836 = 1;
         Ld_1892 = 0;
      }
      if (iobv_3800 <= iobv_3808) {
         Ld_1836 = 0;
         Ld_1892 = 1;
      }
      iobv_3816 = iOBV(Gs_308, G_timeframe_504, PRICE_CLOSE, 0);
      iobv_3824 = iOBV(Gs_308, G_timeframe_504, PRICE_CLOSE, 20);
      if (iobv_3816 > iobv_3824) {
         Ld_1844 = 1;
         Ld_1900 = 0;
      }
      if (iobv_3816 <= iobv_3824) {
         Ld_1844 = 0;
         Ld_1900 = 1;
      }
      iobv_3832 = iOBV(Gs_308, G_timeframe_500, PRICE_CLOSE, 0);
      iobv_3840 = iOBV(Gs_308, G_timeframe_500, PRICE_CLOSE, 20);
      if (iobv_3832 > iobv_3840) {
         Ld_1852 = 2;
         Ld_1908 = 0;
      }
      if (iobv_3832 <= iobv_3840) {
         Ld_1852 = 0;
         Ld_1908 = 2;
      }
      iobv_3848 = iOBV(Gs_308, G_timeframe_488, PRICE_CLOSE, 0);
      iobv_3856 = iOBV(Gs_308, G_timeframe_488, PRICE_CLOSE, 20);
      if (iobv_3848 > iobv_3856) {
         Ld_1860 = 3;
         Ld_1916 = 0;
      }
      if (iobv_3848 <= iobv_3856) {
         Ld_1860 = 0;
         Ld_1916 = 3;
      }
      iobv_3864 = iOBV(Gs_308, G_timeframe_492, PRICE_CLOSE, 0);
      iobv_3872 = iOBV(Gs_308, G_timeframe_492, PRICE_CLOSE, 20);
      if (iobv_3864 > iobv_3872) {
         Ld_1868 = 2;
         Ld_1924 = 0;
      }
      if (iobv_3864 <= iobv_3872) {
         Ld_1868 = 0;
         Ld_1924 = 2;
      }
      iobv_3880 = iOBV(Gs_308, G_timeframe_496, PRICE_CLOSE, 0);
      iobv_3888 = iOBV(Gs_308, G_timeframe_496, PRICE_CLOSE, 20);
      if (iobv_3880 > iobv_3888) {
         Ld_1876 = 2;
         Ld_1932 = 0;
      }
      if (iobv_3880 <= iobv_3888) {
         Ld_1876 = 0;
         Ld_1932 = 2;
      }
      iforce_3896 = iForce(Gs_308, G_timeframe_512, G_period_424, G_ma_method_400, G_applied_price_412, 0);
      if (iforce_3896 >= 0.0) {
         Ld_1044 = 1;
         Ld_1324 = 0;
      }
      if (iforce_3896 < 0.0) {
         Ld_1044 = 0;
         Ld_1324 = 1;
      }
      iforce_3904 = iForce(Gs_308, G_timeframe_508, G_period_424, G_ma_method_400, G_applied_price_412, 0);
      if (iforce_3904 >= 0.0) {
         Ld_1052 = 1;
         Ld_1332 = 0;
      }
      if (iforce_3904 < 0.0) {
         Ld_1052 = 0;
         Ld_1332 = 1;
      }
      iforce_3912 = iForce(Gs_308, G_timeframe_504, G_period_424, G_ma_method_400, G_applied_price_412, 0);
      if (iforce_3912 >= 0.0) {
         Ld_1060 = 1;
         Ld_1340 = 0;
      }
      if (iforce_3912 < 0.0) {
         Ld_1060 = 0;
         Ld_1340 = 1;
      }
      iforce_3920 = iForce(Gs_308, G_timeframe_500, G_period_424, G_ma_method_400, G_applied_price_412, 0);
      if (iforce_3920 >= 0.0) {
         Ld_1068 = 2;
         Ld_1348 = 0;
      }
      if (iforce_3920 < 0.0) {
         Ld_1068 = 0;
         Ld_1348 = 2;
      }
      iforce_3928 = iForce(Gs_308, G_timeframe_488, G_period_424, G_ma_method_400, G_applied_price_412, 0);
      if (iforce_3928 >= 0.0) {
         Ld_1076 = 3;
         Ld_1356 = 0;
      }
      if (iforce_3928 < 0.0) {
         Ld_1076 = 0;
         Ld_1356 = 3;
      }
      iforce_3936 = iForce(Gs_308, G_timeframe_492, G_period_424, G_ma_method_400, G_applied_price_412, 0);
      if (iforce_3936 >= 0.0) {
         Ld_1084 = 2;
         Ld_1364 = 0;
      }
      if (iforce_3936 < 0.0) {
         Ld_1084 = 0;
         Ld_1364 = 2;
      }
      iforce_3944 = iForce(Gs_308, G_timeframe_496, G_period_424, G_ma_method_400, G_applied_price_412, 0);
      if (iforce_3944 >= 0.0) {
         Ld_1092 = 2;
         Ld_1372 = 0;
      }
      if (iforce_3944 < 0.0) {
         Ld_1092 = 0;
         Ld_1372 = 2;
      }
      imomentum_3952 = iMomentum(Gs_308, G_timeframe_512, G_period_424, G_applied_price_412, 0);
      if (imomentum_3952 >= 100.0) {
         Ld_1100 = 1;
         Ld_1380 = 0;
      }
      if (imomentum_3952 < 100.0) {
         Ld_1100 = 0;
         Ld_1380 = 1;
      }
      imomentum_3960 = iMomentum(Gs_308, G_timeframe_508, G_period_424, G_applied_price_412, 0);
      if (imomentum_3960 >= 100.0) {
         Ld_1108 = 1;
         Ld_1388 = 0;
      }
      if (imomentum_3960 < 100.0) {
         Ld_1108 = 0;
         Ld_1388 = 1;
      }
      imomentum_3968 = iMomentum(Gs_308, G_timeframe_504, G_period_424, G_applied_price_412, 0);
      if (imomentum_3968 >= 100.0) {
         Ld_1116 = 1;
         Ld_1396 = 0;
      }
      if (imomentum_3968 < 100.0) {
         Ld_1116 = 0;
         Ld_1396 = 1;
      }
      imomentum_3976 = iMomentum(Gs_308, G_timeframe_500, G_period_424, G_applied_price_412, 0);
      if (imomentum_3976 >= 100.0) {
         Ld_1124 = 2;
         Ld_1404 = 0;
      }
      if (imomentum_3976 < 100.0) {
         Ld_1124 = 0;
         Ld_1404 = 2;
      }
      imomentum_3984 = iMomentum(Gs_308, G_timeframe_488, G_period_424, G_applied_price_412, 0);
      if (imomentum_3984 >= 100.0) {
         Ld_1132 = 3;
         Ld_1412 = 0;
      }
      if (imomentum_3984 < 100.0) {
         Ld_1132 = 0;
         Ld_1412 = 3;
      }
      imomentum_3992 = iMomentum(Gs_308, G_timeframe_492, G_period_424, G_applied_price_412, 0);
      if (imomentum_3992 >= 100.0) {
         Ld_1140 = 2;
         Ld_1420 = 0;
      }
      if (imomentum_3992 < 100.0) {
         Ld_1140 = 0;
         Ld_1420 = 2;
      }
      imomentum_4000 = iMomentum(Gs_308, G_timeframe_496, G_period_424, G_applied_price_412, 0);
      if (imomentum_4000 >= 100.0) {
         Ld_1148 = 2;
         Ld_1428 = 0;
      }
      if (imomentum_4000 < 100.0) {
         Ld_1148 = 0;
         Ld_1428 = 2;
      }
      idemarker_4008 = iDeMarker(Gs_308, G_timeframe_512, G_period_424, 0);
      if (idemarker_4008 >= 0.5) {
         Ld_1156 = 1;
         Ld_1436 = 0;
      }
      if (idemarker_4008 < 0.5) {
         Ld_1156 = 0;
         Ld_1436 = 1;
      }
      idemarker_4016 = iDeMarker(Gs_308, G_timeframe_508, G_period_424, 0);
      if (idemarker_4016 >= 0.5) {
         Ld_1164 = 1;
         Ld_1444 = 0;
      }
      if (idemarker_4016 < 0.5) {
         Ld_1164 = 0;
         Ld_1444 = 1;
      }
      idemarker_4024 = iDeMarker(Gs_308, G_timeframe_504, G_period_424, 0);
      if (idemarker_4024 >= 0.5) {
         Ld_1172 = 1;
         Ld_1452 = 0;
      }
      if (idemarker_4024 < 0.5) {
         Ld_1172 = 0;
         Ld_1452 = 1;
      }
      idemarker_4032 = iDeMarker(Gs_308, G_timeframe_500, G_period_424, 0);
      if (idemarker_4032 >= 0.5) {
         Ld_1180 = 2;
         Ld_1460 = 0;
      }
      if (idemarker_4032 < 0.5) {
         Ld_1180 = 0;
         Ld_1460 = 2;
      }
      idemarker_4040 = iDeMarker(Gs_308, G_timeframe_488, G_period_424, 0);
      if (idemarker_4040 >= 0.5) {
         Ld_1188 = 3;
         Ld_1468 = 0;
      }
      if (idemarker_4040 < 0.5) {
         Ld_1188 = 0;
         Ld_1468 = 3;
      }
      idemarker_4048 = iDeMarker(Gs_308, G_timeframe_492, G_period_424, 0);
      if (idemarker_4048 >= 0.5) {
         Ld_1196 = 2;
         Ld_1476 = 0;
      }
      if (idemarker_4048 < 0.5) {
         Ld_1196 = 0;
         Ld_1476 = 2;
      }
      idemarker_4056 = iDeMarker(Gs_308, G_timeframe_496, G_period_424, 0);
      if (idemarker_4056 >= 0.5) {
         Ld_1204 = 2;
         Ld_1484 = 0;
      }
      if (idemarker_4056 < 0.5) {
         Ld_1204 = 0;
         Ld_1484 = 2;
      }
      iac_4064 = iAC(Gs_308, G_timeframe_512, 0);
      if (iac_4064 >= 0.0) {
         Ld_2164 = 1;
         Ld_2220 = 0;
      }
      if (iac_4064 < 0.0) {
         Ld_2164 = 0;
         Ld_2220 = 1;
      }
      iac_4072 = iAC(Gs_308, G_timeframe_508, 0);
      if (iac_4072 >= 0.0) {
         Ld_2172 = 1;
         Ld_2228 = 0;
      }
      if (iac_4072 < 0.0) {
         Ld_2172 = 0;
         Ld_2228 = 1;
      }
      iac_4080 = iAC(Gs_308, G_timeframe_504, 0);
      if (iac_4080 >= 0.0) {
         Ld_2180 = 1;
         Ld_2236 = 0;
      }
      if (iac_4080 < 0.0) {
         Ld_2180 = 0;
         Ld_2236 = 1;
      }
      iac_4088 = iAC(Gs_308, G_timeframe_500, 0);
      if (iac_4088 >= 0.0) {
         Ld_2188 = 2;
         Ld_2244 = 0;
      }
      if (iac_4088 < 0.0) {
         Ld_2188 = 0;
         Ld_2244 = 2;
      }
      iac_4096 = iAC(Gs_308, G_timeframe_488, 0);
      if (iac_4096 >= 0.0) {
         Ld_2196 = 3;
         Ld_2252 = 0;
      }
      if (iac_4096 < 0.0) {
         Ld_2196 = 0;
         Ld_2252 = 3;
      }
      iac_4104 = iAC(Gs_308, G_timeframe_492, 0);
      if (iac_4104 >= 0.0) {
         Ld_2204 = 2;
         Ld_2260 = 0;
      }
      if (iac_4104 < 0.0) {
         Ld_2204 = 0;
         Ld_2260 = 2;
      }
      iac_4112 = iAC(Gs_308, G_timeframe_496, 0);
      if (iac_4112 >= 0.0) {
         Ld_2212 = 2;
         Ld_2268 = 0;
      }
      if (iac_4112 < 0.0) {
         Ld_2212 = 0;
         Ld_2268 = 2;
      }
      iwpr_4120 = iWPR(Gs_308, G_timeframe_512, 42, 0);
      if (iwpr_4120 >= -50.0) {
         Ld_2052 = 1;
         Ld_2108 = 0;
      }
      if (iwpr_4120 < -50.0) {
         Ld_2052 = 0;
         Ld_2108 = 1;
      }
      iwpr_4128 = iWPR(Gs_308, G_timeframe_508, 42, 0);
      if (iwpr_4128 >= -50.0) {
         Ld_2060 = 1;
         Ld_2108 = 0;
      }
      if (iwpr_4128 < -50.0) {
         Ld_2060 = 0;
         Ld_2108 = 1;
      }
      iwpr_4136 = iWPR(Gs_308, G_timeframe_504, 42, 0);
      if (iwpr_4136 >= -50.0) {
         Ld_2068 = 1;
         Ld_2116 = 0;
      }
      if (iwpr_4136 < -50.0) {
         Ld_2068 = 0;
         Ld_2116 = 1;
      }
      iwpr_4144 = iWPR(Gs_308, G_timeframe_500, 42, 0);
      if (iwpr_4144 >= -50.0) {
         Ld_2076 = 2;
         Ld_2124 = 0;
      }
      if (iwpr_4144 < -50.0) {
         Ld_2076 = 0;
         Ld_2124 = 2;
      }
      iwpr_4152 = iWPR(Gs_308, G_timeframe_488, 42, 0);
      if (iwpr_4152 >= -50.0) {
         Ld_2084 = 3;
         Ld_2132 = 0;
      }
      if (iwpr_4152 < -50.0) {
         Ld_2084 = 0;
         Ld_2132 = 3;
      }
      iwpr_4160 = iWPR(Gs_308, G_timeframe_492, 42, 0);
      if (iwpr_4160 >= -50.0) {
         Ld_2092 = 2;
         Ld_2148 = 0;
      }
      if (iwpr_4160 < -50.0) {
         Ld_2092 = 0;
         Ld_2148 = 2;
      }
      iwpr_4168 = iWPR(Gs_308, G_timeframe_496, 42, 0);
      if (iwpr_4168 >= -50.0) {
         Ld_2100 = 2;
         Ld_2156 = 0;
      }
      if (iwpr_4168 < -50.0) {
         Ld_2100 = 0;
         Ld_2156 = 2;
      }
      iosma_4176 = iOsMA(Gs_308, G_timeframe_512, G_period_436, G_period_440, G_period_444, PRICE_CLOSE, 0);
      if (iosma_4176 >= 0.0) {
         Ld_1940 = 1;
         Ld_1996 = 0;
      }
      if (iosma_4176 < 0.0) {
         Ld_1940 = 0;
         Ld_1996 = 1;
      }
      iosma_4184 = iOsMA(Gs_308, G_timeframe_508, G_period_436, G_period_440, G_period_444, PRICE_CLOSE, 0);
      if (iosma_4184 >= 0.0) {
         Ld_1948 = 1;
         Ld_2004 = 0;
      }
      if (iosma_4184 < 0.0) {
         Ld_1948 = 0;
         Ld_2004 = 1;
      }
      iosma_4192 = iOsMA(Gs_308, G_timeframe_504, G_period_436, G_period_440, G_period_444, PRICE_CLOSE, 0);
      if (iosma_4192 >= 0.0) {
         Ld_1956 = 1;
         Ld_2012 = 0;
      }
      if (iosma_4192 < 0.0) {
         Ld_1956 = 0;
         Ld_2012 = 1;
      }
      iosma_4200 = iOsMA(Gs_308, G_timeframe_500, G_period_436, G_period_440, G_period_444, PRICE_CLOSE, 0);
      if (iosma_4200 >= 0.0) {
         Ld_1964 = 2;
         Ld_2020 = 0;
      }
      if (iosma_4200 < 0.0) {
         Ld_1964 = 0;
         Ld_2020 = 2;
      }
      iosma_4208 = iOsMA(Gs_308, G_timeframe_488, G_period_436, G_period_440, G_period_444, PRICE_CLOSE, 0);
      if (iosma_4208 >= 0.0) {
         Ld_1972 = 3;
         Ld_2028 = 0;
      }
      if (iosma_4208 < 0.0) {
         Ld_1972 = 0;
         Ld_2028 = 3;
      }
      iosma_4216 = iOsMA(Gs_308, G_timeframe_492, G_period_436, G_period_440, G_period_444, PRICE_CLOSE, 0);
      if (iosma_4216 >= 0.0) {
         Ld_1980 = 2;
         Ld_2036 = 0;
      }
      if (iosma_4216 < 0.0) {
         Ld_1980 = 0;
         Ld_2036 = 2;
      }
      iosma_4224 = iOsMA(Gs_308, G_timeframe_496, G_period_436, G_period_440, G_period_444, PRICE_CLOSE, 0);
      if (iosma_4224 >= 0.0) {
         Ld_1988 = 2;
         Ld_2044 = 0;
      }
      if (iosma_4224 < 0.0) {
         Ld_1988 = 0;
         Ld_2044 = 2;
      }
      isar_4232 = iSAR(Gs_308, G_timeframe_512, 0.02, 0.2, 0);
      if (isar_4232 < MarketInfo(Gs_308, MODE_BID)) {
         Ld_1716 = 1;
         Ld_1772 = 0;
      }
      if (isar_4232 >= MarketInfo(Gs_308, MODE_BID)) {
         Ld_1716 = 0;
         Ld_1772 = 1;
      }
      isar_4240 = iSAR(Gs_308, G_timeframe_508, 0.02, 0.2, 0);
      if (isar_4240 < MarketInfo(Gs_308, MODE_BID)) {
         Ld_1724 = 1;
         Ld_1780 = 0;
      }
      if (isar_4240 >= MarketInfo(Gs_308, MODE_BID)) {
         Ld_1724 = 0;
         Ld_1780 = 1;
      }
      isar_4248 = iSAR(Gs_308, G_timeframe_504, 0.02, 0.2, 0);
      if (isar_4248 < MarketInfo(Gs_308, MODE_BID)) {
         Ld_1732 = 1;
         Ld_1788 = 0;
      }
      if (isar_4248 >= MarketInfo(Gs_308, MODE_BID)) {
         Ld_1732 = 0;
         Ld_1788 = 1;
      }
      isar_4256 = iSAR(Gs_308, G_timeframe_500, 0.02, 0.2, 0);
      if (isar_4256 < MarketInfo(Gs_308, MODE_BID)) {
         Ld_1740 = 2;
         Ld_1796 = 0;
      }
      if (isar_4256 >= MarketInfo(Gs_308, MODE_BID)) {
         Ld_1740 = 0;
         Ld_1796 = 2;
      }
      isar_4264 = iSAR(Gs_308, G_timeframe_488, 0.02, 0.2, 0);
      if (isar_4264 < MarketInfo(Gs_308, MODE_BID)) {
         Ld_1748 = 3;
         Ld_1804 = 0;
      }
      if (isar_4264 >= MarketInfo(Gs_308, MODE_BID)) {
         Ld_1748 = 0;
         Ld_1804 = 3;
      }
      isar_4272 = iSAR(Gs_308, G_timeframe_492, 0.02, 0.2, 0);
      if (isar_4272 < MarketInfo(Gs_308, MODE_BID)) {
         Ld_1756 = 2;
         Ld_1812 = 0;
      }
      if (isar_4272 >= MarketInfo(Gs_308, MODE_BID)) {
         Ld_1756 = 0;
         Ld_1812 = 2;
      }
      isar_4280 = iSAR(Gs_308, G_timeframe_496, 0.02, 0.2, 0);
      if (isar_4280 < MarketInfo(Gs_308, MODE_BID)) {
         Ld_1764 = 2;
         Ld_1820 = 0;
      }
      if (isar_4280 >= MarketInfo(Gs_308, MODE_BID)) {
         Ld_1764 = 0;
         Ld_1820 = 2;
      }
      Ld_4288 = Ld_36 + Ld_92 + Ld_148 + Ld_204 + Ld_260 + Ld_316 + Ld_372 + Ld_428 + Ld_932 + Ld_988 + Ld_1044 + Ld_1100 + Ld_1156 + Ld_1828 + Ld_1940 + Ld_2052 + Ld_2164 +
         Ld_1716 + Ld_1492 + Ld_1604;
      Ld_4296 = Ld_44 + Ld_100 + Ld_156 + Ld_212 + Ld_268 + Ld_324 + Ld_380 + Ld_436 + Ld_940 + Ld_996 + Ld_1052 + Ld_1108 + Ld_1164 + Ld_1836 + Ld_1948 + Ld_2060 + Ld_2172 +
         Ld_1724 + Ld_1500 + Ld_1612;
      Ld_4304 = Ld_52 + Ld_108 + Ld_164 + Ld_220 + Ld_276 + Ld_332 + Ld_388 + Ld_444 + Ld_948 + Ld_1004 + Ld_1060 + Ld_1116 + Ld_1172 + Ld_1844 + Ld_1956 + Ld_2068 + Ld_2180 +
         Ld_1732 + Ld_1508 + Ld_1620;
      Ld_4312 = Ld_60 + Ld_116 + Ld_172 + Ld_228 + Ld_284 + Ld_340 + Ld_396 + Ld_452 + Ld_956 + Ld_1012 + Ld_1068 + Ld_1124 + Ld_1180 + Ld_1852 + Ld_1964 + Ld_2076 + Ld_2188 +
         Ld_1740 + Ld_1516 + Ld_1628;
      Ld_4320 = Ld_68 + Ld_124 + Ld_180 + Ld_236 + Ld_292 + Ld_348 + Ld_404 + Ld_460 + Ld_964 + Ld_1020 + Ld_1076 + Ld_1132 + Ld_1188 + Ld_1860 + Ld_1972 + Ld_2084 + Ld_2196 +
         Ld_1748 + Ld_1524 + Ld_1636;
      Ld_4328 = Ld_76 + Ld_132 + Ld_188 + Ld_244 + Ld_300 + Ld_356 + Ld_412 + Ld_468 + Ld_972 + Ld_1028 + Ld_1084 + Ld_1140 + Ld_1196 + Ld_1868 + Ld_1980 + Ld_2092 + Ld_2204 +
         Ld_1756 + Ld_1532 + Ld_1644;
      Ld_4336 = Ld_84 + Ld_140 + Ld_196 + Ld_252 + Ld_308 + Ld_364 + Ld_420 + Ld_476 + Ld_980 + Ld_1036 + Ld_1092 + Ld_1148 + Ld_1204 + Ld_1876 + Ld_1988 + Ld_2100 + Ld_2212 +
         Ld_1764 + Ld_1540 + Ld_1652;
      Ld_4344 = Ld_4288 + Ld_4296 + Ld_4304 + Ld_4312 + Ld_4320 + Ld_4328 + Ld_4336;
      Ld_4352 = Ld_484 + Ld_540 + Ld_596 + Ld_652 + Ld_708 + Ld_764 + Ld_820 + Ld_876 + Ld_1212 + Ld_1268 + Ld_1324 + Ld_1380 + Ld_1436 + Ld_1884 + Ld_1996 + Ld_2108 + Ld_2220 +
         Ld_1772 + Ld_1548 + Ld_1660;
      Ld_4360 = Ld_492 + Ld_548 + Ld_604 + Ld_660 + Ld_716 + Ld_772 + Ld_828 + Ld_884 + Ld_1220 + Ld_1276 + Ld_1332 + Ld_1388 + Ld_1444 + Ld_1892 + Ld_2004 + Ld_2116 + Ld_2228 +
         Ld_1780 + Ld_1556 + Ld_1668;
      Ld_4368 = Ld_500 + Ld_556 + Ld_612 + Ld_668 + Ld_724 + Ld_780 + Ld_836 + Ld_892 + Ld_1228 + Ld_1284 + Ld_1340 + Ld_1396 + Ld_1452 + Ld_1900 + Ld_2012 + Ld_2124 + Ld_2236 +
         Ld_1788 + Ld_1564 + Ld_1676;
      Ld_4376 = Ld_508 + Ld_564 + Ld_620 + Ld_676 + Ld_732 + Ld_788 + Ld_844 + Ld_900 + Ld_1236 + Ld_1292 + Ld_1348 + Ld_1404 + Ld_1460 + Ld_1908 + Ld_2020 + Ld_2132 + Ld_2244 +
         Ld_1796 + Ld_1572 + Ld_1684;
      Ld_4384 = Ld_516 + Ld_572 + Ld_628 + Ld_684 + Ld_740 + Ld_796 + Ld_852 + Ld_908 + Ld_1244 + Ld_1300 + Ld_1356 + Ld_1412 + Ld_1468 + Ld_1916 + Ld_2028 + Ld_2140 + Ld_2252 +
         Ld_1804 + Ld_1580 + Ld_1692;
      Ld_4392 = Ld_524 + Ld_580 + Ld_636 + Ld_692 + Ld_748 + Ld_804 + Ld_860 + Ld_916 + Ld_1252 + Ld_1308 + Ld_1364 + Ld_1420 + Ld_1476 + Ld_1924 + Ld_2036 + Ld_2148 + Ld_2260 +
         Ld_1812 + Ld_1588 + Ld_1700;
      Ld_4400 = Ld_532 + Ld_588 + Ld_644 + Ld_700 + Ld_756 + Ld_812 + Ld_868 + Ld_924 + Ld_1260 + Ld_1316 + Ld_1372 + Ld_1428 + Ld_1484 + Ld_1932 + Ld_2044 + Ld_2156 + Ld_2268 +
         Ld_1820 + Ld_1596 + Ld_1708;
      Ld_4408 = Ld_4352 + Ld_4360 + Ld_4368 + Ld_4376 + Ld_4384 + Ld_4392 + Ld_4400;
      Ld_4416 = NormalizeDouble(100.0 * (Ld_4344 / 241.0), 0);
      Ld_4424 = NormalizeDouble(100.0 * (Ld_4408 / 241.0), 0);
      if (Ld_4416 < 51.0 || Ld_4424 < 51.0) Gi_952 = 0;
      if (Ld_4416 >= 51.0) Gi_952 = 1;
      if (Ld_4416 >= 52.0) Gi_952 = 2;
      if (Ld_4416 >= 53.0) Gi_952 = 3;
      if (Ld_4416 >= 54.0) Gi_952 = 4;
      if (Ld_4416 >= 55.0) Gi_952 = 5;
      if (Ld_4416 >= 56.0) Gi_952 = 6;
      if (Ld_4416 >= 57.0) Gi_952 = 7;
      if (Ld_4416 >= 58.0) Gi_952 = 8;
      if (Ld_4416 >= 59.0) Gi_952 = 9;
      if (Ld_4416 >= 60.0) Gi_952 = 10;
      if (Ld_4416 >= 61.0) Gi_952 = 11;
      if (Ld_4416 >= 62.0) Gi_952 = 12;
      if (Ld_4416 >= 63.0) Gi_952 = 13;
      if (Ld_4416 >= 64.0) Gi_952 = 14;
      if (Ld_4416 >= 65.0) Gi_952 = 15;
      if (Ld_4416 >= 66.0) Gi_952 = 16;
      if (Ld_4416 >= 67.0) Gi_952 = 17;
      if (Ld_4416 >= 68.0) Gi_952 = 18;
      if (Ld_4416 >= 69.0) Gi_952 = 19;
      if (Ld_4416 >= 70.0) Gi_952 = 20;
      if (Ld_4416 >= 71.0) Gi_952 = 21;
      if (Ld_4416 >= 72.0) Gi_952 = 22;
      if (Ld_4416 >= 73.0) Gi_952 = 23;
      if (Ld_4416 >= 74.0) Gi_952 = 24;
      if (Ld_4416 >= 75.0) Gi_952 = 25;
      if (Ld_4416 >= 76.0) Gi_952 = 26;
      if (Ld_4416 >= 77.0) Gi_952 = 27;
      if (Ld_4416 >= 78.0) Gi_952 = 28;
      if (Ld_4416 >= 79.0) Gi_952 = 29;
      if (Ld_4416 >= 80.0) Gi_952 = 30;
      if (Ld_4416 >= 81.0) Gi_952 = 31;
      if (Ld_4416 >= 82.0) Gi_952 = 32;
      if (Ld_4416 >= 83.0) Gi_952 = 33;
      if (Ld_4416 >= 84.0) Gi_952 = 34;
      if (Ld_4416 >= 85.0) Gi_952 = 35;
      if (Ld_4416 >= 86.0) Gi_952 = 36;
      if (Ld_4416 >= 87.0) Gi_952 = 37;
      if (Ld_4416 >= 88.0) Gi_952 = 38;
      if (Ld_4416 >= 89.0) Gi_952 = 39;
      if (Ld_4416 >= 90.0) Gi_952 = 40;
      if (Ld_4416 >= 91.0) Gi_952 = 41;
      if (Ld_4416 >= 92.0) Gi_952 = 42;
      if (Ld_4416 >= 93.0) Gi_952 = 43;
      if (Ld_4416 >= 94.0) Gi_952 = 44;
      if (Ld_4416 >= 95.0) Gi_952 = 45;
      if (Ld_4416 >= 96.0) Gi_952 = 46;
      if (Ld_4416 >= 97.0) Gi_952 = 47;
      if (Ld_4416 >= 100.0) Li_unused_2556 = 26;
      if (Ld_4424 >= 51.0) Gi_952 = -1;
      if (Ld_4424 >= 52.0) Gi_952 = -2;
      if (Ld_4424 >= 53.0) Gi_952 = -3;
      if (Ld_4424 >= 54.0) Gi_952 = -4;
      if (Ld_4424 >= 55.0) Gi_952 = -5;
      if (Ld_4424 >= 56.0) Gi_952 = -6;
      if (Ld_4424 >= 57.0) Gi_952 = -7;
      if (Ld_4424 >= 58.0) Gi_952 = -8;
      if (Ld_4424 >= 59.0) Gi_952 = -9;
      if (Ld_4424 >= 60.0) Gi_952 = -10;
      if (Ld_4424 >= 61.0) Gi_952 = -11;
      if (Ld_4424 >= 62.0) Gi_952 = -12;
      if (Ld_4424 >= 63.0) Gi_952 = -13;
      if (Ld_4424 >= 64.0) Gi_952 = -14;
      if (Ld_4424 >= 65.0) Gi_952 = -15;
      if (Ld_4424 >= 66.0) Gi_952 = -16;
      if (Ld_4424 >= 67.0) Gi_952 = -17;
      if (Ld_4424 >= 68.0) Gi_952 = -18;
      if (Ld_4424 >= 69.0) Gi_952 = -19;
      if (Ld_4424 >= 70.0) Gi_952 = -20;
      if (Ld_4424 >= 71.0) Gi_952 = -21;
      if (Ld_4424 >= 72.0) Gi_952 = -22;
      if (Ld_4424 >= 73.0) Gi_952 = -23;
      if (Ld_4424 >= 74.0) Gi_952 = -24;
      if (Ld_4424 >= 75.0) Gi_952 = -25;
      if (Ld_4424 >= 76.0) Gi_952 = -26;
      if (Ld_4424 >= 77.0) Gi_952 = -27;
      if (Ld_4424 >= 78.0) Gi_952 = -28;
      if (Ld_4424 >= 79.0) Gi_952 = -29;
      if (Ld_4424 >= 80.0) Gi_952 = -30;
      if (Ld_4424 >= 81.0) Gi_952 = -31;
      if (Ld_4424 >= 82.0) Gi_952 = -32;
      if (Ld_4424 >= 83.0) Gi_952 = -33;
      if (Ld_4424 >= 84.0) Gi_952 = -34;
      if (Ld_4424 >= 85.0) Gi_952 = -35;
      if (Ld_4424 >= 86.0) Gi_952 = -36;
      if (Ld_4424 >= 87.0) Gi_952 = -37;
      if (Ld_4424 >= 88.0) Gi_952 = -38;
      if (Ld_4424 >= 89.0) Gi_952 = -39;
      if (Ld_4424 >= 90.0) Gi_952 = -40;
      if (Ld_4424 >= 91.0) Gi_952 = -41;
      if (Ld_4424 >= 92.0) Gi_952 = -42;
      if (Ld_4424 >= 93.0) Gi_952 = -43;
      if (Ld_4424 >= 94.0) Gi_952 = -44;
      if (Ld_4424 >= 95.0) Gi_952 = -45;
      if (Ld_4424 >= 96.0) Gi_952 = -46;
      if (Ld_4424 >= 97.0) Gi_952 = -47;
      if (Ld_4424 >= 100.0) Li_unused_2556 = 26;
      if (Ld_4416 >= 50.0) {
         Gd_unused_580 = Ld_4416;
         Gs_unused_568 = "5";
         Gi_unused_636 = G_color_644;
      } else {
         Gd_unused_580 = Ld_4424;
         Gs_unused_568 = "6";
         Gi_unused_636 = G_color_760;
      }
      if (Ld_4416 >= 60.0) Gi_unused_588 = G_color_652;
      if (Ld_4424 >= 60.0) Gi_unused_588 = G_color_836;
      if (Ld_4416 < 60.0 && Ld_4416 >= 45.0) Gi_unused_588 = G_color_932;
      if (Ld_4424 < 60.0 && Ld_4424 > 45.0) Gi_unused_588 = G_color_932;
      symbol_4432 = Gs_308;
      dbl2str_4440 = DoubleToStr(iHigh(symbol_4432, G_timeframe_480, iHighest(symbol_4432, G_timeframe_480, MODE_HIGH, 48, 0)), MarketInfo(Gs_308, MODE_DIGITS));
      dbl2str_4448 = DoubleToStr(MarketInfo(symbol_4432, MODE_ASK), MarketInfo(Gs_308, MODE_DIGITS));
      dbl2str_4456 = DoubleToStr(MarketInfo(symbol_4432, MODE_BID), MarketInfo(Gs_308, MODE_DIGITS));
      dbl2str_4464 = DoubleToStr(iLow(symbol_4432, G_timeframe_480, iLowest(symbol_4432, G_timeframe_480, MODE_LOW, 48, 0)), MarketInfo(Gs_308, MODE_DIGITS));
      dbl2str_4472 = DoubleToStr((StrToDouble(dbl2str_4440) - StrToDouble(dbl2str_4464)) / MarketInfo(Gs_308, MODE_POINT), 0);
      dbl2str_4480 = DoubleToStr(100.0 * ((StrToDouble(dbl2str_4456) - StrToDouble(dbl2str_4464)) / StrToDouble(dbl2str_4472)) / MarketInfo(Gs_308, MODE_POINT), 2);
      Ld_4488 = f0_1(StrToDouble(dbl2str_4480));
      if (Ld_4488 < 6.0 && Ld_4488 > 3.0) Gi_956 = 0;
      if (Ld_4488 >= 6.0) Gi_956 = 3;
      if (Ld_4488 >= 7.0) Gi_956 = 6;
      if (Ld_4488 >= 8.0) Gi_956 = 8;
      if (Ld_4488 >= 9.0) Gi_956 = 10;
      if (Ld_4488 <= 3.0) Gi_956 = -3;
      if (Ld_4488 <= 2.0) Gi_956 = -6;
      if (Ld_4488 <= 1.0) Gi_956 = -8;
      if (Ld_4488 <= 0.0) Gi_956 = -10;
      if (Ld_4488 <= 2.0) Gi_unused_592 = G_color_824;
      if (Ld_4488 > 2.0 && Ld_4488 < 7.0) Gi_unused_592 = G_color_920;
      if (Ld_4488 >= 7.0) Gi_unused_592 = G_color_672;
      RefreshRates();
      idemarker_4496 = iDeMarker(Gs_308, G_timeframe_360, G_period_424, 0);
      idemarker_4504 = iDeMarker(Gs_308, G_timeframe_360, G_period_424, 10);
      if (idemarker_4496 > idemarker_4504 && idemarker_4496 >= 0.5) {
         Gi_532 = 4;
         Gs_unused_524 = "55";
      } else {
         if (idemarker_4496 < idemarker_4504 && idemarker_4496 < 0.5) {
            Gi_532 = -4;
            Gs_unused_524 = "66";
         } else {
            Gi_532 = 0;
            Gs_unused_524 = ";;";
         }
      }
      if (idemarker_4496 > idemarker_4504 && idemarker_4496 >= 0.5 && Ld_4416 >= 50.0) {
         Gi_unused_596 = G_color_684;
         Gi_unused_620 = Gi_332;
      } else {
         if (idemarker_4496 < idemarker_4504 && idemarker_4496 < 0.5 && Ld_4424 > 50.0) {
            Gi_unused_596 = G_color_812;
            Gi_unused_620 = Gi_332;
         } else {
            Gi_unused_596 = G_color_908;
            Gi_unused_620 = Gi_756;
         }
      }
      imfi_4512 = iMFI(Gs_308, G_timeframe_484, 14, 0);
      if (imfi_4512 >= 61.0) {
         Gi_544 = 4;
         Gs_unused_536 = "55";
      } else {
         if (imfi_4512 <= 39.0) {
            Gi_544 = -4;
            Gs_unused_536 = "66";
         } else {
            Gi_544 = 0;
            Gs_unused_536 = ";;";
         }
      }
      if (imfi_4512 >= 61.0 && Ld_4416 >= 50.0) {
         Gi_unused_600 = G_color_700;
         Gi_unused_624 = Gi_332;
      } else {
         if (imfi_4512 <= 39.0 && Ld_4424 > 50.0) {
            Gi_unused_600 = G_color_796;
            Gi_unused_624 = Gi_332;
         } else {
            Gi_unused_600 = G_color_892;
            Gi_unused_624 = Gi_756;
         }
      }
      irvi_4520 = iRVI(Gs_308, G_timeframe_360, 10, MODE_MAIN, 0);
      irvi_4528 = iRVI(Gs_308, G_timeframe_360, 10, MODE_SIGNAL, 0);
      if (irvi_4520 < 0.0 && irvi_4520 < irvi_4528) {
         Gi_556 = -4;
         Gs_unused_548 = "66";
      } else {
         if (irvi_4520 >= 0.0 && irvi_4520 > irvi_4528) {
            Gi_556 = 4;
            Gs_unused_548 = "55";
         } else {
            Gi_556 = 0;
            Gs_unused_548 = ";;";
         }
      }
      if (irvi_4520 < 0.0 && irvi_4520 < irvi_4528 && Ld_4424 > 50.0) {
         Gi_unused_604 = G_color_780;
         Gi_unused_628 = Gi_332;
      } else {
         if (irvi_4520 >= 0.0 && irvi_4520 > irvi_4528 && Ld_4416 >= 50.0) {
            Gi_unused_604 = G_color_708;
            Gi_unused_628 = Gi_332;
         } else {
            Gi_unused_604 = G_color_876;
            Gi_unused_628 = Gi_756;
         }
      }
      iao_4536 = iAO(Gs_308, G_timeframe_484, 0);
      iao_4544 = iAO(Gs_308, G_timeframe_484, 1);
      if (iao_4536 >= 0.00005 && iao_4536 > iao_4544) {
         Gi_576 = 4;
         Gs_unused_560 = "55";
      } else {
         if (iao_4536 < -0.00005 && iao_4536 < iao_4544) {
            Gi_576 = -4;
            Gs_unused_560 = "66";
         } else {
            Gi_576 = 0;
            Gs_unused_560 = ";;";
         }
      }
      if (iao_4536 >= 0.00005 && iao_4536 > iao_4544 && Ld_4416 >= 50.0) {
         Gi_unused_608 = G_color_724;
         Gi_unused_632 = Gi_332;
      } else {
         if (iao_4536 < -0.00005 && iao_4536 < iao_4544 && Ld_4424 > 50.0) {
            Gi_unused_608 = G_color_764;
            Gi_unused_632 = Gi_332;
         } else {
            Gi_unused_608 = G_color_860;
            Gi_unused_632 = Gi_756;
         }
      }
      Li_4552 = Gi_952 + Gi_956 + Gi_532 + Gi_544 + Gi_556 + Gi_576;
      Ld_4556 = 100.0 * (MathAbs(Li_4552) / 73.0);
      if (Li_4552 > 0) Gs_unused_960 = "BUY";
      if (Li_4552 < 0) Gs_unused_960 = "SELL";
      Ls_4564 = Ls_2648;
      if (Ld_4556 >= 96.0 && Ld_4556 <= 100.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_748;
         color_2452 = G_color_644;
         color_2456 = G_color_648;
         color_2460 = G_color_652;
         color_2464 = G_color_656;
         color_2468 = G_color_660;
         color_2472 = G_color_664;
         color_2476 = G_color_668;
         color_2480 = G_color_672;
         color_2484 = G_color_676;
         color_2488 = G_color_680;
         color_2492 = G_color_684;
         color_2496 = G_color_688;
         color_2500 = G_color_692;
         color_2504 = G_color_696;
         color_2508 = G_color_700;
         color_2512 = G_color_704;
         color_2516 = G_color_708;
         color_2520 = G_color_712;
         color_2524 = G_color_716;
         color_2528 = G_color_720;
         color_2532 = G_color_724;
         color_2536 = G_color_728;
         color_2540 = G_color_732;
      }
      if (Ld_4556 >= 92.0 && Ld_4556 < 96.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_856;
         color_2452 = G_color_748;
         color_2456 = G_color_648;
         color_2460 = G_color_652;
         color_2464 = G_color_656;
         color_2468 = G_color_660;
         color_2472 = G_color_664;
         color_2476 = G_color_668;
         color_2480 = G_color_672;
         color_2484 = G_color_676;
         color_2488 = G_color_680;
         color_2492 = G_color_684;
         color_2496 = G_color_688;
         color_2500 = G_color_692;
         color_2504 = G_color_696;
         color_2508 = G_color_700;
         color_2512 = G_color_704;
         color_2516 = G_color_708;
         color_2520 = G_color_712;
         color_2524 = G_color_716;
         color_2528 = G_color_720;
         color_2532 = G_color_724;
         color_2536 = G_color_728;
         color_2540 = G_color_732;
      }
      if (Ld_4556 >= 88.0 && Ld_4556 < 92.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_856;
         color_2452 = G_color_860;
         color_2456 = G_color_748;
         color_2460 = G_color_652;
         color_2464 = G_color_656;
         color_2468 = G_color_660;
         color_2472 = G_color_664;
         color_2476 = G_color_668;
         color_2480 = G_color_672;
         color_2484 = G_color_676;
         color_2488 = G_color_680;
         color_2492 = G_color_684;
         color_2496 = G_color_688;
         color_2500 = G_color_692;
         color_2504 = G_color_696;
         color_2508 = G_color_700;
         color_2512 = G_color_704;
         color_2516 = G_color_708;
         color_2520 = G_color_712;
         color_2524 = G_color_716;
         color_2528 = G_color_720;
         color_2532 = G_color_724;
         color_2536 = G_color_728;
         color_2540 = G_color_732;
      }
      if (Ld_4556 >= 84.0 && Ld_4556 < 88.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_856;
         color_2452 = G_color_860;
         color_2456 = G_color_864;
         color_2460 = G_color_748;
         color_2464 = G_color_656;
         color_2468 = G_color_660;
         color_2472 = G_color_664;
         color_2476 = G_color_668;
         color_2480 = G_color_672;
         color_2484 = G_color_676;
         color_2488 = G_color_680;
         color_2492 = G_color_684;
         color_2496 = G_color_688;
         color_2500 = G_color_692;
         color_2504 = G_color_696;
         color_2508 = G_color_700;
         color_2512 = G_color_704;
         color_2516 = G_color_708;
         color_2520 = G_color_712;
         color_2524 = G_color_716;
         color_2528 = G_color_720;
         color_2532 = G_color_724;
         color_2536 = G_color_728;
         color_2540 = G_color_732;
      }
      if (Ld_4556 >= 80.0 && Ld_4556 < 84.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_856;
         color_2452 = G_color_860;
         color_2456 = G_color_864;
         color_2460 = G_color_868;
         color_2464 = G_color_748;
         color_2468 = G_color_660;
         color_2472 = G_color_664;
         color_2476 = G_color_668;
         color_2480 = G_color_672;
         color_2484 = G_color_676;
         color_2488 = G_color_680;
         color_2492 = G_color_684;
         color_2496 = G_color_688;
         color_2500 = G_color_692;
         color_2504 = G_color_696;
         color_2508 = G_color_700;
         color_2512 = G_color_704;
         color_2516 = G_color_708;
         color_2520 = G_color_712;
         color_2524 = G_color_716;
         color_2528 = G_color_720;
         color_2532 = G_color_724;
         color_2536 = G_color_728;
         color_2540 = G_color_732;
      }
      if (Ld_4556 >= 76.0 && Ld_4556 < 80.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_856;
         color_2452 = G_color_860;
         color_2456 = G_color_864;
         color_2460 = G_color_868;
         color_2464 = G_color_872;
         color_2468 = G_color_748;
         color_2472 = G_color_664;
         color_2476 = G_color_668;
         color_2480 = G_color_672;
         color_2484 = G_color_676;
         color_2488 = G_color_680;
         color_2492 = G_color_684;
         color_2496 = G_color_688;
         color_2500 = G_color_692;
         color_2504 = G_color_696;
         color_2508 = G_color_700;
         color_2512 = G_color_704;
         color_2516 = G_color_708;
         color_2520 = G_color_712;
         color_2524 = G_color_716;
         color_2528 = G_color_720;
         color_2532 = G_color_724;
         color_2536 = G_color_728;
         color_2540 = G_color_732;
      }
      if (Ld_4556 >= 72.0 && Ld_4556 < 76.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_856;
         color_2452 = G_color_860;
         color_2456 = G_color_864;
         color_2460 = G_color_868;
         color_2464 = G_color_872;
         color_2468 = G_color_876;
         color_2472 = G_color_748;
         color_2476 = G_color_668;
         color_2480 = G_color_672;
         color_2484 = G_color_676;
         color_2488 = G_color_680;
         color_2492 = G_color_684;
         color_2496 = G_color_688;
         color_2500 = G_color_692;
         color_2504 = G_color_696;
         color_2508 = G_color_700;
         color_2512 = G_color_704;
         color_2516 = G_color_708;
         color_2520 = G_color_712;
         color_2524 = G_color_716;
         color_2528 = G_color_720;
         color_2532 = G_color_724;
         color_2536 = G_color_728;
         color_2540 = G_color_732;
      }
      if (Ld_4556 >= 68.0 && Ld_4556 < 72.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_856;
         color_2452 = G_color_860;
         color_2456 = G_color_864;
         color_2460 = G_color_868;
         color_2464 = G_color_872;
         color_2468 = G_color_876;
         color_2472 = G_color_880;
         color_2476 = G_color_748;
         color_2480 = G_color_672;
         color_2484 = G_color_676;
         color_2488 = G_color_680;
         color_2492 = G_color_684;
         color_2496 = G_color_688;
         color_2500 = G_color_692;
         color_2504 = G_color_696;
         color_2508 = G_color_700;
         color_2512 = G_color_704;
         color_2516 = G_color_708;
         color_2520 = G_color_712;
         color_2524 = G_color_716;
         color_2528 = G_color_720;
         color_2532 = G_color_724;
         color_2536 = G_color_728;
         color_2540 = G_color_732;
      }
      if (Ld_4556 >= 64.0 && Ld_4556 < 68.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_856;
         color_2452 = G_color_860;
         color_2456 = G_color_864;
         color_2460 = G_color_868;
         color_2464 = G_color_872;
         color_2468 = G_color_876;
         color_2472 = G_color_880;
         color_2476 = G_color_884;
         color_2480 = G_color_748;
         color_2484 = G_color_676;
         color_2488 = G_color_680;
         color_2492 = G_color_684;
         color_2496 = G_color_688;
         color_2500 = G_color_692;
         color_2504 = G_color_696;
         color_2508 = G_color_700;
         color_2512 = G_color_704;
         color_2516 = G_color_708;
         color_2520 = G_color_712;
         color_2524 = G_color_716;
         color_2528 = G_color_720;
         color_2532 = G_color_724;
         color_2536 = G_color_728;
         color_2540 = G_color_732;
      }
      if (Ld_4556 >= 60.0 && Ld_4556 < 64.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_856;
         color_2452 = G_color_860;
         color_2456 = G_color_864;
         color_2460 = G_color_868;
         color_2464 = G_color_872;
         color_2468 = G_color_876;
         color_2472 = G_color_880;
         color_2476 = G_color_884;
         color_2480 = G_color_888;
         color_2484 = G_color_748;
         color_2488 = G_color_680;
         color_2492 = G_color_684;
         color_2496 = G_color_688;
         color_2500 = G_color_692;
         color_2504 = G_color_696;
         color_2508 = G_color_700;
         color_2512 = G_color_704;
         color_2516 = G_color_708;
         color_2520 = G_color_712;
         color_2524 = G_color_716;
         color_2528 = G_color_720;
         color_2532 = G_color_724;
         color_2536 = G_color_728;
         color_2540 = G_color_732;
      }
      if (Ld_4556 >= 56.0 && Ld_4556 < 60.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_856;
         color_2452 = G_color_860;
         color_2456 = G_color_864;
         color_2460 = G_color_868;
         color_2464 = G_color_872;
         color_2468 = G_color_876;
         color_2472 = G_color_880;
         color_2476 = G_color_884;
         color_2480 = G_color_888;
         color_2484 = G_color_892;
         color_2488 = G_color_748;
         color_2492 = G_color_684;
         color_2496 = G_color_688;
         color_2500 = G_color_692;
         color_2504 = G_color_696;
         color_2508 = G_color_700;
         color_2512 = G_color_704;
         color_2516 = G_color_708;
         color_2520 = G_color_712;
         color_2524 = G_color_716;
         color_2528 = G_color_720;
         color_2532 = G_color_724;
         color_2536 = G_color_728;
         color_2540 = G_color_732;
      }
      if (Ld_4556 >= 52.0 && Ld_4556 < 56.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_856;
         color_2452 = G_color_860;
         color_2456 = G_color_864;
         color_2460 = G_color_868;
         color_2464 = G_color_872;
         color_2468 = G_color_876;
         color_2472 = G_color_880;
         color_2476 = G_color_884;
         color_2480 = G_color_888;
         color_2484 = G_color_892;
         color_2488 = G_color_896;
         color_2492 = G_color_748;
         color_2496 = G_color_688;
         color_2500 = G_color_692;
         color_2504 = G_color_696;
         color_2508 = G_color_700;
         color_2512 = G_color_704;
         color_2516 = G_color_708;
         color_2520 = G_color_712;
         color_2524 = G_color_716;
         color_2528 = G_color_720;
         color_2532 = G_color_724;
         color_2536 = G_color_728;
         color_2540 = G_color_732;
      }
      if (Ld_4556 >= 48.0 && Ld_4556 < 52.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_856;
         color_2452 = G_color_860;
         color_2456 = G_color_864;
         color_2460 = G_color_868;
         color_2464 = G_color_872;
         color_2468 = G_color_876;
         color_2472 = G_color_880;
         color_2476 = G_color_884;
         color_2480 = G_color_888;
         color_2484 = G_color_892;
         color_2488 = G_color_896;
         color_2492 = G_color_900;
         color_2496 = G_color_748;
         color_2500 = G_color_692;
         color_2504 = G_color_696;
         color_2508 = G_color_700;
         color_2512 = G_color_704;
         color_2516 = G_color_708;
         color_2520 = G_color_712;
         color_2524 = G_color_716;
         color_2528 = G_color_720;
         color_2532 = G_color_724;
         color_2536 = G_color_728;
         color_2540 = G_color_732;
      }
      if (Ld_4556 >= 44.0 && Ld_4556 < 48.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_856;
         color_2452 = G_color_860;
         color_2456 = G_color_864;
         color_2460 = G_color_868;
         color_2464 = G_color_872;
         color_2468 = G_color_876;
         color_2472 = G_color_880;
         color_2476 = G_color_884;
         color_2480 = G_color_888;
         color_2484 = G_color_892;
         color_2488 = G_color_896;
         color_2492 = G_color_900;
         color_2496 = G_color_904;
         color_2500 = G_color_748;
         color_2504 = G_color_696;
         color_2508 = G_color_700;
         color_2512 = G_color_704;
         color_2516 = G_color_708;
         color_2520 = G_color_712;
         color_2524 = G_color_716;
         color_2528 = G_color_720;
         color_2532 = G_color_724;
         color_2536 = G_color_728;
         color_2540 = G_color_732;
      }
      if (Ld_4556 >= 39.0 && Ld_4556 < 44.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_856;
         color_2452 = G_color_860;
         color_2456 = G_color_864;
         color_2460 = G_color_868;
         color_2464 = G_color_872;
         color_2468 = G_color_876;
         color_2472 = G_color_880;
         color_2476 = G_color_884;
         color_2480 = G_color_888;
         color_2484 = G_color_892;
         color_2488 = G_color_896;
         color_2492 = G_color_900;
         color_2496 = G_color_904;
         color_2500 = G_color_908;
         color_2504 = G_color_748;
         color_2508 = G_color_700;
         color_2512 = G_color_704;
         color_2516 = G_color_708;
         color_2520 = G_color_712;
         color_2524 = G_color_716;
         color_2528 = G_color_720;
         color_2532 = G_color_724;
         color_2536 = G_color_728;
         color_2540 = G_color_732;
      }
      if (Ld_4556 >= 34.0 && Ld_4556 < 39.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_856;
         color_2452 = G_color_860;
         color_2456 = G_color_864;
         color_2460 = G_color_868;
         color_2464 = G_color_872;
         color_2468 = G_color_876;
         color_2472 = G_color_880;
         color_2476 = G_color_884;
         color_2480 = G_color_888;
         color_2484 = G_color_892;
         color_2488 = G_color_896;
         color_2492 = G_color_900;
         color_2496 = G_color_904;
         color_2500 = G_color_908;
         color_2504 = G_color_912;
         color_2508 = G_color_748;
         color_2512 = G_color_704;
         color_2516 = G_color_708;
         color_2520 = G_color_712;
         color_2524 = G_color_716;
         color_2528 = G_color_720;
         color_2532 = G_color_724;
         color_2536 = G_color_728;
         color_2540 = G_color_732;
      }
      if (Ld_4556 >= 28.0 && Ld_4556 < 34.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_856;
         color_2452 = G_color_860;
         color_2456 = G_color_864;
         color_2460 = G_color_868;
         color_2464 = G_color_872;
         color_2468 = G_color_876;
         color_2472 = G_color_880;
         color_2476 = G_color_884;
         color_2480 = G_color_888;
         color_2484 = G_color_892;
         color_2488 = G_color_896;
         color_2492 = G_color_900;
         color_2496 = G_color_904;
         color_2500 = G_color_908;
         color_2504 = G_color_912;
         color_2508 = G_color_916;
         color_2512 = G_color_748;
         color_2516 = G_color_708;
         color_2520 = G_color_712;
         color_2524 = G_color_716;
         color_2528 = G_color_720;
         color_2532 = G_color_724;
         color_2536 = G_color_728;
         color_2540 = G_color_732;
      }
      if (Ld_4556 >= 22.0 && Ld_4556 < 28.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_856;
         color_2452 = G_color_860;
         color_2456 = G_color_864;
         color_2460 = G_color_868;
         color_2464 = G_color_872;
         color_2468 = G_color_876;
         color_2472 = G_color_880;
         color_2476 = G_color_884;
         color_2480 = G_color_888;
         color_2484 = G_color_892;
         color_2488 = G_color_896;
         color_2492 = G_color_900;
         color_2496 = G_color_904;
         color_2500 = G_color_908;
         color_2504 = G_color_912;
         color_2508 = G_color_916;
         color_2512 = G_color_920;
         color_2516 = G_color_748;
         color_2520 = G_color_712;
         color_2524 = G_color_716;
         color_2528 = G_color_720;
         color_2532 = G_color_724;
         color_2536 = G_color_728;
         color_2540 = G_color_732;
      }
      if (Ld_4556 >= 18.0 && Ld_4556 < 22.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_856;
         color_2452 = G_color_860;
         color_2456 = G_color_864;
         color_2460 = G_color_868;
         color_2464 = G_color_872;
         color_2468 = G_color_876;
         color_2472 = G_color_880;
         color_2476 = G_color_884;
         color_2480 = G_color_888;
         color_2484 = G_color_892;
         color_2488 = G_color_896;
         color_2492 = G_color_900;
         color_2496 = G_color_904;
         color_2500 = G_color_908;
         color_2504 = G_color_912;
         color_2508 = G_color_916;
         color_2512 = G_color_920;
         color_2516 = G_color_924;
         color_2520 = G_color_748;
         color_2524 = G_color_716;
         color_2528 = G_color_720;
         color_2532 = G_color_724;
         color_2536 = G_color_728;
         color_2540 = G_color_732;
      }
      if (Ld_4556 >= 14.0 && Ld_4556 < 18.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_856;
         color_2452 = G_color_860;
         color_2456 = G_color_864;
         color_2460 = G_color_868;
         color_2464 = G_color_872;
         color_2468 = G_color_876;
         color_2472 = G_color_880;
         color_2476 = G_color_884;
         color_2480 = G_color_888;
         color_2484 = G_color_892;
         color_2488 = G_color_896;
         color_2492 = G_color_900;
         color_2496 = G_color_904;
         color_2500 = G_color_908;
         color_2504 = G_color_912;
         color_2508 = G_color_916;
         color_2512 = G_color_920;
         color_2516 = G_color_924;
         color_2520 = G_color_928;
         color_2524 = G_color_748;
         color_2528 = G_color_720;
         color_2532 = G_color_724;
         color_2536 = G_color_728;
         color_2540 = G_color_732;
      }
      if (Ld_4556 >= 12.0 && Ld_4556 < 14.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_856;
         color_2452 = G_color_860;
         color_2456 = G_color_864;
         color_2460 = G_color_868;
         color_2464 = G_color_872;
         color_2468 = G_color_876;
         color_2472 = G_color_880;
         color_2476 = G_color_884;
         color_2480 = G_color_888;
         color_2484 = G_color_892;
         color_2488 = G_color_896;
         color_2492 = G_color_900;
         color_2496 = G_color_904;
         color_2500 = G_color_908;
         color_2504 = G_color_912;
         color_2508 = G_color_916;
         color_2512 = G_color_920;
         color_2516 = G_color_924;
         color_2520 = G_color_928;
         color_2524 = G_color_932;
         color_2528 = G_color_748;
         color_2532 = G_color_724;
         color_2536 = G_color_728;
         color_2540 = G_color_732;
      }
      if (Ld_4556 >= 8.0 && Ld_4556 < 12.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_856;
         color_2452 = G_color_860;
         color_2456 = G_color_864;
         color_2460 = G_color_868;
         color_2464 = G_color_872;
         color_2468 = G_color_876;
         color_2472 = G_color_880;
         color_2476 = G_color_884;
         color_2480 = G_color_888;
         color_2484 = G_color_892;
         color_2488 = G_color_896;
         color_2492 = G_color_900;
         color_2496 = G_color_904;
         color_2500 = G_color_908;
         color_2504 = G_color_912;
         color_2508 = G_color_916;
         color_2512 = G_color_920;
         color_2516 = G_color_924;
         color_2520 = G_color_928;
         color_2524 = G_color_932;
         color_2528 = G_color_936;
         color_2532 = G_color_748;
         color_2536 = G_color_728;
         color_2540 = G_color_732;
      }
      if (Ld_4556 >= 4.0 && Ld_4556 < 8.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_856;
         color_2452 = G_color_860;
         color_2456 = G_color_864;
         color_2460 = G_color_868;
         color_2464 = G_color_872;
         color_2468 = G_color_876;
         color_2472 = G_color_880;
         color_2476 = G_color_884;
         color_2480 = G_color_888;
         color_2484 = G_color_892;
         color_2488 = G_color_896;
         color_2492 = G_color_900;
         color_2496 = G_color_904;
         color_2500 = G_color_908;
         color_2504 = G_color_912;
         color_2508 = G_color_916;
         color_2512 = G_color_920;
         color_2516 = G_color_924;
         color_2520 = G_color_928;
         color_2524 = G_color_932;
         color_2528 = G_color_936;
         color_2532 = G_color_940;
         color_2536 = G_color_748;
         color_2540 = G_color_732;
      }
      if (Ld_4556 >= 0.0 && Ld_4556 < 4.0 && Li_4552 >= 0) {
         Ls_unused_2340 = "5";
         color_2444 = G_color_664;
         color_2448 = G_color_856;
         color_2452 = G_color_860;
         color_2456 = G_color_864;
         color_2460 = G_color_868;
         color_2464 = G_color_872;
         color_2468 = G_color_876;
         color_2472 = G_color_880;
         color_2476 = G_color_884;
         color_2480 = G_color_888;
         color_2484 = G_color_892;
         color_2488 = G_color_896;
         color_2492 = G_color_900;
         color_2496 = G_color_904;
         color_2500 = G_color_908;
         color_2504 = G_color_912;
         color_2508 = G_color_916;
         color_2512 = G_color_920;
         color_2516 = G_color_924;
         color_2520 = G_color_928;
         color_2524 = G_color_932;
         color_2528 = G_color_936;
         color_2532 = G_color_940;
         color_2536 = G_color_944;
         color_2540 = G_color_748;
      }
      if (Ld_4556 >= 96.0 && Ld_4556 <= 100.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_852;
         color_2452 = G_color_848;
         color_2456 = G_color_844;
         color_2460 = G_color_840;
         color_2464 = G_color_836;
         color_2468 = G_color_832;
         color_2472 = G_color_828;
         color_2476 = G_color_824;
         color_2480 = G_color_820;
         color_2484 = G_color_816;
         color_2488 = G_color_812;
         color_2492 = G_color_808;
         color_2496 = G_color_804;
         color_2500 = G_color_800;
         color_2504 = G_color_796;
         color_2508 = G_color_792;
         color_2512 = G_color_788;
         color_2516 = G_color_784;
         color_2520 = G_color_780;
         color_2524 = G_color_776;
         color_2528 = G_color_772;
         color_2532 = G_color_768;
         color_2536 = G_color_764;
         color_2540 = G_color_752;
      }
      if (Ld_4556 >= 92.0 && Ld_4556 < 96.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_852;
         color_2452 = G_color_848;
         color_2456 = G_color_844;
         color_2460 = G_color_840;
         color_2464 = G_color_836;
         color_2468 = G_color_832;
         color_2472 = G_color_828;
         color_2476 = G_color_824;
         color_2480 = G_color_820;
         color_2484 = G_color_816;
         color_2488 = G_color_812;
         color_2492 = G_color_808;
         color_2496 = G_color_804;
         color_2500 = G_color_800;
         color_2504 = G_color_796;
         color_2508 = G_color_792;
         color_2512 = G_color_788;
         color_2516 = G_color_784;
         color_2520 = G_color_780;
         color_2524 = G_color_776;
         color_2528 = G_color_772;
         color_2532 = G_color_768;
         color_2536 = G_color_752;
         color_2540 = G_color_856;
      }
      if (Ld_4556 >= 88.0 && Ld_4556 < 92.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_852;
         color_2452 = G_color_848;
         color_2456 = G_color_844;
         color_2460 = G_color_840;
         color_2464 = G_color_836;
         color_2468 = G_color_832;
         color_2472 = G_color_828;
         color_2476 = G_color_824;
         color_2480 = G_color_820;
         color_2484 = G_color_816;
         color_2488 = G_color_812;
         color_2492 = G_color_808;
         color_2496 = G_color_804;
         color_2500 = G_color_800;
         color_2504 = G_color_796;
         color_2508 = G_color_792;
         color_2512 = G_color_788;
         color_2516 = G_color_784;
         color_2520 = G_color_780;
         color_2524 = G_color_776;
         color_2528 = G_color_772;
         color_2532 = G_color_752;
         color_2536 = G_color_860;
         color_2540 = G_color_856;
      }
      if (Ld_4556 >= 84.0 && Ld_4556 < 88.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_852;
         color_2452 = G_color_848;
         color_2456 = G_color_844;
         color_2460 = G_color_840;
         color_2464 = G_color_836;
         color_2468 = G_color_832;
         color_2472 = G_color_828;
         color_2476 = G_color_824;
         color_2480 = G_color_820;
         color_2484 = G_color_816;
         color_2488 = G_color_812;
         color_2492 = G_color_808;
         color_2496 = G_color_804;
         color_2500 = G_color_800;
         color_2504 = G_color_796;
         color_2508 = G_color_792;
         color_2512 = G_color_788;
         color_2516 = G_color_784;
         color_2520 = G_color_780;
         color_2524 = G_color_776;
         color_2528 = G_color_752;
         color_2532 = G_color_864;
         color_2536 = G_color_860;
         color_2540 = G_color_856;
      }
      if (Ld_4556 >= 80.0 && Ld_4556 < 84.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_852;
         color_2452 = G_color_848;
         color_2456 = G_color_844;
         color_2460 = G_color_840;
         color_2464 = G_color_836;
         color_2468 = G_color_832;
         color_2472 = G_color_828;
         color_2476 = G_color_824;
         color_2480 = G_color_820;
         color_2484 = G_color_816;
         color_2488 = G_color_812;
         color_2492 = G_color_808;
         color_2496 = G_color_804;
         color_2500 = G_color_800;
         color_2504 = G_color_796;
         color_2508 = G_color_792;
         color_2512 = G_color_788;
         color_2516 = G_color_784;
         color_2520 = G_color_780;
         color_2524 = G_color_752;
         color_2528 = G_color_868;
         color_2532 = G_color_864;
         color_2536 = G_color_860;
         color_2540 = G_color_856;
      }
      if (Ld_4556 >= 76.0 && Ld_4556 < 80.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_852;
         color_2452 = G_color_848;
         color_2456 = G_color_844;
         color_2460 = G_color_840;
         color_2464 = G_color_836;
         color_2468 = G_color_832;
         color_2472 = G_color_828;
         color_2476 = G_color_824;
         color_2480 = G_color_820;
         color_2484 = G_color_816;
         color_2488 = G_color_812;
         color_2492 = G_color_808;
         color_2496 = G_color_804;
         color_2500 = G_color_800;
         color_2504 = G_color_796;
         color_2508 = G_color_792;
         color_2512 = G_color_788;
         color_2516 = G_color_784;
         color_2520 = G_color_752;
         color_2524 = G_color_872;
         color_2528 = G_color_868;
         color_2532 = G_color_864;
         color_2536 = G_color_860;
         color_2540 = G_color_856;
      }
      if (Ld_4556 >= 72.0 && Ld_4556 < 76.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_852;
         color_2452 = G_color_848;
         color_2456 = G_color_844;
         color_2460 = G_color_840;
         color_2464 = G_color_836;
         color_2468 = G_color_832;
         color_2472 = G_color_828;
         color_2476 = G_color_824;
         color_2480 = G_color_820;
         color_2484 = G_color_816;
         color_2488 = G_color_812;
         color_2492 = G_color_808;
         color_2496 = G_color_804;
         color_2500 = G_color_800;
         color_2504 = G_color_796;
         color_2508 = G_color_792;
         color_2512 = G_color_788;
         color_2516 = G_color_752;
         color_2520 = G_color_876;
         color_2524 = G_color_872;
         color_2528 = G_color_868;
         color_2532 = G_color_864;
         color_2536 = G_color_860;
         color_2540 = G_color_856;
      }
      if (Ld_4556 >= 68.0 && Ld_4556 < 72.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_852;
         color_2452 = G_color_848;
         color_2456 = G_color_844;
         color_2460 = G_color_840;
         color_2464 = G_color_836;
         color_2468 = G_color_832;
         color_2472 = G_color_828;
         color_2476 = G_color_824;
         color_2480 = G_color_820;
         color_2484 = G_color_816;
         color_2488 = G_color_812;
         color_2492 = G_color_808;
         color_2496 = G_color_804;
         color_2500 = G_color_800;
         color_2504 = G_color_796;
         color_2508 = G_color_792;
         color_2512 = G_color_752;
         color_2516 = G_color_880;
         color_2520 = G_color_876;
         color_2524 = G_color_872;
         color_2528 = G_color_868;
         color_2532 = G_color_864;
         color_2536 = G_color_860;
         color_2540 = G_color_856;
      }
      if (Ld_4556 >= 64.0 && Ld_4556 < 68.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_852;
         color_2452 = G_color_848;
         color_2456 = G_color_844;
         color_2460 = G_color_840;
         color_2464 = G_color_836;
         color_2468 = G_color_832;
         color_2472 = G_color_828;
         color_2476 = G_color_824;
         color_2480 = G_color_820;
         color_2484 = G_color_816;
         color_2488 = G_color_812;
         color_2492 = G_color_808;
         color_2496 = G_color_804;
         color_2500 = G_color_800;
         color_2504 = G_color_796;
         color_2508 = G_color_752;
         color_2512 = G_color_884;
         color_2516 = G_color_880;
         color_2520 = G_color_876;
         color_2524 = G_color_872;
         color_2528 = G_color_868;
         color_2532 = G_color_864;
         color_2536 = G_color_860;
         color_2540 = G_color_856;
      }
      if (Ld_4556 >= 60.0 && Ld_4556 < 64.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_852;
         color_2452 = G_color_848;
         color_2456 = G_color_844;
         color_2460 = G_color_840;
         color_2464 = G_color_836;
         color_2468 = G_color_832;
         color_2472 = G_color_828;
         color_2476 = G_color_824;
         color_2480 = G_color_820;
         color_2484 = G_color_816;
         color_2488 = G_color_812;
         color_2492 = G_color_808;
         color_2496 = G_color_804;
         color_2500 = G_color_800;
         color_2504 = G_color_752;
         color_2508 = G_color_888;
         color_2512 = G_color_884;
         color_2516 = G_color_880;
         color_2520 = G_color_876;
         color_2524 = G_color_872;
         color_2528 = G_color_868;
         color_2532 = G_color_864;
         color_2536 = G_color_860;
         color_2540 = G_color_856;
      }
      if (Ld_4556 >= 56.0 && Ld_4556 < 60.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_852;
         color_2452 = G_color_848;
         color_2456 = G_color_844;
         color_2460 = G_color_840;
         color_2464 = G_color_836;
         color_2468 = G_color_832;
         color_2472 = G_color_828;
         color_2476 = G_color_824;
         color_2480 = G_color_820;
         color_2484 = G_color_816;
         color_2488 = G_color_812;
         color_2492 = G_color_808;
         color_2496 = G_color_804;
         color_2500 = G_color_752;
         color_2504 = G_color_892;
         color_2508 = G_color_888;
         color_2512 = G_color_884;
         color_2516 = G_color_880;
         color_2520 = G_color_876;
         color_2524 = G_color_872;
         color_2528 = G_color_868;
         color_2532 = G_color_864;
         color_2536 = G_color_860;
         color_2540 = G_color_856;
      }
      if (Ld_4556 >= 52.0 && Ld_4556 < 56.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_852;
         color_2452 = G_color_848;
         color_2456 = G_color_844;
         color_2460 = G_color_840;
         color_2464 = G_color_836;
         color_2468 = G_color_832;
         color_2472 = G_color_828;
         color_2476 = G_color_824;
         color_2480 = G_color_820;
         color_2484 = G_color_816;
         color_2488 = G_color_812;
         color_2492 = G_color_808;
         color_2496 = G_color_752;
         color_2500 = G_color_896;
         color_2504 = G_color_892;
         color_2508 = G_color_888;
         color_2512 = G_color_884;
         color_2516 = G_color_880;
         color_2520 = G_color_876;
         color_2524 = G_color_872;
         color_2528 = G_color_868;
         color_2532 = G_color_864;
         color_2536 = G_color_860;
         color_2540 = G_color_856;
      }
      if (Ld_4556 >= 48.0 && Ld_4556 < 52.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_852;
         color_2452 = G_color_848;
         color_2456 = G_color_844;
         color_2460 = G_color_840;
         color_2464 = G_color_836;
         color_2468 = G_color_832;
         color_2472 = G_color_828;
         color_2476 = G_color_824;
         color_2480 = G_color_820;
         color_2484 = G_color_816;
         color_2488 = G_color_812;
         color_2492 = G_color_752;
         color_2496 = G_color_900;
         color_2500 = G_color_896;
         color_2504 = G_color_892;
         color_2508 = G_color_888;
         color_2512 = G_color_884;
         color_2516 = G_color_880;
         color_2520 = G_color_876;
         color_2524 = G_color_872;
         color_2528 = G_color_868;
         color_2532 = G_color_864;
         color_2536 = G_color_860;
         color_2540 = G_color_856;
      }
      if (Ld_4556 >= 44.0 && Ld_4556 < 48.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_852;
         color_2452 = G_color_848;
         color_2456 = G_color_844;
         color_2460 = G_color_840;
         color_2464 = G_color_836;
         color_2468 = G_color_832;
         color_2472 = G_color_828;
         color_2476 = G_color_824;
         color_2480 = G_color_820;
         color_2484 = G_color_816;
         color_2488 = G_color_752;
         color_2492 = G_color_904;
         color_2496 = G_color_900;
         color_2500 = G_color_896;
         color_2504 = G_color_892;
         color_2508 = G_color_888;
         color_2512 = G_color_884;
         color_2516 = G_color_880;
         color_2520 = G_color_876;
         color_2524 = G_color_872;
         color_2528 = G_color_868;
         color_2532 = G_color_864;
         color_2536 = G_color_860;
         color_2540 = G_color_856;
      }
      if (Ld_4556 >= 39.0 && Ld_4556 < 44.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_852;
         color_2452 = G_color_848;
         color_2456 = G_color_844;
         color_2460 = G_color_840;
         color_2464 = G_color_836;
         color_2468 = G_color_832;
         color_2472 = G_color_828;
         color_2476 = G_color_824;
         color_2480 = G_color_820;
         color_2484 = G_color_752;
         color_2488 = G_color_908;
         color_2492 = G_color_904;
         color_2496 = G_color_900;
         color_2500 = G_color_896;
         color_2504 = G_color_892;
         color_2508 = G_color_888;
         color_2512 = G_color_884;
         color_2516 = G_color_880;
         color_2520 = G_color_876;
         color_2524 = G_color_872;
         color_2528 = G_color_868;
         color_2532 = G_color_864;
         color_2536 = G_color_860;
         color_2540 = G_color_856;
      }
      if (Ld_4556 >= 34.0 && Ld_4556 < 39.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_852;
         color_2452 = G_color_848;
         color_2456 = G_color_844;
         color_2460 = G_color_840;
         color_2464 = G_color_836;
         color_2468 = G_color_832;
         color_2472 = G_color_828;
         color_2476 = G_color_824;
         color_2480 = G_color_752;
         color_2484 = G_color_912;
         color_2488 = G_color_908;
         color_2492 = G_color_904;
         color_2496 = G_color_900;
         color_2500 = G_color_896;
         color_2504 = G_color_892;
         color_2508 = G_color_888;
         color_2512 = G_color_884;
         color_2516 = G_color_880;
         color_2520 = G_color_876;
         color_2524 = G_color_872;
         color_2528 = G_color_868;
         color_2532 = G_color_864;
         color_2536 = G_color_860;
         color_2540 = G_color_856;
      }
      if (Ld_4556 >= 28.0 && Ld_4556 < 34.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_852;
         color_2452 = G_color_848;
         color_2456 = G_color_844;
         color_2460 = G_color_840;
         color_2464 = G_color_836;
         color_2468 = G_color_832;
         color_2472 = G_color_828;
         color_2476 = G_color_752;
         color_2480 = G_color_916;
         color_2484 = G_color_912;
         color_2488 = G_color_908;
         color_2492 = G_color_904;
         color_2496 = G_color_900;
         color_2500 = G_color_896;
         color_2504 = G_color_892;
         color_2508 = G_color_888;
         color_2512 = G_color_884;
         color_2516 = G_color_880;
         color_2520 = G_color_876;
         color_2524 = G_color_872;
         color_2528 = G_color_868;
         color_2532 = G_color_864;
         color_2536 = G_color_860;
         color_2540 = G_color_856;
      }
      if (Ld_4556 >= 22.0 && Ld_4556 < 28.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_852;
         color_2452 = G_color_848;
         color_2456 = G_color_844;
         color_2460 = G_color_840;
         color_2464 = G_color_836;
         color_2468 = G_color_832;
         color_2472 = G_color_752;
         color_2476 = G_color_920;
         color_2480 = G_color_916;
         color_2484 = G_color_912;
         color_2488 = G_color_908;
         color_2492 = G_color_904;
         color_2496 = G_color_900;
         color_2500 = G_color_896;
         color_2504 = G_color_892;
         color_2508 = G_color_888;
         color_2512 = G_color_884;
         color_2516 = G_color_880;
         color_2520 = G_color_876;
         color_2524 = G_color_872;
         color_2528 = G_color_868;
         color_2532 = G_color_864;
         color_2536 = G_color_860;
         color_2540 = G_color_856;
      }
      if (Ld_4556 >= 18.0 && Ld_4556 < 22.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_852;
         color_2452 = G_color_848;
         color_2456 = G_color_844;
         color_2460 = G_color_840;
         color_2464 = G_color_836;
         color_2468 = G_color_752;
         color_2472 = G_color_924;
         color_2476 = G_color_920;
         color_2480 = G_color_916;
         color_2484 = G_color_912;
         color_2488 = G_color_908;
         color_2492 = G_color_904;
         color_2496 = G_color_900;
         color_2500 = G_color_896;
         color_2504 = G_color_892;
         color_2508 = G_color_888;
         color_2512 = G_color_884;
         color_2516 = G_color_880;
         color_2520 = G_color_876;
         color_2524 = G_color_872;
         color_2528 = G_color_868;
         color_2532 = G_color_864;
         color_2536 = G_color_860;
         color_2540 = G_color_856;
      }
      if (Ld_4556 >= 14.0 && Ld_4556 < 18.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_852;
         color_2452 = G_color_848;
         color_2456 = G_color_844;
         color_2460 = G_color_840;
         color_2464 = G_color_752;
         color_2468 = G_color_928;
         color_2472 = G_color_924;
         color_2476 = G_color_920;
         color_2480 = G_color_916;
         color_2484 = G_color_912;
         color_2488 = G_color_908;
         color_2492 = G_color_904;
         color_2496 = G_color_900;
         color_2500 = G_color_896;
         color_2504 = G_color_892;
         color_2508 = G_color_888;
         color_2512 = G_color_884;
         color_2516 = G_color_880;
         color_2520 = G_color_876;
         color_2524 = G_color_872;
         color_2528 = G_color_868;
         color_2532 = G_color_864;
         color_2536 = G_color_860;
         color_2540 = G_color_856;
      }
      if (Ld_4556 >= 12.0 && Ld_4556 < 14.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_852;
         color_2452 = G_color_848;
         color_2456 = G_color_844;
         color_2460 = G_color_752;
         color_2464 = G_color_932;
         color_2468 = G_color_928;
         color_2472 = G_color_924;
         color_2476 = G_color_920;
         color_2480 = G_color_916;
         color_2484 = G_color_912;
         color_2488 = G_color_908;
         color_2492 = G_color_904;
         color_2496 = G_color_900;
         color_2500 = G_color_896;
         color_2504 = G_color_892;
         color_2508 = G_color_888;
         color_2512 = G_color_884;
         color_2516 = G_color_880;
         color_2520 = G_color_876;
         color_2524 = G_color_872;
         color_2528 = G_color_868;
         color_2532 = G_color_864;
         color_2536 = G_color_860;
         color_2540 = G_color_856;
      }
      if (Ld_4556 >= 8.0 && Ld_4556 < 12.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_852;
         color_2452 = G_color_848;
         color_2456 = G_color_752;
         color_2460 = G_color_936;
         color_2464 = G_color_932;
         color_2468 = G_color_928;
         color_2472 = G_color_924;
         color_2476 = G_color_920;
         color_2480 = G_color_916;
         color_2484 = G_color_912;
         color_2488 = G_color_908;
         color_2492 = G_color_904;
         color_2496 = G_color_900;
         color_2500 = G_color_896;
         color_2504 = G_color_892;
         color_2508 = G_color_888;
         color_2512 = G_color_884;
         color_2516 = G_color_880;
         color_2520 = G_color_876;
         color_2524 = G_color_872;
         color_2528 = G_color_868;
         color_2532 = G_color_864;
         color_2536 = G_color_860;
         color_2540 = G_color_856;
      }
      if (Ld_4556 >= 4.0 && Ld_4556 < 8.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_852;
         color_2452 = G_color_752;
         color_2456 = G_color_940;
         color_2460 = G_color_936;
         color_2464 = G_color_932;
         color_2468 = G_color_928;
         color_2472 = G_color_924;
         color_2476 = G_color_920;
         color_2480 = G_color_916;
         color_2484 = G_color_912;
         color_2488 = G_color_908;
         color_2492 = G_color_904;
         color_2496 = G_color_900;
         color_2500 = G_color_896;
         color_2504 = G_color_892;
         color_2508 = G_color_888;
         color_2512 = G_color_884;
         color_2516 = G_color_880;
         color_2520 = G_color_876;
         color_2524 = G_color_872;
         color_2528 = G_color_868;
         color_2532 = G_color_864;
         color_2536 = G_color_860;
         color_2540 = G_color_856;
      }
      if (Ld_4556 >= 0.0 && Ld_4556 < 4.0 && Li_4552 < 0) {
         Ls_unused_2340 = "6";
         color_2444 = G_color_760;
         color_2448 = G_color_752;
         color_2452 = G_color_944;
         color_2456 = G_color_940;
         color_2460 = G_color_936;
         color_2464 = G_color_932;
         color_2468 = G_color_928;
         color_2472 = G_color_924;
         color_2476 = G_color_920;
         color_2480 = G_color_916;
         color_2484 = G_color_912;
         color_2488 = G_color_908;
         color_2492 = G_color_904;
         color_2496 = G_color_900;
         color_2500 = G_color_896;
         color_2504 = G_color_892;
         color_2508 = G_color_888;
         color_2512 = G_color_884;
         color_2516 = G_color_880;
         color_2520 = G_color_876;
         color_2524 = G_color_872;
         color_2528 = G_color_868;
         color_2532 = G_color_864;
         color_2536 = G_color_860;
         color_2540 = G_color_856;
      }
      if (Ld_4416 >= 97.0) {
         color_2348 = G_color_748;
         color_2352 = G_color_644;
         color_2356 = G_color_648;
         color_2360 = G_color_652;
         color_2364 = G_color_656;
         color_2368 = G_color_660;
         color_2372 = G_color_664;
         color_2376 = G_color_668;
         color_2380 = G_color_672;
         color_2384 = G_color_676;
         color_2388 = G_color_680;
         color_2392 = G_color_684;
         color_2396 = G_color_688;
         color_2400 = G_color_692;
         color_2404 = G_color_696;
         color_2408 = G_color_700;
         color_2412 = G_color_704;
         color_2416 = G_color_708;
         color_2420 = G_color_712;
         color_2424 = G_color_716;
         color_2428 = G_color_720;
         color_2432 = G_color_724;
         color_2436 = G_color_728;
         color_2440 = G_color_732;
      }
      if (Ld_4416 >= 95.0 && Ld_4416 < 97.0) {
         color_2348 = G_color_856;
         color_2352 = G_color_748;
         color_2356 = G_color_648;
         color_2360 = G_color_652;
         color_2364 = G_color_656;
         color_2368 = G_color_660;
         color_2372 = G_color_664;
         color_2376 = G_color_668;
         color_2380 = G_color_672;
         color_2384 = G_color_676;
         color_2388 = G_color_680;
         color_2392 = G_color_684;
         color_2396 = G_color_688;
         color_2400 = G_color_692;
         color_2404 = G_color_696;
         color_2408 = G_color_700;
         color_2412 = G_color_704;
         color_2416 = G_color_708;
         color_2420 = G_color_712;
         color_2424 = G_color_716;
         color_2428 = G_color_720;
         color_2432 = G_color_724;
         color_2436 = G_color_728;
         color_2440 = G_color_732;
      }
      if (Ld_4416 >= 93.0 && Ld_4416 < 95.0) {
         color_2348 = G_color_856;
         color_2352 = G_color_860;
         color_2356 = G_color_748;
         color_2360 = G_color_652;
         color_2364 = G_color_656;
         color_2368 = G_color_660;
         color_2372 = G_color_664;
         color_2376 = G_color_668;
         color_2380 = G_color_672;
         color_2384 = G_color_676;
         color_2388 = G_color_680;
         color_2392 = G_color_684;
         color_2396 = G_color_688;
         color_2400 = G_color_692;
         color_2404 = G_color_696;
         color_2408 = G_color_700;
         color_2412 = G_color_704;
         color_2416 = G_color_708;
         color_2420 = G_color_712;
         color_2424 = G_color_716;
         color_2428 = G_color_720;
         color_2432 = G_color_724;
         color_2436 = G_color_728;
         color_2440 = G_color_732;
      }
      if (Ld_4416 >= 91.0 && Ld_4416 < 93.0) {
         color_2348 = G_color_856;
         color_2352 = G_color_860;
         color_2356 = G_color_864;
         color_2360 = G_color_748;
         color_2364 = G_color_656;
         color_2368 = G_color_660;
         color_2372 = G_color_664;
         color_2376 = G_color_668;
         color_2380 = G_color_672;
         color_2384 = G_color_676;
         color_2388 = G_color_680;
         color_2392 = G_color_684;
         color_2396 = G_color_688;
         color_2400 = G_color_692;
         color_2404 = G_color_696;
         color_2408 = G_color_700;
         color_2412 = G_color_704;
         color_2416 = G_color_708;
         color_2420 = G_color_712;
         color_2424 = G_color_716;
         color_2428 = G_color_720;
         color_2432 = G_color_724;
         color_2436 = G_color_728;
         color_2440 = G_color_732;
      }
      if (Ld_4416 >= 89.0 && Ld_4416 < 91.0) {
         color_2348 = G_color_856;
         color_2352 = G_color_860;
         color_2356 = G_color_864;
         color_2360 = G_color_868;
         color_2364 = G_color_748;
         color_2368 = G_color_660;
         color_2372 = G_color_664;
         color_2376 = G_color_668;
         color_2380 = G_color_672;
         color_2384 = G_color_676;
         color_2388 = G_color_680;
         color_2392 = G_color_684;
         color_2396 = G_color_688;
         color_2400 = G_color_692;
         color_2404 = G_color_696;
         color_2408 = G_color_700;
         color_2412 = G_color_704;
         color_2416 = G_color_708;
         color_2420 = G_color_712;
         color_2424 = G_color_716;
         color_2428 = G_color_720;
         color_2432 = G_color_724;
         color_2436 = G_color_728;
         color_2440 = G_color_732;
      }
      if (Ld_4416 >= 87.0 && Ld_4416 < 89.0) {
         color_2348 = G_color_856;
         color_2352 = G_color_860;
         color_2356 = G_color_864;
         color_2360 = G_color_868;
         color_2364 = G_color_872;
         color_2368 = G_color_748;
         color_2372 = G_color_664;
         color_2376 = G_color_668;
         color_2380 = G_color_672;
         color_2384 = G_color_676;
         color_2388 = G_color_680;
         color_2392 = G_color_684;
         color_2396 = G_color_688;
         color_2400 = G_color_692;
         color_2404 = G_color_696;
         color_2408 = G_color_700;
         color_2412 = G_color_704;
         color_2416 = G_color_708;
         color_2420 = G_color_712;
         color_2424 = G_color_716;
         color_2428 = G_color_720;
         color_2432 = G_color_724;
         color_2436 = G_color_728;
         color_2440 = G_color_732;
      }
      if (Ld_4416 >= 85.0 && Ld_4416 < 87.0) {
         color_2348 = G_color_856;
         color_2352 = G_color_860;
         color_2356 = G_color_864;
         color_2360 = G_color_868;
         color_2364 = G_color_872;
         color_2368 = G_color_876;
         color_2372 = G_color_748;
         color_2376 = G_color_668;
         color_2380 = G_color_672;
         color_2384 = G_color_676;
         color_2388 = G_color_680;
         color_2392 = G_color_684;
         color_2396 = G_color_688;
         color_2400 = G_color_692;
         color_2404 = G_color_696;
         color_2408 = G_color_700;
         color_2412 = G_color_704;
         color_2416 = G_color_708;
         color_2420 = G_color_712;
         color_2424 = G_color_716;
         color_2428 = G_color_720;
         color_2432 = G_color_724;
         color_2436 = G_color_728;
         color_2440 = G_color_732;
      }
      if (Ld_4416 >= 83.0 && Ld_4416 < 85.0) {
         color_2348 = G_color_856;
         color_2352 = G_color_860;
         color_2356 = G_color_864;
         color_2360 = G_color_868;
         color_2364 = G_color_872;
         color_2368 = G_color_876;
         color_2372 = G_color_880;
         color_2376 = G_color_748;
         color_2380 = G_color_672;
         color_2384 = G_color_676;
         color_2388 = G_color_680;
         color_2392 = G_color_684;
         color_2396 = G_color_688;
         color_2400 = G_color_692;
         color_2404 = G_color_696;
         color_2408 = G_color_700;
         color_2412 = G_color_704;
         color_2416 = G_color_708;
         color_2420 = G_color_712;
         color_2424 = G_color_716;
         color_2428 = G_color_720;
         color_2432 = G_color_724;
         color_2436 = G_color_728;
         color_2440 = G_color_732;
      }
      if (Ld_4416 >= 81.0 && Ld_4416 < 83.0) {
         color_2348 = G_color_856;
         color_2352 = G_color_860;
         color_2356 = G_color_864;
         color_2360 = G_color_868;
         color_2364 = G_color_872;
         color_2368 = G_color_876;
         color_2372 = G_color_880;
         color_2376 = G_color_884;
         color_2380 = G_color_748;
         color_2384 = G_color_676;
         color_2388 = G_color_680;
         color_2392 = G_color_684;
         color_2396 = G_color_688;
         color_2400 = G_color_692;
         color_2404 = G_color_696;
         color_2408 = G_color_700;
         color_2412 = G_color_704;
         color_2416 = G_color_708;
         color_2420 = G_color_712;
         color_2424 = G_color_716;
         color_2428 = G_color_720;
         color_2432 = G_color_724;
         color_2436 = G_color_728;
         color_2440 = G_color_732;
      }
      if (Ld_4416 >= 79.0 && Ld_4416 < 81.0) {
         color_2348 = G_color_856;
         color_2352 = G_color_860;
         color_2356 = G_color_864;
         color_2360 = G_color_868;
         color_2364 = G_color_872;
         color_2368 = G_color_876;
         color_2372 = G_color_880;
         color_2376 = G_color_884;
         color_2380 = G_color_888;
         color_2384 = G_color_748;
         color_2388 = G_color_680;
         color_2392 = G_color_684;
         color_2396 = G_color_688;
         color_2400 = G_color_692;
         color_2404 = G_color_696;
         color_2408 = G_color_700;
         color_2412 = G_color_704;
         color_2416 = G_color_708;
         color_2420 = G_color_712;
         color_2424 = G_color_716;
         color_2428 = G_color_720;
         color_2432 = G_color_724;
         color_2436 = G_color_728;
         color_2440 = G_color_732;
      }
      if (Ld_4416 >= 77.0 && Ld_4416 < 79.0) {
         color_2348 = G_color_856;
         color_2352 = G_color_860;
         color_2356 = G_color_864;
         color_2360 = G_color_868;
         color_2364 = G_color_872;
         color_2368 = G_color_876;
         color_2372 = G_color_880;
         color_2376 = G_color_884;
         color_2380 = G_color_888;
         color_2384 = G_color_892;
         color_2388 = G_color_748;
         color_2392 = G_color_684;
         color_2396 = G_color_688;
         color_2400 = G_color_692;
         color_2404 = G_color_696;
         color_2408 = G_color_700;
         color_2412 = G_color_704;
         color_2416 = G_color_708;
         color_2420 = G_color_712;
         color_2424 = G_color_716;
         color_2428 = G_color_720;
         color_2432 = G_color_724;
         color_2436 = G_color_728;
         color_2440 = G_color_732;
      }
      if (Ld_4416 >= 75.0 && Ld_4416 < 77.0) {
         color_2348 = G_color_856;
         color_2352 = G_color_860;
         color_2356 = G_color_864;
         color_2360 = G_color_868;
         color_2364 = G_color_872;
         color_2368 = G_color_876;
         color_2372 = G_color_880;
         color_2376 = G_color_884;
         color_2380 = G_color_888;
         color_2384 = G_color_892;
         color_2388 = G_color_896;
         color_2392 = G_color_748;
         color_2396 = G_color_688;
         color_2400 = G_color_692;
         color_2404 = G_color_696;
         color_2408 = G_color_700;
         color_2412 = G_color_704;
         color_2416 = G_color_708;
         color_2420 = G_color_712;
         color_2424 = G_color_716;
         color_2428 = G_color_720;
         color_2432 = G_color_724;
         color_2436 = G_color_728;
         color_2440 = G_color_732;
      }
      if (Ld_4416 >= 73.0 && Ld_4416 < 75.0) {
         color_2348 = G_color_856;
         color_2352 = G_color_860;
         color_2356 = G_color_864;
         color_2360 = G_color_868;
         color_2364 = G_color_872;
         color_2368 = G_color_876;
         color_2372 = G_color_880;
         color_2376 = G_color_884;
         color_2380 = G_color_888;
         color_2384 = G_color_892;
         color_2388 = G_color_896;
         color_2392 = G_color_900;
         color_2396 = G_color_748;
         color_2400 = G_color_692;
         color_2404 = G_color_696;
         color_2408 = G_color_700;
         color_2412 = G_color_704;
         color_2416 = G_color_708;
         color_2420 = G_color_712;
         color_2424 = G_color_716;
         color_2428 = G_color_720;
         color_2432 = G_color_724;
         color_2436 = G_color_728;
         color_2440 = G_color_732;
      }
      if (Ld_4416 >= 71.0 && Ld_4416 < 73.0) {
         color_2348 = G_color_856;
         color_2352 = G_color_860;
         color_2356 = G_color_864;
         color_2360 = G_color_868;
         color_2364 = G_color_872;
         color_2368 = G_color_876;
         color_2372 = G_color_880;
         color_2376 = G_color_884;
         color_2380 = G_color_888;
         color_2384 = G_color_892;
         color_2388 = G_color_896;
         color_2392 = G_color_900;
         color_2396 = G_color_904;
         color_2400 = G_color_748;
         color_2404 = G_color_696;
         color_2408 = G_color_700;
         color_2412 = G_color_704;
         color_2416 = G_color_708;
         color_2420 = G_color_712;
         color_2424 = G_color_716;
         color_2428 = G_color_720;
         color_2432 = G_color_724;
         color_2436 = G_color_728;
         color_2440 = G_color_732;
      }
      if (Ld_4416 >= 69.0 && Ld_4416 < 71.0) {
         color_2348 = G_color_856;
         color_2352 = G_color_860;
         color_2356 = G_color_864;
         color_2360 = G_color_868;
         color_2364 = G_color_872;
         color_2368 = G_color_876;
         color_2372 = G_color_880;
         color_2376 = G_color_884;
         color_2380 = G_color_888;
         color_2384 = G_color_892;
         color_2388 = G_color_896;
         color_2392 = G_color_900;
         color_2396 = G_color_904;
         color_2400 = G_color_908;
         color_2404 = G_color_748;
         color_2408 = G_color_700;
         color_2412 = G_color_704;
         color_2416 = G_color_708;
         color_2420 = G_color_712;
         color_2424 = G_color_716;
         color_2428 = G_color_720;
         color_2432 = G_color_724;
         color_2436 = G_color_728;
         color_2440 = G_color_732;
      }
      if (Ld_4416 >= 67.0 && Ld_4416 < 69.0) {
         color_2348 = G_color_856;
         color_2352 = G_color_860;
         color_2356 = G_color_864;
         color_2360 = G_color_868;
         color_2364 = G_color_872;
         color_2368 = G_color_876;
         color_2372 = G_color_880;
         color_2376 = G_color_884;
         color_2380 = G_color_888;
         color_2384 = G_color_892;
         color_2388 = G_color_896;
         color_2392 = G_color_900;
         color_2396 = G_color_904;
         color_2400 = G_color_908;
         color_2404 = G_color_912;
         color_2408 = G_color_748;
         color_2412 = G_color_704;
         color_2416 = G_color_708;
         color_2420 = G_color_712;
         color_2424 = G_color_716;
         color_2428 = G_color_720;
         color_2432 = G_color_724;
         color_2436 = G_color_728;
         color_2440 = G_color_732;
      }
      if (Ld_4416 >= 65.0 && Ld_4416 < 67.0) {
         color_2348 = G_color_856;
         color_2352 = G_color_860;
         color_2356 = G_color_864;
         color_2360 = G_color_868;
         color_2364 = G_color_872;
         color_2368 = G_color_876;
         color_2372 = G_color_880;
         color_2376 = G_color_884;
         color_2380 = G_color_888;
         color_2384 = G_color_892;
         color_2388 = G_color_896;
         color_2392 = G_color_900;
         color_2396 = G_color_904;
         color_2400 = G_color_908;
         color_2404 = G_color_912;
         color_2408 = G_color_916;
         color_2412 = G_color_748;
         color_2416 = G_color_708;
         color_2420 = G_color_712;
         color_2424 = G_color_716;
         color_2428 = G_color_720;
         color_2432 = G_color_724;
         color_2436 = G_color_728;
         color_2440 = G_color_732;
      }
      if (Ld_4416 >= 63.0 && Ld_4416 < 65.0) {
         color_2348 = G_color_856;
         color_2352 = G_color_860;
         color_2356 = G_color_864;
         color_2360 = G_color_868;
         color_2364 = G_color_872;
         color_2368 = G_color_876;
         color_2372 = G_color_880;
         color_2376 = G_color_884;
         color_2380 = G_color_888;
         color_2384 = G_color_892;
         color_2388 = G_color_896;
         color_2392 = G_color_900;
         color_2396 = G_color_904;
         color_2400 = G_color_908;
         color_2404 = G_color_912;
         color_2408 = G_color_916;
         color_2412 = G_color_920;
         color_2416 = G_color_748;
         color_2420 = G_color_712;
         color_2424 = G_color_716;
         color_2428 = G_color_720;
         color_2432 = G_color_724;
         color_2436 = G_color_728;
         color_2440 = G_color_732;
      }
      if (Ld_4416 >= 61.0 && Ld_4416 < 63.0) {
         color_2348 = G_color_856;
         color_2352 = G_color_860;
         color_2356 = G_color_864;
         color_2360 = G_color_868;
         color_2364 = G_color_872;
         color_2368 = G_color_876;
         color_2372 = G_color_880;
         color_2376 = G_color_884;
         color_2380 = G_color_888;
         color_2384 = G_color_892;
         color_2388 = G_color_896;
         color_2392 = G_color_900;
         color_2396 = G_color_904;
         color_2400 = G_color_908;
         color_2404 = G_color_912;
         color_2408 = G_color_916;
         color_2412 = G_color_920;
         color_2416 = G_color_924;
         color_2420 = G_color_748;
         color_2424 = G_color_716;
         color_2428 = G_color_720;
         color_2432 = G_color_724;
         color_2436 = G_color_728;
         color_2440 = G_color_732;
      }
      if (Ld_4416 >= 59.0 && Ld_4416 < 61.0) {
         color_2348 = G_color_856;
         color_2352 = G_color_860;
         color_2356 = G_color_864;
         color_2360 = G_color_868;
         color_2364 = G_color_872;
         color_2368 = G_color_876;
         color_2372 = G_color_880;
         color_2376 = G_color_884;
         color_2380 = G_color_888;
         color_2384 = G_color_892;
         color_2388 = G_color_896;
         color_2392 = G_color_900;
         color_2396 = G_color_904;
         color_2400 = G_color_908;
         color_2404 = G_color_912;
         color_2408 = G_color_916;
         color_2412 = G_color_920;
         color_2416 = G_color_924;
         color_2420 = G_color_928;
         color_2424 = G_color_748;
         color_2428 = G_color_720;
         color_2432 = G_color_724;
         color_2436 = G_color_728;
         color_2440 = G_color_732;
      }
      if (Ld_4416 >= 57.0 && Ld_4416 < 59.0) {
         color_2348 = G_color_856;
         color_2352 = G_color_860;
         color_2356 = G_color_864;
         color_2360 = G_color_868;
         color_2364 = G_color_872;
         color_2368 = G_color_876;
         color_2372 = G_color_880;
         color_2376 = G_color_884;
         color_2380 = G_color_888;
         color_2384 = G_color_892;
         color_2388 = G_color_896;
         color_2392 = G_color_900;
         color_2396 = G_color_904;
         color_2400 = G_color_908;
         color_2404 = G_color_912;
         color_2408 = G_color_916;
         color_2412 = G_color_920;
         color_2416 = G_color_924;
         color_2420 = G_color_928;
         color_2424 = G_color_932;
         color_2428 = G_color_748;
         color_2432 = G_color_724;
         color_2436 = G_color_728;
         color_2440 = G_color_732;
      }
      if (Ld_4416 >= 55.0 && Ld_4416 < 57.0) {
         color_2348 = G_color_856;
         color_2352 = G_color_860;
         color_2356 = G_color_864;
         color_2360 = G_color_868;
         color_2364 = G_color_872;
         color_2368 = G_color_876;
         color_2372 = G_color_880;
         color_2376 = G_color_884;
         color_2380 = G_color_888;
         color_2384 = G_color_892;
         color_2388 = G_color_896;
         color_2392 = G_color_900;
         color_2396 = G_color_904;
         color_2400 = G_color_908;
         color_2404 = G_color_912;
         color_2408 = G_color_916;
         color_2412 = G_color_920;
         color_2416 = G_color_924;
         color_2420 = G_color_928;
         color_2424 = G_color_932;
         color_2428 = G_color_936;
         color_2432 = G_color_748;
         color_2436 = G_color_728;
         color_2440 = G_color_732;
      }
      if (Ld_4416 >= 53.0 && Ld_4416 < 55.0) {
         color_2348 = G_color_856;
         color_2352 = G_color_860;
         color_2356 = G_color_864;
         color_2360 = G_color_868;
         color_2364 = G_color_872;
         color_2368 = G_color_876;
         color_2372 = G_color_880;
         color_2376 = G_color_884;
         color_2380 = G_color_888;
         color_2384 = G_color_892;
         color_2388 = G_color_896;
         color_2392 = G_color_900;
         color_2396 = G_color_904;
         color_2400 = G_color_908;
         color_2404 = G_color_912;
         color_2408 = G_color_916;
         color_2412 = G_color_920;
         color_2416 = G_color_924;
         color_2420 = G_color_928;
         color_2424 = G_color_932;
         color_2428 = G_color_936;
         color_2432 = G_color_940;
         color_2436 = G_color_748;
         color_2440 = G_color_732;
      }
      if (Ld_4416 >= 49.0 && Ld_4416 < 53.0) {
         color_2348 = G_color_856;
         color_2352 = G_color_860;
         color_2356 = G_color_864;
         color_2360 = G_color_868;
         color_2364 = G_color_872;
         color_2368 = G_color_876;
         color_2372 = G_color_880;
         color_2376 = G_color_884;
         color_2380 = G_color_888;
         color_2384 = G_color_892;
         color_2388 = G_color_896;
         color_2392 = G_color_900;
         color_2396 = G_color_904;
         color_2400 = G_color_908;
         color_2404 = G_color_912;
         color_2408 = G_color_916;
         color_2412 = G_color_920;
         color_2416 = G_color_924;
         color_2420 = G_color_928;
         color_2424 = G_color_932;
         color_2428 = G_color_936;
         color_2432 = G_color_940;
         color_2436 = G_color_944;
         color_2440 = G_color_748;
      }
      if (Ld_4424 >= 97.0) {
         color_2348 = G_color_852;
         color_2352 = G_color_848;
         color_2356 = G_color_844;
         color_2360 = G_color_840;
         color_2364 = G_color_836;
         color_2368 = G_color_832;
         color_2372 = G_color_828;
         color_2376 = G_color_824;
         color_2380 = G_color_820;
         color_2384 = G_color_816;
         color_2388 = G_color_812;
         color_2392 = G_color_808;
         color_2396 = G_color_804;
         color_2400 = G_color_800;
         color_2404 = G_color_796;
         color_2408 = G_color_792;
         color_2412 = G_color_788;
         color_2416 = G_color_784;
         color_2420 = G_color_780;
         color_2424 = G_color_776;
         color_2428 = G_color_772;
         color_2432 = G_color_768;
         color_2436 = G_color_764;
         color_2440 = G_color_752;
      }
      if (Ld_4424 >= 95.0 && Ld_4424 < 97.0) {
         color_2348 = G_color_852;
         color_2352 = G_color_848;
         color_2356 = G_color_844;
         color_2360 = G_color_840;
         color_2364 = G_color_836;
         color_2368 = G_color_832;
         color_2372 = G_color_828;
         color_2376 = G_color_824;
         color_2380 = G_color_820;
         color_2384 = G_color_816;
         color_2388 = G_color_812;
         color_2392 = G_color_808;
         color_2396 = G_color_804;
         color_2400 = G_color_800;
         color_2404 = G_color_796;
         color_2408 = G_color_792;
         color_2412 = G_color_788;
         color_2416 = G_color_784;
         color_2420 = G_color_780;
         color_2424 = G_color_776;
         color_2428 = G_color_772;
         color_2432 = G_color_768;
         color_2436 = G_color_752;
         color_2440 = G_color_856;
      }
      if (Ld_4424 >= 93.0 && Ld_4424 < 95.0) {
         color_2348 = G_color_852;
         color_2352 = G_color_848;
         color_2356 = G_color_844;
         color_2360 = G_color_840;
         color_2364 = G_color_836;
         color_2368 = G_color_832;
         color_2372 = G_color_828;
         color_2376 = G_color_824;
         color_2380 = G_color_820;
         color_2384 = G_color_816;
         color_2388 = G_color_812;
         color_2392 = G_color_808;
         color_2396 = G_color_804;
         color_2400 = G_color_800;
         color_2404 = G_color_796;
         color_2408 = G_color_792;
         color_2412 = G_color_788;
         color_2416 = G_color_784;
         color_2420 = G_color_780;
         color_2424 = G_color_776;
         color_2428 = G_color_772;
         color_2432 = G_color_752;
         color_2436 = G_color_860;
         color_2440 = G_color_856;
      }
      if (Ld_4424 >= 91.0 && Ld_4424 < 93.0) {
         color_2348 = G_color_852;
         color_2352 = G_color_848;
         color_2356 = G_color_844;
         color_2360 = G_color_840;
         color_2364 = G_color_836;
         color_2368 = G_color_832;
         color_2372 = G_color_828;
         color_2376 = G_color_824;
         color_2380 = G_color_820;
         color_2384 = G_color_816;
         color_2388 = G_color_812;
         color_2392 = G_color_808;
         color_2396 = G_color_804;
         color_2400 = G_color_800;
         color_2404 = G_color_796;
         color_2408 = G_color_792;
         color_2412 = G_color_788;
         color_2416 = G_color_784;
         color_2420 = G_color_780;
         color_2424 = G_color_776;
         color_2428 = G_color_752;
         color_2432 = G_color_864;
         color_2436 = G_color_860;
         color_2440 = G_color_856;
      }
      if (Ld_4424 >= 89.0 && Ld_4424 < 91.0) {
         color_2348 = G_color_852;
         color_2352 = G_color_848;
         color_2356 = G_color_844;
         color_2360 = G_color_840;
         color_2364 = G_color_836;
         color_2368 = G_color_832;
         color_2372 = G_color_828;
         color_2376 = G_color_824;
         color_2380 = G_color_820;
         color_2384 = G_color_816;
         color_2388 = G_color_812;
         color_2392 = G_color_808;
         color_2396 = G_color_804;
         color_2400 = G_color_800;
         color_2404 = G_color_796;
         color_2408 = G_color_792;
         color_2412 = G_color_788;
         color_2416 = G_color_784;
         color_2420 = G_color_780;
         color_2424 = G_color_752;
         color_2428 = G_color_868;
         color_2432 = G_color_864;
         color_2436 = G_color_860;
         color_2440 = G_color_856;
      }
      if (Ld_4424 >= 87.0 && Ld_4424 < 89.0) {
         color_2348 = G_color_852;
         color_2352 = G_color_848;
         color_2356 = G_color_844;
         color_2360 = G_color_840;
         color_2364 = G_color_836;
         color_2368 = G_color_832;
         color_2372 = G_color_828;
         color_2376 = G_color_824;
         color_2380 = G_color_820;
         color_2384 = G_color_816;
         color_2388 = G_color_812;
         color_2392 = G_color_808;
         color_2396 = G_color_804;
         color_2400 = G_color_800;
         color_2404 = G_color_796;
         color_2408 = G_color_792;
         color_2412 = G_color_788;
         color_2416 = G_color_784;
         color_2420 = G_color_752;
         color_2424 = G_color_872;
         color_2428 = G_color_868;
         color_2432 = G_color_864;
         color_2436 = G_color_860;
         color_2440 = G_color_856;
      }
      if (Ld_4424 >= 85.0 && Ld_4424 < 87.0) {
         color_2348 = G_color_852;
         color_2352 = G_color_848;
         color_2356 = G_color_844;
         color_2360 = G_color_840;
         color_2364 = G_color_836;
         color_2368 = G_color_832;
         color_2372 = G_color_828;
         color_2376 = G_color_824;
         color_2380 = G_color_820;
         color_2384 = G_color_816;
         color_2388 = G_color_812;
         color_2392 = G_color_808;
         color_2396 = G_color_804;
         color_2400 = G_color_800;
         color_2404 = G_color_796;
         color_2408 = G_color_792;
         color_2412 = G_color_788;
         color_2416 = G_color_752;
         color_2420 = G_color_876;
         color_2424 = G_color_872;
         color_2428 = G_color_868;
         color_2432 = G_color_864;
         color_2436 = G_color_860;
         color_2440 = G_color_856;
      }
      if (Ld_4424 >= 83.0 && Ld_4424 < 85.0) {
         color_2348 = G_color_852;
         color_2352 = G_color_848;
         color_2356 = G_color_844;
         color_2360 = G_color_840;
         color_2364 = G_color_836;
         color_2368 = G_color_832;
         color_2372 = G_color_828;
         color_2376 = G_color_824;
         color_2380 = G_color_820;
         color_2384 = G_color_816;
         color_2388 = G_color_812;
         color_2392 = G_color_808;
         color_2396 = G_color_804;
         color_2400 = G_color_800;
         color_2404 = G_color_796;
         color_2408 = G_color_792;
         color_2412 = G_color_752;
         color_2416 = G_color_880;
         color_2420 = G_color_876;
         color_2424 = G_color_872;
         color_2428 = G_color_868;
         color_2432 = G_color_864;
         color_2436 = G_color_860;
         color_2440 = G_color_856;
      }
      if (Ld_4424 >= 81.0 && Ld_4424 < 83.0) {
         color_2348 = G_color_852;
         color_2352 = G_color_848;
         color_2356 = G_color_844;
         color_2360 = G_color_840;
         color_2364 = G_color_836;
         color_2368 = G_color_832;
         color_2372 = G_color_828;
         color_2376 = G_color_824;
         color_2380 = G_color_820;
         color_2384 = G_color_816;
         color_2388 = G_color_812;
         color_2392 = G_color_808;
         color_2396 = G_color_804;
         color_2400 = G_color_800;
         color_2404 = G_color_796;
         color_2408 = G_color_752;
         color_2412 = G_color_884;
         color_2416 = G_color_880;
         color_2420 = G_color_876;
         color_2424 = G_color_872;
         color_2428 = G_color_868;
         color_2432 = G_color_864;
         color_2436 = G_color_860;
         color_2440 = G_color_856;
      }
      if (Ld_4424 >= 79.0 && Ld_4424 < 81.0) {
         color_2348 = G_color_852;
         color_2352 = G_color_848;
         color_2356 = G_color_844;
         color_2360 = G_color_840;
         color_2364 = G_color_836;
         color_2368 = G_color_832;
         color_2372 = G_color_828;
         color_2376 = G_color_824;
         color_2380 = G_color_820;
         color_2384 = G_color_816;
         color_2388 = G_color_812;
         color_2392 = G_color_808;
         color_2396 = G_color_804;
         color_2400 = G_color_800;
         color_2404 = G_color_752;
         color_2408 = G_color_888;
         color_2412 = G_color_884;
         color_2416 = G_color_880;
         color_2420 = G_color_876;
         color_2424 = G_color_872;
         color_2428 = G_color_868;
         color_2432 = G_color_864;
         color_2436 = G_color_860;
         color_2440 = G_color_856;
      }
      if (Ld_4424 >= 77.0 && Ld_4424 < 79.0) {
         color_2348 = G_color_852;
         color_2352 = G_color_848;
         color_2356 = G_color_844;
         color_2360 = G_color_840;
         color_2364 = G_color_836;
         color_2368 = G_color_832;
         color_2372 = G_color_828;
         color_2376 = G_color_824;
         color_2380 = G_color_820;
         color_2384 = G_color_816;
         color_2388 = G_color_812;
         color_2392 = G_color_808;
         color_2396 = G_color_804;
         color_2400 = G_color_752;
         color_2404 = G_color_892;
         color_2408 = G_color_888;
         color_2412 = G_color_884;
         color_2416 = G_color_880;
         color_2420 = G_color_876;
         color_2424 = G_color_872;
         color_2428 = G_color_868;
         color_2432 = G_color_864;
         color_2436 = G_color_860;
         color_2440 = G_color_856;
      }
      if (Ld_4424 >= 75.0 && Ld_4424 < 77.0) {
         color_2348 = G_color_852;
         color_2352 = G_color_848;
         color_2356 = G_color_844;
         color_2360 = G_color_840;
         color_2364 = G_color_836;
         color_2368 = G_color_832;
         color_2372 = G_color_828;
         color_2376 = G_color_824;
         color_2380 = G_color_820;
         color_2384 = G_color_816;
         color_2388 = G_color_812;
         color_2392 = G_color_808;
         color_2396 = G_color_752;
         color_2400 = G_color_896;
         color_2404 = G_color_892;
         color_2408 = G_color_888;
         color_2412 = G_color_884;
         color_2416 = G_color_880;
         color_2420 = G_color_876;
         color_2424 = G_color_872;
         color_2428 = G_color_868;
         color_2432 = G_color_864;
         color_2436 = G_color_860;
         color_2440 = G_color_856;
      }
      if (Ld_4424 >= 73.0 && Ld_4424 < 75.0) {
         color_2348 = G_color_852;
         color_2352 = G_color_848;
         color_2356 = G_color_844;
         color_2360 = G_color_840;
         color_2364 = G_color_836;
         color_2368 = G_color_832;
         color_2372 = G_color_828;
         color_2376 = G_color_824;
         color_2380 = G_color_820;
         color_2384 = G_color_816;
         color_2388 = G_color_812;
         color_2392 = G_color_752;
         color_2396 = G_color_900;
         color_2400 = G_color_896;
         color_2404 = G_color_892;
         color_2408 = G_color_888;
         color_2412 = G_color_884;
         color_2416 = G_color_880;
         color_2420 = G_color_876;
         color_2424 = G_color_872;
         color_2428 = G_color_868;
         color_2432 = G_color_864;
         color_2436 = G_color_860;
         color_2440 = G_color_856;
      }
      if (Ld_4424 >= 71.0 && Ld_4424 < 73.0) {
         color_2348 = G_color_852;
         color_2352 = G_color_848;
         color_2356 = G_color_844;
         color_2360 = G_color_840;
         color_2364 = G_color_836;
         color_2368 = G_color_832;
         color_2372 = G_color_828;
         color_2376 = G_color_824;
         color_2380 = G_color_820;
         color_2384 = G_color_816;
         color_2388 = G_color_752;
         color_2392 = G_color_904;
         color_2396 = G_color_900;
         color_2400 = G_color_896;
         color_2404 = G_color_892;
         color_2408 = G_color_888;
         color_2412 = G_color_884;
         color_2416 = G_color_880;
         color_2420 = G_color_876;
         color_2424 = G_color_872;
         color_2428 = G_color_868;
         color_2432 = G_color_864;
         color_2436 = G_color_860;
         color_2440 = G_color_856;
      }
      if (Ld_4424 >= 69.0 && Ld_4424 < 71.0) {
         color_2348 = G_color_852;
         color_2352 = G_color_848;
         color_2356 = G_color_844;
         color_2360 = G_color_840;
         color_2364 = G_color_836;
         color_2368 = G_color_832;
         color_2372 = G_color_828;
         color_2376 = G_color_824;
         color_2380 = G_color_820;
         color_2384 = G_color_752;
         color_2388 = G_color_908;
         color_2392 = G_color_904;
         color_2396 = G_color_900;
         color_2400 = G_color_896;
         color_2404 = G_color_892;
         color_2408 = G_color_888;
         color_2412 = G_color_884;
         color_2416 = G_color_880;
         color_2420 = G_color_876;
         color_2424 = G_color_872;
         color_2428 = G_color_868;
         color_2432 = G_color_864;
         color_2436 = G_color_860;
         color_2440 = G_color_856;
      }
      if (Ld_4424 >= 67.0 && Ld_4424 < 69.0) {
         color_2348 = G_color_852;
         color_2352 = G_color_848;
         color_2356 = G_color_844;
         color_2360 = G_color_840;
         color_2364 = G_color_836;
         color_2368 = G_color_832;
         color_2372 = G_color_828;
         color_2376 = G_color_824;
         color_2380 = G_color_752;
         color_2384 = G_color_912;
         color_2388 = G_color_908;
         color_2392 = G_color_904;
         color_2396 = G_color_900;
         color_2400 = G_color_896;
         color_2404 = G_color_892;
         color_2408 = G_color_888;
         color_2412 = G_color_884;
         color_2416 = G_color_880;
         color_2420 = G_color_876;
         color_2424 = G_color_872;
         color_2428 = G_color_868;
         color_2432 = G_color_864;
         color_2436 = G_color_860;
         color_2440 = G_color_856;
      }
      if (Ld_4424 >= 65.0 && Ld_4424 < 67.0) {
         color_2348 = G_color_852;
         color_2352 = G_color_848;
         color_2356 = G_color_844;
         color_2360 = G_color_840;
         color_2364 = G_color_836;
         color_2368 = G_color_832;
         color_2372 = G_color_828;
         color_2376 = G_color_752;
         color_2380 = G_color_916;
         color_2384 = G_color_912;
         color_2388 = G_color_908;
         color_2392 = G_color_904;
         color_2396 = G_color_900;
         color_2400 = G_color_896;
         color_2404 = G_color_892;
         color_2408 = G_color_888;
         color_2412 = G_color_884;
         color_2416 = G_color_880;
         color_2420 = G_color_876;
         color_2424 = G_color_872;
         color_2428 = G_color_868;
         color_2432 = G_color_864;
         color_2436 = G_color_860;
         color_2440 = G_color_856;
      }
      if (Ld_4424 >= 63.0 && Ld_4424 < 65.0) {
         color_2348 = G_color_852;
         color_2352 = G_color_848;
         color_2356 = G_color_844;
         color_2360 = G_color_840;
         color_2364 = G_color_836;
         color_2368 = G_color_832;
         color_2372 = G_color_752;
         color_2376 = G_color_920;
         color_2380 = G_color_916;
         color_2384 = G_color_912;
         color_2388 = G_color_908;
         color_2392 = G_color_904;
         color_2396 = G_color_900;
         color_2400 = G_color_896;
         color_2404 = G_color_892;
         color_2408 = G_color_888;
         color_2412 = G_color_884;
         color_2416 = G_color_880;
         color_2420 = G_color_876;
         color_2424 = G_color_872;
         color_2428 = G_color_868;
         color_2432 = G_color_864;
         color_2436 = G_color_860;
         color_2440 = G_color_856;
      }
      if (Ld_4424 >= 61.0 && Ld_4424 < 63.0) {
         color_2348 = G_color_852;
         color_2352 = G_color_848;
         color_2356 = G_color_844;
         color_2360 = G_color_840;
         color_2364 = G_color_836;
         color_2368 = G_color_752;
         color_2372 = G_color_924;
         color_2376 = G_color_920;
         color_2380 = G_color_916;
         color_2384 = G_color_912;
         color_2388 = G_color_908;
         color_2392 = G_color_904;
         color_2396 = G_color_900;
         color_2400 = G_color_896;
         color_2404 = G_color_892;
         color_2408 = G_color_888;
         color_2412 = G_color_884;
         color_2416 = G_color_880;
         color_2420 = G_color_876;
         color_2424 = G_color_872;
         color_2428 = G_color_868;
         color_2432 = G_color_864;
         color_2436 = G_color_860;
         color_2440 = G_color_856;
      }
      if (Ld_4424 >= 59.0 && Ld_4424 < 61.0) {
         color_2348 = G_color_852;
         color_2352 = G_color_848;
         color_2356 = G_color_844;
         color_2360 = G_color_840;
         color_2364 = G_color_752;
         color_2368 = G_color_928;
         color_2372 = G_color_924;
         color_2376 = G_color_920;
         color_2380 = G_color_916;
         color_2384 = G_color_912;
         color_2388 = G_color_908;
         color_2392 = G_color_904;
         color_2396 = G_color_900;
         color_2400 = G_color_896;
         color_2404 = G_color_892;
         color_2408 = G_color_888;
         color_2412 = G_color_884;
         color_2416 = G_color_880;
         color_2420 = G_color_876;
         color_2424 = G_color_872;
         color_2428 = G_color_868;
         color_2432 = G_color_864;
         color_2436 = G_color_860;
         color_2440 = G_color_856;
      }
      if (Ld_4424 >= 57.0 && Ld_4424 < 59.0) {
         color_2348 = G_color_852;
         color_2352 = G_color_848;
         color_2356 = G_color_844;
         color_2360 = G_color_752;
         color_2364 = G_color_932;
         color_2368 = G_color_928;
         color_2372 = G_color_924;
         color_2376 = G_color_920;
         color_2380 = G_color_916;
         color_2384 = G_color_912;
         color_2388 = G_color_908;
         color_2392 = G_color_904;
         color_2396 = G_color_900;
         color_2400 = G_color_896;
         color_2404 = G_color_892;
         color_2408 = G_color_888;
         color_2412 = G_color_884;
         color_2416 = G_color_880;
         color_2420 = G_color_876;
         color_2424 = G_color_872;
         color_2428 = G_color_868;
         color_2432 = G_color_864;
         color_2436 = G_color_860;
         color_2440 = G_color_856;
      }
      if (Ld_4424 >= 55.0 && Ld_4424 < 57.0) {
         color_2348 = G_color_852;
         color_2352 = G_color_848;
         color_2356 = G_color_752;
         color_2360 = G_color_936;
         color_2364 = G_color_932;
         color_2368 = G_color_928;
         color_2372 = G_color_924;
         color_2376 = G_color_920;
         color_2380 = G_color_916;
         color_2384 = G_color_912;
         color_2388 = G_color_908;
         color_2392 = G_color_904;
         color_2396 = G_color_900;
         color_2400 = G_color_896;
         color_2404 = G_color_892;
         color_2408 = G_color_888;
         color_2412 = G_color_884;
         color_2416 = G_color_880;
         color_2420 = G_color_876;
         color_2424 = G_color_872;
         color_2428 = G_color_868;
         color_2432 = G_color_864;
         color_2436 = G_color_860;
         color_2440 = G_color_856;
      }
      if (Ld_4424 >= 53.0 && Ld_4424 < 55.0) {
         color_2348 = G_color_852;
         color_2352 = G_color_752;
         color_2356 = G_color_940;
         color_2360 = G_color_936;
         color_2364 = G_color_932;
         color_2368 = G_color_928;
         color_2372 = G_color_924;
         color_2376 = G_color_920;
         color_2380 = G_color_916;
         color_2384 = G_color_912;
         color_2388 = G_color_908;
         color_2392 = G_color_904;
         color_2396 = G_color_900;
         color_2400 = G_color_896;
         color_2404 = G_color_892;
         color_2408 = G_color_888;
         color_2412 = G_color_884;
         color_2416 = G_color_880;
         color_2420 = G_color_876;
         color_2424 = G_color_872;
         color_2428 = G_color_868;
         color_2432 = G_color_864;
         color_2436 = G_color_860;
         color_2440 = G_color_856;
      }
      if (Ld_4424 > 50.0 && Ld_4424 < 53.0) {
         color_2348 = G_color_752;
         color_2352 = G_color_944;
         color_2356 = G_color_940;
         color_2360 = G_color_936;
         color_2364 = G_color_932;
         color_2368 = G_color_928;
         color_2372 = G_color_924;
         color_2376 = G_color_920;
         color_2380 = G_color_916;
         color_2384 = G_color_912;
         color_2388 = G_color_908;
         color_2392 = G_color_904;
         color_2396 = G_color_900;
         color_2400 = G_color_896;
         color_2404 = G_color_892;
         color_2408 = G_color_888;
         color_2412 = G_color_884;
         color_2416 = G_color_880;
         color_2420 = G_color_876;
         color_2424 = G_color_872;
         color_2428 = G_color_868;
         color_2432 = G_color_864;
         color_2436 = G_color_860;
         color_2440 = G_color_856;
      }
      if (Li_4552 >= 0 && Ld_4556 >= 50.0) {
         color_2544 = G_color_664;
         G_color_612 = G_color_736;
      } else {
         if (Li_4552 < 0 && Ld_4556 >= 50.0) {
            color_2544 = G_color_788;
            G_color_612 = G_color_736;
         } else {
            color_2544 = G_color_336;
            G_color_612 = G_color_740;
         }
      }
      if (Ld_4416 >= 75.0 && Ld_4424 < 50.0) {
         color_2548 = G_color_664;
         G_color_616 = G_color_736;
      } else {
         if (Ld_4424 >= 75.0 && Ld_4416 < 50.0) {
            color_2548 = G_color_788;
            G_color_616 = G_color_736;
         } else {
            color_2548 = G_color_336;
            G_color_616 = G_color_740;
         }
      }
      if (ObjectDescription("50Alimeter") == "BUY") color_2444 = C'0x3D,0x72,0xED';
      if (ObjectDescription("50Alimeter") == "SELL") color_2444 = C'0xFF,0x0B,0x00';
      if (Gi_272 == 1) {
         Gi_276 = 0;
         G_y_280 = 0;
         ObjectCreate("Build95", OBJ_LABEL, G_window_296, 0, 0);
         if (ObjectDescription("50Alimeter") == "BUY") {
            if (Close[0] < Gd_156) ObjectSetText("Build95", DoubleToStr(Gd_156, MarketInfo(Symbol(), MODE_DIGITS)), 8, "Arial Black", color_2444);
            if (Close[0] >= Gd_156) ObjectSetText("Build95", DoubleToStr(Gd_156, MarketInfo(Symbol(), MODE_DIGITS)) + " (HIT)", 8, "Arial Black", color_2444);
         }
         if (ObjectDescription("50Alimeter") == "SELL") {
            if (Close[0] > Gd_156) ObjectSetText("Build95", DoubleToStr(Gd_156, MarketInfo(Symbol(), MODE_DIGITS)), 8, "Arial Black", color_2444);
            if (Close[0] <= Gd_156) ObjectSetText("Build95", DoubleToStr(Gd_156, MarketInfo(Symbol(), MODE_DIGITS)) + " (HIT)", 8, "Arial Black", color_2444);
         }
         ObjectSet("Build95", OBJPROP_CORNER, 0);
         ObjectSet("Build95", OBJPROP_XDISTANCE, Gi_276 + 145);
         ObjectSet("Build95", OBJPROP_YDISTANCE, G_y_280 + 70);
         ObjectCreate("Build96", OBJ_LABEL, G_window_296, 0, 0);
         if (StrToDouble(G_dbl2str_184) >= 0.0) ObjectSetText("Build96", G_dbl2str_184 + "  Pips", 8, "Arial Black", Green);
         if (StrToDouble(G_dbl2str_184) < 0.0) ObjectSetText("Build96", G_dbl2str_184 + " Pips", 8, "Arial Black", Crimson);
         ObjectSet("Build96", OBJPROP_CORNER, 0);
         ObjectSet("Build96", OBJPROP_XDISTANCE, Gi_276 + 145);
         ObjectSet("Build96", OBJPROP_YDISTANCE, G_y_280 + 85);
         if (StrToDouble(G_dbl2str_192) > 500000.0) G_dbl2str_192 = "00000";
         ObjectCreate("Build97", OBJ_LABEL, G_window_296, 0, 0);
         if (ObjectDescription("50Alimeter") == "BUY") ObjectSetText("Build97", "Candle should close below " + G_dbl2str_192, 8, "Arial Black", color_2444);
         if (ObjectDescription("50Alimeter") == "SELL") ObjectSetText("Build97", "Candle should close above " + G_dbl2str_192, 8, "Arial Black", color_2444);
         ObjectSet("Build97", OBJPROP_CORNER, 0);
         ObjectSet("Build97", OBJPROP_XDISTANCE, Gi_276 + 95);
         ObjectSet("Build97", OBJPROP_YDISTANCE, G_y_280 + 105);
         ObjectCreate("Build98", OBJ_LABEL, G_window_296, 0, 0);
         ObjectSetText("Build98", ObjectDescription("50Alimeter") + " @ " + DoubleToStr(Gd_140, MarketInfo(Symbol(), MODE_DIGITS)), 8, "Arial Black", color_2444);
         ObjectSet("Build98", OBJPROP_CORNER, 0);
         ObjectSet("Build98", OBJPROP_XDISTANCE, Gi_276 + 145);
         ObjectSet("Build98", OBJPROP_YDISTANCE, G_y_280 + 40);
         ObjectCreate("Build99", OBJ_LABEL, G_window_296, 0, 0);
         if (ObjectDescription("50Alimeter") == "BUY") ObjectSetText("Build99", DoubleToStr(Lda_16[0] + 25.0 * Gd_148 / 100.0, MarketInfo(Symbol(), MODE_DIGITS)) + " - " + G_dbl2str_192, 8, "Arial Black", color_2444);
         if (ObjectDescription("50Alimeter") == "SELL") ObjectSetText("Build99", DoubleToStr(Lda_12[0] - 25.0 * Gd_148 / 100.0, MarketInfo(Symbol(), MODE_DIGITS)) + " - " + G_dbl2str_192, 8, "Arial Black", color_2444);
         ObjectSet("Build99", OBJPROP_CORNER, 0);
         ObjectSet("Build99", OBJPROP_XDISTANCE, Gi_276 + 145);
         ObjectSet("Build99", OBJPROP_YDISTANCE, G_y_280 + 55);
         for (bars_4580 = 1; bars_4580 < 15; bars_4580++) {
            if (bars_4580 == 1) {
               G_text_208 = "Entry:";
               Gi_220 = 100;
               Gi_224 = 40;
               G_angle_232 = 0;
            }
            if (bars_4580 == 2) {
               G_text_208 = "Safe:";
               Gi_220 = 106;
               Gi_224 = 55;
               G_angle_232 = 0;
            }
            if (bars_4580 == 3) {
               G_text_208 = "TGT:";
               Gi_220 = 108;
               Gi_224 = 70;
               G_angle_232 = 0;
            }
            if (bars_4580 == 4) {
               G_text_208 = "P&L:";
               Gi_220 = 107;
               Gi_224 = 85;
               G_angle_232 = 0;
            }
            if (bars_4580 == 5) {
               G_text_208 = "SL:";
               Gi_220 = 70;
               Gi_224 = 105;
               G_angle_232 = 0;
            }
            if (bars_4580 == 6) {
               G_text_208 = " ";
               Gi_220 = 18;
               Gi_224 = 210;
               G_angle_232 = 90;
            }
            if (bars_4580 == 7) {
               G_text_208 = " ";
               Gi_220 = 338;
               Gi_224 = 210;
               G_angle_232 = 90;
            }
            if (bars_4580 == 8) {
               G_text_208 = " ";
               Gi_220 = 18;
               Gi_224 = 330;
               G_angle_232 = 90;
            }
            if (bars_4580 == 9) {
               G_text_208 = " ";
               Gi_220 = 338;
               Gi_224 = 330;
               G_angle_232 = 90;
            }
            if (bars_4580 == 10) {
               G_text_208 = " ";
               Gi_220 = 18;
               Gi_224 = 450;
               G_angle_232 = 90;
            }
            if (bars_4580 == 11) {
               G_text_208 = " ";
               Gi_220 = 338;
               Gi_224 = 450;
               G_angle_232 = 90;
            }
            if (bars_4580 == 12) {
               G_text_208 = "Long";
               Gi_220 = 170;
               Gi_224 = 130;
               G_angle_232 = 0;
            }
            if (bars_4580 == 13) {
               G_text_208 = "Long";
               Gi_220 = 170;
               Gi_224 = 252;
               G_angle_232 = 0;
            }
            if (bars_4580 == 14) {
               G_text_208 = "Long";
               Gi_220 = 170;
               Gi_224 = 374;
               G_angle_232 = 0;
            }
            ObjectCreate("Build94" + bars_4580, OBJ_LABEL, G_window_296, 0, 0);
            ObjectSetText("Build94" + bars_4580, G_text_208, 8, "Arial Black", G_color_320);
            ObjectSet("Build94" + bars_4580, OBJPROP_CORNER, 0);
            ObjectSet("Build94" + bars_4580, OBJPROP_ANGLE, G_angle_232);
            ObjectSet("Build94" + bars_4580, OBJPROP_XDISTANCE, Gi_276 + Gi_220);
            ObjectSet("Build94" + bars_4580, OBJPROP_YDISTANCE, G_y_280 + Gi_224);
         }
         for (bars_4580 = 1; bars_4580 < 9; bars_4580++) {
            if (bars_4580 == 1) {
               G_text_208 = ")";
               Gi_220 = 5;
               Gi_224 = 5;
               G_fontsize_228 = 115;
               G_color_268 = C'0x19,0x19,0x16';
            }
            if (bars_4580 == 2) {
               G_text_208 = ")";
               Gi_220 = 10;
               Gi_224 = 8;
               G_fontsize_228 = 110;
               G_color_268 = Black;
            }
            if (bars_4580 == 3) {
               G_text_208 = ")";
               Gi_220 = 5;
               Gi_224 = 126;
               G_fontsize_228 = 115;
               G_color_268 = C'0x19,0x19,0x16';
            }
            if (bars_4580 == 4) {
               G_text_208 = ")";
               Gi_220 = 10;
               Gi_224 = 129;
               G_fontsize_228 = 110;
               G_color_268 = Black;
            }
            if (bars_4580 == 5) {
               G_text_208 = ")";
               Gi_220 = 5;
               Gi_224 = 247;
               G_fontsize_228 = 115;
               G_color_268 = C'0x19,0x19,0x16';
            }
            if (bars_4580 == 6) {
               G_text_208 = ")";
               Gi_220 = 10;
               Gi_224 = 250;
               G_fontsize_228 = 110;
               G_color_268 = Black;
            }
            if (bars_4580 == 7) {
               G_text_208 = ")";
               Gi_220 = 5;
               Gi_224 = 368;
               G_fontsize_228 = 115;
               G_color_268 = C'0x19,0x19,0x16';
            }
            if (bars_4580 == 8) {
               G_text_208 = ")";
               Gi_220 = 10;
               Gi_224 = 371;
               G_fontsize_228 = 110;
               G_color_268 = Black;
            }
            ObjectCreate("****lay_" + bars_4580, OBJ_LABEL, 0, 0, 0);
            ObjectSetText("****lay_" + bars_4580, G_text_208, G_fontsize_228, "ButtonButton AOE", G_color_336);
            ObjectSet("****lay_" + bars_4580, OBJPROP_CORNER, 0);
            ObjectSet("****lay_" + bars_4580, OBJPROP_XDISTANCE, Gi_276 + Gi_220);
            ObjectSet("****lay_" + bars_4580, OBJPROP_YDISTANCE, G_y_280 + Gi_224);
            ObjectSet("****lay_" + bars_4580, OBJPROP_ANGLE, 0);
            ObjectSet("****lay_" + bars_4580, OBJPROP_COLOR, G_color_268);
         }
         for (bars_4580 = 4; bars_4580 < 7; bars_4580++) {
            if (bars_4580 == 4) {
               G_fontname_200 = "GA Clock Dial Round";
               G_text_208 = "g";
               G_fontsize_228 = 100;
               Gi_220 = 288;
               Gi_224 = 22;
            }
            if (bars_4580 == 5) {
               G_fontname_200 = "GA Clock Dial Round";
               G_text_208 = "g";
               G_fontsize_228 = 30;
               Gi_220 = 25;
               Gi_224 = 22;
            }
            if (bars_4580 == 6) {
               G_fontname_200 = "Arial Black";
               G_text_208 = "www.radarsignal.in";
               G_fontsize_228 = 10;
               Gi_220 = 210;
               Gi_224 = 10;
            }
            if (bars_4580 == 5 || bars_4580 == 4) {
               if (!ObjectCreate("**build" + bars_4580 + Gi_272, OBJ_LABEL, G_window_296, 0, 0)) {
                  ObjectSet("**build" + bars_4580 + Gi_272, OBJPROP_XDISTANCE, Gi_276 + Gi_220);
                  ObjectSet("**build" + bars_4580 + Gi_272, OBJPROP_YDISTANCE, G_y_280 + Gi_224);
                  ObjectSet("**build" + bars_4580 + Gi_272, OBJPROP_CORNER, corner_2560);
                  ObjectSet("**build" + bars_4580 + Gi_272, OBJPROP_ANGLE, angle_2636);
               } else {
                  ObjectCreate("**build" + bars_4580 + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
                  if (bars_4580 == 6) ObjectSetText("**build" + bars_4580 + Gi_272, G_text_208, G_fontsize_228, G_fontname_200, C'0xCC,0xCC,0x00');
                  if (bars_4580 != 6) ObjectSetText("**build" + bars_4580 + Gi_272, G_text_208, G_fontsize_228, G_fontname_200, C'0x33,0x33,0x33');
                  ObjectSet("**build" + bars_4580 + Gi_272, OBJPROP_CORNER, corner_2560);
                  ObjectSet("**build" + bars_4580 + Gi_272, OBJPROP_XDISTANCE, Gi_276 + Gi_220);
                  ObjectSet("**build" + bars_4580 + Gi_272, OBJPROP_YDISTANCE, G_y_280 + Gi_224);
                  ObjectSet("**build" + bars_4580 + Gi_272, OBJPROP_ANGLE, angle_2636);
               }
            }
            if (bars_4580 != 5 && bars_4580 != 4) {
               ObjectCreate("**build" + bars_4580 + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
               if (bars_4580 == 6) ObjectSetText("**build" + bars_4580 + Gi_272, G_text_208, G_fontsize_228, G_fontname_200, C'0xCC,0xCC,0x00');
               if (bars_4580 != 6) ObjectSetText("**build" + bars_4580 + Gi_272, G_text_208, G_fontsize_228, G_fontname_200, C'0x33,0x33,0x33');
               ObjectSet("**build" + bars_4580 + Gi_272, OBJPROP_CORNER, corner_2560);
               ObjectSet("**build" + bars_4580 + Gi_272, OBJPROP_XDISTANCE, Gi_276 + Gi_220);
               ObjectSet("**build" + bars_4580 + Gi_272, OBJPROP_YDISTANCE, G_y_280 + Gi_224);
               ObjectSet("**build" + bars_4580 + Gi_272, OBJPROP_ANGLE, angle_2636);
            }
         }
         ObjectCreate("Radar__Price" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
         ObjectSetText("Radar__Price" + Gi_272, dbl2str_2656, 10, "Arial Black", color_2444);
         ObjectSet("Radar__Price" + Gi_272, OBJPROP_CORNER, corner_2560);
         ObjectSet("Radar__Price" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 95);
         ObjectSet("Radar__Price" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 10);
         ObjectCreate("Radar_symbol" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
         ObjectSetText("Radar_symbol" + Gi_272, Ls_4564 + ":", 10, "Arial Black", G_color_320);
         ObjectSet("Radar_symbol" + Gi_272, OBJPROP_CORNER, corner_2560);
         ObjectSet("Radar_symbol" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 25);
         ObjectSet("Radar_symbol" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 10);
         ObjectCreate("Radar_X_signal_global" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
         if (ObjectDescription("50Alimeter") == "BUY") {
            ObjectSetText("**build5" + Gi_272, "g", 30, "GA Clock Dial Round", C'0x3D,0x72,0xED');
            ObjectSetText("**build4" + Gi_272, "g", 30, "GA Clock Dial Round", C'0x33,0x33,0x33');
            ObjectSetText("Radar_X_signal_global" + Gi_272, "BUY", 13, "Arial Black", Black);
         }
         if (ObjectDescription("50Alimeter") == "SELL") {
            ObjectSetText("**build5" + Gi_272, "g", 30, "GA Clock Dial Round", C'0xFF,0x0B,0x00');
            ObjectSetText("**build4" + Gi_272, "g", 30, "GA Clock Dial Round", C'0x33,0x33,0x33');
            ObjectSetText("Radar_X_signal_global" + Gi_272, "SELL", 13, "Arial Black", Black);
         }
         ObjectSet("Radar_X_signal_global" + Gi_272, OBJPROP_CORNER, corner_2560);
         ObjectSet("Radar_X_signal_global" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 35);
         ObjectSet("Radar_X_signal_global" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 57);
         ObjectCreate("Radar_X_signal_global1" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
         ObjectSetText("Radar_X_signal_global1" + Gi_272, " ", 13, "Arial Black", Black);
         if (ObjectDescription("50Alimeter") == "BUY") {
            if (Close[0] <= Lda_16[0] + 25.0 * Gd_148 / 100.0) {
               ObjectSetText("Radar_X_signal_global1" + Gi_272, "SAFE", 13, "Arial Black", Black);
               ObjectSetText("**build4" + Gi_272, "g", 30, "GA Clock Dial Round", C'0x3D,0x72,0xED');
            }
         }
         if (ObjectDescription("50Alimeter") == "SELL") {
            if (Close[0] >= Lda_12[0] - 25.0 * Gd_148 / 100.0) {
               ObjectSetText("Radar_X_signal_global1" + Gi_272, "SAFE", 13, "Arial Black", Black);
               ObjectSetText("**build4" + Gi_272, "g", 30, "GA Clock Dial Round", C'0xFF,0x0B,0x00');
            }
         }
         ObjectSet("Radar_X_signal_global1" + Gi_272, OBJPROP_CORNER, corner_2560);
         ObjectSet("Radar_X_signal_global1" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 296);
         ObjectSet("Radar_X_signal_global1" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 57);
      }
      if (Gi_272 == 1) {
         Gi_276 = -10;
         G_y_280 = 116;
         Gsa_260[Gi_272] = Ld_4556;
      }
      if (Gi_272 == 2) {
         Gi_276 = 82;
         G_y_280 = 116;
         Gsa_260[Gi_272] = Ld_4556;
      }
      if (Gi_272 == 3) {
         Gi_276 = 174;
         G_y_280 = 116;
         Gsa_260[Gi_272] = Ld_4556;
      }
      if (Gi_272 == 4) {
         Gi_276 = -10;
         G_y_280 = 237;
         Gsa_260[Gi_272] = Ld_4556;
      }
      if (Gi_272 == 5) {
         Gi_276 = 82;
         G_y_280 = 237;
         Gsa_260[Gi_272] = Ld_4556;
      }
      if (Gi_272 == 6) {
         Gi_276 = 174;
         G_y_280 = 237;
         Gsa_260[Gi_272] = Ld_4556;
      }
      if (Gi_272 == 7) {
         Gi_276 = -10;
         G_y_280 = 358;
         Gsa_260[Gi_272] = Ld_4556;
      }
      if (Gi_272 == 8) {
         Gi_276 = 82;
         G_y_280 = 358;
         Gsa_260[Gi_272] = Ld_4556;
      }
      if (Gi_272 == 9) {
         Gi_276 = 174;
         G_y_280 = 358;
         Gsa_260[Gi_272] = Ld_4556;
      }
      for (bars_4580 = 0; bars_4580 < 4; bars_4580++) {
         if (bars_4580 == 0) {
            if (Gi_272 == 1 || Gi_272 == 4 || Gi_272 == 7) {
               Gi_220 = 45;
               Gi_224 = Li_2592 + 25;
            }
         }
         if (bars_4580 == 1) {
            if (Gi_272 == 1 || Gi_272 == 4 || Gi_272 == 7) {
               Gi_220 = 57;
               Gi_224 = Li_2592 + 14;
            }
         }
         if (bars_4580 == 2) {
            Gi_220 = Li_2588 + 30;
            Gi_224 = Li_2592 + 14;
         }
         if (bars_4580 == 3) {
            Gi_220 = Li_2588 + 30;
            Gi_224 = Li_2592 + 25;
         }
         ObjectCreate("**build" + bars_4580 + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
         ObjectSetText("**build" + bars_4580 + Gi_272, "M", 78, "Building", C'0x33,0x33,0x33');
         ObjectSet("**build" + bars_4580 + Gi_272, OBJPROP_CORNER, corner_2560);
         ObjectSet("**build" + bars_4580 + Gi_272, OBJPROP_XDISTANCE, Gi_276 + Gi_220);
         ObjectSet("**build" + bars_4580 + Gi_272, OBJPROP_YDISTANCE, G_y_280 + Gi_224);
         ObjectSet("**build" + bars_4580 + Gi_272, OBJPROP_ANGLE, angle_2636);
      }
      ObjectCreate("**Radar_signal " + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("**Radar_signal " + Gi_272, "g", 71, "WebDings", G_color_336);
      ObjectSet("**Radar_signal " + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("**Radar_signal " + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 61);
      ObjectSet("**Radar_signal " + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 32);
      ObjectCreate("*Radar_signal1" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("*Radar_signal1" + Gi_272, "|", 70, "Webdings", color_2548);
      ObjectSet("*Radar_signal1" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("*Radar_signal1" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 38);
      ObjectSet("*Radar_signal1" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 32);
      ObjectCreate("*Radar_signal2" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("*Radar_signal2" + Gi_272, "|", 70, "Webdings", color_2548);
      ObjectSet("*Radar_signal2" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("*Radar_signal2" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 43);
      ObjectSet("*Radar_signal2" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 32);
      ObjectCreate("*Radar_signal3" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("*Radar_signal3" + Gi_272, "|", 70, "Webdings", color_2544);
      ObjectSet("*Radar_signal3" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("*Radar_signal3" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 84);
      ObjectSet("*Radar_signal3" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 32);
      ObjectCreate("*Radar_signal4" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("*Radar_signal4" + Gi_272, "|", 70, "Webdings", color_2544);
      ObjectSet("*Radar_signal4" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("*Radar_signal4" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 88);
      ObjectSet("*Radar_signal4" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 32);
      ObjectCreate("Radar_signal_trend_1" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_1" + Gi_272, "_ _", 25, "Arial Bold", color_2448);
      ObjectSet("Radar_signal_trend_1" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 155);
      ObjectSet("Radar_signal_trend_1" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 69);
      ObjectSet("Radar_signal_trend_1" + Gi_272, OBJPROP_ANGLE, 180);
      ObjectCreate("Radar_signal_trend_2" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_2" + Gi_272, "_ _", 25, "Arial Bold", color_2452);
      ObjectSet("Radar_signal_trend_2" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 110);
      ObjectSet("Radar_signal_trend_2" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 1);
      ObjectCreate("Radar_signal_trend_3" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_3" + Gi_272, "_ _", 25, "Arial Bold", color_2456);
      ObjectSet("Radar_signal_trend_3" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 110);
      ObjectSet("Radar_signal_trend_3" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 5);
      ObjectCreate("Radar_signal_trend_4" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_4" + Gi_272, "_ _", 25, "Arial Bold", color_2460);
      ObjectSet("Radar_signal_trend_4" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 110);
      ObjectSet("Radar_signal_trend_4" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 9);
      ObjectCreate("Radar_signal_trend_5" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_5" + Gi_272, "_ _", 25, "Arial Bold", color_2464);
      ObjectSet("Radar_signal_trend_5" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 110);
      ObjectSet("Radar_signal_trend_5" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 13);
      ObjectCreate("Radar_signal_trend_6" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_6" + Gi_272, "_ _", 25, "Arial Bold", color_2468);
      ObjectSet("Radar_signal_trend_6" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 110);
      ObjectSet("Radar_signal_trend_6" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 17);
      ObjectCreate("Radar_signal_trend_7" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_7" + Gi_272, "_ _", 25, "Arial Bold", color_2472);
      ObjectSet("Radar_signal_trend_7" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 110);
      ObjectSet("Radar_signal_trend_7" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 21);
      ObjectCreate("Radar_signal_trend_8" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_8" + Gi_272, "_ _", 25, "Arial Bold", color_2476);
      ObjectSet("Radar_signal_trend_8" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 110);
      ObjectSet("Radar_signal_trend_8" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 25);
      ObjectCreate("Radar_signal_trend_9" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_9" + Gi_272, "_ _", 25, "Arial Bold", color_2480);
      ObjectSet("Radar_signal_trend_9" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 110);
      ObjectSet("Radar_signal_trend_9" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 29);
      ObjectCreate("Radar_signal_trend_10" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_10" + Gi_272, "_ _", 25, "Arial Bold", color_2484);
      ObjectSet("Radar_signal_trend_10" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 110);
      ObjectSet("Radar_signal_trend_10" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 33);
      ObjectCreate("Radar_signal_trend_11" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_11" + Gi_272, "_ _", 25, "Arial Bold", color_2488);
      ObjectSet("Radar_signal_trend_11" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 110);
      ObjectSet("Radar_signal_trend_11" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 37);
      ObjectCreate("Radar_signal_trend_12" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_12" + Gi_272, "_ _", 25, "Arial Bold", color_2492);
      ObjectSet("Radar_signal_trend_12" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 110);
      ObjectSet("Radar_signal_trend_12" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 41);
      ObjectCreate("Radar_signal_trend_13" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_13" + Gi_272, "_ _", 25, "Arial Bold", color_2496);
      ObjectSet("Radar_signal_trend_13" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 110);
      ObjectSet("Radar_signal_trend_13" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 45);
      ObjectCreate("Radar_signal_trend_14" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_14" + Gi_272, "_ _", 25, "Arial Bold", color_2500);
      ObjectSet("Radar_signal_trend_14" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 110);
      ObjectSet("Radar_signal_trend_14" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 49);
      ObjectCreate("Radar_signal_trend_15" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_15" + Gi_272, "_ _", 25, "Arial Bold", color_2504);
      ObjectSet("Radar_signal_trend_15" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 110);
      ObjectSet("Radar_signal_trend_15" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 53);
      ObjectCreate("Radar_signal_trend_16" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_16" + Gi_272, "_ _", 25, "Arial Bold", color_2508);
      ObjectSet("Radar_signal_trend_16" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 110);
      ObjectSet("Radar_signal_trend_16" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 57);
      ObjectCreate("Radar_signal_trend_17" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_17" + Gi_272, "_ _", 25, "Arial Bold", color_2512);
      ObjectSet("Radar_signal_trend_17" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 110);
      ObjectSet("Radar_signal_trend_17" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 61);
      ObjectCreate("Radar_signal_trend_18" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_18" + Gi_272, "_ _", 25, "Arial Bold", color_2516);
      ObjectSet("Radar_signal_trend_18" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 110);
      ObjectSet("Radar_signal_trend_18" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 65);
      ObjectCreate("Radar_signal_trend_19" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_19" + Gi_272, "_ _", 25, "Arial Bold", color_2520);
      ObjectSet("Radar_signal_trend_19" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 110);
      ObjectSet("Radar_signal_trend_19" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 69);
      ObjectCreate("Radar_signal_trend_20" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_20" + Gi_272, "_ _", 25, "Arial Bold", color_2524);
      ObjectSet("Radar_signal_trend_20" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 110);
      ObjectSet("Radar_signal_trend_20" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 73);
      ObjectCreate("Radar_signal_trend_21" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_21" + Gi_272, "_ _", 25, "Arial Bold", color_2528);
      ObjectSet("Radar_signal_trend_21" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 110);
      ObjectSet("Radar_signal_trend_21" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 77);
      ObjectCreate("Radar_signal_trend_22" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_22" + Gi_272, "_ _", 25, "Arial Bold", color_2532);
      ObjectSet("Radar_signal_trend_22" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 110);
      ObjectSet("Radar_signal_trend_22" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 81);
      ObjectCreate("Radar_signal_trend_23" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_23" + Gi_272, "_ _", 25, "Arial Bold", color_2536);
      ObjectSet("Radar_signal_trend_23" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 110);
      ObjectSet("Radar_signal_trend_23" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 85);
      ObjectCreate("Radar_signal_trend_24" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trend_24" + Gi_272, "_ _", 25, "Arial Bold", color_2540);
      ObjectSet("Radar_signal_trend_24" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 110);
      ObjectSet("Radar_signal_trend_24" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 89);
      ObjectCreate("Radar_signal_trendy_1" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_1" + Gi_272, "_ _", 25, "Arial Bold", color_2348);
      ObjectSet("Radar_signal_trendy_1" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_1" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 109);
      ObjectSet("Radar_signal_trendy_1" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 69);
      ObjectSet("Radar_signal_trendy_1" + Gi_272, OBJPROP_ANGLE, 180);
      ObjectCreate("Radar_signal_trendy_2" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_2" + Gi_272, "_ _", 25, "Arial Bold", color_2352);
      ObjectSet("Radar_signal_trendy_2" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_2" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 64);
      ObjectSet("Radar_signal_trendy_2" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 1);
      ObjectCreate("Radar_signal_trendy_3" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_3" + Gi_272, "_ _", 25, "Arial Bold", color_2356);
      ObjectSet("Radar_signal_trendy_3" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_3" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 64);
      ObjectSet("Radar_signal_trendy_3" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 5);
      ObjectCreate("Radar_signal_trendy_4" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_4" + Gi_272, "_ _", 25, "Arial Bold", color_2360);
      ObjectSet("Radar_signal_trendy_4" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_4" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 64);
      ObjectSet("Radar_signal_trendy_4" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 9);
      ObjectCreate("Radar_signal_trendy_5" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_5" + Gi_272, "_ _", 25, "Arial Bold", color_2364);
      ObjectSet("Radar_signal_trendy_5" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_5" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 64);
      ObjectSet("Radar_signal_trendy_5" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 13);
      ObjectCreate("Radar_signal_trendy_6" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_6" + Gi_272, "_ _", 25, "Arial Bold", color_2368);
      ObjectSet("Radar_signal_trendy_6" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_6" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 64);
      ObjectSet("Radar_signal_trendy_6" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 17);
      ObjectCreate("Radar_signal_trendy_7" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_7" + Gi_272, "_ _", 25, "Arial Bold", color_2372);
      ObjectSet("Radar_signal_trendy_7" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_7" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 64);
      ObjectSet("Radar_signal_trendy_7" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 21);
      ObjectCreate("Radar_signal_trendy_8" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_8" + Gi_272, "_ _", 25, "Arial Bold", color_2376);
      ObjectSet("Radar_signal_trendy_8" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_8" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 64);
      ObjectSet("Radar_signal_trendy_8" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 25);
      ObjectCreate("Radar_signal_trendy_9" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_9" + Gi_272, "_ _", 25, "Arial Bold", color_2380);
      ObjectSet("Radar_signal_trendy_9" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_9" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 64);
      ObjectSet("Radar_signal_trendy_9" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 29);
      ObjectCreate("Radar_signal_trendy_10" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_10" + Gi_272, "_ _", 25, "Arial Bold", color_2384);
      ObjectSet("Radar_signal_trendy_10" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_10" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 64);
      ObjectSet("Radar_signal_trendy_10" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 33);
      ObjectCreate("Radar_signal_trendy_11" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_11" + Gi_272, "_ _", 25, "Arial Bold", color_2388);
      ObjectSet("Radar_signal_trendy_11" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_11" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 64);
      ObjectSet("Radar_signal_trendy_11" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 37);
      ObjectCreate("Radar_signal_trendy_12" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_12" + Gi_272, "_ _", 25, "Arial Bold", color_2392);
      ObjectSet("Radar_signal_trendy_12" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_12" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 64);
      ObjectSet("Radar_signal_trendy_12" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 41);
      ObjectCreate("Radar_signal_trendy_13" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_13" + Gi_272, "_ _", 25, "Arial Bold", color_2396);
      ObjectSet("Radar_signal_trendy_13" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_13" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 64);
      ObjectSet("Radar_signal_trendy_13" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 45);
      ObjectCreate("Radar_signal_trendy_14" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_14" + Gi_272, "_ _", 25, "Arial Bold", color_2400);
      ObjectSet("Radar_signal_trendy_14" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_14" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 64);
      ObjectSet("Radar_signal_trendy_14" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 49);
      ObjectCreate("Radar_signal_trendy_15" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_15" + Gi_272, "_ _", 25, "Arial Bold", color_2404);
      ObjectSet("Radar_signal_trendy_15" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_15" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 64);
      ObjectSet("Radar_signal_trendy_15" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 53);
      ObjectCreate("Radar_signal_trendy_16" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_16" + Gi_272, "_ _", 25, "Arial Bold", color_2408);
      ObjectSet("Radar_signal_trendy_16" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_16" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 64);
      ObjectSet("Radar_signal_trendy_16" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 57);
      ObjectCreate("Radar_signal_trendy_17" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_17" + Gi_272, "_ _", 25, "Arial Bold", color_2412);
      ObjectSet("Radar_signal_trendy_17" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_17" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 64);
      ObjectSet("Radar_signal_trendy_17" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 61);
      ObjectCreate("Radar_signal_trendy_18" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_18" + Gi_272, "_ _", 25, "Arial Bold", color_2416);
      ObjectSet("Radar_signal_trendy_18" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_18" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 64);
      ObjectSet("Radar_signal_trendy_18" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 65);
      ObjectCreate("Radar_signal_trendy_19" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_19" + Gi_272, "_ _", 25, "Arial Bold", color_2420);
      ObjectSet("Radar_signal_trendy_19" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_19" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 64);
      ObjectSet("Radar_signal_trendy_19" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 69);
      ObjectCreate("Radar_signal_trendy_20" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_20" + Gi_272, "_ _", 25, "Arial Bold", color_2424);
      ObjectSet("Radar_signal_trendy_20" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_20" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 64);
      ObjectSet("Radar_signal_trendy_20" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 73);
      ObjectCreate("Radar_signal_trendy_21" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_21" + Gi_272, "_ _", 25, "Arial Bold", color_2428);
      ObjectSet("Radar_signal_trendy_21" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_21" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 64);
      ObjectSet("Radar_signal_trendy_21" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 77);
      ObjectCreate("Radar_signal_trendy_22" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_22" + Gi_272, "_ _", 25, "Arial Bold", color_2432);
      ObjectSet("Radar_signal_trendy_22" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_22" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 64);
      ObjectSet("Radar_signal_trendy_22" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 81);
      ObjectCreate("Radar_signal_trendy_23" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_23" + Gi_272, "_ _", 25, "Arial Bold", color_2436);
      ObjectSet("Radar_signal_trendy_23" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_23" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 64);
      ObjectSet("Radar_signal_trendy_23" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 85);
      ObjectCreate("Radar_signal_trendy_24" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_signal_trendy_24" + Gi_272, "_ _", 25, "Arial Bold", color_2440);
      ObjectSet("Radar_signal_trendy_24" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_signal_trendy_24" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + 64);
      ObjectSet("Radar_signal_trendy_24" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + 89);
      for (count_4584 = 1; count_4584 < 25; count_4584++) ObjectSet("Radar_signal_trend_" + count_4584 + Gi_272, OBJPROP_CORNER, corner_2560);
      if (Ld_4556 >= 9.5 && Ld_4556 <= 99.9) Li_unused_2552 = 2;
      else {
         if (Ld_4556 < 10.0) Li_unused_2552 = 7;
         else Li_unused_2552 = 0;
      }
      if (Gi_272 == 1 || Gi_272 == 4 || Gi_272 == 7) {
         G_text_244 = "ADX";
         G_text_252 = "RSI";
      }
      if (Gi_272 == 2 || Gi_272 == 5 || Gi_272 == 8) {
         G_text_244 = "CCI";
         G_text_252 = "OsMA";
      }
      if (Gi_272 == 3 || Gi_272 == 6 || Gi_272 == 9) {
         G_text_244 = "ATR";
         G_text_252 = "WPR";
      }
      ObjectCreate("Radar_Value_percent1" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_Value_percent1" + Gi_272, G_text_244, 8, "Arial Black", G_color_616);
      ObjectSet("Radar_Value_percent1" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_Value_percent1" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + Li_2564 - 18);
      ObjectSet("Radar_Value_percent1" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + Li_2568 + 50);
      ObjectSet("Radar_Value_percent1" + Gi_272, OBJPROP_ANGLE, 90);
      ObjectCreate("Radar_Value_percent2" + Gi_272, OBJ_LABEL, G_window_296, 0, 0);
      ObjectSetText("Radar_Value_percent2" + Gi_272, G_text_252, 8, "Arial Black", G_color_612);
      ObjectSet("Radar_Value_percent2" + Gi_272, OBJPROP_CORNER, corner_2560);
      ObjectSet("Radar_Value_percent2" + Gi_272, OBJPROP_XDISTANCE, Gi_276 + Li_2572 - 18);
      ObjectSet("Radar_Value_percent2" + Gi_272, OBJPROP_YDISTANCE, G_y_280 + Li_2576 + 50);
      ObjectSet("Radar_Value_percent2" + Gi_272, OBJPROP_ANGLE, 90);
   }
   ObjectSetText("Build946", DoubleToStr(iStochastic(Gs_308, PERIOD_M5, 15, 21, 50, MODE_SMA, 1, MODE_MAIN, 0), 2), 8, "Arial Black", G_color_320);
   ObjectSetText("Build947", DoubleToStr(iStochastic(Gs_308, PERIOD_M15, 15, 21, 50, MODE_SMA, 1, MODE_MAIN, 0), 2), 8, "Arial Black", G_color_320);
   ObjectSetText("Build948", DoubleToStr(iStochastic(Gs_308, PERIOD_H1, 15, 21, 50, MODE_SMA, 1, MODE_MAIN, 0), 2), 8, "Arial Black", G_color_320);
   ObjectSetText("Build949", DoubleToStr(iStochastic(Gs_308, PERIOD_H4, 15, 21, 50, MODE_SMA, 1, MODE_MAIN, 0), 2), 8, "Arial Black", G_color_320);
   ObjectSetText("Build9410", DoubleToStr(iStochastic(Gs_308, PERIOD_D1, 15, 21, 50, MODE_SMA, 1, MODE_MAIN, 0), 2), 8, "Arial Black", G_color_320);
   ObjectSetText("Build9411", DoubleToStr(iStochastic(Gs_308, PERIOD_W1, 15, 21, 50, MODE_SMA, 1, MODE_MAIN, 0), 2), 8, "Arial Black", G_color_320);
   ObjectSetText("Build9412", DoubleToStr((iStochastic(Gs_308, PERIOD_M5, 15, 21, 50, MODE_SMA, 1, MODE_MAIN, 0) + iStochastic(Gs_308, PERIOD_M15, 15, 21, 50, MODE_SMA,
      1, MODE_MAIN, 0)) / 2.0, 2), 8, "Arial Black", G_color_320);
   ObjectSetText("Build9413", DoubleToStr((iStochastic(Gs_308, PERIOD_H1, 15, 21, 50, MODE_SMA, 1, MODE_MAIN, 0) + iStochastic(Gs_308, PERIOD_H4, 15, 21, 50, MODE_SMA,
      1, MODE_MAIN, 0)) / 2.0, 2), 8, "Arial Black", G_color_320);
   ObjectSetText("Build9414", DoubleToStr((iStochastic(Gs_308, PERIOD_D1, 15, 21, 50, MODE_SMA, 1, MODE_MAIN, 0) + iStochastic(Gs_308, PERIOD_W1, 15, 21, 50, MODE_SMA,
      1, MODE_MAIN, 0)) / 2.0, 2), 8, "Arial Black", G_color_320);
   return (0);
}

// 9B1AEE847CFB597942D106A4135D4FE6
int f0_1(double Ad_0) {
   int Li_ret_8;
   int Lia_12[10] = {0, 3, 10, 25, 40, 50, 60, 75, 90, 97};
   if (Ad_0 <= Lia_12[0]) Li_ret_8 = 0;
   else {
      if (Ad_0 < Lia_12[1]) Li_ret_8 = 0;
      else {
         if (Ad_0 < Lia_12[2]) Li_ret_8 = 1;
         else {
            if (Ad_0 < Lia_12[3]) Li_ret_8 = 2;
            else {
               if (Ad_0 < Lia_12[4]) Li_ret_8 = 3;
               else {
                  if (Ad_0 < Lia_12[5]) Li_ret_8 = 4;
                  else {
                     if (Ad_0 < Lia_12[6]) Li_ret_8 = 5;
                     else {
                        if (Ad_0 < Lia_12[7]) Li_ret_8 = 6;
                        else {
                           if (Ad_0 < Lia_12[8]) Li_ret_8 = 7;
                           else {
                              if (Ad_0 < Lia_12[9]) Li_ret_8 = 8;
                              else Li_ret_8 = 9;
                           }
                        }
                     }
                  }
               }
            }
         }
      }
   }
   return (Li_ret_8);
}

// 945D754CB0DC06D04243FCBA25FC0802
int f0_0() {
   ObjectDelete("_Alert1");
   ObjectDelete("_Alert2");
   ObjectDelete("_Alert3");
   ObjectDelete("_Alert4");
   return (0);
}
