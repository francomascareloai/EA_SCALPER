/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website: htTP:/ /w WW. me TAQ U O t E S. Ne T
   E-mail : sU p P o R T@ Me t A q uO tE s.ne t
*/
#property copyright "Copyright © 2012, invest-system.net"
#property link      "invest-system.net"

int G_acc_number_76 = 62249064;
double G_maxlot_80 = 0.0;
string Gs_88 = "AP_v.3.0";
double Gd_96 = 2.0;
string Gs_104 = "AutoP_v.3.0";
int Gi_unused_112 = 1;
extern string __1__ = " МАРТИН 1 - вкл. 2 - выкл.";
extern int MMType = 1;
bool Gi_128 = TRUE;
extern string __2__ = "множитель след. лота";
extern double LotMultiplikator = 1.667;
double Gd_148;
double G_slippage_156 = 5.0;
extern string __3__ = "начальный лот:";
extern string _____ = "true - постоянный, false - от баланса";
extern bool LotConst_or_not = FALSE;
extern double Lot = 0.01;
extern double RiskPercent = 30.0;
double Gd_200;
extern string __4__ = "прибыль в пунктах - ТР";
extern double TakeProfit = 5.0;
double Gd_224;
double G_pips_232 = 0.0;
double Gd_240 = 10.0;
double Gd_248 = 10.0;
extern string __5__ = "расстояние м/у ордерами";
extern double Step = 5.0;
double Gd_272;
extern string __6__ = "МАX кол-во ордеров";
extern int MaxTrades = 30;
extern string __7__ = "Ограничение потерь";
extern bool UseEquityStop = FALSE;
extern double TotalEquityRisk = 20.0;
bool Gi_312 = FALSE;
bool Gi_316 = FALSE;
bool Gi_320 = FALSE;
double Gd_324 = 48.0;
bool Gi_332 = FALSE;
int Gi_336 = 2;
int Gi_340 = 16;
extern string __8__ = "Идентификатор ордера";
extern int Magic = 1111111;
int Gi_356;
extern string __9__ = "логотип и вывод данных";
extern bool ShowTableOnTesting = TRUE;
extern string _ = "(true-вкл.,false-выкл.)";
double G_price_380;
double Gd_388;
double Gd_unused_396;
double Gd_unused_404;
double G_price_412;
double G_bid_420;
double G_ask_428;
double Gd_436;
double Gd_444;
double Gd_452;
bool Gi_460;
datetime G_time_464 = 0;
int Gi_468;
int Gi_472 = 0;
double Gd_476;
int G_pos_484 = 0;
int Gi_488;
double Gd_492 = 0.0;
bool Gi_500 = FALSE;
bool Gi_504 = FALSE;
bool Gi_508 = FALSE;
int Gi_512;
bool Gi_516 = FALSE;
int G_datetime_520 = 0;
int G_datetime_524 = 0;
double Gd_528;
double Gd_536;
int G_fontsize_544 = 14;
color G_color_548 = Gold;
color G_color_552 = Orange;
color G_color_556 = Gray;
int Gi_unused_560 = 5197615;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   Gd_452 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   if (IsTesting() == TRUE) f0_9();
   if (IsTesting() == FALSE) f0_9();
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   double order_lots_52;
   double order_lots_60;
   double iclose_68;
   double iclose_76;
   int Li_unused_0 = MarketInfo(Symbol(), MODE_STOPLEVEL);
   int Li_unused_4 = MarketInfo(Symbol(), MODE_SPREAD);
   double point_8 = MarketInfo(Symbol(), MODE_POINT);
   double bid_16 = MarketInfo(Symbol(), MODE_BID);
   double ask_24 = MarketInfo(Symbol(), MODE_ASK);
   int Li_unused_32 = MarketInfo(Symbol(), MODE_DIGITS);
   if (G_maxlot_80 == 0.0) G_maxlot_80 = MarketInfo(Symbol(), MODE_MAXLOT);
   double minlot_36 = MarketInfo(Symbol(), MODE_MINLOT);
   double lotstep_44 = MarketInfo(Symbol(), MODE_LOTSTEP);
   if (AccountNumber() != G_acc_number_76 && (!IsDemo())) {
      Comment("Советник может работать только на счёте " + G_acc_number_76 + ", для бесплатного подключения к другому счёту перейдите на сайт invest-system.net");
      Sleep(1000);
      Print("Советник может работать только на счёте " + G_acc_number_76 + ", для подключения к другому счёту проидите на сайт invest-system.net");
      return;
   }
   if (((!IsOptimization()) && (!IsTesting()) && (!IsVisualMode())) || (ShowTableOnTesting && IsTesting() && (!IsOptimization()))) {
      f0_13();
      f0_10();
   }
   if (LotConst_or_not) Gd_200 = Lot;
   else Gd_200 = AccountBalance() * RiskPercent / 100.0 / 10000.0;
   if (Gd_200 < minlot_36) Print("Расчетный лот  " + Gd_200 + "  меньше минимально допустимого для торговли  " + minlot_36);
   if (Gd_200 > G_maxlot_80 && G_maxlot_80 > 0.0) Print("Расчетный лот  " + Gd_200 + "  больше максимально допустимого для торговли  " + G_maxlot_80);
   Gd_148 = LotMultiplikator;
   Gd_224 = TakeProfit;
   Gd_272 = Step;
   Gi_356 = Magic;
   string Ls_84 = "false";
   string Ls_92 = "false";
   if (Gi_332 == FALSE || (Gi_332 && (Gi_340 > Gi_336 && (Hour() >= Gi_336 && Hour() <= Gi_340)) || (Gi_336 > Gi_340 && (!Hour() >= Gi_340 && Hour() <= Gi_336)))) Ls_84 = "true";
   if (Gi_332 && (Gi_340 > Gi_336 && (!Hour() >= Gi_336 && Hour() <= Gi_340)) || (Gi_336 > Gi_340 && (Hour() >= Gi_340 && Hour() <= Gi_336))) Ls_92 = "true";
   if (Gi_316) f0_18(Gd_240, Gd_248, G_price_412);
   if (Gi_320) {
      if (TimeCurrent() >= Gi_468) {
         f0_3();
         Print("Closed All due to TimeOut");
      }
   }
   if (G_time_464 == Time[0]) return (0);
   G_time_464 = Time[0];
   double Ld_100 = f0_5();
   if (UseEquityStop) {
      if (Ld_100 < 0.0 && MathAbs(Ld_100) > TotalEquityRisk / 100.0 * f0_7()) {
         f0_3();
         Print("Closed All due to Stop Out");
         Gi_516 = FALSE;
      }
   }
   Gi_488 = f0_16();
   if (Gi_488 == 0) Gi_460 = FALSE;
   for (G_pos_484 = OrdersTotal() - 1; G_pos_484 >= 0; G_pos_484--) {
      OrderSelect(G_pos_484, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Gi_356) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_356) {
         if (OrderType() == OP_BUY) {
            Gi_504 = TRUE;
            Gi_508 = FALSE;
            order_lots_52 = OrderLots();
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_356) {
         if (OrderType() == OP_SELL) {
            Gi_504 = FALSE;
            Gi_508 = TRUE;
            order_lots_60 = OrderLots();
            break;
         }
      }
   }
   if (Gi_488 > 0 && Gi_488 <= MaxTrades) {
      RefreshRates();
      Gd_436 = f0_2();
      Gd_444 = f0_6();
      if (Gi_504 && Gd_436 - Ask >= Gd_272 * Point) Gi_500 = TRUE;
      if (Gi_508 && Bid - Gd_444 >= Gd_272 * Point) Gi_500 = TRUE;
   }
   if (Gi_488 < 1) {
      Gi_508 = FALSE;
      Gi_504 = FALSE;
      Gi_500 = TRUE;
      Gd_388 = AccountEquity();
   }
   if (Gi_500) {
      Gd_436 = f0_2();
      Gd_444 = f0_6();
      if (Gi_508) {
         if (Gi_312 || Ls_92 == "true") {
            f0_1(0, 1);
            Gd_476 = NormalizeDouble(Gd_148 * order_lots_60, Gd_96);
         } else Gd_476 = f0_14(OP_SELL);
         if (Gi_128 && Ls_84 == "true") {
            Gi_472 = Gi_488;
            if (Gd_476 > 0.0) {
               RefreshRates();
               Gi_512 = f0_15(1, Gd_476, Bid, G_slippage_156, Ask, 0, 0, Symbol() + "-" + Gs_88 + "-" + Gi_472, Gi_356, 0, HotPink);
               if (Gi_512 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               Gd_444 = f0_6();
               Gi_500 = FALSE;
               Gi_516 = TRUE;
            }
         }
      } else {
         if (Gi_504) {
            if (Gi_312 || Ls_92 == "true") {
               f0_1(1, 0);
               Gd_476 = NormalizeDouble(Gd_148 * order_lots_52, Gd_96);
            } else Gd_476 = f0_14(OP_BUY);
            if (Gi_128 && Ls_84 == "true") {
               Gi_472 = Gi_488;
               if (Gd_476 > 0.0) {
                  Gi_512 = f0_15(0, Gd_476, Ask, G_slippage_156, Bid, 0, 0, Symbol() + "-" + Gs_88 + "-" + Gi_472, Gi_356, 0, Lime);
                  if (Gi_512 < 0) {
                     Print("Error: ", GetLastError());
                     return (0);
                  }
                  Gd_436 = f0_2();
                  Gi_500 = FALSE;
                  Gi_516 = TRUE;
               }
            }
         }
      }
   }
   if (Gi_500 && Gi_488 < 1) {
      iclose_68 = iClose(Symbol(), 0, 2);
      iclose_76 = iClose(Symbol(), 0, 1);
      G_bid_420 = Bid;
      G_ask_428 = Ask;
      if ((!Gi_508) && (!Gi_504) && Ls_84 == "true") {
         Gi_472 = Gi_488;
         if (iclose_68 > iclose_76) {
            Gd_476 = f0_14(OP_SELL);
            if (Gd_476 > 0.0) {
               Gi_512 = f0_15(1, Gd_476, G_bid_420, G_slippage_156, G_bid_420, 0, 0, Symbol() + "-" + Gs_88 + "-" + Gi_472, Gi_356, 0, HotPink);
               if (Gi_512 < 0) {
                  Print(Gd_476, "Error: ", GetLastError());
                  return (0);
               }
               Gd_436 = f0_2();
               Gi_516 = TRUE;
            }
         } else {
            Gd_476 = f0_14(OP_BUY);
            if (Gd_476 > 0.0) {
               Gi_512 = f0_15(0, Gd_476, G_ask_428, G_slippage_156, G_ask_428, 0, 0, Symbol() + "-" + Gs_88 + "-" + Gi_472, Gi_356, 0, Lime);
               if (Gi_512 < 0) {
                  Print(Gd_476, "Error: ", GetLastError());
                  return (0);
               }
               Gd_444 = f0_6();
               Gi_516 = TRUE;
            }
         }
      }
      if (Gi_512 > 0) Gi_468 = TimeCurrent() + 60.0 * (60.0 * Gd_324);
      Gi_500 = FALSE;
   }
   Gi_488 = f0_16();
   G_price_412 = 0;
   double Ld_108 = 0;
   for (G_pos_484 = OrdersTotal() - 1; G_pos_484 >= 0; G_pos_484--) {
      OrderSelect(G_pos_484, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Gi_356) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_356) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            G_price_412 += OrderOpenPrice() * OrderLots();
            Ld_108 += OrderLots();
         }
      }
   }
   if (Gi_488 > 0) G_price_412 = NormalizeDouble(G_price_412 / Ld_108, Digits);
   if (Gi_516) {
      for (G_pos_484 = OrdersTotal() - 1; G_pos_484 >= 0; G_pos_484--) {
         OrderSelect(G_pos_484, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Gi_356) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_356) {
            if (OrderType() == OP_BUY) {
               G_price_380 = G_price_412 + Gd_224 * Point;
               Gd_unused_396 = G_price_380;
               Gd_492 = G_price_412 - G_pips_232 * Point;
               Gi_460 = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_356) {
            if (OrderType() == OP_SELL) {
               G_price_380 = G_price_412 - Gd_224 * Point;
               Gd_unused_404 = G_price_380;
               Gd_492 = G_price_412 + G_pips_232 * Point;
               Gi_460 = TRUE;
            }
         }
      }
   }
   if (Gi_516) {
      if (Gi_460 == TRUE) {
         for (G_pos_484 = OrdersTotal() - 1; G_pos_484 >= 0; G_pos_484--) {
            OrderSelect(G_pos_484, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != Gi_356) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_356) OrderModify(OrderTicket(), G_price_412, OrderStopLoss(), G_price_380, 0, Yellow);
            Gi_516 = FALSE;
         }
      }
   }
   return (0);
}

// 9A116C50D133C8648404081885194300
double f0_11(double Ad_0) {
   return (NormalizeDouble(Ad_0, Digits));
}

// 169720DB8C7DA7F48F483E787B4A2725
int f0_1(bool Ai_0 = TRUE, bool Ai_4 = TRUE) {
   int Li_ret_8 = 0;
   for (int pos_12 = OrdersTotal() - 1; pos_12 >= 0; pos_12--) {
      if (OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_356) {
            if (OrderType() == OP_BUY && Ai_0) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!OrderClose(OrderTicket(), OrderLots(), f0_11(Bid), 5, CLR_NONE)) {
                     Print("Error close BUY " + OrderTicket());
                     Li_ret_8 = -1;
                  }
               } else {
                  if (G_datetime_520 == iTime(NULL, 0, 0)) return (-2);
                  G_datetime_520 = iTime(NULL, 0, 0);
                  Print("Need close BUY " + OrderTicket() + ". Trade Context Busy");
                  return (-2);
               }
            }
            if (OrderType() == OP_SELL && Ai_4) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!(!OrderClose(OrderTicket(), OrderLots(), f0_11(Ask), 5, CLR_NONE))) continue;
                  Print("Error close SELL " + OrderTicket());
                  Li_ret_8 = -1;
                  continue;
               }
               if (G_datetime_524 == iTime(NULL, 0, 0)) return (-2);
               G_datetime_524 = iTime(NULL, 0, 0);
               Print("Need close SELL " + OrderTicket() + ". Trade Context Busy");
               return (-2);
            }
         }
      }
   }
   return (Li_ret_8);
}

// BD1F338B493E3233DF78411E167716E8
double f0_14(int A_cmd_0) {
   double Ld_ret_4;
   int datetime_12;
   switch (MMType) {
   case 0:
      Ld_ret_4 = Gd_200;
      break;
   case 1:
      Ld_ret_4 = NormalizeDouble(Gd_200 * MathPow(Gd_148, Gi_472), Gd_96);
      break;
   case 2:
      datetime_12 = 0;
      Ld_ret_4 = Gd_200;
      for (int pos_20 = OrdersHistoryTotal() - 1; pos_20 >= 0; pos_20--) {
         if (OrderSelect(pos_20, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_356) {
               if (datetime_12 < OrderCloseTime()) {
                  datetime_12 = OrderCloseTime();
                  if (OrderProfit() < 0.0) {
                     Ld_ret_4 = NormalizeDouble(OrderLots() * Gd_148, Gd_96);
                     continue;
                  }
                  Ld_ret_4 = Gd_200;
               }
            }
         } else return (-3);
      }
   }
   if (AccountFreeMarginCheck(Symbol(), A_cmd_0, Ld_ret_4) <= 0.0) return (-1);
   if (GetLastError() == 134/* NOT_ENOUGH_MONEY */) return (-2);
   return (Ld_ret_4);
}

// CBBD1151F6D49BC6C817A0B96D15036D
int f0_16() {
   int count_0 = 0;
   for (int pos_4 = OrdersTotal() - 1; pos_4 >= 0; pos_4--) {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Gi_356) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_356)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count_0++;
   }
   return (count_0);
}

// 41BB59E8D36C416E4C62910D9E765220
void f0_3() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_356) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, G_slippage_156, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, G_slippage_156, Red);
         }
         Sleep(1000);
      }
   }
}

// C159FD8BED695B6E6A109D3B72C199C3
int f0_15(int Ai_0, double A_lots_4, double A_price_12, int A_slippage_20, double Ad_24, int Ai_unused_32, int Ai_36, string A_comment_40, int A_magic_48, int A_datetime_52, color A_color_56) {
   int ticket_60 = 0;
   int error_64 = 0;
   int count_68 = 0;
   int Li_72 = 100;
   switch (Ai_0) {
   case 2:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_12(Ad_24, G_pips_232), f0_17(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
            A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(1000);
      }
      break;
   case 4:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, A_lots_4, A_price_12, A_slippage_20, f0_12(Ad_24, G_pips_232), f0_17(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
            A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 0:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         RefreshRates();
         ticket_60 = OrderSend(Symbol(), OP_BUY, A_lots_4, Ask, A_slippage_20, f0_12(Bid, G_pips_232), f0_17(Ask, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 3:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_0(Ad_24, G_pips_232), f0_4(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
            A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 5:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, A_lots_4, A_price_12, A_slippage_20, f0_0(Ad_24, G_pips_232), f0_4(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
            A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELL, A_lots_4, Bid, A_slippage_20, f0_0(Ask, G_pips_232), f0_4(Bid, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
   }
   return (ticket_60);
}

// A04259EF619300E271488B8ABD9DF8A9
double f0_12(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 - Ai_8 * Point);
}

// 0D578CA46072792DE50D5B9F5F5F8784
double f0_0(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 + Ai_8 * Point);
}

// CE75B31DDDC1519B313C4C612EF22D86
double f0_17(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 + Ai_8 * Point);
}

// 4347D7B92E8469B198EAA742F66BBE62
double f0_4(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 - Ai_8 * Point);
}

// 4A186EA1A04A05E39FD2E7A94BB28576
double f0_5() {
   double Ld_ret_0 = 0;
   for (G_pos_484 = OrdersTotal() - 1; G_pos_484 >= 0; G_pos_484--) {
      OrderSelect(G_pos_484, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Gi_356) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_356)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) Ld_ret_0 += OrderProfit();
   }
   return (Ld_ret_0);
}

// FDD5E0C68EEEAC73C07299767285F173
void f0_18(int Ai_0, int Ai_4, double A_price_8) {
   int Li_16;
   double order_stoploss_20;
   double price_28;
   if (Ai_4 != 0) {
      for (int pos_36 = OrdersTotal() - 1; pos_36 >= 0; pos_36--) {
         if (OrderSelect(pos_36, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != Gi_356) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == Gi_356) {
               if (OrderType() == OP_BUY) {
                  Li_16 = NormalizeDouble((Bid - A_price_8) / Point, 0);
                  if (Li_16 < Ai_0) continue;
                  order_stoploss_20 = OrderStopLoss();
                  price_28 = Bid - Ai_4 * Point;
                  if (order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 > order_stoploss_20)) OrderModify(OrderTicket(), A_price_8, price_28, OrderTakeProfit(), 0, Aqua);
               }
               if (OrderType() == OP_SELL) {
                  Li_16 = NormalizeDouble((A_price_8 - Ask) / Point, 0);
                  if (Li_16 < Ai_0) continue;
                  order_stoploss_20 = OrderStopLoss();
                  price_28 = Ask + Ai_4 * Point;
                  if (order_stoploss_20 == 0.0 || (order_stoploss_20 != 0.0 && price_28 < order_stoploss_20)) OrderModify(OrderTicket(), A_price_8, price_28, OrderTakeProfit(), 0, Red);
               }
            }
            Sleep(1000);
         }
      }
   }
}

// 91C97865111C4DD6B44C584F4B9358BB
double f0_7() {
   if (f0_16() == 0) Gd_528 = AccountEquity();
   if (Gd_528 < Gd_536) Gd_528 = Gd_536;
   else Gd_528 = AccountEquity();
   Gd_536 = AccountEquity();
   return (Gd_528);
}

// 262336F736ADFEEC641C03BB3514631C
double f0_2() {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Gi_356) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_356 && OrderType() == OP_BUY) {
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

// 599A26C25DF2561FBAA884F47E1B315C
double f0_6() {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Gi_356) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_356 && OrderType() == OP_SELL) {
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

// 938363B042E987609BD8B876255B9679
void f0_9() {
   Comment("            AutoProfit v.3.0  " + Symbol() + "  " + Period(), 
      "\n", "            Forex Account Server:", AccountServer(), 
      "\n", "            Lots:  ", Gd_200, 
      "\n", "            Symbol: ", Symbol(), 
      "\n", "            Price:  ", NormalizeDouble(Bid, 4), 
      "\n", "            Date: ", Month(), "-", Day(), "-", Year(), " Server Time: ", Hour(), ":", Minute(), ":", Seconds(), 
   "\n");
}

// B53A5EDA65DD2C5C76918FE4BE35941D
void f0_13() {
   double Ld_0 = f0_8(0);
   string name_8 = Gs_104 + "1";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 15);
   }
   ObjectSetText(name_8, "Заработок сегодня: " + DoubleToStr(Ld_0, 2), G_fontsize_544, "Courier New", G_color_548);
   Ld_0 = f0_8(1);
   name_8 = Gs_104 + "2";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 33);
   }
   ObjectSetText(name_8, "Заработок вчера: " + DoubleToStr(Ld_0, 2), G_fontsize_544, "Courier New", G_color_548);
   Ld_0 = f0_8(2);
   name_8 = Gs_104 + "3";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 51);
   }
   ObjectSetText(name_8, "Заработок позавчера: " + DoubleToStr(Ld_0, 2), G_fontsize_544, "Courier New", G_color_548);
   name_8 = Gs_104 + "4";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 76);
   }
   ObjectSetText(name_8, "Баланс : " + DoubleToStr(AccountBalance(), 2), G_fontsize_544, "Courier New", G_color_548);
}

// 97265C974964F68E43402B476A8AA8AB
void f0_10() {
   string name_0 = Gs_104 + "L_1";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 390);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 10);
   }
   ObjectSetText(name_0, "I N V E S T", 28, "Arial", G_color_552);
   name_0 = Gs_104 + "L_2";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 382);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 50);
   }
   ObjectSetText(name_0, "  S Y S T E M", 16, "Arial", G_color_552);
   name_0 = Gs_104 + "L_3";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 397);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 75);
   }
   ObjectSetText(name_0, "www.invest-system.net", 12, "Arial", G_color_556);
   name_0 = Gs_104 + "L_4";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 382);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 57);
   }
   ObjectSetText(name_0, "_____________________", 12, "Arial", Gray);
   name_0 = Gs_104 + "L_5";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 382);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 76);
   }
   ObjectSetText(name_0, "_____________________", 12, "Arial", Gray);
}

// 92106D273A87E0D4E98361E7DB777FFA
double f0_8(int Ai_0) {
   double Ld_ret_4 = 0;
   for (int pos_12 = 0; pos_12 < OrdersHistoryTotal(); pos_12++) {
      if (!(OrderSelect(pos_12, SELECT_BY_POS, MODE_HISTORY))) break;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
         if (OrderCloseTime() >= iTime(Symbol(), PERIOD_D1, Ai_0) && OrderCloseTime() < iTime(Symbol(), PERIOD_D1, Ai_0) + 86400) Ld_ret_4 = Ld_ret_4 + OrderProfit() + OrderCommission() + OrderSwap();
   }
   return (Ld_ret_4);
}