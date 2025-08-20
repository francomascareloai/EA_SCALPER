//+------------------------------------------------------------------+
//|                                        CloseAllTradesPending.mq4 |
//|                                                     Matus German |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Matus German"

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+

// script closes all pending positions on all charts
int start()
{
   double total;
   int cnt;
   while(OpenTradesOnly()>0)
   {
      // close opened orders first
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

int OpenTradesOnly()
{
   int icnt, itotal, retval;

   retval=0;
   itotal=OrdersTotal();

      for(icnt=itotal-1;icnt>=0;icnt--) 
      {
         OrderSelect(icnt, SELECT_BY_POS, MODE_TRADES);
         if(OrderType()==OP_BUYLIMIT || OrderType()==OP_SELLLIMIT || OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP)
             retval++;             
          
      }

   return(retval);
}
//+------------------------------------------------------------------+

