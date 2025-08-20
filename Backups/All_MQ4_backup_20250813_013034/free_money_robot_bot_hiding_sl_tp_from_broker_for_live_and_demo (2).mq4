//+------------------------------------------------------------------+
//| Alternating Buy/Sell EA with Martingale, Virtual TP/SL, Slippage, Spread Filter |
//+------------------------------------------------------------------+
#property strict

input double  LotSize           = 0.01;
input double  TakeProfit        = 100;         // points (hidden from broker)
input double  StopLoss          = 50;          // points (hidden from broker)
input int     Slippage          = 1;
input double  MartingaleFactor  = 2.0;
input double  MaxLotSize        = 10.0;        // prevent infinite martingale
input double  MaxSpread         = 20.0;        // Maximum spread allowed (in points)
input int     MagicNumber       = 1;           // Unique Magic Number for this EA
input int     TradeStartHour    = 0;
input int     TradeEndHour      = 23;
input string  CommentText       = "Trade comment"; // User-defined comment for each order
input bool    PushNotifications = true;
input bool    EmailAlerts       = true;

string directionFile = "last_trade_direction.dat";
string lossTradeFile = "last_trade_loss.dat";
double LastLot = 0;
datetime LastClosedTime = 0;
bool LastTradeWasBuy = true;
bool LastTradeWasLoss = false;
bool FirstTrade = true;

int OnInit() {
   int fileHandle = FileOpen(directionFile, FILE_BIN | FILE_READ);
   if (fileHandle != INVALID_HANDLE) {
      LastTradeWasBuy = (FileReadInteger(fileHandle, CHAR_VALUE) == 1);
      FileClose(fileHandle);
   } else {
      LastTradeWasBuy = true;
   }

   fileHandle = FileOpen(lossTradeFile, FILE_BIN | FILE_READ);
   if (fileHandle != INVALID_HANDLE) {
      LastTradeWasLoss = (FileReadInteger(fileHandle, CHAR_VALUE) == 1);
      FileClose(fileHandle);
   }

   return(INIT_SUCCEEDED);
}

void SaveTradeState() {
   int fileHandle = FileOpen(directionFile, FILE_BIN | FILE_WRITE);
   if (fileHandle != INVALID_HANDLE) {
      FileWriteInteger(fileHandle, (LastTradeWasBuy ? 1 : 0), CHAR_VALUE);
      FileClose(fileHandle);
   }
   fileHandle = FileOpen(lossTradeFile, FILE_BIN | FILE_WRITE);
   if (fileHandle != INVALID_HANDLE) {
      FileWriteInteger(fileHandle, (LastTradeWasLoss ? 1 : 0), CHAR_VALUE);
      FileClose(fileHandle);
   }
}

void OnTick() {
   int currentHour = TimeHour(TimeCurrent());
   if (currentHour < TradeStartHour || currentHour > TradeEndHour) return;

   double spread = MarketInfo(Symbol(), MODE_SPREAD);
   if (spread > MaxSpread) {
      Print("Spread too high: ", spread, " points. Trade skipped.");
      return;
   }

   // Manage hidden TP/SL
   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol()) {
            double entryPrice = OrderOpenPrice();
            double currentPrice = (OrderType() == OP_BUY) ? Bid : Ask;
            double tpPrice = (OrderType() == OP_BUY) ? entryPrice + TakeProfit * Point : entryPrice - TakeProfit * Point;
            double slPrice = (OrderType() == OP_BUY) ? entryPrice - StopLoss * Point : entryPrice + StopLoss * Point;

            if ((OrderType() == OP_BUY && (currentPrice >= tpPrice || currentPrice <= slPrice)) ||
                (OrderType() == OP_SELL && (currentPrice <= tpPrice || currentPrice >= slPrice))) {
               bool closed = OrderClose(OrderTicket(), OrderLots(), currentPrice, Slippage, clrYellow);
               if (!closed) Print("OrderClose failed. Error: ", GetLastError());
            }
         }
      }
   }

   if (OrdersTotal() == 0) {
      CheckLastTrade();
      double lot = (LastLot == 0) ? LotSize : LastLot;
      if (lot > MaxLotSize) lot = MaxLotSize;

      if (FirstTrade) {
         OpenTrade(OP_BUY, lot); LastTradeWasBuy = true; FirstTrade = false;
      } else {
         if (LastTradeWasBuy) {
            OpenTrade(OP_SELL, lot); LastTradeWasBuy = false;
         } else {
            OpenTrade(OP_BUY, lot); LastTradeWasBuy = true;
         }
      }

      SaveTradeState();
   }

   if (PushNotifications && OrdersTotal() > 0) {
      SendNotification("Trade Alert: " + CommentText);
   }

   if (EmailAlerts && OrdersTotal() > 0) {
      SendMail("Trade Alert", "A new trade has been opened: " + CommentText);
   }
}

void OpenTrade(int orderType, double lot) {
   double price = (orderType == OP_BUY) ? Ask : Bid;
   int ticket = OrderSend(Symbol(), orderType, lot, price, Slippage, 0, 0, CommentText, MagicNumber, 0, clrBlue);
   if (ticket < 0) {
      Print("OrderSend failed with error #", GetLastError());
   } else {
      Print("Order opened: ", (orderType == OP_BUY ? "BUY" : "SELL"), " | Lot: ", lot);
   }
}

void CheckLastTrade() {
   int total = OrdersHistoryTotal();
   for (int i = total - 1; i >= 0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
         if (OrderSymbol() == Symbol() && (OrderType() == OP_BUY || OrderType() == OP_SELL)) {
            if (OrderCloseTime() > LastClosedTime) {
               LastClosedTime = OrderCloseTime();
               if (OrderProfit() < 0) {
                  LastLot = OrderLots() * MartingaleFactor;
                  LastTradeWasLoss = true;
               } else {
                  LastLot = 0;
                  LastTradeWasLoss = false;
               }
               break;
            }
         }
      }
   }
}
