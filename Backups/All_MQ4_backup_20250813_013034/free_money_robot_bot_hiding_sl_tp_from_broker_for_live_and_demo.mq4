//+------------------------------------------------------------------+
//| Buy-Only EA with Martingale, Virtual TP/SL, Slippage, Spread Filter |
//+------------------------------------------------------------------+
#property strict

input double  LotSize           = 0.01;
input double  TakeProfit        = 100;         // points (hidden from broker)
input double  StopLoss          = 50;          // points (hidden from broker)
input int     Slippage          = 1;
input double  MartingaleFactor  = 2.0;
input double  MaxLotSize        = 10.0;
input double  MaxSpread         = 20.0;        // Maximum spread allowed (in points)
input int     MagicNumber       = 1;           // Unique Magic Number for this EA
input int     TradeStartHour    = 0;
input int     TradeEndHour      = 23;
input string  CommentText       = "Buy-Only EA";
input bool    PushNotifications = true;
input bool    EmailAlerts       = true;

string lossTradeFile = "last_trade_loss.dat";
double LastLot = 0;
datetime LastClosedTime = 0;
bool LastTradeWasLoss = false;

int OnInit() {
   int fileHandle = FileOpen(lossTradeFile, FILE_BIN | FILE_READ);
   if (fileHandle != INVALID_HANDLE) {
      LastTradeWasLoss = (FileReadInteger(fileHandle, CHAR_VALUE) == 1);
      FileClose(fileHandle);
   }
   return INIT_SUCCEEDED;
}

void SaveTradeState() {
   int fileHandle = FileOpen(lossTradeFile, FILE_BIN | FILE_WRITE);
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
            double currentPrice = Bid;
            double tpPrice = entryPrice + TakeProfit * Point;
            double slPrice = entryPrice - StopLoss * Point;

            if (currentPrice >= tpPrice || currentPrice <= slPrice) {
               bool closed = OrderClose(OrderTicket(), OrderLots(), currentPrice, Slippage, clrYellow);
               if (!closed) Print("OrderClose failed. Error: ", GetLastError());
            }
         }
      }
   }

   // If no open orders, place a BUY
   if (OrdersTotal() == 0) {
      CheckLastTrade();

      double lot = (LastLot == 0) ? LotSize : LastLot;
      if (lot > MaxLotSize) lot = MaxLotSize;

      OpenTrade(OP_BUY, lot);
      SaveTradeState();

      if (PushNotifications) SendNotification("Buy Trade Opened: " + CommentText);
      if (EmailAlerts) SendMail("Buy Trade Alert", "A new BUY trade has been opened: " + CommentText);
   }
}

void OpenTrade(int orderType, double lot) {
   double price = Ask;
   int ticket = OrderSend(Symbol(), orderType, lot, price, Slippage, 0, 0, CommentText, MagicNumber, 0, clrBlue);
   if (ticket < 0) {
      Print("OrderSend failed with error #", GetLastError());
   } else {
      Print("Order opened: BUY | Lot: ", lot);
   }
}

void CheckLastTrade() {
   int total = OrdersHistoryTotal();
   for (int i = total - 1; i >= 0; i--) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
         if (OrderSymbol() == Symbol() && OrderType() == OP_BUY) {
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
