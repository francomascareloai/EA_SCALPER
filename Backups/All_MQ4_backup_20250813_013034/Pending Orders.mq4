
void init()
{
   // Create some Orders 
   
   double iBuyPrice = 0;
   double iSellPrice = 0;
   
   iBuyPrice = Ask;
   iSellPrice =  Bid;
   
   iBuyPrice = iBuyPrice - 0.0020;
   iSellPrice = iSellPrice + 0.0020;

   OrderSend(Symbol(), OP_BUYLIMIT, 1, iBuyPrice, 4, 0, 0, "", 123456789, 0 ,Blue);
   OrderSend(Symbol(), OP_BUYLIMIT, 1, iBuyPrice, 4, 0, 0, "", 123456789, 0 ,Blue);
   
   OrderSend(Symbol(), OP_SELLLIMIT, 1, iSellPrice, 4, 0, 0, "", 123456789, 0 ,Blue);
   OrderSend(Symbol(), OP_SELLLIMIT, 1, iSellPrice, 4, 0, 0, "", 123456789, 0 ,Blue);

   Print("Total Pending Orders (init): ", GetTotalPendingOrders());   
}

void start()
{
   // start what?
   
   Print("Total Pending Orders (start): ", GetTotalPendingOrders());
}

int GetTotalPendingOrders()
{
   int iCounter = 0;
   int iSelectedOrderType = 0;
   int iPendingOrders = 0;
   
   for(iCounter = 0; iCounter < OrdersTotal(); iCounter++)
   {      
      if ( OrderSelect(iCounter, SELECT_BY_POS, MODE_TRADES) == true )
      {
         iSelectedOrderType = OrderType();
         
         if ( iSelectedOrderType == OP_BUYLIMIT || iSelectedOrderType == OP_BUYSTOP || iSelectedOrderType == OP_SELLLIMIT || iSelectedOrderType == OP_SELLSTOP )
         {
            iPendingOrders = iPendingOrders + 1;
         }
      }
      else
      {
         Print("Unable to select order: ", iCounter);
      }
      
   }
   
   return (iPendingOrders);
}









