//+------------------------------------------------------------------+
//|                                      Double(Ilan1_5&Ilan1_6).mq4 |
//|                                                       BETSAFE    |
//|                                        http://beam.to/betsafe    |
//+------------------------------------------------------------------+
#property copyright "BETSAFE"
#property link      "http://beam.to/betsafe"

extern string t1 = "Íàñòðîéêè ýêñïåðòà Ilan 1.5";
extern int OpenNewTF = 60;
extern double LotExponent = 1.59;
extern double slip = 3.0;
int gi_unused_88;
extern double Lots = 0.01;
extern int lotdecimal = 2;
extern double TakeProfit = 10.0;
extern double Stoploss = 500.0;
extern double TrailStart = 10.0;
extern double TrailStop = 10.0;
extern double PipStep = 30.0;
extern int MaxTrades = 10;
extern bool UseEquityStop = FALSE;
extern double TotalEquityRisk = 20.0;
extern bool UseTrailingStop = FALSE;
extern bool UseTimeOut = FALSE;
extern double MaxTradeOpenHours = 48.0;
extern int g_magic_176 = 12324;
double g_price_180;
double gd_188;
double gd_unused_196;
double gd_unused_204;
double g_price_212;
double g_bid_220;
double g_ask_228;
double gd_236;
double gd_244;
double gd_260;
bool gi_268;
string gs_ilan_272 = "Ilan 1.5";
int gi_280 = 0;
int gi_284;
int gi_288 = 0;
double gd_292;
int g_pos_300 = 0;
int gi_304;
double gd_308 = 0.0;
bool gi_316 = FALSE;
bool gi_320 = FALSE;
bool gi_324 = FALSE;
int gi_328;
bool gi_332 = FALSE;
double gd_336;
double gd_344;
datetime time_15=1;
//========================================================================
extern string t2 = "Íàñòðîéêè ýêñïåðòà Ilan 1.6";
extern int OpenNewTF_16 = 1;
extern double LotExponent_16 = 1.59;
extern double slip_16 = 3.0;
extern double Lots_16 = 0.01;
extern int lotdecimal_16 = 2;
extern double TakeProfit_16 = 10.0;
extern double Stoploss_16 = 500.0;
extern double TrailStart_16 = 10.0;
extern double TrailStop_16 = 10.0;
extern double PipStep_16 = 30.0;
extern int MaxTrades_16 = 10;
extern bool UseEquityStop_16 = FALSE;
extern double TotalEquityRisk_16 = 20.0;
extern bool UseTrailingStop_16 = FALSE;
extern bool UseTimeOut_16 = FALSE;
extern double MaxTradeOpenHours_16 = 48.0;
extern int g_magic_176_16 = 16794;
double g_price_180_16;
double gd_188_16;
double gd_unused_196_16;
double gd_unused_204_16;
double g_price_212_16;
double g_bid_220_16;
double g_ask_228_16;
double gd_236_16;
double gd_244_16;
double gd_260_16;
bool gi_268_16;
string gs_ilan_272_16 = "Ilan 1.6";
int gi_280_16 = 0;
int gi_284_16;
int gi_288_16 = 0;
double gd_292_16;
int g_pos_300_16 = 0;
int gi_304_16;
double gd_308_16 = 0.0;
bool gi_316_16 = FALSE;
bool gi_320_16 = FALSE;
bool gi_324_16 = FALSE;
int gi_328_16;
bool gi_332_16 = FALSE;
double gd_336_16;
double gd_344_16;
datetime time_16=1;
//========================================================================

int init()
  {
   gd_260 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   gd_260_16 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   return;
  }

int deinit()
  {

   return;
  }

int start()
  {
//========================================================================//
//                       ÏÐÎÃÐÀÌÍÛÉ ÊÎÄ Ilan 1.5                          //
//========================================================================//
   double l_iclose_8;
   double l_iclose_16;
   if (UseTrailingStop) TrailingAlls(TrailStart, TrailStop, g_price_212);
   if (UseTimeOut) {
      if (TimeCurrent() >= gi_284) {
         CloseThisSymbolAll();
         Print("Closed All due to TimeOut");
      }
   }
   if (gi_280 != Time[0])
   {
   gi_280 = Time[0];
   double ld_0 = CalculateProfit();
   if (UseEquityStop) {
      if (ld_0 < 0.0 && MathAbs(ld_0) > TotalEquityRisk / 100.0 * AccountEquityHigh()) {
         CloseThisSymbolAll();
         Print("Closed All due to Stop Out");
         gi_332 = FALSE;
      }
   }
   gi_304 = CountTrades();
   if (gi_304 == 0) gi_268 = FALSE;
   for (g_pos_300 = OrdersTotal() - 1; g_pos_300 >= 0; g_pos_300--) {
      OrderSelect(g_pos_300, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176) {
         if (OrderType() == OP_BUY) {
            gi_320 = TRUE;
            gi_324 = FALSE;
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176) {
         if (OrderType() == OP_SELL) {
            gi_320 = FALSE;
            gi_324 = TRUE;
            break;
         }
      }
   }
   if (gi_304 > 0 && gi_304 <= MaxTrades) {
      RefreshRates();
      gd_236 = FindLastBuyPrice();
      gd_244 = FindLastSellPrice();
      if (gi_320 && gd_236 - Ask >= PipStep * Point) gi_316 = TRUE;
      if (gi_324 && Bid - gd_244 >= PipStep * Point) gi_316 = TRUE;
   }
   if (gi_304 < 1) {
      gi_324 = FALSE;
      gi_320 = FALSE;
      gi_316 = TRUE;
      gd_188 = AccountEquity();
   }
   if (gi_316) {
      gd_236 = FindLastBuyPrice();
      gd_244 = FindLastSellPrice();
      if (gi_324) {
         gi_288 = gi_304;
         gd_292 = NormalizeDouble(Lots * MathPow(LotExponent, gi_288), lotdecimal);
         RefreshRates();
         gi_328 = OpenPendingOrder(1, gd_292, Bid, slip, Ask, 0, 0, gs_ilan_272 + "-" + gi_288, g_magic_176, 0, HotPink);
         if (gi_328 < 0) {
            Print("Error: ", GetLastError());
            return (0);
         }
         gd_244 = FindLastSellPrice();
         gi_316 = FALSE;
         gi_332 = TRUE;
      } else {
         if (gi_320) {
            gi_288 = gi_304;
            gd_292 = NormalizeDouble(Lots * MathPow(LotExponent, gi_288), lotdecimal);
            gi_328 = OpenPendingOrder(0, gd_292, Ask, slip, Bid, 0, 0, gs_ilan_272 + "-" + gi_288, g_magic_176, 0, Lime);
            if (gi_328 < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            gd_236 = FindLastBuyPrice();
            gi_316 = FALSE;
            gi_332 = TRUE;
         }
      }
   }
   }
   if(time_15!=iTime(NULL,OpenNewTF,0))
   {
   int totals=OrdersTotal();
   int orders=0;
   for(int total=totals; total>=1; total--)
   {
   OrderSelect(total-1,SELECT_BY_POS,MODE_TRADES);
   if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176) continue;
   if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176) {
     orders++;
   }
   }
          
   if (totals==0 || orders < 1) {
      l_iclose_8 = iClose(Symbol(), 0, 2);
      l_iclose_16 = iClose(Symbol(), 0, 1);
      g_bid_220 = Bid;
      g_ask_228 = Ask;
//      if (!gi_324 && !gi_320) {
         gi_288 = gi_304;
         gd_292 = /*NormalizeDouble(*/Lots/* * MathPow(LotExponent, gi_288), lotdecimal)*/;
         if (l_iclose_8 > l_iclose_16) {
            gi_328 = OpenPendingOrder(1, gd_292, g_bid_220, slip, g_bid_220, 0, 0, gs_ilan_272 + "-" + gi_288, g_magic_176, 0, HotPink);
            if (gi_328 < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            gd_236 = FindLastBuyPrice();
            gi_332 = TRUE;
         } else {
            gi_328 = OpenPendingOrder(0, gd_292, g_ask_228, slip, g_ask_228, 0, 0, gs_ilan_272 + "-" + gi_288, g_magic_176, 0, Lime);
            if (gi_328 < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            gd_244 = FindLastSellPrice();
            gi_332 = TRUE;
         }
         if (gi_328 > 0) gi_284 = TimeCurrent() + 60.0 * (60.0 * MaxTradeOpenHours);
         gi_316 = FALSE;
//      }
   }
   time_15=iTime(NULL,OpenNewTF,0);
   }
   gi_304 = CountTrades();
   g_price_212 = 0;
   double ld_24 = 0;
   for (g_pos_300 = OrdersTotal() - 1; g_pos_300 >= 0; g_pos_300--) {
      OrderSelect(g_pos_300, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            g_price_212 += OrderOpenPrice() * OrderLots();
            ld_24 += OrderLots();
         }
      }
   }
   if (gi_304 > 0) g_price_212 = NormalizeDouble(g_price_212 / ld_24, Digits);
   if (gi_332) {
      for (g_pos_300 = OrdersTotal() - 1; g_pos_300 >= 0; g_pos_300--) {
         OrderSelect(g_pos_300, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176) {
            if (OrderType() == OP_BUY) {
               g_price_180 = g_price_212 + TakeProfit * Point;
               gd_unused_196 = g_price_180;
               gd_308 = g_price_212 - Stoploss * Point;
               gi_268 = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176) {
            if (OrderType() == OP_SELL) {
               g_price_180 = g_price_212 - TakeProfit * Point;
               gd_unused_204 = g_price_180;
               gd_308 = g_price_212 + Stoploss * Point;
               gi_268 = TRUE;
            }
         }
      }
   }
   if (gi_332) {
      if (gi_268 == TRUE) {
         for (g_pos_300 = OrdersTotal() - 1; g_pos_300 >= 0; g_pos_300--) {
            OrderSelect(g_pos_300, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176) OrderModify(OrderTicket(), g_price_212, OrderStopLoss(), g_price_180, 0, Yellow);
            gi_332 = FALSE;
         }
      }
   }
//========================================================================//
//                       ÏÐÎÃÐÀÌÍÛÉ ÊÎÄ Ilan 1.6                          //
//========================================================================//
//   double l_iclose_8;
//   double l_iclose_16;
   if (UseTrailingStop_16) TrailingAlls_16(TrailStart_16, TrailStop_16, g_price_212_16);
   if (UseTimeOut_16) {
      if (TimeCurrent() >= gi_284_16) {
         CloseThisSymbolAll_16();
         Print("Closed All due to TimeOut");
      }
   }
   if (gi_280_16 != Time[0])
   {
   gi_280_16 = Time[0];
   double ld_0_16 = CalculateProfit_16();
   if (UseEquityStop_16) {
      if (ld_0_16 < 0.0 && MathAbs(ld_0_16) > TotalEquityRisk_16 / 100.0 * AccountEquityHigh_16()) {
         CloseThisSymbolAll_16();
         Print("Closed All due to Stop Out");
         gi_332_16 = FALSE;
      }
   }
   gi_304_16 = CountTrades_16();
   if (gi_304_16 == 0) gi_268_16 = FALSE;
   for (g_pos_300_16 = OrdersTotal() - 1; g_pos_300_16 >= 0; g_pos_300_16--) {
      OrderSelect(g_pos_300_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
         if (OrderType() == OP_BUY) {
            gi_320_16 = TRUE;
            gi_324_16 = FALSE;
            break;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
         if (OrderType() == OP_SELL) {
            gi_320_16 = FALSE;
            gi_324_16 = TRUE;
            break;
         }
      }
   }
   if (gi_304_16 > 0 && gi_304_16 <= MaxTrades_16) {
      RefreshRates();
      gd_236_16 = FindLastBuyPrice_16();
      gd_244_16 = FindLastSellPrice_16();
      if (gi_320_16 && gd_236_16 - Ask >= PipStep_16 * Point) gi_316_16 = TRUE;
      if (gi_324_16 && Bid - gd_244_16 >= PipStep_16 * Point) gi_316_16 = TRUE;
   }
   if (gi_304_16 < 1) {
      gi_324_16 = FALSE;
      gi_320_16 = FALSE;
//      gi_316_16 = TRUE;
      gd_188_16 = AccountEquity();
   }
   if (gi_316_16) {
      gd_236_16 = FindLastBuyPrice_16();
      gd_244_16 = FindLastSellPrice_16();
      if (gi_324_16) {
         gi_288_16 = gi_304_16;
         gd_292_16 = NormalizeDouble(Lots_16 * MathPow(LotExponent_16, gi_288_16), lotdecimal_16);
         RefreshRates();
         gi_328_16 = OpenPendingOrder_16(1, gd_292_16, Bid, slip_16, Ask, 0, 0, gs_ilan_272_16 + "-" + gi_288_16, g_magic_176_16, 0, HotPink);
         if (gi_328_16 < 0) {
            Print("Error: ", GetLastError());
            return (0);
         }
         gd_244_16 = FindLastSellPrice_16();
         gi_316_16 = FALSE;
         gi_332_16 = TRUE;
      } else {
         if (gi_320_16) {
            gi_288_16 = gi_304_16;
            gd_292_16 = NormalizeDouble(Lots_16 * MathPow(LotExponent_16, gi_288_16), lotdecimal_16);
            gi_328_16 = OpenPendingOrder_16(0, gd_292_16, Ask, slip_16, Bid, 0, 0, gs_ilan_272_16 + "-" + gi_288_16, g_magic_176_16, 0, Lime);
            if (gi_328_16 < 0) {
               Print("Error: ", GetLastError());
               return (0);
            }
            gd_236_16 = FindLastBuyPrice_16();
            gi_316_16 = FALSE;
            gi_332_16 = TRUE;
         }
      }
   }
   }
   if(time_16!=iTime(NULL,OpenNewTF_16,0))
   {
   int totals_16=OrdersTotal();
   int orders_16=0;
   for(int total_16=totals_16; total_16>=1; total_16--)
   {
   OrderSelect(total_16-1,SELECT_BY_POS,MODE_TRADES);
   if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
   if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
     orders_16++;
   }
   }
   if (totals_16==0 || orders_16 < 1) {
      l_iclose_8/*_16*/ = iClose(Symbol(), 0, 2);
      l_iclose_16/*_16*/ = iClose(Symbol(), 0, 1);
      g_bid_220_16 = Bid;
      g_ask_228_16 = Ask;
//      if (!gi_324_16 && !gi_320_16) {
         gi_288_16 = gi_304_16;
         gd_292_16 =/* NormalizeDouble(*/Lots_16/* * MathPow(LotExponent_16, gi_288_16), lotdecimal_16)*/;
         if (l_iclose_8/*_16*/ > l_iclose_16/*_16*/) {
            if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) > 30.0) {
               gi_328_16 = OpenPendingOrder_16(1, gd_292_16, g_bid_220_16, slip_16, g_bid_220_16, 0, 0, gs_ilan_272_16 + "-" + gi_288_16, g_magic_176_16, 0, HotPink);
               if (gi_328_16 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               gd_236_16 = FindLastBuyPrice_16();
               gi_332_16 = TRUE;
            }
         } else {
            if (iRSI(NULL, PERIOD_H1, 14, PRICE_CLOSE, 1) < 70.0) {
               gi_328_16 = OpenPendingOrder_16(0, gd_292_16, g_ask_228_16, slip_16, g_ask_228_16, 0, 0, gs_ilan_272_16 + "-" + gi_288_16, g_magic_176_16, 0, Lime);
               if (gi_328_16 < 0) {
                  Print("Error: ", GetLastError());
                  return (0);
               }
               gd_244_16 = FindLastSellPrice_16();
               gi_332_16 = TRUE;
            }
         }
         if (gi_328_16 > 0) gi_284_16 = TimeCurrent() + 60.0 * (60.0 * MaxTradeOpenHours_16);
         gi_316_16 = FALSE;
//      }
   }
   time_16=iTime(NULL,OpenNewTF_16,0);
   }
   gi_304_16 = CountTrades_16();
   g_price_212_16 = 0;
   double ld_24_16 = 0;
   for (g_pos_300_16 = OrdersTotal() - 1; g_pos_300_16 >= 0; g_pos_300_16--) {
      OrderSelect(g_pos_300_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) {
            g_price_212_16 += OrderOpenPrice() * OrderLots();
            ld_24_16 += OrderLots();
         }
      }
   }
   if (gi_304_16 > 0) g_price_212_16 = NormalizeDouble(g_price_212_16 / ld_24_16, Digits);
   if (gi_332_16) {
      for (g_pos_300_16 = OrdersTotal() - 1; g_pos_300_16 >= 0; g_pos_300_16--) {
         OrderSelect(g_pos_300_16, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
            if (OrderType() == OP_BUY) {
               g_price_180_16 = g_price_212_16 + TakeProfit_16 * Point;
               gd_unused_196_16 = g_price_180_16;
               gd_308_16 = g_price_212_16 - Stoploss_16 * Point;
               gi_268_16 = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
            if (OrderType() == OP_SELL) {
               g_price_180_16 = g_price_212_16 - TakeProfit_16 * Point;
               gd_unused_204_16 = g_price_180_16;
               gd_308_16 = g_price_212_16 + Stoploss_16 * Point;
               gi_268_16 = TRUE;
            }
         }
      }
   }
   if (gi_332_16) {
      if (gi_268_16 == TRUE) {
         for (g_pos_300_16 = OrdersTotal() - 1; g_pos_300_16 >= 0; g_pos_300_16--) {
            OrderSelect(g_pos_300_16, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) OrderModify(OrderTicket(), g_price_212_16, OrderStopLoss(), g_price_180_16, 0, Yellow);
            gi_332_16 = FALSE;
         }
      }
   }
   return (0);
}
//=============================================================================================================//
//=============================================================================================================//
//=============================================================================================================//
int CountTrades() {
   int l_count_0 = 0;
   for (int l_pos_4 = OrdersTotal() - 1; l_pos_4 >= 0; l_pos_4--) {
      OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) l_count_0++;
   }
   return (l_count_0);
}

void CloseThisSymbolAll() {
   for (int l_pos_0 = OrdersTotal() - 1; l_pos_0 >= 0; l_pos_0--) {
      OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slip, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slip, Red);
         }
         Sleep(1000);
      }
   }
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
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(1000);
      }
      break;
   case 4:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_BUYSTOP, a_lots_4, a_price_12, a_slippage_20, StopLong(ad_24, ai_32), TakeLong(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 0:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         RefreshRates();
         l_ticket_60 = OrderSend(Symbol(), OP_BUY, a_lots_4, Ask, a_slippage_20, StopLong(Bid, ai_32), TakeLong(Ask, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 3:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELLLIMIT, a_lots_4, a_price_12, a_slippage_20, StopShort(ad_24, ai_32), TakeShort(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 5:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELLSTOP, a_lots_4, a_price_12, a_slippage_20, StopShort(ad_24, ai_32), TakeShort(a_price_12, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (l_count_68 = 0; l_count_68 < li_72; l_count_68++) {
         l_ticket_60 = OrderSend(Symbol(), OP_SELL, a_lots_4, Bid, a_slippage_20, StopShort(Ask, ai_32), TakeShort(Bid, ai_36), a_comment_40, a_magic_48, a_datetime_52, a_color_56);
         l_error_64 = GetLastError();
         if (l_error_64 == 0/* NO_ERROR */) break;
         if (!(l_error_64 == 4/* SERVER_BUSY */ || l_error_64 == 137/* BROKER_BUSY */ || l_error_64 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
   }
   return (l_ticket_60);
}

double StopLong(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   else return (ad_0 - ai_8 * Point);
}

double StopShort(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   else return (ad_0 + ai_8 * Point);
}

double TakeLong(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   else return (ad_0 + ai_8 * Point);
}

double TakeShort(double ad_0, int ai_8) {
   if (ai_8 == 0) return (0);
   else return (ad_0 - ai_8 * Point);
}

double CalculateProfit() {
   double ld_ret_0 = 0;
   for (g_pos_300 = OrdersTotal() - 1; g_pos_300 >= 0; g_pos_300--) {
      OrderSelect(g_pos_300, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0 += OrderProfit();
   }
   return (ld_ret_0);
}

void TrailingAlls(int ai_0, int ai_4, double a_price_8) {
   int l_ticket_16;
   double l_ord_stoploss_20;
   double l_price_28;
   if (ai_4 != 0) {
      for (int l_pos_36 = OrdersTotal() - 1; l_pos_36 >= 0; l_pos_36--) {
         if (OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == g_magic_176) {
               if (OrderType() == OP_BUY) {
                  l_ticket_16 = NormalizeDouble((Bid - a_price_8) / Point, 0);
                  if (l_ticket_16 < ai_0) continue;
                  l_ord_stoploss_20 = OrderStopLoss();
                  l_price_28 = Bid - ai_4 * Point;
                  if (l_ord_stoploss_20 == 0.0 || (l_ord_stoploss_20 != 0.0 && l_price_28 > l_ord_stoploss_20)) OrderModify(OrderTicket(), a_price_8, l_price_28, OrderTakeProfit(), 0, Aqua);
               }
               if (OrderType() == OP_SELL) {
                  l_ticket_16 = NormalizeDouble((a_price_8 - Ask) / Point, 0);
                  if (l_ticket_16 < ai_0) continue;
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
   if (CountTrades() == 0) gd_336 = AccountEquity();
   if (gd_336 < gd_344) gd_336 = gd_344;
   else gd_336 = AccountEquity();
   gd_344 = AccountEquity();
   return (gd_336);
}

double FindLastBuyPrice() {
   double l_ord_open_price_8;
   int l_ticket_24;
   double ld_unused_0 = 0;
   int l_ticket_20 = 0;
   for (int l_pos_16 = OrdersTotal() - 1; l_pos_16 >= 0; l_pos_16--) {
      OrderSelect(l_pos_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176 && OrderType() == OP_BUY) {
         l_ticket_24 = OrderTicket();
         if (l_ticket_24 > l_ticket_20) {
            l_ord_open_price_8 = OrderOpenPrice();
            ld_unused_0 = l_ord_open_price_8;
            l_ticket_20 = l_ticket_24;
         }
      }
   }
   return (l_ord_open_price_8);
}

double FindLastSellPrice() {
   double l_ord_open_price_8;
   int l_ticket_24;
   double ld_unused_0 = 0;
   int l_ticket_20 = 0;
   for (int l_pos_16 = OrdersTotal() - 1; l_pos_16 >= 0; l_pos_16--) {
      OrderSelect(l_pos_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176 && OrderType() == OP_SELL) {
         l_ticket_24 = OrderTicket();
         if (l_ticket_24 > l_ticket_20) {
            l_ord_open_price_8 = OrderOpenPrice();
            ld_unused_0 = l_ord_open_price_8;
            l_ticket_20 = l_ticket_24;
         }
      }
   }
   return (l_ord_open_price_8);
}
//=============================================================================================================//
//=============================================================================================================//
//=============================================================================================================//
int CountTrades_16() {
   int l_count_0_16 = 0;
   for (int l_pos_4_16 = OrdersTotal() - 1; l_pos_4_16 >= 0; l_pos_4_16--) {
      OrderSelect(l_pos_4_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16)
         if (OrderType() == OP_SELL || OrderType() == OP_BUY) l_count_0_16++;
   }
   return (l_count_0_16);
}

void CloseThisSymbolAll_16() {
   for (int l_pos_0_16 = OrdersTotal() - 1; l_pos_0_16 >= 0; l_pos_0_16--) {
      OrderSelect(l_pos_0_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol()) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16) {
            if (OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, slip_16, Blue);
            if (OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, slip_16, Red);
         }
         Sleep(1000);
      }
   }
}

int OpenPendingOrder_16(int ai_0_16, double a_lots_4_16, double a_price_12_16, int a_slippage_20_16, double ad_24_16, int ai_32_16, int ai_36_16, string a_comment_40_16, int a_magic_48_16, int a_datetime_52_16, color a_color_56_16) {
   int l_ticket_60_16 = 0;
   int l_error_64_16 = 0;
   int l_count_68_16 = 0;
   int li_72_16 = 100;
   switch (ai_0_16) {
   case 2:
      for (l_count_68_16 = 0; l_count_68_16 < li_72_16; l_count_68_16++) {
         l_ticket_60_16 = OrderSend(Symbol(), OP_BUYLIMIT, a_lots_4_16, a_price_12_16, a_slippage_20_16, StopLong_16(ad_24_16, ai_32_16), TakeLong_16(a_price_12_16, ai_36_16), a_comment_40_16, a_magic_48_16, a_datetime_52_16, a_color_56_16);
         l_error_64_16 = GetLastError();
         if (l_error_64_16 == 0/* NO_ERROR */) break;
         if (!(l_error_64_16 == 4/* SERVER_BUSY */ || l_error_64_16 == 137/* BROKER_BUSY */ || l_error_64_16 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_16 == 136/* OFF_QUOTES */)) break;
         Sleep(1000);
      }
      break;
   case 4:
      for (l_count_68_16 = 0; l_count_68_16 < li_72_16; l_count_68_16++) {
         l_ticket_60_16 = OrderSend(Symbol(), OP_BUYSTOP, a_lots_4_16, a_price_12_16, a_slippage_20_16, StopLong_16(ad_24_16, ai_32_16), TakeLong_16(a_price_12_16, ai_36_16), a_comment_40_16, a_magic_48_16, a_datetime_52_16, a_color_56_16);
         l_error_64_16 = GetLastError();
         if (l_error_64_16 == 0/* NO_ERROR */) break;
         if (!(l_error_64_16 == 4/* SERVER_BUSY */ || l_error_64_16 == 137/* BROKER_BUSY */ || l_error_64_16 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_16 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 0:
      for (l_count_68_16 = 0; l_count_68_16 < li_72_16; l_count_68_16++) {
         RefreshRates();
         l_ticket_60_16 = OrderSend(Symbol(), OP_BUY, a_lots_4_16, Ask, a_slippage_20_16, StopLong_16(Bid, ai_32_16), TakeLong_16(Ask, ai_36_16), a_comment_40_16, a_magic_48_16, a_datetime_52_16, a_color_56_16);
         l_error_64_16 = GetLastError();
         if (l_error_64_16 == 0/* NO_ERROR */) break;
         if (!(l_error_64_16 == 4/* SERVER_BUSY */ || l_error_64_16 == 137/* BROKER_BUSY */ || l_error_64_16 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_16 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 3:
      for (l_count_68_16 = 0; l_count_68_16 < li_72_16; l_count_68_16++) {
         l_ticket_60_16 = OrderSend(Symbol(), OP_SELLLIMIT, a_lots_4_16, a_price_12_16, a_slippage_20_16, StopShort_16(ad_24_16, ai_32_16), TakeShort_16(a_price_12_16, ai_36_16), a_comment_40_16, a_magic_48_16, a_datetime_52_16, a_color_56_16);
         l_error_64_16 = GetLastError();
         if (l_error_64_16 == 0/* NO_ERROR */) break;
         if (!(l_error_64_16 == 4/* SERVER_BUSY */ || l_error_64_16 == 137/* BROKER_BUSY */ || l_error_64_16 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_16 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 5:
      for (l_count_68_16 = 0; l_count_68_16 < li_72_16; l_count_68_16++) {
         l_ticket_60_16 = OrderSend(Symbol(), OP_SELLSTOP, a_lots_4_16, a_price_12_16, a_slippage_20_16, StopShort_16(ad_24_16, ai_32_16), TakeShort_16(a_price_12_16, ai_36_16), a_comment_40_16, a_magic_48_16, a_datetime_52_16, a_color_56_16);
         l_error_64_16 = GetLastError();
         if (l_error_64_16 == 0/* NO_ERROR */) break;
         if (!(l_error_64_16 == 4/* SERVER_BUSY */ || l_error_64_16 == 137/* BROKER_BUSY */ || l_error_64_16 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_16 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
      break;
   case 1:
      for (l_count_68_16 = 0; l_count_68_16 < li_72_16; l_count_68_16++) {
         l_ticket_60_16 = OrderSend(Symbol(), OP_SELL, a_lots_4_16, Bid, a_slippage_20_16, StopShort_16(Ask, ai_32_16), TakeShort_16(Bid, ai_36_16), a_comment_40_16, a_magic_48_16, a_datetime_52_16, a_color_56_16);
         l_error_64_16 = GetLastError();
         if (l_error_64_16 == 0/* NO_ERROR */) break;
         if (!(l_error_64_16 == 4/* SERVER_BUSY */ || l_error_64_16 == 137/* BROKER_BUSY */ || l_error_64_16 == 146/* TRADE_CONTEXT_BUSY */ || l_error_64_16 == 136/* OFF_QUOTES */)) break;
         Sleep(5000);
      }
   }
   return (l_ticket_60_16);
}

double StopLong_16(double ad_0_16, int ai_8_16) {
   if (ai_8_16 == 0) return (0);
   else return (ad_0_16 - ai_8_16 * Point);
}

double StopShort_16(double ad_0_16, int ai_8_16) {
   if (ai_8_16 == 0) return (0);
   else return (ad_0_16 + ai_8_16 * Point);
}

double TakeLong_16(double ad_0_16, int ai_8_16) {
   if (ai_8_16 == 0) return (0);
   else return (ad_0_16 + ai_8_16 * Point);
}

double TakeShort_16(double ad_0_16, int ai_8_16) {
   if (ai_8_16 == 0) return (0);
   else return (ad_0_16 - ai_8_16 * Point);
}

double CalculateProfit_16() {
   double ld_ret_0_16 = 0;
   for (g_pos_300_16 = OrdersTotal() - 1; g_pos_300_16 >= 0; g_pos_300_16--) {
      OrderSelect(g_pos_300_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16)
         if (OrderType() == OP_BUY || OrderType() == OP_SELL) ld_ret_0_16 += OrderProfit();
   }
   return (ld_ret_0_16);
}

void TrailingAlls_16(int ai_0_16, int ai_4_16, double a_price_8_16) {
   int l_ticket_16_16;
   double l_ord_stoploss_20_16;
   double l_price_28_16;
   if (ai_4_16 != 0) {
      for (int l_pos_36 = OrdersTotal() - 1; l_pos_36 >= 0; l_pos_36--) {
         if (OrderSelect(l_pos_36, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
            if (OrderSymbol() == Symbol() || OrderMagicNumber() == g_magic_176_16) {
               if (OrderType() == OP_BUY) {
                  l_ticket_16_16 = NormalizeDouble((Bid - a_price_8_16) / Point, 0);
                  if (l_ticket_16_16 < ai_0_16) continue;
                  l_ord_stoploss_20_16 = OrderStopLoss();
                  l_price_28_16 = Bid - ai_4_16 * Point;
                  if (l_ord_stoploss_20_16 == 0.0 || (l_ord_stoploss_20_16 != 0.0 && l_price_28_16 > l_ord_stoploss_20_16)) OrderModify(OrderTicket(), a_price_8_16, l_price_28_16, OrderTakeProfit(), 0, Aqua);
               }
               if (OrderType() == OP_SELL) {
                  l_ticket_16_16 = NormalizeDouble((a_price_8_16 - Ask) / Point, 0);
                  if (l_ticket_16_16 < ai_0_16) continue;
                  l_ord_stoploss_20_16 = OrderStopLoss();
                  l_price_28_16 = Ask + ai_4_16 * Point;
                  if (l_ord_stoploss_20_16 == 0.0 || (l_ord_stoploss_20_16 != 0.0 && l_price_28_16 < l_ord_stoploss_20_16)) OrderModify(OrderTicket(), a_price_8_16, l_price_28_16, OrderTakeProfit(), 0, Red);
               }
            }
            Sleep(1000);
         }
      }
   }
}

double AccountEquityHigh_16() {
   if (CountTrades_16() == 0) gd_336_16 = AccountEquity();
   if (gd_336_16 < gd_344_16) gd_336_16 = gd_344_16;
   else gd_336_16 = AccountEquity();
   gd_344_16 = AccountEquity();
   return (gd_336_16);
}

double FindLastBuyPrice_16() {
   double l_ord_open_price_8_16;
   int l_ticket_24_16;
   double ld_unused_0_16 = 0;
   int l_ticket_20_16 = 0;
   for (int l_pos_16_16 = OrdersTotal() - 1; l_pos_16_16 >= 0; l_pos_16_16--) {
      OrderSelect(l_pos_16_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16 && OrderType() == OP_BUY) {
         l_ticket_24_16 = OrderTicket();
         if (l_ticket_24_16 > l_ticket_20_16) {
            l_ord_open_price_8_16 = OrderOpenPrice();
            ld_unused_0_16 = l_ord_open_price_8_16;
            l_ticket_20_16 = l_ticket_24_16;
         }
      }
   }
   return (l_ord_open_price_8_16);
}

double FindLastSellPrice_16() {
   double l_ord_open_price_8_16;
   int l_ticket_24_16;
   double ld_unused_0_16 = 0;
   int l_ticket_20_16 = 0;
   for (int l_pos_16_16 = OrdersTotal() - 1; l_pos_16_16 >= 0; l_pos_16_16--) {
      OrderSelect(l_pos_16_16, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() != Symbol() || OrderMagicNumber() != g_magic_176_16) continue;
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_176_16 && OrderType() == OP_SELL) {
         l_ticket_24_16 = OrderTicket();
         if (l_ticket_24_16 > l_ticket_20_16) {
            l_ord_open_price_8_16 = OrderOpenPrice();
            ld_unused_0_16 = l_ord_open_price_8_16;
            l_ticket_20_16 = l_ticket_24_16;
         }
      }
   }
   return (l_ord_open_price_8_16);
}