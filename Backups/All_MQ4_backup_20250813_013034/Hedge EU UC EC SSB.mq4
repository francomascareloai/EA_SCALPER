//+------------------------------------------------------------------+
//|Dryclean's Brijon game playing multi-pairauto trader by SteveHopwood.mq4 |
//|                                  Copyright © 2010, Steve Hopwood |
//|                              http://www.hopwood3.freeserve.co.uk |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Steve Hopwood"
#property link      "http://www.hopwood3.freeserve.co.uk"
#include <WinUser32.mqh>
#include <stdlib.mqh>
#define  NL    "\n"



/*
void DisplayUserFeedback()


void CalculateNoOfTrades()
bool O_R_CheckForHistory(int ticket) //Cheers Matt
void CalculateBasketUpl()
bool DoesTradeExist(string symbol)
bool SendSingleTrade(string symbol, int type, string comment, double lotsize, double price, double stop, double take)
void SendTrades()
bool CloseAllTrades()
void LookForSecondTradeOpportunity()
int HowManyTradesOpenAlready(string symbol)



*/

extern double  Lot=1.0;
extern int     MagicNumber=102;
extern string  TradeComment="Hedge SSB";
extern double  CashProfitTarget=100;
extern bool    ContinueTrading = true;
extern int     PipsToSecondTrade=0;
extern bool    AllowHedging=false;
extern int     HedgeAtLossPips=40;
extern string  lts="----Buy pairs----";
extern string	BuyPairs = "EURCHF";
extern string  sts="----Sell pairs----";
extern string	SellPairs = "EURUSD,USDCHF";
extern bool    UseDrycleanPairs=false;
extern string  tt="----Trading hours----";
extern string  Trade_Hours= "Set Morning & Evening Hours";
extern string  Trade_Hoursi= "Use 24 hour, local time clock";
extern string  Trade_Hours_M= "Morning Hours 0-12";
extern  int    start_hourm = 0;
extern  int    end_hourm = 12;
extern string  Trade_Hours_E= "Evening Hours 12-24";
extern  int    start_houre = 12;
extern  int    end_houre = 24;

int            PairsTrading, TotBuyPairs, TotSellPairs, NoOfPairs;
string         BuyPairSymbol[], SellPairSymbol[];//Arrays for the trade pairs
double         Upl;
bool           ForceClose=false;
string         ScreenMessage;

string	      BuyPair[], SellPair[];			//Arrays to hold the pairs traded by the user
int            NoOfBuyPairs, NoOfSellPairs;// Holds the number of pairs passed by the user via the inputs screen
string         InputString;//For pair extraction

//Matt's O-R stuff
int 	         O_R_Setting_max_retries 	= 10;
double 	      O_R_Setting_sleep_time 		= 4.0; /* seconds */
double 	      O_R_Setting_sleep_max 		= 15.0; /* seconds */

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
//----

   //sET UP dRYCLEAN'S PAIRS
   if (UseDrycleanPairs)
   {
      BuyPairs = "AUDUSD,EURUSD,USDJPY";
      SellPairs = "GBPCHF,EURJPY,USDCHF";
   }//if (UseDrycleanPairs)
   
   
   ExtractPairs();
   EventSetMillisecondTimer(1);
//----
   return(0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
{
//----
   EventKillTimer();
//----
   return(0);
}

void DisplayUserFeedback()
{

   string Gap = "                                 ";
   
   ScreenMessage = "";
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);
   ScreenMessage = StringConcatenate(ScreenMessage, Gap, TimeToStr(TimeLocal(), TIME_DATE|TIME_MINUTES|TIME_SECONDS), NL );

   int cc;
   
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Upl ", DoubleToStr(Upl, 2), NL);
   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Buy pairs ", NL);
   for (cc = 0; cc < TotBuyPairs; cc++)
   {
      ScreenMessage = StringConcatenate(ScreenMessage, Gap, BuyPairSymbol[cc]);
      ScreenMessage = StringConcatenate(ScreenMessage, ": Long swap ", MarketInfo(BuyPairSymbol[cc], MODE_SWAPLONG));
      //ScreenMessage = StringConcatenate(ScreenMessage, ": Short swap ", MarketInfo(BuyPairSymbol[cc], MODE_SWAPSHORT));
      ScreenMessage = StringConcatenate(ScreenMessage, ": Spread ", MarketInfo(BuyPairSymbol[cc], MODE_SPREAD));
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);
   
   }//for (cc = 0; cc < BuyPairs; cc++)

   ScreenMessage = StringConcatenate(ScreenMessage,Gap, "Sell pairs ", NL);
   for (cc = 0; cc < TotSellPairs; cc++)
   {
      ScreenMessage = StringConcatenate(ScreenMessage, Gap, SellPairSymbol[cc]);
      //ScreenMessage = StringConcatenate(ScreenMessage, ": Long swap ", MarketInfo(SellPairSymbol[cc], MODE_SWAPLONG));
      ScreenMessage = StringConcatenate(ScreenMessage, ": Short swap ", MarketInfo(SellPairSymbol[cc], MODE_SWAPSHORT));
      ScreenMessage = StringConcatenate(ScreenMessage, ": Spread ", MarketInfo(SellPairSymbol[cc], MODE_SPREAD));
      ScreenMessage = StringConcatenate(ScreenMessage,Gap, NL);
   
   }//for (cc = 0; cc < SellPairs; cc++)

   
   Comment(ScreenMessage);
   
}//void DisplayUserFeedback()

void ExtractPairs()
{
   string AddChar = StringSubstr(Symbol(),6,4);
   
   
   //Set up buy pairs
   
   // Cleanup first
   InputString=BuyPairs;
   CleanUpInputString();
   
   // Extract the number of paraaters passed by the user
   CalculatePairsPassed();
   TotBuyPairs = NoOfPairs;
   
   
   // Resize the arrays appropriately
   string NewArray = ArrayResize(BuyPairSymbol, TotBuyPairs);
   
   int Index = 0;//For searching InputString
   int LastIndex = 0;//Points the the most recent Index
   for (int cc = 0; cc < TotBuyPairs; cc ++)
   {
      Index = StringFind(InputString, ",",LastIndex);
      if (Index > -1)
      {
         BuyPairSymbol[cc] = StringSubstr(InputString, LastIndex,Index-LastIndex);
         BuyPairSymbol[cc] = StringTrimLeft(BuyPairSymbol[cc]);
         BuyPairSymbol[cc] = StringTrimRight(BuyPairSymbol[cc]);
         BuyPairSymbol[cc] = StringConcatenate(BuyPairSymbol[cc], AddChar);
         
         LastIndex = Index+1;         
      }//if (Index > -1)            
   }//for (int cc; cc<NoOfPairs; cc ++)

   //Set up sell pairs
   
   // Cleanup first
   InputString=SellPairs;
   CleanUpInputString();
   
   // Extract the number of paraaters passed by the user
   CalculatePairsPassed();
   TotSellPairs = NoOfPairs;
   
   
   // Resize the arrays appropriately
   string NewArray1 = ArrayResize(SellPairSymbol, TotSellPairs);
   
   Index = 0;//For searching InputString
   LastIndex = 0;//Points the the most recent Index
   for (cc = 0; cc < TotSellPairs; cc ++)
   {
      Index = StringFind(InputString, ",",LastIndex);
      if (Index > -1)
      {
         SellPairSymbol[cc] = StringSubstr(InputString, LastIndex,Index-LastIndex);
         SellPairSymbol[cc] = StringTrimLeft(SellPairSymbol[cc]);
         SellPairSymbol[cc] = StringTrimRight(SellPairSymbol[cc]);
         SellPairSymbol[cc] = StringConcatenate(SellPairSymbol[cc], AddChar);
         
         LastIndex = Index+1;         
      }//if (Index > -1)            
   }//for (int cc; cc<NoOfPairs; cc ++)



}//End void ExtractPairs()


void CleanUpInputString()
{
   // Does any tidying up of the user inputs
   
   //Remove unwanted spaces
   InputString = StringTrimLeft(InputString);
   InputString = StringTrimRight(InputString);

   //Add final comma if ommitted by user
   if (StringSubstr(InputString, StringLen(InputString)-1) != ",") 
      InputString = StringConcatenate(InputString,",");
      
   
}//void CleanUpInputString

void CalculatePairsPassed()
{
   // Calculates the numbers of paramaters passed in LongMagicNumber and TradeComment.
   
   int Index = 0;//For searching NoTradePairs
   int LastIndex;//Points the the most recent Index
   NoOfPairs = 0;
   
   while(Index > -1)
      {
         Index = StringFind(InputString, ",",LastIndex);
         if (Index > -1)
         {
            NoOfPairs ++;
            LastIndex = Index+1;            
         }//if (Index > -1)
      }//while(int cc > -1)
   
   
   
}//End void CalculatePairsPassed()



//=============================================================================
//                           O_R_CheckForHistory()
//
//  This function is to work around a very annoying and dangerous bug in MT4:
//      immediately after you send a trade, the trade may NOT show up in the
//      order history, even though it exists according to ticket number.
//      As a result, EA's which count history to check for trade entries
//      may give many multiple entries, possibly blowing your account!
//
//  This function will take a ticket number and loop until
//  it is seen in the history.
//
//  RETURN VALUE:
//     TRUE if successful, FALSE otherwise
//
//
//  FEATURES:
//     * Re-trying under some error conditions, sleeping a random
//       time defined by an exponential probability distribution.
//
//     * Displays various error messages on the log for debugging.
//
//  ORIGINAL AUTHOR AND DATE:
//     Matt Kennel, 2010
//
//=============================================================================
bool O_R_CheckForHistory(int ticket)
{
   //My thanks to Matt for this code. He also has the undying gratitude of all users of my trading robots
   
   int lastTicket = OrderTicket();

   int cnt = 0;
   int err = GetLastError(); // so we clear the global variable.
   err = 0;
   bool exit_loop = false;
   bool success=false;

   while (!exit_loop) {
      /* loop through open trades */
      int total=OrdersTotal();
      for(int c = 0; c < total; c++) {
         if(OrderSelect(c,SELECT_BY_POS,MODE_TRADES) == true) {
            if (OrderTicket() == ticket) {
               success = true;
               exit_loop = true;
            }
         }
      }
      if (cnt > 3) {
         /* look through history too, as order may have opened and closed immediately */
         total=OrdersHistoryTotal();
         for(c = 0; c < total; c++) {
            if(OrderSelect(c,SELECT_BY_POS,MODE_HISTORY) == true) {
               if (OrderTicket() == ticket) {
                  success = true;
                  exit_loop = true;
               }
            }
         }
      }

      cnt = cnt+1;
      if (cnt > O_R_Setting_max_retries) {
         exit_loop = true;
      }
      if (!(success || exit_loop)) {
         Print("Did not find #"+ticket+" in history, sleeping, then doing retry #"+cnt);
         O_R_Sleep(O_R_Setting_sleep_time, O_R_Setting_sleep_max);
      }
   }
   // Select back the prior ticket num in case caller was using it.
   if (lastTicket >= 0) {
      bool k = OrderSelect(lastTicket, SELECT_BY_TICKET, MODE_TRADES);
   }
   if (!success) {
      Print("Never found #"+ticket+" in history! crap!");
   }
   return(success);
}//End bool O_R_CheckForHistory(int ticket)

//=============================================================================
//                              O_R_Sleep()
//
//  This sleeps a random amount of time defined by an exponential
//  probability distribution. The mean time, in Seconds is given
//  in 'mean_time'.
//  This returns immediately if we are backtesting
//  and does not sleep.
//
//=============================================================================
void O_R_Sleep(double mean_time, double max_time)
{
   if (IsTesting()) {
      return;   // return immediately if backtesting.
   }

   double p = (MathRand()+1) / 32768.0;
   double t = -MathLog(p)*mean_time;
   t = MathMin(t,max_time);
   int ms = t*1000;
   if (ms < 10) {
      ms=10;
   }
   Sleep(ms);
}//End void O_R_Sleep(double mean_time, double max_time)

void CalculateBasketUpl()
{
   Upl = 0;
   
   for (int cc = OrdersTotal() - 1; cc >= 0 ; cc--)
   {
      if (!OrderSelect(cc,SELECT_BY_POS, MODE_TRADES)) continue;
      
      if (OrderMagicNumber()==MagicNumber)      
      {
         Upl+= (OrderProfit() + OrderSwap() + OrderCommission() );
      }//if (OrderMagicNumber()==MagicNumber && OrderSymbol() == Symbol() )      
   }//for (int cc = OrdersTotal() - 1; cc >= 0 ; cc--)



}//End void CalculateBasketUpl();


bool DoesTradeExist(string symbol)
{
   
   
   if (OrdersTotal() == 0) return(false);
   
   for (int cc = OrdersTotal() - 1; cc >= 0 ; cc--)
   {
      if (!OrderSelect(cc,SELECT_BY_POS)) continue;
      
      if (OrderMagicNumber()==MagicNumber && OrderSymbol() == symbol )      
      {
         return(true);         
      }//if (OrderMagicNumber()==MagicNumber && OrderSymbol() == Symbol() )      
   }//for (int cc = OrdersTotal() - 1; cc >= 0 ; cc--)

   return(false);

}//End bool DoesTradeExist()


bool SendSingleTrade(string symbol, int type, string comment, double lotsize, double price, double stop, double take)
{
   
   
   int slippage = 10;
   if (Digits == 3 || Digits == 5) slippage = 100;
   
   color col = Red;
   if (type == OP_BUY || type == OP_BUYSTOP) col = Green;
   
   int expiry = 0;
   //if (SendPendingTrades) expiry = TimeCurrent() + (PendingExpiryMinutes * 60);

   //if (!CriminalIsECN) int ticket = OrderSend(Symbol(),type, lotsize, price, slippage, stop, take, comment, MagicNumber, expiry, col);
   int ticket = OrderSend(symbol,type, lotsize, price, slippage, stop, take, comment, MagicNumber, expiry, col);
   
   /*
   //Is a 2 stage criminal
   if (CriminalIsECN)
   {
      bool result;
      int err;
      ticket = OrderSend(Symbol(),type, lotsize, price, slippage, 0, 0, comment, MagicNumber, expiry, col);
      if (ticket > 0)
      {
	     
	     if (take > 0 && stop > 0)
        {
           while(IsTradeContextBusy()) Sleep(100);
           result = OrderModify(ticket, OrderOpenPrice(), stop, take, OrderExpiration(), CLR_NONE);
           if (!result)
           {
               err=GetLastError();
               Print(Symbol(), " SL/TP  order modify failed with error(",err,"): ",ErrorDescription(err));               
           }//if (!result)			  
        }//if (take > 0 && stop > 0)
      
	     if (take != 0 && stop == 0)
        {
           while(IsTradeContextBusy()) Sleep(100);
           result = OrderModify(ticket, OrderOpenPrice(), OrderStopLoss(), take, OrderExpiration(), CLR_NONE);
           if (!result)
           {
               err=GetLastError();
               Print(Symbol(), " SL  order modify failed with error(",err,"): ",ErrorDescription(err));               
           }//if (!result)			  
        }//if (take == 0 && stop != 0)

        if (take == 0 && stop != 0)
        {
           while(IsTradeContextBusy()) Sleep(100);
           result = OrderModify(ticket, OrderOpenPrice(), stop, OrderTakeProfit(), OrderExpiration(), CLR_NONE);
           if (!result)
           {
               err=GetLastError();
               Print(Symbol(), " SL  order modify failed with error(",err,"): ",ErrorDescription(err));               
           }//if (!result)			  
        }//if (take == 0 && stop != 0)

      }//if (ticket > 0)
        
      
      
   }//if (CriminalIsECN)
   */
   
   //Error trapping for both
   if (ticket < 0)
   {
      string stype;
      if (type == OP_BUY) stype = "OP_BUY";
      if (type == OP_SELL) stype = "OP_SELL";
      if (type == OP_BUYLIMIT) stype = "OP_BUYLIMIT";
      if (type == OP_SELLLIMIT) stype = "OP_SELLLIMIT";
      if (type == OP_BUYSTOP) stype = "OP_BUYSTOP";
      if (type == OP_SELLSTOP) stype = "OP_SELLSTOP";
      int err=GetLastError();
      Alert(symbol, " ", stype," order send failed with error(",err,"): ",ErrorDescription(err));
      Print(symbol, " ", stype," order send failed with error(",err,"): ",ErrorDescription(err));
      return(false);
   }//if (ticket < 0)  
   
   
   //Make sure the trade has appeared in the platform's history to avoid duplicate trades
   O_R_CheckForHistory(ticket); 
   
   //Got this far, so trade send succeeded
   return(true);
   
}//End bool SendSingleTrade(int type, string comment, double lotsize, double price, double stop, double take)

void SendTrades()
{
   
   double bid, ask;
   int cc;
   
   for (cc = 0; cc < TotBuyPairs; cc++)
   {
      if (!DoesTradeExist(BuyPairSymbol[cc]) )
      {
         ask = MarketInfo(BuyPairSymbol[cc], MODE_ASK);
         bool result = SendSingleTrade(BuyPairSymbol[cc], OP_BUY, TradeComment, Lot, ask, 0, 0);
      }//if (!DoesTradeExist(BuyPairSymbol[cc]) )
   }//for (cc = 0; cc < BuyPairs; cc++)
   
   for (cc = 0; cc < TotSellPairs; cc++)
   {
      if (!DoesTradeExist(SellPairSymbol[cc]) )
      {
         bid = MarketInfo(SellPairSymbol[cc], MODE_BID);
         result = SendSingleTrade(SellPairSymbol[cc], OP_SELL, TradeComment, Lot, bid, 0, 0);
      }//if (!DoesTradeExist(SellPairSymbol[cc]) )
   }//for (cc = 0; cc < SellPairs; cc++)
   
   
   
}//End void SendTrades()

bool CloseAllTrades()
{

   bool success = true;
   
   for (int cc = OrdersTotal() - 1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS, MODE_TRADES) ) continue;
      if (OrderMagicNumber() != MagicNumber) continue;
      while(IsTradeContextBusy() ) Sleep(100);
      bool result = OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), 5000, CLR_NONE);
      if (!result) success = false;
      Sleep(100);
   }//for (int cc = OrdersTotal() - 1; cc >= 0, cc--)
   
   return(success);
}//bool CloseAllTrades()

int HowManyTradesOpenAlready(string symbol)
{

   int tot;
   
   for (int cc = OrdersTotal() -1; cc >= 0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
      if (OrderMagicNumber() != MagicNumber) continue;
      if (OrderSymbol() == symbol) tot++;
   }//for (int cc = OrdersTotal() -1; cc >0; cc--)
   
   return(tot);
   
}//int HowManyTradesOpenAlready(string symbol)


void LookForSecondTradeOpportunity()
{
   //Cycles through the order list and looks for an opportunity to open a second trade
   double ask, bid, point, digits;

  
   for (int cc = OrdersTotal() -1; cc >0; cc--)
   {
      if (!OrderSelect(cc, SELECT_BY_POS) ) continue;
      if (OrderMagicNumber() != MagicNumber) continue;
      //if (OrderProfit() <= 0) continue;
      point = MarketInfo(OrderSymbol(), MODE_POINT);
      digits = MarketInfo(OrderSymbol(), MODE_DIGITS);
      
      //Adapt to x digit criminals
      int multiplier;
      if(digits == 2 || digits == 4) multiplier = 1;
      if(digits == 3 || digits == 5) multiplier = 10;
      if(digits == 6) multiplier = 100;   
      if(digits == 7) multiplier = 1000;   

      //Adapt the user inputs to x digit wally-plonker-dipstick-criminals
      int ptss = PipsToSecondTrade;
      ptss*= multiplier;
      int halp = HedgeAtLossPips;
      halp*= multiplier;
         
      if (OrderType() == OP_BUY)
      {
         RefreshRates();
         ask = MarketInfo(OrderSymbol(), MODE_ASK);
         //Add to profitable position
         if (ask - OrderOpenPrice() >= (ptss * point) )
         {
            int ticket = OrderTicket();
            int OpenTrades = HowManyTradesOpenAlready(OrderSymbol() );
            bool k = OrderSelect(ticket, SELECT_BY_TICKET);
            if (OpenTrades == 1)
            {
               bool result = SendSingleTrade(OrderSymbol(), OP_BUY, TradeComment, Lot, ask, 0, 0);
            }//if (tot == 1)
            
         }//if (ask - OrderOpenPrice() >= (PipsToSecondTrade * point) )
         
         //Hedge loosing trade
         if (AllowHedging && OrderProfit() < 0)
         {
            if (OrderOpenPrice() - ask >= (halp * point) )
            {
               bid = MarketInfo(OrderSymbol(), MODE_BID);         
               ticket = OrderTicket();
               OpenTrades = HowManyTradesOpenAlready(OrderSymbol() );
               k = OrderSelect(ticket, SELECT_BY_TICKET);
               if (OpenTrades == 1)
               {
                  result = SendSingleTrade(OrderSymbol(), OP_SELL, TradeComment, Lot, bid, 0, 0);
               }//if (tot == 1)
            
            }//if (ask - OrderOpenPrice() >= (PipsToSecondTrade * point) )
         }//if (AllowHedgingif (AllowHedging)
         
         
         
      }//if (OrderType() == OP_BUY)
      
      
      if (OrderType() == OP_SELL)
      {
         RefreshRates();
         bid = MarketInfo(OrderSymbol(), MODE_BID);
         //Add to profitable position         
         if (OrderOpenPrice() - bid >= (ptss * point) )
         {
            ticket = OrderTicket();
            OpenTrades = HowManyTradesOpenAlready(OrderSymbol() );
            k = OrderSelect(ticket, SELECT_BY_TICKET);
            if (OpenTrades == 1)
            {
               result = SendSingleTrade(OrderSymbol(), OP_SELL, TradeComment, Lot, bid, 0, 0);
            }//if (tot == 1)
            
         }//if (OrderOpenPrice() - bid >= (PipsToSecondTrade * point) )
         
         //Hedge loosing trade
         if (AllowHedging && OrderProfit() < 0)
         {
            if (bid - OrderOpenPrice() >= (ptss * point) )
            {
               ask = MarketInfo(OrderSymbol(), MODE_ASK);
               ticket = OrderTicket();
               OpenTrades = HowManyTradesOpenAlready(OrderSymbol() );
               k = OrderSelect(ticket, SELECT_BY_TICKET);
               if (OpenTrades == 1)
               {
                  result = SendSingleTrade(OrderSymbol(), OP_BUY, TradeComment, Lot, ask, 0, 0);
               }//if (tot == 1)
            
            }//if bid - (OrderOpenPrice() >= (ptss * point) )
         }//if (AllowHedgingif (AllowHedging)
         
      
      }//if (OrderType() == OP_SELL)
      
      
   }//for (int cc = OrdersTotal() -1; cc >0 0; cc--)
   

}//End void LookForSecondTradeOpportunity()

bool CheckTradingTimes()
{
   int hour = TimeHour(TimeLocal() );
   
   if (end_hourm < start_hourm)
	{
		end_hourm += 24;
	}
	

	if (end_houre < start_houre)
	{
		end_houre += 24;
	}
	
	bool ok2Trade = true;
	
	ok2Trade = (hour >= start_hourm && hour <= end_hourm) || (hour >= start_houre && hour <= end_houre);

	// adjust for past-end-of-day cases
	// eg in AUS, USDJPY trades 09-17 and 22-06
	// so, the above check failed, check if it is because of this condition
	if (!ok2Trade && hour < 12)
	{
 		hour += 24;
		ok2Trade = (hour >= start_hourm && hour <= end_hourm) || (hour >= start_houre && hour <= end_houre);		
		// so, if the trading hours are 11pm - 6am and the time is between  midnight to 11am, (say, 5am)
		// the above code will result in comparing 5+24 to see if it is between 23 (11pm) and 30(6+24), which it is...
	}


   // check for end of day by looking at *both* end-hours

   if (hour >= MathMax(end_hourm, end_houre))
   {      
      ok2Trade = false;
   }//if (hour >= MathMax(end_hourm, end_houre))

   return(ok2Trade);

}//End bool CheckTradingTimes()

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
void OnTimer()
{
  start();
}
int start()
{

   //int loop = 100;
   
   //Endless loop so the bot is not depending on ticks
  // while (loop == 100)
   //{
   
      if (OrdersTotal() == 0) ForceClose = false;
      
      if (ForceClose)
      {
         ForceClose = CloseAllTrades();
      }//if (ForceClose)
      
      if (!ForceClose)
      {
         CalculateBasketUpl();
         if (Upl >= CashProfitTarget)
         {
            ForceClose = CloseAllTrades();
         }//if (Upl >= CashProfitTarget)
      }//if (!ForceClose)

      if (OrdersTotal() > 0 && PipsToSecondTrade > 0) LookForSecondTradeOpportunity();

      /////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //Trading times
      bool TradeTimeOk = CheckTradingTimes();
      if (!TradeTimeOk)
      {
         Comment("Outside trading hours\nstart_hourm-end_hourm: ", start_hourm, "-",end_hourm, "\nstart_houre-end_houre: ", start_houre, "-",end_houre);
         return(0);
      }//if (hour < start_hourm)
      /////////////////////////////////////////////////////////////////////////////////////////////////////////////////

      int countOrders = 0;
      for (int i = OrdersTotal()-1; i >= 0; i --)
      {
        if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        if(OrderMagicNumber() == MagicNumber)         
        countOrders = countOrders + 1;
      }
      if(ContinueTrading && ForceClose)
      ForceClose = false;
      //Open trades
      if (countOrders != (TotBuyPairs + TotSellPairs) && !ForceClose)
      {
         SendTrades();
      }//if (OrdersTotal() != PairsTrading)

      
      
      DisplayUserFeedback();
      
    //  Sleep(1000);
  // }//whlie (loop == 100)
   
return(0);
}//End int start()

//+------------------------------------------------------------------+