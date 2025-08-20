//+------------------------------------------------------------------+
//|                            HFT_Hedge_EA_UserLot.mq4              |
//|      Fix: User-defined Fixed Lot Size, No Dynamic Calculation    |
//+------------------------------------------------------------------+
#property strict

extern string Symbol1 = "XAUUSDm";
extern string Symbol2 = "XAUEURm";
extern double FixedLotSize = 0.1;          // User-defined lot size
extern double ProfitTargetUSD = 5.0;
extern int Slippage = 3;
extern bool DailyLock = true;
extern int MagicNumber = 12345;

datetime lastTradeTime = 0;
bool locked = false;

//+------------------------------------------------------------------+
//| Check for open trades                                            |
//+------------------------------------------------------------------+
bool HasOpenTrade(string symbol) {
   for (int i=OrdersTotal()-1; i>=0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == symbol && OrderMagicNumber() == MagicNumber) return true;
      }
   }
   return false;
}

//+------------------------------------------------------------------+
//| Get total profit of hedge trades                                 |
//+------------------------------------------------------------------+
double GetHedgeProfit() {
   double total = 0;
   for (int i=OrdersTotal()-1; i>=0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if ((OrderSymbol()==Symbol1 || OrderSymbol()==Symbol2) && OrderMagicNumber() == MagicNumber)
            total += OrderProfit() + OrderSwap() + OrderCommission();
      }
   }
   return total;
}

//+------------------------------------------------------------------+
//| Close all hedge trades                                           |
//+------------------------------------------------------------------+
void CloseHedge() {
   for (int i=OrdersTotal()-1; i>=0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if ((OrderSymbol()==Symbol1 || OrderSymbol()==Symbol2) && OrderMagicNumber() == MagicNumber) {
            int type = OrderType();
            double price = (type==OP_BUY) ? MarketInfo(OrderSymbol(), MODE_BID) : MarketInfo(OrderSymbol(), MODE_ASK);
            OrderClose(OrderTicket(), OrderLots(), price, Slippage, clrRed);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Main OnTick loop                                                 |
//+------------------------------------------------------------------+
void OnTick() {
   if (locked && TimeDay(TimeCurrent()) == TimeDay(lastTradeTime)) {
      Print("Daily lock active. No new trades.");
      return;
   }

   if (!HasOpenTrade(Symbol1) && !HasOpenTrade(Symbol2)) {
      double price1 = MarketInfo(Symbol1, MODE_ASK);
      double price2 = MarketInfo(Symbol2, MODE_ASK);
      double diff = MathAbs(price1 - price2);
      Print("Price diff: ", DoubleToStr(diff, 3));

      if (diff > 0.2) {
         int t1 = OrderSend(Symbol1, OP_BUY, FixedLotSize, Ask, Slippage, 0, 0, "Hedge Long", MagicNumber, 0, clrGreen);
         int t2 = OrderSend(Symbol2, OP_SELL, FixedLotSize, Bid, Slippage, 0, 0, "Hedge Short", MagicNumber, 0, clrBlue);
         if (t1 > 0 && t2 > 0) {
            lastTradeTime = TimeCurrent();
            Print("✅ Hedge opened successfully.");
         } else {
            Print("❌ OrderSend error: ", GetLastError());
         }
      }
   } else {
      double profit = GetHedgeProfit();
      Print("Current hedge profit: $", DoubleToStr(profit, 2));
      if (profit >= ProfitTargetUSD) {
         Print("Profit target hit. Closing hedge.");
         CloseHedge();
         if (DailyLock) locked = true;
      }
   }
}
