//+------------------------------------------------------------------+
//|                                                     CloseAll.mq4 |
//|                                                  ThinkTrustTrade |
//|                                        www.think-trust-trade.com |
//+------------------------------------------------------------------+
#property copyright "ThinkTrustTrade"
#property link      "www.think-trust-trade.com"

extern string  Visit="www.think-trust-trade.com";
extern string  Like="www.facebook.com/ThinkTrustTrade";

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----
int ticket;
if (OrdersTotal()==0) return(0);
for (int i=OrdersTotal()-1; i>=0; i--)
      {//pozicio kivalasztasa
       if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true)//ha kivalasztas ok
            {
            //Print ("order ticket: ", OrderTicket(), "order magic: ", OrderMagicNumber());
            if (OrderType()==0)
               {//ha long
               ticket=OrderClose(OrderTicket(),OrderLots(), MarketInfo(OrderSymbol(),MODE_BID), 3,Red);
               if (ticket==-1) Print ("Error: ",  GetLastError());
               if (ticket>0) Print ("Position ", OrderTicket() ," closed. Thank you for using our script! Visit www.think-trust-trade.com for more free tools.");
               }
            if (OrderType()==1)
               {//ha short
               ticket=OrderClose(OrderTicket(),OrderLots(), MarketInfo(OrderSymbol(),MODE_ASK), 3,Red);
               if (ticket==-1) Print ("Error: ",  GetLastError());
               if (ticket>0) Print ("Position ", OrderTicket() ," closed. Thank you for using our script! Visit www.think-trust-trade.com for more free tools.");
               }   
            }
      }//pozicio kivalszatas vege
  
//----
   return(0);
  }
//+------------------------------------------------------------------+ 