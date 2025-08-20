#property copyright "Copyright © 2011, Forex-investor.net"
#property link      "http://www.forex-investor.net"

double g_maxlot_80 = 0.0;
string gs_88 = "ShockBar v.1.1";
double gd_96 = 2.0;
string gs_104 = "ShockBar_";
int gi_unused_112 = 1;
extern string __1__ = " МАРТИН 1 - вкл. 2 - выкл.";
extern int MMType = 2;
bool gi_128 = TRUE;
extern string __2__ = "множитель след. лота";
extern double LotMultiplikator = 1.667;
double gd_148;
double g_slippage_156 = 5.0;
extern string __3__ = "начальный лот:";
extern string _____ = "true - постоянный, false - от баланса";
extern bool LotConst_or_not = TRUE;
extern double Lot = 0.1;
extern double RiskPercent = 10.0;
double gd_200;
extern string __4__ = "прибыль в пунктах - ТР";
extern double TakeProfit = 5.0;
double gd_224;
double g_pips_232 = 0.0;
double gd_240 = 10.0;
double gd_248 = 10.0;
extern string __5__ = "расстояние м/у ордерами";
extern double Step = 5.0;
double gd_272;
extern string __6__ = "МАX кол-во ордеров";
extern int MaxTrades = 30;
extern string __7__ = "Ограничение потерь";
extern bool UseEquityStop = FALSE;
extern double TotalEquityRisk = 20.0;
bool gi_312 = FALSE;
bool gi_316 = FALSE;
bool gi_320 = FALSE;
double gd_324 = 48.0;
bool gi_332 = FALSE;
int gi_336 = 2;
int gi_340 = 16;
extern string __8__ = "Идентификатор ордера";
extern int Magic = 1111111;
int gi_356;
extern string __9__ = "логотип и вывод данных";
extern bool ShowTableOnTesting = TRUE;
extern string _ = "(true-вкл.,false-выкл.)";
double g_price_380;
double gd_388;
double gd_unused_396;
double gd_unused_404;
double g_price_412;
double g_bid_420;
double g_ask_428;
double gd_436;
double gd_444;
double gd_452;
bool gi_460;
int g_time_464 = 0;
int gi_468;
int gi_472 = 0;
double gd_476;
int g_pos_484 = 0;
int gi_488;
double gd_492 = 0.0;
bool gi_500 = FALSE;
bool gi_504 = FALSE;
bool gi_508 = FALSE;
int gi_512;
bool gi_516 = FALSE;
int g_datetime_520 = 0;
int g_datetime_524 = 0;
double gd_528;
double gd_536;

int init() {
   gd_452 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   if (IsTesting() == TRUE) Display_Info();
   if (IsTesting() == FALSE) Display_Info();
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   double l_ord_lots_52;
   double l_ord_lots_60;
   double l_iclose_68;
   double l_iclose_76;
   int li_unused_0 = MarketInfo(Symbol(), MODE_STOPLEVEL);
   int li_unused_4 = MarketInfo(Symbol(), MODE_SPREAD);
   double l_point_8 = MarketInfo(Symbol(), MODE_POINT);
   double l_bid_16 = MarketInfo(Symbol(), MODE_BID);
   double l_ask_24 = MarketInfo(Symbol(), MODE_ASK);
   int li_unused_32 = MarketInfo(Symbol(), MODE_DIGITS);
   if (g_maxlot_80 == 0.0) g_maxlot_80 = MarketInfo(Symbol(), MODE_MAXLOT);
   double l_minlot_36 = MarketInfo(Symbol(), MODE_MINLOT);
   double l_lotstep_44 = MarketInfo(Symbol(), MODE_LOTSTEP);
   if ((!IsOptimization() && !IsTesting() && !IsVisualMode()) || (ShowTableOnTesting && IsTesting() && !IsOptimization())) {
      DrawStats();
      DrawLogo();
   }
   if (LotConst_or_not) gd_200 = Lot;
   else gd_200 = AccountBalance() * RiskPercent / 100.0 / 10000.0;
   if (gd_200 < l_minlot_36) Print("Расчетный лот  " + gd_200 + "  меньше минимально допустимого для торговли  " + l_minlot_36);
   if (gd_200 > g_maxlot_80 && g_maxlot_80 > 0.0) Print("Расчетный лот  " + gd_200 + "  больше максимально допустимого для торговли  " + g_maxlot_80);
   gd_148 = LotMultiplikator;
   gd_224 = TakeProfit;
   gd_272 = Step;
   gi_356 = Magic;
   string ls_84 = "false";
   string ls_92 = "false";
   if (gi_332 == FALSE || (gi_332 && (gi_340 > gi_336 && (Hour() >= gi_336 && Hour() <= gi_340)) || (gi_336 > gi_340 && !(Hour() >= gi_340 && Hour() <= gi_336)))) ls_84 = "true";
   if (gi_332 && (gi_340 > gi_336 && !(Hour() >= gi_336 && Hour() <= gi_340)) || (gi_336 > gi_340 && (Hour() >= gi_340 && Hour() <= gi_336))) ls_92 = "true";
   if (gi_316) TrailingAlls(gd_240, gd_248, g_price_412);
   if (gi_320) {
      if (TimeCurrent() >= gi_468) {
         CloseThisSymbolAll();
         Print("Closed All due to TimeOut");
      }
   }
   if (g_time_464 == Time[0]) return (0);
   g_time_464 = Time[0];
   double ld_100 = CalculateProfit();
   if (UseEquityStop) {
      if (ld_100 < 0.0 && MathAbs(ld_100) > TotalEquityRisk / 100.0 * AccountEquityHigh()) {
         CloseThisSymbolAll();
         Print("Closed All due to Stop Out");
         gi_516 = FALSE;
      }
   }
   gi_488 = CountTrades();
   if (gi_488 == 0) gi_460 = FALSE;
   for (g_pos_484 = OrdersTotal() - 1; g_pos_484 >= 0; g_pos_484--) {
      OrderSelect(g_pos_484, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != gi_356) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356) {
         if (OrderType() == OP_BUY) {
            gi_504 = TRUE;
            gi_508 = FALSE;
            l_ord_lots_52 = OrderLots();
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356) {
         if (OrderType() == OP_SELL) {
            gi_504 = FALSE;
            gi_508 = TRUE;
            l_ord_lots_60 = OrderLots();
            break;
         }
      }
   }
   if (gi_488 > 0 && gi_488 <= MaxTrades) {
      RefreshRates();
      gd_436 = FindLastBuyPrice();
      gd_444 = FindLastSellPrice();
      if (gi_504 && gd_436 - Ask >= gd_272 * Point) gi_500 = TRUE;
      if (gi_508 && Bid - gd_444 >= gd_272 * Point) gi_500 = TRUE;
   }
   if (gi_488 < 1) {
      gi_508 = FALSE;
      gi_504 = FALSE;
      gi_500 = TRUE;
      gd_388 = AccountEquity();
   }
   if (gi_500) {
      gd_436 = FindLastBuyPrice();
      gd_444 = FindLastSellPrice();
      if (gi_508) {
         if (gi_312 || ls_92 == "true") {
            fOrderCloseMarket(0, 1);
            gd_476 = NormalizeDouble(gd_148 * l_ord_lots_60, gd_96);
         } else gd_476 = fGetLots(OP_SELL);
         if (gi_128 && ls_84 == "true") {
            gi_472 = gi_488;
            if (gd_476 > 0.0) {
               RefreshRates();
               gi_512 = OpenPendingOrder(1, gd_476, Bid, g_slippage_156, Ask, 0, 0, Symbol() + "-" + gs_88 + "-" + gi_472, gi_356, 0, HotPink);
               if (gi_512 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               gd_444 = FindLastSellPrice();
               gi_500 = FALSE;
               gi_516 = TRUE;
            }
         }
      } else {
         if (gi_504) {
            if (gi_312 || ls_92 == "true") {
               fOrderCloseMarket(1, 0);
               gd_476 = NormalizeDouble(gd_148 * l_ord_lots_52, gd_96);
            } else gd_476 = fGetLots(OP_BUY);
            if (gi_128 && ls_84 == "true") {
               gi_472 = gi_488;
               if (gd_476 > 0.0) {
                  gi_512 = OpenPendingOrder(0, gd_476, Ask, g_slippage_156, Bid, 0, 0, Symbol() + "-" + gs_88 + "-" + gi_472, gi_356, 0, Lime);
                  if (gi_512 < 0) {
                     Print("Error: ", GetLastError());
                     return (0);
                  }
                  gd_436 = FindLastBuyPrice();
                  gi_500 = FALSE;
                  gi_516 = TRUE;
               }
            }
         }
      }
   }
   if (gi_500 && gi_488 < 1) {
      l_iclose_68 = iClose(Symbol(), 0, 2);
      l_iclose_76 = iClose(Symbol(), 0, 1);
      g_bid_420 = Bid;
      g_ask_428 = Ask;
      if (!gi_508 && !gi_504 && ls_84 == "true") {
         gi_472 = gi_488;
         if (l_iclose_68 > l_iclose_76) {
            gd_476 = fGetLots(OP_SELL);
            if (gd_476 > 0.0) {
               gi_512 = OpenPendingOrder(1, gd_476, g_bid_420, g_slippage_156, g_bid_420, 0, 0, Symbol() + "-" + gs_88 + "-" + gi_472, gi_356, 0, HotPink);
               if (gi_512 < 0) {
                  Print(gd_476, "Error: ", GetLastError());
                  return (0);
               }
               gd_436 = FindLastBuyPrice();
               gi_516 = TRUE;
            }
         } else {
            gd_476 = fGetLots(OP_BUY);
            if (gd_476 > 0.0) {
               gi_512 = OpenPendingOrder(0, gd_476, g_ask_428, g_slippage_156, g_ask_428, 0, 0, Symbol() + "-" + gs_88 + "-" + gi_472, gi_356, 0, Lime);
               if (gi_512 < 0) {
                  Print(gd_476, "Error: ", GetLastError());
                  return (0);
               }
               gd_444 = FindLastSellPrice();
               gi_516 = TRUE;
            }
         }
      }
      if (gi_512 > 0) gi_468 = TimeCurrent() + 60.0 * (60.0 * gd_324);
      gi_500 = FALSE;
   }
   gi_488 = CountTrades();
   g_price_412 = 0;
   double ld_108 = 0;
   for (g_pos_484 = OrdersTotal() - 1; g_pos_484 >= 0; g_pos_484--) {
      OrderSelect(g_pos_484, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != gi_356) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            g_price_412 += OrderOpenPrice() * OrderLots();
            ld_108 += OrderLots();
         }
      }
   }
   if (gi_488 > 0) g_price_412 = NormalizeDouble(g_price_412 / ld_108, Digits);
   if (gi_516) {
      for (g_pos_484 = OrdersTotal() - 1; g_pos_484 >= 0; g_pos_484--) {
         OrderSelect(g_pos_484, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != gi_356) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356) {
            if (OrderType() == OP_BUY) {
               g_price_380 = g_price_412 + gd_224 * Point;
               gd_unused_396 = g_price_380;
               gd_492 = g_price_412 - g_pips_232 * Point;
               gi_460 = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356) {
            if (OrderType() == OP_SELL) {
               g_price_380 = g_price_412 - gd_224 * Point;
               gd_unused_404 = g_price_380;
               gd_492 = g_price_412 + g_pips_232 * Point;
               gi_460 = TRUE;
            }
         }
      }
   }
   if (gi_516) {
      if (gi_460 == TRUE) {
         for (g_pos_484 = OrdersTotal() - 1; g_pos_484 >= 0; g_pos_484--) {
            OrderSelect(g_pos_484, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != gi_356) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356) OrderModify(OrderTicket(), g_price_412, OrderStopLoss(), g_price_380, 0, Yellow);
            gi_516 = FALSE;
         }
      }
   }
   return (0);
}

double ND(double ad_0) {
   return (NormalizeDouble(ad_0, Digits));
}

int fOrderCloseMarket(bool ai_0 = TRUE, bool ai_4 = TRUE) {
   int li_ret_8 = 0;
   for (int l_pos_12 = OrdersTotal() - 1; l_pos_12 >= 0; l_pos_12--) {
      if (OrderSelect(l_pos_12, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356) {
            if (OrderType() == OP_BUY && ai_0) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!OrderClose(OrderTicket(), OrderLots(), ND(Bid), 5, CLR_NONE)) {
                     Print("Error close BUY " + OrderTicket());
                     li_ret_8 = -1;
                  }
               } else {
                  if (g_datetime_520 != iTime(NULL, 0, 0)) {
                     g_datetime_520 = iTime(NULL, 0, 0);
                     Print("Need close BUY " + OrderTicket() + ". Trade Context Busy");
                  }
                  return (-2);
               }
            }
            if (OrderType() == OP_SELL && ai_4) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!OrderClose(OrderTicket(), OrderLots(), ND(Ask), 5, CLR_NONE)) {
                     Print("Error close SELL " + OrderTicket());
                     li_ret_8 = -1;
                  }
               } else {
                  if (g_datetime_524 != iTime(NULL, 0, 0)) {
                     g_datetime_524 = iTime(NULL, 0, 0);
                     Print("Need close SELL " + OrderTicket() + ". Trade Context Busy");
                  }
                  return (-2);
               }
            }
         }
      }
   }
   return (li_ret_8);
}

double fGetLots(int a_cmd_0) {
   double ld_ret_4;
   int l_datetime_12;
   switch (MMType) {
   case 0:
      ld_ret_4 = gd_200;
      break;
   case 1:
      ld_ret_4 = NormalizeDouble(gd_200 * MathPow(gd_148, gi_472), gd_96);
      break;
   case 2:
      l_datetime_12 = 0;
      ld_ret_4 = gd_200;
      for (int l_pos_20 = OrdersHistoryTotal() - 1; l_pos_20 >= 0; l_pos_20--) {
         if (OrderSelect(l_pos_20, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356) {
               if (l_datetime_12 < OrderCloseTime()) {
                  l_datetime_12 = OrderCloseTime();
                  if (OrderProfit() < 0.0) ld_ret_4 = NormalizeDouble(OrderLots() * gd_148, gd_96);
                  else ld_ret_4 = gd_200;
               }
            }
         } else return (-3);
      }
   }
   if (AccountFreeMarginCheck(Symbol(), a_cmd_0, ld_ret_4) <= 0.0) return (-1);
   if (GetLastError() == 134/* NOT_ENOUGH_MONEY */) return (-2);
   return (ld_ret_4);
}

int CountTrades() {
   int l_count_0 = 0;
   for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--) {
      OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != gi_356) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) l_count_0++;
   }
   return (l_count_0);
}

void CloseThisSymbolAll() {
   for (int l_pos_0 = OrdersTotal() - 1; l_pos_0 >= 0; l_pos_0--) {
      OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, g_slippage_156, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, g_slippage_156, Red);
         }
         Sleep(1000);
      }
   }
}

int OpenPendingOrder(int ai_0, double a_lots_4, double a_price_12, int a_slippage_20, double ad_24, int ai_unused_32, int ai_36, string a_comment_40, int a_magic_48, int a_datetime_52, color a_color_56) {
   int l_ticket_60 = 0;
   int l_error_64 = 0;
   int l_count_68 = 0;
   int li_72 = 100;
   switch (ai_0) {
   case 2:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, a_lots_4, a_price_12, a_slippage_20, StopLong(ad_24, g_pips_232), TakeLong(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(1000);
      }
      break;
   case 4:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, a_lots_4, a_price_12, a_slippage_20, StopLong(ad_24, g_pips_232), TakeLong(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 0:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         RefreshRates();
         l_ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, Ask, a_slippage_20, StopLong(Bid, g_pips_232), TakeLong(Ask, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 3:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, a_lots_4, a_price_12, a_slippage_20, StopShort(ad_24, g_pips_232), TakeShort(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 5:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, a_lots_4, a_price_12, a_slippage_20, StopShort(ad_24, g_pips_232), TakeShort(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, Bid, a_slippage_20, StopShort(Ask, g_pips_232), TakeShort(Bid, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
   }
   return (l_ticket_60);
}

double StopLong(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 - ai_8 * Point);
}

double StopShort(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 + ai_8 * Point);
}

double TakeLong(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 + ai_8 * Point);
}

double TakeShort(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 - ai_8 * Point);
}

double CalculateProfit() {
   double ld_ret_0 = 0;
   for (g_pos_484 = OrdersTotal() - 1; g_pos_484 >= 0; g_pos_484--) {
      OrderSelect(g_pos_484, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != gi_356) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0 += OrderProfit();
   }
   return (ld_ret_0);
}

void TrailingAlls(int ai_0, int ai_4, double a_price_8) {
   int li_16;
   double l_ord_stoploss_20;
   double l_price_28;
   if (ai_4 != 0) {
      for (int l_pos_36 = OrdersTotal() - 1; l_pos_36 >= 0; l_pos_36--) {
         if (OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != gi_356) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == gi_356) {
               if (OrderType() == OP_BUY) {
                  li_16 = NormalizeDouble((Bid - a_price_8) / Point, 0);
                  if (li_16 < ai_0) continue;
                  l_ord_stoploss_20 = OrderStopLoss();
                  l_price_28 = Bid - ai_4 * Point;
                  if (l_ord_stoploss_20 == 0.0 || (l_ord_stoploss_20 != 0.0 && l_price_28 > l_ord_stoploss_20)) OrderModify(OrderTicket(), a_price_8, l_price_28, OrderTakeProfit(), 0, Aqua);
               }
               if (OrderType() == OP_SELL) {
                  li_16 = NormalizeDouble((a_price_8 - Ask) / Point, 0);
                  if (li_16 < ai_0) continue;
                  l_ord_stoploss_20 = OrderStopLoss();
                  l_price_28 = Ask + ai_4 * Point;
                  if (l_ord_stoploss_20 == 0.0 || (l_ord_stoploss_20 != 0.0 && l_price_28 < l_ord_stoploss_20)) OrderModify(OrderTicket(), a_price_8, l_price_28, OrderTakeProfit(), 0, Red);
               }
            }
            Sleep(1000);
         }
      }
   }
}

double AccountEquityHigh() {
   if (CountTrades() == 0) gd_528 = AccountEquity();
   if (gd_528 < gd_536) gd_528 = gd_536;
   else gd_528 = AccountEquity();
   gd_536 = AccountEquity();
   return (gd_528);
}

double FindLastBuyPrice() {
   double l_ord_open_price_0;
   int l_ticket_8;
   double ld_unused_12 = 0;
   int l_ticket_20 = 0;
   for (int l_pos_24 = OrdersTotal() - 1; l_pos_24 >= 0; l_pos_24--) {
      OrderSelect(l_pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != gi_356) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356 && OrderType() == OP_BUY) {
         l_ticket_8 = OrderTicket();
         if (l_ticket_8 > l_ticket_20) {
            l_ord_open_price_0 = OrderOpenPrice();
            ld_unused_12 = l_ord_open_price_0;
            l_ticket_20 = l_ticket_8;
         }
      }
   }
   return (l_ord_open_price_0);
}

double FindLastSellPrice() {
   double l_ord_open_price_0;
   int l_ticket_8;
   double ld_unused_12 = 0;
   int l_ticket_20 = 0;
   for (int l_pos_24 = OrdersTotal() - 1; l_pos_24 >= 0; l_pos_24--) {
      OrderSelect(l_pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != gi_356) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == gi_356 && OrderType() == OP_SELL) {
         l_ticket_8 = OrderTicket();
         if (l_ticket_8 > l_ticket_20) {
            l_ord_open_price_0 = OrderOpenPrice();
            ld_unused_12 = l_ord_open_price_0;
            l_ticket_20 = l_ticket_8;
         }
      }
   }
   return (l_ord_open_price_0);
}

void Display_Info() {
   Comment("            ShockBar v.1.1  " + Symbol() + "  " + Period(), 
      "\n", "            Forex Account Server:", AccountServer(), 
      "\n", "            Lots:  ", gd_200, 
      "\n", "            Symbol: ", Symbol(), 
      "\n", "            Price:  ", NormalizeDouble(Bid, 4), 
      "\n", "            Date: ", Month(), "-", Day(), "-", Year(), " Server Time: ", Hour(), ":", Minute(), ":", Seconds(), 
   "\n");
}

void DrawStats() {
   double ld_0 = GetProfitForDay(0);
   string l_name_8 = gs_104 + "1";
   if (ObjectFind(l_name_8) == -1) {
      ObjectCreate(l_name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(l_name_8, OBJPROP_CORNER, 1);
      ObjectSet(l_name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(l_name_8, OBJPROP_YDISTANCE, 15);
   }
   ObjectSetText(l_name_8, "Заработок сегодня: " + DoubleToStr(ld_0, 2), 10, "Courier New", Yellow);
   ld_0 = GetProfitForDay(1);
   l_name_8 = gs_104 + "2";
   if (ObjectFind(l_name_8) == -1) {
      ObjectCreate(l_name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(l_name_8, OBJPROP_CORNER, 1);
      ObjectSet(l_name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(l_name_8, OBJPROP_YDISTANCE, 30);
   }
   ObjectSetText(l_name_8, "Заработок вчера: " + DoubleToStr(ld_0, 2), 10, "Courier New", Yellow);
   ld_0 = GetProfitForDay(2);
   l_name_8 = gs_104 + "3";
   if (ObjectFind(l_name_8) == -1) {
      ObjectCreate(l_name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(l_name_8, OBJPROP_CORNER, 1);
      ObjectSet(l_name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(l_name_8, OBJPROP_YDISTANCE, 45);
   }
   ObjectSetText(l_name_8, "Заработок позавчера: " + DoubleToStr(ld_0, 2), 10, "Courier New", Yellow);
   l_name_8 = gs_104 + "4";
   if (ObjectFind(l_name_8) == -1) {
      ObjectCreate(l_name_8, OBJ_LABEL, 0, 0, 0);
      ObjectSet(l_name_8, OBJPROP_CORNER, 1);
      ObjectSet(l_name_8, OBJPROP_XDISTANCE, 10);
      ObjectSet(l_name_8, OBJPROP_YDISTANCE, 75);
   }
   ObjectSetText(l_name_8, "Баланс: " + DoubleToStr(AccountBalance(), 2), 12, "Courier New", Yellow);
}

void DrawLogo() {
   string l_name_0 = gs_104 + "L_1";
   if (ObjectFind(l_name_0) == -1) {
      ObjectCreate(l_name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(l_name_0, OBJPROP_CORNER, 0);
      ObjectSet(l_name_0, OBJPROP_XDISTANCE, 390);
      ObjectSet(l_name_0, OBJPROP_YDISTANCE, 10);
   }
   ObjectSetText(l_name_0, "F O R E X", 28, "Arial", DarkTurquoise);
   l_name_0 = gs_104 + "L_2";
   if (ObjectFind(l_name_0) == -1) {
      ObjectCreate(l_name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(l_name_0, OBJPROP_CORNER, 0);
      ObjectSet(l_name_0, OBJPROP_XDISTANCE, 382);
      ObjectSet(l_name_0, OBJPROP_YDISTANCE, 50);
   }
   ObjectSetText(l_name_0, "I  N  V  E  S  T  O  R", 16, "Arial", Gold);
   l_name_0 = gs_104 + "L_3";
   if (ObjectFind(l_name_0) == -1) {
      ObjectCreate(l_name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(l_name_0, OBJPROP_CORNER, 0);
      ObjectSet(l_name_0, OBJPROP_XDISTANCE, 397);
      ObjectSet(l_name_0, OBJPROP_YDISTANCE, 75);
   }
   ObjectSetText(l_name_0, "www.forex-investor.net", 12, "Arial", Gray);
   l_name_0 = gs_104 + "L_4";
   if (ObjectFind(l_name_0) == -1) {
      ObjectCreate(l_name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(l_name_0, OBJPROP_CORNER, 0);
      ObjectSet(l_name_0, OBJPROP_XDISTANCE, 382);
      ObjectSet(l_name_0, OBJPROP_YDISTANCE, 57);
   }
   ObjectSetText(l_name_0, "_____________________", 12, "Arial", Gray);
   l_name_0 = gs_104 + "L_5";
   if (ObjectFind(l_name_0) == -1) {
      ObjectCreate(l_name_0, OBJ_LABEL, 0, 0, 0);
      ObjectSet(l_name_0, OBJPROP_CORNER, 0);
      ObjectSet(l_name_0, OBJPROP_XDISTANCE, 382);
      ObjectSet(l_name_0, OBJPROP_YDISTANCE, 76);
   }
   ObjectSetText(l_name_0, "_____________________", 12, "Arial", Gray);
}

double GetProfitForDay(int ai_0) {
   double ld_ret_4 = 0;
   for (int l_pos_12 = 0; l_pos_12 < OrdersHistoryTotal(); l_pos_12++) {
      if (!(OrderSelect(l_pos_12, SELECT_BY_POS, MODE_HISTORY))) break;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
         if (OrderCloseTime() >= iTime(Symbol(), PERIOD_D1, ai_0) && OrderCloseTime() < iTime(Symbol(), PERIOD_D1, ai_0) + 86400) ld_ret_4 = ld_ret_4 + OrderProfit() + OrderCommission() + OrderSwap();
   }
   return (ld_ret_4);
}