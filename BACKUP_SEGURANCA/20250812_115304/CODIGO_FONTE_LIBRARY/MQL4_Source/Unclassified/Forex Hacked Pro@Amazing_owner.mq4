/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website: h TT p : / / W wW.m ET A q U ot ES. NE T
   E-mail : Sup p o RT @me T aq U oTEs. NE t
*/
#property copyright "Forex Vzlomshik Pro"
#property link      "http://www.google.com"

extern string ______General_Settings________ = "------------General Settings------------";
extern bool UseManualLots = FALSE;
extern double Lots = 0.01;
extern double Booster = 1.55;
extern double TakeProfit = 20.0;
extern double PipStarter = 50.0;
extern string ________Misc_Settinngs________ = "--------------Misc Settings--------------";
extern bool TurboMode = TRUE;
extern double TurboDivider = 3.0;
extern bool ContinueTrading = TRUE;
extern bool MM = FALSE;
extern double Divider = 100.0;
extern bool chartDisplay = TRUE;
extern string ____Addtional_Safe_Guards_____ = "----------Addtional Safe Guards----------";
extern bool UseStoplossPct = FALSE;
extern double StoplossPct = 30.0;
extern bool UseTakeProfitPct = FALSE;
extern double TakeProfitPct = 1.0;
extern bool UseTrailingStop = FALSE;
extern double StartTrailing = 15.0;
extern double StopTrailing = 5.0;
int Gi_212 = 2;
extern double Slippage = 7.0;
int Gi_224 = 5;
double Gd_228 = 1.0;
int G_timeframe_236;
double G_lots_240 = 50.0;
extern string ___________System_1____________ = "------------------System 1 Settings-------------------";
extern bool UseStrategy_1 = TRUE;
extern int MagicNumber_1 = 1000;
extern int MaxTrades_1 = 15;
extern bool UseDollarTakeProfit_s1 = FALSE;
extern double DollarTakeProfit_s1 = 15.0;
int Gi_280;
int G_timeframe_284 = PERIOD_H1;
double G_pips_288 = 500.0;
bool Gi_296 = FALSE;
double Gd_300 = 72.0;
double Gd_308;
double Gd_316;
double G_price_324;
double Gd_332;
double Gd_unused_340;
double Gd_unused_348;
double G_price_356;
double Gd_364;
double Gd_372;
double Gd_380;
double Gd_388;
double Gd_396;
bool Gi_404;
extern string system1_comment = "Forex Vzlomshik Pro System 1";
int Gi_416 = 0;
int Gi_420;
int Gi_424 = 0;
double Gd_428;
int G_pos_436 = 0;
int Gi_440;
double Gd_444 = 0.0;
bool Gi_452 = FALSE;
bool Gi_456 = FALSE;
bool Gi_460 = FALSE;
int Gi_464;
bool Gi_468 = FALSE;
double Gd_472;
double Gd_480;
int G_datetime_488 = 1;
double Gd_492;
extern string __________System_2_____________ = "-------------------System 2 Settings-------------------";
extern bool UseStrategy_2 = TRUE;
extern int MagicNumber_2 = 2000;
extern int MaxTrades_2 = 15;
extern bool UseDollarTakeProfit_s2 = FALSE;
extern double DollarTakeProfit_s2 = 15.0;
int Gi_532;
int G_timeframe_536 = PERIOD_M1;
double G_pips_540 = 500.0;
bool Gi_548 = FALSE;
double Gd_552 = 72.0;
double Gd_560;
double Gd_568;
double G_price_576;
double Gd_584;
double Gd_unused_592;
double Gd_unused_600;
double G_price_608;
double Gd_616;
double Gd_624;
double Gd_632;
double Gd_640;
double Gd_648;
bool Gi_656;
extern string system2_comment = "Forex Vzlomshik Pro System 2";
int Gi_668 = 0;
int Gi_672;
int Gi_676 = 0;
double Gd_680;
int G_pos_688 = 0;
int Gi_692;
double Gd_696 = 0.0;
bool Gi_704 = FALSE;
bool Gi_708 = FALSE;
bool Gi_712 = FALSE;
int Gi_716;
bool Gi_720 = FALSE;
double Gd_724;
double Gd_732;
int G_datetime_740 = 1;
double Gd_744;
extern string __________System_3___________ = "-------------------System 3 Settings--------------------";
extern bool UseStrategy_3 = TRUE;
extern int MagicNumber_3 = 3000;
extern int MaxTrades_3 = 15;
extern bool UseDollarTakeProfit_s3 = FALSE;
extern double DollarTakeProfit_s3 = 15.0;
int Gi_784;
bool Gi_788 = FALSE;
double Gd_792 = 72.0;
double G_pips_800 = 500.0;
double Gd_808;
double Gd_816;
double G_price_824;
double Gd_832;
double Gd_unused_840;
double Gd_unused_848;
double G_price_856;
double Gd_864;
double Gd_872;
double Gd_880;
double Gd_888;
double Gd_896;
bool Gi_904;
extern string system3_comment = "Forex Vzlomshik Pro System 3";
int Gi_916 = 0;
int Gi_920;
int Gi_924 = 0;
double Gd_928;
int G_pos_936 = 0;
int Gi_940;
double Gd_944 = 0.0;
bool Gi_952 = FALSE;
bool Gi_956 = FALSE;
bool Gi_960 = FALSE;
int Gi_964;
bool Gi_968 = FALSE;
double Gd_972;
double Gd_980;
double Gd_988;
double G_lotstep_996;
double G_minlot_1004;
int Gi_unused_1020 = 0;
int Gi_unused_1024 = 1;
int Gi_unused_1028 = 250;
string Gs_unused_1032;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   Gd_228 = 1.0;
   if (Digits == 3 || Digits == 5) Gd_228 = 10;
   Gs_unused_1032 = "approved";
   Gd_896 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   Gd_396 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   Gd_648 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
void deinit() {
}

// EA2B2676C28C0DB26D39331A336C6B92
void start() {
   string Ls_0;
   string Ls_8;
   string Ls_16;
   double Ld_24;
   double ihigh_32;
   double ilow_40;
   double iclose_48;
   double iclose_56;
   double Ld_64;
   double Ld_72;
   int Li_80;
   int count_84;
   double Ld_88;
   int Li_96;
   int count_100;
   double Ld_188;
   double Ld_200;
   int Li_208;
   double Ld_212;
   bool bool_220;
   double Ld_224;
   bool bool_232;
   double Ld_236;
   bool bool_244;
   double Ld_248;
   double Ld_256;
   double Ld_264;
   double Ld_272;
   double Ld_284;
   double Ld_296;
   int Li_304;
   double Ld_308;
   bool bool_316;
   double Ld_320;
   bool bool_328;
   double Ld_332;
   bool bool_340;
   double Ld_344;
   double Ld_352;
   double Ld_360;
   double Ld_368;
   double Ld_380;
   int ind_counted_104 = IndicatorCounted();
   G_lotstep_996 = MarketInfo(Symbol(), MODE_LOTSTEP);
   G_minlot_1004 = MarketInfo(Symbol(), MODE_MINLOT);
   if (UseManualLots == FALSE) {
      if (G_lotstep_996 == 0.1 && G_minlot_1004 == 0.1) {
         Lots = 0.1;
         Gi_212 = 1;
      } else {
         if (G_lotstep_996 == 0.01 && G_minlot_1004 == 0.1) {
            Lots = 0.1;
            Gi_212 = 2;
         } else {
            if (G_lotstep_996 == 0.001 && G_minlot_1004 == 0.01) {
               Lots = 0.01;
               Gi_212 = 3;
            }
         }
      }
   }
   if (Lots > G_lots_240) Lots = G_lots_240;
   if (chartDisplay) {
      Ls_0 = Gd_492;
      Ls_0 = Gd_492;
      Ls_8 = Gd_744;
      Ls_8 = Gd_744;
      Ls_16 = Gd_988;
      Ls_16 = Gd_988;
      Ld_24 = Gd_492 + Gd_744 + Gd_988;
      Comment("\n" 
         + "____________Forex Vzlomshik PRO 1.14_______________" 
         + "\n" 
         + "\n" 
         + "\n" 
         + "__________ACCOUNT INFORMATION___________" 
         + "\n" 
         + "\n" 
         + "Authenticated:      YES" 
         + "\n" 
         + "User:                   " + "User" 
         + "\n" 
         + "Broker:                " + AccountCompany() 
         + "\n" 
         + "Acct Leverage:     " + AccountLeverage() 
         + "\n" 
         + "Currency:            " + AccountCurrency() 
         + "\n" 
         + "\n" 
         + "_________________TRADES_____________________" 
         + "\n" 
         + "\n" 
         + "System 1 Open Trades :  " + f0_38() + "   Current Profit $:  " + Ls_0 
         + "\n" 
         + "System 2 Open Trades :  " + f0_23() + "   Current Profit $:  " + Ls_8 
         + "\n" 
         + "System 3 Open Trades :  " + f0_28() + "   Current Profit $:  " + Ls_16 
         + "\n" 
         + "Total Profit         :  " + Ld_24 
         + "\n" 
         + "\n" 
         + "_________________PROFIT_____________________" 
         + "\n" 
         + "\n" 
         + "Total # Of Open Trades :   " + OrdersTotal() 
         + "\n" 
         + "Balance:                   " + AccountBalance() 
         + "\n" 
         + "Equity:                     " + AccountEquity() 
         + "\n" 
         + "\n" 
      + "_____________________________________________");
   }
   if (Gi_224 == 1) G_timeframe_236 = 1;
   if (Gi_224 == 2) G_timeframe_236 = 5;
   if (Gi_224 == 3) G_timeframe_236 = 15;
   if (Gi_224 == 4) G_timeframe_236 = 30;
   if (Gi_224 == 5) G_timeframe_236 = 60;
   if (Gi_224 == 6) G_timeframe_236 = 240;
   if (Gi_224 == 7) G_timeframe_236 = 1440;
   if (Gi_224 == 8) G_timeframe_236 = 10080;
   if (Gi_224 == 9) G_timeframe_236 = 43200;
   if (Gi_224 == 0) G_timeframe_236 = Period();
   double Ld_108 = Booster;
   int Li_116 = Gi_212;
   double Ld_120 = TakeProfit;
   bool bool_128 = UseStoplossPct;
   double Ld_132 = StoplossPct;
   bool bool_140 = UseTakeProfitPct;
   double Ld_144 = TakeProfitPct;
   bool bool_152 = UseTrailingStop;
   double Ld_156 = StartTrailing;
   double Ld_164 = StopTrailing;
   double Ld_172 = Slippage;
   Gi_784 = f0_28();
   if (TurboMode == TRUE) {
      if (Gi_784 == 1) Gd_808 = PipStarter / TurboDivider;
      if (Gi_784 == 2) Gd_808 = 2.0 * (PipStarter / TurboDivider);
      if (Gi_784 >= 3) Gd_808 = PipStarter;
   } else Gd_808 = PipStarter;
   if (MM == TRUE) {
      if (MathCeil(AccountBalance()) < 999.0) Ld_64 = Lots;
      else Ld_64 = 0.00001 * MathCeil(AccountBalance() / Divider);
   } else Ld_64 = Lots;
   if (bool_152) f0_24(Ld_156, Ld_164, G_price_856);
   if (Gi_788) {
      if (TimeCurrent() >= Gi_920) {
         f0_17();
         Print("Closed All system 3 trades because TimeOut was reached");
      }
   }
   double Ld_180 = f0_2();
   if (bool_128 == TRUE) {
      if (Ld_180 < 0.0 && MathAbs(Ld_180) > Ld_132 / 100.0 * f0_25()) {
         f0_17();
         Print("Closed all trades under this pair because StoplossPCT was met");
         Gi_968 = FALSE;
      }
   }
   if (bool_140) {
      if (Ld_180 > 0.0 && MathAbs(Ld_180) > Ld_144 / 100.0 * f0_25()) {
         f0_17();
         Print("Closed all trades under this pair because TakeProfitPCT was met");
         Gi_968 = FALSE;
      }
   }
   if (UseDollarTakeProfit_s3 == TRUE) {
      if (Gd_988 > DollarTakeProfit_s3) {
         f0_17();
         Print("Closed all Strategy 3 trades under this pair because DollarTakeProfit was met!");
         Gi_968 = FALSE;
      }
   }
   if (Time[0] != Gi_916) {
      Gi_916 = Time[0];
      Gi_940 = f0_28();
      if (Gi_940 == 0) Gi_904 = FALSE;
      for (G_pos_936 = OrdersTotal() - 1; G_pos_936 >= 0; G_pos_936--) {
         OrderSelect(G_pos_936, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_3) {
            if (OrderType() == OP_BUY) {
               Gi_956 = TRUE;
               Gi_960 = FALSE;
               break;
            }
            if (OrderType() == OP_SELL) {
               Gi_956 = FALSE;
               Gi_960 = TRUE;
               break;
            }
         }
      }
      if (Gi_940 <= MaxTrades_3) {
         RefreshRates();
         Gd_880 = f0_16();
         Gd_888 = f0_19();
         if (Gi_956 != FALSE && Gd_880 - Ask >= Gd_808 * Gd_228 * Point) Gi_952 = TRUE;
         if (Gi_960 != FALSE && Bid - Gd_888 >= Gd_808 * Gd_228 * Point) Gi_952 = TRUE;
      }
      if (Gi_940 < 1) {
         Gi_960 = FALSE;
         Gi_956 = FALSE;
         Gi_952 = TRUE;
         Gd_832 = AccountEquity();
      }
      if (Gi_952) {
         Gd_880 = f0_16();
         Gd_888 = f0_19();
         if (Gi_960) {
            Gi_924 = Gi_940;
            Gd_928 = NormalizeDouble(Ld_64 * MathPow(Ld_108, Gi_924), Li_116);
            RefreshRates();
            Gi_964 = f0_35(1, Gd_928, NormalizeDouble(Bid, Digits), Ld_172 * Gd_228, NormalizeDouble(Ask, Digits), 0, 0, system3_comment + ": Basket# " + Gi_924, MagicNumber_3,
               0, Black);
            if (Gi_964 < 0) {
               Print("Error_s3_1: ", GetLastError(), Gd_928);
               return;
            }
            Gd_888 = f0_19();
            Gi_952 = FALSE;
            Gi_968 = TRUE;
         } else {
            if (Gi_956) {
               Gi_924 = Gi_940;
               Gd_928 = NormalizeDouble(Ld_64 * MathPow(Ld_108, Gi_924), Li_116);
               Gi_964 = f0_35(0, Gd_928, NormalizeDouble(Ask, Digits), Ld_172 * Gd_228, NormalizeDouble(Bid, Digits), 0, 0, system3_comment + ": Basket# " + Gi_924, MagicNumber_3,
                  0, Green);
               if (Gi_964 < 1) {
                  Print("Error_s3_2: ", GetLastError());
                  return;
               }
               Gd_880 = f0_16();
               Gi_952 = FALSE;
               Gi_968 = TRUE;
            }
         }
      }
      if (Gi_952 != FALSE && Gi_940 < 1) {
         ihigh_32 = iHigh(Symbol(), 0, 1);
         ilow_40 = iLow(Symbol(), 0, 2);
         Gd_864 = NormalizeDouble(Bid, Digits);
         Gd_872 = NormalizeDouble(Ask, Digits);
         if (Gi_960 == FALSE && Gi_956 == FALSE) {
            Gi_924 = Gi_940;
            Gd_928 = NormalizeDouble(Ld_64 * MathPow(Ld_108, Gi_924), Li_116);
            if (UseStrategy_3 != FALSE && ContinueTrading != FALSE) {
               if (ihigh_32 > ilow_40) {
                  if (iRSI(NULL, G_timeframe_236, 14, PRICE_CLOSE, 1) > 30.0) {
                     Gi_964 = f0_35(1, Gd_928, Gd_864, Ld_172 * Gd_228, Gd_864, 0, 0, system3_comment + ": Basket# " + Gi_924, MagicNumber_3, 0, Black);
                     if (Gi_964 < 1) {
                        Print("Error_s3_3: ", GetLastError());
                        return;
                     }
                     Gd_880 = f0_16();
                     Gi_968 = TRUE;
                  }
               } else {
                  if (iRSI(NULL, G_timeframe_236, 14, PRICE_CLOSE, 1) < 70.0) {
                     Gi_964 = f0_35(0, Gd_928, Gd_872, Ld_172 * Gd_228, Gd_872, 0, 0, system3_comment + ": Basket# " + Gi_924, MagicNumber_3, 0, Green);
                     if (Gi_964 < 1) {
                        Print("Error_s3_4: ", GetLastError());
                        return;
                     }
                     Gd_888 = f0_19();
                     Gi_968 = TRUE;
                  }
               }
            }
            if (Gi_964 > 0) Gi_920 = TimeCurrent() + 3600.0 * Gd_792;
            Gi_952 = FALSE;
         }
      }
      Gi_940 = f0_28();
      G_price_856 = 0.0;
      Ld_188 = 0.0;
      for (G_pos_936 = OrdersTotal() - 1; G_pos_936 >= 0; G_pos_936--) {
         OrderSelect(G_pos_936, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_3) {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
               G_price_856 += OrderOpenPrice() * OrderLots();
               Ld_188 += OrderLots();
            }
         }
      }
      if (Gi_940 > 0) G_price_856 = NormalizeDouble(G_price_856 / Ld_188, Digits);
      if (Gi_968) {
         for (G_pos_936 = OrdersTotal() - 1; G_pos_936 >= 0; G_pos_936--) {
            OrderSelect(G_pos_936, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_3) {
               if (OrderType() == OP_BUY) {
                  G_price_824 = G_price_856 + Ld_120 * Gd_228 * Point;
                  Gd_unused_840 = G_price_824;
                  Gd_944 = G_price_856 - G_pips_800 * Point;
                  Gi_904 = TRUE;
               }
               if (OrderType() == OP_SELL) {
                  G_price_824 = G_price_856 - Ld_120 * Gd_228 * Point;
                  Gd_unused_848 = G_price_824;
                  Gd_944 = G_price_856 + G_pips_800 * Point;
                  Gi_904 = TRUE;
               }
            }
         }
      }
      if (Gi_968) {
         if (Gi_904 == TRUE) {
            for (int Li_196 = OrdersTotal() - 1; Li_196 >= 0; Li_196--) {
               if (f0_29(Li_196, SELECT_BY_POS)) {
                  while (!IsTradeAllowed()) {
                     Sleep(150);
                     RefreshRates();
                  }
                  while (!OrderModify(OrderTicket(), G_price_856, OrderStopLoss(), G_price_824, 0, Yellow)) {
                     Sleep(1000);
                     RefreshRates();
                  }
                  Gi_968 = FALSE;
               }
            }
         }
      }
      Ld_200 = Booster;
      Li_208 = Gi_212;
      Ld_212 = TakeProfit;
      bool_220 = UseStoplossPct;
      Ld_224 = StoplossPct;
      bool_232 = UseTakeProfitPct;
      Ld_236 = TakeProfitPct;
      bool_244 = UseTrailingStop;
      Ld_248 = StartTrailing;
      Ld_256 = StopTrailing;
      Ld_264 = Slippage;
      Gi_280 = f0_38();
      if (TurboMode) {
         if (Gi_280 == 1) Gd_308 = PipStarter / TurboDivider;
         if (Gi_280 == 2) Gd_308 = 2.0 * (PipStarter / TurboDivider);
         if (Gi_280 >= 3) Gd_308 = PipStarter;
      } else Gd_308 = PipStarter;
      if (MM == TRUE) {
         if (MathCeil(AccountBalance()) < 999.0) Ld_72 = Lots;
         else Ld_72 = 0.00001 * MathCeil(AccountBalance() / Divider);
      } else Ld_72 = Lots;
      if (bool_244) f0_33(Ld_248, Ld_256, G_price_356);
      if (Gi_296) {
         if (TimeCurrent() >= Gi_420) {
            f0_32();
            Print("Closed All system 1 trades due to TimeOut");
         }
      }
      Ld_272 = f0_0();
      if (bool_220) {
         if (Ld_272 < 0.0 && MathAbs(Ld_272) > Ld_224 / 100.0 * f0_18()) {
            f0_32();
            Print("Closed all trades under this pair because StoplossPCT was met");
            Gi_468 = FALSE;
         }
      }
      if (bool_232) {
         if (Ld_272 > 0.0 && MathAbs(Ld_272) > Ld_236 / 100.0 * f0_18()) {
            f0_32();
            Print("Closed all trades under this pair because TakeProfitPCT was met");
            Gi_468 = FALSE;
         }
      }
      if (UseDollarTakeProfit_s1) {
         if (Ld_272 > DollarTakeProfit_s1) {
            f0_32();
            Print("Closed all Strategy 1 trades under this pair because DollarTakeProfit was met!");
            Gi_468 = FALSE;
         }
      }
      if (Time[0] != Gi_416) {
         Gi_416 = Time[0];
         Gi_440 = f0_38();
         if (Gi_440 == 0) Gi_404 = FALSE;
         for (G_pos_436 = OrdersTotal() - 1; G_pos_436 >= 0; G_pos_436--) {
            OrderSelect(G_pos_436, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1) {
               if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1) {
                  if (OrderType() == OP_BUY) {
                     Gi_456 = TRUE;
                     Gi_460 = FALSE;
                     break;
                  }
               }
               if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1) {
                  if (OrderType() == OP_SELL) {
                     Gi_456 = FALSE;
                     Gi_460 = TRUE;
                     break;
                  }
               }
            }
         }
         if (Gi_440 > 0 && MaxTrades_1 >= Gi_440) {
            RefreshRates();
            Gd_380 = f0_20();
            Gd_388 = f0_3();
            if (Gi_456 != FALSE && Gd_380 - Ask >= Gd_308 * Gd_228 * Point) Gi_452 = TRUE;
            if (Gi_460 != FALSE && Bid - Gd_388 >= Gd_308 * Gd_228 * Point) Gi_452 = TRUE;
         }
         if (Gi_440 < 1) {
            Gi_460 = FALSE;
            Gi_456 = FALSE;
            Gi_452 = TRUE;
            Gd_332 = AccountEquity();
         }
         if (Gi_452) {
            Gd_380 = f0_20();
            Gd_388 = f0_3();
            if (Gi_460) {
               Gi_424 = Gi_440;
               Gd_428 = NormalizeDouble(Ld_72 * MathPow(Ld_200, Gi_424), Li_208);
               RefreshRates();
               Gi_464 = f0_7(1, Gd_428, NormalizeDouble(Bid, Digits), Ld_264 * Gd_228, NormalizeDouble(Ask, Digits), 0, 0, system1_comment + ": Basket# " + Gi_424, MagicNumber_1,
                  0, Black);
               if (Gi_464 < 0) {
                  Print("Error_s1_1: ", GetLastError());
                  return;
               }
               Gd_388 = f0_3();
               Gi_452 = FALSE;
               Gi_468 = TRUE;
            } else {
               if (Gi_456) {
                  Gi_424 = Gi_440;
                  Gd_428 = NormalizeDouble(Ld_72 * MathPow(Ld_200, Gi_424), Li_208);
                  Gi_464 = f0_7(0, Gd_428, NormalizeDouble(Ask, Digits), Ld_264 * Gd_228, NormalizeDouble(Bid, Digits), 0, 0, system1_comment + ": Basket# " + Gi_424, MagicNumber_1,
                     0, Green);
                  if (Gi_464 < 0) {
                     Print("Error:_s1_2 ", GetLastError());
                     return;
                  }
                  Gd_380 = f0_20();
                  Gi_452 = FALSE;
                  Gi_468 = TRUE;
               }
            }
         }
      }
      if (iTime(NULL, G_timeframe_284, 0) != G_datetime_488) {
         Li_80 = OrdersTotal();
         count_84 = 0;
         for (int Li_280 = Li_80; Li_280 >= 1; Li_280--) {
            OrderSelect(Li_280 - 1, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1) count_84++;
         }
         if (Li_80 == 0 || count_84 < 1) {
            iclose_48 = iClose(Symbol(), 0, 2);
            iclose_56 = iClose(Symbol(), 0, 1);
            Gd_364 = NormalizeDouble(Bid, Digits);
            Gd_372 = NormalizeDouble(Ask, Digits);
            if (Gi_460 == FALSE && Gi_456 == FALSE) {
               Gi_424 = Gi_440;
               Gd_428 = NormalizeDouble(Ld_72 * MathPow(Booster, Gi_424), Li_208);
               if (iclose_48 > iclose_56) {
                  if (UseStrategy_1 && ContinueTrading) {
                     Gi_464 = f0_7(1, Gd_428, Gd_364, Ld_264 * Gd_228, Gd_364, 0, 0, system1_comment + ": Basket# " + Gi_424, MagicNumber_1, 0, Black);
                     if (Gi_464 < 1) {
                        Print("Error_s1_3: ", GetLastError());
                        return;
                     }
                     Gd_380 = f0_20();
                     Gi_468 = TRUE;
                  }
               }
            } else {
               if (UseStrategy_1 != FALSE && ContinueTrading != FALSE) {
                  Gi_464 = f0_7(0, Gd_428, Gd_372, Ld_264 * Gd_228, Gd_372, 0, 0, system1_comment + ": Basket# " + Gi_424, MagicNumber_1, 0, Green);
                  if (Gi_464 < 1) {
                     Print("Error_s1_4: ", GetLastError());
                     return;
                  }
                  Gd_388 = f0_3();
                  Gi_468 = TRUE;
               }
            }
            if (Gi_464 > 0) Gi_420 = TimeCurrent() + 3600.0 * Gd_300;
            Gi_452 = FALSE;
         }
         G_datetime_488 = iTime(NULL, G_timeframe_284, 0);
      }
      Gi_440 = f0_38();
      G_price_356 = 0.0;
      Ld_284 = 0.0;
      for (G_pos_436 = OrdersTotal() - 1; G_pos_436 >= 0; G_pos_436--) {
         OrderSelect(G_pos_436, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1 == 1) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1) {
               if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
                  G_price_356 += OrderOpenPrice() * OrderLots();
                  Ld_284 += OrderLots();
               }
            }
         }
      }
      if (Gi_440 > 0) G_price_356 = NormalizeDouble(G_price_356 / Ld_284, Digits);
      if (Gi_468) {
         for (G_pos_436 = OrdersTotal() - 1; G_pos_436 >= 0; G_pos_436--) {
            OrderSelect(G_pos_436, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1 == 1) {
               if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1) {
                  if (OrderType() == OP_BUY) {
                     G_price_324 = G_price_356 + Ld_212 * Gd_228 * Point;
                     Gd_unused_340 = G_price_324;
                     Gd_444 = G_price_356 - G_pips_288 * Point;
                     Gi_404 = TRUE;
                  }
               }
               if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1) {
                  if (OrderType() == OP_SELL) {
                     G_price_324 = G_price_356 - Ld_212 * Gd_228 * Point;
                     Gd_unused_348 = G_price_324;
                     Gd_444 = G_price_356 + G_pips_288 * Point;
                     Gi_404 = TRUE;
                  }
               }
            }
         }
      }
      if (Gi_468) {
         if (Gi_404 == TRUE) {
            for (int Li_292 = OrdersTotal() - 1; Li_292 >= 0; Li_292--) {
               if (f0_22(Li_292, SELECT_BY_POS)) {
                  while (!IsTradeAllowed()) {
                     Sleep(150);
                     RefreshRates();
                  }
                  while (!OrderModify(OrderTicket(), G_price_356, OrderStopLoss(), G_price_324, 0, Yellow)) {
                     Sleep(900);
                     RefreshRates();
                  }
                  Gi_468 = FALSE;
               }
            }
         }
      }
      Ld_296 = Booster;
      Li_304 = Gi_212;
      Ld_308 = TakeProfit;
      bool_316 = UseStoplossPct;
      Ld_320 = StoplossPct;
      bool_328 = UseTakeProfitPct;
      Ld_332 = TakeProfitPct;
      bool_340 = UseTrailingStop;
      Ld_344 = StartTrailing;
      Ld_352 = StopTrailing;
      Ld_360 = Slippage;
      Gi_532 = f0_23();
      if (TurboMode) {
         if (Gi_532 == 1) Gd_560 = PipStarter / TurboDivider;
         if (Gi_532 == 2) Gd_560 = 2.0 * (PipStarter / TurboDivider);
         if (Gi_532 >= 3) Gd_560 = PipStarter;
      } else Gd_560 = PipStarter;
      if (MM) {
         if (MathCeil(AccountBalance()) < 999.0) Ld_88 = Lots;
         else Ld_88 = 0.00001 * MathCeil(AccountBalance() / Divider);
      } else Ld_88 = Lots;
      if (bool_340) f0_10(Ld_344, Ld_352, G_price_608);
      if (Gi_548) {
         if (TimeCurrent() >= Gi_672) {
            f0_15();
            Print("Closed All system 2 trades due to TimeOut");
         }
      }
      Ld_368 = f0_30();
      if (bool_316) {
         if (Ld_368 < 0.0 && MathAbs(Ld_368) > Ld_320 / 100.0 * f0_21()) {
            f0_15();
            Print("Closed all trades under this pair because StoplossPCT was met");
            Gi_720 = FALSE;
         }
      }
      if (bool_328) {
         if (Ld_368 > 0.0 && MathAbs(Ld_368) > Ld_332 / 100.0 * f0_21()) {
            f0_15();
            Print("Closed all trades under this pair because TakeProfitPCT was met");
            Gi_720 = FALSE;
         }
      }
      if (UseDollarTakeProfit_s2) {
         if (Ld_368 > DollarTakeProfit_s2) {
            f0_15();
            Print("Closed all Strategy 2 trades under this pair because DollarTakeProfit was met!");
            Gi_720 = FALSE;
         }
      }
      if (Time[0] != Gi_668) {
         Gi_668 = Time[0];
         Gi_692 = f0_23();
         if (Gi_692 == 0) Gi_656 = FALSE;
         for (G_pos_688 = OrdersTotal() - 1; G_pos_688 >= 0; G_pos_688--) {
            OrderSelect(G_pos_688, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_2) {
               if (OrderType() == OP_BUY) {
                  Gi_708 = TRUE;
                  Gi_712 = FALSE;
                  break;
               }
               if (OrderType() == OP_SELL) {
                  Gi_708 = FALSE;
                  Gi_712 = TRUE;
                  break;
               }
            }
         }
         if (Gi_692 <= MaxTrades_2) {
            RefreshRates();
            Gd_632 = f0_12();
            Gd_640 = f0_5();
            if (Gi_708 != FALSE && Gd_632 - Ask >= Gd_560 * Gd_228 * Point) Gi_704 = TRUE;
            if (Gi_712 != FALSE && Bid - Gd_640 >= Gd_560 * Gd_228 * Point) Gi_704 = TRUE;
         }
         if (Gi_692 < 1) {
            Gi_712 = FALSE;
            Gi_708 = FALSE;
            Gi_704 = TRUE;
            Gd_584 = AccountEquity();
         }
         if (Gi_704) {
            Gd_632 = f0_12();
            Gd_640 = f0_5();
            if (Gi_712) {
               Gi_676 = Gi_692;
               Gd_680 = NormalizeDouble(Ld_88 * MathPow(Ld_296, Gi_676), Li_304);
               RefreshRates();
               Gi_716 = f0_6(1, Gd_680, NormalizeDouble(Bid, Digits), Ld_360 * Gd_228, NormalizeDouble(Ask, Digits), 0, 0, system2_comment + ": Basket# " + Gi_676, MagicNumber_2,
                  0, Black);
               if (Gi_716 < 0) {
                  Print("Error_s2_1: ", GetLastError());
                  return;
               }
               Gd_640 = f0_5();
               Gi_704 = FALSE;
               Gi_720 = TRUE;
            } else {
               if (Gi_708) {
                  Gi_676 = Gi_692;
                  Gd_680 = NormalizeDouble(Ld_88 * MathPow(Ld_296, Gi_676), Li_304);
                  Gi_716 = f0_6(0, Gd_680, NormalizeDouble(Ask, Digits), Ld_360 * Gd_228, NormalizeDouble(Bid, Digits), 0, 0, system2_comment + ": Basket# " + Gi_676, MagicNumber_2,
                     0, Green);
                  if (Gi_716 < 1) {
                     Print("Error_s2_2: ", GetLastError());
                     return;
                  }
                  Gd_632 = f0_12();
                  Gi_704 = FALSE;
                  Gi_720 = TRUE;
               }
            }
         }
      }
      if (iTime(NULL, G_timeframe_536, 0) != G_datetime_740) {
         Li_96 = OrdersTotal();
         count_100 = 0;
         for (int Li_376 = Li_96; Li_376 >= 1; Li_376--) {
            OrderSelect(Li_376 - 1, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_2) count_100++;
         }
         if (Li_96 == 0 || count_100 < 1) {
            iclose_48 = iClose(Symbol(), 0, 2);
            iclose_56 = iClose(Symbol(), 0, 1);
            Gd_616 = NormalizeDouble(Bid, Digits);
            Gd_624 = NormalizeDouble(Ask, Digits);
            if (Gi_712 == FALSE && Gi_708 == FALSE) {
               Gi_676 = Gi_692;
               Gd_680 = NormalizeDouble(Ld_88 * MathPow(Ld_296, Gi_676), Li_304);
               if (UseStrategy_2 != FALSE && ContinueTrading != FALSE) {
                  if (iclose_48 > iclose_56) {
                     if (iRSI(NULL, G_timeframe_236, 14, PRICE_CLOSE, 1) > 30.0) {
                        Gi_716 = f0_6(1, Gd_680, Gd_616, Ld_360 * Gd_228, Gd_616, 0, 0, system2_comment + ": Basket# " + Gi_676, MagicNumber_2, 0, Black);
                        if (Gi_716 < 0) {
                           Print("Error_s2_3: ", GetLastError());
                           return;
                        }
                        Gd_632 = f0_12();
                        Gi_720 = TRUE;
                     }
                  } else {
                     if (iRSI(NULL, G_timeframe_236, 14, PRICE_CLOSE, 1) < 70.0) {
                        Gi_716 = f0_6(0, Gd_680, Gd_624, Ld_360 * Gd_228, Gd_624, 0, 0, system2_comment + ": Basket# " + Gi_676, MagicNumber_2, 0, Green);
                        if (Gi_716 < 0) {
                           Print("Error_s2_4: ", GetLastError());
                           return;
                        }
                        Gd_640 = f0_5();
                        Gi_720 = TRUE;
                     }
                  }
               }
               if (Gi_716 > 0) Gi_672 = TimeCurrent() + 3600.0 * Gd_552;
               Gi_704 = FALSE;
            }
         }
         G_datetime_740 = iTime(NULL, G_timeframe_536, 0);
      }
      Gi_692 = f0_23();
      G_price_608 = 0.0;
      Ld_380 = 0.0;
      for (G_pos_688 = OrdersTotal() - 1; G_pos_688 >= 0; G_pos_688--) {
         OrderSelect(G_pos_688, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_2) {
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
               G_price_608 += OrderOpenPrice() * OrderLots();
               Ld_380 += OrderLots();
            }
         }
      }
      if (Gi_692 > 0) G_price_608 = NormalizeDouble(G_price_608 / Ld_380, Digits);
      if (Gi_720) {
         for (G_pos_688 = OrdersTotal() - 1; G_pos_688 >= 0; G_pos_688--) {
            OrderSelect(G_pos_688, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_2 == 1) {
               if (OrderType() == OP_BUY) {
                  G_price_576 = G_price_608 + Ld_308 * Gd_228 * Point;
                  Gd_unused_592 = G_price_576;
                  Gd_696 = G_price_608 - G_pips_540 * Point;
                  Gi_656 = TRUE;
               }
               if (OrderType() == OP_SELL) {
                  G_price_576 = G_price_608 - Ld_308 * Gd_228 * Point;
                  Gd_unused_600 = G_price_576;
                  Gd_696 = G_price_608 + G_pips_540 * Point;
                  Gi_656 = TRUE;
               }
            }
         }
      }
      if (Gi_720) {
         if (Gi_656 == TRUE) {
            for (int Li_388 = OrdersTotal() - 1; Li_388 >= 0; Li_388--) {
               if (f0_1(Li_388, SELECT_BY_POS)) {
                  while (!IsTradeAllowed()) {
                     Sleep(150);
                     RefreshRates();
                  }
                  while (!OrderModify(OrderTicket(), G_price_608, OrderStopLoss(), G_price_576, 0, Yellow)) {
                     Sleep(800);
                     RefreshRates();
                  }
                  Gi_720 = FALSE;
               }
            }
         }
      }
   }
}

// AA5EA51BFAC7B64E723BF276E0075513
int f0_28() {
   int count_0 = 0;
   Gd_988 = 0.0;
   double Ld_4 = 0.0;
   for (int pos_12 = OrdersTotal() - 1; pos_12 >= 0; pos_12--) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_3 == TRUE) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_3) {
            if (OrderType() == OP_SELL || OrderType() == OP_BUY) {
               count_0++;
               Gd_988 = OrderProfit() + OrderSwap() + Gd_988;
               Ld_4 = OrderLots() + Ld_4;
            }
         }
      }
   }
   return (count_0);
}

// 6ABA3523C7A75AAEA41CC0DEC7953CC5
void f0_17() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_3) {
         if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Gd_816 * Gd_228, DarkGray);
         if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Gd_816 * Gd_228, YellowGreen);
      }
      Sleep(600);
   }
}

// F7B1F0AA13347699EFAE0D924298CB02
int f0_35(int Ai_0, double A_lots_4, double Ad_unused_12, double Ad_20, double Ad_unused_28, int Ai_36, int Ai_40, string A_comment_44, int A_magic_52, int A_datetime_56, color A_color_60) {
   int ticket_64 = 0;
   int error_68 = 0;
   int count_72 = 0;
   int Li_76 = 100;
   switch (Ai_0) {
   case 0:
      for (count_72 = 0; count_72 < Li_76; count_72++) {
         while (!IsTradeAllowed()) {
            Sleep(150);
            RefreshRates();
         }
         ticket_64 = OrderSend(Symbol(), OP_BUY, A_lots_4, NormalizeDouble(Ask, Digits), Ad_20 * Gd_228, NormalizeDouble(f0_4(Bid, Ai_36), Digits), NormalizeDouble(f0_27(Ask,
            Ai_40), Digits), A_comment_44, A_magic_52, A_datetime_56, A_color_60);
         error_68 = GetLastError();
         if (error_68 == 0/* NO_ERROR */) break;
         if (error_68 != 4/* SERVER_BUSY */ || error_68 != 137/* BROKER_BUSY */ || error_68 != 146/* TRADE_CONTEXT_BUSY */ || error_68 != 136/* OFF_QUOTES */) break;
         Sleep(3000);
      }
      break;
   case 1:
      for (count_72 = 0; count_72 < Li_76; count_72++) {
         while (!IsTradeAllowed()) {
            Sleep(150);
            RefreshRates();
         }
         ticket_64 = OrderSend(Symbol(), OP_SELL, A_lots_4, NormalizeDouble(Bid, Digits), Ad_20 * Gd_228, NormalizeDouble(f0_13(Ask, Ai_36), Digits), NormalizeDouble(f0_14(Bid,
            Ai_40), Digits), A_comment_44, A_magic_52, A_datetime_56, A_color_60);
         error_68 = GetLastError();
         if (error_68 == 0/* NO_ERROR */) break;
         if (error_68 != 4/* SERVER_BUSY */ || error_68 != 137/* BROKER_BUSY */ || error_68 != 146/* TRADE_CONTEXT_BUSY */ || error_68 != 136/* OFF_QUOTES */) break;
         Sleep(3500);
      }
   }
   return (ticket_64);
}

// 19821383AADC0BD1EE56BF2194EC478F
double f0_4(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0.0);
   return (Ad_0 - Ai_8 * Point);
}

// 58B0897F29A3AD862616D6CBF39536ED
double f0_13(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0.0);
   return (Ad_0 + Ai_8 * Point);
}

// A0F6E6535C856D4495BA899376567E48
double f0_27(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0.0);
   return (Ad_0 + Ai_8 * Point);
}

// 632A6309D71E99A017FD9D3CE1A19C24
double f0_14(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0.0);
   return (Ad_0 - Ai_8 * Point);
}

// 0B26898E7D2CBB01295E320263028F2C
double f0_2() {
   double Ld_ret_0 = 0.0;
   for (G_pos_936 = OrdersTotal() - 1; G_pos_936 >= 0; G_pos_936--) {
      OrderSelect(G_pos_936, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_3)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) Ld_ret_0 += OrderProfit();
   }
   return (Ld_ret_0);
}

// 9B1AEE847CFB597942D106A4135D4FE6
void f0_24(double Ad_0, double Ad_8, double A_price_16) {
   int Li_24;
   double order_stoploss_28;
   double price_36;
   if (Ad_8 != 0.0) {
      for (int pos_44 = OrdersTotal() - 1; pos_44 >= 0; pos_44--) {
         if (OrderSelect(pos_44, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_3) {
               if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_3) {
                  if (OrderType() == OP_BUY) {
                     Li_24 = MathFloor((Bid - A_price_16) / Point);
                     if (Li_24 < Ad_0) continue;
                     order_stoploss_28 = OrderStopLoss();
                     price_36 = Bid - Ad_8 * Gd_228 * Point;
                     if (order_stoploss_28 == 0.0 || order_stoploss_28 < price_36) OrderModify(OrderTicket(), A_price_16, price_36, OrderTakeProfit(), 0, Gray);
                  }
                  if (OrderType() == OP_SELL) {
                     Li_24 = MathFloor((A_price_16 - Ask) / Point);
                     if (Li_24 < Ad_0) continue;
                     order_stoploss_28 = OrderStopLoss();
                     price_36 = Ask + Ad_8 * Gd_228 * Point;
                     if (order_stoploss_28 == 0.0 || order_stoploss_28 > price_36) OrderModify(OrderTicket(), A_price_16, price_36, OrderTakeProfit(), 0, SpringGreen);
                  }
               }
               Sleep(200);
            }
         }
      }
   }
}

// 9ED55815FB278759298B6BAF50BEC3C8
double f0_25() {
   if (f0_28() == 0) Gd_972 = AccountEquity();
   if (Gd_972 < Gd_980) Gd_972 = Gd_980;
   else Gd_972 = AccountEquity();
   Gd_980 = AccountEquity();
   return (Gd_972);
}

// 689C35E4872BA754D7230B8ADAA28E48
double f0_16() {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0.0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_3 == TRUE) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_3 && OrderType() == OP_BUY) {
            ticket_8 = OrderTicket();
            if (ticket_8 > ticket_20) {
               order_open_price_0 = OrderOpenPrice();
               Ld_unused_12 = order_open_price_0;
               ticket_20 = ticket_8;
            }
         }
      }
   }
   return (order_open_price_0);
}

// 81A4CBF7E575109EFB1104EFB9B5DF39
double f0_19() {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0.0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_3 == TRUE) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_3 && OrderType() == OP_SELL) {
            ticket_8 = OrderTicket();
            if (ticket_8 > ticket_20) {
               order_open_price_0 = OrderOpenPrice();
               Ld_unused_12 = order_open_price_0;
               ticket_20 = ticket_8;
            }
         }
      }
   }
   return (order_open_price_0);
}

// FD4055E1AC0A7D690C66D37B2C70E529
int f0_38() {
   int count_0 = 0;
   Gd_492 = 0.0;
   double Ld_4 = 0.0;
   for (int pos_12 = OrdersTotal() - 1; pos_12 >= 0; pos_12--) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1) {
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) {
            count_0++;
            Ld_4 = OrderLots() + Ld_4;
            Gd_492 = OrderProfit() + OrderSwap() + Gd_492;
         }
      }
   }
   return (count_0);
}

// D362D41CFF235C066CFB390D52F4EB13
void f0_32() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1) {
         if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Gd_316 * Gd_228, DarkGray);
         if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Gd_316 * Gd_228, GreenYellow);
      }
      Sleep(500);
   }
}

// 28EFB830D150E70A8BB0F12BAC76EF35
int f0_7(int Ai_0, double A_lots_4, double Ad_unused_12, double Ad_20, double Ad_unused_28, int Ai_36, int Ai_40, string A_comment_44, int A_magic_52, int A_datetime_56, color A_color_60) {
   int ticket_64 = 0;
   int error_68 = 0;
   int count_72 = 0;
   int Li_76 = 100;
   switch (Ai_0) {
   case 0:
      for (count_72 = 0; count_72 < Li_76; count_72++) {
         while (!IsTradeAllowed()) {
            Sleep(150);
            RefreshRates();
         }
         ticket_64 = OrderSend(Symbol(), OP_BUY, A_lots_4, NormalizeDouble(Ask, Digits), Ad_20 * Gd_228, NormalizeDouble(f0_11(Bid, Ai_36), Digits), NormalizeDouble(f0_26(Ask,
            Ai_40), Digits), A_comment_44, A_magic_52, A_datetime_56, A_color_60);
         error_68 = GetLastError();
         if (error_68 == 0/* NO_ERROR */) break;
         if (error_68 != 4/* SERVER_BUSY */ || error_68 != 136/* OFF_QUOTES */ || error_68 != 137/* BROKER_BUSY */ || error_68 != 146/* TRADE_CONTEXT_BUSY */) break;
         Sleep(4000);
      }
      break;
   case 1:
      for (count_72 = 0; count_72 < Li_76; count_72++) {
         while (!IsTradeAllowed()) {
            Sleep(150);
            RefreshRates();
         }
         ticket_64 = OrderSend(Symbol(), OP_SELL, A_lots_4, NormalizeDouble(Bid, Digits), Ad_20 * Gd_228, NormalizeDouble(f0_9(Ask, Ai_36), Digits), NormalizeDouble(f0_31(Bid,
            Ai_40), Digits), A_comment_44, A_magic_52, A_datetime_56, A_color_60);
         error_68 = GetLastError();
         if (error_68 == 0/* NO_ERROR */) break;
         if (error_68 != 4/* SERVER_BUSY */ || error_68 != 137/* BROKER_BUSY */ || error_68 != 146/* TRADE_CONTEXT_BUSY */ || error_68 != 136/* OFF_QUOTES */) break;
         Sleep(4500);
      }
   }
   return (ticket_64);
}

// 528FD8B404F8774AC78741021D00D737
double f0_11(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0.0);
   return (Ad_0 - Ai_8 * Point);
}

// 3180D254E1C24E987439E4F62708F6A2
double f0_9(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0.0);
   return (Ad_0 + Ai_8 * Point);
}

// 9FDC179C742334D485A77A8B241EC55C
double f0_26(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0.0);
   return (Ad_0 + Ai_8 * Point);
}

// D1DDCE31F1A86B3140880F6B1877CBF8
double f0_31(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0.0);
   return (Ad_0 - Ai_8 * Point);
}

// 07726B7CD4E14568E00388C5E27E3F10
double f0_0() {
   double Ld_ret_0 = 0.0;
   for (G_pos_436 = OrdersTotal() - 1; G_pos_436 >= 0; G_pos_436--) {
      OrderSelect(G_pos_436, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1)
            if (OrderType() == OP_BUY || OrderType() == OP_SELL) Ld_ret_0 += OrderProfit();
      }
   }
   return (Ld_ret_0);
}

// E57BE7F0D51233E12F19376575CE10FF
void f0_33(double Ad_0, double Ad_8, double A_price_16) {
   int Li_24;
   double order_stoploss_28;
   double price_36;
   if (Ad_8 != 0.0) {
      for (int pos_44 = OrdersTotal() - 1; pos_44 >= 0; pos_44--) {
         if (OrderSelect(pos_44, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1 == 1) {
               if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1) {
                  if (OrderType() == OP_BUY) {
                     RefreshRates();
                     Li_24 = MathFloor((Bid - A_price_16) / Point);
                     if (Li_24 < Ad_0) continue;
                     order_stoploss_28 = OrderStopLoss();
                     price_36 = Bid - Ad_8 * Gd_228 * Point;
                     if (order_stoploss_28 == 0.0 || order_stoploss_28 < price_36) OrderModify(OrderTicket(), A_price_16, price_36, OrderTakeProfit(), 0, SlateGray);
                  }
                  if (OrderType() == OP_SELL) {
                     RefreshRates();
                     Li_24 = MathFloor((A_price_16 - Ask) / Point);
                     if (Li_24 < Ad_0) continue;
                     order_stoploss_28 = OrderStopLoss();
                     price_36 = Ask + Ad_8 * Gd_228 * Point;
                     if (order_stoploss_28 == 0.0 || order_stoploss_28 > price_36) {
                        OrderModify(OrderTicket(), A_price_16, price_36, OrderTakeProfit(), 0, SpringGreen);
                        Print("STOPLOSS IS:" + price_36);
                     }
                  }
               }
               Sleep(500);
            }
         }
      }
   }
}

// 78BAA8FAE18F93570467778F2E829047
double f0_18() {
   if (f0_38() == 0) Gd_472 = AccountEquity();
   if (Gd_472 < Gd_480) Gd_472 = Gd_480;
   else Gd_472 = AccountEquity();
   Gd_480 = AccountEquity();
   return (Gd_472);
}

// 88CBC5FF77567D51686974367A3E9700
double f0_20() {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0.0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1 == TRUE) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1 && OrderType() == OP_BUY) {
            ticket_8 = OrderTicket();
            if (ticket_8 > ticket_20) {
               order_open_price_0 = OrderOpenPrice();
               Ld_unused_12 = order_open_price_0;
               ticket_20 = ticket_8;
            }
         }
      }
   }
   return (order_open_price_0);
}

// 184916985BFD167AE4E08C739AF60F52
double f0_3() {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0.0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1 && OrderType() == OP_SELL) {
         ticket_8 = OrderTicket();
         if (ticket_8 > ticket_20) {
            order_open_price_0 = OrderOpenPrice();
            Ld_unused_12 = order_open_price_0;
            ticket_20 = ticket_8;
         }
      }
   }
   return (order_open_price_0);
}

// 945D754CB0DC06D04243FCBA25FC0802
int f0_23() {
   int count_0 = 0;
   double Ld_4 = 0.0;
   Gd_744 = 0.0;
   for (int pos_12 = OrdersTotal() - 1; pos_12 >= 0; pos_12--) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_2) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_2) {
            if (OrderType() == OP_SELL || OrderType() == OP_BUY) {
               count_0++;
               Ld_4 = OrderLots() + Ld_4;
               Gd_744 = OrderProfit() + OrderSwap() + Gd_744;
            }
         }
      }
   }
   return (count_0);
}

// 667DC3F4F5B9C0B70229F573988AC7C0
void f0_15() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_2) {
         if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Gd_568 * Gd_228, DarkGray);
         if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), Gd_568 * Gd_228, GreenYellow);
      }
      Sleep(500);
   }
}

// 2569208C5E61CB15E209FFE323DB48B7
int f0_6(int Ai_0, double A_lots_4, double Ad_unused_12, double Ad_20, double Ad_unused_28, int Ai_36, int Ai_40, string A_comment_44, int A_magic_52, int A_datetime_56, color A_color_60) {
   int ticket_64 = 0;
   int error_68 = 0;
   int count_72 = 0;
   int Li_76 = 100;
   switch (Ai_0) {
   case 0:
      for (count_72 = 0; count_72 < Li_76; count_72++) {
         while (!IsTradeAllowed()) {
            Sleep(150);
            RefreshRates();
         }
         ticket_64 = OrderSend(Symbol(), OP_BUY, A_lots_4, NormalizeDouble(Ask, Digits), Ad_20 * Gd_228, NormalizeDouble(f0_37(Bid, Ai_36), Digits), NormalizeDouble(f0_36(Ask,
            Ai_40), Digits), A_comment_44, A_magic_52, A_datetime_56, A_color_60);
         error_68 = GetLastError();
         if (error_68 == 0/* NO_ERROR */) break;
         if (error_68 != 4/* SERVER_BUSY */ || error_68 != 137/* BROKER_BUSY */ || error_68 != 146/* TRADE_CONTEXT_BUSY */ || error_68 != 136/* OFF_QUOTES */) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (count_72 = 0; count_72 < Li_76; count_72++) {
         while (!IsTradeAllowed()) {
            Sleep(150);
            RefreshRates();
         }
         ticket_64 = OrderSend(Symbol(), OP_SELL, A_lots_4, NormalizeDouble(Bid, Digits), Ad_20 * Gd_228, NormalizeDouble(f0_8(Ask, Ai_36), Digits), NormalizeDouble(f0_34(Bid,
            Ai_40), Digits), A_comment_44, A_magic_52, A_datetime_56, A_color_60);
         error_68 = GetLastError();
         if (error_68 == 0/* NO_ERROR */) break;
         if (error_68 != 4/* SERVER_BUSY */ || error_68 != 136/* OFF_QUOTES */ || error_68 != 137/* BROKER_BUSY */ || error_68 != 146/* TRADE_CONTEXT_BUSY */) break;
         Sleep(5500);
      }
   }
   return (ticket_64);
}

// F96D30471D3E10470383B6981C5E7039
double f0_37(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0.0);
   return (Ad_0 - Ai_8 * Point);
}

// 2FC9212C93C86A99B2C376C96453D3A4
double f0_8(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0.0);
   return (Ad_0 + Ai_8 * Point);
}

// F8058EB0D24E6949E44CCCFC53A38CBD
double f0_36(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0.0);
   return (Ad_0 + Ai_8 * Point);
}

// F590ACE4AD4063CE989827AACE7F7FA6
double f0_34(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0.0);
   return (Ad_0 - Ai_8 * Point);
}

// C326432F8CFFDF18B9C33D8D42CEBC52
double f0_30() {
   double Ld_ret_0 = 0.0;
   for (G_pos_688 = OrdersTotal() - 1; G_pos_688 >= 0; G_pos_688--) {
      OrderSelect(G_pos_688, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_2 == TRUE)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) Ld_ret_0 += OrderProfit();
   }
   return (Ld_ret_0);
}

// 50257C26C4E5E915F022247BABD914FE
void f0_10(double Ad_0, double Ad_8, double A_price_16) {
   int Li_24;
   double order_stoploss_28;
   double price_36;
   if (Ad_8 != 0.0) {
      for (int pos_44 = OrdersTotal() - 1; pos_44 >= 0; pos_44--) {
         if (OrderSelect(pos_44, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_2 == 1) {
               if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_2) {
                  if (OrderType() == OP_BUY) {
                     Li_24 = MathFloor((Bid - A_price_16) / Point);
                     if (Li_24 < Ad_0) continue;
                     order_stoploss_28 = OrderStopLoss();
                     price_36 = Bid - Ad_8 * Gd_228 * Point;
                     if (order_stoploss_28 == 0.0 || order_stoploss_28 < price_36) OrderModify(OrderTicket(), A_price_16, price_36, OrderTakeProfit(), 0, SlateGray);
                  }
                  if (OrderType() == OP_SELL) {
                     Li_24 = MathFloor((A_price_16 - Ask) / Point);
                     if (Li_24 < Ad_0) continue;
                     order_stoploss_28 = OrderStopLoss();
                     price_36 = Ask + Ad_8 * Gd_228 * Point;
                     if (order_stoploss_28 == 0.0 || order_stoploss_28 > price_36) OrderModify(OrderTicket(), A_price_16, price_36, OrderTakeProfit(), 0, SpringGreen);
                  }
               }
               Sleep(1000);
            }
         }
      }
   }
}

// 8B746562E009E3A592746A8F1AFB5B72
double f0_21() {
   if (f0_23() == 0) Gd_724 = AccountEquity();
   if (Gd_724 < Gd_732) Gd_724 = Gd_732;
   else Gd_724 = AccountEquity();
   Gd_732 = AccountEquity();
   return (Gd_724);
}

// 5710F6E623305B2C1458238C9757193B
double f0_12() {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0.0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_2 && OrderType() == OP_BUY) {
         ticket_8 = OrderTicket();
         if (ticket_8 > ticket_20) {
            order_open_price_0 = OrderOpenPrice();
            Ld_unused_12 = order_open_price_0;
            ticket_20 = ticket_8;
         }
      }
   }
   return (order_open_price_0);
}

// 2230DA82D7FAFF3EA8CD4CFC92DE64E8
double f0_5() {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0.0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_2 && OrderType() == OP_SELL) {
         ticket_8 = OrderTicket();
         if (ticket_8 > ticket_20) {
            order_open_price_0 = OrderOpenPrice();
            Ld_unused_12 = order_open_price_0;
            ticket_20 = ticket_8;
         }
      }
   }
   return (order_open_price_0);
}

// 90124A87B1714F1FF8E93A2800BD4144
int f0_22(int A_pos_0, int Ai_4, int Ai_8 = 0) {
   if (OrderSelect(A_pos_0, Ai_4, Ai_8) == FALSE) return (0);
   if (OrderMagicNumber() != MagicNumber_1) return (0);
   if (OrderSymbol() != Symbol()) return (0);
   if (Ai_8 != MODE_HISTORY) return (1);
   return (OrderType() <= OP_SELL);
}

// 09CBB5F5CE12C31A043D5C81BF20AA4A
int f0_1(int A_pos_0, int Ai_4, int Ai_8 = 0) {
   if (OrderSelect(A_pos_0, Ai_4, Ai_8) == FALSE) return (0);
   if (OrderMagicNumber() != MagicNumber_2) return (0);
   if (OrderSymbol() != Symbol()) return (0);
   if (Ai_8 != MODE_HISTORY) return (1);
   return (OrderType() <= OP_SELL);
}

// C23BD2D05F1A927B2825264A247F4626
int f0_29(int A_pos_0, int Ai_4, int Ai_8 = 0) {
   if (OrderSelect(A_pos_0, Ai_4, Ai_8) == FALSE) return (0);
   if (OrderMagicNumber() != MagicNumber_3) return (0);
   if (OrderSymbol() != Symbol()) return (0);
   if (Ai_8 != MODE_HISTORY) return (1);
   return (OrderType() <= OP_SELL);
}
