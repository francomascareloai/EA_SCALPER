
//+------------------------------------------------------------------+
//|                                      THEONE (Name).mq4       |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2019-2020, theoneea.com"
#property link      "https://theoneea.com"
#property version   "3.01"

#property description   "***THEONE***"
#property description   "=Recommended Pair EURUSD,EURJPY,USDJPY,GBPUSD,GBPJPY="
#property description   "=TF H1="
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+



#import "stdlib.ex4"
   string ErrorDescription(int a0); // DA69CBAFF4D38B87377667EEC549DE5A
#import   

extern double default_lot = 0.01;
extern int risk = 1.0;
extern double MaxSpread = 30.0;
extern bool mm = TRUE;

extern double Loto = 0.1;
extern double LotM = 10.0;
extern double StopLoss = 20;
extern double TakeProfit = 80;
int slippage = 3;
int Gi_352 = -1;
int Gi_356 = 0;
int Gi_360 = 0;
int G_datetime_364;
int G_leverage_368;
int Gi_372;
int Gi_376;
int Gi_380;
int Gi_384;
int Gi_388;
int Gi_392;
int Gi_396;
int Gi_400;
int Gi_404;
int Gi_408;
int Gi_412;
int Gi_416;
int Gi_420;
int Gi_424;
int G_count_428 = 0;
int Gi_432 = 0;
double Gda_436[30];
double G_lots_440;
double Gd_448;
double Gd_456;
double Gd_464;
extern double MinimumUseStopLevel = 10.0;
extern string VolatilitySettings = "23";
extern bool UseDynamicVolatilityLimit = TRUE;
extern double VolatilityMultiplier = 125.0;
extern double VolatilityLimit = 180.0;
extern bool UseVolatilityPercentage = TRUE;
double Gd_472;
double G_lotstep_480;
double G_marginrequired_488;
double Gd_496 = 0.0;
int Gi_504;
int Gi_508 = -1;
int Gi_512 = 3000000;
int Gi_516 = 0;
string Configuration = "23";
int Magic = -1;
string OrderCmt = "HGL";
extern bool ECN_Mode = TRUE;
extern string TradingSettings = "0012";
extern int MaxExecution = 0;
extern int MaxExecutionMinutes = 5;
extern double AddPriceGap = 0.0;
extern double TrailingStart = 1.0;
extern double Commission = 0.0;
extern double VolatilityPercentageLimit = 0.0;
extern string UseIndicatorSet = "134";
extern int UseIndicatorSwitch = 3;
extern double BBDeviation = 1.5;
extern double EnvelopesDeviation = 0.07;
extern int OrderExpireSeconds = 3600;
string Money_Management = "MM";
string Screen_Shooter = "42";
bool TakeShots = FALSE;
int DelayTicks = 1;
bool Debug = FALSE;
bool Verbose = FALSE;
int ShotsPerBar = 1;
string Gs_320 = "HGL";
int G_period_328 = 3;
int G_digits_332 = 0;
int Gi_336 = 0;
datetime G_time_340 = 0;
int G_count_344 = 0;
int Gi_348 = 0;


// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   Print("====== Initialization of ", Gs_320, " ======");
   G_datetime_364 = TimeLocal();
   Gi_336 = -1;
   G_digits_332 = Digits;
   G_leverage_368 = AccountLeverage();
   Gd_464 = MathMax(MarketInfo(Symbol(), MODE_FREEZELEVEL), MarketInfo(Symbol(), MODE_STOPLEVEL));
   Gd_472 = AccountStopoutLevel();
   G_lotstep_480 = MarketInfo(Symbol(), MODE_LOTSTEP);
   if (UseIndicatorSwitch < 1 || UseIndicatorSwitch > 4) UseIndicatorSwitch = 1;
   if (UseIndicatorSwitch == 4) UseVolatilityPercentage = FALSE;
   if (Gd_464 == 0.0 && AddPriceGap == 0.0) Gd_464 = MinimumUseStopLevel;
   StopLoss = MathMax(StopLoss, Gd_464);
   TakeProfit = MathMax(TakeProfit, Gd_464);
   VolatilityPercentageLimit = VolatilityPercentageLimit / 100.0 + 1.0;
   VolatilityMultiplier /= 10.0;
   ArrayInitialize(Gda_436, 0);
   VolatilityLimit *= Point;
   Commission = f0_12(Commission * Point);
   TrailingStart *= Point;
   Gd_464 *= Point;
   AddPriceGap *= Point;
   if (Loto < MarketInfo(Symbol(), MODE_MINLOT)) Loto = MarketInfo(Symbol(), MODE_MINLOT);
   if (LotM > MarketInfo(Symbol(), MODE_MAXLOT)) LotM = MarketInfo(Symbol(), MODE_MAXLOT);
   if (LotM < Loto) LotM = Loto;
   G_marginrequired_488 = MarketInfo(Symbol(), MODE_MARGINREQUIRED);
   Gi_372 = MarketInfo(Symbol(), MODE_LOTSIZE);
   f0_4();
   G_lots_440 = f0_11();
   if (Magic < 0) f0_13();
   if (MaxExecution > 0) MaxExecutionMinutes = 60 * MaxExecution;
   f0_14();
   Print("========== Initialization complete! ===========\n");
   start();
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   string Ls_0 = "";
   if (IsTesting() && MaxExecution > 0) {
      Ls_0 = Ls_0 + "During backtesting " + G_count_428 + " number of ticks was ";
      Ls_0 = Ls_0 + "skipped to simulate latency of up to " + MaxExecution + " ms";
      f0_3(Ls_0);
   }
   f0_5();
   Print(Gs_320, " has been deinitialized!");
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   if (iBars(Symbol(), PERIOD_M1) > G_period_328) f0_9();
   else Print("Please wait until enough of bar data has been gathered!");
   return (0);
}

// AFD14DA6E58014378C872DB68236EA0C
void f0_9() {
   string Ls_unused_8;
   bool bool_24;
   int Li_32;
   int Li_36;
   int Li_40;
   int ticket_52;
   int Li_88;
   int Li_92;
   double Ld_128;
   double price_144;
   double order_stoploss_152;
   double order_takeprofit_160;
   double Ld_184;
   double Ld_192;
   double Ld_200;
   double Ld_208;
   double Ld_216;
   double Ld_224;
   double Ld_232;
   double Ld_240;
   double Ld_248;
   double price_312;
   double Ld_344;
   if (G_time_340 < Time[0]) {
      if (Gi_432 < 10) Gi_432++;
      Gd_496 += (G_count_344 - Gd_496) / Gi_432;
      G_time_340 = Time[0];
      G_count_344 = 0;
   } else G_count_344++;
   if (IsTesting() && MaxExecution != 0 && Gi_352 != -1) {
      Ld_344 = MathRound(Gd_496 * MaxExecution / 60000.0);
      if (G_count_428 >= Ld_344) {
         Gi_352 = -1;
         G_count_428 = 0;
      } else {
         G_count_428++;
         return;
      }
   }
   double ask_96 = MarketInfo(Symbol(), MODE_ASK);
   double bid_104 = MarketInfo(Symbol(), MODE_BID);
   double ihigh_168 = iHigh(Symbol(), PERIOD_M1, 0);
   double ilow_176 = iLow(Symbol(), PERIOD_M1, 0);
   double Ld_280 = ihigh_168 - ilow_176;
   string Ls_16 = "";
   if (UseIndicatorSwitch == 1 || UseIndicatorSwitch == 4) {
      Ld_184 = iMA(Symbol(), PERIOD_M1, G_period_328, 0, MODE_LWMA, PRICE_LOW, 0);
      Ld_192 = iMA(Symbol(), PERIOD_M1, G_period_328, 0, MODE_LWMA, PRICE_HIGH, 0);
      Ld_200 = Ld_192 - Ld_184;
      Li_32 = bid_104 >= Ld_184 + Ld_200 / 2.0;
      Ls_16 = "iMA_low: " + f0_6(Ld_184) + ", iMA_high: " + f0_6(Ld_192) + ", iMA_diff: " + f0_6(Ld_200);
   }
   if (UseIndicatorSwitch == 2) {
      Ld_208 = iBands(Symbol(), PERIOD_M1, G_period_328, BBDeviation, 0, PRICE_OPEN, MODE_UPPER, 0);
      Ld_216 = iBands(Symbol(), PERIOD_M1, G_period_328, BBDeviation, 0, PRICE_OPEN, MODE_LOWER, 0);
      Ld_224 = Ld_208 - Ld_216;
      Li_36 = bid_104 >= Ld_216 + Ld_224 / 2.0;
      Ls_16 = "iBands_upper: " + f0_6(Ld_216) + ", iBands_lower: " + f0_6(Ld_216) + ", iBands_diff: " + f0_6(Ld_224);
   }
   if (UseIndicatorSwitch == 3) {
      Ld_232 = iEnvelopes(Symbol(), PERIOD_M1, G_period_328, MODE_LWMA, 0, PRICE_OPEN, EnvelopesDeviation, MODE_UPPER, 0);
      Ld_240 = iEnvelopes(Symbol(), PERIOD_M1, G_period_328, MODE_LWMA, 0, PRICE_OPEN, EnvelopesDeviation, MODE_LOWER, 0);
      Ld_248 = Ld_232 - Ld_240;
      Li_40 = bid_104 >= Ld_240 + Ld_248 / 2.0;
      Ls_16 = "iEnvelopes_upper: " + f0_6(Ld_232) + ", iEnvelopes_lower: " + f0_6(Ld_240) + ", iEnvelopes_diff: " + f0_6(Ld_248);
   }
   

   
   bool Li_48 = FALSE;
   int Li_72 = 0;
   if (UseIndicatorSwitch == 1 && Li_32 == 1) {
      Li_48 = TRUE;
      Gd_448 = Ld_192;
      Gd_456 = Ld_184;
   } else {
      if (UseIndicatorSwitch == 2 && Li_36 == 1) {
         Li_48 = TRUE;
         Gd_448 = Ld_208;
         Gd_456 = Ld_216;
      } else {
         if (UseIndicatorSwitch == 3 && Li_40 == 1) {
            Li_48 = TRUE;
            Gd_448 = Ld_232;
            Gd_456 = Ld_240;
         }
      }
   }
   double Ld_288 = ask_96 - bid_104;
   int datetime_56 = TimeCurrent() + OrderExpireSeconds;
   G_lots_440 = f0_11();
   ArrayCopy(Gda_436, Gda_436, 0, 1, 29);
   Gda_436[29] = Ld_288;
   if (Gi_348 < 30) Gi_348++;
   double Ld_320 = 0;
   int pos_64 = 29;
   for (int count_68 = 0; count_68 < Gi_348; count_68++) {
      Ld_320 += Gda_436[pos_64];
      pos_64--;
   }
   double Ld_296 = Ld_320 / Gi_348;
   double Ld_328 = f0_12(ask_96 + Commission);
   double Ld_336 = f0_12(bid_104 - Commission);
   double Ld_304 = Ld_296 + Commission;
   if (UseDynamicVolatilityLimit == TRUE) VolatilityLimit = Ld_304 * VolatilityMultiplier;
   if (Ld_280 && VolatilityLimit && Gd_456 && Gd_448 && UseIndicatorSwitch != 4) {
      if (Ld_280 > VolatilityLimit) {
         Ld_128 = Ld_280 / VolatilityLimit;
         if (UseVolatilityPercentage == FALSE || (UseVolatilityPercentage == TRUE && Ld_128 > VolatilityPercentageLimit)) {
            if (bid_104 < Gd_456) Li_72 = -1;
            else
               if (bid_104 > Gd_448) Li_72 = 1;
         }
      } else Ld_128 = 0;
   }
   if (AccountBalance() <= 0.0) {
      Comment("ERROR -- Account Balance is " + DoubleToStr(MathRound(AccountBalance()), 0));
      return;
   }
   Gi_352 = -1;
   int count_76 = 0;
   int count_80 = 0;
   for (pos_64 = 0; pos_64 < OrdersTotal(); pos_64++) {
      OrderSelect(pos_64, SELECT_BY_POS, MODE_TRADES);
      if (OrderMagicNumber() == Magic && OrderCloseTime() == 0) {
         if (OrderSymbol() != Symbol()) {
            count_80++;
            continue;
         }
         switch (OrderType()) {
         case OP_BUY:
            RefreshRates();
            order_stoploss_152 = OrderStopLoss();
            order_takeprofit_160 = OrderTakeProfit();
            if (order_takeprofit_160 < f0_12(Ld_328 + TakeProfit * Point + AddPriceGap) && Ld_328 + TakeProfit * Point + AddPriceGap - order_takeprofit_160 > TrailingStart) {
               order_stoploss_152 = f0_12(bid_104 - StopLoss * Point - AddPriceGap);
               order_takeprofit_160 = f0_12(Ld_328 + TakeProfit * Point + AddPriceGap);
               if (order_stoploss_152 != OrderStopLoss() && order_takeprofit_160 != OrderTakeProfit()) {
                  Gi_352 = GetTickCount();
                  bool_24 = OrderModify(OrderTicket(), 0, order_stoploss_152, order_takeprofit_160, datetime_56, Lime);
               }
               if (bool_24 == TRUE) {
                  Gi_352 = GetTickCount() - Gi_352;
                  if (TakeShots && (!IsTesting())) f0_8();
               } else {
                  Gi_352 = -1;
                  f0_0();
                  if (Debug || Verbose) Print("Order could not be modified because of ", ErrorDescription(GetLastError()));
                  if (order_stoploss_152 == 0.0) bool_24 = OrderModify(OrderTicket(), 0, NormalizeDouble(Bid - 30.0, G_digits_332), 0, 0, Red);
               }
            }
            count_76++;
            break;
         case OP_SELL:
            RefreshRates();
            order_stoploss_152 = OrderStopLoss();
            order_takeprofit_160 = OrderTakeProfit();
            if (order_takeprofit_160 > f0_12(Ld_336 - TakeProfit * Point - AddPriceGap) && order_takeprofit_160 - Ld_336 + TakeProfit * Point - AddPriceGap > TrailingStart) {
               order_stoploss_152 = f0_12(ask_96 + StopLoss * Point + AddPriceGap);
               order_takeprofit_160 = f0_12(Ld_336 - TakeProfit * Point - AddPriceGap);
               if (order_stoploss_152 != OrderStopLoss() && order_takeprofit_160 != OrderTakeProfit()) {
                  Gi_352 = GetTickCount();
                  bool_24 = OrderModify(OrderTicket(), 0, order_stoploss_152, order_takeprofit_160, datetime_56, Orange);
               }
               if (bool_24 == TRUE) {
                  Gi_352 = GetTickCount() - Gi_352;
                  if (TakeShots && (!IsTesting())) f0_8();
               } else {
                  Gi_352 = -1;
                  f0_0();
                  if (Debug || Verbose) Print("Order could not be modified because of ", ErrorDescription(GetLastError()));
                  Sleep(1000);
                  if (order_stoploss_152 == 0.0) bool_24 = OrderModify(OrderTicket(), 0, NormalizeDouble(Ask + 30.0, G_digits_332), 0, 0, Red);
               }
            }
            count_76++;
            break;
         case OP_BUYSTOP:
            if (Li_48 == FALSE) {
               price_144 = f0_12(ask_96 + Gd_464 + AddPriceGap);
               order_stoploss_152 = f0_12(price_144 - Ld_288 - StopLoss * Point - AddPriceGap);
               order_takeprofit_160 = f0_12(price_144 + Commission + TakeProfit * Point + AddPriceGap);
               if (price_144 < OrderOpenPrice() && OrderOpenPrice() - price_144 > TrailingStart) {
                  if (order_stoploss_152 != OrderStopLoss() && order_takeprofit_160 != OrderTakeProfit()) {
                     RefreshRates();
                     Gi_352 = GetTickCount();
                     bool_24 = OrderModify(OrderTicket(), price_144, order_stoploss_152, order_takeprofit_160, 0, Lime);
                  }
                  if (bool_24 == TRUE) {
                     Gi_352 = GetTickCount() - Gi_352;
                     if (Debug || Verbose) Print("Order executed in " + Gi_352 + " ms");
                  } else {
                     Gi_352 = -1;
                     f0_0();
                  }
               }
               count_76++;
            } else OrderDelete(OrderTicket());
            break;
         case OP_SELLSTOP:
            if (Li_48 == TRUE) {
               price_144 = f0_12(bid_104 - Gd_464 - AddPriceGap);
               order_stoploss_152 = f0_12(price_144 + Ld_288 + StopLoss * Point + AddPriceGap);
               order_takeprofit_160 = f0_12(price_144 - Commission - TakeProfit * Point - AddPriceGap);
               if (price_144 > OrderOpenPrice() && price_144 - OrderOpenPrice() > TrailingStart) {
                  if (order_stoploss_152 != OrderStopLoss() && order_takeprofit_160 != OrderTakeProfit()) {
                     RefreshRates();
                     Gi_352 = GetTickCount();
                     bool_24 = OrderModify(OrderTicket(), price_144, order_stoploss_152, order_takeprofit_160, 0, Orange);
                  }
                  if (bool_24 == TRUE) {
                     Gi_352 = GetTickCount() - Gi_352;
                     if (Debug || Verbose) Print("Order executed in " + Gi_352 + " ms");
                  } else {
                     Gi_352 = -1;
                     f0_0();
                  }
               }
               count_76++;
            } else OrderDelete(OrderTicket());
         }
      }
   }
   if (Gi_336 >= 0 || Gi_336 == -2) {
      Li_92 = NormalizeDouble(bid_104 / Point, 0);
      Li_88 = NormalizeDouble(ask_96 / Point, 0);
      if (Li_92 % 10 != 0 || Li_88 % 10 != 0) Gi_336 = -1;
      else {
         if (Gi_336 >= 0 && Gi_336 < 10) Gi_336++;
         else Gi_336 = -2;
      }
   }
   int Li_unused_28 = 0;
   if (Li_72 != 0 && MaxExecution > 0 && Gi_356 > MaxExecution) {
      Li_72 = 0;
      if (Debug || Verbose) Print("Server is too Slow. Average Execution: " + Gi_356);
   }
   double Ld_112 = ask_96 + Gd_464;
   double Ld_120 = bid_104 - Gd_464;
   if (count_76 == 0 && Li_72 != 0 && f0_12(Ld_304) <= f0_12(MaxSpread * Point) && Gi_336 == -1) {
      if (Li_72 == -1 || Li_72 == 2 ) {
         price_144 = ask_96 + Gd_464;
         if (ECN_Mode == TRUE) {
            price_144 = Ld_112;
            order_stoploss_152 = 0;
            order_takeprofit_160 = 0;
            Gi_352 = GetTickCount();
            ticket_52 = OrderSend(Symbol(), OP_BUYSTOP, G_lots_440, price_144, slippage, order_stoploss_152, order_takeprofit_160, OrderCmt, Magic, 0, Lime);
            if (ticket_52 > 0) {
               Gi_352 = GetTickCount() - Gi_352;
               if (Debug || Verbose) Print("Order executed in " + Gi_352 + " ms");
               if (TakeShots && (!IsTesting())) f0_8();
            } else {
               Li_unused_28 = 1;
               Gi_352 = -1;
               f0_0();
            }
            if (OrderSelect(ticket_52, SELECT_BY_TICKET)) {
               RefreshRates();
               price_144 = OrderOpenPrice();
               order_stoploss_152 = f0_12(price_144 - Ld_288 - StopLoss * Point - AddPriceGap);
               order_takeprofit_160 = f0_12(price_144 + TakeProfit * Point + AddPriceGap);
               Gi_352 = GetTickCount();
               bool_24 = OrderModify(OrderTicket(), price_144, order_stoploss_152, order_takeprofit_160, datetime_56, Lime);
               if (bool_24 == TRUE) {
                  Gi_352 = GetTickCount() - Gi_352;
                  if (Debug || Verbose) Print("Order executed in " + Gi_352 + " ms");
                  if (TakeShots && (!IsTesting())) f0_8();
               } else {
                  Li_unused_28 = 1;
                  Gi_352 = -1;
                  f0_0();
               }
            }
         } else {
            RefreshRates();
            price_144 = Ld_112;
            order_stoploss_152 = f0_12(price_144 - Ld_288 - StopLoss * Point - AddPriceGap);
            order_takeprofit_160 = f0_12(price_144 + TakeProfit * Point + AddPriceGap);
            Gi_352 = GetTickCount();
            ticket_52 = OrderSend(Symbol(), OP_BUYSTOP, G_lots_440, price_144, slippage, order_stoploss_152, order_takeprofit_160, OrderCmt, Magic, datetime_56, Lime);
            if (ticket_52 > 0) {
               Gi_352 = GetTickCount() - Gi_352;
               if (Debug || Verbose) Print("Order executed in " + Gi_352 + " ms");
               if (TakeShots && (!IsTesting())) f0_8();
            } else {
               Li_unused_28 = 1;
               Gi_352 = -1;
               f0_0();
            }
         }
      }
      if (Li_72 == 1 || Li_72 == 2  ) {
         price_144 = Ld_120;
         order_stoploss_152 = 0;
         order_takeprofit_160 = 0;
         if (ECN_Mode) {
            Gi_352 = GetTickCount();
            ticket_52 = OrderSend(Symbol(), OP_SELLSTOP, G_lots_440, price_144, slippage, order_stoploss_152, order_takeprofit_160, OrderCmt, Magic, 0, Orange);
            if (ticket_52 > 0) {
               Gi_352 = GetTickCount() - Gi_352;
               if (Debug || Verbose) Print("Order executed in " + Gi_352 + " ms");
               if (TakeShots && (!IsTesting())) f0_8();
            } else {
               Li_unused_28 = 1;
               Gi_352 = -1;
               f0_0();
            }
            if (OrderSelect(ticket_52, SELECT_BY_TICKET)) {
               RefreshRates();
               price_144 = OrderOpenPrice();
               order_stoploss_152 = f0_12(price_144 + Ld_288 + StopLoss * Point + AddPriceGap);
               order_takeprofit_160 = f0_12(price_144 - TakeProfit * Point - AddPriceGap);
               Gi_352 = GetTickCount();
               bool_24 = OrderModify(OrderTicket(), OrderOpenPrice(), order_stoploss_152, order_takeprofit_160, datetime_56, Orange);
            }
            if (bool_24 == TRUE) {
               Gi_352 = GetTickCount() - Gi_352;
               if (Debug || Verbose) Print("Order executed in " + Gi_352 + " ms");
               if (TakeShots && (!IsTesting())) f0_8();
            } else {
               Li_unused_28 = 1;
               Gi_352 = -1;
               f0_0();
            }
         } else {
            RefreshRates();
            price_144 = Ld_120;
            order_stoploss_152 = f0_12(price_144 + Ld_288 + StopLoss * Point + AddPriceGap);
            order_takeprofit_160 = f0_12(price_144 - TakeProfit * Point - AddPriceGap);
            Gi_352 = GetTickCount();
            ticket_52 = OrderSend(Symbol(), OP_SELLSTOP, G_lots_440, price_144, slippage, order_stoploss_152, order_takeprofit_160, OrderCmt, Magic, datetime_56, Orange);
            if (ticket_52 > 0) {
               Gi_352 = GetTickCount() - Gi_352;
               if (Debug || Verbose) Print("Order executed in " + Gi_352 + " ms");
               if (TakeShots && (!IsTesting())) f0_8();
            } else {
               Li_unused_28 = 1;
               Gi_352 = 0;
               f0_0();
            }
         }
      }
   }
   if (MaxExecution && Gi_352 == -1 && (TimeLocal() - G_datetime_364) % MaxExecutionMinutes == 0) {
      if (IsTesting() && MaxExecution) {
         MathSrand(TimeLocal());
         Gi_352 = MathRand() / (32767 / MaxExecution);
      } else {
         if (IsTesting() == FALSE) {
            price_312 = 2.0 * ask_96;
            ticket_52 = OrderSend(Symbol(), OP_BUYSTOP, G_lots_440, price_312, slippage, 0, 0, OrderCmt, Magic, 0, Lime);
            Gi_352 = GetTickCount();
            bool_24 = OrderModify(ticket_52, price_312 + 10.0 * Point, 0, 0, 0, Lime);
            Gi_352 = GetTickCount() - Gi_352;
            OrderDelete(ticket_52);
         }
      }
   }
   if (Gi_352 >= 0) {
      if (Gi_360 < 10) Gi_360++;
      Gi_356 += (Gi_352 - Gi_356) / Gi_360;
   }
   if (Gi_336 >= 0) {
      Comment("Robot is initializing...");
      return;
   }
   if (Gi_336 == -2) {
      Comment("ERROR -- Instrument " + Symbol() + " prices should have " + G_digits_332 + " fraction digits on broker account");
      return;
   }
   string Ls_0 = TimeToStr(TimeCurrent()) + " Tick: " + f0_10(G_count_344);
   if (Debug || Verbose) {
      Ls_0 = Ls_0 
      + "\n*** DEBUG MODE *** \nCurrency pair: " + Symbol() + ", Volatility: " + f0_6(Ld_280) + ", VolatilityLimit: " + f0_6(VolatilityLimit) + ", VolatilityPercentage: " + f0_6(Ld_128);
      Ls_0 = Ls_0 
      + "\nPriceDirection: " + StringSubstr("BUY NULLSELLBOTH", Li_72 * 4 + 4, 4) + ", Expire: " + TimeToStr(datetime_56, TIME_MINUTES) + ", Open orders: " + count_76;
      Ls_0 = Ls_0 
      + "\nBid: " + f0_6(bid_104) + ", Ask: " + f0_6(ask_96) + ", " + Ls_16;
      Ls_0 = Ls_0 
      + "\nAvgSpread: " + f0_6(Ld_296) + ", RealAvgSpread: " + f0_6(Ld_304) + ", Commission: " + f0_6(Commission) + ", Loto: " + DoubleToStr(G_lots_440, 2) + ", Execution: " + Gi_352 + " ms";
      if (f0_12(Ld_304) > f0_12(MaxSpread * Point)) {
         Ls_0 = Ls_0 
            + "\n" 
         + "The current spread (" + f0_6(Ld_304) + ") is higher than what has been set as MaxSpread (" + f0_6(MaxSpread * Point) + ") so no trading is allowed right now on this currency pair!";
      }
      if (MaxExecution > 0 && Gi_356 > MaxExecution) {
         Ls_0 = Ls_0 
            + "\n" 
         + "The current Avg Execution (" + Gi_356 + ") is higher than what has been set as MaxExecution (" + MaxExecution + " ms), so no trading is allowed right now on this currency pair!";
      }
      Comment(Ls_0);
      if (count_76 != 0 || Li_72 != 0) f0_2(Ls_0);
   }
}

// 7AA9CDCAF42FC1262F92557FA1F124FA
string f0_6(double Ad_0) {
   return (DoubleToStr(Ad_0, G_digits_332));
}

// DE72AA99F9D3A3AD52C2E7BCCD1BFA0C
double f0_12(double Ad_0) {
   return (NormalizeDouble(Ad_0, G_digits_332));
}

// C0E09A7A5566781BF263F5CB348E3A6C
string f0_10(int Ai_0) {
   if (Ai_0 < 10) return ("00" + Ai_0);
   if (Ai_0 < 100) return ("0" + Ai_0);
   return ("" + Ai_0);
}

// 35F45DEE3B9C1C6C9281F0DA22F81A45
void f0_2(string As_0) {
   int Li_8;
   int Li_12 = -1;
   while (Li_12 < StringLen(As_0)) {
      Li_8 = Li_12 + 1;
      Li_12 = StringFind(As_0, 
      "\n", Li_8);
      if (Li_12 == -1) {
         Print(StringSubstr(As_0, Li_8));
         return;
      }
      Print(StringSubstr(As_0, Li_8, Li_12 - Li_8));
   }
}

// DFBE3093131AABA8D77F9CB1FE6E1552
int f0_13() {
   string Ls_0 = Symbol();
   int str_len_8 = StringLen(Ls_0);
   int Li_12 = 0;
   for (int Li_16 = 0; Li_16 < str_len_8 - 1; Li_16++) Li_12 += StringGetChar(Ls_0, Li_16);
   Magic = AccountNumber() + Li_12;
   return (0);
}

// 9C2687F508CED8BB1EAB6834D518BA37
void f0_8() {
   int Li_0;
   if (ShotsPerBar > 0) Li_0 = MathRound(60 * Period() / ShotsPerBar);
   else Li_0 = 60 * Period();
   int Li_4 = MathFloor((TimeCurrent() - Time[0]) / Li_0);
   if (Time[0] != Gi_504) {
      Gi_504 = Time[0];
      Gi_508 = DelayTicks;
   } else
      if (Li_4 > Gi_512) f0_1("i");
   Gi_512 = Li_4;
   if (Gi_508 == 0) f0_1("");
   if (Gi_508 >= 0) Gi_508--;
}

// 8060808A3BF5522E8DBBF8DC133410B9
string f0_7(int Ai_0, int Ai_4) {
   for (string dbl2str_8 = DoubleToStr(Ai_0, 0); StringLen(dbl2str_8) < Ai_4; dbl2str_8 = "0" + dbl2str_8) {
   }
   return (dbl2str_8);
}

// 0DAB8A118C4EB024FE8E35E50480882E
void f0_1(string As_0 = "") {
   Gi_516++;
   string Ls_8 = "SnapShot" + Symbol() + Period() + "\\" + Year() + "-" + f0_7(Month(), 2) + "-" + f0_7(Day(), 2) + " " + f0_7(Hour(), 2) + "_" + f0_7(Minute(), 2) + "_" + f0_7(Seconds(),
      2) + " " + Gi_516 + As_0 + ".gif";
   if (!WindowScreenShot(Ls_8, 640, 480)) Print("ScreenShot error: ", ErrorDescription(GetLastError()));
}

// C3E84A38BAF4657CF1B25D6282BD8B27
double f0_11() {
   int Li_40;
   if (G_lotstep_480 == 1.0) Li_40 = 0;
   if (G_lotstep_480 == 0.1) Li_40 = 1;
   if (G_lotstep_480 == 0.01) Li_40 = 2;
   double Ld_8 = AccountEquity();
   double Ld_24 = MathMin(MathFloor(0.98 * Ld_8 / G_marginrequired_488 / G_lotstep_480) * G_lotstep_480, LotM);
   double Ld_32 = Loto;
   double Ld_ret_16 = MathMin(MathFloor(risk / 102.0 * Ld_8 / (StopLoss + AddPriceGap) / G_lotstep_480) * G_lotstep_480, LotM);
   Ld_ret_16 = NormalizeDouble(Ld_ret_16, Li_40);
   string Ls_0 = "";
   if (mm == FALSE) {
      Ld_ret_16 = default_lot;
      if (default_lot > Ld_24) {
         Ld_ret_16 = Ld_24;
         Ls_0 = "Note: Manual lotsize is too high. It has been recalculated to maximum allowed " + DoubleToStr(Ld_24, 2);
         Print(Ls_0);
         Comment(Ls_0);
         default_lot = Ld_24;
      } else
         if (default_lot < Ld_32) Ld_ret_16 = Ld_32;
   }
   return (Ld_ret_16);
}

// 48C49E5C7339D3F851087D5DB2E99BE9
double f0_4() {
   double Ld_8 = AccountEquity();
   double Ld_16 = MathFloor(Ld_8 / G_marginrequired_488 / G_lotstep_480) * G_lotstep_480;
   double Ld_40 = MathFloor(100.0 * (Ld_16 * (Gd_464 + StopLoss) / Ld_8) / 0.1) / 10.0;
   double Ld_24 = Loto;
   double Ld_48 = MathRound(100.0 * (Ld_24 * StopLoss / Ld_8) / 0.1) / 10.0;
   string Ls_0 = "";
   if (mm == TRUE) {
      if (risk > Ld_40) {
         Ls_0 = Ls_0 + "Note: risk has manually been set to " + DoubleToStr(risk, 1) + " but cannot be higher than " + DoubleToStr(Ld_40, 1) + " according to ";
         Ls_0 = Ls_0 + "the broker, StopLoss and Equity. It has now been adjusted accordingly to " + DoubleToStr(Ld_40, 1) + "%";
         risk = Ld_40;
         f0_3(Ls_0);
      }
      if (risk < Ld_48) {
         Ls_0 = Ls_0 + "Note: risk has manually been set to " + DoubleToStr(risk, 1) + " but cannot be lower than " + DoubleToStr(Ld_48, 1) + " according to ";
         Ls_0 = Ls_0 + "the broker, StopLoss, AddPriceGap and Equity. It has now been adjusted accordingly to " + DoubleToStr(Ld_48, 1) + "%";
         risk = Ld_48;
         f0_3(Ls_0);
      }
   } else {
      if (default_lot < Loto) {
         Ls_0 = "Manual lotsize " + DoubleToStr(default_lot, 2) + " cannot be less than " + DoubleToStr(Loto, 2) + ". It has now been adjusted to " + DoubleToStr(Loto,
            2);
         default_lot = Loto;
         f0_3(Ls_0);
      }
      if (default_lot > LotM) {
         Ls_0 = "Manual lotsize " + DoubleToStr(default_lot, 2) + " cannot be greater than " + DoubleToStr(LotM, 2) + ". It has now been adjusted to " + DoubleToStr(Loto,
            2);
         default_lot = LotM;
         f0_3(Ls_0);
      }
      if (default_lot > Ld_16) {
         Ls_0 = "Manual lotsize " + DoubleToStr(default_lot, 2) + " cannot be greater than maximum allowed lotsize. It has now been adjusted to " + DoubleToStr(Ld_16, 2);
         default_lot = Ld_16;
         f0_3(Ls_0);
      }
   }
   return (0.0);
}

// F97F5B4768613A27C2FAF9A2C2687B8C
void f0_14() {
   string Ls_0;
   string Ls_8;
   string Ls_16;
   int Li_24 = IsDemo() + IsTesting();
   int Li_28 = AccountFreeMarginMode();
   int Li_32 = AccountStopoutMode();
   if (Li_28 == 0) Ls_0 = "that floating profit/loss is not used for calculation.";
   else {
      if (Li_28 == 1) Ls_0 = "both floating profit and loss on open positions.";
      else {
         if (Li_28 == 2) Ls_0 = "only profitable values, where current loss on open positions are not included.";
         else
            if (Li_28 == 3) Ls_0 = "only loss values are used for calculation, where current profitable open positions are not included.";
      }
   }
   if (Li_32 == 0) Ls_8 = "percentage ratio between margin and equity.";
   else
      if (Li_32 == 1) Ls_8 = "comparison of the free margin level to the absolute value.";
   if (mm == TRUE) Ls_16 = " (automatically calculated lots).";
   if (mm == FALSE) Ls_16 = " (fixed manual lots).";
   Print("Broker name: ", AccountCompany());
   Print("Broker server: ", AccountServer());
   Print("Account type: ", StringSubstr("RealDemoTest", Li_24 * 4, 4));
   Print("Initial account balance: ", AccountBalance(), " ", AccountCurrency());
   Print("Broker digits: ", G_digits_332);
   Print("Broker stoplevel / freezelevel (max): ", Gd_464, " points.");
   Print("Broker stopout level: ", Gd_472, "%");
   Print("Broker Point: ", DoubleToStr(Point, G_digits_332), " on ", AccountCurrency());
   Print("Broker account leverage in percentage: ", G_leverage_368);
   Print("Broker credit value on the account: ", AccountCredit());
   Print("Broker account margin: ", AccountMargin());
   Print("Broker calculation of free margin allowed to open positions considers " + Ls_0);
   Print("Broker calculates stopout level as " + Ls_8);
   Print("Broker requires at least ", G_marginrequired_488, " ", AccountCurrency(), " in margin for 1 lot.");
   Print("Broker set 1 lot to trade ", Gi_372, " ", AccountCurrency());
   Print("Broker minimum allowed lotsize: ", Loto);
   Print("Broker maximum allowed lotsize: ", LotM);
   Print("Broker allow lots to be resized in ", G_lotstep_480, " steps.");
   Print("risk: ", risk, "%");
   Print("risk adjusted lotsize: ", DoubleToStr(G_lots_440, 2) + Ls_16);
}

// 38AEA7E267C4F1F66DFEFAD5F5ADFAD1
void f0_3(string As_0) {
   Print(As_0);
   Comment(As_0);
}

// 0CA6740765B96E5992006F2D8C9BDB84
void f0_0() {
   int error_0 = GetLastError();
   switch (error_0) {
   case 1/* NO_RESULT */:
      Gi_376++;
      return;
   case 4/* SERVER_BUSY */:
      Gi_380++;
      return;
   case 6/* NO_CONNECTION */:
      Gi_384++;
      return;
   case 8/* TOO_FREQUENT_REQUESTS */:
      Gi_388++;
      return;
   case 129/* INVALID_PRICE */:
      Gi_392++;
      return;
   case 130/* INVALID_STOPS */:
      Gi_396++;
      return;
   case 131/* INVALID_TRADE_VOLUME */:
      Gi_400++;
      return;
   case 135/* PRICE_CHANGED */:
      Gi_404++;
      return;
   case 137/* BROKER_BUSY */:
      Gi_408++;
      return;
   case 138/* REQUOTE */:
      Gi_412++;
      return;
   case 141/* TOO_MANY_REQUESTS */:
      Gi_416++;
      return;
   case 145/* TRADE_MODIFY_DENIED */:
      Gi_420++;
      return;
   case 146/* TRADE_CONTEXT_BUSY */:
      Gi_424++;
      return;
      return;
   }
}

// 50400725409988D8A31E8EA0D0ABA31F
void f0_5() {
   string Ls_0 = "Number of times the brokers server reported that ";
   if (Gi_376 > 0) f0_3(Ls_0 + "SL and TP was modified to existing values: " + DoubleToStr(Gi_376, 0));
   if (Gi_380 > 0) f0_3(Ls_0 + "it is buzy: " + DoubleToStr(Gi_380, 0));
   if (Gi_384 > 0) f0_3(Ls_0 + "the connection is lost: " + DoubleToStr(Gi_384, 0));
   if (Gi_388 > 0) f0_3(Ls_0 + "there was too many requests: " + DoubleToStr(Gi_388, 0));
   if (Gi_392 > 0) f0_3(Ls_0 + "the price was invalid: " + DoubleToStr(Gi_392, 0));
   if (Gi_396 > 0) f0_3(Ls_0 + "invalid SL and/or TP: " + DoubleToStr(Gi_396, 0));
   if (Gi_400 > 0) f0_3(Ls_0 + "invalid lot size: " + DoubleToStr(Gi_400, 0));
   if (Gi_404 > 0) f0_3(Ls_0 + "the price has changed: " + DoubleToStr(Gi_404, 0));
   if (Gi_408 > 0) f0_3(Ls_0 + "the broker is buzy: " + DoubleToStr(Gi_408, 0));
   if (Gi_412 > 0) f0_3(Ls_0 + "requotes " + DoubleToStr(Gi_412, 0));
   if (Gi_416 > 0) f0_3(Ls_0 + "too many requests " + DoubleToStr(Gi_416, 0));
   if (Gi_420 > 0) f0_3(Ls_0 + "modifying orders is denied " + DoubleToStr(Gi_420, 0));
   if (Gi_424 > 0) f0_3(Ls_0 + "trade context is buzy: " + DoubleToStr(Gi_424, 0));
}
