//+------------------------------------------------------------------+
//|                                            CloseAllTradesBuy.mq4 |
//|                                                     Matus German |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Matus German"

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+

// script closes all opened Buy positions
int start()
{
   double total;
   int cnt;
   while(OpenTradesBuy()>0)
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
                  
            }             
         }
      }
   }
   return(0);
}

int OpenTradesBuy()
{
   int icnt, itotal, retval;

   retval=0;
   itotal=OrdersTotal();

      for(icnt=itotal-1;icnt>=0;icnt--) 
      {
         OrderSelect(icnt, SELECT_BY_POS, MODE_TRADES);
         if(OrderType()==OP_BUY)
             retval++;             
          
      }

   return(retval);
}
//+------------------------------------------------------------------+

