#property copyright "Grok, xAI"
#property link      "https://x.ai"
#property version   "1.00"

// Input parameters
input double LotSize = 0.01;        // Fixed lot size for each trade
input int GridSpacing = 15;         // Grid spacing in pips
input int ProfitTargetPips = 10;    // Profit target per trade in pips
input int MaxTrades = 5;            // Maximum number of open trades in the grid
input int MAPeriod = 20;            // Moving average period for trend direction

// Global variables
double gridLevelBuy = 0;            // Last buy grid level
double gridLevelSell = 0;           // Last sell grid level
int buyCount = 0;                   // Number of open buy trades
int sellCount = 0;                  // Number of open sell trades
double point;                       // Point value for the symbol

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   // Calculate point value for the symbol
   point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if (_Digits == 3 || _Digits == 5) point *= 10; // Adjust for 3 or 5 digit brokers
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                               |
//+------------------------------------------------------------------+
void OnTick()
{
   // Get current price
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   // Calculate moving average for trend direction
   double ma = iMA(_Symbol, PERIOD_CURRENT, MAPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
   bool isBullish = ask > ma; // Trend is bullish if price is above MA
   bool isBearish = bid < ma; // Trend is bearish if price is below MA

   // Count open trades and reset grid levels if no trades in that direction
   buyCount = 0;
   sellCount = 0;
   for (int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if (PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol)
      {
         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) buyCount++;
         else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) sellCount++;
      }
   }

   // Reset grid levels if no open trades in that direction
   if (buyCount == 0) gridLevelBuy = 0;
   if (sellCount == 0) gridLevelSell = 0;

   // Grid trading logic for buys
   if (isBullish && buyCount < MaxTrades)
   {
      // If no buy trades, set the first grid level
      if (buyCount == 0)
      {
         gridLevelBuy = ask;
         OpenBuyTrade(ask);
      }
      // If price has moved down by GridSpacing pips, open another buy
      else if (ask <= gridLevelBuy - GridSpacing * point)
      {
         gridLevelBuy = ask;
         OpenBuyTrade(ask);
      }
   }

   // Grid trading logic for sells
   if (isBearish && sellCount < MaxTrades)
   {
      // If no sell trades, set the first grid level
      if (sellCount == 0)
      {
         gridLevelSell = bid;
         OpenSellTrade(bid);
      }
      // If price has moved up by GridSpacing pips, open another sell
      else if (bid >= gridLevelSell + GridSpacing * point)
      {
         gridLevelSell = bid;
         OpenSellTrade(bid);
      }
   }

   // Check for profit targets and close trades
   CloseProfitableTrades();
}

//+------------------------------------------------------------------+
//| Open a buy trade                                                   |
//+------------------------------------------------------------------+
void OpenBuyTrade(double price)
{
   MqlTradeRequest request = {0};
   MqlTradeResult result = {0};

   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = LotSize;
   request.type = ORDER_TYPE_BUY;
   request.price = price;
   request.deviation = 10; // Slippage in points
   request.magic = 123456; // Magic number for identification

   if (!OrderSend(request, result))
   {
      Print("Buy order failed: ", result.retcode);
   }
}

//+------------------------------------------------------------------+
//| Open a sell trade                                                  |
//+------------------------------------------------------------------+
void OpenSellTrade(double price)
{
   MqlTradeRequest request = {0};
   MqlTradeResult result = {0};

   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = LotSize;
   request.type = ORDER_TYPE_SELL;
   request.price = price;
   request.deviation = 10; // Slippage in points
   request.magic = 123456; // Magic number for identification

   if (!OrderSend(request, result))
   {
      Print("Sell order failed: ", result.retcode);
   }
}

//+------------------------------------------------------------------+
//| Close trades that have reached the profit target                   |
//+------------------------------------------------------------------+
void CloseProfitableTrades()
{
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

   for (int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if (PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol)
      {
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double profitPips = 0;

         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
         {
            profitPips = (bid - openPrice) / point;
            if (profitPips >= ProfitTargetPips)
            {
               ClosePosition(ticket);
            }
         }
         else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
         {
            profitPips = (openPrice - ask) / point;
            if (profitPips >= ProfitTargetPips)
            {
               ClosePosition(ticket);
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Close a position by ticket                                         |
//+------------------------------------------------------------------+
void ClosePosition(ulong ticket)
{
   MqlTradeRequest request = {0};
   MqlTradeResult result = {0};

   request.action = TRADE_ACTION_DEAL;
   request.position = ticket;
   request.symbol = _Symbol;
   request.volume = PositionGetDouble(POSITION_VOLUME);
   request.type = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
   request.price = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_BID) : SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   request.deviation = 10;

   if (!OrderSend(request, result))
   {
      Print("Close order failed: ", result.retcode);
   }
}