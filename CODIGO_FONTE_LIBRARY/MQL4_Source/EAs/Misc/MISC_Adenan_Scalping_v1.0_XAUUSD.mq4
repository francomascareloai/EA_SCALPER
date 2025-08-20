/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website: h t t p : / / wwW. Me T aq U Ot E S.n Et
   E-mail :  S Up P O R t@m E t aQ UO tes . n eT
*/
#property copyright "Copyright © 2012, Agustinus Adenan"
#property link      "email : sumberku@yahoo.com"

double G_maxlot_76 = 0.0;
string Gs_84 = "Adenanku scalping";
double Gd_92 = 2.0;
string Gs_100 = "Scalping System 1";
int Gi_unused_108 = 1;
extern string __1__ = "Lot Multiplier";
extern double LotMultiplikator = 1.667;
extern string __2__ = " Turn on/off Martingale,  1=on. or 2=off.";
extern int MMType = 1;
bool Gi_140 = TRUE;
double Gd_144;
double G_slippage_152 = 5.0;
extern string __3__ = "Initial lot:";
extern string _____ = "true = Fixed Lot, false = Account Balance";
extern bool LotConst_or_not = FALSE;
extern double Lot = 0.01;
extern double RiskPercent = 30.0;
double Gd_196;
extern string __4__ = "Take Profit in Pips";
extern double TakeProfit = 3.0;
double Gd_220;
double G_pips_228 = 0.0;
double Gd_236 = 10.0;
double Gd_244 = 10.0;
extern string __5__ = "Distance between orders";
extern double Step = 5.0;
double Gd_268;
extern string __6__ = "Max Number of trades";
extern int MaxTrades = 15;
extern string __7__ = "Stop Loss";
extern bool UseEquityStop = FALSE;
extern double TotalEquityRisk = 10.0;
bool Gi_308 = FALSE;
bool Gi_312 = FALSE;
bool Gi_316 = FALSE;
double Gd_320 = 48.0;
bool Gi_328 = FALSE;
int Gi_332 = 2;
int Gi_336 = 16;
extern string __8__ = "Magic Number Must Be Different for Each Chart";
extern int Magic = 1111111;
int Gi_352;
extern string __9__ = "logo and output";
extern bool ShowTableOnTesting = TRUE;
extern string _ = "(true-On.,false-off)";
extern string S1 = " Start End Hour ";
extern int Open_Hour = 22;
extern int Close_Hour = 23;
extern bool TradeOnFriday = FALSE;
extern int Friday_Hour = 15;
double G_price_400;
double Gd_408;
double Gd_unused_416;
double Gd_unused_424;
double G_price_432;
double G_bid_440;
double G_ask_448;
double Gd_456;
double Gd_464;
double Gd_472;
bool Gi_480;
datetime G_time_484 = 0;
int Gi_488;
int Gi_492 = 0;
double Gd_496;
int G_pos_504 = 0;
int Gi_508;
double Gd_512 = 0.0;
bool Gi_520 = FALSE;
bool Gi_524 = FALSE;
bool Gi_528 = FALSE;
int Gi_532;
bool Gi_536 = FALSE;
int G_datetime_540 = 0;
int G_datetime_544 = 0;
double Gd_548;
double Gd_556;
int G_fontsize_564 = 10;
color G_color_568 = White;
color G_color_572 = Gold;
color G_color_576 = White;
int Gi_unused_580 = 5197615;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   Gd_472 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
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
   double order_lots_0;
   double order_lots_8;
   double iclose_16;
   double iclose_24;
   int Li_unused_32 = MarketInfo(Symbol(), MODE_STOPLEVEL);
   int Li_unused_36 = MarketInfo(Symbol(), MODE_SPREAD);
   double point_40 = MarketInfo(Symbol(), MODE_POINT);
   double bid_48 = MarketInfo(Symbol(), MODE_BID);
   double ask_56 = MarketInfo(Symbol(), MODE_ASK);
   int Li_unused_64 = MarketInfo(Symbol(), MODE_DIGITS);
   if (G_maxlot_76 == 0.0) G_maxlot_76 = MarketInfo(Symbol(), MODE_MAXLOT);
   double minlot_68 = MarketInfo(Symbol(), MODE_MINLOT);
   double lotstep_76 = MarketInfo(Symbol(), MODE_LOTSTEP);
   if (((!IsOptimization()) && (!IsTesting()) && (!IsVisualMode())) || (ShowTableOnTesting && IsTesting() && (!IsOptimization()))) {
      f0_13();
      f0_4();
   }
   if (LotConst_or_not) Gd_196 = Lot;
   else Gd_196 = AccountBalance() * RiskPercent / 100.0 / 10000.0;
   if (Gd_196 < minlot_68) Print("Lot size " + Gd_196 + "  less than the minimum trading  " + minlot_68);
   if (Gd_196 > G_maxlot_76 && G_maxlot_76 > 0.0) Print("Lot size  " + Gd_196 + "  beyond the maximum allowed for trade  " + G_maxlot_76);
   Gd_144 = LotMultiplikator;
   Gd_220 = TakeProfit;
   Gd_268 = Step;
   Gi_352 = Magic;
   string Ls_84 = "false";
   string Ls_92 = "false";
   if (Gi_328 == FALSE || (Gi_328 && (Gi_336 > Gi_332 && (Hour() >= Gi_332 && Hour() <= Gi_336)) || (Gi_332 > Gi_336 && (!Hour() >= Gi_336 && Hour() <= Gi_332)))) Ls_84 = "true";
   if (Gi_328 && (Gi_336 > Gi_332 && (!Hour() >= Gi_332 && Hour() <= Gi_336)) || (Gi_332 > Gi_336 && (Hour() >= Gi_336 && Hour() <= Gi_332))) Ls_92 = "true";
   if (Gi_312) f0_17(Gd_236, Gd_244, G_price_432);
   if (Gi_316) {
      if (TimeCurrent() >= Gi_488) {
         f0_8();
         Print("Closed All due to TimeOut");
      }
   }
   if (G_time_484 == Time[0]) return (0);
   G_time_484 = Time[0];
   double Ld_100 = f0_12();
   if (UseEquityStop) {
      if (Ld_100 < 0.0 && MathAbs(Ld_100) > TotalEquityRisk / 100.0 * f0_5()) {
         f0_8();
         Print("Closed All due to Stop Out");
         Gi_536 = FALSE;
      }
   }
   Gi_508 = f0_18();
   if (Gi_508 == 0) Gi_480 = FALSE;
   for (G_pos_504 = OrdersTotal() - 1; G_pos_504 >= 0; G_pos_504--) {
      OrderSelect(G_pos_504, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Gi_352) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_352) {
         if (OrderType() == OP_BUY) {
            Gi_524 = TRUE;
            Gi_528 = FALSE;
            order_lots_0 = OrderLots();
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_352) {
         if (OrderType() == OP_SELL) {
            Gi_524 = FALSE;
            Gi_528 = TRUE;
            order_lots_8 = OrderLots();
            break;
         }
      }
   }
   if (Gi_508 > 0 && Gi_508 <= MaxTrades) {
      RefreshRates();
      Gd_456 = f0_1();
      Gd_464 = f0_15();
      if (Gi_524 && Gd_456 - Ask >= Gd_268 * Point) Gi_520 = TRUE;
      if (Gi_528 && Bid - Gd_464 >= Gd_268 * Point) Gi_520 = TRUE;
   }
   if (Gi_508 < 1) {
      Gi_528 = FALSE;
      Gi_524 = FALSE;
      Gi_520 = TRUE;
      Gd_408 = AccountEquity();
   }
   if (Gi_520) {
      Gd_456 = f0_1();
      Gd_464 = f0_15();
      if (Gi_528) {
         if (Gi_308 || Ls_92 == "true") {
            f0_11(0, 1);
            Gd_496 = NormalizeDouble(Gd_144 * order_lots_8, Gd_92);
         } else Gd_496 = f0_3(OP_SELL);
         if (Gi_140 && Ls_84 == "true") {
            Gi_492 = Gi_508;
            if (Gd_496 > 0.0) {
               RefreshRates();
               Gi_532 = f0_16(1, Gd_496, Bid, G_slippage_152, Ask, 0, 0, Symbol() + "-" + Gs_84 + "-" + Gi_492, Gi_352, 0, HotPink);
               if (Gi_532 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               Gd_464 = f0_15();
               Gi_520 = FALSE;
               Gi_536 = TRUE;
            }
         }
      } else {
         if (Gi_524) {
            if (Gi_308 || Ls_92 == "true") {
               f0_11(1, 0);
               Gd_496 = NormalizeDouble(Gd_144 * order_lots_0, Gd_92);
            } else Gd_496 = f0_3(OP_BUY);
            if (Gi_140 && Ls_84 == "true") {
               Gi_492 = Gi_508;
               if (Gd_496 > 0.0) {
                  Gi_532 = f0_16(0, Gd_496, Ask, G_slippage_152, Bid, 0, 0, Symbol() + "-" + Gs_84 + "-" + Gi_492, Gi_352, 0, Lime);
                  if (Gi_532 < 0) {
                     Print("Error: ", GetLastError());
                     return (0);
                  }
                  Gd_456 = f0_1();
                  Gi_520 = FALSE;
                  Gi_536 = TRUE;
               }
            }
         }
      }
   }
   if (Gi_520 && Gi_508 < 1 && f0_14(Magic) == 1) {
      iclose_16 = iClose(Symbol(), 0, 2);
      iclose_24 = iClose(Symbol(), 0, 1);
      G_bid_440 = Bid;
      G_ask_448 = Ask;
      if ((!Gi_528) && (!Gi_524) && Ls_84 == "true") {
         Gi_492 = Gi_508;
         if (iclose_16 > iclose_24) {
            Gd_496 = f0_3(OP_SELL);
            if (Gd_496 > 0.0) {
               Gi_532 = f0_16(1, Gd_496, G_bid_440, G_slippage_152, G_bid_440, 0, 0, Symbol() + "-" + Gs_84 + "-" + Gi_492, Gi_352, 0, HotPink);
               if (Gi_532 < 0) {
                  Print(Gd_496, "Error: ", GetLastError());
                  return (0);
               }
               Gd_456 = f0_1();
               Gi_536 = TRUE;
            }
         } else {
            Gd_496 = f0_3(OP_BUY);
            if (Gd_496 > 0.0) {
               Gi_532 = f0_16(0, Gd_496, G_ask_448, G_slippage_152, G_ask_448, 0, 0, Symbol() + "-" + Gs_84 + "-" + Gi_492, Gi_352, 0, Lime);
               if (Gi_532 < 0) {
                  Print(Gd_496, "Error: ", GetLastError());
                  return (0);
               }
               Gd_464 = f0_15();
               Gi_536 = TRUE;
            }
         }
      }
      if (Gi_532 > 0) Gi_488 = TimeCurrent() + 60.0 * (60.0 * Gd_320);
      Gi_520 = FALSE;
   }
   Gi_508 = f0_18();
   G_price_432 = 0;
   double Ld_108 = 0;
   for (G_pos_504 = OrdersTotal() - 1; G_pos_504 >= 0; G_pos_504--) {
      OrderSelect(G_pos_504, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Gi_352) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_352) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            G_price_432 += OrderOpenPrice() * OrderLots();
            Ld_108 += OrderLots();
         }
      }
   }
   if (Gi_508 > 0) G_price_432 = NormalizeDouble(G_price_432 / Ld_108, Digits);
   if (Gi_536) {
      for (G_pos_504 = OrdersTotal() - 1; G_pos_504 >= 0; G_pos_504--) {
         OrderSelect(G_pos_504, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != Gi_352) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_352) {
            if (OrderType() == OP_BUY) {
               G_price_400 = G_price_432 + Gd_220 * Point;
               Gd_unused_416 = G_price_400;
               Gd_512 = G_price_432 - G_pips_228 * Point;
               Gi_480 = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_352) {
            if (OrderType() == OP_SELL) {
               G_price_400 = G_price_432 - Gd_220 * Point;
               Gd_unused_424 = G_price_400;
               Gd_512 = G_price_432 + G_pips_228 * Point;
               Gi_480 = TRUE;
            }
         }
      }
   }
   if (Gi_536) {
      if (Gi_480 == TRUE) {
         for (G_pos_504 = OrdersTotal() - 1; G_pos_504 >= 0; G_pos_504--) {
            OrderSelect(G_pos_504, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != Gi_352) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_352) OrderModify(OrderTicket(), G_price_432, OrderStopLoss(), G_price_400, 0, Yellow);
            Gi_536 = FALSE;
         }
      }
   }
   return (0);
}

// 58B0897F29A3AD862616D6CBF39536ED
double f0_6(double Ad_0) {
   return (NormalizeDouble(Ad_0, Digits));
}

// 9B1AEE847CFB597942D106A4135D4FE6
int f0_11(bool Ai_0 = TRUE, bool Ai_4 = TRUE) {
   int Li_ret_8 = 0;
   for (int pos_12 = OrdersTotal() - 1; pos_12 >= 0; pos_12--) {
      if (OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_352) {
            if (OrderType() == OP_BUY && Ai_0) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!OrderClose(OrderTicket(), OrderLots(), f0_6(Bid), 5, CLR_NONE)) {
                     Print("Error close BUY " + OrderTicket());
                     Li_ret_8 = -1;
                  }
               } else {
                  if (G_datetime_540 == iTime(NULL, 0, 0)) return (-2);
                  G_datetime_540 = iTime(NULL, 0, 0);
                  Print("Need close BUY " + OrderTicket() + ". Trade Context Busy");
                  return (-2);
               }
            }
            if (OrderType() == OP_SELL && Ai_4) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!((!OrderClose(OrderTicket(), OrderLots(), f0_6(Ask), 5, CLR_NONE)))) continue;
                  Print("Error close SELL " + OrderTicket());
                  Li_ret_8 = -1;
                  continue;
               }
               if (G_datetime_544 == iTime(NULL, 0, 0)) return (-2);
               G_datetime_544 = iTime(NULL, 0, 0);
               Print("Need close SELL " + OrderTicket() + ". Trade Context Busy");
               return (-2);
            }
         }
      }
   }
   return (Li_ret_8);
}

// 2FC9212C93C86A99B2C376C96453D3A4
double f0_3(int A_cmd_0) {
   double Ld_ret_4;
   int datetime_12;
   switch (MMType) {
   case 0:
      Ld_ret_4 = Gd_196;
      break;
   case 1:
      Ld_ret_4 = NormalizeDouble(Gd_196 * MathPow(Gd_144, Gi_492), Gd_92);
      break;
   case 2:
      datetime_12 = 0;
      Ld_ret_4 = Gd_196;
      for (int pos_20 = OrdersHistoryTotal() - 1; pos_20 >= 0; pos_20--) {
         if (!OrderSelect(pos_20, SELECT_BY_POS, MODE_HISTORY)) return (-3);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_352) {
            if (datetime_12 < OrderCloseTime()) {
               datetime_12 = OrderCloseTime();
               if (OrderProfit() < 0.0) {
                  Ld_ret_4 = NormalizeDouble(OrderLots() * Gd_144, Gd_92);
                  continue;
               }
               Ld_ret_4 = Gd_196;
            }
         }
      }
   }
   if (AccountFreeMarginCheck(Symbol(), A_cmd_0, Ld_ret_4) <= 0.0) return (-1);
   if (GetLastError() == 134/* NOT_ENOUGH_MONEY */) return (-2);
   return (Ld_ret_4);
}

// F7B1F0AA13347699EFAE0D924298CB02
int f0_18() {
   int count_0 = 0;
   for (int pos_4 = OrdersTotal() - 1; pos_4 >= 0; pos_4--) {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Gi_352) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_352)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count_0++;
   }
   return (count_0);
}

// 6ABA3523C7A75AAEA41CC0DEC7953CC5
void f0_8() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_352) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, G_slippage_152, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, G_slippage_152, Red);
         }
         Sleep(1000);
      }
   }
}

// D362D41CFF235C066CFB390D52F4EB13
int f0_16(int Ai_0, double A_lots_4, double A_price_12, int A_slippage_20, double Ad_24, int Ai_unused_32, int Ai_36, string A_comment_40, int A_magic_48, int A_datetime_52, color A_color_56) {
   int ticket_60 = 0;
   int error_64 = 0;
   int count_68 = 0;
   int Li_72 = 100;
   switch (Ai_0) {
   case 2:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_2(Ad_24, G_pips_228), f0_19(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
            A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(1000);
      }
      break;
   case 4:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, A_lots_4, A_price_12, A_slippage_20, f0_2(Ad_24, G_pips_228), f0_19(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
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
         ticket_60 = OrderSend(Symbol(), OP_BUY, A_lots_4, Ask, A_slippage_20, f0_2(Bid, G_pips_228), f0_19(Ask, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 3:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, A_lots_4, A_price_12, A_slippage_20, f0_10(Ad_24, G_pips_228), f0_0(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
            A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 5:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, A_lots_4, A_price_12, A_slippage_20, f0_10(Ad_24, G_pips_228), f0_0(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
            A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELL, A_lots_4, Bid, A_slippage_20, f0_10(Ask, G_pips_228), f0_0(Bid, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
   }
   return (ticket_60);
}

// 28EFB830D150E70A8BB0F12BAC76EF35
double f0_2(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 - Ai_8 * Point);
}

// 945D754CB0DC06D04243FCBA25FC0802
double f0_10(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 + Ai_8 * Point);
}

// FD4055E1AC0A7D690C66D37B2C70E529
double f0_19(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 + Ai_8 * Point);
}

// 09CBB5F5CE12C31A043D5C81BF20AA4A
double f0_0(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 - Ai_8 * Point);
}

// A9B24A824F70CC1232D1C2BA27039E8D
double f0_12() {
   double Ld_ret_0 = 0;
   for (G_pos_504 = OrdersTotal() - 1; G_pos_504 >= 0; G_pos_504--) {
      OrderSelect(G_pos_504, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Gi_352) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_352)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) Ld_ret_0 += OrderProfit();
   }
   return (Ld_ret_0);
}

// F4F2EE5CE6F3F7678B6B3F2A5D4685D7
void f0_17(int Ai_0, int Ai_4, double A_price_8) {
   int Li_16;
   double order_stoploss_20;
   double price_28;
   if (Ai_4 != 0) {
      for (int pos_36 = OrdersTotal() - 1; pos_36 >= 0; pos_36--) {
         if (OrderSelect(pos_36, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != Gi_352) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == Gi_352) {
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

// 5710F6E623305B2C1458238C9757193B
double f0_5() {
   if (f0_18() == 0) Gd_548 = AccountEquity();
   if (Gd_548 < Gd_556) Gd_548 = Gd_556;
   else Gd_548 = AccountEquity();
   Gd_556 = AccountEquity();
   return (Gd_548);
}

// 2569208C5E61CB15E209FFE323DB48B7
double f0_1() {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Gi_352) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_352 && OrderType() == OP_BUY) {
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

// D1DDCE31F1A86B3140880F6B1877CBF8
double f0_15() {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != Gi_352) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Gi_352 && OrderType() == OP_SELL) {
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

// 78BAA8FAE18F93570467778F2E829047
void f0_9() {
   Comment("            Adenan Scalping V1  " + Symbol() + "  " + Period(), 
      "\n", "            Account :", AccountServer(), 
      "\n", "            Lots:  ", Gd_196, 
      "\n", "            Symbol: ", Symbol(), 
      "\n", "            Price:  ", NormalizeDouble(Bid, 4), 
      "\n", "            Date: ", Month(), "-", Day(), "-", Year(), " Server Time: ", Hour(), ":", Minute(), ":", Seconds(), 
      "\n", "            (^_^) HAPPY TRADING, USE THIS FREE EA AT YOUR OWN RISK", 
      "\n", "            EMAIL : sumberku@yahoo.com ", 
   "\n");
}

// AA5EA51BFAC7B64E723BF276E0075513
void f0_13() {
   double Ld_0 = f0_7(0);
   string name_8 = Gs_100 + "1";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 15);
   }
   ObjectSetText(name_8, "Profit Today: " + DoubleToStr(Ld_0, 2), G_fontsize_564, "Courier New", G_color_568);
   Ld_0 = f0_7(1);
   name_8 = Gs_100 + "2";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 33);
   }
   ObjectSetText(name_8, "Profit yesterday : " + DoubleToStr(Ld_0, 2), G_fontsize_564, "Courier New", G_color_568);
   Ld_0 = f0_7(2);
   name_8 = Gs_100 + "3";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 51);
   }
   ObjectSetText(name_8, "Profit before yesterday: " + DoubleToStr(Ld_0, 2), G_fontsize_564, "Courier New", G_color_568);
   name_8 = Gs_100 + "4";
   if (ObjectFind(name_8) == -1) {
      ObjectCreate(name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_8, OBJPROP_CORNER, 1);
      ObjectSet(name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(name_8, OBJPROP_YDISTANCE, 76);
   }
   ObjectSetText(name_8, "Total Balance : " + DoubleToStr(AccountBalance(), 2), G_fontsize_564, "Courier New", G_color_568);
}

// 50257C26C4E5E915F022247BABD914FE
void f0_4() {
   string name_0 = Gs_100 + "L_1";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 350);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 10);
   }
   ObjectSetText(name_0, "ADENAN SCALPING EA", 12, "Arial", G_color_572);
   name_0 = Gs_100 + "L_2";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 350);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 50);
   }
   ObjectSetText(name_0, " S Y S T E M ", 10, "Arial", G_color_572);
   name_0 = Gs_100 + "L_3";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 350);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 75);
   }
   ObjectSetText(name_0, "EMAIL : sumberku@yahoo.com", 10, "Arial", G_color_576);
   name_0 = Gs_100 + "L_4";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 350);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 57);
   }
   ObjectSetText(name_0, "_____________________", 12, "Arial", White);
   name_0 = Gs_100 + "L_5";
   if (ObjectFind(name_0) == -1) {
      ObjectCreate(name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_0, OBJPROP_CORNER, 0);
      ObjectSet(name_0, OBJPROP_XDISTANCE, 350);
      ObjectSet(name_0, OBJPROP_YDISTANCE, 76);
   }
   ObjectSetText(name_0, "_____________________", 12, "Arial", White);
}

// 689C35E4872BA754D7230B8ADAA28E48
double f0_7(int Ai_0) {
   double Ld_ret_4 = 0;
   for (int pos_12 = 0; pos_12 < OrdersHistoryTotal(); pos_12++) {
      if (!(OrderSelect(pos_12, SELECT_BY_POS, MODE_HISTORY))) break;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
         if (OrderCloseTime() >= iTime(Symbol(), PERIOD_D1, Ai_0) && OrderCloseTime() < iTime(Symbol(), PERIOD_D1, Ai_0) + 86400) Ld_ret_4 = Ld_ret_4 + OrderProfit() + OrderCommission() + OrderSwap();
   }
   return (Ld_ret_4);
}

// C5B2595DCE0154956AB7468CF03770D7
int f0_14(int Ai_unused_0) {
   bool Li_ret_4 = TRUE;
   if ((!TradeOnFriday) && DayOfWeek() == 5) Li_ret_4 = FALSE;
   if (TradeOnFriday && DayOfWeek() == 5 && TimeHour(TimeCurrent()) > Friday_Hour) Li_ret_4 = FALSE;
   if (Open_Hour == 24) Open_Hour = 0;
   if (Close_Hour == 24) Close_Hour = 0;
   if (Open_Hour < Close_Hour && TimeHour(TimeCurrent()) < Open_Hour || TimeHour(TimeCurrent()) >= Close_Hour) Li_ret_4 = FALSE;
   if (Open_Hour > Close_Hour && (TimeHour(TimeCurrent()) < Open_Hour && TimeHour(TimeCurrent()) >= Close_Hour)) Li_ret_4 = FALSE;
   return (Li_ret_4);
}
