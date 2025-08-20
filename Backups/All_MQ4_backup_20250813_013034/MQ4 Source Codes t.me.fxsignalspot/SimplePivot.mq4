//+------------------------------------------------------------------+
//|                                                  SimplePivot.mq4 |
//|                  Copyright © 2006, Derk Wehler, Global One Group |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Derk Wehler, Global One Group"
#property link      "http://www.metaquotes.net"

//---- input parameters
extern int Lots = 1;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
{
   static int prevTradeOp = -1;
   static int prevBars = -1;
   static int ticketNum = -1;
   
   int curBars = Bars;
   if (prevBars == -1)
      prevBars = curBars;

   Print("curBars, prevBars = ", curBars);
   if (curBars == prevBars)
      return(0);
   Print("After checking bars");
      
   prevBars = curBars;
   
   // Only buy and tell on the first tick of new candle creation
   double prevHigh = High[1];
   double prevLow = Low[1];
   double curOpen = Open[0];
   double pivot = (prevHigh + prevLow) / 2;
   int tradeOp = OP_BUY;

   // Determine whether we are in a buy or sell position for this candle
   if (curOpen < prevHigh && curOpen > pivot)
      tradeOp = OP_SELL;

   // If we were in a buy, and still in a buy for this new candle, do not 
   // close and re-open the trade, giving up the spread again.  Same for sell.
   if (tradeOp == prevTradeOp && prevTradeOp != -1)
      return(0);
      
   Print("Closing old trade");
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   // Close the current trade
   if (ticketNum != -1)
   {
      OrderSelect(ticketNum, SELECT_BY_TICKET);
   
      // long position is opened
      if (OrderType() == OP_BUY) 
      {
         OrderClose(ticketNum, OrderLots(), Bid, 0, Violet);
      }
      // short position is opened
      else
      {
         OrderClose(ticketNum, OrderLots(), Ask, 0, Violet);
      }
   }
   
   Print("Opening new trade");
   // - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
   // Open new trade
   if (tradeOp == OP_BUY)
   {
     ticketNum = OrderSend(Symbol(), OP_BUY, Lots, Ask, 0, 0,
         0, "Simple Pivot", 55255, 0, Green);
      if (ticketNum > 0)
      {
         if (OrderSelect(ticketNum, SELECT_BY_TICKET))
            Print("BUY order opened : ",OrderOpenPrice());
      }
      else 
         Print("Error opening BUY order : ", GetLastError());
   }
   else
   {
      ticketNum = OrderSend(Symbol(), OP_SELL, Lots, Bid, 0, 0,
         0, "CSimple Pivot", 55255, 0, Red);
      if (ticketNum > 0)
      {
         if (OrderSelect(ticketNum, SELECT_BY_TICKET))
            Print("SELL order opened : ", OrderOpenPrice());
      }
      else 
         Print("Error opening SELL order : ", GetLastError());
   }
     
   return(0);
}
//+------------------------------------------------------------------+