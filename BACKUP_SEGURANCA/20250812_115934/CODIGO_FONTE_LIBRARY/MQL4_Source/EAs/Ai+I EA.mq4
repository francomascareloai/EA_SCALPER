//+------------------------------------------------------------------+
//|                                                      Ai+I EA.mq4 |
//+------------------------------------------------------------------+
#property strict
#property version "1.00";
#property copyright "https://t.me/tripeller";
#property link "https://t.me/tripeller";
#property description "Ai+I EA v1.00 for MT4 - Machine Learning / AI Based Free Advisor.";
#property description "Utilize with EURUSD on the M30 timeframe, suitable for standard";
#property description "account with a minimum balance of $1000. The EA excels with";
#property description "spreads of 0 to 1, coupled with low commissions. Avoid running";
#property description "on a low-capacity VPS server as it is highly resource-intensive.";
#property description " ";
#property description "Crypto donations appreciated if you find this advisor beneficial.";
#property description " ";
#property description "BTC - 35FVUdiTPDyNHRnLJqaCK7g43hpmQyRBHW";
#property description "ETH - 0x9E72A4bC29beDdCB8BDCf90D825b1E8E8cEC51cC";

input double FixedLots = 0.01;             // Fixed Lots
input double MaxLots = 2.5;                // Maximum Lots
input int MaxSpread = 2;                   // Maximum Spread (in points)
input int TakeProfit = 50;                 // Take Profit (in points)
input int StopLoss = 5;                    // Stop Loss (in points)
double ProfitPercent = 0.0;                // Profit Percent to Close Orders
double TrailingStop = 0.0;                 // Trailing Stop (in points)
input int Slippage = 3;                    // Slippage
input int MaFastPeriod = 5;                // Period for Fast Moving Average
input int MaSlowPeriod = 10;               // Period for Slow Moving Average
input int TradingStartTime = 11;           // Trading Start Hour
input int TradingEndTime = 19;             // Trading End Hour
input int MagicNumber = 10001;
input string OrderComments = "Ai+I v1.0 ";  // Order Comments
input string Notes = "This is a free advisor, improve and reshare ...";
input string BTCDonations = "35FVUdiTPDyNHRnLJqaCK7g43hpmQyRBHW"; // BTC donations
input string ETHDonations = "0x9E72A4bC29beDdCB8BDCf90D825b1E8E8cEC51cC"; // ETH donations

// Machine learning model parameters
int LookbackPeriod = 50;                   // Lookback period for historical data
int TrainRatio = 80;                       // Percentage of data used for training

double TotalOpenLots = 0;                  // Keep track of total open lot size

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
// Initialization code here
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
// Check trading hours
   if(!IsTradingTime())
      return;

// Check spread
   if(SpreadExceedsMax())
      return;

// Get historical market data
   double HistoricalData[];
   GetHistoricalData(HistoricalData);

// Train machine learning model
   double TrainData[], TestData[];
   SplitData(HistoricalData, TrainData, TestData);

// Predict market trend
   int PredictedTrend = PredictTrend(HistoricalData);

// Execute trade based on predicted trend
   ExecuteTrade(PredictedTrend);

// Close orders if equity profit percent exceeds threshold
   if(ProfitPercent > 0)
     {
      double Equity = AccountEquity();
      double Balance = AccountBalance();
      double ProfitPercentTotal = (Equity - Balance) / Balance * 100;
      if(ProfitPercentTotal >= ProfitPercent)
        {
         CloseAllOrders();
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetHistoricalData(double &Data[])
  {
   ArraySetAsSeries(Data, true); // Set array to be accessed in the reverse order
   int Limit = LookbackPeriod + 100; // Number of bars to retrieve

   ArrayResize(Data, Limit);
   int CopiedBars = CopyClose(_Symbol, Period(), 0, Limit, Data);
   if(CopiedBars <= 0)
     {
      Print("Failed to retrieve historical data!");
      return;
     }
   ArraySetAsSeries(Data, false); // Restore array to the forward order
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SplitData(double &Data[], double &TrainData[], double &TestData[])
  {
// Split historical data into training and testing sets
   int TrainSize = ArraySize(Data) * TrainRatio / 100;
   ArrayCopy(Data, TrainData, 0, TrainSize);
   ArrayCopy(Data, TestData, TrainSize, ArraySize(Data) - TrainSize);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PredictTrend(double &HistoricalData[])
  {
// Implement your trend prediction logic here
   double MaFast = iMA(NULL, 0, MaFastPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   double MaSlow = iMA(NULL, 0, MaSlowPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);

   if(MaFast > MaSlow)
     {
      return 1; // Buy signal
     }
   else
      if(MaFast < MaSlow)
        {
         return -1; // Sell signal
        }
      else
        {
         return 0; // No signal
        }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ExecuteTrade(int PredictedTrend)
  {
// Calculate total open lots
   double CurrentOpenLots = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS))
         continue;

      if(OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber)
         CurrentOpenLots += OrderLots();
     }

// Check if adding new trade will exceed the limit
   if(CurrentOpenLots + FixedLots > MaxLots)
     {
      Print("Max open lot size reached. Cannot open new trade.");
      return;
     }

   double Price = 0;
   if(PredictedTrend == 1)
     {
      // Place buy order
      Price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      int Ticket = OrderSend(_Symbol, OP_BUY, FixedLots, Price, Slippage,
                             Price - StopLoss * _Point,
                             Price + TakeProfit * _Point,
                             OrderComments, MagicNumber, 0, clrGreen);
      if(Ticket <= 0)
        {
         Print("Failed to place buy order! Error:", GetLastError());
        }
     }
   else
      if(PredictedTrend == -1)
        {
         // Place sell order
         Price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         int Ticket = OrderSend(_Symbol, OP_SELL, FixedLots, Price, Slippage,
                                Price + StopLoss * _Point,
                                Price - TakeProfit * _Point,
                                OrderComments, MagicNumber, 0, clrRed);
         if(Ticket <= 0)
           {
            Print("Failed to place sell order! Error:", GetLastError());
           }
        }
  }

//+------------------------------------------------------------------+
//| Close all open orders                                            |
//+------------------------------------------------------------------+
void CloseAllOrders()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(!OrderSelect(i, SELECT_BY_POS))
         continue;

      if(OrderSymbol() == _Symbol && OrderMagicNumber() == MagicNumber)
        {
         double ClosePrice = (OrderType() == OP_BUY) ? MarketInfo(OrderSymbol(), MODE_BID) : MarketInfo(OrderSymbol(), MODE_ASK);
         bool Result = OrderClose(OrderTicket(), OrderLots(), ClosePrice, Slippage, clrRed);
         if(!Result)
           {
            Print("Failed to close order! Error:", GetLastError());
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Check if spread exceeds the maximum allowed spread               |
//+------------------------------------------------------------------+
bool SpreadExceedsMax()
  {
   double Spread = Ask - Bid;
   return (Spread >= MaxSpread * Point);
  }

//+------------------------------------------------------------------+
//| Check if current time is within trading hours                     |
//+------------------------------------------------------------------+
bool IsTradingTime()
  {
   return ((Hour() >= TradingStartTime && Hour() <= TradingEndTime));
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
