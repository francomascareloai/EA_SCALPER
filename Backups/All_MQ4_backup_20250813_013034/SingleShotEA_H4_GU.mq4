//+------------------------------------------------------------------+
//|                                               AtamSuperFree_EA_v5.mq4|
//|                        Copyright 2024, AtamSuper EA Free         |
//|                                       http://www.AtamSuper.com |
//|                                       contact +60102888xxx |
//+------------------------------------------------------------------+

#property strict

// Input parameters
input int period_5 = 5;         // Period for the first moving average
input int period_10 = 10;        // Period for the second moving average
input int period_50 = 50;        // Period for the third moving average
input double lotSize = 0.1;      // Lot size for trading
input int takeProfit = 100;      // Take profit in points
input int stopLoss = 50;         // Stop loss in points

// Global variables
int maCrossBuy = 0;                // 1 when buy condition is met
int maCrossSell = 0;               // -1 when sell condition is met

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Initialize the MA crosses
   maCrossBuy = 0;
   maCrossSell = 0;

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Calculate the first LWMA for high prices
   double lwmaHigh_5 = iMA(Symbol(), 0, period_5, 0, MODE_LWMA, PRICE_HIGH, 0);
   // Calculate the second LWMA for high prices
   double lwmaHigh_10 = iMA(Symbol(), 0, period_10, 0, MODE_LWMA, PRICE_HIGH, 0);
   // Calculate the first LWMA for low prices
   double lwmaLow_5 = iMA(Symbol(), 0, period_5, 0, MODE_LWMA, PRICE_LOW, 0);
   // Calculate the second LWMA for low prices
   double lwmaLow_10 = iMA(Symbol(), 0, period_10, 0, MODE_LWMA, PRICE_LOW, 0);
   // Calculate the EMA for close prices
   double emaClose_50 = iMA(Symbol(), 0, period_50, 0, MODE_EMA, PRICE_CLOSE, 0);
   
   // Check for existing open positions
   if (OrdersTotal() > 0) 
   {
      return;
   }

   // Check for buy condition
   if (Low[0] <= lwmaLow_5 && Low[0] <= lwmaLow_10 && Close[0] > emaClose_50 && maCrossBuy != 1)
     {
      maCrossBuy = 1;
      // Open buy order
      double sl = Ask - stopLoss * Point;
      double tp = Ask + takeProfit * Point;
      OrderSend(Symbol(), OP_BUY, lotSize, Ask, 3, sl, tp, "Buy Order", 0, 0, clrLime);
     }
   // Check for sell condition
   else if (High[0] >= lwmaHigh_5 && High[0] >= lwmaHigh_10 && Close[0] < emaClose_50 && maCrossSell != -1)
     {
      maCrossSell = -1;
      // Open sell order
      double sl = Bid + stopLoss * Point;
      double tp = Bid - takeProfit * Point;
      OrderSend(Symbol(), OP_SELL, lotSize, Bid, 3, sl, tp, "Sell Order", 0, 0, clrRed);
     }
  }

//+------------------------------------------------------------------+
//| Expert function to handle order events                           |
//+------------------------------------------------------------------+
 void OnTrade()
{
    // Check for closed orders
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (!OrderSelect(i, SELECT_BY_POS))
        {
            Print("Error selecting order ", GetLastError());
            continue;
        }
        // If the order is closed, reset the corresponding flag
        if (OrderCloseTime() > 0)
        {
            if (OrderType() == OP_BUY)
                maCrossBuy = 0;
            else if (OrderType() == OP_SELL)
                maCrossSell = 0;
        }
    }

    // Reset flags to allow new trades
    if (OrdersTotal() == 0)
    {
        maCrossBuy = 0;
        maCrossSell = 0;
    }
}
