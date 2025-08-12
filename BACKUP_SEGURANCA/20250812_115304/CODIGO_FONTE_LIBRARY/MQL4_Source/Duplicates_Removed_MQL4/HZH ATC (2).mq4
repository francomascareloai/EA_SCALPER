//+------------------------------------------------------------------+
//|                                            HZH-欧美1小时_ATC.mq4 |
//|                                      中国自动化交易联盟-红之汇著 |
//|                                                     QQ:712933993 |
//+------------------------------------------------------------------+
#property copyright "中国自动化交易联盟-红之汇著"
#property link      "QQ:712933993"

extern int Magic = 1175460;
int gi_80 = 160;
int gi_84 = 0;
int gi_88 = 1;
double gd_92 = 1.0;
int gi_100 = 2;
int g_datetime_104 = 10;
double g_pips_108 = 10.0;
double g_pips_116 = 21.0;
double g_pips_124 = 21.0;
extern double Lots = 1.0;
extern double MaximumRisk = 0.08;
extern double DecreaseFactor = 3.0;
int gi_156 = 150;
int g_ticket_160;
int g_ticket_164;
int g_ticket_168;
int g_ticket_172;
int g_ticket_176;
int g_ticket_180;
double gd_184 = 0.0;

double LotsOptimized() {
   double l_lots_0 = Lots;
   int l_hist_total_8 = OrdersHistoryTotal();
   int l_count_12 = 0;
   l_lots_0 = NormalizeDouble(AccountFreeMargin() * MaximumRisk / 1000.0, 1);
   if (DecreaseFactor > 0.0) {
      for (int l_pos_16 = l_hist_total_8 - 1; l_pos_16 >= 0; l_pos_16--) {
         if (OrderSelect(l_pos_16, SELECT_BY_POS, MODE_HISTORY) == FALSE) {
            Print("Error in history!");
            break;
         }
         if (OrderSymbol() != Symbol() || OrderType() > OP_SELL) continue;
         if (OrderProfit() > 0.0) break;
         if (OrderProfit() < 0.0) l_count_12++;
      }
      if (l_count_12 > 1) l_lots_0 = NormalizeDouble(l_lots_0 - l_lots_0 * l_count_12 / DecreaseFactor, 1);
   }
   if (l_lots_0 < 0.1) l_lots_0 = 0.1;
   return (l_lots_0);
}

int init()//初始化变量
{
   ObjectCreate("comment_label", OBJ_LABEL, 0, 0, 0);
   ObjectSet("comment_label", OBJPROP_XDISTANCE, 50);
   ObjectSet("comment_label", OBJPROP_YDISTANCE, 20);
   ObjectSetText("comment_label","紅之匯【垃圾圣杯】ATC", 20, "Arial", Blue);
   return (0);
}

int deinit() {
   ObjectDelete("comment_label");
   return (0);
}
int start() {
   double l_price_0;
   double l_price_8;
   double l_price_16;
   double l_price_24;
   double l_price_32;
   double l_price_40;
   int l_ticket_48;
   double l_price_52;
   double l_price_60;
   int l_period_68 = 0;
   l_period_68 = gi_80;
   int l_timeframe_72 = 0;
   l_timeframe_72 = gi_84;
   int l_ma_method_76 = 0;
   l_ma_method_76 = gi_88;
   double l_deviation_80 = 0;
   l_deviation_80 = gd_92;
   double l_ienvelopes_88 = 0;
   double l_ienvelopes_96 = 0;
   double l_ima_104 = 0;
   int l_digits_112 = MarketInfo(Symbol(), MODE_DIGITS);
   l_ima_104 = iMA(NULL, l_timeframe_72, l_period_68, 0, l_ma_method_76, PRICE_CLOSE, 0);
   l_ienvelopes_88 = iEnvelopes(NULL, l_timeframe_72, l_period_68, l_ma_method_76, 0, PRICE_CLOSE, l_deviation_80, MODE_UPPER, 0);
   l_ienvelopes_96 = iEnvelopes(NULL, l_timeframe_72, l_period_68, l_ma_method_76, 0, PRICE_CLOSE, l_deviation_80, MODE_LOWER, 0);
   Comment("HZH EA\nFor EUR/USD time frame H1 only");
   int l_day_of_year_116 = DayOfYear();
   int l_year_120 = Year();
   if ((l_year_120 == 2030 && l_day_of_year_116 >= 365) || l_year_120 > 2030) {
      Comment("Trade is stopped ! Update your adviser please.\nUse of this version can be dangerous to your deposit !");
      return (0);
   }
   int l_ord_total_124 = OrdersTotal();
   if (OrdersTotal() == 0) {
      g_ticket_160 = 0;
      g_ticket_164 = 0;
      g_ticket_168 = 0;
      g_ticket_172 = 0;
      g_ticket_176 = 0;
      g_ticket_180 = 0;
   }
   if (OrdersTotal() > 0) {
      for (int l_pos_128 = 0; l_pos_128 < l_ord_total_124; l_pos_128++) {
         OrderSelect(l_pos_128, SELECT_BY_POS, MODE_TRADES);
         if (OrderMagicNumber() == Magic + 2) g_ticket_160 = OrderTicket();
         if (OrderMagicNumber() == Magic + 4) g_ticket_164 = OrderTicket();
         if (OrderMagicNumber() == Magic + 6) g_ticket_168 = OrderTicket();
         if (OrderMagicNumber() == Magic + 1) g_ticket_172 = OrderTicket();
         if (OrderMagicNumber() == Magic + 3) g_ticket_176 = OrderTicket();
         if (OrderMagicNumber() == Magic + 5) g_ticket_180 = OrderTicket();
      }
   }
   if (g_ticket_160 == 0) {
      if (Hour() > gi_100 && Hour() < g_datetime_104) {
         if (l_ienvelopes_88 > Close[0] && l_ienvelopes_96 < Close[0]) {
            l_price_0 = NormalizeDouble(l_ienvelopes_88, l_digits_112) + g_pips_108 * Point;
            l_ticket_48 = OrderSend(Symbol(), OP_BUYSTOP, LotsOptimized(), NormalizeDouble(l_ienvelopes_88, l_digits_112), 0, NormalizeDouble(l_ienvelopes_96, l_digits_112), l_price_0, "", Magic +
               2, g_datetime_104, Aqua);
            if (l_ticket_48 > 0) {
               if (OrderSelect(l_ticket_48, SELECT_BY_TICKET, MODE_TRADES)) {
                  g_ticket_160 = l_ticket_48;
                  Print(l_ticket_48);
               } else Print("Error Opening BuyStop Order: ", GetLastError());
               return (0);
            }
         }
      }
   }
   if (g_ticket_164 == 0) {
      if (Hour() > gi_100 && Hour() < g_datetime_104) {
         if (l_ienvelopes_88 > Close[0] && l_ienvelopes_96 < Close[0]) {
            l_price_8 = NormalizeDouble(l_ienvelopes_88, l_digits_112) + g_pips_116 * Point;
            l_ticket_48 = OrderSend(Symbol(), OP_BUYSTOP, LotsOptimized(), NormalizeDouble(l_ienvelopes_88, l_digits_112), 0, NormalizeDouble(l_ienvelopes_96, l_digits_112), l_price_8, "", Magic +
               4, g_datetime_104, Aqua);
            if (l_ticket_48 > 0) {
               if (OrderSelect(l_ticket_48, SELECT_BY_TICKET, MODE_TRADES)) {
                  g_ticket_164 = l_ticket_48;
                  Print(l_ticket_48);
               } else Print("Error Opening BuyStop Order: ", GetLastError());
               return (0);
            }
         }
      }
   }
   if (g_ticket_168 == 0) {
      if (Hour() > gi_100 && Hour() < g_datetime_104) {
         if (l_ienvelopes_88 > Close[0] && l_ienvelopes_96 < Close[0]) {
            l_price_16 = NormalizeDouble(l_ienvelopes_88, l_digits_112) + g_pips_124 * Point;
            l_ticket_48 = OrderSend(Symbol(), OP_BUYSTOP, LotsOptimized(), NormalizeDouble(l_ienvelopes_88, l_digits_112), 0, NormalizeDouble(l_ienvelopes_96, l_digits_112), l_price_16, "", Magic +
               6, g_datetime_104, Aqua);
            if (l_ticket_48 > 0) {
               if (OrderSelect(l_ticket_48, SELECT_BY_TICKET, MODE_TRADES)) {
                  g_ticket_168 = l_ticket_48;
                  Print(l_ticket_48);
               } else Print("Error Opening BuyStop Order: ", GetLastError());
               return (0);
            }
         }
      }
   }
   if (g_ticket_172 == 0) {
      if (Hour() > gi_100 && Hour() < g_datetime_104) {
         if (l_ienvelopes_88 > Close[0] && l_ienvelopes_96 < Close[0]) {
            l_price_24 = NormalizeDouble(l_ienvelopes_96, l_digits_112) - g_pips_108 * Point;
            l_ticket_48 = OrderSend(Symbol(), OP_SELLSTOP, LotsOptimized(), NormalizeDouble(l_ienvelopes_96, l_digits_112), 0, NormalizeDouble(l_ienvelopes_88, l_digits_112), l_price_24, "", Magic +
               1, g_datetime_104, HotPink);
            if (l_ticket_48 > 0) {
               if (OrderSelect(l_ticket_48, SELECT_BY_TICKET, MODE_TRADES)) {
                  g_ticket_172 = l_ticket_48;
                  Print(l_ticket_48);
               } else Print("Error Opening SellStop Order: ", GetLastError());
               return (0);
            }
         }
      }
   }
   if (g_ticket_176 == 0) {
      if (Hour() > gi_100 && Hour() < g_datetime_104) {
         if (l_ienvelopes_88 > Close[0] && l_ienvelopes_96 < Close[0]) {
            l_price_32 = NormalizeDouble(l_ienvelopes_96, l_digits_112) - g_pips_116 * Point;
            l_ticket_48 = OrderSend(Symbol(), OP_SELLSTOP, LotsOptimized(), NormalizeDouble(l_ienvelopes_96, l_digits_112), 0, NormalizeDouble(l_ienvelopes_88, l_digits_112), l_price_32, "", Magic +
               3, g_datetime_104, HotPink);
            if (l_ticket_48 > 0) {
               if (OrderSelect(l_ticket_48, SELECT_BY_TICKET, MODE_TRADES)) {
                  g_ticket_176 = l_ticket_48;
                  Print(l_ticket_48);
               } else Print("Error Opening SellStop Order: ", GetLastError());
               return (0);
            }
         }
      }
   }
   if (g_ticket_180 == 0) {
      if (Hour() > gi_100 && Hour() < g_datetime_104) {
         if (l_ienvelopes_88 > Close[0] && l_ienvelopes_96 < Close[0]) {
            l_price_40 = NormalizeDouble(l_ienvelopes_96, l_digits_112) - g_pips_124 * Point;
            l_ticket_48 = OrderSend(Symbol(), OP_SELLSTOP, LotsOptimized(), NormalizeDouble(l_ienvelopes_96, l_digits_112), 0, NormalizeDouble(l_ienvelopes_88, l_digits_112), l_price_40, "", Magic +
               5, g_datetime_104, HotPink);
            if (l_ticket_48 > 0) {
               if (OrderSelect(l_ticket_48, SELECT_BY_TICKET, MODE_TRADES)) {
                  g_ticket_180 = l_ticket_48;
                  Print(l_ticket_48);
               } else Print("Error Opening SellStop Order: ", GetLastError());
               return (0);
            }
         }
      }
   }
   for (l_pos_128 = 0; l_pos_128 < l_ord_total_124; l_pos_128++) {
      OrderSelect(l_pos_128, SELECT_BY_POS, MODE_TRADES);
      if (OrderType() == OP_BUY) {
         if (gi_156 == 0) gd_184 = NormalizeDouble(l_ima_104, l_digits_112);
         if (gi_156 == 1) gd_184 = NormalizeDouble(l_ienvelopes_96, l_digits_112);
         if (Close[0] > OrderOpenPrice()) {
            if (Close[0] > l_ienvelopes_96 && gd_184 > OrderStopLoss()) {
               l_price_52 = gd_184;
               OrderModify(OrderTicket(), OrderOpenPrice(), l_price_52, OrderTakeProfit(), 0, Green);
               Sleep(10000);
            }
         }
      }
      OrderSelect(l_pos_128, SELECT_BY_POS, MODE_TRADES);
      if (OrderType() == OP_SELL) {
         if (gi_156 == 0) gd_184 = NormalizeDouble(l_ima_104, l_digits_112);
         if (gi_156 == 1) gd_184 = NormalizeDouble(l_ienvelopes_88, l_digits_112);
         if (Close[0] < OrderOpenPrice()) {
            if (Close[0] < l_ienvelopes_88 && gd_184 < OrderStopLoss()) {
               l_price_60 = gd_184;
               OrderModify(OrderTicket(), OrderOpenPrice(), l_price_60, OrderTakeProfit(), 0, Red);
               Sleep(10000);
            }
         }
      }
      OrderSelect(l_pos_128, SELECT_BY_POS, MODE_TRADES);
      if (Hour() == g_datetime_104 && OrderType() == OP_BUYSTOP) {
         OrderDelete(OrderTicket());
         if (OrderTicket() == g_ticket_160) {
            g_ticket_160 = 0;
            return;
         }
         if (OrderTicket() == g_ticket_164) {
            g_ticket_164 = 0;
            return;
         }
         if (OrderTicket() == g_ticket_168) {
            g_ticket_168 = 0;
            return;
         }
      }
      OrderSelect(l_pos_128, SELECT_BY_POS, MODE_TRADES);
      if (Hour() == g_datetime_104 && OrderType() == OP_SELLSTOP) {
         OrderDelete(OrderTicket());
         if (OrderTicket() == g_ticket_172) {
            g_ticket_172 = 0;
            return;
         }
         if (OrderTicket() == g_ticket_176) {
            g_ticket_176 = 0;
            return;
         }
         if (OrderTicket() == g_ticket_180) {
            g_ticket_180 = 0;
            return;
         }
      }
      OrderSelect(g_ticket_160, SELECT_BY_TICKET);
      if (OrderClosePrice() > 0.0) g_ticket_160 = 0;
      OrderSelect(g_ticket_164, SELECT_BY_TICKET);
      if (OrderClosePrice() > 0.0) g_ticket_164 = 0;
      OrderSelect(g_ticket_168, SELECT_BY_TICKET);
      if (OrderClosePrice() > 0.0) g_ticket_168 = 0;
      OrderSelect(g_ticket_172, SELECT_BY_TICKET);
      if (OrderClosePrice() > 0.0) g_ticket_172 = 0;
      OrderSelect(g_ticket_176, SELECT_BY_TICKET);
      if (OrderClosePrice() > 0.0) g_ticket_176 = 0;
      OrderSelect(g_ticket_180, SELECT_BY_TICKET);
      if (OrderClosePrice() > 0.0) g_ticket_180 = 0;
   }
   return (0);
}