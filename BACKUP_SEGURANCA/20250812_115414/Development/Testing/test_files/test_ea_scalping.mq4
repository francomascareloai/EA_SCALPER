
//+------------------------------------------------------------------+
//| Test EA Scalping                                                 |
//+------------------------------------------------------------------+
#property copyright "Test"
#property version   "1.00"

input double LotSize = 0.01;
input int StopLoss = 20;
input int TakeProfit = 60;

void OnTick()
{
    // Scalping logic
    if(OrdersTotal() == 0)
    {
        if(iMA(Symbol(), PERIOD_M1, 10, 0, MODE_SMA, PRICE_CLOSE, 0) > 
           iMA(Symbol(), PERIOD_M1, 20, 0, MODE_SMA, PRICE_CLOSE, 0))
        {
            OrderSend(Symbol(), OP_BUY, LotSize, Ask, 3, Ask-StopLoss*Point, Ask+TakeProfit*Point);
        }
    }
}
