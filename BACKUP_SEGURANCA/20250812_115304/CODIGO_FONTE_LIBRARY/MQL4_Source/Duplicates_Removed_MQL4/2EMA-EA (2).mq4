/*
Four Inputs: 1 [Magic], 2 [Trade Comment], 3 [Lot size], 4 [Maximum Buy Sell].

1) Open Order
a) First Check: TradeCount [Maximum Buy Sell Input value] has not been exceeded.
b) all orders must be Distance from last Order of minimum [5 x (Spread + Broker Commission)]. If 0 orders, ignore above check and open Order immediately
c) Second Check: if 5EMA is above 20EMA, open Buy order; if 5EMA is below 20EMA, open Sell order.
d) use Lot Input value, Magic Input value, Trade Comment Input value.

2) Close Order
a) Closes buy orders when 5EMA crosses below 20EMA AND loss exceeds threshold
b) Closes sell orders when 5EMA crosses above 20EMA AND loss exceeds threshold
c) Add minimum loss threshold calculation: MinLossThreshold = 10 * (Spread + BrokerCommission)
*/

// best test on XAUUSD, H1, 5 trades, 5/10 EMA, 0.01 lot, dist_mult 5, PRICE_WEIGHTED

#property copyright "FreeWare"
#property link      ""
#property version   "1.01"
#property strict

//+------------------------------------------------------------------+
//| Input variables                                                  |
//+------------------------------------------------------------------+
input int MaxTrades = 5; // Max Trades (0 for unlimited)
input double LotSize = 0.01; // Lot Size
input int Magic  = 12345; // Magic number
input string TradeComment  = "2EMA"; // Trade comment

// more parameters, better to be available for user change
input int EMA_FAST_PERIOD = 5;
input int EMA_SLOW_PERIOD = 10;
input ENUM_APPLIED_PRICE EMA_PRICE_TYPE = PRICE_WEIGHTED;
input int distanceMultiplier = 5;

//+------------------------------------------------------------------+
//| Global variable                                                  |
//+------------------------------------------------------------------+
datetime newtime;
double spreadDistance;
int lastBuyTicket;
int lastSellTicket;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   newtime = 0;
   lastBuyTicket = LastOpenOrderTicket(OP_BUY);
   lastSellTicket = LastOpenOrderTicket(OP_SELL);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert Shutdown function                                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
   if(newtime == 0) {
      newtime = Time[0];
   } else {
      if(newtime != Time[0]) {
         newtime = Time[0];
         // at every new bar open (current timeframe):
         spreadDistance = MarketInfo(Symbol(), MODE_SPREAD) * MarketInfo(Symbol(), MODE_POINT);
         int orders_count = CountOrders();
         int buy_orders_count = CountOrdersByType(OP_BUY);
         int sell_orders_count = CountOrdersByType(OP_SELL);
         double lastBuyPrice = OrderPrice(lastBuyTicket);
         double lastSellPrice = OrderPrice(lastSellTicket);
         bool enoughDistanceForNewBuy = (lastBuyPrice>0) && (MathAbs(lastBuyPrice - Ask) >= spreadDistance * distanceMultiplier);
         bool enoughDistanceForNewSell = (lastSellPrice>0) && (MathAbs(lastSellPrice - Bid) >= spreadDistance * distanceMultiplier);
         double emaFast = iMA(_Symbol, _Period, EMA_FAST_PERIOD, 0, MODE_EMA, EMA_PRICE_TYPE, 1);
         double emaSlow = iMA(_Symbol, _Period, EMA_SLOW_PERIOD, 0, MODE_EMA, EMA_PRICE_TYPE, 1);
         double emaFastPrev = iMA(_Symbol, _Period, EMA_FAST_PERIOD, 0, MODE_EMA, EMA_PRICE_TYPE, 2);
         double emaSlowPrev = iMA(_Symbol, _Period, EMA_SLOW_PERIOD, 0, MODE_EMA, EMA_PRICE_TYPE, 2);
         bool emaCrossDn = emaFast < emaSlow && emaFastPrev >= emaSlowPrev;
         bool emaCrossUp = emaFast > emaSlow && emaFastPrev <= emaSlowPrev;
         double MinLossThreshold = 10 * spreadDistance; // ??? how to use it ???
         // check for open new order conditions:
         if(MaxTrades == 0 || (MaxTrades != 0 && orders_count < MaxTrades)) {
            if((emaFast > emaSlow) && (orders_count == 0 || enoughDistanceForNewBuy)) {
               // open first buy order
               int t = OpenOrder(OP_BUY, Ask, LotSize);
               if(t > 0) lastBuyTicket = t;
            } else {
               if((emaFast < emaSlow) && (orders_count == 0 || enoughDistanceForNewSell)) {
                  // open first sell order
                  int t = OpenOrder(OP_SELL, Bid, LotSize);
                  if(t > 0) lastSellTicket = t;
               }
            }
         }
         // check for the closing conditions:
         if(emaCrossDn && buy_orders_count > 0) {
            // check the condition to close all buy orders (need to use also MinLossThreshold ???)
            CloseOrdersByType(OP_BUY);
            lastBuyTicket = LastOpenOrderTicket(OP_BUY);
         }
         if(emaCrossUp && sell_orders_count > 0) {
            // check the condition to close all sell orders (need to use also MinLossThreshold ???)
            CloseOrdersByType(OP_SELL);
            lastSellTicket = LastOpenOrderTicket(OP_SELL);
         }
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OrderPrice(int ticket) {
   double price = 0;
   if(ticket <= 0) return price;
   if(OrderSelect(ticket, SELECT_BY_TICKET)) {
      price =  OrderOpenPrice();
   }
   return price;
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountOrders() {
   int count = 0;
   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderMagicNumber() == Magic && OrderSymbol() == Symbol()) {
            count++;
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountOrdersByType(int type) {
   int count = 0;
   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderMagicNumber() == Magic && OrderSymbol() == Symbol() && OrderType() == type) {
            count++;
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CheckVolume(string pSymbol, double pVolume) {
   double minVolume = SymbolInfoDouble(pSymbol, SYMBOL_VOLUME_MIN);
   double maxVolume = SymbolInfoDouble(pSymbol, SYMBOL_VOLUME_MAX);
   double stepVolume = SymbolInfoDouble(pSymbol, SYMBOL_VOLUME_STEP);
   double tradeSize;
   if(pVolume < minVolume) {
      tradeSize = minVolume;
   } else if(pVolume > maxVolume) {
      tradeSize = maxVolume;
   } else tradeSize = MathRound(pVolume / stepVolume) * stepVolume;
   if(stepVolume >= 0.1) tradeSize = NormalizeDouble(tradeSize, 1);
   else tradeSize = NormalizeDouble(tradeSize, 2);
   return(tradeSize);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OpenOrder(int type, double price, double lots) {
   double priceN =  NormalizeDouble(price, _Digits);
   double lotsN = CheckVolume(Symbol(), lots);
   int ticket = OrderSend(Symbol(), type, lotsN, priceN, 3, 0, 0, TradeComment, Magic, 0, (type == OP_BUY) ? clrGreen : clrRed);
   if (ticket < 0) {
      Print("Order open error: ", GetLastError());
   }
   return ticket;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseOrdersByType(int type) {
   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderMagicNumber() == Magic && OrderSymbol() == Symbol() && OrderType() == type) {
            bool result = false;
            if (type == OP_BUY)
               result = OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrBlue);
            else if (type == OP_SELL)
               result = OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrRed);
            if (!result)
               Print("Error closing order: ", GetLastError());
         }
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int LastOpenOrderTicket(int type = -1) {
   int ticket = 0;
   for (int i = OrdersTotal() - 1; i >= 0; i--) {
      bool ok = OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if(ok) {
         if (OrderSymbol() != Symbol() || (OrderMagicNumber() != Magic)) {
            continue;
         }
         if (OrderType() == OP_BUY && (type == OP_BUY || type == -1)) {
            ticket = OrderTicket();
            return ticket;
         }
         if (OrderType() == OP_SELL && (type == OP_SELL || type == -1)) {
            ticket = OrderTicket();
            return ticket;
         }
      }
   }
   return ticket;
}
