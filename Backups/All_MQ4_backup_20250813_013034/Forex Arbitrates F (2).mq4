extern int TakeProfit = 0;
bool gi_80 = TRUE;
extern int StopLoss = 0;
bool gi_88 = TRUE;
extern bool UseTrailingStop = TRUE;
extern int TrailingStop = 0;
bool gi_152 = FALSE;
double gd_156 = 0.0;
double gd_164 = 0.0;
int g_ticket_172 = -1;
double g_point_176;
int ere;
extern double Lots = 1.0;
extern bool MM = TRUE;
extern double Risk = 0.05;
extern bool SignalMail = FALSE;
extern bool EachTickMode = TRUE;
extern int Slippage = 3;
extern bool NFA = FALSE;
extern int MagicNumber = 98098;
bool gi_140 = TRUE;
int g_bars_144;
int gi_unused;

int init() {
   double ld_0;
   g_bars_144 = Bars;
   if (EachTickMode) gi_unused= 0;
   else gi_unused= 1;
   int l_digits_8 = MarketInfo("EURUSD", MODE_DIGITS);
   if (l_digits_8 > 4) {
      ld_0 = MathPow(10, l_digits_8 - 4);
      StopLoss = StopLoss * ld_0;
      TakeProfit = TakeProfit * ld_0;
      TrailingStop = TrailingStop * ld_0;
   }
   if (MM) Lots = CalculateMM(Risk);
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   int l_ticket_0;
   double l_price_4;
   double l_price_12;
   if (Point == 0.00001) g_point_176 = 0.0001;
   else {
      if (Point == 0.001) g_point_176 = 0.01;
      else g_point_176 = Point;
   }
   int li_20 = 0;
   if (EachTickMode && Bars != g_bars_144) gi_152 = FALSE;
   int l_ord_total_24 = OrdersTotal();
   li_20 = 0;
   HideTestIndicators(TRUE);
   double l_isar_28 = iSAR(NULL, 0, 0.005, 0.05, 1);
   double l_isar_36 = iSAR(NULL, 0, 0.005, 0.05, 0);
   double l_irsi_44 = iRSI(NULL, 0, 21, PRICE_CLOSE, 0);
   double l_istochastic_52 = iStochastic(NULL, 0, 10, 3, 3, MODE_EMA, 0, MODE_MAIN, 0);
   double l_istochastic_60 = iStochastic(NULL, 0, 10, 3, 3, MODE_EMA, 0, MODE_MAIN, 1);
   double l_imomentum_68 = iMomentum(NULL, 0, 100, PRICE_OPEN, 0);
   double l_iadx_76 = iADX(NULL, 0, 21, PRICE_CLOSE, MODE_MAIN, 0);
   double l_iosma_84 = iOsMA(NULL, 0, 90, 99, 88, PRICE_OPEN, 1);
   HideTestIndicators(FALSE);
   if (g_ticket_172 != -1 && OrderSelect(g_ticket_172, SELECT_BY_TICKET)) {
      if (OrderCloseTime() == 0) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) {
            if (OrderType() == OP_BUY) {
               if (UseTrailingStop && TrailingStop > 0) {
                  if (Bid - OrderOpenPrice() > g_point_176 * TrailingStop) {
                     if (gi_140) {
                        if (gd_156 < Bid - g_point_176 * TrailingStop) {
                           gd_156 = Bid - g_point_176 * TrailingStop;
                           if (!EachTickMode) g_bars_144 = Bars;
                        }
                     } else {
                        if (OrderStopLoss() < Bid - g_point_176 * TrailingStop) {
                           ere=OrderModify(OrderTicket(), OrderOpenPrice(), Bid - g_point_176 * TrailingStop, OrderTakeProfit(), 0, MediumSeaGreen);
                           if (!EachTickMode) g_bars_144 = Bars;
                        }
                     }
                  }
               }
               if (gi_140 && Bid <= gd_156 || Bid >= gd_164) {
                  if (OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, MediumSeaGreen)) {
                     gd_156 = 0;
                     gd_164 = 0;
                     g_ticket_172 = -1;
                  }
                  if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + " Close Buy");
                  if (!EachTickMode) g_bars_144 = Bars;
               }
            } else {
               if (OrderType() == OP_SELL) {
                  if (UseTrailingStop && TrailingStop > 0) {
                     if (OrderOpenPrice() - Ask > g_point_176 * TrailingStop) {
                        if (gi_140) {
                           if (gd_156 > Ask + g_point_176 * TrailingStop || gd_156 == 0.0) {
                              gd_156 = Ask + g_point_176 * TrailingStop;
                              if (!EachTickMode) g_bars_144 = Bars;
                           }
                        } else {
                           if (OrderStopLoss() > Ask + g_point_176 * TrailingStop || OrderStopLoss() == 0.0) {
                              ere=OrderModify(OrderTicket(), OrderOpenPrice(), Ask + g_point_176 * TrailingStop, OrderTakeProfit(), 0, DarkOrange);
                              if (!EachTickMode) g_bars_144 = Bars;
                           }
                        }
                     }
                  }
                  if (gi_140 && Bid >= gd_156 || Bid <= gd_164) {
                     if (OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, DarkOrange)) {
                        gd_156 = 0;
                        gd_164 = 0;
                        g_ticket_172 = -1;
                     }
                     if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + " Close Sell");
                     if (!EachTickMode) g_bars_144 = Bars;
                  }
               }
            }
         }
      }
   }
   bool li_92 = FALSE;
   if (g_ticket_172 != -1) {
      if (OrderSelect(g_ticket_172, SELECT_BY_TICKET)) {
         if (OrderCloseTime() == 0) li_92 = TRUE;
         else {
            g_ticket_172 = -1;
            gd_156 = 0;
            gd_164 = 0;
         }
      }
   }
   if (l_isar_36 <= Ask && l_isar_28 > l_isar_36 && l_istochastic_60 < l_istochastic_52 && l_istochastic_52 < 0.8 && l_iosma_84 > 0.0 && l_imomentum_68 > 100.0 && l_iadx_76 > 21.0) li_20 = 1;
   if (l_isar_36 >= Ask && l_isar_28 < l_isar_36 && l_istochastic_60 > l_istochastic_52 && l_istochastic_52 > 0.2 && l_iosma_84 < 0.0 && l_imomentum_68 < 100.0 && l_iadx_76 < 21.0) li_20 = 2;
   if (li_20 == 1 && (EachTickMode && !gi_152) || (!EachTickMode && Bars != g_bars_144)) {
      if (!li_92) {
         if (AccountFreeMargin() < 1000.0 * Lots) {
            Print("Free Margin = ", AccountFreeMargin());
            return (0);
         }
         if (gi_80) l_price_4 = Ask - StopLoss * g_point_176;
         else l_price_4 = 0.0;
         if (gi_88) l_price_12 = Ask + TakeProfit * g_point_176;
         else l_price_12 = 0.0;
         gd_156 = l_price_4;
         gd_164 = l_price_12;
         if (gi_140) l_ticket_0 = OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, 0, 0, "Buy(#" + MagicNumber + ")", MagicNumber, 0, White);
         else l_ticket_0 = OrderSend(Symbol(), OP_BUY, Lots, Ask, Slippage, l_price_4, l_price_12, "Buy(#" + MagicNumber + ")", MagicNumber, 0, White);
         if (l_ticket_0 > 0) {
            if (OrderSelect(l_ticket_0, SELECT_BY_TICKET, MODE_TRADES)) {
               Print("BUY order opened : ", OrderOpenPrice());
               if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Ask, Digits) + " Open Buy");
               g_ticket_172 = l_ticket_0;
            } else Print("Error opening BUY order : ", GetLastError());
         }
         if (EachTickMode) gi_152 = TRUE;
         if (!EachTickMode) g_bars_144 = Bars;
         return (0);
      }
   }
   if (li_20 == 2 && (EachTickMode && !gi_152) || (!EachTickMode && Bars != g_bars_144)) {
      if (!li_92) {
         if (AccountFreeMargin() < 1000.0 * Lots) {
            Print("Free Margin = ", AccountFreeMargin());
            return (0);
         }
         if (gi_80) l_price_4 = Bid + StopLoss * g_point_176;
         else l_price_4 = 0.0;
         if (gi_88) l_price_12 = Bid - TakeProfit * g_point_176;
         else l_price_12 = 0.0;
         gd_156 = l_price_4;
         gd_164 = l_price_12;
         if (gi_140) l_ticket_0 = OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, 0, 0, "Sell(#" + MagicNumber + ")", MagicNumber, 0, DeepPink);
         else l_ticket_0 = OrderSend(Symbol(), OP_SELL, Lots, Bid, Slippage, l_price_4, l_price_12, "Sell(#" + MagicNumber + ")", MagicNumber, 0, DeepPink);
         if (l_ticket_0 > 0) {
            if (OrderSelect(l_ticket_0, SELECT_BY_TICKET, MODE_TRADES)) {
               Print("SELL order opened : ", OrderOpenPrice());
               if (SignalMail) SendMail("[Signal Alert]", "[" + Symbol() + "] " + DoubleToStr(Bid, Digits) + " Open Sell");
               g_ticket_172 = l_ticket_0;
            } else Print("Error opening SELL order : ", GetLastError());
         }
         if (EachTickMode) gi_152 = TRUE;
         if (!EachTickMode) g_bars_144 = Bars;
         return (0);
      }
   }
   if (!EachTickMode) g_bars_144 = Bars;
   return (0);
}

double CalculateMM(double ad_0) {
   double l_minlot_8 = MarketInfo(Symbol(), MODE_MINLOT);
   double l_maxlot_16 = MarketInfo(Symbol(), MODE_MAXLOT);
   double ld_ret_24 = AccountFreeMargin() / MarketInfo(Symbol(), MODE_MARGINREQUIRED) * ad_0;
   ld_ret_24 = MathMin(l_maxlot_16, MathMax(l_minlot_8, ld_ret_24));
   if (l_minlot_8 < 0.1) ld_ret_24 = NormalizeDouble(ld_ret_24, 2);
   else {
      if (l_minlot_8 < 1.0) ld_ret_24 = NormalizeDouble(ld_ret_24, 1);
      else ld_ret_24 = NormalizeDouble(ld_ret_24, 0);
   }
   if (ld_ret_24 < l_minlot_8) ld_ret_24 = l_minlot_8;
   if (ld_ret_24 > l_maxlot_16) ld_ret_24 = l_maxlot_16;
   return (ld_ret_24);
}
