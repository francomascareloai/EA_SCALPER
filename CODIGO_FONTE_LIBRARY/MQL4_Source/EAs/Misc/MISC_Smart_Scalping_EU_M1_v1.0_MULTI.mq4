#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

extern string comment = "SSEUM1";
extern int Magic = 1423;
bool gi_88 = FALSE;
bool gi_92 = FALSE;
bool gi_96 = FALSE;
string gs_unused_100 = "Money Management";
extern int Risk = 1;
extern double lots = 0.1;
string gs_unused_120 = "Order Management";
extern bool ecn = FALSE;
bool gi_132 = TRUE;
int gi_unused_136 = 20;
bool gi_140 = FALSE;
int gi_unused_144 = 100;
int gi_148 = 1;
bool gi_152 = FALSE;
bool gi_156 = FALSE;
double gd_160 = 6.0;
extern double TakeProfit = 100.0;
extern double TrailingStart = 6.0;
extern double TtrailingStop = 6.0;
double gd_192 = 0.0;
double gd_200 = 1.0;
double gd_208 = 0.0;
double gd_216 = 0.0;
double gd_224 = 3.0;
double gd_232 = 0.0;
extern double StopLose = 20.0;
bool gi_248 = FALSE;
bool gi_252 = TRUE;
int gi_256 = 0;
int gi_260 = 0;
string gs_unused_264 = "Entry Logics";
double gd_272 = 0.0;
double gd_280 = 1.0;
bool gi_unused_288 = TRUE;
int gi_292 = 5;
double gd_296 = 3.0;
bool gi_unused_304 = TRUE;
int gi_308 = 5;
double gd_312 = 3.0;
int gi_320 = 1;
int g_datetime_340;
int g_datetime_348;
datetime g_time_372;
datetime g_time_376;
int g_pos_392;
int g_bars_396 = -1;
int g_count_400;
int g_count_404;
int g_count_408;
int gi_412 = 100;
int g_count_464;
int gi_468;
bool gi_480;
int gi_484;
int gi_488;
int gi_492;
string gs_dummy_512;
string gs_dummy_520;
string gs_dummy_528;
string gs_dummy_536;
string gs_dummy_544;
string gs_dummy_552;
string gs_dummy_560;
string gs_dummy_568;
string gs_dummy_576;
string gs_dummy_584;
double g_price_600;
double g_price_608;
double g_lots_616;
double g_lots_624;
double gda_unused_672[14];
double gda_unused_676[14];
double gd_unused_712;
double gd_unused_720;
double gd_unused_768 = 0.0;
bool gi_unused_784 = TRUE;
bool gi_unused_788 = TRUE;
double gd_792;
double gd_800;
double gd_808;
double gd_816;
int g_count_824;
int g_count_828;
int g_datetime_832;
int g_datetime_836;
bool gi_840;
bool gi_844;
double gd_852;
double gd_860;
double gd_868;

int init() {
   if (Digits == 3 || Digits == 5) {
      gd_792 = 10.0 * Point;
      gd_808 = 10;
      if (gd_272 == 0.0) {
         gd_816 = Digits - 1;
         gd_800 = gd_792;
      }
      if (gd_272 == 1.0) {
         gd_816 = Digits;
         gd_800 = Point;
      }
   } else {
      gd_792 = Point;
      gd_808 = 1;
      if (gd_272 == 0.0 || gd_272 == 1.0) {
         gd_816 = Digits;
         gd_800 = gd_792;
      }
   }
   if (StopLose > 0.0) {
      gd_160 = StopLose;
      TakeProfit = StopLose;
   }
   return (0);
}

int start() {
   int li_4;
   bool li_0 = TRUE;
   gi_488 = f0_10(OP_BUY);
   gi_492 = f0_10(OP_SELL);
   gi_484 = gi_488 + gi_492;
   if (gd_208 > 0.0 && li_0) f0_7(gd_208, gd_216);
   if (TtrailingStop > 0.0 && li_0) f0_4(TrailingStart, TtrailingStop);
   if (gd_192 > 0.0 && li_0) f0_5(TrailingStart, gd_192);
   gd_unused_712 = 0;
   gd_unused_720 = 0;
   if (OrdersTotal() > 0) {
      for (g_pos_392 = 0; g_pos_392 <= OrdersTotal(); g_pos_392++) {
         OrderSelect(g_pos_392, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderCloseTime() == 0) {
            if (OrderType() == OP_BUY) g_datetime_340 = OrderOpenTime();
            if (OrderType() == OP_SELL) g_datetime_348 = OrderOpenTime();
         }
      }
   }
   if (gi_148 == 1) {
      if (g_datetime_340 < Time[0]) g_count_404 = 0;
      else g_count_404 = 1;
      if (g_datetime_348 < Time[0]) g_count_408 = 0;
      else g_count_408 = 1;
   }
   if (gi_148 != 1 && g_bars_396 != Bars) {
      g_count_404 = 0;
      g_count_408 = 0;
      g_bars_396 = Bars;
   }
   if (li_0 || gi_320 == 0) {
      if (gi_484 == 0) {
         if (gd_852 <= NormalizeDouble(Ask, gd_816) - gd_280 * gd_800) {
            g_count_824++;
            gd_852 = NormalizeDouble(Ask, gd_816);
            if (gi_840 == FALSE) {
               g_datetime_832 = TimeCurrent();
               gi_840 = TRUE;
            }
         } else {
            gd_852 = 0;
            g_count_824 = 0;
            gi_840 = FALSE;
            g_datetime_832 = 0;
         }
         if (gd_860 >= NormalizeDouble(Ask, gd_816) + gd_280 * gd_800) {
            g_count_828++;
            gd_860 = NormalizeDouble(Ask, gd_816);
            if (gi_844 == FALSE) {
               g_datetime_836 = TimeCurrent();
               gi_844 = TRUE;
            }
         } else {
            gd_860 = 0;
            g_count_828 = 0;
            gi_844 = FALSE;
            g_datetime_836 = 0;
         }
         if (gd_852 == 0.0) gd_852 = NormalizeDouble(Ask, gd_816);
         if (gd_860 == 0.0) gd_860 = NormalizeDouble(Ask, gd_816);
      }
      li_4 = 0;
      if (g_count_824 == gi_292 || g_count_828 == gi_308 && g_count_824 >= g_count_828 && TimeCurrent() - g_datetime_832 <= gd_296) li_4 = 1;
      if (g_count_824 == gi_292 || g_count_828 == gi_308 && g_count_824 < g_count_828 && TimeCurrent() - g_datetime_836 <= gd_312) li_4 = 2;
      if (li_4 != 0) {
         gd_852 = 0;
         gd_860 = 0;
         g_count_824 = 0;
         g_count_828 = 0;
         gi_840 = FALSE;
         gi_844 = FALSE;
         g_datetime_832 = 0;
         g_datetime_836 = 0;
      }
   }
   int li_unused_8 = 1;
   bool li_12 = FALSE;
   bool li_16 = FALSE;
   if (li_4 == 1) {
      if (gi_140) li_16 = TRUE;
      else li_12 = TRUE;
   }
   if (li_4 == 2) {
      if (gi_140) li_12 = TRUE;
      else li_16 = TRUE;
   }
   if (gi_156 || gi_152) {
      f0_8(0);
      f0_8(1);
   }
   if (gd_232 != 0.0)
      if (Ask - Bid > gd_232 * gd_808 * gd_792) return (0);
   if (lots == 0.0) {
      g_lots_616 = f0_3();
      g_lots_624 = f0_3();
   } else {
      g_lots_616 = lots;
      g_lots_624 = lots;
   }
   if (li_12 && g_count_404 < gi_148 && (!gi_96)) {
      gi_468 = 0;
      g_count_464 = 0;
      gi_480 = FALSE;
      if (!ecn) {
         if (gi_132) {
            while (gi_468 <= 0 && g_count_464 < gi_412) {
               while (!IsTradeAllowed()) Sleep(5000);
               RefreshRates();
               gi_468 = f0_6(OP_BUY, g_lots_616, Ask, gd_160, TakeProfit, gi_480, Blue);
               if (gi_468 < 0) {
                  if (gi_88) Print("Error opening BUY order! ", f0_9(GetLastError()));
                  g_count_464++;
               }
            }
         }
         if (gi_248) {
            if (g_time_372 != Time[0]) {
               if (gi_252) f0_0(OP_BUYSTOP);
               RefreshRates();
               gi_468 = f0_6(OP_SELLSTOP, g_lots_616, Bid - gd_160 * gd_792, gi_256, gi_260, gi_480, Red);
               g_time_372 = Time[0];
            }
         }
      }
      if (ecn) {
         if (gi_132) {
            while (gi_468 <= 0 && g_count_464 < gi_412) {
               while (!IsTradeAllowed()) Sleep(5000);
               RefreshRates();
               gi_468 = f0_6(OP_BUY, g_lots_616, Ask, 0, 0, gi_480, Blue);
               if (gi_468 < 0) {
                  if (gi_88) Print("Error opening BUY order! ", f0_9(GetLastError()));
                  g_count_464++;
               }
            }
         }
         if (gi_248) {
            if (g_time_372 != Time[0]) {
               if (gi_252) f0_0(OP_BUYSTOP);
               RefreshRates();
               gi_468 = f0_6(OP_SELLSTOP, g_lots_616, Bid - gd_160 * gd_792, 0, 0, gi_480, Red);
               g_time_372 = Time[0];
            }
         }
      }
      if (gi_132) {
         if (gi_468 <= 0) {
            if (gi_88) Print("Error Occured : " + f0_9(GetLastError()));
         } else g_count_404++;
      }
   }
   if (li_16 && g_count_408 < gi_148 && (!gi_92)) {
      gi_468 = 0;
      g_count_464 = 0;
      gi_480 = FALSE;
      if (!ecn) {
         if (gi_132) {
            while (gi_468 <= 0 && g_count_464 < gi_412) {
               while (!IsTradeAllowed()) Sleep(5000);
               RefreshRates();
               gi_468 = f0_6(OP_SELL, g_lots_624, Bid, gd_160, TakeProfit, gi_480, Red);
               if (gi_468 < 0) {
                  if (gi_88) Print("Error opening BUY order! ", f0_9(GetLastError()));
                  g_count_464++;
               }
            }
         }
         if (gi_248) {
            if (g_time_376 != Time[0]) {
               if (gi_252) f0_0(OP_SELLSTOP);
               RefreshRates();
               gi_468 = f0_6(OP_BUYSTOP, g_lots_616, Ask + gd_160 * gd_792, gi_256, gi_260, gi_480, Red);
               g_time_376 = Time[0];
            }
         }
      }
      if (ecn) {
         if (gi_132) {
            while (gi_468 <= 0 && g_count_464 < gi_412) {
               while (!IsTradeAllowed()) Sleep(5000);
               RefreshRates();
               gi_468 = f0_6(OP_SELL, g_lots_624, Bid, 0, 0, gi_480, Red);
               if (gi_468 < 0) {
                  if (gi_88) Print("Error opening BUY order! ", f0_9(GetLastError()));
                  g_count_464++;
               }
            }
         }
         if (gi_248) {
            if (g_time_376 != Time[0]) {
               if (gi_252) f0_0(OP_SELLSTOP);
               RefreshRates();
               gi_468 = f0_6(OP_BUYSTOP, g_lots_616, Ask + gd_160 * gd_792, 0, 0, gi_480, Red);
               g_time_376 = Time[0];
            }
         }
      }
      if (gi_132) {
         if (gi_468 <= 0) {
            if (gi_88) Print("Error Occured : " + f0_9(GetLastError()));
         } else g_count_408++;
      }
   }
   if (ecn) f0_1(gd_160, TakeProfit);
   Comment("\nSmart Scalping EU M1", 
      "\n--------------------------------", 
      "\nEquitity :  ", AccountEquity(), 
   "\nDraw Down Max:  ", DoubleToStr(f0_2(), 2), " %");
   return (0);
}

int f0_6(int a_cmd_0, double a_lots_4, double ad_12, double ad_20, double ad_28, int a_datetime_36, color a_color_40) {
   int ticket_44 = 0;
   if (a_cmd_0 == OP_BUY || a_cmd_0 == OP_BUYSTOP || a_cmd_0 == OP_BUYLIMIT) {
      if (gi_152 == FALSE && ad_20 > 0.0) g_price_600 = ad_12 - ad_20 * gd_792;
      else g_price_600 = 0;
      if (gi_156 == FALSE && ad_28 > 0.0) g_price_608 = ad_12 + ad_28 * gd_792;
      else g_price_608 = 0;
   }
   if (a_cmd_0 == OP_SELL || a_cmd_0 == OP_SELLSTOP || a_cmd_0 == OP_SELLLIMIT) {
      if (gi_152 == FALSE && ad_20 > 0.0) g_price_600 = ad_12 + ad_20 * gd_792;
      else g_price_600 = 0;
      if (gi_156 == FALSE && ad_28 > 0.0) g_price_608 = ad_12 - ad_28 * gd_792;
      else g_price_608 = 0;
   }
   ticket_44 = OrderSend(Symbol(), a_cmd_0, a_lots_4, NormalizeDouble(ad_12, Digits), gd_224 * gd_808, g_price_600, g_price_608, comment + " " + DoubleToStr(Magic, 0),
      Magic, a_datetime_36, a_color_40);
   return (ticket_44);
}

double f0_3() {
   double ld_ret_0 = NormalizeDouble(AccountEquity() * Risk / 100.0 / 100.0, 1);
   double ld_8 = MarketInfo(Symbol(), MODE_MINLOT);
   double ld_16 = MarketInfo(Symbol(), MODE_MAXLOT);
   if (ld_ret_0 < ld_8) ld_ret_0 = ld_8;
   if (ld_ret_0 > ld_16) ld_ret_0 = ld_16;
   return (ld_ret_0);
}

int f0_10(int a_cmd_0) {
   g_count_400 = 0;
   if (OrdersTotal() > 0) {
      for (g_pos_392 = OrdersTotal(); g_pos_392 >= 0; g_pos_392--) {
         OrderSelect(g_pos_392, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderType() == a_cmd_0 && OrderMagicNumber() == Magic) g_count_400++;
      }
      return (g_count_400);
   }
   return (0);
}

void f0_8(int ai_0) {
   if (OrdersTotal() > 0) {
      for (g_pos_392 = OrdersTotal() - 1; g_pos_392 >= 0; g_pos_392--) {
         OrderSelect(g_pos_392, SELECT_BY_POS, MODE_TRADES);
         if (ai_0 == 0 && OrderType() == OP_BUY) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && (gi_152 && gd_160 > 0.0 && NormalizeDouble(OrderClosePrice() - OrderOpenPrice(), Digits) <= (-1.0 * gd_160) * gd_792 - MarketInfo(Symbol(),
               MODE_SPREAD) * gd_792) || (gi_156 && TakeProfit > 0.0 && NormalizeDouble(OrderClosePrice() - OrderOpenPrice(), Digits) >= TakeProfit * gd_792)) {
               RefreshRates();
               OrderClose(OrderTicket(), OrderLots(), Bid, gd_224 * gd_808);
            }
         }
         if (ai_0 == 1 && OrderType() == OP_SELL) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && (gi_152 && gd_160 > 0.0 && NormalizeDouble(OrderOpenPrice() - OrderClosePrice(), Digits) <= (-1.0 * gd_160) * gd_792 - MarketInfo(Symbol(),
               MODE_SPREAD) * gd_792) || (gi_156 && TakeProfit > 0.0 && NormalizeDouble(OrderOpenPrice() - OrderClosePrice(), Digits) >= TakeProfit * gd_792)) {
               RefreshRates();
               OrderClose(OrderTicket(), OrderLots(), Ask, gd_224 * gd_808);
            }
         }
      }
   }
}

void f0_0(int a_cmd_0) {
   if (OrdersTotal() > 0) {
      for (g_pos_392 = OrdersTotal(); g_pos_392 >= 0; g_pos_392--) {
         OrderSelect(g_pos_392, SELECT_BY_POS, MODE_TRADES);
         if (a_cmd_0 != 6)
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == a_cmd_0) OrderDelete(OrderTicket());
         if (a_cmd_0 == 6)
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic && OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP || OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT) OrderDelete(OrderTicket());
      }
   }
}

void f0_7(double ad_0, double ad_8) {
   RefreshRates();
   if (OrdersTotal() > 0) {
      for (g_pos_392 = OrdersTotal(); g_pos_392 >= 0; g_pos_392--) {
         OrderSelect(g_pos_392, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
            if (OrderType() == OP_BUY) {
               if (NormalizeDouble(Bid - OrderOpenPrice(), Digits) < NormalizeDouble(ad_0 * gd_792, Digits)) continue;
               if (!(NormalizeDouble(OrderStopLoss() - OrderOpenPrice(), Digits) < NormalizeDouble(ad_8 * gd_792, Digits) || OrderStopLoss() == 0.0)) continue;
               OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(OrderOpenPrice() + ad_8 * gd_792, Digits), OrderTakeProfit(), 0, Blue);
               return;
            }
            if (NormalizeDouble(OrderOpenPrice() - Ask, Digits) >= NormalizeDouble(ad_0 * gd_792, Digits)) {
               if (NormalizeDouble(OrderOpenPrice() - OrderStopLoss(), Digits) < NormalizeDouble(ad_8 * gd_792, Digits) || OrderStopLoss() == 0.0) {
                  OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(OrderOpenPrice() - ad_8 * gd_792, Digits), OrderTakeProfit(), 0, Red);
                  return;
               }
            }
         }
      }
   }
}

void f0_4(double ad_0, double ad_8) {
   RefreshRates();
   if (OrdersTotal() > 0) {
      for (g_pos_392 = OrdersTotal(); g_pos_392 >= 0; g_pos_392--) {
         OrderSelect(g_pos_392, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
            if (OrderType() == OP_BUY) {
               if (!(NormalizeDouble(Ask, Digits) > NormalizeDouble(OrderOpenPrice() + ad_0 * gd_792, Digits) && NormalizeDouble(OrderStopLoss(), Digits) < NormalizeDouble(Bid - (ad_8 +
                  gd_200) * gd_792, Digits))) continue;
               OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Bid - ad_8 * gd_792, Digits), OrderTakeProfit(), 0, Blue);
               return;
            }
            if (NormalizeDouble(Bid, Digits) < NormalizeDouble(OrderOpenPrice() - ad_0 * gd_792, Digits) && NormalizeDouble(OrderStopLoss(), Digits) > NormalizeDouble(Ask + (ad_8 +
               gd_200) * gd_792, Digits) || OrderStopLoss() == 0.0) {
               OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Ask + ad_8 * gd_792, Digits), OrderTakeProfit(), 0, Red);
               return;
            }
         }
      }
   }
}

void f0_5(double ad_0, double ad_8) {
   RefreshRates();
   for (g_pos_392 = OrdersTotal(); g_pos_392 >= 0; g_pos_392--) {
      if (OrderSelect(g_pos_392, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
            if (OrderType() == OP_BUY) {
               if (NormalizeDouble(Bid - OrderOpenPrice(), Digits) <= NormalizeDouble((-1.0 * ad_0) * gd_792, Digits))
                  if (NormalizeDouble(OrderTakeProfit(), Digits) > NormalizeDouble(Bid + (ad_8 + gd_200) * gd_792, Digits) || NormalizeDouble(OrderTakeProfit(), Digits) == 0.0) OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormalizeDouble(Bid + ad_8 * gd_792, Digits), 0, Blue);
            }
            if (OrderType() == OP_SELL) {
               if (NormalizeDouble(OrderOpenPrice() - Ask, Digits) <= NormalizeDouble((-1.0 * ad_0) * gd_792, Digits))
                  if (NormalizeDouble(OrderTakeProfit(), Digits) < NormalizeDouble(Ask - (ad_8 + gd_200) * gd_792, Digits)) OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormalizeDouble(Ask - ad_8 * gd_792, Digits), 0, Red);
            }
         }
      }
   }
}

double f0_2() {
   double ld_0 = AccountBalance() - AccountEquity();
   if (ld_0 > gd_868) gd_868 = ld_0;
   return (gd_868);
}

void f0_1(double ad_0, double ad_8) {
   for (g_pos_392 = OrdersTotal(); g_pos_392 >= 0; g_pos_392--) {
      OrderSelect(g_pos_392, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
         if (OrderType() == OP_BUY) {
            if (OrderStopLoss() == 0.0 && ad_0 > 0.0 && ad_8 == 0.0) {
               RefreshRates();
               OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Ask - ad_0 * gd_792, Digits), OrderTakeProfit(), 0, Red);
            }
            if (OrderTakeProfit() == 0.0 && ad_0 == 0.0 && ad_8 > 0.0) {
               RefreshRates();
               OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormalizeDouble(Ask + ad_8 * gd_792, Digits), 0, Red);
            }
            if (OrderTakeProfit() == 0.0 && OrderStopLoss() == 0.0 && ad_0 > 0.0 && ad_8 > 0.0) {
               RefreshRates();
               OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Ask - ad_0 * gd_792, Digits), NormalizeDouble(Ask + ad_8 * gd_792, Digits), 0, Red);
            }
         }
         if (OrderType() == OP_SELL) {
            if (OrderStopLoss() == 0.0 && ad_0 > 0.0 && ad_8 == 0.0) {
               RefreshRates();
               OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Bid + ad_0 * gd_792, Digits), OrderTakeProfit(), 0, Red);
            }
            if (OrderTakeProfit() == 0.0 && ad_0 == 0.0 && ad_8 > 0.0) {
               RefreshRates();
               OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormalizeDouble(Bid - ad_8 * gd_792, Digits), 0, Red);
            }
            if (OrderTakeProfit() == 0.0 && OrderStopLoss() == 0.0 && ad_0 > 0.0 && ad_8 > 0.0) {
               RefreshRates();
               OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Bid + ad_0 * gd_792, Digits), NormalizeDouble(Bid - ad_8 * gd_792, Digits), 0, Red);
            }
         }
      }
   }
}

string f0_9(int ai_0) {
   string ls_ret_4;
   switch (ai_0) {
   case 0:
   case 1:
      ls_ret_4 = "no error";
      break;
   case 2:
      ls_ret_4 = "common error";
      break;
   case 3:
      ls_ret_4 = "invalid trade parameters";
      break;
   case 4:
      ls_ret_4 = "trade server is busy";
      break;
   case 5:
      ls_ret_4 = "old version of the client terminal";
      break;
   case 6:
      ls_ret_4 = "no connection with trade server";
      break;
   case 7:
      ls_ret_4 = "not enough rights";
      break;
   case 8:
      ls_ret_4 = "too frequent requests";
      break;
   case 9:
      ls_ret_4 = "malfunctional trade operation";
      break;
   case 64:
      ls_ret_4 = "account disabled";
      break;
   case 65:
      ls_ret_4 = "invalid account";
      break;
   case 128:
      ls_ret_4 = "trade timeout";
      break;
   case 129:
      ls_ret_4 = "invalid price";
      break;
   case 130:
      ls_ret_4 = "invalid stops";
      break;
   case 131:
      ls_ret_4 = "invalid trade volume";
      break;
   case 132:
      ls_ret_4 = "market is closed";
      break;
   case 133:
      ls_ret_4 = "trade is disabled";
      break;
   case 134:
      ls_ret_4 = "not enough money";
      break;
   case 135:
      ls_ret_4 = "price changed";
      break;
   case 136:
      ls_ret_4 = "off quotes";
      break;
   case 137:
      ls_ret_4 = "broker is busy";
      break;
   case 138:
      ls_ret_4 = "requote";
      break;
   case 139:
      ls_ret_4 = "order is locked";
      break;
   case 140:
      ls_ret_4 = "long positions only allowed";
      break;
   case 141:
      ls_ret_4 = "too many requests";
      break;
   case 145:
      ls_ret_4 = "modification denied because order too close to market";
      break;
   case 146:
      ls_ret_4 = "trade context is busy";
      break;
   case 4000:
      ls_ret_4 = "no error";
      break;
   case 4001:
      ls_ret_4 = "wrong function pointer";
      break;
   case 4002:
      ls_ret_4 = "array index is out of range";
      break;
   case 4003:
      ls_ret_4 = "no memory for function call stack";
      break;
   case 4004:
      ls_ret_4 = "recursive stack overflow";
      break;
   case 4005:
      ls_ret_4 = "not enough stack for parameter";
      break;
   case 4006:
      ls_ret_4 = "no memory for parameter string";
      break;
   case 4007:
      ls_ret_4 = "no memory for temp string";
      break;
   case 4008:
      ls_ret_4 = "not initialized string";
      break;
   case 4009:
      ls_ret_4 = "not initialized string in array";
      break;
   case 4010:
      ls_ret_4 = "no memory for array\' string";
      break;
   case 4011:
      ls_ret_4 = "too long string";
      break;
   case 4012:
      ls_ret_4 = "remainder from zero divide";
      break;
   case 4013:
      ls_ret_4 = "zero divide";
      break;
   case 4014:
      ls_ret_4 = "unknown command";
      break;
   case 4015:
      ls_ret_4 = "wrong jump (never generated error)";
      break;
   case 4016:
      ls_ret_4 = "not initialized array";
      break;
   case 4017:
      ls_ret_4 = "dll calls are not allowed";
      break;
   case 4018:
      ls_ret_4 = "cannot load library";
      break;
   case 4019:
      ls_ret_4 = "cannot call function";
      break;
   case 4020:
      ls_ret_4 = "expert function calls are not allowed";
      break;
   case 4021:
      ls_ret_4 = "not enough memory for temp string returned from function";
      break;
   case 4022:
      ls_ret_4 = "system is busy (never generated error)";
      break;
   case 4050:
      ls_ret_4 = "invalid function parameters count";
      break;
   case 4051:
      ls_ret_4 = "invalid function parameter value";
      break;
   case 4052:
      ls_ret_4 = "string function internal error";
      break;
   case 4053:
      ls_ret_4 = "some array error";
      break;
   case 4054:
      ls_ret_4 = "incorrect series array using";
      break;
   case 4055:
      ls_ret_4 = "custom indicator error";
      break;
   case 4056:
      ls_ret_4 = "arrays are incompatible";
      break;
   case 4057:
      ls_ret_4 = "global variables processing error";
      break;
   case 4058:
      ls_ret_4 = "global variable not found";
      break;
   case 4059:
      ls_ret_4 = "function is not allowed in testing mode";
      break;
   case 4060:
      ls_ret_4 = "function is not confirmed";
      break;
   case 4061:
      ls_ret_4 = "send mail error";
      break;
   case 4062:
      ls_ret_4 = "string parameter expected";
      break;
   case 4063:
      ls_ret_4 = "integer parameter expected";
      break;
   case 4064:
      ls_ret_4 = "double parameter expected";
      break;
   case 4065:
      ls_ret_4 = "array as parameter expected";
      break;
   case 4066:
      ls_ret_4 = "requested history data in update state";
      break;
   case 4099:
      ls_ret_4 = "end of file";
      break;
   case 4100:
      ls_ret_4 = "some file error";
      break;
   case 4101:
      ls_ret_4 = "wrong file name";
      break;
   case 4102:
      ls_ret_4 = "too many opened files";
      break;
   case 4103:
      ls_ret_4 = "cannot open file";
      break;
   case 4104:
      ls_ret_4 = "incompatible access to a file";
      break;
   case 4105:
      ls_ret_4 = "no order selected";
      break;
   case 4106:
      ls_ret_4 = "unknown symbol";
      break;
   case 4107:
      ls_ret_4 = "invalid price parameter for trade function";
      break;
   case 4108:
      ls_ret_4 = "invalid ticket";
      break;
   case 4109:
      ls_ret_4 = "trade is not allowed";
      break;
   case 4110:
      ls_ret_4 = "longs are not allowed";
      break;
   case 4111:
      ls_ret_4 = "shorts are not allowed";
      break;
   case 4200:
      ls_ret_4 = "object is already exist";
      break;
   case 4201:
      ls_ret_4 = "unknown object property";
      break;
   case 4202:
      ls_ret_4 = "object is not exist";
      break;
   case 4203:
      ls_ret_4 = "unknown object type";
      break;
   case 4204:
      ls_ret_4 = "no object name";
      break;
   case 4205:
      ls_ret_4 = "object coordinates error";
      break;
   case 4206:
      ls_ret_4 = "no specified subwindow";
      break;
   default:
      ls_ret_4 = "unknown error";
   }
   return (ls_ret_4);
}