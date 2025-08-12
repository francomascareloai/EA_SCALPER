//+------------------------------------------------------------------+
//| Alternating Buy/Sell EA with Martingale, TP, SL, Slippage, Spread Filter |
//+------------------------------------------------------------------+
#property strict

input double  LotSize           = 0.1;
input double  TakeProfit        = 100;         // points
input double  StopLoss          = 50;          // points
input int     Slippage          = 3;
input double  MartingaleFactor  = 2.0;
input double  MaxLotSize        = 10.0;        // Max lot size to prevent huge risks
input double  MaxSpread         = 20.0;        // Max spread allowed (in points)

input int     TradeStartHour    = 8;           // Allowed trading start hour (24h)
input int     TradeEndHour      = 18;          // Allowed trading end hour (24h)
input int MagicNumber = 123456; // Unique identifier for this EA's trades


double LastLot = 0;
bool LastTradeWasBuy = true; // Track last trade direction
datetime LastClosedTime = 0;

int OnInit() {
   return(INIT_SUCCEEDED);
}

void OnTick() {
   // Time filter
   int currentHour = TimeHour(TimeCurrent());
   if (currentHour < TradeStartHour || currentHour >= TradeEndHour) {
      return;
   }

   // Spread filter
   double spread = MarketInfo(Symbol(), MODE_SPREAD);
   if (spread > MaxSpread) {
      Print("Spread too high: ", spread, " points. Trade skipped.");
      return;
   }

   // If no open orders, proceed to open a new one
   if (OrdersTotal() == 0) {
      CheckLastTrade(); // Check last trade result for Martingale
      
      double lot = (LastLot == 0) ? LotSize : LastLot;
      if (lot > MaxLotSize) {
         lot = MaxLotSize;
         Print("Lot size capped to MaxLotSize: ", MaxLotSize);
      }

      // Alternate between Buy and Sell
      if (LastTradeWasBuy) {
         OpenTrade(OP_SELL, lot);  // Sell if last was Buy
         LastTradeWasBuy = false;
      } else {
         OpenTrade(OP_BUY, lot);   // Buy if last was Sell
         LastTradeWasBuy = true;
      }
   }
}

// Function to open a trade (Buy or Sell)
void OpenTrade(int orderType, double lot) {
   double price, sl, tp;
   int ticket;

   if (orderType == OP_BUY) {
      price = Ask;
      sl = NormalizeDouble(price - StopLoss * Point, Digits);
      tp = NormalizeDouble(price + TakeProfit * Point, Digits);
      ticket = OrderSend(Symbol(), OP_BUY, lot, price, Slippage, sl, tp, "BuyOrder", MagicNumber, 0, clrBlue);
   } else {
      price = Bid;
      sl = NormalizeDouble(price + StopLoss * Point, Digits);
      tp = NormalizeDouble(price - TakeProfit * Point, Digits);
      ticket = OrderSend(Symbol(), OP_SELL, lot, price, Slippage, sl, tp, "SellOrder", MagicNumber, 0, clrRed);
   }

   if (ticket < 0) {
      int err = GetLastError();
      Print("OrderSend failed with error #", err);
   } else {
      Print("Order opened: ", (orderType == OP_BUY ? "BUY" : "SELL"), " | Lot: ", lot);
   }
}

// Check the last trade's result to determine the next lot size (for Martingale)
void CheckLastTrade() {
   int total = OrdersHistoryTotal();
   for (int i = total - 1; i >= 0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
         if (OrderSymbol() == Symbol() && (OrderType() == OP_BUY || OrderType() == OP_SELL)) {
            if (OrderCloseTime() > LastClosedTime) {
               LastClosedTime = OrderCloseTime();
               if (OrderProfit() < 0) {
                  LastLot = OrderLots() * MartingaleFactor; // Apply Martingale after loss
               } else {
                  LastLot = 0; // Reset lot size after a win
               }
               break;
            }
         }
      }
   }
}