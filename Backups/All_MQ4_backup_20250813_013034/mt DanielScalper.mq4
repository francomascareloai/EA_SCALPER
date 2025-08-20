#property copyright "Matt Todorovski 2025"
#property link      "https://x.ai"
#property description "Shared as freeware in Free Forex Robots on Telegram"
#property version   "1.01"
#property strict

input double LotSize = 0.01;
input int GridSpacing = 15;
input int MaxTrades = 5;
input int BBPeriod = 20;
input double BBDeviationOuter = 2.0;
input double BBDeviationInner = 1.0;
input int MinPinBarWickPips = 10;
input int SwingLookback = 5; // Lookback period for swing low/high
input string TradeComment = "DanielScalper";
input int Magic = 202503261;

double gridLevelBuy, gridLevelSell, point;
int buyCount, sellCount;

int init()
{
   point = Point;
   if (Digits == 3 || Digits == 5) point *= 10;
   return(0);
}

void OnTick()
{
   double bid = MarketInfo(Symbol(), MODE_BID), ask = MarketInfo(Symbol(), MODE_ASK);
   double bbUpperOuter = iBands(Symbol(), 0, BBPeriod, BBDeviationOuter, 0, PRICE_CLOSE, MODE_UPPER, 1);
   double bbLowerOuter = iBands(Symbol(), 0, BBPeriod, BBDeviationOuter, 0, PRICE_CLOSE, MODE_LOWER, 1);
   double bbMiddle = iBands(Symbol(), 0, BBPeriod, BBDeviationOuter, 0, PRICE_CLOSE, MODE_MAIN, 1);
   double bbUpperInner = iBands(Symbol(), 0, BBPeriod, BBDeviationInner, 0, PRICE_CLOSE, MODE_UPPER, 1);
   double bbLowerInner = iBands(Symbol(), 0, BBPeriod, BBDeviationInner, 0, PRICE_CLOSE, MODE_LOWER, 1);
   double open1 = iOpen(Symbol(), 0, 1), close1 = iClose(Symbol(), 0, 1), high1 = iHigh(Symbol(), 0, 1), low1 = iLow(Symbol(), 0, 1);
   double open2 = iOpen(Symbol(), 0, 2), close2 = iClose(Symbol(), 0, 2), high2 = iHigh(Symbol(), 0, 2), low2 = iLow(Symbol(), 0, 2);
   double open3 = iOpen(Symbol(), 0, 3), close3 = iClose(Symbol(), 0, 3), high3 = iHigh(Symbol(), 0, 3), low3 = iLow(Symbol(), 0, 3);

   buyCount = 0; sellCount = 0;
   for (int i = OrdersTotal() - 1; i >= 0; i--)
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
         if (OrderType() == OP_BUY) buyCount++; else if (OrderType() == OP_SELL) sellCount++;

   if (buyCount == 0) gridLevelBuy = 0;
   if (sellCount == 0) gridLevelSell = 0;

   double swingLow = iLow(Symbol(), 0, iLowest(Symbol(), 0, MODE_LOW, SwingLookback, 2));
   double swingHigh = iHigh(Symbol(), 0, iHighest(Symbol(), 0, MODE_HIGH, SwingLookback, 2));
   bool breakoutBelow = low2 < swingLow && close2 < swingLow;
   bool breakoutAbove = high2 > swingHigh && close2 > swingHigh;
   bool retestAndReverseUp = breakoutBelow && close1 > swingLow && close1 > open1;
   bool retestAndReverseDown = breakoutAbove && close1 < swingHigh && close1 < open1;

   bool isBullishTrend = close1 > bbUpperOuter, isBearishTrend = close1 < bbLowerOuter;
   bool bullishPinBar = (low1 < bbLowerOuter) && (close1 > open1) && ((high1 - low1) / point >= MinPinBarWickPips) && ((close1 - low1) / (high1 - low1) > 0.7);
   bool bearishPinBar = (high1 > bbUpperOuter) && (close1 < open1) && ((high1 - low1) / point >= MinPinBarWickPips) && ((high1 - close1) / (high1 - low1) > 0.7);
   bool bullishEngulfing = (close1 > open1) && (close2 < open2) && (close1 > open2) && (open1 < close2);
   bool bearishEngulfing = (close1 < open1) && (close2 > open2) && (close1 < open2) && (open1 > close2);

   if ((retestAndReverseUp || (!isBearishTrend && (bullishPinBar || bullishEngulfing))) && buyCount < MaxTrades)
   {
      if (buyCount == 0) { gridLevelBuy = ask; OpenBuyTrade(ask, bbMiddle, bbUpperOuter); }
      else if (ask <= gridLevelBuy - GridSpacing * point) { gridLevelBuy = ask; OpenBuyTrade(ask, bbMiddle, bbUpperOuter); }
   }

   if ((retestAndReverseDown || (!isBullishTrend && (bearishPinBar || bearishEngulfing))) && sellCount < MaxTrades)
   {
      if (sellCount == 0) { gridLevelSell = bid; OpenSellTrade(bid, bbMiddle, bbLowerOuter); }
      else if (bid >= gridLevelSell + GridSpacing * point) { gridLevelSell = bid; OpenSellTrade(bid, bbMiddle, bbLowerOuter); }
   }

   CloseProfitableTrades();
}

void OpenBuyTrade(double price, double tp1, double tp2)
{
   double ticket = OrderSend(Symbol(), OP_BUY, LotSize, price, 10, 0, 0, TradeComment, Magic, 0, clrGreen);
   if (ticket > 0)
   {
      double halfLot = LotSize / 2;
      if (OrderSend(Symbol(), OP_BUY, halfLot, price, 10, 0, tp1, TradeComment, Magic, 0, clrGreen) <= 0)
         Print("Buy TP1 order failed: ", GetLastError());
      if (OrderSend(Symbol(), OP_BUY, halfLot, price, 10, 0, tp2, TradeComment, Magic, 0, clrGreen) <= 0)
         Print("Buy TP2 order failed: ", GetLastError());
   }
   else Print("Buy order failed: ", GetLastError());
}

void OpenSellTrade(double price, double tp1, double tp2)
{
   double ticket = OrderSend(Symbol(), OP_SELL, LotSize, price, 10, 0, 0, TradeComment, Magic, 0, clrRed);
   if (ticket > 0)
   {
      double halfLot = LotSize / 2;
      if (OrderSend(Symbol(), OP_SELL, halfLot, price, 10, 0, tp1, TradeComment, Magic, 0, clrRed) <= 0)
         Print("Sell TP1 order failed: ", GetLastError());
      if (OrderSend(Symbol(), OP_SELL, halfLot, price, 10, 0, tp2, TradeComment, Magic, 0, clrRed) <= 0)
         Print("Sell TP2 order failed: ", GetLastError());
   }
   else Print("Sell order failed: ", GetLastError());
}

void CloseProfitableTrades()
{
   double bid = MarketInfo(Symbol(), MODE_BID), ask = MarketInfo(Symbol(), MODE_ASK);
   for (int i = OrdersTotal() - 1; i >= 0; i--)
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol() && OrderMagicNumber() == Magic)
      {
         double openPrice = OrderOpenPrice();
         if (OrderType() == OP_BUY && OrderTakeProfit() > 0 && bid >= OrderTakeProfit())
            if (!OrderClose(OrderTicket(), OrderLots(), bid, 10, clrGreen))
               Print("Close buy order failed: ", GetLastError());
         else if (OrderType() == OP_SELL && OrderTakeProfit() > 0 && ask <= OrderTakeProfit())
            if (!OrderClose(OrderTicket(), OrderLots(), ask, 10, clrRed))
               Print("Close sell order failed: ", GetLastError());
      }
}

void deinit()
{
}