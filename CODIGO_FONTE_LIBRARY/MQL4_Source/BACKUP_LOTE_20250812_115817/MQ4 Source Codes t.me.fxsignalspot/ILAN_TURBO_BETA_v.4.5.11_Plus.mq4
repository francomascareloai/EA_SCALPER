// Заблокирована возможность открытия двух серий в одну сторону. 
int g_corner_100 = 1;
int gi_unused_104 = 65535;
int gi_unused_108 = 15;
string gs_calibri_112 = "Calibri";
int gi_unused_120 = 15;
int gi_unused_124 = 2;
double g_pips_128 = 20.0;

extern double LotExponent = 1.59;
extern bool DynamicPips = TRUE;
extern int DefaultPips = 22;
extern double slip = 3.0;
extern double Lots = 0.1;
extern int lotdecimal = 1;
extern double TakeProfit = 20.0;
extern double RsiMinimum = 30.0;
extern double RsiMaximum = 70.0;
extern int MagicNumber_1 = 2222;
extern int MagicNumber = 1111;
int gi_220 = 0;
int gi_224 = 0;
extern int MaxTrades = 12;
extern bool UseEquityStop = FALSE;
extern double TotalEquityRisk = 20.0;
extern bool UseTrailingStop = FALSE;
extern double gd_136 = 10.0;
extern double gd_144 = 10.0;
extern bool UseTimeOut = FALSE;
extern double MaxTradeOpenHours = 48.0;
double g_price_260;
double gd_268;
double gd_unused_276;
double gd_unused_284;
double g_price_292;
double g_bid_300;
double g_ask_308;
double gd_316;
double gd_324;
double gd_332;
double g_price_340;
double gd_348;
double gd_unused_356;
double gd_unused_364;
double g_price_372;
double g_bid_380;
double g_ask_388;
double gd_396;
double gd_404;
bool gi_420;
bool gi_424;
int g_time_428 = 0;
int gi_432;
int gi_436 = 0;
int gi_440;
int gi_444 = 0;
int gi_448 = 0;
double gd_452;
double gd_460;
int g_pos_468 = 0;
int gi_472;
int g_pos_476 = 0;
int gi_480;
double gd_484 = 0.0;
double gd_492 = 0.0;
bool gi_500 = FALSE;
bool gi_504 = FALSE;
bool gi_508 = FALSE;
bool gi_512 = FALSE;
bool gi_516 = FALSE;
bool gi_520 = FALSE;
string gs_524 = "Ilan_TURBO_V.4.5";
int gi_532;
int g_ticket_536;
int g_ticket_540;
bool gi_544 = FALSE;
bool gi_548 = FALSE;
double gd_552;
double gd_560;
double gd_568;
double gd_576;

int init() {
   gd_332 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   double l_high_56;
   double l_low_64;
   double l_iclose_72;
   double l_iclose_80;
   string l_dbl2str_0 = DoubleToStr(AccountBalance(), 2);
   ObjectCreate("zagolovok_Label", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("zagolovok_Label", "ILAN_TURBO_BETA_v4.5.12 by Geret   ", 10, gs_calibri_112, LawnGreen);
   ObjectSet("zagolovok_Label", OBJPROP_CORNER, g_corner_100);
   ObjectSet("zagolovok_Label", OBJPROP_XDISTANCE, 1);
   ObjectSet("zagolovok_Label", OBJPROP_YDISTANCE, 30);
   string l_dbl2str_8 = DoubleToStr(AccountBalance(), 2);
   //ObjectCreate("zagolovok1_Label", OBJ_LABEL, 0, 0, 0);
   //ObjectSetText("zagolovok1_Label", "________________________", 10, gs_calibri_112, Red);
   //ObjectSet("zagolovok1_Label", OBJPROP_CORNER, g_corner_100);
   //ObjectSet("zagolovok1_Label", OBJPROP_XDISTANCE, 1);
   //ObjectSet("zagolovok1_Label", OBJPROP_YDISTANCE, 35);
   //string l_dbl2str_16 = DoubleToStr(AccountBalance(), 2);
   ObjectCreate("Balans_Label", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("Balans_Label", "Баланс счета    " + l_dbl2str_8, 10, gs_calibri_112, Yellow);
   ObjectSet("Balans_Label", OBJPROP_CORNER, g_corner_100);
   ObjectSet("balans_Label", OBJPROP_XDISTANCE, 20);
   ObjectSet("Balans_Label", OBJPROP_YDISTANCE, 60);
   string l_dbl2str_24 = DoubleToStr(AccountEquity(), 2);
   ObjectCreate("sr_Label", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("sr_Label", "Свободные средства    " + l_dbl2str_24, 10, gs_calibri_112, Yellow);
   ObjectSet("sr_Label", OBJPROP_CORNER, g_corner_100);
   ObjectSet("sr_Label", OBJPROP_XDISTANCE, 20);
   ObjectSet("sr_Label", OBJPROP_YDISTANCE, 90);
   string ls_32 = CountTrades();
   ObjectCreate("orders_Label", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("orders_Label", "Ордеров серии 1               " + ls_32, 10, gs_calibri_112, Yellow);
   ObjectSet("orders_Label", OBJPROP_CORNER, g_corner_100);
   ObjectSet("orders_Label", OBJPROP_XDISTANCE, 20);
   ObjectSet("orders_Label", OBJPROP_YDISTANCE, 120);
   string ls_40 = CountTrades_1();
   ObjectCreate("orders1_Label", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("orders1_Label", "Ордеров серии 2               " + ls_40, 10, gs_calibri_112, Yellow);
   ObjectSet("orders1_Label", OBJPROP_CORNER, g_corner_100);
   ObjectSet("orders1_Label", OBJPROP_XDISTANCE, 20);
   ObjectSet("orders1_Label", OBJPROP_YDISTANCE, 150);
   string l_dbl2str_48 = DoubleToStr(AccountBalance(), 2);
   //ObjectCreate("zagolovok2_Label", OBJ_LABEL, 0, 0, 0);
   //ObjectSetText("zagolovok2_Label", "_________________________", 10, gs_calibri_112, Red);
   //ObjectSet("zagolovok2_Label", OBJPROP_CORNER, g_corner_100);
   //ObjectSet("zagolovok2_Label", OBJPROP_XDISTANCE, 1);
   //ObjectSet("zagolovok2_Label", OBJPROP_YDISTANCE, 155);
   if (DynamicPips) {
      l_high_56 = High[iHighest(NULL, 0, MODE_HIGH, 36, 1)];
      l_low_64 = Low[iLowest(NULL, 0, MODE_LOW, 36, 1)];
      gi_220 = NormalizeDouble((l_high_56 - l_low_64) / 3.0 / Point, 2);
      if (gi_220 < DefaultPips / 2) gi_220 = DefaultPips / 2;
      if (gi_220 > 2 * DefaultPips) gi_220 = DefaultPips * 2;
   } else gi_220 = DefaultPips;
   if (UseTrailingStop) TrailingAlls_1(gd_136, gd_144, g_price_292);
   if (UseTimeOut) {
      if (TimeCurrent() >= gi_432) {
         CloseThisSymbolAll();
         Print("Closed All due to TimeOut");
      }
   }
   if (g_time_428 == Time[0]) return (0);
   g_time_428 = Time[0];
   double ld_88 = CalculateProfit_1();
   if (UseEquityStop) {
      if (ld_88 < 0.0 && MathAbs(ld_88) > TotalEquityRisk / 100.0 * AccountEquityHigh_1()) {
         CloseThisSymbolAll();
         Print("Closed All due to Stop Out");
         gi_544 = FALSE;
      }
   }
   gi_472 = CountTrades_1();
   if (gi_472 == 0) gi_420 = FALSE;
   for (g_pos_468 = OrdersTotal() - 1; g_pos_468 >= 0; g_pos_468--) {
      OrderSelect(g_pos_468, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_1) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1) {
         if (OrderType() == OP_BUY) {
            gi_504 = TRUE;
            gi_508 = FALSE;
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1) {
         if (OrderType() == OP_SELL) {
            gi_504 = FALSE;
            gi_508 = TRUE;
            break;
         }
      }
   }
   if (gi_472 > 0 && gi_472 <= MaxTrades) {
      RefreshRates();
      gd_316 = FindLastBuyPrice_1();
      gd_324 = FindLastSellPrice_1();
      if (gi_504 && gd_316 - Ask >= gi_220 * Point) gi_500 = TRUE;
      if (gi_508 && Bid - gd_324 >= gi_220 * Point) gi_500 = TRUE;
   }
   if (gi_472 < 1) {
      gi_508 = FALSE;
      gi_504 = FALSE;
      gi_500 = TRUE;
      gd_268 = AccountEquity();
   }
   if (gi_500) {
      gd_316 = FindLastBuyPrice_1();
      gd_324 = FindLastSellPrice_1();
      if (gi_508) {
         gi_444 = gi_472;
         gd_452 = NormalizeDouble(Lots * MathPow(LotExponent, gi_444), lotdecimal);
         RefreshRates();
         gi_532 = OpenPendingOrder_1(1, gd_452, Bid, slip, Ask, 0, 0, gs_524 + "-" + gi_444, MagicNumber_1, 0, HotPink);
         if (gi_532 < 0) {
            Print("Error: ", GetLastError());
            return (0);
         }
         gd_324 = FindLastSellPrice_1();
         gi_500 = FALSE;
         gi_544 = TRUE;
      } else {
         if (gi_504) {
            gi_444 = gi_472;
            gd_452 = NormalizeDouble(Lots * MathPow(LotExponent, gi_444), lotdecimal);
            gi_532 = OpenPendingOrder_1(0, gd_452, Ask, slip, Bid, 0, 0, gs_524 + "-" + gi_444, MagicNumber_1, 0, Lime);
            if (gi_532 < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            gd_316 = FindLastBuyPrice_1();
            gi_500 = FALSE;
            gi_544 = TRUE;
         }
      }
   }
   if (gi_500 && gi_472 < 1) {
      l_iclose_72 = iClose(Symbol(), 0, 2);
      l_iclose_80 = iClose(Symbol(), 0, 1);
      g_bid_300 = Bid;
      g_ask_308 = Ask;
      if (!gi_508 && !gi_504) {
         gi_444 = gi_472;
         gd_452 = NormalizeDouble(Lots * MathPow(LotExponent, gi_444), lotdecimal);
         if (l_iclose_72 > l_iclose_80) {
            if ((FindLastSellPrice()==0)&&(iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1)) > RsiMinimum) {
               gi_532 = OpenPendingOrder_1(1, gd_452, g_bid_300, slip, g_bid_300, 0, 0, gs_524 + "-" + gi_444, MagicNumber_1, 0, HotPink);
               if (gi_532 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               gd_316 = FindLastBuyPrice_1();
               gi_544 = TRUE;
            }
         } else {
            if ((FindLastBuyPrice()==0)&&(iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) < RsiMaximum)) {
               gi_532 = OpenPendingOrder_1(0, gd_452, g_ask_308, slip, g_ask_308, 0, 0, gs_524 + "-" + gi_444, MagicNumber_1, 0, Lime);
               if (gi_532 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               gd_324 = FindLastSellPrice_1();
               gi_544 = TRUE;
            }
         }
         if (gi_532 > 0) gi_432 = TimeCurrent() + 60.0 * (60.0 * MaxTradeOpenHours);
         gi_500 = FALSE;
      }
   }
   gi_472 = CountTrades_1();
   g_price_292 = 0;
   double ld_96 = 0;
   for (g_pos_468 = OrdersTotal() - 1; g_pos_468 >= 0; g_pos_468--) {
      OrderSelect(g_pos_468, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_1) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            g_price_292 += OrderOpenPrice() * OrderLots();
            ld_96 += OrderLots();
         }
      }
   }
   if (gi_472 > 0) g_price_292 = NormalizeDouble(g_price_292 / ld_96, Digits);
   if (gi_544) {
      for (g_pos_468 = OrdersTotal() - 1; g_pos_468 >= 0; g_pos_468--) {
         OrderSelect(g_pos_468, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_1) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1) {
            if (OrderType() == OP_BUY) {
               g_price_260 = g_price_292 + TakeProfit * Point;
               gd_unused_276 = g_price_260;
               gd_484 = g_price_292 - g_pips_128 * Point;
               gi_420 = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1) {
            if (OrderType() == OP_SELL) {
               g_price_260 = g_price_292 - TakeProfit * Point;
               gd_unused_284 = g_price_260;
               gd_484 = g_price_292 + g_pips_128 * Point;
               gi_420 = TRUE;
            }
         }
      }
   }
   if (gi_544) {
      if (gi_420 == TRUE) {
         for (g_pos_468 = OrdersTotal() - 2; g_pos_468 >= 0; g_pos_468--) {
            OrderSelect(g_pos_468, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_1) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1) OrderModify(OrderTicket(), g_price_292, OrderStopLoss(), g_price_260, 0, Yellow);
            gi_544 = FALSE;
         }
      }
   }
   if (DynamicPips) {
      gi_224 = NormalizeDouble((l_high_56 - l_low_64) / 3.0 / Point, 2);
      if (gi_224 < DefaultPips / 2) gi_224 = DefaultPips / 2;
      if (gi_224 > 2 * DefaultPips) gi_224 = DefaultPips * 2;
   } else gi_224 = DefaultPips;
   if (UseTrailingStop) TrailingAlls(gd_136, gd_144, g_price_372);
   if (UseTimeOut) {
      if (TimeCurrent() >= gi_440) {
         CloseThisSymbolAll();
         Print("Closed All due to TimeOut");
      }
   }
   if (gi_436 == Time[0]) return (0);
   gi_436 = Time[0];
   double ld_104 = CalculateProfit();
   if (UseEquityStop) {
      if (ld_104 < 0.0 && MathAbs(ld_104) > TotalEquityRisk / 100.0 * AccountEquityHigh()) {
         CloseThisSymbolAll();
         Print("Closed All due to Stop Out");
         gi_548 = FALSE;
      }
   }
   gi_480 = CountTrades();
   if (gi_480 == 0) gi_424 = FALSE;
   for (g_pos_476 = OrdersTotal() - 1; g_pos_476 >= 0; g_pos_476--) {
      OrderSelect(g_pos_476, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         if (OrderType() == OP_BUY) {
            gi_516 = TRUE;
            gi_520 = FALSE;
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         if (OrderType() == OP_SELL) {
            gi_516 = FALSE;
            gi_520 = TRUE;
            break;
         }
      }
   }
   if (gi_480 > 0 && gi_480 <= MaxTrades) {
      RefreshRates();
      gd_396 = FindLastBuyPrice();
      gd_404 = FindLastSellPrice();
      if (gi_516 && gd_396 - Ask >= gi_224 * Point) gi_512 = TRUE;
      if (gi_520 && Bid - gd_404 >= gi_224 * Point) gi_512 = TRUE;
   }
   if (gi_480 < 1) {
      gi_520 = FALSE;
      gi_516 = FALSE;
      gi_512 = TRUE;
      gd_348 = AccountEquity();
   }
   if (gi_512) {
      gd_396 = FindLastBuyPrice();
      gd_404 = FindLastSellPrice();
      if (gi_520) {
         gi_448 = gi_480;
         gd_460 = NormalizeDouble(Lots * MathPow(LotExponent, gi_448), lotdecimal);
         RefreshRates();
         gi_532 = OpenPendingOrder(1, gd_460, Bid, slip, Ask, 0, 0, gs_524 + "-" + gi_448, MagicNumber, 0, HotPink);
         if (gi_532 < 0) {
            Print("Error: ", GetLastError());
            return (0);
         }
         gd_404 = FindLastSellPrice();
         gi_512 = FALSE;
         gi_548 = TRUE;
      } else {
         if (gi_516) {
            gi_448 = gi_480;
            gd_460 = NormalizeDouble(Lots * MathPow(LotExponent, gi_448), lotdecimal);
            gi_532 = OpenPendingOrder(0, gd_460, Ask, slip, Bid, 0, 0, gs_524 + "-" + gi_448, MagicNumber, 0, Lime);
            if (gi_532 < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            gd_396 = FindLastBuyPrice();
            gi_512 = FALSE;
            gi_548 = TRUE;
         }
      }
   }
   if (gi_512 && gi_480 > 0) {
      l_iclose_72 = iClose(Symbol(), 0, 2);
      l_iclose_80 = iClose(Symbol(), 0, 1);
      g_bid_380 = Bid;
      g_ask_388 = Ask;
      if (!gi_520 && !gi_516) {
         gi_448 = gi_480;
         gd_460 = NormalizeDouble(Lots * MathPow(LotExponent, gi_448), lotdecimal);
         if (l_iclose_72 > l_iclose_80) {
            if ((FindLastSellPrice_1()==0)&&(iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1)) > RsiMinimum) {
               gi_532 = OpenPendingOrder(1, gd_460, g_bid_380, slip, g_bid_380, 0, 0, gs_524 + "-" + gi_448, MagicNumber, 0, HotPink);
               if (gi_532 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               gd_396 = FindLastBuyPrice();
               gi_548 = TRUE;
            }
         } else {
            if ((FindLastBuyPrice_1()==0)&&(iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1)) < RsiMaximum) {
               gi_532 = OpenPendingOrder(0, gd_460, g_ask_388, slip, g_ask_388, 0, 0, gs_524 + "-" + gi_448, MagicNumber, 0, Lime);
               if (gi_532 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               gd_404 = FindLastSellPrice();
               gi_548 = TRUE;
            }
         }
         if (gi_532 > 0) gi_440 = TimeCurrent() + 60.0 * (60.0 * MaxTradeOpenHours);
         gi_512 = FALSE;
      }
   }
   gi_480 = CountTrades();
   g_price_372 = 0;
   double ld_112 = 0;
   for (g_pos_476 = OrdersTotal() - 1; g_pos_476 >= 0; g_pos_476--) {
      OrderSelect(g_pos_476, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            g_price_372 += OrderOpenPrice() * OrderLots();
            ld_112 += OrderLots();
         }
      }
   }
   if (gi_480 > 0) g_price_372 = NormalizeDouble(g_price_372 / ld_112, Digits);
   if (gi_548) {
      for (g_pos_476 = OrdersTotal() - 1; g_pos_476 >= 0; g_pos_476--) {
         OrderSelect(g_pos_476, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_BUY) {
               g_price_340 = g_price_372 + TakeProfit * Point;
               gd_unused_356 = g_price_340;
               gd_492 = g_price_372 - g_pips_128 * Point;
               gi_424 = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_SELL) {
               g_price_340 = g_price_372 - TakeProfit * Point;
               gd_unused_364 = g_price_340;
               gd_492 = g_price_372 + g_pips_128 * Point;
               gi_424 = TRUE;
            }
         }
      }
   }
   if (gi_548) {
      if (gi_424 == TRUE) {
         for (g_pos_476 = OrdersTotal() - 2; g_pos_476 >= 0; g_pos_476--) {
            OrderSelect(g_pos_476, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) OrderModify(OrderTicket(), g_price_372, OrderStopLoss(), g_price_340, 0, Yellow);
            gi_548 = FALSE;
         }
      }
   }
   return (0);
}

int OpenPendingOrder_1(int ai_0, double a_lots_4, double a_price_12, int a_slippage_20, double ad_24, int ai_32, int ai_36, string a_comment_40, int a_magic_48, int a_datetime_52, color a_color_56) {
   int l_ticket_60 = 0;
   int l_error_64 = 0;
   int l_count_68 = 0;
   int li_72 = 100;
   switch (ai_0) {
   case 2:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, a_lots_4, a_price_12, a_slippage_20, StopLong_1(ad_24, ai_32), TakeLong_1(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(1000);
      }
      break;
   case 4:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, a_lots_4, a_price_12, a_slippage_20, StopLong_1(ad_24, ai_32), TakeLong_1(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 0:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         RefreshRates();
         l_ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, NormalizeDouble(Ask,Digits), a_slippage_20, StopLong_1(Bid, ai_32), NormalizeDouble(Ask + 15.0 * Point, Digits), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         RefreshRates();
         if (CountTrades() < 1) g_ticket_536 = OrderSend(Symbol(), OP_SELL, a_lots_4, NormalizeDouble(Bid,Digits), a_slippage_20, StopLong_1(Bid, ai_32), NormalizeDouble(Bid - 15.0 * Point, Digits), a_comment_40, MagicNumber, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 3:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, a_lots_4, a_price_12, a_slippage_20, StopShort_1(ad_24, ai_32), TakeShort_1(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 5:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, a_lots_4, a_price_12, a_slippage_20, StopShort_1(ad_24, ai_32), TakeShort_1(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, NormalizeDouble(Bid,Digits), a_slippage_20, StopShort_1(Ask, ai_32), NormalizeDouble(Bid - 15.0 * Point, Digits), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         if (CountTrades() < 1) g_ticket_536 = OrderSend(Symbol(), OP_BUY, a_lots_4, NormalizeDouble(Ask,Digits), a_slippage_20, StopShort_1(Ask, ai_32), NormalizeDouble(Bid + 15.0 * Point, Digits), a_comment_40, MagicNumber, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
   }
   return (l_ticket_60);
}

double StopLong_1(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 - ai_8 * Point);
}

double StopShort_1(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 + ai_8 * Point);
}

double TakeLong_1(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 + ai_8 * Point);
}

double TakeShort_1(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   return (ad_0 - ai_8 * Point);
}

double CalculateProfit_1() {
   double ld_ret_0 = 0;
   for (g_pos_468 = OrdersTotal() - 1; g_pos_468 >= 0; g_pos_468--) {
      OrderSelect(g_pos_468, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_1) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0 += OrderProfit();
   }
   return (ld_ret_0);
}

void TrailingAlls_1(int ai_0, int ai_4, double a_price_8) {
   int li_16;
   double l_ord_stoploss_20;
   double l_price_28;
   if (ai_4 != 0) {
      for (int l_pos_36 = OrdersTotal() - 1; l_pos_36 >= 0; l_pos_36--) {
         if (OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_1) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber_1) {
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

double AccountEquityHigh_1() {
   if (CountTrades_1() == 0) gd_552 = AccountEquity();
   if (gd_552 < gd_560) gd_552 = gd_560;
   else gd_552 = AccountEquity();
   gd_560 = AccountEquity();
   return (gd_552);
}

double FindLastBuyPrice_1() {
   double l_ord_open_price_0;
   int l_ticket_8;
   double ld_unused_12 = 0;
   int l_ticket_20 = 0;
   for (int l_pos_24 = OrdersTotal() - 1; l_pos_24 >= 0; l_pos_24--) {
      OrderSelect(l_pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_1) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1 && OrderType() == OP_BUY) {
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

double FindLastSellPrice_1() {
   double l_ord_open_price_0;
   int l_ticket_8;
   double ld_unused_12 = 0;
   int l_ticket_20 = 0;
   for (int l_pos_24 = OrdersTotal() - 1; l_pos_24 >= 0; l_pos_24--) {
      OrderSelect(l_pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_1) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1 && OrderType() == OP_SELL) {
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

int CountTrades() {
   int l_count_0 = 0;
   for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--) {
      OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) l_count_0++;
   }
   return (l_count_0);
}

int OpenPendingOrder(int ai_0, double a_lots_4, double a_price_12, int a_slippage_20, double ad_24, int ai_32, int ai_36, string a_comment_40, int a_magic_48, int a_datetime_52, color a_color_56) {
   int l_ticket_60 = 0;
   int l_error_64 = 0;
   int l_count_68 = 0;
   int li_72 = 100;
   switch (ai_0) {
   case 2:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_BUYLIMIT, a_lots_4, a_price_12, a_slippage_20, StopLong(ad_24, ai_32), TakeLong(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(1000);
      }
      break;
   case 4:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, a_lots_4, a_price_12, a_slippage_20, StopLong(ad_24, ai_32), TakeLong(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 0:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         RefreshRates();
         l_ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, NormalizeDouble(Ask,Digits), a_slippage_20, StopLong(Bid, ai_32), NormalizeDouble(Ask + 15.0 * Point, Digits), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         RefreshRates();
         if (CountTrades_1() < 1) g_ticket_540 = OrderSend(Symbol(), OP_SELL, a_lots_4, NormalizeDouble(Bid,Digits), a_slippage_20, StopLong(Bid, ai_32), NormalizeDouble(Ask - 15.0 * Point, Digits), a_comment_40, MagicNumber_1, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 3:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, a_lots_4, a_price_12, a_slippage_20, StopShort(ad_24, ai_32), TakeShort(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 5:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, a_lots_4, a_price_12, a_slippage_20, StopShort(ad_24, ai_32), TakeShort(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, NormalizeDouble(Bid,Digits), a_slippage_20, StopShort(Ask, ai_32), NormalizeDouble(Bid - 15.0 * Point, Digits), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         if (CountTrades_1() < 1) g_ticket_540 = OrderSend(Symbol(), OP_BUY, a_lots_4, NormalizeDouble(Ask,Digits), a_slippage_20, StopShort(Ask, ai_32), NormalizeDouble(Bid + 15.0 * Point, Digits), a_comment_40, MagicNumber_1, a_datetime_52, a_color_56);
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
   for (g_pos_476 = OrdersTotal() - 1; g_pos_476 >= 0; g_pos_476--) {
      OrderSelect(g_pos_476, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0 += OrderProfit();
   }
   return (ld_ret_0);
}

int CountTrades_1() {
   int l_count_0 = 0;
   for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--) {
      OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber_1) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) l_count_0++;
   }
   return (l_count_0);
}

void CloseThisSymbolAll() {
   for (int l_pos_0 = OrdersTotal() - 1; l_pos_0 >= 0; l_pos_0--) {
      OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber_1) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slip, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slip, Red);
         }
         Sleep(1000);
      }
   }
}

void TrailingAlls(int ai_0, int ai_4, double a_price_8) {
   int li_16;
   double l_ord_stoploss_20;
   double l_price_28;
   if (ai_4 != 0) {
      for (int l_pos_36 = OrdersTotal() - 1; l_pos_36 >= 0; l_pos_36--) {
         if (OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == MagicNumber) {
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
   if (CountTrades() == 0) gd_568 = AccountEquity();
   if (gd_568 < gd_576) gd_568 = gd_576;
   else gd_568 = AccountEquity();
   gd_576 = AccountEquity();
   return (gd_568);
}

double FindLastBuyPrice() {
   double l_ord_open_price_0;
   int l_ticket_8;
   double ld_unused_12 = 0;
   int l_ticket_20 = 0;
   for (int l_pos_24 = OrdersTotal() - 1; l_pos_24 >= 0; l_pos_24--) {
      OrderSelect(l_pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) {
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
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_SELL) {
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