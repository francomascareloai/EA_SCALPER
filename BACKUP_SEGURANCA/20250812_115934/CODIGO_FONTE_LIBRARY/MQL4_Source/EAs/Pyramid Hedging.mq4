//+------------------------------------------------------------------+
//|                   XAUUSD_Triangle_Zone_Pyramid_EA.mq4            |
//|                   Created by Grok 3, xAI, March 14, 2025         |
//| Optimized for XAUUSD M1, IC Markets Raw Spread, 500:1 Leverage   |
//+------------------------------------------------------------------+
#property copyright "xAI"
#property link      "https://x.ai"
#property version   "1.00"
#property strict
#property description "Triangle Hedging, Zone Recovery, and Pyramid EA for XAUUSD M1"

//--- Input Parameters
input double BaseLotSize = 0.01;      // Base lot size for initial trades
input double MaxLotSize = 0.50;       // Maximum lot size for pyramiding
input int RecoveryZonePips = 10;      // Recovery zone size in pips
input int TakeProfitPips = 5;         // Take profit in pips
input int StopLossPips = 20;          // Stop loss in pips
input int MaxTrades = 10;             // Maximum number of open trades
input double PyramidMultiplier = 1.5; // Lot size multiplier for pyramid trades
input int MagicNumber = 123456;       // Unique identifier for trades

//--- Global Variables
double point;                         // Point value adjusted for digits
int totalBuyOrders = 0;               // Total buy orders
int totalSellOrders = 0;              // Total sell orders
double lastBuyPrice = 0;              // Last buy price for zone recovery
double lastSellPrice = 0;             // Last sell price for zone recovery

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   point = Point;
   if(Digits == 5 || Digits == 3) point *= 10; // Adjust for 5-digit brokers (IC Markets)
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Cleanup code if needed
}

//+------------------------------------------------------------------+
//| Count open orders by type                                          |
//+------------------------------------------------------------------+
void CountOrders()
{
   totalBuyOrders = 0;
   totalSellOrders = 0;
   
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         {
            if(OrderType() == OP_BUY) totalBuyOrders++;
            if(OrderType() == OP_SELL) totalSellOrders++;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Calculate lot size based on pyramid strategy                       |
//+------------------------------------------------------------------+
double CalculateLotSize(int tradeCount)
{
   double lotSize = BaseLotSize * MathPow(PyramidMultiplier, tradeCount);
   return MathMin(lotSize, MaxLotSize); // Cap at MaxLotSize
}

//+------------------------------------------------------------------+
//| Check if price is in recovery zone                                 |
//+------------------------------------------------------------------+
bool IsInRecoveryZone(double price, double referencePrice, int direction)
{
   if(direction == OP_BUY)
      return price <= (referencePrice - RecoveryZonePips * point);
   else // OP_SELL
      return price >= (referencePrice + RecoveryZonePips * point);
   return false;
}

//+------------------------------------------------------------------+
//| Open a new trade                                                   |
//+------------------------------------------------------------------+
void OpenTrade(int tradeType, double lotSize)
{
   double slPrice, tpPrice;
   double price = (tradeType == OP_BUY) ? Ask : Bid;
   
   if(tradeType == OP_BUY)
   {
      slPrice = price - StopLossPips * point;
      tpPrice = price + TakeProfitPips * point;
   }
   else // OP_SELL
   {
      slPrice = price + StopLossPips * point;
      tpPrice = price - TakeProfitPips * point;
   }
   
   int ticket = OrderSend(Symbol(), tradeType, lotSize, price, 3, slPrice, tpPrice, 
                         "TriangleZonePyramid", MagicNumber, 0, clrGreen);
   if(ticket < 0)
      Print("OrderSend failed with error #", GetLastError());
   else
   {
      if(tradeType == OP_BUY) lastBuyPrice = price;
      else lastSellPrice = price;
   }
}

//+------------------------------------------------------------------+
//| Main trading logic                                                 |
//+------------------------------------------------------------------+
void OnTick()
{
   // Count current open orders
   CountOrders();
   
   // Initial triangle hedging: Open one buy and one sell if no trades exist
   if(totalBuyOrders == 0 && totalSellOrders == 0 && OrdersTotal() < MaxTrades)
   {
      OpenTrade(OP_BUY, BaseLotSize);
      OpenTrade(OP_SELL, BaseLotSize);
      return;
   }
   
   // Zone recovery and pyramiding logic
   double currentPrice = (Bid + Ask) / 2;
   
   // Buy side recovery and pyramid
   if(totalBuyOrders > 0 && totalBuyOrders < MaxTrades)
   {
      if(IsInRecoveryZone(currentPrice, lastBuyPrice, OP_BUY))
      {
         double lotSize = CalculateLotSize(totalBuyOrders);
         OpenTrade(OP_BUY, lotSize);
      }
      else if(currentPrice > lastBuyPrice + TakeProfitPips * point / 2)
      {
         double lotSize = CalculateLotSize(totalBuyOrders);
         OpenTrade(OP_BUY, lotSize); // Pyramid on profit
      }
   }
   
   // Sell side recovery and pyramid
   if(totalSellOrders > 0 && totalSellOrders < MaxTrades)
   {
      if(IsInRecoveryZone(currentPrice, lastSellPrice, OP_SELL))
      {
         double lotSize = CalculateLotSize(totalSellOrders);
         OpenTrade(OP_SELL, lotSize);
      }
      else if(currentPrice < lastSellPrice - TakeProfitPips * point / 2)
      {
         double lotSize = CalculateLotSize(totalSellOrders);
         OpenTrade(OP_SELL, lotSize); // Pyramid on profit
      }
   }
}

//+------------------------------------------------------------------+