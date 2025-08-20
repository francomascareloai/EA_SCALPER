string gs_76 = "EA with Force Magic V.2";
extern int magic = 1234;
extern bool closeall = FALSE;
extern bool closelosses = FALSE;
extern double minlosses = 100.0;
extern string moneymanagement = "Money Management";
extern double lots = 0.1;
extern bool mm = FALSE;
extern double risk = 1.0;
extern double minlot = 0.01;
extern double maxlot = 100.0;
extern double lotdigits = 2.0;
extern bool basketpercent = FALSE;
extern double profit = 10.0;
extern double loss = 30.0;
extern string ordersmanagement = "Order Management";
extern bool isbrokerecn = FALSE;
extern bool timeout = FALSE;
extern double timeminutes = 60.0;
extern double maxorders = 200.0;
extern bool maxtradesperpair = FALSE;
extern double maxtradespercent = 50.0;
extern double pipstep = 0.0;
extern bool hidesl = FALSE;
extern bool hidetp = FALSE;
extern double lstoploss = 0.0;
extern double sstoploss = 0.0;
extern bool dynamicsl = FALSE;
extern int atrperiod = 14;
extern double atrmultiple = 1.0;
extern int atrtimeframe = 1440;
extern int atrshift = 1;
extern double ltakeprofit = 10.0;
extern double stakeprofit = 10.0;
extern double ltrailingstop = 20.0;
extern double strailingstop = 10.0;
extern int slippage = 1;
extern string entrylogics = "Entry Logics";
extern int closetimeframe = 5;
extern int closeshift = 0;
extern int matimeframe = 5;
extern int maperiod1 = 5;
extern int maperiod2 = 4;
extern int mamethod = 0;
extern int maprice = 1;
extern int mashift = 1;
extern bool sleeping = FALSE;
extern int sleepingminutes = 10;
extern string trendfilters = "Trend Filters";
extern bool enforceall = FALSE;
extern bool oppositeclose = FALSE;
extern bool reverseontrend = FALSE;
extern bool tradetrendsonly = FALSE;
extern int trendmaperiod = 14;
extern bool mafilter = FALSE;
extern int mafiltertimeframe = 0;
extern int mafilterperiod = 100;
extern int mafiltermethod = 0;
extern int mafilterprice = 0;
extern int mafiltershift = 1;
extern bool damianifilter = FALSE;
extern int damianitimeframe = 0;
extern int visatr = 13;
extern int visstd = 20;
extern int sedatr = 40;
extern int sedstd = 100;
extern double thresholdlevel = 1.4;
extern int damianishift = 1;
extern string carmen = "Carmen Settings";
extern bool usecarmen = FALSE;
extern string Warning = "GBP/USD vs EUR/USD";
extern int average = 3;
extern double space = 1.0;
extern bool try_again = FALSE;
extern bool Display_TakeProfit = TRUE;
extern string SetOne = "**********************Set_One_Settings***************";
extern double Main_expand_rate_1 = 75.0;
extern double LineOne_expand_rate_1 = 20.0;
extern double LineTwo_expand_rate_1 = 10.0;
extern string SetTwo = "**********************Set_Two_Settings***************";
extern double start_at_pips_profit_2 = 50.0;
extern double Main_expand_rate_2 = 65.0;
extern double LineOne_expand_rate_2 = 40.0;
extern double LineTwo_expand_rate_2 = 20.0;
extern string SetThree = "**********************Set_Three_Settings***********";
extern double start_at_pips_profit_3 = 100.0;
extern double Main_expand_rate_3 = 50.0;
extern double LineOne_expand_rate_3 = 25.0;
extern double LineTwo_expand_rate_3 = 15.0;
extern string SetFour = "**********************Set_Four_Settings***********";
extern double start_at_pips_profit_4 = 150.0;
extern double Main_expand_rate_4 = 35.0;
extern double LineOne_expand_rate_4 = 15.0;
extern double LineTwo_expand_rate_4 = 10.0;
extern int carmenshift = 1;
extern string timefilter = "Time Filter";
extern int summergmtshift = 2;
extern int wintergmtshift = 1;
extern bool generalfilter1 = FALSE;
extern int starthour1 = 7;
extern int startminutes1 = 0;
extern int endhour1 = 21;
extern int endminutes1 = 0;
extern bool generalfilter2 = FALSE;
extern int starthour2 = 7;
extern int startminutes2 = 0;
extern int endhour2 = 21;
extern int endminutes2 = 0;
extern bool generalfilter3 = FALSE;
extern int starthour3 = 7;
extern int startminutes3 = 0;
extern int endhour3 = 21;
extern int endminutes3 = 0;
extern bool tradesunday = TRUE;
extern bool fridayfilter = FALSE;
extern int fridayhour = 21;
extern int fridayminutes = 0;



extern int h1 = 6;
extern int h2 = 12;
extern int clear = 5;
#include <stdlib.mqh>
//+------------------------------------------------------------------+
//| global variables to program:                                     |
//+------------------------------------------------------------------+
double Price[2];
int    giSlippage;
bool   CloseOrdersWithMinusProfit = true;




int gi_736;
int gi_740;
int gi_744;
int gi_748;
string gs_752;
string gs_760;
string gs_768;
string gs_776;
string gs_784;
string gs_792;
int g_str2time_800;
int g_str2time_804;
int g_str2time_808;
int gi_812;
int gi_816;
string gs_820;
string gs_828;
string gs_836;
string gs_844;
int g_str2time_852;
int g_str2time_856;
int gi_860;
int gi_864;
string gs_868;
string gs_876;
string gs_884;
string gs_892;
int g_str2time_900;
int g_str2time_904;
bool gi_unused_908 = FALSE;
string gs_unused_912 = "Alert.wav";
int g_color_920 = Green;
int gi_unused_924 = 16776960;
int g_color_928 = Red;
int gi_unused_932 = 15631086;
int gi_unused_936 = 16711680;
int gi_unused_940 = 255;
int g_order_total_944;
int g_pos_948;
int gi_960;
double g_order_open_price_964;
double g_order_open_price_972;
double g_order_open_price_980;
double g_order_open_price_988;
double g_order_open_price_996;
double g_order_open_price_1004;
double gda_1012[14];
double gda_1016[14];
double gd_1020;
double gd_1028;
int g_digits_1036;
int g_datetime_1040;

int init() {
   g_digits_1036 = Digits;
   if (g_digits_1036 == 3 || g_digits_1036 == 5) {
      gd_1020 = 10.0 * Point;
      gd_1028 = 10;
   } else {
      gd_1020 = Point;
      gd_1028 = 1;
   }
   gda_1016[13] = D'28.03.2012 11:00';
   gda_1012[13] = D'31.10.2012 12:00';
   gda_1016[12] = D'29.03.2011 11:00';
   gda_1012[12] = D'25.10.2011 12:00';
   gda_1016[11] = D'30.03.2010 11:00';
   gda_1012[11] = D'26.10.2010 12:00';
   gda_1016[10] = D'29.03.2009 11:00';
   gda_1012[10] = D'25.10.2009 12:00';
   gda_1016[9] = D'30.03.2008 11:00';
   gda_1012[9] = D'26.10.2008 12:00';
   gda_1016[8] = D'25.03.2007 11:00';
   gda_1012[8] = D'28.10.2007 12:00';
   gda_1016[7] = D'26.03.2006 11:00';
   gda_1012[7] = D'29.10.2006 12:00';
   gda_1016[6] = D'27.03.2005 11:00';
   gda_1012[6] = D'30.10.2005 12:00';
   gda_1016[5] = D'28.03.2004 11:00';
   gda_1012[5] = D'31.10.2004 12:00';
   gda_1016[4] = D'30.03.2003 11:00';
   gda_1012[4] = D'26.10.2003 12:00';
   gda_1016[3] = D'31.03.2002 11:00';
   gda_1012[3] = D'27.10.2002 12:00';
   gda_1016[2] = D'25.03.2001 11:00';
   gda_1012[2] = D'28.10.2001 12:00';
   gda_1016[1] = D'26.03.2000 11:00';
   gda_1012[1] = D'29.10.2000 12:00';
   gda_1016[0] = 922586400;
   gda_1012[0] = 941338800;
   return (0);
}

void deinit() {
   Comment("");
}

int start() {
   

   if((!isTradeTimeInt(h1, 00, h1, h2))){
     /* if(isTradeTimeInt(23, 50, 23, 59)){
         clear=clear-1;
         if(clear==0){
            clear=5;
            int iOrders=OrdersTotal()-1, i;
         
            for(i=iOrders; i>=0; i--) {
               if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && (OrderProfit() <= 0)) {
                  if((OrderType()<=OP_SELL) && GetMarketInfo()) {
                    if(!OrderClose(OrderTicket(),OrderLots(),Price[1-OrderType()],giSlippage)) Print(OrderError());
                  }
                }
             // if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && (OrderType()<=OP_SELL) && GetMarketInfo() && !OrderClose(OrderTicket(),OrderLots(),Price[1-OrderType()],giSlippage)) Print(OrderError());
            }
         }
      }
      */
      return (0);
   }

   double iatr_88;
   double ima_96;
   double icustom_104;
   double icustom_112;
   double icustom_120;
   double icustom_128;
   double icustom_136;
   double icustom_144;
   double icustom_152;
   double icustom_160;
   bool li_176;
   bool li_180;
   bool li_184;
   bool li_188;
   bool li_192;
   bool li_196;
   string ls_0 = "2020.03.20";
   int str2time_8 = StrToTime(ls_0);
   if (TimeCurrent() >= str2time_8) {
      Alert("silahkan hubungi saya budiman.terima kasih!");
      return (0);
   }
   if (closeall) {
      f0_7();
      f0_11();
   }
   if (closelosses) {
      f0_14();
      f0_20();
   }
   if (basketpercent) f0_16(profit, loss);
   if (timeout) {
      f0_10();
      f0_27();
   }
   if (hidetp || hidesl) {
      f0_3();
      f0_6();
   }
   f0_15(ltrailingstop);
   f0_4(strailingstop);
   if (OrdersHistoryTotal() > 0) {
      for (g_pos_948 = 0; g_pos_948 < OrdersHistoryTotal(); g_pos_948++) {
         OrderSelect(g_pos_948, SELECT_BY_POS, MODE_HISTORY);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) g_datetime_1040 = OrderCloseTime();
      }
   }
   if (sleeping && TimeCurrent() - g_datetime_1040 < 60 * sleepingminutes) return (0);
   if (TimeCurrent() < gda_1012[TimeYear(TimeCurrent()) - 1999] && TimeCurrent() > gda_1016[TimeYear(TimeCurrent()) - 1999]) gi_748 = summergmtshift;
   else gi_748 = wintergmtshift;
   string ls_unused_12 = "";
   string ls_20 = Year() + "." + Month() + "." + Day();
   if (generalfilter1) {
      gi_736 = starthour1 + gi_748;
      if (gi_736 > 23) gi_736 -= 24;
      if (gi_736 < 10) gs_752 = "0" + gi_736;
      if (gi_736 > 9) gs_752 = gi_736;
      if (startminutes1 < 10) gs_760 = "0" + startminutes1;
      if (startminutes1 > 9) gs_760 = startminutes1;
      g_str2time_800 = StrToTime(ls_20 + " " + gs_752 + ":" + gs_760);
      gi_740 = endhour1 + gi_748;
      if (gi_740 > 23) gi_740 -= 24;
      if (endhour1 < 10) gs_768 = "0" + gi_740;
      if (endhour1 > 9) gs_768 = gi_740;
      if (endminutes1 < 10) gs_776 = "0" + endminutes1;
      if (endminutes1 > 9) gs_776 = endminutes1;
      g_str2time_804 = StrToTime(ls_20 + " " + gs_768 + ":" + gs_776);
   }
   if (generalfilter2) {
      gi_812 = starthour2 + gi_748;
      if (gi_812 > 23) gi_812 -= 24;
      gi_812 = starthour2 + gi_748;
      if (gi_812 > 23) gi_812 -= 24;
      if (gi_812 < 10) gs_820 = "0" + gi_812;
      if (gi_812 > 9) gs_820 = gi_812;
      if (startminutes2 < 10) gs_828 = "0" + startminutes2;
      if (startminutes2 > 9) gs_828 = startminutes2;
      g_str2time_852 = StrToTime(ls_20 + " " + gs_820 + ":" + gs_828);
      gi_816 = endhour2 + gi_748;
      if (gi_816 > 23) gi_816 -= 24;
      if (endhour2 < 10) gs_836 = "0" + gi_816;
      if (endhour2 > 9) gs_836 = gi_816;
      if (endminutes2 < 10) gs_844 = "0" + endminutes2;
      if (endminutes2 > 9) gs_844 = endminutes2;
      g_str2time_856 = StrToTime(ls_20 + " " + gs_836 + ":" + gs_844);
   }
   if (generalfilter3) {
      gi_860 = starthour3 + gi_748;
      if (gi_860 > 23) gi_860 -= 24;
      gi_860 = starthour3 + gi_748;
      if (gi_860 > 23) gi_860 -= 24;
      if (gi_860 < 10) gs_868 = "0" + gi_860;
      if (gi_860 > 9) gs_868 = gi_860;
      if (startminutes3 < 10) gs_876 = "0" + startminutes3;
      if (startminutes3 > 9) gs_876 = startminutes3;
      g_str2time_900 = StrToTime(ls_20 + " " + gs_868 + ":" + gs_876);
      gi_864 = endhour3 + gi_748;
      if (gi_864 > 23) gi_864 -= 24;
      if (endhour3 < 10) gs_884 = "0" + gi_864;
      if (endhour3 > 9) gs_884 = gi_864;
      if (endminutes3 < 10) gs_892 = "0" + endminutes3;
      if (endminutes3 > 9) gs_892 = endminutes3;
      g_str2time_904 = StrToTime(ls_20 + " " + gs_884 + ":" + gs_892);
   }
   if (fridayfilter) {
      gi_744 = fridayhour + gi_748;
      if (gi_744 > 23) gi_744 -= 24;
      if (gi_744 < 10) gs_784 = "0" + gi_744;
      if (gi_744 > 9) gs_784 = gi_744;
      if (fridayminutes < 10) gs_792 = "0" + fridayminutes;
      if (fridayminutes > 9) gs_792 = fridayminutes;
      g_str2time_808 = StrToTime(ls_20 + " " + gs_784 + ":" + gs_792);
   }
   bool li_28 = TRUE;
   if (generalfilter1 && (gi_736 <= gi_740 && TimeCurrent() < g_str2time_800 || TimeCurrent() > g_str2time_804) || (gi_736 > gi_740 && TimeCurrent() < g_str2time_800 &&
      TimeCurrent() > g_str2time_804)) li_28 = FALSE;
   bool li_32 = TRUE;
   if (generalfilter2 && (gi_812 <= gi_816 && TimeCurrent() < g_str2time_852 || TimeCurrent() > g_str2time_856) || (gi_812 > gi_816 && TimeCurrent() < g_str2time_852 &&
      TimeCurrent() > g_str2time_856)) li_32 = FALSE;
   bool li_36 = TRUE;
   if (generalfilter3 && (gi_860 <= gi_864 && TimeCurrent() < g_str2time_900 || TimeCurrent() > g_str2time_904) || (gi_860 > gi_864 && TimeCurrent() < g_str2time_900 &&
      TimeCurrent() > g_str2time_904)) li_36 = FALSE;
   bool li_40 = TRUE;
   if (tradesunday == FALSE && DayOfWeek() == 0) li_40 = FALSE;
   bool li_44 = TRUE;
   if (fridayfilter && li_28 == TRUE || li_32 == TRUE || li_36 == TRUE && DayOfWeek() == 5 && TimeCurrent() > g_str2time_808) li_44 = FALSE;
   double iclose_48 = iClose(NULL, closetimeframe, closeshift);
   double ima_56 = iMA(NULL, matimeframe, maperiod1, 0, mamethod, maprice, mashift);
   double ima_64 = iMA(NULL, matimeframe, maperiod2, 0, mamethod, maprice, mashift);
   double ima_72 = iMA(NULL, 0, trendmaperiod, 0, MODE_SMA, PRICE_CLOSE, 1);
   double ima_80 = iMA(NULL, 0, trendmaperiod, 0, MODE_SMA, PRICE_CLOSE, 2);
   if (dynamicsl) {
      iatr_88 = iATR(NULL, atrtimeframe, atrperiod, atrshift);
      lstoploss = iatr_88 * atrmultiple / Point / gd_1028;
      sstoploss = iatr_88 * atrmultiple / Point / gd_1028;
   }
   if (mafilter) ima_96 = iMA(NULL, mafiltertimeframe, mafilterperiod, 0, mafiltermethod, mafilterprice, mafiltershift);
   if (damianifilter) {
      icustom_104 = iCustom(NULL, damianitimeframe, "Damiani_volatmeter v3.2", visatr, visstd, sedatr, sedstd, thresholdlevel, 0, damianishift);
      icustom_112 = iCustom(NULL, damianitimeframe, "Damiani_volatmeter v3.2", visatr, visstd, sedatr, sedstd, thresholdlevel, 2, damianishift);
   }
   if (usecarmen) {
      icustom_120 = iCustom(NULL, 0, "carmens_eyes_v3.1", Warning, average, space, try_again, Display_TakeProfit, SetOne, Main_expand_rate_1, LineOne_expand_rate_1, LineTwo_expand_rate_1,
         SetTwo, start_at_pips_profit_2, Main_expand_rate_2, LineOne_expand_rate_2, LineTwo_expand_rate_2, SetThree, start_at_pips_profit_3, Main_expand_rate_3, LineOne_expand_rate_3,
         LineTwo_expand_rate_3, SetFour, start_at_pips_profit_4, Main_expand_rate_4, LineOne_expand_rate_4, LineTwo_expand_rate_4, 0, carmenshift);
      icustom_128 = iCustom(NULL, 0, "carmens_eyes_v3.1", Warning, average, space, try_again, Display_TakeProfit, SetOne, Main_expand_rate_1, LineOne_expand_rate_1, LineTwo_expand_rate_1,
         SetTwo, start_at_pips_profit_2, Main_expand_rate_2, LineOne_expand_rate_2, LineTwo_expand_rate_2, SetThree, start_at_pips_profit_3, Main_expand_rate_3, LineOne_expand_rate_3,
         LineTwo_expand_rate_3, SetFour, start_at_pips_profit_4, Main_expand_rate_4, LineOne_expand_rate_4, LineTwo_expand_rate_4, 3, carmenshift);
      icustom_136 = iCustom(NULL, 0, "carmens_eyes_v3.1", Warning, average, space, try_again, Display_TakeProfit, SetOne, Main_expand_rate_1, LineOne_expand_rate_1, LineTwo_expand_rate_1,
         SetTwo, start_at_pips_profit_2, Main_expand_rate_2, LineOne_expand_rate_2, LineTwo_expand_rate_2, SetThree, start_at_pips_profit_3, Main_expand_rate_3, LineOne_expand_rate_3,
         LineTwo_expand_rate_3, SetFour, start_at_pips_profit_4, Main_expand_rate_4, LineOne_expand_rate_4, LineTwo_expand_rate_4, 4, carmenshift);
      icustom_144 = iCustom(NULL, 0, "carmens_eyes_v3.1", Warning, average, space, try_again, Display_TakeProfit, SetOne, Main_expand_rate_1, LineOne_expand_rate_1, LineTwo_expand_rate_1,
         SetTwo, start_at_pips_profit_2, Main_expand_rate_2, LineOne_expand_rate_2, LineTwo_expand_rate_2, SetThree, start_at_pips_profit_3, Main_expand_rate_3, LineOne_expand_rate_3,
         LineTwo_expand_rate_3, SetFour, start_at_pips_profit_4, Main_expand_rate_4, LineOne_expand_rate_4, LineTwo_expand_rate_4, 0, carmenshift + 1);
      icustom_152 = iCustom(NULL, 0, "carmens_eyes_v3.1", Warning, average, space, try_again, Display_TakeProfit, SetOne, Main_expand_rate_1, LineOne_expand_rate_1, LineTwo_expand_rate_1,
         SetTwo, start_at_pips_profit_2, Main_expand_rate_2, LineOne_expand_rate_2, LineTwo_expand_rate_2, SetThree, start_at_pips_profit_3, Main_expand_rate_3, LineOne_expand_rate_3,
         LineTwo_expand_rate_3, SetFour, start_at_pips_profit_4, Main_expand_rate_4, LineOne_expand_rate_4, LineTwo_expand_rate_4, 3, carmenshift + 1);
      icustom_160 = iCustom(NULL, 0, "carmens_eyes_v3.1", Warning, average, space, try_again, Display_TakeProfit, SetOne, Main_expand_rate_1, LineOne_expand_rate_1, LineTwo_expand_rate_1,
         SetTwo, start_at_pips_profit_2, Main_expand_rate_2, LineOne_expand_rate_2, LineTwo_expand_rate_2, SetThree, start_at_pips_profit_3, Main_expand_rate_3, LineOne_expand_rate_3,
         LineTwo_expand_rate_3, SetFour, start_at_pips_profit_4, Main_expand_rate_4, LineOne_expand_rate_4, LineTwo_expand_rate_4, 4, carmenshift + 1);
   }
   g_order_open_price_972 = 0;
   g_order_open_price_980 = 0;
   g_order_open_price_996 = 0;
   g_order_open_price_1004 = 0;
   if (OrdersTotal() > 0) {
      for (g_pos_948 = 0; g_pos_948 < OrdersTotal(); g_pos_948++) {
         OrderSelect(g_pos_948, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderCloseTime() == 0) {
            if (OrderType() == OP_BUY) {
               g_order_open_price_964 = OrderOpenPrice();
               if (g_order_open_price_964 > g_order_open_price_972) g_order_open_price_972 = g_order_open_price_964;
               if (g_order_open_price_980 == 0.0 || g_order_open_price_964 < g_order_open_price_980) g_order_open_price_980 = g_order_open_price_964;
            }
            if (OrderType() == OP_SELL) {
               g_order_open_price_988 = OrderOpenPrice();
               if (g_order_open_price_988 > g_order_open_price_996) g_order_open_price_996 = g_order_open_price_988;
               if (g_order_open_price_1004 == 0.0 || g_order_open_price_988 < g_order_open_price_1004) g_order_open_price_1004 = g_order_open_price_988;
            }
         }
      }
   }
   bool li_168 = FALSE;
   bool li_172 = FALSE;
   if (enforceall) {
      li_176 = TRUE;
      li_180 = TRUE;
      li_184 = TRUE;
      li_188 = TRUE;
      li_192 = TRUE;
      li_196 = TRUE;
      if (mafilter && (!(Ask > ima_96 && ima_72 > ima_80))) li_176 = FALSE;
      if (mafilter && (!(Bid < ima_96 && ima_72 < ima_80))) li_188 = FALSE;
      if (damianifilter && (!(icustom_104 < icustom_112 && ima_72 > ima_80))) li_180 = FALSE;
      if (damianifilter && (!(icustom_104 < icustom_112 && ima_72 < ima_80))) li_192 = FALSE;
      if (usecarmen && (!(icustom_120 > icustom_128 && icustom_120 > icustom_136 && (!(icustom_144 > icustom_152 && icustom_144 > icustom_160)) && ima_72 > ima_80))) li_184 = FALSE;
      if (usecarmen && (!(icustom_120 < icustom_128 && icustom_120 < icustom_136 && (!(icustom_144 < icustom_152 && icustom_144 < icustom_160)) && ima_72 < ima_80))) li_196 = FALSE;
      if (li_176 && li_180 && li_184 && mafilter || damianifilter || usecarmen) {
         li_168 = TRUE;
         if (oppositeclose) f0_11();
      }
      if (li_188 && li_192 && li_196 && mafilter || damianifilter || usecarmen) {
         li_172 = TRUE;
         if (oppositeclose) f0_7();
      }
   } else {
      if ((mafilter && Ask > ima_96 && ima_72 > ima_80) || (damianifilter && icustom_104 < icustom_112 && ima_72 > ima_80) || (usecarmen && icustom_120 > icustom_128 && icustom_120 > icustom_136 &&
         (!(icustom_144 > icustom_152 && icustom_144 > icustom_160)) && ima_72 > ima_80)) {
         li_168 = TRUE;
         if (oppositeclose) f0_11();
      }
      if ((mafilter && Bid < ima_96 && ima_72 < ima_80) || (damianifilter && icustom_104 < icustom_112 && ima_72 < ima_80) || (usecarmen && icustom_120 < icustom_128 && icustom_120 < icustom_136 &&
         (!(icustom_144 < icustom_152 && icustom_144 < icustom_160)) && ima_72 < ima_80)) {
         li_172 = TRUE;
         if (oppositeclose) f0_7();
      }
   }
   if (mm) lots = f0_9();
   if (!f0_17() && li_44 == TRUE && li_40 == TRUE && li_28 == TRUE || li_32 == TRUE || li_36 == TRUE) {
      if ((li_168 && reverseontrend) || (iclose_48 < ima_56 && li_172 == FALSE && tradetrendsonly == FALSE)) {
         if (!(g_order_open_price_980 - Ask >= pipstep * gd_1020 || Ask - g_order_open_price_972 >= pipstep * gd_1020)) return (0);
         f0_25();
         return (0);
      }
      if ((li_172 && reverseontrend) || (iclose_48 > ima_64 && li_168 == FALSE && tradetrendsonly == FALSE)) {
         if (!(Bid - g_order_open_price_996 >= pipstep * gd_1020 || g_order_open_price_1004 - Bid >= pipstep * gd_1020)) return (0);
         f0_5();
         return (0);
      }
   }
   return (0);
}

int f0_22(int a_cmd_0) {
   int count_4 = 0;
   if (OrdersTotal() > 0) {
      for (g_pos_948 = OrdersTotal(); g_pos_948 >= 0; g_pos_948--) {
         OrderSelect(g_pos_948, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderType() == a_cmd_0 && OrderMagicNumber() == magic) count_4++;
      }
      return (count_4);
   }
   return (0);
}

double f0_9() {
   double lots_0;
   if (mm == TRUE) lots_0 = NormalizeDouble(AccountFreeMargin() / (100.0 * (NormalizeDouble(MarketInfo(Symbol(), MODE_MARGINREQUIRED), 4) + 5.0) / risk) - 0.05, lotdigits);
   else lots_0 = lots;
   return (lots_0);
}

bool f0_17() {
   for (int pos_0 = maxorders; pos_0 < OrdersTotal(); pos_0++) {
      if (OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES))
         if (OrderSymbol() == Symbol()) return (TRUE);
   }
   return (FALSE);
}

void f0_15(int ai_0) {
   for (int pos_4 = maxorders; pos_4 < OrdersTotal(); pos_4++) {
      if (OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
            if (OrderType() == OP_BUY) {
               if (Bid - OrderOpenPrice() > ai_0 * gd_1020)
                  if (OrderStopLoss() < Bid - ai_0 * gd_1020) f0_0(Bid - ai_0 * gd_1020);
            }
         }
      }
   }
}

void f0_4(int ai_0) {
   for (int pos_4 = maxorders; pos_4 < OrdersTotal(); pos_4++) {
      if (OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
            if (OrderType() == OP_SELL) {
               if (OrderOpenPrice() - Ask > ai_0 * gd_1020)
                  if (OrderStopLoss() > Ask + ai_0 * gd_1020 || OrderStopLoss() == 0.0) f0_0(Ask + ai_0 * gd_1020);
            }
         }
      }
   }
}

void f0_0(double a_price_0) {
   bool bool_8 = OrderModify(OrderTicket(), OrderOpenPrice(), a_price_0, OrderTakeProfit(), 0, CLR_NONE);
}

void f0_25() {
   double price_8;
   double price_16;
   double lots_0 = f0_19();
   if (lstoploss > 0.0 && hidesl == FALSE) price_8 = f0_21();
   else price_8 = 0;
   if (ltakeprofit > 0.0 && hidetp == FALSE) price_16 = f0_26();
   else price_16 = 0;
   string comment_24 = f0_12();
   if (maxtradesperpair == FALSE || (maxtradesperpair && f0_22(OP_BUY) < NormalizeDouble(maxorders * maxtradespercent / 100.0, 0))) {
      if (isbrokerecn == FALSE) OrderSend(Symbol(), OP_BUY, lots_0, Ask, slippage * gd_1028, price_8, price_16, comment_24, magic, 0, g_color_920);
      if (isbrokerecn) OrderSend(Symbol(), OP_BUY, lots_0, Ask, slippage * gd_1028, 0, 0, comment_24, magic, 0, g_color_920);
   }
   if (isbrokerecn) {
      f0_24(lstoploss);
      f0_2(ltakeprofit);
   }
}

void f0_5() {
   double price_8;
   double price_16;
   double lots_0 = f0_19();
   if (sstoploss > 0.0 && hidesl == FALSE) price_8 = f0_23();
   else price_8 = 0;
   if (stakeprofit > 0.0 && hidetp == FALSE) price_16 = f0_13();
   else price_16 = 0;
   string comment_24 = f0_12();
   if (maxtradesperpair == FALSE || (maxtradesperpair && f0_22(OP_SELL) < NormalizeDouble(maxorders * maxtradespercent / 100.0, 0))) {
      if (isbrokerecn == FALSE) OrderSend(Symbol(), OP_SELL, lots_0, Bid, slippage * gd_1028, price_8, price_16, comment_24, magic, 0, g_color_928);
      if (isbrokerecn) OrderSend(Symbol(), OP_SELL, lots_0, Bid, slippage * gd_1028, 0, 0, comment_24, magic, 0, g_color_928);
   }
   if (isbrokerecn) {
      f0_8(sstoploss);
      f0_18(stakeprofit);
   }
}

void f0_1(int a_cmd_0) {
   if (OrdersTotal() > 0) {
      for (g_pos_948 = OrdersTotal(); g_pos_948 >= 0; g_pos_948--) {
         OrderSelect(g_pos_948, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == a_cmd_0) OrderDelete(OrderTicket());
      }
   }
}

string f0_12() {
   return (gs_76);
}

double f0_19() {
   return (lots);
}

double f0_21() {
   return (Ask - lstoploss * gd_1020);
}

double f0_23() {
   return (Bid + sstoploss * gd_1020);
}

double f0_26() {
   return (Ask + ltakeprofit * gd_1020);
}

double f0_13() {
   return (Bid - stakeprofit * gd_1020);
}

void f0_16(double ad_0, double ad_8) {
   double ld_16 = ad_0 * (AccountBalance() / 100.0);
   double ld_24 = ad_8 * (AccountBalance() / 100.0);
   gi_960 = AccountEquity() - AccountBalance();
   if (gi_960 >= ld_16 || gi_960 <= (-1.0 * ld_24)) {
      f0_7();
      f0_11();
      f0_1(OP_BUYSTOP);
      f0_1(OP_SELLSTOP);
      f0_1(OP_BUYLIMIT);
      f0_1(OP_SELLLIMIT);
      return;
   }
}

void f0_6() {
   if (OrdersTotal() > 0) {
      for (g_pos_948 = OrdersTotal(); g_pos_948 >= 0; g_pos_948--) {
         OrderSelect(g_pos_948, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_BUY && (hidesl && lstoploss > 0.0 && OrderProfit() <= (-1.0 * lstoploss) * OrderLots() - MarketInfo(Symbol(),
            MODE_SPREAD) * OrderLots()) || (hidetp && ltakeprofit > 0.0 && OrderProfit() >= ltakeprofit * OrderLots())) OrderClose(OrderTicket(), OrderLots(), Bid, slippage * gd_1028);
      }
   }
}

void f0_3() {
   if (OrdersTotal() > 0) {
      for (g_pos_948 = OrdersTotal(); g_pos_948 >= 0; g_pos_948--) {
         OrderSelect(g_pos_948, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_SELL && (hidesl && sstoploss > 0.0 && OrderProfit() <= (-1.0 * sstoploss) * OrderLots() - MarketInfo(Symbol(),
            MODE_SPREAD) * OrderLots()) || (hidetp && stakeprofit > 0.0 && OrderProfit() >= stakeprofit * OrderLots())) OrderClose(OrderTicket(), OrderLots(), Ask, slippage * gd_1028);
      }
   }
}

void f0_7() {
   g_order_total_944 = OrdersTotal();
   if (g_order_total_944 > 0) {
      for (g_pos_948 = 0; g_pos_948 < g_order_total_944; g_pos_948++) {
         OrderSelect(g_pos_948, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slippage * gd_1028);
      }
   }
}

void f0_11() {
   g_order_total_944 = OrdersTotal();
   if (g_order_total_944 > 0) {
      for (g_pos_948 = 0; g_pos_948 < g_order_total_944; g_pos_948++) {
         OrderSelect(g_pos_948, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slippage * gd_1028);
      }
   }
}

void f0_14() {
   g_order_total_944 = OrdersTotal();
   if (g_order_total_944 > 0) {
      for (g_pos_948 = 0; g_pos_948 < g_order_total_944; g_pos_948++) {
         OrderSelect(g_pos_948, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_BUY && OrderProfit() <= (-1.0 * minlosses)) OrderClose(OrderTicket(), OrderLots(), Bid, slippage * gd_1028);
      }
   }
}

void f0_20() {
   g_order_total_944 = OrdersTotal();
   if (g_order_total_944 > 0) {
      for (g_pos_948 = 0; g_pos_948 < g_order_total_944; g_pos_948++) {
         OrderSelect(g_pos_948, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_SELL && OrderProfit() <= (-1.0 * minlosses)) OrderClose(OrderTicket(), OrderLots(), Ask, slippage * gd_1028);
      }
   }
}

void f0_10() {
   g_order_total_944 = OrdersTotal();
   if (g_order_total_944 > 0) {
      for (g_pos_948 = 0; g_pos_948 < g_order_total_944; g_pos_948++) {
         OrderSelect(g_pos_948, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_BUY && TimeCurrent() - OrderOpenTime() > 60.0 * timeminutes) OrderClose(OrderTicket(), OrderLots(), Bid, slippage * gd_1028);
      }
   }
}

void f0_27() {
   g_order_total_944 = OrdersTotal();
   if (g_order_total_944 > 0) {
      for (g_pos_948 = 0; g_pos_948 < g_order_total_944; g_pos_948++) {
         OrderSelect(g_pos_948, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_SELL && TimeCurrent() - OrderOpenTime() > 60.0 * timeminutes) OrderClose(OrderTicket(), OrderLots(), Ask, slippage * gd_1028);
      }
   }
}

void f0_24(int ai_0) {
   RefreshRates();
   double ask_4 = MarketInfo(Symbol(), MODE_ASK);
   double bid_12 = MarketInfo(Symbol(), MODE_BID);
   int order_total_20 = OrdersTotal();
   if (order_total_20 > 0) {
      for (int pos_24 = 0; pos_24 < order_total_20; pos_24++) {
         OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
            if (OrderType() == OP_BUY) {
               if (OrderStopLoss() == 0.0) {
                  OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(ask_4 - ai_0 * gd_1020, g_digits_1036), OrderTakeProfit(), 0, Red);
                  return;
               }
            }
         }
      }
   }
}

void f0_8(int ai_0) {
   RefreshRates();
   double ask_4 = MarketInfo(Symbol(), MODE_ASK);
   double bid_12 = MarketInfo(Symbol(), MODE_BID);
   int order_total_20 = OrdersTotal();
   if (order_total_20 > 0) {
      for (int pos_24 = 0; pos_24 < order_total_20; pos_24++) {
         OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
            if (OrderType() == OP_SELL) {
               if (OrderStopLoss() == 0.0) {
                  OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(bid_12 + ai_0 * gd_1020, g_digits_1036), OrderTakeProfit(), 0, Red);
                  return;
               }
            }
         }
      }
   }
}

void f0_2(int ai_0) {
   RefreshRates();
   double ask_4 = MarketInfo(Symbol(), MODE_ASK);
   double bid_12 = MarketInfo(Symbol(), MODE_BID);
   int order_total_20 = OrdersTotal();
   if (order_total_20 > 0) {
      for (int pos_24 = 0; pos_24 < order_total_20; pos_24++) {
         OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
            if (OrderType() == OP_BUY) {
               if (OrderTakeProfit() == 0.0) {
                  OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormalizeDouble(ask_4 + ai_0 * gd_1020, g_digits_1036), 0, Red);
                  return;
               }
            }
         }
      }
   }
}

void f0_18(int ai_0) {
   RefreshRates();
   double ask_4 = MarketInfo(Symbol(), MODE_ASK);
   double bid_12 = MarketInfo(Symbol(), MODE_BID);
   int order_total_20 = OrdersTotal();
   if (order_total_20 > 0) {
      for (int pos_24 = 0; pos_24 < order_total_20; pos_24++) {
         OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
            if (OrderType() == OP_SELL) {
               if (OrderTakeProfit() == 0.0) {
                  OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormalizeDouble(bid_12 - ai_0 * gd_1020, g_digits_1036), 0, Red);
                  return;
               }
            }
         }
      }
   }
}


//+----------------------------------------------------------------------------+
//|  Параметры:                                                                |
//|    hb - часы времени начала торговли                                       |
//|    mb - минуты времени начала торговли                                     |
//|    he - часы времени окончания торговли                                    |
//|    me - минуты времени окончания торговли                                  |
//+----------------------------------------------------------------------------+
bool isTradeTimeInt(int hb=0, int mb=0, int he=0, int me=0) {
  datetime db, de;           // Время начала и окончания работы
  int      hc;               // Часы текущего времени торгового сервера

  db=StrToTime(TimeToStr(TimeCurrent(), TIME_DATE)+" "+hb+":"+mb);
  de=StrToTime(TimeToStr(TimeCurrent(), TIME_DATE)+" "+he+":"+me);
  hc=TimeHour(TimeCurrent());
 
  if (db>=de) {
    if (hc>=he) de+=24*60*60; else db-=24*60*60;
  }

  if (TimeCurrent()>=db && TimeCurrent()<=de) return(True);
  else return(False);
} 

//+------------------------------------------------------------------+
//| Function..: OrderError                                           |
//+------------------------------------------------------------------+
string OrderError() {
  int iError=GetLastError();
  return(StringConcatenate("Order:",OrderTicket()," GetLastError()=",iError," ",ErrorDescription(iError)));
}
//+------------------------------------------------------------------+
//| Function..: GetMarketInfo                                        |
//+------------------------------------------------------------------+
bool GetMarketInfo() {
  RefreshRates();
  Price[0]=MarketInfo(OrderSymbol(),MODE_ASK);
  Price[1]=MarketInfo(OrderSymbol(),MODE_BID);
  double dPoint=MarketInfo(OrderSymbol(),MODE_POINT);
  if(dPoint==0) return(false);
  giSlippage=(Price[0]-Price[1])/dPoint;
  return(Price[0]>0.0 && Price[1]>0.0);
}
//+------------------------------------------------------------------+