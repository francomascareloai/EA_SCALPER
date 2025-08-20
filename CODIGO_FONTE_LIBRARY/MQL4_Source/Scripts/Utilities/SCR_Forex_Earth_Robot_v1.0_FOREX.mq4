#property copyright "Ex4toMq4Decompiler MT4 Expert Advisors and Indicators Base of Source Codes"
#property link      "https://ex4tomq4decompiler.com/"
//----
//#include <stdlib.mqh>
#import "stdlib.ex4"
   string ErrorDescription(int a0); // DA69CBAFF4D38B87377667EEC549DE5A
#import

string RTRs_76 = "Forex Earth Robot";
extern int magic = 1234;
bool RTRi_88 = FALSE;
bool RTRi_92 = TRUE;
bool RTRi_unused_96 = FALSE;
bool RTRi_100 = FALSE;
bool RTRi_104 = FALSE;
bool RTRi_108 = FALSE;
bool RTRi_112 = FALSE;
bool RTRi_116 = FALSE;
bool RTRi_120 = FALSE;
bool RTRi_124 = FALSE;
bool RTRi_128 = FALSE;
bool RTRi_132 = FALSE;
extern string moneymanagement = "Money Management";
extern double lots = 0.1;
extern bool mm = FALSE;
extern double risk = 1.0;
extern double minlot = 0.01;
extern double maxlot = 50.0;
extern int lotdigits = 2;
bool RTRi_184 = FALSE;
double RTRd_188 = 2.0;
bool RTRi_196 = FALSE;
int RTRi_200 = 0;
double RTRd_204 = 2.0;
double RTRd_212 = 0.0;
bool RTRi_220 = FALSE;
int RTRi_224 = 0;
bool RTRi_228 = FALSE;
int RTRi_232 = 0;
double RTRd_236 = 1.0;
double RTRd_244 = 1.0;
int RTRi_252 = 500;
string RTRs_unused_256 = "Profit Management";
bool RTRi_264 = FALSE;
double RTRd_268 = 0.1;
double RTRd_276 = 100.0;
bool RTRi_284 = FALSE;
double RTRd_288 = 10.0;
double RTRd_296 = 10000.0;
bool RTRi_304 = FALSE;
double RTRd_308 = 5.0;
double RTRd_316 = 10000.0;
bool RTRi_324 = FALSE;
double RTRd_328 = 1.0;
double RTRd_336 = 0.5;
bool RTRi_344 = FALSE;
double RTRd_348 = 75.0;
double RTRd_356 = 20.0;
bool RTRi_364 = FALSE;
double RTRd_368 = 10.0;
double RTRd_376 = 5.0;
extern string ordersmanagement = "Order Management";
extern bool ecn = FALSE;
bool RTRi_396 = TRUE;
bool RTRi_400 = FALSE;
bool RTRi_404 = FALSE;
bool RTRi_408 = FALSE;
int RTRi_412 = 20;
bool RTRi_416 = FALSE;
bool RTRi_420 = FALSE;
extern bool oppositeclose = TRUE;
bool RTRi_428 = FALSE;
int RTRi_432 = 0;
extern bool reversesignals = FALSE;
extern int maxtrades = 500;
extern int tradesperbar = 1;
bool RTRi_448 = FALSE;
int RTRi_452 = 1;
extern bool hidesl = FALSE;
extern bool hidetp = FALSE;
extern double stoploss = 0.0;
extern double takeprofit = 0.0;
bool RTRi_480 = FALSE;
bool RTRi_484 = FALSE;
double RTRd_488 = 5.0;
double RTRd_496 = 50.0;
double RTRd_504 = 20.0;
double RTRd_512 = 25.0;
int RTRi_520 = 0;
extern double trailingstart = 0.0;
extern double trailingstop = 0.0;
double RTRd_540 = 0.0;
extern double trailingstep = 1.0;
extern double breakevengain = 0.0;
extern double breakeven = 0.0;
int RTRi_572 = 1440;
double RTRd_576 = 0.0;
extern double maxspread = 0.0;
extern string adordersmanagement = "Advanced Order Management";
extern bool firstticks = FALSE;
extern int ticks = 4;
bool RTRi_608 = FALSE;
extern bool changedirection = FALSE;
extern bool onesideatatime = FALSE;
extern double stop = 0.0;
extern double trailing = 0.0;
bool RTRi_636 = FALSE;
bool RTRi_640 = FALSE;
int RTRi_644 = 0;
double RTRd_648 = 20.0;
double RTRd_656 = 1.0;
bool RTRi_664 = FALSE;
bool RTRi_668 = TRUE;
int RTRi_672 = 0;
int RTRi_676 = 0;
bool RTRi_680 = FALSE;
int RTRi_684 = 4;
int RTRi_688 = 60;
bool RTRi_692 = FALSE;
int RTRi_696 = 2;
bool RTRi_700 = FALSE;
int RTR_timeframe_704 = 0;
int RTRi_708 = 10;
bool RTRi_712 = FALSE;
int RTR_timeframe_716 = 0;
int RTRi_720 = 10;
extern string entrylogics = "Entry Logics";
extern int lastxbars = 32;
extern int ybarsago = 20;
int RTRi_740 = 0;
extern string adxfilter = "0:NONE,1:M1,2:M5,3:M15,...,9:MN";
extern int adxtf = 5;
extern int adxperiod = 14;
extern int adxlevel = 20;
extern bool exitrule = TRUE;
extern int exitlastxbars = 32;
extern int exitybarsago = 20;
extern int shift = 1;
extern string timefilter = "Time Filter";
extern bool usetimefilter = FALSE;
extern int summergmtshift = 0;
extern int wintergmtshift = 0;
extern bool mondayfilter = FALSE;
extern int mondayhour = 12;
extern int mondayminute = 0;
extern bool weekfilter = FALSE;
extern int starthour = 7;
extern int startminute = 0;
extern int endhour = 21;
extern int endminute = 0;
extern bool tradesunday = TRUE;
extern bool fridayfilter = FALSE;
extern int fridayhour = 12;
extern int fridayminute = 0;
extern int testhour = 24;
bool RTRi_852 = FALSE;
int RTRi_856 = 1;
int RTRi_860 = 4;
int RTRi_864 = 12;
int RTRi_868 = 18;
bool RTRi_872 = FALSE;
int RTRi_876 = 3;
int RTRi_880 = 10;
bool RTRi_884 = FALSE;
int RTRi_888 = 21;
string RTRs_unused_892 = "News Filter";
bool RTRi_900 = FALSE;
int RTRi_904 = 30;
int RTRi_908 = 30;
bool RTRi_912 = FALSE;
bool RTRi_916 = FALSE;
bool RTRi_920 = FALSE;
string RTRs_unused_924 = "Time Outs and Targets";
bool RTRi_932 = FALSE;
int RTRi_936 = 30;
int RTRi_940 = 7;
int RTRi_944 = 70;
int RTRi_948 = 5;
int RTRi_952 = 95;
int RTRi_956 = 4;
int RTRi_960 = 120;
int RTRi_964 = 2;
int RTRi_968 = 150;
int RTRi_972 = -5;
int RTRi_976 = 180;
int RTRi_980 = -8;
int RTRi_984 = 210;
int RTRi_988 = -15;
bool RTRi_unused_992 = FALSE;
bool RTRi_996 = TRUE;
bool RTRi_1000 = TRUE;
bool RTRi_1004 = TRUE;
bool RTRi_1008 = FALSE;
bool RTRi_1012 = FALSE;
bool RTRi_1016 = TRUE;
bool RTRi_1020 = TRUE;
bool RTRi_1024 = TRUE;
bool RTRi_1028 = TRUE;
bool RTRi_1032 = TRUE;
bool RTRi_1036 = TRUE;
int RTR_count_1040;
int RTR_pos_1048;
int RTRi_1052 = 100;
int RTRi_1060;
int RTRi_1064;
int RTRi_1068;
int RTRi_1072;
bool RTRi_1080 = FALSE;
int RTRi_1084;
int RTRi_1092;
int RTRi_1100;
int RTRi_1104;
int RTRi_1108;
int RTR_count_1112;
int RTRi_1116;
int RTRi_1120;
int RTRi_1124;
int RTRi_1128;
int RTRi_1132 = 0;
int RTRi_1136 = 0;
int RTR_datetime_1144;
int RTR_datetime_1148;
int RTR_file_1152;
int RTR_str2time_1156;
bool RTRi_1160 = FALSE;
int RTRi_1164 = 0;
bool RTRi_1168 = FALSE;
int RTRi_1172 = 0;
int RTRi_unused_1176;
int RTRi_unused_1180;
double RTR_price_1192;
double RTR_price_1200;
double RTRd_1208;
double RTRd_1216;
double RTRd_1240;
double RTRd_1248;
double RTRd_1256;
double RTRda_1264[14];
double RTRda_1268[14];
double RTRd_1280;
double RTRda_1304[20];
double RTR_order_open_price_1308;
double RTR_order_open_price_1316;
double RTRd_1340;
double RTRd_1364 = 0.0;
double RTRd_1372;
double RTR_open_1380 = 0.0;
double RTRd_1388;
double RTRd_1396;
double RTRd_1404;
double RTRd_1412;
double RTRd_1420;
double RTRd_1428;
double RTRd_1436;
double RTRd_1444 = 0.0;
double RTRd_1452 = 0.0;
double RTRd_1460;
double RTRd_1468;
string RTRs_1476;
string RTRs_1484;
string RTRs_1492;
string RTRs_1500;
string RTRs_1508;
string RTRs_1516;
string RTRs_1524;
string RTRs_1532;
string RTRs_1540;
string RTRs_1548;
string RTRs_1556;
string RTRs_1564;
string RTRs_1572;
string RTRs_1580;
string RTRs_1588;
string RTRs_1596;
string RTRs_1604;
string RTRs_unused_1612 = "";
string RTRs_unused_1620 = "";
string RTRs_unused_1628 = "";
string RTRs_unused_1636 = "";
string RTRs_1644;
string RTRs_1652;
string RTRs_1660 = "";
string RTRs_1668 = "";
string RTRs_1676 = "";
string RTRs_1684 = "";
string RTRs_1692 = "";
string RTRs_1700 = "";
int RTR_str2time_1708;
int RTR_str2time_1712;
int RTR_str2time_1716;
int RTR_str2time_1720;
int RTR_datetime_1724;
int RTR_datetime_1732;
int RTRi_1740;
int RTRi_1744;
int RTRi_1748;
int RTRi_1752;
int RTRi_1756;
int RTRi_1760;
int RTR_datetime_1764;
datetime RTR_time_1768;
datetime RTR_time_1772;
int RTR_datetime_1776;
int RTR_str2time_1780;
double RTR_digits_1784;
double RTRd_1792;
double RTRd_1800;
int RTR_minute_1808 = -1;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
//--- 
   RTR_digits_1784 = Digits;
   if (RTR_digits_1784 == 3.0 || RTR_digits_1784 == 5.0) {
      RTRd_1792 = 10.0 * Point;
      RTRd_1800 = 10;
   } else {
      RTRd_1792 = Point;
      RTRd_1800 = 1;
   }
   RTRi_unused_1176 = RTRi_412;
   RTRi_unused_1180 = RTRi_412;
   f0_27();
   f0_4();
   f0_53();
   f0_48();
   return (0);
}

// 521345A9FB579F52117F27BE6E0673EE
int f0_24(int xxxxi_0, int xxxxi_4) {
   double ihigh_8 = iHigh(NULL, f0_45(RTRi_740), iHighest(NULL, f0_45(RTRi_740), MODE_HIGH, lastxbars, xxxxi_4 + 1));
   double ilow_16 = iLow(NULL, f0_45(RTRi_740), iLowest(NULL, f0_45(RTRi_740), MODE_LOW, lastxbars, xxxxi_4 + 1));
   if (Close[xxxxi_4] < ilow_16 && iHighest(NULL, f0_45(RTRi_740), MODE_HIGH, lastxbars, xxxxi_4 + 1) >= ybarsago && f0_45(adxtf) == 0 || (f0_45(adxtf) > 0 && iADX(NULL,
      f0_45(adxtf), adxperiod, PRICE_CLOSE, MODE_PLUSDI, xxxxi_4) > adxlevel))
      if (xxxxi_0 == 0) return (1);
   if (Close[xxxxi_4] > ihigh_8 && iLowest(NULL, f0_45(RTRi_740), MODE_LOW, lastxbars, xxxxi_4 + 1) >= ybarsago && f0_45(adxtf) == 0 || (f0_45(adxtf) > 0 && iADX(NULL,
      f0_45(adxtf), adxperiod, PRICE_CLOSE, MODE_PLUSDI, xxxxi_4) > adxlevel))
      if (xxxxi_0 == 1) return (2);
   return (0);
}

// 7ECFA5EFA45F9CEF565617081544780F
int f0_35(int xxxxi_0, int xxxxi_4) {
   double ihigh_8 = iHigh(NULL, f0_45(RTRi_740), iHighest(NULL, f0_45(RTRi_740), MODE_HIGH, lastxbars, xxxxi_4 + 1));
   double ilow_16 = iLow(NULL, f0_45(RTRi_740), iLowest(NULL, f0_45(RTRi_740), MODE_LOW, lastxbars, xxxxi_4 + 1));
   if (Close[xxxxi_4] > ihigh_8 && iLowest(NULL, f0_45(RTRi_740), MODE_LOW, exitlastxbars, xxxxi_4 + 1) >= exitybarsago)
      if (xxxxi_0 == 0) return (1);
   if (Close[xxxxi_4] < ilow_16 && iHighest(NULL, f0_45(RTRi_740), MODE_HIGH, exitlastxbars, xxxxi_4 + 1) >= exitybarsago)
      if (xxxxi_0 == 1) return (2);
   return (0);
}

// F24F62EEB789199B9B2E467DF3B1876B
void f0_62() {
   RTRi_1168 = FALSE;
   RTRi_1172 = 0;
   if (exitrule) {
      if (f0_35(0, shift) == 1) RTRi_1168 = TRUE;
      if (f0_35(1, shift) == 2) RTRi_1172 = 2;
   }
}

// 1043BFC77FEBE75FAFEC0C4309FACCF1
void f0_6() {
   if (RTRi_448) {
      RTR_count_1040 = 0;
      if (OrdersHistoryTotal() > 0) {
         for (RTR_pos_1048 = OrdersHistoryTotal() - 1; RTR_pos_1048 >= 0; RTR_pos_1048--) {
            OrderSelect(RTR_pos_1048, SELECT_BY_POS, MODE_HISTORY);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != magic) continue;
            if (OrderOpenTime() < iTime(NULL, PERIOD_D1, 0)) break;
            RTR_count_1040++;
         }
      }
   }
   RTRi_1160 = FALSE;
   RTRi_1164 = 0;
   if (RTRi_1168 != TRUE && f0_24(0, shift) == 1 && RTRi_448 == FALSE || (RTRi_448 && RTR_count_1040 < RTRi_452) && RTRi_852 == FALSE || (RTRi_852 && (!Month() == RTRi_856 &&
      Day() <= RTRi_860) && (!Month() == RTRi_864 && Day() >= RTRi_868)) && IsTradeContextBusy() == FALSE) RTRi_1160 = TRUE;
   if (RTRi_1172 != 2 && f0_24(1, shift) == 2 && RTRi_448 == FALSE || (RTRi_448 && RTR_count_1040 < RTRi_452) && RTRi_852 == FALSE || (RTRi_852 && (!Month() == RTRi_856 &&
      Day() <= RTRi_860) && (!Month() == RTRi_864 && Day() >= RTRi_868)) && IsTradeContextBusy() == FALSE) RTRi_1164 = 2;
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   if (RTRi_120 || (RTRi_884 && Hour() >= RTRi_888)) {
      f0_33();
      return (0);
   }
   if (RTRi_124) f0_30(0);
   if (RTRi_128) f0_30(1);
   if (f0_17() || f0_47() || f0_60()) return (0);
   f0_39();
   f0_5();
   if (RTRs_1660 == "CLOSE" || RTRs_1668 == "CLOSE" || RTRs_1684 == "CLOSE" || RTRs_1676 == "CLOSE" || RTRs_1700 == "CLOSE" || RTRs_1692 == "CLOSE") return (0);
   f0_9();
   f0_40();
   f0_55();
   f0_62();
   f0_6();
   f0_50();
   f0_51();
   f0_8();
   f0_61();
   f0_41();
   if (((!RTRi_1008) && (!RTRi_1012)) || f0_15()) return (0);
   f0_10();
   f0_43();
   f0_38();
   f0_21();
   f0_28();
   f0_1();
   f0_23();
   f0_56();
   return (0);
}

// 37B51D194A7513E45B56F6524F2D51F2
int f0_19(int xxxxi_0) {
   int count_4 = 0;
   if (OrdersTotal() > 0) {
      for (RTR_pos_1048 = OrdersTotal() - 1; RTR_pos_1048 >= 0; RTR_pos_1048--) {
         OrderSelect(RTR_pos_1048, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderCloseTime() == 0) {
            if (OrderOpenTime() < iTime(NULL, 0, 0)) break;
            if (OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP && xxxxi_0 == 0)
               if (OrderOpenTime() >= iTime(NULL, 0, 0)) count_4++;
            if (OrderType() == OP_SELL || OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP && xxxxi_0 == 1)
               if (OrderOpenTime() >= iTime(NULL, 0, 0)) count_4++;
         }
      }
   }
   if (OrdersHistoryTotal() > 0) {
      for (RTR_pos_1048 = OrdersHistoryTotal() - 1; RTR_pos_1048 >= 0; RTR_pos_1048--) {
         OrderSelect(RTR_pos_1048, SELECT_BY_POS, MODE_HISTORY);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != magic) continue;
         if (OrderOpenTime() < iTime(NULL, 0, 0)) break;
         if (OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP && xxxxi_0 == 0)
            if (OrderOpenTime() >= iTime(NULL, 0, 0)) count_4++;
         if (OrderType() == OP_SELL || OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP && xxxxi_0 == 1)
            if (OrderOpenTime() >= iTime(NULL, 0, 0)) count_4++;
      }
   }
   return (count_4);
}

// 1DFB6B98AEF3416E03D50FD2FB525600
void f0_9() {
   if (RTRi_132) {
      GlobalVariableSet("vGrafBalance", AccountBalance());
      GlobalVariableSet("vGrafEquity", AccountEquity());
   }
}

// 8C70514847A2FF8FFAD1BC3DBE652BA0
void f0_39() {
   if (RTRi_88) {
      if (RTR_datetime_1776 != iTime(NULL, PERIOD_D1, 0)) {
         MathSrand(TimeLocal());
         magic = MathRand();
         RTR_datetime_1776 = iTime(NULL, PERIOD_D1, 0);
      }
   }
}

// 0F6BBDB05CF026B71C833D0C6548BA1B
void f0_4() {
   RTRd_1388 = AccountBalance();
   if (stop > 0.0) {
      stoploss = stop;
      takeprofit = stop;
   }
}

// 333ABA968C38D95E63061CDDC3924D56
int f0_17() {
   if (firstticks)
      if (iVolume(NULL, 0, 0) > ticks) return (1);
   return (0);
}

// 64EF7DE6E858DA246FAF2C23608A34AC
void f0_27() {
   if (RTRi_608) RTR_open_1380 = Open[0];
}

// A739B7C7D1E3FB3ACE2656BE26C77D93
int f0_47() {
   if (RTRi_608)
      if (RTR_open_1380 == Open[0]) return (1);
   return (0);
}

// EC0B142DB0D5AE0F462F0ADBA1181D0E
int f0_60() {
   if (Bars < 100) return (1);
   return (0);
}

// 8D777F385D3DFEC8815D20F7496026DC
void f0_40() {
   if (RTRi_1080 == TRUE) {
      RTRi_1060 = 0;
      RTRi_1064 = 0;
   }
   if (oppositeclose) {
      RTR_datetime_1144 = 0;
      RTR_datetime_1148 = 0;
   }
   RTR_order_open_price_1308 = 0;
   RTR_order_open_price_1316 = 0;
   if (OrdersTotal() > 0) {
      for (RTR_pos_1048 = 0; RTR_pos_1048 < OrdersTotal(); RTR_pos_1048++) {
         OrderSelect(RTR_pos_1048, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderCloseTime() == 0) {
            if (OrderType() == OP_BUY) {
               if (oppositeclose)
                  if (RTR_datetime_1144 == 0 || RTR_datetime_1144 > OrderOpenTime()) RTR_datetime_1144 = OrderOpenTime();
               RTR_datetime_1724 = OrderOpenTime();
               if (RTRi_636) RTR_order_open_price_1308 = OrderOpenPrice();
               if (RTRi_1080 == TRUE) RTRi_1060 = RTRi_1060 + OrderProfit();
            }
            if (OrderType() == OP_SELL) {
               if (oppositeclose)
                  if (RTR_datetime_1144 == 0 || RTR_datetime_1148 > OrderOpenTime()) RTR_datetime_1148 = OrderOpenTime();
               RTR_datetime_1732 = OrderOpenTime();
               if (RTRi_636) RTR_order_open_price_1316 = OrderOpenPrice();
               if (RTRi_1080 == TRUE) RTRi_1064 = RTRi_1064 + OrderProfit();
            }
         }
      }
   }
   if (RTRi_1080 == TRUE) RTRd_1280 = RTRi_1060 + RTRi_1064;
}

// B55B54F47954E65C6647EC4752AE71B1
void f0_50() {
   RTRi_1008 = FALSE;
   RTRi_1012 = FALSE;
}

// 16F51C1AB9137B3733BD210C2D080289
void f0_8() {
   RTRi_1024 = TRUE;
   RTRi_1028 = TRUE;
   if (onesideatatime) {
      if (f0_58(OP_SELL) > 0) {
         if (reversesignals) RTRi_1028 = FALSE;
         else RTRi_1024 = FALSE;
      }
      if (f0_58(OP_BUY) > 0) {
         if (reversesignals) RTRi_1024 = FALSE;
         else RTRi_1028 = FALSE;
      }
   }
   if (RTRi_1160 == TRUE && RTRi_1016 && RTRi_1024 && RTRi_996 && RTRi_1004 && RTRi_872 == FALSE || (RTRi_872 && Day() != RTRi_876 && Day() != RTRi_880)) {
      if (reversesignals) RTRi_1012 = TRUE;
      else RTRi_1008 = TRUE;
      if (changedirection) {
         RTRi_996 = FALSE;
         RTRi_1000 = TRUE;
      }
      if (RTRi_428) {
         if (reversesignals) RTRs_1540 = "SHORT";
         else RTRs_1540 = "LONG";
      }
   }
   if (RTRi_1164 == 2 && RTRi_1020 && RTRi_1028 && RTRi_1000 && RTRi_1004 && RTRi_872 == FALSE || (RTRi_872 && Day() != RTRi_876 && Day() != RTRi_880)) {
      if (reversesignals) RTRi_1008 = TRUE;
      else RTRi_1012 = TRUE;
      if (changedirection) {
         RTRi_996 = TRUE;
         RTRi_1000 = FALSE;
      }
      if (RTRi_428) {
         if (reversesignals) {
            RTRs_1540 = "LONG";
            return;
         }
         RTRs_1540 = "SHORT";
      }
   }
}

// 7CEF8A734855777C2A9D0CAF42666E69
int f0_34(int xxxx_cmd_0, double xxxxd_4, double xxxxd_12, double xxxxd_20, double xxxxd_28, int xxxx_datetime_36, color xxxx_color_40) {
   int ticket_44 = 0;
   if (xxxxd_4 < minlot) xxxxd_4 = minlot;
   if (xxxxd_4 > maxlot) xxxxd_4 = maxlot;
   if (xxxx_cmd_0 == OP_BUY || xxxx_cmd_0 == OP_BUYSTOP || xxxx_cmd_0 == OP_BUYLIMIT) {
      if (hidesl == FALSE && xxxxd_20 > 0.0) RTR_price_1192 = xxxxd_12 - xxxxd_20 * RTRd_1792;
      else RTR_price_1192 = 0;
      if (hidetp == FALSE && xxxxd_28 > 0.0) RTR_price_1200 = xxxxd_12 + xxxxd_28 * RTRd_1792;
      else RTR_price_1200 = 0;
      if (ecn) {
         RTR_price_1192 = 0;
         RTR_price_1200 = 0;
      }
   }
   if (xxxx_cmd_0 == OP_SELL || xxxx_cmd_0 == OP_SELLSTOP || xxxx_cmd_0 == OP_SELLLIMIT) {
      if (hidesl == FALSE && xxxxd_20 > 0.0) RTR_price_1192 = xxxxd_12 + xxxxd_20 * RTRd_1792;
      else RTR_price_1192 = 0;
      if (hidetp == FALSE && xxxxd_28 > 0.0) RTR_price_1200 = xxxxd_12 - xxxxd_28 * RTRd_1792;
      else RTR_price_1200 = 0;
      if (ecn) {
         RTR_price_1192 = 0;
         RTR_price_1200 = 0;
      }
   }
   ticket_44 = OrderSend(Symbol(), xxxx_cmd_0, f0_46(xxxxd_4, lotdigits), f0_46(xxxxd_12, RTR_digits_1784), RTRd_576 * RTRd_1800, RTR_price_1192, RTR_price_1200, RTRs_76 +
      " " + DoubleToStr(magic, 0), magic, xxxx_datetime_36, xxxx_color_40);
   return (ticket_44);
}

// 0461EBD2B773878EAC9F78A891912D65
void f0_0() {
   if (RTRi_700) {
      stoploss = (Ask - iLow(NULL, RTR_timeframe_704, iLowest(NULL, RTR_timeframe_704, MODE_LOW, RTRi_708, shift))) / RTRd_1792;
      if (stoploss < MarketInfo(Symbol(), MODE_STOPLEVEL) + MarketInfo(Symbol(), MODE_SPREAD)) stoploss = MarketInfo(Symbol(), MODE_STOPLEVEL) + MarketInfo(Symbol(), MODE_SPREAD);
   }
   if (RTRi_712) {
      takeprofit = (iHigh(NULL, RTR_timeframe_716, iHighest(NULL, RTR_timeframe_716, MODE_HIGH, RTRi_720, shift)) - Ask) / RTRd_1792;
      if (takeprofit < MarketInfo(Symbol(), MODE_STOPLEVEL) + MarketInfo(Symbol(), MODE_SPREAD)) takeprofit = MarketInfo(Symbol(), MODE_STOPLEVEL) + MarketInfo(Symbol(), MODE_SPREAD);
   }
   if (RTRi_420) {
      f0_2(OP_SELLSTOP);
      f0_2(OP_SELLLIMIT);
   }
   RTRi_1116 = 0;
   RTR_count_1112 = 0;
   RTRi_1124 = 0;
   if (RTRi_400 || RTRi_404)
      if (RTRi_572 > 0) RTRi_1124 = TimeCurrent() + 60 * RTRi_572 - 5;
   if (RTRi_396) {
      if (RTRi_1080 == FALSE) {
         while (RTRi_1116 <= 0 && RTR_count_1112 < RTRi_1052) {
            while (!IsTradeAllowed()) Sleep(5000);
            RefreshRates();
            RTRi_1116 = f0_34(OP_BUY, RTRd_1208, Ask, stoploss, takeprofit, RTRi_1124, Blue);
            if (RTRi_1116 < 0) {
               if (RTRi_92) Print("Error opening BUY order! ", ErrorDescription(GetLastError()));
               RTR_count_1112++;
            }
         }
      }
      if (RTRi_1080 == TRUE) {
         while (RTRi_1116 <= 0 && RTR_count_1112 < RTRi_1052) {
            while (!IsTradeAllowed()) Sleep(5000);
            RefreshRates();
            RTRi_1116 = f0_34(OP_BUY, RTRd_1208, Ask, stoploss, 0, RTRi_1124, Blue);
            if (RTRi_1116 < 0) {
               if (RTRi_92) Print("Error opening BUY order! ", ErrorDescription(GetLastError()));
               RTR_count_1112++;
            }
         }
      }
   }
   if (RTRi_400) {
      if (RTRi_1740 != Time[0]) {
         if (RTRi_416) f0_2(OP_BUYSTOP);
         RefreshRates();
         RTRi_1116 = f0_34(OP_BUYSTOP, RTRd_1208, Ask + RTRi_412 * RTRd_1792, stoploss, takeprofit, RTRi_1124, Blue);
         RTRi_1740 = Time[0];
      }
   }
   if (RTRi_404) {
      if (RTRi_1744 != Time[0]) {
         if (RTRi_416) f0_2(OP_BUYLIMIT);
         RefreshRates();
         RTRi_1116 = f0_34(OP_BUYLIMIT, RTRd_1208, Bid - RTRi_412 * RTRd_1792, stoploss, takeprofit, RTRi_1124, Blue);
         RTRi_1744 = Time[0];
      }
   }
   if (RTRi_664 && RTRi_1756 != Time[0]) {
      if (RTRi_668) f0_2(OP_BUYSTOP);
      RefreshRates();
      RTRi_1116 = f0_34(OP_SELLSTOP, RTRd_1208, Bid - stoploss * RTRd_1792, RTRi_672, RTRi_676, RTRi_1124, Red);
      RTRi_1756 = Time[0];
   }
   if (RTRi_396) {
      if (RTRi_1116 <= 0)
         if (RTRi_92) Print("Error Occured : " + ErrorDescription(GetLastError()));
   }
   if (RTR_time_1768 != Time[0]) {
      RefreshRates();
      if (RTRi_100) SendMail("[Long Trade]", "[" + Symbol() + "] " + DoubleToStr(Ask, RTR_digits_1784));
      if (RTRi_104) Alert(Symbol(), " Long Trade @  Hour ", Hour(), "  Minute ", Minute());
      if (RTRi_108) PlaySound("alert.wav");
      RTR_time_1768 = Time[0];
   }
}

// 8325324B47E1E62A1C2998A640CBDC72
void f0_37() {
   if (RTRi_700) {
      stoploss = (iHigh(NULL, RTR_timeframe_704, iHighest(NULL, RTR_timeframe_704, MODE_HIGH, RTRi_708, shift)) - Bid) / RTRd_1792;
      if (stoploss < MarketInfo(Symbol(), MODE_STOPLEVEL) + MarketInfo(Symbol(), MODE_SPREAD)) stoploss = MarketInfo(Symbol(), MODE_STOPLEVEL) + MarketInfo(Symbol(), MODE_SPREAD);
   }
   if (RTRi_712) {
      takeprofit = (Bid - iLow(NULL, RTR_timeframe_716, iLowest(NULL, RTR_timeframe_716, MODE_LOW, RTRi_720, shift))) / RTRd_1792;
      if (takeprofit < MarketInfo(Symbol(), MODE_STOPLEVEL) + MarketInfo(Symbol(), MODE_SPREAD)) takeprofit = MarketInfo(Symbol(), MODE_STOPLEVEL) + MarketInfo(Symbol(), MODE_SPREAD);
   }
   if (RTRi_420) {
      f0_2(OP_BUYSTOP);
      f0_2(OP_BUYLIMIT);
   }
   RTRi_1116 = 0;
   RTR_count_1112 = 0;
   RTRi_1124 = 0;
   if (RTRi_400 || RTRi_404)
      if (RTRi_572 > 0) RTRi_1124 = TimeCurrent() + 60 * RTRi_572 - 5;
   if (RTRi_396) {
      if (RTRi_1080 == FALSE) {
         while (RTRi_1116 <= 0 && RTR_count_1112 < RTRi_1052) {
            while (!IsTradeAllowed()) Sleep(5000);
            RefreshRates();
            RTRi_1116 = f0_34(OP_SELL, RTRd_1216, Bid, stoploss, takeprofit, RTRi_1124, Red);
            if (RTRi_1116 < 0) {
               if (RTRi_92) Print("Error opening BUY order! ", ErrorDescription(GetLastError()));
               RTR_count_1112++;
            }
         }
      }
      if (RTRi_1080 == TRUE) {
         while (RTRi_1116 <= 0 && RTR_count_1112 < RTRi_1052) {
            while (!IsTradeAllowed()) Sleep(5000);
            RefreshRates();
            RTRi_1116 = f0_34(OP_SELL, RTRd_1216, Bid, stoploss, 0, RTRi_1124, Red);
            if (RTRi_1116 < 0) {
               if (RTRi_92) Print("Error opening BUY order! ", ErrorDescription(GetLastError()));
               RTR_count_1112++;
            }
         }
      }
   }
   if (RTRi_400) {
      if (RTRi_1748 != Time[0]) {
         if (RTRi_416) f0_2(OP_SELLSTOP);
         RefreshRates();
         RTRi_1116 = f0_34(OP_SELLSTOP, RTRd_1216, Bid - RTRi_412 * RTRd_1792, stoploss, takeprofit, RTRi_1124, Red);
         RTRi_1748 = Time[0];
      }
   }
   if (RTRi_404) {
      if (RTRi_1752 != Time[0]) {
         if (RTRi_416) f0_2(OP_SELLLIMIT);
         RefreshRates();
         RTRi_1116 = f0_34(OP_SELLLIMIT, RTRd_1216, Ask + RTRi_412 * RTRd_1792, stoploss, takeprofit, RTRi_1124, Red);
         RTRi_1752 = Time[0];
      }
   }
   if (RTRi_664 && RTRi_1760 != Time[0]) {
      if (RTRi_668) f0_2(OP_SELLSTOP);
      RefreshRates();
      RTRi_1116 = f0_34(OP_BUYSTOP, RTRd_1208, Ask + stoploss * RTRd_1792, RTRi_672, RTRi_676, RTRi_1124, Blue);
      RTRi_1760 = Time[0];
   }
   if (RTRi_396) {
      if (RTRi_1116 <= 0)
         if (RTRi_92) Print("Error Occured : " + ErrorDescription(GetLastError()));
   }
   if (RTR_time_1768 != Time[0]) {
      RefreshRates();
      if (RTRi_100) SendMail("[Short Trade]", "[" + Symbol() + "] " + DoubleToStr(Bid, RTR_digits_1784));
      if (RTRi_104) Alert(Symbol(), " Short Trade @  Hour ", Hour(), "  Minute ", Minute());
      if (RTRi_108) PlaySound("alert.wav");
      RTR_time_1768 = Time[0];
   }
}

// CDFEE2BC43D63CAEAA3B169AD31E966C
void f0_56() {
   if (RTRi_1032 && RTRi_1036) {
      if (RTRi_1008 && (!RTRi_116) && f0_19(0) < tradesperbar) f0_0();
      if (RTRi_1012 && (!RTRi_112) && f0_19(1) < tradesperbar) f0_37();
   }
}

// FC07D24AB535D9106B0EDBE2F659DE71
int f0_66() {
   int count_0 = 0;
   if (OrdersTotal() > 0) {
      for (RTR_pos_1048 = OrdersTotal() - 1; RTR_pos_1048 >= 0; RTR_pos_1048--) {
         OrderSelect(RTR_pos_1048, SELECT_BY_POS, MODE_TRADES);
         count_0++;
      }
      return (count_0);
   }
   return (0);
}

// E2942A04780E223B215EB8B663CF5353
int f0_58(int xxxx_cmd_0) {
   int count_4 = 0;
   if (OrdersTotal() > 0) {
      for (RTR_pos_1048 = OrdersTotal() - 1; RTR_pos_1048 >= 0; RTR_pos_1048--) {
         OrderSelect(RTR_pos_1048, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderType() == xxxx_cmd_0 && OrderMagicNumber() == magic) count_4++;
      }
      return (count_4);
   }
   return (0);
}

// 305261DBE9AC028F16746587E5B57B11
int f0_16(int xxxxi_0) {
   int YYYYi_ret_4 = 0;
   if (xxxxi_0 == 0) YYYYi_ret_4 = f0_58(OP_BUY) + f0_58(OP_SELL);
   if (xxxxi_0 == 1) YYYYi_ret_4 = f0_58(OP_BUY) + f0_58(OP_SELL) + f0_58(OP_BUYSTOP) + f0_58(OP_SELLSTOP) + f0_58(OP_BUYLIMIT) + f0_58(OP_SELLLIMIT);
   return (YYYYi_ret_4);
}

// 2FFE4E77325D9A7152F7086EA7AA5114
int f0_15() {
   if (maxspread != 0.0)
      if (Ask - Bid > maxspread * RTRd_1792) return (1);
   if (maxtrades < 500)
      if (f0_16(0) >= maxtrades) return (1);
   return (0);
}

// 3CD15F8F2940AFF879DF34DF4E5C2CD1
double f0_20(int xxxxi_0) {
   double order_profit_4 = 0;
   double order_lots_12 = 0;
   if (OrdersHistoryTotal() > 0) {
      for (RTR_pos_1048 = OrdersHistoryTotal() - 1; RTR_pos_1048 >= 0; RTR_pos_1048--) {
         if (order_profit_4 != 0.0) break;
         OrderSelect(RTR_pos_1048, SELECT_BY_POS, MODE_HISTORY);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_BUY || OrderType() == OP_SELL) {
            order_profit_4 = OrderProfit();
            order_lots_12 = OrderLots();
         }
      }
   }
   if (xxxxi_0 == 0) return (order_lots_12);
   if (xxxxi_0 == 1) return (order_profit_4);
   return (0);
}

// E8947C1CC9CE3CD7370C8E0DC2E3BE00
double f0_59(int xxxxi_0) {
   double YYYYd_ret_4 = 0;
   if (OrdersTotal() > 0) {
      for (RTR_pos_1048 = OrdersTotal() - 1; RTR_pos_1048 >= 0; RTR_pos_1048--) {
         OrderSelect(RTR_pos_1048, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderType() == OP_BUY && OrderMagicNumber() == magic) {
            if (xxxxi_0 == 0) YYYYd_ret_4 += (OrderClosePrice() - OrderOpenPrice()) / RTRd_1792;
            if (xxxxi_0 == 1) YYYYd_ret_4 += OrderProfit();
         }
         if (OrderSymbol() == Symbol() && OrderType() == OP_SELL && OrderMagicNumber() == magic) {
            if (xxxxi_0 == 0) YYYYd_ret_4 += (OrderOpenPrice() - OrderClosePrice()) / RTRd_1792;
            if (xxxxi_0 == 1) YYYYd_ret_4 += OrderProfit();
         }
      }
      return (YYYYd_ret_4);
   }
   return (0.0);
}

// 436B21E3C6DBA892C58F161A5F55B3B7
double f0_22(int xxxxi_0) {
   double YYYYd_ret_4 = 0;
   if (OrdersHistoryTotal() > 0) {
      for (RTR_pos_1048 = OrdersHistoryTotal() - 1; RTR_pos_1048 >= 0; RTR_pos_1048--) {
         OrderSelect(RTR_pos_1048, SELECT_BY_POS, MODE_HISTORY);
         if (OrderSymbol() == Symbol() && OrderType() == OP_BUY && OrderMagicNumber() == magic) {
            if (xxxxi_0 == 2 || xxxxi_0 == 3 && TimeDay(OrderOpenTime()) != TimeDay(Time[0])) break;
            if (xxxxi_0 == 4 || xxxxi_0 == 5 && TimeMonth(OrderOpenTime()) != TimeMonth(Time[0])) break;
            if (xxxxi_0 == 0) YYYYd_ret_4 += (OrderClosePrice() - OrderOpenPrice()) / RTRd_1792;
            if (xxxxi_0 == 1) YYYYd_ret_4 += OrderProfit();
            if (xxxxi_0 == 2 && TimeDay(OrderOpenTime()) == TimeDay(Time[0])) YYYYd_ret_4 += (OrderClosePrice() - OrderOpenPrice()) / RTRd_1792;
            if (xxxxi_0 == 3 && TimeDay(OrderOpenTime()) == TimeDay(Time[0])) YYYYd_ret_4 += OrderProfit();
            if (xxxxi_0 == 4 && TimeMonth(OrderOpenTime()) == TimeMonth(Time[0])) YYYYd_ret_4 += (OrderClosePrice() - OrderOpenPrice()) / RTRd_1792;
            if (xxxxi_0 == 5 && TimeMonth(OrderOpenTime()) == TimeMonth(Time[0])) YYYYd_ret_4 += OrderProfit();
         }
         if (OrderSymbol() == Symbol() && OrderType() == OP_SELL && OrderMagicNumber() == magic) {
            if (xxxxi_0 == 2 || xxxxi_0 == 3 && TimeDay(OrderOpenTime()) != TimeDay(Time[0])) break;
            if (xxxxi_0 == 4 || xxxxi_0 == 5 && TimeMonth(OrderOpenTime()) != TimeMonth(Time[0])) break;
            if (xxxxi_0 == 0) YYYYd_ret_4 += (OrderOpenPrice() - OrderClosePrice()) / RTRd_1792;
            if (xxxxi_0 == 1) YYYYd_ret_4 += OrderProfit();
            if (xxxxi_0 == 2 && TimeDay(OrderOpenTime()) == TimeDay(Time[0])) YYYYd_ret_4 += (OrderOpenPrice() - OrderClosePrice()) / RTRd_1792;
            if (xxxxi_0 == 3 && TimeDay(OrderOpenTime()) == TimeDay(Time[0])) YYYYd_ret_4 += OrderProfit();
            if (xxxxi_0 == 4 && TimeMonth(OrderOpenTime()) == TimeMonth(Time[0])) YYYYd_ret_4 += (OrderOpenPrice() - OrderClosePrice()) / RTRd_1792;
            if (xxxxi_0 == 5 && TimeMonth(OrderOpenTime()) == TimeMonth(Time[0])) YYYYd_ret_4 += OrderProfit();
         }
      }
      return (YYYYd_ret_4);
   }
   return (0.0);
}

// 7720E711944C2CEB609F72714E69F0E7
int f0_32(int xxxxi_0) {
   int count_4 = 0;
   for (RTR_pos_1048 = OrdersHistoryTotal(); RTR_pos_1048 >= 0; RTR_pos_1048--) {
      OrderSelect(RTR_pos_1048, SELECT_BY_POS, MODE_HISTORY);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
         if (xxxxi_0 == 0) {
            if (OrderProfit() > 0.0) break;
            if (OrderProfit() < 0.0) count_4++;
         }
         if (xxxxi_0 == 1) {
            if (OrderProfit() < 0.0) break;
            if (OrderProfit() > 0.0) count_4++;
         }
      }
   }
   return (count_4);
}

// 9C70933AFF6B2A6D08C687A6CBB6B765
double f0_44(int xxxxi_0) {
   double YYYYd_ret_4 = 0;
   for (RTR_pos_1048 = OrdersHistoryTotal(); RTR_pos_1048 >= 0; RTR_pos_1048--) {
      OrderSelect(RTR_pos_1048, SELECT_BY_POS, MODE_HISTORY);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
         if (xxxxi_0 == 0) {
            if (OrderProfit() > 0.0) break;
            if (OrderProfit() < 0.0) YYYYd_ret_4 += OrderProfit();
         }
         if (xxxxi_0 == 1) {
            if (OrderProfit() < 0.0) break;
            if (OrderProfit() > 0.0) YYYYd_ret_4 += OrderProfit();
         }
      }
   }
   return (YYYYd_ret_4);
}

// BC0017B308109A3050233000024B5306
void f0_51() {
   RTRi_1016 = TRUE;
   RTRi_1020 = TRUE;
   if (RTRi_636) f0_25();
}

// 5B8EB17B72A5FFD1D63CDD9308920F83
void f0_25() {
   if (f0_58(OP_BUY) > 0) {
      RTRi_1016 = FALSE;
      if ((RTRi_644 == 0 && Close[0] <= RTR_order_open_price_1308 - RTRd_648 * RTRd_1792 * MathPow(RTRd_656, f0_58(OP_BUY))) || (RTRi_644 == 1 && Close[0] >= RTR_order_open_price_1308 +
         RTRd_648 * RTRd_1792 * MathPow(RTRd_656, f0_58(OP_BUY))) || (RTRi_644 == 2 && Close[0] <= RTR_order_open_price_1308 - RTRd_648 * RTRd_1792 * MathPow(RTRd_656, f0_58(OP_BUY)) ||
         Close[0] >= RTR_order_open_price_1308 + RTRd_648 * RTRd_1792 * MathPow(RTRd_656, f0_58(OP_BUY))) && RTRi_640 == FALSE || (RTRi_640 && (reversesignals == FALSE && RTRi_1160 == TRUE) ||
         (reversesignals && RTRi_1164 == 2))) RTRi_1008 = TRUE;
   }
   if (f0_58(OP_SELL) > 0) {
      RTRi_1020 = FALSE;
      if ((RTRi_644 == 0 && Close[0] >= RTR_order_open_price_1316 + RTRd_648 * RTRd_1792 * MathPow(RTRd_656, f0_58(OP_SELL))) || (RTRi_644 == 1 && Close[0] <= RTR_order_open_price_1316 - RTRd_648 * RTRd_1792 * MathPow(RTRd_656,
         f0_58(OP_SELL))) || (RTRi_644 == 2 && Close[0] >= RTR_order_open_price_1316 + RTRd_648 * RTRd_1792 * MathPow(RTRd_656, f0_58(OP_SELL)) || Close[0] <= RTR_order_open_price_1316 - RTRd_648 * RTRd_1792 * MathPow(RTRd_656,
         f0_58(OP_SELL))) && RTRi_640 == FALSE || (RTRi_640 && (reversesignals == FALSE && RTRi_1164 == 2) || (reversesignals && RTRi_1160 == TRUE))) RTRi_1012 = TRUE;
   }
}

// 2A38C5A02CC69575F68476FDB8CCA4ED
void f0_14() {
   RTRd_1208 = lots * MathPow(RTRd_204, f0_58(OP_BUY));
   RTRd_1216 = lots * MathPow(RTRd_204, f0_58(OP_SELL));
}

// 209F2308333B9973DE9B4EA31D526B89
void f0_10() {
   if (mm)
      if (RTRi_196 == FALSE || (RTRi_196 && (!RTRi_636) && RTRd_1248 >= 0.0) || (RTRi_196 && RTRi_636) && RTRi_484 == FALSE || (RTRi_484 && f0_66() == 0)) lots = f0_49(risk);
   RTRd_1208 = lots;
   RTRd_1216 = lots;
}

// AC33B4E969C6D6701461AF94B4EB808F
void f0_48() {
   if (mm) {
      if (MarketInfo(Symbol(), MODE_MINLOT) >= 1.0) RTRi_1068 = 100000;
      if (MarketInfo(Symbol(), MODE_MINLOT) < 1.0) RTRi_1068 = 10000;
      if (MarketInfo(Symbol(), MODE_MINLOT) < 0.1) RTRi_1068 = 1000;
      if (RTRi_484) lots = f0_49(risk);
   }
}

// B3CD915D758008BD19D0F2428FBB354A
double f0_49(double xxxxd_0) {
   double YYYYd_ret_8;
   if (stoploss > 0.0) YYYYd_ret_8 = AccountBalance() * (xxxxd_0 / 100.0) / (stoploss * RTRd_1792 / MarketInfo(Symbol(), MODE_TICKSIZE) * MarketInfo(Symbol(), MODE_TICKVALUE));
   else YYYYd_ret_8 = f0_46(AccountBalance() / RTRi_1068 / 100.0 * xxxxd_0, lotdigits);
   return (YYYYd_ret_8);
}

// 93563B5493D5328EE287BC009CD98DD8
void f0_43() {
   if (RTRi_196) {
      if (!RTRi_636) f0_52();
      if (RTRi_636) f0_14();
   }
}

// BE5098500291EEAC5F94E5920CBA6E5F
void f0_52() {
   RTRi_1080 = FALSE;
   RTRd_1372 = 0;
   RTRd_1364 = 0;
   RTRd_1240 = f0_20(0);
   RTRd_1248 = f0_20(1);
   RTRd_1256 = 0;
   if (RTRi_200 == 0) {
      if (RTRd_1248 < 0.0) {
         RTRd_1256 = RTRd_1240 * RTRd_204;
         if (RTRi_252 < 500) {
            RTRi_1132 = f0_32(0);
            if (RTRi_1132 >= RTRi_252) RTRd_1256 = lots;
         }
         if (RTRd_212 != 0.0) {
            RTRd_1372 = f0_44(0);
            RTRi_1080 = TRUE;
            RTRd_1364 = f0_46(RTRd_1372 / 100.0 * RTRd_212, 2);
         }
      } else RTRd_1256 = lots;
   }
   if (RTRi_200 == 1) {
      if (RTRd_1248 > 0.0) {
         RTRd_1256 = RTRd_1240 * RTRd_204;
         if (RTRi_252 < 500) {
            RTRi_1136 = f0_32(1);
            if (RTRi_1136 >= RTRi_252) RTRd_1256 = lots;
         }
      } else {
         RTRd_1256 = lots;
         if (RTRd_212 != 0.0) {
            RTRd_1372 = f0_44(0);
            RTRi_1080 = TRUE;
            RTRd_1364 = f0_46(RTRd_1372 / 100.0 * RTRd_212, 2);
         }
      }
   }
   RTRd_1208 = RTRd_1256;
   RTRd_1216 = RTRd_1256;
}

// BFB26825FC577670A1E47E48620E9D86
void f0_53() {
   if (RTRi_220) {
      RTRda_1304[0] = 1;
      RTRda_1304[1] = 1;
      RTRda_1304[2] = 2;
      RTRda_1304[3] = 3;
      RTRda_1304[4] = 5;
      RTRda_1304[5] = 8;
      RTRda_1304[6] = 13;
      RTRda_1304[7] = 21;
      RTRda_1304[8] = 34;
      RTRda_1304[9] = 55;
      RTRda_1304[10] = 89;
      RTRda_1304[11] = 144;
      RTRda_1304[12] = 233;
      RTRda_1304[13] = 377;
      RTRda_1304[14] = 610;
      RTRda_1304[15] = 987;
      RTRda_1304[16] = 1597;
      RTRda_1304[17] = 2584;
      RTRda_1304[18] = 4181;
      RTRda_1304[19] = 6765;
      RTRda_1304[20] = 10946;
   }
}

// 3E0E1E0651A67F216012E7981C695166
void f0_21() {
   if (RTRi_220) f0_7();
}

// 10CE897B6293451FAE0C6097F1B466F7
void f0_7() {
   if (OrdersHistoryTotal() > 0) {
      if (RTRi_224 == 0) {
         RTRi_1132 = f0_32(0);
         RTRd_1208 = lots * RTRda_1304[RTRi_1132];
         RTRd_1216 = lots * RTRda_1304[RTRi_1132];
         if (RTRi_252 < 500) {
            if (RTRi_1132 >= RTRi_252) {
               RTRd_1208 = lots;
               RTRd_1216 = lots;
            }
         }
      }
      if (RTRi_224 == 1) {
         RTRi_1136 = f0_32(1);
         RTRd_1208 = lots * RTRda_1304[RTRi_1136];
         RTRd_1216 = lots * RTRda_1304[RTRi_1136];
         if (RTRi_252 < 500) {
            if (RTRi_1136 >= RTRi_252) {
               RTRd_1208 = lots;
               RTRd_1216 = lots;
            }
         }
      }
   }
}

// 87FFB3E443716D9FC26578CD3A817865
void f0_38() {
   if (RTRi_228) f0_18();
}

// 3555B1EFDBF1F6B8B102B51EFDD7FAFC
void f0_18() {
   RTRd_1240 = f0_20(0);
   RTRd_1468 = f0_20(1);
   if (RTRd_1468 > 0.0) {
      if (RTRi_232 == 0) {
         RTRd_1208 = RTRd_1240 - lots * RTRd_244;
         RTRd_1216 = RTRd_1240 - lots * RTRd_244;
         if (RTRi_252 < 500) {
            RTRi_1132 = f0_32(0);
            if (RTRi_1132 >= RTRi_252) {
               RTRd_1208 = lots;
               RTRd_1216 = lots;
            }
         }
      } else {
         RTRd_1208 = RTRd_1240 + lots * RTRd_236;
         RTRd_1216 = RTRd_1240 + lots * RTRd_236;
      }
   }
   if (RTRd_1468 < 0.0) {
      if (RTRi_232 == 0) {
         RTRd_1208 = RTRd_1240 + lots * RTRd_236;
         RTRd_1216 = RTRd_1240 + lots * RTRd_236;
         if (RTRi_252 >= 500) return;
         RTRi_1136 = f0_32(1);
         if (RTRi_1136 < RTRi_252) return;
         RTRd_1208 = lots;
         RTRd_1216 = lots;
         return;
      }
      RTRd_1208 = RTRd_1240 - lots * RTRd_244;
      RTRd_1216 = RTRd_1240 - lots * RTRd_244;
   }
}

// 6CCF929934691710135F3F0DF7CC43C5
void f0_28() {
   if (RTRi_184) {
      RTRd_1208 = f0_64(lots);
      RTRd_1216 = f0_64(lots);
   }
}

// F74B591DE8514761AABAC3EAEA6CDB5F
double f0_64(double xxxxd_0) {
   RTRd_1452 = f0_22(1);
   if (RTRd_1444 <= RTRd_1452) RTRd_1444 = RTRd_1452;
   if (RTRd_1444 > RTRd_1452) return (RTRd_188 * xxxxd_0);
   return (xxxxd_0);
}

// 716F6B30598BA30945D84485E61C1027
void f0_30(int xxxxi_0) {
   if (OrdersTotal() > 0) {
      for (RTR_pos_1048 = OrdersTotal() - 1; RTR_pos_1048 >= 0; RTR_pos_1048--) {
         OrderSelect(RTR_pos_1048, SELECT_BY_POS, MODE_TRADES);
         if (xxxxi_0 == 3 || xxxxi_0 == 0 && OrderType() == OP_BUY) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && RTRi_432 == 0 || (RTRi_432 > 0 && OrderClosePrice() - OrderOpenPrice() < (-1 * RTRi_432) * RTRd_1792)) {
               RefreshRates();
               OrderClose(OrderTicket(), OrderLots(), f0_46(Bid, RTR_digits_1784), RTRd_576 * RTRd_1800);
            }
         }
         if (xxxxi_0 == 3 || xxxxi_0 == 1 && OrderType() == OP_SELL) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && RTRi_432 == 0 || (RTRi_432 > 0 && OrderOpenPrice() - OrderClosePrice() < (-1 * RTRi_432) * RTRd_1792)) {
               RefreshRates();
               OrderClose(OrderTicket(), OrderLots(), f0_46(Ask, RTR_digits_1784), RTRd_576 * RTRd_1800);
            }
         }
      }
   }
}

// C5D503A3228BBD0F937EF160F08A5560
void f0_54() {
   if (OrdersTotal() > 0) {
      for (RTR_pos_1048 = OrdersTotal() - 1; RTR_pos_1048 >= 0; RTR_pos_1048--) {
         OrderSelect(RTR_pos_1048, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() == OP_BUY) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && (hidesl && stoploss > 0.0 && f0_46(OrderClosePrice() - OrderOpenPrice(), RTR_digits_1784) <= (-1.0 * stoploss) * RTRd_1792 - MarketInfo(Symbol(),
               MODE_SPREAD) * RTRd_1792) || (hidetp && takeprofit > 0.0 && f0_46(OrderClosePrice() - OrderOpenPrice(), RTR_digits_1784) >= takeprofit * RTRd_1792)) {
               RefreshRates();
               OrderClose(OrderTicket(), OrderLots(), Bid, RTRd_576 * RTRd_1800);
            }
         }
         if (OrderType() == OP_SELL) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && (hidesl && stoploss > 0.0 && f0_46(OrderOpenPrice() - OrderClosePrice(), RTR_digits_1784) <= (-1.0 * stoploss) * RTRd_1792 - MarketInfo(Symbol(),
               MODE_SPREAD) * RTRd_1792) || (hidetp && takeprofit > 0.0 && f0_46(OrderOpenPrice() - OrderClosePrice(), RTR_digits_1784) >= takeprofit * RTRd_1792)) {
               RefreshRates();
               OrderClose(OrderTicket(), OrderLots(), Ask, RTRd_576 * RTRd_1800);
            }
         }
      }
   }
}

// 2253C3089F9D00C8B048717CF84A7295
void f0_12(int xxxxi_0, int xxxxi_4, double xxxxd_8, double xxxxd_16) {
   if (OrdersTotal() > 0) {
      for (RTR_pos_1048 = OrdersTotal() - 1; RTR_pos_1048 >= 0; RTR_pos_1048--) {
         OrderSelect(RTR_pos_1048, SELECT_BY_POS, MODE_TRADES);
         if (xxxxd_8 < minlot) xxxxd_8 = minlot;
         if (xxxxi_0 == 3 || xxxxi_0 == 0 && OrderType() == OP_BUY) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderLots() >= xxxxd_8 && (xxxxi_4 == 0 && OrderClosePrice() - OrderOpenPrice() >= xxxxd_16 * RTRd_1792) ||
               xxxxi_4 == 1) {
               RefreshRates();
               OrderClose(OrderTicket(), f0_46(xxxxd_8, lotdigits), f0_46(Bid, RTR_digits_1784), RTRd_576 * RTRd_1800);
            }
         }
         if (xxxxi_0 == 3 || xxxxi_0 == 1 && OrderType() == OP_SELL) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderLots() >= xxxxd_8 && (xxxxi_4 == 0 && OrderOpenPrice() - OrderClosePrice() >= xxxxd_16 * RTRd_1792) ||
               xxxxi_4 == 1) {
               RefreshRates();
               OrderClose(OrderTicket(), f0_46(xxxxd_8, lotdigits), f0_46(Ask, RTR_digits_1784), RTRd_576 * RTRd_1800);
            }
         }
      }
   }
}

// 22B3BA4C071BE2CEF3256046E4A421AD
void f0_13(int xxxxi_0, int xxxxi_4, double xxxxd_8, double xxxxd_16, double xxxxd_24) {
   if (OrdersTotal() > 0) {
      for (RTR_pos_1048 = OrdersTotal() - 1; RTR_pos_1048 >= 0; RTR_pos_1048--) {
         OrderSelect(RTR_pos_1048, SELECT_BY_POS, MODE_TRADES);
         if (xxxxd_16 < minlot) xxxxd_16 = minlot;
         if (xxxxi_0 == 3 || xxxxi_0 == 0 && OrderType() == OP_BUY) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderLots() == f0_46(xxxxd_8, lotdigits) && OrderLots() >= minlot && (xxxxi_4 == 0 && OrderClosePrice() - OrderOpenPrice() >= xxxxd_24 * RTRd_1792) ||
               xxxxi_4 == 1) {
               RefreshRates();
               OrderClose(OrderTicket(), f0_46(xxxxd_16, lotdigits), f0_46(Bid, RTR_digits_1784), RTRd_576 * RTRd_1800);
            }
         }
         if (xxxxi_0 == 3 || xxxxi_0 == 1 && OrderType() == OP_SELL) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderLots() == f0_46(xxxxd_8, lotdigits) && OrderLots() >= minlot && (xxxxi_4 == 0 && OrderOpenPrice() - OrderClosePrice() >= xxxxd_24 * RTRd_1792) ||
               xxxxi_4 == 1) {
               RefreshRates();
               OrderClose(OrderTicket(), f0_46(xxxxd_16, lotdigits), f0_46(Ask, RTR_digits_1784), RTRd_576 * RTRd_1800);
            }
         }
      }
   }
}

// F266344C21865AD34CF1F053154212F5
void f0_63(int xxxxi_0, double xxxxd_4, double xxxxd_12, double xxxxd_20) {
   RTRd_1340 = 0;
   RTRi_1128 = 0;
   if (OrdersTotal() > 0) {
      for (RTR_pos_1048 = OrdersTotal() - 1; RTR_pos_1048 >= 0; RTR_pos_1048--) {
         OrderSelect(RTR_pos_1048, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() == OP_BUY) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
               RTRd_1340 = f0_46(OrderClosePrice() - OrderOpenPrice(), RTR_digits_1784);
               RTRi_1128 = TimeCurrent() - OrderOpenTime();
               if ((xxxxi_0 == 0 && RTRd_1340 >= xxxxd_4 * RTRd_1792 && RTRi_1128 > 60.0 * xxxxd_12 && RTRi_1128 < 60.0 * xxxxd_20) || (xxxxi_0 == 1 && RTRd_1340 >= xxxxd_4 * RTRd_1792 &&
                  RTRi_1128 > 60.0 * xxxxd_12)) {
                  RefreshRates();
                  OrderClose(OrderTicket(), OrderLots(), Bid, RTRd_576 * RTRd_1800);
               }
            }
         }
         if (OrderType() == OP_SELL) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
               RTRd_1340 = f0_46(OrderOpenPrice() - OrderClosePrice(), RTR_digits_1784);
               RTRi_1128 = TimeCurrent() - OrderOpenTime();
               if ((xxxxi_0 == 0 && RTRd_1340 >= xxxxd_4 * RTRd_1792 && RTRi_1128 > 60.0 * xxxxd_12 && RTRi_1128 < 60.0 * xxxxd_20) || (xxxxi_0 == 1 && RTRd_1340 >= xxxxd_4 * RTRd_1792 &&
                  RTRi_1128 > 60.0 * xxxxd_12)) {
                  RefreshRates();
                  OrderClose(OrderTicket(), OrderLots(), Ask, RTRd_576 * RTRd_1800);
               }
            }
         }
      }
   }
}

// 099AF53F601532DBD31E0EA99FFDEB64
void f0_2(int xxxx_cmd_0) {
   if (OrdersTotal() > 0) {
      for (RTR_pos_1048 = OrdersTotal() - 1; RTR_pos_1048 >= 0; RTR_pos_1048--) {
         OrderSelect(RTR_pos_1048, SELECT_BY_POS, MODE_TRADES);
         if (xxxx_cmd_0 != 6 && xxxx_cmd_0 != 7 && xxxx_cmd_0 != 8)
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == xxxx_cmd_0) OrderDelete(OrderTicket());
         if (xxxx_cmd_0 == 6)
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP || OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT) OrderDelete(OrderTicket());
         if (xxxx_cmd_0 == 7)
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_BUYSTOP || OrderType() == OP_BUYLIMIT) OrderDelete(OrderTicket());
         if (xxxx_cmd_0 == 8)
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT) OrderDelete(OrderTicket());
      }
   }
}

// 799B6F2C43F9E173C5420064357F04E6
void f0_33() {
   f0_30(0);
   f0_30(1);
   f0_2(7);
   f0_2(8);
}

// EF399B2D446BB37B7C32AD2CC1B6045B
void f0_61() {
   if (oppositeclose) {
      if (RTRi_1008) {
         if (RTRi_480) f0_12(1, 1, lots * RTRd_496 / 100.0, 0);
         else f0_30(1);
      }
      if (RTRi_1012) {
         if (RTRi_480) f0_12(0, 1, lots * RTRd_496 / 100.0, 0);
         else f0_30(0);
      }
      if (RTRi_428) {
         if (RTRs_1540 == "LONG") f0_30(0);
         if (RTRs_1540 == "SHORT") f0_30(1);
      }
      if (RTRi_480 == FALSE && RTR_datetime_1144 > RTR_datetime_1148 && RTR_datetime_1148 != 0) f0_30(1);
      if (RTRi_480 == FALSE && RTR_datetime_1148 > RTR_datetime_1144 && RTR_datetime_1144 != 0) f0_30(0);
   }
   if (hidetp || hidesl) f0_54();
   if (RTRi_408) {
      if (f0_58(OP_SELL) > 0) f0_2(7);
      if (f0_58(OP_BUY) > 0) f0_2(8);
   }
   if (RTRi_484) {
      f0_13(3, 0, RTRd_1208, RTRd_1208 * RTRd_496 / 100.0, RTRd_488);
      RTRd_1460 = RTRd_1208 - RTRd_1208 * RTRd_496 / 100.0;
      if (RTRd_1208 * RTRd_496 / 100.0 < minlot) RTRd_1460 = RTRd_1208 - minlot;
      f0_13(3, 0, RTRd_1460, RTRd_1208 * RTRd_512 / 100.0, RTRd_504);
   }
   if (RTRi_1080 == TRUE && RTRd_1280 >= (-1.0 * RTRd_1364)) f0_30(3);
   if (RTRi_932) {
      f0_63(0, RTRi_940, RTRi_936, RTRi_944);
      f0_63(0, RTRi_948, RTRi_944, RTRi_952);
      f0_63(0, RTRi_956, RTRi_952, RTRi_960);
      f0_63(0, RTRi_964, RTRi_960, RTRi_968);
      f0_63(0, RTRi_972, RTRi_968, RTRi_976);
      f0_63(0, RTRi_980, RTRi_976, RTRi_984);
      f0_63(1, RTRi_988, RTRi_984, 0);
   }
   if (RTRi_1168 == TRUE) {
      if (reversesignals) f0_30(1);
      else f0_30(0);
   }
   if (RTRi_1172 == 2) {
      if (reversesignals) {
         f0_30(0);
         return;
      }
      f0_30(1);
   }
}

// 6DE16931209DF21117152D106A975D61
void f0_29(int xxxxi_0, double xxxxd_4, double xxxxd_12) {
   RefreshRates();
   if (OrdersTotal() > 0) {
      for (RTR_pos_1048 = OrdersTotal() - 1; RTR_pos_1048 >= 0; RTR_pos_1048--) {
         OrderSelect(RTR_pos_1048, SELECT_BY_POS, MODE_TRADES);
         if (xxxxi_0 == 0) {
            if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
               if (OrderType() == OP_BUY) {
                  if (f0_46(Ask, RTR_digits_1784) > f0_46(OrderOpenPrice() + xxxxd_4 * RTRd_1792, RTR_digits_1784) && f0_46(OrderStopLoss(), RTR_digits_1784) < f0_46(Bid - (xxxxd_12 +
                     trailingstep) * RTRd_1792, RTR_digits_1784)) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), f0_46(Bid - xxxxd_12 * RTRd_1792, RTR_digits_1784), OrderTakeProfit(), 0, Blue);
                     return;
                  }
               } else {
                  if (f0_46(Bid, RTR_digits_1784) < f0_46(OrderOpenPrice() - xxxxd_4 * RTRd_1792, RTR_digits_1784) && f0_46(OrderStopLoss(), RTR_digits_1784) > f0_46(Ask + (xxxxd_12 +
                     trailingstep) * RTRd_1792, RTR_digits_1784) || OrderStopLoss() == 0.0) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), f0_46(Ask + xxxxd_12 * RTRd_1792, RTR_digits_1784), OrderTakeProfit(), 0, Red);
                     return;
                  }
               }
            }
         }
         if (xxxxi_0 == 1) {
            if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
               if (OrderType() == OP_BUY && OrderStopLoss() == 0.0) {
                  if (f0_46(Ask, RTR_digits_1784) >= f0_46(OrderOpenPrice() + xxxxd_4 * RTRd_1792, RTR_digits_1784)) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), f0_46(OrderOpenPrice() + xxxxd_12 * RTRd_1792, RTR_digits_1784), OrderTakeProfit(), 0, Blue);
                     return;
                  }
               }
               if (OrderType() == OP_BUY && OrderStopLoss() != 0.0) {
                  if (f0_46(Ask, RTR_digits_1784) >= f0_46(OrderOpenPrice() + xxxxd_4 * RTRd_1792, RTR_digits_1784) && f0_46(Ask, RTR_digits_1784) >= f0_46(OrderStopLoss() + xxxxd_4 * RTRd_1792,
                     RTR_digits_1784)) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), f0_46(OrderStopLoss() + xxxxd_12 * RTRd_1792, RTR_digits_1784), OrderTakeProfit(), 0, Blue);
                     return;
                  }
               }
               if (OrderType() == OP_SELL && OrderStopLoss() == 0.0) {
                  if (f0_46(Bid, RTR_digits_1784) <= f0_46(OrderOpenPrice() - xxxxd_4 * RTRd_1792, RTR_digits_1784)) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), f0_46(OrderOpenPrice() - xxxxd_12 * RTRd_1792, RTR_digits_1784), OrderTakeProfit(), 0, Red);
                     return;
                  }
               }
               if (OrderType() == OP_SELL && OrderStopLoss() != 0.0) {
                  if (f0_46(Bid, RTR_digits_1784) <= f0_46(OrderOpenPrice() - xxxxd_4 * RTRd_1792, RTR_digits_1784) && f0_46(Bid, RTR_digits_1784) <= f0_46(OrderStopLoss() - xxxxd_4 * RTRd_1792,
                     RTR_digits_1784)) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), f0_46(OrderStopLoss() - xxxxd_12 * RTRd_1792, RTR_digits_1784), OrderTakeProfit(), 0, Red);
                     return;
                  }
               }
            }
         }
      }
   }
}

// 9351396E040873D136593DE1CC96C3F9
void f0_42(int xxxx_cmd_0, double xxxxd_4) {
   RefreshRates();
   if (OrdersTotal() > 0) {
      for (RTR_pos_1048 = OrdersTotal() - 1; RTR_pos_1048 >= 0; RTR_pos_1048--) {
         OrderSelect(RTR_pos_1048, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
            if (OrderType() == xxxx_cmd_0) {
               if (f0_46(OrderStopLoss(), RTR_digits_1784) == 0.0 && f0_46(Bid, RTR_digits_1784) > f0_46(xxxxd_4 + (MarketInfo(Symbol(), MODE_STOPLEVEL) + MarketInfo(Symbol(), MODE_SPREAD)) * RTRd_1792,
                  RTR_digits_1784)) {
                  OrderModify(OrderTicket(), OrderOpenPrice(), f0_46(xxxxd_4, RTR_digits_1784), OrderTakeProfit(), 0, Blue);
                  return;
               }
               if (f0_46(OrderStopLoss(), RTR_digits_1784) > 0.0 && f0_46(Bid, RTR_digits_1784) > f0_46(xxxxd_4 + (MarketInfo(Symbol(), MODE_STOPLEVEL) + MarketInfo(Symbol(), MODE_SPREAD)) * RTRd_1792,
                  RTR_digits_1784) && f0_46(xxxxd_4, RTR_digits_1784) > f0_46(OrderStopLoss(), RTR_digits_1784)) {
                  OrderModify(OrderTicket(), OrderOpenPrice(), f0_46(xxxxd_4, RTR_digits_1784), OrderTakeProfit(), 0, Blue);
                  return;
               }
            }
            if (OrderType() == xxxx_cmd_0) {
               if (f0_46(OrderStopLoss(), RTR_digits_1784) == 0.0 && f0_46(Ask, RTR_digits_1784) < f0_46(xxxxd_4 - (MarketInfo(Symbol(), MODE_STOPLEVEL) + MarketInfo(Symbol(), MODE_SPREAD)) * RTRd_1792,
                  RTR_digits_1784)) {
                  OrderModify(OrderTicket(), OrderOpenPrice(), f0_46(xxxxd_4, RTR_digits_1784), OrderTakeProfit(), 0, Red);
                  return;
               }
               if (f0_46(OrderStopLoss(), RTR_digits_1784) > 0.0 && f0_46(Ask, RTR_digits_1784) < f0_46(xxxxd_4 - (MarketInfo(Symbol(), MODE_STOPLEVEL) + MarketInfo(Symbol(), MODE_SPREAD)) * RTRd_1792,
                  RTR_digits_1784) && f0_46(xxxxd_4, RTR_digits_1784) < f0_46(OrderStopLoss(), RTR_digits_1784)) {
                  OrderModify(OrderTicket(), OrderOpenPrice(), f0_46(xxxxd_4, RTR_digits_1784), OrderTakeProfit(), 0, Red);
                  return;
               }
            }
         }
      }
   }
}

// 73BBD91C5E8DA93BBB9A157AB3439809
void f0_31(double xxxxd_0, double xxxxd_8) {
   RefreshRates();
   if (OrdersTotal() > 0) {
      for (RTR_pos_1048 = OrdersTotal() - 1; RTR_pos_1048 >= 0; RTR_pos_1048--) {
         if (OrderSelect(RTR_pos_1048, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
               if (OrderType() == OP_BUY) {
                  if (f0_46(Bid - OrderOpenPrice(), RTR_digits_1784) <= f0_46((-1.0 * xxxxd_0) * RTRd_1792, RTR_digits_1784)) {
                     if (f0_46(OrderTakeProfit(), RTR_digits_1784) > f0_46(Bid + (xxxxd_8 + trailingstep) * RTRd_1792, RTR_digits_1784) || f0_46(OrderTakeProfit(), RTR_digits_1784) == 0.0) {
                        OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), f0_46(Bid + xxxxd_8 * RTRd_1792, RTR_digits_1784), 0, Blue);
                        return;
                     }
                  }
               }
               if (OrderType() == OP_SELL) {
                  if (f0_46(OrderOpenPrice() - Ask, RTR_digits_1784) <= f0_46((-1.0 * xxxxd_0) * RTRd_1792, RTR_digits_1784)) {
                     if (f0_46(OrderTakeProfit(), RTR_digits_1784) < f0_46(Ask - (xxxxd_8 + trailingstep) * RTRd_1792, RTR_digits_1784)) {
                        OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), f0_46(Ask - xxxxd_8 * RTRd_1792, RTR_digits_1784), 0, Red);
                        return;
                     }
                  }
               }
            }
         }
      }
   }
}

// 7F27FC242C0738054AC7C7E3A2B292B1
void f0_36(double xxxxd_0, double xxxxd_8) {
   RefreshRates();
   if (OrdersTotal() > 0) {
      for (RTR_pos_1048 = OrdersTotal() - 1; RTR_pos_1048 >= 0; RTR_pos_1048--) {
         OrderSelect(RTR_pos_1048, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
            if (OrderType() == OP_BUY) {
               if (f0_46(Bid - OrderOpenPrice(), RTR_digits_1784) < f0_46(xxxxd_0 * RTRd_1792, RTR_digits_1784)) continue;
               if (!(f0_46(OrderStopLoss() - OrderOpenPrice(), RTR_digits_1784) < f0_46(xxxxd_8 * RTRd_1792, RTR_digits_1784) || OrderStopLoss() == 0.0)) continue;
               OrderModify(OrderTicket(), OrderOpenPrice(), f0_46(OrderOpenPrice() + xxxxd_8 * RTRd_1792, RTR_digits_1784), OrderTakeProfit(), 0, Blue);
               return;
            }
            if (f0_46(OrderOpenPrice() - Ask, RTR_digits_1784) >= f0_46(xxxxd_0 * RTRd_1792, RTR_digits_1784)) {
               if (f0_46(OrderOpenPrice() - OrderStopLoss(), RTR_digits_1784) < f0_46(xxxxd_8 * RTRd_1792, RTR_digits_1784) || OrderStopLoss() == 0.0) {
                  OrderModify(OrderTicket(), OrderOpenPrice(), f0_46(OrderOpenPrice() - xxxxd_8 * RTRd_1792, RTR_digits_1784), OrderTakeProfit(), 0, Red);
                  return;
               }
            }
         }
      }
   }
}

// 0C55C96F7804991BA94A89341D31D35C
void f0_3(double xxxxd_0, double xxxxd_8) {
   if (OrdersTotal() > 0) {
      for (RTR_pos_1048 = OrdersTotal() - 1; RTR_pos_1048 >= 0; RTR_pos_1048--) {
         OrderSelect(RTR_pos_1048, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
            if (OrderType() == OP_BUY) {
               if (OrderStopLoss() == 0.0 && xxxxd_0 > 0.0 && xxxxd_8 == 0.0) {
                  RefreshRates();
                  OrderModify(OrderTicket(), OrderOpenPrice(), f0_46(Ask - xxxxd_0 * RTRd_1792, RTR_digits_1784), OrderTakeProfit(), 0, Red);
                  return;
               }
               if (OrderTakeProfit() == 0.0 && xxxxd_0 == 0.0 && xxxxd_8 > 0.0) {
                  RefreshRates();
                  OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), f0_46(Ask + xxxxd_8 * RTRd_1792, RTR_digits_1784), 0, Red);
                  return;
               }
               if (OrderTakeProfit() == 0.0 && OrderStopLoss() == 0.0 && xxxxd_0 > 0.0 && xxxxd_8 > 0.0) {
                  RefreshRates();
                  OrderModify(OrderTicket(), OrderOpenPrice(), f0_46(Ask - xxxxd_0 * RTRd_1792, RTR_digits_1784), f0_46(Ask + xxxxd_8 * RTRd_1792, RTR_digits_1784), 0, Red);
                  return;
               }
            }
            if (OrderType() == OP_SELL) {
               if (OrderStopLoss() == 0.0 && xxxxd_0 > 0.0 && xxxxd_8 == 0.0) {
                  RefreshRates();
                  OrderModify(OrderTicket(), OrderOpenPrice(), f0_46(Bid + xxxxd_0 * RTRd_1792, RTR_digits_1784), OrderTakeProfit(), 0, Red);
                  return;
               }
               if (OrderTakeProfit() == 0.0 && xxxxd_0 == 0.0 && xxxxd_8 > 0.0) {
                  RefreshRates();
                  OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), f0_46(Bid - xxxxd_8 * RTRd_1792, RTR_digits_1784), 0, Red);
                  return;
               }
               if (OrderTakeProfit() == 0.0 && OrderStopLoss() == 0.0 && xxxxd_0 > 0.0 && xxxxd_8 > 0.0) {
                  RefreshRates();
                  OrderModify(OrderTicket(), OrderOpenPrice(), f0_46(Bid + xxxxd_0 * RTRd_1792, RTR_digits_1784), f0_46(Bid - xxxxd_8 * RTRd_1792, RTR_digits_1784), 0, Red);
                  return;
               }
            }
         }
      }
   }
}

// 8F45A2644508B5282F57FE129F62D19A
void f0_41() {
   if (RTRi_692) {
      f0_42(OP_BUY, Low[shift] - RTRi_696 * RTRd_1792);
      f0_42(OP_SELL, High[shift] + RTRi_696 * RTRd_1792);
   }
   if (breakevengain > 0.0) f0_36(breakevengain, breakeven);
   if (trailingstop > 0.0) f0_29(RTRi_520, trailingstart, trailingstop);
   if (trailing > 0.0) f0_29(0, trailing, trailing);
   if (RTRd_540 > 0.0) f0_31(trailingstart, RTRd_540);
   if (ecn) f0_3(stoploss, takeprofit);
}

// 0F6CDB621B452AC6FB994D88E674E49F
void f0_5() {
   if (RTRi_264 || RTRi_284 || RTRi_304 || RTRi_324 || RTRi_344 || RTRi_364) f0_57();
}

// D486A56867AB775AA2C397A06DDF523C
void f0_57() {
   if (RTRi_264) {
      if (RTRs_1684 == "CLOSE")
         if (f0_16(1) == 0) RTRs_1684 = "";
      if (f0_59(1) >= f0_46(RTRd_268 / 100.0 * AccountBalance(), 2) || f0_59(1) <= (-1.0 * f0_46(RTRd_276 / 100.0 * AccountBalance(), 2))) RTRs_1684 = "CLOSE";
      if (RTRs_1684 == "CLOSE") f0_33();
   }
   if (RTRi_284) {
      if (RTRs_1660 == "CLOSE")
         if (f0_16(1) == 0) RTRs_1660 = "";
      if (f0_59(0) >= RTRd_288 || f0_59(0) <= (-1.0 * RTRd_296)) RTRs_1660 = "CLOSE";
      if (RTRs_1660 == "CLOSE") f0_33();
   }
   if (RTRi_304) {
      if (RTRs_1668 == "CLOSE")
         if (f0_16(1) == 0) RTRs_1668 = "";
      if (f0_59(1) >= RTRd_308 || f0_59(1) <= (-1.0 * RTRd_316)) RTRs_1668 = "CLOSE";
      if (RTRs_1668 == "CLOSE") f0_33();
   }
   if (RTRi_324) {
      if (f0_16(1) == 0) {
         if (RTRs_1692 == "CLOSE") RTRs_1692 = "";
         RTRd_1428 = 0;
         RTRd_1436 = 0;
      }
      if (f0_16(1) == 0 != FALSE && f0_59(1) >= RTRd_1428 + f0_46(RTRd_328 / 100.0 * AccountBalance(), 2)) {
         RTRd_1428 = f0_59(1);
         RTRd_1436 = RTRd_1428 - RTRd_1428 * (RTRd_328 - RTRd_336) / 100.0;
      }
      if (f0_59(1) <= RTRd_1436 && RTRd_1436 != 0.0) RTRs_1692 = "CLOSE";
      if (RTRs_1692 == "CLOSE") f0_33();
   }
   if (RTRi_344) {
      if (RTRs_1676 == "CLOSE")
         if (f0_16(1) == 0) RTRs_1676 = "";
      if (f0_16(1) == 0) {
         RTRd_1396 = 0;
         RTRd_1404 = 0;
      }
      if (f0_16(1) != 0 && f0_59(0) >= RTRd_1396 + RTRd_348) {
         RTRd_1396 = f0_59(0);
         RTRd_1404 = RTRd_1396 - (RTRd_348 - RTRd_356);
      }
      if (f0_59(0) <= RTRd_1404 && RTRd_1404 != 0.0) RTRs_1676 = "CLOSE";
      if (RTRs_1676 == "CLOSE") f0_33();
   }
   if (RTRi_364) {
      if (RTRs_1700 == "CLOSE")
         if (f0_16(1) == 0) RTRs_1700 = "";
      if (f0_16(1) == 0) {
         RTRd_1420 = 0;
         RTRd_1412 = 0;
      }
      if (f0_16(1) != 0 && f0_59(1) >= RTRd_1420 + RTRd_368) {
         RTRd_1420 = f0_59(1);
         RTRd_1412 = RTRd_1420 - (RTRd_368 - RTRd_376);
      }
      if (f0_59(0) <= RTRd_1412 && RTRd_1412 != 0.0) RTRs_1700 = "CLOSE";
      if (RTRs_1700 == "CLOSE") f0_33();
   }
}

// C9FAB33E9458412C527C3FE8A13EE37D
void f0_55() {
   RTRi_1004 = TRUE;
   if (RTRi_680) f0_65();
}

// F92DB2A463384DB5C9700A276CEC28B3
void f0_65() {
   if (OrdersHistoryTotal() > 0) {
      RTRi_1072 = f0_32(0);
      RTR_datetime_1764 = 0;
      for (RTR_pos_1048 = OrdersHistoryTotal() - 1; RTR_pos_1048 >= 0; RTR_pos_1048--) {
         OrderSelect(RTR_pos_1048, SELECT_BY_POS, MODE_HISTORY);
         if (RTR_datetime_1764 != 0) break;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) RTR_datetime_1764 = OrderCloseTime();
      }
      if (RTRi_1072 >= RTRi_684)
         if (TimeCurrent() - RTR_datetime_1764 < 60 * RTRi_688) RTRi_1004 = FALSE;
   }
}

// 07CC694B9B3FC636710FA08B6922C42B
void f0_1() {
   RTRi_1032 = TRUE;
   if (usetimefilter) {
      if (f0_11(summergmtshift, wintergmtshift, mondayfilter, mondayhour, mondayminute, weekfilter, starthour, startminute, endhour, endminute, tradesunday, fridayfilter,
         fridayhour, fridayminute)) RTRi_1032 = FALSE;
   }
}

// 20BD1B26E34C29E3BA32B7D41776D9B5
int f0_11(int xxxxi_0, int xxxxi_4, bool xxxxi_8, int xxxxi_12, int xxxxi_16, bool xxxxi_20, int xxxxi_24, int xxxxi_28, int xxxxi_32, int xxxxi_36, int xxxxi_40, bool xxxxi_44, int xxxxi_48, int xxxxi_52) {
   RTRda_1268[13] = D'28.03.2012 09:00';
   RTRda_1264[13] = D'31.10.2012 10:00';
   RTRda_1268[12] = D'29.03.2011 09:00';
   RTRda_1264[12] = D'25.10.2011 10:00';
   RTRda_1268[11] = D'30.03.2010 09:00';
   RTRda_1264[11] = D'26.10.2010 10:00';
   RTRda_1268[10] = D'29.03.2009 09:00';
   RTRda_1264[10] = D'25.10.2009 10:00';
   RTRda_1268[9] = D'30.03.2008 09:00';
   RTRda_1264[9] = D'26.10.2008 10:00';
   RTRda_1268[8] = D'25.03.2007 09:00';
   RTRda_1264[8] = D'28.10.2007 10:00';
   RTRda_1268[7] = D'26.03.2006 09:00';
   RTRda_1264[7] = D'29.10.2006 10:00';
   RTRda_1268[6] = D'27.03.2005 09:00';
   RTRda_1264[6] = D'30.10.2005 10:00';
   RTRda_1268[5] = D'28.03.2004 09:00';
   RTRda_1264[5] = D'31.10.2004 10:00';
   RTRda_1268[4] = D'30.03.2003 09:00';
   RTRda_1264[4] = D'26.10.2003 10:00';
   RTRda_1268[3] = D'31.03.2002 09:00';
   RTRda_1264[3] = D'27.10.2002 10:00';
   RTRda_1268[2] = D'25.03.2001 09:00';
   RTRda_1264[2] = D'28.10.2001 10:00';
   RTRda_1268[1] = D'26.03.2000 09:00';
   RTRda_1264[1] = D'29.10.2000 10:00';
   RTRda_1268[0] = 922586400;
   RTRda_1264[0] = 941338800;
   if (TimeCurrent() < RTRda_1264[TimeYear(TimeCurrent()) - 1999] && TimeCurrent() > RTRda_1268[TimeYear(TimeCurrent()) - 1999]) RTRi_1120 = xxxxi_0;
   else RTRi_1120 = xxxxi_4;
   string YYYYs_56 = Year() + "." + Month() + "." + Day();
   if (xxxxi_8) {
      RTRi_1108 = xxxxi_12 + RTRi_1120;
      if (RTRi_1108 > 23) RTRi_1108 -= 24;
      if (RTRi_1108 < 10) RTRs_1524 = "0" + RTRi_1108;
      if (RTRi_1108 > 9) RTRs_1524 = RTRi_1108;
      if (xxxxi_16 < 10) RTRs_1532 = "0" + xxxxi_16;
      if (xxxxi_16 > 9) RTRs_1532 = xxxxi_16;
      RTR_str2time_1720 = StrToTime(YYYYs_56 + " " + RTRs_1524 + ":" + RTRs_1532);
   }
   if (xxxxi_20) {
      RTRi_1092 = xxxxi_24 + RTRi_1120;
      if (RTRi_1092 > 23) RTRi_1092 -= 24;
      if (RTRi_1092 < 10) RTRs_1476 = "0" + RTRi_1092;
      if (RTRi_1092 > 9) RTRs_1476 = RTRi_1092;
      if (xxxxi_28 < 10) RTRs_1484 = "0" + xxxxi_28;
      if (xxxxi_28 > 9) RTRs_1484 = xxxxi_28;
      RTR_str2time_1708 = StrToTime(YYYYs_56 + " " + RTRs_1476 + ":" + RTRs_1484);
      RTRi_1100 = xxxxi_32 + RTRi_1120;
      if (RTRi_1100 > 23) RTRi_1100 -= 24;
      if (RTRi_1100 < 10) RTRs_1492 = "0" + RTRi_1100;
      if (RTRi_1100 > 9) RTRs_1492 = RTRi_1100;
      if (xxxxi_36 < 10) RTRs_1500 = "0" + xxxxi_36;
      if (xxxxi_36 > 9) RTRs_1500 = xxxxi_36;
      RTR_str2time_1712 = StrToTime(YYYYs_56 + " " + RTRs_1492 + ":" + RTRs_1500);
   }
   if (xxxxi_44) {
      RTRi_1104 = xxxxi_48 + RTRi_1120;
      if (RTRi_1104 > 23) RTRi_1104 -= 24;
      if (RTRi_1104 < 10) RTRs_1508 = "0" + RTRi_1104;
      if (RTRi_1104 > 9) RTRs_1508 = RTRi_1104;
      if (xxxxi_52 < 10) RTRs_1516 = "0" + xxxxi_52;
      if (xxxxi_52 > 9) RTRs_1516 = xxxxi_52;
      RTR_str2time_1716 = StrToTime(YYYYs_56 + " " + RTRs_1508 + ":" + RTRs_1516);
   }
   if (testhour != 24) {
      RTRi_1084 = testhour + RTRi_1120;
      if (RTRi_1084 > 23) RTRi_1084 -= 24;
      if (RTRi_1084 < 10) RTRs_1644 = "0" + RTRi_1084;
      if (RTRi_1084 > 9) RTRs_1644 = RTRi_1084;
      RTRs_1652 = "00";
      RTR_str2time_1780 = StrToTime(YYYYs_56 + " " + RTRs_1644 + ":" + RTRs_1652);
   }
   if (xxxxi_20) {
      if ((RTRi_1092 <= RTRi_1100 && TimeCurrent() < RTR_str2time_1708 || TimeCurrent() > RTR_str2time_1712) || (RTRi_1092 > RTRi_1100 && TimeCurrent() < RTR_str2time_1708 &&
         TimeCurrent() > RTR_str2time_1712)) return (1);
   }
   if (xxxxi_40 == 0)
      if (DayOfWeek() == 0) return (1);
   if (xxxxi_44)
      if (DayOfWeek() == 5 && TimeCurrent() > RTR_str2time_1716) return (1);
   if (xxxxi_8)
      if (DayOfWeek() == 1 && TimeCurrent() < RTR_str2time_1720) return (1);
   if (testhour != 24)
      if (TimeHour(TimeCurrent()) != TimeHour(RTR_str2time_1780)) return (1);
   return (0);
}

// 508C75C8507A2AE5223DFD2FAEB98122
void f0_23() {
   RTRi_1036 = TRUE;
   if (RTRi_900)
      if (f0_26()) RTRi_1036 = FALSE;
}

// 60C920674673AE62A5FF913DC8F22C17
int f0_26() {
   string name_0;
   int icustom_8;
   int icustom_12;
   int icustom_16;
   int icustom_20;
   if (IsTesting()) {
      if (RTR_time_1772 != Time[0]) {
         name_0 = "@BACKUP@.CSV";
         RTR_file_1152 = FileOpen(name_0, FILE_CSV|FILE_WRITE|FILE_READ);
         if (RTR_file_1152 > 0) {
            if (FileIsEnding(RTR_file_1152) == FALSE) {
               if (FileIsEnding(RTR_file_1152) == FALSE) {
                  RTRs_1548 = FileReadString(RTR_file_1152);
                  RTRs_1556 = StringSubstr(RTRs_1548, 1, 4);
                  RTRs_1564 = StringSubstr(RTRs_1548, 6, 2);
                  RTRs_1572 = StringSubstr(RTRs_1548, 9, 2);
                  RTRs_1580 = StringSubstr(RTRs_1548, 14, 5);
                  RTRs_1588 = StringSubstr(RTRs_1548, 24, 3);
                  RTR_str2time_1156 = StrToTime(RTRs_1556 + "." + RTRs_1564 + "." + RTRs_1572 + " " + RTRs_1580);
                  RTRs_1596 = StringSubstr(Symbol(), 0, 3);
                  RTRs_1604 = StringSubstr(Symbol(), 3, 3);
                  if (!((RTR_str2time_1156 - Time[0] >= 0 && RTR_str2time_1156 - Time[0] < 60 * RTRi_904) || (Time[0] - RTR_str2time_1156 >= 0 && Time[0] - RTR_str2time_1156 < 60 * RTRi_908) &&
                     RTRs_1596 == RTRs_1588 || RTRs_1604 == RTRs_1588)) return (1);
                  FileClose(RTR_file_1152);
                  return (1);
               }
            }
         }
         FileClose(RTR_file_1152);
         RTR_time_1772 = Time[0];
      }
   }
   if (IsTesting() == FALSE) {
      if (Minute() != RTR_minute_1808) {
         RTR_minute_1808 = Minute();
         icustom_8 = iCustom(NULL, 0, "FFCal", 1, 1, 0, 1, 1, 1, 0);
         icustom_12 = iCustom(NULL, 0, "FFCal", 1, 1, 0, 1, 1, 1, 1);
         icustom_16 = iCustom(NULL, 0, "FFCal", 1, 1, 0, 1, 1, 2, 0);
         icustom_20 = iCustom(NULL, 0, "FFCal", 1, 1, 0, 1, 1, 2, 1);
         if (RTRi_912 && (icustom_12 <= RTRi_904 && icustom_20 == 1) || (icustom_8 <= RTRi_908 && icustom_16 == 1)) return (1);
         if (RTRi_916 && (icustom_12 <= RTRi_904 && icustom_20 == 2) || (icustom_8 <= RTRi_908 && icustom_16 == 2)) return (1);
         if (RTRi_920 && (icustom_12 <= RTRi_904 && icustom_20 == 3) || (icustom_8 <= RTRi_908 && icustom_16 == 3)) return (1);
      }
   }
   return (0);
}

// A69913F66F2CFD4BD3F8EA75954AC476
double f0_46(double xxxxd_0, double xxxxd_8) {
   double YYYYd_16;
   YYYYd_16 = NormalizeDouble(xxxxd_0, xxxxd_8);
   return (YYYYd_16);
}

// A0ACFA46D86F7610B2C73DBB28F64701
int f0_45(int xxxxi_0) {
   switch (xxxxi_0) {
   case 0:
      return (0);
   case 1:
      return (1);
   case 2:
      return (5);
   case 3:
      return (15);
   case 4:
      return (30);
   case 5:
      return (60);
   case 6:
      return (240);
   case 7:
      return (1440);
   case 8:
      return (10080);
   case 9:
      return (43200);
   }
   return (0);
}
