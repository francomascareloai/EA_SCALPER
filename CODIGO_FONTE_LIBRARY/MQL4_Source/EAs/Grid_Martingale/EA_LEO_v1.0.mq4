//+------------------------------------------------------------------+
//| Input Parameters                                                 |
//+------------------------------------------------------------------+
input double inputStopLoss = 50;   // Stop Loss in points
input double inputTakeProfit = 50; // Take Profit in points
input double inputLotSize = 0.1;   // Lot size

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Initialization
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Deinitialization
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Input parameters for the Moving Averages
   int ma1_length = 200;
   int ma2_length = 200;
   int ma3_length = 20;
   int ma4_length = 20;
   int boll_length = 48;
   double boll_dev = 1.75;

   // Get Moving Averages
   double ma1 = iMA(NULL, 0, ma1_length, 0, MODE_SMA, PRICE_HIGH, 0);
   double ma2 = iMA(NULL, 0, ma2_length, 0, MODE_SMA, PRICE_LOW, 0);
   double ma3 = iMA(NULL, 0, ma3_length, 0, MODE_SMA, PRICE_HIGH, 0);
   double ma4 = iMA(NULL, 0, ma4_length, 0, MODE_SMA, PRICE_LOW, 0);

   // SSL Channel conditions
   static int Hlv1 = 0;
   static int prevHlv1 = 0; // Store previous value of Hlv1
   if (Close[1] > ma1) Hlv1 = 1;
   else if (Close[1] < ma2) Hlv1 = -1;

   static int Hlv2 = 0;
   static int prevHlv2 = 0; // Store previous value of Hlv2
   if (Close[1] > ma3) Hlv2 = 1;
   else if (Close[1] < ma4) Hlv2 = -1;

   // Calculate Stop Loss and Take Profit in price terms
   double stopLossPrice, takeProfitPrice;
   
   // Buy Condition
   if (Hlv1 == 1 && prevHlv1 == -1)
     {
      if (OrdersTotal() == 0) // Check no open orders
        {
         stopLossPrice = Ask - inputStopLoss * Point;
         takeProfitPrice = Ask + inputTakeProfit * Point;
         int buyTicket = OrderSend(Symbol(), OP_BUY, inputLotSize, Ask, 3, stopLossPrice, takeProfitPrice, "SSL Buy", 0, 0, Blue);
         if (buyTicket < 0) Print("Error opening Buy Order: ", GetLastError());
        }
     }

   // Sell Condition
   if (Hlv1 == -1 && prevHlv1 == 1)
     {
      if (OrdersTotal() == 0) // Check no open orders
        {
         stopLossPrice = Bid + inputStopLoss * Point;
         takeProfitPrice = Bid - inputTakeProfit * Point;
         int sellTicket = OrderSend(Symbol(), OP_SELL, inputLotSize, Bid, 3, stopLossPrice, takeProfitPrice, "SSL Sell", 0, 0, Red);
         if (sellTicket < 0) Print("Error opening Sell Order: ", GetLastError());
        }
     }

   // Update previous values for the next tick
   prevHlv1 = Hlv1;
   prevHlv2 = Hlv2;
  }
