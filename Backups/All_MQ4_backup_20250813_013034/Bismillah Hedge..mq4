
#property copyright "PT Trada Mitra Utama Int."
#property link      "indofxrebates"

extern string EAName = "hedge close";
extern int pips = 100;
extern double lots = 0.01;
extern int FixedSpread = 3;
extern int NbLevels = 10;
extern bool ContinueTrading = TRUE;
bool gi_108 = FALSE;
bool gi_112 = FALSE;
int gi_116 = 0;
string gs_unused_120 = " Setting Tampilan EA";
int g_corner_128 = 1;
int g_color_132 = Green;
int g_fontsize_136 = 10;
string gs_calibri_140 = "Calibri";
int gi_148 = 15;
int gi_152 = 2;
bool gi_156 = TRUE;
bool gi_160 = TRUE;
bool gi_unused_164 = TRUE;
int g_magic_168 = 123321;
int gi_172 = 0;
int gi_unused_176 = 0;
int gi_unused_180 = 0;
int gi_unused_184 = 10;

int init() {
   return (0);
}

int deinit() {
   ObjectDelete("ObjLots_Label");
   ObjectDelete("ObjBuyGoal_Label");
   ObjectDelete("ObjBuyGoalProfit_Label");
   ObjectDelete("ObjSellGoal_Label");
   ObjectDelete("ObjSellGoalProfit_Label");
   ObjectDelete("ObjLevels_Label");
   ObjectDelete("ObjPairTotal_Label");
   ObjectDelete("ObjInitialprice_Label");
   ObjectDelete("ObjSellGoalStop_Label");
   ObjectDelete("ObjBuyGoalStop_Label");
   ObjectDelete("ObjContinueTrading_Label");
   return (0);
}

int start() {
   int l_ticket_0 = 0;
   int l_pos_4 = 0;
   int li_unused_8 = 0;
   int li_unused_12 = 0;
   int l_count_16 = 0;
   int li_20 = 0;
   int li_24 = 0;
   double l_price_28 = 0;
   double l_price_36 = 0;
   double l_price_44 = 0;
   double l_price_52 = 0;
   double ld_60 = FixedSpread;
   double ld_68 = 0;
   if (pips < MarketInfo(Symbol(), MODE_STOPLEVEL) + ld_60) pips = MarketInfo(Symbol(), MODE_STOPLEVEL) + 1.0 + ld_60;
   if (lots < MarketInfo(Symbol(), MODE_MINLOT)) lots = MarketInfo(Symbol(), MODE_MINLOT);
   for (l_pos_4 = 0; l_pos_4 < OrdersTotal(); l_pos_4++) {
      OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_168) {
         l_count_16++;
         if (!ld_68) ld_68 = StrToDouble(OrderComment());
      }
   }
   if (gi_108 == TRUE) {
      KillSession();
      return (0);
   }
   if (gi_156 == TRUE && l_count_16 >= 1) {
      EndSession();
      return (0);
   }
   if (l_count_16 == 0 && gi_160 && !gi_112 || (gi_112 && Hour() == gi_116)) {
      gi_156 = FALSE;
      ld_68 = Ask;
      l_price_28 = ld_68 + (NbLevels + 1) * pips * Point;
      l_price_44 = ld_68 - (NbLevels + 1) * pips * Point;
      l_price_36 = l_price_44 - ld_60 * Point;
      l_price_52 = l_price_28 + ld_60 * Point;
      for (l_pos_4 = 1; l_pos_4 <= NbLevels; l_pos_4++) {
         OrderSend(Symbol(), OP_BUYSTOP, lots, ld_68 + l_pos_4 * pips * Point, 2, l_price_36, l_price_28, DoubleToStr(ld_68, MarketInfo(Symbol(), MODE_DIGITS)), g_magic_168, 0);
         OrderSend(Symbol(), OP_SELLSTOP, lots, ld_68 - l_pos_4 * pips * Point, 2, l_price_52, l_price_44, DoubleToStr(ld_68, MarketInfo(Symbol(), MODE_DIGITS)), g_magic_168, 0);
      }
   } else {
      l_price_28 = ld_68 + (NbLevels + 1) * pips * Point;
      l_price_44 = ld_68 - (NbLevels + 1) * pips * Point;
      l_price_36 = l_price_44 - ld_60 * Point;
      l_price_52 = l_price_28 + ld_60 * Point;
      if (Bid >= l_price_28) {
         gi_156 = TRUE;
         EndSession();
         return (0);
      }
      if (Ask <= l_price_44) {
         gi_156 = TRUE;
         EndSession();
         return (0);
      }
      if (gi_156 == TRUE) {
         EndSession();
         return (0);
      }
      li_20 = CheckProfits(lots, 0, 0, ld_68);
      li_24 = CheckProfits(lots, 1, 0, ld_68);
      if (li_20 < gi_172) {
         for (l_pos_4 = NbLevels; l_pos_4 >= 1; l_pos_4--) {
            if (Ask <= ld_68 + (l_pos_4 * pips - MarketInfo(Symbol(), MODE_STOPLEVEL)) * Point) l_ticket_0 = OrderSend(Symbol(), OP_BUYSTOP, l_pos_4 * lots, ld_68 + l_pos_4 * pips * Point, 2, l_price_36, l_price_28, DoubleToStr(ld_68, MarketInfo(Symbol(), MODE_DIGITS)), g_magic_168, 0);
            if (l_ticket_0 > 0) li_20 += lots * (l_price_28 - ld_68 - l_pos_4 * pips * Point) / Point;
         }
      }
      if (li_24 < gi_172) {
         for (l_pos_4 = NbLevels; l_pos_4 >= 1; l_pos_4--) {
            if (Bid >= ld_68 - (l_pos_4 * pips - MarketInfo(Symbol(), MODE_STOPLEVEL)) * Point) l_ticket_0 = OrderSend(Symbol(), OP_SELLSTOP, l_pos_4 * lots, ld_68 - l_pos_4 * pips * Point, 2, l_price_52, l_price_44, DoubleToStr(ld_68, MarketInfo(Symbol(), MODE_DIGITS)), g_magic_168, 0);
            if (l_ticket_0 > 0) li_24 += lots * (ld_68 - l_price_44 - l_pos_4 * pips * Point) / Point;
         }
      }
   }
   string l_dbl2str_76 = DoubleToStr(lots, 2);
   string ls_unused_84 = pips;
   string ls_92 = NbLevels;
   string l_dbl2str_100 = DoubleToStr(l_price_28, Digits);
   string ls_108 = li_20;
   string l_dbl2str_116 = DoubleToStr(l_price_44, Digits);
   string ls_124 = li_24;
   string ls_132 = l_count_16;
   string l_dbl2str_140 = DoubleToStr(ld_68, Digits);
   string l_dbl2str_148 = DoubleToStr(l_price_36, Digits);
   string l_dbl2str_156 = DoubleToStr(l_price_52, Digits);
   string l_bool_164 = ContinueTrading;
   int l_x_172 = gi_152;
   int l_y_176 = gi_148;
   int li_180 = 15;
   int l_y_184 = l_y_176 + li_180;
   int l_y_188 = l_y_184 + li_180 + 10;
   int l_y_192 = l_y_188 + li_180;
   int l_y_196 = l_y_192 + li_180;
   int l_y_200 = l_y_196 + li_180 + 10;
   int l_y_204 = l_y_200 + li_180;
   int l_y_208 = l_y_204 + li_180 + 10;
   int li_212 = l_y_208 + li_180;
   int li_216 = li_212 + li_180;
   ObjectCreate("ObjContinueTrading_Label", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("ObjContinueTrading_Label", "Continuous Trade " + l_bool_164, g_fontsize_136, gs_calibri_140, g_color_132);
   ObjectSet("ObjContinueTrading_Label", OBJPROP_CORNER, g_corner_128);
   ObjectSet("ObjContinueTrading_Label", OBJPROP_XDISTANCE, l_x_172);
   ObjectSet("ObjContinueTrading_Label", OBJPROP_YDISTANCE, l_y_176);
   ObjectCreate("ObjLots_Label", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("ObjLots_Label", "Lots " + l_dbl2str_76, g_fontsize_136, gs_calibri_140, g_color_132);
   ObjectSet("ObjLots_Label", OBJPROP_CORNER, g_corner_128);
   ObjectSet("ObjLots_Label", OBJPROP_XDISTANCE, l_x_172);
   ObjectSet("ObjLots_Label", OBJPROP_YDISTANCE, l_y_184);
   ObjectCreate("ObjLevels_Label", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("ObjLevels_Label", "Levels " + ls_92, g_fontsize_136, gs_calibri_140, g_color_132);
   ObjectSet("ObjLevels_Label", OBJPROP_CORNER, g_corner_128);
   ObjectSet("ObjLevels_Label", OBJPROP_XDISTANCE, l_x_172 + 60);
   ObjectSet("ObjLevels_Label", OBJPROP_YDISTANCE, l_y_184);
   ObjectCreate("ObjInitialprice_Label", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("ObjInitialprice_Label", "Start Price " + l_dbl2str_140, g_fontsize_136, gs_calibri_140, g_color_132);
   ObjectSet("ObjInitialprice_Label", OBJPROP_CORNER, g_corner_128);
   ObjectSet("ObjInitialprice_Label", OBJPROP_XDISTANCE, l_x_172);
   ObjectSet("ObjInitialprice_Label", OBJPROP_YDISTANCE, l_y_188);
   ObjectCreate("ObjBuyGoal_Label", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("ObjBuyGoal_Label", "Buy TP " + l_dbl2str_100, g_fontsize_136, gs_calibri_140, g_color_132);
   ObjectSet("ObjBuyGoal_Label", OBJPROP_CORNER, g_corner_128);
   ObjectSet("ObjBuyGoal_Label", OBJPROP_XDISTANCE, l_x_172);
   ObjectSet("ObjBuyGoal_Label", OBJPROP_YDISTANCE, l_y_192);
   ObjectCreate("ObjSellGoal_Label", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("ObjSellGoal_Label", "Sell TP " + l_dbl2str_116, g_fontsize_136, gs_calibri_140, g_color_132);
   ObjectSet("ObjSellGoal_Label", OBJPROP_CORNER, g_corner_128);
   ObjectSet("ObjSellGoal_Label", OBJPROP_XDISTANCE, l_x_172);
   ObjectSet("ObjSellGoal_Label", OBJPROP_YDISTANCE, l_y_196);
   ObjectCreate("ObjBuyGoalProfit_Label", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("ObjBuyGoalProfit_Label", "Buy Pips  " + ls_108, g_fontsize_136, gs_calibri_140, g_color_132);
   ObjectSet("ObjBuyGoalProfit_Label", OBJPROP_CORNER, g_corner_128);
   ObjectSet("ObjBuyGoalProfit_Label", OBJPROP_XDISTANCE, l_x_172);
   ObjectSet("ObjBuyGoalProfit_Label", OBJPROP_YDISTANCE, l_y_200);
   ObjectCreate("ObjSellGoalProfit_Label", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("ObjSellGoalProfit_Label", "Sell Pips  " + ls_124, g_fontsize_136, gs_calibri_140, g_color_132);
   ObjectSet("ObjSellGoalProfit_Label", OBJPROP_CORNER, g_corner_128);
   ObjectSet("ObjSellGoalProfit_Label", OBJPROP_XDISTANCE, l_x_172);
   ObjectSet("ObjSellGoalProfit_Label", OBJPROP_YDISTANCE, l_y_204);
   ObjectCreate("ObjPairTotal_Label", OBJ_LABEL, 0, 0, 0);
   ObjectSetText("ObjPairTotal_Label", "Total Trades  " + ls_132, g_fontsize_136, gs_calibri_140, g_color_132);
   ObjectSet("ObjPairTotal_Label", OBJPROP_CORNER, g_corner_128);
   ObjectSet("ObjPairTotal_Label", OBJPROP_XDISTANCE, l_x_172);
   ObjectSet("ObjPairTotal_Label", OBJPROP_YDISTANCE, l_y_208);
   Comment("" 
      + "\n" 
      + "Beautiful Bby Hedge" 
      + "\n" 
      + "------------------------------------------------" 
      + "\n" 
      + "BISMILLAH INFORMATION:" 
      + "\n" 
      + "Nama BROKER      " + AccountCompany() 
      + "\n" 
      + "------------------------------------------------" 
      + "\n" 
      + "ACC INFORMATION:" 
      + "\n" 
      + "Nama ACCOUNT :          " + AccountName() 
      + "\n" 
      + "NOMOR ACCOUNT :       " + AccountNumber() 
      + "\n" 
      + "ACCOUNT  Leverage:     " + DoubleToStr(AccountLeverage(), 0) 
      + "\n" 
      + " SALDO ACCOUNT :       " + DoubleToStr(AccountBalance(), 2) 
      + "\n" 
      + "MATA UANG :     " + AccountCurrency() 
      + "\n" 
      + " Equity:         " + DoubleToStr(AccountEquity(), 2) 
      + "\n" 
      + "------------------------------------------------" 
      + "\n" 
      + "MARGIN INFORMATION:" 
      + "\n" 
      + "Free Margin:              " + DoubleToStr(AccountFreeMargin(), 2) 
      + "\n" 
      + "Used Margin:              " + DoubleToStr(AccountMargin(), 2) 
      + "\n" 
      + "------------------------------------------------" 
      + "\n" 
      + "Actual Server Time     " + TimeToStr(TimeCurrent(), TIME_SECONDS) 
      + "\n" 
   + "------------------------------------------------");
   return (0);
}

int CheckProfits(double ad_0, int ai_8, bool ai_12, double ad_16) {
   int li_ret_24 = 0;
   if (ai_12) {
      for (int l_pos_28 = 0; l_pos_28 < OrdersTotal(); l_pos_28++) {
         OrderSelect(l_pos_28, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_168 && StrToDouble(OrderComment()) == ad_16) {
            if (OrderType() == OP_BUY) li_ret_24 += (Bid - OrderOpenPrice()) / Point * OrderLots() / ad_0;
            if (OrderType() == OP_SELL) li_ret_24 += (OrderOpenPrice() - Ask) / Point * OrderLots() / ad_0;
         }
      }
      return (li_ret_24);
   }
   if (ai_8 == 0) {
      for (l_pos_28 = 0; l_pos_28 < OrdersTotal(); l_pos_28++) {
         OrderSelect(l_pos_28, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_168 && StrToDouble(OrderComment()) == ad_16) {
            if (OrderType() == OP_BUY) li_ret_24 += (OrderTakeProfit() - OrderOpenPrice()) / Point * OrderLots() / ad_0;
            if (OrderType() == OP_SELL) li_ret_24 -= (OrderStopLoss() - OrderOpenPrice()) / Point * OrderLots() / ad_0;
            if (OrderType() == OP_BUYSTOP) li_ret_24 += (OrderTakeProfit() - OrderOpenPrice()) / Point * OrderLots() / ad_0;
         }
      }
      return (li_ret_24);
   }
   for (l_pos_28 = 0; l_pos_28 < OrdersTotal(); l_pos_28++) {
      OrderSelect(l_pos_28, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_168 && StrToDouble(OrderComment()) == ad_16) {
         if (OrderType() == OP_BUY) li_ret_24 -= (OrderOpenPrice() - OrderStopLoss()) / Point * OrderLots() / ad_0;
         if (OrderType() == OP_SELL) li_ret_24 += (OrderOpenPrice() - OrderTakeProfit()) / Point * OrderLots() / ad_0;
         if (OrderType() == OP_SELLSTOP) li_ret_24 += (OrderOpenPrice() - OrderTakeProfit()) / Point * OrderLots() / ad_0;
      }
   }
   return (li_ret_24);
}

int EndSession() {
   int l_ord_total_0 = OrdersTotal();
   for (int l_pos_4 = 0; l_pos_4 < l_ord_total_0; l_pos_4++) {
      OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_168 && OrderType() > OP_BUY) OrderDelete(OrderTicket());
   }
   if (!ContinueTrading) gi_160 = FALSE;
   return (1);
}

int KillSession() {
   int l_ord_total_0 = OrdersTotal();
   for (int l_pos_4 = 0; l_pos_4 < l_ord_total_0; l_pos_4++) {
      OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_168 && OrderType() == OP_BUYSTOP) OrderDelete(OrderTicket());
      else {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_168 && OrderType() == OP_SELLSTOP) OrderDelete(OrderTicket());
         else {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_168 && OrderType() == OP_BUY) OrderClose(OrderTicket(), OrderLots(), Bid, 3);
            else
               if (OrderSymbol() == Symbol() && OrderMagicNumber() == g_magic_168 && OrderType() == OP_SELL) OrderClose(OrderTicket(), OrderLots(), Ask, 3);
         }
      }
   }
   if (!ContinueTrading) gi_160 = FALSE;
   return (1);
}