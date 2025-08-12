//+------------------------------------------------------------------+
//|                                           Trailing_EA.mq4        |
//|                                              Copyright © 2007    |
//|                                                                  |
//|    Written by Robert Hill aka MrPip for Forex-tsd group          |
//|                                                                  |
//|  Includes 6 different types of trailing stops                    |
//|  Code from IgorAD, KimIV and MrPip modified to be functions      |
//|                                                                  |
//| Version 1.1                                                      |
//|   Added pSAR trailing stop                                       |
//|                                                                  |
//| Added ability to close half of position                          |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, Robert Hill"
#include <stdlib.mqh>
#include <stderror.mqh> 

extern bool    AccountIsMini = true;
extern string  Expert_Name    = "TrailingPartialClose";

extern string  st6 = "--Profit Controls--";
extern double  StopLoss = 100;          // Maximum pips willing to lose per position.
extern int     usePartialClose = 1;
extern double  PartialPercent = 50;
extern int     TP_Level1 = 20;
extern int     Slippage=3;
bool           First_TP_Level = false;


extern string  tsp0 = "--Trailing Stop Types--";
extern string  tsp1 = " 1 = Trail immediately";
extern string  tsp2 = " 2 = Wait to trail";
extern string  tsp3 = " 3 = Uses 3 levels before trail";
extern string  tsp4 = " 4 = Breakeven + Lockin";
extern string  tsp5 = " 5 = Step trail";
extern string  tsp6 = " 6 = MA trail";
extern string  tsp7 = " 7 = pSAR trail";
extern int     TrailingStopType = 4;

extern string  ts2 = "Settings for Type 2";
extern double  TrailingStop = 15;      // Change to whatever number of pips you wish to trail your position with.

extern string  ts3 = "Settings for Type 3";
extern double  FirstMove = 20;        // Type 3  first level pip gain
extern double  FirstStopLoss = 50;    // Move Stop to Breakeven
extern double  SecondMove = 30;       // Type 3 second level pip gain
extern double  SecondStopLoss = 30;   // Move stop to lock is profit
extern double  ThirdMove = 40;        // type 3 third level pip gain
extern double  TrailingStop3 = 20;    // Move stop and trail from there

extern string  ts4 = "Settings for Type 4";
extern double  BreakEven = 30;
extern int     LockInPips = 1;        // Profit Lock in pips

extern string  ts5 = "Settings for Type 5";
extern int     eTrailingStop   = 10;
extern int     eTrailingStep   = 2;

extern string  ts6 = "Settings for Type 6";
extern int     TrailMA_TimeFrame    =  15;
extern int     TrailMA_Period       = 10;
extern int     TrailMA_Shift        =  0;    
extern string  t3="--Moving Average settings--";
extern string  tm = "--Moving Average Types--";
extern string  tm0 = " 0 = SMA";
extern string  tm1 = " 1 = EMA";
extern string  tm2 = " 2 = SMMA";
extern string  tm3 = " 3 = LWMA";
extern int     TrailMA_Type = 1;
extern string  tp = "--Applied Price Types--";
extern string  tp0 = " 0 = close";
extern string  tp1 = " 1 = open";
extern string  tp2 = " 2 = high";
extern string  tp3 = " 3 = low";
extern string  tp4 = " 4 = median(high+low)/2";
extern string  tp5 = " 5 = typical(high+low+close)/3";
extern string  tp6 = " 6 = weighted(high+low+close+close)/4";
extern int     TrailMA_AppliedPrice = 0;
extern int     InitialStop     =  0;
 
extern string  ts7 = "Settings for Type 7";
extern double  StepParabolic = 0.02;
extern double  MaxParabolic  = 0.2;
extern int     Interval      = 5;

//+---------------------------------------------------+
//|General controls                                   |
//+---------------------------------------------------+
string setup;
double myPoint;
int totalTries 		= 5; 
int retryDelay 		= 1000;
int OrderErr;

//+---------------------------------------------------+
//|  Indicator values for signals and filters         |
//|  Add or Change to test your system                |
//+---------------------------------------------------+

int SignalCandle = 1;
int TradesInThisSymbol = 0;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
   
   setup=Expert_Name + Symbol() + "_" + func_TimeFrame_Val2String(func_TimeFrame_Const2Val(Period()));
   
     myPoint = SetPoint();
//----
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
//| The functions from this point to the start function are where    |
//| changes are made to test other systems or strategies.            |
//|+-----------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Determine number of lots to close
//| Uses percentage of current lots
//| Checks for mini or standard account
//| Inputs:
//|      ol - OrderLots()
//| percent - percentage of position to close
//+------------------------------------------------------------------+
double GetTP_Lots(double ol, double percent)
{
  double mLots;
   
  mLots = 0;
   
  if (AccountIsMini)
  {
     if (ol > 0.1)
     {
        mLots = MathFloor(ol*percent/10)/10;
        if (mLots < 0.1) mLots = 0.1;
     }
  }
  else
  {
    if (ol > 1)
    {
        mLots = MathFloor(ol*percent/100);
        if (mLots < 1) mLots = 1;
    }
  }
  return(mLots);
  
}

int CloseOrder(int ticket,double numLots,int cmd)
{
	bool exit_loop = false, result;
   int cnt, err, digits;
   double myPrice;
   
   if (cmd == OP_BUY) myPrice = MarketInfo(Symbol( ), MODE_BID);
   if (cmd == OP_SELL) myPrice = MarketInfo(Symbol( ), MODE_ASK);
   digits = MarketInfo(Symbol( ), MODE_DIGITS) ;
   if (digits > 0)  myPrice = NormalizeDouble( myPrice, digits);
   // try to close 3 Times
      
    cnt = 0;
    while (!exit_loop)
    {
		if (IsTradeAllowed()) 
		{
       result = OrderClose(ticket,numLots,myPrice,Slippage*myPoint,Violet);
		 err = GetLastError();
      }
        else cnt++;
		if (result == true) 
			exit_loop = true;

         err=GetLastError();
		switch (err) 
		{
			case ERR_NO_ERROR:
				exit_loop = true;
				break;
			case ERR_SERVER_BUSY:
			case ERR_NO_CONNECTION:
			case ERR_INVALID_PRICE:
			case ERR_OFF_QUOTES:
			case ERR_BROKER_BUSY:
			case ERR_TRADE_CONTEXT_BUSY: 
			case ERR_TRADE_TIMEOUT:		// for modify this is a retryable error, I hope. 
				cnt++; 	// a retryable error
				break;
			case ERR_PRICE_CHANGED:
			case ERR_REQUOTE:
				RefreshRates();
				continue; 	// we can apparently retry immediately according to MT docs.
			default:
				// an apparently serious, unretryable error.
				exit_loop = true;
				break; 
		}  // end switch 

		if (cnt > totalTries) 
			exit_loop = true; 
			
		if (!exit_loop) 
		{
         Sleep(retryDelay);
			RefreshRates(); 
		}
	}  
	// we have now exited from loop. 
	if ((result == true) || (err == ERR_NO_ERROR)) 
	{
		OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES); 
		return(true); // SUCCESS! 
	}
	 
   Print(" Error closing order : (", err , ") " + ErrorDescription(err));
   return(false);

}

// Do Partial Close from TakeProfit
bool CheckPartialClose(int cmd, int mTicket, double mLots)
{
   double TP_Lots;

   TP_Lots = GetTP_Lots(mLots, PartialPercent);
   if (TP_Lots > 0)
   { 
       CloseOrder(mTicket,TP_Lots,cmd);
       return(false);
   }
   return(true);
}

//+------------------------------------------------------------------+
//| Close Partial Lots                                               |
//| Close Partial Lots as levels are reached                         |
//| Inputs:                                                          |
//|     type - Trade type, OP_BUY or OP_SELL                         |
//|   ticket - OrderTicket()                                         |
//|       op - OrderOpenPrice()                                      |
//|       ol - OrderLots()                                           |
//|       os - OrderStopLoss()                                       |
//|       tp - OrderTakeProfit()                                     |
//| Returns true if partial lots are closed, false otherwise         |
//+------------------------------------------------------------------+
bool ClosePartialLots(int type, int ticket, double op, double ol, double os, double tp, color mColor = CLR_NONE)
{
   double myAsk, myBid;
   
   switch (type)
   {
   case OP_BUY:
		     myBid = MarketInfo(Symbol(),MODE_BID);

           if (!First_TP_Level)   // Reach 1st TP level
           {
              if(myBid >= op + TP_Level1*myPoint)
              {
                First_TP_Level = true;
                if (CheckPartialClose(OP_BUY, ticket, ol)) return(true);
                return(false);
              }
           }             
           return(false);
           break;
   case OP_SELL:
		     myAsk = MarketInfo(Symbol(),MODE_ASK);
		     
           if (!First_TP_Level)  // Reach 1st TP level 
           {
              if(myAsk <= op-TP_Level1*myPoint)
              {
                First_TP_Level = true;
                if (CheckPartialClose(OP_SELL, ticket, ol)) return(true);
                return(false);
              }
           }
    }
    return(false);
}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//---- 
   
// Check if any open positions were not closed

     TradesInThisSymbol = CheckOpenPositions();
  
// Only allow 1 trade per Symbol

     if(TradesInThisSymbol == 0) {
        First_TP_Level = false;
        return(0);
     }
//+------------------------------------------------------------------+
//| Check for Open Position                                          |
//+------------------------------------------------------------------+

     HandleOpenPositions();
     
//----
   return(0);
  }

//+------------------------------------------------------------------+
//| Check Open Position Controls                                     |
//+------------------------------------------------------------------+
  
int CheckOpenPositions()
{
   int cnt, total;
   int NumTrades;
   
   NumTrades = 0;
   total=OrdersTotal();
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
     {
      OrderSelect (cnt, SELECT_BY_POS, MODE_TRADES);
      if ( OrderSymbol() != Symbol()) continue;
//      if ( OrderMagicNumber() != MagicNumber)  continue;
      
      if(OrderType() == OP_BUY )  NumTrades++;
      if(OrderType() == OP_SELL )  NumTrades++;
             
     }
     return (NumTrades);
  }

//+------------------------------------------------------------------+
//| Handle Open Positions                                            |
//| Check if any open positions need to be closed or modified        |
//+------------------------------------------------------------------+
int HandleOpenPositions()
{
   int cnt;
   
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
   {
      OrderSelect (cnt, SELECT_BY_POS, MODE_TRADES);
      if ( OrderSymbol() != Symbol()) continue;
//      if ( OrderMagicNumber() != MagicNumber)  continue;
      
      if(OrderType() == OP_BUY)
      {
          if (usePartialClose == 1)
          {
            if (ClosePartialLots(OP_BUY, OrderTicket(),OrderOpenPrice(),OrderLots(), OrderStopLoss(),OrderTakeProfit(), Aqua)) continue;
          }
            
               HandleTrailingStop(OP_BUY,OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit());
      }

      if(OrderType() == OP_SELL)
      {
          if (usePartialClose == 1)
          {
            if (ClosePartialLots(OP_SELL, OrderTicket(),OrderOpenPrice(),OrderLots(), OrderStopLoss(),OrderTakeProfit(), Aqua)) continue;
          }
               HandleTrailingStop(OP_SELL,OrderTicket(),OrderOpenPrice(),OrderStopLoss(),OrderTakeProfit());
      }
   }
}

//+------------------------------------------------------------------+
//| HandleTrailingStop                                               |
//| Type 1 moves the stoploss without delay.                         |
//| Type 2 waits for price to move the amount of the trailStop       |
//| before moving stop loss then moves like type 1                   |
//| Type 3 uses up to 3 levels for trailing stop                     |
//|      Level 1 Move stop to 1st level                              |
//|      Level 2 Move stop to 2nd level                              |
//|      Level 3 Trail like type 1 by fixed amount other than 1      |
//| Type 4 Move stop to breakeven + Lockin, no trail                 |
//| Type 5 uses steps for 1, every step pip move moves stop 1 pip    |
//| Type 6 Uses EMA to set trailing stop                             |
//+------------------------------------------------------------------+
int HandleTrailingStop(int type, int ticket, double op, double os, double tp)
{
   switch (TrailingStopType)
   {
     case 1 : Immediate_TrailingStop (type, ticket, op, os, tp);
              break;
     case 2 : Delayed_TrailingStop (type, ticket, op, os, tp);
              break;
     case 3 : ThreeLevel_TrailingStop (type, ticket, op, os, tp);
              break;
     case 4 : BreakEven_TrailingStop (type, ticket, op, os, tp);
              break;
	  case 5 : eTrailingStop (type, ticket, op, os, tp);
              break;
	  case 6 : MA_TrailingStop (type, ticket, op, os, tp);
              break;
	  case 7 : pSAR_TrailingStop (type, ticket, op, os, tp);
              break;
	}
   return(0);
}

int ModifyOrder(int ord_ticket,double op, double price,double tp, color mColor)
{
    int CloseCnt, err;
    
    CloseCnt=0;
    while (CloseCnt < 3)
    {
       if (OrderModify(ord_ticket,op,price,tp,0,mColor))
       {
         CloseCnt = 3;
       }
       else
       {
          err=GetLastError();
          Print(CloseCnt," Error modifying order : (", err , ") " + ErrorDescription(err));
         if (err>0) CloseCnt++;
       }
    }
}

double ValidStopLoss(int type, double price, double SL)
{

   double mySL;
   double minstop;
   
   minstop = MarketInfo(Symbol(),MODE_STOPLEVEL);
   if (Digits == 3 || Digits == 5) minstop = minstop / 10;
   
   mySL = SL;
   if (type == OP_BUY)
   {
		 if((price - mySL) < minstop*myPoint) mySL = price - minstop*myPoint;
   }
   if (type == OP_SELL)
   {
       if((mySL-price) < minstop*myPoint)  mySL = price + minstop*myPoint;  
   }

   return(NormalizeDouble(mySL,MarketInfo(Symbol(), MODE_DIGITS)));   
}
//+------------------------------------------------------------------+
//|                                           BreakEvenExpert_v1.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |                                      
//+------------------------------------------------------------------+
void BreakEven_TrailingStop(int type, int ticket, double op, double os, double tp)
{

   int digits;
   double pBid, pAsk, BuyStop, SellStop;

   digits = MarketInfo(Symbol(), MODE_DIGITS);
   
  if (type==OP_BUY)
  {
    pBid = MarketInfo(Symbol(), MODE_BID);
    if ( pBid-op > myPoint*BreakEven ) 
    {
       BuyStop = op + LockInPips * myPoint;
       if (digits > 0) BuyStop = NormalizeDouble( BuyStop, digits);
		 BuyStop = ValidStopLoss(OP_BUY,pBid, BuyStop);   
       if (os < BuyStop) ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
		 return;
	 }
  }
  if (type==OP_SELL)
  {
    pAsk = MarketInfo(Symbol(), MODE_ASK);
    if ( op - pAsk > myPoint*BreakEven ) 
    {
       SellStop = op - LockInPips * myPoint;
       if (digits > 0) SellStop = NormalizeDouble( SellStop, digits);
       SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);  
       if (os > SellStop) ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
		 return;
    }
  }   

}

//+------------------------------------------------------------------+
//|                                                   e-Trailing.mq4 |
//|                                           Ким Игорь В. aka KimIV |
//|                                              http://www.kimiv.ru |
//|                                                                  |
//| 12.09.2005 Автоматический Trailing Stop всех открытых позиций    |
//|            Вешать только на один график                          |
//+------------------------------------------------------------------+
void eTrailingStop(int type, int ticket, double op, double os, double tp)
{

  int digits;
  double pBid, pAsk, BuyStop, SellStop;

  digits = MarketInfo(Symbol(), MODE_DIGITS) ;
  if (type==OP_BUY)
  {
    pBid = MarketInfo(Symbol(), MODE_BID);
    if ((pBid-op)>eTrailingStop*myPoint)
    {
      if (os<pBid-(eTrailingStop+eTrailingStep-1)*myPoint)
      {
        BuyStop = pBid-eTrailingStop*myPoint;
        if (digits > 0) BuyStop = NormalizeDouble( BuyStop, digits);
		  BuyStop = ValidStopLoss(OP_BUY, pBid, BuyStop);   
        ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
        return;
      }
    }
  }
  if (type==OP_SELL)
  {
    pAsk = MarketInfo(Symbol(), MODE_ASK);
    if (op - pAsk > eTrailingStop*myPoint)
    {
      if (os > pAsk + (eTrailingStop + eTrailingStep-1)*myPoint || os==0)
      {
        SellStop = pAsk + eTrailingStop * myPoint;
        if (digits > 0) SellStop = NormalizeDouble( SellStop, digits);
        SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);  
        ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
        return;
      }
    }
  }

}

//+------------------------------------------------------------------+
//|                                           EMATrailingStop_v1.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by IgorAD,igorad2003@yahoo.co.uk |   
//|            http://finance.groups.yahoo.com/group/TrendLaboratory |
//|                                                                  |
//|  Modified to use any MA                                          |                                      
//+------------------------------------------------------------------+
void MA_TrailingStop(int type, int ticket, double op, double os, double tp)
{
   int digits;
   double pBid, pAsk, BuyStop, SellStop, ema;

   digits = MarketInfo(Symbol(), MODE_DIGITS) ;
   ema = iMA(Symbol(),TrailMA_TimeFrame,TrailMA_Period,0,TrailMA_Type,TrailMA_AppliedPrice,TrailMA_Shift);
   
   if (type==OP_BUY) 
   {
	   BuyStop = ema;
      pBid = MarketInfo(Symbol(),MODE_BID);
		if(os == 0 && InitialStop>0 ) BuyStop = pBid-InitialStop*myPoint;
		if (digits > 0) BuyStop = NormalizeDouble(BuyStop, digits); 
		BuyStop = ValidStopLoss(OP_BUY, pBid, BuyStop);   
		if ((op <= BuyStop && BuyStop > os) || os==0) 
		{
          ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
			 return;
      }
   }   

   if (type==OP_SELL)
   {
	   SellStop = ema;
      pAsk = MarketInfo(Symbol(),MODE_ASK);
      if (os==0 && InitialStop > 0) SellStop = pAsk+InitialStop*myPoint;
		if (digits > 0) SellStop = NormalizeDouble(SellStop, digits); 
		SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);
      if( (op >= SellStop && os > SellStop) || os==0) 
      {
          ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
			 return;
      }
   }
}

//+------------------------------------------------------------------+
//|                                                b-TrailingSAR.mqh |
//|                                           Ким Игорь В. aka KimIV |
//|                                              http://www.kimiv.ru |
//|                                                                  |
//|    21.11.2005  Библиотека функций трала по параболику.           |
//|  Для использования добавить строку в модуле start                |
//|  if (UseTrailing) TrailingPositions();                           |
//+------------------------------------------------------------------+
void pSAR_TrailingStop(int type, int ticket, double op, double os, double tp)
{
   int digits;
   double pBid, pAsk, BuyStop, SellStop, spr;
   double sar1, sar2;
  
   digits = MarketInfo(Symbol(), MODE_DIGITS) ;
   pBid = MarketInfo(Symbol(), MODE_BID);
   pAsk = MarketInfo(Symbol(), MODE_ASK);
   sar1=iSAR(NULL, 0, StepParabolic, MaxParabolic, 1);
   sar2=iSAR(NULL, 0, StepParabolic, MaxParabolic, 2);
   spr = pAsk - pBid;
   if (digits > 0) spr = NormalizeDouble(spr, digits); 
   
   if (type==OP_BUY)
   {
     pBid = MarketInfo(Symbol(), MODE_BID);
     if (sar2 < sar1)
     {
        BuyStop = sar1-Interval*myPoint;
        if (digits > 0) BuyStop = NormalizeDouble(BuyStop, digits); 
	     BuyStop = ValidStopLoss(OP_BUY, pBid, BuyStop);   
        if (os<BuyStop) ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
     }
   }
   if (type==OP_SELL)
   {
     if (sar2 > sar1)
     {
        SellStop = sar1 + Interval * myPoint + spr;
        if (digits > 0) SellStop = NormalizeDouble(SellStop, digits); 
	     SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);   
        if (os>SellStop || os==0) ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
     }
   }
}

//+------------------------------------------------------------------+
//|                                      ThreeLevel_TrailingStop.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by MrPip,robydoby314@yahoo.com   |   
//|                                                                  |
//| Uses up to 3 levels for trailing stop                            |
//|      Level 1 Move stop to 1st level                              |
//|      Level 2 Move stop to 2nd level                              |
//|      Level 3 Trail like type 1 by fixed amount other than 1      |
//+------------------------------------------------------------------+
void ThreeLevel_TrailingStop(int type, int ticket, double op, double os, double tp)
{

   int digits;
   double pBid, pAsk, BuyStop, SellStop;

   digits = MarketInfo(Symbol(), MODE_DIGITS) ;

   if (type == OP_BUY)
   {
      pBid = MarketInfo(Symbol(), MODE_BID);
      if (pBid - op > FirstMove * myPoint)
      {
         BuyStop = op + FirstMove*myPoint - FirstStopLoss * myPoint;
         if (digits > 0) BuyStop = NormalizeDouble(BuyStop, digits); 
		   BuyStop = ValidStopLoss(OP_BUY, pBid, BuyStop);   
         if (os < BuyStop) ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
      }
              
      if (pBid - op > SecondMove * myPoint)
      {
         BuyStop = op + SecondMove*myPoint - SecondStopLoss * myPoint;
         if (digits > 0) BuyStop = NormalizeDouble(BuyStop, digits); 
		   BuyStop = ValidStopLoss(OP_BUY, pBid, BuyStop);   
         if (os < BuyStop) ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
      }
                
      if (pBid - op > ThirdMove * myPoint)
      {
         BuyStop = pBid  - TrailingStop3*myPoint;
         if (digits > 0) BuyStop = NormalizeDouble(BuyStop, digits); 
		   BuyStop = ValidStopLoss(OP_BUY, pBid, BuyStop);   
         if (os < BuyStop) ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
      }
   }
       
    if (type ==  OP_SELL)
    {
        pAsk = MarketInfo(Symbol(), MODE_ASK);
        if (op - pAsk > FirstMove * myPoint)
        {
           SellStop = op - FirstMove * myPoint + FirstStopLoss * myPoint;
           if (digits > 0) SellStop = NormalizeDouble(SellStop, digits); 
		     SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);   
           if (os > SellStop) ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
        }
        if (op - pAsk > SecondMove * myPoint)
        {
           SellStop = op - SecondMove * myPoint + SecondStopLoss * myPoint;
           if (digits > 0) SellStop = NormalizeDouble(SellStop, digits); 
		     SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);   
           if (os > SellStop) ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
        }
        if (op - pAsk > ThirdMove * myPoint)
        {
           SellStop = pAsk + TrailingStop3 * myPoint;               
           if (digits > 0) SellStop = NormalizeDouble(SellStop, digits); 
		     SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);   
           if (os > SellStop) ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
        }
    }

}

//+------------------------------------------------------------------+
//|                                       Immediate_TrailingStop.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by MrPip,robydoby314@yahoo.com   |
//|                                                                  |   
//| Moves the stoploss without delay.                                |
//+------------------------------------------------------------------+
void Immediate_TrailingStop(int type, int ticket, double op, double os, double tp)
{

   int digits;
   double pt, pBid, pAsk, BuyStop, SellStop;

   digits = MarketInfo(Symbol( ), MODE_DIGITS);
   
   if (type==OP_BUY)
   {
     pBid = MarketInfo(Symbol(), MODE_BID);
     pt = StopLoss * myPoint;
     if(pBid-os > pt)
     {
       BuyStop = pBid - pt;
       if (digits > 0) BuyStop = NormalizeDouble( BuyStop, digits);
		 BuyStop = ValidStopLoss(OP_BUY,pBid, BuyStop);   
       if (os < BuyStop) ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
		 return;
	  }
   }
   if (type==OP_SELL)
   {
     pAsk = MarketInfo(Symbol(), MODE_ASK);
     pt = StopLoss * myPoint;
     if(os - pAsk > pt)
     {
       SellStop = pAsk + pt;
       if (digits > 0) SellStop = NormalizeDouble( SellStop, digits);
       SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);  
       if (os > SellStop) ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
		 return;
     }
   }   
}

//+------------------------------------------------------------------+
//|                                         Delayed_TrailingStop.mq4 |
//|                                  Copyright © 2006, Forex-TSD.com |
//|                         Written by MrPip,robydoby314@yahoo.com   |
//|                                                                  |   
//| Waits for price to move the amount of the TrailingStop           |
//| Moves the stoploss pip for pip after delay.                      |
//+------------------------------------------------------------------+
void Delayed_TrailingStop(int type, int ticket, double op, double os, double tp)
{
   int digits;
   double pt, pBid, pAsk, BuyStop, SellStop;

   pt = TrailingStop * myPoint;
   digits = MarketInfo(Symbol(), MODE_DIGITS);
   
   if (type==OP_BUY)
   {
     pBid = MarketInfo(Symbol(), MODE_BID);
     BuyStop = pBid - pt;
     if (digits > 0) BuyStop = NormalizeDouble( BuyStop, digits);
	  BuyStop = ValidStopLoss(OP_BUY,pBid, BuyStop);   
     if (pBid-op > pt && os < BuyStop) ModifyOrder(ticket,op,BuyStop,tp,LightGreen);
	  return;
   }
   if (type==OP_SELL)
   {
     pAsk = MarketInfo(Symbol(), MODE_ASK);
     pt = TrailingStop * myPoint;
     SellStop = pAsk + pt;
     if (digits > 0) SellStop = NormalizeDouble( SellStop, digits);
     SellStop = ValidStopLoss(OP_SELL, pAsk, SellStop);  
     if (op - pAsk > pt && os > SellStop) ModifyOrder(ticket,op,SellStop,tp,DarkOrange);
	  return;
   }   
}

//+------------------------------------------------------------------+
//| Time frame interval appropriation  function                      |
//+------------------------------------------------------------------+

int func_TimeFrame_Const2Val(int Constant ) {
   switch(Constant) {
      case 1:  // M1
         return(1);
      case 5:  // M5
         return(2);
      case 15:
         return(3);
      case 30:
         return(4);
      case 60:
         return(5);
      case 240:
         return(6);
      case 1440:
         return(7);
      case 10080:
         return(8);
      case 43200:
         return(9);
   }
}

//+------------------------------------------------------------------+
//| Time frame string appropriation  function                               |
//+------------------------------------------------------------------+

string func_TimeFrame_Val2String(int Value ) {
   switch(Value) {
      case 1:  // M1
         return("PERIOD_M1");
      case 2:  // M1
         return("PERIOD_M5");
      case 3:
         return("PERIOD_M15");
      case 4:
         return("PERIOD_M30");
      case 5:
         return("PERIOD_H1");
      case 6:
         return("PERIOD_H4");
      case 7:
         return("PERIOD_D1");
      case 8:
         return("PERIOD_W1");
      case 9:
         return("PERIOD_MN1");
   	default: 
   		return("undefined " + Value);
   }
}

double SetPoint()
{
   double mPoint;
   
   if (Digits < 4)
      mPoint = 0.01;
   else
      mPoint = 0.0001;
   
   return(mPoint);
}



