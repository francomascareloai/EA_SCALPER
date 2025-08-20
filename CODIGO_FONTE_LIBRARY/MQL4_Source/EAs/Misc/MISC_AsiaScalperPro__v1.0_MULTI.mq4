/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website: h t T p://W wW . M e T AqU o t E S . net
   E-mail : S U pP Ort @mEt aQ u oTES.nE t
*/

double Gd_76 = 1.6;
extern double Lots = 0.01;
extern double TakeProfit = 24.0;
double G_pips_100 = 5.0;
extern bool UseTrailing = FALSE;
extern double TrailStart = 35.0;
extern double TrailStop = 49.0;
extern int MaxCountOrders = 10;
extern bool SafeEquity = FALSE;
extern double SafeEquityRisk = 10.0;
extern double slippage = 3.0;
extern int MagicNumber = 12469;
bool Gi_156 = FALSE;
double Gd_160 = 48.0;
double G_pips_168 = 500.0;
double Gd_176 = 0.0;
bool Gi_184 = TRUE;
bool Gi_188 = FALSE;
int Gi_192 = 1;
double G_price_196;
double Gd_204;
double Gd_unused_212;
double Gd_unused_220;
double G_price_228;
double G_bid_236;
double G_ask_244;
double Gd_252;
double Gd_260;
double Gd_268;
bool Gi_276;
string Gs_280 = "Take Profit";
datetime G_time_288 = 0;
int Gi_292;
int Gi_296 = 0;
double Gd_300;
int G_pos_308 = 0;
int Gi_312;
double Gd_316 = 0.0;
bool Gi_324 = FALSE;
bool Gi_328 = FALSE;
bool Gi_332 = FALSE;
int Gi_336;
bool Gi_340 = FALSE;
int G_datetime_344 = 0;
int G_datetime_348 = 0;
double Gd_352;
double Gd_360;

int init() {
   Gd_268 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   switch (MarketInfo(Symbol(), MODE_MINLOT)) {
   case 0.001:
      Gd_176 = 3;
      break;
   case 0.01:
      Gd_176 = 2;
      break;
   case 0.1:
      Gd_176 = 1;
      break;
   case 1.0:
      Gd_176 = 0;
   }
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   double order_lots_0;
   double order_lots_8;
   double iclose_16;
   double iclose_24;
   if (UseTrailing) TrailingAlls(TrailStart, TrailStop, G_price_228);
   if (Gi_156) {
      if (TimeCurrent() >= Gi_292) {
         CloseThisSymbolAll();
         Print("Closed All due to TimeOut");
      }
   }
   if (G_time_288 == Time[0]) return (0);
   G_time_288 = Time[0];
   double Ld_32 = CalculateProfit();
   if (SafeEquity) {
      if (Ld_32 < 0.0 && MathAbs(Ld_32) > SafeEquityRisk / 100.0 * AccountEquityHigh()) {
         CloseThisSymbolAll();
         Print("Closed All due to Stop Out");
         Gi_340 = FALSE;
      }
   }
   Gi_312 = CountTrades();
   if (Gi_312 == 0) Gi_276 = FALSE;
   for (G_pos_308 = OrdersTotal() - 1; G_pos_308 >= 0; G_pos_308--) {
      OrderSelect(G_pos_308, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         if (OrderType() == OP_BUY) {
            Gi_328 = TRUE;
            Gi_332 = FALSE;
            order_lots_0 = OrderLots();
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         if (OrderType() == OP_SELL) {
            Gi_328 = FALSE;
            Gi_332 = TRUE;
            order_lots_8 = OrderLots();
            break;
         }
      }
   }
   if (Gi_312 > 0 && Gi_312 <= MaxCountOrders) {
      RefreshRates();
      Gd_252 = FindLastBuyPrice();
      Gd_260 = FindLastSellPrice();
      if (Gi_328 && Gd_252 - Ask >= G_pips_100 * Point) Gi_324 = TRUE;
      if (Gi_332 && Bid - Gd_260 >= G_pips_100 * Point) Gi_324 = TRUE;
   }
   if (Gi_312 < 1) {
      Gi_332 = FALSE;
      Gi_328 = FALSE;
      Gi_324 = TRUE;
      Gd_204 = AccountEquity();
   }
   if (Gi_324) {
      Gd_252 = FindLastBuyPrice();
      Gd_260 = FindLastSellPrice();
      if (Gi_332) {
         if (Gi_188) {
            fOrderCloseMarket(0, 1);
            Gd_300 = NormalizeDouble(Gd_76 * order_lots_8, Gd_176);
         } else Gd_300 = fGetLots(OP_SELL);
         if (Gi_184) {
            Gi_296 = Gi_312;
            if (Gd_300 > 0.0) {
               RefreshRates();
               Gi_336 = OpenPendingOrder(1, Gd_300, Bid, slippage, Ask, 0, 0, Gs_280 + "-" + Gi_296, MagicNumber, 0, HotPink);
               if (Gi_336 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               Gd_260 = FindLastSellPrice();
               Gi_324 = FALSE;
               Gi_340 = TRUE;
            }
         }
      } else {
         if (Gi_328) {
            if (Gi_188) {
               fOrderCloseMarket(1, 0);
               Gd_300 = NormalizeDouble(Gd_76 * order_lots_0, Gd_176);
            } else Gd_300 = fGetLots(OP_BUY);
            if (Gi_184) {
               Gi_296 = Gi_312;
               if (Gd_300 > 0.0) {
                  Gi_336 = OpenPendingOrder(0, Gd_300, Ask, slippage, Bid, 0, 0, Gs_280 + "-" + Gi_296, MagicNumber, 0, Lime);
                  if (Gi_336 < 0) {
                     Print("Error: ", GetLastError());
                     return (0);
                  }
                  Gd_252 = FindLastBuyPrice();
                  Gi_324 = FALSE;
                  Gi_340 = TRUE;
               }
            }
         }
      }
   }
   if (Gi_324 && Gi_312 < 1) {
      iclose_16 = iClose(Symbol(), 0, 2);
      iclose_24 = iClose(Symbol(), 0, 1);
      G_bid_236 = Bid;
      G_ask_244 = Ask;
      if ((!Gi_332) && (!Gi_328)) {
         Gi_296 = Gi_312;
         if (iclose_16 > iclose_24) {
            Gd_300 = fGetLots(OP_SELL);
            if (Gd_300 > 0.0) {
               Gi_336 = OpenPendingOrder(1, Gd_300, G_bid_236, slippage, G_bid_236, 0, 0, Gs_280 + " " + MagicNumber + "-" + Gi_296, MagicNumber, 0, HotPink);
               if (Gi_336 < 0) {
                  Print(Gd_300, "Error: ", GetLastError());
                  return (0);
               }
               Gd_252 = FindLastBuyPrice();
               Gi_340 = TRUE;
            }
         } else {
            Gd_300 = fGetLots(OP_BUY);
            if (Gd_300 > 0.0) {
               Gi_336 = OpenPendingOrder(0, Gd_300, G_ask_244, slippage, G_ask_244, 0, 0, Gs_280 + " " + MagicNumber + "-" + Gi_296, MagicNumber, 0, Lime);
               if (Gi_336 < 0) {
                  Print(Gd_300, "Error: ", GetLastError());
                  return (0);
               }
               Gd_260 = FindLastSellPrice();
               Gi_340 = TRUE;
            }
         }
      }
      if (Gi_336 > 0) Gi_292 = TimeCurrent() + 60.0 * (60.0 * Gd_160);
      Gi_324 = FALSE;
   }
   Gi_312 = CountTrades();
   G_price_228 = 0;
   double Ld_40 = 0;
   for (G_pos_308 = OrdersTotal() - 1; G_pos_308 >= 0; G_pos_308--) {
      OrderSelect(G_pos_308, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            G_price_228 += OrderOpenPrice() * OrderLots();
            Ld_40 += OrderLots();
         }
      }
   }
   if (Gi_312 > 0) G_price_228 = NormalizeDouble(G_price_228 / Ld_40, Digits);
   if (Gi_340) {
      for (G_pos_308 = OrdersTotal() - 1; G_pos_308 >= 0; G_pos_308--) {
         OrderSelect(G_pos_308, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_BUY) {
               G_price_196 = G_price_228 + TakeProfit * Point;
               Gd_unused_212 = G_price_196;
               Gd_316 = G_price_228 - G_pips_168 * Point;
               Gi_276 = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_SELL) {
               G_price_196 = G_price_228 - TakeProfit * Point;
               Gd_unused_220 = G_price_196;
               Gd_316 = G_price_228 + G_pips_168 * Point;
               Gi_276 = TRUE;
            }
         }
      }
   }
   if (Gi_340) {
      if (Gi_276 == TRUE) {
         for (G_pos_308 = OrdersTotal() - 1; G_pos_308 >= 0; G_pos_308--) {
            OrderSelect(G_pos_308, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) OrderModify(OrderTicket(), G_price_228, OrderStopLoss(), G_price_196, 0, Yellow);
            Gi_340 = FALSE;
         }
      }
   }
   return (0);
}

double ND(double Ad_0) {
   return (NormalizeDouble(Ad_0, Digits));
}

int fOrderCloseMarket(bool Ai_0 = TRUE, bool Ai_4 = TRUE) {
   int Li_ret_8 = 0;
   for (int pos_12 = OrdersTotal() - 1; pos_12 >= 0; pos_12--) {
      if (OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_BUY && Ai_0) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!OrderClose(OrderTicket(), OrderLots(), ND(Bid), 5, CLR_NONE)) {
                     Print("Error close BUY " + OrderTicket());
                     Li_ret_8 = -1;
                  }
               } else {
                  if (G_datetime_344 == iTime(NULL, 0, 0)) return (-2);
                  G_datetime_344 = iTime(NULL, 0, 0);
                  Print("Need close BUY " + OrderTicket() + ". Trade Context Busy");
                  return (-2);
               }
            }
            if (OrderType() == OP_SELL && Ai_4) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!(!OrderClose(OrderTicket(), OrderLots(), ND(Ask), 5, CLR_NONE))) continue;
                  Print("Error close SELL " + OrderTicket());
                  Li_ret_8 = -1;
                  continue;
               }
               if (G_datetime_348 == iTime(NULL, 0, 0)) return (-2);
               G_datetime_348 = iTime(NULL, 0, 0);
               Print("Need close SELL " + OrderTicket() + ". Trade Context Busy");
               return (-2);
            }
         }
      }
   }
   return (Li_ret_8);
}

double fGetLots(int A_cmd_0) {
   double lots_4;
   int datetime_12;
   switch (Gi_192) {
   case 0:
      lots_4 = Lots;
      break;
   case 1:
      lots_4 = NormalizeDouble(Lots * MathPow(Gd_76, Gi_296), Gd_176);
      break;
   case 2:
      datetime_12 = 0;
      lots_4 = Lots;
      for (int pos_20 = OrdersHistoryTotal() - 1; pos_20 >= 0; pos_20--) {
         if (OrderSelect(pos_20, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
               if (datetime_12 < OrderCloseTime()) {
                  datetime_12 = OrderCloseTime();
                  if (OrderProfit() < 0.0) {
                     lots_4 = NormalizeDouble(OrderLots() * Gd_76, Gd_176);
                     continue;
                  }
                  lots_4 = Lots;
               }
            }
         } else return (-3);
      }
   }
   if (AccountFreeMarginCheck(Symbol(), A_cmd_0, lots_4) <= 0.0) return (-1);
   if (GetLastError() == 134/* NOT_ENOUGH_MONEY */) return (-2);
   return (lots_4);
}

int CountTrades() {
   int count_0 = 0;
   for (int pos_4 = OrdersTotal() - 1; pos_4 >= 0; pos_4--) {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count_0++;
   }
   return (count_0);
}

void CloseThisSymbolAll() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slippage, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slippage, Red);
         }
         Sleep(1000);
      }
   }
}

int OpenPendingOrder(int Ai_0, double A_lots_4, double A_price_12, int A_slippage_20, double Ad_24, int Ai_32, int Ai_36, string A_comment_40, int A_magic_48, int A_datetime_52, color A_color_56) {
   int ticket_60 = 0;
   int error_64 = 0;
   int count_68 = 0;
   int Li_72 = 100;
   switch (Ai_0) {
   case 2:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, A_lots_4, A_price_12, A_slippage_20, StopLong(Ad_24, Ai_32), TakeLong(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
            A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(1000);
      }
      break;
   case 4:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, A_lots_4, A_price_12, A_slippage_20, StopLong(Ad_24, Ai_32), TakeLong(A_price_12, Ai_36), A_comment_40, A_magic_48, A_datetime_52,
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
         ticket_60 = OrderSend(Symbol(), OP_BUY, A_lots_4, Ask, A_slippage_20, StopLong(Bid, Ai_32), TakeLong(Ask, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 3:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, A_lots_4, A_price_12, A_slippage_20, StopShort(Ad_24, Ai_32), TakeShort(A_price_12, Ai_36), A_comment_40, A_magic_48,
            A_datetime_52, A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 5:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, A_lots_4, A_price_12, A_slippage_20, StopShort(Ad_24, Ai_32), TakeShort(A_price_12, Ai_36), A_comment_40, A_magic_48,
            A_datetime_52, A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (count_68 = 0; count_68 < Li_72; count_68++) {
         ticket_60 = OrderSend(Symbol(), OP_SELL, A_lots_4, Bid, A_slippage_20, StopShort(Ask, Ai_32), TakeShort(Bid, Ai_36), A_comment_40, A_magic_48, A_datetime_52, A_color_56);
         error_64 = GetLastError();
         if (error_64 == 0/* NO_ERROR */) break;
         if (!((error_64 == 4/* SERVER_BUSY */ || error_64 == 137/* BROKER_BUSY */ || error_64 == 146/* TRADE_CONTEXT_BUSY */ || error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
   }
   return (ticket_60);
}

double StopLong(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 - Ai_8 * Point);
}

double StopShort(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 + Ai_8 * Point);
}

double TakeLong(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 + Ai_8 * Point);
}

double TakeShort(double Ad_0, int Ai_8) {
   if (Ai_8 == 0) return (0);
   return (Ad_0 - Ai_8 * Point);
}

double CalculateProfit() {
   double Ld_ret_0 = 0;
   for (G_pos_308 = OrdersTotal() - 1; G_pos_308 >= 0; G_pos_308--) {
      OrderSelect(G_pos_308, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) Ld_ret_0 += OrderProfit();
   }
   return (Ld_ret_0);
}

void TrailingAlls(int Ai_0, int Ai_4, double A_price_8) {
   int Li_16;
   double order_stoploss_20;
   double price_28;
   if (Ai_4 != 0) {
      for (int pos_36 = OrdersTotal() - 1; pos_36 >= 0; pos_36--) {
         if (OrderSelect(pos_36, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber) {
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

double AccountEquityHigh() {
   if (CountTrades() == 0) Gd_352 = AccountEquity();
   if (Gd_352 < Gd_360) Gd_352 = Gd_360;
   else Gd_352 = AccountEquity();
   Gd_360 = AccountEquity();
   return (Gd_352);
}

double FindLastBuyPrice() {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) {
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

double FindLastSellPrice() {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL) {
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
