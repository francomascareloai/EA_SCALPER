//+------------------------------------------------------------------+
//|                                    __SureForexHedging__1_0_0.mq4 |
//|                                                   Anton Trefolev |
//|                                         anton.trefolev@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Anton Trefolev"
#property link      "anton.trefolev@gmail.com"


#include <stderror.mqh>


#define sec_wait_context 10
#define max_errors 30
#define wait_error 1000
#define busysleep 100
#define EB_NEXTTRY 0
#define EB_WAITTRY 1
#define EB_TERMINATE 2
#define StoplevelAdd 0


extern int strategy_mode = 1 ; // 0 - FIRST strategy, 1 - SECOND strategy
extern int initial_deal = 0 ; // Direction of initial deal: 0 - buy deal, 1 - sell deal, other values - new opening disabled
extern double stoploss = 60 ; // Stoploss for all deals
extern double takeprofit = 30 ; // takeprofit for all deals
extern double fixed_lot = 0.1 ; // If > 0, the initial deal will be opened with this lot
extern double deposit_lot = 0 ; // If fixed_lot is 0 and deposit_lot > 0, initial deal will be opened with volume Balance / deposit_lot lots
extern double martin_koeff1 = 3 ; // Lot multiplier for first hedging deal
extern double martin_koeff2 = 2 ; // Lot multiplier for second, third and further hedging deals
extern int enable_daily_profit = 0 ; // Enable option to stop trading if a daily profit exceeds following values (it considers profit for ALL currencies)
extern double daily_profit = 0 ; // Daily profit in the account currency
extern double daily_profit_percent = 0 ; // Daily profit as a percent to Balance of start of the day
extern double distance0 = 30 ; // If > 0, distance for placing 1-st hedging deal
extern double distance1 = 0 ; // If > 0, distance for placing 2-nd hedging deal
extern double distance2 = 0 ; // If > 0, distance for placing 3-rd hedging deal
extern double distance3 = 0 ; // If > 0, distance for placing 4-th hedging deal
extern double distance4 = 0 ; // If > 0, distance for placing 5-th hedging deal
extern double distance5 = 0 ; // If > 0, distance for placing 6-th hedging deal
extern double distance6 = 0 ; // If > 0, distance for placing 7-th hedging deal
extern double distance7 = 0 ; // If > 0, distance for placing 8-th hedging deal
extern double distance8 = 0 ; // If > 0, distance for placing 9-th hedging deal
extern double distance9 = 0 ; // If > 0, distance for placing 10-th hedging deal
extern double normal_spread = 0 ; // This value in pips is substracted from SELL takeprofit and added to SELL stoploss to consider the spread
extern string sep0 = " common EA settings " ;
extern int params_digits = 4 ; // If = 4, then stoploss, takeprofit and distances are specified in 4-digit points, if = 5, then in 5-digit pips
extern int initial_magic1 = 123000 ; // Initial magic for 1-st strategy. Hedging deals add 1 to this number
extern int initial_magic2 = 223000 ; // Initial magic for 2-nd strategy. Hedging deals add 1 to this number
// Magic numbers must have difference at least by 100
extern int market_execution = 0 ; // Set to 1 for ECN and STP accounts (stoploss and takeprofit are modified only after an order is sent)
extern int command_attempts = 5 ; // Number of simultaneous attempts of sending broker requests (if some error occurs)
extern int max_slippage = 10 ; // Maximum slippage


int go = true ;
double point, d_stoplevel, d_freezelevel, d_buystop, d_sellstop, d_buytake, d_selltake ;
int errors = 0 ;
int lotsdigits ;


double dist [10] ;


int init()
{
   if (IsTesting () || IsOptimization ())
   {
      GlobalVariableDel ("DailyLimit") ;  
   }
   if (takeprofit <= 0)
   {
      go = false ;
      return ;
   }
   if (distance0 <= 0)
   {
      distance0 = takeprofit ;
   }
   point = MathPow (0.1, params_digits) ;   
   d_freezelevel = MarketInfo (Symbol (), MODE_FREEZELEVEL) * Point ;
   d_buystop = NormalizeDouble (stoploss * point, Digits) ;
   d_selltake = NormalizeDouble ((takeprofit - normal_spread) * point, Digits) ;
   d_sellstop = NormalizeDouble ((stoploss + normal_spread) * point, Digits) ;
   d_buytake = NormalizeDouble (takeprofit * point, Digits) ;

   dist [0] = NormalizeDouble (distance0 * point, Digits) ;
   if (distance1 > 0) { dist [1] = NormalizeDouble (distance1 * point, Digits) ; } else { dist [1] = NormalizeDouble (distance0 * point, Digits) ; }
   if (distance2 > 0) { dist [2] = NormalizeDouble (distance2 * point, Digits) ; } else { dist [2] = NormalizeDouble (distance0 * point, Digits) ; }
   if (distance3 > 0) { dist [3] = NormalizeDouble (distance3 * point, Digits) ; } else { dist [3] = NormalizeDouble (distance0 * point, Digits) ; }
   if (distance4 > 0) { dist [4] = NormalizeDouble (distance4 * point, Digits) ; } else { dist [4] = NormalizeDouble (distance0 * point, Digits) ; }
   if (distance5 > 0) { dist [5] = NormalizeDouble (distance5 * point, Digits) ; } else { dist [5] = NormalizeDouble (distance0 * point, Digits) ; }
   if (distance6 > 0) { dist [6] = NormalizeDouble (distance6 * point, Digits) ; } else { dist [6] = NormalizeDouble (distance0 * point, Digits) ; }
   if (distance7 > 0) { dist [7] = NormalizeDouble (distance7 * point, Digits) ; } else { dist [7] = NormalizeDouble (distance0 * point, Digits) ; }
   if (distance8 > 0) { dist [8] = NormalizeDouble (distance8 * point, Digits) ; } else { dist [8] = NormalizeDouble (distance0 * point, Digits) ; }
   if (distance9 > 0) { dist [9] = NormalizeDouble (distance9 * point, Digits) ; } else { dist [9] = NormalizeDouble (distance0 * point, Digits) ; }
   
   lotsdigits = 0 ;
   
   if (MarketInfo (Symbol (), MODE_LOTSTEP) == 0.1)
   {
      lotsdigits = 1 ;
   }
   if (MarketInfo (Symbol (), MODE_LOTSTEP) == 0.01)
   {
      lotsdigits = 2 ;
   }
   if (MarketInfo (Symbol (), MODE_LOTSTEP) == 0.001)
   {
      lotsdigits = 3 ;
   }
}


int start()
{
   if (DailyReached ())
   {
      Comment ("Daily profit is reached. No more trading for today!") ;
      CloseAll () ;
      return ;
   }
   if (! go)
   {
      return ;
   }
   if (errors >= max_errors)
   {
      Comment (
         "Exceeded maximum count of rejects from broker" + "\n" + 
         "See experts tab for the information" + "\n" +
         "Expert should be restarted to continue") ;
      return ;
   }
   if (_IsNotTradeContextBusy () < 0)
   {
      return ;
   }   
   if (! IsTradeAllowed ())
   {
      Comment ("Trade by experts is prohibited") ;
      return ;
   }
   if (! IsConnected () && ! IsTesting () && ! IsOptimization ())
   {
      Comment ("No connection with the trade server") ;
      return ;
   }/*   
   if (stoplevel_is_spread)
   {
      d_stoplevel = NormalizeDouble (Ask - Bid + StoplevelAdd * point, Digits) ;
   }
   else*/
   {
      d_stoplevel = NormalizeDouble (MarketInfo (Symbol (), MODE_STOPLEVEL) * Point + StoplevelAdd * point, Digits) ;
   }

   for (int i = OrdersTotal () - 1; i >= 0; i --)
   {
      if (OrderSelect (i, SELECT_BY_POS) && OrderSymbol () == Symbol () && 
         ((OrderMagicNumber () >= initial_magic1 && OrderMagicNumber () <= initial_magic1 + 100) ||
         (OrderMagicNumber () >= initial_magic2 && OrderMagicNumber () <= initial_magic2 + 100)))
      {
         switch (OrderType ())
         {
            case OP_BUYSTOP:
            case OP_SELLSTOP:
               int tick = OrderTicket () ;
            
               if (OrderSelect (StrToDouble (OrderComment ()), SELECT_BY_TICKET) && OrderCloseTime () > 0)
               {
                  PendingRemove (tick) ;
               }               
               break ;
         }
      }
   }
   if (MyOrders (initial_magic1) == 0) // Open a new
   {
      switch (LastProfitDir (initial_magic1))
      {
         case 0:
            MarketSend (OP_BUY, Lots (), d_buystop, d_buytake, initial_magic1) ;
            
            break ;
         case 1:
            MarketSend (OP_SELL, Lots (), d_sellstop, d_selltake, initial_magic1) ;
      }       
   }
   if (strategy_mode > 0 && MyOrders (initial_magic2) == 0)
   {
      switch (LastProfitDir (initial_magic2))
      {
         case 0:
            MarketSend (OP_BUY, Lots (), d_buystop, d_buytake, initial_magic2) ;
            
            break ;
         case 1:
            MarketSend (OP_SELL, Lots (), d_sellstop, d_selltake, initial_magic2) ;
      }   
   }
   for (i = OrdersTotal () - 1; i >= 0; i --)
   {
      if (OrderSelect (i, SELECT_BY_POS) && OrderSymbol () == Symbol () && 
            ((OrderMagicNumber () >= initial_magic1 && OrderMagicNumber () <= initial_magic1 + 100) ||
            (OrderMagicNumber () >= initial_magic2 && OrderMagicNumber () <= initial_magic2 + 100)))
      {
         switch (OrderType ())
         {
            case OP_BUY:
               if (! HedgeIsSet (OrderMagicNumber () + 1))
               {
                  PendingSend (OP_SELLSTOP, Lots (MagicModolo () + 1), OrderOpenPrice () - dist [MagicModolo () % 10], d_sellstop, d_selltake, OrderMagicNumber () + 1, DoubleToStr (OrderTicket (), 0)) ;
               }
               break ;
               
            case OP_SELL:
               if (! HedgeIsSet (OrderMagicNumber () + 1))
               {
                  PendingSend (OP_BUYSTOP, Lots (MagicModolo () + 1), OrderOpenPrice () + dist [MagicModolo () % 10], d_buystop, d_buytake, OrderMagicNumber () + 1, DoubleToStr (OrderTicket (), 0)) ;
               }
               break ;
         }
      }
   }
}

int ErrorBlock (int err, int ms)
{
   string str = "" ;
   int res = EB_TERMINATE ;

   switch (err)
   {
      case ERR_NO_ERROR:
         str = "No error" ;
         
         break ;
      case ERR_NO_RESULT:
         str = "Unknown result" ;
         
         break ;
      case ERR_COMMON_ERROR:
         str = "Common error. Probably the signal was rejected by user or trade direction is denied in expert settings" ;
         
         
         break ;
      case ERR_INVALID_TRADE_PARAMETERS:
         str = "Wrong trade function parameters" ;
         
         break ;
      case ERR_SERVER_BUSY:
         str = "Server is busy. Waiting..." ;
         res = EB_WAITTRY ;
         
         break ;
      case ERR_OLD_VERSION:
         str = "Old version of client terminal" ;
         
         break ;
      case ERR_NO_CONNECTION:
         str = "No connection with trade server. Waiting..." ;
         res = EB_WAITTRY ;
      
         break ;
      case ERR_NOT_ENOUGH_RIGHTS:
         str = "Not enough rights" ;
         
         break ;   
      case ERR_TOO_MANY_REQUESTS:
      case ERR_TOO_FREQUENT_REQUESTS:
         str = "To many requests" ;
         
         break ;
      case ERR_MALFUNCTIONAL_TRADE:
         str = "Malfunctional trade" ;
         
         break ;
      case ERR_ACCOUNT_DISABLED:
         str = "The account is blocked" ;
         
         break ;
      case ERR_INVALID_ACCOUNT:
         str = "Invalid account" ;
         
         break ;
      case ERR_TRADE_TIMEOUT:
         str = "Trade timeout exceeded" ;
         res = EB_NEXTTRY ;
         
         break ;
      case ERR_INVALID_PRICE:
         str = "Wrong price" ;
         res = EB_NEXTTRY ;
         
         break ;
      case ERR_INVALID_STOPS:
         str = "Invalid stops" ;

         break ;
      case ERR_INVALID_TRADE_VOLUME:
         str = "Invalid trade volume" ;
         
         break ;
      case ERR_MARKET_CLOSED:
         str = "The market is closed" ;
         
         break ;
      case ERR_TRADE_DISABLED:
         str = "Trade is disabled" ;
         
         break ;
      case ERR_NOT_ENOUGH_MONEY:
         str = "Not enough money to complete operation" ;
         
         break ;
      case ERR_PRICE_CHANGED:
         str = "The price has changed, trying again" ;
         res = EB_NEXTTRY ;
         
         break ;
      case ERR_OFF_QUOTES:
         str = "The broker sent offquotes. Trying again" ;
         res = EB_NEXTTRY ;
         
         break ;
      case ERR_BROKER_BUSY:
         str = "The broker is budy. Waiting..." ;
         res = EB_WAITTRY ;
         
         break ;
      case ERR_REQUOTE:
         str = "The broker sent requote. Trying again" ;
         res = EB_WAITTRY ;
         
         break ;
      case ERR_ORDER_LOCKED:
         str = "The order is already processing" ;
         
         break ;
      case ERR_LONG_POSITIONS_ONLY_ALLOWED:
         str = "Only long positions allowed" ;
         
         break ;
      case ERR_TRADE_MODIFY_DENIED:
         str = "Modification is denied because the order is too close to the price" ;
         res = EB_WAITTRY ;
         
         break ;
      case ERR_TRADE_CONTEXT_BUSY: 
         if (_IsNotTradeContextBusy () >= 0)
         {
            res = EB_NEXTTRY ;
         }
         return (res) ;
         
      case ERR_TRADE_EXPIRATION_DENIED:
         str = "Expiration date usage is denied by the broker" ;
         
         break ;
      case ERR_TRADE_TOO_MANY_ORDERS:
         str = "Too many orders" ;
         
         break ;
      case ERR_TRADE_HEDGE_PROHIBITED:
         str = "Hedging is denied by broker" ;
         
         break ;
      case ERR_TRADE_PROHIBITED_BY_FIFO:
         str = "Cannot close a deal because FIFO order is violated" ;
         
         break ;
      case 4107:
         str = "Wrong price for OrderSend function" ;
         
         break ;      
      case 4051:
         str = "Wrong takeprofit for OrderModify function" ;
      default:
      
         str = "Unknown error №" + DoubleToStr (err, 0) ;
   }  
   str = StringConcatenate (str, " (the request is processed by broker in ", DoubleToStr (GetTickCount () - ms, 0), " ms)") ;
   
   Print (str) ;
   return (res) ;
}

int _IsNotTradeContextBusy()
  {
// проверяем, свободен ли торговый поток
	  if(IsTradeContextBusy())
	    {
		     int StartWaitingTime = GetTickCount();
		     Print("Trade context is busy. Waiting...");
		     // бесконечный цикл
		     while(true)
		       {
			        // если ожидание длится дольше времени, указанного в переменной 
			        // MaxWaiting_sec, тоже прекращаем работу
			        if(GetTickCount() - StartWaitingTime > sec_wait_context * 1000)
			          {
				           Print("Waiting limit exceeded (" + sec_wait_context + " sec.)!");
				           return(-2);
			          }
			        // если торговый поток освободился,
			        if(!IsTradeContextBusy())
			          {
				           //Print("торговый поток освободился");
				           return(0);
			          }
			        // если ни одно из условий остановки цикла не сработало, 
			        // "ждём" 0,1 секунды и начинаем проверку сначала
			        Sleep( busysleep );
		       }
	    }
	  else
	    {
		     //Print("Торговый поток свободен!");
		     return(1);
	    }
  }



int MarketModify (int tick, double stop, double take)
{
   if (! OrderSelect (tick, SELECT_BY_TICKET) || OrderType () >= 2 || OrderCloseTime () > 0)
   {
      Print ("Wrong ticket for MarketModify function") ;
      return (-3) ;  
   }
   double use_sl = 0, use_tp = 0 ;
   
   if (stop > 0)
   {
      if (OrderType () == OP_BUY)
      {
         use_sl = OrderOpenPrice () - stop ;
      }
      else
      {
         use_sl = OrderOpenPrice () + stop ;
      }
   }
   if (stop < 0)
   {
      use_sl = -stop ;
   }
   if (take > 0)
   {
      if (OrderType () == OP_BUY)
      {
         use_tp = OrderOpenPrice () + take ;
      }
      else
      {
         use_tp = OrderOpenPrice () - take ;
      }
   }
   if (take < 0)
   {
      use_tp = -take ;
   }
   if (MathAbs (OrderStopLoss () - use_sl) < Point && MathAbs (use_tp - OrderTakeProfit ()) < Point)
   {
      Print ("There was an attempt to modify market order without changes to TP and SL") ;
      return (-3) ;
   }

   int attempt = 1 ;
   bool result = false ;
   
   while (attempt <= command_attempts && ! result)
   {/*
      if ((OrderType () == OP_BUY && (MarketInfo (OrderSymbol (), MODE_BID) - use_sl < d_stoplevel || use_tp - MarketInfo (OrderSymbol (), MODE_BID) < d_stoplevel)) || 
          (OrderType () == OP_SELL && (use_sl - MarketInfo (OrderSymbol (), MODE_ASK) < d_stoplevel || MarketInfo (OrderSymbol (), MODE_ASK) - use_tp < d_stoplevel)))
      {
         Print ("Couldn''t modify order ", tick, " because of broker stops level") ;
         return (-2) ;
      }
      if ((OrderType () == OP_BUY && (MarketInfo (OrderSymbol (), MODE_BID) - use_sl < d_freezelevel || use_tp - MarketInfo (OrderSymbol (), MODE_BID) < d_freezelevel)) || 
          (OrderType () == OP_SELL && (use_sl - MarketInfo (OrderSymbol (), MODE_ASK) < d_freezelevel || MarketInfo (OrderSymbol (), MODE_ASK) - use_tp < d_freezelevel)))
      {
         Print ("Couldn''t modify order ", tick, " because its level is too close to the price") ;
         return (-2) ;
      }*/

      int ms = GetTickCount () ;
      
      Print ("Attempt #", attempt, " to modify market order ", tick, " to stoploss ", DoubleToStr (use_sl, Digits), " and takeprofit ", DoubleToStr (use_tp, Digits)) ;
      result = OrderModify (tick, OrderOpenPrice (), use_sl, use_tp, 0) ;
      
      if (! result)
      {
         errors ++ ;
      
         int err = GetLastError () ;
         
         switch (ErrorBlock (err, ms))
         {
            case 0: // continue
            
               break ;
            case 1: // wait and continue
               Sleep (wait_error) ;
               
               break ;
            case 2: // terminate
               return (-1) ;
         }
      }
      else
      {
         errors = 0 ;
         Print ("Order successfully modified in ", GetTickCount () - ms, " ms") ;
      }
      if (errors > max_errors)
      {
         Print ("Exceeded maximum errors count while trying to send trading command.") ;
         Print ("To continue you should restart terminal or the EA") ; 
         return (-1) ;
      }
      attempt ++ ;
      
      if (attempt > command_attempts && ! result)
      {
         return (-1) ;
      }      
   }      
   return (1) ;
}


int PendingSend (int type, double lots, double price, double stop, double take, int magic_number, string comm)
{
   if (type < 2 || type > 5)
   {
      Print ("Error in type of pending order!") ;
      return (-3) ;
   }
   bool price_err = false, sltp_err = false ;
   
   RefreshRates () ;
   double use_sl = 0, use_tp = 0 ;
   
   if (stop > 0 && stop < d_stoplevel)
   {
      Print ("Stoploss for sending pending order is lesser that stops level!") ;
      return (-3) ;
   }
   if (take > 0 && take < d_stoplevel)
   {
      Print ("Takeprofit for sending pending order is lesser that stops level!") ;
      return (-3) ;
   }
   switch (type)
   {
      case OP_BUYLIMIT:
         if (Ask - price < d_stoplevel)
         {
            price_err = true ;
         }
         if (stop != 0)
         {
            if (stop > 0)
            {
               use_sl = price - stop ;
            }           
            else
            {
               use_sl = -stop ;
            
               if (price - use_sl < d_stoplevel)
               {
                  Print ("Stoploss for sending pending order is lesser that stops level!") ;
                  return (-3) ;
               }
            }
         }
         if (take != 0)
         {
            if (take > 0)
            {
               use_tp = price + take ;
            }           
            else
            {
               use_tp = -take ;
            
               if (use_tp - price < d_stoplevel)
               {
                  Print ("Takeprofit for sending pending order is lesser that stops level!") ;
                  return (-3) ;
               }
            }
         }
         break ;
         
      case OP_SELLLIMIT:
         if (price - Bid < d_stoplevel)
         {
            price_err = true ;
         }
         if (stop != 0)
         {
            if (stop > 0)
            {
               use_sl = price + stop ;
            }           
            else
            {
               use_sl = -stop ;
            
               if (use_sl - price < d_stoplevel)
               {
                  Print ("Stoploss for sending pending order is lesser that stops level!") ;
                  return (-3) ;
               }
            }
         }
         if (take != 0)
         {
            if (take > 0)
            {
               use_tp = price - take ;
            }           
            else
            {
               use_tp = -take ;
            
               if (price - use_tp < d_stoplevel)
               {
                  Print ("Takeprofit for sending pending order is lesser that stops level!") ;
                  return (-3) ;
               }
            }
         }
         break ;
         
      case OP_BUYSTOP:
         if (price - Ask < d_stoplevel)
         {
            price_err = true ;
         }
         if (stop != 0)
         {
            if (stop > 0)
            {
               use_sl = price - stop ;
            }           
            else
            {
               use_sl = -stop ;
            
               if (price - use_sl < d_stoplevel)
               {
                  Print ("Stoploss for sending pending order is lesser that stops level!") ;
                  return (-3) ;
               }
            }
         }
         if (take != 0)
         {
            if (take > 0)
            {
               use_tp = price + take ;
            }           
            else
            {
               use_tp = -take ;
            
               if (use_tp - price < d_stoplevel)
               {
                  Print ("Takeprofit for sending pending order is lesser that stops level!") ;
                  return (-3) ;
               }
            }
         }
         break ;
         
      case OP_SELLSTOP:
         if (Bid - price < d_stoplevel)
         {
            price_err = true ;
         }
         if (stop != 0)
         {
            if (stop > 0)
            {
               use_sl = price + stop ;
            }           
            else
            {
               use_sl = -stop ;
            
               if (use_sl - price < d_stoplevel)
               {
                  Print ("Stoploss for sending pending order is lesser that stops level!") ;
                  return (-3) ;
               }
            }
         }
         if (take != 0)
         {
            if (take > 0)
            {
               use_tp = price - take ;
            }           
            else
            {
               use_tp = -take ;
            
               if (price - use_tp < d_stoplevel)
               {
                  Print ("Takeprofit for sending pending order is lesser that stops level!") ;
                  return (-3) ;
               }
            }
         }
         break ;
   }
   int attempt = 1 ;
   int tick = -1 ;
   
   while (attempt <= command_attempts && tick < 0)
   {
      RefreshRates () ;

      if ((type == OP_BUYLIMIT && Ask - price < d_stoplevel) ||
         (type == OP_SELLLIMIT && price - Bid < d_stoplevel) ||
         (type == OP_BUYSTOP && price - Ask < d_stoplevel) ||
         (type == OP_SELLSTOP && Bid - price < d_stoplevel))
      {
         Print ("Cannot set a pending orders due to minimal broker stops&limits level (", DoubleToStr (type, 0), " ", DoubleToStr (price, Digits), " ", 
            DoubleToStr (use_sl, Digits), " ", DoubleToStr (use_tp, Digits), ") (", DoubleToStr (Ask, Digits), " ", DoubleToStr (Bid, Digits), ")") ;
         return (-2) ;
      }
      string str = StringConcatenate ("Attempt ", DoubleToStr (attempt, 0), " to set an order ") ;
      
      switch (type)
      {
         case OP_BUYLIMIT: str = StringConcatenate (str, "Buy Limit") ; break ;
         case OP_SELLLIMIT: str = StringConcatenate (str, "Sell Limit") ; break ;
         case OP_BUYSTOP: str = StringConcatenate (str, "Buy Stop") ; break ;
         case OP_SELLSTOP: str = StringConcatenate (str, "Sell Stop") ;
      }
      str = StringConcatenate (str, " at price ", DoubleToStr (price, Digits), " stop ", DoubleToStr (use_sl, Digits), " take ", DoubleToStr (use_tp, Digits)) ;
      Print (str) ;
      
      int ms = GetTickCount () ;
      tick = OrderSend (Symbol (), type, lots, price, 0, use_sl, use_tp, comm, magic_number) ;
      
      if (tick < 0)
      {
         errors ++ ;
      
         int err = GetLastError () ;
         
         switch (ErrorBlock (err, ms))
         {
            case 0: // continue
            
               break ;
            case 1: // wait and continue
               Sleep (wait_error) ;
               
               break ;
            case 2: // terminate
               return (-1) ;
         }
      }
      else
      {
         errors = 0 ;
         Print ("Order is set in ", GetTickCount () - ms, " ms") ;
      }
      if (errors > max_errors)
      {
         Print ("Exceeded maximum errors count while trying to send trading command.") ;
         Print ("To continue you should restart terminal or the EA") ; 
         return (-1) ;
      }
      attempt ++ ;
      
      if (attempt > command_attempts && tick < 0)
      {
         Print ("Exeeded maximum number of simultaneous attempts of setting an order") ;
         return (-1) ;
      }
   }
   return (tick) ;
}


int MarketSend (int dir, double lots, double stop, double take, int magic_number)
{
   if (dir != OP_BUY && dir != OP_SELL)
   {
      Print ("Wrong order direction for function MarketSend") ;
      return (-3) ;
   }
   RefreshRates () ;

   double init_ask = Ask ;
   double init_bid = Bid ;

   if ((stop > 0 && stop < d_stoplevel) || (stop < 0 && ((dir == OP_BUY && Ask + stop < d_stoplevel) || (dir == OP_SELL && -stop - Bid < d_stoplevel))))
   {
      Print ("Wrong stoploss value for function MarketSend. Sending w/o stop") ;
      return (-3) ;
   }
   if ((take > 0 && take < d_stoplevel) || (take < 0 && ((dir == OP_BUY && -take - Ask < d_stoplevel) || (dir == OP_SELL && Bid + take < d_stoplevel))))
   {
      Print ("Wrong takeprofit value for function MarketSend. Sending w/o take") ;
      return (-3) ;
   }
   double use_sl, use_tp, price ;
   int attempt = 1, tick = -1 ;
      
   while (attempt <= command_attempts && tick < 0)
   {
      double _slp ;
      int use_slp ;
      
      if (dir == OP_BUY)
      {
         _slp = (Ask - init_ask) / Point ;
         use_slp = max_slippage - _slp ;
      }
      else
      {
         _slp = (init_bid - Bid) / Point ;
         use_slp = max_slippage - _slp ;
      }
      if (use_slp < 0)
      {
         Print ("Maximal slippage exceeded while trying to open market order") ;
         return (-2) ;
      }
      if (dir == OP_BUY)
      {
         price = Ask ;
      }
      else
      {
         price = Bid ;
      }
      use_sl = 0 ;
      use_tp = 0 ;
      
      if (market_execution == 0)
      {
         if (stop > 0)
         {
            if (dir == OP_BUY)
            {
               use_sl = Ask - stop ;
            }
            else
            {
               use_sl = Bid + stop ;
            }
         }
         if (stop < 0)
         {
            if (dir == OP_BUY)
            {
               if (Ask + stop < d_stoplevel)
               {
                  Print ("Stoploss is under broker stop levels while sending BUY") ;
                  return (-2) ;
               }
               else
               {
                  use_sl = -stop ;
               }
            }
            else
            {
               if (-stop - Bid < d_stoplevel)
               {
                  Print ("Stoploss is under broker stop levels while sending SELL") ;
                  return (-2) ;
               }
               else
               {
                  use_sl = -stop ;
               }
            }
         }
         if (take > 0)
         {
            if (dir == OP_BUY)
            {
               use_tp = Ask + take ;
            }
            else
            {
               use_tp = Bid - take ;
            }
         }
         if (take < 0)
         {
            if (dir == OP_BUY)
            {
               if (-take - Ask < d_stoplevel)
               {
                  Print ("Takeprofit is under broker stop levels while sending BUY") ;
                  return (-2) ;
               }
               else
               {
                  use_tp = -take ;
               }
            }
            else
            {
               if (Bid + take < d_stoplevel)
               {
                  Print ("Takeprofit is under broker stop levels while sending SELL") ;
                  return (-2) ;
               }
               else
               {
                  use_tp = -take ;
               }
            }
         }
      }
      string str = StringConcatenate ("Attempt ", DoubleToStr (attempt, 0), " of sending order") ;
      
      if (dir == OP_BUY)
      {
         str = StringConcatenate (str, " BUY ") ;
      }
      else
      {
         str = StringConcatenate (str, " SELL ") ;
      }
      str = StringConcatenate (str, "at price ", DoubleToStr (price, Digits), " stop ", DoubleToStr (use_sl, Digits), " take ", DoubleToStr (use_tp, Digits)) ;
      Print (str) ;
      
      int ms = GetTickCount () ;
      tick = OrderSend (Symbol (), dir, lots, price, use_slp, use_sl, use_tp, "", magic_number) ;
      
      if (tick < 0)
      {
         errors ++ ;
      
         int err = GetLastError () ;
         
         if (err == ERR_INVALID_STOPS)
         {
            if (market_execution == 0)
            {
               if (stop != 0 || take != 0)
               {
                  Print ("Incorrect stops. Maybe broker increased stop levels") ;
                  return (-2) ;
               }
               else
               {
                  Print ("Incorrect stops while stop and take = 0. Error in expert logic") ;
                  return (-3) ;
               }
            }
            else
            {
               Print ("Incorrect stops with Market Execution. Error in expert logic") ;
               return (-3) ;
            }
         }
         else
         {         
            switch (ErrorBlock (err, ms))
            {
               case 0: // continue
               
                  break ;
               case 1: // wait and continue
                  Sleep (wait_error) ;
                  
                  break ;
               case 2: // terminate
                  return (-1) ;
            }
         }
      }
      else
      {
         errors = 0 ;
         OrderSelect (tick, SELECT_BY_TICKET) ;
         
         str = StringConcatenate ("Order was opened in ", DoubleToStr (GetTickCount () - ms, 0), " ms") ;
         double r_slp ;
         
         if (MathAbs (OrderOpenPrice () - price) >= Point)
         {
            if (OrderType () == OP_BUY)
            {
               r_slp = (OrderOpenPrice () - price) / Point ;
            }
            else
            {
               r_slp = (price - OrderOpenPrice ()) / Point ;
            }
            str = StringConcatenate (str, " with slippage ", DoubleToStr (MathAbs (r_slp), 0), " pips") ;
            
            if (r_slp < 0)
            {
               str = StringConcatenate (str, " in our benefit") ;
            }
         }
         Print (str) ;
         
         if (market_execution == 1 && (stop != 0 || take != 0))
         {
            MarketModify (OrderTicket (), stop, take) ;              
         }
      }
      if (errors > max_errors)
      {
         Print ("Exceeded maximum errors count while trying to send trading command.") ;
         Print ("To continue you should restart terminal or the EA") ; 
         return (-1) ;
      }
      attempt ++ ;
      
      if (attempt > command_attempts && tick < 0)
      {
         Print ("Exeeded maximum number of simultaneous attempts of setting an order") ;
         return (-1) ;
      }
      RefreshRates () ;
   }
   return (tick) ;
}

int MyOrders (int magic)
{
   int num = 0 ;
   
   for (int i = OrdersTotal () - 1; i >= 0; i --)
   {
      if (OrderSelect (i, SELECT_BY_POS) && OrderSymbol () == Symbol () && OrderMagicNumber () >= magic && OrderMagicNumber () < magic + 100)
      {
         num ++ ;
      }
   }  
   return (num) ;
}

int LastProfitDir (int magic)
{
   int dir = initial_deal, pos = OrdersHistoryTotal () - 1, i = 0 ;
   
   if (magic == initial_magic2)
   {
      if (dir == 0) dir = 1 ; else dir = 0 ;
   }
     
   while (i < 100 && pos >= 0)
   {
      if (OrderSelect (pos, SELECT_BY_POS, MODE_HISTORY) && OrderMagicNumber () >= magic && OrderMagicNumber () < magic + 100 && OrderType () < 2)
      {
//         if (OrderOpenTime () < TimeCurrent () - TimeCurrent () % 86400)
//         {
//            break ;
//         }
         if (OrderProfit () > 0 && TimeCurrent () - OrderCloseTime () < 300)
         {
            switch (OrderType ())
            {
               case OP_BUY:
                  dir = 0 ;
                  
                  break ;
               case OP_SELL:
                  dir = 1 ;
                  
                  break ;           
            }      
            if (strategy_mode > 0)
            {
               if (dir == 0) dir = 1 ; else dir = 0 ;
            }
            break ;
         }
      }
      i ++ ;
      pos -- ;
   }
   return (dir) ;
}

int PendingRemove (int tick)
{
   if (! OrderSelect (tick, SELECT_BY_TICKET) || OrderType () < 2 || OrderType () > 5 || OrderCloseTime () > 0)
   {
      Print ("Wrong ticket for function PendingRemove") ;
      return (-3) ;  
   }
   
   int attempt = 1 ;
   bool result = false ;
   
   while (attempt <= command_attempts && ! result)
   {
      switch (OrderType ())
      {
         case OP_BUYLIMIT:
            if (Ask - OrderOpenPrice () < d_freezelevel)
            {
               Print ("Unable to delete order ", tick, " because it is too close to the market") ;
               return (-2) ;
            }
            break ;
            
         case OP_BUYSTOP:
            if (OrderOpenPrice () - Ask < d_freezelevel)
            {
               Print ("Unable to delete order ", tick, " because it is too close to the market") ;
               return (-2) ;
            }
            break ;
            
         case OP_SELLLIMIT:
            if (OrderOpenPrice () - Bid < d_freezelevel)
            {
               Print ("Unable to delete order ", tick, " because it is too close to the market") ;
               return (-2) ;
            }
            break ;
            
         case OP_SELLSTOP:
            if (Bid - OrderOpenPrice () < d_freezelevel)
            {
               Print ("Unable to delete order ", tick, " because it is too close to the market") ;
               return (-2) ;
            }
            break ;
      }
      int ms = GetTickCount () ;
      
      Print ("Attempt ", attempt, " to remove pending order ", tick) ;
      result = OrderDelete (tick) ;
      
      if (! result)
      {
         errors ++ ;
      
         int err = GetLastError () ;
         
         switch (ErrorBlock (err, ms))
         {
            case 0: // continue
            
               break ;
            case 1: // wait and continue
               Sleep (wait_error) ;
               
               break ;
            case 2: // terminate
               return (-1) ;
         }
      }
      else
      {
         errors = 0 ;
         Print ("Order was removed in ", GetTickCount () - ms, " ms") ;
      }
      if (errors > max_errors)
      {
         Print ("Exceeded maximum errors count while trying to send trading command.") ;
         Print ("To continue you should restart terminal or the EA") ; 
         return (-1) ;
      }
      attempt ++ ;
      
      if (attempt > command_attempts && tick < 0)
      {
         Print ("Exeeded maximum number of simultaneous attempts of setting an order") ;
         return (-1) ;
      }      
   }
   return (1) ;
}

double Lots (int leg = 0)
{
   double lot = 0 ;

   if (fixed_lot > 0)
   {
      lot = fixed_lot ;
   }
   else
   {
      if (deposit_lot > 0)
      {
         lot = AccountBalance () / deposit_lot ;
      }
   }
   for (int i = 1; i <= leg; i ++)
   {
      if (i == 1)
      {
         lot *= martin_koeff1 ;
      }
      else
      {
         lot *= martin_koeff2 ;
      }
   }
   return (NormalizeDouble (MathMax (MathMin (MarketInfo (Symbol (), MODE_MAXLOT), lot), MarketInfo (Symbol (), MODE_MINLOT)), lotsdigits)) ;
}

bool HedgeIsSet (int magic)
{
   int tick = OrderTicket () ;
   
   for (int i = OrdersTotal () - 1; i >= 0; i --)
   {
      if (OrderSelect (i, SELECT_BY_POS) && OrderSymbol () == Symbol () && OrderMagicNumber () == magic)
      {
         return (true) ;
      }
   }
   OrderSelect (tick, SELECT_BY_TICKET) ;
   
   return (false) ;
}

bool DailyReached ()
{
   // Calculate Balance on the start of the day
   double start_balance = AccountBalance () ;
   int day_start = TimeCurrent () - TimeCurrent () % 86400 ;
   
   if (enable_daily_profit < 1)
   {
      return (false) ;
   }   
   if (GlobalVariableGet ("DailyLimit") > TimeCurrent ())
   {
      return (true) ;
   }
   
   for (int i = OrdersHistoryTotal () - 1; i >= 0; i --)
   {
      if (OrderSelect (i, SELECT_BY_POS, MODE_HISTORY) && 
         ((OrderMagicNumber () >= initial_magic1 && OrderMagicNumber () < initial_magic1 + 100) ||
          (OrderMagicNumber () >= initial_magic2 && OrderMagicNumber () < initial_magic2 + 100)) && OrderType () < 2)
      {
         if (OrderOpenTime () < day_start)
         {
            break ;
         }
         else
         {
            start_balance -= OrderProfit () - OrderCommission () - OrderSwap () ;
         }
      }
   }  
   if ((daily_profit > 0 && AccountEquity () - start_balance >= daily_profit) ||
         (daily_profit_percent > 0 && (AccountEquity () - start_balance) / start_balance * 100 >= daily_profit_percent))
   {
      GlobalVariableSet ("DailyLimit", day_start + 86400) ;
      return (true) ;
   }
   return (false) ;
}

void CloseAll ()
{
   for (int i = OrdersTotal () - 1; i >= 0; i --)
   {
      if (OrderSelect (i, SELECT_BY_POS) && OrderSymbol () == Symbol () && 
         ((OrderMagicNumber () >= initial_magic1 && OrderMagicNumber () < initial_magic1 + 100) ||
          (OrderMagicNumber () >= initial_magic2 && OrderMagicNumber () < initial_magic2 + 100)))
      {
         switch (OrderType ())
         {
            case OP_BUYSTOP:
            case OP_SELLSTOP:
               OrderDelete (OrderTicket ()) ;
               
               break ;
            case OP_BUY:
               OrderClose (OrderTicket (), OrderLots (), Bid, max_slippage) ;
               
               break ;
            case OP_SELL:
               OrderClose (OrderTicket (), OrderLots (), Ask, max_slippage) ;
               
               break ;
         }
      }
   }  
}

int MagicModolo ()
{
   if (OrderMagicNumber () >= initial_magic1 && OrderMagicNumber () < initial_magic1 + 100)
   {
      return (OrderMagicNumber () - initial_magic1) ;
   }
   if (OrderMagicNumber () >= initial_magic2 && OrderMagicNumber () < initial_magic2 + 100)
   {
      return (OrderMagicNumber () - initial_magic2) ;
   }
   return (0) ;
}