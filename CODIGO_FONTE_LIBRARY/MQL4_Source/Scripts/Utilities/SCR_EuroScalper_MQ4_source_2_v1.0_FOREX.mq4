//+------------------------------------------------------------------+
//|                                                      
//|                                      Copyright 2023, lengockhanhhai|
//|                                       lengockhanhhai@gmail.com|
//+------------------------------------------------------------------+
#property copyright "2023.";
#property link "lengockhanhhai@gmail.com"
#property version "1.10";
#property strict

extern string Minimal_Deposit = "$200";
extern string Time_Frame = "Time Frame M1";
extern string Pairs = "EurUsd";
extern bool Use_Daily_Target = true;
extern double Daily_Target = 100;
extern bool Hidden_TP = true;
extern double Hiden_TP = 500;
extern double Lot = 0.01;
extern double LotMultiplikator = 1.21;
extern double TakeProfit = 34;
extern double Step = 21;
extern double Averaging = 1;
extern int MaxTrades = 31;
extern bool UseEquityStop;
extern double TotalEquityRisk = 20;
extern int Open_Hour;
extern int Close_Hour = 23;
extern bool TradeOnThursday = true;
extern int Thursday_Hour = 12;
extern bool TradeOnFriday = true;
extern int Friday_Hour = 20;
extern bool Filter_Sideway = true;
extern bool Filter_News = true;
extern bool invisible_mode = true;
extern double OpenRangePips = 1;
extern double MaxDailyRange = 20000;

string I_s_0;
int I_i_0;
double I_d_0;
double I_d_1;
int I_i_1;
double G_d_2;
int G_i_2;
int G_i_3;
double G_d_3;
int G_i_4;
int G_i_5;
int G_i_6;
int G_i_7;
int G_i_8;
int G_i_9;
int G_i_10;
int G_i_11;
int G_i_12;
int G_i_13;
int G_i_14;
int G_i_15;
double G_d_4;
int G_i_16;
int G_i_17;
int G_i_18;
int G_i_19;
int G_i_20;
double G_d_5;
int G_i_21;
int G_i_22;
int G_i_23;
double G_d_6;
int G_i_24;
int G_i_25;
int G_i_26;
double G_d_7;
int G_i_27;
int G_i_28;
int G_i_29;
double G_d_8;
int G_i_30;
int G_i_31;
int G_i_32;
double G_d_9;
double G_d_10;
int G_i_33;
int G_i_34;
double G_d_11;
int G_i_35;
int G_i_36;
int G_i_37;
double G_d_12;
double G_d_13;
int G_i_38;
int G_i_39;
double G_d_14;
int G_i_40;
int G_i_41;
int G_i_42;
double G_d_15;
int G_i_43;
int G_i_44;
double G_d_16;
int G_i_45;
int G_i_46;
bool G_b_0;
double G_d_17;
double G_d_18;
int G_i_47;
int G_i_48;
double G_d_19;
int G_i_49;
int G_i_50;
int G_i_51;
double G_d_20;
double G_d_21;
int G_i_52;
int G_i_53;
double G_d_22;
int G_i_54;
int G_i_55;
int G_i_56;
bool G_b_1;
double G_d_23;
double G_d_24;
int G_i_57;
int G_i_58;
double G_d_25;
int G_i_59;
int G_i_60;
int G_i_61;
double G_d_26;
double G_d_27;
int G_i_62;
int G_i_63;
double G_d_28;
int G_i_64;
int G_i_65;
int G_i_66;
int G_i_67;
int G_i_68;
bool I_b_2;
bool G_b_3;
double G_d_29;
double I_d_30;
double G_d_31;
double I_d_32;
bool G_b_4;
string I_s_1;
bool I_b_5;
double G_d_33;
long G_l_1;
long I_l_2;
int G_i_70;
bool I_b_7;
int I_i_71;
double I_d_34;
int G_i_73;
int G_i_75;
bool G_b_9;
double I_d_43;
bool I_b_10;
double I_d_44;
int I_i_76;
int I_i_77;
double I_d_45;
double I_d_46;
double I_d_47;
bool I_b_11;
int I_i_78;
int I_i_79;
bool I_b_12;
double I_d_48;
double I_d_49;
double I_d_50;
bool I_b_13;
long G_l_3;
long G_l_4;
int I_i_80;
int G_i_81;
int I_i_84;
double G_d_55;
double G_d_56;
int G_i_85;
double I_d_57;
double I_d_58;
int G_i_87;
bool I_b_16;
int I_i_88;
bool I_b_17;
bool I_b_18;
bool I_b_19;
double I_d_63;
double I_d_64;
bool I_b_20;
double G_d_65;
bool I_b_22;
double I_d_66;
int G_i_89;
bool I_b_23;
double I_d_67;
double I_d_69;
bool I_b_24;
int I_i_90;
string I_s_2;
int G_i_91;
int I_i_92;
double G_d_70;
int G_i_93;
int G_i_97;
double I_d_74;
double I_d_75;
int I_i_98;
int G_i_99;
long G_l_5;
double I_d_76;
double G_d_77;
int G_i_100;
double G_d_78;
double I_d_79;
double I_d_80;
double I_d_81;
double I_d_82;
double I_d_83;
double I_d_84;
int G_i_102;
long G_l_6;
long G_l_7;
int G_i_105;
int G_i_106;
long G_l_8;
long G_l_9;
int G_i_110;
int G_i_111;
int G_i_112;
long G_l_10;
long G_l_11;
int G_i_115;
long G_l_12;
long G_l_13;
int G_i_119;
long G_l_14;
long G_l_15;
int G_i_124;
long G_l_16;
long G_l_17;
double G_d_104;
double I_d_105;
string I_s_3;
int I_i_129;
string I_s_4;
string I_s_5;
string I_s_6;
string I_s_7;
int I_i_130;
int I_i_131;
int I_i_132;
int I_i_133;
int I_i_134;
int I_i_135;
int I_i_136;
int I_i_137;
bool I_b_43;
string I_s_8;
string I_s_9;
double G_d_106;
double G_d_108;
long G_l_20;
long G_l_21;
long G_l_22;
long G_l_23;
double G_d_109;
double G_d_110;
double G_d_111;
double G_d_112;
double G_d_113;
double G_d_114;
double G_d_115;
double G_d_116;
double G_d_117;
double G_d_118;
double G_d_119;
double G_d_120;
int G_i_139;
double G_d_121;
double G_d_122;
double G_d_123;
double G_d_124;
bool G_b_44;
double G_d_125;
double G_d_126;
bool G_b_45;
int G_i_143;
bool G_b_46;
bool G_b_47;
double G_d_127;
double G_d_128;
int G_i_146;
bool G_b_48;
double returned_double;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init() {
   I_s_2 = "Euro Scalper";
   I_d_67 = 2;
   I_s_3 = "Euro Scalper";
   I_i_129 = 1;
   I_s_4 = " MARTIN 1 - on. 2 - off.";
   I_i_98 = 1;
   I_b_24 = true;
   I_d_45 = 0;
   I_d_34 = 5;
   I_s_5 = "true = Fixed Lot, false = Account Balance";
   I_b_10 = true;
   I_d_105 = 30;
   I_d_44 = 0;
   I_d_30 = 0;
   I_i_77 = 1;
   I_d_46 = 0;
   I_d_82 = 0;
   I_d_50 = 10;
   I_d_49 = 10;
   I_d_47 = 0;
   I_s_6 = "汤X Number of trades 29 max 27 2x";
   I_s_7 = "Stop Loss";
   I_b_23 = false;
   I_b_12 = false;
   I_b_13 = false;
   I_d_76 = 48;
   I_b_11 = false;
   I_i_79 = 2;
   I_i_78 = 16;
   I_i_0 = 1111111;
   I_i_71 = 0;
   I_b_20 = true;
   I_d_43 = 0;
   I_d_80 = 0;
   I_d_66 = 0;
   I_d_81 = 0;
   I_d_84 = 0;
   I_d_48 = 0;
   I_d_74 = 0;
   I_d_75 = 0;
   I_d_63 = 0;
   I_d_64 = 0;
   I_d_1 = 0;
   I_b_17 = false;
   I_i_130 = 0;
   I_i_80 = 0;
   I_i_90 = 0;
   I_d_69 = 0;
   I_i_84 = 0;
   I_i_88 = 0;
   I_d_83 = 0;
   I_b_22 = false;
   I_b_18 = false;
   I_b_19 = false;
   I_i_92 = 0;
   I_b_16 = false;
   I_i_131 = 0;
   I_i_132 = 0;
   I_d_57 = 0;
   I_d_58 = 0;
   I_i_133 = 14;
   I_i_134 = 55295;
   I_i_135 = 42495;
   I_i_136 = 8421504;
   I_i_137 = 5197615;
   I_i_76 = -2;
   I_b_7 = false;
   I_b_5 = false;
   I_b_43 = true;
   I_s_9 = "ACCOUNT ANDA BELUM TERDAFTAR! UNTUK DIPAKAI DI LIVE ACCOUNT,HUBUNGI https://www.facebook.com/septi.fx.profit";
   int L_i_15;
   L_i_15 = 0;
   I_s_0 = "Daftar account,358795,3720446,71328690,3710974,64513290,71417917,71328956,71423205,,,";
   if (_Symbol == "AUDCADm" || _Symbol == "AUDCAD") {
      I_i_0 = 101101;
   }
   if (_Symbol == "AUDJPYm" || _Symbol == "AUDJPY") {
      I_i_0 = 101102;
   }
   if (_Symbol == "AUDNZDm" || _Symbol == "AUDNZD") {
      I_i_0 = 101103;
   }
   if (_Symbol == "AUDUSDm" || _Symbol == "AUDUSD") {
      I_i_0 = 101104;
   }
   if (_Symbol == "CHFJPYm" || _Symbol == "CHFJPY") {
      I_i_0 = 101105;
   }
   if (_Symbol == "EURAUDm" || _Symbol == "EURAUD") {
      I_i_0 = 101106;
   }
   if (_Symbol == "EURCADm" || _Symbol == "EURCAD") {
      I_i_0 = 101107;
   }
   if (_Symbol == "EURCHFm" || _Symbol == "EURCHF") {
      I_i_0 = 101108;
   }
   if (_Symbol == "EURGBPm" || _Symbol == "EURGBP") {
      I_i_0 = 101109;
   }
   if (_Symbol == "EURJPYm" || _Symbol == "EURJPY") {
      I_i_0 = 101110;
   }
   if (_Symbol == "EURUSDm" || _Symbol == "EURUSD") {
      I_i_0 = 101111;
   }
   if (_Symbol == "GBPCHFm" || _Symbol == "GBPCHF") {
      I_i_0 = 101112;
   }
   if (_Symbol == "GBPJPYm" || _Symbol == "GBPJPY") {
      I_i_0 = 101113;
   }
   if (_Symbol == "GBPUSDm" || _Symbol == "GBPUSD") {
      I_i_0 = 101114;
   }
   if (_Symbol == "NZDJPYm" || _Symbol == "NZDJPY") {
      I_i_0 = 101115;
   }
   if (_Symbol == "NZDUSDm" || _Symbol == "NZDUSD") {
      I_i_0 = 101116;
   }
   if (_Symbol == "USDCHFm" || _Symbol == "USDCHF") {
      I_i_0 = 101117;
   }
   if (_Symbol == "USDJPYm" || _Symbol == "USDJPY") {
      I_i_0 = 101118;
   }
   if (_Symbol == "USDCADm" || _Symbol == "USDCAD") {
      I_i_0 = 101119;
   }
   if (I_i_0 == 0) {
      I_i_0 = 999999;
   }
   I_d_1 = (MarketInfo(_Symbol, MODE_SPREAD) * _Point);
   L_i_15 = 0;
   return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start() {
   string S_s_20;
   string S_s_21;
   string S_s_22;
   string S_s_23;
   string S_s_14;
   string S_s_15;
   string S_s_16;
   string S_s_17;
   string S_s_18;
   string S_s_19;
   int L_i_15;
   int L_i_11;
   string L_s_0;
   double L_d_0;
   double L_d_1;
   double L_d_2;
   double L_d_3;
   int L_i_3;
   int L_i_4;
   double L_d_4;
   double L_d_5;
   double L_d_6;
   int L_i_5;
   string L_s_1;
   string L_s_2;
   double L_d_7;
   double L_d_8;
   double L_d_9;
   double L_d_10;
   double L_d_11;
   double L_d_12;
   L_i_15 = 0;
   L_i_11 = 0;
   L_d_0 = 0;
   L_d_1 = 0;
   L_d_2 = 0;
   L_d_3 = 0;
   L_i_3 = 0;
   L_i_4 = 0;
   L_d_4 = 0;
   L_d_5 = 0;
   L_d_6 = 0;
   L_i_5 = 0;
   L_d_7 = 0;
   L_d_8 = 0;
   L_d_9 = 0;
   L_d_10 = 0;
   L_d_11 = 0;
   L_d_12 = 0;
   G_d_2 = 0;
   G_i_2 = 0;
   G_i_3 = 0;
   G_d_3 = 0;
   G_i_4 = 0;
   G_i_5 = 0;
   G_i_6 = 0;
   G_i_7 = 0;
   G_i_8 = 0;
   G_i_9 = 0;
   G_i_10 = 0;
   G_i_11 = 0;
   G_i_12 = 0;
   G_i_13 = 0;
   G_i_14 = 0;
   G_i_15 = 0;
   G_d_4 = 0;
   G_i_16 = 0;
   G_i_17 = 0;
   G_i_18 = 0;
   G_i_19 = 0;
   G_i_20 = 0;
   G_d_5 = 0;
   G_i_21 = 0;
   G_i_22 = 0;
   G_i_23 = 0;
   G_d_6 = 0;
   G_i_24 = 0;
   G_i_25 = 0;
   G_i_26 = 0;
   G_d_7 = 0;
   G_i_27 = 0;
   G_i_28 = 0;
   G_i_29 = 0;
   G_d_8 = 0;
   G_i_30 = 0;
   G_i_31 = 0;
   G_i_32 = 0;
   G_d_9 = 0;
   G_d_10 = 0;
   G_i_33 = 0;
   G_i_34 = 0;
   G_d_11 = 0;
   G_i_35 = 0;
   G_i_36 = 0;
   G_i_37 = 0;
   G_d_12 = 0;
   G_d_13 = 0;
   G_i_38 = 0;
   G_i_39 = 0;
   G_d_14 = 0;
   G_i_40 = 0;
   G_i_41 = 0;
   G_i_42 = 0;
   G_d_15 = 0;
   G_i_43 = 0;
   G_i_44 = 0;
   G_d_16 = 0;
   G_i_45 = 0;
   G_i_46 = 0;
   G_b_0 = false;
   G_d_17 = 0;
   G_d_18 = 0;
   G_i_47 = 0;
   G_i_48 = 0;
   G_d_19 = 0;
   G_i_49 = 0;
   G_i_50 = 0;
   G_i_51 = 0;
   G_d_20 = 0;
   G_d_21 = 0;
   G_i_52 = 0;
   G_i_53 = 0;
   G_d_22 = 0;
   G_i_54 = 0;
   G_i_55 = 0;
   G_i_56 = 0;
   G_b_1 = false;
   G_d_23 = 0;
   G_d_24 = 0;
   G_i_57 = 0;
   G_i_58 = 0;
   G_d_25 = 0;
   G_i_59 = 0;
   G_i_60 = 0;
   G_i_61 = 0;
   G_d_26 = 0;
   G_d_27 = 0;
   G_i_62 = 0;
   G_i_63 = 0;
   G_d_28 = 0;
   G_i_64 = 0;
   G_i_65 = 0;
   G_i_66 = 0;
   G_i_67 = 0;
   G_i_68 = 0;
   /*
   if (IsTesting()) {
   Alert("This EA Cannot be Backtest (Maaf ya EA tidak Bisa di Backtest wkwkwkwkw) ");
   L_i_15 = 0;
   return L_i_15;
   }
   */
   L_i_11 = ObjectsTotal(-1) - 1;
   if (L_i_11 >= 0) {
      do {
         L_s_0 = ObjectName(L_i_11);
         if ((ObjectGet(L_s_0, OBJPROP_TIME1) > 0)) {
            G_d_29 = ObjectGet(L_s_0, OBJPROP_TIME1);
            G_d_31 = (I_d_30 * 86400);
            if ((G_d_29 < (Time[0] - G_d_31))) {
               ObjectDelete(L_s_0);
            }
         }
         L_i_11 = L_i_11 - 1;
      } while (L_i_11 >= 0);
   }
   /*
   S_s_20 = (string)AccountNumber();
   S_s_20 = "," + S_s_20;
   S_s_20 = S_s_20 + ",";
   I_s_1 = S_s_20;
   I_i_1 = StringFind(I_s_0, I_s_1, 0);
   if (I_i_1 == -1) {
   I_b_5 = false;
   }
   else {
   I_b_5 = true;
   }

   if (I_i_1 == 238 && IsDemo() == false) {
   Alert("ACCOUNT ANDA BELUM TERDAFTAR!HUBUNGI https://www.facebook.com/septi.fx.profit");
   ObjectCreate(0, "Copyright", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSet("Copyright", OBJPROP_XDISTANCE, 1);
   ObjectSet("Copyright", OBJPROP_YDISTANCE, 20);
   ObjectSetText("Copyright", "For Aktivasi EA => https://www.facebook.com/septi.fx.profit", 20, "Times New Roman", 65535);
   L_i_15 = 0;
   return L_i_15;
   }
   */
   ObjectCreate(0, "j", OBJ_LABEL, 0, 0, 0, 0, 0, 0, 0);
   ObjectSet("j", OBJPROP_CORNER, 4);
   ObjectSet("j", OBJPROP_XDISTANCE, 4);
   ObjectSet("j", OBJPROP_YDISTANCE, 10);
   ObjectSetText("j", "Euro Scalper NDD", 19, "Times New Roman Bold", 65280);
   S_s_20 = "\nLisensi https://www.facebook.com/septi.fx.profit \n================================\nINFORMATION:\n  Nama Broker " + AccountCompany();
   S_s_20 = S_s_20 + "\n";
   S_s_20 = S_s_20 + "================================";
   S_s_20 = S_s_20 + "\n";
   S_s_20 = S_s_20 + "ACC INFORMATION:";
   S_s_20 = S_s_20 + "\n";
   S_s_20 = S_s_20 + "  Nomor Account :";
   S_s_21 = (string)AccountNumber();
   S_s_20 = S_s_20 + S_s_21;
   S_s_20 = S_s_20 + "\n";
   S_s_20 = S_s_20 + "  Account Leverage: ";
   S_s_20 = S_s_20 + DoubleToString(AccountLeverage(), 0);
   S_s_20 = S_s_20 + "\n";
   S_s_20 = S_s_20 + "  Mata Uang : ";
   S_s_20 = S_s_20 + AccountCurrency();
   S_s_20 = S_s_20 + "\n";
   S_s_20 = S_s_20 + "  EQUITY: ";
   S_s_20 = S_s_20 + DoubleToString(AccountEquity(), 2);
   S_s_20 = S_s_20 + "\n";
   S_s_20 = S_s_20 + "  BALANCE:";
   S_s_20 = S_s_20 + DoubleToString(AccountBalance(), 2);
   S_s_20 = S_s_20 + "\n";
   S_s_20 = S_s_20 + "=================";
   S_s_20 = S_s_20 + "\n";
   S_s_20 = S_s_20 + "MARGIN INFORMATION:";
   S_s_20 = S_s_20 + "\n";
   S_s_20 = S_s_20 + "  Free Margin : ";
   S_s_20 = S_s_20 + DoubleToString(AccountFreeMargin(), 2);
   S_s_20 = S_s_20 + "\n";
   S_s_20 = S_s_20 + "  Used Margin : ";
   S_s_20 = S_s_20 + DoubleToString(AccountMargin(), 2);
   Comment("\n ", S_s_20, "\n\n\n :: Spread: ", MarketInfo(_Symbol, MODE_SPREAD), "\n=================");
   L_d_0 = 0;
   L_d_1 = 0;
   L_d_2 = 0;
   L_d_3 = 0;
   L_i_3 = (int)MarketInfo(_Symbol, MODE_STOPLEVEL);
   L_i_4 = (int)MarketInfo(_Symbol, MODE_SPREAD);
   L_d_4 = MarketInfo(_Symbol, MODE_POINT);
   L_d_5 = MarketInfo(_Symbol, MODE_BID);
   L_d_6 = MarketInfo(_Symbol, MODE_ASK);
   L_i_5 = (int)MarketInfo(_Symbol, MODE_DIGITS);
   if (Use_Daily_Target) {
      G_d_2 = 0;
      G_i_2 = HistoryTotal();
      if (G_i_2 >= 0) {
         do {
            if (OrderSelect(G_i_2, 0, 1) && OrderMagicNumber() == I_i_0) {
               G_l_1 = OrderCloseTime();
               if (G_l_1 >= iTime(_Symbol, 1440, 0) && OrderType() <= OP_SELL) {
                  G_d_33 = OrderProfit();
                  G_d_33 = (G_d_33 + OrderCommission());
                  G_d_2 = ((G_d_33 + OrderSwap()) + G_d_2);
               }
            }
            G_i_2 = G_i_2 - 1;
         } while (G_i_2 >= 0);
      }
      if ((G_d_2 >= Daily_Target)) {
         G_i_70 = OrdersTotal() - 1;
         G_i_3 = G_i_70;
         if (G_i_70 >= 0) {
            do {
               I_b_7 = OrderSelect(G_i_3, 0, 0);
               if (OrderSymbol() == _Symbol) {
                  if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71) {
                     if (OrderType() == OP_BUY) {
                        I_b_7 = OrderClose(OrderTicket(), OrderLots(), Bid, (int)I_d_34, 16711680);
                     }
                     if (OrderType() == OP_SELL) {
                        I_b_7 = OrderClose(OrderTicket(), OrderLots(), Ask, (int)I_d_34, 255);
                     }
                  }
                  Sleep(1000);
               }
               G_i_3 = G_i_3 - 1;
            } while (G_i_3 >= 0);
         }
         Print("\nSelamat target harian tercapai");
         L_i_15 = 0;
         return L_i_15;
      }
   }
   if (Hidden_TP) {
      G_d_3 = 0;
      G_i_4 = 0;
      G_i_4 = 0;
      if (OrdersTotal() > 0) {
         do {
            if (!OrderSelect(G_i_4, 0, 0) || (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_0)) {
               G_d_3 = (G_d_3 + OrderProfit());
            }
            G_i_4 = G_i_4 + 1;
         } while (G_i_4 < OrdersTotal());
      }
      if ((Hiden_TP <= G_d_3)) {
         Print("\nMagic Take Profit");
         G_i_73 = OrdersTotal() - 1;
         G_i_5 = G_i_73;
         if (G_i_73 >= 0) {
            do {
               I_b_7 = OrderSelect(G_i_5, 0, 0);
               if (OrderSymbol() == _Symbol) {
                  if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71) {
                     if (OrderType() == OP_BUY) {
                        I_b_7 = OrderClose(OrderTicket(), OrderLots(), Bid, (int)I_d_34, 16711680);
                     }
                     if (OrderType() == OP_SELL) {
                        I_b_7 = OrderClose(OrderTicket(), OrderLots(), Ask, (int)I_d_34, 255);
                     }
                  }
                  Sleep(1000);
               }
               G_i_5 = G_i_5 - 1;
            } while (G_i_5 >= 0);
         }
      }
   }
   if ((I_d_43 == 0)) {
      I_d_43 = AccountBalance();
   }
   if (I_b_10) {
      I_d_44 = Lot;
   } else {
      if ((I_d_44 == -1)) {
         I_d_44 = (((AccountBalance() * I_d_105) / 100) / 10000);
      } else {
         if ((I_i_76 == Averaging)) {
            if (I_i_77 == 1) {
               I_d_44 = (I_d_44 * LotMultiplikator);
            } else {
               I_d_44 = (I_d_44 + Lot);
            }
         }
      }
   }
   if ((I_i_76 >= Averaging)) {
      I_i_76 = -2;
   }
   G_i_7 = 0;
   S_s_21 = _Symbol;
   G_i_8 = OrdersTotal();
   G_i_9 = 0;
   G_i_10 = 0;
   if (G_i_8 > 0) {
      do {
         bool order_select = OrderSelect(G_i_10, 0, 0);
         if (OrderMagicNumber() == I_i_0 && OrderSymbol() == S_s_21 && G_i_7 == OrderType()) {
            G_i_75 = G_i_9 + 1;
            G_i_9 = G_i_75;
         }
         G_i_10 = G_i_10 + 1;
      } while (G_i_10 < G_i_8);
   }
   G_i_6 = G_i_9;
   G_i_11 = 1;
   S_s_22 = _Symbol;
   G_i_12 = OrdersTotal();
   G_i_13 = 0;
   G_i_14 = 0;
   if (G_i_12 > 0) {
      do {
         bool order_select = OrderSelect(G_i_14, 0, 0);
         if (OrderMagicNumber() == I_i_0 && OrderSymbol() == S_s_22 && G_i_11 == OrderType()) {
            G_i_75 = G_i_13 + 1;
            G_i_13 = G_i_75;
         }
         G_i_14 = G_i_14 + 1;
      } while (G_i_14 < G_i_12);
   }
   G_i_75 = G_i_6 + G_i_13;
   if (G_i_75 == 0) {
      I_i_76 = -2;
      G_b_9 = (I_d_43 != AccountBalance());
      if (G_b_9) {
         I_d_43 = 0;
         I_d_44 = 0;
      }
   }
   if (I_i_77 == 1) {
      I_d_45 = LotMultiplikator;
   } else {
      I_d_45 = Lot;
   }
   I_d_46 = TakeProfit;
   I_d_47 = Step;
   I_i_71 = I_i_0;
   L_s_1 = "false";
   L_s_2 = "false";
   G_i_75 = I_b_11;
   if ((G_i_75 == 0)
         || (I_b_11 && I_i_78 > I_i_79 && Hour() >= I_i_79 && Hour() <= I_i_78)
         || (I_i_79 > I_i_78 && Hour() < I_i_78 && Hour() > I_i_79)) {
      L_s_1 = "true";
   }
   if (I_b_11) {
      if ((I_i_78 > I_i_79 && Hour() < I_i_79 && Hour() > I_i_78)
            || (I_i_79 > I_i_78 && Hour() >= I_i_78 && Hour() <= I_i_79)) {
         L_s_2 = "true";
      }
   }
   if (I_b_12) {
      f0_18((int)I_d_50, (int)I_d_49, (int)I_d_48);
   }
   if (I_b_13) {
      G_l_3 = TimeCurrent();
      G_l_4 = I_i_80;
      if (G_l_3 >= G_l_4) {
         G_i_81 = OrdersTotal() - 1;
         G_i_15 = G_i_81;
         if (G_i_81 >= 0) {
            do {
               I_b_7 = OrderSelect(G_i_15, 0, 0);
               if (OrderSymbol() == _Symbol) {
                  if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71) {
                     if (OrderType() == OP_BUY) {
                        I_b_7 = OrderClose(OrderTicket(), OrderLots(), Bid, (int)I_d_34, 16711680);
                     }
                     if (OrderType() == OP_SELL) {
                        I_b_7 = OrderClose(OrderTicket(), OrderLots(), Ask, (int)I_d_34, 255);
                     }
                  }
                  Sleep(1000);
               }
               G_i_15 = G_i_15 - 1;
            } while (G_i_15 >= 0);
         }
         Print("Closed All due to TimeOut");
      }
   }
   G_d_4 = 0;
   I_i_84 = OrdersTotal() - 1;
   if (I_i_84 >= 0) {
      do {
         I_b_7 = OrderSelect(I_i_84, 0, 0);
         if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71) {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
               G_d_4 = (G_d_4 + OrderProfit());
            }
         }
         I_i_84 = I_i_84 - 1;
      } while (I_i_84 >= 0);
   }
   L_d_7 = G_d_4;
   if (UseEquityStop && (G_d_4 < 0)) {
      G_d_55 = fabs(G_d_4);
      G_d_56 = (TotalEquityRisk / 100);
      G_i_16 = 0;
      G_i_85 = OrdersTotal() - 1;
      G_i_17 = G_i_85;
      if (G_i_85 >= 0) {
         do {
            I_b_7 = OrderSelect(G_i_17, 0, 0);
            if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71) {
               if (OrderType() == OP_SELL || OrderType() == OP_BUY) {
                  G_i_16 = G_i_16 + 1;
               }
            }
            G_i_17 = G_i_17 - 1;
         } while (G_i_17 >= 0);
      }
      if (G_i_16 == 0) {
         I_d_57 = AccountEquity();
      }
      if ((I_d_57 < I_d_58)) {
         I_d_57 = I_d_58;
      } else {
         I_d_57 = AccountEquity();
      }
      I_d_58 = AccountEquity();
      if ((G_d_55 > (G_d_56 * I_d_57))) {
         G_i_85 = OrdersTotal() - 1;
         G_i_18 = G_i_85;
         if (G_i_85 >= 0) {
            do {
               I_b_7 = OrderSelect(G_i_18, 0, 0);
               if (OrderSymbol() == _Symbol) {
                  if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71) {
                     if (OrderType() == OP_BUY) {
                        I_b_7 = OrderClose(OrderTicket(), OrderLots(), Bid, (int)I_d_34, 16711680);
                     }
                     if (OrderType() == OP_SELL) {
                        I_b_7 = OrderClose(OrderTicket(), OrderLots(), Ask, (int)I_d_34, 255);
                     }
                  }
                  Sleep(1000);
               }
               G_i_18 = G_i_18 - 1;
            } while (G_i_18 >= 0);
         }
         Print("Closed All due to Stop Out");
         I_b_16 = false;
      }
   }
   G_i_19 = 0;
   G_i_87 = OrdersTotal() - 1;
   G_i_20 = G_i_87;
   if (G_i_87 >= 0) {
      do {
         I_b_7 = OrderSelect(G_i_20, 0, 0);
         if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71) {
            if (OrderType() == OP_SELL || OrderType() == OP_BUY) {
               G_i_19 = G_i_19 + 1;
            }
         }
         G_i_20 = G_i_20 - 1;
      } while (G_i_20 >= 0);
   }
   I_i_88 = G_i_19;
   if (G_i_19 == 0) {
      I_b_17 = false;
   }
   I_i_84 = OrdersTotal() - 1;
   if (I_i_84 >= 0) {
      do {
         I_b_7 = OrderSelect(I_i_84, 0, 0);
         if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71) {
            if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderType() == OP_BUY) {
               I_b_18 = true;
               I_b_19 = false;
               L_d_0 = OrderLots();
               break;
            }
            if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderType() == OP_SELL) {
               I_b_18 = false;
               I_b_19 = true;
               L_d_1 = OrderLots();
               break;
            }
         }
         I_i_84 = I_i_84 - 1;
      } while (I_i_84 >= 0);
   }
   if (I_i_88 > 0 && I_i_88 <= MaxTrades) {
      RefreshRates();
      G_d_5 = 0;
      G_i_21 = 0;
      G_i_22 = 0;
      G_i_87 = OrdersTotal() - 1;
      G_i_23 = G_i_87;
      if (G_i_87 >= 0) {
         do {
            I_b_7 = OrderSelect(G_i_23, 0, 0);
            if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderType() == OP_BUY) {
               G_i_21 = OrderTicket();
               if (G_i_21 > G_i_22) {
                  G_d_5 = OrderOpenPrice();
                  G_i_22 = G_i_21;
               }
            }
            G_i_23 = G_i_23 - 1;
         } while (G_i_23 >= 0);
      }
      I_d_63 = G_d_5;
      G_d_6 = 0;
      G_i_24 = 0;
      G_i_25 = 0;
      G_i_87 = OrdersTotal() - 1;
      G_i_26 = G_i_87;
      if (G_i_87 >= 0) {
         do {
            I_b_7 = OrderSelect(G_i_26, 0, 0);
            if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderType() == OP_SELL) {
               G_i_24 = OrderTicket();
               if (G_i_24 > G_i_25) {
                  G_d_6 = OrderOpenPrice();
                  G_i_25 = G_i_24;
               }
            }
            G_i_26 = G_i_26 - 1;
         } while (G_i_26 >= 0);
      }
      I_d_64 = G_d_6;
      if (I_b_20 == 0) {
         if (I_b_18) {
            G_d_65 = (I_d_63 - Ask);
            if ((G_d_65 >= (I_d_47 * _Point))) {
               I_b_22 = true;
            }
         }
         if (I_b_19 != false) {
            G_d_65 = (Bid - I_d_64);
            if ((G_d_65 >= (I_d_47 * _Point))) {
               I_b_22 = true;
            }
         }
      } else {
         if (I_b_20 == true && Volume[0] < 5) {
            if (I_b_18) {
               G_d_104 = (I_d_63 - Ask);
               if ((G_d_104 >= (I_d_47 * _Point))) {
                  I_b_22 = true;
               }
            }
            if (I_b_19) {
               G_d_104 = (Bid - I_d_64);
               if ((G_d_104 >= (I_d_47 * _Point))) {
                  I_b_22 = true;
               }
            }
         }
      }
   }
   if (I_i_88 < 1) {
      I_b_19 = false;
      I_b_18 = false;
      if (I_b_20 == 0) {
         I_b_22 = true;
      } else {
         if (I_b_20 == true && Volume[0] < 2) {
            I_b_22 = true;
         }
      }
      I_d_66 = AccountEquity();
      I_d_66 = AccountEquity();
   }
   if (I_b_22) {
      G_d_7 = 0;
      G_i_27 = 0;
      G_i_28 = 0;
      G_i_89 = OrdersTotal() - 1;
      G_i_29 = G_i_89;
      if (G_i_89 >= 0) {
         do {
            I_b_7 = OrderSelect(G_i_29, 0, 0);
            if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderType() == OP_BUY) {
               G_i_27 = OrderTicket();
               if (G_i_27 > G_i_28) {
                  G_d_7 = OrderOpenPrice();
                  G_i_28 = G_i_27;
               }
            }
            G_i_29 = G_i_29 - 1;
         } while (G_i_29 >= 0);
      }
      I_d_63 = G_d_7;
      G_d_8 = 0;
      G_i_30 = 0;
      G_i_31 = 0;
      G_i_89 = OrdersTotal() - 1;
      G_i_32 = G_i_89;
      if (G_i_89 >= 0) {
         do {
            I_b_7 = OrderSelect(G_i_32, 0, 0);
            if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderType() == OP_SELL) {
               G_i_30 = OrderTicket();
               if (G_i_30 > G_i_31) {
                  G_d_8 = OrderOpenPrice();
                  G_i_31 = G_i_30;
               }
            }
            G_i_32 = G_i_32 - 1;
         } while (G_i_32 >= 0);
      }
      I_d_64 = G_d_8;
      if (I_b_19 != false) {
         if (I_b_23 || L_s_2 == "true") {
            f0_1(false, true);
            if (I_i_76 == -2) {
               if (I_i_77 == 1) {
                  I_d_69 = NormalizeDouble((I_d_45 * L_d_1), (int)I_d_67);
               } else {
                  I_d_69 = NormalizeDouble((Lot + L_d_1), (int)I_d_67);
               }
            }
         } else {
            if (I_i_76 == -2) {
               G_d_10 = 0;
               G_i_33 = 0;
               I_i_1 = I_i_98;
               if (I_i_1 == 0) {
                  G_d_10 = I_d_44;
               }
               if (I_i_1 == 1) {
                  if (I_i_77 == 1) {
                     returned_double = MathPow(I_d_45, I_i_90);
                     G_d_10 = NormalizeDouble((I_d_44 * returned_double), (int)I_d_67);
                  } else {
                     if (I_i_76 == -2) {
                        G_d_10 = NormalizeDouble(I_d_44, (int)I_d_67);
                     }
                  }
               }
               if (I_i_1 == 2) {
                  G_i_33 = 0;
                  G_d_10 = I_d_44;
                  G_i_119 = HistoryTotal() - 1;
                  G_i_34 = G_i_119;
                  if (G_i_119 >= 0) {
                     do {
                        if (!OrderSelect(G_i_34, 0, 1)) {
                           G_d_9 = -3;
                           break;
                        }
                        if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71) {
                           G_l_14 = OrderCloseTime();
                           G_l_15 = G_i_33;
                           if (G_l_15 < G_l_14) {
                              G_i_33 = (int)OrderCloseTime();
                              if ((OrderProfit() < 0)) {
                                 if (I_i_77 == 1) {
                                    G_d_10 = NormalizeDouble((OrderLots() * I_d_45), (int)I_d_67);
                                 } else {
                                    G_d_10 = NormalizeDouble((OrderLots() + Lot), (int)I_d_67);
                                 }
                              } else {
                                 G_d_10 = I_d_44;
                              }
                           }
                        }
                        G_i_34 = G_i_34 - 1;
                     } while (G_i_34 >= 0);
                  }
               }
               G_i_91 = GetLastError();
               if (G_i_91 == 134) {
                  G_d_9 = -2;
               } else {
                  G_d_9 = G_d_10;
               }
               I_d_69 = G_d_9;
            }
         }
         if (I_b_24 && L_s_1 == "true") {
            I_i_90 = I_i_88;
            if ((I_d_69 > 0)) {
               RefreshRates();
               S_s_23 = _Symbol + "-";
               S_s_23 = S_s_23 + I_s_2;
               S_s_23 = S_s_23 + "-";
               S_s_14 = (string)I_i_88;
               S_s_23 = S_s_23 + S_s_14;
               I_i_92 = f0_15(1, I_d_69, Bid, (int)I_d_34, Ask, 0, 0, S_s_23, I_i_71, 0, 11823615);
               if (I_i_92 < 0) {
                  Print("Error: ", GetLastError());
                  L_i_15 = 0;
                  return L_i_15;
               }
               G_d_11 = 0;
               G_i_35 = 0;
               G_i_36 = 0;
               G_i_91 = OrdersTotal() - 1;
               G_i_37 = G_i_91;
               if (G_i_91 >= 0) {
                  do {
                     I_b_7 = OrderSelect(G_i_37, 0, 0);
                     if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderType() == OP_SELL) {
                        G_i_35 = OrderTicket();
                        if (G_i_35 > G_i_36) {
                           G_d_11 = OrderOpenPrice();
                           G_i_36 = G_i_35;
                        }
                     }
                     G_i_37 = G_i_37 - 1;
                  } while (G_i_37 >= 0);
               }
               I_d_64 = G_d_11;
               I_b_22 = false;
               I_b_16 = true;
            }
         }
      } else {
         if (I_b_18) {
            if (I_b_23 || L_s_2 == "true") {
               f0_1(true, false);
               if (I_i_76 == -2) {
                  if (I_i_77 == 1) {
                     I_d_69 = NormalizeDouble((I_d_45 * L_d_0), (int)I_d_67);
                  } else {
                     I_d_69 = NormalizeDouble((Lot + L_d_0), (int)I_d_67);
                  }
               }
            } else {
               if (I_i_76 == -2) {
                  G_d_13 = 0;
                  G_i_38 = 0;
                  I_i_1 = I_i_98;
                  if (I_i_1 == 0) {
                     G_d_13 = I_d_44;
                  }
                  if (I_i_1 == 1) {
                     if (I_i_77 == 1) {
                        returned_double = MathPow(I_d_45, I_i_90);
                        G_d_13 = NormalizeDouble((I_d_44 * returned_double), (int)I_d_67);
                     } else {
                        if (I_i_76 == -2) {
                           G_d_13 = NormalizeDouble(I_d_44, (int)I_d_67);
                        }
                     }
                  }
                  if (I_i_1 == 2) {
                     G_i_38 = 0;
                     G_d_13 = I_d_44;
                     G_i_124 = HistoryTotal() - 1;
                     G_i_39 = G_i_124;
                     if (G_i_124 >= 0) {
                        do {
                           if (!OrderSelect(G_i_39, 0, 1)) {
                              G_d_12 = -3;
                              break;
                           }
                           if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71) {
                              G_l_16 = OrderCloseTime();
                              G_l_17 = G_i_38;
                              if (G_l_17 < G_l_16) {
                                 G_i_38 = (int)OrderCloseTime();
                                 if ((OrderProfit() < 0)) {
                                    if (I_i_77 == 1) {
                                       G_d_13 = NormalizeDouble((OrderLots() * I_d_45), (int)I_d_67);
                                    } else {
                                       G_d_13 = NormalizeDouble((OrderLots() + Lot), (int)I_d_67);
                                    }
                                 } else {
                                    G_d_13 = I_d_44;
                                 }
                              }
                           }
                           G_i_39 = G_i_39 - 1;
                        } while (G_i_39 >= 0);
                     }
                  }
                  G_i_93 = GetLastError();
                  if (G_i_93 == 134) {
                     G_d_12 = -2;
                  } else {
                     G_d_12 = G_d_13;
                  }
                  I_d_69 = G_d_12;
               }
            }
            if (I_b_24 && L_s_1 == "true") {
               I_i_90 = I_i_88;
               if ((I_d_69 > 0)) {
                  S_s_14 = _Symbol + "-";
                  S_s_14 = S_s_14 + I_s_2;
                  S_s_14 = S_s_14 + "-";
                  S_s_15 = (string)I_i_88;
                  S_s_14 = S_s_14 + S_s_15;
                  I_i_92 = f0_15(0, I_d_69, Ask, (int)I_d_34, Bid, 0, 0, S_s_14, I_i_71, 0, 65280);
                  if (I_i_92 < 0) {
                     Print("Error: ", GetLastError());
                     L_i_15 = 0;
                     return L_i_15;
                  }
                  G_d_14 = 0;
                  G_i_40 = 0;
                  G_i_41 = 0;
                  G_i_93 = OrdersTotal() - 1;
                  G_i_42 = G_i_93;
                  if (G_i_93 >= 0) {
                     do {
                        I_b_7 = OrderSelect(G_i_42, 0, 0);
                        if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderType() == OP_BUY) {
                           G_i_40 = OrderTicket();
                           if (G_i_40 > G_i_41) {
                              G_d_14 = OrderOpenPrice();
                              G_i_41 = G_i_40;
                           }
                        }
                        G_i_42 = G_i_42 - 1;
                     } while (G_i_42 >= 0);
                  }
                  I_d_63 = G_d_14;
                  I_b_22 = false;
                  I_b_16 = true;
               }
            }
         }
      }
   }
   if ((OpenRangePips > 0) && (MaxDailyRange > 0)) {
      G_d_15 = 0;
      G_i_43 = DayOfYear();
      G_i_44 = 0;
      if (Bars > 0) {
         do {
            if (TimeDayOfYear(iTime(_Symbol, _Period, G_i_44)) == G_i_43) {
               G_d_15 = iOpen(_Symbol, _Period, G_i_44);
            }
            if (TimeDayOfYear(iTime(_Symbol, _Period, G_i_44)) != G_i_43) break;
            G_i_44 = G_i_44 + 1;
         } while (G_i_44 < Bars);
      }
      L_d_8 = NormalizeDouble(((OpenRangePips * _Point) + G_d_15), _Digits);
      G_d_16 = 0;
      G_i_45 = DayOfYear();
      G_i_46 = 0;
      if (Bars > 0) {
         do {
            if (TimeDayOfYear(iTime(_Symbol, _Period, G_i_46)) == G_i_45) {
               G_d_16 = iOpen(_Symbol, _Period, G_i_46);
            }
            if (TimeDayOfYear(iTime(_Symbol, _Period, G_i_46)) != G_i_45) break;
            G_i_46 = G_i_46 + 1;
         } while (G_i_46 < Bars);
      }
      G_d_70 = (OpenRangePips * _Point);
      L_d_9 = NormalizeDouble((G_d_16 - G_d_70), _Digits);
      L_d_10 = NormalizeDouble(((MaxDailyRange * _Point) + L_d_8), _Digits);
      G_d_70 = (MaxDailyRange * _Point);
      L_d_11 = NormalizeDouble((L_d_9 - G_d_70), _Digits);
      if ((Close[0] > L_d_8 && Close[0] < L_d_10) || (Close[0] < L_d_9 && Close[0] > L_d_11)) {
         if (I_b_22 && I_i_88 < 1) {
            G_b_0 = true;
            if (TradeOnThursday == false && DayOfWeek() == 4) {
               G_b_0 = false;
            }
            if (TradeOnThursday && DayOfWeek() == 4 && TimeHour(TimeCurrent()) > Thursday_Hour) {
               G_b_0 = false;
            }
            if (TradeOnFriday == false && DayOfWeek() == 5) {
               G_b_0 = false;
            }
            if (TradeOnFriday && DayOfWeek() == 5 && TimeHour(TimeCurrent()) > Friday_Hour) {
               G_b_0 = false;
            }
            if (Open_Hour == 24) {
               Open_Hour = 0;
            }
            if (Close_Hour == 24) {
               Close_Hour = 0;
            }
            if (Open_Hour < Close_Hour) {
               if (TimeHour(TimeCurrent()) < Open_Hour || TimeHour(TimeCurrent()) >= Close_Hour) {
                  G_b_0 = false;
               }
            }
            if (Open_Hour > Close_Hour && TimeHour(TimeCurrent()) < Open_Hour && TimeHour(TimeCurrent()) >= Close_Hour) {
               G_b_0 = false;
            }
            G_i_97 = G_b_0;
            if (G_i_97 == 1) {
               L_d_2 = iClose(_Symbol, 0, 2);
               returned_double = iClose(_Symbol, 0, 1);
               L_d_3 = returned_double;
               I_d_74 = Bid;
               I_d_75 = Ask;
               if (I_b_19 == false && I_b_18 == false && L_s_1 == "true") {
                  I_i_90 = I_i_88;
                  if ((L_d_2 > returned_double)) {
                     if (I_i_76 == -2) {
                        G_d_18 = 0;
                        G_i_47 = 0;
                        I_i_1 = I_i_98;
                        if (I_i_1 == 0) {
                           G_d_18 = I_d_44;
                        }
                        if (I_i_1 == 1) {
                           if (I_i_77 == 1) {
                              returned_double = MathPow(I_d_45, I_i_90);
                              G_d_18 = NormalizeDouble((I_d_44 * returned_double), (int)I_d_67);
                           } else {
                              if (I_i_76 == -2) {
                                 G_d_18 = NormalizeDouble(I_d_44, (int)I_d_67);
                              }
                           }
                        }
                        if (I_i_1 == 2) {
                           G_i_47 = 0;
                           G_d_18 = I_d_44;
                           G_i_102 = HistoryTotal() - 1;
                           G_i_48 = G_i_102;
                           if (G_i_102 >= 0) {
                              do {
                                 if (!OrderSelect(G_i_48, 0, 1)) {
                                    G_d_17 = -3;
                                    break;
                                 }
                                 if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71) {
                                    G_l_6 = OrderCloseTime();
                                    G_l_7 = G_i_47;
                                    if (G_l_7 < G_l_6) {
                                       G_i_47 = (int)OrderCloseTime();
                                       if ((OrderProfit() < 0)) {
                                          if (I_i_77 == 1) {
                                             G_d_18 = NormalizeDouble((OrderLots() * I_d_45), (int)I_d_67);
                                          } else {
                                             G_d_18 = NormalizeDouble((OrderLots() + Lot), (int)I_d_67);
                                          }
                                       } else {
                                          G_d_18 = I_d_44;
                                       }
                                    }
                                 }
                                 G_i_48 = G_i_48 - 1;
                              } while (G_i_48 >= 0);
                           }
                        }
                        G_i_99 = GetLastError();
                        if (G_i_99 == 134) {
                           G_d_17 = -2;
                        } else {
                           G_d_17 = G_d_18;
                        }
                        I_d_69 = G_d_17;
                     }
                     if ((I_d_69 > 0)) {
                        S_s_15 = _Symbol + "-";
                        S_s_15 = S_s_15 + I_s_2;
                        S_s_15 = S_s_15 + "-";
                        S_s_16 = (string)I_i_90;
                        S_s_15 = S_s_15 + S_s_16;
                        I_i_92 = f0_15(1, I_d_69, I_d_74, (int)I_d_34, I_d_74, 0, 0, S_s_15, I_i_71, 0, 11823615);
                        if (I_i_92 < 0) {
                           Print(I_d_69, "Error: ", GetLastError());
                           L_i_15 = 0;
                           return L_i_15;
                        }
                        G_d_19 = 0;
                        G_i_49 = 0;
                        G_i_50 = 0;
                        G_i_99 = OrdersTotal() - 1;
                        G_i_51 = G_i_99;
                        if (G_i_99 >= 0) {
                           do {
                              I_b_7 = OrderSelect(G_i_51, 0, 0);
                              if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderType() == OP_BUY) {
                                 G_i_49 = OrderTicket();
                                 if (G_i_49 > G_i_50) {
                                    G_d_19 = OrderOpenPrice();
                                    G_i_50 = G_i_49;
                                 }
                              }
                              G_i_51 = G_i_51 - 1;
                           } while (G_i_51 >= 0);
                        }
                        I_d_63 = G_d_19;
                        I_b_16 = true;
                     }
                  } else {
                     if (I_i_76 == -2) {
                        G_d_21 = 0;
                        G_i_52 = 0;
                        I_i_1 = I_i_98;
                        if (I_i_1 == 0) {
                           G_d_21 = I_d_44;
                        }
                        if (I_i_1 == 1) {
                           if (I_i_77 == 1) {
                              returned_double = MathPow(I_d_45, I_i_90);
                              G_d_21 = NormalizeDouble((I_d_44 * returned_double), (int)I_d_67);
                           } else {
                              if (I_i_76 == -2) {
                                 G_d_21 = NormalizeDouble(I_d_44, (int)I_d_67);
                              }
                           }
                        }
                        if (I_i_1 == 2) {
                           G_i_52 = 0;
                           G_d_21 = I_d_44;
                           G_i_106 = HistoryTotal() - 1;
                           G_i_53 = G_i_106;
                           if (G_i_106 >= 0) {
                              do {
                                 if (!OrderSelect(G_i_53, 0, 1)) {
                                    G_d_20 = -3;
                                    break;
                                 }
                                 if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71) {
                                    G_l_8 = OrderCloseTime();
                                    G_l_9 = G_i_52;
                                    if (G_l_9 < G_l_8) {
                                       G_i_52 = (int)OrderCloseTime();
                                       if ((OrderProfit() < 0)) {
                                          if (I_i_77 == 1) {
                                             G_d_21 = NormalizeDouble((OrderLots() * I_d_45), (int)I_d_67);
                                          } else {
                                             G_d_21 = NormalizeDouble((OrderLots() + Lot), (int)I_d_67);
                                          }
                                       } else {
                                          G_d_21 = I_d_44;
                                       }
                                    }
                                 }
                                 G_i_53 = G_i_53 - 1;
                              } while (G_i_53 >= 0);
                           }
                        }
                        G_i_105 = GetLastError();
                        if (G_i_105 == 134) {
                           G_d_20 = -2;
                        } else {
                           G_d_20 = G_d_21;
                        }
                        I_d_69 = G_d_20;
                     }
                     if ((I_d_69 > 0)) {
                        S_s_16 = _Symbol + "-";
                        S_s_16 = S_s_16 + I_s_2;
                        S_s_16 = S_s_16 + "-";
                        S_s_17 = (string)I_i_90;
                        S_s_16 = S_s_16 + S_s_17;
                        I_i_92 = f0_15(0, I_d_69, I_d_75, (int)I_d_34, I_d_75, 0, 0, S_s_16, I_i_71, 0, 65280);
                        if (I_i_92 < 0) {
                           Print(I_d_69, "Error: ", GetLastError());
                           L_i_15 = 0;
                           return L_i_15;
                        }
                        G_d_22 = 0;
                        G_i_54 = 0;
                        G_i_55 = 0;
                        G_i_105 = OrdersTotal() - 1;
                        G_i_56 = G_i_105;
                        if (G_i_105 >= 0) {
                           do {
                              I_b_7 = OrderSelect(G_i_56, 0, 0);
                              if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderType() == OP_SELL) {
                                 G_i_54 = OrderTicket();
                                 if (G_i_54 > G_i_55) {
                                    G_d_22 = OrderOpenPrice();
                                    G_i_55 = G_i_54;
                                 }
                              }
                              G_i_56 = G_i_56 - 1;
                           } while (G_i_56 >= 0);
                        }
                        I_d_64 = G_d_22;
                        I_b_16 = true;
                     }
                  }
               }
            }
         }
         if (I_i_92 > 0) {
            G_l_5 = TimeCurrent();
            G_d_77 = ((I_d_76 * 60) * 60);
            I_i_80 = (int)(G_l_5 + G_d_77);
         }
         I_b_22 = false;
      }
   } else {
      if (I_b_22 && I_i_88 < 1) {
         G_b_1 = true;
         if (TradeOnThursday == false && DayOfWeek() == 4) {
            G_b_1 = false;
         }
         if (TradeOnThursday && DayOfWeek() == 4 && TimeHour(TimeCurrent()) > Thursday_Hour) {
            G_b_1 = false;
         }
         if (TradeOnFriday == false && DayOfWeek() == 5) {
            G_b_1 = false;
         }
         if (TradeOnFriday && DayOfWeek() == 5 && TimeHour(TimeCurrent()) > Friday_Hour) {
            G_b_1 = false;
         }
         if (Open_Hour == 24) {
            Open_Hour = 0;
         }
         if (Close_Hour == 24) {
            Close_Hour = 0;
         }
         if (Open_Hour < Close_Hour) {
            if (TimeHour(TimeCurrent()) < Open_Hour || TimeHour(TimeCurrent()) >= Close_Hour) {
               G_b_1 = false;
            }
         }
         if (Open_Hour > Close_Hour && TimeHour(TimeCurrent()) < Open_Hour && TimeHour(TimeCurrent()) >= Close_Hour) {
            G_b_1 = false;
         }
         G_i_110 = G_b_1;
         if (G_i_110 == 1) {
            L_d_2 = iClose(_Symbol, 0, 2);
            returned_double = iClose(_Symbol, 0, 1);
            L_d_3 = returned_double;
            I_d_74 = Bid;
            I_d_75 = Ask;
            if (I_b_19 == false && I_b_18 == false && L_s_1 == "true") {
               I_i_90 = I_i_88;
               if ((L_d_2 > returned_double)) {
                  if (I_i_76 == -2) {
                     G_d_24 = 0;
                     G_i_57 = 0;
                     I_i_1 = I_i_98;
                     if (I_i_1 == 0) {
                        G_d_24 = I_d_44;
                     }
                     if (I_i_1 == 1) {
                        if (I_i_77 == 1) {
                           returned_double = MathPow(I_d_45, I_i_90);
                           G_d_24 = NormalizeDouble((I_d_44 * returned_double), (int)I_d_67);
                        } else {
                           if (I_i_76 == -2) {
                              G_d_24 = NormalizeDouble(I_d_44, (int)I_d_67);
                           }
                        }
                     }
                     if (I_i_1 == 2) {
                        G_i_57 = 0;
                        G_d_24 = I_d_44;
                        G_i_112 = HistoryTotal() - 1;
                        G_i_58 = G_i_112;
                        if (G_i_112 >= 0) {
                           do {
                              if (!OrderSelect(G_i_58, 0, 1)) {
                                 G_d_23 = -3;
                                 break;
                              }
                              if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71) {
                                 G_l_10 = OrderCloseTime();
                                 G_l_11 = G_i_57;
                                 if (G_l_11 < G_l_10) {
                                    G_i_57 = (int)OrderCloseTime();
                                    if ((OrderProfit() < 0)) {
                                       if (I_i_77 == 1) {
                                          G_d_24 = NormalizeDouble((OrderLots() * I_d_45), (int)I_d_67);
                                       } else {
                                          G_d_24 = NormalizeDouble((OrderLots() + Lot), (int)I_d_67);
                                       }
                                    } else {
                                       G_d_24 = I_d_44;
                                    }
                                 }
                              }
                              G_i_58 = G_i_58 - 1;
                           } while (G_i_58 >= 0);
                        }
                     }
                     G_i_111 = GetLastError();
                     if (G_i_111 == 134) {
                        G_d_23 = -2;
                     } else {
                        G_d_23 = G_d_24;
                     }
                     I_d_69 = G_d_23;
                  }
                  if ((I_d_69 > 0)) {
                     S_s_17 = _Symbol + "-";
                     S_s_17 = S_s_17 + I_s_2;
                     S_s_17 = S_s_17 + "-";
                     S_s_18 = (string)I_i_90;
                     S_s_17 = S_s_17 + S_s_18;
                     I_i_92 = f0_15(1, I_d_69, I_d_74, (int)I_d_34, I_d_74, 0, 0, S_s_17, I_i_71, 0, 11823615);
                     if (I_i_92 < 0) {
                        Print(I_d_69, "Error: ", GetLastError());
                        L_i_15 = 0;
                        return L_i_15;
                     }
                     G_d_25 = 0;
                     G_i_59 = 0;
                     G_i_60 = 0;
                     G_i_111 = OrdersTotal() - 1;
                     G_i_61 = G_i_111;
                     if (G_i_111 >= 0) {
                        do {
                           I_b_7 = OrderSelect(G_i_61, 0, 0);
                           if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderType() == OP_BUY) {
                              G_i_59 = OrderTicket();
                              if (G_i_59 > G_i_60) {
                                 G_d_25 = OrderOpenPrice();
                                 G_i_60 = G_i_59;
                              }
                           }
                           G_i_61 = G_i_61 - 1;
                        } while (G_i_61 >= 0);
                     }
                     I_d_63 = G_d_25;
                     I_b_16 = true;
                  }
               } else {
                  if (I_i_76 == -2) {
                     G_d_27 = 0;
                     G_i_62 = 0;
                     I_i_1 = I_i_98;
                     if (I_i_1 == 0) {
                        G_d_27 = I_d_44;
                     }
                     if (I_i_1 == 1) {
                        if (I_i_77 == 1) {
                           returned_double = MathPow(I_d_45, I_i_90);
                           G_d_27 = NormalizeDouble((I_d_44 * returned_double), (int)I_d_67);
                        } else {
                           if (I_i_76 == -2) {
                              G_d_27 = NormalizeDouble(I_d_44, (int)I_d_67);
                           }
                        }
                     }
                     if (I_i_1 == 2) {
                        G_i_62 = 0;
                        G_d_27 = I_d_44;
                        G_i_115 = HistoryTotal() - 1;
                        G_i_63 = G_i_115;
                        if (G_i_115 >= 0) {
                           do {
                              if (!OrderSelect(G_i_63, 0, 1)) {
                                 G_d_26 = -3;
                                 break;
                              }
                              if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71) {
                                 G_l_12 = OrderCloseTime();
                                 G_l_13 = G_i_62;
                                 if (G_l_13 < G_l_12) {
                                    G_i_62 = (int)OrderCloseTime();
                                    if ((OrderProfit() < 0)) {
                                       if (I_i_77 == 1) {
                                          G_d_27 = NormalizeDouble((OrderLots() * I_d_45), (int)I_d_67);
                                       } else {
                                          G_d_27 = NormalizeDouble((OrderLots() + Lot), (int)I_d_67);
                                       }
                                    } else {
                                       G_d_27 = I_d_44;
                                    }
                                 }
                              }
                              G_i_63 = G_i_63 - 1;
                           } while (G_i_63 >= 0);
                        }
                     }
                     G_i_100 = GetLastError();
                     if (G_i_100 == 134) {
                        G_d_26 = -2;
                     } else {
                        G_d_26 = G_d_27;
                     }
                     I_d_69 = G_d_26;
                  }
                  if ((I_d_69 > 0)) {
                     S_s_18 = _Symbol + "-";
                     S_s_18 = S_s_18 + I_s_2;
                     S_s_18 = S_s_18 + "-";
                     S_s_19 = (string)I_i_90;
                     S_s_18 = S_s_18 + S_s_19;
                     I_i_92 = f0_15(0, I_d_69, I_d_75, (int)I_d_34, I_d_75, 0, 0, S_s_18, I_i_71, 0, 65280);
                     if (I_i_92 < 0) {
                        Print(I_d_69, "Error: ", GetLastError());
                        L_i_15 = 0;
                        return L_i_15;
                     }
                     G_d_28 = 0;
                     G_i_64 = 0;
                     G_i_65 = 0;
                     G_i_100 = OrdersTotal() - 1;
                     G_i_66 = G_i_100;
                     if (G_i_100 >= 0) {
                        do {
                           I_b_7 = OrderSelect(G_i_66, 0, 0);
                           if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderType() == OP_SELL) {
                              G_i_64 = OrderTicket();
                              if (G_i_64 > G_i_65) {
                                 G_d_28 = OrderOpenPrice();
                                 G_i_65 = G_i_64;
                              }
                           }
                           G_i_66 = G_i_66 - 1;
                        } while (G_i_66 >= 0);
                     }
                     I_d_64 = G_d_28;
                     I_b_16 = true;
                  }
               }
            }
         }
      }
   }
   G_i_67 = 0;
   G_i_100 = OrdersTotal() - 1;
   G_i_68 = G_i_100;
   if (G_i_100 >= 0) {
      do {
         I_b_7 = OrderSelect(G_i_68, 0, 0);
         if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71) {
            if (OrderType() == OP_SELL || OrderType() == OP_BUY) {
               G_i_67 = G_i_67 + 1;
            }
         }
         G_i_68 = G_i_68 - 1;
      } while (G_i_68 >= 0);
   }
   I_i_88 = G_i_67;
   I_d_48 = 0;
   L_d_12 = 0;
   I_i_84 = OrdersTotal() - 1;
   if (I_i_84 >= 0) {
      do {
         I_b_7 = OrderSelect(I_i_84, 0, 0);
         if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71) {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
               G_d_78 = OrderOpenPrice();
               I_d_48 = ((G_d_78 * OrderLots()) + I_d_48);
               L_d_12 = (L_d_12 + OrderLots());
            }
         }
         I_i_84 = I_i_84 - 1;
      } while (I_i_84 >= 0);
   }
   if (I_i_88 > 0) {
      I_d_48 = NormalizeDouble((I_d_48 / L_d_12), _Digits);
   }
   if (I_b_16) {
      I_i_84 = OrdersTotal() - 1;
      if (I_i_84 >= 0) {
         do {
            I_b_7 = OrderSelect(I_i_84, 0, 0);
            if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71) {
               if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderType() == OP_BUY) {
                  I_d_80 = ((I_d_46 * _Point) + I_d_48);
                  I_d_81 = I_d_80;
                  G_d_78 = (I_d_82 * _Point);
                  I_d_83 = (I_d_48 - G_d_78);
                  I_b_17 = true;
               }
               if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71 && OrderType() == OP_SELL) {
                  G_d_78 = (I_d_46 * _Point);
                  I_d_80 = (I_d_48 - G_d_78);
                  I_d_84 = I_d_80;
                  I_d_83 = ((I_d_82 * _Point) + I_d_48);
                  I_b_17 = true;
               }
            }
            I_i_84 = I_i_84 - 1;
         } while (I_i_84 >= 0);
      }
   }
   if (I_b_16 == false) return 0;
   G_i_100 = I_b_17;
   if (G_i_100 != 1) return 0;
   I_i_84 = OrdersTotal() - 1;
   if (I_i_84 < 0) return 0;
   do {
      I_b_7 = OrderSelect(I_i_84, 0, 0);
      if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71) {
         if (OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71) {
            I_b_7 = OrderModify(OrderTicket(), I_d_48, OrderStopLoss(), I_d_80, 0, 65535);
         }
         I_b_16 = false;
      }
      I_i_84 = I_i_84 - 1;
   } while (I_i_84 >= 0);
   L_i_15 = 0;
   return L_i_15;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit() {
   int L_i_15;
   L_i_15 = 0;
   Comment("************");
   L_i_15 = 0;
   return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int f0_1(bool FuncArg_Boolean_00000000, bool FuncArg_Boolean_00000001) {
   string S_s_20;
   string S_s_21;
   string S_s_22;
   string S_s_23;
   int L_i_15;
   int L_i_11;
   int L_i_12;
   L_i_15 = 0;
   L_i_11 = 0;
   L_i_12 = 0;
   G_d_2 = 0;
   G_d_106 = 0;
   L_i_11 = 0;
   L_i_12 = OrdersTotal() - 1;
   if (L_i_12 < 0) return L_i_11;
   do {
      if (OrderSelect(L_i_12, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71) {
         if (OrderType() == OP_BUY && FuncArg_Boolean_00000000) {
            RefreshRates();
            if (!IsTradeContextBusy()) {
               if (!OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Bid, _Digits), 5, 4294967295)) {
                  S_s_20 = (string)OrderTicket();
                  S_s_20 = "Error close BUY " + S_s_20;
                  Print(S_s_20);
                  L_i_11 = -1;
               }
            } else {
               G_l_22 = iTime(NULL, 0, 0);
               G_l_23 = I_i_131;
               if (G_l_23 == G_l_22) {
                  L_i_15 = -2;
                  return L_i_15;
               }
               I_i_131 = (int)iTime(NULL, 0, 0);
               S_s_21 = (string)OrderTicket();
               S_s_21 = "Need close BUY " + S_s_21;
               S_s_21 = S_s_21 + ". Trade Context Busy";
               Print(S_s_21);
               L_i_15 = -2;
               return L_i_15;
            }
         }
         if (OrderType() == OP_SELL && FuncArg_Boolean_00000001) {
            RefreshRates();
            if (!IsTradeContextBusy()) {
               if (!OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(Ask, _Digits), 5, 4294967295)) {
                  S_s_22 = (string)OrderTicket();
                  S_s_22 = "Error close SELL " + S_s_22;
                  Print(S_s_22);
                  L_i_11 = -1;
               }
            } else {
               G_l_20 = iTime(NULL, 0, 0);
               G_l_21 = I_i_132;
               if (G_l_21 == G_l_20) {
                  L_i_15 = -2;
                  return L_i_15;
               }
               I_i_132 = (int)iTime(NULL, 0, 0);
               S_s_23 = (string)OrderTicket();
               S_s_23 = "Need close SELL " + S_s_23;
               S_s_23 = S_s_23 + ". Trade Context Busy";
               Print(S_s_23);
               L_i_15 = -2;
               return L_i_15;
            }
         }
      }
      L_i_12 = L_i_12 - 1;
   } while (L_i_12 >= 0);
   L_i_15 = L_i_11;
   return L_i_15;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int f0_15(int Fa_i_00, double Fa_d_01, double Fa_d_02, int Fa_i_03, double Fa_d_04, double Fa_d_05, int Fa_i_06, string Fa_s_07, int Fa_i_08, int Fa_i_09, int Fa_i_0A) {
   int L_i_15;
   int L_i_11;
   int L_i_12;
   int L_i_13;
   int L_i_14;
   L_i_15 = 0;
   L_i_11 = 0;
   L_i_12 = 0;
   L_i_13 = 0;
   L_i_14 = 0;
   G_d_2 = 0;
   G_d_106 = 0;
   G_i_3 = 0;
   G_d_3 = 0;
   G_d_108 = 0;
   G_i_5 = 0;
   G_d_109 = 0;
   G_d_110 = 0;
   G_i_8 = 0;
   G_d_111 = 0;
   G_d_112 = 0;
   G_i_11 = 0;
   G_d_113 = 0;
   G_d_114 = 0;
   G_i_14 = 0;
   G_d_115 = 0;
   G_d_4 = 0;
   G_i_16 = 0;
   G_d_116 = 0;
   G_d_117 = 0;
   G_i_19 = 0;
   G_d_118 = 0;
   G_d_5 = 0;
   G_i_21 = 0;
   G_d_119 = 0;
   G_d_120 = 0;
   G_i_139 = 0;
   G_d_121 = 0;
   G_d_122 = 0;
   G_i_26 = 0;
   G_d_7 = 0;
   G_d_123 = 0;
   G_i_28 = 0;
   G_d_124 = 0;
   G_d_8 = 0;
   G_i_30 = 0;
   L_i_11 = 0;
   L_i_12 = 0;
   L_i_13 = 0;
   L_i_14 = 100;
   I_i_1 = Fa_i_00;
   if (I_i_1 > 5) return L_i_11;
   if (I_i_1 == 2) {
      L_i_13 = 0;
      if (L_i_14 <= 0) return L_i_11;
      do {
         G_i_31 = Fa_i_0A;
         G_i_5 = Fa_i_06;
         G_d_108 = Fa_d_02;
         if (Fa_i_06 == 0) {
            G_d_3 = 0;
         } else {
            G_d_3 = ((G_i_5 * _Point) + G_d_108);
         }
         G_i_3 = (int)I_d_82;
         G_d_106 = Fa_d_04;
         if (G_i_3 == 0) {
            G_d_2 = 0;
         } else {
            G_d_10 = (G_i_3 * _Point);
            G_d_2 = (G_d_106 - G_d_10);
         }
         L_i_11 = OrderSend(_Symbol, 2, Fa_d_01, Fa_d_02, Fa_i_03, G_d_2, G_d_3, Fa_s_07, Fa_i_08, Fa_i_09, G_i_31);
         if (L_i_11 > 0) {
            I_i_76 = I_i_76 + 1;
         }
         G_i_146 = GetLastError();
         L_i_12 = G_i_146;
         if (G_i_146 == 0) return L_i_11;
         G_b_48 = (G_i_146 == 4);
         if (G_b_48 != true) {
            G_b_48 = (G_i_146 == 137);
         }
         if (G_b_48 != true) {
            G_b_48 = (L_i_12 == 146);
         }
         if (G_b_48 != true) {
            G_b_48 = (L_i_12 == 136);
         }
         if (G_b_48 == false) return L_i_11;
         Sleep(1000);
         L_i_13 = L_i_13 + 1;
      } while (L_i_13 < L_i_14);
      return L_i_11;
   }
   if (I_i_1 == 4) {
      L_i_13 = 0;
      if (L_i_14 <= 0) return L_i_11;
      do {
         G_i_33 = Fa_i_0A;
         G_i_11 = Fa_i_06;
         G_d_112 = Fa_d_02;
         if (Fa_i_06 == 0) {
            G_d_111 = 0;
         } else {
            G_d_111 = ((G_i_11 * _Point) + G_d_112);
         }
         G_i_8 = (int)I_d_82;
         G_d_110 = Fa_d_04;
         if (G_i_8 == 0) {
            G_d_109 = 0;
         } else {
            G_d_128 = (G_i_8 * _Point);
            G_d_109 = (G_d_110 - G_d_128);
         }
         L_i_11 = OrderSend(_Symbol, 4, Fa_d_01, Fa_d_02, Fa_i_03, G_d_109, G_d_111, Fa_s_07, Fa_i_08, Fa_i_09, G_i_33);
         if (L_i_11 > 0) {
            I_i_76 = I_i_76 + 1;
         }
         G_i_35 = GetLastError();
         L_i_12 = G_i_35;
         if (G_i_35 == 0) return L_i_11;
         G_b_45 = (G_i_35 == 4);
         if (G_b_45 != true) {
            G_b_45 = (G_i_35 == 137);
         }
         if (G_b_45 != true) {
            G_b_45 = (L_i_12 == 146);
         }
         if (G_b_45 != true) {
            G_b_45 = (L_i_12 == 136);
         }
         if (G_b_45 == false) return L_i_11;
         Sleep(5000);
         L_i_13 = L_i_13 + 1;
      } while (L_i_13 < L_i_14);
      return L_i_11;
   }
   if (I_i_1 == 0) {
      L_i_13 = 0;
      if (L_i_14 <= 0) return L_i_11;
      do {
         RefreshRates();
         G_i_36 = Fa_i_0A;
         G_i_16 = Fa_i_06;
         G_d_4 = Ask;
         if (Fa_i_06 == 0) {
            G_d_115 = 0;
         } else {
            G_d_115 = ((G_i_16 * _Point) + G_d_4);
         }
         G_i_14 = (int)I_d_82;
         G_d_114 = Bid;
         if (G_i_14 == 0) {
            G_d_113 = 0;
         } else {
            G_d_13 = (G_i_14 * _Point);
            G_d_113 = (G_d_114 - G_d_13);
         }
         L_i_11 = OrderSend(_Symbol, 0, Fa_d_01, Ask, Fa_i_03, G_d_113, G_d_115, Fa_s_07, Fa_i_08, Fa_i_09, G_i_36);
         if (L_i_11 > 0) {
            I_i_76 = I_i_76 + 1;
         }
         G_i_143 = GetLastError();
         L_i_12 = G_i_143;
         if (G_i_143 == 0) return L_i_11;
         G_b_46 = (G_i_143 == 4);
         if (G_b_46 != true) {
            G_b_46 = (G_i_143 == 137);
         }
         if (G_b_46 != true) {
            G_b_46 = (L_i_12 == 146);
         }
         if (G_b_46 != true) {
            G_b_46 = (L_i_12 == 136);
         }
         if (G_b_46 == false) return L_i_11;
         Sleep(5000);
         L_i_13 = L_i_13 + 1;
      } while (L_i_13 < L_i_14);
      return L_i_11;
   }
   if (I_i_1 == 3) {
      L_i_13 = 0;
      if (L_i_14 <= 0) return L_i_11;
      do {
         G_i_38 = Fa_i_0A;
         G_i_21 = Fa_i_06;
         G_d_5 = Fa_d_02;
         if (Fa_i_06 == 0) {
            G_d_118 = 0;
         } else {
            G_d_127 = (G_i_21 * _Point);
            G_d_118 = (G_d_5 - G_d_127);
         }
         G_i_19 =(int) I_d_82;
         G_d_117 = Fa_d_04;
         if (G_i_19 == 0) {
            G_d_116 = 0;
         } else {
            G_d_116 = ((G_i_19 * _Point) + G_d_117);
         }
         L_i_11 = OrderSend(_Symbol, 3, Fa_d_01, Fa_d_02, Fa_i_03, G_d_116, G_d_118, Fa_s_07, Fa_i_08, Fa_i_09, G_i_38);
         if (L_i_11 > 0) {
            I_i_76 = I_i_76 + 1;
         }
         G_i_40 = GetLastError();
         L_i_12 = G_i_40;
         if (G_i_40 == 0) return L_i_11;
         G_b_47 = (G_i_40 == 4);
         if (G_b_47 != true) {
            G_b_47 = (G_i_40 == 137);
         }
         if (G_b_47 != true) {
            G_b_47 = (L_i_12 == 146);
         }
         if (G_b_47 != true) {
            G_b_47 = (L_i_12 == 136);
         }
         if (G_b_47 == false) return L_i_11;
         Sleep(5000);
         L_i_13 = L_i_13 + 1;
      } while (L_i_13 < L_i_14);
      return L_i_11;
   }
   if (I_i_1 == 5) {
      L_i_13 = 0;
      if (L_i_14 <= 0) return L_i_11;
      do {
         G_i_41 = Fa_i_0A;
         G_i_26 = Fa_i_06;
         G_d_122 = Fa_d_02;
         if (Fa_i_06 == 0) {
            G_d_121 = 0;
         } else {
            G_d_126 = (G_i_26 * _Point);
            G_d_121 = (G_d_122 - G_d_126);
         }
         G_i_139 = (int)I_d_82;
         G_d_120 = Fa_d_04;
         if (G_i_139 == 0) {
            G_d_119 = 0;
         } else {
            G_d_119 = ((G_i_139 * _Point) + G_d_120);
         }
         L_i_11 = OrderSend(_Symbol, 5, Fa_d_01, Fa_d_02, Fa_i_03, G_d_119, G_d_121, Fa_s_07, Fa_i_08, Fa_i_09, G_i_41);
         if (L_i_11 > 0) {
            I_i_76 = I_i_76 + 1;
         }
         G_i_43 = GetLastError();
         L_i_12 = G_i_43;
         if (G_i_43 == 0) return L_i_11;
         G_b_44 = (G_i_43 == 4);
         if (G_b_44 != true) {
            G_b_44 = (G_i_43 == 137);
         }
         if (G_b_44 != true) {
            G_b_44 = (L_i_12 == 146);
         }
         if (G_b_44 != true) {
            G_b_44 = (L_i_12 == 136);
         }
         if (G_b_44 == false) return L_i_11;
         Sleep(5000);
         L_i_13 = L_i_13 + 1;
      } while (L_i_13 < L_i_14);
      return L_i_11;
   }
   if (I_i_1 == 1) {
      L_i_13 = 0;
      if (L_i_14 <= 0) return L_i_11;
      do {
         G_i_44 = Fa_i_0A;
         G_i_30 = Fa_i_06;
         G_d_8 = Bid;
         if (Fa_i_06 == 0) {
            G_d_124 = 0;
         } else {
            G_d_125 = (G_i_30 * _Point);
            G_d_124 = (G_d_8 - G_d_125);
         }
         G_i_28 = (int)I_d_82;
         G_d_123 = Ask;
         if (G_i_28 == 0) {
            G_d_7 = 0;
         } else {
            G_d_7 = ((G_i_28 * _Point) + G_d_123);
         }
         L_i_11 = OrderSend(_Symbol, 1, Fa_d_01, Bid, Fa_i_03, G_d_7, G_d_124, Fa_s_07, Fa_i_08, Fa_i_09, G_i_44);
         if (L_i_11 > 0) {
            I_i_76 = I_i_76 + 1;
         }
         G_i_46 = GetLastError();
         L_i_12 = G_i_46;
         if (G_i_46 == 0) return L_i_11;
         G_b_0 = (G_i_46 == 4);
         if (G_b_0 != true) {
            G_b_0 = (G_i_46 == 137);
         }
         if (G_b_0 != true) {
            G_b_0 = (L_i_12 == 146);
         }
         if (G_b_0 != true) {
            G_b_0 = (L_i_12 == 136);
         }
         if (G_b_0 == false) return L_i_11;
         Sleep(5000);
         L_i_13 = L_i_13 + 1;
      } while (L_i_13 < L_i_14);
   }
   L_i_15 = L_i_11;
   return L_i_11;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void f0_18(int Fa_i_00, int Fa_i_01, double Fa_d_02) {
   int L_i_15;
   double L_d_13;
   double L_d_14;
   int L_i_16;
   L_i_15 = 0;
   L_d_13 = 0;
   L_d_14 = 0;
   L_i_16 = 0;
   L_i_15 = 0;
   L_d_13 = 0;
   L_d_14 = 0;
   if (Fa_i_01 == 0) return;
   L_i_16 = OrdersTotal() - 1;
   if (L_i_16 < 0) return;
   do {
      if (OrderSelect(L_i_16, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == I_i_71) {
         if (OrderSymbol() == _Symbol || OrderMagicNumber() == I_i_71) {
            if (OrderType() == OP_BUY) {
               G_d_2 = (Bid - Fa_d_02);
               L_i_15 = (int)NormalizeDouble((G_d_2 / _Point), 0);
               if (L_i_15 < Fa_i_00) continue;
               returned_double = OrderStopLoss();
               L_d_13 = returned_double;
               G_d_2 = (Fa_i_01 * _Point);
               L_d_14 = (Bid - G_d_2);
               if (returned_double == 0 || (returned_double != 0 && L_d_14 > returned_double)) {
                  I_b_7 = OrderModify(OrderTicket(), Fa_d_02, L_d_14, OrderTakeProfit(), 0, 16776960);
               }
            }
            if (OrderType() == OP_SELL) {
               G_d_106 = (Fa_d_02 - Ask);
               L_i_15 = (int)NormalizeDouble((G_d_106 / _Point), 0);
               if (L_i_15 < Fa_i_00) continue;
               returned_double = OrderStopLoss();
               L_d_13 = returned_double;
               L_d_14 = ((Fa_i_01 * _Point) + Ask);
               if (returned_double == 0 || (returned_double != 0 && L_d_14 < returned_double)) {
                  I_b_7 = OrderModify(OrderTicket(), Fa_d_02, L_d_14, OrderTakeProfit(), 0, 255);
               }
            }
         }
         Sleep(1000);
      }
      L_i_16 = L_i_16 - 1;
   } while (L_i_16 >= 0);
}


//+------------------------------------------------------------------+
