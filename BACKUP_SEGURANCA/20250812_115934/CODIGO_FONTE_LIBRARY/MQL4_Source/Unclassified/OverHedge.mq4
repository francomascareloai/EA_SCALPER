//+------------------------------------------------------------------+
//|                                                  OverHedgeV2.mq4 |
//|                                               Copyright © 2006,  |
//|                                                                  |
//| Written by MrPip (Robert Hill) for kmrunner                      |
//| 3/7/06  Added check of direction for first trade Buy or Sell     |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005"
#property link      "http://www.strategtbuilderfx.com"
#include <stdlib.mqh>


extern int    MagicNumber = 11111;
extern double Lots = 0.1;
extern double HedgeBase = 2.0; 
extern int Slippage = 5;
extern bool shutdownGrid = false;
extern int TunnelWidth=20;

extern double profitTarget = 100;     // if > 0, will close out all positions once the pip target has been met
extern bool UseLSMA = true;
extern int MAShortPeriod=8;   // original was 7, change based on new optimization Mar06
extern int MALongPeriod=21;   // original was 16, change based on new optimization Mar06
extern int    PauseSeconds  =     6; // Number of seconds to "sleep" before closing the next winning trade
extern int    MillisPerSec  =  1000; // DO NOT CHANGE - Standard multiplier to convert seconds to milliseconds

double TunnelSize;
string setup;
double startBuyRate, startSellRate;
int currentOpen;
int NumBuyTrades, NumSellTrades;   // Number of buy and sell trades in this symbol
bool myWantLongs;
double lotMM;
double Profit;
bool OK2Buy,OK2Sell, FirstDirSell;

//+------------------------------------------------------------------------+
//| LSMA - Least Squares Moving Average function calculation               |
//| LSMA_In_Color Indicator plots the end of the linear regression line    |
//+------------------------------------------------------------------------+

double LSMA(int Rperiod, int shift)
{
   int i;
   double sum;
   int length;
   double lengthvar;
   double tmp;
   double wt;

   length = Rperiod;
 
   sum = 0;
   for(i = length; i >= 1  ; i--)
   {
     lengthvar = length + 1;
     lengthvar /= 3;
     tmp = 0;
     tmp = ( i - lengthvar)*Close[length-i+shift];
     sum+=tmp;
    }
    wt = sum*6/(length*(length+1));
    
    return(wt);
}


//+------------------------------------------------------------------+
//| CheckDirection                                                   |
//| Check direction for trade                                        |
//| return 1 for up, -1 for down, 0 for flat                         |
//+------------------------------------------------------------------+
int CheckDirection()
{
   double SlowMA, FastMA;
   double Dif;
   
   if (UseLSMA)
   {
     FastMA = LSMA(MAShortPeriod,1);
     SlowMA = LSMA(MALongPeriod,1);
   }
   else
   {
     FastMA = iMA(NULL,0,MAShortPeriod,0,MODE_EMA,PRICE_CLOSE,1);
     SlowMA = iMA(NULL,0,MALongPeriod,0,MODE_EMA,PRICE_CLOSE,1);
   }
 
   Dif = FastMA-SlowMA;
   
   if(Dif > 0 ) return(1);
   if(Dif < 0 ) return(-1);
   return(0);
   

}

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//---- 
   setup = StringConcatenate( "OverHedgeEMA-", Symbol(),"-",MagicNumber );
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
//| Close Open Positions                                             |
//| Close all open positions                                         |
//+------------------------------------------------------------------+
void CloseOpenPositions()
{
   int cnt, err;
   
// First close losing trades
   
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
   {
      OrderSelect (cnt, SELECT_BY_POS,MODE_TRADES);
      if ( OrderSymbol() != Symbol()) continue;
      if ( OrderMagicNumber() != MagicNumber)  continue;
      
        if(OrderType() == OP_BUY && OrderProfit() < 0)
        {
          if (OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Violet))
          {
            Print("Buy Order closed for " + Symbol() + " at " + Bid + ".");
          }
          else
          {
            err=GetLastError();
            Print("Error closing order : (", err , ") " + ErrorDescription(err));
          }
        }
        if(OrderType() == OP_SELL && OrderProfit() < 0)
        {
          if (OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Violet))
          {
            Print("Sell Order closed for " + Symbol() + " at " + Ask + ".");
          }
          else
          {
            err=GetLastError();
            Print("Error closing order : (", err , ") " + ErrorDescription(err));
          }
        }
   }
   
// Then close winning trades
   
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
   {
      OrderSelect (cnt, SELECT_BY_POS,MODE_TRADES);
      if ( OrderSymbol() != Symbol()) continue;
      if ( OrderMagicNumber() != MagicNumber)  continue;
      
        if(OrderType() == OP_BUY && OrderProfit() > 0)
        {
          Sleep(PauseSeconds*MillisPerSec);
          if (OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,Gold))
          {
            Print("Buy Order closed for " + Symbol() + " at " + Bid + ".");
          }
          else
          {
            err=GetLastError();
            Print("Error closing order : (", err , ") " + ErrorDescription(err));
          }
        }
        if(OrderType() == OP_SELL && OrderProfit() > 0)
        {
          Sleep(PauseSeconds*MillisPerSec);
          if (OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,Gold))
          {
            Print("Sell Order closed for " + Symbol() + " at " + Ask + ".");
          }
          else
          {
            err=GetLastError();
            Print(" Error closing order : (", err , ") " + ErrorDescription(err));
          }
        }
   }

}

//+------------------------------------------------------------------------+
//| counts the number of open positions                                    |
//| type BUY returns number of long positions                              |
//| type SELL returns number of short positions                            |
//| type BOTH returns number of long and short positions                   |
//+------------------------------------------------------------------------+

int CheckOpenPositions(string type)
{
   int cnt, NumPositions;
   int NumBuyTrades, NumSellTrades;   // Number of buy and sell trades in this symbol
   
   NumBuyTrades = 0;
   NumSellTrades = 0;
   for(cnt=OrdersTotal()-1;cnt>=0;cnt--)
   {
      OrderSelect (cnt, SELECT_BY_POS, MODE_TRADES);
      if ( OrderSymbol() != Symbol()) continue;
      if ( OrderMagicNumber() != MagicNumber)  continue;
      if(OrderType() == OP_BUY )
      {
        NumBuyTrades++;
      }
      else if(OrderType() == OP_SELL)
      {
        NumSellTrades++;
      }
             
   }
   NumPositions = NumBuyTrades + NumSellTrades;
   if (type == "BUY") return (NumBuyTrades);
   if (type == "SELL") return (NumSellTrades);
   return (NumPositions);
}

//+------------------------------------------------------------------+
//| GetProfit                                                        |
//| Return Open Profit from all open positions                       |
//+------------------------------------------------------------------+
double GetProfit( )
{
   int i;
   double   openProfit = 0;

   openProfit = 0;

   for(i=OrdersTotal()-1;i>=0;i--)
   {
      OrderSelect(i, SELECT_BY_POS );
      if ( OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber )
      {
          openProfit = openProfit + MathRound(OrderProfit()/MarketInfo(Symbol(),MODE_TICKVALUE)*10);
      }
   }
   return (openProfit);
}

//+------------------------------------------------------------------+
//| OpenBuyOrder                                                     |
//+------------------------------------------------------------------+
void OpenBuyOrder()
{
   int err;
   int ticket;

   ticket = OrderSend(Symbol(),OP_BUY,lotMM,Ask,Slippage,0,0,setup,MagicNumber,0,Blue);
   if(ticket<=0)
   {
      err = GetLastError();
      Print("Error opening BUY order [" + setup + "]: (" + err + ") " + ErrorDescription(err)); 
   }
}

//+------------------------------------------------------------------+
//| OpenSellOrder                                                    |
//+------------------------------------------------------------------+
void OpenSellOrder()
{
   int err;
   int ticket;
   
   ticket = OrderSend(Symbol(),OP_SELL,lotMM,Bid,Slippage,0,0,setup,MagicNumber,0,Red);
   if(ticket<=0)
   {
      err = GetLastError();
      Print("Error opening Sell order [" + setup + "]: (" + err + ") " + ErrorDescription(err)); 
   }
}

//+------------------------------------------------------------------+
//| Check  Profit                                                    |
//| Output comment showing progit, longs, shorts, etc                |
//| If profit target is reached close all open positions             |
//+------------------------------------------------------------------+
void CheckProfit()
{
   double Profit;
   int openLongs,openShorts;
   
   Profit = GetProfit();
   if ( Profit >= profitTarget ) 
   {
       CloseOpenPositions();
   }
//   else
//   {
//       openLongs = CheckOpenPositions("BUY");
//       openShorts = CheckOpenPositions("SELL");
//       Comment(" Server time is ",TimeToStr(CurTime()),
//               "\n",
//               "\n","                  Open p&l  = ",Profit,
//               "\n","                  Long      = ",openLongs, 
//               "\n","                  Short     = ",openShorts, 
//               "\n",
//               "\n","                  Balance   = ",AccountBalance(),
//               "\n","                  Equity    = ",AccountEquity(),
//               "\n","                  Margin    = ",AccountMargin(),
//               "\n","                  Free mrg  = ",AccountFreeMargin());
//    }
}

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//---- 


//---- test if we want to shutdown

   if (shutdownGrid )         // close all orders. then exit.. there is nothing more to do
   {
      CloseOpenPositions();
      return(0);
   }
   
   TunnelSize = ((2*(Ask-Bid)/Point)+TunnelWidth);
   
// Check for new trade cycle
// First check if profit target is reached
// If yes then there will be no open positions
// So a new trade cycle will begin
    
   CheckProfit();
   currentOpen = CheckOpenPositions("BOTH");
   if (currentOpen == 0)
   {
// Start trades based on confirmation direction, was daily

      if (CheckDirection() == 0) return(0);
      if (CheckDirection() == 1)
      {
         OK2Buy = true;
         OK2Sell = false;
         FirstDirSell = false;
      }
      if (CheckDirection() == -1)
      {
         OK2Buy = false;
         OK2Sell = true;
         FirstDirSell = true;
      }
      if (OK2Buy)
      {
         startBuyRate = Ask ;
         startSellRate = Bid - TunnelSize*Point;
      }
      if (OK2Sell)
      {
         startSellRate = Bid ;
         startBuyRate = Bid + TunnelSize*Point;
      }
      
   }
   else
   {
     OK2Buy = true;
     OK2Sell = true;
   }
   
// Determine how many lots for next trade based on current number of open positions

   lotMM = Lots * MathPow(HedgeBase,currentOpen);
   if (lotMM == 0) return (0);
   
// Determine if next trade should be long or short based on current number of open positions

  myWantLongs = true;
  if (MathMod(currentOpen,2) > 0.1) myWantLongs = false;
   
   if (FirstDirSell) myWantLongs = !myWantLongs;   // added to match starting trade direction
	if (myWantLongs)
	{
	   if (Ask >=startBuyRate )
	   {

        OpenBuyOrder();
	   }
	}
	else
	{
	   if (Bid <= startSellRate)
	   {
        OpenSellOrder();
	   }
	}
	
   return(0);
}

