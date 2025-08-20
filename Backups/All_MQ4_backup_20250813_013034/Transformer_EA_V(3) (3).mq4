#property copyright "Copyright © 2016, Transformer EA By Charlie Trade LTD  "
#property link      "http://www.transformer_ea.webs.com"

extern string Version = "Transformer_EA_V[3] ";
extern string Optimizer = "CHARLIE POWER";
extern string Currency = "EURUSD, USDCHF, USDCAD or USDJPY, TF M15 M30 M60";
extern int MMType = 1;
extern bool UseClose = FALSE;
extern bool UseAdd = TRUE;
extern double TurboBoost = 1.667;
extern double slip = 3.0;
extern double Lots = 0.1;
extern double LotsDigits = 2.0;
extern double TakeProfit = 10.0;
double G_pips_152 = 0.0;
double Gd_160 = 0.0;
double Gd_168 = 0.0;
extern double PipStep = 5.0;
extern int MaxTrades = 10;
extern bool UseEquityStop = FALSE;
extern double TotalEquityRisk = 20.0;
extern bool UseTrailingStop = FALSE;
extern bool UseTimeOut = FALSE;
extern bool EnableErrorMessages = FALSE;
extern double MaxTradeOpenHours = 0.0;
extern int GMTOffset = 2;
extern int BeginHour = 0;
extern int EndHour = 21;
extern string Key = "0123456789";
extern string Note = "Licensed Until 1.1.900065";
int G_magic_248 = 12771;
double G_price_252;
double Gd_260;
double Gd_unused_268;
double Gd_unused_276;
double G_price_284;
double G_bid_292;
double G_ask_300;
double Gd_308;
double Gd_316;
double Gd_324;
bool Gi_332;
string Gs_336 = "EA Rahsia";
datetime G_time_344 = 0;
int Gi_348;
int Gi_352 = 0;
double Gd_356;
int G_pos_364 = 0;
int Gi_368;
double Gd_372 = 0.0;
bool Gi_380 = TRUE;
bool Gi_384 = TRUE;
bool Gi_388 = TRUE;
int Gi_392;
bool Gi_396 = TRUE;
int G_datetime_400 = 0;
int G_datetime_404 = 0;
double Gd_408;
double Gd_416;

int init() {
   Gd_324 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
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
   if (UseTrailingStop) TrailingAlls(Gd_160, Gd_168, G_price_284);
   if (UseTimeOut) {
      if (TimeCurrent() >= Gi_348) {
         CloseThisSymbolAll();
         Print("Closed All due to TimeOut");
      }
   }
   if (G_time_344 == Time[0]) return (0);
   G_time_344 = Time[0];
   double Ld_32 = CalculateProfit();
   if (UseEquityStop) {
      if (Ld_32 < 0.0 && MathAbs(Ld_32) > TotalEquityRisk / 100.0 * AccountEquityHigh()) {
         CloseThisSymbolAll();
         Print("Closed All due to Stop Out");
         Gi_396 = FALSE;
      }
   }
   Gi_368 = CountTrades();
   if (Gi_368 == 0) Gi_332 = FALSE;
   for (G_pos_364 = OrdersTotal() - 1; G_pos_364 >= 0; G_pos_364--) {
      OrderSelect(G_pos_364, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_248) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_248) {
         if (OrderType() == OP_BUY) {
            Gi_384 = TRUE;
            Gi_388 = FALSE;
            order_lots_0 = OrderLots();
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_248) {
         if (OrderType() == OP_SELL) {
            Gi_384 = FALSE;
            Gi_388 = TRUE;
            order_lots_8 = OrderLots();
            break;
         }
      }
   }
   if (Gi_368 > 0 && Gi_368 <= MaxTrades) {
      RefreshRates();
      Gd_308 = FindLastBuyPrice();
      Gd_316 = FindLastSellPrice();
      if (Gi_384 && Gd_308 - Ask >= PipStep * Point) Gi_380 = TRUE;
      if (Gi_388 && Bid - Gd_316 >= PipStep * Point) Gi_380 = TRUE;
   }
   if (Gi_368 < 1) {
      Gi_388 = FALSE;
      Gi_384 = FALSE;
      Gi_380 = TRUE;
      Gd_260 = AccountEquity();
   }
   if (Gi_380) {
      Gd_308 = FindLastBuyPrice();
      Gd_316 = FindLastSellPrice();
      if (Gi_388) {
         if (UseClose) {
            fOrderCloseMarket(0, 1);
            Gd_356 = NormalizeDouble(TurboBoost * order_lots_8, LotsDigits);
         } else Gd_356 = fGetLots(OP_SELL);
         if (UseAdd) {
            Gi_352 = Gi_368;
            if (Gd_356 > 0.0) {
               RefreshRates();
               Gi_392 = OpenPendingOrder(1, Gd_356, Bid, slip, Ask, 0, 0, Gs_336 + "-" + Gi_352, G_magic_248, 0, HotPink);
               if (Gi_392 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               Gd_316 = FindLastSellPrice();
               Gi_380 = FALSE;
               Gi_396 = TRUE;
            }
         }
      } else {
         if (Gi_384) {
            if (UseClose) {
               fOrderCloseMarket(1, 0);
               Gd_356 = NormalizeDouble(TurboBoost * order_lots_0, LotsDigits);
            } else Gd_356 = fGetLots(OP_BUY);
            if (UseAdd) {
               Gi_352 = Gi_368;
               if (Gd_356 > 0.0) {
                  Gi_392 = OpenPendingOrder(0, Gd_356, Ask, slip, Bid, 0, 0, Gs_336 + "-" + Gi_352, G_magic_248, 0, Lime);
                  if (Gi_392 < 0) {
                     Print("Error: ", GetLastError());
                     return (0);
                  }
                  Gd_308 = FindLastBuyPrice();
                  Gi_380 = FALSE;
                  Gi_396 = TRUE;
               }
            }
         }
      }
   }
   if (Gi_380 && Gi_368 < 1) {
      iclose_16 = iClose(Symbol(), 0, 2);
      iclose_24 = iClose(Symbol(), 0, 1);
      G_bid_292 = Bid;
      G_ask_300 = Ask;
      if ((!Gi_388) && (!Gi_384)) {
         Gi_352 = Gi_368;
         if (iclose_16 > iclose_24) {
            Gd_356 = fGetLots(OP_SELL);
            if (Gd_356 > 0.0) {
               Gi_392 = OpenPendingOrder(1, Gd_356, G_bid_292, slip, G_bid_292, 0, 0, Gs_336 + "-" + Gi_352, G_magic_248, 0, HotPink);
               if (Gi_392 < 0) {
                  Print(Gd_356, "Error: ", GetLastError());
                  return (0);
               }
               Gd_308 = FindLastBuyPrice();
               Gi_396 = TRUE;
            }
         } else {
            Gd_356 = fGetLots(OP_BUY);
            if (Gd_356 > 0.0) {
               Gi_392 = OpenPendingOrder(0, Gd_356, G_ask_300, slip, G_ask_300, 0, 0, Gs_336 + "-" + Gi_352, G_magic_248, 0, Lime);
               if (Gi_392 < 0) {
                  Print(Gd_356, "Error: ", GetLastError());
                  return (0);
               }
               Gd_316 = FindLastSellPrice();
               Gi_396 = TRUE;
            }
         }
      }
      if (Gi_392 > 0) Gi_348 = TimeCurrent() + 60.0 * (60.0 * MaxTradeOpenHours);
      Gi_380 = FALSE;
   }
   Gi_368 = CountTrades();
   G_price_284 = 0;
   double Ld_40 = 0;
   for (G_pos_364 = OrdersTotal() - 1; G_pos_364 >= 0; G_pos_364--) {
      OrderSelect(G_pos_364, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_248) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_248) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            G_price_284 += OrderOpenPrice() * OrderLots();
            Ld_40 += OrderLots();
         }
      }
   }
   if (Gi_368 > 0) G_price_284 = NormalizeDouble(G_price_284 / Ld_40, Digits);
   if (Gi_396) {
      for (G_pos_364 = OrdersTotal() - 1; G_pos_364 >= 0; G_pos_364--) {
         OrderSelect(G_pos_364, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_248) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_248) {
            if (OrderType() == OP_BUY) {
               G_price_252 = G_price_284 + TakeProfit * Point;
               Gd_unused_268 = G_price_252;
               Gd_372 = G_price_284 - G_pips_152 * Point;
               Gi_332 = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_248) {
            if (OrderType() == OP_SELL) {
               G_price_252 = G_price_284 - TakeProfit * Point;
               Gd_unused_276 = G_price_252;
               Gd_372 = G_price_284 + G_pips_152 * Point;
               Gi_332 = TRUE;
            }
         }
      }
   }
   if (Gi_396) {
      if (Gi_332 == TRUE) {
         for (G_pos_364 = OrdersTotal() - 1; G_pos_364 >= 0; G_pos_364--) {
            OrderSelect(G_pos_364, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_248) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_248) OrderModify(OrderTicket(), G_price_284, OrderStopLoss(), G_price_252, 0, Yellow);
            Gi_396 = FALSE;
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
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_248) {
            if (OrderType() == OP_BUY && Ai_0) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!OrderClose(OrderTicket(), OrderLots(), ND(Bid), 5, CLR_NONE)) {
                     Print("Error close BUY " + OrderTicket());
                     Li_ret_8 = -1;
                  }
               } else {
                  if (G_datetime_400 == iTime(NULL, 0, 0)) return (-2);
                  G_datetime_400 = iTime(NULL, 0, 0);
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
               if (G_datetime_404 == iTime(NULL, 0, 0)) return (-2);
               G_datetime_404 = iTime(NULL, 0, 0);
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
   switch (MMType) {
   case 0:
      lots_4 = Lots;
      break;
   case 1:
      lots_4 = NormalizeDouble(Lots * MathPow(TurboBoost, Gi_352), LotsDigits);
      break;
   case 2:
      datetime_12 = 0;
      lots_4 = Lots;
      for (int pos_20 = OrdersHistoryTotal() - 1; pos_20 >= 0; pos_20--) {
         if (OrderSelect(pos_20, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_248) {
               if (datetime_12 < OrderCloseTime()) {
                  datetime_12 = OrderCloseTime();
                  if (OrderProfit() < 0.0) {
                     lots_4 = NormalizeDouble(OrderLots() * TurboBoost, LotsDigits);
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
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_248) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_248)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) count_0++;
   }
   return (count_0);
}

void CloseThisSymbolAll() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_248) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slip, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slip, Red);
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
   for (G_pos_364 = OrdersTotal() - 1; G_pos_364 >= 0; G_pos_364--) {
      OrderSelect(G_pos_364, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_248) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_248)
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
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_248) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == G_magic_248) {
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
   if (CountTrades() == 0) Gd_408 = AccountEquity();
   if (Gd_408 < Gd_416) Gd_408 = Gd_416;
   else Gd_408 = AccountEquity();
   Gd_416 = AccountEquity();
   return (Gd_408);
}

double FindLastBuyPrice() {
   double order_open_price_0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_248) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_248 && OrderType() == OP_BUY) {
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
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != G_magic_248) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_248 && OrderType() == OP_SELL) {
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
