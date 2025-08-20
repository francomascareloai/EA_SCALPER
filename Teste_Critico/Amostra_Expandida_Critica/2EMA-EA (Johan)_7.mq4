#property copyright "Matt Todorovski 2025"
#property link      "https://x.ai"
#property description "Shared as freeware in Free Forex Robots on Telegram"
#property version   "1.06"
#property strict

input int MaxTrades = 5;
input double LotSize = 0.01;
input int Magic = 202503271;
input string TradeComment = "2EMA-Johan";

datetime newtime;
double spreadDistance;
int lastSellTicket, lastBuyTicket;
double hiddenSellStopLoss, hiddenBuyStopLoss;

// Hardcoded parameters
int distanceMultiplier = 2;
double KeepFreeMargin = 20.0;
int EMA_FAST_PERIOD = 5, EMA_SLOW_PERIOD = 10, EMA_TIMEFRAME = PERIOD_M15;
double LossThresholdMultiplier = 10.0;
double FloatingLossThreshold = 7.00, FloatingProfitThreshold = 3.00;
int ProfitToStartTrailingSL = 255, TrailingSLValue = 100;
string CloseTimeServer = "11:49";

int OnInit() {
   newtime = 0;
   lastSellTicket = LastOpenOrderTicket(OP_SELL);
   lastBuyTicket = LastOpenOrderTicket(OP_BUY);
   UpdateStopLossValues();
   return(INIT_SUCCEEDED);
}

void OnTick() {
   spreadDistance = MarketInfo(Symbol(), MODE_SPREAD) * MarketInfo(Symbol(), MODE_POINT);
   int orders_count = 0, sell_orders_count = 0, buy_orders_count = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == Magic && OrderSymbol() == Symbol()) {
         orders_count++;
         if(OrderType() == OP_SELL) sell_orders_count++;
         else if(OrderType() == OP_BUY) buy_orders_count++;
      }
   }

   double floatingProfit = AccountProfit();
   if(floatingProfit <= -FloatingLossThreshold || floatingProfit >= FloatingProfitThreshold || 
      AccountFreeMargin() < KeepFreeMargin || StringSubstr(TimeToString(TimeCurrent(), TIME_MINUTES), 11, 5) == CloseTimeServer) {
      CloseAllOrders();
      return;
   }

   ApplyTrailingStop();

   if(newtime != Time[0]) {
      newtime = Time[0];
      double lastSellPrice = OrderPrice(lastSellTicket), lastBuyPrice = OrderPrice(lastBuyTicket);
      bool enoughDistanceForNewSell = lastSellPrice > 0 && MathAbs(lastSellPrice - Bid) >= spreadDistance * distanceMultiplier;
      bool enoughDistanceForNewBuy = lastBuyPrice > 0 && MathAbs(lastBuyPrice - Ask) >= spreadDistance * distanceMultiplier;

      double emaFast = iMA(_Symbol, EMA_TIMEFRAME, EMA_FAST_PERIOD, 0, MODE_EMA, PRICE_OPEN, 1);
      double emaSlow = iMA(_Symbol, EMA_TIMEFRAME, EMA_SLOW_PERIOD, 0, MODE_EMA, PRICE_CLOSE, 1);
      double emaGap = MathAbs(emaFast - emaSlow);
      if(emaGap < spreadDistance * LossThresholdMultiplier) return;

      bool twoBearCandles = iClose(_Symbol, _Period, 1) < iOpen(_Symbol, _Period, 1) && 
                           MathAbs(iClose(_Symbol, _Period, 1) - iOpen(_Symbol, _Period, 1)) >= 10 * _Point &&
                           iClose(_Symbol, _Period, 2) < iOpen(_Symbol, _Period, 2) && 
                           MathAbs(iClose(_Symbol, _Period, 2) - iOpen(_Symbol, _Period, 2)) >= 10 * _Point;
      bool twoBullCandles = iClose(_Symbol, _Period, 1) > iOpen(_Symbol, _Period, 1) && 
                           MathAbs(iClose(_Symbol, _Period, 1) - iOpen(_Symbol, _Period, 1)) >= 10 * _Point &&
                           iClose(_Symbol, _Period, 2) > iOpen(_Symbol, _Period, 2) && 
                           MathAbs(iClose(_Symbol, _Period, 2) - iOpen(_Symbol, _Period, 2)) >= 10 * _Point;

      if(MaxTrades == 0 || orders_count < MaxTrades) {
         if(emaFast < emaSlow && emaGap > spreadDistance * distanceMultiplier && 
            twoBearCandles && (orders_count == 0 || enoughDistanceForNewSell)) {
            int t = OrderSend(Symbol(), OP_SELL, NormalizeDouble(LotSize, 2), Bid, 3, 0, 0, TradeComment, Magic, 0, clrRed);
            if(t > 0) { lastSellTicket = t; UpdateStopLossValues(); }
            else Print("Order open error: ", GetLastError());
         } else if(emaFast > emaSlow && emaGap > spreadDistance * distanceMultiplier && 
                  twoBullCandles && (orders_count == 0 || enoughDistanceForNewBuy)) {
            int t = OrderSend(Symbol(), OP_BUY, NormalizeDouble(LotSize, 2), Ask, 3, 0, 0, TradeComment, Magic, 0, clrGreen);
            if(t > 0) { lastBuyTicket = t; UpdateStopLossValues(); }
            else Print("Order open error: ", GetLastError());
         }
      }
   }

   if(sell_orders_count > 0 && hiddenSellStopLoss > 0 && Ask >= hiddenSellStopLoss) {
      CloseOrdersByType(OP_SELL);
      lastSellTicket = LastOpenOrderTicket(OP_SELL);
      hiddenSellStopLoss = 0;
   }
   if(buy_orders_count > 0 && hiddenBuyStopLoss > 0 && Bid <= hiddenBuyStopLoss) {
      CloseOrdersByType(OP_BUY);
      lastBuyTicket = LastOpenOrderTicket(OP_BUY);
      hiddenBuyStopLoss = 0;
   }
}

void UpdateStopLossValues() {
   if(lastSellTicket > 0 && OrderSelect(lastSellTicket, SELECT_BY_TICKET)) {
      hiddenSellStopLoss = iLow(_Symbol, _Period, 1);
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && 
            OrderMagicNumber() == Magic && OrderSymbol() == Symbol() && OrderType() == OP_SELL) {
            double orderSL = iLow(_Symbol, _Period, 1);
            if(orderSL < hiddenSellStopLoss || hiddenSellStopLoss == 0) hiddenSellStopLoss = orderSL;
         }
      }
   }
   
   if(lastBuyTicket > 0 && OrderSelect(lastBuyTicket, SELECT_BY_TICKET)) {
      hiddenBuyStopLoss = iHigh(_Symbol, _Period, 1);
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && 
            OrderMagicNumber() == Magic && OrderSymbol() == Symbol() && OrderType() == OP_BUY) {
            double orderSL = iHigh(_Symbol, _Period, 1);
            if(orderSL > hiddenBuyStopLoss) hiddenBuyStopLoss = orderSL;
         }
      }
   }
}

void ApplyTrailingStop() {
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == Magic && OrderSymbol() == Symbol()) {
         if(OrderType() == OP_BUY) {
            double profit = (Bid - OrderOpenPrice()) / _Point;
            if(profit >= ProfitToStartTrailingSL) {
               double newSL = Bid - TrailingSLValue * _Point;
               if(OrderStopLoss() == 0 || newSL > OrderStopLoss()) {
                  bool success = OrderModify(OrderTicket(), OrderOpenPrice(), newSL, 0, 0, clrNONE);
                  if(!success) Print("OrderModify failed for Buy order: ", GetLastError());
               }
            }
         } else if(OrderType() == OP_SELL) {
            double profit = (OrderOpenPrice() - Ask) / _Point;
            if(profit >= ProfitToStartTrailingSL) {
               double newSL = Ask + TrailingSLValue * _Point;
               if(OrderStopLoss() == 0 || newSL < OrderStopLoss()) {
                  bool success = OrderModify(OrderTicket(), OrderOpenPrice(), newSL, 0, 0, clrNONE);
                  if(!success) Print("OrderModify failed for Sell order: ", GetLastError());
               }
            }
         }
      }
   }
}

double OrderPrice(int ticket) {
   if(ticket <= 0 || !OrderSelect(ticket, SELECT_BY_TICKET)) return 0;
   return OrderOpenPrice();
}

void CloseOrdersByType(int type) {
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && 
         OrderMagicNumber() == Magic && OrderSymbol() == Symbol() && OrderType() == type) {
         if(!OrderClose(OrderTicket(), OrderLots(), type == OP_BUY ? Bid : Ask, 3, type == OP_BUY ? clrBlue : clrRed))
            Print("Error closing order: ", GetLastError());
      }
   }
}

void CloseAllOrders() {
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && 
         OrderMagicNumber() == Magic && OrderSymbol() == Symbol()) {
         if(!OrderClose(OrderTicket(), OrderLots(), OrderType() == OP_BUY ? Bid : Ask, 3, OrderType() == OP_BUY ? clrBlue : clrRed))
            Print("Error closing order: ", GetLastError());
      }
   }
}

int LastOpenOrderTicket(int type = -1) {
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && 
         OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
         if(OrderType() == OP_SELL && (type == OP_SELL || type == -1)) return OrderTicket();
         if(OrderType() == OP_BUY && (type == OP_BUY || type == -1)) return OrderTicket();
      }
   }
   return 0;
}