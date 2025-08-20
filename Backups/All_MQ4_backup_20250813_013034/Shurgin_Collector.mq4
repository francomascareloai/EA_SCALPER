#property copyright "Copyright © 2012, Fx-robot.ru"
#property link      "fx-robot.ru"

extern int MagicNumber = 1;
extern string Pair_1 = "EURUSD";
extern string Pair_2 = "GBPUSD";
extern double Lots_1 = 0.01;
extern double Lots_2 = 0.01;
extern double KoeffLots = 2.0;
extern double LossInValute = 3.0;
extern double ProfitInValute = 3.0;
extern double SumProfitInValute = 2.0;
extern int Slippage = 3;
extern string OrdersComment = "Shurgin_Collector";
int gi_160;
int g_magic_164;
int g_ticket_168;
int g_count_172;
int gi_176;
int gi_180;
int gi_184;
double g_lots_188;
double g_maxlot_212;
double g_minlot_220;
double g_lotstep_228;
double g_maxlot_236;
double g_minlot_244;
double g_lotstep_252;
double gda_260[500];
double gda_264[500];
double gd_268;
double gd_276;
string g_comment_284;
string g_comment_292;
string g_text_300;
bool gba_308[500];
bool gba_312[500];
bool gba_316[500];
bool gba_320[500];

int init() {
   if ((!IsExpertEnabled()) && !IsTesting()) Comment("Running experts in the terminal is prohibited! Click the \"EA\" on the toolbar.");
   ObjectCreate("Copyright", OBJ_LABEL, 0, 0, 1.0);
   ObjectSet("Copyright", OBJPROP_CORNER, 2);
   ObjectSet("Copyright", OBJPROP_XDISTANCE, 3);
   ObjectSet("Copyright", OBJPROP_YDISTANCE, 1);
   g_text_300 = "Shurgin Aleksandr " + CharToStr(174) + " FX-ROBOT.RU";
   ObjectSetText("Copyright", g_text_300, 12, "Times New Roman", Tomato);
   ObjectSet("Copyright", OBJPROP_TIMEFRAMES, NULL);
   ObjectSet("Copyright", OBJPROP_BACK, FALSE);
   gi_160 = 1000 * MagicNumber;
   g_maxlot_212 = MarketInfo(Pair_1, MODE_MAXLOT);
   g_minlot_220 = MarketInfo(Pair_1, MODE_MINLOT);
   g_lotstep_228 = MarketInfo(Pair_1, MODE_LOTSTEP);
   if (g_lotstep_228 <= 0.009) gi_176 = 3;
   else {
      if (g_lotstep_228 <= 0.09) gi_176 = 2;
      else {
         if (g_lotstep_228 <= 0.9) gi_176 = 1;
         else gi_176 = 0;
      }
   }
   g_maxlot_236 = MarketInfo(Pair_2, MODE_MAXLOT);
   g_minlot_244 = MarketInfo(Pair_2, MODE_MINLOT);
   g_lotstep_252 = MarketInfo(Pair_2, MODE_LOTSTEP);
   if (g_lotstep_252 <= 0.009) gi_180 = 3;
   else {
      if (g_lotstep_252 <= 0.09) gi_180 = 2;
      else {
         if (g_lotstep_252 <= 0.9) gi_180 = 1;
         else gi_180 = 0;
      }
   }
   g_comment_284 = OrdersComment + " _1";
   g_comment_292 = OrdersComment + " _2";
   gi_184 = 3.0 * (7.0 * (4.0 * (3.0 * AccountNumber() + 134.0) + 11.0));
   return (0);
}

int start() {
   int li_4;
   int li_8;
   if (!IsTesting()) {
      if (!IsExpertEnabled()) {
         Comment("The trading terminal of experts do not run.");
         return (0);
      }
      if (!IsTradeAllowed()) {
         Comment("Trade is disabled or trade flow is busy.");
         return (0);
      }
      Comment("");
   }
   if ((!IsTesting()) && !IsOptimization() && (!IsDemo())) {
      if (gi_184 != gi_184) {
         Comment("To trade a live account I need the license key.");
         return (0);
      }
   }
   for (int pos_0 = 0; pos_0 < 500; pos_0++) {
      gda_260[pos_0] = 0;
      gda_264[pos_0] = 0;
      gba_308[pos_0] = 0;
      gba_312[pos_0] = 0;
      gba_316[pos_0] = 0;
      gba_320[pos_0] = 0;
   }
   gd_268 = 0;
   gd_276 = 0;
   int li_12 = -1;
   int li_16 = -1;
   for (pos_0 = OrdersTotal() - 1; pos_0 >= 0; pos_0--) {
      if (OrderSelect(pos_0, SELECT_BY_POS)) {
         if ((OrderSymbol() != Pair_1 && OrderSymbol() != Pair_2) || OrderMagicNumber() < gi_160 || OrderMagicNumber() >= gi_160 + 1000) continue;
         if (OrderMagicNumber() < gi_160 + 500) {
            li_4 = OrderMagicNumber() - gi_160;
            li_8 = 1;
            if (li_12 < li_4) li_12 = li_4;
            gd_268 += OrderProfit() + OrderSwap() + OrderCommission();
            gda_260[li_4] += (OrderProfit() + OrderSwap() + OrderCommission());
         } else {
            li_4 = OrderMagicNumber() - gi_160 - 500;
            li_8 = 2;
            if (li_16 < li_4) li_16 = li_4;
            gd_276 += OrderProfit() + OrderSwap() + OrderCommission();
            gda_264[li_4] += (OrderProfit() + OrderSwap() + OrderCommission());
         }
         if (OrderType() == OP_SELL) {
            if (li_8 == 1) {
               gba_312[li_4] = 1;
               continue;
            }
            gba_320[li_4] = 1;
            continue;
         }
         if (OrderType() == OP_BUY) {
            if (li_8 == 1) {
               gba_308[li_4] = 1;
               continue;
            }
            gba_316[li_4] = 1;
         }
      }
   }
   if (li_12 >= 2 && gd_268 >= SumProfitInValute) {
      Print("*** Closure of all first orders at (SumProfitInValute) of profit ", gd_268);
      CloseAll(1, -1);
      return (0);
   }
   if (li_16 >= 2 && gd_276 >= SumProfitInValute) {
      Print("*** Closure of second order in (SumProfitInValute) of profit ", gd_276);
      CloseAll(2, -1);
      return (0);
   }
   if (gda_260[li_12] >= ProfitInValute) {
      Print("*** Closure ", li_12 + 1," a pair of first order in (ProfitInValute) of profit ", gda_260[li_12]);
      CloseAll(1, li_12);
      return (0);
   }
   if (gda_264[li_16] >= ProfitInValute) {
      Print("*** Closure ", li_16 + 1," a pair of second order (ProfitInValute) of profit ", gda_264[li_16]);
      CloseAll(2, li_16);
      return (0);
   }
   RefreshRates();
   if (li_12 < 0) {
      Print("*** Opening of the first order of the first pair");
      g_lots_188 = NRL1(Lots_1);
      g_magic_164 = gi_160;
   } else {
      if (li_12 >= 0 && (!gba_308[li_12]) && gba_312[li_12]) {
         Print("*** Opening of the first order of the first pair");
         g_lots_188 = NRL1(Lots_1 * MathPow(KoeffLots, li_12));
         g_magic_164 = gi_160 + li_12;
      } else {
         if (li_12 >= 0 && gba_308[li_12] && gba_312[li_12] && gda_260[li_12] <= (-LossInValute) * MathPow(KoeffLots, li_12)) {
            Print("*** Opening ", li_12 + 1," orders the first couple of orders. The loss of the previous level ", gda_260[li_12]);
            g_lots_188 = NRL1(Lots_1 * MathPow(KoeffLots, li_12 + 1));
            g_magic_164 = gi_160 + li_12 + 1;
         } else g_lots_188 = 0;
      }
   }
   if (g_lots_188 > 0.0) {
      g_ticket_168 = OrderSend(Pair_1, OP_BUY, g_lots_188, MarketInfo(Pair_1, MODE_ASK), Slippage, 0, 0, g_comment_284, g_magic_164, 0, Blue);
      if (g_ticket_168 > 0) {
         g_count_172 = 0;
         while (g_count_172 < 90 && !OrderSelect(g_ticket_168, SELECT_BY_TICKET)) {
            g_count_172++;
            Sleep(2000);
         }
      }
   }
   if (li_12 < 0) {
      Print("*** Opening of the first order of the first pair");
      g_lots_188 = NRL2(Lots_2);
      g_magic_164 = gi_160;
   } else {
      if (li_12 >= 0 && (!gba_312[li_12]) && gba_308[li_12]) {
         Print("*** Opening of the first order of the first pair");
         g_lots_188 = NRL2(Lots_2 * MathPow(KoeffLots, li_12));
         g_magic_164 = gi_160 + li_12;
      } else {
         if (li_12 >= 0 && gba_308[li_12] && gba_312[li_12] && gda_260[li_12] <= (-LossInValute) * MathPow(KoeffLots, li_12)) {
            Print("*** Opening ", li_12 + 1," orders the first couple of orders. The loss of the previous level ", gda_260[li_12]);
            g_lots_188 = NRL2(Lots_2 * MathPow(KoeffLots, li_12 + 1));
            g_magic_164 = gi_160 + li_12 + 1;
         } else g_lots_188 = 0;
      }
   }
   if (g_lots_188 > 0.0) {
      g_ticket_168 = OrderSend(Pair_2, OP_SELL, g_lots_188, MarketInfo(Pair_2, MODE_BID), Slippage, 0, 0, g_comment_284, g_magic_164, 0, Red);
      if (g_ticket_168 > 0) {
         g_count_172 = 0;
         while (g_count_172 < 90 && !OrderSelect(g_ticket_168, SELECT_BY_TICKET)) {
            g_count_172++;
            Sleep(2000);
         }
      }
   }
   if (li_16 < 0) {
      Print("*** Opening of the first order of the second pair");
      g_lots_188 = NRL1(Lots_1);
      g_magic_164 = gi_160 + 500;
   } else {
      if (li_16 >= 0 && (!gba_316[li_16]) && gba_320[li_16]) {
         Print("*** Opening of the first order of the second pair");
         g_lots_188 = NRL1(Lots_1 * MathPow(KoeffLots, li_16));
         g_magic_164 = gi_160 + li_16 + 500;
      } else {
         if (li_16 >= 0 && gba_316[li_16] && gba_320[li_16] && gda_264[li_16] <= (-LossInValute) * MathPow(KoeffLots, li_16)) {
            Print("*** Opening ", li_16 + 1," the order of the second pair of orders. The loss of the previous level ", gda_264[li_16]);
            g_lots_188 = NRL1(Lots_1 * MathPow(KoeffLots, li_16 + 1));
            g_magic_164 = gi_160 + li_16 + 501;
         } else g_lots_188 = 0;
      }
   }
   if (g_lots_188 > 0.0) {
      g_ticket_168 = OrderSend(Pair_2, OP_BUY, g_lots_188, MarketInfo(Pair_2, MODE_ASK), Slippage, 0, 0, g_comment_292, g_magic_164, 0, Blue);
      if (g_ticket_168 > 0) {
         g_count_172 = 0;
         while (g_count_172 < 90 && !OrderSelect(g_ticket_168, SELECT_BY_TICKET)) {
            g_count_172++;
            Sleep(2000);
         }
      }
   }
   if (li_16 < 0) {
      Print("*** Opening of the first order of the second pair");
      g_lots_188 = NRL2(Lots_2);
      g_magic_164 = gi_160 + 500;
   } else {
      if (li_16 >= 0 && (!gba_320[li_16]) && gba_316[li_16]) {
         Print("*** Opening of the first order of the second pair");
         g_lots_188 = NRL2(Lots_2 * MathPow(KoeffLots, li_16));
         g_magic_164 = gi_160 + li_16 + 500;
      } else {
         if (li_16 >= 0 && gba_316[li_16] && gba_320[li_16] && gda_264[li_16] <= (-LossInValute) * MathPow(KoeffLots, li_16)) {
            Print("*** Opening ", li_16 + 1," the order of the second pair of orders. The loss of the previous level ", gda_264[li_16]);
            g_lots_188 = NRL2(Lots_2 * MathPow(KoeffLots, li_16 + 1));
            g_magic_164 = gi_160 + li_16 + 501;
         } else g_lots_188 = 0;
      }
   }
   if (g_lots_188 > 0.0) {
      g_ticket_168 = OrderSend(Pair_1, OP_SELL, g_lots_188, MarketInfo(Pair_1, MODE_BID), Slippage, 0, 0, g_comment_292, g_magic_164, 0, Red);
      if (g_ticket_168 > 0) {
         g_count_172 = 0;
         while (g_count_172 < 90 && !OrderSelect(g_ticket_168, SELECT_BY_TICKET)) {
            g_count_172++;
            Sleep(2000);
         }
      }
   }
   return (0);
}

double NRL1(double ad_0) {
   if (ad_0 < g_minlot_220) return (g_minlot_220);
   if (ad_0 > g_maxlot_212) return (g_maxlot_212);
   return (NormalizeDouble(ad_0, gi_176));
}

double NRL2(double ad_0) {
   if (ad_0 < g_minlot_244) return (g_minlot_244);
   if (ad_0 > g_maxlot_236) return (g_maxlot_236);
   return (NormalizeDouble(ad_0, gi_180));
}

int deinit() {
   ObjectDelete("Copyright");
   Comment("");
   return (0);
}

void CloseAll(int ai_0, int ai_4) {
   bool li_12 = TRUE;
   if (ai_0 == 1) {
      while (li_12) {
         li_12 = FALSE;
         for (int pos_8 = OrdersTotal() - 1; pos_8 >= 0; pos_8--) {
            if (OrderSelect(pos_8, SELECT_BY_POS)) {
               if (ai_4 >= 0 && OrderMagicNumber() != gi_160 + ai_4) continue;
               if (ai_4 < 0 && OrderMagicNumber() < gi_160 || OrderMagicNumber() >= gi_160 + 500) continue;
               RefreshRates();
               if (OrderType() == OP_SELL && OrderSymbol() == Pair_2) {
                  li_12 = TRUE;
                  OrderClose(OrderTicket(), OrderLots(), MarketInfo(Pair_2, MODE_ASK), Slippage);
                  continue;
               }
               if (OrderType() == OP_BUY && OrderSymbol() == Pair_1) {
                  li_12 = TRUE;
                  OrderClose(OrderTicket(), OrderLots(), MarketInfo(Pair_1, MODE_BID), Slippage);
               }
            }
         }
         if (li_12) Sleep(2000);
      }
   } else {
      while (li_12) {
         li_12 = FALSE;
         for (pos_8 = OrdersTotal() - 1; pos_8 >= 0; pos_8--) {
            if (OrderSelect(pos_8, SELECT_BY_POS)) {
               if (ai_4 >= 0 && OrderMagicNumber() != gi_160 + ai_4 + 500) continue;
               if (ai_4 < 0 && OrderMagicNumber() < gi_160 + 500 || OrderMagicNumber() >= gi_160 + 1000) continue;
               RefreshRates();
               if (OrderType() == OP_SELL && OrderSymbol() == Pair_1) {
                  li_12 = TRUE;
                  OrderClose(OrderTicket(), OrderLots(), MarketInfo(Pair_1, MODE_ASK), Slippage);
                  continue;
               }
               if (OrderType() == OP_BUY && OrderSymbol() == Pair_2) {
                  li_12 = TRUE;
                  OrderClose(OrderTicket(), OrderLots(), MarketInfo(Pair_2, MODE_BID), Slippage);
               }
            }
         }
         if (li_12) Sleep(2000);
      }
   }
}