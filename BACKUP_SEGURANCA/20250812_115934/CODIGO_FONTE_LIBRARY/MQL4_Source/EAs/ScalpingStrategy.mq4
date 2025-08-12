
//+------------------------------------------------------------------+
//|                                                    Scalping.mq4  |
//|                        Generated for Strategy                    |
//+------------------------------------------------------------------+
#property strict

// Input Parameters
input int    SL_Pips     = 20;   // Stop Loss in pips
input int    TP_Pips     = 15;   // Take Profit in pips

// Indicators
double sma5[], heikenAshiOpen[], heikenAshiClose[], qqe1[], qqe3[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Indicators setup
   SetIndexBuffer(0, sma5);
   SetIndexBuffer(1, heikenAshiOpen);
   SetIndexBuffer(2, heikenAshiClose);
   SetIndexBuffer(3, qqe1);
   SetIndexBuffer(4, qqe3);
   
   // Initialize indicators
   sma5 = iMA(NULL, 0, 5, 0, MODE_SMA, PRICE_CLOSE, 0);
   heikenAshiOpen = iCustom(NULL, 0, "Heiken_Ashi", 0, 0);
   heikenAshiClose = iCustom(NULL, 0, "Heiken_Ashi", 3, 0);
   qqe1 = iCustom(NULL, 0, "QQE", 1, 0);
   qqe3 = iCustom(NULL, 0, "QQE", 3, 0);
   
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
   // Conditions for Sell Order
   if(IsSellCondition())
     {
      double price = Ask;
      double sl = price + SL_Pips * Point;
      double tp = price - TP_Pips * Point;
      
      // Place Sell Order
      OrderSend(Symbol(), OP_SELL, 0.1, price, 3, sl, tp, "Sell Order", 0, 0, clrRed);
     }
  }
//+------------------------------------------------------------------+
//| Check conditions for Sell Order                                  |
//+------------------------------------------------------------------+
bool IsSellCondition()
  {
   // Breakout Confirmation
   if (iClose(NULL, 0, 1) < sma5[1] && iClose(NULL, 0, 2) > sma5[2])
     {
      // Heiken Ashi Confirmation
      if (heikenAshiClose[1] < heikenAshiOpen[1])
        {
         // SMA Tunnel and QQE Alert
         if (sma5[0] < sma5[1] && qqe1[0] > qqe3[0])
           {
            return true;
           }
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
