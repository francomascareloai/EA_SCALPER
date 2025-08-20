//+------------------------------------------------------------------+
//|                                               CloseAllTrades.mq4 |
//|                                                     Matus German |
//+------------------------------------------------------------------+
#property copyright "Matus German"

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+

// script closes all opened and pending positions on all charts
int start()
{
   double total;
   int cnt;
   while(OrdersTotal()>0)
   {
      // close opened orders first
      total = OrdersTotal();
      for (cnt = total-1; cnt >=0 ; cnt--)
      {
         if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) 
         {
            switch(OrderType())
            {
               case OP_BUY       :
                  OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),3,Violet);break;
                   
               case OP_SELL      :
                  OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),3,Violet); break;
            }             
         }
      }
      // and close pending
      total = OrdersTotal();      
      for (cnt = total-1; cnt >=0 ; cnt--)
      {
         if(OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES)) 
         {
            switch(OrderType())
            {
               case OP_BUYLIMIT  :OrderDelete(OrderTicket()); break;
               case OP_SELLLIMIT :OrderDelete(OrderTicket()); break;
               case OP_BUYSTOP   :OrderDelete(OrderTicket()); break;
               case OP_SELLSTOP  :OrderDelete(OrderTicket()); break;
            }
         }
      }
   }
   return(0);
}
//+------------------------------------------------------------------+

