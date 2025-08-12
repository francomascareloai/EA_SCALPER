
#property copyright "exness@gawab.com"
#property link      "exness@gawab.com"

bool gi_76 = TRUE;
bool gi_80 = TRUE;
extern bool custom_balance = FALSE;
extern double balance = 10000.0;
extern bool ema_filter = FALSE;
extern int ema_period = 60;
extern int ema_tf = 5;
extern bool auto_tf_settings = FALSE;
bool gi_112 = FALSE;
bool gi_116 = TRUE;
extern bool auto_trade_at_cross = TRUE;
extern bool trade_at_the_cross_only = FALSE;
extern string parabolic_sar = "//////parabolic stop and reverse////////////////";
extern bool open_with_tc = TRUE;
extern bool close_with_tc = FALSE;
extern bool use_tc_hedge = TRUE;
extern double psar = 0.003;
extern double max = 0.2;
extern int time_frame_for_signal = 30;
extern string parabolic_sar_2 = "second parabolic stop and reverse//////////////";
extern bool open_with_tc2 = TRUE;
extern bool close_with_tc2 = FALSE;
extern bool use_tc2_hedge = FALSE;
extern double psar2 = 0.06;
extern double max2 = 0.2;
extern int time_frame_for_signal2 = 5;
extern bool reverse_second_tc_entry = TRUE;
extern bool reverse_second_tc_exits = TRUE;
bool gi_unused_216 = FALSE;
extern string money_management = "settings//////////////////////////////////// ";
extern bool manage_all_trades = TRUE;
extern double Maximum_Risk = 1.0;
extern double Lots = 0.01;
extern bool use_martingale = FALSE;
extern double multiplier = 20.0;
extern double Max_Lots_allowed = 50.0;
extern int mm_calculation = 10000;
extern int max_trades = 1000;
extern int limit_longs = 1000;
extern int limit_shorts = 1000;
extern bool close_trades_limit = TRUE;
extern int limit = 1000;
extern bool double_the_hedge = TRUE;
extern double hedge_plus = 1.0;
extern bool dis_dbl_hedge = FALSE;
extern double at_percent_profit = -6.0;
extern string taking_profit = "settings /////////////////////////////////";
extern double profit_target_percent = 0.5;
extern double equity_target = 1000.0;
extern double emergency_loss_protection = -10000.0;
extern bool breakeven = FALSE;
extern int BreakEven = 5000;
extern bool use_hidden_stop_loss = FALSE;
extern int hidden_sl = 10;
extern bool use_hidden_take_profit = FALSE;
extern int hidden_tp = 10;
extern bool trail = FALSE;
extern int TrailingStop = 10;
extern string high_low = "h/l filter//////////////////////////////";
extern bool hi_lo_filter = FALSE;
extern double h_l_tf = 240.0;
extern string pivot_filter1 = "one pivot/////////////////////////////// ";
extern bool one_pivot = FALSE;
extern int piv_period = 60;
extern double level = 50.0;
extern string pivot_filter2 = "all pivots//////////////////////////////";
extern bool auto_pivot = FALSE;
extern double orders = 20.0;
extern bool pivot_filter = FALSE;
extern int bars_back = 1;
extern bool show_piv_lines = TRUE;
extern string customize_the_pivot = "longs//////////// ";
extern double h1_tf = 60.0;
extern double h1 = 50.0;
extern double h4_tf = 240.0;
extern int h4 = 50;
extern double d1_tf = 1440.0;
extern int d1 = 50;
extern double w1_tf = 10080.0;
extern int w1 = 50;
extern double mn_tf = 43200.0;
extern int mn = 50;
extern string customize_the_pivot2 = "shorts/////////// ";
extern double h1_tfs = 60.0;
extern double h1s = 50.0;
extern double h4_tfs = 240.0;
extern int h4s = 50;
extern double d1_tfs = 1440.0;
extern int d1s = 50;
extern double w1_tfs = 10080.0;
extern int w1s = 50;
extern double mn_tfs = 43200.0;
extern int mns = 50;
extern bool pricefilter = TRUE;
extern bool patternsfilter = TRUE;
double gd_unused_624 = 0.0;
double gd_unused_632 = 0.0;
double gd_unused_640 = 0.0;
double gd_664;
int gi_unused_716 = -1;
int gi_unused_720 = 0;
int gi_unused_732 = 0;
int gi_unused_736 = 0;
int gi_unused_740 = 0;
int gi_unused_744 = 0;
int gi_unused_748 = 0;
int gi_unused_752 = 0;
bool gi_756 = TRUE;
bool gi_760 = TRUE;
bool gi_764 = FALSE;
int gi_unused_768 = -15;
bool gi_772 = FALSE;
string gs_unused_776 = "only effects current chart";
bool gi_784 = FALSE;
bool gi_788 = TRUE;
bool gi_792 = TRUE;
int gi_796 = 2;
double gd_800 = 0.0;
double gd_808 = 0.0;
double gd_816 = 0.0;
bool gi_824 = FALSE;
double gd_828 = 2.0;
double gd_unused_836 = 0.0;
double gd_unused_844 = 0.0;
bool gi_852 = FALSE;
string gs_unused_856 = "equity closses trades globally";
bool gi_864 = FALSE;
bool gi_868 = FALSE;
bool gi_872 = FALSE;
double gd_876 = -5.0;
double gd_884 = 0.0;
string gs_unused_892 = "only effects current chart";
bool gi_900 = FALSE;
double gd_904 = 1.99;
bool gi_912 = FALSE;
double gd_916 = 75.0;
string gs_unused_924 = "//////envelopes hedge";
bool gi_932 = FALSE;
int g_period_936 = 50;
double g_deviation_940 = 0.1;
int g_timeframe_948 = PERIOD_M15;
extern string env4 = "//////envelopes";
extern bool open_with_envelopes = TRUE;
extern bool close_with_envelopes = FALSE;
extern string env2 = "buy options";
extern int envelopes_period_buy = 2;
extern int apply_to_buy = 3;
extern int apply_to_close_buy = 2;
extern double buy = 0.01;
extern double close_buy = 0.01;
extern bool open_buy_upper_line = FALSE;
extern bool exit_buy_upper_line = TRUE;
extern bool open_buy_lower_line = TRUE;
extern bool exit_buy_lower_line = FALSE;
extern string env3 = "sell options";
bool gi_unused_1028 = FALSE;
bool gi_unused_1032 = FALSE;
bool gi_unused_1036 = FALSE;
bool gi_unused_1040 = FALSE;
bool gi_unused_1044 = FALSE;
bool gi_unused_1048 = FALSE;
bool gi_unused_1052 = FALSE;
bool gi_unused_1056 = FALSE;
bool gi_unused_1060 = FALSE;
bool gi_unused_1064 = FALSE;
bool gi_1068 = FALSE;
bool gi_1072 = FALSE;
bool gi_1076 = FALSE;
bool gi_1080 = FALSE;
bool gi_1084 = FALSE;
bool gi_1088 = FALSE;
bool gi_1092 = FALSE;
bool gi_1096 = FALSE;
extern int envelopes_period_sell = 2;
extern int apply_to_sell = 2;
extern int apply_to_close_sell = 3;
extern double sell = 0.01;
extern double close_sell = 0.01;
extern int time_frame_for_env = 0;
extern bool open_sell_upper_line = TRUE;
extern bool exit_sell_upper_line = FALSE;
extern bool open_sell_lower_line = FALSE;
extern bool exit_sell_lower_line = TRUE;
string gs_unused_1148 = "average_true_range";
bool gi_1156 = FALSE;
bool gi_1160 = FALSE;
int g_period_1164 = 5;
double gd_1168 = 0.0009;
int g_timeframe_1176 = PERIOD_M15;
string gs_unused_1180 = "activate ma hedge";
bool gi_1188 = FALSE;
double gd_1192 = 75.0;
string gs_unused_1200 = "stop trading excluding hedges";
bool gi_1208 = FALSE;
double gd_1212 = 75.0;
string gs_unused_1220 = "close profit trades";
bool gi_1228 = FALSE;
double gd_1232 = 5.0;
int gi_unused_1240 = 40;
int gi_1244 = 20;
string gs_unused_1248 = "trail profit trades";
bool gi_1256 = FALSE;
double gd_1260 = 40.0;
bool gi_1268 = FALSE;
double gd_1272 = -50.0;
bool gi_1280 = FALSE;
double gd_1284 = -50.0;
string gs_unused_1292 = "close all trades";
bool gi_1300 = FALSE;
double gd_1304 = -80.0;
string gs_unused_1312 = "activate breakeven";
bool gi_1320 = FALSE;
int gi_1324 = 100;
string gs_unused_1328 = "moving averages";
bool gi_1336 = FALSE;
bool gi_1340 = FALSE;
string gs_unused_1344 = "moving average one";
int g_period_1352 = 200;
int gi_1356 = 0;
int g_ma_method_1360 = MODE_SMA;
int g_applied_price_1364 = PRICE_CLOSE;
string gs_unused_1368 = "moving average two";
int g_period_1376 = 50;
int gi_1380 = 0;
int g_ma_method_1384 = MODE_SMA;
int g_applied_price_1388 = PRICE_CLOSE;
bool gi_unused_1392 = FALSE;
bool gi_unused_1396 = TRUE;
int gi_unused_1400 = 99;
extern string trading_time = "///////////////////////////////////////////";
extern bool dont_restrict_hedge = TRUE;
extern bool UseHourTrade_longs = FALSE;
extern int FromHourTrade_longs = 5;
extern int ToHourTrade_longs = 9;
extern bool UseHourTrade_shorts = FALSE;
extern int FromHourTrade_shorts = 5;
extern int ToHourTrade_shorts = 9;
extern bool UseHourTrade = FALSE;
extern int FromHourTrade = 5;
extern int ToHourTrade = 9;
extern bool close_all_trades_at_time = FALSE;
extern int CloseHour = 21;
extern int CloseMinute = 0;
bool gi_1464 = TRUE;
bool gi_1468 = TRUE;
int gi_1472 = 5000;
int gi_1476 = 1;
int gi_1480 = 1;
bool gi_1484 = FALSE;
int gi_1488 = 10;
int gi_1492 = 20;
int gi_1496 = 30;
int gi_1500 = 5000;
bool gi_1504 = FALSE;
int gi_1508 = 10;
int gi_1512 = 20;
int gi_1516 = 30;
extern string alerts = "notification options//////////////////////////////////";
extern bool Use_popup_and_sound_alert = FALSE;
extern bool Use_Sound_only = FALSE;
extern bool email_notification = FALSE;
extern bool comments = TRUE;
bool gi_1544 = FALSE;
string gs_unused_1548 = "none";
string gs_unused_1556 = "none";
string gs_unused_1564 = "none";
string gs_unused_1572 = "none";
string gs_unused_1580 = "none";
string gs_unused_1588 = "none";
string gs_unused_1596 = "none";
string gs_unused_1604 = "none";
string gs_unused_1612 = "none";
string gs_unused_1620 = "none";
string gs_unused_1628 = "none";
string gs_unused_1636 = "none";
string gs_unused_1644 = "do not trade this pair";
string gs_unused_1652 = "2=buy 0=sell 1=no trade";
double gd_unused_1660 = 1.0;
bool gi_unused_1668 = FALSE;
double gd_1672 = 1.0;
double gd_unused_1680 = 0.0;
double gd_unused_1688 = 0.0;
double gd_unused_1696 = 0.0;
double gd_1704 = 0.0;
bool gi_1712 = FALSE;
bool gi_1716 = FALSE;
bool gi_1720 = FALSE;
bool gi_1724 = TRUE;
int g_count_1728 = 0;
int g_count_1732 = 0;
int gi_unused_1736 = 0;
int g_count_1740 = 0;
int g_count_1744 = 0;
int gi_unused_1748 = 0;
string gs_unused_1752 = "//////filter";
bool gi_unused_1760 = FALSE;
int g_period_1764 = 1;
double gd_1768 = 0.0;
int g_timeframe_1776 = 0;
string gs_1780 = "new alert from trendchaser";
string gs_1788 = "alert.wav";
bool gi_1796 = TRUE;
bool gi_unused_1800 = TRUE;
int gi_1804 = 1;
int gi_1808 = 0;
bool gi_1812 = FALSE;
bool gi_1816 = FALSE;
int gi_unused_1820 = 2;
bool gi_1824 = TRUE;
bool gi_1828 = TRUE;
bool gi_1832 = TRUE;
bool gi_1836 = TRUE;
int gi_1840 = 0;
bool gi_1844 = TRUE;
bool gi_1848 = TRUE;
bool gi_unused_1852 = FALSE;
bool gi_unused_1856 = FALSE;
int gi_unused_1860 = 21414;
bool gi_1864 = FALSE;
bool gi_1868 = FALSE;
string gs_1872 = "DRACULA FOREX EA";
string gs_1880 = "DRACULA FOREX EA";
string gs_unused_1888 = "0-Sunday,1,2,3,4,5,6";
string gs_gbpjpym_1896 = "GBPJPYm";
double g_lots_1904 = 0.01;
bool gi_1912 = FALSE;
bool gi_1916 = FALSE;
int gi_1920 = 0;
int gi_1924 = 0;
int gi_1928 = 0;
int gi_unused_1932 = 5000;
int gi_unused_1936 = 5000;
int g_magic_1940 = 95;
bool gi_unused_1944 = FALSE;
string gs_none_1948 = "none";
bool gi_unused_1956 = FALSE;
string gs_unused_1960 = "2012.05.01";
int gi_1968 = 0;
bool gi_1972 = FALSE;
int gi_1976 = 0;
int gi_1980 = 0;
int gi_unused_1984 = 0;
int gi_unused_1988 = 0;
int gi_1992 = 0;
int gi_unused_1996 = 0;
int gi_2000 = 0;
int gi_2004 = 0;
double gd_2008 = 0.0;
double gd_2016 = 0.0;
bool gi_2024 = TRUE;
bool gi_2028 = TRUE;
bool gi_2032 = TRUE;
string gs_unused_2036 = "standard fibs ";
bool gi_2044 = FALSE;
bool gi_2048 = FALSE;
bool gi_2052 = FALSE;
bool gi_2056 = FALSE;
bool gi_2060 = FALSE;
bool gi_2064 = FALSE;
double gd_unused_2068 = 0.01;
double g_lots_2076 = 0.01;
double gd_2084 = 0.0;
int gi_2092 = 0;
bool gi_2096 = FALSE;
bool gi_unused_2100 = FALSE;
bool gi_unused_2104 = FALSE;
bool gi_2108 = FALSE;
int g_bars_2112;
int gi_2116;
bool gi_2120 = FALSE;
int g_bars_2124;

double LotsOptimized() {
   string symbol_0 = Symbol();
   double lotstep_8 = MarketInfo(symbol_0, MODE_LOTSTEP);
   double minlot_16 = MarketInfo(symbol_0, MODE_MINLOT);
   double ld_ret_24 = Lots;
   int hist_total_32 = OrdersHistoryTotal();
   int li_36 = gi_2092;
   if (use_martingale == FALSE && lotstep_8 == 0.001) ld_ret_24 = NormalizeDouble(balance * Maximum_Risk / mm_calculation, 3);
   if (use_martingale && lotstep_8 == 0.001) ld_ret_24 = NormalizeDouble(balance * Maximum_Risk / mm_calculation * OrdersTotal() / multiplier, 3);
   if (use_martingale == FALSE && lotstep_8 == 0.01) ld_ret_24 = NormalizeDouble(balance * Maximum_Risk / mm_calculation, 2);
   if (use_martingale && lotstep_8 == 0.01) ld_ret_24 = NormalizeDouble(balance * Maximum_Risk / mm_calculation * OrdersTotal() / multiplier, 2);
   if (use_martingale == FALSE && lotstep_8 == 0.1) ld_ret_24 = NormalizeDouble(balance * Maximum_Risk / mm_calculation, 1);
   if (use_martingale && lotstep_8 == 0.1) ld_ret_24 = NormalizeDouble(balance * Maximum_Risk / mm_calculation * OrdersTotal() / multiplier, 1);
   if (gd_2084 > 0.0) {
      for (int pos_40 = hist_total_32 - 1; pos_40 >= 0; pos_40--) {
         if (OrderSelect(pos_40, SELECT_BY_POS, MODE_HISTORY) == FALSE) {
            Print("Error in history!");
            break;
         }
         if (OrderSymbol() != Symbol() || OrderType() > OP_SELL) continue;
         if (OrderProfit() > 0.0) break;
         if (OrderProfit() < 0.0) li_36++;
      }
      if (li_36 > 0) ld_ret_24 = NormalizeDouble(2.0 * ld_ret_24 + li_36 / gd_2084, 2);
   }
   if (ld_ret_24 < g_lots_2076) ld_ret_24 = Lots;
   if (ld_ret_24 > Max_Lots_allowed) ld_ret_24 = Max_Lots_allowed;
   return (ld_ret_24);
}

void hidden_take_profit() {
   bool ord_close_0;
   int ord_total_4 = OrdersTotal();
   for (int pos_8 = ord_total_4 - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS);
      ord_close_0 = FALSE;
      if (OrderSymbol() == Symbol()) {
         if (OrderType() == OP_BUY && OrderOpenPrice() + hidden_tp * Point <= Bid) ord_close_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
         if (OrderType() == OP_SELL && OrderOpenPrice() - hidden_tp * Point >= Ask) ord_close_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
      }
   }
}

void hidden_stop_loss() {
   bool ord_close_0;
   int ord_total_4 = OrdersTotal();
   for (int pos_8 = ord_total_4 - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS);
      ord_close_0 = FALSE;
      if (OrderSymbol() == Symbol()) {
         if (OrderType() == OP_BUY && OrderOpenPrice() - hidden_sl * Point >= Bid) ord_close_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
         if (OrderType() == OP_SELL && OrderOpenPrice() + hidden_sl * Point <= Ask) ord_close_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
      }
   }
}

void scale_take_profit() {
   bool ord_close_0;
   int ord_total_4 = OrdersTotal();
   for (int pos_8 = ord_total_4 - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS);
      ord_close_0 = FALSE;
      if (OrderSymbol() == Symbol()) {
         if (OrderType() == OP_BUY && OrderOpenPrice() + gi_1508 * Point <= Bid) ord_close_0 = OrderClose(OrderTicket(), OrderLots() / 3.0, MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
         if (OrderType() == OP_SELL && OrderOpenPrice() - gi_1508 * Point >= Ask) ord_close_0 = OrderClose(OrderTicket(), OrderLots() / 3.0, MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
      }
   }
}

void scale_take_profit2() {
   bool ord_close_0;
   int ord_total_4 = OrdersTotal();
   for (int pos_8 = ord_total_4 - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS);
      ord_close_0 = FALSE;
      if (OrderSymbol() == Symbol()) {
         if (OrderType() == OP_BUY && OrderOpenPrice() + gi_1512 * Point <= Bid) ord_close_0 = OrderClose(OrderTicket(), OrderLots() / 2.0, MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
         if (OrderType() == OP_SELL && OrderOpenPrice() - gi_1512 * Point >= Ask) ord_close_0 = OrderClose(OrderTicket(), OrderLots() / 2.0, MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
      }
   }
}

void scale_take_profit3() {
   bool ord_close_0;
   int ord_total_4 = OrdersTotal();
   for (int pos_8 = ord_total_4 - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS);
      ord_close_0 = FALSE;
      if (OrderSymbol() == Symbol()) {
         if (OrderType() == OP_BUY && OrderOpenPrice() + gi_1516 * Point <= Bid) ord_close_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
         if (OrderType() == OP_SELL && OrderOpenPrice() - gi_1516 * Point >= Ask) ord_close_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
      }
   }
}

void scale_stop_loss() {
   bool ord_close_0;
   int ord_total_4 = OrdersTotal();
   for (int pos_8 = ord_total_4 - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS);
      ord_close_0 = FALSE;
      if (OrderSymbol() == Symbol()) {
         if (OrderType() == OP_BUY && OrderOpenPrice() - gi_1488 * Point >= Bid) ord_close_0 = OrderClose(OrderTicket(), OrderLots() / 3.0, MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
         if (OrderType() == OP_SELL && OrderOpenPrice() + gi_1488 * Point <= Ask) ord_close_0 = OrderClose(OrderTicket(), OrderLots() / 3.0, MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
      }
   }
}

void scale_stop_loss2() {
   bool ord_close_0;
   int ord_total_4 = OrdersTotal();
   for (int pos_8 = ord_total_4 - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS);
      ord_close_0 = FALSE;
      if (OrderSymbol() == Symbol()) {
         if (OrderType() == OP_BUY && OrderOpenPrice() - gi_1492 * Point >= Bid) ord_close_0 = OrderClose(OrderTicket(), OrderLots() / 2.0, MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
         if (OrderType() == OP_SELL && OrderOpenPrice() + gi_1492 * Point <= Ask) ord_close_0 = OrderClose(OrderTicket(), OrderLots() / 2.0, MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
      }
   }
}

void scale_stop_loss3() {
   bool ord_close_0;
   int ord_total_4 = OrdersTotal();
   for (int pos_8 = ord_total_4 - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS);
      ord_close_0 = FALSE;
      if (OrderSymbol() == Symbol()) {
         if (OrderType() == OP_BUY && OrderOpenPrice() - gi_1496 * Point >= Bid) ord_close_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
         if (OrderType() == OP_SELL && OrderOpenPrice() + gi_1496 * Point <= Ask) ord_close_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
      }
   }
}

void Closelongs() {
   bool li_0;
   int ord_total_4 = OrdersTotal();
   for (int pos_8 = ord_total_4 - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS);
      li_0 = FALSE;
      if (OrderSymbol() == Symbol()) {
         if (OrderType() == OP_BUY) li_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
         if (OrderType() > OP_SELL) li_0 = OrderDelete(OrderTicket());
         RefreshRates();
         if (OrdersTotal() > 0) Closelongs();
      }
   }
}

void Closepending() {
   bool ord_delete_0;
   int ord_total_4 = OrdersTotal();
   for (int pos_8 = ord_total_4 - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS);
      ord_delete_0 = FALSE;
      if (OrderSymbol() == Symbol())
         if (OrderType() > OP_SELL) ord_delete_0 = OrderDelete(OrderTicket());
   }
}

void Closelongsinprofit() {
   bool ord_close_0;
   int ord_total_4 = OrdersTotal();
   for (int pos_8 = ord_total_4 - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS);
      ord_close_0 = FALSE;
      if (OrderSymbol() == Symbol()) {
         if (OrderProfit() == (-gi_1244) * LotsOptimized())
            if (OrderType() == OP_BUY) ord_close_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
      }
   }
}

void Closeshortsinprofit() {
   bool ord_close_0;
   int ord_total_4 = OrdersTotal();
   for (int pos_8 = ord_total_4 - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS);
      ord_close_0 = FALSE;
      if (OrderSymbol() == Symbol()) {
         if (OrderProfit() == (-gi_1244) * LotsOptimized())
            if (OrderType() == OP_SELL) ord_close_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
      }
   }
}

void Closeshorts() {
   bool ord_close_0;
   int ord_total_4 = OrdersTotal();
   for (int pos_8 = ord_total_4 - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS);
      ord_close_0 = FALSE;
      if (OrderSymbol() == Symbol())
         if (OrderType() == OP_SELL) ord_close_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
   }
}

void mClose_target() {
   bool ord_close_0;
   int ord_total_4 = OrdersTotal();
   for (int pos_8 = ord_total_4 - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS);
      ord_close_0 = FALSE;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == 99) {
         if (OrderSymbol() == Symbol() && OrderType() == OP_BUY) ord_close_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
         if (OrderSymbol() == Symbol() && OrderType() == OP_SELL) ord_close_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
         RefreshRates();
         if (gi_1968 > 0) mClose_target();
      }
   }
}

void Close_target() {
   bool ord_close_0;
   int ord_total_4 = OrdersTotal();
   for (int pos_8 = ord_total_4 - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS);
      ord_close_0 = FALSE;
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderType() == OP_BUY) ord_close_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
         if (OrderSymbol() == Symbol() && OrderType() == OP_SELL) ord_close_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
         RefreshRates();
         if (gi_1968 > 0) Close_target();
      }
   }
}

void Closeprofit() {
   bool ord_close_0;
   int ord_total_4 = OrdersTotal();
   for (int pos_8 = ord_total_4 - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS);
      ord_close_0 = FALSE;
      if (OrderSymbol() == Symbol()) {
         if (OrderProfit() > 0.0 && OrderSymbol() == Symbol() && OrderType() == OP_BUY) ord_close_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
         if (OrderProfit() > 0.0 && OrderSymbol() == Symbol() && OrderType() == OP_SELL) ord_close_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
      }
   }
}

void Closeppall() {
   bool ord_close_0;
   int ord_total_4 = OrdersTotal();
   for (int pos_8 = ord_total_4 - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS);
      ord_close_0 = FALSE;
      if (gi_1796) {
         if (OrderType() == OP_BUY) ord_close_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
         if (OrderType() == OP_SELL) ord_close_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
         RefreshRates();
         if (OrdersTotal() > 0) Closeppall();
      }
   }
}

void breakeven() {
   bool bool_472;
   int error_476;
   int li_unused_0 = 1;
   int li_unused_4 = 1;
   int li_unused_8 = 0;
   int li_unused_12 = 0;
   li_unused_0 = 0;
   li_unused_4 = 0;
   double close_16 = Close[1];
   double ld_24 = 5.0 * gd_664;
   double ld_32 = 10.0 * gd_664;
   double ld_40 = 50.0 * gd_664;
   double ld_48 = 110.0 * gd_664;
   double iclose_56 = iClose(NULL, PERIOD_H1, 1);
   double iclose_64 = iClose(NULL, PERIOD_H1, 2);
   double iclose_72 = iClose(NULL, PERIOD_H1, 3);
   double iclose_80 = iClose(NULL, PERIOD_H1, 4);
   double iclose_88 = iClose(NULL, PERIOD_H1, 5);
   double iclose_96 = iClose(NULL, PERIOD_H1, 6);
   double iclose_104 = iClose(NULL, PERIOD_H1, 7);
   double iclose_112 = iClose(NULL, PERIOD_H1, 8);
   double iclose_120 = iClose(NULL, PERIOD_H1, 9);
   double iclose_128 = iClose(NULL, PERIOD_H1, 10);
   double iclose_136 = iClose(NULL, PERIOD_H1, 11);
   double iclose_144 = iClose(NULL, PERIOD_H1, 12);
   double iclose_152 = iClose(NULL, PERIOD_H1, 13);
   double iopen_160 = iOpen(NULL, PERIOD_H1, 1);
   double iopen_168 = iOpen(NULL, PERIOD_H1, 2);
   double iopen_176 = iOpen(NULL, PERIOD_H1, 3);
   double iopen_184 = iOpen(NULL, PERIOD_H1, 4);
   double iopen_192 = iOpen(NULL, PERIOD_H1, 5);
   double iopen_200 = iOpen(NULL, PERIOD_H1, 6);
   double iopen_208 = iOpen(NULL, PERIOD_H1, 7);
   double iopen_216 = iOpen(NULL, PERIOD_H1, 8);
   double iopen_224 = iOpen(NULL, PERIOD_H1, 9);
   double iopen_232 = iOpen(NULL, PERIOD_H1, 10);
   double iopen_240 = iOpen(NULL, PERIOD_H1, 11);
   double iopen_248 = iOpen(NULL, PERIOD_H1, 12);
   double iopen_256 = iOpen(NULL, PERIOD_H1, 13);
   double ihigh_264 = iHigh(NULL, PERIOD_H1, 1);
   double ihigh_272 = iHigh(NULL, PERIOD_H1, 2);
   double ihigh_280 = iHigh(NULL, PERIOD_H1, 3);
   double ihigh_288 = iHigh(NULL, PERIOD_H1, 4);
   double ihigh_296 = iHigh(NULL, PERIOD_H1, 5);
   double ihigh_304 = iHigh(NULL, PERIOD_H1, 6);
   double ihigh_312 = iHigh(NULL, PERIOD_H1, 7);
   double ihigh_320 = iHigh(NULL, PERIOD_H1, 8);
   double ihigh_328 = iHigh(NULL, PERIOD_H1, 9);
   double ihigh_336 = iHigh(NULL, PERIOD_H1, 10);
   double ihigh_344 = iHigh(NULL, PERIOD_H1, 11);
   double ihigh_352 = iHigh(NULL, PERIOD_H1, 12);
   double ihigh_360 = iHigh(NULL, PERIOD_H1, 13);
   double ilow_368 = iLow(NULL, PERIOD_H1, 1);
   double ilow_376 = iLow(NULL, PERIOD_H1, 2);
   double ilow_384 = iLow(NULL, PERIOD_H1, 3);
   double ilow_392 = iLow(NULL, PERIOD_H1, 4);
   double ilow_400 = iLow(NULL, PERIOD_H1, 5);
   double ilow_408 = iLow(NULL, PERIOD_H1, 6);
   double ilow_416 = iLow(NULL, PERIOD_H1, 7);
   double ilow_424 = iLow(NULL, PERIOD_H1, 8);
   double ilow_432 = iLow(NULL, PERIOD_H1, 9);
   double ilow_440 = iLow(NULL, PERIOD_H1, 10);
   double ilow_448 = iLow(NULL, PERIOD_H1, 11);
   double ilow_456 = iLow(NULL, PERIOD_H1, 12);
   double ilow_464 = iLow(NULL, PERIOD_H1, 13);
   if ((pricefilter && close_16 > iclose_96 + 110.0 * gd_664) || (patternsfilter && (iclose_56 >= iclose_64 && iclose_56 >= iclose_72 && iopen_184 > iclose_80 && iclose_88 > iopen_192 &&
      iopen_184 - iclose_80 >= 50.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 < iclose_88 - iopen_192 && iclose_88 - iopen_192 < iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_72 - iopen_176 < 4.0 * (ihigh_280 - iclose_72) && iclose_64 - iopen_168 < 2.0 * (ihigh_272 - iclose_64) && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_88 - iopen_192 < iclose_80 - iopen_184 &&
      iclose_80 - iopen_184 < iclose_72 - iopen_176 && iclose_72 - iopen_176 > iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_64 - iopen_168 < 10.0 * (ihigh_272 - iclose_64) && iclose_56 - iopen_160 < 2.0 * (ihigh_264 - iclose_56)) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && iclose_88 - iopen_192 > 110.0 * gd_664 &&
      iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 >= iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && ihigh_296 > ihigh_288 &&
      ihigh_296 > ihigh_280 && ihigh_296 > ihigh_272 && ihigh_296 > ihigh_264 && ihigh_272 > ihigh_264 && ilow_400 < ihigh_288 && ilow_392 < ihigh_280 && ilow_384 < ihigh_272 &&
      ilow_368 < ihigh_272) || (iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_72 - iopen_176 <= 10.0 * gd_664 && iclose_64 - iopen_168 >= 50.0 * gd_664 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && iopen_160 - ilow_368 <= 5.0 * gd_664) ||
      (iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_80 - iopen_184 <= 10.0 * gd_664 && iclose_72 - iopen_176 >= 50.0 * gd_664 && ihigh_288 < ihigh_280 &&
      ihigh_280 < ihigh_272 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_88 - iopen_192 <= 10.0 * gd_664 && iclose_80 - iopen_184 >= 50.0 * gd_664 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && ihigh_272 < ihigh_280 &&
      ihigh_264 < ihigh_272) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_96 - iopen_200 <= 10.0 * gd_664 && iclose_88 - iopen_192 >= 50.0 * gd_664 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) ||
      (iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_104 - iopen_208 <= 10.0 * gd_664 && iclose_96 - iopen_200 >= 50.0 * gd_664 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && iopen_208 - ilow_416 <= 5.0 * gd_664 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 < ihigh_296 &&
      ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 >= iopen_168 && iclose_56 < iopen_160 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264) ||
      (iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392) ||
      (iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iopen_176 > iclose_72 && iopen_168 > iclose_64 && iclose_56 > iopen_160 &&
      ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368 && iclose_104 - ilow_416 <= 5.0 * gd_664 && iclose_96 - ilow_408 <= 5.0 * gd_664 &&
      ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iopen_168 <= 5.0 * gd_664 && ihigh_264 - iclose_56 <= 5.0 * gd_664) || (iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iopen_184 > iclose_80 && iopen_176 > iclose_72 && iclose_64 > iopen_168 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && iclose_112 - ilow_424 <= 5.0 * gd_664 && iclose_104 - ilow_416 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iclose_64 <= 5.0 * gd_664) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iopen_192 > iclose_88 && iopen_184 > iclose_80 && iclose_72 > iopen_176 &&
      ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 >= ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && iclose_120 - ilow_432 <= 5.0 * gd_664 && iclose_112 - ilow_424 <= 5.0 * gd_664 &&
      ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iclose_72 <= 5.0 * gd_664) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iopen_200 > iclose_96 && iopen_192 > iclose_88 && iclose_80 > iopen_184 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && iclose_128 - ilow_440 <= 5.0 * gd_664 && iclose_120 - ilow_432 <= 5.0 * gd_664 && ihigh_304 - iopen_200 <= 5.0 * gd_664 && ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iclose_80 <= 5.0 * gd_664) ||
      (iclose_128 > iopen_232 && iopen_224 > iclose_120 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_440 > ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 <= ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 <= ilow_384 && ilow_384 < ilow_376) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 >= iclose_120 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iclose_128 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 >= ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 >= ihigh_296 && ihigh_296 >= ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368))) li_unused_0 = 0;
   if ((pricefilter && close_16 < iclose_96 - 110.0 * gd_664) || (patternsfilter && (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 &&
      iclose_56 > iopen_160 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 > iopen_168 - iclose_64 &&
      iopen_168 - iclose_64 < iclose_56 - iopen_160) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 > iclose_88 - iopen_192 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iopen_176 - iclose_72 && iopen_176 - iclose_72 < iclose_64 - iopen_168 && iclose_64 - iopen_168 <= iclose_56 - iopen_160) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 <= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) ||
      (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 <= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 < iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384) || (iclose_144 < iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 <= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 < ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392) ||
      (iclose_152 < iopen_256 && iclose_144 < iopen_248 && iclose_136 > iopen_240 && iclose_128 <= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 &&
      iclose_96 < iopen_200 && iclose_88 < iopen_192 && ihigh_360 > ihigh_352 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 &&
      ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ilow_464 > ilow_456 && ilow_456 < ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 &&
      ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 >= iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 <= ilow_368) ||
      (iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_224 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 <= ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 <= ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 <= ihigh_288 && ihigh_288 <= ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 >= ilow_424 && ilow_424 >= ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 >= ilow_432 && ilow_432 >= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384) || (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 <= ilow_440 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 <= iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 &&
      ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 &&
      ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 <= ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 >= ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 >= ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 >= ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 < ilow_440 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 >= ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 < ilow_448 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 >= ilow_400 && ilow_400 > ilow_392) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 >= iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 <= iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 <= iopen_208 && iclose_96 <= iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 <= iopen_216 && iclose_104 <= iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) || (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 <= iopen_224 && iclose_112 <= iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ilow_448 > ilow_440 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384))) li_unused_4 = 0;
   if ((pricefilter && close_16 > iclose_96 + 110.0 * gd_664) || (patternsfilter && (iclose_56 >= iclose_64 && iclose_56 >= iclose_72 && iopen_184 > iclose_80 && iclose_88 > iopen_192 &&
      iopen_184 - iclose_80 >= 50.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 < iclose_88 - iopen_192 && iclose_88 - iopen_192 < iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_72 - iopen_176 < 4.0 * (ihigh_280 - iclose_72) && iclose_64 - iopen_168 < 2.0 * (ihigh_272 - iclose_64) && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_88 - iopen_192 < iclose_80 - iopen_184 &&
      iclose_80 - iopen_184 < iclose_72 - iopen_176 && iclose_72 - iopen_176 > iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_64 - iopen_168 < 10.0 * (ihigh_272 - iclose_64) && iclose_56 - iopen_160 < 2.0 * (ihigh_264 - iclose_56)) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && iclose_88 - iopen_192 > 110.0 * gd_664 &&
      iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 >= iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && ihigh_296 > ihigh_288 &&
      ihigh_296 > ihigh_280 && ihigh_296 > ihigh_272 && ihigh_296 > ihigh_264 && ihigh_272 > ihigh_264 && ilow_400 < ihigh_288 && ilow_392 < ihigh_280 && ilow_384 < ihigh_272 &&
      ilow_368 < ihigh_272) || (iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_72 - iopen_176 <= 10.0 * gd_664 && iclose_64 - iopen_168 >= 50.0 * gd_664 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && iopen_160 - ilow_368 <= 5.0 * gd_664) ||
      (iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_80 - iopen_184 <= 10.0 * gd_664 && iclose_72 - iopen_176 >= 50.0 * gd_664 && ihigh_288 < ihigh_280 &&
      ihigh_280 < ihigh_272 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_88 - iopen_192 <= 10.0 * gd_664 && iclose_80 - iopen_184 >= 50.0 * gd_664 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && ihigh_272 < ihigh_280 &&
      ihigh_264 < ihigh_272) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_96 - iopen_200 <= 10.0 * gd_664 && iclose_88 - iopen_192 >= 50.0 * gd_664 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) ||
      (iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_104 - iopen_208 <= 10.0 * gd_664 && iclose_96 - iopen_200 >= 50.0 * gd_664 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && iopen_208 - ilow_416 <= 5.0 * gd_664 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 < ihigh_296 &&
      ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 >= iopen_168 && iclose_56 < iopen_160 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264) ||
      (iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392) ||
      (iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iopen_176 > iclose_72 && iopen_168 > iclose_64 && iclose_56 > iopen_160 &&
      ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368 && iclose_104 - ilow_416 <= 5.0 * gd_664 && iclose_96 - ilow_408 <= 5.0 * gd_664 &&
      ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iopen_168 <= 5.0 * gd_664 && ihigh_264 - iclose_56 <= 5.0 * gd_664) || (iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iopen_184 > iclose_80 && iopen_176 > iclose_72 && iclose_64 > iopen_168 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && iclose_112 - ilow_424 <= 5.0 * gd_664 && iclose_104 - ilow_416 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iclose_64 <= 5.0 * gd_664) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iopen_192 > iclose_88 && iopen_184 > iclose_80 && iclose_72 > iopen_176 &&
      ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 >= ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && iclose_120 - ilow_432 <= 5.0 * gd_664 && iclose_112 - ilow_424 <= 5.0 * gd_664 &&
      ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iclose_72 <= 5.0 * gd_664) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iopen_200 > iclose_96 && iopen_192 > iclose_88 && iclose_80 > iopen_184 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && iclose_128 - ilow_440 <= 5.0 * gd_664 && iclose_120 - ilow_432 <= 5.0 * gd_664 && ihigh_304 - iopen_200 <= 5.0 * gd_664 && ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iclose_80 <= 5.0 * gd_664) ||
      (iclose_128 > iopen_232 && iopen_224 > iclose_120 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_440 > ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 <= ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 <= ilow_384 && ilow_384 < ilow_376) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 >= iclose_120 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iclose_128 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 >= ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 >= ihigh_296 && ihigh_296 >= ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368))) li_unused_0 = 0;
   if ((pricefilter && close_16 < iclose_96 - 110.0 * gd_664) || (patternsfilter && (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 &&
      iclose_56 > iopen_160 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 > iopen_168 - iclose_64 &&
      iopen_168 - iclose_64 < iclose_56 - iopen_160) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 > iclose_88 - iopen_192 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iopen_176 - iclose_72 && iopen_176 - iclose_72 < iclose_64 - iopen_168 && iclose_64 - iopen_168 <= iclose_56 - iopen_160) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 <= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) ||
      (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 <= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 < iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384) || (iclose_144 < iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 <= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 < ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392) ||
      (iclose_152 < iopen_256 && iclose_144 < iopen_248 && iclose_136 > iopen_240 && iclose_128 <= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 &&
      iclose_96 < iopen_200 && iclose_88 < iopen_192 && ihigh_360 > ihigh_352 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 &&
      ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ilow_464 > ilow_456 && ilow_456 < ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 &&
      ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 >= iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 <= ilow_368) ||
      (iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_224 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 <= ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 <= ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 <= ihigh_288 && ihigh_288 <= ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 >= ilow_424 && ilow_424 >= ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 >= ilow_432 && ilow_432 >= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384) || (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 <= ilow_440 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 <= iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 &&
      ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 &&
      ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 <= ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 >= ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 >= ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 >= ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 < ilow_440 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 >= ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 < ilow_448 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 >= ilow_400 && ilow_400 > ilow_392) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 >= iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 <= iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 <= iopen_208 && iclose_96 <= iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 <= iopen_216 && iclose_104 <= iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) || (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 <= iopen_224 && iclose_112 <= iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ilow_448 > ilow_440 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384))) li_unused_4 = 0;
   if ((pricefilter && close_16 > iclose_96 + 110.0 * gd_664) || (patternsfilter && (iclose_56 >= iclose_64 && iclose_56 >= iclose_72 && iopen_184 > iclose_80 && iclose_88 > iopen_192 &&
      iopen_184 - iclose_80 >= 50.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 < iclose_88 - iopen_192 && iclose_88 - iopen_192 < iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_72 - iopen_176 < 4.0 * (ihigh_280 - iclose_72) && iclose_64 - iopen_168 < 2.0 * (ihigh_272 - iclose_64) && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_88 - iopen_192 < iclose_80 - iopen_184 &&
      iclose_80 - iopen_184 < iclose_72 - iopen_176 && iclose_72 - iopen_176 > iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_64 - iopen_168 < 10.0 * (ihigh_272 - iclose_64) && iclose_56 - iopen_160 < 2.0 * (ihigh_264 - iclose_56)) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && iclose_88 - iopen_192 > 110.0 * gd_664 &&
      iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 >= iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && ihigh_296 > ihigh_288 &&
      ihigh_296 > ihigh_280 && ihigh_296 > ihigh_272 && ihigh_296 > ihigh_264 && ihigh_272 > ihigh_264 && ilow_400 < ihigh_288 && ilow_392 < ihigh_280 && ilow_384 < ihigh_272 &&
      ilow_368 < ihigh_272) || (iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_72 - iopen_176 <= 10.0 * gd_664 && iclose_64 - iopen_168 >= 50.0 * gd_664 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && iopen_160 - ilow_368 <= 5.0 * gd_664) ||
      (iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_80 - iopen_184 <= 10.0 * gd_664 && iclose_72 - iopen_176 >= 50.0 * gd_664 && ihigh_288 < ihigh_280 &&
      ihigh_280 < ihigh_272 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_88 - iopen_192 <= 10.0 * gd_664 && iclose_80 - iopen_184 >= 50.0 * gd_664 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && ihigh_272 < ihigh_280 &&
      ihigh_264 < ihigh_272) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_96 - iopen_200 <= 10.0 * gd_664 && iclose_88 - iopen_192 >= 50.0 * gd_664 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) ||
      (iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_104 - iopen_208 <= 10.0 * gd_664 && iclose_96 - iopen_200 >= 50.0 * gd_664 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && iopen_208 - ilow_416 <= 5.0 * gd_664 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 < ihigh_296 &&
      ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 >= iopen_168 && iclose_56 < iopen_160 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264) ||
      (iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392) ||
      (iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iopen_176 > iclose_72 && iopen_168 > iclose_64 && iclose_56 > iopen_160 &&
      ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368 && iclose_104 - ilow_416 <= 5.0 * gd_664 && iclose_96 - ilow_408 <= 5.0 * gd_664 &&
      ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iopen_168 <= 5.0 * gd_664 && ihigh_264 - iclose_56 <= 5.0 * gd_664) || (iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iopen_184 > iclose_80 && iopen_176 > iclose_72 && iclose_64 > iopen_168 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && iclose_112 - ilow_424 <= 5.0 * gd_664 && iclose_104 - ilow_416 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iclose_64 <= 5.0 * gd_664) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iopen_192 > iclose_88 && iopen_184 > iclose_80 && iclose_72 > iopen_176 &&
      ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 >= ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && iclose_120 - ilow_432 <= 5.0 * gd_664 && iclose_112 - ilow_424 <= 5.0 * gd_664 &&
      ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iclose_72 <= 5.0 * gd_664) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iopen_200 > iclose_96 && iopen_192 > iclose_88 && iclose_80 > iopen_184 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && iclose_128 - ilow_440 <= 5.0 * gd_664 && iclose_120 - ilow_432 <= 5.0 * gd_664 && ihigh_304 - iopen_200 <= 5.0 * gd_664 && ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iclose_80 <= 5.0 * gd_664) ||
      (iclose_128 > iopen_232 && iopen_224 > iclose_120 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_440 > ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 <= ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 <= ilow_384 && ilow_384 < ilow_376) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 >= iclose_120 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iclose_128 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 >= ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 >= ihigh_296 && ihigh_296 >= ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368))) li_unused_0 = 0;
   if ((pricefilter && close_16 < iclose_96 - 110.0 * gd_664) || (patternsfilter && (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 &&
      iclose_56 > iopen_160 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 > iopen_168 - iclose_64 &&
      iopen_168 - iclose_64 < iclose_56 - iopen_160) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 > iclose_88 - iopen_192 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iopen_176 - iclose_72 && iopen_176 - iclose_72 < iclose_64 - iopen_168 && iclose_64 - iopen_168 <= iclose_56 - iopen_160) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 <= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) ||
      (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 <= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 < iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384) || (iclose_144 < iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 <= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 < ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392) ||
      (iclose_152 < iopen_256 && iclose_144 < iopen_248 && iclose_136 > iopen_240 && iclose_128 <= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 &&
      iclose_96 < iopen_200 && iclose_88 < iopen_192 && ihigh_360 > ihigh_352 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 &&
      ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ilow_464 > ilow_456 && ilow_456 < ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 &&
      ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 >= iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 <= ilow_368) ||
      (iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_224 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 <= ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 <= ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 <= ihigh_288 && ihigh_288 <= ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 >= ilow_424 && ilow_424 >= ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 >= ilow_432 && ilow_432 >= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384) || (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 <= ilow_440 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 <= iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 &&
      ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 &&
      ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 <= ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 >= ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 >= ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 >= ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 < ilow_440 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 >= ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 < ilow_448 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 >= ilow_400 && ilow_400 > ilow_392) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 >= iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 <= iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 <= iopen_208 && iclose_96 <= iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 <= iopen_216 && iclose_104 <= iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) || (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 <= iopen_224 && iclose_112 <= iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ilow_448 > ilow_440 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384))) li_unused_4 = 0;
   if ((pricefilter && close_16 > iclose_96 + 110.0 * gd_664) || (patternsfilter && (iclose_56 >= iclose_64 && iclose_56 >= iclose_72 && iopen_184 > iclose_80 && iclose_88 > iopen_192 &&
      iopen_184 - iclose_80 >= 50.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 < iclose_88 - iopen_192 && iclose_88 - iopen_192 < iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_72 - iopen_176 < 4.0 * (ihigh_280 - iclose_72) && iclose_64 - iopen_168 < 2.0 * (ihigh_272 - iclose_64) && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_88 - iopen_192 < iclose_80 - iopen_184 &&
      iclose_80 - iopen_184 < iclose_72 - iopen_176 && iclose_72 - iopen_176 > iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_64 - iopen_168 < 10.0 * (ihigh_272 - iclose_64) && iclose_56 - iopen_160 < 2.0 * (ihigh_264 - iclose_56)) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && iclose_88 - iopen_192 > 110.0 * gd_664 &&
      iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 >= iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && ihigh_296 > ihigh_288 &&
      ihigh_296 > ihigh_280 && ihigh_296 > ihigh_272 && ihigh_296 > ihigh_264 && ihigh_272 > ihigh_264 && ilow_400 < ihigh_288 && ilow_392 < ihigh_280 && ilow_384 < ihigh_272 &&
      ilow_368 < ihigh_272) || (iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_72 - iopen_176 <= 10.0 * gd_664 && iclose_64 - iopen_168 >= 50.0 * gd_664 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && iopen_160 - ilow_368 <= 5.0 * gd_664) ||
      (iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_80 - iopen_184 <= 10.0 * gd_664 && iclose_72 - iopen_176 >= 50.0 * gd_664 && ihigh_288 < ihigh_280 &&
      ihigh_280 < ihigh_272 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_88 - iopen_192 <= 10.0 * gd_664 && iclose_80 - iopen_184 >= 50.0 * gd_664 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && ihigh_272 < ihigh_280 &&
      ihigh_264 < ihigh_272) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_96 - iopen_200 <= 10.0 * gd_664 && iclose_88 - iopen_192 >= 50.0 * gd_664 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) ||
      (iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_104 - iopen_208 <= 10.0 * gd_664 && iclose_96 - iopen_200 >= 50.0 * gd_664 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && iopen_208 - ilow_416 <= 5.0 * gd_664 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 < ihigh_296 &&
      ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 >= iopen_168 && iclose_56 < iopen_160 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264) ||
      (iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392) ||
      (iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iopen_176 > iclose_72 && iopen_168 > iclose_64 && iclose_56 > iopen_160 &&
      ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368 && iclose_104 - ilow_416 <= 5.0 * gd_664 && iclose_96 - ilow_408 <= 5.0 * gd_664 &&
      ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iopen_168 <= 5.0 * gd_664 && ihigh_264 - iclose_56 <= 5.0 * gd_664) || (iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iopen_184 > iclose_80 && iopen_176 > iclose_72 && iclose_64 > iopen_168 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && iclose_112 - ilow_424 <= 5.0 * gd_664 && iclose_104 - ilow_416 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iclose_64 <= 5.0 * gd_664) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iopen_192 > iclose_88 && iopen_184 > iclose_80 && iclose_72 > iopen_176 &&
      ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 >= ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && iclose_120 - ilow_432 <= 5.0 * gd_664 && iclose_112 - ilow_424 <= 5.0 * gd_664 &&
      ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iclose_72 <= 5.0 * gd_664) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iopen_200 > iclose_96 && iopen_192 > iclose_88 && iclose_80 > iopen_184 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && iclose_128 - ilow_440 <= 5.0 * gd_664 && iclose_120 - ilow_432 <= 5.0 * gd_664 && ihigh_304 - iopen_200 <= 5.0 * gd_664 && ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iclose_80 <= 5.0 * gd_664) ||
      (iclose_128 > iopen_232 && iopen_224 > iclose_120 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_440 > ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 <= ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 <= ilow_384 && ilow_384 < ilow_376) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 >= iclose_120 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iclose_128 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 >= ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 >= ihigh_296 && ihigh_296 >= ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368))) li_unused_0 = 0;
   if ((pricefilter && close_16 < iclose_96 - 110.0 * gd_664) || (patternsfilter && (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 &&
      iclose_56 > iopen_160 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 > iopen_168 - iclose_64 &&
      iopen_168 - iclose_64 < iclose_56 - iopen_160) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 > iclose_88 - iopen_192 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iopen_176 - iclose_72 && iopen_176 - iclose_72 < iclose_64 - iopen_168 && iclose_64 - iopen_168 <= iclose_56 - iopen_160) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 <= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) ||
      (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 <= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 < iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384) || (iclose_144 < iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 <= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 < ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392) ||
      (iclose_152 < iopen_256 && iclose_144 < iopen_248 && iclose_136 > iopen_240 && iclose_128 <= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 &&
      iclose_96 < iopen_200 && iclose_88 < iopen_192 && ihigh_360 > ihigh_352 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 &&
      ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ilow_464 > ilow_456 && ilow_456 < ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 &&
      ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 >= iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 <= ilow_368) ||
      (iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_224 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 <= ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 <= ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 <= ihigh_288 && ihigh_288 <= ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 >= ilow_424 && ilow_424 >= ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 >= ilow_432 && ilow_432 >= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384) || (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 <= ilow_440 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 <= iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 &&
      ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 &&
      ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 <= ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 >= ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 >= ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 >= ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 < ilow_440 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 >= ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 < ilow_448 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 >= ilow_400 && ilow_400 > ilow_392) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 >= iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 <= iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 <= iopen_208 && iclose_96 <= iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 <= iopen_216 && iclose_104 <= iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) || (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 <= iopen_224 && iclose_112 <= iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ilow_448 > ilow_440 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384))) li_unused_4 = 0;
   if ((pricefilter && close_16 > iclose_96 + 110.0 * gd_664) || (patternsfilter && (iclose_56 >= iclose_64 && iclose_56 >= iclose_72 && iopen_184 > iclose_80 && iclose_88 > iopen_192 &&
      iopen_184 - iclose_80 >= 50.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 < iclose_88 - iopen_192 && iclose_88 - iopen_192 < iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_72 - iopen_176 < 4.0 * (ihigh_280 - iclose_72) && iclose_64 - iopen_168 < 2.0 * (ihigh_272 - iclose_64) && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_88 - iopen_192 < iclose_80 - iopen_184 &&
      iclose_80 - iopen_184 < iclose_72 - iopen_176 && iclose_72 - iopen_176 > iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_64 - iopen_168 < 10.0 * (ihigh_272 - iclose_64) && iclose_56 - iopen_160 < 2.0 * (ihigh_264 - iclose_56)) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && iclose_88 - iopen_192 > 110.0 * gd_664 &&
      iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 >= iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && ihigh_296 > ihigh_288 &&
      ihigh_296 > ihigh_280 && ihigh_296 > ihigh_272 && ihigh_296 > ihigh_264 && ihigh_272 > ihigh_264 && ilow_400 < ihigh_288 && ilow_392 < ihigh_280 && ilow_384 < ihigh_272 &&
      ilow_368 < ihigh_272) || (iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_72 - iopen_176 <= 10.0 * gd_664 && iclose_64 - iopen_168 >= 50.0 * gd_664 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && iopen_160 - ilow_368 <= 5.0 * gd_664) ||
      (iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_80 - iopen_184 <= 10.0 * gd_664 && iclose_72 - iopen_176 >= 50.0 * gd_664 && ihigh_288 < ihigh_280 &&
      ihigh_280 < ihigh_272 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_88 - iopen_192 <= 10.0 * gd_664 && iclose_80 - iopen_184 >= 50.0 * gd_664 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && ihigh_272 < ihigh_280 &&
      ihigh_264 < ihigh_272) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_96 - iopen_200 <= 10.0 * gd_664 && iclose_88 - iopen_192 >= 50.0 * gd_664 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) ||
      (iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_104 - iopen_208 <= 10.0 * gd_664 && iclose_96 - iopen_200 >= 50.0 * gd_664 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && iopen_208 - ilow_416 <= 5.0 * gd_664 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 < ihigh_296 &&
      ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 >= iopen_168 && iclose_56 < iopen_160 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264) ||
      (iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392) ||
      (iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iopen_176 > iclose_72 && iopen_168 > iclose_64 && iclose_56 > iopen_160 &&
      ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368 && iclose_104 - ilow_416 <= 5.0 * gd_664 && iclose_96 - ilow_408 <= 5.0 * gd_664 &&
      ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iopen_168 <= 5.0 * gd_664 && ihigh_264 - iclose_56 <= 5.0 * gd_664) || (iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iopen_184 > iclose_80 && iopen_176 > iclose_72 && iclose_64 > iopen_168 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && iclose_112 - ilow_424 <= 5.0 * gd_664 && iclose_104 - ilow_416 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iclose_64 <= 5.0 * gd_664) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iopen_192 > iclose_88 && iopen_184 > iclose_80 && iclose_72 > iopen_176 &&
      ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 >= ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && iclose_120 - ilow_432 <= 5.0 * gd_664 && iclose_112 - ilow_424 <= 5.0 * gd_664 &&
      ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iclose_72 <= 5.0 * gd_664) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iopen_200 > iclose_96 && iopen_192 > iclose_88 && iclose_80 > iopen_184 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && iclose_128 - ilow_440 <= 5.0 * gd_664 && iclose_120 - ilow_432 <= 5.0 * gd_664 && ihigh_304 - iopen_200 <= 5.0 * gd_664 && ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iclose_80 <= 5.0 * gd_664) ||
      (iclose_128 > iopen_232 && iopen_224 > iclose_120 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_440 > ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 <= ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 <= ilow_384 && ilow_384 < ilow_376) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 >= iclose_120 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iclose_128 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 >= ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 >= ihigh_296 && ihigh_296 >= ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368))) li_unused_0 = 0;
   if ((pricefilter && close_16 < iclose_96 - 110.0 * gd_664) || (patternsfilter && (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 &&
      iclose_56 > iopen_160 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 > iopen_168 - iclose_64 &&
      iopen_168 - iclose_64 < iclose_56 - iopen_160) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 > iclose_88 - iopen_192 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iopen_176 - iclose_72 && iopen_176 - iclose_72 < iclose_64 - iopen_168 && iclose_64 - iopen_168 <= iclose_56 - iopen_160) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 <= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) ||
      (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 <= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 < iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384) || (iclose_144 < iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 <= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 < ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392) ||
      (iclose_152 < iopen_256 && iclose_144 < iopen_248 && iclose_136 > iopen_240 && iclose_128 <= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 &&
      iclose_96 < iopen_200 && iclose_88 < iopen_192 && ihigh_360 > ihigh_352 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 &&
      ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ilow_464 > ilow_456 && ilow_456 < ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 &&
      ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 >= iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 <= ilow_368) ||
      (iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_224 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 <= ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 <= ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 <= ihigh_288 && ihigh_288 <= ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 >= ilow_424 && ilow_424 >= ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 >= ilow_432 && ilow_432 >= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384) || (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 <= ilow_440 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 <= iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 &&
      ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 &&
      ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 <= ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 >= ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 >= ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 >= ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 < ilow_440 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 >= ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 < ilow_448 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 >= ilow_400 && ilow_400 > ilow_392) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 >= iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 <= iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 <= iopen_208 && iclose_96 <= iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 <= iopen_216 && iclose_104 <= iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) || (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 <= iopen_224 && iclose_112 <= iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ilow_448 > ilow_440 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384))) li_unused_4 = 0;
   if ((pricefilter && close_16 > iclose_96 + 110.0 * gd_664) || (patternsfilter && (iclose_56 >= iclose_64 && iclose_56 >= iclose_72 && iopen_184 > iclose_80 && iclose_88 > iopen_192 &&
      iopen_184 - iclose_80 >= 50.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 < iclose_88 - iopen_192 && iclose_88 - iopen_192 < iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_72 - iopen_176 < 4.0 * (ihigh_280 - iclose_72) && iclose_64 - iopen_168 < 2.0 * (ihigh_272 - iclose_64) && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_88 - iopen_192 < iclose_80 - iopen_184 &&
      iclose_80 - iopen_184 < iclose_72 - iopen_176 && iclose_72 - iopen_176 > iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_64 - iopen_168 < 10.0 * (ihigh_272 - iclose_64) && iclose_56 - iopen_160 < 2.0 * (ihigh_264 - iclose_56)) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && iclose_88 - iopen_192 > 110.0 * gd_664 &&
      iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 >= iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && ihigh_296 > ihigh_288 &&
      ihigh_296 > ihigh_280 && ihigh_296 > ihigh_272 && ihigh_296 > ihigh_264 && ihigh_272 > ihigh_264 && ilow_400 < ihigh_288 && ilow_392 < ihigh_280 && ilow_384 < ihigh_272 &&
      ilow_368 < ihigh_272) || (iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_72 - iopen_176 <= 10.0 * gd_664 && iclose_64 - iopen_168 >= 50.0 * gd_664 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && iopen_160 - ilow_368 <= 5.0 * gd_664) ||
      (iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_80 - iopen_184 <= 10.0 * gd_664 && iclose_72 - iopen_176 >= 50.0 * gd_664 && ihigh_288 < ihigh_280 &&
      ihigh_280 < ihigh_272 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_88 - iopen_192 <= 10.0 * gd_664 && iclose_80 - iopen_184 >= 50.0 * gd_664 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && ihigh_272 < ihigh_280 &&
      ihigh_264 < ihigh_272) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_96 - iopen_200 <= 10.0 * gd_664 && iclose_88 - iopen_192 >= 50.0 * gd_664 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) ||
      (iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_104 - iopen_208 <= 10.0 * gd_664 && iclose_96 - iopen_200 >= 50.0 * gd_664 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && iopen_208 - ilow_416 <= 5.0 * gd_664 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 < ihigh_296 &&
      ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 >= iopen_168 && iclose_56 < iopen_160 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264) ||
      (iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392) ||
      (iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iopen_176 > iclose_72 && iopen_168 > iclose_64 && iclose_56 > iopen_160 &&
      ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368 && iclose_104 - ilow_416 <= 5.0 * gd_664 && iclose_96 - ilow_408 <= 5.0 * gd_664 &&
      ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iopen_168 <= 5.0 * gd_664 && ihigh_264 - iclose_56 <= 5.0 * gd_664) || (iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iopen_184 > iclose_80 && iopen_176 > iclose_72 && iclose_64 > iopen_168 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && iclose_112 - ilow_424 <= 5.0 * gd_664 && iclose_104 - ilow_416 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iclose_64 <= 5.0 * gd_664) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iopen_192 > iclose_88 && iopen_184 > iclose_80 && iclose_72 > iopen_176 &&
      ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 >= ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && iclose_120 - ilow_432 <= 5.0 * gd_664 && iclose_112 - ilow_424 <= 5.0 * gd_664 &&
      ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iclose_72 <= 5.0 * gd_664) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iopen_200 > iclose_96 && iopen_192 > iclose_88 && iclose_80 > iopen_184 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && iclose_128 - ilow_440 <= 5.0 * gd_664 && iclose_120 - ilow_432 <= 5.0 * gd_664 && ihigh_304 - iopen_200 <= 5.0 * gd_664 && ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iclose_80 <= 5.0 * gd_664) ||
      (iclose_128 > iopen_232 && iopen_224 > iclose_120 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_440 > ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 <= ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 <= ilow_384 && ilow_384 < ilow_376) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 >= iclose_120 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iclose_128 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 >= ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 >= ihigh_296 && ihigh_296 >= ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368))) li_unused_0 = 0;
   if ((pricefilter && close_16 < iclose_96 - 110.0 * gd_664) || (patternsfilter && (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 &&
      iclose_56 > iopen_160 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 > iopen_168 - iclose_64 &&
      iopen_168 - iclose_64 < iclose_56 - iopen_160) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 > iclose_88 - iopen_192 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iopen_176 - iclose_72 && iopen_176 - iclose_72 < iclose_64 - iopen_168 && iclose_64 - iopen_168 <= iclose_56 - iopen_160) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 <= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) ||
      (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 <= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 < iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384) || (iclose_144 < iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 <= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 < ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392) ||
      (iclose_152 < iopen_256 && iclose_144 < iopen_248 && iclose_136 > iopen_240 && iclose_128 <= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 &&
      iclose_96 < iopen_200 && iclose_88 < iopen_192 && ihigh_360 > ihigh_352 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 &&
      ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ilow_464 > ilow_456 && ilow_456 < ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 &&
      ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 >= iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 <= ilow_368) ||
      (iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_224 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 <= ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 <= ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 <= ihigh_288 && ihigh_288 <= ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 >= ilow_424 && ilow_424 >= ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 >= ilow_432 && ilow_432 >= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384) || (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 <= ilow_440 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 <= iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 &&
      ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 &&
      ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 <= ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 >= ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 >= ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 >= ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 < ilow_440 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 >= ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 < ilow_448 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 >= ilow_400 && ilow_400 > ilow_392) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 >= iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 <= iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 <= iopen_208 && iclose_96 <= iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 <= iopen_216 && iclose_104 <= iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) || (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 <= iopen_224 && iclose_112 <= iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ilow_448 > ilow_440 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384))) li_unused_4 = 0;
   if ((pricefilter && close_16 > iclose_96 + 110.0 * gd_664) || (patternsfilter && (iclose_56 >= iclose_64 && iclose_56 >= iclose_72 && iopen_184 > iclose_80 && iclose_88 > iopen_192 &&
      iopen_184 - iclose_80 >= 50.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 < iclose_88 - iopen_192 && iclose_88 - iopen_192 < iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_72 - iopen_176 < 4.0 * (ihigh_280 - iclose_72) && iclose_64 - iopen_168 < 2.0 * (ihigh_272 - iclose_64) && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_88 - iopen_192 < iclose_80 - iopen_184 &&
      iclose_80 - iopen_184 < iclose_72 - iopen_176 && iclose_72 - iopen_176 > iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_64 - iopen_168 < 10.0 * (ihigh_272 - iclose_64) && iclose_56 - iopen_160 < 2.0 * (ihigh_264 - iclose_56)) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && iclose_88 - iopen_192 > 110.0 * gd_664 &&
      iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 >= iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && ihigh_296 > ihigh_288 &&
      ihigh_296 > ihigh_280 && ihigh_296 > ihigh_272 && ihigh_296 > ihigh_264 && ihigh_272 > ihigh_264 && ilow_400 < ihigh_288 && ilow_392 < ihigh_280 && ilow_384 < ihigh_272 &&
      ilow_368 < ihigh_272) || (iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_72 - iopen_176 <= 10.0 * gd_664 && iclose_64 - iopen_168 >= 50.0 * gd_664 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && iopen_160 - ilow_368 <= 5.0 * gd_664) ||
      (iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_80 - iopen_184 <= 10.0 * gd_664 && iclose_72 - iopen_176 >= 50.0 * gd_664 && ihigh_288 < ihigh_280 &&
      ihigh_280 < ihigh_272 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_88 - iopen_192 <= 10.0 * gd_664 && iclose_80 - iopen_184 >= 50.0 * gd_664 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && ihigh_272 < ihigh_280 &&
      ihigh_264 < ihigh_272) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_96 - iopen_200 <= 10.0 * gd_664 && iclose_88 - iopen_192 >= 50.0 * gd_664 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) ||
      (iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_104 - iopen_208 <= 10.0 * gd_664 && iclose_96 - iopen_200 >= 50.0 * gd_664 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && iopen_208 - ilow_416 <= 5.0 * gd_664 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 < ihigh_296 &&
      ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 >= iopen_168 && iclose_56 < iopen_160 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264) ||
      (iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392) ||
      (iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iopen_176 > iclose_72 && iopen_168 > iclose_64 && iclose_56 > iopen_160 &&
      ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368 && iclose_104 - ilow_416 <= 5.0 * gd_664 && iclose_96 - ilow_408 <= 5.0 * gd_664 &&
      ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iopen_168 <= 5.0 * gd_664 && ihigh_264 - iclose_56 <= 5.0 * gd_664) || (iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iopen_184 > iclose_80 && iopen_176 > iclose_72 && iclose_64 > iopen_168 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && iclose_112 - ilow_424 <= 5.0 * gd_664 && iclose_104 - ilow_416 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iclose_64 <= 5.0 * gd_664) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iopen_192 > iclose_88 && iopen_184 > iclose_80 && iclose_72 > iopen_176 &&
      ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 >= ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && iclose_120 - ilow_432 <= 5.0 * gd_664 && iclose_112 - ilow_424 <= 5.0 * gd_664 &&
      ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iclose_72 <= 5.0 * gd_664) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iopen_200 > iclose_96 && iopen_192 > iclose_88 && iclose_80 > iopen_184 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && iclose_128 - ilow_440 <= 5.0 * gd_664 && iclose_120 - ilow_432 <= 5.0 * gd_664 && ihigh_304 - iopen_200 <= 5.0 * gd_664 && ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iclose_80 <= 5.0 * gd_664) ||
      (iclose_128 > iopen_232 && iopen_224 > iclose_120 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_440 > ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 <= ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 <= ilow_384 && ilow_384 < ilow_376) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 >= iclose_120 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iclose_128 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 >= ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 >= ihigh_296 && ihigh_296 >= ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368))) li_unused_0 = 0;
   if ((pricefilter && close_16 < iclose_96 - 110.0 * gd_664) || (patternsfilter && (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 &&
      iclose_56 > iopen_160 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 > iopen_168 - iclose_64 &&
      iopen_168 - iclose_64 < iclose_56 - iopen_160) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 > iclose_88 - iopen_192 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iopen_176 - iclose_72 && iopen_176 - iclose_72 < iclose_64 - iopen_168 && iclose_64 - iopen_168 <= iclose_56 - iopen_160) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 <= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) ||
      (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 <= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 < iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384) || (iclose_144 < iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 <= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 < ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392) ||
      (iclose_152 < iopen_256 && iclose_144 < iopen_248 && iclose_136 > iopen_240 && iclose_128 <= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 &&
      iclose_96 < iopen_200 && iclose_88 < iopen_192 && ihigh_360 > ihigh_352 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 &&
      ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ilow_464 > ilow_456 && ilow_456 < ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 &&
      ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 >= iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 <= ilow_368) ||
      (iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_224 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 <= ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 <= ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 <= ihigh_288 && ihigh_288 <= ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 >= ilow_424 && ilow_424 >= ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 >= ilow_432 && ilow_432 >= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384) || (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 <= ilow_440 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 <= iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 &&
      ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 &&
      ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 <= ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 >= ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 >= ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 >= ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 < ilow_440 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 >= ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 < ilow_448 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 >= ilow_400 && ilow_400 > ilow_392) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 >= iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 <= iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 <= iopen_208 && iclose_96 <= iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 <= iopen_216 && iclose_104 <= iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) || (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 <= iopen_224 && iclose_112 <= iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ilow_448 > ilow_440 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384))) li_unused_4 = 0;
   if ((pricefilter && close_16 > iclose_96 + 110.0 * gd_664) || (patternsfilter && (iclose_56 >= iclose_64 && iclose_56 >= iclose_72 && iopen_184 > iclose_80 && iclose_88 > iopen_192 &&
      iopen_184 - iclose_80 >= 50.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 < iclose_88 - iopen_192 && iclose_88 - iopen_192 < iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_72 - iopen_176 < 4.0 * (ihigh_280 - iclose_72) && iclose_64 - iopen_168 < 2.0 * (ihigh_272 - iclose_64) && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_88 - iopen_192 < iclose_80 - iopen_184 &&
      iclose_80 - iopen_184 < iclose_72 - iopen_176 && iclose_72 - iopen_176 > iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_64 - iopen_168 < 10.0 * (ihigh_272 - iclose_64) && iclose_56 - iopen_160 < 2.0 * (ihigh_264 - iclose_56)) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && iclose_88 - iopen_192 > 110.0 * gd_664 &&
      iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 >= iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && ihigh_296 > ihigh_288 &&
      ihigh_296 > ihigh_280 && ihigh_296 > ihigh_272 && ihigh_296 > ihigh_264 && ihigh_272 > ihigh_264 && ilow_400 < ihigh_288 && ilow_392 < ihigh_280 && ilow_384 < ihigh_272 &&
      ilow_368 < ihigh_272) || (iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_72 - iopen_176 <= 10.0 * gd_664 && iclose_64 - iopen_168 >= 50.0 * gd_664 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && iopen_160 - ilow_368 <= 5.0 * gd_664) ||
      (iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_80 - iopen_184 <= 10.0 * gd_664 && iclose_72 - iopen_176 >= 50.0 * gd_664 && ihigh_288 < ihigh_280 &&
      ihigh_280 < ihigh_272 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_88 - iopen_192 <= 10.0 * gd_664 && iclose_80 - iopen_184 >= 50.0 * gd_664 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && ihigh_272 < ihigh_280 &&
      ihigh_264 < ihigh_272) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_96 - iopen_200 <= 10.0 * gd_664 && iclose_88 - iopen_192 >= 50.0 * gd_664 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) ||
      (iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_104 - iopen_208 <= 10.0 * gd_664 && iclose_96 - iopen_200 >= 50.0 * gd_664 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && iopen_208 - ilow_416 <= 5.0 * gd_664 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 < ihigh_296 &&
      ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 >= iopen_168 && iclose_56 < iopen_160 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264) ||
      (iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392) ||
      (iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iopen_176 > iclose_72 && iopen_168 > iclose_64 && iclose_56 > iopen_160 &&
      ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368 && iclose_104 - ilow_416 <= 5.0 * gd_664 && iclose_96 - ilow_408 <= 5.0 * gd_664 &&
      ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iopen_168 <= 5.0 * gd_664 && ihigh_264 - iclose_56 <= 5.0 * gd_664) || (iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iopen_184 > iclose_80 && iopen_176 > iclose_72 && iclose_64 > iopen_168 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && iclose_112 - ilow_424 <= 5.0 * gd_664 && iclose_104 - ilow_416 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iclose_64 <= 5.0 * gd_664) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iopen_192 > iclose_88 && iopen_184 > iclose_80 && iclose_72 > iopen_176 &&
      ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 >= ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && iclose_120 - ilow_432 <= 5.0 * gd_664 && iclose_112 - ilow_424 <= 5.0 * gd_664 &&
      ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iclose_72 <= 5.0 * gd_664) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iopen_200 > iclose_96 && iopen_192 > iclose_88 && iclose_80 > iopen_184 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && iclose_128 - ilow_440 <= 5.0 * gd_664 && iclose_120 - ilow_432 <= 5.0 * gd_664 && ihigh_304 - iopen_200 <= 5.0 * gd_664 && ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iclose_80 <= 5.0 * gd_664) ||
      (iclose_128 > iopen_232 && iopen_224 > iclose_120 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_440 > ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 <= ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 <= ilow_384 && ilow_384 < ilow_376) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 >= iclose_120 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iclose_128 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 >= ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 >= ihigh_296 && ihigh_296 >= ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368))) li_unused_0 = 0;
   if ((pricefilter && close_16 < iclose_96 - 110.0 * gd_664) || (patternsfilter && (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 &&
      iclose_56 > iopen_160 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 > iopen_168 - iclose_64 &&
      iopen_168 - iclose_64 < iclose_56 - iopen_160) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 > iclose_88 - iopen_192 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iopen_176 - iclose_72 && iopen_176 - iclose_72 < iclose_64 - iopen_168 && iclose_64 - iopen_168 <= iclose_56 - iopen_160) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 <= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) ||
      (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 <= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 < iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384) || (iclose_144 < iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 <= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 < ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392) ||
      (iclose_152 < iopen_256 && iclose_144 < iopen_248 && iclose_136 > iopen_240 && iclose_128 <= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 &&
      iclose_96 < iopen_200 && iclose_88 < iopen_192 && ihigh_360 > ihigh_352 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 &&
      ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ilow_464 > ilow_456 && ilow_456 < ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 &&
      ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 >= iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 <= ilow_368) ||
      (iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_224 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 <= ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 <= ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 <= ihigh_288 && ihigh_288 <= ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 >= ilow_424 && ilow_424 >= ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 >= ilow_432 && ilow_432 >= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384) || (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 <= ilow_440 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 <= iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 &&
      ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 &&
      ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 <= ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 >= ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 >= ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 >= ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 < ilow_440 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 >= ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 < ilow_448 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 >= ilow_400 && ilow_400 > ilow_392) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 >= iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 <= iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 <= iopen_208 && iclose_96 <= iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 <= iopen_216 && iclose_104 <= iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) || (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 <= iopen_224 && iclose_112 <= iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ilow_448 > ilow_440 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384))) li_unused_4 = 0;
   if ((pricefilter && close_16 > iclose_96 + 110.0 * gd_664) || (patternsfilter && (iclose_56 >= iclose_64 && iclose_56 >= iclose_72 && iopen_184 > iclose_80 && iclose_88 > iopen_192 &&
      iopen_184 - iclose_80 >= 50.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 < iclose_88 - iopen_192 && iclose_88 - iopen_192 < iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_72 - iopen_176 < 4.0 * (ihigh_280 - iclose_72) && iclose_64 - iopen_168 < 2.0 * (ihigh_272 - iclose_64) && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_88 - iopen_192 < iclose_80 - iopen_184 &&
      iclose_80 - iopen_184 < iclose_72 - iopen_176 && iclose_72 - iopen_176 > iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_64 - iopen_168 < 10.0 * (ihigh_272 - iclose_64) && iclose_56 - iopen_160 < 2.0 * (ihigh_264 - iclose_56)) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && iclose_88 - iopen_192 > 110.0 * gd_664 &&
      iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 >= iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && ihigh_296 > ihigh_288 &&
      ihigh_296 > ihigh_280 && ihigh_296 > ihigh_272 && ihigh_296 > ihigh_264 && ihigh_272 > ihigh_264 && ilow_400 < ihigh_288 && ilow_392 < ihigh_280 && ilow_384 < ihigh_272 &&
      ilow_368 < ihigh_272) || (iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_72 - iopen_176 <= 10.0 * gd_664 && iclose_64 - iopen_168 >= 50.0 * gd_664 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && iopen_160 - ilow_368 <= 5.0 * gd_664) ||
      (iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_80 - iopen_184 <= 10.0 * gd_664 && iclose_72 - iopen_176 >= 50.0 * gd_664 && ihigh_288 < ihigh_280 &&
      ihigh_280 < ihigh_272 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_88 - iopen_192 <= 10.0 * gd_664 && iclose_80 - iopen_184 >= 50.0 * gd_664 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && ihigh_272 < ihigh_280 &&
      ihigh_264 < ihigh_272) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_96 - iopen_200 <= 10.0 * gd_664 && iclose_88 - iopen_192 >= 50.0 * gd_664 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) ||
      (iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_104 - iopen_208 <= 10.0 * gd_664 && iclose_96 - iopen_200 >= 50.0 * gd_664 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && iopen_208 - ilow_416 <= 5.0 * gd_664 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 < ihigh_296 &&
      ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 >= iopen_168 && iclose_56 < iopen_160 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264) ||
      (iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392) ||
      (iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iopen_176 > iclose_72 && iopen_168 > iclose_64 && iclose_56 > iopen_160 &&
      ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368 && iclose_104 - ilow_416 <= 5.0 * gd_664 && iclose_96 - ilow_408 <= 5.0 * gd_664 &&
      ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iopen_168 <= 5.0 * gd_664 && ihigh_264 - iclose_56 <= 5.0 * gd_664) || (iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iopen_184 > iclose_80 && iopen_176 > iclose_72 && iclose_64 > iopen_168 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && iclose_112 - ilow_424 <= 5.0 * gd_664 && iclose_104 - ilow_416 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iclose_64 <= 5.0 * gd_664) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iopen_192 > iclose_88 && iopen_184 > iclose_80 && iclose_72 > iopen_176 &&
      ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 >= ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && iclose_120 - ilow_432 <= 5.0 * gd_664 && iclose_112 - ilow_424 <= 5.0 * gd_664 &&
      ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iclose_72 <= 5.0 * gd_664) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iopen_200 > iclose_96 && iopen_192 > iclose_88 && iclose_80 > iopen_184 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && iclose_128 - ilow_440 <= 5.0 * gd_664 && iclose_120 - ilow_432 <= 5.0 * gd_664 && ihigh_304 - iopen_200 <= 5.0 * gd_664 && ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iclose_80 <= 5.0 * gd_664) ||
      (iclose_128 > iopen_232 && iopen_224 > iclose_120 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_440 > ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 <= ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 <= ilow_384 && ilow_384 < ilow_376) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 >= iclose_120 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iclose_128 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 >= ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 >= ihigh_296 && ihigh_296 >= ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368))) li_unused_0 = 0;
   if ((pricefilter && close_16 < iclose_96 - 110.0 * gd_664) || (patternsfilter && (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 &&
      iclose_56 > iopen_160 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 > iopen_168 - iclose_64 &&
      iopen_168 - iclose_64 < iclose_56 - iopen_160) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 > iclose_88 - iopen_192 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iopen_176 - iclose_72 && iopen_176 - iclose_72 < iclose_64 - iopen_168 && iclose_64 - iopen_168 <= iclose_56 - iopen_160) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 <= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) ||
      (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 <= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 < iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384) || (iclose_144 < iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 <= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 < ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392) ||
      (iclose_152 < iopen_256 && iclose_144 < iopen_248 && iclose_136 > iopen_240 && iclose_128 <= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 &&
      iclose_96 < iopen_200 && iclose_88 < iopen_192 && ihigh_360 > ihigh_352 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 &&
      ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ilow_464 > ilow_456 && ilow_456 < ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 &&
      ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 >= iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 <= ilow_368) ||
      (iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_224 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 <= ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 <= ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 <= ihigh_288 && ihigh_288 <= ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 >= ilow_424 && ilow_424 >= ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 >= ilow_432 && ilow_432 >= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384) || (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 <= ilow_440 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 <= iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 &&
      ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 &&
      ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 <= ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 >= ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 >= ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 >= ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 < ilow_440 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 >= ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 < ilow_448 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 >= ilow_400 && ilow_400 > ilow_392) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 >= iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 <= iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 <= iopen_208 && iclose_96 <= iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 <= iopen_216 && iclose_104 <= iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) || (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 <= iopen_224 && iclose_112 <= iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ilow_448 > ilow_440 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384))) li_unused_4 = 0;
   if ((pricefilter && close_16 > iclose_96 + 110.0 * gd_664) || (patternsfilter && (iclose_56 >= iclose_64 && iclose_56 >= iclose_72 && iopen_184 > iclose_80 && iclose_88 > iopen_192 &&
      iopen_184 - iclose_80 >= 50.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 < iclose_88 - iopen_192 && iclose_88 - iopen_192 < iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_72 - iopen_176 < 4.0 * (ihigh_280 - iclose_72) && iclose_64 - iopen_168 < 2.0 * (ihigh_272 - iclose_64) && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_88 - iopen_192 < iclose_80 - iopen_184 &&
      iclose_80 - iopen_184 < iclose_72 - iopen_176 && iclose_72 - iopen_176 > iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_64 - iopen_168 < 10.0 * (ihigh_272 - iclose_64) && iclose_56 - iopen_160 < 2.0 * (ihigh_264 - iclose_56)) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && iclose_88 - iopen_192 > 110.0 * gd_664 &&
      iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 >= iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && ihigh_296 > ihigh_288 &&
      ihigh_296 > ihigh_280 && ihigh_296 > ihigh_272 && ihigh_296 > ihigh_264 && ihigh_272 > ihigh_264 && ilow_400 < ihigh_288 && ilow_392 < ihigh_280 && ilow_384 < ihigh_272 &&
      ilow_368 < ihigh_272) || (iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_72 - iopen_176 <= 10.0 * gd_664 && iclose_64 - iopen_168 >= 50.0 * gd_664 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && iopen_160 - ilow_368 <= 5.0 * gd_664) ||
      (iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_80 - iopen_184 <= 10.0 * gd_664 && iclose_72 - iopen_176 >= 50.0 * gd_664 && ihigh_288 < ihigh_280 &&
      ihigh_280 < ihigh_272 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_88 - iopen_192 <= 10.0 * gd_664 && iclose_80 - iopen_184 >= 50.0 * gd_664 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && ihigh_272 < ihigh_280 &&
      ihigh_264 < ihigh_272) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_96 - iopen_200 <= 10.0 * gd_664 && iclose_88 - iopen_192 >= 50.0 * gd_664 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) ||
      (iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_104 - iopen_208 <= 10.0 * gd_664 && iclose_96 - iopen_200 >= 50.0 * gd_664 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && iopen_208 - ilow_416 <= 5.0 * gd_664 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 < ihigh_296 &&
      ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 >= iopen_168 && iclose_56 < iopen_160 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264) ||
      (iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392) ||
      (iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iopen_176 > iclose_72 && iopen_168 > iclose_64 && iclose_56 > iopen_160 &&
      ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368 && iclose_104 - ilow_416 <= 5.0 * gd_664 && iclose_96 - ilow_408 <= 5.0 * gd_664 &&
      ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iopen_168 <= 5.0 * gd_664 && ihigh_264 - iclose_56 <= 5.0 * gd_664) || (iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iopen_184 > iclose_80 && iopen_176 > iclose_72 && iclose_64 > iopen_168 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && iclose_112 - ilow_424 <= 5.0 * gd_664 && iclose_104 - ilow_416 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iclose_64 <= 5.0 * gd_664) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iopen_192 > iclose_88 && iopen_184 > iclose_80 && iclose_72 > iopen_176 &&
      ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 >= ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && iclose_120 - ilow_432 <= 5.0 * gd_664 && iclose_112 - ilow_424 <= 5.0 * gd_664 &&
      ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iclose_72 <= 5.0 * gd_664) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iopen_200 > iclose_96 && iopen_192 > iclose_88 && iclose_80 > iopen_184 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && iclose_128 - ilow_440 <= 5.0 * gd_664 && iclose_120 - ilow_432 <= 5.0 * gd_664 && ihigh_304 - iopen_200 <= 5.0 * gd_664 && ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iclose_80 <= 5.0 * gd_664) ||
      (iclose_128 > iopen_232 && iopen_224 > iclose_120 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_440 > ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 <= ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 <= ilow_384 && ilow_384 < ilow_376) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 >= iclose_120 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iclose_128 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 >= ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 >= ihigh_296 && ihigh_296 >= ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368))) li_unused_0 = 0;
   if ((pricefilter && close_16 < iclose_96 - 110.0 * gd_664) || (patternsfilter && (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 &&
      iclose_56 > iopen_160 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 > iopen_168 - iclose_64 &&
      iopen_168 - iclose_64 < iclose_56 - iopen_160) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 > iclose_88 - iopen_192 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iopen_176 - iclose_72 && iopen_176 - iclose_72 < iclose_64 - iopen_168 && iclose_64 - iopen_168 <= iclose_56 - iopen_160) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 <= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) ||
      (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 <= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 < iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384) || (iclose_144 < iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 <= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 < ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392) ||
      (iclose_152 < iopen_256 && iclose_144 < iopen_248 && iclose_136 > iopen_240 && iclose_128 <= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 &&
      iclose_96 < iopen_200 && iclose_88 < iopen_192 && ihigh_360 > ihigh_352 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 &&
      ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ilow_464 > ilow_456 && ilow_456 < ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 &&
      ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 >= iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 <= ilow_368) ||
      (iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_224 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 <= ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 <= ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 <= ihigh_288 && ihigh_288 <= ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 >= ilow_424 && ilow_424 >= ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 >= ilow_432 && ilow_432 >= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384) || (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 <= ilow_440 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 <= iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 &&
      ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 &&
      ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 <= ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 >= ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 >= ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 >= ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 < ilow_440 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 >= ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 < ilow_448 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 >= ilow_400 && ilow_400 > ilow_392) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 >= iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 <= iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 <= iopen_208 && iclose_96 <= iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 <= iopen_216 && iclose_104 <= iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) || (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 <= iopen_224 && iclose_112 <= iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ilow_448 > ilow_440 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384))) li_unused_4 = 0;
   if ((pricefilter && close_16 > iclose_96 + 110.0 * gd_664) || (patternsfilter && (iclose_56 >= iclose_64 && iclose_56 >= iclose_72 && iopen_184 > iclose_80 && iclose_88 > iopen_192 &&
      iopen_184 - iclose_80 >= 50.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 < iclose_88 - iopen_192 && iclose_88 - iopen_192 < iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_72 - iopen_176 < 4.0 * (ihigh_280 - iclose_72) && iclose_64 - iopen_168 < 2.0 * (ihigh_272 - iclose_64) && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_88 - iopen_192 < iclose_80 - iopen_184 &&
      iclose_80 - iopen_184 < iclose_72 - iopen_176 && iclose_72 - iopen_176 > iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_64 - iopen_168 < 10.0 * (ihigh_272 - iclose_64) && iclose_56 - iopen_160 < 2.0 * (ihigh_264 - iclose_56)) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && iclose_88 - iopen_192 > 110.0 * gd_664 &&
      iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 >= iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && ihigh_296 > ihigh_288 &&
      ihigh_296 > ihigh_280 && ihigh_296 > ihigh_272 && ihigh_296 > ihigh_264 && ihigh_272 > ihigh_264 && ilow_400 < ihigh_288 && ilow_392 < ihigh_280 && ilow_384 < ihigh_272 &&
      ilow_368 < ihigh_272) || (iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_72 - iopen_176 <= 10.0 * gd_664 && iclose_64 - iopen_168 >= 50.0 * gd_664 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && iopen_160 - ilow_368 <= 5.0 * gd_664) ||
      (iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_80 - iopen_184 <= 10.0 * gd_664 && iclose_72 - iopen_176 >= 50.0 * gd_664 && ihigh_288 < ihigh_280 &&
      ihigh_280 < ihigh_272 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_88 - iopen_192 <= 10.0 * gd_664 && iclose_80 - iopen_184 >= 50.0 * gd_664 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && ihigh_272 < ihigh_280 &&
      ihigh_264 < ihigh_272) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_96 - iopen_200 <= 10.0 * gd_664 && iclose_88 - iopen_192 >= 50.0 * gd_664 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) ||
      (iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_104 - iopen_208 <= 10.0 * gd_664 && iclose_96 - iopen_200 >= 50.0 * gd_664 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && iopen_208 - ilow_416 <= 5.0 * gd_664 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 < ihigh_296 &&
      ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 >= iopen_168 && iclose_56 < iopen_160 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264) ||
      (iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392) ||
      (iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iopen_176 > iclose_72 && iopen_168 > iclose_64 && iclose_56 > iopen_160 &&
      ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368 && iclose_104 - ilow_416 <= 5.0 * gd_664 && iclose_96 - ilow_408 <= 5.0 * gd_664 &&
      ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iopen_168 <= 5.0 * gd_664 && ihigh_264 - iclose_56 <= 5.0 * gd_664) || (iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iopen_184 > iclose_80 && iopen_176 > iclose_72 && iclose_64 > iopen_168 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && iclose_112 - ilow_424 <= 5.0 * gd_664 && iclose_104 - ilow_416 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iclose_64 <= 5.0 * gd_664) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iopen_192 > iclose_88 && iopen_184 > iclose_80 && iclose_72 > iopen_176 &&
      ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 >= ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && iclose_120 - ilow_432 <= 5.0 * gd_664 && iclose_112 - ilow_424 <= 5.0 * gd_664 &&
      ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iclose_72 <= 5.0 * gd_664) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iopen_200 > iclose_96 && iopen_192 > iclose_88 && iclose_80 > iopen_184 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && iclose_128 - ilow_440 <= 5.0 * gd_664 && iclose_120 - ilow_432 <= 5.0 * gd_664 && ihigh_304 - iopen_200 <= 5.0 * gd_664 && ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iclose_80 <= 5.0 * gd_664) ||
      (iclose_128 > iopen_232 && iopen_224 > iclose_120 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_440 > ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 <= ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 <= ilow_384 && ilow_384 < ilow_376) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 >= iclose_120 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iclose_128 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 >= ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 >= ihigh_296 && ihigh_296 >= ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368))) li_unused_0 = 0;
   if ((pricefilter && close_16 < iclose_96 - 110.0 * gd_664) || (patternsfilter && (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 &&
      iclose_56 > iopen_160 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 > iopen_168 - iclose_64 &&
      iopen_168 - iclose_64 < iclose_56 - iopen_160) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 > iclose_88 - iopen_192 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iopen_176 - iclose_72 && iopen_176 - iclose_72 < iclose_64 - iopen_168 && iclose_64 - iopen_168 <= iclose_56 - iopen_160) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 <= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) ||
      (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 <= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 < iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384) || (iclose_144 < iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 <= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 < ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392) ||
      (iclose_152 < iopen_256 && iclose_144 < iopen_248 && iclose_136 > iopen_240 && iclose_128 <= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 &&
      iclose_96 < iopen_200 && iclose_88 < iopen_192 && ihigh_360 > ihigh_352 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 &&
      ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ilow_464 > ilow_456 && ilow_456 < ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 &&
      ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 >= iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 <= ilow_368) ||
      (iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_224 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 <= ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 <= ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 <= ihigh_288 && ihigh_288 <= ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 >= ilow_424 && ilow_424 >= ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 >= ilow_432 && ilow_432 >= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384) || (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 <= ilow_440 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 <= iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 &&
      ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 &&
      ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 <= ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 >= ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 >= ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 >= ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 < ilow_440 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 >= ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 < ilow_448 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 >= ilow_400 && ilow_400 > ilow_392) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 >= iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 <= iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 <= iopen_208 && iclose_96 <= iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 <= iopen_216 && iclose_104 <= iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) || (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 <= iopen_224 && iclose_112 <= iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ilow_448 > ilow_440 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384))) li_unused_4 = 0;
   if ((pricefilter && close_16 > iclose_96 + 110.0 * gd_664) || (patternsfilter && (iclose_56 >= iclose_64 && iclose_56 >= iclose_72 && iopen_184 > iclose_80 && iclose_88 > iopen_192 &&
      iopen_184 - iclose_80 >= 50.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 < iclose_88 - iopen_192 && iclose_88 - iopen_192 < iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_72 - iopen_176 < 4.0 * (ihigh_280 - iclose_72) && iclose_64 - iopen_168 < 2.0 * (ihigh_272 - iclose_64) && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_88 - iopen_192 < iclose_80 - iopen_184 &&
      iclose_80 - iopen_184 < iclose_72 - iopen_176 && iclose_72 - iopen_176 > iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_64 - iopen_168 < 10.0 * (ihigh_272 - iclose_64) && iclose_56 - iopen_160 < 2.0 * (ihigh_264 - iclose_56)) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && iclose_88 - iopen_192 > 110.0 * gd_664 &&
      iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 >= iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && ihigh_296 > ihigh_288 &&
      ihigh_296 > ihigh_280 && ihigh_296 > ihigh_272 && ihigh_296 > ihigh_264 && ihigh_272 > ihigh_264 && ilow_400 < ihigh_288 && ilow_392 < ihigh_280 && ilow_384 < ihigh_272 &&
      ilow_368 < ihigh_272) || (iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_72 - iopen_176 <= 10.0 * gd_664 && iclose_64 - iopen_168 >= 50.0 * gd_664 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && iopen_160 - ilow_368 <= 5.0 * gd_664) ||
      (iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_80 - iopen_184 <= 10.0 * gd_664 && iclose_72 - iopen_176 >= 50.0 * gd_664 && ihigh_288 < ihigh_280 &&
      ihigh_280 < ihigh_272 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_88 - iopen_192 <= 10.0 * gd_664 && iclose_80 - iopen_184 >= 50.0 * gd_664 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && ihigh_272 < ihigh_280 &&
      ihigh_264 < ihigh_272) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_96 - iopen_200 <= 10.0 * gd_664 && iclose_88 - iopen_192 >= 50.0 * gd_664 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) ||
      (iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_104 - iopen_208 <= 10.0 * gd_664 && iclose_96 - iopen_200 >= 50.0 * gd_664 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && iopen_208 - ilow_416 <= 5.0 * gd_664 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 < ihigh_296 &&
      ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 >= iopen_168 && iclose_56 < iopen_160 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264) ||
      (iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392) ||
      (iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iopen_176 > iclose_72 && iopen_168 > iclose_64 && iclose_56 > iopen_160 &&
      ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368 && iclose_104 - ilow_416 <= 5.0 * gd_664 && iclose_96 - ilow_408 <= 5.0 * gd_664 &&
      ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iopen_168 <= 5.0 * gd_664 && ihigh_264 - iclose_56 <= 5.0 * gd_664) || (iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iopen_184 > iclose_80 && iopen_176 > iclose_72 && iclose_64 > iopen_168 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && iclose_112 - ilow_424 <= 5.0 * gd_664 && iclose_104 - ilow_416 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iclose_64 <= 5.0 * gd_664) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iopen_192 > iclose_88 && iopen_184 > iclose_80 && iclose_72 > iopen_176 &&
      ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 >= ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && iclose_120 - ilow_432 <= 5.0 * gd_664 && iclose_112 - ilow_424 <= 5.0 * gd_664 &&
      ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iclose_72 <= 5.0 * gd_664) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iopen_200 > iclose_96 && iopen_192 > iclose_88 && iclose_80 > iopen_184 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && iclose_128 - ilow_440 <= 5.0 * gd_664 && iclose_120 - ilow_432 <= 5.0 * gd_664 && ihigh_304 - iopen_200 <= 5.0 * gd_664 && ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iclose_80 <= 5.0 * gd_664) ||
      (iclose_128 > iopen_232 && iopen_224 > iclose_120 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_440 > ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 <= ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 <= ilow_384 && ilow_384 < ilow_376) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 >= iclose_120 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iclose_128 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 >= ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 >= ihigh_296 && ihigh_296 >= ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368))) li_unused_0 = 0;
   if ((pricefilter && close_16 < iclose_96 - 110.0 * gd_664) || (patternsfilter && (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 &&
      iclose_56 > iopen_160 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 > iopen_168 - iclose_64 &&
      iopen_168 - iclose_64 < iclose_56 - iopen_160) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 > iclose_88 - iopen_192 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iopen_176 - iclose_72 && iopen_176 - iclose_72 < iclose_64 - iopen_168 && iclose_64 - iopen_168 <= iclose_56 - iopen_160) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 <= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) ||
      (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 <= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 < iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384) || (iclose_144 < iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 <= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 < ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392) ||
      (iclose_152 < iopen_256 && iclose_144 < iopen_248 && iclose_136 > iopen_240 && iclose_128 <= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 &&
      iclose_96 < iopen_200 && iclose_88 < iopen_192 && ihigh_360 > ihigh_352 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 &&
      ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ilow_464 > ilow_456 && ilow_456 < ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 &&
      ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 >= iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 <= ilow_368) ||
      (iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_224 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 <= ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 <= ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 <= ihigh_288 && ihigh_288 <= ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 >= ilow_424 && ilow_424 >= ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 >= ilow_432 && ilow_432 >= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384) || (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 <= ilow_440 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 <= iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 &&
      ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 &&
      ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 <= ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 >= ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 >= ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 >= ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 < ilow_440 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 >= ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 < ilow_448 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 >= ilow_400 && ilow_400 > ilow_392) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 >= iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 <= iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 <= iopen_208 && iclose_96 <= iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 <= iopen_216 && iclose_104 <= iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) || (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 <= iopen_224 && iclose_112 <= iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ilow_448 > ilow_440 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384))) li_unused_4 = 0;
   if ((pricefilter && close_16 > iclose_96 + 110.0 * gd_664) || (patternsfilter && (iclose_56 >= iclose_64 && iclose_56 >= iclose_72 && iopen_184 > iclose_80 && iclose_88 > iopen_192 &&
      iopen_184 - iclose_80 >= 50.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 < iclose_88 - iopen_192 && iclose_88 - iopen_192 < iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_72 - iopen_176 < 4.0 * (ihigh_280 - iclose_72) && iclose_64 - iopen_168 < 2.0 * (ihigh_272 - iclose_64) && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_88 - iopen_192 < iclose_80 - iopen_184 &&
      iclose_80 - iopen_184 < iclose_72 - iopen_176 && iclose_72 - iopen_176 > iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_64 - iopen_168 < 10.0 * (ihigh_272 - iclose_64) && iclose_56 - iopen_160 < 2.0 * (ihigh_264 - iclose_56)) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && iclose_88 - iopen_192 > 110.0 * gd_664 &&
      iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 >= iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && ihigh_296 > ihigh_288 &&
      ihigh_296 > ihigh_280 && ihigh_296 > ihigh_272 && ihigh_296 > ihigh_264 && ihigh_272 > ihigh_264 && ilow_400 < ihigh_288 && ilow_392 < ihigh_280 && ilow_384 < ihigh_272 &&
      ilow_368 < ihigh_272) || (iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_72 - iopen_176 <= 10.0 * gd_664 && iclose_64 - iopen_168 >= 50.0 * gd_664 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && iopen_160 - ilow_368 <= 5.0 * gd_664) ||
      (iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_80 - iopen_184 <= 10.0 * gd_664 && iclose_72 - iopen_176 >= 50.0 * gd_664 && ihigh_288 < ihigh_280 &&
      ihigh_280 < ihigh_272 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_88 - iopen_192 <= 10.0 * gd_664 && iclose_80 - iopen_184 >= 50.0 * gd_664 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && ihigh_272 < ihigh_280 &&
      ihigh_264 < ihigh_272) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_96 - iopen_200 <= 10.0 * gd_664 && iclose_88 - iopen_192 >= 50.0 * gd_664 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) ||
      (iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_104 - iopen_208 <= 10.0 * gd_664 && iclose_96 - iopen_200 >= 50.0 * gd_664 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && iopen_208 - ilow_416 <= 5.0 * gd_664 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 < ihigh_296 &&
      ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 >= iopen_168 && iclose_56 < iopen_160 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264) ||
      (iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392) ||
      (iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iopen_176 > iclose_72 && iopen_168 > iclose_64 && iclose_56 > iopen_160 &&
      ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368 && iclose_104 - ilow_416 <= 5.0 * gd_664 && iclose_96 - ilow_408 <= 5.0 * gd_664 &&
      ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iopen_168 <= 5.0 * gd_664 && ihigh_264 - iclose_56 <= 5.0 * gd_664) || (iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iopen_184 > iclose_80 && iopen_176 > iclose_72 && iclose_64 > iopen_168 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && iclose_112 - ilow_424 <= 5.0 * gd_664 && iclose_104 - ilow_416 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iclose_64 <= 5.0 * gd_664) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iopen_192 > iclose_88 && iopen_184 > iclose_80 && iclose_72 > iopen_176 &&
      ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 >= ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && iclose_120 - ilow_432 <= 5.0 * gd_664 && iclose_112 - ilow_424 <= 5.0 * gd_664 &&
      ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iclose_72 <= 5.0 * gd_664) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iopen_200 > iclose_96 && iopen_192 > iclose_88 && iclose_80 > iopen_184 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && iclose_128 - ilow_440 <= 5.0 * gd_664 && iclose_120 - ilow_432 <= 5.0 * gd_664 && ihigh_304 - iopen_200 <= 5.0 * gd_664 && ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iclose_80 <= 5.0 * gd_664) ||
      (iclose_128 > iopen_232 && iopen_224 > iclose_120 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_440 > ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 <= ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 <= ilow_384 && ilow_384 < ilow_376) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 >= iclose_120 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iclose_128 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 >= ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 >= ihigh_296 && ihigh_296 >= ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368))) li_unused_0 = 0;
   if ((pricefilter && close_16 < iclose_96 - 110.0 * gd_664) || (patternsfilter && (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 &&
      iclose_56 > iopen_160 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 > iopen_168 - iclose_64 &&
      iopen_168 - iclose_64 < iclose_56 - iopen_160) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 > iclose_88 - iopen_192 && iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 > iopen_176 - iclose_72 && iopen_176 - iclose_72 < iclose_64 - iopen_168 && iclose_64 - iopen_168 <= iclose_56 - iopen_160) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 <= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) ||
      (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 <= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 < iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384) || (iclose_144 < iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 <= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 < ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392) ||
      (iclose_152 < iopen_256 && iclose_144 < iopen_248 && iclose_136 > iopen_240 && iclose_128 <= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 &&
      iclose_96 < iopen_200 && iclose_88 < iopen_192 && ihigh_360 > ihigh_352 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 &&
      ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ilow_464 > ilow_456 && ilow_456 < ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 &&
      ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 <= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 >= iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 <= ilow_368) ||
      (iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iopen_232 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) || (iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_224 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 <= ilow_440 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 < ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 <= ilow_448 && ilow_448 < ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 <= ihigh_288 && ihigh_288 <= ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 >= ilow_424 && ilow_424 >= ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_312 <= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 >= ilow_432 && ilow_432 >= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 >= iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 &&
      iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 &&
      ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 &&
      ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384) || (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 > ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 > ilow_448 && ilow_448 <= ilow_440 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 <= iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 <= ihigh_312 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 &&
      ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 &&
      ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 <= ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 >= ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 >= ihigh_296 &&
      ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 >= ilow_384 && ilow_384 > ilow_376) || (iclose_136 > iopen_240 && iclose_128 < iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 < ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ilow_448 < ilow_440 && ilow_440 > ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 >= ilow_392 && ilow_392 > ilow_384) ||
      (iclose_144 > iopen_248 && iclose_136 < iopen_240 && iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 &&
      iclose_88 < iopen_192 && iclose_80 > iopen_184 && ihigh_352 < ihigh_344 && ihigh_344 > ihigh_336 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 >= ihigh_312 &&
      ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ilow_456 < ilow_448 && ilow_448 > ilow_440 && ilow_440 <= ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 >= ilow_400 && ilow_400 > ilow_392) || (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 >= iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 >= iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 < iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 <= iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 >= iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 >= ilow_392 && ilow_392 >= ilow_384 && ilow_384 < ilow_376 && ilow_376 <= ilow_368) || (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 <= iopen_208 && iclose_96 <= iopen_200 && iclose_88 >= iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 <= iopen_216 && iclose_104 <= iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) || (iclose_136 < iopen_240 && iclose_128 < iopen_232 && iclose_120 <= iopen_224 && iclose_112 <= iopen_216 && iclose_104 >= iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && ihigh_344 > ihigh_336 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ilow_448 > ilow_440 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384))) li_unused_4 = 0;
   if ((pricefilter && close_16 > iclose_96 + 110.0 * gd_664) || (patternsfilter && (iclose_56 >= iclose_64 && iclose_56 >= iclose_72 && iopen_184 > iclose_80 && iclose_88 > iopen_192 &&
      iopen_184 - iclose_80 >= 50.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 < iclose_88 - iopen_192 && iclose_88 - iopen_192 < iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_72 - iopen_176 < 4.0 * (ihigh_280 - iclose_72) && iclose_64 - iopen_168 < 2.0 * (ihigh_272 - iclose_64) && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_88 - iopen_192 < iclose_80 - iopen_184 &&
      iclose_80 - iopen_184 < iclose_72 - iopen_176 && iclose_72 - iopen_176 > iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_64 - iopen_168 < 10.0 * (ihigh_272 - iclose_64) && iclose_56 - iopen_160 < 2.0 * (ihigh_264 - iclose_56)) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && iclose_88 - iopen_192 > 110.0 * gd_664 &&
      iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 >= iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && ihigh_296 > ihigh_288 &&
      ihigh_296 > ihigh_280 && ihigh_296 > ihigh_272 && ihigh_296 > ihigh_264 && ihigh_272 > ihigh_264 && ilow_400 < ihigh_288 && ilow_392 < ihigh_280 && ilow_384 < ihigh_272 &&
      ilow_368 < ihigh_272) || (iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_72 - iopen_176 <= 10.0 * gd_664 && iclose_64 - iopen_168 >= 50.0 * gd_664 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && iopen_160 - ilow_368 <= 5.0 * gd_664) ||
      (iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_80 - iopen_184 <= 10.0 * gd_664 && iclose_72 - iopen_176 >= 50.0 * gd_664 && ihigh_288 < ihigh_280 &&
      ihigh_280 < ihigh_272 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_88 - iopen_192 <= 10.0 * gd_664 && iclose_80 - iopen_184 >= 50.0 * gd_664 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && ihigh_272 < ihigh_280 &&
      ihigh_264 < ihigh_272) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_96 - iopen_200 <= 10.0 * gd_664 && iclose_88 - iopen_192 >= 50.0 * gd_664 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) ||
      (iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_104 - iopen_208 <= 10.0 * gd_664 && iclose_96 - iopen_200 >= 50.0 * gd_664 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && iopen_208 - ilow_416 <= 5.0 * gd_664 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 < ihigh_296 &&
      ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 >= iopen_168 && iclose_56 < iopen_160 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264) ||
      (iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392) ||
      (iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iopen_176 > iclose_72 && iopen_168 > iclose_64 && iclose_56 > iopen_160 &&
      ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368 && iclose_104 - ilow_416 <= 5.0 * gd_664 && iclose_96 - ilow_408 <= 5.0 * gd_664 &&
      ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iopen_168 <= 5.0 * gd_664 && ihigh_264 - iclose_56 <= 5.0 * gd_664) || (iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iopen_184 > iclose_80 && iopen_176 > iclose_72 && iclose_64 > iopen_168 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && iclose_112 - ilow_424 <= 5.0 * gd_664 && iclose_104 - ilow_416 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iclose_64 <= 5.0 * gd_664) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iopen_192 > iclose_88 && iopen_184 > iclose_80 && iclose_72 > iopen_176 &&
      ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 >= ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && iclose_120 - ilow_432 <= 5.0 * gd_664 && iclose_112 - ilow_424 <= 5.0 * gd_664 &&
      ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iclose_72 <= 5.0 * gd_664) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iopen_200 > iclose_96 && iopen_192 > iclose_88 && iclose_80 > iopen_184 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && iclose_128 - ilow_440 <= 5.0 * gd_664 && iclose_120 - ilow_432 <= 5.0 * gd_664 && ihigh_304 - iopen_200 <= 5.0 * gd_664 && ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iclose_80 <= 5.0 * gd_664) ||
      (iclose_128 > iopen_232 && iopen_224 > iclose_120 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_440 > ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 <= ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 <= ilow_384 && ilow_384 < ilow_376) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 >= iclose_120 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iclose_128 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 >= ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 >= ihigh_296 && ihigh_296 >= ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368))) li_unused_0 = 0;
   if ((pricefilter && close_16 > iclose_96 + 110.0 * gd_664) || (patternsfilter && (iclose_56 >= iclose_64 && iclose_56 >= iclose_72 && iopen_184 > iclose_80 && iclose_88 > iopen_192 &&
      iopen_184 - iclose_80 >= 50.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_96 - iopen_200 < iclose_88 - iopen_192 && iclose_88 - iopen_192 < iclose_80 - iopen_184 && iclose_80 - iopen_184 > iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_72 - iopen_176 < 4.0 * (ihigh_280 - iclose_72) && iclose_64 - iopen_168 < 2.0 * (ihigh_272 - iclose_64) && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_88 - iopen_192 < iclose_80 - iopen_184 &&
      iclose_80 - iopen_184 < iclose_72 - iopen_176 && iclose_72 - iopen_176 > iclose_64 - iopen_168 && iclose_64 - iopen_168 < iclose_56 - iopen_160 && iclose_64 - iopen_168 < 10.0 * (ihigh_272 - iclose_64) && iclose_56 - iopen_160 < 2.0 * (ihigh_264 - iclose_56)) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 && iclose_88 - iopen_192 > 110.0 * gd_664 &&
      iclose_88 - iopen_192 > iclose_80 - iopen_184 && iclose_80 - iopen_184 >= iclose_72 - iopen_176 && iclose_72 - iopen_176 < iclose_64 - iopen_168 && ihigh_296 > ihigh_288 &&
      ihigh_296 > ihigh_280 && ihigh_296 > ihigh_272 && ihigh_296 > ihigh_264 && ihigh_272 > ihigh_264 && ilow_400 < ihigh_288 && ilow_392 < ihigh_280 && ilow_384 < ihigh_272 &&
      ilow_368 < ihigh_272) || (iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && iclose_72 - iopen_176 <= 10.0 * gd_664 && iclose_64 - iopen_168 >= 50.0 * gd_664 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && iopen_160 - ilow_368 <= 5.0 * gd_664) ||
      (iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_80 - iopen_184 <= 10.0 * gd_664 && iclose_72 - iopen_176 >= 50.0 * gd_664 && ihigh_288 < ihigh_280 &&
      ihigh_280 < ihigh_272 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && iopen_168 - ilow_376 <= 5.0 * gd_664 && ihigh_264 < ihigh_272) ||
      (iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_88 - iopen_192 <= 10.0 * gd_664 && iclose_80 - iopen_184 >= 50.0 * gd_664 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && iopen_176 - ilow_384 <= 5.0 * gd_664 && ihigh_272 < ihigh_280 &&
      ihigh_264 < ihigh_272) || (iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_96 - iopen_200 <= 10.0 * gd_664 && iclose_88 - iopen_192 >= 50.0 * gd_664 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && iopen_184 - ilow_392 <= 5.0 * gd_664 && ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) ||
      (iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_104 - iopen_208 <= 10.0 * gd_664 && iclose_96 - iopen_200 >= 50.0 * gd_664 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && iopen_208 - ilow_416 <= 5.0 * gd_664 && iopen_200 - ilow_408 <= 5.0 * gd_664 && iopen_192 - ilow_400 <= 5.0 * gd_664 && ihigh_288 < ihigh_296 &&
      ihigh_280 < ihigh_288 && ihigh_272 < ihigh_280 && ihigh_264 < ihigh_272) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 >= iopen_168 && iclose_56 < iopen_160 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368 && ihigh_320 <= ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264) ||
      (iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && iclose_56 < iopen_160 &&
      ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384) || (iclose_128 > iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && ihigh_336 > ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ilow_440 > ilow_432 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392) ||
      (iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iopen_176 > iclose_72 && iopen_168 > iclose_64 && iclose_56 > iopen_160 &&
      ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_416 > ilow_408 &&
      ilow_408 > ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368 && iclose_104 - ilow_416 <= 5.0 * gd_664 && iclose_96 - ilow_408 <= 5.0 * gd_664 &&
      ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iopen_168 <= 5.0 * gd_664 && ihigh_264 - iclose_56 <= 5.0 * gd_664) || (iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iopen_184 > iclose_80 && iopen_176 > iclose_72 && iclose_64 > iopen_168 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 > ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376 && iclose_112 - ilow_424 <= 5.0 * gd_664 && iclose_104 - ilow_416 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iopen_176 <= 5.0 * gd_664 && ihigh_272 - iclose_64 <= 5.0 * gd_664) ||
      (iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iopen_192 > iclose_88 && iopen_184 > iclose_80 && iclose_72 > iopen_176 &&
      ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 >= ihigh_280 && ilow_432 > ilow_424 &&
      ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 > ilow_400 && ilow_400 > ilow_392 && ilow_392 < ilow_384 && iclose_120 - ilow_432 <= 5.0 * gd_664 && iclose_112 - ilow_424 <= 5.0 * gd_664 &&
      ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iopen_184 <= 5.0 * gd_664 && ihigh_280 - iclose_72 <= 5.0 * gd_664) || (iclose_128 < iopen_232 && iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iopen_200 > iclose_96 && iopen_192 > iclose_88 && iclose_80 > iopen_184 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 >= ihigh_288 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 < ilow_416 && ilow_416 > ilow_408 && ilow_408 > ilow_400 && ilow_400 < ilow_392 && iclose_128 - ilow_440 <= 5.0 * gd_664 && iclose_120 - ilow_432 <= 5.0 * gd_664 && ihigh_304 - iopen_200 <= 5.0 * gd_664 && ihigh_296 - iopen_192 <= 5.0 * gd_664 && ihigh_288 - iclose_80 <= 5.0 * gd_664) ||
      (iclose_128 > iopen_232 && iopen_224 > iclose_120 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 &&
      iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 &&
      ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 < ihigh_264 && ilow_440 > ilow_432 && ilow_432 < ilow_424 &&
      ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_120 < iopen_224 && iclose_112 >= iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 <= ilow_376 && ilow_376 < ilow_368) ||
      (iclose_128 < iopen_232 && iclose_120 >= iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 &&
      iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 &&
      ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 &&
      ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 <= ilow_384 && ilow_384 < ilow_376) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 && iclose_64 < iopen_168 && iclose_56 < iopen_160 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 > ihigh_264 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 > ilow_368) ||
      (iclose_120 >= iclose_120 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 < iopen_192 && iclose_80 > iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 >= ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 > ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 >= iclose_128 && iclose_120 < iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 > ihigh_328 && ihigh_328 >= ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 > ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 >= iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 < iopen_168 && iclose_56 > iopen_160 && ihigh_328 >= ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 >= ihigh_264 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 <= ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 >= iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && ihigh_336 >= ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 >= ihigh_272 && ilow_440 < ilow_432 && ilow_432 <= ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 <= ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 < iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 > ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 <= ilow_408 && ilow_408 > ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ilow_440 < ilow_432 && ilow_432 < ilow_424 && ilow_424 <= ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 > ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 > iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 > ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 < ihigh_288 &&
      ihigh_288 > ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 > ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 < ilow_368) || (iclose_128 > iopen_232 && iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 > iopen_208 && iclose_96 > iopen_200 && iclose_88 > iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 && iclose_64 > iopen_168 && ihigh_336 < ihigh_328 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 < ihigh_296 && ihigh_296 > ihigh_288 && ihigh_288 < ihigh_280 && ihigh_280 > ihigh_272 && ilow_440 < ilow_432 && ilow_432 > ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376) ||
      (iclose_120 > iopen_224 && iclose_112 < iopen_216 && iclose_104 < iopen_208 && iclose_96 > iopen_200 && iclose_88 < iopen_192 && iclose_80 < iopen_184 && iclose_72 > iopen_176 &&
      iclose_64 > iopen_168 && iclose_56 < iopen_160 && ihigh_328 > ihigh_320 && ihigh_320 > ihigh_312 && ihigh_312 >= ihigh_304 && ihigh_304 >= ihigh_296 && ihigh_296 >= ihigh_288 &&
      ihigh_288 < ihigh_280 && ihigh_280 < ihigh_272 && ihigh_272 > ihigh_264 && ilow_432 < ilow_424 && ilow_424 > ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 &&
      ilow_400 > ilow_392 && ilow_392 < ilow_384 && ilow_384 < ilow_376 && ilow_376 > ilow_368) || (iclose_120 < iopen_224 && iclose_112 > iopen_216 && iclose_104 > iopen_208 && iclose_96 >= iopen_200 && iclose_88 > iopen_192 && iclose_80 > iopen_184 && iclose_72 < iopen_176 && iclose_64 > iopen_168 && iclose_56 > iopen_160 && ihigh_328 < ihigh_320 && ihigh_320 < ihigh_312 && ihigh_312 < ihigh_304 && ihigh_304 <= ihigh_296 && ihigh_296 < ihigh_288 && ihigh_288 > ihigh_280 && ihigh_280 > ihigh_272 && ihigh_272 < ihigh_264 && ilow_432 < ilow_424 && ilow_424 < ilow_416 && ilow_416 < ilow_408 && ilow_408 < ilow_400 && ilow_400 < ilow_392 && ilow_392 < ilow_384 && ilow_384 > ilow_376 && ilow_376 < ilow_368))) li_unused_0 = 0;
   int ord_total_480 = OrdersTotal();
   for (int pos_484 = ord_total_480 - 1; pos_484 >= 0; pos_484--) {
      OrderSelect(pos_484, SELECT_BY_POS);
      bool_472 = FALSE;
      if (OrderSymbol() == Symbol()) {
         if (OrderType() == OP_BUY && High[0] - OrderOpenPrice() >= BreakEven * Point && OrderStopLoss() != OrderOpenPrice()) bool_472 = OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, Green);
         if (OrderType() == OP_SELL && OrderOpenPrice() - Low[0] >= BreakEven * Point && OrderStopLoss() != OrderOpenPrice()) bool_472 = OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, Green);
         error_476 = GetLastError();
      }
   }
}

void profittarget() {
   bool ord_close_0;
   int ord_total_4 = OrdersTotal();
   for (int pos_8 = ord_total_4 - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS);
      ord_close_0 = FALSE;
      if (OrderSymbol() == Symbol() && gd_1672 >= gd_904) {
         if (OrderType() == OP_BUY) ord_close_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
         if (OrderType() == OP_SELL) ord_close_0 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
      }
   }
}

void close_all_orders() {
   int cmd_0;
   bool li_4;
   int ord_total_8 = OrdersTotal();
   for (int pos_12 = ord_total_8 - 1; pos_12 >= 0; pos_12--) {
      OrderSelect(pos_12, SELECT_BY_POS);
      cmd_0 = OrderType();
      li_4 = FALSE;
      switch (cmd_0) {
      case OP_BUY:
         li_4 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), 5, Red);
         break;
      case OP_SELL:
         li_4 = OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), 5, Red);
         break;
      case OP_BUYLIMIT:
      case OP_BUYSTOP:
      case OP_SELLLIMIT:
      case OP_SELLSTOP:
         li_4 = OrderDelete(OrderTicket());
      }
      if (li_4 == FALSE) close_all_orders();
   }
}

void morders() {
   int li_unused_0;
   int ord_total_4 = OrdersTotal();
   for (int pos_8 = ord_total_4 - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS);
      li_unused_0 = 0;
      if (OrderMagicNumber() == 99 && OrderSymbol() == Symbol()) {
         if (OrderType() == OP_SELL) g_count_1732++;
         if (OrderType() == OP_BUY) g_count_1728++;
         if (OrderType() == OP_SELL) gd_1672 += OrderProfit();
         if (OrderType() == OP_BUY) gd_1672 += OrderProfit();
         if (OrderType() == OP_SELL) gd_2008 += OrderProfit();
         if (OrderType() == OP_BUY) gd_2016 += OrderProfit();
         if (OrderType() == OP_SELL) gd_800 += OrderLots();
         if (OrderType() == OP_BUY) gd_808 += OrderLots();
      }
   }
}

void orders() {
   int li_unused_0;
   int ord_total_4 = OrdersTotal();
   for (int pos_8 = ord_total_4 - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS);
      li_unused_0 = 0;
      if (OrderSymbol() == Symbol()) {
         if (OrderType() == OP_SELL) g_count_1732++;
         if (OrderType() == OP_BUY) g_count_1728++;
         if (OrderType() == OP_SELL) gd_1672 += OrderProfit();
         if (OrderType() == OP_BUY) gd_1672 += OrderProfit();
         if (OrderType() == OP_SELL) gd_2008 += OrderProfit();
         if (OrderType() == OP_BUY) gd_2016 += OrderProfit();
         if (OrderType() == OP_SELL) gd_800 += OrderLots();
         if (OrderType() == OP_BUY) gd_808 += OrderLots();
      }
   }
}

void accorders() {
   int li_unused_0;
   int ord_total_4 = OrdersTotal();
   for (int pos_8 = ord_total_4 - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS);
      li_unused_0 = 0;
      if (OrderType() == OP_SELL || OrderType() == OP_BUY) {
         if (OrderType() == OP_SELL) g_count_1744++;
         if (OrderType() == OP_BUY) g_count_1740++;
      }
   }
}

void maccorders() {
   int li_unused_0;
   int ord_total_4 = OrdersTotal();
   for (int pos_8 = ord_total_4 - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS);
      li_unused_0 = 0;
      if (OrderMagicNumber() == 99 && OrderType() == OP_SELL || OrderType() == OP_BUY) {
         if (OrderType() == OP_SELL) g_count_1744++;
         if (OrderType() == OP_BUY) g_count_1740++;
      }
   }
}

void trail() {
   for (int pos_0 = 0; pos_0 < OrdersTotal(); pos_0++) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderType() == OP_BUY) {
            if (Bid - OrderOpenPrice() <= TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT)) continue;
            if (OrderStopLoss() >= Bid - TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT)) continue;
            OrderModify(OrderTicket(), OrderOpenPrice(), Bid - TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT), OrderTakeProfit(), 255);
            continue;
         }
         if (OrderType() == OP_SELL) {
            if (OrderOpenPrice() - Ask > TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT))
               if (OrderStopLoss() > Ask + TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT) || OrderStopLoss() == 0.0) OrderModify(OrderTicket(), OrderOpenPrice(), Ask + TrailingStop * MarketInfo(OrderSymbol(), MODE_POINT), OrderTakeProfit(), 255);
         }
      }
   }
}

int init() {
   g_bars_2112 = Bars;
   if (gi_116) gi_2116 = 0;
   else gi_2116 = 1;
   return (0);
}

int deinit() {
   ObjectsDeleteAll(0, OBJ_HLINE);
   return (0);
}

int start() {
   double ld_12;
   double ld_20;
   double ld_28;
   int ticket_36;
   int li_40;
   double ld_44;
   double ld_52;
   int li_unused_60;
   if (UseHourTrade_longs)
      if (Hour() < FromHourTrade_longs || Hour() > ToHourTrade_longs) gi_1464 = FALSE;
   if (UseHourTrade_longs)
      if (Hour() >= FromHourTrade_longs && Hour() <= ToHourTrade_longs) gi_1464 = TRUE;
   if (UseHourTrade_shorts)
      if (Hour() < FromHourTrade_shorts || Hour() > ToHourTrade_shorts) gi_1468 = FALSE;
   if (UseHourTrade_shorts)
      if (Hour() >= FromHourTrade_shorts && Hour() <= ToHourTrade_shorts) gi_1468 = TRUE;
   if (custom_balance == FALSE) balance = AccountBalance();
   if (auto_tf_settings && Period() == PERIOD_M1) {
      psar = 0.003;
      time_frame_for_signal = 30;
      psar2 = 0.06;
      time_frame_for_signal2 = 5;
   }
   if (auto_tf_settings && Period() == PERIOD_M5) {
      psar = 0.003;
      time_frame_for_signal = 30;
      psar2 = 0.06;
      time_frame_for_signal2 = 5;
   }
   if (auto_tf_settings && Period() == PERIOD_M15) {
      psar = 0.003;
      time_frame_for_signal = 30;
      psar2 = 0.06;
      time_frame_for_signal2 = 5;
   }
   if (auto_tf_settings && Period() == PERIOD_M30) {
      psar = 0.003;
      time_frame_for_signal = 30;
      psar2 = 0.06;
      time_frame_for_signal2 = 5;
   }
   if (auto_tf_settings && Period() == PERIOD_H1) {
      psar = 0.001;
      time_frame_for_signal = 240;
      psar2 = 0.002;
      time_frame_for_signal2 = 60;
   }
   if (auto_tf_settings && Period() == PERIOD_H4) {
      psar = 0.001;
      time_frame_for_signal = 240;
      psar2 = 0.002;
      time_frame_for_signal2 = 60;
   }
   if (auto_tf_settings && Period() == PERIOD_D1) {
      psar = 0.001;
      time_frame_for_signal = 240;
      psar2 = 0.002;
      time_frame_for_signal2 = 60;
   }
   if (auto_tf_settings && Period() == PERIOD_W1) {
      psar = 0.001;
      time_frame_for_signal = 240;
      psar2 = 0.002;
      time_frame_for_signal2 = 60;
   }
   if (auto_tf_settings && Period() == PERIOD_MN1) {
      psar = 0.001;
      time_frame_for_signal = 240;
      psar2 = 0.002;
      time_frame_for_signal2 = 60;
   }
   double ld_64 = 100.0 * ((AccountEquity() - AccountBalance()) / AccountBalance());
   Print("Account equity = ", AccountEquity());
   Print("Account balance = ", balance);
   int li_72 = g_count_1732 + g_count_1728;
   int li_76 = g_count_1732 - g_count_1728;
   int li_unused_80 = 5000.0 * (gd_1672 / LotsOptimized());
   int li_84 = 1;
   if (auto_trade_at_cross && li_72 == 0) trade_at_the_cross_only = FALSE;
   if (auto_trade_at_cross && li_72 > 0) trade_at_the_cross_only = TRUE;
   if (auto_trade_at_cross && gi_796 == 2) trade_at_the_cross_only = TRUE;
   if (DayOfWeek() == 0) li_84 = 2;
   if (DayOfWeek() > 0) li_84 = 1;
   double ld_88 = gd_800 + gd_808;
   double lots_96 = ld_88 - gd_808;
   double lots_104 = ld_88 - gd_800;
   double iclose_112 = iClose(NULL, 0, gi_2116 + 0);
   double ienvelopes_120 = iEnvelopes(NULL, g_timeframe_948, g_period_936, MODE_SMMA, 0, PRICE_CLOSE, g_deviation_940, MODE_UPPER, gi_2116 + 0);
   double ienvelopes_128 = iEnvelopes(NULL, g_timeframe_948, g_period_936, MODE_SMMA, 0, PRICE_CLOSE, g_deviation_940, MODE_LOWER, gi_2116 + 0);
   double ima_136 = iMA(NULL, 0, g_period_1352, gi_1356, g_ma_method_1360, g_applied_price_1364, gi_2116 + 1);
   double ima_144 = iMA(NULL, 0, g_period_1376, gi_1380, g_ma_method_1384, g_applied_price_1388, gi_2116 + 1);
   double iclose_152 = iClose(NULL, 0, gi_2116 + 0);
   double isar_160 = iSAR(NULL, time_frame_for_signal, psar, max, gi_2116 + 0);
   double iclose_168 = iClose(NULL, 0, gi_2116 + 0);
   double isar_176 = iSAR(NULL, time_frame_for_signal2, psar2, max2, gi_2116 + 0);
   double iatr_184 = iATR(NULL, g_timeframe_1176, g_period_1164, 0);
   double ld_192 = gd_1168;
   double ima_200 = iMA(NULL, ema_tf, ema_period, gi_1356, MODE_EMA, g_applied_price_1364, gi_2116 + 0);
   if (ema_filter && iclose_112 > ima_200) {
      gi_76 = TRUE;
      gi_80 = FALSE;
   }
   if (ema_filter && iclose_112 < ima_200) {
      gi_76 = FALSE;
      gi_80 = TRUE;
   }
   if (ema_filter == FALSE) {
      gi_76 = TRUE;
      gi_80 = TRUE;
   }
   double ihigh_208 = iHigh(NULL, PERIOD_MN1, 1);
   double ilow_216 = iLow(NULL, PERIOD_MN1, 1);
   double iopen_224 = iOpen(NULL, PERIOD_MN1, 1);
   double iclose_232 = iClose(NULL, PERIOD_MN1, 1);
   double ihigh_240 = iHigh(NULL, PERIOD_MN1, 2);
   double ilow_248 = iLow(NULL, PERIOD_MN1, 2);
   double iopen_256 = iOpen(NULL, PERIOD_MN1, 2);
   double iclose_264 = iClose(NULL, PERIOD_MN1, 2);
   double ihigh_272 = iHigh(NULL, PERIOD_W1, 1);
   double ilow_280 = iLow(NULL, PERIOD_W1, 1);
   double iopen_288 = iOpen(NULL, PERIOD_W1, 1);
   double iclose_296 = iClose(NULL, PERIOD_W1, 1);
   double ihigh_304 = iHigh(NULL, PERIOD_W1, 2);
   double ilow_312 = iLow(NULL, PERIOD_W1, 2);
   double iopen_320 = iOpen(NULL, PERIOD_W1, 2);
   double iclose_328 = iClose(NULL, PERIOD_W1, 2);
   double ihigh_336 = iHigh(NULL, PERIOD_H1, 1);
   double ilow_344 = iLow(NULL, PERIOD_H1, 1);
   double iopen_352 = iOpen(NULL, PERIOD_H1, 1);
   double iclose_360 = iClose(NULL, PERIOD_H1, 1);
   double ihigh_368 = iHigh(NULL, PERIOD_H1, 2);
   double ilow_376 = iLow(NULL, PERIOD_H1, 2);
   double iopen_384 = iOpen(NULL, PERIOD_H1, 2);
   double iclose_392 = iClose(NULL, PERIOD_H1, 2);
   double ihigh_400 = iHigh(NULL, PERIOD_H4, 1);
   double ilow_408 = iLow(NULL, PERIOD_H4, 1);
   double iopen_416 = iOpen(NULL, PERIOD_H4, 1);
   double iclose_424 = iClose(NULL, PERIOD_H4, 1);
   double ihigh_432 = iHigh(NULL, PERIOD_H4, 2);
   double ilow_440 = iLow(NULL, PERIOD_H4, 2);
   double iopen_448 = iOpen(NULL, PERIOD_H4, 2);
   double iclose_456 = iClose(NULL, PERIOD_H4, 2);
   double ihigh_464 = iHigh(NULL, PERIOD_D1, 1);
   double ilow_472 = iLow(NULL, PERIOD_D1, 1);
   double iopen_480 = iOpen(NULL, PERIOD_D1, 1);
   double iclose_488 = iClose(NULL, PERIOD_D1, 1);
   double ihigh_496 = iHigh(NULL, PERIOD_D1, 2);
   double ilow_504 = iLow(NULL, PERIOD_D1, 2);
   double iopen_512 = iOpen(NULL, PERIOD_D1, 2);
   double iclose_520 = iClose(NULL, PERIOD_D1, 2);
   double ihigh_528 = iHigh(NULL, PERIOD_H1, bars_back);
   double ilow_536 = iLow(NULL, PERIOD_H1, bars_back);
   double iopen_544 = iOpen(NULL, PERIOD_H1, bars_back);
   double iclose_552 = iClose(NULL, PERIOD_H1, bars_back);
   double ld_560 = ihigh_528 - ilow_536;
   double price_568 = 100.0 * (ld_560 / 100.0) + ilow_536;
   double price_576 = 76.4 * (ld_560 / 100.0) + ilow_536;
   double price_584 = 61.8 * (ld_560 / 100.0) + ilow_536;
   double price_592 = 50.0 * (ld_560 / 100.0) + ilow_536;
   double price_600 = 38.2 * (ld_560 / 100.0) + ilow_536;
   double price_608 = 23.6 * (ld_560 / 100.0) + ilow_536;
   double price_616 = 0.0 * (ld_560 / 100.0) + ilow_536;
   if (gi_2044 && ObjectFind("h11_100") != 0) {
      ObjectCreate("h11_100", OBJ_HLINE, 0, Time[0], price_568);
      ObjectSet("h11_100", OBJPROP_COLOR, White);
      ObjectSet("h11_100", OBJPROP_WIDTH, 0);
   } else ObjectMove("h11_100", 0, Time[0], price_568);
   if (gi_2044 && ObjectFind("h11_73") != 0) {
      ObjectCreate("h11_73", OBJ_HLINE, 0, Time[0], price_576);
      ObjectSet("h11_73", OBJPROP_COLOR, White);
      ObjectSet("h11_73", OBJPROP_WIDTH, 0);
   } else ObjectMove("h11_73", 0, Time[0], price_576);
   if (gi_2044 && ObjectFind("h11_61") != 0) {
      ObjectCreate("h11_61", OBJ_HLINE, 0, Time[0], price_584);
      ObjectSet("h11_61", OBJPROP_COLOR, White);
      ObjectSet("h11_61", OBJPROP_WIDTH, 0);
   } else ObjectMove("h11_61", 0, Time[0], price_584);
   if (gi_2044 && ObjectFind("h11_50") != 0) {
      ObjectCreate("h11_50", OBJ_HLINE, 0, Time[0], price_592);
      ObjectSet("h11_50", OBJPROP_COLOR, White);
      ObjectSet("h11_50", OBJPROP_WIDTH, 0);
   } else ObjectMove("h11_50", 0, Time[0], price_592);
   if (gi_2044 && ObjectFind("h11_38") != 0) {
      ObjectCreate("h11_38", OBJ_HLINE, 0, Time[0], price_600);
      ObjectSet("h11_38", OBJPROP_COLOR, White);
      ObjectSet("h11_38", OBJPROP_WIDTH, 0);
   } else ObjectMove("h11_38", 0, Time[0], price_600);
   if (gi_2044 && ObjectFind("h11_23") != 0) {
      ObjectCreate("h11_23", OBJ_HLINE, 0, Time[0], price_608);
      ObjectSet("h11_23", OBJPROP_COLOR, White);
      ObjectSet("h11_23", OBJPROP_WIDTH, 0);
   } else ObjectMove("h11_23", 0, Time[0], price_608);
   if (gi_2044 && ObjectFind("h11_0") != 0) {
      ObjectCreate("h11_0", OBJ_HLINE, 0, Time[0], price_616);
      ObjectSet("h11_0", OBJPROP_COLOR, White);
      ObjectSet("h11_0", OBJPROP_WIDTH, 0);
   } else ObjectMove("h11_0", 0, Time[0], price_616);
   double ihigh_624 = iHigh(NULL, PERIOD_H4, bars_back);
   double ilow_632 = iLow(NULL, PERIOD_H4, bars_back);
   double iopen_640 = iOpen(NULL, PERIOD_H4, bars_back);
   double iclose_648 = iClose(NULL, PERIOD_H4, bars_back);
   double ld_656 = ihigh_624 - ilow_632;
   double price_664 = 100.0 * (ld_656 / 100.0) + ilow_632;
   double price_672 = 76.4 * (ld_656 / 100.0) + ilow_632;
   double price_680 = 61.8 * (ld_656 / 100.0) + ilow_632;
   double price_688 = 50.0 * (ld_656 / 100.0) + ilow_632;
   double price_696 = 38.2 * (ld_656 / 100.0) + ilow_632;
   double price_704 = 23.6 * (ld_656 / 100.0) + ilow_632;
   double price_712 = 0.0 * (ld_656 / 100.0) + ilow_632;
   if (gi_2048 && ObjectFind("h41_100") != 0) {
      ObjectCreate("h41_100", OBJ_HLINE, 0, Time[0], price_664);
      ObjectSet("h41_100", OBJPROP_COLOR, Yellow);
      ObjectSet("h41_100", OBJPROP_WIDTH, 0);
   } else ObjectMove("h41_100", 0, Time[0], price_664);
   if (gi_2048 && ObjectFind("h41_73") != 0) {
      ObjectCreate("h41_73", OBJ_HLINE, 0, Time[0], price_672);
      ObjectSet("h41_73", OBJPROP_COLOR, Yellow);
      ObjectSet("h41_73", OBJPROP_WIDTH, 0);
   } else ObjectMove("h41_73", 0, Time[0], price_672);
   if (gi_2048 && ObjectFind("h41_61") != 0) {
      ObjectCreate("h41_61", OBJ_HLINE, 0, Time[0], price_680);
      ObjectSet("h41_61", OBJPROP_COLOR, Yellow);
      ObjectSet("h41_61", OBJPROP_WIDTH, 0);
   } else ObjectMove("h41_61", 0, Time[0], price_680);
   if (gi_2048 && ObjectFind("h41_50") != 0) {
      ObjectCreate("h41_50", OBJ_HLINE, 0, Time[0], price_688);
      ObjectSet("h41_50", OBJPROP_COLOR, Yellow);
      ObjectSet("h41_50", OBJPROP_WIDTH, 0);
   } else ObjectMove("h41_50", 0, Time[0], price_688);
   if (gi_2048 && ObjectFind("h41_38") != 0) {
      ObjectCreate("h41_38", OBJ_HLINE, 0, Time[0], price_696);
      ObjectSet("h41_38", OBJPROP_COLOR, Yellow);
      ObjectSet("h41_38", OBJPROP_WIDTH, 0);
   } else ObjectMove("h41_38", 0, Time[0], price_696);
   if (gi_2048 && ObjectFind("h41_23") != 0) {
      ObjectCreate("h41_23", OBJ_HLINE, 0, Time[0], price_704);
      ObjectSet("h41_23", OBJPROP_COLOR, Yellow);
      ObjectSet("h41_23", OBJPROP_WIDTH, 0);
   } else ObjectMove("h41_23", 0, Time[0], price_704);
   if (gi_2048 && ObjectFind("h41_0") != 0) {
      ObjectCreate("h41_0", OBJ_HLINE, 0, Time[0], price_712);
      ObjectSet("h41_0", OBJPROP_COLOR, Yellow);
      ObjectSet("h41_0", OBJPROP_WIDTH, 0);
   } else ObjectMove("h41_0", 0, Time[0], price_712);
   double ihigh_720 = iHigh(NULL, PERIOD_D1, bars_back);
   double ilow_728 = iLow(NULL, PERIOD_D1, bars_back);
   double iopen_736 = iOpen(NULL, PERIOD_D1, bars_back);
   double iclose_744 = iClose(NULL, PERIOD_D1, bars_back);
   double ld_752 = ihigh_720 - ilow_728;
   double price_760 = 100.0 * (ld_752 / 100.0) + ilow_728;
   double price_768 = 76.4 * (ld_752 / 100.0) + ilow_728;
   double price_776 = 61.8 * (ld_752 / 100.0) + ilow_728;
   double price_784 = 50.0 * (ld_752 / 100.0) + ilow_728;
   double price_792 = 38.2 * (ld_752 / 100.0) + ilow_728;
   double price_800 = 23.6 * (ld_752 / 100.0) + ilow_728;
   double price_808 = 0.0 * (ld_752 / 100.0) + ilow_728;
   if (gi_2052 && ObjectFind("day1_100") != 0) {
      ObjectCreate("day1_100", OBJ_HLINE, 0, Time[0], price_760);
      ObjectSet("day1_100", OBJPROP_COLOR, Orange);
      ObjectSet("day1_100", OBJPROP_WIDTH, 0);
   } else ObjectMove("day1_100", 0, Time[0], price_760);
   if (gi_2052 && ObjectFind("day1_73") != 0) {
      ObjectCreate("day1_73", OBJ_HLINE, 0, Time[0], price_768);
      ObjectSet("day1_73", OBJPROP_COLOR, Orange);
      ObjectSet("day1_73", OBJPROP_WIDTH, 0);
   } else ObjectMove("day1_73", 0, Time[0], price_768);
   if (gi_2052 && ObjectFind("day1_61") != 0) {
      ObjectCreate("day1_61", OBJ_HLINE, 0, Time[0], price_776);
      ObjectSet("day1_61", OBJPROP_COLOR, Orange);
      ObjectSet("day1_61", OBJPROP_WIDTH, 0);
   } else ObjectMove("day1_61", 0, Time[0], price_776);
   if (gi_2052 && ObjectFind("day1_50") != 0) {
      ObjectCreate("day1_50", OBJ_HLINE, 0, Time[0], price_784);
      ObjectSet("day1_50", OBJPROP_COLOR, Orange);
      ObjectSet("day1_50", OBJPROP_WIDTH, 0);
   } else ObjectMove("day1_50", 0, Time[0], price_784);
   if (gi_2052 && ObjectFind("day1_38") != 0) {
      ObjectCreate("day1_38", OBJ_HLINE, 0, Time[0], price_792);
      ObjectSet("day1_38", OBJPROP_COLOR, Orange);
      ObjectSet("day1_38", OBJPROP_WIDTH, 0);
   } else ObjectMove("day1_38", 0, Time[0], price_792);
   if (gi_2052 && ObjectFind("day1_23") != 0) {
      ObjectCreate("day1_23", OBJ_HLINE, 0, Time[0], price_800);
      ObjectSet("day1_23", OBJPROP_COLOR, Orange);
      ObjectSet("day1_23", OBJPROP_WIDTH, 0);
   } else ObjectMove("day1_23", 0, Time[0], price_800);
   if (gi_2052 && ObjectFind("day1_0") != 0) {
      ObjectCreate("day1_0", OBJ_HLINE, 0, Time[0], price_808);
      ObjectSet("day1_0", OBJPROP_COLOR, Orange);
      ObjectSet("day1_0", OBJPROP_WIDTH, 0);
   } else ObjectMove("day1_0", 0, Time[0], price_808);
   double ihigh_816 = iHigh(NULL, PERIOD_W1, bars_back);
   double ilow_824 = iLow(NULL, PERIOD_W1, bars_back);
   double iopen_832 = iOpen(NULL, PERIOD_W1, bars_back);
   double iclose_840 = iClose(NULL, PERIOD_W1, bars_back);
   double ld_848 = -0.618;
   double ld_856 = -1.618;
   double ld_864 = ihigh_816 - ilow_824;
   double ld_872 = 261.8 * (ld_864 / 100.0) + ilow_824;
   double ld_880 = 161.8 * (ld_864 / 100.0) + ilow_824;
   double price_888 = 100.0 * (ld_864 / 100.0) + ilow_824;
   double price_896 = 76.4 * (ld_864 / 100.0) + ilow_824;
   double price_904 = 61.8 * (ld_864 / 100.0) + ilow_824;
   double price_912 = 50.0 * (ld_864 / 100.0) + ilow_824;
   double price_920 = 38.2 * (ld_864 / 100.0) + ilow_824;
   double price_928 = 23.6 * (ld_864 / 100.0) + ilow_824;
   double price_936 = 0.0 * (ld_864 / 100.0) + ilow_824;
   double ld_944 = ld_864 / 100.0 * ld_848 + ilow_824;
   double ld_952 = ld_864 / 100.0 * ld_856 + ilow_824;
   if (gi_2056 && ObjectFind("week1_100") != 0) {
      ObjectCreate("week1_100", OBJ_HLINE, 0, Time[0], price_888);
      ObjectSet("week1_100", OBJPROP_COLOR, Red);
      ObjectSet("week1_100", OBJPROP_WIDTH, 0);
   } else ObjectMove("week1_100", 0, Time[0], price_888);
   if (gi_2056 && ObjectFind("week1_73") != 0) {
      ObjectCreate("week1_73", OBJ_HLINE, 0, Time[0], price_896);
      ObjectSet("week1_73", OBJPROP_COLOR, Red);
      ObjectSet("week1_73", OBJPROP_WIDTH, 0);
   } else ObjectMove("week1_73", 0, Time[0], price_896);
   if (gi_2056 && ObjectFind("week1_61") != 0) {
      ObjectCreate("week1_61", OBJ_HLINE, 0, Time[0], price_904);
      ObjectSet("week1_61", OBJPROP_COLOR, Red);
      ObjectSet("week1_61", OBJPROP_WIDTH, 0);
   } else ObjectMove("week1_61", 0, Time[0], price_904);
   if (gi_2056 && ObjectFind("week1_50") != 0) {
      ObjectCreate("week1_50", OBJ_HLINE, 0, Time[0], price_912);
      ObjectSet("week1_50", OBJPROP_COLOR, Red);
      ObjectSet("week1_50", OBJPROP_WIDTH, 0);
   } else ObjectMove("week1_50", 0, Time[0], price_912);
   if (gi_2056 && ObjectFind("week1_38") != 0) {
      ObjectCreate("week1_38", OBJ_HLINE, 0, Time[0], price_920);
      ObjectSet("week1_38", OBJPROP_COLOR, Red);
      ObjectSet("week1_38", OBJPROP_WIDTH, 0);
   } else ObjectMove("week1_38", 0, Time[0], price_920);
   if (gi_2056 && ObjectFind("week1_23") != 0) {
      ObjectCreate("week1_23", OBJ_HLINE, 0, Time[0], price_928);
      ObjectSet("week1_23", OBJPROP_COLOR, Red);
      ObjectSet("week1_23", OBJPROP_WIDTH, 0);
   } else ObjectMove("week1_23", 0, Time[0], price_928);
   if (gi_2056 && ObjectFind("week1_0") != 0) {
      ObjectCreate("week1_0", OBJ_HLINE, 0, Time[0], price_936);
      ObjectSet("week1_0", OBJPROP_COLOR, Red);
      ObjectSet("week1_0", OBJPROP_WIDTH, 0);
   } else ObjectMove("week1_0", 0, Time[0], price_936);
   double ihigh_960 = iHigh(NULL, PERIOD_MN1, bars_back);
   double ilow_968 = iLow(NULL, PERIOD_MN1, bars_back);
   double iopen_976 = iOpen(NULL, PERIOD_MN1, bars_back);
   double iclose_984 = iClose(NULL, PERIOD_MN1, bars_back);
   double ld_992 = ihigh_960 - ilow_968;
   double price_1000 = 100.0 * (ld_992 / 100.0) + ilow_968;
   double price_1008 = 76.4 * (ld_992 / 100.0) + ilow_968;
   double price_1016 = 61.8 * (ld_992 / 100.0) + ilow_968;
   double price_1024 = 50.0 * (ld_992 / 100.0) + ilow_968;
   double price_1032 = 38.2 * (ld_992 / 100.0) + ilow_968;
   double price_1040 = 23.6 * (ld_992 / 100.0) + ilow_968;
   double price_1048 = 0.0 * (ld_992 / 100.0) + ilow_968;
   if (gi_2060 && ObjectFind("month1_100") != 0) {
      ObjectCreate("month1_100", OBJ_HLINE, 0, Time[0], price_1000);
      ObjectSet("month1_100", OBJPROP_COLOR, Blue);
      ObjectSet("month1_100", OBJPROP_WIDTH, 0);
   } else ObjectMove("month1_100", 0, Time[0], price_1000);
   if (gi_2060 && ObjectFind("month1_73") != 0) {
      ObjectCreate("month1_73", OBJ_HLINE, 0, Time[0], price_1008);
      ObjectSet("month1_73", OBJPROP_COLOR, Blue);
      ObjectSet("month1_73", OBJPROP_WIDTH, 0);
   } else ObjectMove("month1_73", 0, Time[0], price_1008);
   if (gi_2060 && ObjectFind("month1_61") != 0) {
      ObjectCreate("month1_61", OBJ_HLINE, 0, Time[0], price_1016);
      ObjectSet("month1_61", OBJPROP_COLOR, Blue);
      ObjectSet("month1_61", OBJPROP_WIDTH, 0);
   } else ObjectMove("month1_61", 0, Time[0], price_1016);
   if (gi_2060 && ObjectFind("month1_50") != 0) {
      ObjectCreate("month1_50", OBJ_HLINE, 0, Time[0], price_1024);
      ObjectSet("month1_50", OBJPROP_COLOR, Blue);
      ObjectSet("month1_50", OBJPROP_WIDTH, 0);
   } else ObjectMove("month1_50", 0, Time[0], price_1024);
   if (gi_2060 && ObjectFind("month1_38") != 0) {
      ObjectCreate("month1_38", OBJ_HLINE, 0, Time[0], price_1032);
      ObjectSet("month1_38", OBJPROP_COLOR, Blue);
      ObjectSet("month1_38", OBJPROP_WIDTH, 0);
   } else ObjectMove("month1_38", 0, Time[0], price_1032);
   if (gi_2060 && ObjectFind("month1_23") != 0) {
      ObjectCreate("month1_23", OBJ_HLINE, 0, Time[0], price_1040);
      ObjectSet("month1_23", OBJPROP_COLOR, Blue);
      ObjectSet("month1_23", OBJPROP_WIDTH, 0);
   } else ObjectMove("month1_23", 0, Time[0], price_1040);
   if (gi_2060 && ObjectFind("month1_0") != 0) {
      ObjectCreate("month1_0", OBJ_HLINE, 0, Time[0], price_1048);
      ObjectSet("month1_0", OBJPROP_COLOR, Blue);
      ObjectSet("month1_0", OBJPROP_WIDTH, 0);
   } else ObjectMove("month1_0", 0, Time[0], price_1048);
   double ihigh_1056 = iHigh(NULL, piv_period, li_84);
   double ilow_1064 = iLow(NULL, piv_period, li_84);
   double ld_1072 = ihigh_1056 / 2.0;
   double ld_1080 = ilow_1064 / 2.0;
   double ld_1088 = ld_1072 + ld_1080;
   double ld_1096 = ld_1088 / 2.0;
   double ld_1104 = ld_1096 + ld_1072;
   double ld_1112 = ld_1096 + ld_1080;
   double ihigh_1120 = iHigh(NULL, h4_tf, bars_back);
   double ilow_1128 = iLow(NULL, h4_tf, bars_back);
   double ihigh_1136 = iHigh(NULL, h_l_tf, 1);
   double ilow_1144 = iLow(NULL, h_l_tf, 1);
   double ld_1152 = ihigh_1120 / 2.0;
   double ld_1160 = ilow_1128 / 2.0;
   double ld_1168 = ihigh_1120 - ilow_1128;
   double price_1176 = ld_1168 / 100.0 * h4 + ilow_1128;
   double ld_1184 = price_1176 / 2.0;
   double ld_1192 = ld_1184 + ld_1152;
   double ld_1200 = ld_1184 + ld_1160;
   double ihigh_1208 = iHigh(NULL, mn_tf, bars_back);
   double ilow_1216 = iLow(NULL, mn_tf, bars_back);
   double ld_1224 = ihigh_1208 / 2.0;
   double ld_1232 = ilow_1216 / 2.0;
   double ld_1240 = ihigh_1208 - ilow_1216;
   double price_1248 = ld_1240 / 100.0 * mn + ilow_1216;
   double ld_1256 = price_1248 / 2.0;
   double ld_1264 = ld_1256 + ld_1224;
   double ld_1272 = ld_1256 + ld_1232;
   double ihigh_1280 = iHigh(NULL, w1_tf, bars_back);
   double ilow_1288 = iLow(NULL, w1_tf, bars_back);
   double ld_1296 = ihigh_1280 / 2.0;
   double ld_1304 = ilow_1288 / 2.0;
   double ld_1312 = ihigh_1280 - ilow_1288;
   double price_1320 = ld_1312 / 100.0 * w1 + ilow_1288;
   double ld_1328 = price_1320 / 2.0;
   double ld_1336 = ld_1328 + ld_1296;
   double ld_1344 = ld_1328 + ld_1304;
   double ihigh_1352 = iHigh(NULL, d1_tf, li_84);
   double ilow_1360 = iLow(NULL, d1_tf, li_84);
   double ld_1368 = ihigh_1352 / 2.0;
   double ld_1376 = ilow_1360 / 2.0;
   double ld_1384 = ihigh_1352 - ilow_1360;
   double price_1392 = ld_1384 / 100.0 * d1 + ilow_1360;
   double ld_1400 = price_1392 / 2.0;
   double ld_1408 = ld_1400 + ld_1368;
   double ld_1416 = ld_1400 + ld_1376;
   double ihigh_1424 = iHigh(NULL, h1_tf, bars_back);
   double ilow_1432 = iLow(NULL, h1_tf, bars_back);
   double ld_1440 = ihigh_1424 / 2.0;
   double ld_1448 = ilow_1432 / 2.0;
   double ld_1456 = ihigh_1424 - ilow_1432;
   double price_1464 = ld_1456 / 100.0 * h1 + ilow_1432;
   double ld_1472 = price_1464 / 2.0;
   double ld_1480 = ld_1472 + ld_1440;
   double ld_1488 = ld_1472 + ld_1448;
   double ihigh_1496 = iHigh(NULL, h4_tfs, bars_back);
   double ilow_1504 = iLow(NULL, h4_tfs, bars_back);
   double ld_1512 = ihigh_1496 / 2.0;
   double ld_1520 = ilow_1504 / 2.0;
   double ld_1528 = ihigh_1496 - ilow_1504;
   double price_1536 = ld_1528 / 100.0 * h4s + ilow_1504;
   double ld_1544 = price_1536 / 2.0;
   double ld_1552 = ld_1544 + ld_1512;
   double ld_1560 = ld_1544 + ld_1520;
   double ihigh_1568 = iHigh(NULL, mn_tfs, bars_back);
   double ilow_1576 = iLow(NULL, mn_tfs, bars_back);
   double ld_1584 = ihigh_1568 / 2.0;
   double ld_1592 = ilow_1576 / 2.0;
   double ld_1600 = ihigh_1208 - ilow_1576;
   double price_1608 = ld_1600 / 100.0 * mns + ilow_1576;
   double ld_1616 = price_1608 / 2.0;
   double ld_1624 = ld_1616 + ld_1584;
   double ld_1632 = ld_1616 + ld_1592;
   double ihigh_1640 = iHigh(NULL, w1_tfs, bars_back);
   double ilow_1648 = iLow(NULL, w1_tfs, bars_back);
   double ld_1656 = ihigh_1640 / 2.0;
   double ld_1664 = ilow_1648 / 2.0;
   double ld_1672 = ihigh_1640 - ilow_1648;
   double price_1680 = ld_1672 / 100.0 * w1s + ilow_1648;
   double ld_1688 = price_1680 / 2.0;
   double ld_1696 = ld_1688 + ld_1656;
   double ld_1704 = ld_1688 + ld_1664;
   double ihigh_1712 = iHigh(NULL, d1_tfs, li_84);
   double ilow_1720 = iLow(NULL, d1_tfs, li_84);
   double ld_1728 = ihigh_1712 / 2.0;
   double ld_1736 = ilow_1720 / 2.0;
   double ld_1744 = ihigh_1712 - ilow_1720;
   double price_1752 = ld_1744 / 100.0 * d1s + ilow_1720;
   double ld_1760 = price_1752 / 2.0;
   double ld_1768 = ld_1760 + ld_1728;
   double ld_1776 = ld_1760 + ld_1736;
   double ihigh_1784 = iHigh(NULL, h1_tfs, bars_back);
   double ilow_1792 = iLow(NULL, h1_tfs, bars_back);
   double ld_1800 = ihigh_1784 / 2.0;
   double ld_1808 = ilow_1792 / 2.0;
   double ld_1816 = ihigh_1784 - ilow_1792;
   double price_1824 = ld_1816 / 100.0 * h1s + ilow_1792;
   double ld_1832 = price_1824 / 2.0;
   double ld_1840 = ld_1832 + ld_1800;
   double ld_1848 = ld_1832 + ld_1808;
   if (show_piv_lines && ObjectFind("hpivots") != 0) {
      ObjectCreate("hpivots", OBJ_HLINE, 0, Time[0], price_1824);
      ObjectSet("hpivots", OBJPROP_COLOR, White);
      ObjectSet("hpivots", OBJPROP_WIDTH, 0);
   } else ObjectMove("hpivots", 0, Time[0], price_1824);
   if (show_piv_lines && ObjectFind("hpivot") != 0) {
      ObjectCreate("hpivot", OBJ_HLINE, 0, Time[0], price_1464);
      ObjectSet("hpivot", OBJPROP_COLOR, White);
      ObjectSet("hpivot", OBJPROP_WIDTH, 0);
   } else ObjectMove("hpivot", 0, Time[0], price_1464);
   if (show_piv_lines && ObjectFind("pivots") != 0) {
      ObjectCreate("pivots", OBJ_HLINE, 0, Time[0], price_1536);
      ObjectSet("pivots", OBJPROP_COLOR, Orange);
      ObjectSet("pivots", OBJPROP_WIDTH, 0);
   } else ObjectMove("pivots", 0, Time[0], price_1536);
   if (show_piv_lines && ObjectFind("pivot") != 0) {
      ObjectCreate("pivot", OBJ_HLINE, 0, Time[0], price_1176);
      ObjectSet("pivot", OBJPROP_COLOR, Orange);
      ObjectSet("pivot", OBJPROP_WIDTH, 0);
   } else ObjectMove("pivot", 0, Time[0], price_1176);
   if (show_piv_lines && ObjectFind("dpivots") != 0) {
      ObjectCreate("dpivots", OBJ_HLINE, 0, Time[0], price_1752);
      ObjectSet("dpivots", OBJPROP_COLOR, OrangeRed);
      ObjectSet("dpivots", OBJPROP_WIDTH, 0);
   } else ObjectMove("dpivots", 0, Time[0], price_1752);
   if (show_piv_lines && ObjectFind("dpivot") != 0) {
      ObjectCreate("dpivot", OBJ_HLINE, 0, Time[0], price_1392);
      ObjectSet("dpivot", OBJPROP_COLOR, OrangeRed);
      ObjectSet("dpivot", OBJPROP_WIDTH, 0);
   } else ObjectMove("dpivot", 0, Time[0], price_1392);
   if (show_piv_lines && ObjectFind("wpivots") != 0) {
      ObjectCreate("wpivots", OBJ_HLINE, 0, Time[0], price_1680);
      ObjectSet("wpivots", OBJPROP_COLOR, Red);
      ObjectSet("wpivots", OBJPROP_WIDTH, 0);
   } else ObjectMove("wpivots", 0, Time[0], price_1680);
   if (show_piv_lines && ObjectFind("wpivot") != 0) {
      ObjectCreate("wpivot", OBJ_HLINE, 0, Time[0], price_1320);
      ObjectSet("wpivot", OBJPROP_COLOR, Red);
      ObjectSet("wpivot", OBJPROP_WIDTH, 0);
   } else ObjectMove("wpivot", 0, Time[0], price_1320);
   if (show_piv_lines && ObjectFind("mpivots") != 0) {
      ObjectCreate("mpivots", OBJ_HLINE, 0, Time[0], price_1608);
      ObjectSet("mpivots", OBJPROP_COLOR, Blue);
      ObjectSet("mpivots", OBJPROP_WIDTH, 0);
   } else ObjectMove("mpivots", 0, Time[0], price_1608);
   if (show_piv_lines && ObjectFind("mpivot") != 0) {
      ObjectCreate("mpivot", OBJ_HLINE, 0, Time[0], price_1248);
      ObjectSet("mpivot", OBJPROP_COLOR, Blue);
      ObjectSet("mpivot", OBJPROP_WIDTH, 0);
   } else ObjectMove("mpivot", 0, Time[0], price_1248);
   if (iclose_112 == price_1464) gi_unused_1028 = TRUE;
   if (iclose_112 == price_1824) gi_unused_1032 = TRUE;
   if (iclose_112 == price_1176) gi_unused_1036 = TRUE;
   if (iclose_112 == price_1536) gi_unused_1040 = TRUE;
   if (iclose_112 == price_1392) gi_unused_1044 = TRUE;
   if (iclose_112 == price_1752) gi_unused_1048 = TRUE;
   if (iclose_112 == price_1320) gi_unused_1052 = TRUE;
   if (iclose_112 == price_1680) gi_unused_1056 = TRUE;
   if (iclose_112 == price_1248) gi_unused_1060 = TRUE;
   if (iclose_112 == price_1608) gi_unused_1064 = TRUE;
   if (hi_lo_filter && iclose_112 > ihigh_1136) {
      gi_756 = TRUE;
      gi_760 = FALSE;
   }
   if (hi_lo_filter && iclose_112 < ihigh_1136) gi_756 = FALSE;
   if (hi_lo_filter && iclose_112 > ilow_1144) gi_760 = FALSE;
   if (hi_lo_filter && iclose_112 < ilow_1144) {
      gi_756 = FALSE;
      gi_760 = TRUE;
   }
   if (pivot_filter && iclose_112 > price_1176 && iclose_112 > price_1464 && iclose_112 > price_1392 && iclose_112 > price_1320 && iclose_112 > price_1248) gi_756 = TRUE;
   if (pivot_filter && iclose_112 < price_1176 || iclose_112 < price_1464 || iclose_112 < price_1392 || iclose_112 < price_1320 || iclose_112 < price_1248) gi_756 = FALSE;
   if (pivot_filter && iclose_112 > price_1536 || iclose_112 > price_1824 || iclose_112 > price_1752 || iclose_112 > price_1680 || iclose_112 > price_1608) gi_760 = FALSE;
   if (pivot_filter && iclose_112 < price_1536 && iclose_112 < price_1824 && iclose_112 < price_1752 && iclose_112 < price_1680 && iclose_112 < price_1608) gi_760 = TRUE;
   if (one_pivot && iclose_112 > ld_1104) gi_756 = TRUE;
   if (one_pivot && iclose_112 < ld_1104) gi_756 = FALSE;
   if (one_pivot && iclose_112 > ld_1112) gi_760 = FALSE;
   if (one_pivot && iclose_112 < ld_1112) gi_760 = TRUE;
   if (gd_1704 > 0.0 && gi_772 && Minute() == 1) Closeprofit();
   if (gi_1268 && ld_64 < gd_1272) gi_1484 = TRUE;
   if (gi_1268 && ld_64 > gd_1272) gi_1484 = FALSE;
   if (gi_1280 && ld_64 < gd_1284) gi_1504 = TRUE;
   if (gi_1280 && ld_64 > gd_1284) gi_1504 = FALSE;
   if (gi_1476 == 4) gi_1476 = 1;
   if (gi_1480 == 4) gi_1480 = 1;
   if (gi_1480 == 1 && gi_1504) scale_take_profit();
   if (gi_1480 == 2 && gi_1504) scale_take_profit2();
   if (gi_1480 == 3 && gi_1504) {
      scale_take_profit3();
      gi_1480++;
   }
   if (gi_1476 == 1 && gi_1484) {
      scale_stop_loss();
      gi_1476++;
   }
   if (gi_1476 == 2 && gi_1484) {
      scale_stop_loss2();
      gi_1476++;
   }
   if (gi_1476 == 3 && gi_1484) {
      scale_stop_loss3();
      gi_1476++;
   }
   if (use_hidden_stop_loss) hidden_stop_loss();
   if (use_hidden_take_profit) hidden_take_profit();
   if (gs_1872 == gs_1880) gi_1868 = TRUE;
   if (gi_1868) gi_1864 = TRUE;
   if (gi_1868 == FALSE) {
      gi_1864 = FALSE;
      Alert("Wrong password!");
   }
   if (manage_all_trades && gi_900 && gd_1672 >= gd_904) Close_target();
   if (manage_all_trades == FALSE && gi_900 && gd_1672 >= gd_904) mClose_target();
   if (g_count_1728 >= limit_longs) {
      gi_1844 = FALSE;
      gi_1848 = FALSE;
   }
   if (g_count_1732 >= limit_shorts) {
      gi_1844 = FALSE;
      gi_1848 = FALSE;
   }
   if (gi_1320 && li_72 < gi_1324) breakeven = FALSE;
   if (gi_1320 && li_72 > gi_1324) breakeven = TRUE;
   if (gi_1544) Closepending();
   if (breakeven) breakeven();
   if (trail) trail();
   if (gi_1840 == 2) gi_1840 = 0;
   if (gi_1840 == 1) gi_1840 = 0;
   if (ima_136 > ima_144) gi_1840 = 1;
   if (ima_136 < ima_144) gi_1840 = 2;
   if (gi_1336 == FALSE && gi_1340 == FALSE) gi_1840 = 3;
   if (gi_1336 && gi_1840 == 1) {
      gi_788 = TRUE;
      gi_792 = FALSE;
   }
   if (gi_1336 && gi_1840 == 2) {
      gi_788 = FALSE;
      gi_792 = TRUE;
   }
   if (use_tc2_hedge && g_count_1732 > g_count_1728 && isar_176 > iclose_168) gi_1716 = TRUE;
   if (use_tc2_hedge && g_count_1732 < g_count_1728 && isar_176 < iclose_168) gi_1720 = TRUE;
   if (gi_852) {
      use_tc_hedge = FALSE;
      gi_1720 = TRUE;
      gi_1716 = TRUE;
      use_tc2_hedge = FALSE;
      gi_932 = FALSE;
   }
   if (gi_872 && ld_64 < gd_876) {
      gi_1720 = TRUE;
      gi_1716 = TRUE;
      gi_1848 = FALSE;
   }
   if (gi_872 && ld_64 >= gd_884) gi_1848 = TRUE;
   if (gi_864 == FALSE && gi_868 && ld_64 > equity_target) {
      gi_1720 = TRUE;
      gi_1716 = TRUE;
   }
   if (gi_864 && gi_868 && ld_64 > equity_target) {
      gi_1720 = TRUE;
      gi_1716 = TRUE;
      gi_1848 = FALSE;
   }
   if (gi_1724) {
      g_count_1728 = 0;
      g_count_1732 = 0;
   }
   if (manage_all_trades && gi_1724) {
      accorders();
      orders();
   }
   if (manage_all_trades == FALSE && gi_1724) {
      maccorders();
      morders();
   }
   if (gi_1156 && iatr_184 < ld_192) {
      gi_1824 = FALSE;
      gi_1828 = FALSE;
   }
   if (gi_900) profittarget();
   if (gi_1160 && iatr_184 < ld_192) Close_target();
   HideTestIndicators(TRUE);
   int count_1856 = 0;
   int ord_total_1860 = 0;
   if (gi_1804 != Time[0]) {
      gi_1804 = Time[0];
      gi_1808++;
      count_1856 = 0;
      for (ord_total_1860 = OrdersTotal(); ord_total_1860 >= 0; ord_total_1860--) {
         OrderSelect(ord_total_1860, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol()) count_1856++;
      }
      if (count_1856 == 0) gi_unused_1800 = TRUE;
   }
   if (Hour() == CloseHour && Minute() >= CloseMinute && close_all_trades_at_time) Closeppall();
   if (UseHourTrade) {
      if (Hour() < FromHourTrade || Hour() > ToHourTrade) gi_1844 = FALSE;
      gi_1848 = FALSE;
   }
   if (UseHourTrade) {
      if (Hour() >= FromHourTrade && Hour() <= ToHourTrade) gi_1844 = TRUE;
      gi_1848 = TRUE;
   }
   int leverage_1864 = AccountLeverage();
   double ld_unused_1868 = balance;
   double free_magrin_1876 = AccountFreeMargin();
   double ld_1884 = AccountProfit();
   double ld_1892 = AccountEquity();
   int li_unused_1900 = MarketInfo("GBPJPYm", MODE_MARGININIT);
   double swaplong_1904 = MarketInfo("GBPJPYm", MODE_SWAPLONG);
   double swapshort_1912 = MarketInfo("GBPJPYm", MODE_SWAPSHORT);
   int li_unused_1920 = MarketInfo("GBPJPYm", MODE_MAXLOT);
   double minlot_1924 = MarketInfo("GBPJPYm", MODE_MINLOT);
   int li_unused_1932 = MarketInfo("GBPJPYm", MODE_SPREAD);
   double swaplong_1936 = MarketInfo("GBPUSDm", MODE_SWAPLONG);
   double swapshort_1944 = MarketInfo("GBPUSDm", MODE_SWAPSHORT);
   int li_unused_1952 = MarketInfo("GBPUSDm", MODE_MAXLOT);
   double minlot_1956 = MarketInfo("GBPUSDm", MODE_MINLOT);
   int li_unused_1964 = MarketInfo("GBPUSDm", MODE_SPREAD);
   double swaplong_1968 = MarketInfo("EURUSDm", MODE_SWAPLONG);
   double swapshort_1976 = MarketInfo("EURUSDm", MODE_SWAPSHORT);
   int li_unused_1984 = MarketInfo("EURUSDm", MODE_MAXLOT);
   double minlot_1988 = MarketInfo("EURUSDm", MODE_MINLOT);
   int li_unused_1996 = MarketInfo("EURUSDm", MODE_SPREAD);
   double swaplong_2000 = MarketInfo("USDJPYm", MODE_SWAPLONG);
   double swapshort_2008 = MarketInfo("USDJPYm", MODE_SWAPSHORT);
   int li_unused_2016 = MarketInfo("USDJPYm", MODE_MAXLOT);
   double minlot_2020 = MarketInfo("USDJPYm", MODE_MINLOT);
   int li_unused_2028 = MarketInfo("USDJPYm", MODE_SPREAD);
   double swaplong_2032 = MarketInfo("USDCHFm", MODE_SWAPLONG);
   double swapshort_2040 = MarketInfo("USDCHFm", MODE_SWAPSHORT);
   int li_unused_2048 = MarketInfo("USDCHFm", MODE_MAXLOT);
   double minlot_2052 = MarketInfo("USDCHFm", MODE_MINLOT);
   int li_unused_2060 = MarketInfo("USDCHFm", MODE_SPREAD);
   double swaplong_2064 = MarketInfo("EURCHFm", MODE_SWAPLONG);
   double swapshort_2072 = MarketInfo("EURCHFm", MODE_SWAPSHORT);
   int li_unused_2080 = MarketInfo("EURCHFm", MODE_MAXLOT);
   double minlot_2084 = MarketInfo("EURCHFm", MODE_MINLOT);
   int li_unused_2092 = MarketInfo("EURCHFm", MODE_SPREAD);
   double swaplong_2096 = MarketInfo("AUDUSDm", MODE_SWAPLONG);
   double swapshort_2104 = MarketInfo("AUDUSDm", MODE_SWAPSHORT);
   int li_unused_2112 = MarketInfo("AUDUSDm", MODE_MAXLOT);
   int li_unused_2116 = MarketInfo("AUDUSDm", MODE_MINLOT);
   int li_unused_2120 = MarketInfo("AUDUSDm", MODE_SPREAD);
   double swaplong_2124 = MarketInfo("USDCADm", MODE_SWAPLONG);
   double swapshort_2132 = MarketInfo("USDCADm", MODE_SWAPSHORT);
   int li_unused_2140 = MarketInfo("USDCADm", MODE_MAXLOT);
   double minlot_2144 = MarketInfo("USDCADm", MODE_MINLOT);
   int li_unused_2152 = MarketInfo("USDCADm", MODE_SPREAD);
   double swaplong_2156 = MarketInfo("NZDUSDm", MODE_SWAPLONG);
   double swapshort_2164 = MarketInfo("NZDUSDm", MODE_SWAPSHORT);
   int li_unused_2172 = MarketInfo("NZDUSDm", MODE_MAXLOT);
   double minlot_2176 = MarketInfo("NZDUSDm", MODE_MINLOT);
   int li_unused_2184 = MarketInfo("NZDUSDm", MODE_SPREAD);
   double swaplong_2188 = MarketInfo("EURGBPm", MODE_SWAPLONG);
   double swapshort_2196 = MarketInfo("EURGBPm", MODE_SWAPSHORT);
   int li_unused_2204 = MarketInfo("EURGBPm", MODE_MAXLOT);
   double minlot_2208 = MarketInfo("EURGBPm", MODE_MINLOT);
   int li_unused_2216 = MarketInfo("EURGBPm", MODE_SPREAD);
   double swaplong_2220 = MarketInfo("EURJPYm", MODE_SWAPLONG);
   double swapshort_2228 = MarketInfo("EURJPYm", MODE_SWAPSHORT);
   int li_unused_2236 = MarketInfo("EURJPYm", MODE_MAXLOT);
   double minlot_2240 = MarketInfo("EURJPYm", MODE_MINLOT);
   int li_unused_2248 = MarketInfo("EURJPYm", MODE_SPREAD);
   double swaplong_2252 = MarketInfo("CHFJPYm", MODE_SWAPLONG);
   double swapshort_2260 = MarketInfo("CHFJPYm", MODE_SWAPSHORT);
   int li_unused_2268 = MarketInfo("CHFJPYm", MODE_MAXLOT);
   double minlot_2272 = MarketInfo("CHFJPYm", MODE_MINLOT);
   int li_unused_2280 = MarketInfo("CHFJPYm", MODE_SPREAD);
   double swaplong_2284 = MarketInfo("GBPCHFm", MODE_SWAPLONG);
   double swapshort_2292 = MarketInfo("GBPCHFm", MODE_SWAPSHORT);
   int li_unused_2300 = MarketInfo("GBPCHFm", MODE_MAXLOT);
   double minlot_2304 = MarketInfo("GBPCHFm", MODE_MINLOT);
   int li_unused_2312 = MarketInfo("GBPCHFm", MODE_SPREAD);
   double swaplong_2316 = MarketInfo("EURAUDm", MODE_SWAPLONG);
   double swapshort_2324 = MarketInfo("EURAUDm", MODE_SWAPSHORT);
   int li_unused_2332 = MarketInfo("EURAUDm", MODE_MAXLOT);
   double minlot_2336 = MarketInfo("EURAUDm", MODE_MINLOT);
   int li_unused_2344 = MarketInfo("EURAUDm", MODE_SPREAD);
   double swaplong_2348 = MarketInfo("EURCADm", MODE_SWAPLONG);
   double swapshort_2356 = MarketInfo("EURCADm", MODE_SWAPSHORT);
   int li_unused_2364 = MarketInfo("EURCADm", MODE_MAXLOT);
   double minlot_2368 = MarketInfo("EURCADm", MODE_MINLOT);
   int li_unused_2376 = MarketInfo("EURCADm", MODE_SPREAD);
   double swaplong_2380 = MarketInfo("AUDCADm", MODE_SWAPLONG);
   double swapshort_2388 = MarketInfo("AUDCADm", MODE_SWAPSHORT);
   int li_unused_2396 = MarketInfo("AUDCADm", MODE_MAXLOT);
   double minlot_2400 = MarketInfo("AUDCADm", MODE_MINLOT);
   int li_unused_2408 = MarketInfo("AUDCADm", MODE_SPREAD);
   double swaplong_2412 = MarketInfo("AUDJPYm", MODE_SWAPLONG);
   double swapshort_2420 = MarketInfo("AUDJPYm", MODE_SWAPSHORT);
   int li_unused_2428 = MarketInfo("AUDJPYm", MODE_MAXLOT);
   double minlot_2432 = MarketInfo("AUDJPYm", MODE_MINLOT);
   int li_unused_2440 = MarketInfo("AUDJPYm", MODE_SPREAD);
   double swaplong_2444 = MarketInfo("NZDJPYm", MODE_SWAPLONG);
   double swapshort_2452 = MarketInfo("NZDJPYm", MODE_SWAPSHORT);
   int li_unused_2460 = MarketInfo("NZDJPYm", MODE_MAXLOT);
   double minlot_2464 = MarketInfo("NZDJPYm", MODE_MINLOT);
   int li_unused_2472 = MarketInfo("NZDJPYm", MODE_SPREAD);
   double swaplong_2476 = MarketInfo("AUDNZDm", MODE_SWAPLONG);
   double swapshort_2484 = MarketInfo("AUDNZDm", MODE_SWAPSHORT);
   int li_unused_2492 = MarketInfo("AUDNZDm", MODE_MAXLOT);
   double minlot_2496 = MarketInfo("AUDNZDm", MODE_MINLOT);
   int li_unused_2504 = MarketInfo("AUDNZDm", MODE_SPREAD);
   double swaplong_2508 = MarketInfo("GBPJPY", MODE_SWAPLONG);
   double point_2516 = MarketInfo("GBPJPY", MODE_POINT);
   double swapshort_2524 = MarketInfo("GBPJPY", MODE_SWAPSHORT);
   int li_unused_2532 = MarketInfo("GBPJPY", MODE_MAXLOT);
   double minlot_2536 = MarketInfo("GBPJPY", MODE_MINLOT);
   int li_unused_2544 = MarketInfo("GBPJPY", MODE_SPREAD);
   double swaplong_2548 = MarketInfo("GBPUSD", MODE_SWAPLONG);
   double swapshort_2556 = MarketInfo("GBPUSD", MODE_SWAPSHORT);
   int li_unused_2564 = MarketInfo("GBPUSD", MODE_MAXLOT);
   double minlot_2568 = MarketInfo("GBPUSD", MODE_MINLOT);
   int li_unused_2576 = MarketInfo("GBPUSD", MODE_SPREAD);
   double swaplong_2580 = MarketInfo("EURUSD", MODE_SWAPLONG);
   double swapshort_2588 = MarketInfo("EURUSD", MODE_SWAPSHORT);
   int li_unused_2596 = MarketInfo("EURUSD", MODE_MAXLOT);
   double minlot_2600 = MarketInfo("EURUSD", MODE_MINLOT);
   int li_unused_2608 = MarketInfo("EURUSD", MODE_SPREAD);
   double swaplong_2612 = MarketInfo("USDJPY", MODE_SWAPLONG);
   double swapshort_2620 = MarketInfo("USDJPY", MODE_SWAPSHORT);
   int li_unused_2628 = MarketInfo("USDJPY", MODE_MAXLOT);
   double minlot_2632 = MarketInfo("USDJPY", MODE_MINLOT);
   int li_unused_2640 = MarketInfo("USDJPY", MODE_SPREAD);
   double swaplong_2644 = MarketInfo("USDCHF", MODE_SWAPLONG);
   double swapshort_2652 = MarketInfo("USDCHF", MODE_SWAPSHORT);
   int li_unused_2660 = MarketInfo("USDCHF", MODE_MAXLOT);
   double minlot_2664 = MarketInfo("USDCHF", MODE_MINLOT);
   int li_unused_2672 = MarketInfo("USDCHF", MODE_SPREAD);
   double swaplong_2676 = MarketInfo("EURCHF", MODE_SWAPLONG);
   double swapshort_2684 = MarketInfo("EURCHF", MODE_SWAPSHORT);
   int li_unused_2692 = MarketInfo("EURCHF", MODE_MAXLOT);
   double minlot_2696 = MarketInfo("EURCHF", MODE_MINLOT);
   int li_unused_2704 = MarketInfo("EURCHF", MODE_SPREAD);
   double swaplong_2708 = MarketInfo("AUDUSD", MODE_SWAPLONG);
   double swapshort_2716 = MarketInfo("AUDUSD", MODE_SWAPSHORT);
   int li_unused_2724 = MarketInfo("AUDUSD", MODE_MAXLOT);
   double minlot_2728 = MarketInfo("AUDUSD", MODE_MINLOT);
   int li_unused_2736 = MarketInfo("AUDUSD", MODE_SPREAD);
   double swaplong_2740 = MarketInfo("USDCAD", MODE_SWAPLONG);
   double swapshort_2748 = MarketInfo("USDCAD", MODE_SWAPSHORT);
   int li_unused_2756 = MarketInfo("USDCAD", MODE_MAXLOT);
   double minlot_2760 = MarketInfo("USDCAD", MODE_MINLOT);
   int li_unused_2768 = MarketInfo("USDCAD", MODE_SPREAD);
   double swaplong_2772 = MarketInfo("NZDUSD", MODE_SWAPLONG);
   double swapshort_2780 = MarketInfo("NZDUSD", MODE_SWAPSHORT);
   int li_unused_2788 = MarketInfo("NZDUSD", MODE_MAXLOT);
   double minlot_2792 = MarketInfo("NZDUSD", MODE_MINLOT);
   int li_unused_2800 = MarketInfo("NZDUSD", MODE_SPREAD);
   double swaplong_2804 = MarketInfo("EURGBP", MODE_SWAPLONG);
   double swapshort_2812 = MarketInfo("EURGBP", MODE_SWAPSHORT);
   int li_unused_2820 = MarketInfo("EURGBP", MODE_MAXLOT);
   double minlot_2824 = MarketInfo("EURGBP", MODE_MINLOT);
   int li_unused_2832 = MarketInfo("EURGBP", MODE_SPREAD);
   double swaplong_2836 = MarketInfo("EURJPY", MODE_SWAPLONG);
   double swapshort_2844 = MarketInfo("EURJPY", MODE_SWAPSHORT);
   int li_unused_2852 = MarketInfo("EURJPY", MODE_MAXLOT);
   double minlot_2856 = MarketInfo("EURJPY", MODE_MINLOT);
   int li_unused_2864 = MarketInfo("EURJPY", MODE_SPREAD);
   double swaplong_2868 = MarketInfo("CHFJPY", MODE_SWAPLONG);
   double swapshort_2876 = MarketInfo("CHFJPY", MODE_SWAPSHORT);
   int li_unused_2884 = MarketInfo("CHFJPY", MODE_MAXLOT);
   double minlot_2888 = MarketInfo("CHFJPY", MODE_MINLOT);
   int li_unused_2896 = MarketInfo("CHFJPY", MODE_SPREAD);
   double swaplong_2900 = MarketInfo("GBPCHF", MODE_SWAPLONG);
   double swapshort_2908 = MarketInfo("GBPCHF", MODE_SWAPSHORT);
   int li_unused_2916 = MarketInfo("GBPCHF", MODE_MAXLOT);
   double minlot_2920 = MarketInfo("GBPCHF", MODE_MINLOT);
   int li_unused_2928 = MarketInfo("GBPCHF", MODE_SPREAD);
   double swaplong_2932 = MarketInfo("EURAUD", MODE_SWAPLONG);
   double swapshort_2940 = MarketInfo("EURAUD", MODE_SWAPSHORT);
   int li_unused_2948 = MarketInfo("EURAUD", MODE_MAXLOT);
   double minlot_2952 = MarketInfo("EURAUD", MODE_MINLOT);
   int li_unused_2960 = MarketInfo("EURAUD", MODE_SPREAD);
   double swaplong_2964 = MarketInfo("EURCAD", MODE_SWAPLONG);
   double swapshort_2972 = MarketInfo("EURCAD", MODE_SWAPSHORT);
   int li_unused_2980 = MarketInfo("EURCAD", MODE_MAXLOT);
   double minlot_2984 = MarketInfo("EURCAD", MODE_MINLOT);
   int li_unused_2992 = MarketInfo("EURCAD", MODE_SPREAD);
   double swaplong_2996 = MarketInfo("AUDCAD", MODE_SWAPLONG);
   double swapshort_3004 = MarketInfo("AUDCAD", MODE_SWAPSHORT);
   int li_unused_3012 = MarketInfo("AUDCAD", MODE_MAXLOT);
   double minlot_3016 = MarketInfo("AUDCAD", MODE_MINLOT);
   int li_unused_3024 = MarketInfo("AUDCAD", MODE_SPREAD);
   double swaplong_3028 = MarketInfo("AUDJPY", MODE_SWAPLONG);
   double swapshort_3036 = MarketInfo("AUDJPY", MODE_SWAPSHORT);
   int li_unused_3044 = MarketInfo("AUDJPY", MODE_MAXLOT);
   double minlot_3048 = MarketInfo("AUDJPY", MODE_MINLOT);
   int li_unused_3056 = MarketInfo("AUDJPY", MODE_SPREAD);
   double swaplong_3060 = MarketInfo("NZDJPY", MODE_SWAPLONG);
   double swapshort_3068 = MarketInfo("NZDJPY", MODE_SWAPSHORT);
   int li_unused_3076 = MarketInfo("NZDJPY", MODE_MAXLOT);
   double minlot_3080 = MarketInfo("NZDJPY", MODE_MINLOT);
   int li_unused_3088 = MarketInfo("NZDJPY", MODE_SPREAD);
   double swaplong_3092 = MarketInfo("AUDNZD", MODE_SWAPLONG);
   double swapshort_3100 = MarketInfo("AUDNZD", MODE_SWAPSHORT);
   int li_unused_3108 = MarketInfo("AUDNZD", MODE_MAXLOT);
   double minlot_3112 = MarketInfo("AUDNZD", MODE_MINLOT);
   int li_unused_3120 = MarketInfo("AUDNZD", MODE_SPREAD);
   int li_3124 = g_count_1744 + g_count_1740;
   double ld_3128 = 100.0 * (gd_1672 / balance);
   if (comments) {
      ld_12 = 100.0 * (gd_2008 / balance);
      ld_20 = 100.0 * (gd_2016 / balance);
      ld_28 = 100.0 * ((AccountFreeMargin() - AccountMargin()) / AccountEquity());
      Comment("\n", " --VvvvvV-- D R A C U L A   F O R E X  EA --VvvvvV-- Period ", Period(), "", 
         "\n", "     FreeMargin  = ", DoubleToStr(ld_28, 2), 
         "\n", 
         "\n", "                 profit  =   ", DoubleToStr(ld_3128, 2), "   shorts  = ", DoubleToStr(ld_12, 2), "   longs  = ", DoubleToStr(ld_20, 2), 
         "\n", "               Target  =     ", DoubleToStr(profit_target_percent, 2), 
         "\n", "     loss protection  =   ", DoubleToStr(emergency_loss_protection, 2), 
         "\n", 
         "\n", 
         "\n", "   buy lots   = ", DoubleToStr(gd_808, 2), 
         "\n", "   sell lots    = ", DoubleToStr(gd_800, 2), 
         "\n", 
         "\n", 
         "\n", "     Total Orders= ", DoubleToStr(li_72, 0), "     Longs  = ", DoubleToStr(g_count_1728, 0), "     Shorts  = ", DoubleToStr(g_count_1732, 0), 
         "\n", 
         "\n", "     Psar = ", DoubleToStr(psar, 4), "     Time Frame= ", DoubleToStr(time_frame_for_signal, 0), 
         "\n", 
         "\n", 
         "\n", "     Psar2= ", DoubleToStr(psar2, 4), "     Time Frame= ", DoubleToStr(time_frame_for_signal2, 0), 
         "\n", 
      "\n", "     trend  = ", gs_none_1948);
   }
   if (manage_all_trades && gi_2028 && ld_3128 > profit_target_percent) Close_target();
   if (manage_all_trades == FALSE && gi_2028 && ld_3128 > profit_target_percent) mClose_target();
   if (gi_1796) {
      gi_unused_1028 = FALSE;
      gi_unused_1032 = FALSE;
      gi_unused_1036 = FALSE;
      gi_unused_1040 = FALSE;
      gi_unused_1044 = FALSE;
      gi_unused_1048 = FALSE;
      gi_unused_1052 = FALSE;
      gi_unused_1056 = FALSE;
      gi_unused_1060 = FALSE;
      gi_unused_1064 = FALSE;
      hi_lo_filter = FALSE;
      gi_824 = FALSE;
      gi_756 = TRUE;
      gi_760 = TRUE;
      ld_3128 = 0;
      gd_1672 = 0;
      gd_808 = 0;
      gd_800 = 0;
      li_3124 = 0;
      g_count_1744 = 0;
      g_count_1740 = 0;
      gd_unused_2068 = Lots;
      g_lots_2076 = Lots;
   }
   if (auto_pivot && li_72 > orders) {
      h1_tf = 60;
      h1 = 50;
      h4_tf = 240;
      h4 = 50;
      d1_tf = 1440;
      d1 = 50;
      w1_tf = 10800;
      w1 = 50;
      mn_tf = 43200;
      mn = 50;
      h1_tfs = 60;
      h1s = 50;
      h4_tfs = 240;
      h4s = 50;
      d1_tfs = 1440;
      d1s = 50;
      w1_tfs = 10800;
      w1s = 50;
      mn_tfs = 43200;
      mns = 50;
   }
   if (auto_pivot && li_72 < orders) {
      h1_tf = 60;
      h1 = 50;
      h4_tf = 60;
      h4 = 50;
      d1_tf = 60;
      d1 = 50;
      w1_tf = 60;
      w1 = 50;
      mn_tf = 60;
      mn = 50;
      h1_tfs = 60;
      h1s = 50;
      h4_tfs = 60;
      h4s = 50;
      d1_tfs = 60;
      d1s = 50;
      w1_tfs = 60;
      w1s = 50;
      mn_tfs = 60;
      mns = 50;
   }
   if (gi_764 && ld_3128 > -2.0) {
      hi_lo_filter = FALSE;
      gi_824 = FALSE;
      use_martingale = FALSE;
      open_with_tc2 = TRUE;
   }
   if (gi_764 && ld_3128 < -2.0) {
      hi_lo_filter = TRUE;
      gi_824 = FALSE;
      use_martingale = FALSE;
      open_with_tc2 = FALSE;
      piv_period = 240;
   }
   if (gi_764 && ld_3128 < -3.0) {
      hi_lo_filter = TRUE;
      gi_824 = FALSE;
      use_martingale = FALSE;
      open_with_tc2 = FALSE;
      piv_period = 43200;
   }
   if (gi_764 && ld_3128 < -5.0) {
      hi_lo_filter = TRUE;
      gi_824 = FALSE;
      use_martingale = FALSE;
      piv_period = 10080;
   }
   if (gi_764 && ld_3128 < -7.0) {
      hi_lo_filter = TRUE;
      gi_824 = FALSE;
      use_martingale = FALSE;
      open_with_tc2 = FALSE;
      piv_period = 1440;
   }
   if (gi_764 && ld_3128 < -10.0) {
      hi_lo_filter = TRUE;
      gi_824 = FALSE;
      use_martingale = FALSE;
      open_with_tc2 = FALSE;
      piv_period = 240;
   }
   if (gi_764 && ld_3128 < -20.0) {
      hi_lo_filter = FALSE;
      gi_824 = FALSE;
      use_martingale = FALSE;
      open_with_tc2 = FALSE;
   }
   if (gi_2108 && ld_3128 > -1.0) time_frame_for_signal2 = 5;
   if (gi_2108 && ld_3128 < -1.0 && ld_3128 > -3.0) time_frame_for_signal2 = 30;
   if (gi_2108 && ld_3128 < -3.0) time_frame_for_signal2 = 240;
   if (gi_2064 && ld_28 < gd_916) use_martingale = TRUE;
   if (gi_2064 && ld_28 > gd_916) use_martingale = FALSE;
   if (gi_912 && ld_28 < gd_916) trade_at_the_cross_only = TRUE;
   if (gi_912 && OrdersTotal() == 0) trade_at_the_cross_only = FALSE;
   if (gi_1188 && ld_28 > gd_1192) gi_1340 = FALSE;
   if (gi_1188 && ld_28 < gd_1192) {
      gi_1340 = TRUE;
      use_tc_hedge = FALSE;
   }
   if (gi_1228 && ld_28 < gd_1232) {
      Closelongsinprofit();
      Closeshortsinprofit();
   }
   if (gi_1712 && ld_28 < 20.0 && ld_64 > -5.0) Closeppall();
   if (gi_1300 && ld_28 < gd_1304) Closeppall();
   if (gi_1256 && ld_28 > gd_1260) trail = FALSE;
   if (gi_1256 && ld_28 < gd_1260) trail = TRUE;
   if (gi_1208 && ld_28 < gd_1212) {
      gi_1844 = FALSE;
      gi_1848 = FALSE;
   }
   if (gi_1208 && ld_28 > gd_1212) gi_1844 = TRUE;
   int li_3136 = 0;
   if (gi_116 && Bars != g_bars_2112) gi_2120 = FALSE;
   int ord_total_3140 = OrdersTotal();
   li_3136 = 0;
   double iatr_3144 = iATR(NULL, g_timeframe_1776, g_period_1764, 0);
   double ld_3152 = gd_1768;
   double iforce_3160 = iForce(NULL, 0, 13, MODE_SMA, PRICE_CLOSE, 0);
   double ld_unused_3168 = 8;
   double ld_unused_3176 = -8;
   double iclose_3184 = iClose(NULL, 0, gi_2116 + 0);
   double ienvelopes_3192 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_buy, buy, MODE_LOWER, gi_2116 + 0);
   double iclose_3200 = iClose(NULL, 0, gi_2116 + 1);
   double ienvelopes_3208 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_buy, buy, MODE_LOWER, gi_2116 + 1);
   double iclose_3216 = iClose(NULL, 0, gi_2116 + 2);
   double ienvelopes_3224 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_buy, buy, MODE_LOWER, gi_2116 + 2);
   double iclose_3232 = iClose(NULL, 0, gi_2116 + 0);
   double ienvelopes_3240 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_buy, buy, MODE_UPPER, gi_2116 + 0);
   double iclose_3248 = iClose(NULL, 0, gi_2116 + 1);
   double ienvelopes_3256 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_buy, buy, MODE_UPPER, gi_2116 + 1);
   double iclose_3264 = iClose(NULL, 0, gi_2116 + 2);
   double ienvelopes_3272 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_buy, buy, MODE_UPPER, gi_2116 + 2);
   double isar_3280 = iSAR(NULL, time_frame_for_signal, psar, max, gi_2116 + 0);
   double iclose_3288 = iClose(NULL, 0, gi_2116 + 0);
   double isar_3296 = iSAR(NULL, time_frame_for_signal, psar, max, gi_2116 + 1);
   double iclose_3304 = iClose(NULL, 0, gi_2116 + 1);
   double isar_3312 = iSAR(NULL, time_frame_for_signal, psar, max, gi_2116 + 2);
   double iclose_3320 = iClose(NULL, 0, gi_2116 + 2);
   double isar_3328 = iSAR(NULL, time_frame_for_signal2, psar2, max2, gi_2116 + 0);
   double iclose_3336 = iClose(NULL, 0, gi_2116 + 0);
   double isar_3344 = iSAR(NULL, time_frame_for_signal2, psar2, max2, gi_2116 + 1);
   double iclose_3352 = iClose(NULL, 0, gi_2116 + 1);
   double isar_3360 = iSAR(NULL, time_frame_for_signal2, psar2, max2, gi_2116 + 2);
   double iclose_3368 = iClose(NULL, 0, gi_2116 + 2);
   double iclose_3376 = iClose(NULL, 0, gi_2116 + 0);
   double ima_3384 = iMA(NULL, time_frame_for_signal, ima_200, 0, MODE_SMMA, PRICE_OPEN, gi_2116 + 0);
   double iclose_3392 = iClose(NULL, 0, gi_2116 + 1);
   double ima_3400 = iMA(NULL, time_frame_for_signal, ima_200, 0, MODE_SMMA, PRICE_OPEN, gi_2116 + 1);
   double iclose_3408 = iClose(NULL, 0, gi_2116 + 2);
   double ima_3416 = iMA(NULL, time_frame_for_signal, ima_200, 0, MODE_SMMA, PRICE_OPEN, gi_2116 + 2);
   double isar_3424 = iSAR(NULL, time_frame_for_signal, psar, max, gi_2116 + 0);
   double iclose_3432 = iClose(NULL, 0, gi_2116 + 0);
   double isar_3440 = iSAR(NULL, time_frame_for_signal, psar, max, gi_2116 + 1);
   double iclose_3448 = iClose(NULL, 0, gi_2116 + 1);
   double isar_3456 = iSAR(NULL, time_frame_for_signal, psar, max, gi_2116 + 2);
   double iclose_3464 = iClose(NULL, 0, gi_2116 + 2);
   double isar_3472 = iSAR(NULL, time_frame_for_signal2, psar2, max2, gi_2116 + 0);
   double iclose_3480 = iClose(NULL, 0, gi_2116 + 0);
   double isar_3488 = iSAR(NULL, time_frame_for_signal2, psar2, max2, gi_2116 + 1);
   double iclose_3496 = iClose(NULL, 0, gi_2116 + 1);
   double isar_3504 = iSAR(NULL, time_frame_for_signal2, psar2, max2, gi_2116 + 2);
   double iclose_3512 = iClose(NULL, 0, gi_2116 + 2);
   double iclose_3520 = iClose(NULL, 0, gi_2116 + 0);
   double ienvelopes_3528 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_sell, buy, MODE_UPPER, gi_2116 + 0);
   double iclose_3536 = iClose(NULL, 0, gi_2116 + 1);
   double ienvelopes_3544 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_sell, buy, MODE_UPPER, gi_2116 + 1);
   double iclose_3552 = iClose(NULL, 0, gi_2116 + 2);
   double ienvelopes_3560 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_sell, buy, MODE_UPPER, gi_2116 + 2);
   double iclose_3568 = iClose(NULL, 0, gi_2116 + 0);
   double ienvelopes_3576 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_sell, buy, MODE_LOWER, gi_2116 + 0);
   double iclose_3584 = iClose(NULL, 0, gi_2116 + 1);
   double ienvelopes_3592 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_sell, buy, MODE_LOWER, gi_2116 + 1);
   double iclose_3600 = iClose(NULL, 0, gi_2116 + 2);
   double ienvelopes_3608 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_sell, buy, MODE_LOWER, gi_2116 + 2);
   double iclose_3616 = iClose(NULL, 0, gi_2116 + 0);
   double ima_3624 = iMA(NULL, time_frame_for_signal, ima_200, 0, MODE_SMMA, PRICE_OPEN, gi_2116 + 0);
   double iclose_3632 = iClose(NULL, 0, gi_2116 + 1);
   double ima_3640 = iMA(NULL, time_frame_for_signal, ima_200, 0, MODE_SMMA, PRICE_OPEN, gi_2116 + 1);
   double iclose_3648 = iClose(NULL, 0, gi_2116 + 2);
   double ima_3656 = iMA(NULL, time_frame_for_signal, ima_200, 0, MODE_SMMA, PRICE_OPEN, gi_2116 + 2);
   double iclose_3664 = iClose(NULL, 0, gi_2116 + 0);
   double ienvelopes_3672 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_close_buy, close_buy, MODE_UPPER, gi_2116 + 0);
   double iclose_3680 = iClose(NULL, 0, gi_2116 + 0);
   double ienvelopes_3688 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_close_buy, close_buy, MODE_LOWER, gi_2116 + 0);
   double isar_3696 = iSAR(NULL, time_frame_for_signal, psar, max, gi_2116 + 0);
   double iclose_3704 = iClose(NULL, 0, gi_2116 + 0);
   double isar_3712 = iSAR(NULL, time_frame_for_signal2, psar2, max2, gi_2116 + 0);
   double iclose_3720 = iClose(NULL, 0, gi_2116 + 0);
   double iclose_3728 = iClose(NULL, 0, gi_2116 + 0);
   double ienvelopes_3736 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_close_sell, close_sell, MODE_LOWER, gi_2116 + 0);
   double iclose_3744 = iClose(NULL, 0, gi_2116 + 0);
   double ienvelopes_3752 = iEnvelopes(NULL, time_frame_for_env, envelopes_period_buy, MODE_SMMA, 1, apply_to_close_sell, close_sell, MODE_UPPER, gi_2116 + 0);
   double isar_3760 = iSAR(NULL, time_frame_for_signal, psar, max, gi_2116 + 0);
   double iclose_3768 = iClose(NULL, 0, gi_2116 + 0);
   double isar_3776 = iSAR(NULL, time_frame_for_signal2, psar2, max2, gi_2116 + 0);
   double iclose_3784 = iClose(NULL, 0, gi_2116 + 0);
   bool li_3792 = FALSE;
   for (int pos_3796 = max_trades; pos_3796 < ord_total_3140; pos_3796++) {
      OrderSelect(pos_3796, SELECT_BY_POS, MODE_TRADES);
      if (g_bars_2124 != Bars && OrderType() <= OP_SELL && OrderSymbol() == Symbol()) {
         li_3792 = TRUE;
         if (g_bars_2124 != Bars && OrderType() == OP_BUY) {
            if (exit_buy_upper_line && reverse_second_tc_exits == FALSE && close_with_tc2 == FALSE && close_with_envelopes && close_with_tc)
               if (iclose_3664 > ienvelopes_3672 || iclose_3704 < isar_3696) li_3136 = 3;
            if (exit_buy_upper_line && reverse_second_tc_exits == FALSE && close_with_tc2 && close_with_envelopes && close_with_tc)
               if (iclose_3664 > ienvelopes_3672 || iclose_3704 < isar_3696 || iclose_3720 < isar_3712) li_3136 = 3;
            if (reverse_second_tc_exits == FALSE && close_with_tc2 == FALSE && close_with_envelopes == FALSE && close_with_tc)
               if (iclose_3704 < isar_3696) li_3136 = 3;
            if (exit_buy_upper_line && reverse_second_tc_exits == FALSE && close_with_tc2 == FALSE && close_with_envelopes && close_with_tc == FALSE)
               if (iclose_3664 > ienvelopes_3672) li_3136 = 3;
            if (close_with_envelopes == FALSE && reverse_second_tc_exits == FALSE && close_with_tc2 && close_with_tc)
               if (iclose_3720 < isar_3712 || iclose_3704 < isar_3696) li_3136 = 3;
            if (close_with_tc == FALSE && exit_buy_upper_line && reverse_second_tc_exits == FALSE && close_with_tc2 && close_with_envelopes)
               if (iclose_3720 < isar_3712 || iclose_3664 > ienvelopes_3672) li_3136 = 3;
            if (close_with_tc == FALSE && close_with_envelopes == FALSE && reverse_second_tc_exits == FALSE && close_with_tc2)
               if (iclose_3720 < isar_3712) li_3136 = 3;
            if (exit_buy_upper_line && reverse_second_tc_exits && close_with_tc2 == FALSE && close_with_envelopes && close_with_tc)
               if (iclose_3664 > ienvelopes_3672 || iclose_3704 < isar_3696) li_3136 = 3;
            if (exit_buy_upper_line && reverse_second_tc_exits && close_with_tc2 && close_with_envelopes && close_with_tc)
               if (iclose_3664 > ienvelopes_3672 || iclose_3704 < isar_3696 || iclose_3720 > isar_3712) li_3136 = 3;
            if (reverse_second_tc_exits && close_with_tc2 == FALSE && close_with_envelopes == FALSE && close_with_tc)
               if (iclose_3704 < isar_3696) li_3136 = 3;
            if (exit_buy_upper_line && reverse_second_tc_exits && close_with_tc2 == FALSE && close_with_envelopes && close_with_tc == FALSE)
               if (iclose_3664 > ienvelopes_3672) li_3136 = 3;
            if (close_with_envelopes == FALSE && reverse_second_tc_exits && close_with_tc2 && close_with_tc)
               if (iclose_3720 > isar_3712 || iclose_3704 < isar_3696) li_3136 = 3;
            if (exit_buy_upper_line && close_with_tc == FALSE && reverse_second_tc_exits && close_with_tc2 && close_with_envelopes)
               if (iclose_3720 > isar_3712 || iclose_3664 > ienvelopes_3672) li_3136 = 3;
            if (close_with_envelopes == FALSE && close_with_tc == FALSE && reverse_second_tc_exits && close_with_tc2)
               if (iclose_3720 > isar_3712) li_3136 = 3;
            if (exit_buy_upper_line && reverse_second_tc_exits == FALSE && close_with_tc2 == FALSE && close_with_envelopes && close_with_tc)
               if (iclose_3664 > ienvelopes_3672 || iclose_3704 < isar_3696) li_3136 = 3;
            if (exit_buy_upper_line && reverse_second_tc_exits == FALSE && close_with_tc2 && close_with_envelopes && close_with_tc)
               if (iclose_3664 > ienvelopes_3672 || iclose_3704 < isar_3696 || iclose_3720 < isar_3712) li_3136 = 3;
            if (reverse_second_tc_exits == FALSE && close_with_tc2 == FALSE && close_with_envelopes == FALSE && close_with_tc)
               if (iclose_3704 < isar_3696) li_3136 = 3;
            if (exit_buy_upper_line && reverse_second_tc_exits == FALSE && close_with_tc2 == FALSE && close_with_envelopes && close_with_tc == FALSE)
               if (iclose_3664 > ienvelopes_3672) li_3136 = 3;
            if (close_with_envelopes == FALSE && reverse_second_tc_exits == FALSE && close_with_tc2 && close_with_tc)
               if (iclose_3720 < isar_3712 || iclose_3704 < isar_3696) li_3136 = 3;
            if (close_with_tc == FALSE && exit_buy_lower_line && reverse_second_tc_exits == FALSE && close_with_tc2 && close_with_envelopes)
               if (iclose_3720 < isar_3712 || iclose_3680 < ienvelopes_3688) li_3136 = 3;
            if (close_with_tc == FALSE && close_with_envelopes == FALSE && reverse_second_tc_exits == FALSE && close_with_tc2)
               if (iclose_3720 < isar_3712) li_3136 = 3;
            if (exit_buy_lower_line && reverse_second_tc_exits && close_with_tc2 == FALSE && close_with_envelopes && close_with_tc)
               if (iclose_3680 < ienvelopes_3688 || iclose_3704 < isar_3696) li_3136 = 3;
            if (exit_buy_lower_line && reverse_second_tc_exits && close_with_tc2 && close_with_envelopes && close_with_tc)
               if (iclose_3680 < ienvelopes_3688 || iclose_3704 < isar_3696 || iclose_3720 > isar_3712) li_3136 = 3;
            if (reverse_second_tc_exits && close_with_tc2 == FALSE && close_with_envelopes == FALSE && close_with_tc)
               if (iclose_3704 < isar_3696) li_3136 = 3;
            if (exit_buy_lower_line && reverse_second_tc_exits && close_with_tc2 == FALSE && close_with_envelopes && close_with_tc == FALSE)
               if (iclose_3680 < ienvelopes_3688) li_3136 = 3;
            if (close_with_envelopes == FALSE && reverse_second_tc_exits && close_with_tc2 && close_with_tc)
               if (iclose_3720 > isar_3712 || iclose_3704 < isar_3696) li_3136 = 3;
            if (exit_buy_lower_line && close_with_tc == FALSE && reverse_second_tc_exits && close_with_tc2 && close_with_envelopes)
               if (iclose_3720 > isar_3712 || iclose_3680 < ienvelopes_3688) li_3136 = 3;
            if (close_with_envelopes == FALSE && close_with_tc == FALSE && reverse_second_tc_exits && close_with_tc2)
               if (iclose_3720 > isar_3712) li_3136 = 3;
            if (li_3136 == 3) Closelongs();
            if (li_3136 == 3) {
               OrderClose(OrderTicket(), OrderLots(), Bid, 200, MediumSeaGreen);
               if (email_notification) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + " Close Buy");
               if (Use_Sound_only) PlaySound(gs_1788);
               if (!(Use_popup_and_sound_alert)) continue;
               Alert(gs_1780);
               continue;
            }
            if (exit_sell_lower_line && reverse_second_tc_exits == FALSE && close_with_tc2 == FALSE && close_with_envelopes && close_with_tc)
               if (iclose_3728 < ienvelopes_3736 || iclose_3768 > isar_3760) li_3136 = 4;
            if (exit_sell_lower_line && reverse_second_tc_exits == FALSE && close_with_tc2 && close_with_envelopes && close_with_tc)
               if (iclose_3728 < ienvelopes_3736 || iclose_3768 > isar_3760 || iclose_3784 > isar_3776) li_3136 = 4;
            if (reverse_second_tc_exits == FALSE && close_with_tc2 == FALSE && close_with_envelopes == FALSE && close_with_tc)
               if (iclose_3768 > isar_3760) li_3136 = 4;
            if (reverse_second_tc_exits == FALSE && close_with_tc2 && close_with_envelopes == FALSE && close_with_tc)
               if (iclose_3784 > isar_3776 || iclose_3768 > isar_3760) li_3136 = 4;
            if (exit_sell_lower_line && reverse_second_tc_exits == FALSE && close_with_tc2 == FALSE && close_with_envelopes && close_with_tc == FALSE)
               if (iclose_3728 < ienvelopes_3736) li_3136 = 4;
            if (exit_sell_lower_line && reverse_second_tc_exits == FALSE && close_with_envelopes && close_with_tc2 && close_with_tc == FALSE)
               if (iclose_3728 < ienvelopes_3736 || iclose_3784 > isar_3776) li_3136 = 4;
            if (reverse_second_tc_exits == FALSE && close_with_envelopes == FALSE && close_with_tc2 && close_with_tc == FALSE)
               if (iclose_3784 > isar_3776) li_3136 = 4;
            if (exit_sell_lower_line && reverse_second_tc_exits && close_with_tc2 == FALSE && close_with_envelopes && close_with_tc)
               if (iclose_3728 < ienvelopes_3736 || iclose_3768 > isar_3760) li_3136 = 4;
            if (exit_sell_lower_line && reverse_second_tc_exits && close_with_tc2 && close_with_envelopes && close_with_tc)
               if (iclose_3728 < ienvelopes_3736 || iclose_3768 > isar_3760 || iclose_3784 < isar_3776) li_3136 = 4;
            if (reverse_second_tc_exits && close_with_tc2 == FALSE && close_with_envelopes == FALSE && close_with_tc)
               if (iclose_3768 > isar_3760) li_3136 = 4;
            if (reverse_second_tc_exits && close_with_tc2 && close_with_envelopes == FALSE && close_with_tc)
               if (iclose_3784 < isar_3776 || iclose_3768 > isar_3760) li_3136 = 4;
            if (exit_sell_lower_line && reverse_second_tc_exits && close_with_tc2 == FALSE && close_with_envelopes && close_with_tc == FALSE)
               if (iclose_3728 < ienvelopes_3736) li_3136 = 4;
            if (exit_sell_lower_line && reverse_second_tc_exits && close_with_envelopes && close_with_tc2 && close_with_tc == FALSE)
               if (iclose_3728 < ienvelopes_3736 || iclose_3784 < isar_3776) li_3136 = 4;
            if (reverse_second_tc_exits && close_with_envelopes == FALSE && close_with_tc2 && close_with_tc == FALSE)
               if (iclose_3784 < isar_3776) li_3136 = 4;
            if (exit_sell_upper_line && reverse_second_tc_exits == FALSE && close_with_tc2 == FALSE && close_with_envelopes && close_with_tc)
               if (iclose_3744 > ienvelopes_3752 || iclose_3768 > isar_3760) li_3136 = 4;
            if (exit_sell_upper_line && reverse_second_tc_exits == FALSE && close_with_tc2 && close_with_envelopes && close_with_tc)
               if (iclose_3744 > ienvelopes_3752 || iclose_3768 > isar_3760 || iclose_3784 > isar_3776) li_3136 = 4;
            if (reverse_second_tc_exits == FALSE && close_with_tc2 == FALSE && close_with_envelopes == FALSE && close_with_tc)
               if (iclose_3768 > isar_3760) li_3136 = 4;
            if (reverse_second_tc_exits == FALSE && close_with_tc2 && close_with_envelopes == FALSE && close_with_tc)
               if (iclose_3784 > isar_3776 || iclose_3768 > isar_3760) li_3136 = 4;
            if (exit_sell_upper_line && reverse_second_tc_exits == FALSE && close_with_tc2 == FALSE && close_with_envelopes && close_with_tc == FALSE)
               if (iclose_3744 > ienvelopes_3752) li_3136 = 4;
            if (exit_sell_upper_line && reverse_second_tc_exits == FALSE && close_with_envelopes && close_with_tc2 && close_with_tc == FALSE)
               if (iclose_3744 > ienvelopes_3752 || iclose_3784 > isar_3776) li_3136 = 4;
            if (reverse_second_tc_exits == FALSE && close_with_envelopes == FALSE && close_with_tc2 && close_with_tc == FALSE)
               if (iclose_3784 > isar_3776) li_3136 = 4;
            if (exit_sell_upper_line && reverse_second_tc_exits && close_with_tc2 == FALSE && close_with_envelopes && close_with_tc)
               if (iclose_3744 > ienvelopes_3752 || iclose_3768 > isar_3760) li_3136 = 4;
            if (exit_sell_upper_line && reverse_second_tc_exits && close_with_tc2 && close_with_envelopes && close_with_tc)
               if (iclose_3744 > ienvelopes_3752 || iclose_3768 > isar_3760 || iclose_3784 < isar_3776) li_3136 = 4;
            if (reverse_second_tc_exits && close_with_tc2 == FALSE && close_with_envelopes == FALSE && close_with_tc)
               if (iclose_3768 > isar_3760) li_3136 = 4;
            if (reverse_second_tc_exits && close_with_tc2 && close_with_envelopes == FALSE && close_with_tc)
               if (iclose_3784 < isar_3776 || iclose_3768 > isar_3760) li_3136 = 4;
            if (exit_sell_upper_line && reverse_second_tc_exits && close_with_tc2 == FALSE && close_with_envelopes && close_with_tc == FALSE)
               if (iclose_3744 > ienvelopes_3752) li_3136 = 4;
            if (exit_sell_upper_line && reverse_second_tc_exits && close_with_envelopes && close_with_tc2 && close_with_tc == FALSE)
               if (iclose_3744 > ienvelopes_3752 || iclose_3784 < isar_3776) li_3136 = 4;
            if (reverse_second_tc_exits && close_with_envelopes == FALSE && close_with_tc2 && close_with_tc == FALSE)
               if (iclose_3784 < isar_3776) li_3136 = 4;
            if (li_3136 == 4) Closeshorts();
            if (li_3136 == 4) {
               OrderClose(OrderTicket(), OrderLots(), Ask, 200, DarkOrange);
               if (email_notification) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + " Close Sell");
               if (Use_Sound_only) PlaySound(gs_1788);
               if (Use_popup_and_sound_alert) Alert(gs_1780);
            }
         }
      }
   }
   int li_3800 = Time[1];
   int li_3804 = Time[1];
   if (open_sell_upper_line && open_buy_lower_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192 && iclose_3200 < ienvelopes_3208 && iclose_3216 >= ienvelopes_3224 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3520 > ienvelopes_3528 && iclose_3536 > ienvelopes_3544 && iclose_3552 <= ienvelopes_3560 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_sell_lower_line && open_buy_lower_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192 && iclose_3200 < ienvelopes_3208 && iclose_3216 >= ienvelopes_3224 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3568 < ienvelopes_3576 && iclose_3584 < ienvelopes_3592 && iclose_3600 >= ienvelopes_3608 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_sell_upper_line && open_buy_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3232 > ienvelopes_3240 && iclose_3248 > ienvelopes_3256 && iclose_3264 <= ienvelopes_3272 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3520 > ienvelopes_3528 && iclose_3536 > ienvelopes_3544 && iclose_3552 <= ienvelopes_3560 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_sell_lower_line && open_buy_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3232 > ienvelopes_3240 && iclose_3248 > ienvelopes_3256 && iclose_3264 <= ienvelopes_3272 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3568 < ienvelopes_3576 && iclose_3584 < ienvelopes_3592 && iclose_3600 >= ienvelopes_3608 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && gi_1816 &&
      trade_at_the_cross_only == FALSE && gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3520 > ienvelopes_3528 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_lower_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && gi_1816 &&
      trade_at_the_cross_only == FALSE && gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3568 < ienvelopes_3576 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && gi_1816 &&
      trade_at_the_cross_only == FALSE && gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3232 > ienvelopes_3240 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3520 > ienvelopes_3528 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_lower_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && gi_1816 &&
      trade_at_the_cross_only == FALSE && gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3232 > ienvelopes_3240 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3568 < ienvelopes_3576 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3520 > ienvelopes_3528) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_lower_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3568 < ienvelopes_3576) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3232 > ienvelopes_3240) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3520 > ienvelopes_3528) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_lower_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3232 > ienvelopes_3240) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3568 < ienvelopes_3576) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280 && iclose_3200 < ienvelopes_3208 && iclose_3216 >= ienvelopes_3224 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3432 < isar_3424 && iclose_3520 > ienvelopes_3528 && iclose_3536 > ienvelopes_3544 && iclose_3552 <= ienvelopes_3560 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_lower_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280 && iclose_3200 < ienvelopes_3208 && iclose_3216 >= ienvelopes_3224 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3432 < isar_3424 && iclose_3568 < ienvelopes_3576 && iclose_3584 < ienvelopes_3592 && iclose_3600 >= ienvelopes_3608 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3288 > isar_3280 && iclose_3232 > ienvelopes_3240 && iclose_3248 > ienvelopes_3256 && iclose_3264 <= ienvelopes_3272 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3432 < isar_3424 && iclose_3520 > ienvelopes_3528 && iclose_3536 > ienvelopes_3544 && iclose_3552 <= ienvelopes_3560 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_lower_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3288 > isar_3280 && iclose_3232 > ienvelopes_3240 && iclose_3248 > ienvelopes_3256 && iclose_3264 <= ienvelopes_3272 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3432 < isar_3424 && iclose_3568 < ienvelopes_3576 && iclose_3584 < ienvelopes_3592 && iclose_3600 >= ienvelopes_3608 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3520 > ienvelopes_3528 && iclose_3432 < isar_3424 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_lower_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3568 < ienvelopes_3576 && iclose_3432 < isar_3424 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3232 > ienvelopes_3240 && iclose_3288 > isar_3280 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3520 > ienvelopes_3528 && iclose_3432 < isar_3424 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_lower_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3232 > ienvelopes_3240 && iclose_3288 > isar_3280 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3568 < ienvelopes_3576 && iclose_3432 < isar_3424 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes == FALSE && trade_at_the_cross_only && gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3288 > isar_3280 && iclose_3304 <= isar_3296 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3432 < isar_3424 && iclose_3448 >= isar_3440 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes == FALSE && gi_1816 && trade_at_the_cross_only == FALSE && gi_1812 == FALSE &&
      g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3288 > isar_3280 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3432 < isar_3424 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes == FALSE && trade_at_the_cross_only == FALSE && gi_1816 == FALSE &&
      g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3288 > isar_3280) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3432 < isar_3424) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3520 > ienvelopes_3528 && iclose_3432 < isar_3424) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_lower_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3568 < ienvelopes_3576 && iclose_3432 < isar_3424) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3232 > ienvelopes_3240 && iclose_3288 > isar_3280) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3568 < ienvelopes_3576 && iclose_3432 < isar_3424) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_lower_line && reverse_second_tc_entry == FALSE && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3232 > ienvelopes_3240 && iclose_3288 > isar_3280) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3568 < ienvelopes_3576 && iclose_3432 < isar_3424) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3184 < ienvelopes_3192 && iclose_3336 <= isar_3328 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3520 > ienvelopes_3528 && isar_3472 >= isar_3472 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_lower_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only && gi_1816 == FALSE &&
      g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3184 < ienvelopes_3192 && iclose_3336 <= isar_3328 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3568 < ienvelopes_3576 && isar_3472 >= isar_3472 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3232 > ienvelopes_3240 && iclose_3336 <= isar_3328 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3520 > ienvelopes_3528 && isar_3472 >= isar_3472 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_lower_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3232 > ienvelopes_3240 && iclose_3336 <= isar_3328 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3568 < ienvelopes_3576 && isar_3472 >= isar_3472 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3184 < ienvelopes_3192 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3520 > ienvelopes_3528 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_lower_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3184 < ienvelopes_3192 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3568 < ienvelopes_3576 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3232 > ienvelopes_3240 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3520 > ienvelopes_3528 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_sell_lower_line && open_buy_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3232 > ienvelopes_3240 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3568 < ienvelopes_3576 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3184 < ienvelopes_3192) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3520 > ienvelopes_3528) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_lower_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3184 < ienvelopes_3192) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3568 < ienvelopes_3576) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3232 > ienvelopes_3240) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3520 > ienvelopes_3528) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_lower_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3232 > ienvelopes_3240) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3568 < ienvelopes_3576) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3288 > isar_3280 && iclose_3184 < ienvelopes_3192 && iclose_3200 < ienvelopes_3208 && iclose_3216 >= ienvelopes_3224 &&
         li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3432 < isar_3424 && iclose_3520 > iclose_3568 < ienvelopes_3576 && iclose_3584 < ienvelopes_3592 && iclose_3600 >= ienvelopes_3608 &&
         li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_lower_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280 && iclose_3336 > isar_3328 && iclose_3352 <= isar_3344 &&
         li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3432 < isar_3424 && iclose_3568 < ienvelopes_3576 && iclose_3480 < isar_3472 && iclose_3496 >= isar_3488 &&
         li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3232 > ienvelopes_3240 && iclose_3288 > isar_3280 && iclose_3336 > isar_3328 && iclose_3352 <= isar_3344 &&
         li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3432 < isar_3424 && iclose_3520 > ienvelopes_3528 && iclose_3480 < isar_3472 && iclose_3496 >= isar_3488 &&
         li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_lower_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3232 > ienvelopes_3240 && iclose_3288 > isar_3280 && iclose_3336 > isar_3328 && iclose_3352 <= isar_3344 &&
         li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3432 < isar_3424 && iclose_3568 < ienvelopes_3576 && iclose_3480 < isar_3472 && iclose_3496 >= isar_3488 &&
         li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3520 > ienvelopes_3528 && iclose_3432 < isar_3424 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_lower_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3568 < ienvelopes_3576 && iclose_3432 < isar_3424 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3232 > ienvelopes_3240 && iclose_3288 > isar_3280 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3520 > ienvelopes_3528 && iclose_3432 < isar_3424 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_lower_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3232 > ienvelopes_3240 && iclose_3288 > isar_3280 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3568 < ienvelopes_3576 && iclose_3432 < isar_3424 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc && open_with_envelopes == FALSE && trade_at_the_cross_only && gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3288 > isar_3280 && iclose_3336 > isar_3328 && iclose_3352 <= isar_3344 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3432 < isar_3424 && iclose_3480 < isar_3472 && iclose_3496 >= isar_3488 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc && open_with_envelopes == FALSE && gi_1816 && trade_at_the_cross_only == FALSE && gi_1812 == FALSE &&
      g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3288 > isar_3280 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3432 < isar_3424 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc && open_with_envelopes == FALSE && trade_at_the_cross_only == FALSE && gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3288 > isar_3280) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3432 < isar_3424) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3520 > ienvelopes_3528 && iclose_3432 < isar_3424) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_lower_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3568 < ienvelopes_3576 && iclose_3432 < isar_3424) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_upper_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3232 > ienvelopes_3240 && iclose_3288 > isar_3280) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3520 > ienvelopes_3528 && iclose_3432 < isar_3424) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_lower_line && reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3232 > ienvelopes_3240 && iclose_3288 > isar_3280) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3568 < ienvelopes_3576 && iclose_3432 < isar_3424) li_3136 = 2;
   }
   if (reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes == FALSE && trade_at_the_cross_only == FALSE && gi_1816 == FALSE &&
      g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472) li_3136 = 2;
   }
   if (reverse_second_tc_entry == FALSE && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes == FALSE && trade_at_the_cross_only && gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 > isar_3328 && iclose_3352 <= isar_3344 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 < isar_3472 && iclose_3496 >= isar_3488 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192 && iclose_3200 < ienvelopes_3208 && iclose_3216 >= ienvelopes_3224 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3520 > ienvelopes_3528 && iclose_3536 > ienvelopes_3544 && iclose_3552 <= ienvelopes_3560 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192 && iclose_3200 < ienvelopes_3208 && iclose_3216 >= ienvelopes_3224 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3568 < ienvelopes_3576 && iclose_3584 < ienvelopes_3592 && iclose_3600 >= ienvelopes_3608 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3232 > ienvelopes_3240 && iclose_3248 > ienvelopes_3256 && iclose_3264 <= ienvelopes_3272 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3520 > ienvelopes_3528 && iclose_3536 > ienvelopes_3544 && iclose_3552 <= ienvelopes_3560 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3232 > ienvelopes_3240 && iclose_3248 > ienvelopes_3256 && iclose_3264 <= ienvelopes_3272 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3568 < ienvelopes_3576 && iclose_3584 < ienvelopes_3592 && iclose_3600 >= ienvelopes_3608 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3520 > ienvelopes_3528 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3568 < ienvelopes_3576 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3232 > ienvelopes_3240 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3520 > ienvelopes_3528 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3232 > ienvelopes_3240 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3568 < ienvelopes_3576 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3520 > ienvelopes_3528) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3568 < ienvelopes_3576) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3232 > ienvelopes_3240) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3520 > ienvelopes_3528) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3232 > ienvelopes_3240) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3568 < ienvelopes_3576) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3288 > isar_3280 && iclose_3184 < ienvelopes_3192 && iclose_3200 < ienvelopes_3208 && iclose_3216 >= ienvelopes_3224 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3432 < isar_3424 && iclose_3520 > ienvelopes_3528 && iclose_3536 > ienvelopes_3544 && iclose_3552 <= ienvelopes_3560 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3288 > isar_3280 && iclose_3184 < ienvelopes_3192 && iclose_3200 < ienvelopes_3208 && iclose_3216 >= ienvelopes_3224 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3432 < isar_3424 && iclose_3520 > iclose_3568 < ienvelopes_3576 && iclose_3584 < ienvelopes_3592 && iclose_3600 >= ienvelopes_3608 &&
         li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3288 > isar_3280 && iclose_3232 > ienvelopes_3240 && iclose_3248 > ienvelopes_3256 && iclose_3264 <= ienvelopes_3272 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3432 < isar_3424 && iclose_3520 > ienvelopes_3528 && iclose_3536 > ienvelopes_3544 && iclose_3552 <= ienvelopes_3560 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3288 > isar_3280 && iclose_3232 > ienvelopes_3240 && iclose_3248 > ienvelopes_3256 && iclose_3264 <= ienvelopes_3272 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3432 < isar_3424 && iclose_3568 < ienvelopes_3576 && iclose_3584 < ienvelopes_3592 && iclose_3600 >= ienvelopes_3608 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3520 > ienvelopes_3528 && iclose_3432 < isar_3424 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3520 > ienvelopes_3528 && iclose_3432 < isar_3424 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3520 > ienvelopes_3528 && iclose_3432 < isar_3424 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3520 > ienvelopes_3528 && iclose_3432 < isar_3424 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes == FALSE && trade_at_the_cross_only && gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3288 > isar_3280 && iclose_3304 <= isar_3296 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3432 < isar_3424 && iclose_3448 >= isar_3440 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes == FALSE && gi_1816 && trade_at_the_cross_only == FALSE && gi_1812 == FALSE &&
      g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3288 > isar_3280 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3432 < isar_3424 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes == FALSE && trade_at_the_cross_only == FALSE && gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3288 > isar_3280) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3432 < isar_3424) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3520 > ienvelopes_3528 && iclose_3432 < isar_3424) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3568 < ienvelopes_3576 && iclose_3432 < isar_3424) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3232 > ienvelopes_3240 && iclose_3288 > isar_3280) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3520 > ienvelopes_3528 && iclose_3432 < isar_3424) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 == FALSE && open_with_tc && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3232 > ienvelopes_3240 && iclose_3288 > isar_3280) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3568 < ienvelopes_3576 && iclose_3432 < isar_3424) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3184 < ienvelopes_3192 && iclose_3336 >= isar_3328 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3520 > ienvelopes_3528 && isar_3472 <= isar_3472 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3184 < ienvelopes_3192 && iclose_3336 >= isar_3328 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3568 < ienvelopes_3576 && isar_3472 <= isar_3472 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3232 > ienvelopes_3240 && iclose_3336 >= isar_3328 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3520 > ienvelopes_3528 && isar_3472 <= isar_3472 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3232 > ienvelopes_3240 && iclose_3336 >= isar_3328 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3568 < ienvelopes_3576 && isar_3472 <= isar_3472 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3184 < ienvelopes_3192 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3520 > ienvelopes_3528 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3184 < ienvelopes_3192 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3568 < ienvelopes_3576 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3232 > ienvelopes_3240 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3520 > ienvelopes_3528 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3232 > ienvelopes_3240 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3568 < ienvelopes_3576 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3184 < ienvelopes_3192) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3520 > ienvelopes_3528) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3184 < ienvelopes_3192) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3520 > ienvelopes_3528) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3184 < ienvelopes_3192) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3520 > ienvelopes_3528) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3184 < ienvelopes_3192) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3520 > ienvelopes_3528) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc && open_with_envelopes && trade_at_the_cross_only && gi_1816 == FALSE &&
      g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280 && iclose_3336 < isar_3328 && iclose_3352 >= isar_3344 &&
         li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3432 < isar_3424 && iclose_3520 > ienvelopes_3528 && iclose_3480 > isar_3472 && iclose_3496 <= isar_3488 &&
         li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc && open_with_envelopes && trade_at_the_cross_only && gi_1816 == FALSE &&
      g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280 && iclose_3336 < isar_3328 && iclose_3352 >= isar_3344 &&
         li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3432 < isar_3424 && iclose_3568 < ienvelopes_3576 && iclose_3480 > isar_3472 && iclose_3496 <= isar_3488 &&
         li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc && open_with_envelopes && trade_at_the_cross_only && gi_1816 == FALSE &&
      g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3232 > ienvelopes_3240 && iclose_3288 > isar_3280 && iclose_3336 < isar_3328 && iclose_3352 >= isar_3344 &&
         li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3432 < isar_3424 && iclose_3520 > ienvelopes_3528 && iclose_3480 > isar_3472 && iclose_3496 <= isar_3488 &&
         li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc && open_with_envelopes && trade_at_the_cross_only && gi_1816 == FALSE &&
      g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3232 > ienvelopes_3240 && iclose_3288 > isar_3280 && iclose_3336 < isar_3328 && iclose_3352 >= isar_3344 &&
         li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3432 < isar_3424 && iclose_3568 < ienvelopes_3576 && iclose_3480 > isar_3472 && iclose_3496 <= isar_3488 &&
         li_3804 < Time[0]) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3520 > ienvelopes_3528 && iclose_3432 < isar_3424 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3568 < ienvelopes_3576 && iclose_3432 < isar_3424 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3232 > ienvelopes_3240 && iclose_3288 > isar_3280 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3520 > ienvelopes_3528 && iclose_3432 < isar_3424 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc && open_with_envelopes && gi_1816 && trade_at_the_cross_only == FALSE &&
      gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3232 > ienvelopes_3240 && iclose_3288 > isar_3280 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3568 < ienvelopes_3576 && iclose_3432 < isar_3424 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (reverse_second_tc_entry && open_with_tc2 && open_with_tc && open_with_envelopes == FALSE && trade_at_the_cross_only && gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3288 > isar_3280 && iclose_3336 < isar_3328 && iclose_3352 >= isar_3344 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3432 < isar_3424 && iclose_3480 > isar_3472 && iclose_3496 <= isar_3488 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (reverse_second_tc_entry && open_with_tc2 && open_with_tc && open_with_envelopes == FALSE && gi_1816 && trade_at_the_cross_only == FALSE && gi_1812 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3288 > isar_3280 && iclose_3376 < ima_3384) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3432 < isar_3424 && iclose_3616 > ima_3624) li_3136 = 2;
   }
   if (reverse_second_tc_entry && open_with_tc2 && open_with_tc && open_with_envelopes == FALSE && trade_at_the_cross_only == FALSE && gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3288 > isar_3280) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3432 < isar_3424) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3520 > ienvelopes_3528 && iclose_3432 < isar_3424) li_3136 = 2;
   }
   if (open_buy_lower_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3520 > ienvelopes_3528 && iclose_3432 < isar_3424) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_upper_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3520 > ienvelopes_3528 && iclose_3432 < isar_3424) li_3136 = 2;
   }
   if (open_buy_upper_line && open_sell_lower_line && reverse_second_tc_entry && open_with_tc2 && open_with_tc && open_with_envelopes && trade_at_the_cross_only == FALSE &&
      gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3184 < ienvelopes_3192 && iclose_3288 > isar_3280) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3520 > ienvelopes_3528 && iclose_3432 < isar_3424) li_3136 = 2;
   }
   if (reverse_second_tc_entry && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes == FALSE && trade_at_the_cross_only == FALSE && gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472) li_3136 = 2;
   }
   if (reverse_second_tc_entry && open_with_tc2 && open_with_tc == FALSE && open_with_envelopes == FALSE && trade_at_the_cross_only && gi_1816 == FALSE && g_bars_2124 != Bars) {
      if (iatr_3144 > ld_3152 && iclose_3336 < isar_3328 && iclose_3352 >= isar_3344 && li_3800 < Time[0]) li_3136 = 1;
      if (iatr_3144 > ld_3152 && iclose_3480 > isar_3472 && iclose_3496 <= isar_3488 && li_3804 < Time[0]) li_3136 = 2;
   }
   if (gi_1068 && ilow_216 < ilow_248 && iopen_224 > ilow_248 && iclose_232 > ilow_248 && iclose_112 > ihigh_208 && iopen_224 < iopen_256 && iopen_224 < iclose_264) li_3136 = 1;
   if (gi_1072 && ihigh_208 > ihigh_240 && iopen_224 < ihigh_240 && iclose_232 < ihigh_240 && iclose_112 < ilow_216 && iopen_224 > iopen_256 && iopen_224 > iclose_264) li_3136 = 2;
   if (gi_1076 && ilow_280 < ilow_312 && iopen_288 > ilow_312 && iclose_296 > ilow_312 && iclose_112 > ihigh_272 && iopen_288 < iopen_320 && iopen_288 < iclose_328) li_3136 = 1;
   if (gi_1080 && ihigh_272 > ihigh_304 && iopen_288 < ihigh_304 && iclose_296 < ihigh_304 && iclose_112 < ilow_280 && iopen_288 > iopen_320 && iopen_288 > iclose_328) li_3136 = 2;
   if (gi_1084 && ilow_472 < ilow_504 && iopen_480 > ilow_504 && iclose_488 > ilow_504 && iclose_112 > ihigh_464 && iopen_480 < iopen_512 && iopen_480 < iclose_520) li_3136 = 1;
   if (gi_1088 && ihigh_464 > ihigh_496 && iopen_480 < ihigh_496 && iclose_488 < ihigh_496 && iclose_112 < ilow_472 && iopen_480 > iopen_512 && iopen_480 > iclose_520) li_3136 = 2;
   if (gi_1092 && ilow_408 < ilow_440 && iopen_416 > ilow_440 && iclose_424 > ilow_440 && iclose_112 > ihigh_400 && iopen_416 < iopen_448 && iopen_416 < iclose_456) li_3136 = 1;
   if (gi_1096 && ihigh_400 > ihigh_432 && iopen_416 < ihigh_432 && iclose_424 < ihigh_432 && iclose_112 < ilow_408 && iopen_416 > iopen_448 && iopen_416 > iclose_456) li_3136 = 2;
   if (gi_1464 && gi_76 && gi_756 && gi_788 && gi_1864 && gi_1848 && gi_1832 && gi_1844 && gi_1824 && g_bars_2124 != Bars && li_3136 == 1 && gi_1840 == 3 || gi_1840 == 1 &&
      (gi_116 && (!gi_2120)) || (!gi_116 && Bars != g_bars_2112)) {
      if (!li_3792) {
         if (AccountFreeMargin() < 0.0 * Lots) {
            Print("We have no money. Free Margin = ", AccountFreeMargin());
            return (0);
         }
         ld_44 = Ask - gi_1472 * Point;
         ld_52 = Ask + gi_1500 * Point;
         ticket_36 = OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
         if (ticket_36 > 0) {
            if (OrderSelect(ticket_36, SELECT_BY_TICKET, MODE_TRADES)) {
               Print("BUY order opened : ", OrderOpenPrice());
               g_bars_2124 = Bars;
               if (email_notification) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + " Open Buy");
               if (Use_Sound_only) PlaySound(gs_1788);
               if (Use_popup_and_sound_alert) Alert(gs_1780);
            } else Print("Error opening BUY order : ", GetLastError());
         }
         if (gi_116) gi_2120 = TRUE;
         if (!gi_116) g_bars_2112 = Bars;
         return (0);
      }
   }
   if (gi_1468 && gi_80 && gi_760 && gi_792 && gi_1864 && gi_1848 && gi_1836 && gi_1844 && gi_1828 && g_bars_2124 != Bars && li_3136 == 2 && gi_1840 == 3 || gi_1840 == 2 &&
      (gi_116 && (!gi_2120)) || (!gi_116 && Bars != g_bars_2112)) {
      if (!li_3792) {
         if (AccountFreeMargin() < 0.0 * Lots) {
            Print("We have no money. Free Margin = ", AccountFreeMargin());
            return (0);
         }
         ld_44 = Bid + gi_1472 * Point;
         ld_52 = Bid - gi_1500 * Point;
         ticket_36 = OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 99, 0, DeepPink);
         if (ticket_36 > 0) {
            if (OrderSelect(ticket_36, SELECT_BY_TICKET, MODE_TRADES)) {
               Print("SELL order opened : ", OrderOpenPrice());
               g_bars_2124 = Bars;
               if (email_notification) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + " Open Sell");
               if (Use_Sound_only) PlaySound(gs_1788);
               if (Use_popup_and_sound_alert) Alert(gs_1780);
            } else Print("Error opening SELL order : ", GetLastError());
         }
         if (gi_116) gi_2120 = TRUE;
         if (!gi_116) g_bars_2112 = Bars;
         return (0);
      }
   }
   if (dont_restrict_hedge) {
      gi_1468 = TRUE;
      gi_1464 = TRUE;
   }
   if (gi_1464 && gi_788 && gi_824 == FALSE && gi_1864 && gi_1716 && g_count_1728 < g_count_1732) OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 == FALSE && gi_1864 && gi_1720 && g_count_1732 < g_count_1728) OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 99, 0, DeepPink);
   if (gi_1464 && gi_756 && gi_788 && gi_824 == FALSE && gi_1824 && gi_1864 && use_tc_hedge == FALSE && gi_1336 && gi_1840 == 1 && g_count_1728 < g_count_1732 + 1) OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 == FALSE && gi_1828 && gi_1864 && use_tc_hedge == FALSE && gi_1336 && gi_1840 == 2 && g_count_1732 < g_count_1728 + 1) OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 99, 0, DeepPink);
   if (gi_1464 && gi_756 && gi_788 && gi_824 == FALSE && gi_1824 && double_the_hedge == FALSE && gi_1864 && use_tc_hedge == FALSE && gi_1340 && gi_1840 == 1 && g_count_1728 < g_count_1732 +
      hedge_plus) OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 == FALSE && gi_1828 && double_the_hedge == FALSE && gi_1864 && use_tc_hedge == FALSE && gi_1340 && gi_1840 == 2 && g_count_1732 < g_count_1728 +
      hedge_plus) OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea  " + li_40 + ")", 99, 0, DeepPink);
   if (gi_1464 && gi_756 && gi_788 && gi_824 == FALSE && gi_1824 && double_the_hedge == FALSE && gi_1864 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc2_hedge && isar_176 < iclose_168 &&
      g_count_1728 < g_count_1732 + hedge_plus) OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 == FALSE && gi_1828 && double_the_hedge == FALSE && gi_1864 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc2_hedge && isar_176 > iclose_168 &&
      g_count_1732 < g_count_1728 + hedge_plus) OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 99, 0, DeepPink);
   if (gi_1464 && gi_756 && gi_788 && gi_824 == FALSE && gi_1824 && double_the_hedge == FALSE && gi_1864 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge && isar_160 < iclose_152 &&
      g_count_1728 < g_count_1732 + hedge_plus) OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 == FALSE && gi_1828 && double_the_hedge == FALSE && gi_1864 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge && isar_160 > iclose_152 &&
      g_count_1732 < g_count_1728 + hedge_plus) OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 99, 0, DeepPink);
   if (gi_1464 && gi_756 && gi_788 && gi_824 == FALSE && gi_1824 && double_the_hedge == FALSE && gi_1864 && gi_932 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge == FALSE &&
      iclose_112 > ienvelopes_120 && g_count_1728 < g_count_1732 + hedge_plus) OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 == FALSE && gi_1828 && double_the_hedge == FALSE && gi_1864 && gi_932 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge == FALSE &&
      iclose_112 < ienvelopes_128 && g_count_1732 < g_count_1728 + hedge_plus) OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 99, 0, DeepPink);
   if (gi_1464 && gi_756 && gi_788 && gi_824 == FALSE && gi_1824 && double_the_hedge == FALSE && gi_1864 && gi_932 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge == FALSE &&
      iclose_112 > ienvelopes_120 && g_count_1728 < g_count_1732 + hedge_plus) OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 == FALSE && gi_1828 && double_the_hedge == FALSE && gi_1864 && gi_932 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge == FALSE &&
      iclose_112 < ienvelopes_128 && g_count_1732 < g_count_1728 + hedge_plus) OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 99, 0, DeepPink);
   if (gi_1464 && gi_756 && gi_788 && gi_824 == FALSE && gi_1824 && double_the_hedge && gi_1864 && use_tc_hedge == FALSE && gi_1340 && gi_1840 == 1 && g_count_1728 < g_count_1732 * 2 / hedge_plus) OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 == FALSE && gi_1828 && double_the_hedge && gi_1864 && use_tc_hedge == FALSE && gi_1340 && gi_1840 == 2 && g_count_1732 < g_count_1728 * 2 / hedge_plus) OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 99, 0, DeepPink);
   if (gi_1464 && gi_756 && gi_788 && gi_788 && gi_824 == FALSE && gi_1824 && double_the_hedge && gi_1864 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc2_hedge && isar_176 < iclose_168 &&
      g_count_1728 < g_count_1732 * 2 / hedge_plus) OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 == FALSE && gi_1828 && double_the_hedge && gi_1864 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc2_hedge && isar_176 > iclose_168 &&
      g_count_1732 < g_count_1728 * 2 / hedge_plus) OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 99, 0, DeepPink);
   if (gi_1464 && gi_756 && gi_788 && gi_824 == FALSE && gi_1824 && double_the_hedge && gi_1864 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge && isar_160 < iclose_152 &&
      g_count_1728 < g_count_1732 * 2 / hedge_plus) OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 == FALSE && gi_1828 && double_the_hedge && gi_1864 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge && isar_160 > iclose_152 &&
      g_count_1732 < g_count_1728 * 2 / hedge_plus) OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea  " + li_40 + ")", 99, 0, DeepPink);
   if (gi_1464 && gi_756 && gi_788 && gi_824 == FALSE && gi_1824 && double_the_hedge && gi_1864 && gi_932 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge == FALSE &&
      iclose_112 > ienvelopes_120 && g_count_1728 < g_count_1732 * 2 / hedge_plus) OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 == FALSE && gi_1828 && double_the_hedge && gi_1864 && gi_932 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge == FALSE &&
      iclose_112 < ienvelopes_128 && g_count_1732 < g_count_1728 * 2 / hedge_plus) OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 99, 0, DeepPink);
   if (gi_1464 && gi_756 && gi_788 && gi_824 == FALSE && gi_1824 && double_the_hedge && gi_1864 && gi_932 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge == FALSE &&
      iclose_112 > ienvelopes_120 && g_count_1728 < g_count_1732 * 2 / hedge_plus) OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 == FALSE && gi_1828 && double_the_hedge && gi_1864 && gi_932 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge == FALSE &&
      iclose_112 < ienvelopes_128 && g_count_1732 < g_count_1728 * 2 / hedge_plus) OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 99, 0, DeepPink);
   if (gi_1464 && gi_788 && gi_824 && gi_1864 && gi_1716 && g_count_1728 < g_count_1732) OrderSend(Symbol(), OP_BUY, lots_96, Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 && gi_1864 && gi_1720 && g_count_1732 < g_count_1728) OrderSend(Symbol(), OP_SELL, lots_104, Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 99, 0, DeepPink);
   if (gi_1464 && gi_756 && gi_788 && gi_824 == FALSE && gi_1824 && gi_1864 && use_tc_hedge == FALSE && gi_1336 && gi_1840 == 1 && g_count_1728 < g_count_1732 + 1) OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 == FALSE && gi_1828 && gi_1864 && use_tc_hedge == FALSE && gi_1336 && gi_1840 == 2 && g_count_1732 < g_count_1728 + 1) OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 99, 0, DeepPink);
   if (gi_1464 && gi_756 && gi_788 && gi_824 && gi_1824 && double_the_hedge == FALSE && gi_1864 && use_tc_hedge == FALSE && gi_1340 && gi_1840 == 1 && gd_808 < gd_800 * gd_828) OrderSend(Symbol(), OP_BUY, lots_96, Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 && gi_1828 && double_the_hedge == FALSE && gi_1864 && use_tc_hedge == FALSE && gi_1340 && gi_1840 == 2 && gd_808 > gd_800 * gd_828) OrderSend(Symbol(), OP_SELL, lots_104, Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 99, 0, DeepPink);
   if (gi_1464 && gi_756 && gi_788 && gi_824 && gi_1824 && double_the_hedge == FALSE && gi_1864 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc2_hedge && isar_176 < iclose_168 &&
      gd_808 < gd_800 * gd_828) OrderSend(Symbol(), OP_BUY, lots_96, Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 && gi_1828 && double_the_hedge == FALSE && gi_1864 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc2_hedge && isar_176 > iclose_168 &&
      gd_808 > gd_800 * gd_828) OrderSend(Symbol(), OP_SELL, lots_104, Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 99, 0, DeepPink);
   if (gi_1464 && gi_756 && gi_788 && gi_824 && gi_1824 && double_the_hedge == FALSE && gi_1864 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge && isar_160 < iclose_152 &&
      gd_808 < gd_800 * gd_828) OrderSend(Symbol(), OP_BUY, lots_96, Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 && gi_1828 && double_the_hedge == FALSE && gi_1864 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge && isar_160 > iclose_152 &&
      gd_808 > gd_800 * gd_828) OrderSend(Symbol(), OP_SELL, lots_104, Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 99, 0, DeepPink);
   if (gi_1464 && gi_756 && gi_788 && gi_824 && gi_1824 && double_the_hedge == FALSE && gi_1864 && gi_932 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge == FALSE &&
      iclose_112 > ienvelopes_120 && gd_808 < gd_800 * gd_828) OrderSend(Symbol(), OP_BUY, lots_96, Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea  " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 && gi_1828 && double_the_hedge == FALSE && gi_1864 && gi_932 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge == FALSE &&
      iclose_112 < ienvelopes_128 && gd_808 > gd_800 * gd_828) OrderSend(Symbol(), OP_SELL, lots_104, Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 99, 0, DeepPink);
   if (gi_1464 && gi_756 && gi_788 && gi_824 && gi_1824 && double_the_hedge == FALSE && gi_1864 && gi_932 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge == FALSE &&
      iclose_112 > ienvelopes_120 && gd_808 < gd_800 * gd_828) OrderSend(Symbol(), OP_BUY, lots_96, Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 && gi_1828 && double_the_hedge == FALSE && gi_1864 && gi_932 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge == FALSE &&
      iclose_112 < ienvelopes_128 && gd_808 > gd_800 * gd_828) OrderSend(Symbol(), OP_SELL, lots_104, Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 99, 0, DeepPink);
   if (gi_1464 && gi_756 && gi_788 && gi_824 && gi_1824 && gi_1864 && use_tc_hedge == FALSE && gi_1340 && gi_1840 == 1 && gd_808 < gd_800 * gd_828) OrderSend(Symbol(), OP_BUY, lots_96, Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 && gi_1828 && gi_1864 && use_tc_hedge == FALSE && gi_1340 && gi_1840 == 2 && gd_808 > gd_800 * gd_828) OrderSend(Symbol(), OP_SELL, lots_104, Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 99, 0, DeepPink);
   if (gi_1464 && gi_756 && gi_788 && gi_824 && gi_1824 && gi_1864 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc2_hedge && isar_176 < iclose_168 && gd_808 < gd_800 * gd_828) OrderSend(Symbol(), OP_BUY, lots_96, Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 && gi_1828 && gi_1864 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc2_hedge && isar_176 > iclose_168 && gd_808 > gd_800 * gd_828) OrderSend(Symbol(), OP_SELL, lots_104, Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 99, 0, DeepPink);
   if (gi_1464 && gi_756 && gi_788 && gi_824 && gi_1824 && gi_1864 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge && isar_160 < iclose_152 && gd_808 < gd_800 * gd_828) OrderSend(Symbol(), OP_BUY, lots_96, Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 && gi_1828 && gi_1864 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge && isar_160 > iclose_152 && gd_808 > gd_800 * gd_828) OrderSend(Symbol(), OP_SELL, lots_104, Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea  " + li_40 + ")", 99, 0, DeepPink);
   if (gi_1464 && gi_756 && gi_788 && gi_824 && gi_1824 && gi_1864 && gi_932 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge == FALSE && iclose_112 > ienvelopes_120 &&
      gd_808 < gd_800 * gd_828) OrderSend(Symbol(), OP_BUY, lots_96, Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 && gi_1828 && gi_1864 && gi_932 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge == FALSE && iclose_112 < ienvelopes_128 &&
      gd_808 > gd_800 * gd_828) OrderSend(Symbol(), OP_SELL, lots_104, Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 99, 0, DeepPink);
   if (gi_1464 && gi_756 && gi_788 && gi_824 && gi_1824 && gi_1864 && gi_932 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge == FALSE && iclose_112 > ienvelopes_120 &&
      gd_808 < gd_800 * gd_828) OrderSend(Symbol(), OP_BUY, lots_96, Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
   if (gi_1468 && gi_760 && gi_792 && gi_824 && gi_1828 && gi_1864 && gi_932 && gi_1340 == FALSE && gi_1336 == FALSE && use_tc_hedge == FALSE && iclose_112 < ienvelopes_128 &&
      gd_808 > gd_800 * gd_828) OrderSend(Symbol(), OP_SELL, lots_104, Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 99, 0, DeepPink);
   if (manage_all_trades && gi_2028 && ld_3128 > profit_target_percent) Close_target();
   if (manage_all_trades == FALSE && gi_2028 && ld_3128 > profit_target_percent) mClose_target();
   if (gi_2032 && ld_64 > equity_target || ld_3128 < emergency_loss_protection) close_all_orders();
   if (gi_2096 && ld_3128 < -10.0) {
      gi_unused_2100 = TRUE;
      gi_unused_2104 = FALSE;
   }
   if (gi_2096 && ld_3128 > -2.0) {
      gi_unused_2100 = FALSE;
      gi_unused_2104 = TRUE;
   }
   int ord_total_3808 = OrdersTotal();
   for (int pos_3812 = ord_total_3808 - 1; pos_3812 >= 0; pos_3812--) {
      OrderSelect(pos_3812, SELECT_BY_POS);
      li_unused_60 = 0;
      if (OrderMagicNumber() == g_magic_1940 && Symbol() == gs_gbpjpym_1896) {
         if (OrderType() == OP_SELL) gd_816 += 1.0;
         if (OrderType() == OP_BUY) gd_816 += 1.0;
         if (gi_1916 && Hour() == gi_1920 && Minute() == gi_1924 && DayOfWeek() == gi_1928 && OrdersTotal() == 0) OrderSend(gs_gbpjpym_1896, OP_BUY, g_lots_1904, Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 99, 236, DodgerBlue);
         if (gi_1912 && Hour() == gi_1920 && Minute() == gi_1924 && DayOfWeek() == gi_1928 && OrdersTotal() == 0) OrderSend(gs_gbpjpym_1896, OP_SELL, g_lots_1904, Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 99, 0, DeepPink);
      }
   }
   if (gi_784 && li_72 > 100) profit_target_percent = 5;
   if (gi_784 && li_72 > 50) profit_target_percent = 2;
   if (gi_784 && li_72 > 20) profit_target_percent = 1;
   if (gi_784 && li_72 < 20) profit_target_percent = 0.1;
   if (gi_2000 == 0 && iclose_112 == price_936) gi_2000++;
   if (gi_2000 == 1 && iclose_112 > price_928) gi_2000++;
   if (gi_2000 == 2 && iclose_112 > price_920) gi_2000++;
   if (gi_2000 == 3 && iclose_112 > price_912) gi_2000++;
   if (gi_2000 == 4 && iclose_112 > price_904) gi_2000++;
   if (gi_2000 == 5 && iclose_112 > price_896) gi_2000++;
   if (gi_2000 == 6 && iclose_112 > price_888) gi_2000++;
   if (gi_2004 == 0 && iclose_112 == price_936) gi_2004++;
   if (gi_2004 == 1 && iclose_112 > price_928) gi_2004++;
   if (gi_2004 == 2 && iclose_112 > price_920) gi_2004++;
   if (gi_2004 == 3 && iclose_112 > price_912) gi_2004++;
   if (gi_2004 == 4 && iclose_112 > price_904) gi_2004++;
   if (gi_2004 == 5 && iclose_112 > price_896) gi_2004++;
   if (gi_2004 == 6 && iclose_112 > price_888) gi_2004++;
   if (gi_1972 && gi_1992 == FALSE && iclose_112 > price_928 && iclose_112 < price_920) {
      OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 3, 236, DodgerBlue);
      gi_1992 = TRUE;
   }
   if (gi_1972 && gi_1976 == FALSE && iclose_112 > price_912 && iclose_112 < price_904) {
      OrderSend(Symbol(), OP_BUY, LotsOptimized(), Ask, 200, 0, 0, "Buy(Dracula Forex Robot ea   " + li_40 + ")", 1, 236, DodgerBlue);
      gi_1976 = TRUE;
   }
   if (gi_1972 && gi_1980 == FALSE && iclose_112 < price_912 && iclose_112 > price_920) {
      OrderSend(Symbol(), OP_SELL, LotsOptimized(), Bid, 200, 0, 0, "Sell(Dracula Forex Robot ea   " + li_40 + ")", 2, 0, DeepPink);
      gi_1980 = TRUE;
   }
   if (gi_2024 && ld_64 < emergency_loss_protection) close_all_orders();
   if (gi_112) {
      double_the_hedge = FALSE;
      hedge_plus = 0;
      open_with_tc = FALSE;
      open_with_tc2 = FALSE;
      use_tc2_hedge = FALSE;
   }
   if (gi_112 && g_count_1728 == g_count_1732) use_tc2_hedge = FALSE;
   if (dis_dbl_hedge && ld_64 < at_percent_profit) double_the_hedge = FALSE;
   if (dis_dbl_hedge && li_72 == 0) double_the_hedge = TRUE;
   if (close_trades_limit && li_72 > limit) close_all_orders();
   if (li_72 == 0) {
      open_with_envelopes = FALSE;
      reverse_second_tc_entry = FALSE;
   }
   if (li_72 > 0) {
      open_with_envelopes = TRUE;
      reverse_second_tc_entry = TRUE;
   }
   if (gi_1796) {
      gd_2008 = 0.0;
      gd_2016 = 0.0;
      gi_796 = FALSE;
      gi_824 = FALSE;
      gi_756 = TRUE;
      gi_760 = TRUE;
      ld_3128 = 0;
      gd_1672 = 0;
      gd_808 = 0;
      gd_800 = 0;
      li_3124 = 0;
      g_count_1744 = 0;
      g_count_1740 = 0;
      gd_unused_2068 = Lots;
      g_lots_2076 = Lots;
   }
   if (OrdersTotal() == 0) {
      gi_1976 = FALSE;
      gi_1980 = FALSE;
      gi_unused_1984 = 0;
      gi_unused_1988 = 0;
      gi_1992 = FALSE;
      gi_unused_1996 = 0;
   }
   if (iclose_112 < isar_3280) gs_none_1948 = "short";
   if (iclose_112 > isar_3280) gs_none_1948 = "long";
   if (!gi_116) g_bars_2112 = Bars;
   return (0);
}