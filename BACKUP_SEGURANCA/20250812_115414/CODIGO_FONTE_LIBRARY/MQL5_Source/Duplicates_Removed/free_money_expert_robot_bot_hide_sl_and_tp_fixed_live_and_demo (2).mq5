#include <Trade\Trade.mqh>

input double LotSize       = 0.1;
input double Multiplier    = 2.0;
input double MaxLot        = 5.0;
input int    Slippage      = 5;
input int    MaxSpread     = 20;
input int    TP_Points     = 100;
input int    SL_Points     = 50;
input int    StartHour     = 0;
input int    EndHour       = 23;
input bool   EnablePush    = false;
input bool   EnableEmail   = false;
input string TradeComment  = "Alternate Trader";  // New input for trade comments

CTrade trade;

int      direction        = 1;             // 1 = Buy, -1 = Sell
double   currentLot       = LotSize;
datetime lastTradeTime    = 0;
ulong    lastOrderTicket  = 0;
double   lastOpenPrice    = 0;
double   stopLoss         = 0;
double   takeProfit       = 0;

//+------------------------------------------------------------------+
bool IsWithinTradingTime()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   return (dt.hour >= StartHour && dt.hour < EndHour);
}

bool IsSpreadOkay()
{
   double spreadPoints = (SymbolInfoDouble(_Symbol, SYMBOL_ASK) - SymbolInfoDouble(_Symbol, SYMBOL_BID)) / _Point;
   return (spreadPoints <= MaxSpread);
}

bool IsPositionOpen()
{
   return PositionSelect(_Symbol);
}

//+------------------------------------------------------------------+
void OnTick()
{
   if (!IsWithinTradingTime()) return;
   if (IsPositionOpen()) return;
   if (!IsSpreadOkay()) return;

   // Only proceed once per bar or new deal
   if (TimeCurrent() == lastTradeTime) return;

   // Look for most recent completed deal
   datetime timeFrom = TimeCurrent() - 3600 * 24;
   datetime timeTo   = TimeCurrent();

   if (HistorySelect(timeFrom, timeTo))
   {
      ulong lastDeal = 0;
      double profit = 0;
      datetime latestCloseTime = 0;

      int total = HistoryDealsTotal();
      for (int i = total - 1; i >= 0; i--)
      {
         ulong ticket = HistoryDealGetTicket(i);
         if (HistoryDealGetString(ticket, DEAL_SYMBOL) == _Symbol &&
             (HistoryDealGetInteger(ticket, DEAL_TYPE) == DEAL_TYPE_BUY ||
              HistoryDealGetInteger(ticket, DEAL_TYPE) == DEAL_TYPE_SELL))
         {
            datetime closeTime = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME); // Fix: cast to datetime
            if (closeTime > latestCloseTime)
            {
               latestCloseTime = closeTime;
               lastDeal = ticket;
               profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
            }
         }
      }

      if (lastDeal != 0 && lastDeal != lastOrderTicket)
      {
         lastOrderTicket = lastDeal;
         lastTradeTime = TimeCurrent();

         if (profit >= 0)
            currentLot = LotSize;
         else
            currentLot = MathMin(currentLot * Multiplier, MaxLot);

         direction *= -1; // flip direction
      }
   }

   double price = (direction == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);

   // Calculate SL/TP based on points
   if (SL_Points > 0)
      stopLoss = (direction == 1) ? price - SL_Points * _Point : price + SL_Points * _Point;

   if (TP_Points > 0)
      takeProfit = (direction == 1) ? price + TP_Points * _Point : price - TP_Points * _Point;

   bool result = false;
   string comment = TradeComment;  // Use the input comment here

   if (direction == 1)
      result = trade.Buy(currentLot, _Symbol, price, 0, 0, comment);  // No SL/TP in the order
   else
      result = trade.Sell(currentLot, _Symbol, price, 0, 0, comment);  // No SL/TP in the order

   if (result)
   {
      string dirStr = (direction == 1 ? "BUY" : "SELL");
      string msg = StringFormat("Order Sent: %s\\nLot: %.2f\\nTP: %.5f\\nSL: %.5f", dirStr, currentLot, takeProfit, stopLoss);

      if (EnablePush) SendNotification(msg);
      if (EnableEmail) SendMail("MT5 EA Trade", msg);

      lastOpenPrice = price;  // Record the price where the order was opened
      lastTradeTime = TimeCurrent();
   }
   else
   {
      Print("Order failed. Error: ", GetLastError());
   }

   // Manage stop loss and take profit manually after trade execution
   if (IsPositionOpen())
   {
      double currentPrice = (direction == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);

      // Close the position if it hits the stop loss or take profit
      if ((direction == 1 && currentPrice <= stopLoss) || (direction == -1 && currentPrice >= stopLoss))
      {
         trade.PositionClose(_Symbol);  // Close the position if it hits stop loss
      }
      else if ((direction == 1 && currentPrice >= takeProfit) || (direction == -1 && currentPrice <= takeProfit))
      {
         trade.PositionClose(_Symbol);  // Close the position if it hits take profit
      }
   }
}
