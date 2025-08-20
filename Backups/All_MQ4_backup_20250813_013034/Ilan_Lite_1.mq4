//----------------------------------+
extern double TakeProfit = 10;
extern double StartLot = 0.1;
extern double LotExponent = 1.5;
extern double LotStep = 30;
extern int MaxTrades = 10;
int Magic = 12345;
//----------------------------------+
int PrevTime = 0, cnt = 0, Ticket;
bool TradeNow = FALSE, LongTrade = FALSE, ShortTrade = FALSE, NewOrdersPlaced = FALSE, Flag;
//----------------------------------+
int init() {
   WindowRedraw();
   return (0);
}
//----------------------------------+
int deinit() {
   ObjectsDeleteAll();
   return (0);
}
//----------------------------------+
int start() {
//----------------------------------+
   double B = AccountEquity(), C = AccountBalance();
   color Color;
   if (B < C) Color = Yellow;
   if (B > C) Color = Lime; 
   ObjectCreate("A", OBJ_LABEL, 0, 0, 0);
   ObjectSet("A", OBJPROP_CORNER, 3);
   ObjectSet("A", OBJPROP_XDISTANCE, 25);
   ObjectSet("A", OBJPROP_YDISTANCE, 60);
   ObjectSetText("A", ""+OrdersTotal()+"", 12, "Courier", OrangeRed);
   ObjectCreate("B", OBJ_LABEL, 0, 0, 0);
   ObjectSet("B", OBJPROP_CORNER, 3);
   ObjectSet("B", OBJPROP_XDISTANCE, 25);
   ObjectSet("B", OBJPROP_YDISTANCE, 40);
   ObjectSetText("B", ""+DoubleToStr(AccountEquity(), 2)+"", 12, "Courier", Color);
   ObjectCreate("C", OBJ_LABEL, 0, 0, 0);
   ObjectSet("C", OBJPROP_CORNER, 3);
   ObjectSet("C", OBJPROP_XDISTANCE, 25);
   ObjectSet("C", OBJPROP_YDISTANCE, 20);
   ObjectSetText("C", ""+DoubleToStr(AccountBalance(), 2)+"", 12, "Courier", Lime);
//----------------------------------+
   if (PrevTime == Time[0]) return (0);
      PrevTime = Time[0];
//----------------------------------+
   if (CountTrades() == 0) Flag = FALSE;
   for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
         if (OrderType() == OP_BUY) {
            LongTrade = TRUE;
            ShortTrade = FALSE;
         }
      }
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
         if (OrderType() == OP_SELL) {
            LongTrade = FALSE;
            ShortTrade = TRUE;
         }
      }
   }
//----------------------------------+
   if (CountTrades() > 0 && CountTrades() <= MaxTrades) {
      if (LongTrade && LastPrice() - Ask >= LotStep * Point) TradeNow = TRUE;
      if (ShortTrade && Bid - LastPrice() >= LotStep * Point) TradeNow = TRUE;
   }
//----------------------------------+
   if (CountTrades() < 1) {
      LongTrade = FALSE;
      ShortTrade = FALSE;
      TradeNow = TRUE;
   }
//----------------------------------+
   if (TradeNow) {
      if (ShortTrade) {
         Ticket = OrderSend(Symbol(), OP_SELL, Lots(StartLot), NormalizeDouble(Bid, Digits), 3, 0, 0, NULL, Magic, Red);
         TradeNow = FALSE;
         NewOrdersPlaced = TRUE;
      }
      if (LongTrade) {
         Ticket = OrderSend(Symbol(), OP_BUY, Lots(StartLot), NormalizeDouble(Ask, Digits), 3, 0, 0, NULL, Magic, Blue);
         TradeNow = FALSE;
         NewOrdersPlaced = TRUE;
      }
   }
//----------------------------------+
   if (TradeNow && CountTrades() < 1) {
      double PrevCl = iClose(Symbol(), 0, 2);
      double CurrCl = iClose(Symbol(), 0, 1);
      if (!ShortTrade && !LongTrade) {
         if (PrevCl > CurrCl) {
            Ticket = OrderSend(Symbol(), OP_SELL, Lots(StartLot), NormalizeDouble(Bid, Digits), 3, 0, 0, NULL, Magic, Red);
            TradeNow = FALSE;
            NewOrdersPlaced = TRUE;
         }
         if (PrevCl < CurrCl) {
            Ticket = OrderSend(Symbol(), OP_BUY, Lots(StartLot), NormalizeDouble(Ask, Digits), 3, 0, 0, NULL, Magic, Blue);
            TradeNow = FALSE;
            NewOrdersPlaced = TRUE;
         }
      }
   }
//----------------------------------+
   double AveragePrice;
   double Count;
   for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
         AveragePrice += OrderOpenPrice() * OrderLots();
         Count += OrderLots();
      }
   }
   if (CountTrades() > 0) AveragePrice = AveragePrice / Count;
//----------------------------------+
   if (NewOrdersPlaced) {
      double PriceTarget;
      for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
         OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
            if (OrderType() == OP_BUY) {
               PriceTarget = AveragePrice + TakeProfit * Point;
               Flag = TRUE;
            }
         }
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
            if (OrderType() == OP_SELL) {
               PriceTarget = AveragePrice - TakeProfit * Point;
               Flag = TRUE;
            }
         }
      }
      if (Flag == TRUE) {
         for (cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
            OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) OrderModify(OrderTicket(), 0, 0, PriceTarget, Yellow);
            NewOrdersPlaced = FALSE;
         }
      }
   }
   return (0);
}
//----------------------------------+
double Lots(double StartLot) {
   double Lots;
      Lots = StartLot * MathPow(LotExponent, CountTrades());
   if (AccountFreeMarginCheck(Symbol(), OrderType(), Lots) <= 0) {
      Print("NOT ENOUGH MONEY");
      return (-1);
   }  
   return (Lots);
}
//----------------------------------+
int CountTrades() {
   int Count;
   for (int Trade = OrdersTotal() - 1; Trade >= 0; Trade--) {
      OrderSelect(Trade, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) Count++;
   }
   return (Count);
}
//----------------------------------+
double LastPrice() {
   double OrderPrice;
   int OldTicket;
   for (int cnt = OrdersTotal() - 1; cnt >= 0; cnt--) {
      OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
         if (OrderTicket() > OldTicket) {
            OrderPrice = OrderOpenPrice();
            OldTicket = OrderTicket();
         }
      }
   }
   return (OrderPrice);
}
//----------------------------------+
//END//