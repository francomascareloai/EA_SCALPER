//+------------------------------------------------------------------+
//| Alternating Buy/Sell EA with Martingale, TP, SL, Slippage, Spread Filter |
//+------------------------------------------------------------------+
#property strict

input double  LotSize           = 0.01;
input double  TakeProfit        = 100;         // in points
input double  StopLoss          = 50;          // in points
input int     Slippage          = 1;
input double  MartingaleFactor  = 2.0;
input double  MaxLotSize        = 10.0;
input double  MaxSpread         = 20.0;        // in points
input int     MagicNumber       = 123456;
input int     TradeStartHour    = 8;
input int     TradeEndHour      = 18;
input string  CommentText       = "Trade comment";
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

void OnTick() {
   int currentHour = TimeHour(TimeCurrent());
   if (currentHour < TradeStartHour || currentHour >= TradeEndHour) return;

   double spread = MarketInfo(Symbol(), MODE_SPREAD);
   if (spread > MaxSpread) {
      Print("Spread too high: ", spread, " points. Trade skipped.");
      return;
   }

   if (!HasOpenOrder()) {
      CheckLastTrade();
      double lot = (LastLot == 0) ? LotSize : LastLot;
      if (lot > MaxLotSize) lot = MaxLotSize;

      if (FirstTrade) {
         OpenTrade(OP_BUY, lot);
         LastTradeWasBuy = true;
         FirstTrade = false;
      } else {
         if (LastTradeWasBuy) {
            OpenTrade(OP_SELL, lot);
            LastTradeWasBuy = false;
         } else {
            OpenTrade(OP_BUY, lot);
            LastTradeWasBuy = true;
         }
      }

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

      if (PushNotifications) SendNotification("Trade Alert: " + CommentText);
      if (EmailAlerts) SendMail("Trade Alert", "A new trade has been opened: " + CommentText);
   }
}

bool HasOpenOrder() {
   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber) return true;
      }
   }
   return false;
}

void OpenTrade(int orderType, double lot) {
   double price, sl, tp;
   int ticket;

   if (orderType == OP_BUY) {
      price = NormalizeDouble(Ask, Digits);
      sl = NormalizeDouble(price - StopLoss * Point, Digits);
      tp = NormalizeDouble(price + TakeProfit * Point, Digits);
      ticket = OrderSend(Symbol(), OP_BUY, lot, price, Slippage, sl, tp, CommentText, MagicNumber, 0, clrBlue);
   } else {
      price = NormalizeDouble(Bid, Digits);
      sl = NormalizeDouble(price + StopLoss * Point, Digits);
      tp = NormalizeDouble(price - TakeProfit * Point, Digits);
      ticket = OrderSend(Symbol(), OP_SELL, lot, price, Slippage, sl, tp, CommentText, MagicNumber, 0, clrRed);
   }

   if (ticket < 0) {
      int err = GetLastError();
      Print("OrderSend failed with error #", err);
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
