
//+------------------------------------------------------------------+
//| Test Utility Script                                             |
//+------------------------------------------------------------------+
#property copyright "Test"
#property version   "1.00"

void OnStart()
{
    Print("Utility script executed");
    
    // Close all orders
    for(int i = OrdersTotal()-1; i >= 0; i--)
    {
        if(OrderSelect(i, SELECT_BY_POS))
        {
            OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 3);
        }
    }
}
