/*
   G e n e r a t e d  by ex4-to-mq4 decompiler FREEWARE 4.0.509.5
   Website: h T tp: / /Www .me t A q Uot eS. NEt
   E-mail : SUPp oRT @ mEta Q u OT e S.n et
*/
#property link      "http://forexrobotnation.com Forex Fireball"

string Gs_unused_76;
string Gs_84 = "Forex Fireball EURUSD M1";
extern int magic = 999999;
extern double lots = 0.1;
extern bool moneymanagement = TRUE;
extern bool ecnbroker = FALSE;
extern int maxtradesopen = 1;
extern int tradesperposition = 1;
extern double minlot = 0.01;
extern double maxlot = 30.0;
extern double risk = 10.0;
extern double stoploss = 50.0;
extern double takeprofit = 50.0;
extern bool inverse_close = TRUE;
extern int tradelock = 40;
extern int tradeinverse = 20;
int Gi_172 = 1;
double Gd_176 = 5.0;
double Gd_184 = 10.0;
double Gd_192 = 10.0;
bool Gi_200 = TRUE;
bool Gi_204 = FALSE;
bool Gi_208 = FALSE;
bool Gi_212 = FALSE;
int Gi_216 = 20;
bool Gi_220 = FALSE;
bool Gi_224 = FALSE;
bool Gi_228 = FALSE;
int G_timeframe_232 = PERIOD_H1;
int G_period_236 = 7;
int G_ma_method_240 = MODE_SMMA;
int Gi_244 = 8;
bool Gi_248 = TRUE;
int G_timeframe_252 = 0;
int G_period_256 = 7;
int Gi_260 = 27;
int Gi_264 = 69;
bool Gi_268 = TRUE;
int G_timeframe_272 = 0;
int G_period_276 = 14;
int G_period_280 = 7;
int G_slowing_284 = 9;
int Gi_288 = 30;
int Gi_292 = 70;
int Gi_296 = 0;
int Gi_300 = 2;
int Gi_304 = 1;
bool Gi_308 = FALSE;
int Gi_312 = 12;
int Gi_316 = 0;
bool Gi_320 = FALSE;
int Gi_324 = 0;
int Gi_328 = 1;
int Gi_332 = 21;
int Gi_336 = 0;
bool Gi_340 = TRUE;
bool Gi_344 = TRUE;
int Gi_348 = 0;
int Gi_352 = 0;
int Gi_356 = 2;
bool Gi_360 = FALSE;
bool Gi_364 = FALSE;
double Gd_368 = 15.0;
double Gd_376 = 1.0;
double Gd_384 = 15.0;
double Gd_392 = 0.0;
double Gd_400 = 0.0;
datetime Gt_unused_408;
datetime Gt_unused_412;
int G_str2time_416;
int G_str2time_420;
int G_str2time_424;
int G_str2time_428;
int G_datetime_432;
int G_datetime_436;
int G_pos_440;
int G_bars_444 = -1;
int G_count_448;
int G_count_452;
int G_count_456;
int Gi_460 = 100;
int Gi_464;
int Gi_468;
int Gi_472;
int Gi_476;
int Gi_480;
int G_count_484;
int Gi_488;
int Gi_492;
string Gs_496;
string Gs_504;
string Gs_512;
string Gs_520;
string Gs_528;
string Gs_536;
string Gs_544;
string Gs_552;
double G_price_560;
double G_price_568;
double G_lots_576;
double Gda_584[14];
double Gda_588[14];
double G_order_open_price_592;
double G_order_open_price_600;
bool Gi_unused_608 = FALSE;
bool Gi_612 = TRUE;
bool Gi_616 = TRUE;
double Gd_620;
double Gd_628;
int G_digits_636;
bool Gi_640 = TRUE;
int Gi_unused_644 = D'01.05.2011 08:00';

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   Gs_unused_76 = "";
   Gt_unused_408 = Time[0];
   Gt_unused_412 = Time[0];
   Gda_588[13] = D'28.03.2012 10:00';
   Gda_584[13] = D'31.10.2012 11:00';
   Gda_588[12] = D'29.03.2011 10:00';
   Gda_584[12] = D'25.10.2011 11:00';
   Gda_588[11] = D'30.03.2010 02:00';
   Gda_584[11] = D'26.10.2010 03:00';
   Gda_588[10] = D'29.03.2009 02:00';
   Gda_584[10] = D'25.10.2009 03:00';
   Gda_588[9] = D'30.03.2008 02:00';
   Gda_584[9] = D'26.10.2008 03:00';
   Gda_588[8] = D'25.03.2007 02:00';
   Gda_584[8] = D'28.10.2007 03:00';
   Gda_588[7] = D'26.03.2006';
   Gda_584[7] = D'29.10.2006 03:00';
   Gda_588[6] = D'27.03.2005';
   Gda_584[6] = D'30.10.2005 03:00';
   Gda_588[5] = D'28.03.2004';
   Gda_584[5] = D'31.10.2004 03:00';
   Gda_588[4] = D'30.03.2003';
   Gda_584[4] = D'26.10.2003 03:00';
   Gda_588[3] = D'31.03.2002';
   Gda_584[3] = D'27.10.2002 03:00';
   Gda_588[2] = D'25.03.2001';
   Gda_584[2] = D'28.10.2001 03:00';
   Gda_588[1] = D'26.03.2000 10:00';
   Gda_584[1] = D'29.10.2000 11:00';
   Gda_588[0] = 922586400;
   Gda_584[0] = 941338800;
   G_digits_636 = Digits;
   if (G_digits_636 == 3 || G_digits_636 == 5) {
      Gd_620 = 10.0 * Point;
      Gd_628 = 10;
   } else {
      Gd_620 = Point;
      Gd_628 = 1;
   }
   if (minlot >= 1.0) Gi_464 = 100000;
   if (minlot < 1.0) Gi_464 = 10000;
   if (minlot < 0.1) Gi_464 = 1000;
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   if (inverse_close) f0_13();
   if (Gd_392 > 0.0) f0_11(Gd_392, Gd_400);
   if (Gd_384 > 0.0) f0_9(Gd_368, Gd_384);
   if (OrdersTotal() > 0) {
      for (G_pos_440 = 0; G_pos_440 <= OrdersTotal(); G_pos_440++) {
         OrderSelect(G_pos_440, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderCloseTime() == 0) {
            if (OrderType() == OP_BUY) {
               G_datetime_432 = OrderOpenTime();
               G_order_open_price_592 = OrderOpenPrice();
            }
            if (OrderType() == OP_SELL) {
               G_datetime_436 = OrderOpenTime();
               G_order_open_price_600 = OrderOpenPrice();
            }
         }
      }
   }
   if (tradesperposition == 1) {
      if (G_datetime_432 < Time[0]) G_count_452 = 0;
      else G_count_452 = 1;
      if (G_datetime_436 < Time[0]) G_count_456 = 0;
      else G_count_456 = 1;
   }
   if (tradesperposition != 1 && G_bars_444 != Bars) {
      G_count_452 = 0;
      G_count_456 = 0;
      G_bars_444 = Bars;
   }
   double ima_0 = iMA(NULL, G_timeframe_232, G_period_236, 0, G_ma_method_240, PRICE_CLOSE, Gi_296);
   int count_8 = 0;
   for (G_pos_440 = 1; G_pos_440 <= Gi_244; G_pos_440++) {
      if (ima_0 >= iMA(NULL, G_timeframe_232, G_period_236, 0, G_ma_method_240, PRICE_CLOSE, G_pos_440))
         if (ima_0 > iMA(NULL, G_timeframe_232, G_period_236, 0, G_ma_method_240, PRICE_CLOSE, G_pos_440)) count_8++;
   }
   int count_12 = 0;
   for (G_pos_440 = 1; G_pos_440 <= Gi_244; G_pos_440++) {
      if (ima_0 <= iMA(NULL, G_timeframe_232, G_period_236, 0, G_ma_method_240, PRICE_CLOSE, G_pos_440))
         if (ima_0 < iMA(NULL, G_timeframe_232, G_period_236, 0, G_ma_method_240, PRICE_CLOSE, G_pos_440)) count_12++;
   }
   double irsi_16 = iRSI(NULL, G_timeframe_252, G_period_256, PRICE_CLOSE, Gi_296);
   double istochastic_24 = iStochastic(NULL, G_timeframe_272, G_period_276, G_period_280, G_slowing_284, MODE_SMA, 0, MODE_MAIN, Gi_296);
   bool Li_32 = FALSE;
   bool Li_36 = FALSE;
   if (count_8 == Gi_244 && Gi_248 == FALSE || (Gi_248 && irsi_16 <= Gi_260) && Gi_268 == FALSE || (Gi_268 && istochastic_24 <= Gi_288) && f0_14(OP_BUY) == 0 || (f0_14(OP_BUY) > 0 &&
      Ask < G_order_open_price_592 - Gd_192 * Gd_620) && Gi_228 == FALSE || (Gi_228 && Gi_612)) {
      if (Gi_364) Li_36 = TRUE;
      else Li_32 = TRUE;
      Gi_612 = FALSE;
      Gi_616 = TRUE;
   }
   if (count_12 == Gi_244 && Gi_248 == FALSE || (Gi_248 && irsi_16 >= Gi_264) && Gi_268 == FALSE || (Gi_268 && istochastic_24 >= Gi_292) && f0_14(OP_SELL) == 0 || (f0_14(OP_SELL) > 0 &&
      Bid > G_order_open_price_600 + Gd_192 * Gd_620) && Gi_228 == FALSE || (Gi_228 && Gi_616)) {
      if (Gi_364) Li_32 = TRUE;
      else Li_36 = TRUE;
      Gi_612 = TRUE;
      Gi_616 = FALSE;
   }
   if (Gi_360 && Li_36) f0_5();
   if (Gi_360 && Li_32) f0_8();
   if (Gi_224 || Gi_220) {
      f0_2();
      f0_4();
   }
   if (Ask - Bid > Gd_184 * Gd_628 * Gd_620) return (0);
   if (f0_14(OP_BUY) + f0_14(OP_SELL) >= maxtradesopen) return (0);
   if (f0_3()) return (0);
   if (moneymanagement) lots = f0_7();
   int Li_40 = 0;
   if (Gi_172 > 0) Li_40 = TimeCurrent() + 60 * Gi_172 - 5;
   Gi_488 = 0;
   G_count_484 = 0;
   if (Li_32 && G_count_452 < tradesperposition) {
      if (Gi_204) {
         f0_0(OP_SELLSTOP);
         f0_0(OP_SELLLIMIT);
      }
      G_lots_576 = lots;
      if (ecnbroker == FALSE) {
         if (Gi_200) {
            while (Gi_488 <= 0 && G_count_484 < Gi_460) {
               while (!IsTradeAllowed()) Sleep(5000);
               RefreshRates();
               Gi_488 = f0_10(OP_BUY, G_lots_576, Ask, stoploss, takeprofit, Li_40, Blue);
               if (Gi_488 < 0) G_count_484++;
            }
         }
         if (Gi_208) {
            RefreshRates();
            Gi_488 = f0_10(OP_BUYSTOP, G_lots_576, Ask + Gi_216 * Gd_620, stoploss, takeprofit, Li_40, Blue);
         }
         if (Gi_212) {
            RefreshRates();
            Gi_488 = f0_10(OP_BUYLIMIT, G_lots_576, Bid - Gi_216 * Gd_620, stoploss, takeprofit, Li_40, Blue);
         }
      }
      if (ecnbroker) {
         if (Gi_200) {
            while (Gi_488 <= 0 && G_count_484 < Gi_460) {
               while (!IsTradeAllowed()) Sleep(5000);
               RefreshRates();
               Gi_488 = f0_10(OP_BUY, G_lots_576, Ask, 0, 0, Li_40, Blue);
               if (Gi_488 < 0) G_count_484++;
            }
         }
         if (Gi_208) {
            RefreshRates();
            Gi_488 = f0_10(OP_BUYSTOP, G_lots_576, Ask + Gi_216 * Gd_620, 0, 0, Li_40, Blue);
         }
         if (Gi_212) {
            RefreshRates();
            Gi_488 = f0_10(OP_BUYLIMIT, G_lots_576, Bid - Gi_216 * Gd_620, 0, 0, Li_40, Blue);
         }
         f0_15(stoploss);
         f0_1(takeprofit);
      }
      if (Gi_488 > 0) G_count_452++;
   }
   Gi_488 = 0;
   if (Li_36 && G_count_456 < tradesperposition) {
      if (Gi_204) {
         f0_0(OP_BUYSTOP);
         f0_0(OP_BUYLIMIT);
      }
      G_lots_576 = lots;
      if (ecnbroker == FALSE) {
         if (Gi_200) {
            while (Gi_488 <= 0 && G_count_484 < Gi_460) {
               while (!IsTradeAllowed()) Sleep(5000);
               RefreshRates();
               Gi_488 = f0_10(OP_SELL, G_lots_576, Bid, stoploss, takeprofit, Li_40, Red);
               if (Gi_488 < 0) G_count_484++;
            }
         }
         if (Gi_208) {
            RefreshRates();
            Gi_488 = f0_10(OP_SELLSTOP, G_lots_576, Bid - Gi_216 * Gd_620, stoploss, takeprofit, Li_40, Red);
         }
         if (Gi_212) {
            RefreshRates();
            Gi_488 = f0_10(OP_SELLLIMIT, G_lots_576, Ask + Gi_216 * Gd_620, stoploss, takeprofit, Li_40, Red);
         }
      }
      if (ecnbroker) {
         if (Gi_200) {
            while (Gi_488 <= 0 && G_count_484 < Gi_460) {
               while (!IsTradeAllowed()) Sleep(5000);
               RefreshRates();
               Gi_488 = f0_10(OP_SELL, G_lots_576, Bid, 0, 0, Li_40, Red);
               if (Gi_488 < 0) G_count_484++;
            }
         }
         if (Gi_208) {
            RefreshRates();
            Gi_488 = f0_10(OP_SELLSTOP, G_lots_576, Bid - Gi_216 * Gd_620, 0, 0, Li_40, Red);
         }
         if (Gi_212) {
            RefreshRates();
            Gi_488 = f0_10(OP_SELLLIMIT, G_lots_576, Ask + Gi_216 * Gd_620, 0, 0, Li_40, Red);
         }
         f0_6(stoploss);
         f0_12(takeprofit);
      }
      if (Gi_488 > 0) G_count_456++;
   }
   if (ecnbroker) {
      f0_15(stoploss);
      f0_1(takeprofit);
      f0_6(stoploss);
      f0_12(takeprofit);
   }
   return (0);
}

// D7B98DB9B07886F5E1661ED96AE3EB86
void f0_13() {
   for (int pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      OrderSelect(pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderMagicNumber() == magic && OrderSymbol() == Symbol() && Gi_640) {
         if (OrderType() == OP_BUY) {
            if (OrderOpenPrice() - Bid >= tradelock * Gd_620)
               if (OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), Bid + tradeinverse * Gd_620, 0, Black)) Gi_640 = FALSE;
         }
         if (OrderType() == OP_SELL) {
            if (Ask - OrderOpenPrice() >= tradelock * Gd_620)
               if (OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), Ask - tradeinverse * Gd_620, 0, Black)) Gi_640 = FALSE;
         }
      }
   }
}

// 7CEF8A734855777C2A9D0CAF42666E69
int f0_10(int A_cmd_0, double Ad_4, double Ad_12, double Ad_20, double Ad_28, int A_datetime_36, color A_color_40) {
   int ticket_44 = 0;
   if (Ad_4 < minlot) Ad_4 = minlot;
   if (Ad_4 > maxlot) Ad_4 = maxlot;
   if (A_cmd_0 == OP_BUY || A_cmd_0 == OP_BUYSTOP || A_cmd_0 == OP_BUYLIMIT) {
      if (Gi_220 == FALSE && Ad_20 > 0.0) G_price_560 = Ad_12 - Ad_20 * Gd_620;
      else G_price_560 = 0;
      if (Gi_224 == FALSE && Ad_28 > 0.0) G_price_568 = Ad_12 + Ad_28 * Gd_620;
      else G_price_568 = 0;
   }
   if (A_cmd_0 == OP_SELL || A_cmd_0 == OP_SELLSTOP || A_cmd_0 == OP_SELLLIMIT) {
      if (Gi_220 == FALSE && Ad_20 > 0.0) G_price_560 = Ad_12 + Ad_20 * Gd_620;
      else G_price_560 = 0;
      if (Gi_224 == FALSE && Ad_28 > 0.0) G_price_568 = Ad_12 - Ad_28 * Gd_620;
      else G_price_568 = 0;
   }
   ticket_44 = OrderSend(Symbol(), A_cmd_0, NormalizeDouble(Ad_4, Gi_356), NormalizeDouble(Ad_12, G_digits_636), Gd_176 * Gd_628, G_price_560, G_price_568, Gs_84 + " " +
      DoubleToStr(magic, 0), magic, A_datetime_36, A_color_40);
   if (ticket_44 > -1) Gi_640 = TRUE;
   return (ticket_44);
}

// 482B9D6BC9EC8341260ED26FCB4279DE
double f0_7() {
   double Ld_ret_0;
   if (stoploss > 0.0) Ld_ret_0 = AccountBalance() * (risk / 100.0) / (stoploss * Gd_620 / MarketInfo(Symbol(), MODE_TICKSIZE) * MarketInfo(Symbol(), MODE_TICKVALUE));
   else Ld_ret_0 = NormalizeDouble(AccountBalance() / Gi_464 * minlot * risk, Gi_356);
   return (Ld_ret_0);
}

// 20BD1B26E34C29E3BA32B7D41776D9B5
int f0_3() {
   if (TimeCurrent() < Gda_584[TimeYear(TimeCurrent()) - 1999] && TimeCurrent() > Gda_588[TimeYear(TimeCurrent()) - 1999]) Gi_492 = Gi_300;
   else Gi_492 = Gi_304;
   string Ls_0 = Year() + "." + Month() + "." + Day();
   if (Gi_308) {
      Gi_480 = Gi_312 + Gi_492;
      if (Gi_480 > 23) Gi_480 -= 24;
      if (Gi_480 < 10) Gs_544 = "0" + Gi_480;
      if (Gi_480 > 9) Gs_544 = Gi_480;
      if (Gi_316 < 10) Gs_552 = "0" + Gi_316;
      if (Gi_316 > 9) Gs_552 = Gi_316;
      G_str2time_428 = StrToTime(Ls_0 + " " + Gs_544 + ":" + Gs_552);
   }
   if (Gi_320) {
      Gi_468 = Gi_324 + Gi_492;
      if (Gi_468 > 23) Gi_468 -= 24;
      if (Gi_468 < 10) Gs_496 = "0" + Gi_468;
      if (Gi_468 > 9) Gs_496 = Gi_468;
      if (Gi_328 < 10) Gs_504 = "0" + Gi_328;
      if (Gi_328 > 9) Gs_504 = Gi_328;
      G_str2time_416 = StrToTime(Ls_0 + " " + Gs_496 + ":" + Gs_504);
      Gi_472 = Gi_332 + Gi_492;
      if (Gi_472 > 23) Gi_472 -= 24;
      if (Gi_332 < 10) Gs_512 = "0" + Gi_472;
      if (Gi_332 > 9) Gs_512 = Gi_472;
      if (Gi_336 < 10) Gs_520 = "0" + Gi_336;
      if (Gi_336 > 9) Gs_520 = Gi_336;
      G_str2time_420 = StrToTime(Ls_0 + " " + Gs_512 + ":" + Gs_520);
   }
   if (Gi_344) {
      Gi_476 = Gi_348 + Gi_492;
      if (Gi_476 > 23) Gi_476 -= 24;
      if (Gi_476 < 10) Gs_528 = "0" + Gi_476;
      if (Gi_476 > 9) Gs_528 = Gi_476;
      if (Gi_352 < 10) Gs_536 = "0" + Gi_352;
      if (Gi_352 > 9) Gs_536 = Gi_352;
      G_str2time_424 = StrToTime(Ls_0 + " " + Gs_528 + ":" + Gs_536);
   }
   if ((Gi_320 && (Gi_468 <= Gi_472 && TimeCurrent() < G_str2time_416 || TimeCurrent() > G_str2time_420) || (Gi_468 > Gi_472 && TimeCurrent() < G_str2time_416 && TimeCurrent() > G_str2time_420)) ||
      (Gi_340 == FALSE && DayOfWeek() == 0) || (Gi_344 && DayOfWeek() == 5 && TimeCurrent() > G_str2time_424) || (Gi_308 && DayOfWeek() == 1 && TimeCurrent() < G_str2time_428)) return (1);
   return (0);
}

// E2942A04780E223B215EB8B663CF5353
int f0_14(int A_cmd_0) {
   G_count_448 = 0;
   if (OrdersTotal() > 0) {
      for (G_pos_440 = OrdersTotal(); G_pos_440 >= 0; G_pos_440--) {
         OrderSelect(G_pos_440, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderType() == A_cmd_0 && OrderMagicNumber() == magic) G_count_448++;
      }
      return (G_count_448);
   }
   return (0);
}

// 3B0BE0D68A6C482BE1B4A0CA1A4EB449
void f0_5() {
   RefreshRates();
   if (OrdersTotal() > 0) {
      for (G_pos_440 = OrdersTotal() - 1; G_pos_440 >= 0; G_pos_440--) {
         OrderSelect(G_pos_440, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, Gd_176 * Gd_628);
      }
   }
}

// 5652188B537AFABC73EFC948BEA91426
void f0_8() {
   RefreshRates();
   if (OrdersTotal() > 0) {
      for (G_pos_440 = OrdersTotal() - 1; G_pos_440 >= 0; G_pos_440--) {
         OrderSelect(G_pos_440, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, Gd_176 * Gd_628);
      }
   }
}

// 316ED4A3D926CDF4F0850741B1C08237
void f0_4() {
   RefreshRates();
   if (OrdersTotal() > 0) {
      for (G_pos_440 = OrdersTotal() - 1; G_pos_440 >= 0; G_pos_440--) {
         OrderSelect(G_pos_440, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_BUY && (Gi_220 && stoploss > 0.0 && OrderProfit() <= 10.0 * ((-1.0 * stoploss) * OrderLots()) - 10.0 * (MarketInfo(Symbol(),
            MODE_SPREAD) * OrderLots()) / Gd_628) || (Gi_224 && takeprofit > 0.0 && OrderProfit() >= 10.0 * (takeprofit * OrderLots()))) OrderClose(OrderTicket(), OrderLots(), Bid, Gd_176 * Gd_628);
      }
   }
}

// 188659BF1D817DBBF734DE3AB384F40C
void f0_2() {
   RefreshRates();
   if (OrdersTotal() > 0) {
      for (G_pos_440 = OrdersTotal() - 1; G_pos_440 >= 0; G_pos_440--) {
         OrderSelect(G_pos_440, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == OP_SELL && (Gi_220 && stoploss > 0.0 && OrderProfit() <= 10.0 * ((-1.0 * stoploss) * OrderLots()) - 10.0 * (MarketInfo(Symbol(),
            MODE_SPREAD) * OrderLots()) / Gd_628) || (Gi_224 && takeprofit > 0.0 && OrderProfit() >= 10.0 * (takeprofit * OrderLots()))) OrderClose(OrderTicket(), OrderLots(), Ask, Gd_176 * Gd_628);
      }
   }
}

// 7F27FC242C0738054AC7C7E3A2B292B1
void f0_11(double Ad_0, double Ad_8) {
   RefreshRates();
   if (OrdersTotal() > 0) {
      for (G_pos_440 = OrdersTotal(); G_pos_440 >= 0; G_pos_440--) {
         OrderSelect(G_pos_440, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
            if (OrderType() == OP_BUY) {
               if (NormalizeDouble(Bid - OrderOpenPrice(), G_digits_636) < NormalizeDouble(Ad_0 * Gd_620, G_digits_636)) continue;
               if (!((NormalizeDouble(OrderStopLoss() - OrderOpenPrice(), G_digits_636) < NormalizeDouble(Ad_8 * Gd_620, G_digits_636) || OrderStopLoss() == 0.0))) continue;
               OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(OrderOpenPrice() + Ad_8 * Gd_620, G_digits_636), OrderTakeProfit(), 0, Blue);
               return;
            }
            if (NormalizeDouble(OrderOpenPrice() - Ask, G_digits_636) >= NormalizeDouble(Ad_0 * Gd_620, G_digits_636)) {
               if (NormalizeDouble(OrderOpenPrice() - OrderStopLoss(), G_digits_636) < NormalizeDouble(Ad_8 * Gd_620, G_digits_636) || OrderStopLoss() == 0.0) {
                  OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(OrderOpenPrice() - Ad_8 * Gd_620, G_digits_636), OrderTakeProfit(), 0, Red);
                  return;
               }
            }
         }
      }
   }
}

// 6DE16931209DF21117152D106A975D61
void f0_9(double Ad_0, double Ad_8) {
   RefreshRates();
   if (OrdersTotal() > 0) {
      for (G_pos_440 = OrdersTotal(); G_pos_440 >= 0; G_pos_440--) {
         OrderSelect(G_pos_440, SELECT_BY_POS, MODE_TRADES);
         if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
            if (OrderType() == OP_BUY) {
               if (!((NormalizeDouble(Ask, G_digits_636) > NormalizeDouble(OrderOpenPrice() + Ad_0 * Gd_620, G_digits_636) && NormalizeDouble(OrderStopLoss(), G_digits_636) < NormalizeDouble(Bid - (Ad_8 +
                  Gd_376) * Gd_620, G_digits_636)))) continue;
               OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Bid - Ad_8 * Gd_620, G_digits_636), OrderTakeProfit(), 0, Blue);
               return;
            }
            if (NormalizeDouble(Bid, G_digits_636) < NormalizeDouble(OrderOpenPrice() - Ad_0 * Gd_620, G_digits_636) && NormalizeDouble(OrderStopLoss(), G_digits_636) > NormalizeDouble(Ask +
               (Ad_8 + Gd_376) * Gd_620, G_digits_636) || OrderStopLoss() == 0.0) {
               OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Ask + Ad_8 * Gd_620, G_digits_636), OrderTakeProfit(), 0, Red);
               return;
            }
         }
      }
   }
}

// E6911D0C377C3261DA664CEEE9305788
void f0_15(double Ad_0) {
   RefreshRates();
   for (G_pos_440 = OrdersTotal(); G_pos_440 >= 0; G_pos_440--) {
      OrderSelect(G_pos_440, SELECT_BY_POS, MODE_TRADES);
      if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
         if (OrderType() == OP_BUY) {
            if (OrderStopLoss() == 0.0) {
               OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Ask - Ad_0 * Gd_620, G_digits_636), OrderTakeProfit(), 0, Red);
               return;
            }
         }
      }
   }
}

// 41243DBF2E8A4563F99C9141736CD7E3
void f0_6(double Ad_0) {
   RefreshRates();
   for (G_pos_440 = OrdersTotal(); G_pos_440 >= 0; G_pos_440--) {
      OrderSelect(G_pos_440, SELECT_BY_POS, MODE_TRADES);
      if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
         if (OrderType() == OP_SELL) {
            if (OrderStopLoss() == 0.0) {
               OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Bid + Ad_0 * Gd_620, G_digits_636), OrderTakeProfit(), 0, Red);
               return;
            }
         }
      }
   }
}

// 186276D281E179E100DCD33EAB7684E9
void f0_1(double Ad_0) {
   RefreshRates();
   for (G_pos_440 = OrdersTotal(); G_pos_440 >= 0; G_pos_440--) {
      OrderSelect(G_pos_440, SELECT_BY_POS, MODE_TRADES);
      if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
         if (OrderType() == OP_BUY) {
            if (OrderTakeProfit() == 0.0) {
               OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormalizeDouble(Ask + Ad_0 * Gd_620, G_digits_636), 0, Red);
               return;
            }
         }
      }
   }
}

// D6898ACD5EFE66A6D72CF9153A84BC80
void f0_12(double Ad_0) {
   RefreshRates();
   int order_total_8 = OrdersTotal();
   for (G_pos_440 = OrdersTotal(); G_pos_440 >= 0; G_pos_440--) {
      OrderSelect(G_pos_440, SELECT_BY_POS, MODE_TRADES);
      if (OrderType() <= OP_SELL && OrderSymbol() == Symbol() && OrderMagicNumber() == magic) {
         if (OrderType() == OP_SELL) {
            if (OrderTakeProfit() == 0.0) {
               OrderModify(OrderTicket(), OrderOpenPrice(), OrderStopLoss(), NormalizeDouble(Bid - Ad_0 * Gd_620, G_digits_636), 0, Red);
               return;
            }
         }
      }
   }
}

// 099AF53F601532DBD31E0EA99FFDEB64
void f0_0(int A_cmd_0) {
   if (OrdersTotal() > 0) {
      for (G_pos_440 = OrdersTotal(); G_pos_440 >= 0; G_pos_440--) {
         OrderSelect(G_pos_440, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == magic && OrderType() == A_cmd_0) OrderDelete(OrderTicket());
      }
   }
}
