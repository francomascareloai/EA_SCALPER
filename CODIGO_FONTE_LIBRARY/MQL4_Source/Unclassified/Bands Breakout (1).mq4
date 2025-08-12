//+------------------------------------------------------------------+
//|                                               Bands Breakout.mq4 |
//|                                                        Brian Rue |
//|                                               brianrue@gmail.com |
//+------------------------------------------------------------------+

#property copyright "Brian Rue"
#property link      "brianrue@gmail.com"

// Permission is granted for personal use. You may distribute this file as long as it is contains this notice, 
// including the author's name, and distributed for free.
// If you do trade this system live, I'd appreciate if you would send me an email and tell me how it's going. And if it's making
// you tons of money, I wouldn't mind a thank-you check :)
// This software is provided AS IS, with no warranty of any kind. No guarantee is made as to the future profitability of this system.
// Trade at your own risk.

#define MAGIC 35583

//---- input parameters
extern int       DeMarker_Period = 14;
extern double    demarker_delta = 0.20; // trade when the DeMarker is outside of .5 +/- demarker_delta
extern int       Bollinger_Period = 14;
extern int       bollinger_delta = 5; // trade when the price is within bollinger_delta points of the band (negative means price must be outside)
extern int       MinADX = 40; // only enter a trade when the ADX is at least this level

extern int       TakeProfit = 20;
extern double    StopLossATR = 10; // number of ATRs to use for the stoploss
extern int       TimePeriod = 5; // in minutes
extern int       Slippage = 3;
extern bool      UseFixedLots = false;
extern int       FixedLotSize = 1;
extern double    VAR = 0.1; // .1 means the value-at-risk is 10% of the account (i.e., if the stoploss is hit, this amount will be lost)

double entry = 0;
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
//| Calculate open positions                                         |
//+------------------------------------------------------------------+
int CalculateCurrentOrders(string symbol)
{
   int buys=0,sells=0;
//----
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGIC)
        {
         if(OrderType()==OP_BUY)  buys++;
         if(OrderType()==OP_SELL) sells++;
        }
     }
//---- return orders volume
   if(buys>0) return(buys);
   else       return(-sells);
}
  
double StopLoss()
{
   double atr = iATR(NULL,240,100,1);
   if (atr * StopLossATR < 10 * Point) return (10 * Point);
   return (atr * StopLossATR);
}
  
double LotSize()
{
   if (UseFixedLots == true) return (FixedLotSize);

   double size;
   
   size = (AccountEquity() * VAR) / (StopLoss() / Point);
   
   if (size < 0.01) size = 0.01;
   if (size > 50) size = 50;
   return (size);
}

bool EnterLong() 
{
   double demarker, highboll, adx;
   
   demarker = iDeMarker(NULL,TimePeriod,DeMarker_Period,1);
   highboll = iBands(NULL,TimePeriod,Bollinger_Period,2,0,PRICE_LOW,MODE_UPPER,1);
   adx = iADX(NULL,TimePeriod,14,PRICE_TYPICAL,MODE_MAIN,1);
   
   // Enter long if demarker is extreme, AND Ask is outside of upper band, AND ADX is extreme
   if ((Ask - bollinger_delta * Point >= highboll) && (MathAbs(demarker - 0.5) >= demarker_delta) && (adx >= MinADX)) {
      return (true);
   }
   else return (false);
}

bool CloseLong()
{
   // Close intentionally if we're profitable
   if (Bid > entry) {
      double ma;
      ma = iMA(NULL,TimePeriod,Bollinger_Period,0,MODE_EMA,PRICE_TYPICAL,1);
   
      // Close when the price drops below the moving average
      if ((Bid < ma)) {
         return (true);
      }
      else return (false);
   } else return (false);
}

bool EnterShort() 
{
   double demarker, lowboll, adx;
   
   demarker = iDeMarker(NULL,TimePeriod,DeMarker_Period,1);
   lowboll = iBands(NULL,TimePeriod,Bollinger_Period,2,0,PRICE_HIGH,MODE_LOWER,1);
   adx = iADX(NULL,TimePeriod,14,PRICE_TYPICAL,MODE_MAIN,1);
   
   // Enter short if demarker is extreme, AND Bid is outside of lower band, AND ADX is high
   if ((Bid + bollinger_delta * Point <= lowboll) && (MathAbs(demarker - 0.5) >= demarker_delta) && (adx >= MinADX)) {
      return (true);
   }
   else return (false);
}

bool CloseShort()
{
   // Close intentionally if we're profitable
   if (Ask < entry) {
      double ma;
   
      ma = iMA(NULL,TimePeriod,Bollinger_Period,0,MODE_EMA,PRICE_TYPICAL,1);
   
      // Close when the price is above the moving average
      if ((Ask > ma)) {
         return (true);
      }
      else return (false);
   } else return (false);
}

//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
   int res;
   
   // long conditions
   if (EnterLong()) {
      res = OrderSend(Symbol(),OP_BUY,LotSize(),Ask,Slippage,Ask-StopLoss(),Bid+TakeProfit*Point,"",MAGIC);
      entry = Ask;
      return;
   }
   
   // short conditions
   else if (EnterShort()) {
      res = OrderSend(Symbol(),OP_SELL,LotSize(),Bid,Slippage,Bid+StopLoss(),Ask-TakeProfit*Point,"",MAGIC);
      entry = Bid;
   }
 
  }
//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
void CheckForClose()
{  
   for (int i=0; i<OrdersTotal(); i++) {
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if (OrderMagicNumber()!=MAGIC || OrderSymbol()!=Symbol()) continue;
      
      if (OrderType()==OP_BUY) {
         // close long conditions
         if (CloseLong()) {
            OrderClose(OrderTicket(),OrderLots(),Bid,Slippage,White);
            if (EnterShort()) {
               OrderSend(Symbol(),OP_SELL,LotSize(),Bid,Slippage,Bid+StopLoss(),Ask-TakeProfit*Point,"",MAGIC);
               entry = Bid;
            }
            break;
         }
      }
      if (OrderType()==OP_SELL) {
         // close short conditions
         if (CloseShort()) {
            OrderClose(OrderTicket(),OrderLots(),Ask,Slippage,White);
            if (EnterLong()) {
               OrderSend(Symbol(),OP_BUY,LotSize(),Ask,Slippage,Ask-StopLoss(),Bid+TakeProfit*Point,"",MAGIC);
               entry = Ask;
            }
            break;
         }
      }
   }
}

  
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
//---- check for history and trading
   if(Bars<100 || IsTradeAllowed()==false) return;
//---- calculate open orders by current symbol
   if(CalculateCurrentOrders(Symbol())==0) CheckForOpen();
   else                                    CheckForClose();
//----
   return(0);
  }
//+------------------------------------------------------------------+