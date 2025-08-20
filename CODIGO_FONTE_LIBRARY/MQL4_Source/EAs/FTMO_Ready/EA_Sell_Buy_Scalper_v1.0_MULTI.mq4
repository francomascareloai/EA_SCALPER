extern double TakeProfit = 25.0;
extern double TakeProfit2 = 25.0;
extern double TrailingStop = 20.0;
extern double TrailingStop2 = 20.0;
extern double Lots = 1.0;
  
  color Filter10 = 68;
  color Filter12 = 9;
  color Filter6 = 80;
  color Filter4 = 35;
  color Filter2 = 47;
  color Filter9 = 46;
  string Name_EA = "sca";
  int Slippage = 30;
  bool UseSound = FALSE;
  string EAsound = "alert.wav";
  int adv;
int init()
  {
   return(0);
  }

void deinit() {
   Comment("");
}

int start() {
   if (Bars < 100) {
      Print("");
      return (0);
   }
   if (TakeProfit < 10.0) {
      Print("");
      return (0);
   }
   if (TakeProfit2 < 10.0) {
      Print("");
      return (0);
   }
   double l_iclose_0 = iClose(NULL, PERIOD_M5, 0);
   double l_ima_8 = iMA(NULL, PERIOD_M5, 7, 0, MODE_SMA, PRICE_OPEN, 0);
   double l_iclose_16 = iClose(NULL, PERIOD_M5, 0);
   double l_ima_24 = iMA(NULL, PERIOD_M5, 6, 0, MODE_SMA, PRICE_OPEN, 0);
   if (AccountFreeMargin() < 1000.0 * Lots) {
      Print(" Free Margin = ", AccountFreeMargin());
      return (0);
   }
   if (!ExistPositions()) {
      if (l_iclose_0 < l_ima_8) {
         OpenBuy();
         return (0);
      }
      if (l_iclose_16 > l_ima_24) {
         OpenSell();
         return (0);
      }
   }
   TrailingPositionsBuy(TrailingStop);
   TrailingPositionsSell(TrailingStop2);
   return (0);
}

bool ExistPositions() {
   for (int l_pos_0 = 0; l_pos_0 < OrdersTotal(); l_pos_0++) {
      if (OrderSelect(l_pos_0, SELECT_BY_POS, MODE_TRADES))
         if (OrderSymbol() == Symbol()) return (TRUE);
   }
   return (FALSE);
}

void TrailingPositionsBuy(int ai_0) {
   for (int l_pos_4 = 0; l_pos_4 < OrdersTotal(); l_pos_4++) {
      if (OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol()) {
            if (OrderType() == OP_BUY) {
               if (Bid - OrderOpenPrice() > ai_0 * Point)
                  if (OrderStopLoss() < Bid - ai_0 * Point) ModifyStopLoss(Bid - ai_0 * Point);
            }
         }
      }
   }
}

void TrailingPositionsSell(int ai_0) {
   for (int l_pos_4 = 0; l_pos_4 < OrdersTotal(); l_pos_4++) {
      if (OrderSelect(l_pos_4, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol()) {
            if (OrderType() == OP_SELL) {
               if (OrderOpenPrice() - Ask > ai_0 * Point)
                  if (OrderStopLoss() > Ask + ai_0 * Point || OrderStopLoss() == 0.0) ModifyStopLoss(Ask + ai_0 * Point);
            }
         }
      }
   }
}

void ModifyStopLoss(double a_price_0) {
   int l_bool_8 = OrderModify(OrderTicket(), OrderOpenPrice(), a_price_0, OrderTakeProfit(), 0, CLR_NONE);
   if (l_bool_8 && UseSound) PlaySound(EAsound);
}

void OpenBuy() {
   double l_lots_0 = GetSizeLot();
   double l_price_8 = 0;
   double l_price_16 = GetTakeProfitBuy();
   string l_comment_24 = GetCommentForOrder();
   adv=OrderSend(Symbol(), OP_BUY, l_lots_0, Ask, Slippage, l_price_8, l_price_16, l_comment_24, 0, 0, Filter10);
   if (UseSound) PlaySound(EAsound);
}

void OpenSell() {
   double l_lots_0 = GetSizeLot();
   double l_price_8 = 0;
   double l_price_16 = GetTakeProfitSell();
   string l_comment_24 = GetCommentForOrder();
   adv=OrderSend(Symbol(), OP_SELL, l_lots_0, Bid, Slippage, l_price_8, l_price_16, l_comment_24, 0, 0, Filter6);
   if (UseSound) PlaySound(EAsound);
}

string GetCommentForOrder() {
   return (Name_EA);
}

double GetSizeLot() {
   return (Lots);
}

double GetTakeProfitBuy() {
   return (Ask + TakeProfit * Point);
}

double GetTakeProfitSell() {
   return (Bid - TakeProfit2 * Point);
}