//+------------------------------------------------------------------+
//| Expert Advisor: XAUUSD_ATR_TrendGrid.mq4                         |
//| Strategy : Buy-only, trend-following grid with ATR-based logic   |
//| Timeframe: M15                                                   |
//| Platform : MT4                                                   |
//+------------------------------------------------------------------+
#property strict

//---- input parameters
input double   ATR_Multiplier = 0.5;       // Grid spacing multiplier of ATR
input int      Grid_Orders = 5;            // Number of buy grid entries
input double   RSI_Buy_Level = 45.0;       // RSI Buy Level
input double   Trail_ATR_Multiplier = 5.5; // Trailing stop multiplier of ATR
input double   SMA_Angle_Min = -6;         // Minimum angle (degrees) to enter
input int      ATR_Period = 14;            // ATR period
input double   LotSize = 0.01;             // Fixed lot size per trade
input int      MagicNumber = 12345;        // Magic Number
input int      Slippage = 5;               // Slippage
input int      SlopeBarsBack = 4;          // Slope bars for 1 hour delay
input int      SMA_Bars = 460;             // 5 days worth of M15 data

datetime new_bar;
bool confirmation_up;
bool confirmation_dn;
double confirmation_price;

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
   if(lowest_open_price==0) {
      // no orders yet
      ticket = OrderSend(Symbol(), OP_BUY, LotSize, basePrice, Slippage, 0, 0, "First Buy", MagicNumber, 0, clrBlue);
   } else {
      double price = lowest_open_price - atr * ATR_Multiplier;
      ticket = OrderSend(Symbol(), OP_BUY, LotSize, price, Slippage, 0, 0, "Grid Buy", MagicNumber, 0, clrBlue);
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
   Print("XAUUSD ATR Trend Grid EA initialized.");
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   Print("XAUUSD ATR Trend Grid EA deinitialized.");
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
      if(!confirmation_up) {
            if(Close[2]>sma2 && Close[1]>High[2]) {
               confirmation_up=true;
               confirmation_dn=false;
               confirmation_price = Ask;
            }
      }
      if(!confirmation_dn) {
            if(Close[2]<sma2 && Close[1]<Low[2]) {
               confirmation_dn=true;
               confirmation_up=false;
               confirmation_price = 0;
            }
      }
      
      double slope1 = GetSMAAngle(SlopeBarsBack);
      double rsi1 =iRSI(Symbol(),PERIOD_M15,14,PRICE_CLOSE,1);
      if (confirmation_up && Ask <= confirmation_price && slope1 >= SMA_Angle_Min && rsi1 <= RSI_Buy_Level && HasOpenBuyTrades() < Grid_Orders) {
         PlaceBuyGrid(Ask, atr1);
      }
   }
   ManageTrailingStops(atr1);
}
