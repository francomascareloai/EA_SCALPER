//+-------------------------------------------------------------------+
//|                                                Nuclear Option.mq4 |
//|                                    Copyright 2012, Steve Hopwood  |
//|                              http://www.hopwood3.freeserve.co.uk  |
//+-------------------------------------------------------------------+

#property strict
#property show_inputs

extern string  ins1="A magic of -1 will close/delete";
extern string  ins2="every trade on the platform.";
extern int     MagicNumber=-1;
bool           ForceTradeClosure=false;

//This script creates a Global Variable that tells EA's able to read it that
//it is closing trades, and so the EA is not to attempt to send
//new ones.
string         NuclearGvName = "Nuclear option closure in operation ";

void CloseAllTrades(int type)
{
   ForceTradeClosure= false;
   
   if (OrdersTotal() == 0) return;
   
   bool result = false;
   
      
   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS, MODE_TRADES) ) continue;
      if (OrderMagicNumber() != MagicNumber && MagicNumber != -1) continue;
      //if (OrderSymbol() != Symbol() ) continue;
      
      while(IsTradeContextBusy()) Sleep(100);
      
      if (type < 2)
         if (OrderType() < 2)
         {
            result = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 1000, CLR_NONE);
            if (!result) ForceTradeClosure= true;
            if (result) cc++;
         }//if (OrderType() < 2)
      
      if (type > 1)   
         if (OrderType() > 1) 
         {
            result = OrderDelete(OrderTicket(), clrNONE);
            if (!result) ForceTradeClosure= true;
            if (result) cc++;
         }//if (OrderType() > 1) 
       
      
   }//for (int cc = OrdersTotal() - 1; cc >= 0; cc--)

   
}//End void CloseAllTrades()

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
 
   //Set a Global Variable to tell EA's not to attempt to trade
   GlobalVariableSet(NuclearGvName, 0);//Value is of no importance
   
   //Close market orders
   CloseAllTrades(0);
   
   //Delete pending trades
   CloseAllTrades(2);
   
   //Try again if necessary
   if (ForceTradeClosure)
   {
      //Close market orders
      CloseAllTrades(0);
      
      //Delete pending trades
      CloseAllTrades(2);
   }//if (ForceTradeClosure)
   
   //And again if necessary
   if (ForceTradeClosure)
   {
      //Close market orders
      CloseAllTrades(0);
      
      //Delete pending trades
      CloseAllTrades(2);
   }//if (ForceTradeClosure)
   
   //Give up
   if (ForceTradeClosure)
      Alert("The script did not close/delete all trades. Please try again.");

   GlobalVariableDel(NuclearGvName);
     
}
