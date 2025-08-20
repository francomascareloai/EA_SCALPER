// Hedging Scalper XE
// Xtra Educated!
//
// Recommended pairs:      GBPUSD/EURGBP
// Recommended timeframes: M1, M5, H4
// M5 is perhaps best
//
// XE version will allow you to use any pair
// on any timeframe. Real or Demo account.
// No expiry or restrictions.

#property copyright "FXA Trading Group"
#property link      "http://www.forex-ea.ru"

extern bool Hedging = TRUE;
extern int MaxTrades = 1;
extern bool AutoLots = TRUE;
extern double Lots = 0.01;
extern int risk = 1;
extern bool CheckFreeMargin = TRUE;
extern double TakeProfit = 20.0;
extern double Stoploss = 2000.0;
extern double Dist1 = 40.0;
extern double Dist2 = 40.0;
extern double Dist3 = 120.0;
extern double Dist4 = 300.0;
extern double Dist5 = 400.0;
extern bool TrailSL = FALSE;
extern int TrailPips = 12;
double gd_176;
double gd_184;
double gd_192;
bool gi_200 = TRUE;
bool gi_204 = FALSE;
double gd_208;
double g_ima_216;
double g_ienvelopes_224;
double g_ienvelopes_232;
double g_ienvelopes_240;
double g_ienvelopes_248;
double g_ichimoku_256;
int gi_264 = 1;
bool gi_268 = FALSE;
bool gi_272 = TRUE;
double gd_276 = 1.667;
int g_magic_284;
double g_price_288;
double gd_296;
double gd_unused_304;
double gd_unused_312;
bool gi_unused_320 = FALSE;
double gd_unused_324 = 20.0;
double g_price_332;
double g_bid_340;
double g_ask_348;
double gd_356;
double gd_364;
double gd_372;
double gd_380 = 3.0;
double gd_388;
int gi_396 = 0;
int gi_400 = 0;
bool gi_404;
string gs_eurgbp_408 = "";
int gi_416 = 0;
bool gi_420 = FALSE;
bool gi_424 = FALSE;
bool gi_428 = FALSE;
int gi_unused_432;
int gi_436;
double gd_440;
int g_pos_448 = 0;
int gi_452;
double gd_456 = 0.0;
bool gi_464 = FALSE;
int g_datetime_468 = 0;
int g_datetime_472 = 0;

int init() {
   gd_372 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   gs_eurgbp_408 = Symbol();
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   int li_0;
   int li_4;
   int li_8;
   bool li_12;
   int l_timeframe_16;
   double ld_20;
   double ld_28;
   double ld_36;
   double l_str2dbl_44;
   double l_str2dbl_52;
   double l_str2dbl_60;
   string ls_68;
   string ls_76;
   double ld_unused_84;
   double ld_unused_92;
   int li_unused_100;
   int li_104;
   int li_unused_108;
   double ld_112;
   double l_ord_lots_120;
   double l_ord_lots_128;
   double l_iclose_136;
   double l_iclose_144;
   double ld_152;
   int li_160;
   int li_164;
      if (MarketInfo(Symbol(), MODE_LOTSTEP) == 0.1) gd_388 = 1;
      else gd_388 = 2;

            gd_208 = Dist1;
            for (int l_pos_168 = 0; l_pos_168 <= OrdersTotal() - 1; l_pos_168++) {
               OrderSelect(l_pos_168, SELECT_BY_POS, MODE_TRADES);
               if (OrderSymbol() == Symbol() && OrderMagicNumber() == 51400 || OrderMagicNumber() == 51401) {
                  if (OrderType() == OP_BUY)
                     if (OrderOpenPrice() - Bid > Stoploss / 10000.0) OrderClose(OrderTicket(), OrderLots(), Bid, 2, CLR_NONE);
                  if (OrderType() == OP_SELL)
                     if (Ask - OrderOpenPrice() > Stoploss / 10000.0) OrderClose(OrderTicket(), OrderLots(), Ask, 2, CLR_NONE);
               }
            }
            if (TrailSL == TRUE) {
               if (CountTradesB() == 1) {
                  for (int l_pos_172 = 0; l_pos_172 <= OrdersTotal() - 1; l_pos_172++) {
                     OrderSelect(l_pos_172, SELECT_BY_POS, MODE_TRADES);
                     if (OrderSymbol() == Symbol() && OrderMagicNumber() == 51400 || OrderMagicNumber() == 51402) {
                        if (OrderType() == OP_BUY)
                           if (Bid - OrderOpenPrice() >= TrailPips / 10000.0 && OrderStopLoss() < Bid - TrailPips / 10000.0 - 0.0002) OrderModify(OrderTicket(), OrderOpenPrice(), Bid - TrailPips / 10000.0 + 0.0002, Bid - TrailPips / 10000.0 + 0.0002 + 0.002, 0, Yellow);
                     }
                  }
               }
               if (CountTradesS() == 1) {
                  for (l_pos_172 = 0; l_pos_172 <= OrdersTotal() - 1; l_pos_172++) {
                     OrderSelect(l_pos_172, SELECT_BY_POS, MODE_TRADES);
                     if (OrderSymbol() == Symbol() && OrderMagicNumber() == 51402 || OrderMagicNumber() == 51402) {
                        if (OrderType() == OP_SELL)
                           if (OrderOpenPrice() - Ask >= TrailPips / 10000.0 && OrderStopLoss() > Ask + TrailPips / 10000.0 - 0.0002) OrderModify(OrderTicket(), OrderOpenPrice(), Ask + TrailPips / 10000.0 - 0.0002, Ask + TrailPips / 10000.0 - 0.0002 - 0.002, 0, Yellow);
                     }
                  }
               }
            }
            l_timeframe_16 = Period();
            if (Hedging == TRUE) {
               if (gi_200 == TRUE) g_magic_284 = 51401;
               else g_magic_284 = 12378;
 
                     ls_76 = "FXA Trading Group www.forex-ea.org";
                     ls_76 = ls_76 
                     + "\nBroker: " + AccountCompany();
                     if (IsDemo() == TRUE) {
                        ls_76 = ls_76 
                        + "\nDemo Account: " + AccountNumber();
                     } else {
                        ls_76 = ls_76 
                        + "\nReal Account: " + AccountNumber();
                     }
                     gi_unused_432 = 0;
                     if (gi_200 == TRUE) {
                        gi_464 = FALSE;
                        if (AccountLeverage() <= 500) {
                           gd_176 = AccountFreeMargin() / 500.0;
                           gd_184 = MarketInfo(Symbol(), MODE_MARGINREQUIRED) * MarketInfo(Symbol(), MODE_MINLOT);
                           if (AutoLots == TRUE) {
                              Lots = 0;
                              gd_192 = MathFloor(AccountFreeMargin() / (500.0 * gd_184)) * MarketInfo(Symbol(), MODE_MINLOT);
                              if (gd_192 < MarketInfo(Symbol(), MODE_MINLOT)) Lots = MarketInfo(Symbol(), MODE_MINLOT);
                              else Lots = gd_192;
                           }
                           if (gd_184 <= gd_176) gi_unused_432 = 1;
                           else {
                              li_104 = 500.0 * gd_184;
                              ls_76 = ls_76 
                              + "\nFree Margin should be around: " + li_104 + " [atleast]";
                           }
                        } else {
                           Lots = 0;
                           Alert("Account Leverage should be 500 or LESS\nYour Account Leverage is: ", AccountLeverage());
                        }
                     }
                     li_unused_108 = TakeProfit;
                     Comment(ls_76);
                     if (gi_396 == Time[0]) return (0);
                     gi_396 = Time[0];
                     ld_112 = CalculateProfit();
                     gi_452 = CountTrades();
                     if (gi_452 == 0) gi_404 = FALSE;
                     for (g_pos_448 = OrdersTotal() - 1; g_pos_448 >= 0; g_pos_448--) {
                        OrderSelect(g_pos_448, SELECT_BY_POS, MODE_TRADES);
                        if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_284) continue;
                        if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284) {
                           if (OrderType() == OP_BUY) {
                              gi_424 = TRUE;
                              gi_428 = FALSE;
                              l_ord_lots_120 = OrderLots();
                              break;
                           }
                        }
                        if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284) {
                           if (OrderType() == OP_SELL) {
                              gi_424 = FALSE;
                              gi_428 = TRUE;
                              l_ord_lots_128 = OrderLots();
                              break;
                           }
                        }
                     }
                     if (gi_452 > 0 && gi_452 <= MaxTrades) {
                        RefreshRates();
                        if (gi_452 == 1) gd_208 = Dist2;
                        if (gi_452 > 1) gd_208 = Dist1;
                        if (gi_452 > 2) gd_208 = Dist3;
                        if (gi_452 > 3) gd_208 = Dist4;
                        if (gi_452 > 4) gd_208 = Dist5;
                        gd_356 = LastBuyPrice();
                        gd_364 = LastSellPrice();
                        if (gi_204 != FALSE) gd_208 = 2.5 * (Dist1 * gi_452);
                        if (gi_424 && gd_356 - Ask >= gd_208 / 10000.0) gi_420 = TRUE;
                        if (gi_428 && Bid - gd_364 >= gd_208 / 10000.0) gi_420 = TRUE;
                     }
                     if (gi_452 < 1) {
                        gi_428 = FALSE;
                        gi_424 = FALSE;
                        gi_420 = TRUE;
                        gd_296 = AccountEquity();
                     }
                     if (gi_420) {
                        gd_356 = LastBuyPrice();
                        gd_364 = LastSellPrice();
                        if (gi_428) {
                           if (gi_268) {
                              fOrderCloseMarket(0, 1);
                              gd_440 = NormalizeDouble(gd_276 * l_ord_lots_128, gd_388);
                           } else gd_440 = fGetLots(OP_SELL);
                           if (gi_272) {
                              gi_416 = gi_452;
                              if (gd_440 > 0.0) {
                                 RefreshRates();
                                 if (gi_436 < 0) {
                                    Print("Error: ", GetLastError());
                                    return (0);
                                 }
                                 gd_364 = LastSellPrice();
                                 gi_420 = FALSE;
                                 gi_464 = TRUE;
                              }
                           }
                        } else {
                           if (gi_424) {
                              if (gi_268) {
                                 fOrderCloseMarket(1, 0);
                                 gd_440 = NormalizeDouble(gd_276 * l_ord_lots_120, gd_388);
                              } else gd_440 = fGetLots(OP_BUY);
                              if (gi_272) {
                                 gi_416 = gi_452;
                                 if (gd_440 > 0.0) {
                                    gi_436 = OpenPendingOrder(0, gd_440, Ask, gd_380, Bid, 0, 0, gs_eurgbp_408 + "-" + gi_416, g_magic_284, 0, Lime);
                                    if (gi_436 < 0) {
                                       Print("Error: ", GetLastError());
                                       return (0);
                                    }
                                    gd_356 = LastBuyPrice();
                                    gi_420 = FALSE;
                                    gi_464 = TRUE;
                                 }
                              }
                           }
                        }
                     }
                     if (gi_420 && gi_452 < 1) {
                        l_iclose_136 = iClose(Symbol(), 0, 2);
                        l_iclose_144 = iClose(Symbol(), 0, 1);
                        g_bid_340 = Bid;
                        g_ask_348 = Ask;
                        if (!gi_428 && !gi_424) {
                           gi_416 = gi_452;
                           if (l_iclose_136 > l_iclose_144) {
                              gd_440 = fGetLots(OP_SELL);
                              if (gd_440 > 0.0) {
                                 if (gi_436 < 0) {
                                    Print(gd_440, "Error: ", GetLastError());
                                    return (0);
                                 }
                                 gd_356 = LastBuyPrice();
                                 gi_464 = TRUE;
                              }
                           } else {
                              gd_440 = fGetLots(OP_BUY);
                              if (gd_440 > 0.0) {
                                 gi_436 = OpenPendingOrder(0, gd_440, g_ask_348, gd_380, g_ask_348, 0, 0, gs_eurgbp_408 + "-" + gi_416, g_magic_284, 0, Lime);
                                 if (gi_436 < 0) {
                                    Print(gd_440, "Error: ", GetLastError());
                                    return (0);
                                 }
                                 gd_364 = LastSellPrice();
                                 gi_464 = TRUE;
                              }
                           }
                        }
                        gi_420 = FALSE;
                     }
                     gi_452 = CountTrades();
                     g_price_332 = 0;
                     ld_152 = 0;
                     for (g_pos_448 = OrdersTotal() - 1; g_pos_448 >= 0; g_pos_448--) {
                        OrderSelect(g_pos_448, SELECT_BY_POS, MODE_TRADES);
                        if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_284) continue;
                        if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284) {
                           if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
                              g_price_332 += OrderOpenPrice() * OrderLots();
                              ld_152 += OrderLots();
                           }
                        }
                     }
                     if (gi_452 > 0) g_price_332 = NormalizeDouble(g_price_332 / ld_152, Digits);
                     if (gi_464) {
                        for (g_pos_448 = OrdersTotal() - 1; g_pos_448 >= 0; g_pos_448--) {
                           OrderSelect(g_pos_448, SELECT_BY_POS, MODE_TRADES);
                           if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_284) continue;
                           if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284) {
                              if (OrderType() == OP_BUY) {
                                 g_price_288 = g_price_332 + TakeProfit / 10000.0;
                                 gd_unused_304 = g_price_288;
                                 gd_456 = g_price_332 - Stoploss * Point;
                                 gi_404 = TRUE;
                              }
                           }
                           if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284) {
                              if (OrderType() == OP_SELL) {
                                 g_price_288 = g_price_332 - TakeProfit / 10000.0;
                                 gd_unused_312 = g_price_288;
                                 gd_456 = g_price_332 + Stoploss * Point;
                                 gi_404 = TRUE;
                              }
                           }
                        }
                     }
                     if (gi_464) {
                        if (gi_404 == TRUE) {
                           for (g_pos_448 = OrdersTotal() - 1; g_pos_448 >= 0; g_pos_448--) {
                              OrderSelect(g_pos_448, SELECT_BY_POS, MODE_TRADES);
                              if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_284) continue;
                              if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284) {
                                 if (OrderStopLoss() > 0.0) OrderModify(OrderTicket(), g_price_332, OrderStopLoss(), g_price_288, 0, Yellow);
                                 else OrderModify(OrderTicket(), g_price_332, OrderOpenPrice() - Stoploss / 10000.0, g_price_288, 0, Yellow);
                              }
                              gi_464 = FALSE;
                           }
                        }
                     }

               if (gi_200 == TRUE) {
                  gi_420 = FALSE;
                  g_magic_284 = 51402;
               } else g_magic_284 = 12378;
                  ld_20 = 0;
                  ld_28 = 0;
                  ld_36 = 0;
                  l_str2dbl_44 = 0;
                  l_str2dbl_52 = 0;
                  l_str2dbl_60 = 0;
                  //if (ld_20 == ld_28) {
                     ls_76 = "FXA Trading Group www.forex-ea.org";
                     ls_76 = ls_76 
                     + "\nBroker: " + AccountCompany();
                     if (IsDemo() == TRUE) {
                        ls_76 = ls_76 
                        + "\nDemo Account: " + AccountNumber();
                     } else {
                        ls_76 = ls_76 
                        + "\nReal Account: " + AccountNumber();
                     }
                     gi_unused_432 = 0;
                     ld_unused_84 = 0;
                     ld_unused_92 = 0;
                     li_unused_100 = 0;
                     if (gi_200 == TRUE) {
                        gi_464 = FALSE;
                        if (AccountLeverage() <= 500) {
                           gd_176 = AccountFreeMargin() / 500.0;
                           gd_184 = MarketInfo(Symbol(), MODE_MARGINREQUIRED) * MarketInfo(Symbol(), MODE_MINLOT);
                           if (AutoLots == TRUE) {
                              Lots = 0;
                              gd_192 = MathFloor(AccountFreeMargin() / (1000.0 * gd_184)) * MarketInfo(Symbol(), MODE_MINLOT);
                              if (gd_192 < MarketInfo(Symbol(), MODE_MINLOT)) Lots = MarketInfo(Symbol(), MODE_MINLOT);
                              else Lots = gd_192;
                           }
                           if (gd_184 <= gd_176) gi_unused_432 = 1;
                           else {
                              li_160 = 500.0 * gd_184;
                              ls_76 = ls_76 
                              + "\nFree Margin should be around: " + li_160 + " [atleast]";
                           }
                        } else {
                           Lots = 0;
                           Alert("Account Leverage should be 500 or LESS\nYour Account Leverage is: ", AccountLeverage());
                        }
                     }
                     li_unused_108 = TakeProfit;
                     Comment(ls_76);
                     if (gi_400 == Time[0]) return (0);
                     gi_400 = Time[0];
                     ld_112 = CalculateProfit();
                     gi_452 = CountTrades();
                     if (gi_452 == 0) gi_404 = FALSE;
                     l_ord_lots_120 = 0;
                     l_ord_lots_128 = 0;
                     for (g_pos_448 = OrdersTotal() - 1; g_pos_448 >= 0; g_pos_448--) {
                        OrderSelect(g_pos_448, SELECT_BY_POS, MODE_TRADES);
                        if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_284) continue;
                        if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284) {
                           if (OrderType() == OP_BUY) {
                              gi_424 = TRUE;
                              gi_428 = FALSE;
                              l_ord_lots_120 = OrderLots();
                              break;
                           }
                        }
                        if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284) {
                           if (OrderType() == OP_SELL) {
                              gi_424 = FALSE;
                              gi_428 = TRUE;
                              l_ord_lots_128 = OrderLots();
                              break;
                           }
                        }
                     }
                     if (gi_452 > 0 && gi_452 <= MaxTrades) {
                        RefreshRates();
                        if (gi_452 == 1) gd_208 = Dist2;
                        if (gi_452 > 1) gd_208 = Dist1;
                        if (gi_452 > 2) gd_208 = Dist3;
                        if (gi_452 > 3) gd_208 = Dist4;
                        if (gi_452 > 4) gd_208 = Dist5;
                        gd_356 = LastBuyPrice();
                        gd_364 = LastSellPrice();
                        if (gi_204 != FALSE) gd_208 = 2.5 * (Dist1 * gi_452);
                        if (gi_424 && gd_356 - Ask >= gd_208 / 10000.0) gi_420 = TRUE;
                        if (gi_428 && Bid - gd_364 >= gd_208 / 10000.0) gi_420 = TRUE;
                     }
                     if (gi_452 < 1) {
                        gi_428 = FALSE;
                        gi_424 = FALSE;
                        gi_420 = TRUE;
                        gd_296 = AccountEquity();
                     }
                     if (gi_420) {
                        gd_356 = LastBuyPrice();
                        gd_364 = LastSellPrice();
                        if (gi_428) {
                           if (gi_268) {
                              fOrderCloseMarket(0, 1);
                              gd_440 = NormalizeDouble(gd_276 * l_ord_lots_128, gd_388);
                           } else gd_440 = fGetLots(OP_SELL);
                           if (gi_272) {
                              gi_416 = gi_452;
                              if (gd_440 > 0.0) {
                                 RefreshRates();
                                 gi_436 = OpenPendingOrder(1, gd_440, Bid, gd_380, Ask, 0, 0, gs_eurgbp_408 + "-" + gi_416, g_magic_284, 0, HotPink);
                                 if (gi_436 < 0) {
                                    Print("Error: ", GetLastError());
                                    return (0);
                                 }
                                 gd_364 = LastSellPrice();
                                 gi_420 = FALSE;
                                 gi_464 = TRUE;
                              }
                           }
                        } else {
                           if (gi_424) {
                              if (gi_268) {
                                 fOrderCloseMarket(1, 0);
                                 gd_440 = NormalizeDouble(gd_276 * l_ord_lots_120, gd_388);
                              } else gd_440 = fGetLots(OP_BUY);
                              if (gi_272) {
                                 gi_416 = gi_452;
                                 if (gd_440 > 0.0) {
                                    if (gi_436 < 0) {
                                       Print("Error: ", GetLastError());
                                       return (0);
                                    }
                                    gd_356 = LastBuyPrice();
                                    gi_420 = FALSE;
                                    gi_464 = TRUE;
                                 }
                              }
                           }
                        }
                     }
                     if (gi_420 && gi_452 < 1) {
                        l_iclose_136 = iClose(Symbol(), 0, 2);
                        l_iclose_144 = iClose(Symbol(), 0, 1);
                        g_bid_340 = Bid;
                        g_ask_348 = Ask;
                        if (!gi_428 && !gi_424) {
                           gi_416 = gi_452;
                           if (l_iclose_136 > l_iclose_144) {
                              gd_440 = fGetLots(OP_SELL);
                              if (gd_440 > 0.0) {
                                 gi_436 = OpenPendingOrder(1, gd_440, g_bid_340, gd_380, g_bid_340, 0, 0, gs_eurgbp_408 + "-" + gi_416, g_magic_284, 0, HotPink);
                                 if (gi_436 < 0) {
                                    Print(gd_440, "Error: ", GetLastError());
                                    return (0);
                                 }
                                 gd_356 = LastBuyPrice();
                                 gi_464 = TRUE;
                              }
                           } else {
                              gd_440 = fGetLots(OP_BUY);
                              if (gd_440 > 0.0) {
                                 if (gi_436 < 0) {
                                    Print(gd_440, "Error: ", GetLastError());
                                    return (0);
                                 }
                                 gd_364 = LastSellPrice();
                                 gi_464 = TRUE;
                              }
                           }
                        }
                        gi_420 = FALSE;
                     }
                     gi_452 = CountTrades();
                     g_price_332 = 0;
                     ld_152 = 0;
                     for (g_pos_448 = OrdersTotal() - 1; g_pos_448 >= 0; g_pos_448--) {
                        OrderSelect(g_pos_448, SELECT_BY_POS, MODE_TRADES);
                        if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_284) continue;
                        if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284) {
                           if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
                              g_price_332 += OrderOpenPrice() * OrderLots();
                              ld_152 += OrderLots();
                           }
                        }
                     }
                     if (gi_452 > 0) g_price_332 = NormalizeDouble(g_price_332 / ld_152, Digits);
                     if (gi_464) {
                        for (g_pos_448 = OrdersTotal() - 1; g_pos_448 >= 0; g_pos_448--) {
                           OrderSelect(g_pos_448, SELECT_BY_POS, MODE_TRADES);
                           if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_284) continue;
                           if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284) {
                              if (OrderType() == OP_BUY) {
                                 g_price_288 = g_price_332 + TakeProfit / 10000.0;
                                 gd_unused_304 = g_price_288;
                                 gd_456 = g_price_332 - Stoploss * Point;
                                 gi_404 = TRUE;
                              }
                           }
                           if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284) {
                              if (OrderType() == OP_SELL) {
                                 g_price_288 = g_price_332 - TakeProfit / 10000.0;
                                 gd_unused_312 = g_price_288;
                                 gd_456 = g_price_332 + Stoploss * Point;
                                 gi_404 = TRUE;
                              }
                           }
                        }
                     }
                     if (gi_464) {
                        if (gi_404 == TRUE) {
                           for (g_pos_448 = OrdersTotal() - 1; g_pos_448 >= 0; g_pos_448--) {
                              OrderSelect(g_pos_448, SELECT_BY_POS, MODE_TRADES);
                              if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_284) continue;
                              if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284) {
                                 if (OrderStopLoss() > 0.0) OrderModify(OrderTicket(), g_price_332, OrderStopLoss(), g_price_288, 0, Yellow);
                                 else OrderModify(OrderTicket(), g_price_332, OrderOpenPrice() + Stoploss / 10000.0, g_price_288, 0, Yellow);
                              }
                              gi_464 = FALSE;
                           }
                        }
                     }

            } else {
               if (gi_200 == TRUE) {
                  gi_420 = FALSE;
                  g_magic_284 = 51402;
               } else g_magic_284 = 12378;
                  ld_20 = 0;
                  ld_28 = 0;
                  ld_36 = 0;
                  l_str2dbl_44 = 0;
                  l_str2dbl_52 = 0;
                  l_str2dbl_60 = 0;
                  if (IsDemo() == TRUE) {
                     ls_68 = AccountNumber();
                     ld_36 = StringLen(ls_68);
                     l_str2dbl_44 = StrToDouble(StringSubstr(ls_68, 0, 1));
                     l_str2dbl_52 = StrToDouble(StringSubstr(ls_68, 1, 1));
                     l_str2dbl_60 = StrToDouble(StringSubstr(ls_68, ld_36 - 1.0, 1));
                     ld_28 = AccountNumber() + 739;
                     ld_28 = ld_28 + 189.0 * l_str2dbl_44 + 204.0 * l_str2dbl_52 + 118.0 * l_str2dbl_60;
                  } else {
                     ls_68 = AccountNumber();
                     ld_36 = StringLen(ls_68);
                     l_str2dbl_44 = StrToDouble(StringSubstr(ls_68, 0, 1));
                     l_str2dbl_52 = StrToDouble(StringSubstr(ls_68, 1, 1));
                     l_str2dbl_60 = StrToDouble(StringSubstr(ls_68, ld_36 - 1.0, 1));
                     ld_28 = AccountNumber() + 839;
                     ld_28 = ld_28 + 176.0 * l_str2dbl_44 + 298.0 * l_str2dbl_52 + 328.0 * l_str2dbl_60;
                  }

                     ls_76 = "FXA Trading Group www.forex-ea.org";
                     ls_76 = ls_76 
                     + "\nBroker: " + AccountCompany();
                     if (IsDemo() == TRUE) {
                        ls_76 = ls_76 
                        + "\nDemo Account: " + AccountNumber();
                     } else {
                        ls_76 = ls_76 
                        + "\nReal Account: " + AccountNumber();
                     }
                     gi_unused_432 = 0;
                     ld_unused_84 = 0;
                     ld_unused_92 = 0;
                     li_unused_100 = 0;
                     if (gi_200 == TRUE) {
                        gi_464 = FALSE;
                        if (AccountLeverage() <= 500) {
                           gd_176 = AccountFreeMargin() / 500.0;
                           gd_184 = MarketInfo(Symbol(), MODE_MARGINREQUIRED) * MarketInfo(Symbol(), MODE_MINLOT);
                           if (AutoLots == TRUE) {
                              Lots = 0;
                              gd_192 = MathFloor(AccountFreeMargin() / (500.0 * gd_184)) * MarketInfo(Symbol(), MODE_MINLOT);
                              if (gd_192 < MarketInfo(Symbol(), MODE_MINLOT)) Lots = MarketInfo(Symbol(), MODE_MINLOT);
                              else Lots = gd_192;
                           }
                           if (gd_184 <= gd_176) gi_unused_432 = 1;
                           else {
                              li_164 = 500.0 * gd_184;
                              ls_76 = ls_76 
                              + "\nFree Margin should be around: " + li_164 + " [atleast]";
                           }
                        } else {
                           Lots = 0;
                           Alert("Account Leverage should be 100 or LESS\nYour Account Leverage is: ", AccountLeverage());
                        }
                     }
                     li_unused_108 = TakeProfit;
                     Comment(ls_76);
                     if (gi_400 == Time[0]) return (0);
                     gi_400 = Time[0];
                     ld_112 = CalculateProfit();
                     gi_452 = CountTrades();
                     if (gi_452 == 0) gi_404 = FALSE;
                     l_ord_lots_120 = 0;
                     l_ord_lots_128 = 0;
                     for (g_pos_448 = OrdersTotal() - 1; g_pos_448 >= 0; g_pos_448--) {
                        OrderSelect(g_pos_448, SELECT_BY_POS, MODE_TRADES);
                        if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_284) continue;
                        if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284) {
                           if (OrderType() == OP_BUY) {
                              gi_424 = TRUE;
                              gi_428 = FALSE;
                              l_ord_lots_120 = OrderLots();
                              break;
                           }
                        }
                        if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284) {
                           if (OrderType() == OP_SELL) {
                              gi_424 = FALSE;
                              gi_428 = TRUE;
                              l_ord_lots_128 = OrderLots();
                              break;
                           }
                        }
                     }
                     if (gi_452 > 0 && gi_452 <= MaxTrades) {
                        RefreshRates();
                        if (gi_452 == 1) gd_208 = Dist2;
                        if (gi_452 > 1) gd_208 = Dist1;
                        if (gi_452 > 2) gd_208 = Dist3;
                        if (gi_452 > 3) gd_208 = Dist4;
                        if (gi_452 > 4) gd_208 = Dist5;
                        gd_356 = LastBuyPrice();
                        gd_364 = LastSellPrice();
                        if (gi_204 != FALSE) gd_208 = 2.5 * (Dist1 * gi_452);
                        if (gi_424 && gd_356 - Ask >= gd_208 / 10000.0) gi_420 = TRUE;
                        if (gi_428 && Bid - gd_364 >= gd_208 / 10000.0) gi_420 = TRUE;
                     }
                     if (gi_452 < 1) {
                        gi_428 = FALSE;
                        gi_424 = FALSE;
                        gi_420 = TRUE;
                        gd_296 = AccountEquity();
                     }
                     if (gi_420) {
                        gd_356 = LastBuyPrice();
                        gd_364 = LastSellPrice();
                        if (gi_428) {
                           if (gi_268) {
                              fOrderCloseMarket(0, 1);
                              gd_440 = NormalizeDouble(gd_276 * l_ord_lots_128, gd_388);
                           } else gd_440 = fGetLots(OP_SELL);
                           if (gi_272) {
                              gi_416 = gi_452;
                              if (gd_440 > 0.0) {
                                 RefreshRates();
                                 gi_436 = OpenPendingOrder(1, gd_440, Bid, gd_380, Ask, 0, 0, gs_eurgbp_408 + "-" + gi_416, g_magic_284, 0, HotPink);
                                 if (gi_436 < 0) {
                                    Print("Error: ", GetLastError());
                                    return (0);
                                 }
                                 gd_364 = LastSellPrice();
                                 gi_420 = FALSE;
                                 gi_464 = TRUE;
                              }
                           }
                        } else {
                           if (gi_424) {
                              if (gi_268) {
                                 fOrderCloseMarket(1, 0);
                                 gd_440 = NormalizeDouble(gd_276 * l_ord_lots_120, gd_388);
                              } else gd_440 = fGetLots(OP_BUY);
                              if (gi_272) {
                                 gi_416 = gi_452;
                                 if (gd_440 > 0.0) {
                                    gi_436 = OpenPendingOrder(0, gd_440, Ask, gd_380, Bid, 0, 0, gs_eurgbp_408 + "-" + gi_416, g_magic_284, 0, Lime);
                                    if (gi_436 < 0) {
                                       Print("Error: ", GetLastError());
                                       return (0);
                                    }
                                    gd_356 = LastBuyPrice();
                                    gi_420 = FALSE;
                                    gi_464 = TRUE;
                                 }
                              }
                           }
                        }
                     }
                     if (gi_420 && gi_452 < 1) {
                        l_iclose_136 = iClose(Symbol(), 0, 2);
                        l_iclose_144 = iClose(Symbol(), 0, 1);
                        g_bid_340 = Bid;
                        g_ask_348 = Ask;
                        if (!gi_428 && !gi_424) {
                           gi_416 = gi_452;
                           if (l_iclose_136 > l_iclose_144) {
                              gd_440 = fGetLots(OP_SELL);
                              if (gd_440 > 0.0) {
                                 gi_436 = OpenPendingOrder(1, gd_440, g_bid_340, gd_380, g_bid_340, 0, 0, gs_eurgbp_408 + "-" + gi_416, g_magic_284, 0, HotPink);
                                 if (gi_436 < 0) {
                                    Print(gd_440, "Error: ", GetLastError());
                                    return (0);
                                 }
                                 gd_356 = LastBuyPrice();
                                 gi_464 = TRUE;
                              }
                           } else {
                              gd_440 = fGetLots(OP_BUY);
                              if (gd_440 > 0.0) {
                                 gi_436 = OpenPendingOrder(0, gd_440, g_ask_348, gd_380, g_ask_348, 0, 0, gs_eurgbp_408 + "-" + gi_416, g_magic_284, 0, Lime);
                                 if (gi_436 < 0) {
                                    Print(gd_440, "Error: ", GetLastError());
                                    return (0);
                                 }
                                 gd_364 = LastSellPrice();
                                 gi_464 = TRUE;
                              }
                           }
                        }
                        gi_420 = FALSE;
                     }
                     gi_452 = CountTrades();
                     g_price_332 = 0;
                     ld_152 = 0;
                     for (g_pos_448 = OrdersTotal() - 1; g_pos_448 >= 0; g_pos_448--) {
                        OrderSelect(g_pos_448, SELECT_BY_POS, MODE_TRADES);
                        if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_284) continue;
                        if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284) {
                           if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
                              g_price_332 += OrderOpenPrice() * OrderLots();
                              ld_152 += OrderLots();
                           }
                        }
                     }
                     if (gi_452 > 0) g_price_332 = NormalizeDouble(g_price_332 / ld_152, Digits);
                     if (gi_464) {
                        for (g_pos_448 = OrdersTotal() - 1; g_pos_448 >= 0; g_pos_448--) {
                           OrderSelect(g_pos_448, SELECT_BY_POS, MODE_TRADES);
                           if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_284) continue;
                           if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284) {
                              if (OrderType() == OP_BUY) {
                                 g_price_288 = g_price_332 + TakeProfit / 10000.0;
                                 gd_unused_304 = g_price_288;
                                 gd_456 = g_price_332 - Stoploss * Point;
                                 gi_404 = TRUE;
                              }
                           }
                           if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284) {
                              if (OrderType() == OP_SELL) {
                                 g_price_288 = g_price_332 - TakeProfit / 10000.0;
                                 gd_unused_312 = g_price_288;
                                 gd_456 = g_price_332 + Stoploss * Point;
                                 gi_404 = TRUE;
                              }
                           }
                        }
                     }
                     if (gi_464) {
                        if (gi_404 == TRUE) {
                           for (g_pos_448 = OrdersTotal() - 1; g_pos_448 >= 0; g_pos_448--) {
                              OrderSelect(g_pos_448, SELECT_BY_POS, MODE_TRADES);
                              if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_284) continue;
                              if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284) {
                                 if (OrderStopLoss() > 0.0) OrderModify(OrderTicket(), g_price_332, OrderStopLoss(), g_price_288, 0, Yellow);
                                 else {
                                    if (OrderType() == OP_SELL) OrderModify(OrderTicket(), g_price_332, OrderOpenPrice() + Stoploss / 10000.0, g_price_288, 0, Yellow);
                                    else
                                       if (OrderType() == OP_BUY) OrderModify(OrderTicket(), g_price_332, OrderOpenPrice() - Stoploss / 10000.0, g_price_288, 0, Yellow);
                                 }
                              }
                              gi_464 = FALSE;
                           }
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
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284) {
            if (OrderType() == OP_BUY && ai_0) {
               RefreshRates();
               if (!IsTradeContextBusy()) {
                  if (!OrderClose(OrderTicket(), OrderLots(), ND(Bid), 5, CLR_NONE)) {
                     Print("Error close BUY " + OrderTicket());
                     li_ret_8 = -1;
                  }
               } else {
                  if (g_datetime_468 != iTime(NULL, 0, 0)) {
                     g_datetime_468 = iTime(NULL, 0, 0);
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
                  if (g_datetime_472 != iTime(NULL, 0, 0)) {
                     g_datetime_472 = iTime(NULL, 0, 0);
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
   switch (gi_264) {
   case 0:
      ld_ret_4 = Lots * risk;
      break;
   case 1:
      ld_ret_4 = NormalizeDouble(Lots * risk * MathPow(gd_276, CountTrades()), gd_388);
      break;
   case 2:
      l_datetime_12 = 0;
      ld_ret_4 = Lots * risk;
      for (int l_pos_20 = OrdersHistoryTotal() - 1; l_pos_20 >= 0; l_pos_20--) {
         if (OrderSelect(l_pos_20, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284) {
               if (l_datetime_12 < OrderCloseTime()) {
                  l_datetime_12 = OrderCloseTime();
                  if (OrderProfit() < 0.0) ld_ret_4 = NormalizeDouble(OrderLots() * gd_276, gd_388);
                  else ld_ret_4 = Lots * risk;
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
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_284) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) l_count_0++;
   }
   return (l_count_0);
}

int CountTradesB() {
   int l_count_0 = 0;
   for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--) {
      OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == 51401 || OrderMagicNumber() == 51402)
         if (OrderType() == OP_BUY) l_count_0++;
   }
   return (l_count_0);
}

int CountTradesS() {
   int l_count_0 = 0;
   for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--) {
      OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == 51401 || OrderMagicNumber() == 51402)
         if (OrderType() == OP_SELL) l_count_0++;
   }
   return (l_count_0);
}

int OpenPendingOrder(int ai_0, double a_lots_4, double ad_unused_12, int a_slippage_20, double ad_unused_24, int ai_32, int ai_36, string a_comment_40, int a_magic_48, int a_datetime_52, color a_color_56) {
   int l_ticket_60 = 0;
   int l_error_64 = 0;
   int l_count_68 = 0;
   int li_72 = 100;
   double l_istochastic_76 = iStochastic(NULL, PERIOD_M5, 8, 4, 4, MODE_EMA, 0, MODE_MAIN, 0);
   double l_istochastic_84 = iStochastic(NULL, PERIOD_M5, 8, 4, 4, MODE_EMA, 0, MODE_SIGNAL, 0);
   switch (ai_0) {
   case 0:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         RefreshRates();
         g_ichimoku_256 = iIchimoku(Symbol(), 0, 9, 26, 52, MODE_TENKANSEN, 0);
         g_ima_216 = iMA(Symbol(), 0, 1, 0, MODE_SMA, PRICE_CLOSE, 0);
         g_ienvelopes_232 = iEnvelopes(Symbol(), 0, 99, MODE_EMA, 0, PRICE_CLOSE, 0.03, MODE_LOWER, 1);
         g_ienvelopes_232 = iEnvelopes(Symbol(), 0, 99, MODE_EMA, 0, PRICE_CLOSE, 0.05, MODE_LOWER, 1);
         if (l_istochastic_76 < 20.0) {
            if (CountTrades() == 1) {
               g_ienvelopes_248 = iEnvelopes(Symbol(), 0, 99, MODE_EMA, 0, PRICE_CLOSE, 0.15, MODE_LOWER, 1);
               if (Ask < g_ienvelopes_248) {
                  l_ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, Ask, a_slippage_20, StopLong(Bid, ai_32), TakeLong(Ask, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
                  break;
               }
            } else {
               l_ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, Ask, a_slippage_20, StopLong(Bid, ai_32), TakeLong(Ask, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
               break;
            }
            if (CountTrades() == 2) {
               g_ienvelopes_248 = iEnvelopes(Symbol(), 0, 99, MODE_EMA, 0, PRICE_CLOSE, 0.2, MODE_LOWER, 1);
               if (Ask < g_ienvelopes_248) {
                  l_ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, Ask, a_slippage_20, StopLong(Bid, ai_32), TakeLong(Ask, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
                  break;
               }
            } else {
               l_ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, Ask, a_slippage_20, StopLong(Bid, ai_32), TakeLong(Ask, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
               break;
            }
            if (CountTrades() > 2) {
               g_ienvelopes_248 = iEnvelopes(Symbol(), 0, 99, MODE_EMA, 0, PRICE_CLOSE, 0.2, MODE_LOWER, 1);
               if (Ask < g_ienvelopes_248) {
                  l_ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, Ask, a_slippage_20, StopLong(Bid, ai_32), TakeLong(Ask, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
                  break;
               }
            } else {
               l_ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, Ask, a_slippage_20, StopLong(Bid, ai_32), TakeLong(Ask, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
               break;
            }
         }
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!((l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */))) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         RefreshRates();
         g_ienvelopes_224 = iEnvelopes(Symbol(), 0, 99, MODE_EMA, 0, PRICE_CLOSE, 0.05, MODE_UPPER, 1);
         if (l_istochastic_76 > 80.0) {
            if (CountTrades() == 1) {
               g_ienvelopes_240 = iEnvelopes(Symbol(), 0, 99, MODE_EMA, 0, PRICE_CLOSE, 0.2, MODE_UPPER, 1);
               if (Bid > g_ienvelopes_240) {
                  if (High[0] < High[1] && High[1] < High[2] && High[2] < High[3] && Open[0] < Open[1] && Open[1] < Open[2] && Open[2] < Open[3]) {
                     l_ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, Bid, a_slippage_20, StopShort(Ask, ai_32), TakeShort(Bid, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
                     break;
                  }
               }
            } else {
               l_ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, Bid, a_slippage_20, StopShort(Ask, ai_32), TakeShort(Bid, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
               break;
            }
            if (CountTrades() == 2) {
               g_ienvelopes_240 = iEnvelopes(Symbol(), 0, 99, MODE_EMA, 0, PRICE_CLOSE, 0.2, MODE_UPPER, 1);
               if (Bid > g_ienvelopes_240) {
                  if (High[0] < High[1] && High[1] < High[2] && High[2] < High[3] && Open[0] < Open[1] && Open[1] < Open[2] && Open[2] < Open[3]) {
                     l_ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, Bid, a_slippage_20, StopShort(Ask, ai_32), TakeShort(Bid, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
                     break;
                  }
               }
            } else {
               l_ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, Bid, a_slippage_20, StopShort(Ask, ai_32), TakeShort(Bid, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
               break;
            }
            if (CountTrades() > 2) {
               g_ienvelopes_240 = iEnvelopes(Symbol(), 0, 99, MODE_EMA, 0, PRICE_CLOSE, 0.2, MODE_UPPER, 1);
               if (Bid > g_ienvelopes_240) {
                  if (High[0] < High[1] && High[1] < High[2] && High[2] < High[3] && Open[0] < Open[1] && Open[1] < Open[2] && Open[2] < Open[3]) {
                     l_ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, Bid, a_slippage_20, StopShort(Ask, ai_32), TakeShort(Bid, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
                     break;
                  }
               }
            } else {
               l_ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, Bid, a_slippage_20, StopShort(Ask, ai_32), TakeShort(Bid, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
               break;
            }
         }
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
   for (g_pos_448 = OrdersTotal() - 1; g_pos_448 >= 0; g_pos_448--) {
      OrderSelect(g_pos_448, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_284) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0 += OrderProfit();
   }
   return (ld_ret_0);
}

double LastBuyPrice() {
   double l_ord_open_price_0;
   int l_ticket_8;
   double ld_unused_12 = 0;
   int l_ticket_20 = 0;
   for (int l_pos_24 = OrdersTotal() - 1; l_pos_24 >= 0; l_pos_24--) {
      OrderSelect(l_pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_284) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284 && OrderType() == OP_BUY) {
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

double LastSellPrice() {
   double l_ord_open_price_0;
   int l_ticket_8;
   double ld_unused_12 = 0;
   int l_ticket_20 = 0;
   for (int l_pos_24 = OrdersTotal() - 1; l_pos_24 >= 0; l_pos_24--) {
      OrderSelect(l_pos_24, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_284) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_284 && OrderType() == OP_SELL) {
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