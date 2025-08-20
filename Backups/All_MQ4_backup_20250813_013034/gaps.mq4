//+------------------------------------------------------------------+
//|                                                         gaps.mq4 |
//|                                                        SFK Corp. |
//+------------------------------------------------------------------+
#property copyright "SFK Corp."
#property link      ""
//---- input parameters
extern int    min_gapsize = 1;
extern double lotsize_gap = 0.1;
//----
datetime order_time = 0;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
/* 
 Thing to be done in future in this program to make it more efficient
 and more powerful:
   1. Make the dicission of the quantity of lots used according to 
      the scillators;
   2. This program will catch the gaps.
 Things to ware of:
   1. the spread;
   2. excuting the order not on the gap ends a little bit less.
*/
// Defining the variables to decide.
   Print("order time", order_time);
   double current_openprice = iOpen(Symbol(), PERIOD_M15, 0);
   double previous_highprice = iHigh(Symbol(), PERIOD_M15, 1);
   double previous_lowprice = iLow(Symbol(), PERIOD_M15, 1);
   double point_gap = MarketInfo(Symbol(), MODE_POINT);
   int spread_gap = MarketInfo(Symbol(), MODE_SPREAD);
   datetime current_time = iTime(Symbol(), PERIOD_M15, 0);
// catching the gap on sell upper gap
   if(current_openprice > previous_highprice + (min_gapsize + spread_gap)*point_gap &&
      current_time != order_time)
     {
       int ticket = OrderSend(Symbol(), OP_SELL, lotsize_gap, Bid, 0, 0, 
                              previous_highprice + spread_gap*point_gap, 
                              "", 4, 0, Red);
       order_time = iTime(Symbol(), PERIOD_M15, 0);
       Print("I am inside (sell) :-)", order_time);
       //----
       if(ticket < 0)
         {
           Print("OrderSend failed with error #", GetLastError());
         }
     }
//catching the gap on buy down gap
   if(current_openprice < previous_lowprice - (min_gapsize + spread_gap)*point_gap &&
      current_time != order_time)
     {
       ticket = OrderSend(Symbol(), OP_BUY, lotsize_gap, Ask, 0, 0, 
                          previous_lowprice - spread_gap*point_gap,
                          "", 5, 0, Green);
       order_time = iTime(Symbol(), PERIOD_M15, 0);
       Print("I am inside (buy) :-)", order_time);
       if(ticket < 0)
         {
           Print("OrderSend failed with error #", GetLastError());
         }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+