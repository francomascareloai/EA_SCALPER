
#property copyright "Copyright © 2012, Forex-investor.net"
#property link      "http://www.forex-investor.net"

int g_acc_number_76 =0 ;
string gs_80 = "ShockBar_";
string gsa_88[7];
string gs_92;
int gi_100;
extern string ___WORC_MODE_ = "--- РЕЖИМ РАБОТЫ ---";
extern bool Exit_mode = TRUE;
extern string ___LOT_SETUP_BLOK_ = "--- БЛОК РАСЧЕТА ЛОТА ---";
extern bool LotConst_or_not = FALSE;
extern double RiskPercent = 3.0;
extern double Lot = 0.01;
double g_minlot_144 = 0.0;
extern double MaxL = 0.0;
int gi_160 = 0;
extern double LotMultiplicator = 1.667;
extern int N_LotMult = 2;
bool gi_176 = FALSE;
double gd_180 = 0.75;
int gi_188 = 40;
int gi_192;
extern string ___STEP_SETUP_BLOK_ = "--- БЛОК УСЛОВИЙ СЕТКИ ---";
extern int Mode_Step = 0;
extern int Step = 5;
int gi_212;
extern int StepUv_Step = 5;
int gi_220;
int gi_224;
int gi_228 = 0;
int gi_232 = 0;
extern string ___SETUP_SIGNAL_BLOK_ = "--- БЛОК ТОРГОВОГО СИГНАЛА ---";
string gs_244;
int gi_252 = 5;
int gi_256 = 7;
int gi_260 = 15;
double gd_264;
int gi_280 = 5;
double gd_284;
int gi_300;
int gi_304 = 5;
int gi_308 = 100;
int gi_312 = 50;
int gi_unused_316 = 14;
int gi_unused_320 = 0;
double gd_unused_324 = 0.08;
double gda_332[7];
double gda_336[7];
bool gi_340 = FALSE;
int gi_344 = 0;
int gi_348 = 21;
int gi_352 = 7;
int gi_356 = 50;
int gi_360 = 30;
int gi_364 = 90;
int gi_368 = 120;
int gi_372 = 10;
int gi_376 = 1;
double g_price_380;
double g_price_388;
double g_price_396;
double g_price_404;
double g_price_412;
double g_price_420;
extern bool Off_MA_H4 = TRUE;
extern int Mode_MA = 1;
extern int TF_for_MA = 5;
extern int Period_MA = 14;
string gs_444;
double g_price_452;
extern string ___CLOSE_SETUP_BLOK_ = "--- БЛОК УСТАНОВОК ЗАКРЫТИЯ ---";
extern int Mode_Close_Orders = 1;
extern int TakeProfit = 30;
extern int ProtectionTP = 5;
extern int TrallingStop = 5;
bool gi_484 = FALSE;
bool gi_488 = FALSE;
bool gi_492 = FALSE;
bool gi_496 = FALSE;
bool gi_500 = FALSE;
bool gi_504 = FALSE;
bool gi_unused_508 = FALSE;
bool gi_unused_512 = FALSE;
bool gi_unused_516 = FALSE;
extern string _RESTRICTION_ = "--- БЛОК ЗАЩИТЫ - ОГРАНИЧЕНИЯ ---";
extern bool BUY_SELL_SUMM = TRUE;
extern int MaxTrades = 18;
extern double Min_Proc_Sv_Sr = 0.0;
extern string ___DEF_STOPLOSS_ = "--- ЗАЩИТНЫЙ SL(общий) ---";
extern int Mode_SL_inst = 0;
extern double Percent_SL = 40.0;
double gd_564;
double g_price_572;
double g_price_580;
double g_pips_588 = 10.0;
extern string ___n6________________ = "--- ЗАЩИТА %-м ПРИБЫЛИ ---";
extern int Mode_enable_OTBOY = 2;
extern int N_Day_Prof = 7;
extern double PercentProf_from_OTBOY = 40.0;
extern int N_ord_enable_OTBOY = 4;
extern int r_cen_enable_OTBOY = 100;
extern string _ORDER_id_ = "--- МАРКЕР ОРДЕРА ---";
extern int Magic = 1111111;
extern string _OUT_DATA_ = "--- БЛОК ВЫВОДА ДАННЫХ НА ГРАФИК ---";
extern bool LineOnGraph = TRUE;
extern bool DataOnGraph = TRUE;
extern bool LogotipOn = TRUE;
int g_fontsize_660 = 14;
int g_color_664 = Yellow;
int gi_unused_668 = 13422920;
int gi_unused_672 = 55295;
int g_color_676 = Gray;
color g_color_680;
extern string _Step_N_ = "*** Если: Mode_Step = 3 ";
extern int St_2 = 30;
extern int St_3 = 25;
extern int St_4 = 20;
extern int St_5 = 15;
extern int St_6 = 10;
extern int St_7 = 5;
extern int St_8 = 100;
extern int St_9 = 30;
extern int St_10 = 20;
extern int St_11 = 10;
extern int St_12 = 100;
extern int St_13 = 30;
extern int St_14 = 20;
extern int St_15 = 10;
extern int St_16 = 30;
int gia_752[16];
int gi_756 = 3;
string gs_unused_760 = "ПАРАМЕТРЫ ИНДИКАТОРА";
int gi_unused_768 = 14;
double gd_772;
double gd_780;
double gd_788;
double g_color_796;
double gd_812;
double gd_820;
double gd_828;
double gd_836;
int gia_844[7];
int gia_unused_848[7];
int g_slippage_852 = 5;
int gi_856;
double gda_860[7];
double gda_864[7];
double gda_868[7];
double gda_872[7];
int gia_876[7];
int gia_880[7];
double gda_884[7];
double gda_888[7];
double gda_892[7];
double gda_896[7];
double gd_unused_900;
int gia_916[6][2] = {16711680, 255,
   15570276, 7504122,
   13959039, 17919,
   65535, 65535,
   16711680, 255,
   16711680, 255};
string gsa_920[6][2] = {"sled_BUY", "sled_SELL",
   "sled_BUY_1", "sled_SELL_1",
   "sled_BUY_2", "sled_SELL_2",
   "Max_BAR", "min_BAR",
   "Ur_BUY_Stop", "Ur_SELL_Stop",
   "Ur_BUY_Limit", "Ur_SELL_Limit"};
string gsa_924[6][2] = {"on_SL_1-N_BUY", "on_SL_1-N_SELL",
   "on_SL_1,N_BUY", "on_SL_1,N_SELL",
   "on_SL_1,N-1,N_BUY", "on_SL_1,N-1,N_SELL",
   "TS_BUY", "TS_SELL",
   "on_SL_N-1,N_BUY", "on_SL_N-1,N_SELL"};
int gi_928;
int gia_932[7] = {1, 0, 0, 0, 0, 0, 0};
string gsa_936[7];
int gia_940[7] = {9, 1, 0, 1, 1, 1, 1};
int gia_944[7] = {9, 3, 3, 3, 3, 3, 3};
int gia_948[7] = {9, 20, 20, 20, 20, 20, 20};
int gia_952[7] = {5, 5, 5, 5, 7, 7, 7};
int gia_956[7] = {111, 222, 333, 444, 555, 777, 999};
double gda_unused_960[7];
double gda_unused_964[7];
double gda_unused_968[7];
double gda_unused_972[7];
double gda_unused_976[7];
double gda_unused_980[7];
double gda_unused_984[7];
int gia_988[10] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200, 0};
double gda_992[7][16][50];
double gda_996[7][16][50];
double gda_1000[7][16][50];
int gia_1004[7][16][50];
double gda_1008[7][16][50];
double gda_1012[7][16][50];
double gda_1016[7];
double gda_1020[7];
double gda_1024[7][16];
double gda_1028[7][16];
int gia_1032[7];
int gia_1036[7];
int gia_1040[7];
int gia_1044[7];
int gia_1048[7];
int gia_1052[7];
int gia_1056[7];
int gia_1060[7];
int g_pos_1064;
int g_ticket_1068;
int g_order_total_1072;
int gi_1084;
int gia_1100[7];
int gia_1104[7];
int gia_unused_1108[7];
int gia_unused_1112[7];
int gia_1116[7];
int gia_1120[7];
int gia_1124[7];
int gia_1128[7];
int gia_1132[7];
int gia_1136[7];
int gia_1140[7];
int gia_1144[7];
int gia_1148[7];
int gia_1152[7];
int gia_unused_1156[7];
int gia_unused_1160[7];
int gia_unused_1164[7];
int gia_1168[7];
int gia_1172[7];
int gia_1176[7];
int gia_1180[7];
int gia_1184[7];
int gia_1188[7];
int gi_unused_1192;
int gi_unused_1196;
int gia_1200[7];
int gia_1204[7];
int gia_unused_1212[7];
double gda_1216[7];
double gda_1220[7];
double gda_1224[7];
double gda_1228[7];
int gi_unused_1232;
int gi_unused_1236;
bool gi_1240;
bool gi_1244;
double g_price_1264;
double g_price_1272;
double g_price_1280;
double g_price_1288;
double gda_1296[7];
double gda_1300[7];
double gda_unused_1304[7];
double gda_unused_1308[7];
double gda_unused_1312[13][6][21];
double gda_unused_1316[13][6][21];
double gda_unused_1320[13][6][21];
double gda_unused_1324[13][6][21];
double gda_unused_1328[13][6][21];
double gda_unused_1332[13][6][21];
double gda_unused_1336[13][6][21];
double gda_unused_1340[13][6][21];
double gda_unused_1344[13][6][21];
double gda_1348[13][6][21];
double gda_unused_1352[13][6][21];
double gda_unused_1356[13][6][21];
double gda_unused_1360[13][6][21];
double gda_unused_1364[13][6][21];
double gda_unused_1368[13][6][21];
double gda_unused_1372[13][6][21];
double gda_unused_1376[13][6][21];
double gda_unused_1380[13][6][21];
int gia_unused_1384[7];
int gia_unused_1388[7];
double gd_1392;
int g_time_1400 = 0;
int g_time_1404 = 0;
double g_bid_1408;
double g_order_lots_1416;
double gd_1488;
string gs_dummy_1496;
string gs_dummy_1504;
string gs_dummy_1512;
string gs_dummy_1520;
string gs_dummy_1528;
double g_tickvalue_1544;
double gda_1552[90];
double gda_1556[90];
double gda_1560[90];
double gd_1564;
double gd_1572;
double gd_1580;
int gi_unused_1588 = 0;

int init() {
   gi_856 = 1;
   if (Digits == 5 || Digits == 3) gi_856 = 10;
   for (gi_1084 = 1; gi_1084 < 8; gi_1084++) {
      gia_1100[gi_1084] = 0;
      gia_1104[gi_1084] = 0;
      gia_1116[gi_1084] = 0;
      gia_1120[gi_1084] = 0;
      gia_1124[gi_1084] = 0;
      gia_1128[gi_1084] = 0;
      gia_1132[gi_1084] = 0;
      gia_1136[gi_1084] = 0;
   }
   for (gi_1084 = 0; gi_1084 <= 7; gi_1084++) {
      gia_956[gi_1084] = Magic + gi_1084;
      f0_7();
   }
   gia_752[0] = 20 * gi_856;
   gia_752[1] = St_2 * gi_856;
   gia_752[2] = St_3 * gi_856;
   gia_752[3] = St_4 * gi_856;
   gia_752[4] = St_5 * gi_856;
   gia_752[5] = St_6 * gi_856;
   gia_752[6] = St_7 * gi_856;
   gia_752[7] = St_8 * gi_856;
   gia_752[8] = St_9 * gi_856;
   gia_752[9] = St_10 * gi_856;
   gia_752[10] = St_11 * gi_856;
   gia_752[11] = St_12 * gi_856;
   gia_752[12] = St_13 * gi_856;
   gia_752[13] = St_14 * gi_856;
   gia_752[14] = St_15 * gi_856;
   gia_752[15] = St_16 * gi_856;
   Print("Expert_start");
   if (gi_252 == 0) gi_300 = 0;
   if (gi_252 == 1) gi_300 = 16;
   if (gi_252 == 2) gi_300 = 17;
   if (gi_252 == 3) gi_300 = 18;
   if (gi_252 == 4) gi_300 = 19;
   if (gi_252 == 5) gi_300 = 30;
   if (gi_252 == 6) gi_300 = 31;
   if (gi_252 < -5 && gi_252 > 6) {
      gi_300 = -1;
      gs_244 = " Error_Signal_Tipe ";
   }
   if (Mode_Close_Orders == 0) {
      gi_484 = TRUE;
      gi_488 = FALSE;
      gi_492 = FALSE;
      gi_496 = FALSE;
      gi_500 = FALSE;
      gi_504 = FALSE;
      gi_unused_508 = FALSE;
      gi_unused_512 = FALSE;
      gi_unused_516 = FALSE;
   }
   if (Mode_Close_Orders == 1) {
      gi_484 = FALSE;
      gi_488 = TRUE;
      gi_492 = FALSE;
      gi_496 = FALSE;
      gi_500 = FALSE;
      gi_504 = FALSE;
      gi_unused_508 = FALSE;
      gi_unused_512 = FALSE;
      gi_unused_516 = FALSE;
   }
   if (Mode_Close_Orders == 2) {
      gi_484 = FALSE;
      gi_488 = TRUE;
      gi_492 = TRUE;
      gi_496 = TRUE;
      gi_500 = FALSE;
      gi_504 = FALSE;
      gi_unused_508 = FALSE;
      gi_unused_512 = FALSE;
      gi_unused_516 = FALSE;
   }
   if (Mode_Close_Orders == 3) {
      gi_484 = FALSE;
      gi_488 = TRUE;
      gi_492 = TRUE;
      gi_496 = TRUE;
      gi_500 = FALSE;
      gi_504 = FALSE;
      gi_unused_508 = FALSE;
      gi_unused_512 = FALSE;
      gi_unused_516 = FALSE;
   }
   if (Mode_Close_Orders == 4) {
      gi_484 = FALSE;
      gi_488 = FALSE;
      gi_492 = FALSE;
      gi_496 = FALSE;
      gi_500 = FALSE;
      gi_504 = TRUE;
      gi_unused_508 = FALSE;
      gi_unused_512 = FALSE;
      gi_unused_516 = FALSE;
   }
   if (Mode_Close_Orders == 5) {
      gi_484 = FALSE;
      gi_488 = FALSE;
      gi_492 = FALSE;
      gi_496 = FALSE;
      gi_500 = FALSE;
      gi_504 = TRUE;
      gi_unused_508 = FALSE;
      gi_unused_512 = FALSE;
      gi_unused_516 = FALSE;
   }
   if (Mode_Close_Orders == 6) {
      gi_484 = FALSE;
      gi_488 = TRUE;
      gi_492 = TRUE;
      gi_496 = TRUE;
      gi_500 = TRUE;
      gi_504 = FALSE;
      gi_unused_508 = FALSE;
      gi_unused_512 = FALSE;
      gi_unused_516 = FALSE;
   }
   return (0);
}

void deinit() {
   Comment("Expert_stop");
}

int start() {
   int li_64;
   int li_68;
   int li_76;
   int li_80;
   int li_84;
   int li_88;
   bool li_92;
   bool li_96;
   bool li_100;
   bool li_104;
   double price_108;
   double price_116;
   double margininit_124;
   if (Exit_mode) gsa_88[gi_928] = "ТОРГОВЛЯ";
   else gsa_88[gi_928] = "ВЫХОД ИЗ РЫНКА";
   string ls_0 = Symbol();
   if (gd_1392 > AccountProfit()) gd_1392 = AccountProfit();
   gi_928 = 0;
   gsa_936[gi_928] = ls_0;
   gia_944[gi_928] = gi_304;
   gi_100 = 0;
   gd_772 = AccountBalance() * Min_Proc_Sv_Sr / 100.0;
   if (Min_Proc_Sv_Sr < 100.0 && Min_Proc_Sv_Sr > 0.0 && AccountFreeMargin() < gd_772) gi_100 = 1;
   /*if (AccountNumber() != g_acc_number_76 && (!IsDemo())) {
      Comment("Советник может работать на любом тестовом счете или на реальном счёте " + g_acc_number_76 + ", для подключения к другому реальному счёту пройдите на сайт forex-sovetnic.ru");
      Print("Советник может работать только на счёте " + g_acc_number_76 + ", для подключения к другому счёту проидите на сайт forex-sovetnic.ru");
      return;
   }*/
   if (LogotipOn) {
      f0_12();
      f0_9();
   }
   gia_956[gi_928] = Magic + gi_928;
   int stoplevel_8 = MarketInfo(gsa_936[gi_928], MODE_STOPLEVEL);
   int li_unused_12 = MarketInfo(gsa_936[gi_928], MODE_SPREAD);
   double point_16 = MarketInfo(gsa_936[gi_928], MODE_POINT);
   int li_unused_24 = MarketInfo(gsa_936[gi_928], MODE_DIGITS);
   if (MaxL == 0.0) MaxL = MarketInfo(gsa_936[gi_928], MODE_MAXLOT);
   if (g_minlot_144 < MarketInfo(gsa_936[gi_928], MODE_MINLOT)) g_minlot_144 = MarketInfo(gsa_936[gi_928], MODE_MINLOT);
   double lotstep_28 = MarketInfo(gsa_936[gi_928], MODE_LOTSTEP);
   double ld_36 = AccountBalance();
   int digits_44 = MarketInfo(gsa_936[gi_928], MODE_DIGITS);
   double ld_48 = NormalizeDouble(MarketInfo(gsa_936[gi_928], MODE_BID), digits_44);
   double ld_56 = NormalizeDouble(MarketInfo(gsa_936[gi_928], MODE_ASK), digits_44);
   if (g_minlot_144 == 0.01) li_64 = 2;
   if (g_minlot_144 == 0.1) li_64 = 1;
   if (g_minlot_144 >= 1.0) li_64 = 0;
   if (lotstep_28 == 0.01) li_68 = 2;
   if (lotstep_28 == 0.1) li_68 = 1;
   if (lotstep_28 >= 1.0) li_68 = 0;
   gd_564 = ld_36;
   if (Percent_SL > 0.0 && Percent_SL < 100.0 && Mode_SL_inst > 0) gd_564 = ld_36 * Percent_SL / 100.0;
   if (gd_1488 != 0.0 && gd_1488 - ld_36 * (Percent_SL - 2.0) / 100.0 > ld_36 && Mode_SL_inst == 2) Exit_mode = FALSE;
   if (gd_1488 != ld_36) gd_1488 = ld_36;
   if (TrallingStop * gi_856 < stoplevel_8) gia_876[gi_928] = stoplevel_8 + gi_856 * 2;
   else gia_876[gi_928] = TrallingStop * gi_856;
   if (TrallingStop * gi_856 < stoplevel_8) gia_880[gi_928] = stoplevel_8 + gi_856 * 2;
   else gia_880[gi_928] = TrallingStop * gi_856;
   gda_860[gi_928] = TakeProfit * gi_856;
   gda_864[gi_928] = TakeProfit * gi_856;
   gda_868[gi_928] = gi_228 * gi_856;
   gda_872[gi_928] = gi_228 * gi_856;
   gda_888[gi_928] = gi_212 * gi_856;
   gda_896[gi_928] = gi_212 * gi_856;
   gda_1224[gi_928] = ProtectionTP * gi_856;
   gda_1228[gi_928] = ProtectionTP * gi_856;
   gda_1296[gi_928] = gi_756 * gi_856;
   gda_1300[gi_928] = gi_756 * gi_856;
   g_slippage_852 *= gi_856;
   gi_372 *= gi_856;
   gi_356 *= gi_856;
   r_cen_enable_OTBOY *= gi_856;
   gi_192 *= gi_856;
   gs_92 = "    ";
   g_color_680 = g_color_664;
   if (Exit_mode && gi_100 == 1) {
      gs_92 = " !!!  Опасный ур. своб. средств";
      if (gda_1024[gi_928][0] == gda_1024[gi_928][1]) {
         gsa_88[gi_928] = "Торговля OU_B+S";
         gi_100 = 0;
         g_color_680 = Red;
      }
      if (gda_1024[gi_928][0] < gda_1024[gi_928][1]) {
         gsa_88[gi_928] = "Торговля BUY";
         gi_100 = 2;
         g_color_680 = Red;
      }
      if (gda_1024[gi_928][0] > gda_1024[gi_928][1]) {
         gsa_88[gi_928] = "Торговля SELL";
         gi_100 = 3;
         g_color_680 = Red;
      }
   }
   gi_212 = Step;
   gi_224 = Mode_Step;
   gi_220 = StepUv_Step;
   gi_192 = gi_188 - ProtectionTP;
   if (LotConst_or_not) {
      gda_1216[gi_928] = Lot;
      gda_1220[gi_928] = Lot;
   }
   if (!LotConst_or_not) {
      gda_1216[gi_928] = NormalizeDouble(ld_36 * RiskPercent / 1000000.0, li_64);
      gda_1220[gi_928] = NormalizeDouble(ld_36 * RiskPercent / 1000000.0, li_64);
   }
   if (gda_1216[gi_928] == 0.0) gda_1216[gi_928] = g_minlot_144;
   if (gda_1220[gi_928] == 0.0) gda_1220[gi_928] = g_minlot_144;
   int li_72 = 0;
   if (gsa_936[gi_928] == ls_0 && LineOnGraph && gs_444 == " + MA ") ObjectDelete("MA_trend");
   gs_444 = " + MA ";
   if (Off_MA_H4) gs_444 = " ";
   if (gs_444 == " + MA ") {
      g_price_452 = f0_3(0, Period_MA, MODE_SMA, PRICE_CLOSE, gia_988[TF_for_MA]);
      if (gsa_936[gi_928] == ls_0 && LineOnGraph) {
         ObjectCreate("MA_trend", OBJ_HLINE, 0, Time[0], g_price_452);
         ObjectSet("MA_trend", OBJPROP_PRICE1, g_price_452);
         ObjectSet("MA_trend", OBJPROP_COLOR, Gray);
         ObjectSet("MA_trend", OBJPROP_STYLE, STYLE_DASH);
      }
   }
   if (g_price_452 > ld_48 && Mode_MA < 2) li_72 = 1;
   if (g_price_452 <= ld_48 && Mode_MA < 2) li_72 = 2;
   if (g_price_452 < ld_48 && Mode_MA > 1) li_72 = 1;
   if (g_price_452 >= ld_48 && Mode_MA > 1) li_72 = 2;
   if (gi_300 > 5 && gi_300 < 15) {
      g_price_380 = 10000;
      g_price_388 = 0;
      for (gi_1084 = gi_352 + 1; gi_1084 <= gi_348 + gi_352; gi_1084++) {
         if (gi_344 == 0) {
            if (iHigh(gsa_936[gi_928], 0, gi_1084) >= g_price_388) g_price_388 = iHigh(gsa_936[gi_928], 0, gi_1084);
            if (iLow(gsa_936[gi_928], 0, gi_1084) <= g_price_380) g_price_380 = iLow(gsa_936[gi_928], 0, gi_1084);
         }
         if (gi_344 == 1) {
            if (iOpen(gsa_936[gi_928], 0, gi_1084) > iClose(gsa_936[gi_928], 0, gi_1084)) {
               if (iOpen(gsa_936[gi_928], 0, gi_1084) >= g_price_388) g_price_388 = iOpen(gsa_936[gi_928], 0, gi_1084);
               if (iClose(gsa_936[gi_928], 0, gi_1084) <= g_price_380) g_price_380 = iClose(gsa_936[gi_928], 0, gi_1084);
            }
            if (iOpen(gsa_936[gi_928], 0, gi_1084) < iClose(gsa_936[gi_928], 0, gi_1084)) {
               if (iClose(gsa_936[gi_928], 0, gi_1084) >= g_price_388) g_price_388 = iClose(gsa_936[gi_928], 0, gi_1084);
               if (iOpen(gsa_936[gi_928], 0, gi_1084) <= g_price_380) g_price_380 = iOpen(gsa_936[gi_928], 0, gi_1084);
            }
            if (iOpen(gsa_936[gi_928], 0, gi_1084) == iClose(gsa_936[gi_928], 0, gi_1084)) {
               if (iClose(gsa_936[gi_928], 0, gi_1084) >= g_price_388) g_price_388 = iClose(gsa_936[gi_928], 0, gi_1084);
               if (iClose(gsa_936[gi_928], 0, gi_1084) <= g_price_380) g_price_380 = iClose(gsa_936[gi_928], 0, gi_1084);
            }
         }
      }
      if (gi_300 == 10 || gi_300 == 11 || gi_300 == 12) {
         g_price_396 = g_price_388 + gi_372 * point_16;
         g_price_420 = g_price_388 - gi_372 * point_16;
         g_price_404 = g_price_380 - gi_372 * point_16;
         g_price_412 = g_price_380 + gi_372 * point_16;
      }
      if (gsa_936[gi_928] == ls_0 && LineOnGraph) {
         ObjectCreate(gsa_920[3][0], OBJ_HLINE, 0, Time[0], g_price_388);
         ObjectSet(gsa_920[3][0], OBJPROP_PRICE1, g_price_388);
         ObjectSet(gsa_920[3][0], OBJPROP_COLOR, gia_916[3][0]);
         ObjectSet(gsa_920[3][0], OBJPROP_STYLE, 7);
         ObjectCreate(gsa_920[3][1], OBJ_HLINE, 0, Time[0], g_price_380);
         ObjectSet(gsa_920[3][1], OBJPROP_PRICE1, g_price_380);
         ObjectSet(gsa_920[3][1], OBJPROP_COLOR, gia_916[3][1]);
         ObjectSet(gsa_920[3][1], OBJPROP_STYLE, 7);
         ObjectCreate(gsa_920[4][0], OBJ_HLINE, 0, Time[0], g_price_396);
         ObjectSet(gsa_920[4][0], OBJPROP_PRICE1, g_price_396);
         ObjectSet(gsa_920[4][0], OBJPROP_COLOR, gia_916[4][0]);
         ObjectSet(gsa_920[4][0], OBJPROP_STYLE, STYLE_DASH);
         ObjectCreate(gsa_920[4][1], OBJ_HLINE, 0, Time[0], g_price_404);
         ObjectSet(gsa_920[4][1], OBJPROP_PRICE1, g_price_404);
         ObjectSet(gsa_920[4][1], OBJPROP_COLOR, gia_916[4][1]);
         ObjectSet(gsa_920[4][1], OBJPROP_STYLE, STYLE_DASH);
         if (g_price_388 - g_price_380 > gi_356 * point_16) {
            ObjectCreate(gsa_920[5][0], OBJ_HLINE, 0, Time[0], g_price_412);
            ObjectSet(gsa_920[5][0], OBJPROP_PRICE1, g_price_412);
            ObjectSet(gsa_920[5][0], OBJPROP_COLOR, gia_916[5][0]);
            ObjectSet(gsa_920[5][0], OBJPROP_STYLE, STYLE_DASH);
            ObjectCreate(gsa_920[5][1], OBJ_HLINE, 0, Time[0], g_price_420);
            ObjectSet(gsa_920[5][1], OBJPROP_PRICE1, g_price_420);
            ObjectSet(gsa_920[5][1], OBJPROP_COLOR, gia_916[5][1]);
            ObjectSet(gsa_920[5][1], OBJPROP_STYLE, STYLE_DASH);
         } else {
            ObjectDelete(gsa_920[5][0]);
            ObjectDelete(gsa_920[5][1]);
         }
      }
   }
   if (gia_1032[gi_928] > 0) {
      li_76 = f0_0(0, gia_1032[gi_928]);
      li_80 = f0_14(0, gia_1032[gi_928]);
   }
   if (gia_1036[gi_928] > 0) {
      li_84 = f0_0(1, gia_1036[gi_928]);
      li_88 = f0_14(1, gia_1036[gi_928]);
   }
   if (gia_1032[gi_928] > 1) {
      li_92 = f0_2(0, gia_1032[gi_928], ld_56);
      li_96 = f0_4(0, gia_1032[gi_928], ld_56);
   } else {
      li_92 = FALSE;
      li_96 = FALSE;
   }
   if (gia_1036[gi_928] > 1) {
      li_100 = f0_2(1, gia_1036[gi_928], ld_48);
      li_104 = f0_4(1, gia_1036[gi_928], ld_48);
   } else {
      li_100 = FALSE;
      li_104 = FALSE;
   }
   gda_884[gi_928] = gda_888[gi_928] * point_16;
   gda_892[gi_928] = gda_896[gi_928] * point_16;
   if (gi_224 == 0) {
      gda_884[gi_928] = gda_888[gi_928] * point_16;
      gda_892[gi_928] = gda_896[gi_928] * point_16;
   }
   if (gi_224 == 1) {
      if (gia_1032[gi_928] < 2) gda_884[gi_928] = gda_888[gi_928] * point_16;
      if (gia_1036[gi_928] < 2) gda_892[gi_928] = gda_896[gi_928] * point_16;
      if (gia_1032[gi_928] > 1) gda_884[gi_928] = (gda_888[gi_928] + gi_220 * gia_1032[gi_928] * gi_856) * point_16;
      if (gia_1036[gi_928] > 1) gda_892[gi_928] = (gda_896[gi_928] + gi_220 * gia_1036[gi_928] * gi_856) * point_16;
   }
   if (gi_224 == 2) {
      if (gia_1032[gi_928] < 2) gda_884[gi_928] = gda_888[gi_928] * point_16;
      if (gia_1036[gi_928] < 2) gda_892[gi_928] = gda_896[gi_928] * point_16;
      if (gia_1032[gi_928] > 1) gda_884[gi_928] = (gda_888[gi_928] - gi_220 * gia_1032[gi_928] * gi_856) * point_16;
      if (gia_1036[gi_928] > 1) gda_892[gi_928] = (gda_896[gi_928] - gi_220 * gia_1036[gi_928] * gi_856) * point_16;
   }
   if (gi_224 == 3) {
      if (gia_1032[gi_928] < 1) gda_884[gi_928] = gda_888[gi_928] * point_16;
      if (gia_1036[gi_928] < 1) gda_892[gi_928] = gda_896[gi_928] * point_16;
      if (gia_1032[gi_928] > 0) gda_884[gi_928] = gia_752[gia_1032[gi_928]] * point_16;
      if (gia_1036[gi_928] > 0) gda_892[gi_928] = gia_752[gia_1036[gi_928]] * point_16;
      if (gia_1032[gi_928] > 15) gda_884[gi_928] = gia_752[15] * point_16;
      if (gia_1036[gi_928] > 15) gda_892[gi_928] = gia_752[15] * point_16;
   }
   if (gi_224 == 4) {
      if (gia_1032[gi_928] < 1) gda_884[gi_928] = gda_888[gi_928] * point_16;
      if (gia_1036[gi_928] < 1) gda_892[gi_928] = gda_896[gi_928] * point_16;
      if (gia_1032[gi_928] > 0) gda_884[gi_928] = gda_1024[0][gi_928] / gda_1216[gi_928] * gda_888[gi_928] * point_16;
      if (gia_1036[gi_928] > 0) gda_892[gi_928] = gda_1024[1][gi_928] / gda_1220[gi_928] * gda_896[gi_928] * point_16;
   }
   if (gi_224 == 5) {
      if (gia_1032[gi_928] < 1) gda_884[gi_928] = gda_888[gi_928] * point_16;
      if (gia_1036[gi_928] < 1) gda_892[gi_928] = gda_896[gi_928] * point_16;
      if (gia_1032[gi_928] > 0 && gia_1036[gi_928] > 0) {
         gda_884[gi_928] = gda_1024[gi_928][0] / gda_1024[gi_928][1] * gda_888[gi_928] * point_16;
         gda_892[gi_928] = gda_1024[gi_928][1] / gda_1024[gi_928][0] * gda_896[gi_928] * point_16;
      }
      if (gia_1032[gi_928] > 0 && gia_1036[gi_928] == 0) gda_884[gi_928] = gda_1024[gi_928][0] / gda_1216[gi_928] * gda_888[gi_928] * point_16;
      if (gia_1032[gi_928] == 0 && gia_1036[gi_928] > 0) gda_892[gi_928] = gda_1024[gi_928][1] / gda_1220[gi_928] * gda_896[gi_928] * point_16;
   }
   if (gda_884[gi_928] < 5 * gi_856 * point_16) gda_884[gi_928] = 5 * gi_856 * point_16;
   if (gda_892[gi_928] < 5 * gi_856 * point_16) gda_892[gi_928] = 5 * gi_856 * point_16;
   gia_1140[gi_928] = 0;
   gia_1148[gi_928] = 0;
   gia_1144[gi_928] = 0;
   gia_1152[gi_928] = 0;
   if (gsa_936[gi_928] == ls_0 && LineOnGraph) {
      ObjectCreate(gsa_920[gi_928][0], OBJ_HLINE, 0, Time[0], gda_996[gi_928][0][li_80] - gda_884[gi_928]);
      ObjectSet(gsa_920[gi_928][0], OBJPROP_PRICE1, gda_996[gi_928][0][li_80] - gda_884[gi_928]);
      ObjectSet(gsa_920[gi_928][0], OBJPROP_COLOR, gia_916[gi_928][0]);
      ObjectSet(gsa_920[gi_928][0], OBJPROP_STYLE, 7);
      ObjectCreate(gsa_920[gi_928][1], OBJ_HLINE, 0, Time[0], gda_996[gi_928][1][li_84] + gda_892[gi_928]);
      ObjectSet(gsa_920[gi_928][1], OBJPROP_PRICE1, gda_996[gi_928][1][li_84] + gda_892[gi_928]);
      ObjectSet(gsa_920[gi_928][1], OBJPROP_COLOR, gia_916[gi_928][1]);
      ObjectSet(gsa_920[gi_928][1], OBJPROP_STYLE, 7);
   }
   if (gia_1032[gi_928] == 0 && Exit_mode) gia_1140[gi_928] = 1;
   if (gia_1036[gi_928] == 0 && Exit_mode) gia_1144[gi_928] = 1;
   if (gi_228 == 0) {
      if (gia_1032[gi_928] > 0 && ld_56 < gda_996[gi_928][0][li_80] - gda_884[gi_928]) gia_1140[gi_928] = 1;
      if (gia_1032[gi_928] > 0 && ld_56 > gda_996[gi_928][0][li_76] + gda_884[gi_928] && gi_232 > 0 || Mode_Close_Orders == 5) gia_1140[gi_928] = 1;
      if (gia_1036[gi_928] > 0 && ld_48 > gda_996[gi_928][1][li_84] + gda_892[gi_928]) gia_1144[gi_928] = 1;
      if (gia_1036[gi_928] > 0 && ld_48 < gda_996[gi_928][1][li_88] - gda_892[gi_928] && gi_232 > 0 || Mode_Close_Orders == 5) gia_1144[gi_928] = 1;
      if (gia_1032[gi_928] > 0 && gia_1032[gi_928] > gia_1036[gi_928] && ld_56 < gda_996[gi_928][0][li_80] - gda_884[gi_928]) gia_1140[gi_928] = 1;
      if (gia_1032[gi_928] > 0 && gia_1032[gi_928] > gia_1036[gi_928] && ld_56 > gda_996[gi_928][0][li_76] + gda_884[gi_928] && gi_232 > 0 || Mode_Close_Orders == 5) gia_1140[gi_928] = 1;
      if (gia_1036[gi_928] > 0 && gia_1036[gi_928] > gia_1032[gi_928] && ld_48 > gda_996[gi_928][1][li_84] + gda_892[gi_928]) gia_1144[gi_928] = 1;
      if (gia_1036[gi_928] > 0 && gia_1036[gi_928] > gia_1032[gi_928] && ld_48 < gda_996[gi_928][1][li_88] - gda_892[gi_928] && gi_232 > 0 || Mode_Close_Orders == 5) gia_1144[gi_928] = 1;
   }
   if (gia_1032[gi_928] > 0 && ld_56 > gda_996[gi_928][0][li_76] + gda_884[gi_928] && gda_1012[gi_928][0][li_76] > 0.0 && gi_232 > 0) gia_1140[gi_928] = 1;
   if (gia_1036[gi_928] > 0 && ld_48 < gda_996[gi_928][1][li_88] - gda_892[gi_928] && gda_1012[gi_928][1][li_88] > 0.0 && gi_232 > 0) gia_1144[gi_928] = 1;
   if (gi_300 > 5 && gi_300 < 10 && gi_232 == 2) {
      gia_1140[gi_928] = 1;
      gia_1144[gi_928] = 1;
   }
   if (gi_228 > 0 && gia_1032[gi_928] > 0) gia_1140[gi_928] = 0;
   if (gi_228 > 0 && gia_1036[gi_928] > 0) gia_1144[gi_928] = 0;
   gia_1168[gi_928] = 0;
   gia_1172[gi_928] = 0;
   if (gi_300 == 0) {
      gs_244 = " анализ Close ";
      if (gia_1032[gi_928] == 0 && g_time_1400 != Time[0] && iClose(gsa_936[gi_928], 0, 2) > iClose(gsa_936[gi_928], 0, 1) && ld_48 > iClose(gsa_936[gi_928], 0, 1)) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (gia_1036[gi_928] == 0 && g_time_1404 != Time[0] && iClose(gsa_936[gi_928], 0, 2) < iClose(gsa_936[gi_928], 0, 1) && ld_48 < iClose(gsa_936[gi_928], 0, 1)) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
      if (gia_1032[gi_928] > 0 && g_time_1400 != Time[0] && ld_48 > iClose(gsa_936[gi_928], 0, 1)) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (gia_1036[gi_928] > 0 && g_time_1404 != Time[0] && ld_48 < iClose(gsa_936[gi_928], 0, 1)) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 == 16) {
      gs_244 = " инверсн.анализ Close ";
      if (gia_1032[gi_928] == 0 && g_time_1400 != Time[0] && iClose(gsa_936[gi_928], 0, 2) < iClose(gsa_936[gi_928], 0, 1) && ld_48 < iClose(gsa_936[gi_928], 0, 1)) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (gia_1036[gi_928] == 0 && g_time_1404 != Time[0] && iClose(gsa_936[gi_928], 0, 2) > iClose(gsa_936[gi_928], 0, 1) && ld_48 > iClose(gsa_936[gi_928], 0, 1)) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
      if (gia_1032[gi_928] > 0 && g_time_1400 != Time[0] && ld_48 < iClose(gsa_936[gi_928], 0, 1)) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (gia_1036[gi_928] > 0 && g_time_1404 != Time[0] && ld_48 > iClose(gsa_936[gi_928], 0, 1)) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 == 30) {
      gs_244 = " анализ Close ";
      if (g_time_1400 != Time[0] && iClose(gsa_936[gi_928], 0, 2) <= iClose(gsa_936[gi_928], 0, 1)) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (g_time_1404 != Time[0] && iClose(gsa_936[gi_928], 0, 2) > iClose(gsa_936[gi_928], 0, 1)) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 == 31) {
      gs_244 = " инверсн.анализ Close+ ";
      if (g_time_1400 != Time[0] && iClose(gsa_936[gi_928], 0, 2) > iClose(gsa_936[gi_928], 0, 1)) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (g_time_1404 != Time[0] && iClose(gsa_936[gi_928], 0, 2) <= iClose(gsa_936[gi_928], 0, 1)) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 == 17) {
      gs_244 = " анализ High/Low ";
      if (g_time_1400 != Time[0] && iLow(gsa_936[gi_928], 0, 3) > iLow(gsa_936[gi_928], 0, 2) && iLow(gsa_936[gi_928], 0, 2) < iLow(gsa_936[gi_928], 0, 1) && ld_48 > iClose(gsa_936[gi_928],
         0, 1)) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (g_time_1404 != Time[0] && iHigh(gsa_936[gi_928], 0, 3) < iHigh(gsa_936[gi_928], 0, 2) && iHigh(gsa_936[gi_928], 0, 2) > iHigh(gsa_936[gi_928], 0, 1) && ld_48 < iClose(gsa_936[gi_928],
         0, 1)) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 == 18) {
      gs_244 = " анализ High/Low + ";
      if (g_time_1400 != Time[0] && iLow(gsa_936[gi_928], 0, 4) > iLow(gsa_936[gi_928], 0, 3) && iLow(gsa_936[gi_928], 0, 3) > iLow(gsa_936[gi_928], 0, 2) && iLow(gsa_936[gi_928],
         0, 2) < iLow(gsa_936[gi_928], 0, 1) && ld_48 > iClose(gsa_936[gi_928], 0, 1)) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (g_time_1404 != Time[0] && iHigh(gsa_936[gi_928], 0, 4) < iHigh(gsa_936[gi_928], 0, 3) && iHigh(gsa_936[gi_928], 0, 3) < iHigh(gsa_936[gi_928], 0, 2) && iHigh(gsa_936[gi_928],
         0, 2) > iHigh(gsa_936[gi_928], 0, 1) && ld_48 < iClose(gsa_936[gi_928], 0, 1)) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 == 19) {
      gs_244 = " анализ посл. БАРов ";
      if (g_time_1400 != Time[0] && iLow(gsa_936[gi_928], 0, 4) > iLow(gsa_936[gi_928], 0, 3) && iLow(gsa_936[gi_928], 0, 3) > iLow(gsa_936[gi_928], 0, 2) && iLow(gsa_936[gi_928],
         0, 2) < iLow(gsa_936[gi_928], 0, 1) && ld_48 < iLow(gsa_936[gi_928], 0, 1)) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (g_time_1404 != Time[0] && iHigh(gsa_936[gi_928], 0, 4) < iHigh(gsa_936[gi_928], 0, 3) && iHigh(gsa_936[gi_928], 0, 3) < iHigh(gsa_936[gi_928], 0, 2) && iHigh(gsa_936[gi_928],
         0, 2) > iHigh(gsa_936[gi_928], 0, 1) && ld_48 > iHigh(gsa_936[gi_928], 0, 1)) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 > 20) {
      gd_1580 = 0.00001;
      gd_1572 = 10000;
      gd_1564 = 0;
      for (gi_1084 = 0; gi_1084 < gi_256; gi_1084++) {
         gda_1556[gi_1084] = iLow(gsa_936[gi_928], 0, gi_1084);
         gda_1560[gi_1084] = iHigh(gsa_936[gi_928], 0, gi_1084);
         gda_1552[gi_1084] = (gd_1572 + gd_1580) / 2.0;
         if (gd_1580 < gda_1560[gi_1084] && gi_1084 != 0) gd_1580 = gda_1560[gi_1084];
         if (gd_1572 > gda_1556[gi_1084] && gi_1084 != 0) gd_1572 = gda_1556[gi_1084];
      }
      gd_1564 = (gd_1572 + gd_1580) / 2.0;
      gd_284 = gi_280 * gi_856 * point_16;
      gd_264 = gi_260 * gi_856 * point_16;
   }
   if (gi_300 == 25) {
      gs_244 = " анализ 1-го БАРа ";
      if (g_time_1400 != Time[0] && gda_1560[0] - gda_1556[0] > gd_264 && gda_1552[0] < iOpen(gsa_936[gi_928], 0, 0) && ld_48 < gda_1552[0]) {
         if (gda_1556[0] + gd_284 < ld_48) {
            gia_1168[gi_928] = 1;
            gia_1176[gi_928] = 0;
            g_time_1400 = Time[0];
         }
      }
      if (g_time_1404 != Time[0] && gda_1560[0] - gda_1556[0] > gd_264 && gda_1552[0] > iOpen(gsa_936[gi_928], 0, 0) && ld_48 > gda_1552[0]) {
         if (gda_1560[0] - gd_284 > ld_48) {
            gia_1172[gi_928] = 1;
            gia_1180[gi_928] = 0;
            g_time_1404 = Time[0];
         }
      }
   }
   if (gi_300 == 26) {
      gs_244 = " анализ 1-го БАРа инв. ";
      if (g_time_1400 != Time[0] && gda_1560[0] - gda_1556[0] > gd_264 && gda_1552[0] > iOpen(gsa_936[gi_928], 0, 0) && ld_48 > gda_1552[0]) {
         if (gda_1560[0] - gd_284 > ld_48) {
            gia_1168[gi_928] = 1;
            gia_1176[gi_928] = 0;
            g_time_1400 = Time[0];
         }
      }
      if (g_time_1404 != Time[0] && gda_1560[0] - gda_1556[0] > gd_264 && gda_1552[0] < iOpen(gsa_936[gi_928], 0, 0) && ld_48 < gda_1552[0]) {
         if (gda_1556[0] + gd_284 < ld_48) {
            gia_1172[gi_928] = 1;
            gia_1180[gi_928] = 0;
            g_time_1404 = Time[0];
         }
      }
   }
   if (gi_300 == 27) {
      gs_244 = " анализ 1-го БАРа без CS";
      if (gda_1560[0] - gda_1556[0] > gd_264) {
         if (g_time_1400 != Time[0] && gda_1556[0] + gd_284 < ld_48 && ld_48 < gda_1552[0]) {
            gia_1168[gi_928] = 1;
            gia_1176[gi_928] = 0;
            g_time_1400 = Time[0];
         }
         if (g_time_1404 != Time[0] && gda_1560[0] - gd_284 > ld_48 && ld_48 > gda_1552[0]) {
            gia_1172[gi_928] = 1;
            gia_1180[gi_928] = 0;
            g_time_1404 = Time[0];
         }
      }
   }
   if (gi_300 == 28) {
      gs_244 = " анализ " + gi_256 + " БАР - пробой ";
      if (gd_1580 - gd_1572 < gd_264) {
         gia_1176[gi_928] = 1;
         gia_1180[gi_928] = 1;
         Print("***");
      }
      if (g_time_1400 != Time[0] && gia_1176[gi_928] == 1 && gd_1580 + gd_284 < ld_48 && ld_48 > gd_1564) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (g_time_1404 != Time[0] && gia_1180[gi_928] == 1 && gd_1572 - gd_284 > ld_48 && ld_48 < gd_1564) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 == 29) {
      gs_244 = " анализ " + gi_256 + " БАР - отскок";
      if (gd_1580 - gd_1572 > gd_264) {
         gia_1176[gi_928] = 1;
         gia_1180[gi_928] = 1;
      }
      if (gia_1176[gi_928] == 1 || gia_1180[gi_928] == 1) {
         if (g_time_1400 != Time[0] && gia_1176[gi_928] == 1 && gd_1572 + gd_284 < ld_48 && ld_48 < gd_1564) {
            gia_1168[gi_928] = 1;
            gia_1176[gi_928] = 0;
            gia_1180[gi_928] = 0;
            g_time_1400 = Time[0];
         }
         if (g_time_1404 != Time[0] && gia_1180[gi_928] == 1 && gd_1580 - gd_284 > ld_48 && ld_48 > gd_1564) {
            gia_1172[gi_928] = 1;
            gia_1176[gi_928] = 0;
            gia_1180[gi_928] = 0;
            g_time_1404 = Time[0];
         }
      }
   }
   if (gi_300 == -4) {
      gs_244 = " inv.Envelopes + Close ";
      if (g_time_1400 != Time[0] && iClose(gsa_936[gi_928], 0, 1) > gda_332[1] && ld_48 < gda_332[0]) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (g_time_1404 != Time[0] && iClose(gsa_936[gi_928], 0, 1) < gda_336[1] && ld_48 > gda_336[0]) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
      if (gi_340 && gia_1032[gi_928] + 1 < gia_1036[gi_928] && gia_1032[gi_928] < 4 && g_time_1400 != Time[0] && iClose(gsa_936[gi_928], 0, 1) > gda_336[1] && ld_48 < gda_336[0]) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (gi_340 && gia_1036[gi_928] + 1 < gia_1032[gi_928] && gia_1036[gi_928] < 4 && g_time_1404 != Time[0] && iClose(gsa_936[gi_928], 0, 1) < gda_332[1] && ld_48 > gda_332[0]) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 == -3) {
      gs_244 = " Envelopes + Close ";
      if (g_time_1400 != Time[0] && iClose(gsa_936[gi_928], 0, 1) < gda_336[1] && ld_48 > gda_336[0]) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (g_time_1404 != Time[0] && iClose(gsa_936[gi_928], 0, 1) > gda_332[1] && ld_48 < gda_332[0]) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
      if (gi_340 && gia_1032[gi_928] + 1 < gia_1036[gi_928] && gia_1032[gi_928] < 4 && g_time_1400 != Time[0] && iClose(gsa_936[gi_928], 0, 1) < gda_332[1] && ld_48 > gda_332[0]) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (gi_340 && gia_1036[gi_928] + 1 < gia_1032[gi_928] && gia_1036[gi_928] < 4 && g_time_1404 != Time[0] && iClose(gsa_936[gi_928], 0, 1) > gda_336[1] && ld_48 < gda_336[0]) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 == -2) {
      gs_244 = " inv.Envelopes ";
      if (g_time_1400 != Time[0] && ld_48 > gda_332[0]) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (g_time_1404 != Time[0] && ld_48 < gda_336[0]) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
      if (gi_340 && gia_1032[gi_928] + 1 < gia_1036[gi_928] && gia_1032[gi_928] < 4 && g_time_1400 != Time[0] && ld_48 < gda_332[0]) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (gi_340 && gia_1036[gi_928] + 1 < gia_1032[gi_928] && gia_1036[gi_928] < 4 && g_time_1404 != Time[0] && ld_48 > gda_336[0]) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 == -1) {
      gs_244 = " Envelopes ";
      if (g_time_1400 != Time[0] && ld_48 < gda_336[0]) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (g_time_1404 != Time[0] && ld_48 > gda_332[0]) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
      if (gi_340 && gia_1032[gi_928] + 1 < gia_1036[gi_928] && gia_1032[gi_928] < 4 && g_time_1400 != Time[0] && ld_48 > gda_336[0]) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (gi_340 && gia_1036[gi_928] + 1 < gia_1032[gi_928] && gia_1036[gi_928] < 4 && g_time_1404 != Time[0] && ld_48 < gda_332[0]) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 == 1) {
      if (iClose(gsa_936[gi_928], 0, 2) < iClose(gsa_936[gi_928], 0, 1)) {
         gia_1176[gi_928] = 1;
         gia_1180[gi_928] = 0;
      }
      if (iClose(gsa_936[gi_928], 0, 2) > iClose(gsa_936[gi_928], 0, 1)) {
         gia_1180[gi_928] = 1;
         gia_1176[gi_928] = 0;
      }
      if (gia_1176[gi_928] == 1 && g_time_1400 != Time[0] && ld_48 > iClose(gsa_936[gi_928], 0, 1)) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (gia_1180[gi_928] == 1 && g_time_1404 != Time[0] && ld_48 < iClose(gsa_936[gi_928], 0, 1)) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 == 2) {
      if (iClose(gsa_936[gi_928], 0, 2) > iClose(gsa_936[gi_928], 0, 1)) {
         gia_1176[gi_928] = 1;
         gia_1180[gi_928] = 0;
      }
      if (iClose(gsa_936[gi_928], 0, 2) < iClose(gsa_936[gi_928], 0, 1)) {
         gia_1180[gi_928] = 1;
         gia_1176[gi_928] = 0;
      }
      if (gia_1176[gi_928] == 1 && g_time_1400 != Time[0] && ld_48 > iOpen(gsa_936[gi_928], 0, 1)) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (gia_1180[gi_928] == 1 && g_time_1404 != Time[0] && ld_48 < iOpen(gsa_936[gi_928], 0, 1)) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 == 3) {
      if (iClose(gsa_936[gi_928], 0, 2) > iClose(gsa_936[gi_928], 0, 1) && gda_1348[gi_928][gia_944[gi_928]][0] < -100.0) {
         gia_1176[gi_928] = 1;
         gia_1180[gi_928] = 0;
      }
      if (iClose(gsa_936[gi_928], 0, 2) < iClose(gsa_936[gi_928], 0, 1) && gda_1348[gi_928][gia_944[gi_928]][0] > 100.0) {
         gia_1180[gi_928] = 1;
         gia_1176[gi_928] = 0;
      }
      if (gia_1176[gi_928] == 1 && g_time_1400 != Time[0] && ld_48 > iOpen(gsa_936[gi_928], 0, 1)) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (gia_1180[gi_928] == 1 && g_time_1404 != Time[0] && ld_48 < iOpen(gsa_936[gi_928], 0, 1)) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 == 4) {
      if (iClose(gsa_936[gi_928], 0, 2) > iClose(gsa_936[gi_928], 0, 1) && gda_1348[gi_928][gia_944[gi_928]][0] > -50.0 || gda_1348[gi_928][gia_944[gi_928]][0] < -200.0) {
         gia_1176[gi_928] = 1;
         gia_1180[gi_928] = 0;
      }
      if (iClose(gsa_936[gi_928], 0, 2) < iClose(gsa_936[gi_928], 0, 1) && gda_1348[gi_928][gia_944[gi_928]][0] < 50.0 || gda_1348[gi_928][gia_944[gi_928]][0] > 200.0) {
         gia_1180[gi_928] = 1;
         gia_1176[gi_928] = 0;
      }
      if (gia_1176[gi_928] == 1 && g_time_1400 != Time[0] && ld_48 > iOpen(gsa_936[gi_928], 0, 1)) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (gia_1180[gi_928] == 1 && g_time_1404 != Time[0] && ld_48 < iOpen(gsa_936[gi_928], 0, 1)) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 == 5) {
      if ((gda_1348[gi_928][gia_944[gi_928]][0] < (-gi_308) && gi_308 > 0) || (gda_1348[gi_928][gia_944[gi_928]][0] > (-gi_308) && gi_308 <= 0)) {
         gia_1176[gi_928] = 1;
         gia_1180[gi_928] = 0;
      }
      if ((gda_1348[gi_928][gia_944[gi_928]][0] > gi_308 && gi_308 > 0) || (gda_1348[gi_928][gia_944[gi_928]][0] < gi_308 && gi_308 <= 0)) {
         gia_1180[gi_928] = 1;
         gia_1176[gi_928] = 0;
      }
      if (gia_1176[gi_928] == 1 && g_time_1400 != Time[0] && ld_48 > iOpen(gsa_936[gi_928], 0, 1)) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (gia_1180[gi_928] == 1 && g_time_1404 != Time[0] && ld_48 < iOpen(gsa_936[gi_928], 0, 1)) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 == 6) {
      if ((gda_1348[gi_928][gia_944[gi_928]][0] < (-gi_308) && gi_308 > 0) || (gda_1348[gi_928][gia_944[gi_928]][0] > (-gi_308) && gi_308 <= 0)) {
         gia_1176[gi_928] = 1;
         gia_1180[gi_928] = 0;
      }
      if ((gda_1348[gi_928][gia_944[gi_928]][0] > gi_308 && gi_308 > 0) || (gda_1348[gi_928][gia_944[gi_928]][0] < gi_308 && gi_308 <= 0)) {
         gia_1180[gi_928] = 1;
         gia_1176[gi_928] = 0;
      }
      if (gia_1176[gi_928] == 1 && g_time_1400 != Time[0] && iOpen(gsa_936[gi_928], 0, 0) > g_price_380 && ld_48 < g_price_380) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (gia_1180[gi_928] == 1 && g_time_1404 != Time[0] && iOpen(gsa_936[gi_928], 0, 0) < g_price_388 && ld_48 > g_price_388) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 == 7) {
      if ((gda_1348[gi_928][gia_944[gi_928]][0] < (-gi_308) && gi_308 > 0) || (gda_1348[gi_928][gia_944[gi_928]][0] > (-gi_308) && gi_308 <= 0)) {
         gia_1176[gi_928] = 1;
         gia_1180[gi_928] = 0;
      }
      if ((gda_1348[gi_928][gia_944[gi_928]][0] > gi_308 && gi_308 > 0) || (gda_1348[gi_928][gia_944[gi_928]][0] < gi_308 && gi_308 <= 0)) {
         gia_1180[gi_928] = 1;
         gia_1176[gi_928] = 0;
      }
      if (gia_1176[gi_928] == 1 && g_time_1400 != Time[0] && iOpen(gsa_936[gi_928], 0, 0) < g_price_388 && ld_48 > g_price_388) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (gia_1180[gi_928] == 1 && g_time_1404 != Time[0] && iOpen(gsa_936[gi_928], 0, 0) > g_price_380 && ld_48 < g_price_380) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 == 8) {
      gs_244 = " отскок от уровня ";
      gia_1176[gi_928] = 1;
      gia_1180[gi_928] = 1;
      if (gia_1176[gi_928] == 1 && g_time_1400 != Time[0] && iOpen(gsa_936[gi_928], 0, 0) > g_price_380 && ld_48 < g_price_380) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (gia_1180[gi_928] == 1 && g_time_1404 != Time[0] && iOpen(gsa_936[gi_928], 0, 0) < g_price_388 && ld_48 > g_price_388) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 == 9) {
      gs_244 = " пробой уровня ";
      gia_1176[gi_928] = 1;
      gia_1180[gi_928] = 1;
      if (gia_1176[gi_928] == 1 && g_time_1400 != Time[0] && iOpen(gsa_936[gi_928], 0, 0) < g_price_388 && ld_48 > g_price_388) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (gia_1180[gi_928] == 1 && g_time_1404 != Time[0] && iOpen(gsa_936[gi_928], 0, 0) > g_price_380 && ld_48 < g_price_380) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 == 10) {
      if (g_price_388 - g_price_380 > gi_356 * point_16) {
         gia_1176[gi_928] = 1;
         gia_1180[gi_928] = 1;
      }
      if ((g_time_1400 != Time[0] && gia_1176[gi_928] == 1 && gi_376 == 1 && iOpen(gsa_936[gi_928], 0, 0) > g_price_412 && ld_48 < g_price_412) || (g_time_1400 != Time[0] &&
         gia_1176[gi_928] == 1 && gi_376 == 2 && iOpen(gsa_936[gi_928], 0, 0) < g_price_412 && ld_48 > g_price_412) || (g_time_1400 != Time[0] && gia_1176[gi_928] == 1 && gi_376 == 0 && iOpen(gsa_936[gi_928],
         0, 0) < g_price_396 && ld_48 > g_price_396)) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if ((g_time_1404 != Time[0] && gia_1180[gi_928] == 1 && gi_376 == 1 && iOpen(gsa_936[gi_928], 0, 0) < g_price_420 && ld_48 > g_price_420) || (g_time_1404 != Time[0] &&
         gia_1180[gi_928] == 1 && gi_376 == 2 && iOpen(gsa_936[gi_928], 0, 0) > g_price_420 && ld_48 < g_price_420) || (g_time_1404 != Time[0] && gia_1180[gi_928] == 1 && gi_376 == 0 && iOpen(gsa_936[gi_928],
         0, 0) > g_price_404 && ld_48 < g_price_404)) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 == 11) {
      if (g_price_388 - g_price_380 > gi_356 * point_16) {
         gia_1176[gi_928] = 1;
         gia_1180[gi_928] = 1;
      }
      if ((g_time_1400 != Time[0] && gia_1176[gi_928] == 1 && gi_376 == 1 && iOpen(gsa_936[gi_928], 0, 0) > g_price_412 && ld_48 < g_price_412 && (gda_1348[gi_928][gia_944[gi_928]][0] < (-gi_308) &&
         gi_308 > 0) || (gda_1348[gi_928][gia_944[gi_928]][0] > (-gi_308) && gi_308 <= 0)) || (g_time_1400 != Time[0] && gia_1176[gi_928] == 1 && gi_376 == 2 && iOpen(gsa_936[gi_928],
         0, 0) < g_price_412 && ld_48 > g_price_412 && (gda_1348[gi_928][gia_944[gi_928]][0] < (-gi_308) && gi_308 > 0) || (gda_1348[gi_928][gia_944[gi_928]][0] > (-gi_308) && gi_308 <= 0)) ||
         (g_time_1400 != Time[0] && iOpen(gsa_936[gi_928], 0, 0) < g_price_396 && ld_48 > g_price_396 && (gda_1348[gi_928][gia_944[gi_928]][0] < (-gi_308) && gi_308 > 0) ||
         (gda_1348[gi_928][gia_944[gi_928]][0] > (-gi_308) && gi_308 <= 0))) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if ((g_time_1404 != Time[0] && gia_1180[gi_928] == 1 && gi_376 == 1 && iOpen(gsa_936[gi_928], 0, 0) < g_price_420 && ld_48 > g_price_420 && (gda_1348[gi_928][gia_944[gi_928]][0] > gi_308 &&
         gi_308 > 0) || (gda_1348[gi_928][gia_944[gi_928]][0] < gi_308 && gi_308 <= 0)) || (g_time_1404 != Time[0] && gia_1180[gi_928] == 1 && gi_376 == 2 && iOpen(gsa_936[gi_928],
         0, 0) > g_price_420 && ld_48 < g_price_420 && (gda_1348[gi_928][gia_944[gi_928]][0] > gi_308 && gi_308 > 0) || (gda_1348[gi_928][gia_944[gi_928]][0] < gi_308 && gi_308 <= 0)) ||
         (g_time_1404 != Time[0] && iOpen(gsa_936[gi_928], 0, 0) > g_price_404 && ld_48 < g_price_404 && (gda_1348[gi_928][gia_944[gi_928]][0] > gi_308 && gi_308 > 0) || (gda_1348[gi_928][gia_944[gi_928]][0] < gi_308 &&
         gi_308 <= 0))) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 == 12) {
      if (g_price_388 - g_price_380 <= gi_360 * point_16) {
         gia_1176[gi_928] = 1;
         gia_1180[gi_928] = 1;
         gi_376 = 0;
      }
      if (g_price_388 - g_price_380 < gi_360 * point_16 && g_price_388 - g_price_380 <= gi_364 * point_16) {
         gia_1176[gi_928] = 1;
         gia_1180[gi_928] = 1;
         gi_376 = 2;
      }
      if (g_price_388 - g_price_380 > gi_364 * point_16 && g_price_388 - g_price_380 <= gi_368 * point_16) {
         gia_1176[gi_928] = 1;
         gia_1180[gi_928] = 1;
         gi_376 = 2;
      }
      if (g_price_388 - g_price_380 > gi_368 * point_16) {
         gia_1176[gi_928] = 1;
         gia_1180[gi_928] = 1;
         gi_376 = 0;
      }
      if ((g_time_1400 != Time[0] && gia_1176[gi_928] == 1 && gi_376 == 1 && iOpen(gsa_936[gi_928], 0, 0) > g_price_412 && ld_48 < g_price_412) || (g_time_1400 != Time[0] &&
         gia_1176[gi_928] == 1 && gi_376 == 2 && iOpen(gsa_936[gi_928], 0, 0) < g_price_412 && ld_48 > g_price_412) || (g_time_1400 != Time[0] && gia_1176[gi_928] == 1 && gi_376 == 0 && iOpen(gsa_936[gi_928],
         0, 0) < g_price_396 && ld_48 > g_price_396)) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if ((g_time_1404 != Time[0] && gia_1180[gi_928] == 1 && gi_376 == 1 && iOpen(gsa_936[gi_928], 0, 0) < g_price_420 && ld_48 > g_price_420) || (g_time_1404 != Time[0] &&
         gia_1180[gi_928] == 1 && gi_376 == 2 && iOpen(gsa_936[gi_928], 0, 0) > g_price_420 && ld_48 < g_price_420) || (g_time_1404 != Time[0] && gia_1180[gi_928] == 1 && gi_376 == 0 && iOpen(gsa_936[gi_928],
         0, 0) > g_price_404 && ld_48 < g_price_404)) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   }
   if (gi_300 == 13 && gi_352 > 0) {
      gs_244 = " инверсный пробой ";
      if (iHigh(gsa_936[gi_928], 0, 1) < g_price_380) gia_1176[gi_928] = 1;
      if (iLow(gsa_936[gi_928], 0, 1) > g_price_388) gia_1180[gi_928] = 1;
      if (gia_1176[gi_928] == 1 && g_time_1400 != Time[0] && ld_48 > g_price_380) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (gia_1180[gi_928] == 1 && g_time_1404 != Time[0] && ld_48 < g_price_388) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   } else
      if (gi_300 == 13 && gi_352 == 0) gi_300 = 8;
   if (gi_300 == 14 && gi_352 > 0) {
      gs_244 = " пробой с подтв. ";
      if (iClose(gsa_936[gi_928], 0, 1) > g_price_388) {
         gia_1184[gi_928] = 1;
         gia_1188[gi_928] = 0;
      }
      if (iClose(gsa_936[gi_928], 0, 1) < g_price_380) {
         gia_1188[gi_928] = 1;
         gia_1184[gi_928] = 0;
      }
      if (iHigh(gsa_936[gi_928], 0, 1) < g_price_388) {
         gia_1176[gi_928] = 1;
         gia_1184[gi_928] = 0;
      }
      if (iLow(gsa_936[gi_928], 0, 1) > g_price_380) {
         gia_1180[gi_928] = 1;
         gia_1188[gi_928] = 0;
      }
      if (gia_1176[gi_928] == 1 && g_time_1400 != Time[0] && iHigh(gsa_936[gi_928], 0, 1) <= g_price_388 && ld_48 > g_price_388) {
         gia_1168[gi_928] = 1;
         gia_1176[gi_928] = 0;
         g_time_1400 = Time[0];
      }
      if (gia_1180[gi_928] == 1 && g_time_1404 != Time[0] && iLow(gsa_936[gi_928], 0, 1) >= g_price_380 && ld_48 < g_price_380) {
         gia_1172[gi_928] = 1;
         gia_1180[gi_928] = 0;
         g_time_1404 = Time[0];
      }
   } else
      if (gi_300 == 14 && gi_352 == 0) gi_300 = 9;
   gi_unused_1192 = 0;
   gi_unused_1196 = 0;
   if (gda_1348[gi_928][gia_944[gi_928]][0] > gi_312) gi_unused_1192 = 1;
   if (gda_1348[gi_928][gia_944[gi_928]][0] < -gi_312) gi_unused_1196 = 1;
   gi_unused_1232 = 0;
   gi_unused_1236 = 0;
   gi_1240 = FALSE;
   gi_1244 = FALSE;
   if (BUY_SELL_SUMM || gi_100 > 0) {
      if (li_72 == 1 || Off_MA_H4 && gia_1140[gi_928] == 1 && gia_1168[gi_928] == 1 && gi_100 == 0 || gi_100 == 2) gi_1240 = TRUE;
      if (li_72 == 2 || Off_MA_H4 && gia_1144[gi_928] == 1 && gia_1172[gi_928] == 1 && gi_100 == 0 || gi_100 == 3) gi_1244 = TRUE;
   }
   if (BUY_SELL_SUMM == FALSE) {
      if (li_72 == 1 || Off_MA_H4 && gia_1140[gi_928] == 1 && gia_1168[gi_928] == 1 && gia_1036[gi_928] == 0 && gi_100 == 0 || gi_100 == 2) gi_1240 = TRUE;
      if (li_72 == 2 || Off_MA_H4 && gia_1144[gi_928] == 1 && gia_1172[gi_928] == 1 && gia_1032[gi_928] == 0 && gi_100 == 0 || gi_100 == 3) gi_1244 = TRUE;
   }
   if (gi_1240 == TRUE && gia_1032[gi_928] < MaxTrades) {
      gd_812 = NormalizeDouble(MarketInfo(gsa_936[gi_928], MODE_ASK), digits_44);
      if (gi_160 == 0) {
         if (gia_1032[gi_928] == 0 && gia_1032[gi_928] < N_LotMult) gda_1016[gi_928] = NormalizeDouble(gda_1216[gi_928], li_64);
         if (gia_1032[gi_928] == 0 && gi_176 && gia_1036[gi_928] > 4) gda_1016[gi_928] = NormalizeDouble(gda_1024[gi_928][1] * gd_180, li_64);
         if (gia_1032[gi_928] > 0 && gia_1032[gi_928] < N_LotMult) gda_1016[gi_928] = NormalizeDouble(gda_992[gi_928][0][li_80], li_64);
         if (gia_1032[gi_928] > 0 && gi_1240 == TRUE && gia_1032[gi_928] > N_LotMult - 1) gda_1016[gi_928] = NormalizeDouble(gda_992[gi_928][0][li_80] * LotMultiplicator, li_64);
         if (gia_1032[gi_928] > 0 && gi_1240 == TRUE && ld_56 > gda_996[gi_928][0][li_76] + gda_884[gi_928] && gi_232 < 1) gda_1016[gi_928] = NormalizeDouble(gda_992[gi_928][0][li_76], li_64);
      }
      if (gi_160 == 1) {
         if (gia_1032[gi_928] == 0) gda_1016[gi_928] = NormalizeDouble(gda_1216[gi_928], li_64);
         if (gia_1032[gi_928] > 0) {
            gda_996[gi_928][0][gia_1032[gi_928] + 1] = gd_812;
            gda_1016[gi_928] = NormalizeDouble(f0_16(0, gia_1032[gi_928] + 1), li_68);
         }
      }
      if (gi_160 == 2) {
         if (gia_1032[gi_928] == 0) gda_1016[gi_928] = NormalizeDouble(gda_1216[gi_928], li_64);
         if (gia_1032[gi_928] > 0) {
            gda_996[gi_928][0][gia_1032[gi_928] + 1] = gd_812;
            gda_1016[gi_928] = NormalizeDouble(f0_13(0, gia_1032[gi_928] + 1), li_68);
         }
      }
      if (gi_160 == 3) {
         if (gia_1032[gi_928] == 0) gda_1016[gi_928] = NormalizeDouble(gda_1216[gi_928], li_64);
         if (gia_1032[gi_928] > 0) {
            gda_996[gi_928][0][gia_1032[gi_928] + 1] = gd_812;
            gda_1016[gi_928] = NormalizeDouble(f0_15(0, gia_1032[gi_928] + 1), li_68);
         }
      }
      if (gi_160 == 4) {
         if (gia_1032[gi_928] == 0 || (gia_1032[gi_928] > 0 && gia_1032[gi_928] < N_LotMult)) gda_1016[gi_928] = NormalizeDouble(gda_1216[gi_928], li_64);
         if (gia_1032[gi_928] > 0 && gia_1032[gi_928] > N_LotMult - 1) {
            gda_996[gi_928][0][gia_1032[gi_928] + 1] = gd_812;
            gda_1016[gi_928] = NormalizeDouble(gda_992[gi_928][0][li_80] * MathPow(LotMultiplicator, (gda_996[gi_928][0][li_80] - gd_812) / gda_884[gi_928]), li_68);
         }
      }
      if (gi_160 == 5) {
         if (gia_1032[gi_928] == 0 || (gia_1032[gi_928] > 0 && gia_1032[gi_928] < N_LotMult)) gda_1016[gi_928] = NormalizeDouble(gda_1216[gi_928], li_64);
         if (gia_1032[gi_928] > 0 && gia_1032[gi_928] > N_LotMult - 1) {
            gda_996[gi_928][0][gia_1032[gi_928] + 1] = gd_812;
            gda_1016[gi_928] = NormalizeDouble(gda_1216[gi_928] * MathPow(LotMultiplicator, (gda_996[gi_928][0][li_76] - gd_812) / gda_884[gi_928] - N_LotMult), li_68);
         }
      }
      if (gi_160 == 6) {
         if (gia_1032[gi_928] == 0 || (gia_1032[gi_928] > 0 && gia_1032[gi_928] < N_LotMult + 1)) gda_1016[gi_928] = NormalizeDouble(gda_1216[gi_928], li_64);
         if (gia_1032[gi_928] > 0 && gia_1032[gi_928] > N_LotMult) {
            gda_996[gi_928][0][gia_1032[gi_928] + 1] = gd_812;
            gda_1016[gi_928] = NormalizeDouble(gda_1216[gi_928] * MathPow(LotMultiplicator, gia_1032[gi_928] - N_LotMult), li_64);
         }
      }
      if (gda_1016[gi_928] < g_minlot_144) gda_1016[gi_928] = g_minlot_144;
      if (gda_1016[gi_928] > MaxL) gda_1016[gi_928] = MaxL;
      gd_788 = 0;
      g_color_796 = gia_916[gi_928][0];
      gd_836 = gd_812 - gda_868[gi_928] * point_16;
      if (gda_868[gi_928] == 0.0) gd_836 = 0;
      gd_828 = gd_812 + gda_860[gi_928] * point_16;
      if (gda_860[gi_928] == 0.0 || gia_1032[gi_928] > 0) gd_828 = 0;
      if (gda_860[gi_928] < stoplevel_8 && gda_860[gi_928] != 0.0 && gia_1032[gi_928] == 0) gd_828 = gd_812 + (stoplevel_8 + 2) * point_16;
      g_ticket_1068 = f0_1(gsa_936[gi_928], gd_788, gda_1016[gi_928], gd_812, gd_836, gd_828, gia_956[gi_928], g_color_796);
      if (g_ticket_1068 > 0) {
         gia_1004[gi_928][0][gia_1032[gi_928] + 1] = g_ticket_1068;
         gia_1100[gi_928] = 0;
      }
      if (g_ticket_1068 < 0) gia_1100[gi_928] = 1;
      gia_844[gi_928] += gia_1100[gi_928];
      gia_1100[gi_928] = 0;
   }
   if (gi_1244 == TRUE && gia_1036[gi_928] < MaxTrades) {
      gd_820 = NormalizeDouble(MarketInfo(gsa_936[gi_928], MODE_BID), digits_44);
      if (gi_160 == 0) {
         if (gia_1036[gi_928] == 0 && gia_1036[gi_928] < N_LotMult) gda_1020[gi_928] = NormalizeDouble(gda_1220[gi_928], li_64);
         if (gia_1036[gi_928] == 0 && gi_176 && gia_1032[gi_928] > 4) gda_1020[gi_928] = NormalizeDouble(gda_1024[gi_928][0] * gd_180, li_64);
         if (gia_1036[gi_928] > 0 && gia_1036[gi_928] < N_LotMult) gda_1020[gi_928] = NormalizeDouble(gda_992[gi_928][1][li_84], li_64);
         if (gia_1036[gi_928] > 0 && gi_1244 == TRUE && gia_1036[gi_928] > N_LotMult - 1) gda_1020[gi_928] = NormalizeDouble(gda_992[gi_928][1][li_84] * LotMultiplicator, li_64);
         if (gia_1036[gi_928] > 0 && gi_1244 == TRUE && ld_48 < gda_996[gi_928][1][li_88] - gda_892[gi_928] && gi_232 < 1) gda_1020[gi_928] = NormalizeDouble(gda_992[gi_928][1][li_88], li_64);
      }
      if (gi_160 == 1) {
         if (gia_1036[gi_928] == 0) gda_1020[gi_928] = NormalizeDouble(gda_1220[gi_928], li_64);
         if (gia_1036[gi_928] > 0) {
            gda_996[gi_928][1][gia_1036[gi_928] + 1] = gd_820;
            gda_1020[gi_928] = NormalizeDouble(f0_16(1, gia_1036[gi_928] + 1), li_68);
         }
      }
      if (gi_160 == 2) {
         if (gia_1036[gi_928] == 0) gda_1020[gi_928] = NormalizeDouble(gda_1220[gi_928], li_64);
         if (gia_1036[gi_928] > 0) {
            gda_996[gi_928][1][gia_1036[gi_928] + 1] = gd_820;
            gda_1020[gi_928] = NormalizeDouble(f0_13(1, gia_1036[gi_928] + 1), li_68);
         }
      }
      if (gi_160 == 3) {
         if (gia_1036[gi_928] == 0) gda_1020[gi_928] = NormalizeDouble(gda_1220[gi_928], li_64);
         if (gia_1036[gi_928] > 0) {
            gda_996[gi_928][1][gia_1036[gi_928] + 1] = gd_820;
            gda_1020[gi_928] = NormalizeDouble(f0_15(1, gia_1036[gi_928] + 1), li_68);
         }
      }
      if (gi_160 == 4) {
         if (gia_1036[gi_928] == 0 || (gia_1036[gi_928] > 0 && gia_1036[gi_928] < N_LotMult)) gda_1020[gi_928] = NormalizeDouble(gda_1220[gi_928], li_64);
         if (gia_1036[gi_928] > 0 && gia_1036[gi_928] > N_LotMult - 1) {
            gda_996[gi_928][1][gia_1036[gi_928] + 1] = gd_820;
            gda_1020[gi_928] = NormalizeDouble(gda_992[gi_928][1][li_84] * MathPow(LotMultiplicator, (gd_820 - gda_996[gi_928][1][li_84]) / gda_892[gi_928]), li_68);
         }
      }
      if (gi_160 == 5) {
         if (gia_1036[gi_928] == 0 || (gia_1036[gi_928] > 0 && gia_1036[gi_928] < N_LotMult)) gda_1020[gi_928] = NormalizeDouble(gda_1220[gi_928], li_64);
         if (gia_1036[gi_928] > 0 && gia_1036[gi_928] > N_LotMult - 1) {
            gda_996[gi_928][1][gia_1036[gi_928] + 1] = gd_820;
            gda_1020[gi_928] = NormalizeDouble(gda_1220[gi_928] * MathPow(LotMultiplicator, (gd_820 - gda_996[gi_928][1][li_88]) / gda_892[gi_928] - N_LotMult), li_68);
         }
      }
      if (gi_160 == 6) {
         if (gia_1036[gi_928] == 0 || (gia_1036[gi_928] > 0 && gia_1036[gi_928] < N_LotMult + 1)) gda_1020[gi_928] = NormalizeDouble(gda_1220[gi_928], li_64);
         if (gia_1036[gi_928] > 0 && gia_1036[gi_928] > N_LotMult) {
            gda_996[gi_928][1][gia_1036[gi_928] + 1] = gd_820;
            gda_1020[gi_928] = NormalizeDouble(gda_1220[gi_928] * MathPow(LotMultiplicator, gia_1036[gi_928] - N_LotMult), li_64);
         }
      }
      if (gda_1020[gi_928] < g_minlot_144) gda_1020[gi_928] = g_minlot_144;
      if (gda_1020[gi_928] > MaxL) gda_1020[gi_928] = MaxL;
      if (gi_1240 == TRUE || gi_1244 == TRUE) gd_788 = 1;
      g_color_796 = gia_916[gi_928][1];
      gd_836 = gd_820 + gda_872[gi_928] * point_16;
      if (gda_872[gi_928] == 0.0) gd_836 = 0;
      gd_828 = gd_820 - gda_864[gi_928] * point_16;
      if (gda_864[gi_928] == 0.0 || gia_1036[gi_928] > 0) gd_828 = 0;
      if (gda_864[gi_928] < stoplevel_8 && gda_864[gi_928] != 0.0 && gia_1036[gi_928] == 0) gd_828 = gd_820 - (stoplevel_8 + 2) * point_16;
      g_ticket_1068 = f0_1(gsa_936[gi_928], gd_788, gda_1020[gi_928], gd_820, gd_836, gd_828, gia_956[gi_928], g_color_796);
      if (g_ticket_1068 > 0) gia_1004[gi_928][1][gia_1036[gi_928] + 1] = g_ticket_1068;
      if (g_ticket_1068 < 0) gia_1104[gi_928] = 1;
      gia_844[gi_928] += gia_1104[gi_928];
      gia_1104[gi_928] = 0;
   }
   if (gia_1032[gi_928] > 0 || gia_1036[gi_928] > 0) {
      price_108 = NormalizeDouble(f0_11(gia_1032[gi_928], 0) + gda_1224[gi_928] * point_16, digits_44);
      price_116 = NormalizeDouble(f0_11(gia_1036[gi_928], 1) - gda_1228[gi_928] * point_16, digits_44);
   }
   if (gi_484) {
      if ((gia_1032[gi_928] > 0 && gda_860[gi_928] == 0.0) || gia_1032[gi_928] > 1) {
         for (gi_1084 = 1; gi_1084 <= gia_1032[gi_928]; gi_1084++) {
            OrderSelect(gia_1004[gi_928][0][gi_1084], SELECT_BY_TICKET, MODE_TRADES);
            if (OrderType() == OP_BUY && OrderMagicNumber() == gia_956[gi_928] && OrderSymbol() == gsa_936[gi_928])
               if (price_108 != OrderTakeProfit()) g_ticket_1068 = OrderModify(gia_1004[gi_928][0][gi_1084], OrderOpenPrice(), OrderStopLoss(), price_108, 0, gia_916[gi_928][0]);
         }
      }
      if ((gia_1036[gi_928] > 0 && gda_864[gi_928] == 0.0) || gia_1036[gi_928] > 1) {
         for (gi_1084 = 1; gi_1084 <= gia_1036[gi_928]; gi_1084++) {
            OrderSelect(gia_1004[gi_928][1][gi_1084], SELECT_BY_TICKET, MODE_TRADES);
            if (OrderType() == OP_SELL && OrderMagicNumber() == gia_956[gi_928] && OrderSymbol() == gsa_936[gi_928])
               if (price_116 != OrderTakeProfit()) g_ticket_1068 = OrderModify(gia_1004[gi_928][1][gi_1084], OrderOpenPrice(), OrderStopLoss(), price_116, 0, gia_916[gi_928][1]);
         }
      }
   }
   gia_1200[gi_928] = 0;
   gia_1204[gi_928] = 0;
   gia_1056[gi_928] = gia_1032[gi_928];
   gia_1060[gi_928] = gia_1036[gi_928];
   f0_7();
   if (gia_1032[gi_928] > 0) {
      li_76 = f0_0(0, gia_1032[gi_928]);
      li_80 = f0_14(0, gia_1032[gi_928]);
   }
   if (gia_1036[gi_928] > 0) {
      li_84 = f0_0(1, gia_1036[gi_928]);
      li_88 = f0_14(1, gia_1036[gi_928]);
   }
   if (gia_1056[gi_928] != gia_1032[gi_928]) gia_1200[gi_928] = 1;
   if (gia_1060[gi_928] != gia_1036[gi_928]) gia_1204[gi_928] = 1;
   if (Mode_SL_inst != 0) {
      g_tickvalue_1544 = MarketInfo(gsa_936[gi_928], MODE_TICKVALUE);
      margininit_124 = MarketInfo(gsa_936[gi_928], MODE_MARGININIT);
      gd_unused_900 = 1;
      if (Digits == 2 || (Digits == 3 && gi_856 == 10)) gd_unused_900 = 100;
      if (gia_1032[gi_928] > 0) {
         g_price_572 = NormalizeDouble(f0_11(gia_1032[gi_928], 0) - gd_564 / (g_tickvalue_1544 * gda_1024[gi_928][0]) * point_16, digits_44);
         if (g_price_572 < 0.0) g_price_572 = 0;
      }
      if (gia_1036[gi_928] > 0) {
         g_price_580 = NormalizeDouble(f0_11(gia_1036[gi_928], 1) + gd_564 / (g_tickvalue_1544 * gda_1024[gi_928][1]) * point_16, digits_44);
         if (g_price_580 < 0.0) g_price_580 = 0;
      }
      if (gia_1032[gi_928] > 0 && gia_1036[gi_928] > 0) {
      }
      if (gia_1032[gi_928] > 0 && g_price_572 > 0.0) {
         for (gi_1084 = 1; gi_1084 <= gia_1032[gi_928]; gi_1084++) {
            OrderSelect(gia_1004[gi_928][0][gi_1084], SELECT_BY_TICKET, MODE_TRADES);
            if (OrderType() == OP_BUY && OrderMagicNumber() == gia_956[gi_928] && OrderSymbol() == gsa_936[gi_928])
               if ((g_price_572 > OrderStopLoss() + g_pips_588 * point_16 && g_price_572 < OrderStopLoss() - g_pips_588 * point_16) || OrderStopLoss() == 0.0 || gia_1200[gi_928] == 1) g_ticket_1068 = OrderModify(gia_1004[gi_928][0][gi_1084], OrderOpenPrice(), g_price_572, OrderTakeProfit(), 0, gia_916[gi_928][0]);
         }
      }
      if (gia_1036[gi_928] > 0 && g_price_580 > 0.0) {
         for (gi_1084 = 1; gi_1084 <= gia_1036[gi_928]; gi_1084++) {
            OrderSelect(gia_1004[gi_928][1][gi_1084], SELECT_BY_TICKET, MODE_TRADES);
            if (OrderType() == OP_SELL && OrderMagicNumber() == gia_956[gi_928] && OrderSymbol() == gsa_936[gi_928])
               if ((g_price_580 < OrderStopLoss() - g_pips_588 * point_16 && g_price_580 > OrderStopLoss() + g_pips_588 * point_16) || OrderStopLoss() == 0.0 || gia_1204[gi_928] == 1) g_ticket_1068 = OrderModify(gia_1004[gi_928][1][gi_1084], OrderOpenPrice(), g_price_580, OrderTakeProfit(), 0, gia_916[gi_928][1]);
         }
      }
   }
   if (gia_1032[gi_928] > 0 && gia_1036[gi_928] > 0 && Mode_Close_Orders == 3 || Mode_Close_Orders == 5) {
      if (gda_1024[gi_928][0] > gda_1024[gi_928][1]) gia_880[gi_928] = gia_880[gi_928] * gda_1024[gi_928][0] / gda_1024[gi_928][1];
      if (gda_1024[gi_928][0] < gda_1024[gi_928][1]) gia_876[gi_928] = gia_876[gi_928] * gda_1024[gi_928][1] / gda_1024[gi_928][0];
   }
   if (gi_488) {
      if (gia_1032[gi_928] > 0) {
         g_price_1280 = NormalizeDouble(f0_11(gia_1032[gi_928], 0) + gda_1224[gi_928] * point_16, digits_44);
         g_price_1264 = 0;
         if (gsa_936[gi_928] == ls_0 && LineOnGraph) {
            ObjectCreate(gsa_924[0][0], OBJ_HLINE, 0, Time[0], g_price_1280);
            ObjectSet(gsa_924[0][0], OBJPROP_PRICE1, g_price_1280);
            ObjectSet(gsa_924[0][0], OBJPROP_COLOR, gia_916[gi_928][0]);
            ObjectSet(gsa_924[0][0], OBJPROP_WIDTH, 2);
            ObjectCreate(gsa_924[3][0], OBJ_HLINE, 0, Time[0], ld_48 - gia_876[gi_928] * point_16);
            ObjectSet(gsa_924[3][0], OBJPROP_PRICE1, ld_48 - gia_876[gi_928] * point_16);
            ObjectSet(gsa_924[3][0], OBJPROP_COLOR, gia_916[gi_928][0]);
            ObjectSet(gsa_924[3][0], OBJPROP_STYLE, STYLE_DASHDOT);
         }
         if (gia_1032[gi_928] > 0 && g_price_1280 < NormalizeDouble(ld_48 - gia_876[gi_928] * point_16, digits_44)) {
            for (gi_1084 = 1; gi_1084 <= gia_1032[gi_928]; gi_1084++) {
               OrderSelect(gia_1004[gi_928][0][gi_1084], SELECT_BY_TICKET, MODE_TRADES);
               if (OrderType() == OP_BUY && OrderMagicNumber() == gia_956[gi_928] && OrderSymbol() == gsa_936[gi_928])
                  if (NormalizeDouble(ld_48 - gia_876[gi_928] * point_16, digits_44) > OrderStopLoss() || OrderStopLoss() == 0.0) g_ticket_1068 = OrderModify(gia_1004[gi_928][0][gi_1084], OrderOpenPrice(), NormalizeDouble(ld_48 - gia_876[gi_928] * point_16, digits_44), g_price_1264, 0, gia_916[gi_928][0]);
            }
         }
      } else {
         if (gsa_936[gi_928] == ls_0 && LineOnGraph) {
            ObjectDelete(gsa_924[0][0]);
            ObjectDelete(gsa_924[3][0]);
         }
      }
      if (gia_1036[gi_928] > 0) {
         g_price_1288 = NormalizeDouble(f0_11(gia_1036[gi_928], 1) - gda_1228[gi_928] * point_16, digits_44);
         g_price_1272 = 0;
         if (gsa_936[gi_928] == ls_0 && LineOnGraph) {
            ObjectCreate(gsa_924[0][1], OBJ_HLINE, 0, Time[0], g_price_1288);
            ObjectSet(gsa_924[0][1], OBJPROP_PRICE1, g_price_1288);
            ObjectSet(gsa_924[0][1], OBJPROP_COLOR, gia_916[gi_928][1]);
            ObjectSet(gsa_924[0][1], OBJPROP_WIDTH, 2);
            ObjectCreate(gsa_924[3][1], OBJ_HLINE, 0, Time[0], ld_56 + gia_880[gi_928] * point_16);
            ObjectSet(gsa_924[3][1], OBJPROP_PRICE1, ld_56 + gia_880[gi_928] * point_16);
            ObjectSet(gsa_924[3][1], OBJPROP_COLOR, gia_916[gi_928][1]);
            ObjectSet(gsa_924[3][1], OBJPROP_STYLE, STYLE_DASHDOT);
         }
         if (gia_1036[gi_928] > 0 && g_price_1288 > NormalizeDouble(ld_56 + gia_880[gi_928] * point_16, digits_44)) {
            for (gi_1084 = 1; gi_1084 <= gia_1036[gi_928]; gi_1084++) {
               OrderSelect(gia_1004[gi_928][1][gi_1084], SELECT_BY_TICKET, MODE_TRADES);
               if (OrderType() == OP_SELL && OrderMagicNumber() == gia_956[gi_928] && OrderSymbol() == gsa_936[gi_928])
                  if (NormalizeDouble(ld_56 + gia_880[gi_928] * point_16, digits_44) < OrderStopLoss() || OrderStopLoss() == 0.0) g_ticket_1068 = OrderModify(gia_1004[gi_928][1][gi_1084], OrderOpenPrice(), NormalizeDouble(ld_56 + gia_880[gi_928] * point_16, digits_44), g_price_1272, 0, gia_916[gi_928][1]);
            }
         }
      } else {
         if (gsa_936[gi_928] == ls_0 && LineOnGraph) {
            ObjectDelete(gsa_924[0][1]);
            ObjectDelete(gsa_924[3][1]);
         }
      }
   }
   if (gi_496) {
      if (gia_1032[gi_928] > 3) {
         g_price_1280 = f0_10(1, gia_1032[gi_928] - 1, gia_1032[gi_928], 0) + gda_1224[gi_928] * point_16;
         g_price_1264 = 0;
         if (gsa_936[gi_928] == ls_0 && LineOnGraph) {
            ObjectCreate(gsa_924[2][0], OBJ_HLINE, 0, Time[0], g_price_1280);
            ObjectSet(gsa_924[2][0], OBJPROP_PRICE1, g_price_1280);
            ObjectSet(gsa_924[2][0], OBJPROP_COLOR, DarkTurquoise);
            ObjectSet(gsa_924[2][0], OBJPROP_STYLE, 6);
            ObjectCreate(gsa_924[3][0], OBJ_HLINE, 0, Time[0], ld_48 - gia_876[gi_928] * point_16);
            ObjectSet(gsa_924[3][0], OBJPROP_PRICE1, ld_48 - gia_876[gi_928] * point_16);
            ObjectSet(gsa_924[3][0], OBJPROP_COLOR, Blue);
            ObjectSet(gsa_924[3][0], OBJPROP_STYLE, STYLE_DASHDOT);
         }
         if (gia_1032[gi_928] > 0 && g_price_1280 < ld_48 - gia_876[gi_928] * point_16) {
            for (gi_1084 = 1; gi_1084 <= gia_1032[gi_928]; gi_1084++) {
               OrderSelect(gia_1004[gi_928][0][gi_1084], SELECT_BY_TICKET, MODE_TRADES);
               if (OrderType() == OP_BUY && OrderMagicNumber() == gia_956[gi_928] && OrderSymbol() == gsa_936[gi_928] && gi_1084 == 1 || gi_1084 == gia_1032[gi_928] - 1 || gi_1084 == gia_1032[gi_928])
                  if (ld_48 - gia_876[gi_928] * point_16 > OrderStopLoss() || OrderStopLoss() == 0.0) g_ticket_1068 = OrderModify(OrderTicket(), OrderOpenPrice(), ld_48 - gia_876[gi_928] * point_16, g_price_1264, 0, DarkTurquoise);
            }
         }
      } else
         if (gsa_936[gi_928] == ls_0 && LineOnGraph) ObjectDelete(gsa_924[2][0]);
      if (gia_1036[gi_928] > 3) {
         g_price_1288 = f0_10(1, gia_1036[gi_928] - 1, gia_1036[gi_928], 1) - gda_1228[gi_928] * point_16;
         g_price_1272 = 0;
         if (gsa_936[gi_928] == ls_0 && LineOnGraph) {
            ObjectCreate(gsa_924[2][1], OBJ_HLINE, 0, Time[0], g_price_1288);
            ObjectSet(gsa_924[2][1], OBJPROP_PRICE1, g_price_1288);
            ObjectSet(gsa_924[2][1], OBJPROP_COLOR, OrangeRed);
            ObjectSet(gsa_924[2][1], OBJPROP_STYLE, 6);
            ObjectCreate(gsa_924[3][1], OBJ_HLINE, 0, Time[0], ld_56 + gia_880[gi_928] * point_16);
            ObjectSet(gsa_924[3][1], OBJPROP_PRICE1, ld_56 + gia_880[gi_928] * point_16);
            ObjectSet(gsa_924[3][1], OBJPROP_COLOR, Red);
            ObjectSet(gsa_924[3][1], OBJPROP_STYLE, STYLE_DASHDOT);
         }
         if (gia_1036[gi_928] > 0 && g_price_1288 > ld_56 + gia_880[gi_928] * point_16) {
            for (gi_1084 = 1; gi_1084 <= gia_1036[gi_928]; gi_1084++) {
               OrderSelect(gia_1004[gi_928][1][gi_1084], SELECT_BY_TICKET, MODE_TRADES);
               if (OrderType() == OP_SELL && OrderMagicNumber() == gia_956[gi_928] && OrderSymbol() == gsa_936[gi_928] && gi_1084 == 1 || gi_1084 == gia_1036[gi_928] - 1 || gi_1084 == gia_1036[gi_928])
                  if (ld_56 + gia_880[gi_928] * point_16 < OrderStopLoss() || OrderStopLoss() == 0.0) g_ticket_1068 = OrderModify(OrderTicket(), OrderOpenPrice(), ld_56 + gia_880[gi_928] * point_16, g_price_1272, 0, OrangeRed);
            }
         }
      } else
         if (gsa_936[gi_928] == ls_0 && LineOnGraph) ObjectDelete(gsa_924[2][1]);
   }
   if (gi_492) {
      if (gia_1032[gi_928] > 2) {
         g_price_1280 = f0_5(1, gia_1032[gi_928], 0) + gda_1224[gi_928] * point_16;
         g_price_1264 = 0;
         if (gsa_936[gi_928] == ls_0 && LineOnGraph) {
            ObjectCreate(gsa_924[1][0], OBJ_HLINE, 0, Time[0], g_price_1280);
            ObjectSet(gsa_924[1][0], OBJPROP_PRICE1, g_price_1280);
            ObjectSet(gsa_924[1][0], OBJPROP_COLOR, MidnightBlue);
            ObjectSet(gsa_924[1][0], OBJPROP_STYLE, 6);
            ObjectCreate(gsa_924[3][0], OBJ_HLINE, 0, Time[0], ld_48 - gia_876[gi_928] * point_16);
            ObjectSet(gsa_924[3][0], OBJPROP_PRICE1, ld_48 - gia_876[gi_928] * point_16);
            ObjectSet(gsa_924[3][0], OBJPROP_COLOR, Blue);
            ObjectSet(gsa_924[3][0], OBJPROP_STYLE, STYLE_DASHDOT);
         }
         if (gia_1032[gi_928] > 0 && g_price_1280 < ld_48 - gia_876[gi_928] * point_16) {
            for (gi_1084 = 1; gi_1084 <= gia_1032[gi_928]; gi_1084++) {
               OrderSelect(gia_1004[gi_928][0][gi_1084], SELECT_BY_TICKET, MODE_TRADES);
               if (OrderType() == OP_BUY && OrderMagicNumber() == gia_956[gi_928] && OrderSymbol() == gsa_936[gi_928] && gi_1084 == 1 || gi_1084 == gia_1032[gi_928])
                  if (ld_48 - gia_876[gi_928] * point_16 > OrderStopLoss() || OrderStopLoss() == 0.0) g_ticket_1068 = OrderModify(OrderTicket(), OrderOpenPrice(), ld_48 - gia_876[gi_928] * point_16, g_price_1264, 0, MidnightBlue);
            }
         }
      } else
         if (gsa_936[gi_928] == ls_0 && LineOnGraph) ObjectDelete(gsa_924[1][0]);
      if (gia_1036[gi_928] > 2) {
         g_price_1288 = f0_5(1, gia_1036[gi_928], 1) - gda_1228[gi_928] * point_16;
         g_price_1272 = 0;
         if (gsa_936[gi_928] == ls_0 && LineOnGraph) {
            ObjectCreate(gsa_924[1][1], OBJ_HLINE, 0, Time[0], g_price_1288);
            ObjectSet(gsa_924[1][1], OBJPROP_PRICE1, g_price_1288);
            ObjectSet(gsa_924[1][1], OBJPROP_COLOR, Peru);
            ObjectSet(gsa_924[1][1], OBJPROP_STYLE, 6);
            ObjectCreate(gsa_924[3][1], OBJ_HLINE, 0, Time[0], ld_56 + gia_880[gi_928] * point_16);
            ObjectSet(gsa_924[3][1], OBJPROP_PRICE1, ld_56 + gia_880[gi_928] * point_16);
            ObjectSet(gsa_924[3][1], OBJPROP_COLOR, Red);
            ObjectSet(gsa_924[3][1], OBJPROP_STYLE, STYLE_DASHDOT);
         }
         if (gia_1036[gi_928] > 0 && g_price_1288 > ld_56 + gia_880[gi_928] * point_16) {
            for (gi_1084 = 1; gi_1084 <= gia_1036[gi_928]; gi_1084++) {
               OrderSelect(gia_1004[gi_928][1][gi_1084], SELECT_BY_TICKET, MODE_TRADES);
               if (OrderType() == OP_SELL && OrderMagicNumber() == gia_956[gi_928] && OrderSymbol() == gsa_936[gi_928] && gi_1084 == 1 || gi_1084 == gia_1036[gi_928])
                  if (ld_56 + gia_880[gi_928] * point_16 < OrderStopLoss() || OrderStopLoss() == 0.0) g_ticket_1068 = OrderModify(OrderTicket(), OrderOpenPrice(), ld_56 + gia_880[gi_928] * point_16, g_price_1272, 0, Peru);
            }
         }
      } else
         if (gsa_936[gi_928] == ls_0 && LineOnGraph) ObjectDelete(gsa_924[1][1]);
   }
   if (gi_500) {
      if (gia_1032[gi_928] > 2) {
         g_price_1280 = f0_5(gia_1032[gi_928] - 1, gia_1032[gi_928], 0) + gda_1224[gi_928] * point_16;
         g_price_1264 = 0;
         if (gsa_936[gi_928] == ls_0 && LineOnGraph) {
            ObjectCreate(gsa_924[4][0], OBJ_HLINE, 0, Time[0], g_price_1280);
            ObjectSet(gsa_924[4][0], OBJPROP_PRICE1, g_price_1280);
            ObjectSet(gsa_924[4][0], OBJPROP_COLOR, MidnightBlue);
            ObjectSet(gsa_924[4][0], OBJPROP_STYLE, 6);
            ObjectCreate(gsa_924[3][0], OBJ_HLINE, 0, Time[0], ld_48 - gia_876[gi_928] * point_16);
            ObjectSet(gsa_924[3][0], OBJPROP_PRICE1, ld_48 - gia_876[gi_928] * point_16);
            ObjectSet(gsa_924[3][0], OBJPROP_COLOR, Blue);
            ObjectSet(gsa_924[3][0], OBJPROP_STYLE, STYLE_DASHDOT);
         }
         if (gia_1032[gi_928] > 0 && g_price_1280 < ld_48 - gia_876[gi_928] * point_16) {
            for (gi_1084 = 1; gi_1084 <= gia_1032[gi_928]; gi_1084++) {
               OrderSelect(gia_1004[gi_928][0][gi_1084], SELECT_BY_TICKET, MODE_TRADES);
               if (OrderType() == OP_BUY && OrderMagicNumber() == gia_956[gi_928] && OrderSymbol() == gsa_936[gi_928] && gi_1084 == gia_1032[gi_928] - 1 || gi_1084 == gia_1032[gi_928])
                  if (ld_48 - gia_876[gi_928] * point_16 > OrderStopLoss() || OrderStopLoss() == 0.0) g_ticket_1068 = OrderModify(OrderTicket(), OrderOpenPrice(), ld_48 - gia_876[gi_928] * point_16, g_price_1264, 0, MidnightBlue);
            }
         }
      } else
         if (gsa_936[gi_928] == ls_0 && LineOnGraph) ObjectDelete(gsa_924[4][0]);
      if (gia_1036[gi_928] > 2) {
         g_price_1288 = f0_5(gia_1036[gi_928] - 1, gia_1036[gi_928], 1) - gda_1228[gi_928] * point_16;
         g_price_1272 = 0;
         if (gsa_936[gi_928] == ls_0 && LineOnGraph) {
            ObjectCreate(gsa_924[4][1], OBJ_HLINE, 0, Time[0], g_price_1288);
            ObjectSet(gsa_924[4][1], OBJPROP_PRICE1, g_price_1288);
            ObjectSet(gsa_924[4][1], OBJPROP_COLOR, Peru);
            ObjectSet(gsa_924[4][1], OBJPROP_STYLE, 6);
            ObjectCreate(gsa_924[3][1], OBJ_HLINE, 0, Time[0], ld_56 + gia_880[gi_928] * point_16);
            ObjectSet(gsa_924[3][1], OBJPROP_PRICE1, ld_56 + gia_880[gi_928] * point_16);
            ObjectSet(gsa_924[3][1], OBJPROP_COLOR, Red);
            ObjectSet(gsa_924[3][1], OBJPROP_STYLE, STYLE_DASHDOT);
         }
         if (gia_1036[gi_928] > 0 && g_price_1288 > ld_56 + gia_880[gi_928] * point_16) {
            for (gi_1084 = 1; gi_1084 <= gia_1036[gi_928]; gi_1084++) {
               OrderSelect(gia_1004[gi_928][1][gi_1084], SELECT_BY_TICKET, MODE_TRADES);
               if (OrderType() == OP_SELL && OrderMagicNumber() == gia_956[gi_928] && OrderSymbol() == gsa_936[gi_928] && gi_1084 == gia_1036[gi_928] - 1 || gi_1084 == gia_1036[gi_928])
                  if (ld_56 + gia_880[gi_928] * point_16 < OrderStopLoss() || OrderStopLoss() == 0.0) g_ticket_1068 = OrderModify(OrderTicket(), OrderOpenPrice(), ld_56 + gia_880[gi_928] * point_16, g_price_1272, 0, Peru);
            }
         }
      } else
         if (gsa_936[gi_928] == ls_0 && LineOnGraph) ObjectDelete(gsa_924[4][1]);
   }
   if (gi_504) {
      if (gia_1032[gi_928] > 0) {
         g_price_1280 = gda_996[gi_928][0][li_80] + gda_1224[gi_928] * point_16;
         g_price_1264 = 0;
         if (gsa_936[gi_928] == ls_0) {
            ObjectCreate("UBB2", OBJ_HLINE, 0, Time[0], g_price_1280);
            ObjectSet("UBB2", OBJPROP_PRICE1, g_price_1280);
            ObjectSet("UBB2", OBJPROP_COLOR, MidnightBlue);
            ObjectSet("UBB2", OBJPROP_STYLE, 6);
            ObjectCreate("SLB", OBJ_HLINE, 0, Time[0], ld_48 - gia_876[gi_928] * point_16);
            ObjectSet("SLB", OBJPROP_PRICE1, ld_48 - gia_876[gi_928] * point_16);
            ObjectSet("SLB", OBJPROP_COLOR, Blue);
            ObjectSet("SLB", OBJPROP_STYLE, STYLE_DASHDOT);
         }
         if (gia_1032[gi_928] > 0 && g_price_1280 < ld_48 - gia_876[gi_928] * point_16) {
            for (gi_1084 = 1; gi_1084 <= gia_1032[gi_928]; gi_1084++) {
               OrderSelect(gia_1004[gi_928][0][gi_1084], SELECT_BY_TICKET, MODE_TRADES);
               if (OrderType() == OP_BUY && OrderMagicNumber() == gia_956[gi_928] && OrderSymbol() == gsa_936[gi_928] && gi_1084 == li_80)
                  if (ld_48 - gia_876[gi_928] * point_16 > OrderStopLoss() || OrderStopLoss() == 0.0) g_ticket_1068 = OrderModify(OrderTicket(), OrderOpenPrice(), ld_48 - gia_876[gi_928] * point_16, g_price_1264, 0, MidnightBlue);
            }
         }
      } else ObjectDelete("UBB2");
      if (gia_1036[gi_928] > 0) {
         g_price_1288 = gda_996[gi_928][1][li_84] - gda_1228[gi_928] * point_16;
         g_price_1272 = 0;
         if (gsa_936[gi_928] == ls_0) {
            ObjectCreate("UBS2", OBJ_HLINE, 0, Time[0], g_price_1288);
            ObjectSet("UBS2", OBJPROP_PRICE1, g_price_1288);
            ObjectSet("UBS2", OBJPROP_COLOR, Peru);
            ObjectSet("UBS2", OBJPROP_STYLE, 6);
            ObjectCreate("SLS", OBJ_HLINE, 0, Time[0], ld_56 + gia_880[gi_928] * point_16);
            ObjectSet("SLS", OBJPROP_PRICE1, ld_56 + gia_880[gi_928] * point_16);
            ObjectSet("SLS", OBJPROP_COLOR, Red);
            ObjectSet("SLS", OBJPROP_STYLE, STYLE_DASHDOT);
         }
         if (gia_1036[gi_928] > 0 && g_price_1288 > ld_56 + gia_880[gi_928] * point_16) {
            for (gi_1084 = 1; gi_1084 <= gia_1036[gi_928]; gi_1084++) {
               OrderSelect(gia_1004[gi_928][1][gi_1084], SELECT_BY_TICKET, MODE_TRADES);
               if (OrderType() == OP_SELL && OrderMagicNumber() == gia_956[gi_928] && OrderSymbol() == gsa_936[gi_928] && gi_1084 == li_84)
                  if (ld_56 + gia_880[gi_928] * point_16 < OrderStopLoss() || OrderStopLoss() == 0.0) g_ticket_1068 = OrderModify(OrderTicket(), OrderOpenPrice(), ld_56 + gia_880[gi_928] * point_16, g_price_1272, 0, Peru);
            }
         }
      } else ObjectDelete("UBS2");
   }
   if (PercentProf_from_OTBOY > 0.0 || (Mode_Close_Orders == 4 || Mode_Close_Orders == 5 && PercentProf_from_OTBOY == 0.0)) {
      if (Mode_Close_Orders == 4 || Mode_Close_Orders == 5 && PercentProf_from_OTBOY == 0.0 && Mode_enable_OTBOY != 3) PercentProf_from_OTBOY = 30;
      gd_780 = 0;
      for (gi_1084 = 0; gi_1084 <= N_Day_Prof; gi_1084++) gd_780 += f0_8(gi_1084);
      gd_780 = gd_780 * PercentProf_from_OTBOY / 100.0;
      if ((Mode_enable_OTBOY == 1 && gia_1032[gi_928] > N_ord_enable_OTBOY) || (Mode_enable_OTBOY == 2 && gda_996[gi_928][0][li_76] - ld_48 > r_cen_enable_OTBOY * point_16) ||
         (gi_100 > 0 && Mode_enable_OTBOY != 3) && gda_1024[gi_928][0] > gda_1024[gi_928][1] && (-gda_1000[gi_928][0][1]) < gd_780 && gda_1028[gi_928][0] < gda_1028[gi_928][1]) {
         OrderSelect(gia_1004[gi_928][0][1], SELECT_BY_TICKET, MODE_TRADES);
         if (OrderMagicNumber() == gia_956[gi_928] && OrderSymbol() == gsa_936[gi_928]) {
            if (OrderType() == OP_BUY) {
               g_bid_1408 = MarketInfo(gsa_936[gi_928], MODE_BID);
               g_order_lots_1416 = OrderLots();
               g_ticket_1068 = OrderTicket();
               g_color_796 = DarkViolet;
               OrderClose(g_ticket_1068, g_order_lots_1416, g_bid_1408, g_slippage_852, g_color_796);
            }
         }
      }
      if ((Mode_enable_OTBOY == 1 && gia_1036[gi_928] > N_ord_enable_OTBOY) || (Mode_enable_OTBOY == 2 && ld_48 - gda_996[gi_928][1][li_88] > r_cen_enable_OTBOY * point_16) ||
         (gi_100 > 0 && Mode_enable_OTBOY != 3) && gda_1024[gi_928][1] > gda_1024[gi_928][0] && (-gda_1000[gi_928][1][1]) < gd_780 && gda_1028[gi_928][1] < gda_1028[gi_928][0]) {
         OrderSelect(gia_1004[gi_928][1][1], SELECT_BY_TICKET, MODE_TRADES);
         if (OrderMagicNumber() == gia_956[gi_928] && OrderSymbol() == gsa_936[gi_928]) {
            if (OrderType() == OP_SELL) {
               g_bid_1408 = MarketInfo(gsa_936[gi_928], MODE_ASK);
               g_order_lots_1416 = OrderLots();
               g_ticket_1068 = OrderTicket();
               g_color_796 = LightSalmon;
               OrderClose(g_ticket_1068, g_order_lots_1416, g_bid_1408, g_slippage_852, g_color_796);
            }
         }
      }
   }
   if (DataOnGraph) f0_6();
   return (0);
}

int f0_1(string a_symbol_0, int a_cmd_8, double a_lots_12, double a_price_20, double a_price_28, double a_price_36, int a_magic_44, color a_color_48) {
   int ticket_52;
   ticket_52 = OrderSend(a_symbol_0, a_cmd_8, a_lots_12, a_price_20, 6, a_price_28, a_price_36, gsa_936[gi_928] + gs_80 + " mgk" + a_magic_44, a_magic_44, 0, a_color_48);
   return (ticket_52);
}

double f0_11(int ai_0, int ai_4) {
   double ld_8 = 0;
   double ld_16 = 0;
   for (gi_1084 = 1; gi_1084 <= ai_0; gi_1084++) {
      ld_8 += gda_996[gi_928][ai_4][gi_1084] * gda_992[gi_928][ai_4][gi_1084];
      ld_16 += gda_992[gi_928][ai_4][gi_1084];
   }
   if (ld_16 == 0.0) return (0);
   return (ld_8 / ld_16);
}

double f0_10(int ai_0, int ai_4, int ai_8, int ai_12) {
   double ld_16 = 0;
   double ld_24 = 0;
   ld_16 = gda_996[gi_928][ai_12][ai_0] * gda_992[gi_928][ai_12][ai_0] + gda_996[gi_928][ai_12][ai_4] * gda_992[gi_928][ai_12][ai_4] + gda_996[gi_928][ai_12][ai_8] * gda_992[gi_928][ai_12][ai_8];
   ld_24 = gda_992[gi_928][ai_12][ai_0] + gda_992[gi_928][ai_12][ai_4] + gda_992[gi_928][ai_12][ai_8];
   if (ld_24 == 0.0) return (0);
   return (ld_16 / ld_24);
}

double f0_5(int ai_0, int ai_4, int ai_8) {
   double ld_12 = 0;
   double ld_20 = 0;
   ld_12 = gda_996[gi_928][ai_8][ai_0] * gda_992[gi_928][ai_8][ai_0] + gda_996[gi_928][ai_8][ai_4] * gda_992[gi_928][ai_8][ai_4];
   ld_20 = gda_992[gi_928][ai_8][ai_0] + gda_992[gi_928][ai_8][ai_4];
   if (ld_20 == 0.0) return (0);
   return (ld_12 / ld_20);
}

double f0_3(int ai_0, int a_period_4, int a_ma_method_8, int a_applied_price_12, int a_timeframe_16) {
   double ima_20;
   ima_20 = iMA(gsa_936[gi_928], a_timeframe_16, a_period_4, 0, a_ma_method_8, a_applied_price_12, ai_0);
   return (ima_20);
}

int f0_14(int ai_0, int ai_4) {
   int li_ret_16;
   double ld_8 = 100000;
   for (gi_1084 = 1; gi_1084 <= ai_4; gi_1084++) {
      if (ld_8 >= gda_996[gi_928][ai_0][gi_1084]) {
         ld_8 = gda_996[gi_928][ai_0][gi_1084];
         li_ret_16 = gi_1084;
      }
   }
   return (li_ret_16);
}

int f0_0(int ai_0, int ai_4) {
   int li_ret_16;
   double ld_8 = 0;
   for (gi_1084 = 1; gi_1084 <= ai_4; gi_1084++) {
      if (ld_8 <= gda_996[gi_928][ai_0][gi_1084]) {
         ld_8 = gda_996[gi_928][ai_0][gi_1084];
         li_ret_16 = gi_1084;
      }
   }
   return (li_ret_16);
}

int f0_2(int ai_0, int ai_4, double ad_8) {
   int li_ret_24;
   double ld_16 = 100000;
   for (gi_1084 = 1; gi_1084 <= ai_4; gi_1084++) {
      if (ld_16 >= gda_996[gi_928][ai_0][gi_1084] && ad_8 <= gda_996[gi_928][ai_0][gi_1084]) {
         ld_16 = gda_996[gi_928][ai_0][gi_1084];
         li_ret_24 = gi_1084;
      }
   }
   return (li_ret_24);
}

int f0_4(int ai_0, int ai_4, double ad_8) {
   int li_ret_24;
   double ld_16 = 0;
   for (gi_1084 = 1; gi_1084 <= ai_4; gi_1084++) {
      if (ld_16 <= gda_996[gi_928][ai_0][gi_1084] && ad_8 >= gda_996[gi_928][ai_0][gi_1084]) {
         ld_16 = gda_996[gi_928][ai_0][gi_1084];
         li_ret_24 = gi_1084;
      }
   }
   return (li_ret_24);
}

void f0_7() {
   gia_1032[gi_928] = 0;
   gia_1036[gi_928] = 0;
   gia_1040[gi_928] = 0;
   gia_1044[gi_928] = 0;
   int count_0 = 0;
   int count_4 = 0;
   int count_8 = 0;
   int count_12 = 0;
   int count_16 = 0;
   int count_20 = 0;
   gda_1024[gi_928][0] = 0;
   gda_1024[gi_928][1] = 0;
   gda_1024[gi_928][2] = 0;
   gda_1024[gi_928][3] = 0;
   gda_1028[gi_928][0] = 0;
   gda_1028[gi_928][1] = 0;
   g_order_total_1072 = OrdersTotal();
   for (g_pos_1064 = 0; g_pos_1064 < g_order_total_1072; g_pos_1064++) {
      OrderSelect(g_pos_1064, SELECT_BY_POS, MODE_TRADES);
      if (OrderType() == OP_BUY && OrderMagicNumber() == gia_956[gi_928] && OrderSymbol() == gsa_936[gi_928]) {
         count_0++;
         gia_1004[gi_928][0][count_0] = OrderTicket();
         gda_996[gi_928][0][count_0] = OrderOpenPrice();
         gda_992[gi_928][0][count_0] = OrderLots();
         gda_1000[gi_928][0][count_0] = OrderProfit();
         gda_1008[gi_928][0][count_0] = OrderTakeProfit();
         gda_1012[gi_928][0][count_0] = OrderStopLoss();
         gda_1028[gi_928][0] += gda_1000[gi_928][0][count_0];
         gda_1024[gi_928][0] += gda_992[gi_928][0][count_0];
         if (gda_1012[gi_928][0][count_0] > 0.0) count_8++;
      }
      if (OrderType() == OP_SELL && OrderMagicNumber() == gia_956[gi_928] && OrderSymbol() == gsa_936[gi_928]) {
         count_4++;
         gia_1004[gi_928][1][count_4] = OrderTicket();
         gda_996[gi_928][1][count_4] = OrderOpenPrice();
         gda_992[gi_928][1][count_4] = OrderLots();
         gda_1000[gi_928][1][count_4] = OrderProfit();
         gda_1008[gi_928][1][count_4] = OrderTakeProfit();
         gda_1012[gi_928][1][count_4] = OrderStopLoss();
         gda_1028[gi_928][1] += gda_1000[gi_928][1][count_4];
         gda_1024[gi_928][1] += gda_992[gi_928][1][count_4];
         if (gda_1012[gi_928][1][count_4] > 0.0) count_12++;
      }
      if (OrderType() == OP_BUYSTOP && OrderMagicNumber() == gia_956[gi_928] && OrderSymbol() == gsa_936[gi_928]) {
         count_16++;
         gia_1004[gi_928][2][count_16] = OrderTicket();
         gda_996[gi_928][2][count_16] = OrderOpenPrice();
         gda_1008[gi_928][2][count_16] = OrderTakeProfit();
         gda_1012[gi_928][2][count_16] = OrderStopLoss();
         gda_992[gi_928][2][count_16] = OrderLots();
         gda_1024[gi_928][2] += gda_992[gi_928][2][count_16];
      }
      if (OrderType() == OP_SELLSTOP && OrderMagicNumber() == gia_956[gi_928] && OrderSymbol() == gsa_936[gi_928]) {
         count_20++;
         gda_996[gi_928][3][count_20] = OrderOpenPrice();
         gia_1004[gi_928][3][count_20] = OrderTicket();
         gda_1008[gi_928][3][count_20] = OrderTakeProfit();
         gda_1012[gi_928][3][count_20] = OrderStopLoss();
         gda_992[gi_928][3][count_20] = OrderLots();
         gda_1024[gi_928][3] += gda_992[gi_928][3][count_20];
      }
   }
   gia_1032[gi_928] = count_0;
   gia_1036[gi_928] = count_4;
   gia_1048[gi_928] = count_8;
   gia_1052[gi_928] = count_12;
   gia_1040[gi_928] = count_16;
   gia_1044[gi_928] = count_20;
}

void f0_12() {
   double ld_0 = f0_8(0);
   string name_8 = gs_80 + "1";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 15);
   }
   ObjectSetText(name_8, "Заработок сегодня: " + DoubleToStr(ld_0, 2), g_fontsize_660, "Courier New", g_color_664);
   ld_0 = f0_8(1);
   name_8 = gs_80 + "2";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 33);
   }
   ObjectSetText(name_8, "Заработок вчера: " + DoubleToStr(ld_0, 2), g_fontsize_660, "Courier New", g_color_664);
   ld_0 = f0_8(2);
   name_8 = gs_80 + "3";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 51);
   }
   ObjectSetText(name_8, "Заработок позавчера: " + DoubleToStr(ld_0, 2), g_fontsize_660, "Courier New", g_color_664);
   name_8 = gs_80 + "4";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 76);
   }
   ObjectSetText(name_8, "Баланс : " + DoubleToStr(AccountBalance(), 2), g_fontsize_660, "Courier New", g_color_664);
   if (Min_Proc_Sv_Sr > 0.0 && Min_Proc_Sv_Sr < 100.0) {
      name_8 = gs_80 + "5";
      if (ObjectFind(name_8) == -1) {
         ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
         ObjectSet(name_8, OBJPROP_CORNER, 1);
         ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
         ObjectSet(name_8, OBJPROP_YDISTANCE, 96);
      }
      ObjectSetText(name_8, "Своб. средства: " + DoubleToStr(AccountFreeMargin(), 2), g_fontsize_660, "Courier New", g_color_680);
      name_8 = gs_80 + "6";
      if (ObjectFind(name_8) == -1) {
         ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
         ObjectSet(name_8, OBJPROP_CORNER, 1);
         ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
         ObjectSet(name_8, OBJPROP_YDISTANCE, 116);
      }
      ObjectSetText(name_8, "Контр. уровень: " + DoubleToStr(gd_772, 2), g_fontsize_660, "Courier New", g_color_664);
   }
}

void f0_9() {
   string name_0 = gs_80 + "L_1";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 390);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 10);
   }
   ObjectSetText(name_0, "F O R E X", 28, "Arial", DarkTurquoise);
   name_0 = gs_80 + "L_2";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 382);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 50);
   }
   ObjectSetText(name_0, "I  N  V  E  S  T  O  R", 16, "Arial", Gold);
   name_0 = gs_80 + "L_3";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 397);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 75);
   }
   ObjectSetText(name_0, "www.forex-investor.net", 12, "Arial", g_color_676);
   name_0 = gs_80 + "L_4";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 382);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 57);
   }
   ObjectSetText(name_0, "_____________________", 12, "Arial", Gray);
   name_0 = gs_80 + "L_5";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 382);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 76);
   }
   ObjectSetText(name_0, "_____________________", 12, "Arial", Gray);
}

double f0_8(int ai_0) {
   double ld_ret_4 = 0;
   for (int pos_12 = 0; pos_12 < OrdersHistoryTotal(); pos_12++) {
      if (!(OrderSelect(pos_12, SELECT_BY_POS, MODE_HISTORY))) break;
      if (OrderSymbol() == gsa_936[gi_928] && OrderMagicNumber() == gia_956[0] || OrderMagicNumber() == gia_956[1] || OrderMagicNumber() == gia_956[2])
         if (OrderCloseTime() >= iTime(gsa_936[gi_928], PERIOD_D1, ai_0) && OrderCloseTime() < iTime(gsa_936[gi_928], PERIOD_D1, ai_0) + 86400) ld_ret_4 = ld_ret_4 + OrderProfit() + OrderCommission() + OrderSwap();
   }
   return (ld_ret_4);
}

double f0_16(int ai_0, int ai_4) {
   double ld_ret_8;
   double ld_16 = 0;
   double ld_24 = 0;
   for (gi_1084 = 1; gi_1084 < ai_4; gi_1084++) {
      ld_16 += gda_996[gi_928][ai_0][gi_1084] * gda_992[gi_928][ai_0][gi_1084];
      ld_24 += gda_992[gi_928][ai_0][gi_1084];
   }
   if (ai_0 == 0) ld_ret_8 = (ld_16 - ld_24 * (gda_996[gi_928][ai_0][ai_4] - gi_192 * Point)) / (gi_192 * Point);
   if (ai_0 == 1) ld_ret_8 = (ld_24 * (gda_996[gi_928][ai_0][ai_4] + gi_192 * Point) - ld_16) / (gi_192 * Point);
   return (ld_ret_8);
}

double f0_13(int ai_0, int ai_4) {
   double ld_ret_8;
   double ld_16 = 0;
   double ld_24 = 0;
   ld_16 += gda_996[gi_928][ai_0][1] * gda_992[gi_928][ai_0][1];
   ld_24 += gda_992[gi_928][ai_0][1];
   if (ai_0 == 0) ld_ret_8 = (ld_16 - ld_24 * (gda_996[gi_928][ai_0][ai_4] - gi_192 * Point)) / (gi_192 * Point);
   if (ai_0 == 1) ld_ret_8 = (ld_24 * (gda_996[gi_928][ai_0][ai_4] + gi_192 * Point) - ld_16) / (gi_192 * Point);
   return (ld_ret_8);
}

double f0_15(int ai_0, int ai_4) {
   double ld_ret_8;
   double ld_16 = 0;
   double ld_24 = 0;
   ld_16 += gda_996[gi_928][ai_0][ai_4 - 1] * gda_992[gi_928][ai_0][ai_4 - 1];
   ld_24 += gda_992[gi_928][ai_0][ai_4 - 1];
   if (ai_0 == 0) ld_ret_8 = (ld_16 - ld_24 * (gda_996[gi_928][ai_0][ai_4] - gi_192 * Point)) / (gi_192 * Point);
   if (ai_0 == 1) ld_ret_8 = (ld_24 * (gda_996[gi_928][ai_0][ai_4] + gi_192 * Point) - ld_16) / (gi_192 * Point);
   return (ld_ret_8);
}

void f0_6() {
   if (Mode_SL_inst > 0) {
      if (LogotipOn && PercentProf_from_OTBOY == 0.0 || Mode_enable_OTBOY == 0) {
         Comment("\n", 
            "\n", 
            "\n", 
            "\n", 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                           ", gs_92, 
            "\n", "                          Режим работы: ", gsa_88[gi_928], 
            "\n", "                          Тип сигнала - ", gs_244, gs_444, 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          BUY  : ", DoubleToStr(gda_1024[0][0], 2), " (", gia_1032[0], ")     SL_all_BUY : ", DoubleToStr(g_price_572, Digits), 
            "\n", "                          SELL : ", DoubleToStr(gda_1024[0][1], 2), " (", gia_1036[0], ")     SL_all_SELL : ", DoubleToStr(g_price_580, Digits), 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          LotDisbalance : ", DoubleToStr(gda_1024[0][0] - gda_1024[0][1], 2), 
            "\n", "                          Возможные потери : ", DoubleToStr(gd_564, 2), 
            "\n", "                        ------------------------------------------------------------", 
         "\n");
      }
      if (LogotipOn && PercentProf_from_OTBOY > 0.0 && Mode_enable_OTBOY > 0) {
         Comment("\n", 
            "\n", 
            "\n", 
            "\n", 
            "\n", "                       +-------------------------------------------------------+", 
            "\n", "                           ", gs_92, 
            "\n", "                          Режим работы: ", gsa_88[gi_928], 
            "\n", "                          Тип сигнала - ", gs_244, gs_444, 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          BUY  : ", DoubleToStr(gda_1024[0][0], 2), " (", gia_1032[0], ")     SL_all_BUY : ", DoubleToStr(g_price_572, Digits), 
            "\n", "                          SELL : ", DoubleToStr(gda_1024[0][1], 2), " (", gia_1036[0], ")     SL_all_SELL : ", DoubleToStr(g_price_580, Digits), 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          LotDisbalance : ", DoubleToStr(gda_1024[0][0] - gda_1024[0][1], 2), 
            "\n", "                          Возможные потери : ", DoubleToStr(gd_564, 2), 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          просадка 1-го BUY  = ", gda_1000[0][0][1], 
            "\n", "                          просадка 1-го SELL = ", gda_1000[0][1][1], 
            "\n", "                          Средства на защиту = ", gd_780, 
            "\n", "                        ------------------------------------------------------------", 
         "\n");
      }
      if (LogotipOn == FALSE && PercentProf_from_OTBOY == 0.0 || Mode_enable_OTBOY == 0 && Min_Proc_Sv_Sr > 0.0 && Min_Proc_Sv_Sr < 100.0) {
         Comment("\n", 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                        ShockBar v.1.2 (www.forex-investor.net) ", 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                           ", gs_92, 
            "\n", "                          Режим работы: ", gsa_88[gi_928], 
            "\n", "                          Тип сигнала - ", gs_244, gs_444, 
            "\n", "                          BUY  : ", DoubleToStr(gda_1024[0][0], 2), " (", gia_1032[0], ")     SL_all_BUY : ", DoubleToStr(g_price_572, Digits), 
            "\n", "                          SELL : ", DoubleToStr(gda_1024[0][1], 2), " (", gia_1036[0], ")     SL_all_SELL : ", DoubleToStr(g_price_580, Digits), 
            "\n", "                          LotDisbalance : ", DoubleToStr(gda_1024[0][0] - gda_1024[0][1], 2), 
            "\n", "                          Возможные потери : ", DoubleToStr(gd_564, 2), 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          ЗАРАБОТОК : ", 
            "\n", "                          - СЕГОДНЯ     : ", DoubleToStr(f0_8(0), 2), 
            "\n", "                          - ВЧЕРА          : ", DoubleToStr(f0_8(1), 2), 
            "\n", "                          - ПОЗАВЧЕРА : ", DoubleToStr(f0_8(2), 2), 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          БАЛАНС     : ", AccountBalance(), 
            "\n", "                          Своб.Ср.   : ", AccountFreeMargin(), 
            "\n", "                          Контр.Ур.  : ", gd_772, 
            "\n", "                        ------------------------------------------------------------", 
         "\n");
      }
      if (LogotipOn == FALSE && PercentProf_from_OTBOY > 0.0 && Mode_enable_OTBOY > 0 && Min_Proc_Sv_Sr > 0.0 && Min_Proc_Sv_Sr < 100.0) {
         Comment("\n", 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                        ShockBar v.1.2 (www.forex-investor.net) ", 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                           ", gs_92, 
            "\n", "                          Режим работы: ", gsa_88[gi_928], 
            "\n", "                          Тип сигнала - ", gs_244, gs_444, 
            "\n", "                          BUY  : ", DoubleToStr(gda_1024[0][0], 2), " (", gia_1032[0], ")     SL_all_BUY : ", DoubleToStr(g_price_572, Digits), 
            "\n", "                          SELL : ", DoubleToStr(gda_1024[0][1], 2), " (", gia_1036[0], ")     SL_all_SELL : ", DoubleToStr(g_price_580, Digits), 
            "\n", "                          LotDisbalance : ", DoubleToStr(gda_1024[0][0] - gda_1024[0][1], 2), 
            "\n", "                          Возможные потери : ", DoubleToStr(gd_564, 2), 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          ЗАРАБОТОК : ", 
            "\n", "                          - СЕГОДНЯ     : ", DoubleToStr(f0_8(0), 2), 
            "\n", "                          - ВЧЕРА          : ", DoubleToStr(f0_8(1), 2), 
            "\n", "                          - ПОЗАВЧЕРА : ", DoubleToStr(f0_8(2), 2), 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          Своб.Ср.   : ", AccountFreeMargin(), 
            "\n", "                          Контр.Ур.  : ", gd_772, 
            "\n", "                          Средства на защиту = ", gd_780, 
            "\n", "                        ------------------------------------------------------------", 
         "\n");
      }
      if (LogotipOn == FALSE && PercentProf_from_OTBOY == 0.0 || Mode_enable_OTBOY == 0 && Min_Proc_Sv_Sr == 0.0) {
         Comment("\n", 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                        ShockBar v.1.2 (www.forex-investor.net) ", 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                           ", gs_92, 
            "\n", "                          Режим работы: ", gsa_88[gi_928], 
            "\n", "                          Тип сигнала - ", gs_244, gs_444, 
            "\n", "                          BUY  : ", DoubleToStr(gda_1024[0][0], 2), " (", gia_1032[0], ")     SL_all_BUY : ", DoubleToStr(g_price_572, Digits), 
            "\n", "                          SELL : ", DoubleToStr(gda_1024[0][1], 2), " (", gia_1036[0], ")     SL_all_SELL : ", DoubleToStr(g_price_580, Digits), 
            "\n", "                          LotDisbalance : ", DoubleToStr(gda_1024[0][0] - gda_1024[0][1], 2), 
            "\n", "                          Возможные потери : ", DoubleToStr(gd_564, 2), 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          ЗАРАБОТОК : ", 
            "\n", "                          - СЕГОДНЯ     : ", DoubleToStr(f0_8(0), 2), 
            "\n", "                          - ВЧЕРА          : ", DoubleToStr(f0_8(1), 2), 
            "\n", "                          - ПОЗАВЧЕРА : ", DoubleToStr(f0_8(2), 2), 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          БАЛАНС     : ", AccountBalance(), 
            "\n", "                        ------------------------------------------------------------", 
         "\n");
      }
      if (LogotipOn == FALSE && PercentProf_from_OTBOY > 0.0 && Mode_enable_OTBOY > 0 && Min_Proc_Sv_Sr == 0.0) {
         Comment("\n", 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                        ShockBar v.1.2 (www.forex-investor.net) ", 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                           ", gs_92, 
            "\n", "                          Режим работы: ", gsa_88[gi_928], 
            "\n", "                          Тип сигнала - ", gs_244, gs_444, 
            "\n", "                          BUY  : ", DoubleToStr(gda_1024[0][0], 2), " (", gia_1032[0], ")     SL_all_BUY : ", DoubleToStr(g_price_572, Digits), 
            "\n", "                          SELL : ", DoubleToStr(gda_1024[0][1], 2), " (", gia_1036[0], ")     SL_all_SELL : ", DoubleToStr(g_price_580, Digits), 
            "\n", "                          LotDisbalance : ", DoubleToStr(gda_1024[0][0] - gda_1024[0][1], 2), 
            "\n", "                          Возможные потери : ", DoubleToStr(gd_564, 2), 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          ЗАРАБОТОК : ", 
            "\n", "                          - СЕГОДНЯ     : ", DoubleToStr(f0_8(0), 2), 
            "\n", "                          - ВЧЕРА          : ", DoubleToStr(f0_8(1), 2), 
            "\n", "                          - ПОЗАВЧЕРА : ", DoubleToStr(f0_8(2), 2), 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          Средства на защиту = ", gd_780, 
            "\n", "                        ------------------------------------------------------------", 
         "\n");
      }
   }
   if (Mode_SL_inst == 0) {
      if (LogotipOn && PercentProf_from_OTBOY == 0.0 || Mode_enable_OTBOY == 0) {
         Comment("\n", 
            "\n", 
            "\n", 
            "\n", 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                           ", gs_92, 
            "\n", "                          Режим работы: ", gsa_88[gi_928], 
            "\n", "                          Тип сигнала - ", gs_244, gs_444, 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          BUY  : ", DoubleToStr(gda_1024[0][0], 2), " (", gia_1032[0], ")", 
            "\n", "                          SELL : ", DoubleToStr(gda_1024[0][1], 2), " (", gia_1036[0], ")", 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          LotDisbalance : ", DoubleToStr(gda_1024[0][0] - gda_1024[0][1], 2), 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          Своб.Ср.   : ", AccountFreeMargin(), 
            "\n", "                        ------------------------------------------------------------", 
         "\n");
      }
      if (LogotipOn && PercentProf_from_OTBOY > 0.0 && Mode_enable_OTBOY > 0) {
         Comment("\n", 
            "\n", 
            "\n", 
            "\n", 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                           ", gs_92, 
            "\n", "                          Режим работы: ", gsa_88[gi_928], 
            "\n", "                          Тип сигнала - ", gs_244, gs_444, 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          BUY  : ", DoubleToStr(gda_1024[0][0], 2), " (", gia_1032[0], ")", 
            "\n", "                          SELL : ", DoubleToStr(gda_1024[0][1], 2), " (", gia_1036[0], ")", 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          LotDisbalance : ", DoubleToStr(gda_1024[0][0] - gda_1024[0][1], 2), 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          просадка 1-го BUY  = ", gda_1000[0][0][1], 
            "\n", "                          просадка 1-го SELL = ", gda_1000[0][1][1], 
            "\n", "                          Средства на защиту = ", gd_780, 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          Своб.Ср.   : ", AccountFreeMargin(), 
            "\n", "                        ------------------------------------------------------------", 
         "\n");
      }
      if (LogotipOn == FALSE && PercentProf_from_OTBOY == 0.0 || Mode_enable_OTBOY == 0 && Min_Proc_Sv_Sr > 0.0 && Min_Proc_Sv_Sr < 100.0) {
         Comment("\n", 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                        ShockBar v.1.2 (www.forex-investor.net) ", 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                           ", gs_92, 
            "\n", "                          Режим работы: ", gsa_88[gi_928], 
            "\n", "                          Тип сигнала - ", gs_244, gs_444, 
            "\n", "                          BUY  : ", DoubleToStr(gda_1024[0][0], 2), " (", gia_1032[0], ")", 
            "\n", "                          SELL : ", DoubleToStr(gda_1024[0][1], 2), " (", gia_1036[0], ")", 
            "\n", "                          LotDisbalance : ", DoubleToStr(gda_1024[0][0] - gda_1024[0][1], 2), 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          ЗАРАБОТОК : ", 
            "\n", "                          - СЕГОДНЯ     : ", DoubleToStr(f0_8(0), 2), 
            "\n", "                          - ВЧЕРА          : ", DoubleToStr(f0_8(1), 2), 
            "\n", "                          - ПОЗАВЧЕРА : ", DoubleToStr(f0_8(2), 2), 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          Своб.Ср.   : ", AccountFreeMargin(), 
            "\n", "                          Контр.Ур.  : ", gd_772, 
            "\n", "                        ------------------------------------------------------------", 
         "\n");
      }
      if (LogotipOn == FALSE && PercentProf_from_OTBOY > 0.0 && Mode_enable_OTBOY > 0 && Min_Proc_Sv_Sr > 0.0 && Min_Proc_Sv_Sr < 100.0) {
         Comment("\n", 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                        ShockBar v.1.2 (www.forex-investor.net) ", 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                           ", gs_92, 
            "\n", "                          Режим работы: ", gsa_88[gi_928], 
            "\n", "                          Тип сигнала - ", gs_244, gs_444, 
            "\n", "                          BUY  : ", DoubleToStr(gda_1024[0][0], 2), " (", gia_1032[0], ")", 
            "\n", "                          SELL : ", DoubleToStr(gda_1024[0][1], 2), " (", gia_1036[0], ")", 
            "\n", "                          LotDisbalance : ", DoubleToStr(gda_1024[0][0] - gda_1024[0][1], 2), 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          ЗАРАБОТОК : ", 
            "\n", "                          - СЕГОДНЯ     : ", DoubleToStr(f0_8(0), 2), 
            "\n", "                          - ВЧЕРА          : ", DoubleToStr(f0_8(1), 2), 
            "\n", "                          - ПОЗАВЧЕРА : ", DoubleToStr(f0_8(2), 2), 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          Своб.Ср.   : ", AccountFreeMargin(), 
            "\n", "                          Контр.Ур.  : ", gd_772, 
            "\n", "                          Средства на защиту = ", gd_780, 
            "\n", "                        ------------------------------------------------------------", 
         "\n");
      }
      if (LogotipOn == FALSE && PercentProf_from_OTBOY == 0.0 || Mode_enable_OTBOY == 0 && Min_Proc_Sv_Sr == 0.0) {
         Comment("\n", 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                        ShockBar v.1.2 (www.forex-investor.net) ", 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                           ", gs_92, 
            "\n", "                          Режим работы: ", gsa_88[gi_928], 
            "\n", "                          Тип сигнала - ", gs_244, gs_444, 
            "\n", "                          BUY  : ", DoubleToStr(gda_1024[0][0], 2), " (", gia_1032[0], ")", 
            "\n", "                          SELL : ", DoubleToStr(gda_1024[0][1], 2), " (", gia_1036[0], ")", 
            "\n", "                          LotDisbalance : ", DoubleToStr(gda_1024[0][0] - gda_1024[0][1], 2), 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          ЗАРАБОТОК : ", 
            "\n", "                          - СЕГОДНЯ     : ", DoubleToStr(f0_8(0), 2), 
            "\n", "                          - ВЧЕРА          : ", DoubleToStr(f0_8(1), 2), 
            "\n", "                          - ПОЗАВЧЕРА : ", DoubleToStr(f0_8(2), 2), 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          БАЛАНС     : ", AccountBalance(), 
            "\n", "                          Своб.Ср.   : ", AccountFreeMargin(), 
            "\n", "                        ------------------------------------------------------------", 
         "\n");
      }
      if (LogotipOn == FALSE && PercentProf_from_OTBOY > 0.0 && Mode_enable_OTBOY > 0 && Min_Proc_Sv_Sr == 0.0) {
         Comment("\n", 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                        ShockBar v.1.2 (www.forex-investor.net) ", 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                           ", gs_92, 
            "\n", "                          Режим работы: ", gsa_88[gi_928], 
            "\n", "                          Тип сигнала - ", gs_244, gs_444, 
            "\n", "                          BUY  : ", DoubleToStr(gda_1024[0][0], 2), " (", gia_1032[0], ")", 
            "\n", "                          SELL : ", DoubleToStr(gda_1024[0][1], 2), " (", gia_1036[0], ")", 
            "\n", "                          LotDisbalance : ", DoubleToStr(gda_1024[0][0] - gda_1024[0][1], 2), 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          ЗАРАБОТОК : ", 
            "\n", "                          - СЕГОДНЯ     : ", DoubleToStr(f0_8(0), 2), 
            "\n", "                          - ВЧЕРА          : ", DoubleToStr(f0_8(1), 2), 
            "\n", "                          - ПОЗАВЧЕРА : ", DoubleToStr(f0_8(2), 2), 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          БАЛАНС     : ", AccountBalance(), 
            "\n", "                          Своб.Ср.   : ", AccountFreeMargin(), 
            "\n", "                        ------------------------------------------------------------", 
            "\n", "                          Средства на защиту = ", gd_780, 
            "\n", "                        ------------------------------------------------------------", 
         "\n");
      }
   }
}