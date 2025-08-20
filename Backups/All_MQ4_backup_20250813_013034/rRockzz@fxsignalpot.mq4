//+------------------------------------------------------------------+
//|                                                      rRockzz.mq4 |
//|                                          Copyright 2023,JBlanked |
//|                                  https://www.github.com/jblanked |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023,JBlanked"
#property link      "https://www.github.com/jblanked"
#property description "This strategy compares the current price to the closing price of the previous day."
#property description "If the current price is lower than the previous day's closing price, the strategy will look for opportunities to buy."
#property description "If the current price is higher than the previous day's closing price, the strategy will look for opportunities to sell."
#property strict

input double lotsize = 0.10; // lot size
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double recent_close_price = iClose(_Symbol,PERIOD_CURRENT,1); // last close price, since current close price would be the current price
   double current_buy_price = SymbolInfoDouble(_Symbol,SYMBOL_ASK); // current ask price
   double current_sell_price = SymbolInfoDouble(_Symbol,SYMBOL_BID); // current bid price
   double previous_day_closing_price = iClose(_Symbol,PERIOD_D1,1); // previous day's closing price

   double stop_loss_price_buy = current_buy_price * 0.95; // buy stop loss
   double take_profit_price_buy = current_buy_price * 1.1; // buy take profit

   double stop_loss_price_sell = current_sell_price * 1.05; // sell stop loss
   double take_profit_price_sell = current_sell_price * 0.90; // sell take profit


   if(OrdersTotal() == 0) // if there are no orders opened
     {

      if(current_buy_price < previous_day_closing_price) // if price is lower than the previous day's closing price
        {
         // buys

         int order_send = OrderSend(_Symbol,OP_BUY,lotsize,current_buy_price,3,stop_loss_price_buy,take_profit_price_buy); // send MQL4 buy order
         // that order send wont work in MQL5

        }


      if(current_sell_price > previous_day_closing_price) // if price is greater than the previous day's closing price
        {
         // sells

         int order_send = OrderSend(_Symbol,OP_BUY,lotsize,current_sell_price,3,stop_loss_price_sell,take_profit_price_sell); // send MQL4 sell order
         // that order send wont work in MQL5
        }

     } // end of orders total


  }
//+------------------------------------------------------------------+
