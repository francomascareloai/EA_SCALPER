//+------------------------------------------------------------------+
//|                                 TripleMA_Crossover_Expert.mq4    |
//|                                              Copyright © 2006    |
//|                        Written by Robert Hill aka MrPip          |                                                    |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, MrPip"
#property link      "http:/strategybuilderfx.com/"
#include <stdlib.mqh>


#define MAGIC 3333

extern bool AccountIsMini = true;        // Change to true if trading mini account
extern bool MoneyManagement = true;      // Change to false to shutdown money management controls.
                                         // Lots = 1 will be in effect and only 1 lot will be open regardless of equity.
extern double TradeSizePercent = 5;      // Change to whatever percent of equity you wish to risk.
extern double Lots = 3;             // standard lot size. 
//+---------------------------------------------------+
//|Indicator Variables                                |
//| Change these to try your own system               |
//| or add more if you like                           |
//+---------------------------------------------------+
extern int FasterMode = 0; //0=sma, 1=ema, 2=smma, 3=lwma
extern int FastMAPeriod =   9;
extern int MiddleMode = 0; //0=sma, 1=ema, 2=smma, 3=lwma
extern int MiddleMAPeriod =   14;
extern int SlowerMode = 0; //0=sma, 1=ema, 2=smma, 3=lwma
extern int SlowMAPeriod =   29;
extern int Fast_MiddleSpread=0;
extern int Middle_SlowSpread=0;
extern int Signal=1;
//+---------------------------------------------------+
//|Money Management                                   |
//+---------------------------------------------------+
extern double StopLoss = 250;       // Maximum pips willing to lose per position.
extern bool UseTrailingStop = true;
extern int TrailingStopType = 3;        // Type 1 moves stop immediately, Type 2 waits til value of TS is reached
extern double TrailingStop = 40;        // Change to whatever number of pips you wish to trail your position with.
extern double TRStopLevel_1 = 20;       // Type 3  first level pip gain
extern double TrailingStop1 = 20;       // Move Stop to Breakeven
extern double TRStopLevel_2 = 30;       // Type 3 second level pip gain
extern double TrailingStop2 = 20;       // Move stop to lock is profit
extern double TRStopLevel_3 = 50;
extern double TrailingStop3 = 20;       // Move stop and trail from there
extern int TakeProfit = 0;          // Maximum profit level achieved.
extern double Margincutoff = 800;   // Expert will stop trading if equity level decreases to that level.
extern double MaxLots = 100;
extern int Slippage = 10;           // Possible fix for not getting closed    


//+---------------------------------------------------+
//|General controls                                   |
//+---------------------------------------------------+
string setup;
double lotMM;
int TradesInThisSymbol;
double Sl; 
double Tr;
bool OK2Buy, OK2Sell;              // determines if buy or sell trades are allowed
int NumBuys, NumSells;             // Number of buy and sell trades in this Symbol

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
  }

//+------------------------------------------------------------------+
//| CheckExitCondition                                               |
//| Check if any exit condition is met                               |
//+------------------------------------------------------------------+
bool CheckExitCondition(string TradeType)
{
   bool YesClose;
   double fMA, mMA;
   
   YesClose = false;
   fMA = iMA(NULL, 0, FastMAPeriod, 1, FasterMode, PRICE_CLOSE, Signal);
   mMA = iMA(NULL, 0, MiddleMAPeriod, 1, MiddleMode, PRICE_CLOSE, Signal);
    // Check for cross down
   if (TradeType == "BUY" && fMA < mMA) YesClose = true;
   // Check for cross up
   if (TradeType == "SELL" && fMA > mMA) YesClose =true;

   return (YesClose);
}

//+------------------------------------------------------------------+
//| CheckEntryCondition                                              |
//| Check if entry condition is met                                  |
//+------------------------------------------------------------------+
bool CheckEntryCondition(string TradeType)
{
   bool YesTrade;
   double fMA, mMA, sMA;
   
   YesTrade = false;
   fMA = iMA(NULL, 0, FastMAPeriod, 1, FasterMode, PRICE_CLOSE, Signal);
   mMA = iMA(NULL, 0, MiddleMAPeriod, 1, MiddleMode, PRICE_CLOSE, Signal);
   sMA = iMA(NULL, 0, SlowMAPeriod, 1, SlowerMode, PRICE_CLOSE, Signal);

   // Check for cross up
   if (TradeType == "BUY" && fMA > (mMA + Fast_MiddleSpread*Point) && mMA > (sMA + Middle_SlowSpread * Point))  YesTrade = true;
    // Check for cross down
   if (TradeType == "SELL" && fMA < (mMA - Fast_MiddleSpread*Point) && mMA < (sMA - Middle_SlowSpread * Point) ) YesTrade = true;
   
   return (YesTrade);
}
  

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//---- 

   setup="tripleMA_crossover_expert" + Symbol();

// Check for valid inputs

   if (CheckValidUserInputs()) return(0);   

//+------------------------------------------------------------------+
//| Check for Open Position                                          |
//+------------------------------------------------------------------+

     HandleOpenPositions();
     
// Check if any open positions were not closed

     TradesInThisSymbol = CheckOpenPositions();
     
//+------------------------------------------------------------------+
//| Check if OK to make new trades                                   |
//+------------------------------------------------------------------+


   if(AccountFreeMargin() < Margincutoff) {
     return(0);}
     
// Only allow 1 trade per Symbol

   if(TradesInThisSymbol > 0) {
     return(0);}

   lotMM = GetLots();
   
	if(CheckEntryCondition("BUY"))
	{
		if (StopLoss>0) {
		 Sl = Ask-StopLoss*Point;
		} else {
		 Sl=0;
		}
		if (TakeProfit == 0) 
		    Tr = 0;
		else
		    Tr = Ask+TakeProfit*Point;
		    
		OpenBuyOrder();
	}

   
	if(CheckEntryCondition("SELL"))
	{
		if (StopLoss>0) {
		 Sl = Bid+StopLoss*Point;
		} else {
		 Sl = 0;
		}
		if (TakeProfit == 0) 
		    Tr = 0;
		else
		    Tr = Bid-TakeProfit*Point;
		    
		OpenSellOrder();
	}
//----
   return(0);
  }

//+-------------------------------------------+
//| DoTrades module cut from start            |
//|  No real changes                          |
//+-------------------------------------------+
void DoTrades(string OrdText, string SetupStr,double lotM, double SSl, double TTr)
{
   int err;
   int ticket;

   if(OrdText == "BUY")
   {
       ticket = OrderSend(Symbol(),OP_BUY,lotM,Ask,Slippage,SSl,TTr,SetupStr,MAGIC,0,Green);
       if(ticket<=0)
       {
           err = GetLastError();
           Alert("Error opening BUY order [" + SetupStr + "]: (" + err + ") " + ErrorDescription(err)); 
       }
   }
   else if(OrdText == "SELL")
   {
       ticket = OrderSend(Symbol(),OP_SELL,lotM,Bid,Slippage,SSl,TTr,SetupStr,MAGIC,0,Red);
       if(ticket<=0)
       {
          err = GetLastError();
          Alert("Error opening Sell order [" + SetupStr + "]: (" + err + ") " + ErrorDescription(err)); 
       }
    }
}

//+------------------------------------------------------------------+
//| Check Open Position Controls                                     |
//+------------------------------------------------------------------+
  
int CheckOpenPositions()
{
   int cnt, NumPositions;
   int NumBuyTrades, NumSellTrades;   // Number of buy and sell trades in this symbol
   
   NumBuyTrades = 0;
   NumSellTrades = 0;
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
     {
      OrderSelect (cnt, SELECT_BY_POS, MODE_TRADES);
      if ( OrderSymbol() != Symbol()) continue;
      if ( OrderMagicNumber() != MAGIC)  continue;
      
      if(OrderType() == OP_BUY )  NumBuyTrades++;
      if(OrderType() == OP_SELL ) NumSellTrades++;
             
     }
     NumPositions = NumBuyTrades + NumSellTrades;
     return (NumPositions);
  }


//+------------------------------------------------------------------+
//| Handle Open Positions                                            |
//| Check if any open positions need to be closed or modified        |
//| Three attempts are made to close or modify                       |
//+------------------------------------------------------------------+
int HandleOpenPositions(bool BuyExit, bool SellExit)
{
   int cnt, CloseCnt;
   int err;
   double os;
   
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
     {
      OrderSelect (cnt, SELECT_BY_POS, MODE_TRADES);
      if ( OrderSymbol() != Symbol()) continue;
      if ( OrderMagicNumber() != MAGIC)  continue;
      
      if(OrderType() == OP_BUY)
          {
            
            if (BuyExit)
            {
                OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Violet);
             }
             else
             {
              if(TrailingStop>0) 
               {                
                 os = OrderStopLoss();                
                  if(Bid - os>Point*StopLoss)
                  {
                     CloseCnt=0;
                     while (CloseCnt < 3)
                     {
                     if (!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-Point*StopLoss,OrderTakeProfit(),0,Aqua))
                     {
                        err=GetLastError();
                        if (err>0) CloseCnt++;
                     }
                     else
                     {
                      CloseCnt = 3;
                     }
                  }
                 }
              }
             }
          }

      if(OrderType() == OP_SELL)
          {
            if (SellExit)
            {
            
                 OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Violet);
             }
             else
             {
  
   // try to modify 3 Times
      
                 if(TrailingStop>0)  
                 {                
                  os = OrderStopLoss();                
                   if(os - Ask > Point*StopLoss)
                   {
                     CloseCnt = 0;
                     while (CloseCnt < 3)
                     {
                       if (!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+Point*StopLoss,OrderTakeProfit(),0,Aqua))
                       {
                         err=GetLastError();
                         if (err > 0) CloseCnt++;
                       }
                       else
                       {
                        CloseCnt = 3;
                       }
                     }
                   }
                }
             }
       }
  }
}


