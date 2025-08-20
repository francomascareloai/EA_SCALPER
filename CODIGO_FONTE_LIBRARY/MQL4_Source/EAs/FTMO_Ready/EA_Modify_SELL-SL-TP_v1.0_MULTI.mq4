//+------------------------------------------------------------------+
//|            Copyright © 2011, Matus German, matusgerman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012 Matus German www.MTexperts.net"
#property show_inputs

#include <WinUser32.mqh>

extern string descr   = "*** Modify SELL orders ***";
extern double SLpip   = 0;
extern double TPpip   = 0;
extern double SLprice = 0;
extern double TPprice = 0;

double pips2dbl, pips2point, minDistance,
       slPoints, tpPoints,
       itotal,
       sl, tp;

// script modifies stop loss and take profit
int start()
{
   minDistance=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point;
   
   if (Digits == 5 || Digits == 3)    // Adjust for five (5) digit brokers.
   {            
      pips2dbl = Point*10; pips2point = 10;
   } 
   else 
   {    
      pips2dbl = Point;   pips2point = 1;
   }

   slPoints=SLpip*pips2dbl;
   tpPoints=TPpip*pips2dbl;

   itotal=OrdersTotal();
   for(int icnt=itotal-1;icnt>=0;icnt--) 
   {
      OrderSelect(icnt, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol()==Symbol() && OrderType()==OP_SELL)
      {
         RefreshRates();
         sl=0; tp=0;
         if(slPoints>0)
            sl=Ask+slPoints;
         else if(SLprice>0)
            sl=SLprice;
         else
            sl=OrderStopLoss();
            
         if(tpPoints>0)
            tp=Ask-tpPoints;
         else if(TPprice>0)
            tp=TPprice;
         else
            tp=OrderTakeProfit(); 
            
         if(sl-Ask<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point && sl>0) // check broker stop levels
         {
            Alert("Stop Loss is too close to market price or on wrong side!!!");
            return(0);
         }         
         
         if(Ask-tp<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point && tp>0)
         {
            Alert("Take Profit is too close to market price or on wrong side!!!");
            return(0);
         } 
         
         if(OrderTakeProfit()!=tp || OrderStopLoss()!=sl)
         {
            while(OrderModify(OrderTicket(),OrderOpenPrice(),sl,tp,0,Green)==false)
            {
               if(sl-Ask<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point && sl>0) // check broker stop levels
               {
                  Alert("Stop Loss is too close to market price or on wrong side!!!");
                  return(0);
               }         
         
               if(Ask-tp<=MarketInfo(Symbol(),MODE_STOPLEVEL)*Point && tp>0)
               {
                  Alert("Take Profit is too close to market price or on wrong side!!!");
                  return(0);
               } 
            }   
         }                      
      } 
   }
   return(0);
}
//+------------------------------------------------------------------+

