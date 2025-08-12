/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website:  http://WwW .m EtAQ UOt ES . n Et
   E-mail : s UPP o R T@ M eta q u oT e s . N e t
*/
#property copyright "My4xScalper GOLD Copyright © 2013, Forex Zone Ltd. ver. 1.1"
#property link      "www.my4xstore.com"

int G_magic_76;
extern string _______________ = "-------------- My4xScalper EUR/USD M5 ver 1.1 --------------";
int Gi_88 = 0;
string Gs_92 = "Your Registered Login";
string Gs_100 = "Your Password here";
extern int ID_STRATEGY = 24816;
extern double MIN_PROFIT = 2.0;
extern double def_lots = 0.01;
extern int Max_Num_BUY = 2;
extern int Max_Num_SELL = 2;
extern int EXPERT_LEVEL = 1;
extern bool ADDITIONAL_POSITION = TRUE;
extern int ADD_POSITION_PROFIT = 5;
extern int ADD_POSITION_SL = 0;
int Gi_152 = 1;
extern int BEGIN_BREAK_HOUR = 6;
extern int END_BREAK_HOUR = 9;
extern int BEGIN_BREAK_HOUR_2 = 16;
extern int END_BREAK_HOUR_2 = 18;
extern int STOP_loss_buy_def = 0;
extern double STOP_profit_buy_def = 3.0;
extern int STOP_loss_sell_def = 0;
extern double STOP_profit_sell_def = 3.0;
extern bool Monday = TRUE;
extern bool Tuesday = TRUE;
extern bool Wednesday = TRUE;
extern bool Thursday = TRUE;
extern bool Friday = FALSE;
double Gd_unused_216 = 0.1;
double G_period_224 = 12.0;
double Gd_232 = 6.0;
int Gi_240 = 0;
double Gd_244 = 0.0;
int Gi_252 = 0;
bool Gi_256 = FALSE;
int Gi_260 = 0;
bool Gi_264 = FALSE;
double Gd_268 = 0.0;
double Gd_276 = 0.0;
int G_bars_284 = 0;
int G_bars_288 = 0;
bool G_bars_292 = FALSE;
bool G_bars_296 = FALSE;
bool Gi_300 = FALSE;
bool Gi_304 = FALSE;
bool Gi_308 = FALSE;
int Gi_312 = 0;
int Gi_316 = 0;
string Gs_320 = "";
int Gi_328;
int Gi_332 = 1;
double Gd_336 = 0.0;
double G_order_open_price_344 = 0.0;
double Gd_352 = 0.0;
double G_order_open_price_360 = 0.0;
double Gd_368 = 0.0;
double Gd_376 = 0.0;
double Gd_384 = 0.0;
string Gs_392 = "12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234";
bool Gi_400 = FALSE;
int Gi_404 = 1;
bool Gi_408 = TRUE;
int G_acc_number_412 = 0;
bool G_bool_416 = FALSE;

// 689C35E4872BA754D7230B8ADAA28E48
int f0_6(int A_cmd_0) {
   int count_4 = 0;
   for (int pos_8 = 0; pos_8 < OrdersTotal(); pos_8++) {
      if (OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES) == FALSE) break;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_76)
         if (OrderType() == A_cmd_0) count_4++;
   }
   return (count_4);
}

// 2569208C5E61CB15E209FFE323DB48B7
int f0_2(int A_cmd_0) {
   int count_4 = 0;
   for (int pos_8 = 0; pos_8 < OrdersTotal(); pos_8++) {
      if (OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES) == FALSE) break;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == G_magic_76 + 1)
         if (OrderType() == A_cmd_0) count_4++;
   }
   return (count_4);
}

// D1DDCE31F1A86B3140880F6B1877CBF8
double f0_18() {
   return (def_lots);
}

// 09CBB5F5CE12C31A043D5C81BF20AA4A
void f0_0() {
   string magic_0;
   int ticket_8;
   int ticket_12;
   bool Li_16;
   bool Li_20;
   double ima_24;
   double ima_32;
   double irvi_40;
   double ima_48;
   double irsi_56;
   double imomentum_64;
   double price_72;
   double price_80;
   int Li_88;
   int error_92;
   int ticket_96;
   double price_100;
   double price_108;
   int Li_116;
   int error_120;
   int ticket_124;
   if (TimeDayOfWeek(TimeCurrent()) != 0) {
      if (TimeDayOfWeek(TimeCurrent()) == 1 && Monday == FALSE) return;
      if (TimeDayOfWeek(TimeCurrent()) == 2 && Tuesday == FALSE) return;
      if (TimeDayOfWeek(TimeCurrent()) == 3 && Wednesday == FALSE) return;
      if (TimeDayOfWeek(TimeCurrent()) == 4 && Thursday == FALSE) return;
      if (TimeDayOfWeek(TimeCurrent()) == 5 && Friday == FALSE) return;
      if (TimeDayOfWeek(TimeCurrent()) == 1 && TimeHour(TimeCurrent()) == 0 && TimeMinute(TimeCurrent()) >= 0 && TimeMinute(TimeCurrent()) <= 3) {
         G_bars_296 = FALSE;
         G_bars_292 = FALSE;
      }
      if (Gi_328 < Gi_152) {
         if (TimeHour(TimeCurrent()) < Gi_152) return;
         Gi_328 = Gi_152;
      }
      if (TimeHour(TimeCurrent()) >= BEGIN_BREAK_HOUR && TimeHour(TimeCurrent()) < END_BREAK_HOUR) return;
      if (TimeHour(TimeCurrent()) >= BEGIN_BREAK_HOUR_2 && TimeHour(TimeCurrent()) < END_BREAK_HOUR_2) return;
      magic_0 = G_magic_76;
      ticket_8 = 0;
      ticket_12 = 0;
      Li_16 = FALSE;
      Li_20 = FALSE;
      Gi_304 = TRUE;
      Gi_300 = TRUE;
      if (f0_6(OP_BUY) > 0) {
         Gi_300 = FALSE;
         Gi_304 = TRUE;
      }
      if (f0_6(OP_SELL) > 0) {
         Gi_304 = FALSE;
         Gi_300 = TRUE;
      }
      ima_24 = iMA(NULL, 0, 26, 0, MODE_SMA, PRICE_CLOSE, 0);
      ima_32 = iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_CLOSE, 0);
      irvi_40 = iRVI(NULL, 0, 6, MODE_MAIN, 0);
      G_period_224 = 12;
      Gd_232 = 6;
      if (EXPERT_LEVEL == 2) Gd_232 = 3;
      ima_48 = iMA(NULL, 0, G_period_224, Gd_232, MODE_SMA, PRICE_CLOSE, 0);
      irsi_56 = iRSI(NULL, 0, 5, PRICE_CLOSE, 0);
      imomentum_64 = iMomentum(NULL, 0, 12, PRICE_CLOSE, 0);
      if (ADDITIONAL_POSITION == TRUE) f0_12();
      if (f0_11(ima_24, ima_32, irvi_40, ima_48, irsi_56, Gi_332, Point, Open[0], Close[0], Open[1], Close[1], Gs_392, G_acc_number_412, Gi_88, Gs_92, Gs_100, Gi_404, G_bool_416,
         AccountServer()) == 1) {
         Li_16 = f0_6(OP_SELL);
         Gi_316 = Li_16;
         Gd_276 = f0_14(ima_24, ima_32, irvi_40, Li_16, Bars, G_bars_284, Gd_276, Bid, Gi_332, Close[1], Point, Gs_392, G_acc_number_412, Gi_88, Gs_92, Gs_100, Gi_404, G_bool_416);
         if (f0_16(EXPERT_LEVEL, irvi_40, ima_32, Close[0], ima_48, Li_16, Max_Num_SELL, Close[1], Bid, Gd_276, Bars, G_bars_296, irsi_56, imomentum_64, Gi_300, G_bars_284,
            G_bars_288, Gs_392, G_acc_number_412, Gi_88, Gs_92, Gs_100, Gi_404) == 1) {
            price_72 = 0;
            price_80 = 0;
            RefreshRates();
            if (Gi_260 == 0) price_72 = 0;
            else price_72 = Bid + Gi_260 * Point;
            price_72 = NormalizeDouble(price_72, Digits);
            if (Gi_264 == FALSE) price_80 = 0;
            else price_80 = Bid - Gi_264 * Point;
            price_80 = NormalizeDouble(price_80, Digits);
            Li_88 = f0_1(Max_Num_SELL);
            for (int count_128 = 0; count_128 < Li_88; count_128++) {
               if (f0_6(OP_SELL) < Li_88) {
                  ticket_8 = OrderSend(Symbol(), OP_SELL, f0_18(), Bid, 5, price_72, price_80, magic_0, G_magic_76, 0, Red);
                  if (ticket_8 < 0) {
                     Print("Order [Sell] Error: " + GetLastError() + " Send Again");
                     Sleep(200);
                     RefreshRates();
                     ticket_12 = OrderSend(Symbol(), OP_SELL, f0_18(), Bid, 5, price_72, price_80, magic_0, G_magic_76, 0, Red);
                     if (ticket_12 < 0) {
                        error_92 = GetLastError();
                        Print("Again Order [Sell] Error: " + error_92);
                        Print("Open ECN Order [Sell]");
                        if (error_92 == 130/* INVALID_STOPS */) {
                           Sleep(100);
                           RefreshRates();
                           ticket_96 = OrderSend(Symbol(), OP_SELL, f0_18(), Bid, 5, 0, 0, magic_0, G_magic_76, 0, Red);
                           if (ticket_96 > 0) {
                              Sleep(200);
                              if (OrderModify(ticket_96, OrderOpenPrice(), price_72, price_80, 0, Red)) {
                                 Print("Order [Sell] modify: stop loss and take profit");
                                 Gi_304 = FALSE;
                                 G_bars_296 = Bars;
                                 Gd_336 = OrderTakeProfit();
                                 G_order_open_price_344 = OrderOpenPrice();
                                 f0_4();
                              } else Print("Order [Sell] " + ticket_96 + " modify Error: " + GetLastError());
                           } else Print("Order [Sell] ECN Open Error: " + GetLastError());
                        }
                     } else {
                        Gi_304 = FALSE;
                        G_bars_296 = Bars;
                        Gd_336 = OrderTakeProfit();
                        G_order_open_price_344 = OrderOpenPrice();
                        f0_4();
                     }
                  } else {
                     Gi_304 = FALSE;
                     G_bars_296 = Bars;
                     Gd_336 = OrderTakeProfit();
                     G_order_open_price_344 = OrderOpenPrice();
                     f0_4();
                  }
                  RefreshRates();
               }
            }
            return;
         }
      }
      if (f0_9(ima_24, ima_32, irvi_40, ima_48, imomentum_64, Gi_332, Point, Open[0], Close[0], Open[1], Close[1], Gs_392, G_acc_number_412, Gi_88, Gs_92, Gs_100, Gi_404,
         G_bool_416, AccountServer()) == 1) {
         Li_20 = f0_6(OP_BUY);
         Gi_312 = Li_20;
         Gd_268 = f0_13(ima_24, ima_32, irvi_40, Li_20, Bars, G_bars_288, Gd_268, Ask, Gi_332, Close[1], Point, Gs_392, G_acc_number_412, Gi_88, Gs_92, Gs_100, Gi_404, G_bool_416);
         if (f0_19(EXPERT_LEVEL, irvi_40, ima_32, Close[0], ima_48, Li_20, Max_Num_BUY, Close[1], Ask, Gd_268, Bars, G_bars_292, irsi_56, imomentum_64, Gi_304, G_bars_288,
            G_bars_284, Gs_392, G_acc_number_412, Gi_88, Gs_92, Gs_100, Gi_404) == 1) {
            price_100 = 0;
            price_108 = 0;
            RefreshRates();
            if (Gi_252 == 0) price_100 = 0;
            else price_100 = Ask - Gi_252 * Point;
            price_100 = NormalizeDouble(price_100, Digits);
            if (Gi_256 == FALSE) price_108 = 0;
            else price_108 = Ask + Gi_256 * Point;
            price_108 = NormalizeDouble(price_108, Digits);
            Li_116 = f0_5(Max_Num_BUY);
            for (int count_132 = 0; count_132 < Li_116; count_132++) {
               if (f0_6(OP_BUY) < Li_116) {
                  ticket_8 = OrderSend(Symbol(), OP_BUY, f0_18(), Ask, 5, price_100, price_108, magic_0, G_magic_76, 0, Blue);
                  if (ticket_8 < 0) {
                     Print("Order [Buy] Error: " + GetLastError() + " Send Again");
                     Sleep(200);
                     RefreshRates();
                     ticket_12 = OrderSend(Symbol(), OP_BUY, f0_18(), Ask, 5, price_100, price_108, magic_0, G_magic_76, 0, Blue);
                     if (ticket_12 < 0) {
                        error_120 = GetLastError();
                        Print("Again Order [Buy] Error: " + error_120);
                        Print("Open ECN Order [Buy]");
                        if (error_120 == 130/* INVALID_STOPS */) {
                           Sleep(100);
                           RefreshRates();
                           ticket_124 = OrderSend(Symbol(), OP_BUY, f0_18(), Ask, 5, 0, 0, magic_0, G_magic_76, 0, Blue);
                           if (ticket_124 > 0) {
                              Sleep(200);
                              if (OrderModify(ticket_124, OrderOpenPrice(), price_100, price_108, 0, Red)) {
                                 Print("Order [Buy] modify: set stop loss and take profit");
                                 Gi_300 = FALSE;
                                 G_bars_292 = Bars;
                                 Gd_352 = OrderTakeProfit();
                                 G_order_open_price_360 = OrderOpenPrice();
                                 f0_4();
                              } else Print("Order [Buy] " + ticket_124 + " modify Error: " + GetLastError());
                           } else Print("Order [Buy] ECN open Error: " + GetLastError());
                        }
                     } else {
                        Gi_300 = FALSE;
                        G_bars_292 = Bars;
                        Gd_352 = OrderTakeProfit();
                        G_order_open_price_360 = OrderOpenPrice();
                        f0_4();
                     }
                  } else {
                     Gi_300 = FALSE;
                     G_bars_292 = Bars;
                     Gd_352 = OrderTakeProfit();
                     G_order_open_price_360 = OrderOpenPrice();
                     f0_4();
                  }
                  RefreshRates();
               }
            }
         }
      }
   }
}

// 6ABA3523C7A75AAEA41CC0DEC7953CC5
void f0_7() {
   double Ld_0;
   double Ld_8;
   double order_open_price_16;
   int is_closed_24;
   double order_open_price_28;
   int is_closed_36;
   double Ld_40 = Gd_244 * Point;
   Ld_40 = NormalizeDouble(Ld_40, Digits);
   double ima_48 = iMA(NULL, 0, 26, 0, MODE_SMA, PRICE_CLOSE, 0);
   double ima_56 = iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_CLOSE, 0);
   double irvi_64 = iRVI(NULL, 0, 6, MODE_MAIN, 0);
   int Li_72 = f0_6(OP_SELL);
   int Li_76 = f0_6(OP_BUY);
   if (Li_72 > 0 && Li_72 % 2 == 1) {
      Ld_0 = f0_10(OP_SELL, Ld_40);
      if (Ld_0 > 0.0) {
         Gd_276 = Ld_0;
         G_bars_284 = Bars;
      }
   }
   if (Li_76 > 0 && Li_76 % 2 == 1) {
      Ld_8 = f0_10(OP_BUY, Ld_40);
      if (Ld_8 > 0.0) {
         Gd_268 = Ld_8;
         G_bars_288 = Bars;
      }
   }
   for (int pos_80 = 0; pos_80 < OrdersTotal(); pos_80++) {
      if (OrderSelect(pos_80, SELECT_BY_POS, MODE_TRADES) == FALSE) break;
      if (OrderSymbol() == Symbol()) {
         if (OrderMagicNumber() != G_magic_76 && OrderMagicNumber() != G_magic_76 + 1) continue;
         if (OrderType() != OP_BUY && OrderType() != OP_SELL) continue;
         if (OrderType() == OP_SELL) {
            order_open_price_16 = OrderOpenPrice();
            if (f0_8(order_open_price_16, Close[0], Ask, Ld_40, OrderProfit(), Gi_240, ima_48, ima_56, irvi_64) == 1 && OrderMagicNumber() == G_magic_76) {
               RefreshRates();
               if (OrderCloseTime() > 0) continue;
               is_closed_24 = OrderClose(OrderTicket(), OrderLots(), Ask, 3, White);
               if (is_closed_24 == 0) Print("Order SELL [" + OrderTicket() + "] Close Error: " + GetLastError());
               else {
                  Gd_276 = OrderClosePrice();
                  G_bars_284 = Bars;
                  Gd_336 = 0;
                  G_order_open_price_344 = 0;
                  Gd_368 = 0;
                  Gd_376 = 0;
                  Gd_384 = 0;
               }
            }
            if (!((OrderOpenPrice() >= Ask + NormalizeDouble(ADD_POSITION_PROFIT * Gi_332 * Point, Digits) && OrderMagicNumber() == G_magic_76 + 1 && OrderProfit() > 0.0))) continue;
            if (OrderCloseTime() > 0) continue;
            OrderClose(OrderTicket(), OrderLots(), Ask, 3, White);
            continue;
         }
         if (OrderType() == OP_BUY) {
            order_open_price_28 = OrderOpenPrice();
            if (f0_15(order_open_price_28, Close[0], Bid, Ld_40, OrderProfit(), Gi_240, ima_48, ima_56, irvi_64) == 1 && OrderMagicNumber() == G_magic_76) {
               RefreshRates();
               if (OrderCloseTime() > 0) continue;
               is_closed_36 = OrderClose(OrderTicket(), OrderLots(), Bid, 3, White);
               if (is_closed_36 == 0) Print("Order BUY [" + OrderTicket() + "] Close Error: " + GetLastError());
               else {
                  Gd_268 = OrderClosePrice();
                  G_bars_288 = Bars;
                  Gd_352 = 0;
                  G_order_open_price_360 = 0;
                  Gd_368 = 0;
                  Gd_376 = 0;
                  Gd_384 = 0;
               }
            }
            if (OrderOpenPrice() <= Bid - ADD_POSITION_PROFIT * Gi_332 * Point && OrderMagicNumber() == G_magic_76 + 1 && OrderProfit() > 0.0)
               if (OrderCloseTime() <= 0) OrderClose(OrderTicket(), OrderLots(), Bid, 3, White);
         }
      }
   }
}

// A9B24A824F70CC1232D1C2BA27039E8D
double f0_17(int Ai_0, int A_cmd_4, double Ad_8) {
   double price_16;
   int is_closed_24;
   double price_28 = 0;
   for (int pos_36 = 0; pos_36 < OrdersTotal(); pos_36++) {
      if (OrderSelect(pos_36, SELECT_BY_POS, MODE_TRADES) == FALSE) break;
      if (OrderMagicNumber() != G_magic_76 || OrderSymbol() != Symbol()) continue;
      if (OrderType() == A_cmd_4 && TimeDayOfYear(OrderOpenTime()) == TimeDayOfYear(Ai_0) && OrderProfit() > 0.0 && TimeHour(OrderOpenTime()) == TimeHour(Ai_0) && TimeMinute(OrderOpenTime()) == TimeMinute(Ai_0)) {
         price_16 = 0;
         RefreshRates();
         if (A_cmd_4 == OP_BUY) price_16 = Bid;
         else
            if (A_cmd_4 == OP_SELL) price_16 = Ask;
         if (OrderProfit() > 0.0) {
            if (A_cmd_4 == OP_SELL && OrderOpenPrice() < Ask + Ad_8 / 3.0) continue;
            if (A_cmd_4 == OP_BUY && OrderOpenPrice() > Bid - Ad_8 / 3.0) continue;
            if (OrderCloseTime() <= 0) {
               if (OrderProfit() > 0.0) {
                  is_closed_24 = OrderClose(OrderTicket(), OrderLots(), price_16, 3, White);
                  if (is_closed_24 > 0) {
                     price_28 = price_16;
                     if (A_cmd_4 == OP_SELL) {
                        Gd_336 = 0;
                        G_order_open_price_344 = 0;
                     }
                     if (A_cmd_4 == OP_BUY) {
                        Gd_352 = 0;
                        G_order_open_price_360 = 0;
                     }
                     Gd_368 = 0;
                     Gd_376 = 0;
                     Gd_384 = 0;
                  }
               }
            }
         }
      }
   }
   return (price_28);
}

// 945D754CB0DC06D04243FCBA25FC0802
double f0_10(int A_cmd_0, double Ad_4) {
   double Ld_ret_12 = 0;
   int hist_total_20 = OrdersHistoryTotal();
   for (int pos_24 = 0; pos_24 < hist_total_20; pos_24++) {
      if (OrderSelect(pos_24, SELECT_BY_POS, MODE_HISTORY) == FALSE) break;
      if (OrderMagicNumber() != G_magic_76 || OrderSymbol() != Symbol()) continue;
      if (OrderType() == A_cmd_0)
         if (OrderProfit() > 0.0 && OrderCloseTime() > 0) Ld_ret_12 = f0_17(OrderOpenTime(), A_cmd_0, Ad_4);
   }
   return (Ld_ret_12);
}

// 5710F6E623305B2C1458238C9757193B
void f0_4() {
   double ihigh_0 = iHigh(Symbol(), PERIOD_D1, 0);
   double ilow_8 = iLow(Symbol(), PERIOD_D1, 0);
   double iclose_16 = iClose(Symbol(), PERIOD_D1, 0);
   Gd_368 = (ihigh_0 + ilow_8 + iclose_16) / 3.0;
   Gd_376 = 2.0 * Gd_368 - ilow_8;
   Gd_384 = 2.0 * Gd_368 - ihigh_0;
}

// 9B1AEE847CFB597942D106A4135D4FE6
void f0_12() {
   int ticket_0;
   double price_4;
   double price_12;
   int ticket_20;
   double price_24;
   double price_32;
   double Ld_40 = (ADD_POSITION_PROFIT + 2) * Gi_332 * Point;
   Ld_40 = NormalizeDouble(Ld_40, Digits);
   string comment_48 = G_magic_76 + 1;
   double Ld_56 = (ADD_POSITION_PROFIT + 2) * Gi_332 * Point;
   Ld_56 = NormalizeDouble(Ld_56, Digits);
   double Ld_64 = ADD_POSITION_SL * Gi_332 * Point;
   Ld_64 = NormalizeDouble(Ld_64, Digits);
   if (f0_3(f0_2(OP_SELL), G_bars_292, Bars, Gd_352, G_order_open_price_360, Ld_40, Gd_368, Gd_384, Close[0], Close[1], Close[2], Close[3], Ask) == 1) {
      ticket_0 = OrderSend(Symbol(), OP_SELL, f0_18(), Bid, 5, 0, 0, comment_48, G_magic_76 + 1, 0, Yellow);
      if (ticket_0 > 0) {
         Sleep(200);
         RefreshRates();
         price_4 = Gd_336;
         if (price_4 == 0.0) price_4 = Bid - Ld_56;
         OrderSelect(ticket_0, SELECT_BY_TICKET);
         price_12 = Bid + Ld_64;
         price_12 = NormalizeDouble(price_12, Digits);
         if (OrderModify(ticket_0, OrderOpenPrice(), price_12, price_4, 0, Yellow)) Print("Order [Sell] modify ADDED: set stop loss and take profit");
         else Print("Order [Sell] " + ticket_0 + " modify ADDED Error: " + GetLastError());
      }
   }
   if (f0_20(f0_2(OP_BUY), G_bars_296, Bars, Gd_336, G_order_open_price_344, Ld_40, Gd_368, Gd_376, Close[0], Close[1], Close[2], Close[3], Bid) == 1) {
      ticket_20 = OrderSend(Symbol(), OP_BUY, f0_18(), Ask, 5, 0, 0, comment_48, G_magic_76 + 1, 0, Green);
      if (ticket_20 > 0) {
         Sleep(200);
         RefreshRates();
         price_24 = Gd_352;
         if (price_24 == 0.0) price_24 = Ask + Ld_56;
         OrderSelect(ticket_20, SELECT_BY_TICKET);
         price_32 = Ask - Ld_64;
         price_32 = NormalizeDouble(price_32, Digits);
         if (OrderModify(ticket_20, OrderOpenPrice(), price_32, price_24, 0, Green)) Print("Order [Buy] modify ADDED: set stop loss and take profit");
         else Print("Order [Buy] modify ADDED Error: " + GetLastError());
      }
   }
}

// E37F0136AA3FFAF149B351F6A4C948E9
void init() {
   HideTestIndicators(TRUE);
   G_magic_76 = ID_STRATEGY;
   Gi_328 = 0;
   if (G_magic_76 == 0) {
      Alert("Wrong identity number: ID_STRATEGY: " + G_magic_76);
      Comment("\n\n\n Wrong identity number: ID_STRATEGY!!!");
      Gi_308 = TRUE;
      return;
   }
   Comment("\n\n\n\n");
   Gi_400 = FALSE;
   G_acc_number_412 = AccountNumber();
   G_bool_416 = IsDemo();
   Gi_408 = TRUE;
   double point_4 = MarketInfo(Symbol(), MODE_POINT);
   if (100000.0 * point_4 == 1.0) Gi_332 = 10;
   else Gi_332 = 1;
   Print("Ratio: " + Gi_332);
   Gd_244 = 0;
   Gi_252 = 0;
   Gi_256 = FALSE;
   Gi_260 = 0;
   Gi_264 = FALSE;
   Gd_244 = Gi_332 * MIN_PROFIT;
   Gi_252 = Gi_332 * STOP_loss_buy_def;
   Gi_256 = Gi_332 * STOP_profit_buy_def;
   Gi_260 = Gi_332 * STOP_loss_sell_def;
   Gi_264 = Gi_332 * STOP_profit_sell_def;
   Gs_320 = def_lots;
}

// EA2B2676C28C0DB26D39331A336C6B92
void start() {
   int Li_0;
   double Ld_4;
   string spread_12;
   string Ls_20;
   string Ls_28;
   if (EXPERT_LEVEL != 1 && EXPERT_LEVEL != 2) EXPERT_LEVEL = TRUE;
   if (Gi_308 == FALSE) {
      if (Gi_408 == FALSE) Comment("\n\n\nINVALID LICENSE NUMBER, PASSWORD OR USERLOGIN. CAN\'T CONTINUE.");
      else Comment("\n\n\n");
      G_acc_number_412 = AccountNumber();
      if (Gi_400 == FALSE) {
         Li_0 = -1;
         Gi_400 = TRUE;
         Gi_408 = FALSE;
         Li_0 = 1;
         if (Li_0 >= 0) Gi_408 = TRUE;
      }
      if (Bars < 100 || IsTradeAllowed() == FALSE) return;
      if (def_lots > 10.0) {
         Alert("Wrong Lots, maximum=10!!!");
         Comment("\n\n\n Wrong Lots, maximum=10!!!");
      } else {
         Comment("\n\n\n\n\n\n\n\n");
         if (Max_Num_BUY > 6 || Max_Num_SELL > 6) return;
         Ld_4 = MarketInfo(Symbol(), MODE_SPREAD);
         spread_12 = Ld_4;
         Ls_20 = Gd_244;
         Ls_28 = "false";
         if (ADDITIONAL_POSITION == TRUE) Ls_28 = "true";
         Comment("\n\nID STRATEGIA: " + G_magic_76 
            + "\n" 
            + "MIN_ORDER_PROFIT: " + StringSubstr(Ls_20, 0, 4) 
            + "\n[BUY]: " + Gi_312 
            + "\n" 
            + "[SELL]: " + Gi_316 
            + "\n" 
            + "Lots: " + StringSubstr(Gs_320, 0, 4) 
            + "\nSpread: " + StringSubstr(spread_12, 0, 4) 
            + "\nRatio: " + Gi_332 
            + "\nExpertLevel: " + EXPERT_LEVEL 
            + "\n\n----------------------------------\nAdditional Position: " + Ls_28 
         + "\nProfit: " + (ADD_POSITION_PROFIT * Gi_332));
         f0_7();
         f0_0();
      }
   }
}

// 82564BB23825BCFCF0FE6D5B5306413B
int f0_8(double Ad_0, double Ad_8, double Ad_16, double Ad_24, double Ad_32, double Ad_40, double Ad_48, double Ad_56, double Ad_unused_64) {
   if (Ad_48 != 0.0 && Ad_56 != 0.0 && Ad_0 + Ad_48 != 0.0 && Ad_16 + Ad_56 != 0.0 && Ad_0 > Ad_8 && Ad_16 + Ad_24 <= Ad_0 && Ad_32 > Ad_40) return (1);
   return (0);
}

// A32C481F3352A617CCFF46B7136E467C
int f0_15(double Ad_0, double Ad_8, double Ad_16, double Ad_24, double Ad_32, double Ad_40, double Ad_48, double Ad_56, double Ad_unused_64) {
   if (Ad_48 != 0.0 && Ad_56 != 0.0 && Ad_0 + Ad_48 != 0.0 && Ad_16 + Ad_56 != 0.0 && Ad_0 < Ad_8 && Ad_16 - Ad_24 >= Ad_0 && Ad_32 > Ad_40) return (1);
   return (0);
}

// 3B87D6AFA36FA9ECFF84BD8D83C48285
int f0_3(int Ai_0, int Ai_4, int Ai_8, double Ad_12, double Ad_20, double Ad_28, double Ad_36, double Ad_44, double Ad_52, double Ad_60, double Ad_68, double Ad_76, double Ad_84) {
   if (Ai_0 == 0 && Ai_4 > 0 && Ai_8 > Ai_4 && Ad_12 > 0.0 && Ad_20 - Ad_28 > Ad_84 && Ad_36 > 0.0 && Ad_44 > 0.0 && Ad_84 < Ad_36 && Ad_84 > Ad_44 && Ad_76 < Ad_60 &&
      Ad_68 < Ad_52) return (1);
   return (0);
}

// E9667AF5825CC32A8F2CE9937FE009C0
int f0_20(int Ai_0, int Ai_4, int Ai_8, double Ad_12, double Ad_20, double Ad_28, double Ad_36, double Ad_44, double Ad_52, double Ad_60, double Ad_68, double Ad_76, double Ad_84) {
   if (Ai_0 == 0 && Ai_4 > 0 && Ai_8 > Ai_4 && Ad_12 > 0.0 && Ad_20 + Ad_28 < Ad_84 && Ad_36 > 0.0 && Ad_44 > 0.0 && Ad_84 > Ad_36 && Ad_84 < Ad_44 && Ad_76 > Ad_60 &&
      Ad_68 > Ad_52) return (1);
   return (0);
}

// 1E3420D98727178261F41335B8E1E7B8
int f0_1(int Ai_0) {
   if (Ai_0 > 4) return (1);
   return (Ai_0);
}

// 661FFB8095DBD7F2FCEA5E7DF2C61AC0
int f0_5(int Ai_0) {
   return (f0_1(Ai_0));
}

// A60A9666D88F168547E1688C3064C30B
int f0_16(int Ai_0, double Ad_unused_4, double Ad_12, double Ad_unused_20, double Ad_28, int Ai_36, int Ai_unused_40, double Ad_44, double Ad_52, double Ad_60, int Ai_68, int Ai_72, double Ad_76, double Ad_84, int Ai_92, int Ai_96, int Ai_unused_100, string As_unused_104, int Ai_unused_112, int Ai_unused_116, string As_unused_120, string As_unused_128, int Ai_unused_136) {
   if (Ai_0 == 1) {
      if (Ad_76 <= 40.0 || Ad_76 >= 48.0) return (0);
   } else
      if (Ai_0 != 2 || Ad_76 <= 30.0 || Ad_76 >= 50.0) return (0);
   if (Ad_12 >= Ad_28 || Ai_36 >= 4 || Ad_44 >= Ad_28 || Ad_52 <= Ad_60 || Ai_68 <= Ai_72 + 1 || Ad_84 >= 100.0 || Ai_92 != 1 || Ai_68 <= Ai_96) return (0);
   return (1);
}

// E5B21AC25A9B70A6204D7CAECE6AF76C
int f0_19(int Ai_0, double Ad_unused_4, double Ad_unused_12, double Ad_20, double Ad_28, int Ai_36, int Ai_unused_40, double Ad_44, double Ad_52, double Ad_60, int Ai_68, int Ai_72, double Ad_76, double Ad_84, int Ai_92, int Ai_unused_96, int Ai_100, string As_unused_104, int Ai_unused_112, int Ai_unused_116, string As_unused_120, string As_unused_128, int Ai_unused_136) {
   if (Ai_0 == 1) {
      if (Ad_76 <= 52.0 || Ad_76 >= 60.0) return (0);
   } else
      if (Ai_0 != 2 || Ad_76 <= 50.0 || Ad_76 >= 80.0) return (0);
   if (Ad_20 <= Ad_28 || Ai_36 >= 4 || Ad_44 <= Ad_28 || Ad_52 >= Ad_60 || Ai_68 <= Ai_72 + 1 || Ad_84 <= 100.0 || Ai_92 != 1 || Ai_68 <= Ai_100) return (0);
   return (1);
}

// 8F72EF17FEC7187BAFC96F0AACB91F55
int f0_9(double Ad_unused_0, double Ad_unused_8, double Ad_unused_16, double Ad_unused_24, double Ad_unused_32, int Ai_unused_40, double Ad_unused_44, double Ad_52, double Ad_60, double Ad_68, double Ad_76, string As_unused_84, int Ai_unused_92, int Ai_unused_96, string As_unused_100, string As_unused_108, int Ai_unused_116, int Ai_unused_120, string As_unused_124) {
   if (Ad_60 <= Ad_52 || Ad_76 <= Ad_68) return (0);
   return (1);
}

// 99FEB39F860B1169E6CED38987D8747E
int f0_11(double Ad_unused_0, double Ad_unused_8, double Ad_unused_16, double Ad_unused_24, double Ad_unused_32, int Ai_unused_40, double Ad_unused_44, double Ad_52, double Ad_60, double Ad_68, double Ad_76, string As_unused_84, int Ai_unused_92, int Ai_unused_96, string As_unused_100, string As_unused_108, int Ai_unused_116, int Ai_unused_120, string As_unused_124) {
   if (Ad_60 >= Ad_52 || Ad_76 >= Ad_68) return (0);
   return (1);
}

// 9FC549D1A9B3DFEF12295780F31A85C6
double f0_14(double Ad_unused_0, double Ad_unused_8, double Ad_unused_16, int Ai_24, int Ai_28, int Ai_32, double Ad_36, double Ad_44, int Ai_52, double Ad_56, double Ad_64, string As_unused_72, int Ai_unused_80, int Ai_unused_84, string As_unused_88, string As_unused_96, int Ai_unused_104, int Ai_unused_108) {
   double Ld_ret_112 = Ad_36;
   if (Ai_24 == 0 && Ai_28 - Ai_32 > 0 && Ad_36 > 0.0 && Ad_44 - Ad_36 < (-4 * Ai_52) * Ad_64 || Ad_36 == 0.0) Ld_ret_112 = Ad_56 - 10000.0;
   return (Ld_ret_112);
}

// 9F1798FECC684E7D6709A77B659D86E9
double f0_13(double Ad_unused_0, double Ad_unused_8, double Ad_unused_16, int Ai_24, int Ai_28, int Ai_32, double Ad_36, double Ad_44, int Ai_52, double Ad_56, double Ad_64, string As_unused_72, int Ai_unused_80, int Ai_unused_84, string As_unused_88, string As_unused_96, int Ai_unused_104, int Ai_unused_108) {
   double Ld_ret_112 = Ad_36;
   if (Ai_24 == 0 && Ai_28 - Ai_32 > 0 && Ad_36 > 0.0 && Ad_44 - Ad_36 < (-4 * Ai_52) * Ad_64 || Ad_36 == 0.0) Ld_ret_112 = Ad_56 + 10000.0;
   return (Ld_ret_112);
}
