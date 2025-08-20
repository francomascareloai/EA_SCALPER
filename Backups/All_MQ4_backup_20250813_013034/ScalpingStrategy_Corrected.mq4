
//+------------------------------------------------------------------+
//|                                                    Scalping.mq4  |
//|                        Generated for Strategy                    |
//+------------------------------------------------------------------+
#property strict

// Input Parameters
input int    SL_Pips     = 20;   // Stop Loss in pips
input int    TP_Pips     = 15;   // Take Profit in pips

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Indicators setup (Note: Fix for accessing indicator values)
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Cleanup code
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double sma5 = iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_CLOSE, 0);
   double heikenAshiOpen = iCustom(NULL, 0, "Heiken_Ashi", 0, 0);
   double heikenAshiClose = iCustom(NULL, 0, "Heiken_Ashi", 3, 0);
   double qqe1 = iCustom(NULL, 0, "QQE", 1, 0);
   double qqe3 = iCustom(NULL, 0, "QQE", 3, 0);
   
   // Conditions for Sell Order
   if(IsSellCondition(sma5, heikenAshiOpen, heikenAshiClose, qqe1, qqe3))
     {
      double price = Ask;
      double sl = price + SL_Pips * Point;
      double tp = price - TP_Pips * Point;
      
      // Place Sell Order with error handling
      int ticket = OrderSend(Symbol(), OP_SELL, 0.1, price, 3, sl, tp, "Sell Order", 0, 0, clrRed);
      if(ticket < 0)
        {
         Print("OrderSend failed with error #", GetLastError());
        }
      else
        {
         Print("Sell Order placed successfully.");
        }
     }
  }
//+------------------------------------------------------------------+
//| Check conditions for Sell Order                                  |
//+------------------------------------------------------------------+
bool IsSellCondition(double sma5, double heikenAshiOpen, double heikenAshiClose, double qqe1, double qqe3)
  {
   // Breakout Confirmation and Indicator logic fix
   if (iClose(NULL, 0, 1) < sma5 && iClose(NULL, 0, 2) > sma5)
     {
      // Heiken Ashi Confirmation
      if (heikenAshiClose < heikenAshiOpen)
        {
         // SMA Tunnel and QQE Alert
         if (sma5 < iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_CLOSE, 1) && qqe1 > qqe3)
           {
            return true;
           }
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
