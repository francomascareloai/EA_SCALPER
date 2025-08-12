//+------------------------------------------------------------------+
//|   Controlled Hedge Bot - TRADINGWITHKAY (TP in $ version)       |
//|   Opens hedge when trend reverses and exits on profit           |
//|   © 2025 TRADINGWITHKAY - www.tradingwithkay.com                |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>
CTrade trade;

input double LotSize = 0.01;
input int MaxEntries = 2;
input double TakeProfitAmount = 0.50;
input bool EnableTrailingStop = false;
input double TrailingProfit = 0.30;

bool hedgeOpened = false;
ulong sellTicket = 0;
ulong buyTicket = 0;

//+------------------------------------------------------------------+
int OnInit()
  {
   Print("Hedge Bot (TP in $) initialized.");
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
void OnTick()
  {
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   int count = 0;
   for(int i = 0; i < PositionsTotal(); i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket) && PositionGetString(POSITION_SYMBOL) == _Symbol)
         count++;
     }
   if(count >= MaxEntries) return;

   // Entry logic
   if(!PositionSelect(_Symbol))
     {
      if(trade.Sell(LotSize, _Symbol, bid, 0, 0))
         sellTicket = trade.ResultOrder();
      return;
     }

   // Hedge logic
   if(sellTicket > 0 && PositionSelectByTicket(sellTicket))
     {
      double sellOpenPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      if(bid > sellOpenPrice && !hedgeOpened)
        {
         if(trade.Buy(LotSize, _Symbol, ask, 0, 0))
            buyTicket = trade.ResultOrder();
         hedgeOpened = true;
         return;
        }
     }

   // Check profit targets and trailing stop
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;

      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;

      double profit = PositionGetDouble(POSITION_PROFIT);
      if(profit >= TakeProfitAmount)
         trade.PositionClose(ticket);

      if(EnableTrailingStop && profit > TrailingProfit)
         continue; // Optional: implement trailing stop logic here
     }

   // Recovering hedge logic
   if(hedgeOpened && buyTicket > 0 && sellTicket > 0)
     {
      if(PositionSelectByTicket(buyTicket) && PositionSelectByTicket(sellTicket))
        {
         double buyProfit = PositionGetDouble(POSITION_PROFIT);
         double sellProfit = PositionGetDouble(POSITION_PROFIT);

         if(buyProfit + sellProfit >= 0.0)
           {
            trade.PositionClose(sellTicket);
            hedgeOpened = false;
            sellTicket = 0;
           }
        }
     }
  }
//+------------------------------------------------------------------+
