/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website: h tTP : //WW W. met a Q u Otes.n e t
   E-mail :  s uP P o R t@MetAquo Tes. nET
*/
#property copyright "Copyright © 2011, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

extern double Lots = 0.1;
extern bool Compound = FALSE;
extern double Pembagi = 10000.0;
extern string Pengali = "+++++++++++PENGALI+++++++++++=";
extern string RESISTANCE = "===========RESISTANCE===========";
extern double LOT_R4 = 16.0;
extern double LOT_MR4 = 8.0;
extern double LOT_R3 = 4.0;
extern double LOT_MR3 = 4.0;
extern double LOT_R2 = 2.0;
extern double LOT_MR2 = 2.0;
extern string SUPPORT = "===========SUPPORT=========== ";
extern double LOT_MS2 = 2.0;
extern double LOT_S2 = 2.0;
extern double LOT_MS3 = 4.0;
extern double LOT_S3 = 4.0;
extern double LOT_MS4 = 8.0;
extern double LOT_S4 = 16.0;
extern int MAGIC = 110489;
int G_count_220;
int G_count_224;
int G_count_228;
int G_order_total_236;
int G_count_240;
double G_order_open_price_244;
double G_order_lots_252;
int G_cmd_260;
double G_order_open_price_264;
double G_order_open_price_272;
double G_order_lots_280;
double G_order_lots_288;
bool G_is_closed_300;
bool G_is_deleted_304;
int G_slippage_308 = 10;
int Gi_312;
int Gi_316;
int G_count_320;
int G_count_324;
extern bool Pake_Lock_Profit = TRUE;
extern int Target1 = 5;
extern int LockProfiT1 = 3;
extern int Target2 = 6;
extern int LockProfiT2 = 4;
extern int Target3 = 7;
extern int LockProfiT3 = 5;
extern int Target4 = 8;
extern int LockProfiT4 = 6;
extern int Target5 = 9;
extern int LockProfiT5 = 7;
extern int Target6 = 10;
extern int LockProfiT6 = 8;
extern int Target7 = 11;
extern int LockProfiT7 = 9;
extern int Target8 = 12;
extern int LockProfiT8 = 10;
extern int Target9 = 13;
extern int LockProfiT9 = 11;
extern int Target10 = 14;
extern int LockProfiT10 = 12;
extern int Target11 = 15;
extern int LockProfiT11 = 13;
bool Gi_420 = TRUE;
bool Gi_424 = FALSE;
bool Gi_428 = FALSE;
bool Gi_432 = FALSE;
bool Gi_436 = FALSE;
bool Gi_440 = FALSE;
bool Gi_444 = FALSE;
bool Gi_448 = FALSE;
bool Gi_452 = FALSE;
bool Gi_456 = FALSE;
bool Gi_460 = FALSE;
extern string Good_Luck = "------------------------------------------------------------------------------------------";

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   double lots_248;
   double lots_272;
   double price_300;
   double Ld_308;
   double price_324;
   double Ld_332;
   if (Pake_Lock_Profit) f0_2();
   f0_8();
   if (G_count_224 < Gi_312) {
      f0_0(2);
      f0_0(2);
      f0_0(2);
   }
   f0_8();
   Gi_312 = G_count_224;
   f0_8();
   if (G_count_228 < Gi_316) {
      f0_0(3);
      f0_0(3);
      f0_0(3);
   }
   f0_8();
   Gi_316 = G_count_228;
   if (Compound) Lots = AccountBalance() / Pembagi;
   double lots_0 = NormalizeDouble(MarketInfo(Symbol(), MODE_MINLOT), Digits);
   double lots_8 = NormalizeDouble(MarketInfo(Symbol(), MODE_MAXLOT), Digits);
   if (Lots < lots_0) Lots = lots_0;
   if (Lots > lots_8) Lots = lots_8;
   double Ld_16 = NormalizeDouble(iClose(NULL, PERIOD_D1, 1), Digits);
   double Ld_24 = NormalizeDouble(iHigh(NULL, PERIOD_D1, 1), Digits);
   double Ld_32 = NormalizeDouble(iLow(NULL, PERIOD_D1, 1), Digits);
   double Ld_40 = NormalizeDouble((Ld_24 + Ld_32 + Ld_16) / 3.0, Digits);
   double price_48 = NormalizeDouble(2.0 * Ld_40 - Ld_32, Digits);
   double price_56 = NormalizeDouble(2.0 * Ld_40 - Ld_24, Digits);
   double price_64 = NormalizeDouble(Ld_40 + (price_48 - price_56), Digits);
   double price_72 = NormalizeDouble(Ld_40 - (price_48 - price_56), Digits);
   double price_80 = NormalizeDouble(2.0 * Ld_40 + (Ld_24 - 2.0 * Ld_32), Digits);
   double price_88 = NormalizeDouble(2.0 * Ld_40 - (2.0 * Ld_24 - Ld_32), Digits);
   double price_96 = NormalizeDouble(Ld_40 + 3.0 * (Ld_24 - Ld_32), Digits);
   double price_104 = NormalizeDouble(Ld_40 - 3.0 * (Ld_24 - Ld_32), Digits);
   double price_112 = NormalizeDouble((Ld_40 + price_48) / 2.0, Digits);
   double price_120 = NormalizeDouble((Ld_40 + price_56) / 2.0, Digits);
   double price_128 = NormalizeDouble((price_48 + price_64) / 2.0, Digits);
   double price_136 = NormalizeDouble((price_56 + price_72) / 2.0, Digits);
   double price_144 = NormalizeDouble((price_64 + price_80) / 2.0, Digits);
   double price_152 = NormalizeDouble((price_72 + price_88) / 2.0, Digits);
   double price_160 = NormalizeDouble((price_80 + price_96) / 2.0, Digits);
   double price_168 = NormalizeDouble((price_88 + price_104) / 2.0, Digits);
   int spread_176 = MarketInfo(Symbol(), MODE_SPREAD);
   int Li_180 = f0_6();
   int Li_184 = f0_7();
   int Li_188 = f0_11();
   int Li_192 = f0_3();
   int Li_196 = f0_14();
   double Ld_200 = f0_16();
   double Ld_208 = f0_5();
   double Ld_216 = f0_1();
   double Ld_224 = f0_4();
   double Ld_232 = f0_10();
   double Ld_240 = f0_12();
   if (Li_180 == 0) lots_248 = Lots;
   if (Li_180 != 0) lots_248 = 2.0 * Ld_232;
   double Ld_256 = NormalizeDouble(MarketInfo(Symbol(), MODE_MINLOT), Digits);
   double Ld_264 = NormalizeDouble(MarketInfo(Symbol(), MODE_MAXLOT), Digits);
   if (lots_248 < Ld_256) lots_248 = Ld_256;
   if (lots_248 > Ld_264) lots_248 = Ld_264;
   if (Li_184 == 0) lots_272 = Lots;
   if (Li_184 != 0) lots_272 = 2.0 * Ld_232;
   double Ld_280 = NormalizeDouble(MarketInfo(Symbol(), MODE_MINLOT), Digits);
   double Ld_288 = NormalizeDouble(MarketInfo(Symbol(), MODE_MAXLOT), Digits);
   if (lots_272 < Ld_280) lots_272 = Ld_280;
   if (lots_272 > Ld_288) lots_272 = Ld_288;
   if (Symbol() == "GOLD") {
      price_48 = NormalizeDouble(price_48, 1);
      price_56 = NormalizeDouble(price_56, 1);
      price_64 = NormalizeDouble(price_64, 1);
      price_72 = NormalizeDouble(price_72, 1);
      price_80 = NormalizeDouble(price_80, 1);
      price_88 = NormalizeDouble(price_88, 1);
      price_96 = NormalizeDouble(price_96, 1);
      price_104 = NormalizeDouble(price_104, 1);
   }
   int Li_296 = (Ld_24 - Ld_32) / Point / 3.0;
   f0_8();
   if (G_count_320 < 8 && Close[0] > price_120 && Hour() < 22) {
      if (f0_9("MS1 " + MAGIC) < 1) {
         OrderSend(Symbol(), OP_BUYLIMIT, lots_248, price_120, 5, 0, 0, "MS1 " + MAGIC, MAGIC, 0, Blue);
         Print("masuk1");
      }
      if (f0_9("S1 " + MAGIC) < 1) {
         OrderSend(Symbol(), OP_BUYLIMIT, lots_248, price_56, 5, 0, 0, "S1 " + MAGIC, MAGIC, 0, Blue);
         Print("masuk2");
      }
      if (f0_9("MS2 " + MAGIC) < 1) {
         OrderSend(Symbol(), OP_BUYLIMIT, lots_248 * LOT_MS2, price_136, 5, 0, 0, "MS2 " + MAGIC, MAGIC, 0, Blue);
         Print("masuk3");
      }
      if (f0_9("S2 " + MAGIC) < 1) {
         OrderSend(Symbol(), OP_BUYLIMIT, lots_248 * LOT_S2, price_72, 5, 0, 0, "S2 " + MAGIC, MAGIC, 0, Blue);
         Print("masuk4");
      }
      if (f0_9("MS3 " + MAGIC) < 1) OrderSend(Symbol(), OP_BUYLIMIT, lots_248 * LOT_MS3, price_152, 5, 0, 0, "MS3 " + MAGIC, MAGIC, 0, Blue);
      if (f0_9("S3 " + MAGIC) < 1) OrderSend(Symbol(), OP_BUYLIMIT, lots_248 * LOT_S3, price_88, 5, 0, 0, "S3 " + MAGIC, MAGIC, 0, Blue);
      if (f0_9("MS4 " + MAGIC) < 1) OrderSend(Symbol(), OP_BUYLIMIT, lots_248 * LOT_MS4, price_168, 5, 0, 0, "MS4 " + MAGIC, MAGIC, 0, Blue);
      if (f0_9("S4 " + MAGIC) < 1) OrderSend(Symbol(), OP_BUYLIMIT, lots_248 * LOT_S4, price_104, 5, 0, 0, "S4 " + MAGIC, MAGIC, 0, Blue);
   }
   f0_8();
   if (G_count_324 < 8 && Close[0] < price_112 && Hour() < 22) {
      if (f0_9("MR1 " + MAGIC) < 1) OrderSend(Symbol(), OP_SELLLIMIT, lots_272, price_112, 5, 0, 0, "MR1 " + MAGIC, MAGIC, 0, Red);
      if (f0_9("R1 " + MAGIC) < 1) OrderSend(Symbol(), OP_SELLLIMIT, lots_272, price_48, 5, 0, 0, "R1 " + MAGIC, MAGIC, 0, Red);
      if (f0_9("MR2 " + MAGIC) < 1) OrderSend(Symbol(), OP_SELLLIMIT, lots_272 * LOT_MR2, price_128, 5, 0, 0, "MR2 " + MAGIC, MAGIC, 0, Red);
      if (f0_9("R2 " + MAGIC) < 1) OrderSend(Symbol(), OP_SELLLIMIT, lots_272 * LOT_R2, price_64, 5, 0, 0, "R2 " + MAGIC, MAGIC, 0, Red);
      if (f0_9("MR3 " + MAGIC) < 1) OrderSend(Symbol(), OP_SELLLIMIT, lots_272 * LOT_MR3, price_144, 5, 0, 0, "MR3 " + MAGIC, MAGIC, 0, Red);
      if (f0_9("R3 " + MAGIC) < 1) OrderSend(Symbol(), OP_SELLLIMIT, lots_272 * LOT_R3, price_80, 5, 0, 0, "R3 " + MAGIC, MAGIC, 0, Red);
      if (f0_9("MR4 " + MAGIC) < 1) OrderSend(Symbol(), OP_SELLLIMIT, lots_272 * LOT_MR4, price_160, 5, 0, 0, "MR4 " + MAGIC, MAGIC, 0, Red);
      if (f0_9("R4 " + MAGIC) < 1) OrderSend(Symbol(), OP_SELLLIMIT, lots_272 * LOT_R4, price_96, 5, 0, 0, "R4 " + MAGIC, MAGIC, 0, Red);
   }
   if (Li_180 > 0 && Li_192) {
      price_300 = 0;
      Ld_308 = 0;
      for (int pos_316 = OrdersTotal() - 1; pos_316 >= 0; pos_316--) {
         OrderSelect(pos_316, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != MAGIC) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC) {
            if (OrderType() == OP_BUY) {
               price_300 += OrderOpenPrice() * OrderLots();
               Ld_308 += OrderLots();
            }
         }
      }
      price_300 = NormalizeDouble(price_300 / Ld_308, Digits);
      price_300 += Li_296 * Point;
      for (int pos_320 = OrdersTotal() - 1; pos_320 >= 0; pos_320--) {
         OrderSelect(pos_320, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != MAGIC) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC) {
            if (OrderType() == OP_BUY) {
               if (Ld_200 >= Li_296 && Ask > Ld_216 + spread_176 * Point && OrderTakeProfit() == 0.0) {
                  OrderModify(OrderTicket(), OrderOpenPrice(), Ask - spread_176 * Point, OrderTakeProfit(), 0, CLR_NONE);
                  continue;
               }
               OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), price_300, 0, Aqua);
            }
         }
      }
   }
   if (Li_184 > 0 && Li_196) {
      price_324 = 0;
      Ld_332 = 0;
      for (int pos_340 = OrdersTotal() - 1; pos_340 >= 0; pos_340--) {
         OrderSelect(pos_340, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != MAGIC) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC) {
            if (OrderType() == OP_SELL) {
               price_324 += OrderOpenPrice() * OrderLots();
               Ld_332 += OrderLots();
            }
         }
      }
      price_324 = NormalizeDouble(price_324 / Ld_332, Digits);
      price_324 -= Li_296 * Point;
      for (int pos_344 = OrdersTotal() - 1; pos_344 >= 0; pos_344--) {
         OrderSelect(pos_344, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != MAGIC) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC) {
            if (OrderType() == OP_SELL) {
               if (Ld_208 >= Li_296 && Bid < Ld_224 - spread_176 * Point && OrderTakeProfit() == 0.0) {
                  OrderModify(OrderTicket(), OrderOpenPrice(), Bid + spread_176 * Point, OrderTakeProfit(), 0, CLR_NONE);
                  continue;
               }
               OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), price_324, 0, Pink);
            }
         }
      }
   }
   f0_8();
   if (Hour() >= 22) f0_13(OP_BUYLIMIT);
   if (Hour() >= 22) f0_13(OP_SELLLIMIT);
   return (0);
}

// 2208AB04CCD91A8303FE0D7679EA198F
void f0_0(int Ai_0) {
   int count_4;
   G_is_closed_300 = FALSE;
   G_is_deleted_304 = FALSE;
   for (G_order_total_236 = OrdersTotal(); G_order_total_236 >= 0; G_order_total_236--) {
      OrderSelect(G_order_total_236, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC) {
         if (OrderType() == OP_BUY && Ai_0 == 0 || Ai_0 == 7) {
            count_4 = 0;
            while (G_is_closed_300 == 0) {
               RefreshRates();
               G_is_closed_300 = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), G_slippage_308, Blue);
               if (G_is_closed_300 == 0) {
                  Sleep(1000);
                  count_4++;
               }
               if (GetLastError() == 4108/* INVALID_TICKET */ || GetLastError() == 145/* TRADE_MODIFY_DENIED */) G_is_closed_300 = TRUE;
            }
            G_is_closed_300 = FALSE;
         }
         if (OrderType() == OP_SELL && Ai_0 == 1 || Ai_0 == 7) {
            count_4 = 0;
            while (G_is_closed_300 == 0) {
               RefreshRates();
               G_is_closed_300 = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), G_slippage_308, Red);
               if (G_is_closed_300 == 0) {
                  Sleep(1000);
                  count_4++;
               }
               if (GetLastError() == 4108/* INVALID_TICKET */ || GetLastError() == 145/* TRADE_MODIFY_DENIED */) G_is_closed_300 = TRUE;
            }
            G_is_closed_300 = FALSE;
         }
      }
   }
   for (G_order_total_236 = OrdersTotal(); G_order_total_236 >= 0; G_order_total_236--) {
      OrderSelect(G_order_total_236, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC) {
         if (OrderType() == OP_BUYLIMIT && Ai_0 == 2 || Ai_0 == 7) {
            count_4 = 0;
            while (G_is_deleted_304 == 0) {
               RefreshRates();
               G_is_deleted_304 = OrderDelete(OrderTicket());
               if (G_is_deleted_304 == 0) {
                  Sleep(1000);
                  count_4++;
               }
               if (GetLastError() == 4108/* INVALID_TICKET */ || GetLastError() == 145/* TRADE_MODIFY_DENIED */) G_is_deleted_304 = TRUE;
            }
            G_is_deleted_304 = FALSE;
         }
         if (OrderType() == OP_SELLLIMIT && Ai_0 == 3 || Ai_0 == 7) {
            count_4 = 0;
            while (G_is_deleted_304 == 0) {
               RefreshRates();
               G_is_deleted_304 = OrderDelete(OrderTicket());
               if (G_is_deleted_304 == 0) {
                  Sleep(1000);
                  count_4++;
               }
               if (GetLastError() == 4108/* INVALID_TICKET */ || GetLastError() == 145/* TRADE_MODIFY_DENIED */) G_is_deleted_304 = TRUE;
            }
            G_is_deleted_304 = FALSE;
         }
         if (OrderType() == OP_BUYSTOP && Ai_0 == 4 || Ai_0 == 7) {
            count_4 = 0;
            while (G_is_deleted_304 == 0) {
               RefreshRates();
               G_is_deleted_304 = OrderDelete(OrderTicket());
               if (G_is_deleted_304 == 0) {
                  Sleep(1000);
                  count_4++;
               }
               if (GetLastError() == 4108/* INVALID_TICKET */ || GetLastError() == 145/* TRADE_MODIFY_DENIED */) G_is_deleted_304 = TRUE;
            }
            G_is_deleted_304 = FALSE;
         }
         if (OrderType() == OP_SELLSTOP && Ai_0 == 5 || Ai_0 == 7) {
            count_4 = 0;
            while (G_is_deleted_304 == 0) {
               RefreshRates();
               G_is_deleted_304 = OrderDelete(OrderTicket());
               if (G_is_deleted_304 == 0) {
                  Sleep(1000);
                  count_4++;
               }
               if (GetLastError() == 4108/* INVALID_TICKET */ || GetLastError() == 145/* TRADE_MODIFY_DENIED */) G_is_deleted_304 = TRUE;
            }
            G_is_deleted_304 = FALSE;
         }
      }
   }
}

// 728A3586533695AE250618970CD2B78D
void f0_8() {
   G_count_220 = 0;
   G_count_224 = 0;
   G_count_228 = 0;
   G_count_240 = 0;
   G_count_320 = 0;
   G_count_324 = 0;
   for (G_order_total_236 = 0; G_order_total_236 < OrdersTotal(); G_order_total_236++) {
      OrderSelect(G_order_total_236, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC && OrderType() == OP_BUY || OrderType() == OP_SELL) {
         G_count_220++;
         G_order_open_price_244 = OrderOpenPrice();
         G_order_lots_252 = OrderLots();
         G_cmd_260 = OrderType();
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC && OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT) G_count_240++;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC && OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP) G_count_320++;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC && OrderType() == OP_SELLSTOP || OrderType() == OP_SELLLIMIT) G_count_324++;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC && OrderType() == OP_BUY) {
         G_count_224++;
         G_order_open_price_264 = OrderOpenPrice();
         G_order_lots_280 = OrderLots();
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC && OrderType() == OP_SELL) {
         G_count_228++;
         G_order_open_price_272 = OrderOpenPrice();
         G_order_lots_288 = OrderLots();
      }
   }
}

// BE586324D883FB11DC0B48BBDDA88586
int f0_11() {
   int count_0 = 0;
   for (int pos_4 = OrdersTotal() - 1; pos_4 >= 0; pos_4--) {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MAGIC) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC) {
         if (TimeDayOfYear(OrderOpenTime()) == TimeDayOfYear(TimeCurrent()))
            if (OrderType() == OP_BUY || OrderType() == OP_SELL || OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT) count_0++;
      }
   }
   for (int pos_8 = OrdersHistoryTotal() - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS, MODE_HISTORY);
      if (TimeDayOfYear(OrderOpenTime()) == TimeDayOfYear(TimeCurrent()))
         if (OrderType() == OP_BUY || OrderType() == OP_SELL || OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT) count_0++;
   }
   return (count_0);
}

// 6A7F2382EF1650313789BF793AC0DAC1
int f0_6() {
   int count_0 = 0;
   for (int pos_4 = OrdersTotal() - 1; pos_4 >= 0; pos_4--) {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MAGIC) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC)
         if (OrderType() == OP_BUY) count_0++;
   }
   return (count_0);
}

// 72834DD20977CBD77629966646505F8C
int f0_7() {
   int count_0 = 0;
   for (int pos_4 = OrdersTotal() - 1; pos_4 >= 0; pos_4--) {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MAGIC) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC)
         if (OrderType() == OP_SELL) count_0++;
   }
   return (count_0);
}

// B3918665EE674080BF505E1B2D862187
int f0_9(string As_0) {
   int count_8 = 0;
   for (int pos_12 = OrdersTotal() - 1; pos_12 >= 0; pos_12--) {
      OrderSelect(pos_12, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC)
         if (OrderComment() == As_0) count_8++;
   }
   return (count_8);
}

// 43C27E073DC5BFF8EE519765E41AEE6F
int f0_3() {
   bool Li_ret_0 = FALSE;
   for (int pos_4 = OrdersTotal() - 1; pos_4 >= 0; pos_4--) {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MAGIC) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC)
         if (OrderType() == OP_BUY && OrderTakeProfit() == 0.0) Li_ret_0 = TRUE;
   }
   return (Li_ret_0);
}

// DCE6BE178BC8495832CD39B5226FDA01
int f0_14() {
   bool Li_ret_0 = FALSE;
   for (int pos_4 = OrdersTotal() - 1; pos_4 >= 0; pos_4--) {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MAGIC) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC)
         if (OrderType() == OP_SELL && OrderTakeProfit() == 0.0) Li_ret_0 = TRUE;
   }
   return (Li_ret_0);
}

// D7D4E575CCC1A12510982F93BF259443
void f0_13(int A_cmd_0) {
   for (int pos_4 = OrdersTotal() - 1; pos_4 >= 0; pos_4--) {
      OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MAGIC) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC)
         if (OrderType() == A_cmd_0) OrderDelete(OrderTicket());
   }
}

// E9559617DBC93BE8078D863006306B15
double f0_16() {
   double Ld_ret_0 = 0;
   for (int pos_8 = OrdersTotal() - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC && OrderType() == OP_BUY) Ld_ret_0 += OrderProfit();
   }
   return (Ld_ret_0);
}

// 5CA3EDEDB34296DAC2F9DB378E373757
double f0_5() {
   double Ld_ret_0 = 0;
   for (int pos_8 = OrdersTotal() - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC && OrderType() == OP_SELL) Ld_ret_0 += OrderProfit();
   }
   return (Ld_ret_0);
}

// 262336F736ADFEEC641C03BB3514631C
double f0_1() {
   double order_open_price_0;
   for (int pos_8 = OrdersTotal() - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MAGIC) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC && OrderType() == OP_BUY) order_open_price_0 = OrderOpenPrice();
   }
   return (order_open_price_0);
}

// 599A26C25DF2561FBAA884F47E1B315C
double f0_4() {
   double order_open_price_0;
   for (int pos_8 = OrdersTotal() - 1; pos_8 >= 0; pos_8--) {
      OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MAGIC) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC && OrderType() == OP_SELL) order_open_price_0 = OrderOpenPrice();
   }
   return (order_open_price_0);
}

// B4B321B38B9A855ACE5E12936AFF6236
double f0_10() {
   double order_lots_0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MAGIC) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC && OrderType() == OP_BUY) {
         ticket_8 = OrderTicket();
         if (ticket_8 > ticket_20) {
            order_lots_0 = OrderLots();
            Ld_unused_12 = order_lots_0;
            ticket_20 = ticket_8;
         }
      }
   }
   return (order_lots_0);
}

// CA84AF2EC545107F52AAA08D2CE43DDC
double f0_12() {
   double order_lots_0;
   int ticket_8;
   double Ld_unused_12 = 0;
   int ticket_20 = 0;
   for (int pos_24 = OrdersTotal() - 1; pos_24 >= 0; pos_24--) {
      OrderSelect(pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MAGIC) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC && OrderType() == OP_SELL) {
         ticket_8 = OrderTicket();
         if (ticket_8 > ticket_20) {
            order_lots_0 = OrderLots();
            Ld_unused_12 = order_lots_0;
            ticket_20 = ticket_8;
         }
      }
   }
   return (order_lots_0);
}

// 345AB7B5A4BDE561A11DB34B6FEA9E84
void f0_2() {
   int order_total_0;
   if (Bars < 100) {
      Print("bars less than 100");
      return;
   }
   if (LockProfiT1 > Target1 || LockProfiT2 > Target2) Comment("Setting Target dan StopLoss-nya salah !");
   if (Target1 > 0 && f0_15() > 0 && Gi_420 || Gi_424 || Gi_428 || Gi_432 || Gi_436 || Gi_440 || Gi_444 || Gi_448 || Gi_452 || Gi_456 || Gi_460) {
      order_total_0 = OrdersTotal();
      for (int pos_4 = 0; pos_4 < OrdersTotal(); pos_4++) {
         OrderSelect(pos_4, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol()) {
            if (OrderType() == OP_BUY) {
               if (Gi_420) {
                  if (Bid - OrderOpenPrice() >= Point * Target1 && OrderStopLoss() < OrderOpenPrice() + Point * LockProfiT1) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + Point * LockProfiT1, OrderTakeProfit(), 0, Green);
                     if (Target2 <= 0) break;
                     Gi_424 = TRUE;
                     return;
                  }
               }
               if (Gi_424) {
                  if (Bid - OrderOpenPrice() >= Point * Target2 && OrderStopLoss() < OrderOpenPrice() + Point * LockProfiT2) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + Point * LockProfiT2, OrderTakeProfit(), 0, Green);
                     if (Target3 <= 0) break;
                     Gi_428 = TRUE;
                     return;
                  }
               }
               if (Gi_428) {
                  if (Bid - OrderOpenPrice() >= Point * Target3 && OrderStopLoss() < OrderOpenPrice() + Point * LockProfiT3) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + Point * LockProfiT3, OrderTakeProfit(), 0, Green);
                     if (Target4 <= 0) break;
                     Gi_432 = TRUE;
                     return;
                  }
               }
               if (Gi_432) {
                  if (Bid - OrderOpenPrice() >= Point * Target4 && OrderStopLoss() < OrderOpenPrice() + Point * LockProfiT4) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + Point * LockProfiT4, OrderTakeProfit(), 0, Green);
                     if (Target5 <= 0) break;
                     Gi_436 = TRUE;
                     return;
                  }
               }
               if (Gi_436) {
                  if (Bid - OrderOpenPrice() >= Point * Target5 && OrderStopLoss() < OrderOpenPrice() + Point * LockProfiT5) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + Point * LockProfiT5, OrderTakeProfit(), 0, Green);
                     return;
                  }
               }
               if (Gi_440) {
                  if (Bid - OrderOpenPrice() >= Point * Target6 && OrderStopLoss() < OrderOpenPrice() + Point * LockProfiT6) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + Point * LockProfiT6, OrderTakeProfit(), 0, Green);
                     return;
                  }
               }
               if (Gi_444) {
                  if (Bid - OrderOpenPrice() >= Point * Target7 && OrderStopLoss() < OrderOpenPrice() + Point * LockProfiT7) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + Point * LockProfiT7, OrderTakeProfit(), 0, Green);
                     return;
                  }
               }
               if (Gi_448) {
                  if (Bid - OrderOpenPrice() >= Point * Target8 && OrderStopLoss() < OrderOpenPrice() + Point * LockProfiT8) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + Point * LockProfiT8, OrderTakeProfit(), 0, Green);
                     return;
                  }
               }
               if (Gi_452) {
                  if (Bid - OrderOpenPrice() >= Point * Target9 && OrderStopLoss() < OrderOpenPrice() + Point * LockProfiT9) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + Point * LockProfiT9, OrderTakeProfit(), 0, Green);
                     return;
                  }
               }
               if (Gi_456) {
                  if (Bid - OrderOpenPrice() >= Point * Target10 && OrderStopLoss() < OrderOpenPrice() + Point * LockProfiT10) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + Point * LockProfiT10, OrderTakeProfit(), 0, Green);
                     return;
                  }
               }
               if (Gi_460) {
                  if (Bid - OrderOpenPrice() >= Point * Target11 && OrderStopLoss() < OrderOpenPrice() + Point * LockProfiT11) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + Point * LockProfiT11, OrderTakeProfit(), 0, Green);
                     return;
                  }
               }
            }
            if (OrderType() == OP_SELL) {
               if (Gi_420) {
                  if (OrderOpenPrice() - Ask >= Point * Target1 && OrderStopLoss() > OrderOpenPrice() - Point * LockProfiT1 || OrderStopLoss() == 0.0) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - Point * LockProfiT1, OrderTakeProfit(), 0, Red);
                     if (Target2 <= 0) break;
                     Gi_424 = TRUE;
                     return;
                  }
               }
               if (Gi_424) {
                  if (OrderOpenPrice() - Ask >= Point * Target2 && OrderStopLoss() > OrderOpenPrice() - Point * LockProfiT2) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - Point * LockProfiT2, OrderTakeProfit(), 0, Red);
                     if (Target3 <= 0) break;
                     Gi_428 = TRUE;
                     return;
                  }
               }
               if (Gi_428) {
                  if (OrderOpenPrice() - Ask >= Point * Target3 && OrderStopLoss() > OrderOpenPrice() - Point * LockProfiT3) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - Point * LockProfiT3, OrderTakeProfit(), 0, Red);
                     if (Target4 <= 0) break;
                     Gi_432 = TRUE;
                     return;
                  }
               }
               if (Gi_432) {
                  if (OrderOpenPrice() - Ask >= Point * Target4 && OrderStopLoss() > OrderOpenPrice() - Point * LockProfiT4) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - Point * LockProfiT4, OrderTakeProfit(), 0, Red);
                     if (Target5 <= 0) break;
                     Gi_436 = TRUE;
                     return;
                  }
               }
               if (Gi_436) {
                  if (OrderOpenPrice() - Ask >= Point * Target5 && OrderStopLoss() > OrderOpenPrice() - Point * LockProfiT5) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - Point * LockProfiT5, OrderTakeProfit(), 0, Red);
                     return;
                  }
               }
               if (Gi_440) {
                  if (OrderOpenPrice() - Ask >= Point * Target6 && OrderStopLoss() > OrderOpenPrice() - Point * LockProfiT6) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - Point * LockProfiT6, OrderTakeProfit(), 0, Red);
                     return;
                  }
               }
               if (Gi_444) {
                  if (OrderOpenPrice() - Ask >= Point * Target7 && OrderStopLoss() > OrderOpenPrice() - Point * LockProfiT7) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - Point * LockProfiT7, OrderTakeProfit(), 0, Red);
                     return;
                  }
               }
               if (Gi_448) {
                  if (OrderOpenPrice() - Ask >= Point * Target8 && OrderStopLoss() > OrderOpenPrice() - Point * LockProfiT8) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - Point * LockProfiT8, OrderTakeProfit(), 0, Red);
                     return;
                  }
               }
               if (Gi_452) {
                  if (OrderOpenPrice() - Ask >= Point * Target9 && OrderStopLoss() > OrderOpenPrice() - Point * LockProfiT9) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - Point * LockProfiT9, OrderTakeProfit(), 0, Red);
                     return;
                  }
               }
               if (Gi_456) {
                  if (OrderOpenPrice() - Ask >= Point * Target10 && OrderStopLoss() > OrderOpenPrice() - Point * LockProfiT10) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - Point * LockProfiT10, OrderTakeProfit(), 0, Red);
                     return;
                  }
               }
               if (Gi_460) {
                  if (OrderOpenPrice() - Ask >= Point * Target11 && OrderStopLoss() > OrderOpenPrice() - Point * LockProfiT11) {
                     OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - Point * LockProfiT11, OrderTakeProfit(), 0, Red);
                     return;
                  }
               }
            }
         }
      }
   }
}

// E26FEFBBE211DFE0E47EB2F1F86E6987
int f0_15() {
   int Li_ret_0;
   int order_total_4 = OrdersTotal();
   for (int pos_8 = 0; pos_8 < order_total_4; pos_8++) {
      OrderSelect(pos_8, SELECT_BY_POS, MODE_TRADES);
      if (OrderType() <= OP_SELL && OrderSymbol() == Symbol()) Li_ret_0++;
   }
   return (Li_ret_0);
}
