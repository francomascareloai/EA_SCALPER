#property copyright "Mr Leo's Simple System by BluePanther (Matt T)"
#property link      "https://t.me/freeforexea1"
#property version   "1.3"
#property description "Created using Mistral"

//--- input parameters
input int BOLLINGER_PERIOD = 20;
input int BOLLINGER_DEVIATIONS = 2;
input int MIN_PRICE_MOVEMENT = 10;
input int LIMIT_ORDER_OFFSET = 2;
input int STOP_LOSS = 35;
input int BREAKEVEN_MOVEMENT = 30;
input int TAKE_PROFIT = 100;
input int MAGIC_NUMBER = 12345;

//--- global variables
double previous_day_open;
double limit_order_price;
double stop_loss_price;
double breakeven_price;
double take_profit_price;
datetime order_activation_time;
int order_ticket = -1;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   previous_day_open = iOpen(Symbol(), PERIOD_D1, 1);
   order_activation_time = 0;
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   double bollinger_center = iMA(Symbol(), 0, BOLLINGER_PERIOD, 0, MODE_EMA, PRICE_CLOSE, 1);
   double bollinger_lower = bollinger_center - BOLLINGER_DEVIATIONS * iStdDev(Symbol(), 0, BOLLINGER_PERIOD, 0, MODE_EMA, PRICE_CLOSE, 1);
   double bollinger_upper = bollinger_center + BOLLINGER_DEVIATIONS * iStdDev(Symbol(), 0, BOLLINGER_PERIOD, 0, MODE_EMA, PRICE_CLOSE, 1);

   double potential_limit_order_price;
   int result;

   if(Close[0] < bollinger_lower)
      {
      if(Ask < previous_day_open + MIN_PRICE_MOVEMENT)
         return;

      potential_limit_order_price = previous_day_open + LIMIT_ORDER_OFFSET;

      if(potential_limit_order_price < bollinger_lower)
         return;

      if(order_ticket == -1)
         {
         limit_order_price = potential_limit_order_price;
         stop_loss_price = limit_order_price - STOP_LOSS;
         breakeven_price = limit_order_price + BREAKEVEN_MOVEMENT;
         take_profit_price = limit_order_price + TAKE_PROFIT;

         order_ticket = OrderSend(Symbol(), OP_BUYLIMIT, 0.01, limit_order_price, 3, stop_loss_price, take_profit_price, MAGIC_NUMBER);

         if(order_ticket > 0)
            order_activation_time = Time[0];
         }
      else if(Ask >= breakeven_price)
         {
         result = OrderModify(order_ticket, breakeven_price, 3, stop_loss_price, take_profit_price, MAGIC_NUMBER);

         // if(result != RETURN_CODE_OK)
         //    Print("Error modifying order: ", GetLastError());
         }
      }
   else if(Close[0] > bollinger_upper)
      {
      if(Bid > previous_day_open - MIN_PRICE_MOVEMENT)
         return;

      potential_limit_order_price = previous_day_open - LIMIT_ORDER_OFFSET;

      if(potential_limit_order_price > bollinger_upper)
         return;

      if(order_ticket == -1)
         {
         limit_order_price = potential_limit_order_price;
         stop_loss_price = limit_order_price + STOP_LOSS;
         breakeven_price = limit_order_price - BREAKEVEN_MOVEMENT;
         take_profit_price = limit_order_price - TAKE_PROFIT;

         order_ticket = OrderSend(Symbol(), OP_SELLLIMIT, 0.01, limit_order_price, 3, stop_loss_price, take_profit_price, MAGIC_NUMBER);

         if(order_ticket > 0)
            order_activation_time = Time[0];
         }
      else if(Bid <= breakeven_price)
         {
         result = OrderModify(order_ticket, breakeven_price, 3, stop_loss_price, take_profit_price, MAGIC_NUMBER);

         // if(result != RETURN_CODE_OK)
         //    Print("Error modifying order: ", GetLastError());
         }
      }

   if(order_ticket != -1 && Time[0] - order_activation_time > 24 * 60 * 60 * 1000)
      {
      result = OrderClose(order_ticket, 0, 0, 3, MAGIC_NUMBER);

      // if(result != RETURN_CODE_OK)
      //    Print("Error closing order: ", GetLastError());

      order_ticket = -1;
      order_activation_time = 0;
      }
  }
