//+------------------------------------------------------------------+
//|                                       Nasdaq Fundamental EA V2.mq5 |
//|                                           Nasdaq Fundamental EA V2.|
//|                                             https://www.nasdaq.com |
//+------------------------------------------------------------------+
#property copyright "Nasdaq Fundamental EA V2."
#property link  "https://www.ctg.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   // Initialization logic here if needed
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   // Cleanup tasks if needed
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   // Define the lot size
   double lotSize = 0.01;
   
   // Detect HH or LL condition
   bool isNewHH = IsNewHigherHigh();
   bool isNewLL = IsNewLowerLow();
   
   if (isNewHH)
     {
      // Open a buy trade
      OpenBuyTrade(lotSize);
     }
   else if (isNewLL)
     {
      // Open a sell trade
      OpenSellTrade(lotSize);
     }
  }
//+------------------------------------------------------------------+
//| Function to check if a new Higher High (HH) is formed             |
//+------------------------------------------------------------------+
bool IsNewHigherHigh()
  {
   // Check if the previous high is lower than the current high
   double prevHigh = iHigh(Symbol(), PERIOD_M1, 1); // Use iHigh to get high of the previous bar
   double currentHigh = iHigh(Symbol(), PERIOD_M1, 0); // Use iHigh to get high of the current bar
   
   // Return true if the current high is higher than the previous one
   return currentHigh > prevHigh;
  }
//+------------------------------------------------------------------+
//| Function to check if a new Lower Low (LL) is formed               |
//+------------------------------------------------------------------+
bool IsNewLowerLow()
  {
   // Check if the previous low is higher than the current low
   double prevLow = iLow(Symbol(), PERIOD_M1, 1); // Use iLow to get low of the previous bar
   double currentLow = iLow(Symbol(), PERIOD_M1, 0); // Use iLow to get low of the current bar
   
   // Return true if the current low is lower than the previous one
   return currentLow < prevLow;
  }
//+------------------------------------------------------------------+
//| Function to open a Buy trade                                      |
//+------------------------------------------------------------------+
void OpenBuyTrade(double lotSize)
  {
   // Create an instance of the trade class
   MqlTradeRequest request = {};
   MqlTradeResult result = {};
   
   // Set the trade request parameters for buying
   request.action = TRADE_ACTION_DEAL;
   request.symbol = Symbol();
   request.volume = lotSize;
   request.type = ORDER_TYPE_BUY;
   request.price = SymbolInfoDouble(Symbol(), SYMBOL_ASK); // Get current Ask price
   request.deviation = 10;  // Allowed slippage in points
   request.magic = 123456;
   request.comment = "Buy on HH";
   request.type_filling = ORDER_FILLING_FOK;  // Immediate or cancel
   request.type_time = ORDER_TIME_GTC;        // Good 'til canceled
   
   // Send the order
   if (!OrderSend(request, result))
     {
      // Handle error if order failed
      Print("Error opening buy order: ", GetLastError());
      return;
     }
   else
     {
      Print("Buy order opened successfully. Ticket: ", result.order);
     }
  }
//+------------------------------------------------------------------+
//| Function to open a Sell trade                                     |
//+------------------------------------------------------------------+
void OpenSellTrade(double lotSize)
  {
   // Create an instance of the trade class
   MqlTradeRequest request = {};
   MqlTradeResult result = {};
   
   // Set the trade request parameters for selling
   request.action = TRADE_ACTION_DEAL;
   request.symbol = Symbol();
   request.volume = lotSize;
   request.type = ORDER_TYPE_SELL;
   request.price = SymbolInfoDouble(Symbol(), SYMBOL_BID); // Get current Bid price
   request.deviation = 10;  // Allowed slippage in points
   request.magic = 123456;
   request.comment = "Sell on LL";
   request.type_filling = ORDER_FILLING_FOK;  // Immediate or cancel
   request.type_time = ORDER_TIME_GTC;        // Good 'til canceled
   
   // Send the order
   if (!OrderSend(request, result))
     {
      // Handle error if order failed
      Print("Error opening sell order: ", GetLastError());
      return;
     }
   else
     {
      Print("Sell order opened successfully. Ticket: ", result.order);
     }
  }
//+------------------------------------------------------------------+
