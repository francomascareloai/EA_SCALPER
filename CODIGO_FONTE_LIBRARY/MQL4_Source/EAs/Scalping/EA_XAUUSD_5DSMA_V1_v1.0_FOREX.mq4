//+------------------------------------------------------------------+
//| Expert Advisor: XAUUSD_5DSMA_V1.mq4                              |
//| Strategy : Buy-only, trend-following grid with ATR-based logic   |
//| Timeframe: M15                                                   |
//| Platform : MT4                                                   |
//+------------------------------------------------------------------+
#property copyright "Semilogic Corporation"
#property link      "https://www.semilogic.ca"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Includes and object initialization                               |
//+------------------------------------------------------------------+

enum MAXDD_MODE {
   MAXDD_UNUSED,             // Max DD not used
   MAXDD_CLOSE_AND_STOP,     // Max DD close and stop trading
   MAXDD_LOCK_AND_STOP,      // Max DD lock and stop trading
};


//+------------------------------------------------------------------+
//| Input variables                                                  |
//+------------------------------------------------------------------+
input double   ATR_Multiplier = 0.5;       // Grid spacing multiplier of ATR
input int      Grid_Orders = 5;            // Number of buy grid entries
input double   RSI_Buy_Level = 45.0;       // RSI Buy Level
input double   Trail_ATR_Multiplier = 5.5; // Trailing stop multiplier of ATR
input double   SMA_Angle_Min = -6;         // Minimum angle (degrees) to enter
input int      ATR_Period = 14;            // ATR period
input double   Minimum_ATR_Threshold = 3.0;// Minimum ATR threshold
input int      MagicNumber = 12345;        // Magic Number
input int      Slippage = 5;               // Slippage
input int      SlopeBarsBack = 4;          // Slope bars for 1 hour delay
input int      SMA_Bars = 460;             // 5 days worth of M15 data
input double   StartTradingHour = 9;       // Start trading hour
input double   EndTradingHour = 20;        // End trading hour
input bool     UseDynamicLotSize = true;   // Use dynamic lot size
input double   FixedLotSize = 0.01;        // Fixed lot size per trade
input double   RiskPercentage = 5.0;       // Lot size by risk percentage
input MAXDD_MODE MaxDDMode = MAXDD_CLOSE_AND_STOP; // Max DD Mode
input double   MaxDrawdown = 20.0;         // Max DD percentage


//+------------------------------------------------------------------+
//| Global variable and indicators                                   |
//+------------------------------------------------------------------+
datetime new_bar;
bool confirmation_up;
bool confirmation_dn;
double confirmation_price;
bool trading_disabled;

//+------------------------------------------------------------------+
//| Calculate the used lot size                                      |
//+------------------------------------------------------------------+
double CalculateLotSize(double riskPercent, double stopLossPips) {
   double baseLot;
   if(UseDynamicLotSize) {
      double riskMoney = AccountBalance() * (riskPercent / 100.0);
      double lotSize = riskMoney / (stopLossPips * MarketInfo(Symbol(), MODE_TICKVALUE));
      baseLot = lotSize;
   } else {
      baseLot = FixedLotSize;
   }
   // Ensures that the volume is within the broker's limits
   if(baseLot < MarketInfo(Symbol(), MODE_MINLOT))
      baseLot = MarketInfo(Symbol(), MODE_MINLOT);
   if(baseLot > MarketInfo(Symbol(), MODE_MAXLOT))
      baseLot = MarketInfo(Symbol(), MODE_MAXLOT);
   return NormalizeDouble(baseLot, 2);
}

//+------------------------------------------------------------------+
//| Calculate real 5-day SMA                                         |
//+------------------------------------------------------------------+
double GetRealSMA(int barsBack, int shift) {
   double sum = 0;
   for (int i = shift; i < barsBack + shift; i++)
      sum += iClose(Symbol(), PERIOD_M15, i);
   return sum / barsBack;
}

//+------------------------------------------------------------------+
//| Calculate SMA Slope Angle                                        |
//+------------------------------------------------------------------+
double GetSMAAngle(int barsBack) {
   double current = GetRealSMA(SMA_Bars, 1); // 5-day SMA, now
   double previous = GetRealSMA(SMA_Bars, 1+barsBack); // 5-day SMA, 1h ago
   double deltaY = current - previous;
   double deltaX = barsBack;
   double angle = MathArctan(deltaY / deltaX);
   angle = angle * 180 / M_PI;
   return angle;
}

//+------------------------------------------------------------------+
//| Calculate current ATR                                            |
//+------------------------------------------------------------------+
double GetATR(int shift) {
   return iATR(Symbol(), PERIOD_M30, ATR_Period, shift);
}

//+------------------------------------------------------------------+
//| Check for the lower open price                                   |
//+------------------------------------------------------------------+
double LowerOpenBuyPrice() {
   double price = 0;
   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY)
            if(price==0) {
               price = OrderOpenPrice();
            } else {
               if(OrderOpenPrice()<price) price = OrderOpenPrice();
            }
      }
   }
   return price;
}

//+------------------------------------------------------------------+
//| Check for existing buy trades                                    |
//+------------------------------------------------------------------+
int HasOpenBuyTrades() {
   int orders = 0;
   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY)
            orders = orders + 1;
      }
   }
   return orders;
}

//+------------------------------------------------------------------+
//| Place grid of buy orders                                         |
//+------------------------------------------------------------------+
int PlaceBuyGrid(double basePrice, double atr) {   
   int ticket;
   double lowest_open_price = LowerOpenBuyPrice();
   double lot = CalculateLotSize(RiskPercentage, (atr*Trail_ATR_Multiplier)/Point());
   if(lowest_open_price==0) {
      // no orders yet
      ticket = OrderSend(Symbol(), OP_BUY, lot, basePrice, Slippage, 0, 0, "First Buy", MagicNumber, 0, clrBlue);
   } else {
      double price = lowest_open_price - atr * ATR_Multiplier;
      ticket = OrderSend(Symbol(), OP_BUY, lot, price, Slippage, 0, 0, "Grid Buy", MagicNumber, 0, clrBlue);
   }
   return ticket;
}

//+------------------------------------------------------------------+
//| Manage Trailing Stop                                             |
//+------------------------------------------------------------------+
void ManageTrailingStops(double atr) {
   for (int i = 0; i < OrdersTotal(); i++) {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber && OrderType() == OP_BUY) {
            double newStop = Bid - atr * Trail_ATR_Multiplier;
            if (newStop > OrderStopLoss()) {
               bool ret = OrderModify(OrderTicket(), OrderOpenPrice(), newStop, 0, 0, clrGreen);
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Expert initialization                                            |
//+------------------------------------------------------------------+
int OnInit() {
   new_bar = Time[0];
   confirmation_up = false;
   confirmation_dn = false;
   confirmation_price = 0;
   trading_disabled = false;
   if(MaxDDMode == MAXDD_LOCK_AND_STOP) {
      double buy_lots = CountOrderLots(OP_BUY);
      double sell_lots = CountOrderLots(OP_SELL);
      if((buy_lots == sell_lots) && (buy_lots > 0)) {
         trading_disabled = true;
      }
   }
   Print("XAUUSD 5DSMA EA initialized.");
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   Print("XAUUSD 5DSMA EA deinitialized.");
}

//+------------------------------------------------------------------+
//| Expert tick                                                      |
//+------------------------------------------------------------------+
void OnTick() {
   double atr1 = GetATR(1);
   if(new_bar != Time[0]) {
      new_bar = Time[0];
      double sma1 = GetRealSMA(SMA_Bars, 1);
      double sma2 = GetRealSMA(SMA_Bars, 2);
      if(Ask > sma1) {
         if(!confirmation_up) {
            if(Close[2]>sma2 && Close[1]>High[2]) {
               confirmation_up=true;
               confirmation_dn=false;
               confirmation_price = Ask;
            }
         }
      }
      if(Ask < sma1) {
         if(!confirmation_dn) {
            if(Close[2]<sma2 && Close[1]<Low[2]) {
               confirmation_dn=true;
               confirmation_up=false;
               confirmation_price = 0;
            }
         }
      }
      
      double slope1 = GetSMAAngle(SlopeBarsBack);
      if (confirmation_up && (Ask <= confirmation_price || Ask < (sma1 + atr1) )&& slope1 >= SMA_Angle_Min && atr1 >= Minimum_ATR_Threshold && HasOpenBuyTrades() < Grid_Orders) {
         if(Hour()>=StartTradingHour && Hour()<=EndTradingHour) {
            if(!trading_disabled) PlaceBuyGrid(Ask, atr1);
         }
      }
   } else {
      if(CountOrders(-1)>0) {
         double sma1 = GetRealSMA(SMA_Bars, 0);
         if (confirmation_up && Ask < (sma1 + atr1) && HasOpenBuyTrades() < Grid_Orders) {
            if(Hour()>=StartTradingHour && Hour()<=EndTradingHour) {
               if(!trading_disabled) PlaceBuyGrid(Ask, atr1);
            }
         }
      }
   }
   ManageTrailingStops(atr1);
   
   // max DD check
   if(MaxDDMode != MAXDD_UNUSED) {      
      double currentDD = 100.0 * (AccountBalance() - AccountEquity()) / AccountBalance();
      if (currentDD >= MaxDrawdown) {
         if(MaxDDMode == MAXDD_CLOSE_AND_STOP) {      
            // close all open orders and stop trading
            trading_disabled = true;
            CloseAllOrders();
         }
         if(MaxDDMode == MAXDD_LOCK_AND_STOP) {      
            // lock open orders and stop trading
            trading_disabled = true;
            LockAllOrders();
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Close all open orders                                            |
//+------------------------------------------------------------------+
int CloseAllOrders() {
   int closedOrders = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == MagicNumber) {
         if(OrderSymbol() == Symbol()) {
            if(OrderType() == OP_BUY) {
               if(OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_BID), (int)MarketInfo(OrderSymbol(), MODE_SPREAD), Blue)) {
                  closedOrders++;
               }
            } else if(OrderType() == OP_SELL) {
               if(OrderClose(OrderTicket(), OrderLots(), MarketInfo(OrderSymbol(), MODE_ASK), (int)MarketInfo(OrderSymbol(), MODE_SPREAD), Red)) {
                  closedOrders++;
               }
            } else if(OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP) {
               if(OrderDelete(OrderTicket())) {
                  closedOrders++;
               }
            }
         }
      }
   }
   return closedOrders;
}

//+------------------------------------------------------------------+
//| Count orders by order type                                       |
//+------------------------------------------------------------------+
int CountOrders(int order_type) {
   int count = 0;
   for(int idx = 0; idx < OrdersTotal(); idx++) {
      if (OrderSelect(idx, 0, 0) && Symbol() == OrderSymbol() && MagicNumber == OrderMagicNumber()) {
         if (order_type == -1 || OrderType() == order_type) {
            count = count + 1;
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| Count lot size by order type                                     |
//+------------------------------------------------------------------+
double CountOrderLots(int order_type) {
   double lots = 0;
   for(int idx = 0; idx < OrdersTotal(); idx++) {
      if (OrderSelect(idx, 0, 0) && OrderMagicNumber() == MagicNumber) {
         if (OrderType() == order_type || order_type == -1) {
            lots = (lots + OrderLots());
         }
      }
   }
   return lots;
}

//+------------------------------------------------------------------+
//| Lock all orders by opposite open order to balance the used lots  |
//+------------------------------------------------------------------+
void LockAllOrders() {
   int ticket;
   double buy_lots = CountOrderLots(OP_BUY);
   double sell_lots = CountOrderLots(OP_SELL);
   if(buy_lots == sell_lots) {
      // already done, exit
      return;
   }
   if(buy_lots > sell_lots) {
      // it needs more sell lots
      ticket = OrderSend(Symbol(), OP_SELL, buy_lots - sell_lots, Bid, Slippage, 0, 0, "Lock Sell", MagicNumber, 0, clrBlue);
      return;
   }
   if(buy_lots < sell_lots) {
      // it needs more buy lots
      ticket = OrderSend(Symbol(), OP_BUY, sell_lots - buy_lots, Ask, Slippage, 0, 0, "Lock Buy", MagicNumber, 0, clrBlue);
      return;
   }
}