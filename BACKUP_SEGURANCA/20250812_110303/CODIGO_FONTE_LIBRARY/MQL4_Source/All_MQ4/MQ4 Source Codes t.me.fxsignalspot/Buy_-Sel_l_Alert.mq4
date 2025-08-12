
#property indicator_chart_window
#property indicator_minimum 0.0
#property indicator_maximum 1.0
#property indicator_buffers 2
#property indicator_color1 Black
#property indicator_color2 Black

string Gs_76 = "=== Trade Info Box ===";
bool Gi_84 = FALSE;
int Gi_88 = 10;
int Gi_92 = 20;
bool Gi_96 = TRUE;
extern int Window = 0;
int Gi_104 = 1;
extern int X_trend = 0;
extern int Y_trend = 40;
extern bool Alerts = true;
extern int Buy  = 75;
extern int Sell = 75;
string Gs_116 = "=== Trade Info ===";
bool Gi_124 = TRUE;
double Gd_128 = 5.0;
double Gd_136 = 0.832;
double Gd_144 = 75.0;
string Gs_152 = "=== Trend calculation and display ===";
bool Gi_160 = TRUE;
bool Gi_164 = TRUE;
bool Gi_168 = TRUE;
bool Gi_172 = TRUE;
bool Gi_176 = TRUE;
bool Gi_180 = TRUE;
bool Gi_184 = TRUE;
bool Gi_188 = TRUE;
bool Gi_192 = TRUE;
bool Gi_196 = TRUE;
bool Gi_200 = TRUE;
bool Gi_204 = TRUE;
bool Gi_208 = TRUE;
bool Gi_212 = TRUE;
string Gs_216 = "=== If display false, set coef to 0 ===";
string Gs_224 = "3 TF true, SUM of their coef must be 3";
bool Gi_232 = TRUE;
double Gd_236 = 1.0;
bool Gi_244 = TRUE;
double Gd_248 = 1.0;
bool Gi_256 = TRUE;
double Gd_260 = 1.0;
bool Gi_268 = TRUE;
double Gd_272 = 1.0;
bool Gi_280 = TRUE;
double Gd_284 = 1.0;
bool Gi_292 = TRUE;
double Gd_296 = 1.0;
bool Gi_304 = FALSE;
double Gd_308 = 0.0;
string Gs_316 = "=== Format: 2007.05.07 00:00 ===";
int Gi_324 = D'07.05.2007 07:00';
double Gd_328 = 0.0;
bool Gi_336 = FALSE;
string Gs_340 = "=== Moving Average Settings ===";
int Gi_348 = 5;
int Gi_352 = 26;
int Gi_356 = 52;
int Gi_360 = MODE_EMA;
int Gi_364 = PRICE_CLOSE;
string Gs_368 = "=== CCI Settings ===";
int Gi_376 = 14;
int Gi_380 = PRICE_CLOSE;
string Gs_384 = "=== MACD Settings ===";
int Gi_392 = 12;
int Gi_396 = 24;
int Gi_400 = 6;
string Gs_404 = "=== ADX Settings ===";
int Gi_412 = 14;
int Gi_416 = PRICE_CLOSE;
string Gs_420 = "=== BULLS Settings ===";
int Gi_428 = 13;
int Gi_432 = PRICE_CLOSE;
string Gs_436 = "=== BEARS Settings ===";
int Gi_444 = 13;
int Gi_448 = PRICE_CLOSE;
string Gs_452 = "=== STOCHASTIC Settings ===";
int Gi_460 = 5;
int Gi_464 = 3;
int Gi_468 = 3;
string Gs_472 = "=== RSI Settings ===";
int Gi_480 = 14;
string Gs_484 = "=== FORCE INDEX Settings ===";
int Gi_492 = 14;
int Gi_496 = MODE_SMA;
int Gi_500 = PRICE_CLOSE;
string Gs_504 = "=== MOMENTUM INDEX Settings ===";
int Gi_512 = 14;
int Gi_516 = PRICE_CLOSE;
string Gs_520 = "=== DeMARKER Settings ===";
int Gi_528 = 14;
double Gda_532[];
double Gda_536[];

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   SetIndexBuffer(0, Gda_532);
   SetIndexBuffer(1, Gda_536);
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   ObjectDelete("timeframe");
   ObjectDelete("line1");
   ObjectDelete("stoploss");
   ObjectDelete("Stop");
   ObjectDelete("pipstostop");
   ObjectDelete("PipsStop");
   ObjectDelete("line2");
   ObjectDelete("pipsprofit");
   ObjectDelete("pips_profit");
   ObjectDelete("percentbalance");
   ObjectDelete("percent_profit");
   ObjectDelete("line3");
   ObjectDelete("maxlot1");
   ObjectDelete("maxlot2");
   ObjectDelete("line4");
   ObjectDelete("Trend_UP");
   ObjectDelete("line9");
   ObjectDelete("Trend_UP_text");
   ObjectDelete("Trend_UP_value");
   ObjectDelete("Trend_DOWN_text");
   ObjectDelete("Trend_DOWN_value");
   ObjectDelete("line10");
   ObjectDelete("line12");
   ObjectDelete("Trend");
   ObjectDelete("Trend_comment");
   ObjectDelete("line13");
   ObjectDelete("line11");
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   double Ld_0;
   double Ld_8;
   double Ld_16;
   double Ld_24;
   double Ld_32;
   double Ld_40;
   double Ld_48;
   double Ld_56;
   double Ld_64;
   double Ld_72;
   double Ld_80;
   double Ld_88;
   double Ld_96;
   double Ld_104;
   double Ld_112;
   double Ld_120;
   double Ld_128;
   double Ld_136;
   double Ld_144;
   double Ld_152;
   double Ld_160;
   double Ld_168;
   double Ld_176;
   double Ld_184;
   double Ld_192;
   double Ld_200;
   double Ld_208;
   double Ld_216;
   double Ld_224;
   double Ld_232;
   double Ld_240;
   double Ld_248;
   double Ld_256;
   double Ld_264;
   double Ld_272;
   double Ld_280;
   double Ld_288;
   double Ld_296;
   double Ld_304;
   double Ld_312;
   double Ld_320;
   double Ld_328;
   double Ld_336;
   double Ld_344;
   double Ld_352;
   double Ld_360;
   double Ld_368;
   double Ld_376;
   double Ld_384;
   double Ld_392;
   double Ld_400;
   double Ld_408;
   double Ld_416;
   double Ld_424;
   double Ld_432;
   double Ld_440;
   double Ld_448;
   double Ld_456;
   double Ld_464;
   double Ld_472;
   double Ld_480;
   double Ld_488;
   double Ld_496;
   double Ld_504;
   double Ld_512;
   double Ld_520;
   double Ld_528;
   double Ld_536;
   double Ld_544;
   double Ld_552;
   double Ld_560;
   double Ld_568;
   double Ld_576;
   double Ld_584;
   double Ld_592;
   double Ld_600;
   double Ld_608;
   double Ld_616;
   double Ld_624;
   double Ld_632;
   double Ld_640;
   double Ld_648;
   double Ld_656;
   double Ld_664;
   double Ld_672;
   double Ld_680;
   double Ld_688;
   double Ld_696;
   double Ld_704;
   double Ld_712;
   double Ld_720;
   double Ld_728;
   double Ld_736;
   double Ld_744;
   double Ld_752;
   double Ld_760;
   double Ld_768;
   double Ld_776;
   double Ld_784;
   double Ld_792;
   double Ld_800;
   double Ld_808;
   double Ld_816;
   double Ld_824;
   double Ld_832;
   double Ld_840;
   double Ld_848;
   double Ld_856;
   double Ld_864;
   double Ld_872;
   double Ld_880;
   double Ld_888;
   double Ld_896;
   double Ld_904;
   double Ld_912;
   double Ld_920;
   double Ld_928;
   double Ld_936;
   double Ld_944;
   double Ld_952;
   double Ld_960;
   double Ld_968;
   double Ld_976;
   double Ld_984;
   double Ld_992;
   double Ld_1000;
   double Ld_1008;
   double Ld_1016;
   double Ld_1024;
   double Ld_1032;
   double Ld_1040;
   double Ld_1048;
   double Ld_1056;
   double Ld_1064;
   double Ld_1072;
   double Ld_1080;
   double Ld_1088;
   double Ld_1096;
   double Ld_1104;
   double Ld_1112;
   double Ld_1120;
   double Ld_1128;
   double Ld_1136;
   double Ld_1144;
   double Ld_1152;
   double Ld_1160;
   double Ld_1168;
   double Ld_1176;
   double Ld_1184;
   double Ld_1192;
   double Ld_1200;
   double Ld_1208;
   double Ld_1216;
   double Ld_1224;
   double Ld_1232;
   double Ld_1240;
   double Ld_1248;
   double Ld_1256;
   double Ld_1264;
   double Ld_1272;
   double Ld_1280;
   double Ld_1288;
   double Ld_1296;
   double Ld_1304;
   double Ld_1312;
   double Ld_1320;
   double Ld_1328;
   double Ld_1336;
   double Ld_1344;
   double Ld_1352;
   double Ld_1360;
   double Ld_1368;
   double Ld_1376;
   double Ld_1384;
   double Ld_1392;
   double Ld_1400;
   double Ld_1408;
   double Ld_1416;
   double Ld_1424;
   double Ld_1432;
   double Ld_1440;
   double Ld_1448;
   double Ld_1456;
   double Ld_1464;
   double Ld_1472;
   double Ld_1480;
   double Ld_1488;
   double Ld_1496;
   double Ld_1504;
   double Ld_1512;
   double Ld_1520;
   double Ld_1528;
   double Ld_1536;
   double Ld_1544;
   double Ld_1552;
   double Ld_1560;
   double Ld_1568;
   double Ld_1576;
   double Ld_1584;
   double Ld_1592;
   double Ld_1600;
   double Ld_1608;
   double Ld_1616;
   string Ls_1624;
   color Li_1632;
   double Ld_1636;
   string Ls_1644;
   int Li_1652;
   int Li_1656;
   int Li_1660;
   int Li_1664;
   int Li_1668;
   int Li_1672;
   int Li_1676;
   int Li_1680;
   int Li_1684;
   int Li_1688;
   int Li_1692;
   int Li_1696;
   int Li_1700;
   int Li_1704;
   int Li_1708;
   int Li_1712;
   int Li_1716;
   int Li_1720;
   int Li_1724;
   int Li_1728;
   int Li_1732;
   int Li_1736;
   int Li_1740;
   string Ls_1744;
   color Li_1752;
   string Ls_1756;
   color Li_1764;
   string Ls_1768;
   color Li_1776;
   string Ls_1780;
   color Li_1788;
   string Ls_1792;
   color Li_1800;
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
   string Ls_3212;
   string Ls_3220;
   color Li_3228;
   color Li_3232;
   double Ld_3236;
   double Ld_3244;
   if (Gi_232 == TRUE) Ld_1568 = 1;
   if (Gi_244 == TRUE) Ld_1576 = 1;
   if (Gi_256 == TRUE) Ld_1584 = 1;
   if (Gi_268 == TRUE) Ld_1592 = 1;
   if (Gi_280 == TRUE) Ld_1600 = 1;
   if (Gi_292 == TRUE) Ld_1608 = 1;
   if (Gi_304 == TRUE) Ld_1616 = 1;
   double Ld_3252 = Ld_1568 + Ld_1576 + Ld_1584 + Ld_1592 + Ld_1600 + Ld_1608 + Ld_1616;
   double Ld_3260 = Gd_236 + Gd_248 + Gd_260 + Gd_272 + Gd_284 + Gd_296 + Gd_308;
   if (Ld_3260 != Ld_3252) Alert("The sum of the coefs must be ", Ld_3252, ". Your setting is ", Ld_3260, "!!!");
   int Li_3268 = OrdersTotal();
   for (int Li_3272 = 0; Li_3272 < Li_3268; Li_3272++) OrderSelect(Li_3272, SELECT_BY_POS, MODE_TRADES);
   color Li_3276 = White;
   color Li_3280 = White;
   if (Gi_84 == TRUE) {
      Ls_1624 = "";
      Li_1632 = SkyBlue;
      Ld_1636 = Period();
      Ls_1644 = Symbol();
      if (Ld_1636 == 1.0) Ls_1624 = "M1";
      if (Ld_1636 == 5.0) Ls_1624 = "M5";
      if (Ld_1636 == 15.0) Ls_1624 = "M15";
      if (Ld_1636 == 30.0) Ls_1624 = "M30";
      if (Ld_1636 == 60.0) Ls_1624 = "H1";
      if (Ld_1636 == 240.0) Ls_1624 = "H4";
      if (Ld_1636 == 1440.0) Ls_1624 = "D1";
      if (Ld_1636 == 10080.0) Ls_1624 = "W1";
      if (Ld_1636 == 43200.0) Ls_1624 = "MN";
      Li_1652 = 0;
      Li_1656 = Gi_88 + 10;
      Li_1660 = Gi_92 - 15 + 15;
      Li_1664 = 0;
      Li_1668 = Gi_88 + 2;
      Li_1672 = Gi_92 - 15 + 27;
      Li_1676 = Gi_92 - 15 + 77;
      Li_1680 = Gi_92 - 15 + 117;
      Li_1684 = Gi_92 - 15 + 140;
      Li_1688 = 0;
      Li_1692 = Gi_88 + 3;
      Li_1696 = 0;
      Li_1700 = Gi_88 + 92;
      Li_1704 = Gi_92 - 15 + 43;
      Li_1708 = Gi_92 - 15 + 43;
      Li_1712 = Gi_92 - 15 + 62;
      Li_1716 = Gi_92 - 15 + 62;
      Li_1720 = Gi_92 - 15 + 88;
      Li_1724 = Gi_92 - 15 + 88;
      Li_1728 = Gi_92 - 15 + 106;
      Li_1732 = Gi_92 - 15 + 106;
      Li_1736 = Gi_92 - 15 + 129;
      Li_1740 = Gi_92 - 15 + 129;
      ObjectCreate("timeframe", OBJ_LABEL, Window, 0, 0);
      ObjectSetText("timeframe", "+  " + Ls_1644 + "  " + Ls_1624 + "  +", 9, "Verdana", Li_1632);
      ObjectSet("timeframe", OBJPROP_CORNER, Li_1652);
      ObjectSet("timeframe", OBJPROP_XDISTANCE, Li_1656);
      ObjectSet("timeframe", OBJPROP_YDISTANCE, Li_1660);
      ObjectCreate("line1", OBJ_LABEL, Window, 0, 0);
      ObjectSetText("line1", "--------------------------", 7, "Verdana", Li_3276);
      ObjectSet("line1", OBJPROP_CORNER, Li_1664);
      ObjectSet("line1", OBJPROP_XDISTANCE, Li_1668);
      ObjectSet("line1", OBJPROP_YDISTANCE, Li_1672);
      ObjectCreate("stoploss", OBJ_LABEL, Window, 0, 0);
      ObjectSetText("stoploss", "Stop Loss", 7, "Verdana", Li_3280);
      ObjectSet("stoploss", OBJPROP_CORNER, Li_1688);
      ObjectSet("stoploss", OBJPROP_XDISTANCE, Li_1692);
      ObjectSet("stoploss", OBJPROP_YDISTANCE, Li_1704);
      Ls_1744 = "";
      if (OrderStopLoss() > 0.0) {
         Ls_1744 = DoubleToStr(OrderStopLoss(), 2);
         Li_1752 = Orange;
      }
      if (Li_3268 == 0 || OrderStopLoss() == 0.0) {
         Ls_1744 = "-------";
         Li_1752 = Red;
      }
      ObjectCreate("Stop", OBJ_LABEL, Window, 0, 0);
      ObjectSetText("Stop", Ls_1744, 7, "Verdana", Li_1752);
      ObjectSet("Stop", OBJPROP_CORNER, Li_1696);
      ObjectSet("Stop", OBJPROP_XDISTANCE, Li_1700);
      ObjectSet("Stop", OBJPROP_YDISTANCE, Li_1708);
      ObjectCreate("pipstostop", OBJ_LABEL, Window, 0, 0);
      ObjectSetText("pipstostop", "Pips to Stop", 7, "Verdana", Li_3280);
      ObjectSet("pipstostop", OBJPROP_CORNER, Li_1688);
      ObjectSet("pipstostop", OBJPROP_XDISTANCE, Li_1692);
      ObjectSet("pipstostop", OBJPROP_YDISTANCE, Li_1712);
      Ls_1756 = "";
      if (OrderStopLoss() > 0.0 && OrderType() == OP_BUY) {
         Ls_1756 = DoubleToStr(100.0 * (Bid - OrderStopLoss()), 0) + " pips";
         Li_1764 = Orange;
      }
      if (OrderStopLoss() > 0.0 && OrderType() == OP_SELL) {
         Ls_1756 = DoubleToStr(100.0 * (OrderStopLoss() - Ask), 0) + " pips";
         Li_1764 = Orange;
      }
      if (Li_3268 == 0 || OrderStopLoss() == 0.0) {
         Ls_1756 = "-------";
         Li_1764 = Red;
      }
      ObjectCreate("PipsStop", OBJ_LABEL, Window, 0, 0);
      ObjectSetText("PipsStop", Ls_1756, 7, "Verdana", Li_1764);
      ObjectSet("PipsStop", OBJPROP_CORNER, Li_1696);
      ObjectSet("PipsStop", OBJPROP_XDISTANCE, Li_1700);
      ObjectSet("PipsStop", OBJPROP_YDISTANCE, Li_1716);
      ObjectCreate("line2", OBJ_LABEL, Window, 0, 0);
      ObjectSetText("line2", "--------------------------", 7, "Verdana", Li_3276);
      ObjectSet("line2", OBJPROP_CORNER, Li_1664);
      ObjectSet("line2", OBJPROP_XDISTANCE, Li_1668);
      ObjectSet("line2", OBJPROP_YDISTANCE, Li_1676);
      ObjectCreate("pipsprofit", OBJ_LABEL, Window, 0, 0);
      ObjectSetText("pipsprofit", "Pips Profit", 7, "Verdana", Li_3280);
      ObjectSet("pipsprofit", OBJPROP_CORNER, Li_1688);
      ObjectSet("pipsprofit", OBJPROP_XDISTANCE, Li_1692);
      ObjectSet("pipsprofit", OBJPROP_YDISTANCE, Li_1720);
      Ls_1768 = "";
      if (Li_3268 == 0) {
         Ls_1768 = "-------";
         Li_1776 = Red;
      } else {
         Ls_1768 = DoubleToStr(OrderProfit() / (OrderLots() * Gd_136), 0) + " pips";
         if (StrToDouble(Ls_1768) >= 0.0) Li_1776 = Lime;
         else Li_1776 = Red;
      }
      ObjectCreate("pips_profit", OBJ_LABEL, Window, 0, 0);
      ObjectSetText("pips_profit", Ls_1768, 7, "Verdana", Li_1776);
      ObjectSet("pips_profit", OBJPROP_CORNER, Li_1696);
      ObjectSet("pips_profit", OBJPROP_XDISTANCE, Li_1700);
      ObjectSet("pips_profit", OBJPROP_YDISTANCE, Li_1724);
      ObjectCreate("percentbalance", OBJ_LABEL, Window, 0, 0);
      ObjectSetText("percentbalance", "% of Balance", 7, "Verdana", Li_3280);
      ObjectSet("percentbalance", OBJPROP_CORNER, Li_1688);
      ObjectSet("percentbalance", OBJPROP_XDISTANCE, Li_1692);
      ObjectSet("percentbalance", OBJPROP_YDISTANCE, Li_1728);
      Ls_1780 = "";
      if (Li_3268 == 0) {
         Ls_1780 = "-------";
         Li_1788 = Red;
      } else {
         Ls_1780 = DoubleToStr(100.0 * ((OrderProfit() - OrderSwap()) / AccountBalance()), 2) + " %";
         if (StrToDouble(Ls_1780) >= 0.0) Li_1788 = Lime;
         else Li_1788 = Red;
      }
      ObjectCreate("percent_profit", OBJ_LABEL, Window, 0, 0);
      ObjectSetText("percent_profit", Ls_1780, 7, "Verdana", Li_1788);
      ObjectSet("percent_profit", OBJPROP_CORNER, Li_1696);
      ObjectSet("percent_profit", OBJPROP_XDISTANCE, Li_1700);
      ObjectSet("percent_profit", OBJPROP_YDISTANCE, Li_1732);
      ObjectCreate("line3", OBJ_LABEL, Window, 0, 0);
      ObjectSetText("line3", "--------------------------", 7, "Verdana", Li_3276);
      ObjectSet("line3", OBJPROP_CORNER, Li_1664);
      ObjectSet("line3", OBJPROP_XDISTANCE, Li_1668);
      ObjectSet("line3", OBJPROP_YDISTANCE, Li_1680);
      ObjectCreate("maxlot1", OBJ_LABEL, Window, 0, 0);
      ObjectSetText("maxlot1", "Max lot to trade", 7, "Verdana", Li_3280);
      ObjectSet("maxlot1", OBJPROP_CORNER, Li_1688);
      ObjectSet("maxlot1", OBJPROP_XDISTANCE, Li_1692);
      ObjectSet("maxlot1", OBJPROP_YDISTANCE, Li_1736);
      Ls_1792 = "";
      Li_1800 = Orange;
      if (Li_3268 > 0) {
         if (Gi_124 == TRUE) Ls_1792 = DoubleToStr(AccountBalance() / 10000.0 * Gd_128 - OrderLots(), 2);
         else Ls_1792 = DoubleToStr(AccountBalance() / 100000.0 * Gd_128 - OrderLots(), 2);
      } else {
         if (Gi_124 == TRUE) Ls_1792 = DoubleToStr(AccountBalance() / 10000.0 * Gd_128, 2);
         else Ls_1792 = DoubleToStr(AccountBalance() / 100000.0 * Gd_128, 2);
      }
      ObjectCreate("maxlot2", OBJ_LABEL, Window, 0, 0);
      ObjectSetText("maxlot2", Ls_1792, 7, "Verdana", Li_1800);
      ObjectSet("maxlot2", OBJPROP_CORNER, Li_1696);
      ObjectSet("maxlot2", OBJPROP_XDISTANCE, Li_1700);
      ObjectSet("maxlot2", OBJPROP_YDISTANCE, Li_1740);
      ObjectCreate("line4", OBJ_LABEL, Window, 0, 0);
      ObjectSetText("line4", "--------------------------", 7, "Verdana", Li_3276);
      ObjectSet("line4", OBJPROP_CORNER, Li_1664);
      ObjectSet("line4", OBJPROP_XDISTANCE, Li_1668);
      ObjectSet("line4", OBJPROP_YDISTANCE, Li_1684);
   }
   if (Gi_336 == TRUE) {
      Ld_1804 = iBarShift(NULL, PERIOD_M1, Gi_324, FALSE);
      Ld_1812 = iBarShift(NULL, PERIOD_M5, Gi_324, FALSE);
      Ld_1820 = iBarShift(NULL, PERIOD_M15, Gi_324, FALSE);
      Ld_1828 = iBarShift(NULL, PERIOD_M30, Gi_324, FALSE);
      Ld_1836 = iBarShift(NULL, PERIOD_H1, Gi_324, FALSE);
      Ld_1844 = iBarShift(NULL, PERIOD_H4, Gi_324, FALSE);
      Ld_1852 = iBarShift(NULL, PERIOD_D1, Gi_324, FALSE);
      Ld_1860 = iBarShift(NULL, PERIOD_W1, Gi_324, FALSE);
   } else {
      Ld_1804 = Gd_328;
      Ld_1812 = Gd_328;
      Ld_1820 = Gd_328;
      Ld_1828 = Gd_328;
      Ld_1836 = Gd_328;
      Ld_1844 = Gd_328;
      Ld_1852 = Gd_328;
      Ld_1860 = Gd_328;
   }
   if (Gi_160 == TRUE) {
      if (Gi_232 == TRUE) {
         Ld_1868 = iMA(NULL, PERIOD_M1, Gi_348, 0, Gi_360, Gi_364, Ld_1804);
         Ld_1876 = iMA(NULL, PERIOD_M1, Gi_348, 0, Gi_360, Gi_364, Ld_1804 + 1.0);
         if (Ld_1868 > Ld_1876) {
            Ld_0 = 1;
            Ld_448 = 0;
         }
         if (Ld_1868 < Ld_1876) {
            Ld_0 = 0;
            Ld_448 = 1;
         }
      }
      if (Gi_244 == TRUE) {
         Ld_1884 = iMA(NULL, PERIOD_M5, Gi_348, 0, Gi_360, Gi_364, Ld_1812);
         Ld_1892 = iMA(NULL, PERIOD_M5, Gi_348, 0, Gi_360, Gi_364, Ld_1812 + 1.0);
         if (Ld_1884 > Ld_1892) {
            Ld_8 = 1;
            Ld_456 = 0;
         }
         if (Ld_1884 < Ld_1892) {
            Ld_8 = 0;
            Ld_456 = 1;
         }
      }
      if (Gi_256 == TRUE) {
         Ld_1900 = iMA(NULL, PERIOD_M15, Gi_348, 0, Gi_360, Gi_364, Ld_1820);
         Ld_1908 = iMA(NULL, PERIOD_M15, Gi_348, 0, Gi_360, Gi_364, Ld_1820 + 1.0);
         if (Ld_1900 > Ld_1908) {
            Ld_16 = 1;
            Ld_464 = 0;
         }
         if (Ld_1900 < Ld_1908) {
            Ld_16 = 0;
            Ld_464 = 1;
         }
      }
      if (Gi_268 == TRUE) {
         Ld_1916 = iMA(NULL, PERIOD_M30, Gi_348, 0, Gi_360, Gi_364, Ld_1828);
         Ld_1924 = iMA(NULL, PERIOD_M30, Gi_348, 0, Gi_360, Gi_364, Ld_1828 + 1.0);
         if (Ld_1916 > Ld_1924) {
            Ld_24 = 1;
            Ld_472 = 0;
         }
         if (Ld_1916 < Ld_1924) {
            Ld_24 = 0;
            Ld_472 = 1;
         }
      }
      if (Gi_280 == TRUE) {
         Ld_1932 = iMA(NULL, PERIOD_H1, Gi_348, 0, Gi_360, Gi_364, Ld_1836);
         Ld_1940 = iMA(NULL, PERIOD_H1, Gi_348, 0, Gi_360, Gi_364, Ld_1836 + 1.0);
         if (Ld_1932 > Ld_1940) {
            Ld_32 = 1;
            Ld_480 = 0;
         }
         if (Ld_1932 < Ld_1940) {
            Ld_32 = 0;
            Ld_480 = 1;
         }
      }
      if (Gi_292 == TRUE) {
         Ld_1948 = iMA(NULL, PERIOD_H4, Gi_348, 0, Gi_360, Gi_364, Ld_1844);
         Ld_1956 = iMA(NULL, PERIOD_H4, Gi_348, 0, Gi_360, Gi_364, Ld_1844 + 1.0);
         if (Ld_1948 > Ld_1956) {
            Ld_40 = 1;
            Ld_488 = 0;
         }
         if (Ld_1948 < Ld_1956) {
            Ld_40 = 0;
            Ld_488 = 1;
         }
      }
      if (Gi_304 == TRUE) {
         Ld_1964 = iMA(NULL, PERIOD_D1, Gi_348, 0, Gi_360, Gi_364, Ld_1852);
         Ld_1972 = iMA(NULL, PERIOD_D1, Gi_348, 0, Gi_360, Gi_364, Ld_1852 + 1.0);
         if (Ld_1964 > Ld_1972) {
            Ld_48 = 1;
            Ld_496 = 0;
         }
         if (Ld_1964 < Ld_1972) {
            Ld_48 = 0;
            Ld_496 = 1;
         }
      }
   }
   if (Gi_164 == TRUE) {
      if (Gi_232 == TRUE) {
         Ld_1980 = iMA(NULL, PERIOD_M1, Gi_352, 0, Gi_360, Gi_364, Ld_1804);
         Ld_1988 = iMA(NULL, PERIOD_M1, Gi_352, 0, Gi_360, Gi_364, Ld_1804 + 1.0);
         if (Ld_1980 > Ld_1988) {
            Ld_56 = 1;
            Ld_504 = 0;
         }
         if (Ld_1980 < Ld_1988) {
            Ld_56 = 0;
            Ld_504 = 1;
         }
      }
      if (Gi_244 == TRUE) {
         Ld_1996 = iMA(NULL, PERIOD_M5, Gi_352, 0, Gi_360, Gi_364, Ld_1812);
         Ld_2004 = iMA(NULL, PERIOD_M5, Gi_352, 0, Gi_360, Gi_364, Ld_1812 + 1.0);
         if (Ld_1996 > Ld_2004) {
            Ld_64 = 1;
            Ld_512 = 0;
         }
         if (Ld_1996 < Ld_2004) {
            Ld_64 = 0;
            Ld_512 = 1;
         }
      }
      if (Gi_256 == TRUE) {
         Ld_2012 = iMA(NULL, PERIOD_M15, Gi_352, 0, Gi_360, Gi_364, Ld_1820);
         Ld_2020 = iMA(NULL, PERIOD_M15, Gi_352, 0, Gi_360, Gi_364, Ld_1820 + 1.0);
         if (Ld_2012 > Ld_2020) {
            Ld_72 = 1;
            Ld_520 = 0;
         }
         if (Ld_2012 < Ld_2020) {
            Ld_72 = 0;
            Ld_520 = 1;
         }
      }
      if (Gi_268 == TRUE) {
         Ld_2028 = iMA(NULL, PERIOD_M30, Gi_352, 0, Gi_360, Gi_364, Ld_1828);
         Ld_2036 = iMA(NULL, PERIOD_M30, Gi_352, 0, Gi_360, Gi_364, Ld_1828 + 1.0);
         if (Ld_2028 > Ld_2036) {
            Ld_80 = 1;
            Ld_528 = 0;
         }
         if (Ld_2028 < Ld_2036) {
            Ld_80 = 0;
            Ld_528 = 1;
         }
      }
      if (Gi_280 == TRUE) {
         Ld_2044 = iMA(NULL, PERIOD_H1, Gi_352, 0, Gi_360, Gi_364, Ld_1836);
         Ld_2052 = iMA(NULL, PERIOD_H1, Gi_352, 0, Gi_360, Gi_364, Ld_1836 + 1.0);
         if (Ld_2044 > Ld_2052) {
            Ld_88 = 1;
            Ld_536 = 0;
         }
         if (Ld_2044 < Ld_2052) {
            Ld_88 = 0;
            Ld_536 = 1;
         }
      }
      if (Gi_292 == TRUE) {
         Ld_2060 = iMA(NULL, PERIOD_H4, Gi_352, 0, Gi_360, Gi_364, Ld_1844);
         Ld_2068 = iMA(NULL, PERIOD_H4, Gi_352, 0, Gi_360, Gi_364, Ld_1844 + 1.0);
         if (Ld_2060 > Ld_2068) {
            Ld_96 = 1;
            Ld_544 = 0;
         }
         if (Ld_2060 < Ld_2068) {
            Ld_96 = 0;
            Ld_544 = 1;
         }
      }
      if (Gi_304 == TRUE) {
         Ld_2076 = iMA(NULL, PERIOD_D1, Gi_352, 0, Gi_360, Gi_364, Ld_1852);
         Ld_2084 = iMA(NULL, PERIOD_D1, Gi_352, 0, Gi_360, Gi_364, Ld_1852 + 1.0);
         if (Ld_2076 > Ld_2084) {
            Ld_104 = 1;
            Ld_552 = 0;
         }
         if (Ld_2076 < Ld_2084) {
            Ld_104 = 0;
            Ld_552 = 1;
         }
      }
   }
   if (Gi_168 == TRUE) {
      if (Gi_232 == TRUE) {
         Ld_2092 = iMA(NULL, PERIOD_M1, Gi_356, 0, Gi_360, Gi_364, Ld_1804);
         Ld_2100 = iMA(NULL, PERIOD_M1, Gi_356, 0, Gi_360, Gi_364, Ld_1804 + 1.0);
         if (Ld_2092 > Ld_2100) {
            Ld_112 = 1;
            Ld_560 = 0;
         }
         if (Ld_2092 < Ld_2100) {
            Ld_112 = 0;
            Ld_560 = 1;
         }
      }
      if (Gi_244 == TRUE) {
         Ld_2108 = iMA(NULL, PERIOD_M5, Gi_356, 0, Gi_360, Gi_364, Ld_1812);
         Ld_2116 = iMA(NULL, PERIOD_M5, Gi_356, 0, Gi_360, Gi_364, Ld_1812 + 1.0);
         if (Ld_2108 > Ld_2116) {
            Ld_120 = 1;
            Ld_568 = 0;
         }
         if (Ld_2108 < Ld_2116) {
            Ld_120 = 0;
            Ld_568 = 1;
         }
      }
      if (Gi_256 == TRUE) {
         Ld_2124 = iMA(NULL, PERIOD_M15, Gi_356, 0, Gi_360, Gi_364, Ld_1820);
         Ld_2132 = iMA(NULL, PERIOD_M15, Gi_356, 0, Gi_360, Gi_364, Ld_1820 + 1.0);
         if (Ld_2124 > Ld_2132) {
            Ld_128 = 1;
            Ld_576 = 0;
         }
         if (Ld_2124 < Ld_2132) {
            Ld_128 = 0;
            Ld_576 = 1;
         }
      }
      if (Gi_268 == TRUE) {
         Ld_2140 = iMA(NULL, PERIOD_M30, Gi_356, 0, Gi_360, Gi_364, Ld_1828);
         Ld_2148 = iMA(NULL, PERIOD_M30, Gi_356, 0, Gi_360, Gi_364, Ld_1828 + 1.0);
         if (Ld_2140 > Ld_2148) {
            Ld_136 = 1;
            Ld_584 = 0;
         }
         if (Ld_2140 < Ld_2148) {
            Ld_136 = 0;
            Ld_584 = 1;
         }
      }
      if (Gi_280 == TRUE) {
         Ld_2156 = iMA(NULL, PERIOD_H1, Gi_356, 0, Gi_360, Gi_364, Ld_1836);
         Ld_2164 = iMA(NULL, PERIOD_H1, Gi_356, 0, Gi_360, Gi_364, Ld_1836 + 1.0);
         if (Ld_2156 > Ld_2164) {
            Ld_144 = 1;
            Ld_592 = 0;
         }
         if (Ld_2156 < Ld_2164) {
            Ld_144 = 0;
            Ld_592 = 1;
         }
      }
      if (Gi_292 == TRUE) {
         Ld_2172 = iMA(NULL, PERIOD_H4, Gi_356, 0, Gi_360, Gi_364, Ld_1844);
         Ld_2180 = iMA(NULL, PERIOD_H4, Gi_356, 0, Gi_360, Gi_364, Ld_1844 + 1.0);
         if (Ld_2172 > Ld_2180) {
            Ld_152 = 1;
            Ld_600 = 0;
         }
         if (Ld_2172 < Ld_2180) {
            Ld_152 = 0;
            Ld_600 = 1;
         }
      }
      if (Gi_304 == TRUE) {
         Ld_2188 = iMA(NULL, PERIOD_D1, Gi_356, 0, Gi_360, Gi_364, Ld_1852);
         Ld_2196 = iMA(NULL, PERIOD_D1, Gi_356, 0, Gi_360, Gi_364, Ld_1852 + 1.0);
         if (Ld_2188 > Ld_2196) {
            Ld_160 = 1;
            Ld_608 = 0;
         }
         if (Ld_2188 < Ld_2196) {
            Ld_160 = 0;
            Ld_608 = 1;
         }
      }
   }
   if (Gi_172 == TRUE) {
      if (Gi_232 == TRUE) {
         Ld_2204 = iCCI(NULL, PERIOD_M1, Gi_376, Gi_380, Ld_1804);
         if (Ld_2204 > 0.0) {
            Ld_168 = 1;
            Ld_616 = 0;
         }
         if (Ld_2204 < 0.0) {
            Ld_168 = 0;
            Ld_616 = 1;
         }
      }
      if (Gi_244 == TRUE) {
         Ld_2212 = iCCI(NULL, PERIOD_M5, Gi_376, Gi_380, Ld_1812);
         if (Ld_2212 > 0.0) {
            Ld_176 = 1;
            Ld_624 = 0;
         }
         if (Ld_2212 < 0.0) {
            Ld_176 = 0;
            Ld_624 = 1;
         }
      }
      if (Gi_256 == TRUE) {
         Ld_2220 = iCCI(NULL, PERIOD_M15, Gi_376, Gi_380, Ld_1820);
         if (Ld_2220 > 0.0) {
            Ld_184 = 1;
            Ld_632 = 0;
         }
         if (Ld_2220 < 0.0) {
            Ld_184 = 0;
            Ld_632 = 1;
         }
      }
      if (Gi_268 == TRUE) {
         Ld_2228 = iCCI(NULL, PERIOD_M30, Gi_376, Gi_380, Ld_1828);
         if (Ld_2228 > 0.0) {
            Ld_192 = 1;
            Ld_640 = 0;
         }
         if (Ld_2228 < 0.0) {
            Ld_192 = 0;
            Ld_640 = 1;
         }
      }
      if (Gi_280 == TRUE) {
         Ld_2236 = iCCI(NULL, PERIOD_H1, Gi_376, Gi_380, Ld_1836);
         if (Ld_2236 > 0.0) {
            Ld_200 = 1;
            Ld_648 = 0;
         }
         if (Ld_2236 < 0.0) {
            Ld_200 = 0;
            Ld_648 = 1;
         }
      }
      if (Gi_292 == TRUE) {
         Ld_2244 = iCCI(NULL, PERIOD_H4, Gi_376, Gi_380, Ld_1844);
         if (Ld_2244 > 0.0) {
            Ld_208 = 1;
            Ld_656 = 0;
         }
         if (Ld_2244 < 0.0) {
            Ld_208 = 0;
            Ld_656 = 1;
         }
      }
      if (Gi_304 == TRUE) {
         Ld_2252 = iCCI(NULL, PERIOD_D1, Gi_376, Gi_380, Ld_1852);
         if (Ld_2252 > 0.0) {
            Ld_216 = 1;
            Ld_664 = 0;
         }
         if (Ld_2252 < 0.0) {
            Ld_216 = 0;
            Ld_664 = 1;
         }
      }
   }
   if (Gi_176 == TRUE) {
      if (Gi_232 == TRUE) {
         Ld_2260 = iMACD(NULL, PERIOD_M1, Gi_392, Gi_396, Gi_400, PRICE_CLOSE, MODE_MAIN, Ld_1804);
         Ld_2268 = iMACD(NULL, PERIOD_M1, Gi_392, Gi_396, Gi_400, PRICE_CLOSE, MODE_SIGNAL, Ld_1804);
         if (Ld_2260 > Ld_2268) {
            Ld_224 = 1;
            Ld_672 = 0;
         }
         if (Ld_2260 < Ld_2268) {
            Ld_224 = 0;
            Ld_672 = 1;
         }
      }
      if (Gi_244 == TRUE) {
         Ld_2276 = iMACD(NULL, PERIOD_M5, Gi_392, Gi_396, Gi_400, PRICE_CLOSE, MODE_MAIN, Ld_1812);
         Ld_2284 = iMACD(NULL, PERIOD_M5, Gi_392, Gi_396, Gi_400, PRICE_CLOSE, MODE_SIGNAL, Ld_1812);
         if (Ld_2276 > Ld_2284) {
            Ld_232 = 1;
            Ld_680 = 0;
         }
         if (Ld_2276 < Ld_2284) {
            Ld_232 = 0;
            Ld_680 = 1;
         }
      }
      if (Gi_256 == TRUE) {
         Ld_2292 = iMACD(NULL, PERIOD_M15, Gi_392, Gi_396, Gi_400, PRICE_CLOSE, MODE_MAIN, Ld_1820);
         Ld_2300 = iMACD(NULL, PERIOD_M15, Gi_392, Gi_396, Gi_400, PRICE_CLOSE, MODE_SIGNAL, Ld_1820);
         if (Ld_2292 > Ld_2300) {
            Ld_240 = 1;
            Ld_688 = 0;
         }
         if (Ld_2292 < Ld_2300) {
            Ld_240 = 0;
            Ld_688 = 1;
         }
      }
      if (Gi_268 == TRUE) {
         Ld_2308 = iMACD(NULL, PERIOD_M30, Gi_392, Gi_396, Gi_400, PRICE_CLOSE, MODE_MAIN, Ld_1828);
         Ld_2316 = iMACD(NULL, PERIOD_M30, Gi_392, Gi_396, Gi_400, PRICE_CLOSE, MODE_SIGNAL, Ld_1828);
         if (Ld_2308 > Ld_2316) {
            Ld_248 = 1;
            Ld_696 = 0;
         }
         if (Ld_2308 < Ld_2316) {
            Ld_248 = 0;
            Ld_696 = 1;
         }
      }
      if (Gi_280 == TRUE) {
         Ld_2324 = iMACD(NULL, PERIOD_H1, Gi_392, Gi_396, Gi_400, PRICE_CLOSE, MODE_MAIN, Ld_1836);
         Ld_2332 = iMACD(NULL, PERIOD_H1, Gi_392, Gi_396, Gi_400, PRICE_CLOSE, MODE_SIGNAL, Ld_1836);
         if (Ld_2324 > Ld_2332) {
            Ld_256 = 1;
            Ld_704 = 0;
         }
         if (Ld_2324 < Ld_2332) {
            Ld_256 = 0;
            Ld_704 = 1;
         }
      }
      if (Gi_292 == TRUE) {
         Ld_2340 = iMACD(NULL, PERIOD_H4, Gi_392, Gi_396, Gi_400, PRICE_CLOSE, MODE_MAIN, Ld_1844);
         Ld_2348 = iMACD(NULL, PERIOD_H4, Gi_392, Gi_396, Gi_400, PRICE_CLOSE, MODE_SIGNAL, Ld_1844);
         if (Ld_2340 > Ld_2348) {
            Ld_264 = 1;
            Ld_712 = 0;
         }
         if (Ld_2340 < Ld_2348) {
            Ld_264 = 0;
            Ld_712 = 1;
         }
      }
      if (Gi_304 == TRUE) {
         Ld_2356 = iMACD(NULL, PERIOD_D1, Gi_392, Gi_396, Gi_400, PRICE_CLOSE, MODE_MAIN, Ld_1852);
         Ld_2364 = iMACD(NULL, PERIOD_D1, Gi_392, Gi_396, Gi_400, PRICE_CLOSE, MODE_SIGNAL, Ld_1852);
         if (Ld_2356 > Ld_2364) {
            Ld_272 = 1;
            Ld_720 = 0;
         }
         if (Ld_2356 < Ld_2364) {
            Ld_272 = 0;
            Ld_720 = 1;
         }
      }
   }
   if (Gi_180 == TRUE) {
      if (Gi_232 == TRUE) {
         Ld_2372 = iADX(NULL, PERIOD_M1, Gi_412, Gi_416, MODE_PLUSDI, Ld_1804);
         Ld_2380 = iADX(NULL, PERIOD_M1, Gi_412, Gi_416, MODE_MINUSDI, Ld_1804);
         if (Ld_2372 > Ld_2380) {
            Ld_280 = 1;
            Ld_728 = 0;
         }
         if (Ld_2372 < Ld_2380) {
            Ld_280 = 0;
            Ld_728 = 1;
         }
      }
      if (Gi_244 == TRUE) {
         Ld_2388 = iADX(NULL, PERIOD_M5, Gi_412, Gi_416, MODE_PLUSDI, Ld_1812);
         Ld_2396 = iADX(NULL, PERIOD_M5, Gi_412, Gi_416, MODE_MINUSDI, Ld_1812);
         if (Ld_2388 > Ld_2396) {
            Ld_288 = 1;
            Ld_736 = 0;
         }
         if (Ld_2388 < Ld_2396) {
            Ld_288 = 0;
            Ld_736 = 1;
         }
      }
      if (Gi_256 == TRUE) {
         Ld_2404 = iADX(NULL, PERIOD_M15, Gi_412, Gi_416, MODE_PLUSDI, Ld_1820);
         Ld_2412 = iADX(NULL, PERIOD_M15, Gi_412, Gi_416, MODE_MINUSDI, Ld_1820);
         if (Ld_2404 > Ld_2412) {
            Ld_296 = 1;
            Ld_744 = 0;
         }
         if (Ld_2404 < Ld_2412) {
            Ld_296 = 0;
            Ld_744 = 1;
         }
      }
      if (Gi_268 == TRUE) {
         Ld_2420 = iADX(NULL, PERIOD_M30, Gi_412, Gi_416, MODE_PLUSDI, Ld_1828);
         Ld_2428 = iADX(NULL, PERIOD_M30, Gi_412, Gi_416, MODE_MINUSDI, Ld_1828);
         if (Ld_2420 > Ld_2428) {
            Ld_304 = 1;
            Ld_752 = 0;
         }
         if (Ld_2420 < Ld_2428) {
            Ld_304 = 0;
            Ld_752 = 1;
         }
      }
      if (Gi_280 == TRUE) {
         Ld_2436 = iADX(NULL, PERIOD_H1, Gi_412, Gi_416, MODE_PLUSDI, Ld_1836);
         Ld_2444 = iADX(NULL, PERIOD_H1, Gi_412, Gi_416, MODE_MINUSDI, Ld_1836);
         if (Ld_2436 > Ld_2444) {
            Ld_312 = 1;
            Ld_760 = 0;
         }
         if (Ld_2436 < Ld_2444) {
            Ld_312 = 0;
            Ld_760 = 1;
         }
      }
      if (Gi_292 == TRUE) {
         Ld_2452 = iADX(NULL, PERIOD_H4, Gi_412, Gi_416, MODE_PLUSDI, Ld_1844);
         Ld_2460 = iADX(NULL, PERIOD_H4, Gi_412, Gi_416, MODE_MINUSDI, Ld_1844);
         if (Ld_2452 > Ld_2460) {
            Ld_320 = 1;
            Ld_768 = 0;
         }
         if (Ld_2452 < Ld_2460) {
            Ld_320 = 0;
            Ld_768 = 1;
         }
      }
      if (Gi_304 == TRUE) {
         Ld_2468 = iADX(NULL, PERIOD_D1, Gi_412, Gi_416, MODE_PLUSDI, Ld_1852);
         Ld_2476 = iADX(NULL, PERIOD_D1, Gi_412, Gi_416, MODE_MINUSDI, Ld_1852);
         if (Ld_2468 > Ld_2476) {
            Ld_328 = 1;
            Ld_776 = 0;
         }
         if (Ld_2468 < Ld_2476) {
            Ld_328 = 0;
            Ld_776 = 1;
         }
      }
   }
   if (Gi_184 == TRUE) {
      if (Gi_232 == TRUE) {
         Ld_2484 = iBullsPower(NULL, PERIOD_M1, Gi_428, Gi_432, Ld_1804);
         if (Ld_2484 > 0.0) {
            Ld_336 = 1;
            Ld_784 = 0;
         }
         if (Ld_2484 < 0.0) {
            Ld_336 = 0;
            Ld_784 = 1;
         }
      }
      if (Gi_244 == TRUE) {
         Ld_2492 = iBullsPower(NULL, PERIOD_M5, Gi_428, Gi_432, Ld_1812);
         if (Ld_2492 > 0.0) {
            Ld_344 = 1;
            Ld_792 = 0;
         }
         if (Ld_2492 < 0.0) {
            Ld_344 = 0;
            Ld_792 = 1;
         }
      }
      if (Gi_256 == TRUE) {
         Ld_2500 = iBullsPower(NULL, PERIOD_M15, Gi_428, Gi_432, Ld_1820);
         if (Ld_2500 > 0.0) {
            Ld_352 = 1;
            Ld_800 = 0;
         }
         if (Ld_2500 < 0.0) {
            Ld_352 = 0;
            Ld_800 = 1;
         }
      }
      if (Gi_268 == TRUE) {
         Ld_2508 = iBullsPower(NULL, PERIOD_M30, Gi_428, Gi_432, Ld_1828);
         if (Ld_2508 > 0.0) {
            Ld_360 = 1;
            Ld_808 = 0;
         }
         if (Ld_2508 < 0.0) {
            Ld_360 = 0;
            Ld_808 = 1;
         }
      }
      if (Gi_280 == TRUE) {
         Ld_2516 = iBullsPower(NULL, PERIOD_H1, Gi_428, Gi_432, Ld_1836);
         if (Ld_2516 > 0.0) {
            Ld_368 = 1;
            Ld_816 = 0;
         }
         if (Ld_2516 < 0.0) {
            Ld_368 = 0;
            Ld_816 = 1;
         }
      }
      if (Gi_292 == TRUE) {
         Ld_2524 = iBullsPower(NULL, PERIOD_H4, Gi_428, Gi_432, Ld_1844);
         if (Ld_2524 > 0.0) {
            Ld_376 = 1;
            Ld_824 = 0;
         }
         if (Ld_2524 < 0.0) {
            Ld_376 = 0;
            Ld_824 = 1;
         }
      }
      if (Gi_304 == TRUE) {
         Ld_2532 = iBullsPower(NULL, PERIOD_D1, Gi_428, Gi_432, Ld_1852);
         if (Ld_2532 > 0.0) {
            Ld_384 = 1;
            Ld_832 = 0;
         }
         if (Ld_2532 < 0.0) {
            Ld_384 = 0;
            Ld_832 = 1;
         }
      }
   }
   if (Gi_188 == TRUE) {
      if (Gi_232 == TRUE) {
         Ld_2540 = iBearsPower(NULL, PERIOD_M1, Gi_444, Gi_448, Ld_1804);
         if (Ld_2540 > 0.0) {
            Ld_392 = 1;
            Ld_840 = 0;
         }
         if (Ld_2540 < 0.0) {
            Ld_392 = 0;
            Ld_840 = 1;
         }
      }
      if (Gi_244 == TRUE) {
         Ld_2548 = iBearsPower(NULL, PERIOD_M5, Gi_444, Gi_448, Ld_1812);
         if (Ld_2548 > 0.0) {
            Ld_400 = 1;
            Ld_848 = 0;
         }
         if (Ld_2548 < 0.0) {
            Ld_400 = 0;
            Ld_848 = 1;
         }
      }
      if (Gi_256 == TRUE) {
         Ld_2556 = iBearsPower(NULL, PERIOD_M15, Gi_444, Gi_448, Ld_1820);
         if (Ld_2556 > 0.0) {
            Ld_408 = 1;
            Ld_856 = 0;
         }
         if (Ld_2556 < 0.0) {
            Ld_408 = 0;
            Ld_856 = 1;
         }
      }
      if (Gi_268 == TRUE) {
         Ld_2564 = iBearsPower(NULL, PERIOD_M30, Gi_444, Gi_448, Ld_1828);
         if (Ld_2564 > 0.0) {
            Ld_416 = 1;
            Ld_864 = 0;
         }
         if (Ld_2564 < 0.0) {
            Ld_416 = 0;
            Ld_864 = 1;
         }
      }
      if (Gi_280 == TRUE) {
         Ld_2572 = iBearsPower(NULL, PERIOD_H1, Gi_444, Gi_448, Ld_1836);
         if (Ld_2572 > 0.0) {
            Ld_424 = 1;
            Ld_872 = 0;
         }
         if (Ld_2572 < 0.0) {
            Ld_424 = 0;
            Ld_872 = 1;
         }
      }
      if (Gi_292 == TRUE) {
         Ld_2580 = iBearsPower(NULL, PERIOD_H4, Gi_444, Gi_448, Ld_1844);
         if (Ld_2580 > 0.0) {
            Ld_432 = 1;
            Ld_880 = 0;
         }
         if (Ld_2580 < 0.0) {
            Ld_432 = 0;
            Ld_880 = 1;
         }
      }
      if (Gi_304 == TRUE) {
         Ld_2588 = iBearsPower(NULL, PERIOD_D1, Gi_444, Gi_448, Ld_1852);
         if (Ld_2588 > 0.0) {
            Ld_440 = 1;
            Ld_888 = 0;
         }
         if (Ld_2588 < 0.0) {
            Ld_440 = 0;
            Ld_888 = 1;
         }
      }
   }
   if (Gi_192 == TRUE) {
      if (Gi_232 == TRUE) {
         Ld_2596 = iStochastic(NULL, PERIOD_M1, Gi_460, Gi_464, Gi_468, MODE_SMA, 1, MODE_MAIN, Ld_1804);
         Ld_2604 = iStochastic(NULL, PERIOD_M1, Gi_460, Gi_464, Gi_468, MODE_SMA, 1, MODE_SIGNAL, Ld_1804);
         if (Ld_2596 >= Ld_2604) {
            Ld_896 = 1;
            Ld_1232 = 0;
         }
         if (Ld_2596 < Ld_2604) {
            Ld_896 = 0;
            Ld_1232 = 1;
         }
      }
      if (Gi_244 == TRUE) {
         Ld_2612 = iStochastic(NULL, PERIOD_M5, Gi_460, Gi_464, Gi_468, MODE_SMA, 1, MODE_MAIN, Ld_1812);
         Ld_2620 = iStochastic(NULL, PERIOD_M5, Gi_460, Gi_464, Gi_468, MODE_SMA, 1, MODE_SIGNAL, Ld_1812);
         if (Ld_2612 >= Ld_2620) {
            Ld_904 = 1;
            Ld_1240 = 0;
         }
         if (Ld_2612 < Ld_2620) {
            Ld_904 = 0;
            Ld_1240 = 1;
         }
      }
      if (Gi_256 == TRUE) {
         Ld_2628 = iStochastic(NULL, PERIOD_M15, Gi_460, Gi_464, Gi_468, MODE_SMA, 1, MODE_MAIN, Ld_1820);
         Ld_2636 = iStochastic(NULL, PERIOD_M15, Gi_460, Gi_464, Gi_468, MODE_SMA, 1, MODE_SIGNAL, Ld_1820);
         if (Ld_2628 >= Ld_2636) {
            Ld_912 = 1;
            Ld_1248 = 0;
         }
         if (Ld_2628 < Ld_2636) {
            Ld_912 = 0;
            Ld_1248 = 1;
         }
      }
      if (Gi_268 == TRUE) {
         Ld_2644 = iStochastic(NULL, PERIOD_M30, Gi_460, Gi_464, Gi_468, MODE_SMA, 1, MODE_MAIN, Ld_1828);
         Ld_2652 = iStochastic(NULL, PERIOD_M30, Gi_460, Gi_464, Gi_468, MODE_SMA, 1, MODE_SIGNAL, Ld_1828);
         if (Ld_2644 >= Ld_2652) {
            Ld_920 = 1;
            Ld_1256 = 0;
         }
         if (Ld_2644 < Ld_2652) {
            Ld_920 = 0;
            Ld_1256 = 1;
         }
      }
      if (Gi_280 == TRUE) {
         Ld_2660 = iStochastic(NULL, PERIOD_H1, Gi_460, Gi_464, Gi_468, MODE_SMA, 1, MODE_MAIN, Ld_1836);
         Ld_2668 = iStochastic(NULL, PERIOD_H1, Gi_460, Gi_464, Gi_468, MODE_SMA, 1, MODE_SIGNAL, Ld_1836);
         if (Ld_2660 >= Ld_2668) {
            Ld_928 = 1;
            Ld_1264 = 0;
         }
         if (Ld_2660 < Ld_2668) {
            Ld_928 = 0;
            Ld_1264 = 1;
         }
      }
      if (Gi_292 == TRUE) {
         Ld_2676 = iStochastic(NULL, PERIOD_H4, Gi_460, Gi_464, Gi_468, MODE_SMA, 1, MODE_MAIN, Ld_1844);
         Ld_2684 = iStochastic(NULL, PERIOD_H4, Gi_460, Gi_464, Gi_468, MODE_SMA, 1, MODE_SIGNAL, Ld_1844);
         if (Ld_2676 >= Ld_2684) {
            Ld_936 = 1;
            Ld_1272 = 0;
         }
         if (Ld_2676 < Ld_2684) {
            Ld_936 = 0;
            Ld_1272 = 1;
         }
      }
      if (Gi_304 == TRUE) {
         Ld_2692 = iStochastic(NULL, PERIOD_D1, Gi_460, Gi_464, Gi_468, MODE_SMA, 1, MODE_MAIN, Ld_1852);
         Ld_2700 = iStochastic(NULL, PERIOD_D1, Gi_460, Gi_464, Gi_468, MODE_SMA, 1, MODE_SIGNAL, Ld_1852);
         if (Ld_2692 >= Ld_2700) {
            Ld_944 = 1;
            Ld_1280 = 0;
         }
         if (Ld_2692 < Ld_2700) {
            Ld_944 = 0;
            Ld_1280 = 1;
         }
      }
   }
   if (Gi_196 == TRUE) {
      if (Gi_232 == TRUE) {
         Ld_2708 = iRSI(NULL, PERIOD_M1, Gi_480, PRICE_CLOSE, Ld_1804);
         if (Ld_2708 >= 50.0) {
            Ld_952 = 1;
            Ld_1288 = 0;
         }
         if (Ld_2708 < 50.0) {
            Ld_952 = 0;
            Ld_1288 = 1;
         }
      }
      if (Gi_244 == TRUE) {
         Ld_2716 = iRSI(NULL, PERIOD_M5, Gi_480, PRICE_CLOSE, Ld_1812);
         if (Ld_2716 >= 50.0) {
            Ld_960 = 1;
            Ld_1296 = 0;
         }
         if (Ld_2716 < 50.0) {
            Ld_960 = 0;
            Ld_1296 = 1;
         }
      }
      if (Gi_256 == TRUE) {
         Ld_2724 = iRSI(NULL, PERIOD_M15, Gi_480, PRICE_CLOSE, Ld_1820);
         if (Ld_2724 >= 50.0) {
            Ld_968 = 1;
            Ld_1304 = 0;
         }
         if (Ld_2724 < 50.0) {
            Ld_968 = 0;
            Ld_1304 = 1;
         }
      }
      if (Gi_268 == TRUE) {
         Ld_2732 = iRSI(NULL, PERIOD_M30, Gi_480, PRICE_CLOSE, Ld_1828);
         if (Ld_2732 >= 50.0) {
            Ld_976 = 1;
            Ld_1312 = 0;
         }
         if (Ld_2732 < 50.0) {
            Ld_976 = 0;
            Ld_1312 = 1;
         }
      }
      if (Gi_280 == TRUE) {
         Ld_2740 = iRSI(NULL, PERIOD_H1, Gi_480, PRICE_CLOSE, Ld_1836);
         if (Ld_2740 >= 50.0) {
            Ld_984 = 1;
            Ld_1320 = 0;
         }
         if (Ld_2740 < 50.0) {
            Ld_984 = 0;
            Ld_1320 = 1;
         }
      }
      if (Gi_292 == TRUE) {
         Ld_2748 = iRSI(NULL, PERIOD_H4, Gi_480, PRICE_CLOSE, Ld_1844);
         if (Ld_2748 >= 50.0) {
            Ld_992 = 1;
            Ld_1328 = 0;
         }
         if (Ld_2748 < 50.0) {
            Ld_992 = 0;
            Ld_1328 = 1;
         }
      }
      if (Gi_304 == TRUE) {
         Ld_2756 = iRSI(NULL, PERIOD_D1, Gi_480, PRICE_CLOSE, Ld_1852);
         if (Ld_2756 >= 50.0) {
            Ld_1000 = 1;
            Ld_1336 = 0;
         }
         if (Ld_2756 < 50.0) {
            Ld_1000 = 0;
            Ld_1336 = 1;
         }
      }
   }
   if (Gi_200 == TRUE) {
      if (Gi_232 == TRUE) {
         Ld_2764 = iForce(NULL, PERIOD_M1, Gi_492, Gi_496, Gi_500, Ld_1804);
         if (Ld_2764 >= 0.0) {
            Ld_1008 = 1;
            Ld_1344 = 0;
         }
         if (Ld_2764 < 0.0) {
            Ld_1008 = 0;
            Ld_1344 = 1;
         }
      }
      if (Gi_244 == TRUE) {
         Ld_2772 = iForce(NULL, PERIOD_M5, Gi_492, Gi_496, Gi_500, Ld_1812);
         if (Ld_2772 >= 0.0) {
            Ld_1016 = 1;
            Ld_1352 = 0;
         }
         if (Ld_2772 < 0.0) {
            Ld_1016 = 0;
            Ld_1352 = 1;
         }
      }
      if (Gi_256 == TRUE) {
         Ld_2780 = iForce(NULL, PERIOD_M15, Gi_492, Gi_496, Gi_500, Ld_1820);
         if (Ld_2780 >= 0.0) {
            Ld_1024 = 1;
            Ld_1360 = 0;
         }
         if (Ld_2780 < 0.0) {
            Ld_1024 = 0;
            Ld_1360 = 1;
         }
      }
      if (Gi_268 == TRUE) {
         Ld_2788 = iForce(NULL, PERIOD_M30, Gi_492, Gi_496, Gi_500, Ld_1828);
         if (Ld_2788 >= 0.0) {
            Ld_1032 = 1;
            Ld_1368 = 0;
         }
         if (Ld_2788 < 0.0) {
            Ld_1032 = 0;
            Ld_1368 = 1;
         }
      }
      if (Gi_280 == TRUE) {
         Ld_2796 = iForce(NULL, PERIOD_H1, Gi_492, Gi_496, Gi_500, Ld_1836);
         if (Ld_2796 >= 0.0) {
            Ld_1040 = 1;
            Ld_1376 = 0;
         }
         if (Ld_2796 < 0.0) {
            Ld_1040 = 0;
            Ld_1376 = 1;
         }
      }
      if (Gi_292 == TRUE) {
         Ld_2804 = iForce(NULL, PERIOD_H4, Gi_492, Gi_496, Gi_500, Ld_1844);
         if (Ld_2804 >= 0.0) {
            Ld_1048 = 1;
            Ld_1384 = 0;
         }
         if (Ld_2804 < 0.0) {
            Ld_1048 = 0;
            Ld_1384 = 1;
         }
      }
      if (Gi_304 == TRUE) {
         Ld_2812 = iForce(NULL, PERIOD_D1, Gi_492, Gi_496, Gi_500, Ld_1852);
         if (Ld_2812 >= 0.0) {
            Ld_1056 = 1;
            Ld_1392 = 0;
         }
         if (Ld_2812 < 0.0) {
            Ld_1056 = 0;
            Ld_1392 = 1;
         }
      }
   }
   if (Gi_204 == TRUE) {
      if (Gi_232 == TRUE) {
         Ld_2820 = iMomentum(NULL, PERIOD_M1, Gi_512, Gi_516, Ld_1804);
         if (Ld_2820 >= 100.0) {
            Ld_1064 = 1;
            Ld_1400 = 0;
         }
         if (Ld_2820 < 100.0) {
            Ld_1064 = 0;
            Ld_1400 = 1;
         }
      }
      if (Gi_244 == TRUE) {
         Ld_2828 = iMomentum(NULL, PERIOD_M5, Gi_512, Gi_516, Ld_1812);
         if (Ld_2828 >= 100.0) {
            Ld_1072 = 1;
            Ld_1408 = 0;
         }
         if (Ld_2828 < 100.0) {
            Ld_1072 = 0;
            Ld_1408 = 1;
         }
      }
      if (Gi_256 == TRUE) {
         Ld_2836 = iMomentum(NULL, PERIOD_M15, Gi_512, Gi_516, Ld_1820);
         if (Ld_2836 >= 100.0) {
            Ld_1080 = 1;
            Ld_1416 = 0;
         }
         if (Ld_2836 < 100.0) {
            Ld_1080 = 0;
            Ld_1416 = 1;
         }
      }
      if (Gi_268 == TRUE) {
         Ld_2844 = iMomentum(NULL, PERIOD_M30, Gi_512, Gi_516, Ld_1828);
         if (Ld_2844 >= 100.0) {
            Ld_1088 = 1;
            Ld_1424 = 0;
         }
         if (Ld_2844 < 100.0) {
            Ld_1088 = 0;
            Ld_1424 = 1;
         }
      }
      if (Gi_280 == TRUE) {
         Ld_2852 = iMomentum(NULL, PERIOD_H1, Gi_512, Gi_516, Ld_1836);
         if (Ld_2852 >= 100.0) {
            Ld_1096 = 1;
            Ld_1432 = 0;
         }
         if (Ld_2852 < 100.0) {
            Ld_1096 = 0;
            Ld_1432 = 1;
         }
      }
      if (Gi_292 == TRUE) {
         Ld_2860 = iMomentum(NULL, PERIOD_H4, Gi_512, Gi_516, Ld_1844);
         if (Ld_2860 >= 100.0) {
            Ld_1104 = 1;
            Ld_1440 = 0;
         }
         if (Ld_2860 < 100.0) {
            Ld_1104 = 0;
            Ld_1440 = 1;
         }
      }
      if (Gi_304 == TRUE) {
         Ld_2868 = iMomentum(NULL, PERIOD_D1, Gi_512, Gi_516, Ld_1852);
         if (Ld_2868 >= 100.0) {
            Ld_1112 = 1;
            Ld_1448 = 0;
         }
         if (Ld_2868 < 100.0) {
            Ld_1112 = 0;
            Ld_1448 = 1;
         }
      }
   }
   if (Gi_208 == TRUE) {
      if (Gi_232 == TRUE) {
         Ld_2876 = iDeMarker(NULL, PERIOD_M1, Gi_528, Ld_1804);
         Ld_2884 = iDeMarker(NULL, PERIOD_M1, Gi_528, Ld_1804 + 1.0);
         if (Ld_2876 >= Ld_2884) {
            Ld_1120 = 1;
            Ld_1456 = 0;
         }
         if (Ld_2876 < Ld_2884) {
            Ld_1120 = 0;
            Ld_1456 = 1;
         }
      }
      if (Gi_244 == TRUE) {
         Ld_2892 = iDeMarker(NULL, PERIOD_M5, Gi_528, Ld_1812);
         Ld_2900 = iDeMarker(NULL, PERIOD_M5, Gi_528, Ld_1812 + 1.0);
         if (Ld_2892 >= Ld_2900) {
            Ld_1128 = 1;
            Ld_1464 = 0;
         }
         if (Ld_2892 < Ld_2900) {
            Ld_1128 = 0;
            Ld_1464 = 1;
         }
      }
      if (Gi_256 == TRUE) {
         Ld_2908 = iDeMarker(NULL, PERIOD_M15, Gi_528, Ld_1820);
         Ld_2916 = iDeMarker(NULL, PERIOD_M15, Gi_528, Ld_1820 + 1.0);
         if (Ld_2908 >= Ld_2916) {
            Ld_1136 = 1;
            Ld_1472 = 0;
         }
         if (Ld_2908 < Ld_2916) {
            Ld_1136 = 0;
            Ld_1472 = 1;
         }
      }
      if (Gi_268 == TRUE) {
         Ld_2924 = iDeMarker(NULL, PERIOD_M30, Gi_528, Ld_1828);
         Ld_2932 = iDeMarker(NULL, PERIOD_M30, Gi_528, Ld_1828 + 1.0);
         if (Ld_2924 >= Ld_2932) {
            Ld_1144 = 1;
            Ld_1480 = 0;
         }
         if (Ld_2924 < Ld_2932) {
            Ld_1144 = 0;
            Ld_1480 = 1;
         }
      }
      if (Gi_280 == TRUE) {
         Ld_2940 = iDeMarker(NULL, PERIOD_H1, Gi_528, Ld_1836);
         Ld_2948 = iDeMarker(NULL, PERIOD_H1, Gi_528, Ld_1836 + 1.0);
         if (Ld_2940 >= Ld_2948) {
            Ld_1152 = 1;
            Ld_1488 = 0;
         }
         if (Ld_2940 < Ld_2948) {
            Ld_1152 = 0;
            Ld_1488 = 1;
         }
      }
      if (Gi_292 == TRUE) {
         Ld_2956 = iDeMarker(NULL, PERIOD_H4, Gi_528, Ld_1844);
         Ld_2964 = iDeMarker(NULL, PERIOD_H4, Gi_528, Ld_1844 + 1.0);
         if (Ld_2956 >= Ld_2964) {
            Ld_1160 = 1;
            Ld_1496 = 0;
         }
         if (Ld_2956 < Ld_2964) {
            Ld_1160 = 0;
            Ld_1496 = 1;
         }
      }
      if (Gi_304 == TRUE) {
         Ld_2972 = iDeMarker(NULL, PERIOD_D1, Gi_528, Ld_1852);
         Ld_2980 = iDeMarker(NULL, PERIOD_D1, Gi_528, Ld_1852 + 1.0);
         if (Ld_2972 >= Ld_2980) {
            Ld_1168 = 1;
            Ld_1504 = 0;
         }
         if (Ld_2972 < Ld_2980) {
            Ld_1168 = 0;
            Ld_1504 = 1;
         }
      }
   }
   if (Gi_212 == TRUE) {
      if (Gi_232 == TRUE) {
         Ld_2988 = iCustom(NULL, PERIOD_M1, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 0, Ld_1804);
         Ld_2996 = iCustom(NULL, PERIOD_M1, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 0, Ld_1804 + 1.0);
         Ld_3004 = iCustom(NULL, PERIOD_M1, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 1, Ld_1804);
         Ld_3012 = iCustom(NULL, PERIOD_M1, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 1, Ld_1804 + 1.0);
         if (Ld_2988 > Ld_2996 || Ld_3004 < Ld_3012) {
            Ld_1176 = 1;
            Ld_1512 = 0;
         }
         if (Ld_2988 < Ld_2996 || Ld_3004 > Ld_3012) {
            Ld_1176 = 0;
            Ld_1512 = 1;
         }
      }
      if (Gi_244 == TRUE) {
         Ld_3020 = iCustom(NULL, PERIOD_M5, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 0, Ld_1812);
         Ld_3028 = iCustom(NULL, PERIOD_M5, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 0, Ld_1812 + 1.0);
         Ld_3036 = iCustom(NULL, PERIOD_M5, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 1, Ld_1812);
         Ld_3044 = iCustom(NULL, PERIOD_M5, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 1, Ld_1812 + 1.0);
         if (Ld_3020 > Ld_3028 || Ld_3036 < Ld_3044) {
            Ld_1184 = 1;
            Ld_1520 = 0;
         }
         if (Ld_3020 < Ld_3028 || Ld_3036 > Ld_3044) {
            Ld_1184 = 0;
            Ld_1520 = 1;
         }
      }
      if (Gi_256 == TRUE) {
         Ld_3052 = iCustom(NULL, PERIOD_M15, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 0, Ld_1820);
         Ld_3060 = iCustom(NULL, PERIOD_M15, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 0, Ld_1820 + 1.0);
         Ld_3068 = iCustom(NULL, PERIOD_M15, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 1, Ld_1820);
         Ld_3076 = iCustom(NULL, PERIOD_M15, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 1, Ld_1820 + 1.0);
         if (Ld_3052 > Ld_3060 || Ld_3068 < Ld_3076) {
            Ld_1192 = 1;
            Ld_1528 = 0;
         }
         if (Ld_3052 < Ld_3060 || Ld_3068 > Ld_3076) {
            Ld_1192 = 0;
            Ld_1528 = 1;
         }
      }
      if (Gi_268 == TRUE) {
         Ld_3084 = iCustom(NULL, PERIOD_M30, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 0, Ld_1828);
         Ld_3092 = iCustom(NULL, PERIOD_M30, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 0, Ld_1828 + 1.0);
         Ld_3100 = iCustom(NULL, PERIOD_M30, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 1, Ld_1828);
         Ld_3108 = iCustom(NULL, PERIOD_M30, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 1, Ld_1828 + 1.0);
         if (Ld_3084 > Ld_3092 || Ld_3100 < Ld_3108) {
            Ld_1200 = 1;
            Ld_1536 = 0;
         }
         if (Ld_3084 < Ld_3092 || Ld_3100 > Ld_3108) {
            Ld_1200 = 0;
            Ld_1536 = 1;
         }
      }
      if (Gi_280 == TRUE) {
         Ld_3116 = iCustom(NULL, PERIOD_H1, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 0, Ld_1836);
         Ld_3124 = iCustom(NULL, PERIOD_H1, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 0, Ld_1836 + 1.0);
         Ld_3132 = iCustom(NULL, PERIOD_H1, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 1, Ld_1836);
         Ld_3140 = iCustom(NULL, PERIOD_H1, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 1, Ld_1836 + 1.0);
         if (Ld_3116 > Ld_3124 || Ld_3132 < Ld_3140) {
            Ld_1208 = 1;
            Ld_1544 = 0;
         }
         if (Ld_3116 < Ld_3124 || Ld_3132 > Ld_3140) {
            Ld_1208 = 0;
            Ld_1544 = 1;
         }
      }
      if (Gi_292 == TRUE) {
         Ld_3148 = iCustom(NULL, PERIOD_H4, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 0, Ld_1844);
         Ld_3156 = iCustom(NULL, PERIOD_H4, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 0, Ld_1844 + 1.0);
         Ld_3164 = iCustom(NULL, PERIOD_H4, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 1, Ld_1844);
         Ld_3172 = iCustom(NULL, PERIOD_H4, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 1, Ld_1844 + 1.0);
         if (Ld_3148 > Ld_3156 || Ld_3164 < Ld_3172) {
            Ld_1216 = 1;
            Ld_1552 = 0;
         }
         if (Ld_3148 < Ld_3156 || Ld_3164 > Ld_3172) {
            Ld_1216 = 0;
            Ld_1552 = 1;
         }
      }
      if (Gi_304 == TRUE) {
         Ld_3180 = iCustom(NULL, PERIOD_D1, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 0, Ld_1852);
         Ld_3188 = iCustom(NULL, PERIOD_D1, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 0, Ld_1852 + 1.0);
         Ld_3196 = iCustom(NULL, PERIOD_D1, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 1, Ld_1852);
         Ld_3204 = iCustom(NULL, PERIOD_D1, "Waddah_Attar_Explosion", 150, 30, 15, 15, 0, 1, 0, 0, 0, 0, 1, Ld_1852 + 1.0);
         if (Ld_3180 > Ld_3188 || Ld_3196 < Ld_3204) {
            Ld_1224 = 1;
            Ld_1560 = 0;
         }
         if (Ld_3180 < Ld_3188 || Ld_3196 > Ld_3204) {
            Ld_1224 = 0;
            Ld_1560 = 1;
         }
      }
   }
   double Ld_3284 = Ld_0 + Ld_56 + Ld_112 + Ld_168 + Ld_224 + Ld_280 + Ld_336 + Ld_392 + Ld_896 + Ld_952 + Ld_1008 + Ld_1064 + Ld_1120 + Ld_1176 + Ld_8 + Ld_64 + Ld_120 +
      Ld_176 + Ld_232 + Ld_288 + Ld_344 + Ld_400 + Ld_904 + Ld_960 + Ld_1016 + Ld_1072 + Ld_1128 + Ld_1184 + Ld_16 + Ld_72 + Ld_128 + Ld_184 + Ld_240 + Ld_296 + Ld_352 +
      Ld_408 + Ld_912 + Ld_968 + Ld_1024 + Ld_1080 + Ld_1136 + Ld_1192 + Ld_24 + Ld_80 + Ld_136 + Ld_192 + Ld_248 + Ld_304 + Ld_360 + Ld_416 + Ld_920 + Ld_976 + Ld_1032 +
      Ld_1088 + Ld_1144 + Ld_1200 + Ld_32 + Ld_88 + Ld_144 + Ld_200 + Ld_256 + Ld_312 + Ld_368 + Ld_424 + Ld_928 + Ld_984 + Ld_1040 + Ld_1096 + Ld_1152 + Ld_1208 + Ld_40 +
      Ld_96 + Ld_152 + Ld_208 + Ld_264 + Ld_320 + Ld_376 + Ld_432 + Ld_936 + Ld_992 + Ld_1048 + Ld_1104 + Ld_1160 + Ld_1216 + Ld_48 + Ld_104 + Ld_160 + Ld_216 + Ld_272 +
      Ld_328 + Ld_384 + Ld_440 + Ld_944 + Ld_1000 + Ld_1056 + Ld_1112 + Ld_1168 + Ld_1224 + Ld_448 + Ld_504 + Ld_560 + Ld_616 + Ld_672 + Ld_728 + Ld_784 + Ld_840 + Ld_1232 +
      Ld_1288 + Ld_1344 + Ld_1400 + Ld_1456 + Ld_1512 + Ld_456 + Ld_512 + Ld_568 + Ld_624 + Ld_680 + Ld_736 + Ld_792 + Ld_848 + Ld_1240 + Ld_1296 + Ld_1352 + Ld_1408 + Ld_1464 +
      Ld_1520 + Ld_464 + Ld_520 + Ld_576 + Ld_632 + Ld_688 + Ld_744 + Ld_800 + Ld_856 + Ld_1248 + Ld_1304 + Ld_1360 + Ld_1416 + Ld_1472 + Ld_1528 + Ld_472 + Ld_528 + Ld_584 +
      Ld_640 + Ld_696 + Ld_752 + Ld_808 + Ld_864 + Ld_1256 + Ld_1312 + Ld_1368 + Ld_1424 + Ld_1480 + Ld_1536 + Ld_480 + Ld_536 + Ld_592 + Ld_648 + Ld_704 + Ld_760 + Ld_816 +
      Ld_872 + Ld_1264 + Ld_1320 + Ld_1376 + Ld_1432 + Ld_1488 + Ld_1544 + Ld_488 + Ld_544 + Ld_600 + Ld_656 + Ld_712 + Ld_768 + Ld_824 + Ld_880 + Ld_1272 + Ld_1328 + Ld_1384 +
      Ld_1440 + Ld_1496 + Ld_1552 + Ld_496 + Ld_552 + Ld_608 + Ld_664 + Ld_720 + Ld_776 + Ld_832 + Ld_888 + Ld_1280 + Ld_1336 + Ld_1392 + Ld_1448 + Ld_1504 + Ld_1560;
   double Ld_3292 = (Ld_0 + Ld_56 + Ld_112 + Ld_168 + Ld_224 + Ld_280 + Ld_336 + Ld_392 + Ld_896 + Ld_952 + Ld_1008 + Ld_1064 + Ld_1120 + Ld_1176) * Gd_236;
   double Ld_3300 = (Ld_8 + Ld_64 + Ld_120 + Ld_176 + Ld_232 + Ld_288 + Ld_344 + Ld_400 + Ld_904 + Ld_960 + Ld_1016 + Ld_1072 + Ld_1128 + Ld_1184) * Gd_248;
   double Ld_3308 = (Ld_16 + Ld_72 + Ld_128 + Ld_184 + Ld_240 + Ld_296 + Ld_352 + Ld_408 + Ld_912 + Ld_968 + Ld_1024 + Ld_1080 + Ld_1136 + Ld_1192) * Gd_260;
   double Ld_3316 = (Ld_24 + Ld_80 + Ld_136 + Ld_192 + Ld_248 + Ld_304 + Ld_360 + Ld_416 + Ld_920 + Ld_976 + Ld_1032 + Ld_1088 + Ld_1144 + Ld_1200) * Gd_272;
   double Ld_3324 = (Ld_32 + Ld_88 + Ld_144 + Ld_200 + Ld_256 + Ld_312 + Ld_368 + Ld_424 + Ld_928 + Ld_984 + Ld_1040 + Ld_1096 + Ld_1152 + Ld_1208) * Gd_284;
   double Ld_3332 = (Ld_40 + Ld_96 + Ld_152 + Ld_208 + Ld_264 + Ld_320 + Ld_376 + Ld_432 + Ld_936 + Ld_992 + Ld_1048 + Ld_1104 + Ld_1160 + Ld_1216) * Gd_296;
   double Ld_3340 = (Ld_48 + Ld_104 + Ld_160 + Ld_216 + Ld_272 + Ld_328 + Ld_384 + Ld_440 + Ld_944 + Ld_1000 + Ld_1056 + Ld_1112 + Ld_1168 + Ld_1224) * Gd_308;
   double Ld_3348 = Ld_3292 + Ld_3300 + Ld_3308 + Ld_3316 + Ld_3324 + Ld_3332 + Ld_3340;
   double Ld_3356 = (Ld_448 + Ld_504 + Ld_560 + Ld_616 + Ld_672 + Ld_728 + Ld_784 + Ld_840 + Ld_1232 + Ld_1288 + Ld_1344 + Ld_1400 + Ld_1456 + Ld_1512) * Gd_236;
   double Ld_3364 = (Ld_456 + Ld_512 + Ld_568 + Ld_624 + Ld_680 + Ld_736 + Ld_792 + Ld_848 + Ld_1240 + Ld_1296 + Ld_1352 + Ld_1408 + Ld_1464 + Ld_1520) * Gd_248;
   double Ld_3372 = (Ld_464 + Ld_520 + Ld_576 + Ld_632 + Ld_688 + Ld_744 + Ld_800 + Ld_856 + Ld_1248 + Ld_1304 + Ld_1360 + Ld_1416 + Ld_1472 + Ld_1528) * Gd_260;
   double Ld_3380 = (Ld_472 + Ld_528 + Ld_584 + Ld_640 + Ld_696 + Ld_752 + Ld_808 + Ld_864 + Ld_1256 + Ld_1312 + Ld_1368 + Ld_1424 + Ld_1480 + Ld_1536) * Gd_272;
   double Ld_3388 = (Ld_480 + Ld_536 + Ld_592 + Ld_648 + Ld_704 + Ld_760 + Ld_816 + Ld_872 + Ld_1264 + Ld_1320 + Ld_1376 + Ld_1432 + Ld_1488 + Ld_1544) * Gd_284;
   double Ld_3396 = (Ld_488 + Ld_544 + Ld_600 + Ld_656 + Ld_712 + Ld_768 + Ld_824 + Ld_880 + Ld_1272 + Ld_1328 + Ld_1384 + Ld_1440 + Ld_1496 + Ld_1552) * Gd_296;
   double Ld_3404 = (Ld_496 + Ld_552 + Ld_608 + Ld_664 + Ld_720 + Ld_776 + Ld_832 + Ld_888 + Ld_1280 + Ld_1336 + Ld_1392 + Ld_1448 + Ld_1504 + Ld_1560) * Gd_308;
   double Ld_3412 = Ld_3356 + Ld_3364 + Ld_3372 + Ld_3380 + Ld_3388 + Ld_3396 + Ld_3404;
   string Ls_3420 = DoubleToStr(100.0 * (Ld_3348 / Ld_3284), 0);
   string Ls_3428 = DoubleToStr(100 - StrToDouble(Ls_3420), 0);
   Gda_532[0] = 100.0 * (Ld_3348 / Ld_3284);
   Gda_536[0] = 100 - 100.0 * (Ld_3348 / Ld_3284);
   if (Gi_96 == TRUE) {
      ObjectCreate("Trend_UP_text", OBJ_LABEL, Window, 0, 0);
      ObjectSetText("Trend_UP_text", " BUY ", 15, "Arial Bold", Lime);
      ObjectSet("Trend_UP_text", OBJPROP_CORNER, Gi_104);
      ObjectSet("Trend_UP_text", OBJPROP_XDISTANCE, X_trend + 905 - 740);
      ObjectSet("Trend_UP_text", OBJPROP_YDISTANCE, Y_trend + 2);
      ObjectCreate("Trend_UP_value", OBJ_LABEL, Window, 0, 0);
      ObjectSetText("Trend_UP_value", Ls_3420 + "%", 15, "Arial Bold", White);
      ObjectSet("Trend_UP_value", OBJPROP_CORNER, Gi_104);
      ObjectSet("Trend_UP_value", OBJPROP_XDISTANCE, X_trend + 945 - 825);
      ObjectSet("Trend_UP_value", OBJPROP_YDISTANCE, Y_trend + 2);
      ObjectCreate("Trend_DOWN_text", OBJ_LABEL, Window, 0, 0);
      ObjectSetText("Trend_DOWN_text", " SELL ", 15, "Arial Bold", Red);
      ObjectSet("Trend_DOWN_text", OBJPROP_CORNER, Gi_104);
      ObjectSet("Trend_DOWN_text", OBJPROP_XDISTANCE, X_trend + 905 - 850);
      ObjectSet("Trend_DOWN_text", OBJPROP_YDISTANCE, Y_trend + 2);
      ObjectCreate("Trend_DOWN_value", OBJ_LABEL, Window, 0, 0);
      ObjectSetText("Trend_DOWN_value", Ls_3428 + "%", 15, "Arial Bold", White);
      ObjectSet("Trend_DOWN_value", OBJPROP_CORNER, Gi_104);
      ObjectSet("Trend_DOWN_value", OBJPROP_XDISTANCE, X_trend + 945 - 930);
      ObjectSet("Trend_DOWN_value", OBJPROP_YDISTANCE, Y_trend + 2);
      ObjectCreate("Trend", OBJ_LABEL, Window, 0, 0);
      ObjectSetText("Trend", Ls_3212, 18, "Impact", Li_3228);
      ObjectSet("Trend", OBJPROP_CORNER, Gi_104);
      ObjectSet("Trend", OBJPROP_XDISTANCE, Ld_3236 + X_trend - 900.0);
      ObjectSet("Trend", OBJPROP_YDISTANCE, Y_trend + 36);
      ObjectCreate("Trend_comment", OBJ_LABEL, Window, 0, 0);
      ObjectSetText("Trend_comment", Ls_3220, 8, "Arial Bold", Li_3232);
      ObjectSet("Trend_comment", OBJPROP_CORNER, Gi_104);
      ObjectSet("Trend_comment", OBJPROP_XDISTANCE, Ld_3244 + X_trend - 900.0);
      ObjectSet("Trend_comment", OBJPROP_YDISTANCE, Y_trend + 62);
   }
 if(Alerts){
  static int PrevSignal = 0, PrevTime = 0;
  if( Time[0] <= PrevTime)   
	      return(0);
	      PrevTime = Time[0]; 
  if(100.0 * (Ld_3348 / Ld_3284) > Buy){Alert("Buy%-Sel%l (", Symbol(), ", ", Period(), ")  -  BUY!!!");}
  if(100 - 100.0 * (Ld_3348 / Ld_3284)> Sell){Alert("Buy%-Sel%l (", Symbol(), ", ", Period(), ")  -  SELL!!!");}
  }
   return (0);
}